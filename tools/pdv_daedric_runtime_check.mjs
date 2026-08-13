#!/usr/bin/env node
/*
 * Read-only Papyrus log checker for the Daedric sender proof packet.
 *
 * This validates that controlled or exact live Daedric sender routes reached EventBus.
 * It does not replace the human Active Effects, MessageBox, Prisma, curse,
 * save/load, stack, or organic vanilla sender checks in the Daedric runbook.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--help", "--include-generic", "--json", "--list", "--log", "--no-generic", "--prince", "--self-test", "--source", "--strict-manager"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_daedric_runtime_check" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const CONTRACT_PATH = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const DEFAULT_LOG = path.join(
  "C:/Users/Admin",
  "Documents",
  "My Games",
  "Skyrim Special Edition",
  "Logs",
  "Script",
  "Papyrus.0.log",
);

function usage() {
  return [
    "Usage: node .\\tools\\pdv_daedric_runtime_check.mjs [options]",
    "",
    "Options:",
    "  --prince <all|stem|display>  Prince to check. Defaults to all.",
    "  --log <path>                 Papyrus log path. Defaults to Papyrus.0.log.",
    "  --strict-manager            Also fail when manager proof traces are missing.",
    "  --source <any|qasmoke|mcm|organic>",
    "                              Manager source marker required with --strict-manager.",
    "                              Defaults to any.",
    "  --include-generic           Require the generic silence probe marker. Default on.",
    "  --no-generic                Do not require the generic silence probe marker.",
    "  --list                      Print expected markers and exit.",
    "  --self-test                 Check an embedded synthetic log and exit.",
    "  --json                      Emit JSON.",
    "  --help                      Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = {
    prince: "all",
    logPath: DEFAULT_LOG,
    strictManager: false,
    source: "any",
    includeGeneric: true,
    list: false,
    selfTest: false,
    json: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--prince") {
      index += 1;
      options.prince = String(argv[index] || "").toLowerCase();
      if (!options.prince) {
        throw new Error("--prince requires a value.");
      }
    } else if (arg === "--log") {
      index += 1;
      options.logPath = argv[index];
      if (!options.logPath) {
        throw new Error("--log requires a path.");
      }
    } else if (arg === "--strict-manager") {
      options.strictManager = true;
    } else if (arg === "--source") {
      index += 1;
      options.source = String(argv[index] || "").toLowerCase();
      if (!["any", "qasmoke", "mcm", "organic"].includes(options.source)) {
        throw new Error("--source must be one of: any, qasmoke, mcm, organic.");
      }
    } else if (arg === "--include-generic") {
      options.includeGeneric = true;
    } else if (arg === "--no-generic") {
      options.includeGeneric = false;
    } else if (arg === "--list") {
      options.list = true;
    } else if (arg === "--self-test") {
      options.selfTest = true;
    } else if (arg === "--json") {
      options.json = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function loadPrinces() {
  if (!fs.existsSync(CONTRACT_PATH)) {
    throw new Error(`Daedric contract not found: ${CONTRACT_PATH}`);
  }

  const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
  if (!Array.isArray(contract.princes) || contract.princes.length !== 16) {
    throw new Error("Daedric contract must contain exactly 16 princes.");
  }

  const organicSources = organicSourceMap();

  return contract.princes.map((prince, index) => ({
    index,
    stem: String(prince.stem || ""),
    key: String(prince.stem || "").toLowerCase(),
    displayName: String(prince.displayName || prince.stem || ""),
    questEditorId: String(prince.questEditorId || ""),
    reference: `PDV_REFR_Daedric_${prince.stem}_LiveSender_QASmoke`,
    sourceId: `qasmoke_daedric_${String(prince.stem || "").toLowerCase()}`,
    organicSourceId: organicSources[String(prince.stem || "").toLowerCase()] || "",
    required: [`RouteDaedricPrinceSignal complete: 200 index ${index}`],
  }));
}

function organicSourceMap() {
  return {
    boethiah: "po3_queststage_daedric_boethiah_da02",
    azura: "po3_queststage_daedric_azura_da01",
    vaermina: "po3_queststage_daedric_vaermina_da16",
    meridia: "po3_queststage_daedric_meridia_da09",
    molag: "po3_queststage_daedric_molag_da10",
    mephala: "po3_queststage_daedric_mephala_da08",
    malacath: "po3_queststage_daedric_malacath_da06",
    dagon: "po3_queststage_daedric_dagon_da07",
    sheo: "po3_queststage_daedric_sheo_da15",
    namira: "po3_queststage_daedric_namira_da11",
    sanguine: "po3_queststage_daedric_sanguine_da14",
    vile: "po3_queststage_daedric_vile_da03",
    mora: "po3_queststage_daedric_mora_da04",
    nocturnal: "po3_queststage_daedric_nocturnal_tg09",
    peryite: "po3_queststage_daedric_peryite_da13",
    hircine: "po3_queststage_daedric_hircine_da05",
  };
}

function managerMarkerForPrince(prince, sourceMode) {
  const prefix = `Daedric live signal: ${prince.displayName} index ${prince.index} source eventbus_200_`;
  if (sourceMode === "qasmoke") {
    return `${prefix}${prince.sourceId}`;
  }
  if (sourceMode === "mcm") {
    return `${prefix}mcm_live_`;
  }
  if (sourceMode === "organic") {
    if (!prince.organicSourceId) {
      throw new Error(`No organic source mapping for ${prince.stem}.`);
    }
    return `${prefix}${prince.organicSourceId}`;
  }
  return prefix;
}

function selectedPrinces(princes, princeKey) {
  if (princeKey === "all") {
    return princes;
  }

  const normalized = princeKey.toLowerCase();
  const match = princes.find((prince) =>
    prince.key === normalized ||
    prince.displayName.toLowerCase() === normalized ||
    prince.questEditorId.toLowerCase() === normalized ||
    prince.reference.toLowerCase() === normalized
  );

  if (!match) {
    const valid = princes.map((prince) => prince.stem).join(", ");
    throw new Error(`Unknown Prince "${princeKey}". Valid stems: ${valid}.`);
  }

  return [match];
}

function genericMarkerForSource(sourceMode) {
  const prefix = "Daedric generic silence probe ignored: eventbus_201_";
  if (sourceMode === "mcm") {
    return `${prefix}mcm_generic_probe`;
  }
  // The physical QASmoke probe activator and the organic path both emit the
  // "generic" source id; "any" stays a prefix match that accepts either.
  if (sourceMode === "qasmoke" || sourceMode === "organic") {
    return `${prefix}generic`;
  }
  return prefix;
}

function genericCheck(sourceMode) {
  return {
    id: "generic-silence",
    reference: "PDV_REFR_Daedric_GenericSilenceProbe_QASmoke",
    required: ["RouteDaedricGenericSilenceProbe complete: 201"],
    optional: [genericMarkerForSource(sourceMode)],
  };
}

function markerMatches(lines, marker) {
  const matches = [];
  for (let index = 0; index < lines.length; index += 1) {
    const matchIndex = lines[index].indexOf(marker);
    if (matchIndex >= 0 && markerBoundaryPasses(lines[index], marker, matchIndex)) {
      matches.push({
        line: index + 1,
        text: lines[index].trim(),
      });
    }
  }
  return {
    marker,
    found: matches.length > 0,
    count: matches.length,
    samples: matches.slice(-3),
  };
}

function markerBoundaryPasses(line, marker, matchIndex) {
  const last = marker[marker.length - 1];
  if (last < "0" || last > "9") {
    return true;
  }
  const next = line[matchIndex + marker.length] || "";
  return next < "0" || next > "9";
}

function checkMarkerGroup(lines, group, strictManager) {
  const required = group.required.map((marker) => markerMatches(lines, marker));
  const optional = group.optional.map((marker) => markerMatches(lines, marker));
  const requiredPass = required.every((marker) => marker.found);
  const optionalPass = optional.length === 0 || optional.every((marker) => marker.found);
  return {
    ...group,
    status: requiredPass && (!strictManager || optionalPass) ? "PASS" : "FAIL",
    required,
    optional,
  };
}

function checkLog(logText, options, princes) {
  const lines = logText.split(/\r?\n/);
  const princeGroups = selectedPrinces(princes, options.prince).map((prince) =>
    checkMarkerGroup(lines, {
      id: prince.key,
      index: prince.index,
      stem: prince.stem,
      displayName: prince.displayName,
      questEditorId: prince.questEditorId,
      reference: prince.reference,
      sourceId: prince.sourceId,
      organicSourceId: prince.organicSourceId,
      required: prince.required,
      optional: [managerMarkerForPrince(prince, options.source)],
    }, options.strictManager)
  );

  const generic = options.includeGeneric ? checkMarkerGroup(lines, genericCheck(options.source), options.strictManager) : null;
  const groups = generic ? [...princeGroups, generic] : princeGroups;

  return {
    status: groups.every((group) => group.status === "PASS") ? "PASS" : "FAIL",
    logPath: options.selfTest ? "<embedded-self-test>" : path.resolve(options.logPath),
    contractPath: CONTRACT_PATH,
    prince: options.prince,
    strictManager: options.strictManager,
    source: options.source,
    includeGeneric: options.includeGeneric,
    note: "Route-marker proof only. Active Effects, MessageBox summary, Prisma display, stack, curse, save/load, and manual feel proof still require the Daedric runbook.",
    princes: princeGroups,
    generic,
  };
}

function embeddedLog(princes) {
  const lines = [];
  for (const prince of princes) {
    lines.push(`[PDV] EventBus: ${prince.required[0]}`);
    lines.push(`[PDV] Manager: ${managerMarkerForPrince(prince, "any")}`);
    lines.push(`[PDV] Manager: ${managerMarkerForPrince(prince, "qasmoke")}`);
    lines.push(`[PDV] Manager: ${managerMarkerForPrince(prince, "mcm")}all`);
    lines.push(`[PDV] Manager: ${managerMarkerForPrince(prince, "organic")}`);
  }
  const generic = genericCheck("any");
  lines.push(`[PDV] EventBus: ${generic.required[0]}`);
  lines.push(`[PDV] Manager: ${genericMarkerForSource("qasmoke")}`);
  lines.push(`[PDV] Manager: ${genericMarkerForSource("mcm")}`);
  return lines.join(os.EOL);
}

function listReport(options, princes) {
  return {
    status: "INFO",
    defaultLog: DEFAULT_LOG,
    contractPath: CONTRACT_PATH,
    prince: options.prince,
    source: options.source,
    includeGeneric: options.includeGeneric,
    princes: selectedPrinces(princes, options.prince).map((prince) => ({
      index: prince.index,
      stem: prince.stem,
      displayName: prince.displayName,
      questEditorId: prince.questEditorId,
      reference: prince.reference,
      sourceId: prince.sourceId,
      organicSourceId: prince.organicSourceId,
      required: prince.required,
      optional: [managerMarkerForPrince(prince, options.source)],
    })),
    generic: options.includeGeneric ? genericCheck(options.source) : null,
  };
}

function printList(report) {
  console.log("PDV Daedric runtime proof markers");
  console.log(`Default log: ${report.defaultLog}`);
  console.log(`Contract: ${report.contractPath}`);
  console.log(`Source mode: ${report.source}`);
  for (const prince of report.princes) {
    console.log("");
    console.log(`${prince.displayName} (${prince.stem}, index ${prince.index})`);
    console.log(`Reference: ${prince.reference}`);
    for (const marker of prince.required) {
      console.log(`  required: ${marker}`);
    }
    for (const marker of prince.optional) {
      console.log(`  optional: ${marker}`);
    }
  }
  if (report.generic) {
    console.log("");
    console.log(`Generic silence (${report.generic.reference})`);
    for (const marker of report.generic.required) {
      console.log(`  required: ${marker}`);
    }
    for (const marker of report.generic.optional) {
      console.log(`  optional: ${marker}`);
    }
  }
}

function sampleSummary(markerReport) {
  if (!markerReport.found) {
    return "missing";
  }
  const last = markerReport.samples[markerReport.samples.length - 1];
  return `line ${last.line}`;
}

function printGroup(group) {
  const label = group.displayName ? `${group.displayName} (${group.stem}, index ${group.index})` : group.id;
  console.log(`- ${group.status} ${label}`);
  console.log(`  reference: ${group.reference}`);
  for (const marker of group.required) {
    console.log(`  required ${sampleSummary(marker)}: ${marker.marker}`);
  }
  for (const marker of group.optional) {
    console.log(`  optional ${sampleSummary(marker)}: ${marker.marker}`);
  }
}

function printCheck(report) {
  console.log(`PDV Daedric runtime proof check: ${report.status}`);
  console.log(`Log: ${report.logPath}`);
  console.log(`Prince: ${report.prince}`);
  console.log(`Strict manager: ${report.strictManager ? "yes" : "no"}`);
  console.log(`Source mode: ${report.source}`);
  console.log(report.note);
  for (const prince of report.princes) {
    printGroup(prince);
  }
  if (report.generic) {
    printGroup(report.generic);
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return 0;
  }

  const princes = loadPrinces();

  if (options.list) {
    const report = listReport(options, princes);
    if (options.json) {
      console.log(JSON.stringify(report, null, 2));
    } else {
      printList(report);
    }
    return 0;
  }

  let logText;
  if (options.selfTest) {
    logText = embeddedLog(princes);
  } else {
    if (!fs.existsSync(options.logPath)) {
      throw new Error(`Papyrus log not found: ${options.logPath}`);
    }
    logText = fs.readFileSync(options.logPath, "utf8");
  }

  const report = checkLog(logText, options, princes);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printCheck(report);
  }
  return report.status === "PASS" ? 0 : 1;
}

try {
  const exitCode = main();
  process.exitCode = exitCode;
} catch (error) {
  if (process.argv.includes("--json")) {
    console.log(JSON.stringify({ status: "FAIL", error: error.message }, null, 2));
  } else {
    console.error(`PDV Daedric runtime proof check failed: ${error.message}`);
    console.error(usage());
  }
  process.exitCode = 2;
}
