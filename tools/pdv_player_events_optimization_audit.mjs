#!/usr/bin/env node
// Static acceptance gate for the save-compatible PDV_PlayerEvents 1.0.4 tranche.
// Runtime overlap and absent-plugin log proof remain separate manual gates.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE =
  process.env.PDV_PLAYER_EVENTS_SOURCE ||
  path.join(REPO_ROOT, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
const failures = [];
const passes = [];

function requireToken(source, token, label) {
  if (source.includes(token)) {
    passes.push(label);
  } else {
    failures.push(`${label}: missing ${token}`);
  }
}

if (!fs.existsSync(SOURCE)) {
  console.error(`[FAIL] PDV_PlayerEvents source is missing: ${SOURCE}`);
  process.exit(1);
}

const source = fs.readFileSync(SOURCE, "utf8");
const singleUpdateCalls = [...source.matchAll(/\bRegisterForSingleUpdate\s*\(/g)].length;
if (singleUpdateCalls === 1) {
  passes.push("Exactly one native RegisterForSingleUpdate call remains.");
} else {
  failures.push(`Expected exactly one RegisterForSingleUpdate call; found ${singleUpdateCalls}.`);
}

for (const [token, label] of [
  ["Float PDV_ORIGIN_NEXT_DUE", "Origin lane has an explicit next deadline."],
  ["Float PDV_COMBAT_NEXT_DUE", "Combat lane has an explicit next deadline."],
  ["Float PDV_BARD_NEXT_DUE", "Bard lane has an explicit next deadline."],
  ["Function ArmEarliestDeadline", "One scheduler owns native update registration."],
  ["Function GetEarliestPendingDeadline", "Scheduler selects the earliest outstanding lane."],
  ["PDV_UPDATE_DISPATCHING = true", "OnUpdate defers lane re-arm while dispatching."],
  ["PDV_UPDATE_DISPATCHING = false", "OnUpdate releases the dispatch barrier before arming."],
  ['Game.IsPluginInstalled("BecomeABard.esp")', "Become a Bard lookup is plugin-guarded."],
  [
    'Game.IsPluginInstalled("SkyrimsGotTalent-Bards.esp")',
    "Skyrim's Got Talent lookup is plugin-guarded.",
  ],
  ["if !PDV_BardFormsResolved", "Bard form resolution is cached once per load."],
  ["PDV_BardFormsResolved = false", "Bard form cache resets on load."],
]) {
  requireToken(source, token, label);
}

const armStart = source.indexOf("Function ArmEarliestDeadline");
const armEnd = source.indexOf("EndFunction", armStart);
const registerPosition = source.indexOf("RegisterForSingleUpdate(");
if (armStart >= 0 && armEnd > armStart && registerPosition > armStart && registerPosition < armEnd) {
  passes.push("The sole RegisterForSingleUpdate call is inside ArmEarliestDeadline.");
} else {
  failures.push("RegisterForSingleUpdate is not exclusively owned by ArmEarliestDeadline.");
}

const becomeGuard = source.indexOf('if Game.IsPluginInstalled("BecomeABard.esp")');
const becomeLookup = source.indexOf('Game.GetFormFromFile(0x00051223, "BecomeABard.esp")');
const sgtGuard = source.indexOf('if Game.IsPluginInstalled("SkyrimsGotTalent-Bards.esp")');
const sgtLookup = source.indexOf(
  'Game.GetFormFromFile(0x00000D62, "SkyrimsGotTalent-Bards.esp")',
);
if (becomeGuard >= 0 && becomeLookup > becomeGuard && sgtGuard >= 0 && sgtLookup > sgtGuard) {
  passes.push("Optional plugin checks precede every optional lookup block.");
} else {
  failures.push("An optional bard GetFormFromFile lookup is not preceded by its plugin guard.");
}

for (const message of passes) console.log(`[PASS] ${message}`);
for (const message of failures) console.error(`[FAIL] ${message}`);
console.log(
  `PDV_PlayerEvents optimization audit: ${passes.length} passed, ${failures.length} failed.`,
);
if (failures.length) process.exit(1);
