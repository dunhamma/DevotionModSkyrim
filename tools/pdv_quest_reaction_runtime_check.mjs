#!/usr/bin/env node
/*
 * Read-only Papyrus log checker for bounded quest-reaction queue proof.
 *
 * It validates lifecycle markers and safety failures. It does not prove the
 * Book of Days entry, Prisma rendering, exact piety values, or organic stage
 * delivery; those remain separate runtime/manual proof buckets.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--allow-overflow", "--expected-sequence", "--help", "--json", "--log", "--max-job-ms", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_quest_reaction_runtime_check" });

const DEFAULT_LOG = path.join("C:/Users/Admin", "Documents", "My Games", "Skyrim Special Edition", "Logs", "Script", "Papyrus.0.log");
const ACTIONS = ["ENQUEUE", "COALESCE", "START", "COMPLETE", "RESUME", "OVERFLOW"];

function usage() {
  return [
    "Usage: node .\\tools\\pdv_quest_reaction_runtime_check.mjs [options]",
    "",
    "Options:",
    "  --log <path>                    Papyrus log path. Defaults to Papyrus.0.log.",
    "  --expected-sequence <key,...>   Require the final enqueue/start/complete key sequence.",
    "  --max-job-ms <milliseconds>      Fail when START-to-COMPLETE latency exceeds the limit.",
    "  --allow-overflow                 Report (but do not fail on) an explicit overload probe.",
    "  --self-test                      Check an embedded successful synthetic log.",
    "  --json                           Emit JSON.",
    "  --help                           Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = { logPath: DEFAULT_LOG, expectedSequence: [], maxJobMs: null, allowOverflow: false, selfTest: false, json: false, help: false };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--log") {
      options.logPath = argv[++index];
      if (!options.logPath) throw new Error("--log requires a path.");
    } else if (arg === "--expected-sequence") {
      const raw = argv[++index];
      if (!raw) throw new Error("--expected-sequence requires a comma-separated list of reaction keys.");
      options.expectedSequence = raw.split(",").map((value) => value.trim()).filter(Boolean);
      if (!options.expectedSequence.length) throw new Error("--expected-sequence must contain at least one reaction key.");
    } else if (arg === "--max-job-ms") {
      const raw = argv[++index];
      options.maxJobMs = Number(raw);
      if (!raw || !Number.isFinite(options.maxJobMs) || options.maxJobMs <= 0) {
        throw new Error("--max-job-ms requires a positive number.");
      }
    } else if (arg === "--allow-overflow") options.allowOverflow = true;
    else if (arg === "--self-test") options.selfTest = true;
    else if (arg === "--json") options.json = true;
    else if (arg === "--help" || arg === "-h") options.help = true;
    else throw new Error(`Unknown option: ${arg}`);
  }
  return options;
}

function timestampMs(line) {
  const match = line.match(/\[(\d{1,2})\/(\d{1,2})\/(\d{4})\s*-\s*(\d{1,2}):(\d{2}):(\d{2})(AM|PM)\]/i);
  if (!match) return null;
  let hour = Number(match[4]);
  const period = match[7].toUpperCase();
  if (period === "AM" && hour === 12) hour = 0;
  if (period === "PM" && hour !== 12) hour += 12;
  return new Date(Number(match[3]), Number(match[1]) - 1, Number(match[2]), hour, Number(match[5]), Number(match[6])).getTime();
}

function token(line, names) {
  for (const name of names) {
    const match = line.match(new RegExp(`\\b${name}=([^\\s,;]+)`, "i"));
    if (match) return match[1];
  }
  return "";
}

function parseMarker(line, lineNumber) {
  const match = line.match(/\[PDV\]\[QR_QUEUE\]\s+(ENQUEUE|COALESCE|START|COMPLETE|RESUME|OVERFLOW)\b/i);
  if (!match) return null;
  const action = match[1].toUpperCase();
  const explicitMs = token(line, ["elapsedMs", "durationMs"]);
  const elapsedSeconds = token(line, ["elapsed"]);
  const markerTail = line.slice((match.index ?? 0) + match[0].length).trim();
  const namedJob = token(line, ["job", "jobId", "id"]);
  // V3 writes a human verb before the persisted job id, e.g. "START started
  // v3qr_2 ...".  Do not mistake that verb for the job: pair only the explicit
  // V3/legacy queue identifier, wherever it appears in the marker tail.
  const implicitJob = ["ENQUEUE", "START", "COMPLETE"].includes(action)
    ? (markerTail.match(/\b((?:v3)?qr_[0-9]+)\b/i)?.[1] ?? "")
    : "";
  return {
    action,
    line: lineNumber,
    text: line.trim(),
    job: namedJob || implicitJob,
    key: token(line, ["key", "reactionKey"]),
    sequence: token(line, ["sequence", "seq"]),
    timestamp: timestampMs(line),
    buildMs: Number.isFinite(Number(token(line, ["buildMs"]))) ? Number(token(line, ["buildMs"])) : null,
    durationMs: explicitMs && Number.isFinite(Number(explicitMs))
      ? Number(explicitMs)
      : (elapsedSeconds && Number.isFinite(Number(elapsedSeconds)) ? Number(elapsedSeconds) * 1000 : null),
  };
}

function suffixMatches(actual, expected) {
  if (!expected.length) return true;
  if (actual.length < expected.length) return false;
  const suffix = actual.slice(-expected.length);
  return suffix.every((value, index) => value === expected[index]);
}

function findSafetyFailures(lines) {
  const patterns = [
    { id: "stack-dump", pattern: /dumping stack|stack dump|freezing suspended stack/i },
    { id: "broad-scope-abort", pattern: /BROAD_SCOPE_ABORT/i },
  ];
  const failures = [];
  for (let index = 0; index < lines.length; index += 1) {
    for (const item of patterns) {
      if (item.pattern.test(lines[index])) failures.push({ id: item.id, line: index + 1, text: lines[index].trim() });
    }
  }
  return failures;
}

function findVmLifecycleObservations(lines) {
  const observations = [];
  let openFreeze = null;
  for (let index = 0; index < lines.length; index += 1) {
    const text = lines[index].trim();
    if (/VM is freezing|VM freeze/i.test(text) && !/freezing suspended stack/i.test(text)) {
      openFreeze = { line: index + 1, text };
    } else if (/VM is thawing/i.test(text) && openFreeze) {
      observations.push({
        id: "normal-freeze-thaw",
        line: openFreeze.line,
        thawLine: index + 1,
        text: openFreeze.text,
      });
      openFreeze = null;
    }
  }
  if (openFreeze) observations.push({ id: "unpaired-vm-freeze", line: openFreeze.line, text: openFreeze.text });
  return observations;
}

export function evaluateLog(logText, options = {}) {
  const lines = logText.split(/\r?\n/);
  const markers = lines.map(parseMarker).filter(Boolean);
  const byAction = Object.fromEntries(ACTIONS.map((action) => [action, markers.filter((marker) => marker.action === action)]));
  const safetyFailures = findSafetyFailures(lines);
  const vmLifecycleObservations = findVmLifecycleObservations(lines);
  const startsByJob = new Map(byAction.START.filter((entry) => entry.job).map((entry) => [entry.job, entry]));
  const enqueueByJob = new Map(byAction.ENQUEUE.filter((entry) => entry.job).map((entry) => [entry.job, entry]));
  const completeByJob = new Map(byAction.COMPLETE.filter((entry) => entry.job).map((entry) => [entry.job, entry]));
  const incomplete = [];
  for (const start of byAction.START) {
    const complete = start.job ? completeByJob.get(start.job) : byAction.COMPLETE.find((entry) => entry.key && entry.key === start.key && entry.line > start.line);
    if (!complete) incomplete.push(start);
  }
  const durations = byAction.COMPLETE.map((complete) => {
    const start = complete.job ? startsByJob.get(complete.job) : byAction.START.find((entry) => entry.key === complete.key && entry.line < complete.line);
    const enqueue = complete.job ? enqueueByJob.get(complete.job) : byAction.ENQUEUE.find((entry) => entry.key === complete.key && entry.line < complete.line);
    const jobMs = start?.timestamp != null && complete.timestamp != null ? complete.timestamp - start.timestamp : null;
    const endToEndMs = complete.durationMs ?? (enqueue?.timestamp != null && complete.timestamp != null ? complete.timestamp - enqueue.timestamp : null);
    const ingressMs = enqueue?.timestamp != null && start?.timestamp != null ? start.timestamp - enqueue.timestamp : null;
    return { job: complete.job, key: complete.key, line: complete.line, jobMs, endToEndMs, ingressMs, ingressBuildMs: enqueue?.buildMs ?? null };
  });
  const expected = options.expectedSequence ?? [];
  const enqueueKeys = byAction.ENQUEUE.map((entry) => entry.key).filter(Boolean);
  const startKeys = byAction.START.map((entry) => entry.key).filter(Boolean);
  const completeKeys = byAction.COMPLETE.map((entry) => entry.key).filter(Boolean);
  const checks = [];
  const add = (ok, id, detail) => checks.push({ status: ok ? "PASS" : "FAIL", id, detail });
  add(markers.length > 0, "markers-present", "Papyrus log contains [PDV][QR_QUEUE] lifecycle markers.");
  add(byAction.ENQUEUE.length > 0, "enqueue-present", "At least one queue job was enqueued.");
  add(byAction.START.length > 0, "start-present", "At least one queue job began processing.");
  add(byAction.COMPLETE.length > 0, "complete-present", "At least one queue job completed.");
  add(incomplete.length === 0, "started-jobs-complete", incomplete.length ? `${incomplete.length} started job(s) lack a completion marker.` : "Every started job has a later completion marker.");
  add(safetyFailures.length === 0, "no-critical-safety-failure", safetyFailures.length ? safetyFailures.map((entry) => `${entry.id}@${entry.line}`).join(", ") : "No stack dump, frozen-stack marker, or BROAD_SCOPE_ABORT found.");
  add(options.allowOverflow || byAction.OVERFLOW.length === 0, "no-overflow", byAction.OVERFLOW.length ? `${byAction.OVERFLOW.length} overflow marker(s) found.` : "No queue overflow marker found.");
  if (options.maxJobMs != null) {
    const unavailable = durations.filter((entry) => entry.jobMs == null);
    const slow = durations.filter((entry) => entry.jobMs != null && entry.jobMs > options.maxJobMs);
    add(
      unavailable.length === 0 && slow.length === 0,
      "job-latency-within-limit",
      unavailable.length
        ? `${unavailable.length} completed job(s) lack START-to-COMPLETE timestamps.`
        : (slow.length
          ? `${slow.length} job(s) exceeded ${options.maxJobMs} ms: ${slow.map((entry) => `${entry.job || entry.key}=${entry.jobMs}`).join(", ")}.`
          : `Every completed job finished within ${options.maxJobMs} ms of START.`),
    );
  }
  if (expected.length) {
    add(suffixMatches(enqueueKeys, expected), "expected-enqueue-sequence", `Expected final enqueue keys: ${expected.join(" -> ")}; saw ${enqueueKeys.slice(-expected.length).join(" -> ") || "none"}.`);
    add(suffixMatches(startKeys, expected), "expected-start-sequence", `Expected final start keys: ${expected.join(" -> ")}; saw ${startKeys.slice(-expected.length).join(" -> ") || "none"}.`);
    add(suffixMatches(completeKeys, expected), "expected-complete-sequence", `Expected final completion keys: ${expected.join(" -> ")}; saw ${completeKeys.slice(-expected.length).join(" -> ") || "none"}.`);
  }

  return {
    status: checks.some((check) => check.status === "FAIL") ? "FAIL" : "PASS",
    proofBoundary: "runtime-route and queue-safety markers only; Book of Days, Prisma, exact state, and organic quest-stage proof remain separate",
    checks,
    markerCounts: Object.fromEntries(ACTIONS.map((action) => [action.toLowerCase(), byAction[action].length])),
    safetyFailures,
    vmLifecycleObservations,
    incomplete: incomplete.map((entry) => ({ job: entry.job, key: entry.key, line: entry.line })),
    durations,
    sequence: { expected, enqueue: enqueueKeys, start: startKeys, complete: completeKeys },
  };
}

function selfTestLog() {
  return [
    "[08/14/2026 - 05:56:23PM] [PDV][QR_QUEUE] ENQUEUE queued v3qr_2 key=Skyrim.esm|210731|150 cells=25 sourceCells=45 skipped=20 meta=0 buildMs=11500.000000 pending=1",
    "[08/14/2026 - 05:56:23PM] [PDV][QR_QUEUE] START started v3qr_2 key=Skyrim.esm|210731|150 cells=25 sourceCells=45 skipped=20 meta=0",
    "[08/14/2026 - 05:56:23PM] [PDV][QR_QUEUE] ENQUEUE queued v3qr_3 key=Skyrim.esm|148154|160 cells=25 sourceCells=45 skipped=20 meta=0 buildMs=261.962891 pending=2",
    "[08/14/2026 - 05:56:24PM] [PDV][QR_QUEUE] ENQUEUE queued v3qr_4 key=Skyrim.esm|207142|200 cells=25 sourceCells=45 skipped=20 meta=0 buildMs=189.025879 pending=3",
    "[08/14/2026 - 05:56:25PM] [PDV][QR_QUEUE] ENQUEUE queued v3qr_5 key=Skyrim.esm|221587|220 cells=11 sourceCells=22 skipped=11 meta=0 buildMs=613.037109 pending=4",
    "[08/14/2026 - 05:56:31PM] [PDV][QR_QUEUE] COMPLETE completed v3qr_2 key=Skyrim.esm|210731|150 cells=25 sourceCells=45 skipped=20 meta=0 elapsed=7.729004",
    "[08/14/2026 - 05:56:31PM] [PDV][QR_QUEUE] START started v3qr_3 key=Skyrim.esm|148154|160 cells=25 sourceCells=45 skipped=20 meta=0",
    "[08/14/2026 - 05:56:36PM] [PDV][QR_QUEUE] COMPLETE completed v3qr_3 key=Skyrim.esm|148154|160 cells=25 sourceCells=45 skipped=20 meta=0 elapsed=12.684021",
    "[08/14/2026 - 05:56:36PM] [PDV][QR_QUEUE] START started v3qr_4 key=Skyrim.esm|207142|200 cells=25 sourceCells=45 skipped=20 meta=0",
    "[08/14/2026 - 05:56:42PM] [PDV][QR_QUEUE] COMPLETE completed v3qr_4 key=Skyrim.esm|207142|200 cells=25 sourceCells=45 skipped=20 meta=0 elapsed=17.491028",
    "[08/14/2026 - 05:56:42PM] [PDV][QR_QUEUE] START started v3qr_5 key=Skyrim.esm|221587|220 cells=11 sourceCells=22 skipped=11 meta=0",
    "[08/14/2026 - 05:56:45PM] [PDV][QR_QUEUE] COMPLETE completed v3qr_5 key=Skyrim.esm|221587|220 cells=11 sourceCells=22 skipped=11 meta=0 elapsed=19.790039",
  ].join(os.EOL);
}

function printReport(report) {
  console.log(`PDV quest-reaction queue runtime check: ${report.status}`);
  for (const check of report.checks) console.log(`[${check.status}] ${check.id}: ${check.detail}`);
  console.log(`Markers: ${Object.entries(report.markerCounts).map(([key, value]) => `${key}=${value}`).join(" ")}`);
  for (const duration of report.durations) {
    console.log(`Completion: job=${duration.job || "?"} key=${duration.key || "?"} jobMs=${duration.jobMs ?? "unavailable"} endToEndMs=${duration.endToEndMs ?? "unavailable"} queueWaitMs=${duration.ingressMs ?? "unavailable"} ingressBuildMs=${duration.ingressBuildMs ?? "unavailable"}`);
  }
  console.log(`Proof boundary: ${report.proofBoundary}`);
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return 0;
  }
  const logText = options.selfTest
    ? selfTestLog()
    : fs.readFileSync(options.logPath, "utf8");
  if (options.selfTest) {
    options.expectedSequence = [
      "Skyrim.esm|210731|150",
      "Skyrim.esm|148154|160",
      "Skyrim.esm|207142|200",
      "Skyrim.esm|221587|220",
    ];
    options.maxJobMs = 10000;
  }
  const report = evaluateLog(logText, options);
  if (options.json) console.log(JSON.stringify(report, null, 2));
  else printReport(report);
  return report.status === "PASS" ? 0 : 1;
}

try {
  process.exitCode = main();
} catch (error) {
  if (process.argv.includes("--json")) console.log(JSON.stringify({ status: "FAIL", error: error.message }, null, 2));
  else {
    console.error(`PDV quest-reaction queue runtime check failed: ${error.message}`);
    console.error(usage());
  }
  process.exitCode = 2;
}
