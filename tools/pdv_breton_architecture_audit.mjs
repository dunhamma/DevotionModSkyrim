#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relative) => fs.readFileSync(path.join(ROOT, relative), "utf8");
const readJson = (relative) => JSON.parse(read(relative));

function functionBody(source, name) {
  const match = new RegExp(`(?:Bool |Int |Float |String |Spell |PDV_[A-Za-z0-9_]+ )?Function ${name}\\b`).exec(source);
  if (!match) return "";
  const end = source.indexOf("\nEndFunction", match.index);
  return source.slice(match.index, end < 0 ? source.length : end + 12);
}

const manager = read("live-source/Scripts/Source/PDV__ManagerQuest.psc");
const mcm = read("live-source/Scripts/Source/PDV_MCM.psc");
const daedricBase = read("live-source/Scripts/Source/PDV_DaedricPathBase.psc");
const sync = read("tools/sync-devotion-to-live.ps1");
const spec = readJson("references/authoring/PDV_BretonRewardRecords.spec.json");
const raceSheet = read("race-sheets/PDV_RaceDesign_Breton.md");

const failures = [];
const checks = [];
function assert(name, condition, detail) {
  checks.push(name);
  if (!condition) failures.push({ name, detail });
}

const surveyDispatch = functionBody(manager, "GetSurveyDevotionText");
const survey = functionBody(manager, "GetBretonSurveyText");
const patronSurvey = functionBody(manager, "GetBretonPatronSurveySentence");
const bookPath = functionBody(manager, "GetBretonBookOfDaysPathStatusLabel");
const rewardSync = functionBody(manager, "SyncBretonRewards");
const familySync = functionBody(manager, "SyncBretonTraditionRewardFamily");
const championSync = functionBody(manager, "SyncBretonChampionBoonExclusive");
const championMap = functionBody(manager, "GetBretonPatronChampionBoon");
const debugTradition = functionBody(manager, "DebugSetBretonTradition");
const initialChoice = functionBody(manager, "ApplyBretonInitialChoice");
const practiceAward = functionBody(manager, "AwardBretonPracticePulse");
const daedricMultiplier = functionBody(manager, "GetDaedricStigmaGainMultiplier");
const priceSync = functionBody(daedricBase, "SyncDaedricContractToTier");
const priceWaiver = functionBody(daedricBase, "ShouldWaivePriceForPlayer");
const stigmaAward = functionBody(daedricBase, "AddStigma");
const stigmaWaiver = functionBody(daedricBase, "ShouldWaiveStigmaForPlayer");
const integratedPact = functionBody(daedricBase, "IsBretonHiddenArtIntegratedPact");
const makeActivePact = functionBody(daedricBase, "MakeActiveDaedricPact");
const priceApply = functionBody(daedricBase, "AddPriceSpellPreservingCurrentPools");
const panelNote = functionBody(manager, "GetPanelPatronNote");

assert("three explicit traditions", manager.includes("BRETON_TRADITION_KNIGHTS_ROAD = 0") && manager.includes("BRETON_TRADITION_HIDDEN_ART = 1") && manager.includes("BRETON_TRADITION_GREEN_WAY = 2"), "Breton must retain three explicit tradition values.");
assert("practice pacing contract", manager.includes("BRETON_PRACTICE_SEEKER_POINTS = 25") && manager.includes("BRETON_PRACTICE_DEVOTED_POINTS = 50") && manager.includes("BRETON_PRACTICE_DAILY_MAX_POINTS = 4"), "Practice must remain 25/50 with a four-point daily cap.");
assert("survey preserves race layer under pact", surveyDispatch.indexOf("originRace == ORIGIN_BRETON") >= 0 && surveyDispatch.indexOf("originRace == ORIGIN_BRETON") < surveyDispatch.indexOf("if pactPath"), "Breton Survey must compose its tradition layer before the global Prince-wins fallback.");
assert("survey covers all traditions", ["Knight's Road", "Hidden Art", "Green Way"].every((label) => survey.includes(label)) && survey.includes("GetBretonPatronSurveySentence"), "Survey must retain every tradition base and append patron/pact context.");
assert("hidden art survey names pact", patronSurvey.includes("GetActiveDaedricPactPath") && patronSurvey.includes("Your pact with "), "Hidden Art Survey must append the active Prince without replacing the tradition.");
assert("book path composes tradition and pact", bookPath.includes("traditionLabel") && bookPath.includes("activePact") && bookPath.includes(' + " / " + '), "Book of Days path status must name both Breton tradition and active pact.");
assert("retired generic rewards strip", rewardSync.includes("PDV_Bless_Breton_Tradition_T1, False") && rewardSync.includes("PDV_Bless_Breton_Tradition_T2, False"), "Retired generic Breton reward spells must be removed from migrated saves.");
assert("retired ancestor spine clears", rewardSync.includes("SyncBretonAncestorSubstrate") && functionBody(manager, "SyncBretonAncestorSubstrate").includes("ClearSubstrateBoons"), "The retired Breton ancestor spine must stay cleanup-only.");
assert("three practice families", ["KnightsRoad", "HiddenArt", "GreenWay"].every((label) => rewardSync.includes(`"${label}"`)), "All three practice reward families must be synchronized.");
assert("notorious does not revoke hidden art", !familySync.includes("WitchcraftExposure") && !practiceAward.includes('WitchcraftExposure") >= 100'), "Notorious exposure is a cost/reward posture, not a reason to disable Hidden Art practice rewards.");

const championProps = ["Mara", "Arkay", "Akatosh", "Julianos", "Kynareth", "Dibella", "Zenithar", "Talos", "Magnus"];
assert("all champion records declared", championProps.every((name) => manager.includes(`Spell Property PDV_Bless_Breton_Champion_${name} Auto`)), "All nine copied deity Champion records must be manager properties.");
assert("all champion records exclusive", championProps.every((name) => championSync.includes(`PDV_Bless_Breton_Champion_${name}`)) && championSync.includes("PDV_Bless_Breton_KnightsRoad_T3") && championSync.includes("PDV_Bless_Breton_GreenWay_T3") && championSync.includes("PDV_Bless_Breton_HiddenArt_T3"), "Champion sync must own exactly one of all twelve possible Breton Champion boons.");
assert("champion map complete", championProps.every((name) => championMap.includes(`PDV_Bless_Breton_Champion_${name}`)) && championMap.includes("PDV_Bless_Breton_KnightsRoad_T3") && championMap.includes("PDV_Bless_Breton_GreenWay_T3") && championMap.includes("PDV_Bless_Breton_HiddenArt_T3"), "Every Breton patron class must resolve to its intended Champion boon.");
assert("generic patron mark retired", !rewardSync.includes("PDV_Bless_Breton_PatronChampion") && !championSync.includes("PDV_Bless_Breton_PatronChampion"), "The generic Patron's Mark record may remain for save compatibility but must never be granted.");

const hiddenPrinces = ["Hermaeus Mora", "Hircine", "Namira", "Nocturnal"];
assert("hidden art prince roster consistent", hiddenPrinces.every((name) => manager.includes(`pathName == "${name}"`)) && hiddenPrinces.every((name) => integratedPact.includes(`DeityName == "${name}"`)) && priceWaiver.includes("IsBretonHiddenArtIntegratedPact") && stigmaWaiver.includes("IsBretonHiddenArtIntegratedPact"), "Offer, price-waiver, and stigma-waiver rosters must contain the same four Hidden Art Princes.");
assert("hidden art price waived", priceSync.includes("ShouldWaivePriceForPlayer") && priceWaiver.includes("IsBretonHiddenArtIntegratedPact") && integratedPact.includes("RACE_BRETON") && integratedPact.includes('"PDV.Breton.Tradition"'), "The global Prince price must be waived only for a Breton walking Hidden Art with an integrated Prince.");
assert("hidden art duplicate stigma waived", stigmaAward.includes("ShouldWaiveStigmaForPlayer") && stigmaWaiver.includes("IsBretonHiddenArtIntegratedPact") && integratedPact.includes("RACE_BRETON") && integratedPact.includes('"PDV.Breton.Tradition"'), "WitchcraftExposure is the Hidden Art stigma layer; the generic per-Prince stigma must not stack.");
assert("notorious pact gain multiplier", daedricMultiplier.includes("WitchcraftExposure") && daedricMultiplier.includes("1.25") && daedricMultiplier.includes("IsBretonHiddenArtDaedricOfferDeity"), "Notorious Hidden Art must deliver its locked 1.25 pact-gain reward for the four integrated Princes.");
assert("same pact refresh idempotent", makeActivePact.indexOf("if priorPact != GetDeityForm()") >= 0 && makeActivePact.indexOf("if priorPact != GetDeityForm()") < makeActivePact.indexOf("ClearLiveDaedricPactSpells"), "Refreshing one Prince must not hard-strip and regrant the pact.");
assert("price application preserves current pools", ["Health", "Magicka", "Stamina"].every((av) => priceApply.includes(`GetActorValue("${av}")`)) && priceApply.includes("RestoreCurrentPoolIfReduced"), "A non-waived maximum-pool price must not consume the current resource bar.");

assert("debug tradition initializes state", debugTradition.includes("PDV.Breton.SetupComplete") && debugTradition.includes("SetBretonDruidicFork") && debugTradition.includes("SyncFirstTierRaceRewardRuntime") && debugTradition.includes("RequestPanelRefresh"), "The MCM tradition override must initialize the matching fork and refresh rewards/UI.");
assert("startup choice refreshes state", initialChoice.includes("SyncFirstTierRaceRewardRuntime") && initialChoice.includes("RequestPanelRefresh"), "The real startup choice must immediately reconcile rewards and public UI.");
assert("panel keeps layered hidden art note", panelNote.includes("BRETON_TRADITION_HIDDEN_ART") && panelNote.includes("Hidden Art"), "The focused panel must not describe an integrated Hidden Art pact as silencing the Breton tradition.");
assert("mcm exposes controlled Breton tools", ["Apply practice target", "Add renewable practice", "Add curated practice", "Reset Breton practice"].every((label) => mcm.includes(label)), "MCM must expose the controlled Breton practice boundary and pacing tools.");
assert("live sync includes daedric base", sync.includes("PDV_DaedricPathBase.psc"), "The guarded live sync must deploy the shared pact base changed by Breton fixes.");

const specIds = new Set((spec.emphasisRewards ?? []).map((row) => row.spellEditorId));
assert("reward spec covers live families", [
  "PDV_Bless_Breton_KnightsRoad_T1", "PDV_Bless_Breton_KnightsRoad_T2", "PDV_Bless_Breton_KnightsRoad_T3",
  "PDV_Bless_Breton_HiddenArt_T1", "PDV_Bless_Breton_HiddenArt_T2", "PDV_Bless_Breton_HiddenArt_T3",
  "PDV_Bless_Breton_GreenWay_T1", "PDV_Bless_Breton_GreenWay_T2", "PDV_Bless_Breton_GreenWay_T3",
  ...championProps.map((name) => `PDV_Bless_Breton_Champion_${name}`),
].every((id) => specIds.has(id)), "The reward spec must cover every currently grantable Breton reward family.");
assert("reward spec names current model", String(spec.status).includes("Unified Champion") && String(spec.notes).includes("25/50") && String(spec.notes).includes("save compatibility"), "The reward spec header must describe the current 25/50 unified-Champion model and retired-record boundary.");
assert("race authority owns single hidden-art cost", raceSheet.includes("global Prince price") && raceSheet.includes("sole cost") && raceSheet.includes("WitchcraftExposure"), "The race sheet must explicitly own the Hidden Art cost boundary.");

const output = { status: failures.length ? "FAIL" : "PASS", checks: checks.length, failures };
console.log(JSON.stringify(output, null, 2));
process.exit(failures.length ? 1 : 0);
