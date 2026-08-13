#!/usr/bin/env node
/**
 * Reconcile the exhaustive ARR 2.5 non-quest signal sweep into the content
 * inventory. Every direct-read SIGNAL occurrence is reduced to its defining
 * record identity (signature|plugin|local FormID), so patches and updates
 * cannot manufacture duplicate candidates. Only primary-reviewed evidence is
 * accepted. This tool never decides gameplay implementation or support state.
 *
 * Usage:
 *   node tools/pdv_arr25_nonquest_inventory_apply.mjs --check [--json]
 *   node tools/pdv_arr25_nonquest_inventory_apply.mjs --write [--json]
 */

import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = join(REPO, "references", "vanilla-gameplay", "compatibility");
const CHECKPOINTS = join(COMPAT, "arr25-nonquest-checkpoints");
const INVENTORY = join(COMPAT, "PDV_ARR25_ContentInventory_2026-08-06.csv");
const REPORT = join(COMPAT, "PDV_ARR25_NonQuestInventoryClosure_2026-08-06.json");
const MANAGED = "[ARR25-NQ]";
const HEADER = [
  "separator", "mod", "plugin", "signature", "formid", "editor_id", "name",
  "covered_by", "triage", "candidate_deities", "notes",
  "candidate_deities_canonical", "reachable_races",
];
const SIGNATURES = {
  Activator: "ACTI", Armor: "ARMO", ObjectEffect: "ENCH", Keyword: "KYWD",
  FormList: "FLST", Spell: "SPEL", Faction: "FACT", MiscItem: "MISC",
  Ingredient: "INGR", Container: "CONT", Location: "LCTN", Flora: "FLOR",
  Tree: "TREE", Book: "BOOK", Perk: "PERK", Scroll: "SCRL", Weapon: "WEAP",
  AlchemyItem: "ALCH",
};

function args(argv) {
  const result = { mode: null, json: false };
  for (const arg of argv) {
    if (arg === "--check" || arg === "--write") {
      if (result.mode) throw new Error("Choose exactly one of --check or --write");
      result.mode = arg.slice(2);
    } else if (arg === "--json") result.json = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  if (!result.mode) throw new Error("Use --check or --write");
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
      else if (ch !== "\r") throw new Error(`Malformed CSV after closing quote: ${JSON.stringify(ch)}`);
    } else if (ch === '"') {
      if (field) throw new Error("Malformed CSV: quote starts inside an unquoted field");
      quoted = true;
    } else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (quoted) throw new Error("CSV ends inside a quoted field");
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((cells) => cells.some((cell) => cell !== ""));
}

function objects(path) {
  const rows = parseCsv(readFileSync(path, "utf8"));
  if (!rows.length) throw new Error(`Empty CSV: ${path}`);
  const header = rows.shift();
  return { header, rows: rows.map((cells, index) => {
    if (cells.length !== header.length) throw new Error(`${basename(path)}:${index + 2}: ${cells.length} fields; expected ${header.length}`);
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

function signature(value) {
  const trimmed = value.trim();
  const normalized = SIGNATURES[trimmed] ?? trimmed.toUpperCase();
  if (!/^[A-Z0-9]{4}$/.test(normalized)) throw new Error(`Unknown record signature: ${value}`);
  return normalized;
}

function identity(row) {
  const match = row.formid.trim().match(/^([0-9A-Fa-f]{6,8}):(.+\.(?:esm|esp|esl))$/i);
  if (!match) throw new Error(`${row.batch_id}/${row.input_id}: malformed FormKey ${JSON.stringify(row.formid)}`);
  const sig = signature(row.record_signature);
  const hex = match[1].toUpperCase().padStart(6, "0");
  const plugin = match[2].trim();
  return { key: `${sig}|${plugin.toLowerCase()}|${hex}`, sig, definingPlugin: plugin, hex, inventoryFormId: `${plugin}:${hex}` };
}

function canonicalFor(row) {
  const editor = row.editor_id.toLowerCase();
  const mod = row.mod.toLowerCase();
  const plugin = row.definingPlugin.toLowerCase();
  if (/lunarguard/.test(editor + mod + plugin)) return ["Alkosh"];
  if (/authoria_food_cooked_|foodgourd|mihail.*(?:meat|food)|drinktea|kvsweets/.test(editor)) return ["Y'ffre"];
  if (/dibellashrine/.test(editor)) return ["Dibella"];
  if (/zenitharshrine/.test(editor)) return ["Zenithar"];
  if (/shrineofmara/.test(editor)) return ["Mara"];
  if (/shrineofnocturnal/.test(editor)) return ["Nocturnal"];
  if (/shrineoftalos/.test(editor)) return ["Talos"];
  if (/shrineofkynareth/.test(editor)) return ["Kynareth"];
  if (/kyne/.test(editor) && /(?:shrine|prayer)/.test(editor)) return ["Kyne"];
  if (/boethiah/.test(editor)) return ["Boethiah"];
  if (/thedeadlands/.test(editor)) return ["Mehrunes Dagon"];
  if (/deathoftiber|sonsofempire|tibernote/.test(editor)) return ["Talos"];
  if (/unclesweetshare/.test(editor)) return ["Sheogorath"];
  if (/brandy/.test(editor)) return ["Sanguine"];
  if (plugin === "aqua.esl") return ["Hermaeus Mora"];
  if (plugin === "ghostlight.esl") return ["Stendarr", "Meridia"];
  if (editor === "_k01_radiantoppression") return ["Stendarr", "Meridia"];
  if (editor === "_k01_celestialvortex") return ["Magnus"];
  if (editor === "_k01_naturesfury") return ["Y'ffre", "Kyne", "Kynareth"];
  return [];
}

function sourceOccurrenceScore(row, definingPlugin) {
  let score = row.primary_review_status === "APPROVED" ? 100 : 0;
  if (row.plugin.toLowerCase() === definingPlugin.toLowerCase()) score += 20;
  if (!/(?:update|hotfix|patch|fix)/i.test(row.mod)) score += 5;
  return score;
}

function main() {
  const options = args(process.argv.slice(2));
  if (!existsSync(INVENTORY) || !existsSync(CHECKPOINTS)) throw new Error("Required inventory/checkpoint path is missing");
  const inventory = objects(INVENTORY);
  if (JSON.stringify(inventory.header) !== JSON.stringify(HEADER)) throw new Error("Inventory header drift");
  const files = readdirSync(CHECKPOINTS).filter((name) => /^NQ\d{3}\.csv$/.test(name)).sort();
  if (files.length !== 107) throw new Error(`Expected 107 checkpoint CSVs; found ${files.length}`);

  const occurrences = [];
  let pluginPaths = 0;
  for (const file of files) {
    const id = file.slice(0, -4);
    const manifestPath = join(CHECKPOINTS, `${id}.json`);
    if (!existsSync(manifestPath)) throw new Error(`${id}: missing manifest`);
    const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
    if (manifest.status !== "complete" || manifest.lastError !== null) throw new Error(`${id}: incomplete or errored manifest`);
    const inputs = [...manifest.inputIds].sort();
    const completed = [...manifest.completedInputIds].sort();
    if (JSON.stringify(inputs) !== JSON.stringify(completed)) throw new Error(`${id}: completedInputIds do not equal inputIds`);
    pluginPaths += inputs.length;
    const checkpoint = objects(join(CHECKPOINTS, file)).rows;
    for (const row of checkpoint.filter((item) => item.evidence_kind === "SIGNAL")) {
      if (!row.reader_status.startsWith("read")) throw new Error(`${id}/${row.input_id}: signal read is unresolved`);
      if (!['APPROVED', 'REJECTED'].includes(row.primary_review_status)) throw new Error(`${id}/${row.input_id}: unresolved primary review`);
      if (!['ROWABLE', 'DEFER', 'NO-ROWS'].includes(row.proposed_triage)) throw new Error(`${id}/${row.input_id}: invalid triage ${row.proposed_triage}`);
      occurrences.push({ ...row, ...identity(row) });
    }
  }
  if (pluginPaths !== 1070) throw new Error(`Expected 1070 plugin paths; found ${pluginPaths}`);

  const groups = new Map();
  for (const row of occurrences) {
    if (!groups.has(row.key)) groups.set(row.key, []);
    groups.get(row.key).push(row);
  }
  const managedRows = [];
  for (const [key, rows] of [...groups].sort(([a], [b]) => a.localeCompare(b))) {
    const approved = rows.filter((row) => row.primary_review_status === "APPROVED");
    const candidates = approved.length ? approved : rows;
    const exemplar = [...candidates].sort((a, b) =>
      sourceOccurrenceScore(b, b.definingPlugin) - sourceOccurrenceScore(a, a.definingPlugin)
      || a.batch_id.localeCompare(b.batch_id)
      || a.input_id.localeCompare(b.input_id)
      || a.mod.localeCompare(b.mod))[0];
    const triage = approved.some((row) => row.proposed_triage === "ROWABLE") ? "ROWABLE"
      : approved.length ? "DEFER" : "NO-ROWS";
    const deities = approved.length ? canonicalFor(exemplar) : [];
    const reason = exemplar.proposed_reason || exemplar.notes || "Primary-reviewed non-quest signal verdict.";
    managedRows.push({
      separator: exemplar.separator,
      mod: exemplar.mod,
      plugin: exemplar.plugin,
      signature: exemplar.sig,
      formid: exemplar.inventoryFormId,
      editor_id: exemplar.editor_id,
      name: exemplar.name,
      covered_by: "none",
      triage,
      candidate_deities: deities.join("; "),
      notes: `${MANAGED} ${approved.length ? "Retained" : "Rejected"} after direct record review; ${rows.length} load-order occurrence(s) reconciled to defining record ${key}. ${reason}`,
      candidate_deities_canonical: deities.join("|"),
      reachable_races: "",
    });
  }

  const unmanaged = inventory.rows.filter((row) => !row.notes.startsWith(MANAGED));
  const unmanagedKeys = new Map();
  const sweptSignatures = new Set([...groups.keys()].map((key) => key.split("|", 1)[0]));
  for (const row of unmanaged) {
    if (!row.formid || !groups.size) continue;
    const match = row.formid.match(/^(.+\.(?:esm|esp|esl)):([0-9A-Fa-f]{6,8})$/i);
    if (!match) continue;
    const sig = SIGNATURES[row.signature] ?? row.signature.toUpperCase();
    if (!sweptSignatures.has(sig)) continue;
    const key = `${sig}|${match[1].toLowerCase()}|${match[2].toUpperCase().padStart(6, "0")}`;
    if (!groups.has(key)) continue;
    if (!unmanagedKeys.has(key)) unmanagedKeys.set(key, []);
    unmanagedKeys.get(key).push(row);
  }
  const duplicates = [...unmanagedKeys].filter(([, rows]) => rows.length > 1);
  if (duplicates.length) throw new Error(`Existing inventory has ${duplicates.length} duplicate non-quest natural key(s)`);
  const append = managedRows.filter((row) => {
    const match = row.formid.match(/^(.+):([0-9A-F]+)$/);
    return !unmanagedKeys.has(`${row.signature}|${match[1].toLowerCase()}|${match[2]}`);
  });
  const proposed = [...unmanaged, ...append];
  const proposedKeys = new Map();
  for (const row of proposed) {
    if (!row.notes.startsWith(MANAGED)) continue;
    const match = row.formid.match(/^(.+\.(?:esm|esp|esl)):([0-9A-Fa-f]{6,8})$/i);
    const key = `${row.signature}|${match[1].toLowerCase()}|${match[2].toUpperCase().padStart(6, "0")}`;
    proposedKeys.set(key, (proposedKeys.get(key) ?? 0) + 1);
  }
  const missing = [...groups.keys()].filter((key) => !unmanagedKeys.has(key) && !proposedKeys.has(key));
  const outside = [...proposedKeys.keys()].filter((key) => !groups.has(key));
  const managedDuplicates = [...proposedKeys].filter(([, count]) => count !== 1);
  if (missing.length || outside.length || managedDuplicates.length) {
    throw new Error(`Projected closure failure: missing=${missing.length}, outside=${outside.length}, duplicates=${managedDuplicates.length}`);
  }

  const approvedOccurrences = occurrences.filter((row) => row.primary_review_status === "APPROVED").length;
  const approvedKeys = new Set(occurrences.filter((row) => row.primary_review_status === "APPROVED").map((row) => row.key));
  const report = {
    schema: "pdv-arr25-nonquest-inventory-closure.v1",
    generatedAt: new Date().toISOString(),
    checkpointBatches: files.length,
    pluginPaths,
    signalOccurrences: occurrences.length,
    uniqueNaturalSignals: groups.size,
    duplicateOccurrences: occurrences.length - groups.size,
    approvedOccurrences,
    approvedUniqueSignals: approvedKeys.size,
    rejectedUniqueSignals: groups.size - approvedKeys.size,
    existingCoveredSignals: unmanagedKeys.size,
    appendedSignals: append.length,
    projectedInventoryRows: proposed.length,
    unresolvedReadFailures: 0,
    unresolvedPrimaryReviews: 0,
    closure: "PASS",
  };
  if (options.mode === "write") {
    writeFileSync(INVENTORY, render(HEADER, proposed), "utf8");
    writeFileSync(REPORT, JSON.stringify(report, null, 2) + "\n", "utf8");
  }
  if (options.json) console.log(JSON.stringify(report, null, 2));
  else console.log(`${options.mode.toUpperCase()} PASS: ${groups.size} unique natural signals from ${occurrences.length} occurrences; ${approvedKeys.size} retained, ${groups.size - approvedKeys.size} rejected; ${append.length} managed rows.`);
}

try { main(); } catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
