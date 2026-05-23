import { readDocument } from "./io.mjs";
import { ValidationError } from "./errors.mjs";

const OUTPUT_POLICIES = new Set(["overlay", "generated-patch", "in-place-explicit"]);

export function loadProfile(filePath) {
  const { path, document } = readDocument(filePath);
  return normalizeProfile(document, path);
}

export function normalizeProfile(input, sourcePath = null) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new ValidationError("Project profile must be an object.", { sourcePath });
  }

  const profile = {
    schema: input.schema || "creation-profile.v1",
    game: requireString(input.game, "profile.game"),
    modId: requireString(input.modId, "profile.modId"),
    sourcePlugin: requireString(input.sourcePlugin, "profile.sourcePlugin"),
    outputPolicy: input.outputPolicy || "overlay",
    defaultOutput: input.defaultOutput || null,
    reportsDir: input.reportsDir || "reports",
    resourceConnectors: Array.isArray(input.resourceConnectors) ? input.resourceConnectors : [],
    verifierRules: Array.isArray(input.verifierRules) ? input.verifierRules : [],
    referencePack: input.referencePack || null,
    sourcePath
  };

  if (profile.schema !== "creation-profile.v1") {
    throw new ValidationError(`Unsupported profile schema: ${profile.schema}`, { sourcePath });
  }

  if (!OUTPUT_POLICIES.has(profile.outputPolicy)) {
    throw new ValidationError(`Unsupported outputPolicy: ${profile.outputPolicy}`, {
      allowed: [...OUTPUT_POLICIES],
      sourcePath
    });
  }

  for (const [index, connector] of profile.resourceConnectors.entries()) {
    if (!connector || typeof connector !== "object" || Array.isArray(connector)) {
      throw new ValidationError(`profile.resourceConnectors[${index}] must be an object.`, {
        sourcePath
      });
    }
    requireString(connector.type, `profile.resourceConnectors[${index}].type`);
  }

  return profile;
}

function requireString(value, field) {
  if (typeof value !== "string" || !value.trim()) {
    throw new ValidationError(`${field} must be a non-empty string.`);
  }
  return value;
}
