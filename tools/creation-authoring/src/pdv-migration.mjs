import { ValidationError } from "./errors.mjs";

export function migratePdvAuthorManifest(input, profile = null) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new ValidationError("PDV manifest must be an object.");
  }

  const groupedScripts = new Map();
  const operations = [];

  for (const [index, operation] of (input.operations || []).entries()) {
    if (operation.kind === "setProperty") {
      const key = `${operation.record}::${operation.script}`;
      if (!groupedScripts.has(key)) {
        groupedScripts.set(key, {
          id: `${operation.record}-${operation.script}`.replace(/[^a-zA-Z0-9_-]+/g, "-"),
          kind: "vmad.attach_script",
          target: operation.record,
          payload: {
            script: operation.script,
            properties: []
          },
          metadata: {
            migratedFrom: "pdv_author.setProperty"
          }
        });
      }
      groupedScripts.get(key).payload.properties.push({
        name: operation.property,
        type: mapValueType(operation.valueType),
        value: operation.value
      });
      continue;
    }

    if (operation.kind === "attachScript") {
      operations.push({
        id: `op-${index + 1}`,
        kind: "vmad.attach_script",
        target: operation.record,
        payload: {
          script: operation.script,
          properties: []
        },
        metadata: {
          migratedFrom: "pdv_author.attachScript",
          note: operation.note || null
        }
      });
      continue;
    }

    if (operation.kind === "addFormListEntry") {
      operations.push({
        id: `op-${index + 1}`,
        kind: "formlist.add",
        target: operation.record,
        payload: {
          entry: operation.entry
        },
        metadata: {
          migratedFrom: "pdv_author.addFormListEntry",
          note: operation.note || null
        }
      });
      continue;
    }

    if (/Array$/i.test(operation.valueType || "")) {
      operations.push({
        id: `op-${index + 1}`,
        kind: "vmad.array_property",
        target: operation.record,
        payload: {
          script: operation.script,
          property: operation.property,
          type: operation.valueType,
          value: operation.value
        },
        metadata: {
          migratedFrom: `pdv_author.${operation.kind || "unknown"}`
        }
      });
      continue;
    }

    operations.push({
      id: `op-${index + 1}`,
      kind: "manual.unsupported",
      target: operation.record || operation.target || "unknown",
      payload: {
        sourceOperation: operation
      },
      metadata: {
        migratedFrom: `pdv_author.${operation.kind || "unknown"}`
      }
    });
  }

  operations.unshift(...groupedScripts.values());

  return {
    schema: "creation-authoring.v1",
    project: profile?.modId || "player-devotion-reference",
    game: profile?.game || "SkyrimSE",
    sourcePlugin: profile?.sourcePlugin || "PlayerDevotion_Framework.esp",
    output: input.defaultOutput || profile?.defaultOutput || null,
    metadata: {
      migratedFrom: "pdv_author",
      sourceId: input.id || null,
      title: input.title || null,
      notes: input.notes || []
    },
    operations
  };
}

function mapValueType(valueType) {
  if (valueType === "Float") {
    return "Float";
  }
  if (valueType === "Int") {
    return "Int";
  }
  if (valueType === "Bool") {
    return "Bool";
  }
  if (valueType === "String") {
    return "String";
  }
  return "Object";
}
