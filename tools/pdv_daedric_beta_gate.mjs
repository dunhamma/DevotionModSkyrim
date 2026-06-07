#!/usr/bin/env node
/*
 * Fail-closed Daedric beta-display gate.
 *
 * This reads the structured runtime evidence ledger and reports whether every
 * Skyrim-present Prince has the required in-game route/display/manual slots.
 * It does not write ESP, PEX, SEQ, Papyrus logs, or evidence data.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const CONTRACT_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const LEDGER_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricRuntimeEvidenceLedger.json");
const SCHEMA = "pdv.daedric-runtime-evidence-ledger.v1";

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
  "manualFeel",
];

const curseSlots = ["curseNoDoubleFire"];

function usage() {
  return [
    "Usage: node .\\tools\\pdv_daedric_beta_gate.mjs [options]",
    "",
    "Options:",
    "  --json      Emit JSON.",
    "  --help      Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = { json: false, help: false };
  for (const arg of argv) {
    if (arg === "--json") {
      options.json = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }
  return options;
}

function loadJson(filePath, label) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`${label} missing: ${filePath}`);
  }
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function loadPrinces() {
  const contract = loadJson(CONTRACT_PATH, "Daedric contract");
  if (!Array.isArray(contract.princes) || contract.princes.length !== 16) {
    throw new Error(`Expected 16 princes in ${CONTRACT_PATH}.`);
  }
  return contract.princes.map((prince, index) => ({
    index,
    stem: String(prince.stem || ""),
    displayName: String(prince.displayName || prince.stem || ""),
    curseAccess: ["Molag", "Hircine"].includes(String(prince.stem || "")),
  }));
}

function evaluate() {
  const princes = loadPrinces();
  const ledger = loadJson(LEDGER_PATH, "Daedric runtime evidence ledger");
  if (ledger.schema !== SCHEMA) {
    throw new Error(`Unexpected ledger schema: ${ledger.schema}`);
  }
  const rows = Array.isArray(ledger.princes) ? ledger.princes : [];
  const findings = [];

  for (const prince of princes) {
    const row = rows.find((item) => String(item.stem || "").toLowerCase() === prince.stem.toLowerCase());
    if (!row) {
      findings.push({
        status: "FAIL",
        prince: prince.stem,
        detail: "Missing evidence row.",
        missingSlots: [...requiredSlots, ...(prince.curseAccess ? curseSlots : [])],
      });
      continue;
    }

    const slots = [...requiredSlots, ...(prince.curseAccess ? curseSlots : [])];
    const missingSlots = [];
    const conditionalSlots = [];
    const failedSlots = [];
    const blockedSlots = [];
    for (const slot of slots) {
      const status = row.slots?.[slot]?.status || "missing";
      if (status === "pass" || status === "not_required") {
        continue;
      }
      if (status === "conditional") {
        conditionalSlots.push(slot);
      } else if (status === "fail") {
        failedSlots.push(slot);
      } else if (status === "blocked") {
        blockedSlots.push(slot);
      } else {
        missingSlots.push(slot);
      }
    }

    let status = "PASS";
    if (failedSlots.length) {
      status = "FAIL";
    } else if (blockedSlots.length) {
      status = "BLOCKED";
    } else if (missingSlots.length) {
      status = "PENDING";
    } else if (conditionalSlots.length) {
      status = "CONDITIONAL";
    }

    findings.push({
      status,
      prince: prince.stem,
      displayName: prince.displayName,
      missingSlots,
      conditionalSlots,
      failedSlots,
      blockedSlots,
    });
  }

  const counts = {};
  for (const finding of findings) {
    counts[finding.status] = (counts[finding.status] || 0) + 1;
  }
  const status = findings.every((finding) => finding.status === "PASS") ? "PASS" : "FAIL";
  return {
    status,
    generatedAtLocal: new Date().toLocaleString("en-AU", { timeZone: "Australia/Sydney" }),
    contractPath: CONTRACT_PATH,
    ledgerPath: LEDGER_PATH,
    counts,
    findings,
  };
}

function printText(report) {
  console.log(`PDV Daedric beta-display gate: ${report.status}`);
  console.log(`Summary: ${Object.entries(report.counts).map(([key, value]) => `${key}=${value}`).join(", ")}`);
  console.log(`Ledger: ${report.ledgerPath}`);
  console.log("");
  for (const finding of report.findings) {
    if (finding.status === "PASS") {
      console.log(`[PASS] ${finding.displayName}`);
      continue;
    }
    const parts = [];
    if (finding.missingSlots.length) {
      parts.push(`missing=${finding.missingSlots.join(",")}`);
    }
    if (finding.conditionalSlots.length) {
      parts.push(`conditional=${finding.conditionalSlots.join(",")}`);
    }
    if (finding.failedSlots.length) {
      parts.push(`fail=${finding.failedSlots.join(",")}`);
    }
    if (finding.blockedSlots.length) {
      parts.push(`blocked=${finding.blockedSlots.join(",")}`);
    }
    console.log(`[${finding.status}] ${finding.displayName}: ${parts.join("; ")}`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    process.exitCode = 0;
  } else {
    const report = evaluate();
    if (options.json) {
      console.log(JSON.stringify(report, null, 2));
    } else {
      printText(report);
    }
    process.exitCode = report.status === "PASS" ? 0 : 1;
  }
} catch (error) {
  if (process.argv.includes("--json")) {
    console.log(JSON.stringify({
      status: "FAIL",
      error: error instanceof Error ? error.message : String(error),
    }, null, 2));
  } else {
    console.error(error instanceof Error ? error.message : String(error));
    console.error(usage());
  }
  process.exitCode = 2;
}
