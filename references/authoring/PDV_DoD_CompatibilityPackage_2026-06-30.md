# Devotion for Diaries of Dibella -- Compatibility Setup (2026-06-30)

**Boundary:** PRE-BETA tester setup. The integration is applied and **machine-valid**
on the local DoD install (load order clean, all deps present), but it has **not yet
been runtime-smoke-tested in game.** This is not a "supported" release; in-game smoke
(below) is the gate before that claim.

Diaries of Dibella (DoD) is a public Modding Bordello list, so every DoD user has the
same plugins -- these steps are reproducible for anyone running DoD.

## What this does
Replaces DoD's **Wintersun** religion layer with **Devotion** (per-deity piety, race-aware
reactions, Book of Days). Survival / curse / bathing / temple / visual content is kept.

## Requirements (already in DoD)
SKSE64 + Address Library, PapyrusUtil, powerofthree's Papyrus Extender, SkyUI, KID, and the
**PrismaUI** framework -- all confirmed present in the DoD list. Devotion ships its own SKSE
bridge DLL inside its mod.

## Install (Mod Organizer 2)
1. **Install Devotion** -- the core mod. Use the `Devotion PreBeta .8` release:
   https://github.com/dunhamma/DevotionModSkyrim/releases/tag/prebeta-0.8
   Install the `Devotion\` folder as a mod, enable `Devotion.esp`.
2. **Disable Wintersun + its patches (20 plugins):**
   - Core (5): `Wintersun - Faiths of Skyrim`, `Hearthfires - Wintersun Shrines`,
     `Wintersun - Tweaks and Enhancements`, `Wintersun - GotT Lite Patch`,
     `Wintersun - Gallows Hall`.
   - "X - Wintersun patch" compat patches (15): `Sacrilege - Wintersun`, `DBM_Wintersun_Patch`,
     `LOTD_TCC_Wintersun`, `COTN Dawnstar - Wintersun Patch`,
     `JKs Dark Brotherhood Sanctuary - Wintersun patch`, `TOCQE - Wintersun patch`,
     `TWDQE - Wintersun patch`, `FloatingSword_TCIY_Wintersun_Patch`, `SDA Wintersun Patch`,
     `Wintersun - Mrissi Patch`, `AX ValSerano-Wintersun`, `Mannaz-Freyr-Wintersun-patch`,
     `Lux - Wintersun patch`, `Lux Orbis - Wintersun patch`, `Northern Roads - Wintersun patch`.
3. **Forward-patch `DOD - Ohmes-Raht Fix.esp`** (it masters Wintersun for one dead dialogue):
   in xEdit, open it, remove the **1 DIAL + 1 INFO** records that override
   `Wintersun - Faiths of Skyrim.esp`, then right-click the plugin -> **Clean Masters**
   (drops the now-unused Wintersun master). Ohmes-Raht piety is handled by Devotion's
   `PDV_RaceMap.json` (HalfKhajiit -> Khajiit), so the dropped Wintersun-faith bit is redundant.
   *(A pre-built stripped copy + the strip script exist in the local build if you want them.)*
4. **Re-run Synthesis and ParallaxGen** -- their outputs (`Lord's Vision - Synthesis Gameplay.esp`,
   `PG_1.esp`) mastered Wintersun and are disabled; regenerating rebuilds them Wintersun-free.
5. *(Optional)* `JOJ - Player Devotion Patch.esp` -- a Lux/MusicMerged CELL cleanup for cells that
   lose the Lux-Wintersun patches. Only needed if you notice lighting regressions in those cells.

## Smoke checklist (the gate before "supported")
- Launch with **no missing-master CTD**.
- New game / coc: origin resolves; an **Ohmes-Raht** player reads as **Khajiit** in the MCM/Survey.
- Pray at a Divine + a Daedric shrine -> Devotion prayer line, not a Wintersun one.
- One devotion action moves piety; Book of Days opens/closes.
- Dawn rollover; save/reload; check `Papyrus.0.log` clean.

## Still open (not in this package)
- In-game runtime smoke (above) -- the release gate.
- DoD-specific shrine-prayer / reward **adapter ESP** (like the ARR package's 11 shrine
  activators) if outlier DoD shrines need curation -- future work; load-order replacement is
  the current scope.

## Local integration record
Applied to `profiles/Diaries of Dibella - Lord's Vision` on 2026-06-30; backups under
`pdv-dod-backup-20260630/`. Dossier + `phase20-targets.csv` updated. 0 new missing masters
(3 pre-existing, unrelated: HalfKhajiit->RaceCompatibility, ORomance->OSA/OStim).
