#!/usr/bin/env node
/**
 * Append one mod-level inventory verdict for fully primary-reviewed discovery
 * evidence. This is intentionally conservative: it never invents deity
 * candidates, never overwrites an existing mod verdict, and refuses any mod
 * that still contains an UNREVIEWED QUST/SIGNAL row.
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = join(REPO, "references", "vanilla-gameplay", "compatibility");
const CHECKPOINTS = join(COMPAT, "arr25-discovery-checkpoints");
const INVENTORY = join(COMPAT, "PDV_ARR25_ContentInventory_2026-08-06.csv");
const INVENTORY_HEADER = [
  "separator", "mod", "plugin", "signature", "formid", "editor_id", "name",
  "covered_by", "triage", "candidate_deities", "notes",
  "candidate_deities_canonical", "reachable_races",
];

function parseArgs(argv) {
  const out = { batches: [], write: false };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--batch") out.batches.push(...argv[++i].split(",").map((v) => v.trim()).filter(Boolean));
    else if (argv[i] === "--write") out.write = true;
    else throw new Error(`Unknown argument: ${argv[i]}`);
  }
  if (!out.batches.length || out.batches.some((id) => !/^[ABC]\d{3}$/.test(id))) {
    throw new Error("Use --batch C019[,C020...] [--write]");
  }
  return out;
}

function parseCsv(text) {
  const rows = []; let row = []; let field = ""; let quoted = false;
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

function readObjects(path) {
  const rows = parseCsv(readFileSync(path, "utf8"));
  const header = rows.shift();
  return { header, rows: rows.map((cells) => Object.fromEntries(header.map((key, i) => [key, cells[i] ?? ""]))) };
}

function escapeCsv(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(header, rows) {
  return [header, ...rows.map((row) => header.map((key) => row[key] ?? ""))]
    .map((cells) => cells.map(escapeCsv).join(",")).join("\n") + "\n";
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const inventory = readObjects(INVENTORY);
  if (JSON.stringify(inventory.header) !== JSON.stringify(INVENTORY_HEADER)) throw new Error("Inventory header drift");
  const existingMods = new Set(inventory.rows.map((row) => row.mod));
  const proposals = [];

  for (const batch of args.batches) {
    const path = join(CHECKPOINTS, `${batch}.csv`);
    if (!existsSync(path)) throw new Error(`${batch}: checkpoint CSV missing`);
    const checkpoint = readObjects(path).rows;
    const byMod = new Map();
    for (const row of checkpoint) {
      if (!byMod.has(row.mod)) byMod.set(row.mod, []);
      byMod.get(row.mod).push(row);
    }
    for (const [mod, rows] of byMod) {
      if (existingMods.has(mod)) continue;
      const actionable = rows.filter((row) => row.evidence_kind === "QUST" || row.evidence_kind === "SIGNAL");
      const unreviewed = actionable.filter((row) => row.primary_review_status === "UNREVIEWED");
      if (unreviewed.length) throw new Error(`${batch}: ${mod} still has ${unreviewed.length} unreviewed actionable row(s)`);
      const triages = actionable.map((row) => row.proposed_triage);
      if (actionable.some((row) => !["ROWABLE", "DEFER", "NO-ROWS"].includes(row.proposed_triage))) {
        throw new Error(`${batch}: ${mod} has reviewed evidence without a final triage`);
      }
      const triage = triages.includes("ROWABLE") ? "ROWABLE" : triages.includes("DEFER") ? "DEFER" : "NO-ROWS";
      const pluginRows = rows.filter((row) => row.evidence_id === "PLUGIN");
      const uniquePlugins = [...new Set(pluginRows.map((row) => row.plugin))];
      const rowable = triages.filter((value) => value === "ROWABLE").length;
      const deferred = triages.filter((value) => value === "DEFER").length;
      const noRows = triages.filter((value) => value === "NO-ROWS").length;
      const notes = actionable.length
        ? `Primary-reviewed ${batch} summary across ${uniquePlugins.length} plugin path(s): ${actionable.length} actionable record(s); ${rowable} ROWABLE, ${deferred} DEFER, ${noRows} NO-ROWS. Record-level reasons and duplicate reconciliation remain in the checkpoint.`
        : `Direct-read ${batch} summary across ${uniquePlugins.length} plugin path(s): zero QUST/SIGNAL records; structural NO-ROWS.`;
      proposals.push({
        separator: pluginRows[0]?.separator ?? rows[0].separator,
        mod,
        plugin: uniquePlugins[0] ?? rows[0].plugin,
        signature: actionable.length ? "QUST" : "NONE",
        formid: "", editor_id: "", name: "", covered_by: "none", triage,
        candidate_deities: "", notes, candidate_deities_canonical: "", reachable_races: "",
      });
      existingMods.add(mod);
    }
  }

  console.log(`${args.write ? "WRITE" : "CHECK"}: ${proposals.length} new mod verdict(s) from ${args.batches.join(", ")}.`);
  for (const row of proposals) console.log(`${row.triage}\t${row.mod}`);
  if (args.write && proposals.length) writeFileSync(INVENTORY, renderCsv(INVENTORY_HEADER, [...inventory.rows, ...proposals]), "utf8");
}

try { main(); } catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
