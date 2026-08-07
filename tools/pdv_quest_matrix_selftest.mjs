#!/usr/bin/env node
/*
 * Self-test / regression net for the PDV quest-reaction matrix compile output.
 *
 * Compiles the frozen CSVs in-memory (pdv_quest_matrix_compile.mjs --stdout) and
 * asserts the runtime JSON is well-formed BEFORE the Papyrus wiring consumes it,
 * so a malformed cell (bad vocab, column-shift, orphan key, parallel-array drift)
 * is caught here instead of in-game. Run: node tools/pdv_quest_matrix_selftest.mjs
 *
 * Exit 0 = PASS, exit 1 = FAIL. INFO lines are advisory (e.g. matrix quests the
 * recall pilot does not flag) and never fail the run -- the pilot stays the
 * separate recall proxy per the wiring handoff.
 */

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const COMPILE = path.join(__dirname, "pdv_quest_matrix_compile.mjs");

const VALENCES = new Set(["+", "-"]);
const INTENSITIES = new Set(["C", "S", "m"]);
const MAGNITUDES = new Set(["milestone", "small"]);
const REQUIRED_VALUE_KEYS = [
  "value.milestone.C", "value.milestone.S", "value.milestone.m",
  "value.small.C", "value.small.S", "value.small.m",
];

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

function checkParallelArrays(out) {
  for (const key of out.questKeys) {
    const fields = ["deities", "valences", "intensities", "magnitudes", "tags"];
    const arrays = fields.map((f) => out[`quest.${key}.${f}`]);
    if (arrays.some((a) => !Array.isArray(a))) {
      fail(`quest ${key}: missing one of ${fields.join("/")}`);
      continue;
    }
    const len = arrays[0].length;
    if (len === 0) fail(`quest ${key}: zero cells`);
    if (!arrays.every((a) => a.length === len)) {
      fail(`quest ${key}: parallel-array length drift (${fields.map((f, i) => `${f}=${arrays[i].length}`).join(", ")})`);
    }
    const [deities, valences, intensities, magnitudes] = arrays;
    deities.forEach((d, i) => {
      if (!d || !d.trim()) fail(`quest ${key} cell ${i}: empty deity (likely CSV column shift)`);
      if (!VALENCES.has(valences[i])) fail(`quest ${key} cell ${i}: bad valence "${valences[i]}" (deity ${d})`);
      if (!INTENSITIES.has(intensities[i])) fail(`quest ${key} cell ${i}: bad intensity "${intensities[i]}" (deity ${d})`);
      if (!MAGNITUDES.has(magnitudes[i])) fail(`quest ${key} cell ${i}: bad magnitude "${magnitudes[i]}" (deity ${d})`);
    });
    // No deity should react twice to the SAME quest|stage outcome (authoring dup).
    const seen = new Set();
    deities.forEach((d, i) => {
      if (seen.has(d)) fail(`quest ${key}: deity "${d}" appears twice on the same stage (duplicate cell)`);
      seen.add(d);
    });
  }
}

function checkFaucets(out) {
  if (!Array.isArray(out.faucetKeys) || out.faucetKeys.length === 0) {
    fail("faucetKeys missing or empty");
    return;
  }
  for (const key of out.faucetKeys) {
    for (const f of ["deity", "valence", "intensity", "magnitude", "tag", "cap"]) {
      const v = out[`faucet.${key}.${f}`];
      if (v === undefined || v === null || String(v).trim() === "") {
        fail(`faucet ${key}: missing ${f}`);
      }
    }
    if (!VALENCES.has(out[`faucet.${key}.valence`])) fail(`faucet ${key}: bad valence`);
    if (!INTENSITIES.has(out[`faucet.${key}.intensity`])) fail(`faucet ${key}: bad intensity`);
    if (!MAGNITUDES.has(out[`faucet.${key}.magnitude`])) fail(`faucet ${key}: bad magnitude`);
  }
}

function checkTopLevel(out) {
  if (out.schema !== "pdv-quest-reaction-matrix.v1") fail(`unexpected schema "${out.schema}"`);
  for (const f of ["questKeys", "questForms", "questFormIds", "questEditorIds"]) {
    if (!Array.isArray(out[f])) fail(`top-level ${f} is not an array`);
  }
  const n = out.questKeys.length;
  if (n === 0) fail("questKeys empty");
  if (new Set(out.questKeys).size !== n) fail("duplicate quest keys");
  for (const f of ["questForms", "questFormIds", "questEditorIds"]) {
    if (out[f].length !== n) fail(`${f} length ${out[f].length} != questKeys ${n}`);
  }
  for (const k of REQUIRED_VALUE_KEYS) {
    if (typeof out[k] !== "number") fail(`value table key ${k} missing or non-numeric`);
  }
  const stanceKeys = Object.keys(out).filter((k) => k.startsWith("stanceMult."));
  if (stanceKeys.length === 0) fail("no stanceMult.* keys (stance table absent)");
}

function checkReactionStanceCoverage(out) {
  const races = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];
  const stanceKeys = Object.keys(out).filter((key) => key.startsWith("stance."));
  for (const key of stanceKeys) {
    if (key.includes("/")) fail(`runtime stance key retains a display alias (${key})`);
  }

  // These path-only Prince lookups cannot rely on PDV_DeityBase's fallback
  // stance. Missing canonical keys therefore silently become FOREIGN at run
  // time even though their authored rows are TABOO.
  for (const deity of ["Namira", "Sanguine"]) {
    for (const race of races) {
      const key = `stance.${race}.${deity}`;
      if (typeof out[key] !== "string" || out[key] === "") {
        fail(`reaction deity "${deity}" has no runtime stance for ${race} (${key})`);
      }
    }
  }
}

function main() {
  let out;
  try {
    out = loadCompiled();
  } catch (e) {
    console.error("FATAL: could not compile matrix --stdout:", e.message);
    process.exit(1);
  }

  checkTopLevel(out);
  checkParallelArrays(out);
  checkFaucets(out);
  checkReactionStanceCoverage(out);

  const cellCount = out.questKeys.reduce((sum, k) => sum + (out[`quest.${k}.deities`]?.length ?? 0), 0);
  const deitySet = new Set();
  for (const k of out.questKeys) for (const d of out[`quest.${k}.deities`] ?? []) deitySet.add(d);

  console.log(`PDV quest-matrix self-test`);
  console.log(`  quest keys:   ${out.questKeys.length}`);
  console.log(`  quest cells:  ${cellCount}`);
  console.log(`  deities:      ${deitySet.size}`);
  console.log(`  faucet acts:  ${out.faucetKeys.length}`);
  for (const m of infos) console.log(`  INFO: ${m}`);

  if (failures.length) {
    console.error(`\nFAIL (${failures.length}):`);
    for (const m of failures) console.error(`  - ${m}`);
    process.exit(1);
  }
  console.log(`\nPASS: runtime JSON well-formed.`);
}

main();
