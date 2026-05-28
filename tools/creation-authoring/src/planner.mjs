import { availableBackendsForProfile, BACKEND_ORDER, createCapabilityRegistry } from "./capabilities.mjs";
import { createResolver } from "./resolver.mjs";
import { buildManualPacket } from "./manual-packet.mjs";

export function createPlan(manifest, profile, options = {}) {
  const registry = options.registry || createCapabilityRegistry();
  const resolver = options.resolver || createResolver(profile);
  const availableBackends = options.availableBackends || availableBackendsForProfile(profile);
  const plannedCreates = new Set(
    manifest.operations
      .filter((operation) => ["record.create", "quest.create", "record.duplicate_create", "glob.duplicate_create"].includes(operation.kind))
      .map((operation) => operation.target.toLowerCase())
  );

  const operations = manifest.operations.map((operation) => {
    const capability = registry.explain(operation.kind);
    let targetResolution = resolver.resolveRecord(operation.target);
    const targetIsPlannedCreate = plannedCreates.has(operation.target.toLowerCase());
    if (!targetResolution.resolved && targetIsPlannedCreate) {
      targetResolution = plannedResolution(operation);
    }
    const enrichedOperation = enrichPayload(operation, resolver, plannedCreates);
    const backend = selectBackend(enrichedOperation, capability, availableBackends, {
      targetIsPlannedCreate,
      payloadReferencesPlannedCreate: hasPlannedCreateReference(enrichedOperation, plannedCreates),
      allowUnprovenCk: Boolean(options.allowUnprovenCk)
    });
    const conflict = classifyConflict(enrichedOperation, targetResolution, capability);

    if (!capability || capability.unknown) {
      return manualResult(enrichedOperation, capability, targetResolution, "No capability is registered for this operation kind.");
    }

    if (conflict.status === "blocked") {
      return blockedResult(enrichedOperation, capability, targetResolution, conflict.reason);
    }

    if (!targetResolution.resolved && !capability.requiresCkSemantics && !enrichedOperation.ckSemanticsRequired) {
      return manualResult(enrichedOperation, capability, targetResolution, "Target could not be resolved by the active resource connectors.");
    }

    if (!backend || backend === "manual-packet") {
      return manualResult(enrichedOperation, capability, targetResolution, "No safe backend is available for this operation in the active profile.");
    }

    return {
      operation: enrichedOperation,
      capability,
      capabilityTier: capability.tier,
      conflict,
      targetResolution,
      backend,
      status: "ready",
      verifier: capability.verifier,
      manualPacket: null
    };
  });

  return {
    schema: "creation-authoring.plan.v1",
    manifest: {
      project: manifest.project,
      game: manifest.game,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output
    },
    profile: {
      modId: profile.modId,
      game: profile.game,
      sourcePlugin: profile.sourcePlugin,
      outputPolicy: profile.outputPolicy
    },
    availableBackends,
    operations,
    summary: summarize(operations)
  };
}

function enrichPayload(operation, resolver, plannedCreates = new Set()) {
  const payload = { ...operation.payload };

  if (operation.kind === "vmad.attach_script") {
    payload.properties = (payload.properties || []).map((property) => {
      const resolved = resolver.resolveValue(property.value);
      const planned = typeof property.value === "string" && plannedCreates.has(property.value.toLowerCase());
      return {
        ...property,
        resolvedValue: planned ? property.value : resolved.resolvedValue,
        resolution: planned ? plannedResolution({ target: property.value, recordFamily: "planned" }) : resolved.record || null
      };
    });
  }

  if (operation.kind === "formlist.add" && payload.entry) {
    const resolved = resolver.resolveValue(payload.entry);
    const planned = typeof payload.entry === "string" && plannedCreates.has(payload.entry.toLowerCase());
    payload.resolvedEntry = planned ? payload.entry : resolved.resolvedValue;
    payload.entryResolution = planned ? plannedResolution({ target: payload.entry, recordFamily: "planned" }) : resolved.record || null;
  }

  return {
    ...operation,
    payload
  };
}

function selectBackend(operation, capability, availableBackends, context = {}) {
  if (!capability || capability.unknown) {
    return null;
  }

  const available = new Set(availableBackends);
  const needsCkSemantics =
    operation.ckSemanticsRequired ||
    capability.requiresCkSemantics ||
    context.targetIsPlannedCreate ||
    context.payloadReferencesPlannedCreate;
  if (
    !context.allowUnprovenCk &&
    available.has("ckpe-bridge") &&
    capability.supportedBackends.includes("ckpe-bridge") &&
    needsCkSemantics &&
    operation.kind !== "glob.duplicate_create" &&
    operation.kind !== "record.duplicate_create"
  ) {
    return null;
  }
  if (
    available.has("ckpe-bridge") &&
    capability.supportedBackends.includes("ckpe-bridge") &&
    needsCkSemantics
  ) {
    return "ckpe-bridge";
  }
  if (
    operation.preferredBackend &&
    capability.supportedBackends.includes(operation.preferredBackend) &&
    available.has(operation.preferredBackend)
  ) {
    return operation.preferredBackend;
  }

  for (const backend of BACKEND_ORDER) {
    if (capability.supportedBackends.includes(backend) && available.has(backend)) {
      return backend;
    }
  }

  return capability.fallback || "manual-packet";
}

function hasPlannedCreateReference(operation, plannedCreates) {
  if (plannedCreates.size === 0) {
    return false;
  }
  for (const property of operation.payload?.properties || []) {
    if (typeof property.value === "string" && plannedCreates.has(property.value.toLowerCase())) {
      return true;
    }
  }
  return typeof operation.payload?.entry === "string" && plannedCreates.has(operation.payload.entry.toLowerCase());
}

function plannedResolution(operation) {
  return {
    identifier: operation.target,
    formid: null,
    editorId: operation.target,
    recordType: operation.recordFamily || operation.payload?.recordType || null,
    plugin: null,
    winningPlugin: null,
    plannedCreate: true,
    resolved: true
  };
}

function manualResult(operation, capability, targetResolution, reason) {
  return {
    operation,
    capability,
    capabilityTier: capability.tier,
    conflict: null,
    targetResolution,
    backend: "manual-packet",
    status: "manual",
    verifier: capability.verifier,
    manualPacket: buildManualPacket(operation, capability, targetResolution, reason)
  };
}

function blockedResult(operation, capability, targetResolution, reason) {
  return {
    operation,
    capability,
    capabilityTier: capability.tier,
    conflict: {
      status: "blocked",
      reason
    },
    targetResolution,
    backend: "manual-packet",
    status: "abort",
    verifier: capability.verifier,
    manualPacket: buildManualPacket(operation, capability, targetResolution, reason)
  };
}

function classifyConflict(operation, targetResolution, capability) {
  if (targetResolution.plannedCreate) {
    return {
      status: "ok",
      reason: null
    };
  }
  if (operation.mode === "create" && targetResolution.resolved && operation.onConflict === "fail") {
    return {
      status: "blocked",
      reason: `Create operation targets existing record ${operation.target}. Authored EditorIDs are design identity; declare mode:update or onConflict:rename when that is intentional.`
    };
  }
  if (operation.mode === "create" && targetResolution.resolved && operation.onConflict === "rename") {
    return {
      status: "rename",
      reason: "Existing target will require deterministic rename before execution."
    };
  }
  if (operation.mode === "update" && !targetResolution.resolved && !capability.requiresCkSemantics && !operation.ckSemanticsRequired) {
    return {
      status: "blocked",
      reason: `Update operation targets missing record ${operation.target}. Declare mode:create when minting a new record is intentional.`
    };
  }
  return {
    status: "ok",
    reason: null
  };
}

function summarize(operations) {
  const summary = {
    total: operations.length,
    ready: 0,
    manual: 0,
    abort: 0
  };
  for (const operation of operations) {
    if (operation.status === "ready") {
      summary.ready += 1;
    } else if (operation.status === "manual") {
      summary.manual += 1;
    } else {
      summary.abort += 1;
    }
  }
  return summary;
}
