#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_khajiit_rebalance_audit" });

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relative) => fs.readFileSync(path.join(root, relative), "utf8");
const manager = read("live-source/Scripts/Source/PDV__ManagerQuest.psc");
const rescue = read("live-source/Scripts/Source/PDV_T3DailyLowHealthSaveEffect.psc");
const baanRescue = read("live-source/Scripts/Source/PDV_KhajiitBaanDarRescueEffect.psc");
const playerEvents = read("live-source/Scripts/Source/PDV_PlayerEvents.psc");
const portent = read("live-source/Scripts/Source/PDV_KhajiitAzurahPortentEffect.psc");
const prisma = read("native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js");
const observations = JSON.parse(read("SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_KhajiitMoonObservations.json"));
const jsonMode = process.argv.includes("--json");

let pass = 0;
let fail = 0;
const findings = [];
function check(id, condition, detail) {
  if (condition) {
    pass += 1;
    findings.push({ status: "PASS", check: id, detail: "Contract satisfied." });
    if (!jsonMode) console.log(`[PASS] ${id}`);
  } else {
    fail += 1;
    findings.push({ status: "FAIL", check: id, detail });
    if (!jsonMode) console.error(`[FAIL] ${id}: ${detail}`);
  }
}

const deityKeys = ["khenarthi", "azurah", "baandar", "rajhin", "alkosh"];
check("observations.version", observations.version === 1, "schema version must be 1");
check("observations.keys", JSON.stringify(Object.keys(observations).sort()) === JSON.stringify(["version", "shared", ...deityKeys].sort()), "only version, shared, and the five deity keys are allowed");
check("observations.shared-count", Array.isArray(observations.shared) && observations.shared.length === 6, "shared must contain exactly six entries");
for (const key of deityKeys) check(`observations.${key}-count`, Array.isArray(observations[key]) && observations[key].length === 10, `${key} must contain exactly ten entries`);
const distinct = [...observations.shared, ...deityKeys.flatMap((key) => observations[key])];
const ids = distinct.map((entry) => entry.id);
check("observations.distinct-count", distinct.length === 56, "must ship 56 distinct authored entries");
check("observations.logical-memberships", deityKeys.reduce((sum, key) => sum + observations[key].length + observations.shared.length, 0) === 80, "five 16-entry logical pools must total 80 memberships");
check("observations.unique-ids", new Set(ids).size === 56, "all resolved IDs must be globally unique");
check("observations.copy-shape", distinct.every((entry) => entry && typeof entry.id === "string" && entry.id.trim() && typeof entry.title === "string" && entry.title.trim() && typeof entry.body === "string" && entry.body.trim()), "every entry needs non-empty id/title/body");
check("observations.ascii", distinct.every((entry) => /^[\x20-\x7E]+$/.test(`${entry.id}${entry.title}${entry.body}`)), "observation copy must be printable ASCII");

check("focus.threshold", /KHAJIIT_FOCUS_THRESHOLD\s*=\s*25\.0/.test(manager) && /KHAJIIT_FOCUS_LEAD_REQUIRED\s*=\s*15\.0/.test(manager), "focus boundaries must be 25 / 15");
check("focus.piety-gate", /GetPiety\(bestDeity\)\s*<\s*25\.0/.test(manager), "candidate must have actual Seeker piety");
check("focus.update-order", /AdjustKhajiitFocusedEmphasis\([^\r\n]+False\)[\s\S]{0,160}PulseKhajiitFocusPiety\([^\r\n]+\)[\s\S]{0,120}EvaluateKhajiitFocusedEmphasis\(\)/.test(manager), "weight and piety must land before evaluation");
check("focus.retention", !/SetKhajiitFocusedEmphasis\(KHAJIIT_FOCUS_NONE,\s*"no_clear_lead"\)/.test(manager) && /oldFocus\s*!=\s*KHAJIIT_FOCUS_NONE\s*&&\s*focusValue\s*==\s*KHAJIIT_FOCUS_NONE/.test(manager), "ties and piety loss must not reset an emerged focus");
check("focus.first-popup", /FocusEmergenceAcknowledged/.test(manager) && /GetKhajiitFocusEmergenceMessage/.test(manager) && /emergenceMessage\.Show\(\)/.test(manager), "first emergence must have a once-only ceremonial MessageBox");
check("focus.grandfather", /Existing focused saves are grandfathered/.test(manager), "focused saves must be acknowledged without replaying the popup");

check("schedule.eight-slots", /phaseIndex == 1[\s\S]{0,160}KHAJIIT_FOCUS_ALKOSH[\s\S]*phaseIndex == 2[\s\S]{0,160}KHAJIIT_FOCUS_AZURAH[\s\S]*phaseIndex == 3[\s\S]{0,160}KHAJIIT_FOCUS_KHENARTHI[\s\S]*phaseIndex == 4[\s\S]{0,160}KHAJIIT_FOCUS_RAJHIN[\s\S]*phaseIndex == 5[\s\S]{0,160}KHAJIIT_FOCUS_RAJHIN[\s\S]*phaseIndex == 6[\s\S]{0,160}KHAJIIT_FOCUS_BAANDAR[\s\S]*phaseIndex == 7[\s\S]{0,160}KHAJIIT_FOCUS_KHENARTHI[\s\S]*phaseIndex == 8[\s\S]{0,160}KHAJIIT_FOCUS_AZURAH/.test(manager), "eight-slot god-strength sequence drifted");
check("observations.uniform-no-repeat", /Utility\.RandomInt\(0, 14\)/.test(manager) && /excludedPoolIndex/.test(manager) && /LastResolvedId/.test(manager), "selection must be uniform over the remaining 15 and use resolved-ID no-repeat");
check("observations.fallback", /ShowKhajiitMoonContemplationFallback/.test(manager) && /GetKhajiitMoonContemplationTitle/.test(manager), "compiled four-line pools must remain fallback");
check("observations.public-strength-copy", /in Strength -/.test(manager), "presentation must name the current god in strength");

check("resonance.keyword-perk-contract", /PDV_PERK_Khajiit_LatticeResonance/.test(manager) && /PDV_SPEL_Khajiit_LatticeResonanceMarker/.test(manager), "manager properties for the tagged perk and marker are required");
check("resonance.refresh", /RefreshKhajiitFocusedRewardForResonance/.test(manager) && /shouldResonate\s*!=\s*wasResonating/.test(manager), "constant reward must refresh only when resonance changes");
check("resonance.scheduled", /RegisterForSingleUpdateGameTime/.test(manager) && /Event OnUpdateGameTime\(\)/.test(manager) && !/RegisterForSingleUpdateGameTime\(0\./.test(manager), "god-strength boundary must use a scheduled game-time update, not polling");
check("retired.phase-spells", /retired Khajiit phase blessing/.test(manager) && /GetKhajiitPhaseBlessing\(focusValue\), False/.test(manager), "old phase spells must be removed during reconciliation");
check("retired.piety-multiplier", !/appliedAmount\s*=\s*appliedAmount\s*\*\s*GetKhajiitLunarAlignmentMultiplier/.test(manager) && !/KHAJIIT_LUNAR_ALIGNMENT_BONUS/.test(manager), "presiding-deity bonus must be absent from gain pipeline and constants");

check("portent.power-lifecycle", /SyncKhajiitPortentPower/.test(manager) && /PDV_Power_Khajiit_AzurahPortent/.test(manager), "Portent power must reconcile with Azurah Champion state");
check("portent.day-key", /PDV\.Khajiit\.AzurahPortent\.Day/.test(manager) && /GetDevotionalDay\(\) \+ 2/.test(manager), "Portent must use the 06:00 devotional day key");
check("portent.native-cast", /PDV_SPEL_Khajiit_AzurahPortentDetect\.Cast/.test(manager) && !/FindClosestActor|GetNthRef|GetNumRefs/.test(portent), "Portent must cast conditioned native detection without actor searches");
check("portent.script-gate", /TryUseKhajiitAzurahPortent/.test(portent), "lesser-power effect must route through the manager eligibility gate");

check("baan.final-guard", /!HasRuntimeEligibility\(\)/.test(rescue) && /CanExecuteKhajiitBaanDarRescue\(playerRef\)/.test(baanRescue) && /return 0\.50/.test(baanRescue), "Baan Dar rescue must defend immediately before healing and restore to 50% Health");
check("baan.manager-eligibility", /GetPlayerOriginRaceIndex\(\) != ORIGIN_KHAJIIT/.test(manager) && /GetKhajiitFocusedEmphasis\(\) != KHAJIIT_FOCUS_BAANDAR/.test(manager) && /GetTier\(PDV_BaanDar\) < TIER_CHAMPION/.test(manager) && /HasSpell\(PDV_Bless_Khajiit_BaanDar_T3\)/.test(manager), "manager must require origin, focus, Champion tier, and the correct T3");

check("prisma.payload", ["currentFocus", "godInStrength", "focusStanding", "substrateTier", "resonating"].every((token) => manager.includes(`\\\"${token}\\\"`)), "extended lunar payload fields are incomplete");
check("prisma.render", ["currentFocus", "godInStrength", "focusStanding", "resonating"].every((token) => prisma.includes(token)), "dashboard does not render the extended lunar payload");
check("sleep.start-authoritative", /PDV_LastSleepStartedOutside/.test(playerEvents) && /PDV_HasSleepStartContext/.test(playerEvents) && /!playerActor\.IsInInterior\(\)/.test(playerEvents) && /!abInterrupted && hadSleepStartContext/.test(playerEvents), "landed sleep-start classifier must remain present");

if (jsonMode) {
  console.log(JSON.stringify({ status: fail ? "FAIL" : "PASS", pass, fail, findings }, null, 2));
} else {
  console.log(`\nKhajiit rebalance audit: PASS=${pass} FAIL=${fail}`);
}
process.exitCode = fail ? 1 : 0;
