#!/usr/bin/env node
/*
 * PDV 1.0 End-State Gate - contract-driven ship-readiness burndown.
 *
 * Reads references/authoring/PDV_1_0_EndStateContract.json and evaluates every
 * criterion against committed ledgers (default) or by executing the machine
 * gate tools (--run). Emits PDV_1_0_EndStateBurndown.md/.json: the single
 * cross-check of "agreed 1.0 end state" vs "recorded testing evidence".
 *
 * Pass-rule vocabulary (the ONLY logic here; criteria edits never need tool
 * edits): md-contains, json-path-equals, slots-all-pass, exit-zero (run/
 * tool-fast), not-built, stamp-only, rollup-all. Unknown rules fail closed.
 *
 * Drift doctrine: machine criteria FAIL on source drift, human criteria go
 * STALE (see contract driftDoctrine). Hashes live in the generated stamp file
 * and refresh whenever a criterion is observed PASS.
 *
 * Flags:
 *   --run             also execute machine-gate tools (bridge-backed ones
 *                     SKIP-not-PASS internally when houseCARL is down)
 *   --strict-stale    STALE blocks too (release-day mode)
 *   --restamp <id>    refresh one criterion's freshness stamp (attests the
 *                     recorded evidence was re-checked against current sources)
 *   --json            print the JSON report to stdout
 *   --self-test       run the fixture-based self test and exit
 *
 * Read-only except its own burndown + stamp outputs.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { hashBytes, hashText, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--error-unmatch", "--help", "--json", "--only", "--restamp", "--run", "--self-test", "--strict-stale"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_1_0_endstate_gate" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const CONTRACT_REL = "references/authoring/PDV_1_0_EndStateContract.json";
const FRESHNESS_HASH_MODE = "text-lf-bytes-binary-v1";
const BINARY_FRESHNESS_EXTENSIONS = new Set([".ba2", ".bsa", ".dll", ".esl", ".esm", ".esp", ".pex", ".seq", ".zip"]);

function parseArgs(argv) {
  const opts = { run: false, strictStale: false, json: false, selfTest: false, restamp: [], only: [], help: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--run") opts.run = true;
    else if (a === "--only") { opts.only.push(String(argv[++i] ?? "")); }
    else if (a === "--strict-stale") opts.strictStale = true;
    else if (a === "--json") opts.json = true;
    else if (a === "--self-test") opts.selfTest = true;
    else if (a === "--restamp") { opts.restamp.push(String(argv[++i] ?? "")); }
    else if (a === "--help" || a === "-h") opts.help = true;
    else throw new Error(`Unknown option: ${a}`);
  }
  return opts;
}

function usage() {
  return [
    "Usage: node .\\tools\\pdv_1_0_endstate_gate.mjs [--run] [--only <criterionId>] [--strict-stale] [--restamp <criterionId>] [--json] [--self-test]",
  ].join(os.EOL);
}

// ---------- helpers ----------

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^﻿/, ""));
}

function sha256File(filePath) {
  try {
    return BINARY_FRESHNESS_EXTENSIONS.has(path.extname(filePath).toLowerCase()) ? hashBytes(filePath) : hashText(filePath);
  } catch {
    return "absent";
  }
}

function jsonPath(obj, dotted) {
  let cur = obj;
  for (const part of String(dotted).split(".")) {
    if (cur == null) return undefined;
    cur = cur[part];
  }
  return cur;
}

function asciiSafe(v) {
  return String(v ?? "").replace(/\|/g, "/").replace(/[^\x00-\x7F]/g, "?").replace(/\r?\n/g, " ");
}

function resolveSource(root, sharedSources, entry) {
  let p = String(entry);
  if (p.startsWith("@")) {
    const key = p.slice(1);
    if (!(key in sharedSources)) throw new Error(`Unknown shared source ref: ${p}`);
    p = sharedSources[key];
  }
  return path.isAbsolute(p) ? p : path.join(root, p);
}

// ---------- evidence evaluation (base status, before freshness) ----------

function evalSlotsAllPass(ledgerObj, params) {
  const passStatuses = params.passStatuses ?? ["evidence-recorded", "not-applicable"];
  const statusField = params.statusField ?? "status";
  let entries;
  if (params.group) {
    const group = ledgerObj?.groups?.[params.group];
    if (!group || typeof group.slots !== "object") return { ok: false, detail: `group '${params.group}' missing` };
    entries = Object.entries(group.slots);
  } else {
    const rows = params.rowsPath ? jsonPath(ledgerObj, params.rowsPath) : ledgerObj;
    if (rows == null || typeof rows !== "object") return { ok: false, detail: `rowsPath '${params.rowsPath}' missing` };
    entries = Array.isArray(rows) ? rows.map((r, i) => [r.id ?? r.familyId ?? String(i), r]) : Object.entries(rows);
  }
  if (!entries.length) return { ok: false, detail: "no slots found (fail-closed)" };
  const pending = entries.filter(([, v]) => !passStatuses.includes(String(v?.[statusField] ?? "missing"))).map(([k]) => k);
  if (pending.length) {
    const shown = pending.slice(0, 8).join(", ") + (pending.length > 8 ? `, +${pending.length - 8} more` : "");
    return { ok: false, detail: `${pending.length}/${entries.length} slots open: ${shown}` };
  }
  return { ok: true, detail: `${entries.length}/${entries.length} slots recorded` };
}

function runTool(root, tool, timeoutMs) {
  const r = spawnSync(process.execPath, tool, {
    cwd: root, encoding: "utf8", timeout: timeoutMs ?? 900_000,
    maxBuffer: 64 * 1024 * 1024, windowsHide: true,
  });
  if (r.error) return { ok: false, detail: `spawn error: ${r.error.message}` };
  return { ok: r.status === 0, detail: `exit ${r.status}` };
}

function evalRead(root, criterion, stamps) {
  const read = criterion.evidence?.read;
  if (!read) return { base: "RED", detail: "no read evidence spec (fail-closed)" };
  const kind = read.kind;

  if (kind === "not-built") {
    return { base: "RED", detail: `not built. Planned evidence: ${read.params?.plannedEvidence ?? "unspecified"}` };
  }

  if (kind === "stamp-only") {
    const stamp = stamps.stamps?.[criterion.id];
    if (!stamp || stamp.result !== "PASS") return { base: "RED", detail: "never observed PASS; run with --run" };
    return { base: "PASS", detail: `last observed PASS ${stamp.observedAt}` };
  }

  if (kind === "tool-fast") {
    const r = runTool(root, read.tool, 120_000);
    return { base: r.ok ? "PASS" : "RED", detail: r.detail };
  }

  if (kind === "rollup") return { base: "ROLLUP", detail: "" };

  const ledgerPath = path.join(root, read.ledger ?? "");
  if (!read.ledger || !fs.existsSync(ledgerPath)) {
    return { base: "RED", detail: `ledger missing: ${read.ledger ?? "(unset)"}` };
  }

  if (kind === "ledger-md") {
    if (read.passRule !== "md-contains") return { base: "RED", detail: `unknown passRule '${read.passRule}' (fail-closed)` };
    const text = fs.readFileSync(ledgerPath, "utf8");
    const re = new RegExp(read.params.pattern, "gm");
    const count = (text.match(re) ?? []).length;
    const min = read.params.minCount ?? 1;
    return count >= min
      ? { base: "PASS", detail: `pattern matched ${count}x (min ${min})` }
      : { base: "RED", detail: `pattern '${read.params.pattern}' matched ${count}x, need ${min}` };
  }

  if (kind === "ledger-json" || kind === "manual-slots") {
    let obj;
    try { obj = loadJson(ledgerPath); } catch (e) { return { base: "RED", detail: `ledger unreadable: ${e.message}` }; }
    if (read.passRule === "json-path-equals") {
      const actual = jsonPath(obj, read.params.path);
      return actual === read.params.equals
        ? { base: "PASS", detail: `${read.params.path} = ${JSON.stringify(actual)}` }
        : { base: "RED", detail: `${read.params.path} = ${JSON.stringify(actual)}, need ${JSON.stringify(read.params.equals)}` };
    }
    if (read.passRule === "slots-all-pass") {
      const r = evalSlotsAllPass(obj, read.params ?? {});
      return { base: r.ok ? "PASS" : "RED", detail: r.detail };
    }
    return { base: "RED", detail: `unknown passRule '${read.passRule}' (fail-closed)` };
  }

  return { base: "RED", detail: `unknown evidence kind '${kind}' (fail-closed)` };
}

// ---------- freshness ----------

function hashSources(root, sharedSources, sources) {
  const out = {};
  for (const entry of sources ?? []) {
    const abs = resolveSource(root, sharedSources, entry);
    out[String(entry)] = sha256File(abs);
  }
  return out;
}

function legacyByteHashSources(root, sharedSources, sources) {
  const out = {};
  for (const entry of sources ?? []) {
    const abs = resolveSource(root, sharedSources, entry);
    try { out[String(entry)] = hashBytes(abs); }
    catch { out[String(entry)] = "absent"; }
  }
  return out;
}

function applyFreshness(criterion, base, detail, currentHashes, legacyHashes, stamps, restampIds, freshObservation) {
  const stampEntry = stamps.stamps?.[criterion.id];
  let effectiveStamp = stampEntry;
  let migratedLegacyHash = false;
  const onDrift = criterion.freshness?.onDrift ?? "FAIL";
  const hasSources = (criterion.freshness?.sources ?? []).length > 0;

  if (stampEntry && !stampEntry.hashMode) {
    const legacyMatches = Object.entries(legacyHashes).every(([key, value]) => stampEntry.sourceHashes?.[key] === value);
    if (legacyMatches) {
      effectiveStamp = { ...stampEntry, hashMode: FRESHNESS_HASH_MODE, sourceHashes: currentHashes };
      migratedLegacyHash = true;
    }
  }

  // A live execution (--run or tool-fast) IS new evidence: it supersedes the
  // old stamp, so drift-vs-old-stamp does not apply.
  if (restampIds.includes(criterion.id) || (freshObservation && base === "PASS")) {
    return { status: base, detail, stamp: { observedAt: new Date().toISOString(), result: base, hashMode: FRESHNESS_HASH_MODE, sourceHashes: currentHashes }, drift: false };
  }
  if (base !== "PASS" || !hasSources) {
    const stamp = base === "PASS" ? { observedAt: new Date().toISOString(), result: "PASS", hashMode: FRESHNESS_HASH_MODE, sourceHashes: currentHashes } : effectiveStamp ?? null;
    return { status: base, detail, stamp, drift: false };
  }
  if (!effectiveStamp) {
    return { status: "PASS", detail: `${detail}; stamped fresh`, stamp: { observedAt: new Date().toISOString(), result: "PASS", hashMode: FRESHNESS_HASH_MODE, sourceHashes: currentHashes }, drift: false };
  }
  if (migratedLegacyHash) {
    return {
      status: "PASS",
      detail: `${detail}; migrated freshness hashes from raw checkout bytes to normalized text/exact binary semantics`,
      stamp: effectiveStamp,
      drift: false,
    };
  }
  const drifted = Object.entries(currentHashes).filter(([k, v]) => (effectiveStamp.sourceHashes?.[k] ?? "unknown") !== v).map(([k]) => k);
  if (!drifted.length) return { status: "PASS", detail, stamp: effectiveStamp, drift: false };
  const driftDetail = `${detail}; drift since ${effectiveStamp.observedAt}: ${drifted.join(", ")}`;
  if (onDrift === "STALE") return { status: "STALE", detail: driftDetail, stamp: effectiveStamp, drift: true };
  return { status: "RED", detail: `evidence voided by source drift - ${driftDetail}`, stamp: effectiveStamp, drift: true };
}

// ---------- main evaluation ----------

export function evaluateContract(root, contractRel, opts) {
  const contractPath = path.join(root, contractRel);
  const contract = loadJson(contractPath);
  if (contract.schema !== "pdv.1-0.endstate-contract.v1") throw new Error(`Unexpected contract schema: ${contract.schema}`);
  const shared = contract.sharedSources ?? {};
  const stampPath = path.join(root, contract.stampFile);
  let stamps = { schema: "pdv.1-0.freshness-stamps.v2", stamps: {} };
  if (fs.existsSync(stampPath)) { try { stamps = loadJson(stampPath); } catch { /* regenerate */ } }

  const rows = [];
  const findings = [];
  let rollupCriterion = null;

  for (const criterion of contract.criteria) {
    if (criterion.evidence?.read?.kind === "rollup") { rollupCriterion = criterion; continue; }

    let base, detail;
    const runThis = opts.run && (!opts.only?.length || opts.only.includes(criterion.id));
    const executedLive = (runThis && criterion.evidence?.run) || criterion.evidence?.read?.kind === "tool-fast";
    if (runThis && criterion.evidence?.run) {
      const r = runTool(root, criterion.evidence.run.tool);
      base = r.ok ? "PASS" : "RED";
      detail = `--run ${criterion.evidence.run.tool.join(" ")}: ${r.detail}`;
    } else {
      ({ base, detail } = evalRead(root, criterion, stamps));
    }

    const currentHashes = hashSources(root, shared, criterion.freshness?.sources);
    const legacyHashes = legacyByteHashSources(root, shared, criterion.freshness?.sources);
    const fresh = applyFreshness(criterion, base, detail, currentHashes, legacyHashes, stamps, opts.restamp ?? [], executedLive);
    if (fresh.stamp) stamps.stamps[criterion.id] = fresh.stamp;

    rows.push({
      id: criterion.id, lane: criterion.lane, category: criterion.category,
      title: criterion.title, status: fresh.status, detail: fresh.detail,
      closes: criterion.closes ?? "", drift: fresh.drift,
    });
  }

  // Live-vs-deployed manager drift finding.
  if (shared.managerLive && shared.managerDeployed) {
    const live = sha256File(resolveSource(root, shared, "@managerLive"));
    const deployed = sha256File(resolveSource(root, shared, "@managerDeployed"));
    if (live !== "absent" && deployed !== "absent" && live !== deployed) {
      findings.push("live-vs-deployed-drift: git live-source manager differs from the MO2 deployed copy; sync live-source to MO2 (or vice versa) before trusting source-read audits.");
    }
    const gitCheck = spawnSync("git", ["ls-files", "--error-unmatch", shared.managerLive], { cwd: root, encoding: "utf8", windowsHide: true });
    if (gitCheck.status !== 0 && live !== "absent") {
      findings.push(`untracked-live-manager: ${shared.managerLive} is not tracked by git (disappearance risk; snapshot it).`);
    }
  }

  const blocking = rows.filter((r) => r.status === "RED" || (opts.strictStale && r.status === "STALE"));
  const counts = { PASS: 0, STALE: 0, RED: 0 };
  for (const r of rows) counts[r.status] = (counts[r.status] ?? 0) + 1;
  const rollupStatus = blocking.length ? "RED" : "PASS";
  if (rollupCriterion) {
    rows.push({
      id: rollupCriterion.id, lane: rollupCriterion.lane, category: "rollup",
      title: rollupCriterion.title, status: rollupStatus,
      detail: `${counts.PASS} PASS / ${counts.STALE} STALE / ${counts.RED} RED${opts.strictStale ? " (strict-stale)" : ""}`,
      closes: rollupCriterion.closes ?? "", drift: false,
    });
  }

  return {
    status: rollupStatus,
    mode: opts.run ? "run" : "read",
    strictStale: !!opts.strictStale,
    counts,
    rows,
    findings,
    post10Exclusions: contract.post10Exclusions ?? [],
    contractPath: contractRel,
    stamps,
    stampPath,
    burndown: contract.burndown,
  };
}

function writeOutputs(root, report) {
  writeTextWithEol(report.stampPath, JSON.stringify({ schema: "pdv.1-0.freshness-stamps.v2", updated: new Date().toISOString(), stamps: report.stamps.stamps }, null, 2) + "\n", "lf");

  const md = [
    "# PDV 1.0 End-State Burndown",
    "",
    "GENERATED by tools/pdv_1_0_endstate_gate.mjs - do not hand-edit.",
    "",
    `Overall: **${report.status}** (mode: ${report.mode}${report.strictStale ? ", strict-stale" : ""}). Contract: ${report.contractPath}.`,
    "",
    "| Criterion | Lane | Kind | Status | Detail | What closes it |",
    "|---|---|---|---|---|---|",
  ];
  for (const r of report.rows) {
    md.push(`| ${r.id} | ${r.lane} | ${r.category} | ${r.status} | ${asciiSafe(r.detail)} | ${asciiSafe(r.closes)} |`);
  }
  md.push("");
  if (report.findings.length) {
    md.push("## Drift findings", "");
    for (const f of report.findings) md.push(`- ${asciiSafe(f)}`);
    md.push("");
  }
  md.push("## Explicitly post-1.0 (not gating)", "");
  for (const x of report.post10Exclusions) md.push(`- **${x.id}** ${asciiSafe(x.title)} - ${asciiSafe(x.reason)}`);
  md.push("");

  if (report.burndown?.md) writeTextWithEol(path.join(root, report.burndown.md), md.join("\n") + "\n", "lf");
  if (report.burndown?.json) {
    const { stamps, stampPath, ...pub } = report;
    writeTextWithEol(path.join(root, report.burndown.json), JSON.stringify(pub, null, 2) + "\n", "lf");
  }
}

// ---------- self test ----------

function selfTest() {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-endstate-gate-"));
  const authoring = path.join(tmp, "references", "authoring");
  fs.mkdirSync(authoring, { recursive: true });
  const fx = (rel, content) => fs.writeFileSync(path.join(tmp, rel), content, "utf8");

  fx("references/authoring/fixture-ledger.md", "# fx\nVerdict: Pass - one\nVerdict: Pass - two\n");
  fx("references/authoring/fixture-ledger.json", JSON.stringify({ status: "PASS" }));
  fx("references/authoring/fixture-signoff.json", JSON.stringify({
    groups: { g1: { slots: { a: { status: "evidence-recorded" }, b: { status: "pending" } } } },
  }));
  fx("references/authoring/source-a.txt", "v1");

  const contract = {
    schema: "pdv.1-0.endstate-contract.v1",
    sharedSources: {},
    stampFile: "references/authoring/fixture-stamps.json",
    burndown: { md: "references/authoring/fixture-burndown.md", json: "references/authoring/fixture-burndown.json" },
    criteria: [
      { id: "F-MD", lane: "fx", category: "evidence-gate", title: "md", closes: "",
        evidence: { read: { kind: "ledger-md", ledger: "references/authoring/fixture-ledger.md", passRule: "md-contains", params: { pattern: "^Verdict: Pass", minCount: 2 } } },
        freshness: { sources: [], onDrift: "STALE" } },
      { id: "F-JSON", lane: "fx", category: "machine-gate", title: "json", closes: "",
        evidence: { read: { kind: "ledger-json", ledger: "references/authoring/fixture-ledger.json", passRule: "json-path-equals", params: { path: "status", equals: "PASS" } } },
        freshness: { sources: ["references/authoring/source-a.txt"], onDrift: "FAIL" } },
      { id: "F-HUMAN", lane: "fx", category: "evidence-gate", title: "human", closes: "",
        evidence: { read: { kind: "manual-slots", ledger: "references/authoring/fixture-signoff.json", passRule: "slots-all-pass", params: { group: "g1" } } },
        freshness: { sources: [], onDrift: "STALE" } },
      { id: "F-NOTBUILT", lane: "fx", category: "machine-gate", title: "nb", closes: "",
        evidence: { read: { kind: "not-built", params: { plannedEvidence: "future tool" } } },
        freshness: { sources: [], onDrift: "FAIL" } },
      { id: "F-STALE", lane: "fx", category: "evidence-gate", title: "stale", closes: "",
        evidence: { read: { kind: "ledger-json", ledger: "references/authoring/fixture-ledger.json", passRule: "json-path-equals", params: { path: "status", equals: "PASS" } } },
        freshness: { sources: ["references/authoring/source-a.txt"], onDrift: "STALE" } },
      { id: "F-ROLLUP", lane: "fx", category: "rollup", title: "rollup", closes: "",
        evidence: { read: { kind: "rollup", passRule: "rollup-all" } },
        freshness: { sources: [], onDrift: "FAIL" } },
    ],
    post10Exclusions: [{ id: "X-FX", title: "fixture exclusion", reason: "self-test" }],
  };
  fx("references/authoring/fixture-contract.json", JSON.stringify(contract));

  const asserts = [];
  const expect = (name, actual, expected) => asserts.push({ name, ok: actual === expected, actual, expected });
  const statusOf = (report, id) => report.rows.find((r) => r.id === id)?.status;

  // Pass 1: base statuses + stamps created.
  let report = evaluateContract(tmp, "references/authoring/fixture-contract.json", { run: false, strictStale: false, restamp: [] });
  writeOutputs(tmp, report);
  expect("F-MD PASS", statusOf(report, "F-MD"), "PASS");
  expect("F-JSON PASS", statusOf(report, "F-JSON"), "PASS");
  expect("F-HUMAN RED (pending slot)", statusOf(report, "F-HUMAN"), "RED");
  expect("F-NOTBUILT RED", statusOf(report, "F-NOTBUILT"), "RED");
  expect("rollup RED", statusOf(report, "F-ROLLUP"), "RED");
  expect("burndown md written", fs.existsSync(path.join(tmp, "references/authoring/fixture-burndown.md")), true);

  // Pass 2: drift the shared source; FAIL-doctrine goes RED, STALE-doctrine goes STALE.
  fx("references/authoring/source-a.txt", "v2-drifted\n");
  report = evaluateContract(tmp, "references/authoring/fixture-contract.json", { run: false, strictStale: false, restamp: [] });
  expect("F-JSON RED on drift (onDrift FAIL)", statusOf(report, "F-JSON"), "RED");
  expect("F-STALE STALE on drift (onDrift STALE)", statusOf(report, "F-STALE"), "STALE");

  // Pass 3: restamp clears the drift.
  report = evaluateContract(tmp, "references/authoring/fixture-contract.json", { run: false, strictStale: false, restamp: ["F-JSON", "F-STALE"] });
  writeOutputs(tmp, report);
  fx("references/authoring/source-a.txt", "v2-drifted\r\n");
  report = evaluateContract(tmp, "references/authoring/fixture-contract.json", { run: false, strictStale: false, restamp: [] });
  expect("F-JSON PASS after restamp and EOL-only change", statusOf(report, "F-JSON"), "PASS");
  expect("F-STALE PASS after restamp and EOL-only change", statusOf(report, "F-STALE"), "PASS");

  // Pass 4: strict-stale blocks STALE.
  fx("references/authoring/source-a.txt", "v3-drifted-again");
  report = evaluateContract(tmp, "references/authoring/fixture-contract.json", { run: false, strictStale: true, restamp: [] });
  expect("strict-stale counts STALE as blocking", report.status, "RED");

  fs.rmSync(tmp, { recursive: true, force: true });
  const failed = asserts.filter((a) => !a.ok);
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}${a.ok ? "" : ` (got ${JSON.stringify(a.actual)}, want ${JSON.stringify(a.expected)})`}`);
  console.log(failed.length ? `SELF-TEST FAIL (${failed.length}/${asserts.length})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed.length ? 1 : 0;
}

// ---------- entry ----------

try {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    console.log(usage());
  } else if (opts.selfTest) {
    selfTest();
  } else {
    const report = evaluateContract(PROJECT_ROOT, CONTRACT_REL, opts);
    writeOutputs(PROJECT_ROOT, report);
    if (opts.json) {
      const { stamps, stampPath, ...pub } = report;
      console.log(JSON.stringify(pub, null, 2));
    } else {
      console.log(`PDV 1.0 end-state gate: ${report.status} (mode: ${report.mode})`);
      console.log(`Counts: PASS=${report.counts.PASS} STALE=${report.counts.STALE} RED=${report.counts.RED}`);
      for (const r of report.rows) console.log(`[${r.status}] ${r.id} (${r.lane}): ${r.detail}`);
      for (const f of report.findings) console.log(`[DRIFT] ${f}`);
      console.log(`Burndown: ${report.burndown?.md}`);
    }
    process.exitCode = report.status === "PASS" ? 0 : 1;
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  console.error(usage());
  process.exitCode = 2;
}
