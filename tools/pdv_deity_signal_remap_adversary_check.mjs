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
  readback: path.join(ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv"),
  medallion: path.join(ROOT, "references", "authoring", "PDV_MedallionRoster.manifest.json"),
  prismaApp: path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "app.js"),
};

const failures = [];
const warnings = [];

function read(file) {
  return fs.readFileSync(file, "utf8");
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

const manager = read(files.manager);
const medallion = read(files.medallion);
const prismaApp = read(files.prismaApp);
const trancheText = read(files.tranche);
const merge = read(files.merge);
const likesRows = parseCsv(read(files.likes));
const trancheRows = parseCsv(trancheText);
const readbackRows = parseCsv(read(files.readback));
const readbackIds = new Set(readbackRows.map((entry) => entry.row.editor_id).filter(Boolean));
for (const manualId of ["DA10", "DA13", "DA06", "dunHunterQST", "MS05", "FreeformKolskeggrA", "MQ105U", "MS14", "T01", "t02", "T03"]) {
  readbackIds.add(manualId);
}

assert("shrine cap helper exists", manager.includes("Bool Function ConsumeShrinePrayerCredit("), "Missing shared daily shrine cap helper.");
assert("shrine cap is called", manager.includes("if !ConsumeShrinePrayerCredit(deity, sourceId)"), "AwardShrinePrayerToDeityName does not consume the per-deity daily cap.");
assert("shrine cap key is deity scoped", manager.includes("\"PDV.Signal.ShrinePrayer.\" + deityKey"), "Shrine cap must key by resolved deity, not only by shrine/source.");
assert("likes dislikes version bumped", /Int Property LIKES_DISLIKES_VERSION = 15 AutoReadOnly/.test(manager), "LIKES_DISLIKES_VERSION should be 15 for the signal-floor rows.");

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
    readbackIds: readbackIds.size,
    likesRows: likesRows.length,
  },
};

console.log(JSON.stringify(result, null, 2));
if (failures.length > 0) process.exit(1);
