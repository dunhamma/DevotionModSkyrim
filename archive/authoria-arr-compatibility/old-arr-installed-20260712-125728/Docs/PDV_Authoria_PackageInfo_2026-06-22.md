# Devotion - Authoria / ARR Package Info

Date: 2026-06-25 refresh of the 2026-06-22 friend handoff sheet.
Audience: trusted tester running a power-fantasy list on top of Authoria -
Requiem Reforged, with an existing patch workflow already in place.

This sheet is install/package info only. The full runtime smoke checklist lives
in `Docs\PDV_Phase21_ARR_SmokeRunbook.md` inside the compat archive.

This is a beta integration package. Public Authoria support is not claimed.

## What You Are Installing

Two mods, in this order:

1. **Devotion (core)** - the religion framework that replaces the Wintersun
   gameplay layer with per-deity piety, race-aware reactions, and panel/MCM
   surfaces. Bundle: `dist\PDV_FirstLook_20260625.zip`.
2. **Devotion - Authoria / ARR Compatibility** - the add-on that teaches
   Devotion about Authoria's extra theological content. Bundle:
   `dist\PDV_AuthoriaARR_Compatibility_20260625.zip`.

The outer handoff bundle is:

`dist\PDV_AuthoriaARR_TrustedTester_20260625.zip`

You also need po3 Base Object Swapper for the clickable Daedric shrines. If you
have Authoria's normal install, you already have it.

## What The Compat Add-On Does

| File | What it does |
|------|--------------|
| `PDV_AuthoriaARR_Compatibility.esp` | ESL-flagged. 11 Daedric shrine-prayer Activators: one-off +2 piety to that Prince, once per in-game day, for the `man_DaedricShrines` statues. Masters: `Skyrim.esm`, `Devotion.esp`. |
| `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini` | Base Object Swapper rule that makes the decorative Daedric statues clickable by swapping their STAT meshes to the prayer Activators. |
| `SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionMatrix_ARR.json` | Extensibility channel: 24 quest-reaction cells / 22 quest keys / 20 watched quests / 24 faucet acts across Vigilant, Glenmoril, Unslaad, Olenveld, The Forgotten City, Saints & Seducers, DAc0da, and the Ebony Blade curse. It loads automatically and silently no-ops for missing content. |

Theology stays inside the gods PDV already covers: no new pantheons, no new
Princes.

## Install

1. Install `PDV_FirstLook_20260625.zip` as a new MO2 mod. Name it `Devotion`.
2. Install `PDV_AuthoriaARR_Compatibility_20260625.zip` as a second MO2 mod.
   Name it `Devotion - Authoria ARR Compatibility`.
3. Enable both mods.
4. Disable the Archon religion family listed below.
5. Place plugins in this order:
   - `Devotion.esp` before `Requiem for the Indifferent.esp`.
   - `PDV_AuthoriaARR_Compatibility.esp` after `Devotion.esp`.
6. Re-run the Reqtificator after placement.

Expected plugin shape:

```text
... Authoria + Requiem inputs ...
Devotion.esp
PDV_AuthoriaARR_Compatibility.esp
... patches that do not master Archon ...
Requiem for the Indifferent.esp
```

## Archon Family - Disable These

PDV owns the shrine SPELs. Archon's religion layer collides with Devotion, so
disable these 15 plugins:

```text
Archon.esp
Archon - Vigilant.esp
Archon - BDS.esp
Archon - Mandra Shrines.esp
Archon - Wyrmstooth.esp
Archon - HOHQE.esp
Archon - TG Alt Endings.esp
Archon - TOCQE.esp
Archon - TWDQE.esp
Archon - Markarth Entrance and Farm Overhaul.esp
Archon - Lux Via.esp
Lux - Archon.esp
Lux - Archon - Mandra Shrines.esp
Authoria - Master Patch - Archon.esp
Authoria - Papyrus - Missing Properties - Archon Fix.esp
```

Disable the matching mod folders too where MO2 has them listed under Archon.

## What To Check In Game

- Devotion MCM/status opens.
- The `_ARR` quest matrix channel reports as loaded in Papyrus log.
- One ARR quest hook applies the expected piety.
- One Daedric statue shrine is clickable, grants +2 to the matching Prince once
  per day, and does not double-award on the same day.
- Standard shrine activation still gives disease cure only; vanilla stat
  blessings do not remain in Active Effects.

## Requirements Recap

- Authoria - Requiem Reforged base list installed and working.
- po3 Base Object Swapper.
- SKSE, PapyrusUtil, and JContainers.
- Reqtificator run after plugin placement.

## Proof Boundary

Machine/readback checks pass for packaging. Runtime smoke and Authoria
maintainer acceptance remain open, so do not describe this as public support.
