# PDV Phase 21 - Diaries of Dibella Compatibility Handoff

Status: local package evidence; runtime and list-author acceptance pending.
Date: 2026-06-15.

This is a technical handoff for Diaries of Dibella integration testing. It is
not a public support claim and not maintainer approval.

## Package Contents

- Use the current `Devotion.esp` from the Devotion mod.
- Disable the Wintersun religion layer and direct Wintersun patches listed
  below.
- Load `Devotion.esp` at the former Wintersun core slot.
- Installable package artifact:
  `dist/PDV_DoD_BordelloPatch_v0_20260615.zip`.
- The package is MO2-ready with `Devotion.esp`, runtime `.pex` files,
  `Seq\Devotion.seq`, required `SKSE\Plugins` data, and install docs at archive
  root.
- No standalone `PDV_DoD_Compatibility.esp` is emitted for this slice. The
  reserved plugin name is for later DoD-specific route adapters if a stable
  Wintersun asset-reuse map or curated social-location hook set is approved.
- Authoria reuse audit:
  `references/authoring/PDV_Phase21_DoD_AuthoriaReuseAudit.md`. The reusable
  result is the scan/proof method and candidate backlog, not a direct copy of
  Authoria's Requiem/list-balancing ESPs.

## Wintersun Removal Set

Disable these 20 plugins for the PDV test package:

| Plugin | Role |
|---|---|
| `Wintersun - Faiths of Skyrim.esp` | core religion overhaul |
| `Hearthfires - Wintersun Shrines.esp` | craftable shrine bridge |
| `Wintersun - Tweaks and Enhancements.esp` | Wintersun gameplay tuning |
| `Wintersun - GotT Lite Patch.esp` | Ghosts of the Tribunal bridge |
| `Wintersun - Gallows Hall.esp` | Creation Club bridge |
| `Sacrilege - Wintersun.esp` | vampire religion bridge |
| `DBM_Wintersun_Patch.esp` | Legacy of the Dragonborn bridge |
| `LOTD_TCC_Wintersun.esp` | LOTD Curator's Companion bridge |
| `COTN Dawnstar - Wintersun Patch.esp` | city/worldspace bridge |
| `JKs Dark Brotherhood Sanctuary - Wintersun patch.esp` | location bridge |
| `TOCQE - Wintersun patch.esp` | The Only Cure QE bridge |
| `TWDQE - Wintersun patch.esp` | The Whispering Door QE bridge |
| `FloatingSword_TCIY_Wintersun_Patch.esp` | quest/content bridge |
| `SDA Wintersun Patch.esp` | follower bridge |
| `Wintersun - Mrissi Patch.esp` | follower/quest bridge |
| `AX ValSerano-Wintersun.esp` | follower bridge |
| `Mannaz-Freyr-Wintersun-patch.esp` | race/standing-stone bridge |
| `Lux Orbis - Wintersun patch.esp` | lighting/worldspace bridge |
| `Lux - Wintersun patch.esp` | lighting bridge |
| `Northern Roads - Wintersun patch.esp` | worldspace bridge |

The local profile also disables the matching Wintersun mod folders for
settings, textures, craftable shrines, and direct Wintersun patch content.

## Required Generated-Output Rebuild

Do not reuse generated output plugins that were built with Wintersun active.
The local DoD proof profile reported missing-master blockers from these active
generated plugins after Wintersun was removed:

| Plugin | Stale master evidence |
|---|---|
| `DynDOLOD.esp` | still masters `Wintersun - Faiths of Skyrim.esp` |
| `Lord's Vision - Synthesis Gameplay.esp` | still masters `Wintersun - Faiths of Skyrim.esp` |
| `PG_1.esp` | still masters `Wintersun - Faiths of Skyrim.esp` and `DBM_Wintersun_Patch.esp` |

For a reusable package, regenerate the outputs rather than hand-cleaning
masters:

1. Run Synthesis through MO2 with Wintersun disabled and `Devotion.esp`
   enabled.
2. Run ParallaxGen through MO2 with the list's existing settings.
3. Run TexGen if required by the list's normal DynDOLOD workflow.
4. Run DynDOLOD through MO2 with the list's existing settings.
5. Enable the regenerated outputs and confirm MO2 reports no missing masters.

For a private smoke test only, those stale generated plugins can be disabled
temporarily. That avoids the crash but is not a public packaging answer.

## Local Readback Evidence

Local DoD test profile changes were backed up under:

`D:\Wabbajack\modlists\DoD\profiles\Diaries of Dibella - Lord's Vision\pdv-dod-backups`

Backup stamp: `20260615-130025`.

Local test install:

- `D:\Wabbajack\modlists\DoD\mods\Devotion - PlayerDevotion Local Test`
- junction target: `D:\Wabbajack\modlists\Anvil\mods\Devotion`
- `Devotion.esp` active at the former Wintersun core slot

houseCARL readback after disabling Wintersun and activating PDV:

- `Devotion.esp` is active.
- `Wintersun - Faiths of Skyrim.esp` is inactive.
- All 14 shrine blessing spell targets resolve to `Devotion.esp`.
- The three Dragonborn Good Daedra altar spells resolve to the PDV cure effect
  `071554:Devotion.esp`, carrying `PDV_DunmerShrinePrayerEffect`.
- `akdDibellanBathsLocation` already carries `LocTypeTemple`.
- `akdDibellaMarker` uses `TempleBlessingScript` and points at vanilla
  `AltarDibellaSpell`; the current Devotion shrine override covers it.
- `akdSybilMarker` uses `TempleBlessingScript` but points at the custom
  `akdAltarSybilSpell` from `Dibellan Baths.esp`, which still carries list
  blessing effects and is a future candidate only.
- `XXTUSolitudeBordello` carries `LocTypeInn`; no temple keyword patch was
  emitted.
- `XXTURiftenBrothel` from `Mara's Embrace.esp` carries `LocTypeInn`; no Mara
  temple/social route patch was emitted.
- `JOJ_TalosTeaseLocation` from `Talos' Tease.esp` carries `LocTypeDwelling`
  and `LocTypeInn`; no Talos social route patch was emitted.
- `HalfKhajiitRace` and `HalfKhajiitRaceVampire` win from
  `DOD - Ohmes-Raht Fix.esp`; no custom-race origin normalization patch was
  emitted.

## Extensibility Boundary

The current package deliberately stops at replacement-first religion removal
and shrine spell readback. It does not add generic adult-framework events,
generic romance counters, or broad social-location piety.

Future DoD or shared Bordello patches should use curated authored hooks only:

1. Wintersun shrine asset reuse can be a targeted adapter later, but only by
   overriding specific Wintersun prayer/shrine activators after ACTI/script
   readback. Keeping Wintersun active without that adapter would keep its
   gameplay driver in the stack.
2. Dibella/Mara/Talos social hooks need exact authored sources and a PDV
   receiver before an ESP write is meaningful.
3. Last Seed, Frostfall, Campfire, Growl, Sacrilege, and Moonlight Tales should
   stay context-only until explicit adapters read stable state and prevent
   duplicate curse/survival scoring.
4. DoD's custom Sybil blessing is a strong candidate for a future explicit
   design decision: either leave it as list content, neutralize its stat boon,
   or route a curated Dibella/Sybil signal after runtime proof.
5. Ohmes-Raht / Half-Khajiit needs explicit custom-race origin policy before
   PDV treats it as Khajiit for worship routing. The current package does not
   change origin detection.

## Smoke Checklist

Run on a disposable DoD test save:

1. Start game and confirm no missing masters or startup crash.
2. Open the MCM/status surface.
3. Activate representative Divine, Talos, Nocturnal, and Auriel shrines.
4. Confirm disease cure remains and vanilla stat boons do not remain in Active
   Effects.
5. As Dunmer, test the Solstheim Azura/Boethiah/Mephala altar route during a
   dawn or dusk window.
6. Confirm Papyrus log shows the Dunmer outdoor Good Daedra shrine route once
   and does not duplicate within the same window/day.
7. Enter Dibellan Baths and Crimson Corner to confirm the list's location
   content still loads normally.
8. Trigger one non-shrine devotion action.
9. Run a dawn tick.
10. Save, reload, and recheck status/MCM.
11. Confirm Papyrus log has no new PDV errors.

## Deferred Follow-Up

- Author a real Wintersun asset-reuse adapter only if DoD or another Bordello
  list wants to keep the shrine meshes/placements while replacing Wintersun
  gameplay.
- Add curated Dibella/Mara/Talos social hooks only after exact source readback
  and runtime receiver support exist.
- Refresh against current public or author-provided DoD evidence before
  presenting this as a list-author package.
