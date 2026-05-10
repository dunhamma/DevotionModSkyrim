;/
    PDV_DeityBase.psc
    PlayerDevotion — Deity Contract / Base Class
    -----------------------------------------------------------------------
    OVERVIEW
    Abstract base class that every concrete deity script extends
    (PDV_Deity_Kyne, PDV_Deity_Talos, etc.). Establishes the contract
    that all deities honour — properties for identity, rubric weights,
    tier thresholds, and boon spells; virtual functions for action
    scoring, tier transitions, and patron lifecycle.

    DESIGN NOTES
    - All piety reads/writes go through StorageUtil keyed by this quest's
      Form (GetFormID). Never touch globals directly.
    - Properties are set in the CK once per deity; scripts override
      ScoreAction() to implement deity-specific rubric.
    - OnTierChange() implements boon granting/revoking; concrete deities
      may override to add VFX or Messages.
    - The manager quest calls all deity functions; deities never call
      the manager directly.

    DEPENDENCIES
    - PapyrusUtil SE (StorageUtil)
    - PDV__ManagerQuest (dispatcher)

    -----------------------------------------------------------------------
/;

Scriptname PDV_DeityBase extends Quest

; -----------------------------------------------------------------------
; IDENTITY PROPERTIES (set once in CK per deity)
; -----------------------------------------------------------------------
String Property DeityName Auto
    ; "Kyne", "Talos", "Mara", etc.

String Property DeityDomain Auto
    ; "Storms, Hunt, Warriors' Spirit", etc. Flavor text.

Int Property DeityIndex Auto
    ; Stable index for MCM ordering and FormList iteration.
    ; Set once, never changes. 0 for primary, 1, 2, ... for others.

; -----------------------------------------------------------------------
; TIER THRESHOLDS (tunable per-deity)
; -----------------------------------------------------------------------
Float Property ThresholdSeeker = 10.0 Auto
Float Property ThresholdDevoted = 50.0 Auto
Float Property ThresholdChampion = 150.0 Auto

; -----------------------------------------------------------------------
; ORIGIN MULTIPLIERS (apply to action deltas)
; Phase 2 note: These are simple floats. Phase 4 replaces with stance
; taxonomy. For now, use ratios: 0.5 = half speed, 1.25 = fast, 0.0 = blocked.
; -----------------------------------------------------------------------
Float Property GainMult_Nordic = 1.0 Auto
    ; Multiplier for Nord origin. Typically 1.0 (baseline).
    ; Set > 1.0 for Nordic deities (Kyne=1.25), < 1.0 for foreign.

Float Property GainMult_Imperial = 1.0 Auto
Float Property GainMult_Mer = 1.0 Auto
Float Property GainMult_Beast = 1.0 Auto
Float Property GainMult_Foreign = 1.0 Auto
    ; Catch-all for custom races.

; -----------------------------------------------------------------------
; RUBRIC WEIGHTS (which action types matter, which sign)
; Phase 2 note: Declared for future ActionRouter consumption. Not used
; yet — concrete deities drive all scoring via ScoreAction override.
; -----------------------------------------------------------------------
Float Property Weight_Combat = 0.0 Auto
    ; +1.0 if combat acts are favored, -0.5 if penalized.
    ; Populated but not read in Phase 2; will drive Phase 3 event routing.

Float Property Weight_Social = 0.0 Auto
Float Property Weight_Lifestyle = 0.0 Auto

; -----------------------------------------------------------------------
; BOON SPELLS (granted on tier change)
; Set in CK to the blessing spell for each tier. OnTierChange grants
; the new-tier spell, removes the old-tier spell. All three can be 0
; (None) if the deity has no boons.
; -----------------------------------------------------------------------
Spell Property Boon_Seeker Auto
Spell Property Boon_Devoted Auto
Spell Property Boon_Champion Auto

; -----------------------------------------------------------------------
; TIER CONSTANTS (for readability in function bodies)
; -----------------------------------------------------------------------
Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly


; =======================================================================
; PUBLIC VIRTUAL FUNCTIONS — Concrete deities override these
; =======================================================================

; -----------------------------------------------------------------------
; ScoreAction(eventType, actorRef, targetRef) -> float
;   Called by ActionRouter after an event fires. Return the piety
;   delta this deity wants to apply based on the event type.
;
;   Parameters:
;     eventType     Int code (PDV_EventTypes.KILLED_HOSTILE_BEAST, etc.)
;     actorRef      Form triggering the event (usually the player)
;     targetRef     Form acted upon (victim, location, etc.)
;
;   Default (this base class): return 0.0 (no effect)
;
;   Override in concrete deities to implement the rubric. Example:
;     if eventType == PDV_EventTypes.KILLED_HOSTILE_BEAST
;         return -3.0   ; Kyne: slaughtering beasts is forbidden
;     elseif eventType == PDV_EventTypes.KILLED_HUMANOID_COMBAT
;         return +0.5   ; Kyne: warrior's spirit
;     endif
;     return 0.0
; -----------------------------------------------------------------------
Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return 0.0
EndFunction

; -----------------------------------------------------------------------
; OnTierChange(oldTier, newTier)
;   Called by ManagerQuest when this deity's tier changes.
;   Default: grant newTier's boon, remove oldTier's boon.
;
;   Concrete deities may override to add VFX, sound, Messages, etc.
;   Example override:
;     Function OnTierChange(Int oldTier, Int newTier)
;         ; Call parent first
;         Parent_OnTierChange(oldTier, newTier)
;         ; Add Kyne-specific effects
;         MagicEffect_SkyEffect.Cast(PlayerRef, PlayerRef)
;         Game.GetPlayer().PlaceAtMe(FXObject_Thunder)
;     EndFunction
; -----------------------------------------------------------------------
Function OnTierChange(Int oldTier, Int newTier)
    ; Remove old-tier boon
    if oldTier == TIER_SEEKER && Boon_Seeker
        Game.GetPlayer().RemoveSpell(Boon_Seeker)
    elseif oldTier == TIER_DEVOTED && Boon_Devoted
        Game.GetPlayer().RemoveSpell(Boon_Devoted)
    elseif oldTier == TIER_CHAMPION && Boon_Champion
        Game.GetPlayer().RemoveSpell(Boon_Champion)
    endIf

    ; Grant new-tier boon
    if newTier == TIER_SEEKER && Boon_Seeker
        Game.GetPlayer().AddSpell(Boon_Seeker, False)
    elseif newTier == TIER_DEVOTED && Boon_Devoted
        Game.GetPlayer().AddSpell(Boon_Devoted, False)
    elseif newTier == TIER_CHAMPION && Boon_Champion
        Game.GetPlayer().AddSpell(Boon_Champion, False)
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " tier change: " + oldTier + " -> " + newTier)
    endIf
EndFunction

; -----------------------------------------------------------------------
; OnPatronStart()
;   Called by ManagerQuest when player sets this deity as their patron.
;   Default: trace only.
;
;   Concrete deities may override to grant starting boons, play
;   notification, etc.
; -----------------------------------------------------------------------
Function OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron start")
    endIf
EndFunction

; -----------------------------------------------------------------------
; OnPatronEnd()
;   Called by ManagerQuest when player changes patron away from this
;   deity. Default: remove all boons, trace.
;
;   Concrete deities may override to add farewell message, etc.
; -----------------------------------------------------------------------
Function OnPatronEnd()
    ; Strip all boons
    if Boon_Seeker
        Game.GetPlayer().RemoveSpell(Boon_Seeker)
    endIf
    if Boon_Devoted
        Game.GetPlayer().RemoveSpell(Boon_Devoted)
    endIf
    if Boon_Champion
        Game.GetPlayer().RemoveSpell(Boon_Champion)
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron end")
    endIf
EndFunction


; =======================================================================
; UTILITY FUNCTIONS
; =======================================================================

; -----------------------------------------------------------------------
; GetDeityForm() -> Form
;   Return this quest's own Form. Used as the StorageUtil key for
;   piety reads/writes. Shorthand for (Self as Form).
; -----------------------------------------------------------------------
Form Function GetDeityForm()
    return Self as Form
EndFunction

; -----------------------------------------------------------------------
; GetDebugLevel() -> Int
;   Read PDV_GLO_DebugLevel to determine trace verbosity.
;   0 = no trace, 1 = normal, 2 = verbose, 3 = spam.
; -----------------------------------------------------------------------
Int Function GetDebugLevel()
    GlobalVariable debugGlobal = Game.GetFormFromFile(0x0A, "PlayerDevotion_Framework.esp") as GlobalVariable
    if debugGlobal
        return debugGlobal.GetValueInt()
    endIf
    return 0
EndFunction
