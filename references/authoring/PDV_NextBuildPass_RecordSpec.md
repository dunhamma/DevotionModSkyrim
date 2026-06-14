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

**Open:** which vanilla quest stages/dialogue emit each of the 6 actions (signal-routing, deferred to
the build pass). Whether AltmerCrisis state should sync with this track.

---

## 2. Breton -- KnightlyVowIntegrity

**Records (all grounded in `PDV_RaceDesign_Breton.md` 52-90):**
- KnightlyVowIntegrity counter (exists; init 100 on Knight's Road, manager line ~10014). Bands:
  intact >=70, strained 30-69, broken <30 (existing labels, manager ~12032-12041).
- Creed-loss SPEL set = the 4 BC-0477 spells (confirmed needed; only `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` currently exists):
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

**Open:** Nightingale oath (-5) and major Daedric-quest (-10) as explicit 1.0 breaches or deferred
(doc mentions, not in the core 4). Whether creed-loss spells are persistent-while-in-band or
once-per-crossing (recommend persistent-while-in-band). Threshold-crossing notifications.

---

## 3. Orc -- "Witnessed" variety tranche (5 beats; mirror the 5 Argonian variety levers)

Template = the proven Argonian variety set (`PDV_SPEL_ArgonianAdapt_*` 4 adaptation spells +
`PDV_SPEL_ArgonianRootedRest` bed utility). Magnitudes mirror Argonian (+5 bonuses, ~0.5-1.0 piety).

| Beat | Records (new) | Mechanic + magnitude |
|---|---|---|
| **Trial of Iron** (rite) | `PDV_SPEL_Orc_TrialOfIron_Tusk` / `_Shield` / `_Hammer` / `_Yoke` <- `PDV_SPEL_ArgonianAdapt_*` | 4-choice swap rite (1 active). Tusk +5 unarmed, Shield +5 armor rating, Hammer +5 smithing, Yoke +15 carry weight. +0.5 piety per switch, 1/day, 7-day "not yet" safe. |
| **Four Holds of the Code** (pilgrimage) | `PDV_State_OrcFourHolds` (or StorageUtil int keys) | First-arrival pulse at the 4 canonical strongholds (Dushnikh Yal, Mor Khazgur, Largashbur, Narzulbur): +1.0 piety each + mode-flavored notif; milestone on all 4. FormID-key anti-farm. |
| **The Watchers** (observation line) | `PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold` / `_City` / `_LegionExile` | Malacath rare line after qualifying conduct, cap 1/dawn. Mode-split text, unified cadence. Notif only (no piety). |
| **The Code Holds** (survival beat) | `PDV_SPEL_OrcCodeHolds` <- `PDV_SPEL_ArgonianRootedRest` | On surviving below 20% health: regen pulse, once per combat. Observant/Faithful +2 hp/s 10s; Devoted +3 hp/s 10s + 30 stamina. +0.5 piety/combat. Quiet (effect only). |
| **Hearth-Held** (self-made community) | `PDV_SPEL_OrcHearthHeld` + `PDV_Notif_Orc_HearthHeld_Declare` / `_Return` / `_MissedCadence` <- Argonian `PDV_SacredPlace` bed-of-choice | Declare one cell (forge/home/workplace preferred); 3 invested returns in 30 days; wake pulse. Mirror Argonian magnitudes. |

**Pacing:** Stronghold ~3.3/day base; these beats add modest, anti-farmed piety (~0.5-1.0 each) and
do not break the 30-45-day Champion curve. Life-mode multipliers x1.00/0.75/0.60 apply post-calc.

**Open:** confirm no existing EditorID reservations for the new `PDV_SPEL_Orc_*`. Four Holds vehicle
(StorageUtil ints vs full state enum -- recommend StorageUtil ints, simple one-shot tracker). Code
Holds trigger event (on-first-dip-<20% vs on-combat-end-if-dipped). Hearth-Held cell restriction
(forges+strongholds only vs any home/inn).

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

**Open:** exact FormID of the portable Far Shores token *inventory object* (BC-0118; distinct from
the spell). Whether Dawnguard cure-vampire quests fire Ash'abah burden entry.

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

**Curse messages (BC-0642; new MESG <- Nord `PDV_Msg_Nord_CurseState_*`, manager lines 295-297):**
`PDV_Msg_Argonian_CurseState_VampireOnset` / `_VampireCured` / `_WerewolfOnset` / `_WerewolfCured`.
Nord-structure adapted to Argonian grief (Hist silence / reconnection). Loud MessageBoxes.

**DominationPressure dispatch -- RULING (recommended): set when Molag Bal piety >= 25 (Seeker) AND
curseState == vampire** -> escalates posture Silenced -> Corrupted (in `ApplyArgonianCurseHandlers`).
Clean threshold mirroring other races' Seeker gate; avoids fragile vanilla-feed detection.

**Hist creed-loss dispatch values -- keep as locked spec.json:** -4.0 (abandonment -> Distant; light,
soft state via passive decay), -8.0 (corruption -> vampire+Molag; heavy, deepest grief), -6.0
(intermediate). Confirm the exact triple against the reward spec.json at build time.

**Open:** is below-20%-health detection already hooked, or needs combat polling? Is Molag Bal path
Argonian-accessible (gates the DominationPressure rule)? MESG vs INFO record type (Nord uses MESG).

---

## 6. Dunmer -- werewolf Layer-2, Grey Quarter, dawn/dusk

- **Layer-2 werewolf factor:** new `GetDunmerCurseLayerWeight(2)` returning **0.75x** for Good Daedra
  (Azura/Boethiah/Mephala) piety under werewolf curse (parallels the existing Layer-1 0.5x ancestor
  `GetDunmerCurseLayerWeight(1)`, manager 9516-9526). Applies to portable-shrine prayer, home bonus,
  and Azura/Boethiah/Mephala focus signals (shrine activations, major quest completions). Locked by
  `PDV_RaceDesign_Dunmer.md:273`.
- **Grey Quarter solidarity:** Layer-1 small burst **+0.75 piety** per curated act (per-NPC daily
  cooldown), curated whitelist of ~5-8 core Windhelm Dunmer NPCs/quests; plus **Mephala focus +2.0**
  at Champion for protected-secrets/community-aid.
- **Dawn/dusk twilight window (Azura):** two 3-hour windows (06:00-09:00 dawn, 18:00-21:00 dusk),
  **+0.25 piety** each, once-per-window daily cap, on portable-shrine prayer or outdoor Good-Daedra
  shrine activation inside the window. Reuses `GetDevotionDayIndex`/dawn alignment.

**Open:** Grey Quarter NPC list hardcoded vs JSON-config; does "Windhelm Dunmer support" include
Ulfric-opposition or refugee-aid-only; dawn/dusk window bounds as configurable globals vs hardcoded.

---

## 7. Orc -- dawn-side everyday hooks

- **Oath-breaking -- RULING (user): `DELTA_OATH_BREAK = -1.5`** (medium-light creed violation). New
  `SIGNAL_OATH_BREAK` on `PDV_Deity_Malacath` <- `SIGNAL_BROKEN_FAITH_KIN` (-2.0). Below the -2.0
  betrayal tier and above day-to-day drift; "not large... sustained accumulates" (Orc doc 189).
- **Forge / strength everyday hooks -- keep AS-IS (no new manager hooks).** The likes/dislikes faucet
  already scores these: event 330 smith-item +0.75 (2-day cd), event 2 kill-hostile-humanoid +0.25,
  event 1 kill-hostile-beast +0.25, event 301 kill-daedra +0.75. The +0.25 everyday-strength tier is
  intentionally small (combat texture, not a major piety source), forcing engagement with the full
  code (forge + community), not kill-grinding.

**Open:** which vanilla quest-abandonment/failure surface emits `SIGNAL_OATH_BREAK` (feasibility rule
sec.41 defers the concrete hook). Whether City/Legion Orcs need a top-up if beta shows stalling
below 3.3/day.

---

## 8. Imperial -- Concordat secondary modifiers + per-action point table

**Track:** `PDV_ConcordatStandingTrack` (exists; race doc also calls it `PDV_RepTrack_ConcordatStanding`
-- the runtime/manager EditorID `PDV_ConcordatStandingTrack` is authoritative). -100..+100, 5 states
(Open Defiant -100..-76 Talos x1.5; Private Defiant -75..-51 x1.25; Uncommitted -50..+50 x1.0; Public
Compliant +51..+75 x0.75; Concordat Enforcer +76..+100 x0.5).

**Secondary modifiers on Arkay/Stendarr (doc line 110):**
- Concordat Enforcer (>+50): **Arkay -15%** daily shift, **Stendarr -15%** daily shift.
- Open Defiant: **Stendarr +15%** daily shift; Arkay unaffected. (From grounding; confirm the Open
  Defiant Arkay/Stendarr row against the Imperial doc at build time.)
- Wire via explicit per-state `GainMultiplierPerTrackState` / `DecayMultiplierPerTrackState` arrays on
  `PDV_Deity_Arkay` and `PDV_Deity_Stendarr` (Khajiit-lunar precedent; parallels the Talos fallback at
  `PDV_DeityBase.psc` ~376-391). Default 1.0 in the three middle states.

**Per-action Concordat point table (replace the current flat +/-15):** graduated magnitude bands
- major civic/Talos pressure: +/-15 (e.g. report a Talos worshipper +15, hidden Talos shrine -15)
- civil-war commitment: +/-20 (e.g. Stormcloak commitment -20)
- medium: +/-10
- minor: +/-5

The exact per-action assignment should be pulled from the Imperial doc's signal table at build time;
values are designed (not placeholders) -- do NOT auto-retune; validate in pre-beta and patch in 1.1 if
swings prove too punishing.

**Open:** the full per-action point mapping (doc signal table); how the 10+ Concordat actions are
wired in the manifest (reason-string matching vs a points map); signal-handler ownership to avoid
double-counting across Civil War / Thalmor / Legion domains.

---

## 9. Status / next step

These records are authored into NO ESP and NO manager this session (spec only). The next ESP-record
build pass (Skyrim closed) authors them by hand per the EditorIDs/magnitudes above, then verifies with
the relevant `--check` tools. The Altmer track is a deliberate user override of the locked Altmer doc
and that doc needs later reconciliation.
