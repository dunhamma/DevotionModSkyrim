# LD-P1 Test ESP Setup (Devotion - Living Deities Test)

A fully self-contained, disable-able MO2 mod proving the LD-P1 Block B engine
without touching the `Devotion` mod. Authored by
`tools/pdv-living-deities-author` (`--author` to build, `--check` to readback).

## What the mod contains (machine-proven 2026-06-10: author PASS + readback PASS)
```
D:\Wabbajack\modlists\Anvil\mods\Devotion - Living Deities Test\
  PDV_LivingDeitiesTest.esp     (masters: Dawnguard.esm, Skyrim.esm, PlayerDevotion_Framework.esp)
  SEQ\PDV_LivingDeitiesTest.seq (SGE entry for PDV_Deity_Hircine, raw 0x03000806)
  Scripts\*.pex                 (the six Block B compiles - VFS-override Devotion's while enabled)
  SKSE\...\PDV_LivingDeities.json (flat JsonUtil-contract build incl. demandKey.*/eventTypesCsv)
```

ESP records:
- `PDV_Deity_Hircine` QUST - SGE, script attached, DeityName/DeityIndex(123)/
  MoodAlpha(0.22)/all stances TABOO(2)/`PDV_CurseStateService` + GLO links
  resolved from the framework's own manager VMAD.
- `PDV_GLO_PatronMoodBand` GlobalFloat (1.0 = Cool).
- `PDV_FLST_DemandGreatBeasts` - the quantified 11-race true-beast set.
- Override `PDV_FLST_AllDeities` (32 -> 33, + Hircine face).
- Override `PDV__ManagerQuest` VMAD (+PDV_HircineDeity, +PDV_GLO_PatronMoodBand,
  +PDV_FLST_DemandGreatBeasts).
- Override `PDV_Deity_Kyne` VMAD (+Boon_Seeker_Pleased/_Exalted -> TEST
  stand-in abilities `PDV_LDTEST_SPEL_KyneBoon_*`).
- `PDV_LDTEST_MGEF_ClutchSaveKyne` - constant-effect MGEF carrying
  `PDV_T3DailyLowHealthSaveEffect` with `RequiredMoodBand=2`, `DeityLabel=Kyne`,
  its own `StorageKey` (never collides with shipped capstones). Doubles as the
  Pleased band boon, so band-swap and the clutch gate are proven by one record.

## How to run the smoke (proof boundary: everything below is MANUAL proof)
1. In MO2 (Anvil): F5 refresh, enable mod **Devotion - Living Deities Test**
   (place AFTER Devotion), tick plugin `PDV_LivingDeitiesTest.esp`.
2. **NEW GAME or main-menu `coc qasmoke` only.** VMAD values bake at first
   init - an existing save will leave the three new manager properties None
   (the code guards None, so old saves simply keep shipped behavior).
3. `set PDV_GLO_DebugLevel to 2` for the `[PDV]` trace markers.

### Counted checks (from the revised 03_feasibility.md proof lists)
- Mood: seed piety (SetPQV harness / kill loop), force dawn; expect
  `PDV.Mood.*` movement, band per thresholds, decay toward 0 on no-act days,
  persistence across save/load.
- Band-cross: fires ONCE per cross (toast + notification), not per dawn.
- Demand: down-cross then dawn -> offer once; bound act -> fulfill once
  (mood +alpha*100); let one expire -> penalty once + 7d cooldown.
- Boons: at Seeker tier, Pleased cross grants `Kyne's Favor: Pleased (LD
  test)`; Exalted cross swaps to the Exalted marker with NO stacking.
- Clutch: with Pleased+ and the test boon active, drop below 10% health ->
  one heal + "Kyne steadies your failing body."; once per day; blocked when
  band < Pleased.
- Hircine face: scores 0 / silent while not werewolf; `player.setrace
  WerewolfBeastRace` (or curse via quest) -> beast kills move Hircine's
  `clampedToday`; cure -> mood zeroed, demand cleared, no path double-fire.
- Disable the mod in MO2 -> everything reverts to shipped Devotion behavior.

## Caveats
- Masters are written Dawnguard.esm before Skyrim.esm (Mutagen insertion
  order). The engine resolves masters by name so this is functionally fine;
  xEdit will note unsorted masters. Cosmetic; fix at promote time if desired.
- The Kyne band boons are TEST stand-ins, not the real Block C boon designs.
- This mod must be REBUILT (`--author`) whenever the framework ESP changes
  the overridden records (manager quest, Kyne quest, AllDeities FLST), or the
  overrides will carry stale copies of those records.
