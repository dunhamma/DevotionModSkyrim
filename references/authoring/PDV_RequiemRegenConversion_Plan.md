# PDV Requiem Regen Conversion Plan

Status: DRAFT (no-deploy prep)
Created 2026-06-20
Provenance: pdv-requiem-regen-audit workflow (2026-06-20) over all 10
PDV_*RewardRecords.spec.json, PDV_Phase20_RewardRecordContracts.json,
PDV_DaedricPrinceRecordContracts.json, the three variety-manifest drafts, and the
live 2026-06-15-final-polish Scripts/Source. See memory
`requiem-proof-heal-flat-restore-not-rate`. Nothing here deploys.

## Phase 0 conversion decisions (2026-06-20, user-ruled)

Per the approved implementation plan: every always-on swallowed health-regen
reward is re-themed (NOT made a constant passive heal, which Requiem removes).
Two re-theme types:

- **Fortify Health (default)** -- change the effect to `actorValue: "Health"`
  (a plain Value-Modifier = max-HP increase; the author tool already emits this,
  NO Program.cs change). Felt under Requiem, Requiem-safe (bigger HP pool, not
  passive regen).
- **Event-driven heal-on-deed** -- for HEALING-THEMED rewards: remove the
  swallowed always-on effect from the spec and instead fire a scripted
  `RestoreActorValue("Health",x)` in Papyrus at the reward's thematic moment
  (clone the `PDV_T3DailyLowHealthSaveEffect` / Orc-stamina pattern).

**Per-reward classification:**

| Re-theme type | Rewards |
| --- | --- |
| **Event-driven heal-on-deed** | Imperial Mara T2/T3 (healing patron); Redguard Tu'whacca T2/T3 (restoration/death-rite); Dunmer substrate-High (the 11a home-prayer pulse); the two LIVE Orc Code Holds near-death pulses (already event near-death). CANDIDATE: Daedric Namira (the "sustains you" lifesteal -> consider heal-on-feed at the Daedric batch). |
| **Fortify Health (max-HP)** | Argonian (Substrate Mid/High nearWater, Hist T1/T2/Signature, People T2/T3); Khajiit BaanDar T2/T3; Bosmer LivingStory T2/T3 + BanditRoad T2/T3; Breton Tradition T1/T2 + GreenWay T3; Orc Malacath T2; Nord Shor T1/T2/T3; Imperial Civic T1/T2 + Arkay T2/T3. |

Row review MAY promote a strongly healing-themed Fortify-Health entry to
event-driven (e.g. Argonian Hist "communion", Breton GreenWay restoration) -- a
per-reward call, not blocking.

**Provisional Fortify-Health magnitudes (PROVISIONAL -- tune against Requiem's
health economy in-game):** scale flat max-HP by the old regen-% tier --
T1 (old +4-5%) -> ~+10 HP; T2 (old +6-13%) -> ~+20 HP; T3/Champion (old +15-27%)
-> ~+30 HP; signature/capstone -> ~+40 HP. Keep all co-effects (Armor/Speech/
ResistMagic/etc.) unchanged.

**Spec edit shape (applied AT author time, not now):** in the effect object,
`"actorValue": "HealRateMult"` -> `"Health"`, set the flat `magnitude`, change
`"effectName": "Health Regeneration"` -> `"Fortify Health"`, and update the
record's `playerFacingText` ("Health Regeneration +X%" -> "Maximum Health +N").
For event-driven entries, DELETE the swallowed effect from the spec (the heal
moves to Papyrus).

**Readback-sync rule:** do NOT edit a canonical spec until its ESP author run is
in the same batch -- a spec/ESP mismatch turns `pdv_phase2_reward_readback_audit`
red. The conversions ride the gated author batches (free-now Imperial/Dunmer;
deferred passed-race batch).


## Build progress

- **Imperial free-now: DONE + verified 2026-06-20.** Civic T1 (+10) / Civic T2
  (+20) / Arkay T2 (+20) / Arkay T3 (+30) -> Fortify Health (max-HP). Mara T2/T3
  HealRateMult removed; heal re-themed to event-driven `HandleImperialMaraSleepMercy`
  (flat RestoreActorValue on rest, once/day, Devoted 25 / Champion 40). Manager
  compile 0/0; reward readback PASS=1284 FAIL=1 (only the pre-existing unrelated
  GreenPact KID). ESP backups under Backups/phase20-race-rewards/. Magnitudes
  PROVISIONAL (tune in-game under Requiem).
- **Dunmer free-now: DONE + verified 2026-06-20.** Auto-declare ancestor-home
  (`HandleDunmerSleepEvents`, first interior bed-cell, `PDV.DunHome.DeclaredFormID`)
  + `IsPlayerAtDunmerDeclaredHome` gate on `HandleDunmerPortableShrinePrayer` ->
  reuses `HandleDunmerPlayerHomeBonus` (now with a flat `RestoreActorValue("Health")`
  pulse, tier 15/30). Substrate Mid `MagickaRateMult` + High `MagickaRateMult`/`HealRateMult`
  removed (ResistMagic kept); compile 0/0; author PASS; readback 1284/1. Prompted-MESG
  + move-home deferred post-V1 (houseCARL writes patches not Devotion.esp; needs CK).
- (superseded) Dunmer scoped notes (live manager `PDV__ManagerQuest.psc`,
  ~14.6k lines; line numbers are POST the Mara insert, re-grep before editing):
  - KEY REUSE: `HandleDunmerPlayerHomeBonus` (~line 3766) already does the
    home-bonus substrate progress (`RecordPlayerHomeBonusScaled`, anti-farm key
    `PDV.Signal.DunmerHomeBonus`) but is ONLY called from the MCM (~line 9022),
    never from gameplay. Build = WIRE it, not write new logic.
  - (1) Add a flat `playerRef.RestoreActorValue("Health", x)` pulse inside
    `HandleDunmerPlayerHomeBonus` (tier-scaled via `PDV_DunmerAncestorSubstrate.GetSubstrateTier()`).
  - (2) New `IsPlayerAtDunmerDeclaredHome()` = current cell FormID == StorageUtil
    `PDV.DunHome.DeclaredFormID`. Call it from `HandleDunmerPortableShrinePrayer`
    (~line 3744) -> if at home, `HandleDunmerPlayerHomeBonus(reason + "_home")`.
  - (3) Declaration: clone `TryArgonianBedOfChoiceSleep` (line 2580) into
    `TryDunmerHomeDeclarationSleep` (keys `PDV.DunHome.DeclaredFormID/DeclaredDay/DeclineDay`);
    dispatch via a new `HandleDunmerSleepEvents` added to `HandlePlayerSleepStop`
    (the Imperial-Mara branch is already there as the template; ORIGIN_DUNMER=5).
    Prompt = a new `PDV_MESG_DunmerMarkHome` MESG (clone `PDV_MESG_ArgonianMarkBed`
    via houseCARL), referenced by `Game.GetFormFromFile(<localFormId>, "Devotion.esp") as Message`
    -- this AVOIDS the VMAD manager-property wiring the Argonian one uses.
  - (4) Spec: remove the homeOrShrineOnly swallowed regen effect(s) from the
    Dunmer `substrateBoons` slots in `PDV_DunmerRewardRecords.spec.json` (keep
    always-on ResistMagic), then `--author-rewards` Dunmer.
  - (5) `pdv_compile --script PDV__ManagerQuest` (0/0) + readback.
- **Passed-race batch: 5 of 7 DONE + verified 2026-06-20.** Argonian (7 effects),
  Khajiit (BaanDar T2/T3), Bosmer (LivingStory/BanditRoad T2/T3), Breton
  (Tradition T1/T2, GreenWay T3), Orc (Malacath T2) -> Fortify Health (max-HP,
  tier 10/20/30). 20 effects converted via scratch/requiem_convert.mjs (+ Argonian
  text fix); all authored PASS; reward readback PASS=1284 FAIL=1 (only the
  pre-existing GreenPact KID). Khajiit BaanDar T3 cheat-death save preserved
  (`preserveAdditionalEffects`). Backups under Backups/phase20-race-rewards/.
- **Nord: DEFERRED (capstone-save blocker).** The Nord Shor T3 "Sovngarde Looks
  Back" cheat-death save (`PDV_T3DailyLowHealthSaveEffect`) script rides ON the
  Shor T3 `HealRateMult` MGEF (attached by the capstone-signatures CK-command-packet
  process, not the reward author). Converting that effect to a new Health MGEF
  drops the save-carrying MGEF, and `preserveAdditionalEffects` does NOT protect a
  replaced SPEC'd effect (it only keeps EXTRA effects -- which is why BaanDar T3,
  whose save is on an extra effect, survived). To convert Nord later: author Nord,
  then re-run the capstone-signature save attachment (CK packet,
  tools/creation-authoring/) to re-attach `PDV_T3DailyLowHealthSaveEffect` to a
  surviving Shor T3 MGEF. Low cost to defer: Nord's real heal IS the save (works);
  only the sole-effect Shor T1 (+5% dead regen) loses a felt conversion.
- **Orc Code Holds health half: DONE in live source (spec synced 2026-06-23).**
  `TryOrcCodeHolds` (live `PDV__ManagerQuest.psc` ~3932) does a flat scripted
  `RestoreActorValue("Health", ...)` near-death pulse: Seeker Health 40 (health
  only); Devoted/Champion Health 60 + Stamina 30. The old `HealRate` regen MGEF
  (`PDV_MGEF_OrcCodeHolds_HealRate` 2 / `_Devoted_HealRate` 3, 10s) is NOT cast;
  the two spell records are gating-presence flags only. NOTE: the health half is
  its OWN ladder (40/60), not a 1:1 mirror of the stamina 30, and Seeker is
  health-only. `PDV_OrcRewardRecords.spec.json` updated to match (effect shape =
  scripted flat restore; dead regen magnitudes removed). Magnitudes PROVISIONAL
  (in-game HP-bar proof pending). Doc/spec sync only -- no `.psc` change this pass.
- **Still PENDING (Papyrus feature-builds + cross-race):** Redguard
  Tu'whacca T2/T3 event-driven heals; HoonDing make-way rebuild (6a); Ash'abah
  stigma (6b); Breton "Vigilant attention" nod (7); Daedric Namira boon.

## The problem

Requiem drives the BASE passive health-regen rate to ~0, so a `HealRateMult`
(or `HealRate`) reward buff is +% of ~0 = NOT FELT. A grep for `actorValue:
"Health"` (a flat Value-Modifier + Recover restore) across all 10 reward specs +
both contract files returns **ZERO**. So **every authored PDV "Health
Regeneration" reward is swallowed under Requiem** -- ~30 effects, nearly every
race. The ONLY Requiem-proof health restore in the runtime is
`PDV_T3DailyLowHealthSaveEffect.psc:88` (scripted `RestoreActorValue("Health",x)`
HoT, the shared cheat-death save wired to Nord Shor "Sovngarde Looks Back").
**That is the conversion reference pattern.**

The fix per effect: re-author as a flat Restore-Health -- a Value-Modifier magic
effect on the `Health` AV WITH the Recover flag (timed HoT), or a scripted
`RestoreActorValue("Health",x)` pulse. Felt identically in vanilla and Requiem,
no load-order detection.

## Conversions (positive rewards) -- ~30 effects

Magnitudes below are the CURRENT swallowed rate values; the flat-restore
magnitude is a row-review job (a regen % does not map 1:1 to HP/sec). All on
passed races re-open that race's stackSnapshot manual proof.

### Deferred races -- FREE now (stack proof already open; fold into the pending pass)

| Race | Record | Cur AV / mag | Notes |
|---|---|---|---|
| Imperial | Civic_T1 "The Divines' Regard - Seeker" | HealRateMult +4 | SOLE effect; player's FIRST reward, zero felt value today |
| Imperial | Civic_T2 | HealRateMult +7 | co-effect ResistDisease +10 kept |
| Imperial | Mara_T2 "Mara's Mercy" | HealRateMult +7 | Mara = healing patron; Restoration +13 kept |
| Imperial | Mara_T3 "Mara's Compassion" | HealRateMult +19 | STRONGEST candidate; "strongest healing-rate" headline fully swallowed |
| Imperial | Arkay_T2 / Arkay_T3 | HealRateMult +7 / +17 | ResistDisease co-effects kept |
| Dunmer | Substrate_High "Ancestor Attunement" | HealRateMult +5 (homeOrShrineOnly) | ALIGN to the home-prayer pulse conversion already in flight |

### Passed races -- BATCH into the deferred build, re-prove 7 stacks in one sweep

Priority order: sole-effect tiers -> capstones -> mid tiers.

| Race | Record | Cur AV / mag | Guardrail |
|---|---|---|---|
| Breton | Tradition_T1 "Footing - Seeker" | HealRateMult +4 | SOLE effect -> broad-Seeker reward invisible today |
| Nord | Shor_T1 "Shor's Favor - Seeker" | HealRateMult +5 | SOLE effect -> whole T1 dead today |
| Argonian | Hist_T1 "Communion - Faithful" | HealRateMult +5 | SOLE effect -> whole reward dead today |
| Argonian | Hist_Signature "Hist-Sworn" | HealRateMult +23 | largest swallowed buff in Argonian spec (marquee capstone) |
| Nord | Shor_T3 "Shor's Hall" | HealRateMult +27 | KEEP the scripted "Sovngarde Looks Back" cheat-death save (already FLAT_RESTORE_OK); preserve Effects ordering |
| Khajiit | BaanDar_T3 "Baan Dar's Luck" | HealRateMult +25 | preserveAdditionalEffects:true -> T3 save at non-zero Effects index (Effects[0] blind-spot); preserve ordering |
| Khajiit | BaanDar_T2 "Baan Dar's Guile" | HealRateMult +10 | DamageResist +30 (armor pts, Requiem-exempt) kept |
| Redguard | Tuwhacca_T3 "Far Shores" | HealRateMult +25 | capstone promises "strongest restoration"; revisit R8 ceiling prose (T2 15/T3 30) after convert |
| Redguard | Tuwhacca_T2 "Ward" | HealRateMult +10 | death-duty/restoration lane -> real heal thematically apt |
| Bosmer | LivingStory_T3 / BanditRoad_T3 | HealRateMult +25 each | co-effects (Speech/Armor/Sneak/Magicka) kept |
| Bosmer | LivingStory_T2 / BanditRoad_T2 | HealRateMult +10 each | co-effects kept |
| Argonian | Substrate_Mid / Substrate_High | HealRateMult +6 / +15 (nearWaterOnly) | keep nearWater condition |
| Argonian | People_T2 / People_T3 | HealRateMult +5 / +13 | CarryWeight/ResistPoison/ResistMagic co-effects already felt |
| Breton | Tradition_T2 / GreenWay_T3 | HealRateMult +6 / +10 | co-effects kept |
| Nord | Shor_T2 | HealRateMult +15 | OneHanded +8 kept |
| Orc | Malacath_T2 | HealRateMult +8 | DamageResist +30 (Requiem-exempt) kept |
| **Orc** | **Code Holds + Code Holds Devoted** | **was HealRate 2.0 / 3.0, 10s near-death pulse** | **DONE (live source + spec, 2026-06-23). Flat scripted `RestoreActorValue` in `TryOrcCodeHolds`: Seeker Health 40 (health only); Devoted/Champion Health 60 + Stamina 30. Old HealRate MGEF not cast; spells are gating flags. In-game HP-bar proof pending.** |

### Daedric -- sequence with the Daedric batch

| Record | Cur AV / mag | Notes |
|---|---|---|
| Namira boon Seeker/Devoted/Champion | HealRateMult +10/+15/+20 | highest-magnitude swallowed positive buff; "Namira sustains you" lifesteal fantasy unfelt; re-open Daedric stack once |

### Unauthored variety drafts -- author flat-restore FIRST (never ship swallowed)

| Record | Planned AV | Action |
|---|---|---|
| Redguard `Remember_Rest` (Tu'whacca) | HealRate +5% PROVISIONAL | author as flat Restore-Health; resolve AV before authoring; sync race sheet + manifest |
| Khajiit `Alkosh Long Breath` | HealRateMult or MagickaRateMult UNDECIDED | decide at ledger review with Requiem in mind; if Health, flat-restore |

## Do NOT convert (penalties + misreads)

- **Penalties** (swallowed but converting to a restore would be wrong): neglect
  HealRateMult debuffs (Argonian "Hist Distant" -5, Imperial "Divines Grow
  Distant" -5, Breton "Tradition Grows Distant" -5), Breton excommunication
  "Cast Out" -8, Daedric Vaermina regen-price. Leave note-only, or re-author as a
  FELT penalty (flat negative on a felt stat / scripted HP drain) only if the
  bite matters. Leaving as-is avoids passed-race re-test.
- **Stamina pulses that read like heals (do not mis-convert):** Argonian Sithis
  "Void-Held Surge" near-death capstone and the Code Holds Stamina half are
  STAMINA regen, not HP restores. If a survival HEAL was the intent that is a
  SEPARATE design gap (would need a flat Health HoT), not a conversion. (Update
  2026-06-23: for Code Holds that gap is now filled -- a flat `RestoreActorValue`
  Health pulse exists in `TryOrcCodeHolds` alongside the stamina half; see Build
  progress. The stamina half itself is still stamina and still must not be
  converted. Argonian Sithis remains stamina-only.)
- **Orc HearthHeld mismatch:** race sheet says "small health-regen pulse" but the
  shipped record is StaminaRateMult +5. If row review restores the HEALTH intent,
  it becomes a swallowed-health case needing flat-restore; as shipped (Stamina),
  note-only.

## Magicka / Stamina regen -- CONVERTED 2026-07-13 (was "leave as-is")

**SUPERSEDED:** the owner overrode the note-only ruling on 2026-07-13. All
positive `MagickaRateMult`/`StaminaRateMult` reward effects (+ 2 Argonian
HealRateMult survivors, the Daedric boons/prices, the regen penalties, and the
Argonian near-death burst) were converted project-wide to flat Fortify max-pool /
felt negatives. Authority: `PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`.
Original note-only rationale retained below for provenance:

All `MagickaRateMult`/`StaminaRateMult` reward effects are REDUCED but NOT zeroed
by Requiem -> partly felt, note-only. Includes Altmer's whole magicka-regen
identity (Auri-El/Magnus/Xarxes/Orthodox), Imperial Akatosh/Dibella/Julianos/
Kynareth, Nord Kyne/Tsun, Dunmer Azura, Breton GreenWay, Khajiit Khenarthi/Azurah,
Daedric Sheo/Hircine boons. Use PeakValueModifier where any are re-authored.
Optional balance review only (e.g. whether the Auri-El/Azura capstones want a
non-regen secondary if Requiem mutes regen heavily) -- not a swallow fix.

## Sequencing (load-bearing)

1. **Free now:** convert Imperial (Civic/Mara/Arkay) + Dunmer substrate-High
   during the pending Imperial/Dunmer test pass -- stacks already open, no extra
   re-test. Align Dunmer to the home-prayer pulse conversion.
2. **Batch the passed races:** fold ALL passed-race conversions
   (Argonian/Khajiit/Bosmer/Redguard/Breton/Orc/Nord, incl. the two live Orc Code
   Holds) into the single deferred build batch, then re-run stackSnapshot manual
   proof for the 7 affected races in ONE sweep. Do not trickle in.
3. **Daedric Namira** with the Daedric batch.
4. **Guardrails:** preserve Effects ordering on records with scripted saves
   (Khajiit BaanDar T3, Nord Shor T3); PeakValueModifier for any regen AVs left in
   place; revisit Redguard R8 ceiling prose after Tu'whacca convert.
5. **Penalties** stay note-only unless a felt-penalty re-author is wanted.
6. **Variety drafts** authored flat-restore-first.

## Proof-boundary note

The reward readback gate (1280/0) is GREEN and stays green -- it proves records
EXIST, not that they are felt under Requiem. "Felt" is manual/runtime proof under
an actual Requiem list (HP bar moves). That is why this whole class slipped past
the machine gate and why each conversion needs a fresh stackSnapshot read.
