# Devotion - DoD Early Tester Bundle

Status: early tester package; runtime smoke and public support are pending.
Date: 2026-06-15.

This bundle is for trusted early testers using Diaries of Dibella / Bordello
profiles. It replaces the Wintersun religion gameplay layer with Devotion and
adds the first DoD extensibility slice: Ohmes-Raht / Half-Khajiit maps to the
Khajiit devotion origin.

Do not install this on a main save first. Copy the MO2 profile, test on a
disposable save, and keep the original generated outputs backed up.

## Bundle Contents

- `Mod\PDV_DoD_BordelloPatch_v0_20260615.zip`
  - This is the MO2-ready mod to install.
- `Docs\PDV_Phase21_DoD_PackageInstall.md`
  - Full install guide.
- `Docs\PDV_Phase21_DoD_AuthorHandoff.md`
  - Technical handoff and proof boundary.
- `Docs\PDV_Phase21_DoD_AuthoriaReuseAudit.md`
  - Notes on shared Authoria / DoD surfaces and deferred adapters.
- `Docs\PDV_Phase21_DoD_CompatibilityPackage.manifest.json`
  - Machine-readable package status.

## Install Into MO2

1. Copy your DoD MO2 profile before changing anything.
2. In MO2, install `Mod\PDV_DoD_BordelloPatch_v0_20260615.zip` as a new mod.
3. Name the MO2 mod `Devotion - Bordello Patch`.
4. Enable the mod.
5. Enable `Devotion.esp`.
6. Place `Devotion.esp` at the former `Wintersun - Faiths of Skyrim.esp` plugin
   slot.
7. Keep `Devotion.esp` before Synthesis, ParallaxGen, DynDOLOD, and other
   generated output plugins.
8. There is no separate `PDV_DoD_Compatibility.esp` in this package.

Expected plugin shape:

```text
[Wintersun removed]
Devotion.esp
... normal list patches that do not master Wintersun ...
new Synthesis output
new ParallaxGen output
new DynDOLOD output
```

## Disable Wintersun Plugins

Disable these plugins before rebuilding generated outputs:

```text
Wintersun - Faiths of Skyrim.esp
Hearthfires - Wintersun Shrines.esp
Wintersun - Tweaks and Enhancements.esp
Wintersun - GotT Lite Patch.esp
Wintersun - Gallows Hall.esp
Sacrilege - Wintersun.esp
DBM_Wintersun_Patch.esp
LOTD_TCC_Wintersun.esp
COTN Dawnstar - Wintersun Patch.esp
JKs Dark Brotherhood Sanctuary - Wintersun patch.esp
TOCQE - Wintersun patch.esp
TWDQE - Wintersun patch.esp
FloatingSword_TCIY_Wintersun_Patch.esp
SDA Wintersun Patch.esp
Wintersun - Mrissi Patch.esp
AX ValSerano-Wintersun.esp
Mannaz-Freyr-Wintersun-patch.esp
Lux Orbis - Wintersun patch.esp
Lux - Wintersun patch.esp
Northern Roads - Wintersun patch.esp
```

Disable matching Wintersun mod folders where present, especially:

```text
Wintersun - Faiths of Skyrim
Wintersun - Faiths of Skyrim - Settings Loader
Wintersun - Tweaks and Enhancements
Wintersun Textures Reborn
Hearthfire - Craftable Wintersun Shrines
Sacrilege - Wintersun
Wintersun - Gallows Hall
Wintersun - Ghosts of the Tribunal
Wintersun - M'rissi's Tails of Troubles Patch
The Whispering Door - Quest Expansion - Wintersun patch
The Only Cure - Quest Expansion - Wintersun patch
Patch for Mannaz - Freyr - Wintersun
```

## Rebuild Generated Outputs

Do not keep generated plugins that still master Wintersun. The local DoD proof
profile found stale Wintersun masters in:

```text
DynDOLOD.esp
Lord's Vision - Synthesis Gameplay.esp
PG_1.esp
```

Recommended rebuild order:

1. Run Synthesis through MO2 with Wintersun disabled and `Devotion.esp` enabled.
2. Run ParallaxGen through MO2.
3. Run TexGen if the list's DynDOLOD workflow normally requires it.
4. Run DynDOLOD through MO2.
5. Enable the regenerated output mods.
6. Confirm MO2 reports no missing masters.

For a private smoke test only, you can temporarily disable stale generated
outputs instead of rebuilding them. That avoids a missing-master crash, but it
does not prove the final generated-output setup.

## What This Package Includes

- `Devotion.esp`
- Compiled `Scripts\*.pex`
- `Seq\Devotion.seq`
- `SKSE\Plugins\KeywordItemDistributor\PDV_GreenPact_KID.ini`
- `SKSE\Plugins\StorageUtilData\PlayerDevotion\*.json`
- `SKSE\Plugins\DevotionPrismaBridge.dll`
- Package docs

Ohmes-Raht / Half-Khajiit support is data-only:

```json
{
  "raceForms": [
    "0x03322B|HalfKhajiit.esp",
    "0x05693A|HalfKhajiit.esp"
  ],
  "raceIndices": [
    6,
    6
  ]
}
```

This maps normal and vampire HalfKhajiit races to Khajiit origin index `6`
without adding `HalfKhajiit.esp` as a master to `Devotion.esp`.

## Smoke Test

Use a disposable save.

1. Start the game and confirm no missing masters or startup crash.
2. Open the Devotion MCM/status surface.
3. On an Ohmes-Raht / Half-Khajiit character, confirm `PDV_GLO_OriginRace == 6`
   and no Imperial custom-race fallback diagnostic appears.
4. If safely reachable, repeat the origin check for vampire Ohmes-Raht.
5. Activate representative Divine, Talos, Nocturnal, and Auriel shrines.
6. Confirm disease cure remains and vanilla shrine stat boons do not remain in
   Active Effects.
7. As Dunmer, test the Solstheim Azura/Boethiah/Mephala altar route during a
   dawn or dusk window.
8. Enter Dibellan Baths and Crimson Corner to confirm the list's location
   content still loads normally.
9. In Dibellan Baths, activate the standard Dibella shrine marker and confirm it
   behaves like the normalized Dibella shrine.
10. Treat the Sybil shrine marker as observation-only for this package. Record
    whether its list-authored blessing still appears, but do not count that as a
    failure until a Sybil adapter is explicitly approved.
11. Trigger one non-shrine devotion action.
12. Run a dawn tick.
13. Save, reload, and recheck status/MCM.
14. Check `Papyrus.0.log` for new `[PDV]` errors.

## What To Report Back

- Whether MO2 shows any missing masters after generated outputs are rebuilt.
- Whether the Ohmes-Raht origin check resolves to `6`.
- Whether MCM/status opens and reads sensibly.
- Which shrines were tested and what Active Effects remained.
- Whether Dibellan Baths, Crimson Corner, and the Sybil marker loaded normally.
- Any new `[PDV]` Papyrus log errors.

## Support Boundary

This is not a public support release. It is a friend/tester package for
runtime smoke and feedback. Public support still requires a rebuilt DoD profile,
runtime smoke evidence, and current list-author or public-list evidence.
