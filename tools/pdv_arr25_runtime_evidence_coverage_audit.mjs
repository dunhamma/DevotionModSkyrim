#!/usr/bin/env node
/*
 * Read-only coverage gate for ARR 2.5 runtime-evidence ledgers.
 *
 * A reaction matrix has one row per deity cell, while runtime testing owes one
 * observation per distinct quest outcome. This gate compares outcome keys
 * (plugin + form ID + stage), not cell counts. It also accepts Skyrim.esm as
 * the canonical owner when a quest-expansion overrides a vanilla quest.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const AUTHORING = path.join(ROOT, "references", "authoring");
const PATCHES = path.join(AUTHORING, "patches");
const EXPECTED_OUTCOMES = 72;

const CSV_SOURCES = [
  "PDV_QRM_Wyrmstooth.csv",
  "PDV_QRM_TasteOfDeathAddon.csv",
  "PDV_QRM_SiegeAtIcemoth.csv",
  "PDV_QRM_HuntForSpectre.csv",
  "PDV_QRM_CallingTheWatchmaker.csv",
  "PDV_QRM_GiftOfSaturalia.csv",
  "PDV_QRM_Thogra.csv",
  "PDV_QRM_Auri.csv",
  "PDV_QRM_Mrissi.csv",
  "PDV_QRM_Xelzaz.csv",
  "PDV_QRM_Moonpath.csv",
  "PDV_QRM_CollegeQuestExpansion.csv",
  "PDV_QRM_InfiltrationQE.csv",
  "PDV_QRM_NilheimQE.csv",
  "PDV_QRM_WhisperingDoorQE.csv",
  "PDV_QRM_PaarthurnaxQE.csv",
  "PDV_QRM_ForswornConspiracyQE.csv",
  "PDV_QRM_TGAlternativeEndings.csv",
  "PDV_QRM_SaveTheIcerunner.csv",
  "PDV_QRM_LegacyOfTheDragonborn.csv",
  "PDV_QRM_BeyondSkyrimBruma.csv",
];

const LEDGERS = ["T13", "T14", "T15", "T16", "T17"];
const CREATION_CLUB = {
  "T13-002": "ccBGSSSE067_Quest2",
  "T13-003": "ccASVSSE001_QuestE",
  "T13-004": "ccMTYSSE001_Quest",
};

const result = audit();
console.log(JSON.stringify(result, null, 2));
process.exitCode = result.status === "PASS" ? 0 : 1;

function audit() {
  const sourceOutcomes = collectSourceOutcomes();
  const ledgerOutcomes = collectLedgerOutcomes(sourceOutcomes);
  const nonquest = checkNonquestLedger();

  const sourceDuplicates = duplicateKeys(sourceOutcomes.map((entry) => entry.key));
  const ledgerDuplicates = duplicateKeys(ledgerOutcomes.map((entry) => entry.key));
  const sourceKeys = new Set(sourceOutcomes.map((entry) => entry.key));
  const ledgerKeys = new Set(ledgerOutcomes.map((entry) => entry.key));
  const missing = [...sourceKeys].filter((key) => !ledgerKeys.has(key)).sort();
  const orphan = [...ledgerKeys].filter((key) => !sourceKeys.has(key)).sort();
  const issues = [
    ...sourceOutcomes.filter((entry) => entry.error).map((entry) => entry.error),
    ...ledgerOutcomes.filter((entry) => entry.error).map((entry) => entry.error),
    ...nonquest.issues,
  ];

  const pass = sourceOutcomes.length === EXPECTED_OUTCOMES
    && ledgerOutcomes.length === EXPECTED_OUTCOMES
    && sourceDuplicates.length === 0
    && ledgerDuplicates.length === 0
    && missing.length === 0
    && orphan.length === 0
    && issues.length === 0;

  return {
    check: "arr25RuntimeEvidenceCoverage",
    status: pass ? "PASS" : "FAIL",
    expectedOutcomes: EXPECTED_OUTCOMES,
    matrixOutcomes: sourceOutcomes.length,
    ledgerOutcomes: ledgerOutcomes.length,
    missing,
    duplicate: { matrix: sourceDuplicates, ledger: ledgerDuplicates },
    orphan,
    nonquest: nonquest.summary,
    issues,
  };
}

function collectSourceOutcomes() {
  const outcomes = [];
  for (const filename of CSV_SOURCES) {
    const rows = parseCsv(read(path.join(PATCHES, filename)));
    for (const row of distinctRows(rows, (item) => matrixOutcomeKey(item))) {
      outcomes.push({ key: matrixOutcomeKey(row), source: filename });
    }
  }

  // These three Creation Club outcomes were promoted into the core CSV. That
  // source has no formid column, so its editor ID is its stable outcome key.
  const ccRows = parseCsv(read(path.join(AUTHORING, "PDV_QuestReactionMatrix_CreationClubCore_2026-08-07.csv")));
  const wanted = new Set(Object.values(CREATION_CLUB));
  for (const row of distinctRows(ccRows.filter((item) => wanted.has(item.editor_id)), (item) => matrixOutcomeKey(item))) {
    outcomes.push({ key: matrixOutcomeKey(row), source: "PDV_QuestReactionMatrix_CreationClubCore_2026-08-07.csv" });
  }
  return outcomes;
}

function collectLedgerOutcomes(sourceOutcomes) {
  const sourceByFormAndStage = new Map();
  for (const source of sourceOutcomes) {
    const parts = source.key.split("|");
    if (parts[0] !== "form") continue;
    const lookup = `${parts[2]}|${parts[3]}`;
    const entries = sourceByFormAndStage.get(lookup) ?? [];
    entries.push(source.key);
    sourceByFormAndStage.set(lookup, entries);
  }

  const outcomes = [];
  for (const tranche of LEDGERS) {
    const ledger = readJson(path.join(AUTHORING, `PDV_ARR25_${tranche}_RuntimeEvidenceLedger.json`));
    for (const entry of ledger.cases ?? []) {
      const ccEditorId = CREATION_CLUB[entry.id];
      if (ccEditorId) {
        outcomes.push({ key: `editor|${ccEditorId.toLowerCase()}|${entry.stage}`, ledger: entry.id });
        continue;
      }

      // T16 records physical stage 200 but the adapter routes it to 201/202.
      const stage = entry.resolvedStage ?? entry.stage;
      const lookup = `${normalizeHex(entry.localFormId)}|${stage}`;
      const candidates = sourceByFormAndStage.get(lookup) ?? [];
      const exactPlugin = normalizePlugin(entry.plugin);
      const key = candidates.find((candidate) => candidate.split("|")[1] === exactPlugin)
        // Skyrim.esm is the intentional canonical owner for vanilla overrides.
        ?? candidates.find((candidate) => candidate.split("|")[1] === "skyrim.esm");
      outcomes.push(key
        ? { key, ledger: entry.id }
        : { key: `unresolved|${entry.id}`, ledger: entry.id, error: `${entry.id}: no matrix outcome for ${entry.plugin}:${entry.localFormId} stage ${stage}` });
    }
  }
  return outcomes;
}

function checkNonquestLedger() {
  const ledger = readJson(path.join(AUTHORING, "PDV_ARR25_NonQuest_RuntimeEvidenceLedger.json"));
  const afdi = ledger.afdiCases ?? [];
  const other = ledger.otherCases ?? [];
  const shrine = other.filter((entry) => String(entry.id).startsWith("NQ-SHRINE-"));
  const supportedShrines = shrine.filter((entry) => /^NQ-SHRINE-0(?:0[1-9]|1[01])$/.test(entry.id));
  const jyggalag = shrine.filter((entry) => entry.id === "NQ-SHRINE-012");
  const wyrmstooth = shrine.filter((entry) => entry.id === "NQ-SHRINE-013");
  const issues = [];
  if (afdi.length !== 30) issues.push(`AFDI cases ${afdi.length}; expected 30`);
  if (other.length !== 19) issues.push(`other cases ${other.length}; expected 19`);
  if (shrine.length !== 13) issues.push(`shrine cases ${shrine.length}; expected 13`);
  if (supportedShrines.length !== 11 || jyggalag.length !== 1 || wyrmstooth.length !== 1) {
    issues.push(`shrine split ${supportedShrines.length} supported / ${jyggalag.length} Jyggalag negative / ${wyrmstooth.length} Wyrmstooth non-inheritance; expected 11 / 1 / 1`);
  }
  return { summary: { afdi: afdi.length, other: other.length, shrine: shrine.length, supportedShrines: supportedShrines.length, jyggalagNegative: jyggalag.length, wyrmstoothNonInheritance: wyrmstooth.length }, issues };
}

function matrixOutcomeKey(row) {
  const stage = String(row.outcome_stage ?? "").trim();
  if (row.formid) {
    const [plugin, formId] = row.formid.split(":");
    return `form|${normalizePlugin(plugin)}|${normalizeHex(formId)}|${stage}`;
  }
  return `editor|${String(row.editor_id ?? "").trim().toLowerCase()}|${stage}`;
}

function parseCsv(text) {
  const rows = [];
  let cell = "";
  let row = [];
  let quoted = false;
  const pushRow = () => { rows.push(row); row = []; };
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (quoted) {
      if (char === '"' && text[index + 1] === '"') { cell += '"'; index += 1; }
      else if (char === '"') quoted = false;
      else cell += char;
    } else if (char === '"') quoted = true;
    else if (char === ",") { row.push(cell); cell = ""; }
    else if (char === "\n") { row.push(cell.replace(/\r$/, "")); cell = ""; pushRow(); }
    else cell += char;
  }
  if (cell.length || row.length) { row.push(cell.replace(/\r$/, "")); pushRow(); }
  const [header, ...data] = rows;
  return data.filter((values) => values.some((value) => value !== "")).map((values) => Object.fromEntries(header.map((name, index) => [name, values[index] ?? ""])));
}

function distinctRows(rows, keyFor) {
  const seen = new Set();
  return rows.filter((row) => {
    const key = keyFor(row);
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function duplicateKeys(keys) {
  const count = new Map();
  for (const key of keys) count.set(key, (count.get(key) ?? 0) + 1);
  return [...count].filter(([, occurrences]) => occurrences > 1).map(([key]) => key).sort();
}

function normalizePlugin(plugin) { return String(plugin ?? "").trim().toLowerCase(); }
function normalizeHex(value) { return String(value ?? "").trim().replace(/^0x/i, "").toUpperCase().padStart(6, "0"); }
function read(file) { return fs.readFileSync(file, "utf8"); }
function readJson(file) { return JSON.parse(read(file)); }
