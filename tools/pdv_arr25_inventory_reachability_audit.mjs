#!/usr/bin/env node
/**
 * Report-only ARR 2.5 inventory reachability audit.
 *
 * Validates the inventory's canonical deity field and derives the origins that
 * can receive at least one candidate through IsDashboardDeityInOriginRoster.
 * Daedric Princes are global and therefore reach every origin. Findings about
 * an empty or partial origin set are warnings; malformed CSV, unknown deities,
 * and source-roster drift are failures. Requested scope mismatches are reported.
 *
 * Usage:
 *   node tools/pdv_arr25_inventory_reachability_audit.mjs --json
 *   node tools/pdv_arr25_inventory_reachability_audit.mjs --write-derived
 *   node tools/pdv_arr25_inventory_reachability_audit.mjs --scope-tsv <path>
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { familySourceText } from "./lib/pdv_symbol_home.mjs";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_ROOT = join(REPO, "live-source", "Scripts", "Source");
const DEFAULT_INVENTORY = join(
  REPO,
  "references",
  "vanilla-gameplay",
  "compatibility",
  "PDV_ARR25_ContentInventory_2026-08-06.csv",
);
const MANAGER = join(REPO, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const FULL_MATRIX = join(REPO, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
const ALL_RACES = [
  "Nord", "Imperial", "Breton", "Altmer", "Bosmer",
  "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard",
];

const ORIGIN_TOKEN_TO_RACE = Object.fromEntries(ALL_RACES.map((race) => [`ORIGIN_${race.toUpperCase()}`, race]));
const PROPERTY_TO_DEITY = {
  PDV_Kyne: "Kyne",
  PDV_Kynareth: "Kynareth",
  PDV_Talos: "Talos",
  PDV_Shor: "Shor",
  PDV_Tsun: "Tsun",
  PDV_Stuhn: "Stuhn",
  PDV_Mara: "Mara",
  PDV_Akatosh: "Akatosh",
  PDV_Arkay: "Arkay",
  PDV_Stendarr: "Stendarr",
  PDV_Julianos: "Julianos",
  PDV_Dibella: "Dibella",
  PDV_Zenithar: "Zenithar",
  PDV_Magnus: "Magnus",
  PDV_Yffre: "Y'ffre",
  PDV_AuriEl: "Auri-El",
  PDV_Xarxes: "Xarxes",
  PDV_Trinimac: "Trinimac",
  PDV_Syrabane: "Syrabane",
  PDV_Zen: "Z'en",
  PDV_Azura: "Azura",
  PDV_Boethiah: "Boethiah",
  PDV_Mephala: "Mephala",
  PDV_BaanDar: "Baan Dar",
  PDV_Rajhin: "Rajhin",
  PDV_Alkosh: "Alkosh",
  PDV_Khenarthi: "Khenarthi",
  PDV_Hist: "The Hist",
  PDV_Sithis: "Sithis",
  PDV_Malacath: "Malacath",
  PDV_Tuwhacca: "Tu'whacca",
  PDV_Leki: "Leki",
  PDV_HoonDing: "HoonDing",
};

const DAEDRIC_PRINCES = new Set([
  "Azura", "Boethiah", "Mephala", "Meridia", "Hircine", "Molag Bal",
  "Nocturnal", "Hermaeus Mora", "Mehrunes Dagon", "Sheogorath", "Namira",
  "Sanguine", "Clavicus Vile", "Peryite", "Vaermina", "Malacath",
]);

function parseArgs(argv) {
  const out = { inventory: DEFAULT_INVENTORY, scopeTsv: null, json: false, writeDerived: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--inventory") out.inventory = resolve(argv[++i]);
    else if (arg === "--scope-tsv") out.scopeTsv = resolve(argv[++i]);
    else if (arg === "--json") out.json = true;
    else if (arg === "--write-derived") out.writeDerived = true;
    else throw new Error(`Unknown argument: ${arg}`);
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
  return rows.filter((r) => r.some((value) => value !== ""));
}

function csvObjects(text) {
  const rows = parseCsv(text);
  if (!rows.length) throw new Error("Inventory CSV is empty");
  const header = rows.shift();
  const objects = rows.map((values, index) => {
    if (values.length !== header.length) {
      throw new Error(`CSV row ${index + 2} has ${values.length} fields; expected ${header.length}`);
    }
    return Object.fromEntries(header.map((name, i) => [name, values[i]]));
  });
  return { header, objects };
}

function quoteCsv(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(header, objects) {
  return [header, ...objects.map((row) => header.map((name) => row[name] ?? ""))]
    .map((row) => row.map(quoteCsv).join(","))
    .join("\r\n") + "\r\n";
}

function parseLegacyMatrixCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted && ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
    else if (ch === '"') quoted = !quoted;
    else if (ch === "," && !quoted) { row.push(field); field = ""; }
    else if (ch === "\n" && !quoted) { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field.length || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((r) => r.some(Boolean));
}

function normalizeKey(value) {
  return value
    .toLowerCase()
    .replace(/[’']/g, "")
    .replace(/[^a-z0-9]+/g, "")
    .trim();
}

function canonicalDeities() {
  // Historical matrix citations contain a few unquoted commas. The deity field
  // precedes citation, so tolerate trailing legacy cells while still taking the
  // canonical name from the declared deity column.
  const rows = parseLegacyMatrixCsv(readFileSync(FULL_MATRIX, "utf8"));
  const header = rows.shift();
  const deityIndex = header.indexOf("deity");
  if (deityIndex < 0) throw new Error("Full matrix is missing deity column");
  const values = new Set(rows.map((row) => row[deityIndex]?.trim()).filter(Boolean));
  const byKey = new Map([...values].map((name) => [normalizeKey(name), name]));
  const aliases = {
    yffre: "Y'ffre", auriel: "Auri-El", baandar: "Baan Dar",
    tuwhacca: "Tu'whacca", hist: "The Hist", thehist: "The Hist",
  };
  for (const [key, name] of Object.entries(aliases)) byKey.set(key, name);
  return { values, byKey };
}

function parseRuntimeRosters() {
  // Resolver-aware: search the manager's decomposition family, not the manager alone,
  // so the roster parse tracks IsDashboardDeityInOriginRoster into an extracted module.
  const source = familySourceText(REPO, SOURCE_ROOT);
  const match = source.match(/Bool Function IsDashboardDeityInOriginRoster[\s\S]*?\nEndFunction/i);
  if (!match) throw new Error("Could not find IsDashboardDeityInOriginRoster in manager source");
  const rosters = Object.fromEntries(ALL_RACES.map((race) => [race, new Set()]));
  let currentRace = null;
  for (const line of match[0].split(/\r?\n/)) {
    const origin = line.match(/(?:if|elseIf)\s+originRace\s*==\s*(ORIGIN_[A-Z]+)/i);
    if (origin) currentRace = ORIGIN_TOKEN_TO_RACE[origin[1].toUpperCase()] ?? null;
    if (!currentRace || !/\breturn\b/i.test(line)) continue;
    for (const property of line.match(/PDV_[A-Za-z0-9]+/g) ?? []) {
      const deity = PROPERTY_TO_DEITY[property];
      if (!deity) throw new Error(`Unknown deity property in runtime roster: ${property}`);
      rosters[currentRace].add(deity);
    }
  }
  for (const race of ALL_RACES) {
    if (!rosters[race].size) throw new Error(`Runtime roster parsed empty for ${race}`);
  }
  return rosters;
}

function scopeMods(path) {
  const mods = new Set();
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    const cells = line.split("\t");
    if (cells.length < 2 || !cells[1].trim()) throw new Error(`Malformed scope TSV line: ${line}`);
    mods.add(cells[1].trim());
  }
  return mods;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  for (const required of [args.inventory, MANAGER, FULL_MATRIX]) {
    if (!existsSync(required)) throw new Error(`Required file not found: ${required}`);
  }
  const { header, objects } = csvObjects(readFileSync(args.inventory, "utf8"));
  for (const required of ["mod", "triage", "candidate_deities"]) {
    if (!header.includes(required)) throw new Error(`Inventory is missing required column: ${required}`);
  }
  for (const derived of ["candidate_deities_canonical", "reachable_races"]) {
    if (!header.includes(derived)) {
      if (!args.writeDerived) throw new Error(`Inventory is missing required column: ${derived}; use --write-derived to migrate it`);
      header.push(derived);
      for (const row of objects) row[derived] = "";
    }
  }

  const { values: canonicalValues, byKey } = canonicalDeities();
  const rosters = parseRuntimeRosters();
  if (!rosters.Altmer.has("Trinimac") || rosters.Orc.has("Trinimac")) {
    throw new Error("Locked Trinimac reachability drift: expected Altmer reachable and Orc pressure-only");
  }
  const unknown = [];
  const warnings = [];
  const legacyCandidateRows = [];
  const unreachableByOrigin = Object.fromEntries(ALL_RACES.map((race) => [race, []]));
  let derivedRows = 0;
  for (let i = 0; i < objects.length; i++) {
    const row = objects[i];
    const requested = row.candidate_deities_canonical.split("|").map((v) => v.trim()).filter(Boolean);
    if (row.candidate_deities.trim() && !requested.length && !row.notes.includes("[ARR25-CANONICAL-REVIEW:")) {
      legacyCandidateRows.push({ row: i + 2, mod: row.mod, legacy: row.candidate_deities });
    }
    const canonical = [];
    for (const value of requested) {
      const resolved = byKey.get(normalizeKey(value));
      if (!resolved || !canonicalValues.has(resolved)) unknown.push({ row: i + 2, mod: row.mod, deity: value });
      else if (!canonical.includes(resolved)) canonical.push(resolved);
    }
    const reachable = new Set();
    for (const deity of canonical) {
      if (DAEDRIC_PRINCES.has(deity)) ALL_RACES.forEach((race) => reachable.add(race));
      else for (const race of ALL_RACES) if (rosters[race].has(deity)) reachable.add(race);
    }
    const derived = ALL_RACES.filter((race) => reachable.has(race)).join("|");
    if (canonical.length) derivedRows++;
    if (canonical.length && !derived) warnings.push({ row: i + 2, mod: row.mod, finding: "no reachable origin", deities: canonical });
    for (const race of ALL_RACES) {
      for (const deity of canonical) {
        if (DAEDRIC_PRINCES.has(deity) || rosters[race].has(deity)) continue;
        unreachableByOrigin[race].push({
          row: i + 2,
          mod: row.mod,
          deity,
          classification: race === "Orc" && deity === "Trinimac" ? "intentional-pressure" : "roster-filtered",
        });
      }
    }
    if (row.reachable_races && row.reachable_races !== derived) {
      warnings.push({ row: i + 2, mod: row.mod, finding: "stale reachable_races", recorded: row.reachable_races, derived });
    }
    row.candidate_deities_canonical = canonical.join("|");
    row.reachable_races = derived;
  }

  const inventoryMods = new Set(objects.map((row) => row.mod.trim()).filter(Boolean));
  let scope = null;
  if (args.scopeTsv) {
    scope = scopeMods(args.scopeTsv);
    const missing = [...scope].filter((mod) => !inventoryMods.has(mod)).sort();
    const unexpected = [...inventoryMods].filter((mod) => !scope.has(mod)).sort();
    if (missing.length || unexpected.length) {
      warnings.push({ finding: "scope mismatch", missing, unexpected });
    }
  }

  if (unknown.length) {
    const sample = unknown.slice(0, 10).map((item) => `row ${item.row} ${item.mod}: ${item.deity}`).join("; ");
    throw new Error(`Unknown canonical deity value(s): ${unknown.length}. ${sample}`);
  }
  if (args.writeDerived) writeFileSync(args.inventory, renderCsv(header, objects), "utf8");

  const result = {
    status: "PASS",
    reportOnly: !args.writeDerived,
    inventory: args.inventory,
    rows: objects.length,
    mods: inventoryMods.size,
    scopeMods: scope?.size ?? null,
    rowsWithCanonicalCandidates: derivedRows,
    legacyCandidateRowsPendingReview: legacyCandidateRows.length,
    warnings: warnings.length,
    wroteDerived: args.writeDerived,
    rosterCounts: Object.fromEntries(ALL_RACES.map((race) => [race, rosters[race].size])),
    unreachableByOrigin: Object.fromEntries(ALL_RACES.map((race) => [race, {
      count: unreachableByOrigin[race].length,
      intentionalPressure: unreachableByOrigin[race].filter((item) => item.classification === "intentional-pressure").length,
      details: unreachableByOrigin[race],
    }])),
    warningDetails: warnings,
  };
  if (args.json) console.log(JSON.stringify(result, null, 2));
  else {
    console.log(`PASS: ${result.rows} rows / ${result.mods} mods; ${derivedRows} rows have canonical deity candidates.`);
    console.log(`Report-only reachability warnings: ${warnings.length}.`);
    if (args.writeDerived) console.log(`Updated derived columns: ${args.inventory}`);
  }
}

try { main(); }
catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
