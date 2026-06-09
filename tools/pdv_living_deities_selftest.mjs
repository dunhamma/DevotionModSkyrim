#!/usr/bin/env node
/*
 * Self-test / regression net for the LD-P1 living-deities compile output.
 *
 * Compiles the authoring CSVs in-memory (pdv_living_deities_compile.mjs --stdout)
 * and asserts the runtime JSON is well-formed BEFORE the Papyrus wiring consumes
 * it, so a malformed row (bad vocab, column-shift, orphan key, parallel-array
 * drift, empty deity) is caught here instead of in-game. This is the pre-wiring
 * gate. Run: node tools/pdv_living_deities_selftest.mjs
 *
 * Exit 0 = PASS, exit 1 = FAIL. INFO lines are advisory and never fail the run.
 */

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const COMPILE = path.join(__dirname, "pdv_living_deities_compile.mjs");

const STANCES = new Set(["NATIVE", "TOLERATED", "FOREIGN", "TABOO", "HOSTILE", "CURSE"]);
const BANDS = new Set(["Wroth", "Cool", "Pleased", "Exalted"]);
const TONES = new Set(["positive", "negative", "neutral"]);
// LD-P1 omen transitions: simple up/down + band-targeted escalations + dream.
const TRANSITIONS = new Set(["up", "down", "dream", "->Wroth", "->Cool", "->Pleased", "->Exalted"]);
const PILOT_DEITIES = ["Kyne", "Hircine"];
// Demand signal-binding vocab (M3 Spike 3): a demand fulfills against the
// day-to-day faucet (Int eventType), the curated quest matrix tag, or both.
const BINDING_LAYERS = new Set(["faucet", "quest_matrix", "faucet|quest_matrix"]);
const WIRED_TODAY = new Set(["yes", "no", "partial"]);
// Known faucet eventType vocabulary: live 1/2/40 + the reserved 300-369 block
// (references/authoring/PDV_DeityLikesDislikesMatrix.md section 4).
const isKnownEventType = (n) =>
  n === 1 || n === 2 || n === 40 || (n >= 300 && n <= 369);
// Events 1-4 are live today; the 300+ block has no SM receivers/router yet.
const isWiredEventType = (n) => n >= 1 && n <= 4;

const failures = [];
const infos = [];
const fail = (msg) => failures.push(msg);
const info = (msg) => infos.push(msg);

function loadCompiled() {
  const raw = execFileSync("node", [COMPILE, "--stdout"], {
    encoding: "utf8",
    maxBuffer: 32 * 1024 * 1024,
  });
  return JSON.parse(raw);
}

function checkTopLevel(out) {
  if (out.schema !== "pdv-living-deities.v1") fail(`unexpected schema "${out.schema}"`);
  for (const f of ["deities", "demandKeys", "omenKeys"]) {
    if (!Array.isArray(out[f])) fail(`top-level ${f} is not an array`);
  }
  if ((out.deities || []).length === 0) fail("deities empty");
  if (new Set(out.deities).size !== (out.deities || []).length) fail("duplicate deities");
  if (new Set(out.demandKeys).size !== (out.demandKeys || []).length) fail("duplicate demand keys");
  if (new Set(out.omenKeys).size !== (out.omenKeys || []).length) fail("duplicate omen keys");
}

// Vocabulary check: alpha numeric + sane, band thresholds numeric + ordered,
// stance-ceiling stances/bands in the controlled vocabulary, no empty deity.
function checkMood(out) {
  for (const deity of out.deities) {
    if (!deity || !deity.trim()) {
      fail(`mood: empty deity in deities[] (likely CSV column shift)`);
      continue;
    }
    const alpha = out[`mood.${deity}.alpha`];
    const wrothMax = out[`mood.${deity}.bandWrothMax`];
    const coolMax = out[`mood.${deity}.bandCoolMax`];
    const pleasedMax = out[`mood.${deity}.bandPleasedMax`];
    if (typeof alpha !== "number") fail(`mood ${deity}: alpha missing/non-numeric`);
    else if (alpha <= 0 || alpha >= 1) fail(`mood ${deity}: alpha ${alpha} out of (0,1)`);
    for (const [name, v] of [["bandWrothMax", wrothMax], ["bandCoolMax", coolMax], ["bandPleasedMax", pleasedMax]]) {
      if (typeof v !== "number") fail(`mood ${deity}: ${name} missing/non-numeric`);
      else if (v < -100 || v > 100) fail(`mood ${deity}: ${name} ${v} outside [-100,100]`);
    }
    if (typeof wrothMax === "number" && typeof coolMax === "number" && typeof pleasedMax === "number") {
      if (!(wrothMax < coolMax && coolMax < pleasedMax)) {
        fail(`mood ${deity}: band thresholds not strictly ascending (wroth=${wrothMax} cool=${coolMax} pleased=${pleasedMax})`);
      }
    }
    const ceiling = out[`mood.${deity}.stanceCeiling`];
    if (!ceiling || typeof ceiling !== "object") {
      fail(`mood ${deity}: stanceCeiling missing or not an object`);
    } else {
      const entries = Object.entries(ceiling);
      if (entries.length === 0) fail(`mood ${deity}: stanceCeiling empty`);
      for (const [stance, band] of entries) {
        if (!STANCES.has(stance)) fail(`mood ${deity}: bad stanceCeiling stance "${stance}"`);
        if (!BANDS.has(band)) fail(`mood ${deity}: bad stanceCeiling band "${band}" (stance ${stance})`);
      }
    }
  }
}

// Parallel-array + vocab integrity for demands; no-empty-deity guard.
function checkDemands(out) {
  if (!Array.isArray(out.demandKeys) || out.demandKeys.length === 0) {
    fail("demandKeys missing or empty");
    return;
  }
  for (const key of out.demandKeys) {
    for (const f of ["deity", "type", "rewardTag", "penaltyTag", "cap"]) {
      const v = out[`demand.${key}.${f}`];
      if (v === undefined || v === null || String(v).trim() === "") {
        fail(`demand ${key}: missing ${f}`);
      }
    }
    const deity = out[`demand.${key}.deity`];
    if (!deity || !String(deity).trim()) fail(`demand ${key}: empty deity (likely CSV column shift)`);
    const window = out[`demand.${key}.windowDays`];
    if (typeof window !== "number" || !Number.isFinite(window) || window <= 0) {
      fail(`demand ${key}: windowDays "${window}" not a positive number`);
    }
    // --- Signal binding (M3 Spike 3): every demand must bind to a concrete
    // signal layer; free-text act tags are forbidden.
    const layer = out[`demand.${key}.bindingLayer`];
    if (!BINDING_LAYERS.has(layer)) {
      fail(`demand ${key}: bad binding_layer "${layer}" (expected faucet | quest_matrix | faucet|quest_matrix)`);
    }
    const eventTypes = out[`demand.${key}.eventTypes`];
    const questTag = (out[`demand.${key}.questMatrixTag`] ?? "").toString().trim();
    if (!Array.isArray(eventTypes)) {
      fail(`demand ${key}: eventTypes missing or not an array`);
    } else {
      for (const n of eventTypes) {
        if (!Number.isInteger(n)) fail(`demand ${key}: eventTypes entry "${n}" is not an int`);
        else if (!isKnownEventType(n)) fail(`demand ${key}: eventType ${n} not in known vocabulary (1,2,40,300-369)`);
      }
    }
    const hasEvents = Array.isArray(eventTypes) && eventTypes.length > 0;
    const hasQuestTag = questTag !== "";
    if (!hasEvents && !hasQuestTag) {
      fail(`demand ${key}: no concrete binding (event_types and quest_matrix_tag both empty)`);
    }
    // Layer <-> binding consistency.
    if (typeof layer === "string") {
      if (layer.includes("faucet") && !hasEvents) fail(`demand ${key}: binding_layer includes faucet but event_types is empty`);
      if (layer.includes("quest_matrix") && !hasQuestTag) fail(`demand ${key}: binding_layer includes quest_matrix but quest_matrix_tag is empty`);
      if (!layer.includes("faucet") && hasEvents) fail(`demand ${key}: event_types set but binding_layer omits faucet`);
      if (!layer.includes("quest_matrix") && hasQuestTag) fail(`demand ${key}: quest_matrix_tag set but binding_layer omits quest_matrix`);
    }
    const wired = out[`demand.${key}.wiredToday`];
    if (!WIRED_TODAY.has(wired)) {
      fail(`demand ${key}: bad wired_today "${wired}" (expected yes|no|partial)`);
    }
    // Honesty cross-check: a demand whose faucet events are ALL in the unwired
    // 300+ block and which has no live quest tag cannot claim wired_today=yes.
    if (wired === "yes" && hasEvents && !eventTypes.some(isWiredEventType) && !hasQuestTag) {
      fail(`demand ${key}: wired_today=yes but all bound events are in the unwired 300+ block`);
    }
    if (hasEvents && eventTypes.some((n) => !isWiredEventType(n))) {
      info(`demand ${key}: binds 300+ block event(s) [${eventTypes.filter((n) => !isWiredEventType(n)).join(", ")}] - no SM receivers/router yet`);
    }
  }
}

// Parallel-array + vocab integrity for omens; no-empty-deity guard.
function checkOmens(out) {
  if (!Array.isArray(out.omenKeys) || out.omenKeys.length === 0) {
    fail("omenKeys missing or empty");
    return;
  }
  for (const key of out.omenKeys) {
    const deity = out[`omen.${key}.deity`];
    const transition = out[`omen.${key}.transition`];
    const tone = out[`omen.${key}.tone`];
    const toastKey = out[`omen.${key}.toastKey`];
    const dreamKey = out[`omen.${key}.dreamTextKey`];
    if (!deity || !String(deity).trim()) fail(`omen ${key}: empty deity (likely CSV column shift)`);
    if (!TRANSITIONS.has(transition)) fail(`omen ${key}: bad transition "${transition}"`);
    if (!TONES.has(tone)) fail(`omen ${key}: bad tone "${tone}"`);
    // An omen must carry at least one payload: a toast key or a dream text key.
    const hasToast = toastKey !== undefined && String(toastKey).trim() !== "";
    const hasDream = dreamKey !== undefined && String(dreamKey).trim() !== "";
    if (!hasToast && !hasDream) fail(`omen ${key}: no toastKey or dreamTextKey (empty payload)`);
  }
}

// No-empty-deity at the cross-table level: every pilot deity must have a mood
// row, at least one demand, and at least one omen (no orphan/empty deity).
function checkDeityCoverage(out) {
  const moodDeities = new Set(out.deities);
  const demandDeities = new Set((out.demandKeys || []).map((k) => out[`demand.${k}.deity`]));
  const omenDeities = new Set((out.omenKeys || []).map((k) => out[`omen.${k}.deity`]));

  for (const d of PILOT_DEITIES) {
    if (!moodDeities.has(d)) fail(`coverage: pilot deity ${d} has no mood row`);
    if (!demandDeities.has(d)) fail(`coverage: pilot deity ${d} has no demand`);
    if (!omenDeities.has(d)) fail(`coverage: pilot deity ${d} has no omen`);
  }
  // Flag any demand/omen deity with no mood row (orphan).
  for (const d of demandDeities) {
    if (!moodDeities.has(d)) fail(`coverage: demand references deity "${d}" with no mood row`);
  }
  for (const d of omenDeities) {
    if (!moodDeities.has(d)) fail(`coverage: omen references deity "${d}" with no mood row`);
  }
  // Advisory: a mood deity with no demand/omen authored yet.
  for (const d of moodDeities) {
    if (!demandDeities.has(d)) info(`mood deity ${d} has no demand authored`);
    if (!omenDeities.has(d)) info(`mood deity ${d} has no omen authored`);
  }
}

function main() {
  let out;
  try {
    out = loadCompiled();
  } catch (e) {
    console.error("FATAL: could not compile living-deities --stdout:", e.message);
    process.exit(1);
  }

  checkTopLevel(out);
  checkMood(out);
  checkDemands(out);
  checkOmens(out);
  checkDeityCoverage(out);

  console.log(`PDV living-deities self-test`);
  console.log(`  deities:      ${(out.deities || []).length}`);
  console.log(`  demand keys:  ${(out.demandKeys || []).length}`);
  console.log(`  omen keys:    ${(out.omenKeys || []).length}`);
  for (const m of infos) console.log(`  INFO: ${m}`);

  if (failures.length) {
    console.error(`\nFAIL (${failures.length}):`);
    for (const m of failures) console.error(`  - ${m}`);
    process.exit(1);
  }
  console.log(`\nPASS: runtime JSON well-formed.`);
}

main();
