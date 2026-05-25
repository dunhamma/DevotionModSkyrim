import path from "node:path";
import { writeJson } from "./io.mjs";

const PASS_STATUSES = new Set(["PASS", "SKIPPED"]);

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

  const needsCkFinalization = mergeRequest.operations.some((operation) => operation.mergePolicy?.requiresCkFinalization || operation.ckSemanticsRequired);
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
    ? await options.postMergeVerifier({ runReport, profile, mergeRequest })
    : null;
  phases.push({
    phase: "post-merge-verify",
    status: options.postMergeVerifier ? normalizeRunnerStatus(postMergeVerifierResult) : "REQUESTED",
    message: options.postMergeVerifier
      ? "Post-merge verifier completed."
      : "A host adapter must verify live source-plugin state after promotion.",
    result: postMergeVerifierResult
  });

  return finalizePromotion({ runReport, profile, phases, startedAt, options });
}

export function evaluatePromotionGates(runReport, profile, options = {}) {
  const phaseFailures = (runReport.phases || []).filter((phase) => !PASS_STATUSES.has(phase.status));
  const manualPackets = runReport.manualPackets || [];
  const approved = Boolean(options.approved);
  const sourcePolicyOk = profile.outputPolicy !== "in-place-explicit" || Boolean(options.allowSourceMutation);
  const generatedOutput = runReport.manifest?.output || profile.defaultOutput || null;

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
  if (!approved) {
    blockers.push("Human review approval was not recorded.");
  }
  if (!sourcePolicyOk) {
    blockers.push("Profile allows direct source mutation only with explicit promotion approval.");
  }
  if (!generatedOutput) {
    blockers.push("Run report does not identify a generated output plugin.");
  }

  return {
    ready: blockers.length === 0,
    blockers,
    approved,
    generatedOutput,
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    requiresBackup: true,
    requiresStructuredMerge: true,
    requiresPostMergeVerify: true
  };
}

export function buildStructuredMergeRequest(runReport, profile, options = {}) {
  const operations = collectOperations(runReport);
  return {
    schema: "creation-authoring.structured-merge-request.v1",
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
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
    includeArtifacts: ["seq", "lip", "facegen", "reports"],
    rollbackMetadata: true
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

function finalizePromotion({ runReport, profile, phases, startedAt, options }) {
  const finishedAt = new Date();
  const report = {
    schema: "creation-authoring.promotion-report.v1",
    status: summarizePromotion(phases),
    startedAt: startedAt.toISOString(),
    finishedAt: finishedAt.toISOString(),
    sourcePlugin: runReport.manifest?.sourcePlugin || profile.sourcePlugin,
    generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
    phases
  };

  if (options.reportPath) {
    report.reportPath = writeJson(options.reportPath, report);
  }

  return report;
}

function summarizePromotion(phases) {
  if (phases.some((phase) => phase.status === "FAIL" || phase.status === "UNSAFE_BLOCKED")) {
    return "FAIL";
  }
  if (phases.some((phase) => phase.status === "REQUESTED")) {
    return "REQUESTED";
  }
  return "PASS";
}

function normalizeRunnerStatus(result) {
  if (!result) {
    return "FAIL";
  }
  if (result.status === "DEFERRED_TO_MERGE_RUNNER") {
    return "PASS";
  }
  if (result.status === "PASS" || result.status === "SKIPPED") {
    return result.status;
  }
  if (result.status === "REQUESTED") {
    return "REQUESTED";
  }
  return "FAIL";
}
