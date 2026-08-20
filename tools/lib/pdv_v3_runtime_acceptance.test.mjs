import assert from "node:assert/strict";
import test from "node:test";

import {
  evaluateGate,
  isRuntimeSensitive,
  recordSlot,
  scanLog,
  syncLedger,
  validateManifest,
} from "./pdv_v3_runtime_acceptance.mjs";

const manifest = {
  schema: "pdv.v3-runtime-acceptance-manifest.v1",
  revision: 1,
  profile: "Devotion Dev",
  enabledMod: "Devotion-V3Dev",
  runtimeSensitivePaths: ["live-source/", "native/"],
  logRules: { failPatterns: [{ id: "none", pattern: "None object[^\\r\\n]*Runtime", flags: "i" }] },
  gates: [{ id: "gate1", title: "Gate", requiresLog: false, cases: [{ id: "case_a", title: "Case A", slots: ["route", "surface"] }] }],
};

test("validates and synchronizes the manifest into a fail-closed ledger", () => {
  assert.deepEqual(validateManifest(manifest), []);
  const ledger = syncLedger(manifest, {});
  assert.equal(ledger.cases[0].slots.route.status, "pending");
  const report = evaluateGate(manifest, ledger, "gate1");
  assert.equal(report.status, "FAIL");
});

test("records explicit evidence without promoting sibling slots", () => {
  const ledger = syncLedger(manifest, { testedCommit: "abcdef1", startedAtLocal: "20/08/2026, 20:00:00" });
  recordSlot(ledger, { caseId: "case_a", slotId: "route", status: "pass", note: "Marker observed.", commit: "abcdef1" });
  assert.equal(ledger.cases[0].slots.route.status, "pass");
  assert.equal(ledger.cases[0].slots.surface.status, "pending");
});

test("passes only when every required slot has explicit evidence", () => {
  const ledger = syncLedger(manifest, { testedCommit: "abcdef1", startedAtLocal: "20/08/2026, 20:00:00" });
  for (const slotId of ["route", "surface"]) recordSlot(ledger, { caseId: "case_a", slotId, status: "pass", note: `${slotId} observed.`, commit: "abcdef1" });
  assert.equal(evaluateGate(manifest, ledger, "gate1").status, "PASS");
  assert.equal(evaluateGate(manifest, ledger, "gate1", { runtimeSensitiveChanges: ["live-source/PDV_MCM.psc"] }).status, "FAIL");
});

test("a gate that requires runtime logs fails when no log was scanned", () => {
  const requiringLog = structuredClone(manifest);
  requiringLog.gates[0].requiresLog = true;
  const ledger = syncLedger(requiringLog, { testedCommit: "abcdef1", startedAtLocal: "20/08/2026, 20:00:00" });
  for (const slotId of ["route", "surface"]) recordSlot(ledger, { caseId: "case_a", slotId, status: "pass", note: `${slotId} observed.`, commit: "abcdef1" });
  assert.equal(evaluateGate(requiringLog, ledger, "gate1").status, "FAIL");
  assert.equal(evaluateGate(requiringLog, ledger, "gate1", { logReports: [{ matches: [], stale: false }] }).status, "PASS");
});

test("scans targeted log failures and rejects stale logs", () => {
  const clean = scanLog("[PDV] startup complete", manifest.logRules, { startedAt: "2026-08-20T10:00:00Z", modifiedAt: new Date("2026-08-20T10:01:00Z") });
  assert.equal(clean.status, "PASS");
  const bad = scanLog("Cannot call on a None object in LedgerRuntime", manifest.logRules, { startedAt: "2026-08-20T10:00:00Z", modifiedAt: new Date("2026-08-20T09:00:00Z") });
  assert.equal(bad.status, "FAIL");
  assert.equal(bad.matches.length, 1);
  assert.equal(bad.stale, true);
});

test("matches runtime-sensitive paths by exact file or directory prefix", () => {
  assert.equal(isRuntimeSensitive("live-source/Scripts/Source/PDV_MCM.psc", manifest.runtimeSensitivePaths), true);
  assert.equal(isRuntimeSensitive("references/authoring/runbook.md", manifest.runtimeSensitivePaths), false);
});
