import fs from "node:fs";
import path from "node:path";

const DEFAULT_PROOF_RESULTS = "generated/proof-results.skyrimse.json";
const DEFAULT_MATRIX = "generated/capability-matrix.skyrimse.json";
const DEFAULT_SUMMARY = "generated/platform-v1-proof-summary.json";
const CK_SHELL_FAMILIES = new Set(["FLST", "MESG", "ACTI", "QUST"]);

export function verifyPlatformV1Evidence({
  proofResultsPath = DEFAULT_PROOF_RESULTS,
  matrixPath = DEFAULT_MATRIX,
  summaryPath = DEFAULT_SUMMARY,
  repoRoot = process.cwd()
} = {}) {
  const failures = [];
  const proofResults = readJsonEvidence(proofResultsPath, "proof-results", repoRoot, failures);
  const matrix = readJsonEvidence(matrixPath, "capability-matrix", repoRoot, failures);
  const summary = readJsonEvidence(summaryPath, "platform-v1-proof-summary", repoRoot, failures);

  if (!proofResults || !matrix || !summary) {
    return buildReport({ proofResultsPath, matrixPath, summaryPath, repoRoot, failures });
  }

  requireSchema(proofResults, "creation-authoring.proof-results.v1", "proof-results", failures);
  requireSchema(matrix, "creation-authoring.capability-matrix.v1", "capability-matrix", failures);
  requireSchema(summary, "creation-authoring.platform-v1-proof-summary.v1", "platform-v1-proof-summary", failures);
  requireSummarySourceProofResults(summary, proofResultsPath, repoRoot, failures);

  validatePathReferences({
    proofResults,
    matrix,
    summary,
    repoRoot,
    failures
  });

  validateProofResultsRows(proofResults, failures);
  validateMatrixAgreement(proofResults, matrix, proofResultsPath, repoRoot, failures);
  validateSummaryAgreement(proofResults, summary, proofResultsPath, repoRoot, failures);
  validatePlatformV1Semantics(matrix, summary, failures);

  return buildReport({ proofResultsPath, matrixPath, summaryPath, repoRoot, failures });
}

export function formatPlatformV1EvidenceCheck(report, written = null) {
  const lines = [
    `Status: ${report.status}`,
    `Failures: ${report.failures.length}`,
    `Proof results: ${report.inputs.proofResults}`,
    `Capability matrix: ${report.inputs.matrix}`,
    `Proof summary: ${report.inputs.summary}`
  ];
  for (const failure of report.failures) {
    lines.push(`- ${failure.code}: ${failure.message}`);
  }
  if (written) {
    lines.push(`Evidence check: ${written}`);
  }
  return `${lines.join("\n")}\n`;
}

function buildReport({ proofResultsPath, matrixPath, summaryPath, repoRoot, failures }) {
  return {
    schema: "creation-authoring.platform-v1-evidence-check.v1",
    generatedAt: new Date().toISOString(),
    status: failures.length ? "FAIL" : "PASS",
    inputs: {
      proofResults: normalizeRepoPath(proofResultsPath, repoRoot),
      matrix: normalizeRepoPath(matrixPath, repoRoot),
      summary: normalizeRepoPath(summaryPath, repoRoot)
    },
    failures
  };
}

function readJsonEvidence(filePath, label, repoRoot, failures) {
  const absolutePath = resolveEvidencePath(filePath, repoRoot);
  if (!fs.existsSync(absolutePath)) {
    failures.push({
      code: "missing_evidence_file",
      message: `${label} file does not exist: ${normalizeRepoPath(filePath, repoRoot)}`,
      path: normalizeRepoPath(filePath, repoRoot)
    });
    return null;
  }
  try {
    return JSON.parse(fs.readFileSync(absolutePath, "utf8"));
  } catch (error) {
    failures.push({
      code: "invalid_evidence_json",
      message: `${label} file is not valid JSON: ${error.message}`,
      path: normalizeRepoPath(filePath, repoRoot)
    });
    return null;
  }
}

function requireSchema(document, schema, label, failures) {
  if (document?.schema !== schema) {
    failures.push({
      code: "invalid_schema",
      message: `${label} schema is ${document?.schema || "MISSING"}; expected ${schema}.`
    });
  }
}

function requireSummarySourceProofResults(summary, proofResultsPath, repoRoot, failures) {
  if (!summary.sourceProofResults) {
    failures.push({
      code: "summary_missing_source_proof_results",
      message: "Platform v1 proof summary must be regenerated with --proof-results generated\\proof-results.skyrimse.json in release mode."
    });
    return;
  }
  if (!pathsEqual(summary.sourceProofResults, proofResultsPath, repoRoot)) {
    failures.push({
      code: "summary_source_proof_results_mismatch",
      message: `Platform v1 proof summary uses ${summary.sourceProofResults}, expected ${normalizeRepoPath(proofResultsPath, repoRoot)}.`
    });
  }
}

function validatePathReferences({ proofResults, matrix, summary, repoRoot, failures }) {
  for (const sourceLedger of proofResults.sourceLedgers || []) {
    requireExistingPath(sourceLedger, repoRoot, failures, "proof_results_source_ledger");
  }
  for (const proof of proofResults.results || []) {
    for (const [field, value] of Object.entries({
      fixture: proof.fixture,
      strictReport: proof.strictReport,
      proofLedger: proof.proofLedger
    })) {
      requireExistingPath(value, repoRoot, failures, `proof_results_${field}`, proofKey(proof));
    }
  }
  for (const row of matrix.rows || []) {
    for (const proof of row.operationProofs || []) {
      if (proof.status !== "PASS") {
        continue;
      }
      for (const [field, value] of Object.entries({
        fixture: proof.fixture,
        strictReport: proof.strictReport,
        proofLedger: proof.proofLedger
      })) {
        requireExistingPath(value, repoRoot, failures, `matrix_operation_${field}`, `${row.recordFamily}:${proof.operation}`);
      }
    }
  }
  for (const row of summaryRows(summary)) {
    for (const proof of row.operationProofs || []) {
      if (proof.status !== "PASS") {
        continue;
      }
      for (const [field, value] of Object.entries({
        fixture: proof.fixture,
        strictReport: proof.strictReport,
        proofLedger: proof.proofLedger
      })) {
        requireExistingPath(value, repoRoot, failures, `summary_operation_${field}`, `${row.recordFamily}:${proof.operation}`);
      }
    }
  }
}

function validateProofResultsRows(proofResults, failures) {
  for (const proof of proofResults.results || []) {
    if (proof.status !== "PASS") {
      failures.push({
        code: "proof_result_not_pass",
        message: `${proofKey(proof)} has status ${proof.status || "MISSING"}.`
      });
      continue;
    }
    for (const field of ["recordFamily", "operation", "target", "generatedPlugin", "fixture", "strictReport", "proofLedger"]) {
      if (!proof[field]) {
        failures.push({
          code: "proof_result_missing_field",
          message: `${proofKey(proof)} is missing ${field}.`
        });
      }
    }
    if (proof.verifierStatus !== "PASS") {
      failures.push({
        code: "proof_result_verifier_not_pass",
        message: `${proofKey(proof)} verifierStatus is ${proof.verifierStatus || "MISSING"}.`
      });
    }
    if (proof.readbackStatus !== "PASS") {
      failures.push({
        code: "proof_result_readback_not_pass",
        message: `${proofKey(proof)} readbackStatus is ${proof.readbackStatus || "MISSING"}.`
      });
    }
    if (!["PASS", "NOT_REQUIRED"].includes(proof.commandEvidenceStatus)) {
      failures.push({
        code: "proof_result_command_evidence_not_pass",
        message: `${proofKey(proof)} commandEvidenceStatus is ${proof.commandEvidenceStatus || "MISSING"}.`
      });
    }
  }
}

function validateMatrixAgreement(proofResults, matrix, proofResultsPath, repoRoot, failures) {
  const proofResultIndex = indexProofResults(proofResults);
  for (const proof of proofResults.results || []) {
    const matrixProof = findOperationProof(matrix, proof);
    if (!matrixProof) {
      failures.push({
        code: "matrix_missing_operation_proof",
        message: `Capability matrix is missing PASS operation proof for ${proofKey(proof)}.`
      });
      continue;
    }
    compareProofFields("matrix", proof, matrixProof, proofResultsPath, repoRoot, failures);
  }

  for (const row of matrix.rows || []) {
    for (const proof of row.operationProofs || []) {
      if (proof.status !== "PASS") {
        continue;
      }
      const matching = proofResultIndex.get(indexKey(row.recordFamily, proof.operation, proof.target));
      if (!matching) {
        failures.push({
          code: "matrix_operation_proof_missing_from_results",
          message: `${row.recordFamily}:${proof.operation}:${proof.target || "NO_TARGET"} is PASS in matrix but missing from proof-results.`
        });
      }
    }
  }
}

function validateSummaryAgreement(proofResults, summary, proofResultsPath, repoRoot, failures) {
  const proofResultIndex = indexProofResults(proofResults);
  for (const proof of proofResults.results || []) {
    const summaryProof = findSummaryOperationProof(summary, proof);
    if (!summaryProof) {
      failures.push({
        code: "summary_missing_operation_proof",
        message: `Platform v1 proof summary is missing PASS operation proof for ${proofKey(proof)}.`
      });
      continue;
    }
    compareProofFields("summary", proof, summaryProof, proofResultsPath, repoRoot, failures);
  }

  for (const row of summaryRows(summary)) {
    for (const proof of row.operationProofs || []) {
      if (proof.status !== "PASS") {
        continue;
      }
      const matching = proofResultIndex.get(indexKey(row.recordFamily, proof.operation, proof.target));
      if (!matching) {
        failures.push({
          code: "summary_operation_proof_missing_from_results",
          message: `${row.recordFamily}:${proof.operation}:${proof.target || "NO_TARGET"} is PASS in summary but missing from proof-results.`
        });
      }
    }
  }
}

function validatePlatformV1Semantics(matrix, summary, failures) {
  const glob = (matrix.rows || []).find((row) => row.recordFamily === "GLOB");
  if (glob?.status !== "supported" || !(glob.manifestOperations || []).includes("glob.duplicate_create")) {
    failures.push({
      code: "glob_duplicate_create_not_supported",
      message: "GLOB must remain the only fully supported CK creation row, and only for glob.duplicate_create."
    });
  }

  for (const family of CK_SHELL_FAMILIES) {
    const row = (matrix.rows || []).find((item) => item.recordFamily === family);
    if (row?.status === "supported") {
      failures.push({
        code: "ck_shell_family_promoted_to_family_support",
        message: `${family} must remain operation-level record.duplicate_create shell proof, not full family support.`
      });
    }
    const proof = (row?.operationProofs || []).find((item) => item.operation === "record.duplicate_create");
    if (proof?.status !== "PASS") {
      failures.push({
        code: "ck_shell_family_duplicate_proof_missing",
        message: `${family} must have PASS operation proof for record.duplicate_create.`
      });
    }
  }

  if (summary.platformV1Gate?.status !== "PASS") {
    failures.push({
      code: "platform_v1_gate_not_pass",
      message: `Platform v1 proof summary gate status is ${summary.platformV1Gate?.status || "MISSING"}.`
    });
  }
}

function compareProofFields(sourceName, expected, actual, proofResultsPath, repoRoot, failures) {
  if (actual.status !== "PASS") {
    failures.push({
      code: `${sourceName}_operation_not_pass`,
      message: `${sourceName} operation proof for ${proofKey(expected)} is ${actual.status || "MISSING"}.`
    });
  }
  for (const field of ["fixture", "strictReport", "generatedPlugin", "target"]) {
    if (expected[field] && actual[field] && !valuesEqual(expected[field], actual[field], repoRoot)) {
      failures.push({
        code: `${sourceName}_proof_field_mismatch`,
        message: `${sourceName} ${proofKey(expected)} ${field} is ${actual[field]}, expected ${expected[field]}.`
      });
    }
  }
  if (expected.proofLedger && actual.proofLedger &&
    !valuesEqual(expected.proofLedger, actual.proofLedger, repoRoot) &&
    !pathsEqual(actual.proofLedger, proofResultsPath, repoRoot)) {
    failures.push({
      code: `${sourceName}_proof_ledger_mismatch`,
      message: `${sourceName} ${proofKey(expected)} proofLedger is ${actual.proofLedger}, expected ${expected.proofLedger} or aggregate ${normalizeRepoPath(proofResultsPath, repoRoot)}.`
    });
  }
}

function findOperationProof(matrix, proof) {
  const row = (matrix.rows || []).find((item) => item.recordFamily === proof.recordFamily);
  return (row?.operationProofs || []).find((item) =>
    item.operation === proof.operation &&
    (!item.target || !proof.target || item.target === proof.target)
  ) || null;
}

function findSummaryOperationProof(summary, proof) {
  const row = summaryRows(summary).find((item) => item.recordFamily === proof.recordFamily);
  return (row?.operationProofs || []).find((item) =>
    item.operation === proof.operation &&
    (!item.target || !proof.target || item.target === proof.target)
  ) || null;
}

function indexProofResults(proofResults) {
  const index = new Map();
  for (const proof of proofResults.results || []) {
    index.set(indexKey(proof.recordFamily, proof.operation, proof.target), proof);
  }
  return index;
}

function indexKey(recordFamily, operation, target) {
  return [recordFamily || "", operation || "", target || ""].join("|");
}

function summaryRows(summary) {
  return [
    ...(summary.groups?.supported || []),
    ...(summary.groups?.discoveryOnly || []),
    ...(summary.groups?.blocked || [])
  ];
}

function requireExistingPath(value, repoRoot, failures, code, owner = null) {
  if (!value) {
    failures.push({
      code: `${code}_missing`,
      message: owner ? `${owner} is missing a required proof path.` : "Required proof path is missing."
    });
    return;
  }
  if (!fs.existsSync(resolveEvidencePath(value, repoRoot))) {
    failures.push({
      code,
      message: `${owner ? `${owner} ` : ""}proof path does not exist: ${normalizeRepoPath(value, repoRoot)}`,
      path: normalizeRepoPath(value, repoRoot)
    });
  }
}

function proofKey(proof) {
  return `${proof.recordFamily || "UNKNOWN"}:${proof.operation || "unknown"}:${proof.target || "NO_TARGET"}`;
}

function valuesEqual(left, right, repoRoot) {
  if (looksLikePath(left) || looksLikePath(right)) {
    return pathsEqual(left, right, repoRoot);
  }
  return String(left) === String(right);
}

function pathsEqual(left, right, repoRoot) {
  return normalizeRepoPath(left, repoRoot).toLowerCase() === normalizeRepoPath(right, repoRoot).toLowerCase();
}

function looksLikePath(value) {
  return String(value || "").includes("/") || String(value || "").includes("\\");
}

function resolveEvidencePath(value, repoRoot) {
  return path.isAbsolute(String(value)) ? String(value) : path.resolve(repoRoot, String(value));
}

function normalizeRepoPath(value, repoRoot) {
  const absolutePath = resolveEvidencePath(value, repoRoot);
  const relativePath = path.relative(repoRoot, absolutePath);
  if (!relativePath.startsWith("..") && !path.isAbsolute(relativePath)) {
    return relativePath.replaceAll("\\", "/");
  }
  return absolutePath.replaceAll("\\", "/");
}
