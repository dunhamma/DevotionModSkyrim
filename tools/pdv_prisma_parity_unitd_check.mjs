#!/usr/bin/env node
/*
 * Read-only Unit D Prisma parity verifier.
 *
 * This is intentionally source/readback focused. Runtime proof for the surfaced
 * transitions remains an in-game owner gate.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { devotionSource } from "./lib/pdv_paths.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_MANAGER = path.join(devotionSource(), "PDV__ManagerQuest.psc");
const DEFAULT_DIRECTOR = path.join(devotionSource(), "PDV_DiegeticDirector.psc");
const DAEDRIC_CONTRACT = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  const managerPath = path.resolve(args.manager || DEFAULT_MANAGER);
  const directorPath = path.resolve(args.director || DEFAULT_DIRECTOR);
  const findings = [];
  const pass = (check, detail, filePath = null) => findings.push({ status: "PASS", check, detail, path: filePath });
  const fail = (check, detail, filePath = null) => findings.push({ status: "FAIL", check, detail, path: filePath });

  const managerText = readRequired(managerPath, "Manager source", pass, fail);
  const directorText = readRequired(directorPath, "Director source", pass, fail);

  if (managerText) {
    verifyManager(managerText, managerPath, pass, fail);
  }
  if (directorText) {
    verifyDirector(directorText, directorPath, pass, fail);
  }
  verifyDaedricTitles(pass, fail);

  const passCount = findings.filter((finding) => finding.status === "PASS").length;
  const failCount = findings.filter((finding) => finding.status === "FAIL").length;
  const summary = {
    status: failCount === 0 ? "PASS" : "FAIL",
    passCount,
    failCount,
    manager: toDisplayPath(managerPath),
    director: toDisplayPath(directorPath),
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
  const args = { json: false, manager: null, director: null };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--manager") {
      args.manager = argv[++i];
    } else if (arg === "--director") {
      args.director = argv[++i];
    } else if (arg === "--help" || arg === "-h") {
      console.log("Usage: node tools/pdv_prisma_parity_unitd_check.mjs [--json] [--manager PATH] [--director PATH]");
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

function verifyManager(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Offer accept resolver", 'eventClass == "offer" && direction == "accept"', "offer.accept resolves to a non-empty per-race line."],
    ["Offer refuse resolver", 'eventClass == "offer" && direction == "refuse"', "offer.refuse resolves to a non-empty per-race line."],
    ["Offer accept Nord/Imperial line", "The broad faith narrows to one; ", "Nord/Imperial accept chronicle is present."],
    ["Offer refuse Nord/Imperial line", "The broad faith stays whole; you turned ", "Nord/Imperial refuse chronicle is present."],
    ["Offer accept Dunmer line", "The Reclamation deepens in you. You named ", "Dunmer accept chronicle is present."],
    ["Offer refuse Dunmer line", "The Reclamation holds as it was. You set ", "Dunmer refuse chronicle is present."],
    ["Offer accept Altmer line", "The foundation narrows to a single disciplined road. You named ", "Altmer accept chronicle is present."],
    ["Offer refuse Altmer line", "The foundation stands as it was. You kept to it alone, and ", "Altmer refuse chronicle is present."],
    ["Offer accept Redguard line", "The sect's broad worship narrows to one charge. You took ", "Redguard accept chronicle is present."],
    ["Offer refuse Redguard line", "The sect's broad worship holds as it was. You set ", "Redguard refuse chronicle is present."],
    ["Refuse silent surface", 'SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)', "Refuse path writes the pinned Book of Days cue without director wash/sound."],
    ["Accept cue dispatch", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")', "Accept path emits the Book of Days cue from the shared handler."],
    ["Accept direct Prisma toast", 'SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "good", BuildCommitmentOfferAcceptToastLine(pendingDeity), "")', "Accept path emits the locked per-race Prisma toast without the generic shift template."],
    ["Refuse direct Prisma toast", 'SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "warning", BuildCommitmentOfferRefuseToastLine(pendingDeity), "")', "Refuse path emits the locked per-race Prisma toast without the generic shift template."],
    ["No-loss commitment telemetry", 'StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)', "Commitment acceptance preserves deity piety and records zero legacy carryover."],
    ["Altmer alignment toast", "The Thalmor question turns in you: ", "Altmer committed-band toast is present."],
    ["Altmer alignment chronicle", "Your soul records where you stand in the Thalmor question: ", "Altmer committed-band chronicle is present."],
    ["Altmer committed band source", "GetStateLabelAt(PDV_ThalmorAlignmentTrack.GetCommittedStateIndex())", "Altmer band uses committed state rather than raw value."],
    ["Breton tradition toast", "You set your tradition: ", "Breton tradition toast is present."],
    ["Breton tradition chronicle", "You've chosen your road: ", "Breton tradition chronicle is present."],
    ["Hircine onset chronicle", "The beast-blood took you and stirred Hircine. The Hunt is in you now.", "Hircine werewolf-onset chronicle is present."],
    ["Hircine renunciation drain", "DrainHircineRenunciationJournal()", "Hircine renunciation production breadcrumb is drained."],
    ["Hircine renunciation chronicle", "Hircine's mark fades from your blood, and the pack is no longer yours.", "Hircine renunciation chronicle is present."],
    ["Redguard Crown chronicle", "The Crown way is more than memory in you now. It has become a public shape of your devotion.", "Redguard Crown Champion-entry chronicle is present."],
    ["Redguard Crown toast", 'SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")', "Redguard Crown Champion-entry toast is present."],
    ["Redguard Forebear chronicle", "The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.", "Redguard Forebear Champion-entry chronicle is present."],
    ["Redguard Forebear toast", 'SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")', "Redguard Forebear Champion-entry toast is present."],
    ["Redguard Ash'abah chronicle", "The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.", "Redguard Ash'abah Champion-entry chronicle is present."],
    ["Redguard Ash'abah toast", "SendPrismaShiftToast(\"The Ash'abah duty, made public.\", \"More than necessity now -- a public shape of your devotion.\", \"sect\")", "Redguard Ash'abah Champion-entry toast is present."],
    ["Argonian adaptation toast", "The Hist has reshaped you.", "Argonian adaptation toast is present."],
    ["Argonian adaptation chronicle", "You took the Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its image.", "Argonian adaptation chronicle is present."],
    ["Breton werewolf fork chronicle", "The beast-blood took your Green Way down a wilder road. The Werewolf path is yours now.", "Breton werewolf fork chronicle is present."],
    ["Breton betrayed fork chronicle", "You turned from the Green Way's trust. The path remembers the betrayal.", "Breton betrayed fork chronicle is present."],
    ["Bosmer path chronicle", "Y'ffre's song settles within you. Your road through the Green is the ", "Bosmer path-confirm chronicle is present."],
    ["Khajiit corrupted chronicle", "The moonlight scatters from your path. Corruption is upon you.", "Khajiit Corrupted posture chronicle is present."],
    ["Khajiit shadowdrift chronicle", "You slipped into the moons' shadow. Darkness is upon you.", "Khajiit ShadowDrift posture chronicle is present."],
    ["Altmer crisis toast", 'SendPrismaShiftToast(crisisHeadline, crisisLine, "auri-el")', "Altmer crisis transition emits an immediate Prisma toast from authored copy."],
    ["Altmer crisis journal pairing", 'AppendBookOfDaysEntry(crisisLine, Utility.GetCurrentGameTime() as Int, crisisTone, "auri-el", True, 3, crisisHeadline)', "Altmer crisis transition pairs the toast with a Book of Days entry."]
  ];

  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }

  const acceptFunction = extractFunction(text, "DebugAcceptPendingCommitment");
  if (!acceptFunction) {
    fail("No-loss accept function", "DebugAcceptPendingCommitment is missing.", filePath);
  } else if (/carryAmount|commitment_carryover|AwardPiety\(pendingDeity/.test(acceptFunction)) {
    fail("No-loss patron transition", "Commitment acceptance must not deduct, re-award, or otherwise transform the patron's existing piety.", filePath);
  } else if (!/StorageUtil\.SetFloatValue\(None, "PDV\.Commitment\.LastCarryover", 0\.0\)[\s\S]*SetActiveDeity\(pendingDeity\)[\s\S]*SyncFirstTierRaceRewardRuntime\(\)[\s\S]*DispatchDiegeticCue\("offer", pendingDeity\.DeityName, "accept"/.test(acceptFunction)) {
    fail("Accept reward sync", "Accept must resync race rewards after setting the active patron and before surfacing the accept beat.", filePath);
  } else if (/DebugForceSetPietyByIndex/.test(acceptFunction)) {
    fail("Carryover legacy setter", "DebugAcceptPendingCommitment still calls DebugForceSetPietyByIndex.", filePath);
  } else if (/SendPrismaShiftToast\(BuildCommitmentOffer/.test(acceptFunction)) {
    fail("Commitment toast template", "Commitment accept still uses the generic shift-toast template.", filePath);
  } else {
    pass("No-loss patron transition", "Acceptance preserves patron piety, records zero legacy carryover, and contains no carryover award path.", filePath);
    pass("Accept reward sync", "Accept resyncs race rewards after setting the active patron.", filePath);
    pass("Commitment toast template", "Commitment accept uses a direct toast instead of the generic shift template.", filePath);
  }

  const refuseFunction = extractFunction(text, "DebugRefusePendingCommitment");
  if (!refuseFunction) {
    fail("Refuse function", "DebugRefusePendingCommitment is missing.", filePath);
  } else if (!refuseFunction.includes('SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)')) {
    fail("Refuse surface", "Commitment refuse must write the pinned chronicle through silent SurfaceTransition.", filePath);
  } else if (!refuseFunction.includes('SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "warning", BuildCommitmentOfferRefuseToastLine(pendingDeity), "")')) {
    fail("Refuse direct Prisma toast", "Commitment refuse must emit the explicit refusal toast.", filePath);
  } else if (refuseFunction.includes('DispatchDiegeticCue("offer"')) {
    fail("Refuse director dispatch", "Commitment refuse must not dispatch the diegetic director wash/sound path.", filePath);
  } else if (/SendPrismaShiftToast\(BuildCommitmentOffer/.test(refuseFunction)) {
    fail("Refuse toast template", "Commitment refuse still uses the generic shift-toast template.", filePath);
  } else {
    pass("Refuse surface", "Commitment refuse writes a pinned chronicle through silent SurfaceTransition.", filePath);
    pass("Refuse direct Prisma toast", "Commitment refuse emits the explicit refusal toast.", filePath);
    pass("Refuse director dispatch", "Commitment refuse avoids the diegetic director wash/sound path.", filePath);
    pass("Refuse toast template", "Commitment refuse uses a direct toast instead of the generic shift template.", filePath);
  }
}

function verifyDirector(text, filePath, pass, fail) {
  const requiredSnippets = [
    ["Khajiit resolver receives deity index", "ResolveKhajiitJournalLine(toneKey, deityIndex)", "Khajiit quiet-emergence can resolve the focused deity name."],
    ["Khajiit dynamic journal line", "Under the moons your road turned toward ", "Khajiit quiet-emergence chronicle is non-empty and dynamic."],
    ["Director deity lookup helper", "String Function GetDeityNameByIndex(Int deityIndex)", "Director deity-name fallback helper is present."],
    ["Imperial resolver retained", "String Function ResolveImperialJournalLine(String toneKey)", "Imperial journal resolver remains wired."],
    ["Altmer resolver retained", "String Function ResolveAltmerJournalLine(String toneKey)", "Altmer journal resolver remains wired."]
  ];

  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }
}

function verifyDaedricTitles(pass, fail) {
  if (!fs.existsSync(DAEDRIC_CONTRACT)) {
    fail("Daedric title authority", "Daedric record contract is missing.", DAEDRIC_CONTRACT);
    return;
  }

  try {
    const parsed = JSON.parse(fs.readFileSync(DAEDRIC_CONTRACT, "utf8").replace(/^\uFEFF/, ""));
    const princes = Array.isArray(parsed.princes) ? parsed.princes : [];
    const commitments = princes.map((prince) => {
      const messages = Array.isArray(prince.messages) ? prince.messages : [];
      return messages.find((message) => message.property === "Msg_Commitment");
    });
    const editorIds = commitments.map((message) => message?.editorId).filter(Boolean);
    const titles = commitments.map((message) => message?.title).filter(Boolean);
    const valid = parsed.princeCount === 16 && princes.length === 16 && commitments.every((message) =>
      message && message.messageBox === true && /^PDV_Msg_Daedric_.+_Commitment$/.test(message.editorId || "") && (message.title || "").trim().length > 0
    ) && new Set(editorIds).size === 16 && new Set(titles).size === 16;
    if (valid) {
      pass("Daedric title authority", "All 16 distinct Daedric commitment MESG titles are present in the locked record contract.", DAEDRIC_CONTRACT);
    } else {
      fail("Daedric title authority", "Expected 16 distinct, titled commitment MessageBox contracts.", DAEDRIC_CONTRACT);
    }
  } catch (error) {
    fail("Daedric title authority", `Could not parse the record contract: ${error.message}`, DAEDRIC_CONTRACT);
  }
}

function requireSnippet(text, snippet, check, detail, filePath, pass, fail) {
  if (text.includes(snippet)) {
    pass(check, detail, filePath);
  } else {
    fail(check, `Missing required snippet: ${snippet}`, filePath);
  }
}

function extractFunction(text, functionName) {
  const start = text.indexOf(`Function ${functionName}(`);
  if (start < 0) return "";
  const end = text.indexOf("\nEndFunction", start);
  if (end < 0) return text.slice(start);
  return text.slice(start, end + "\nEndFunction".length);
}

function printTextSummary(summary) {
  console.log(`PDV Prisma parity Unit D check: ${summary.status}`);
  console.log(`Summary: PASS=${summary.passCount}, FAIL=${summary.failCount}`);
  for (const finding of summary.findings) {
    console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${finding.path ? ` [${finding.path}]` : ""}`);
  }
}

function toDisplayPath(filePath) {
  return path.relative(PROJECT_ROOT, filePath).replaceAll("\\", "/");
}
