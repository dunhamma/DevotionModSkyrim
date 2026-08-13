#!/usr/bin/env node
// One logical quest stage has one owner. A dependency-expanded stage belongs in its
// dependency-gated PatchHub channel, never in the always-loaded core matrix as well.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--channels-root", "--core", "--json"]);
assertKnownFlags(process.argv.slice(2).filter((arg) => arg.startsWith("--")), KNOWN_FLAGS, {
  toolName: "pdv_quest_stage_ownership_check",
});

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const argv = process.argv.slice(2);
const valueOf = (name, fallback) => {
  const index = argv.indexOf(name);
  return index >= 0 ? argv[index + 1] : fallback;
};
const corePath = path.resolve(valueOf("--core", path.join(repo, "SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "PDV_QuestReactionMatrix.json")));
const channelsRoot = path.resolve(valueOf("--channels-root", path.join(repo, "dist", "PDV_QuestModPatches_FOMOD", "common")));

function walk(directory) {
  if (!fs.existsSync(directory)) return [];
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...walk(target));
    else if (/PDV_QRM_.+\.json$/i.test(entry.name) && target.split(path.sep).includes("Channels")) files.push(target);
  }
  return files.sort((left, right) => left.localeCompare(right));
}

function readStages(file) {
  const json = JSON.parse(fs.readFileSync(file, "utf8"));
  const lists = json.stringList ?? {};
  const keys = lists.questKeys ?? lists.questkeys ?? [];
  const plugins = lists.questPlugins ?? lists.questplugins ?? [];
  const editors = lists.questEditorIds ?? lists.questeditorids ?? [];
  if (!Array.isArray(keys) || !Array.isArray(plugins) || keys.length !== plugins.length) {
    throw new Error(`${file}: questKeys and questPlugins must be aligned arrays`);
  }
  const unique = new Map();
  for (let index = 0; index < keys.length; index += 1) {
    const questKey = String(keys[index]).trim();
    const plugin = String(plugins[index]).trim();
    if (!questKey || !plugin) throw new Error(`${file}: incomplete quest stage metadata at index ${index}`);
    const stageKey = `${plugin.toLowerCase()}|${questKey}`;
    if (!unique.has(stageKey)) unique.set(stageKey, {
      stageKey,
      formKeyStage: `${plugin}:${questKey}`,
      editorId: String(editors[index] ?? ""),
    });
  }
  return [...unique.values()];
}

if (!fs.existsSync(corePath)) throw new Error(`Core matrix missing: ${corePath}`);
const coreStages = new Map(readStages(corePath).map((stage) => [stage.stageKey, stage]));
const channelFiles = walk(channelsRoot);
const collisions = [];
for (const file of channelFiles) {
  for (const stage of readStages(file)) {
    const core = coreStages.get(stage.stageKey);
    if (core) collisions.push({
      formKeyStage: stage.formKeyStage,
      editorId: stage.editorId || core.editorId,
      core: path.relative(repo, corePath),
      channel: path.relative(repo, file),
    });
  }
}

const result = {
  check: "questStageOwnership",
  status: collisions.length ? "FAIL" : "PASS",
  coreStages: coreStages.size,
  channels: channelFiles.length,
  collisions,
};
if (argv.includes("--json")) console.log(JSON.stringify(result, null, 2));
else {
  console.log(`${result.status} coreStages=${result.coreStages} channels=${result.channels} collisions=${collisions.length}`);
  for (const collision of collisions) console.error(`  ${collision.formKeyStage} ${collision.editorId}: core <-> ${collision.channel}`);
}
process.exitCode = collisions.length ? 1 : 0;
