const OPERATION_NORMALIZERS = {
  "glob.duplicate_create": "record-exists",
  "record.duplicate_create": "record-exists",
  "record.create": "record-exists",
  "record.update": "record-exists",
  "message.payload.set": "message-payload",
  "activator.payload.set": "activator-payload",
  "vmad.attach_script": "vmad-scripts",
  "vmad.set_property": "vmad-properties",
  "vmad.set_array_property": "vmad-array-properties",
  "formlist.add": "formlist",
  "keyword.add": "keywords",
  "spell.add": "spells",
  "perk.add": "perks",
  "package.add": "packages",
  "inventory.add": "inventory",
  "condition.add": "conditions",
  "quest.alias.add": "aliases",
  "quest.stage.fragment": "quest-stages",
  "story_manager.node": "story-manager",
  "story_manager.node.create": "story-manager",
  "reference.place": "placed-reference",
  "artifact.seq.generate": "artifact-seq",
  "artifact.lip.generate": "artifact-lip",
  "artifact.facegen.generate": "artifact-facegen"
};

const FAMILY_NORMALIZERS = {
  ACTI: ["record-exists", "activator-payload", "vmad-scripts", "vmad-properties", "vmad-array-properties"],
  FLST: ["record-exists", "formlist"],
  GLOB: ["record-exists"],
  MESG: ["record-exists", "message", "message-payload"],
  NPC_: ["record-exists", "keywords", "spells", "perks", "packages", "inventory"],
  QUST: ["record-exists", "vmad-scripts", "vmad-properties", "vmad-array-properties", "aliases", "quest-stages", "conditions", "artifact-seq"],
  REFR: ["record-exists", "placed-reference"],
  SMEN: ["record-exists", "story-manager"],
  SMBN: ["record-exists", "story-manager"],
  SMQN: ["record-exists", "story-manager"]
};

export function createReadbackOracle(readback = null) {
  return {
    find(operation, targetResolution = {}) {
      const record = findReadbackRecord(readback, operation.target, targetResolution, readbackIdentityCandidates(operation));
      return {
        record,
        normalizer: describeReadbackNormalizer(operation, record)
      };
    }
  };
}

export function describeReadbackNormalizer(operation, readbackRecord = null) {
  const recordFamily = String(operation.recordFamily || readbackRecord?.recordType || "").toUpperCase();
  const operationNormalizer = OPERATION_NORMALIZERS[operation.kind] || null;
  const familyNormalizers = FAMILY_NORMALIZERS[recordFamily] || [];
  const supported = Boolean(operationNormalizer && (!recordFamily || familyNormalizers.includes(operationNormalizer) || !FAMILY_NORMALIZERS[recordFamily]));
  const status = operationNormalizer && supported ? "PASS" : "MISSING";
  return {
    status,
    operation: operation.kind,
    recordFamily: recordFamily || null,
    normalizer: operationNormalizer,
    familyNormalizers,
    message: status === "PASS"
      ? `Readback normalizer ${operationNormalizer} covers ${operation.kind}.`
      : `No readback normalizer covers ${operation.kind}${recordFamily ? ` for ${recordFamily}` : ""}.`
  };
}

export function findReadbackRecord(readback, target, targetResolution = {}, identityCandidates = []) {
  if (!readback) {
    return null;
  }
  const records = readback.records || readback;
  const identifiers = [
    target,
    targetResolution.formid,
    targetResolution.editorId,
    ...identityCandidates
  ].filter(Boolean);
  if (Array.isArray(records)) {
    return records.find((record) => {
      return identifiers.some((identifier) => {
        return equals(record.editorId || record.EditorID, identifier) ||
          equals(record.formid || record.FormID, identifier);
      });
    }) || null;
  }
  for (const identifier of identifiers) {
    if (records[identifier]) {
      return records[identifier];
    }
  }
  return null;
}

export function readbackIdentityCandidates(operation = {}) {
  const payload = operation.payload || {};
  const metadata = operation.metadata || {};
  const created = payload.created || payload.createdRecord || payload.expectedCreated || metadata.created || {};
  return [
    created.editorId,
    created.EditorID,
    created.formid,
    created.FormID,
    payload.createdEditorId,
    payload.createdFormid,
    payload.createdFormID,
    payload.expectedEditorId,
    payload.expectedFormid,
    payload.expectedFormID
  ].filter(Boolean);
}

export function normalizeGlobalPayload(record = {}) {
  const fields = record.fields || record.Fields || {};
  const global = record.global || record.Global || {};
  return {
    type: record.globalType ?? record.type ?? global.type ?? global.Type ?? fields.FNAM ?? fields.Type ?? fields.GlobalType ?? null,
    value: record.value ?? record.globalValue ?? global.value ?? global.Value ?? fields.FLTV ?? fields.Value ?? fields.GlobalValue ?? null
  };
}

export function isDiscoveryOnlyEvidence(readbackRecord) {
  if (!readbackRecord || typeof readbackRecord !== "object") {
    return false;
  }
  const proofSurface = String(readbackRecord.proofSurface || "").toLowerCase();
  const saveStatus = String(readbackRecord.saveStatus || readbackRecord.save_status || "").toLowerCase();
  return readbackRecord.observerEnvelopeOnly === true ||
    readbackRecord.invocationPlanOnly === true ||
    readbackRecord.factoryReturnOnly === true ||
    readbackRecord.wrapperReturnOnly === true ||
    readbackRecord.callerContractOnly === true ||
    readbackRecord.sourceProbeOnly === true ||
    readbackRecord.selectorProbeOnly === true ||
    readbackRecord.guardProbeOnly === true ||
    readbackRecord.existingRecordReturnOnly === true ||
    readbackRecord.templateRecordReturnOnly === true ||
    readbackRecord.booleanReturnOnly === true ||
    readbackRecord.noCaptureOnly === true ||
    readbackRecord.postAllocationCandidateOnly === true ||
    readbackRecord.missedCaptureOnly === true ||
    readbackRecord.saved === false ||
    proofSurface === "observer-envelope" ||
    proofSurface === "observer_envelope" ||
    proofSurface === "invocation-plan" ||
    proofSurface === "invocation_plan" ||
    proofSurface === "factory-return" ||
    proofSurface === "factory_return" ||
    proofSurface === "factory-return-only" ||
    proofSurface === "factory_return_only" ||
    proofSurface === "wrapper-return" ||
    proofSurface === "wrapper_return" ||
    proofSurface === "wrapper-return-only" ||
    proofSurface === "wrapper_return_only" ||
    proofSurface === "factory-0x141627e60" ||
    proofSurface === "wrapper-0x14169c520" ||
    proofSurface === "caller-contract" ||
    proofSurface === "caller_contract" ||
    proofSurface === "caller-contract-only" ||
    proofSurface === "caller_contract_only" ||
    proofSurface === "ck-ui-stack" ||
    proofSurface === "ck_ui_stack" ||
    proofSurface === "source-probe" ||
    proofSurface === "source_probe" ||
    proofSurface === "selector-probe" ||
    proofSurface === "selector_probe" ||
    proofSurface === "guard-probe" ||
    proofSurface === "guard_probe" ||
    proofSurface === "existing-glob-return" ||
    proofSurface === "existing_glob_return" ||
    proofSurface === "template-record-return" ||
    proofSurface === "template_record_return" ||
    proofSurface === "boolean-return" ||
    proofSurface === "boolean_return" ||
    proofSurface === "no-capture" ||
    proofSurface === "no_capture" ||
    proofSurface === "post-allocation-candidate" ||
    proofSurface === "post_allocation_candidate" ||
    proofSurface === "post-allocation-0x141618120" ||
    proofSurface === "post_allocation_0x141618120" ||
    proofSurface === "phase33-post-allocation-candidate" ||
    proofSurface === "phase33_post_allocation_candidate" ||
    proofSurface === "phase36-missed" ||
    proofSurface === "phase36_missed" ||
    proofSurface === "phase37-missed" ||
    proofSurface === "phase37_missed" ||
    saveStatus === "no-save" ||
    saveStatus === "unsaved" ||
    readbackRecord.observerEnvelope?.recordDetail === false;
}

export function normalizeScripts(scripts) {
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

export function normalizeProperties(properties) {
  if (Array.isArray(properties)) {
    const result = {};
    for (const property of properties) {
      result[property.name || property.Name] = property.value ?? property.Object ?? property.Value;
    }
    return result;
  }
  return { ...properties };
}

export function readPath(object, path) {
  if (!path || typeof path !== "string") {
    return undefined;
  }
  return path.split(".").reduce((current, key) => current?.[key], object);
}

export function detectPartialOverlay(operation, readbackRecord, manifest = {}) {
  if (!readbackRecord) {
    return null;
  }
  const generatedPlugin = manifest.output;
  const stale = detectStaleGeneratedOutput(operation, readbackRecord, manifest);
  if (stale) {
    return stale;
  }
  const winningPlugin = readbackRecord.winningPlugin;
  const generatedWins = generatedPlugin && valueMatches(winningPlugin, generatedPlugin);
  const missingFields = readbackRecord.missingFields || readbackRecord.partialOverlay?.missingFields || [];
  const explicitPartial = readbackRecord.partialOverlay === true ||
    readbackRecord.overlayComplete === false ||
    (readbackRecord.partialOverlay && readbackRecord.partialOverlay.status === "partial");
  if (!generatedWins && !explicitPartial) {
    return null;
  }
  if (explicitPartial || missingFields.length) {
    return {
      status: "FAIL",
      generatedPlugin,
      winningPlugin,
      missingFields,
      conflictChain: readbackRecord.conflictChain || null,
      message: `${operation.target} is a partial winning overlay.`
    };
  }
  return null;
}

export function detectStaleGeneratedOutput(operation, readbackRecord, manifest = {}) {
  const expectedGeneratedPlugin = manifest.output;
  const observedGeneratedPlugin = readbackRecord.generatedPlugin ||
    readbackRecord.sourceGeneratedPlugin ||
    readbackRecord.readbackGeneratedPlugin ||
    readbackRecord.artifactPlugin ||
    null;
  if (!expectedGeneratedPlugin || !observedGeneratedPlugin) {
    return null;
  }
  if (valueMatches(observedGeneratedPlugin, expectedGeneratedPlugin)) {
    return null;
  }
  return {
    status: "FAIL",
    generatedPlugin: expectedGeneratedPlugin,
    observedGeneratedPlugin,
    message: `${operation.target} readback came from stale generated output ${observedGeneratedPlugin}; expected ${expectedGeneratedPlugin}.`
  };
}

export function valueMatches(actual, expected) {
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
