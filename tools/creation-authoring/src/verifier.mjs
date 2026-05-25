import { createResolver } from "./resolver.mjs";

export function verifyManifest(manifest, profile, readback = null) {
  const resolver = createResolver(profile);
  const results = [];

  for (const operation of manifest.operations) {
    const targetResolution = resolver.resolveRecord(operation.target);
    const readbackRecord = findReadbackRecord(readback, operation.target, targetResolution);
    results.push(verifyOperation(operation, targetResolution, readbackRecord));
  }

  return {
    schema: "creation-authoring.verify.v1",
    manifest: {
      project: manifest.project,
      game: manifest.game,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output
    },
    results,
    summary: summarize(results)
  };
}

function verifyOperation(operation, targetResolution, readbackRecord) {
  if (!readbackRecord) {
    return result(operation, "TODO", `No readback record was supplied for ${operation.target}.`, {
      targetResolution
    });
  }

  const expectationResult = verifyExpectations(operation, readbackRecord);
  if (expectationResult) {
    return expectationResult;
  }

  if (operation.kind === "vmad.attach_script") {
    return verifyScript(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "formlist.add") {
    return verifyListContains(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "keyword.add") {
    return verifyContainsAny(operation, targetResolution, readbackRecord, "keywords", operation.payload.keywords || operation.payload.keyword);
  }

  if (operation.kind === "spell.add") {
    return verifyContainsAny(operation, targetResolution, readbackRecord, "spells", operation.payload.spells || operation.payload.spell);
  }

  if (operation.kind === "perk.add") {
    return verifyContainsAny(operation, targetResolution, readbackRecord, "perks", operation.payload.perks || operation.payload.perk);
  }

  if (operation.kind === "package.add") {
    return verifyContainsAny(operation, targetResolution, readbackRecord, "packages", operation.payload.packages || operation.payload.package);
  }

  if (operation.kind === "inventory.add") {
    return verifyInventory(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "condition.add") {
    return verifyConditions(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "story_manager.node") {
    return verifyStoryManager(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "record.create") {
    return result(operation, "PASS", `${operation.target} exists in readback.`, {
      targetResolution
    });
  }

  return result(operation, "TODO", `No verifier is implemented for ${operation.kind}.`, {
    targetResolution
  });
}

function verifyExpectations(operation, readbackRecord) {
  const expectations = operation.verifierExpectations || [];
  const failures = [];
  for (const expectation of expectations) {
    if (expectation.type === "fieldEquals") {
      const actual = readPath(readbackRecord, expectation.path);
      if (!valueMatches(actual, expectation.value)) {
        failures.push({ expectation, actual });
      }
    }
    if (expectation.type === "contains") {
      const actual = readPath(readbackRecord, expectation.path);
      const values = Array.isArray(actual) ? actual : [];
      if (!values.some((value) => valueMatches(value, expectation.value))) {
        failures.push({ expectation, actual });
      }
    }
  }
  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} failed verifier expectations.`, {
      failures
    });
  }
  return null;
}

function readPath(object, path) {
  if (!path || typeof path !== "string") {
    return undefined;
  }
  return path.split(".").reduce((current, key) => current?.[key], object);
}

function verifyScript(operation, targetResolution, readbackRecord) {
  const scriptName = operation.payload.script;
  const scripts = normalizeScripts(readbackRecord.scripts || readbackRecord.Scripts || []);
  const matches = scripts.filter((script) => equals(script.name, scriptName));

  if (matches.length === 0) {
    return result(operation, "FAIL", `Script ${scriptName} is not attached to ${operation.target}.`, {
      targetResolution
    });
  }

  if (matches.length > 1) {
    return result(operation, "FAIL", `Script ${scriptName} is attached ${matches.length} times to ${operation.target}.`, {
      targetResolution
    });
  }

  const script = matches[0];
  const missingProperties = [];
  const mismatchedProperties = [];

  for (const property of operation.payload.properties || []) {
    if (!(property.name in script.properties)) {
      missingProperties.push(property.name);
      continue;
    }
    if (!valueMatches(script.properties[property.name], property.value)) {
      mismatchedProperties.push({
        name: property.name,
        expected: property.value,
        actual: script.properties[property.name]
      });
    }
  }

  if (missingProperties.length || mismatchedProperties.length) {
    return result(operation, "FAIL", `Script ${scriptName} property readback does not match manifest intent.`, {
      targetResolution,
      missingProperties,
      mismatchedProperties
    });
  }

  return result(operation, "PASS", `Script ${scriptName} is attached and required properties match.`, {
    targetResolution
  });
}

function verifyListContains(operation, targetResolution, readbackRecord) {
  const entries = readbackRecord.entries || readbackRecord.formListEntries || [];
  const expected = operation.payload.entry;
  if (entries.some((entry) => valueMatches(entry, expected))) {
    return result(operation, "PASS", `${operation.target} contains ${expected}.`, {
      targetResolution
    });
  }
  return result(operation, "FAIL", `${operation.target} does not contain ${expected}.`, {
    targetResolution,
    entries
  });
}

function verifyContainsAny(operation, targetResolution, readbackRecord, field, expectedRaw) {
  const actual = readbackRecord[field] || [];
  const expected = Array.isArray(expectedRaw) ? expectedRaw : [expectedRaw].filter(Boolean);
  const missing = expected.filter((value) => !actual.some((entry) => valueMatches(entry, value)));
  if (!missing.length) {
    return result(operation, "PASS", `${operation.target} ${field} contains expected entries.`, {
      targetResolution
    });
  }
  return result(operation, "FAIL", `${operation.target} ${field} is missing expected entries.`, {
    targetResolution,
    missing,
    actual
  });
}

function verifyInventory(operation, targetResolution, readbackRecord) {
  const actual = readbackRecord.inventory || [];
  const expected = operation.payload.items || operation.payload.inventory || [];
  const missing = expected.filter((entry) => {
    return !actual.some((actualEntry) => valueMatches(actualEntry.item, entry.item || entry));
  });
  if (!missing.length) {
    return result(operation, "PASS", `${operation.target} inventory contains expected entries.`, {
      targetResolution
    });
  }
  return result(operation, "FAIL", `${operation.target} inventory is missing expected entries.`, {
    targetResolution,
    missing,
    actual
  });
}

function verifyConditions(operation, targetResolution, readbackRecord) {
  const actual = readbackRecord.conditions || [];
  const expected = operation.payload.conditions || [];
  const missing = expected.filter((condition) => {
    return !actual.some((actualCondition) => {
      return valueMatches(actualCondition.function, condition.function) &&
        (!condition.operator || valueMatches(actualCondition.operator, condition.operator));
    });
  });
  if (!missing.length) {
    return result(operation, "PASS", `${operation.target} conditions contain expected entries.`, {
      targetResolution
    });
  }
  return result(operation, "FAIL", `${operation.target} conditions are missing expected entries.`, {
    targetResolution,
    missing,
    actual
  });
}

function verifyStoryManager(operation, targetResolution, readbackRecord) {
  const storyManager = readbackRecord.storyManager || {};
  const expectedSharesEvent = operation.payload.sharesEvent;
  if (expectedSharesEvent === undefined || storyManager.sharesEvent === expectedSharesEvent) {
    return result(operation, "PASS", `${operation.target} Story Manager expectations match readback.`, {
      targetResolution
    });
  }
  return result(operation, "FAIL", `${operation.target} Story Manager readback does not match manifest intent.`, {
    targetResolution,
    expectedSharesEvent,
    actual: storyManager
  });
}

function findReadbackRecord(readback, target, targetResolution) {
  if (!readback) {
    return null;
  }
  const records = readback.records || readback;
  if (Array.isArray(records)) {
    return records.find((record) => {
      return equals(record.editorId || record.EditorID, target) ||
        equals(record.formid || record.FormID, target) ||
        equals(record.formid || record.FormID, targetResolution.formid);
    }) || null;
  }
  return records[target] ||
    records[targetResolution.formid] ||
    records[targetResolution.editorId] ||
    null;
}

function normalizeScripts(scripts) {
  if (!Array.isArray(scripts)) {
    return [];
  }
  return scripts.map((script) => {
    if (typeof script === "string") {
      return { name: script, properties: {} };
    }
    return {
      name: script.name || script.Name,
      properties: normalizeProperties(script.properties || script.Properties || {})
    };
  });
}

function normalizeProperties(properties) {
  if (Array.isArray(properties)) {
    const result = {};
    for (const property of properties) {
      result[property.name || property.Name] = property.value ?? property.Object ?? property.Value;
    }
    return result;
  }
  return { ...properties };
}

function result(operation, status, message, details = {}) {
  return {
    operationId: operation.id,
    kind: operation.kind,
    target: operation.target,
    status,
    message,
    details
  };
}

function summarize(results) {
  const summary = {
    PASS: 0,
    FAIL: 0,
    WARN: 0,
    TODO: 0
  };
  for (const item of results) {
    summary[item.status] = (summary[item.status] || 0) + 1;
  }
  return summary;
}

function valueMatches(actual, expected) {
  if (actual === expected) {
    return true;
  }
  if (typeof actual === "string" && typeof expected === "string") {
    return actual.toLowerCase() === expected.toLowerCase() ||
      actual.toLowerCase().includes(`(${expected.toLowerCase()})`);
  }
  return false;
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
