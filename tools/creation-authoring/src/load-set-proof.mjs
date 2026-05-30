const LEGACY_LOAD_STATE_OPS = new Set(["loadPlugin", "setActivePlugin"]);
export const LOAD_PLUGIN_SET_RELEASE_BLOCKERS = [
  "missing_source_plugin",
  "missing_generated_or_candidate_plugin",
  "generated_or_candidate_plugin_not_active",
  "source_plugin_active",
  "intended_save_target_mismatch",
  "active_target_not_normal_writable_esp"
];

export const LOAD_PLUGIN_SET_DIAGNOSTIC_BLOCKERS = [
  "data_handler_unavailable",
  "source_plugin_not_declared",
  "source_plugin_not_selected",
  "generated_or_candidate_plugin_not_declared",
  "generated_or_candidate_plugin_not_selected",
  "active_plugin_not_declared",
  "active_plugin_mismatch",
  "generated_or_candidate_plugin_differs_from_requested_active_plugin",
  "required_plugin_missing",
  "required_plugin_not_selected"
];

export function findLoadPluginSetCommand(commands = []) {
  return commands.find((command) => command?.op === "loadPluginSet") || null;
}

export function hasLegacyLoadStateCommands(commands = []) {
  return commands.some((command) => LEGACY_LOAD_STATE_OPS.has(command?.op));
}

export function validateShipPathLoadSet(commands = [], options = {}) {
  const failures = [];
  const loadPluginSetCommands = commands.filter((command) => command?.op === "loadPluginSet");
  const loadPluginSet = loadPluginSetCommands[0] || null;

  if (!loadPluginSet) {
    failures.push("Ship-path CK evidence is missing loadPluginSet.");
    return {
      status: "FAIL",
      failures,
      command: null
    };
  }

  if (loadPluginSetCommands.length !== 1) {
    failures.push(`Ship-path CK evidence must declare exactly one loadPluginSet; found ${loadPluginSetCommands.length}.`);
  }

  if (options.requireOpenProjectPrelude) {
    if (commands[0]?.op !== "openProject") {
      failures.push("Ship-path CK evidence must begin with openProject before loadPluginSet.");
    }
    if (commands[1]?.op !== "loadPluginSet") {
      failures.push("Ship-path CK evidence must place loadPluginSet immediately after openProject.");
    }
  }

  if (!options.allowLegacyCommands && hasLegacyLoadStateCommands(commands)) {
    failures.push("Ship-path CK evidence still includes transitional loadPlugin/setActivePlugin commands.");
  }

  if (loadPluginSet.status && loadPluginSet.status !== "PASS") {
    failures.push(`loadPluginSet status is ${loadPluginSet.status}.`);
  }

  const evidence = loadPluginSet.evidence || {};
  const requestedActivePlugin = evidence.requestedActivePlugin || loadPluginSet.activePlugin || null;
  const intendedSaveTarget = evidence.intendedSaveTarget || loadPluginSet.intendedSaveTarget || null;
  const expectedActivePlugin = options.expectedActivePlugin || null;
  const expectedSaveTarget = options.expectedSaveTarget || expectedActivePlugin || null;
  const requireSourcePluginNotActive = options.requireSourcePluginNotActive !== false;

  if (!requestedActivePlugin) {
    failures.push("loadPluginSet does not declare the requested active plugin.");
  }
  if (!intendedSaveTarget) {
    failures.push("loadPluginSet does not declare the intended save target.");
  }
  if (expectedActivePlugin && !samePathOrName(requestedActivePlugin, expectedActivePlugin)) {
    failures.push(`loadPluginSet active plugin is ${requestedActivePlugin}, expected ${expectedActivePlugin}.`);
  }
  if (expectedSaveTarget && !samePathOrName(intendedSaveTarget, expectedSaveTarget)) {
    failures.push(`loadPluginSet intended save target is ${intendedSaveTarget}, expected ${expectedSaveTarget}.`);
  }

  if (hasVerificationEvidence(evidence)) {
    if (evidence.activePluginMatchesRequest !== true) {
      failures.push("loadPluginSet evidence does not prove activePluginMatchesRequest.");
    }
    if (evidence.saveTargetMatchesActive !== true) {
      failures.push("loadPluginSet evidence does not prove saveTargetMatchesActive.");
    }
    if (requireSourcePluginNotActive && evidence.sourcePluginActive === true) {
      failures.push("loadPluginSet evidence shows the source plugin active during generated-first proof.");
    }
  } else if (requireSourcePluginNotActive && loadPluginSet.sourcePluginNotActive !== true) {
    failures.push("loadPluginSet does not require the source plugin to remain inactive.");
  }

  return {
    status: failures.length ? "FAIL" : "PASS",
    failures,
    command: loadPluginSet
  };
}

function hasVerificationEvidence(evidence) {
  return Object.prototype.hasOwnProperty.call(evidence, "activePluginMatchesRequest") ||
    Object.prototype.hasOwnProperty.call(evidence, "saveTargetMatchesActive") ||
    Object.prototype.hasOwnProperty.call(evidence, "sourcePluginActive");
}

function samePathOrName(left, right) {
  if (!left || !right) {
    return false;
  }
  const normalizedLeft = String(left).replaceAll("\\", "/").toLowerCase();
  const normalizedRight = String(right).replaceAll("\\", "/").toLowerCase();
  return normalizedLeft === normalizedRight ||
    normalizedLeft.split("/").at(-1) === normalizedRight.split("/").at(-1);
}
