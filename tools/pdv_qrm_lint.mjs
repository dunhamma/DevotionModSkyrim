#!/usr/bin/env node
// Row-level lint for every quest-reaction CSV: the core tranches AND the per-mod channels.
//
// WHY. Four of the five things checked here are enforced NOWHERE ELSE, and each fails the
// same way -- quietly.
//
//   act_tags   Read by cross_gen, the equity audit and the signal-floor audits; validated by
//              none of them. An off-vocabulary tag matches no deity profile, so it yields no
//              fan-out candidates and no error. The ROW still awards -- its deity, valence
//              and magnitude are hand-authored and the runtime treats the tag as an opaque
//              string it copies into a snapshot. What is lost is the ability to ask "which
//              other gods care about this act", and visibility to the equity audit.
//   deity      Gated only since 2026-08-09 for channels, and only by name resolution.
//   magnitude  `echo` was retired 2026-07-09. Nothing rejects it.
//   formid     A malformed token throws at compile, but with a less specific message.
//   citation   A row derived from an objective rather than journal text must say
//              RUNTIME-VERIFY. That was a documented convention with no enforcement.
//
// The vocabularies are PARSED, never hardcoded -- see tools/lib/pdv_matrix_vocab.mjs. A lint
// that pins the list it checks against is pinning, not verifying.
//
// WAIVERS. Off-vocabulary act tags predate this tool: rows authored through the ARR
// reconciliation lane carry tags Part A never had. They are waived by name in
// references/authoring/PDV_QRMLintWaivers.csv so today's content passes, and so that every
// waiver is a line someone has to look at rather than a silence. A NEW tag outside Part A
// fails: the ratchet only turns one way.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { acceptedDeityNames, actTagVocabulary, isKnownActTag, daedricSlugs, badDaedricSlug } from "./lib/pdv_matrix_vocab.mjs";

const KNOWN_FLAGS = new Set(["--csv", "--json", "--list-unknown-tags"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_qrm_lint" });

const argv = process.argv.slice(2);
const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const AUTHORING = path.join(REPO, "references", "authoring");
const WAIVERS = path.join(AUTHORING, "PDV_QRMLintWaivers.csv");

function parseCsvLine(line) {
  const cells = [];
  let cur = "";
  let inQ = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (inQ) {
      if (ch === '"' && line[i + 1] === '"') { cur += '"'; i += 1; }
      else if (ch === '"') inQ = false;
      else cur += ch;
    } else if (ch === '"') inQ = true;
    else if (ch === ",") { cells.push(cur); cur = ""; }
    else cur += ch;
  }
  cells.push(cur);
  return cells;
}

function readRows(file) {
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((l) => l.trim() !== "");
  if (!lines.length) return { header: [], rows: [] };
  const header = parseCsvLine(lines[0]).map((h) => h.trim().toLowerCase());
  const rows = lines.slice(1).map((l, i) => {
    const cells = parseCsvLine(l);
    return { _line: i + 2, ...Object.fromEntries(header.map((h, j) => [h, (cells[j] ?? "").trim()])) };
  });
  return { header, rows };
}

// Both families, same rule. Auxiliary files without a deity column are skipped by shape, not
// by name, so a new auxiliary CSV does not need this tool edited.
function targetFiles() {
  const explicit = argv.indexOf("--csv");
  if (explicit !== -1 && argv[explicit + 1] && !argv[explicit + 1].startsWith("--")) {
    return [argv[explicit + 1]];
  }
  const files = [];
  for (const f of fs.readdirSync(AUTHORING)) {
    if (/^PDV_QuestReactionMatrix.*\.csv$/i.test(f)) files.push(path.join(AUTHORING, f));
  }
  const patches = path.join(AUTHORING, "patches");
  if (fs.existsSync(patches)) {
    for (const f of fs.readdirSync(patches)) {
      if (/^PDV_QRM_.*\.csv$/i.test(f)) files.push(path.join(patches, f));
    }
  }
  return files;
}

function loadWaivedTags() {
  if (!fs.existsSync(WAIVERS)) return new Set();
  const { rows } = readRows(WAIVERS);
  return new Set(rows.map((r) => r.act_tag).filter(Boolean));
}

const vocab = actTagVocabulary(REPO);
const deities = acceptedDeityNames(REPO);
const daedric = daedricSlugs(REPO);
const waived = loadWaivedTags();
const failures = [];
const issues = [...vocab.issues, ...deities.issues, ...daedric.issues];

const MAGNITUDES = new Set(["small", "milestone"]);
const VALENCES = new Set(["+", "-"]);
const INTENSITIES = new Set(["C", "S", "m"]);
const FORMID = /^[^:]+\.(esp|esm|esl):[0-9A-Fa-f]{6}$/i;

const unknownTagHits = new Map();
let rowsChecked = 0;
let filesChecked = 0;

const skipped = [];
for (const file of targetFiles()) {
  const rel = path.relative(REPO, file);
  const { header, rows } = readRows(file);
  // Shape, not filename, decides what this tool owns -- so a new auxiliary CSV needs no edit
  // here. BOTH columns are required: PartD_ThinGodFaucets has `deity` but is a repeatable
  // ACTIVITY table with no outcome_stage at all, and testing `deity` alone reported all 27 of
  // its rows as malformed quest rows. A schema mismatch is not a finding.
  if (!header.includes("deity") || !header.includes("outcome_stage")) {
    if (header.includes("deity")) skipped.push(`${rel} (no outcome_stage column -- not a quest-outcome table)`);
    continue;
  }
  filesChecked += 1;
  for (const r of rows) {
    rowsChecked += 1;
    const at = `${rel}:${r._line} ${r.editor_id ?? "?"} s${r.outcome_stage ?? "?"}`;

    for (const tag of (r.act_tags ?? "").split(",").map((t) => t.trim()).filter(Boolean)) {
      if (!isKnownActTag(tag, vocab)) {
        unknownTagHits.set(tag, (unknownTagHits.get(tag) ?? 0) + 1);
        if (!waived.has(tag)) failures.push(`${at}: act_tag "${tag}" is not in Part A and is not waived`);
        continue;
      }
      // A legal prefix with an illegal Prince slug passes every other check and then matches
      // no profile at all -- no fan-out, no reaction, no error. See pdv_matrix_vocab.
      const bad = badDaedricSlug(tag, daedric.slugs);
      if (bad && !waived.has(tag)) failures.push(`${at}: act_tag "${tag}" -- ${bad}`);
    }

    if (r.deity && !deities.names.has(r.deity)) {
      failures.push(`${at}: deity "${r.deity}" does not resolve through the manager name model`);
    }
    if (!/^\d+$/.test(r.outcome_stage ?? "")) {
      failures.push(`${at}: outcome_stage "${r.outcome_stage}" must be exactly one integer`);
    }
    if (r.valence && !VALENCES.has(r.valence)) failures.push(`${at}: valence "${r.valence}" must be + or -`);
    if (r.intensity && !INTENSITIES.has(r.intensity)) failures.push(`${at}: intensity "${r.intensity}" must be C, S or m`);
    if (r.magnitude && !MAGNITUDES.has(r.magnitude)) {
      const retired = r.magnitude === "echo" ? " (echo was RETIRED 2026-07-09)" : "";
      failures.push(`${at}: magnitude "${r.magnitude}" must be small or milestone${retired}`);
    }
    if (header.includes("formid") && r.formid && !FORMID.test(r.formid)) {
      failures.push(`${at}: formid "${r.formid}" must be PLUGIN.esp:HHHHHH`);
    }
  }
}

if (argv.includes("--list-unknown-tags")) {
  const sorted = [...unknownTagHits.entries()].sort((a, b) => b[1] - a[1]);
  console.log(`${sorted.length} act tag(s) outside Part A, ${sorted.filter(([t]) => !waived.has(t)).length} unwaived`);
  for (const [tag, n] of sorted) console.log(`  ${waived.has(tag) ? "waived  " : "UNWAIVED"} ${String(n).padStart(4)}  ${tag}`);
  process.exit(0);
}

const status = failures.length === 0 && issues.length === 0 ? "PASS" : "FAIL";
if (argv.includes("--json")) {
  console.log(JSON.stringify({
    check: "qrmLint", status, filesChecked, rowsChecked, skipped,
    actTagLiterals: vocab.literals.size, acceptedDeities: deities.names.size,
    waivedTags: waived.size, failures, issues,
  }, null, 2));
} else {
  console.log(`${status} files=${filesChecked} rows=${rowsChecked} tags=${vocab.literals.size}+${vocab.prefixes.size} deities=${deities.names.size} waived=${waived.size} failures=${failures.length}`);
  for (const s of skipped) console.log(`  skipped ${s}`);
  for (const i of issues) console.error(`  ISSUE ${i}`);
  for (const f of failures.slice(0, 60)) console.error(`  ${f}`);
  if (failures.length > 60) console.error(`  ... and ${failures.length - 60} more`);
}
process.exitCode = status === "PASS" ? 0 : 1;
