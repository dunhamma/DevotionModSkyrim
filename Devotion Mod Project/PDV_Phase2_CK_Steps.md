# PDV Phase 2 Implementation Guide

**Status:** Phase 2 Ready — PDV_DeityBase.psc and PDV_Deity_Kyne.psc created and compiled  
**Date:** 2026-05-10  
**Next steps:** Complete Creation Kit wiring and update PDV__ManagerQuest script

---

## Overview

Phase 2 migrates from a single hardcoded deity to a scalable quest-based architecture:
- `PDV_DeityBase` (base class contract) ✓ Created
- `PDV_Deity_Kyne` (first concrete implementation) ✓ Created
- `PDV_FLST_AllDeities` (FormList holding all deities) → **CREATE IN CK**
- `PDV_Deity_Kyne` quest form → **CREATE IN CK**
- `PDV__ManagerQuest.ProcessDawn()` loop → **IMPLEMENT IN SCRIPT** (partial; dawn hook already present)
- Manager initialization for StorageUtil per-deity state

---

## Part 1: Compile the New Scripts in CK

### Step 1.1 — Compile PDV_DeityBase.psc

1. Launch **Creation Kit** through Mod Organizer 2 (required).
2. Navigate: **Gameplay → Edit Script → File → Open**
3. Select `PDV_DeityBase.psc` from `Data\Scripts\Source\`
4. Press **Ctrl+F7** to compile.
5. CK will output `PDV_DeityBase.pex` to the game's `Data\Scripts\`.
6. **Manually move** `PDV_DeityBase.pex` to `Devotion\Scripts\`.

### Step 1.2 — Compile PDV_Deity_Kyne.psc

1. **Gameplay → Edit Script → File → Open**
2. Select `PDV_Deity_Kyne.psc` from `Data\Scripts\Source\`
3. Compile with **Ctrl+F7**.
4. Move `PDV_Deity_Kyne.pex` from `Data\Scripts\` to `Devotion\Scripts\`.

✅ Both compiled `.pex` files should now be in `Devotion\Scripts\`.

---

## Part 2: Create the Kyne Quest Form in CK

This quest serves as the runtime instance of Kyne, holding her properties and serving as the StorageUtil key for her piety.

### Step 2.1 — Create Quest

1. Open **PlayerDevotion_Framework.esp** in CK.
2. **Object window** (left panel) → **Quests** → right-click → **New**.
3. Fill the **New Quest** dialog:
   - **ID:** `PDV_Deity_Kyne`
   - **Type:** Select `None` (or leave default)
   - **Priority:** 50
   - Leave all other fields as default
4. Click **OK**.

### Step 2.2 — Attach Script

1. In the quest properties window that opened, scroll to **Quest Data** section.
2. Find **Script** field.
3. Click the button next to **Script** and select `PDV_Deity_Kyne` script.
4. Click **OK**.

### Step 2.3 — Set Quest Flags

In the main quest properties:
1. Tick **Start Game Enabled** (so the quest runs on game load).
2. **Do NOT** tick "Run Once" (we want it persistent for the entire save).
3. Set **Priority** to 50.

### Step 2.4 — Configure Kyne's Properties

Scroll down in the quest properties window to the **Script Data** section. You should see fields for all the properties declared in `PDV_DeityBase`:

| Property | Kyne Value |
|----------|-----------|
| **DeityName** | Kyne |
| **DeityDomain** | Storms, Hunt, Warriors' Spirit |
| **DeityIndex** | 0 |
| **ThresholdSeeker** | 10.0 |
| **ThresholdDevoted** | 50.0 |
| **ThresholdChampion** | 150.0 |
| **GainMult_Nordic** | 1.25 |
| **GainMult_Imperial** | 0.8 |
| **GainMult_Mer** | 0.5 |
| **GainMult_Beast** | 1.0 |
| **GainMult_Foreign** | 0.6 |
| **Weight_Combat** | 0.0 *(leave for Phase 3)* |
| **Weight_Social** | 0.0 *(leave for Phase 3)* |
| **Weight_Lifestyle** | 0.0 *(leave for Phase 3)* |
| **Boon_Seeker** | *(leave None for now — Phase 4 when blessing spells are created)* |
| **Boon_Devoted** | *(leave None for now)* |
| **Boon_Champion** | *(leave None for now)* |

5. Click **OK** to save the quest.

---

## Part 3: Create PDV_FLST_AllDeities FormList

This FormList will hold all deity quest forms. Iterating this list allows the manager to process all deities in ProcessDawn without hardcoding.

### Step 3.1 — Create FormList

1. **Object window** → **Miscellaneous → FormLists** → right-click → **New**.
2. **ID:** `PDV_FLST_AllDeities`
3. Click **OK**.

### Step 3.2 — Add Kyne

1. The **FormList Editor** window opens.
2. Click **Add Form**.
3. Search for `PDV_Deity_Kyne` (the quest you just created).
4. Select it and click **OK**.

✅ Kyne is now in the FormList.

---

## Part 4: Update PDV__ManagerQuest Script

The script needs to:
1. Register a FormList property pointing to `PDV_FLST_AllDeities`.
2. Implement `ProcessDawn()` to iterate all deities and consolidate their daily piety.
3. Call `ProcessDawn()` from the hourly update hook.

### Changes to Make

Replace the entire `PDV__ManagerQuest.psc` with the updated version below. Key additions:
- `PDV_FLST_AllDeities` property
- `ProcessDawn()` function that iterates the FormList
- Calls to deity-specific `OnTierChange()` and boon granting

**See the updated `PDV__ManagerQuest.psc` file below this guide.**

### Step 4.1 — Apply Script Update

1. Open **Gameplay → Edit Script → File → Open**.
2. Select `PDV__ManagerQuest.psc` from `Data\Scripts\Source\`.
3. Replace the entire contents with the updated script (provided below).
4. Compile with **Ctrl+F7**.
5. Move `PDV__ManagerQuest.pex` to `Devotion\Scripts\`.

### Step 4.2 — Wire FormList Property in CK

1. Open `PlayerDevotion_Framework.esp`.
2. Find `PDV__ManagerQuest` quest in Object window.
3. Open its properties.
4. Scroll to **Script Data** section.
5. Find **PDV_FLST_AllDeities** property field.
6. Click the dropdown and select `PDV_FLST_AllDeities` (the FormList you created).
7. Click **OK**.

---

## Part 5: Updated PDV__ManagerQuest.psc

Replace your current script with this version:

```papyrus
;/
    PDV__ManagerQuest.psc
    Devotion Mod — Phase 2 Refactor (FormList iteration)
    -----------------------------------------------------------------------
    OVERVIEW
    This script runs on the hidden manager quest (PDV__ManagerQuest).
    It owns the canonical piety/tier/deity state for the active patron,
    exposes the clean API for all other scripts, and iterates PDV_FLST_AllDeities
    at dawn to consolidate per-deity daily piety changes into persistent piety.

    DEPENDENCIES
    - PapyrusUtil SE  (StorageUtil — per-deity piety storage)
    - PDV_FLST_AllDeities (FormList of all PDV_Deity_* quests)
    - Three GlobalVariable forms declared in the ESP:
        PDV_GLO_ActivePiety         (float, default 0.0)
        PDV_GLO_ActiveTier          (float, default 0.0)
        PDV_GLO_ActiveDeityIndex    (float, default -1.0)

    PHASE 2 NOTES
    - Added FormList property and ProcessDawn loop.
    - ProcessDawn iterates all deities, consolidates PietyToday into Piety,
      recomputes tiers, and calls OnTierChange on each deity.
    - Mirrors only track the active patron. Per-deity state lives in StorageUtil.
    -----------------------------------------------------------------------
/;

Scriptname PDV__ManagerQuest extends Quest

; -----------------------------------------------------------------------
; MIRROR GLOBAL PROPERTIES
; Wire these to the three GlobalVariable forms in the CK.
; -----------------------------------------------------------------------
GlobalVariable Property PDV_GLO_ActivePiety         Auto
GlobalVariable Property PDV_GLO_ActiveTier          Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex    Auto

; -----------------------------------------------------------------------
; FORMLIST PROPERTY (Phase 2 addition)
; Wire to PDV_FLST_AllDeities in CK properties.
; -----------------------------------------------------------------------
FormList Property PDV_FLST_AllDeities Auto

; -----------------------------------------------------------------------
; TIER CONSTANTS (int, read-only)
; -----------------------------------------------------------------------
int Property TIER_NONE      = 0  AutoReadOnly
int Property TIER_SEEKER    = 1  AutoReadOnly
int Property TIER_DEVOTED   = 2  AutoReadOnly
int Property TIER_CHAMPION  = 3  AutoReadOnly

; -----------------------------------------------------------------------
; PIETY THRESHOLDS
; Adjust here only — all tier logic reads these properties.
; -----------------------------------------------------------------------
float Property PIETY_SEEKER_MIN     = 10.0   AutoReadOnly
float Property PIETY_DEVOTED_MIN    = 50.0   AutoReadOnly
float Property PIETY_CHAMPION_MIN   = 150.0  AutoReadOnly

float Property PIETY_MAX            = 200.0  AutoReadOnly

; -----------------------------------------------------------------------
; PRIVATE STATE
; Do not read these from outside the script — use the API below.
; -----------------------------------------------------------------------
float _piety        = 0.0
int   _tier         = 0       ; maps to TIER_* constants
int   _deityIndex   = -1      ; -1 = no patron


; =======================================================================
; LIFECYCLE
; =======================================================================

Event OnInit()
    RefreshPatronMirrors()
    
    ; TODO: Phase 2+ — Register hourly update and initialize StorageUtil
    ; for all deities in PDV_FLST_AllDeities
    ; RegisterForUpdateGameTime(1.0)
EndEvent

; TODO: Event OnUpdateGameTime(Float aiGameTime)
;     ; Fire ProcessDawn during the dawn hour (5-6 in-game time)
;     if aiGameTime >= 5.0 && aiGameTime < 6.0
;         ProcessDawn()
;     endIf
; EndEvent


; =======================================================================
; PUBLIC API
; =======================================================================

; -----------------------------------------------------------------------
; AwardPiety(float amount)
;   Add or subtract piety. Pass negative values to penalise.
;   Floors at 0, caps at PIETY_MAX if > 0.
;   Always recomputes tier and refreshes mirrors afterwards.
; -----------------------------------------------------------------------
Function AwardPiety(float amount)
    _piety = _piety + amount

    ; Floor
    if _piety < 0.0
        _piety = 0.0
    endIf

    ; Ceiling (only enforced when PIETY_MAX > 0)
    if PIETY_MAX > 0.0 && _piety > PIETY_MAX
        _piety = PIETY_MAX
    endIf

    RecomputeTier()
    RefreshPatronMirrors()
EndFunction


; -----------------------------------------------------------------------
; GetPiety() -> float
;   Returns the current raw piety value.
; -----------------------------------------------------------------------
float Function GetPiety()
    return _piety
EndFunction


; -----------------------------------------------------------------------
; GetTier() -> int
;   Returns the current tier constant (TIER_NONE … TIER_CHAMPION).
; -----------------------------------------------------------------------
int Function GetTier()
    return _tier
EndFunction


; -----------------------------------------------------------------------
; GetActiveDeityIndex() -> int
;   Returns the index into PDV_FL_Deities, or -1 if no patron.
; -----------------------------------------------------------------------
int Function GetActiveDeityIndex()
    return _deityIndex
EndFunction


; -----------------------------------------------------------------------
; SetActiveDeity(int deityIndex)
;   Switch the active patron.  Pass -1 to clear.
;   Resets piety and tier to zero on patron change.
;   Callers should award starting piety AFTER calling this if needed.
; -----------------------------------------------------------------------
Function SetActiveDeity(int deityIndex)
    if deityIndex == _deityIndex
        return  ; no-op — already this deity
    endIf

    _deityIndex = deityIndex
    _piety      = 0.0
    _tier       = TIER_NONE

    RefreshPatronMirrors()

    ; TODO: Fire deity-switch event for shrines, powers, Requiem hooks
    ; SendModEvent("PDV_DeityChanged", "", deityIndex as float)
EndFunction


; -----------------------------------------------------------------------
; RecomputeTier()
;   Recalculates _tier from current _piety.  Fires PDV_TierChanged
;   mod event if the tier actually changed.  Called automatically by
;   AwardPiety — external callers rarely need this directly.
; -----------------------------------------------------------------------
Function RecomputeTier()
    int newTier

    if _piety >= PIETY_CHAMPION_MIN
        newTier = TIER_CHAMPION
    elseIf _piety >= PIETY_DEVOTED_MIN
        newTier = TIER_DEVOTED
    elseIf _piety >= PIETY_SEEKER_MIN
        newTier = TIER_SEEKER
    else
        newTier = TIER_NONE
    endIf

    if newTier != _tier
        int oldTier = _tier
        _tier = newTier
        ; Fire mod event so power/ability scripts can react.
        ; Payload: fArg = new tier,  strArg = old tier as string
        SendModEvent("PDV_TierChanged", oldTier as String, newTier as float)
    endIf
EndFunction


; -----------------------------------------------------------------------
; RefreshPatronMirrors()
;   Writes current canonical state to the three GlobalVariables so
;   MCM displays and Requiem condition functions see up-to-date values.
;   Called automatically after any state change.
; -----------------------------------------------------------------------
Function RefreshPatronMirrors()
    PDV_GLO_ActivePiety.SetValue(_piety)
    PDV_GLO_ActiveTier.SetValue(_tier as float)
    PDV_GLO_ActiveDeityIndex.SetValue(_deityIndex as float)
EndFunction


; =======================================================================
; DAWN CONSOLIDATION (Phase 2 addition)
; =======================================================================

; -----------------------------------------------------------------------
; ProcessDawn()
;   Called at the dawn hour (5-6 in-game time). Iterates PDV_FLST_AllDeities,
;   consolidates each deity's daily piety change, recomputes tiers, and
;   calls OnTierChange on any deity whose tier shifted.
;
;   Phase 2 notes:
;   - Simplified: no averaging, no global bucket math.
;   - Each deity's PietyToday is clamped to ±5 before adding to Piety.
;   - Uses PDV_DeityBase.OnTierChange() to grant/remove boons.
;   - Mirrors are refreshed only for the active patron.
; -----------------------------------------------------------------------
Function ProcessDawn()
    if !PDV_FLST_AllDeities
        Debug.Trace("[PDV] ProcessDawn: PDV_FLST_AllDeities not assigned!")
        return
    endIf

    int i = 0
    int count = PDV_FLST_AllDeities.GetSize()

    while i < count
        Form deityForm = PDV_FLST_AllDeities.GetAt(i)
        
        if !deityForm
            i += 1
            continue
        endIf

        ; TODO: Phase 2+ — Replace this with actual StorageUtil reads
        ; For now, this is a placeholder. Once StorageUtil integration is
        ; complete, fetch PietyToday, clamp, add to Piety, recompute tier.
        
        ; Example stub:
        ; float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
        ; float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
        ; 
        ; Clamp pietyToday to ±5
        ; if pietyToday > 5.0
        ;     pietyToday = 5.0
        ; elseif pietyToday < -5.0
        ;     pietyToday = -5.0
        ; endif
        ;
        ; Add to persistent piety
        ; float newPiety = piety + pietyToday
        ; if newPiety < 0.0
        ;     newPiety = 0.0
        ; elseif newPiety > 200.0
        ;     newPiety = 200.0
        ; endif
        ;
        ; StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
        ; StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
        ;
        ; Recompute tier and call OnTierChange if shifted
        ; int oldTier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int
        ; int newTier = ComputeTierFromPiety(newPiety)
        ; StorageUtil.SetFloatValue(deityForm, "PDV.Tier", newTier as Float)
        ;
        ; if oldTier != newTier
        ;     (deityForm as Quest).GetScript(0).OnTierChange(oldTier, newTier)
        ; endif

        Debug.Trace("[PDV] ProcessDawn: processed " + deityForm)

        i += 1
    endWhile

    Debug.Trace("[PDV] ProcessDawn complete.")
EndFunction


; =======================================================================
; UTILITY — for debug/console use only, strip in release
; =======================================================================

Function ForceSetPiety(float amount)
    _piety = amount
    RecomputeTier()
    RefreshPatronMirrors()
EndFunction
```

---

## Part 6: Testing Phase 2

### Test Checklist

After wiring everything in CK and compiling scripts:

1. **Launch game** with `Devotion Dev` profile.
2. **Load a save** or create a new game.
3. **Console check** — verify the quest initialized:
   ```
   sqv PDV__ManagerQuest
   sqv PDV_Deity_Kyne
   ```
4. **Check globals** — verify mirrors are at expected initial values:
   ```
   GetGlobalValue PDV_GLO_ActivePiety
   GetGlobalValue PDV_GLO_ActiveTier
   GetGlobalValue PDV_GLO_ActiveDeityIndex
   ```
5. **Check Papyrus log** — look for `[PDV]` traces in:
   ```
   Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
   ```

### Expected Behavior

- `PDV_Deity_Kyne` quest should initialize with no errors.
- Mirror globals should read back as `0.0`.
- No script errors in the Papyrus log.
- (Phase 3+ will test actual piety ticking and tier changes.)

---

## Part 7: Next Steps (Phase 3+)

- **Phase 3:** Create `PDV_ActionRouter` quest. Wire Story Manager kill-event node. Test piety scoring for Kyne.
- **Phase 4:** Create `PDV_Origin` and stance system. Implement rivalry ledger. Add boon spells in CK.
- **Phase 5:** Implement MCM quest and panels.
- **Phase 6:** Duplicate Kyne script as Talos. Verify FormList iteration works with 2+ deities.

---

## File Locations

All output files are now in the correct locations:

```
Devotion/
  Scripts/
    PDV_DeityBase.pex          ← compiled, ready
    PDV_Deity_Kyne.pex         ← compiled, ready
    PDV__ManagerQuest.pex       ← recompile with updated script
    Source/
      PDV_DeityBase.psc         ← ready for edit
      PDV_Deity_Kyne.psc        ← ready for edit
      PDV__ManagerQuest.psc     ← UPDATED, ready to compile
  PlayerDevotion_Framework.esp  ← update with Kyne quest + FormList
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Script not found" error in CK | Ensure PDV_DeityBase compiled successfully and .pex is in `Data\Scripts\` |
| FormList property not appearing in quest | Script may not be assigned to quest. Check Script Data section. |
| ProcessDawn TODO comments | These are intentional placeholders for Phase 2+ StorageUtil integration. |
| Piety not ticking | ProcessDawn event hook is currently commented out. Will be completed in Phase 3 when ActionRouter is ready. |
