export function buildCkCommandPacket(plan, options = {}) {
  const ckOperations = plan.operations.filter((item) => {
    return item.capability.requiresCkSemantics ||
      item.operation.ckSemanticsRequired ||
      item.backend === "ckpe-bridge" ||
      item.backend === "ui-automation";
  });

  return {
    schema: "creation-authoring.ck-command-packet.v1",
    project: plan.manifest.project,
    game: plan.manifest.game,
    sourcePlugin: plan.manifest.sourcePlugin,
    generatedPlugin: options.generatedPlugin || plan.manifest.output,
    backendOrder: ["ckpe-bridge", "ui-automation", "manual-packet"],
    failClosed: true,
    commands: [
      { op: "openProject", profile: plan.profile.modId, game: plan.profile.game },
      { op: "loadPlugin", plugin: options.generatedPlugin || plan.manifest.output, active: true },
      ...ckOperations.flatMap((item) => operationToCommands(item)),
      { op: "savePlugin", plugin: options.generatedPlugin || plan.manifest.output }
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

function operationToCommands(item) {
  const operation = item.operation;
  const payload = operation.payload || {};

  if (operation.kind === "record.create" || operation.kind === "quest.create") {
    return [
      {
        op: "createRecord",
        operationId: operation.id,
        target: operation.target,
        recordFamily: operation.recordFamily || payload.recordType,
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
        target: operation.target,
        recordFamily: operation.recordFamily || payload.recordType,
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
