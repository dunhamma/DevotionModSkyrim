import crypto from "node:crypto";

export const CATALOG_SCHEMA = "pdv.quest-reaction.catalog.v2";
export const CATALOG_VERSION = 2;

const BUCKETS = ["string", "float", "int", "stringList"];
const PAPYRUSUTIL_WIRE_BUCKETS = ["string", "float", "int", "stringList", "intList"];
const V1_QUEST_INDEX_KEYS = new Set([
  "questKeys",
  "questkeys",
  "questForms",
  "questforms",
  "questFormIds",
  "questformids",
  "questPlugins",
  "questplugins",
  "questEditorIds",
  "questeditorids",
  "questWatch.formIds",
  "questwatch.formids",
  "questWatch.plugins",
  "questwatch.plugins",
  "questWatch.editorIds",
  "questwatch.editorids",
  "questWatchFormIds",
  "questwatchformids",
  "questWatchPlugins",
  "questwatchplugins",
  "questWatchEditorIds",
  "questwatcheditorids",
]);
const V1_STRING_META_KEYS = new Set([
  "generatedAt",
  "generatedat",
  "schema",
  "sourceMod",
  "sourcemod",
  "questWatchFormIdsCsv",
  "questwatchformidscsv",
  "questWatchPluginsCsv",
  "questwatchpluginscsv",
]);

export function emptyTypedCatalog(kind) {
  return {
    string: {
      schema: CATALOG_SCHEMA,
      catalogKind: kind,
    },
    float: {},
    int: {
      schemaVersion: CATALOG_VERSION,
    },
    stringList: {
      sourceIds: [],
      questKeys: [],
      semanticKeys: [],
      stageAdapterKeys: [],
    },
  };
}

export function buildCoreCatalog(compiled, { stageSelectors = [] } = {}) {
  const catalog = emptyTypedCatalog("core");
  const questIndex = buildQuestIndex(compiled.flat);
  copyCompiledValues(catalog, compiled.runtime, questIndex, { includeShared: true });

  const byPlugin = new Map();
  for (const item of questIndex.values()) {
    if (!byPlugin.has(item.pluginName)) byPlugin.set(item.pluginName, []);
    byPlugin.get(item.pluginName).push(item.qualifiedKey);
  }
  for (const pluginName of [...byPlugin.keys()].sort(compareText)) {
    const sourceId = `core-${stableId(pluginName.replace(/\.[^.]+$/, ""))}`;
    const questKeys = uniqueSorted(byPlugin.get(pluginName));
    addSource(catalog, {
      sourceId,
      displayName: pluginName,
      pluginName,
      sentinelForms: questKeys.length ? [questKeyToSentinel(questKeys[0])] : [],
      questKeys,
      semanticKeys: [],
      stageAdapterKeys: stageSelectors.filter((selector) => selector.key.startsWith(`${pluginName}|`)).map((selector) => selector.key),
    });
  }
  addStageSelectors(catalog, stageSelectors);
  finalizeCatalog(catalog);
  return catalog;
}

export function buildOfficialCatalog({ sources, compiledBySource, semanticRowsBySource = new Map(), stageSelectorsBySource = new Map() }) {
  const catalog = emptyTypedCatalog("official-third-party");
  const keyOwner = new Map();

  for (const source of [...sources].sort((a, b) => compareText(a.sourceId, b.sourceId))) {
    const compiled = compiledBySource.get(source.sourceId);
    const semanticRows = semanticRowsBySource.get(source.sourceId) ?? [];
    const stageSelectors = stageSelectorsBySource.get(source.sourceId) ?? [];
    const questKeys = [];
    const semanticKeys = [];

    if (compiled) {
      const questIndex = buildQuestIndex(compiled.flat);
      for (const item of questIndex.values()) {
        claimKey(keyOwner, item.qualifiedKey, source.sourceId);
        questKeys.push(item.qualifiedKey);
      }
      copyCompiledValues(catalog, compiled.runtime, questIndex, { includeShared: false });
    }

    if (semanticRows.length) {
      const semanticPayloads = compileSemanticRows(source.sourceId, semanticRows);
      for (const [semanticKey, payload] of semanticPayloads) {
        claimKey(keyOwner, semanticKey, source.sourceId);
        semanticKeys.push(semanticKey);
        writeReactionPayload(catalog, `semantic.${semanticKey}.`, payload);
      }
    }

    addStageSelectors(catalog, stageSelectors);

    if (questKeys.length || semanticKeys.length || stageSelectors.length) {
      addSource(catalog, {
        sourceId: source.sourceId,
        displayName: source.displayName,
        pluginName: source.pluginName,
        sentinelForms: normalizeSentinels(source.sentinelForms),
        questKeys: uniqueSorted(questKeys),
        semanticKeys: uniqueSorted(semanticKeys),
        stageAdapterKeys: stageSelectors.map((selector) => selector.key),
      });
    }
  }

  finalizeCatalog(catalog);
  assertPatchDeltaOnly(catalog);
  return catalog;
}

export function resolveCatalogPrecedence({ core, official, extensions = [] }) {
  const resolved = new Map();
  const rejected = [];
  const ordered = [
    { name: "core", catalog: core },
    { name: "official", catalog: official },
    ...[...extensions].sort((a, b) => compareText(a.fileName, b.fileName)).map((entry) => ({
      name: entry.fileName,
      catalog: entry.catalog,
    })),
  ];
  for (const entry of ordered) {
    try {
      validateCatalog(entry.catalog);
      for (const questKey of entry.catalog.stringList.questKeys ?? []) {
        if (!resolved.has(`quest:${questKey}`)) resolved.set(`quest:${questKey}`, entry.name);
      }
      for (const semanticKey of entry.catalog.stringList.semanticKeys ?? []) {
        if (!resolved.has(`semantic:${semanticKey}`)) resolved.set(`semantic:${semanticKey}`, entry.name);
      }
    } catch (error) {
      rejected.push({ source: entry.name, reason: error.message });
    }
  }
  return { resolved, rejected };
}

export function validateCatalog(catalog, { requirePatchDelta = false } = {}) {
  if (!catalog || typeof catalog !== "object") throw new Error("catalog must be an object");
  for (const bucket of BUCKETS) {
    if (!catalog[bucket] || typeof catalog[bucket] !== "object" || Array.isArray(catalog[bucket])) {
      throw new Error(`catalog bucket ${bucket} is missing or invalid`);
    }
  }
  if (catalog.string.schema !== CATALOG_SCHEMA || catalog.int.schemaVersion !== CATALOG_VERSION) {
    throw new Error("catalog schema/version mismatch");
  }
  const sourceIds = catalog.stringList.sourceIds ?? [];
  if (sourceIds.length !== new Set(sourceIds).size) throw new Error("duplicate sourceId in catalog");
  const questKeys = catalog.stringList.questKeys ?? [];
  const semanticKeys = catalog.stringList.semanticKeys ?? [];
  const stageAdapterKeys = catalog.stringList.stageAdapterKeys ?? [];
  if (questKeys.length !== new Set(questKeys).size) throw new Error("duplicate quest key in catalog");
  if (semanticKeys.length !== new Set(semanticKeys).size) throw new Error("duplicate semantic key in catalog");
  if (stageAdapterKeys.length !== new Set(stageAdapterKeys).size) throw new Error("duplicate stage-adapter key in catalog");
  for (const sourceId of sourceIds) {
    const pluginName = catalog.string[`source.${sourceId}.pluginName`];
    if (!pluginName) throw new Error(`source ${sourceId} has no pluginName`);
    const sentinels = catalog.stringList[`source.${sourceId}.sentinelForms`] ?? [];
    if (!sentinels.length) throw new Error(`source ${sourceId} has no sentinelForms`);
    const sourceStageAdapterKeys = catalog.stringList[`source.${sourceId}.stageAdapterKeys`] ?? [];
    if (sourceStageAdapterKeys.length !== new Set(sourceStageAdapterKeys).size) throw new Error(`source ${sourceId} has duplicate stage-adapter keys`);
    for (const key of sourceStageAdapterKeys) if (!stageAdapterKeys.includes(key)) throw new Error(`source ${sourceId} references unknown stage-adapter key ${key}`);
  }
  for (const questKey of questKeys) {
    if (!/^.+\|\d+\|\d+$/.test(questKey)) throw new Error(`unqualified quest key: ${questKey}`);
    validateReactionPayload(catalog, `quest.${questKey}.`);
  }
  for (const semanticKey of semanticKeys) {
    if (!/^[^|]+\|[^|]+$/.test(semanticKey)) throw new Error(`invalid semantic key: ${semanticKey}`);
    validateReactionPayload(catalog, `semantic.${semanticKey}.`);
  }
  for (const stageAdapterKey of stageAdapterKeys) validateStageSelector(catalog, stageAdapterKey);
  if (requirePatchDelta) assertPatchDeltaOnly(catalog);
  return true;
}

export function stableJson(value) {
  return `${JSON.stringify(sortDeep(value), null, 2)}\n`;
}

export function toPapyrusUtilCatalogWire(catalog) {
  validateCatalog(catalog, { requirePatchDelta: catalog?.string?.catalogKind !== "core" });
  const wire = Object.fromEntries(PAPYRUSUTIL_WIRE_BUCKETS.map((bucket) => [bucket, {}]));
  for (const bucket of BUCKETS) {
    for (const [key, value] of Object.entries(catalog[bucket]).sort(([left], [right]) => compareText(left, right))) {
      let wireBucket = bucket;
      if (Array.isArray(value)) {
        if (bucket === "int") wireBucket = "intList";
        else if (bucket !== "stringList") throw new Error(`unsupported PapyrusUtil list value ${bucket}.${key}`);
      } else if (bucket === "stringList") {
        throw new Error(`PapyrusUtil stringList value is not an array: ${key}`);
      }
      const wireKey = key.toLowerCase();
      if (Object.hasOwn(wire[wireBucket], wireKey)) {
        if (JSON.stringify(wire[wireBucket][wireKey]) !== JSON.stringify(value)) {
          throw new Error(`conflicting PapyrusUtil case-fold collision ${wireBucket}.${wireKey}`);
        }
        continue;
      }
      wire[wireBucket][wireKey] = structuredClone(value);
    }
  }
  validatePapyrusUtilCatalogWire(wire, { requirePatchDelta: catalog.string.catalogKind !== "core" });
  return wire;
}

export function validatePapyrusUtilCatalogWire(catalog, { requirePatchDelta = false } = {}) {
  if (!catalog || typeof catalog !== "object" || Array.isArray(catalog)) throw new Error("PapyrusUtil catalog wire must be an object");
  for (const bucket of PAPYRUSUTIL_WIRE_BUCKETS) {
    if (!catalog[bucket] || typeof catalog[bucket] !== "object" || Array.isArray(catalog[bucket])) {
      throw new Error(`PapyrusUtil catalog wire bucket ${bucket} is missing or invalid`);
    }
    for (const key of Object.keys(catalog[bucket])) {
      if (key !== key.toLowerCase()) throw new Error(`PapyrusUtil catalog wire key is not lowercase: ${bucket}.${key}`);
    }
  }
  for (const [key, value] of Object.entries(catalog.string)) if (typeof value !== "string") throw new Error(`PapyrusUtil string value is invalid: ${key}`);
  for (const [key, value] of Object.entries(catalog.float)) if (typeof value !== "number" || !Number.isFinite(value)) throw new Error(`PapyrusUtil float value is invalid: ${key}`);
  for (const [key, value] of Object.entries(catalog.int)) if (!Number.isInteger(value)) throw new Error(`PapyrusUtil int value is invalid: ${key}`);
  for (const [key, value] of Object.entries(catalog.stringList)) {
    if (!Array.isArray(value) || value.some((item) => typeof item !== "string")) throw new Error(`PapyrusUtil stringList value is invalid: ${key}`);
  }
  for (const [key, value] of Object.entries(catalog.intList)) {
    if (!Array.isArray(value) || value.some((item) => !Number.isInteger(item))) throw new Error(`PapyrusUtil intList value is invalid: ${key}`);
  }
  if (catalog.string.schema !== CATALOG_SCHEMA || catalog.int.schemaversion !== CATALOG_VERSION) {
    throw new Error("PapyrusUtil catalog wire schema/version mismatch");
  }
  const sourceIds = catalog.stringList.sourceids ?? [];
  const questKeys = catalog.stringList.questkeys ?? [];
  const semanticKeys = catalog.stringList.semantickeys ?? [];
  const stageAdapterKeys = catalog.stringList.stageadapterkeys ?? [];
  assertWireUnique(sourceIds, "sourceId");
  assertWireUnique(questKeys, "quest key");
  assertWireUnique(semanticKeys, "semantic key");
  assertWireUnique(stageAdapterKeys, "stage-adapter key");
  for (const sourceId of sourceIds) {
    const sourcePrefix = `source.${sourceId}.`.toLowerCase();
    if (!catalog.string[`${sourcePrefix}pluginname`]) throw new Error(`PapyrusUtil catalog source ${sourceId} has no pluginName`);
    const sentinels = catalog.stringList[`${sourcePrefix}sentinelforms`] ?? [];
    if (!sentinels.length) throw new Error(`PapyrusUtil catalog source ${sourceId} has no sentinelForms`);
    const sourceQuestKeys = catalog.stringList[`${sourcePrefix}questkeys`] ?? [];
    const sourceSemanticKeys = catalog.stringList[`${sourcePrefix}semantickeys`] ?? [];
    const sourceStageAdapterKeys = catalog.stringList[`${sourcePrefix}stageadapterkeys`] ?? [];
    assertWireUnique(sentinels, `${sourceId} sentinel`);
    assertWireUnique(sourceQuestKeys, `${sourceId} quest key`);
    assertWireUnique(sourceSemanticKeys, `${sourceId} semantic key`);
    assertWireUnique(sourceStageAdapterKeys, `${sourceId} stage-adapter key`);
    for (const key of sourceQuestKeys) if (!questKeys.some((candidate) => candidate.toLowerCase() === key.toLowerCase())) throw new Error(`PapyrusUtil catalog source ${sourceId} references unknown quest key ${key}`);
    for (const key of sourceSemanticKeys) if (!semanticKeys.some((candidate) => candidate.toLowerCase() === key.toLowerCase())) throw new Error(`PapyrusUtil catalog source ${sourceId} references unknown semantic key ${key}`);
    for (const key of sourceStageAdapterKeys) if (!stageAdapterKeys.some((candidate) => candidate.toLowerCase() === key.toLowerCase())) throw new Error(`PapyrusUtil catalog source ${sourceId} references unknown stage-adapter key ${key}`);
  }
  for (const questKey of questKeys) {
    if (!/^.+\|\d+\|\d+$/.test(questKey)) throw new Error(`PapyrusUtil catalog has unqualified quest key: ${questKey}`);
    validateWireReactionPayload(catalog, `quest.${questKey}.`);
  }
  for (const semanticKey of semanticKeys) {
    if (!/^[^|]+\|[^|]+$/.test(semanticKey)) throw new Error(`PapyrusUtil catalog has invalid semantic key: ${semanticKey}`);
    validateWireReactionPayload(catalog, `semantic.${semanticKey}.`);
  }
  for (const stageAdapterKey of stageAdapterKeys) validateWireStageSelector(catalog, stageAdapterKey);
  if (requirePatchDelta) assertWirePatchDeltaOnly(catalog);
  return true;
}

function assertWireUnique(values, label) {
  const folded = new Set();
  for (const value of values) {
    if (typeof value !== "string" || !value) throw new Error(`PapyrusUtil catalog ${label} is empty or invalid`);
    const key = value.toLowerCase();
    if (folded.has(key)) throw new Error(`PapyrusUtil catalog has duplicate ${label}: ${value}`);
    folded.add(key);
  }
}

function validateWireReactionPayload(catalog, prefix) {
  const wirePrefix = prefix.toLowerCase();
  const names = ["deities", "valences", "intensities", "magnitudes", "tags"];
  const lists = names.map((name) => catalog.stringList[`${wirePrefix}${name}`] ?? []);
  const count = lists[0].length;
  if (!count || lists.some((values) => values.length !== count)) {
    throw new Error(`PapyrusUtil reaction payload arrays are empty or misaligned: ${wirePrefix}${lists.map((values) => values.length).join("/")}`);
  }
  for (let index = 0; index < names.length; index += 1) {
    const csvKey = `${wirePrefix}${names[index]}csv`;
    if (catalog.string[csvKey] !== lists[index].join("|")) {
      throw new Error(`PapyrusUtil reaction payload CSV is missing or misaligned: ${csvKey}`);
    }
  }
}

function validateWireStageSelector(catalog, key) {
  if (!/^.+\|\d+\|\d+$/.test(key)) throw new Error(`PapyrusUtil catalog has invalid stage-selector key: ${key}`);
  const prefix = `stageadapter.${key}.`.toLowerCase();
  const selectorKind = catalog.string[`${prefix}selectorkind`];
  const selectorPlugin = catalog.string[`${prefix}selectorplugin`];
  const selectorFormId = catalog.int[`${prefix}selectorformid`];
  const selectorValues = catalog.intList[`${prefix}selectorvalues`] ?? [];
  const targetStages = catalog.intList[`${prefix}targetstages`] ?? [];
  if (!selectorKind || !selectorPlugin || !Number.isInteger(selectorFormId) || selectorFormId < 0) {
    throw new Error(`PapyrusUtil catalog has invalid stage-selector metadata: ${key}`);
  }
  if (!selectorValues.length || selectorValues.length !== targetStages.length) {
    throw new Error(`PapyrusUtil stage-selector values/stages are empty or misaligned: ${key}`);
  }
  if (targetStages.some((value) => value < 0)) throw new Error(`PapyrusUtil target stages must be non-negative: ${key}`);
}

function assertWirePatchDeltaOnly(catalog) {
  for (const bucket of PAPYRUSUTIL_WIRE_BUCKETS) {
    for (const key of Object.keys(catalog[bucket])) {
      if (/^(stance\.|stancemult\.|value\.|faucet)/i.test(key)) {
        throw new Error(`third-party PapyrusUtil catalog contains core-owned shared policy: ${key}`);
      }
    }
  }
}

export function buildReceipt(artifacts, inputDigest) {
  const files = Object.entries(artifacts)
    .map(([relativePath, text]) => ({
      path: relativePath.replaceAll("\\", "/"),
      bytes: Buffer.byteLength(text, "utf8"),
      sha256: sha256(text),
    }))
    .sort((a, b) => compareText(a.path, b.path));
  const treeSha256 = sha256(files.map((file) => `${file.path}\0${file.bytes}\0${file.sha256}`).join("\n"));
  return {
    schema: "pdv.quest-reaction.build-receipt.v1",
    inputSha256: inputDigest,
    treeSha256,
    files,
  };
}

export function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function buildQuestIndex(flat) {
  const questKeys = flat.questKeys ?? [];
  const plugins = flat.questPlugins ?? [];
  if (questKeys.length !== plugins.length) {
    throw new Error(`quest key/plugin arrays differ: ${questKeys.length} != ${plugins.length}`);
  }
  const result = new Map();
  for (let index = 0; index < questKeys.length; index += 1) {
    const legacyKey = String(questKeys[index]);
    const pluginName = String(plugins[index]);
    if (!/^\d+\|\d+$/.test(legacyKey) || !pluginName) {
      throw new Error(`invalid V1 quest identity at index ${index}: ${pluginName}|${legacyKey}`);
    }
    const qualifiedKey = `${pluginName}|${legacyKey}`;
    const existing = result.get(legacyKey);
    if (existing && existing.pluginName !== pluginName) {
      throw new Error(`V1 compiler collapsed cross-plugin identity ${legacyKey}`);
    }
    result.set(legacyKey, { legacyKey, pluginName, qualifiedKey });
  }
  return result;
}

function copyCompiledValues(target, runtime, questIndex, { includeShared }) {
  for (const bucket of BUCKETS) {
    for (const [key, value] of Object.entries(runtime[bucket] ?? {}).sort(([a], [b]) => compareText(a, b))) {
      if (V1_QUEST_INDEX_KEYS.has(key)) continue;
      if (bucket === "string" && V1_STRING_META_KEYS.has(key)) continue;
      const questMatch = /^quest\.([^.]*)\.(.+)$/.exec(key);
      if (questMatch) {
        const item = questIndex.get(questMatch[1]);
        if (!item) throw new Error(`compiled quest payload has no identity mapping: ${key}`);
        setTyped(target, bucket, `quest.${item.qualifiedKey}.${questMatch[2]}`, value);
      } else if (includeShared) {
        setTyped(target, bucket, key, value);
      }
    }
  }
}

function addSource(catalog, source) {
  if (!source.sourceId || !source.pluginName) throw new Error("sourceId and pluginName are required");
  if (catalog.stringList.sourceIds.includes(source.sourceId)) throw new Error(`duplicate sourceId ${source.sourceId}`);
  catalog.stringList.sourceIds.push(source.sourceId);
  catalog.string[`source.${source.sourceId}.displayName`] = source.displayName;
  catalog.string[`source.${source.sourceId}.pluginName`] = source.pluginName;
  catalog.stringList[`source.${source.sourceId}.sentinelForms`] = uniqueSorted(source.sentinelForms);
  catalog.stringList[`source.${source.sourceId}.questKeys`] = uniqueSorted(source.questKeys);
  catalog.stringList[`source.${source.sourceId}.semanticKeys`] = uniqueSorted(source.semanticKeys);
  catalog.stringList[`source.${source.sourceId}.stageAdapterKeys`] = uniqueSorted(source.stageAdapterKeys ?? []);
  catalog.stringList.questKeys.push(...source.questKeys);
  catalog.stringList.semanticKeys.push(...source.semanticKeys);
}

function addStageSelectors(catalog, selectors) {
  for (const selector of [...selectors].sort((a, b) => compareText(a.key, b.key))) {
    if (catalog.stringList.stageAdapterKeys.includes(selector.key)) {
      throw new Error(`duplicate stage-adapter key ${selector.key}`);
    }
    const prefix = `stageAdapter.${selector.key}.`;
    catalog.stringList.stageAdapterKeys.push(selector.key);
    catalog.string[`${prefix}selectorKind`] = selector.selectorKind;
    catalog.string[`${prefix}selectorPlugin`] = selector.selectorPlugin;
    catalog.int[`${prefix}selectorFormId`] = selector.selectorFormId;
    catalog.int[`${prefix}selectorValues`] = [...selector.selectorValues];
    catalog.int[`${prefix}targetStages`] = [...selector.targetStages];
  }
}

function compileSemanticRows(sourceId, rows) {
  const payloads = new Map();
  const duplicateCells = new Set();
  for (const row of rows) {
    const eventId = row.event_id?.trim();
    if (!eventId) throw new Error(`semantic row for ${sourceId} has no event_id`);
    const semanticKey = `${sourceId}|${eventId}`;
    if (!payloads.has(semanticKey)) payloads.set(semanticKey, emptyPayload());
    const payload = payloads.get(semanticKey);
    const cell = [row.deity, row.valence, row.intensity, row.magnitude, row.act_tags].map((value) => value?.trim() ?? "");
    if (cell.some((value) => !value)) throw new Error(`semantic row ${semanticKey} has an empty reaction field`);
    const duplicateKey = `${semanticKey}\0${cell.join("\0")}`;
    if (duplicateCells.has(duplicateKey)) throw new Error(`duplicate semantic cell ${semanticKey}`);
    duplicateCells.add(duplicateKey);
    payload.deities.push(cell[0]);
    payload.valences.push(cell[1]);
    payload.intensities.push(cell[2]);
    payload.magnitudes.push(cell[3]);
    payload.tags.push(cell[4]);
  }
  return new Map([...payloads.entries()].sort(([a], [b]) => compareText(a, b)));
}

function writeReactionPayload(catalog, prefix, payload) {
  catalog.stringList[`${prefix}deities`] = payload.deities;
  catalog.stringList[`${prefix}valences`] = payload.valences;
  catalog.stringList[`${prefix}intensities`] = payload.intensities;
  catalog.stringList[`${prefix}magnitudes`] = payload.magnitudes;
  catalog.stringList[`${prefix}tags`] = payload.tags;
  catalog.string[`${prefix}deitiesCsv`] = payload.deities.join("|");
  catalog.string[`${prefix}valencesCsv`] = payload.valences.join("|");
  catalog.string[`${prefix}intensitiesCsv`] = payload.intensities.join("|");
  catalog.string[`${prefix}magnitudesCsv`] = payload.magnitudes.join("|");
  catalog.string[`${prefix}tagsCsv`] = payload.tags.join("|");
}

function validateReactionPayload(catalog, prefix) {
  const names = ["deities", "valences", "intensities", "magnitudes", "tags"];
  const lengths = names.map((name) => (catalog.stringList[`${prefix}${name}`] ?? []).length);
  if (!lengths[0] || lengths.some((length) => length !== lengths[0])) {
    throw new Error(`reaction payload arrays are empty or misaligned: ${prefix}${lengths.join("/")}`);
  }
}

function validateStageSelector(catalog, key) {
  if (!/^.+\|\d+\|\d+$/.test(key)) throw new Error(`invalid stage-selector key: ${key}`);
  const prefix = `stageAdapter.${key}.`;
  const selectorKind = catalog.string[`${prefix}selectorKind`];
  const selectorPlugin = catalog.string[`${prefix}selectorPlugin`];
  const selectorFormId = catalog.int[`${prefix}selectorFormId`];
  const selectorValues = catalog.int[`${prefix}selectorValues`] ?? [];
  const targetStages = catalog.int[`${prefix}targetStages`] ?? [];
  if (!selectorKind || !selectorPlugin || !Number.isInteger(selectorFormId) || selectorFormId < 0) {
    throw new Error(`invalid stage-selector metadata: ${key}`);
  }
  if (!selectorValues.length || selectorValues.length !== targetStages.length) {
    throw new Error(`stage-selector values/stages are empty or misaligned: ${key}`);
  }
  if (selectorValues.some((value) => !Number.isInteger(value)) || targetStages.some((value) => !Number.isInteger(value) || value < 0)) {
    throw new Error(`stage-selector values/stages must be integers: ${key}`);
  }
}

function finalizeCatalog(catalog) {
  catalog.stringList.sourceIds = uniqueSorted(catalog.stringList.sourceIds);
  catalog.stringList.questKeys = uniqueSorted(catalog.stringList.questKeys);
  catalog.stringList.semanticKeys = uniqueSorted(catalog.stringList.semanticKeys);
  catalog.stringList.stageAdapterKeys = uniqueSorted(catalog.stringList.stageAdapterKeys ?? []);
  validateCatalog(catalog, { requirePatchDelta: catalog.string.catalogKind !== "core" });
}

function assertPatchDeltaOnly(catalog) {
  for (const bucket of BUCKETS) {
    for (const key of Object.keys(catalog[bucket])) {
      if (/^(stance\.|stancemult\.|value\.|faucet)/i.test(key)) {
        throw new Error(`third-party catalog contains core-owned shared policy: ${key}`);
      }
    }
  }
}

function claimKey(owners, key, sourceId) {
  const current = owners.get(key);
  if (current && current !== sourceId) throw new Error(`official key ${key} is owned by both ${current} and ${sourceId}`);
  owners.set(key, sourceId);
}

function setTyped(catalog, bucket, key, value) {
  if (Object.hasOwn(catalog[bucket], key)) throw new Error(`duplicate generated key ${bucket}.${key}`);
  catalog[bucket][key] = structuredClone(value);
}

function normalizeSentinels(values = []) {
  return uniqueSorted(values.map((value) => {
    const separator = value.lastIndexOf("|");
    if (separator <= 0) throw new Error(`invalid sentinel ${value}`);
    const pluginName = value.slice(0, separator);
    const localText = value.slice(separator + 1);
    const localHex = localText.replace(/^0x/i, "");
    const localFormId = Number.parseInt(localHex, 16);
    if (!pluginName || !/^[0-9a-f]+$/i.test(localHex) || !Number.isInteger(localFormId) || localFormId < 0) {
      throw new Error(`invalid sentinel ${value}`);
    }
    return `${pluginName}|${localFormId}`;
  }));
}

function questKeyToSentinel(qualifiedKey) {
  const parts = qualifiedKey.split("|");
  return `${parts[0]}|${parts[1]}`;
}

function stableId(value) {
  return value
    .normalize("NFKD")
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .toLowerCase();
}

function emptyPayload() {
  return { deities: [], valences: [], intensities: [], magnitudes: [], tags: [] };
}

function uniqueSorted(values) {
  return [...new Set(values)].sort(compareText);
}

function compareText(a, b) {
  return String(a).localeCompare(String(b), "en", { sensitivity: "variant" });
}

function sortDeep(value) {
  if (Array.isArray(value)) return value.map(sortDeep);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(Object.entries(value).sort(([a], [b]) => compareText(a, b)).map(([key, item]) => [key, sortDeep(item)]));
}
