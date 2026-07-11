#!/usr/bin/env node
/*
 * Read-only guard for the deity signal remap tranche.
 * This does not prove runtime behavior; it keeps the implementation wiring from
 * drifting before in-game smoke covers visible behavior.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");

const files = {
  manager: path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc"),
  tranche: path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv"),
  merge: path.join(ROOT, "tools", "pdv_quest_tranche_merge.mjs"),
  likes: path.join(ROOT, "references", "authoring", "PDV_DeityLikesDislikes.csv"),
  full: path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv"),
  stance: path.join(ROOT, "references", "phase4", "PDV_StanceMatrix.csv"),
  daedricMatrix: path.join(ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv"),
  daedricContracts: path.join(ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json"),
  readback: path.join(ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv"),
  medallion: path.join(ROOT, "references", "authoring", "PDV_MedallionRoster.manifest.json"),
  prismaApp: path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "app.js"),
  playerEvents: path.join(ROOT, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc"),
  eventBus: path.join(ROOT, "live-source", "Scripts", "Source", "PDV_EventBus.psc"),
};

const failures = [];
const warnings = [];

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function readJson(file) {
  return JSON.parse(read(file));
}

function assert(name, condition, detail) {
  if (!condition) failures.push({ name, detail });
}

function warn(name, condition, detail) {
  if (!condition) warnings.push({ name, detail });
}

function parseCsvLine(line) {
  const cols = [];
  let cur = "";
  let quote = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (ch === "\"") {
      if (quote && line[i + 1] === "\"") {
        cur += "\"";
        i += 1;
      } else {
        quote = !quote;
      }
    } else if (ch === "," && !quote) {
      cols.push(cur);
      cur = "";
    } else {
      cur += ch;
    }
  }
  cols.push(cur);
  return cols;
}

function parseCsv(text) {
  const lines = text.split(/\r?\n/).filter((line) => line.trim().length > 0);
  const header = parseCsvLine(lines.shift());
  return lines.map((line, index) => {
    const cols = parseCsvLine(line);
    return { lineNumber: index + 2, cols, row: Object.fromEntries(header.map((key, i) => [key, cols[i] ?? ""])) };
  });
}

function functionBody(source, functionName) {
  const startToken = `Function ${functionName}`;
  const start = source.indexOf(startToken);
  if (start < 0) return "";
  const next = source.indexOf("\nFunction ", start + startToken.length);
  return source.slice(start, next < 0 ? source.length : next);
}

const RACES = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];

const ORIGIN_ROSTERS = {
  Nord: ["Kyne", "Kynareth", "Talos", "Shor", "Tsun", "Stuhn", "Mara", "Akatosh", "Arkay", "Stendarr", "Julianos", "Dibella", "Zenithar"],
  Imperial: ["Kynareth", "Mara", "Akatosh", "Arkay", "Stendarr", "Julianos", "Dibella", "Zenithar"],
  Breton: ["Kynareth", "Talos", "Mara", "Akatosh", "Arkay", "Stendarr", "Julianos", "Dibella", "Zenithar", "Magnus", "Y'ffre"],
  Altmer: ["Mara", "Stendarr", "Magnus", "Y'ffre", "Auri-El", "Xarxes", "Trinimac", "Syrabane"],
  Bosmer: ["Y'ffre", "Auri-El", "Xarxes", "Baan Dar", "Z'en"],
  Dunmer: ["Azura", "Boethiah", "Mephala"],
  Khajiit: ["Azura", "Boethiah", "Mephala", "Baan Dar", "Rajhin", "Alkosh", "Khenarthi"],
  Argonian: ["The Hist", "Sithis"],
  Orc: ["Malacath"],
  Redguard: ["Tu'whacca", "Leki", "HoonDing"],
};

function normalizeName(value) {
  return String(value ?? "")
    .trim()
    .replace(/[’]/g, "'")
    .replace(/\s+/g, " ")
    .toLowerCase();
}

function splitAliasNames(value) {
  return String(value ?? "")
    .split("/")
    .map((part) => part.trim())
    .filter(Boolean);
}

function buildStanceLookup(stanceEntries) {
  const byName = new Map();
  for (const entry of stanceEntries) {
    for (const alias of splitAliasNames(entry.row.WorshipObject)) {
      byName.set(normalizeName(alias), entry.row);
    }
  }
  const hist = byName.get(normalizeName("Hist"));
  if (hist) byName.set(normalizeName("The Hist"), hist);
  return byName;
}

function buildDaedricNames(matrixEntries, contracts) {
  const names = new Set();
  for (const entry of matrixEntries) {
    for (const alias of splitAliasNames(entry.row.Prince)) names.add(normalizeName(alias));
  }
  for (const prince of contracts.princes ?? []) names.add(normalizeName(prince.displayName));
  return names;
}

function runtimeStanceFor(deityName, race, stanceByName) {
  if (normalizeName(deityName) === normalizeName("Z'en")) {
    return race === "Bosmer" ? "NATIVE" : "FOREIGN";
  }
  const row = stanceByName.get(normalizeName(deityName));
  return row?.[race] || "FOREIGN";
}

function potentialOffRosterHostileSurfaces(fullEntries, stanceByName, daedricNames) {
  const rosters = Object.fromEntries(
    Object.entries(ORIGIN_ROSTERS).map(([race, names]) => [race, new Set(names.map(normalizeName))]),
  );
  const groups = new Map();
  for (const entry of fullEntries) {
    const key = `${entry.row.editor_id}|${entry.row.outcome_stage}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(entry);
  }

  const findings = [];
  for (const [key, entries] of groups.entries()) {
    const distinctDeities = new Set(entries.map((entry) => entry.row.deity));
    if (distinctDeities.size < 2) continue;
    for (const entry of entries) {
      const deity = entry.row.deity;
      const isDaedricPath = daedricNames.has(normalizeName(deity));
      if (isDaedricPath) continue;
      for (const race of RACES) {
        if (rosters[race].has(normalizeName(deity))) continue;
        const stance = runtimeStanceFor(deity, race, stanceByName);
        if (stance === "TABOO" || stance === "HOSTILE") {
          findings.push({
            key,
            lineNumber: entry.lineNumber,
            race,
            deity,
            valence: entry.row.valence,
            stance,
          });
        }
      }
    }
  }
  return findings;
}

const manager = read(files.manager);
const playerEvents = read(files.playerEvents);
const eventBus = read(files.eventBus);
const medallion = read(files.medallion);
const prismaApp = read(files.prismaApp);
const trancheText = read(files.tranche);
const merge = read(files.merge);
const likesRows = parseCsv(read(files.likes));
const trancheRows = parseCsv(trancheText);
const fullRows = parseCsv(read(files.full));
const stanceRows = parseCsv(read(files.stance));
const daedricMatrixRows = parseCsv(read(files.daedricMatrix));
const daedricContracts = readJson(files.daedricContracts);
const readbackRows = parseCsv(read(files.readback));
const readbackIds = new Set(readbackRows.map((entry) => entry.row.editor_id).filter(Boolean));
for (const manualId of ["DA10", "DA13", "DA06", "dunHunterQST", "MS05", "FreeformKolskeggrA", "MQ105U", "MS14", "T01", "t02", "T03"]) {
  readbackIds.add(manualId);
}

assert("shrine cap helper exists", manager.includes("Bool Function ConsumeShrinePrayerCredit("), "Missing shared daily shrine cap helper.");
assert("shrine cap is called", manager.includes("if !ConsumeShrinePrayerCredit(deity, sourceId)"), "AwardShrinePrayerToDeityName does not consume the per-deity daily cap.");
assert("shrine cap key is deity scoped", manager.includes("\"PDV.Signal.ShrinePrayer.\" + deityKey"), "Shrine cap must key by resolved deity, not only by shrine/source.");
assert("likes dislikes version bumped", /Int Property LIKES_DISLIKES_VERSION = 15 AutoReadOnly/.test(manager), "LIKES_DISLIKES_VERSION should be 15 for the signal-floor rows.");
assert("paarthurnax kill helper exists", playerEvents.includes("Bool Function IsPaarthurnaxActor") && playerEvents.includes("RoutePaarthurnaxKill(akVictim as Form)"), "Paarthurnax kill must be detected before Khajiit-only organic kill routing.");
assert("paarthurnax kill eventbus route exists", eventBus.includes("Function RoutePaarthurnaxKill(Form sourceForm)") && eventBus.includes("HandlePaarthurnaxKill(sourceForm, \"eventbus_paarthurnax_kill\")"), "EventBus must expose the global Paarthurnax kill route.");
assert("paarthurnax kill manager route exists", manager.includes("Function HandlePaarthurnaxKill(Form sourceForm, String reason)") && manager.includes("\"PDV.Paarthurnax.KillSeen\""), "Manager must apply the one-shot Paarthurnax kill fork.");
for (const deity of ["Shor", "Tsun", "Kyne", "Stendarr", "Stuhn", "Mara"]) {
  assert(`paarthurnax kill fanout ${deity}`, manager.includes(`ApplyPaarthurnaxKillReaction("${deity}",`), `Missing Paarthurnax kill reaction for ${deity}.`);
}
assert("paarthurnax spare mq305 latch exists", playerEvents.includes("Function RoutePaarthurnaxSpareQuestStage") && playerEvents.includes("MQ305_FORM_ID") && playerEvents.includes("Paarthurnax.GetDeadCount() > 0"), "Paarthurnax spare must latch off MQ305 completion with Paarthurnax still alive.");
assert("paarthurnax spare load catchup exists", playerEvents.includes("Function RoutePaarthurnaxSpareLoadCheck") && playerEvents.includes("load_mq305_complete"), "Existing saves with MQ305 complete and Paarthurnax alive need a load-time spare catchup.");
assert("paarthurnax spare eventbus route exists", eventBus.includes("Function RoutePaarthurnaxSpare(Form sourceForm)") && eventBus.includes("HandlePaarthurnaxSpare(sourceForm, \"eventbus_paarthurnax_spare\")"), "EventBus must expose the global Paarthurnax spare route.");
assert("paarthurnax spare manager route exists", manager.includes("Function HandlePaarthurnaxSpare(Form sourceForm, String reason)") && manager.includes("\"PDV.Paarthurnax.SpareSeen\"") && manager.includes("\"PDV.Paarthurnax.KillSeen\""), "Manager must apply the one-shot Paarthurnax spare fork and suppress it after kill.");
for (const deity of ["Stuhn", "Stendarr", "Mara", "Kyne"]) {
  assert(`paarthurnax spare fanout ${deity}`, manager.includes(`ApplyPaarthurnaxSpareReaction("${deity}",`), `Missing Paarthurnax spare reaction for ${deity}.`);
}

const syncBretonRewards = functionBody(manager, "SyncBretonRewards");
assert("breton hidden art reward uses magnus", syncBretonRewards.includes("BRETON_TRADITION_HIDDEN_ART") && syncBretonRewards.includes("PDV_Magnus"), "Hidden Art reward family should read Magnus.");
assert("breton green way reward uses yffre", syncBretonRewards.includes("BRETON_TRADITION_GREEN_WAY") && syncBretonRewards.includes("PDV_Yffre"), "Green Way reward family should read Y'ffre.");
assert("breton hidden art reward not julianos", !/BRETON_TRADITION_HIDDEN_ART[\s\S]{0,180}PDV_Julianos/.test(syncBretonRewards), "Hidden Art still routes to Julianos.");
assert("breton green way reward not kynareth", !/BRETON_TRADITION_GREEN_WAY[\s\S]{0,180}PDV_Kynareth/.test(syncBretonRewards), "Green Way still routes to Kynareth.");

assert("breton offers included", manager.includes("IsBretonOfferEligibleDeity(deity)"), "Formal offer gate does not include Breton eligibility.");
assert("altmer trinimac offer included", /IsAltmerOfferEligibleDeity[\s\S]*PDV_Trinimac/.test(manager), "Altmer offer eligibility does not include Trinimac.");
assert("altmer syrabane origin roster included", /ORIGIN_ALTMER[\s\S]{0,260}PDV_Syrabane/.test(manager), "Altmer origin roster omits Syrabane, which suppresses dashboard display and quest-reaction reachability.");
assert("altmer syrabane medallion is live roster", manager.includes('RosterMedallionEntry("syrabane", "Syrabane", "god", "syrabane", PDV_Syrabane'), "Altmer medallion still treats Syrabane as pending instead of a live roster deity.");
assert("altmer syrabane medallion not pending", !manager.includes('PendingMedallionEntry("syrabane"'), "Altmer medallion still emits a pending Syrabane entry.");
assert("altmer syrabane prisma symbol route", manager.includes('deity.DeityName == "Syrabane"') && manager.includes('return "syrabane"'), "GetPrismaSymbolForDeity does not resolve Syrabane to the syrabane symbol token.");
assert("altmer syrabane manifest live roster", medallion.includes('"optionId": "syrabane"') && medallion.includes('"deityRecord": "PDV_Deity_Syrabane"'), "Medallion manifest still lacks Syrabane's live deity record.");
assert("altmer syrabane prisma glyph", prismaApp.includes('["syrabane", "Syrabane"]') && /syrabane:\s*\[/.test(prismaApp), "Prisma app.js lacks Syrabane display-name or glyph coverage.");
assert("breton hidden art daedric set present", /Hermaeus Mora/.test(manager) && /Hircine/.test(manager) && /Namira/.test(manager) && /Nocturnal/.test(manager), "Hidden Art Daedric offer set is incomplete.");

const applyDeityReaction = functionBody(manager, "ApplyDeityReaction");
const tabooHostileStart = applyDeityReaction.indexOf('if stance == "TABOO" || stance == "HOSTILE"');
const tabooHostileBranch = tabooHostileStart >= 0 ? applyDeityReaction.slice(tabooHostileStart, applyDeityReaction.indexOf("; Reachability gate", tabooHostileStart)) : "";
const tabooHostileGateIndex = tabooHostileBranch.indexOf("if !IsQuestReactionDeityReachable(deity)");
const tabooHostileStigmaIndex = tabooHostileBranch.indexOf("ApplyQuestReactionStigma");
const tabooHostilePietyIndex = tabooHostileBranch.indexOf("ApplyQuestReactionPiety");
const tabooHostileGateBeforeAwards = tabooHostileGateIndex >= 0
  && (tabooHostileStigmaIndex < 0 || tabooHostileGateIndex < tabooHostileStigmaIndex)
  && (tabooHostilePietyIndex < 0 || tabooHostileGateIndex < tabooHostilePietyIndex);
const potentialHostileLeaks = potentialOffRosterHostileSurfaces(
  fullRows,
  buildStanceLookup(stanceRows),
  buildDaedricNames(daedricMatrixRows, daedricContracts),
);
assert(
  "quest-reaction taboo/hostile off-roster gate",
  tabooHostileGateBeforeAwards,
  `ApplyDeityReaction must reachability-gate TABOO/HOSTILE non-Daedric reactions before piety/stigma/surface; current matrix has ${potentialHostileLeaks.length} potential off-roster hostile/taboo surface(s).`,
);

const generatedBranches = [...manager.matchAll(/(?:if|elseIf) ldName == "([^"]+)"/g)].map((match) => match[1]);
for (const duplicate of ["Akatosh", "Trinimac", "Khenarthi"]) {
  assert(`no unreachable ${duplicate} generated branch`, !generatedBranches.includes(duplicate), `Use the existing runtime key casing for ${duplicate}.`);
}
for (const expected of ["akatosh", "trinimac", "khenarthi", "magnus", "Y'ffre", "Mara"]) {
  assert(`likes branch ${expected}`, generatedBranches.includes(expected), `Missing generated likes/dislikes branch ${expected}.`);
}

assert("tranche included in merge", merge.includes("PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv"), "Tranche9 is not included in the merge helper.");
for (const bad of ["dunEldergleamT03", "MS13", "FreeformSkyHavenTempleA"]) {
  assert(`unsupported editor id absent ${bad}`, !trancheText.includes(bad), `${bad} is not accepted by the current readback-backed compiler surface.`);
}

for (const entry of trancheRows) {
  assert(`tranche row ${entry.lineNumber} column count`, entry.cols.length === 10, `Expected 10 columns, found ${entry.cols.length}.`);
  assert(`tranche row ${entry.lineNumber} readback id`, readbackIds.has(entry.row.editor_id), `No readback row for ${entry.row.editor_id}.`);
  assert(`tranche row ${entry.lineNumber} citation rejects generic context`, /reject|exact|terminal|stage|branch/i.test(entry.row.citation), `Citation should name exact/rejected context: ${entry.row.citation}`);
}

const actors = likesRows.map((entry) => entry.row.actor);
for (const badActor of ["Akatosh", "Trinimac", "Khenarthi"]) {
  assert(`likes actor casing ${badActor}`, !actors.includes(badActor), `${badActor} would generate an unreachable branch.`);
}
for (const actor of ["magnus", "Mara", "Y'ffre", "akatosh", "trinimac", "khenarthi", "sithis"]) {
  assert(`likes actor present ${actor}`, actors.includes(actor), `Missing remap likes/dislikes actor ${actor}.`);
}

warn("thin gods remain design work", !read(files.full).includes("The Hist"), "The merge diagnostic may still report The Hist thin; this is design coverage, not a wiring failure.");

const result = {
  status: failures.length === 0 ? "PASS" : "FAIL",
  failures,
  warnings,
  checked: {
    trancheRows: trancheRows.length,
    fullRows: fullRows.length,
    potentialOffRosterHostileSurfaces: potentialHostileLeaks.length,
    readbackIds: readbackIds.size,
    likesRows: likesRows.length,
  },
};

console.log(JSON.stringify(result, null, 2));
if (failures.length > 0) process.exit(1);
