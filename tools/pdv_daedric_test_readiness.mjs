#!/usr/bin/env node
/*
 * Read-only preflight for Daedric in-game smoke readiness.
 *
 * This checks that the live test surfaces exist and are fresh enough to launch
 * Skyrim testing. It does not write ESP, PEX, SEQ, or Papyrus log data.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEVOTION_MOD = "D:/Wabbajack/modlists/Anvil/mods/Devotion";
const PROFILE_DIR = "D:/Wabbajack/modlists/Anvil/profiles/Devotion Dev";
const PAPYRUS_LOG = "C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log";

const CONTRACT_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const PACKET_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricInGameSmokePacket.md");
const EVIDENCE_LEDGER_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricRuntimeEvidenceLedger.json");
const RUNTIME_CHECKER = path.join(PROJECT_ROOT, "tools", "pdv_daedric_runtime_check.mjs");
const PACKET_GENERATOR = path.join(PROJECT_ROOT, "tools", "pdv_daedric_ingame_packet.mjs");
const BETA_GATE = path.join(PROJECT_ROOT, "tools", "pdv_daedric_beta_gate.mjs");
const AUTHOR_PROJECT = path.join(PROJECT_ROOT, "tools", "pdv-daedric-author", "PdvDaedricAuthor.csproj");

const liveFiles = [
  {
    label: "PDV_PlayerEvents",
    source: path.join(DEVOTION_MOD, "Scripts", "Source", "PDV_PlayerEvents.psc"),
    compiled: path.join(DEVOTION_MOD, "Scripts", "PDV_PlayerEvents.pex"),
  },
  {
    label: "PDV_MCM",
    source: path.join(DEVOTION_MOD, "Scripts", "Source", "PDV_MCM.psc"),
    compiled: path.join(DEVOTION_MOD, "Scripts", "PDV_MCM.pex"),
  },
];

function usage() {
  return [
    "Usage: node .\\tools\\pdv_daedric_test_readiness.mjs [options]",
    "",
    "Options:",
    "  --deep     Also run daedric author readback and runtime checker self-test.",
    "  --json     Emit JSON.",
    "  --help     Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = {
    deep: false,
    json: false,
    help: false,
  };

  for (const arg of argv) {
    if (arg === "--deep") {
      options.deep = true;
    } else if (arg === "--json") {
      options.json = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function exists(pathName) {
  return fs.existsSync(pathName);
}

function statOrNull(pathName) {
  try {
    return fs.statSync(pathName);
  } catch {
    return null;
  }
}

function add(findings, status, check, detail, filePath = null) {
  findings.push({ status, check, detail, path: filePath });
}

function checkFile(findings, label, filePath) {
  const stat = statOrNull(filePath);
  if (!stat) {
    add(findings, "FAIL", label, "Missing.", filePath);
    return null;
  }
  add(findings, "PASS", label, `Found (${stat.size} bytes).`, filePath);
  return stat;
}

function loadContract(findings) {
  const stat = checkFile(findings, "Daedric contract", CONTRACT_PATH);
  if (!stat) {
    return null;
  }

  try {
    const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
    const count = Array.isArray(contract.princes) ? contract.princes.length : 0;
    if (count === 16) {
      add(findings, "PASS", "Daedric contract prince count", "Contract contains 16 princes.", CONTRACT_PATH);
    } else {
      add(findings, "FAIL", "Daedric contract prince count", `Expected 16 princes, found ${count}.`, CONTRACT_PATH);
    }
    return contract;
  } catch (error) {
    add(findings, "FAIL", "Daedric contract parse", error instanceof Error ? error.message : String(error), CONTRACT_PATH);
    return null;
  }
}

function checkPacket(findings, contract) {
  const packetStat = checkFile(findings, "Daedric in-game packet", PACKET_PATH);
  const contractStat = statOrNull(CONTRACT_PATH);
  if (!packetStat || !contractStat) {
    return;
  }

  if (packetStat.mtimeMs >= contractStat.mtimeMs) {
    add(findings, "PASS", "Daedric packet freshness", "Packet is newer than or equal to the contract.", PACKET_PATH);
  } else {
    add(findings, "WARN", "Daedric packet freshness", "Packet is older than the contract; regenerate with pdv_daedric_ingame_packet.mjs --write.", PACKET_PATH);
  }

  const packetText = fs.readFileSync(PACKET_PATH, "utf8");
  const requiredSnippets = [
    "--source mcm",
    "--source qasmoke",
    "--source organic",
    "setstage DA16 190",
    "player.placeatme",
    "PDV DAEDRIC GENERIC SILENCE",
    "## Evidence Intake",
    "pdv_daedric_evidence_intake.mjs --summary",
    "--from-runtime-check --source mcm",
    "--from-runtime-check --source qasmoke",
    "--from-runtime-check --source organic",
    "--slot activeEffects",
    "--slot curseNoDoubleFire",
    "pdv_daedric_beta_gate.mjs",
  ];
  for (const snippet of requiredSnippets) {
    if (packetText.includes(snippet)) {
      add(findings, "PASS", "Daedric packet content", `Contains ${snippet}.`, PACKET_PATH);
    } else {
      add(findings, "FAIL", "Daedric packet content", `Missing ${snippet}.`, PACKET_PATH);
    }
  }

  const princes = Array.isArray(contract?.princes) ? contract.princes : [];
  for (const prince of princes) {
    const stem = String(prince.stem || "");
    const displayName = String(prince.displayName || stem);
    const qasmokeRef = `PDV_REFR_Daedric_${stem}_LiveSender_QASmoke`;
    const qasmokeChecker = `--prince ${stem} --strict-manager --source qasmoke`;
    if (packetText.includes(displayName) && packetText.includes(qasmokeRef) && packetText.includes(qasmokeChecker)) {
      add(findings, "PASS", "Daedric packet Prince row", `${displayName} has QASmoke row/checker.`, PACKET_PATH);
    } else {
      add(findings, "FAIL", "Daedric packet Prince row", `${displayName} is missing QASmoke row/checker content.`, PACKET_PATH);
    }
  }
}

function checkEvidenceLedger(findings, contract) {
  const stat = checkFile(findings, "Daedric runtime evidence ledger", EVIDENCE_LEDGER_PATH);
  if (!stat) {
    return;
  }

  let ledger;
  try {
    ledger = JSON.parse(fs.readFileSync(EVIDENCE_LEDGER_PATH, "utf8"));
  } catch (error) {
    add(findings, "FAIL", "Daedric runtime evidence ledger parse", error instanceof Error ? error.message : String(error), EVIDENCE_LEDGER_PATH);
    return;
  }

  if (ledger.schema === "pdv.daedric-runtime-evidence-ledger.v1") {
    add(findings, "PASS", "Daedric runtime evidence ledger schema", `Schema ${ledger.schema}.`, EVIDENCE_LEDGER_PATH);
  } else {
    add(findings, "FAIL", "Daedric runtime evidence ledger schema", `Unexpected schema ${ledger.schema}.`, EVIDENCE_LEDGER_PATH);
  }

  const ledgerRows = Array.isArray(ledger.princes) ? ledger.princes : [];
  if (ledgerRows.length === 16) {
    add(findings, "PASS", "Daedric runtime evidence ledger prince count", "Ledger contains 16 Prince rows.", EVIDENCE_LEDGER_PATH);
  } else {
    add(findings, "FAIL", "Daedric runtime evidence ledger prince count", `Expected 16 Prince rows, found ${ledgerRows.length}.`, EVIDENCE_LEDGER_PATH);
  }

  const requiredSlots = [
    "mcmRoute",
    "qasmokeRoute",
    "organicRoute",
    "genericSilence",
    "activeEffects",
    "summaryMessage",
    "prismaNotification",
    "saveLoad",
    "stackLegibility",
    "curseNoDoubleFire",
    "manualFeel",
  ];
  const princes = Array.isArray(contract?.princes) ? contract.princes : [];
  for (const prince of princes) {
    const stem = String(prince.stem || "");
    const row = ledgerRows.find((item) => String(item.stem || "").toLowerCase() === stem.toLowerCase());
    if (!row) {
      add(findings, "FAIL", "Daedric runtime evidence ledger row", `Missing ${stem}.`, EVIDENCE_LEDGER_PATH);
      continue;
    }
    const missingSlots = requiredSlots.filter((slot) => !row.slots || !row.slots[slot]);
    if (missingSlots.length === 0) {
      add(findings, "PASS", "Daedric runtime evidence ledger row", `${stem} has all evidence slots.`, EVIDENCE_LEDGER_PATH);
    } else {
      add(findings, "FAIL", "Daedric runtime evidence ledger row", `${stem} missing slots: ${missingSlots.join(", ")}.`, EVIDENCE_LEDGER_PATH);
    }
  }
}

function checkLiveScripts(findings) {
  for (const item of liveFiles) {
    const source = checkFile(findings, `${item.label} source`, item.source);
    const compiled = checkFile(findings, `${item.label} compiled PEX`, item.compiled);
    if (!source || !compiled) {
      continue;
    }
    if (compiled.mtimeMs >= source.mtimeMs) {
      add(findings, "PASS", `${item.label} PEX freshness`, "Compiled PEX is newer than or equal to source.", item.compiled);
    } else {
      add(findings, "FAIL", `${item.label} PEX freshness`, "Compiled PEX is older than source; recompile before testing.", item.compiled);
    }
  }
}

function checkProfile(findings) {
  const pluginsPath = path.join(PROFILE_DIR, "plugins.txt");
  const loadorderPath = path.join(PROFILE_DIR, "loadorder.txt");
  checkFile(findings, "Devotion Dev plugins.txt", pluginsPath);
  checkFile(findings, "Devotion Dev loadorder.txt", loadorderPath);

  if (exists(pluginsPath)) {
    const plugins = fs.readFileSync(pluginsPath, "utf8");
    if (plugins.split(/\r?\n/).some((line) => line.trim() === "*PlayerDevotion_Framework.esp")) {
      add(findings, "PASS", "PlayerDevotion plugin active", "PlayerDevotion_Framework.esp is active in Devotion Dev.", pluginsPath);
    } else {
      add(findings, "FAIL", "PlayerDevotion plugin active", "PlayerDevotion_Framework.esp is not active in Devotion Dev.", pluginsPath);
    }
  }
}

function checkRuntimeFiles(findings) {
  checkFile(findings, "PlayerDevotion framework ESP", path.join(DEVOTION_MOD, "PlayerDevotion_Framework.esp"));
  checkFile(findings, "PlayerDevotion SEQ", path.join(DEVOTION_MOD, "Seq", "PlayerDevotion_Framework.seq"));
  checkFile(findings, "Daedric runtime checker", RUNTIME_CHECKER);
  checkFile(findings, "Daedric packet generator", PACKET_GENERATOR);
  checkFile(findings, "Daedric beta-display gate", BETA_GATE);

  const logStat = statOrNull(PAPYRUS_LOG);
  if (logStat) {
    add(findings, "PASS", "Papyrus log path", `Papyrus.0.log exists (${logStat.size} bytes).`, PAPYRUS_LOG);
  } else {
    add(findings, "WARN", "Papyrus log path", "Papyrus.0.log does not exist yet; it should appear after Skyrim logging starts.", PAPYRUS_LOG);
  }
}

function checkProcesses(findings) {
  const result = spawnSync("powershell", [
    "-NoProfile",
    "-Command",
    "Get-Process SkyrimSE,CreationKit,ckpe_loader -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProcessName",
  ], {
    encoding: "utf8",
    timeout: 10000,
  });
  if (result.status !== 0) {
    const processOutput = `${result.stdout || ""}${result.stderr || ""}`.trim();
    if (!processOutput) {
      add(findings, "PASS", "Process preflight", "SkyrimSE, CreationKit, and ckpe_loader are not running.", null);
      return;
    }
    add(findings, "WARN", "Process preflight", `Could not inspect Skyrim/CK processes: ${processOutput}`, null);
    return;
  }

  const running = result.stdout.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  if (running.length === 0) {
    add(findings, "PASS", "Process preflight", "SkyrimSE, CreationKit, and ckpe_loader are not running.", null);
  } else {
    add(findings, "WARN", "Process preflight", `Already running: ${running.join(", ")}. This is fine for testing, but avoid ESP writes.`, null);
  }
}

function runCommand(findings, check, command, args) {
  const result = spawnSync(command, args, {
    cwd: PROJECT_ROOT,
    encoding: "utf8",
    timeout: 120000,
  });
  const output = `${result.stdout || ""}${result.stderr || ""}`.trim();
  if (result.status === 0) {
    add(findings, "PASS", check, firstLine(output) || "Command passed.", null);
  } else {
    add(findings, "FAIL", check, firstLine(output) || `Command exited ${result.status}.`, null);
  }
}

function firstLine(text) {
  return text.split(/\r?\n/).map((line) => line.trim()).find(Boolean) || "";
}

function runDeepChecks(findings) {
  runCommand(findings, "Daedric author readback", "dotnet", [
    "run",
    "--project",
    AUTHOR_PROJECT,
    "--",
    "--check",
  ]);
  runCommand(findings, "Daedric runtime checker self-test", "node", [
    RUNTIME_CHECKER,
    "--self-test",
    "--strict-manager",
    "--source",
    "organic",
    "--json",
  ]);
}

function summarize(findings) {
  const counts = {};
  for (const finding of findings) {
    counts[finding.status] = (counts[finding.status] || 0) + 1;
  }
  return {
    status: findings.some((finding) => finding.status === "FAIL") ? "FAIL" : "PASS",
    counts,
  };
}

function printText(report) {
  console.log("PDV Daedric in-game test readiness");
  console.log(`Status: ${report.status}`);
  console.log(`Summary: ${Object.entries(report.counts).map(([key, value]) => `${key}=${value}`).join(", ")}`);
  console.log("");
  for (const finding of report.findings) {
    const suffix = finding.path ? ` [${finding.path}]` : "";
    console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${suffix}`);
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  const findings = [];
  const contract = loadContract(findings);
  checkPacket(findings, contract);
  checkLiveScripts(findings);
  checkProfile(findings);
  checkRuntimeFiles(findings);
  checkEvidenceLedger(findings, contract);
  checkProcesses(findings);
  if (options.deep) {
    runDeepChecks(findings);
  }

  const summary = summarize(findings);
  const report = {
    ...summary,
    deep: options.deep,
    projectRoot: PROJECT_ROOT,
    generatedAtLocal: new Date().toLocaleString("en-AU", { timeZone: "Australia/Sydney" }),
    findings,
  };

  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printText(report);
  }
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
