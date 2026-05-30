# PlayerDevotion Phase 18 Nord Beta Slice

Build: `5de775b`
Date: 2026-05-30

## What This Is

This is a playable beta deep slice for the Nord module and the new player-facing status surface.

It is not the full 12-god Nord pantheon and it is not a Molag Bal/vampire worship path. The slice is meant to review the architecture, status UX, runtime logic, and the first complete Nord pilot lane.

## Install

Install the folder below as a normal MO2 mod:

```text
Installable-Mod/Devotion
```

The installable mod includes:

```text
PlayerDevotion_Framework.esp
Scripts/*.pex
Seq/PlayerDevotion_Framework.seq
SKSE/Plugins/DevotionPrismaBridge.dll
PrismaUI/views/Devotion/*
```

Do not install only the ESP. The compiled Papyrus files in `Scripts/*.pex` are required for the MCM, Survey Devotion, curse state handling, and Nord runtime logic.

## Expected Dependencies

- Skyrim Special Edition / Anniversary Edition runtime compatible with the Anvil setup
- SKSE
- SkyUI
- PapyrusUtil / StorageUtil
- powerofthree's Papyrus Extender for the wider Devotion build

## What To Review

- Player page: status readout is thematic and does not expose exact piety.
- Developer Options: Status and Debug pages stay hidden unless enabled.
- Survey Devotion: lesser power is auto-granted and can be activated with `Z` when no other power or shout is selected.
- Broad Nord lanes: Old Ways and Nine Divines status readouts.
- Focused Nord lanes: Kyne and Talos Champion readouts.
- Curse handling: werewolf/Hircine tension, vampire rupture suppression, cured-vampire scar.
- Dialogue gates: Froki, Heimskr, Andurs, and Aela should appear only under the intended Nord conditions.

## Review Materials

`Review-Materials/Source-Papyrus` contains the main scripts for logic review.

`Review-Materials/Authoring` contains the Phase 18 manifest, runbook, and project context docs used to verify this slice.

## Known Scope Limits

- Numeric piety is intentionally developer-only.
- Non-pilot Nord gods are drafted but not complete runtime lanes.
- Vampire is curse feedback plus suppression/scar only.
- Dialogue was CK-authored and verifier-read back; generated dialogue creation is not claimed as product-safe yet.

## Current Verification

Backend checks at package time:

```text
PDV__ManagerQuest compile: 0 errors, 0 warnings
pdv_verify strict Phase 13-18/Nord ladder: PASS=1185, INFO=28
pdv_content_verify: PASS=631, WARN=165, INFO=3
pdv-phase18-author dry-run: PASS
```

Runtime checks reported passed:

```text
Player page and Developer Options
Survey Devotion MessageBox and Z activation
Broad Old Ways and Broad Nine Divines
Focused Kyne and Talos
Werewolf/Hircine tension
Vampire suppression, cure scar, and save/load persistence
Froki, Heimskr, Andurs, and Aela dialogue positive/negative checks
```
