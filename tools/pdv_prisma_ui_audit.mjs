#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

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
    !bretonPatronSurvey.includes('Hidden Art - Champion stands beside the pact.') ||
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
    fail("Breton Champion Survey must name the actual boon, while toast/Book copy stays to one patron-recognition sentence.", managerPath);
  } else {
    pass("Breton Champion Survey names the actual boon and toast/Book copy stays to one patron-recognition sentence.", managerPath);
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
  const residueBlock = functionBlock(manager, "DrainHircineResiduePrismaToasts");
  const nordCurseBlock = functionBlock(manager, "ApplyCurseRaceHandlers");
  if (!milestoneBlock.includes('SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)')) {
    fail("Daedric milestone presentation must emit the paired boon toast after the milestone toast.", managerPath);
  } else {
    pass("Daedric milestone presentation emits the paired boon toast.", managerPath);
  }

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
    const p2BookNoticeBlock = functionBlock(manager, "ShowP2BookNotice");
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
      "ProcessQueuedPrismaToastRetry",
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
    const refreshJournalBlock = functionBlock(manager, "RefreshOpenBookOfDays");
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

    if (
      !refreshJournalBlock.includes("PDV_PrismaBridge.IsJournalVisible()") ||
      !refreshJournalBlock.includes('StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)')
    ) {
      fail("Book of Days refresh must reconcile stale Papyrus open state against native journal visibility.", managerPath);
    } else {
      pass("Book of Days refresh reconciles stale Papyrus open state against native visibility.", managerPath);
    }

    if (appendJournalBlock.includes("RefreshOpenBookOfDays(") || appendJournalBlock.includes("SendPrismaJournalPayload(")) {
      fail("Book of Days writes must not open or refresh the journal modal during gameplay.", managerPath);
    } else {
      pass("Book of Days writes only store chronicle data and do not open/refresh the modal.", managerPath);
    }

    if (
      !p2BookNoticeBlock.includes("SendPrismaToast(") ||
      !p2BookNoticeBlock.includes("AppendBookOfDaysEntry(")
    ) {
      fail("Accepted P2 book notices must feed both Prisma toast and Book of Days chronicle.", managerPath);
    } else {
      pass("Accepted P2 book notices feed both Prisma toast and Book of Days chronicle.", managerPath);
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
    !app.includes("const MIN_TOAST_DURATION_MS = 1800;") ||
    !app.includes("const DEFAULT_TOAST_DURATION_MS = 5600;") ||
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
    !managerForBroadLane.includes("Function SendPrismaSubstrateProgress(String substrate, Int tierBefore, Int tierAfter, Float multiplier, String context, String symbolName, String stateLabel)") ||
    !managerForBroadLane.includes('if multiplier > 0.0 && context != "" && tierAfter >= tierBefore') ||
    !managerForBroadLane.includes('AppendBookOfDaysEntry(context, Utility.GetCurrentGameTime() as Int, "substrate.act", symbolName, False)') ||
    !managerForBroadLane.includes('AppendBookOfDaysEntry("The code was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)') ||
    !managerForBroadLane.includes('AppendBookOfDaysEntry("The Yokudan path was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "sect", False)') ||
    !managerForBroadLane.includes('return "public civic service"')
  ) {
    fail("Reason-bearing substrate acts must feed both Prisma toast/ledger and the Book of Days chronicle.", managerPath);
  } else {
    pass("Reason-bearing substrate acts feed both Prisma toast/ledger and the Book of Days chronicle.", managerPath);
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
verifyParityRegistryContracts(path.join(REPO_ROOT, "references", "authoring", "PDV_PrismaParityRegistry.csv"));

for (const item of passes) {
  console.log(`[PASS] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
}
for (const item of failures) {
  console.error(`[FAIL] ${item.message}${item.source ? ` [${item.source}]` : ""}`);
}

if (failures.length > 0) {
  process.exit(1);
}

console.log(`Prisma UI audit passed: ${passes.length} checks.`);
