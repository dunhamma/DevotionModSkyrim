#!/usr/bin/env node
/*
 * PDV Spine Stack Score — mechanism-agnostic parity metric for each race's
 * ALWAYS-ACTIVE ancestral spine (patron-tier rewards excluded). Per the
 * cross-cutting-audit-doctrine: registry-driven, score-per-unit,
 * generated-ledger-as-truth, DETERMINISTIC checks where possible.
 *
 * Six weighted dims (0-3 each): boon_floor x3, piety_sink x2, minus_stack x2,
 * renewable x1, diegetic x1, text_voice x1 (raw max 30). Normalized so the
 * reference race (Argonian) = 100%; <70% = a parity build target.
 *
 * The judgment dims are CURATED in PDV_SpineStackRegistry.csv (seeded from the
 * 2026-06-24 ancestral-spine audit, refine per-race). The tool also runs a
 * DETERMINISTIC drift-check: PDV_Notif_<Race>_* diegetic declarations that have
 * no dispatch site (the Nord AncestorsQuiet / Orc Watchers dead-decl class) are
 * detected from the live source and flagged against the curated diegetic score.
 *
 * Read-only except its own generated ledger files.
 */
import fs from "node:fs";

const ROOT = process.cwd().replace(/\\/g, "/");
const REGISTRY = `${ROOT}/references/authoring/PDV_SpineStackRegistry.csv`;
const SOURCE_DIR = `${ROOT}/live-source/Scripts/Source`;
const OUT_MD = `${ROOT}/references/authoring/PDV_SpineStackScoreLedger.md`;
const OUT_CSV = `${ROOT}/references/authoring/PDV_SpineStackScoreLedger.csv`;

const DIMS = [
  { key: "boon_floor", label: "Unconditional boon floor", weight: 3 },
  { key: "piety_sink", label: "Piety-sink reachability", weight: 2 },
  { key: "minus_stack", label: "Minus stack", weight: 2 },
  { key: "renewable", label: "Renewable maintenance", weight: 1 },
  { key: "diegetic", label: "Diegetic surfaces wired", weight: 1 },
  { key: "text_voice", label: "Text/voice depth", weight: 1 },
];
const MAX_DIM = 3;
const PARITY_TARGET_PCT = 70;
const REFERENCE_RACE = "Argonian";
const SELFTEST_RACE = "SELFTEST_ZERO";

function main() {
  assertFile(REGISTRY);
  const rows = parseRegistry(fs.readFileSync(REGISTRY, "utf8"));
  const diegetic = analyzeDiegetic();

  if (process.env.PDV_SPINE_SELFTEST === "1") {
    rows.push({ race: SELFTEST_RACE, scores: Object.fromEntries(DIMS.map((d) => [d.key, 0])), basis: "selftest injected all-zero race" });
  }

  const reference = rows.find((r) => r.race === REFERENCE_RACE);
  if (!reference) throw new Error(`Reference race ${REFERENCE_RACE} not in registry.`);
  const refRaw = rawScore(reference.scores);
  if (refRaw <= 0) throw new Error(`Reference race ${REFERENCE_RACE} has a non-positive raw score; cannot normalize.`);

  const scored = rows
    .map((r) => {
      const raw = rawScore(r.scores);
      const pct = Math.round((raw / refRaw) * 1000) / 10;
      const real = r.race !== SELFTEST_RACE;
      return { ...r, raw, pct, target: real && pct < PARITY_TARGET_PCT, drift: diegeticDrift(r, diegetic) };
    })
    .sort((a, b) => a.pct - b.pct);

  writeLedgers(scored, diegetic, refRaw);

  const real = scored.filter((s) => s.race !== SELFTEST_RACE);
  const targets = real.filter((s) => s.target);
  const summary = {
    status: "PASS",
    races: real.length,
    reference: REFERENCE_RACE,
    referenceRawMax: refRaw,
    worstFirst: real.slice(0, 3).map((s) => `${s.race} ${s.pct}%`),
    parityTargets: targets.map((t) => `${t.race} ${t.pct}%`),
    diegeticDeadDeclarations: diegetic.dead.map((d) => d.id),
    driftRaces: scored.filter((s) => s.drift && s.drift.flag).map((s) => s.race),
    selftest: process.env.PDV_SPINE_SELFTEST === "1"
      ? (scored.find((s) => s.race === SELFTEST_RACE)?.pct === 0 ? "PASS (zero-race scored 0%)" : "FAIL")
      : "off",
    ledger: "references/authoring/PDV_SpineStackScoreLedger.md",
  };
  console.log(JSON.stringify(summary, null, 2));
}

function rawScore(scores) {
  return DIMS.reduce((sum, d) => sum + clampDim(scores[d.key]) * d.weight, 0);
}

function clampDim(value) {
  const n = Number(value);
  if (!Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(MAX_DIM, n));
}

function parseRegistry(text) {
  const lines = text.replace(/^﻿/, "").split(/\r?\n/).filter((l) => l.trim().length);
  const header = splitCsvLine(lines[0]);
  const out = [];
  for (const line of lines.slice(1)) {
    const cells = splitCsvLine(line);
    const rec = Object.fromEntries(header.map((h, i) => [h, cells[i] ?? ""]));
    out.push({
      race: rec.race,
      scores: Object.fromEntries(DIMS.map((d) => [d.key, rec[d.key]])),
      richness: rec.richness ?? "",
      basis: rec.score_basis ?? "",
    });
  }
  return out;
}

function splitCsvLine(line) {
  const cells = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"' && line[i + 1] === '"') { cur += '"'; i++; }
      else if (ch === '"') inQuotes = false;
      else cur += ch;
    } else if (ch === '"') inQuotes = true;
    else if (ch === ",") { cells.push(cur); cur = ""; }
    else cur += ch;
  }
  cells.push(cur);
  return cells.map((c) => c.trim());
}

// DETERMINISTIC: scan the live source for PDV_Notif_<Race>_* identifiers; one that
// appears only once (its declaration, no dispatch reference) is a dead declaration.
function analyzeDiegetic() {
  const byId = new Map(); // id -> count
  const idRace = new Map(); // id -> race token
  if (fs.existsSync(SOURCE_DIR)) {
    for (const file of fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f))) {
      const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
      for (const m of text.matchAll(/PDV_Notif_([A-Za-z]+)_[A-Za-z0-9_]+/g)) {
        const id = m[0];
        byId.set(id, (byId.get(id) ?? 0) + 1);
        idRace.set(id, m[1]);
      }
    }
  }
  const dead = [];
  const wiredByRace = new Map();
  const deadByRace = new Map();
  for (const [id, count] of byId) {
    const race = idRace.get(id);
    if (count <= 1) {
      dead.push({ id, race, count });
      deadByRace.set(race, (deadByRace.get(race) ?? 0) + 1);
    } else {
      wiredByRace.set(race, (wiredByRace.get(race) ?? 0) + 1);
    }
  }
  return { byId, dead, wiredByRace, deadByRace, available: fs.existsSync(SOURCE_DIR) };
}

function diegeticDrift(row, diegetic) {
  if (!diegetic.available || row.race === SELFTEST_RACE) return null;
  const dead = diegetic.deadByRace.get(row.race) ?? 0;
  const wired = diegetic.wiredByRace.get(row.race) ?? 0;
  const curated = clampDim(row.scores.diegetic);
  // Flag if the curated diegetic score implies wired surfaces but the live source
  // shows dead declarations and no wired ones (declared-but-never-dispatched).
  const flag = curated >= 2 && wired === 0 && dead > 0;
  return { dead, wired, curated, flag };
}

function writeLedgers(scored, diegetic, refRaw) {
  const md = [];
  md.push("# PDV Spine Stack Score Ledger");
  md.push("");
  md.push("GENERATED by tools/pdv_spine_stack_score.mjs - do not hand-edit.");
  md.push("");
  md.push(`Mechanism-agnostic parity score for each race's always-active ancestral spine (patron-tier excluded). Reference ${REFERENCE_RACE} = 100% (raw ${refRaw}/30). <${PARITY_TARGET_PCT}% = parity build target. Judgment dims are curated in PDV_SpineStackRegistry.csv; the diegetic column is drift-checked against live-source dead declarations.`);
  md.push("");
  md.push("## Scores (worst-first)");
  md.push("");
  md.push("| Race | % | Raw | Target? | Boon x3 | Sink x2 | Minus x2 | Renew x1 | Dieg x1 | Text x1 | Richness |");
  md.push("|---|---|---|---|---|---|---|---|---|---|---|");
  for (const s of scored) {
    if (s.race === SELFTEST_RACE) continue;
    md.push([
      s.race, `${s.pct}%`, s.raw, s.target ? "**YES**" : "-",
      fmt(s.scores.boon_floor), fmt(s.scores.piety_sink), fmt(s.scores.minus_stack),
      fmt(s.scores.renewable), fmt(s.scores.diegetic), fmt(s.scores.text_voice), s.richness,
    ].map((c) => `| ${asciiSafe(c)} `).join("") + "|");
  }
  md.push("");
  md.push("## Parity build targets (<" + PARITY_TARGET_PCT + "%, worst-first)");
  md.push("");
  const targets = scored.filter((s) => s.target);
  if (!targets.length) md.push("- none");
  for (const t of targets) md.push(`- **${t.race}** ${t.pct}% - ${asciiSafe(t.basis)}`);
  md.push("");
  md.push("## Diegetic dead-declaration drift-check (deterministic, live source)");
  md.push("");
  if (!diegetic.available) {
    md.push("- live source dir not found; diegetic check SKIPPED.");
  } else if (!diegetic.dead.length) {
    md.push("- no PDV_Notif_* declared-but-never-dispatched identifiers found.");
  } else {
    md.push("Declared once with no dispatch site (dispatch-or-delete per the spine build):");
    for (const d of diegetic.dead) md.push(`- ${asciiSafe(d.id)} (${d.race})`);
  }
  const driftRows = scored.filter((s) => s.drift && s.drift.flag);
  if (driftRows.length) {
    md.push("");
    md.push("Curated-vs-derived drift (curated diegetic >=2 but live source shows only dead decls):");
    for (const s of driftRows) md.push(`- ${asciiSafe(s.race)}: curated ${s.drift.curated}, wired ${s.drift.wired}, dead ${s.drift.dead}`);
  }
  md.push("");
  fs.writeFileSync(OUT_MD, md.join("\n") + "\n", "utf8");

  const cols = ["race", "pct", "raw", "target", ...DIMS.map((d) => d.key), "richness", "diegetic_dead", "diegetic_wired"];
  const csv = [cols.join(",")];
  for (const s of scored) {
    if (s.race === SELFTEST_RACE) continue;
    csv.push([
      s.race, s.pct, s.raw, s.target ? "YES" : "",
      ...DIMS.map((d) => fmt(s.scores[d.key])),
      s.richness, s.drift ? s.drift.dead : "", s.drift ? s.drift.wired : "",
    ].map(csvCell).join(","));
  }
  fs.writeFileSync(OUT_CSV, csv.join("\r\n") + "\r\n", "utf8");
}

function fmt(v) { const n = Number(v); return Number.isFinite(n) ? String(n) : "0"; }
function assertFile(f) { if (!fs.existsSync(f)) throw new Error(`Required file not found: ${f}`); }
function csvCell(v) { const t = asciiSafe(v); return /[",\r\n]/.test(t) ? `"${t.replace(/"/g, '""')}"` : t; }
function asciiSafe(v) {
  return String(v ?? "")
    .replace(/—/g, "--").replace(/[‐-–]/g, "-")
    .replace(/→/g, "->").replace(/[‘’]/g, "'").replace(/[“”]/g, '"')
    .replace(/[^\x00-\x7F]/g, "?");
}

main();
