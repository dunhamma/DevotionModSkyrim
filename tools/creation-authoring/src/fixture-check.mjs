import fs from "node:fs";
import path from "node:path";
import { loadManifest } from "./manifest.mjs";
import { createPlan } from "./planner.mjs";
import { verifyManifest } from "./verifier.mjs";

export function checkFixtureDirectory(directory, profile, readback, options = {}) {
  const fixtureDir = path.resolve(directory);
  const files = fs.readdirSync(fixtureDir)
    .filter((file) => file.endsWith(".creation-authoring.json"))
    .sort();
  const results = files.map((file) => checkFixture(path.join(fixtureDir, file), profile, readback, options));
  const summary = summarize(results);
  return {
    schema: "creation-authoring.fixture-check.v1",
    fixtureDir: options.displayDirectory || directory,
    mode: options.allowUnprovenCk ? "discovery_allow_unproven_ck" : "strict_readiness",
    status: summary.FAIL ? "FAIL" : "PASS",
    summary,
    results
  };
}

export function checkFixture(filePath, profile, readback, options = {}) {
  const manifest = loadManifest(filePath, profile);
  const plan = createPlan(manifest, profile, {
    allowUnprovenCk: Boolean(options.allowUnprovenCk)
  });
  const verify = verifyManifest(manifest, profile, readback);
  const failures = [];

  if (plan.summary.abort) {
    failures.push(`Plan has ${plan.summary.abort} abort operation(s).`);
  }
  if (plan.summary.manual) {
    failures.push(`Plan has ${plan.summary.manual} manual operation(s).`);
  }
  if (!plan.summary.ready) {
    failures.push("Plan has no ready operation.");
  }
  if (verify.summary.FAIL || verify.summary.TODO) {
    failures.push(`Verifier summary is PASS=${verify.summary.PASS} FAIL=${verify.summary.FAIL} TODO=${verify.summary.TODO}.`);
  }

  return {
    fixture: normalizePath(filePath),
    project: manifest.project,
    status: failures.length ? "FAIL" : "PASS",
    failures,
    planSummary: plan.summary,
    verifySummary: verify.summary,
    operations: plan.operations.map((item) => ({
      id: item.operation.id,
      kind: item.operation.kind,
      target: item.operation.target,
      recordFamily: item.operation.recordFamily,
      capabilityTier: item.capabilityTier,
      backend: item.backend,
      status: item.status
    }))
  };
}

function summarize(results) {
  return results.reduce((summary, result) => {
    summary.total += 1;
    summary[result.status] = (summary[result.status] || 0) + 1;
    return summary;
  }, { total: 0, PASS: 0, FAIL: 0 });
}

function normalizePath(filePath) {
  return filePath.replaceAll("\\", "/");
}
