#!/usr/bin/env node
/**
 * Promote owner-approved quest cross-generation candidates into one canonical
 * core tranche. The adjudication manifest is the durable authority; generated
 * candidate reports remain regenerable review output.
 */

import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const HEADER = [
  "editor_id", "quest_name", "outcome_stage", "outcome", "act_tags",
  "deity", "valence", "intensity", "magnitude", "citation",
];

function parseArgs(argv) {
  const args = { manifest: null, write: false, selfTest: false };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--manifest") args.manifest = argv[++i];
    else if (argv[i] === "--write") args.write = true;
    else if (argv[i] === "--self-test") args.selfTest = true;
    else throw new Error(`Unknown argument: ${argv[i]}`);
  }
  return args;
}

function parseCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (ch === '"') quoted = false;
      else field += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((cells) => cells.some((cell) => cell !== ""));
}

function readObjects(file) {
  const rows = parseCsv(readFileSync(file, "utf8"));
  const header = rows.shift();
  return rows.map((cells) => Object.fromEntries(header.map((key, index) => [key, cells[index] ?? ""])));
}

function csvEscape(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(rows) {
  return [HEADER, ...rows.map((row) => HEADER.map((key) => row[key] ?? ""))]
    .map((cells) => cells.map(csvEscape).join(","))
    .join("\n") + "\n";
}

function candidateKey(row) {
  return `${row.editor_id}|${row.outcome_stage}|${row.deity}`;
}

function validateManifest(manifest) {
  if (manifest.schema !== "pdv-core-quest-crossgen-adjudication-v1") throw new Error("Manifest schema drift");
  if (!manifest.output || !Array.isArray(manifest.sources) || !manifest.sources.length) throw new Error("Manifest requires output and sources");
  if (!manifest.approval || !manifest.approval.trim()) throw new Error("Manifest requires approval text");
}

function promote(manifest) {
  validateManifest(manifest);
  const promoted = [];
  const allKeys = new Set();
  let candidateCount = 0;
  let exclusionCount = 0;

  for (const source of manifest.sources) {
    const sourcePath = path.resolve(ROOT, source.path);
    const rows = readObjects(sourcePath);
    if (rows.length !== source.expected_candidates) {
      throw new Error(`${source.path}: expected ${source.expected_candidates} candidates, found ${rows.length}`);
    }
    candidateCount += rows.length;
    const byKey = new Map(rows.map((row) => [candidateKey(row), row]));
    if (byKey.size !== rows.length) throw new Error(`${source.path}: duplicate candidate natural key`);
    const exclusions = new Map((source.exclusions ?? []).map((entry) => [entry.key, entry.reason]));
    for (const [key, reason] of exclusions) {
      if (!byKey.has(key)) throw new Error(`${source.path}: exclusion does not match a candidate: ${key}`);
      if (!reason) throw new Error(`${source.path}: exclusion lacks a reason: ${key}`);
    }
    exclusionCount += exclusions.size;

    for (const row of rows) {
      const key = candidateKey(row);
      if (exclusions.has(key)) continue;
      if (allKeys.has(key)) throw new Error(`Duplicate promoted natural key across sources: ${key}`);
      allKeys.add(key);
      promoted.push({
        ...row,
        citation: row.citation.replace(/; REVIEW before promotion$/, `; ${manifest.approval}`),
      });
    }
  }

  for (const row of manifest.manual_rows ?? []) {
    const key = candidateKey(row);
    if (allKeys.has(key)) throw new Error(`Manual row duplicates a promoted natural key: ${key}`);
    for (const column of HEADER) {
      if (row[column] === undefined) throw new Error(`Manual row ${key} lacks ${column}`);
    }
    allKeys.add(key);
    promoted.push(row);
  }

  promoted.sort((a, b) =>
    a.editor_id.localeCompare(b.editor_id)
    || Number(a.outcome_stage) - Number(b.outcome_stage)
    || a.deity.localeCompare(b.deity));
  return { promoted, candidateCount, exclusionCount, manualCount: (manifest.manual_rows ?? []).length };
}

function selfTest() {
  const manifest = {
    schema: "pdv-core-quest-crossgen-adjudication-v1",
    output: "unused.csv",
    approval: "owner-approved test",
    sources: [{ path: "unused.csv", expected_candidates: 1, exclusions: [] }],
  };
  validateManifest(manifest);
  const csv = renderCsv([{ editor_id: "Q", quest_name: "Quest", outcome_stage: "10", outcome: "Done", act_tags: "charity", deity: "Mara", valence: "+", intensity: "m", magnitude: "small", citation: "reviewed" }]);
  const parsed = parseCsv(csv);
  if (parsed.length !== 2 || parsed[1][3] !== "Done") throw new Error("CSV round-trip failed");
  console.log("PASS pdv_quest_cross_promote self-test");
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.selfTest) return selfTest();
  if (!args.manifest) throw new Error("Use --manifest <path> [--write]");
  const manifestPath = path.resolve(ROOT, args.manifest);
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  const result = promote(manifest);
  const output = path.resolve(ROOT, manifest.output);
  const rendered = renderCsv(result.promoted);
  if (args.write) writeFileSync(output, rendered, "utf8");
  else if (readFileSync(output, "utf8").replaceAll("\r\n", "\n") !== rendered) throw new Error(`${manifest.output}: regeneration drift; run with --write`);
  console.log(`PASS pdv_quest_cross_promote candidates=${result.candidateCount} excluded=${result.exclusionCount} manual=${result.manualCount} promoted=${result.promoted.length}`);
}

try { main(); } catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
