#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), "utf8");
const exists = (...parts) => fs.existsSync(path.join(root, ...parts));
const failures = [];
const pass = (label) => console.log(`[PASS] ${label}`);
const requireTrue = (condition, label, detail = "") => {
  if (condition) pass(label);
  else failures.push(`${label}${detail ? `: ${detail}` : ""}`);
};

const functionBlock = (source, functionName) => {
  const pattern = new RegExp(`(?:[A-Za-z_][\\w]*\\s+)?Function\\s+${functionName}\\b[\\s\\S]*?EndFunction`, "i");
  return source.match(pattern)?.[0] ?? "";
};

const eventBlock = (source, eventName) => {
  const pattern = new RegExp(`Event\\s+${eventName}\\b[\\s\\S]*?EndEvent`, "i");
  return source.match(pattern)?.[0] ?? "";
};

const spidPath = ["mod-data", "PDV_ReligiousRecognition_DISTR.ini"];
const kidPaths = [
  ["mod-data", "PDV_GreenPact_KID.ini"],
  ["mod-data", "PDV_ItemRecognition_KID.ini"],
];
const manifestPath = ["references", "authoring", "PDV_SPIDKIDRecognition.manifest.json"];
requireTrue(exists(...spidPath) && kidPaths.every((p) => exists(...p)), "flat Data distributor files exist");
requireTrue(!exists("mod-data", "SKSE", "Plugins", "KeywordItemDistributor", "PDV_GreenPact_KID.ini"), "retired nested KID path is absent");

const manifest = JSON.parse(read(...manifestPath));
requireTrue(manifest.recognition.enabledByDefault === true, "recognition defaults on");
requireTrue(manifest.recognition.hostileReactionsEnabledByDefault === true, "hard-rival reactions default on");
requireTrue(manifest.kidLanes.length === 7, "seven KID action lanes declared");
requireTrue(manifest.greenPactNeutralFamilies.join(",") === "Fungi,Egg,Insect", "Green Pact neutral families locked");
requireTrue(manifest.antiFarm.sameDayMultiplier === 0.7 && manifest.antiFarm.dailyPietyClamp === 4.3, "anti-farm contract preserved");

const activeLines = (text) => text.split(/\r?\n/).map((x) => x.trim()).filter((x) => x && !x.startsWith(";"));
const spidLines = activeLines(read(...spidPath));
const allowedSpidTypes = new Set(["Keyword", "Faction"]);
for (const [index, line] of spidLines.entries()) {
  const match = line.match(/^(\w+)\s*=\s*(.+)$/);
  requireTrue(Boolean(match), `SPID line ${index + 1} parses`);
  if (!match) continue;
  requireTrue(allowedSpidTypes.has(match[1]), `SPID line ${index + 1} uses allowed form type`);
  requireTrue(match[2].split("|").length <= 7, `SPID line ${index + 1} has no extra fields`);
}
const spidKeywords = spidLines.filter((x) => x.startsWith("Keyword = ")).map((x) => x.split("=")[1].trim().split("|")[0]);
const spidFactions = spidLines.filter((x) => x.startsWith("Faction = "));
requireTrue(spidKeywords.length > 0 && spidFactions.length >= spidKeywords.length, "every SPID evidence family has a cohort rule");
requireTrue(spidFactions.every((line) => line.includes("|PDV_KYWD_Faith_")), "SPID faction rules consume faith keywords");
requireTrue(!spidLines.some((line) => /^(Package|Item|Spell|Perk|Outfit|Skin)\s*=/.test(line)), "SPID layer changes no AI or inventory forms");

const allowedKidTypes = new Set(["Armor", "Weapon", "Potion", "Ingredient", "Misc Item"]);
for (const kidPath of kidPaths) {
  for (const [index, line] of activeLines(read(...kidPath)).entries()) {
    const match = line.match(/^Keyword\s*=\s*(.+)$/);
    requireTrue(Boolean(match), `${kidPath.at(-1)} line ${index + 1} parses`);
    if (!match) continue;
    const fields = match[1].split("|");
    requireTrue(fields.length >= 3 && fields.length <= 5, `${kidPath.at(-1)} line ${index + 1} field count`);
    requireTrue(allowedKidTypes.has(fields[1]), `${kidPath.at(-1)} line ${index + 1} item type`);
  }
}

const manager = read("live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const playerEvents = read("live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
const mcm = read("live-source", "Scripts", "Source", "PDV_MCM.psc");
for (const token of [
  "PDV.Recognition.Claim", "PDV.Recognition.Release", "PDV.Recognition.State",
  "RECOGNITION_REACTION_NEUTRAL = 0", "RECOGNITION_REACTION_ENEMY = 1",
  "RECOGNITION_REACTION_ALLY = 2", "RECOGNITION_REACTION_FRIEND = 3",
  "Function HandleKIDAction", "ConsumeDailyRepeatMultiplier(\"PDV.Signal.KID.\"",
]) requireTrue(manager.includes(token), `manager contains ${token}`);
for (const token of [
  "Faction _recognitionPlayerFaction = None",
  "Faction[] _recognitionCohortFactions",
  "Bool _recognitionFormsResolved = False",
  "Function EnsureRecognitionForms()",
  "_recognitionCohortFactions[identityIndex] = Game.GetFormFromFile",
  "Bool recognitionEnabled = NpcReligiousRecognitionEnabled()",
  "Bool hostileRecognitionEnabled = NpcHostileRecognitionEnabled()",
]) requireTrue(manager.includes(token), `manager recognition cache contains ${token}`);
requireTrue(
  !manager.includes('return Game.GetFormFromFile(0x00071756, "Devotion.esp") as Faction') &&
    !manager.includes('return Game.GetFormFromFile(0x00071757 + identityIndex, "Devotion.esp") as Faction'),
  "recognition getters do not repeat owned-form lookups",
);
requireTrue((manager.match(/sourceForm\.GetName\(\)/g) ?? []).length === 1, "KID source name resolves once per action");

const syncRecognition = functionBlock(manager, "SyncNpcReligiousRecognition");
const surfaceRecognition = functionBlock(manager, "SurfaceNpcRecognitionTransition");
const recognitionPayload = functionBlock(manager, "GetNpcRecognitionPanelJson");
const recognitionAdvisory = functionBlock(manager, "GetNpcRecognitionAdvisory");
const focusedPanel = functionBlock(manager, "PushDevotionPanel");
const updateEvent = eventBlock(manager, "OnUpdate");
const compatPage = functionBlock(mcm, "BuildCompatPage");

requireTrue(syncRecognition.length > 0, "recognition sync function is present");
requireTrue(surfaceRecognition.length > 0, "recognition transition presentation function is present");
requireTrue(recognitionPayload.length > 0, "focused-panel recognition payload builder is present");
requireTrue(
  manager.includes('"PDV.Recognition.LastPresentedSignature"') &&
    manager.includes('"PDV.Recognition.LastSignature"'),
  "presentation dedupe is stored separately from relation-sync dedupe",
);
requireTrue(
  syncRecognition.includes("SurfaceNpcRecognitionTransition(") &&
    syncRecognition.indexOf('StorageUtil.SetIntValue(None, "PDV.Recognition.LastSignature", signature)') <
      syncRecognition.indexOf("SurfaceNpcRecognitionTransition("),
  "recognition presentation follows the effective relation-state write",
);
requireTrue(
  surfaceRecognition.includes('StorageUtil.GetIntValue(None, "PDV.Recognition.LastPresentedSignature"') &&
    surfaceRecognition.includes('StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature"'),
  "recognition transition presentation is signature-deduped",
);
requireTrue(
  surfaceRecognition.includes("SendPrismaToast(") &&
    surfaceRecognition.includes("AppendBookOfDaysEntry(") &&
    surfaceRecognition.indexOf("SendPrismaToast(") < surfaceRecognition.indexOf("AppendBookOfDaysEntry("),
  "one recognition transition route pairs Prisma-first toast with Book of Days entry",
);
requireTrue(
  !surfaceRecognition.includes("PushDevotionPanel(") &&
    !surfaceRecognition.includes("SendJson(") &&
    !surfaceRecognition.includes("SendOverlayJson("),
  "recognition transitions never auto-open the focused panel",
);
requireTrue(
  !updateEvent.includes("SyncNpcReligiousRecognition(") &&
    !updateEvent.includes("SurfaceNpcRecognitionTransition("),
  "recognition sync and presentation are not polled from OnUpdate",
);
const npcScanTokens = [
  "FindClosestActor",
  "FindRandomActor",
  "GetHighActors",
  "GetNumRefs",
  "GetNthRef",
  "GetNumReferenceAliases",
];
const recognitionSection = manager.slice(manager.indexOf("; SPID religious recognition"));
requireTrue(
  npcScanTokens.every((token) => !recognitionSection.includes(token)),
  "recognition state changes do not scan nearby or loaded NPCs",
);

for (const field of ["enabled", "managed", "status", "identity", "band", "advisory"]) {
  requireTrue(recognitionPayload.includes(`\\\"${field}\\\"`), `focused-panel recognition payload contains ${field}`);
}
requireTrue(
  focusedPanel.includes(',\\"recognition\\":') && focusedPanel.includes("GetNpcRecognitionPanelJson()"),
  "player-requested focused panel carries persistent recognition state",
);
requireTrue(
  focusedPanel.includes("if !playerRequested") && focusedPanel.includes("return False"),
  "focused panel remains player-requested only",
);
requireTrue(
  recognitionPayload.includes("NpcReligiousRecognitionEnabled()") &&
    recognitionPayload.includes('StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")') &&
    recognitionAdvisory.includes("if !recognitionEnabled") &&
    recognitionAdvisory.includes('elseIf ownerName != ""') &&
    recognitionAdvisory.includes("band >= TIER_DEVOTED"),
  "focused-panel recognition state distinguishes disabled, external-owner, and below-Faithful states",
);
requireTrue(
  compatPage.includes('AddTextOption("Current", PDV_Manager.GetNpcRecognitionStatusLine(), OPTION_FLAG_DISABLED)') &&
    !/if\s+devMode\s+AddTextOption\("Current",\s*PDV_Manager\.GetNpcRecognitionStatusLine\(\)/i.test(compatPage),
  "MCM Current recognition line is visible outside developer mode",
);
for (const token of ["RouteKIDEquippedAction", "RouteKIDTrophyPickup", "RouteKIDRemovedAction", "RegisterForMenu(\"BarterMenu\")"])
  requireTrue(playerEvents.includes(token), `player ingress contains ${token}`);
for (const token of ["Religious recognition", "Hard-rival reactions", "SetNpcReligiousRecognitionEnabled", "SetNpcHostileRecognitionEnabled"])
  requireTrue(mcm.includes(token), `MCM contains ${token}`);
requireTrue(playerEvents.includes('Trace(3, "Green Pact insect food ignored.")') && !playerEvents.includes("Green Pact insect food positive routed"), "fungi, eggs, and insects remain inert");

const releaseManifest = JSON.parse(read("references", "authoring", "PDV_ReleasePayload.manifest.json"));
for (const file of ["PDV_GreenPact_KID.ini", "PDV_ItemRecognition_KID.ini", "PDV_ReligiousRecognition_DISTR.ini"])
  requireTrue(releaseManifest.fixedEntries.includes(file), `release payload includes ${file}`);

if (failures.length) {
  console.error(`\nSPID/KID recognition audit failed (${failures.length}):`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}
console.log(`\nSPID/KID recognition audit passed (${spidLines.length} SPID rules).`);
