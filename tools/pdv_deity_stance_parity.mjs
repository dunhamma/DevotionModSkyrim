#!/usr/bin/env node
// Deity stance parity: the ESP records, the shipped matrix JSON, and the origin rosters must
// agree. Fails by exit code on any disagreement.
//
// WHY THIS EXISTS, and why the existing check did not catch it.
//
// A player's stance toward a god has THREE sources, and only one wins at runtime:
//
//   1. JSON  stance.<Race>.<Deity>  in PDV_QuestReactionMatrix.json   <- WINS
//   2. ESP   Stance_<Race>  VMAD property on the PDV_Deity_* quest    <- fallback only
//   3. IsDashboardDeityInOriginRoster (PDV__ManagerQuest.psc)         <- gates reachability
//
// GetQuestReactionStance (PDV__ManagerQuest.psc) reads the JSON first and falls back to the
// record. So the two can drift with no symptom until something reads the losing copy.
//
// They HAD drifted, in 8 places, when this was written on 2026-08-09 - including the three
// that are the whole point of the 1.5.0 Altmer change (Mara, Y'ffre and Stendarr are FOREIGN
// for Altmer in the JSON and still NATIVE in the records). Behaviour was correct only because
// the JSON happens to win.
//
// pdv_verify DOES check stances and could never have caught this: it pins hardcoded expected
// values for 3 of 33 deities (Kyne, Talos, Auri-El) and reads the JSON stance table zero
// times. Comparing one source against a literal in the tool is pinning, not verifying - it
// stays green while the OTHER source moves, which is exactly what happened. None of the 8
// drifted pairs is one of its 3, so its coverage would not have helped either.
//
// This tool therefore derives EVERYTHING from live sources and hardcodes no stance, no
// roster and no deity name. A gate that carries its own copy of the answer is a fourth place
// for the answer to be wrong.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { openHousecarl, extractHousecarlText, resolveHousecarlExe } from "./lib/pdv_housecarl_stdio.mjs";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--json", "--matrix"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_deity_stance_parity" });
const AS_JSON = process.argv.includes("--json");

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANAGER = path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const matrixArg = process.argv[process.argv.indexOf("--matrix") + 1];
const MATRIX = process.argv.includes("--matrix") && matrixArg
  ? path.resolve(ROOT, matrixArg)
  : "D:/Wabbajack/modlists/Anvil/mods/Devotion/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix.json";

const RACES = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];
const ESP_STANCE_NAME = { 0: "NATIVE", 1: "FOREIGN", 2: "TABOO", 3: "HOSTILE" };

const failures = [];
const warnings = [];
const notes = [];
const fail = (kind, detail) => failures.push({ kind, detail });
// Reported, but does not fail. Reserved for states with NO available fix - failing on
// something nobody can act on is how a gate gets ignored, and an ignored gate is worse than
// no gate because it looks like coverage.
const warn = (kind, detail) => warnings.push({ kind, detail });

// ---- 1. Rosters, parsed from the manager rather than copied ----------------------
// IsDashboardDeityInOriginRoster is a chain of `deity == PDV_<Stem>` comparisons per race.
function parseRosters(src) {
  const fn = src.slice(src.indexOf("Bool Function IsDashboardDeityInOriginRoster"));
  const body = fn.slice(0, fn.indexOf("\nEndFunction"));
  const rosters = {};
  const re = /originRace == ORIGIN_([A-Z]+)\s*\n\s*return ([^\n]+)/g;
  for (const m of body.matchAll(re)) {
    const race = RACES.find((r) => r.toUpperCase() === m[1] || (m[1] === "ORSIMER" && r === "Orc"));
    const stems = [...m[2].matchAll(/deity == PDV_(\w+)/g)].map((x) => x[1]);
    if (race && stems.length) rosters[race] = stems;
  }
  return rosters;
}

// ---- 2. Canonical display names, parsed from RepairDeityRuntimeName --------------
// The JSON is keyed by the CANONICAL name, which is not always the name sitting in the
// record: PDV_Deity_Azura's DeityName is "Azurah" and is repaired to "Azura" at init. Using
// the record's raw value as the lookup key would miss the JSON and silently read the ESP.
function parseCanonicalNames(src) {
  const out = {};
  for (const m of src.matchAll(/RepairDeityRuntimeName\(PDV_(\w+),\s*"([^"]+)"\)/g)) out[m[1]] = m[2];
  return out;
}

const managerSrc = fs.readFileSync(MANAGER, "utf8");
const ROSTER = parseRosters(managerSrc);
const CANON = parseCanonicalNames(managerSrc);
if (Object.keys(ROSTER).length !== RACES.length) {
  fail("parse", `parsed ${Object.keys(ROSTER).length} rosters from IsDashboardDeityInOriginRoster, expected ${RACES.length}`);
}
if (Object.keys(CANON).length === 0) fail("parse", "parsed no canonical deity names from RepairDeityRuntimeName");

// ---- 3. JSON stance table --------------------------------------------------------
if (!fs.existsSync(MATRIX)) {
  console.error(JSON.stringify({ status: "FAIL", reason: `matrix JSON not found: ${MATRIX}` }, null, 2));
  process.exit(1);
}
const strings = JSON.parse(fs.readFileSync(MATRIX, "utf8")).string ?? {};
const jsonStance = (race, name) => strings[`stance.${race}.${name}`] ?? null;

// ---- 4. ESP stances, read live ---------------------------------------------------
try { resolveHousecarlExe(); } catch (error) {
  console.error(JSON.stringify({ status: "SKIP", reason: `no houseCARL server: ${error.message.split("\n")[0]}` }, null, 2));
  process.exit(0); // SKIP, not PASS - an unavailable prover is not a proof
}

const session = openHousecarl();
const esp = {};
try {
  const listed = extractHousecarlText(await session.call("housecarl_cross_plugin_query", {
    type: "QUST", editorid_contains: "PDV_Deity_", plugins: ["Devotion.esp"], defined_in: true, limit: 200,
  }));
  const deities = [...listed.matchAll(/^\s+([0-9A-Fa-f]{6}:\S+)\s+type=Quest\s+editorid=PDV_Deity_(\w+)/gm)]
    .map((m) => ({ formid: m[1], stem: m[2] }));
  if (!deities.length) fail("readback", "no PDV_Deity_* quests found in Devotion.esp");

  for (const { formid, stem } of deities) {
    const text = extractHousecarlText(await session.call("housecarl_read_record", {
      formid, fields: ["VirtualMachineAdapter.Scripts[0].Properties"], depth: 2,
    }));
    const nameByIndex = {};
    for (const m of text.matchAll(/Properties\[(\d+)\] = \[Script\w+Property\] Name=(\S+)/g)) nameByIndex[m[1]] = m[2];
    const dataByIndex = {};
    for (const m of text.matchAll(/Properties\[(\d+)\]\.Data = (.*)/g)) dataByIndex[m[1]] = m[2].trim();
    const byName = {};
    for (const [i, n] of Object.entries(nameByIndex)) byName[n] = dataByIndex[i];
    esp[stem] = {
      formid,
      recordName: byName.DeityName ?? null,
      stances: Object.fromEntries(RACES.map((r) => [r, byName[`Stance_${r}`] === undefined ? null : Number(byName[`Stance_${r}`])])),
    };
  }
} finally {
  session.close();
}

// ---- 5. Checks -------------------------------------------------------------------
for (const [stem, rec] of Object.entries(esp)) {
  // 5a. Every deity record must carry all ten stances. An unbound property is not a
  // default - it is a record that cannot answer the question, and the VMAD layer is where
  // this project has been bitten before.
  const unbound = RACES.filter((r) => rec.stances[r] === null);
  if (unbound.length) fail("unbound-property", `${stem} (${rec.formid}) has no Stance_${unbound.join(", Stance_")}`);

  const canon = CANON[stem] ?? rec.recordName;
  if (!canon) { notes.push(`${stem}: no canonical name resolved; JSON pairs skipped`); continue; }

  for (const race of RACES) {
    const j = jsonStance(race, canon);
    if (j === null) continue;                       // JSON does not cover this pair; ESP is authority
    const e = rec.stances[race];
    if (e === null) continue;                       // already reported as unbound
    const eName = ESP_STANCE_NAME[e] ?? `UNKNOWN(${e})`;

    // 5b. THE CHECK THIS TOOL EXISTS FOR. The JSON wins at runtime, so a mismatch means the
    // record is a stale second copy that any non-JSON reader will get wrong.
    if (j !== eName) {
      // TOLERATED and CURSE cannot be expressed by the record at all: PDV_DeityBase defines
      // four stances and the JSON uses six. So this is a WARNING, not a failure - "fix the
      // record" is not an available action, and failing on it would leave the gate
      // permanently red until someone changes the design. Resolving it means either
      // extending the stance vocabulary or deleting the ESP copy and letting the JSON be the
      // only source. Both are design calls, not gate fodder.
      if (j === "TOLERATED" || j === "CURSE") warn("inexpressible-in-esp", `${race}/${stem}: JSON=${j} ESP=${eName} (record cannot hold this value)`);
      else fail("esp-json-drift", `${race}/${stem}: JSON=${j} ESP=${eName}`);
    }
  }
}

// 5c. Roster coherence. A deity the roster excludes must not read NATIVE for that race -
// that is the "off-roster god still looks like yours" state, and it is what made the 1.5.0
// Altmer change look done when the records still disagreed.
for (const race of RACES) {
  const roster = ROSTER[race] ?? [];
  for (const [stem, rec] of Object.entries(esp)) {
    const canon = CANON[stem] ?? rec.recordName;
    const effective = jsonStance(race, canon) ?? ESP_STANCE_NAME[rec.stances[race]] ?? null;
    if (effective === null) continue;
    const inRoster = roster.includes(stem);
    if (!inRoster && effective === "NATIVE") fail("off-roster-native", `${race}/${stem}: not in the ${race} roster but reads NATIVE`);
  }
}

// ---- 6. Report -------------------------------------------------------------------
const group = (list) => {
  const by = {};
  for (const f of list) (by[f.kind] ??= []).push(f.detail);
  return by;
};
const byKind = group(failures);
const warnByKind = group(warnings);
const result = {
  status: failures.length ? "FAIL" : "PASS",
  deities: Object.keys(esp).length,
  races: RACES.length,
  jsonStanceEntries: Object.keys(strings).filter((k) => k.startsWith("stance.")).length,
  failures: failures.length,
  warnings: warnings.length,
  ...(failures.length ? { failureDetail: byKind } : {}),
  ...(warnings.length ? { warningDetail: warnByKind } : {}),
  ...(notes.length ? { notes } : {}),
};

if (AS_JSON) console[failures.length ? "error" : "log"](JSON.stringify(result, null, 2));
else {
  const line = `deity stance parity: ${result.status} (${result.deities} deities x ${result.races} races, ${result.failures} failure(s), ${result.warnings} warning(s))`;
  console[failures.length ? "error" : "log"](line);
  for (const [kind, list] of Object.entries(byKind)) {
    console.error(`  FAIL ${kind} (${list.length}):`);
    list.forEach((d) => console.error(`    ${d}`));
  }
  for (const [kind, list] of Object.entries(warnByKind)) {
    console.log(`  warn ${kind} (${list.length}):`);
    list.forEach((d) => console.log(`    ${d}`));
  }
  notes.forEach((n) => console.log(`  note: ${n}`));
}
process.exit(failures.length ? 1 : 0);
