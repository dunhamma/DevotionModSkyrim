export function buildManualPacket(operation, capability, targetResolution, reason) {
  const payload = operation.payload || {};
  const steps = [];

  if (operation.kind === "vmad.attach_script") {
    steps.push(`Open the record ${operation.target}.`);
    steps.push(`Attach or select script ${payload.script}.`);
    for (const property of payload.properties || []) {
      steps.push(`Set property ${property.name} to ${property.value}.`);
    }
    steps.push("Save the plugin and run the verifier/readback command.");
  } else if (operation.kind === "formlist.add") {
    steps.push(`Open FormList ${operation.target}.`);
    steps.push(`Add entry ${payload.entry}.`);
    steps.push("Save the plugin and run the verifier/readback command.");
  } else if (operation.kind === "story_manager.node") {
    steps.push("Open Creation Kit through the project mod manager profile.");
    steps.push(`Navigate to the Story Manager branch for ${payload.event || operation.target}.`);
    steps.push(`Create or update node ${operation.target}.`);
    if (payload.receiverQuest) {
      steps.push(`Point the node at receiver quest ${payload.receiverQuest}.`);
    }
    if (payload.sharesEvent !== undefined) {
      steps.push(`Set Shares Event to ${payload.sharesEvent ? "checked" : "unchecked"}.`);
    }
    steps.push("Save the plugin and capture readback evidence.");
  } else {
    steps.push(`Perform ${operation.kind} on ${operation.target} with the manifest payload.`);
    steps.push("Save the plugin and run the verifier/readback command.");
  }

  return {
    operationId: operation.id,
    kind: operation.kind,
    target: operation.target,
    reason,
    developmentOnly: true,
    shippable: false,
    productRule: "Manual packets are diagnostics for unfinished automation. A shipped CK authoring path must use CKPE execution plus live readback verification.",
    capability: capability.kind,
    requiresCkSemantics: Boolean(capability.requiresCkSemantics || operation.ckSemanticsRequired),
    targetResolution,
    steps,
    verifier: capability.verifier
  };
}
