import { buildPatchRequest } from "./patch-request.mjs";
import { buildCkCommandPacket } from "./ck-command-packet.mjs";

export async function executeApply(plan, options = {}) {
  const operationFilter = options.operationFilter || (() => true);
  const phaseName = options.phaseName || "apply";
  const patchRequest = buildPatchRequest(plan, {
    ...(options.patchOptions || {}),
    operationFilter
  });
  const readyOperations = plan.operations.filter((item) => {
    return item.status === "ready" &&
      operationFilter(item) &&
      ["mutagen-patch-request", "mo2-mcp-patch-request", "xedit-script-request"].includes(item.backend);
  });
  const manualOperations = plan.operations.filter((item) => item.status === "manual");

  if (!readyOperations.length) {
    return {
      schema: "creation-authoring.execution.v1",
      phase: phaseName,
      status: "SKIPPED",
      message: "No safe patch operations were ready to execute.",
      patchRequest,
      manualOperations: manualOperations.length
    };
  }

  if (options.patchWriter) {
    const writerResult = await options.patchWriter(patchRequest, { plan });
    const status = normalizePatchWriterStatus(writerResult);
    return {
      schema: "creation-authoring.execution.v1",
      phase: phaseName,
      status,
      message: status === "PASS" ? "Patch writer completed." : "Patch writer did not complete safely.",
      patchRequest,
      writerResult,
      manualOperations: manualOperations.length
    };
  }

  if (options.appliedPatchEvidence) {
    const status = normalizePatchWriterStatus(options.appliedPatchEvidence);
    return {
      schema: "creation-authoring.execution.v1",
      phase: phaseName,
      status,
      message: status === "PASS"
        ? "Patch writer evidence was supplied for an already-applied generated plugin."
        : "Supplied patch writer evidence did not prove a completed generated-plugin write.",
      patchRequest,
      writerResult: options.appliedPatchEvidence,
      manualOperations: manualOperations.length
    };
  }

  return {
    schema: "creation-authoring.execution.v1",
    phase: phaseName,
    status: "REQUESTED",
    message: "Patch request is ready. A host adapter must pass it to MO2 MCP, Mutagen, or another writer.",
    patchRequest,
    manualOperations: manualOperations.length
  };
}

export async function executeCkApply(plan, options = {}) {
  const ckOperations = plan.operations.filter((item) => {
    return item.status === "ready" && (
      item.capability.requiresCkSemantics ||
      item.backend === "ckpe-bridge" ||
      item.backend === "ui-automation"
    );
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

function normalizePatchWriterStatus(result) {
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
  if (result.status === "FAIL" || result.status === "TODO") {
    return "FAIL";
  }
  if (result.output || result.output_name || result.outputName || result.output_path || result.generatedPlugin || result.success === true) {
    return "PASS";
  }
  return "FAIL";
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
