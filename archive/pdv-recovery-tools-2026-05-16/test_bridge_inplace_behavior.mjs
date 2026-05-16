#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const PROJECT_ROOT = process.cwd();
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const DEVOTION_PROFILE = path.join(ANVIL_ROOT, "profiles", "Devotion Dev");
const STOCK_GAME = path.join(ANVIL_ROOT, "Stock Game");
const STOCK_GAME_DATA = path.join(STOCK_GAME, "Data");

function exists(filePath) {
  return fs.existsSync(filePath);
}

function toPosix(filePath) {
  return String(filePath).replace(/\\/g, "/");
}

function readPluginList(filePath, starredOnly) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"))
    .filter((line) => !starredOnly || line.startsWith("*"))
    .map((line) => starredOnly ? line.slice(1).trim() : line)
    .map((line) => line.toLowerCase());
}

function readEnabledModList(filePath) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("+"))
    .map((line) => line.slice(1).trim())
    .filter((name) => name && !name.endsWith("_separator"));
}

function listPluginFiles(dirPath) {
  if (!exists(dirPath) || !fs.statSync(dirPath).isDirectory()) {
    return [];
  }
  return fs.readdirSync(dirPath, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .filter((entry) => [".esp", ".esm", ".esl"].includes(path.extname(entry.name).toLowerCase()))
    .map((entry) => ({ name: entry.name, fullPath: path.join(dirPath, entry.name) }));
}

function buildPluginPathMap(modNames) {
  const map = new Map();
  for (const entry of listPluginFiles(STOCK_GAME_DATA)) {
    map.set(entry.name.toLowerCase(), entry.fullPath);
  }
  for (const modName of modNames) {
    const modRoot = path.join(ANVIL_ROOT, "mods", modName);
    for (const entry of listPluginFiles(modRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
    const dataRoot = path.join(modRoot, "Data");
    for (const entry of listPluginFiles(dataRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
  }
  return map;
}

function buildLoadOrderContext() {
  const loadOrderNames = readPluginList(path.join(DEVOTION_PROFILE, "loadorder.txt"), false);
  const enabledNames = new Set(readPluginList(path.join(DEVOTION_PROFILE, "plugins.txt"), true));
  const modNames = readEnabledModList(path.join(DEVOTION_PROFILE, "modlist.txt"));
  const pluginPathMap = buildPluginPathMap(modNames);

  const listings = [];
  for (const pluginName of loadOrderNames) {
    const pluginPath = pluginPathMap.get(pluginName.toLowerCase());
    if (!pluginPath || !exists(pluginPath)) {
      continue;
    }
    listings.push({
      mod_key: pluginName,
      path: toPosix(pluginPath),
      enabled: enabledNames.has(pluginName.toLowerCase()) || pluginName.endsWith(".esm"),
    });
  }

  const ctx = { game_release: "SkyrimSE", listings };
  if (exists(STOCK_GAME_DATA)) {
    ctx.data_folder = toPosix(STOCK_GAME_DATA);
  }
  const cccPath = path.join(STOCK_GAME, "Skyrim.ccc");
  if (exists(cccPath)) {
    ctx.ccc_path = toPosix(cccPath);
  }
  return ctx;
}

function bridgeWrite(request) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: 120000,
    maxBuffer: 10 * 1024 * 1024,
    windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`No output: ${result.stderr || ""}`);
  return JSON.parse(stdout);
}

function main() {
  const scratch = path.resolve(PROJECT_ROOT, "scratch_framework_test.esp");
  const request = {
    output_path: toPosix(scratch),
    esl_flag: false,
    author: "Codex test",
    records: [
      {
        op: "override",
        formid: "PlayerDevotion_Framework.esp:00C325",
        source_plugin: "PlayerDevotion_Framework.esp",
        attach_scripts: [
          {
            name: "PDV__ManagerQuest",
            properties: [
              { name: "PDV_GLO_DebugLevel", type: "Object", value: "PlayerDevotion_Framework.esp:01DBD9" },
            ],
          },
        ],
      },
    ],
    load_order: buildLoadOrderContext(),
  };

  const before = fs.statSync(scratch).size;
  const response = bridgeWrite(request);
  const after = fs.statSync(scratch).size;
  console.log(JSON.stringify({ before, after, response }, null, 2));
}

main();
