#!/usr/bin/env node
// Fail-closed contract for the owner-approved official-content ambiguity routes.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (...parts) => fs.readFileSync(path.join(repo, ...parts), "utf8");
const json = (...parts) => JSON.parse(read(...parts));
const failures = [];
let passes = 0;

function requireTrue(condition, label) {
  if (condition) {
    passes += 1;
    console.log(`[PASS] ${label}`);
  } else failures.push(label);
}

const coreCatalog = json("SKSE", "Plugins", "StorageUtilData", "PlayerDevotion", "PDV_QuestReactionCore.v2.json");

function requireAdapter(key, expected) {
  const prefix = `stageAdapter.${key}.`;
  for (const [key, value] of Object.entries(expected.string)) {
    requireTrue(coreCatalog.string?.[`${prefix}${key}`] === value, `${prefix}${key}=${value}`);
  }
  for (const [key, value] of Object.entries(expected.int)) {
    requireTrue(JSON.stringify(coreCatalog.int?.[`${prefix}${key}`]) === JSON.stringify(value), `${prefix}${key}=${JSON.stringify(value)}`);
  }
  requireTrue(coreCatalog.stringList?.stageAdapterKeys?.includes(key), `${key} is indexed in core v2`);
}

requireAdapter("Skyrim.esm|340742|200", {
  string: { selectorKind: "global", selectorPlugin: "Skyrim.esm" },
  int: { selectorFormId: 1113756, selectorValues: [0, 1], targetStages: [201, 202] },
});
requireAdapter("Skyrim.esm|340743|200", {
  string: { selectorKind: "global", selectorPlugin: "Skyrim.esm" },
  int: { selectorFormId: 270303, selectorValues: [0, 1], targetStages: [201, 202] },
});
requireAdapter("ccbgssse025-advdsgs.esm|1671799|300", {
  string: { selectorKind: "player_item_count", selectorPlugin: "ccbgssse025-advdsgs.esm" },
  int: { selectorFormId: 1588833, selectorValues: [0, 1], targetStages: [301, 302] },
});

const runtime = read("live-source", "Scripts", "Source", "PDV_QuestReactionRuntime.psc");
for (const token of [
  'selectorKind == "player_item_count"',
  "selectorPlayer.GetItemCount(selectorItem)",
  'selectorKind == "global"',
  'JsonUtil.IntListGet(adapterFile, adapterPrefix + "targetStages", valueIndex)',
]) requireTrue(runtime.includes(token), `Runtime retains adapter token ${token}`);

const router = read("live-source", "Scripts", "Source", "PDV_ActionRouter.psc");
for (const token of [
  "RouteQuestSpecificPlayerKill(victimActor)",
  "victimBaseId == 0x00075C7F",
  "Game.GetFormFromFile(0x00055977, \"Skyrim.esm\") as Quest",
  "matrixStage = 100",
  "victimBaseId == 0x00062128",
  "Game.GetFormFromFile(0x00062119, \"Skyrim.esm\") as Quest",
  "PDV_EventBusService.RouteQuestReaction(sourceQuest, matrixStage, logicalEventId)",
]) requireTrue(router.includes(token), `ActionRouter retains ${token}`);

const tagged = read("generated", "core-rows", "Official_Ambiguity_Resolutions_2026-08-12.tagged.csv");
const taggedLines = tagged.trim().split(/\r?\n/);
requireTrue(taggedLines.length === 29, "ambiguity slate contains exactly 28 outcomes");
for (const token of [
  "FreeformRiften02,The Lover's Requital,201",
  "FreeformRiften02,The Lover's Requital,202",
  "FreeformRiften03,Under the Table,201",
  "FreeformRiften03,Under the Table,202",
  "dunMidden01QST,Forgotten Names,80",
  "dunMidden01QST,Forgotten Names,100",
  "WE24,A Good Death,100",
  "DLC2RR03Intro,An Axe to Find,20",
  "DLC2RR03Intro,An Axe to Find,25",
  "DLC2SkaalVillageFreeform1,Skaal Village Dialogue,20",
  "DLC2SkaalVillageFreeform1,Skaal Village Dialogue,200",
  "ccBGSSSE025_StaadaQuest,Staada Quest,301",
  "ccBGSSSE025_StaadaQuest,Staada Quest,302",
  "ccBGSSSE025_StaadaQuest,Staada Quest,310",
  "dunRagnvaldQST,Ragnvald,30",
  "dunMossMotherQST,Moss Mother Cavern,20",
  "dunMossMotherQST,Moss Mother Cavern,100",
  "DBTortureTreasureMiscObjective1,Torture Treasure Objective 1,10",
  "DBTortureTreasureMiscObjective2,Torture Treasure Objective 2,10",
  "DBTortureTreasureMiscObjective2,Torture Treasure Objective 2,200",
  "DBTortureTreasureMiscObjective3,Torture Treasure Objective 3,10",
  "DBTortureTreasureMiscObjective3,Torture Treasure Objective 3,200",
  "CW03,Message to Whiterun,210",
  "CW03,Message to Whiterun,240",
  "BYOHHouseBanditAttack,Bandit Attack,100",
  "BYOHHouseGiantAttack,Giant Attack,10",
  "BYOHHouseWolfAttack,Wolf Attack,10",
  "BYOHHouseSkeeverInfestation,Skeever Infestation,20",
]) requireTrue(tagged.includes(token), `tagged slate retains ${token}`);

const full = read("references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
for (const token of [
  "FreeformRiften02,The Lover's Requital,201",
  "FreeformRiften02,The Lover's Requital,202",
  "FreeformRiften03,Under the Table,201",
  "FreeformRiften03,Under the Table,202",
  "dunMidden01QST,Forgotten Names,80",
  "dunMidden01QST,Forgotten Names,100",
  "WE24,A Good Death,100",
  "DLC2RR03Intro,An Axe to Find,20",
  "DLC2RR03Intro,An Axe to Find,25",
  "DLC2SkaalVillageFreeform1,Skaal Village Dialogue,20",
  "DLC2SkaalVillageFreeform1,Skaal Village Dialogue,200",
  "ccBGSSSE025_StaadaQuest,Staada Quest,301",
  "ccBGSSSE025_StaadaQuest,Staada Quest,302",
  "ccBGSSSE025_StaadaQuest,Staada Quest,310",
  "dunRagnvaldQST,Ragnvald,30",
  "dunMossMotherQST,Moss Mother Cavern,20",
  "dunMossMotherQST,Moss Mother Cavern,100",
  "DBTortureTreasureMiscObjective1,Torture Treasure Objective 1,10",
  "DBTortureTreasureMiscObjective2,Torture Treasure Objective 2,10",
  "DBTortureTreasureMiscObjective2,Torture Treasure Objective 2,200",
  "DBTortureTreasureMiscObjective3,Torture Treasure Objective 3,10",
  "DBTortureTreasureMiscObjective3,Torture Treasure Objective 3,200",
  "CW03,Message to Whiterun,210",
  "CW03,Message to Whiterun,240",
  "BYOHHouseBanditAttack,Bandit Attack,100",
  "BYOHHouseGiantAttack,Giant Attack,10",
  "BYOHHouseWolfAttack,Wolf Attack,10",
  "BYOHHouseSkeeverInfestation,Skeever Infestation,20",
]) requireTrue(full.includes(token), `compiled matrix source contains ${token}`);
requireTrue(!full.includes("RelationshipMarriage,The Bonds of Matrimony,100"), "parent marriage quest does not double-score the wedding");
requireTrue(full.includes("RelationshipMarriageWedding,Wedding Ceremony Scene,100"), "wedding quest remains the sole ceremony scorer");

const matrixAuthority = read("references", "authoring", "PDV_QuestReactionMatrix.md");
for (const token of [
  "`restore_faction_home:blades`(m)",
  "`restore_faction_home:blades`(S)",
  "`restore_faction_home:dark_brotherhood`(C)",
  "`persecute_religious_worship:*`(C)",
  "`persecute_religious_worship:*`(S)",
  "`persecute_religious_worship:talos`(C)",
  "`atonement_restitution`(S)",
  "`atonement_restitution`(C)",
  "`restore_cultural_relic`(C)",
  "`recover_stolen_divine_relic:nocturnal`(C)",
  "`resist_extortion`(S)",
  "`coercion_extortion`(S)",
  "`enthrall_enslave`(C)",
]) requireTrue(matrixAuthority.includes(token), `Part B retains corrected profile token ${token}`);

const correctionSources = [
  read("generated", "core-rows", "Skyrim_063EE7_0AB3F7.tagged.csv"),
  read("generated", "core-rows", "Skyrim_0AB3FA_10FF8F.tagged.csv"),
  read("generated", "core-rows", "Dawnguard_V03B01.tagged.csv"),
].join("\n");
for (const token of [
  "persecute_religious_worship:talos",
  "restore_faction_home:dark_brotherhood",
  "restore_faction_home:blades",
  "settle_anothers_debt,recover_lost_keepsake,civic_service",
  "recover_stolen_divine_relic:nocturnal",
]) requireTrue(correctionSources.includes(token), `tagged sources retain corrected token ${token}`);
requireTrue(!correctionSources.includes("FreeformValdDebt,Vald's Debt,200,Recovered the Quill of Gemination so Vald's debt could be discharged.,atonement_restitution"), "Vald's Debt no longer claims player atonement");

for (const token of [
  "DarkBrotherhoodSanctuaryRepair,Where You Hang Your Enemy's Head...,200,Funded the restoration of the Dawnstar Sanctuary.,restore_faction_home:dark_brotherhood,Sithis,+",
  "FreeformSkyhavenTempleA,Rebuilding the Blades,50,Rebuilt the Blades by recruiting three followers into Sky Haven Temple.,restore_faction_home:blades,Akatosh,+",
  "FreeformSkyhavenTempleA,Rebuilding the Blades,50,Rebuilt the Blades by recruiting three followers into Sky Haven Temple.,restore_faction_home:blades,Talos,+",
  "FreeformMarkarthM,Search and Seizure,200,Delivered evidence of Ogmund's Talos worship to the Thalmor.,persecute_religious_worship:talos,Stendarr,-",
  "FreeformMarkarthM,Search and Seizure,200,Delivered evidence of Ogmund's Talos worship to the Thalmor.,persecute_religious_worship:talos,Mara,-",
  "FreeformMarkarthM,Search and Seizure,200,Delivered evidence of Ogmund's Talos worship to the Thalmor.,persecute_religious_worship:talos,Talos,-",
  "FreeformMarkarthM,Search and Seizure,200,Delivered evidence of Ogmund's Talos worship to the Thalmor.,persecute_religious_worship:talos,Stuhn,-",
  "TG08B,Blindsighted,50,Recovered Nocturnal's stolen Skeleton Key from Mercer Frey.,recover_stolen_divine_relic:nocturnal,Nocturnal,+",
]) requireTrue(full.includes(token), `compiled matrix retains corrected reaction ${token}`);

const fullLines = full.split(/\r?\n/);
function requireMatrixCell(editorId, stage, tag, deity, valence) {
  const present = fullLines.some((line) => line.startsWith(`${editorId},`) && line.includes(`,${stage},`) && line.includes(`,${tag},${deity},${valence},`));
  requireTrue(present, `compiled matrix retains ${editorId} s${stage} ${tag} ${deity} ${valence}`);
}
requireMatrixCell("DBEviction", "200", "atonement_restitution", "Stendarr", "+");
requireMatrixCell("CR11", "200", "restore_cultural_relic", "Xarxes", "+");
requireMatrixCell("DLC2TT1b", "310", "resist_extortion", "Zenithar", "+");
requireMatrixCell("DLC2TT1b", "310", "resist_extortion", "Stuhn", "+");
requireMatrixCell("DLC1VQ03Vampire", "70", "enthrall_enslave", "Stendarr", "-");
requireMatrixCell("DLC1VQ03Vampire", "70", "enthrall_enslave", "Mara", "-");

const checkpoint = read("references", "vanilla-gameplay", "compatibility", "PDV_CoreQuestAuditCheckpoint.csv");
for (const editorId of [
  "FreeformRiften02", "FreeformRiften03", "dunMidden01QST", "WE24", "RelationshipMarriage",
  "DLC2RR03Intro", "DLC2SkaalVillageFreeform1", "ccBGSSSE025_StaadaQuest",
  "dunRagnvaldQST", "dunMossMotherQST", "DBTortureTreasureMiscObjective1",
  "DBTortureTreasureMiscObjective2", "DBTortureTreasureMiscObjective3", "CW03",
  "BYOHHouseBanditAttack", "BYOHHouseGiantAttack", "BYOHHouseWolfAttack",
  "BYOHHouseSkeeverInfestation",
]) {
  const row = checkpoint.split(/\r?\n/).find((line) => line.includes(`,${editorId},`)) ?? "";
  requireTrue(row.includes(",APPROVED,ok,APPROVED,"), `${editorId} checkpoint is owner-approved`);
  requireTrue(row.includes(",ok,") && row.includes("post_readback=ok"), `${editorId} checkpoint records readback proof`);
}

if (failures.length) {
  console.error(`\nFAIL: ${failures.length} ambiguity-route contract(s) failed`);
  for (const failure of failures) console.error(`  - ${failure}`);
  process.exitCode = 1;
} else console.log(`\nPASS: official ambiguity routes (${passes} checks)`);
