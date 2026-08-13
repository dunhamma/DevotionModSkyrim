#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { runQuestReactionScenario } from "./lib/pdv_quest_reaction_characterization.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const FIXTURE_ROOT = path.join(
  ROOT,
  "tools",
  "fixtures",
  "pdv-quest-reaction-characterization",
);
const CONTRACT_PATH = path.join(
  ROOT,
  "references",
  "authoring",
  "PDV_V3Slice1QuestReaction.manifest.json",
);
const KNOWN_FLAGS = new Set(["--case", "--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, {
  toolName: "pdv_quest_reaction_characterization",
  valueFlags: new Set(["--case"]),
});

function parseArgs(argv) {
  const options = { caseId: "", json: false };
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === "--case") {
      const value = argv[++index];
      if (!value || value.startsWith("--")) throw new Error("Missing value after --case");
      options.caseId = value;
    }
    else if (argv[index] === "--json") options.json = true;
  }
  return options;
}

function fixtureFiles(caseId) {
  if (caseId) return [path.join(FIXTURE_ROOT, `${caseId}.json`)];
  return fs
    .readdirSync(FIXTURE_ROOT)
    .filter((name) => name.endsWith(".json"))
    .sort()
    .map((name) => path.join(FIXTURE_ROOT, name));
}

function sameJson(actual, expected) {
  return JSON.stringify(actual) === JSON.stringify(expected);
}

function validateFixture(fixture, contract) {
  if (fixture.schema !== "pdv.quest-reaction.characterization.v1") {
    throw new Error(`${fixture.id ?? "unnamed fixture"}: unknown schema`);
  }
  const requiredCases = contract.currentBehaviorCharacterization.cases;
  if (!requiredCases.includes(fixture.id)) {
    throw new Error(`${fixture.id}: not declared by the V3 characterization contract`);
  }
  const parity = contract.parityInvariants;
  const mismatches = [
    ["maxPending", parity.queueMaxPending],
    ["workItemsPerTick", parity.workItemsPerTick],
    ["duplicateWindowDays", parity.duplicateWindowDays],
  ].filter(([name, expected]) => fixture.config?.[name] !== expected);
  if (mismatches.length) {
    throw new Error(
      `${fixture.id}: config differs from the V3 contract: ${mismatches
        .map(([name, expected]) => `${name} must be ${expected}`)
        .join(", ")}`,
    );
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
  const files = fixtureFiles(options.caseId);
  const fixtures = files.map((fixturePath) =>
    JSON.parse(fs.readFileSync(fixturePath, "utf8")),
  );
  if (!options.caseId) {
    const ids = fixtures.map((fixture) => fixture.id).sort();
    const required = [...contract.currentBehaviorCharacterization.cases].sort();
    if (!sameJson(ids, required)) {
      throw new Error(
        `Fixture inventory must exactly match the V3 contract; expected ${required.join(", ")}; found ${ids.join(", ")}`,
      );
    }
  }
  const cases = fixtures.map((fixture) => {
    validateFixture(fixture, contract);
    const actual = runQuestReactionScenario(fixture);
    return {
      id: fixture.id,
      status: sameJson(actual, fixture.expected) ? "PASS" : "FAIL",
      expected: fixture.expected,
      actual,
    };
  });
  const report = {
    status: cases.every((entry) => entry.status === "PASS") ? "PASS" : "FAIL",
    proofBoundary:
      "deterministic interface characterization only; Papyrus scheduling, StorageUtil serialization, VMAD, save/load, and player surfaces require Skyrim proof",
    cases,
  };
  if (options.json) console.log(JSON.stringify(report, null, 2));
  else {
    for (const entry of cases) console.log(`[${entry.status}] ${entry.id}`);
    console.log(`Summary: ${report.status}`);
    console.log(`Proof boundary: ${report.proofBoundary}`);
  }
  return report.status === "PASS" ? 0 : 1;
}

try {
  process.exitCode = main();
} catch (error) {
  console.error(`PDV quest-reaction characterization failed: ${error.message}`);
  process.exitCode = 2;
}
