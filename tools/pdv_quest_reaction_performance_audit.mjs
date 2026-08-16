#!/usr/bin/env node
/*
 * Read-only static architecture gate for the V3 Quest Reaction runtime.
 *
 * This proves source ownership, bounds, call direction, key namespace, and
 * the final Quest Reaction player-source boundary shared by toast and Book.
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
  const configure = bodyFor(runtime, "Configure");
  const ensureRunning = bodyFor(runtime, "EnsureQuestReactionQueueRunning");
  const submitQuest = bodyFor(runtime, "SubmitQuestStage");
  const submitSemantic = bodyFor(runtime, "SubmitSemanticEvent");
  const queueResolved = bodyFor(runtime, "QueueResolvedReactionJob");
  const processBuildUnit = bodyFor(runtime, "ProcessQuestReactionBuildUnit");
  const appendBuiltCell = bodyFor(runtime, "AppendBuiltQuestReactionCell");
  const refreshCatalog = bodyFor(runtime, "RefreshCatalogSources");
  const loadCatalog = bodyFor(runtime, "LoadAndActivateCatalog");
  const activateCatalog = bodyFor(runtime, "ActivateCatalogSources");
  const validateSource = bodyFor(runtime, "ValidateCatalogSource");
  const canActivateSource = bodyFor(runtime, "CanActivateCatalogSource");
  const indexCatalogSource = bodyFor(runtime, "IndexCatalogSource");
  const eventBusQuest = bodyFor(eventBus, "RouteQuestReaction");
  const questStageIngress = bodyFor(playerEvents, "OnQuestStageChange", "Event");
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
  finding(findings, count(runtime, /RegisterForSingleUpdate\s*\(/gi) === 1 &&
    !workerExists && !bodyFor(manager, "ProcessQuestReactionQueueSlice"),
    "runtime.single-scheduler", "Only the runtime owns initial and continuation re-arms; the old worker is absent.");
  const onUpdateClear = onUpdate.indexOf("StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 0)");
  const onUpdateProcess = onUpdate.indexOf("ProcessQuestReactionQueueSlice()");
  finding(findings,
    ensureRunning.includes("StorageUtil.GetIntValue(None, QUEUE_UPDATE_ARMED_KEY) != 1") &&
    ensureRunning.indexOf("StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 1)") < ensureRunning.indexOf("RegisterForSingleUpdate(") &&
    onUpdateClear >= 0 && onUpdateClear < onUpdateProcess &&
    onUpdate.includes("if _sliceActive") && onUpdate.includes("EnsureQuestReactionQueueRunning()") &&
    configure.includes("savedSliceOwnsResume = fromLoad && _sliceActive") &&
    configure.includes("UnregisterForUpdate()") &&
    configure.includes("StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 0)") &&
    configure.includes("if !savedSliceOwnsResume"),
    "runtime.single-armed-update-chain", "One armed update chain owns the queue, while a saved active slice retains resume ownership.");
  finding(findings, onUpdate.includes("ProcessQuestReactionQueueSlice()") &&
    !/\b(?:Utility\.)?Wait(?:MenuMode)?\s*\(/i.test(runtime),
    "runtime.nonblocking", "OnUpdate drains one bounded slice and the runtime contains no waits.");
  const ingressBegin = questStageIngress.indexOf("BeginLogicalDevotionalAct(logicalEventId)");
  const ingressCurated = questStageIngress.indexOf("RouteCuratedMilestoneQuestStage(akQuest, aiNewStage)");
  const ingressFlush = questStageIngress.indexOf("FlushLogicalDevotionalAct()");
  const ingressQuestReaction = questStageIngress.lastIndexOf("RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)");
  finding(findings, ingressBegin >= 0 && ingressBegin < ingressCurated && ingressCurated < ingressFlush &&
    ingressFlush < ingressQuestReaction && count(questStageIngress, /RouteQuestReactionStage\s*\(/g) === 1,
    "playerevents.scope-closes-before-qr", "Ordinary quest/P2/curated routing flushes its logical broad scope before Quest Reaction admission begins.");
  finding(findings,
    queueResolved.includes('StorageUtil.SetStringValue(None, prefix + "MatrixFile", matrixFile)') &&
    queueResolved.includes('StorageUtil.SetStringValue(None, prefix + "CellPrefix", cellPrefix)') &&
    queueResolved.includes('StorageUtil.SetIntValue(None, prefix + "BuildComplete", 0)') &&
    queueResolved.includes('StorageUtil.SetIntValue(None, prefix + "BuildIndex", 0)') &&
    queueResolved.includes("admissionMs=") &&
    !queueResolved.includes("PDV_Manager.ShouldQueueQuestReactionCell") &&
    !queueResolved.includes("StringUtil.Split") &&
    !/\bwhile\b/i.test(queueResolved),
    "runtime.lightweight-admission", "Ingress persists only a resumable job header and returns without scanning or filtering catalog cells.");
  finding(findings,
    processBody.includes("processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK") &&
    processBody.includes('StorageUtil.GetIntValue(None, prefix + "BuildComplete") != 1') &&
    processBody.includes("ProcessQuestReactionBuildUnit(jobId, prefix)") &&
    processBuildUnit.includes('StorageUtil.GetIntValue(None, prefix + "BuildIndex")') &&
    processBuildUnit.includes("JsonUtil.StringListGet") &&
    processBuildUnit.includes("AppendBuiltQuestReactionCell") &&
    processBuildUnit.indexOf('StorageUtil.SetIntValue(None, prefix + "BuildIndex", buildIndex)') > processBuildUnit.indexOf("buildIndex += 1") &&
    !/\bwhile\b/i.test(processBuildUnit) &&
    appendBuiltCell.includes('StorageUtil.SetIntValue(None, prefix + "CellCount", cellCount + 1)'),
    "runtime.bounded-materialization", "The existing two-item scheduler incrementally materializes and checkpoints catalog cells before apply/finalize work.");
  finding(findings, processBody.includes("processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK") &&
    processBody.includes("CellIndex") && processBody.includes("FinalizeQueuedQuestReaction") &&
    processBody.includes("RemoveHeadJob"),
    "runtime.bounded-finalization", "The persisted head advances under the two-item budget and finalizes once before removal.");
  const applyCell = processBody.indexOf("PDV_Manager.ApplyQueuedQuestReactionCell(");
  const advanceCell = processBody.indexOf("cellIndex += 1", applyCell);
  const checkpointCell = processBody.indexOf('StorageUtil.SetIntValue(None, prefix + "CellIndex", cellIndex)', advanceCell);
  const advanceBudget = processBody.indexOf("processed += 1", checkpointCell);
  const loopEnd = processBody.indexOf("endWhile", advanceBudget);
  finding(findings, applyCell >= 0 && applyCell < advanceCell && advanceCell < checkpointCell && checkpointCell < advanceBudget && advanceBudget < loopEnd &&
    count(processBody, /StorageUtil\.SetIntValue\(None, prefix \+ "CellIndex", cellIndex\)/g) === 1 &&
    processBody.indexOf("if cellIndex < cellCount", loopEnd) > loopEnd,
    "runtime.cell-progress-checkpoint", "Every applied cell advances the persisted cursor before the bounded slice continues or finalizes.");
  finding(findings, submitQuest.includes("QueueQuestReactionJob") &&
    runtime.includes("StorageUtil.StringListAdd(None, QUEUE_IDS_KEY") &&
    runtime.includes("StorageUtil.FormListAdd(None, QUEUE_FORMS_KEY"),
    "runtime.persist-before-return", "Accepted quest stages persist parallel FIFO identity and source form state.");
  finding(findings, ["PDV.V3.QR.Queue.", "PDV.V3.QR.Job.", "PDV.V3.QR.Recent.", "PDV.V3.QR.Index."]
    .every((token) => runtime.includes(token)) && !/["']PDV\.QR\./.test(sources),
    "runtime.v3-namespace", "Owned queue, job, recent, and index state use only PDV.V3.QR keys.");
  finding(findings, refreshCatalog.includes("LoadAndActivateCatalog(QUEST_REACTION_CORE_FILE)") &&
    refreshCatalog.includes("LoadAndActivateCatalog(QUEST_REACTION_PATCH_FILE)") &&
    refreshCatalog.includes("SortCatalogNames(JsonUtil.JsonInFolder(QUEST_REACTION_EXTENSION_FOLDER))") &&
    runtime.includes('"pdv.quest-reaction.catalog.v2"') &&
    runtime.includes("schemaVersion") &&
    activateCatalog.includes("ValidateCatalogSource") &&
    activateCatalog.includes("CanActivateCatalogSource") &&
    runtime.includes("PO3_Events_Alias.RegisterForQuestStage(_questStageReceiver, sourceQuest)") &&
    !playerEvents.includes("JsonUtil.JsonInFolder") &&
    !playerEvents.includes("JsonUtil.Load(") &&
    !playerEvents.includes("JsonUtil.Unload(") &&
    !playerEvents.includes("RegisterQuestReactionMatrixFile") &&
    !playerEvents.includes('"PDV.V3.QR.CellCatalog."'),
    "runtime.catalog-owner", "Runtime alone loads core, official, then sorted extensions; validates and activates each source independently; and owns Quest-stage registration.");
  finding(findings, indexCatalogSource.includes('"PDV.V3.QR.CellCatalog." + questKey') &&
    indexCatalogSource.includes('"PDV.V3.QR.SemanticCatalog." + semanticKey') &&
    indexCatalogSource.includes("if StorageUtil.GetStringValue(None, \"PDV.V3.QR.CellCatalog.\" + questKey) == \"\"") &&
    indexCatalogSource.includes("if StorageUtil.GetStringValue(None, \"PDV.V3.QR.SemanticCatalog.\" + semanticKey) == \"\"") &&
    submitQuest.includes("QueueQuestReactionJob(sourceQuest, ResolveQuestStage(sourceQuest, stageValue), logicalEventId)") &&
    runtime.includes('"quest." + reactionKey + "."') &&
    !runtime.includes('"quest." + localFormId + "|" + stageValue + "."'),
    "runtime.qualified-indexes", "Quest and semantic indexes are exact, precedence-preserving, and quest enqueue resolves only plugin-qualified keys.");
  finding(findings, submitSemantic.includes("String semanticKey = sourceId + \"|\" + eventId") &&
    submitSemantic.includes('"PDV.V3.QR.SemanticCatalog." + semanticKey') &&
    submitSemantic.includes('"semantic." + semanticKey + "."') &&
    submitSemantic.includes("QueueResolvedReactionJob"),
    "runtime.semantic-ingress", "SubmitSemanticEvent resolves a qualified semantic event through the runtime-owned index and enqueues its catalog payload.");
  finding(findings, activateCatalog.includes("if !ValidateCatalogSource(catalogFile, sourceId)") &&
    activateCatalog.includes("_rejectedSourceCount += 1") &&
    activateCatalog.includes("elseIf !CanActivateCatalogSource(catalogFile, sourceId)") &&
    activateCatalog.includes("_inactiveSourceCount += 1") &&
    bodyFor(runtime, "CanActivateCatalogSource").includes("DISABLED_SOURCES_KEY") &&
    !/\b(?:Return|return)\b/.test(activateCatalog.slice(activateCatalog.indexOf("if !ValidateCatalogSource"), activateCatalog.indexOf("elseIf !CanActivateCatalogSource"))),
    "runtime.source-isolation", "A malformed, disabled, absent, or unresolved source is rejected or inactive without aborting other catalog sources.");
  finding(findings, refreshCatalog.includes('"CATALOG loaded catalogs="') &&
    refreshCatalog.includes('"CATALOG loaded questKeys="') &&
    loadCatalog.includes('"CATALOG_REJECT file=" + catalogFile + " reason=missing"') &&
    loadCatalog.includes('"CATALOG_REJECT file=" + catalogFile + " reason=parse_or_load"') &&
    loadCatalog.includes('"CATALOG_REJECT file=" + catalogFile + " reason=schema"') &&
    activateCatalog.includes('"CATALOG_REJECT file=" + catalogFile + " source=" + sourceId + " reason=invalid_source"'),
    "runtime.catalog-diagnostics", "Configuration and reload paths expose aggregate admission plus source-local rejection reasons.");
  finding(findings, validateSource.includes("Int sentinelCount = JsonUtil.StringListCount") &&
    validateSource.includes("Int questCount = JsonUtil.StringListCount") &&
    validateSource.includes("Int semanticCount = JsonUtil.StringListCount") &&
    validateSource.includes("Int stageAdapterCount = JsonUtil.StringListCount") &&
    canActivateSource.includes("Int sentinelCount = JsonUtil.StringListCount") &&
    canActivateSource.includes("Int questCount = JsonUtil.StringListCount") &&
    canActivateSource.includes("Int stageAdapterCount = JsonUtil.StringListCount") &&
    indexCatalogSource.includes("Int questCount = JsonUtil.StringListCount") &&
    indexCatalogSource.includes("Int semanticCount = JsonUtil.StringListCount") &&
    indexCatalogSource.includes("Int stageAdapterCount = JsonUtil.StringListCount") &&
    processBody.includes('String reactionKey = StorageUtil.GetStringValue(None, prefix + "ReactionKey")') &&
    processBody.includes("PDV_Manager.FinalizeQueuedQuestReaction(sourceModName, reactionKey)"),
    "runtime.qr-local-caching", "Catalog loops cache list counts and completion reuses terminal job fields without changing queue bounds.");
  finding(findings, !/QUEST_REACTION_CHANNEL|QUEST_REACTION_STAGE_ADAPTER|ChannelFiles|SourceCatalog|ResolveQuestReactionCell(?:File|Prefix)|questWatchFormIdsCsv/.test(runtime),
    "runtime.v1-discovery-retired", "No V1 channels, stage-adapter files, source catalog, or local-key fallback discovery remains.");

  finding(findings, managerCallbacks.every((name) => bodyFor(manager, name)),
    "manager.callback-seam", "Manager exposes only the scoring/final-presentation callback seam needed by the runtime.");
  const queuedSurface = bodyFor(manager, "AccumulateQueuedQuestReactionSurface");
  const queuedSurfaceUnique = bodyFor(manager, "QueuedQuestReactionSurfaceHasName");
  const flushQueuedSurface = bodyFor(manager, "FlushQueuedQuestReactionSurface");
  finding(findings, queuedSurface.includes("alreadyListed = QueuedQuestReactionSurfaceHasName(deityName)") &&
    queuedSurface.includes("if !alreadyListed") &&
    queuedSurfaceUnique.includes("_qrQueueSurfPosNamesCsv") && queuedSurfaceUnique.includes("_qrQueueSurfNegNamesCsv") &&
    queuedSurfaceUnique.includes("StringUtil.Find"),
    "manager.unique-final-surface", "A logical deed lists each deity once; magnitude remains a separate Book rune concern.");
  finding(findings,
    flushQueuedSurface.includes("String surfaceSourceModName = NormalizePublicDeityDisplayText(sourceModName)") &&
    ["Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm"]
      .every((master) => flushQueuedSurface.includes(`surfaceSourceModName == "${master}"`)) &&
    flushQueuedSurface.includes('surfaceSourceModName = ""') &&
    count(flushQueuedSurface, /SendPrismaToastWithSource\([^\r\n]*surfaceSourceModName/g) === 3 &&
    count(flushQueuedSurface, /AppendBookOfDaysEntry\([^\r\n]*surfaceSourceModName/g) === 3 &&
    !/SendPrismaToastWithSource\([^\r\n]*,\s*sourceModName(?:\s*,|\s*\))/g.test(flushQueuedSurface) &&
    !/AppendBookOfDaysEntry\([^\r\n]*,\s*sourceModName(?:\s*,|\s*\))/g.test(flushQueuedSurface),
    "manager.public-source-sanitized", "Quest Reaction toast and Book surfaces hide Bethesda master filenames while retaining optional integration attribution.");
  finding(findings, retiredManager.every((name) => !bodyFor(manager, name)) &&
    !manager.includes("PDV.V3.QR.") && !manager.includes("PDV_QuestReactionWorker"),
    "manager.ownership-retired", "Manager no longer owns catalog, queue, V3 storage, scheduler, or the old worker.");
  finding(findings, eventBusQuest.includes("PDV_QuestReactionRuntimeService.SubmitQuestStage") &&
    !eventBusQuest.includes("PDV_Manager.ApplyQuestReaction"),
    "eventbus.direct-ingress", "EventBus submits quest stages directly to the runtime.");
  finding(findings, /QUEST_REACTION_MATRIX_FILE\s*=\s*"\.\.\/StorageUtilData\/PlayerDevotion\/PDV_QuestReactionCore\.v2"/i.test(manager) &&
    /QUEST_REACTION_MATRIX_FILE\s*=\s*"\.\.\/StorageUtilData\/PlayerDevotion\/PDV_QuestReactionCore\.v2"/i.test(playerEvents) &&
    !/QUEST_REACTION_MATRIX_FILE\s*=\s*"[^"\r\n]*(?:PDV_QuestReactionMatrix(?:\.json)?|PDV_QuestReactionPatches\.v2|QuestReactionExtensions)/i.test(`${manager}\n${playerEvents}`),
    "core-only-consumers", "Manager and PlayerEvents consume only the shared Core.v2 data surface; patches and extensions stay private to Runtime.");
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
    ["missing armed update guard", { runtime: base.runtime.replace("StorageUtil.GetIntValue(None, QUEUE_UPDATE_ARMED_KEY) != 1", "True") }, "runtime.single-armed-update-chain"],
    ["quest reaction inside broad scope", { playerEvents: base.playerEvents.replace("RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)", "RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)\n    RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)") }, "playerevents.scope-closes-before-qr"],
    ["synchronous catalog materialization", { runtime: base.runtime.replace('StorageUtil.SetIntValue(None, prefix + "BuildComplete", 0)', 'StorageUtil.SetIntValue(None, prefix + "BuildComplete", 0)\n    PDV_Manager.ShouldQueueQuestReactionCell("Akatosh", "+", "native", "major")') }, "runtime.lightweight-admission"],
    ["uncheckpointed build cursor", { runtime: base.runtime.replace('StorageUtil.SetIntValue(None, prefix + "BuildIndex", buildIndex)', '; cursor checkpoint removed') }, "runtime.bounded-materialization"],
    ["load ignores saved active slice", { runtime: base.runtime.replace("savedSliceOwnsResume = fromLoad && _sliceActive", "savedSliceOwnsResume = False") }, "runtime.single-armed-update-chain"],
    ["cell checkpoint after slice", { runtime: base.runtime.replace('        StorageUtil.SetIntValue(None, prefix + "CellIndex", cellIndex)\n        processed += 1', '        processed += 1\n    endWhile\n    StorageUtil.SetIntValue(None, prefix + "CellIndex", cellIndex)').replace('    endWhile\n    PDV_Manager.EndQueuedQuestReactionSlice()', '    PDV_Manager.EndQueuedQuestReactionSlice()') }, "runtime.cell-progress-checkpoint"],
    ["surface deity duplication", { manager: base.manager.replace("Bool alreadyListed = QueuedQuestReactionSurfaceHasName(deityName)", "Bool alreadyListed = False") }, "manager.unique-final-surface"],
    ["raw core source reaches quest surfaces", { manager: base.manager.replace("String surfaceSourceModName = NormalizePublicDeityDisplayText(sourceModName)", "String surfaceSourceModName = sourceModName") }, "manager.public-source-sanitized"],
    ["Book bypasses sanitized quest source", { manager: base.manager.replace("False, surfaceSourceModName)", "False, sourceModName)") }, "manager.public-source-sanitized"],
    ["missing interface member", { runtime: base.runtime.replace("String Function GetCompatibilityDetail()", "String Function MissingCompatibilityDetail()") }, "runtime.interface"],
    ["EventBus manager ingress", { eventBus: base.eventBus.replace("PDV_QuestReactionRuntimeService.SubmitQuestStage", "PDV_Manager.ApplyQuestReaction") }, "eventbus.direct-ingress"],
    ["Manager V3 storage", { manager: base.manager + '\nString bad = "PDV.V3.QR.Queue.JobIds"\n' }, "manager.ownership-retired"],
    ["legacy V1 discovery", { runtime: base.runtime + '\nString Property QUEST_REACTION_CHANNEL_FOLDER = "Channels" AutoReadOnly\n' }, "runtime.v1-discovery-retired"],
    ["unsorted extensions", { runtime: base.runtime.replace("SortCatalogNames(JsonUtil.JsonInFolder(QUEST_REACTION_EXTENSION_FOLDER))", "JsonUtil.JsonInFolder(QUEST_REACTION_EXTENSION_FOLDER)") }, "runtime.catalog-owner"],
    ["missing semantic path", { runtime: base.runtime.replace('return QueueResolvedReactionJob(catalogFile, "semantic." + semanticKey + ".", semanticKey, sourceForm, semanticKey, StorageUtil.GetStringValue(None, "PDV.V3.QR.SemanticSourceName." + semanticKey))', "return False") }, "runtime.semantic-ingress"],
    ["local-key fallback", { runtime: base.runtime + '\nString legacyPrefix = "quest." + localFormId + "|" + stageValue + "."\n' }, "runtime.qualified-indexes"],
    ["malformed source aborts catalog", { runtime: base.runtime.replace('if !ValidateCatalogSource(catalogFile, sourceId)\n            _rejectedSourceCount += 1', 'if !ValidateCatalogSource(catalogFile, sourceId)\n            return\n            _rejectedSourceCount += 1') }, "runtime.source-isolation"],
    ["missing catalog rejection reason", { runtime: base.runtime.replace('"CATALOG_REJECT file=" + catalogFile + " reason=schema"', '"catalog rejected"') }, "runtime.catalog-diagnostics"],
    ["uncached catalog loop count", { runtime: base.runtime.replace("Int sentinelCount = JsonUtil.StringListCount(catalogFile, sentinelKey)", "Int sentinelCount = 0") }, "runtime.qr-local-caching"],
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
