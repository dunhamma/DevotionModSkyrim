export function buildPatchRequest(plan, options = {}) {
  const records = new Map();
  const operationFilter = options.operationFilter || (() => true);

  for (const item of plan.operations) {
    if (item.status !== "ready") {
      continue;
    }
    if (!operationFilter(item)) {
      continue;
    }
    if (!["mutagen-patch-request", "mo2-mcp-patch-request", "xedit-script-request"].includes(item.backend)) {
      continue;
    }
    addOperationToPatch(records, item);
  }

  return {
    output_name: options.output || plan.manifest.output || `${plan.manifest.project}_AutoWire.esp`,
    author: options.author || "Creation Authoring Automation",
    esl_flag: options.eslFlag ?? true,
    records: [...records.values()]
  };
}

function addOperationToPatch(records, item) {
  const operation = item.operation;
  const targetFormId = item.targetResolution.formid || operation.target;
  const spec = getRecordSpec(records, targetFormId);

  if (operation.kind === "vmad.attach_script") {
    const script = {
      name: operation.payload.script,
      properties: (operation.payload.properties || []).map((property) => ({
        name: property.name,
        type: property.type || inferPropertyType(property.value),
        value: property.resolvedValue || property.value
      }))
    };
    spec.attach_scripts = spec.attach_scripts || [];
    spec.attach_scripts.push(script);
  }

  if (operation.kind === "formlist.add") {
    spec.add_form_list_entries = spec.add_form_list_entries || [];
    spec.add_form_list_entries.push(operation.payload.resolvedEntry || operation.payload.entry);
  }

  if (operation.kind === "keyword.add") {
    spec.add_keywords = spec.add_keywords || [];
    spec.add_keywords.push(...normalizeArrayPayload(operation.payload, "keywords", "keyword"));
  }

  if (operation.kind === "spell.add") {
    spec.add_spells = spec.add_spells || [];
    spec.add_spells.push(...normalizeArrayPayload(operation.payload, "spells", "spell"));
  }

  if (operation.kind === "perk.add") {
    spec.add_perks = spec.add_perks || [];
    spec.add_perks.push(...normalizeArrayPayload(operation.payload, "perks", "perk"));
  }

  if (operation.kind === "package.add") {
    spec.add_packages = spec.add_packages || [];
    spec.add_packages.push(...normalizeArrayPayload(operation.payload, "packages", "package"));
  }

  if (operation.kind === "inventory.add") {
    spec.add_inventory = spec.add_inventory || [];
    spec.add_inventory.push(...(operation.payload.items || operation.payload.inventory || []));
  }

  if (operation.kind === "condition.add") {
    spec.add_conditions = spec.add_conditions || [];
    spec.add_conditions.push(...(operation.payload.conditions || []));
  }

  if (operation.kind === "message.payload.set") {
    spec.set_message_payload = {
      ...(operation.payload.title !== undefined ? { title: operation.payload.title } : {}),
      ...(operation.payload.text !== undefined ? { text: operation.payload.text } : {}),
      ...(operation.payload.buttons !== undefined ? { buttons: operation.payload.buttons } : {})
    };
  }

  if (operation.kind === "activator.payload.set") {
    spec.set_activator_payload = {
      ...(operation.payload.fullName !== undefined ? { fullName: operation.payload.fullName } : {}),
      ...(operation.payload.name !== undefined ? { fullName: operation.payload.name } : {}),
      ...(operation.payload.model !== undefined ? { model: operation.payload.model } : {})
    };
  }
}

function getRecordSpec(records, formid) {
  if (!records.has(formid)) {
    records.set(formid, {
      op: "override",
      formid
    });
  }
  return records.get(formid);
}

function inferPropertyType(value) {
  if (typeof value === "number" && Number.isInteger(value)) {
    return "Int";
  }
  if (typeof value === "number") {
    return "Float";
  }
  if (typeof value === "boolean") {
    return "Bool";
  }
  return "Object";
}

function normalizeArrayPayload(payload, pluralKey, singularKey) {
  const raw = payload[pluralKey] || payload[singularKey] || [];
  return Array.isArray(raw) ? raw : [raw];
}
