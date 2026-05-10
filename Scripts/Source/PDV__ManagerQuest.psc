;/
    PDV__ManagerQuest.psc
    Devotion Mod — Phase 2 Refactor (FormList iteration + dawn consolidation)
    -----------------------------------------------------------------------
    OVERVIEW
    This script runs on the hidden manager quest (PDV__ManagerQuest).
    It owns the canonical piety/tier/deity state for the active patron,
    exposes a clean API that all other mod scripts call, and iterates
    PDV_FLST_AllDeities at dawn to consolidate per-deity daily piety.

    DEPENDENCIES
    - PapyrusUtil SE  (StorageUtil — per-deity piety storage via deity FormIDs)
    - PDV_FLST_AllDeities (FormList of all PDV_Deity_* quests)
    - Three GlobalVariable forms declared in the ESP:
        PDV_GLO_ActivePiety         (float, default 0.0)
        PDV_GLO_ActiveTier          (float, default 0.0)
        PDV_GLO_ActiveDeityIndex    (float, default -1.0)

    TIER TABLE
        0  = NONE     (no patron)
        1  = SEEKER   (piety >= PIETY_SEEKER_MIN)
        2  = DEVOTED  (piety >= PIETY_DEVOTED_MIN)
        3  = CHAMPION (piety >= PIETY_CHAMPION_MIN)

    DESIGN NOTES
    - Mirrors track only the ACTIVE patron. All per-deity piety lives
      in StorageUtil, keyed by deity FormID.
    - ProcessDawn iterates PDV_FLST_AllDeities, consolidating daily
      piety changes into persistent piety, recomputing tiers, and
      calling deity OnTierChange on any tier shifts.
    - Boon granting is handled by PDV_DeityBase.OnTierChange(), called
      from ProcessDawn.
    - The manager dispatches; deities own their scoring logic.

    PHASE 2 ADDITIONS
    - FormList property PDV_FLST_AllDeities
    - ProcessDawn() function iterating all deities
    - Placeholder for hourly update event (uncomment when Phase 3 ready)
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
; Contains all PDV_Deity_* quest forms. Iterated by ProcessDawn.
; -----------------------------------------------------------------------
FormList Property PDV_FLST_AllDeities Auto

; -----------------------------------------------------------------------
; TIER CONSTANTS  (int, read-only)
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

; Optional piety ceiling. 0.0 = no cap enforced.
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
    
    ; TODO: Phase 2+ — Uncomment after ProcessDawn is wired in Phase 3.
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
;
;   TODO: Phase 2+ — This is a structural stub. Fill in StorageUtil calls.
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

        ; TODO: Phase 2+ — Integrate StorageUtil once per-deity storage is wired.
        ; For now, this is a placeholder. Replace with:
        ;
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
        ; int oldTier = (StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int)
        ; int newTier = ComputeTierFromPiety(newPiety)
        ; StorageUtil.SetFloatValue(deityForm, "PDV.Tier", newTier as Float)
        ;
        ; if oldTier != newTier
        ;     Quest deityQuest = deityForm as Quest
        ;     (deityQuest.GetScript(0) as PDV_DeityBase).OnTierChange(oldTier, newTier)
        ; endif

        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] ProcessDawn: processed deity " + deityForm)
        endIf

        i += 1
    endWhile

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] ProcessDawn complete.")
    endIf
EndFunction

; -----------------------------------------------------------------------
; GetDebugLevel() -> Int
;   Fetch debug verbosity from PDV_GLO_DebugLevel if available.
; -----------------------------------------------------------------------
Int Function GetDebugLevel()
    GlobalVariable debugGlobal = Game.GetFormFromFile(0x0A, "PlayerDevotion_Framework.esp") as GlobalVariable
    if debugGlobal
        return debugGlobal.GetValueInt()
    endIf
    return 0
EndFunction


; =======================================================================
; UTILITY — for debug/console use only, strip in release
; =======================================================================

; PDV__ManagerQuest.ForceSetPiety(100.0)  — console helper
Function ForceSetPiety(float amount)
    _piety = amount
    RecomputeTier()
    RefreshPatronMirrors()
EndFunction
