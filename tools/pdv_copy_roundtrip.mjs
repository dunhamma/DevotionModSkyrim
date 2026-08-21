#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { assertKnownFlags, makeFlagReader } from "./lib/pdv_cli.mjs";
import { stableStringify } from "./lib/pdv_copy_census.mjs";
import { importProseExchange, renderProseExchangeCsv } from "./lib/pdv_copy_flow.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const GENERATED = path.join(ROOT, "generated", "pdv-copy-census");
const argv = process.argv.slice(2);
const knownFlags = new Set(["--export", "--import", "--output", "--help"]);
assertKnownFlags(argv, knownFlags, {
  toolName: "pdv_copy_roundtrip",
  onHelp: () => {
    console.log("Usage:");
    console.log("  node tools/pdv_copy_roundtrip.mjs --export PATH");
    console.log("  node tools/pdv_copy_roundtrip.mjs --import EDITED.csv --output REVIEW_PLAN.json");
    console.log("Export writes an Excel-friendly CSV. Import validates owner edits and writes a review-only plan; it never edits source or ESP files.");
  },
});
const flags = makeFlagReader(argv);

try {
  const censusPath = path.join(GENERATED, "PDV_CopyCensus.json");
  const flowPath = path.join(GENERATED, "PDV_CopyFlowAssignments.json");
  if (!fs.existsSync(censusPath) || !fs.existsSync(flowPath)) {
    throw new Error("generated census/flow reports are missing; run node tools/pdv_copy_census.mjs first");
  }
  const census = JSON.parse(fs.readFileSync(censusPath, "utf8"));
  const flow = JSON.parse(fs.readFileSync(flowPath, "utf8"));
  flow.byCopyId = new Map(flow.assignments.map((row) => [row.copyId, row]));
  const exportPath = flags.value("--export");
  const importPath = flags.value("--import");
  if (Boolean(exportPath) === Boolean(importPath)) throw new Error("choose exactly one of --export or --import");
  if (exportPath) {
    const target = path.resolve(exportPath);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, renderProseExchangeCsv(census, flow), "utf8");
    console.log(`PASS pdv_copy_roundtrip: exported ${census.rows.length} rows to ${target}`);
  } else {
    const outputPath = flags.value("--output");
    if (!outputPath) throw new Error("--import requires --output REVIEW_PLAN.json");
    const plan = importProseExchange(fs.readFileSync(path.resolve(importPath), "utf8"), census, flow);
    const target = path.resolve(outputPath);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, stableStringify(plan), "utf8");
    console.log(`PASS pdv_copy_roundtrip: reviewed=${plan.summary.reviewedRows} replacements=${plan.summary.replacements} warnings=${plan.summary.warnings} output=${target}`);
  }
} catch (error) {
  console.error(`FAIL pdv_copy_roundtrip: ${error.message}`);
  process.exit(1);
}
