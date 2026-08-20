#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

import { devotionSource } from "./lib/pdv_paths.mjs";

const DEVOTION_SOURCE = devotionSource();
const REPO_ROOT = process.cwd();
const REPO_SOURCE = path.join(REPO_ROOT, "live-source", "Scripts", "Source");

const sourceRoot = fs.existsSync(DEVOTION_SOURCE) ? DEVOTION_SOURCE : REPO_SOURCE;

const failures = [];
const passes = [];

function fail(check, detail, source = "") {
  failures.push({ check, detail, source });
}

function pass(check, detail, source = "") {
  passes.push({ check, detail, source });
}

function readSource(name) {
  const livePath = path.join(sourceRoot, name);
  if (fs.existsSync(livePath)) {
    return { path: livePath, text: fs.readFileSync(livePath, "utf8") };
  }
  const repoPath = path.join(REPO_SOURCE, name);
  return { path: repoPath, text: fs.readFileSync(repoPath, "utf8") };
}

function functionBlock(source, functionName) {
  const pattern = new RegExp(`(?:Bool\\s+)?Function\\s+${functionName}\\b[\\s\\S]*?EndFunction`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
}

function hasLegacyOptOut(source) {
  const block = functionBlock(source, "ShouldSyncLegacyPatronBoons");
  return block.includes("return False");
}

function hasTierClearPath(source) {
  const block = functionBlock(source, "OnTierChange");
  return block.includes("Parent.OnTierChange(") || block.includes("ClearAllBoons()") || block.includes("ClearLegacy");
}

function hasPatronStartClearPath(source) {
  const block = functionBlock(source, "OnPatronStart");
  return block.includes("Parent.OnPatronStart()") || block.includes("ClearAllBoons()") || block.includes("ClearLegacy");
}

if (!fs.existsSync(sourceRoot)) {
  fail("Source root", "Devotion source root is missing.", sourceRoot);
} else {
  pass("Source root", "Devotion source root found.", sourceRoot);
}

const base = readSource("PDV_DeityBase.psc");
if (!base.text.includes("if !ShouldSyncLegacyPatronBoons()")) {
  fail("Legacy boon base gate", "PDV_DeityBase must gate old cumulative Boon_* grants behind ShouldSyncLegacyPatronBoons().", base.path);
} else {
  pass("Legacy boon base gate", "PDV_DeityBase gates old cumulative Boon_* grants.", base.path);
}

const manager = readSource("PDV__ManagerQuest.psc");
const managerOwnedFamilies = [
  ["Altmer Auri-El", "SyncAltmerRewardFamily(playerRef, PDV_AuriEl, PDV_Bless_Altmer_AuriEl_T1, PDV_Bless_Altmer_AuriEl_T2, PDV_Bless_Altmer_AuriEl_T3"],
  ["Nord Kyne", "SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Kyne, PDV_Bless_Nord_Kyne_T1, PDV_Bless_Nord_Kyne_T2, PDV_Bless_Nord_Kyne_T3"],
  ["Nord Talos", "SyncNordRewardFamily(playerRef, -1, PDV_Talos, PDV_Bless_Nord_Talos_T1, PDV_Bless_Nord_Talos_T2, PDV_Bless_Nord_Talos_T3"],
  ["Imperial Talos", "SyncImperialRewardFamily(playerRef, PDV_Talos, PDV_Bless_Imperial_Talos_T1, PDV_Bless_Imperial_Talos_T2, PDV_Bless_Imperial_Talos_T3"],
];

for (const [label, needle] of managerOwnedFamilies) {
  if (!manager.text.includes(needle)) {
    fail("Manager-owned race reward family", `${label} reward family is not routed through the manager.`, manager.path);
  } else {
    pass("Manager-owned race reward family", `${label} reward family is routed through the manager.`, manager.path);
  }
}

const overlappingLegacyDeities = [
  ["Auri-El", "PDV_Deity_AuriEl.psc"],
  ["Kyne", "PDV_Deity_Kyne.psc"],
  ["Talos", "PDV_Deity_Talos.psc"],
];

for (const [label, fileName] of overlappingLegacyDeities) {
  const source = readSource(fileName);
  if (!hasLegacyOptOut(source.text)) {
    fail("Legacy overlap opt-out", `${label} must opt out of old cumulative Boon_* grants because current rewards are manager-owned race families.`, source.path);
  } else {
    pass("Legacy overlap opt-out", `${label} opts out of old cumulative Boon_* grants.`, source.path);
  }

  if (!hasTierClearPath(source.text)) {
    fail("Legacy overlap tier clear", `${label} tier changes must clear old Boon_* spells rather than leaving stale saves dirty.`, source.path);
  } else {
    pass("Legacy overlap tier clear", `${label} tier changes clear old Boon_* spells.`, source.path);
  }

  if (!hasPatronStartClearPath(source.text)) {
    fail("Legacy overlap patron-start clear", `${label} patron start must clear old Boon_* spells rather than re-granting them.`, source.path);
  } else {
    pass("Legacy overlap patron-start clear", `${label} patron start clears old Boon_* spells.`, source.path);
  }
}

const daedricBase = readSource("PDV_DaedricPathBase.psc");
const daedricSync = functionBlock(daedricBase.text, "SyncPatronBoonsToTier");
if (!daedricSync.includes("IsActiveDaedricPact()") || !daedricSync.includes("elseIf tierValue >= TIER_DEVOTED")) {
  fail("Daedric pact boon ownership", "Daedric pact boons must remain exclusive active-pact rewards, not legacy cumulative patron boons.", daedricBase.path);
} else {
  pass("Daedric pact boon ownership", "Daedric pact boons remain exclusive active-pact rewards.", daedricBase.path);
}

if (daedricBase.text.includes("ShouldSyncLegacyPatronBoons")) {
  fail("Daedric pact opt-out", "DaedricPathBase should not use the Aedric legacy opt-out hook; it owns a separate pact spell contract.", daedricBase.path);
} else {
  pass("Daedric pact opt-out", "DaedricPathBase does not use the Aedric legacy opt-out hook.", daedricBase.path);
}

const result = {
  schema: "pdv.legacy-boon-overlap-audit.v1",
  sourceRoot,
  counts: {
    PASS: passes.length,
    FAIL: failures.length,
  },
  findings: [
    ...failures.map((finding) => ({ status: "FAIL", ...finding })),
    ...passes.map((finding) => ({ status: "PASS", ...finding })),
  ],
};

console.log(JSON.stringify(result, null, 2));

if (failures.length > 0) {
  process.exitCode = 1;
}
