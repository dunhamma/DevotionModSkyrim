import { readDocument } from "./io.mjs";
import { ValidationError } from "./errors.mjs";

export function loadManifest(filePath, profile = null) {
  const { path, document } = readDocument(filePath);
  return normalizeManifest(document, profile, path);
}

export function normalizeManifest(input, profile = null, sourcePath = null) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new ValidationError("Authoring manifest must be an object.", { sourcePath });
  }

  const schema = input.schema || "creation-authoring.v1";
  if (schema !== "creation-authoring.v1") {
    throw new ValidationError(`Unsupported manifest schema: ${schema}`, { sourcePath });
  }

  const manifest = {
    schema,
    project: input.project || profile?.modId || null,
    game: input.game || profile?.game || null,
    sourcePlugin: input.sourcePlugin || profile?.sourcePlugin || null,
    output: input.output || profile?.defaultOutput || null,
    operations: Array.isArray(input.operations) ? input.operations.map(normalizeOperation) : null,
    metadata: input.metadata || {},
    sourcePath
  };

  requireString(manifest.project, "manifest.project");
  requireString(manifest.game, "manifest.game");
  requireString(manifest.sourcePlugin, "manifest.sourcePlugin");

  if (!manifest.operations) {
    throw new ValidationError("manifest.operations must be an array.", { sourcePath });
  }

  return manifest;
}

function normalizeOperation(operation, index) {
  if (!operation || typeof operation !== "object" || Array.isArray(operation)) {
    throw new ValidationError(`manifest.operations[${index}] must be an object.`);
  }

  const normalized = {
    id: operation.id || `op-${index + 1}`,
    kind: requireString(operation.kind, `manifest.operations[${index}].kind`),
    target: operation.target ?? operation.record ?? null,
    payload: operation.payload || {},
    mode: normalizeEnum(operation.mode, ["create", "update", "create_or_update"], "update", `manifest.operations[${index}].mode`),
    onConflict: normalizeEnum(operation.onConflict, ["fail", "update", "rename"], "fail", `manifest.operations[${index}].onConflict`),
    recordFamily: operation.recordFamily || inferRecordFamily(operation.kind),
    ckSemanticsRequired: Boolean(operation.ckSemanticsRequired),
    reviewIntent: operation.reviewIntent || null,
    verifierExpectations: Array.isArray(operation.verifierExpectations) ? operation.verifierExpectations : [],
    runtimeSmokeRequired: Boolean(operation.runtimeSmokeRequired),
    mergePolicy: normalizeMergePolicy(operation.mergePolicy),
    mastersExpected: Array.isArray(operation.mastersExpected) ? operation.mastersExpected : [],
    requires: Array.isArray(operation.requires) ? operation.requires : [],
    preferredBackend: operation.preferredBackend || null,
    metadata: operation.metadata || {}
  };

  requireString(normalized.target, `manifest.operations[${index}].target`);

  if (!normalized.payload || typeof normalized.payload !== "object" || Array.isArray(normalized.payload)) {
    throw new ValidationError(`manifest.operations[${index}].payload must be an object.`);
  }

  return normalized;
}

function normalizeEnum(value, allowed, fallback, field) {
  const normalized = value || fallback;
  if (!allowed.includes(normalized)) {
    throw new ValidationError(`${field} must be one of: ${allowed.join(", ")}.`);
  }
  return normalized;
}

function inferRecordFamily(kind) {
  const [family] = String(kind || "").split(".");
  return family || "unknown";
}

function normalizeMergePolicy(input) {
  const policy = input && typeof input === "object" && !Array.isArray(input) ? input : {};
  return {
    promote: policy.promote || "reviewed",
    preserveFormId: policy.preserveFormId ?? "when-safe",
    requiresCkFinalization: Boolean(policy.requiresCkFinalization),
    allowSourceMutation: Boolean(policy.allowSourceMutation)
  };
}

function requireString(value, field) {
  if (typeof value !== "string" || !value.trim()) {
    throw new ValidationError(`${field} must be a non-empty string.`);
  }
  return value;
}
