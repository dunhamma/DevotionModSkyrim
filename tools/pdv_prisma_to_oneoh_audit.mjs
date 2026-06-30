#!/usr/bin/env node
/*
 * Read-only Prisma-to-1.0 wiring audit.
 *
 * This is source/deployment proof only. It does not replace in-game Prisma
 * display, Book of Days close-path smoke, route logs, or manual feel evidence.
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const REPO_SOURCE = path.join(ROOT, "live-source", "Scripts", "Source");
const LIVE_SOURCE = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";
const REPO_VIEW = path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion");
const LIVE_VIEW = "D:/Wabbajack/modlists/Anvil/mods/Devotion/PrismaUI/views/Devotion";

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  const findings = [];
  const pass = (check, detail, filePath = null) => findings.push({ status: "PASS", check, detail, path: filePath });
  const fail = (check, detail, filePath = null) => findings.push({ status: "FAIL", check, detail, path: filePath });

  const managerPath = path.join(LIVE_SOURCE, "PDV__ManagerQuest.psc");
  const directorPath = path.join(LIVE_SOURCE, "PDV_DiegeticDirector.psc");
  const hircinePath = path.join(LIVE_SOURCE, "PDV_DaedricPath_Hircine.psc");
  const appPath = path.join(LIVE_VIEW, "app.js");

  verifyHashPair("Manager source parity", path.join(REPO_SOURCE, "PDV__ManagerQuest.psc"), managerPath, pass, fail);
  verifyHashPair("Director source parity", path.join(REPO_SOURCE, "PDV_DiegeticDirector.psc"), directorPath, pass, fail);
  verifyHashPair("Hircine source parity", path.join(REPO_SOURCE, "PDV_DaedricPath_Hircine.psc"), hircinePath, pass, fail);

  for (const name of ["index.html", "styles.css", "app.js"]) {
    verifyHashPair(`Prisma view ${name} parity`, path.join(REPO_VIEW, name), path.join(LIVE_VIEW, name), pass, fail);
  }

  const manager = readRequired(managerPath, "Manager source", pass, fail);
  const director = readRequired(directorPath, "Director source", pass, fail);
  const hircine = readRequired(hircinePath, "Hircine source", pass, fail);
  const app = readRequired(appPath, "Prisma app", pass, fail);

  if (manager) verifyManager(manager, managerPath, pass, fail);
  if (director) verifyDirector(director, directorPath, pass, fail);
  if (hircine) verifyHircine(hircine, hircinePath, pass, fail);
  if (app) verifyApp(app, appPath, pass, fail);
  if (manager) runNegativeFixtures(manager, pass, fail);

  const passCount = findings.filter((finding) => finding.status === "PASS").length;
  const failCount = findings.filter((finding) => finding.status === "FAIL").length;
  const summary = {
    status: failCount === 0 ? "PASS" : "FAIL",
    passCount,
    failCount,
    findings
  };

  if (args.json) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    console.log(`PDV Prisma-to-1.0 audit: ${summary.status} (PASS=${passCount} FAIL=${failCount})`);
    for (const finding of findings) {
      console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${finding.path ? ` [${finding.path}]` : ""}`);
    }
  }

  process.exit(failCount === 0 ? 0 : 1);
}

function parseArgs(argv) {
  const args = { json: false };
  for (const arg of argv) {
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--help" || arg === "-h") {
      console.log("Usage: node tools/pdv_prisma_to_oneoh_audit.mjs [--json]");
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function readRequired(filePath, label, pass, fail) {
  if (!fs.existsSync(filePath)) {
    fail(label, "File is missing.", filePath);
    return "";
  }
  const text = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  pass(label, `Read ${text.length} characters.`, filePath);
  return text;
}

function verifyHashPair(check, repoPath, livePath, pass, fail) {
  if (!fs.existsSync(repoPath)) {
    fail(check, "Repo file is missing.", repoPath);
    return;
  }
  if (!fs.existsSync(livePath)) {
    fail(check, "Live file is missing.", livePath);
    return;
  }
  const repoHash = hash(repoPath);
  const liveHash = hash(livePath);
  if (repoHash === liveHash) {
    pass(check, `Hashes match (${repoHash.slice(0, 12)}).`, livePath);
  } else {
    fail(check, `Hashes differ (${repoHash.slice(0, 12)} != ${liveHash.slice(0, 12)}).`, livePath);
  }
}

function verifyManager(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Rivalry drain driver", 'AwardPietyInternal(rivalDeity, rivalAmount, False, "rivalry with " + sourceDeity.DeityName)', "Rivalry drain uses a reason-bearing piety path."],
    ["Khajiit corrupted chronicle", "The moonlight scatters from your path. Corruption is upon you.", "Severe Corrupted posture writes a Chronicle line."],
    ["Khajiit shadowdrift chronicle", "You slipped into the moons' shadow. Darkness is upon you.", "Severe ShadowDrift posture writes a Chronicle line."],
    ["Khajiit emergence helper", "PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)", "Khajiit focus resolves to a deity for quiet-emergence surfacing."],
    ["Khajiit emergence onset", 'SurfaceTransition("emergence", focusDeity.DeityName, "onset", focusDeity.DeityIndex, "revelation")', "Khajiit quiet-emergence emits onset, not reach."],
    ["Breton emergence helper", "PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)", "Breton tradition resolves to a deity for quiet-emergence surfacing."],
    ["Breton emergence onset", 'SurfaceTransition("emergence", traditionDeity.DeityName, "onset", traditionDeity.DeityIndex, "revelation")', "Breton quiet-emergence emits onset, not reach."],
    ["Neglect recovery producer", 'SurfaceTransition("neglect", _activeDeity.DeityName, "recover", _activeDeity.DeityIndex, "renewal")', "Patron neglect recovery emits the built recover tone."],
    ["Substrate thinning producer", 'SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)', "Substrate erosion emits the built thin phase."],
    ["Khajiit Champion pin", 'SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)', "Khajiit Champion Chronicle entry is pinned and uses the internal Champion label."],
    ["Orc lapse-to-City route", 'ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")', "Orc passive lapse routes through the toast-producing switch path."],
    ["New Daedric pact toast", 'SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")', "First Daedric pact activation emits a Prisma shift toast."],
    ["Altmer crisis toast", 'SendPrismaShiftToast("The old line turns: " + GetAltmerCrisisStateLabelForValue(stateValue) + ".", "", "auri-el")', "Altmer crisis transitions emit an immediate shift toast."],
    ["Daedric boon producer", 'SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)', "Daedric tier presentation emits the rite-answered boon toast."],
    ["Hircine residue drain", "Function DrainHircineResiduePrismaToasts()", "Manager drains Hircine residue onset/fade toast breadcrumbs."],
    ["Hircine renunciation chronicle", "You set the hunt down. The pact with Hircine is renounced -- the beast's mark fades slowly, but the road back is yours to walk.", "Hircine renunciation writes the approved Chronicle line."],
    ["Hircine renunciation toast", 'SendPrismaShiftToast("You renounce the hunt.", "Hircine\'s pact is set down.", "hircine")', "Hircine renunciation emits the approved Prisma toast."],
    ["Redguard Crown entry toast", 'SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")', "Redguard Crown Champion-entry emits the approved Prisma toast."],
    ["Redguard Forebear entry toast", 'SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")', "Redguard Forebear Champion-entry emits the approved Prisma toast."],
    ["Redguard Ash'abah entry toast", "SendPrismaShiftToast(\"The Ash'abah duty, made public.\", \"More than necessity now -- a public shape of your devotion.\", \"sect\")", "Redguard Ash'abah Champion-entry emits the approved Prisma toast."],
    ["Offer accept surface", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")', "Commitment accept dispatches a diegetic offer beat from the shared handler."],
    ["Offer accept toast", 'SendPrismaShiftToast("You have given your devotion to " + GetPublicDeityDisplayName(pendingDeity) + ".", GetPublicDeityDisplayName(pendingDeity) + " takes you as their own.", GetPrismaSymbolForDeity(pendingDeity))', "Commitment accept emits the approved Prisma toast."],
    ["Offer refuse surface", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "refuse", pendingDeity, "absence")', "Terminal refusal dispatches a diegetic offer beat."],
    ["Offer refuse toast", 'SendPrismaShiftToast("You turn " + GetPublicDeityDisplayName(pendingDeity) + " away.", GetPublicDeityDisplayName(pendingDeity) + " will not ask again.", GetPrismaSymbolForDeity(pendingDeity))', "Terminal refusal emits the approved fallback Prisma toast."],
    ["Commitment carryover driver", 'AwardPiety(pendingDeity, carryAmount, "commitment_carryover")', "Commitment carryover uses the reason-bearing AwardPiety funnel."],
    ["Altmer alignment surface", "Where you stand in the Thalmor question shifts: ", "Altmer Thalmor-alignment band writes the approved Chronicle line."],
    ["Breton tradition surface", "You set your tradition: ", "Breton irreversible tradition choice emits an immediate surface."],
    ["Argonian adaptation surface", "The Hist has reshaped you.", "Argonian adaptation emits a Prisma surface."],
    ["Bosmer path chronicle", "Y'ffre's song settles within you. Your road through the Green is the ", "Bosmer path confirmation writes a Chronicle line."]
  ];

  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }

  forbidSnippet(text, 'eventClass == "drift"', "Retired drift producer branch", "No drift transition branch remains in the manager.", filePath, pass, fail);
  forbidSnippet(text, '"drift.warn"', "Retired drift tone", "No drift.warn tone entries remain in the manager.", filePath, pass, fail);

  if (/SurfaceTransition\("emergence"[\s\S]{0,140}"reach"/.test(text)) {
    fail("Emergence direction", 'A SurfaceTransition("emergence", ..., "reach") call remains; expected "onset".', filePath);
  } else {
    pass("Emergence direction", 'No stale SurfaceTransition("emergence", ..., "reach") call remains.', filePath);
  }
}

function verifyDirector(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Director emergence tone", 'if eventClass == "emergence"', "Director maps emergence events to authored tone."],
    ["Director emergence line", 'if toneKey == "emergence.onset"', "Director resolves emergence.onset journal text."],
    ["Director Khajiit resolver", "ResolveKhajiitJournalLine(toneKey, deityIndex)", "Khajiit quiet-emergence uses the deity index."],
    ["Director tier line", 'if toneKey == "tier.reach"', "Director preserves generic tier journal line routing."]
  ];
  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }
}

function verifyHircine(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Hircine residue onset breadcrumb", 'StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueToastPending", 1)', "Residue onset queues a manager-drained Prisma toast."],
    ["Hircine residue fade breadcrumb", 'StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueClearToastPending", 1)', "Residue fade queues a manager-drained Prisma toast."],
    ["Hircine renunciation source", 'BeginNordResidueRecovery("renounce_" + reason)', "Renunciation starts the residue recovery lane."],
    ["Hircine cure source", 'BeginNordResidueRecovery("cure_" + reason)', "Werewolf cure starts the residue recovery lane."]
  ];
  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }
}

function verifyApp(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Substrate thin renderer", 'if (phase === "thin")', "Prisma UI renders the substrate thin phase."],
    ["Substrate thin fixture", "substrate_thin", "Prisma UI keeps a substrate thin fixture."],
    ["Daedric boon renderer", 'if (phase === "boon")', "Prisma UI renders the Daedric boon phase."],
    ["Daedric residue renderer", 'if (phase === "residue")', "Prisma UI renders the Hircine residue phase."]
  ];
  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }
}

function runNegativeFixtures(managerText, pass, fail) {
  expectManagerFailure(
    "Negative fixture: rivalry reason",
    managerText.replace('AwardPietyInternal(rivalDeity, rivalAmount, False, "rivalry with " + sourceDeity.DeityName)', "AwardPietyInternal(rivalDeity, rivalAmount, False)"),
    pass,
    fail
  );
  expectManagerFailure(
    "Negative fixture: emergence reach",
    managerText.replace('SurfaceTransition("emergence", focusDeity.DeityName, "onset", focusDeity.DeityIndex, "revelation")', 'SurfaceTransition("emergence", focusDeity.DeityName, "reach", focusDeity.DeityIndex, "revelation")'),
    pass,
    fail
  );
  expectManagerFailure(
    "Negative fixture: neglect recover",
    managerText.replace('SurfaceTransition("neglect", _activeDeity.DeityName, "recover", _activeDeity.DeityIndex, "renewal")', ""),
    pass,
    fail
  );
}

function expectManagerFailure(check, mutatedText, pass, fail) {
  const local = [];
  const localPass = () => {};
  const localFail = (localCheck, detail) => local.push({ localCheck, detail });
  verifyManager(mutatedText, "<self-test>", localPass, localFail);
  if (local.length > 0) {
    pass(check, `Self-test failed as expected (${local[0].localCheck}).`);
  } else {
    fail(check, "Self-test unexpectedly passed.");
  }
}

function requireSnippet(text, snippet, check, detail, filePath, pass, fail) {
  if (text.includes(snippet)) {
    pass(check, detail, filePath);
  } else {
    fail(check, `Missing required snippet: ${snippet}`, filePath);
  }
}

function forbidSnippet(text, snippet, check, detail, filePath, pass, fail) {
  if (text.includes(snippet)) {
    fail(check, `Forbidden snippet remains: ${snippet}`, filePath);
  } else {
    pass(check, detail, filePath);
  }
}

function hash(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}
