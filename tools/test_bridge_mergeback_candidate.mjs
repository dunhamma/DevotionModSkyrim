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
const PDV_ESP = path.join(ANVIL_ROOT, "mods", "Devotion", "PlayerDevotion_Framework.esp");

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
    .map((line) => (starredOnly ? line.slice(1).trim() : line))
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

function bridge(request, timeout = 120000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout,
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`No output: ${(result.stderr || "").trim()}`);
  return JSON.parse(stdout);
}

function main() {
  const outputPath = path.join(PROJECT_ROOT, "scratch_framework_mergeback_candidate.esp");
  if (exists(outputPath)) {
    fs.unlinkSync(outputPath);
  }

  fs.copyFileSync(PDV_ESP, outputPath);
  const loadOrder = buildLoadOrderContext();

  const writeRequest = {
    output_path: toPosix(outputPath),
    esl_flag: false,
    author: "Codex mergeback test",
    records: [
      {
        op: "override",
        formid: "PlayerDevotion_Framework.esp:00C325",
        source_plugin: "PlayerDevotion_Framework.esp",
        source_path: toPosix(PDV_ESP),
        attach_scripts: [
          {
            name: "PDV__ManagerQuest",
            properties: [
              {
                name: "PDV_GLO_PatronDeity",
                type: "Object",
                value: "PlayerDevotion_Framework.esp:02C5C7",
              },
            ],
          },
        ],
      },
      {
        op: "override",
        formid: "PlayerDevotion_Framework.esp:03AFBE",
        source_plugin: "PlayerDevotion_Framework.esp",
        source_path: toPosix(PDV_ESP),
        attach_scripts: [
          {
            name: "PDV_MCM",
            properties: [
              { name: "PDV_Manager", type: "Object", value: "PlayerDevotion_Framework.esp:00C325" },
              { name: "PDV_FLST_AllDeities", type: "Object", value: "PlayerDevotion_Framework.esp:017E47" },
              { name: "PDV_GLO_ActivePiety", type: "Object", value: "PlayerDevotion_Framework.esp:00945A" },
              { name: "PDV_GLO_ActiveTier", type: "Object", value: "PlayerDevotion_Framework.esp:00945B" },
              { name: "PDV_GLO_ActiveDeityIndex", type: "Object", value: "PlayerDevotion_Framework.esp:00945C" },
              { name: "PDV_GLO_PatronDeity", type: "Object", value: "PlayerDevotion_Framework.esp:02C5C7" },
              { name: "PDV_GLO_DebugLevel", type: "Object", value: "PlayerDevotion_Framework.esp:01DBD9" },
            ],
          },
        ],
      },
    ],
    load_order: loadOrder,
  };

  const writeResponse = bridge(writeRequest);

  const scanResponse = bridge({
    command: "scan",
    plugins: [toPosix(outputPath)],
  }, 60000);

  const detailResponse = bridge({
    command: "read_records",
    records: [
      { plugin_path: toPosix(outputPath), formid: "PlayerDevotion_Framework.esp:00C325" },
      { plugin_path: toPosix(outputPath), formid: "PlayerDevotion_Framework.esp:03AFBE" },
    ],
  }, 60000);

  console.log(JSON.stringify({
    outputPath,
    writeResponse,
    scanResponse,
    detailResponse,
  }, null, 2));
}

main();
