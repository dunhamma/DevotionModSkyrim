#!/usr/bin/env node
/*
 * Verifies that the Papyrus compiler's public --list surface exactly matches
 * the shipped script inventory in PDV_ReleasePayload.manifest.json.
 *
 * The release manifest is the authority. This gate prevents a clean checkout
 * from silently omitting a shipped PSC/PEX pair from --all/default rebuilds.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, {
  toolName: "pdv_compile_inventory_audit",
});

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANIFEST_PATH = path.join(
  ROOT,
  "references",
  "authoring",
  "PDV_ReleasePayload.manifest.json",
);
const COMPILER_PATH = path.join(ROOT, "tools", "pdv_compile.mjs");
const COMPILE_SOURCE =
  process.env.PDV_COMPILE_SOURCE_ROOT ||
  path.join("D:/Wabbajack/modlists/Anvil", "mods", "Devotion", "Scripts", "Source");
const args = new Set(process.argv.slice(2));
const JSON_OUTPUT = args.has("--json");

function add(findings, ok, id, detail) {
  findings.push({ status: ok ? "PASS" : "FAIL", id, detail });
}

export function evaluateInventory({ manifest, compilerScripts, sourceRoot }) {
  const findings = [];
  const sourceScripts = Array.isArray(manifest?.sourceScripts) ? manifest.sourceScripts : [];
  const duplicates = sourceScripts.filter(
    (scriptName, index) => sourceScripts.indexOf(scriptName) !== index,
  );
  const invalidNames = sourceScripts.filter(
    (scriptName) =>
      typeof scriptName !== "string" ||
      (!/^PDV_[A-Za-z0-9_]+$/.test(scriptName) && scriptName !== "TempleBlessingScript"),
  );
  const missingFromCompiler = sourceScripts.filter(
    (scriptName) => !compilerScripts.includes(scriptName),
  );
  const extraInCompiler = compilerScripts.filter(
    (scriptName) => !sourceScripts.includes(scriptName),
  );
  const missingSource = sourceScripts.filter(
    (scriptName) => !fs.existsSync(path.join(sourceRoot, `${scriptName}.psc`)),
  );
  const expectedPex = sourceScripts.map((scriptName) => `Scripts/${scriptName}.pex`);
  const manifestedPex = Array.isArray(manifest?.fixedEntries)
    ? manifest.fixedEntries.filter((entry) => /^Scripts\/[^/]+\.pex$/i.test(entry))
    : [];
  const duplicatePexEntries = manifestedPex.filter(
    (entry, index) => manifestedPex.indexOf(entry) !== index,
  );
  const missingPexEntries = expectedPex.filter((entry) => !manifestedPex.includes(entry));
  const extraPexEntries = manifestedPex.filter((entry) => !expectedPex.includes(entry));

  add(
    findings,
    Number.isInteger(manifest?.scriptPairCount) &&
      manifest.scriptPairCount === sourceScripts.length,
    "manifest.count",
    `Manifest declares ${manifest?.scriptPairCount ?? "no"} pairs and lists ${sourceScripts.length} source scripts.`,
  );
  add(
    findings,
    duplicates.length === 0,
    "manifest.unique",
    duplicates.length
      ? `Duplicate source scripts: ${[...new Set(duplicates)].join(", ")}.`
      : "Manifest source-script names are unique.",
  );
  add(
    findings,
    invalidNames.length === 0,
    "manifest.names",
    invalidNames.length
      ? `Invalid source-script names: ${invalidNames.join(", ")}.`
      : "Manifest source-script names are valid.",
  );
  add(
    findings,
    missingSource.length === 0,
    "manifest.sources-exist",
    missingSource.length
      ? `Configured compile source missing: ${missingSource.join(", ")}.`
      : "Every manifested script exists in the configured compile source root.",
  );
  add(
    findings,
    missingPexEntries.length === 0 &&
      extraPexEntries.length === 0 &&
      duplicatePexEntries.length === 0,
    "manifest.exact-pex-pairs",
    missingPexEntries.length || extraPexEntries.length || duplicatePexEntries.length
      ? `PEX mismatch; missing: ${missingPexEntries.join(", ") || "none"}; extra: ${extraPexEntries.join(", ") || "none"}; duplicates: ${[...new Set(duplicatePexEntries)].join(", ") || "none"}.`
      : "Manifest fixed entries contain exactly one matching PEX for every source script.",
  );
  add(
    findings,
    missingFromCompiler.length === 0 && extraInCompiler.length === 0,
    "compiler.exact-inventory",
    missingFromCompiler.length || extraInCompiler.length
      ? `Compiler mismatch; missing: ${missingFromCompiler.join(", ") || "none"}; extra: ${extraInCompiler.join(", ") || "none"}.`
      : "Compiler --list exactly matches the release-manifest inventory.",
  );
  add(
    findings,
    compilerScripts.length === sourceScripts.length,
    "compiler.count",
    `Compiler lists ${compilerScripts.length}; manifest lists ${sourceScripts.length}.`,
  );

  return {
    status: findings.some((finding) => finding.status === "FAIL") ? "FAIL" : "PASS",
    sourceRoot,
    proofBoundary: "static compile-inventory contract only; no Papyrus bytecode was built",
    findings,
  };
}

function readCompilerInventory() {
  const result = spawnSync(process.execPath, [COMPILER_PATH, "--list", "--json"], {
    cwd: ROOT,
    encoding: "utf8",
    windowsHide: true,
    env: {
      ...process.env,
      PDV_COMPILE_OUTPUT_ROOT: path.join(ROOT, ".pdv-inventory-output-not-created"),
    },
  });
  if (result.error || result.status !== 0) {
    throw new Error(
      result.error?.message || result.stderr.trim() || `pdv_compile exited ${result.status}`,
    );
  }
  const payload = JSON.parse(result.stdout);
  return payload.scripts.map((row) => row.script);
}

function selfTest() {
  const fixtureRoot = path.join(ROOT, "tools", "fixtures", "pdv-compile-inventory");
  const sourceExists = (scriptName) =>
    fs.existsSync(path.join(fixtureRoot, `${scriptName}.psc`));
  const manifest = {
    scriptPairCount: 2,
    sourceScripts: ["PDV_A", "PDV_B"],
    fixedEntries: ["Scripts/PDV_A.pex", "Scripts/PDV_B.pex"],
  };
  const exact = evaluateInventory({
    manifest,
    compilerScripts: ["PDV_A", "PDV_B"],
    sourceRoot: fixtureRoot,
  });
  const omittedCompilerScript = evaluateInventory({
    manifest,
    compilerScripts: ["PDV_A"],
    sourceRoot: fixtureRoot,
  });
  const missingPexManifest = {
    ...manifest,
    fixedEntries: ["Scripts/PDV_A.pex"],
  };
  const omittedPex = evaluateInventory({
    manifest: missingPexManifest,
    compilerScripts: ["PDV_A", "PDV_B"],
    sourceRoot: fixtureRoot,
  });
  const duplicatePex = evaluateInventory({
    manifest: {
      ...manifest,
      fixedEntries: [...manifest.fixedEntries, "Scripts/PDV_A.pex"],
    },
    compilerScripts: ["PDV_A", "PDV_B"],
    sourceRoot: fixtureRoot,
  });
  const passed =
    sourceExists("PDV_A") &&
    sourceExists("PDV_B") &&
    exact.status === "PASS" &&
    omittedCompilerScript.status === "FAIL" &&
    omittedPex.status === "FAIL" &&
    duplicatePex.status === "FAIL";
  return {
    status: passed ? "PASS" : "FAIL",
    cases: [
      { name: "exact inventory passes", status: exact.status },
      {
        name: "omitted compiler script fails",
        status: omittedCompilerScript.status === "FAIL" ? "PASS" : "FAIL",
      },
      {
        name: "omitted PEX pair fails",
        status: omittedPex.status === "FAIL" ? "PASS" : "FAIL",
      },
      {
        name: "duplicate PEX pair fails",
        status: duplicatePex.status === "FAIL" ? "PASS" : "FAIL",
      },
    ],
  };
}

function printReport(report) {
  if (JSON_OUTPUT) {
    console.log(JSON.stringify(report, null, 2));
    return;
  }
  if (report.sourceRoot) console.log(`Compile source root: ${report.sourceRoot}`);
  for (const finding of report.findings ?? report.cases ?? []) {
    console.log(
      `[${finding.status}] ${finding.id ?? finding.name}: ${finding.detail ?? ""}`.trim(),
    );
  }
  console.log(`Summary: ${report.status}`);
  if (report.proofBoundary) console.log(`Proof boundary: ${report.proofBoundary}`);
}

try {
  const report = args.has("--self-test")
    ? selfTest()
    : evaluateInventory({
        manifest: JSON.parse(fs.readFileSync(MANIFEST_PATH, "utf8")),
        compilerScripts: readCompilerInventory(),
        sourceRoot: COMPILE_SOURCE,
      });
  printReport(report);
  process.exitCode = report.status === "PASS" ? 0 : 1;
} catch (error) {
  const report = { status: "FAIL", error: error.message };
  if (JSON_OUTPUT) console.log(JSON.stringify(report, null, 2));
  else console.error(`PDV compile inventory audit failed: ${error.message}`);
  process.exitCode = 2;
}
