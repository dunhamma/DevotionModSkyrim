#!/usr/bin/env node
// JoJ Phase 1 progress checkpoint -- one row per candidate mod, one column per transition.
//
// WHY. Phase 1 is ~37 mods and several sessions. The failure this prevents is not a crash,
// it is a CONTEXT that ends: a session dies holding "I already digested B04 and judged three
// of its mods" and the next session either redoes the work or, worse, skips it believing it
// was done. Every transition is a file on disk, so a fresh context recovers the entire job
// from `--check` and needs to read nothing else -- not the plan, not the digests, not the
// CSVs.
//
// TWO RULES INHERITED FROM THE ARR25 CHECKPOINT, both learned the hard way:
//
//   --init NEVER overwrites. A resumed session that re-inits silently loses the whole run,
//   and the loss looks exactly like "we had not started yet".
//
//   Reader evidence never merges into review_verdict. The digest and the lint are EVIDENCE;
//   the verdict is the only semantic authority and only a human sets it. Letting a tool
//   write APPROVED because a gate went green is how a machine check gets laundered into a
//   design decision.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--init", "--check", "--set", "--mod", "--batch", "--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_joj_content_checkpoint" });

const argv = process.argv.slice(2);
const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const COMPAT = path.join(REPO, "references", "vanilla-gameplay", "compatibility");
const CANDIDATES = path.join(COMPAT, "PDV_JoJ_ContentCandidates.csv");
const CHECKPOINT = path.join(COMPAT, "PDV_JoJ_ContentCheckpoint.csv");

// Ordered: each is a transition, and a later one is meaningless before an earlier one.
const STAGES = [
  "stage_digested",  // ok | partial | error | -
  "rows_judged",     // ok | needs-tag | -
  "crossgen_run",    // ok | -
  "review_verdict",  // APPROVED | REVISE | SILENT | UNREVIEWED   <- human only
  "promoted",        // ok | -
  "channel_compiled",// ok | -
  "manifest_entry",  // ok | -
  "docs_page",       // ok | skipped | -
  "lint",            // PASS | FAIL | -
];
const HEADER = ["mod_key", "mod_name", "class", "batch_id", "plugin", ...STAGES, "notes"];
const HUMAN_ONLY = new Set(["review_verdict"]);
const VERDICTS = new Set(["APPROVED", "REVISE", "SILENT", "UNREVIEWED"]);

const valueOf = (flag) => {
  const inline = argv.find((a) => a.startsWith(`${flag}=`));
  if (inline) return inline.slice(flag.length + 1);
  const i = argv.indexOf(flag);
  return i !== -1 && argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[i + 1] : null;
};

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

function readCsv(file) {
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((l) => l.trim() !== "");
  const header = parseCsvLine(lines[0]).map((h) => h.trim());
  return lines.slice(1).map((l) => {
    const cells = parseCsvLine(l);
    return Object.fromEntries(header.map((h, i) => [h, (cells[i] ?? "").trim()]));
  });
}

const cell = (v) => {
  const s = String(v ?? "");
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};
const writeCsv = (rows) =>
  fs.writeFileSync(CHECKPOINT, `${[HEADER.join(","), ...rows.map((r) => HEADER.map((h) => cell(r[h])).join(","))].join("\n")}\n`, "utf8");

function doInit() {
  if (fs.existsSync(CHECKPOINT)) {
    console.error(`Refusing to overwrite ${path.relative(REPO, CHECKPOINT)}.`);
    console.error("--init never overwrites: a resumed session that re-inits loses the run, and the");
    console.error("loss is indistinguishable from never having started. Delete it deliberately if");
    console.error("you really mean to restart.");
    process.exit(2);
  }
  const rows = readCsv(CANDIDATES).map((c) => ({
    mod_key: c.mod_key, mod_name: c.mod_name, class: c.class, batch_id: c.batch_id, plugin: c.plugin,
    ...Object.fromEntries(STAGES.map((s) => [s, s === "review_verdict" ? "UNREVIEWED" : "-"])),
    notes: "",
  }));
  writeCsv(rows);
  console.log(`init ${path.relative(REPO, CHECKPOINT)} mods=${rows.length}`);
}

function doSet() {
  const modKey = valueOf("--mod");
  const assignment = valueOf("--set");
  if (!modKey || !assignment || !assignment.includes("=")) {
    console.error("usage: --mod <key> --set <column>=<value>");
    process.exit(2);
  }
  const [col, val] = [assignment.slice(0, assignment.indexOf("=")), assignment.slice(assignment.indexOf("=") + 1)];
  if (!STAGES.includes(col) && col !== "notes") {
    console.error(`Unknown column "${col}". Settable: ${[...STAGES, "notes"].join(", ")}`);
    process.exit(2);
  }
  if (col === "review_verdict" && !VERDICTS.has(val)) {
    console.error(`review_verdict must be one of ${[...VERDICTS].join(", ")}`);
    process.exit(2);
  }
  const rows = readCsv(CHECKPOINT);
  const row = rows.find((r) => r.mod_key === modKey);
  if (!row) { console.error(`No checkpoint row for mod_key "${modKey}"`); process.exit(2); }
  row[col] = val;
  writeCsv(rows);
  console.log(`${modKey} ${col}=${val}`);
}

function doCheck() {
  if (!fs.existsSync(CHECKPOINT)) {
    console.error(`No checkpoint at ${path.relative(REPO, CHECKPOINT)}. Run --init.`);
    process.exit(2);
  }
  const batch = valueOf("--batch");
  let rows = readCsv(CHECKPOINT);
  if (batch) rows = rows.filter((r) => r.batch_id === batch);

  const byBatch = new Map();
  for (const r of rows) {
    if (!byBatch.has(r.batch_id)) byBatch.set(r.batch_id, []);
    byBatch.get(r.batch_id).push(r);
  }

  // The first mod that is not finished and not deliberately silent, in batch then file order.
  // A resumed session needs ONE answer -- where do I pick up -- not a table to interpret.
  const done = (r) => r.review_verdict === "SILENT" || (r.lint === "PASS" && r.manifest_entry === "ok");
  const blocked = rows.filter((r) => !done(r));
  const next = blocked[0] ?? null;
  const nextReason = next
    ? STAGES.find((s) => next[s] === "-" || next[s] === "UNREVIEWED" || next[s] === "FAIL") ?? "unknown"
    : null;

  const summary = {
    check: "jojContentCheckpoint",
    mods: rows.length,
    complete: rows.length - blocked.length,
    remaining: blocked.length,
    byBatch: Object.fromEntries([...byBatch].map(([b, list]) => [b, `${list.filter(done).length}/${list.length}`])),
    verdicts: rows.reduce((a, r) => ((a[r.review_verdict] = (a[r.review_verdict] ?? 0) + 1), a), {}),
    lintFailures: rows.filter((r) => r.lint === "FAIL").map((r) => r.mod_key),
    next: next ? { mod: next.mod_key, batch: next.batch_id, blockedAt: nextReason } : null,
  };

  if (argv.includes("--json")) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    console.log(`mods=${summary.mods} complete=${summary.complete} remaining=${summary.remaining}`);
    console.log(`batches: ${Object.entries(summary.byBatch).map(([b, v]) => `${b} ${v}`).join("  ")}`);
    console.log(`verdicts: ${JSON.stringify(summary.verdicts)}`);
    if (summary.lintFailures.length) console.log(`lint FAIL: ${summary.lintFailures.join(", ")}`);
    console.log(summary.next ? `next: ${summary.next.mod} (${summary.next.batch}) blocked at ${summary.next.blockedAt}` : "next: nothing -- all mods complete or SILENT");
  }
  // Exit 0 always. This REPORTS progress; it is not a gate, and making incomplete work look
  // like a failing check would train everyone to ignore its exit code.
}

const modes = ["--init", "--check", "--set"].filter((m) => argv.includes(m) || argv.some((a) => a.startsWith(`${m}=`)));
if (modes.length !== 1) {
  console.error("usage: --init | --check [--batch B0N] [--json] | --mod <key> --set <column>=<value>");
  process.exit(2);
}
if (argv.includes("--init")) doInit();
else if (argv.includes("--check")) doCheck();
else doSet();
