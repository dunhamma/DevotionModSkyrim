import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./pdv_cli.mjs";
import { actTagVocabulary, isKnownActTag, daedricSlugs, badDaedricSlug } from "./pdv_matrix_vocab.mjs";

export const TAGGED_ROW_SCHEMA = [
  "editor_id",
  "quest_name",
  "outcome_stage",
  "outcome",
  "act_tags",
  "citation",
  "formid",
  "evidence_tier",
  "branch_note",
];

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

function collectFiles(repo, argv, defaultRowsDir) {
  const dirIndex = argv.indexOf("--dir");
  const requestedDir = dirIndex >= 0 ? argv[dirIndex + 1] : null;
  const positional = argv.filter((arg, index) => {
    if (arg.startsWith("--")) return false;
    if (dirIndex >= 0 && index === dirIndex + 1) return false;
    return true;
  });
  if (positional.length) return positional.map((file) => path.resolve(file));
  const rowsDir = requestedDir ? path.resolve(requestedDir) : defaultRowsDir;
  if (!rowsDir || !fs.existsSync(rowsDir)) return [];
  return fs.readdirSync(rowsDir)
    .filter((file) => file.endsWith(".tagged.csv"))
    .sort((left, right) => left.localeCompare(right))
    .map((file) => path.join(rowsDir, file));
}

export function runTaggedRowsCheck({
  argv = process.argv.slice(2),
  repo,
  defaultRowsDir = null,
  checkName = "taggedRows",
  toolName = "pdv_tagged_rows_check",
  allowDir = true,
} = {}) {
  const knownFlags = new Set(["--json", ...(allowDir ? ["--dir"] : [])]);
  assertKnownFlags(argv.filter((arg) => arg.startsWith("--")), knownFlags, { toolName });
  const files = collectFiles(repo, argv, defaultRowsDir);
  if (!files.length) {
    console.error("No tagged CSVs found. Pass one or more files or --dir <folder>.");
    process.exitCode = 2;
    return { check: checkName, status: "ERROR", files: 0, rows: 0, failures: ["no input files"] };
  }

  const vocab = actTagVocabulary(repo);
  const daedric = daedricSlugs(repo);
  const failures = [...vocab.issues, ...daedric.issues];
  let rows = 0;

  for (const file of files) {
    const label = path.basename(file);
    const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((line) => line.trim() !== "");
    if (!lines.length) {
      failures.push(`${label}: file is empty`);
      continue;
    }
    const header = parseCsvLine(lines[0]).map((column) => column.trim().toLowerCase());
    for (const column of TAGGED_ROW_SCHEMA) if (!header.includes(column)) failures.push(`${label}: missing column "${column}"`);
    for (const column of header) if (!TAGGED_ROW_SCHEMA.includes(column)) failures.push(`${label}: unexpected column "${column}"`);
    if (header.length !== TAGGED_ROW_SCHEMA.length || new Set(header).size !== header.length) {
      failures.push(`${label}: header must contain exactly the nine tagged-row columns once each`);
    }
    if (header.includes("deity")) failures.push(`${label}: has a deity column -- the fan-out is cross-gen's job, not the judge's`);
    const indexOf = (name) => header.indexOf(name);

    for (const line of lines.slice(1)) {
      rows += 1;
      const cells = parseCsvLine(line);
      const at = `${label} ${cells[indexOf("editor_id")] || "?"} s${cells[indexOf("outcome_stage")] || "?"}`;
      if (cells.length !== header.length) failures.push(`${at}: row has ${cells.length} cells; header has ${header.length}`);
      const tier = cells[indexOf("evidence_tier")];
      const tags = (cells[indexOf("act_tags")] || "").split(",").map((tag) => tag.trim()).filter(Boolean);
      const note = cells[indexOf("branch_note")] || "";
      if (!tags.length && !/NEEDS-TAG/.test(note)) failures.push(`${at}: empty act_tags with no NEEDS-TAG note`);
      for (const tag of tags) {
        if (!isKnownActTag(tag, vocab)) { failures.push(`${at}: act_tag "${tag}" is not in Part A`); continue; }
        const bad = badDaedricSlug(tag, daedric.slugs);
        if (bad) failures.push(`${at}: act_tag "${tag}" -- ${bad}`);
      }
      if (!/^\d+$/.test(cells[indexOf("outcome_stage")] || "")) failures.push(`${at}: outcome_stage must be exactly one integer`);
      if (!FORMID.test(cells[indexOf("formid")] || "")) failures.push(`${at}: formid "${cells[indexOf("formid")]}" must be PLUGIN.esp:HHHHHH`);
      if (!["A", "B", "C"].includes(tier)) failures.push(`${at}: evidence_tier "${tier}" must be A, B or C`);
      if (tier !== "A" && !/RUNTIME-VERIFY/.test(cells[indexOf("citation")] || "")) {
        failures.push(`${at}: tier ${tier} has no journal text, so its citation must carry RUNTIME-VERIFY`);
      }
    }
  }

  const result = { check: checkName, status: failures.length ? "FAIL" : "PASS", files: files.length, rows, failures };
  if (argv.includes("--json")) console.log(JSON.stringify(result, null, 2));
  else {
    console.log(`${result.status} files=${files.length} rows=${rows} failures=${failures.length}`);
    for (const failure of failures) console.error(`  ${failure}`);
  }
  process.exitCode = failures.length ? 1 : 0;
  return result;
}
