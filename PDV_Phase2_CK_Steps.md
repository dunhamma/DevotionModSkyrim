# PDV Phase 2 Implementation Guide

**Status:** Phase 2 functional refactor is complete on disk and has now been verified in game with the poll-based debug harness.  
**Date:** 2026-05-11  
**Canonical context doc:** `AGENTS.md`

---

## Overview

Phase 2 is now responsible for the working per-deity ledger:
- `PDV_DeityBase.psc` defines the deity contract and now exposes a `PDV_GLO_DebugLevel` property.
- `PDV_Deity_Kyne.psc` is the first concrete deity and inherits that debug property.
- `PDV__ManagerQuest.psc` now stores per-deity piety and tier in StorageUtil, mirrors the active patron's persistent values into globals, consolidates `PDV.PietyToday` at dawn, and exposes a poll-based debug harness for Skyrim console testing.

Important runtime rule:
- `PDV_GLO_ActivePiety` mirrors persistent `PDV.Piety` only.
- Daytime awards accumulate in `PDV.PietyToday`.
- `ProcessDawn()` moves scratch piety into persistent piety and triggers tier transitions.

---

## Part 1: Compile the Scripts

Compile these three scripts:

1. `PDV_DeityBase.psc`
2. `PDV_Deity_Kyne.psc`
3. `PDV__ManagerQuest.psc`

Expected outputs:
- `PDV_DeityBase.pex`
- `PDV_Deity_Kyne.pex`
- `PDV__ManagerQuest.pex`

Compile command for the manager:

```powershell
& "D:\Wabbajack\modlists\Anvil\Stock Game\Papyrus Compiler\PapyrusCompiler.exe" `
"PDV__ManagerQuest" `
"-import=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source;D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts;D:\Wabbajack\modlists\Anvil\mods\PapyrusUtil AE - Scripting Utility Functions\Scripts\Source;D:\Wabbajack\modlists\Anvil\mods\SKSE Script Sources - Compile Only\scripts\source" `
"-output=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts" `
"-flags=D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg"
```

---

## Part 2: Create or Verify the Kyne Quest

If `PDV_Deity_Kyne` does not already exist in the ESP, create it:

1. Open `PlayerDevotion_Framework.esp` in CK.
2. Create a new quest:
   - `ID`: `PDV_Deity_Kyne`
   - `Type`: `None`
   - `Priority`: `50`
   - `Start Game Enabled`: checked
   - `Run Once`: unchecked
3. Attach the `PDV_Deity_Kyne` script.

Set these script properties:

| Property | Value |
|---|---|
| `DeityName` | `Kyne` |
| `DeityDomain` | `Storms, Hunt, Warriors' Spirit` |
| `DeityIndex` | `0` |
| `ThresholdSeeker` | `10.0` |
| `ThresholdDevoted` | `50.0` |
| `ThresholdChampion` | `150.0` |
| `GainMult_Nordic` | `1.25` |
| `GainMult_Imperial` | `0.8` |
| `GainMult_Mer` | `0.5` |
| `GainMult_Beast` | `1.0` |
| `GainMult_Foreign` | `0.6` |
| `Weight_Combat` | `0.0` |
| `Weight_Social` | `0.0` |
| `Weight_Lifestyle` | `0.0` |
| `PDV_GLO_DebugLevel` | `PDV_GLO_DebugLevel` or `None` |
| `Boon_Seeker` | `None` |
| `Boon_Devoted` | `None` |
| `Boon_Champion` | `None` |

---

## Part 3: Create or Verify `PDV_FLST_AllDeities`

1. In CK, create a new FormList:
   - `ID`: `PDV_FLST_AllDeities`
2. Add `PDV_Deity_Kyne` to the list.

This FormList is the iteration source for `ProcessDawn()` and later for MCM and ActionRouter work.

---

## Part 4: Wire Manager Properties

Open `PDV__ManagerQuest` in CK and confirm these properties are assigned:

| Property | Value |
|---|---|
| `PDV_FLST_AllDeities` | `PDV_FLST_AllDeities` |
| `PDV_GLO_ActivePiety` | `PDV_GLO_ActivePiety` |
| `PDV_GLO_ActiveTier` | `PDV_GLO_ActiveTier` |
| `PDV_GLO_ActiveDeityIndex` | `PDV_GLO_ActiveDeityIndex` |
| `PDV_GLO_DebugLevel` | `PDV_GLO_DebugLevel` or `None` |

The manager will compile without `PDV_GLO_DebugLevel`, but it will not behave correctly in-game if the three mirror globals or the FormList are missing.

---

## Part 5: Runtime Behavior to Verify

After compile and wiring, the expected runtime behavior is:

- `AwardPiety(deity, amount)` writes to `PDV.PietyToday`
- `SetActiveDeity(deity)` changes which deity is mirrored without wiping stored piety
- `RefreshPatronMirrors()` reflects persistent active-patron piety and tier only
- `ProcessDawn()` clamps daily scratch to `+/-5`, writes persistent piety, recomputes tier, and fires `OnTierChange()` on tier change
- `GetDebugLevel()` reads the wired `PDV_GLO_DebugLevel` property rather than a hardcoded FormID

---

## Part 6: Use the Poll-Based Debug Harness

The validated Phase 2 test harness is the manager's built-in poll loop, not a CK stage fragment.

`PDV__ManagerQuest` registers `OnUpdate()` every 1 second and consumes queued debug commands from `SetPQV`.

Use these manager script properties with `SetPQV`:

| Property | Purpose |
|---|---|
| `DebugCommand` | Chooses which helper runs |
| `DebugIndex` | Deity index argument |
| `DebugValue` | Float argument |

Command IDs:

| `DebugCommand` | Action |
|---|---|
| `1` | `DebugClearActiveDeity()` |
| `2` | `DebugResetDeityByIndex(DebugIndex)` |
| `3` | `ForceSetActiveDeityByIndex(DebugIndex)` |
| `4` | `ForceSetPietyToday(DebugValue)` |
| `5` | `ProcessDawn()` |
| `6` | `ForceSetPiety(DebugValue)` |

Important usage rule:
- Enter one command at a time.
- Close the console after each `SetPQV DebugCommand ...`.
- Wait 2-3 seconds in live gameplay before reopening the console to inspect results.

---

## Part 7: Testing Phase 2

### Baseline checks

- `sqv PDV_Deity_Kyne`
- `GetGlobalValue PDV_GLO_ActivePiety`
- `GetGlobalValue PDV_GLO_ActiveTier`
- `GetGlobalValue PDV_GLO_ActiveDeityIndex`

Expected clean-start behavior:
- active piety is `0.0`
- active tier is `0.0`
- active deity index is `-1` until a patron is selected

If testing on an existing save after recompiling the manager, reload it first:

```text
StopQuest PDV__ManagerQuest
StartQuest PDV__ManagerQuest
```

Then wait 2-3 seconds before running test commands.

### Patron-switch check

Goal:
- confirm that switching patron updates the mirrors
- confirm that previously stored piety is not wiped on the old deity

Console steps:

```text
SetPQV PDV__ManagerQuest DebugIndex 0
SetPQV PDV__ManagerQuest DebugCommand 3
```

Close the console, wait 2-3 seconds, then reopen the console and run:

```text
GetGlobalValue PDV_GLO_ActiveDeityIndex
SQV PDV__ManagerQuest
```

Expected result:
- `PDV_GLO_ActiveDeityIndex` becomes `0`
- `DebugCommand` has been consumed back to `0`
- `activeDeity` is no longer `None`

### Dawn-consolidation check

Goal:
- seed `PDV.PietyToday` on the active deity
- call `ProcessDawn()`
- confirm the delta is clamped to `+/-5`
- confirm persistent `PDV.Piety` changes
- confirm `PDV.PietyToday` resets to `0`
- confirm tier changes call `OnTierChange()` when thresholds are crossed

Reset Kyne:

```text
SetPQV PDV__ManagerQuest DebugIndex 0
SetPQV PDV__ManagerQuest DebugCommand 2
```

Close the console and wait 2-3 seconds.

Activate Kyne:

```text
SetPQV PDV__ManagerQuest DebugIndex 0
SetPQV PDV__ManagerQuest DebugCommand 3
```

Close the console and wait 2-3 seconds.

Seed scratch piety:

```text
SetPQV PDV__ManagerQuest DebugValue 7.0
SetPQV PDV__ManagerQuest DebugCommand 4
```

Close the console and wait 2-3 seconds.

Run dawn:

```text
SetPQV PDV__ManagerQuest DebugCommand 5
```

Close the console and wait 2-3 seconds, then reopen the console and run:

```text
GetGlobalValue PDV_GLO_ActivePiety
GetGlobalValue PDV_GLO_ActiveTier
```

Expected result:
- Active piety becomes `5.0`
- Active tier remains `0.0`

Threshold-crossing follow-up:

```text
SetPQV PDV__ManagerQuest DebugValue 10.0
SetPQV PDV__ManagerQuest DebugCommand 4
```

Close the console and wait 2-3 seconds.

```text
SetPQV PDV__ManagerQuest DebugCommand 5
```

Close the console and wait 2-3 seconds, then reopen the console and run:

```text
GetGlobalValue PDV_GLO_ActivePiety
GetGlobalValue PDV_GLO_ActiveTier
```

Expected result:
- Active piety becomes `10.0`
- Active tier becomes `1.0`

### Debug check

Goal:
- change `PDV_GLO_DebugLevel`
- confirm traces increase or decrease accordingly
- confirm there are no missing-property warnings and no hardcoded FormID dependency

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Missing property warning on Kyne | `PDV_GLO_DebugLevel` was not wired on the Kyne quest |
| Missing property warning on manager | One or more manager globals or the FormList are not wired |
| `ProcessDawn()` does nothing | `PDV_FLST_AllDeities` is empty or the active test deity is not in the FormList |
| `DebugCommand` never clears | The console stayed open; close it and let the game run 2-3 seconds so `OnUpdate()` can consume the command |
| `GetGlobalValue PDV_GLO_ActiveDeityIndex` stays `-1` after command `3` | `SetPQV` was entered but the console was not closed, or the manager was not restarted after recompiling |
| Mirrors change during daytime awards | Old compiled script still in use; recompile and replace `PDV__ManagerQuest.pex` |
| Debug traces never appear | `PDV_GLO_DebugLevel` is unset or `0` |

---

## Notes

- This guide no longer embeds a copy of `PDV__ManagerQuest.psc`. The script on disk is the source of truth.
- The original stage-fragment approach was abandoned in this setup because CKPE fragment binding was unreliable. The poll-based harness is the validated path.
- `SetPQV` testing must be done one command at a time, with the console closed between commands so Papyrus updates can fire.
- Phase 3 will add live event capture. Phase 2 already owns the per-deity ledger and dawn consolidation logic.
