#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { assertKnownFlags, makeFlagReader } from "./lib/pdv_cli.mjs";
import {
  evaluateGate,
  formatSummary,
  isRuntimeSensitive,
  nowLocal,
  readJson,
  recordSlot,
  scanLog,
  syncLedger,
  validateManifest,
} from "./lib/pdv_v3_runtime_acceptance.mjs";

const KNOWN_FLAGS = new Set(["--artifact", "--case", "--check", "--commit", "--gate", "--help", "--init", "--json", "--log", "--note", "--record", "--slot", "--start", "--status", "--summary"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_v3_runtime_acceptance" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANIFEST_PATH = path.join(ROOT, "references", "authoring", "PDV_2_0_RuntimeAcceptance.manifest.json");
const LEDGER_PATH = path.join(ROOT, "references", "authoring", "PDV_2_0_RuntimeAcceptanceLedger.json");

function usage() {
  return [
    "Usage: node .\\tools\\pdv_v3_runtime_acceptance.mjs <mode> [options]",
    "",
    "Modes:",
    "  --init                       Synchronize the committed ledger shell with the manifest.",
    "  --start --commit <sha>       Start a fresh evidence run at the tested code commit.",
    "  --record                     Record one slot.",
    "  --summary                    Show current evidence status without gating.",
    "  --check                      Fail closed on the selected gate (default gate1).",
    "",
    "Recording:",
    "  --case <id> --slot <id> --status <pending|pass|fail|blocked|not_required>",
    "  --note <text> [--artifact <path>]... [--commit <sha>]",
    "",
    "Checking:",
    "  --gate <gate1|gate2|final|all> [--log <Papyrus.0.log>] [--json]",
    "",
    "This tool never infers manual/player-surface PASS from a Papyrus log.",
  ].join(os.EOL);
}

function git(args) {
  return execFileSync("git", args, { cwd: ROOT, encoding: "utf8" }).trim();
}

function writeLedger(ledger) {
  fs.writeFileSync(LEDGER_PATH, `${JSON.stringify(ledger, null, 2)}\n`, "utf8");
}

function collectValues(argv, flag) {
  const values = [];
  for (let index = 0; index < argv.length; index += 1) if (argv[index] === flag && argv[index + 1]) values.push(argv[index + 1]);
  return values;
}

function runtimeSensitiveChanges(manifest, testedCommit) {
  if (!testedCommit) return [];
  try {
    git(["cat-file", "-e", `${testedCommit}^{commit}`]);
  } catch {
    return ["(testedCommit is not available in this checkout)"];
  }
  try {
    git(["merge-base", "--is-ancestor", testedCommit, "HEAD"]);
  } catch {
    return ["(testedCommit is not an ancestor of HEAD)"];
  }

  const changed = new Set();
  for (const args of [
    ["diff", "--name-only", `${testedCommit}..HEAD`],
    ["diff", "--name-only"],
    ["diff", "--cached", "--name-only"],
    ["ls-files", "--others", "--exclude-standard"],
  ]) {
    for (const file of git(args).split(/\r?\n/).filter(Boolean)) changed.add(file.replaceAll("\\", "/"));
  }
  return [...changed].filter((file) => isRuntimeSensitive(file, manifest.runtimeSensitivePaths ?? [])).sort();
}

function summary(manifest, ledger) {
  const synced = syncLedger(manifest, ledger);
  const counts = {};
  for (const row of synced.cases) {
    for (const slot of Object.values(row.slots)) counts[slot.status] = (counts[slot.status] ?? 0) + 1;
  }
  return {
    status: counts.fail ? "FAIL" : counts.blocked ? "BLOCKED" : counts.pending ? "PENDING" : "PASS",
    testedCommit: synced.testedCommit,
    startedAtLocal: synced.startedAtLocal,
    counts,
    cases: synced.cases.map((row) => ({
      id: row.id,
      gate: row.gate,
      status: Object.values(row.slots).every((slot) => ["pass", "not_required"].includes(slot.status)) ? "PASS" : "OPEN",
      open: Object.entries(row.slots).filter(([, slot]) => !["pass", "not_required"].includes(slot.status)).map(([id, slot]) => `${id}:${slot.status}`),
    })),
  };
}

try {
  const argv = process.argv.slice(2);
  if (argv.includes("--help") || argv.includes("-h")) {
    console.log(usage());
    process.exit(0);
  }
  const flags = makeFlagReader(argv);
  const modes = ["--init", "--start", "--record", "--summary", "--check"].filter((flag) => flags.has(flag));
  if (modes.length !== 1) throw new Error("Select exactly one mode: --init, --start, --record, --summary, or --check.");
  const manifest = readJson(MANIFEST_PATH);
  const manifestErrors = validateManifest(manifest);
  if (manifestErrors.length) throw new Error(manifestErrors.join(" "));
  const ledger = syncLedger(manifest, fs.existsSync(LEDGER_PATH) ? readJson(LEDGER_PATH) : {});
  let output;
  let exitCode = 0;

  if (flags.has("--init")) {
    ledger.updatedAtLocal = nowLocal();
    writeLedger(ledger);
    output = { status: "PASS", action: "init", cases: ledger.cases.length, ledger: path.relative(ROOT, LEDGER_PATH) };
  } else if (flags.has("--start")) {
    const commit = flags.value("--commit") || git(["rev-parse", "HEAD"]);
    if (!commit.match(/^[0-9a-f]{7,40}$/i)) throw new Error("--commit must be a Git commit SHA.");
    const fresh = syncLedger(manifest, { testedCommit: commit, profile: manifest.profile, enabledMod: manifest.enabledMod, startedAtLocal: nowLocal() });
    fresh.updatedAtLocal = fresh.startedAtLocal;
    writeLedger(fresh);
    output = { status: "PASS", action: "start", testedCommit: commit, startedAtLocal: fresh.startedAtLocal };
  } else if (flags.has("--record")) {
    recordSlot(ledger, {
      caseId: flags.value("--case") || "",
      slotId: flags.value("--slot") || "",
      status: String(flags.value("--status") || "").toLowerCase(),
      note: flags.value("--note") || "",
      artifacts: collectValues(argv, "--artifact"),
      commit: flags.value("--commit") || ledger.testedCommit,
    });
    writeLedger(ledger);
    output = { status: "PASS", action: "record", case: flags.value("--case"), slot: flags.value("--slot") };
  } else if (flags.has("--summary")) {
    output = summary(manifest, ledger);
  } else {
    const gate = flags.value("--gate") || "gate1";
    const logReports = [];
    for (const logPath of collectValues(argv, "--log")) {
      const resolved = path.resolve(logPath);
      if (!fs.existsSync(resolved)) throw new Error(`Papyrus log not found: ${resolved}`);
      const stat = fs.statSync(resolved);
      logReports.push({
        ...scanLog(fs.readFileSync(resolved, "utf8"), manifest.logRules, { startedAt: ledger.startedAtLocal, modifiedAt: stat.mtime }),
        path: resolved,
      });
    }
    output = evaluateGate(manifest, ledger, gate, {
      runtimeSensitiveChanges: runtimeSensitiveChanges(manifest, ledger.testedCommit),
      logReports,
    });
    exitCode = output.status === "PASS" ? 0 : 1;
  }

  if (flags.has("--json")) console.log(JSON.stringify(output, null, 2));
  else if (flags.has("--check")) console.log(formatSummary(output));
  else console.log(JSON.stringify(output, null, 2));
  process.exitCode = exitCode;
} catch (error) {
  const payload = { status: "FAIL", error: error instanceof Error ? error.message : String(error) };
  if (process.argv.includes("--json")) console.log(JSON.stringify(payload, null, 2));
  else {
    console.error(payload.error);
    console.error(usage());
  }
  process.exitCode = 2;
}
