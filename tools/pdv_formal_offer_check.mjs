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
import { fileURLToPath } from "node:url";
import { familySourceText, stripQualifiers } from "./lib/pdv_symbol_home.mjs";
import { extractHousecarlText, openHousecarl } from "./lib/pdv_housecarl_stdio.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_SPEC = path.join(PROJECT_ROOT, "references", "authoring", "PDV_FormalOffer_RecordWave.spec.json");
const DEFAULT_DEVOTION_ROOT = process.env.PDV_DEVOTION_ROOT || "D:/Wabbajack/modlists/Anvil/mods/Devotion-V3Dev";
const DEFAULT_SOURCE = path.join(DEFAULT_DEVOTION_ROOT, "Scripts", "Source", "PDV__ManagerQuest.psc");
const DEFAULT_SOURCE_DIR = path.join(DEFAULT_DEVOTION_ROOT, "Scripts", "Source");
const DEFAULT_ESP = path.join(DEFAULT_DEVOTION_ROOT, "Devotion.esp");

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
    "PDV_Msg_Altmer_Xarxes_Offer",
    "PDV_Msg_Altmer_Trinimac_Offer",
    "PDV_Msg_Altmer_Syrabane_Offer"
  ],
  breton: [
    "PDV_Msg_Breton_Akatosh_Offer",
    "PDV_Msg_Breton_Arkay_Offer",
    "PDV_Msg_Breton_Dibella_Offer",
    "PDV_Msg_Breton_Julianos_Offer",
    "PDV_Msg_Breton_Kynareth_Offer",
    "PDV_Msg_Breton_Magnus_Offer",
    "PDV_Msg_Breton_Mara_Offer",
    "PDV_Msg_Breton_Stendarr_Offer",
    "PDV_Msg_Breton_Talos_Offer",
    "PDV_Msg_Breton_Yffre_Offer",
    "PDV_Msg_Breton_Zenithar_Offer"
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
  "PDV_Msg_Breton_OfferResponse_Accept",
  "PDV_Msg_Breton_OfferResponse_NotYet",
  "PDV_Msg_Breton_OfferResponse_Refuse",
  "PDV_Msg_Imperial_OfferResponse_Accept",
  "PDV_Msg_Imperial_OfferResponse_NotYet",
  "PDV_Msg_Imperial_OfferResponse_Refuse",
  "PDV_Msg_Redguard_OfferResponse_Accept",
  "PDV_Msg_Redguard_OfferResponse_NotYet",
  "PDV_Msg_Redguard_OfferResponse_Refuse"
];

main(process.argv.slice(2)).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});

async function main(argv) {
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

  const sourceDir = path.resolve(args.sourceDir || path.dirname(sourcePath) || DEFAULT_SOURCE_DIR);

  if (!fs.existsSync(sourcePath)) {
    fail("Formal offer source", "Live PDV__ManagerQuest.psc is missing.", sourcePath);
  } else {
    // Searched, never hashed or rewritten. The 2.0 rebuild moves manager bodies
    // into deep modules, so reading only PDV__ManagerQuest.psc would report the
    // formal-offer flow missing when it merely relocated -- and would let the
    // negated "must not contain" needles pass vacuously. familySourceText() is
    // strictly additive: manager text first and verbatim, then each extracted
    // module with qualifiers stripped; unextracted trees are unaffected.
    const sourceText = familySourceText(PROJECT_ROOT, sourceDir).replace(/\r\n/g, "\n");
    verifySourceContract(sourceText, sourcePath, pass, fail);
  }

  verifyCurseCommitmentBoundaries(sourceDir, pass, fail, warn);
  verifyDebugReachabilityBoundaries(sourceDir, pass, fail);

  if (!args.sourceOnly && spec) {
    await verifyEspReadback(spec, espPath, pass, fail, warn);
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
    "  - Checks source formal-offer flow and reads the active Devotion.esp winner directly through houseCARL.",
    "  - Defaults to Devotion-V3Dev; set PDV_DEVOTION_ROOT or pass explicit source/ESP paths to override.",
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

  if (messageRecords.length === 46) {
    pass("Formal offer spec shape", "Spec declares 46 post-Kyne message records.", specPath);
  } else {
    fail("Formal offer spec shape", `Expected 46 post-Kyne message records, found ${messageRecords.length}.`, specPath);
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
    "PDV_Msg_Redguard_Satakal_Offer",
    "PDV_Msg_Redguard_Ruptga_Offer",
    "PDV_Msg_Redguard_Tava_Offer",
    "PDV_Msg_Redguard_Onsi_Offer",
    "PDV_Msg_Redguard_Sep_Offer",
    "PDV_Msg_Bosmer_",
    "PDV_Msg_Orc_",
    "PDV_Msg_Khajiit_",
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
    "StorageUtil.SetIntValue(pendingDeity as Form, \"PDV.Commitment.Offered\", 0)",
    "StorageUtil.SetFloatValue(pendingDeity as Form, \"PDV.Commitment.DeclinedAt\", Utility.GetCurrentGameTime())",
    "if IsCommitmentDeclineDelayActive(deity)",
    "return (Utility.GetCurrentGameTime() - declinedAt) < COMMITMENT_DECLINE_DELAY_DAYS",
    "elseIf choice == 2",
    "DebugRefusePendingCommitment()",
    "SurfaceTransition(\"offer\", pendingDeity.DeityName, \"refuse\", pendingDeity.DeityIndex, \"absence\", False, True, True)",
    "SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), \"warning\", BuildCommitmentOfferRefuseToastLine(pendingDeity), \"\")",
    "Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)",
    "return GetNordFormalCommitmentOfferMessage(deity)",
    "return GetImperialFormalCommitmentOfferMessage(deity)",
    "return GetDunmerFormalCommitmentOfferMessage(deity)",
    "return GetAltmerFormalCommitmentOfferMessage(deity)",
    "return GetBretonFormalCommitmentOfferMessage(deity)",
    "return GetRedguardFormalCommitmentOfferMessage(deity)",
    "Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)",
    "return IsOfferEligibleDeity(deity) || IsDaedricPactOfferEligibleDeity(deity)",
    "Bool Function IsImperialTalosOfferAllowed()",
    "PDV_ConcordatStandingTrack.GetValue() <= 50",
    "Bool Function ShouldSuppressImperialTalosTierSurface(PDV_DeityBase deity)",
    "Tier reach surface suppressed for Imperial Talos while Concordat blocks offers.",
    "ApplyConcordatPressure ignored for non-Imperial origin.",
    "Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction, PDV_DeityBase deity, String toneOverride = \"\")"
  ];

  // A call that stayed in the manager but whose callee moved gains a forward-ref
  // hop (BuildX(...) -> LedgerRuntime.BuildX(...)). That is a relocation, not a
  // contract change, so the positive needles below are matched against the raw
  // text OR a qualifier-stripped view. The forbidden/exclusion needles further
  // down deliberately keep using the raw text only.
  const qualifierFreeText = stripQualifiers(sourceText);
  const containsSnippet = (snippet) => sourceText.includes(snippet) || qualifierFreeText.includes(snippet);

  for (const snippet of requiredSourceSnippets) {
    if (containsSnippet(snippet)) {
      pass("Formal offer source flow", `Manager contains: ${snippet}`, sourcePath);
    } else {
      fail("Formal offer source flow", `Manager is missing: ${snippet}`, sourcePath);
    }
  }

  const refuseFunction = sourceText.match(/Function\s+DebugRefusePendingCommitment\(\)([\s\S]*?)EndFunction/i)?.[1] || "";
  if (refuseFunction.includes("DispatchDiegeticCue(\"offer\"")) {
    fail("Formal offer refuse surface", "Refuse still dispatches the diegetic director path, which can produce wash/sound.", sourcePath);
  } else {
    pass("Formal offer refuse surface", "Refuse avoids the diegetic director dispatch; only toast + pinned chronicle remain.", sourcePath);
  }

  const helperExpectations = [
    ["IsNordOfferEligibleDeity", ["PDV_Kyne"]],
    ["IsDunmerOfferEligibleDeity", ["PDV_Azura", "PDV_Boethiah", "PDV_Mephala"]],
    ["IsAltmerOfferEligibleDeity", ["PDV_AuriEl", "PDV_Magnus", "PDV_Xarxes", "PDV_Trinimac", "PDV_Syrabane"]],
    ["IsBretonOfferEligibleDeity", ["PDV_Stendarr", "PDV_Akatosh", "PDV_Mara", "PDV_Arkay", "PDV_Julianos", "PDV_Zenithar", "PDV_Kynareth", "PDV_Dibella", "PDV_Magnus", "PDV_Talos", "PDV_Yffre"]],
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

  const forbiddenSourceFunctions = [
    "GetBosmerFormalCommitmentOfferMessage",
    "GetKhajiitFormalCommitmentOfferMessage",
    "GetOrcFormalCommitmentOfferMessage",
    "GetArgonianFormalCommitmentOfferMessage",
    "IsBosmerOfferEligibleDeity",
    "IsKhajiitOfferEligibleDeity",
    "IsOrcOfferEligibleDeity",
    "IsArgonianOfferEligibleDeity"
  ];
  for (const functionName of forbiddenSourceFunctions) {
    if (extractFunctionBody(sourceText, functionName)) {
      fail("Formal offer source exclusion", `Decomposition family must not declare ${functionName}.`, sourcePath);
    } else {
      pass("Formal offer source exclusion", `Decomposition family excludes ${functionName}.`, sourcePath);
    }
  }

  const forbiddenSourceTokens = [
    "PDV_Msg_Redguard_Satakal_Offer",
    "PDV_Msg_Redguard_Ruptga_Offer",
    "PDV_Msg_Redguard_Tava_Offer",
    "PDV_Msg_Redguard_Onsi_Offer",
    "PDV_Msg_Redguard_Sep_Offer"
  ];
  for (const token of forbiddenSourceTokens) {
    if (sourceText.includes(token)) {
      fail("Formal offer source exclusion", `Decomposition family must not contain ${token}.`, sourcePath);
    } else {
      pass("Formal offer source exclusion", `Decomposition family excludes ${token}.`, sourcePath);
    }
  }

  const quietEmergenceSnippets = [
    "SendPrismaShiftToast(\"Your road turns toward \" + GetKhajiitFocusLabel(focusValue) + \".\"",
    "AppendBookOfDaysEntry(focusText, Utility.GetCurrentGameTime() as Int, \"focus.emergence\"",
    "PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)",
    "SurfaceTransition(\"emergence\", traditionDeity.DeityName, \"onset\", traditionDeity.DeityIndex, \"revelation\")",
    "PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)",
    "SurfaceTransition(\"reorientation\", GetOrcLifeModeLabel(), \"shift\", deityIndex, \"turning\")",
    "SurfaceTransition(\"reorientation\", GetBosmerPathLabel(), \"shift\", deity.DeityIndex, \"turning\")",
    "SurfaceTransition(\"reorientation\", GetRedguardSectLabel(), \"shift\", -1, \"turning\")"
  ];
  for (const snippet of quietEmergenceSnippets) {
    if (containsSnippet(snippet)) {
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

async function verifyEspReadback(spec, espPath, pass, fail, warn) {
  if (!fs.existsSync(espPath)) {
    fail("Formal offer ESP readback", "Devotion.esp is missing.", espPath);
    return;
  }

  const session = openHousecarl({ cwd: PROJECT_ROOT, timeoutMs: 90_000 });
  try {
    const v3Status = extractHousecarlText(await session.call("housecarl_load_order_status", {
      lookup: path.basename(path.dirname(espPath)),
      max_chars: 12_000
    }));
    if (!/as a mod:\s+ENABLED/i.test(v3Status)) {
      fail("Formal offer V3 profile", `${path.basename(path.dirname(espPath))} is not enabled in the active houseCARL profile.`, espPath);
      return;
    }
    pass("Formal offer V3 profile", `${path.basename(path.dirname(espPath))} is enabled in the active houseCARL profile.`, espPath);

    const inventoryText = extractHousecarlText(await session.call("housecarl_cross_plugin_query", {
      plugins: ["Devotion.esp"],
      type: "MESG",
      editorid_contains: "PDV_Msg_",
      fields: ["EditorID"],
      limit: 500,
      max_chars: 160_000
    }));
    const inventory = new Map();
    for (const match of inventoryText.matchAll(/formid=([0-9A-F]{6}:Devotion\.esp)\s+editorid=(PDV_Msg_[A-Za-z0-9_]+)/gi)) {
      inventory.set(match[2], match[1]);
    }

    const expectedRecords = spec.messageRecords || [];
    const formids = [];
    for (const record of expectedRecords) {
      const formid = inventory.get(record.editorId);
      if (!formid) fail("Formal offer ESP record", `${record.editorId} is missing from the active Devotion.esp winner.`, espPath);
      else formids.push(formid);
    }
    if (formids.length !== expectedRecords.length) return;

    const detailText = extractHousecarlText(await session.call("housecarl_batch_record_detail", {
      formids,
      fields: ["EditorID", "Name", "Description", "MenuButtons"],
      depth: 3,
      max_chars: 300_000
    }));
    const blocks = splitRecordBlocks(detailText, "Message");
    const byEditorId = new Map(blocks.map((block) => [readRecordField(block, "EditorID"), block]));
    for (const record of expectedRecords) {
      const block = byEditorId.get(record.editorId);
      if (!block) {
        fail("Formal offer ESP readback", `${record.editorId} was not returned by direct houseCARL detail readback.`, espPath);
        continue;
      }
      compareRecordField(record.editorId, "title", readRecordField(block, "Name"), record.title, pass, fail, espPath);
      compareRecordField(record.editorId, "body", readRecordField(block, "Description"), record.body, pass, fail, espPath);
      const actualButtons = [...block.matchAll(/MenuButtons\[(\d+)\]\.Text\s*=\s*(.+)\r?$/gm)]
        .sort((left, right) => Number(left[1]) - Number(right[1]))
        .map((match) => match[2].trim());
      const expectedButtons = record.buttons || [];
      if (JSON.stringify(actualButtons) === JSON.stringify(expectedButtons)) {
        pass("Formal offer ESP buttons", `${record.editorId} button text matches the spec.`, espPath);
      } else {
        fail("Formal offer ESP buttons", `${record.editorId} buttons ${JSON.stringify(actualButtons)} do not match ${JSON.stringify(expectedButtons)}.`, espPath);
      }
    }
  } catch (error) {
    fail("Formal offer ESP readback", `Direct houseCARL readback failed: ${error.message}`, espPath);
  } finally {
    session.close();
  }
}

function verifyDebugReachabilityBoundaries(sourceDir, pass, fail) {
  if (!fs.existsSync(sourceDir)) {
    fail("Debug deity reachability", "Live source directory is missing.", sourceDir);
    return;
  }

  const sourceFiles = fs.readdirSync(sourceDir).filter((name) => name.toLowerCase().endsWith(".psc"));
  const sourceByFile = new Map(sourceFiles.map((name) => [name, readText(path.join(sourceDir, name))]));
  const findFunction = (functionName) => {
    for (const [fileName, sourceText] of sourceByFile) {
      const block = extractFunctionBlocks(sourceText).find((candidate) => candidate.name.toLowerCase() === functionName.toLowerCase());
      if (block) return { ...block, fileName, filePath: path.join(sourceDir, fileName) };
    }
    return null;
  };

  const reachability = findFunction("IsDeityReachableForCurrentOrigin");
  if (!reachability) {
    fail("Debug deity reachability", "IsDeityReachableForCurrentOrigin is missing.", sourceDir);
  } else if (reachability.body.includes("IsDashboardDeityInOriginRoster") && reachability.body.includes("UsesFormalCommitmentOffersForDeity")) {
    pass("Debug deity reachability", "The shared predicate delegates to current-origin roster and formal-offer eligibility.", reachability.filePath);
  } else {
    fail("Debug deity reachability", "The shared predicate does not delegate to both current-origin roster and formal-offer eligibility.", reachability.filePath);
  }

  const activeSetter = findFunction("SetActiveDeity");
  if (activeSetter?.body.includes("!IsDeityReachableForCurrentOrigin(newDeity)")) {
    pass("Active deity reachability", "SetActiveDeity uses the shared current-origin predicate.", activeSetter.filePath);
  } else {
    fail("Active deity reachability", "SetActiveDeity is missing the shared current-origin predicate.", activeSetter?.filePath || sourceDir);
  }

  const altmerEligibility = findFunction("IsAltmerOfferEligibleDeity");
  const expectedAltmer = ["PDV_AuriEl", "PDV_Magnus", "PDV_Xarxes", "PDV_Trinimac", "PDV_Syrabane"];
  if (!altmerEligibility) {
    fail("Altmer formal-offer roster", "IsAltmerOfferEligibleDeity is missing.", sourceDir);
  } else {
    for (const propertyName of expectedAltmer) {
      if (altmerEligibility.body.includes(propertyName)) pass("Altmer formal-offer roster", `Altmer eligibility includes ${propertyName}.`, altmerEligibility.filePath);
      else fail("Altmer formal-offer roster", `Altmer eligibility is missing ${propertyName}.`, altmerEligibility.filePath);
    }
    if (altmerEligibility.body.includes("PDV_BaanDar")) fail("Altmer Baan Dar exclusion", "Altmer eligibility references PDV_BaanDar.", altmerEligibility.filePath);
    else pass("Altmer Baan Dar exclusion", "Altmer eligibility excludes PDV_BaanDar.", altmerEligibility.filePath);
  }

  const dashboardRoster = findFunction("IsDashboardDeityInOriginRoster");
  const altmerRosterArm = dashboardRoster?.body.match(/elseIf\s+originRace\s*==\s*Manager\.ORIGIN_ALTMER([\s\S]*?)(?=elseIf|endIf)/i)?.[1] || "";
  if (!altmerRosterArm) {
    fail("Altmer dashboard roster", "The Altmer dashboard-roster arm is missing.", dashboardRoster?.filePath || sourceDir);
  } else if (expectedAltmer.every((propertyName) => altmerRosterArm.includes(propertyName)) && !altmerRosterArm.includes("PDV_BaanDar")) {
    pass("Altmer dashboard roster", "The Altmer dashboard roster contains the five Altmer deities and excludes Baan Dar.", dashboardRoster.filePath);
  } else {
    fail("Altmer dashboard roster", "The Altmer dashboard roster is incomplete or includes Baan Dar.", dashboardRoster.filePath);
  }

  const guardedMutators = [
    "DebugForceSetPietyByIndex",
    "DebugForceSetPietyTodayByIndex",
    "DebugPrimeDecayGraceByIndex",
    "DebugPrimeDecayEligibleByIndex",
    "DebugRunDecayProofDaysByIndex",
    "DebugAwardCuratedSignalByIndex",
    "DebugSeedCommitmentSignalDaysByIndex",
    "DebugSeedCommitmentSignalDaysForDeity"
  ];
  for (const functionName of guardedMutators) {
    const block = findFunction(functionName);
    if (!block) fail("Ordinary debug reachability", `${functionName} is missing.`, sourceDir);
    else if (block.body.includes("IsDebugDeityTargetEligible")) pass("Ordinary debug reachability", `${functionName} uses the shared debug guard.`, block.filePath);
    else fail("Ordinary debug reachability", `${functionName} can mutate a deity without the shared debug guard.`, block.filePath);
  }

  const mcm = sourceByFile.get("PDV_MCM.psc") || "";
  if (/UnsafeApplyActiveDeityState\s*\(/i.test(mcm)) fail("Ordinary MCM reachability", "PDV_MCM directly calls the unsafe active-deity state writer.", path.join(sourceDir, "PDV_MCM.psc"));
  else pass("Ordinary MCM reachability", "PDV_MCM has no direct off-roster active-deity bypass.", path.join(sourceDir, "PDV_MCM.psc"));
  for (const functionName of ["DebugOverridePatron", "DebugApplySelectedPiety", "DebugApplySelectedPietyToday", "DebugApplyCuratedSignal", "DebugFireSelectedDislike"]) {
    const block = findFunction(functionName);
    if (block?.body.includes("RequireEligibleDebugDeity")) pass("Ordinary MCM reachability", `${functionName} rejects an ineligible selected deity.`, block.filePath);
    else fail("Ordinary MCM reachability", `${functionName} is missing the selected-deity eligibility guard.`, block?.filePath || sourceDir);
  }

  const unsafeBypasses = [];
  for (const [fileName, sourceText] of sourceByFile) {
    for (const block of extractFunctionBlocks(sourceText)) {
      if (/UnsafeApplyActiveDeityState\s*\(/i.test(block.body) && block.name !== "UnsafeApplyActiveDeityState") unsafeBypasses.push(`${fileName}::${block.name}`);
    }
  }
  const expectedBypasses = ["PDV_DevotionLedger.psc::SetActiveDeity", "PDV_DevotionLedger.psc::UnsafeFaultInjectActiveDeity"];
  if (JSON.stringify(unsafeBypasses) === JSON.stringify(expectedBypasses)) {
    pass("Unsafe fault injection isolation", "The unchecked active-deity writer is called only by the guarded setter and named fault injector.", sourceDir);
  } else {
    fail("Unsafe fault injection isolation", `Unexpected unchecked active-deity writer owners: ${JSON.stringify(unsafeBypasses)}.`, sourceDir);
  }

  const unsafeInjector = findFunction("UnsafeFaultInjectActiveDeity");
  const unsafeCleanup = findFunction("ClearUnsafeFaultInjection");
  if (unsafeInjector?.body.includes("[PDV][UNSAFE_FAULT_INJECTION]") && unsafeInjector.body.includes("PDV.Debug.UnsafeFaultInjectionActive") && unsafeInjector.body.includes("PDV.Debug.UnsafeFaultInjectionEver")) {
    pass("Unsafe fault injection marker", "The isolated injector emits and stores an unmistakable unsafe marker.", unsafeInjector.filePath);
  } else {
    fail("Unsafe fault injection marker", "The isolated injector is missing its runtime/persistent unsafe marker.", unsafeInjector?.filePath || sourceDir);
  }
  if (unsafeCleanup?.body.includes("ClearPendingCommitment") && unsafeCleanup.body.includes("SyncFirstTierRaceRewardRuntime") && unsafeCleanup.body.includes("DebugClosePrismaSurfaces")) {
    pass("Unsafe fault injection cleanup", "Cleanup clears pending commitment, reward state, and Prisma surfaces.", unsafeCleanup.filePath);
  } else {
    fail("Unsafe fault injection cleanup", "Unsafe injection cleanup is incomplete.", unsafeCleanup?.filePath || sourceDir);
  }
  const consentFixture = findFunction("DebugConsentDivinePatronThenRaiseSanguine");
  if (consentFixture?.body.includes("ClearUnsafeFaultInjection") && consentFixture.body.includes("previousPatronState") && mcm.includes("[UNSAFE] Divine patron then raise Sanguine")) {
    pass("Unsafe fault injection self-cleanup", "The sole user-facing invalid-state fixture is labelled unsafe, self-cleans, and restores the prior patron mode.", consentFixture.filePath);
  } else {
    fail("Unsafe fault injection self-cleanup", "The user-facing invalid-state fixture is not clearly labelled or self-cleaning.", consentFixture?.filePath || sourceDir);
  }
}

function splitRecordBlocks(text, type) {
  return String(text)
    .split(new RegExp(`(?=\\r?\\ntype=${type}\\s)`, "i"))
    .filter((block) => new RegExp(`(?:^|\\n)type=${type}\\s`, "i").test(block));
}

function readRecordField(block, fieldName) {
  const escaped = escapeRegExp(fieldName);
  return block.match(new RegExp(`^\\s*${escaped}\\s*=\\s*(.*)$`, "m"))?.[1]?.trim() ?? "";
}

function compareRecordField(editorId, fieldName, actual, expected, pass, fail, filePath) {
  if (actual === expected) pass("Formal offer ESP text", `${editorId} ${fieldName} matches the spec.`, filePath);
  else fail("Formal offer ESP text", `${editorId} ${fieldName} does not match the spec.`, filePath);
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
