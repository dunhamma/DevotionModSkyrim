#!/usr/bin/env node
/* Read-only broad-pantheon authority/runtime audit. Flags: --json, --self-test. */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_broad_pantheon_audit" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CONTRACT_PATH = path.join(ROOT, "references", "authoring", "PDV_BroadPantheonContracts.json");
const MANAGER_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const MCM_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_MCM.psc");
const PLAYER_EVENTS_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
const EVENT_BUS_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_EventBus.psc");
const QUEST_REACTION_RUNTIME_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_QuestReactionRuntime.psc");
const ACTION_ROUTER_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_ActionRouter.psc");
const DEITY_BASE_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_DeityBase.psc");
const RUNTIME_LEDGER_PATH = path.join(ROOT, "references", "authoring", "PDV_PantheonSubstrateRuntimeEvidenceLedger.json");
const flags = new Set(process.argv.slice(2));

const EXPECTED_ROSTERS = {
  ImperialDivines: ["Akatosh", "Arkay", "Dibella", "Julianos", "Kynareth", "Mara", "Stendarr", "Zenithar"],
  NordOldWays: ["Kyne", "Shor", "Tsun", "Stuhn", "Mara", "Orkey", "Dibella", "Talos"],
  NordNineDivines: ["Akatosh", "Arkay", "Dibella", "Julianos", "Kynareth", "Mara", "Stendarr", "Zenithar", "Talos"],
};

function norm(value) {
  return String(value ?? "").toLowerCase().replace(/[^a-z0-9]/g, "");
}

function bodyFor(source, functionName) {
  const start = source.search(new RegExp(`(?:(?:Bool|Float|Int|String|Form|Spell)\\s+)?Function\\s+${functionName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndFunction\b/i);
  return end >= 0 ? tail.slice(0, end + 12) : tail;
}

function eventBodyFor(source, eventName) {
  const start = source.search(new RegExp(`Event\\s+${eventName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndEvent\b/i);
  return end >= 0 ? tail.slice(0, end + 10) : tail;
}

function hasNumber(source, label, expected) {
  const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`${escaped}\\s*=\\s*${String(expected).replace(".", "\\.")}(?:0+)?\\b`, "i").test(source);
}

function sameMembers(actual, expected) {
  const a = [...new Set((actual ?? []).map(norm))].sort();
  const b = [...new Set(expected.map(norm))].sort();
  return a.length === b.length && a.every((value, index) => value === b[index]);
}

export function aggregateLogicalEvent(deltas) {
  const eligible = deltas.filter((item) => item.eligible !== false).map((item) => Number(item.delta)).filter(Number.isFinite);
  const positive = eligible.filter((delta) => delta > 0);
  if (positive.length) return Math.max(...positive);
  const negative = eligible.filter((delta) => delta < 0);
  return negative.length ? Math.min(...negative) : 0;
}

export function hasDetachedActionShape(body) {
  const eventReasonAssignment = body.search(/String\s+eventReason\s*=\s*GetEventReason\s*\(\s*eventType\s*\)/i);
  const substrateCall = body.search(/HandleSubstrateActionEvent\s*\(\s*eventType\s*,\s*eventReason\s*\)/i);
  return /detachedBroadEvent\s*=\s*!PDV_Manager\.ShouldSurfaceLikesDislikesEvent\s*\(\s*eventType\s*\)/i.test(body)
    && /GetActiveBroadPantheonPoolId\s*\(\s*\)/i.test(body)
    && eventReasonAssignment >= 0
    && substrateCall > eventReasonAssignment
    && (body.match(/GetEventReason\s*\(\s*eventType\s*\)/gi) ?? []).length === 1
    && /AwardPietyFromLikesDislikes\s*\([^\r\n]*detachedBroadEvent[^\r\n]*detachedBroadPool/i.test(body)
    && /CommitDetachedBroadPantheonEvent\s*\(\s*logicalEventId\s*,\s*detachedBroadPool[^\r\n]*eventType\s*\)/i.test(body);
}

export function hasDetachedCommitShape(body) {
  return /ApplyBroadPantheonEventResult\s*\(/i.test(body)
    && !/BeginBroadPantheonEvent|FlushBroadPantheonEvent|WaitMenuMode/i.test(body);
}

export function foldSignedScratch(value, scratch, signedCap = 4.3, poolCap = 50) {
  const folded = Math.max(-signedCap, Math.min(signedCap, scratch));
  return Math.max(0, Math.min(poolCap, value + folded));
}

export function elapsedBroadDecayDays(currentDay, lastProcessedDay, lastGainDay, graceDays = 2) {
  let firstDecayDay = lastProcessedDay + 1;
  if (Number.isFinite(lastGainDay) && firstDecayDay <= lastGainDay + graceDays) firstDecayDay = lastGainDay + graceDays + 1;
  return Math.max(0, currentDay - firstDecayDay + 1);
}

export function elapsedBroadDecayDaysWithActivity(currentDay, lastProcessedDay, lastGainDay, activityDay, graceDays = 2) {
  let firstDecayDay = lastProcessedDay + 1;
  if (Number.isFinite(activityDay) && firstDecayDay <= activityDay) firstDecayDay = activityDay + 1;
  if (Number.isFinite(lastGainDay) && firstDecayDay <= lastGainDay + graceDays) firstDecayDay = lastGainDay + graceDays + 1;
  return Math.max(0, currentDay - firstDecayDay + 1);
}

export function settleReturningBroadAct(value, scratch, currentDay, lastProcessedDay, lastGainDay) {
  const pastDecayDays = elapsedBroadDecayDays(currentDay - 1, lastProcessedDay, lastGainDay);
  return foldSignedScratch(Math.max(0, value - pastDecayDays * 0.1), scratch);
}

export function evaluate({ contract, managerSource, playerEventsSource, eventBusSource, questReactionRuntimeSource, actionRouterSource, deityBaseSource, mcmSource = "" }) {
  const findings = [];
  const add = (ok, id, detail) => findings.push({ status: ok ? "PASS" : "FAIL", id, detail });
  const shared = contract.shared ?? {};
  const pools = Array.isArray(contract.pools) ? contract.pools : [];
  const poolById = new Map(pools.map((pool) => [pool.id, pool]));

  add(contract.schema === "pdv.broad-pantheon-contracts.v1", "contract.schema", `expected pdv.broad-pantheon-contracts.v1; got ${contract.schema}`);
  add(shared.thresholds?.seeker === 25 && shared.thresholds?.faithful === 50, "contract.thresholds", `expected 25/50; got ${shared.thresholds?.seeker}/${shared.thresholds?.faithful}`);
  add(shared.cap === 50, "contract.cap", `expected pool cap 50; got ${shared.cap}`);
  add(shared.tierCount === 2, "contract.tier-count", `expected exactly two broad tiers; got ${shared.tierCount}`);
  add(shared.dailyFold?.signedCap === 4.3, "contract.daily-cap", `expected signed dawn cap 4.3; got ${shared.dailyFold?.signedCap}`);
  add(shared.logicalEventAggregation?.neverSumGods === true, "contract.never-sum", "logical events must never sum deity deltas");
  add(/strongest applied positive/i.test(shared.logicalEventAggregation?.positiveRule ?? ""), "contract.strongest-positive", "positive aggregation must choose the strongest applied eligible delta");
  add(/most severe applied eligible negative/i.test(shared.logicalEventAggregation?.negativeRule ?? ""), "contract.strongest-negative", "negative aggregation must choose the most severe applied eligible delta only when there is no positive");
  add(shared.decay?.graceDays === 2 && shared.decay?.amountPerDawn === 0.1 && shared.decay?.floor === 0, "contract.decay", `expected grace 2, decay 0.1, floor 0; got ${JSON.stringify(shared.decay)}`);
  add(/any nonzero eligible signed pool event counts as activity/i.test(shared.decay?.activityDefinition ?? "") && /Only positive events reset/i.test(shared.decay?.activityDefinition ?? ""), "contract.signed-activity", "negative signed events count as activity without resetting positive-gain grace");
  add(shared.decay?.appliesWhileSuppressed === true, "contract.suppressed-decay", "suppressed and committed pools must continue decay");
  add(pools.length === 3, "contract.pool-count", `expected three pools; got ${pools.length}`);
  add(contract.representation?.type === "manager-owned StorageUtil pool" && contract.representation?.aggregateDeityRecord === false, "contract.representation", "broad standing must be a manager-owned StorageUtil pool, never an aggregate deity record");

  for (const [id, roster] of Object.entries(EXPECTED_ROSTERS)) {
    const pool = poolById.get(id);
    add(Boolean(pool), `contract.pool.${id}`, `${id} must exist`);
    add(Boolean(pool) && sameMembers(pool.eligibleImmediately, roster), `contract.roster.${id}`, `${id} roster must be ${roster.join(", ")}`);
    add(pool?.rewardFamily?.tier3 === null, `contract.no-t3.${id}`, `${id} must cap at T2`);
  }
  add(/explicit Talos stance, prayer, or defiance unlock/i.test(poolById.get("ImperialDivines")?.conditional?.Talos ?? ""), "contract.imperial-talos", "Imperial Talos must be conditionally unlocked");
  add(poolById.get("NordNineDivines")?.rewardFamily?.recordPolicy?.includes("distinct Nord records") === true, "contract.nord-distinct-records", "Nord Nine Divines must use distinct records");
  const resistanceFamilyIsExact = (pool) => {
    const tier1 = pool?.rewardFamily?.tier1?.effects ?? [];
    const tier2 = pool?.rewardFamily?.tier2?.effects ?? [];
    return tier1.length === 1 && tier1[0].actorValue === "PoisonResist" && tier1[0].magnitude === 10
      && tier2.length === 2
      && tier2.some((effect) => effect.actorValue === "PoisonResist" && effect.magnitude === 10)
      && tier2.some((effect) => effect.actorValue === "DiseaseResist" && effect.magnitude === 10);
  };
  add(resistanceFamilyIsExact(poolById.get("ImperialDivines")), "contract.imperial-effects", "Imperial T1/T2 must be poison10 then poison10+disease10");
  add(resistanceFamilyIsExact(poolById.get("NordNineDivines")), "contract.nord-nine-effects", "Nord Nine Divines T1/T2 must be poison10 then poison10+disease10");
  add(contract.nordParity?.onlyOneBaselineActive === true, "contract.nord-exclusive", "only one Nord baseline may be active");
  add((contract.nordParity?.sameMechanics ?? []).length >= 6, "contract.nord-mirror", "both Nord baselines must enumerate their mirrored mechanics");
  add(contract.patronTransition?.carryoverLoss === false, "contract.no-carryover-loss", "patron acceptance must preserve piety");
  add(/never granted/i.test(contract.patronTransition?.focusedT1 ?? ""), "contract.focused-t1-retired", "focused T1 must remain compatibility-only");
  add(/50-84/.test((contract.patronTransition?.acceptance ?? []).join(" ")) && /85 or above/.test((contract.patronTransition?.acceptance ?? []).join(" ")), "contract.focused-thresholds", "focused T2/T3 boundaries must be 50-84/85+");
  add(/suspended until piety recovers to 50/i.test(contract.patronTransition?.below50 ?? ""), "contract.below50", "commitment persists while focused boon suspends below 50");
  let runtimeLedger = null;
  try {
    runtimeLedger = JSON.parse(fs.readFileSync(RUNTIME_LEDGER_PATH, "utf8"));
  } catch {}
  const runtimeCards = Array.isArray(runtimeLedger?.cards) ? runtimeLedger.cards : [];
  const expectedCardIds = Array.from({ length: 12 }, (_, index) => `PS-A${index + 1}`);
  add(runtimeLedger?.schema === "pdv.pantheon-substrate-runtime-evidence.v2" && expectedCardIds.every((id) => runtimeCards.some((card) => card.id === id)), "evidence.runtime-ledger", "v2 structured evidence ledger must expose PS-A1 through PS-A12");
  add(runtimeCards.every((card) => ["runtimeRoute", "organicRoute", "manualDisplay", "saveLoad"].every((slot) => Object.hasOwn(card, slot))), "evidence.proof-buckets", "every adversarial card must keep runtime, organic, manual, and save/load proof separate");

  for (const id of Object.keys(EXPECTED_ROSTERS)) add(managerSource.includes(id), `source.pool-key.${id}`, `${id} must be represented in manager source`);
  add(hasNumber(managerSource, "BROAD_PANTHEON_SEEKER_THRESHOLD", 25), "source.seeker-threshold", "manager must define broad Seeker threshold 25");
  add(hasNumber(managerSource, "BROAD_PANTHEON_FAITHFUL_THRESHOLD", 50), "source.faithful-threshold", "manager must define broad Faithful threshold 50");
  add(hasNumber(managerSource, "BROAD_PANTHEON_POOL_MAX", 50), "source.pool-cap", "manager must define broad pool cap 50");
  add(hasNumber(managerSource, "BROAD_PANTHEON_DECAY_GRACE_DAYS", 2), "source.decay-grace", "manager must define two-day grace");
  add(hasNumber(managerSource, "BROAD_PANTHEON_DECAY_PER_DAWN", 0.1), "source.decay-rate", "manager must define 0.1-per-dawn decay");
  add(hasNumber(managerSource, "PIETY_DAILY_MAX_DELTA", 4.3), "source.signed-daily-cap", "manager must retain the signed 4.3 daily cap");

  const begin = bodyFor(managerSource, "BeginBroadPantheonEvent");
  const join = bodyFor(managerSource, "JoinBroadPantheonEvent");
  const accumulate = bodyFor(managerSource, "AccumulateBroadPantheonDelta");
  const flush = bodyFor(managerSource, "FlushBroadPantheonEvent");
  const dawn = bodyFor(managerSource, "ProcessBroadPantheonDawn");
  const sync = bodyFor(managerSource, "SyncBroadPantheonRewards");
  const broadBookTier = bodyFor(managerSource, "BuildBroadLaneTierReachJournalLine");
  const devotionalDayBody = bodyFor(managerSource, "GetDevotionalDay");
  add(/Float\s+Function\s+AwardPietyInternal\s*\(/i.test(managerSource), "source.applied-delta-return", "AwardPietyInternal must return the post-pipeline applied Float delta");
  add(Boolean(begin), "source.begin-event", "BeginBroadPantheonEvent must exist");
  add(/while\s+_broadPantheonEventDepth\s*>\s*0/i.test(begin) && /_broadPantheonEventId\s*!=\s*logicalEventId/i.test(begin) && /WaitMenuMode/i.test(begin) && /BROAD_SCOPE_ABORT/i.test(begin), "source.concurrent-event-serialization", "independent Papyrus stacks must serialize broad logical events and fail closed on a stalled owner");
  add(/_broadPantheonEventId\s*!=\s*logicalEventId/i.test(join) && /BROAD_SCOPE_MISMATCH/i.test(join) && !/ClearBroadPantheonEventScope/i.test(join), "source.nested-event-join", "nested receivers must join only the matching logical-event identity without clearing a concurrent root scope");
  add(Boolean(accumulate), "source.accumulate-event", "AccumulateBroadPantheonDelta must exist");
  add(Boolean(flush), "source.flush-event", "FlushBroadPantheonEvent must exist");
  add(Boolean(dawn), "source.dawn-fold", "ProcessBroadPantheonDawn must exist");
  add(Boolean(sync), "source.reward-sync", "SyncBroadPantheonRewards must exist");
  add(/The Divines' Regard - Observant/i.test(sync) && /Old Ways - Observant/i.test(sync) && /Faith of the Holds - Observant/i.test(sync), "source.public-broad-ranks", "Broad reward trace labels must use the public Observant/Faithful rank vocabulary, never player-facing Seeker.");
  add(/return\s+GetBroadLaneDisplayName\(originRace\)\s*\+\s*" has reached "/i.test(broadBookTier) && !/"Your /i.test(broadBookTier), "source.broad-book-possessive", "Broad Book of Days tier lines must say '<family> has reached <band>' without the malformed 'Your <family>'.");
  add(/shiftedTime\s*<\s*0\.0/i.test(devotionalDayBody) && /truncatedDay\s*-\s*1/i.test(devotionalDayBody), "source.day-zero-floor", "broad-pool day stamps must explicitly floor negative shifted time on game day zero");
  add(/>\s*0\.0/i.test(accumulate) && />\s*[A-Za-z_][A-Za-z0-9_]*/.test(accumulate), "source.strongest-positive", "event accumulator must compare positive candidates and retain the strongest");
  add(/<\s*0\.0/i.test(accumulate) && /<\s*[A-Za-z_][A-Za-z0-9_]*/.test(accumulate), "source.strongest-negative", "event accumulator must compare negative candidates and retain the most severe");
  add(/positive/i.test(flush) && /negative/i.test(flush), "source.positive-precedence", "flush must prefer an eligible positive over the negative accumulator");
  add(/PIETY_DAILY_MAX_DELTA/i.test(dawn), "source.dawn-signed-cap", "dawn fold must use the shared signed 4.3 cap");
  add(/BROAD_PANTHEON_DECAY/i.test(dawn) && /PATRON_STATE_ACTIVE|suppressed|activePool/i.test(dawn), "source.suppressed-decay", "dawn processing must address pool decay outside the active broad lane");
  add(!/CivicServiceCount[^\r\n]*(>=|>)\s*[36]/i.test(sync), "source.no-civic-count-gate", "broad reward sync must not gate Imperial rewards on civic service count");
  add(/PATRON_STATE_BROAD/i.test(sync) && /25(?:\.0+)?|BROAD_PANTHEON_SEEKER_THRESHOLD/i.test(sync) && /50(?:\.0+)?|BROAD_PANTHEON_FAITHFUL_THRESHOLD/i.test(sync), "source.two-tier-sync", "broad reward sync must resolve highest-slot-only 25/50 tiers");

  add(/BeginLogicalDevotionalAct/i.test(playerEventsSource) && /FlushLogicalDevotionalAct/i.test(playerEventsSource), "source.player-event-scopes", "book, quest-stage, and P2 fan-out receivers must use logical devotional-act scopes");
  const onBookRead = eventBodyFor(playerEventsSource, "OnBookRead");
  const onQuestStageChange = eventBodyFor(playerEventsSource, "OnQuestStageChange");
  const p2Source = bodyFor(playerEventsSource, "RouteP2ImmersiveSource");
  const p2QuestStage = bodyFor(playerEventsSource, "RouteP2ImmersiveQuestStage");
  const genericAction = bodyFor(playerEventsSource, "RouteGenericAction");
  const questReactionStage = bodyFor(playerEventsSource, "RouteQuestReactionStage");
  const eventBusAction = bodyFor(eventBusSource, "RouteActionWithAttribution");
  const eventBusQuest = bodyFor(eventBusSource, "RouteQuestReaction");
  const routerAction = bodyFor(actionRouterSource, "RouteActionWithAttribution");
  add(/String\s+logicalEventId\s*=\s*"book_"/i.test(onBookRead) && /RouteGenericBookRead\s*\([^\r\n]*logicalEventId/i.test(onBookRead) && /RouteP2ImmersiveSource\s*\([^\r\n]*logicalEventId/i.test(onBookRead), "source.book-parent-identity", "book scoring and P2 source routing must inherit one book logical-event identity");
  const questBeginIndex = onQuestStageChange.indexOf("BeginLogicalDevotionalAct(logicalEventId)");
  const questFlushIndex = onQuestStageChange.indexOf("FlushLogicalDevotionalAct()");
  const questReactionIndex = onQuestStageChange.indexOf("RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)");
  add(/String\s+logicalEventId\s*=\s*""/i.test(onQuestStageChange) && /logicalEventId\s*=\s*"quest_"/i.test(onQuestStageChange) && /RouteP2ImmersiveQuestStage\s*\([^\r\n]*logicalEventId/i.test(onQuestStageChange) && questBeginIndex >= 0 && questBeginIndex < questFlushIndex && questFlushIndex < questReactionIndex, "source.quest-scope-separation", "ordinary quest/P2/curated broad work must flush before the independently persisted Quest Reaction transaction is admitted");
  add(/JoinLogicalDevotionalAct\s*\(\s*parentLogicalEventId\s*\)/i.test(p2Source) && /JoinLogicalDevotionalAct\s*\(\s*parentLogicalEventId\s*\)/i.test(p2QuestStage) && /if\s*!joinedParentEvent/i.test(p2Source) && /if\s*!joinedParentEvent/i.test(p2QuestStage), "source.p2-nested-join", "P2 source and quest-stage receivers must join a supplied parent identity and create roots only when standalone");
  add(/String\s+logicalEventId\s*=\s*""/i.test(genericAction) && /RouteAction\s*\([^\r\n]*logicalEventId/i.test(genericAction) && /BeginLikesDislikesSurface\s*\(\s*eventType\s*,\s*logicalEventId\s*\)/i.test(eventBusAction), "source.action-parent-identity", "generic action scoring must pass a supplied parent identity into the likes/dislikes surface");
  add(/String\s+logicalEventId\s*=\s*""/i.test(questReactionStage) && /RouteQuestReaction\s*\([^\r\n]*logicalEventId/i.test(questReactionStage) && /SubmitQuestStage\s*\([^\r\n]*logicalEventId/i.test(eventBusQuest) && !/BeginBroadPantheonEvent|JoinLogicalDevotionalAct|FlushBroadPantheonEvent/i.test(questReactionRuntimeSource), "source.quest-reaction-independent-transaction", "quest reaction retains event attribution while Runtime owns a separate persisted transaction with no borrowed broad scope");
  add(/String\s+logicalEventId\s*=\s*""/i.test(routerAction) && /RouteActionWithAttribution\s*\([^\r\n]*logicalEventId/i.test(routerAction) && /BeginLikesDislikesSurface\s*\(\s*eventType\s*,\s*logicalEventId\s*\)/i.test(routerAction), "source.router-parent-identity", "fallback action routing must preserve a supplied parent identity");
  const detachedBroadCommit = bodyFor(managerSource, "CommitDetachedBroadPantheonEvent");
  add(hasDetachedActionShape(eventBusAction) && hasDetachedActionShape(routerAction), "source.nonsurface-action-detached-broad", "non-presented action fan-out must aggregate locally and commit once without holding the shared broad scope");
  add(hasDetachedCommitShape(detachedBroadCommit), "source.detached-broad-atomic-commit", "detached action results must commit without opening, waiting on, or clearing the shared broad scope");
  add(/likes_dislikes_"\s*\+\s*eventType\s*\+\s*"_"\s*\+\s*Utility\.GetCurrentGameTime/i.test(detachedBroadCommit), "source.detached-broad-identity", "detached fallback identities must preserve event type plus game time");
  const shrinePrayer = bodyFor(managerSource, "HandleShrinePrayer");
  const shoutAttack = bodyFor(managerSource, "HandleShoutAttack");
  add(/BeginBroadPantheonEvent/i.test(shrinePrayer) && /FlushBroadPantheonEvent/i.test(shrinePrayer), "source.shrine-event-scope", "multi-deity shrine prayer must aggregate inside one logical broad event");
  add(/BeginBroadPantheonEvent/i.test(shoutAttack) && /FlushBroadPantheonEvent/i.test(shoutAttack), "source.shout-event-scope", "shout fan-out must aggregate inside one logical broad event");
  const onePoolDawn = bodyFor(managerSource, "ProcessOneBroadPantheonDawn");
  const throughDay = bodyFor(managerSource, "ProcessBroadPantheonThroughDay");
  const applyResult = bodyFor(managerSource, "ApplyBroadPantheonEventResult");
  add(/WriteZeroReservedDevotionalDayStamp\s*\(\s*GetBroadPantheonScratchDayKey/i.test(applyResult)
    && /ReadZeroReservedDevotionalDayStamp\s*\(\s*GetBroadPantheonScratchDayKey/i.test(throughDay)
    && /scratchDay\s*=\s*scratchStamp\s*-\s*2/i.test(throughDay)
    && /scratchDay\s*<=\s*targetDay/i.test(throughDay), "source.broad-scratch-day", "signed scratch must carry its own zero-reserved devotional day and fold only through its stamped day");
  add(/ProcessBroadPantheonThroughDay\s*\(\s*poolId\s*,\s*GetDevotionalDay\(\)/i.test(onePoolDawn)
    && /GetBroadPantheonLastProcessedDayKey/i.test(throughDay)
    && /elapsedDecayDays/i.test(throughDay)
    && /BROAD_PANTHEON_DECAY_PER_DAWN\s*\*\s*elapsedDecayDays/i.test(throughDay)
    && /targetDay\s*\+\s*2/i.test(throughDay), "source.decay-catchup", "broad inactivity decay must catch up elapsed devotional days and persist the processed day with +2 encoding");
  add(/scratchEligible\s*&&\s*firstDecayDay\s*<=\s*scratchDay/i.test(throughDay)
    && /firstDecayDay\s*=\s*scratchDay\s*\+\s*1/i.test(throughDay), "source.signed-activity-skips-inactivity", "a folded positive or negative scratch must exclude its own activity day from inactivity decay");
  const catchupBeforeAct = bodyFor(managerSource, "CatchUpBroadPantheonDecayBeforeCurrentDay");
  add(/CatchUpBroadPantheonDecayBeforeCurrentDay\s*\(\s*poolId\s*\)/i.test(applyResult)
    && /targetDay\s*=\s*GetDevotionalDay\(\)\s*-\s*1/i.test(catchupBeforeAct)
    && /ProcessBroadPantheonThroughDay\s*\(\s*poolId\s*,\s*targetDay/i.test(catchupBeforeAct), "source.returning-act-decay-order", "a returning positive or negative act must settle already-owed inactivity through yesterday before opening today's scratch");
  const questCapBody = bodyFor(managerSource, "MarkQuestReactionFaucet");
  add(/pdvCurrentDawnDay\s*=\s*GetDevotionalDay\(\)/i.test(managerSource), "source.scheduler-day-zero", "auto-dawn scheduler must use the canonical negative-floor devotional day");
  add(/GetDevotionalDay\(\)\s*\+\s*2/i.test(questCapBody), "source.quest-cap-day-zero", "quest reaction daily cap must reserve zero with day+2 encoding");
  add(/ShouldSyncLegacyPatronBoons/i.test(deityBaseSource) && /RACE_NORD|RACE_IMPERIAL/i.test(deityBaseSource) && /return\s+False/i.test(deityBaseSource), "source.legacy-focused-t1-suppressed", "Nord and Imperial deity records must not transiently grant legacy focused T1");
  const pacingCatchup = bodyFor(managerSource, "DebugRunBroadPantheonCatchupForPacing");
  add(!/(?:Adjust|Set)IntValue\s*\([^\r\n]*PDV\.Imperial\.CivicServiceCount/i.test(managerSource), "source.frozen-imperial-counter", "production code must never write PDV.Imperial.CivicServiceCount; the legacy civic counter stays frozen");
  add(!/(?:Adjust|Set)IntValue\s*\([^\r\n]*PDV\.Nord\.OldWaysContextCount/i.test(managerSource), "source.frozen-oldways-counter", "production code must never write PDV.Nord.OldWaysContextCount; the legacy Old Ways counter stays frozen");
  const legacyBroadSeed = bodyFor(managerSource, "DebugSeedBroadLane");
  add(/SetBroadPantheonStanding\s*\(\s*BROAD_PANTHEON_IMPERIAL\s*,\s*BROAD_PANTHEON_FAITHFUL_THRESHOLD/i.test(legacyBroadSeed), "source.debug-imperial-pool-seed", "the legacy MCM broad-lane seed must write ImperialDivines standing 50, not a frozen counter");
  const awardPiety = bodyFor(managerSource, "AwardPietyInternal");
  add(/queuedQuestReaction\s*=\s*_qrQueueTransactionActive/i.test(awardPiety)
    && /ownsBroadEvent\s*=\s*trackBroadPantheon\s*&&\s*!queuedQuestReaction\s*&&\s*_broadPantheonEventDepth\s*==\s*0/i.test(awardPiety)
    && /_broadPantheonSelfEventSequence\s*\+=\s*1/i.test(awardPiety)
    && /if\s+_broadPantheonSelfEventSequence\s*<=\s*0/i.test(awardPiety)
    && /String\s+eventLabel\s*=\s*reason/i.test(awardPiety)
    && /eventLabel\s*=\s*"piety"/i.test(awardPiety)
    && /BeginBroadPantheonEvent\s*\(\s*eventLabel\s*\+\s*"_auto_"\s*\+\s*_broadPantheonSelfEventSequence/i.test(awardPiety), "source.unique-self-owned-events", "every unscoped piety award must create a unique manager-owned broad event identity");
  add(/IsRecentBroadPantheonEventDuplicate/i.test(applyResult) && /RememberBroadPantheonEvent/i.test(applyResult) && /StringListCount\s*\([^\r\n]*>=\s*8/i.test(managerSource), "source.recent-event-ring", "logical-event dedupe must retain a bounded recent-ID ring so immediate A/B/A fan-out cannot multiply the pool delta");
  const resetPool = bodyFor(managerSource, "ResetBroadPantheonPool");
  add(/StringListClear\s*\(\s*None\s*,\s*GetBroadPantheonRecentEventIdsKey\s*\(\s*poolId\s*\)/i.test(resetPool)
    && /FloatListClear\s*\(\s*None\s*,\s*GetBroadPantheonRecentEventTimesKey\s*\(\s*poolId\s*\)/i.test(resetPool)
    && /GetBroadPantheonScratchDayKey\s*\(\s*poolId\s*\)[^\r\n]*0/i.test(resetPool), "source.recent-event-ring-reset", "pool reset must clear both recent-event rings and the scratch-day stamp");
  const talosDefiance = bodyFor(managerSource, "HandleTalosShrineDefiance");
  const talosPressure = bodyFor(managerSource, "HandleImperialTalosPressure");
  add(/ShrinePrayerHasAlias\s*\([^\r\n]*"Talos"\)/i.test(shrinePrayer) && /PDV\.Imperial\.TalosBroadUnlocked[^\r\n]*1/i.test(shrinePrayer), "source.talos-unlock-prayer", "explicit Imperial Talos prayer must unlock Talos for the broad roster");
  add(/GetPlayerOriginRaceIndex\(\)\s*==\s*ORIGIN_IMPERIAL/i.test(talosDefiance) && /PDV\.Imperial\.TalosBroadUnlocked[^\r\n]*1/i.test(talosDefiance), "source.talos-unlock-defiance", "Imperial Talos shrine defiance must unlock Talos for the broad roster");
  add(/GetPlayerOriginRaceIndex\(\)\s*!=\s*ORIGIN_IMPERIAL/i.test(talosPressure) && /IsImperialVampireStateActive/i.test(talosPressure) && /PDV\.Imperial\.TalosBroadUnlocked[^\r\n]*1/i.test(talosPressure), "source.talos-unlock-stance", "eligible Imperial Talos pressure must unlock Talos while rejecting wrong-origin and vampire routes");
  const imperialCurse = bodyFor(managerSource, "ApplyImperialCurseHandlers");
  const imperialRewardFamily = bodyFor(managerSource, "SyncImperialRewardFamily");
  add(/SetFloatValue\s*\(\s*None\s*,\s*GetBroadPantheonScratchKey\s*\(\s*BROAD_PANTHEON_IMPERIAL\s*\)\s*,\s*0\.0/i.test(imperialCurse), "source.vampire-clears-scratch", "Imperial vampire onset must clear pending broad-pool scratch");
  add(/!IsImperialVampireStateActive/i.test(imperialRewardFamily) && /SyncImperialRewards/i.test(imperialCurse), "source.vampire-clears-focused", "Imperial vampire halt must remove focused T2/T3 rewards as well as broad/substrate rewards");
  const baselineSwitch = bodyFor(managerSource, "DebugSetNordPantheonBaseline");
  const debugAccept = bodyFor(managerSource, "DebugAcceptPendingCommitment");
  const pacingOffer = bodyFor(managerSource, "DebugRunPatronOfferForPacing");
  const pacingLapse = bodyFor(managerSource, "DebugLapsePatronForPacing");
  const pacingRecover = bodyFor(managerSource, "DebugRecoverPatronForPacing");
  add(/pending|commitment|patron/i.test(baselineSwitch) && /SetNordPantheonBaseline|SetValue|StorageUtil/i.test(baselineSwitch), "source.debug-baseline-reconciles", "debug baseline switching must reconcile incompatible pending/active patron state");
  const pendingAccept = bodyFor(managerSource, "IsPendingCommitmentStillAcceptable");
  add(/IsPendingCommitmentStillAcceptable/i.test(debugAccept) && /UsesFormalCommitmentOffersForDeity/i.test(pendingAccept) && /HasRecentCommitmentSignalDays\s*\([^\r\n]*2\s*,\s*7/i.test(pendingAccept) && /IsCommitmentDeclineDelayActive/i.test(pendingAccept), "source.debug-accept-revalidates", "commitment acceptance must revalidate baseline, piety, recent activity days, and cooldown state");
  add(/GetPacingPatronCandidate/i.test(pacingOffer) && /COMMITMENT_OFFER_THRESHOLD/i.test(pacingOffer) && /DebugSeedCommitmentSignalDaysByIndex/i.test(pacingOffer) && /PendingDeityIndex/i.test(pacingOffer) && /DeclinedAt/i.test(pacingOffer), "source.pacing-controlled-offer", "Pacing MCM must create a deterministic baseline-eligible 50-piety pending offer on a clean save");
  add(/PDV\.Piety[^\r\n]*49\.0/i.test(pacingLapse) && /SyncFirstTierRaceRewardRuntime/i.test(pacingLapse), "source.pacing-lapse-49", "Pacing MCM must expose a separate 49-piety lapse boundary and resynchronize focused rewards");
  add(/PDV\.Piety[^\r\n]*50\.0/i.test(pacingRecover) && /SyncFirstTierRaceRewardRuntime/i.test(pacingRecover), "source.pacing-recover-50", "Pacing MCM must expose a separate 50-piety recovery boundary and resynchronize focused rewards");
  add(/lastGainDay\s*\+\s*5/i.test(pacingCatchup)
    && /GetBroadPantheonScratch\s*\(\s*poolId\s*\)\s*!=\s*0\.0/i.test(pacingCatchup)
    && /GetActiveBroadPantheonPoolId\s*\(\s*\)\s*==\s*poolId/i.test(pacingCatchup)
    && /ProcessBroadPantheonThroughDay\s*\(\s*poolId\s*,\s*targetDay\s*,\s*signedCap\s*,\s*"mcm_ps_a11_catchup"/i.test(pacingCatchup), "source.ps-a11-production-catchup", "PS-A11 must require a suppressed, settled, real-gain pool and exercise the production catch-up routine through gain day +5");
  add(/_oidPacingBroadCatchup/i.test(mcmSource)
    && /DebugRunBroadPantheonCatchupForPacing\s*\(\s*\)/i.test(mcmSource)
    && /PDV_Manager\.DebugRunBroadPantheonCatchupForPacing\s*\(\s*_selectedBroadPantheonPool\s*\)/i.test(mcmSource), "source.ps-a11-mcm-control", "Pacing MCM must expose the PS-A11 production catch-up control for the selected broad pool");

  return { status: findings.some((item) => item.status === "FAIL") ? "FAIL" : "PASS", findings };
}

function selfTest() {
  const checks = [];
  const expect = (name, ok) => checks.push({ name, ok });
  expect("strongest positive wins", aggregateLogicalEvent([{ delta: 0.4 }, { delta: 2.1 }, { delta: 1.2 }]) === 2.1);
  expect("positive wins over rivalry negative", aggregateLogicalEvent([{ delta: -4 }, { delta: 0.2 }]) === 0.2);
  expect("most severe negative wins without positive", aggregateLogicalEvent([{ delta: -0.4 }, { delta: -2.1 }, { delta: 0 }]) === -2.1);
  expect("ineligible deity is ignored", aggregateLogicalEvent([{ delta: 9, eligible: false }, { delta: 1 }]) === 1);
  expect("empty event is zero", aggregateLogicalEvent([]) === 0);
  expect("positive daily fold caps at 4.3", foldSignedScratch(10, 99) === 14.3);
  expect("negative daily fold caps at -4.3", foldSignedScratch(10, -99) === 5.7);
  expect("pool caps at 50", foldSignedScratch(49, 4.3) === 50);
  expect("pool floors at zero", foldSignedScratch(1, -4.3) === 0);
  expect("decay catches up after grace", elapsedBroadDecayDays(8, 2, 3) === 3);
  expect("decay remains inside grace", elapsedBroadDecayDays(5, 4, 3) === 0);
  expect("negative activity does not also decay on its own day", elapsedBroadDecayDaysWithActivity(5, 4, 0, 5) === 0);
  expect("negative activity preserves later catch-up", elapsedBroadDecayDaysWithActivity(7, 4, 0, 5) === 2);
  expect("positive return preserves past decay", Math.abs(settleReturningBroadAct(10, 2, 5, 0, 0) - 11.8) < 0.0001);
  expect("negative return preserves past decay", Math.abs(settleReturningBroadAct(10, -2, 5, 0, 0) - 7.8) < 0.0001);
  const detachedActionFixture = `
    String eventReason = GetEventReason(eventType)
    PDV_Manager.HandleSubstrateActionEvent(eventType, eventReason)
    Bool detachedBroadEvent = !PDV_Manager.ShouldSurfaceLikesDislikesEvent(eventType)
    String detachedBroadPool = PDV_Manager.GetActiveBroadPantheonPoolId()
    Float broadDelta = PDV_Manager.AwardPietyFromLikesDislikes(deity, delta, eventType, eventReason, detachedBroadEvent, detachedBroadPool)
    PDV_Manager.CommitDetachedBroadPantheonEvent(logicalEventId, detachedBroadPool, bestPositive, worstNegative, eventType)`;
  expect("non-presented action uses detached broad result", hasDetachedActionShape(detachedActionFixture));
  expect("duplicate event-reason lookup is rejected", !hasDetachedActionShape(detachedActionFixture.replace("PDV_Manager.HandleSubstrateActionEvent(eventType, eventReason)", "PDV_Manager.HandleSubstrateActionEvent(eventType, GetEventReason(eventType))")));
  expect("legacy fan-out fixture is rejected", !hasDetachedActionShape("PDV_Manager.BeginLikesDislikesSurface(eventType, logicalEventId)"));
  expect("detached commit cannot borrow the shared scope", hasDetachedCommitShape("ApplyBroadPantheonEventResult(poolId, logicalEventId, chosenDelta)"));
  expect("waiting detached commit is rejected", !hasDetachedCommitShape("BeginBroadPantheonEvent(logicalEventId)\nApplyBroadPantheonEventResult(poolId, logicalEventId, chosenDelta)"));
  const failed = checks.filter((item) => !item.ok).length;
  if (flags.has("--json")) console.log(JSON.stringify({ schema: "pdv.broad-pantheon-audit-self-test.v1", status: failed ? "FAIL" : "PASS", assertions: checks }, null, 2));
  else {
    for (const item of checks) console.log(`[${item.ok ? "PASS" : "FAIL"}] ${item.name}`);
    console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${checks.length} assertions)`);
  }
  process.exitCode = failed ? 1 : 0;
}

function main() {
  let contract;
  try {
    contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
  } catch (error) {
    const report = { schema: "pdv.broad-pantheon-audit.v1", status: "FAIL", contract: path.relative(ROOT, CONTRACT_PATH), findings: [{ status: "FAIL", id: "contract.read", detail: error.message }] };
    console.log(flags.has("--json") ? JSON.stringify(report, null, 2) : `[FAIL] contract.read: ${error.message}`);
    process.exitCode = 2;
    return;
  }
  const managerSource = fs.existsSync(MANAGER_PATH) ? fs.readFileSync(MANAGER_PATH, "utf8") : "";
  const playerEventsSource = fs.existsSync(PLAYER_EVENTS_PATH) ? fs.readFileSync(PLAYER_EVENTS_PATH, "utf8") : "";
  const eventBusSource = fs.existsSync(EVENT_BUS_PATH) ? fs.readFileSync(EVENT_BUS_PATH, "utf8") : "";
  const questReactionRuntimeSource = fs.existsSync(QUEST_REACTION_RUNTIME_PATH) ? fs.readFileSync(QUEST_REACTION_RUNTIME_PATH, "utf8") : "";
  const actionRouterSource = fs.existsSync(ACTION_ROUTER_PATH) ? fs.readFileSync(ACTION_ROUTER_PATH, "utf8") : "";
  const deityBaseSource = fs.existsSync(DEITY_BASE_PATH) ? fs.readFileSync(DEITY_BASE_PATH, "utf8") : "";
  const mcmSource = fs.existsSync(MCM_PATH) ? fs.readFileSync(MCM_PATH, "utf8") : "";
  const result = evaluate({ contract, managerSource, playerEventsSource, eventBusSource, questReactionRuntimeSource, actionRouterSource, deityBaseSource, mcmSource });
  const report = { schema: "pdv.broad-pantheon-audit.v1", contract: path.relative(ROOT, CONTRACT_PATH).replaceAll("\\", "/"), ...result };
  if (flags.has("--json")) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`Broad pantheon audit: ${report.status}`);
    for (const item of report.findings) console.log(`[${item.status}] ${item.id}: ${item.detail}`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
