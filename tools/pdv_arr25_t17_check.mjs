#!/usr/bin/env node
/* Read-only ARR 2.5 T17 source/channel/package contract gate. */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const failures = [];
const passes = [];
const at = (...parts) => path.join(ROOT, ...parts);

function read(file) {
  if (!fs.existsSync(file)) { failures.push(`missing file: ${path.relative(ROOT, file)}`); return ""; }
  return fs.readFileSync(file, "utf8");
}

function parseCsv(text) {
  const rows = []; let row = [], field = "", quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i += 1; }
      else if (ch === '"') quoted = false;
      else field += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  const nonblank = rows.filter((cells) => cells.some((cell) => cell.trim()));
  const header = nonblank.shift() ?? [];
  return nonblank.map((cells) => Object.fromEntries(header.map((name, i) => [name, cells[i] ?? ""])));
}

function requireEqual(label, actual, expected) {
  if (JSON.stringify(actual) === JSON.stringify(expected)) passes.push(label);
  else failures.push(`${label}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
}

function validateCsv(label, file, expectedRows, expectedKeys, plugin) {
  const rows = parseCsv(read(file));
  requireEqual(`${label} row count`, rows.length, expectedRows);
  requireEqual(`${label} outcome keys`, [...new Set(rows.map((r) => `${r.editor_id}|${r.outcome_stage}`))].sort(), [...expectedKeys].sort());
  if (rows.every((r) => r.formid.endsWith(`:${r.formid.split(":").at(-1)}`) && r.formid.startsWith(`${plugin}:`))) passes.push(`${label} canonical FormKeys`);
  else failures.push(`${label}: noncanonical FormKey`);
  return rows;
}

function validateJson(label, file, cells, keys) {
  const data = JSON.parse(read(file));
  const questKeys = data.stringList?.questKeys ?? [];
  const cellCount = Object.entries(data.stringList ?? {})
    .filter(([key]) => /^quest\..+\.deities$/.test(key))
    .reduce((sum, [, values]) => sum + values.length, 0);
  requireEqual(`${label} compiled key count`, questKeys.length, keys);
  requireEqual(`${label} compiled cell count`, cellCount, cells);
}

const lotdKeys = ["DBM_Excavation03A|350", "DBM_EchosOfMadness|100", "DBM_MuchAdoAboutSnowElves|398"];
const brumaKeys = ["CYRBrumaMS01|30", "CYRBrumaMS01|50", "CYRBrumaMS01|150", "CYRBrumaMS04|100", "CYRBrumaMS04|160", "CYRBrumaMS04|170", "CYRFortPalePassMS01New|600", "CYRBrumaMS07|120"];
const wyrmNewKeys = ["WTTheNakedNord|50", "WTTheNakedNord|56", "WTTheNakedNord|75", "WTTheNakedNord|76", "WTTheNakedNord|77", "WTTheNakedNord|78", "WTTheNakedNord|79", "WTUberEncounter|50", "WTSignyFavor|30", "WTDaenlitFavor|30", "WTKillThalmor|30"];

validateCsv("LOTD", at("references/authoring/patches/PDV_QRM_LegacyOfTheDragonborn.csv"), 19, lotdKeys, "LegacyoftheDragonborn.esm");
validateCsv("Bruma", at("references/authoring/patches/PDV_QRM_BeyondSkyrimBruma.csv"), 54, brumaKeys, "BSHeartland.esm");
const wyrm = parseCsv(read(at("references/authoring/patches/PDV_QRM_Wyrmstooth.csv")));
requireEqual("Wyrmstooth cumulative row count", wyrm.length, 76);
requireEqual("Wyrmstooth T17 key set", [...new Set(wyrm.filter((r) => wyrmNewKeys.includes(`${r.editor_id}|${r.outcome_stage}`)).map((r) => `${r.editor_id}|${r.outcome_stage}`))].sort(), [...wyrmNewKeys].sort());

validateJson("LOTD", at("dist/PDV_QuestModPatches_FOMOD/common/LegacyOfTheDragonborn/SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/PDV_QRM_LegacyOfTheDragonborn.json"), 19, 3);
validateJson("Bruma", at("dist/PDV_QuestModPatches_FOMOD/common/BeyondSkyrimBruma/SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/PDV_QRM_BeyondSkyrimBruma.json"), 54, 8);
validateJson("Wyrmstooth", at("dist/PDV_QuestModPatches_FOMOD/common/Wyrmstooth/SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/PDV_QRM_Wyrmstooth.json"), 76, 12);

const ledger = JSON.parse(read(at("references/authoring/PDV_ARR25_T17_RuntimeEvidenceLedger.json")));
requireEqual("T17 ledger case count", ledger.cases?.length, 22);
requireEqual("T17 ledger remains open", ledger.status, "OPEN");
if (ledger.cases?.every((c) => c.verdict === "OPEN")) passes.push("all T17 support cases remain open");
else failures.push("T17 ledger contains premature non-OPEN verdict");

for (const [prefix, candidates, conflicts] of [["T17LOTD", 20, 0], ["T17Bruma", 27, 2], ["T17Wyrmstooth", 8, 0]]) {
  requireEqual(`${prefix} final candidate count`, parseCsv(read(at(`references/authoring/generated/PDV_QuestCrossGen_${prefix}_Candidates.csv`))).length, candidates);
  requireEqual(`${prefix} conflict count`, parseCsv(read(at(`references/authoring/generated/PDV_QuestCrossGen_${prefix}_Conflicts.csv`))).length, conflicts);
}

const xml = read(at("dist/PDV_QuestModPatches_FOMOD/fomod/ModuleConfig.xml"));
for (const token of ["common\\LegacyOfTheDragonborn", "common\\BeyondSkyrimBruma", "LegacyoftheDragonborn.esm", "BSHeartland.esm", "all thirty-four data channels"]) {
  if (xml.includes(token)) passes.push(`FOMOD contains ${token}`); else failures.push(`FOMOD missing ${token}`);
}
const receipt = JSON.parse(read(at("references/authoring/PDV_QuestModPatches_FOMOD_Validation.json")));
requireEqual("package receipt PASS", receipt.status, "PASS");
requireEqual("package channel count", receipt.optionCounts?.channelFiles, 34);
requireEqual("package individual count", receipt.optionCounts?.individualContentOptions, 34);

console.log(JSON.stringify({
  status: failures.length ? "FAIL" : "PASS",
  passes: passes.length,
  failures,
  proofBoundary: "Static source/channel/package proof only; runtime routing, semantic observation, player surfaces, and support remain open.",
}, null, 2));
process.exitCode = failures.length ? 1 : 0;
