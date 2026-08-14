#!/usr/bin/env node
// Generated v2 catalogs must have one canonical owner for each qualified quest
// stage. Public extensions may intentionally shadow canonical keys; the Runtime's
// fixed core -> official -> lexical-extension precedence handles those overrides.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--core", "--official", "--extensions-root", "--json"]);
assertKnownFlags(process.argv.slice(2).filter((arg) => arg.startsWith("--")), KNOWN_FLAGS, {
  toolName: "pdv_quest_stage_ownership_check",
});

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const argv = process.argv.slice(2);
const valueOf = (name, fallback) => {
  const index = argv.indexOf(name);
  return index >= 0 ? argv[index + 1] : fallback;
};
const catalogRoot = path.join(repo, "SKSE", "Plugins", "StorageUtilData", "PlayerDevotion");
const corePath = path.resolve(valueOf("--core", path.join(catalogRoot, "PDV_QuestReactionCore.v2.json")));
const officialPath = path.resolve(valueOf("--official", path.join(catalogRoot, "PDV_QuestReactionPatches.v2.json")));
const extensionsRoot = path.resolve(valueOf("--extensions-root", path.join(catalogRoot, "QuestReactionExtensions")));

function readCatalog(file) {
  const json = JSON.parse(fs.readFileSync(file, "utf8"));
  if (json.string?.schema !== "pdv.quest-reaction.catalog.v2" || Number(json.int?.schemaVersion) !== 2) {
    throw new Error(`${file}: expected pdv.quest-reaction.catalog.v2 schema version 2`);
  }
  const keys = json.stringList?.questKeys;
  if (!Array.isArray(keys)) throw new Error(`${file}: stringList.questKeys is required`);
  const seen = new Set();
  for (const rawKey of keys) {
    const key = String(rawKey).trim();
    if (!/^[^|]+\|\d+\|-?\d+$/.test(key)) throw new Error(`${file}: invalid qualified quest key '${key}'`);
    const folded = key.toLowerCase();
    if (seen.has(folded)) throw new Error(`${file}: duplicate quest key '${key}'`);
    seen.add(folded);
  }
  return seen;
}

function extensionFiles(directory) {
  if (!fs.existsSync(directory)) return [];
  return fs.readdirSync(directory, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".json"))
    .map((entry) => path.join(directory, entry.name))
    .sort((left, right) => path.basename(left).localeCompare(path.basename(right), "en", { sensitivity: "base" }));
}

for (const file of [corePath, officialPath]) {
  if (!fs.existsSync(file)) throw new Error(`Catalog missing: ${file}`);
}
const core = readCatalog(corePath);
const official = readCatalog(officialPath);
const canonicalCollisions = [...official].filter((key) => core.has(key)).sort();

const claimed = new Set([...core, ...official]);
let extensionStages = 0;
let extensionOverrides = 0;
const extensions = extensionFiles(extensionsRoot);
for (const file of extensions) {
  const keys = readCatalog(file);
  extensionStages += keys.size;
  for (const key of keys) {
    if (claimed.has(key)) extensionOverrides += 1;
    claimed.add(key);
  }
}

const result = {
  check: "questStageOwnershipV2",
  status: canonicalCollisions.length ? "FAIL" : "PASS",
  coreStages: core.size,
  officialStages: official.size,
  extensions: extensions.length,
  extensionStages,
  extensionOverrides,
  canonicalCollisions,
};
if (argv.includes("--json")) console.log(JSON.stringify(result, null, 2));
else console.log(`${result.status} coreStages=${result.coreStages} officialStages=${result.officialStages} extensions=${result.extensions} canonicalCollisions=${canonicalCollisions.length}`);
process.exitCode = canonicalCollisions.length ? 1 : 0;
