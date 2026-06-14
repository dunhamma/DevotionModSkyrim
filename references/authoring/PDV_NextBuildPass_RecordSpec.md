# PDV Next Build-Pass Record Spec (EditorIDs + Magnitudes)

**Created:** 2026-06-14
**Status:** SPEC ONLY -- no ESP write, no manager edit, no codegen this session. Records below are
the authoring target for the next ESP-record build pass (run with Skyrim closed). Rulings were made
interactively with the user 2026-06-14.
**Owner:** Companion to `PDV_PreBetaRaceScalingSpine.md` (which now points here for magnitudes) and
the per-race `race-sheets/PDV_RaceDesign_*.md`. Grounding came from those LOCKED race docs + the
2026-06-10 manager backup; sibling EditorIDs cited per record.

## How to read this / build rules

- **Idempotency (HARD):** every magnitude here goes into the ESP/manager BY HAND. Do NOT run any
  cumulative/additive rebalance tool to apply these -- those tools double values on a 2nd write
  (see `rebalance-tool-idempotency`). Hand-enter, then verify with `--check`.
- EditorID conventions used: tracks `PDV_<Name>Track` (script `PDV_ReputationTrack`; methods
  `Adjust(adj,reason)`/`GetValue()`/`GetStateLabel()`/`RefreshState()`; deity wires via
  `GainModifyingTrack`/`DecayModifyingTrack`); spells `PDV_SPEL_*` / `PDV_Bless_<Race>_<X>_T<n>`;
  messages `PDV_Msg_<Race>_*`; notifs `PDV_Notif_<Race>_*`; getters `Get<Race><Thing>Modifier`.
- Pacing frame for every magnitude: per-deity cap 4.3/day, GAIN_RATE_SCALE 1.32, tiers
  Seeker25/Devoted50/Champion85, PIETY_MAX 200, ~30-45 days normal play to Champion.
- "exists" = found in the manager backup / framework ESP; "new" = to author.

---

## 1. Altmer -- ThalmorAlignment track  [USER OVERRIDE of locked doc]

**RULING (user, 2026-06-14):** use the **Imperial Concordat mirror: -100..+100, 5-state**, NOT the
0-100 / 3-band shape written in `PDV_RaceDesign_Altmer.md`. The user wants the full track including a
genuine anti-Thalmor *rebel* pole and the extreme-reset stickiness. **Follow-up:** the Altmer race
doc must be reconciled to this in a later pass (NOT edited this session).

**Records:**
- `PDV_ThalmorAlignmentTrack` (new) <- mirror `PDV_ConcordatStandingTrack` (`PDV_ReputationTrack`, manager backup line 79).
- `GetAltmerLorkhanFactionModifier(Bool isEnforcementAction)` (new getter) -- returns the band multiplier; the bool distinguishes enforcement vs self-cultivation signals.

**Track shape (mirror Concordat exactly):** range -100..+100, starts 0 (Uncommitted). Positive =
Thalmor-aligned, negative = Heterodox/Defiant. Dual signal-class multipliers (self-cultivation /
enforcement), because Altmer has two signal classes where Concordat has one (Talos):

| State | Range | self-cultivation mult | enforcement mult | Lorkhan-penalty mult |
|---|---|---|---|---|
| Open Heterodox | -100..-76 | x1.5 | x0.5 | x0.75 |
| Private Heterodox | -75..-51 | x1.25 | x0.75 | x0.875 |
| Uncommitted | -50..+50 | x1.0 | x1.0 | x1.0 |
| Public Orthodox | +51..+75 | x0.75 | x1.25 | x1.25 |
| Thalmor Devout | +76..+100 | x0.5 | x1.5 | x1.5 |

`GetAltmerLorkhanFactionModifier` returns the last column (orthodoxy = stronger anti-mortal Lorkhan
rejection = larger penalty); the task's x0.75/1.0/1.5 spread is preserved across the 5 bands.
Include the Concordat extreme-reset gate (`HasExtremeResetGate`/`UnlockExtremeResetGate`).

**Point table (track Adjust values, from Altmer doc lines 72-80; positive = toward +100 Thalmor):**

| Action | Points |
|---|---|
| Arrest a Talos worshipper | +15 |
| Complete a Thalmor mission | +20 |
| Help a Thalmor prisoner escape | -15 |
| Kill a Thalmor agent | -20 |
| Read banned texts | -5 |
| Consort with Daedra | -25 |

Points are ABSOLUTE track adjustments (no band multiplier on the points themselves; band multipliers
apply only to piety gain and Lorkhan penalties).

**Emitters (built 2026-06-14, source/compile-clean):** the manager owns
`ApplyAltmerAlignmentAction(actionKey, reason)` + `GetAltmerThalmorPointsForAction` (the 6-action
point table) and `HandleAltmerAlignmentSignal` (Altmer-origin gate + per-source one-shot). Three of
the six actions are live: **read_banned_texts** (-5; The Talos Mistake `000ED04D` via the book-read
hook), **consort_with_daedra** (-25; any Daedric artifact equip via `PDV_FLST_FaucetDaedricArtifacts`),
and **kill_thalmor_agent** (-20; player kill of a `ThalmorFaction 039F26` member via
`PDV_ActionRouter.HandleStoryKillActor`, gated on `aiRelationshipRank > -2` = not a pre-set enemy, so
open kills and assassinations both count; pre-scripted enemy Thalmor at rank <= -2 are excluded).

**Open / deferred (no clean vanilla hook):** arrest_talos_worshipper (no Talos-arrest crime flag),
complete_thalmor_mission (radiant loop, no terminal stage), help_thalmor_prisoner_escape (manual
dialogue). Whether AltmerCrisis state should sync with this track.

**Route-proven 2026-06-14 (Papyrus log):** read_banned_texts -5, consort_with_daedra -25 (x2 distinct
artifacts, per-artifact one-shot held), and kill_thalmor_agent -20 each moved the track (0 -> -5 ->
-30 -> -55 -> raw -75). NOTE: the committed band label lags the raw value via the track's lock-in /
pending-transition grace, so a single signal does NOT flip the Survey state label. Full manual
beta-feel proof (Survey clarity, stack) remains separate.

---

## 2. Breton -- KnightlyVowIntegrity

**Records (all grounded in `PDV_RaceDesign_Breton.md` 52-90):**
- KnightlyVowIntegrity counter (exists; init 100 on Knight's Road, manager line ~10014). Bands:
  intact >=70, strained 30-69, broken <30 (existing labels, manager ~12032-12041).
- Creed-loss SPEL set = the 4 BC-0477 spells. **Readback update 2026-06-14:** all four records now
  exist and pass tightened `pdv-phase20-race-author --check-rewards` against
  `PDV_BretonRewardRecords.spec.json`; all ten race reward specs now pass the same
  tightened spell/effect readback after the 2026-06-14 reward refresh. This closes the
  record/copy/archetype slice only.
  **Runtime update 2026-06-14:** manager-side persistent spell application is now live:
  `VowIntegrity` in the strained band, `Excommunication` in the broken band,
  `ExposureRupture` at `WitchcraftExposure >= 100`, and Druidic fork betrayal through
  the shared helper. This is compile/readback-proven, not in-game Active Effects proof.
  - `PDV_SPEL_CreedLoss_Breton_VowIntegrity` (Block -5% + Restoration -5%) -- fires when Integrity enters STRAINED (<70).
  - `PDV_SPEL_CreedLoss_Breton_ExposureRupture` (Conjuration -8% + Illusion -8%).
  - `PDV_SPEL_CreedLoss_Breton_Excommunication` (HealRateMult -8%) -- fires at BROKEN (<30).
  - `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` (StaminaRateMult -8% + Restoration -8%) (exists).
  - `PDV_SPEL_Neglect_Breton` (HealRateMult -5%) (BC-0477 base).

**Breach decrements (exact, Breton doc 56-60):**

| Breach | Integrity delta |
|---|---|
| Join Thieves Guild | -30 |
| Join Dark Brotherhood | -40 |
| Unprovoked killing of innocents | -15 per event |
| Abandon an NPC in need mid-quest | -10 |

**Restoration (doc 62-65):** mercy/justice +5 per significant act; Stendarr shrine clean hands +10
(can lift collapse but CANNOT raise Integrity above 75); help-NPC-without-reward quest +5. Integrity
>75 requires lived conduct, never shrine-only.

**Access-suppression multipliers (doc 69-72):**

| Integrity band | All Knight's Road daily shift | Stendarr | Akatosh |
|---|---|---|---|
| Below 50 | x0.75 | x0.5 | x0.75 |
| Below 25 | x0.5 | x0.25 | x0.5 |
| At 0 | halts until restored >25 | fully withdrawn | fully withdrawn |

**Resolved 2026-06-14:** include Nightingale oath **-5** and major Daedric-quest **-10** as explicit
1.0 breaches (authentic vow-breaches the doc names; small enough not to dominate the core 4).
Creed-loss spells are **persistent-while-in-band** (matches the band-state suppression model -- the
spell is held while Integrity sits in its band, cleared on restoration above the band), NOT
once-per-crossing.
**Resolved 2026-06-14:** threshold-crossing HUD notification text now fires from the live manager when
each persistent Breton creed-loss spell first becomes active (`VowIntegrity`, `Excommunication`,
`ExposureRupture`, `DruidicForkBetrayal`). Backup:
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\breton-threshold-notices\PDV__ManagerQuest.psc.20260614-160858.bak`.
**Open:** exact breach-source quest routing for the decrements, recovery/restoration routes, and
in-game Active Effects proof for the persistent creed-loss spells.

---

## 3. Orc -- "Witnessed" variety tranche (5 beats; mirror the 5 Argonian variety levers)

Template = the proven Argonian variety set (`PDV_SPEL_ArgonianAdapt_*` 4 adaptation spells +
`PDV_SPEL_ArgonianRootedRest` bed utility). Magnitudes mirror Argonian (+5 bonuses, ~0.5-1.0 piety).

| Beat | Records (new) | Mechanic + magnitude |
|---|---|---|
| **Trial of Iron** (rite) | `PDV_SPEL_Orc_TrialOfIron_Tusk` / `_Shield` / `_Hammer` / `_Yoke` <- `PDV_SPEL_ArgonianAdapt_*` | 4-choice swap rite (1 active). Tusk +5 unarmed, Shield +5 armor rating, Hammer +5 smithing, Yoke +15 carry weight. +0.5 piety per switch, 1/day, 7-day "not yet" safe. |
| **Four Holds of the Code** (pilgrimage) | `PDV_State_OrcFourHolds` (or StorageUtil int keys) | First-arrival pulse at the 4 canonical strongholds (Dushnikh Yal, Mor Khazgur, Largashbur, Narzulbur): +1.0 piety each + mode-flavored notif; milestone on all 4. FormID-key anti-farm. |
| **The Watchers** (observation line) | `PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold` / `_City` / `_LegionExile` | Malacath rare line after qualifying conduct, cap 1/dawn. Mode-split text, unified cadence. Notif only (no piety). |
| **The Code Holds** (survival beat) | `PDV_SPEL_OrcCodeHolds` + `PDV_SPEL_OrcCodeHolds_Devoted` <- timed support spell path | **LIVE/readback-clean 2026-06-14.** On surviving combat after dropping below 20% health: regen pulse, once per combat. Observant/Faithful +2 hp/s 10s; Devoted +3 hp/s 10s + 30 stamina restore. +0.5 Malacath piety/combat. Quiet (effect only). |
| **Hearth-Held** (self-made community) | `PDV_SPEL_OrcHearthHeld` + `PDV_Notif_Orc_HearthHeld_Declare` / `_Return` / `_MissedCadence` <- Argonian `PDV_SacredPlace` bed-of-choice | Declare one cell (forge/home/workplace preferred); 3 invested returns in 30 days; wake pulse. Mirror Argonian magnitudes. |

**Pacing:** Stronghold ~3.3/day base; these beats add modest, anti-farmed piety (~0.5-1.0 each) and
do not break the 30-45-day Champion curve. Life-mode multipliers x1.00/0.75/0.60 apply post-calc.

**Record update 2026-06-14:** the first Witnessed record tranche is live/readback-clean through
`PDV_OrcRewardRecords.spec.json`: Trial of Iron Tusk/Shield/Hammer/Yoke support spells, The Watchers
mode-split MESG records, and Hearth-Held support spell + declare/return/missed-cadence MESG records
exist and are wired on `PDV__ManagerQuest`. Backup:
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-165115.bak`.
**Route/message update 2026-06-14:** Four Holds now uses the recommended StorageUtil one-shot
tracker rather than a full state enum. Route 75 is compile/verifier-clean through
`PDV_EventTypes`, `PDV_EventBus`, `PDV_EventSignalActivator`, `PDV_EventSignalEffect`,
`PDV_Deity_Malacath`, and `PDV__ManagerQuest.HandleOrcFourHoldsVisit`; the four hold notifications
plus the all-holds milestone MESG are live/readback-clean through `PDV_OrcRewardRecords.spec.json`.
Backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-165810.bak`.
Four added QASmoke ACTI/REFR proof surfaces for Dushnikh Yal, Mor Khazgur, Narzulbur, and
Largashbur are also readback-clean; proof harness backups:
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-orc\PlayerDevotion_Framework.esp.20260614-170457.bak`
and
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-proof-placements\PlayerDevotion_Framework.esp.20260614-170503.bak`.
**Open:** final-world `ChangeLocation`/placement emitters for the four strongholds,
Hearth-Held runtime cell restriction (forges+strongholds only vs any home/inn), and
Trial-of-Iron/Watchers/Hearth-Held manager behavior remain deferred. Code Holds source/record/readback
is closed, but runtime/manual proof of the combat-end survival payout remains pending. Four Holds is
source/record/QASmoke-placement readback proof only until runtime route evidence and final-world
stronghold-arrival emitters exist.

---

## 4. Redguard -- Far Shores Keep Watch tranche

**Records:**
- `PDV_Bless_Redguard_FarShoresToken` (exists, manager line 322; signal RefID `07102E` in framework
  ESP, routed via `HandleRedguardFarShoresToken` ~4163-4178; Tu'whacca backend
  `SIGNAL_FAR_SHORES_TOKEN=2403`).
- `PDV_State_RedguardSect` (exists) -- Ash'abah is a sect value within it.

**Magnitudes:**
- `DELTA_FAR_SHORES_TOKEN = 1.0` (matches Tu'whacca `DELTA_CROWN_FORM` precedent; daily anti-farm cap
  via `ConsumeDailyRepeatMultiplier`). Keeps the token a support surface, not the optimal piety path.
- **FarShoresToken condition-shape -- RULING (user): UNCONDITIONAL V1** (ResistMagic 5% anywhere,
  daily-capped, NOT a 3rd always-on boon family). Per BC-0524 ("unconditional V1") +
  RaceRewardBudgetLedger. The home/private (`IsInInterior`+`IsOwner`) and home-cell-keyword variants
  are documented POST-1.0 expansion shapes, not 1.0.
- **Ash'abah entry/exit = category-gate** (reason-string `redguard_ashabah_burden`), not numeric
  thresholds. Enumerate the burden reasons in a curated table/comment: major death, undead, tomb,
  funerary duty (per the design lock). Exit = light/heavy path requirement stays categorical.

**Resolved/clarified 2026-06-14:** V1 does not ship a separate portable inventory object or
private/home bonus for Far Shores. The live V1 surface is the `PDV.Redguard.FarShoresToken`
StorageUtil proof texture, routed by `PDV_ACTI_RedguardFarShoresTokenSignal` /
`PDV_REFR_RedguardFarShoresTokenSignal` to `HandleRedguardFarShoresToken`, and grants the
unconditional support spell `PDV_Bless_Redguard_FarShoresToken` after daily-capped token proof.

**Deferred exact-source routing:** generic vampirism cure already drives Redguard re-entry through
`ApplyRedguardCurseHandlers` and `PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry`.
Do not also treat Dawnguard cure as Ash'abah burden until an exact Dawnguard quest/stage source is
read back and added to `PDV_FLST_P2_RedguardAshAbahSources`. A final-world portable inventory object
remains a post-1.0 expansion option if the devotional token becomes a real item instead of the
current proof-surface route.

**Dawnguard-cure Ash'abah source -- readback determination (2026-06-14): DEFERRED.** DLC1VQ02
"Bloodline" was read back (stages 0/5/6/7/8/9/10/15/20/25/30/40/180/190/200) and is the Dawnguard
intro / side-CHOICE quest, NOT a vampire-cure quest -- there is no cure stage to map to an Ash'abah
death-duty burden. The generic vampire-cure already drives Redguard Tu'whacca re-entry via
`OnVampirismStateChanged` -> `ApplyRedguardCurseHandlers`. A dedicated "Dawnguard cure as Ash'abah
burden" has no clean vanilla source; if pursued later, undead-heavy Dawnguard content (Soul Cairn,
vampire-hunting) is the design candidate, not Bloodline.

---

## 5. Argonian -- Sithis T3, curse messages, DominationPressure, Hist creed-loss

**Sithis T3 "Void-Held" capstone -- RULING (user): two-part, passive bumped to 10%.**
- `PDV_Bless_Argonian_Sithis_T3` (new) <- `PDV_Bless_Argonian_Sithis_T2` (manager backup line 5310).
- `PDV_MGEF_Argonian_Sithis_T3_StaminaBurst` (new) <- `PDV_MGEF_Argonian_Sithis_T2_Sneak`.
- **Always-on passive: StaminaRateMult +10%** (Void/endurance theme; user raised from the proposed 5%
  -- 5% was too small for a Champion T3). Non-redundant with the existing post-contract +10% move /
  +15 sneak temp buff (doc line 139).
- **Near-death burst:** below 20% health, +50 stamina regen for 10s, once per day. (Doc line 139.)
- Keep the existing line-139 components: DB max standing + dialogue; post-DB-contract +10% movement /
  +15 sneak for 60s. Respects the ~12% always-on ceiling (passive small, burst is a one-off).
- **LIVE/readback-clean 2026-06-14:** `PDV_Bless_Argonian_Sithis_T3` and
  `PDV_SPEL_ArgonianSithisNearDeathBurst` are authored, wired to `PDV__ManagerQuest`, and checked by
  `tools/pdv-phase20-race-author --check-rewards`. Runtime/manual proof of the below-20% once/day burst
  remains pending.

**Curse messages (BC-0642; new MESG <- Nord `PDV_Msg_Nord_CurseState_*`, manager lines 295-297):**
`PDV_Msg_Argonian_CurseState_VampireOnset` / `_VampireCured` / `_WerewolfOnset` / `_WerewolfCured`.
Nord-structure adapted to Argonian grief (Hist silence / reconnection). Loud MessageBoxes.

**DominationPressure dispatch -- RULING: set when Molag Bal piety >= 25 (Seeker) AND
curseState == vampire** -> escalates posture to **Corrupted(4)** (in `ApplyArgonianCurseHandlers`).
Posture enum `PDV_State_ArgonianHistPosture`: Normal0/Distant1/Strained2/Silenced3/Corrupted4 (from
`PDV_ArgonianRewardRecords.spec.json`). Clean Seeker-threshold gate; avoids fragile vanilla-feed
detection. Neglect texture already exists: `PDV_MGEF_Neglect_ArgonianHist_HealRate` (HealRateMult -5)
applies at posture Silenced or Corrupted.

**Runtime update 2026-06-14:** Molag Bal is Argonian-accessible by record contract/readback (`statesByRace.Argonian = Curse`, live `PDV_DaedricPath_Molag` in `PDV_FLST_DaedricPaths_All`). The deployed manager now writes `PDV.Curse.Argonian.DominationPressure` from the existing Daedric path tier (`GetStoredTier() >= TIER_SEEKER`) while the player is Argonian + vampire, refreshes the Hist posture after Molag path piety changes, and keeps the legacy `PDV.Curse.Argonian.HistPosture` debug key synced to the substrate posture. The completeness contract row `BC-0714` was corrected from stale proposed `PDV_DaedricPath_MolagBal` to live `PDV_DaedricPath_Molag`; regenerated `pdv_completeness_audit` reports `PASS=337`, `GAP-REVIEW=77`, and `BC-0714` PASS. Proof is compile/readback only: `PDV__ManagerQuest` compile 0/0, Argonian reward-spec readback PASS, `pdv_completeness_audit` PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`. Runtime/manual proof of the Corrupted posture transition remains open.

**Hist creed-loss dispatch values -- RESOLVED 2026-06-14 (exact, from
`references/authoring/PDV_ArgonianRewardRecords.spec.json` creedViolation, target = PDV_Deity_Hist
piety / Hist substrate relation; medium/major only, no minor-tier loss):**

| id | magnitude | trigger | player text |
|---|---|---|---|
| hist-abandonment-extended | -4.0 | extended Hist neglect past the 3-day grace into posture Distant while still neglecting (medium) | "The Hist has felt your absence. Its memory of you grows thin." |
| hist-corruption-domination | -8.0 | domination pressure driving posture to Corrupted (vampire grief + domination) (major) | "Something has come between you and the Hist. The connection is fouled." |
| void-overreach-against-hist | -6.0 | leaning hard into Void/Sithis while Hist maintenance lapsed past grace (major; Void must not replace Hist) | "You reached for the Void and let the Hist slip. The marsh feels further away." |

Curse messages are **MESG** records (Nord precedent, manager 295-297), not INFO.

**Resolved in source/readback 2026-06-14:** below-20%-health detection is now hooked by the shared
combat-session poll described in section 9. Runtime/manual proof of the Argonian once/day burst
remains pending.

---

## 6. Dunmer -- werewolf Layer-2, Grey Quarter, dawn/dusk

- **Layer-2 werewolf factor (SOURCE/COMPILE CLEAN 2026-06-14):** `GetDunmerCurseLayerWeight(2)` returns **0.75x** for Good Daedra
  (Azura/Boethiah/Mephala) piety under werewolf curse (parallels the existing Layer-1 0.5x ancestor
  `GetDunmerCurseLayerWeight(1)`). Applies to the Good Daedra memory pulse from portable-shrine prayer
  and home bonus, plus Azura/Boethiah/Mephala focus signals (shrine activations, major quest
  completions). The source path now uses `AwardCuratedSignalScaled(...)` for the affected Layer-2
  awards while leaving other curated signals unscaled. Locked by `PDV_RaceDesign_Dunmer.md:273`.
  Runtime/manual proof remains pending.
- **Grey Quarter solidarity:** Layer-1 small burst **+0.75 piety** per curated act (per-NPC daily
  cooldown), curated whitelist of ~5-8 core Windhelm Dunmer NPCs/quests; plus **Mephala focus +2.0**
  at Champion for protected-secrets/community-aid.
- **Dawn/dusk twilight window (Azura):** two 3-hour windows (06:00-09:00 dawn, 18:00-21:00 dusk),
  **+0.25 piety** each, once-per-window daily cap, on portable-shrine prayer or outdoor Good-Daedra
  shrine activation inside the window. **SOURCE/COMPILE/VERIFIER CLEAN 2026-06-14 for portable prayer:** Azura now
  owns `SIGNAL_DUNMER_TWILIGHT_RITE = 704` / `DELTA_DUNMER_TWILIGHT_RITE = 0.25`; the manager checks
  the game-time fraction in `TryAwardDunmerTwilightWindowSignal(reason)` and calls it from
  `HandleDunmerPortableShrinePrayer`. Default `pdv_verify` guards the manager/Azura snippets. Outdoor
  Good Daedra shrine activation still needs an exact emitter.

**Open:** Grey Quarter NPC list hardcoded vs JSON-config; does "Windhelm Dunmer support" include
Ulfric-opposition or refugee-aid-only; whether twilight window bounds should be configurable globals vs
hardcoded; runtime/manual proof that werewolf posture scales Layer-2 Good Daedra gains to 0.75x and that
twilight awards cap once per dawn and dusk window.

**Outdoor shrine emitter (built 2026-06-14, source/compile-clean):** detection is limited to the
Dragonborn DLC2 Solstheim altars (Azura/Boethiah/Mephala, blessing spells `03BCFB`/`03BCFC`/`03BCFD`) --
the Good Daedra have no vanilla blessing-giving world shrines. `OnMagicEffectApplyEx` matches the altar
blessing spell (the three share one base effect `0FBFF5`, so the source-spell is the discriminator) and
routes `RouteDunmerOutdoorGoodDaedraShrine` -> `HandleDunmerOutdoorGoodDaedraShrine` ->
`TryAwardDunmerTwilightWindowSignal`. The Azura statue (DA01) and the Boethiah/Mephala quest shrines
are non-blessing activators (no clean hook).

---

## 7. Orc -- dawn-side everyday hooks

- **Oath-breaking -- RULING (user): `DELTA_OATH_BREAK = -1.5`** (medium-light creed violation).
  **SOURCE/COMPILE/VERIFIER CLEAN 2026-06-14:** `PDV_Deity_Malacath` now owns `SIGNAL_OATH_BREAK = 2253` and
  `DELTA_OATH_BREAK = -1.5`, with `PDV_EventTypes.EVT_ORC_OATH_BREAK = 74`,
  `PDV_EventBus.RouteOrcOathBreak(sourceId)`, manager `HandleOrcOathBreak(reason)`, and route 74
  support in both reusable signal receivers. This sits
  below the -2.0 betrayal tier and above day-to-day drift; "not large... sustained accumulates"
  (Orc doc 189). Default `pdv_verify` guards the EventTypes/EventBus/manager/Malacath/receiver snippets.
  Exact vanilla emitters remain deferred.
- **Forge / strength everyday hooks -- keep AS-IS (no new manager hooks).** The likes/dislikes faucet
  already scores these: event 330 smith-item +0.75 (2-day cd), event 2 kill-hostile-humanoid +0.25,
  event 1 kill-hostile-beast +0.25, event 301 kill-daedra +0.75. The +0.25 everyday-strength tier is
  intentionally small (combat texture, not a major piety source), forcing engagement with the full
  code (forge + community), not kill-grinding.

**Open:** which vanilla quest-abandonment/failure surface emits `RouteOrcOathBreak(...)` (feasibility
rule sec.41 defers the concrete hook). Whether City/Legion Orcs need a top-up if beta shows stalling
below 3.3/day. Runtime/manual proof remains pending because no exact emitter is live yet.

---

## 8. Imperial -- Concordat secondary modifiers + per-action point table

**Track:** `PDV_ConcordatStandingTrack` manager property points at the live record
`PDV_RepTrack_ConcordatStanding`. -100..+100, 5 states
(Open Defiant -100..-76 Talos x1.5; Private Defiant -75..-51 x1.25; Uncommitted -50..+50 x1.0; Public
Compliant +51..+75 x0.75; Concordat Enforcer +76..+100 x0.5).

**Secondary modifiers on Arkay/Stendarr (RESOLVED 2026-06-14 from Imperial doc 109-111 -- exact):**
- Compliant side, **>+50** (Public Compliant + Concordat Enforcer): **Arkay -15%** daily shift (mass
  graves / inadequate death rites enabled), **Stendarr -15%** daily shift (mercy incompatible with
  active persecution).
- Defiant side, **<-50** (Private + Open Defiant): **Stendarr +15%** daily shift (active resistance =
  merciful act); **Arkay unaffected** (death rites transcend politics).
- Note the doc triggers span BOTH bands per side (>+50 / <-50), not only the extreme state.
- Wire via explicit per-state `GainMultiplierPerTrackState` / `DecayMultiplierPerTrackState` arrays on
  `PDV_Deity_Arkay` and `PDV_Deity_Stendarr` (Khajiit-lunar precedent; parallels the Talos fallback at
  `PDV_DeityBase.psc` ~376-391). Arkay: 1.0 except 0.85 in the two compliant states. Stendarr: 1.0
  except 0.85 in the two compliant states and 1.15 in the two defiant states.
  **Readback update 2026-06-14:** `PDV_ImperialRewardRecords.spec.json` now carries
  `deityTrackModifiers` for both deities, and `tools/pdv-phase20-race-author --check-rewards`
  verifies the `GainModifyingTrack` object plus exact 5-entry float arrays. Live readback passes for
  Arkay `[1.0,1.0,1.0,0.85,0.85]` and Stendarr `[1.15,1.15,1.0,0.85,0.85]`.

**Per-action Concordat point table (RESOLVED 2026-06-14 from Imperial doc 113-122 -- exact; replaces
the current flat +/-15). Positive = toward +100 Enforcer/compliance:**

| Action | Points |
|---|---|
| Find / activate hidden Talos shrine | -15 |
| Help a Talos worshipper escape the Thalmor | -15 |
| Kill a Thalmor Justiciar (unprovoked) | -10 |
| Side with the Stormcloaks | -20 |
| Refuse to report a Talos worshipper | -5 |
| Publicly observe the Talos ban | +5 |
| Report a Talos worshipper to the Thalmor | +15 |
| Attack a Talos worshipper | +15 |

Values are designed, not placeholders -- do NOT auto-retune; validate in pre-beta and patch in 1.1 if
swings prove too punishing.
**Runtime scaffold update 2026-06-14:** the manager now exposes
`GetImperialConcordatPressureForAction(actionKey)` plus `ApplyImperialConcordatAction(actionKey,
reason)` with the exact eight-action point table. The existing hidden Talos shrine route now uses the
named `hidden_talos_shrine` key and preserves the current `-15` behavior.

**Emitter update (2026-06-14):** two of the eight actions now have live emitters.
**side_with_stormcloaks** (-20): `RouteConcordatPressure`'s defiance branch now sources its magnitude
from the point table (was a flat -15), so the proven Phase-7 CW01B fragment lands -20 without being
edited. **kill_thalmor_justiciar_unprovoked** (-10): unprovoked kill of a `ThalmorFaction 039F26`
member via `PDV_ActionRouter.HandleStoryKillActor` -> `HandleThalmorUnprovokedKill`. NOTE: the Talos
Mistake book was NOT migrated onto this track -- it routes `RouteImperialTalosPressure` (a separate
Talos-piety axis), not Concordat Standing.

**Open (no clean vanilla hook / manual-dialogue):** help_talos_worshipper_escape, refuse_report,
report_talos_worshipper (manual dialogue, no outcome flag); attack_talos_worshipper (greenfield
assault-whitelist, out of scope); public_observe_talos_ban (no discrete outcome). Signal-handler
ownership to avoid double-counting across CW/Thalmor/Legion remains a design watch-item.

**Route-proven 2026-06-14:** side_with_stormcloaks via the MCM defiance button ->
`RouteConcordatPressure complete: 21 adjustment -20` (compliance +15 confirmed unchanged). The
Altmer/Imperial Thalmor-kill share one hook. **Fix 2026-06-14:** testing showed an OPEN kill of
Ondolemar did not score -- attacking him makes him hostile, diverting the kill to the wrong
(hostile) branch -- so the gate was moved before the hostile/non-hostile split and changed to
`aiRelationshipRank > -2` (not a pre-set enemy), counting open kills and assassinations alike.
Altmer -20 and Imperial -10 BOTH route-proven (Imperial via an OPEN kill after the rank-gate fix:
`ConcordatStanding raw=-10 (thalmor_unprovoked_kill)`). The self-defense exclusion is now rank-based,
not combat-based, so `startcombat`-forced hostility still scores; only a rank <= -2 pre-flagged enemy
Thalmor is suppressed.

---

## 9. Cross-cutting build hook

The **below-20%-health** trigger is shared by Bosmer Baan Dar Gap, Orc **Code Holds** (sec.3), and
Argonian **Sithis T3** near-death burst (sec.5). **LIVE/readback-clean 2026-06-14:** `PDV_PlayerEvents`
now opens one combat-session poll for Bosmer/Khajiit/Argonian/Orc, routes the first below-20% dip through
`PDV_EventBus.RoutePlayerBelowHealthGate`, fans to `PDV__ManagerQuest.HandlePlayerBelowHealthGate`, and
routes Orc's survived-combat payout through `RoutePlayerBelowHealthSurvived` on combat exit. Khajiit
keeps its existing Baan Dar near-fatal/outnumbered session logic. Runtime/manual proof remains pending.

## 10. Status / next step

This file began as a spec-only packet, but the 2026-06-14 build pass has now promoted selected rows:
Altmer ThalmorAlignment, the first voice-conformance MESG/NOTI wave, Breton creed-loss spell wiring,
all-race reward readback hardening, and Imperial Arkay/Stendarr Concordat secondary modifiers are
live/readback-clean. Remaining rows below stay future ESP/source tranches. The Altmer track is a
deliberate user override of the locked Altmer doc and that doc still needs future reconciliation if
not already handled in the current branch.

**Open-question status (resolved 2026-06-14 offline vs genuinely deferred to the build pass):**
- RESOLVED from docs: Imperial point table (8 actions) + secondary-mod thresholds; Argonian Hist
  creed-loss triple (-4/-8/-6 with triggers + text), posture enum (Corrupted=4), curse = MESG; Breton
  Nightingale/Daedric breaches + persistent-while-in-band creed-loss; Four Holds = the 4 vanilla
  strongholds.
- RESOLVED in code/readback 2026-06-14: Molag Bal path Argonian-accessibility plus the manager
  DominationPressure writer for Argonian + vampire + Molag Seeker; shared below-20% hook plus Argonian
  Sithis T3 and Orc Code Holds support records/properties; Breton creed-loss threshold HUD notices.
- EMITTER PASS (2026-06-14, source/compile/verifier-clean): Altmer ThalmorAlignment now has live
  emitters for read_banned_texts/-5, consort_with_daedra/-25, kill_thalmor_agent/-20; Imperial Concordat
  side_with_stormcloaks now lands -20 (table-sourced through the proven CW01B path) and
  kill_thalmor_justiciar_unprovoked/-10 is live; Dunmer outdoor Good Daedra shrine prayer is live (DLC2
  Solstheim altars only). Runtime/manual proof pending for all.
- STILL DEFERRED (no clean vanilla hook / manual-dialogue / radiant-loop): Altmer arrest /
  complete_thalmor_mission / help_thalmor_prisoner_escape; Imperial help-escape / refuse-report /
  report-worshipper / attack-worshipper / public-observe; Orc oath-break (no clean quest-fail marker,
  sec.41); Dunmer Grey Quarter NPC whitelist; Redguard Dawnguard-cure-as-Ash'abah (DLC1VQ02 is a choice
  quest, not a cure -- see sec.4). Runtime/manual proof of the below-20% hook also remains.
