#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { hashByteFiles, hashText } from "./lib/pdv_file_compare.mjs";

const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_prisma_ui_audit" });
const JSON_OUTPUT = process.argv.includes("--json");

const DEVOTION_SOURCE = process.env.PDV_PRISMA_AUDIT_SOURCE_ROOT || "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts\\Source";
const DEVOTION_COMPILED = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts";
const DEVOTION_PRISMA_VIEW = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\PrismaUI\\views\\Devotion\\app.js";
const DEVOTION_PRISMA_INDEX = path.join(path.dirname(DEVOTION_PRISMA_VIEW), "index.html");
const REPO_ROOT = process.cwd();
const NATIVE_BRIDGE_SOURCE = path.join(REPO_ROOT, "native", "DevotionPrismaBridge", "src", "main.cpp");
const MANAGER_SOURCE = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
const MCM_SOURCE = path.join(DEVOTION_SOURCE, "PDV_MCM.psc");
const MANAGER_PEX = path.join(DEVOTION_COMPILED, "PDV__ManagerQuest.pex");
const MCM_PEX = path.join(DEVOTION_COMPILED, "PDV_MCM.pex");
const DAEDRIC_CONTRACT = path.join(REPO_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");
const MEDALLION_ROSTER_MANIFEST = path.join(REPO_ROOT, "references", "authoring", "PDV_MedallionRoster.manifest.json");
const REPO_PRISMA_VIEW_DIR = path.join(REPO_ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion");
const REPO_PRISMA_APP = path.join(REPO_PRISMA_VIEW_DIR, "app.js");
const REPO_PRISMA_STYLE = path.join(REPO_PRISMA_VIEW_DIR, "styles.css");
const REPO_PRISMA_INDEX = path.join(REPO_PRISMA_VIEW_DIR, "index.html");
const REPO_MANAGER_SOURCE = path.join(REPO_ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const BRIDGE_PSC_LIVE = path.join(DEVOTION_SOURCE, "PDV_PrismaBridge.psc");
const BRIDGE_PSC_REPO = path.join(REPO_ROOT, "native", "DevotionPrismaBridge", "mod", "Scripts", "Source", "PDV_PrismaBridge.psc");

function fail(message, source = "") {
  failures.push({ message, source });
}

function pass(message, source = "") {
  passes.push({ message, source });
}

function read(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function mtime(filePath) {
  return fs.statSync(filePath).mtimeMs;
}

// Hash of content with line endings normalized. The repo bridge mirror is CRLF
// while the live copy has mixed CRLF/LF, so a raw byte hash reports drift on two
// files that are textually identical -- a false FAIL on exactly the check that is
// supposed to catch real drift. Compare what the compiler sees: the text.
function normalizedHash(filePath) {
  return hashText(filePath);
}

// The repo bridge mirror is what anyone building the DLL compiles against, but
// every other check in this audit reads the LIVE tree. That gap let the mirror
// sit two commits behind live (missing IsPanelVisible, which PDV_MCM.psc calls)
// without any gate noticing. Compare the two directly.
function requireBridgeSourceParity() {
  if (!exists(BRIDGE_PSC_LIVE)) {
    fail("Live PDV_PrismaBridge.psc is missing.", BRIDGE_PSC_LIVE);
    return;
  }
  if (!exists(BRIDGE_PSC_REPO)) {
    fail("Repository PDV_PrismaBridge.psc mirror is missing.", BRIDGE_PSC_REPO);
    return;
  }

  if (normalizedHash(BRIDGE_PSC_LIVE) !== normalizedHash(BRIDGE_PSC_REPO)) {
    const liveDecls = declaredBridgeNatives(BRIDGE_PSC_LIVE);
    const repoDecls = declaredBridgeNatives(BRIDGE_PSC_REPO);
    const missing = liveDecls.filter((name) => !repoDecls.includes(name));
    const extra = repoDecls.filter((name) => !liveDecls.includes(name));
    const detail = [
      missing.length ? `missing from repo mirror: ${missing.join(", ")}` : "",
      extra.length ? `present only in repo mirror: ${extra.join(", ")}` : "",
    ].filter(Boolean).join("; ");
    fail(
      `PDV_PrismaBridge.psc repo mirror drifted from live${detail ? ` (${detail})` : ""}. Anyone compiling from the repo tree will not match the shipped bridge.`,
      BRIDGE_PSC_REPO,
    );
    return;
  }

  pass(
    `PDV_PrismaBridge.psc repo mirror matches live (${declaredBridgeNatives(BRIDGE_PSC_LIVE).length} native declarations).`,
    BRIDGE_PSC_REPO,
  );
}

function declaredBridgeNatives(filePath) {
  return [...read(filePath).matchAll(/^\s*\w+\s+Function\s+(\w+)\s*\(.*\)\s+Global\s+Native/gim)].map((m) => m[1]);
}

// Every native the C++ registers on PDV_PrismaBridge must be declared in the
// .psc, or the call is a compile error rather than a runtime miss.
function requireBridgeNativesDeclared() {
  if (!exists(NATIVE_BRIDGE_SOURCE) || !exists(BRIDGE_PSC_LIVE)) {
    return;
  }

  const registered = [...read(NATIVE_BRIDGE_SOURCE).matchAll(/RegisterFunction\s*(?:<[^>]*>)?\s*\(\s*"(\w+)"/g)].map((m) => m[1]);
  if (!registered.length) {
    fail("Could not parse any RegisterFunction calls from the native bridge; the declaration check would silently pass.", NATIVE_BRIDGE_SOURCE);
    return;
  }

  const declared = declaredBridgeNatives(BRIDGE_PSC_LIVE);
  const undeclared = [...new Set(registered)].filter((name) => !declared.includes(name));
  if (undeclared.length) {
    fail(
      `C++ registers PDV_PrismaBridge natives with no Papyrus declaration: ${undeclared.join(", ")}.`,
      BRIDGE_PSC_LIVE,
    );
  } else {
    pass(
      `All ${new Set(registered).size} C++-registered PDV_PrismaBridge natives are declared in Papyrus.`,
      BRIDGE_PSC_LIVE,
    );
  }
}

function isoMtime(filePath) {
  return fs.statSync(filePath).mtime.toISOString();
}

function requirePexAtLeastAsFresh(pexPath, dependencyPath, label) {
  if (!exists(pexPath)) {
    fail(`${label} PEX is missing.`, pexPath);
    return;
  }
  if (!exists(dependencyPath)) {
    fail(`${label} dependency is missing.`, dependencyPath);
    return;
  }
  if (mtime(pexPath) + 1000 >= mtime(dependencyPath)) {
    pass(`${label} PEX is fresh against ${path.basename(dependencyPath)}.`, pexPath);
  } else {
    fail(
      `${label} PEX is older than ${path.basename(dependencyPath)}; recompile before in-game Prisma testing (${path.basename(pexPath)} ${isoMtime(pexPath)} < ${path.basename(dependencyPath)} ${isoMtime(dependencyPath)}).`,
      pexPath,
    );
  }
}

function verifyJournalBytecodeFreshness() {
  requirePexAtLeastAsFresh(MANAGER_PEX, MANAGER_SOURCE, "Manager journal payload");
  requirePexAtLeastAsFresh(MCM_PEX, MCM_SOURCE, "Book of Days hotkey");

  if (!exists(MANAGER_SOURCE) || !exists(MCM_SOURCE) || !exists(MANAGER_PEX) || !exists(MCM_PEX)) {
    return;
  }

  const manager = read(MANAGER_SOURCE);
  const mcm = read(MCM_SOURCE);
  if (
    manager.includes("Function SendPrismaJournalPayload(Bool playerRequested") &&
    mcm.includes("PDV_Manager.SendPrismaJournalPayload(")
  ) {
    requirePexAtLeastAsFresh(MCM_PEX, MANAGER_SOURCE, "Book of Days hotkey dependency");
    requirePexAtLeastAsFresh(MCM_PEX, MANAGER_PEX, "Book of Days hotkey dependency");
  }

}

function verifyPrismaAssetCacheContract() {
  for (const assetPath of [REPO_PRISMA_APP, REPO_PRISMA_STYLE, REPO_PRISMA_INDEX]) {
    if (!exists(assetPath)) {
      fail("Prisma cache-contract asset is missing.", assetPath);
      return;
    }
  }

  const expectedKey = `pdv-${hashByteFiles([REPO_PRISMA_APP, REPO_PRISMA_STYLE]).slice(0, 16)}`;
  const index = read(REPO_PRISMA_INDEX);
  const styleMatch = index.match(/styles\.css\?v=([A-Za-z0-9_-]+)/);
  const appMatch = index.match(/app\.js\?v=([A-Za-z0-9_-]+)/);
  const styleKey = styleMatch?.[1] ?? "";
  const appKey = appMatch?.[1] ?? "";

  if (styleKey !== expectedKey || appKey !== expectedKey) {
    fail(`Prisma asset cache key must be ${expectedKey} for the current app.js + styles.css bytes (found CSS=${styleKey || "missing"}, JS=${appKey || "missing"}).`, REPO_PRISMA_INDEX);
  } else {
    pass(`Prisma app.js and styles.css share current content-derived cache key ${expectedKey}.`, REPO_PRISMA_INDEX);
  }

  const app = read(REPO_PRISMA_APP);
  if (
    !app.includes('state.instrument.primary !== undefined') ||
    !app.includes('clamp01(numberOrZero(state.instrument.primary))') ||
    !app.includes('const pietyPercent = Math.round(instrumentPrimary * 100);') ||
    app.includes('const pietyPercent = Math.min(100, Math.round((piety / 85) * 100));')
  ) {
    fail("Focused-panel progress meter must use the kind-normalized instrument primary value, not a fixed 85-point piety denominator.", REPO_PRISMA_APP);
  } else {
    pass("Focused-panel progress meter uses the kind-normalized instrument primary value (broad 50/50 and Argonian 75/75 render full).", REPO_PRISMA_APP);
  }

  const culturalUiTokens = [
    "const renderCulturalInstrument",
    "[1 / 75, 25 / 75, 1]",
    "cultural: renderCulturalInstrument",
    'cultural: "Cultural practice"',
    'broad: "Pantheon standing"',
  ];
  if (culturalUiTokens.some((token) => !app.includes(token)) || app.includes("detail.textContent = kind;")) {
    fail("Prisma must render Argonian cultural practice as a 75-point instrument and translate internal instrument kinds into player-facing captions.", REPO_PRISMA_APP);
  } else {
    pass("Prisma renders the 75-point Argonian cultural instrument and hides internal instrument-kind tokens from player captions.", REPO_PRISMA_APP);
  }

  const patchSourceUiTokens = [
    'const sourceName = text(copy.source, "");',
    'source.className = "toast__source";',
    'text(copy.source, ""),',
    'const sourceName = text(entry.source, "");',
    'sourceEl.className = "bod-leaf__source";',
  ];
  if (patchSourceUiTokens.some((token) => !app.includes(token))) {
    fail("Prisma must render the optional source-mod label on quest-reaction toasts and Book of Days entries.", REPO_PRISMA_APP);
  } else {
    pass("Prisma renders optional source-mod labels on both quest-reaction player surfaces.", REPO_PRISMA_APP);
  }

  if (!exists(REPO_MANAGER_SOURCE)) {
    fail("Repository manager source is missing for the Argonian panel payload contract.", REPO_MANAGER_SOURCE);
    return;
  }
  const manager = read(REPO_MANAGER_SOURCE);
  const patchSourceManagerTokens = [
    'JsonUtil.GetStringValue(matrixFile, "sourceMod")',
    'prefix + "SourceModName"',
    'SendPrismaToastWithSource(',
    '"PDV.Diegetic.Journal.Sources"',
    'JsonSafeString(sourceModName)',
  ];
  if (patchSourceManagerTokens.some((token) => !manager.includes(token))) {
    fail("Manager must carry PatchHub sourceMod metadata into Prisma and Book of Days payloads.", REPO_MANAGER_SOURCE);
  } else {
    pass("Manager carries PatchHub sourceMod metadata into Prisma and Book of Days payloads.", REPO_MANAGER_SOURCE);
  }
  const culturalManagerTokens = [
    'return "cultural"',
    'return "Root Memory at 1"',
    'return "River-Kept Practice at 25"',
    'return "Rooted Adaptation at 75"',
    'piety / 75.0',
    'cultural practice',
  ];
  if (culturalManagerTokens.some((token) => !manager.includes(token))) {
    fail("Manager focused-panel payload must expose Argonian cultural practice with 1/25/75 thresholds and a 75-point normalized instrument.", REPO_MANAGER_SOURCE);
  } else {
    pass("Manager focused-panel payload exposes Argonian cultural practice with the locked 1/25/75 semantics.", REPO_MANAGER_SOURCE);
  }
}

function functionBlock(source, functionName) {
  const pattern = new RegExp(`(?:[A-Za-z_][\\w]*\\s+)?Function\\s+${functionName}\\b[\\s\\S]*?EndFunction`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
}

function eventBlock(source, eventName) {
  const pattern = new RegExp(`Event\\s+${eventName}\\b[\\s\\S]*?EndEvent`, "i");
  const match = source.match(pattern);
  return match ? match[0] : "";
}

function functionNamesContaining(source, literal) {
  const result = [];
  const pattern = /(?:Bool\s+)?Function\s+(\w+)\b[\s\S]*?EndFunction/gi;
  let match;
  while ((match = pattern.exec(source))) {
    if (match[0].includes(literal)) {
      result.push(match[1]);
    }
  }
  return result.sort();
}

function countMatches(source, pattern) {
  const matches = source.match(pattern);
  return matches ? matches.length : 0;
}

function lineNumberAt(source, index) {
  return source.slice(0, index).split(/\r?\n/).length;
}

function extractFunctionBlocks(source) {
  const blocks = [];
  const pattern = /(?:[A-Za-z_][\w]*\s+)?Function\s+(\w+)\b[\s\S]*?\nEndFunction\b/gi;
  let match;
  while ((match = pattern.exec(source))) {
    blocks.push({
      name: match[1],
      body: match[0],
      start: match.index,
      end: match.index + match[0].length,
    });
  }
  return blocks;
}

function enclosingFunctionName(blocks, index) {
  const block = blocks.find((item) => item.start <= index && index <= item.end);
  return block ? block.name : "";
}

function extractCalls(source, functionName) {
  const calls = [];
  const needle = `${functionName}(`;
  let index = 0;
  while ((index = source.indexOf(needle, index)) >= 0) {
    const prefix = source.slice(Math.max(0, index - 40), index);
    if (/\bFunction\s+$/.test(prefix)) {
      index += needle.length;
      continue;
    }
    let cursor = index + needle.length;
    let depth = 1;
    let inString = false;
    while (cursor < source.length && depth > 0) {
      const char = source[cursor];
      if (char === '"') {
        inString = !inString;
      } else if (!inString && char === "(") {
        depth += 1;
      } else if (!inString && char === ")") {
        depth -= 1;
      }
      cursor += 1;
    }
    const text = source.slice(index, cursor);
    const argText = text.slice(needle.length, -1);
    calls.push({
      text,
      args: splitArguments(argText),
      index,
      line: lineNumberAt(source, index),
    });
    index = cursor;
  }
  return calls;
}

function splitArguments(argText) {
  const args = [];
  let current = "";
  let depth = 0;
  let inString = false;
  for (let i = 0; i < argText.length; i += 1) {
    const char = argText[i];
    if (char === '"') {
      inString = !inString;
      current += char;
    } else if (!inString && char === "(") {
      depth += 1;
      current += char;
    } else if (!inString && char === ")") {
      depth -= 1;
      current += char;
    } else if (!inString && depth === 0 && char === ",") {
      args.push(current.trim());
      current = "";
    } else {
      current += char;
    }
  }
  if (current.trim() !== "") {
    args.push(current.trim());
  }
  return args;
}

function stringLiteralValue(arg) {
  const trimmed = (arg || "").trim();
  if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) {
    return trimmed.slice(1, -1);
  }
  return null;
}

function journalToneBranches(manager, functionName) {
  const block = functionBlock(manager, functionName);
  const tones = new Set();
  const pattern = /toneKey\s*==\s*"([^"]+)"/g;
  let match;
  while ((match = pattern.exec(block))) {
    tones.add(match[1]);
  }
  return tones;
}

function transitionTone(eventClass, direction) {
  if (eventClass === "reorientation") {
    return "reorientation";
  }
  if (eventClass === "digest") {
    return "dawn.digest";
  }
  return `${eventClass}.${direction}`;
}

function sameStringSet(actual, expected) {
  if (actual.length !== expected.length) {
    return false;
  }
  return actual.every((value, index) => value === expected[index]);
}

function verifyJournalToneContract(manager, managerPath) {
  const titleTones = journalToneBranches(manager, "JournalToneToTitle");
  const valenceTones = journalToneBranches(manager, "JournalToneToValence");
  const usedTones = new Set();

  for (const call of extractCalls(manager, "AppendBookOfDaysEntry")) {
    const tone = stringLiteralValue(call.args[2]);
    if (tone) {
      usedTones.add(tone);
    }
  }

  for (const call of extractCalls(manager, "SurfaceTransition")) {
    const eventClass = stringLiteralValue(call.args[0]);
    const direction = stringLiteralValue(call.args[2]);
    if (eventClass && direction) {
      usedTones.add(transitionTone(eventClass, direction));
    }
  }

  const missingTitle = [...usedTones].filter((tone) => !titleTones.has(tone)).sort();
  const missingValence = [...usedTones].filter((tone) => !valenceTones.has(tone)).sort();
  if (missingTitle.length > 0 || missingValence.length > 0) {
    if (missingTitle.length > 0) {
      fail(`Book of Days tone title coverage is missing: ${missingTitle.join(", ")}.`, managerPath);
    }
    if (missingValence.length > 0) {
      fail(`Book of Days tone valence coverage is missing: ${missingValence.join(", ")}.`, managerPath);
    }
  } else {
    pass(`Book of Days tone coverage supports all ${usedTones.size} literal journal tones used by append/transition producers.`, managerPath);
  }
}

function verifySubstrateChronicleContract(manager, managerPath) {
  const functionBlocks = extractFunctionBlocks(manager);
  const directCalls = extractCalls(manager, "SendPrismaSubstrateToast")
    .filter((call) => enclosingFunctionName(functionBlocks, call.index) !== "SendPrismaSubstrateProgress");
  const reasonBearingPhases = new Set(["act", "water"]);
  const pureFlavorPhases = new Set(["shadowscale", "dream"]);
  let checked = 0;

  for (const call of directCalls) {
    const phase = stringLiteralValue(call.args[1]);
    const functionName = enclosingFunctionName(functionBlocks, call.index);
    const block = functionBlocks.find((item) => item.name === functionName)?.body || "";
    if (reasonBearingPhases.has(phase)) {
      checked += 1;
      if (!block.includes("AppendBookOfDaysEntry(") || !block.includes('"substrate.act"')) {
        fail(`Reason-bearing direct substrate toast at line ${call.line} (${functionName}, phase=${phase}) lacks a substrate.act Book of Days write.`, managerPath);
      }
    } else if (!pureFlavorPhases.has(phase)) {
      fail(`Direct substrate toast at line ${call.line} (${functionName}) uses unclassified phase ${phase || "<dynamic>"}; classify it as reason-bearing or pure flavor.`, managerPath);
    }
  }

  if (failures.length === 0 || checked > 0) {
    pass(`Direct reason-bearing substrate toasts are paired with Book of Days writes (${checked} checked).`, managerPath);
  }
}

function verifySessionCopyContracts(manager, managerPath) {
  const forbiddenManagerPhrases = [
    "You worship the Divines broadly through your civic service.",
    "Your service to the public order has been felt as worship.",
    "You worship the Nine Divines broadly, civic and public.",
    "On the Talos question you stand ",
  ];
  for (const phrase of forbiddenManagerPhrases) {
    if (manager.includes(phrase)) {
      fail(`Player-facing Imperial copy still contains stale phrase/token: ${phrase}`, managerPath);
    }
  }

  const dunmerSurvey = functionBlock(manager, "GetDunmerSurveyText");
  if (
    dunmerSurvey.includes(" -- ") ||
    !dunmerSurvey.includes("The beast, or an unclean rite, makes the ash-prayer carry thinly.") ||
    !dunmerSurvey.includes("your posture is restored, but scarred")
  ) {
    fail("Dunmer Survey curse-posture copy must avoid dash punctuation and explicitly surface restored, but scarred recovery.", managerPath);
  } else {
    pass("Dunmer Survey curse-posture copy avoids dash punctuation and names restored, but scarred recovery.", managerPath);
  }

  const bretonSurvey = functionBlock(manager, "GetBretonSurveyText");
  const bretonPatronSurvey = functionBlock(manager, "GetBretonPatronSurveySentence");
  const bretonChampionPresentation = functionBlock(manager, "MaybeShowBretonChampionBoonPresentation");
  const bretonChampionBoonName = functionBlock(manager, "GetBretonChampionBoonDisplayName");
  if (
    bretonSurvey.includes('" Standing: " + band') ||
    bretonSurvey.includes("open but unproven") ||
    bretonSurvey.includes("practice points).") ||
    !bretonSurvey.includes('String practiceText = " Practice: " + GetPublicTierBand(practiceTier) + "."') ||
    !bretonSurvey.includes('text = text + " Y\'ffre is listening."') ||
    !bretonSurvey.includes("the old covenant accepts your shape")
  ) {
    fail("Breton Survey must lead with one qualitative practice band, omit numeric points and unrelated generic standing, and keep Green Way pressure/fork copy concise.", managerPath);
  } else {
    pass("Breton Survey leads with one qualitative practice band, omits numeric points, and keeps Green Way pressure/fork copy concise.", managerPath);
  }

  if (
    bretonPatronSurvey.includes("tradition's highest blessing") ||
    bretonPatronSurvey.includes("patron's mark") ||
    bretonPatronSurvey.includes("20C path") ||
    !bretonPatronSurvey.includes('String pactName = GetPublicDeityDisplayName(activePact)') ||
    !bretonPatronSurvey.includes('return " Your pact with " + pactName + " stands beside the tradition."') ||
    !bretonPatronSurvey.includes('has opened Hidden Art - Champion.') ||
    bretonPatronSurvey.includes('Hidden Art - Champion stands beside the pact.') ||
    !bretonPatronSurvey.includes("GetBretonChampionBoonDisplayName(_activeDeity)") ||
    bretonChampionPresentation.includes("GetBretonChampionBoonDisplayName(_activeDeity)") ||
    bretonChampionPresentation.includes("stands beside") ||
    !bretonChampionPresentation.includes("if championSource as PDV_DaedricPathBase") ||
    !bretonChampionPresentation.includes('String line = deityName + " names you Champion."') ||
    !bretonChampionPresentation.includes('line = deityName + " names you Champion through the " + traditionLabel + "."') ||
    !bretonChampionBoonName.includes('return "Knight\'s Bulwark - Champion"') ||
    !bretonChampionBoonName.includes('return "Magnus\'s Aperture - Champion"') ||
    !bretonChampionBoonName.includes('return "Hidden Art - Champion"')
  ) {
    fail("Breton Champion Survey must name the pact and actual boon once, while toast/Book copy stays to one patron-recognition sentence.", managerPath);
  } else {
    pass("Breton Champion Survey names the pact and actual boon once; toast/Book copy stays to one patron-recognition sentence.", managerPath);
  }

  const dunmerGoodDaedraShrine = functionBlock(manager, "HandleDunmerOutdoorGoodDaedraShrine");
  if (
    !dunmerGoodDaedraShrine.includes('SendPrismaToast("journal", "good", "Good Daedra", "The Good Daedra hear the ash-prayer.")') ||
    !dunmerGoodDaedraShrine.includes('SendPrismaToast("journal", "neutral", "Shrine quiet", "The shrine is quiet in this hour.")') ||
    dunmerGoodDaedraShrine.includes('Debug.Notification("The Good Daedra hear the ash-prayer.")') ||
    dunmerGoodDaedraShrine.includes('Debug.Notification("The shrine is quiet in this hour.")')
  ) {
    fail("Dunmer outdoor Good Daedra shrine route must surface Prisma toasts for the in-window prayer and quiet-hour fallback.", managerPath);
  } else {
    pass("Dunmer outdoor Good Daedra shrine route has in-window and quiet-hour Prisma toasts.", managerPath);
  }

  const dunmerDeviationPrice = functionBlock(manager, "HandleDunmerDeviationPrice");
  const dunmerDeviationNotice = functionBlock(manager, "SurfaceDunmerDeviationPriceNotice");
  if (
    !dunmerDeviationPrice.includes("SurfaceDunmerDeviationPriceNotice()") ||
    !dunmerDeviationNotice.includes('AppendBookOfDaysEntry(line, today, "creed.drop", symbolName, False, 2, "Reclamation strained")') ||
    !dunmerDeviationNotice.includes('SendPrismaToast(symbolName, "warning", "Reclamation strained", line)') ||
    !dunmerDeviationNotice.includes('"The ash-prayer thins; "')
  ) {
    fail("Dunmer deviation-price route must feed the Book of Days Chronicle and a warning Prisma toast.", managerPath);
  } else {
    pass("Dunmer deviation-price route feeds the Book of Days Chronicle and warning Prisma toast.");
  }

  const acceptToast = functionBlock(manager, "BuildCommitmentOfferAcceptToastLine");
  const refuseToast = functionBlock(manager, "BuildCommitmentOfferRefuseToastLine");
  if (
    !acceptToast.includes('return patron + " has named you their own."') ||
    acceptToast.includes("broad faith narrows")
  ) {
    fail("Commitment accept toast must stay concise and start with the patron naming line.", managerPath);
  } else {
    pass("Commitment accept toast copy is centralized and concise.", managerPath);
  }

  if (!refuseToast.includes('return "You turned " + patron + " away."')) {
    fail("Commitment refusal toast must stay concise; the permanent refusal explanation belongs in the authored response and journal surfaces.", managerPath);
  } else {
    pass("Commitment refusal toast copy is centralized and concise.", managerPath);
  }
}

function verifyDaedricToastContracts(manager, managerPath) {
  const milestoneBlock = functionBlock(manager, "ShowDaedricMilestonePresentation");
  const milestoneSenderBlock = functionBlock(manager, "SendPrismaDaedricMilestoneToast");
  const senderBlock = functionBlock(manager, "SendPrismaDaedricToast");
  const replayBlock = functionBlock(manager, "ReplayConcreteDaedricChampionOffer");
  const residueBlock = functionBlock(manager, "DrainHircineResiduePrismaToasts");
  const nordCurseBlock = functionBlock(manager, "ApplyCurseRaceHandlers");
  if (!milestoneBlock.includes('SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)')) {
    fail("Daedric milestone presentation must emit the paired boon toast after the milestone toast.", managerPath);
  } else {
    pass("Daedric milestone presentation emits the paired boon toast.", managerPath);
  }

  if (
    milestoneSenderBlock.includes("QueuePrismaToastRetry") ||
    manager.includes("Function ProcessQueuedPrismaToastRetry")
  ) {
    fail("Successful Daedric milestone sends must not be resent; the native bridge already queues cold-DOM overlays.", managerPath);
  } else {
    pass("Daedric milestone recognition has no unconditional duplicate retry.", managerPath);
  }

  if (!senderBlock.includes('if phase == "boon"') || !senderBlock.includes('j = j + ",\\\"tone\\\":\\\"good\\\""')) {
    fail("Daedric boon payloads must explicitly declare a good tone instead of relying on UI inference.", managerPath);
  } else {
    pass("Daedric boon payloads explicitly declare a good tone.", managerPath);
  }

  const concreteScripts = [
    "Boethiah", "Azura", "Vaermina", "Meridia", "Molag", "Mephala", "Malacath", "Dagon",
    "Sheo", "Namira", "Sanguine", "Vile", "Mora", "Nocturnal", "Peryite", "Hircine",
  ];
  if (
    !milestoneBlock.includes("ReplayConcreteDaedricChampionOffer(path, oldTier, newTier)") ||
    milestoneBlock.includes("path.ShowTierEntryMessage(oldTier, newTier)") ||
    concreteScripts.some((stem) => !replayBlock.includes(`pathForm as PDV_DaedricPath_${stem}`))
  ) {
    fail("Controlled Champion replay must resolve each concrete Prince script; the co-attached base script has an empty offer hook.", managerPath);
  } else {
    pass("Controlled Champion replay resolves all sixteen concrete Prince scripts.", managerPath);
  }

  verifyDaedricMechanicTextContract(manager, managerPath);

  if (
    !residueBlock.includes('SendPrismaDaedricToast("Hircine", "residue", "The hunt\\\'s old mark still follows.", "hircine")') &&
    !residueBlock.includes('SendPrismaDaedricToast("Hircine", "residue", "The hunt\'s old mark still follows.", "hircine")')
  ) {
    fail("Hircine residue onset must drain to a Prisma residue toast.", managerPath);
  } else if (!residueBlock.includes('SendPrismaDaedricToast("Hircine", "residue", "The hunt\\\'s old mark fades.", "hircine")') && !residueBlock.includes('SendPrismaDaedricToast("Hircine", "residue", "The hunt\'s old mark fades.", "hircine")')) {
    fail("Hircine residue clear must drain to a Prisma residue toast.", managerPath);
  } else {
    pass("Hircine residue onset and clear both drain to Prisma residue toasts.", managerPath);
  }

  if (
    !nordCurseBlock.includes('AppendBookOfDaysEntry("The beast-blood took you and stirred Hircine. The Hunt is in you now."') ||
    !nordCurseBlock.includes('"curse.onset"')
  ) {
    fail("Hircine werewolf curse entry must write a Book of Days curse-onset entry.", managerPath);
  } else {
    pass("Hircine werewolf curse entry writes a Book of Days curse-onset entry.", managerPath);
  }
}

function mechanicRows(block) {
  const rows = new Map();
  const pattern = /(?:if|elseIf)\s+\(princeName == "([^"]+)"(?:\s+\|\|\s+princeName == "[^"]+")?\)\s+&&\s+tierValue == (TIER_[A-Z]+)\s*\r?\n\s*return "([^"]+)"/g;
  let match;
  while ((match = pattern.exec(block))) {
    rows.set(`${match[1]}|${match[2]}`, match[3]);
  }
  return rows;
}

function expectedDaedricMechanicText(princeName, effects, kind) {
  if (princeName === "Namira" && kind === "boon") {
    return "Feeding restores Health and Stamina";
  }

  const labels = {
    OneHanded: "One-handed",
    Speechcraft: "Speech",
    ResistMagic: "Magic resistance",
    Stamina: "Stamina",
    Illusion: "Illusion",
    Health: "Health",
    Restoration: "Restoration",
    Sneak: "Sneak",
    DamageResist: "Armor rating",
    SpeedMult: "Movement speed",
    AttackDamageMult: "Attack damage",
    Magicka: "Magicka",
    CarryWeight: "Carry weight",
    Alteration: "Alteration",
    Lockpicking: "Lockpicking",
    ResistDisease: "Disease resistance",
  };
  const percentActorValues = new Set(["ResistMagic", "SpeedMult", "AttackDamageMult", "ResistDisease"]);
  return effects.map((effect) => {
    const magnitude = Number(effect.magnitude);
    const signedMagnitude = magnitude > 0 ? `+${magnitude}` : String(magnitude);
    const suffix = percentActorValues.has(effect.actorValue) ? `${signedMagnitude}%` : signedMagnitude;
    return `${suffix} ${labels[effect.actorValue] || effect.actorValue}`;
  }).join("; ");
}

function verifyDaedricMechanicTextContract(manager, managerPath) {
  if (!exists(DAEDRIC_CONTRACT)) {
    fail("Daedric record contract is missing; Prisma mechanic copy cannot be checked.", DAEDRIC_CONTRACT);
    return;
  }

  const contract = JSON.parse(read(DAEDRIC_CONTRACT));
  const boonRows = mechanicRows(functionBlock(manager, "GetDaedricBoonMechanicText"));
  const priceRows = mechanicRows(functionBlock(manager, "GetDaedricPriceMechanicText"));
  const tiers = ["TIER_SEEKER", "TIER_DEVOTED", "TIER_CHAMPION"];
  const mismatches = [];
  for (const prince of contract.princes || []) {
    for (let index = 0; index < tiers.length; index += 1) {
      const key = `${prince.displayName}|${tiers[index]}`;
      const expectedBoon = expectedDaedricMechanicText(prince.displayName, prince.boons[index].effects, "boon");
      const expectedPrice = expectedDaedricMechanicText(prince.displayName, prince.prices[index].effects, "price");
      if (boonRows.get(key) !== expectedBoon) mismatches.push(`${key} boon expected '${expectedBoon}' got '${boonRows.get(key) || "missing"}'`);
      if (priceRows.get(key) !== expectedPrice) mismatches.push(`${key} price expected '${expectedPrice}' got '${priceRows.get(key) || "missing"}'`);
    }
  }

  if (mismatches.length > 0) {
    fail(`Daedric Prisma mechanic copy drifts from the record contract (${mismatches.slice(0, 4).join("; ")}).`, managerPath);
  } else {
    pass("Daedric Prisma mechanic copy matches all 96 boon/price tier rows in the record contract.", managerPath);
  }
}

function verifyKynarethMedallionContract(manager, app, managerPath, appPath) {
  if (app.includes('kynareth: "kyne"')) {
    fail("Prisma symbol aliases must not collapse Kynareth into Kyne.", appPath);
  } else {
    pass("Prisma keeps Kynareth and Kyne as distinct symbol tokens.", appPath);
  }

  const requiredManagerFragments = [
    'RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", PDV_Kynareth',
    'elseIf optionId == "kynareth"',
    'return PDV_Kynareth',
    'elseIf deity == PDV_Kynareth',
    'return "kynareth"',
    'elseIf optionId == "kynareth"',
    'return originRace == ORIGIN_NORD || originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_BRETON',
    'if PDV_Kynareth && PDV_Kynareth.DeityIndex == deityIndex',
  ];
  const missing = requiredManagerFragments.filter((fragment) => !manager.includes(fragment));
  if (missing.length > 0) {
    fail(`Kynareth medallion/display contract is incomplete; missing ${missing.length} expected fragment(s).`, managerPath);
  } else {
    pass("Kynareth medallion/display contract is distinct from Kyne and restorable by deity index.", managerPath);
  }
}

function verifySyrabaneDisplayContract(manager, app, managerPath, appPath) {
  const requiredManagerFragments = [
    'PDV_Trinimac || deity == PDV_Syrabane',
    'RosterMedallionEntry("syrabane", "Syrabane", "god", "syrabane", PDV_Syrabane',
    'deity.DeityName == "Syrabane"',
    'return "syrabane"',
  ];
  const missingManager = requiredManagerFragments.filter((fragment) => !manager.includes(fragment));
  if (manager.includes('PendingMedallionEntry("syrabane"')) {
    missingManager.push("Syrabane still emitted as pending medallion entry");
  }

  const missingApp = [];
  if (!app.includes('["syrabane", "Syrabane"]')) missingApp.push("display label");
  if (!/syrabane:\s*\[/.test(app)) missingApp.push("glyph spec");

  if (missingManager.length > 0 || missingApp.length > 0) {
    fail(`Syrabane origin-roster/display contract is incomplete; manager missing ${missingManager.length}, Prisma missing ${missingApp.length}.`, missingManager.length > 0 ? managerPath : appPath);
  } else {
    pass("Syrabane origin-roster/display contract is live and has Prisma glyph coverage.", managerPath);
  }
}

function verifyAltmerCurrentRosterContract(manager, managerPath) {
  const rosterBlock = functionBlock(manager, "IsDashboardDeityInOriginRoster");
  const rosterMatch = rosterBlock.match(/elseIf originRace == ORIGIN_ALTMER[\s\S]*?(?=elseIf originRace == ORIGIN_BOSMER)/);
  const medallionBlock = functionBlock(manager, "GetAltmerMedallionEntriesJson");
  const requiredDeities = ["PDV_AuriEl", "PDV_Magnus", "PDV_Xarxes", "PDV_Syrabane", "PDV_Trinimac"];
  const deferredDeities = ["PDV_Mara", "PDV_Stendarr", "PDV_Yffre"];
  const requiredOptions = ["auri-el", "magnus", "xarxes", "syrabane", "trinimac"];
  const deferredOptions = ["mara", "stendarr", "yffre"];
  const rosterText = rosterMatch?.[0] ?? "";
  const repairBlock = functionBlock(manager, "RepairBookOfDaysJournalText");
  const pruneBlock = functionBlock(manager, "ShouldPruneDeferredAltmerJournalLine");

  let manifestOptions = [];
  if (exists(MEDALLION_ROSTER_MANIFEST)) {
    const manifest = JSON.parse(read(MEDALLION_ROSTER_MANIFEST));
    const altmer = (manifest.races ?? []).find((race) => race.raceId === "altmer");
    manifestOptions = (altmer?.sections ?? []).flatMap((section) => section.entries ?? []).map((entry) => entry.optionId);
  }

  const missing = requiredDeities.filter((name) => !rosterText.includes(name));
  const runtimeLeak = deferredDeities.filter((name) => rosterText.includes(name));
  const medallionMissing = requiredOptions.filter((id) => !medallionBlock.includes(`RosterMedallionEntry("${id}"`));
  const medallionLeak = deferredOptions.filter((id) => medallionBlock.includes(`RosterMedallionEntry("${id}"`));
  const manifestMissing = requiredOptions.filter((id) => !manifestOptions.includes(id));
  const manifestLeak = deferredOptions.filter((id) => manifestOptions.includes(id));
  const migrationMissing = !repairBlock.includes("Int repairVersion = 3") ||
    !repairBlock.includes("ShouldPruneDeferredAltmerJournalLine") ||
    !pruneBlock.includes("GetPlayerOriginRaceIndex() != ORIGIN_ALTMER") ||
    !["Mara", "Stendarr", "Y'ffre"].every((name) => pruneBlock.includes(`StringContainsToken(line, "${name}")`));

  if (!rosterText || missing.length || runtimeLeak.length || medallionMissing.length || medallionLeak.length || manifestMissing.length || manifestLeak.length || migrationMissing) {
    fail(`Altmer current-roster contract drift: missing=${missing.join("|") || "none"}, runtime-deferred=${runtimeLeak.join("|") || "none"}, medallion-missing=${medallionMissing.join("|") || "none"}, medallion-deferred=${medallionLeak.join("|") || "none"}, manifest-missing=${manifestMissing.join("|") || "none"}, manifest-deferred=${manifestLeak.join("|") || "none"}, migration-missing=${migrationMissing}.`, managerPath);
  } else {
    pass("Altmer current roster is limited to Auri-El, Magnus, Xarxes, Syrabane, and Trinimac; Mara, Stendarr, and Y'ffre remain deferred and are pruned from affected existing journals.", managerPath);
  }
}

function verifyBookOfDaysChronicleActionContract({ manager, eventBus, actionRouter, eventTypes, app, index, managerPath, eventBusPath, actionRouterPath, eventTypesPath, appPath, indexPath }) {
  const journalPayloadBlock = functionBlock(manager, "BuildJournalPayloadJson");
  const dashboardBlock = functionBlock(manager, "GetDashboardJson");
  const humanizerBlock = functionBlock(manager, "HumanizeDriverReason");
  const dawnBookBlock = functionBlock(manager, "RunDawnBookOfDays");
  const digestBlock = functionBlock(manager, "BuildBookOfDaysDigestLine");
  const deityDawnBlock = functionBlock(manager, "RunDawnConsolidateScratch");
  const princeDawnBlock = functionBlock(manager, "RunDawnConsolidateDaedricWeek");
  const readSkillIndex = humanizerBlock.indexOf('StringContainsToken(raw, "read-skill-book")');
  const broadBookIndex = humanizerBlock.indexOf('StringContainsToken(raw, "po3_book")');

  if (
    manager.includes("String Function BuildJournalPayloadJson(Int page") ||
    !journalPayloadBlock.includes('j = j + ",\\"entries\\":[" + entries + "]"') ||
    journalPayloadBlock.includes('"\\"entries\\":[]"' ) ||
    journalPayloadBlock.includes('j = j + ",\\"page\\":"') ||
    journalPayloadBlock.includes('j = j + ",\\"dashboard\\":" + GetDashboardJson()')
  ) {
    fail("Book of Days payload must remain Chronicle-only and carry entries on every open.", managerPath);
  } else {
    pass("Book of Days payload is Chronicle-only and carries entries on every open.", managerPath);
  }

  if (
    !dashboardBlock ||
    dashboardBlock.includes("shown < 8") ||
    !dashboardBlock.includes("Int originRace = GetPlayerOriginRaceIndex()") ||
    !dashboardBlock.includes("IsDashboardDeityInOriginRoster(deity, originRace)")
  ) {
    fail("Focused-panel Ledger must be uncapped but scoped to the player's origin roster.", managerPath);
  } else {
    pass("Focused-panel Ledger is uncapped within the player's origin roster.", managerPath);
  }

  const dashboardRosterBlock = functionBlock(manager, "IsDashboardDeityInOriginRoster");
  if (
    !dashboardRosterBlock.includes("originRace == ORIGIN_DUNMER") ||
    !dashboardRosterBlock.includes("deity == PDV_Azura || deity == PDV_Boethiah || deity == PDV_Mephala") ||
    !dashboardRosterBlock.includes("originRace == ORIGIN_KHAJIIT") ||
    !dashboardRosterBlock.includes("deity == PDV_Azura || deity == PDV_Boethiah || deity == PDV_Mephala || deity == PDV_BaanDar")
  ) {
    fail("Focused-panel Ledger roster filter must preserve native Dunmer and Khajiit deity/Prince packets.", managerPath);
  } else {
    pass("Focused-panel Ledger roster filter preserves native race deity/Prince packets.", managerPath);
  }

  const shrinePrayerAwardBlock = functionBlock(manager, "AwardShrinePrayerToDeityName");
  const shrineRosterGateIndex = shrinePrayerAwardBlock.indexOf("IsDashboardDeityInOriginRoster(deity, GetPlayerOriginRaceIndex())");
  const shrineAwardIndex = shrinePrayerAwardBlock.indexOf('AwardPiety(deity, 2.0, "shrine_prayer_" + sourceId)');
  if (
    shrineRosterGateIndex < 0 ||
    shrineAwardIndex < 0 ||
    shrineRosterGateIndex > shrineAwardIndex
  ) {
    fail("Divine shrine prayer awards must be gated by the player's origin roster before piety or Book of Days movement.", managerPath);
  } else {
    pass("Divine shrine prayer awards are gated by the player's origin roster before piety or Book of Days movement.", managerPath);
  }

  if (
    readSkillIndex < 0 ||
    broadBookIndex < 0 ||
    readSkillIndex > broadBookIndex ||
    !humanizerBlock.includes('return "reading instructive texts"') ||
    !humanizerBlock.includes('return "honing your skills"') ||
    !humanizerBlock.includes('return "discovering new roads"')
  ) {
    fail("Driver humanizer must prefer exact day-to-day event labels before broad fallback labels.", managerPath);
  } else {
    pass("Driver humanizer prefers exact day-to-day event labels before broad fallbacks.", managerPath);
  }

  const eventBusRoute = functionBlock(eventBus, "RouteActionWithAttribution");
  const actionRouterRoute = functionBlock(actionRouter, "RouteActionWithAttribution");
  const eventBusPassesReason =
    eventBusRoute.includes("PDV_Manager.AwardPiety(deity, delta, GetEventReason(eventType))") ||
    eventBusRoute.includes("PDV_Manager.AwardPietyFromLikesDislikes(deity, delta, eventType, GetEventReason(eventType))");
  if (
    !eventBusPassesReason ||
    !functionBlock(eventBus, "GetEventReason").includes("eventTypes.EventLabel(eventType)")
  ) {
    fail("EventBus routed piety must pass event-label driver reasons into AwardPiety.", eventBusPath);
  } else {
    pass("EventBus routed piety passes event-label driver reasons into AwardPiety.", eventBusPath);
  }

  const actionRouterPassesReason =
    actionRouterRoute.includes("PDV_Manager.AwardPiety(deity, delta, GetEventReason(eventType))") ||
    actionRouterRoute.includes("PDV_Manager.AwardPietyFromLikesDislikes(deity, delta, eventType, GetEventReason(eventType))");
  if (
    !actionRouterPassesReason ||
    !functionBlock(actionRouter, "GetEventReason").includes("eventTypes.EventLabel(eventType)")
  ) {
    fail("ActionRouter fallback piety must pass event-label driver reasons into AwardPiety.", actionRouterPath);
  } else {
    pass("ActionRouter fallback piety passes event-label driver reasons into AwardPiety.", actionRouterPath);
  }

  const requiredLabels = [
    'return "read-skill-book"',
    'return "read-spell-tome"',
    'return "read-lore-book"',
    'return "increase-skill"',
    'return "discover-location"',
    'return "harvest-ingredient"',
    'return "kill-daedra"',
    'return "killed-hostile-beast"',
    'return "accept-daedric-artifact"',
  ];
  const missingLabels = requiredLabels.filter((fragment) => !eventTypes.includes(fragment));
  if (missingLabels.length > 0) {
    fail(`EventTypes is missing ${missingLabels.length} representative day-to-day driver label(s).`, eventTypesPath);
  } else {
    pass("EventTypes exposes representative day-to-day driver labels.", eventTypesPath);
  }

  if (
    index.includes('data-journal-page=') ||
    index.includes('id="pdv-journal-tab-ledger"') ||
    index.includes('id="pdv-journal-feedback"') ||
    index.includes("bod-ledger") ||
    index.includes("What Feeds Your Gods") ||
    app.includes("const setJournalPage =") ||
    app.includes("const bindJournalTabs =") ||
    app.includes("renderJournalLedger(")
  ) {
    fail("Book of Days UI must remain Chronicle-only; Ledger belongs in the focused Devotion panel.", indexPath);
  } else {
    pass("Book of Days UI is Chronicle-only; no embedded Ledger/tab page is exposed.", indexPath);
  }

  if (
    !dawnBookBlock.includes("AppendBookOfDaysEntry(BuildBookOfDaysDigestLine(), today, \"dawn.digest\", \"journal\", False)") ||
    !digestBlock.includes('return "At dawn, your acts fed " + names + "."') ||
    !digestBlock.includes("if shown > 5") ||
    !manager.includes("Function RecordBookOfDaysFedName(String displayName)")
  ) {
    fail("Book of Days dawn digest must stay as one concise end-of-day fed-name entry.", managerPath);
  } else {
    pass("Book of Days dawn digest stays as one concise end-of-day fed-name entry.", managerPath);
  }

  if (
    !deityDawnBlock.includes("RecordBookOfDaysFedName(GetPublicDeityDisplayName(deity))") ||
    !princeDawnBlock.includes("PDV_DaedricPathBase path = pathForm as PDV_DaedricPathBase") ||
    !princeDawnBlock.includes("RecordBookOfDaysFedName(path.DeityName)") ||
    !princeDawnBlock.includes("_dawnHadActivity = True")
  ) {
    fail("Book of Days dawn digest must collect both deity and Prince positive daily movement before clearing PietyToday.", managerPath);
  } else {
    pass("Book of Days dawn digest collects both deity and Prince positive daily movement.", managerPath);
  }
}

function verifyParityRegistryContracts(registryPath) {
  if (!fs.existsSync(registryPath)) {
    fail("Prisma parity registry is missing.", registryPath);
    return;
  }
  const registry = read(registryPath);
  const staleFragments = [
    "Papyrus producer is absent",
    "only Debug.Notification; NO AwardPiety, NO AppendBookOfDaysEntry, NO SendPrismaEventToast",
    "GAP: no AppendBookOfDaysEntry and no RecordDaedricPathDriver at this site",
    "BeginNordResidueRecovery sets StorageUtil keys with no Prisma emit",
  ];
  for (const fragment of staleFragments) {
    if (registry.includes(fragment)) {
      fail(`Prisma parity registry still contains stale resolved-gap wording: ${fragment}`, registryPath);
    }
  }

  if (
    !registry.includes('"daedric.boon","daedric","ALL","n/a","Y","N","N"') ||
    !registry.includes('SendPrismaDaedricToast(princeName, ""boon"", boonText, symbolName)')
  ) {
    fail("Prisma parity registry must describe the live Daedric boon producer.", registryPath);
  } else if (
    !registry.includes('"rite.argonian.hist-adaptation","rite","Argonian","n/a","Y","Y","N"') ||
    !registry.includes('ApplyArgonianAdaptation - playerRef.AddSpell + SendPrismaShiftToast + AppendBookOfDaysEntry')
  ) {
    fail("Prisma parity registry must describe the live Argonian adaptation toast/chronicle producer.", registryPath);
  } else {
    pass("Prisma parity registry matches the resolved Daedric boon/residue/Hircine/adaptation surfaces.", registryPath);
  }
}

const failures = [];
const passes = [];

if (!fs.existsSync(DEVOTION_SOURCE)) {
  fail("Devotion source folder is missing.", DEVOTION_SOURCE);
} else {
  const pscFiles = fs
    .readdirSync(DEVOTION_SOURCE)
    .filter((name) => name.endsWith(".psc") && !name.startsWith("codex-"));

  for (const name of pscFiles) {
    const filePath = path.join(DEVOTION_SOURCE, name);
    const source = read(filePath);

    // PDV_PrismaBridge.psc declares the natives; PDV_MCM.psc is the sanctioned player-owned
    // UI entry point (the rebindable "Open Devotion panel" hotkey) that focuses the full
    // panel. Every other source is gameplay and must not open the focused panel.
    if (name !== "PDV_PrismaBridge.psc" && name !== "PDV_MCM.psc") {
      for (const forbidden of ["OpenDevotionPanel", "ToggleDevotionPanel"]) {
        if (source.includes(`PDV_PrismaBridge.${forbidden}(`)) {
          fail(`Gameplay source calls ${forbidden}; only player-owned UI entry points may open the full panel.`, filePath);
        }
      }
    }

    if (name !== "PDV__ManagerQuest.psc" && source.includes("PDV_PrismaBridge.SendJson(")) {
      fail("Non-manager source sends focused panel JSON.", filePath);
    }

    if (
      name !== "PDV__ManagerQuest.psc" &&
      name !== "PDV_PrismaBridge.psc" &&
      source.includes("PDV_PrismaBridge.SendOverlayJson(")
    ) {
      if (name !== "PDV_T3DailyLowHealthSaveEffect.psc") {
        fail("Only approved helper/capstone sources may send raw overlay JSON outside the manager.", filePath);
      } else if (!source.includes('{\\"mode\\":\\"toast\\"')) {
        fail("The capstone overlay sender must remain a toast payload, never a modal/panel payload.", filePath);
      } else {
        pass("Approved capstone overlay sender is toast-only.", filePath);
      }
    }

    if (
      name !== "PDV_MCM.psc" &&
      source.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 1)')
    ) {
      fail("Only the player-owned MCM/hotkey surface may mark Book of Days open.", filePath);
    }

    if (name !== "PDV_MCM.psc" && source.includes("SendPrismaJournalPayload(True")) {
      fail("Only the player-owned MCM/hotkey surface may request the Book of Days modal.", filePath);
    }
  }

  const managerPath = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
  if (!fs.existsSync(managerPath)) {
    fail("Manager source is missing.", managerPath);
  } else {
    const manager = read(managerPath);
    const pushBlock = functionBlock(manager, "PushDevotionPanel");
    const onUpdateBlock = eventBlock(manager, "OnUpdate");
    const startupBlock = functionBlock(manager, "SendPrismaStartupPayload");
    const medallionBlock = functionBlock(manager, "SendPrismaMedallionPayload");
    const p2BookNoticeBlock = functionBlock(manager, "SurfaceP2BookReadNotice");
    const p2AmbientNoticeBlock = functionBlock(manager, "SurfaceP2AmbientProgressNotice");
    const p2DeliveryBlock = functionBlock(manager, "SurfaceP2Acknowledgement");
    const altmerSleepBlock = functionBlock(manager, "HandleAltmerSleepEvents");
    const altmerHeritageVoiceBlock = functionBlock(manager, "AppendAltmerHeritageVoice");
    const altmerHeritageSourceLineBlock = functionBlock(manager, "GetAltmerHeritageSourceLine");
    const bretonSleepBlock = functionBlock(manager, "HandleBretonSleepEvents");
    const bretonHiddenArtBlock = functionBlock(manager, "HandleBretonHiddenArtExposure");
    const overlaySenderFunctions = functionNamesContaining(manager, "PDV_PrismaBridge.SendOverlayJson(");
    const focusedSenderFunctions = functionNamesContaining(manager, "PDV_PrismaBridge.SendJson(");

    if (!manager.includes("Bool Property AutoPushPrismaPanel = False Auto")) {
      fail("Manager is missing the default-off full-panel push property.", managerPath);
    } else {
      pass("AutoPushPrismaPanel defaults false.", managerPath);
    }

    if (!manager.includes("Bool Property AllowPrismaBlockingSurfaces = False Auto")) {
      fail("Manager is missing the default-off blocking-surface property.", managerPath);
    } else {
      pass("AllowPrismaBlockingSurfaces defaults false.", managerPath);
    }

    if (!pushBlock.includes("if !playerRequested") || !pushBlock.includes("PDV_PrismaBridge.SendJson(")) {
      fail("PushDevotionPanel must reject non-player requests before focused SendJson.", managerPath);
    } else {
      pass("PushDevotionPanel is player-request gated.", managerPath);
    }

    if (!sameStringSet(focusedSenderFunctions, ["PushDevotionPanel"])) {
      fail(`Focused SendJson may only live in PushDevotionPanel; found ${focusedSenderFunctions.join(", ") || "none"}.`, managerPath);
    } else {
      pass("Focused SendJson is confined to PushDevotionPanel.", managerPath);
    }

    const expectedOverlaySenderFunctions = [
      "ClosePrismaJournal",
      "DebugClosePrismaSurfaces",
      "SendPrismaCurseToast",
      "SendPrismaJournalPayload",
      "SendPrismaMedallionPayload",
      "SendPrismaStartupPayload",
      "SendPrismaToastPayloadOrFallback",
    ].sort();
    if (!sameStringSet(overlaySenderFunctions, expectedOverlaySenderFunctions)) {
      fail(`Manager overlay senders drifted; found ${overlaySenderFunctions.join(", ") || "none"}.`, managerPath);
    } else {
      pass("Manager overlay senders are confined to approved toast/modal close/open helpers.", managerPath);
    }

    if (onUpdateBlock.includes("PushDevotionPanel(")) {
      fail("OnUpdate must not auto-open the focused Devotion panel.", managerPath);
    } else {
      pass("OnUpdate does not auto-open the focused Devotion panel.", managerPath);
    }

    const awardPietyBlock = functionBlock(manager, "AwardPietyInternal");
    if (!awardPietyBlock.includes("RecordDeityDriver(deity, reason, appliedAmount)")) {
      fail("Every nonzero AwardPiety movement must record a dashboard driver for the moved deity.", managerPath);
    } else {
      pass("Every nonzero AwardPiety movement records a dashboard driver.", managerPath);
    }

    if (awardPietyBlock.includes("IsDashboardTrackedDeity(")) {
      fail("Dashboard driver capture must not be gated to active patron / emphasis only.", managerPath);
    } else {
      pass("Dashboard driver capture is not active-patron gated.", managerPath);
    }

    if (!startupBlock.includes("if !AllowPrismaBlockingSurfaces") || !startupBlock.includes("\\\"mode\\\":\\\"startup\\\"")) {
      fail("SendPrismaStartupPayload must be guarded as a blocking UI surface.", managerPath);
    } else {
      pass("Startup modal payload is default-off guarded.", managerPath);
    }

    if (!medallionBlock.includes("if !AllowPrismaBlockingSurfaces") || !medallionBlock.includes("\\\"mode\\\":\\\"medallion\\\"")) {
      fail("SendPrismaMedallionPayload must be guarded as a blocking UI surface.", managerPath);
    } else {
      pass("Medallion modal payload is default-off guarded.", managerPath);
    }

    const journalBlock = functionBlock(manager, "SendPrismaJournalPayload");
    const appendJournalBlock = functionBlock(manager, "AppendBookOfDaysEntry");
    if (!journalBlock) {
      fail("SendPrismaJournalPayload function is missing.", managerPath);
    } else {
      if (!journalBlock.includes("if !AllowPrismaBlockingSurfaces") || !manager.includes("\\\"mode\\\":\\\"journal\\\"")) {
        fail("SendPrismaJournalPayload must be guarded as a blocking UI surface.", managerPath);
      } else {
        pass("Journal modal payload is default-off guarded.", managerPath);
      }

      const journalCalls = countMatches(manager, /SendPrismaJournalPayload\(/g);
      if (journalCalls !== 1) {
        fail(`SendPrismaJournalPayload should have exactly one definition (no additional callers within manager); found ${journalCalls} occurrences.`, managerPath);
      } else {
        pass("Journal modal payload has one definition.", managerPath);
      }

      const journalPayloadBuilderCalls = countMatches(manager, /BuildJournalPayloadJson\(/g);
      if (journalPayloadBuilderCalls !== 2) {
        fail(`BuildJournalPayloadJson must only be defined and called by the player-owned journal open payload; found ${journalPayloadBuilderCalls} occurrences.`, managerPath);
      } else {
        pass("Book of Days payload build is limited to the player-owned journal open path.", managerPath);
      }
    }

    const sendJsonCount = countMatches(manager, /PDV_PrismaBridge\.SendJson\(/g);
    if (sendJsonCount !== 1) {
      fail(`Expected exactly one focused SendJson call in the manager; found ${sendJsonCount}.`, managerPath);
    } else {
      pass("Manager has one focused SendJson call.", managerPath);
    }

    const startupCalls = countMatches(manager, /SendPrismaStartupPayload\(/g);
    const medallionCalls = countMatches(manager, /SendPrismaMedallionPayload\(/g);
    if (startupCalls !== 1) {
      fail(`SendPrismaStartupPayload should have no callers; found ${startupCalls - 1}.`, managerPath);
    } else {
      pass("Startup modal payload has no live callers.", managerPath);
    }
    if (medallionCalls !== 1) {
      fail(`SendPrismaMedallionPayload should have no callers; found ${medallionCalls - 1}.`, managerPath);
    } else {
      pass("Medallion modal payload has no live callers.", managerPath);
    }

    // The invariant is "stale Papyrus journal-open state gets reconciled against native
    // visibility", not "a function named RefreshOpenBookOfDays exists". That standalone function
    // was retired 2026-08-07: PDV_MCM's journal hotkey already did the identical reconciliation
    // inline, at the only moment it matters, so the function was a superseded duplicate that
    // nothing called. Assert the behaviour where it actually lives.
    const mcmJournalSource = read(MCM_SOURCE);
    if (
      !mcmJournalSource.includes("PDV_PrismaBridge.IsJournalVisible()") ||
      !mcmJournalSource.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)')
    ) {
      fail("Journal hotkey must reconcile stale Papyrus open state against native journal visibility.", MCM_SOURCE);
    } else {
      pass("Journal hotkey reconciles stale Papyrus open state against native visibility.", MCM_SOURCE);
    }

    if (appendJournalBlock.includes("SendPrismaJournalPayload(")) {
      fail("Book of Days writes must not open or refresh the journal modal during gameplay.", managerPath);
    } else {
      pass("Book of Days writes only store chronicle data and do not open/refresh the modal.", managerPath);
    }

    if (
      !p2BookNoticeBlock.includes("IsP2BookNoticeReason(reason)") ||
      !p2BookNoticeBlock.includes("SurfaceP2Acknowledgement(") ||
      !p2DeliveryBlock.includes("SendPrismaToast(\"journal\", \"good\", titleText, messageText, True, allowDuringRaceSetup)") ||
      !p2DeliveryBlock.includes("AppendBookOfDaysEntry(messageText")
    ) {
      fail("Accepted P2 book notices must validate book provenance and feed both Prisma toast and Book of Days through the shared delivery module.", managerPath);
    } else {
      pass("Accepted P2 book notices validate provenance and feed both Prisma toast and Book of Days chronicle.", managerPath);
    }

    // P2 (2026-08-04) moved the Altmer dream line out of HandleAltmerSleepEvents: every ancestral
    // spine feed now voices through AppendAltmerHeritageVoice, gated on the day credit actually
    // landing. The invariant is unchanged and still asserted here -- Altmer sleep produces exactly
    // ONE quiet (unpinned, setup-quiet-respecting) Book of Days dream and never borrows the P2
    // book/ambient notice paths -- but it is now proven across the sleep block, the shared voice
    // helper, and the per-source line map rather than against one inline literal.
    const altmerDreamVoiced =
      /AwardAltmerAncestorSpinePulse\(\s*multiplier\s*,\s*"sleep_dream_/.test(altmerSleepBlock) &&
      !altmerSleepBlock.includes("AppendBookOfDaysEntry(") &&
      /if\s+grantedMetric\s*<=\s*0\.0[\s\S]*?return/.test(altmerHeritageVoiceBlock) &&
      // Accepts the source line inline OR via a local, because the helper now RETURNS the line it
      // wrote so the caller can reuse it as the Prisma toast context (toast parity, 2026-08-06).
      // The invariant asserted is unchanged: the entry is built from GetAltmerHeritageSourceLine,
      // carries the auri-el symbol, and is unpinned.
      /String\s+\w+\s*=\s*GetAltmerHeritageSourceLine\(reason\)[\s\S]*?AppendBookOfDaysEntry\(\w+,[^\r\n]*"auri-el",\s*False\s*,/.test(altmerHeritageVoiceBlock) &&
      countMatches(altmerHeritageVoiceBlock, /AppendBookOfDaysEntry\(/g) === 1 &&
      // Assert that the sleep feed HAS its own voiced arm, never what that arm SAYS. The wording
      // here is owner-editable player copy: an earlier revision of this check pinned the exact
      // sentence, and a legitimate voice pass on the line turned the gate red while the behaviour
      // was untouched. A gate that goes red on a copy edit teaches people to ignore it.
      /StringContainsToken\(reason,\s*"sleep_dream"\)\s*\r?\n\s*return\s+"[^"]+"/.test(altmerHeritageSourceLineBlock);

    if (
      !p2BookNoticeBlock.includes('True, "P2 book notice surfaced: "') ||
      !p2AmbientNoticeBlock.includes('False, "P2 ambient notice surfaced: "') ||
      !altmerDreamVoiced ||
      !bretonSleepBlock.includes("SurfaceP2AmbientProgressNotice(") ||
      altmerSleepBlock.includes("SurfaceP2AmbientProgressNotice(") ||
      altmerSleepBlock.includes("SurfaceP2BookReadNotice(") ||
      altmerHeritageVoiceBlock.includes("SurfaceP2AmbientProgressNotice(") ||
      altmerHeritageVoiceBlock.includes("SurfaceP2BookReadNotice(") ||
      bretonSleepBlock.includes("SurfaceP2BookReadNotice(")
    ) {
      fail("P2 book reads must bypass setup quiet presentation; Altmer sleep logs one quiet Book of Days dream through the shared heritage voice while Breton sleep keeps the quiet-respecting ambient notice.", managerPath);
    } else {
      pass("P2 book reads, quiet Altmer dreams, and Breton ambient sleep progress use their intended distinct presentation paths.", managerPath);
    }

    if (
      !bretonHiddenArtBlock.includes("Bool practiceAwarded = AwardBretonPracticePulse(") ||
      !bretonHiddenArtBlock.includes("SurfaceP2BookReadNotice(reason, GetBretonHiddenArtNoticeTitle(reason), GetBretonHiddenArtNoticeText(reason))") ||
      /if\s+practiceAwarded\s*\r?\n\s*SurfaceP2BookReadNotice\(/.test(bretonHiddenArtBlock)
    ) {
      fail("Approved Breton Hidden Art P2 books must acknowledge every unique read; the daily practice cap may reduce mechanics but must not suppress toast or Book of Days delivery.", managerPath);
    } else {
      pass("Breton Hidden Art P2 book acknowledgements are independent of daily practice credit.", managerPath);
    }

    verifyJournalToneContract(manager, managerPath);
    verifySubstrateChronicleContract(manager, managerPath);
    verifySessionCopyContracts(manager, managerPath);
    verifyDaedricToastContracts(manager, managerPath);
    const appPath = DEVOTION_PRISMA_VIEW;
    const indexPath = DEVOTION_PRISMA_INDEX;
    const eventBusPath = path.join(DEVOTION_SOURCE, "PDV_EventBus.psc");
    const actionRouterPath = path.join(DEVOTION_SOURCE, "PDV_ActionRouter.psc");
    const eventTypesPath = path.join(DEVOTION_SOURCE, "PDV_EventTypes.psc");
    if (fs.existsSync(appPath)) {
      const liveApp = read(appPath);
      verifyKynarethMedallionContract(manager, liveApp, managerPath, appPath);
      verifySyrabaneDisplayContract(manager, liveApp, managerPath, appPath);
      verifyAltmerCurrentRosterContract(manager, managerPath);
    } else {
      fail("Live Prisma app.js is missing for medallion symbol contract audit.", appPath);
    }
    if (
      fs.existsSync(appPath) &&
      fs.existsSync(indexPath) &&
      fs.existsSync(eventBusPath) &&
      fs.existsSync(actionRouterPath) &&
      fs.existsSync(eventTypesPath)
    ) {
      verifyBookOfDaysChronicleActionContract({
        manager,
        eventBus: read(eventBusPath),
        actionRouter: read(actionRouterPath),
        eventTypes: read(eventTypesPath),
        app: read(appPath),
        index: read(indexPath),
        managerPath,
        eventBusPath,
        actionRouterPath,
        eventTypesPath,
        appPath,
        indexPath,
      });
    } else {
      if (!fs.existsSync(indexPath)) fail("Live Prisma index.html is missing for Book of Days Chronicle audit.", indexPath);
      if (!fs.existsSync(eventBusPath)) fail("Live EventBus source is missing for Book of Days Chronicle audit.", eventBusPath);
      if (!fs.existsSync(actionRouterPath)) fail("Live ActionRouter source is missing for Book of Days Chronicle audit.", actionRouterPath);
      if (!fs.existsSync(eventTypesPath)) fail("Live EventTypes source is missing for Book of Days Chronicle audit.", eventTypesPath);
    }
  }

  const bridgePath = path.join(DEVOTION_SOURCE, "PDV_PrismaBridge.psc");
  if (!fs.existsSync(bridgePath)) {
    fail("Prisma bridge Papyrus source is missing.", bridgePath);
  } else {
    const bridge = read(bridgePath);
    if (!bridge.includes("Bool Function IsJournalVisible() Global Native")) {
      fail("Prisma bridge Papyrus source must expose IsJournalVisible for Book of Days key-close state.", bridgePath);
    } else {
      pass("Prisma bridge Papyrus source exposes IsJournalVisible.", bridgePath);
    }

    if (!bridge.includes("Bool Function IsPanelVisible() Global Native")) {
      fail("Prisma bridge Papyrus source must expose IsPanelVisible for focused-panel key-close state.", bridgePath);
    } else {
      pass("Prisma bridge Papyrus source exposes IsPanelVisible.", bridgePath);
    }
  }

  const mcmPath = path.join(DEVOTION_SOURCE, "PDV_MCM.psc");
  if (!fs.existsSync(mcmPath)) {
    fail("MCM source is missing.", mcmPath);
  } else {
    const mcm = read(mcmPath);
    const onKeyDown = eventBlock(mcm, "OnKeyDown");
    const registerJournalHotkeyBlock = functionBlock(mcm, "RegisterJournalHotkey");
    const keyMapChangeBlock = functionBlock(mcm, "OnOptionKeyMapChange");
    const journalKeyIndex = onKeyDown.indexOf('StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey"');
    const panelKeyIndex = onKeyDown.indexOf('StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey"');
    const journalStart = onKeyDown.indexOf("Int journalState = StorageUtil.GetIntValue(None, \"PDV.Diegetic.Journal.Open\")");
    const journalEnd = panelKeyIndex > journalStart ? panelKeyIndex : onKeyDown.length;
    const journalSlice = journalStart >= 0 ? onKeyDown.slice(journalStart, journalEnd) : "";
    const visibleIndex = journalSlice.indexOf("PDV_PrismaBridge.IsJournalVisible()");
    const menuIndex = journalSlice.indexOf("Utility.IsInMenuMode()");
    const closeIndex = journalSlice.indexOf("PDV_Manager.ClosePrismaJournal()");

    if (!onKeyDown) {
      fail("MCM OnKeyDown event is missing.", mcmPath);
    } else if (visibleIndex < 0) {
      fail("Book of Days hotkey must query native bridge journal visibility before deciding close/open state.", mcmPath);
    } else {
      pass("Book of Days hotkey queries bridge journal visibility.", mcmPath);
    }

    if (journalKeyIndex < 0 || panelKeyIndex < 0 || journalKeyIndex > panelKeyIndex) {
      fail("Book of Days hotkey must be handled before the Devotion panel hotkey so shared bindings cannot open both surfaces.", mcmPath);
    } else {
      pass("Book of Days hotkey is handled before the Devotion panel hotkey.", mcmPath);
    }

    if (journalSlice.includes("OpenDevotionPanel(") || journalSlice.includes("PushDevotionPanel(")) {
      fail("Book of Days hotkey path must not open or push the focused Devotion panel.", mcmPath);
    } else {
      pass("Book of Days hotkey path does not open the focused Devotion panel.", mcmPath);
    }

    if (!journalSlice || visibleIndex < 0 || menuIndex < 0 || visibleIndex > menuIndex || closeIndex < 0 || closeIndex > menuIndex) {
      fail("Book of Days close path must run before the menu-mode open guard.", mcmPath);
    } else {
      pass("Book of Days close path is not blocked by the menu-mode open guard.", mcmPath);
    }

    if (!journalSlice.includes("StorageUtil.SetIntValue(None, \"PDV.Diegetic.Journal.Open\", 0)")) {
      fail("Book of Days hotkey must clear stale Papyrus open state when native UI is not visible.", mcmPath);
    } else {
      pass("Book of Days hotkey reconciles stale Papyrus open state.", mcmPath);
    }

    const panelSlice = panelKeyIndex >= 0 ? onKeyDown.slice(panelKeyIndex) : "";
    const panelVisibleIndex = panelSlice.indexOf("PDV_PrismaBridge.IsPanelVisible()");
    const panelCloseIndex = panelSlice.indexOf("PDV_PrismaBridge.CloseDevotionPanel()");
    const panelMenuIndex = panelSlice.indexOf("Utility.IsInMenuMode()");
    if (
      !panelSlice ||
      panelVisibleIndex < 0 ||
      panelCloseIndex < 0 ||
      panelMenuIndex < 0 ||
      panelVisibleIndex > panelMenuIndex ||
      panelCloseIndex > panelMenuIndex
    ) {
      fail("Devotion panel hotkey must close a visible focused panel before the menu-mode open guard.", mcmPath);
    } else {
      pass("Devotion panel hotkey closes a visible focused panel before the menu-mode open guard.", mcmPath);
    }

    if (
      !registerJournalHotkeyBlock.includes('StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)') ||
      !registerJournalHotkeyBlock.includes("savedPanelKey == savedKey")
    ) {
      fail("Saved Book of Days/panel hotkey conflicts must self-repair on MCM reload/config init.", mcmPath);
    } else {
      pass("Saved Book of Days/panel hotkey conflicts self-repair on reload/config init.", mcmPath);
    }

    if (
      !keyMapChangeBlock.includes('StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)') ||
      !keyMapChangeBlock.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)')
    ) {
      fail("MCM keymap changes must keep Book of Days and Devotion panel hotkeys mutually exclusive.", mcmPath);
    } else {
      pass("MCM keymap changes keep Book of Days and Devotion panel hotkeys mutually exclusive.", mcmPath);
    }
  }
}

if (!fs.existsSync(NATIVE_BRIDGE_SOURCE)) {
  fail("Native Prisma bridge source is missing.", NATIVE_BRIDGE_SOURCE);
} else {
  const nativeBridge = read(NATIVE_BRIDGE_SOURCE);
  const journalPayloadDetection = nativeBridge.match(/const bool isJournalPayload[\s\S]*?;/)?.[0] ?? "";
  const domReadyBlock = nativeBridge.match(/void OnDomReady[\s\S]*?\n    \}/)?.[0] ?? "";
  const overlayPayloadBlock = nativeBridge.match(/bool SendOverlayPayload[\s\S]*?\n    \}/)?.[0] ?? "";
  if (
    !nativeBridge.includes("g_journalVisible") ||
    !nativeBridge.includes("PapyrusIsJournalVisible") ||
    !nativeBridge.includes('RegisterFunction("IsJournalVisible"')
  ) {
    fail("Native Prisma bridge must track and expose Book of Days visible state.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge tracks and exposes Book of Days visible state.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("g_journalVisible = false") || !nativeBridge.includes("g_journalVisible = true")) {
    fail("Native Prisma bridge must update Book of Days visible state on open and close.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge updates Book of Days visible state on open and close.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("class PrismaInputSink") || !nativeBridge.includes("RegisterInputSink()")) {
    fail("Native Prisma bridge must register a Prisma ESC input sink.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma bridge registers a Prisma ESC input sink.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("button->GetIDCode() == 1") || !nativeBridge.includes("RE::BSEventNotifyControl::kStop")) {
    fail("Native Prisma ESC input sink must consume keyboard ESC before Skyrim opens the pause menu.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native Prisma ESC input sink consumes keyboard ESC.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !nativeBridge.includes("bool g_panelVisible = false;") ||
    !nativeBridge.includes('ClosePanelSurface("keyboard_escape")') ||
    !nativeBridge.includes("PapyrusIsPanelVisible") ||
    !nativeBridge.includes('RegisterFunction("IsPanelVisible"')
  ) {
    fail("Focused Devotion panel must have native ESC close and a Papyrus-visible panel state.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Focused Devotion panel has native ESC close and Papyrus-visible panel state.", NATIVE_BRIDGE_SOURCE);
  }

  if (!nativeBridge.includes("g_prisma->Focus(g_view, true, false);")) {
    fail("Book of Days must keep Prisma's cursor-friendly focus mode for the in-view X button.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days keeps Prisma's cursor-friendly focus mode.", NATIVE_BRIDGE_SOURCE);
  }

  if (nativeBridge.includes("g_prisma->Focus(g_view, true, true);")) {
    fail("Book of Days must not disable Prisma's focus menu; that breaks cursor/X close behavior.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days does not use the cursor-breaking focus mode.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !nativeBridge.includes("void CloseJournalSurface(") ||
    !nativeBridge.includes('CloseJournalSurface("js_panel_close")') ||
    !nativeBridge.includes('CloseJournalSurface("keyboard_escape", true)') ||
    !nativeBridge.includes('CloseJournalSurface("papyrus_journal_close")')
  ) {
    fail("Book of Days close routes must converge on CloseJournalSurface.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Book of Days close routes converge on CloseJournalSurface.", NATIVE_BRIDGE_SOURCE);
  }

  const structuredJournalPayloadDetection =
    journalPayloadDetection.includes('FindTopLevelKey(a_payload, "mode", &mode)') &&
    journalPayloadDetection.includes('mode == "journal"') &&
    journalPayloadDetection.includes('FindTopLevelKey(a_payload, "journal")') &&
    journalPayloadDetection.includes("&&");
  if (
    !journalPayloadDetection ||
    !structuredJournalPayloadDetection ||
    journalPayloadDetection.includes("||") ||
    nativeBridge.includes('a_payload.find("\\"journal\\"")')
  ) {
    fail("Native bridge must require explicit top-level journal mode plus a top-level journal object, not any payload containing a journal key or symbol value.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native bridge only marks explicit top-level journal-mode payloads with top-level journal objects as Book of Days visible.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !domReadyBlock ||
    !domReadyBlock.includes("if (g_panelFocusPending && !g_lastPayload.empty())") ||
    domReadyBlock.includes("if (!g_lastPayload.empty())")
  ) {
    fail("Native DOM-ready replay of focused panel payloads must only run for an actual pending panel open.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native DOM-ready replay of focused panel payloads is gated to pending panel opens.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !overlayPayloadBlock ||
    !overlayPayloadBlock.includes("if (!g_domReady)") ||
    !overlayPayloadBlock.includes("QueueOverlayPayload(a_payload)") ||
    !overlayPayloadBlock.includes("return true") ||
    overlayPayloadBlock.indexOf("if (!g_domReady)") > overlayPayloadBlock.indexOf("g_prisma->Show(g_view)")
  ) {
    fail("Native overlay sends must defer until DOM ready before showing the shared Prisma view.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native overlay sends defer until DOM ready before showing the shared Prisma view.", NATIVE_BRIDGE_SOURCE);
  }

  if (
    !nativeBridge.includes("std::deque<std::string> g_pendingOverlayPayloads") ||
    !nativeBridge.includes("kMaxPendingOverlayPayloads") ||
    !nativeBridge.includes("QueueOverlayPayload") ||
    nativeBridge.includes("std::string g_pendingOverlayPayload;")
  ) {
    fail("Native cold-DOM overlay deferral must use a capped FIFO queue, not a single overwritten payload slot.", NATIVE_BRIDGE_SOURCE);
  } else {
    pass("Native cold-DOM overlay deferral uses a capped FIFO queue.", NATIVE_BRIDGE_SOURCE);
  }
}

if (!fs.existsSync(DEVOTION_PRISMA_VIEW)) {
  fail("Live Prisma UI app.js is missing.", DEVOTION_PRISMA_VIEW);
} else {
  const app = read(DEVOTION_PRISMA_VIEW);
  if (!app.includes("const symbolDisplayNames = Object.fromEntries(gallerySymbols);")) {
    fail("Prisma UI is missing the symbol display-name map.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI has a symbol display-name map.", DEVOTION_PRISMA_VIEW);
  }

  if (!app.includes('deityName = (payload = {}) => displayName(payload.deity, displayName(state.patron, "Devotion"))')) {
    fail("Prisma toast deity labels are not normalized through displayName.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma toast deity labels use display names.", DEVOTION_PRISMA_VIEW);
  }

  if (!app.includes('["azura", "Azurah"]')) {
    fail("Prisma UI is missing the Azurah display-name mapping for the normalized azura symbol key.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI maps normalized azura symbols to Azurah display text.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const overlayController = (() =>") ||
    !app.includes("const isEscapeKey = (event)") ||
    !app.includes("const onOverlayEsc = (event)") ||
    !app.includes("const closeStartupFromView = () =>") ||
    !app.includes("const closeJournalFromView = () =>")
  ) {
    fail("Prisma overlays must use the shared overlay controller and robust ESC close handler.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma overlays use the shared overlay controller and robust ESC close handler.", DEVOTION_PRISMA_VIEW);
  }

  if (
    // 1.0.3: toast lifetimes lengthened for 4K / sentence-length readability (was 1800 / 5600).
    !app.includes("const MIN_TOAST_DURATION_MS = 3600;") ||
    !app.includes("const DEFAULT_TOAST_DURATION_MS = 8000;") ||
    !app.includes("Math.max(MIN_TOAST_DURATION_MS, numberOrZero(copy.duration) || DEFAULT_TOAST_DURATION_MS)")
  ) {
    fail("Prisma toast default lifetime must be explicit and long enough for sentence-length gameplay toasts.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma toast default lifetime supports sentence-length gameplay toasts.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('window.addEventListener("keydown", onOverlayEsc, true)') ||
    !app.includes('document.addEventListener("keydown", onOverlayEsc, true)') ||
    !app.includes('window.addEventListener("keyup", onOverlayEsc, true)') ||
    !app.includes('document.addEventListener("keyup", onOverlayEsc, true)')
  ) {
    fail("Overlay ESC handler must bind at window/document capture on keydown and keyup.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Overlay ESC handler binds at window/document capture on keydown and keyup.", DEVOTION_PRISMA_VIEW);
  }

  if (!app.includes("const onPanelEsc = (event) => {\n    if (isEscapeKey(event))")) {
    fail("Focused panel ESC handler must use the robust shared Escape detector.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Focused panel ESC handler uses the robust shared Escape detector.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('overlayController.open("journal")') ||
    !app.includes('overlayController.open("startup")') ||
    !app.includes("overlayController.closeAll();\n        document.body.classList.add(\"panel-visible\")")
  ) {
    fail("Focused panel and modal opens must pass through the overlay controller.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Focused panel and modal opens pass through the overlay controller.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const isJournalPayload = (payload)") ||
    !app.includes('payload.mode === "journal"') ||
    !app.includes('typeof payload.journal === "object"') ||
    !app.includes("!Array.isArray(payload.journal)") ||
    countMatches(app, /if \(isJournalPayload\(payload\)\)/g) < 2
  ) {
    fail("Prisma UI must render Book of Days only for explicit journal-mode payloads with journal objects.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI renders Book of Days only for explicit journal-mode payloads with journal objects.", DEVOTION_PRISMA_VIEW);
  }

  const overlayHandlerStart = app.indexOf("const handleOverlayPayload = (payload) => {");
  const overlayHandlerEnd = overlayHandlerStart >= 0 ? app.indexOf("};", overlayHandlerStart) : -1;
  const overlayHandler = overlayHandlerStart >= 0 && overlayHandlerEnd > overlayHandlerStart
    ? app.slice(overlayHandlerStart, overlayHandlerEnd)
    : "";
  const clearPanelIndex = overlayHandler.indexOf('document.body.classList.remove("panel-visible")');
  const unbindPanelEscIndex = overlayHandler.indexOf('document.removeEventListener("keydown", onPanelEsc, true)');
  const journalCloseIndex = overlayHandler.indexOf("if (payload.journalClose)");
  if (
    !overlayHandler ||
    clearPanelIndex < 0 ||
    unbindPanelEscIndex < 0 ||
    journalCloseIndex < 0 ||
    clearPanelIndex > journalCloseIndex ||
    unbindPanelEscIndex > journalCloseIndex
  ) {
    fail("Overlay payloads must clear stale focused-panel DOM state before rendering toasts or journal surfaces.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Overlay payloads clear stale focused-panel DOM state before rendering.", DEVOTION_PRISMA_VIEW);
  }

  if (app.includes("if (!bridgeReceived) enableDemo()")) {
    fail("Prisma UI must not auto-render the dashboard demo when in-game overlay payloads race DOM readiness.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma UI demo dashboard is explicit-only and cannot auto-open in game.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("const normalizeJournalSurveyText = (value) =>") ||
    !app.includes("const titleCaseJournalSegment = (segment) =>") ||
    !app.includes("const journalPathText = (value) => normalizeJournalSurveyText(value)") ||
    !app.includes("replace(/\\s*\\|\\s*/g, \" - \")") ||
    !app.includes('["nord", "Nord"]') ||
    !app.includes("const survey = journalPathText(journal.survey);")
  ) {
    fail("Book of Days cover line must normalize public race labels and render the concise path status.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Book of Days cover line normalizes public race labels and renders the concise path status.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes("The Book of Days always uses its book-styled standing gauge") ||
    !app.includes("renderJournalPietyGauge(nodes.journalInstrument, inst);") ||
    app.includes("instrumentRenderers[kind](nodes.journalInstrument, inst);")
  ) {
    fail("Book of Days standing must always render the book-styled diamond gauge, not substrate/path instruments.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Book of Days standing always renders the book-styled diamond gauge.", DEVOTION_PRISMA_VIEW);
  }

  const managerPath = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
  const managerForBroadLane = fs.existsSync(managerPath) ? read(managerPath) : "";
  if (
    !managerForBroadLane.includes("Function EmitBookOfDaysBroadLaneTierChange(Int today)") ||
    !managerForBroadLane.includes("BuildBroadLaneTierReachJournalLine(originRace, tier)") ||
    !managerForBroadLane.includes("Function GetBroadLaneTierForOrigin(Int origin)") ||
    !managerForBroadLane.includes("return \"Broad lane cap reached\"") ||
    !app.includes("nodes.pietyText.textContent = text(state.pietyLabel, `${piety} piety`);")
  ) {
    fail("Broad-lane reward milestones must feed Book of Days and panel presentation without showing broad counters as deity piety.", managerPath);
  } else {
    pass("Broad-lane reward milestones feed Book of Days and panel presentation.", managerPath);
  }

  if (
    !managerForBroadLane.includes('return GetBroadLaneDisplayName(originRace) + " has reached " + GetBroadLaneStandingLabel(originRace, tier) + "."') ||
    managerForBroadLane.includes('return "Your " + GetBroadLaneDisplayName(originRace) + " has reached "') ||
    !managerForBroadLane.includes("Function MaybeSendBroadPantheonTierToast") ||
    !managerForBroadLane.includes("Bool Function SendPrismaBroadPantheonTierToast") ||
    !app.includes('pantheon_tier: "pantheon"') ||
    !app.includes("pantheon: {") ||
    !app.includes('text(payload.pantheon, "Shared worship")')
  ) {
    fail("Broad pantheon milestones must use the public family name in Book of Days and the named dawn-fold toast, never malformed 'Your <family>' copy.", managerPath);
  } else {
    pass("Broad pantheon milestone copy uses public family names in Book of Days and named dawn-fold toasts.", managerPath);
  }

  if (
    !managerForBroadLane.includes("Bool Function IsPantheonBroadPoolPresentationActive(Int origin)") ||
    !managerForBroadLane.includes("Float Function GetBroadLaneStandingValue(Int origin)") ||
    !managerForBroadLane.includes("Float Function GetBroadLaneScratchValue(Int origin)") ||
    !managerForBroadLane.includes("primary = ClampValue(piety / BROAD_PANTHEON_POOL_MAX, 0.0, 1.0)") ||
    !managerForBroadLane.includes('\\"scratch\\":') ||
    !app.includes("const renderBroadInstrument") ||
    !app.includes("broad: renderBroadInstrument")
  ) {
    fail("Imperial and Nord broad pools must render from 0-50 with float standing, live scratch, and a dedicated two-tier gauge.", managerPath);
  } else {
    pass("Imperial and Nord broad pools render from 0-50 with float standing, scratch, and a dedicated two-tier gauge.", managerPath);
  }

  if (
    !managerForBroadLane.includes("Bool Function IsFocusedPantheonBoonSuspended()") ||
    !managerForBroadLane.includes('tierLabelOverride = "Wavering"') ||
    !managerForBroadLane.includes('nextText = "Focused boon returns at 50 piety"') ||
    !managerForBroadLane.includes('return "Suspended"')
  ) {
    fail("Focused Imperial/Nord commitment below 50 must remain committed while the panel and Survey explicitly suspend the boon.", managerPath);
  } else {
    pass("Focused Imperial/Nord commitment below 50 is explicitly surfaced as Wavering while the boon is suspended.", managerPath);
  }

  if (
    !managerForBroadLane.includes('return "Saxhleel Practice"') ||
    !managerForBroadLane.includes("String Function GetArgonianCulturalPracticeLabel()") ||
    !managerForBroadLane.includes('\\"metric\\":') ||
    !managerForBroadLane.includes('PanelPlainObject("hist", "neutral", "Hist relation"') ||
    !managerForBroadLane.includes('PanelPlainObject("journal", "neutral", "People relation"') ||
    !managerForBroadLane.includes('PanelPlainObject("sithis", voidTone, "Void relation"')
  ) {
    fail("Argonian panel must headline the cultural metric/tier and expose Hist, People, and Void as independent relations.", managerPath);
  } else {
    pass("Argonian panel separates cultural practice from Hist, People, and Void relations.", managerPath);
  }

  const shrineSubstratePrayer = functionBlock(managerForBroadLane, "HandleSubstrateShrinePrayer");
  if (
    !shrineSubstratePrayer.includes('AwardImperialAncestorSpinePulse(1.0, "divine_prayer_" + sourceId)') ||
    !shrineSubstratePrayer.includes('AwardAltmerAncestorSpinePulse(1.0, "auriel_shrine_rite_" + sourceId)') ||
    shrineSubstratePrayer.includes('PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled') ||
    shrineSubstratePrayer.includes('PDV_AltmerAncestorSubstrate.RecordHeritageStandingScaled')
  ) {
    fail("Imperial Divine and Altmer Auri-El shrine-prayer routes must use their shared substrate-presentation helpers, so an accepted act updates the metric, Book of Days, and Prisma toast together.", managerPath);
  } else {
    pass("Imperial Divine and Altmer Auri-El shrine-prayer routes use shared substrate presentation helpers.", managerPath);
  }

  const argonianSurvey = functionBlock(managerForBroadLane, "GetArgonianSurveyText");
  if (
    !argonianSurvey.includes('String text = "Far from Black Marsh, Hist memory is "') ||
    !argonianSurvey.includes('text = text + " Cultural practice: " + GetArgonianCulturalPracticeLabel() + "."') ||
    argonianSurvey.includes('You carry the Saxhleel exile') ||
    argonianSurvey.includes('Standing: ') ||
    argonianSurvey.includes('Your chosen bed has begun to matter.') ||
    argonianSurvey.includes('A Reclamation text keeps the old roads')
  ) {
    fail("Argonian Survey must remain a compact Hist/People/conditional-Void/cultural-practice summary; detailed relation, bed, and lore copy belongs in the focused panel.", managerPath);
  } else {
    pass("Argonian Survey is compact while the focused panel retains detailed relation context.", managerPath);
  }

  if (
    !managerForBroadLane.includes('return "distant"') ||
    !managerForBroadLane.includes('return "dormant"') ||
    !app.includes("const relationDisplayText = (displayItem) =>") ||
    !app.includes("const relationName = text(displayItem.listTitle || displayItem.label, \"\").trim();") ||
    !app.includes("const displayState = rawState ? rawState.charAt(0).toUpperCase() + rawState.slice(1) : \"\";") ||
    !app.includes("if (relationName && displayState) return `${relationName}: ${displayState}`;") ||
    !app.includes(": relationDisplayText(displayItem);")
  ) {
    fail("Argonian relation states must keep Survey's grammatical lower case while the focused panel renders named, capitalized relation values.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Argonian focused-panel relations preserve their names and use capitalized display values without changing Survey prose.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('appendSvg(svg, "path", { d: "M39 100 V78", class: "instrument-outline" });') ||
    !app.includes('appendSvg(svg, "path", { d: "M29 78 A10 10 0 0 1 49 78", class: fill });') ||
    app.includes('M27 78 Q39 54 51 78 Q46 94 39 102 Q32 94 27 78 Z')
  ) {
    fail("Argonian cultural practice must use the Hist root-and-river mark, not the retired generic droplet, in the focused instrument.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Argonian cultural practice uses the Hist root-and-river mark in the focused instrument.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !app.includes('if (kind === "broad")') ||
    !app.includes('instData.standing !== undefined') ||
    !app.includes('{ label: "Observant", value: 25 }') ||
    !app.includes('{ label: "Faithful", value: 50 }') ||
    !app.includes('else if (kind === "cultural" || kind === "hist")') ||
    !app.includes('instData.metric !== undefined') ||
    !app.includes('{ label: "Root Memory", value: 1 }') ||
    !app.includes('if (kind === "cultural") return "kept among root and river";')
  ) {
    fail("Book of Days must normalize cold-open broad standing to 50 and Argonian cultural metric to 75 with kind-specific pips.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Book of Days cold-open gauge uses kind-specific broad and Argonian standing semantics.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !managerForBroadLane.includes('return "Practice quiet"') ||
    !managerForBroadLane.includes('elseIf tierValue >= TIER_SEEKER') ||
    !managerForBroadLane.includes('return "Root Memory"')
  ) {
    fail("Argonian cultural practice must show a quiet zero-state and reserve Root Memory for metric 1+.", managerPath);
  } else {
    pass("Argonian cultural practice distinguishes metric 0 from the Root Memory tier at 1+.", managerPath);
  }

  const broadSymbolBody = functionBlock(managerForBroadLane, "GetBroadLaneSymbol");
  if (
    !broadSymbolBody.includes("NORD_BASELINE_NINE_DIVINES") ||
    !broadSymbolBody.includes('return "akatosh"') ||
    !broadSymbolBody.includes('return "kyne"')
  ) {
    fail("Nord broad-pool symbol must distinguish Nine Divines from Old Ways.", managerPath);
  } else {
    pass("Nord broad-pool symbol distinguishes Nine Divines (Akatosh) from Old Ways (Kyne).", managerPath);
  }

  const substrateNameBody = app.match(/const substrateName\s*=\s*\(payload\s*=\s*\{\}\)\s*=>\s*\{[\s\S]*?\n\s*\};/)?.[0] || "";
  if (
    !substrateNameBody.includes('const exactState = text(payload.state, "");') ||
    !substrateNameBody.includes('s === "imperial-civic" || s === "altmer-heritage" || s === "argonian-practice"') ||
    !substrateNameBody.includes('return exactState;') ||
    !substrateNameBody.includes('if (s === "argonian-practice" || s === "argonianhist") return "Root Memory";') ||
    managerForBroadLane.includes('SendPrismaSubstrateProgress("hist"')
  ) {
    fail("Prisma substrate copy must prefer the manager's exact state for the three renamed families and use argonian-practice as the canonical Argonian token.", DEVOTION_PRISMA_VIEW);
  } else {
    pass("Prisma substrate copy prefers exact renamed-family state and Argonian producers use the canonical argonian-practice token.", DEVOTION_PRISMA_VIEW);
  }

  const substrateProgressBody = functionBlock(managerForBroadLane, "SendPrismaSubstrateProgress");
  const substrateProgressCalls = extractCalls(managerForBroadLane, "SendPrismaSubstrateProgress");
  const substrateFunctionBlocks = extractFunctionBlocks(managerForBroadLane);
  const staleMetricCalls = substrateProgressCalls.filter((call) => {
    const metricArgument = call.args[3]?.trim() ?? "";
    if (metricArgument.includes("GetMetric() - metricBefore") || metricArgument.includes("metricAfter - metricBefore")) {
      return false;
    }
    // A bare local is acceptable ONLY if the enclosing function actually assigns it the real
    // post-award delta. This must stay general rather than matching one blessed variable name:
    // producers legitimately use their own pair (studyGrantedMetric/studyMetricBefore), and
    // AwardAltmerAncestorSpinePulse pre-declares `Float grantedMetric = 0.0` then assigns it
    // inside the substrate guard, so the declaration and the assignment are separate lines.
    // Anything else -- notably a requested `multiplier` -- is still a stale-metric failure.
    if (/^[A-Za-z_]\w*$/.test(metricArgument)) {
      const functionName = enclosingFunctionName(substrateFunctionBlocks, call.index);
      const functionBody = substrateFunctionBlocks.find((item) => item.name === functionName)?.body ?? "";
      const realDelta = new RegExp(
        `(?:Float\\s+)?${metricArgument}\\s*=\\s*[A-Za-z0-9_]+\\.GetMetric\\(\\)\\s*-\\s*[A-Za-z0-9_]*metricBefore\\b`,
        "i",
      );
      return !realDelta.test(functionBody);
    }
    return true;
  });
  const creditGuard = substrateProgressBody.indexOf("if grantedMetric <= 0.0");
  const creditReturn = substrateProgressBody.indexOf("return", creditGuard);
  const firstPresentation = Math.min(
    ...[substrateProgressBody.indexOf("SendPrismaSubstrateToast("), substrateProgressBody.indexOf("AppendBookOfDaysEntry(")].filter((index) => index >= 0),
  );
  if (
    !substrateProgressBody.includes("Float grantedMetric") ||
    creditGuard < 0 || creditReturn < creditGuard || firstPresentation < creditReturn ||
    staleMetricCalls.length > 0 || substrateProgressCalls.length === 0 ||
    !substrateProgressBody.includes('AppendBookOfDaysEntry(entryText, Utility.GetCurrentGameTime() as Int, "substrate.act", symbolName, False)') ||
    !substrateProgressBody.includes('entryText = stateLabel + ": " + context')
  ) {
    fail(`Substrate presentation must be gated by actual grantedMetric with zero-credit suppression; ${staleMetricCalls.length} producer(s) do not pass a metric delta.`, managerPath);
  } else {
    pass(`All ${substrateProgressCalls.length} substrate progress producers pass actual metric deltas and the shared helper suppresses zero-credit presentation.`, managerPath);
  }

  // Altmer parity is an acknowledgement contract, not a copy rule. Every accepted heritage
  // producer funnels through AwardAltmerAncestorSpinePulse; that helper resolves one Book line,
  // reuses it as the toast context, and presents only after the real daily-credit delta is known.
  // Keep the producer registry explicit so a new Altmer act cannot silently bypass the surface.
  const expectedAltmerHeritageProducers = new Set([
    "HandleSubstrateShrinePrayer",
    "HandleAltmerSleepEvents",
    "HandleAltmerDawnSteadiness",
    "HandleAltmerOrthodoxCostlyEnforcement",
    "HandleAltmerPracticeFocus",
    "HandleAltmerMagicSkillIncrease",
    "RunDawnAwardAltmerAuriElDawn",
  ]);
  const altmerHeritageCalls = extractCalls(managerForBroadLane, "AwardAltmerAncestorSpinePulse")
    .filter((call) => enclosingFunctionName(substrateFunctionBlocks, call.index) !== "AwardAltmerAncestorSpinePulse");
  const actualAltmerHeritageProducers = new Set(
    altmerHeritageCalls.map((call) => enclosingFunctionName(substrateFunctionBlocks, call.index)),
  );
  const missingAltmerHeritageProducers = [...expectedAltmerHeritageProducers]
    .filter((name) => !actualAltmerHeritageProducers.has(name));
  const unexpectedAltmerHeritageProducers = [...actualAltmerHeritageProducers]
    .filter((name) => !expectedAltmerHeritageProducers.has(name));
  const altmerAwardBody = functionBlock(managerForBroadLane, "AwardAltmerAncestorSpinePulse");
  const altmerVoiceIndex = altmerAwardBody.indexOf("String voicedLine = AppendAltmerHeritageVoice(grantedMetric, reason)");
  const altmerSurfaceIndex = altmerAwardBody.indexOf('SendPrismaSubstrateProgress("altmer-heritage", tierBefore, tierAfter, grantedMetric, voicedLine');
  const altmerBranchIndex = substrateProgressBody.indexOf('if substrate == "altmer-heritage"');
  const altmerBranchReturn = substrateProgressBody.indexOf("return", altmerBranchIndex);
  const altmerBranchBody = altmerBranchIndex >= 0 && altmerBranchReturn > altmerBranchIndex
    ? substrateProgressBody.slice(altmerBranchIndex, altmerBranchReturn)
    : "";
  if (
    missingAltmerHeritageProducers.length > 0 || unexpectedAltmerHeritageProducers.length > 0 ||
    altmerVoiceIndex < 0 || altmerSurfaceIndex < altmerVoiceIndex ||
    !altmerBranchBody.includes('SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)') ||
    !altmerBranchBody.includes('SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)') ||
    !altmerBranchBody.includes("if surfacePresentation") ||
    !altmerBranchBody.includes("if tierAfter > tierBefore") ||
    altmerBranchBody.includes("AppendBookOfDaysEntry(entryText")
  ) {
    fail(`Altmer heritage notice parity requires one accepted-act funnel for every registered producer; missing=${missingAltmerHeritageProducers.join("|") || "none"}, unexpected=${unexpectedAltmerHeritageProducers.join("|") || "none"}.`, managerPath);
  } else {
    pass(`All ${actualAltmerHeritageProducers.size} registered Altmer heritage producers reuse one accepted Book line for one Prisma notice, with a distinct tier Chronicle only on crossing.`, managerPath);
  }

  const renamedFamilyLines = managerForBroadLane.split(/\r?\n/).filter((line) =>
    /SendPrismaSubstrateProgress\("(?:imperial-civic|altmer-heritage|argonian-practice)"/.test(line)
  );
  const neutralRenamedFamilyLines = renamedFamilyLines.filter((line) => !line.includes('"altmer-heritage"'));
  const nonNeutralRenamedFamilyLines = neutralRenamedFamilyLines.filter((line) => !line.includes(', "journal",'));
  const altmerHeritageLines = renamedFamilyLines.filter((line) => line.includes('"altmer-heritage"'));
  const misroutedAltmerHeritageLines = altmerHeritageLines.filter((line) => !line.includes(', "auri-el",'));
  if (renamedFamilyLines.length === 0 || altmerHeritageLines.length === 0 || nonNeutralRenamedFamilyLines.length > 0 || misroutedAltmerHeritageLines.length > 0) {
    fail(`Imperial civic and Argonian practice progress must use a neutral journal symbol, while quiet Altmer heritage must retain Auri-El's Book of Days symbol; found ${nonNeutralRenamedFamilyLines.length} neutral-family and ${misroutedAltmerHeritageLines.length} Altmer producer mismatch(es).`, managerPath);
  } else {
    pass(`Renamed substrate producers use neutral symbols where surfaced and Auri-El's symbol for quiet Altmer heritage milestones.`, managerPath);
  }

  const nordStateBody = functionBlock(managerForBroadLane, "HandleNordOldWaysState");
  if (
    !nordStateBody.includes("GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES") ||
    !nordStateBody.includes('SurfaceP2BookReadNotice(reason, "Faith of the Holds"') ||
    !nordStateBody.includes('SurfaceP2BookReadNotice(reason, "The Old Ways"')
  ) {
    fail("Nord broad-state notices must title Nine Divines as Faith of the Holds and Old Ways as The Old Ways.", managerPath);
  } else {
    pass("Nord broad-state notices use the active baseline's exact family title.", managerPath);
  }

  const nordSurveyContextBody = functionBlock(managerForBroadLane, "GetNordContextSurveyText");
  if (nordSurveyContextBody.includes('"PDV.Nord.OldWaysContextCount"')) {
    fail("Nord Survey context must not read the frozen OldWaysContextCount migration field; current presentation must follow the active baseline and broad-pool standing.", managerPath);
  } else {
    pass("Nord Survey context contains no stale Old Ways service-count presentation dependency.", managerPath);
  }

  const rosterBody = functionBlock(managerForBroadLane, "GetBroadPantheonRosterForDebug");
  if (
    !rosterBody.includes('StorageUtil.GetIntValue(None, "PDV.Imperial.TalosBroadUnlocked") == 1') ||
    !rosterBody.includes("/Talos (unlocked)") ||
    !rosterBody.includes("(Talos locked)")
  ) {
    fail("Imperial broad-pool status must conditionally distinguish Talos locked from explicitly unlocked.", managerPath);
  } else {
    pass("Imperial broad-pool status conditionally distinguishes Talos locked and unlocked states.", managerPath);
  }

  const mcmForVisibleCopy = exists(MCM_SOURCE) ? read(MCM_SOURCE) : "";
  if (/Spine/i.test(app) || /Spine/i.test(mcmForVisibleCopy)) {
    fail("Current Prisma or MCM player-facing source still contains Spine; legacy identifiers belong only in compatibility internals.", /Spine/i.test(app) ? DEVOTION_PRISMA_VIEW : MCM_SOURCE);
  } else {
    pass("Current Prisma and MCM player-facing sources contain zero Spine text.", DEVOTION_PRISMA_VIEW);
  }

  if (
    !managerForBroadLane.includes("String Function GetImperialCivicTierName()") ||
    !managerForBroadLane.includes("String Function GetAltmerHeritageTierName()") ||
    !managerForBroadLane.includes("String Function GetArgonianCulturalPracticeLabel()") ||
    !managerForBroadLane.includes('"journal", GetImperialCivicTierName())') ||
    !managerForBroadLane.includes('GetAltmerHeritageTierJournalLine(tierAfter)') ||
    !managerForBroadLane.includes('"journal", GetArgonianCulturalPracticeLabel())')
  ) {
    fail("Renamed substrate producers must pass exact current tier labels where surfaced, while quiet Altmer heritage must write its dedicated milestone journal copy.", managerPath);
  } else {
    pass("Renamed substrate producers keep exact tier labels where surfaced and dedicated Altmer milestone copy where intentionally quiet.", managerPath);
  }

  const orcMalacathConduct = functionBlock(managerForBroadLane, "HandleOrcMalacathConduct");
  const redguardAncestorSpine = functionBlock(managerForBroadLane, "HandleRedguardAncestorSpine");
  const p2Acknowledgement = functionBlock(managerForBroadLane, "SurfaceP2Acknowledgement");
  if (
    !orcMalacathConduct.includes('SurfaceP2BookReadNotice(reason, "The Code of Malacath", "Malacath weighs your conduct against it.")') ||
    !redguardAncestorSpine.includes('SurfaceP2BookReadNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")') ||
    !p2Acknowledgement.includes('AppendBookOfDaysEntry(messageText')
  ) {
    fail("Reason-bearing substrate acts must route their Prisma acknowledgement through the paired Book of Days chronicle interface.", managerPath);
  } else {
    pass("Reason-bearing substrate acts route their Prisma acknowledgement through the paired Book of Days chronicle interface.", managerPath);
  }

  const reservedSignalSurfaceCases = [
    ["HandleKhajiitKhenarthiCaravanAid", "PDV_Khenarthi", "Caravan defended", "marks the caravan road kept safe."],
    ["HandleKhajiitRajhinLegendMade", "PDV_Rajhin", "Legend made", "marks a theft worth remembering."],
    ["HandleMephalaWebWoven", "PDV_Mephala", "Web woven", "marks a web woven in shadow."],
    ["HandleBoethiahHonorableDuel", "PDV_Boethiah", "Duel honored", "marks a trial honorably won."],
  ];
  const reservedSignalSurfaceHelper = functionBlock(managerForBroadLane, "SurfaceReservedSignal");
  const reservedSignalNameHelper = functionBlock(managerForBroadLane, "GetReservedSignalSurfaceName");
  const missingReservedSignalSurface = [];
  if (
    !reservedSignalSurfaceHelper.includes("SendPrismaToast(symbolName, \"good\", titleText, bodyText)") ||
    !reservedSignalSurfaceHelper.includes('AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "favor.act", symbolName, False, 1, titleText)') ||
    !reservedSignalSurfaceHelper.includes("RecordRecentDevotionEvent(bodyText)") ||
    !reservedSignalSurfaceHelper.includes("RequestPanelRefresh()")
  ) {
    missingReservedSignalSurface.push("SurfaceReservedSignal helper");
  }
  if (
    !reservedSignalNameHelper.includes('return "Boethra"') ||
    !reservedSignalNameHelper.includes('return "Mafala"') ||
    !reservedSignalNameHelper.includes('return "Azurah"')
  ) {
    missingReservedSignalSurface.push("Khajiit shared-deity display aliases");
  }
  for (const [handler, deityExpr, titleText, actionText] of reservedSignalSurfaceCases) {
    const block = functionBlock(managerForBroadLane, handler);
    const expectedCall = `SurfaceReservedSignal(${deityExpr}, "${titleText}", "${actionText}")`;
    if (!block.includes(expectedCall)) {
      missingReservedSignalSurface.push(handler);
    }
  }
  if (missingReservedSignalSurface.length) {
    fail(`Reserved signal handlers must surface Prisma toast, Book of Days, and panel recent-event copy: ${missingReservedSignalSurface.join(", ")}.`, managerPath);
  } else {
    pass("Reserved signal handlers surface Prisma toast, Book of Days, and panel recent-event copy.", managerPath);
  }

  if (
    !managerForBroadLane.includes('return "An act of devotion"') ||
    managerForBroadLane.includes('return "an act of devotion"') ||
    app.includes('"an act of devotion"')
  ) {
    fail("Book of Days and Prisma devotional-act fallback copy must keep sentence-case title capitalization.", managerPath);
  } else {
    pass("Book of Days and Prisma devotional-act fallback copy keep sentence-case title capitalization.", managerPath);
  }

  if (
    !managerForBroadLane.includes("You worship the Nine Divines broadly, and your standing is ") ||
    !managerForBroadLane.includes("BuildImperialConcordatSurveySentence(concordat)") ||
    !managerForBroadLane.includes('return "Under the Concordat, you are " + concordatLabel + "."') ||
    managerForBroadLane.includes("You worship the Divines broadly through your civic service.") ||
    managerForBroadLane.includes("Your service to the public order has been felt as worship.") ||
    managerForBroadLane.includes("You worship the Nine Divines broadly, civic and public.") ||
    managerForBroadLane.includes("On the Talos question you stand ")
  ) {
    fail("Imperial broad Survey copy must use the compact broad-standing sentence and direct Concordat sentence.", managerPath);
  } else {
    pass("Imperial broad Survey copy uses the compact broad-standing and Concordat sentences.", managerPath);
  }

  if (
    !managerForBroadLane.includes("return FormatImperialConcordatLabel(PDV_ConcordatStandingTrack.GetStateLabel())") ||
    !managerForBroadLane.includes("String Function FormatImperialConcordatLabel(String label)") ||
    !managerForBroadLane.includes('return "Publicly Compliant"') ||
    !managerForBroadLane.includes('return "Privately Defiant"') ||
    !managerForBroadLane.includes('return "Openly Defiant"') ||
    !managerForBroadLane.includes('return "Concordat Enforcer"') ||
    !managerForBroadLane.includes('return "Under the White-Gold Concordat, you are " + modeLabel + "."')
  ) {
    fail("Imperial Concordat display labels must be spaced for player-facing Survey, panel, and Book of Days surfaces.", managerPath);
  } else {
    pass("Imperial Concordat display labels are spaced for player-facing surfaces.", managerPath);
  }
}

verifyJournalBytecodeFreshness();
verifyPrismaAssetCacheContract();
requireBridgeSourceParity();
requireBridgeNativesDeclared();
verifyParityRegistryContracts(path.join(REPO_ROOT, "references", "authoring", "PDV_PrismaParityRegistry.csv"));

if (JSON_OUTPUT) {
  console.log(JSON.stringify({
    status: failures.length ? "FAIL" : "PASS",
    counts: { pass: passes.length, fail: failures.length },
    passes,
    failures,
  }, null, 2));
} else {
  for (const item of passes) {
    console.log(`[PASS] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
  }
  for (const item of failures) {
    console.error(`[FAIL] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
  }
  if (failures.length === 0) console.log(`Prisma UI audit passed: ${passes.length} checks.`);
}

if (failures.length > 0) process.exitCode = 1;
