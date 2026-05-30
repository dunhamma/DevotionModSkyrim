export function buildCkCommandPacket(plan, options = {}) {
  const generatedPlugin = options.generatedPlugin || plan.manifest.output;
  const ckOperations = plan.operations.filter((item) => {
    return item.status === "ready" && (
      item.capability.requiresCkSemantics ||
        item.operation.ckSemanticsRequired ||
        item.backend === "ckpe-bridge" ||
        item.backend === "ui-automation"
    );
  });
  const saveCommand = options.saveCommand || "postUiSaveCommand";
  const sourcePlugin = plan.manifest.sourcePlugin || plan.profile.sourcePlugin;
  const requiredPlugins = collectRequiredPlugins(plan, generatedPlugin, sourcePlugin);
  const loadPluginSet = buildLoadPluginSetCommand({
    requiredPlugins,
    sourcePlugin,
    generatedPlugin,
    activePlugin: generatedPlugin,
    intendedSaveTarget: generatedPlugin,
    sourcePluginNotActive: true
  });

  return {
    schema: "creation-authoring.ck-command-packet.v1",
    project: plan.manifest.project,
    game: plan.manifest.game,
    sourcePlugin,
    generatedPlugin,
    backendOrder: ["ckpe-bridge", "ui-automation", "manual-packet"],
    failClosed: true,
    commands: [
      { op: "openProject", profile: plan.profile.modId, game: plan.profile.game },
      loadPluginSet,
      ...ckOperations.flatMap((item) => operationToCommands(item, { generatedPlugin })),
      saveCommand === "savePlugin"
        ? { op: "savePlugin", plugin: generatedPlugin }
        : { op: "postUiSaveCommand", plugin: generatedPlugin },
      { op: "closeSafeStatus" }
    ],
    verifierExpectations: ckOperations.flatMap((item) => {
      return (item.operation.verifierExpectations || []).map((expectation) => ({
        operationId: item.operation.id,
        target: item.operation.target,
        ...expectation
      }));
    })
  };
}

export function buildLoadPluginSetCommand(options = {}) {
  const sourcePlugin = normalizePluginName(options.sourcePlugin);
  const generatedPlugin = normalizePluginName(options.generatedPlugin);
  const activePlugin = normalizePluginName(options.activePlugin || generatedPlugin);
  const intendedSaveTarget = normalizePluginName(options.intendedSaveTarget || activePlugin);

  if (!sourcePlugin) {
    throw new Error("CK-semantic packet generation requires a source plugin for loadPluginSet.");
  }
  if (!activePlugin) {
    throw new Error("CK-semantic packet generation requires a generated or candidate write target for loadPluginSet.");
  }
  if (!intendedSaveTarget) {
    throw new Error("CK-semantic packet generation requires an intended save target for loadPluginSet.");
  }

  const requiredPlugins = uniquePlugins([
    ...(options.requiredPlugins || []),
    sourcePlugin,
    generatedPlugin,
    activePlugin,
    intendedSaveTarget
  ]);

  if (!requiredPlugins.length) {
    throw new Error("CK-semantic packet generation requires a non-empty required plugin set for loadPluginSet.");
  }

  return {
    op: "loadPluginSet",
    requiredPlugins,
    plugins: requiredPlugins.map((plugin) => ({
      name: plugin,
      selected: true,
      active: plugin === activePlugin
    })),
    sourcePlugin,
    generatedPlugin: generatedPlugin || activePlugin,
    activePlugin,
    intendedSaveTarget,
    sourcePluginNotActive: options.sourcePluginNotActive !== false
  };
}

function collectRequiredPlugins(plan, generatedPlugin, sourcePlugin) {
  return uniquePlugins([
    sourcePlugin,
    generatedPlugin,
    ...plan.operations.flatMap((item) => item.operation.mastersExpected || []),
    ...plan.operations.flatMap((item) => item.operation.payload?.requiredPlugins || [])
  ]);
}

function uniquePlugins(plugins = []) {
  return [...new Set(plugins.map((plugin) => normalizePluginName(plugin)).filter(Boolean))];
}

function normalizePluginName(plugin) {
  return typeof plugin === "string" ? plugin.trim() : "";
}

function operationToCommands(item, context = {}) {
  const operation = item.operation;
  const payload = operation.payload || {};

  if (operation.kind === "record.create" || operation.kind === "quest.create") {
    return [
      {
        op: "createRecord",
        operationId: operation.id,
        plugin: context.generatedPlugin,
        target: operation.target,
        recordFamily: recordFamilyForCommand(operation, payload),
        payload
      }
    ];
  }

  if (operation.kind === "glob.duplicate_create") {
    return [
      {
        op: "duplicateCreateGlob",
        operationId: operation.id,
        plugin: context.generatedPlugin,
        sourceEditorId: payload.sourceEditorId,
        target: operation.target,
        targetEditorId: payload.targetEditorId || payload.createdEditorId || operation.target,
        recordFamily: "GLOB",
        mode: payload.replayMode || payload.dispatchMode || "input_context_focus_async_command",
        valueType: payload.valueType || payload.type || payload.globalType,
        value: payload.value ?? payload.globalValue,
        payload
      }
    ];
  }

  if (operation.kind === "record.duplicate_create") {
    return [
      {
        op: "duplicateCreateRecord",
        operationId: operation.id,
        plugin: context.generatedPlugin,
        sourceEditorId: payload.sourceEditorId,
        target: operation.target,
        targetEditorId: payload.targetEditorId || payload.createdEditorId || operation.target,
        createdEditorId: payload.createdEditorId || payload.targetEditorId || operation.target,
        recordFamily: recordFamilyForCommand(operation, payload),
        mode: payload.replayMode || payload.dispatchMode || "input_context_focus_async_command",
        payload
      }
    ];
  }

  if (operation.kind === "record.update") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "updateRecord",
        operationId: operation.id,
        plugin: context.generatedPlugin,
        target: operation.target,
        recordFamily: recordFamilyForCommand(operation, payload),
        payload
      }
    ];
  }

  if (operation.kind === "vmad.attach_script") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "attachScript",
        operationId: operation.id,
        target: operation.target,
        script: payload.script,
        properties: payload.properties || []
      },
      ...(payload.properties || []).map((property) => ({
        op: "setProperty",
        operationId: operation.id,
        target: operation.target,
        script: payload.script,
        property
      }))
    ];
  }

  if (operation.kind === "vmad.set_property") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "setProperty",
        operationId: operation.id,
        target: operation.target,
        script: payload.script,
        property: {
          name: payload.property,
          type: payload.type,
          value: payload.value
        }
      }
    ];
  }

  if (operation.kind === "vmad.array_property" || operation.kind === "vmad.set_array_property") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "setArrayProperty",
        operationId: operation.id,
        target: operation.target,
        script: payload.script,
        property: payload.property,
        type: payload.type,
        values: payload.values || []
      }
    ];
  }

  if (operation.kind === "formlist.add") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "addFormListEntry",
        operationId: operation.id,
        target: operation.target,
        entry: payload.entry
      }
    ];
  }

  if (operation.kind === "quest.alias.add") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "addAlias",
        operationId: operation.id,
        target: operation.target,
        payload
      }
    ];
  }

  if (operation.kind === "quest.stage.fragment") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "questFragmentModEvent",
        operationId: operation.id,
        target: operation.target,
        payload
      }
    ];
  }

  if (operation.kind === "story_manager.node") {
    return [
      { op: "findRecord", editorId: payload.receiverQuest || operation.target },
      {
        op: "addStoryManagerNode",
        operationId: operation.id,
        target: operation.target,
        event: payload.event,
        receiverQuest: payload.receiverQuest,
        sharesEvent: payload.sharesEvent === true
      }
    ];
  }

  if (operation.kind === "story_manager.node.create") {
    return [
      { op: "findRecord", editorId: payload.receiverQuest || operation.target },
      {
        op: "addStoryManagerNode",
        operationId: operation.id,
        target: operation.target,
        event: payload.event,
        receiverQuest: payload.receiverQuest,
        sharesEvent: payload.sharesEvent === true,
        conditions: payload.conditions || []
      }
    ];
  }

  if (operation.kind === "quest.fragment") {
    return [
      { op: "findRecord", editorId: operation.target },
      {
        op: "setQuestFragment",
        operationId: operation.id,
        target: operation.target,
        stage: payload.stage,
        fragmentName: payload.fragmentName
      }
    ];
  }

  if (operation.kind === "dialogue.scene") {
    return [
      {
        op: "createDialogueScene",
        operationId: operation.id,
        target: operation.target,
        payload
      }
    ];
  }

  if (operation.kind === "dialogue.branch.create") {
    return [{ op: "createDialogueBranch", operationId: operation.id, target: operation.target, payload }];
  }

  if (operation.kind === "dialogue.topic.create") {
    return [{ op: "createDialogueTopic", operationId: operation.id, target: operation.target, payload }];
  }

  if (operation.kind === "dialogue.info.create") {
    return [{ op: "createDialogueInfo", operationId: operation.id, target: operation.target, payload }];
  }

  if (operation.kind === "scene.create") {
    return [{ op: "createScene", operationId: operation.id, target: operation.target, payload }];
  }

  if (operation.kind === "reference.place") {
    return [{
      op: "placeReference",
      operationId: operation.id,
      target: operation.target,
      payload
    }];
  }

  if (operation.kind === "seq.generate" || operation.kind === "artifact.seq.generate") {
    return [{ op: "generateSeq", operationId: operation.id, plugin: payload.plugin }];
  }

  if (operation.kind === "lip.generate" || operation.kind === "artifact.lip.generate") {
    return [{ op: "generateLip", operationId: operation.id, payload }];
  }

  if (operation.kind === "facegen.export" || operation.kind === "artifact.facegen.generate") {
    return [{ op: "exportFaceGen", operationId: operation.id, target: operation.target }];
  }

  return [{
    op: "manualUnsupported",
    operationId: operation.id,
    kind: operation.kind,
    target: operation.target,
    payload
  }];
}

function recordFamilyForCommand(operation, payload = {}) {
  if (operation.recordFamily && operation.recordFamily !== "record") {
    return operation.recordFamily;
  }
  return payload.recordType || operation.recordFamily;
}
