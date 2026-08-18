#!/usr/bin/env node
/*
 * Read-only substrate pacing contract audit.
 *
 * Exit 0 = the authority contract and live Papyrus agree.
 * Exit 1 = one or more contract/runtime gates are RED.
 * Exit 2 = the authority contract could not be read.
 *
 * Flags: --json, --self-test
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_substrate_pacing_audit" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CONTRACT_PATH = path.join(ROOT, "references", "authoring", "PDV_SubstratePacingContracts.json");
const SOURCE_ROOT = path.join(ROOT, "live-source", "Scripts", "Source");
const BASE_PATH = path.join(SOURCE_ROOT, "PDV_SubstrateBase.psc");
const MANAGER_PATH = path.join(SOURCE_ROOT, "PDV__ManagerQuest.psc");
const PLAYER_EVENTS_PATH = path.join(SOURCE_ROOT, "PDV_PlayerEvents.psc");
const EVENT_BUS_PATH = path.join(SOURCE_ROOT, "PDV_EventBus.psc");
const ACTION_ROUTER_PATH = path.join(SOURCE_ROOT, "PDV_ActionRouter.psc");
const MCM_PATH = path.join(SOURCE_ROOT, "PDV_MCM.psc");
const OBSERVE_MOONS_PATH = path.join(SOURCE_ROOT, "PDV_ObserveMoonsEffect.psc");
const EXPECTED = new Map([
  ["imperial", "PDV_Substrate_ImperialAncestor.psc"],
  ["dunmer", "PDV_Substrate_DunmerAncestor.psc"],
  ["argonian", "PDV_Substrate_ArgonianHist.psc"],
  ["nord", "PDV_Substrate_NordAncestor.psc"],
  ["altmer", "PDV_Substrate_AltmerAncestor.psc"],
  ["khajiit", "PDV_Substrate_KhajiitLunar.psc"],
]);
const flags = new Set(process.argv.slice(2));

function norm(value) {
  return String(value ?? "").toLowerCase().replace(/[^a-z0-9]/g, "");
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function getPath(object, dotted) {
  return dotted.split(".").reduce((value, key) => value?.[key], object);
}

function first(object, paths) {
  for (const candidate of paths) {
    const value = getPath(object, candidate);
    if (value !== undefined) return value;
  }
  return undefined;
}

function asRows(contract) {
  const value = first(contract, ["substrates", "races", "raceContracts"]);
  if (Array.isArray(value)) return value;
  if (value && typeof value === "object") {
    return Object.entries(value).map(([race, row]) => ({ race, ...(row ?? {}) }));
  }
  return [];
}

function number(contract, paths) {
  const value = first(contract, paths);
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function hasNumber(source, label, expected) {
  const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`${escaped}\\s*=\\s*${String(expected).replace(".", "\\.")}(?:0+)?\\b`, "i").test(source);
}

function bodyFor(source, functionName) {
  const start = source.search(new RegExp(`(?:(?:Bool|Float|Int|String|Form|Spell)\\s+)?Function\\s+${functionName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndFunction\b/i);
  return end >= 0 ? tail.slice(0, end + 12) : tail;
}

function playerFacingSpineValues(value, here = "$") {
  const hits = [];
  if (Array.isArray(value)) {
    value.forEach((entry, index) => hits.push(...playerFacingSpineValues(entry, `${here}[${index}]`)));
  } else if (value && typeof value === "object") {
    for (const [key, entry] of Object.entries(value)) {
      const child = `${here}.${key}`;
      if (typeof entry === "string" && /(display|player|description|title|label|message|copy|full|name)/i.test(key) && /\bspine\b/i.test(entry)) {
        hits.push(`${child}=${JSON.stringify(entry)}`);
      }
      hits.push(...playerFacingSpineValues(entry, child));
    }
  }
  return hits;
}

function sourceFacingSpine(source, file) {
  const hits = [];
  const lines = source.split(/\r?\n/);
  for (const line of lines) {
    if (!/\bspine\b/i.test(line)) continue;
    if (/Debug\.Notification|\.Show\s*\(|Show[A-Za-z]*Notification|Survey|Prisma|Journal|BookOfDays/i.test(line)) {
      hits.push(`${file}:${line.trim()}`);
    }
  }
  const functionPattern = /(?:Bool|Float|Int|String|Form|Spell|Function)\s+Function\s+([A-Za-z0-9_]+)\s*\([^)]*\)([\s\S]*?)\n\s*EndFunction\b/gi;
  let functionMatch;
  while ((functionMatch = functionPattern.exec(source))) {
    if (!/(Summary|Label|Description|Survey|Prisma|Journal|Book|PlayerFacing|StatusText)/i.test(functionMatch[1])) continue;
    for (const literal of functionMatch[2].matchAll(/"([^"\r\n]*)"/g)) {
      if (/\bspine\b/i.test(literal[1])) hits.push(`${file}:${functionMatch[1]}:${literal[1]}`);
    }
  }
  return hits;
}

export function simulateDailyBudget({ days, grant = 4, cap = 75, attemptsPerDay = 1 }) {
  let metric = 0;
  const history = [];
  for (let day = 0; day < days; day += 1) {
    for (let attempt = 0; attempt < attemptsPerDay; attempt += 1) {
      if (attempt === 0) metric = Math.min(cap, metric + grant);
    }
    history.push(metric);
  }
  return { metric, history };
}

export function devotionalDay(gameDaysPassed) {
  return Math.floor(gameDaysPassed - 0.25);
}

export function countDistinctDevotionalDays(gameTimes) {
  return new Set(gameTimes.map((time) => devotionalDay(time) + 2)).size;
}

export function simulateAcceptedEventSequence(events, grant = 4, cap = 75) {
  let metric = 0;
  let spentStamp = 0;
  let lastAcceptedLogicalEvent = "";
  let lastAcceptedTime = 0;
  const results = [];
  for (const event of events) {
    const stamp = devotionalDay(event.time) + 2;
    const duplicate = spentStamp === stamp && event.logicalEventId === lastAcceptedLogicalEvent;
    const accepted = event.authentic !== false && !duplicate && spentStamp !== stamp;
    if (accepted) {
      spentStamp = stamp;
      lastAcceptedLogicalEvent = event.logicalEventId;
      lastAcceptedTime = event.time;
      metric = Math.min(cap, metric + grant);
    }
    results.push({ accepted, metric, stamp });
  }
  return results;
}

export function simulateDecayCatchup(metric, elapsedDecayDays, rate = 1, floor = 20) {
  return Math.max(floor, metric - (Math.max(0, elapsedDecayDays) * rate));
}

export function evaluate({ contract, baseSource, managerSource, concreteSources, playerEventsSource, eventBusSource, actionRouterSource, mcmSource = "", observeMoonsSource = "" }) {
  const findings = [];
  const add = (ok, id, detail) => findings.push({ status: ok ? "PASS" : "FAIL", id, detail });

  const low = number(contract, ["shared.thresholds.low"]);
  const mid = number(contract, ["shared.thresholds.mid"]);
  const high = number(contract, ["shared.thresholds.high"]);
  const grant = number(contract, ["shared.dailyCredit.amount"]);
  const cap = number(contract, ["shared.positiveMetricCap"]);
  const boundaryText = first(contract, ["shared.devotionalDay.boundaryLocalTime"]);
  const formula = first(contract, ["shared.devotionalDay.formula"]);
  const storedValue = first(contract, ["shared.devotionalDay.storedValue"]);
  const firstOnly = first(contract, ["shared.dailyCredit.firstApprovedActOnly"]);
  const laterReturn = number(contract, ["shared.dailyCredit.laterApprovedActsReturn"]);
  const pietyNeutral = first(contract, ["shared.dailyCredit.pietyNeutral"]);
  const timing = first(contract, ["shared.timing"]) ?? {};
  const rows = asRows(contract);

  add(low === 1 && mid === 25 && high === 75, "contract.thresholds", `expected 1/25/75; got ${low}/${mid}/${high}`);
  add(grant === 4, "contract.daily-grant", `expected +4; got ${grant}`);
  add(cap === 75, "contract.metric-cap", `expected 75; got ${cap}`);
  add(boundaryText === "06:00" && /-\s*0\.25/.test(String(formula)), "contract.day-boundary", `expected 06:00 and floor(GameDaysPassed - 0.25); got ${boundaryText} / ${formula}`);
  add(/devotionalDay\s*\+\s*2/i.test(String(storedValue)) && /legacy \+1 stamps migrate once/i.test(String(storedValue)), "contract.day-stamp", `expected zero-reserved devotionalDay + 2 with legacy +1 migration; got ${storedValue}`);
  add(firstOnly === true && laterReturn === 0, "contract.first-only", `expected first-only/then-zero; got ${firstOnly}/${laterReturn}`);
  add(pietyNeutral === true, "contract.piety-neutral", "substrate daily credit must be piety-neutral");
  add(timing.continuousPracticeDayToMid === 7 && timing.continuousPracticeMetricAtMidDay === 28, "contract.day7", `expected day 7 = 28; got day ${timing.continuousPracticeDayToMid} = ${timing.continuousPracticeMetricAtMidDay}`);
  add(timing.continuousPracticeDayToHigh === 19 && timing.continuousPracticeMetricAtDay18 === 72 && timing.continuousPracticeMetricAtDay19 === 75, "contract.day19", `expected day18/day19 = 72/75 and high on 19; got ${timing.continuousPracticeMetricAtDay18}/${timing.continuousPracticeMetricAtDay19} on ${timing.continuousPracticeDayToHigh}`);
  add(rows.length >= EXPECTED.size, "contract.race-rows", `expected at least ${EXPECTED.size} race contracts; got ${rows.length}`);

  const rowNames = new Set(rows.map((row) => norm(row.race ?? row.origin ?? row.id ?? row.name)));
  for (const [race, file] of EXPECTED) {
    add(rowNames.has(race), `contract.race.${race}`, `${race} must have an authority row`);
    add(concreteSources.has(file), `source.file.${race}`, `${file} must exist`);
  }

  add(hasNumber(baseSource, "LowThreshold", 1), "source.low-threshold", "PDV_SubstrateBase LowThreshold must be 1.0");
  add(hasNumber(baseSource, "MidThreshold", 25), "source.mid-threshold", "PDV_SubstrateBase MidThreshold must be 25.0");
  add(hasNumber(baseSource, "HighThreshold", 75), "source.high-threshold", "PDV_SubstrateBase HighThreshold must be 75.0");
  add(hasNumber(baseSource, "MetricMax", 75), "source.metric-cap", "PDV_SubstrateBase MetricMax must be 75.0");

  const joined = `${baseSource}\n${managerSource}`;
  const dayBody = bodyFor(joined, "GetDevotionalDay");
  const awardFunction = /TryAwardSubstrateDayCredit\s*\(/i.test(joined) ? "TryAwardSubstrateDayCredit" : "TryAwardDailyCredit";
  const awardBody = bodyFor(joined, awardFunction);
  add(Boolean(dayBody), "source.day-helper", "GetDevotionalDay must exist in the shared runtime");
  add(/GetCurrentGameTime\s*\(\s*\)\s*-\s*0\.25\b/i.test(dayBody), "source.day-boundary", "GetDevotionalDay must shift the game clock by 0.25 days (06:00)");
  add(/shiftedTime\s*<\s*0\.0/i.test(dayBody) && /truncatedDay\s*-\s*1/i.test(dayBody), "source.day-zero-floor", "GetDevotionalDay must explicitly floor negative shifted time on game day zero");
  add(Boolean(awardBody), "source.award-helper", "a shared TryAwardSubstrateDayCredit/TryAwardDailyCredit helper must exist");
  const stampBody = bodyFor(baseSource, "GetDevotionalDayStamp");
  const stampMigrationBody = bodyFor(baseSource, "EnsureDailyCreditStampEncoding");
  add(/GetDevotionalDay\s*\(\s*\)\s*\+\s*2\b/i.test(stampBody) && /oldStamp\s*\+\s*1/i.test(stampMigrationBody) && /StampVersion/i.test(stampMigrationBody), "source.day-stamp", "daily credit must reserve zero with devotionalDay+2 and migrate legacy +1 stamps once");
  add(/\b4(?:\.0+)?\b/.test(awardBody) || (/DailyCredit/i.test(awardBody) && hasNumber(baseSource, "DailyCredit", 4)), "source.daily-grant", "daily credit helper must award exactly 4");
  add(/\b75(?:\.0+)?\b/.test(awardBody) || /MetricMax|SetMetric/i.test(awardBody), "source.daily-cap", "daily credit helper must clamp through the 75-point metric maximum");
  add(/IsOriginActive|expectedOrigin|RequiredOriginRace/i.test(awardBody), "source.origin-gate", "daily credit helper must validate origin");
  add(/sourceId/i.test(awardBody) && /logicalEventId/i.test(awardBody), "source.event-identity", "daily credit helper must accept sourceId and logicalEventId");
  add(/IsAuthenticSubstrateSource\s*\(\s*sourceId\s*\)/i.test(awardBody), "source.source-allowlist", "daily credit helper must reject sources outside the concrete substrate allowlist");
  const rejectBody = bodyFor(baseSource, "RecordDailyCreditReject");
  add(/GetLastRejectedLogicalEventKey/i.test(rejectBody) && !/GetLastLogicalEventKey\s*\(/i.test(rejectBody), "source.reject-preserves-accepted", "a rejected event must not overwrite the last accepted logical-event identity");
  const rejectedEventKeyBody = bodyFor(baseSource, "GetLastRejectedLogicalEventKey");
  add(/StorageKeyPrefix\s*\+\s*"\."\s*\+\s*SubstrateName\s*\+\s*"\.LastRejectedLogicalEvent"/i.test(rejectedEventKeyBody), "source.reject-event-key-isolated", "rejected logical-event telemetry must be namespaced per substrate so cross-race probes cannot overwrite one another");

  for (const [file, source] of concreteSources) {
    const race = [...EXPECTED.entries()].find(([, expectedFile]) => expectedFile === file)?.[0];
    const authority = rows.find((row) => norm(row.origin ?? row.race ?? row.id ?? row.name) === race);
    add((authority?.acceptedRenewableFamilies?.length ?? 0) > 0 && (authority?.acceptedFiniteOrExactFamilies?.length ?? 0) > 0, `contract.routes.${file}`, `${file} must have renewable and finite/exact route authority`);
    add(/TryAward(?:SubstrateDayCredit|DailyCredit)\s*\(/i.test(source), `source.route-helper.${file}`, `${file} positive routes must converge on the shared daily-credit helper`);
    const rawCalls = [...source.matchAll(/\bAdjustMetric\s*\(([^,\r\n]+)/gi)]
      .map((match) => match[1].trim())
      .filter((argument) => !/^-/.test(argument));
    add(rawCalls.length === 0, `source.raw-positive.${file}`, rawCalls.length ? `raw positive/ambiguous AdjustMetric calls: ${rawCalls.join(", ")}` : "no raw positive AdjustMetric bypass");
    add(/Bool\s+Function\s+IsAuthenticSubstrateSource/i.test(source), `source.allowlist.${file}`, `${file} must own an explicit authentic-source allowlist`);
  }

  for (const file of ["PDV_Substrate_ImperialAncestor.psc", "PDV_Substrate_ArgonianHist.psc", "PDV_Substrate_NordAncestor.psc", "PDV_Substrate_AltmerAncestor.psc"]) {
    const source = concreteSources.get(file) ?? "";
    add(/decayDays/i.test(source) && /(?:DawnDecay|CulturalDawnDecay)\s*\*\s*decayDays/i.test(source), `source.decay-catchup.${file}`, `${file} must apply all elapsed post-grace decay days, not one dawn only`);
  }

  const productionSource = `${managerSource}\n${playerEventsSource}\n${eventBusSource}\n${actionRouterSource}`;
  const uninstall = bodyFor(managerSource, "PrepareForUninstall");
  const uninstallSubstrateCleanup = bodyFor(managerSource, "ClearAllSubstrateBoonsForUninstall");
  const substrateOwnerProperties = [
    "PDV_ImperialAncestorSubstrate",
    "PDV_BretonAncestorSubstrate",
    "PDV_AltmerAncestorSubstrate",
    "PDV_NordAncestorSubstrate",
    "PDV_DunmerAncestorSubstrate",
    "PDV_KhajiitLunarSubstrate",
    "PDV_ArgonianHistSubstrate",
  ];
  add(/ClearAllSubstrateBoonsForUninstall\s*\(\s*\)/i.test(uninstall), "source.uninstall.substrate-owner-sweep", "PrepareForUninstall must invoke the substrate-owner cleanup sweep");
  add(substrateOwnerProperties.every((propertyName) => new RegExp(`${propertyName}\\.ClearSubstrateBoons\\s*\\(\\s*\\)`, "i").test(uninstallSubstrateCleanup)), "source.uninstall.substrate-owner-coverage", "the uninstall sweep must ask every wired substrate owner to clear its own boons");
  const reachability = [
    ["crafting", /HandleSubstrateActionEvent/i, /smith|enchant|alchem/i],
    ["cooking", /HandleSubstrateActionEvent/i, /cook/i],
    ["open-sky-rest", /EVT_REST_UNDER_OPEN_SKY/i, /RecordAncestralRest|RecordRoadHomeCadence/i],
    ["shrine-prayer", /HandleSubstrateShrinePrayer/i, /Auri-El|AuriEl|Mara/i],
    ["altmer-skill", /magic skill|skill increase|HandleSkillIncrease/i, /AwardAltmerAncestorSpinePulse/i],
    ["altmer-mg08", /MG08|altmer_mg08/i, /AwardAltmerAncestorSpinePulse|HandleAltmerDawnSteadiness/i],
    ["argonian-water", /HandleArgonianSacredWaterDiscovery/i, /RecordCulturalPractice|RecordHistMaintenance/i],
    ["dunmer-honorable", /RouteDunmerHonorableVictory/i, /HandleDunmerHonorableVictory/i],
    ["khajiit-substitutes", /organic_caravan_defense/i, /baandar_reversal|notable_theft|alkosh_milestone/i],
  ];
  for (const [id, ingress, sink] of reachability) add(ingress.test(productionSource) && sink.test(productionSource), `source.production-route.${id}`, `${id} must have both a production ingress and substrate sink`);

  const imperialSleep = bodyFor(managerSource, "HandleImperialSleepEvents");
  const legacyMoon = bodyFor(managerSource, "HandleKhajiitMoonObservance");
  const lunarSubstitute = bodyFor(managerSource, "HandleKhajiitLunarSubstrate");
  const lunarRoute = bodyFor(eventBusSource, "RouteKhajiitLunarSubstrate");
  const roadAnchor = bodyFor(managerSource, "HandleKhajiitRoadHomeAnchor");
  const playerSleepStart = playerEventsSource.match(/Event\s+OnSleepStart\b[\s\S]*?EndEvent/i)?.[0] ?? "";
  const playerSleepStop = playerEventsSource.match(/Event\s+OnSleepStop\b[\s\S]*?EndEvent/i)?.[0] ?? "";
  const sleepRoute = bodyFor(eventBusSource, "RouteSleepStop");
  const sleepManager = bodyFor(managerSource, "HandlePlayerSleepStop");
  const roadHome = bodyFor(managerSource, "HandleKhajiitRoadHome");
  const passiveDawn = bodyFor(managerSource, "HandleAltmerDawnSteadiness");
  add(Boolean(imperialSleep) && !/Award|RecordCivicStanding|TryAward/i.test(imperialSleep), "source.rejected.imperial-sleep", "generic Imperial sleep ingress must remain inert");
  add(Boolean(legacyMoon) && !/ObserveMoonPhase|AwardPiety|TryAward/i.test(legacyMoon), "source.rejected.legacy-moon", "legacy automatic moon ingress must remain inert");
  add(/HandleKhajiitLunarSubstrate\s*\(\s*sourceId\s*\)/i.test(lunarRoute) && /RecordCulturalSubstitute\s*\(\s*"khajiit_lunar_source"/i.test(lunarSubstitute), "source.production-route.khajiit-lunar-curated", "curated Khajiit lunar books/quests must reach the cultural substitute instead of the inert legacy moon ingress");
  add(Boolean(roadAnchor) && !/RecordRoadHomeCadence|AwardPiety|TryAward/i.test(roadAnchor), "source.rejected.road-anchor", "retired Khajiit road anchors must remain inert");
  add(/PDV_HasSleepStartContext\s*=\s*true/i.test(playerSleepStart)
    && /sleepStartedOutside\s*=\s*PDV_LastSleepStartedOutside/i.test(playerSleepStop)
    && /RouteSleepStop\s*\([^\r\n]*hadSleepStartContext[^\r\n]*sleepStartedOutside/i.test(playerSleepStop)
    && /HandlePlayerSleepStop\s*\([^\r\n]*hadSleepStartContext[^\r\n]*sleepStartedOutside/i.test(sleepRoute), "source.khajiit-sleep-context-route", "the player alias must capture exterior state at sleep start and carry it through the event bus");
  add(/hadSleepStartContext/i.test(sleepManager)
    && /sleepStartedOutside/i.test(sleepManager)
    && /HandleKhajiitRoadHome\s*\(/i.test(sleepManager)
    && !/GetParentCell|IsInterior/i.test(sleepManager), "source.khajiit-sleep-start-authority", "Khajiit road-home classification must use captured sleep-start context rather than re-sampling the wake cell");
  add(/PDV\.Khajiit\.RoadHome\.PresentationDay/i.test(roadHome)
    && /ReadZeroReservedDevotionalDayStamp/i.test(roadHome)
    && /WriteZeroReservedDevotionalDayStamp/i.test(roadHome)
    && /grantedMetric\s*>\s*0\.0/i.test(roadHome)
    && /Today's lunar practice was already marked\./i.test(roadHome)
    && /SendPrismaSubstrateToast/i.test(roadHome)
    && /AppendBookOfDaysEntry/i.test(roadHome), "source.khajiit-road-home-presentation", "the first road-home rest each devotional cycle must surface once even when the shared lunar credit was already spent");
  add(Boolean(passiveDawn) && /Passive dawn acknowledgement is piety-only/i.test(passiveDawn) && /StringContainsToken\s*\([^\r\n]*(?:auriel|magnus)/i.test(passiveDawn) && /AwardAltmerAncestorSpinePulse/i.test(passiveDawn), "source.rejected.passive-altmer-dawn", "passive Altmer dawn must remain piety-only while curated finite sources are explicitly token-gated");

  const argonianSource = concreteSources.get("PDV_Substrate_ArgonianHist.psc") ?? "";
  const dunmerSource = concreteSources.get("PDV_Substrate_DunmerAncestor.psc") ?? "";
  const histDecay = bodyFor(argonianSource, "ProcessHistDistanceDawn");
  add(/HistDawnDecay\s*\*\s*decayDays/i.test(histDecay) && /graceEndDay/i.test(histDecay), "source.argonian-relation-decay-catchup", "the separate Hist relation ledger must catch up every elapsed post-grace decay day");
  const histMaintenance = bodyFor(argonianSource, "RecordHistMaintenanceScaled");
  const histMaintenanceStamp = bodyFor(argonianSource, "StampHistMaintenance");
  const histNeglect = bodyFor(managerSource, "IsArgonianHistNeglected");
  add(/StampHistMaintenance\s*\(/i.test(histMaintenance)
    && /LastMaintenanceStamp[^\r\n]*GetDevotionalDay\(\)\s*\+\s*2/i.test(histMaintenanceStamp)
    && /MaintenanceStampVersion[^\r\n]*1/i.test(histMaintenanceStamp)
    && /HasHistMaintenance/i.test(histNeglect)
    && /GetLastHistMaintenanceDevotionalDay/i.test(histNeglect)
    && !/LastHistSourceTime/i.test(histNeglect), "source.argonian-maintenance-clock", "all Hist neglect timing must use the substrate-owned +2 maintenance stamp (legacy +1 migration removed on the not-save-safe V3 sweep)");

  const bedSleep = bodyFor(managerSource, "TryArgonianBedOfChoiceSleep");
  add(/rootedRestStamp\s*=\s*GetDevotionalDay\(\)\s*\+\s*2/i.test(bedSleep)
    && /ReadZeroReservedDevotionalDayStamp\s*\(\s*"PDV\.Argonian\.RootedRestDay"\s*\)\s*!=\s*rootedRestStamp/i.test(bedSleep)
    && /WriteZeroReservedDevotionalDayStamp\s*\(\s*"PDV\.Argonian\.RootedRestDay"\s*\)/i.test(bedSleep), "source.argonian-rooted-rest-once-per-day", "Rooted Rest cast and toast must be guarded by a zero-reserved devotional-day stamp");
  add(/Int\s+todayStamp\s*=\s*GetDevotionalDay\(\)\s*\+\s*2/i.test(bedSleep)
    && /candidateDay\s*!=\s*todayStamp/i.test(bedSleep)
    && /PDV\.ArgBed\.CandidateDay[^\r\n]*todayStamp/i.test(bedSleep)
    && /PDV\.ArgBed\.DeclineDay[^\r\n]*todayStamp/i.test(bedSleep)
    && !/Utility\.GetCurrentGameTime\(\)\s+as\s+Int/i.test(bedSleep), "source.argonian-bed-devotional-day", "bed declaration and decline cadence must use the canonical zero-reserved 06:00 devotional-day stamp");
  const bedReturn = bodyFor(argonianSource, "RecordBedOfChoiceReturnScaled");
  add(/sleepStamp\s*=\s*GetDevotionalDay\(\)\s*\+\s*2/i.test(bedReturn)
    && /BedOfChoiceSleepDay[^\r\n]*!=\s*sleepStamp/i.test(bedReturn)
    && /AdjustIntValue\s*\([^\r\n]*BedOfChoiceSleepCount[^\r\n]*1/i.test(bedReturn)
    && /BedOfChoiceSleepDay[^\r\n]*sleepStamp/i.test(bedReturn), "source.argonian-bed-count-once-per-day", "the twelve-sleep Rooted Rest counter must advance at most once per devotional day");
  const setArgonianHome = bodyFor(managerSource, "SetArgonianHome");
  const syncAdaptation = bodyFor(managerSource, "SyncArgonianAdaptation");
  add(!/ClearArgonianAdaptation|RemoveArgonianAdaptationSpells/i.test(setArgonianHome)
    && /PDV\.Adapt\.Active[^\r\n]*==\s*0/i.test(setArgonianHome)
    && !/GetMetric|HIGH_THRESHOLD|HighThreshold/i.test(syncAdaptation)
    && /HasSpell\s*\(\s*activeSpell\s*\)/i.test(syncAdaptation), "source.argonian-adaptation-permanent", "home changes must preserve a chosen adaptation, and dawn sync must restore it without re-gating ownership on metric 75");

  const dunmerCombat = bodyFor(managerSource, "RecordDunmerCombatVictoryEvidence");
  const dunmerStory = bodyFor(managerSource, "RecordDunmerStoryVictoryEvidence");
  const dunmerResolve = bodyFor(managerSource, "TryResolveDunmerHonorableVictory");
  const legacyDunmer = bodyFor(managerSource, "HandleDunmerHonorableVictory");
  add(/CombatSessionActive/i.test(playerEventsSource) && /CombatStartedSneaking/i.test(playerEventsSource) && /CombatObservedSneaking/i.test(playerEventsSource) && /RouteDunmerHonorableVictory/i.test(playerEventsSource), "source.dunmer-clean-opener", "player-alias evidence must require direct kill plus a clean non-stealth combat opener");
  add(/HonorableCombatVictim/i.test(dunmerCombat) && /relationshipRank\s*>\s*-2/i.test(dunmerStory) && /HonorableStoryVictim/i.test(dunmerStory) && /HonorableCombatVictim/i.test(dunmerResolve) && /HonorableStoryVictim/i.test(dunmerResolve) && /aiCrimeStatus\s*==\s*0\s*&&\s*aiRelationshipRank\s*<=\s*-2[\s\S]*RecordDunmerStoryVictoryEvidence\s*\([^\r\n]*aiRelationshipRank/i.test(actionRouterSource), "source.dunmer-two-sided-provenance", "Dunmer victory must intersect clean combat evidence with pre-existing enemy rank and non-murder Story Manager evidence");
  add(/RecordDunmerCombatVictoryEvidence/i.test(legacyDunmer) && !/RecordPortableShrinePrayer|TryAward|AdjustMetric/i.test(legacyDunmer), "source.dunmer-canonical-safe", "the canonical Dunmer victory ingress may record only one evidence half and must not award directly");

  const nearWater = bodyFor(managerSource, "TryArgonianNearWaterMaintenance");
  const moonRite = bodyFor(managerSource, "CompleteKhajiitMoonObservation");
  const moonBegin = bodyFor(managerSource, "BeginKhajiitMoonObservation");
  const moonComplete = bodyFor(managerSource, "ProcessPendingKhajiitMoonObservation");
  const moonPower = bodyFor(managerSource, "EnsureKhajiitObserveMoonsPower");
  const surveyPower = bodyFor(managerSource, "EnsureSurveyDevotionPower");
  const moonPresentation = bodyFor(managerSource, "ShowKhajiitMoonContemplation");
  const sacredWater = bodyFor(managerSource, "AwardArgonianSacredWater");
  const sapVision = bodyFor(managerSource, "HandleArgonianSapVision");
  const dunmerPortable = bodyFor(managerSource, "HandleDunmerPortableShrinePrayer");
  const dunmerHome = bodyFor(managerSource, "HandleDunmerPlayerHomeBonus");
  add(/ReadZeroReservedDevotionalDayStamp/i.test(nearWater) && /WriteZeroReservedDevotionalDayStamp/i.test(nearWater) && /GetDevotionalDay\s*\(\s*\)\s*\+\s*2/i.test(nearWater), "source.day-zero.argonian-water", "Argonian water credit must use the zero-reserved +2 devotional-day stamp");
  add(/ReadZeroReservedDevotionalDayStamp/i.test(moonRite) && /WriteZeroReservedDevotionalDayStamp/i.test(moonRite) && /GetDevotionalDay\s*\(\s*\)\s*\+\s*2/i.test(moonRite), "source.day-zero.khajiit-moon-piety", "Khajiit moon piety must use the zero-reserved +2 devotional-day stamp");
  add(/observationToken\s*=\s*PDV_Manager\.BeginKhajiitMoonObservation\s*\(\s*(?:akTarget|playerActor)\s*\)/i.test(observeMoonsSource)
    && /observationToken\s*>\s*0[\s\S]*Utility\.Wait\s*\(\s*2\.0\s*\)[\s\S]*ProcessPendingKhajiitMoonObservation\s*\(\s*observationToken\s*\)/i.test(observeMoonsSource)
    && /_khajiitMoonObservationGeneration\s*\+=\s*1/i.test(moonBegin)
    && /observationToken\s*!=\s*_khajiitMoonObservationGeneration/i.test(moonComplete)
    && /_khajiitMoonObservationPending\s*=\s*False/i.test(moonComplete)
    && /<\s*2\.0/i.test(moonComplete), "source.khajiit-moon-token", "Observe the Moons must complete exactly one two-second delayed generation token and reject stale completions");
  add(/AddSpell\s*\(\s*PDV_Power_Khajiit_ObserveMoons/i.test(moonPower)
    && /RemoveSpell\s*\(\s*PDV_Power_Khajiit_ObserveMoons/i.test(moonPower)
    && !/\bEquipSpell\s*\(\s*PDV_Power_Khajiit_ObserveMoons/i.test(moonPower), "source.khajiit-moon-power-slot", "Observe the Moons must be granted and removed by origin without ever selecting the player's lesser power through EquipSpell");
  add(/AddSpell\s*\(\s*PDV_Power_Khajiit_ObserveMoons/i.test(moonPower)
    && /AddSpell\s*\(\s*PDV_SPEL_SurveyDevotion/i.test(surveyPower)
    && !/\bEquipSpell\s*\(/i.test(moonPower)
    && !/\bEquipSpell\s*\(/i.test(surveyPower), "source.shared-lesser-power-selection", "Survey Devotion and Observe the Moons must be granted-only peer lesser powers; Papyrus must not attempt to select either through a hand-only EquipSpell call");
  add(/SendPrismaToast\s*\(/i.test(moonPresentation)
    && /AppendBookOfDaysEntry\s*\(/i.test(moonPresentation)
    && !/\.Show\s*\(/i.test(moonPresentation), "source.khajiit-moon-prisma", "Moon contemplations must use non-blocking Prisma plus one first-rite Book of Days entry, never a vanilla MessageBox");
  add(/_dunmerHomePrayerContext\s*=\s*True/i.test(dunmerPortable) && /!_dunmerHomePrayerContext/i.test(dunmerHome) && /IsPlayerAtDunmerDeclaredHome/i.test(dunmerHome) && /requires_paired_home_prayer/i.test(dunmerHome), "source.dunmer-home-paired", "home prayer must require the paired portable-prayer context and declared home");
  add((dunmerSource.match(/TryAwardSubstrateDayCredit\([^\r\n]*normalizedMultiplier/gi) ?? []).length >= 2, "source.dunmer-curse-weight", "Dunmer portable and home prayer must preserve the explicit curse weight into daily credit");
  add(/RecordCulturalPractice/i.test(sacredWater) && /AwardCuratedSignalScaled\s*\(\s*PDV_Hist/i.test(sacredWater), "source.argonian-sacred-water-piety", "sacred water must grant cultural credit and Hist piety exactly once");
  add(/RecordCulturalPractice/i.test(sapVision) && /AwardCuratedSignalScaled\s*\(\s*PDV_Hist/i.test(sapVision), "source.argonian-sap-piety", "Sleeping Tree Sap must grant cultural credit and Hist piety exactly once");
  add(/StampHistMaintenance\s*\(\s*"sacred_water_"\s*\+\s*siteFormId\s*\)/i.test(sacredWater)
    && /StampHistMaintenance\s*\(\s*"sleeping_tree_sap"\s*\)/i.test(sapVision), "source.argonian-hist-contact-clock", "sacred water and Sleeping Tree Sap must both refresh the shared Hist-maintenance clock without adding the routine +5 relation pulse");

  const substrateProgressCalls = managerSource.split(/\r?\n/).filter((line) => /SendPrismaSubstrateProgress\s*\(/i.test(line) && !/Function\s+SendPrismaSubstrateProgress/i.test(line));
  add(substrateProgressCalls.length >= 19 && substrateProgressCalls.every((line) => /(?:[A-Za-z0-9_]+\.)?GetMetric\(\)\s*-\s*metricBefore|metricAfter\s*-\s*metricBefore|grantedMetric/i.test(line))
    && /Float\s+grantedMetric\s*=\s*PDV_KhajiitLunarSubstrate\.GetMetric\(\)\s*-\s*metricBefore/i.test(roadHome), "source.actual-substrate-delta", "every substrate progress producer must report the actual post-award metric delta, including a same-day zero, rather than its requested multiplier");

  const pacingTrigger = bodyFor(managerSource, "DebugTriggerSubstratePacingSource");
  const genuineHandlers = [
    "HandleImperialCivicService", "HandleSubstrateShrinePrayer",
    "HandleDunmerPortableShrinePrayer", "HandleDunmerReclamationFocus",
    "HandleArgonianHistMaintenance", "HandleArgonianPeopleSupport",
    "HandleNordOldWaysState", "HandleSubstrateActionEvent",
    "HandleAltmerMagicSkillIncrease", "HandleKhajiitRoadHome", "HandleKhajiitLunarSubstrate",
  ];
  add(genuineHandlers.every((handler) => new RegExp(`\\b${handler}\\s*\\(`, "i").test(pacingTrigger))
    && !/PDV_[A-Za-z0-9_]*Substrate\.(?:RecordCivicStanding|RecordPortableShrinePrayer|RecordCulturalPractice|RecordAncestorStanding|RecordHeritageStanding|RecordRoadHomeCadence|ObserveMoonPhase)\s*\(/i.test(pacingTrigger), "source.pacing-production-handlers", "approved MCM pacing probes must enter genuine manager production handlers rather than award directly through substrate scripts");

  const pacingPage = bodyFor(mcmSource, "BuildPacingPantheonsPage");
  const applyOrigin = bodyFor(mcmSource, "DebugApplySubstratePacingOrigin");
  add(/Debug:\s*Pacing\s*&\s*Pantheons/i.test(mcmSource) && /BuildPacingPantheonsPage/i.test(mcmSource), "mcm.pacing-page", "MCM must expose the developer-only pacing and pantheons page");
  add(/Apply test origin/i.test(pacingPage) && /Trigger approved source/i.test(pacingPage) && /Reset substrate/i.test(pacingPage), "mcm.substrate-controls", "pacing page must expose explicit origin application, true-handler trigger, and reset controls");
  add(/DebugSetCurseProofOriginRace\s*\(\s*originValue\s*\)/i.test(applyOrigin) && /GetSelectedSubstratePacingOriginValue/i.test(applyOrigin), "mcm.apply-origin", "the selected pacing race must explicitly become the throwaway save's test origin before true-handler proof");
  add(/Use real wait and dawn/i.test(pacingPage) && !/advance day/i.test(pacingPage), "mcm.no-artificial-day", "pacing page must require real wait/dawn and expose no artificial advance-day control");
  add(/Seed 0/i.test(pacingPage) && /Seed 24/i.test(pacingPage) && /Seed 25/i.test(pacingPage) && /Seed 74/i.test(pacingPage) && /Seed 75/i.test(pacingPage), "mcm.substrate-boundaries", "pacing page must expose the locked substrate boundary seeds");
  add(/Signed fan-out test/i.test(pacingPage) && /Prepare patron offer/i.test(pacingPage) && /Lapse patron to 49/i.test(pacingPage) && /Recover patron to 50/i.test(pacingPage), "mcm.pantheon-controls", "pacing page must expose fan-out and focused transition controls");

  const seven = simulateDailyBudget({ days: 7, grant: grant ?? 0, cap: cap ?? 0, attemptsPerDay: 5 });
  const eighteen = simulateDailyBudget({ days: 18, grant: grant ?? 0, cap: cap ?? 0, attemptsPerDay: 5 });
  const nineteen = simulateDailyBudget({ days: 19, grant: grant ?? 0, cap: cap ?? 0, attemptsPerDay: 5 });
  add(seven.metric === 28 && seven.history[5] === 24, "math.day7", `day6/day7 must be 24/28; got ${seven.history[5]}/${seven.metric}`);
  add(eighteen.metric === 72 && nineteen.metric === 75, "math.day19", `day18/day19 must be 72/75; got ${eighteen.metric}/${nineteen.metric}`);
  add(simulateDailyBudget({ days: 1, grant: grant ?? 0, cap: cap ?? 0, attemptsPerDay: 99 }).metric === 4, "math.spam", "99 same-day attempts must still award only 4");
  const xYx = simulateAcceptedEventSequence([
    { time: 0.26, logicalEventId: "X" },
    { time: 0.27, logicalEventId: "Y", authentic: false },
    { time: 1.26, logicalEventId: "X" },
  ], grant ?? 0, cap ?? 0);
  add(xYx[0].accepted && !xYx[1].accepted && xYx[2].accepted && xYx[2].metric === 8, "math.rejected-event-identity", "X accepted / Y rejected / X next dawn must award 4 twice without a false duplicate");
  add(devotionalDay(0.0) === -1 && devotionalDay(0.249) === -1 && devotionalDay(0.25) === 0, "math.day-zero-floor", "day zero must encode pre-06:00 as devotional day -1 and 06:00 as day 0");
  add((devotionalDay(0.0) + 2) === 1 && (devotionalDay(0.25) + 2) === 2, "math.day-zero-stamp", "reserved-zero stamps must encode pre-06:00 as 1 and post-06:00 as 2");
  add(countDistinctDevotionalDays([0.9965, 1.0035]) === 1 && countDistinctDevotionalDays([1.2465, 1.2535]) === 2, "math.argonian-bed-boundary", "23:55/00:05 must be one bed day while 05:55/06:05 crosses the devotional boundary");
  const altmerRite = bodyFor(managerSource, "TryAltmerDisciplinesRite");
  add(/GetDevotionalDay\s*\(\s*\)\s*\+\s*2/i.test(altmerRite) && /LastDeclineDay/i.test(altmerRite), "source.altmer-decline-day-zero", "Altmer Not Yet reprompt stamps must reserve zero before the first 06:00 boundary");
  add(simulateDecayCatchup(30, 4) === 26 && simulateDecayCatchup(22, 9) === 20, "math.decay-catchup", "multi-day decay must catch up and respect the floor");

  const contractSpine = playerFacingSpineValues(contract);
  add(contractSpine.length === 0, "copy.contract-spine", contractSpine.length ? contractSpine.join("; ") : "no player-facing Spine in the contract");
  const sourceSpine = [];
  for (const [file, source] of concreteSources) sourceSpine.push(...sourceFacingSpine(source, file));
  sourceSpine.push(...sourceFacingSpine(managerSource, "PDV__ManagerQuest.psc"));
  add(sourceSpine.length === 0, "copy.source-spine", sourceSpine.length ? sourceSpine.slice(0, 12).join("; ") : "no sentence-like Spine literals in live source");

  return { status: findings.some((item) => item.status === "FAIL") ? "FAIL" : "PASS", findings };
}

function selfTest() {
  const result = [];
  const expect = (name, ok) => result.push({ name, ok });
  const sim = simulateDailyBudget({ days: 19, attemptsPerDay: 50 });
  expect("day 1 spam is capped at 4", sim.history[0] === 4);
  expect("day 6 is 24", sim.history[5] === 24);
  expect("day 7 is 28", sim.history[6] === 28);
  expect("day 18 is 72", sim.history[17] === 72);
  expect("day 19 is capped at 75", sim.history[18] === 75);
  expect("zero days is zero", simulateDailyBudget({ days: 0 }).metric === 0);
  const xYx = simulateAcceptedEventSequence([
    { time: 0.26, logicalEventId: "X" },
    { time: 0.27, logicalEventId: "Y", authentic: false },
    { time: 1.26, logicalEventId: "X" },
  ]);
  expect("rejected event does not poison next-day duplicate identity", xYx[0].accepted && !xYx[1].accepted && xYx[2].accepted && xYx[2].metric === 8);
  expect("day zero floor is explicit", devotionalDay(0.0) === -1 && devotionalDay(0.25) === 0);
  expect("day zero stamps never resemble unset", devotionalDay(0.0) + 2 === 1 && devotionalDay(0.25) + 2 === 2);
  expect("midnight does not create another bed day", countDistinctDevotionalDays([0.9965, 1.0035]) === 1);
  expect("06:00 creates another bed day", countDistinctDevotionalDays([1.2465, 1.2535]) === 2);
  expect("four missed decay days catch up", simulateDecayCatchup(30, 4) === 26);
  expect("decay catch-up respects floor", simulateDecayCatchup(22, 9) === 20);
  const failed = result.filter((item) => !item.ok).length;
  if (flags.has("--json")) console.log(JSON.stringify({ schema: "pdv.substrate-pacing-audit-self-test.v1", status: failed ? "FAIL" : "PASS", assertions: result }, null, 2));
  else {
    for (const item of result) console.log(`[${item.ok ? "PASS" : "FAIL"}] ${item.name}`);
    console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${result.length} assertions)`);
  }
  process.exitCode = failed ? 1 : 0;
}

function main() {
  let contract;
  try {
    contract = JSON.parse(read(CONTRACT_PATH));
  } catch (error) {
    const report = { schema: "pdv.substrate-pacing-audit.v1", status: "FAIL", contract: path.relative(ROOT, CONTRACT_PATH), findings: [{ status: "FAIL", id: "contract.read", detail: error.message }] };
    console.log(flags.has("--json") ? JSON.stringify(report, null, 2) : `[FAIL] contract.read: ${error.message}`);
    process.exitCode = 2;
    return;
  }

  const concreteSources = new Map();
  for (const file of EXPECTED.values()) {
    const filePath = path.join(SOURCE_ROOT, file);
    if (fs.existsSync(filePath)) concreteSources.set(file, read(filePath));
  }
  const result = evaluate({
    contract,
    baseSource: fs.existsSync(BASE_PATH) ? read(BASE_PATH) : "",
    managerSource: fs.existsSync(MANAGER_PATH) ? read(MANAGER_PATH) : "",
    concreteSources,
    playerEventsSource: fs.existsSync(PLAYER_EVENTS_PATH) ? read(PLAYER_EVENTS_PATH) : "",
    eventBusSource: fs.existsSync(EVENT_BUS_PATH) ? read(EVENT_BUS_PATH) : "",
    actionRouterSource: fs.existsSync(ACTION_ROUTER_PATH) ? read(ACTION_ROUTER_PATH) : "",
    mcmSource: fs.existsSync(MCM_PATH) ? read(MCM_PATH) : "",
    observeMoonsSource: fs.existsSync(OBSERVE_MOONS_PATH) ? read(OBSERVE_MOONS_PATH) : "",
  });
  const report = { schema: "pdv.substrate-pacing-audit.v1", contract: path.relative(ROOT, CONTRACT_PATH).replaceAll("\\", "/"), ...result };
  if (flags.has("--json")) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`Substrate pacing audit: ${report.status}`);
    for (const item of report.findings) console.log(`[${item.status}] ${item.id}: ${item.detail}`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
