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

### !!! CRITICAL: a genuinely FRESH game, or nothing works !!!
`PDV__ManagerQuest` is a persistent Start-Game-Enabled quest: its script AND VMAD
properties **bake into the save at first init and are never re-read** (the
deity-stance-wiring lesson). This mod swaps that script and adds THREE new manager
properties (`PDV_HircineDeity`, `PDV_GLO_PatronMoodBand`, `PDV_FLST_DemandGreatBeasts`)
plus a new `PDV_Deity_Hircine` quest and a 33-entry `PDV_FLST_AllDeities` override.
On ANY save that already initialized Devotion, the game keeps the OLD script + OLD
VMAD and **none of the LD-P1 engine runs** -- it silently behaves like the mod is off.

- Exit fully to the **main menu** (loading a save mid-session is NOT enough).
- With the mod enabled, **start a brand-new game** or `coc qasmoke` from the main
  menu. **Never Continue / load an existing character.**
- Failure signature of a stale save: "Run dawn pass" gives only "Your devotions
  settle with the dawn", no mood/demand/band-cross toasts, `GetGlobalValue
  PDV_GLO_PatronMoodBand` stuck at 1. Decisive check: `Papyrus.0.log` should
  contain `Mood band cross` after a dawn (that string exists only in the new script).

### Steps
1. In MO2 (Anvil): F5 refresh, enable mod **Devotion - Living Deities Test**
   (place AFTER Devotion -> higher priority so its scripts win), tick plugin
   `PDV_LivingDeitiesTest.esp`. Make sure the **mood teaser mod is DISABLED**
   (the two conflict; never both on).
2. Fresh game / `coc qasmoke` per the critical box above.
3. `set PDV_GLO_DebugLevel to 2` for the `[PDV]` trace markers.
4. Drive the checks from **MCM -> PlayerDevotion -> Debug** (see MOOD_TEASER.md
   for the button-by-button harness: Selected deity, Debug patron override,
   Apply target scratch, Run dawn pass; read back via `GetGlobalValue
   PDV_GLO_PatronMoodBand`). For the curse checks use **Debug force curse
   werewolf** + **Hircine** debug options.

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
