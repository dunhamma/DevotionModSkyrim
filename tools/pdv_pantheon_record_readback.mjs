#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { familySourceText } from "./lib/pdv_symbol_home.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_pantheon_record_readback" });

const ROOT = process.cwd();
const SOURCE_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const json = process.argv.includes("--json");
const findings = [];
const pass = (check, detail) => findings.push({ status: "PASS", check, detail });
const fail = (check, detail) => findings.push({ status: "FAIL", check, detail });

const imperialGods = ["Akatosh", "Mara", "Arkay", "Stendarr", "Zenithar", "Dibella", "Julianos", "Kynareth", "Talos"];
const expectedProperties = [
  ...imperialGods.flatMap((god) => [1, 2, 3].map((tier) => `PDV_Bless_Imperial_${god}_T${tier}`)),
  ...[1, 2, 3].map((tier) => `PDV_Bless_Nord_Talos_T${tier}`),
  "PDV_Bless_Nord_NineDivines_T1",
  "PDV_Bless_Nord_NineDivines_T2",
];

// Appended manager VMAD properties (Nine Divines, Observe-Moons, QuestReaction, etc.)
// sit beyond houseCARL's bounded generic container expansion. Request the explicit
// manager-module window through property 515 and resolve the values BY NAME
// (parseProperties maps Name->Object). Widen this window when new manager properties land.
const MANAGER_PROPERTY_WINDOW = Array.from({ length: 75 }, (_, i) => `VirtualMachineAdapter.Scripts[0].Properties[${440 + i}]`);

function normalizeFormKey(value) {
  const match = String(value ?? "").trim().match(/^([0-9A-Fa-f]{6}):(.+)$/);
  return match ? `${match[1].toUpperCase()}:${match[2].toLowerCase()}` : String(value ?? "").trim().toLowerCase();
}

function parseInventory(text) {
  const rows = new Map();
  for (const match of String(text).matchAll(/formid=([0-9A-Fa-f]{6}:[^\s]+)\s+editorid=(PDV_Bless_(?:Imperial_[A-Za-z]+|Nord_Talos|Nord_NineDivines)_T[123])/g)) {
    rows.set(match[2], match[1]);
  }
  return rows;
}

function parseProperties(text, prefix = "VirtualMachineAdapter.Scripts[0].Properties") {
  const names = new Map();
  const out = new Map();
  const escaped = prefix.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  for (const line of String(text).split(/\r?\n/)) {
    const name = line.match(new RegExp(`${escaped}\\[(\\d+)\\](?:\\.Name)?\\s*=.*?Name=(PDV_[A-Za-z0-9_]+)`));
    if (name) names.set(name[1], name[2]);
    const scalarName = line.match(new RegExp(`${escaped}\\[(\\d+)\\]\\.Name\\s*=\\s*(PDV_[A-Za-z0-9_]+)`));
    if (scalarName) names.set(scalarName[1], scalarName[2]);
  }
  for (const line of String(text).split(/\r?\n/)) {
    const object = line.match(new RegExp(`${escaped}\\[(\\d+)\\]\\.Object\\s*=\\s*([0-9A-Fa-f]{6}:[^\\s\\r\\n]+)`));
    if (object && names.has(object[1])) out.set(names.get(object[1]), object[2]);
  }
  return out;
}

function functionBlock(source, functionName) {
  const match = source.match(new RegExp(`(?:^|\\n)Function\\s+${functionName}\\b[\\s\\S]*?\\nEndFunction`, "i"));
  return match?.[0] ?? "";
}

async function main() {
  // Search the whole decomposition family, not just the manager: functions extracted
  // into deep modules would otherwise read as absent and every needle below would fail.
  const source = familySourceText(ROOT, SOURCE_DIR);
  const inventoryResult = await callHousecarl("housecarl_cross_plugin_query", {
    plugins: ["Devotion.esp"], type: "SPEL", editorid_contains: "PDV_Bless_", fields: ["EditorID"], limit: 500, max_chars: 120_000,
  });
  const inventory = parseInventory(extractHousecarlText(inventoryResult));
  const managerResult = await callHousecarl("housecarl_read_record", {
    formid: "00C325:Devotion.esp", fields: [
      "VirtualMachineAdapter.Scripts[0].Properties",
      ...MANAGER_PROPERTY_WINDOW,
    ], depth: 3, max_chars: 400_000,
  }, { timeoutMs: 90_000 });
  const managerProperties = parseProperties(extractHousecarlText(managerResult));
  const appendedResult = await callHousecarl("housecarl_batch_record_detail", {
    formids: ["00C325:Devotion.esp"],
    fields: MANAGER_PROPERTY_WINDOW,
    depth: 3,
    max_chars: 180_000,
  }, { timeoutMs: 90_000 });
  const appendedProperties = parseProperties(extractHousecarlText(appendedResult));
  for (const [name, target] of appendedProperties) managerProperties.set(name, target);

  for (const property of expectedProperties) {
    const record = inventory.get(property);
    if (!record) fail("focused reward record", `${property} is missing as SPEL from the live winning Devotion.esp.`);
    else pass("focused reward record", `${property} resolves to ${record}.`);
    const wired = managerProperties.get(property);
    if (!wired) fail("focused reward VMAD", `${property} is unbound on PDV__ManagerQuest.`);
    else if (record && normalizeFormKey(wired) !== normalizeFormKey(record)) fail("focused reward VMAD", `${property} points at ${wired}, expected ${record}.`);
    else pass("focused reward VMAD", `${property} is bound to ${wired}.`);
    if (!source.includes(`Spell Property ${property} Auto`)) fail("focused reward source", `${property} is not declared in manager source.`);
  }

  const nordSync = functionBlock(source, "SyncNordRewards");
  const nordFamilySync = functionBlock(source, "SyncNordRewardFamily");
  const nordReuse = ["Akatosh", "Mara", "Arkay", "Stendarr", "Zenithar", "Dibella", "Julianos", "Kynareth"];
  for (const god of nordReuse) {
    const expectedCall = `PDV_Bless_Imperial_${god}_T1, PDV_Bless_Imperial_${god}_T2, PDV_Bless_Imperial_${god}_T3`;
    if (nordSync.includes(expectedCall)) pass("Nord Nine Divines reuse", `${god} uses the canonical Imperial focused family inside SyncNordRewards.`);
    else fail("Nord Nine Divines reuse", `${god} does not route through the canonical Imperial focused family.`);
  }
  if (nordFamilySync.includes("SyncRaceRewardSpell(playerRef, t1, False") && nordFamilySync.includes("activePiety >= 50.0") && nordFamilySync.includes("activePiety >= 85.0")) {
    pass("focused tier contract", "Focused T1 is compatibility-only; T2 starts at 50 and T3 starts at 85.");
  } else {
    fail("focused tier contract", "Focused reward synchronization does not visibly enforce compatibility-only T1 and 50/85 thresholds.");
  }

  const substrateResult = await callHousecarl("housecarl_batch_record_detail", {
    formids: ["04C8A4:Devotion.esp", "04C8A6:Devotion.esp"], fields: ["EditorID", "VirtualMachineAdapter.Scripts"], depth: 5, max_chars: 100_000,
  });
  const substrateText = extractHousecarlText(substrateResult);
  for (const editorId of ["PDV_Substrate_KhajiitLunar", "PDV_Substrate_ArgonianHist"]) {
    const block = substrateText.split(/(?=\r?\ntype=Quest\s)/i).find((part) => part.includes(`editorid=${editorId}`)) || "";
    for (const scriptIndex of [0, 1]) {
      for (const property of ["Substrate_Always", "Substrate_Mid", "Substrate_High"]) {
        const token = new RegExp(`Scripts\\[${scriptIndex}\\]\\.Properties\\[\\d+\\].*Name=${property}[\\s\\S]*?Scripts\\[${scriptIndex}\\]\\.Properties\\[\\d+\\]\\.Object\\s*=\\s*[0-9A-Fa-f]{6}:Devotion\\.esp`);
        if (token.test(block)) pass("substrate inherited VMAD", `${editorId} script ${scriptIndex} binds ${property}.`);
        else fail("substrate inherited VMAD", `${editorId} script ${scriptIndex} is missing ${property}.`);
      }
    }
  }

  const [visibleNameResult, visibleDescriptionResult, histSpellResult, histEffectsResult] = await Promise.all([
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], where: ["Name contains Spine"], fields: ["EditorID", "Name"], limit: 100, max_chars: 30_000 }),
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], where: ["Description contains Spine"], fields: ["EditorID", "Description"], limit: 100, max_chars: 30_000 }),
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], type: "SPEL", editorid_contains: "Neglect_ArgonianHist", fields: ["EditorID", "Name"], limit: 20, max_chars: 20_000 }),
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], type: "MGEF", editorid_contains: "Neglect_ArgonianHist", fields: ["EditorID", "Name"], limit: 20, max_chars: 20_000 }),
  ]);
  const visibleText = `${extractHousecarlText(visibleNameResult)}\n${extractHousecarlText(visibleDescriptionResult)}`;
  if (!/cross_plugin_query:\s*[1-9]\d* matches/i.test(visibleText)) pass("player-visible Spine cleanup", "Winning Devotion.esp Name and Description fields contain zero Spine matches.");
  else fail("player-visible Spine cleanup", visibleText);

  const histText = `${extractHousecarlText(histSpellResult)}\n${extractHousecarlText(histEffectsResult)}`;
  const histNames = new Map();
  for (const block of histText.split(/(?=type=(?:Spell|MagicEffect)\b)/i)) {
    const editorId = block.match(/\beditorid=(PDV_(?:SPEL|MGEF)_Neglect_ArgonianHist(?:_Health|_HealRate)?)\b/i)?.[1];
    const name = block.match(/^\s*Name\s*=\s*(.+)$/im)?.[1]?.trim();
    if (editorId && name) histNames.set(editorId, name);
  }
  const expectedHistNames = [
    "PDV_SPEL_Neglect_ArgonianHist",
    "PDV_MGEF_Neglect_ArgonianHist_Health",
    "PDV_MGEF_Neglect_ArgonianHist_HealRate",
  ];
  for (const editorId of expectedHistNames) {
    const name = histNames.get(editorId);
    if (name === "The Hist Silenced") pass("Hist Silenced naming", `${editorId} has exact player-facing name The Hist Silenced.`);
    else fail("Hist Silenced naming", `${editorId} has Name=${name || "missing"}; expected The Hist Silenced, including the retired compatibility effect.`);
  }

  const failures = findings.filter((finding) => finding.status === "FAIL");
  const report = { status: failures.length ? "FAIL" : "PASS", assertions: findings.length, failures: failures.length, findings };
  if (json) console.log(JSON.stringify(report, null, 2));
  else {
    for (const finding of findings) console.log(`[${finding.status}] ${finding.check}: ${finding.detail}`);
    console.log(`Summary: ${report.status}; ${report.assertions} assertions; ${report.failures} failures`);
  }
  process.exitCode = failures.length ? 1 : 0;
}

main().catch((error) => {
  console.log(JSON.stringify({ status: "FAIL", assertions: findings.length, failures: 1, error: error.stack || error.message, findings }, null, 2));
  process.exitCode = 1;
});
