#!/usr/bin/env node

// Regression gate for issue #61. A documented flag must either be consumed by
// the tool or removed from the active documentation and its KNOWN_FLAGS set.
// This is intentionally scoped to the fourteen audited contracts; it does not
// claim that an unreviewed tool elsewhere in the repo has a complete interface.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const IMPLEMENTED = [
  ["pdv_refresh_seq", "--check"],
  ["pdv_quest_matrix_compile", "--json"],
  ["pdv_cumulative_rebalance", "--dry"],
  ["pdv_daedric_beta_gate", "--strict"],
  ["pdv_signal_floor_smoke_gate", "--check"],
  ["pdv_antifarm_sweep_audit", "--json"],
  ["pdv_ledger_coverage_audit", "--json"],
  ["pdv_prisma_ui_audit", "--json"],
  ["pdv_requiem_penalty_audit", "--json"],
  ["pdv_signal_floor_audit", "--json"],
  ["pdv_specced_minus_audit", "--json"],
];

const RETIRED = [
  ["pdv_verify", "--run", /pdv_verify\.mjs\s*\(via --run stamp\)/i],
  ["pdv_content_verify", "--run", /pdv_content_verify\.mjs\s*\(via --run stamp\)/i],
  ["pdv_matrix_runtime_preflight", "--expected-arr", /pdv_matrix_runtime_preflight\.mjs[^\r\n]*--expected-arr/i],
];

const failures = [];
const passes = [];

for (const [tool, flag] of IMPLEMENTED) {
  const relative = `tools/${tool}.mjs`;
  const source = fs.readFileSync(path.join(ROOT, relative), "utf8");
  const code = stripComments(source);
  const known = parseKnownFlags(code);
  if (!known.has(flag)) {
    failures.push(`${relative}: ${flag} is not declared in KNOWN_FLAGS`);
    continue;
  }
  if (!hasSemanticRead(code, flag)) {
    failures.push(`${relative}: ${flag} is accepted but has no semantic read`);
    continue;
  }
  passes.push(`${relative}: ${flag} is declared and consumed`);
}

const docs = trackedActiveDocs();
for (const [tool, flag, stalePattern] of RETIRED) {
  const relative = `tools/${tool}.mjs`;
  const source = fs.readFileSync(path.join(ROOT, relative), "utf8");
  const known = parseKnownFlags(stripComments(source));
  if (known.has(flag)) failures.push(`${relative}: retired ${flag} remains in KNOWN_FLAGS`);

  const hits = docs.filter(({ text }) => stalePattern.test(text));
  if (hits.length) {
    failures.push(`${tool}: stale ${flag} documentation remains in ${hits.map((hit) => hit.file).join(", ")}`);
  } else {
    passes.push(`${tool}: retired ${flag} is absent from active tool contracts`);
  }
}

const report = {
  status: failures.length ? "FAIL" : "PASS",
  contracts: IMPLEMENTED.length + RETIRED.length,
  passes,
  failures,
};

console.log(JSON.stringify(report, null, 2));
process.exitCode = failures.length ? 1 : 0;

function parseKnownFlags(source) {
  const match = source.match(/const\s+KNOWN_FLAGS\s*=\s*new\s+Set\s*\(\s*\[([\s\S]*?)\]\s*\)/m);
  if (!match) return new Set();
  return new Set([...match[1].matchAll(/["'](--[a-z0-9-]+)["']/gi)].map((entry) => entry[1]));
}

function hasSemanticRead(source, flag) {
  const escaped = escapeRegex(flag);
  const patterns = [
    new RegExp(`(?:process\\.argv|args|argv)\\.(?:includes|has|indexOf)\\(\\s*["']${escaped}["']\\s*\\)`),
    new RegExp(`(?:arg|value)\\s*===\\s*["']${escaped}["']`),
    new RegExp(`["']${escaped}["']\\s*===\\s*(?:arg|value)`),
    new RegExp(`getArg\\(\\s*["']${escaped}["']\\s*\\)`),
  ];
  return patterns.some((pattern) => pattern.test(source));
}

function stripComments(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/^\s*\/\/.*$/gm, "");
}

function trackedActiveDocs() {
  const output = execFileSync("git", ["ls-files", "*.md", "*.json"], {
    cwd: ROOT,
    encoding: "utf8",
    windowsHide: true,
  });
  return output
    .split(/\r?\n/)
    .filter(Boolean)
    .filter((file) => !file.startsWith("archive/") && !file.startsWith("_retired/"))
    .map((file) => ({ file, text: fs.readFileSync(path.join(ROOT, file), "utf8") }));
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
