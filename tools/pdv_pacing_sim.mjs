#!/usr/bin/env node
/*
 * PDV Pacing Economy Simulator (C-PACING-SIM) - machine half of the 1.0
 * magnitude/pacing gate.
 *
 * Derives per-race piety-per-day capability from the authored tables (deity
 * likes/dislikes CSV + race reward specs) and the live manager constants, and
 * FAILS when a race busts the locked pacing model
 * (references/authoring/PDV_PietyPaceBalancingTable.md):
 *
 *   - clamp check: PIETY_DAILY_MAX_DELTA in the live manager must equal the
 *     contract's dawnClampPerDay (4.3) and be applied in the dawn path
 *   - ceiling: a maximizer saturating the clamp reaches Champion (85) within
 *     greedyDaysTo85Band ([18,24] - locked ceiling is ~20)
 *   - sustain: the race's renewable tables must be able to SATURATE the
 *     default pace (grossDailyMax >= defaultNetPerDay 3.3), else the race is
 *     reward-poor and its real calendar drifts past the steady band
 *   - steady: typical play (min(gross, 3.3)/day) reaches 85 within
 *     steadyDaysTo85Band ([26,45] - locked default is ~26)
 *
 * Modeling assumptions (documented, deliberately coarse - the bands are wide):
 *   - dailyCap > 0 is read as max firings/day; uncapped (+) events count as
 *     UNCAPPED_TYPICAL_USES firings; cooldownDays >= 1 limits to 1/cooldown
 *   - gross is computed for the race's BEST single deity (focused play)
 *   - quest-matrix milestones are clamp-bypassing one-time budget, reported
 *     as info, never gated here
 *
 * Bands and clamp target come from the C-PACING-SIM params in
 * PDV_1_0_EndStateContract.json - tuning is a contract edit, not a tool edit.
 *
 * Emits PDV_PacingSimLedger.json/.md. Exit 0 iff PASS. Flags: --json, --self-test
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = "references/authoring";
const CONTRACT = path.join(ROOT, AUTH, "PDV_1_0_EndStateContract.json");
const CSV_DEITY = path.join(ROOT, AUTH, "PDV_DeityLikesDislikes.csv");
const CSV_PRINCE = path.join(ROOT, AUTH, "PDV_DeityLikesDislikes_Princes_V2.csv");
const MANAGER = path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const OUT_BASE = path.join(ROOT, AUTH, "PDV_PacingSimLedger");
const RACES = ["Altmer", "Argonian", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"];
const UNCAPPED_TYPICAL_USES = 2;
const DEFAULT_NET_PER_DAY = 3.3; // locked default pace, PDV_PietyPaceBalancingTable.md section 1

const flags = new Set(process.argv.slice(2));

function norm(name) { return String(name).toLowerCase().replace(/[^a-z0-9]/g, ""); }

export function parseCsvRows(text) {
  const lines = text.split(/\r?\n/).filter(Boolean);
  const header = lines[0].split(",");
  const idx = (n) => header.indexOf(n);
  return lines.slice(1).map((line) => {
    const c = line.split(",");
    return {
      actor: c[idx("actor")],
      eventId: Number(c[idx("eventId")]),
      sentiment: c[idx("sentiment")],
      baseDelta: Number(c[idx("baseDelta")]),
      dailyCap: Number(c[idx("dailyCap")]),
      cooldownDays: Number(c[idx("cooldownDays")]),
    };
  });
}

// Renewable gross piety/day for one actor's positive rows under the
// documented firing assumptions.
export function grossDailyFor(rows, actor) {
  let gross = 0;
  for (const r of rows) {
    if (norm(r.actor) !== norm(actor) || r.sentiment !== "+") continue;
    let uses = r.dailyCap > 0 ? r.dailyCap : UNCAPPED_TYPICAL_USES;
    if (r.cooldownDays >= 1) uses = Math.min(uses, 1 / r.cooldownDays);
    gross += r.baseDelta * uses;
  }
  return gross;
}

export function evaluate({ managerSource, deityRows, princeRows, raceDeities, params }) {
  const findings = [];
  const clampTarget = params.dawnClampPerDay;
  const champion = params.tiers.champion;
  const [gLo, gHi] = params.greedyDaysTo85Band;
  const [sLo, sHi] = params.steadyDaysTo85Band;

  // Clamp constants parsed from the LIVE manager so code/model drift fails.
  const clampMatch = managerSource.match(/PIETY_DAILY_MAX_DELTA\s*=\s*([\d.]+)/);
  const clamp = clampMatch ? Number(clampMatch[1]) : null;
  const clampApplied = /dailyCap\s*=\s*PIETY_DAILY_MAX_DELTA/.test(managerSource) || /ClampValue\([^)]*PIETY_DAILY_MAX_DELTA/.test(managerSource);
  if (clamp == null) findings.push({ severity: "FAIL", item: "clamp", detail: "PIETY_DAILY_MAX_DELTA not found in live manager" });
  else if (Math.abs(clamp - clampTarget) > 0.001) findings.push({ severity: "FAIL", item: "clamp", detail: `PIETY_DAILY_MAX_DELTA=${clamp}, contract expects ${clampTarget}` });
  if (!clampApplied) findings.push({ severity: "FAIL", item: "clamp-applied", detail: "clamp constant is not read into the dawn daily-cap path" });

  const perRace = [];
  for (const race of RACES) {
    const deities = raceDeities[race] ?? [];
    let best = { deity: null, gross: 0 };
    for (const d of deities) {
      const gross = grossDailyFor(deityRows, d);
      if (gross > best.gross) best = { deity: d, gross };
    }
    const effClamp = clamp ?? clampTarget;
    const ceilingRate = Math.min(effClamp, best.gross);
    const greedyDays = ceilingRate > 0 ? Math.ceil(champion / ceilingRate) : Infinity;
    const steadyRate = Math.min(best.gross, DEFAULT_NET_PER_DAY);
    const steadyDays = steadyRate > 0 ? Math.ceil(champion / steadyRate) : Infinity;
    const row = {
      race, bestDeity: best.deity, grossDailyMax: Number(best.gross.toFixed(2)),
      greedyDaysTo85: greedyDays, steadyDaysTo85: steadyDays,
      status: "PASS", notes: [],
    };
    if (best.gross < DEFAULT_NET_PER_DAY) {
      row.status = "FAIL";
      row.notes.push(`reward-poor: renewable tables max ${best.gross.toFixed(2)}/day < default pace ${DEFAULT_NET_PER_DAY} (rich-day-to-day gap)`);
    }
    if (greedyDays < gLo || greedyDays > gHi) {
      row.status = "FAIL";
      row.notes.push(`greedy days-to-85 ${greedyDays} outside [${gLo},${gHi}]`);
    }
    if (steadyDays < sLo || steadyDays > sHi) {
      row.status = "FAIL";
      row.notes.push(`steady days-to-85 ${steadyDays} outside [${sLo},${sHi}]`);
    }
    perRace.push(row);
  }

  // Prince pacing: info-only rows (prince tiers share the same clamp).
  const princeInfo = [];
  const princeActors = [...new Set(princeRows.map((r) => r.actor))];
  for (const actor of princeActors) {
    const gross = grossDailyFor(princeRows, actor);
    princeInfo.push({ prince: actor.replace(/^Daedric:/, ""), grossDailyMax: Number(gross.toFixed(2)) });
  }

  const failing = perRace.filter((r) => r.status === "FAIL");
  const status = findings.some((f) => f.severity === "FAIL") || failing.length ? "FAIL" : "PASS";
  return { status, clamp, clampApplied, findings, perRace, princeInfo };
}

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  const params = { dawnClampPerDay: 4.3, tiers: { champion: 85 }, greedyDaysTo85Band: [18, 24], steadyDaysTo85Band: [26, 45] };
  const mgr = "Float Property PIETY_DAILY_MAX_DELTA = 4.3 AutoReadOnly\n Float dailyCap = PIETY_DAILY_MAX_DELTA\n";
  const rows = [
    { actor: "richgod", eventId: 1, sentiment: "+", baseDelta: 1.3, dailyCap: 2, cooldownDays: 0 },
    { actor: "richgod", eventId: 2, sentiment: "+", baseDelta: 2.0, dailyCap: 2, cooldownDays: 0 },
    { actor: "richgod", eventId: 3, sentiment: "-", baseDelta: -5, dailyCap: 1, cooldownDays: 0 },
    { actor: "poorgod", eventId: 1, sentiment: "+", baseDelta: 0.5, dailyCap: 2, cooldownDays: 0 },
  ];
  expect("gross ignores minus rows", Math.abs(grossDailyFor(rows, "richgod") - 6.6) < 0.001);
  const rep = evaluate({
    managerSource: mgr, deityRows: rows, princeRows: [],
    raceDeities: Object.fromEntries(["Nord", "Imperial", "Breton", "Dunmer", "Khajiit", "Bosmer", "Redguard", "Orc", "Argonian"].map((r) => [r, ["richgod"]]).concat([["Altmer", ["poorgod"]]])),
    params,
  });
  const nord = rep.perRace.find((r) => r.race === "Nord");
  const altmer = rep.perRace.find((r) => r.race === "Altmer");
  expect("rich race passes (greedy 20, steady 26)", nord.status === "PASS" && nord.greedyDaysTo85 === 20 && nord.steadyDaysTo85 === 26);
  expect("poor race fails reward-poor", altmer.status === "FAIL" && altmer.notes.some((n) => n.includes("reward-poor")));
  expect("overall FAIL when a race fails", rep.status === "FAIL");
  const repBadClamp = evaluate({ managerSource: "Float Property PIETY_DAILY_MAX_DELTA = 5.0\n dailyCap = PIETY_DAILY_MAX_DELTA", deityRows: rows, princeRows: [], raceDeities: { Nord: ["richgod"] }, params });
  expect("clamp drift FAILs", repBadClamp.findings.some((f) => f.item === "clamp"));
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

function main() {
  const contract = JSON.parse(fs.readFileSync(CONTRACT, "utf8"));
  const params = contract.criteria.find((c) => c.id === "C-PACING-SIM")?.params;
  if (!params) { console.error("C-PACING-SIM params missing from the end-state contract."); process.exitCode = 2; return; }

  const deityRows = parseCsvRows(fs.readFileSync(CSV_DEITY, "utf8"));
  const princeRows = parseCsvRows(fs.readFileSync(CSV_PRINCE, "utf8"));
  const managerSource = fs.readFileSync(MANAGER, "utf8");

  // Race -> worship-target deity names from the race reward specs.
  const raceDeities = {};
  for (const race of RACES) {
    const spec = JSON.parse(fs.readFileSync(path.join(ROOT, AUTH, `PDV_${race}RewardRecords.spec.json`), "utf8"));
    raceDeities[race] = (spec.deityQuests ?? []).map((q) => q.deityName).filter(Boolean);
  }

  const report = evaluate({ managerSource, deityRows, princeRows, raceDeities, params });
  const out = {
    schema: "pdv.pacing-sim-ledger.v1",
    status: report.status,
    clamp: report.clamp,
    clampApplied: report.clampApplied,
    params,
    assumptions: {
      uncappedTypicalUses: UNCAPPED_TYPICAL_USES,
      defaultNetPerDay: DEFAULT_NET_PER_DAY,
      model: "best single deity focused play; dailyCap = max firings/day; milestones clamp-bypassing one-time budget, info only",
    },
    findings: report.findings,
    perRace: report.perRace,
    princeInfo: report.princeInfo,
  };
  fs.writeFileSync(`${OUT_BASE}.json`, JSON.stringify(out, null, 2) + "\n", "utf8");

  const md = [
    "# PDV Pacing Sim Ledger", "",
    "GENERATED by tools/pdv_pacing_sim.mjs - do not hand-edit.", "",
    `Overall: **${report.status}**. Clamp: ${report.clamp} (applied: ${report.clampApplied}). Bands: greedy [${params.greedyDaysTo85Band}], steady [${params.steadyDaysTo85Band}] days to ${params.tiers.champion}.`, "",
    "| Race | Best deity | Gross/day | Greedy d85 | Steady d85 | Status | Notes |", "|---|---|---|---|---|---|---|",
  ];
  for (const r of report.perRace) md.push(`| ${r.race} | ${r.bestDeity} | ${r.grossDailyMax} | ${r.greedyDaysTo85} | ${r.steadyDaysTo85} | ${r.status} | ${r.notes.join("; ")} |`);
  md.push("", "Prince renewable gross/day (info only):", "");
  for (const p of report.princeInfo) md.push(`- ${p.prince}: ${p.grossDailyMax}`);
  md.push("");
  fs.writeFileSync(`${OUT_BASE}.md`, md.join("\n") + "\n", "utf8");

  if (flags.has("--json")) console.log(JSON.stringify(out, null, 2));
  else {
    console.log(`Pacing sim: ${report.status} (clamp ${report.clamp}, applied ${report.clampApplied})`);
    for (const f of report.findings) console.log(`[${f.severity}] ${f.item}: ${f.detail}`);
    for (const r of report.perRace) console.log(`[${r.status}] ${r.race}: best=${r.bestDeity} gross=${r.grossDailyMax}/day greedy=${r.greedyDaysTo85}d steady=${r.steadyDaysTo85}d ${r.notes.join("; ")}`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
