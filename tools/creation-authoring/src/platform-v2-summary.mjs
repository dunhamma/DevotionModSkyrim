import fs from "node:fs";
import path from "node:path";
import { validateShipPathLoadSet } from "./load-set-proof.mjs";
import { buildPlatformProofSummary } from "./proof-summary.mjs";

export const PLATFORM_V2_OPERATION_EXPANSION_TARGETS = [
  { recordFamily: "SPEL", operation: "spell.add" },
  { recordFamily: "SPEL", operation: "condition.add" },
  { recordFamily: "PERK", operation: "perk.add" },
  { recordFamily: "PERK", operation: "vmad.attach_script" }
];

export function buildPlatformV2OperationExpansionSummary(matrix, options = {}) {
  const repoRoot = path.resolve(options.repoRoot || process.cwd());
  const platformSummary = buildPlatformProofSummary(matrix, {
    game: options.game || matrix?.game || "SkyrimSE",
    sourceMatrix: options.sourceMatrix || null,
    sourceProofResults: options.sourceProofResults || null
  });
  const targetSurfaces = PLATFORM_V2_OPERATION_EXPANSION_TARGETS.map((target) => summarizeTargetSurface(matrix, target));
  const promotedRows = targetSurfaces.filter((surface) => surface.status === "PASS");
  const loadPluginSetEvidence = verifyLoadPluginSetEvidence({
    repoRoot,
    fixturePath: options.loadSetFixture,
    expectedActivePlugin: options.expectedActivePlugin,
    expectedSaveTarget: options.expectedSaveTarget
  });

  const blockers = [];
  for (const surface of targetSurfaces) {
    if (surface.status !== "PASS") {
      blockers.push({
        code: "v2_target_surface_unproven",
        recordFamily: surface.recordFamily,
        operation: surface.operation,
        message: `${surface.recordFamily} ${surface.operation} is ${surface.status}: ${surface.reason}`
      });
    }
  }
  if (loadPluginSetEvidence.status !== "PASS") {
    for (const failure of loadPluginSetEvidence.failures) {
      blockers.push({
        code: "v2_load_plugin_set_invalid",
        message: failure
      });
    }
  }

  return {
    schema: "creation-authoring.platform-v2-operation-expansion-summary.v1",
    generatedAt: new Date().toISOString(),
    game: platformSummary.game,
    sourceMatrix: options.sourceMatrix || null,
    sourceProofResults: options.sourceProofResults || null,
    tranche: "operation-expansion",
    fullMatrixReleaseReady: platformSummary.releaseReady,
    notes: [
      "Platform v2 operation-expansion gate is operation-first and row-scoped.",
      "Full-matrix releaseReady may remain false while unrelated rows stay blocked or discovery-only."
    ],
    targets: targetSurfaces,
    promotedRows,
    loadPluginSetEvidence,
    gate: {
      status: blockers.length ? "BLOCKED" : "PASS",
      blockers
    }
  };
}

export function formatPlatformV2OperationExpansionSummary(summary) {
  const lines = [
    `Game: ${summary.game}`,
    `Tranche: ${summary.tranche}`,
    `Gate: ${summary.gate.status}`,
    `Promoted target rows: ${summary.promotedRows.length}/${summary.targets.length}`,
    `Full-matrix releaseReady: ${summary.fullMatrixReleaseReady ? "yes" : "no"}`,
    `loadPluginSet evidence: ${summary.loadPluginSetEvidence.status}`
  ];

  if (summary.loadPluginSetEvidence.fixture) {
    lines.push(`loadPluginSet fixture: ${summary.loadPluginSetEvidence.fixture}`);
  }

  lines.push("", "Target surfaces");
  for (const surface of summary.targets) {
    lines.push(`- [${surface.status}] ${surface.recordFamily} ${surface.operation}: ${surface.reason}`);
  }

  if (summary.gate.blockers.length) {
    lines.push("", "Blockers");
    for (const blocker of summary.gate.blockers) {
      lines.push(`- ${blocker.code}: ${blocker.message}`);
    }
  }

  lines.push("", "Notes");
  for (const note of summary.notes || []) {
    lines.push(`- ${note}`);
  }

  return `${lines.join("\n")}\n`;
}

function summarizeTargetSurface(matrix, target) {
  const row = (matrix?.rows || []).find((item) => item.recordFamily === target.recordFamily);
  const proof = (row?.operationProofs || []).find((item) => item.operation === target.operation) || null;
  if (!row || !proof) {
    return {
      recordFamily: target.recordFamily,
      operation: target.operation,
      status: "UNPROVEN",
      reason: "No operation proof row found in capability matrix.",
      proofReferences: {
        target: null,
        generatedPlugin: null,
        fixture: null,
        proofLedger: null,
        strictReport: null,
        backend: null,
        verifierStatus: null,
        readbackStatus: null,
        commandEvidenceStatus: null
      }
    };
  }

  const proofReferences = {
    target: proof.target || null,
    generatedPlugin: proof.generatedPlugin || null,
    fixture: proof.fixture || null,
    proofLedger: proof.proofLedger || null,
    strictReport: proof.strictReport || null,
    backend: proof.backend || null,
    verifierStatus: proof.verifierStatus || null,
    readbackStatus: proof.readbackStatus || null,
    commandEvidenceStatus: proof.commandEvidenceStatus || null
  };

  const missing = [];
  if (proof.status !== "PASS") missing.push(`status=${proof.status || "MISSING"}`);
  if (!proofReferences.fixture) missing.push("fixture");
  if (!proofReferences.strictReport) missing.push("strictReport");
  if (!proofReferences.proofLedger) missing.push("proofLedger");
  if (proofReferences.verifierStatus !== "PASS") missing.push(`verifierStatus=${proofReferences.verifierStatus || "MISSING"}`);
  if (proofReferences.readbackStatus !== "PASS") missing.push(`readbackStatus=${proofReferences.readbackStatus || "MISSING"}`);
  if (!["PASS", "NOT_REQUIRED"].includes(proofReferences.commandEvidenceStatus || "")) {
    missing.push(`commandEvidenceStatus=${proofReferences.commandEvidenceStatus || "MISSING"}`);
  }
  for (const [coverage, present] of Object.entries(proof.coverage || {})) {
    if (present !== true) {
      missing.push(`coverage.${coverage}`);
    }
  }
  for (const item of proof.missingCoverage || []) {
    missing.push(`missingCoverage.${item}`);
  }

  return {
    recordFamily: target.recordFamily,
    operation: target.operation,
    status: missing.length ? "BLOCKED" : "PASS",
    reason: missing.length ? `Missing proof requirements: ${missing.join(", ")}.` : "Operation row promoted from strict proof evidence.",
    proofReferences
  };
}

function verifyLoadPluginSetEvidence({
  repoRoot,
  fixturePath,
  expectedActivePlugin,
  expectedSaveTarget
}) {
  const failures = [];
  if (!fixturePath) {
    return {
      status: "FAIL",
      fixture: null,
      expectedActivePlugin: expectedActivePlugin || null,
      expectedSaveTarget: expectedSaveTarget || expectedActivePlugin || null,
      failures: ["No loadPluginSet fixture path was provided."]
    };
  }

  const absoluteFixturePath = path.resolve(repoRoot, fixturePath);
  if (!fs.existsSync(absoluteFixturePath)) {
    return {
      status: "FAIL",
      fixture: normalizePath(fixturePath),
      expectedActivePlugin: expectedActivePlugin || null,
      expectedSaveTarget: expectedSaveTarget || expectedActivePlugin || null,
      failures: [`loadPluginSet fixture does not exist: ${normalizePath(fixturePath)}.`]
    };
  }

  let packet = null;
  try {
    packet = JSON.parse(fs.readFileSync(absoluteFixturePath, "utf8"));
  } catch (error) {
    return {
      status: "FAIL",
      fixture: normalizePath(fixturePath),
      expectedActivePlugin: expectedActivePlugin || null,
      expectedSaveTarget: expectedSaveTarget || expectedActivePlugin || null,
      failures: [`loadPluginSet fixture is not valid JSON: ${error.message}`]
    };
  }

  const commands = Array.isArray(packet?.commands) ? packet.commands : [];
  if (packet?.schema !== "creation-authoring.ck-command-packet.v1") {
    failures.push(`loadPluginSet fixture schema is ${packet?.schema || "MISSING"}, expected creation-authoring.ck-command-packet.v1.`);
  }

  const gate = validateShipPathLoadSet(commands, {
    requireOpenProjectPrelude: true,
    expectedActivePlugin: expectedActivePlugin || null,
    expectedSaveTarget: expectedSaveTarget || expectedActivePlugin || null
  });
  failures.push(...gate.failures);

  return {
    status: failures.length ? "FAIL" : "PASS",
    fixture: normalizePath(fixturePath),
    expectedActivePlugin: expectedActivePlugin || null,
    expectedSaveTarget: expectedSaveTarget || expectedActivePlugin || null,
    command: gate.command || null,
    failures
  };
}

function normalizePath(filePath) {
  return String(filePath || "").replaceAll("/", "\\");
}
