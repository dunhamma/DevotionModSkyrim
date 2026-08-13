#!/usr/bin/env node
/** Freeze the ARR 2.5 non-QUST record-signature universe. */

import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { hashText, sameTextToString, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = join(REPO, "references", "vanilla-gameplay", "compatibility");
const SOURCE = join(COMPAT, "arr25-discovery-source");
const DEFAULT_SCAN = join(COMPAT, "PDV_ARR25_NonQuestSignatureScan_2026-08-06.csv");
const DEFAULT_WORKLIST = join(COMPAT, "PDV_ARR25_NonQuestSignalWorklist_2026-08-06.csv");
const DEFAULT_MANIFEST = join(COMPAT, "PDV_ARR25_NonQuestSignalBatches_2026-08-06.json");
const MODS_ROOT = "D:\\Wabbajack\\modlists\\ARR 2.5\\mods";

// These are surfaces PDV can plausibly observe through an existing faucet,
// FormList, inventory event, location event, activation event, or distribution
// hook. A signature hit admits a file to direct review; it is not a semantic
// claim that any record in the file is devotional.
const SELECTED = new Set([
  "ACTI", "ALCH", "AMMO", "ARMO", "BOOK", "CONT", "DOOR", "ENCH",
  "FACT", "FLOR", "FLST", "INGR", "KYWD", "LCTN", "MISC", "PERK",
  "SCRL", "SHOU", "SPEL", "TREE", "WEAP",
]);

function parseArgs(argv) {
  const out = {
    sourceDir: SOURCE,
    scan: DEFAULT_SCAN,
    worklist: DEFAULT_WORKLIST,
    manifest: DEFAULT_MANIFEST,
    batchSize: 10,
    check: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--source-dir") out.sourceDir = resolve(argv[++i]);
    else if (arg === "--scan") out.scan = resolve(argv[++i]);
    else if (arg === "--worklist") out.worklist = resolve(argv[++i]);
    else if (arg === "--manifest") out.manifest = resolve(argv[++i]);
    else if (arg === "--batch-size") out.batchSize = Number(argv[++i]);
    else if (arg === "--check") out.check = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  if (!Number.isInteger(out.batchSize) || out.batchSize < 8 || out.batchSize > 12) {
    throw new Error("--batch-size must be an integer from 8 through 12");
  }
  return out;
}

function sha256File(path) {
  return hashText(path);
}

function sourceLabel(path) {
  const rel = relative(REPO, path);
  return rel && !rel.startsWith("..") ? rel.replaceAll("\\", "/") : path;
}

function readQustMods(path) {
  const mods = new Set();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const cells = line.split("\t");
    if (cells.length < 2 || !cells[1].trim()) throw new Error(`Malformed QUST source line: ${line}`);
    mods.add(cells[1].trim());
  }
  return mods;
}

function readPluginMap(path) {
  const rows = [];
  const seen = new Set();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const [separator, mod, plugin] = line.split("\t");
    if (!separator || !mod || !plugin) throw new Error(`Malformed plugin source line: ${line}`);
    const key = `${mod}\0${plugin}`;
    if (seen.has(key)) continue;
    seen.add(key);
    rows.push({ separator, mod, plugin, plugin_path: join(MODS_ROOT, mod, plugin) });
  }
  return rows;
}

function signatureAt(buffer, offset) {
  return buffer.toString("ascii", offset, offset + 4);
}

function scanPlugin(path) {
  const buffer = readFileSync(path);
  const counts = new Map();
  let records = 0;
  function walk(start, end, context) {
    let offset = start;
    while (offset < end) {
      if (offset + 24 > end) throw new Error(`${context}: truncated record header at 0x${offset.toString(16)}`);
      const signature = signatureAt(buffer, offset);
      if (!/^(?:GRUP|[A-Z0-9_]{4})$/.test(signature)) {
        throw new Error(`${context}: invalid signature ${JSON.stringify(signature)} at 0x${offset.toString(16)}`);
      }
      const size = buffer.readUInt32LE(offset + 4);
      if (signature === "GRUP") {
        if (size < 24 || offset + size > end) throw new Error(`${context}: invalid GRUP size ${size} at 0x${offset.toString(16)}`);
        walk(offset + 24, offset + size, `${context}/${signatureAt(buffer, offset + 8)}`);
        offset += size;
      } else {
        const next = offset + 24 + size;
        if (next > end) throw new Error(`${context}: invalid ${signature} size ${size} at 0x${offset.toString(16)}`);
        if (signature !== "TES4") {
          counts.set(signature, (counts.get(signature) ?? 0) + 1);
          records++;
        }
        offset = next;
      }
    }
    if (offset !== end) throw new Error(`${context}: group boundary drift`);
  }
  walk(0, buffer.length, "FILE");
  return { records, counts };
}

function quoteCsv(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(header, rows) {
  return [header, ...rows.map((row) => header.map((key) => row[key] ?? ""))]
    .map((row) => row.map(quoteCsv).join(",")).join("\r\n") + "\r\n";
}

function selectedCounts(counts) {
  return [...SELECTED].sort().filter((sig) => counts.has(sig))
    .map((sig) => `${sig}:${counts.get(sig)}`).join("|");
}

function assignBatches(rows, batchSize) {
  if (!rows.length) return;
  const batchCount = Math.ceil(rows.length / batchSize);
  const baseSize = Math.floor(rows.length / batchCount);
  const larger = rows.length % batchCount;
  if (baseSize < 8 || baseSize + (larger ? 1 : 0) > 12) {
    throw new Error(`Cannot partition ${rows.length} candidates into 8-12 path batches`);
  }
  let cursor = 0;
  for (let index = 1; index <= batchCount; index++) {
    const size = baseSize + (index <= larger ? 1 : 0);
    const id = `NQ${String(index).padStart(3, "0")}`;
    for (const row of rows.slice(cursor, cursor + size)) row.batch_id = id;
    cursor += size;
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const qustPath = join(args.sourceDir, "qust_mods.tsv");
  const pluginsPath = join(args.sourceDir, "mod_plugins.tsv");
  for (const path of [qustPath, pluginsPath]) if (!existsSync(path)) throw new Error(`Required file not found: ${path}`);
  const qustMods = readQustMods(qustPath);
  const allPlugins = readPluginMap(pluginsPath);
  if (qustMods.size !== 583) throw new Error(`QUST universe drift: expected 583 mods, found ${qustMods.size}`);
  if (new Set(allPlugins.map((row) => row.mod)).size !== 1939) throw new Error("Plugin-bearing mod universe drift");
  const scanRows = allPlugins.filter((row) => !qustMods.has(row.mod));
  if (new Set(scanRows.map((row) => row.mod)).size !== 1356 || scanRows.length !== 3001) {
    throw new Error(`Non-QUST universe drift: expected 1356 mods / 3001 paths`);
  }
  for (const row of scanRows) {
    if (!existsSync(row.plugin_path)) throw new Error(`Plugin path not found: ${row.plugin_path}`);
    try {
      const result = scanPlugin(row.plugin_path);
      row.total_records = result.records;
      row.selected_signature_counts = selectedCounts(result.counts);
      row.scan_verdict = row.selected_signature_counts ? "SIGNAL-CANDIDATE" : "OUTSIDE-SELECTED-SIGNATURES";
      row.scan_error = "";
    } catch (error) {
      row.total_records = "";
      row.selected_signature_counts = "";
      row.scan_verdict = "READ-ERROR";
      row.scan_error = error.message;
    }
    row.input_id = createHash("sha256").update(`${row.separator}\0${row.mod}\0${row.plugin_path}`).digest("hex").slice(0, 16);
  }
  scanRows.sort((a, b) => a.separator.localeCompare(b.separator) || a.mod.localeCompare(b.mod) || a.plugin.localeCompare(b.plugin));
  const candidates = scanRows.filter((row) => row.scan_verdict === "SIGNAL-CANDIDATE");
  assignBatches(candidates, args.batchSize);
  const scanHeader = ["separator", "mod", "plugin", "plugin_path", "input_id", "total_records", "selected_signature_counts", "scan_verdict", "scan_error"];
  const workHeader = ["batch_id", "separator", "mod", "plugin", "plugin_path", "input_id", "selected_signature_counts"];
  const scanText = renderCsv(scanHeader, scanRows);
  const workText = renderCsv(workHeader, candidates);
  const errors = scanRows.filter((row) => row.scan_verdict === "READ-ERROR");
  let previousBatches = new Map();
  if (existsSync(args.manifest)) {
    try {
      const previous = JSON.parse(readFileSync(args.manifest, "utf8"));
      previousBatches = new Map((previous.batches ?? []).map((batch) => [batch.id, batch]));
    } catch (error) {
      throw new Error(`Existing manifest is not valid JSON: ${error.message}`);
    }
  }
  const batches = [...new Set(candidates.map((row) => row.batch_id))].map((id) => {
    const inputIds = candidates.filter((row) => row.batch_id === id).map((row) => row.input_id);
    const inputHash = createHash("sha256").update(inputIds.join("\n")).digest("hex");
    const previous = previousBatches.get(id);
    const sameInputs = previous && previous.inputHash === inputHash && JSON.stringify(previous.inputIds) === JSON.stringify(inputIds);
    return {
      id,
      inputIds,
      inputHash,
      status: sameInputs ? previous.status : "pending",
      attempts: sameInputs ? previous.attempts : 0,
      completedInputIds: sameInputs ? (previous.completedInputIds ?? []) : [],
      lastError: sameInputs ? previous.lastError : null,
    };
  });
  for (const batch of batches) {
    if (batch.inputIds.length < 8 || batch.inputIds.length > 12) {
      throw new Error(`Batch ${batch.id} has ${batch.inputIds.length} paths; expected 8-12`);
    }
  }
  const manifest = {
    schema: "pdv-arr25-nonquest-signal-batches.v1",
    target: { mo2Root: "D:\\Wabbajack\\modlists\\ARR 2.5", profile: "KoK R11" },
    selectedSignatures: [...SELECTED].sort(),
    source: {
      qustMods: sourceLabel(qustPath),
      qustModsSha256: sha256File(qustPath),
      modPlugins: sourceLabel(pluginsPath),
      modPluginsSha256: sha256File(pluginsPath),
    },
    scannedMods: new Set(scanRows.map((row) => row.mod)).size,
    scannedPluginPaths: scanRows.length,
    candidateMods: new Set(candidates.map((row) => row.mod)).size,
    candidatePluginPaths: candidates.length,
    outsideSelectedSignaturePaths: scanRows.filter((row) => row.scan_verdict === "OUTSIDE-SELECTED-SIGNATURES").length,
    readErrors: errors.map((row) => ({ inputId: row.input_id, path: row.plugin_path, error: row.scan_error })),
    batches,
  };
  const manifestText = JSON.stringify(manifest, null, 2) + "\n";
  if (args.check) {
    if (!sameTextToString(args.scan, scanText)) throw new Error("Non-quest signature scan is stale");
    if (!sameTextToString(args.worklist, workText)) throw new Error("Non-quest signal worklist is stale");
    if (!sameTextToString(args.manifest, manifestText)) throw new Error("Non-quest signal manifest is stale");
  } else {
    writeTextWithEol(args.scan, scanText, "lf");
    writeTextWithEol(args.worklist, workText, "lf");
    writeTextWithEol(args.manifest, manifestText, "lf");
  }
  console.log(`PASS: scanned ${manifest.scannedMods} non-QUST mods / ${manifest.scannedPluginPaths} paths.`);
  console.log(`  candidates: ${manifest.candidateMods} mods / ${manifest.candidatePluginPaths} paths / ${batches.length} batches`);
  console.log(`  outside signatures: ${manifest.outsideSelectedSignaturePaths}; read errors: ${errors.length}`);
}

try { main(); }
catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
