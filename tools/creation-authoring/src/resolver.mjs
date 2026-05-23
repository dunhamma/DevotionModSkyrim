export function createResolver(profile) {
  const fixtureRecords = new Map();

  for (const connector of profile.resourceConnectors) {
    if (connector.type !== "fixture") {
      continue;
    }
    const records = connector.records || {};
    for (const [key, record] of Object.entries(records)) {
      const normalized = normalizeRecord(key, record);
      fixtureRecords.set(key.toLowerCase(), normalized);
      if (normalized.editorId) {
        fixtureRecords.set(normalized.editorId.toLowerCase(), normalized);
      }
      if (normalized.formid) {
        fixtureRecords.set(normalized.formid.toLowerCase(), normalized);
      }
    }
  }

  return {
    resolveRecord(identifier) {
      if (typeof identifier !== "string" || !identifier.trim()) {
        return unresolved(identifier);
      }
      const resolved = fixtureRecords.get(identifier.toLowerCase());
      if (resolved) {
        return { ...resolved, resolved: true };
      }
      if (looksLikeFormId(identifier)) {
        return {
          identifier,
          formid: identifier,
          editorId: null,
          recordType: null,
          plugin: null,
          winningPlugin: null,
          resolved: true,
          inferred: true
        };
      }
      return unresolved(identifier);
    },
    resolveValue(value) {
      if (typeof value !== "string") {
        return { value, resolvedValue: value, resolved: true };
      }
      const record = this.resolveRecord(value);
      if (record.resolved) {
        return {
          value,
          resolvedValue: record.formid || record.editorId || value,
          record,
          resolved: true
        };
      }
      return { value, resolvedValue: value, resolved: false, record };
    }
  };
}

function normalizeRecord(key, record) {
  const editorId = record.editorId || record.EditorID || key;
  return {
    identifier: key,
    editorId,
    formid: record.formid || record.formID || record.FormID || null,
    recordType: record.recordType || record.type || null,
    plugin: record.plugin || null,
    winningPlugin: record.winningPlugin || record.plugin || null,
    conflictChain: record.conflictChain || null,
    scripts: normalizeScripts(record.scripts || record.Scripts || []),
    entries: normalizeList(record.entries || record.formListEntries || []),
    keywords: normalizeList(record.keywords || []),
    spells: normalizeList(record.spells || []),
    perks: normalizeList(record.perks || []),
    packages: normalizeList(record.packages || []),
    inventory: normalizeList(record.inventory || [])
  };
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

function normalizeList(value) {
  return Array.isArray(value) ? value : [];
}

function unresolved(identifier) {
  return {
    identifier,
    formid: null,
    editorId: typeof identifier === "string" ? identifier : null,
    recordType: null,
    plugin: null,
    winningPlugin: null,
    resolved: false
  };
}

function looksLikeFormId(identifier) {
  return /^[^:]+:[0-9a-fA-F]{1,8}$/.test(identifier);
}
