#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const at = (...parts) => path.join(ROOT, ...parts);
const read = (...parts) => fs.readFileSync(at(...parts), "utf8");
const hash = (...parts) => crypto.createHash("sha256").update(fs.readFileSync(at(...parts))).digest("hex");
const failures = [];
const passes = [];
const check = (name, ok, detail) => (ok ? passes : failures).push(`${name}: ${detail}`);

const manager = read("live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
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

check("Likes/dislikes version", /LIKES_DISLIKES_VERSION\s*=\s*20\s+AutoReadOnly/.test(manager), "live branch stays at version 20 because no table row changed");
const adversary = read("tools", "pdv_deity_signal_remap_adversary_check.mjs");
check("Adversary version expectation", adversary.includes("LIKES_DISLIKES_VERSION = 20"), "the executable audit no longer expects version 16");

const playerEvents = read("live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
for (const token of ["Function BardPerformancePollTick()", "Function MarkBardTavernDay(Form tavernContext)", '"PDV.BardTavern.Day."', "GetDevotionalDayStamp()", "Bard performance blocked by per-tavern daily cap."]) {
  check(`Bard contract ${token}`, playerEvents.includes(token), "existing daily anti-farm route remains present");
}
check("Bard global decay", manager.includes('ConsumeDailyRepeatMultiplier("PDV.Signal.BardPerformance")'), "manager retains the global devotional repeat budget");

const eventBus = read("live-source", "Scripts", "Source", "PDV_EventBus.psc");
// patch-source/, not dist/. This used to read the BUILD OUTPUT as its source of truth, which
// is exactly the problem issue #41 records: for patch-only scripts the output WAS the source,
// so a dist/ wipe lost it and nothing regenerated it. The source now lives in patch-source/
// and dist/ is produced from it by tools/pdv_patch_source_deploy.mjs.
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
check("External reaction API", ["BeginExternalReactionBatch", "ApplyExternalReaction", "EndExternalReactionBatch"].every((token) => manager.includes(`Function ${token}`)), "core exposes only the neutral one-surface compatibility seam");
check("AFDI one surface", afdiObserver.includes("PDV_Manager.BeginExternalReactionBatch()") && afdiObserver.includes("PDV_Manager.EndExternalReactionBatch()"), "each destruction batches its reactions into one surface flush");
check("AFDI Black Star exception", afdiObserver.includes('artifactKey == "black_star"') && afdiObserver.includes('"destroy_profane_artifact:black_star"'), "the profaned star does not use the benign Azura penalty");
check("AFDI excluded entities", afdiObserver.includes('artifactKey == "jyggalag"') && afdiObserver.includes('artifactKey == "necromancer_amulet"'), "Jyggalag remains classify-only and Mannimarco is not invented as a roster target");
for (const relative of ["PDV_Patch_AFDI.esp", "SEQ/PDV_Patch_AFDI.seq", "Scripts/PDV_AFDIObserver.pex"]) {
  check(`AFDI package ${relative}`, fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "common", "AFDI", ...relative.split("/"))).size > 0, "conditional patch artifact is present");
}

const shrine = read("dist", "PDV_QuestModPatches_FOMOD", "common", "DaedricShrinesAIO", "SKSE", "Plugins", "BaseObjectSwapper", "PDV_DaedricShrinesAIO_SWAP.ini");
const shrineRules = shrine.split(/\r?\n/).map((line) => line.trim()).filter((line) => line && !line.startsWith(";") && line.includes("|"));
check("Shrine swap map", shrineRules.length === 11 && shrineRules.every((line) => line.includes("PDV_Patch_DaedricShrinesAIO.esp")) && !shrine.includes("Authoria"), `${shrineRules.length} neutral prayer-activator mappings are packaged; QASmoke and Jyggalag stay absent`);
check("Neutral shrine ESP", fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "common", "DaedricShrinesAIO", "PDV_Patch_DaedricShrinesAIO.esp")).size > 0, "eleven route-202 activators ship in the opt-in shrine option");

const result = { status: failures.length ? "FAIL" : "PASS", passes: passes.length, failures };
console.log(JSON.stringify(result, null, 2));
process.exitCode = failures.length ? 1 : 0;
