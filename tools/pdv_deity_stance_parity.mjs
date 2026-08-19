#!/usr/bin/env node
// Deity stance parity: the ESP records, the shipped matrix JSON, and the origin rosters must
// agree. Fails by exit code on any disagreement.
//
// WHY THIS EXISTS, and why the existing check did not catch it.
//
// A player's stance toward a god has FOUR sources, with JSON providing the
// richest runtime label:
//
//   1. JSON  stance.<Race>.<Deity>  in PDV_QuestReactionMatrix.json   <- WINS
//   2. ESP   Stance_<Race>  VMAD property on the PDV_Deity_* quest    <- fallback only
//   3. IsDashboardDeityInOriginRoster (PDV__ManagerQuest.psc)         <- gates reachability
//   4. ApplyStancesForDeity (PDV__ManagerQuest.psc)                   <- existing-save VMAD projection
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
import { resolveDevotionRoot } from "./lib/pdv_paths.mjs";
import { familySourceText, stripQualifiers } from "./lib/pdv_symbol_home.mjs";

const KNOWN_FLAGS = new Set(["--json", "--matrix"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_deity_stance_parity" });
const AS_JSON = process.argv.includes("--json");

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const MCM = path.join(SOURCE_DIR, "PDV_MCM.psc");
const matrixArg = process.argv[process.argv.indexOf("--matrix") + 1];
const MATRIX = process.argv.includes("--matrix") && matrixArg
  ? path.resolve(ROOT, matrixArg)
  : path.join(resolveDevotionRoot(), "SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "PDV_QuestReactionCore.v2.json");

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

const normaliseName = (value) => String(value ?? "").toLowerCase().replace(/[^a-z0-9]/g, "");

// Existing saves do not re-read VMAD properties, so ApplyStancesForDeity is a
// fourth stance source. Parse its branches instead of carrying another copy of
// the matrix in this gate. TOLERATED/CURSE project to FOREIGN because the
// record script has only four integer states; that projection must still keep
// generic NATIVE-only scoring closed.
function parseRuntimeMigration(src) {
  const start = src.indexOf("Function ApplyStancesForDeity");
  if (start < 0) return {};
  const tail = src.slice(start);
  const body = tail.slice(0, tail.indexOf("\nEndFunction"));
  const branches = [...body.matchAll(/^\s*(?:if|elseIf)\s+sName\s+==([^\n]+)$/gm)];
  const out = {};
  for (let index = 0; index < branches.length; index += 1) {
    const branch = branches[index];
    const branchStart = branch.index + branch[0].length;
    const branchEnd = index + 1 < branches.length ? branches[index + 1].index : body.length;
    const branchBody = body.slice(branchStart, branchEnd);
    const apply = branchBody.match(/ApplyStances\(deity,\s*([^)]+)\)/);
    if (!apply) continue;
    const values = apply[1].split(",").map((value) => Number(value.trim()));
    if (values.length !== RACES.length || values.some((value) => !Number.isInteger(value))) continue;
    const stances = Object.fromEntries(RACES.map((race, raceIndex) => [race, values[raceIndex]]));
    for (const alias of [...branch[1].matchAll(/"([^"]+)"/g)].map((match) => match[1])) {
      out[normaliseName(alias)] = stances;
    }
  }
  return out;
}

function functionBlock(src, functionName) {
  // Anchored on the declaration's open paren, not a bare prefix match. A plain
  // indexOf("Function SetActiveDeity") also matches "Function SetActiveDeityRef"
  // and returns the WRONG body -- which silently reported the real function's
  // contract as missing once SetActiveDeity moved out of the manager.
  const decl = new RegExp("Function\\s+" + functionName + "\\s*\\(");
  const hit = decl.exec(src);
  if (!hit) return "";
  const start = hit.index;
  const tail = src.slice(start);
  const end = tail.indexOf("\nEndFunction");
  return end < 0 ? tail : tail.slice(0, end);
}

// Searched, not hashed or written. The 2.0 rebuild moves manager functions into
// deep modules, so reading only PDV__ManagerQuest.psc makes every parse and
// source-contract needle below blind to a body that merely relocated.
// familySourceText() is strictly additive: manager text first and verbatim, then
// each extracted module with qualifiers stripped.
const managerSrc = familySourceText(ROOT, SOURCE_DIR);
// Qualifier-stripped for the same reason: the MCM's calls picked up a
// `LedgerRuntime.` hop when SetActiveDeity moved, which is a relocation, not a
// contract change. The needle below still pins the receiver and the arguments.
const mcmSrc = stripQualifiers(fs.readFileSync(MCM, "utf8"));
const ROSTER = parseRosters(managerSrc);
const CANON = parseCanonicalNames(managerSrc);
const RUNTIME_MIGRATION = parseRuntimeMigration(managerSrc);
const runtimeMigrationDeityCount = new Set(Object.values(RUNTIME_MIGRATION)).size;
if (Object.keys(ROSTER).length !== RACES.length) {
  fail("parse", `parsed ${Object.keys(ROSTER).length} rosters from IsDashboardDeityInOriginRoster, expected ${RACES.length}`);
}
if (Object.keys(CANON).length === 0) fail("parse", "parsed no canonical deity names from RepairDeityRuntimeName");

const selectionBlock = functionBlock(managerSrc, "SetActiveDeity");
if (!selectionBlock.includes("IsDashboardDeityInOriginRoster(newDeity") || !selectionBlock.includes("UsesFormalCommitmentOffersForDeity(newDeity")) {
  fail("source-contract", "SetActiveDeity lacks the central roster/formal-offer selection guard");
}
if (!mcmSrc.includes("forcePatronManager.SetActiveDeity(forcePatronDeity, True)") || !mcmSrc.includes("primeNeglectManager.SetActiveDeity(primeNeglectDeity, True)")) {
  fail("source-contract", "MCM patron/neglect test controls do not use the explicit off-roster debug override");
}
const grandfatherBlock = functionBlock(managerSrc, "IsGrandfatheredOffRosterPatron");
if (!grandfatherBlock.includes("PATRON_STATE_ACTIVE") || !grandfatherBlock.includes('stance == "FOREIGN" || stance == "TOLERATED"')) {
  fail("source-contract", "grandfathered patrons are not limited to an existing active FOREIGN/TOLERATED relationship");
}
const questAwardBlock = functionBlock(managerSrc, "ApplyQuestReactionPiety");
if (!questAwardBlock.includes("AwardPietyInternal(deity, amount, True, reason, False)")) {
  fail("source-contract", "quest reactions do not bypass the second VMAD stance multiplier");
}
const gainPipelineBlock = functionBlock(managerSrc, "RunGainPipeline");
if (!gainPipelineBlock.includes("GetEffectiveGainMultiplierWithoutStance")) {
  fail("source-contract", "gain pipeline lacks the no-second-stance path");
}
const shrineAwardBlock = functionBlock(managerSrc, "AwardShrinePrayerToDeityName");
if (!shrineAwardBlock.includes("IsGrandfatheredOffRosterPatron") || !shrineAwardBlock.includes("GetQuestReactionStanceMultiplier")) {
  fail("source-contract", "shrine prayer does not preserve a grandfathered patron at the reduced matrix rate");
}

// ---- 3. JSON stance table --------------------------------------------------------
if (!fs.existsSync(MATRIX)) {
  console.error(JSON.stringify({ status: "FAIL", reason: `matrix JSON not found: ${MATRIX}` }, null, 2));
  process.exit(1);
}
const strings = JSON.parse(fs.readFileSync(MATRIX, "utf8")).string ?? {};
const jsonStance = (race, name) => strings[`stance.${race}.${name}`.toLowerCase()] ?? null;

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

// 5c. Existing-save migration parity. Unlike the ESP, this source runs again
// after a version bump and therefore wins for generic likes/dislikes scoring.
// It must match exact four-state labels and use FOREIGN as the safe projection
// for richer JSON-only TOLERATED/CURSE labels.
for (const [stem, rec] of Object.entries(esp)) {
  const canon = CANON[stem] ?? rec.recordName;
  const migration = RUNTIME_MIGRATION[normaliseName(canon)] ?? RUNTIME_MIGRATION[normaliseName(rec.recordName)];
  if (!migration) {
    fail("runtime-migration-missing", `${stem}: no ApplyStancesForDeity branch for ${canon ?? rec.recordName ?? "unknown"}`);
    continue;
  }
  for (const race of RACES) {
    const effective = jsonStance(race, canon) ?? ESP_STANCE_NAME[rec.stances[race]] ?? null;
    if (effective === null) continue;
    const projected = effective === "TOLERATED" || effective === "CURSE" ? "FOREIGN" : effective;
    const migrated = ESP_STANCE_NAME[migration[race]] ?? `UNKNOWN(${migration[race]})`;
    if (migrated !== projected) {
      fail("runtime-migration-drift", `${race}/${stem}: effective=${effective} projected=${projected} migration=${migrated}`);
    }
  }
}

// 5d. Roster coherence. A deity the roster excludes must not read NATIVE for that race -
// that is the "off-roster god still looks like yours" state, and it is what made the 1.5.0
// Altmer change look done when the records still disagreed.
const reducedRatePairs = [];
for (const race of RACES) {
  const roster = ROSTER[race] ?? [];
  for (const [stem, rec] of Object.entries(esp)) {
    const canon = CANON[stem] ?? rec.recordName;
    const effective = jsonStance(race, canon) ?? ESP_STANCE_NAME[rec.stances[race]] ?? null;
    if (effective === null) continue;
    const inRoster = roster.includes(stem);
    if (!inRoster && effective === "NATIVE") fail("off-roster-native", `${race}/${stem}: not in the ${race} roster but reads NATIVE`);
    if (inRoster && (effective === "FOREIGN" || effective === "TOLERATED")) {
      reducedRatePairs.push(`${race}/${stem}:${effective}`);
    }
  }
}
if (!reducedRatePairs.length) fail("dead-reduced-rate-config", "no roster-visible FOREIGN/TOLERATED pair can consume stanceMult.FOREIGN/TOLERATED");

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
  runtimeMigrationDeities: runtimeMigrationDeityCount,
  jsonStanceEntries: Object.keys(strings).filter((k) => k.startsWith("stance.")).length,
  reducedRatePairs,
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
