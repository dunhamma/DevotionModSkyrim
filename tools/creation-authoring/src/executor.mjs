import { buildPatchRequest } from "./patch-request.mjs";
import { buildCkCommandPacket } from "./ck-command-packet.mjs";

export async function executeApply(plan, options = {}) {
  const patchRequest = buildPatchRequest(plan, options.patchOptions || {});
  const readyOperations = plan.operations.filter((item) => {
    return item.status === "ready" && ["mutagen-patch-request", "mo2-mcp-patch-request", "xedit-script-request"].includes(item.backend);
  });
  const manualOperations = plan.operations.filter((item) => item.status === "manual");

  if (!readyOperations.length) {
    return {
      schema: "creation-authoring.execution.v1",
      phase: "apply",
      status: "SKIPPED",
      message: "No safe patch operations were ready to execute.",
      patchRequest,
      manualOperations: manualOperations.length
    };
  }

  if (options.patchWriter) {
    const writerResult = await options.patchWriter(patchRequest, { plan });
    return {
      schema: "creation-authoring.execution.v1",
      phase: "apply",
      status: "PASS",
      message: "Patch writer completed.",
      patchRequest,
      writerResult,
      manualOperations: manualOperations.length
    };
  }

  return {
    schema: "creation-authoring.execution.v1",
    phase: "apply",
    status: "REQUESTED",
    message: "Patch request is ready. A host adapter must pass it to MO2 MCP, Mutagen, or another writer.",
    patchRequest,
    manualOperations: manualOperations.length
  };
}

export async function executeCkApply(plan, options = {}) {
  const ckOperations = plan.operations.filter((item) => {
    return item.capability.requiresCkSemantics || item.backend === "ckpe-bridge" || item.backend === "ui-automation";
  });

  if (!ckOperations.length) {
    return {
      schema: "creation-authoring.execution.v1",
      phase: "ck-apply",
      status: "SKIPPED",
      message: "No CK-semantic operations are present."
    };
  }

  if (options.ckAdapter) {
    const packet = buildCkCommandPacket(plan);
    const adapterResult = await options.ckAdapter(packet, { plan, ckOperations });
    const status = normalizeAdapterStatus(adapterResult);
    return {
      schema: "creation-authoring.execution.v1",
      phase: "ck-apply",
      status,
      message: status === "PASS" ? "CK adapter completed." : "CK adapter did not complete all commands safely.",
      operations: ckOperations.map((item) => item.operation.id),
      packet,
      adapterResult
    };
  }

  return {
    schema: "creation-authoring.execution.v1",
    phase: "ck-apply",
    status: "UNSAFE_BLOCKED",
    message: "CK-semantic operations require a verified CKPE/UI adapter. Manual packets were emitted instead.",
    packet: buildCkCommandPacket(plan),
    packets: ckOperations.map((item) => item.manualPacket).filter(Boolean)
  };
}

function normalizeAdapterStatus(result) {
  if (!result) {
    return "FAIL";
  }
  if (result.status === "PASS" || result.status === "SKIPPED") {
    return result.status;
  }
  if (result.status === "REQUESTED") {
    return "REQUESTED";
  }
  if (result.status === "UNSAFE_BLOCKED") {
    return "UNSAFE_BLOCKED";
  }
  return "FAIL";
}
