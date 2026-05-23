export function normalizeMo2RecordDetail(detail) {
  if (!detail || typeof detail !== "object") {
    return { records: {} };
  }

  const sourceRecords = Array.isArray(detail.records) ? detail.records : [detail];
  const records = {};

  for (const source of sourceRecords) {
    if (!source || source.success === false) {
      continue;
    }
    const fields = source.fields || {};
    const editorId = source.editor_id || source.editorId || fields.EditorID || detail.editor_id || detail.editorId;
    const formid = source.formid || detail.formid;
    const key = editorId || formid;
    if (!key) {
      continue;
    }

    records[key] = {
      editorId,
      formid,
      recordType: source.record_type || detail.record_type,
      plugin: source.plugin || detail.plugin || null,
      winningPlugin: source.winning_plugin || source.winningPlugin || detail.winning_plugin || null,
      scripts: normalizeVmadScripts(fields.VirtualMachineAdapter?.Scripts || []),
      entries: normalizeFormListEntries(fields.Items || fields.Entries || fields.FormListEntries || []),
      aliases: normalizeAliases(fields.Aliases || fields.QuestAliases || []),
      keywords: normalizeFormListEntries(fields.Keywords || []),
      spells: normalizeFormListEntries(fields.Spells || fields.ActorEffects || []),
      perks: normalizeFormListEntries(fields.Perks || []),
      packages: normalizeFormListEntries(fields.Packages || fields.AIPackages || []),
      inventory: normalizeInventory(fields.Items || fields.Inventory || []),
      conditions: normalizeConditions(fields.Conditions || fields.DialogConditions || fields.EventConditions || []),
      storyManager: normalizeStoryManager(fields.StoryManager || fields.StoryManagerNode || fields.StoryEvent || {}),
      fields
    };
  }

  return { records };
}

function normalizeVmadScripts(scripts) {
  if (!Array.isArray(scripts)) {
    return [];
  }
  return scripts.map((script) => ({
    name: script.Name || script.name,
    properties: normalizeVmadProperties(script.Properties || script.properties || [])
  }));
}

function normalizeVmadProperties(properties) {
  const result = {};
  if (Array.isArray(properties)) {
    for (const property of properties) {
      const name = property.Name || property.name;
      if (!name) {
        continue;
      }
      result[name] = property.Object ?? property.Value ?? property.value ?? property.String ?? property.Int ?? property.Float ?? property.Bool;
    }
    return result;
  }
  return { ...properties };
}

function normalizeFormListEntries(entries) {
  if (!Array.isArray(entries)) {
    return [];
  }
  return entries.map((entry) => {
    if (typeof entry === "string") {
      return entry;
    }
    return entry.Form || entry.Item || entry.Reference || entry.formid || entry.EditorID || entry.editorId || entry;
  });
}

function normalizeAliases(aliases) {
  if (!Array.isArray(aliases)) {
    return [];
  }
  return aliases.map((alias) => ({
    name: alias.Name || alias.name || alias.AliasName || null,
    id: alias.ID ?? alias.id ?? alias.AliasId ?? null,
    fillType: alias.FillType || alias.fillType || null,
    conditions: normalizeConditions(alias.Conditions || alias.conditions || [])
  }));
}

function normalizeInventory(items) {
  if (!Array.isArray(items)) {
    return [];
  }
  return items.map((item) => ({
    item: item.Item || item.Form || item.Reference || item.formid || item.EditorID || item.editorId || item,
    count: item.Count ?? item.count ?? 1
  }));
}

function normalizeConditions(conditions) {
  if (!Array.isArray(conditions)) {
    return [];
  }
  return conditions.map((condition) => ({
    function: condition.Function || condition.function || condition.Data?.Function || null,
    operator: condition.Operator || condition.operator || null,
    value: condition.Value ?? condition.value ?? condition.ComparisonValue ?? null,
    runOn: condition.RunOn || condition.run_on || condition.runOn || null,
    raw: condition
  }));
}

function normalizeStoryManager(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }
  return {
    event: value.Event || value.event || null,
    sharesEvent: value.SharesEvent ?? value.sharesEvent ?? null,
    raw: value
  };
}
