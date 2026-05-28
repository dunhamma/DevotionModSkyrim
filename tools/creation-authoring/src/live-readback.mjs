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
      recordType: normalizeRecordType(source.record_type || detail.record_type),
      plugin: source.plugin || detail.plugin || null,
      winningPlugin: source.winning_plugin || source.winningPlugin || detail.winning_plugin || source.plugin || detail.plugin || null,
      scripts: normalizeVmadScripts(fields.VirtualMachineAdapter?.Scripts || []),
      entries: normalizeFormListEntries(fields.Items || fields.Entries || fields.FormListEntries || []),
      aliases: normalizeAliases(fields.Aliases || fields.QuestAliases || []),
      stages: normalizeStages(fields.Stages || fields.QuestStages || []),
      keywords: normalizeFormListEntries(fields.Keywords || []),
      spells: normalizeFormListEntries(fields.Spells || fields.ActorEffects || []),
      perks: normalizeFormListEntries(fields.Perks || []),
      packages: normalizeFormListEntries(fields.Packages || fields.AIPackages || []),
      inventory: normalizeInventory(fields.Items || fields.Inventory || []),
      conditions: normalizeConditions(fields.Conditions || fields.DialogConditions || fields.EventConditions || []),
      dialogue: normalizeDialogue(fields),
      storyManager: normalizeStoryManager(fields.StoryManager || fields.StoryManagerNode || fields.StoryEvent || {}),
      message: normalizeMessage(fields),
      artifacts: normalizeArtifacts(fields.Artifacts || fields.GeneratedArtifacts || []),
      conflictChain: source.conflictChain || source.conflicts || detail.conflictChain || null,
      partialOverlay: source.partialOverlay ?? fields.PartialOverlay ?? null,
      overlayComplete: source.overlayComplete ?? fields.OverlayComplete ?? null,
      missingFields: source.missingFields || fields.MissingFields || [],
      fields
    };
  }

  return { records };
}

function normalizeRecordType(recordType) {
  if (recordType === "MESSAGE") {
    return "MESG";
  }
  return recordType;
}

function normalizeStages(stages) {
  if (!Array.isArray(stages)) {
    return [];
  }
  return stages.map((stage) => ({
    index: stage.Index ?? stage.index ?? stage.Stage ?? stage.stage ?? stage.ID ?? stage.id ?? null,
    logEntry: stage.LogEntry || stage.logEntry || null,
    fragments: Array.isArray(stage.Fragments || stage.fragments) ? (stage.Fragments || stage.fragments) : [],
    raw: stage
  }));
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
      result[name] = normalizePropertyValue(property);
    }
    return result;
  }
  return { ...properties };
}

function normalizePropertyValue(property) {
  if (Array.isArray(property.Array)) return property.Array.map(normalizePropertyEntry);
  if (Array.isArray(property.Values)) return property.Values.map(normalizePropertyEntry);
  if (Array.isArray(property.value)) return property.value.map(normalizePropertyEntry);
  return property.Object ?? property.Value ?? property.value ?? property.String ?? property.Int ?? property.Float ?? property.Bool;
}

function normalizePropertyEntry(entry) {
  if (!entry || typeof entry !== "object") return entry;
  return entry.Object ?? entry.Value ?? entry.value ?? entry.FormID ?? entry.formid ?? entry.EditorID ?? entry.editorId ?? entry;
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
    subject: condition.Subject || condition.subject || condition.RunOn || condition.runOn || null,
    global: condition.Global || condition.global || condition.Parameter || condition.parameter || null,
    runOn: condition.RunOn || condition.run_on || condition.runOn || null,
    raw: condition
  }));
}

function normalizeDialogue(fields = {}) {
  return {
    ownerQuest: firstDefined(fields.OwnerQuest, fields.Quest, fields.OwnerQuestEditorID, fields.QuestEditorID),
    branch: firstDefined(fields.Branch, fields.DialogBranch, fields.BranchEditorID),
    startingTopic: firstDefined(fields.StartingTopic, fields.StartingTopicEditorID),
    topic: firstDefined(fields.Topic, fields.TopicEditorID, fields.ParentTopic),
    prompt: firstDefined(fields.Prompt, fields.Name, fields.FullName),
    category: firstDefined(fields.Category),
    subtype: firstDefined(fields.Subtype),
    flags: normalizeTextArray(fields.Flags),
    speaker: firstDefined(fields.Speaker, fields.SpeakerEditorID),
    speakerForm: firstDefined(fields.SpeakerForm, fields.SpeakerFormID),
    responseLine: firstDefined(fields.ResponseLine, fields.ResponseText, fields.DialogueText, fields.Text),
    conditions: normalizeConditions(fields.Conditions || fields.DialogConditions || [])
  };
}

function firstDefined(...values) {
  return values.find((value) => value !== undefined && value !== null && value !== "");
}

function normalizeTextArray(value) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item));
  }
  if (typeof value === "string") {
    return value.split(/[,\|]/u).map((item) => item.trim()).filter(Boolean);
  }
  return [];
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

function normalizeMessage(fields) {
  return {
    title: fields.Title || fields.Name || fields.FullName || null,
    text: fields.Description || fields.MessageText || fields.Text || null,
    buttons: normalizeButtons(fields.Buttons || fields.MenuButtons || [])
  };
}

function normalizeButtons(buttons) {
  if (!Array.isArray(buttons)) {
    return [];
  }
  return buttons.map((button) => {
    if (typeof button === "string") {
      return { text: button };
    }
    return {
      text: button.Text || button.text || button.Label || null,
      index: button.Index ?? button.index ?? null
    };
  });
}

function normalizeArtifacts(artifacts) {
  if (!Array.isArray(artifacts)) {
    return [];
  }
  return artifacts.map((artifact) => {
    if (typeof artifact === "string") {
      return { path: artifact, exists: true };
    }
    return {
      kind: artifact.Kind || artifact.kind || null,
      path: artifact.Path || artifact.path || null,
      exists: artifact.Exists ?? artifact.exists ?? null,
      fresh: artifact.Fresh ?? artifact.fresh ?? null
    };
  });
}
