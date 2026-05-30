#!/usr/bin/env node
/*
 * Read-only Papyrus log checker for the Phase 20 race proof slices.
 *
 * This validates that the QASmoke proof activators reached the expected
 * EventBus routes. It does not replace the human status, immersion, or
 * negative-hook checks in the Phase 20 runtime runbook.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const DEFAULT_LOG = path.join(
  "C:/Users/Admin",
  "Documents",
  "My Games",
  "Skyrim Special Edition",
  "Logs",
  "Script",
  "Papyrus.0.log",
);

const RACES = [
  {
    key: "altmer",
    label: "Altmer",
    originRace: 3,
    runbook: "references/authoring/PDV_Phase20_AltmerProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show crisis, Lorkhan pressure, and Altmer favor movement.",
    checks: [
      {
        id: "dragonborn-crisis",
        reference: "PDV_REFR_AltmerDragonbornCrisisSignal",
        required: ["RouteAltmerCrisisSource complete: 51 source 1"],
        optional: ["Altmer crisis source accepted:"],
      },
      {
        id: "lorkhan-pressure",
        reference: "PDV_REFR_AltmerLorkhanPressureSignal",
        required: ["RouteAltmerLorkhanPressure complete: 50 tier 3"],
        optional: ["Altmer Lorkhan pressure routed: tier 3"],
      },
      {
        id: "dawn-steadiness",
        reference: "PDV_REFR_AltmerDawnSteadinessSignal",
        required: ["RouteAltmerDawnSteadiness complete: 52"],
        optional: ["Altmer source favor recorded:"],
      },
      {
        id: "orthodox-cost",
        reference: "PDV_REFR_AltmerOrthodoxCostSignal",
        required: ["RouteAltmerOrthodoxCostlyEnforcement complete: 53"],
        optional: ["Altmer source favor recorded:"],
      },
    ],
  },
  {
    key: "argonian",
    label: "Argonian",
    originRace: 7,
    runbook: "references/authoring/PDV_Phase20_ArgonianProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show Hist, People, Void, and bed-of-choice movement.",
    checks: [
      {
        id: "hist-maintenance",
        reference: "PDV_REFR_ArgonianHistMaintenanceSignal",
        required: ["RouteArgonianHistMaintenance complete: 60"],
        optional: ["Argonian Hist maintenance routed"],
      },
      {
        id: "people-support",
        reference: "PDV_REFR_ArgonianPeopleSupportSignal",
        required: ["RouteArgonianPeopleSupport complete: 61"],
        optional: ["Argonian People support routed"],
      },
      {
        id: "void-signal",
        reference: "PDV_REFR_ArgonianVoidSignal",
        required: ["RouteArgonianVoidSignal complete: 62"],
        optional: ["Argonian Void signal routed"],
      },
      {
        id: "bed-of-choice",
        reference: "PDV_REFR_ArgonianBedOfChoiceSignal",
        required: ["RouteArgonianBedOfChoice complete: 63"],
        optional: ["Argonian bed-of-choice return routed"],
      },
    ],
  },
  {
    key: "orc",
    label: "Orc",
    originRace: 8,
    runbook: "references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show Stronghold, City, Legion/Exile, and self-made community movement.",
    checks: [
      {
        id: "stronghold-forge",
        reference: "PDV_REFR_OrcStrongholdForgeSignal",
        required: ["RouteOrcStrongholdForge complete: 70"],
        optional: ["Orc Stronghold forge routed"],
      },
      {
        id: "city-dignity",
        reference: "PDV_REFR_OrcCityDignitySignal",
        required: ["RouteOrcCityDignity complete: 71"],
        optional: ["Orc City dignity routed"],
      },
      {
        id: "legion-service",
        reference: "PDV_REFR_OrcLegionServiceSignal",
        required: ["RouteOrcLegionService complete: 72"],
        optional: ["Orc Legion or exile service routed"],
      },
      {
        id: "self-made-community",
        reference: "PDV_REFR_OrcSelfMadeCommunitySignal",
        required: ["RouteOrcSelfMadeCommunity complete: 73"],
        optional: ["Orc self-made community routed"],
      },
    ],
  },
  {
    key: "redguard",
    label: "Redguard",
    originRace: 9,
    runbook: "references/authoring/PDV_Phase20_RedguardProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show Crown, Forebear, Ash'abah, and Far Shores token movement.",
    checks: [
      {
        id: "crown-tomb-respect",
        reference: "PDV_REFR_RedguardCrownTombRespectSignal",
        required: ["RouteRedguardCrownTombRespect complete: 80"],
        optional: ["Redguard Crown tomb respect routed"],
      },
      {
        id: "forebear-road-passage",
        reference: "PDV_REFR_RedguardForebearRoadSignal",
        required: ["RouteRedguardForebearRoadPassage complete: 81"],
        optional: ["Redguard Forebear road passage routed"],
      },
      {
        id: "ashabah-death-duty",
        reference: "PDV_REFR_RedguardAshAbahDeathDutySignal",
        required: ["RouteRedguardAshAbahDeathDuty complete: 82"],
        optional: ["Redguard AshAbah death duty routed"],
      },
      {
        id: "far-shores-token",
        reference: "PDV_REFR_RedguardFarShoresTokenSignal",
        required: ["RouteRedguardFarShoresToken complete: 83"],
        optional: ["Redguard Far Shores token routed"],
      },
    ],
  },
  {
    key: "khajiit",
    label: "Khajiit",
    originRace: 6,
    runbook: "references/authoring/PDV_Phase20_KhajiitProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show moon observance, road-home cadence, and focus weights.",
    checks: [
      {
        id: "moon-observance",
        reference: "PDV_REFR_KhajiitMoonObservanceSignal",
        required: ["RouteKhajiitMoonObservance complete: 10 phase 1"],
        optional: ["Khajiit moon observance routed"],
      },
      {
        id: "road-home-anchor-one",
        reference: "PDV_REFR_KhajiitRoadHomeAnchorOneSignal",
        required: ["RouteKhajiitRoadHomeAnchor complete: 33 anchor 1"],
        optional: ["Khajiit road-home cadence routed"],
      },
      {
        id: "road-home-anchor-two",
        reference: "PDV_REFR_KhajiitRoadHomeAnchorTwoSignal",
        required: ["RouteKhajiitRoadHomeAnchor complete: 33 anchor 2"],
        optional: ["Khajiit road-home cadence routed"],
      },
      {
        id: "baan-dar-road-trick",
        reference: "PDV_REFR_KhajiitBaanDarRoadTrickSignal",
        required: ["RouteKhajiitBaanDarRoadTrick complete: 90"],
        optional: ["Khajiit Baan Dar road trick routed"],
      },
      {
        id: "rajhin-elegant-theft",
        reference: "PDV_REFR_KhajiitRajhinElegantTheftSignal",
        required: ["RouteKhajiitRajhinElegantTheft complete: 91"],
        optional: ["Khajiit Rajhin elegant theft routed"],
      },
      {
        id: "alkosh-dragon-order",
        reference: "PDV_REFR_KhajiitAlkoshDragonOrderSignal",
        required: ["RouteKhajiitAlkoshDragonOrder complete: 92"],
        optional: ["Khajiit Alkosh dragon order routed"],
      },
    ],
  },
  {
    key: "bosmer",
    label: "Bosmer",
    originRace: 4,
    runbook: "references/authoring/PDV_Phase20_BosmerProofPlacement_Runbook.md",
    statusSurface: "Survey/status should show per-path favor counters for Old Contract, Living Story, Exchange, and Bandit Road.",
    checks: [
      {
        id: "old-contract-proper-hunt",
        reference: "PDV_REFR_BosmerOldContractProperHuntSignal",
        required: ["RouteBosmerOldContractProperHunt complete: 100"],
        optional: ["Bosmer favor OldContract.ProperHunt recorded"],
      },
      {
        id: "old-contract-forest-kept",
        reference: "PDV_REFR_BosmerOldContractForestKeptSignal",
        required: ["RouteBosmerOldContractForestKept complete: 101"],
        optional: ["Bosmer favor OldContract.ForestKept recorded"],
      },
      {
        id: "living-story-community-kept",
        reference: "PDV_REFR_BosmerLivingStoryCommunityKeptSignal",
        required: ["RouteBosmerLivingStoryCommunityKept complete: 102"],
        optional: ["Bosmer favor LivingStory.CommunityKept recorded"],
      },
      {
        id: "living-story-nature-site",
        reference: "PDV_REFR_BosmerLivingStoryNatureSiteSignal",
        required: ["RouteBosmerLivingStoryNatureSite complete: 103"],
        optional: ["Bosmer favor LivingStory.NatureSite recorded"],
      },
      {
        id: "exchange-debt-settled",
        reference: "PDV_REFR_BosmerExchangeDebtSettledSignal",
        required: ["RouteBosmerExchangeDebtSettled complete: 104"],
        optional: ["Bosmer favor Exchange.DebtSettled recorded"],
      },
      {
        id: "exchange-proportionate-vengeance",
        reference: "PDV_REFR_BosmerExchangeProportionateVengeanceSignal",
        required: ["RouteBosmerExchangeProportionateVengeance complete: 105"],
        optional: ["Bosmer favor Exchange.ProportionateVengeance recorded"],
      },
      {
        id: "bandit-road-road-life",
        reference: "PDV_REFR_BosmerBanditRoadRoadLifeSignal",
        required: ["RouteBosmerBanditRoadRoadLife complete: 106"],
        optional: ["Bosmer favor BanditRoad.RoadLife recorded"],
      },
      {
        id: "bandit-road-reversal",
        reference: "PDV_REFR_BosmerBanditRoadReversalSignal",
        required: ["RouteBosmerBanditRoadReversal complete: 107"],
        optional: ["Bosmer favor BanditRoad.Reversal recorded"],
      },
    ],
  },
];

const RACE_KEYS = new Set(RACES.map((race) => race.key));

function usage() {
  return [
    "Usage: node .\\tools\\pdv_phase20_runtime_check.mjs [options]",
    "",
    "Options:",
    "  --race <all|altmer|argonian|orc|redguard|khajiit|bosmer>",
    "  --log <path>          Papyrus log path. Defaults to the Skyrim SE Papyrus.0.log.",
    "  --strict-manager     Also fail when optional manager/status traces are missing.",
    "  --list               Print the expected route markers and exit.",
    "  --self-test          Check an embedded synthetic log and exit.",
    "  --json               Emit JSON.",
    "  --help               Show this help.",
  ].join(os.EOL);
}

function parseArgs(argv) {
  const options = {
    race: "all",
    logPath: DEFAULT_LOG,
    strictManager: false,
    list: false,
    selfTest: false,
    json: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--race") {
      index += 1;
      options.race = normalizeRace(argv[index]);
    } else if (arg === "--log") {
      index += 1;
      options.logPath = argv[index];
      if (!options.logPath) {
        throw new Error("--log requires a path.");
      }
    } else if (arg === "--strict-manager") {
      options.strictManager = true;
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

function normalizeRace(value) {
  const normalized = String(value || "").toLowerCase();
  if (normalized === "all") {
    return "all";
  }
  if (!RACE_KEYS.has(normalized)) {
    throw new Error(`Unknown race "${value}". Use --list for valid races.`);
  }
  return normalized;
}

function selectedRaces(raceKey) {
  if (raceKey === "all") {
    return RACES;
  }
  return RACES.filter((race) => race.key === raceKey);
}

function markerMatches(lines, marker) {
  const matches = [];
  for (let index = 0; index < lines.length; index += 1) {
    if (lines[index].includes(marker)) {
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

function checkLog(logText, options) {
  const lines = logText.split(/\r?\n/);
  const races = selectedRaces(options.race).map((race) => {
    const checks = race.checks.map((check) => {
      const required = check.required.map((marker) => markerMatches(lines, marker));
      const optional = check.optional.map((marker) => markerMatches(lines, marker));
      const requiredPass = required.every((marker) => marker.found);
      const managerPass = optional.length === 0 || optional.every((marker) => marker.found);
      return {
        id: check.id,
        reference: check.reference,
        status: requiredPass && (!options.strictManager || managerPass) ? "PASS" : "FAIL",
        required,
        optional,
      };
    });
    const missingRequired = checks.flatMap((check) =>
      check.required.filter((marker) => !marker.found).map((marker) => ({
        check: check.id,
        marker: marker.marker,
      })),
    );
    const missingOptional = checks.flatMap((check) =>
      check.optional.filter((marker) => !marker.found).map((marker) => ({
        check: check.id,
        marker: marker.marker,
      })),
    );
    return {
      key: race.key,
      label: race.label,
      originRace: race.originRace,
      runbook: race.runbook,
      statusSurface: race.statusSurface,
      status: missingRequired.length === 0 && (!options.strictManager || missingOptional.length === 0) ? "PASS" : "FAIL",
      missingRequired,
      missingOptional,
      checks,
    };
  });

  return {
    status: races.every((race) => race.status === "PASS") ? "PASS" : "FAIL",
    logPath: options.selfTest ? "<embedded-self-test>" : path.resolve(options.logPath),
    race: options.race,
    strictManager: options.strictManager,
    note: "Route-marker proof only. Survey/status, immersion feel, negative hooks, and anti-farm behavior still require the runtime runbook.",
    races,
  };
}

function embeddedLog() {
  const lines = [];
  for (const race of RACES) {
    lines.push(`[PDV] Test: ${race.label}`);
    for (const check of race.checks) {
      for (const marker of check.required) {
        lines.push(`[PDV] EventBus: ${marker}`);
      }
      for (const marker of check.optional) {
        lines.push(`[PDV] Manager: ${marker}`);
      }
    }
  }
  return lines.join(os.EOL);
}

function listReport(options) {
  return {
    status: "INFO",
    defaultLog: DEFAULT_LOG,
    races: selectedRaces(options.race).map((race) => ({
      key: race.key,
      label: race.label,
      originRace: race.originRace,
      runbook: race.runbook,
      checks: race.checks.map((check) => ({
        id: check.id,
        reference: check.reference,
        required: check.required,
        optional: check.optional,
      })),
    })),
  };
}

function printList(report) {
  console.log("PDV Phase 20 runtime proof markers");
  console.log(`Default log: ${report.defaultLog}`);
  for (const race of report.races) {
    console.log("");
    console.log(`${race.label} (origin ${race.originRace})`);
    console.log(`Runbook: ${race.runbook}`);
    for (const check of race.checks) {
      console.log(`- ${check.id} via ${check.reference}`);
      for (const marker of check.required) {
        console.log(`  required: ${marker}`);
      }
      for (const marker of check.optional) {
        console.log(`  optional: ${marker}`);
      }
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

function printCheck(report) {
  console.log(`PDV Phase 20 runtime proof check: ${report.status}`);
  console.log(`Log: ${report.logPath}`);
  console.log(`Race: ${report.race}`);
  console.log(`Strict manager: ${report.strictManager ? "yes" : "no"}`);
  console.log(report.note);

  for (const race of report.races) {
    console.log("");
    console.log(`${race.label} (origin ${race.originRace}): ${race.status}`);
    console.log(`Runbook: ${race.runbook}`);
    console.log(`Status check: ${race.statusSurface}`);
    for (const check of race.checks) {
      console.log(`- ${check.status} ${check.id} (${check.reference})`);
      for (const marker of check.required) {
        console.log(`  required ${sampleSummary(marker)}: ${marker.marker}`);
      }
      for (const marker of check.optional) {
        console.log(`  optional ${sampleSummary(marker)}: ${marker.marker}`);
      }
    }
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    console.log(usage());
    return 0;
  }

  if (options.list) {
    const report = listReport(options);
    if (options.json) {
      console.log(JSON.stringify(report, null, 2));
    } else {
      printList(report);
    }
    return 0;
  }

  let logText;
  if (options.selfTest) {
    logText = embeddedLog();
  } else {
    if (!fs.existsSync(options.logPath)) {
      throw new Error(`Papyrus log not found: ${options.logPath}`);
    }
    logText = fs.readFileSync(options.logPath, "utf8");
  }

  const report = checkLog(logText, options);
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
  const json = process.argv.includes("--json");
  if (json) {
    console.log(JSON.stringify({ status: "FAIL", error: error.message }, null, 2));
  } else {
    console.error(`PDV Phase 20 runtime proof check failed: ${error.message}`);
    console.error(usage());
  }
  process.exitCode = 2;
}
