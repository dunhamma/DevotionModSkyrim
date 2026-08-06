#!/usr/bin/env node
/**
 * Freeze primary-agent rulings for the legacy free-form candidate_deities
 * field. The generated review ledger, rather than the prose itself, is the
 * migration authority. Names outside the current roster/matrix remain useful
 * evidence in candidate_deities and notes but are not invented as reachable
 * runtime candidates.
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const INVENTORY = join(REPO, "references", "vanilla-gameplay", "compatibility", "PDV_ARR25_ContentInventory_2026-08-06.csv");
const MATRIX = join(REPO, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
const LEDGER = join(REPO, "references", "vanilla-gameplay", "compatibility", "PDV_ARR25_LegacyCandidateCanonicalReview_2026-08-06.csv");
const REVIEWED_NONE = "[ARR25-CANONICAL-REVIEW: no-current-roster-candidate]";
const REVIEWED_LEDGER = "[ARR25-CANONICAL-REVIEW: ledger-v1]";
const ALIASES = new Map([
  ["Auriel", "Auri-El"], ["Azurah", "Azura"], ["Mauloch", "Malacath"],
  ["Sangiin", "Sanguine"], ["S'rendarr", "Stendarr"],
]);
const EXCLUDED = new Map([
  ["Almalexia", "Tribunal concept is outside the current runtime roster"],
  ["Jone and Jode", "lunar concept is outside the current runtime roster"],
  ["Jyggalag", "locked classify-only; not a reaction-matrix deity"],
  ["Khajiit lane", "cultural lane label, not a deity"],
  ["Mannimarco", "entity classification is outside the current runtime roster"],
  ["Phynaster", "Altmeri ancestor concept is outside the current runtime roster"],
  ["Riddle'Thar", "Khajiiti doctrine concept is outside the current runtime roster"],
  ["Sotha Sil", "Tribunal concept is outside the current runtime roster"],
  ["Vivec", "Tribunal concept is outside the current runtime roster"],
]);

function parseArgs(argv) {
  const result = { write: false, json: false };
  for (const arg of argv) {
    if (arg === "--write") result.write = true;
    else if (arg === "--json") result.json = true;
    else if (arg !== "--check") throw new Error(`Unknown argument: ${arg}`);
  }
  return result;
}

function parseCsv(text) {
  const rows = []; let row = []; let field = ""; let quoted = false; let afterQuote = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (ch === '"') { quoted = false; afterQuote = true; }
      else field += ch;
    } else if (afterQuote) {
      if (ch === ",") { row.push(field); field = ""; afterQuote = false; }
      else if (ch === "\n") { row.push(field); rows.push(row); row = []; field = ""; afterQuote = false; }
      else if (ch !== "\r") throw new Error("Malformed CSV after closing quote");
    } else if (ch === '"') { if (field) throw new Error("Malformed CSV quote"); quoted = true; }
    else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (quoted) throw new Error("CSV ends inside quote");
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((cells) => cells.some(Boolean));
}

function readObjects(path) {
  const rows = parseCsv(readFileSync(path, "utf8")); const header = rows.shift();
  return { header, rows: rows.map((cells, index) => {
    if (cells.length !== header.length) throw new Error(`${path}:${index + 2}: header mismatch`);
    return Object.fromEntries(header.map((key, i) => [key, cells[i]]));
  }) };
}

function quote(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function render(header, rows) {
  return [header, ...rows.map((row) => header.map((key) => row[key] ?? ""))]
    .map((cells) => cells.map(quote).join(",")).join("\r\n") + "\r\n";
}

function parseLegacyMatrixCsv(text) {
  const rows = []; let row = []; let field = ""; let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted && ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
    else if (ch === '"') quoted = !quoted;
    else if (ch === "," && !quoted) { row.push(field); field = ""; }
    else if (ch === "\n" && !quoted) { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((cells) => cells.some(Boolean));
}

function canonicalMatrixNames() {
  const rows = parseLegacyMatrixCsv(readFileSync(MATRIX, "utf8"));
  const header = rows.shift();
  const deity = header.indexOf("deity");
  if (deity < 0) throw new Error("Matrix is missing deity column");
  return [...new Set(rows.map((row) => row[deity]?.trim()).filter(Boolean))].sort();
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const inventory = readObjects(INVENTORY);
  const canonical = canonicalMatrixNames();
  const canonicalSet = new Set(canonical);
  const legacy = inventory.rows.filter((row) => row.candidate_deities.trim() && !row.candidate_deities_canonical.trim() && !row.notes.includes("[ARR25-CANONICAL-REVIEW:"));
  let phrases = new Map();
  const rulings = new Map();
  let ledgerRows = [];
  if (existsSync(LEDGER)) {
    ledgerRows = readObjects(LEDGER).rows;
    for (const row of ledgerRows) {
      phrases.set(row.legacy_phrase, Number(row.affected_rows));
      rulings.set(row.legacy_phrase, row.candidate_deities_canonical.split("|").filter(Boolean));
    }
  } else {
    for (const row of legacy) phrases.set(row.candidate_deities, (phrases.get(row.candidate_deities) ?? 0) + 1);
  }
  for (const [phrase, count] of [...phrases].sort(([a], [b]) => a.localeCompare(b))) {
    if (rulings.has(phrase)) continue;
    let resolved = []; const excluded = []; const reasons = [];
    if (phrase.trim().toLowerCase() === "all") {
      resolved = [...canonical];
      reasons.push("explicit all-deity integration surface; expanded to current matrix authority");
    } else {
      for (const token of phrase.split(/[;,]/).map((value) => value.trim()).filter(Boolean)) {
        const deity = ALIASES.get(token) ?? token;
        if (canonicalSet.has(deity)) {
          if (!resolved.includes(deity)) resolved.push(deity);
          if (ALIASES.has(token)) reasons.push(`${token} reviewed as cultural alias of ${deity}`);
        } else if (EXCLUDED.has(token)) {
          excluded.push(token); reasons.push(`${token}: ${EXCLUDED.get(token)}`);
        } else throw new Error(`No explicit ruling for legacy token: ${token}`);
      }
    }
    rulings.set(phrase, resolved);
    ledgerRows.push({
      legacy_phrase: phrase,
      affected_rows: count,
      candidate_deities_canonical: resolved.join("|"),
      excluded_tokens: excluded.join("|"),
      primary_ruling: reasons.length ? reasons.join("; ") : "names already match current matrix authority",
    });
  }
  const actualCounts = new Map();
  for (const row of inventory.rows) {
    if (row.notes.startsWith("[ARR25-NQ]") || !phrases.has(row.candidate_deities)) continue;
    actualCounts.set(row.candidate_deities, (actualCounts.get(row.candidate_deities) ?? 0) + 1);
  }
  for (const [phrase, expected] of phrases) {
    if ((actualCounts.get(phrase) ?? 0) !== expected) throw new Error(`Review-ledger row-count drift for ${phrase}: expected ${expected}, found ${actualCounts.get(phrase) ?? 0}`);
  }
  let changed = 0; let reviewedNoCandidate = 0;
  for (const row of inventory.rows) {
    if (!rulings.has(row.candidate_deities) || row.notes.startsWith("[ARR25-NQ]")) continue;
    const resolved = rulings.get(row.candidate_deities);
    row.candidate_deities_canonical = resolved.join("|");
    if (!row.notes.includes(REVIEWED_LEDGER)) row.notes = `${row.notes}${row.notes ? " " : ""}${REVIEWED_LEDGER}`;
    if (!resolved.length) {
      if (!row.notes.includes(REVIEWED_NONE)) row.notes = `${row.notes}${row.notes ? " " : ""}${REVIEWED_NONE}`;
      reviewedNoCandidate++;
    }
    changed++;
  }
  const report = {
    status: "PASS", legacyRowsReviewed: [...phrases.values()].reduce((a, b) => a + b, 0), distinctLegacyPhrases: phrases.size,
    rowsMigrated: changed, reviewedNoCurrentRosterCandidate: reviewedNoCandidate,
    currentCanonicalNames: canonical.length,
  };
  if (options.write) {
    writeFileSync(LEDGER, render(["legacy_phrase", "affected_rows", "candidate_deities_canonical", "excluded_tokens", "primary_ruling"], ledgerRows), "utf8");
    writeFileSync(INVENTORY, render(inventory.header, inventory.rows), "utf8");
  }
  if (options.json) console.log(JSON.stringify(report, null, 2));
  else console.log(`${options.write ? "WRITE" : "CHECK"} PASS: ${legacy.length} rows / ${phrases.size} phrases; ${reviewedNoCandidate} row(s) have reviewed non-roster concepts only.`);
}

try { main(); } catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
