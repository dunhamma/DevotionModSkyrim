import { createResolver } from "./resolver.mjs";
import { createReadbackOracle, detectPartialOverlay, isDiscoveryOnlyEvidence, normalizeGlobalPayload, normalizeScripts, readPath, valueMatches } from "./readback-oracle.mjs";

export function verifyManifest(manifest, profile, readback = null) {
  const resolver = createResolver(profile);
  const oracle = createReadbackOracle(readback);
  const results = [];

  for (const operation of manifest.operations) {
    const targetResolution = resolver.resolveRecord(operation.target);
    const { record: readbackRecord, normalizer } = oracle.find(operation, targetResolution);
    results.push(verifyOperation(operation, targetResolution, readbackRecord, { manifest, profile, normalizer }));
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

function verifyOperation(operation, targetResolution, readbackRecord, context = {}) {
  if (!readbackRecord) {
    return result(operation, "TODO", `No readback record was supplied for ${operation.target}.`, {
      targetResolution,
      readbackNormalizer: context.normalizer
    });
  }

  if (context.normalizer?.status !== "PASS") {
    return result(operation, "TODO", context.normalizer?.message || `No readback normalizer is implemented for ${operation.kind}.`, {
      targetResolution,
      readbackNormalizer: context.normalizer
    });
  }

  if (isDiscoveryOnlyEvidence(readbackRecord)) {
    return result(operation, "TODO", `${operation.target} only has discovery-phase evidence; saved record-detail readback is required for support proof.`, {
      targetResolution,
      readbackNormalizer: context.normalizer,
      observerEnvelope: readbackRecord.observerEnvelope || null,
      proofSurface: readbackRecord.proofSurface || null
    });
  }

  const winningPluginResult = verifyWinningPlugin(operation, readbackRecord, context);
  if (winningPluginResult) {
    return winningPluginResult;
  }

  const partialOverlay = detectPartialOverlay(operation, readbackRecord, context.manifest);
  if (partialOverlay) {
    return result(operation, "FAIL", partialOverlay.message, {
      targetResolution,
      partialOverlay
    });
  }

  const expectationResult = verifyExpectations(operation, readbackRecord);
  if (expectationResult) {
    return expectationResult;
  }

  if (operation.kind === "vmad.attach_script") {
    return verifyScript(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "vmad.set_property" || operation.kind === "vmad.set_array_property") {
    return verifyVmadProperty(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "formlist.add") {
    return verifyListContains(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "keyword.add") {
    const payload = operation.payload || {};
    return verifyContainsAny(operation, targetResolution, readbackRecord, "keywords", payload.keywords || payload.keyword);
  }

  if (operation.kind === "spell.add") {
    const payload = operation.payload || {};
    return verifyContainsAny(operation, targetResolution, readbackRecord, "spells", payload.spells || payload.spell);
  }

  if (operation.kind === "perk.add") {
    const payload = operation.payload || {};
    return verifyContainsAny(operation, targetResolution, readbackRecord, "perks", payload.perks || payload.perk);
  }

  if (operation.kind === "package.add") {
    const payload = operation.payload || {};
    return verifyContainsAny(operation, targetResolution, readbackRecord, "packages", payload.packages || payload.package);
  }

  if (operation.kind === "inventory.add") {
    return verifyInventory(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "condition.add") {
    return verifyConditions(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "message.payload.set") {
    return verifyMessagePayload(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "activator.payload.set") {
    return verifyActivatorPayload(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "quest.alias.add") {
    return verifyAlias(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "quest.stage.fragment") {
    return verifyQuestStage(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "artifact.seq.generate") {
    return verifyArtifact(operation, targetResolution, readbackRecord, "seq");
  }

  if (operation.kind === "artifact.lip.generate") {
    return verifyArtifact(operation, targetResolution, readbackRecord, "lip");
  }

  if (operation.kind === "artifact.facegen.generate") {
    return verifyArtifact(operation, targetResolution, readbackRecord, "facegen");
  }

  if (operation.kind === "story_manager.node") {
    return verifyStoryManager(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "dialogue.branch.create") {
    return verifyDialogueBranch(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "dialogue.topic.create") {
    return verifyDialogueTopic(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "dialogue.info.create") {
    return verifyDialogueInfo(operation, targetResolution, readbackRecord);
  }

  if (operation.kind === "reference.place") {
    return verifyPlacedReference(operation, targetResolution, readbackRecord);
  }

  if ((operation.kind === "record.create" || operation.kind === "glob.duplicate_create") && isGlobCreate(operation, readbackRecord)) {
    return verifyGlobCreate(operation, targetResolution, readbackRecord, context);
  }

  if (operation.kind === "record.duplicate_create") {
    return verifyDuplicateCreate(operation, targetResolution, readbackRecord, context);
  }

  if (operation.kind === "record.create" || operation.kind === "record.update") {
    return verifyGenericRecordPayload(operation, targetResolution, readbackRecord, context);
  }

  return result(operation, "TODO", `No verifier is implemented for ${operation.kind}.`, {
    targetResolution
  });
}

function verifyWinningPlugin(operation, readbackRecord, { manifest } = {}) {
  const expectedWinner = operation.verifierExpectations?.find((expectation) => expectation.type === "winningPlugin")?.value;
  const generatedPlugin = manifest?.output;
  const actualWinner = readbackRecord.winningPlugin;
  if (!actualWinner) {
    return null;
  }
  if (expectedWinner && !valueMatches(actualWinner, expectedWinner)) {
    return result(operation, "FAIL", `${operation.target} winning plugin is ${actualWinner}, expected ${expectedWinner}.`, { actualWinner, expectedWinner });
  }
  if (!expectedWinner && generatedPlugin && operation.mode !== "update_accepted_source" && operation.mergePolicy?.promote !== "accepted-source") {
    if (!valueMatches(actualWinner, generatedPlugin)) {
      return result(operation, "FAIL", `${operation.target} is not won by generated plugin ${generatedPlugin}.`, { actualWinner, expectedWinner: generatedPlugin });
    }
  }
  return null;
}

function isGlobCreate(operation, readbackRecord) {
  const family = operation.recordFamily || operation.payload?.recordType || readbackRecord?.recordType;
  return String(family || "").toUpperCase() === "GLOB";
}

function verifyGlobCreate(operation, targetResolution, readbackRecord, { manifest } = {}) {
  const expectedRecordType = operation.payload.recordType || operation.recordFamily || "GLOB";
  const actualRecordType = readbackRecord.recordType || readbackRecord.type;
  const created = expectedCreatedIdentity(operation);
  const source = expectedSourceIdentity(operation);
  const globalPayload = normalizeGlobalPayload(readbackRecord);
  const expectedType = operation.payload.globalType ?? operation.payload.type;
  const expectedValue = operation.payload.value ?? operation.payload.globalValue;
  const failures = [];

  if (!valueMatches(actualRecordType, expectedRecordType)) {
    failures.push({ field: "recordType", expected: expectedRecordType, actual: actualRecordType });
  }

  if (!readbackRecord.winningPlugin) {
    failures.push({ field: "winningPlugin", expected: manifest?.output || "(generated plugin)", actual: readbackRecord.winningPlugin });
  } else if (manifest?.output && !valueMatches(readbackRecord.winningPlugin, manifest.output)) {
    failures.push({ field: "winningPlugin", expected: manifest.output, actual: readbackRecord.winningPlugin });
  }

  if (created.editorId && !valueMatches(readbackRecord.editorId || readbackRecord.EditorID, created.editorId)) {
    failures.push({ field: "created.editorId", expected: created.editorId, actual: readbackRecord.editorId || readbackRecord.EditorID });
  }

  if (created.formid && !valueMatches(readbackRecord.formid || readbackRecord.FormID, created.formid)) {
    failures.push({ field: "created.formid", expected: created.formid, actual: readbackRecord.formid || readbackRecord.FormID });
  }

  if (source.editorId || source.formid) {
    const evidence = readbackRecord.source || readbackRecord.duplicatedFrom || readbackRecord.createdFrom || {};
    if (source.editorId && !valueMatches(evidence.editorId || evidence.EditorID || evidence.editorID, source.editorId)) {
      failures.push({ field: "source.editorId", expected: source.editorId, actual: evidence.editorId || evidence.EditorID || evidence.editorID });
    }
    if (source.formid && !valueMatches(evidence.formid || evidence.FormID || evidence.formID, source.formid)) {
      failures.push({ field: "source.formid", expected: source.formid, actual: evidence.formid || evidence.FormID || evidence.formID });
    }
  }

  if (expectedType !== undefined && !scalarMatches(globalPayload.type, expectedType)) {
    failures.push({ field: "global.type", expected: expectedType, actual: globalPayload.type });
  }

  if (expectedValue !== undefined && !scalarMatches(globalPayload.value, expectedValue)) {
    failures.push({ field: "global.value", expected: expectedValue, actual: globalPayload.value });
  }

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} GLOB duplicate-create readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual: {
        editorId: readbackRecord.editorId || readbackRecord.EditorID,
        formid: readbackRecord.formid || readbackRecord.FormID,
        recordType: actualRecordType,
        winningPlugin: readbackRecord.winningPlugin,
        global: globalPayload
      }
    });
  }

  return result(operation, "PASS", `${operation.target} GLOB duplicate-create matches readback.`, {
    targetResolution,
    created,
    source,
    global: globalPayload
  });
}

function expectedCreatedIdentity(operation) {
  const payload = operation.payload || {};
  const metadata = operation.metadata || {};
  const created = payload.created || payload.createdRecord || payload.expectedCreated || metadata.created || {};
  return {
    editorId: created.editorId || created.EditorID || payload.createdEditorId || payload.expectedEditorId || null,
    formid: created.formid || created.FormID || payload.createdFormid || payload.createdFormID || payload.expectedFormid || payload.expectedFormID || null
  };
}

function expectedSourceIdentity(operation) {
  const payload = operation.payload || {};
  const source = payload.source || payload.duplicateOf || payload.createdFrom || {};
  return {
    editorId: source.editorId || source.EditorID || payload.sourceEditorId || payload.duplicateOfEditorId || null,
    formid: source.formid || source.FormID || payload.sourceFormid || payload.sourceFormID || payload.duplicateOfFormid || payload.duplicateOfFormID || null
  };
}

function scalarMatches(actual, expected) {
  if (valueMatches(actual, expected)) {
    return true;
  }
  if (actual === null || actual === undefined || expected === null || expected === undefined) {
    return false;
  }
  if (Number.isFinite(Number(actual)) && Number.isFinite(Number(expected))) {
    return Number(actual) === Number(expected);
  }
  return String(actual).toLowerCase() === String(expected).toLowerCase();
}

function verifyVmadProperty(operation, targetResolution, readbackRecord) {
  const scriptName = operation.payload.script;
  const propertyName = operation.payload.name || operation.payload.property || operation.payload.propertyName;
  const expected = operation.payload.value ?? operation.payload.values;
  const scripts = normalizeScripts(readbackRecord.scripts || readbackRecord.Scripts || []);
  const script = scriptName
    ? scripts.find((item) => equals(item.name, scriptName))
    : scripts.find((item) => propertyName && Object.prototype.hasOwnProperty.call(item.properties, propertyName));
  if (!script) {
    return result(operation, "FAIL", `No VMAD script carrying ${propertyName || "the requested property"} was found on ${operation.target}.`, { targetResolution });
  }
  if (!propertyName || !(propertyName in script.properties)) {
    return result(operation, "FAIL", `VMAD property ${propertyName || "(missing)"} is not present on ${operation.target}.`, { targetResolution });
  }
  if (operation.kind === "vmad.set_array_property") {
    const actual = Array.isArray(script.properties[propertyName]) ? script.properties[propertyName] : [];
    const expectedValues = Array.isArray(expected) ? expected : [];
    const missing = expectedValues.filter((value) => !actual.some((entry) => valueMatches(entry, value)));
    if (missing.length) {
      return result(operation, "FAIL", `VMAD array property ${propertyName} is missing expected values.`, { targetResolution, expected: expectedValues, actual, missing });
    }
    return result(operation, "PASS", `VMAD array property ${propertyName} contains expected values.`, { targetResolution });
  }
  if (!valueMatches(script.properties[propertyName], expected)) {
    return result(operation, "FAIL", `VMAD property ${propertyName} does not match manifest intent.`, { targetResolution, expected, actual: script.properties[propertyName] });
  }
  return result(operation, "PASS", `VMAD property ${propertyName} matches manifest intent.`, { targetResolution });
}

function verifyArtifact(operation, targetResolution, readbackRecord, kind) {
  const artifacts = readbackRecord.artifacts || [];
  const match = artifacts.find((artifact) => !artifact.kind || equals(artifact.kind, kind));
  if (match && match.exists !== false && match.fresh !== false) {
    return result(operation, "PASS", `${kind.toUpperCase()} artifact is present and fresh.`, { targetResolution, artifact: match });
  }
  return result(operation, "FAIL", `${kind.toUpperCase()} artifact is missing or stale.`, { targetResolution, artifacts });
}
function verifyExpectations(operation, readbackRecord) {
  const expectations = operation.verifierExpectations || [];
  const failures = [];
  const unsupported = [];
  for (const expectation of expectations) {
    if (expectation.type === "fieldEquals") {
      const actual = readPath(readbackRecord, expectation.path);
      if (!valueMatches(actual, expectation.value)) {
        failures.push({ expectation, actual });
      }
      continue;
    }
    if (expectation.type === "contains") {
      const actual = readPath(readbackRecord, expectation.path);
      const values = Array.isArray(actual) ? actual : [];
      if (!values.some((value) => valueMatches(value, expectation.value))) {
        failures.push({ expectation, actual });
      }
      continue;
    }
    if (expectation.type === "winningPlugin") {
      continue;
    }
    if (expectation.type === "conflictChainPresent") {
      const chain = readbackRecord.conflictChain || [];
      if (!Array.isArray(chain) || !chain.length) {
        failures.push({ expectation, actual: chain });
      }
      continue;
    }
    if (expectation.type === "messageButton") {
      const buttons = readbackRecord.message?.buttons || [];
      if (!buttons.some((button) => valueMatches(button.text, expectation.text || expectation.value))) {
        failures.push({ expectation, actual: buttons });
      }
      continue;
    }
    if (expectation.type === "artifactFresh") {
      const artifacts = readbackRecord.artifacts || [];
      const match = artifacts.find((artifact) => !expectation.kind || valueMatches(artifact.kind, expectation.kind));
      if (!match || match.exists === false || match.fresh === false) {
        failures.push({ expectation, actual: artifacts });
      }
      continue;
    }
    unsupported.push(expectation);
  }
  if (unsupported.length) {
    return result(operation, "TODO", `${operation.target} has unsupported verifier expectations.`, {
      unsupported
    });
  }
  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} failed verifier expectations.`, {
      failures
    });
  }
  return null;
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
  if (!expected.length) {
    return result(operation, "FAIL", `${operation.target} ${field} verifier payload is missing expected entries.`, {
      targetResolution,
      field
    });
  }
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
    return !actual.some((actualEntry) => {
      const itemMatches = valueMatches(actualEntry.item, entry.item || entry);
      const expectedCount = entry.count ?? entry.Count ?? null;
      return itemMatches && (expectedCount === null || Number(actualEntry.count) === Number(expectedCount));
    });
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
        (!condition.operator || conditionOperatorMatches(actualCondition, condition.operator));
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

function conditionOperatorMatches(actualCondition, expectedOperator) {
  return valueMatches(actualCondition.operator, expectedOperator) ||
    valueMatches(actualCondition.raw?.CompareOperator, expectedOperator) ||
    valueMatches(actualCondition.raw?.Operator, expectedOperator);
}

function verifyGenericRecordPayload(operation, targetResolution, readbackRecord, { manifest } = {}) {
  const payload = operation.payload || {};
  const expectedRecordType = payload.recordType || operation.recordFamily || null;
  const actualRecordType = readbackRecord.recordType || readbackRecord.type;
  const failures = [];
  const checkedPaths = [];

  if (expectedRecordType && !valueMatches(actualRecordType, expectedRecordType)) {
    failures.push({ field: "recordType", expected: expectedRecordType, actual: actualRecordType });
  }

  if (!readbackRecord.winningPlugin) {
    failures.push({ field: "winningPlugin", expected: manifest?.output || "(generated plugin)", actual: readbackRecord.winningPlugin });
  } else if (manifest?.output && operation.mode !== "update_accepted_source" && operation.mergePolicy?.promote !== "accepted-source" && !valueMatches(readbackRecord.winningPlugin, manifest.output)) {
    failures.push({ field: "winningPlugin", expected: manifest.output, actual: readbackRecord.winningPlugin });
  }

  for (const section of payloadComparisonSections(payload)) {
    const actualRoot = section.readbackPath ? readPath(readbackRecord, section.readbackPath) : readbackRecord;
    collectPayloadMismatches(section.value, actualRoot, section.label, failures, checkedPaths);
  }

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} record payload readback does not match manifest intent.`, {
      targetResolution,
      failures,
      checkedPaths,
      actual: {
        editorId: readbackRecord.editorId || readbackRecord.EditorID,
        formid: readbackRecord.formid || readbackRecord.FormID,
        recordType: actualRecordType,
        winningPlugin: readbackRecord.winningPlugin
      }
    });
  }

  return result(operation, "PASS", checkedPaths.length
    ? `${operation.target} exists and record payload matches readback.`
    : `${operation.target} exists in readback.`, {
    targetResolution,
    checkedPaths
  });
}

function payloadComparisonSections(payload = {}) {
  return [
    { label: "fields", readbackPath: "fields", value: payload.fields },
    { label: "inventory", readbackPath: "inventory", value: payload.inventory },
    { label: "keywords", readbackPath: "keywords", value: payload.keywords },
    { label: "spells", readbackPath: "spells", value: payload.spells },
    { label: "perks", readbackPath: "perks", value: payload.perks },
    { label: "packages", readbackPath: "packages", value: payload.packages },
    { label: "conditions", readbackPath: "conditions", value: payload.conditions },
    { label: "scripts", readbackPath: "scripts", value: payload.scripts }
  ].filter((section) => section.value !== undefined);
}

function collectPayloadMismatches(expected, actual, path, failures, checkedPaths) {
  if (Array.isArray(expected)) {
    if (!Array.isArray(actual)) {
      failures.push({ field: path, expected, actual });
      return;
    }
    expected.forEach((entry, index) => {
      collectPayloadMismatches(entry, actual[index], `${path}.${index}`, failures, checkedPaths);
    });
    return;
  }

  if (expected && typeof expected === "object") {
    for (const [key, value] of Object.entries(expected)) {
      collectPayloadMismatches(value, actual?.[key], `${path}.${key}`, failures, checkedPaths);
    }
    return;
  }

  checkedPaths.push(path);
  if (!scalarMatches(actual, expected)) {
    failures.push({ field: path, expected, actual });
  }
}

function verifyDuplicateCreate(operation, targetResolution, readbackRecord, { manifest } = {}) {
  const expectedRecordType = operation.payload?.recordType || operation.recordFamily || null;
  const actualRecordType = readbackRecord.recordType || readbackRecord.type;
  const created = expectedCreatedIdentity(operation);
  const source = expectedSourceIdentity(operation);
  const actualWinner = readbackRecord.winningPlugin || targetResolution?.winningPlugin || null;
  const failures = [];

  const recordTypeMatches = expectedRecordType
    ? valueMatches(actualRecordType, expectedRecordType) ||
      valueMatches(actualRecordType, expandRecordTypeName(expectedRecordType))
    : true;
  if (!recordTypeMatches) {
    failures.push({ field: "recordType", expected: expectedRecordType, actual: actualRecordType });
  }

  if (!actualWinner) {
    failures.push({ field: "winningPlugin", expected: manifest?.output || "(generated plugin)", actual: actualWinner });
  } else if (manifest?.output && !valueMatches(actualWinner, manifest.output)) {
    failures.push({ field: "winningPlugin", expected: manifest.output, actual: actualWinner });
  }

  if (created.editorId && !valueMatches(readbackRecord.editorId || readbackRecord.EditorID, created.editorId)) {
    failures.push({ field: "created.editorId", expected: created.editorId, actual: readbackRecord.editorId || readbackRecord.EditorID });
  }

  if (created.formid && !valueMatches(readbackRecord.formid || readbackRecord.FormID, created.formid)) {
    failures.push({ field: "created.formid", expected: created.formid, actual: readbackRecord.formid || readbackRecord.FormID });
  }

  if (source.editorId || source.formid) {
    const evidence = readbackRecord.source || readbackRecord.duplicatedFrom || readbackRecord.createdFrom || {};
    const actualSourceEditorId = evidence.editorId || evidence.EditorID || evidence.editorID;
    const actualSourceFormId = evidence.formid || evidence.FormID || evidence.formID;
    if (source.editorId && actualSourceEditorId !== undefined && !valueMatches(actualSourceEditorId, source.editorId)) {
      failures.push({ field: "source.editorId", expected: source.editorId, actual: evidence.editorId || evidence.EditorID || evidence.editorID });
    }
    if (source.formid && actualSourceFormId !== undefined && !valueMatches(actualSourceFormId, source.formid)) {
      failures.push({ field: "source.formid", expected: source.formid, actual: evidence.formid || evidence.FormID || evidence.formID });
    }
  }

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} duplicate-create readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual: {
        editorId: readbackRecord.editorId || readbackRecord.EditorID,
        formid: readbackRecord.formid || readbackRecord.FormID,
        recordType: actualRecordType,
        winningPlugin: actualWinner
      }
    });
  }

  return result(operation, "PASS", `${operation.target} duplicate-create identity matches readback.`, {
    targetResolution,
    created,
    source
  });
}

function expandRecordTypeName(recordType) {
  const normalized = String(recordType || "").toUpperCase();
  const aliases = {
    ACTI: "ACTIVATOR",
    FLST: "FORMLIST",
    QUST: "QUEST",
    MESG: "MESSAGE",
    GLOB: "GLOBAL"
  };
  return aliases[normalized] || normalized;
}

function verifyMessagePayload(operation, targetResolution, readbackRecord) {
  const actual = normalizeMessagePayload(readbackRecord);
  const failures = [];
  const payload = operation.payload || {};
  if (payload.title !== undefined && !valueMatches(actual.title, payload.title)) {
    failures.push({ field: "title", expected: payload.title, actual: actual.title });
  }
  if (payload.text !== undefined && !valueMatches(actual.text, payload.text)) {
    failures.push({ field: "text", expected: payload.text, actual: actual.text });
  }
  if (payload.buttons !== undefined) {
    const expectedButtons = Array.isArray(payload.buttons) ? payload.buttons : [];
    const missingButtons = expectedButtons.filter((expected) => {
      const expectedText = typeof expected === "string" ? expected : expected.text;
      return !actual.buttons.some((button) => valueMatches(button.text, expectedText));
    });
    if (missingButtons.length) {
      failures.push({ field: "buttons", expected: expectedButtons, actual: actual.buttons, missing: missingButtons });
    }
  }
  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} message payload readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual
    });
  }
  return result(operation, "PASS", `${operation.target} message payload matches manifest intent.`, {
    targetResolution,
    actual
  });
}

function verifyActivatorPayload(operation, targetResolution, readbackRecord) {
  const payload = operation.payload || {};
  const actual = normalizeActivatorPayload(readbackRecord);
  const failures = [];
  const expectedName = payload.fullName ?? payload.name;
  if (expectedName !== undefined && !valueMatches(actual.fullName, expectedName)) {
    failures.push({ field: "fullName", expected: expectedName, actual: actual.fullName });
  }
  if (payload.model !== undefined && !valueMatches(modelFile(actual.model), modelFile(payload.model))) {
    failures.push({ field: "model", expected: payload.model, actual: actual.model });
  }
  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} activator payload readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual
    });
  }
  return result(operation, "PASS", `${operation.target} activator payload matches manifest intent.`, {
    targetResolution,
    actual
  });
}

function normalizeMessagePayload(record = {}) {
  const fields = record.fields || record.Fields || {};
  const message = record.message || record.Message || {};
  const rawButtons = message.buttons || record.buttons || fields.buttons || [];
  return {
    title: record.title ?? message.title ?? fields.title ?? fields.FULL ?? null,
    text: record.text ?? message.text ?? fields.text ?? fields.DESC ?? fields.NAM1 ?? null,
    buttons: Array.isArray(rawButtons)
      ? rawButtons.map((button) => typeof button === "string" ? { text: button } : { ...button })
      : []
  };
}

function normalizeActivatorPayload(record = {}) {
  const fields = record.fields || record.Fields || {};
  const activator = record.activator || record.Activator || {};
  return {
    fullName: record.fullName ?? record.name ?? activator.fullName ?? activator.name ?? fields.FULL ?? null,
    model: record.model ?? activator.model ?? fields.model ?? fields.MODL ?? null
  };
}

function modelFile(value) {
  if (value && typeof value === "object") {
    return value.file ?? value.File ?? value.path ?? value.Path ?? value.model ?? value.Model ?? value;
  }
  return value;
}

function verifyAlias(operation, targetResolution, readbackRecord) {
  const aliases = readbackRecord.aliases || [];
  const expectedName = operation.payload.name || operation.payload.alias || operation.payload.aliasName;
  const match = aliases.find((alias) => valueMatches(alias.name, expectedName) || valueMatches(String(alias.id), String(operation.payload.id)));
  if (match) {
    return result(operation, "PASS", `${operation.target} alias ${expectedName || operation.payload.id} exists.`, {
      targetResolution,
      alias: match
    });
  }
  return result(operation, "FAIL", `${operation.target} is missing alias ${expectedName || operation.payload.id}.`, {
    targetResolution,
    aliases
  });
}

function verifyQuestStage(operation, targetResolution, readbackRecord) {
  const stages = readbackRecord.stages || [];
  const expectedStage = operation.payload.stage ?? operation.payload.index;
  const match = stages.find((stage) => String(stage.index ?? stage.stage ?? stage.id) === String(expectedStage));
  if (match) {
    return result(operation, "PASS", `${operation.target} stage ${expectedStage} exists.`, {
      targetResolution,
      stage: match
    });
  }
  return result(operation, "FAIL", `${operation.target} is missing stage ${expectedStage}.`, {
    targetResolution,
    stages
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

function verifyDialogueBranch(operation, targetResolution, readbackRecord) {
  const payload = operation.payload || {};
  const actual = normalizeDialogueReadback(readbackRecord);
  const failures = [];

  if (!recordTypeAllowed(actual.recordType, payload.recordType, ["DLBR", "DIAL"])) {
    failures.push({ field: "recordType", expected: payload.recordType || "DLBR", actual: actual.recordType });
  }
  compareIfExpected(failures, "ownerQuest", actual.ownerQuest, payload.ownerQuest);
  compareIfExpected(failures, "category", actual.category, payload.category);
  compareIfExpected(failures, "startingTopic", actual.startingTopic, payload.startingTopic || payload.topic);
  for (const flag of normalizeStringArray(payload.flags)) {
    if (!actual.flags.some((actualFlag) => valueMatches(actualFlag, flag))) {
      failures.push({ field: "flags", expected: flag, actual: actual.flags });
    }
  }

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} dialogue branch readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual
    });
  }

  return result(operation, "PASS", `${operation.target} dialogue branch matches readback.`, {
    targetResolution,
    actual
  });
}

function verifyDialogueTopic(operation, targetResolution, readbackRecord) {
  const payload = operation.payload || {};
  const actual = normalizeDialogueReadback(readbackRecord);
  const failures = [];

  if (!recordTypeAllowed(actual.recordType, payload.recordType, ["DIAL"])) {
    failures.push({ field: "recordType", expected: payload.recordType || "DIAL", actual: actual.recordType });
  }
  compareIfExpected(failures, "ownerQuest", actual.ownerQuest, payload.ownerQuest);
  compareIfExpected(failures, "branch", actual.branch, payload.branch);
  compareIfExpected(failures, "prompt", actual.prompt, payload.prompt);
  compareIfExpected(failures, "category", actual.category, payload.category);
  compareIfExpected(failures, "subtype", actual.subtype, payload.subtype);

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} dialogue topic readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual
    });
  }

  return result(operation, "PASS", `${operation.target} dialogue topic matches readback.`, {
    targetResolution,
    actual
  });
}

function verifyDialogueInfo(operation, targetResolution, readbackRecord) {
  const payload = operation.payload || {};
  const actual = normalizeDialogueReadback(readbackRecord);
  const failures = [];

  if (!recordTypeAllowed(actual.recordType, payload.recordType, ["INFO"])) {
    failures.push({ field: "recordType", expected: payload.recordType || "INFO", actual: actual.recordType });
  }
  compareIfExpected(failures, "topic", actual.topic, payload.topic);
  compareIfExpected(failures, "speaker", actual.speaker, payload.speaker);
  compareIfExpected(failures, "speakerForm", actual.speakerForm, payload.speakerForm);
  compareIfExpected(failures, "prompt", actual.prompt, payload.prompt);
  compareIfExpected(failures, "responseLine", actual.responseLine, payload.responseLine || payload.response || payload.text);

  const missingConditions = missingExpectedConditions(payload.conditions || [], actual.conditions);
  if (missingConditions.length) {
    failures.push({ field: "conditions", missing: missingConditions, actual: actual.conditions });
  }

  if (failures.length) {
    return result(operation, "FAIL", `${operation.target} dialogue info readback does not match manifest intent.`, {
      targetResolution,
      failures,
      actual
    });
  }

  return result(operation, "PASS", `${operation.target} dialogue info matches readback.`, {
    targetResolution,
    actual
  });
}

function normalizeDialogueReadback(record = {}) {
  const fields = record.fields || record.Fields || {};
  const dialogue = record.dialogue || record.Dialogue || record.topicInfo || record.TopicInfo || {};
  return {
    editorId: record.editorId || record.EditorID || null,
    formid: record.formid || record.FormID || null,
    recordType: record.recordType || record.type || record.RecordType || null,
    ownerQuest: firstDefined(record.ownerQuest, dialogue.ownerQuest, fields.OwnerQuest, fields.Quest, fields.Owner),
    category: firstDefined(record.category, dialogue.category, fields.Category),
    flags: normalizeStringArray(firstDefined(record.flags, dialogue.flags, fields.Flags)),
    startingTopic: firstDefined(record.startingTopic, dialogue.startingTopic, fields.StartingTopic, fields.StartingTopicEditorID),
    branch: firstDefined(record.branch, dialogue.branch, fields.Branch, fields.DialogBranch, fields.BranchEditorID),
    prompt: firstDefined(record.prompt, dialogue.prompt, fields.Prompt, fields.Name, fields.FullName),
    subtype: firstDefined(record.subtype, dialogue.subtype, fields.Subtype),
    topic: firstDefined(record.topic, dialogue.topic, fields.Topic, fields.TopicEditorID, fields.ParentTopic),
    speaker: firstDefined(record.speaker, dialogue.speaker, fields.Speaker, fields.SpeakerEditorID),
    speakerForm: firstDefined(record.speakerForm, dialogue.speakerForm, fields.SpeakerForm, fields.SpeakerFormID),
    responseLine: firstDefined(record.responseLine, record.response, record.text, dialogue.responseLine, dialogue.response, dialogue.text, fields.ResponseLine, fields.ResponseText, fields.DialogueText, fields.Text),
    conditions: normalizeDialogueConditions(firstDefined(record.conditions, dialogue.conditions, fields.Conditions, []))
  };
}

function recordTypeAllowed(actual, expected, allowed) {
  if (expected) {
    return valueMatches(actual, expected);
  }
  return allowed.some((recordType) => valueMatches(actual, recordType));
}

function compareIfExpected(failures, field, actual, expected) {
  if (expected === undefined || expected === null || expected === "") {
    return;
  }
  if (!scalarMatches(actual, expected)) {
    failures.push({ field, expected, actual });
  }
}

function missingExpectedConditions(expectedConditions, actualConditions) {
  return expectedConditions.filter((expected) => {
    return !actualConditions.some((actual) => conditionMatches(actual, expected));
  });
}

function conditionMatches(actual, expected) {
  return conditionFieldMatches(actual.function, expected.function) &&
    conditionFieldMatches(actual.subject, expected.subject) &&
    conditionFieldMatches(actual.operator, expected.operator) &&
    conditionFieldMatches(actual.global, expected.global) &&
    conditionFieldMatches(actual.runOn, expected.runOn) &&
    conditionFieldMatches(actual.value, expected.value);
}

function conditionFieldMatches(actual, expected) {
  if (expected === undefined || expected === null || expected === "") {
    return true;
  }
  return scalarMatches(actual, expected);
}

function normalizeDialogueConditions(conditions) {
  if (!Array.isArray(conditions)) {
    return [];
  }
  return conditions.map((condition) => ({
    function: condition.function || condition.Function || condition.Data?.Function || null,
    subject: condition.subject || condition.Subject || condition.RunOn || condition.runOn || null,
    operator: condition.operator || condition.Operator || null,
    global: condition.global || condition.Global || condition.parameter || condition.Parameter || null,
    value: condition.value ?? condition.Value ?? condition.ComparisonValue ?? null,
    runOn: condition.runOn || condition.run_on || condition.RunOn || null,
    raw: condition
  }));
}

function normalizeStringArray(value) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item));
  }
  if (typeof value === "string") {
    return value.split(/[,\|]/u).map((item) => item.trim()).filter(Boolean);
  }
  return [];
}

function firstDefined(...values) {
  return values.find((value) => value !== undefined && value !== null && value !== "");
}

function verifyPlacedReference(operation, targetResolution, readbackRecord) {
  const placedReferences = readbackRecord.placedReferences ||
    readbackRecord.placedInstances ||
    readbackRecord.references ||
    [];
  const required = operation.payload.placedInstancesRequired ||
    operation.payload.references ||
    operation.payload.baseObjects ||
    [];
  const missing = required.filter((expected) => {
    return !placedReferences.some((reference) => {
      if (typeof reference === "string") {
        return valueMatches(reference, expected);
      }
      return valueMatches(reference.baseObject, expected) ||
        valueMatches(reference.baseEditorId, expected) ||
        valueMatches(reference.editorId, expected);
    });
  });

  if (!missing.length) {
    return result(operation, "PASS", `${operation.target} contains required placed references.`, {
      targetResolution,
      placedReferences
    });
  }

  return result(operation, "FAIL", `${operation.target} is missing required placed references.`, {
    targetResolution,
    missing,
    placedReferences
  });
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

function equals(left, right) {
  if (left === right) {
    return true;
  }
  if (typeof left !== "string" || typeof right !== "string") {
    return false;
  }
  return left.toLowerCase() === right.toLowerCase();
}

