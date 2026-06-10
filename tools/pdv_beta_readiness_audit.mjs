#!/usr/bin/env node
/*
 * Read-only beta-readiness closure audit for PDV.
 *
 * This is intentionally broader than the record/readback verifiers. It checks
 * that a "scaled out" claim has an authority row, a readback gate, runtime
 * route evidence, and manual/placement evidence without collapsing those proof
 * buckets into one another.
 *
 * Usage: node tools/pdv_beta_readiness_audit.mjs [--strict] [--json]
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  PHASE20_EXPECTED_RACES,
  PHASE20_REQUIRED_COVERAGE_COLUMNS,
  PHASE20_SKYRIM_DAEDRIC_PRINCES,
  verifyPhase21RosterCoverage,
} from "./lib/pdv-roster-coverage.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const AUTHORING = path.join(PROJECT_ROOT, "references", "authoring");

const args = new Set(process.argv.slice(2));
const JSON_OUTPUT = args.has("--json");
const STRICT = args.has("--strict");

const COVERAGE_MATRIX = rel("references/authoring/PDV_DeityCoverageMatrix.json");
const PAIRED_EQUITY_REPORT = rel("references/authoring/PDV_PairedDeityEquityAudit.md");
const P2_RECEIVER_MANIFEST = rel("references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json");
const SOURCE_FILL_LEDGER = rel("references/authoring/PDV_Phase20_SourceFillApprovalLedger.json");
const NO_IN_GAME_GATES = rel("references/authoring/PDV_Phase20_NoInGameProof_Gates.json");
const MANUAL_LEDGER = rel("references/authoring/PDV_Phase20_ManualEvidenceLedger.json");
const DAEDRIC_LEDGER = rel("references/authoring/PDV_DaedricRuntimeEvidenceLedger.json");

const RACE_SPEC_FILES = PHASE20_EXPECTED_RACES.map((race) => ({
  race,
  file: rel(`references/authoring/PDV_${race}RewardRecords.spec.json`),
}));

const BETA_PACKET_CHECKS = [
  { label: "Expected build", re: /##\s+Expected Build/i },
  { label: "Edge build", re: /##\s+Edge Build/i },
  { label: "Wrong-origin check", re: /Wrong-Origin/i },
  { label: "Generic-source check", re: /Generic/i },
  { label: "Evidence return checklist", re: /Evidence To Bring Back/i },
  { label: "Survey/status evidence", re: /Survey\/status|Survey status|Survey/i },
  { label: "Reward or stack evidence", re: /Reward\/stack|stack snapshot|Active Effects/i },
];

const MANUAL_PASS_STATUSES = new Set(["evidence-recorded", "not-applicable"]);
const DAEDRIC_PASS_STATUSES = new Set(["pass", "conditional", "not_required"]);
const DAEDRIC_OVERALL_READY = new Set(["pass", "conditional"]);

class BetaReadinessAudit {
  constructor({ strict }) {
    this.strict = strict;
    this.findings = [];
    this.blockers = [];
    this.runtimeManualPending = false;
    this.fullDaedricPending = false;
    this.rowAuthorityGap = false;
  }

  add(status, bucket, check, detail, filePath = null) {
    const finding = {
      status,
      bucket,
      check,
      detail,
      path: filePath ? displayPath(filePath) : null,
    };
    this.findings.push(finding);
    if (status === "FAIL") {
      this.blockers.push(finding);
    }
  }

  pass(bucket, check, detail, filePath = null) {
    this.add("PASS", bucket, check, detail, filePath);
  }

  info(bucket, check, detail, filePath = null) {
    this.add("INFO", bucket, check, detail, filePath);
  }

  warn(bucket, check, detail, filePath = null) {
    this.add("WARN", bucket, check, detail, filePath);
  }

  fail(bucket, check, detail, filePath = null) {
    this.add("FAIL", bucket, check, detail, filePath);
  }

  run() {
    this.verifyCoverageAuthority();
    this.verifyRosterSummary();
    this.verifyPairedDeityEquity();
    this.verifyRewardSpecs();
    this.verifyP2ReceiversAndSourceFill();
    this.verifyNoInGameGateContracts();
    this.verifyManualEvidenceLedger();
    this.verifyBetaPackets();
    this.verifyDaedricRuntimeLedger();
    this.verifyReleaseClaimBoundary();
    return this.result();
  }

  result() {
    const counts = {};
    for (const finding of this.findings) {
      counts[finding.status] = (counts[finding.status] || 0) + 1;
    }
    const hasFail = (counts.FAIL || 0) > 0;
    const verdict = hasFail
      ? "NOT_BETA_READY"
      : this.strict
        ? "STRICT_GATE_PASS"
        : "AUDIT_PASS_WITH_WARNINGS_ALLOWED";
    return {
      schema: "pdv.beta-readiness-closure-audit.v1",
      strict: this.strict,
      verdict,
      counts,
      blockers: this.blockers,
      findings: this.findings,
    };
  }

  verifyCoverageAuthority() {
    const manifest = this.readJson(COVERAGE_MATRIX, "authority", "Deity coverage matrix");
    if (!manifest) return;

    const rowArrays = ["coverageRows", "rows", "entries", "matrixRows", "coverageEntries"]
      .map((key) => ({ key, value: manifest[key] }))
      .filter((entry) => Array.isArray(entry.value));

    if (!rowArrays.length) {
      this.rowAuthorityGap = true;
      this.fail(
        "authority",
        "Row-level race/deity coverage authority",
        "PDV_DeityCoverageMatrix.json defines required fields and summary matrices, but has no row-level coverage array to machine-check every race/deity and race/Prince pairing.",
        COVERAGE_MATRIX,
      );
      return;
    }

    const rows = rowArrays[0].value;
    const missingColumns = [];
    rows.forEach((row, index) => {
      for (const column of PHASE20_REQUIRED_COVERAGE_COLUMNS) {
        if (!hasText(row[column])) {
          missingColumns.push(`row ${index + 1}.${column}`);
        }
      }
    });

    if (missingColumns.length) {
      this.fail(
        "authority",
        "Row-level race/deity coverage authority",
        `Missing required fields: ${clipList(missingColumns)}.`,
        COVERAGE_MATRIX,
      );
    } else {
      this.pass(
        "authority",
        "Row-level race/deity coverage authority",
        `${rows.length} row-level coverage row(s) include the required beta-readiness columns.`,
        COVERAGE_MATRIX,
      );
    }
  }

  verifyRosterSummary() {
    for (const finding of verifyPhase21RosterCoverage(PROJECT_ROOT, { strictContentReady: true })) {
      this.add(finding.status, "authority", finding.check, finding.detail, finding.path);
    }
  }

  verifyPairedDeityEquity() {
    if (!fs.existsSync(PAIRED_EQUITY_REPORT)) {
      this.fail("authority", "Paired-deity equity audit", "Generated paired-deity audit report is missing.", PAIRED_EQUITY_REPORT);
      return;
    }
    const text = fs.readFileSync(PAIRED_EQUITY_REPORT, "utf8");
    const statusLine = text.split(/\r?\n/).find((line) => line.startsWith("Status:")) || "";
    const statusPass = /Status:\s*PASS/i.test(statusLine);
    const openGapsZero = /open cluster gaps:\s*0/i.test(statusLine);
    const errorsZero = /errors:\s*0/i.test(statusLine);
    if (statusPass && openGapsZero && errorsZero) {
      this.pass("authority", "Paired-deity equity audit", statusLine.trim(), PAIRED_EQUITY_REPORT);
    } else {
      this.fail("authority", "Paired-deity equity audit", `Expected PASS with 0 open gaps and 0 errors; found '${statusLine.trim() || "no status line"}'.`, PAIRED_EQUITY_REPORT);
    }

    const warningsMatch = statusLine.match(/warnings:\s*(\d+)/i);
    const warnings = warningsMatch ? Number(warningsMatch[1]) : 0;
    if (warnings > 0) {
      this.warn("authority", "Paired-deity warning count", `${warnings} warning(s) remain; these do not block the generated PASS, but should be reviewed before broader balance claims.`, PAIRED_EQUITY_REPORT);
    }
  }

  verifyRewardSpecs() {
    const missing = [];
    const parseErrors = [];
    for (const { race, file } of RACE_SPEC_FILES) {
      if (!fs.existsSync(file)) {
        missing.push(race);
        continue;
      }
      try {
        JSON.parse(fs.readFileSync(file, "utf8"));
      } catch (error) {
        parseErrors.push(`${race}: ${error.message}`);
      }
    }
    if (missing.length || parseErrors.length) {
      this.fail(
        "authority",
        "Per-race reward spec presence",
        `Missing specs: ${missing.join(", ") || "none"}; parse errors: ${parseErrors.join("; ") || "none"}.`,
        AUTHORING,
      );
    } else {
      this.pass("authority", "Per-race reward spec presence", "All ten race reward spec JSON files exist and parse.", AUTHORING);
    }
  }

  verifyP2ReceiversAndSourceFill() {
    const manifest = this.readJson(P2_RECEIVER_MANIFEST, "readback", "P2 receiver manifest");
    const ledger = this.readJson(SOURCE_FILL_LEDGER, "readback", "Source-fill approval ledger");
    if (!manifest || !ledger) return;

    this.verifyP2SourceProperties(manifest);
    this.verifySourceFillLedgerRows(ledger);
    this.verifyQuestStageGateDrift(manifest, ledger);

    if (ledger.liveFillReadback?.status === "PASS") {
      this.pass(
        "readback",
        "P2 source-fill readback",
        `${ledger.liveFillReadback.filledEntryCount || 0} filled entries across ${ledger.liveFillReadback.formListGroups || 0} FormList group(s).`,
        SOURCE_FILL_LEDGER,
      );
    } else {
      this.fail("readback", "P2 source-fill readback", "liveFillReadback.status is not PASS.", SOURCE_FILL_LEDGER);
    }

    if (hasText(ledger.runtimeRouteProof?.status) && hasText(ledger.runtimeRouteProof?.boundary)) {
      this.pass(
        "runtime-route",
        "P2 route proof boundary",
        `${ledger.runtimeRouteProof.status}; boundary remains '${ledger.runtimeRouteProof.boundary}'.`,
        SOURCE_FILL_LEDGER,
      );
    } else {
      this.fail("runtime-route", "P2 route proof boundary", "Runtime route proof status or proof-boundary text is missing.", SOURCE_FILL_LEDGER);
    }
  }

  verifyP2SourceProperties(manifest) {
    const rows = Array.isArray(manifest.sourceProperties) ? manifest.sourceProperties : [];
    const missingFields = [];
    const races = new Set();
    const requiredFields = ["property", "race", "sourceKinds", "route", "acceptedUse", "rejectedUse"];

    rows.forEach((row, index) => {
      if (hasText(row.race)) races.add(row.race);
      for (const field of requiredFields) {
        if (field === "sourceKinds") {
          if (!Array.isArray(row.sourceKinds) || row.sourceKinds.length === 0) missingFields.push(`sourceProperties[${index}].sourceKinds`);
        } else if (!hasText(row[field])) {
          missingFields.push(`sourceProperties[${index}].${field}`);
        }
      }
    });

    const missingRaces = PHASE20_EXPECTED_RACES.filter((race) => !races.has(race));
    if (missingFields.length || missingRaces.length) {
      this.fail(
        "authority",
        "P2 immersive receiver contract shape",
        `Missing fields: ${clipList(missingFields) || "none"}; missing races: ${missingRaces.join(", ") || "none"}.`,
        P2_RECEIVER_MANIFEST,
      );
    } else {
      this.pass(
        "authority",
        "P2 immersive receiver contract shape",
        `${rows.length} receiver contract(s) cover all ten races with accepted/rejected source boundaries.`,
        P2_RECEIVER_MANIFEST,
      );
    }
  }

  verifySourceFillLedgerRows(ledger) {
    const rows = Array.isArray(ledger.approvedLiveFillGroups) ? ledger.approvedLiveFillGroups : [];
    const requiredFields = [
      "race",
      "receiver",
      "routeFamily",
      "sourceKind",
      "semanticVerdict",
      "implementationStatus",
      "acceptedContext",
      "rejectedContext",
      "duplicateGuard",
    ];
    const missing = [];
    rows.forEach((row, index) => {
      for (const field of requiredFields) {
        if (!hasText(row[field])) missing.push(`approvedLiveFillGroups[${index}].${field}`);
      }
      if (!Array.isArray(row.sources) || row.sources.length === 0) {
        missing.push(`approvedLiveFillGroups[${index}].sources`);
      }
      if (row.sourceKind === "quest-stage") {
        for (const source of row.sources || []) {
          if (!Array.isArray(source.approvedStages) || source.approvedStages.length === 0) {
            missing.push(`approvedLiveFillGroups[${index}].sources.approvedStages`);
          }
        }
      }
    });

    if (missing.length) {
      this.fail("authority", "Approved source-fill row shape", `Missing required source-fill evidence fields: ${clipList(missing)}.`, SOURCE_FILL_LEDGER);
    } else {
      this.pass("authority", "Approved source-fill row shape", `${rows.length} approved live-fill group(s) name accepted/rejected contexts and duplicate guards.`, SOURCE_FILL_LEDGER);
    }
  }

  verifyQuestStageGateDrift(manifest, ledger) {
    const approvedQuestStageRows = (ledger.approvedLiveFillGroups || []).filter((row) => row.sourceKind === "quest-stage");
    const manifestCount = Number(manifest.questStageGate?.approvedQuestStageEntries || 0);
    if (manifestCount !== approvedQuestStageRows.length) {
      this.fail(
        "authority",
        "P2 quest-stage gate drift",
        `Receiver manifest declares ${manifestCount} approved quest-stage entr${manifestCount === 1 ? "y" : "ies"}, but source-fill ledger has ${approvedQuestStageRows.length}. Update the manifest gate count/status or move the ledger row back to blocked.`,
        P2_RECEIVER_MANIFEST,
      );
    } else {
      this.pass(
        "authority",
        "P2 quest-stage gate drift",
        `${manifestCount} approved quest-stage entr${manifestCount === 1 ? "y" : "ies"} match between manifest and source-fill ledger.`,
        P2_RECEIVER_MANIFEST,
      );
    }
  }

  verifyNoInGameGateContracts() {
    const gates = this.readJson(NO_IN_GAME_GATES, "authority", "No-in-game proof gates");
    if (!gates) return;

    const rules = gates.rules || {};
    if (rules.externalTestingAllowed === false) {
      this.pass("claim", "External testing gate", "externalTestingAllowed is false while runtime/manual proof is deferred.", NO_IN_GAME_GATES);
    } else {
      this.fail("claim", "External testing gate", "externalTestingAllowed must remain false until runtime/manual evidence closes.", NO_IN_GAME_GATES);
    }

    const races = gates.races || {};
    const missingRaces = PHASE20_EXPECTED_RACES.filter((race) => !races[race]);
    if (missingRaces.length) {
      this.fail("authority", "No-in-game race gate coverage", `Missing race gate entries: ${missingRaces.join(", ")}.`, NO_IN_GAME_GATES);
      return;
    }
    this.pass("authority", "No-in-game race gate coverage", "All ten race gate entries exist.", NO_IN_GAME_GATES);

    const requiredFields = Array.isArray(rules.requiredImmersiveHookContractFields)
      ? rules.requiredImmersiveHookContractFields
      : [];
    const minimumContracts = Number(rules.minimumImmersiveHookContracts || 0);
    const contractGaps = [];
    for (const race of PHASE20_EXPECTED_RACES) {
      const contracts = Array.isArray(races[race].immersiveHookContracts) ? races[race].immersiveHookContracts : [];
      if (contracts.length < minimumContracts) {
        contractGaps.push(`${race}: ${contracts.length}/${minimumContracts} contracts`);
      }
      contracts.forEach((contract, index) => {
        for (const field of requiredFields) {
          if (typeof contract[field] === "boolean") continue;
          if (!hasText(contract[field])) contractGaps.push(`${race}.immersiveHookContracts[${index}].${field}`);
        }
      });
    }

    if (contractGaps.length) {
      this.fail("authority", "Immersive hook contract completeness", `Contract gaps: ${clipList(contractGaps)}.`, NO_IN_GAME_GATES);
    } else {
      this.pass("authority", "Immersive hook contract completeness", `All race hook contracts satisfy the ${requiredFields.length}-field contract shape.`, NO_IN_GAME_GATES);
    }
  }

  verifyManualEvidenceLedger() {
    const ledger = this.readJson(MANUAL_LEDGER, "manual", "Manual evidence ledger");
    if (!ledger) return;

    const requiredSlots = ledger.rules?.requiredSlots || [];
    const allowed = new Set(ledger.rules?.allowedSlotStatuses || []);
    const disallowed = new Set(ledger.rules?.disallowedCompletionStatuses || []);
    const raceSummaries = [];
    const invalid = [];
    const missing = [];
    const pendingByRace = [];

    for (const race of PHASE20_EXPECTED_RACES) {
      const raceEntry = ledger.races?.[race];
      if (!raceEntry) {
        missing.push(`${race}: race entry`);
        continue;
      }
      const slots = raceEntry.manualEvidenceSlots || {};
      let pendingCount = 0;
      for (const slot of requiredSlots) {
        const status = slots[slot]?.status;
        if (!hasText(status)) {
          missing.push(`${race}.${slot}`);
          pendingCount += 1;
          continue;
        }
        if (allowed.size && !allowed.has(status)) invalid.push(`${race}.${slot}=${status}`);
        if (disallowed.has(status)) invalid.push(`${race}.${slot} uses disallowed completion status ${status}`);
        if (!MANUAL_PASS_STATUSES.has(status)) pendingCount += 1;
      }
      if (pendingCount > 0) pendingByRace.push(`${race}:${pendingCount}`);
      raceSummaries.push(`${race}:${requiredSlots.length - pendingCount}/${requiredSlots.length}`);
    }

    if (missing.length || invalid.length) {
      this.fail(
        "manual",
        "Manual evidence ledger shape",
        `Missing slots: ${clipList(missing) || "none"}; invalid statuses: ${clipList(invalid) || "none"}.`,
        MANUAL_LEDGER,
      );
    } else {
      this.pass("manual", "Manual evidence ledger shape", "All ten race entries contain required manual evidence slots with allowed statuses.", MANUAL_LEDGER);
    }

    if (pendingByRace.length) {
      this.runtimeManualPending = true;
      this.fail(
        "manual",
        "Race beta-feel manual evidence",
        `Pending required manual evidence by race: ${pendingByRace.join(", ")}.`,
        MANUAL_LEDGER,
      );
    } else {
      this.pass("manual", "Race beta-feel manual evidence", `All required manual slots are recorded: ${raceSummaries.join(", ")}.`, MANUAL_LEDGER);
    }
  }

  verifyBetaPackets() {
    const missingPackets = [];
    const blockedPackets = [];
    const contentGaps = [];
    for (const race of PHASE20_EXPECTED_RACES) {
      const file = rel(`references/authoring/PDV_BetaTestPacket_${race}.md`);
      if (!fs.existsSync(file)) {
        missingPackets.push(race);
        continue;
      }
      const text = fs.readFileSync(file, "utf8");
      const statusLine = text.split(/\r?\n/).find((line) => /^Status:/i.test(line)) || "";
      if (/^Status:\s*blocked/i.test(statusLine)) {
        blockedPackets.push(race);
        const fallbackChecks = BETA_PACKET_CHECKS.filter((check) => !["Expected build", "Edge build"].includes(check.label));
        for (const check of fallbackChecks) {
          if (!check.re.test(text)) {
            contentGaps.push(`${race}: ${check.label}`);
          }
        }
        continue;
      }
      for (const check of BETA_PACKET_CHECKS) {
        if (!check.re.test(text)) {
          contentGaps.push(`${race}: ${check.label}`);
        }
      }
    }

    if (missingPackets.length || blockedPackets.length || contentGaps.length) {
      this.fail(
        "manual",
        "Per-race beta packet coverage",
        `Missing packets: ${missingPackets.join(", ") || "none"}; blocked source packets: ${blockedPackets.join(", ") || "none"}; packet content gaps: ${clipList(contentGaps) || "none"}.`,
        AUTHORING,
      );
    } else {
      this.pass("manual", "Per-race beta packet coverage", "All ten beta packets include expected build, edge build, negative checks, Survey/status, and reward/stack evidence prompts.", AUTHORING);
    }
  }

  verifyDaedricRuntimeLedger() {
    const ledger = this.readJson(DAEDRIC_LEDGER, "manual", "Daedric runtime evidence ledger");
    if (!ledger) return;

    const expectedPrinces = new Set(PHASE20_SKYRIM_DAEDRIC_PRINCES.map(normalizePrinceName));
    const actualPrinces = new Set((ledger.princes || []).map((entry) => normalizePrinceName(entry.displayName || entry.stem)));
    const missingPrinces = [...expectedPrinces].filter((name) => !actualPrinces.has(name));
    const extraPrinces = [...actualPrinces].filter((name) => !expectedPrinces.has(name));

    if (missingPrinces.length || extraPrinces.length) {
      this.fail(
        "authority",
        "Daedric runtime ledger roster",
        `Missing Princes: ${missingPrinces.join(", ") || "none"}; extra Princes: ${extraPrinces.join(", ") || "none"}.`,
        DAEDRIC_LEDGER,
      );
    } else {
      this.pass("authority", "Daedric runtime ledger roster", "All sixteen Skyrim-present Princes have runtime evidence ledger entries.", DAEDRIC_LEDGER);
    }

    const slotGaps = [];
    const pendingPrinces = [];
    const slotNames = Object.keys(ledger.slotDefinitions || {});
    for (const prince of ledger.princes || []) {
      const name = prince.displayName || prince.stem || "(unnamed)";
      if (!DAEDRIC_OVERALL_READY.has(prince.overall)) pendingPrinces.push(`${name}:${prince.overall || "missing"}`);
      for (const slotName of slotNames) {
        const status = prince.slots?.[slotName]?.status;
        if (!hasText(status)) {
          slotGaps.push(`${name}.${slotName}:missing`);
        } else if (!DAEDRIC_PASS_STATUSES.has(status)) {
          slotGaps.push(`${name}.${slotName}:${status}`);
        }
      }
    }

    if (slotGaps.length) {
      this.fullDaedricPending = true;
      this.fail(
        "manual",
        "Daedric runtime/display evidence",
        `Pending or failing Daedric slots: ${clipList(slotGaps, 40)}.`,
        DAEDRIC_LEDGER,
      );
    } else {
      this.pass("manual", "Daedric runtime/display evidence", "All required Daedric slots are pass/conditional/not_required.", DAEDRIC_LEDGER);
    }

    if (pendingPrinces.length) {
      this.fullDaedricPending = true;
      this.fail(
        "manual",
        "Daedric overall beta-display verdict",
        `Princes not pass/conditional: ${clipList(pendingPrinces, 40)}.`,
        DAEDRIC_LEDGER,
      );
    } else {
      this.pass("manual", "Daedric overall beta-display verdict", "All sixteen Princes are pass or conditional.", DAEDRIC_LEDGER);
    }
  }

  verifyReleaseClaimBoundary() {
    if (this.rowAuthorityGap) {
      this.fail(
        "claim",
        "Scaled-out backend claim boundary",
        "Do not claim the backend is fully scaled out until row-level race/deity and race/Prince authority exists and is machine-checked.",
        COVERAGE_MATRIX,
      );
    }

    if (this.runtimeManualPending) {
      this.fail(
        "claim",
        "Race beta-feel release boundary",
        "Race beta-feel remains blocked because required manual/runtime evidence slots are still pending.",
        MANUAL_LEDGER,
      );
    }

    if (this.fullDaedricPending) {
      this.fail(
        "claim",
        "Full Devotion beta-feel release boundary",
        "Full beta-feel remains blocked until all sixteen Daedric runtime/display ledgers are pass or conditional.",
        DAEDRIC_LEDGER,
      );
    }

    if (!this.blockers.length) {
      this.pass("claim", "Beta-readiness closure boundary", "No fail-closed blockers remain in this audit.", AUTHORING);
    } else if (this.strict) {
      this.info(
        "claim",
        "Strict audit mode",
        `${this.blockers.length} blocker(s) keep the beta-ready claim closed.`,
        AUTHORING,
      );
    }
  }

  readJson(filePath, bucket, label) {
    if (!fs.existsSync(filePath)) {
      this.fail(bucket, label, "Required JSON file is missing.", filePath);
      return null;
    }
    try {
      return JSON.parse(fs.readFileSync(filePath, "utf8"));
    } catch (error) {
      this.fail(bucket, label, `JSON parse failed: ${error.message}`, filePath);
      return null;
    }
  }
}

function rel(projectRelativePath) {
  return path.join(PROJECT_ROOT, projectRelativePath);
}

function displayPath(filePath) {
  if (!filePath) return null;
  const absolute = path.isAbsolute(filePath) ? filePath : path.join(PROJECT_ROOT, filePath);
  return path.relative(PROJECT_ROOT, absolute).replaceAll(path.sep, "/");
}

function hasText(value) {
  return typeof value === "string" ? value.trim().length > 0 : value !== null && value !== undefined;
}

function clipList(values, limit = 24) {
  if (!values || values.length === 0) return "";
  const shown = values.slice(0, limit).join(", ");
  return values.length > limit ? `${shown}, ... (${values.length - limit} more)` : shown;
}

function normalizePrinceName(value) {
  return String(value || "")
    .split("/")
    .map((part) => part.trim())
    .filter(Boolean)[0]
    .toLowerCase();
}

function printText(result) {
  console.log("PDV beta readiness closure audit");
  console.log(`Mode: ${result.strict ? "strict" : "standard"}`);
  console.log(`Verdict: ${result.verdict}`);
  console.log(
    `Counts: PASS=${result.counts.PASS || 0} WARN=${result.counts.WARN || 0} FAIL=${result.counts.FAIL || 0} INFO=${result.counts.INFO || 0}`,
  );

  if (result.blockers.length) {
    console.log("");
    console.log("Blocking findings:");
    for (const finding of result.blockers) {
      console.log(`- [${finding.bucket}] ${finding.check}: ${finding.detail}${finding.path ? ` (${finding.path})` : ""}`);
    }
  }

  const warnings = result.findings.filter((finding) => finding.status === "WARN");
  if (warnings.length) {
    console.log("");
    console.log("Warnings:");
    for (const finding of warnings) {
      console.log(`- [${finding.bucket}] ${finding.check}: ${finding.detail}${finding.path ? ` (${finding.path})` : ""}`);
    }
  }
}

const audit = new BetaReadinessAudit({ strict: STRICT });
const result = audit.run();

if (JSON_OUTPUT) {
  console.log(JSON.stringify(result, null, 2));
} else {
  printText(result);
}

process.exitCode = result.verdict === "NOT_BETA_READY" ? 1 : 0;
