#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { familySourceText } from "./lib/pdv_symbol_home.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const at = (...parts) => path.join(ROOT, ...parts);
const read = (...parts) => fs.readFileSync(at(...parts), "utf8");
const failures = [];
const passes = [];
const check = (name, ok, detail) => (ok ? passes : failures).push(`${name}: ${detail}`);

// Resolver-aware: search the manager's decomposition family, not the manager alone,
// so a needle tracks a function that has moved into an extracted module.
const manager = familySourceText(ROOT, at("live-source", "Scripts", "Source"));
const hiddenStart = manager.indexOf("Function HandleBretonSleepEvents");
const hiddenEnd = manager.indexOf("EndFunction", hiddenStart);
const hidden = hiddenStart >= 0 && hiddenEnd > hiddenStart ? manager.slice(hiddenStart, hiddenEnd) : "";
check("Hidden Art function", hidden.length > 0, "HandleBretonSleepEvents is present");
check(
  "Hidden Art Julianos sink",
  hidden.includes("AwardCuratedSignalScaled(PDV_Julianos, PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)"),
  "sleep reflection uses Julianos' compiled lawful-order/civic signal",
);
check("Hidden Art Mara preserved", hidden.includes("AwardCuratedSignalScaled(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None, multiplier)"), "the existing Mara reflection sink remains intact");
check("Hidden Art daily cap", hidden.includes('ConsumeDailyRepeatMultiplier("PDV.Signal.BretonAncestralDream")'), "shared dream repeat key remains active");

const direct = read("references", "authoring", "PDV_SignalFloorDirectRenewables.csv");
check("Hidden Art contract", direct.includes("PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR"), "direct-renewable evidence names the real Julianos property");
const floor = read("references", "authoring", "PDV_SignalFloorLedger.csv");
const floorRows = floor.trim().split(/\r?\n/).slice(1);
check("Signal-floor closeout", floorRows.length === 51 && !floor.includes("UNDER-FLOOR"), `${floorRows.length} paths and no under-floor verdict`);

const kidAuthority = read("references", "authoring", "PDV_ARR25_GreenPact_KID.ini");
const animalNames = [
  "Fox Roast", "Bear Haunch", "Mammoth Roast", "Sabre Cat Steak", "Troll Steak", "Roasted Dog Meat",
  "Chub Loon Breast", "Grilled Chub Loon Breast", "Cliff Racer Tail", "Cliff Racer Stew",
  "Frog Legs", "Fried Frog Legs", "Raw Bantam Guar Thigh", "Roast Bantam Guar Haunch",
];
for (const name of animalNames) check(`KID animal ${name}`, kidAuthority.includes(name), "exact readback name is classified as meat");
check("KID gourd", kidAuthority.includes("Keyword = PDV_KW_GreenPact_Plant|Potion|Gourd"), "three same-name gourd records use the plant keyword");
const kidRules = kidAuthority.split(/\r?\n/).map((line) => line.trim()).filter((line) => line.startsWith("Keyword ="));
check("KID rule grammar", kidRules.length === 4 && kidRules.every((line) => line.split("|").length === 3), `${kidRules.length} exact-name Potion rules use three positional sections`);

check("Likes/dislikes version", /LIKES_DISLIKES_VERSION\s*=\s*\d+\s+AutoReadOnly/.test(manager), "manager retains a versioned likes/dislikes table");

const playerEvents = read("live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
for (const token of ["Function BardPerformancePollTick()", "Function MarkBardTavernDay(Form tavernContext)", '"PDV.BardTavern.Day."', "GetDevotionalDayStamp()", "Bard performance blocked by per-tavern daily cap."]) {
  check(`Bard contract ${token}`, playerEvents.includes(token), "existing daily anti-farm route remains present");
}
check("Bard global decay", manager.includes('ConsumeDailyRepeatMultiplier("PDV.Signal.BardPerformance")'), "manager retains the global devotional repeat budget");

const eventBus = read("live-source", "Scripts", "Source", "PDV_EventBus.psc");
// patch-source/, not dist/. This used to read the BUILD OUTPUT as its source of truth, which
// is exactly the problem issue #41 records: for patch-only scripts the output WAS the source,
// so a dist/ wipe lost it and nothing regenerated it. The source now lives in patch-source/
// and the V3 package builder produces dist/ from the compatibility manifest plus that tree.
const afdiObserver = read("patch-source", "AFDI", "Scripts", "Source", "PDV_AFDIObserver.psc");
for (const token of [
  "Scriptname PDV_AFDIObserver extends Quest",
  "RegisterForUpdate(POLL_INTERVAL)",
  "Function PollDestroyedArtifacts()",
  'String versionKey = "PDV.AFDI.BaselineVersion"',
  "Bool baselineOnly = StorageUtil.GetIntValue(None, versionKey, 0) < BASELINE_VERSION",
  "StorageUtil.SetIntValue(None, seenKey, 1)",
]) {
  check(`AFDI observer ${token}`, afdiObserver.includes(token), "opt-in patch polling and persistent once-only state are present");
}
const afdiIds = ["000FD4", "000FD5", "000FD6", "000FD7", "000FD8", "000FD9", "000FDA", "000FDB", "000FDC", "000FDD", "000FE7", "000FE8", "000FE9", "000FEA", "000FEB", "000FEC", "000FED", "000093", "000FDE", "000FDF", "000FE0", "000FE1", "000FE2", "000FE3", "000FD3", "000F56", "000F55", "0000D9", "000F54", "000110"];
check("AFDI exact global universe", afdiIds.every((id) => afdiObserver.includes(`0x${id}`)), `${afdiIds.length} directly read latched globals are resolved in the patch observer`);
check("AFDI absent from core", !playerEvents.includes("AFDI") && !eventBus.includes("AFDI") && !manager.includes("HandleAFDI") && !manager.includes("Aetherium Forge Destroys Items"), "source-mod polling and semantics are not shipped in core");
check("AFDI Runtime binding", afdiObserver.includes("PDV_QuestReactionRuntime Property PDV_QuestReactionRuntimeService Auto"), "the patch observer depends only on the Runtime semantic ingress");
check("AFDI semantic ingress", afdiObserver.includes('PDV_QuestReactionRuntimeService.SubmitSemanticEvent("afdi", eventId, sourceForm)'), "each detected artifact routes one semantic event through Runtime");
check("Retired Manager batch API", !["BeginExternalReactionBatch", "ApplyExternalReaction", "EndExternalReactionBatch"].some((token) => manager.includes(token) || afdiObserver.includes(token)), "no core or source adapter batch seam remains");
check("AFDI Black Star semantic identity", afdiObserver.includes('SetEntry(1, 0x000FD5, "black_star")') && afdiObserver.includes("GetArtifactEventId"), "the Black Star outcome is now catalog-owned under a deterministic semantic key");
check("AFDI excluded entities", afdiObserver.includes('artifactKey == "jyggalag"') && afdiObserver.includes('SetEntry(28, 0x000F54, "necromancer_amulet")'), "Jyggalag remains classify-only while the Necromancer's Amulet remains explicit data");
for (const relative of ["PDV_Patch_AFDI.esp", "Seq/PDV_Patch_AFDI.seq", "Scripts/PDV_AFDIObserver.pex"]) {
  check(`AFDI package ${relative}`, fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "adapters", "afdi", ...relative.split("/"))).size > 0, "conditional patch artifact is present in the AFDI adapter option");
}

const packageRoot = at("dist", "PDV_QuestModPatches_FOMOD");
const moduleXml = read("dist", "PDV_QuestModPatches_FOMOD", "fomod", "ModuleConfig.xml");
const packageFiles = fs.readdirSync(packageRoot, { recursive: true }).map((item) => String(item).replace(/\\\\/g, "/"));
check("V3 required catalog once", packageFiles.filter((file) => file.endsWith("PDV_QuestReactionPatches.v2.json")).length === 1, "the consolidated data-only catalog is installed exactly once");
check("V3 five adapter options", (moduleXml.match(/<plugin name=/g) || []).length === 5, "only the five mechanism adapters are selectable");
check("V3 no channel payloads", !packageFiles.some((file) => file.includes("Channels") || file.includes("QuestStageAdapters")), "data-only sources do not ship one channel or stage-selector JSON each");

const shrine = read("dist", "PDV_QuestModPatches_FOMOD", "adapters", "daedric-shrines-aio", "SKSE", "Plugins", "BaseObjectSwapper", "PDV_DaedricShrinesAIO_SWAP.ini");
const shrineRules = shrine.split(/\r?\n/).map((line) => line.trim()).filter((line) => line && !line.startsWith(";") && line.includes("|"));
check("Shrine swap map", shrineRules.length === 11 && shrineRules.every((line) => line.includes("PDV_Patch_DaedricShrinesAIO.esp")) && !shrine.includes("Authoria"), `${shrineRules.length} neutral prayer-activator mappings are packaged; QASmoke and Jyggalag stay absent`);
check("Neutral shrine ESP", fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "adapters", "daedric-shrines-aio", "PDV_Patch_DaedricShrinesAIO.esp")).size > 0, "eleven route-202 activators ship in the opt-in shrine option");

const result = { status: failures.length ? "FAIL" : "PASS", passes: passes.length, failures };
console.log(JSON.stringify(result, null, 2));
process.exitCode = failures.length ? 1 : 0;
