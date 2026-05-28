import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createCapabilityRegistry } from "./capabilities.mjs";
import { readDocument, writeJson } from "./io.mjs";
import { emptyProofResults, flattenProofLedgerResults } from "./proof-ledger.mjs";
export { MATRIX_STATUSES } from "./release-status.mjs";
import { MATRIX_STATUSES } from "./release-status.mjs";

const NON_RECORD_FAMILIES = new Set(["NONE", "TES4", "GRUP"]);
const READ_ONLY_FAMILIES = new Set(["GMST", "SKIL"]);
const RESEARCH_ONLY_FAMILIES = new Set([
  "CELL",
  "LAND",
  "NAVI",
  "NAVM",
  "REGN",
  "TLOD",
  "WRLD"
]);

const CKPE_ARRAY_SIGNATURES = {
  arrCell: "CELL",
  arrFootstep: "FSTP",
  arrFootstepSet: "FSTS",
  arrImpactData: "IPCT",
  arrImpactDataSet: "IPDS",
  arrLandspace: "LAND",
  arrLandTexture: "LTEX",
  arrLight: "LIGH",
  arrMaterialType: "MATT",
  arrReference: "REFR",
  arrSoundCategory: "SNCT",
  arrSoundDescriptor: "SNDR",
  arrSoundOutputModel: "SOPM",
  arrTopic: "DIAL",
  arrTopicInfo: "INFO",
  arrVoiceType: "VTYP"
};

const FAMILY_OPERATION_COVERAGE = {
  ACTI: ["record.duplicate_create", "activator.payload.set", "record.create", "record.update", "vmad.attach_script", "vmad.set_property", "vmad.set_array_property"],
  DIAL: ["dialogue.branch.create", "dialogue.topic.create"],
  FLST: ["record.duplicate_create", "record.create", "record.update", "formlist.add"],
  GLOB: ["glob.duplicate_create"],
  INFO: ["dialogue.info.create", "condition.add", "artifact.lip.generate"],
  MESG: ["record.duplicate_create", "message.payload.set", "record.create", "record.update"],
  MGEF: ["record.create", "record.update", "vmad.attach_script", "condition.add"],
  NPC_: ["record.create", "record.update", "keyword.add", "inventory.add", "spell.add", "perk.add", "package.add", "artifact.facegen.generate"],
  PACK: ["record.create", "record.update", "package.add", "condition.add"],
  PERK: ["record.create", "record.update", "perk.add", "condition.add", "vmad.attach_script"],
  QUST: [
    "record.duplicate_create",
    "record.create",
    "record.update",
    "quest.create",
    "quest.alias.add",
    "quest.stage.fragment",
    "condition.add",
    "vmad.attach_script",
    "vmad.set_property",
    "vmad.set_array_property",
    "artifact.seq.generate"
  ],
  REFR: ["reference.place"],
  SCEN: ["scene.create", "condition.add"],
  SMEN: ["story_manager.node.create", "condition.add"],
  SMBN: ["story_manager.node.create", "condition.add"],
  SMQN: ["story_manager.node.create", "condition.add"],
  SPEL: ["record.create", "record.update", "spell.add", "condition.add"]
};

const FAMILY_NORMALIZERS = {
  ACTI: "readback.activator-scripts",
  DIAL: "readback.dialogue-topic",
  FLST: "readback.formlist",
  GLOB: "readback.record-exists",
  INFO: "readback.dialogue-info",
  MESG: "readback.message",
  MGEF: "readback.magic-effect",
  NPC_: "readback.npc",
  PACK: "readback.package",
  PERK: "readback.perk",
  QUST: "readback.quest-vmad-alias-stage",
  REFR: "readback.placed-reference",
  SCEN: "readback.scene",
  SMEN: "readback.story-manager-event-node",
  SMBN: "readback.story-manager-branch-node",
  SMQN: "readback.story-manager-quest-node",
  SPEL: "readback.spell"
};

export function defaultRepoRoot() {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..", "..");
}

export function defaultCkpeRoot(repoRoot = defaultRepoRoot()) {
  return path.join(repoRoot, "third_party", "Creation-Kit-Platform-Extended");
}

export function defaultGeneratedDir(repoRoot = defaultRepoRoot()) {
  return path.join(repoRoot, "generated");
}

export function extractCkpeRecordInventory({
  game = "SkyrimSE",
  ckpeRoot = defaultCkpeRoot()
} = {}) {
  const handlerPath = path.join(ckpeRoot, `CKPE.${game}`, "Include", "EditorAPI", "TESDataHandler.h");
  if (!fs.existsSync(handlerPath)) {
    throw new Error(`CKPE TESDataHandler inventory source not found: ${handlerPath}`);
  }

  const lines = fs.readFileSync(handlerPath, "utf8").split(/\r?\n/u);
  const byFamily = new Map();
  for (const [lineIndex, line] of lines.entries()) {
    const match = line.match(/\b(?:TESFormArray|BSTArray<[^>]+>)\s+(arr[A-Za-z0-9_]+)\s*;\s*\/\/\s*([0-9A-Fa-f]+)\s+Form Type\s+(\d+)(.*)$/u);
    if (!match) {
      continue;
    }
    const [, ckpeArray, offset, formTypeText, commentTail] = match;
    const recordFamily = signatureForCkpeArray(ckpeArray, commentTail);
    if (!recordFamily || byFamily.has(recordFamily)) {
      continue;
    }
    byFamily.set(recordFamily, {
      recordFamily,
      formType: Number.parseInt(formTypeText, 10),
      ckpeArray,
      ckpeOffset: `0x${offset.toUpperCase()}`,
      source: "CKPE.SkyrimSE TESDataHandler",
      sourceFile: path.relative(defaultRepoRoot(), handlerPath).replaceAll("\\", "/"),
      sourceLine: lineIndex + 1
    });
  }

  const recordFamilies = [...byFamily.values()].sort((left, right) => left.formType - right.formType);
  return {
    schema: "creation-authoring.ck-record-inventory.v1",
    game,
    source: {
      kind: "ckpe-tes-data-handler",
      path: path.relative(defaultRepoRoot(), handlerPath).replaceAll("\\", "/")
    },
    generatedAt: new Date().toISOString(),
    count: recordFamilies.length,
    recordFamilies
  };
}

export function loadProofResults(proofResultsPath = null) {
  const resolvedProofResultsPath = proofResultsPath || defaultProofResultsPath();
  if (!resolvedProofResultsPath) {
    return emptyProofResults();
  }
  return flattenProofLedgerResults(readDocument(resolvedProofResultsPath).document);
}

function defaultProofResultsPath() {
  const candidate = path.join(defaultGeneratedDir(), "proof-results.skyrimse.json");
  return fs.existsSync(candidate) ? candidate : null;
}

export function buildCapabilityMatrix({
  inventory,
  proofResults = loadProofResults(),
  registry = createCapabilityRegistry(),
  game = inventory?.game || "SkyrimSE"
} = {}) {
  if (!inventory?.recordFamilies) {
    throw new Error("buildCapabilityMatrix requires an inventory document.");
  }
  const proofByFamily = new Map();
  const proofsByFamilyOperation = new Map();
  for (const proof of proofResults?.results || []) {
    if (proof.recordFamily) {
      const recordFamily = String(proof.recordFamily).toUpperCase();
      proofByFamily.set(recordFamily, proof);
      const operation = String(proof.operation || "");
      if (operation) {
        const key = `${recordFamily}:${operation}`;
        const existing = proofsByFamilyOperation.get(key);
        if (!existing || proof.status === "PASS") {
          proofsByFamilyOperation.set(key, proof);
        }
      }
    }
  }

  const rows = inventory.recordFamilies.map((family) => {
    const recordFamily = family.recordFamily;
    const proof = proofByFamily.get(recordFamily);
    const operationKinds = FAMILY_OPERATION_COVERAGE[recordFamily] || [];
    const operationProofs = operationKinds.map((operation) => {
      const proof = proofsByFamilyOperation.get(`${recordFamily}:${operation}`) || null;
      return {
        operation,
        status: proof?.status || "UNPROVEN",
        target: proof?.target || null,
        generatedPlugin: proof?.generatedPlugin || null,
        fixture: proof?.fixture || null,
        strictReport: proof?.strictReport || null,
        proofLedger: proof ? proof.proofLedger || proofResults?.sourceLedger || null : null,
        verifiedAt: proof?.verifiedAt || null,
        backend: proof?.backend || null,
        readbackStatus: proof?.readbackStatus || null,
        verifierStatus: proof?.verifierStatus || null,
        commandEvidenceStatus: proof?.commandEvidenceStatus || null,
        coverage: proof?.coverage || {},
        missingCoverage: proof?.missingCoverage || []
      };
    });
    const capabilities = operationKinds.map((kind) => registry.get(kind)).filter(Boolean);
    const hasCkRequiredCapability = capabilities.some((capability) => capability.requiresCkSemantics || capability.supportedBackends.includes("ckpe-bridge"));
    const hasSafeWriterCapability = capabilities.some((capability) => ["safe_writer", "generated_artifact"].includes(capability.tier));
    const status = classifyRecordFamily({
      recordFamily,
      proof,
      operationKinds,
      proofsByFamilyOperation,
      hasCkRequiredCapability,
      hasSafeWriterCapability
    });
    const verifier = firstKnown(capabilities.map((capability) => capability.verifier));
    return {
      recordFamily,
      formType: family.formType,
      ckpeArray: family.ckpeArray,
      status,
      manifestOperations: operationKinds,
      supportedCommands: capabilities
        .flatMap((capability) => commandNamesForOperation(capability.kind))
        .filter((value, index, list) => list.indexOf(value) === index),
      backends: capabilities
        .flatMap((capability) => capability.supportedBackends)
        .filter((value, index, list) => list.indexOf(value) === index),
      readbackNormalizer: FAMILY_NORMALIZERS[recordFamily] || null,
      verifier: verifier || null,
      proofFixture: proof?.fixture || null,
      proofStatus: proof?.status || "UNPROVEN",
      proofReport: proof?.strictReport || null,
      proofLedger: proof ? proof.proofLedger || proofResults?.sourceLedger || null : null,
      proofTarget: proof?.target || null,
      proofGeneratedPlugin: proof?.generatedPlugin || null,
      proofCoverage: proof?.coverage || {},
      proofMissingCoverage: proof?.missingCoverage || [],
      operationProofs: operationProofs.length ? operationProofs : undefined,
      proofCommandEvidenceStatus: proof?.commandEvidenceStatus || null,
      proofReadbackStatus: proof?.readbackStatus || null,
      proofVerifierStatus: proof?.verifierStatus || null,
      lastProvenAt: proof?.verifiedAt || null,
      blockReason: blockReasonForStatus(status, { proof, operationKinds, recordFamily }),
      source: {
        file: family.sourceFile,
        line: family.sourceLine
      }
    };
  });

  return {
    schema: "creation-authoring.capability-matrix.v1",
    game,
    generatedAt: new Date().toISOString(),
    inventorySource: inventory.source,
    statusValues: MATRIX_STATUSES,
    summary: rows.reduce((summary, row) => {
      summary.total += 1;
      summary[row.status] = (summary[row.status] || 0) + 1;
      return summary;
    }, { total: 0 }),
    rows
  };
}

export function verifyCapabilityMatrix(matrix, inventory = null) {
  const failures = [];
  if (!matrix?.rows?.length) {
    failures.push({ code: "empty_matrix", message: "Capability matrix has no rows." });
  }

  const inventoryFamilies = new Set((inventory?.recordFamilies || []).map((family) => family.recordFamily));
  const matrixFamilies = new Set();
  for (const row of matrix?.rows || []) {
    if (!row.recordFamily) {
      failures.push({ code: "missing_record_family", message: "Matrix row is missing recordFamily.", row });
      continue;
    }
    if (matrixFamilies.has(row.recordFamily)) {
      failures.push({ code: "duplicate_record_family", recordFamily: row.recordFamily });
    }
    matrixFamilies.add(row.recordFamily);
    if (!MATRIX_STATUSES.includes(row.status)) {
      failures.push({ code: "invalid_status", recordFamily: row.recordFamily, status: row.status });
    }
    if (row.status === "supported") {
      const missingCoverage = [];
      if (row.proofStatus !== "PASS") missingCoverage.push("passing proof result");
      if (!row.manifestOperations?.length) missingCoverage.push("manifest operation");
      if (!row.supportedCommands?.length) missingCoverage.push("CKPE or writer command");
      if (!row.readbackNormalizer) missingCoverage.push("readback normalizer");
      if (!row.verifier) missingCoverage.push("verifier");
      if (!row.proofFixture) missingCoverage.push("proof fixture");
      if (!row.proofReport) missingCoverage.push("strict proof report");
      if (row.proofReadbackStatus !== "PASS") missingCoverage.push("passing readback proof");
      if (row.proofVerifierStatus !== "PASS") missingCoverage.push("passing verifier proof");
      if (row.proofCommandEvidenceStatus === "MISSING" || row.proofCommandEvidenceStatus === "FAIL") missingCoverage.push("passing command evidence");
      for (const [coverageName, present] of Object.entries(row.proofCoverage || {})) {
        if (present !== true) missingCoverage.push(`proof coverage ${coverageName}`);
      }
      if (missingCoverage.length) {
        failures.push({
          code: "unsupported_supported_row",
          recordFamily: row.recordFamily,
          message: `Row is marked supported without ${missingCoverage.join(", ")}.`
        });
      }
    }
  }

  for (const family of inventoryFamilies) {
    if (!matrixFamilies.has(family)) {
      failures.push({ code: "missing_inventory_family", recordFamily: family });
    }
  }

  return {
    schema: "creation-authoring.capability-matrix-verification.v1",
    status: failures.length ? "FAIL" : "PASS",
    generatedAt: new Date().toISOString(),
    failures
  };
}

export function explainCapabilityForFamily(matrix, recordFamily) {
  const normalized = String(recordFamily || "").toUpperCase();
  return matrix.rows.find((row) => row.recordFamily === normalized) || {
    recordFamily: normalized,
    status: "manual_blocked",
    message: "No inventory row exists for this record family."
  };
}

export function formatCapabilityMatrixMarkdown(matrix, verification = null) {
  const lines = [
    "# Skyrim SE CK Record Capability Matrix",
    "",
    `Generated: ${matrix.generatedAt}`,
    `Rows: ${matrix.summary.total}`,
    "",
    "| Record | Form Type | Status | Operations | Proof |",
    "| --- | ---: | --- | --- | --- |"
  ];
  for (const row of matrix.rows) {
    lines.push(`| ${row.recordFamily} | ${row.formType} | ${row.status} | ${formatCellList(row.manifestOperations)} | ${row.proofStatus} |`);
  }
  if (verification) {
    lines.push("", `Verification: ${verification.status}`);
    for (const failure of verification.failures || []) {
      lines.push(`- ${failure.code}: ${failure.recordFamily || failure.message || "matrix failure"}`);
    }
  }
  return `${lines.join("\n")}\n`;
}

export function writeInventoryArtifact(inventory, {
  repoRoot = defaultRepoRoot(),
  game = inventory.game || "SkyrimSE"
} = {}) {
  return writeJson(path.join(defaultGeneratedDir(repoRoot), `ck-record-inventory.${game.toLowerCase()}.json`), inventory);
}

export function writeCapabilityMatrixArtifacts(matrix, verification = null, {
  repoRoot = defaultRepoRoot(),
  game = matrix.game || "SkyrimSE"
} = {}) {
  const generatedDir = defaultGeneratedDir(repoRoot);
  const stem = `capability-matrix.${game.toLowerCase()}`;
  const jsonPath = writeJson(path.join(generatedDir, `${stem}.json`), matrix);
  fs.mkdirSync(generatedDir, { recursive: true });
  const markdownPath = path.join(generatedDir, `${stem}.md`);
  fs.writeFileSync(markdownPath, formatCapabilityMatrixMarkdown(matrix, verification), "utf8");
  const verificationPath = verification
    ? writeJson(path.join(generatedDir, `${stem}.verification.json`), verification)
    : null;
  return { jsonPath, markdownPath, verificationPath };
}

function signatureForCkpeArray(ckpeArray, commentTail) {
  const explicit = commentTail.match(/<([A-Z0-9_]{4})>/u);
  if (explicit) {
    return explicit[1];
  }
  if (CKPE_ARRAY_SIGNATURES[ckpeArray]) {
    return CKPE_ARRAY_SIGNATURES[ckpeArray];
  }
  return ckpeArray.replace(/^arr/u, "").toUpperCase();
}

function classifyRecordFamily({
  recordFamily,
  proof,
  operationKinds = [],
  proofsByFamilyOperation = new Map(),
  hasCkRequiredCapability,
  hasSafeWriterCapability
}) {
  const allOperationsProven = operationKinds.length > 0 &&
    operationKinds.every((operation) => proofsByFamilyOperation.get(`${recordFamily}:${operation}`)?.status === "PASS");
  if (proof?.status === "PASS" && allOperationsProven) {
    return "supported";
  }
  if (NON_RECORD_FAMILIES.has(recordFamily)) {
    return "not_applicable";
  }
  if (READ_ONLY_FAMILIES.has(recordFamily)) {
    return "read_only";
  }
  if (RESEARCH_ONLY_FAMILIES.has(recordFamily)) {
    return "research_only";
  }
  if (hasCkRequiredCapability) {
    return "ck_required_unproven";
  }
  if (hasSafeWriterCapability) {
    return "safe_writer_unproven";
  }
  return "research_only";
}

function blockReasonForStatus(status, { proof, operationKinds, recordFamily }) {
  if (status === "supported") {
    return null;
  }
  if (status === "not_applicable") {
    return "Not a standalone authored CK record family.";
  }
  if (status === "read_only") {
    return "Read-only or engine-owned in this product until a mutation proof exists.";
  }
  if (status === "research_only") {
    return "Inventory exists, but no end-to-end CKPE mutation and MO2 readback proof has been defined.";
  }
  if (status === "ck_required_unproven") {
    return "Manifest operation coverage exists, but CKPE execution and live readback proof is not passing yet.";
  }
  if (status === "safe_writer_unproven") {
    return "Structured writer coverage exists, but strict generated-plugin proof is not passing yet.";
  }
  if (proof?.status && proof.status !== "PASS") {
    return `Latest proof status is ${proof.status}.`;
  }
  return `Record family ${recordFamily} is not shippable until a proof fixture passes.`;
}

function commandNamesForOperation(kind) {
  const commands = {
    "artifact.facegen.generate": ["generateFaceGen"],
    "artifact.lip.generate": ["generateLip"],
    "artifact.seq.generate": ["generateSeq"],
    "condition.add": ["setConditions"],
    "dialogue.branch.create": ["createDialogueBranch"],
    "dialogue.info.create": ["createDialogueInfo"],
    "dialogue.topic.create": ["createDialogueTopic"],
    "formlist.add": ["addFormListEntry"],
    "glob.duplicate_create": ["duplicateCreateGlob"],
    "inventory.add": ["addInventoryEntry"],
    "keyword.add": ["addKeyword"],
    "message.payload.set": ["setMessagePayload"],
    "package.add": ["addPackage"],
    "perk.add": ["addPerk"],
    "activator.payload.set": ["setActivatorPayload"],
    "quest.alias.add": ["addAlias"],
    "quest.create": ["createRecord"],
    "quest.stage.fragment": ["setQuestStageFragment"],
    "record.create": ["createRecord"],
    "record.update": ["updateRecord"],
    "reference.place": ["placeReference"],
    "scene.create": ["createScene"],
    "spell.add": ["addSpell"],
    "story_manager.node.create": ["addStoryManagerNode"],
    "vmad.attach_script": ["attachScript"],
    "vmad.set_array_property": ["setArrayProperty"],
    "vmad.set_property": ["setProperty"]
  };
  return commands[kind] || [];
}

function firstKnown(values) {
  return values.find((value) => value && value !== "manual.review") || null;
}

function formatCellList(values) {
  if (!values?.length) {
    return "";
  }
  return values.join("<br>");
}


