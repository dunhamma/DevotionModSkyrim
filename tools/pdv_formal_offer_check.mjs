#!/usr/bin/env node
/*
 * Read-only formal deity-offer verifier.
 *
 * This checks the post-Kyne formal-offer scale-out without owning the writing:
 * - source eligibility and accept/decline/refuse flow in the live manager
 * - explicit no-offer exclusions for emergent/setup races
 * - formal-offer MESG/property readback through the existing record helper
 */

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SPEC = path.join(PROJECT_ROOT, "references", "authoring", "PDV_FormalOffer_RecordWave.spec.json");
const DEFAULT_SOURCE = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV__ManagerQuest.psc";
const DEFAULT_SOURCE_DIR = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";
const DEFAULT_ESP = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Devotion.esp";
const AUTHOR_PROJECT = path.join(PROJECT_ROOT, "tools", "pdv-phase20-race-author", "PdvPhase20RaceAuthor.csproj");

// Curse-driven severance must remain recoverable and must not masquerade as the
// player's one-time "Refuse" choice. Add a function here only with a cited design
// note explaining why that exact curse handler is allowed to clear active patronage.
const RECOVERABLE_CURSE_SEVER_ALLOWLIST = new Set([]);

const EXPECTED_OFFER_BUTTONS = ["Accept", "Not yet", "Refuse"];

const offerRoster = {
  nord: ["PDV_Msg_Nord_Kyne_Offer"],
  dunmer: [
    "PDV_Msg_Dunmer_Azura_Offer",
    "PDV_Msg_Dunmer_Boethiah_Offer",
    "PDV_Msg_Dunmer_Mephala_Offer"
  ],
  altmer: [
    "PDV_Msg_Altmer_AuriEl_Offer",
    "PDV_Msg_Altmer_Magnus_Offer",
    "PDV_Msg_Altmer_Xarxes_Offer"
  ],
  imperial: [
    "PDV_Msg_Imperial_Akatosh_Offer",
    "PDV_Msg_Imperial_Arkay_Offer",
    "PDV_Msg_Imperial_Dibella_Offer",
    "PDV_Msg_Imperial_Julianos_Offer",
    "PDV_Msg_Imperial_Kynareth_Offer",
    "PDV_Msg_Imperial_Mara_Offer",
    "PDV_Msg_Imperial_Stendarr_Offer",
    "PDV_Msg_Imperial_Talos_Offer",
    "PDV_Msg_Imperial_Zenithar_Offer"
  ],
  redguard: [
    "PDV_Msg_Redguard_Tuwhacca_Offer",
    "PDV_Msg_Redguard_Leki_Offer",
    "PDV_Msg_Redguard_HoonDing_Offer"
  ]
};

const expectedResponseProperties = [
  "PDV_Msg_Dunmer_OfferResponse_Accept",
  "PDV_Msg_Dunmer_OfferResponse_NotYet",
  "PDV_Msg_Dunmer_OfferResponse_Refuse",
  "PDV_Msg_Altmer_OfferResponse_Accept",
  "PDV_Msg_Altmer_OfferResponse_NotYet",
  "PDV_Msg_Altmer_OfferResponse_Refuse",
  "PDV_Msg_Imperial_OfferResponse_Accept",
  "PDV_Msg_Imperial_OfferResponse_NotYet",
  "PDV_Msg_Imperial_OfferResponse_Refuse",
  "PDV_Msg_Redguard_OfferResponse_Accept",
  "PDV_Msg_Redguard_OfferResponse_NotYet",
  "PDV_Msg_Redguard_OfferResponse_Refuse"
];

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  const findings = [];
  const add = (status, check, detail, filePath = null) => findings.push({ status, check, detail, path: filePath });
  const pass = (check, detail, filePath = null) => add("PASS", check, detail, filePath);
  const warn = (check, detail, filePath = null) => add("WARN", check, detail, filePath);
  const fail = (check, detail, filePath = null) => add("FAIL", check, detail, filePath);

  const specPath = path.resolve(PROJECT_ROOT, args.spec || DEFAULT_SPEC);
  const sourcePath = path.resolve(args.source || DEFAULT_SOURCE);
  const espPath = path.resolve(args.esp || DEFAULT_ESP);

  let spec = null;
  if (!fs.existsSync(specPath)) {
    fail("Formal offer spec", "Formal-offer record spec is missing.", specPath);
  } else {
    try {
      spec = JSON.parse(readText(specPath));
      pass("Formal offer spec", "Formal-offer record spec parses.", specPath);
    } catch (error) {
      fail("Formal offer spec", `Formal-offer record spec does not parse: ${error.message}`, specPath);
    }
  }

  if (spec) {
    verifySpecShape(spec, specPath, pass, fail);
  }

  if (!fs.existsSync(sourcePath)) {
    fail("Formal offer source", "Live PDV__ManagerQuest.psc is missing.", sourcePath);
  } else {
    const sourceText = readText(sourcePath);
    verifySourceContract(sourceText, sourcePath, pass, fail);
  }

  verifyCurseCommitmentBoundaries(path.resolve(args.sourceDir || DEFAULT_SOURCE_DIR), pass, fail, warn);

  if (!args.sourceOnly && spec) {
    verifyEspReadback(specPath, espPath, pass, fail, warn);
  }

  const failCount = findings.filter((finding) => finding.status === "FAIL").length;
  const warnCount = findings.filter((finding) => finding.status === "WARN").length;
  const passCount = findings.filter((finding) => finding.status === "PASS").length;
  const summary = {
    status: failCount === 0 ? "PASS" : "FAIL",
    passCount,
    warnCount,
    failCount,
    spec: toDisplayPath(specPath),
    source: toDisplayPath(sourcePath),
    esp: args.sourceOnly ? null : toDisplayPath(espPath),
    findings
  };

  if (args.json) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    printTextSummary(summary);
  }

  process.exit(failCount === 0 ? 0 : 1);
}

function parseArgs(argv) {
  const args = {
    json: false,
    sourceOnly: false,
    spec: null,
    source: null,
    sourceDir: null,
    esp: null
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--source-only") {
      args.sourceOnly = true;
    } else if (arg === "--spec") {
      args.spec = requireNext(argv, ++index, "--spec");
    } else if (arg.startsWith("--spec=")) {
      args.spec = arg.slice("--spec=".length);
    } else if (arg === "--source") {
      args.source = requireNext(argv, ++index, "--source");
    } else if (arg.startsWith("--source=")) {
      args.source = arg.slice("--source=".length);
    } else if (arg === "--source-dir") {
      args.sourceDir = requireNext(argv, ++index, "--source-dir");
    } else if (arg.startsWith("--source-dir=")) {
      args.sourceDir = arg.slice("--source-dir=".length);
    } else if (arg === "--esp") {
      args.esp = requireNext(argv, ++index, "--esp");
    } else if (arg.startsWith("--esp=")) {
      args.esp = arg.slice("--esp=".length);
    } else if (arg === "--help" || arg === "-h") {
      usage(0);
    } else {
      usage(1, `Unknown argument: ${arg}`);
    }
  }

  return args;
}

function requireNext(argv, index, name) {
  if (index >= argv.length || argv[index].startsWith("-")) {
    usage(1, `${name} requires a value.`);
  }
  return argv[index];
}

function usage(exitCode, errorMessage = null) {
  if (errorMessage) {
    console.error(errorMessage);
    console.error("");
  }
  console.log([
    "Usage:",
    "  node .\\tools\\pdv_formal_offer_check.mjs [--json] [--source-only] [--spec <path>] [--source <path>] [--source-dir <path>] [--esp <path>]",
    "",
    "Notes:",
    "  - Read-only.",
    "  - Checks source formal-offer flow and delegates ESP/property readback to pdv-phase20-race-author --check-rewards.",
    "  - Writing quality belongs to references/authoring/PDV_FormalOfferWriting_Handoff.md."
  ].join("\n"));
  process.exit(exitCode);
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8").replace(/\r\n/g, "\n");
}

function verifySpecShape(spec, specPath, pass, fail) {
  const messageRecords = spec.messageRecords || [];
  const editorIds = new Set(messageRecords.map((record) => record.editorId));
  const expectedSpecIds = [
    ...Object.values(offerRoster).flat(),
    ...expectedResponseProperties
  ].filter((editorId) => !editorId.startsWith("PDV_Msg_Nord_"));

  if (messageRecords.length === 30) {
    pass("Formal offer spec shape", "Spec declares 30 post-Kyne message records.", specPath);
  } else {
    fail("Formal offer spec shape", `Expected 30 post-Kyne message records, found ${messageRecords.length}.`, specPath);
  }

  for (const editorId of expectedSpecIds) {
    if (editorIds.has(editorId)) {
      pass("Formal offer spec coverage", `Spec includes ${editorId}.`, specPath);
    } else {
      fail("Formal offer spec coverage", `Spec is missing ${editorId}.`, specPath);
    }
  }

  for (const record of messageRecords) {
    if (!record.editorId || !record.title || !record.body) {
      fail("Formal offer spec record", `Record is missing editorId/title/body: ${JSON.stringify(record)}`, specPath);
      continue;
    }

    if (/[^\x00-\x7F]/.test(`${record.title}${record.body}${(record.buttons || []).join("")}`)) {
      fail("Formal offer spec ASCII", `${record.editorId} contains non-ASCII text.`, specPath);
    } else {
      pass("Formal offer spec ASCII", `${record.editorId} is ASCII-only.`, specPath);
    }

    if (record.kind === "messageBox" || record.messageBox === true) {
      const buttons = record.buttons || [];
      if (JSON.stringify(buttons) === JSON.stringify(EXPECTED_OFFER_BUTTONS)) {
        pass("Formal offer buttons", `${record.editorId} uses Accept / Not yet / Refuse.`, specPath);
      } else {
        fail("Formal offer buttons", `${record.editorId} has unexpected buttons: ${JSON.stringify(buttons)}.`, specPath);
      }
    }
  }

  const forbiddenSpecTokens = [
    "PDV_Msg_Altmer_Trinimac_Offer",
    "PDV_Msg_Altmer_Syrabane_Offer",
    "PDV_Msg_Redguard_Satakal_Offer",
    "PDV_Msg_Redguard_Ruptga_Offer",
    "PDV_Msg_Redguard_Tava_Offer",
    "PDV_Msg_Redguard_Onsi_Offer",
    "PDV_Msg_Redguard_Sep_Offer",
    "PDV_Msg_Bosmer_",
    "PDV_Msg_Orc_",
    "PDV_Msg_Khajiit_",
    "PDV_Msg_Breton_",
    "PDV_Msg_Argonian_"
  ];
  const specText = JSON.stringify(spec);
  for (const token of forbiddenSpecTokens) {
    if (specText.includes(token)) {
      fail("Formal offer no-offer exclusion", `Spec must not include ${token}.`, specPath);
    } else {
      pass("Formal offer no-offer exclusion", `Spec excludes ${token}.`, specPath);
    }
  }
}

function verifySourceContract(sourceText, sourcePath, pass, fail) {
  const sourceOfferIds = Object.values(offerRoster).flat();
  const allExpectedProperties = [
    ...sourceOfferIds,
    ...expectedResponseProperties
  ];

  for (const editorId of allExpectedProperties) {
    if (sourceText.includes(`Message Property ${editorId} Auto`)) {
      pass("Formal offer source property", `Manager declares ${editorId}.`, sourcePath);
    } else {
      fail("Formal offer source property", `Manager does not declare ${editorId}.`, sourcePath);
    }
  }

  const requiredSourceSnippets = [
    "Function ShowFormalCommitmentOffer(PDV_DeityBase deity)",
    "Message offerMessage = GetFormalCommitmentOfferMessage(deity)",
    "DispatchDiegeticCue(\"offer\", deity.DeityName, \"present\", deity, \"revelation\")",
    "Int choice = offerMessage.Show()",
    "if choice == 0",
    "DebugAcceptPendingCommitment()",
    "DispatchDiegeticCue(\"offer\", pendingDeity.DeityName, \"accept\", pendingDeity, \"revelation\")",
    "elseIf choice == 1",
    "DebugDeclinePendingCommitment()",
    "elseIf choice == 2",
    "DebugRefusePendingCommitment()",
    "Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)",
    "return GetNordFormalCommitmentOfferMessage(deity)",
    "return GetImperialFormalCommitmentOfferMessage(deity)",
    "return GetDunmerFormalCommitmentOfferMessage(deity)",
    "return GetAltmerFormalCommitmentOfferMessage(deity)",
    "return GetRedguardFormalCommitmentOfferMessage(deity)",
    "Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)",
    "return IsNordOfferEligibleDeity(deity) || IsImperialOfferEligibleDeity(deity) || IsDunmerOfferEligibleDeity(deity) || IsAltmerOfferEligibleDeity(deity) || IsRedguardOfferEligibleDeity(deity)",
    "Bool Function IsImperialTalosOfferAllowed()",
    "PDV_ConcordatStandingTrack.GetValue() <= 50",
    "Bool Function ShouldSuppressImperialTalosTierSurface(PDV_DeityBase deity)",
    "Tier reach surface suppressed for Imperial Talos while Concordat blocks offers.",
    "ApplyConcordatPressure ignored for non-Imperial origin.",
    "Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction, PDV_DeityBase deity, String toneOverride = \"\")"
  ];

  for (const snippet of requiredSourceSnippets) {
    if (sourceText.includes(snippet)) {
      pass("Formal offer source flow", `Manager contains: ${snippet}`, sourcePath);
    } else {
      fail("Formal offer source flow", `Manager is missing: ${snippet}`, sourcePath);
    }
  }

  const helperExpectations = [
    ["IsNordOfferEligibleDeity", ["PDV_Kyne"]],
    ["IsDunmerOfferEligibleDeity", ["PDV_Azura", "PDV_Boethiah", "PDV_Mephala"]],
    ["IsAltmerOfferEligibleDeity", ["PDV_AuriEl", "PDV_Magnus", "PDV_Xarxes"]],
    ["IsImperialOfferEligibleDeity", ["PDV_Akatosh", "PDV_Mara", "PDV_Arkay", "PDV_Stendarr", "PDV_Zenithar", "PDV_Dibella", "PDV_Julianos", "PDV_Kynareth", "PDV_Talos"]],
    ["IsRedguardOfferEligibleDeity", ["PDV_Tuwhacca", "PDV_HoonDing", "PDV_Leki"]]
  ];
  for (const [helperName, deityProperties] of helperExpectations) {
    const body = extractFunctionBody(sourceText, helperName);
    if (!body) {
      fail("Formal offer eligibility helper", `${helperName} is missing.`, sourcePath);
      continue;
    }
    for (const propertyName of deityProperties) {
      if (body.includes(propertyName)) {
        pass("Formal offer eligibility helper", `${helperName} references ${propertyName}.`, sourcePath);
      } else {
        fail("Formal offer eligibility helper", `${helperName} does not reference ${propertyName}.`, sourcePath);
      }
    }
  }

  const forbiddenSourceSnippets = [
    "GetBosmerFormalCommitmentOfferMessage",
    "GetKhajiitFormalCommitmentOfferMessage",
    "GetOrcFormalCommitmentOfferMessage",
    "GetBretonFormalCommitmentOfferMessage",
    "GetArgonianFormalCommitmentOfferMessage",
    "IsBosmerOfferEligibleDeity",
    "IsKhajiitOfferEligibleDeity",
    "IsOrcOfferEligibleDeity",
    "IsBretonOfferEligibleDeity",
    "IsArgonianOfferEligibleDeity",
    "PDV_Msg_Altmer_Trinimac_Offer",
    "PDV_Msg_Altmer_Syrabane_Offer",
    "PDV_Msg_Redguard_Satakal_Offer",
    "PDV_Msg_Redguard_Ruptga_Offer",
    "PDV_Msg_Redguard_Tava_Offer",
    "PDV_Msg_Redguard_Onsi_Offer",
    "PDV_Msg_Redguard_Sep_Offer"
  ];
  for (const snippet of forbiddenSourceSnippets) {
    if (sourceText.includes(snippet)) {
      fail("Formal offer source exclusion", `Manager must not contain ${snippet}.`, sourcePath);
    } else {
      pass("Formal offer source exclusion", `Manager excludes ${snippet}.`, sourcePath);
    }
  }

  const quietEmergenceSnippets = [
    "SurfaceTransition(\"emergence\", focusDeity.DeityName, \"onset\", focusDeity.DeityIndex, \"revelation\")",
    "PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)",
    "SurfaceTransition(\"emergence\", traditionDeity.DeityName, \"onset\", traditionDeity.DeityIndex, \"revelation\")",
    "PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)",
    "SurfaceTransition(\"reorientation\", GetOrcLifeModeLabel(), \"shift\", deityIndex, \"turning\")",
    "SurfaceTransition(\"reorientation\", GetBosmerPathLabel(), \"shift\", deity.DeityIndex, \"turning\")",
    "SurfaceTransition(\"reorientation\", GetRedguardSectLabel(), \"shift\", -1, \"turning\")"
  ];
  for (const snippet of quietEmergenceSnippets) {
    if (sourceText.includes(snippet)) {
      pass("Quiet-emergence source cue", `Manager contains: ${snippet}`, sourcePath);
    } else {
      fail("Quiet-emergence source cue", `Manager is missing: ${snippet}`, sourcePath);
    }
  }
}

function verifyCurseCommitmentBoundaries(sourceDir, pass, fail, warn) {
  if (!fs.existsSync(sourceDir)) {
    fail("Curse commitment boundary", "Live source directory is missing.", sourceDir);
    return;
  }

  const pscFiles = fs
    .readdirSync(sourceDir)
    .filter((name) => name.toLowerCase().endsWith(".psc"));
  let handlerCount = 0;
  let refusedWrites = 0;
  let patronTeardowns = 0;

  for (const fileName of pscFiles) {
    const filePath = path.join(sourceDir, fileName);
    const sourceText = readText(filePath);
    for (const block of extractFunctionBlocks(sourceText)) {
      if (!isCurseTransitionHandler(block.name)) {
        continue;
      }

      handlerCount += 1;
      const label = `${fileName}::${block.name}`;
      if (block.body.includes("\"PDV.Commitment.Refused\"")) {
        refusedWrites += 1;
        fail("Curse commitment boundary", `${label} writes PDV.Commitment.Refused; curse loss must not become a permanent refusal.`, filePath);
      }

      if (block.body.includes("SetActiveDeity(None)")) {
        if (RECOVERABLE_CURSE_SEVER_ALLOWLIST.has(label)) {
          warn("Curse recoverable sever allowlist", `${label} tears down the active deity under an explicit allowlist entry.`, filePath);
        } else {
          patronTeardowns += 1;
          fail("Curse commitment boundary", `${label} calls SetActiveDeity(None); add an explicit recoverable-sever design entry before allowing curse-driven patron teardown.`, filePath);
        }
      }
    }
  }

  if (handlerCount === 0) {
    fail("Curse commitment boundary", "No curse transition handlers were found to audit.", sourceDir);
    return;
  }

  if (refusedWrites === 0) {
    pass("Curse commitment boundary", `Audited ${handlerCount} curse transition handler(s); none write PDV.Commitment.Refused.`, sourceDir);
  }
  if (patronTeardowns === 0) {
    pass("Curse commitment boundary", `Audited ${handlerCount} curse transition handler(s); none call SetActiveDeity(None) outside the recoverable-sever allowlist.`, sourceDir);
  }
}

function extractFunctionBlocks(sourceText) {
  const blocks = [];
  const pattern = /(?:[A-Za-z_][\w]*\s+)?Function\s+(\w+)\b[\s\S]*?\nEndFunction\b/gi;
  let match;
  while ((match = pattern.exec(sourceText))) {
    blocks.push({ name: match[1], body: match[0] });
  }
  return blocks;
}

function isCurseTransitionHandler(functionName) {
  return functionName === "HandleCurseTransition"
    || functionName === "HandleCurseStateTransition"
    || functionName === "HandleCurseStateRefresh"
    || functionName === "ApplyCurseRaceHandlers"
    || /^Apply[A-Za-z]+CurseHandlers$/.test(functionName);
}

function extractFunctionBody(sourceText, functionName) {
  const pattern = new RegExp(`(?:Bool|Message|PDV_DeityBase|Function)\\s+Function\\s+${escapeRegExp(functionName)}\\b|(?:Bool|Message|PDV_DeityBase)\\s+Function\\s+${escapeRegExp(functionName)}\\b`);
  const match = pattern.exec(sourceText);
  if (!match) {
    return "";
  }
  const start = match.index;
  const rest = sourceText.slice(start);
  const endMatch = /\nEndFunction\b/.exec(rest);
  if (!endMatch) {
    return rest;
  }
  return rest.slice(0, endMatch.index + "\nEndFunction".length);
}

function verifyEspReadback(specPath, espPath, pass, fail, warn) {
  if (!fs.existsSync(AUTHOR_PROJECT)) {
    fail("Formal offer ESP readback", "pdv-phase20-race-author project is missing.", AUTHOR_PROJECT);
    return;
  }
  if (!fs.existsSync(espPath)) {
    fail("Formal offer ESP readback", "Devotion.esp is missing.", espPath);
    return;
  }

  const result = spawnSync("dotnet", [
    "run",
    "--project",
    AUTHOR_PROJECT,
    "-c",
    "Release",
    "--",
    "--check-rewards",
    "--rewards-spec",
    specPath,
    "--esp",
    espPath
  ], {
    cwd: PROJECT_ROOT,
    encoding: "utf8",
    maxBuffer: 32 * 1024 * 1024
  });

  const output = `${result.stdout || ""}${result.stderr || ""}`.trim();
  if (result.error) {
    fail("Formal offer ESP readback", `Could not run pdv-phase20-race-author: ${result.error.message}`, espPath);
  } else if (result.status === 0) {
    pass("Formal offer ESP readback", "pdv-phase20-race-author --check-rewards passed for formal-offer spec.", espPath);
  } else {
    fail("Formal offer ESP readback", `pdv-phase20-race-author --check-rewards failed: ${output}`, espPath);
  }

  if (result.status !== 0 && output && output.length > 0) {
    warn("Formal offer ESP readback output", firstLines(output, 12), espPath);
  }
}

function firstLines(text, limit) {
  return text.split(/\r?\n/).slice(0, limit).join(" | ");
}

function printTextSummary(summary) {
  console.log(`pdv_formal_offer_check: ${summary.status} (PASS=${summary.passCount} WARN=${summary.warnCount} FAIL=${summary.failCount})`);
  for (const finding of summary.findings) {
    if (finding.status !== "PASS") {
      console.log(`[${finding.status}] ${finding.check}: ${finding.detail}`);
    }
  }
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function toDisplayPath(filePath) {
  return path.relative(PROJECT_ROOT, filePath).replace(/\\/g, "/");
}
