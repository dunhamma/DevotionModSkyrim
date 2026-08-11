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
const LIVE_SOURCE =
  process.env.PDV_AUDIT_LIVE_SOURCE ||
  "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";
const REPO_VIEW = path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion");
const LIVE_VIEW =
  process.env.PDV_AUDIT_LIVE_PRISMA ||
  "D:/Wabbajack/modlists/Anvil/mods/Devotion/PrismaUI/views/Devotion";

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  const findings = [];
  const pass = (check, detail, filePath = null) => findings.push({ status: "PASS", check, detail, path: filePath });
  const fail = (check, detail, filePath = null) => findings.push({ status: "FAIL", check, detail, path: filePath });

  const managerPath = path.join(LIVE_SOURCE, "PDV__ManagerQuest.psc");
  const directorPath = path.join(LIVE_SOURCE, "PDV_DiegeticDirector.psc");
  const hircinePath = path.join(LIVE_SOURCE, "PDV_DaedricPath_Hircine.psc");
  const lowHealthPath = path.join(LIVE_SOURCE, "PDV_T3DailyLowHealthSaveEffect.psc");
  const appPath = path.join(LIVE_VIEW, "app.js");

  verifyHashPair("Manager source parity", path.join(REPO_SOURCE, "PDV__ManagerQuest.psc"), managerPath, pass, fail);
  verifyHashPair("Director source parity", path.join(REPO_SOURCE, "PDV_DiegeticDirector.psc"), directorPath, pass, fail);
  verifyHashPair("Hircine source parity", path.join(REPO_SOURCE, "PDV_DaedricPath_Hircine.psc"), hircinePath, pass, fail);
  verifyHashPair("Low-health effect source parity", path.join(REPO_SOURCE, "PDV_T3DailyLowHealthSaveEffect.psc"), lowHealthPath, pass, fail);

  for (const name of ["index.html", "styles.css", "app.js"]) {
    verifyHashPair(`Prisma view ${name} parity`, path.join(REPO_VIEW, name), path.join(LIVE_VIEW, name), pass, fail);
  }

  const manager = readRequired(managerPath, "Manager source", pass, fail);
  const director = readRequired(directorPath, "Director source", pass, fail);
  const hircine = readRequired(hircinePath, "Hircine source", pass, fail);
  const lowHealth = readRequired(lowHealthPath, "Low-health effect source", pass, fail);
  const app = readRequired(appPath, "Prisma app", pass, fail);

  if (manager) verifyManager(manager, managerPath, pass, fail);
  if (manager) verifyJsonSafeString(manager, "Manager JsonSafeString", managerPath, pass, fail);
  if (director) verifyDirector(director, directorPath, pass, fail);
  if (hircine) verifyHircine(hircine, hircinePath, pass, fail);
  if (lowHealth) verifyJsonSafeString(lowHealth, "Low-health effect JsonSafeString", lowHealthPath, pass, fail);
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
  const text = normalizedText(filePath);
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
    ["Khajiit emergence helper", "PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)", "Khajiit focus resolves to a deity for automatic emergence and reorientation."],
    ["Khajiit first-emergence popup", "emergenceMessage.Show()", "Khajiit's first qualifying focus shows its ceremonial one-button MessageBox."],
    ["Khajiit emergence toast", 'SendPrismaShiftToast("Your road turns toward "', "Khajiit emergence and reorientation emit the existing Prisma toast."],
    ["Khajiit pinned emergence entry", '"focus.emergence", GetKhajiitFocusSymbol(focusValue), True', "The first Khajiit emergence writes a pinned Book of Days entry."],
    ["Khajiit unpinned reorientation entry", '"reorientation", GetKhajiitFocusSymbol(focusValue), False', "Later Khajiit reorientations write an unpinned Book of Days entry without another popup."],
    ["Breton emergence helper", "PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)", "Breton tradition resolves to a deity for quiet-emergence surfacing."],
    ["Breton emergence onset", 'SurfaceTransition("emergence", traditionDeity.DeityName, "onset", traditionDeity.DeityIndex, "revelation")', "Breton quiet-emergence emits onset, not reach."],
    ["Neglect recovery producer", 'SurfaceTransition("neglect", _activeDeity.DeityName, "recover", _activeDeity.DeityIndex, "renewal")', "Patron neglect recovery emits the built recover tone."],
    ["Substrate thinning producer", 'SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)', "Substrate erosion emits the built thin phase."],
    ["Khajiit Champion pin", 'SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)', "Khajiit Champion Chronicle entry is pinned and uses the internal Champion label."],
    ["Orc lapse-to-City route", 'ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")', "Orc passive lapse routes through the toast-producing switch path."],
    ["New Daedric pact toast", 'SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")', "First Daedric pact activation emits a Prisma shift toast."],
    ["Altmer crisis toast", 'SendPrismaShiftToast(crisisHeadline, crisisLine, "auri-el")', "Altmer crisis transitions emit an immediate shift toast from authored headline/line copy."],
    ["Altmer crisis journal pairing", 'AppendBookOfDaysEntry(crisisLine, Utility.GetCurrentGameTime() as Int, crisisTone, "auri-el", True, 3, crisisHeadline)', "Altmer crisis transitions pair the shift toast with a Book of Days entry."],
    ["Daedric boon producer", 'SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)', "Daedric tier presentation emits the rite-answered boon toast."],
    ["Hircine residue drain", "Function DrainHircineResiduePrismaToasts()", "Manager drains Hircine residue onset/fade toast breadcrumbs."],
    ["Hircine renunciation drain", "Function DrainHircineRenunciationJournal()", "Manager drains the production Hircine renunciation journal breadcrumb."],
    ["Hircine renunciation chronicle", "Hircine's mark fades from your blood, and the pack is no longer yours.", "Hircine renunciation writes the locked Chronicle line."],
    ["Redguard Crown entry toast", 'SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")', "Redguard Crown Champion-entry emits the approved Prisma toast."],
    ["Redguard Forebear entry toast", 'SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")', "Redguard Forebear Champion-entry emits the approved Prisma toast."],
    ["Redguard Ash'abah entry toast", "SendPrismaShiftToast(\"The Ash'abah duty, made public.\", \"More than necessity now -- a public shape of your devotion.\", \"sect\")", "Redguard Ash'abah Champion-entry emits the approved Prisma toast."],
    ["Offer accept surface", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")', "Commitment accept dispatches a diegetic offer beat from the shared handler."],
    ["Offer accept toast helper", "String Function BuildCommitmentOfferAcceptToastLine(PDV_DeityBase deity)", "Commitment accept resolves the locked per-race Prisma toast."],
    ["Offer accept direct toast", 'SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "good", BuildCommitmentOfferAcceptToastLine(pendingDeity), "")', "Commitment accept uses the direct toast shape, not the generic shift template."],
    ["Offer accept reward sync", 'SetActiveDeity(pendingDeity)\n    SyncFirstTierRaceRewardRuntime()', "Commitment accept resyncs focused rewards immediately after patron assignment."],
    ["Offer accept Dunmer toast", "The ash-prayer has a name: ", "Dunmer accept toast uses locked copy."],
    ["Offer accept Altmer toast", "You name ", "Altmer accept toast uses locked copy."],
    ["Offer accept Redguard toast", "You walk under ", "Redguard accept toast uses locked copy."],
    ["Offer refuse surface", 'SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)', "Terminal refusal writes the pinned offer beat without director wash/sound."],
    ["Offer refuse toast helper", "String Function BuildCommitmentOfferRefuseToastLine(PDV_DeityBase deity)", "Commitment refuse resolves the locked per-race Prisma toast."],
    ["Offer refuse direct toast", 'SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "warning", BuildCommitmentOfferRefuseToastLine(pendingDeity), "")', "Commitment refuse uses the direct toast shape, not the generic shift template."],
    ["Offer refuse Altmer toast", "You keep to the foundation.", "Altmer refuse toast uses locked copy."],
    ["Offer refuse Redguard toast", "You keep to the sect.", "Redguard refuse toast uses locked copy."],
    ["Commitment no-loss marker", 'StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)', "Patron acceptance records zero carryover loss while preserving deity piety."],
    ["Altmer alignment surface", "Your soul records where you stand in the Thalmor question: ", "Altmer Thalmor-alignment band writes the locked Chronicle line."],
    ["Breton tradition surface", "You set your tradition: ", "Breton irreversible tradition choice emits an immediate surface."],
    ["Argonian adaptation surface", "The Hist has reshaped you.", "Argonian adaptation emits a Prisma surface."],
    ["Bosmer path chronicle", "Y'ffre's song settles within you. Your road through the Green is the ", "Bosmer path confirmation writes a Chronicle line."]
  ];

  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }

  forbidSnippet(text, 'eventClass == "drift"', "Retired drift producer branch", "No drift transition branch remains in the manager.", filePath, pass, fail);
  forbidSnippet(text, '"drift.warn"', "Retired drift tone", "No drift.warn tone entries remain in the manager.", filePath, pass, fail);
  forbidSnippet(text, "SendPrismaShiftToast(BuildCommitmentOffer", "Commitment shift-toast fallback", "Commitment accept/refuse do not reuse the generic shift-toast template.", filePath, pass, fail);
  forbidSnippet(text, 'AwardPiety(pendingDeity, carryAmount, "commitment_carryover")', "Retired commitment carryover loss", "Patron acceptance preserves existing deity piety and applies no lossy carryover award.", filePath, pass, fail);
  forbidSnippet(text, 'SurfaceTransition("emergence", focusDeity.DeityName', "Retired Khajiit generic emergence route", "Khajiit emergence uses the exact popup/toast/Book contract rather than the generic transition director.", filePath, pass, fail);

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

function verifyJsonSafeString(text, label, filePath, pass, fail) {
  const block = functionBlock(text, "JsonSafeString");
  if (!block) {
    fail(label, "JsonSafeString helper is missing.", filePath);
    return;
  }

  requireSnippet(block, "StringUtil.AsOrd(currentChar)", `${label}: control-character ordinal`, "Helper reads each character ordinal before JSON emission.", filePath, pass, fail);
  requireSnippet(block, "currentOrd < 32", `${label}: control-character guard`, "Helper replaces JSON-forbidden ASCII control characters before JSON emission.", filePath, pass, fail);
  requireSnippet(block, 'safeText = safeText + " "', `${label}: control-character replacement`, "Helper flattens control characters into a parseable single-line JSON string.", filePath, pass, fail);
}

function functionBlock(source, functionName) {
  const pattern = new RegExp(`(?:[A-Za-z_][\\w]*\\s+)?Function\\s+${functionName}\\b[\\s\\S]*?EndFunction`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
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
    "Negative fixture: Khajiit emergence popup",
    managerText.replace("emergenceMessage.Show()", ""),
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
  return crypto.createHash("sha256").update(normalizedText(filePath), "utf8").digest("hex");
}

function normalizedText(filePath) {
  return fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "").replaceAll("\r\n", "\n");
}
