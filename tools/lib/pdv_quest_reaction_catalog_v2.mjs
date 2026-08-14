import crypto from "node:crypto";

export const CATALOG_SCHEMA = "pdv.quest-reaction.catalog.v2";
export const CATALOG_VERSION = 2;

const BUCKETS = ["string", "float", "int", "stringList"];
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
    },
  };
}

export function buildCoreCatalog(compiled) {
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
    });
  }
  finalizeCatalog(catalog);
  return catalog;
}

export function buildOfficialCatalog({ sources, compiledBySource, semanticRowsBySource = new Map() }) {
  const catalog = emptyTypedCatalog("official-third-party");
  const keyOwner = new Map();

  for (const source of [...sources].sort((a, b) => compareText(a.sourceId, b.sourceId))) {
    const compiled = compiledBySource.get(source.sourceId);
    const semanticRows = semanticRowsBySource.get(source.sourceId) ?? [];
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

    if (questKeys.length || semanticKeys.length) {
      addSource(catalog, {
        sourceId: source.sourceId,
        displayName: source.displayName,
        pluginName: source.pluginName,
        sentinelForms: normalizeSentinels(source.sentinelForms),
        questKeys: uniqueSorted(questKeys),
        semanticKeys: uniqueSorted(semanticKeys),
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
  if (questKeys.length !== new Set(questKeys).size) throw new Error("duplicate quest key in catalog");
  if (semanticKeys.length !== new Set(semanticKeys).size) throw new Error("duplicate semantic key in catalog");
  for (const sourceId of sourceIds) {
    const pluginName = catalog.string[`source.${sourceId}.pluginName`];
    if (!pluginName) throw new Error(`source ${sourceId} has no pluginName`);
    const sentinels = catalog.stringList[`source.${sourceId}.sentinelForms`] ?? [];
    if (!sentinels.length) throw new Error(`source ${sourceId} has no sentinelForms`);
  }
  for (const questKey of questKeys) {
    if (!/^.+\|\d+\|\d+$/.test(questKey)) throw new Error(`unqualified quest key: ${questKey}`);
    validateReactionPayload(catalog, `quest.${questKey}.`);
  }
  for (const semanticKey of semanticKeys) {
    if (!/^[^|]+\|[^|]+$/.test(semanticKey)) throw new Error(`invalid semantic key: ${semanticKey}`);
    validateReactionPayload(catalog, `semantic.${semanticKey}.`);
  }
  if (requirePatchDelta) assertPatchDeltaOnly(catalog);
  return true;
}

export function stableJson(value) {
  return `${JSON.stringify(sortDeep(value), null, 2)}\n`;
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
  catalog.stringList.questKeys.push(...source.questKeys);
  catalog.stringList.semanticKeys.push(...source.semanticKeys);
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

function finalizeCatalog(catalog) {
  catalog.stringList.sourceIds = uniqueSorted(catalog.stringList.sourceIds);
  catalog.stringList.questKeys = uniqueSorted(catalog.stringList.questKeys);
  catalog.stringList.semanticKeys = uniqueSorted(catalog.stringList.semanticKeys);
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
