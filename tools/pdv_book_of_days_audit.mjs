#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { hashBytes, hashText } from "./lib/pdv_file_compare.mjs";

const TOOLS_DIR = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(TOOLS_DIR, "..");
const REPO_VIEW = path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion");
const LIVE_VIEW =
  process.env.PDV_AUDIT_LIVE_PRISMA ||
  "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\PrismaUI\\views\\Devotion";
const SOURCE =
  process.env.PDV_AUDIT_LIVE_SOURCE ||
  "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts\\Source";
const COMPILED =
  process.env.PDV_AUDIT_COMPILED ||
  "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts";
const MANAGER = path.join(SOURCE, "PDV__ManagerQuest.psc");
const DIRECTOR = path.join(SOURCE, "PDV_DiegeticDirector.psc");
const MCM = path.join(SOURCE, "PDV_MCM.psc");
const MANAGER_PEX = path.join(COMPILED, "PDV__ManagerQuest.pex");
const MCM_PEX = path.join(COMPILED, "PDV_MCM.pex");
const NATIVE_MAIN = path.join(ROOT, "native", "DevotionPrismaBridge", "src", "main.cpp");

const results = [];
const add = (level, message, source = "") => results.push({ level, message, source });
const read = (filePath) => fs.readFileSync(filePath, "utf8");
const BYTE_EXTENSIONS = new Set([".ttf", ".woff", ".woff2"]);
const hash = (filePath) => BYTE_EXTENSIONS.has(path.extname(filePath).toLowerCase()) ? hashBytes(filePath) : hashText(filePath);

function mustExist(filePath) {
  if (!fs.existsSync(filePath)) {
    add("FAIL", "Missing required file.", filePath);
    return false;
  }
  return true;
}

function requireText(filePath, needles, label) {
  if (!mustExist(filePath)) return;
  const source = read(filePath);
  for (const needle of needles) {
    if (source.includes(needle)) {
      add("PASS", `${label} contains ${needle}.`, filePath);
    } else {
      add("FAIL", `${label} is missing ${needle}.`, filePath);
    }
  }
}

function forbidText(filePath, needles, label) {
  if (!mustExist(filePath)) return;
  const source = read(filePath);
  for (const needle of needles) {
    if (source.includes(needle)) {
      add("FAIL", `${label} still contains stale marker ${needle}.`, filePath);
    } else {
      add("PASS", `${label} omits stale marker ${needle}.`, filePath);
    }
  }
}

function functionBlock(source, name) {
  const match = source.match(new RegExp(`(?:String\\s+)?Function\\s+${name}\\b[\\s\\S]*?EndFunction`, "i"));
  return match ? match[0] : "";
}

function timestamp(filePath) {
  return fs.statSync(filePath).mtimeMs;
}

function formatTimestamp(filePath) {
  return fs.statSync(filePath).mtime.toISOString();
}

function requirePexAtLeastAsFresh(pexPath, dependencyPath, label) {
  if (!mustExist(pexPath) || !mustExist(dependencyPath)) return;
  if (timestamp(pexPath) + 1000 >= timestamp(dependencyPath)) {
    add("PASS", `${label} PEX is fresh against ${path.basename(dependencyPath)}.`, pexPath);
  } else {
    add(
      "FAIL",
      `${label} PEX is older than ${path.basename(dependencyPath)}; recompile before in-game Prisma testing (${path.basename(pexPath)} ${formatTimestamp(pexPath)} < ${path.basename(dependencyPath)} ${formatTimestamp(dependencyPath)}).`,
      pexPath,
    );
  }
}

function verifyJournalBytecodeFreshness() {
  requirePexAtLeastAsFresh(MANAGER_PEX, MANAGER, "Manager journal payload");
  requirePexAtLeastAsFresh(MCM_PEX, MCM, "Book of Days hotkey");

  if (!mustExist(MANAGER) || !mustExist(MCM) || !mustExist(MANAGER_PEX) || !mustExist(MCM_PEX)) return;
  const manager = read(MANAGER);
  const mcm = read(MCM);
  if (
    manager.includes("Function SendPrismaJournalPayload(Bool playerRequested") &&
    mcm.includes("PDV_Manager.SendPrismaJournalPayload(")
  ) {
    requirePexAtLeastAsFresh(MCM_PEX, MANAGER, "Book of Days hotkey dependency");
    requirePexAtLeastAsFresh(MCM_PEX, MANAGER_PEX, "Book of Days hotkey dependency");
  }
}

const FORM_NAME_ALIASES = { PDV_Kyne: "Kyne", PDV_Talos: "Talos" };

function parseNameSymbolMap(block) {
  const out = new Map();
  for (const segment of block.split(/endIf/i)) {
    const symbolMatch = segment.match(/return\s+"([^"]+)"/);
    if (!symbolMatch) continue;
    const symbol = symbolMatch[1];
    for (const m of segment.matchAll(/(?:deity\.)?DeityName\s*==\s*"([^"]+)"/g)) {
      out.set(m[1], symbol);
    }
    for (const m of segment.matchAll(/name\s*==\s*"([^"]+)"/g)) {
      out.set(m[1], symbol);
    }
    for (const m of segment.matchAll(/deity\s*==\s*(PDV_\w+)/g)) {
      const alias = FORM_NAME_ALIASES[m[1]];
      if (alias) out.set(alias, symbol);
    }
  }
  return out;
}

for (const name of ["index.html", "styles.css", "app.js"]) {
  const repoPath = path.join(REPO_VIEW, name);
  const livePath = path.join(LIVE_VIEW, name);
  if (!mustExist(repoPath) || !mustExist(livePath)) continue;
  const repoHash = hash(repoPath);
  const liveHash = hash(livePath);
  if (repoHash === liveHash) {
    add("PASS", `${name} repo/live hashes match (${repoHash.slice(0, 12)}).`, repoPath);
  } else {
    add("FAIL", `${name} repo/live hashes differ (${repoHash.slice(0, 12)} != ${liveHash.slice(0, 12)}).`, livePath);
  }
}

for (const name of [
  "IMFellEnglish-Regular.woff2",
  "IMFellEnglish-Italic.woff2",
  "IMFellEnglish-Regular.ttf",
  "IMFellEnglish-Italic.ttf",
]) {
  const repoPath = path.join(REPO_VIEW, "fonts", name);
  const livePath = path.join(LIVE_VIEW, "fonts", name);
  if (mustExist(repoPath) && mustExist(livePath)) {
    add(hash(repoPath) === hash(livePath) ? "PASS" : "FAIL", `${name} repo/live font hashes match.`, repoPath);
  }
}

requireText(path.join(REPO_VIEW, "index.html"), [
  "bod-scaler",
  "class=\"bod\"",
  "pdv-journal-by",
  "pdv-journal-emblem",
  "pdv-journal-instrument",
  "pdv-journal-foot",
  "bod-standing-label",
  "bod-instrument",
  "bod-flourish",
  "bod-chroniclehead",
], "repo index");

requireText(path.join(REPO_VIEW, "styles.css"), [
  "@font-face",
  "PDV IM Fell English",
  "IMFellEnglish-Regular.ttf",
  "IMFellEnglish-Italic.ttf",
  ".bod-scaler",
  ".bod",
  ".bod-emblem",
  ".bod-chroniclehead",
  ".bod-standing-label",
  ".bod-instrument",
  ".bod-leaf",
  ".bod-leaf__symbol",
  ".instrument-fade",
  ".instrument-star",
  ".instrument-blood",
], "repo styles");

requireText(path.join(REPO_VIEW, "app.js"), [
  "overlayController",
  "closeStartupFromView",
  "onOverlayEsc",
  'overlayController.open("journal")',
  'overlayController.open("startup")',
  "journalMagnitude",
  "entry.magnitude",
  "entry.valence",
  "entry.symbol",
  "journal.by",
  "journal.foot",
  "journal.instrument",
  "journalClose",
  "buildJournalSun",
  "renderJournalStanding",
  "journalEmblem",
  "journalInstrument",
  "journalRune",
  "bod-leaf__symbol",
  "replace(/\\b(true|false)\\b/gi",
  "thresholdValue = thresholds[index] ? thresholds[index].value : 85",
  "thresholdX = Math.round(74 + 190 * clamp01(thresholdValue / 85))",
], "repo app");

forbidText(path.join(REPO_VIEW, "app.js"), [
  "bod-sun-ray-fill",
  "bod-standing-diamond",
  "journal-rune-mark",
  "bod-ledger",
  "bod-gauge__labels",
  "bod-gauge-caption",
], "repo app");

forbidText(path.join(REPO_VIEW, "styles.css"), [
  ".bod-sun-ray-fill",
  ".bod-standing-diamond",
  ".journal-rune-mark",
  ".bod-ledger",
  ".bod-gauge__labels",
  ".bod-gauge-caption",
], "repo styles");

forbidText(path.join(REPO_VIEW, "index.html"), [
  "bod-ledger",
], "repo index");

requireText(MANAGER, [
  "PDV.Diegetic.Journal.Magnitudes",
  "PDV.Diegetic.Journal.Titles",
  "BuildJournalPayloadJson",
  "BuildBookOfDaysPathInfo",
  "GetBookOfDaysPathStatusLabel",
  "BuildBookOfDaysSummary",
  "ResolveBookOfDaysStandingDeity",
  "BuildBookOfDaysInstrumentJson",
  "\\\"by\\\"",
  "\\\"foot\\\"",
  "\\\"instrument\\\"",
  "\\\"magnitude\\\"",
  "\\\"symbol\\\"",
  "BuildJournalEventTitle",
  "ShowP2BookNotice",
  'AppendBookOfDaysEntry("You offered prayer at the shrine of "',
  "GetJournalMagnitudeForTone",
  // "RefreshOpenBookOfDays" dropped 2026-08-07: the standalone function was a superseded
  // duplicate of the reconciliation PDV_MCM's journal hotkey already does inline, and a needle
  // that pins a function NAME dies with the function. The behaviour is asserted against
  // PDV_MCM.psc in pdv_prisma_ui_audit. The key below still pins the state this gate cares about.
  "PDV.Diegetic.Journal.Open",
  "PDV.BookOfDays.LastTierDeity",
  "BuildTierReachJournalLine",
  "GetTierStandingLabel(newTier)",
  "GetTierStandingLabel(TIER_CHAMPION)",
  'PDV_DiegeticDirectorService && !(eventClass == "tier" && direction == "reach")',
], "manager source");

forbidText(MANAGER, [
  "path not yet chosen",
  'j = j + ",\\"summary\\":\\"A record of devotional acts since the path began.\\""',
], "manager source");

if (mustExist(MANAGER)) {
  const manager = read(MANAGER);
  const journalBuilder = functionBlock(manager, "BuildJournalPayloadJson");
  if (
    manager.includes("String Function BuildJournalPayloadJson(Int page") ||
    !journalBuilder.includes('j = j + ",\\"entries\\":[" + entries + "]"') ||
    journalBuilder.includes("if page == 1") ||
    journalBuilder.includes('j = j + ",\\"entries\\":[]') ||
    journalBuilder.includes('j = j + ",\\"dashboard\\":" + GetDashboardJson()') ||
    journalBuilder.includes('j = j + ",\\"page\\":"') ||
    journalBuilder.includes("Both datasets ship every push")
  ) {
    add("FAIL", "Book of Days payload builder must remain Chronicle-only and must not ship an embedded Ledger page.", MANAGER);
  } else {
    add("PASS", "Book of Days payload builder remains Chronicle-only with no embedded Ledger page.", MANAGER);
  }

  const staleChampionSurface = /SurfaceTransition\("tier",\s*deity\.DeityName\s*\+\s*" "\s*\+\s*GetPublicTierBand\(TIER_CHAMPION\)/.test(manager);
  if (staleChampionSurface) {
    add("FAIL", "Champion reward Book of Days surfaces must use internal tier labels, not public bands.", MANAGER);
  } else {
    add("PASS", "Champion reward Book of Days surfaces use internal tier labels.", MANAGER);
  }

  const instrumentBuilder = functionBlock(manager, "BuildBookOfDaysInstrumentJson");
  const hasBretonPracticeFallback =
    instrumentBuilder.includes("elseIf originRace == ORIGIN_BRETON") &&
    instrumentBuilder.includes("Int bretonPracticeTier = TIER_NONE") &&
    instrumentBuilder.includes("bretonPracticeTier = GetBretonPracticeTier(GetBretonTraditionValue())") &&
    instrumentBuilder.includes("pietyValue = GetBretonPracticeCount(GetBretonTraditionValue()) as Float") &&
    instrumentBuilder.includes("tierLabel = GetPublicTierBand(bretonPracticeTier)") &&
    manager.includes("Int Property BRETON_PRACTICE_SEEKER_POINTS = 25 AutoReadOnly") &&
    manager.includes("Int Property BRETON_PRACTICE_DEVOTED_POINTS = 50 AutoReadOnly");
  if (hasBretonPracticeFallback) {
    add("PASS", "Book of Days uses Breton practice points and the 25/50 tier contract when no patron or pact owns the standing gauge.", MANAGER);
  } else {
    add("FAIL", "Book of Days must use Breton practice points and the 25/50 tier contract when no patron or pact owns the standing gauge.", MANAGER);
  }

  const recognitionSurface = functionBlock(manager, "SurfaceNpcRecognitionTransition");
  const hasSeparatePresentationDedupe =
    manager.includes('"PDV.Recognition.LastSignature"') &&
    recognitionSurface.includes('StorageUtil.GetIntValue(None, "PDV.Recognition.LastPresentedSignature"') &&
    recognitionSurface.includes('StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature"');
  if (hasSeparatePresentationDedupe) {
    add("PASS", "NPC recognition Chronicle presentation has its own transition dedupe state.", MANAGER);
  } else {
    add("FAIL", "NPC recognition Chronicle presentation must dedupe separately from relation synchronization.", MANAGER);
  }

  if (
    recognitionSurface.includes("SendPrismaToast(") &&
    recognitionSurface.includes("AppendBookOfDaysEntry(") &&
    recognitionSurface.indexOf("SendPrismaToast(") < recognitionSurface.indexOf("AppendBookOfDaysEntry(") &&
    !recognitionSurface.includes("PushDevotionPanel(") &&
    !recognitionSurface.includes("SendOverlayJson(")
  ) {
    add("PASS", "NPC recognition transitions pair one Prisma toast with one Book of Days entry without opening focused UI.", MANAGER);
  } else {
    add("FAIL", "NPC recognition transitions must pair one Prisma toast with one Book of Days entry and must not open focused UI.", MANAGER);
  }
}

requireText(NATIVE_MAIN, [
  "void HideJournalDom() noexcept",
  'g_prisma->InteropCall(g_view, kReceiveOverlayFunction.data(), "{\\"journalClose\\":true}");',
  "HideJournalDom();",
  "CloseJournalSurface(std::string_view a_source",
], "native bridge source");

requireText(DIRECTOR, [
  "Function EmitJournal(Int deityIndex, String toneKey)",
  "PDV.Diegetic.Journal.PendingCount",
], "director source");

requireText(MCM, [
  "_oidOpenJournalNow = AddTextOption(\"Open Book of Days\", \"Open now\", OPTION_FLAG_NONE)",
  "_oidJournalHotkey = AddKeyMapOption(\"Book of Days key\", currentJournalKey, OPTION_FLAG_NONE)",
  "Function OpenBookOfDaysFromMcm()",
  "PDV_Manager.SendPrismaJournalPayload(True)",
  "ResetBookOfDaysOptionIds()",
], "mcm source");

forbidText(MCM, [
  "PDV_Manager.SendPrismaJournalPayload(True, 1)",
  "You turn to the Ledger -- what feeds your gods.",
], "mcm source");

verifyJournalBytecodeFreshness();

forbidText(DIRECTOR, [
  'StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Lines"',
  'StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Days"',
  'StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Tones"',
  'StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Symbols"',
  'StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Magnitudes"',
  'StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Titles"',
], "director source");

if (mustExist(MANAGER)) {
  const manager = read(MANAGER);
  const managerMap = parseNameSymbolMap(functionBlock(manager, "GetPrismaSymbolForDeity"));
  for (const name of ["Peryite", "Stendarr", "Kyne", "Akatosh", "Baan Dar", "Auri-El", "Hircine"]) {
    const symbol = managerMap.get(name);
    if (symbol && symbol !== "journal") {
      add("PASS", `Manager journal symbol available for ${name} -> ${symbol}.`, MANAGER);
    } else {
      add("FAIL", `Manager journal symbol missing for ${name}.`, MANAGER);
    }
  }
}

const counts = { PASS: 0, WARN: 0, FAIL: 0 };
for (const result of results) counts[result.level] += 1;
for (const result of results) {
  const stream = result.level === "FAIL" ? console.error : console.log;
  stream(`[${result.level}] ${result.message}${result.source ? ` [${result.source}]` : ""}`);
}
console.log(`Book of Days audit: PASS=${counts.PASS}, WARN=${counts.WARN}, FAIL=${counts.FAIL}.`);
process.exit(counts.FAIL > 0 ? 1 : 0);
