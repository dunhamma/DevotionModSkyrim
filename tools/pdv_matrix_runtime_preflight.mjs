#!/usr/bin/env node
/*
 * Read-only preflight for PDV quest-matrix runtime failures.
 *
 * This catches the failure class where the matrix compiler passes but
 * PapyrusUtil sees zero watched quests because the runtime path or active MO2
 * file set is wrong.
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const args = process.argv.slice(2);
const MO2_ROOT = normalizePath(getArg("--mo2") ?? "D:/Wabbajack/modlists/ARR");
const PROFILE_NAME = getArg("--profile") ?? readSelectedProfile(MO2_ROOT);
const PROFILE_DIR = PROFILE_NAME ? path.join(MO2_ROOT, "profiles", PROFILE_NAME) : null;
const JSON_OUTPUT = args.includes("--json");
const CORE_ONLY = args.includes("--core-only");
const EXPECTED_CORE_WATCHED = Number.parseInt(getArg("--expected-core") ?? "134", 10);
const EXPECTED_ARR_WATCHED = Number.parseInt(getArg("--expected-arr") ?? "20", 10);
const EXPECTED_CHANNELS = Number.parseInt(getArg("--expected-channels") ?? "0", 10);
const CORE_MOD = getArg("--core-mod") ?? "Devotion";
const COMPAT_MOD = getArg("--compat-mod") ?? "Devotion - Authoria ARR Compatibility";
const COMPAT_PLUGIN = getArg("--compat-plugin") ?? "PDV_AuthoriaARR_Combined.esp";
const PAPYRUS_LOG = normalizePath(getArg("--log") ?? "C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log");

const findings = [];

// --name-resolution-only: pure-static gate (no MO2) -- every deity name in the quest-matrix
// CSVs must resolve through the manager's runtime name model (RepairDeityRuntimeName
// canonical names + CanonicalDaedricPathName + IsQuestReactionNameMatch aliases), else
// ApplyDeityReaction silently drops the cell (the Clavicus != "Clavicus Vile" class).
// Shelled by pdv_verify on every run; also folded into the full preflight below.
if (args.includes("--name-resolution-only")) {
  const result = checkMatrixNameResolution();
  console.log(JSON.stringify(result, null, 2));
  process.exitCode = result.status === "PASS" ? 0 : 1;
} else {
  main();
}

function checkMatrixNameResolution() {
  const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
  const managerPath = path.join(repoRoot, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
  const authoringDir = path.join(repoRoot, "references", "authoring");
  const issues = [];
  if (!exists(managerPath)) {
    return { check: "matrixNameResolution", status: "FAIL", issues: [`manager source missing: ${managerPath}`] };
  }
  const managerText = fs.readFileSync(managerPath, "utf8");

  // Accepted requested-names, all parsed from the manager source (never hand-copied).
  const accepted = new Set();
  for (const m of managerText.matchAll(/RepairDeityRuntimeName\(\s*PDV_[A-Za-z0-9_]+\s*,\s*"([^"]+)"\s*\)/g)) {
    accepted.add(m[1]);
  }
  const daedricFn = managerText.match(/String Function CanonicalDaedricPathName[\s\S]*?EndFunction/);
  for (const m of (daedricFn ? daedricFn[0] : "").matchAll(/return "([^"]+)"/g)) {
    accepted.add(m[1]);
  }
  const aliasFn = managerText.match(/Bool Function IsQuestReactionNameMatch[\s\S]*?EndFunction/);
  for (const m of (aliasFn ? aliasFn[0] : "").matchAll(/requestedName == "([^"]+)"/g)) {
    accepted.add(m[1]);
  }
  if (accepted.size < 30) {
    issues.push(`accepted-name extraction suspiciously small (${accepted.size}) -- manager name-model parse may have broken`);
  }

  // Minimal quoted-field CSV parser: enough for the matrix files (quotes around citation).
  const parseCsvLine = (line) => {
    const cells = [];
    let cur = "";
    let inQ = false;
    for (let i = 0; i < line.length; i += 1) {
      const ch = line[i];
      if (inQ) {
        if (ch === '"' && line[i + 1] === '"') { cur += '"'; i += 1; }
        else if (ch === '"') inQ = false;
        else cur += ch;
      } else if (ch === '"') inQ = true;
      else if (ch === ",") { cells.push(cur); cur = ""; }
      else cur += ch;
    }
    cells.push(cur);
    return cells;
  };

  const files = fs.readdirSync(authoringDir).filter((f) => /^PDV_QuestReactionMatrix.*\.csv$/i.test(f));
  const auxiliarySchemas = new Map([
    ["PDV_QuestReactionMatrix_OutcomeTagNormalization.csv", ["editor_id", "outcome_stage", "act_tags", "reason"]],
  ]);
  const unknown = [];
  let cellsChecked = 0;
  let auxiliaryFilesChecked = 0;
  for (const file of files) {
    const lines = fs.readFileSync(path.join(authoringDir, file), "utf8").split(/\r?\n/).filter((l) => l.trim() !== "");
    const header = parseCsvLine(lines[0] || "").map((h) => h.trim().toLowerCase());
    const auxiliarySchema = auxiliarySchemas.get(file);
    if (auxiliarySchema) {
      if (header.length !== auxiliarySchema.length || header.some((name, index) => name !== auxiliarySchema[index])) {
        issues.push(`${file}: expected auxiliary header '${auxiliarySchema.join(",")}', got '${header.join(",")}'`);
      } else {
        auxiliaryFilesChecked += 1;
      }
      continue;
    }
    const deityCol = header.indexOf("deity");
    if (deityCol < 0) {
      issues.push(`${file}: no 'deity' column found -- header drift`);
      continue;
    }
    for (const line of lines.slice(1)) {
      const name = (parseCsvLine(line)[deityCol] || "").trim();
      if (name === "") continue;
      cellsChecked += 1;
      if (!accepted.has(name)) unknown.push(`${file}: "${name}"`);
    }
  }

  if (process.env.PDV_MATRIX_NAME_SELFTEST === "1") {
    unknown.push("(selftest): \"Clavicus\"");
  }

  const distinctUnknown = [...new Set(unknown)];
  const ok = distinctUnknown.length === 0 && issues.length === 0;
  return {
    check: "matrixNameResolution",
    status: ok ? "PASS" : "FAIL",
    acceptedNames: accepted.size,
    files: files.length,
    auxiliaryFilesChecked,
    cellsChecked,
    unknownNames: distinctUnknown,
    issues,
  };
}

function main() {
  checkMo2Profile();
  const enabledMods = checkModlist();
  checkPluginOrder();
  checkKnownMatrixFiles(enabledMods);
  checkChannelFiles(enabledMods);
  checkSourceConstants(enabledMods);
  checkPexFiles(enabledMods);
  checkPapyrusLog();
  const nameRes = checkMatrixNameResolution();
  if (nameRes.status === "PASS") {
    pass("Matrix deity-name resolution", `${nameRes.cellsChecked} cells across ${nameRes.files} CSVs resolve against ${nameRes.acceptedNames} canonical names.`);
  } else {
    fail("Matrix deity-name resolution", `${nameRes.unknownNames.length} unresolvable deity name(s): ${nameRes.unknownNames.slice(0, 10).join("; ")}${nameRes.issues.length ? ` | issues: ${nameRes.issues.join("; ")}` : ""}`);
  }

  const counts = findings.reduce((acc, finding) => {
    acc[finding.status] = (acc[finding.status] ?? 0) + 1;
    return acc;
  }, {});

  if (JSON_OUTPUT) {
    console.log(JSON.stringify({
      status: counts.FAIL ? "FAIL" : "PASS",
      mo2Root: MO2_ROOT,
      profile: PROFILE_NAME,
      counts,
      findings,
    }, null, 2));
  } else {
    for (const finding of findings) {
      const file = finding.file ? ` (${finding.file})` : "";
      console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${file}`);
    }
    console.log(`Summary: PASS=${counts.PASS ?? 0} WARN=${counts.WARN ?? 0} INFO=${counts.INFO ?? 0} FAIL=${counts.FAIL ?? 0}`);
  }

  process.exitCode = counts.FAIL ? 1 : 0;
}

function checkMo2Profile() {
  if (!exists(MO2_ROOT)) {
    fail("MO2 root", `${MO2_ROOT} does not exist.`, MO2_ROOT);
    return;
  }
  pass("MO2 root", `${MO2_ROOT} exists.`, MO2_ROOT);
  if (!PROFILE_NAME) {
    fail("MO2 profile", "Could not determine selected profile from ModOrganizer.ini.", path.join(MO2_ROOT, "ModOrganizer.ini"));
    return;
  }
  if (!PROFILE_DIR || !exists(PROFILE_DIR)) {
    fail("MO2 profile", `Profile ${PROFILE_NAME} does not exist.`, PROFILE_DIR);
    return;
  }
  pass("MO2 profile", `Active profile is ${PROFILE_NAME}.`, PROFILE_DIR);
}

function checkModlist() {
  const modlistPath = PROFILE_DIR ? path.join(PROFILE_DIR, "modlist.txt") : "";
  const enabled = new Set();
  if (!exists(modlistPath)) {
    fail("MO2 modlist", "modlist.txt is missing.", modlistPath);
    return enabled;
  }
  const lines = readLines(modlistPath);
  for (const line of lines) {
    if (line.startsWith("+")) enabled.add(line.slice(1));
  }

  requireEnabledMod(enabled, CORE_MOD);
  if (!CORE_ONLY) requireEnabledMod(enabled, COMPAT_MOD);
  requireDisabledMod(lines, "PDV_AuthoriaARR_Compatibility");
  requireDisabledMod(lines, "PDV_Authoria_FirstLook");
  requireDisabledMod(lines, "Devotion - PlayerDevotion Local Test");
  return enabled;
}

function checkPluginOrder() {
  const pluginsPath = PROFILE_DIR ? path.join(PROFILE_DIR, "plugins.txt") : "";
  if (!exists(pluginsPath)) {
    fail("MO2 plugins", "plugins.txt is missing.", pluginsPath);
    return;
  }
  const activePlugins = readLines(pluginsPath)
    .filter((line) => line && !line.startsWith("#"))
    .map((line) => line.startsWith("*") ? line.slice(1) : line);

  const devotion = activePlugins.indexOf("Devotion.esp");
  const compat = activePlugins.indexOf(COMPAT_PLUGIN);
  const req = activePlugins.indexOf("Requiem for the Indifferent.esp");

  if (devotion === -1) fail("Plugin active", "Devotion.esp is not active.", pluginsPath);
  else pass("Plugin active", "Devotion.esp is active.", pluginsPath);
  if (CORE_ONLY) return;
  if (compat === -1) fail("Plugin active", `${COMPAT_PLUGIN} is not active.`, pluginsPath);
  else pass("Plugin active", `${COMPAT_PLUGIN} is active.`, pluginsPath);

  if (devotion !== -1 && compat !== -1) {
    if (devotion < compat) pass("Plugin order", `Devotion.esp loads before ${COMPAT_PLUGIN}.`, pluginsPath);
    else fail("Plugin order", `${COMPAT_PLUGIN} must load after Devotion.esp.`, pluginsPath);
  }
  if (compat !== -1 && req !== -1) {
    if (compat < req) pass("Plugin order", `${COMPAT_PLUGIN} loads before Requiem for the Indifferent.esp.`, pluginsPath);
    else fail("Plugin order", `${COMPAT_PLUGIN} must load before Requiem for the Indifferent.esp.`, pluginsPath);
  }
}

function checkKnownMatrixFiles(enabledMods) {
  const relativeFiles = [
    path.join("SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "PDV_QuestReactionMatrix.json"),
  ];
  if (!CORE_ONLY) {
    relativeFiles.push(path.join("SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "PDV_QuestReactionMatrix_ARR.json"));
  }

  for (const relativeFile of relativeFiles) {
    const winner = resolveWinningModFile(relativeFile, enabledMods);
    if (!winner) {
      fail("Matrix JSON winner", `${relativeFile} has no active MO2 provider.`, path.join(MO2_ROOT, "mods"));
      continue;
    }
    checkMatrixJson(winner, true);
  }
}

function checkChannelFiles(enabledMods) {
  if (CORE_ONLY || EXPECTED_CHANNELS <= 0) return;
  const relativeDir = path.join("SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "Channels");
  const compatDir = path.join(MO2_ROOT, "mods", COMPAT_MOD, relativeDir);
  if (!exists(compatDir)) {
    fail("Quest reaction channels", `Channels directory is missing from ${COMPAT_MOD}.`, compatDir);
    return;
  }
  const files = fs.readdirSync(compatDir).filter((name) => /^PDV_QRM_.*\.json$/i.test(name)).sort();
  const invalid = [];
  const losing = [];
  for (const name of files) {
    const packaged = path.join(compatDir, name);
    try { readJson(packaged); } catch (error) { invalid.push(`${name}: ${error.message}`); }
    const winner = resolveWinningModFile(path.join(relativeDir, name), enabledMods);
    if (!winner || path.resolve(winner) !== path.resolve(packaged)) losing.push(name);
  }
  if (files.length !== EXPECTED_CHANNELS) {
    fail("Quest reaction channels", `${files.length} packaged channel(s); expected ${EXPECTED_CHANNELS}.`, compatDir);
  } else if (invalid.length > 0) {
    fail("Quest reaction channels", `${invalid.length} invalid JSON channel(s): ${invalid.join("; ")}`, compatDir);
  } else if (losing.length > 0) {
    fail("Quest reaction channels", `${losing.length} channel(s) lose MO2 precedence: ${losing.join(", ")}`, compatDir);
  } else {
    pass("Quest reaction channels", `${files.length} valid channel(s) are present and win MO2 precedence.`, compatDir);
  }
}

function checkMatrixJson(filePath, active) {
  let json;
  try {
    json = readJson(filePath);
  } catch (error) {
    fail("Matrix JSON parse", error.message, filePath);
    return;
  }
  const name = path.basename(filePath);
  const expected = name === "PDV_QuestReactionMatrix_ARR.json" ? EXPECTED_ARR_WATCHED : EXPECTED_CORE_WATCHED;
  const count = matrixWatchCount(json);
  const shape = json.string && json.float && json.int && json.stringList ? "typed" : "flat-or-invalid";
  const hash = sha256(filePath).slice(0, 12);
  const detail = `${name} ${shape}, watched=${count}, sha256=${hash}`;

  if (!active && count > 0) {
    info("Inactive matrix JSON", detail, filePath);
    return;
  }
  if (shape !== "typed") {
    fail("Matrix JSON shape", `${detail}; expected PapyrusUtil typed buckets.`, filePath);
    return;
  }
  if (count !== expected) {
    fail("Matrix JSON watched count", `${detail}; expected ${expected}.`, filePath);
    return;
  }
  pass("Matrix JSON watched count", detail, filePath);
}

function checkSourceConstants(enabledMods) {
  for (const script of ["PDV__ManagerQuest.psc", "PDV_PlayerEvents.psc"]) {
    checkQuestMatrixSourcePath(resolveWinningModFile(path.join("Scripts", "Source", script), enabledMods), "Active source path");
  }
  checkShrinePrayerRouteSource(resolveWinningModFile(path.join("Scripts", "Source", "PDV_EventSignalActivator.psc"), enabledMods), "Active shrine route source");
  checkShrinePrayerRouteSource(resolveWinningModFile(path.join("Scripts", "Source", "PDV_EventBus.psc"), enabledMods), "Active shrine route source");
  checkShrinePrayerRouteSource(resolveWinningModFile(path.join("Scripts", "Source", "PDV__ManagerQuest.psc"), enabledMods), "Active shrine route source");
  checkBookOfDaysSource(resolveWinningModFile(path.join("Scripts", "Source", "PDV__ManagerQuest.psc"), enabledMods), "Active Book of Days source");
  checkBookOfDaysMcmSource(resolveWinningModFile(path.join("Scripts", "Source", "PDV_MCM.psc"), enabledMods), "Active Book of Days MCM source");

  const repoSourceDir = path.join(process.cwd(), "live-source", "Scripts", "Source");
  for (const script of ["PDV__ManagerQuest.psc", "PDV_PlayerEvents.psc"]) {
    if (exists(path.join(repoSourceDir, script))) {
      checkQuestMatrixSourcePath(path.join(repoSourceDir, script), "Repo mirror source path", "WARN");
    }
  }
  for (const script of ["PDV_EventSignalActivator.psc", "PDV_EventBus.psc", "PDV__ManagerQuest.psc"]) {
    if (exists(path.join(repoSourceDir, script))) {
      checkShrinePrayerRouteSource(path.join(repoSourceDir, script), "Repo mirror shrine route source", "WARN");
    }
  }
  if (exists(path.join(repoSourceDir, "PDV__ManagerQuest.psc"))) {
    checkBookOfDaysSource(path.join(repoSourceDir, "PDV__ManagerQuest.psc"), "Repo mirror Book of Days source", "WARN");
  }
  if (exists(path.join(repoSourceDir, "PDV_MCM.psc"))) {
    checkBookOfDaysMcmSource(path.join(repoSourceDir, "PDV_MCM.psc"), "Repo mirror Book of Days MCM source", "WARN");
  }

  if (!enabledMods.has(CORE_MOD)) {
    fail("Source constants", `Cannot trust source constants because ${CORE_MOD} is disabled.`, path.join(MO2_ROOT, "mods", CORE_MOD, "Scripts", "Source"));
  }
}

function checkQuestMatrixSourcePath(filePath, checkName, staleStatus = "FAIL") {
  if (!exists(filePath)) {
    warn(checkName, "Source file is missing; PEX may still be valid but source cannot be audited.", filePath);
    return;
  }
  const text = fs.readFileSync(filePath, "utf8");
  const unsafe = [
    "\"PlayerDevotion/PDV_QuestReactionMatrix\"",
    "\"PlayerDevotion/PDV_QuestReactionMatrix_ARR\"",
  ].filter((needle) => text.includes(needle));
  const expected = [
    "\"../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix\"",
    "\"../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR\"",
  ].filter((needle) => text.includes(needle));

  if (unsafe.length > 0) {
    add(staleStatus, checkName, `Unsafe short PapyrusUtil matrix path present: ${unsafe.join(", ")}.`, filePath);
  } else if (expected.length > 0) {
    pass(checkName, `Native-safe StorageUtilData path present (${expected.length} constants).`, filePath);
  } else {
    warn(checkName, "No quest matrix path constants found.", filePath);
  }
}

function checkShrinePrayerRouteSource(filePath, checkName, staleStatus = "FAIL") {
  if (!exists(filePath)) {
    warn(checkName, "Source file is missing; PEX may still be valid but source cannot be audited.", filePath);
    return;
  }

  const script = path.basename(filePath).toLowerCase();
  const text = fs.readFileSync(filePath, "utf8");
  const required =
    script === "pdv_eventsignalactivator.psc"
      ? ["ROUTE_DAEDRIC_SHRINE_PRAYER", "RouteDaedricShrinePrayer"]
      : script === "pdv_eventbus.psc"
        ? ["Function RouteDaedricShrinePrayer", "HandleDaedricShrinePrayer"]
        : script === "pdv__managerquest.psc"
          ? ["Function HandleDaedricShrinePrayer", "Daedric shrine prayer: +2"]
          : [];

  if (required.length === 0) return;

  const missing = required.filter((needle) => !text.includes(needle));
  if (missing.length > 0) {
    add(staleStatus, checkName, `${path.basename(filePath)} missing shrine-prayer route support: ${missing.join(", ")}.`, filePath);
    return;
  }

  pass(checkName, `${path.basename(filePath)} has shrine-prayer route support.`, filePath);
}

function checkBookOfDaysSource(filePath, checkName, staleStatus = "FAIL") {
  if (!exists(filePath)) {
    warn(checkName, "Source file is missing; PEX may still be valid but source cannot be audited.", filePath);
    return;
  }

  const text = fs.readFileSync(filePath, "utf8");
  const required = [
    "PDV.Diegetic.Journal.Magnitudes",
    "PDV.Diegetic.Journal.Titles",
    "\\\"magnitude\\\"",
    "\\\"instrument\\\"",
    "RefreshOpenBookOfDays",
    "GetJournalMagnitudeForTone",
    'AppendBookOfDaysEntry("You offered prayer at the shrine of "',
  ];
  const missing = required.filter((needle) => !text.includes(needle));
  if (missing.length > 0) {
    add(staleStatus, checkName, `${path.basename(filePath)} missing Book of Days rolling-log support: ${missing.join(", ")}.`, filePath);
    return;
  }
  pass(checkName, `${path.basename(filePath)} has typed Book of Days rolling-log support.`, filePath);
}

function checkBookOfDaysMcmSource(filePath, checkName, staleStatus = "FAIL") {
  if (!exists(filePath)) {
    warn(checkName, "Source file is missing; PEX may still be valid but source cannot be audited.", filePath);
    return;
  }

  const text = fs.readFileSync(filePath, "utf8");
  const required = [
    "Function OpenBookOfDaysFromMcm()",
    "_oidOpenJournalNow = AddTextOption(\"Open Book of Days\", \"Open now\", OPTION_FLAG_NONE)",
    "_oidJournalHotkey = AddKeyMapOption(\"Book of Days key\", currentJournalKey, OPTION_FLAG_NONE)",
    "ResetBookOfDaysOptionIds()",
  ];
  const forbidden = [
    "PDV_Manager.SendPrismaJournalPayload(True, 1)",
    "You turn to the Ledger -- what feeds your gods.",
  ].filter((needle) => text.includes(needle));
  const missing = required.filter((needle) => !text.includes(needle));
  if (missing.length > 0 || forbidden.length > 0) {
    const detail = [
      missing.length ? `missing: ${missing.join(", ")}` : "",
      forbidden.length ? `stale ledger-cycle markers: ${forbidden.join(", ")}` : "",
    ].filter(Boolean).join("; ");
    add(staleStatus, checkName, `${path.basename(filePath)} Book of Days MCM contract failed (${detail}).`, filePath);
    return;
  }
  pass(checkName, `${path.basename(filePath)} opens Chronicle and does not cycle to Ledger.`, filePath);
}

function checkPexFiles(enabledMods) {
  for (const script of ["PDV__ManagerQuest.pex", "PDV_MCM.pex", "PDV_PlayerEvents.pex", "PDV_EventSignalActivator.pex", "PDV_EventBus.pex"]) {
    const filePath = resolveWinningModFile(path.join("Scripts", script), enabledMods);
    if (!exists(filePath)) {
      fail("PEX present", `${script} is missing.`, filePath);
      continue;
    }
    pass("PEX present", `${script} sha256=${sha256(filePath).slice(0, 16)}.`, filePath);
  }
}

function resolveWinningModFile(relativePath, enabledMods) {
  const overwrite = path.join(MO2_ROOT, "overwrite", relativePath);
  if (exists(overwrite)) return overwrite;
  const modlistPath = PROFILE_DIR ? path.join(PROFILE_DIR, "modlist.txt") : "";
  if (!exists(modlistPath)) return null;
  // MO2 serializes the highest-priority enabled mod first in this profile file.
  for (const line of readLines(modlistPath)) {
    if (!line.startsWith("+")) continue;
    const modName = line.slice(1);
    if (!enabledMods.has(modName)) continue;
    const candidate = path.join(MO2_ROOT, "mods", modName, relativePath);
    if (exists(candidate)) return candidate;
  }
  return null;
}

function checkPapyrusLog() {
  if (!exists(PAPYRUS_LOG)) {
    info("Papyrus log", "Papyrus.0.log not found; skip runtime marker readback.", PAPYRUS_LOG);
    return;
  }
  const lines = readLines(PAPYRUS_LOG);
  const diagLines = lines.filter((line) => line.includes("Quest matrix count matrix_diag_"));
  const reloadLines = lines.filter((line) => line.includes("Quest matrix reloaded"));
  if (diagLines.length === 0 && reloadLines.length === 0) {
    info("Papyrus log", "No quest matrix reload diagnostics found in current log.", PAPYRUS_LOG);
    return;
  }
  for (const line of diagLines.slice(-2)) {
    const listMatch = line.match(/list=(\d+)/);
    const count = listMatch ? Number.parseInt(listMatch[1], 10) : null;
    if (count === 0) {
      fail("Papyrus matrix diagnostic", line.trim(), PAPYRUS_LOG);
    } else if (count !== null) {
      pass("Papyrus matrix diagnostic", line.trim(), PAPYRUS_LOG);
    } else {
      info("Papyrus matrix diagnostic", line.trim(), PAPYRUS_LOG);
    }
  }
  for (const line of reloadLines.slice(-1)) {
    const lower = line.toLowerCase();
    if (lower.includes("core 0 watched") || lower.includes("core: 0 watched") || lower.includes("arr 0 watched") || lower.includes("arr channel: 0 watched")) {
      fail("Papyrus matrix reload UI", line.trim(), PAPYRUS_LOG);
    } else {
      pass("Papyrus matrix reload UI", line.trim(), PAPYRUS_LOG);
    }
  }
}

function requireEnabledMod(enabled, modName) {
  if (enabled.has(modName)) pass("MO2 mod enabled", `${modName} is enabled.`);
  else fail("MO2 mod enabled", `${modName} is not enabled.`);
}

function requireDisabledMod(lines, modName) {
  const line = lines.find((entry) => entry.slice(1) === modName);
  if (!line) {
    info("MO2 stale mod disabled", `${modName} is not present in modlist.`);
  } else if (line.startsWith("-")) {
    pass("MO2 stale mod disabled", `${modName} is disabled.`);
  } else {
    fail("MO2 stale mod disabled", `${modName} is enabled; disable stale snapshot.`);
  }
}

function matrixWatchCount(json) {
  if (Array.isArray(json?.stringList?.questWatchFormIds)) return json.stringList.questWatchFormIds.length;
  if (Array.isArray(json?.stringList?.questwatchformids)) return json.stringList.questwatchformids.length;
  if (typeof json?.string?.questWatchFormIdsCsv === "string") return json.string.questWatchFormIdsCsv.split(",").filter(Boolean).length;
  if (typeof json?.string?.questwatchformidscsv === "string") return json.string.questwatchformidscsv.split(",").filter(Boolean).length;
  if (Array.isArray(json?.questWatchFormIds)) return json.questWatchFormIds.length;
  if (Array.isArray(json?.questwatchformids)) return json.questwatchformids.length;
  if (typeof json?.questWatchFormIdsCsv === "string") return json.questWatchFormIdsCsv.split(",").filter(Boolean).length;
  if (typeof json?.questwatchformidscsv === "string") return json.questwatchformidscsv.split(",").filter(Boolean).length;
  return 0;
}

function getMo2ModName(filePath) {
  const marker = `${path.sep}mods${path.sep}`;
  const index = filePath.indexOf(marker);
  if (index === -1) return null;
  const rest = filePath.slice(index + marker.length);
  return rest.split(path.sep)[0] || null;
}

function readSelectedProfile(mo2Root) {
  const ini = path.join(mo2Root, "ModOrganizer.ini");
  if (!exists(ini)) return null;
  const match = fs.readFileSync(ini, "utf8").match(/^selected_profile=@ByteArray\((.+)\)$/m);
  return match?.[1] ?? null;
}

function getArg(name) {
  const index = args.indexOf(name);
  if (index === -1 || index === args.length - 1) return null;
  return args[index + 1];
}

function normalizePath(value) {
  return path.resolve(value.replaceAll("\\", "/"));
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function readLines(filePath) {
  return fs.readFileSync(filePath, "utf8").split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function add(status, check, detail, file = null) {
  findings.push({ status, check, detail, file });
}

function pass(check, detail, file = null) {
  add("PASS", check, detail, file);
}

function info(check, detail, file = null) {
  add("INFO", check, detail, file);
}

function warn(check, detail, file = null) {
  add("WARN", check, detail, file);
}

function fail(check, detail, file = null) {
  add("FAIL", check, detail, file);
}
