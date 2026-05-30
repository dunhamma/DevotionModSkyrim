import fs from "node:fs";
import path from "node:path";
import { promoteRunReport } from "./promotion.mjs";
import { STRICT_BLOCKING_PHASE_STATUSES } from "./release-status.mjs";

export async function checkPromotionCandidateDryRun(runReport, profile, options = {}) {
  const sourcePath = options.sourcePath || runReport.manifest?.sourcePlugin || profile.sourcePlugin || null;
  const generatedPath = options.generatedPath || runReport.manifest?.output || profile.defaultOutput || null;
  const candidatePath = options.mergeOutputPath || options.outputPath || null;
  const before = capturePathStates({ sourcePath, generatedPath, candidatePath });

  const promotionReport = await promoteRunReport(runReport, profile, {
    ...options,
    dryRun: true,
    postMergeVerifier: options.postMergeVerifier || createDryRunPostMergeVerifier({ sourcePath, generatedPath, candidatePath })
  });
  const stablePromotionReport = sanitizePromotionReport(promotionReport);

  const after = capturePathStates({ sourcePath, generatedPath, candidatePath });
  const phases = promotionReport.phases || [];
  const phaseMap = new Map(phases.map((phase) => [phase.phase, phase]));
  const failures = [];

  requirePhaseStatus(phaseMap, "promotion-gates", ["PASS"], failures);
  requirePhaseStatus(phaseMap, "backup", ["PASS"], failures);
  requirePhaseStatus(phaseMap, "structured-merge", ["PASS"], failures);

  if (!options.approved) {
    failures.push("Promotion candidate dry-run proof requires explicit approval.");
  }
  if (!candidatePath) {
    failures.push("Promotion candidate dry-run proof requires an explicit candidate output path.");
  }
  if (!options.mergeRunner) {
    failures.push("Promotion candidate dry-run proof requires a merge runner adapter.");
  }

  const structuredMerge = phaseMap.get("structured-merge");
  const runnerReport = structuredMerge?.result?.report || null;
  if (structuredMerge?.status === "PASS") {
    if (!runnerReport?.dryRun) {
      failures.push("Structured merge runner did not report dryRun=true.");
    }
    if (runnerReport?.status !== "PASS") {
      failures.push("Structured merge runner report did not pass.");
    }
    if (!sameResolvedPath(runnerReport?.outputPath, candidatePath)) {
      failures.push("Structured merge runner output path did not match the candidate output path.");
    }
  }

  for (const change of changedPaths(before, after)) {
    failures.push(`Promotion candidate dry-run changed ${change.label} path: ${change.path}.`);
  }

  const strictBlockers = phases.filter((phase) => STRICT_BLOCKING_PHASE_STATUSES.has(phase.status));
  const releaseBlockers = strictBlockers.map((phase) => ({
    phase: phase.phase,
    status: phase.status,
    message: phase.message || null
  }));
  if (!failures.length) {
    releaseBlockers.push({
      phase: "live-post-merge-verify",
      status: "REQUESTED",
      message: "Repo-local dry-run proof passed, but live post-merge readback and project verifier evidence are still required for release readiness."
    });
  }

  return {
    schema: "creation-authoring.promotion-candidate-check.v1",
    status: failures.length ? "FAIL" : "PASS",
    releaseReady: false,
    failures,
    releaseBlockers,
    sourcePath,
    generatedPath,
    candidatePath,
    dryRun: true,
    phaseStatuses: Object.fromEntries(phases.map((phase) => [phase.phase, phase.status])),
    fileStates: { before, after },
    promotionReport: stablePromotionReport
  };
}

function createDryRunPostMergeVerifier({ sourcePath, generatedPath, candidatePath }) {
  return async ({ mergeRequest, mergeResult, ckFinalizerResult, postMergeVerifyRequest }) => {
    const blockers = [];
    if (postMergeVerifyRequest?.schema !== "creation-authoring.post-merge-verify-request.v1") {
      blockers.push("Post-merge verify request schema is missing or unsupported.");
    }
    if (!postMergeVerifyRequest?.requiresCandidateWinnerProof) {
      blockers.push("Post-merge verify request must require candidate winner proof.");
    }
    if (!postMergeVerifyRequest?.requiresProjectVerifierPass) {
      blockers.push("Post-merge verify request must require project verifier PASS.");
    }
    if (!candidatePath || !sameResolvedPath(postMergeVerifyRequest?.candidatePlugin, candidatePath)) {
      blockers.push("Post-merge verify request candidate does not match the reviewed candidate path.");
    }
    if (sourcePath && !sameResolvedPath(postMergeVerifyRequest?.sourcePlugin, sourcePath) && path.basename(String(sourcePath)).toLowerCase() !== String(postMergeVerifyRequest?.sourcePlugin || "").toLowerCase()) {
      blockers.push("Post-merge verify request source plugin does not match the promotion source.");
    }
    if (generatedPath && !sameResolvedPath(postMergeVerifyRequest?.generatedPlugin, generatedPath) && path.basename(String(generatedPath)).toLowerCase() !== String(postMergeVerifyRequest?.generatedPlugin || "").toLowerCase()) {
      blockers.push("Post-merge verify request generated plugin does not match the promotion generated output.");
    }

    const mergeReport = mergeResult?.report || {};
    if (mergeResult?.status !== "PASS" || mergeReport.status !== "PASS") {
      blockers.push("Structured merge dry-run must PASS before post-merge verifier dry-run can pass.");
    }
    if (mergeReport.dryRun !== true) {
      blockers.push("Structured merge report must prove dryRun=true.");
    }
    if (!sameResolvedPath(mergeReport.outputPath, candidatePath)) {
      blockers.push("Structured merge report output path does not match the reviewed candidate path.");
    }
    const mergeOperationIds = new Set((mergeRequest?.operations || []).map((operation) => operation.id).filter(Boolean));
    const verifyOperationIds = new Set((postMergeVerifyRequest?.operations || []).map((operation) => operation.id).filter(Boolean));
    const missing = [...mergeOperationIds].filter((id) => !verifyOperationIds.has(id));
    if (missing.length) {
      blockers.push(`Post-merge verify request is missing promoted operations: ${missing.join(", ")}.`);
    }
    if (ckFinalizerResult && !["PASS", "SKIPPED"].includes(ckFinalizerResult.status)) {
      blockers.push(`CK finalizer status is ${ckFinalizerResult.status}; expected PASS or SKIPPED.`);
    }

    return {
      status: blockers.length ? "FAIL" : "PASS",
      mode: "repo-local-dry-run",
      verifier: "promotion-candidate-post-merge-contract",
      candidatePath,
      operationCount: verifyOperationIds.size,
      blockers
    };
  };
}

export function formatPromotionCandidateCheck(report, written = null) {
  const lines = [
    `Promotion candidate proof: ${report.status}`,
    `Release ready: ${report.releaseReady ? "yes" : "no"}`,
    `Source plugin: ${report.promotionReport?.sourcePlugin || report.sourcePath}`,
    `Generated plugin: ${report.promotionReport?.generatedPlugin || report.generatedPath}`,
    `Candidate plugin: ${report.promotionReport?.candidatePlugin || report.candidatePath}`
  ];
  for (const [phase, status] of Object.entries(report.phaseStatuses || {})) {
    lines.push(`- [${status}] ${phase}`);
  }
  for (const blocker of report.releaseBlockers || []) {
    lines.push(`  release blocker: ${blocker.phase} ${blocker.status}`);
  }
  for (const failure of report.failures || []) {
    lines.push(`  failure: ${failure}`);
  }
  if (written) {
    lines.push(`Promotion candidate check: ${written}`);
  }
  return `${lines.join("\n")}\n`;
}

function requirePhaseStatus(phaseMap, phaseName, allowedStatuses, failures) {
  const phase = phaseMap.get(phaseName);
  if (!phase) {
    failures.push(`Promotion candidate dry-run did not emit ${phaseName}.`);
    return;
  }
  if (!allowedStatuses.includes(phase.status)) {
    failures.push(`${phaseName} status was ${phase.status}; expected ${allowedStatuses.join(" or ")}.`);
  }
}

function capturePathStates(paths) {
  return Object.fromEntries(Object.entries(paths).map(([label, value]) => [label, capturePathState(value)]));
}

function capturePathState(value) {
  if (!value) {
    return { path: null, exists: false };
  }
  const resolved = path.resolve(String(value));
  if (!fs.existsSync(resolved)) {
    return { path: resolved, exists: false };
  }
  const stat = fs.statSync(resolved);
  return {
    path: resolved,
    exists: true,
    size: stat.size,
    mtimeMs: stat.mtimeMs
  };
}

function changedPaths(before, after) {
  return Object.entries(before)
    .filter(([label, state]) => !samePathState(state, after[label]))
    .map(([label, state]) => ({ label, path: after[label]?.path || state.path }));
}

function samePathState(left, right) {
  return Boolean(left) &&
    Boolean(right) &&
    left.path === right.path &&
    left.exists === right.exists &&
    left.size === right.size &&
    left.mtimeMs === right.mtimeMs;
}

function sameResolvedPath(left, right) {
  if (!left || !right) {
    return false;
  }
  return path.resolve(String(left)).toLowerCase() === path.resolve(String(right)).toLowerCase();
}

function sanitizePromotionReport(report) {
  return {
    ...report,
    startedAt: undefined,
    finishedAt: undefined,
    phases: (report.phases || []).map((phase) => sanitizePhase(phase))
  };
}

function sanitizePhase(phase) {
  const sanitized = phase.backupRequest
    ? {
      ...phase,
      backupRequest: {
        ...phase.backupRequest,
        backupId: "<dry-run-backup-id>"
      }
    }
    : phase;
  if (!phase.result) {
    return sanitized;
  }
  return {
    ...sanitized,
    result: sanitizeRunnerResult(phase.result)
  };
}

function sanitizeRunnerResult(result) {
  return {
    status: result.status,
    exitCode: result.exitCode,
    mode: result.mode,
    verifier: result.verifier,
    operationCount: result.operationCount,
    blockers: result.blockers,
    runnerProject: result.runnerProject,
    sourcePath: result.sourcePath,
    generatedPath: result.generatedPath,
    outputPath: result.outputPath,
    report: result.report || null
  };
}
