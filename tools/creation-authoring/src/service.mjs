import { createCapabilityRegistry } from "./capabilities.mjs";
import { normalizeManifest } from "./manifest.mjs";
import { normalizeProfile } from "./profile.mjs";
import { createPlan } from "./planner.mjs";
import { buildPatchRequest } from "./patch-request.mjs";
import { verifyManifest } from "./verifier.mjs";
import { executeApply, executeCkApply } from "./executor.mjs";
import { runPipeline } from "./orchestrator.mjs";
import { migratePdvAuthorManifest } from "./pdv-migration.mjs";
import { promoteRunReport } from "./promotion.mjs";
import { analyzeDrift } from "./drift.mjs";

export function handleAuthoringRequest(request) {
  if (!request || typeof request !== "object" || Array.isArray(request)) {
    throw new Error("Service request must be an object.");
  }

  const action = request.action;
  if (action === "explain") {
    const registry = createCapabilityRegistry();
    return registry.explain(request.kind);
  }

  if (action === "migrate-pdv") {
    const profile = request.profile ? normalizeProfile(request.profile) : null;
    return migratePdvAuthorManifest(request.sourceManifest, profile);
  }

  const profile = normalizeProfile(request.profile);
  if (action === "promote") {
    return promoteRunReport(request.runReport, profile, {
      approved: Boolean(request.approved),
      allowSourceMutation: Boolean(request.allowSourceMutation),
      reportPath: request.reportPath,
      sourcePath: request.sourcePath,
      generatedPath: request.generatedPath,
      mergeOutputPath: request.mergeOutputPath,
      backupRoot: request.backupRoot,
      proofLedger: request.proofLedger,
      forceCkFinalization: Boolean(request.forceCkFinalization),
      backupRunner: request.adapters?.backupRunner,
      mergeRunner: request.adapters?.mergeRunner,
      ckFinalizer: request.adapters?.ckFinalizer,
      postMergeVerifier: request.adapters?.postMergeVerifier
    });
  }

  const manifest = normalizeManifest(request.manifest, profile);
  const plan = createPlan(manifest, profile, {
    allowUnprovenCk: Boolean(request.allowUnprovenCk)
  });

  if (action === "plan") {
    return plan;
  }

  if (action === "manual-packet") {
    return {
      schema: "creation-authoring.manual-packets.v1",
      manifest: plan.manifest,
      packets: plan.operations.filter((item) => item.manualPacket).map((item) => item.manualPacket)
    };
  }

  if (action === "apply") {
    if (request.execute) {
      return executeApply(plan, {
        patchOptions: request.patchOptions || {},
        patchWriter: request.adapters?.patchWriter
      });
    }
    return {
      schema: "creation-authoring.apply-request.v1",
      plan,
      patchRequest: buildPatchRequest(plan, request.patchOptions || {}),
      note: "The host adapter is responsible for passing this patch request to a concrete writer."
    };
  }

  if (action === "ck-apply") {
    return executeCkApply(plan, {
      ckAdapter: request.adapters?.ckAdapter
    });
  }

  if (action === "run") {
    return runPipeline(manifest, profile, {
      allowManualPackets: Boolean(request.allowManualPackets),
      allowUnprovenCk: Boolean(request.allowUnprovenCk),
      strict: Boolean(request.strict),
      executeLive: Boolean(request.executeLive),
      patchOptions: request.patchOptions || {},
      patchWriter: request.adapters?.patchWriter,
      ckAdapter: request.adapters?.ckAdapter,
      compileRunner: request.adapters?.compileRunner,
      verifierRunner: request.adapters?.verifierRunner,
      readbackCollector: request.adapters?.readbackCollector,
      readback: request.readback || null
    });
  }

  if (action === "verify") {
    return verifyManifest(manifest, profile, request.readback || null);
  }

  if (action === "drift") {
    return analyzeDrift(manifest, profile, request.readback || null);
  }

  throw new Error(`Unsupported service action: ${action}`);
}
