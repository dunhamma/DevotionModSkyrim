import fs from "fs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { sameTextToString, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--check"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_quest_tranche_merge" });
const Q = String.fromCharCode(34);
const QUEST_READBACK_CSV = "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv";
const OUTCOME_TAG_NORMALIZATION_CSV = "references/authoring/PDV_QuestReactionMatrix_OutcomeTagNormalization.csv";
// Some historical tranches use the quest's familiar editor ID while the live
// record has a more specific one. Merge on the resolved FormID so those aliases
// cannot produce two cells for the same quest-stage-deity at runtime.
const MANUAL_QUEST_FORMIDS = {
  DA10: "Skyrim.esm:022F08",
  DA13: "Skyrim.esm:08998D",
  DA06: "Skyrim.esm:03B681",
  ccBGSSSE020_Quest: "ccbgssse020-graycowl.esl:00080F",
  ccASVSSE001_QuestE: "ccasvsse001-almsivi.esm:0990EF",
  ccBGSSSE067_Quest2: "ccbgssse067-daedinv.esm:19952A",
  ccMTYSSE001_Quest: "ccmtysse001-knightsofthenine.esl:000865",
  dunHunterQST: "Skyrim.esm:018601",
  FreeformKolskeggrA: "Skyrim.esm:01FD72",
  MQ105U: "Skyrim.esm:0713DC",
  MS05: "Skyrim.esm:053511",
  MS14: "Skyrim.esm:025F3E",
  T01: "Skyrim.esm:023B6C",
  t02: "Skyrim.esm:0211D5",
  T03: "Skyrim.esm:01C48E",
};
const files = [
  "references/authoring/PDV_QuestReactionMatrix_Tranche1.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche2.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche3_TempleFavor.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche4_ThinPantheon.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche5_AspectParity.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche6_CompatCore.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche7_CrossEcho.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche8_PoolExpansion.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche10_SignalFloor.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche11_MainQuestFullCoverage.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche12_KhajiitFiveWealth.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche13_HircineBeastBlood.csv",
  "references/authoring/PDV_QuestReactionMatrix_CreationClubCore_2026-08-07.csv",
  // Reconciliation source, NOT a content tranche. The Innocence Lost QE s198
  // rows (ARR patchlist TODO-2, owner-ruled 2026-07-16) were authored straight
  // into Full.csv and never landed in a tranche, so the merge could not
  // reproduce them; the next regen would have silently dropped all four. Kept
  // as its own file so the historical tranches stay the record of what each
  // authoring pass actually shipped. See --check below.
  "references/authoring/PDV_QuestReactionMatrix_Reconciliation_2026-08-06.csv",
];
// A gate's verdict is its EXIT CODE. --check re-derives the merge, byte-compares
// against the on-disk Full.csv, and exits 1 on any drift WITHOUT writing.
// Callers must branch on the exit status, never on grepped output.
const checkOnly = process.argv.slice(2).includes("--check");
const FULL_CSV = "references/authoring/PDV_QuestReactionMatrix_Full.csv";
let hdr = null;
const rawBody = [];
for (const f of files) {
  const l = fs.readFileSync(f, "utf8").split(/\r?\n/).filter((x) => x.trim());
  if (!hdr) hdr = l[0];
  else if (l[0] !== hdr) { console.error("HEADER MISMATCH in " + f); process.exit(1); }
  rawBody.push(...l.slice(1));
}
function cells(line) {
  const out = [];
  let cur = "", q = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (q && ch === Q && line[i + 1] === Q) { cur += Q; i++; }
    else if (ch === Q) q = !q;
    else if (ch === "," && !q) { out.push(cur); cur = ""; }
    else cur += ch;
  }
  out.push(cur);
  return out;
}
function questFormIndex() {
  const [header, ...body] = fs.readFileSync(QUEST_READBACK_CSV, "utf8").split(/\r?\n/).filter((x) => x.trim());
  const columns = cells(header);
  const indexOf = (name) => columns.indexOf(name);
  const editorId = indexOf("editor_id");
  const readbackEditorId = indexOf("readback_editor_id");
  const formId = indexOf("formid");
  if (editorId < 0 || readbackEditorId < 0 || formId < 0) {
    throw new Error(`Missing required quest readback columns in ${QUEST_READBACK_CSV}`);
  }
  const out = new Map();
  for (const line of body) {
    const row = cells(line);
    const resolved = row[formId]?.trim();
    if (!resolved) continue;
    for (const alias of [row[editorId], row[readbackEditorId]]) {
      const key = alias?.trim();
      if (key && !out.has(key)) out.set(key, resolved);
    }
  }
  for (const [editor, form] of Object.entries(MANUAL_QUEST_FORMIDS)) {
    out.set(editor, form);
  }
  return out;
}
const questForms = questFormIndex();
function canonicalQuestCellKey(row) {
  const editorId = row[0]?.trim();
  const resolvedFormId = questForms.get(editorId);
  // Preserve the old editor-ID isolation for unresolvable third-party rows;
  // the compiler remains the authority that rejects any row it cannot route.
  const quest = resolvedFormId ?? `editor:${editorId}`;
  return `${quest}|${row[2]}|${row[5]}`;
}
const rank = (row) => (row[8] === "milestone" ? 100 : 0) + ({ C: 30, S: 20, m: 10 }[row[7]] ?? 0);
const byCell = new Map();
for (let i = 0; i < rawBody.length; i++) {
  const row = cells(rawBody[i]);
  const key = canonicalQuestCellKey(row);
  if (!byCell.has(key)) byCell.set(key, []);
  byCell.get(key).push({ line: rawBody[i], row, order: i });
}
const body = [];
let duplicateRowsRemoved = 0;
for (const [key, entries] of byCell) {
  let candidates = entries;
  const valences = new Set(entries.map((entry) => entry.row[6]));
  if (valences.size > 1) {
    if (key === "Skyrim.esm:01C48E|100|Kynareth" || key === "Skyrim.esm:01C48E|100|Y'ffre") {
      candidates = entries.filter((entry) => entry.row[6] === "-");
    } else {
      console.error(`CONFLICTING VALENCE for ${key}`);
      process.exit(1);
    }
  }
  candidates.sort((a, b) => rank(b.row) - rank(a.row) || a.order - b.order);
  body.push(candidates[0].line);
  duplicateRowsRemoved += entries.length - 1;
}
function csvCell(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `${Q}${text.replaceAll(Q, Q + Q)}${Q}` : text;
}
function loadOutcomeTagNormalizations() {
  const lines = fs.readFileSync(OUTCOME_TAG_NORMALIZATION_CSV, "utf8").split(/\r?\n/).filter((x) => x.trim());
  const header = cells(lines.shift());
  const expected = ["editor_id", "outcome_stage", "act_tags", "reason"];
  if (header.length !== expected.length || header.some((name, index) => name !== expected[index])) {
    throw new Error(`HEADER MISMATCH in ${OUTCOME_TAG_NORMALIZATION_CSV}`);
  }
  const out = new Map();
  for (const line of lines) {
    const row = cells(line);
    const key = `${row[0]}|${row[1]}`;
    if (!row[0] || !row[1] || !row[2] || !row[3]) throw new Error(`Malformed outcome-tag normalization: ${line}`);
    if (out.has(key)) throw new Error(`Duplicate outcome-tag normalization: ${key}`);
    out.set(key, row[2]);
  }
  return out;
}
const outcomeTagNormalizations = loadOutcomeTagNormalizations();
const normalizedKeysSeen = new Set();
for (let index = 0; index < body.length; index++) {
  const row = cells(body[index]);
  const key = `${row[0]}|${row[2]}`;
  const normalizedTags = outcomeTagNormalizations.get(key);
  if (!normalizedTags) continue;
  row[4] = normalizedTags;
  body[index] = row.map(csvCell).join(",");
  normalizedKeysSeen.add(key);
}
for (const key of outcomeTagNormalizations.keys()) {
  if (!normalizedKeysSeen.has(key)) throw new Error(`Outcome-tag normalization key not found in merged matrix: ${key}`);
}
function eid(line) { let cur = "", q = false; for (const ch of line) { if (ch === Q) q = !q; else if (ch === "," && !q) return cur; else cur += ch; } return cur; }
const idx = body.map((line, i) => [line, i]);
idx.sort((a, b) => { const ea = eid(a[0]).toLowerCase(), eb = eid(b[0]).toLowerCase(); return ea < eb ? -1 : ea > eb ? 1 : a[1] - b[1]; });
const rendered = [hdr, ...idx.map((x) => x[0])].join("\r\n") + "\r\n";
if (checkOnly) {
  const onDisk = fs.existsSync(FULL_CSV) ? fs.readFileSync(FULL_CSV, "utf8") : null;
  if (sameTextToString(FULL_CSV, rendered)) {
    console.log("PASS: Full.csv reproduces from the tranche sources:", body.length, "cells");
  } else {
    // Report the differing KEYS, not a byte offset -- a single reordered row
    // would otherwise bury the real payload drift under a whole-file diff.
    const keyOf = (line) => canonicalQuestCellKey(cells(line));
    const derivedMap = new Map(idx.map((x) => [keyOf(x[0]), x[0]]));
    const diskMap = new Map();
    if (onDisk !== null) {
      for (const line of onDisk.split(/\r?\n/).slice(1).filter((x) => x.trim())) diskMap.set(keyOf(line), line);
    }
    const onlyDisk = [...diskMap.keys()].filter((k) => !derivedMap.has(k));
    const onlyDerived = [...derivedMap.keys()].filter((k) => !diskMap.has(k));
    const changed = [...derivedMap].filter(([k, v]) => diskMap.has(k) && diskMap.get(k) !== v).map(([k]) => k);
    console.error("FAIL: Full.csv does not reproduce from the tranche sources.");
    if (onDisk === null) console.error("  " + FULL_CSV + " is missing.");
    console.error(`  derived ${derivedMap.size} cells | on-disk ${diskMap.size} cells`);
    for (const k of onlyDisk) console.error("  ONLY IN Full.csv (no tranche produces it): " + k);
    for (const k of onlyDerived) console.error("  ONLY IN tranches (missing from Full.csv): " + k);
    for (const k of changed) {
      console.error("  PAYLOAD DIFFERS: " + k);
      console.error("    Full.csv : " + diskMap.get(k));
      console.error("    tranches : " + derivedMap.get(k));
    }
    if (!onlyDisk.length && !onlyDerived.length && !changed.length) {
      console.error("  Cell sets and payloads agree; the difference is row ORDER or line endings.");
    }
    console.error("  Re-run without --check to regenerate, or fix the tranche source.");
    process.exit(1);
  }
} else {
  writeTextWithEol(FULL_CSV, rendered, "crlf");
  console.log("Wrote Full.csv:", body.length, `cells (${duplicateRowsRemoved} duplicate rows resolved by canonical merge)`);
}
function parse(f) { const t = fs.readFileSync(f, "utf8").split(/\r?\n/).filter((x) => x.trim()); t.shift(); return t.map((line) => { const c = []; let cur = "", q = false; for (const ch of line) { if (ch === Q) q = !q; else if (ch === "," && !q) { c.push(cur); cur = ""; } else cur += ch; } c.push(cur); return c; }); }
const r = parse("references/authoring/PDV_QuestReactionMatrix_Full.csv");
const d = {};
for (const row of r) { const dt = row[5], val = row[6], mag = row[8]; if (!d[dt]) d[dt] = { g: 0, gm: 0, l: 0, lm: 0 }; const o = d[dt]; if (val === "+") { o.g++; if (mag === "milestone") o.gm++; } else { o.l++; if (mag === "milestone") o.lm++; } }
console.log("Total cells:", r.length, "| Deities:", Object.keys(d).length, "| Quests:", new Set(r.map((x) => x[0])).size);
const focus = ["Dibella", "Mara", "Kynareth", "Zenithar", "Stendarr", "Arkay", "Meridia", "Tu" + String.fromCharCode(39) + "whacca"];
console.log("\nTHIN-AEDRA / TOUCHED DEITIES (gain[ms] / loss[ms] / net):");
for (const k of focus) { const v = d[k]; if (!v) { console.log(k, "(absent)"); continue; } console.log(k.padEnd(12), "gain " + v.g + "(" + v.gm + "ms)  loss " + v.l + "(" + v.lm + "ms)  net " + ((v.g - v.l) >= 0 ? "+" : "") + (v.g - v.l)); }
console.log("\nLoss-only deities now:", Object.entries(d).filter(([k, v]) => v.g === 0).map((x) => x[0]).join(", ") || "(none)");
console.log("Thin (<=2) now:", Object.entries(d).filter(([k, v]) => v.g + v.l <= 2).map((x) => x[0]).join(", "));
