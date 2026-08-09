#!/usr/bin/env node
// JoJ Phase 1b -- bulk quest-stage extraction, and the gate nobody had.
//
// WHY THIS EXISTS, TWO REASONS.
//
// 1. TOKEN COST. Phase 1 is ~39 mods and 300-900 stage citations. Reading that through the
//    MCP tool in a conversation dumps every journal entry into context and costs roughly
//    220k tokens before a single row is authored. This reads the same data over ONE
//    long-lived houseCARL session, writes a compact digest to disk, and prints one line. Raw
//    journal text never crosses the conversation boundary in either direction.
//
// 2. A MISSING GATE. `PDV_JoJ_CompatibilityPackage_2026-08-08.md` section 5.1 calls
//    pdv_matrix_runtime_preflight "the load-bearing one -- does stage 80 of that quest
//    actually exist, and does its text say what the row's citation claims". It does not do
//    that. Nothing in this repo checks that an authored `outcome_stage` exists. A row citing
//    a stage that was never in the plugin compiles clean, packages clean, and awards nothing
//    forever. `--verify-rows` is that check, and it is nearly free once the digest exists.
//
// INSTANCE SAFETY. Every read is by ABSOLUTE PATH through read_plugin_file, which opens the
// file off disk and consults no MO2 instance. houseCARL's instance pointer is global to this
// machine and persisted, so moving it would silently change another workspace's next
// session. It is never moved here. A session recorded on 2026-08-08 believed reading JoJ
// required repointing; that was reproduced and disproved on 2026-08-09.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { probePlugins, digestQuests } from "./lib/pdv_qust_probe.mjs";

const KNOWN_FLAGS = new Set([
  "--build-worklist",
  "--batch",
  "--mod",
  "--retry-errors",
  "--verify-rows",
  "--no-cache",
  "--json",
]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_joj_stage_digest" });

const argv = process.argv.slice(2);
const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CANDIDATES = path.join(REPO, "references", "vanilla-gameplay", "compatibility", "PDV_JoJ_ContentCandidates.csv");
const WORKLIST = path.join(REPO, "references", "vanilla-gameplay", "compatibility", "PDV_JoJ_StageWorklist.csv");
const DIGEST_DIR = path.join(REPO, "generated", "joj-stage-digests");
const CACHE = path.join(REPO, "generated", "PDV_JoJ_StageDigest.cache.json");

const valueOf = (flag) => {
  const i = argv.indexOf(flag);
  if (i === -1) return null;
  const inline = argv.find((a) => a.startsWith(`${flag}=`));
  if (inline) return inline.slice(flag.length + 1);
  return argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[i + 1] : null;
};

// Minimal quoted-field CSV, matching the parser the other matrix tools use.
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

const csvCell = (v) => {
  const s = String(v ?? "");
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};

// LF on purpose. This file is compared and diffed; CRLF from a checkout would make a gate
// that hashes or compares it lie, which this repo has been bitten by three times.
const writeCsv = (file, header, rows) => {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const body = [header.join(","), ...rows.map((r) => header.map((h) => csvCell(r[h])).join(","))];
  fs.writeFileSync(file, `${body.join("\n")}\n`, "utf8");
};

// ---------------------------------------------------------------------------------------
// --build-worklist: candidates (one row per MOD) -> worklist (one row per QUST it DEFINES).
//
// Generated, never hand-written: a hand-typed FormID is a silent wrong answer, and
// probePlugins already returns the defining-vs-override split that a hand list gets wrong.
async function buildWorklist() {
  if (!fs.existsSync(CANDIDATES)) {
    console.error(`No candidates file at ${CANDIDATES}`);
    process.exit(2);
  }
  const candidates = readCsv(CANDIDATES);
  const resolved = [];
  const missing = [];
  for (const c of candidates) {
    const abs = path.join(c.instance_root, "mods", c.mod_folder, c.plugin);
    if (fs.existsSync(abs)) resolved.push({ ...c, abs });
    else missing.push(`${c.mod_key}: ${abs}`);
  }

  const { results, degraded, reason } = await probePlugins(resolved.map((r) => r.abs), { cacheFile: CACHE });
  if (degraded) {
    console.error(`houseCARL unusable: ${reason}`);
    process.exit(1);
  }

  const rows = [];
  const noQuests = [];
  for (const r of resolved) {
    const res = results.get(r.abs);
    if (!res || res.error || !res.definedRecords?.length) {
      noQuests.push(`${r.mod_key}: ${res?.error ?? "defines no QUST"}`);
      continue;
    }
    // definedRecords carries the FormID and EditorID paired as the enumeration printed them.
    // DEFINED records only -- an override this plugin merely carries belongs to whoever
    // defines it, and rowing it here would double-claim a cell another channel owns.
    res.definedRecords.forEach((rec, i) => {
      rows.push({
        work_id: `JOJ-${r.class}-${r.mod_key}-${String(i + 1).padStart(3, "0")}`,
        batch_id: r.batch_id,
        class: r.class,
        mod_key: r.mod_key,
        mod_name: r.mod_name,
        plugin: r.plugin,
        plugin_path: r.abs,
        formid: rec.formid,
        editor_id: rec.editorId,
      });
    });
  }

  writeCsv(WORKLIST, ["work_id", "batch_id", "class", "mod_key", "mod_name", "plugin", "plugin_path", "formid", "editor_id"], rows);
  console.log(`worklist=${path.relative(REPO, WORKLIST)} mods=${resolved.length} quests=${rows.length} missingPlugins=${missing.length} noQuests=${noQuests.length}`);
  for (const m of missing) console.error(`  MISSING ${m}`);
  for (const m of noQuests) console.error(`  NO-QUST ${m}`);
  process.exitCode = missing.length ? 1 : 0;
}

// ---------------------------------------------------------------------------------------
// --batch / --mod: digest a bounded slice of the worklist to disk.
async function runDigest() {
  if (!fs.existsSync(WORKLIST)) {
    console.error(`No worklist at ${WORKLIST}. Run --build-worklist first.`);
    process.exit(2);
  }
  const batch = valueOf("--batch");
  const modKey = valueOf("--mod");
  const retry = argv.includes("--retry-errors");
  let work = readCsv(WORKLIST);
  if (batch) work = work.filter((w) => w.batch_id === batch);
  if (modKey) work = work.filter((w) => w.mod_key === modKey);
  if (!work.length) {
    console.error(`No worklist rows match batch=${batch ?? "*"} mod=${modKey ?? "*"}`);
    process.exit(2);
  }

  const items = work.map((w) => ({
    workId: w.work_id,
    batchId: w.batch_id,
    modKey: w.mod_key,
    plugin: w.plugin,
    pluginPath: w.plugin_path,
    formid: w.formid,
    editorId: w.editor_id,
  }));

  const { digests, read, cached, failed, failures, degraded, reason } = await digestQuests(items, {
    cacheFile: CACHE,
    noCache: argv.includes("--no-cache") || retry,
  });
  if (degraded) {
    console.error(`houseCARL unusable: ${reason}`);
    process.exit(1);
  }

  const byMod = new Map();
  for (const d of digests.values()) {
    if (!byMod.has(d.modKey)) byMod.set(d.modKey, []);
    byMod.get(d.modKey).push(d);
  }

  fs.mkdirSync(DIGEST_DIR, { recursive: true });
  let content = 0;
  let framework = 0;
  let stages = 0;
  let logged = 0;
  for (const [mod, list] of byMod) {
    list.sort((a, b) => String(a.editorId).localeCompare(String(b.editorId)));
    fs.writeFileSync(path.join(DIGEST_DIR, `${mod}.digest.jsonl`), `${list.map((d) => JSON.stringify(d)).join("\n")}\n`, "utf8");
    fs.writeFileSync(path.join(DIGEST_DIR, `${mod}.digest.md`), renderDigestMd(mod, list), "utf8");
    for (const d of list) {
      if (d.structuralClass === "content") content += 1;
      else framework += 1;
      stages += d.stageCount ?? 0;
      logged += d.loggedStageCount ?? 0;
    }
  }

  if (failures.length) {
    writeCsv(path.join(DIGEST_DIR, `${batch ?? modKey ?? "all"}.errors.csv`), ["workId", "modKey", "editorId", "formid", "error"], failures);
  }

  console.log(`batch=${batch ?? modKey ?? "all"} quests=${digests.size} read=${read} cached=${cached} failed=${failed} content=${content} framework=${framework} stages=${stages} logged=${logged}`);
  process.exitCode = failed ? 1 : 0;
}

// The view a judging subagent reads. Framework quests collapse to one line: naming them is
// enough to prove they were seen and skipped, and expanding them is most of the payload.
function renderDigestMd(modKey, list) {
  const out = [`# ${modKey}`, ""];
  const framework = [];
  for (const d of list) {
    if (d.readStatus === "error") {
      out.push(`## ${d.editorId}  ERROR: ${d.error}`, "");
      continue;
    }
    if (d.structuralClass !== "content") {
      framework.push(`${d.editorId}(${d.structuralClass})`);
      continue;
    }
    const term = d.terminalStages.join(",") + (d.terminalInferred ? " inferred" : " flagged");
    out.push(`## ${d.editorId} ${d.name ? `"${d.name}"` : ""}  ${d.plugin}:${String(d.formid).split(":")[0]}`);
    out.push(`   ${d.stageCount} stages, ${d.loggedStageCount} with evidence, terminal ${term}${d.truncated ? "  **TRUNCATED**" : ""}`);
    for (const s of d.stages) {
      const marks = [s.isStartUp ? "START" : null, s.isComplete ? "COMPLETE" : null, s.hasFragment ? "frag" : null].filter(Boolean);
      out.push(`- s${s.index} ${s.evidenceTier}${marks.length ? ` [${marks.join(" ")}]` : ""}`);
      if (s.objective) out.push(`    obj: ${s.objective}`);
      for (const l of s.log) out.push(`    "${l}"`);
    }
    if (d.unmatchedObjectives.length) {
      out.push(`- objectives with no matching stage: ${d.unmatchedObjectives.map((o) => o.atIndex).join(", ")}`);
    }
    out.push("");
  }
  if (framework.length) {
    out.push(`## Framework / empty quests (no journal text, no objectives) -- ${framework.length}`, framework.join(", "), "");
  }
  return out.join("\n");
}

// ---------------------------------------------------------------------------------------
// --verify-rows: the gate section 5.1 claimed existed.
//
// For every authored row: does its quest appear in the digest, does its outcome_stage exist
// as a real stage index, does its formid agree, and -- where the stage carries no journal
// text -- does the citation admit that with RUNTIME-VERIFY. That last one is the difference
// between a cited claim and a guess, and it is decided from the record rather than trusted.
function verifyRows() {
  const csv = valueOf("--verify-rows");
  if (!csv || !fs.existsSync(csv)) {
    console.error(`--verify-rows needs a readable CSV (got ${csv ?? "nothing"})`);
    process.exit(2);
  }
  const rows = readCsv(csv);

  const digestByEditorId = new Map();
  if (fs.existsSync(DIGEST_DIR)) {
    for (const f of fs.readdirSync(DIGEST_DIR).filter((n) => n.endsWith(".digest.jsonl"))) {
      for (const line of fs.readFileSync(path.join(DIGEST_DIR, f), "utf8").split("\n")) {
        if (!line.trim()) continue;
        const d = JSON.parse(line);
        if (d.editorId) digestByEditorId.set(d.editorId, d);
      }
    }
  }
  if (digestByEditorId.size === 0) {
    console.error("No digests on disk. Run --batch first; a row cannot be verified against nothing.");
    process.exit(2);
  }

  const failures = [];
  let checked = 0;
  for (const r of rows) {
    const d = digestByEditorId.get(r.editor_id);
    if (!d) continue; // not a JoJ-digested quest; another gate owns it
    checked += 1;
    const stage = Number(r.outcome_stage);
    const hit = d.stages.find((s) => s.index === stage);
    if (!hit) {
      failures.push(`${r.editor_id} s${r.outcome_stage}: no such stage (has ${d.stages.map((s) => s.index).join(",")})`);
      continue;
    }
    if (r.formid && d.formid && r.formid.toLowerCase() !== d.formid.toLowerCase()) {
      failures.push(`${r.editor_id} s${stage}: formid ${r.formid} != digest ${d.formid}`);
    }
    if (hit.evidenceTier !== "A" && !/RUNTIME-VERIFY/i.test(r.citation ?? "")) {
      failures.push(`${r.editor_id} s${stage}: tier ${hit.evidenceTier} (no journal text) but citation lacks RUNTIME-VERIFY`);
    }
  }

  const status = failures.length ? "FAIL" : "PASS";
  if (argv.includes("--json")) {
    console.log(JSON.stringify({ check: "jojStageRows", status, csv: path.relative(REPO, csv), rows: rows.length, checked, failures }, null, 2));
  } else {
    console.log(`${status} csv=${path.basename(csv)} rows=${rows.length} checked=${checked} failures=${failures.length}`);
    for (const f of failures) console.error(`  ${f}`);
  }
  process.exitCode = failures.length ? 1 : 0;
}

if (argv.includes("--build-worklist")) await buildWorklist();
else if (argv.includes("--verify-rows")) verifyRows();
else if (argv.includes("--batch") || argv.includes("--mod")) await runDigest();
else {
  console.error("usage: --build-worklist | --batch <id> | --mod <key> | --verify-rows <csv>");
  process.exit(2);
}
