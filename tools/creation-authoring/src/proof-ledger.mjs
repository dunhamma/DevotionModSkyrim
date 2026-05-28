export const PROOF_LEDGER_SCHEMA = "creation-authoring.proof-ledger.v1";
export const PROOF_RESULTS_SCHEMA = "creation-authoring.proof-results.v1";

export function buildProofLedgerFromRun(report, options = {}) {
  const generatedAt = new Date().toISOString();
  const proofs = [];
  const verificationByOperation = verificationResultMap(report);
  const ckEvidence = collectCkCommandEvidence(report);
  const strictGate = (report.phases || []).find((phase) => phase.phase === "strict-gate");
  const strictPassed = Boolean(strictGate && strictGate.status === "PASS" && report.status === "PASS");
  const discoveryOnly = isDiscoveryOnlyReport(report);

  for (const operation of report.planOperations || []) {
    const recordFamily = operation.recordFamily ? String(operation.recordFamily).toUpperCase() : null;
    if (!recordFamily) {
      continue;
    }
    const verifierResult = verificationByOperation.get(operation.id) || null;
    const operationEvidence = ckEvidence.filter((command) => command.operationId === operation.id || command.target === operation.target || command.recordFamily === recordFamily);
    const commandEvidence = operationEvidence.filter((command) => command.evidenceClass === "support");
    const discoveryEvidence = operationEvidence.filter((command) => command.evidenceClass === "discovery");
    const commandEvidenceStatus = summarizeCommandEvidence(commandEvidence, operation);
    const coverage = {
      manifestOperation: Boolean(operation.kind),
      backend: Boolean(operation.backend && operation.backend !== "manual-packet"),
      ckpeOrWriterHandler: Boolean(operation.backend && operation.backend !== "manual-packet"),
      ckCommandEvidence: commandEvidenceStatus === "PASS" || commandEvidenceStatus === "NOT_REQUIRED",
      commandEvidence: commandEvidenceStatus === "PASS" || commandEvidenceStatus === "NOT_REQUIRED",
      readbackNormalizer: Boolean(verifierResult?.details?.readbackNormalizer?.status === "PASS" || (verifierResult && verifierResult.status === "PASS")),
      verifier: Boolean(verifierResult && verifierResult.status === "PASS"),
      strictReport: strictPassed,
      proofFixture: Boolean(options.fixture || report.reportPath || report.manifest?.project),
      supportClaimAllowed: !discoveryOnly
    };
    const missingCoverage = Object.entries(coverage)
      .filter(([, present]) => !present)
      .map(([name]) => name);

    proofs.push({
      id: `${recordFamily}:${operation.kind}:${operation.target}`,
      recordFamily,
      status: missingCoverage.length ? "FAIL" : "PASS",
      fixture: options.fixture || report.reportPath || report.manifest?.project || "inline-run-report",
      verifiedAt: generatedAt,
      operation: operation.kind,
      target: operation.target,
      generatedPlugin: report.manifest?.output || null,
      strictReport: report.reportPath || null,
      reportStatus: report.status,
      backend: operation.backend,
      verifierStatus: verifierResult?.status || "MISSING",
      readbackStatus: verifierResult ? (verifierResult.status === "TODO" ? "MISSING" : "PASS") : "MISSING",
      readbackNormalizer: verifierResult?.details?.readbackNormalizer || null,
      commandEvidenceStatus,
      coverage,
      missingCoverage,
      commandEvidence,
      discoveryEvidence,
      discoveryOnly
    });
  }

  return {
    schema: PROOF_LEDGER_SCHEMA,
    generatedAt,
    sourceReport: report.reportPath || null,
    project: report.manifest?.project || null,
    generatedPlugin: report.manifest?.output || null,
    discoveryOnly,
    status: proofs.length && proofs.every((proof) => proof.status === "PASS") ? "PASS" : "FAIL",
    proofs
  };
}

export function flattenProofLedgerResults(document) {
  if (!document) {
    return emptyProofResults();
  }
  if (Array.isArray(document.results)) {
    return document;
  }
  const proofs = Array.isArray(document.proofs) ? document.proofs : [];
  return {
    schema: PROOF_RESULTS_SCHEMA,
    generatedAt: document.generatedAt || new Date().toISOString(),
    sourceLedger: document.sourceReport || null,
    results: proofs.map((proof) => ({
      recordFamily: proof.recordFamily,
      status: proof.status,
      fixture: proof.fixture,
      verifiedAt: proof.verifiedAt,
      operation: proof.operation,
      target: proof.target,
      generatedPlugin: proof.generatedPlugin,
      strictReport: proof.strictReport,
      backend: proof.backend,
      verifierStatus: proof.verifierStatus,
      readbackStatus: proof.readbackStatus,
      commandEvidenceStatus: proof.commandEvidenceStatus,
      coverage: proof.coverage || {},
      missingCoverage: proof.missingCoverage || [],
      discoveryOnly: Boolean(proof.discoveryOnly)
    }))
  };
}

function isDiscoveryOnlyReport(report = {}) {
  const metadata = report.manifest?.metadata || {};
  return metadata.supportClaim === false ||
    metadata.discoveryOnly === true ||
    String(metadata.proofLane || "").toLowerCase().includes("discovery");
}

export function mergeProofResults(documents = [], options = {}) {
  const results = [];
  const sources = [];
  const seen = new Map();

  for (const document of documents) {
    const flattened = flattenProofLedgerResults(document);
    const sourceLedger = document.__sourcePath ||
      flattened.sourceLedger ||
      (document.schema === PROOF_LEDGER_SCHEMA ? document.sourceReport : null);
    if (sourceLedger) {
      sources.push(sourceLedger);
    }
    for (const proof of flattened.results || []) {
      const key = proofResultIdentityKey(proof);
      const mergedProof = {
        ...proof,
        proofLedger: proof.proofLedger || sourceLedger || null
      };
      if (seen.has(key)) {
        const existingIndex = seen.get(key);
        const existing = results[existingIndex];
        if (existing.status !== "PASS" && mergedProof.status === "PASS") {
          results[existingIndex] = mergedProof;
        }
        continue;
      }
      seen.set(key, results.length);
      results.push(mergedProof);
    }
  }

  results.sort((left, right) => {
    return String(left.recordFamily || "").localeCompare(String(right.recordFamily || "")) ||
      String(left.operation || "").localeCompare(String(right.operation || "")) ||
      String(left.target || "").localeCompare(String(right.target || ""));
  });

  return {
    schema: PROOF_RESULTS_SCHEMA,
    generatedAt: new Date().toISOString(),
    sourceLedger: sources.length === 1 ? sources[0] : null,
    sourceLedgers: sources,
    game: options.game || null,
    results
  };
}

function proofResultIdentityKey(proof = {}) {
  return [
    String(proof.recordFamily || "").toUpperCase(),
    proof.operation || "",
    proof.target || ""
  ].join("|");
}

export function verifyProofLedger(ledger) {
  const failures = [];
  if (ledger?.schema !== PROOF_LEDGER_SCHEMA) {
    failures.push({ code: "invalid_schema", message: `Expected ${PROOF_LEDGER_SCHEMA}.` });
  }
  if (!Array.isArray(ledger?.proofs) || !ledger.proofs.length) {
    failures.push({ code: "empty_proofs", message: "Proof ledger contains no proof rows." });
  }
  if (ledger?.status !== "PASS") {
    failures.push({ code: "ledger_status_not_pass", message: `Proof ledger status is ${ledger?.status || "MISSING"}.` });
  }
  for (const proof of ledger?.proofs || []) {
    if (!proof.recordFamily) failures.push({ code: "missing_record_family", proof: proof.id || proof.target });
    if (proof.status === "PASS") {
      const missing = requiredCoverageKeys().filter((key) => proof.coverage?.[key] !== true);
      if (missing.length) {
        failures.push({ code: "passing_proof_missing_coverage", recordFamily: proof.recordFamily, missing });
      }
    }
  }
  return {
    schema: "creation-authoring.proof-ledger-verification.v1",
    status: failures.length ? "FAIL" : "PASS",
    generatedAt: new Date().toISOString(),
    failures
  };
}

export function emptyProofResults() {
  return {
    schema: PROOF_RESULTS_SCHEMA,
    generatedAt: new Date().toISOString(),
    results: []
  };
}

export function requiredCoverageKeys() {
  return [
    "manifestOperation",
    "backend",
    "ckpeOrWriterHandler",
    "ckCommandEvidence",
    "readbackNormalizer",
    "verifier",
    "strictReport",
    "proofFixture"
  ];
}

function verificationResultMap(report) {
  const map = new Map();
  for (const phase of report.phases || []) {
    if (phase.phase !== "verify") {
      continue;
    }
    for (const result of phase.report?.results || []) {
      if (result.operationId) {
        map.set(result.operationId, result);
      }
    }
  }
  return map;
}

function collectCkCommandEvidence(report) {
  const evidence = [];
  for (const phase of report.phases || []) {
    if (phase.phase !== "ck-apply") {
      continue;
    }
    for (const command of phase.adapterResult?.commands || []) {
      const commandEvidence = command.evidence || null;
      evidence.push({
        op: command.op,
        status: command.status,
        target: commandEvidence?.editorId ||
          commandEvidence?.target ||
          commandEvidence?.targetEditorId ||
          commandEvidence?.requested?.targetEditorId ||
          commandEvidence?.requested?.editorId ||
          commandEvidence?.createdRecord?.record?.editorId ||
          command.target ||
          null,
        recordFamily: commandEvidence?.recordFamily ||
          commandEvidence?.requested?.recordFamily ||
          commandEvidence?.createdRecord?.record?.recordFamily ||
          command.recordFamily ||
          null,
        operationId: command.operationId || commandEvidence?.operationId || null,
        activePlugin: commandEvidence?.activePlugin || null,
        observerCapturedCalls: readEvidenceValue(commandEvidence, "observerCapturedCalls"),
        creationObserved: readEvidenceValue(commandEvidence, "creationObserved"),
        candidateComparison: commandEvidence?.candidateComparison || null,
        returnCaptured: readEvidenceValue(commandEvidence, "returnCaptured"),
        returnRax: readEvidenceValue(commandEvidence, "returnRax"),
        discoveryGatePassed: readEvidenceValue(commandEvidence, "discoveryGatePassed"),
        invocationPlan: readEvidenceValue(commandEvidence, "invocationPlan") || null,
        invocationPlanPassed: readEvidenceValue(commandEvidence, "invocationPlanPassed"),
        invocationTarget: readEvidenceValue(commandEvidence, "invocationTarget"),
        mutationReady: readEvidenceValue(commandEvidence, "mutationReady"),
        supportBlockers: readEvidenceValue(commandEvidence, "supportBlockers") || readEvidenceValue(commandEvidence, "blockers") || null,
        postAllocationCandidate: readEvidenceValue(commandEvidence, "postAllocationCandidate"),
        candidateAddress: readEvidenceValue(commandEvidence, "candidateAddress") ?? readEvidenceValue(commandEvidence, "invocationTarget"),
        expectedCreatedFormId: readEvidenceValue(commandEvidence, "expectedCreatedFormId"),
        expectedCreatedFormType: readEvidenceValue(commandEvidence, "expectedCreatedFormType"),
        matchedExpectedCreatedForm: readEvidenceValue(commandEvidence, "matchedExpectedCreatedForm"),
        sidePathReturn: readEvidenceValue(commandEvidence, "sidePathReturn"),
        noisy: readEvidenceValue(commandEvidence, "noisy"),
        wrapperTarget: readEvidenceValue(commandEvidence, "wrapperTarget"),
        callerReturn: readEvidenceValue(commandEvidence, "callerReturn"),
        vtableCall: readEvidenceValue(commandEvidence, "vtableCall"),
        rcxSource: readEvidenceValue(commandEvidence, "rcxSource") ?? readEvidenceValue(commandEvidence, "rcx"),
        rdxValue: readEvidenceValue(commandEvidence, "rdxValue") ?? readEvidenceValue(commandEvidence, "rdx"),
        r8Context: readEvidenceValue(commandEvidence, "r8Context") ?? readEvidenceValue(commandEvidence, "r8"),
        returnedRecord: readEvidenceValue(commandEvidence, "returnedRecord") ?? readEvidenceValue(commandEvidence, "createdRecord"),
        returnedExistingFormId: readEvidenceValue(commandEvidence, "returnedExistingFormId"),
        returnedPointerKind: readEvidenceValue(commandEvidence, "returnedPointerKind") ?? readEvidenceValue(commandEvidence, "returnKind"),
        expectedNewFormId: readEvidenceValue(commandEvidence, "expectedNewFormId"),
        fired: readEvidenceValue(commandEvidence, "fired"),
        fireCount: readEvidenceValue(commandEvidence, "fireCount"),
        booleanReturn: readEvidenceValue(commandEvidence, "booleanReturn"),
        generatedPluginOnly: readEvidenceValue(commandEvidence, "generatedPluginOnly") ?? readEvidenceValue(commandEvidence, "targetIsDisposableGeneratedPlugin"),
        mutationCommitted: readEvidenceValue(commandEvidence, "mutationCommitted") ?? readEvidenceValue(commandEvidence, "mutationApplied"),
        saveCompleted: readEvidenceValue(commandEvidence, "saveCompleted") ?? readEvidenceValue(commandEvidence, "saveSucceeded") ?? readEvidenceValue(commandEvidence, "pluginSaved"),
        evidenceClass: classifyCkCommandEvidence(command),
        evidence: command.evidence || null
      });
    }
  }
  return evidence;
}

function classifyCkCommandEvidence(command) {
  const op = String(command.op || "");
  const commandEvidence = command.evidence || {};
  if (commandEvidence.evidenceClass === "discovery") {
    return "discovery";
  }
  if (op.startsWith("inspect") || op.startsWith("arm") || op.startsWith("disarm")) {
    return "discovery";
  }
  if (op === "createRecord" && !hasCreateRecordSupportEvidence(commandEvidence)) {
    return "discovery";
  }
  if (commandEvidence.evidenceClass) {
    return commandEvidence.evidenceClass;
  }
  if (op.includes("Observer") || op.includes("ReturnCapture") || op.includes("FactoryReturn") || op.includes("Wrapper") || op.includes("Caller")) {
    return "discovery";
  }
  if (readEvidenceValue(commandEvidence, "returnCaptured") !== undefined || readEvidenceValue(commandEvidence, "discoveryGatePassed") !== undefined) {
    return "discovery";
  }
  if (readEvidenceValue(commandEvidence, "mutationReady") === false ||
    readEvidenceValue(commandEvidence, "returnedExistingFormId") !== undefined ||
    readEvidenceValue(commandEvidence, "returnedPointerKind") !== undefined ||
    readEvidenceValue(commandEvidence, "returnKind") !== undefined ||
    readEvidenceValue(commandEvidence, "booleanReturn") !== undefined ||
    readEvidenceValue(commandEvidence, "fireCount") !== undefined ||
    readEvidenceValue(commandEvidence, "postAllocationCandidate") !== undefined ||
    readEvidenceValue(commandEvidence, "matchedExpectedCreatedForm") !== undefined ||
    readEvidenceValue(commandEvidence, "sidePathReturn") !== undefined ||
    readEvidenceValue(commandEvidence, "noisy") !== undefined) {
    return "discovery";
  }
  if (commandEvidence.observerCapturedCalls === false || commandEvidence.implementationRule?.includes("does not prove call interception")) {
    return "discovery";
  }
  if (commandEvidence.prototypeRule || commandEvidence.blockedAt) {
    return "discovery";
  }
  return "support";
}

function hasCreateRecordSupportEvidence(evidence) {
  const generatedPluginOnly = readEvidenceValue(evidence, "generatedPluginOnly") === true ||
    readEvidenceValue(evidence, "targetIsDisposableGeneratedPlugin") === true ||
    readEvidenceValue(evidence, "activeGeneratedPluginOnly") === true;
  const mutationCommitted = readEvidenceValue(evidence, "mutationCommitted") === true ||
    readEvidenceValue(evidence, "mutationApplied") === true ||
    readEvidenceValue(evidence, "recordInserted") === true;
  const saveCompleted = readEvidenceValue(evidence, "saveCompleted") === true ||
    readEvidenceValue(evidence, "saveSucceeded") === true ||
    readEvidenceValue(evidence, "pluginSaved") === true;
  return generatedPluginOnly && mutationCommitted && saveCompleted;
}

function readEvidenceValue(evidence, key) {
  if (!evidence || typeof evidence !== "object") {
    return undefined;
  }
  if (Object.prototype.hasOwnProperty.call(evidence, key)) {
    return evidence[key];
  }
  for (const nestedKey of ["delta", "guards", "mutation", "save", "returnCapture", "returnObserver", "factoryReturn", "invocationPlan", "wrapperCall", "callerProof", "registers", "candidateResult", "callResult", "attemptResult", "probeResult", "postAllocationProof"]) {
    const nested = evidence[nestedKey];
    if (nested && typeof nested === "object" && Object.prototype.hasOwnProperty.call(nested, key)) {
      return nested[key];
    }
  }
  return undefined;
}

function summarizeCommandEvidence(commandEvidence, operation) {
  if (!operation.ckSemanticsRequired && operation.backend !== "ckpe-bridge") {
    return "NOT_REQUIRED";
  }
  if (!commandEvidence.length) {
    return "MISSING";
  }
  return commandEvidence.every((command) => command.status === "PASS") ? "PASS" : "FAIL";
}
