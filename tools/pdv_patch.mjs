#!/usr/bin/env node
/*
 * Offline patch-planning helper for PlayerDevotion classification/distribution
 * work. It validates tracked rule manifests, reads the resolved MO2 load order
 * through the same Mutagen bridge context used by pdv_author/pdv_verify,
 * resolves winning records and payload references, emits deterministic dry-run
 * plans, and can write a generated patch plugin through the existing bridge
 * patch-request contract.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const STOCK_GAME = path.join(ANVIL_ROOT, "Stock Game");
const STOCK_GAME_DATA = path.join(STOCK_GAME, "Data");
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const DEVOTION_PROFILE = path.join(ANVIL_ROOT, "profiles", "Devotion Dev");
const DEVOTION_LOADORDER = path.join(DEVOTION_PROFILE, "loadorder.txt");
const DEVOTION_PLUGINS = path.join(DEVOTION_PROFILE, "plugins.txt");
const DEVOTION_MODLIST = path.join(DEVOTION_PROFILE, "modlist.txt");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const DEFAULT_RULES_DIR = path.join(PROJECT_ROOT, "references", "authoring", "patch-rules");
const DEFAULT_OUTPUT = "PDV_ClassificationPatch.esp";
const BRIDGE_MAX_BUFFER = 128 * 1024 * 1024;
const RULE_SCHEMA = "pdv_patch_rules_v0";
const SUPPORTED_OPERATIONS = new Set(["keyword_add", "formlist_inject", "actor_distribution"]);
const DISTRIBUTION_PAYLOAD_KEYS = ["addKeywords", "addSpells", "addPerks", "addFactions", "addItems", "addPackages"];
const ALLOWED_PROVENANCE_STATUSES = new Set(["tooling-example", "candidate", "approved", "blocked"]);
const PLAN_ONLY_PROVENANCE_STATUSES = new Set(["tooling-example"]);
const PAYLOAD_EXPECTED_TYPES = {
  keywords: ["KYWD"],
  addKeywords: ["KYWD"],
  addSpells: ["SPEL"],
  addPerks: ["PERK"],
  addFactions: ["FACT"],
  addPackages: ["PACK"],
};

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  if (!args.command) {
    usage();
  }

  if (args.command === "validate") {
    const result = buildRuleEvaluation(args);
    writeOptionalArtifacts(args, result);
    printResult(result, args.json);
    return;
  }

  if (args.command === "plan") {
    const result = buildRuleEvaluation(args);
    const plan = buildDryRunPlan(result);
    const payload = { ...result, plan };
    writeOptionalArtifacts(args, payload);
    printResult(payload, args.json);
    return;
  }

  if (args.command === "build") {
    const result = buildRuleEvaluation(args);
    const plan = buildDryRunPlan(result);
    const build = buildGeneratedPatchRequest(result, args);
    const payload = { ...result, plan, build };

    if (!args.dryRun) {
      if (build.blockedRuleCount) {
        throw new Error(`Refusing to build with ${build.blockedRuleCount} build-blocked rule(s). Re-run with --dry-run to inspect the ready subset.`);
      }
      if (!build.patchRequest.records.length) {
        throw new Error("Refusing to build because no build-ready rules produced patch records.");
      }
      const mutationCheck = snapshotSourcePlugins(build.sourcePluginPaths);
      const writeResult = invokePatchWrite(build.patchRequest);
      payload.write = {
        ...writeResult,
        mutationCheck: compareSourceSnapshots(mutationCheck),
      };
    } else {
      payload.write = {
        dryRun: true,
        message: "No patch plugin was written.",
      };
    }

    writeOptionalArtifacts(args, payload);
    if (args.writeRequest) {
      writeJsonArtifact(args.writeRequest, build.patchRequest);
    }
    printResult(payload, args.json);
    return;
  }

  usage(`Unknown command: ${args.command}`);
}

function usage(errorMessage = null) {
  if (errorMessage) {
    console.error(errorMessage);
    console.error("");
  }

  console.log([
    "Usage:",
    "  node .\\tools\\pdv_patch.mjs validate [--rules <path>] [--json]",
    "  node .\\tools\\pdv_patch.mjs plan [--rules <path>] [--json]",
    "  node .\\tools\\pdv_patch.mjs build [--rules <path>] [--output <filename>] [--dry-run] [--allow-candidates] [--allow-tooling-examples] [--json]",
    "Optional output:",
    "  --write-plan <path>     write machine-readable JSON payload",
    "  --write-report <path>   write human-readable dry-run report",
    "  --write-request <path>  write generated patch-request JSON",
    "Notes:",
    `  - Default rules directory: ${toWindows(DEFAULT_RULES_DIR)}`,
    `  - Default generated patch: ${DEFAULT_OUTPUT}`,
    `  - Supported manifest schema: ${RULE_SCHEMA}`,
    "  - validate and plan are read-only; build writes only to the Devotion mod folder unless --dry-run is supplied.",
  ].join("\n"));
  process.exit(errorMessage ? 1 : 0);
}

function parseArgs(argv) {
  const args = {
    command: null,
    json: false,
    rulesPath: null,
    writePlan: null,
    writeReport: null,
    writeRequest: null,
    output: DEFAULT_OUTPUT,
    author: "PlayerDevotion Phase 19 patcher",
    esl: true,
    dryRun: false,
    allowCandidates: false,
    allowToolingExamples: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!args.command && !arg.startsWith("-")) {
      args.command = arg;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--rules") {
      args.rulesPath = requireNext(argv, ++index, "--rules");
    } else if (arg.startsWith("--rules=")) {
      args.rulesPath = arg.slice("--rules=".length);
    } else if (arg === "--write-plan") {
      args.writePlan = requireNext(argv, ++index, "--write-plan");
    } else if (arg.startsWith("--write-plan=")) {
      args.writePlan = arg.slice("--write-plan=".length);
    } else if (arg === "--write-report") {
      args.writeReport = requireNext(argv, ++index, "--write-report");
    } else if (arg.startsWith("--write-report=")) {
      args.writeReport = arg.slice("--write-report=".length);
    } else if (arg === "--write-request") {
      args.writeRequest = requireNext(argv, ++index, "--write-request");
    } else if (arg.startsWith("--write-request=")) {
      args.writeRequest = arg.slice("--write-request=".length);
    } else if (arg === "--output") {
      args.output = requireNext(argv, ++index, "--output");
    } else if (arg.startsWith("--output=")) {
      args.output = arg.slice("--output=".length);
    } else if (arg === "--author") {
      args.author = requireNext(argv, ++index, "--author");
    } else if (arg.startsWith("--author=")) {
      args.author = arg.slice("--author=".length);
    } else if (arg === "--no-esl") {
      args.esl = false;
    } else if (arg === "--dry-run") {
      args.dryRun = true;
    } else if (arg === "--allow-candidates") {
      args.allowCandidates = true;
    } else if (arg === "--allow-tooling-examples") {
      args.allowToolingExamples = true;
    } else if (arg === "-h" || arg === "--help") {
      usage();
    } else {
      usage(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function requireNext(argv, index, flag) {
  const value = argv[index];
  if (!value) {
    usage(`Missing value after ${flag}.`);
  }
  return value;
}

function buildRuleEvaluation(args) {
  checkEnvironment();
  const manifests = loadRuleManifests(args.rulesPath);
  const loadOrder = buildLoadOrderContext();
  const relevantPlugins = collectRelevantPluginNames(manifests);
  const winningContext = buildWinningContext(loadOrder, relevantPlugins);
  const evaluations = manifests.flatMap((manifest) => {
    return manifest.rules.map((rule, ruleIndex) => evaluateRule(manifest, rule, ruleIndex, winningContext));
  });

  const summary = {
    manifestCount: manifests.length,
    ruleCount: evaluations.length,
    ready: evaluations.filter((item) => item.status === "READY").length,
    blocked: evaluations.filter((item) => item.status === "BLOCKED").length,
    buildReady: evaluations.filter((item) => item.buildStatus === "BUILD_READY").length,
    planOnly: evaluations.filter((item) => item.buildStatus === "PLAN_ONLY").length,
    buildBlocked: evaluations.filter((item) => item.buildStatus === "BUILD_BLOCKED").length,
    totalResolvedTargets: evaluations.reduce((sum, item) => sum + item.resolvedTargets.length, 0),
    enabledPluginCount: winningContext.enabledListings.length,
  };

  return {
    schema: RULE_SCHEMA,
    source: {
      rulesPath: toWindows(resolveRulesPath(args.rulesPath)),
      manifests: manifests.map((manifest) => ({
        id: manifest.id,
        title: manifest.title,
        file: manifest.source,
        ruleCount: manifest.rules.length,
      })),
    },
    environment: {
      profile: "Devotion Dev",
      enabledPlugins: winningContext.enabledListings.map((listing) => listing.name),
    },
    summary,
    evaluations,
  };
}

function buildDryRunPlan(result) {
  const readyRules = result.evaluations.filter((item) => item.status === "READY");
  const plannedRecords = readyRules.flatMap((item) => item.resolvedTargets);
  const countsByOperation = {};

  for (const rule of readyRules) {
    countsByOperation[rule.operation] = (countsByOperation[rule.operation] || 0) + 1;
  }

  return {
    kind: "pdv_patch_plan_v0",
    generatedAt: new Date().toISOString(),
    countsByOperation,
    readyRuleCount: readyRules.length,
    blockedRuleCount: result.evaluations.length - readyRules.length,
    totalTargetRecords: plannedRecords.length,
    rules: readyRules.map((rule) => ({
      manifestId: rule.manifestId,
      ruleId: rule.ruleId,
      description: rule.description,
      operation: rule.operation,
      target: rule.target,
      payload: rule.payload,
      resolvedPayload: serializeResolvedPayload(rule.resolvedPayload),
      provenance: rule.provenance,
      buildStatus: rule.buildStatus,
      resolvedTargets: rule.resolvedTargets.map((target) => ({
        plugin: target.pluginName,
        formid: target.formid,
        editorId: target.edid,
        signature: target.type,
        pluginPath: toWindows(target.pluginPath),
      })),
      recordActionSummary: buildRecordActionSummary(rule),
    })),
  };
}

function buildGeneratedPatchRequest(result, args) {
  const outputPath = buildSafeOutputPath(args.output);
  const includeRule = (rule) => {
    if (rule.buildStatus !== "BUILD_READY") {
      return false;
    }
    const provenanceStatus = normalizeProvenanceStatus(rule.provenance.status);
    if (provenanceStatus === "approved") {
      return true;
    }
    if (provenanceStatus === "candidate") {
      return args.allowCandidates;
    }
    if (PLAN_ONLY_PROVENANCE_STATUSES.has(provenanceStatus)) {
      return args.allowToolingExamples;
    }
    return false;
  };
  const buildRules = result.evaluations.filter(includeRule);
  const skippedPlanOnly = result.evaluations.filter((rule) =>
    rule.buildStatus === "PLAN_ONLY" && !args.allowToolingExamples,
  );
  const skippedCandidates = result.evaluations.filter((rule) =>
    rule.buildStatus === "BUILD_READY"
      && normalizeProvenanceStatus(rule.provenance.status) === "candidate"
      && !args.allowCandidates,
  );
  const blockedRuleCount = result.evaluations.filter((rule) => rule.buildStatus === "BUILD_BLOCKED").length;
  const records = new Map();

  for (const rule of buildRules) {
    if (rule.operation === "keyword_add") {
      for (const target of rule.resolvedTargets) {
        const spec = getOrCreatePatchRecord(records, target);
        spec.add_keywords = uniqueStrings([...(spec.add_keywords || []), ...rule.resolvedPayload.keywords.map((record) => record.formid)]);
      }
    } else if (rule.operation === "formlist_inject") {
      const spec = getOrCreatePatchRecord(records, rule.resolvedFormList);
      spec.add_form_list_entries = uniqueStrings([...(spec.add_form_list_entries || []), ...rule.resolvedTargets.map((record) => record.formid)]);
    } else if (rule.operation === "actor_distribution") {
      for (const target of rule.resolvedTargets) {
        const spec = getOrCreatePatchRecord(records, target);
        appendResolvedField(spec, "add_keywords", rule.resolvedPayload.addKeywords);
        appendResolvedField(spec, "add_spells", rule.resolvedPayload.addSpells);
        appendResolvedField(spec, "add_perks", rule.resolvedPayload.addPerks);
        appendResolvedField(spec, "add_factions", rule.resolvedPayload.addFactions);
        appendResolvedField(spec, "add_inventory", rule.resolvedPayload.addItems);
        appendResolvedField(spec, "add_packages", rule.resolvedPayload.addPackages);
      }
    }
  }

  const patchRequest = {
    output_path: toPosix(outputPath),
    esl_flag: Boolean(args.esl),
    author: args.author,
    records: [...records.values()].sort((left, right) => left.formid.localeCompare(right.formid)),
    load_order: buildWriterLoadOrderContext(outputPath),
  };

  const sourcePluginPaths = uniqueStrings(
    patchRequest.records
      .map((record) => record.source_path)
      .filter(Boolean),
  );

  return {
    kind: "pdv_patch_build_v0",
    outputPath: toWindows(outputPath),
    dryRun: Boolean(args.dryRun),
    allowCandidates: Boolean(args.allowCandidates),
    allowToolingExamples: Boolean(args.allowToolingExamples),
    buildRuleCount: buildRules.length,
    blockedRuleCount,
    skippedPlanOnlyRuleCount: skippedPlanOnly.length,
    skippedCandidateRuleCount: skippedCandidates.length,
    patchRecordCount: patchRequest.records.length,
    sourcePluginPaths: sourcePluginPaths.map(toWindows),
    patchRequest,
  };
}

function getOrCreatePatchRecord(records, sourceRecord) {
  const key = sourceRecord.formid;
  let spec = records.get(key);
  if (!spec) {
    spec = {
      op: "override",
      formid: sourceRecord.formid,
      source_plugin: sourceRecord.pluginName,
      source_path: toPosix(sourceRecord.pluginPath),
    };
    records.set(key, spec);
  }
  return spec;
}

function appendResolvedField(spec, fieldName, records = []) {
  if (!records.length) {
    return;
  }
  spec[fieldName] = uniqueStrings([...(spec[fieldName] || []), ...records.map((record) => record.formid)]);
}

function buildRecordActionSummary(rule) {
  if (rule.operation === "keyword_add") {
    return `Would add ${rule.payload.keywords.length} keyword reference(s) to ${rule.resolvedTargets.length} matched record(s).`;
  }
  if (rule.operation === "formlist_inject") {
    return `Would inject ${rule.resolvedTargets.length} matched record(s) into ${rule.resolvedFormList.editorId || rule.resolvedFormList.formid}.`;
  }
  if (rule.operation === "actor_distribution") {
    return `Would plan actor/base-record distribution across ${rule.resolvedTargets.length} matched record(s).`;
  }
  return "Planned dry-run action.";
}

function writeOptionalArtifacts(args, payload) {
  if (args.writePlan) {
    writeJsonArtifact(args.writePlan, payload);
  }
  if (args.writeReport) {
    writeTextArtifact(args.writeReport, renderTextReport(payload));
  }
}

function printResult(payload, asJson) {
  if (asJson) {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }
  console.log(renderTextReport(payload));
}

function renderTextReport(payload) {
  const lines = [
    `schema=${payload.schema}`,
    `rules_source=${payload.source.rulesPath}`,
    `manifests=${payload.summary.manifestCount} rules=${payload.summary.ruleCount} ready=${payload.summary.ready} blocked=${payload.summary.blocked} build_ready=${payload.summary.buildReady} plan_only=${payload.summary.planOnly} build_blocked=${payload.summary.buildBlocked} targets=${payload.summary.totalResolvedTargets}`,
    `enabled_plugins=${payload.summary.enabledPluginCount}`,
  ];

  if (payload.plan) {
    lines.push(`plan_ready_rules=${payload.plan.readyRuleCount} blocked_rules=${payload.plan.blockedRuleCount} target_records=${payload.plan.totalTargetRecords}`);
  }
  if (payload.build) {
    lines.push(`build_rules=${payload.build.buildRuleCount} blocked=${payload.build.blockedRuleCount} skipped_plan_only=${payload.build.skippedPlanOnlyRuleCount} skipped_candidates=${payload.build.skippedCandidateRuleCount} patch_records=${payload.build.patchRecordCount} output=${payload.build.outputPath}`);
  }

  lines.push("");
  lines.push("Manifests:");
  for (const manifest of payload.source.manifests) {
    lines.push(`- ${manifest.id}: ${manifest.title} (${manifest.ruleCount} rule(s))`);
    lines.push(`  file=${manifest.file}`);
  }

  lines.push("");
  lines.push("Rules:");
  for (const evaluation of payload.evaluations) {
    lines.push(`- [${evaluation.status}] ${evaluation.manifestId}.${evaluation.ruleId} (${evaluation.operation})`);
    lines.push(`  provenance_status=${evaluation.provenance.status} build_status=${evaluation.buildStatus}`);
    lines.push(`  description=${evaluation.description}`);
    lines.push(`  target=${describeTargetSelection(evaluation.target)}`);
    lines.push(`  matches=${evaluation.resolvedTargets.length}`);
    if (evaluation.operation === "formlist_inject" && evaluation.resolvedFormList) {
      lines.push(`  form_list=${evaluation.resolvedFormList.editorId || evaluation.resolvedFormList.formid}`);
    }
    lines.push(`  payload=${JSON.stringify(evaluation.payload)}`);
    lines.push(`  resolved_payload=${JSON.stringify(serializeResolvedPayload(evaluation.resolvedPayload))}`);
    lines.push(`  provenance=${JSON.stringify(evaluation.provenance)}`);
    if (evaluation.resolvedTargets.length) {
      lines.push(`  resolved=${evaluation.resolvedTargets.map((item) => `${item.pluginName}:${item.edid || item.formid}:${item.type}`).join("; ")}`);
    }
    for (const message of evaluation.messages) {
      lines.push(`  ${message}`);
    }
  }

  if (payload.plan) {
    lines.push("");
    lines.push("Plan summary:");
    for (const [operation, count] of Object.entries(payload.plan.countsByOperation).sort(([a], [b]) => a.localeCompare(b))) {
      lines.push(`- ${operation}=${count}`);
    }
  }
  if (payload.write) {
    lines.push("");
    lines.push(`Write: ${payload.write.dryRun ? payload.write.message : JSON.stringify(payload.write)}`);
  }

  return lines.join("\n");
}

function loadRuleManifests(rulesPathOption) {
  const rulesPath = resolveRulesPath(rulesPathOption);
  const files = collectRuleFiles(rulesPath);
  if (!files.length) {
    throw new Error(`No patch rule manifests found at ${rulesPath}.`);
  }

  return files.map((filePath) => loadRuleManifest(filePath));
}

function resolveRulesPath(rulesPathOption) {
  if (!rulesPathOption) {
    return DEFAULT_RULES_DIR;
  }
  return path.isAbsolute(rulesPathOption)
    ? rulesPathOption
    : path.join(PROJECT_ROOT, rulesPathOption);
}

function collectRuleFiles(rulesPath) {
  if (!exists(rulesPath)) {
    throw new Error(`Patch rule path does not exist: ${rulesPath}`);
  }

  const stats = fs.statSync(rulesPath);
  if (stats.isFile()) {
    return [rulesPath];
  }

  if (!stats.isDirectory()) {
    throw new Error(`Patch rule path is neither a file nor a directory: ${rulesPath}`);
  }

  return fs.readdirSync(rulesPath, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".json"))
    .map((entry) => path.join(rulesPath, entry.name))
    .sort((left, right) => left.localeCompare(right));
}

function loadRuleManifest(filePath) {
  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Failed to parse patch rule manifest ${filePath}: ${error.message}`);
  }

  const manifest = {
    ruleType: parsed.ruleType,
    id: parsed.id,
    title: parsed.title,
    notes: Array.isArray(parsed.notes) ? parsed.notes : [],
    rules: parsed.rules,
    source: path.relative(PROJECT_ROOT, filePath),
  };

  validateManifestShape(manifest, filePath);
  return manifest;
}

function validateManifestShape(manifest, filePath) {
  if (manifest.ruleType !== RULE_SCHEMA) {
    throw new Error(`${filePath} must declare ruleType=${RULE_SCHEMA}.`);
  }
  if (!manifest.id || typeof manifest.id !== "string") {
    throw new Error(`${filePath} must declare a string id.`);
  }
  if (!manifest.title || typeof manifest.title !== "string") {
    throw new Error(`${filePath} must declare a string title.`);
  }
  if (!Array.isArray(manifest.rules) || !manifest.rules.length) {
    throw new Error(`${filePath} must declare a non-empty rules array.`);
  }
}

function evaluateRule(manifest, rule, ruleIndex, context) {
  const ruleId = validateRuleShape(manifest, rule, ruleIndex);
  const messages = [];
  const resolvedTargets = resolveTargetRecords(rule.target, context);
  const provenanceStatus = normalizeProvenanceStatus(rule.provenance.status);

  if (!resolvedTargets.length) {
    messages.push("error=no winning records matched the target selector");
  }

  let resolvedFormList = null;
  if (rule.operation === "formlist_inject") {
    resolvedFormList = resolveRecordReference(rule.payload.formList, context);
    if (!resolvedFormList) {
      messages.push(`error=formList '${rule.payload.formList}' could not be resolved from the winning load order`);
    } else if (resolvedFormList.type !== "FLST") {
      messages.push(`error=formList '${rule.payload.formList}' resolved to ${resolvedFormList.type}, expected FLST`);
    }
  }

  const resolvedPayload = resolvePayloadReferences(rule, context, messages);
  if (provenanceStatus === "blocked") {
    messages.push("error=rule provenance status is blocked");
  }

  const status = messages.length ? "BLOCKED" : "READY";
  if (status === "READY") {
    messages.push(`ok=matched ${resolvedTargets.length} winning record(s)`);
  }
  const buildStatus = determineBuildStatus(rule.provenance.status, status, messages);

  return {
    status,
    buildStatus,
    manifestId: manifest.id,
    manifestTitle: manifest.title,
    ruleId,
    description: rule.description,
    operation: rule.operation,
    target: rule.target,
    payload: rule.payload,
    resolvedPayload,
    provenance: rule.provenance,
    resolvedTargets,
    resolvedFormList,
    messages,
  };
}

function determineBuildStatus(provenanceStatus, status, messages) {
  const normalized = normalizeProvenanceStatus(provenanceStatus);
  if (normalized === "blocked" || status === "BLOCKED") {
    return PLAN_ONLY_PROVENANCE_STATUSES.has(normalized) && !messages.some((message) => message.startsWith("error=no winning records"))
      ? "PLAN_ONLY"
      : "BUILD_BLOCKED";
  }
  if (PLAN_ONLY_PROVENANCE_STATUSES.has(normalized)) {
    return "PLAN_ONLY";
  }
  return "BUILD_READY";
}

function validateRuleShape(manifest, rule, ruleIndex) {
  const ruleLabel = `${manifest.source} rule[${ruleIndex}]`;
  if (!rule || typeof rule !== "object" || Array.isArray(rule)) {
    throw new Error(`${ruleLabel} must be an object.`);
  }
  if (!rule.id || typeof rule.id !== "string") {
    throw new Error(`${ruleLabel} must declare a string id.`);
  }
  if (!rule.description || typeof rule.description !== "string") {
    throw new Error(`${ruleLabel} must declare a string description.`);
  }
  if (!SUPPORTED_OPERATIONS.has(rule.operation)) {
    throw new Error(`${ruleLabel} has unsupported operation '${rule.operation}'.`);
  }
  validateTargetShape(rule.target, ruleLabel);
  validatePayloadShape(rule, ruleLabel);
  validateProvenanceShape(rule.provenance, ruleLabel);
  return rule.id;
}

function validateTargetShape(target, ruleLabel) {
  if (!target || typeof target !== "object" || Array.isArray(target)) {
    throw new Error(`${ruleLabel} must declare a target object.`);
  }

  const activeKeys = [];
  for (const key of ["plugins", "signatures", "editorIds", "editorIdPrefixes", "formIds"]) {
    if (target[key] !== undefined) {
      if (!Array.isArray(target[key]) || !target[key].length || !target[key].every((entry) => typeof entry === "string")) {
        throw new Error(`${ruleLabel}.target.${key} must be a non-empty string array.`);
      }
      activeKeys.push(key);
    }
  }

  if (!activeKeys.length) {
    throw new Error(`${ruleLabel}.target must declare at least one selector array.`);
  }
}

function validatePayloadShape(rule, ruleLabel) {
  const payload = rule.payload;
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    throw new Error(`${ruleLabel} must declare a payload object.`);
  }

  if (rule.operation === "keyword_add") {
    validateStringArray(payload.keywords, `${ruleLabel}.payload.keywords`);
    return;
  }

  if (rule.operation === "formlist_inject") {
    if (!payload.formList || typeof payload.formList !== "string") {
      throw new Error(`${ruleLabel}.payload.formList must be a string record reference.`);
    }
    return;
  }

  if (rule.operation === "actor_distribution") {
    const populatedKeys = DISTRIBUTION_PAYLOAD_KEYS.filter((key) => payload[key] !== undefined);
    if (!populatedKeys.length) {
      throw new Error(`${ruleLabel}.payload must declare at least one of ${DISTRIBUTION_PAYLOAD_KEYS.join(", ")}.`);
    }
    for (const key of populatedKeys) {
      validateStringArray(payload[key], `${ruleLabel}.payload.${key}`);
    }
    return;
  }

  throw new Error(`${ruleLabel} has no payload validator for operation ${rule.operation}.`);
}

function validateStringArray(value, label) {
  if (!Array.isArray(value) || !value.length || !value.every((entry) => typeof entry === "string")) {
    throw new Error(`${label} must be a non-empty string array.`);
  }
}

function validateProvenanceShape(provenance, ruleLabel) {
  if (!provenance || typeof provenance !== "object" || Array.isArray(provenance)) {
    throw new Error(`${ruleLabel} must declare a provenance object.`);
  }
  for (const key of ["status", "source", "comment"]) {
    if (!provenance[key] || typeof provenance[key] !== "string") {
      throw new Error(`${ruleLabel}.provenance.${key} must be a string.`);
    }
  }
  if (!ALLOWED_PROVENANCE_STATUSES.has(normalizeProvenanceStatus(provenance.status))) {
    throw new Error(`${ruleLabel}.provenance.status must be one of ${[...ALLOWED_PROVENANCE_STATUSES].join(", ")}.`);
  }
}

function normalizeProvenanceStatus(status) {
  return String(status || "").trim().toLowerCase();
}

function resolvePayloadReferences(rule, context, messages) {
  if (rule.operation === "keyword_add") {
    return {
      keywords: resolvePayloadRecordArray(rule.payload.keywords, context, messages, `${rule.id}.payload.keywords`, PAYLOAD_EXPECTED_TYPES.keywords),
    };
  }

  if (rule.operation === "formlist_inject") {
    return {
      formList: resolveRecordReference(rule.payload.formList, context),
    };
  }

  if (rule.operation === "actor_distribution") {
    const resolved = {};
    for (const key of DISTRIBUTION_PAYLOAD_KEYS) {
      resolved[key] = rule.payload[key]
        ? resolvePayloadRecordArray(rule.payload[key], context, messages, `${rule.id}.payload.${key}`, PAYLOAD_EXPECTED_TYPES[key] || null)
        : [];
    }
    return resolved;
  }

  return {};
}

function resolvePayloadRecordArray(references, context, messages, label, expectedTypes = null) {
  const resolved = [];
  for (const reference of references || []) {
    const record = resolveRecordReference(reference, context);
    if (!record) {
      messages.push(`error=${label} reference '${reference}' could not be resolved from the winning load order`);
      continue;
    }
    if (expectedTypes && !expectedTypes.includes(String(record.type || "").toUpperCase())) {
      messages.push(`error=${label} reference '${reference}' resolved to ${record.type}, expected ${expectedTypes.join("/")}`);
      continue;
    }
    resolved.push(record);
  }
  return resolved.sort(compareResolvedRecords);
}

function resolveTargetRecords(target, context) {
  const pluginSet = target.plugins ? new Set(target.plugins.map((entry) => entry.toLowerCase())) : null;
  const signatureSet = target.signatures ? new Set(target.signatures.map((entry) => entry.toUpperCase())) : null;
  const editorIdSet = target.editorIds ? new Set(target.editorIds.map((entry) => entry.toLowerCase())) : null;
  const editorPrefixes = target.editorIdPrefixes ? target.editorIdPrefixes.map((entry) => entry.toLowerCase()) : null;
  const formIdSet = target.formIds ? new Set(target.formIds.map((entry) => normalizeFormId(entry).toLowerCase())) : null;

  return context.winningRecords
    .filter((record) => {
      if (pluginSet && !pluginSet.has(record.pluginName.toLowerCase())) {
        return false;
      }
      if (signatureSet && !signatureSet.has(record.type.toUpperCase())) {
        return false;
      }
      if (editorIdSet && !record.edid) {
        return false;
      }
      if (editorIdSet && !editorIdSet.has(record.edid.toLowerCase())) {
        return false;
      }
      if (editorPrefixes && !record.edid) {
        return false;
      }
      if (editorPrefixes && !editorPrefixes.some((prefix) => record.edid.toLowerCase().startsWith(prefix))) {
        return false;
      }
      if (formIdSet && !formIdSet.has(record.formid.toLowerCase())) {
        return false;
      }
      return true;
    })
    .sort(compareResolvedRecords);
}

function resolveRecordReference(reference, context) {
  if (!reference || typeof reference !== "string") {
    return null;
  }
  if (looksLikeFormId(reference)) {
    return context.recordsByFormId.get(normalizeFormId(reference).toLowerCase()) || null;
  }
  return context.recordsByEdid.get(reference.toLowerCase()) || null;
}

function compareResolvedRecords(left, right) {
  if (left.loadOrderIndex !== right.loadOrderIndex) {
    return left.loadOrderIndex - right.loadOrderIndex;
  }
  const leftEdid = left.edid || "";
  const rightEdid = right.edid || "";
  if (leftEdid !== rightEdid) {
    return leftEdid.localeCompare(rightEdid);
  }
  return left.formid.localeCompare(right.formid);
}

function describeTargetSelection(target) {
  const parts = [];
  for (const key of ["plugins", "signatures", "editorIds", "editorIdPrefixes", "formIds"]) {
    if (target[key]) {
      parts.push(`${key}=${target[key].join(",")}`);
    }
  }
  return parts.join(" ");
}

function checkEnvironment() {
  const requiredPaths = {
    "Mutagen bridge": MUTAGEN_BRIDGE,
    "Devotion mod": DEVOTION_MOD,
    "Devotion profile": DEVOTION_PROFILE,
    "loadorder.txt": DEVOTION_LOADORDER,
    "plugins.txt": DEVOTION_PLUGINS,
    "modlist.txt": DEVOTION_MODLIST,
  };

  const failures = Object.entries(requiredPaths)
    .filter(([, filePath]) => !exists(filePath))
    .map(([label, filePath]) => `${label}: ${filePath}`);

  if (failures.length) {
    throw new Error(`Missing required path(s):\n${failures.join("\n")}`);
  }
}

function buildLoadOrderContext() {
  const loadOrderNames = readPluginList(DEVOTION_LOADORDER, false);
  const enabledNames = new Set(readPluginList(DEVOTION_PLUGINS, true));
  const modNames = readEnabledModList(DEVOTION_MODLIST);
  const pluginPathMap = buildPluginPathMap(modNames);

  const listings = [];
  for (const pluginName of loadOrderNames) {
    const pluginPath = pluginPathMap.get(pluginName.toLowerCase());
    if (!pluginPath || !exists(pluginPath)) {
      continue;
    }
    listings.push({
      name: pluginName,
      path: pluginPath,
      enabled: enabledNames.has(pluginName.toLowerCase()) || isImplicitMaster(pluginName),
    });
  }

  return {
    listings,
    pluginPathMap,
  };
}

function buildWinningContext(loadOrder, relevantPlugins = new Set()) {
  const enabledListings = loadOrder.listings.filter((listing) => {
    if (!listing.enabled) {
      return false;
    }
    if (!relevantPlugins.size) {
      return true;
    }
    return relevantPlugins.has(listing.name.toLowerCase());
  });
  if (!enabledListings.length) {
    throw new Error("No enabled plugins matched the current patch-rule selectors.");
  }
  const pluginPaths = enabledListings.map((listing) => listing.path);
  const plugins = scanPlugins(pluginPaths);
  const pluginByPath = new Map();
  for (const plugin of plugins) {
    pluginByPath.set(String(plugin.plugin_path || plugin.path || "").toLowerCase(), plugin);
  }

  const winningByFormId = new Map();
  const winningByEdid = new Map();
  for (let index = 0; index < enabledListings.length; index += 1) {
    const listing = enabledListings[index];
    const plugin = pluginByPath.get(toPosix(listing.path).toLowerCase());
    if (!plugin) {
      throw new Error(`Mutagen scan did not return a payload for ${listing.path}.`);
    }

    for (const record of plugin.records || []) {
      if (!record.formid) {
        continue;
      }
      const enriched = {
        ...record,
        pluginName: path.basename(listing.path),
        pluginPath: listing.path,
        loadOrderIndex: index,
      };
      winningByFormId.set(String(record.formid).toLowerCase(), enriched);
      if (record.edid) {
        winningByEdid.set(String(record.edid).toLowerCase(), enriched);
      }
    }
  }

  return {
    enabledListings,
    recordsByFormId: winningByFormId,
    recordsByEdid: winningByEdid,
    winningRecords: [...winningByFormId.values()],
  };
}

function scanPlugins(pluginPaths) {
  const chunks = chunk(pluginPaths, 24);
  const plugins = [];
  for (const group of chunks) {
    const payload = bridge({
      command: "scan",
      plugins: group.map((pluginPath) => toPosix(pluginPath)),
    }, 120_000);

    if (!Array.isArray(payload.plugins)) {
      throw new Error("Mutagen scan returned no plugin payloads.");
    }

    plugins.push(...payload.plugins);
  }

  return plugins;
}

function collectRelevantPluginNames(manifests) {
  const pluginNames = new Set();

  for (const manifest of manifests) {
    for (const rule of manifest.rules) {
      for (const pluginName of rule.target.plugins || []) {
        pluginNames.add(pluginName.toLowerCase());
      }
      for (const formId of rule.target.formIds || []) {
        pluginNames.add(getPluginNameFromFormId(formId).toLowerCase());
      }
      if (rule.operation === "formlist_inject" && looksLikeFormId(rule.payload.formList)) {
        pluginNames.add(getPluginNameFromFormId(rule.payload.formList).toLowerCase());
      }
      for (const reference of collectPayloadReferences(rule)) {
        if (looksLikeFormId(reference)) {
          pluginNames.add(getPluginNameFromFormId(reference).toLowerCase());
        }
      }
    }
  }

  return pluginNames;
}

function collectPayloadReferences(rule) {
  if (!rule || !rule.payload) {
    return [];
  }
  if (rule.operation === "keyword_add") {
    return rule.payload.keywords || [];
  }
  if (rule.operation === "formlist_inject") {
    return [rule.payload.formList].filter(Boolean);
  }
  if (rule.operation === "actor_distribution") {
    return DISTRIBUTION_PAYLOAD_KEYS.flatMap((key) => rule.payload[key] || []);
  }
  return [];
}

function getPluginNameFromFormId(formId) {
  const normalized = normalizeFormId(formId);
  return normalized.split(":")[0];
}

function chunk(items, size) {
  const groups = [];
  for (let index = 0; index < items.length; index += size) {
    groups.push(items.slice(index, index + size));
  }
  return groups;
}

function bridge(request, timeoutMs = 30_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    maxBuffer: BRIDGE_MAX_BUFFER,
    timeout: timeoutMs,
    windowsHide: true,
  });

  if (result.error) {
    throw result.error;
  }

  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  }

  let payload;
  try {
    payload = JSON.parse(stdout);
  } catch (error) {
    throw new Error(`mutagen-bridge returned invalid JSON: ${stdout.slice(0, 500)}`);
  }

  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }

  return payload;
}

function invokePatchWrite(request) {
  return bridge(request, 120_000);
}

function buildWriterLoadOrderContext(outputPath = null) {
  const loadOrder = buildLoadOrderContext();
  const normalizedOutputPath = outputPath ? path.resolve(outputPath).toLowerCase() : null;
  const ctx = {
    game_release: "SkyrimSE",
    listings: loadOrder.listings
      .filter((listing) => !normalizedOutputPath || path.resolve(listing.path).toLowerCase() !== normalizedOutputPath)
      .map((listing) => ({
        mod_key: listing.name,
        path: toPosix(listing.path),
        enabled: listing.enabled,
      })),
  };

  if (exists(STOCK_GAME_DATA)) {
    ctx.data_folder = toPosix(STOCK_GAME_DATA);
  }

  const cccPath = path.join(STOCK_GAME, "Skyrim.ccc");
  if (exists(cccPath)) {
    ctx.ccc_path = toPosix(cccPath);
  }

  return ctx;
}

function buildSafeOutputPath(output) {
  const raw = output || DEFAULT_OUTPUT;
  const resolved = path.isAbsolute(raw)
    ? path.resolve(raw)
    : path.resolve(DEVOTION_MOD, raw);
  const devotionRoot = path.resolve(DEVOTION_MOD);
  const relative = path.relative(devotionRoot, resolved);

  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new Error(`Generated patch output must stay inside the Devotion mod folder: ${resolved}`);
  }
  if (path.resolve(resolved).toLowerCase() === path.resolve(path.join(DEVOTION_MOD, "PlayerDevotion_Framework.esp")).toLowerCase()) {
    throw new Error("Generated patch output must not overwrite PlayerDevotion_Framework.esp.");
  }
  if (!/\.esp$/i.test(resolved)) {
    throw new Error("Generated patch output must be an .esp file.");
  }

  return resolved;
}

function snapshotSourcePlugins(sourcePluginPaths) {
  return new Map(sourcePluginPaths.map((filePath) => [filePath, exists(filePath) ? fs.statSync(filePath).mtimeMs : null]));
}

function compareSourceSnapshots(before) {
  const results = [];
  for (const [filePath, beforeMtime] of before.entries()) {
    const afterMtime = exists(filePath) ? fs.statSync(filePath).mtimeMs : null;
    results.push({
      path: toWindows(filePath),
      unchanged: beforeMtime === afterMtime,
      beforeMtime,
      afterMtime,
    });
  }
  return results;
}

function writeJsonArtifact(targetPath, payload) {
  const resolved = path.isAbsolute(targetPath)
    ? targetPath
    : path.join(PROJECT_ROOT, targetPath);
  fs.writeFileSync(resolved, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
}

function writeTextArtifact(targetPath, text) {
  const resolved = path.isAbsolute(targetPath)
    ? targetPath
    : path.join(PROJECT_ROOT, targetPath);
  fs.writeFileSync(resolved, `${text}\n`, "utf8");
}

function serializeResolvedPayload(resolvedPayload = {}) {
  const serialized = {};
  for (const [key, value] of Object.entries(resolvedPayload)) {
    if (Array.isArray(value)) {
      serialized[key] = value.map((record) => ({
        plugin: record.pluginName,
        formid: record.formid,
        editorId: record.edid,
        signature: record.type,
      }));
    } else if (value && typeof value === "object") {
      serialized[key] = {
        plugin: value.pluginName,
        formid: value.formid,
        editorId: value.edid,
        signature: value.type,
      };
    } else {
      serialized[key] = value;
    }
  }
  return serialized;
}

function uniqueStrings(values) {
  return [...new Set(values.filter(Boolean))].sort((left, right) => left.localeCompare(right));
}

function readPluginList(filePath, starredOnly) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"))
    .filter((line) => !starredOnly || line.startsWith("*"))
    .map((line) => (starredOnly ? line.slice(1).trim() : line))
    .map((line) => line.toLowerCase());
}

function readEnabledModList(filePath) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("+"))
    .map((line) => line.slice(1).trim())
    .filter((name) => name && !name.endsWith("_separator"));
}

function buildPluginPathMap(modNames) {
  const map = new Map();

  for (const entry of listPluginFiles(STOCK_GAME_DATA)) {
    map.set(entry.name.toLowerCase(), entry.fullPath);
  }

  for (const modName of modNames) {
    const modRoot = path.join(ANVIL_ROOT, "mods", modName);
    for (const entry of listPluginFiles(modRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
    const dataRoot = path.join(modRoot, "Data");
    for (const entry of listPluginFiles(dataRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
  }

  return map;
}

function listPluginFiles(dirPath) {
  if (!exists(dirPath) || !fs.statSync(dirPath).isDirectory()) {
    return [];
  }

  return fs.readdirSync(dirPath, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .filter((entry) => [".esp", ".esm", ".esl"].includes(path.extname(entry.name).toLowerCase()))
    .map((entry) => ({
      name: entry.name,
      fullPath: path.join(dirPath, entry.name),
    }));
}

function isImplicitMaster(pluginName) {
  return ["skyrim.esm", "update.esm", "dawnguard.esm", "hearthfires.esm", "dragonborn.esm"].includes(pluginName.toLowerCase());
}

function looksLikeFormId(value) {
  return /^[^:]+\.(esm|esp|esl):[0-9a-f]{6}$/i.test(String(value || "").trim());
}

function normalizeFormId(value) {
  const text = String(value).trim();
  if (!looksLikeFormId(text)) {
    throw new Error(`Invalid FormID format: ${value}`);
  }
  const [pluginName, localId] = text.split(":");
  return `${pluginName}:${localId.toUpperCase()}`;
}

function toPosix(filePath) {
  return String(filePath).replace(/\\/g, "/");
}

function toWindows(filePath) {
  return String(filePath).replace(/\//g, "\\");
}

function exists(filePath) {
  return fs.existsSync(filePath);
}
