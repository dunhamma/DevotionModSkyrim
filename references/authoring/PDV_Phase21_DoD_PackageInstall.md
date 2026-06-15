# PDV Phase 21 - DoD Bordello Patch Install Guide

Status: shareable package guide; runtime smoke and list-author acceptance
pending.
Date: 2026-06-15.

This package replaces Wintersun gameplay in Diaries of Dibella / Bordello-list
profiles with Devotion. It does not include regenerated Synthesis, ParallaxGen,
TexGen, or DynDOLOD output. Those outputs are list-local and must be rebuilt by
the user after Wintersun is removed.

## Package

Install:

`PDV_DoD_BordelloPatch_v0_20260615.zip`

The archive is MO2-ready. The game-data files are at archive root:

- `Devotion.esp`
- `Scripts\*.pex`
- `Seq\Devotion.seq`
- `SKSE\Plugins\KeywordItemDistributor\PDV_GreenPact_KID.ini`
- `SKSE\Plugins\StorageUtilData\PlayerDevotion\*.json`
- `SKSE\Plugins\DevotionPrismaBridge.dll`
- `Docs\*`

No `PDV_DoD_Compatibility.esp` is included. Local readback showed the proven
shrine-replacement slice is already handled by `Devotion.esp` after Wintersun
is removed. Ohmes-Raht / Half-Khajiit origin support ships as data only in
`SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json`; it maps
`0x03322B|HalfKhajiit.esp` and `0x05693A|HalfKhajiit.esp` to Khajiit origin
index `6` without adding `HalfKhajiit.esp` as a Devotion master.

The package also includes the Authoria reuse audit:

`Docs\PDV_Phase21_DoD_AuthoriaReuseAudit.md`

That audit records candidate future adapters for the Dibellan Baths Sybil
blessing, Heart of Dibella QE, Caught Red Handed QE, and Talos' Tease. The
Ohmes-Raht / Half-Khajiit origin mapping is the first shipped extensibility
slice in this zip; the other candidates remain unshipped.

## Install Order

1. Copy the target MO2 profile before editing it.
2. Install `PDV_DoD_BordelloPatch_v0_20260615.zip` as a new MO2 mod.
3. Name the MO2 mod `Devotion - Bordello Patch`.
4. Enable the mod and enable `Devotion.esp`.
5. Place `Devotion.esp` at the former `Wintersun - Faiths of Skyrim.esp` slot,
   before Synthesis, ParallaxGen, DynDOLOD, and other generated output plugins.
6. Disable the Wintersun plugins listed below.
7. Disable or remove the old generated output mods for Synthesis, ParallaxGen,
   and DynDOLOD until they are regenerated.
8. Rebuild generated outputs from the edited profile.
9. Confirm MO2 reports no missing masters.
10. Smoke test on a disposable save.

## Wintersun Plugins To Disable

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

## Generated Outputs

Do not ship or reuse generated outputs that still master Wintersun.

The local DoD proof profile showed these active generated plugins still had
stale Wintersun masters after Wintersun was removed:

```text
DynDOLOD.esp
Lord's Vision - Synthesis Gameplay.esp
PG_1.esp
```

For a public or reusable package, rebuild them instead of cleaning their
headers by hand.

Recommended rebuild order:

1. Run Synthesis from MO2 using the list's existing Synthesis settings.
2. Run ParallaxGen from MO2 using the list's existing output target.
3. Run TexGen if the list's DynDOLOD workflow normally requires it.
4. Run DynDOLOD from MO2 using the list's existing DynDOLOD settings.
5. Enable the new Synthesis, ParallaxGen, TexGen, and DynDOLOD output mods.
6. Confirm the generated output plugins no longer master:

```text
Wintersun - Faiths of Skyrim.esp
DBM_Wintersun_Patch.esp
```

For a quick private smoke test only, you can temporarily disable the stale
generated plugins instead of rebuilding them. That avoids the missing-master
crash but reduces visual/generated patch coverage.

## Load Placement

Keep the package in this shape:

```text
[Wintersun removed]
Devotion.esp
... normal list patches that do not master Wintersun ...
new Synthesis output
new ParallaxGen output
new DynDOLOD output
```

Do not keep Wintersun active beside Devotion unless a future targeted
Wintersun shrine-asset adapter exists. The current package replaces Wintersun
gameplay rather than syncing to its runtime systems.

## Smoke Test

Use a disposable save.

1. Start the game and confirm no missing masters or startup crash.
2. Open the Devotion MCM/status surface.
3. On an Ohmes-Raht / Half-Khajiit character, confirm `PDV_GLO_OriginRace`
   resolves to `6`, the status surface treats the character as Khajiit, and the
   custom-race Imperial fallback diagnostic does not appear.
4. If safely reachable, repeat the origin check for vampire Ohmes-Raht.
5. Activate representative Divine, Talos, Nocturnal, and Auriel shrines.
6. Confirm disease cure remains.
7. Confirm vanilla shrine stat boons do not remain in Active Effects.
8. As Dunmer, test the Solstheim Azura/Boethiah/Mephala altar route during a
   dawn or dusk window.
9. Enter Dibellan Baths and Crimson Corner.
10. In Dibellan Baths, activate the standard Dibella shrine marker and confirm it
   behaves like the normalized Dibella shrine.
11. Treat the Sybil shrine marker as observation-only for this package: record
   whether its list-authored blessing still appears, but do not count that as a
   package failure until a Sybil adapter is explicitly approved.
12. Trigger one non-shrine devotion action.
13. Run a dawn tick.
14. Save, reload, and recheck status/MCM.
15. Check `Papyrus.0.log` for new `[PDV]` errors.

## Support Boundary

This is a compatibility package for testing and list-author review. It is not a
public support claim until a rebuilt DoD profile passes runtime smoke and the
generated-output rebuild has no Wintersun master warnings.
