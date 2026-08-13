#!/usr/bin/env node
/** Build the checkpointed ARR 2.5 out-of-scope QUST discovery worklist. */

import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { hashText, sameTextToString, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = join(REPO, "references", "vanilla-gameplay", "compatibility");
const DEFAULT_INVENTORY = join(COMPAT, "PDV_ARR25_ContentInventory_2026-08-06.csv");
const DEFAULT_PROFILE = "D:\\Wabbajack\\modlists\\ARR 2.5\\profiles\\KoK R11\\modlist.txt";
const DEFAULT_WORKLIST = join(COMPAT, "PDV_ARR25_DiscoveryWorklist_2026-08-06.csv");
const DEFAULT_MANIFEST = join(COMPAT, "PDV_ARR25_DiscoveryBatches_2026-08-06.json");
const DEFAULT_SOURCE = join(COMPAT, "arr25-discovery-source");

function parseArgs(argv) {
  const out = {
    inventory: DEFAULT_INVENTORY,
    profile: DEFAULT_PROFILE,
    sourceDir: DEFAULT_SOURCE,
    output: DEFAULT_WORKLIST,
    manifest: DEFAULT_MANIFEST,
    batchSize: 10,
    check: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--inventory") out.inventory = resolve(argv[++i]);
    else if (arg === "--profile") out.profile = resolve(argv[++i]);
    else if (arg === "--source-dir" || arg === "--scratch") out.sourceDir = resolve(argv[++i]);
    else if (arg === "--output") out.output = resolve(argv[++i]);
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

function parseCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false, afterQuote = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (ch === '"') { quoted = false; afterQuote = true; }
      else field += ch;
    } else if (afterQuote) {
      if (ch === ",") { row.push(field); field = ""; afterQuote = false; }
      else if (ch === "\n") { row.push(field); rows.push(row); row = []; field = ""; afterQuote = false; }
      else if (ch !== "\r") throw new Error(`Malformed CSV: unexpected ${JSON.stringify(ch)} after closing quote`);
    } else if (ch === '"') {
      if (field.length) throw new Error("Malformed CSV: quote begins inside an unquoted field");
      quoted = true;
    } else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (quoted) throw new Error("CSV ends inside a quoted field");
  if (field.length || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((r) => r.some(Boolean));
}

function inventoryMods(path) {
  const rows = parseCsv(readFileSync(path, "utf8"));
  const header = rows.shift();
  if (new Set(header).size !== header.length) throw new Error("Inventory has duplicate header names");
  const modIndex = header.indexOf("mod");
  if (modIndex < 0) throw new Error("Inventory is missing mod column");
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].length !== header.length) {
      throw new Error(`Inventory row ${i + 2} has ${rows[i].length} fields; expected ${header.length}`);
    }
  }
  return new Set(rows.map((row) => row[modIndex]?.trim()).filter(Boolean));
}

function tsvMods(path) {
  const mods = new Set();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const cells = line.split("\t");
    if (cells.length < 2 || !cells[1].trim()) throw new Error(`Malformed TSV line: ${line}`);
    mods.add(cells[1].trim());
  }
  return mods;
}

function sha256(path) {
  return hashText(path);
}

function sourceLabel(path) {
  const rel = relative(REPO, path);
  return rel && !rel.startsWith("..") ? rel.replaceAll("\\", "/") : path;
}

function separatorMap(path) {
  const map = new Map();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const [separator, mod] = line.split("\t");
    if (!separator || !mod) throw new Error(`Malformed qust_mods.tsv line: ${line}`);
    if (map.has(mod) && map.get(mod) !== separator) throw new Error(`Mod appears under multiple separators: ${mod}`);
    map.set(mod, separator);
  }
  return map;
}

function pluginMap(path) {
  const map = new Map();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const [separator, mod, plugin] = line.split("\t");
    if (!separator || !mod || !plugin) throw new Error(`Malformed mod_plugins.tsv line: ${line}`);
    if (!map.has(mod)) map.set(mod, []);
    const entry = { separator, plugin };
    if (!map.get(mod).some((item) => item.plugin === plugin)) map.get(mod).push(entry);
  }
  return map;
}

function waveFor(separator) {
  if (
    separator === "Base Game & Creation Club Files" ||
    separator === "Gameplay - Magic Mods" ||
    separator === "Gameplay - Vampire and Werewolf Overhaul" ||
    separator === "Gameplay - Death Alternative" ||
    separator === "Gameplay - Missives" ||
    /^City Stuff - (Solitude|Whiterun|Riften|Villages|Misc Worldspace)$/.test(separator)
  ) return "A";
  if (["Gameplay - Combat", "Gameplay - Frameworks", "Gameplay - Perks & Leveling"].includes(separator)) return "B";
  return "C";
}

function quoteCsv(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(rows) {
  const header = ["batch_id", "wave", "separator", "mod", "plugin", "plugin_path", "input_id"];
  return [header, ...rows.map((row) => header.map((key) => row[key]))]
    .map((row) => row.map(quoteCsv).join(","))
    .join("\r\n") + "\r\n";
}

function assignBatches(records, batchSize) {
  for (const wave of ["A", "B", "C"]) {
    const waveRows = records.filter((row) => row.wave === wave);
    if (!waveRows.length) continue;
    const batchCount = Math.ceil(waveRows.length / batchSize);
    const baseSize = Math.floor(waveRows.length / batchCount);
    const largerBatches = waveRows.length % batchCount;
    if (baseSize < 8 || baseSize + (largerBatches ? 1 : 0) > 12) {
      throw new Error(`Cannot partition Wave ${wave} into 8-12 path batches`);
    }
    let cursor = 0;
    for (let batch = 1; batch <= batchCount; batch++) {
      const size = baseSize + (batch <= largerBatches ? 1 : 0);
      const id = `${wave}${String(batch).padStart(3, "0")}`;
      for (const row of waveRows.slice(cursor, cursor + size)) row.batch_id = id;
      cursor += size;
    }
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const qustMods = join(args.sourceDir, "qust_mods.tsv");
  const modPlugins = join(args.sourceDir, "mod_plugins.tsv");
  const wave1Scope = join(args.sourceDir, "wave1_scope.tsv");
  for (const path of [args.inventory, args.profile, qustMods, modPlugins, wave1Scope]) {
    if (!existsSync(path)) throw new Error(`Required file not found: ${path}`);
  }

  const inventory = inventoryMods(args.inventory);
  const covered = tsvMods(wave1Scope);
  const separators = separatorMap(qustMods);
  const pluginsByMod = pluginMap(modPlugins);
  if (separators.size !== 583) throw new Error(`QUST universe drift: expected 583 mods, found ${separators.size}`);
  if (pluginsByMod.size !== 1939) throw new Error(`Plugin-bearing universe drift: expected 1939 mods, found ${pluginsByMod.size}`);
  const missingWave1Inventory = [...covered].filter((mod) => !inventory.has(mod));
  if (covered.size !== 657 || missingWave1Inventory.length) {
    throw new Error(`Wave 1 authority drift: scope=${covered.size}, missing from inventory=${missingWave1Inventory.length}`);
  }
  const coveredQust = [...separators.keys()].filter((mod) => covered.has(mod));
  if (coveredQust.length !== 255) throw new Error(`Wave 1 QUST coverage drift: expected 255, found ${coveredQust.length}`);
  const uncoveredMods = [...separators.keys()].filter((mod) => !covered.has(mod)).sort();
  if (uncoveredMods.length !== 328) throw new Error(`Uncovered QUST drift: expected 328, found ${uncoveredMods.length}`);
  const records = [];
  for (const mod of uncoveredMods) {
    const separator = separators.get(mod);
    const plugins = pluginsByMod.get(mod);
    if (!plugins?.length) throw new Error(`No plugin mapping for QUST mod: ${mod}`);
    for (const { plugin } of plugins) {
      const pluginPath = join("D:\\Wabbajack\\modlists\\ARR 2.5\\mods", mod, plugin);
      if (!existsSync(pluginPath)) throw new Error(`Mapped plugin path does not exist: ${pluginPath}`);
      records.push({
        wave: waveFor(separator),
        separator,
        mod,
        plugin,
        plugin_path: pluginPath,
      });
    }
  }
  records.sort((a, b) =>
    a.wave.localeCompare(b.wave) ||
    a.separator.localeCompare(b.separator) ||
    a.mod.localeCompare(b.mod) ||
    a.plugin.localeCompare(b.plugin),
  );

  assignBatches(records, args.batchSize);
  for (const row of records) {
    row.input_id = createHash("sha256").update(`${row.separator}\0${row.mod}\0${row.plugin_path}`).digest("hex").slice(0, 16);
  }

  const distinctMods = new Set(records.map((row) => row.mod));
  const byWave = {};
  for (const wave of ["A", "B", "C"]) {
    const rows = records.filter((row) => row.wave === wave);
    byWave[wave] = {
      mods: new Set(rows.map((row) => row.mod)).size,
      pluginPaths: rows.length,
      batches: new Set(rows.map((row) => row.batch_id)).size,
    };
  }
  let previousBatches = new Map();
  if (existsSync(args.manifest)) {
    try {
      const previous = JSON.parse(readFileSync(args.manifest, "utf8"));
      previousBatches = new Map((previous.batches ?? []).map((batch) => [batch.id, batch]));
    } catch (error) {
      throw new Error(`Existing manifest is not valid JSON: ${error.message}`);
    }
  }
  const batchRecords = [...new Set(records.map((row) => row.batch_id))].map((id) => {
    const inputIds = records.filter((row) => row.batch_id === id).map((row) => row.input_id);
    const inputHash = createHash("sha256").update(inputIds.join("\n")).digest("hex");
    const previous = previousBatches.get(id);
    const sameInputs = previous && previous.inputHash === inputHash && JSON.stringify(previous.inputIds) === JSON.stringify(inputIds);
    return {
      id,
      wave: id[0],
      inputIds,
      inputHash,
      status: sameInputs ? previous.status : "pending",
      attempts: sameInputs ? previous.attempts : 0,
      completedInputIds: sameInputs ? (previous.completedInputIds ?? []) : [],
      lastError: sameInputs ? previous.lastError : null,
    };
  });
  for (const batch of batchRecords) {
    if (batch.inputIds.length < 8 || batch.inputIds.length > 12) {
      throw new Error(`Batch ${batch.id} has ${batch.inputIds.length} paths; expected 8-12`);
    }
  }
  const manifest = {
    schema: "pdv-arr25-discovery-batches.v1",
    target: { mo2Root: "D:\\Wabbajack\\modlists\\ARR 2.5", profile: "KoK R11" },
    source: {
      profileModlist: args.profile,
      profileModlistSha256: sha256(args.profile),
      wave1Scope: sourceLabel(wave1Scope),
      wave1ScopeSha256: sha256(wave1Scope),
      qustMods: sourceLabel(qustMods),
      qustModsSha256: sha256(qustMods),
      modPlugins: sourceLabel(modPlugins),
      modPluginsSha256: sha256(modPlugins),
    },
    batchSize: args.batchSize,
    uncoveredMods: distinctMods.size,
    pluginPaths: records.length,
    byWave,
    batches: batchRecords,
  };
  const worklist = renderCsv(records);
  const manifestText = JSON.stringify(manifest, null, 2) + "\n";

  if (args.check) {
    const worklistMatches = sameTextToString(args.output, worklist);
    const manifestMatches = sameTextToString(args.manifest, manifestText);
    if (!worklistMatches || !manifestMatches) throw new Error("Discovery worklist or manifest is stale");
  } else {
    mkdirSync(dirname(args.output), { recursive: true });
    mkdirSync(dirname(args.manifest), { recursive: true });
    writeTextWithEol(args.output, worklist, "lf");
    writeTextWithEol(args.manifest, manifestText, "lf");
  }
  console.log(`PASS: ${distinctMods.size} uncovered QUST mods / ${records.length} plugin paths.`);
  for (const wave of ["A", "B", "C"]) {
    const summary = byWave[wave];
    console.log(`  Wave ${wave}: ${summary.mods} mods / ${summary.pluginPaths} paths / ${summary.batches} batches`);
  }
}

try { main(); }
catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
