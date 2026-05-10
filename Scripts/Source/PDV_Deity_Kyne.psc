;/
    PDV_Deity_Kyne.psc
    PlayerDevotion — Kyne (The Widow of Shor)
    -----------------------------------------------------------------------
    OVERVIEW
    Concrete implementation of PDV_DeityBase for Kyne, Nordic goddess of
    storms, hunting, nature, and warriors' free will.

    DESIGN NOTES
    - ScoreAction implements the Kyne-specific rubric: slaughtering her
      beasts is forbidden (-3), combat with humanoids earns favor (+0.5),
      shouting (the Thu'um) earns favor (+0.25), outdoor sleeping earns
      favor (+0.5).
    - Properties set in CK: DeityName="Kyne", DeityIndex=0, thresholds
      default (25/50/85 or 10/50/150 per PDV_Architecture_v2), tier
      boon spells, origin multipliers.
    - Phase 2: GainMult_* are simple float ratios. Phase 4 replaces with
      stance taxonomy (NATIVE/FOREIGN/TABOO/HOSTILE per race).
    - OnTierChange uses parent default (grant/remove boons).

    TIER PROGRESSION
    - Tier 1 (Seeker, piety 10+): Kyne's Blessing — basic favor
    - Tier 2 (Devoted, piety 50+): Kyne's Gift — enhanced favor
    - Tier 3 (Champion, piety 150+): Kyne's Wings — maximum favor

    LORE BASIS
    - Kyne is universally respected in Nordic and Altmeri tradition.
    - Her blessing emphasizes open-air practice: shouting, outdoor rests.
    - Slaughtering her beasts (deer, elk) represents violence against
      nature's order, not honorable hunting.

    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Kyne extends PDV_DeityBase

; -----------------------------------------------------------------------
; EVENT HANDLERS
; -----------------------------------------------------------------------
Event OnInit()
    ; Kyne initializes with her properties already set in CK.
    ; No script-level setup needed at Phase 2.
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Kyne deity initialized.")
    endIf
EndEvent


; =======================================================================
; RUBRIC SCORING
; =======================================================================

; -----------------------------------------------------------------------
; ScoreAction(eventType, actorRef, targetRef) -> float
;   Implement Kyne's specific rubric: beasts are sacred, humanoid combat
;   is honorable, shouting is blessed, sleeping outdoors is communion.
; -----------------------------------------------------------------------
Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; TODO: Phase 3 — when PDV_EventTypes constants are defined in
    ; PDV_ActionRouter, replace these int literals with named constants.

    ; Slaughtering Kyne's beasts is forbidden
    if eventType == 1  ; KILLED_HOSTILE_BEAST (placeholder)
        return -3.0
    endIf

    ; Combat with humanoid enemies (including soldiers) earns favor
    ; as they are seen as warriors' practice
    if eventType == 2  ; KILLED_HOSTILE_HUMANOID_IN_COMBAT (placeholder)
        return 0.5
    endIf

    ; Using the Thu'um (shouting) is direct communion with Kyne
    if eventType == 3  ; SHOUTED (placeholder)
        return 0.25
    endIf

    ; Sleeping outdoors under the sky is prayer
    if eventType == 4  ; SLEPT_OUTDOORS (placeholder)
        return 0.5
    endIf

    ; All other events: Kyne does not care
    return 0.0
EndFunction


; =======================================================================
; TIER TRANSITIONS
; =======================================================================

; -----------------------------------------------------------------------
; OnTierChange(oldTier, newTier)
;   For Phase 2, use parent's default logic (grant/remove boons).
;   If Kyne boon spells are not yet authored in CK, this will be a no-op
;   (Boon_Seeker, Boon_Devoted, Boon_Champion will be None).
;
;   Future: Add Kyne-specific VFX, Messages, sound cues.
; -----------------------------------------------------------------------
Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    ; Optional: add Kyne-specific flavor
    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne recognizes " + Game.GetPlayer().GetName() + " as a Seeker.")
        endIf
    elseif newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne marks " + Game.GetPlayer().GetName() + " as Devoted.")
        endIf
    elseif newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne exalts " + Game.GetPlayer().GetName() + " as her Champion.")
        endIf
    endIf
EndFunction

; -----------------------------------------------------------------------
; OnPatronStart()
;   Called when player chooses Kyne as their patron.
;   For Phase 2, just trace. Future: add notification or VFX.
; -----------------------------------------------------------------------
Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Kyne as patron.")
    endIf
EndFunction

; -----------------------------------------------------------------------
; OnPatronEnd()
;   Called when player changes patron away from Kyne.
;   Parent strips boons; Kyne adds nothing extra in Phase 2.
; -----------------------------------------------------------------------
Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Kyne.")
    endIf
EndFunction
