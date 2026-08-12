#!/usr/bin/env node
// Durable progress authority for the exhaustive official-content quest audit.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set([
  "--check", "--validate", "--set", "--formid", "--field", "--value",
  "--scope", "--tranche", "--shard", "--json",
]);
assertKnownFlags(process.argv.slice(2).filter((arg) => arg.startsWith("--")), KNOWN_FLAGS, {
  toolName: "pdv_core_quest_audit_checkpoint",
});

const argv = process.argv.slice(2);
const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const compat = path.join(repo, "references", "vanilla-gameplay", "compatibility");
const inventoryPath = path.join(compat, "PDV_CoreQuestAuditInventory.json");
const worklistPath = path.join(compat, "PDV_CoreQuestAuditWorklist.csv");
const checkpointPath = path.join(compat, "PDV_CoreQuestAuditCheckpoint.csv");
const CHECKPOINT_HEADER = [
  "work_id", "scope", "audit_tranche", "audit_shard", "risk_priority", "formid", "editor_id",
  "canonical_source_plugin", "direct_read", "classification", "deep_read", "owner_verdict",
  "tagged_rows", "crossgen", "promoted", "post_readback", "notes",
];
const SETTABLE = new Map([
  ["direct_read", new Set(["-", "ok", "partial", "error"])],
  ["classification", new Set(["UNREVIEWED", "STRUCTURAL-SILENT", "SEMANTIC-SILENT", "CANDIDATE", "AMBIGUOUS", "APPROVED", "REJECTED", "NEEDS-TAG"])],
  ["deep_read", new Set(["-", "ok", "not-needed", "error"])],
  ["owner_verdict", new Set(["UNREVIEWED", "APPROVED", "REJECTED", "SILENT", "NEEDS-TAG"])],
  ["tagged_rows", new Set(["-", "ok", "inert", "not-needed"])],
  ["crossgen", new Set(["-", "ok", "not-needed"])],
  ["promoted", new Set(["-", "ok", "not-needed"])],
  ["post_readback", new Set(["-", "ok", "not-needed", "error"])],
]);

function valueOf(name) {
  const index = argv.indexOf(name);
  return index >= 0 ? argv[index + 1] : null;
}

function parseCsvLine(line) {
  const cells = [];
  let current = "";
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const character = line[index];
    if (quoted) {
      if (character === '"' && line[index + 1] === '"') { current += '"'; index += 1; }
      else if (character === '"') quoted = false;
      else current += character;
    } else if (character === '"') quoted = true;
    else if (character === ",") { cells.push(current); current = ""; }
    else current += character;
  }
  cells.push(current);
  return cells;
}

function readCsv(file) {
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((line) => line.trim() !== "");
  const header = parseCsvLine(lines[0]).map((cell) => cell.trim());
  return {
    header,
    rows: lines.slice(1).map((line) => {
      const cells = parseCsvLine(line);
      return Object.fromEntries(header.map((column, index) => [column, (cells[index] ?? "").trim()]));
    }),
  };
}

function csvCell(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

function writeCheckpoint(rows) {
  const text = [CHECKPOINT_HEADER.join(","), ...rows.map((row) => CHECKPOINT_HEADER.map((column) => csvCell(row[column])).join(","))].join("\n");
  fs.writeFileSync(checkpointPath, `${text}\n`, "utf8");
}

function filteredRows(rows) {
  const scope = valueOf("--scope");
  const tranche = valueOf("--tranche");
  const shard = valueOf("--shard");
  return rows.filter((row) => (!scope || row.scope === scope) && (!tranche || row.audit_tranche === tranche) && (!shard || row.audit_shard === shard));
}

function doValidate() {
  const failures = [];
  for (const file of [inventoryPath, worklistPath, checkpointPath]) if (!fs.existsSync(file)) failures.push(`missing ${path.relative(repo, file)}`);
  if (failures.length) return emit({ check: "coreQuestAuditInventory", status: "FAIL", failures }, true);
  const inventory = JSON.parse(fs.readFileSync(inventoryPath, "utf8"));
  const worklist = readCsv(worklistPath);
  const checkpoint = readCsv(checkpointPath);
  if (checkpoint.header.join("|") !== CHECKPOINT_HEADER.join("|")) failures.push("checkpoint header differs from the frozen schema");
  const occurrenceIds = new Set();
  const canonical = new Map();
  for (const row of worklist.rows) {
    if (!row.occurrence_id || occurrenceIds.has(row.occurrence_id)) failures.push(`duplicate/empty occurrence_id ${row.occurrence_id || "<empty>"}`);
    occurrenceIds.add(row.occurrence_id);
    if (row.is_canonical === "yes") {
      const key = row.formid.toLowerCase();
      if (canonical.has(key)) failures.push(`multiple canonical occurrences for ${row.formid}`);
      canonical.set(key, row);
    }
  }
  const checkpointKeys = new Set();
  for (const row of checkpoint.rows) {
    const key = row.formid.toLowerCase();
    if (checkpointKeys.has(key)) failures.push(`duplicate checkpoint FormKey ${row.formid}`);
    checkpointKeys.add(key);
    if (!canonical.has(key)) failures.push(`checkpoint FormKey absent from canonical worklist: ${row.formid}`);
  }
  for (const row of canonical.values()) if (!checkpointKeys.has(row.formid.toLowerCase())) failures.push(`canonical FormKey absent from checkpoint: ${row.formid}`);
  const coreOccurrences = worklist.rows.filter((row) => row.scope === "core").length;
  const coreCanonical = [...canonical.values()].filter((row) => row.scope === "core").length;
  const ccOccurrences = worklist.rows.filter((row) => row.scope === "creation-club").length;
  const ccCanonical = [...canonical.values()].filter((row) => row.scope === "creation-club").length;
  const actual = { coreOccurrences, coreCanonical, ccOccurrences, ccCanonical, checkpointRows: checkpoint.rows.length };
  for (const [key, expected] of Object.entries(inventory.totals)) if (actual[key] !== expected) failures.push(`${key}: expected ${expected}, got ${actual[key]}`);
  return emit({ check: "coreQuestAuditInventory", status: failures.length ? "FAIL" : "PASS", ...actual, failures }, failures.length > 0);
}

function doCheck() {
  const rows = filteredRows(readCsv(checkpointPath).rows);
  const terminal = (row) => ["STRUCTURAL-SILENT", "SEMANTIC-SILENT", "REJECTED"].includes(row.classification)
    ? row.post_readback === "not-needed"
    : row.classification === "APPROVED" && row.post_readback === "ok";
  const summary = {
    check: "coreQuestAuditCheckpoint",
    rows: rows.length,
    complete: rows.filter(terminal).length,
    remaining: rows.filter((row) => !terminal(row)).length,
    classifications: rows.reduce((acc, row) => ((acc[row.classification] = (acc[row.classification] ?? 0) + 1), acc), {}),
    next: rows.find((row) => !terminal(row))?.formid ?? null,
  };
  emit(summary, false);
}

function doSet() {
  const formid = valueOf("--formid");
  const field = valueOf("--field");
  const value = valueOf("--value") ?? "";
  if (!formid || !field || (!SETTABLE.has(field) && field !== "notes")) throw new Error("usage: --set --formid <PLUGIN:HHHHHH> --field <column> --value <value>");
  if (SETTABLE.has(field) && !SETTABLE.get(field).has(value)) throw new Error(`${field} does not accept "${value}"`);
  const data = readCsv(checkpointPath);
  const row = data.rows.find((candidate) => candidate.formid.toLowerCase() === formid.toLowerCase());
  if (!row) throw new Error(`No checkpoint row for ${formid}`);
  row[field] = value;
  writeCheckpoint(data.rows);
  console.log(`${row.formid} ${field}=${value}`);
}

function emit(result, failed) {
  if (argv.includes("--json")) console.log(JSON.stringify(result, null, 2));
  else {
    const details = Object.entries(result).filter(([key]) => !["check", "status", "failures", "classifications", "next"].includes(key)).map(([key, value]) => `${key}=${value}`).join(" ");
    console.log(`${result.status ?? "PROGRESS"} ${details}`.trim());
    if (result.classifications) console.log(`classifications: ${JSON.stringify(result.classifications)}`);
    if (Object.hasOwn(result, "next")) console.log(result.next ? `next: ${result.next}` : "next: none");
    for (const failure of result.failures ?? []) console.error(`  ${failure}`);
  }
  if (failed) process.exitCode = 1;
  return result;
}

const modes = ["--check", "--validate", "--set"].filter((mode) => argv.includes(mode));
if (modes.length !== 1) throw new Error("usage: --validate | --check [filters] | --set --formid ... --field ... --value ...");
if (argv.includes("--validate")) doValidate();
else if (argv.includes("--check")) doCheck();
else doSet();
