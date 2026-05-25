import { createResolver } from "./resolver.mjs";

export function analyzeDrift(manifest, profile, readback = null) {
  const resolver = createResolver(profile);
  const results = manifest.operations.map((operation) => {
    const targetResolution = resolver.resolveRecord(operation.target);
    const liveRecord = findReadbackRecord(readback, operation.target, targetResolution);
    const expectedExists = operation.mode !== "create" || operation.onConflict !== "fail";
    const liveExists = Boolean(liveRecord);

    if (!liveExists && expectedExists) {
      return driftResult(operation, "plugin_regression", "Expected record is absent from live readback.", {
        targetResolution
      });
    }

    if (operation.mode === "create" && targetResolution.resolved && operation.onConflict === "fail") {
      return driftResult(operation, "manual_source_override", "Manifest declares create-only but the target already resolves in the profile.", {
        targetResolution
      });
    }

    return driftResult(operation, "none", "No drift detected by generic checks.", {
      targetResolution
    });
  });

  return {
    schema: "creation-authoring.drift-report.v1",
    manifest: {
      project: manifest.project,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output
    },
    results,
    summary: summarize(results)
  };
}

function driftResult(operation, classification, message, details = {}) {
  return {
    operationId: operation.id,
    kind: operation.kind,
    target: operation.target,
    classification,
    status: classification === "none" ? "PASS" : "UNSAFE_BLOCKED",
    message,
    details
  };
}

function summarize(results) {
  return results.reduce((summary, item) => {
    summary[item.classification] = (summary[item.classification] || 0) + 1;
    return summary;
  }, {});
}

function findReadbackRecord(readback, target, targetResolution) {
  if (!readback) {
    return null;
  }
  const records = readback.records || readback;
  if (Array.isArray(records)) {
    return records.find((record) => {
      return equals(record.editorId || record.EditorID, target) ||
        equals(record.formid || record.FormID, targetResolution.formid);
    }) || null;
  }
  return records[target] || records[targetResolution.formid] || records[targetResolution.editorId] || null;
}

function equals(left, right) {
  if (left === right) {
    return true;
  }
  if (typeof left !== "string" || typeof right !== "string") {
    return false;
  }
  return left.toLowerCase() === right.toLowerCase();
}
