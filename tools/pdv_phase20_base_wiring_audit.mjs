#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const ROOT = process.cwd();
const LIVE_SOURCE = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";
const EXPECTED_RACES = [
  "Altmer",
  "Argonian",
  "Bosmer",
  "Breton",
  "Dunmer",
  "Imperial",
  "Khajiit",
  "Nord",
  "Orc",
  "Redguard",
];

const p2ManifestPath = path.join(
  ROOT,
  "references",
  "authoring",
  "PDV_Phase20_P2ImmersiveReceivers.manifest.json",
);
const rewardManifestPath = path.join(
  ROOT,
  "references",
  "authoring",
  "PDV_Phase20_RewardRecordContracts.json",
);

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function readLiveSource(fileName) {
  return fs.readFileSync(path.join(LIVE_SOURCE, fileName), "utf8");
}

function routeFunctionName(routeText) {
  const match = String(routeText || "").match(/PDV_EventBus\.([A-Za-z0-9_]+)\(/);
  return match ? match[1] : null;
}

function dispatchFunctionName(dispatchText) {
  const match = String(dispatchText || "").match(/PDV_EventBusService\.([A-Za-z0-9_]+)\(/);
  return match ? match[1] : null;
}

function groupCount(items, keyName) {
  const counts = new Map(EXPECTED_RACES.map((race) => [race, 0]));
  for (const item of items) {
    if (counts.has(item[keyName])) {
      counts.set(item[keyName], counts.get(item[keyName]) + 1);
    }
  }
  return counts;
}

function fail(check, detail) {
  return { status: "FAIL", check, detail };
}

function pass(check, detail) {
  return { status: "PASS", check, detail };
}

const p2Manifest = readJson(p2ManifestPath);
const rewardManifest = readJson(rewardManifestPath);
const managerSource = readLiveSource("PDV__ManagerQuest.psc");
const playerEventsSource = readLiveSource("PDV_PlayerEvents.psc");
const eventBusSource = readLiveSource("PDV_EventBus.psc");

const findings = [];
const sourceProperties = p2Manifest.sourceProperties ?? [];
const routeEntries = p2Manifest.routeEntries ?? [];
const sourceFillEntries = p2Manifest.sourceFillEntries ?? [];
const rewards = rewardManifest.races ?? [];
const propertyToRace = new Map(sourceProperties.map((entry) => [entry.property, entry.race]));

const sourceCounts = groupCount(sourceProperties, "race");
const routeCounts = groupCount(routeEntries, "race");
const rewardCounts = groupCount(rewards, "race");
const fillCounts = new Map(EXPECTED_RACES.map((race) => [race, 0]));
for (const fillEntry of sourceFillEntries) {
  const race = propertyToRace.get(fillEntry.property);
  if (race && fillCounts.has(race)) {
    fillCounts.set(race, fillCounts.get(race) + (fillEntry.sources ?? []).length);
  }
}

for (const race of EXPECTED_RACES) {
  const sourceCount = sourceCounts.get(race);
  const rewardCount = rewardCounts.get(race);
  if (sourceCount > 0) {
    findings.push(pass(`${race} P2 scaffold`, `${sourceCount} receiver property contract(s).`));
  } else {
    findings.push(fail(`${race} P2 scaffold`, "No receiver property contract found."));
  }

  if (rewardCount === 1) {
    findings.push(pass(`${race} reward scaffold`, "One T1 race reward contract found."));
  } else {
    findings.push(fail(`${race} reward scaffold`, `${rewardCount} T1 race reward contract(s) found.`));
  }
}

for (const entry of sourceProperties) {
  if (!playerEventsSource.includes(`FormList Property ${entry.property} Auto`)) {
    findings.push(fail("PlayerEvents receiver property", `${entry.property} missing from PDV_PlayerEvents.psc.`));
  }

  const routeFunction = routeFunctionName(entry.route);
  if (!routeFunction) {
    findings.push(fail("EventBus route contract", `${entry.property} route is not parseable: ${entry.route}`));
  } else if (!eventBusSource.includes(`Function ${routeFunction}(`)) {
    findings.push(fail("EventBus route function", `${routeFunction} missing from PDV_EventBus.psc.`));
  }
}

for (const entry of sourceFillEntries) {
  if (!propertyToRace.has(entry.property)) {
    findings.push(fail("Source fill property", `${entry.property} has fills but no source property contract.`));
  }
}

for (const entry of routeEntries) {
  if (!propertyToRace.has(entry.property)) {
    findings.push(fail("Quest-stage route property", `${entry.property} has route entry but no source property contract.`));
  }

  const dispatchFunction = dispatchFunctionName(entry.dispatch);
  if (!dispatchFunction) {
    findings.push(fail("Quest-stage dispatch", `${entry.id} dispatch is not parseable: ${entry.dispatch}`));
  } else if (!eventBusSource.includes(`Function ${dispatchFunction}(`)) {
    findings.push(fail("Quest-stage dispatch function", `${dispatchFunction} missing from PDV_EventBus.psc.`));
  }
}

for (const reward of rewards) {
  const spell = reward.spellEditorId;
  if (!managerSource.includes(`Spell Property ${spell} Auto`)) {
    findings.push(fail("Manager reward property", `${spell} property missing from PDV__ManagerQuest.psc.`));
  }
  if (!managerSource.includes(`SyncRaceRewardSpell(playerRef, ${spell},`)) {
    findings.push(fail("Manager reward sync", `${spell} is not passed through SyncRaceRewardSpell.`));
  }
  if (!managerSource.includes(`return ${spell}`)) {
    findings.push(fail("Manager active reward selector", `${spell} is not returned by the active reward selector.`));
  }
}

const totals = {
  sourceProperties: sourceProperties.length,
  sourceFillRecords: sourceFillEntries.reduce((count, entry) => count + (entry.sources ?? []).length, 0),
  routeEntries: routeEntries.length,
  rewards: rewards.length,
};
const failures = findings.filter((finding) => finding.status === "FAIL");

const summary = {
  status: failures.length === 0 ? "PASS" : "FAIL",
  totals,
  raceSummary: EXPECTED_RACES.map((race) => ({
    race,
    p2ReceiverContracts: sourceCounts.get(race),
    approvedSourceFillRecords: fillCounts.get(race),
    staticQuestStageRoutes: routeCounts.get(race),
    t1RewardContracts: rewardCounts.get(race),
  })),
  findings,
};

console.log(JSON.stringify(summary, null, 2));
process.exit(failures.length === 0 ? 0 : 1);
