#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

function arg(name, fallback) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const corePath = path.resolve(arg("--core", "SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix.json"));
const channelsRoot = path.resolve(arg("--channels-root", "dist/PDV_QuestModPatches_FOMOD/common"));

function walk(directory) {
  if (!fs.existsSync(directory)) return [];
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...walk(target));
    else if (/PDV_QRM_.+\.json$/i.test(entry.name) && target.split(path.sep).some((part) => part === "Channels")) files.push(target);
  }
  return files.sort((left, right) => left.localeCompare(right));
}

function readMatrix(file) {
  const json = JSON.parse(fs.readFileSync(file, "utf8"));
  const lists = json.stringList ?? {};
  const strings = json.string ?? {};
  const keys = lists.questKeys ?? lists.questkeys ?? [];
  const plugins = lists.questPlugins ?? lists.questplugins ?? [];
  if (!Array.isArray(keys) || !Array.isArray(plugins) || keys.length !== plugins.length) {
    throw new Error(`${file}: questKeys and questPlugins must be aligned arrays`);
  }
  const cells = [];
  for (let index = 0; index < keys.length; index += 1) {
    const questKey = String(keys[index]);
    const plugin = String(plugins[index]).trim().toLowerCase();
    const deityCsv = strings[`quest.${questKey}.deitiesCsv`] ?? strings[`quest.${questKey}.deitiescsv`];
    if (!plugin || typeof deityCsv !== "string") throw new Error(`${file}: incomplete quest cell metadata for ${questKey}`);
    for (const deity of deityCsv.split("|").map((value) => value.trim()).filter(Boolean)) {
      cells.push({ naturalKey: `${plugin}|${questKey}|${deity.toLowerCase()}`, file });
    }
  }
  return { keys: keys.length, cells };
}

const files = [corePath, ...walk(channelsRoot)];
if (!fs.existsSync(corePath)) throw new Error(`Core matrix missing: ${corePath}`);
const seen = new Map();
const duplicates = [];
let cellCount = 0;
let questKeyCount = 0;
for (const file of files) {
  const matrix = readMatrix(file);
  questKeyCount += matrix.keys;
  cellCount += matrix.cells.length;
  for (const cell of matrix.cells) {
    const prior = seen.get(cell.naturalKey);
    if (prior) duplicates.push({ naturalKey: cell.naturalKey, first: prior, second: cell.file });
    else seen.set(cell.naturalKey, cell.file);
  }
}

if (duplicates.length) {
  console.error(JSON.stringify({ status: "FAIL", duplicates }, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({
  status: "PASS",
  matrices: files.length,
  channels: files.length - 1,
  questKeys: questKeyCount,
  cells: cellCount,
  duplicateNaturalKeys: 0,
}, null, 2));
