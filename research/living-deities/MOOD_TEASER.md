# Mood Teaser (Slice A) -- "the gods notice you", V1 candidate

A minimal, self-contained mood layer extracted from the LD-P1 engine: each
deity develops a mood that drifts with your recent behavior (EWMA over the daily
`clampedToday`), sorts into four bands, and emits a once-per-day toast when an
active-pool deity's regard crosses a band ("Kyne's regard warms toward you").
NO demands, band-variant boons, dream omens, clutch save, or great-beast filter.
Additive, reversible, degrades to silence.

## Build state (machine-proven 2026-06-10, isolated -- Devotion mod untouched)
- Scripts: `research/living-deities/teaser-src/PDV_DeityBase.psc` (+`MoodAlpha`)
  and `PDV__ManagerQuest.psc` (mood subset folded into the dawn pass). Authored
  from the live baseline (byte-identical 412314) + the mood subset only.
  **Compile: 0 errors / 0 warnings** (`teaser-out/*.pex`).
- Test mod: `tools/pdv-mood-teaser-author` (`--author`/`--check`, both PASS)
  emits `D:\Wabbajack\modlists\Anvil\mods\Devotion - Living Deities - Mood Teaser`:
  `PDV_MoodTeaserTest.esp` (just the `PDV_GLO_PatronMoodBand` GlobalFloat + a VMAD
  override of `PDV__ManagerQuest` wiring that one property) + the two teaser
  `.pex`. Masters: Skyrim.esm, PlayerDevotion_Framework.esp. No JSON (the path
  degrades to property/constant defaults: alpha 0.15, bands -40/10/55); no SEQ.

## What got stripped vs the full LD-P1 engine
- `OnMoodBandCross`: removed the down-cross demand-arm and the
  `SyncPatronBoonsToBand` call (keeps only the patron mood-band mirror + toast).
- `IsDeityInActivePool`: removed the Hircine-curse branch.
- Dropped entirely: the demand engine, dream omens, `ApplyMoodDelta`,
  `GetDemandMoodSwing`, `GetStoredTierForDeity`, all boon-variant/clutch props,
  `SyncPatronBoonsToBand`/`GetBandBoonVariant`/`ClearBandBoonVariants`.
- `PlayerEvents`, `EventBus`, `T3DailyLowHealthSaveEffect`: left vanilla.

## In-game smoke (rig-side -- A3, NOT machine-provable)
MO2 (Anvil): F5, enable mod **Devotion - Living Deities - Mood Teaser** (after
Devotion), tick `PDV_MoodTeaserTest.esp`. **New game or `coc qasmoke` only**
(the manager override property bakes at first init; an existing save leaves
`PDV_GLO_PatronMoodBand` unwired -> the global stays 0 and mood still tracks,
but the mirror is inert). `set PDV_GLO_DebugLevel to 2`.
- Mood `PDV.Mood.<deity>` moves with seeded piety; persists across save/load.
- Band-cross toast fires ONCE per cross (not per dawn), pool-filtered.
- Mood decays toward 0 on no-act days.
- Disable the mod -> shipped Devotion behavior returns.

## Feel caveat (unchanged from LD-P1)
Until the 313/343 non-combat faucet is runtime-proven (main `2e665b7`), mood
moves mostly on kills. The teaser is correct regardless; it gets livelier once
that faucet breadth lands.

## V1 merge (deferred to owner, post-smoke)
Promote by copying the two teaser scripts into the live `Scripts\Source`,
compiling via `tools/pdv_compile.mjs`, and authoring `PDV_GLO_PatronMoodBand` +
the manager property into the framework ESP -- only after the in-game smoke
passes. Adds new save state (`PDV.Mood.*`), so it is a deliberate V1 scope call.
