# PDV Phase 21 - Authoria / ARR Compatibility Handoff

Status: local package evidence; runtime and author acceptance pending.
Date: 2026-06-14.

This is a technical handoff for Authoria / ARR integration testing. It is not a
public support claim and not maintainer approval.

## Package Contents

- Use the current `PlayerDevotion_Framework.esp` from the Devotion mod.
- Disable the Archon religion layer listed below.
- Load `PlayerDevotion_Framework.esp` after Requiem inputs and before
  `Requiem for the Indifferent.esp`.
- Re-run the Reqtificator after placement. Treat any RFTI output from local
  testing as a reference snapshot only; the list author should regenerate it.
- No standalone `PDV_AuthoriaARR_Compatibility.esp` is emitted for this slice.
  The reserved plugin name is for later ARR-specific route adapters if a stable
  Daedric shrine ACTI map is approved.

## Archon Removal Set

Disable these 15 plugins for the PDV test package:

| Plugin | Role |
|---|---|
| `Archon.esp` | core religion overhaul |
| `Archon - Vigilant.esp` | quest-mod bridge |
| `Archon - BDS.esp` | quest-mod bridge |
| `Archon - Mandra Shrines.esp` | Daedric shrine content bridge |
| `Archon - Wyrmstooth.esp` | quest-mod bridge |
| `Archon - HOHQE.esp` | House of Horrors QE bridge |
| `Archon - TG Alt Endings.esp` | Thieves Guild bridge |
| `Archon - TOCQE.esp` | The Only Cure QE bridge |
| `Archon - TWDQE.esp` | The Whispering Door QE bridge |
| `Archon - Markarth Entrance and Farm Overhaul.esp` | worldspace bridge |
| `Archon - Lux Via.esp` | Lux Via bridge |
| `Lux - Archon.esp` | Lux bridge |
| `Lux - Archon - Mandra Shrines.esp` | Lux/Mandra bridge |
| `Authoria - Master Patch - Archon.esp` | Authoria consolidation |
| `Authoria - Papyrus - Missing Properties - Archon Fix.esp` | Archon script-property fix |

The earlier dossier count said 16, but the live ARR profile and the dossier
table resolve to 15 active Archon-family plugins.

## Readback Evidence

Local ARR test profile changes were backed up under:

`D:\Wabbajack\modlists\ARR\profiles\Authoria - Requiem Reforged - Main Profile\pdv-authoria-backups`

Backup stamp: `20260614-224145`.

Local test install:

- `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test`
- junction target: `D:\Wabbajack\modlists\Anvil\mods\Devotion`
- `PlayerDevotion_Framework.esp` active before `Requiem for the Indifferent.esp`

houseCARL readback after disabling Archon and activating PDV:

- `PlayerDevotion_Framework.esp` is active.
- `Archon.esp` and `Archon - Mandra Shrines.esp` are inactive.
- All 14 shrine blessing spell targets resolve to
  `PlayerDevotion_Framework.esp`.
- The three Dragonborn Good Daedra altar spells resolve to the PDV cure effect
  `071554:PlayerDevotion_Framework.esp`, carrying
  `PDV_DunmerShrinePrayerEffect`.

## Smoke Checklist

Run on a disposable ARR test save:

1. Start game and confirm no missing masters or startup crash.
2. Open the MCM/status surface.
3. Activate representative Divine, Talos, Nocturnal, and Auriel shrines.
4. Confirm disease cure remains and vanilla stat boons do not remain in Active
   Effects.
5. As Dunmer, test the Solstheim Azura/Boethiah/Mephala altar route during a
   dawn or dusk window.
6. Confirm Papyrus log shows the Dunmer outdoor Good Daedra shrine route once
   and does not duplicate within the same window/day.
7. Trigger one non-shrine devotion action.
8. Run a dawn tick.
9. Save, reload, and recheck status/MCM.
10. Confirm Papyrus log has no new PDV errors.

## Deferred Follow-Up

- Per-Prince Mandragora/ARR Daedric shrine route adapters are not included.
  The current ACTI scan only found stable Nocturnal shrine ACTI records in the
  queried `man_*` plugins.
- Survival systems remain context-only: SunHelm, Frostfall, and Campfire should
  inform eligibility/caps only, not raw piety gain.
- Curse theology remains Requiem-native for ARR. Future hooks should key off
  Requiem vampire/werewolf records and curated artifact/quest transitions.
