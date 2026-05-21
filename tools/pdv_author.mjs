#!/usr/bin/env node
/*
 * Safe overlay-patch authoring helper for the PlayerDevotion Anvil/MO2 setup.
 *
 * This tool does not mutate PlayerDevotion_Framework.esp in place. Instead,
 * it inspects the live framework ESP through the bundled Mutagen bridge and,
 * when asked to apply, emits a new patch plugin into the Devotion mod folder.
 *
 * Current scope:
 * - inspect built-in Phase 4 / Phase 6 manifests and tracked JSON manifests
 * - attach additional scripts to existing records
 * - wire scalar and object VMAD properties on existing records
 * - add existing records to existing FormLists
 *
 * Explicit non-goals for v1:
 * - creating new records / minting new FormIDs
 * - editing VMAD array properties such as RivalDeities / RivalMultipliers
 * - Story Manager node creation
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const STOCK_GAME = path.join(ANVIL_ROOT, "Stock Game");
const STOCK_GAME_DATA = path.join(STOCK_GAME, "Data");
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const DEVOTION_PROFILE = path.join(ANVIL_ROOT, "profiles", "Devotion Dev");
const PDV_ESP = path.join(DEVOTION_MOD, "PlayerDevotion_Framework.esp");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);

const OBJECT_VALUE_TYPES = new Set(["Object", "Alias"]);
const SCALAR_VALUE_TYPES = new Set(["Int", "Float", "Bool", "String"]);
const ARRAY_VALUE_TYPES = new Set(["IntArray", "FloatArray", "StringArray", "ObjectArray"]);
const SUPPORTED_PROPERTY_TYPES = new Set([...OBJECT_VALUE_TYPES, ...SCALAR_VALUE_TYPES, ...ARRAY_VALUE_TYPES]);
const BRIDGE_MAX_BUFFER = 64 * 1024 * 1024;
const MANIFEST_INDEX = {
  "mcm-property-wiring": path.join(PROJECT_ROOT, "references", "authoring", "PDV_MCMPropertyWiring.manifest.json"),
  "preflight-router-services": path.join(PROJECT_ROOT, "references", "authoring", "PDV_PreflightRouterServices.manifest.json"),
  "skeleton-track-scaffold": path.join(PROJECT_ROOT, "references", "authoring", "PDV_SkeletonTrackScaffold.manifest.json"),
  "structural-systems-scaffold": path.join(PROJECT_ROOT, "references", "authoring", "PDV_StructuralSystemsScaffold.manifest.json"),
  "structural-systems-arrays": path.join(PROJECT_ROOT, "references", "authoring", "PDV_StructuralSystemsArrays.manifest.json"),
  "pattern-proving-core": path.join(PROJECT_ROOT, "references", "authoring", "PDV_PatternProvingCore.manifest.json"),
  "phase8-concordat-talos": path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase8ConcordatTalos.manifest.json"),
  "slice1-signal-receivers": path.join(PROJECT_ROOT, "references", "authoring", "PDV_Slice1SignalReceivers.manifest.json"),
  "vmad-consolidation": path.join(PROJECT_ROOT, "references", "authoring", "PDV_VmadConsolidation.manifest.json"),
};

const KNOWN_EDITORID_FORMIDS = {
  ArgonianRace: "Skyrim.esm:013740",
  BretonRace: "Skyrim.esm:013741",
  DarkElfRace: "Skyrim.esm:013742",
  HighElfRace: "Skyrim.esm:013743",
  ImperialRace: "Skyrim.esm:013744",
  KhajiitRace: "Skyrim.esm:013745",
  NordRace: "Skyrim.esm:013746",
  OrcRace: "Skyrim.esm:013747",
  RedguardRace: "Skyrim.esm:013748",
  WoodElfRace: "Skyrim.esm:013749",
};

const PHASE_MANIFESTS = {
  phase4: {
    title: "Phase 4 Kyne overlay wiring",
    unsupported: [
      "This tool writes an overlay patch plugin. It does not overwrite PlayerDevotion_Framework.esp in place.",
      "If you want the Phase 4 wiring merged back into the framework ESP itself, finish that merge in CK or xEdit after validating the overlay patch.",
    ],
    operations: [
      {
        kind: "setProperty",
        record: "PDV__MainQuest",
        script: "PDV__MainQuest",
        property: "PDV_OriginQuest",
        valueType: "Object",
        value: "PDV_Origin",
        note: "Wire bootstrap quest to origin quest.",
      },
      {
        kind: "setProperty",
        record: "PDV__MainQuest",
        script: "PDV__MainQuest",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel",
        note: "Wire bootstrap debug global.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_GLO_OriginRace",
        valueType: "Object",
        value: "PDV_GLO_OriginRace",
        note: "Wire origin race cache global.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_Manager",
        valueType: "Object",
        value: "PDV__ManagerQuest",
        note: "Wire origin helper to manager quest.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_Kyne",
        valueType: "Object",
        value: "PDV_Deity_Kyne",
        note: "Wire origin helper to Kyne.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PlayerRef",
        valueType: "Object",
        value: "Skyrim.esm:000014",
        note: "Wire PlayerRef explicitly to the player actor reference.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "NordRace",
        valueType: "Object",
        value: "NordRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "ImperialRace",
        valueType: "Object",
        value: "ImperialRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "BretonRace",
        valueType: "Object",
        value: "BretonRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "HighElfRace",
        valueType: "Object",
        value: "HighElfRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "WoodElfRace",
        valueType: "Object",
        value: "WoodElfRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "DarkElfRace",
        valueType: "Object",
        value: "DarkElfRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "KhajiitRace",
        valueType: "Object",
        value: "KhajiitRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "ArgonianRace",
        valueType: "Object",
        value: "ArgonianRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "OrcRace",
        valueType: "Object",
        value: "OrcRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "RedguardRace",
        valueType: "Object",
        value: "RedguardRace",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel",
        note: "Wire origin debug global.",
      },
      {
        kind: "setProperty",
        record: "PDV__ManagerQuest",
        script: "PDV__ManagerQuest",
        property: "PDV_GLO_PatronDeity",
        valueType: "Object",
        value: "PDV_GLO_PatronDeity",
        note: "Wire patron deity cache global on the manager.",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Kyne",
        script: "PDV_Deity_Kyne",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Kyne",
        script: "PDV_Deity_Kyne",
        property: "PDV_GLO_OriginRace",
        valueType: "Object",
        value: "PDV_GLO_OriginRace",
      },
      ...buildStanceOperations("PDV_Deity_Kyne", "PDV_Deity_Kyne", {
        Nord: 0,
        Imperial: 1,
        Breton: 1,
        Altmer: 1,
        Bosmer: 1,
        Dunmer: 1,
        Khajiit: 1,
        Argonian: 1,
        Orc: 1,
        Redguard: 1,
      }),
    ],
  },
  phase6: {
    title: "Phase 6 Talos/Auri-El overlay wiring",
    unsupported: [
      "Create missing records in CK/xEdit first: PDV_Deity_Talos and PDV_Deity_AuriEl.",
      "Create Talos and Auri-El boon spell records first. This tool can wire boon properties once those spell records exist.",
      "Talos RivalDeities and RivalMultipliers remain manual for now because the current bridge path does not expose VMAD array property writes.",
      "This tool writes an overlay patch plugin. It does not overwrite PlayerDevotion_Framework.esp in place.",
    ],
    operations: [
      {
        kind: "addFormListEntry",
        record: "PDV_FLST_AllDeities",
        entry: "PDV_Deity_Talos",
        note: "Add Talos to the deity iteration list.",
      },
      {
        kind: "addFormListEntry",
        record: "PDV_FLST_AllDeities",
        entry: "PDV_Deity_AuriEl",
        note: "Add Auri-El to the deity iteration list.",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_Talos",
        valueType: "Object",
        value: "PDV_Deity_Talos",
      },
      {
        kind: "setProperty",
        record: "PDV_Origin",
        script: "PDV_Origin",
        property: "PDV_AuriEl",
        valueType: "Object",
        value: "PDV_Deity_AuriEl",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Talos",
        script: "PDV_Deity_Talos",
        property: "DeityName",
        valueType: "String",
        value: "Talos",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Talos",
        script: "PDV_Deity_Talos",
        property: "DeityIndex",
        valueType: "Int",
        value: 1,
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Talos",
        script: "PDV_Deity_Talos",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_Talos",
        script: "PDV_Deity_Talos",
        property: "PDV_GLO_OriginRace",
        valueType: "Object",
        value: "PDV_GLO_OriginRace",
      },
      ...buildStanceOperations("PDV_Deity_Talos", "PDV_Deity_Talos", {
        Nord: 0,
        Imperial: 1,
        Breton: 0,
        Altmer: 3,
        Bosmer: 1,
        Dunmer: 1,
        Khajiit: 1,
        Argonian: 1,
        Orc: 1,
        Redguard: 1,
      }),
      {
        kind: "setProperty",
        record: "PDV_Deity_AuriEl",
        script: "PDV_Deity_AuriEl",
        property: "DeityName",
        valueType: "String",
        value: "Auri-El",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_AuriEl",
        script: "PDV_Deity_AuriEl",
        property: "DeityIndex",
        valueType: "Int",
        value: 2,
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_AuriEl",
        script: "PDV_Deity_AuriEl",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel",
      },
      {
        kind: "setProperty",
        record: "PDV_Deity_AuriEl",
        script: "PDV_Deity_AuriEl",
        property: "PDV_GLO_OriginRace",
        valueType: "Object",
        value: "PDV_GLO_OriginRace",
      },
      ...buildStanceOperations("PDV_Deity_AuriEl", "PDV_Deity_AuriEl", {
        Nord: 1,
        Imperial: 1,
        Breton: 1,
        Altmer: 0,
        Bosmer: 0,
        Dunmer: 1,
        Khajiit: 1,
        Argonian: 1,
        Orc: 3,
        Redguard: 1,
      }),
    ],
  },
};

function buildStanceOperations(record, script, values) {
  return Object.entries(values).map(([raceName, stanceValue]) => ({
    kind: "setProperty",
    record,
    script,
    property: `Stance_${raceName}`,
    valueType: "Int",
    value: stanceValue,
  }));
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  if (!command || command === "-h" || command === "--help" || command === "help") {
    usage(null, 0);
  }

  try {
    if (command === "list-phases" || command === "list-manifests") {
      listManifests();
      return;
    }

    if (command === "status") {
      const options = parseCommonOptions(args.slice(1));
      const phaseName = options.positionals[0];
      runStatus(phaseName, options);
      return;
    }

    if (command === "plan") {
      const options = parseCommonOptions(args.slice(1));
      const phaseName = options.positionals[0];
      runPlan(phaseName, options);
      return;
    }

    if (command === "apply") {
      const options = parseCommonOptions(args.slice(1));
      const phaseName = options.positionals[0];
      runApplyPhase(phaseName, options);
      return;
    }

    if (command === "set-property") {
      const options = parseCommonOptions(args.slice(1));
      runApplyOneOffSetProperty(options);
      return;
    }

    if (command === "add-formlist-entry") {
      const options = parseCommonOptions(args.slice(1));
      runApplyOneOffFormList(options);
      return;
    }

    usage(`Unknown command: ${command}`);
  } catch (error) {
    console.error(error.message || String(error));
    process.exitCode = 1;
  }
}

function usage(error = null, exitCode = 2) {
  const text = [
    "Usage: node tools/pdv_author.mjs <command> [options]",
    "",
    "Commands:",
    "  list-manifests",
    "  list-phases                                      legacy alias for list-manifests",
    "  status <manifest|path> [--manifest <path>]",
    "  plan <manifest|path> [--json] [--write-request <path>] [--manifest <path>]",
    "  apply <manifest|path> [--output <filename>] [--esl] [--author <name>] [--write-request <path>] [--manifest <path>]",
    "  set-property --record <EDID> --script <Name> --property <Name> --type <Object|Int|Float|Bool|String> --value <Value> [--output <filename>] [--esl] [--author <name>] [--write-request <path>]",
    "  add-formlist-entry --record <EDID> --entry <EDID> [--output <filename>] [--esl] [--author <name>] [--write-request <path>]",
    "",
    "Notes:",
    "  - v1 writes overlay patch plugins into the Devotion mod folder.",
    "  - v1 does not create new records or edit VMAD array properties.",
    "  - Tracked JSON manifests live under references/authoring/ and may define a defaultOutput filename.",
    "  - Use 'plan' or 'status' before 'apply' if you want a no-write inspection pass.",
  ].join("\n");

  if (error) {
    console.error(error);
    console.error();
  }
  console.log(text);
  process.exit(exitCode);
}

function listManifests() {
  const builtIns = Object.entries(PHASE_MANIFESTS).map(([phaseName, manifest]) => {
    return `${phaseName.padEnd(22)} ${manifest.title} (built-in)`;
  });
  const tracked = Object.entries(MANIFEST_INDEX).map(([manifestName, manifestPath]) => {
    const title = exists(manifestPath) ? readManifestFile(manifestPath).title : "missing manifest file";
    return `${manifestName.padEnd(22)} ${title} (${path.relative(PROJECT_ROOT, manifestPath)})`;
  });
  console.log([...builtIns, ...tracked].join("\n"));
}

function parseCommonOptions(argv) {
  const options = {
    author: "PDV Author",
    esl: false,
    json: false,
    output: null,
    positionals: [],
    record: null,
    script: null,
    property: null,
    type: null,
    value: null,
    entry: null,
    manifestPath: null,
    writeRequest: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];

    if (arg === "--json") {
      options.json = true;
    } else if (arg === "--esl") {
      options.esl = true;
    } else if (arg === "--author") {
      options.author = requireNext(argv, ++index, "--author");
    } else if (arg.startsWith("--author=")) {
      options.author = arg.slice("--author=".length);
    } else if (arg === "--output") {
      options.output = requireNext(argv, ++index, "--output");
    } else if (arg.startsWith("--output=")) {
      options.output = arg.slice("--output=".length);
    } else if (arg === "--record") {
      options.record = requireNext(argv, ++index, "--record");
    } else if (arg.startsWith("--record=")) {
      options.record = arg.slice("--record=".length);
    } else if (arg === "--script") {
      options.script = requireNext(argv, ++index, "--script");
    } else if (arg.startsWith("--script=")) {
      options.script = arg.slice("--script=".length);
    } else if (arg === "--property") {
      options.property = requireNext(argv, ++index, "--property");
    } else if (arg.startsWith("--property=")) {
      options.property = arg.slice("--property=".length);
    } else if (arg === "--type") {
      options.type = requireNext(argv, ++index, "--type");
    } else if (arg.startsWith("--type=")) {
      options.type = arg.slice("--type=".length);
    } else if (arg === "--value") {
      options.value = requireNext(argv, ++index, "--value");
    } else if (arg.startsWith("--value=")) {
      options.value = arg.slice("--value=".length);
    } else if (arg === "--entry") {
      options.entry = requireNext(argv, ++index, "--entry");
    } else if (arg.startsWith("--entry=")) {
      options.entry = arg.slice("--entry=".length);
    } else if (arg === "--manifest") {
      options.manifestPath = requireNext(argv, ++index, "--manifest");
    } else if (arg.startsWith("--manifest=")) {
      options.manifestPath = arg.slice("--manifest=".length);
    } else if (arg === "--write-request") {
      options.writeRequest = requireNext(argv, ++index, "--write-request");
    } else if (arg.startsWith("--write-request=")) {
      options.writeRequest = arg.slice("--write-request=".length);
    } else if (arg.startsWith("--")) {
      usage(`Unknown option: ${arg}`);
    } else {
      options.positionals.push(arg);
    }
  }

  return options;
}

function requireNext(argv, index, flag) {
  const value = argv[index];
  if (!value) {
    usage(`Missing value after ${flag}.`);
  }
  return value;
}

function runStatus(phaseName, options) {
  const spec = getManifestSpec(phaseName, options);
  const manifest = spec.manifest;
  const context = loadPdvContext(manifest);
  const report = buildManifestReport(manifest, context);

  if (options.json) {
    console.log(JSON.stringify({ manifest: specSummary(spec), report }, null, 2));
    return;
  }

  const lines = [
    `${spec.id}: ${manifest.title}`,
    `source=${spec.source}`,
    `supported_write=${report.summary.ready} manual_only=${report.summary.manual} blocked=${report.summary.blocked} unsupported_notes=${report.summary.unsupported}`,
  ];

  if (manifest.unsupported.length) {
    lines.push("");
    lines.push("Unsupported in v1:");
    for (const item of manifest.unsupported) {
      lines.push(`- ${item}`);
    }
  }

  if (manifest.notes.length) {
    lines.push("");
    lines.push("Notes:");
    for (const item of manifest.notes) {
      lines.push(`- ${item}`);
    }
  }

  appendReportSections(lines, report);

  console.log(lines.join("\n"));
}

function runPlan(phaseName, options) {
  const spec = getManifestSpec(phaseName, options);
  const manifest = spec.manifest;
  const context = loadPdvContext(manifest);
  const report = buildManifestReport(manifest, context);
  const patchRequest = buildPatchRequestForManifest(spec, manifest, context, options, false);

  if (options.writeRequest) {
    writeJsonArtifact(options.writeRequest, patchRequest);
  }

  if (options.json) {
    console.log(JSON.stringify({ manifest: specSummary(spec), report, patchRequest }, null, 2));
    return;
  }

  const lines = [
    `${spec.id}: ${manifest.title}`,
    `source=${spec.source}`,
    `output=${path.basename(patchRequest.output_path)}`,
    `records=${patchRequest.records.length}`,
    `supported_write=${report.summary.ready} manual_only=${report.summary.manual} blocked=${report.summary.blocked}`,
  ];
  if (manifest.notes.length) {
    lines.push("");
    lines.push("Notes:");
    for (const item of manifest.notes) {
      lines.push(`- ${item}`);
    }
  }
  appendReportSections(lines, report);
  console.log(lines.join("\n"));
}

function appendReportSections(lines, report) {
  appendOperationSection(lines, "Supported write operations", report.operations.filter((item) => item.status === "READY"));
  appendOperationSection(lines, "Manual-only operations", report.operations.filter((item) => item.status === "MANUAL"));
  appendOperationSection(lines, "Blocked operations", report.operations.filter((item) => item.status === "BLOCKED"));

  if (report.manualActions.length) {
    lines.push("");
    lines.push("Manual follow-up packet:");
    for (const action of report.manualActions) {
      lines.push(`- ${action.target}`);
      lines.push(`  action: ${action.manualAction}`);
      if (action.valueType) {
        lines.push(`  value_type: ${action.valueType}`);
      }
      lines.push(`  intended_value: ${JSON.stringify(action.intendedValue)}`);
      lines.push(`  verifier: ${action.verifierExpectation}`);
    }
  }
}

function appendOperationSection(lines, title, operations) {
  if (!operations.length) {
    return;
  }

  lines.push("");
  lines.push(`${title}:`);
  for (const item of operations) {
    lines.push(`- [${item.status}] ${describeOperationTarget(item)}`);
    if (item.detail) {
      lines.push(`  ${item.detail}`);
    }
  }
}

function runApplyPhase(phaseName, options) {
  const spec = getManifestSpec(phaseName, options);
  const manifest = spec.manifest;
  const context = loadPdvContext(manifest);
  const patchRequest = buildPatchRequestForManifest(spec, manifest, context, options, true);

  if (options.writeRequest) {
    writeJsonArtifact(options.writeRequest, patchRequest);
  }

  const response = invokePatchWrite(patchRequest);
  const hygiene = checkPatchMasterHygiene(patchRequest.output_path);
  if (options.json) {
    console.log(JSON.stringify({ ...response, hygiene }, null, 2));
    return;
  }

  const lines = [
    `${spec.id}: ${manifest.title}`,
    `source=${spec.source}`,
    `output=${path.basename(patchRequest.output_path)}`,
    `success=${Boolean(response.success)}`,
    `records_written=${response.records_written ?? 0}`,
    `successful_count=${response.successful_count ?? 0}`,
    `failed_count=${response.failed_count ?? 0}`,
  ];

  if (Array.isArray(response.details) && response.details.length) {
    lines.push("");
    lines.push("Bridge details:");
    for (const detail of response.details) {
      const label = detail.formid || detail.editor_id || detail.record_type || "record";
      lines.push(`- ${label}: ${detail.error || "ok"}`);
    }
  }

  if (response.error) {
    lines.push("");
    lines.push(`error=${response.error}`);
  }

  appendPatchMasterHygieneLines(lines, hygiene);

  lines.push("");
  lines.push("Next step:");
  if (response.success) {
    lines.push("- Press F5 in MO2 if the new plugin file does not appear immediately.");
    lines.push("- Enable the generated patch plugin in MO2's right pane when you want it in the load order.");
    lines.push("- Run `node .\\tools\\pdv_verify.mjs` after enabling the patch.");
  } else {
    lines.push("- Fix the bridge error above, then rerun this apply command.");
  }
  console.log(lines.join("\n"));
}

function runApplyOneOffSetProperty(options) {
  requireOption(options.record, "--record");
  requireOption(options.script, "--script");
  requireOption(options.property, "--property");
  requireOption(options.type, "--type");
  requireOption(options.value, "--value");

  const valueType = canonicalValueType(options.type);
  const operation = {
    kind: "setProperty",
    record: options.record,
    script: options.script,
    property: options.property,
    valueType,
    value: options.value,
  };
  const context = loadPdvContext({ operations: [operation], unsupported: [] });
  const patchRequest = buildPatchRequestFromOperations(
    [operation],
    context,
    options,
    "one_off_set_property",
  );

  if (options.writeRequest) {
    writeJsonArtifact(options.writeRequest, patchRequest);
  }

  const response = invokePatchWrite(patchRequest);
  const hygiene = checkPatchMasterHygiene(patchRequest.output_path);
  console.log(options.json ? JSON.stringify({ ...response, hygiene }, null, 2) : summarizeOneOffWrite(response, patchRequest, hygiene));
}

function runApplyOneOffFormList(options) {
  requireOption(options.record, "--record");
  requireOption(options.entry, "--entry");

  const operation = {
    kind: "addFormListEntry",
    record: options.record,
    entry: options.entry,
  };
  const context = loadPdvContext({ operations: [operation], unsupported: [] });
  const patchRequest = buildPatchRequestFromOperations(
    [operation],
    context,
    options,
    "one_off_formlist",
  );

  if (options.writeRequest) {
    writeJsonArtifact(options.writeRequest, patchRequest);
  }

  const response = invokePatchWrite(patchRequest);
  const hygiene = checkPatchMasterHygiene(patchRequest.output_path);
  console.log(options.json ? JSON.stringify({ ...response, hygiene }, null, 2) : summarizeOneOffWrite(response, patchRequest, hygiene));
}

function summarizeOneOffWrite(response, patchRequest, hygiene = null) {
  const lines = [
    `output=${path.basename(patchRequest.output_path)}`,
    `success=${Boolean(response.success)}`,
    `records_written=${response.records_written ?? 0}`,
    response.error ? `error=${response.error}` : null,
  ].filter(Boolean);
  appendPatchMasterHygieneLines(lines, hygiene);
  return lines.join("\n");
}

function checkPatchMasterHygiene(outputPath) {
  if (!exists(outputPath)) {
    return {
      ok: false,
      warning: "Patch output was not found, so master-order hygiene could not be checked.",
      masters: [],
    };
  }

  let inventory;
  try {
    inventory = loadPluginInventory(outputPath);
  } catch (error) {
    return {
      ok: false,
      warning: `Patch master-order hygiene check failed: ${error.message}`,
      masters: [],
    };
  }

  const masters = inventory.plugin.masters || [];
  const pluginName = path.basename(outputPath).toLowerCase();
  const hasSelfOwnedRecords = (inventory.plugin.records || []).some((record) => {
    const formid = String(record.formid || "").toLowerCase();
    return formid.startsWith(`${pluginName}:`);
  });
  if (!hasSelfOwnedRecords) {
    return {
      ok: true,
      masters,
      warning: null,
    };
  }

  const firstMaster = masters[0] || "";
  const ok = firstMaster.toLowerCase() === "skyrim.esm";
  return {
    ok,
    masters,
    warning: ok
      ? null
      : "xEdit may warn: modules with extended FormID range should have Skyrim.esm as their first master.",
  };
}

function appendPatchMasterHygieneLines(lines, hygiene) {
  if (!hygiene || hygiene.ok) {
    return;
  }

  lines.push("");
  lines.push("Patch hygiene warning:");
  lines.push(`- ${hygiene.warning}`);
  if (hygiene.masters.length) {
    lines.push(`- Current masters: ${hygiene.masters.join(", ")}`);
  }
  lines.push("- Do not manually insert Skyrim.esm into the header without remapping FormIDs.");
}

function requireOption(value, label) {
  if (!value) {
    usage(`Missing required option ${label}.`);
  }
}

function getManifestSpec(manifestName, options = {}) {
  if (options.manifestPath && manifestName) {
    usage("Use either a positional manifest name/path or --manifest, not both.");
  }

  const requested = options.manifestPath || manifestName;
  if (!requested) {
    usage("Manifest name or path is required.");
  }

  if (!options.manifestPath && PHASE_MANIFESTS[requested]) {
    return {
      id: requested,
      label: safeLabel(requested),
      source: "built-in",
      manifest: normalizeManifest(PHASE_MANIFESTS[requested], requested),
    };
  }

  const indexedPath = !options.manifestPath ? MANIFEST_INDEX[requested] : null;
  const manifestPath = indexedPath || resolveManifestPath(requested);
  if (!manifestPath || !exists(manifestPath)) {
    usage(`Unknown manifest: ${requested}`);
  }

  const manifest = normalizeManifest(readManifestFile(manifestPath), path.basename(manifestPath));
  const id = manifest.id || path.basename(manifestPath).replace(/\.manifest\.json$/i, "").replace(/\.json$/i, "");
  return {
    id,
    label: safeLabel(id),
    source: path.relative(PROJECT_ROOT, manifestPath),
    manifest,
  };
}

function resolveManifestPath(candidate) {
  const resolved = path.isAbsolute(candidate)
    ? candidate
    : path.resolve(PROJECT_ROOT, candidate);
  if (exists(resolved)) {
    return resolved;
  }

  const authoringPath = path.join(PROJECT_ROOT, "references", "authoring", candidate);
  if (exists(authoringPath)) {
    return authoringPath;
  }

  return null;
}

function readManifestFile(manifestPath) {
  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  } catch (error) {
    throw new Error(`Could not read manifest ${manifestPath}: ${error.message}`);
  }
  return parsed;
}

function normalizeManifest(manifest, fallbackId) {
  if (!manifest || typeof manifest !== "object" || Array.isArray(manifest)) {
    throw new Error(`Manifest ${fallbackId} must be a JSON object.`);
  }
  if (!Array.isArray(manifest.operations)) {
    throw new Error(`Manifest ${manifest.id || fallbackId} must define an operations array.`);
  }
  return {
    id: manifest.id || fallbackId,
    title: manifest.title || manifest.id || fallbackId,
    defaultOutput: manifest.defaultOutput || null,
    unsupported: Array.isArray(manifest.unsupported) ? manifest.unsupported : [],
    notes: Array.isArray(manifest.notes) ? manifest.notes : [],
    operations: manifest.operations,
  };
}

function specSummary(spec) {
  return {
    id: spec.id,
    source: spec.source,
    title: spec.manifest.title,
    defaultOutput: spec.manifest.defaultOutput,
  };
}

function loadPdvContext(manifest) {
  checkEnvironment();
  const pdvInventory = loadPluginInventory(PDV_ESP);
  const pdvDetails = loadRecordDetails(PDV_ESP, [...pdvInventory.recordsByEdid.values()].map((record) => record.formid));
  const externalReferences = resolveExternalReferences(manifest.operations, pdvInventory.recordsByEdid);
  return {
    pdvInventory,
    pdvDetails,
    externalReferences,
  };
}

function checkEnvironment() {
  const requiredPaths = {
    "PlayerDevotion ESP": PDV_ESP,
    "Mutagen bridge": MUTAGEN_BRIDGE,
    "Devotion profile": DEVOTION_PROFILE,
    "Devotion mod": DEVOTION_MOD,
  };

  const failures = Object.entries(requiredPaths)
    .filter(([, filePath]) => !exists(filePath))
    .map(([label, filePath]) => `${label}: ${filePath}`);

  if (failures.length) {
    throw new Error(`Missing required path(s):\n${failures.join("\n")}`);
  }
}

function buildManifestReport(manifest, context) {
  const operations = manifest.operations.map((operation) => evaluateOperation(operation, context));
  const summary = {
    ready: operations.filter((item) => item.status === "READY").length,
    manual: operations.filter((item) => item.status === "MANUAL").length,
    blocked: operations.filter((item) => item.status === "BLOCKED").length,
    unsupported: manifest.unsupported.length,
  };
  const manualActions = operations
    .filter((item) => item.status === "MANUAL")
    .map((item) => buildManualFollowUpAction(item, context));
  return {
    summary,
    operations,
    manualActions,
    unsupported: manifest.unsupported,
    notes: manifest.notes,
  };
}

function evaluateOperation(operation, context) {
  if (operation.kind === "attachScript") {
    const record = context.pdvInventory.recordsByEdid.get(operation.record);
    if (!record) {
      return {
        ...operation,
        status: "BLOCKED",
        detail: `Record ${operation.record} is not present in PlayerDevotion_Framework.esp.`,
      };
    }

    const scriptState = describeScriptAttachment(record.edid, operation.script, context.pdvDetails);
    return {
      ...operation,
      status: "READY",
      detail: scriptState,
    };
  }

  if (operation.kind === "setProperty") {
    const record = context.pdvInventory.recordsByEdid.get(operation.record);
    if (!record) {
      return {
        ...operation,
        status: "BLOCKED",
        detail: `Record ${operation.record} is not present in PlayerDevotion_Framework.esp.`,
      };
    }

    if (ARRAY_VALUE_TYPES.has(operation.valueType)) {
      const arrayCheck = validateArrayPropertyOperation(operation, context);
      if (!arrayCheck.ok) {
        return {
          ...operation,
          status: "BLOCKED",
          detail: arrayCheck.reason,
        };
      }

      return {
        ...operation,
        status: "MANUAL",
        detail: "VMAD array properties are recognized for planning/reporting, but mutagen-bridge does not currently expose array writes through attach_scripts. Wire this array manually in CK/xEdit and use verifier readback to confirm it.",
      };
    }

    if (OBJECT_VALUE_TYPES.has(operation.valueType)) {
      const resolved = resolveReferenceValue(operation.value, context);
      if (!resolved.ok) {
        return {
          ...operation,
          status: "BLOCKED",
          detail: resolved.reason,
        };
      }
    }

    const scriptState = describeScriptAttachment(record.edid, operation.script, context.pdvDetails);
    return {
      ...operation,
      status: "READY",
      detail: scriptState,
    };
  }

  if (operation.kind === "addFormListEntry") {
    const record = context.pdvInventory.recordsByEdid.get(operation.record);
    if (!record) {
      return {
        ...operation,
        status: "BLOCKED",
        detail: `FormList ${operation.record} is not present in PlayerDevotion_Framework.esp.`,
      };
    }

    const resolved = resolveReferenceValue(operation.entry, context);
    if (!resolved.ok) {
      return {
        ...operation,
        status: "BLOCKED",
        detail: resolved.reason,
      };
    }

    return {
      ...operation,
      status: "READY",
      detail: `Will add ${operation.entry} to ${operation.record}.`,
    };
  }

  return {
    ...operation,
    status: "BLOCKED",
    detail: `Unsupported operation kind: ${operation.kind}`,
  };
}

function describeScriptAttachment(recordEdid, scriptName, detailMap) {
  const detail = detailMap.get(recordEdid);
  if (!detail) {
    return `${recordEdid} exists, but detail payload is unavailable.`;
  }

  const script = findScript(detail.fields || {}, scriptName);
  if (script) {
    return `${scriptName} is already attached.`;
  }

  return `${scriptName} is not attached yet; bridge will attach/update it if the record type supports VMAD.`;
}

function buildManualFollowUpAction(operation, context) {
  const action = {
    target: describeOperationTarget(operation),
    kind: operation.kind,
    record: operation.record || null,
    script: operation.script || null,
    property: operation.property || null,
    valueType: operation.valueType || null,
    intendedValue: operation.value,
    manualAction: "Review in CK/xEdit and complete the unsupported wiring manually.",
    verifierExpectation: buildVerifierExpectation(operation),
    detail: operation.detail || "",
  };

  if (operation.kind === "setProperty" && ARRAY_VALUE_TYPES.has(operation.valueType)) {
    action.manualAction = `Wire ${operation.property} manually on ${operation.record}.${operation.script} in CK/xEdit; the current bridge path cannot emit ${operation.valueType} writes.`;
    action.intendedValue = describeManualIntendedValue(operation, context);
  } else if (operation.kind === "attachScript") {
    action.manualAction = `Attach ${operation.script} manually to ${operation.record} in CK/xEdit.`;
  } else if (operation.kind === "addFormListEntry") {
    action.manualAction = `Add ${operation.entry} manually to FormList ${operation.record} in CK/xEdit.`;
  }

  return action;
}

function describeManualIntendedValue(operation, context) {
  if (!Array.isArray(operation.value)) {
    return operation.value;
  }

  if (operation.valueType !== "ObjectArray") {
    return [...operation.value];
  }

  return operation.value.map((entry) => {
    const resolved = resolveReferenceValue(entry, context);
    return resolved.ok
      ? { source: entry, resolvedFormId: resolved.formid }
      : { source: entry, unresolved: resolved.reason };
  });
}

function buildVerifierExpectation(operation) {
  if (operation.kind === "setProperty" && operation.record && operation.script && operation.property) {
    return `After manual wiring, rerun pdv_verify and confirm ${operation.record}.${operation.script}.${operation.property} reads back with the intended value.`;
  }

  if (operation.kind === "attachScript" && operation.record && operation.script) {
    return `After manual wiring, rerun pdv_verify and confirm ${operation.script} is attached to ${operation.record}.`;
  }

  if (operation.kind === "addFormListEntry" && operation.record && operation.entry) {
    return `After manual wiring, rerun pdv_verify and confirm ${operation.entry} is present in ${operation.record}.`;
  }

  return "After manual wiring, rerun pdv_verify and confirm the intended readback is visible.";
}

function resolveExternalReferences(operations, pdvRecordsByEdid) {
  const wantedEdids = new Set();

  for (const operation of operations) {
    const candidates = [];
    if (operation.kind === "setProperty" && OBJECT_VALUE_TYPES.has(operation.valueType)) {
      candidates.push(operation.value);
    } else if (operation.kind === "setProperty" && operation.valueType === "ObjectArray" && Array.isArray(operation.value)) {
      for (const entry of operation.value) {
        candidates.push(entry);
      }
    } else if (operation.kind === "addFormListEntry") {
      candidates.push(operation.entry);
    }

    for (const candidate of candidates) {
      if (!candidate || looksLikeFormId(candidate)) {
        continue;
      }
      if (pdvRecordsByEdid.has(candidate)) {
        continue;
      }
      wantedEdids.add(candidate);
    }
  }

  if (!wantedEdids.size) {
    return new Map();
  }

  const found = new Map();
  for (const edid of wantedEdids) {
    const formid = KNOWN_EDITORID_FORMIDS[edid];
    if (formid) {
      found.set(edid, formid);
    }
  }

  return found;
}

function buildPatchRequestForManifest(spec, manifest, context, options, requireReady) {
  const effectiveOptions = {
    ...options,
    output: options.output || manifest.defaultOutput || null,
  };
  return buildPatchRequestFromOperations(
    manifest.operations,
    context,
    effectiveOptions,
    spec.label,
    requireReady,
  );
}

function buildPatchRequestFromOperations(operations, context, options, label, requireReady = true) {
  const evaluated = operations.map((operation) => evaluateOperation(operation, context));
  const blocked = evaluated.filter((item) => item.status !== "READY");
  if (requireReady && blocked.length) {
    const details = blocked.map((item) => {
      const target = describeOperationTarget(item);
      return `- ${target}: ${item.detail}`;
    });
    throw new Error(`Cannot build patch request because some operations are blocked:\n${details.join("\n")}`);
  }

  const recordSpecs = new Map();
  for (const operation of evaluated.filter((item) => item.status === "READY")) {
    if (operation.kind === "attachScript") {
      addAttachScriptToRecordSpecs(operation, context, recordSpecs);
    } else if (operation.kind === "setProperty") {
      addSetPropertyToRecordSpecs(operation, context, recordSpecs);
    } else if (operation.kind === "addFormListEntry") {
      addFormListEntryToRecordSpecs(operation, context, recordSpecs);
    }
  }

  const loadOrder = buildLoadOrderContext();
  const outputPath = buildOutputPath(label, options.output);
  return {
    output_path: toPosix(outputPath),
    esl_flag: Boolean(options.esl),
    author: options.author,
    records: [...recordSpecs.values()],
    load_order: loadOrder,
  };
}

function describeOperationTarget(operation) {
  if (operation.kind === "attachScript") {
    return `${operation.record}.${operation.script}`;
  }
  if (operation.kind === "setProperty") {
    return `${operation.record}.${operation.script}.${operation.property}`;
  }
  if (operation.kind === "addFormListEntry") {
    return `${operation.record} += ${operation.entry}`;
  }
  return `${operation.kind} ${operation.record || ""}`.trim();
}

function getOrCreateRecordSpec(recordEdid, context, recordSpecs) {
  const record = context.pdvInventory.recordsByEdid.get(recordEdid);
  const key = record.formid;
  let spec = recordSpecs.get(key);
  if (!spec) {
    spec = {
      op: "override",
      formid: record.formid,
      source_plugin: "PlayerDevotion_Framework.esp",
      source_path: toPosix(PDV_ESP),
    };
    recordSpecs.set(key, spec);
  }
  return spec;
}

function getOrCreateAttachedScript(spec, scriptName) {
  if (!spec.attach_scripts) {
    spec.attach_scripts = [];
  }

  let script = spec.attach_scripts.find((entry) => entry.name === scriptName);
  if (!script) {
    script = { name: scriptName };
    spec.attach_scripts.push(script);
  }

  return script;
}

function addAttachScriptToRecordSpecs(operation, context, recordSpecs) {
  const spec = getOrCreateRecordSpec(operation.record, context, recordSpecs);
  getOrCreateAttachedScript(spec, operation.script);
}

function addSetPropertyToRecordSpecs(operation, context, recordSpecs) {
  const spec = getOrCreateRecordSpec(operation.record, context, recordSpecs);
  const script = getOrCreateAttachedScript(spec, operation.script);
  if (!script.properties) {
    script.properties = [];
  }

  script.properties.push({
    name: operation.property,
    type: operation.valueType,
    value: convertPropertyValue(operation, context),
  });
}

function addFormListEntryToRecordSpecs(operation, context, recordSpecs) {
  const spec = getOrCreateRecordSpec(operation.record, context, recordSpecs);

  if (!spec.add_form_list_entries) {
    spec.add_form_list_entries = [];
  }

  const resolved = resolveReferenceValue(operation.entry, context);
  spec.add_form_list_entries.push(resolved.formid);
}

function convertPropertyValue(operation, context) {
  const valueType = canonicalValueType(operation.valueType);
  if (valueType === "Object") {
    const resolved = resolveReferenceValue(operation.value, context);
    if (!resolved.ok) {
      throw new Error(resolved.reason);
    }
    return resolved.formid;
  }

  if (valueType === "Int") {
    const value = Number.parseInt(String(operation.value), 10);
    if (!Number.isInteger(value)) {
      throw new Error(`Property ${operation.property} expects an Int, got ${operation.value}.`);
    }
    return value;
  }

  if (valueType === "Float") {
    const value = Number.parseFloat(String(operation.value));
    if (!Number.isFinite(value)) {
      throw new Error(`Property ${operation.property} expects a Float, got ${operation.value}.`);
    }
    return value;
  }

  if (valueType === "Bool") {
    return parseBoolean(operation.value);
  }

  if (valueType === "String") {
    return String(operation.value);
  }

  if (ARRAY_VALUE_TYPES.has(valueType)) {
    throw new Error(`VMAD array property writes are not implemented for ${valueType}.`);
  }

  throw new Error(`Unsupported property type: ${valueType}`);
}

function canonicalValueType(valueType) {
  const normalized = String(valueType || "").trim();
  if (!SUPPORTED_PROPERTY_TYPES.has(normalized)) {
    throw new Error(`Unsupported property type: ${valueType}. Supported types: ${[...SUPPORTED_PROPERTY_TYPES].join(", ")}`);
  }
  if (normalized === "Alias") {
    throw new Error("Alias property wiring is not implemented in pdv_author.mjs v1.");
  }
  return normalized;
}

function parseBoolean(value) {
  const normalized = String(value).trim().toLowerCase();
  if (["true", "1", "yes"].includes(normalized)) {
    return true;
  }
  if (["false", "0", "no"].includes(normalized)) {
    return false;
  }
  throw new Error(`Expected a Bool value, got ${value}.`);
}

function validateArrayPropertyOperation(operation, context) {
  if (!Array.isArray(operation.value)) {
    return {
      ok: false,
      reason: `${operation.record}.${operation.script}.${operation.property} uses ${operation.valueType} but the manifest value is not an array.`,
    };
  }

  if (operation.valueType === "ObjectArray") {
    for (const entry of operation.value) {
      const resolved = resolveReferenceValue(entry, context);
      if (!resolved.ok) {
        return {
          ok: false,
          reason: resolved.reason,
        };
      }
    }
    return { ok: true };
  }

  for (const entry of operation.value) {
    if (operation.valueType === "IntArray" && !Number.isInteger(entry)) {
      return {
        ok: false,
        reason: `${operation.record}.${operation.script}.${operation.property} expects every IntArray entry to be an integer.`,
      };
    }

    if (operation.valueType === "FloatArray" && !Number.isFinite(Number(entry))) {
      return {
        ok: false,
        reason: `${operation.record}.${operation.script}.${operation.property} expects every FloatArray entry to be numeric.`,
      };
    }

    if (operation.valueType === "StringArray" && typeof entry !== "string") {
      return {
        ok: false,
        reason: `${operation.record}.${operation.script}.${operation.property} expects every StringArray entry to be a string.`,
      };
    }
  }

  return { ok: true };
}

function resolveReferenceValue(candidate, context) {
  if (!candidate) {
    return { ok: false, reason: "Object property reference is empty." };
  }

  if (looksLikeFormId(candidate)) {
    return { ok: true, formid: normalizeFormId(candidate) };
  }

  const pdvRecord = context.pdvInventory.recordsByEdid.get(candidate);
  if (pdvRecord) {
    return { ok: true, formid: pdvRecord.formid };
  }

  const external = context.externalReferences.get(candidate);
  if (external) {
    return { ok: true, formid: external };
  }

  return {
    ok: false,
    reason: `Could not resolve reference '${candidate}' by EditorID or FormID.`,
  };
}

function buildOutputPath(label, requestedOutput) {
  const filename = requestedOutput || `PDV_Author_${label}_${timestamp()}.esp`;
  if (filename.includes("/") || filename.includes("\\") || filename.includes("..")) {
    throw new Error(`Output filename must be a simple file name, got: ${filename}`);
  }
  if (!filename.toLowerCase().endsWith(".esp")) {
    throw new Error(`Output filename must end in .esp, got: ${filename}`);
  }
  return path.join(DEVOTION_MOD, filename);
}

function safeLabel(value) {
  const label = String(value || "manifest")
    .trim()
    .replace(/[^a-z0-9_-]+/gi, "_")
    .replace(/^_+|_+$/g, "");
  return label || "manifest";
}

function timestamp() {
  const date = new Date();
  const yyyy = String(date.getFullYear());
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");
  const hh = String(date.getHours()).padStart(2, "0");
  const mi = String(date.getMinutes()).padStart(2, "0");
  const ss = String(date.getSeconds()).padStart(2, "0");
  return `${yyyy}${mm}${dd}_${hh}${mi}${ss}`;
}

function buildLoadOrderContext() {
  const loadOrderNames = readPluginList(path.join(DEVOTION_PROFILE, "loadorder.txt"), false);
  const enabledNames = new Set(readPluginList(path.join(DEVOTION_PROFILE, "plugins.txt"), true));
  const modNames = readEnabledModList(path.join(DEVOTION_PROFILE, "modlist.txt"));
  const pluginPathMap = buildPluginPathMap(modNames);

  const listings = [];
  for (const pluginName of loadOrderNames) {
    const pluginPath = pluginPathMap.get(pluginName.toLowerCase());
    if (!pluginPath || !exists(pluginPath)) {
      continue;
    }
    listings.push({
      mod_key: pluginName,
      path: toPosix(pluginPath),
      enabled: enabledNames.has(pluginName.toLowerCase()) || isImplicitMaster(pluginName),
    });
  }

  const ctx = {
    game_release: "SkyrimSE",
    listings,
  };

  if (exists(STOCK_GAME_DATA)) {
    ctx.data_folder = toPosix(STOCK_GAME_DATA);
  }

  const cccPath = path.join(STOCK_GAME, "Skyrim.ccc");
  if (exists(cccPath)) {
    ctx.ccc_path = toPosix(cccPath);
  }

  return ctx;
}

function readPluginList(filePath, starredOnly) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"))
    .filter((line) => !starredOnly || line.startsWith("*"))
    .map((line) => starredOnly ? line.slice(1).trim() : line)
    .map((line) => line.toLowerCase());
}

function readEnabledModList(filePath) {
  return fs.readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("+"))
    .map((line) => line.slice(1).trim())
    .filter((name) => name && !name.endsWith("_separator"));
}

function buildPluginPathMap(modNames) {
  const map = new Map();

  // Stock Game/Data plugins are always available to the game.
  for (const entry of listPluginFiles(STOCK_GAME_DATA)) {
    map.set(entry.name.toLowerCase(), entry.fullPath);
  }

  // Later enabled mods in modlist.txt take priority over earlier ones.
  for (const modName of modNames) {
    const modRoot = path.join(ANVIL_ROOT, "mods", modName);
    for (const entry of listPluginFiles(modRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
    const dataRoot = path.join(modRoot, "Data");
    for (const entry of listPluginFiles(dataRoot)) {
      map.set(entry.name.toLowerCase(), entry.fullPath);
    }
  }

  return map;
}

function listPluginFiles(dirPath) {
  if (!exists(dirPath) || !fs.statSync(dirPath).isDirectory()) {
    return [];
  }

  return fs.readdirSync(dirPath, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .filter((entry) => [".esp", ".esm", ".esl"].includes(path.extname(entry.name).toLowerCase()))
    .map((entry) => ({
      name: entry.name,
      fullPath: path.join(dirPath, entry.name),
    }));
}

function isImplicitMaster(pluginName) {
  return ["skyrim.esm", "update.esm", "dawnguard.esm", "hearthfires.esm", "dragonborn.esm"].includes(pluginName.toLowerCase());
}

function loadPluginInventory(pluginPath) {
  const payload = bridge({
    command: "scan",
    plugins: [toPosix(pluginPath)],
  }, 60_000);

  const plugin = payload.plugins?.[0];
  if (!plugin) {
    throw new Error(`Mutagen scan returned no plugin payload for ${pluginPath}.`);
  }

  const recordsByEdid = new Map();
  const recordsByFormid = new Map();
  for (const record of plugin.records || []) {
    if (record.formid) {
      recordsByFormid.set(record.formid, record);
    }
    if (record.edid) {
      recordsByEdid.set(record.edid, record);
    }
  }

  return {
    plugin,
    recordsByEdid,
    recordsByFormid,
  };
}

function loadRecordDetails(pluginPath, formids) {
  if (!formids.length) {
    return new Map();
  }

  const payload = bridge({
    command: "read_records",
    records: formids.map((formid) => ({
      plugin_path: toPosix(pluginPath),
      formid,
    })),
  }, 60_000);

  const details = new Map();
  for (const record of payload.records || []) {
    if (record.success && record.editor_id) {
      details.set(record.editor_id, record);
    }
  }
  return details;
}

function bridge(request, timeoutMs = 30_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    maxBuffer: BRIDGE_MAX_BUFFER,
    timeout: timeoutMs,
    windowsHide: true,
  });

  if (result.error) {
    throw result.error;
  }

  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  }

  let payload;
  try {
    payload = JSON.parse(stdout);
  } catch (error) {
    throw new Error(`mutagen-bridge returned invalid JSON: ${stdout.slice(0, 500)}`);
  }

  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }

  return payload;
}

function invokePatchWrite(request) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    maxBuffer: BRIDGE_MAX_BUFFER,
    timeout: 120_000,
    windowsHide: true,
  });

  if (result.error) {
    throw result.error;
  }

  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge write returned no output: ${(result.stderr || "").trim()}`);
  }

  let payload;
  try {
    payload = JSON.parse(stdout);
  } catch (error) {
    throw new Error(`mutagen-bridge write returned invalid JSON: ${stdout.slice(0, 500)}`);
  }

  return payload;
}

function writeJsonArtifact(targetPath, payload) {
  const resolved = path.isAbsolute(targetPath)
    ? targetPath
    : path.join(PROJECT_ROOT, targetPath);
  fs.writeFileSync(resolved, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
}

function findScript(fields, scriptName) {
  const scripts = fields?.VirtualMachineAdapter?.Scripts || [];
  return scripts.find((entry) => entry.Name === scriptName) || null;
}

function looksLikeFormId(value) {
  return /^[^:]+\.(esm|esp|esl):[0-9a-f]{6}$/i.test(String(value || "").trim());
}

function normalizeFormId(value) {
  const text = String(value).trim();
  if (!looksLikeFormId(text)) {
    throw new Error(`Invalid FormID format: ${value}`);
  }
  const [pluginName, localId] = text.split(":");
  return `${pluginName}:${localId.toUpperCase()}`;
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function toPosix(filePath) {
  return String(filePath).replace(/\\/g, "/");
}

main();
