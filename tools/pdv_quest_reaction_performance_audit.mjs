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

export function evaluate({ managerSource, workerSource, daedricPathBaseSource = "", eventBusSource = "", playerEventsSource = "", mcmSource = "" }) {
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
  const snapshotFields = ["ReactionKey", "DeitiesCsv", "ValencesCsv", "IntensitiesCsv", "MagnitudesCsv", "TagsCsv", "CellCount", "CellIndex", "EnqueuedRealTime"];
  const missingSnapshotFields = snapshotFields.filter((field) => !queue.includes(`"${field}"`));
  add(findings, missingSnapshotFields.length === 0, "manager.immutable-snapshot", missingSnapshotFields.length ? `Missing persisted queue snapshot fields: ${missingSnapshotFields.join(", ")}.` : "Ingress snapshots reaction cell data and progress before returning to the stage sender.");
  add(findings, !hasWait(queue) && !hasWait(slice), "manager.no-queue-waits", "Queue enqueue/slice paths contain no Wait or WaitMenuMode contention.");
  add(findings, !/_broadPantheonEventDepth/i.test(queue) && !/_broadPantheonEventDepth/i.test(slice), "manager.no-cross-update-broad-scope", "Queue ingress/slice do not carry broad-pantheon scope state across updates.");
  add(findings, /QUEST_REACTION_QUEUE_CELLS_PER_TICK/i.test(slice) && /while\b/i.test(slice), "manager.bounded-slice", "Queue slice loops against the two-cell budget rather than the whole job.");
  add(findings, /IsQueuedQuestReactionCellCheapSkip\s*\(/i.test(slice) && /processed\s*<\s*QUEST_REACTION_QUEUE_CELLS_PER_TICK/i.test(slice) && /cellIndex\s*\+=\s*1/i.test(slice), "manager.fast-skip-noop-cells", "Queued no-op cells can advance without consuming the two-applied-cell budget.");
  add(findings, /Bool\s+Function\s+IsQueuedQuestReactionCellCheapSkip/i.test(managerSource) && /return\s+!\s*IsQuestReactionDeityReachable\s*\(\s*deity\s*\)/i.test(cheapSkip) && /stance\s*==\s*"CURSE"[\s\S]*?return\s+False/i.test(cheapSkip), "manager.fast-skip-preserves-live-cells", "Cheap-skip helper skips unreachable/no-op cells but preserves curse and reachable cells for normal application.");
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
  StorageUtil.SetIntValue(None, "CellIndex", 0)
  StorageUtil.SetFloatValue(None, "EnqueuedRealTime", 0.0)
  TraceQuestReactionQueue("ENQUEUE")
  TraceQuestReactionQueue("COALESCE")
  TraceQuestReactionQueue("OVERFLOW")
EndFunction
Function ProcessQuestReactionQueueSlice()
  Int done = 0
  while done < QUEST_REACTION_QUEUE_CELLS_PER_TICK
    StorageUtil.AdjustIntValue(None, "PDV.QR.Queue.Count", 0)
    done += 1
  endWhile
  if IsQueuedQuestReactionCellCheapSkip()
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

function main() {
  if (args.has("--self-test")) {
    const sample = syntheticSources();
    const report = evaluate({ managerSource: sample.manager, workerSource: sample.worker, daedricPathBaseSource: sample.daedricPathBase, eventBusSource: sample.routes, playerEventsSource: sample.routes, mcmSource: sample.routes });
    if (JSON_OUTPUT) console.log(JSON.stringify(report, null, 2));
    else console.log(`PDV quest-reaction performance audit self-test: ${report.status}`);
    return report.status === "PASS" ? 0 : 1;
  }

  const report = evaluate({
    managerSource: fs.readFileSync(MANAGER_PATH, "utf8"),
    workerSource: fs.readFileSync(WORKER_PATH, "utf8"),
    daedricPathBaseSource: fs.readFileSync(DAEDRIC_PATH_BASE_PATH, "utf8"),
    eventBusSource: fs.readFileSync(EVENT_BUS_PATH, "utf8"),
    playerEventsSource: fs.readFileSync(PLAYER_EVENTS_PATH, "utf8"),
    mcmSource: fs.readFileSync(MCM_PATH, "utf8"),
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
