#!/usr/bin/env node
/*
 * Read-only static audit for the bounded quest-reaction queue.
 *
 * This is structural/readback proof only. It proves that the shipped source
 * follows the bounded-worker contract; it does not prove Papyrus scheduling,
 * save/load delivery, or player-facing Prisma / Book of Days behaviour.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANAGER_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const WORKER_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_QuestReactionWorker.psc");
const DAEDRIC_PATH_BASE_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_DaedricPathBase.psc");
const EVENT_BUS_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_EventBus.psc");
const PLAYER_EVENTS_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
const MCM_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_MCM.psc");
const FANOUT_LEDGER_PATH = path.join(ROOT, "tools", "pdv_qr_direct_fanout.json");

const args = new Set(process.argv.slice(2));
const JSON_OUTPUT = args.has("--json");

function bodyFor(source, functionName) {
  const start = source.search(new RegExp(`(?:[A-Za-z]+\\s+)?Function\\s+${functionName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndFunction\b/i);
  return end < 0 ? tail : tail.slice(0, end + 12);
}

function eventBodyFor(source, eventName) {
  const start = source.search(new RegExp(`Event\\s+${eventName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndEvent\b/i);
  return end < 0 ? tail : tail.slice(0, end + 9);
}

function hasConstant(source, name, expected) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const numeric = String(expected).replace(".", "\\.");
  return new RegExp(`${escaped}\\s*=\\s*${numeric}(?:0+)?\\b`, "i").test(source);
}

function hasWait(source) {
  return /\b(?:Utility\.)?Wait(?:MenuMode)?\s*\(/i.test(source);
}

function add(findings, ok, id, detail) {
  findings.push({ status: ok ? "PASS" : "FAIL", id, detail });
}

/* --- direct fan-out analysis -------------------------------------------------
 * Every other check here anchors on the queue (enqueue -> slice -> worker) and
 * reasons forward, so a function that calls ApplyDeityReaction directly in a
 * straight line was invisible to this gate. These helpers anchor on the OTHER
 * side -- who applies reactions -- and prove each unbounded burst is registered.
 */

const QUEUE_BOUNDED_FUNCTIONS = new Set(["ProcessQuestReactionQueueSlice", "ProcessQueuedQuestReactionMetaSlice"]);
const APPLY_FN = "ApplyDeityReaction";

function escapeRe(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function countCalls(body, functionName) {
  return (body.match(new RegExp(`\\b${escapeRe(functionName)}\\s*\\(`, "gi")) || []).length;
}

/** Map every Function/Event in a Papyrus source to its body text. */
export function parseFunctions(source) {
  const bodies = new Map();
  let current = null;
  let lines = [];
  for (const line of source.split(/\r?\n/)) {
    const start = line.match(/^\s*(?:[A-Za-z_[\]]+\s+)?(?:Function|Event)\s+([A-Za-z_0-9]+)\s*\(/i);
    if (start && current === null) { current = start[1]; lines = []; continue; }
    if (current !== null && /^\s*End(?:Function|Event)\b/i.test(line)) { bodies.set(current, lines.join("\n")); current = null; continue; }
    if (current !== null) lines.push(line);
  }
  if (current !== null) bodies.set(current, lines.join("\n"));
  return bodies;
}

/** Count synchronous reaction applications per function, resolving thin wrappers.
 *  A thin wrapper is a function whose entire job is one ApplyDeityReaction call
 *  (detected, not hardcoded, so renaming a helper cannot slip past the gate). */
export function analyzeDirectFanout(managerSource, ledger) {
  const bodies = parseFunctions(managerSource);
  const budget = Number(ledger?.budget ?? 2);

  const thinWrappers = [];
  for (const [name, body] of bodies) {
    if (name === APPLY_FN) continue;
    if (countCalls(body, APPLY_FN) !== 1) continue;
    const statements = body.split(/\r?\n/).map((s) => s.trim()).filter((s) => s && !s.startsWith(";"));
    if (statements.length <= 4) thinWrappers.push(name);
  }

  const bursts = new Map();
  for (const [name, body] of bodies) {
    if (name === APPLY_FN) continue;
    let applications = countCalls(body, APPLY_FN);
    for (const wrapper of thinWrappers) if (wrapper !== name) applications += countCalls(body, wrapper);
    if (applications > 0) bursts.set(name, applications);
  }

  const fanouts = [];
  for (const [name, applications] of bursts) {
    if (QUEUE_BOUNDED_FUNCTIONS.has(name)) continue; // bounded by CELLS_PER_TICK; proven by manager.bounded-* checks
    if (thinWrappers.includes(name)) continue; // applies exactly one
    if (applications <= budget) continue;
    fanouts.push({ name, applications });
  }
  return { budget, thinWrappers, fanouts };
}

export function evaluateDirectFanout(managerSource, ledger) {
  const findings = [];
  const registry = ledger?.fanouts ?? {};
  const { budget, fanouts } = analyzeDirectFanout(managerSource, ledger);

  const unregistered = fanouts.filter((f) => !registry[f.name]);
  add(findings, unregistered.length === 0, "fanout.registered",
    unregistered.length
      ? `Unregistered synchronous fan-out (>${budget} applications outside the queue): ${unregistered.map((f) => `${f.name} (${f.applications})`).join(", ")}. Route it through ApplyQuestReaction ingress or register it in tools/pdv_qr_direct_fanout.json.`
      : `Every synchronous fan-out above the ${budget}-application budget is registered in tools/pdv_qr_direct_fanout.json.`);

  const overBudget = fanouts.filter((f) => registry[f.name] && f.applications > Number(registry[f.name].maxApplications));
  add(findings, overBudget.length === 0, "fanout.within-recorded-budget",
    overBudget.length
      ? `Fan-out grew beyond its recorded budget: ${overBudget.map((f) => `${f.name} ${f.applications} > ${registry[f.name].maxApplications}`).join(", ")}.`
      : "No registered fan-out applies more reactions than its recorded maximum.");

  const live = new Set(fanouts.map((f) => f.name));
  const stale = Object.keys(registry).filter((name) => !live.has(name));
  add(findings, stale.length === 0, "fanout.no-stale-registry",
    stale.length
      ? `Registry lists functions that are no longer unbounded fan-outs: ${stale.join(", ")}. Delete the entry.`
      : "Every registry entry still describes a real fan-out.");

  return findings;
}

export function evaluate({ managerSource, workerSource, daedricPathBaseSource = "", eventBusSource = "", playerEventsSource = "", mcmSource = "", fanoutLedger = null }) {
  const findings = [];
  const queue = bodyFor(managerSource, "QueueQuestReactionJob");
  const slice = bodyFor(managerSource, "ProcessQuestReactionQueueSlice");
  const status = bodyFor(managerSource, "GetQuestReactionQueueStatus");
  const hasJobs = bodyFor(managerSource, "HasQueuedQuestReactionJobs");
  const apply = bodyFor(managerSource, "ApplyQuestReaction");
  const applyDeity = bodyFor(managerSource, "ApplyDeityReaction");
  const cheapSkip = bodyFor(managerSource, "IsQueuedQuestReactionCellCheapSkip");
  const finalize = bodyFor(managerSource, "FinalizeQuestReactionJob");
  const workerInit = eventBodyFor(workerSource, "OnInit");
  const workerLoad = eventBodyFor(workerSource, "OnPlayerLoadGame");
  const workerUpdate = eventBodyFor(workerSource, "OnUpdate");
  const workerResume = bodyFor(workerSource, "ResumeQuestReactionQueue");
  const queueTrace = bodyFor(managerSource, "TraceQuestReactionQueue");
  const sources = [eventBusSource, playerEventsSource, mcmSource].join("\n");

  add(findings, /Scriptname\s+PDV_QuestReactionWorker\b/i.test(workerSource), "worker.identity", "Worker source declares PDV_QuestReactionWorker.");
  add(findings, /PDV__ManagerQuest\s+Property\s+PDV_Manager\s+Auto/i.test(workerSource), "worker.manager-property", "Worker has the CK-wired PDV_Manager property.");
  add(findings, hasConstant(managerSource, "QUEST_REACTION_QUEUE_MAX_PENDING", 128), "manager.max-pending", "Queue ceiling is exactly 128 pending jobs.");
  add(findings, hasConstant(managerSource, "QUEST_REACTION_QUEUE_CELLS_PER_TICK", 2), "manager.cells-per-tick", "Worker slice budget is exactly two cells.");
  add(findings, hasConstant(managerSource, "QUEST_REACTION_QUEUE_TICK_SECONDS", 0.1), "manager.tick-seconds", "Worker rearm cadence is exactly 0.1 seconds while work exists.");

  add(findings, Boolean(queue), "manager.enqueue-api", "Manager exposes QueueQuestReactionJob.");
  add(findings, Boolean(slice), "manager.slice-api", "Manager exposes ProcessQuestReactionQueueSlice.");
  add(findings, Boolean(status), "manager.status-api", "Manager exposes GetQuestReactionQueueStatus for MCM/readback.");
  add(findings, Boolean(hasJobs), "manager.has-work-api", "Manager exposes HasQueuedQuestReactionJobs for worker rearm.");
  add(findings, /StorageUtil\.(?:Set|Adjust|Unset|Clear|StringList|IntList|FloatList)/i.test(queue), "manager.storage-queue", "Manager enqueue path persists queue state through StorageUtil.");
  add(findings, /StorageUtil\.(?:Get|Set|Adjust|Unset|Clear|StringList|IntList|FloatList)/i.test(slice), "manager.storage-slice", "Manager slice reads/writes persisted queue state through StorageUtil.");
  const snapshotFields = ["ReactionKey", "DeitiesCsv", "ValencesCsv", "IntensitiesCsv", "MagnitudesCsv", "TagsCsv", "CellCount", "SourceCellCount", "SkippedCellCount", "Compacted", "Started", "CellIndex", "EnqueuedRealTime", "IngressBuildMs"];
  const missingSnapshotFields = snapshotFields.filter((field) => !queue.includes(`"${field}"`));
  add(findings, missingSnapshotFields.length === 0, "manager.immutable-snapshot", missingSnapshotFields.length ? `Missing persisted queue snapshot fields: ${missingSnapshotFields.join(", ")}.` : "Ingress snapshots reaction cell data and progress before returning to the stage sender.");
  add(findings, !hasWait(queue) && !hasWait(slice), "manager.no-queue-waits", "Queue enqueue/slice paths contain no Wait or WaitMenuMode contention.");
  add(findings, !/_broadPantheonEventDepth/i.test(queue) && !/_broadPantheonEventDepth/i.test(slice), "manager.no-cross-update-broad-scope", "Queue ingress/slice do not carry broad-pantheon scope state across updates.");
  add(findings, /QUEST_REACTION_QUEUE_CELLS_PER_TICK/i.test(slice) && /while\b/i.test(slice), "manager.bounded-slice", "Queue slice loops against the two-cell budget rather than the whole job.");
  add(findings, /IsQueuedQuestReactionCellCheapSkip\s*\(/i.test(slice) && /processed\s*<\s*QUEST_REACTION_QUEUE_CELLS_PER_TICK/i.test(slice) && /cellIndex\s*\+=\s*1/i.test(slice), "manager.fast-skip-noop-cells", "Queued no-op cells can advance without consuming the two-applied-cell budget.");
  add(findings, /Bool\s+Function\s+IsQueuedQuestReactionCellCheapSkip/i.test(managerSource) && /return\s+!\s*IsQuestReactionDeityReachable\s*\(\s*deity\s*\)/i.test(cheapSkip) && /stance\s*==\s*"CURSE"[\s\S]*?return\s+False/i.test(cheapSkip), "manager.fast-skip-preserves-live-cells", "Cheap-skip helper skips unreachable/no-op cells but preserves curse and reachable cells for normal application.");
  add(findings, /while\s+sourceIndex\s*<\s*sourceCellCount/i.test(queue) && /!\s*IsQueuedQuestReactionCellCheapSkip\s*\(/i.test(queue) && /AppendQuestReactionSnapshotToken\s*\(/i.test(queue), "manager.ingress-compacts-runnable-cells", "Ingress snapshots only base rows capable of producing work.");
  add(findings, /"Compacted"\s*,\s*1/i.test(queue) && /"SourceCellCount"/i.test(queue) && /"SkippedCellCount"/i.test(queue), "manager.compaction-diagnostics", "Compacted jobs persist their source and skipped-row counts.");
  add(findings, /"MetaIndex"\s*,\s*7/i.test(queue) && /metaRunnableCount/i.test(queue) && /metaEligible/i.test(queue), "manager.ingress-compacts-meta-cells", "Ingress folds runnable legacy meta rows into the bounded row stream and marks the legacy meta cursor complete.");
  add(findings, /!\s*compactedJob\s*&&\s*IsQueuedQuestReactionCellCheapSkip\s*\(/i.test(slice), "manager.legacy-job-compatibility", "Already-saved un-compacted jobs retain the worker-side cheap-skip path.");
  add(findings, /"Started"\s*\)\s*!=\s*1/i.test(slice) && /"Started"\s*,\s*1/i.test(slice), "manager.start-marker-once", "A persisted started flag prevents zero-row compacted jobs from reinitialising on every meta tick.");
  const metaSlice = bodyFor(managerSource, "ProcessQueuedQuestReactionMetaSlice");
  add(findings, /QUEST_REACTION_QUEUE_CELLS_PER_TICK/i.test(metaSlice) && /while\b/i.test(metaSlice), "manager.bounded-meta-slice", "Quest meta lanes consume the same two-work-item budget as base reaction cells.");
  add(findings, /\[PDV\]\[QR_QUEUE\]/i.test(queueTrace) && /GetDebugLevel\s*\(\s*\)\s*>=\s*1/i.test(queueTrace), "manager.marker-helper", "Manager queue trace helper emits the [PDV][QR_QUEUE] prefix at debug level 1.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"ENQUEUE/i.test(queue), "manager.enqueue-marker", "Queue ingress emits the QR_QUEUE ENQUEUE lifecycle marker.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"COALESCE/i.test(queue), "manager.coalesce-marker", "Exact duplicate ingress emits the QR_QUEUE COALESCE lifecycle marker.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"OVERFLOW/i.test(queue), "manager.overflow-marker", "Queue ceiling rejection emits the QR_QUEUE OVERFLOW lifecycle marker.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"START/i.test(slice), "manager.start-marker", "Queue slice emits the QR_QUEUE START lifecycle marker.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"COMPLETE/i.test(slice + "\n" + finalize), "manager.complete-marker", "Queue finalisation emits the QR_QUEUE COMPLETE lifecycle marker.");
  add(findings, /TraceQuestReactionQueue\s*\(\s*"RESUME/i.test(managerSource + "\n" + workerSource), "resume-marker", "Save/load resume emits the QR_QUEUE RESUME lifecycle marker.");

  const applyIsIngressOnly = Boolean(apply)
    && /QueueQuestReactionJob\s*\(/i.test(apply)
    && !/ApplyDeityReaction\s*\(/i.test(apply)
    && !/BeginBroadPantheonEvent\s*\(/i.test(apply)
    && !/FlushQuestReactionSurface\s*\(/i.test(apply)
    && !/FlushBroadPantheonEvent\s*\(/i.test(apply);
  add(findings, applyIsIngressOnly, "manager.ingress-only", "ApplyQuestReaction snapshots/enqueues and does not synchronously fan out cells or finalise UI/pantheon work.");
  const pendingReturn = slice.search(/if\s+cellIndex\s*<\s*cellCount[\s\S]*?return\s+True/i);
  const finalisationTokens = ["FlushQueuedQuestReactionSurface", "CommitQueuedQuestReactionBroad", "HandleCurseStateRefresh", "SyncFirstTierRaceRewardRuntime", "RequestPanelRefresh"];
  const earlyFinalisation = finalisationTokens.filter((tokenName) => {
    const position = slice.indexOf(tokenName);
    return position < 0 || position < pendingReturn;
  });
  add(findings, pendingReturn >= 0 && earlyFinalisation.length === 0, "manager.finalise-once-after-last-cell", pendingReturn < 0 ? "Queue slice has no explicit incomplete-job return." : (earlyFinalisation.length ? `Finalisation is absent or occurs before the last-cell guard: ${earlyFinalisation.join(", ")}.` : "Surface, broad fold, curse sync, Breton sync, and panel refresh occur only after the final queued cell."));
  const curseBranch = (applyDeity.match(/if\s+stance\s*==\s*"CURSE"[\s\S]*?return[\s\S]*?endIf/i) || [""])[0];
  add(findings, /_qrQueueTransactionActive/i.test(curseBranch) && /_qrQueueNeedsCurseRefresh\s*=\s*True/i.test(curseBranch) && /else[\s\S]*?HandleCurseStateRefresh\s*\(/i.test(curseBranch), "manager.queued-curse-deferred", "Queued curse cells set the finalizer flag instead of refreshing curse state per cell.");
  const unreachableTraceAtLevel2 = /GetDebugLevel\s*\(\s*\)\s*>=\s*2[\s\S]{0,180}QuestReaction skipped unreachable/i.test(applyDeity);
  add(findings, !unreachableTraceAtLevel2 && /GetDebugLevel\s*\(\s*\)\s*>=\s*3[\s\S]{0,180}QuestReaction skipped unreachable/i.test(applyDeity), "manager.per-cell-skip-trace-level3", "Per-cell quest-reaction reachability skip traces are debug level 3.");
  add(findings, /StringUtil\.Find\s*\(\s*reason\s*,\s*"quest_reaction_"\s*\)\s*==\s*0/i.test(daedricPathBaseSource) && /traceLevel\s*=\s*3/i.test(daedricPathBaseSource), "daedric.quest-reaction-stigma-trace-level3", "Daedric quest-reaction stigma traces are debug level 3.");
  const resumeIsBounded = /PDV_Manager\.HasQueuedQuestReactionJobs\s*\(/i.test(workerResume) && /RegisterForSingleUpdate\s*\(/i.test(workerResume);
  add(findings, /ResumeQuestReactionQueue\s*\(\s*False\s*\)/i.test(workerInit) && resumeIsBounded, "worker.init-resume", "OnInit delegates to a bounded resume helper which arms only when the manager reports work.");
  add(findings, /ResumeQuestReactionQueue\s*\(\s*True\s*\)/i.test(workerLoad) && resumeIsBounded, "worker.load-resume", "OnPlayerLoadGame delegates to a bounded resume helper which arms only when the manager reports work.");
  const workerDoesNoCellWork = Boolean(workerUpdate)
    && /PDV_Manager\.ProcessQuestReactionQueueSlice\s*\(/i.test(workerUpdate)
    && /RegisterForSingleUpdate\s*\(/i.test(workerUpdate)
    && !/ApplyDeityReaction\s*\(/i.test(workerSource)
    && !/StorageUtil\./i.test(workerSource)
    && !/StringUtil\.Split/i.test(workerSource);
  add(findings, workerDoesNoCellWork, "worker.scheduler-only", "Worker schedules Manager queue slices and owns neither queue data nor deity-cell processing.");

  const routingUsesIngress = /ApplyQuestReaction\s*\(/i.test(sources)
    && !/ProcessQuestReactionQueueSlice\s*\(/i.test(sources)
    && !/QueueQuestReactionJob\s*\(/i.test(eventBusSource + "\n" + playerEventsSource);
  add(findings, routingUsesIngress, "route.integration", "EventBus/PlayerEvents/MCM route multi-cell quest reactions through ApplyQuestReaction ingress, never a direct slice.");

  findings.push(...evaluateDirectFanout(managerSource, fanoutLedger));

  return {
    status: findings.some((finding) => finding.status === "FAIL") ? "FAIL" : "PASS",
    proofBoundary: "static-source-contract-only; runtime scheduling, save/load, latency, Prisma, and Book of Days proof remain separate",
    findings,
  };
}

function syntheticSources() {
  const manager = `
Int QUEST_REACTION_QUEUE_MAX_PENDING = 128
Int QUEST_REACTION_QUEUE_CELLS_PER_TICK = 2
Float QUEST_REACTION_QUEUE_TICK_SECONDS = 0.1
Function QueueQuestReactionJob()
  StorageUtil.SetIntValue(None, "PDV.QR.Queue.Count", 1)
  StorageUtil.SetStringValue(None, "ReactionKey", "x")
  StorageUtil.SetStringValue(None, "DeitiesCsv", "x")
  StorageUtil.SetStringValue(None, "ValencesCsv", "x")
  StorageUtil.SetStringValue(None, "IntensitiesCsv", "x")
  StorageUtil.SetStringValue(None, "MagnitudesCsv", "x")
  StorageUtil.SetStringValue(None, "TagsCsv", "x")
  StorageUtil.SetIntValue(None, "CellCount", 1)
  StorageUtil.SetIntValue(None, "SourceCellCount", 2)
  StorageUtil.SetIntValue(None, "SkippedCellCount", 1)
  StorageUtil.SetIntValue(None, "Compacted", 1)
  StorageUtil.SetIntValue(None, "Started", 0)
  StorageUtil.SetIntValue(None, "CellIndex", 0)
  StorageUtil.SetIntValue(None, "MetaIndex", 7)
  StorageUtil.SetFloatValue(None, "EnqueuedRealTime", 0.0)
  StorageUtil.SetFloatValue(None, "IngressBuildMs", 0.0)
  Int sourceIndex = 0
  Int sourceCellCount = 2
  Int metaRunnableCount = 0
  Int metaEligible = 0
  while sourceIndex < sourceCellCount
    if !IsQueuedQuestReactionCellCheapSkip()
      AppendQuestReactionSnapshotToken()
    endIf
    sourceIndex += 1
  endWhile
  TraceQuestReactionQueue("ENQUEUE")
  TraceQuestReactionQueue("COALESCE")
  TraceQuestReactionQueue("OVERFLOW")
EndFunction
Function ProcessQuestReactionQueueSlice()
  Int done = 0
  Bool compactedJob = True
  if StorageUtil.GetIntValue(None, "Started") != 1
    StorageUtil.SetIntValue(None, "Started", 1)
  endIf
  while done < QUEST_REACTION_QUEUE_CELLS_PER_TICK
    StorageUtil.AdjustIntValue(None, "PDV.QR.Queue.Count", 0)
    done += 1
  endWhile
  if !compactedJob && IsQueuedQuestReactionCellCheapSkip()
    cellIndex += 1
  elseIf processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK
    cellIndex += 1
  endIf
  TraceQuestReactionQueue("START")
  if cellIndex < cellCount
    return True
  endIf
  FlushQueuedQuestReactionSurface()
  CommitQueuedQuestReactionBroad()
  HandleCurseStateRefresh()
  SyncFirstTierRaceRewardRuntime()
  RequestPanelRefresh()
  TraceQuestReactionQueue("COMPLETE")
EndFunction
Int Function ProcessQueuedQuestReactionMetaSlice()
  Int done = 0
  while done < QUEST_REACTION_QUEUE_CELLS_PER_TICK
    done += 1
  endWhile
  return done
EndFunction
String Function GetQuestReactionQueueStatus()
  return "idle"
EndFunction
Bool Function HasQueuedQuestReactionJobs()
  return False
EndFunction
Function ApplyQuestReaction()
  QueueQuestReactionJob()
EndFunction
Bool Function IsQueuedQuestReactionCellCheapSkip()
  if stance == "CURSE"
    return False
  endIf
  return !IsQuestReactionDeityReachable(deity)
EndFunction
Function ApplyDeityReaction()
  if stance == "CURSE"
    if _qrQueueTransactionActive
      _qrQueueNeedsCurseRefresh = True
    else
      HandleCurseStateRefresh()
    endIf
    return
  endIf
  if GetDebugLevel() >= 3
    Debug.Trace("[PDV] QuestReaction skipped unreachable foreign deity")
  endIf
EndFunction
Function FinalizeQuestReactionJob()
  TraceQuestReactionQueue("COMPLETE")
EndFunction
Function ResumeQuestReactionQueue()
  TraceQuestReactionQueue("RESUME")
EndFunction
Function TraceQuestReactionQueue(String text)
  if GetDebugLevel() >= 1
    Debug.Trace("[PDV][QR_QUEUE] " + text)
  endIf
EndFunction`;
  const daedricPathBase = `Function AddStigma(Float amount, String reason)
  Int traceLevel = 2
  if StringUtil.Find(reason, "quest_reaction_") == 0
    traceLevel = 3
  endIf
  TraceDaedric(traceLevel, "Stigma")
EndFunction`;
  const worker = `Scriptname PDV_QuestReactionWorker extends Quest
PDV__ManagerQuest Property PDV_Manager Auto
Event OnInit()
  ResumeQuestReactionQueue(False)
EndEvent
Event OnPlayerLoadGame()
  ResumeQuestReactionQueue(True)
EndEvent
Function ResumeQuestReactionQueue(Bool fromLoad)
  if PDV_Manager.HasQueuedQuestReactionJobs()
    RegisterForSingleUpdate(0.1)
  endIf
EndFunction
Event OnUpdate()
  PDV_Manager.ProcessQuestReactionQueueSlice()
  if PDV_Manager.ProcessQuestReactionQueueSlice()
    RegisterForSingleUpdate(0.1)
  endIf
EndEvent`;
  const routes = `Function RouteQuestReaction()
 ApplyQuestReaction()
EndFunction`;
  return { manager, worker, daedricPathBase, routes };
}

/** The fan-out checks must be provably non-vacuous: a rogue burst has to FAIL,
 *  a registered one has to PASS, and a stale entry has to FAIL. */
function fanoutSelfTest() {
  const results = [];
  const rogue = `
Function HandleSomeFork()
  ApplyDeityReaction("Shor")
  ApplyDeityReaction("Kyne")
  ApplyDeityReaction("Mara")
EndFunction
Function ApplyDeityReaction(String deityName)
EndFunction`;
  const emptyLedger = { budget: 2, fanouts: {} };
  const caught = evaluateDirectFanout(rogue, emptyLedger).find((f) => f.id === "fanout.registered");
  results.push(["unregistered 3-call burst FAILs", caught.status === "FAIL"]);

  const registered = { budget: 2, fanouts: { HandleSomeFork: { maxApplications: 3, reason: "test" } } };
  const allowed = evaluateDirectFanout(rogue, registered).find((f) => f.id === "fanout.registered");
  results.push(["registered burst PASSes", allowed.status === "PASS"]);

  const tight = { budget: 2, fanouts: { HandleSomeFork: { maxApplications: 2, reason: "test" } } };
  const grew = evaluateDirectFanout(rogue, tight).find((f) => f.id === "fanout.within-recorded-budget");
  results.push(["burst over its recorded budget FAILs", grew.status === "FAIL"]);

  const stale = { budget: 2, fanouts: { HandleSomeFork: { maxApplications: 3 }, GoneAway: { maxApplications: 9 } } };
  const rot = evaluateDirectFanout(rogue, stale).find((f) => f.id === "fanout.no-stale-registry");
  results.push(["stale registry entry FAILs", rot.status === "FAIL"]);

  // A thin wrapper called many times must be counted through, not hidden.
  const wrapped = `
Function HandleWrappedFork()
  ApplyOne("Shor")
  ApplyOne("Kyne")
  ApplyOne("Mara")
EndFunction
Function ApplyOne(String deityName)
  ApplyDeityReaction(deityName)
EndFunction
Function ApplyDeityReaction(String deityName)
EndFunction`;
  const throughWrapper = evaluateDirectFanout(wrapped, emptyLedger).find((f) => f.id === "fanout.registered");
  results.push(["burst via a thin wrapper is counted", throughWrapper.status === "FAIL"]);

  return results;
}

function main() {
  if (args.has("--self-test")) {
    const sample = syntheticSources();
    const report = evaluate({ managerSource: sample.manager, workerSource: sample.worker, daedricPathBaseSource: sample.daedricPathBase, eventBusSource: sample.routes, playerEventsSource: sample.routes, mcmSource: sample.routes, fanoutLedger: { budget: 2, fanouts: {} } });
    const fanoutCases = fanoutSelfTest();
    const fanoutOk = fanoutCases.every(([, ok]) => ok);
    const status = report.status === "PASS" && fanoutOk ? "PASS" : "FAIL";
    if (JSON_OUTPUT) console.log(JSON.stringify({ ...report, status, fanoutSelfTest: fanoutCases.map(([name, ok]) => ({ name, status: ok ? "PASS" : "FAIL" })) }, null, 2));
    else {
      console.log(`PDV quest-reaction performance audit self-test: ${status}`);
      for (const [name, ok] of fanoutCases) console.log(`  [${ok ? "PASS" : "FAIL"}] fanout self-test: ${name}`);
    }
    return status === "PASS" ? 0 : 1;
  }

  const report = evaluate({
    managerSource: fs.readFileSync(MANAGER_PATH, "utf8"),
    workerSource: fs.readFileSync(WORKER_PATH, "utf8"),
    daedricPathBaseSource: fs.readFileSync(DAEDRIC_PATH_BASE_PATH, "utf8"),
    eventBusSource: fs.readFileSync(EVENT_BUS_PATH, "utf8"),
    playerEventsSource: fs.readFileSync(PLAYER_EVENTS_PATH, "utf8"),
    mcmSource: fs.readFileSync(MCM_PATH, "utf8"),
    fanoutLedger: JSON.parse(fs.readFileSync(FANOUT_LEDGER_PATH, "utf8")),
  });
  if (JSON_OUTPUT) console.log(JSON.stringify(report, null, 2));
  else {
    for (const finding of report.findings) console.log(`[${finding.status}] ${finding.id}: ${finding.detail}`);
    const failed = report.findings.filter((finding) => finding.status === "FAIL").length;
    console.log(`Summary: ${report.status} (${report.findings.length - failed} pass, ${failed} fail)`);
    console.log(`Proof boundary: ${report.proofBoundary}`);
  }
  return report.status === "PASS" ? 0 : 1;
}

try {
  process.exitCode = main();
} catch (error) {
  const report = { status: "FAIL", error: error.message, proofBoundary: "static-source-contract-only" };
  if (JSON_OUTPUT) console.log(JSON.stringify(report, null, 2));
  else console.error(`PDV quest-reaction performance audit failed: ${error.message}`);
  process.exitCode = 2;
}
