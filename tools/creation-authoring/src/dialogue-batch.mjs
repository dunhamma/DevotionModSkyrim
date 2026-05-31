import { ValidationError } from "./errors.mjs";
import { normalizeManifest } from "./manifest.mjs";
import { createReadbackOracle } from "./readback-oracle.mjs";
import { createResolver } from "./resolver.mjs";
import { verifyManifest } from "./verifier.mjs";

const DIALOGUE_KINDS = new Set([
  "dialogue.branch.create",
  "dialogue.topic.create",
  "dialogue.info.create",
  "artifact.seq.generate"
]);

export function buildDialogueManifestFromRows(rowsDocument, profile = null, options = {}) {
  const rows = normalizeRows(rowsDocument);
  const defaults = rowsDocument && !Array.isArray(rowsDocument) ? rowsDocument : {};
  const project = options.project || defaults.project || profile?.modId || "dialogue-batch";
  const game = options.game || defaults.game || profile?.game;
  const sourcePlugin = options.sourcePlugin || defaults.sourcePlugin || profile?.sourcePlugin;
  const output = options.output || defaults.output || profile?.defaultOutput;
  const ownerQuest = options.ownerQuest || defaults.ownerQuest || defaults.quest || defaults.defaultQuest;
  const defaultBranch = options.defaultBranch || defaults.defaultBranch || defaults.branch || null;
  const seqTarget = options.seqTarget || defaults.seqTarget || ownerQuest;

  const operations = [];
  const seenBranches = new Set();
  const seenTopics = new Set();
  const seqTargets = new Set();

  rows.forEach((row, index) => {
    const normalized = normalizeRow(row, index, { ownerQuest, defaultBranch });
    if (!seenBranches.has(normalized.branchId)) {
      seenBranches.add(normalized.branchId);
      operations.push(buildBranchOperation(normalized));
    }
    if (!seenTopics.has(normalized.topicId)) {
      seenTopics.add(normalized.topicId);
      operations.push(buildTopicOperation(normalized));
    }
    operations.push(buildInfoOperation(normalized));
    seqTargets.add(normalized.ownerQuest || seqTarget);
  });

  for (const target of seqTargets) {
    if (!target) {
      throw new ValidationError("Dialogue rows require ownerQuest or seqTarget for SEQ freshness.", {
        project,
        output
      });
    }
    operations.push(buildSeqOperation(target, output));
  }

  return normalizeManifest({
    schema: "creation-authoring.v1",
    project,
    game,
    sourcePlugin,
    output,
    metadata: {
      supportClaim: false,
      supportClaimAllowed: false,
      proofLane: "dialogue-batch-discovery",
      sourceSchema: defaults.schema || (Array.isArray(rowsDocument) ? "array" : null),
      rowCount: rows.length,
      notes: [
        "Rows scaffold CK-owned dialogue intent only.",
        "Support still requires CKPE-native creation, generated-plugin save, readback, strict proof ledger, and matrix promotion."
      ]
    },
    operations
  }, profile);
}

export function buildDialogueBatchReport(manifest, profile = null, readback = null) {
  const verification = verifyManifest(manifest, profile, readback);
  const resolver = createResolver(profile);
  const oracle = createReadbackOracle(readback);
  const dialogueOperations = manifest.operations.filter((operation) => DIALOGUE_KINDS.has(operation.kind));
  const resultById = new Map(verification.results.map((result) => [result.operationId, result]));
  const bindings = dialogueOperations.map((operation) => {
    const targetResolution = resolver.resolveRecord(operation.target);
    const { record, normalizer } = oracle.find(operation, targetResolution);
    const result = resultById.get(operation.id);
    return buildBinding(operation, result, record, normalizer);
  });
  const summary = summarizeBindings(bindings);

  return {
    schema: "creation-authoring.dialogue-batch-report.v1",
    supportClaimAllowed: false,
    manifest: verification.manifest,
    summary,
    bindings,
    nextActions: buildNextActions(bindings),
    verification
  };
}

function normalizeRows(input) {
  const rows = Array.isArray(input) ? input : input?.rows;
  if (!Array.isArray(rows) || rows.length === 0) {
    throw new ValidationError("Dialogue batch input requires a non-empty rows array.");
  }
  return rows;
}

function normalizeRow(row, index, defaults = {}) {
  if (!row || typeof row !== "object" || Array.isArray(row)) {
    throw new ValidationError(`rows[${index}] must be an object.`);
  }
  const speaker = requireText(row.speaker || row.speakerEditorId, `rows[${index}].speaker`);
  const speakerForm = row.speakerForm || row.speakerFormId || null;
  const prompt = requireText(row.prompt || row.topicPrompt, `rows[${index}].prompt`);
  const responseLine = requireText(row.responseLine || row.response || row.text, `rows[${index}].responseLine`);
  const topicId = requireText(row.topicId || row.topic || row.topicEditorId, `rows[${index}].topicId`);
  const ownerQuest = requireText(row.ownerQuest || row.quest || defaults.ownerQuest, `rows[${index}].ownerQuest`);
  const branchId = row.branchId || row.branch || defaults.defaultBranch || `${topicId}_Branch`;
  const infoId = row.infoId || row.info || row.id || `${topicId}_${speaker}_${index + 1}`;

  return {
    id: row.id || slug(infoId),
    branchId: sanitizeEditorId(branchId),
    topicId: sanitizeEditorId(topicId),
    infoId: sanitizeEditorId(infoId),
    ownerQuest: sanitizeEditorId(ownerQuest),
    speaker: sanitizeEditorId(speaker),
    speakerForm,
    prompt,
    responseLine,
    category: row.category || "Topic",
    branchCategory: row.branchCategory || "Player",
    subtype: row.subtype || "Custom",
    flags: Array.isArray(row.flags) ? row.flags : ["TopLevel"],
    conditions: Array.isArray(row.conditions) ? row.conditions : []
  };
}

function buildBranchOperation(row) {
  return {
    id: `${slug(row.branchId)}-branch`,
    kind: "dialogue.branch.create",
    target: row.branchId,
    recordFamily: "DIAL",
    mode: "create",
    ckSemanticsRequired: true,
    preferredBackend: "ckpe-bridge",
    payload: {
      recordType: "DLBR",
      editorId: row.branchId,
      ownerQuest: row.ownerQuest,
      category: row.branchCategory,
      flags: row.flags,
      startingTopic: row.topicId
    }
  };
}

function buildTopicOperation(row) {
  return {
    id: `${slug(row.topicId)}-topic`,
    kind: "dialogue.topic.create",
    target: row.topicId,
    recordFamily: "DIAL",
    mode: "create",
    ckSemanticsRequired: true,
    preferredBackend: "ckpe-bridge",
    payload: {
      recordType: "DIAL",
      editorId: row.topicId,
      ownerQuest: row.ownerQuest,
      branch: row.branchId,
      prompt: row.prompt,
      category: row.category,
      subtype: row.subtype
    }
  };
}

function buildInfoOperation(row) {
  return {
    id: `${slug(row.infoId)}-info`,
    kind: "dialogue.info.create",
    target: row.infoId,
    recordFamily: "INFO",
    mode: "create",
    ckSemanticsRequired: true,
    preferredBackend: "ckpe-bridge",
    payload: {
      recordType: "INFO",
      ckInfoIdentity: "unnamed-topic-info-accepted",
      topic: row.topicId,
      speaker: row.speaker,
      speakerForm: row.speakerForm,
      prompt: row.prompt,
      responseLine: row.responseLine,
      conditions: row.conditions
    }
  };
}

function buildSeqOperation(target, output) {
  return {
    id: `${slug(target)}-seq`,
    kind: "artifact.seq.generate",
    target,
    recordFamily: "QUST",
    mode: "update",
    ckSemanticsRequired: true,
    preferredBackend: "ckpe-bridge",
    payload: {
      plugin: output
    }
  };
}

function buildBinding(operation, result, record, normalizer) {
  const payload = operation.payload || {};
  const dialogue = record?.dialogue || record?.Dialogue || record?.topicInfo || record?.TopicInfo || {};
  return {
    operationId: operation.id,
    kind: operation.kind,
    target: operation.target,
    recordFamily: operation.recordFamily || payload.recordType || record?.recordType || null,
    status: result?.status || "TODO",
    message: result?.message || `No verification result for ${operation.target}.`,
    formid: record?.formid || record?.FormID || null,
    editorId: record?.editorId || record?.EditorID || null,
    winningPlugin: record?.winningPlugin || record?.WinningPlugin || null,
    recordType: record?.recordType || record?.type || record?.RecordType || null,
    semanticIdentity: operation.kind === "dialogue.info.create" ? {
      topic: payload.topic || payload.parentTopic || null,
      speaker: payload.speaker || payload.speakerEditorId || null,
      speakerForm: payload.speakerForm || null,
      responseLine: payload.responseLine || payload.response || payload.text || null,
      matchedFormid: record?.formid || record?.FormID || null,
      matchedTopic: dialogue.topic || dialogue.parentTopic || record?.topic || null
    } : null,
    normalizer,
    failures: result?.details?.failures || [],
    missing: !record
  };
}

function summarizeBindings(bindings) {
  const summary = {
    total: bindings.length,
    PASS: 0,
    FAIL: 0,
    WARN: 0,
    TODO: 0,
    missing: 0,
    mismatched: 0,
    bound: 0
  };
  for (const binding of bindings) {
    summary[binding.status] = (summary[binding.status] || 0) + 1;
    if (binding.missing) {
      summary.missing += 1;
    } else {
      summary.bound += 1;
    }
    if (binding.failures.length) {
      summary.mismatched += 1;
    }
  }
  return summary;
}

function buildNextActions(bindings) {
  const actions = new Set();
  if (bindings.some((binding) => binding.missing || binding.status === "TODO")) {
    actions.add("Create or verify CK-authored dialogue records, save the active generated plugin, then refresh readback.");
  }
  if (bindings.some((binding) => binding.status === "FAIL" && binding.kind !== "artifact.seq.generate")) {
    actions.add("Fix mismatched dialogue fields or conditions in CK, or update manifest intent.");
  }
  if (bindings.some((binding) => binding.kind === "artifact.seq.generate" && binding.status !== "PASS")) {
    actions.add("Refresh SEQ after CK dialogue save and rerun readback.");
  }
  if (!actions.size) {
    actions.add("Review command evidence before support or promotion; readback alone does not prove CK-owned creation.");
  }
  return Array.from(actions);
}

function requireText(value, field) {
  if (typeof value !== "string" || !value.trim()) {
    throw new ValidationError(`${field} must be a non-empty string.`);
  }
  return value.trim();
}

function sanitizeEditorId(value) {
  return requireText(value, "editorId").replace(/[^A-Za-z0-9_]/gu, "_");
}

function slug(value) {
  return String(value || "dialogue")
    .trim()
    .replace(/[^A-Za-z0-9]+/gu, "-")
    .replace(/^-|-$/gu, "")
    .toLowerCase() || "dialogue";
}
