#!/usr/bin/env node
/*
 * Structured manual/runtime evidence intake for Daedric in-game proof.
 *
 * This writes only references/authoring/PDV_DaedricRuntimeEvidenceLedger.json.
 * It does not write ESP, PEX, SEQ, or Papyrus log data.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--command", "--from-runtime-check", "--help", "--include-generic", "--init", "--json", "--log", "--no-generic", "--note", "--prince", "--record", "--slot", "--source", "--status", "--strict-manager", "--summary"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_daedric_evidence_intake" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const CONTRACT_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const LEDGER_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricRuntimeEvidenceLedger.json");
const RUNTIME_CHECKER = path.join(PROJECT_ROOT, "tools", "pdv_daedric_runtime_check.mjs");

const SCHEMA = "pdv.daedric-runtime-evidence-ledger.v1";

const slotDefinitions = [
  ["mcmRoute", "MCM route marker proof"],
  ["qasmokeRoute", "Physical QASmoke route marker proof"],
  ["organicRoute", "Exact vanilla quest-stage organic route proof"],
  ["genericSilence", "Generic source silence proof"],
  ["activeEffects", "Seeker/Devoted/Champion/lapse Active Effects proof"],
  ["summaryMessage", "Show Prince summary MessageBox proof"],
  ["prismaNotification", "Prisma or notification display proof"],
  ["saveLoad", "Save/load sanity proof"],
  ["stackLegibility", "Race/Daedric stack snapshot legibility"],
  ["curseNoDoubleFire", "Curse-access no-double-fire proof"],
  ["manualFeel", "Manual feel note"],
];

const slotKeys = new Set(slotDefinitions.map(([key]) => key));
const statusValues = new Set(["pending", "pass", "conditional", "fail", "blocked", "not_required"]);

function usage() {
  return [
    "Usage: node .\\tools\\pdv_daedric_evidence_intake.mjs [options]",
    "",
    "Options:",
    "  --init                         Create/update the structured ledger shell.",
    "  --summary                      Print ledger status summary.",
    "  --record                       Record one evidence slot.",
    "  --from-runtime-check           Run the Daedric runtime checker and record route evidence if it passes.",
    "  --prince <stem|display|all>     Prince for --record.",
    "  --slot <slot>                   Evidence slot to update.",
    "  --status <pass|conditional|fail|blocked|pending|not_required>",
    "  --note <text>                   Short evidence note.",
    "  --command <text>                Command used for the evidence, if any.",
    "  --log <path>                    Papyrus log or screenshot path, if any.",
    "  --source <mcm|qasmoke|organic>  Runtime-check source for --from-runtime-check.",
    "  --include-generic              Record genericSilence when runtime checker includes it.",
    "  --no-generic                   Do not require/record genericSilence for --from-runtime-check.",
    "  --json                         Emit JSON.",
    "  --help                         Show this help.",
    "",
    `Slots: ${[...slotKeys].join(", ")}`,
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = {
    init: false,
    summary: false,
    record: false,
    fromRuntimeCheck: false,
    prince: "",
    slot: "",
    status: "",
    note: "",
    command: "",
    log: "",
    source: "",
    includeGeneric: null,
    json: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--init") {
      options.init = true;
    } else if (arg === "--summary") {
      options.summary = true;
    } else if (arg === "--record") {
      options.record = true;
    } else if (arg === "--from-runtime-check") {
      options.fromRuntimeCheck = true;
    } else if (arg === "--prince") {
      options.prince = requireValue(argv, ++index, "--prince");
    } else if (arg === "--slot") {
      options.slot = requireValue(argv, ++index, "--slot");
    } else if (arg === "--status") {
      options.status = requireValue(argv, ++index, "--status").toLowerCase();
    } else if (arg === "--note") {
      options.note = requireValue(argv, ++index, "--note");
    } else if (arg === "--command") {
      options.command = requireValue(argv, ++index, "--command");
    } else if (arg === "--log") {
      options.log = requireValue(argv, ++index, "--log");
    } else if (arg === "--source") {
      options.source = requireValue(argv, ++index, "--source").toLowerCase();
    } else if (arg === "--include-generic") {
      options.includeGeneric = true;
    } else if (arg === "--no-generic") {
      options.includeGeneric = false;
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

function requireValue(argv, index, optionName) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${optionName} requires a value.`);
  }
  return value;
}

function loadPrinces() {
  const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
  if (!Array.isArray(contract.princes) || contract.princes.length !== 16) {
    throw new Error(`Expected 16 princes in ${CONTRACT_PATH}.`);
  }
  return contract.princes.map((prince, index) => ({
    index,
    stem: String(prince.stem),
    displayName: String(prince.displayName || prince.stem),
    batch: String(prince.batch || ""),
    curseAccess: ["Molag", "Hircine"].includes(String(prince.stem)),
  }));
}

function defaultSlot() {
  return {
    status: "pending",
    updatedAtLocal: "",
    note: "",
    command: "",
    log: "",
  };
}

function defaultPrinceRow(prince) {
  const slots = {};
  for (const [key] of slotDefinitions) {
    slots[key] = defaultSlot();
  }
  if (!prince.curseAccess) {
    slots.curseNoDoubleFire.status = "not_required";
    slots.curseNoDoubleFire.note = "Only required for Molag Bal and Hircine curse-access proof.";
  }
  return {
    stem: prince.stem,
    displayName: prince.displayName,
    batch: prince.batch,
    index: prince.index,
    curseAccess: prince.curseAccess,
    overall: "pending",
    slots,
  };
}

function createLedger(princes) {
  return {
    schema: SCHEMA,
    generatedAtLocal: nowLocal(),
    sourceContract: "references/authoring/PDV_DaedricPrinceRecordContracts.json",
    purpose: "Structured intake ledger for Daedric runtime/display proof after CAT-6 readback is green.",
    statusRules: {
      pass: "All required slots for a Prince are pass or not_required.",
      conditional: "At least one required slot is conditional and no required slot is fail, blocked, or pending.",
      fail: "At least one required slot is fail.",
      blocked: "At least one required slot is blocked and no required slot is fail.",
      pending: "At least one required slot is pending and no required slot is fail or blocked.",
    },
    slotDefinitions: Object.fromEntries(slotDefinitions),
    princes: princes.map(defaultPrinceRow),
    observations: [],
  };
}

function loadOrCreateLedger(princes) {
  if (!fs.existsSync(LEDGER_PATH)) {
    return createLedger(princes);
  }
  const ledger = JSON.parse(fs.readFileSync(LEDGER_PATH, "utf8"));
  if (ledger.schema !== SCHEMA) {
    throw new Error(`Unexpected ledger schema in ${LEDGER_PATH}: ${ledger.schema}`);
  }
  ensureLedgerRows(ledger, princes);
  return ledger;
}

function ensureLedgerRows(ledger, princes) {
  ledger.princes ??= [];
  ledger.observations ??= [];
  for (const prince of princes) {
    let row = ledger.princes.find((item) => item.stem.toLowerCase() === prince.stem.toLowerCase());
    if (!row) {
      row = defaultPrinceRow(prince);
      ledger.princes.push(row);
      continue;
    }
    row.displayName = prince.displayName;
    row.batch = prince.batch;
    row.index = prince.index;
    row.curseAccess = prince.curseAccess;
    row.slots ??= {};
    for (const [key] of slotDefinitions) {
      row.slots[key] ??= defaultSlot();
    }
    if (!prince.curseAccess && row.slots.curseNoDoubleFire.status === "pending") {
      row.slots.curseNoDoubleFire.status = "not_required";
      row.slots.curseNoDoubleFire.note = "Only required for Molag Bal and Hircine curse-access proof.";
    }
  }
  ledger.princes.sort((a, b) => a.index - b.index);
  refreshOverall(ledger);
}

function selectRows(ledger, princeKey, slot) {
  if (!princeKey) {
    throw new Error("--prince is required for --record.");
  }
  if (princeKey.toLowerCase() === "all") {
    return ledger.princes;
  }

  const normalized = princeKey.toLowerCase();
  const row = ledger.princes.find((item) =>
    item.stem.toLowerCase() === normalized ||
    item.displayName.toLowerCase() === normalized
  );
  if (!row) {
    throw new Error(`Unknown Prince "${princeKey}". Valid stems: ${ledger.princes.map((item) => item.stem).join(", ")}.`);
  }
  return [row];
}

function recordEvidence(ledger, options) {
  if (!slotKeys.has(options.slot)) {
    throw new Error(`Unknown --slot ${options.slot}. Valid slots: ${[...slotKeys].join(", ")}.`);
  }
  if (!statusValues.has(options.status)) {
    throw new Error("--status must be one of: pass, conditional, fail, blocked, pending, not_required.");
  }
  if (!options.note && options.status !== "pending") {
    throw new Error("--note is required unless --status pending.");
  }

  const rows = selectRows(ledger, options.prince, options.slot);
  const timestamp = nowLocal();
  for (const row of rows) {
    row.slots[options.slot] = {
      status: options.status,
      updatedAtLocal: timestamp,
      note: options.note,
      command: options.command,
      log: options.log,
    };
    ledger.observations.push({
      updatedAtLocal: timestamp,
      prince: row.stem,
      slot: options.slot,
      status: options.status,
      note: options.note,
      command: options.command,
      log: options.log,
    });
  }
  refreshOverall(ledger);
  return rows.length;
}

function recordRuntimeCheckEvidence(ledger, options) {
  const source = options.source || "";
  if (!["mcm", "qasmoke", "organic"].includes(source)) {
    throw new Error("--source must be one of mcm, qasmoke, organic for --from-runtime-check.");
  }
  const prince = options.prince || "all";
  const includeGeneric = options.includeGeneric ?? source !== "organic";
  const slot = source === "mcm" ? "mcmRoute" : source === "qasmoke" ? "qasmokeRoute" : "organicRoute";
  const args = [
    RUNTIME_CHECKER,
    "--prince",
    prince,
    "--strict-manager",
    "--source",
    source,
    "--json",
  ];
  if (options.log) {
    args.push("--log", options.log);
  }
  if (includeGeneric) {
    args.push("--include-generic");
  } else {
    args.push("--no-generic");
  }

  const result = spawnSync("node", args, {
    cwd: PROJECT_ROOT,
    encoding: "utf8",
    timeout: 120000,
  });
  const output = `${result.stdout || ""}${result.stderr || ""}`.trim();
  let report;
  try {
    report = JSON.parse(result.stdout || "{}");
  } catch {
    throw new Error(`Runtime checker did not emit JSON: ${firstLine(output) || "empty output"}`);
  }
  if (result.status !== 0 || report.status !== "PASS") {
    throw new Error(`Runtime checker did not pass: ${runtimeFailureSummary(report) || firstLine(output) || report.status || `exit ${result.status}`}`);
  }

  const command = `node .\\tools\\pdv_daedric_runtime_check.mjs --prince ${prince} --strict-manager --source ${source}${options.log ? ` --log ${options.log}` : ""} ${includeGeneric ? "--include-generic" : "--no-generic"}`;
  const logPath = options.log || report.logPath || "";
  const timestamp = nowLocal();
  const changedRows = new Set();

  for (const group of report.princes || []) {
    if (group.status !== "PASS") {
      continue;
    }
    const row = ledger.princes.find((item) => String(item.stem).toLowerCase() === String(group.stem).toLowerCase());
    if (!row) {
      throw new Error(`Runtime checker returned unknown Prince ${group.stem}.`);
    }
    row.slots[slot] = {
      status: "pass",
      updatedAtLocal: timestamp,
      note: `${source} route checker passed for ${group.displayName || group.stem}.`,
      command,
      log: logPath,
    };
    ledger.observations.push({
      updatedAtLocal: timestamp,
      prince: row.stem,
      slot,
      status: "pass",
      note: `${source} route checker passed for ${group.displayName || group.stem}.`,
      command,
      log: logPath,
    });
    changedRows.add(row.stem);
  }

  if (includeGeneric && report.generic?.status === "PASS") {
    const targetRows = selectRows(ledger, prince, "genericSilence");
    for (const row of targetRows) {
      row.slots.genericSilence = {
        status: "pass",
        updatedAtLocal: timestamp,
        note: `${source} generic silence checker passed.`,
        command,
        log: logPath,
      };
      ledger.observations.push({
        updatedAtLocal: timestamp,
        prince: row.stem,
        slot: "genericSilence",
        status: "pass",
        note: `${source} generic silence checker passed.`,
        command,
        log: logPath,
      });
      changedRows.add(`${row.stem}:genericSilence`);
    }
  }

  refreshOverall(ledger);
  return changedRows.size;
}

function firstLine(text) {
  return text.split(/\r?\n/).map((line) => line.trim()).find(Boolean) || "";
}

function runtimeFailureSummary(report) {
  const failed = [];
  for (const group of report.princes || []) {
    if (group.status !== "PASS") {
      failed.push(group.displayName || group.stem || group.id || "unknown");
    }
  }
  if (report.generic && report.generic.status !== "PASS") {
    failed.push("generic silence");
  }
  if (failed.length) {
    return `missing runtime proof for ${failed.join(", ")}`;
  }
  return "";
}

function refreshOverall(ledger) {
  for (const row of ledger.princes) {
    const statuses = Object.values(row.slots)
      .map((slot) => slot.status)
      .filter((status) => status !== "not_required");
    if (statuses.some((status) => status === "fail")) {
      row.overall = "fail";
    } else if (statuses.some((status) => status === "blocked")) {
      row.overall = "blocked";
    } else if (statuses.some((status) => status === "pending")) {
      row.overall = "pending";
    } else if (statuses.some((status) => status === "conditional")) {
      row.overall = "conditional";
    } else {
      row.overall = "pass";
    }
  }
}

function writeLedger(ledger) {
  ledger.updatedAtLocal = nowLocal();
  fs.mkdirSync(path.dirname(LEDGER_PATH), { recursive: true });
  fs.writeFileSync(LEDGER_PATH, `${JSON.stringify(ledger, null, 2)}${os.EOL}`, "utf8");
}

function summarize(ledger) {
  refreshOverall(ledger);
  const counts = {};
  for (const row of ledger.princes) {
    counts[row.overall] = (counts[row.overall] || 0) + 1;
  }
  const open = ledger.princes
    .filter((row) => row.overall !== "pass")
    .map((row) => ({
      prince: row.stem,
      overall: row.overall,
      pendingSlots: Object.entries(row.slots)
        .filter(([, value]) => ["pending", "fail", "blocked", "conditional"].includes(value.status))
        .map(([key, value]) => `${key}:${value.status}`),
    }));
  return {
    status: open.length === 0 ? "PASS" : "PENDING",
    ledgerPath: LEDGER_PATH,
    counts,
    open,
  };
}

function nowLocal() {
  return `${new Date().toLocaleString("en-AU", { timeZone: "Australia/Sydney" })} AEST`;
}

function printSummary(summary) {
  console.log(`PDV Daedric runtime evidence: ${summary.status}`);
  console.log(`Ledger: ${summary.ledgerPath}`);
  console.log(`Summary: ${Object.entries(summary.counts).map(([key, value]) => `${key}=${value}`).join(", ")}`);
  if (summary.open.length) {
    console.log("");
    for (const row of summary.open) {
      console.log(`${row.prince}: ${row.overall} (${row.pendingSlots.join(", ")})`);
    }
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return;
  }

  const princes = loadPrinces();
  const ledger = loadOrCreateLedger(princes);
  let changed = false;
  let recorded = 0;

  if (options.init) {
    changed = true;
  }
  if (options.record) {
    recorded = recordEvidence(ledger, options);
    changed = true;
  }
  if (options.fromRuntimeCheck) {
    recorded = recordRuntimeCheckEvidence(ledger, options);
    changed = true;
  }
  if (changed) {
    writeLedger(ledger);
  }

  const summary = summarize(ledger);
  const report = {
    ...summary,
    changed,
    recorded,
  };

  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printSummary(summary);
    if (changed) {
      console.log("");
      console.log(recorded ? `Recorded ${recorded} row(s).` : "Ledger initialized/updated.");
    }
  }
}

try {
  main();
} catch (error) {
  if (process.argv.includes("--json")) {
    console.log(JSON.stringify({
      status: "FAIL",
      error: error instanceof Error ? error.message : String(error),
    }, null, 2));
  } else {
    console.error(error instanceof Error ? error.message : String(error));
  }
  process.exitCode = 1;
}
