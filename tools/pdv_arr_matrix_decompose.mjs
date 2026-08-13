#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

import { sameTextToString, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

// Refuse unrecognised flags. These tools read argv with includes()/indexOf(), so an
// unknown or mistyped flag would otherwise fall through to a default and the run would
// SUCCEED against something the caller never asked for. Matches the pdv_arr25_* convention.
const KNOWN_FLAGS = new Set(["--write"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}


const ARR_SOURCE = "archive/PDV_QuestReactionMatrix_ARR_source_2026-08-07.csv";
const CC_TARGET = "references/authoring/PDV_QuestReactionMatrix_CreationClubCore_2026-08-07.csv";
const CHANNELS = new Map([
  ["DAc0da.esm", "PDV_QRM_DAc0da.csv"],
  ["EbonyBladeCurse.esp", "PDV_QRM_EbonyBladeCurse.csv"],
  ["ForgottenCity.esp", "PDV_QRM_ForgottenCity.csv"],
  ["Glenmoril.esm", "PDV_QRM_Glenmoril.csv"],
  ["Olenveld.esp", "PDV_QRM_Olenveld.csv"],
  ["Skyrim Extended Cut - Saints and Seducers.esp", "PDV_QRM_SkyrimExtendedCutSaintsAndSeducers.csv"],
  ["Unslaad.esm", "PDV_QRM_Unslaad.csv"],
  ["Vigilant.esm", "PDV_QRM_Vigilant.csv"],
]);
const CHANNEL_DIR = "references/authoring/patches";
const write = process.argv.includes("--write");

function parseCsvLine(line) {
  const cells = [];
  let current = "";
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const character = line[index];
    if (quoted && character === '"' && line[index + 1] === '"') {
      current += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      cells.push(current);
      current = "";
    } else {
      current += character;
    }
  }
  cells.push(current);
  return cells;
}

function readCsv(file) {
  const lines = fs.readFileSync(file, "utf8").replace(/^\uFEFF/, "").split(/\r?\n/).filter((line) => line.trim());
  return { header: lines[0], rows: lines.slice(1) };
}

function canonicalKey(line, header) {
  const columns = parseCsvLine(header);
  const row = parseCsvLine(line);
  const formId = row[columns.indexOf("formid")]?.trim().toLowerCase();
  const stage = row[columns.indexOf("outcome_stage")]?.trim();
  const deity = row[columns.indexOf("deity")]?.trim().toLowerCase();
  if (!formId || !stage || !deity) throw new Error(`Malformed matrix row: ${line}`);
  return `${formId}|${stage}|${deity}`;
}

function assertUnique(rows, header, label) {
  const seen = new Set();
  for (const row of rows) {
    const key = canonicalKey(row, header);
    if (seen.has(key)) throw new Error(`${label} duplicate natural key: ${key}`);
    seen.add(key);
  }
  return seen;
}

function expectedText(header, rows) {
  return `${header}\n${rows.join("\n")}\n`;
}

function reconcileFile(file, expected, label) {
  if (write) {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    writeTextWithEol(file, expected, "lf");
    return;
  }
  if (!fs.existsSync(file)) throw new Error(`${label} missing: ${file}`);
  if (!sameTextToString(file, expected)) throw new Error(`${label} drift: ${file}`);
}

const arr = readCsv(ARR_SOURCE);
const arrColumns = parseCsvLine(arr.header);
const formIdIndex = arrColumns.indexOf("formid");
if (formIdIndex < 0) throw new Error(`${ARR_SOURCE} has no formid column`);
const groups = new Map([...CHANNELS.keys()].map((plugin) => [plugin, []]));
for (const row of arr.rows) {
  const formId = parseCsvLine(row)[formIdIndex]?.trim();
  const plugin = formId?.split(":")[0];
  if (!groups.has(plugin)) throw new Error(`Unmapped ARR plugin: ${plugin || "<missing>"}`);
  groups.get(plugin).push(row);
}

const arrKeys = assertUnique(arr.rows, arr.header, "ARR source");
const decomposedRows = [];
for (const [plugin, fileName] of CHANNELS) {
  const rows = groups.get(plugin);
  if (!rows.length) throw new Error(`Mapped ARR plugin has no rows: ${plugin}`);
  assertUnique(rows, arr.header, fileName);
  decomposedRows.push(...rows);
  reconcileFile(path.join(CHANNEL_DIR, fileName), expectedText(arr.header, rows), fileName);
}
const decomposedKeys = assertUnique(decomposedRows, arr.header, "decomposed channels");
if (arrKeys.size !== decomposedKeys.size || [...arrKeys].some((key) => !decomposedKeys.has(key))) {
  throw new Error("ARR source and decomposed channel natural-key sets differ");
}

const ccRows = readCsv(CC_TARGET).rows;
if (ccRows.length !== 14) throw new Error(`Creation Club promotion expected 14 cells, found ${ccRows.length}`);

console.log(JSON.stringify({
  status: "PASS",
  mode: write ? "write" : "check",
  arrCells: arr.rows.length,
  channelCount: CHANNELS.size,
  channelCells: Object.fromEntries([...groups].map(([plugin, rows]) => [plugin, rows.length])),
  creationClubCells: ccRows.length,
}, null, 2));
