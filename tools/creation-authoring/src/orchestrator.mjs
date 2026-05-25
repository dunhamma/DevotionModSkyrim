import path from "node:path";
import { createPlan } from "./planner.mjs";
import { executeApply, executeCkApply } from "./executor.mjs";
import { verifyManifest } from "./verifier.mjs";
import { writeJson } from "./io.mjs";
import { runProcess } from "./process-runner.mjs";

export async function runPipeline(manifest, profile, options = {}) {
  const startedAt = new Date();
  const plan = createPlan(manifest, profile, options);
  const manualPackets = plan.operations.filter((item) => item.manualPacket).map((item) => item.manualPacket);
  const phases = [];

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

  phases.push(await executeApply(plan, {
    patchOptions: options.patchOptions,
    patchWriter: options.patchWriter
  }));

  phases.push(await executeCkApply(plan, {
    ckAdapter: options.ckAdapter
  }));

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
    phases.push(buildStrictGate(phases, manualPackets));
  }

  return finalizeReport({ manifest, profile, plan, phases, manualPackets, startedAt, options });
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
  const status = summarizeStatus(phases);
  const report = {
    schema: "creation-authoring.run-report.v1",
    status,
    startedAt: startedAt.toISOString(),
    finishedAt: finishedAt.toISOString(),
    manifest: {
      project: manifest.project,
      game: manifest.game,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output
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
      phase: "readback-collect",
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

function buildStrictGate(phases, manualPackets = []) {
  const blockers = phases.filter((phase) => {
    return ["FAIL", "UNSAFE_BLOCKED", "TODO", "REQUESTED", "MANUAL"].includes(phase.status);
  });
  for (const packet of manualPackets) {
    blockers.push({
      phase: "manual-packet",
      status: "MANUAL",
      message: `${packet.kind} on ${packet.target} emitted a manual development packet. Manual packets are not a shippable automation path.`
    });
  }
  return {
    phase: "strict-gate",
    status: blockers.length ? "FAIL" : "PASS",
    message: blockers.length
      ? "Strict mode requires every executable, readback, and verifier phase to pass before review or promotion."
      : "Strict mode passed.",
    blockers: blockers.map((phase) => ({
      phase: phase.phase,
      status: phase.status,
      message: phase.message || null
    }))
  };
}

function summarizeStatus(phases) {
  if (phases.some((phase) => phase.status === "FAIL" || phase.status === "UNSAFE_BLOCKED")) {
    return "FAIL";
  }
  if (phases.some((phase) => phase.status === "REQUESTED")) {
    return "REQUESTED";
  }
  if (phases.some((phase) => phase.status === "TODO" || phase.status === "MANUAL")) {
    return "TODO";
  }
  return "PASS";
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
