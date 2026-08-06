#!/usr/bin/env node
/**
 * Initialise, update, and validate factual-reader checkpoints for the ARR 2.5
 * discovery queue.  These files deliberately do not merge into the inventory:
 * proposed triage is reader evidence, while primary_review remains the only
 * semantic authority.
 */

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const REPO = join(dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = join(REPO, "references", "vanilla-gameplay", "compatibility");
const DEFAULT_WORKLIST = join(COMPAT, "PDV_ARR25_DiscoveryWorklist_2026-08-06.csv");
const DEFAULT_MANIFEST = join(COMPAT, "PDV_ARR25_DiscoveryBatches_2026-08-06.json");
const DEFAULT_DIR = join(COMPAT, "arr25-discovery-checkpoints");
const STATUSES = new Set(["pending", "in_progress", "retry", "complete"]);
const READ_STATUSES = new Set(["pending", "read", "error"]);
const TRIAGES = new Set(["", "ROWABLE", "DEFER", "NO-ROWS"]);
const REVIEW_STATES = new Set(["UNREVIEWED", "APPROVED", "REJECTED"]);
const EVIDENCE_KINDS = new Set(["PLUGIN-PENDING", "PLUGIN-SUMMARY", "PLUGIN-NO-ROWS", "PLUGIN-ERROR", "QUST", "SIGNAL"]);
const QUEST_EXPANSION_CLASSES = new Set(["", "new-definition", "vanilla-override-extra-stages", "existing-stage-edits-only"]);
const HEADER = [
  "input_id", "batch_id", "wave", "separator", "mod", "plugin", "plugin_path",
  "evidence_id", "evidence_kind", "reader_status", "record_signature", "formid", "editor_id", "name",
  "quest_expansion_classification", "stage_numbers", "evidence", "signal_counts",
  "proposed_triage", "proposed_reason", "notes", "primary_review_status",
];

function usage() {
  return `Usage:
  node tools/pdv_arr25_discovery_checkpoint.mjs --init [--batch A001]
  node tools/pdv_arr25_discovery_checkpoint.mjs --check [--batch A001]
  node tools/pdv_arr25_discovery_checkpoint.mjs --batch A001 --status in_progress [--increment-attempt] [--complete INPUT_ID] [--error TEXT | --clear-error]
  node tools/pdv_arr25_discovery_checkpoint.mjs --batch A001 --review-all APPROVED
  node tools/pdv_arr25_discovery_checkpoint.mjs --batch A001 --review-input INPUT_ID --review-evidence EVIDENCE_ID --review-status APPROVED [--triage ROWABLE] [--reason TEXT]

--init never overwrites an existing checkpoint.  Reader evidence belongs in the
batch CSV; it supports multiple QUST/signal rows per plugin. Use robust CSV
tooling or this file's CSV grammar when editing it.`;
}

function parseArgs(argv) {
  const out = { worklist: DEFAULT_WORKLIST, manifest: DEFAULT_MANIFEST, dir: DEFAULT_DIR, init: false, check: false, batch: null, status: null, incrementAttempt: false, completed: [], error: undefined, clearError: false, reviewAll: null, reviewInput: null, reviewEvidence: null, reviewStatus: null, reviewTriage: undefined, reviewReason: undefined, reviewName: undefined, reviewStages: undefined, reviewEvidenceText: undefined };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--worklist") out.worklist = resolve(argv[++i]);
    else if (arg === "--manifest") out.manifest = resolve(argv[++i]);
    else if (arg === "--dir") out.dir = resolve(argv[++i]);
    else if (arg === "--init") out.init = true;
    else if (arg === "--check") out.check = true;
    else if (arg === "--batch") out.batch = argv[++i];
    else if (arg === "--status") out.status = argv[++i];
    else if (arg === "--increment-attempt") out.incrementAttempt = true;
    else if (arg === "--complete") out.completed.push(argv[++i]);
    else if (arg === "--error") out.error = argv[++i];
    else if (arg === "--clear-error") out.clearError = true;
    else if (arg === "--review-all") out.reviewAll = argv[++i];
    else if (arg === "--review-input") out.reviewInput = argv[++i];
    else if (arg === "--review-evidence") out.reviewEvidence = argv[++i];
    else if (arg === "--review-status") out.reviewStatus = argv[++i];
    else if (arg === "--triage") out.reviewTriage = argv[++i];
    else if (arg === "--reason") out.reviewReason = argv[++i];
    else if (arg === "--name") out.reviewName = argv[++i];
    else if (arg === "--stages") out.reviewStages = argv[++i];
    else if (arg === "--evidence") out.reviewEvidenceText = argv[++i];
    else if (arg === "--help" || arg === "-h") { console.log(usage()); process.exit(0); }
    else throw new Error(`Unknown argument: ${arg}`);
  }
  const hasRowReview = Boolean(out.reviewInput || out.reviewEvidence || out.reviewStatus || out.reviewTriage !== undefined || out.reviewReason !== undefined || out.reviewName !== undefined || out.reviewStages !== undefined || out.reviewEvidenceText !== undefined);
  const modes = Number(out.init) + Number(out.check) + Number(Boolean(out.status || out.incrementAttempt || out.completed.length || out.error !== undefined || out.clearError)) + Number(Boolean(out.reviewAll)) + Number(hasRowReview);
  if (modes !== 1) throw new Error("Choose exactly one mode: --init, --check, or a status update");
  if (out.batch && !/^[ABC]\d{3}$/.test(out.batch)) throw new Error("--batch must look like A001");
  if (out.status && !STATUSES.has(out.status)) throw new Error(`Invalid --status: ${out.status}`);
  if ((out.status || out.incrementAttempt || out.completed.length || out.error !== undefined || out.clearError) && !out.batch) throw new Error("Status updates require --batch");
  if (out.error !== undefined && out.clearError) throw new Error("Use either --error or --clear-error, not both");
  if (out.reviewAll && !REVIEW_STATES.has(out.reviewAll)) throw new Error(`Invalid --review-all state: ${out.reviewAll}`);
  if (out.reviewAll && !out.batch) throw new Error("--review-all requires --batch");
  if (hasRowReview && (!out.batch || !out.reviewInput || !out.reviewEvidence || !out.reviewStatus)) {
    throw new Error("Row review requires --batch, --review-input, --review-evidence, and --review-status");
  }
  if (out.reviewStatus && !REVIEW_STATES.has(out.reviewStatus)) throw new Error(`Invalid --review-status state: ${out.reviewStatus}`);
  if (out.reviewTriage !== undefined && !TRIAGES.has(out.reviewTriage)) throw new Error(`Invalid --triage: ${out.reviewTriage}`);
  return out;
}

function parseCsv(text) {
  const rows = []; let row = [], field = "", quoted = false, afterQuote = false;
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
      if (field) throw new Error("Malformed CSV: quote begins inside an unquoted field");
      quoted = true;
    } else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n") { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (quoted) throw new Error("CSV ends inside a quoted field");
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  return rows.filter((cells) => cells.some(Boolean));
}

function quoteCsv(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function renderCsv(rows) {
  return [HEADER, ...rows.map((row) => HEADER.map((key) => row[key] ?? ""))]
    .map((row) => row.map(quoteCsv).join(",")).join("\r\n") + "\r\n";
}

function readWorklist(path) {
  if (!existsSync(path)) throw new Error(`Worklist not found: ${path}`);
  const rows = parseCsv(readFileSync(path, "utf8"));
  const header = rows.shift();
  const expected = ["batch_id", "wave", "separator", "mod", "plugin", "plugin_path", "input_id"];
  if (JSON.stringify(header) !== JSON.stringify(expected)) throw new Error("Worklist header drift");
  const out = [];
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].length !== header.length) throw new Error(`Worklist row ${i + 2} has wrong field count`);
    const entry = Object.fromEntries(header.map((key, index) => [key, rows[i][index]]));
    if (!entry.input_id || !entry.batch_id) throw new Error(`Worklist row ${i + 2} is missing identity`);
    out.push(entry);
  }
  if (new Set(out.map((row) => row.input_id)).size !== out.length) throw new Error("Worklist has duplicate input_id values");
  return out;
}

function readManifest(path) {
  if (!existsSync(path)) throw new Error(`Batch manifest not found: ${path}`);
  const value = JSON.parse(readFileSync(path, "utf8"));
  if (value.schema !== "pdv-arr25-discovery-batches.v1" || !Array.isArray(value.batches)) throw new Error("Batch manifest schema drift");
  const batches = new Map(value.batches.map((batch) => [batch.id, batch]));
  if (batches.size !== value.batches.length) throw new Error("Batch manifest has duplicate IDs");
  return batches;
}

function selectedBatches(batches, requested) {
  if (requested) {
    const batch = batches.get(requested);
    if (!batch) throw new Error(`Unknown batch: ${requested}`);
    return [batch];
  }
  return [...batches.values()];
}

function paths(dir, id) {
  return { csv: join(dir, `${id}.csv`), json: join(dir, `${id}.json`) };
}

function initialRows(worklistRows) {
  return worklistRows.map((row) => ({
    input_id: row.input_id, batch_id: row.batch_id, wave: row.wave, separator: row.separator,
    mod: row.mod, plugin: row.plugin, plugin_path: row.plugin_path,
    evidence_id: "PLUGIN", evidence_kind: "PLUGIN-PENDING", reader_status: "pending",
    record_signature: "", formid: "", editor_id: "", name: "", quest_expansion_classification: "",
    stage_numbers: "", evidence: "", signal_counts: "", proposed_triage: "",
    proposed_reason: "", notes: "", primary_review_status: "UNREVIEWED",
  }));
}

function initialState(batch) {
  return {
    schema: "pdv-arr25-discovery-checkpoint.v1",
    batchId: batch.id,
    wave: batch.wave,
    inputHash: batch.inputHash,
    inputIds: batch.inputIds,
    status: "pending",
    attempts: 0,
    completedInputIds: [],
    lastError: null,
  };
}

function readCheckpointCsv(path) {
  const rows = parseCsv(readFileSync(path, "utf8"));
  const header = rows.shift();
  if (JSON.stringify(header) !== JSON.stringify(HEADER)) throw new Error(`${path}: checkpoint CSV header drift`);
  return rows.map((cells, index) => {
    if (cells.length !== HEADER.length) throw new Error(`${path}: row ${index + 2} has wrong field count`);
    return Object.fromEntries(HEADER.map((key, field) => [key, cells[field]]));
  });
}

function declaredQuestCount(row) {
  const text = `${row.evidence}\n${row.notes}`;
  for (const pattern of [
    /direct\s+QUST\s+enumeration(?:\s+complete)?\s*[:=]?\s*(\d+)/i,
    /(\d+)\s+QUST\s+direct-enumerated/i,
    /exhaustive\s+QUST\s+enumeration\s*[:=]?\s*(\d+)/i,
  ]) {
    const match = text.match(pattern);
    if (match) return Number.parseInt(match[1], 10);
  }
  return null;
}

function validateCheckpoint(batch, expected, dir) {
  const file = paths(dir, batch.id);
  if (!existsSync(file.csv) || !existsSync(file.json)) throw new Error(`${batch.id}: missing checkpoint CSV or JSON`);
  const rows = readCheckpointCsv(file.csv);
  if (rows.length < expected.length) throw new Error(`${batch.id}: CSV row count ${rows.length}; expected at least ${expected.length} plugin rows`);
  const expectedById = new Map(expected.map((row) => [row.input_id, row]));
  const seen = new Set(); const pluginRows = new Map();
  for (const row of rows) {
    if (!expectedById.has(row.input_id)) throw new Error(`${batch.id}: CSV input_id mismatch: ${row.input_id}`);
    const rowKey = `${row.input_id}\0${row.evidence_id}`;
    if (!row.evidence_id || seen.has(rowKey)) throw new Error(`${batch.id}: CSV evidence identity missing or duplicate: ${row.input_id}/${row.evidence_id}`);
    seen.add(rowKey);
    const source = expectedById.get(row.input_id);
    for (const key of ["batch_id", "wave", "separator", "mod", "plugin", "plugin_path"]) {
      if (row[key] !== source[key]) throw new Error(`${batch.id}: ${row.input_id} mutates immutable ${key}`);
    }
    if (!EVIDENCE_KINDS.has(row.evidence_kind)) throw new Error(`${batch.id}: ${row.input_id} invalid evidence_kind`);
    if (!READ_STATUSES.has(row.reader_status)) throw new Error(`${batch.id}: ${row.input_id} invalid reader_status`);
    if (!TRIAGES.has(row.proposed_triage)) throw new Error(`${batch.id}: ${row.input_id} invalid proposed_triage`);
    if (!REVIEW_STATES.has(row.primary_review_status)) throw new Error(`${batch.id}: ${row.input_id} invalid primary_review_status`);
    if (!QUEST_EXPANSION_CLASSES.has(row.quest_expansion_classification)) throw new Error(`${batch.id}: ${row.input_id} invalid quest expansion classification`);
    if (row.evidence_id === "PLUGIN") {
      if (!row.evidence_kind.startsWith("PLUGIN-")) throw new Error(`${batch.id}: ${row.input_id} PLUGIN row has non-plugin evidence kind`);
      if (pluginRows.has(row.input_id)) throw new Error(`${batch.id}: ${row.input_id} has duplicate PLUGIN rows`);
      pluginRows.set(row.input_id, row);
    } else if (row.evidence_kind.startsWith("PLUGIN-")) {
      throw new Error(`${batch.id}: ${row.input_id} plugin evidence must use evidence_id=PLUGIN`);
    }
  }
  for (const id of expectedById.keys()) if (!pluginRows.has(id)) throw new Error(`${batch.id}: ${id} lacks its required PLUGIN evidence row`);
  for (const [id, pluginRow] of pluginRows) {
    const declared = declaredQuestCount(pluginRow);
    if (declared === null || pluginRow.reader_status !== "read") continue;
    const actual = rows.filter((row) => row.input_id === id && row.evidence_kind === "QUST").length;
    if (actual !== declared) {
      throw new Error(`${batch.id}: ${id} declares ${declared} QUST record(s) but has ${actual} QUST evidence row(s)`);
    }
  }
  const state = JSON.parse(readFileSync(file.json, "utf8"));
  if (state.schema !== "pdv-arr25-discovery-checkpoint.v1") throw new Error(`${batch.id}: checkpoint JSON schema drift`);
  if (state.batchId !== batch.id || state.wave !== batch.wave || state.inputHash !== batch.inputHash || JSON.stringify(state.inputIds) !== JSON.stringify(batch.inputIds)) throw new Error(`${batch.id}: checkpoint JSON does not match manifest inputs`);
  if (!STATUSES.has(state.status) || !Number.isInteger(state.attempts) || state.attempts < 0 || !Array.isArray(state.completedInputIds)) throw new Error(`${batch.id}: invalid checkpoint status state`);
  if (new Set(state.completedInputIds).size !== state.completedInputIds.length || state.completedInputIds.some((id) => !expectedById.has(id))) throw new Error(`${batch.id}: completedInputIds are not a unique input subset`);
  if (state.lastError !== null && typeof state.lastError !== "string") throw new Error(`${batch.id}: lastError must be a string or null`);
  const readIds = new Set([...pluginRows.values()].filter((row) => row.reader_status === "read").map((row) => row.input_id));
  if (state.completedInputIds.some((id) => !readIds.has(id))) throw new Error(`${batch.id}: completed input lacks read_status=read`);
  if (state.status === "complete" && (state.completedInputIds.length !== expected.length || state.lastError !== null)) throw new Error(`${batch.id}: complete requires every input read and no lastError`);
  return { file, rows, state };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const worklist = readWorklist(args.worklist);
  const batches = readManifest(args.manifest);
  const workByBatch = new Map();
  for (const row of worklist) {
    if (!workByBatch.has(row.batch_id)) workByBatch.set(row.batch_id, []);
    workByBatch.get(row.batch_id).push(row);
  }
  for (const [id, rows] of workByBatch) {
    const batch = batches.get(id);
    if (!batch || JSON.stringify(rows.map((row) => row.input_id)) !== JSON.stringify(batch.inputIds)) throw new Error(`Worklist / manifest identity drift for ${id}`);
  }
  if (workByBatch.size !== batches.size) throw new Error("Worklist / manifest batch count drift");
  const chosen = selectedBatches(batches, args.batch);

  if (args.init) {
    mkdirSync(args.dir, { recursive: true });
    let created = 0;
    for (const batch of chosen) {
      const file = paths(args.dir, batch.id);
      if (existsSync(file.csv) || existsSync(file.json)) {
        if (!existsSync(file.csv) || !existsSync(file.json)) throw new Error(`${batch.id}: partial checkpoint exists; refusing to overwrite`);
        validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
        continue;
      }
      writeFileSync(file.csv, renderCsv(initialRows(workByBatch.get(batch.id))), "utf8");
      writeFileSync(file.json, JSON.stringify(initialState(batch), null, 2) + "\n", "utf8");
      created++;
    }
    console.log(`PASS: initialized ${created} checkpoint batch(es); existing evidence left intact.`);
    return;
  }

  if (args.check) {
    let completed = 0;
    for (const batch of chosen) {
      const { state } = validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
      if (state.status === "complete") completed++;
    }
    console.log(`PASS: validated ${chosen.length} checkpoint batch(es); ${completed} complete.`);
    return;
  }

  if (args.reviewAll) {
    const batch = chosen[0];
    const { file, rows } = validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
    for (const row of rows) row.primary_review_status = args.reviewAll;
    writeFileSync(file.csv, renderCsv(rows), "utf8");
    validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
    console.log(`PASS: ${batch.id} primary_review_status=${args.reviewAll} for ${rows.length} evidence row(s)`);
    return;
  }

  if (args.reviewInput) {
    const batch = chosen[0];
    const { file, rows } = validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
    const matches = rows.filter((row) => row.input_id === args.reviewInput && row.evidence_id === args.reviewEvidence);
    if (matches.length !== 1) throw new Error(`${batch.id}: expected one review row, found ${matches.length}`);
    const row = matches[0];
    row.primary_review_status = args.reviewStatus;
    if (args.reviewTriage !== undefined) row.proposed_triage = args.reviewTriage;
    if (args.reviewReason !== undefined) row.proposed_reason = args.reviewReason;
    if (args.reviewName !== undefined) row.name = args.reviewName;
    if (args.reviewStages !== undefined) row.stage_numbers = args.reviewStages;
    if (args.reviewEvidenceText !== undefined) row.evidence = args.reviewEvidenceText;
    writeFileSync(file.csv, renderCsv(rows), "utf8");
    validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
    console.log(`PASS: ${batch.id} reviewed ${args.reviewInput}/${args.reviewEvidence} -> ${args.reviewStatus}`);
    return;
  }

  const batch = chosen[0];
  const { file, rows, state } = validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
  if (args.status) state.status = args.status;
  if (args.incrementAttempt) state.attempts++;
  for (const id of args.completed) {
    if (!batch.inputIds.includes(id)) throw new Error(`${batch.id}: --complete ID is not in this batch: ${id}`);
    if (!state.completedInputIds.includes(id)) state.completedInputIds.push(id);
  }
  if (args.error !== undefined) state.lastError = args.error;
  if (args.clearError) state.lastError = null;
  const readPluginIds = new Set(
    rows
      .filter((row) => row.evidence_id === "PLUGIN" && row.reader_status === "read")
      .map((row) => row.input_id),
  );
  const unreadCompleted = state.completedInputIds.filter((id) => !readPluginIds.has(id));
  if (unreadCompleted.length) {
    throw new Error(`${batch.id}: cannot complete unread input(s): ${unreadCompleted.join(", ")}`);
  }
  // Refuse invalid transitions before replacing durable status evidence.
  if (state.status === "complete" && state.completedInputIds.length !== batch.inputIds.length) throw new Error(`${batch.id}: cannot mark complete until all inputs are recorded as complete`);
  if (state.status === "complete" && state.lastError !== null) throw new Error(`${batch.id}: cannot mark complete while lastError is set`);
  writeFileSync(file.json, JSON.stringify(state, null, 2) + "\n", "utf8");
  validateCheckpoint(batch, workByBatch.get(batch.id), args.dir);
  console.log(`PASS: ${batch.id} status=${state.status} attempts=${state.attempts} completed=${state.completedInputIds.length}/${batch.inputIds.length}`);
}

try { main(); }
catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
