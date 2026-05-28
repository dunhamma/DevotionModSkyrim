import path from "node:path";
import { createPlan } from "./planner.mjs";
import { executeApply, executeCkApply } from "./executor.mjs";
import { verifyManifest } from "./verifier.mjs";
import { writeJson } from "./io.mjs";
import { runProcess } from "./process-runner.mjs";
import { buildStrictGatePhase, summarizePhaseStatuses } from "./release-status.mjs";
import { findReadbackRecord } from "./readback-oracle.mjs";

export async function runPipeline(manifest, profile, options = {}) {
  const startedAt = new Date();
  const plan = createPlan(manifest, profile, options);
  const manualPackets = plan.operations.filter((item) => item.manualPacket).map((item) => item.manualPacket);
  const phases = [];
  const sequencing = analyzeMixedCkWriterSequence(plan);

  phases.push({
    phase: "plan",
    status: plan.summary.abort ? "FAIL" : "PASS",
    summary: plan.summary
  });

  if (manualPackets.length && !options.allowManualPackets) {
    phases.push({
      phase: "safety-gate",
      status: "UNSAFE_BLOCKED",
      message: "Manual or CK-only operations are present. Re-run with allowManualPackets or provide a verified CK adapter.",
      manualPackets
    });
    return finalizeReport({ manifest, profile, plan, phases, manualPackets, startedAt, options });
  }

  if (sequencing.delayedWriterOperationIds.size) {
    phases.push(await executeApply(plan, {
      patchOptions: options.patchOptions,
      patchWriter: options.patchWriter,
      appliedPatchEvidence: options.appliedPatchEvidence,
      operationFilter: (item) => isPatchOperation(item) && !sequencing.delayedWriterOperationIds.has(item.operation.id)
    }));

    phases.push(await executeCkApply(plan, {
      ckAdapter: options.ckAdapter
    }));

    const payloadGate = await runPostCkPayloadGate({ manifest, profile, plan, phases, options, sequencing });
    if (payloadGate.allowed) {
      const payloadPlan = hydratePlanFromReadback(plan, payloadGate.readback, sequencing.delayedWriterOperationIds);
      phases.push(await executeApply(payloadPlan, {
        patchOptions: options.patchOptions,
        patchWriter: options.patchWriter,
        appliedPatchEvidence: options.appliedPatchEvidence,
        phaseName: "payload-apply",
        operationFilter: (item) => sequencing.delayedWriterOperationIds.has(item.operation.id)
      }));
    } else {
      phases.push({
        schema: "creation-authoring.execution.v1",
        phase: "payload-apply",
        status: "UNSAFE_BLOCKED",
        message: "Payload writer was not executed because post-CK generated identity was not proven."
      });
    }
  } else {
    phases.push(await executeApply(plan, {
      patchOptions: options.patchOptions,
      patchWriter: options.patchWriter,
      appliedPatchEvidence: options.appliedPatchEvidence
    }));

    phases.push(await executeCkApply(plan, {
      ckAdapter: options.ckAdapter
    }));
  }

  if (options.compileRunner) {
    phases.push(await options.compileRunner({ manifest, profile, plan }));
  } else {
    phases.push(await runConfiguredProcesses(profile, "papyrus-compiler", "compile"));
  }

  const readback = options.readback || await collectReadback(manifest, profile, plan, phases, options);
  const verifyReport = verifyManifest(manifest, profile, readback);
  phases.push({
    phase: "verify",
    status: verifyReport.summary.FAIL ? "FAIL" : verifyReport.summary.TODO ? "TODO" : "PASS",
    report: verifyReport
  });

  phases.push(...await runVerifierRules(profile, options));

  if (options.strict) {
    phases.push(buildStrictGatePhase(phases, manualPackets));
  }

  return finalizeReport({ manifest, profile, plan, phases, manualPackets, startedAt, options });
}

export function analyzeMixedCkWriterSequence(plan, options = {}) {
  const createdTargets = new Set();
  const delayedWriterOperationIds = new Set();
  const identityOperationIds = new Set();
  const completedIdentityTargets = new Set(
    [...(options.completedIdentityTargets || [])].map((target) => String(target || "").toLowerCase())
  );

  for (const item of plan.operations) {
    const targetKey = String(item.operation.target || "").toLowerCase();
    if ((item.status === "ready" || completedIdentityTargets.has(targetKey)) &&
        item.operation.kind === "record.duplicate_create") {
      createdTargets.add(targetKey);
      identityOperationIds.add(item.operation.id);
      continue;
    }
    if (item.status === "ready" && isPatchOperation(item) && createdTargets.has(targetKey)) {
      delayedWriterOperationIds.add(item.operation.id);
    }
  }

  return {
    delayedWriterOperationIds,
    identityOperationIds
  };
}

export function hydratePlanFromReadback(plan, readback, operationIds = new Set()) {
  if (!readback || !operationIds.size) {
    return plan;
  }
  return {
    ...plan,
    operations: plan.operations.map((item) => {
      if (!operationIds.has(item.operation.id)) {
        return item;
      }
      const record = findReadbackRecord(readback, item.operation.target, item.targetResolution);
      if (!record) {
        return item;
      }
      return {
        ...item,
        targetResolution: {
          ...item.targetResolution,
          formid: record.formid || record.formId || record.FormID || item.targetResolution?.formid || null,
          editorId: record.editorId || record.EditorID || item.targetResolution?.editorId || item.operation.target,
          recordType: record.recordType || record.type || item.targetResolution?.recordType || item.operation.recordFamily || null,
          plugin: record.plugin || record.generatedPlugin || item.targetResolution?.plugin || null,
          winningPlugin: record.winningPlugin || record.plugin || item.targetResolution?.winningPlugin || null,
          resolved: true
        }
      };
    })
  };
}

function isPatchOperation(item) {
  return ["mutagen-patch-request", "mo2-mcp-patch-request", "xedit-script-request"].includes(item.backend);
}

async function runPostCkPayloadGate({ manifest, profile, plan, phases, options, sequencing }) {
  const ckPhase = phases.findLast?.((phase) => phase.phase === "ck-apply") ||
    [...phases].reverse().find((phase) => phase.phase === "ck-apply");
  if (ckPhase?.status !== "PASS") {
    phases.push({
      phase: "post-ck-identity-gate",
      status: "UNSAFE_BLOCKED",
      message: "Payload writer operations are blocked until CK duplicate/save completes with PASS."
    });
    return { allowed: false, readback: null };
  }

  const readback = options.postCkReadback || options.readback || await collectReadback(manifest, profile, plan, phases, {
    ...options,
    readbackPhase: "post-ck-readback"
  });
  if (!readback) {
    phases.push({
      phase: "post-ck-identity-gate",
      status: "TODO",
      message: "Payload writer operations require generated-plugin identity readback after CK duplicate/save."
    });
    return { allowed: false, readback: null };
  }

  if (options.postCkReadback || options.readback) {
    phases.push({
      phase: "post-ck-readback",
      status: "PASS",
      message: "Supplied readback was used for post-CK generated duplicate identity."
    });
  }

  const identityManifest = {
    ...manifest,
    operations: manifest.operations.filter((operation) => sequencing.identityOperationIds.has(operation.id))
  };
  const identityVerify = verifyManifest(identityManifest, profile, readback);
  phases.push({
    phase: "post-ck-identity-gate",
    status: identityVerify.summary.FAIL ? "FAIL" : identityVerify.summary.TODO ? "TODO" : "PASS",
    message: identityVerify.summary.FAIL || identityVerify.summary.TODO
      ? "Generated duplicate identity is not proven; payload writer is blocked."
      : "Generated duplicate identity is proven for payload writer sequencing.",
    report: identityVerify
  });
  return {
    allowed: !identityVerify.summary.FAIL && !identityVerify.summary.TODO,
    readback
  };
}

async function runConfiguredProcesses(profile, connectorType, phaseName) {
  const connectors = profile.resourceConnectors.filter((connector) => connector.type === connectorType);
  if (!connectors.length) {
    return {
      phase: phaseName,
      status: "SKIPPED",
      message: `No ${connectorType} connector is configured.`
    };
  }

  const results = [];
  for (const connector of connectors) {
    if (!connector.command) {
      results.push({
        name: connector.name || connectorType,
        status: "REQUESTED",
        message: "Connector is declared but has no local command. A host adapter must execute it."
      });
      continue;
    }
    results.push({
      name: connector.name || connectorType,
      ...await runProcess(connector.command, connector.args || [], { cwd: connector.cwd })
    });
  }

  return {
    phase: phaseName,
    status: summarizeConnectorResults(results),
    results
  };
}

async function runVerifierRules(profile, options) {
  if (options.verifierRunner) {
    return [await options.verifierRunner({ profile })];
  }

  const connectors = profile.resourceConnectors.filter((connector) => connector.type === "pdv-verifier");
  if (!connectors.length) {
    return [{
      phase: "project-verifier",
      status: "SKIPPED",
      message: "No project verifier connector is configured."
    }];
  }

  const phases = [];
  for (const connector of connectors) {
    if (!connector.command) {
      phases.push({
        phase: "project-verifier",
        status: "REQUESTED",
        name: connector.name || "pdv-verifier",
        message: "Verifier connector is declared but has no local command. A host adapter must execute it."
      });
      continue;
    }
    phases.push({
      phase: "project-verifier",
      name: connector.name || "pdv-verifier",
      ...await runProcess(connector.command, connector.args || [], { cwd: connector.cwd })
    });
  }
  return phases;
}

function finalizeReport({ manifest, profile, plan, phases, manualPackets, startedAt, options }) {
  const finishedAt = new Date();
  const status = summarizePhaseStatuses(phases);
  const report = {
    schema: "creation-authoring.run-report.v1",
    status,
    startedAt: startedAt.toISOString(),
    finishedAt: finishedAt.toISOString(),
    manifest: {
      project: manifest.project,
      game: manifest.game,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output,
      metadata: manifest.metadata || {}
    },
    profile: {
      modId: profile.modId,
      outputPolicy: profile.outputPolicy
    },
    phases,
    manualPackets,
    planSummary: plan.summary,
    planOperations: plan.operations.map((item) => ({
      id: item.operation.id,
      kind: item.operation.kind,
      target: item.operation.target,
      mode: item.operation.mode,
      onConflict: item.operation.onConflict,
      recordFamily: item.operation.recordFamily,
      ckSemanticsRequired: item.operation.ckSemanticsRequired || item.capability.requiresCkSemantics || false,
      capabilityTier: item.capabilityTier,
      backend: item.backend,
      status: item.status,
      mergePolicy: item.operation.mergePolicy,
      reviewIntent: item.operation.reviewIntent,
      verifierExpectations: item.operation.verifierExpectations,
      runtimeSmokeRequired: item.operation.runtimeSmokeRequired
    }))
  };

  if (options.reportPath) {
    report.reportPath = writeJson(options.reportPath, report);
  } else if (options.writeReport) {
    const reportsDir = profile.reportsDir || "reports";
    const timestamp = finishedAt.toISOString().replace(/[:.]/g, "-");
    report.reportPath = writeJson(path.join(reportsDir, `${manifest.project}-${timestamp}.run-report.json`), report);
  }

  return report;
}

async function collectReadback(manifest, profile, plan, phases, options) {
  if (options.readbackCollector) {
    const readback = await options.readbackCollector({ manifest, profile, plan, phases });
    phases.push({
      phase: options.readbackPhase || "readback-collect",
      status: "PASS",
      message: "Readback collector completed."
    });
    return readback;
  }

  if (options.executeLive) {
    phases.push({
      phase: "readback-collect",
      status: "REQUESTED",
      message: "Live execution requested, but no readback collector adapter is configured."
    });
  }

  return null;
}

function summarizeConnectorResults(results) {
  if (results.some((item) => item.status === "FAIL")) {
    return "FAIL";
  }
  if (results.some((item) => item.status === "REQUESTED")) {
    return "REQUESTED";
  }
  return "PASS";
}
