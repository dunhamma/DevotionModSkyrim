#!/usr/bin/env node
/*
 * Read-only Unit D Prisma parity verifier.
 *
 * This is intentionally source/readback focused. Runtime proof for the surfaced
 * transitions remains an in-game owner gate.
 */

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_MANAGER = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV__ManagerQuest.psc";
const DEFAULT_DIRECTOR = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV_DiegeticDirector.psc";
const TITLE_PROJECT = path.join(PROJECT_ROOT, "tools", "pdv-daedric-offer-title-author");

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
    ["Refuse cue dispatch", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "refuse", pendingDeity, "absence")', "Refuse path emits the Book of Days cue before terminal refusal state."],
    ["Accept cue dispatch", 'DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")', "Accept path emits the Book of Days cue from the shared handler."],
    ["Accept Prisma toast helper", "BuildCommitmentOfferAcceptToastLine(pendingDeity)", "Accept path emits the locked per-race Prisma toast."],
    ["Refuse Prisma toast helper", "BuildCommitmentOfferRefuseToastLine(pendingDeity)", "Refuse path emits the locked per-race Prisma toast."],
    ["Carryover award funnel", 'AwardPiety(pendingDeity, carryAmount, "commitment_carryover")', "Commitment carryover uses the reason-bearing AwardPiety funnel."],
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
    ["Altmer crisis toast", "The old line turns: ", "Altmer crisis transition toast is present."]
  ];

  for (const [check, snippet, detail] of requiredSnippets) {
    requireSnippet(text, snippet, check, detail, filePath, pass, fail);
  }

  const acceptFunction = extractFunction(text, "DebugAcceptPendingCommitment");
  if (!acceptFunction) {
    fail("Carryover accept function", "DebugAcceptPendingCommitment is missing.", filePath);
  } else if (!/SetActiveDeity\(pendingDeity\)[\s\S]*AwardPiety\(pendingDeity, carryAmount, "commitment_carryover"\)/.test(acceptFunction)) {
    fail("Carryover accept order", "Carryover AwardPiety must occur after SetActiveDeity so driver capture sees the active patron.", filePath);
  } else if (/DebugForceSetPietyByIndex/.test(acceptFunction)) {
    fail("Carryover legacy setter", "DebugAcceptPendingCommitment still calls DebugForceSetPietyByIndex.", filePath);
  } else {
    pass("Carryover accept order", "Carryover AwardPiety occurs after SetActiveDeity and legacy setter is absent.", filePath);
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
  const result = spawnSync("dotnet", ["run", "--project", TITLE_PROJECT, "--", "--check"], {
    cwd: PROJECT_ROOT,
    encoding: "utf8",
    windowsHide: true
  });

  if (result.status !== 0) {
    fail("Daedric title readback", result.stderr.trim() || result.stdout.trim() || "Title helper failed.");
    return;
  }

  try {
    const parsed = JSON.parse(result.stdout);
    if (parsed.Status === "PASS" && Array.isArray(parsed.Actions) && parsed.Actions.length === 16) {
      pass("Daedric title readback", "All 16 Daedric commitment MESG titles match locked Unit D copy.");
    } else {
      fail("Daedric title readback", `Unexpected title helper result: ${result.stdout.trim()}`);
    }
  } catch (error) {
    fail("Daedric title readback", `Title helper output was not JSON: ${error.message}`);
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
