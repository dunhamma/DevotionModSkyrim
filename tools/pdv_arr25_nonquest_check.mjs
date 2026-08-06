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
const kidPackage = read("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "SKSE", "Plugins", "KeywordItemDistributor", "PDV_GreenPact_KID.ini");
check("KID package parity", kidAuthority === kidPackage, "authoring authority and combined-lane bytes match");
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
for (const token of [
  "Float PDV_AFDI_NEXT_DUE = -1.0",
  "Function StartAFDIPoll()",
  "Function AFDIPollTick()",
  'String versionKey = "PDV.AFDI.BaselineVersion"',
  "Bool baselineOnly = StorageUtil.GetIntValue(None, versionKey, 0) < AFDI_BASELINE_VERSION",
  "StorageUtil.SetIntValue(None, seenKey, 1)",
  "ScheduleAFDIDeadline(AFDI_POLL_INTERVAL)",
]) {
  check(`AFDI observer ${token}`, playerEvents.includes(token), "optional-plugin polling and persistent once-only state are present");
}
const afdiIds = ["000FD4", "000FD5", "000FD6", "000FD7", "000FD8", "000FD9", "000FDA", "000FDB", "000FDC", "000FDD", "000FE7", "000FE8", "000FE9", "000FEA", "000FEB", "000FEC", "000FED", "000093", "000FDE", "000FDF", "000FE0", "000FE1", "000FE2", "000FE3", "000FD3", "000F56", "000F55", "0000D9", "000F54", "000110"];
check("AFDI exact global universe", afdiIds.every((id) => playerEvents.includes(`0x${id}`)), `${afdiIds.length} directly read latched globals are resolved`);
check("AFDI EventBus route", eventBus.includes("Function RouteAFDIArtifactDestroyed(String artifactKey, Form sourceForm)") && eventBus.includes("PDV_Manager.HandleAFDIArtifactDestroyed(artifactKey, sourceForm)"), "observer delegates through EventBus");
check("AFDI manager route", manager.includes("Function HandleAFDIArtifactDestroyed(String artifactKey, Form sourceForm)"), "manager owns semantic adjudication");
check("AFDI one surface", manager.includes("ApplyAFDIDestroyRejectApprovals") && manager.includes("FlushQuestReactionSurface()"), "each destruction batches its reactions into one surface flush");
check("AFDI Black Star exception", manager.includes('artifactKey == "black_star"') && manager.includes('"destroy_profane_artifact:black_star"'), "the profaned star does not use the benign Azura penalty");
check("AFDI excluded entities", manager.includes('artifactKey == "jyggalag"') && manager.includes('artifactKey == "necromancer_amulet"'), "Jyggalag remains classify-only and Mannimarco is not invented as a roster target");

const shrine = read("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "SKSE", "Plugins", "BaseObjectSwapper", "PDV_AuthoriaARR_ShrinePrayer_SWAP.ini");
const shrineRules = shrine.split(/\r?\n/).map((line) => line.trim()).filter((line) => line && !line.startsWith(";") && line.includes("|"));
check("ARR shrine swap map", shrineRules.length === 11 && shrineRules.every((line) => line.includes("PDV_AuthoriaARR_Compatibility.esp")), `${shrineRules.length} exact prayer-activator mappings are packaged; QASmoke and Jyggalag stay absent`);
check("ARR shrine prayer ESP", fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "PDV_AuthoriaARR_Compatibility.esp")).size > 0, "the 11 authored route-202 activators ship with the swap file");

check(
  "Packaged manager source",
  hash("live-source", "Scripts", "Source", "PDV__ManagerQuest.psc") === hash("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "Scripts", "Source", "PDV__ManagerQuest.psc"),
  "combined-lane source matches the branch authority",
);
check("Packaged manager bytecode", fs.statSync(at("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "Scripts", "PDV__ManagerQuest.pex")).size > 0, "compiled PEX is present");
for (const script of ["PDV_PlayerEvents", "PDV_EventBus"]) {
  check(
    `Packaged ${script} source`,
    hash("live-source", "Scripts", "Source", `${script}.psc`) === hash("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "Scripts", "Source", `${script}.psc`),
    "combined-lane source matches the branch authority",
  );
}
for (const script of ["PDV_PlayerEvents", "PDV_EventBus", "PDV__ManagerQuest"]) {
  check(
    `Packaged ${script} bytecode`,
    hash("generated", "arr25-nonquest-pex", `${script}.pex`) === hash("dist", "PDV_QuestModPatches_FOMOD", "plugins", "authoria", "Scripts", `${script}.pex`),
    "combined-lane PEX matches the isolated compile output",
  );
}
check(
  "TGAE PlayerEvents parity",
  hash("live-source", "Scripts", "Source", "PDV_PlayerEvents.psc") === hash("dist", "PDV_QuestModPatches_FOMOD", "common", "TGAlternativeEndings", "Scripts", "Source", "PDV_PlayerEvents.psc") &&
    hash("generated", "arr25-nonquest-pex", "PDV_PlayerEvents.pex") === hash("dist", "PDV_QuestModPatches_FOMOD", "common", "TGAlternativeEndings", "Scripts", "PDV_PlayerEvents.pex"),
  "the individual TGAE lane retains both the T16 resolver and AFDI scheduler additions",
);
for (const tranche of [13, 14, 15, 16, 17]) {
  const name = `PDV_ARR25_T${tranche}_RuntimeEvidenceLedger.json`;
  check(
    `T${tranche} tester-ledger parity`,
    hash("references", "authoring", name) === hash("dist", "PDV_QuestModPatches_FOMOD", "common", "_Runbook", "Docs", name),
    "the package carries the full assigned case sheet",
  );
}
for (const name of ["PDV_ARR25_NonQuest_RuntimeEvidenceLedger.json", "PDV_ARR25_NonQuest_Adjudication.md"]) {
  check(
    `Non-quest package doc ${name}`,
    hash("references", "authoring", name) === hash("dist", "PDV_QuestModPatches_FOMOD", "common", "_Runbook", "Docs", name),
    "the package copy matches the durable authority",
  );
}

const result = { status: failures.length ? "FAIL" : "PASS", passes: passes.length, failures };
console.log(JSON.stringify(result, null, 2));
process.exitCode = failures.length ? 1 : 0;
