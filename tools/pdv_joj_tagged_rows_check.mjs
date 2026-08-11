#!/usr/bin/env node
// Gate the JUDGE's output, before cross-gen ever sees it.
//
// WHY A SEPARATE TOOL. pdv_qrm_lint checks the 11-column CHANNEL CSVs -- the promoted,
// deity-bearing rows. The judging pass produces something different first: a deityless
// 9-column tagged CSV, and nothing looked at it. That intermediate is where the defects
// actually are, because it is the only file in the chain a human or a subagent types by hand.
//
// It earned its place on the first batch it ran against, catching two classes at once:
//
//   - Two rows in a HAND-authored file had unquoted commas in `outcome` and `quest_name`, so
//     every column after them shifted. The visible symptom was an act tag reading "out of
//     pride" and a formid holding a whole citation -- garbage that cross-gen would have
//     silently crossed against 45 deity profiles.
//   - Every row from a SUBAGENT carried a reversed FormID (HEX:PLUGIN instead of PLUGIN:HEX),
//     because the digest printed houseCARL's form and the prompt said to copy it verbatim. A
//     reversed token resolves to nothing; compile would have thrown on it eventually, far
//     from the cause.
//
// The lesson worth keeping: the hand-written file was the broken one and the machine-written
// files were clean. Do not gate only what an agent produces.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { actTagVocabulary, isKnownActTag, daedricSlugs, badDaedricSlug } from "./lib/pdv_matrix_vocab.mjs";

const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2).filter((a) => a.startsWith("--")), KNOWN_FLAGS, {
  toolName: "pdv_joj_tagged_rows_check",
});

const argv = process.argv.slice(2);
const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ROWS_DIR = path.join(REPO, "generated", "joj-rows");
const SCHEMA = ["editor_id", "quest_name", "outcome_stage", "outcome", "act_tags", "citation", "formid", "evidence_tier", "branch_note"];
const FORMID = /^[^:]+\.(esp|esm|esl):[0-9A-Fa-f]{6}$/i;

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

const targets = argv.filter((a) => !a.startsWith("--"));
const files = targets.length
  ? targets
  : (fs.existsSync(ROWS_DIR) ? fs.readdirSync(ROWS_DIR).filter((f) => f.endsWith(".tagged.csv")).map((f) => path.join(ROWS_DIR, f)) : []);

if (!files.length) {
  console.error(`No tagged CSVs found. Looked in ${path.relative(REPO, ROWS_DIR)}.`);
  process.exit(2);
}

const vocab = actTagVocabulary(REPO);
const daedric = daedricSlugs(REPO);
const failures = [...vocab.issues, ...daedric.issues];
let rows = 0;

for (const file of files) {
  const label = path.basename(file);
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((l) => l.trim() !== "");
  const header = parseCsvLine(lines[0]).map((h) => h.trim().toLowerCase());
  for (const col of SCHEMA) if (!header.includes(col)) failures.push(`${label}: missing column "${col}"`);
  const g = (n) => header.indexOf(n);
  // A deity column here means the judge tried to pick the gods. That is cross-gen's job, and
  // the column is withheld precisely so the fan-out cannot be hand-authored.
  if (header.includes("deity")) failures.push(`${label}: has a deity column -- the fan-out is cross-gen's job, not the judge's`);

  for (const line of lines.slice(1)) {
    rows += 1;
    const c = parseCsvLine(line);
    const at = `${label} ${c[g("editor_id")] || "?"} s${c[g("outcome_stage")] || "?"}`;
    const tier = c[g("evidence_tier")];
    const tags = (c[g("act_tags")] || "").split(",").map((t) => t.trim()).filter(Boolean);
    const note = c[g("branch_note")] || "";

    // An empty tag is LEGAL, but only as the declared escape hatch. Silence with no note is
    // a dropped row; silence with NEEDS-TAG is a question for a human.
    if (!tags.length && !/NEEDS-TAG/.test(note)) failures.push(`${at}: empty act_tags with no NEEDS-TAG note`);
    for (const t of tags) {
      if (!isKnownActTag(t, vocab)) { failures.push(`${at}: act_tag "${t}" is not in Part A`); continue; }
      // The prefix being legal is not enough. `serve_a_daedra:<prince>` accepts any suffix as
      // far as Part A is concerned, and a wrong one is the worst failure available: it matches
      // no profile, so it fans out to nobody, silently. Caught in the wild twice on the same
      // file -- `clavicus_vile` for the slug `clavicus`, and `umbra`, which is not a Prince.
      const bad = badDaedricSlug(t, daedric.slugs);
      if (bad) failures.push(`${at}: act_tag "${t}" -- ${bad}`);
    }
    if (!/^\d+$/.test(c[g("outcome_stage")] || "")) failures.push(`${at}: outcome_stage must be exactly one integer`);
    if (!FORMID.test(c[g("formid")] || "")) failures.push(`${at}: formid "${c[g("formid")]}" must be PLUGIN.esp:HHHHHH`);
    if (!["A", "B", "C"].includes(tier)) failures.push(`${at}: evidence_tier "${tier}" must be A, B or C`);
    if (tier !== "A" && !/RUNTIME-VERIFY/.test(c[g("citation")] || "")) {
      failures.push(`${at}: tier ${tier} has no journal text, so its citation must carry RUNTIME-VERIFY`);
    }
  }
}

const status = failures.length ? "FAIL" : "PASS";
if (argv.includes("--json")) {
  console.log(JSON.stringify({ check: "jojTaggedRows", status, files: files.length, rows, failures }, null, 2));
} else {
  console.log(`${status} files=${files.length} rows=${rows} failures=${failures.length}`);
  for (const f of failures) console.error(`  ${f}`);
}
process.exitCode = failures.length ? 1 : 0;
