import path from "node:path";
import { writeJson } from "./io.mjs";
import { validateShipPathLoadSet } from "./load-set-proof.mjs";
import { normalizeRunnerStatus, PASS_PHASE_STATUSES, summarizePhaseStatuses } from "./release-status.mjs";

const DISCOVERY_ONLY_PATTERN = /(discover|discovery|observer|observe|trace|surface|inspect|introspect|wrapper|caller|contract|invocationPlan|mutationReady|sourceLookup|lookup|template|selector|context|init|guard|boolean|candidate|postAllocation|post-allocation|rdx|register|ownership|dirty|missed|noisy|readback|report)/i;
const CK_NON_MUTATING_OPS = new Set([
  "openProject",
  "getActivePlugin",
  "version",
  "environment",
  "capabilities",
  "loadPlugin",
  "loadPluginSet",
  "setActivePlugin",
  "savePlugin",
  "findRecord",
  "findRecordByEditorId",
  "findRecordByFormId",
  "closeSafeStatus",
  "armGlobCreateObserver",
  "disarmGlobCreateObserver",
  "observeGlobCreate",
  "discoverRecordSurface",
  "traceRecordSurface",
  "inspectGlobCreateRecordInvocationPlan"
]);

export async function promoteRunReport(runReport, profile, options = {}) {
  const startedAt = new Date();
  const gates = evaluatePromotionGates(runReport, profile, options);
  const phases = [
    {
      phase: "promotion-gates",
      status: gates.ready ? "PASS" : "UNSAFE_BLOCKED",
      gates
    }
  ];

  if (!gates.ready) {
    return finalizePromotion({ runReport, profile, phases, startedAt, options });
  }

  const backupRequest = buildBackupRequest(runReport, profile, options);
  const backupResult = options.backupRunner ? await options.backupRunner(backupRequest, { runReport, profile }) : null;
  phases.push({
    phase: "backup",
    status: options.backupRunner ? normalizeRunnerStatus(backupResult) : "REQUESTED",
    message: options.backupRunner
      ? "Backup runner completed."
      : "Timestamped source/generated artifact backup is required before source-plugin promotion.",
    backupRequest,
    result: backupResult
  });

  const mergeRequest = buildStructuredMergeRequest(runReport, profile, options);
  const mergeResult = options.mergeRunner ? await options.mergeRunner(mergeRequest, { runReport, profile }) : null;
  phases.push({
    phase: "structured-merge",
    status: options.mergeRunner ? normalizeRunnerStatus(mergeResult) : "REQUESTED",
    message: options.mergeRunner
      ? "Structured merge runner completed."
      : "A host merge adapter must copy approved generated records into the source plugin.",
    mergeRequest,
    result: mergeResult
  });

  const needsCkFinalization = Boolean(options.forceCkFinalization) ||
    mergeRequest.operations.some((operation) => operation.mergePolicy?.requiresCkFinalization || operation.ckSemanticsRequired);
  const ckFinalizerResult = needsCkFinalization && options.ckFinalizer
    ? await options.ckFinalizer(mergeRequest, { runReport, profile })
    : null;
  phases.push({
    phase: "ck-finalization",
    status: needsCkFinalization ? options.ckFinalizer ? normalizeRunnerStatus(ckFinalizerResult) : "REQUESTED" : "SKIPPED",
    message: needsCkFinalization
      ? options.ckFinalizer
        ? "CK finalizer completed."
        : "CK finalization is required for at least one promoted operation."
      : "No promoted operation declared CK finalization.",
    result: ckFinalizerResult
  });

  const postMergeVerifierResult = options.postMergeVerifier
    ? await options.postMergeVerifier({
        runReport,
        profile,
        mergeRequest,
        backupResult,
        mergeResult,
        ckFinalizerResult,
        postMergeVerifyRequest: buildPostMergeVerifyRequest(runReport, profile, mergeRequest, options)
      })
    : null;
  phases.push({
    phase: "post-merge-verify",
    status: options.postMergeVerifier ? normalizeRunnerStatus(postMergeVerifierResult) : "REQUESTED",
    message: options.postMergeVerifier
      ? "Post-merge verifier completed."
      : "A host adapter must verify live source-plugin state after promotion.",
    postMergeVerifyRequest: buildPostMergeVerifyRequest(runReport, profile, mergeRequest, options),
    result: postMergeVerifierResult
  });

  return finalizePromotion({ runReport, profile, phases, startedAt, options });
}

export function evaluatePromotionGates(runReport, profile, options = {}) {
  const phaseFailures = (runReport.phases || []).filter((phase) => !PASS_PHASE_STATUSES.has(phase.status));
  const manualPackets = runReport.manualPackets || [];
  const approved = Boolean(options.approved);
  const sourcePolicyOk = profile.outputPolicy !== "in-place-explicit" || Boolean(options.allowSourceMutation);
  const generatedOutput = runReport.manifest?.output || profile.defaultOutput || null;
  const sourcePath = options.sourcePath || runReport.manifest?.sourcePlugin || profile.sourcePlugin || null;
  const mergeOutputPath = options.mergeOutputPath || null;
  const directSourceOverwrite = Boolean(sourcePath && mergeOutputPath && samePath(sourcePath, mergeOutputPath));
  const strictGate = (runReport.phases || []).find((phase) => phase.phase === "strict-gate");
  const verificationGate = evaluateReadbackProof(runReport);
  const mutationGate = evaluateMutationProof(runReport, generatedOutput);
  const operationGate = evaluatePromotableOperations(runReport);
  const candidateGate = evaluateCandidateOutput(runReport, profile, options);
  const createRecordGate = evaluateCreateRecordPromotion(runReport, options.proofLedger, generatedOutput);

  const blockers = [];
  if (runReport.status !== "PASS") {
    blockers.push(`Run report status is ${runReport.status}; only PASS reports are mergeable.`);
  }
  if (phaseFailures.length) {
    blockers.push("One or more run phases did not pass.");
  }
  if (manualPackets.length) {
    blockers.push("Manual packets are present; unsupported work cannot be promoted as automated.");
  }
  if (strictGate?.status !== "PASS") {
    blockers.push("Promotion requires a strict-gate PASS from a strict proof run.");
  }
  if (!operationGate.ready) {
    blockers.push(...operationGate.blockers);
  }
  if (!mutationGate.ready) {
    blockers.push(...mutationGate.blockers);
  }
  if (!verificationGate.ready) {
    blockers.push(...verificationGate.blockers);
  }
  if (!approved) {
    blockers.push("Human review approval was not recorded.");
  }
  if (!sourcePolicyOk) {
    blockers.push("Profile allows direct source mutation only with explicit promotion approval.");
  }
  if (directSourceOverwrite && !options.allowSourceMutation) {
    blockers.push("Promotion output resolves to the source plugin; Platform v1 requires candidate output unless source mutation is explicitly allowed.");
  }
  if (!generatedOutput) {
    blockers.push("Run report does not identify a generated output plugin.");
  }
  if (!candidateGate.ready) {
    blockers.push(...candidateGate.blockers);
  }
  if (!createRecordGate.ready) {
    blockers.push(...createRecordGate.blockers);
  }

  return {
    ready: blockers.length === 0,
    blockers,
    approved,
    generatedOutput,
    strictProof: strictGate?.status === "PASS",
    mutationProof: mutationGate,
    readbackProof: verificationGate,
    promotableOperations: operationGate,
    candidateOutput: candidateGate,
    createRecordPromotion: createRecordGate,
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    candidateOutputPath: mergeOutputPath,
    directSourceOverwrite,
    requiresBackup: true,
    requiresStructuredMerge: true,
    requiresRollbackMetadata: true,
    requiresPostMergeVerify: true
  };
}

export function buildStructuredMergeRequest(runReport, profile, options = {}) {
  const operations = collectOperations(runReport);
  return {
    schema: "creation-authoring.structured-merge-request.v1",
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
    candidatePlugin: options.mergeOutputPath || null,
    preserveFormIds: options.preserveFormIds || "when-safe",
    remapPolicy: "deterministic",
    conflictPolicy: "fail-unless-declared",
    operations: operations.map((operation) => ({
      id: operation.id,
      kind: operation.kind,
      target: operation.target,
      mode: operation.mode,
      onConflict: operation.onConflict,
      recordFamily: operation.recordFamily,
      ckSemanticsRequired: operation.ckSemanticsRequired,
      mergePolicy: operation.mergePolicy,
      reviewIntent: operation.reviewIntent
    }))
  };
}

export function buildBackupRequest(runReport, profile, options = {}) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const backupRoot = options.backupRoot || profile.backupDir || path.join(profile.reportsDir || "reports", "promotion-backups");
  return {
    schema: "creation-authoring.backup-request.v1",
    backupId: `${profile.modId}-${timestamp}`,
    backupRoot,
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
    candidatePlugin: options.mergeOutputPath || null,
    includeArtifacts: ["seq", "lip", "facegen", "reports"],
    rollbackMetadata: {
      required: true,
      touchedFiles: [
        runReport.manifest?.sourcePlugin || profile.sourcePlugin,
        runReport.manifest?.output || profile.defaultOutput,
        options.mergeOutputPath || null
      ].filter(Boolean),
      restoreStrategy: "restore timestamped backups before re-running post-merge verification"
    }
  };
}

export function buildPostMergeVerifyRequest(runReport, profile, mergeRequest, options = {}) {
  const operations = mergeRequest?.operations || collectOperations(runReport);
  const candidatePlugin = options.mergeOutputPath || null;
  const sourcePlugin = runReport.manifest?.sourcePlugin || profile.sourcePlugin;
  const generatedPlugin = runReport.manifest?.output || profile.defaultOutput;

  return {
    schema: "creation-authoring.post-merge-verify-request.v1",
    sourcePlugin,
    generatedPlugin,
    candidatePlugin,
    requiresGeneratedFirstProof: true,
    requiresCandidateWinnerProof: true,
    requiresProjectVerifierPass: true,
    requiredOutcomes: [
      "candidate load state is explicit and writable",
      "candidate plugin wins readback for every promoted operation",
      "project verifier passes against candidate output"
    ],
    operations: operations.map((operation) => ({
      id: operation.id,
      kind: operation.kind,
      target: operation.target,
      recordFamily: operation.recordFamily || "unknown",
      ckSemanticsRequired: Boolean(operation.ckSemanticsRequired)
    }))
  };
}

function collectOperations(runReport) {
  if (Array.isArray(runReport.planOperations) && runReport.planOperations.length) {
    return runReport.planOperations;
  }
  return (runReport.phases || [])
    .flatMap((phase) => phase.patchRequest?.records || [])
    .map((record, index) => ({
      id: record.id || `merge-${index + 1}`,
      kind: record.kind || "record.merge",
      target: record.editor_id || record.formid || `record-${index + 1}`,
      mode: record.mode || "update",
      onConflict: record.onConflict || "fail",
      recordFamily: record.record_type || "unknown",
      ckSemanticsRequired: false,
      mergePolicy: { promote: "reviewed", preserveFormId: "when-safe" },
      reviewIntent: null
    }));
}

function evaluatePromotableOperations(runReport) {
  const operations = runReport.planOperations || [];
  const blockers = [];
  if (!operations.length) {
    blockers.push("Promotion requires at least one planned operation; raw proof/discovery reports are not promotable.");
  }
  const proofOnly = operations.filter((operation) => {
    return DISCOVERY_ONLY_PATTERN.test([operation.kind, operation.id, operation.backend].filter(Boolean).join(" "));
  });
  if (proofOnly.length) {
    blockers.push(`Proof-only discovery or observer operations are not promotable: ${proofOnly.map((operation) => operation.id || operation.kind).join(", ")}.`);
  }
  return {
    ready: blockers.length === 0,
    blockers,
    operationCount: operations.length
  };
}

function evaluateMutationProof(runReport, generatedOutput) {
  const blockers = [];
  const phases = runReport.phases || [];
  const applyPhase = phases.find((phase) => phase.phase === "apply");
  const ckApplyPhase = phases.find((phase) => phase.phase === "ck-apply");
  const patchRecords = applyPhase?.patchRequest?.records || [];
  const applyGenerated = !generatedOutput || applyPhase?.patchRequest?.output_name === generatedOutput || applyPhase?.writerResult?.output === generatedOutput;
  const patchMutation = applyPhase?.status === "PASS" && patchRecords.length > 0 && applyGenerated;
  const ckMutationCommands = collectMutatingCkCommands(ckApplyPhase);
  const ckGenerated = !generatedOutput || ckApplyPhase?.packet?.generatedPlugin === generatedOutput || ckApplyPhase?.adapterResult?.generatedPlugin === generatedOutput;
  const ckMutation = ckApplyPhase?.status === "PASS" && ckMutationCommands.length > 0 && ckGenerated;

  if (!patchMutation && !ckMutation) {
    blockers.push("Promotion requires PASS mutation evidence against the generated output plugin; discovery, observer, or requested-only reports are not enough.");
  }
  return {
    ready: blockers.length === 0,
    blockers,
    patchMutation,
    ckMutation,
    mutatingCkCommands: ckMutationCommands.map((command) => command.op)
  };
}

function collectMutatingCkCommands(ckApplyPhase) {
  const commands = ckApplyPhase?.adapterResult?.commands || ckApplyPhase?.packet?.commands || [];
  return commands.filter((command) => {
    if (command.status && command.status !== "PASS") {
      return false;
    }
    if (!command.op || CK_NON_MUTATING_OPS.has(command.op) || DISCOVERY_ONLY_PATTERN.test(command.op)) {
      return false;
    }
    return true;
  });
}

function evaluateReadbackProof(runReport) {
  const blockers = [];
  const verifyPhase = (runReport.phases || []).find((phase) => phase.phase === "verify");
  const results = verifyPhase?.report?.results || [];
  const operationIds = new Set((runReport.planOperations || []).map((operation) => operation.id).filter(Boolean));
  const passingIds = new Set(results.filter((result) => result.status === "PASS" && result.operationId).map((result) => result.operationId));

  if (verifyPhase?.status !== "PASS") {
    blockers.push("Promotion requires a verifier/readback phase with PASS status.");
  }
  if (!results.length) {
    blockers.push("Promotion requires operation-level readback verifier results.");
  }
  if (results.some((result) => result.status !== "PASS")) {
    blockers.push("Promotion requires all readback verifier results to PASS.");
  }
  const missing = [...operationIds].filter((id) => !passingIds.has(id));
  if (missing.length) {
    blockers.push(`Promotion requires PASS readback proof for every planned operation; missing: ${missing.join(", ")}.`);
  }

  return {
    ready: blockers.length === 0,
    blockers,
    verifiedOperations: passingIds.size
  };
}

function evaluateCandidateOutput(runReport, profile, options) {
  const blockers = [];
  const sourcePlugin = runReport.manifest?.sourcePlugin || profile.sourcePlugin;
  const generatedPlugin = runReport.manifest?.output || profile.defaultOutput;
  const candidate = options.mergeOutputPath || options.outputPath || null;
  if (!candidate) {
    blockers.push("Promotion requires an explicit reviewed candidate output path.");
  }
  if (candidate && samePathOrName(candidate, sourcePlugin)) {
    blockers.push("Promotion merge output must be a candidate path, not the source plugin.");
  }
  if (candidate && samePathOrName(candidate, generatedPlugin)) {
    blockers.push("Promotion merge output must be a candidate path, not the generated proof plugin.");
  }
  return {
    ready: blockers.length === 0,
    blockers,
    candidateOutput: candidate
  };
}

function evaluateCreateRecordPromotion(runReport, proofLedger, generatedOutput) {
  const createOperations = (runReport.planOperations || []).filter((operation) => {
    return operation.kind === "record.create" || operation.kind === "quest.create";
  });
  const ckCreateCommands = collectCreateRecordCommands(runReport);
  const blockers = [];

  if (!createOperations.length && !ckCreateCommands.length) {
    return {
      ready: true,
      blockers,
      createOperationCount: 0,
      activeGeneratedPlugin: false,
      proofLedger: "NOT_REQUIRED"
    };
  }

  if (hasUnsafeBlockedResult(runReport)) {
    blockers.push("createRecord promotion requires a run report with no UNSAFE_BLOCKED phase or command results.");
  }
  if (!hasActiveGeneratedPluginProof(runReport, generatedOutput)) {
    blockers.push("createRecord promotion requires CK loadPluginSet PASS evidence for the generated plugin.");
  }
  if (!hasGeneratedPluginSaveProof(runReport, generatedOutput)) {
    blockers.push("createRecord promotion requires generated plugin save PASS evidence.");
  }
  if (!createRecordCommandsTargetGeneratedPlugin(ckCreateCommands, generatedOutput)) {
    blockers.push("createRecord promotion requires every createRecord command to target the generated plugin only.");
  }
  const ledgerGate = evaluateCreateRecordProofLedger(createOperations, proofLedger);
  if (!ledgerGate.ready) {
    blockers.push(...ledgerGate.blockers);
  }

  return {
    ready: blockers.length === 0,
    blockers,
    createOperationCount: createOperations.length,
    activeGeneratedPlugin: hasActiveGeneratedPluginProof(runReport, generatedOutput),
    savedGeneratedPlugin: hasGeneratedPluginSaveProof(runReport, generatedOutput),
    proofLedger: ledgerGate
  };
}

function collectCreateRecordCommands(runReport) {
  return (runReport.phases || [])
    .filter((phase) => phase.phase === "ck-apply")
    .flatMap((phase) => phase.adapterResult?.commands || phase.packet?.commands || [])
    .filter((command) => command.op === "createRecord");
}

function hasUnsafeBlockedResult(value) {
  if (!value || typeof value !== "object") {
    return false;
  }
  if (value.status === "UNSAFE_BLOCKED") {
    return true;
  }
  if (Array.isArray(value)) {
    return value.some((item) => hasUnsafeBlockedResult(item));
  }
  return Object.values(value).some((item) => hasUnsafeBlockedResult(item));
}

function hasActiveGeneratedPluginProof(runReport, generatedOutput) {
  if (!generatedOutput) {
    return false;
  }
  return (runReport.phases || [])
    .filter((phase) => phase.phase === "ck-apply")
    .some((phase) => {
      const commands = phase.adapterResult?.commands || [];
      return validateShipPathLoadSet(commands, {
        expectedActivePlugin: generatedOutput,
        expectedSaveTarget: generatedOutput
      }).status === "PASS";
    });
}

function hasGeneratedPluginSaveProof(runReport, generatedOutput) {
  if (!generatedOutput) {
    return false;
  }
  const commands = (runReport.phases || [])
    .filter((phase) => phase.phase === "ck-apply")
    .flatMap((phase) => phase.adapterResult?.commands || []);
  return commands.some((command) => {
    return ["savePlugin", "postUiSaveCommand"].includes(command.op) &&
      command.status === "PASS" &&
      samePathOrName(command.evidence?.plugin || command.evidence?.requestedPlugin || command.plugin, generatedOutput);
  });
}

function createRecordCommandsTargetGeneratedPlugin(commands, generatedOutput) {
  if (!generatedOutput) {
    return false;
  }
  return commands.every((command) => {
    const targetPlugin = command.plugin || command.payload?.plugin || command.evidence?.plugin || command.evidence?.requestedPlugin || null;
    return !targetPlugin || samePathOrName(targetPlugin, generatedOutput);
  });
}

function evaluateCreateRecordProofLedger(createOperations, proofLedger) {
  const blockers = [];
  if (!proofLedger) {
    return {
      ready: false,
      blockers: ["createRecord promotion requires an explicit PASS proof ledger."],
      status: "MISSING"
    };
  }
  if (proofLedger.status !== "PASS" || proofLedger.verification?.status !== "PASS") {
    blockers.push("createRecord promotion requires a proof ledger with PASS status and PASS verification.");
  }

  const proofs = Array.isArray(proofLedger.proofs) ? proofLedger.proofs : [];
  for (const operation of createOperations) {
    const proof = proofs.find((item) => {
      return item.status === "PASS" &&
        (item.operationId === operation.id || item.operation === operation.kind) &&
        item.target === operation.target;
    });
    if (!proof) {
      blockers.push(`createRecord promotion requires PASS proof-ledger evidence for ${operation.id || operation.target}.`);
      continue;
    }
    if (proof.commandEvidenceStatus !== "PASS") {
      blockers.push(`createRecord proof for ${operation.id || operation.target} must include PASS CK command evidence.`);
    }
  }

  return {
    ready: blockers.length === 0,
    blockers,
    status: proofLedger.status || "UNKNOWN",
    proofCount: proofs.length
  };
}

function samePathOrName(left, right) {
  if (!left || !right) {
    return false;
  }
  const normalizedLeft = path.normalize(String(left)).toLowerCase();
  const normalizedRight = path.normalize(String(right)).toLowerCase();
  return normalizedLeft === normalizedRight || path.basename(normalizedLeft) === path.basename(normalizedRight);
}

function finalizePromotion({ runReport, profile, phases, startedAt, options }) {
  const finishedAt = new Date();
  const report = {
    schema: "creation-authoring.promotion-report.v1",
    status: summarizePhaseStatuses(phases),
    startedAt: startedAt.toISOString(),
    finishedAt: finishedAt.toISOString(),
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
    candidatePlugin: options.mergeOutputPath || null,
    rollbackMetadataRequired: true,
    phases
  };

  if (options.reportPath) {
    report.reportPath = writeJson(options.reportPath, report);
  }

  return report;
}

function samePath(left, right) {
  return String(left || "").replaceAll("\\", "/").toLowerCase() ===
    String(right || "").replaceAll("\\", "/").toLowerCase();
}
