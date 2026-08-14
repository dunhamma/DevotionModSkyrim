#!/usr/bin/env node
/*
 * Read-only static architecture gate for the V3 Quest Reaction runtime.
 *
 * This proves source ownership, bounds, call direction, and key namespace.
 * It does not prove Papyrus scheduling, co-save serialization, VMAD wiring,
 * save/load delivery, or player-facing presentation.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, {
  toolName: "pdv_quest_reaction_performance_audit",
});

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_ROOT = path.join(ROOT, "live-source", "Scripts", "Source");
const paths = {
  runtime: path.join(SOURCE_ROOT, "PDV_QuestReactionRuntime.psc"),
  manager: path.join(SOURCE_ROOT, "PDV__ManagerQuest.psc"),
  eventBus: path.join(SOURCE_ROOT, "PDV_EventBus.psc"),
  playerEvents: path.join(SOURCE_ROOT, "PDV_PlayerEvents.psc"),
  mcm: path.join(SOURCE_ROOT, "PDV_MCM.psc"),
  worker: path.join(SOURCE_ROOT, "PDV_QuestReactionWorker.psc"),
  contract: path.join(ROOT, "references", "authoring", "PDV_V3Slice1QuestReaction.manifest.json"),
  release: path.join(ROOT, "references", "authoring", "PDV_ReleasePayload.manifest.json"),
  fanout: path.join(ROOT, "tools", "pdv_qr_direct_fanout.json"),
};

const requiredCases = [
  "single-runnable-cell",
  "multi-tick-base-plus-meta-fifo",
  "mixed-polarity-one-final-surface",
  "zero-runnable-compacted-job",
  "queued-and-recent-duplicate-coalescing",
  "queue-ceiling-overflow",
  "save-load-mid-job-resume",
  "corrupt-snapshot-reject-and-cleanup",
];

function bodyFor(source, name, kind = "Function") {
  const start = source.search(new RegExp(`\\b${kind}\\s+${name}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const endToken = kind === "Event" ? "EndEvent" : "EndFunction";
  const end = tail.search(new RegExp(`\\n\\s*${endToken}\\b`, "i"));
  return end < 0 ? tail : tail.slice(0, end + endToken.length + 1);
}

function count(source, pattern) {
  return (source.match(pattern) ?? []).length;
}

function finding(findings, ok, id, detail) {
  findings.push({ status: ok ? "PASS" : "FAIL", id, detail });
}

function escapeRe(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function countCalls(body, functionName) {
  return (body.match(new RegExp(`\\b${escapeRe(functionName)}\\s*\\(`, "gi")) ?? []).length;
}

function parseFunctions(source) {
  const bodies = new Map();
  let current = null;
  let lines = [];
  for (const line of source.split(/\r?\n/)) {
    const start = line.match(/^\s*(?:[A-Za-z_[\]]+\s+)?(?:Function|Event)\s+([A-Za-z_0-9]+)\s*\(/i);
    if (start && current === null) { current = start[1]; lines = []; continue; }
    if (current !== null && /^\s*End(?:Function|Event)\b/i.test(line)) {
      bodies.set(current, lines.join("\n")); current = null; continue;
    }
    if (current !== null) lines.push(line);
  }
  return bodies;
}

function evaluateDirectFanout(manager, ledger) {
  const findings = [];
  const bodies = parseFunctions(manager);
  const budget = Number(ledger?.budget ?? 2);
  const registry = ledger?.fanouts ?? {};
  const wrappers = [];
  for (const [name, body] of bodies) {
    if (name === "ApplyDeityReaction" || countCalls(body, "ApplyDeityReaction") !== 1) continue;
    const statements = body.split(/\r?\n/).map((line) => line.trim()).filter((line) => line && !line.startsWith(";"));
    if (statements.length <= 4) wrappers.push(name);
  }
  const fanouts = [];
  for (const [name, body] of bodies) {
    if (name === "ApplyDeityReaction" || wrappers.includes(name)) continue;
    let applications = countCalls(body, "ApplyDeityReaction");
    for (const wrapper of wrappers) applications += countCalls(body, wrapper);
    if (applications > budget) fanouts.push({ name, applications });
  }
  const unregistered = fanouts.filter((entry) => !registry[entry.name]);
  const overBudget = fanouts.filter((entry) => registry[entry.name] && entry.applications > Number(registry[entry.name].maxApplications));
  const live = new Set(fanouts.map((entry) => entry.name));
  const stale = Object.keys(registry).filter((name) => !live.has(name));
  finding(findings, unregistered.length === 0, "fanout.registered",
    unregistered.length ? `Unregistered synchronous fan-out: ${unregistered.map((entry) => `${entry.name} (${entry.applications})`).join(", ")}.` : `Every synchronous fan-out above ${budget} calls is registered.`);
  finding(findings, overBudget.length === 0, "fanout.within-recorded-budget",
    overBudget.length ? `Fan-out exceeded its recorded maximum: ${overBudget.map((entry) => `${entry.name} ${entry.applications}`).join(", ")}.` : "Registered fan-outs stay within their recorded maxima.");
  finding(findings, stale.length === 0, "fanout.no-stale-registry",
    stale.length ? `Stale fan-out registry entries: ${stale.join(", ")}.` : "Every fan-out registry entry is live.");
  return findings;
}

function evaluate({ runtime, manager, eventBus, playerEvents, mcm, workerExists, contract, release, fanout }) {
  const findings = [];
  const sources = [runtime, manager, eventBus, playerEvents, mcm].join("\n");
  const processBody = bodyFor(runtime, "ProcessQuestReactionQueueSlice");
  const onUpdate = bodyFor(runtime, "OnUpdate", "Event");
  const submitQuest = bodyFor(runtime, "SubmitQuestStage");
  const refreshCatalog = bodyFor(runtime, "RefreshCatalogSources");
  const activateCatalog = bodyFor(runtime, "ActivateCatalogSources");
  const resolvePrefix = bodyFor(runtime, "ResolveQuestReactionCellPrefix");
  const eventBusQuest = bodyFor(eventBus, "RouteQuestReaction");
  const managerCallbacks = [
    "ShouldQueueQuestReactionCell",
    "PrepareQueuedQuestReactionTransaction",
    "BeginQueuedQuestReactionSlice",
    "ApplyQueuedQuestReactionCell",
    "EndQueuedQuestReactionSlice",
    "FinalizeQueuedQuestReaction",
  ];
  const retiredManager = [
    "ResolveQuestReactionCellFile",
    "QueueQuestReactionJob",
    "HasQueuedQuestReactionJobs",
    "GetQuestReactionQueueStatus",
    "ProcessQuestReactionQueueSlice",
    "RemoveQueuedQuestReactionJob",
    "ShouldSuppressDuplicateQuestReaction",
    "EnsureQuestReactionQueueRunning",
  ];
  const publicInterface = contract?.module?.interface?.map((entry) => entry.name) ?? [];

  finding(findings, /^Scriptname\s+PDV_QuestReactionRuntime\s+extends\s+Quest\b/im.test(runtime),
    "runtime.identity", "The existing quest host is implemented by PDV_QuestReactionRuntime.");
  finding(findings, /INTERFACE_VERSION\s*=\s*1\b/i.test(runtime) &&
    ["Configure", "SubmitQuestStage", "SubmitSemanticEvent", "GetStatusLine", "GetCompatibilityDetail"]
      .every((name) => bodyFor(runtime, name)),
    "runtime.interface", "The version-1 public lifecycle interface is present.");
  finding(findings, JSON.stringify(publicInterface) === JSON.stringify([
    "Configure", "SubmitQuestStage", "SubmitSemanticEvent", "GetStatusLine", "GetCompatibilityDetail",
  ]), "contract.interface", "The manifest pins the five-member version-1 interface.");

  finding(findings, /QUEST_REACTION_QUEUE_MAX_PENDING\s*=\s*128\b/i.test(runtime) &&
    /QUEST_REACTION_QUEUE_CELLS_PER_TICK\s*=\s*2\b/i.test(runtime) &&
    /QUEST_REACTION_QUEUE_TICK_SECONDS\s*=\s*0\.1\b/i.test(runtime) &&
    /QUEST_REACTION_DUPLICATE_WINDOW_DAYS\s*=\s*0\.02\b/i.test(runtime),
    "runtime.bounds", "Queue ceiling, slice budget, tick, and duplicate window retain parity values.");
  finding(findings, count(runtime, /RegisterForSingleUpdate\s*\(/gi) === 2 &&
    !workerExists && !bodyFor(manager, "ProcessQuestReactionQueueSlice"),
    "runtime.single-scheduler", "Only the runtime owns initial and continuation re-arms; the old worker is absent.");
  finding(findings, onUpdate.includes("ProcessQuestReactionQueueSlice()") &&
    !/\b(?:Utility\.)?Wait(?:MenuMode)?\s*\(/i.test(runtime),
    "runtime.nonblocking", "OnUpdate drains one bounded slice and the runtime contains no waits.");
  finding(findings, processBody.includes("processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK") &&
    processBody.includes("CellIndex") && processBody.includes("FinalizeQueuedQuestReaction") &&
    processBody.includes("RemoveHeadJob"),
    "runtime.bounded-finalization", "The persisted head advances under the two-item budget and finalizes once before removal.");
  finding(findings, submitQuest.includes("QueueQuestReactionJob") &&
    runtime.includes("StorageUtil.StringListAdd(None, QUEUE_IDS_KEY") &&
    runtime.includes("StorageUtil.FormListAdd(None, QUEUE_FORMS_KEY"),
    "runtime.persist-before-return", "Accepted quest stages persist parallel FIFO identity and source form state.");
  finding(findings, ["PDV.V3.QR.Queue.", "PDV.V3.QR.Job.", "PDV.V3.QR.Recent.", "PDV.V3.QR.ChannelFiles"]
    .every((token) => runtime.includes(token)) && !/["']PDV\.QR\./.test(sources),
    "runtime.v3-namespace", "Owned queue, job, recent, and channel state use only PDV.V3.QR keys.");
  finding(findings, refreshCatalog.includes("JsonUtil.JsonInFolder(QUEST_REACTION_CHANNEL_FOLDER)") &&
    refreshCatalog.includes("JsonUtil.JsonInFolder(QUEST_REACTION_STAGE_ADAPTER_FOLDER)") &&
    activateCatalog.includes("ActivateCatalogSource") &&
    runtime.includes("PO3_Events_Alias.RegisterForQuestStage(_questStageReceiver, sourceQuest)") &&
    !playerEvents.includes("JsonUtil.JsonInFolder") &&
    !playerEvents.includes("JsonUtil.Load(") &&
    !playerEvents.includes("JsonUtil.Unload(") &&
    !playerEvents.includes("RegisterQuestReactionMatrixFile") &&
    !playerEvents.includes('"PDV.V3.QR.SourceCatalog."'),
    "runtime.catalog-owner", "Runtime owns catalog discovery, parsing, source activation, and Quest-stage registration.");
  finding(findings, runtime.includes('"PDV.V3.QR.SourceCatalog."') &&
    resolvePrefix.includes('"quest." + sourcePlugin + "|" + localFormId + "|" + stageValue + "."') &&
    runtime.includes('"PDV.V3.QR.SourceCatalog."'),
    "runtime.qualified-routing", "Ingress binds each runtime quest to one catalog and prefers the plugin-qualified v2 cell key.");

  finding(findings, managerCallbacks.every((name) => bodyFor(manager, name)),
    "manager.callback-seam", "Manager exposes only the scoring/final-presentation callback seam needed by the runtime.");
  finding(findings, retiredManager.every((name) => !bodyFor(manager, name)) &&
    !manager.includes("PDV.V3.QR.") && !manager.includes("PDV_QuestReactionWorker"),
    "manager.ownership-retired", "Manager no longer owns catalog, queue, V3 storage, scheduler, or the old worker.");
  finding(findings, eventBusQuest.includes("PDV_QuestReactionRuntimeService.SubmitQuestStage") &&
    !eventBusQuest.includes("PDV_Manager.ApplyQuestReaction"),
    "eventbus.direct-ingress", "EventBus submits quest stages directly to the runtime.");
  finding(findings, runtime.includes('"PDV.V3.QR.SourceLocalFormId."') &&
    runtime.includes('"PDV.V3.QR.SourcePlugin."') &&
    runtime.includes('"PDV.V3.QR.ChannelFiles"') &&
    runtime.includes('"PDV.V3.QR.SourceCatalog."') &&
    !playerEvents.includes('"PDV.QuestReaction.LocalFormId."'),
    "player-events.identity", "Runtime materializes plugin-qualified identity; PlayerEvents remains an engine adapter.");
  finding(findings, mcm.includes("PDV_QuestReactionRuntimeService.GetStatusLine()") &&
    mcm.includes("PDV_QuestReactionRuntimeService.DebugReloadCatalog()") &&
    mcm.includes("PDV_QuestReactionRuntimeService.DebugQueuePerformanceSweep()") &&
    !mcm.includes("PDV_Manager.GetQuestReactionQueueStatus()"),
    "mcm.readonly-runtime", "MCM status and controlled probes target the owning runtime.");

  finding(findings, !workerExists && release?.sourceScripts?.includes("PDV_QuestReactionRuntime") &&
    !release?.sourceScripts?.includes("PDV_QuestReactionWorker") &&
    release?.fixedEntries?.includes("Scripts/PDV_QuestReactionRuntime.pex"),
    "release.runtime-inventory", "Release inventory compiles and ships Runtime, not Worker.");
  finding(findings, JSON.stringify(contract?.currentBehaviorCharacterization?.cases ?? []) ===
    JSON.stringify(requiredCases),
    "characterization.case-contract", "The manifest retains the exact eight executable characterization cases.");
  findings.push(...evaluateDirectFanout(manager, fanout));

  return {
    status: findings.every((entry) => entry.status === "PASS") ? "PASS" : "FAIL",
    findings,
    proofBoundary: "static source architecture only; compile, VMAD, StorageUtil, save/load, and player surfaces are separate proof",
  };
}

function loadLiveInputs() {
  return {
    runtime: fs.readFileSync(paths.runtime, "utf8"),
    manager: fs.readFileSync(paths.manager, "utf8"),
    eventBus: fs.readFileSync(paths.eventBus, "utf8"),
    playerEvents: fs.readFileSync(paths.playerEvents, "utf8"),
    mcm: fs.readFileSync(paths.mcm, "utf8"),
    workerExists: fs.existsSync(paths.worker),
    contract: JSON.parse(fs.readFileSync(paths.contract, "utf8")),
    release: JSON.parse(fs.readFileSync(paths.release, "utf8")),
    fanout: JSON.parse(fs.readFileSync(paths.fanout, "utf8")),
  };
}

function selfTest() {
  const base = loadLiveInputs();
  const mutations = [
    ["legacy manager queue owner", { manager: base.manager + "\nFunction QueueQuestReactionJob()\nEndFunction\n" }, "manager.ownership-retired"],
    ["legacy V1 key", { runtime: base.runtime + '\nString legacy = "PDV.QR.Queue.JobIds"\n' }, "runtime.v3-namespace"],
    ["second scheduler", { manager: base.manager + "\nFunction ProcessQuestReactionQueueSlice()\n  RegisterForSingleUpdate(0.1)\nEndFunction\n" }, "runtime.single-scheduler"],
    ["missing interface member", { runtime: base.runtime.replace("String Function GetCompatibilityDetail()", "String Function MissingCompatibilityDetail()") }, "runtime.interface"],
    ["EventBus manager ingress", { eventBus: base.eventBus.replace("PDV_QuestReactionRuntimeService.SubmitQuestStage", "PDV_Manager.ApplyQuestReaction") }, "eventbus.direct-ingress"],
    ["Manager V3 storage", { manager: base.manager + '\nString bad = "PDV.V3.QR.Queue.JobIds"\n' }, "manager.ownership-retired"],
    ["PlayerEvents catalog discovery", { playerEvents: base.playerEvents + "\nString[] bad = JsonUtil.JsonInFolder(\"Channels\")\n" }, "runtime.catalog-owner"],
    ["unqualified route", { runtime: base.runtime.replace('String qualifiedPrefix = "quest." + sourcePlugin + "|" + localFormId + "|" + stageValue + "."', 'String qualifiedPrefix = "quest." + localFormId + "|" + stageValue + "."') }, "runtime.qualified-routing"],
    ["unregistered direct fan-out", { manager: base.manager + "\nFunction RogueFanout()\n ApplyDeityReaction(\"A\")\n ApplyDeityReaction(\"B\")\n ApplyDeityReaction(\"C\")\nEndFunction\n" }, "fanout.registered"],
  ];
  const results = mutations.map(([name, patch, expectedId]) => {
    const report = evaluate({ ...base, ...patch });
    return {
      name,
      status: report.findings.find((entry) => entry.id === expectedId)?.status === "FAIL" ? "PASS" : "FAIL",
    };
  });
  return {
    status: results.every((entry) => entry.status === "PASS") ? "PASS" : "FAIL",
    results,
  };
}

const json = process.argv.includes("--json");
if (process.argv.includes("--self-test")) {
  const report = selfTest();
  if (json) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`PDV Quest Reaction architecture audit self-test: ${report.status}`);
    for (const entry of report.results) console.log(`[${entry.status}] ${entry.name}`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
} else {
  const report = evaluate(loadLiveInputs());
  if (json) console.log(JSON.stringify(report, null, 2));
  else {
    for (const entry of report.findings) console.log(`[${entry.status}] ${entry.id}: ${entry.detail}`);
    console.log(`Summary: ${report.status}`);
    console.log(`Proof boundary: ${report.proofBoundary}`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}
