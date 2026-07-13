# Breton Unified Patron-Champion Model - Build Spec (2026-07-13)

**Status:** Implemented and runtime-proven 2026-07-13; integrated Hidden Art offer/toast replay remains.
Supersedes the **reward-semantics** of `PDV_BretonTwoAxis_BuildSpec_2026-07-12.md`
sections 1 (Reward semantics) and the `PDV_Bless_Breton_PatronChampion` flat-boon
design. Everything else in the two-axis spec (practice-count tiers, resonance
sets, dual-feed signal wiring) stands unchanged.

## Owner decision (2026-07-13)

The two-axis build shipped with a placeholder reward model: resonant Champion
patron -> tradition T3 family; non-resonant Champion patron -> ONE generic
`PDV_Bless_Breton_PatronChampion` = Maximum Health +10, identical for every
patron. Owner ruled this bland and inconsistent - a Dibella-champion and a
Zenithar-champion Breton got the same +10. Every deity already has a defined
top-tier Champion reward elsewhere in the mod; the Breton should get THAT.

Also confirmed at design review: the placeholder `PDV_Bless_Breton_PatronChampion`
record was declared as a manager property but **never authored in Devotion.esp**
(two broad houseCARL queries = 0 matches), so the non-resonant Champion path
currently grants nothing AND its "A patron's mark" presentation early-returns on
the None property. This build replaces that dead path entirely.

## The unified model

- **Tradition owns T1/T2 practice** (25/50 weighted practice points, capped at
  four points per in-game day). The tradition tops out at T2; it no longer
  grants a T3.
- **Patron (at Champion 85) always brings their OWN Champion boon**, resonant or
  not. The patron's identity - not the tradition - determines the reward.
- **Resonance becomes presentation only.** Resonant = "X names you Champion
  through the <lane>." Non-resonant = "X names you Champion; your patron's mark
  stands beside your practice." The resonance sets (two-axis spec section 4) are
  retained solely to pick which line fires.
- **Budget unchanged:** a distinct patron Champion boon remains beside tradition
  T2, for two always-on families at the ceiling. When the patron maps to the
  tradition's own cumulative T3 record (Stendarr, Y'ffre, or an integrated
  Hidden Art Prince), T3 replaces T2 rather than duplicating the same ActorValues.
  Hidden Art Champion therefore shows one Conjuration and one Illusion line at
  the larger Champion values, plus the Prince's distinct pact boon.

### Hidden Art integrated-pact boundary

Hidden Art remains the Breton base layer when Hircine, Hermaeus Mora, Namira,
or Nocturnal becomes the active pact. Survey and Book of Days must retain the
tradition/practice/exposure readout and append the Prince identity. The pact
keeps its own boon, while the generic Prince price and generic Prince stigma are
waived because `WitchcraftExposure` plus Vigilant pressure is this lane's sole
cost. At Notorious exposure (100), practice and T1/T2 rewards remain active and
gain for those four Prince paths is multiplied by 1.25.

The T3 record carries absolute cumulative totals. Once an integrated Prince is
Champion, `HiddenArt_T3` replaces `HiddenArt_T2`; both spells must never be live
together.

This resolves the incentive inversion the placeholder created: under the old
model a non-resonant patron would (if enriched) out-reward a resonant one;
unified makes every patron bring the same reward regardless of tradition, and
resonance is pure flavor.

## The 11 champion boons

Effects mirror each deity's canonical top-tier record EXACTLY (Imperial lane for
the Divines, Altmer for Magnus). Magnitudes are copied verbatim - no Breton
retune - so a Breton championing Mara gets the same boon an Imperial Mara
champion gets. Requiem note: several lean on RateMult regen (dead under Requiem);
we mirror as-is for cross-race parity and track Requiem conversion as a separate
global pass (see Follow-ups). Do NOT fork magnitudes here.

| Patron | Champion boon | Effects | Source | Record |
|---|---|---|---|---|
| Stendarr | Knight's Bulwark - Champion | Block +25, Magic Resist +18, Armor +50 | existing `PDV_Bless_Breton_KnightsRoad_T3` | REUSE |
| Y'ffre | Green Way - Champion | Stamina Regen +20%, Restoration +18, Health +20 | existing `PDV_Bless_Breton_GreenWay_T3` | REUSE |
| Mara | Mara's Compassion - Champion | Restoration +23, Magic Resist +15 | Imperial Mara T3 | NEW |
| Arkay | Arkay's Ward - Champion | Disease Resist +27, Health +30 | Imperial Arkay T3 | NEW |
| Akatosh | Akatosh's Endurance - Champion | Magicka Regen +20%, Magic Resist +15 | Imperial Akatosh T3 | NEW |
| Julianos | Julianos's Insight - Champion | Magicka Regen +20%, Magic Resist +15 | Imperial Julianos T3 | NEW |
| Kynareth | Kynareth's Sky - Champion | Stamina Regen +20%, Magic Resist +13 | Imperial Kynareth T3 | NEW |
| Dibella | Dibella's Inspiration - Champion | Speech +25, Magicka Regen +13% | Imperial Dibella T3 | NEW |
| Zenithar | Zenithar's Prosperity - Champion | Carry Weight +120, Speech +20 | Imperial Zenithar T3 | NEW |
| Talos | Talos's Triumph - Champion | Armor +50, One-Handed +20 | Imperial Talos T3 | NEW |
| Magnus | Magnus's Aperture - Champion | Alteration +25, Magicka Regen +15% | Altmer Magnus T3 | NEW |

New Breton-owned records use editorIds `PDV_Bless_Breton_Champion_<Deity>` and
manager properties of the same name. Names above are the player-facing
`displayName`; keep the deity's own signature name (Breton copies of Imperial
records), not a tradition-flavored one.

**Daedric Hidden Art patrons:** a Hidden Art Breton whose Champion patron is a
Daedric prince (via 20C) keeps `PDV_Bless_Breton_HiddenArt_T3` (Conjuration +27,
Illusion +21, Magicka Regen +8) as the occult-practitioner Champion boon - the
prince's own reward flows through the pact system, and this caps the
practitioner so occult Bretons are not the one group without a signature
capstone. `HiddenArt_T3` is therefore NOT retired; it becomes the champion boon
for the `deity as PDV_DaedricPathBase` case.

## Build steps

### 1. Records - `PDV_BretonRewardRecords.spec.json`

Add 9 entries to the `records[]` array (schema = the Imperial T3 record shape:
`spellEditorId`, `spellProperty`, `displayName`, `effects[]`
(`actorValue`/`magnitude`/`effectName`), `playerFacingText`, `signature`).
`emphasis` = `Champion_<Deity>`, `tier` = `Champion`. Effects verbatim from the
table. Mark the retired `PDV_Bless_Breton_PatronChampion` entry (spec line ~493)
DEPRECATED (stop granting; defer ESP record deletion, mirroring the retired
Tradition_T1/T2 handling).

### 2. Author - `pdv-phase20-race-author`

`dotnet run --project tools/pdv-phase20-race-author -- --author-rewards
--rewards-spec references/authoring/PDV_BretonRewardRecords.spec.json`.
Dry-run first (`--dry-run`), then the real write. ESP-write gate: Skyrim CLOSED,
houseCARL off Anvil (re-point to DoD for the write, back to Anvil after per
housecarl-holds-esp-lock), backup Devotion.esp first. The tool creates SPEL+MGEF
per effect (ValueModifier archetype, deterministic `GenerateMgefId`) and fills
the manager VMAD property named in `spellProperty`.

### 3. Manager - `PDV__ManagerQuest.psc`

- Declare 9 `Spell Property PDV_Bless_Breton_Champion_<Deity> Auto`.
- New `Spell Function GetBretonPatronChampionBoon(PDV_DeityBase deity, Int
  traditionValue)`:
  - Stendarr -> `PDV_Bless_Breton_KnightsRoad_T3`
  - Y'ffre -> `PDV_Bless_Breton_GreenWay_T3`
  - Mara/Arkay/Akatosh/Julianos/Kynareth/Dibella/Zenithar/Talos/Magnus ->
    the matching `_Champion_<Deity>` record
  - `deity as PDV_DaedricPathBase` -> `PDV_Bless_Breton_HiddenArt_T3`
  - else None
- `GetBretonTraditionTier` (13381): return the PRACTICE tier only (drop the
  `IsBretonResonantPatronChampion -> TIER_CHAMPION` shortcut; tradition caps at
  T2). Champion is now a patron property, not a tradition tier.
- `SyncBretonTraditionRewardFamily` (13286): grant T1/T2 ONLY. Never grant the
  T3 slot (KnightsRoad_T3 / GreenWay_T3 / HiddenArt_T3 are now patron-champion
  records owned by the new sync, so remove them from the tradition family's
  managed set to avoid the reused-spell cross-lane strip within Breton itself).
  Suppress T2 whenever the active Champion boon is this same tradition's T3,
  because the T3 magnitudes are cumulative absolute totals.
- Replace `SyncBretonPatronChampionReward` with `SyncBretonChampionBoon`: if
  `GetPatronState()==PATRON_STATE_ACTIVE && _activeDeity && GetTier(_activeDeity)
  >= TIER_CHAMPION`, grant `GetBretonPatronChampionBoon(_activeDeity,
  traditionValue)`; strip all 11 champion boons the player should not have (one
  active at a time). Reuse `SyncRaceRewardSpell`'s add/strip.
- Presentation: keep the resonant/non-resonant split from
  `MaybeShowBretonPatronChampionPresentation` / `GetBretonPatronSurveySentence`,
  but name the actual boon granted. Retire the generic PatronChampion property +
  its sync (leave the property declared but unused for save-compat, or remove -
  it was never in a save because the record never existed).
- Confirm one-active-at-a-time: on patron swap, the old champion boon strips
  (SyncRaceRewardSpell strip path), same as any race reward.

### 4. Compile + sync

`pdv_compile --script PDV__ManagerQuest` and `PDV_MCM` (0/0), sync live-source ->
MO2 (`tools/sync-devotion-to-live.ps1` + the two files it misses:
PDV_Deity_*/PDV_EventSignalActivator are already synced; confirm manager+MCM
copied), relaunch note for pex.

## Audit / gating (this session, before claiming done)

1. houseCARL ESP readback: all 9 new `PDV_Bless_Breton_Champion_*` SPEL exist,
   each with the exact effects from the table (MGEF magnitude + actorValue), and
   the 9 manager VMAD properties are filled (not None). Stendarr/Y'ffre reuse
   confirmed still present.
2. `pdv_compile` manager+MCM 0/0; `pdv_verify --json` FAIL=0 (WARN=1 medallion
   glyph allowed).
3. `pdv_reward_runtime_order_lint` - NO add-then-remove strip on any Breton
   champion boon (the tradition family must no longer manage the T3 slots, or the
   lint flags grant-then-strip).
4. Reward readback audit (`pdv_phase2_reward_readback_audit --json`) PASS with the
   new records in the Breton set.
5. Static trace: a Knight's Road Breton at practice T2 championing Dibella
   (non-resonant) resolves `GetBretonPatronChampionBoon -> Champion_Dibella`;
   a Green Way Breton championing Y'ffre (resonant) resolves `-> GreenWay_T3`;
   Zenithar (unlaned) resolves `-> Champion_Zenithar`; a Daedric Hidden Art
   patron resolves `-> HiddenArt_T3`.

## Proof boundary

Authoring + readback + compile + static-audit completed on 2026-07-13 after a
clean source-first deployment of manager, PlayerEvents, MCM, and Survey. All
four compiled 0/0; Breton audit 30/30, Prisma 92, Book of Days, Phase 2 reward
readback, and the full verifier passed with FAIL=0. Runtime/manual proof (the
champion boon appears in Active Effects, the presentation names the right boon,
patron-swap strips the old one) folds into the Breton co-test sitting - add a
card per the two-axis runbook cards, replacing the obsolete BX2 (which assumed
the tradition-T3-as-capstone model).

The 2026-07-13 Mora replay exposed two shared Daedric presentation defects. The
red `+35` toast was stale presenter copy, not Mora's live Champion boon (`+20
Alteration`) or price (`-30 Stamina`), and a redundant direct base-script VMAD
attachment could consume the controlled Champion offer hook before the concrete
Prince script. The repair contract-checks all 96 boon/price tier strings, marks
boon toasts green, dispatches offer replay through the concrete Prince script,
and removes the direct base attachment from all 16 Prince quests. Final backend
proof: compile 0/0; Breton 32/32; Prisma 95/95; toast fallback 26/26; Book of
Days 126/126; Phase 2 readback 1482/1482; verifier `PASS=3581 WARN=2 FAIL=0`.
The remaining runtime replay is limited to the authored offer, green `+20
Alteration` toast, waived price-toast silence, and concise Survey sentence.

## Requiem parity - RESOLVED 2026-07-13 (no conversion needed)

An earlier draft of this section flagged the Magicka/Stamina regen champion boons
as "Requiem-inert, convert later." That was WRONG - verified against the project's
own conversion ruling and the shipped ESP:

- The project's Requiem conversion (`PDV_RequiemRegenConversion_Plan.md`) targeted
  ONLY `HealRateMult`/`HealRate` (HEALTH regen), which Requiem drives to ~0
  (swallowed) - those became flat Fortify Health / scripted RestoreActorValue
  across all races. **None of the 11 champion boons use HealRateMult.**
- `MagickaRateMult`/`StaminaRateMult` are the project's explicit "reduced but NOT
  zeroed -> partly felt -> leave as-is, note-only" category (plan doc lines
  218-226, which names Imperial Akatosh/Dibella/Julianos/Kynareth and Breton
  GreenWay as the examples deliberately left unconverted). The 6 regen effects
  here (Akatosh/Julianos/Magnus Magicka, Kynareth/Y'ffre Stamina, Dibella Magicka)
  are all in that leave-as-is class.
- Plan-doc line 224 requires regen AVs use `PeakValueModifier`. The author tool
  did this automatically: houseCARL readback confirms `PDV_MGEF_Breton_Champion_
  Akatosh_MagickaRateMult` = PeakValueModifier, byte-matching the Imperial
  reference `PDV_MGEF_Imperial_Akatosh_T3_MagickaRateMult` = PeakValueModifier.
  Non-regen AVs (ResistMagic) correctly stayed ValueModifier.
- DamageResist armor points (Stendarr/Talos Armor +50) are **Requiem-EXEMPT**
  (plan doc lines 172/181: "DamageResist ... armor pts, Requiem-exempt, kept").
  The Y'ffre reuse GreenWay_T3 already had its HealRateMult converted to flat
  Health in the 2026-06 batch.

Conclusion: the champion boons are at EXACT Requiem parity with the reference
races - mirroring them verbatim reproduced the already-converted state. Converting
the Magicka/Stamina regen to flat here would make Breton champions DIVERGE from
(stronger under Requiem than) their Imperial counterparts, breaking parity, not
achieving it. If a future balance review decides muted regen should become a
felt secondary, that is a project-WIDE change across every race's regen reward,
not a Breton-only edit.
