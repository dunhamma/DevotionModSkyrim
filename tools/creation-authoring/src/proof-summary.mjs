import { classifyPlatformV1MatrixStatus } from "./release-status.mjs";

export const PLATFORM_V1_SAFE_WRITER_OPERATIONS = [
  "vmad.attach_script",
  "formlist.add",
  "keyword.add",
  "spell.add",
  "perk.add",
  "package.add",
  "inventory.add",
  "condition.add"
];

export const PLATFORM_V1_REQUIRED_CK_OPERATIONS = [
  "glob.duplicate_create"
];

export const PLATFORM_V1_CREATION_FAMILY_BACKLOG = [
  "MESG",
  "FLST",
  "ACTI",
  "QUST"
];

export const PLATFORM_V1_CREATION_FAMILY_PROOFS = PLATFORM_V1_CREATION_FAMILY_BACKLOG.map((recordFamily) => ({
  recordFamily,
  operation: "record.duplicate_create"
}));

export function buildPlatformProofSummary(matrix, options = {}) {
  const generatedAt = new Date().toISOString();
  const rows = matrix?.rows || [];
  const supported = [];
  const discoveryOnly = [];
  const blocked = [];

  for (const row of rows) {
    const entry = summarizeRow(row);
    const group = classifyPlatformV1MatrixStatus(row.status);
    if (group === "supported") {
      supported.push(entry);
      continue;
    }
    if (group === "discoveryOnly") {
      discoveryOnly.push(entry);
      continue;
    }
    blocked.push(entry);
  }

  const platformV1Gate = buildPlatformV1Gate(rows);

  return {
    schema: "creation-authoring.platform-v1-proof-summary.v1",
    generatedAt,
    game: matrix?.game || options.game || "SkyrimSE",
    sourceMatrix: options.sourceMatrix || null,
    sourceProofResults: options.sourceProofResults || null,
    totals: {
      supported: supported.length,
      discoveryOnly: discoveryOnly.length,
      blocked: blocked.length,
      total: rows.length
    },
    releaseReady: blocked.length === 0 && discoveryOnly.length === 0,
    platformV1ProductReady: platformV1Gate.status === "PASS",
    operationSurfaces: buildOperationSurfaces(rows),
    platformV1Gate,
    groups: {
      supported,
      discoveryOnly,
      blocked
    }
  };
}

export function formatPlatformProofSummary(summary) {
  const lines = [
    `Game: ${summary.game}`,
    `Platform v1 product ready (operation gate only): ${summary.platformV1ProductReady ? "yes" : "no"}`,
    `Release ready (full matrix and live proof): ${summary.releaseReady ? "yes" : "no"}`,
    `Supported: ${summary.totals.supported}`,
    `Discovery-only: ${summary.totals.discoveryOnly}`,
    `Blocked: ${summary.totals.blocked}`
  ];

  lines.push(
    "Summary scope: derived from current proof-results and matrix artifacts.",
    "Summary scope does not re-run live loadPluginSet proof or post-merge verification."
  );

  if (summary.platformV1Gate) {
    lines.push(
      "",
      "Platform v1 gate",
      `- status: ${summary.platformV1Gate.status}`,
      `- required supported operations: ${summary.platformV1Gate.requiredSupportedOperations.filter((item) => item.supported).length}/${summary.platformV1Gate.requiredSupportedOperations.length}`,
      `- operation surfaces: ${summary.operationSurfaces?.length || 0}`,
      `- blockers: ${summary.platformV1Gate.blockers.length}`
    );
    for (const blocker of summary.platformV1Gate.blockers) {
      lines.push(`  blocker: ${blocker.message}`);
    }
    lines.push("- next proof order:");
    for (const item of summary.platformV1Gate.nextProofOrder) {
      lines.push(`  ${item.order}. ${item.surface} - ${item.reason}`);
    }
  }

  for (const [heading, rows] of [
    ["Supported", summary.groups.supported],
    ["Discovery-only", summary.groups.discoveryOnly],
    ["Blocked", summary.groups.blocked]
  ]) {
    lines.push("", heading);
    if (!rows.length) {
      lines.push("- none");
      continue;
    }
    for (const row of rows) {
      lines.push(`- ${row.recordFamily}: ${row.status}${row.reason ? ` - ${row.reason}` : ""}`);
    }
  }

  return `${lines.join("\n")}\n`;
}

function summarizeRow(row) {
  return {
    recordFamily: row.recordFamily,
    status: row.status,
    operations: row.manifestOperations || [],
    proofStatus: row.proofStatus || "UNPROVEN",
    proofTarget: row.proofTarget || null,
    proofGeneratedPlugin: row.proofGeneratedPlugin || null,
    proofFixture: row.proofFixture || null,
    proofLedger: row.proofLedger || null,
    proofReport: row.proofReport || null,
    operationProofs: (row.operationProofs || [])
      .filter((proof) => proof.status === "PASS")
      .map((proof) => ({
        operation: proof.operation,
        status: proof.status,
        target: proof.target || null,
        generatedPlugin: proof.generatedPlugin || null,
        fixture: proof.fixture || null,
        proofLedger: proof.proofLedger || null,
        strictReport: proof.strictReport || null,
        backend: proof.backend || null,
        verifierStatus: proof.verifierStatus || null,
        readbackStatus: proof.readbackStatus || null,
        commandEvidenceStatus: proof.commandEvidenceStatus || null
      })),
    reason: row.blockReason || null
  };
}

function buildOperationSurfaces(rows) {
  const surfaces = [];
  const seen = new Set();

  for (const row of rows) {
    for (const proof of row.operationProofs || []) {
      const surface = buildOperationSurface(row, proof);
      surfaces.push(surface);
      seen.add(operationSurfaceKey(surface));
    }

    if (row.status === "supported" && row.proofStatus === "PASS") {
      for (const operation of row.manifestOperations || []) {
        const surface = buildOperationSurface(row, {
          operation,
          status: "PASS",
          target: row.proofTarget || null,
          generatedPlugin: row.proofGeneratedPlugin || null,
          fixture: row.proofFixture || null,
          proofLedger: row.proofLedger || null,
          strictReport: row.proofReport || null,
          backend: null,
          verifierStatus: row.proofStatus || null,
          readbackStatus: null,
          commandEvidenceStatus: null
        }, { familyLevel: true });
        const key = operationSurfaceKey(surface);
        if (!seen.has(key)) {
          surfaces.push(surface);
          seen.add(key);
        }
      }
    }
  }

  return surfaces;
}

function buildOperationSurface(row, proof, options = {}) {
  const useRowProofFallback = proof.status === "PASS" || options.familyLevel;
  return {
    recordFamily: row.recordFamily,
    operation: proof.operation,
    supportScope: operationSupportScope(row, proof, options),
    status: proof.status || "UNPROVEN",
    proofReferences: {
      target: proof.target || (useRowProofFallback ? row.proofTarget : null) || null,
      generatedPlugin: proof.generatedPlugin || (useRowProofFallback ? row.proofGeneratedPlugin : null) || null,
      fixture: proof.fixture || (useRowProofFallback ? row.proofFixture : null) || null,
      proofLedger: proof.proofLedger || (useRowProofFallback ? row.proofLedger : null) || null,
      strictReport: proof.strictReport || (useRowProofFallback ? row.proofReport : null) || null,
      backend: proof.backend || null,
      verifierStatus: proof.verifierStatus || null,
      readbackStatus: proof.readbackStatus || null,
      commandEvidenceStatus: proof.commandEvidenceStatus || null
    }
  };
}

function operationSupportScope(row, proof, options = {}) {
  if (proof.status === "PASS") {
    return options.familyLevel || row.status === "supported" ? "family" : "operation";
  }
  if (proof.operation === "record.create") {
    return "blocked_generic_create";
  }
  const group = classifyPlatformV1MatrixStatus(row.status);
  if (group === "discoveryOnly") {
    return "discovery_only";
  }
  return "blocked";
}

function operationSurfaceKey(surface) {
  return [
    surface.recordFamily || "",
    surface.operation || "",
    surface.proofReferences?.target || ""
  ].join("|");
}

function buildPlatformV1Gate(rows) {
  const requiredOperations = [
    ...PLATFORM_V1_SAFE_WRITER_OPERATIONS,
    ...PLATFORM_V1_REQUIRED_CK_OPERATIONS
  ].map((operation) => summarizeRequiredOperation(rows, operation));
  const blockers = [];

  for (const operation of requiredOperations) {
    if (!operation.supported) {
      blockers.push({
        code: "platform_v1_operation_unproven",
        operation: operation.operation,
        message: `${operation.operation} is not supported by a passing proof ledger and accepted capability matrix operation proof.`
      });
    }
  }

  const pendingFamilies = PLATFORM_V1_CREATION_FAMILY_PROOFS.filter((required) => {
    return !summarizeRequiredFamilyOperation(rows, required.recordFamily, required.operation).supported;
  });
  if (pendingFamilies.length) {
    const pendingFamilyNames = pendingFamilies.map((item) => item.recordFamily);
    blockers.push({
      code: "platform_v1_creation_family_disposition_pending",
      recordFamilies: pendingFamilyNames,
      operation: "record.duplicate_create",
      message: `${pendingFamilyNames.join(", ")} must have strict record.duplicate_create shell proof or be explicitly documented as Platform v1 exclusions/backlog.`
    });
  }

  return {
    status: blockers.length ? "BLOCKED" : "PASS",
    requiredSupportedOperations: requiredOperations,
    blockers,
    nextProofOrder: buildNextProofOrder(requiredOperations, pendingFamilies)
  };
}

function summarizeRequiredOperation(rows, operation) {
  const matchingRows = rows.filter((row) => (row.manifestOperations || []).includes(operation));
  const supportedRows = matchingRows.filter((row) => {
    const operationProof = (row.operationProofs || []).find((proof) => proof.operation === operation);
    if (operationProof) {
      return operationProof.status === "PASS";
    }
    return row.status === "supported" && row.proofStatus === "PASS";
  });
  return {
    operation,
    supported: supportedRows.length > 0,
    supportedRecordFamilies: supportedRows.map((row) => row.recordFamily),
    candidateRecordFamilies: matchingRows.map((row) => row.recordFamily),
    proofLedgers: supportedRows
      .map((row) => (row.operationProofs || []).find((proof) => proof.operation === operation)?.proofLedger || row.proofLedger)
      .filter(Boolean)
  };
}

function summarizeRequiredFamilyOperation(rows, recordFamily, operation) {
  const row = rows.find((item) => item.recordFamily === recordFamily);
  const operationProof = (row?.operationProofs || []).find((proof) => proof.operation === operation);
  return {
    recordFamily,
    operation,
    supported: operationProof?.status === "PASS",
    proofLedger: operationProof?.proofLedger || null,
    strictReport: operationProof?.strictReport || null
  };
}

function buildNextProofOrder(requiredOperations, pendingFamilies) {
  const missingOperations = requiredOperations
    .filter((operation) => !operation.supported)
    .map((operation) => operation.operation);
  const order = [];
  let index = 1;

  for (const operation of PLATFORM_V1_SAFE_WRITER_OPERATIONS) {
    if (missingOperations.includes(operation)) {
      order.push({
        order: index++,
        surface: operation,
        reason: "Promote safe-writer proof before expanding CK creation coverage."
      });
    }
  }

  if (missingOperations.includes("glob.duplicate_create")) {
    order.push({
      order: index++,
      surface: "GLOB glob.duplicate_create",
      reason: "Keep the current CK creation support row proof-backed before using it as the exemplar."
    });
  }

  for (const item of pendingFamilies) {
    order.push({
      order: index++,
      surface: `${item.recordFamily} authored target create proof`,
      reason: "Run duplicate identity, payload, CK save, readback, verifier, proof ledger, and matrix promotion as separate proof gates."
    });
  }

  if (!order.length) {
    order.push({
      order: 1,
      surface: "Platform v1 release candidate",
      reason: "All required Platform v1 proof rows are supported."
    });
  }

  return order;
}
