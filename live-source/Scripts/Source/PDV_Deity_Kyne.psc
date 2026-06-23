;/ 
    PDV_Deity_Kyne.psc
    PlayerDevotion - Kyne proof-slice deity
    -----------------------------------------------------------------------
    OVERVIEW
    Concrete implementation of PDV_DeityBase for Kyne, Nordic goddess of
    storms, hunting, nature, and warriors' free will.

    PHASE 4 NOTES
    - Kyne is the proof-slice deity for Origin + stance + boon handling.
    - Her stance row is intentionally simple:
        Nord = NATIVE
        everyone else = FOREIGN
        no TABOO/HOSTILE entries
        no rivalry list entries
    - Patron boons are cumulative across tiers but active only while Kyne
      is the current patron.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Kyne extends PDV_DeityBase

Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly
Float Property DELTA_SHOUT_ATTACK = 0.35 Auto
Int Property SHOUT_DAILY_CAP = 3 Auto
Float Property SHOUT_COOLDOWN_DAYS = 0.0208 Auto

; Curated sky-road milestone signal. Kyne is otherwise data-table-scored (her
; ambient acts already feed her), but curated NordKyneTalos sources -- one-shot
; sky-road MILESTONES like Way of the Voice or Children of the Sky -- are not
; day-to-day acts and earn a piety spike here. Awarded directly to Kyne, so it
; services both broad Old Ways worship and a focused Kyne patron. Anti-farmed
; upstream in RouteNordFamily; conservative delta because it stacks on her rich
; day-to-day table (tune DELTA_SKY_ROAD if it over/under-feeds).
Int Property SIGNAL_SKY_ROAD = 1710 AutoReadOnly
Float Property DELTA_SKY_ROAD = 1.5 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Kyne deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; Race-eligibility gate: generic acts only score deities native to the player's race.
    if !IsRaceNativeForPlayer()
        return 0.0
    endIf
    ; Shout keeps its original property-based call (targetRef type guard + Phase 7 invariant);
    ; not migrated to the data table.
    if eventType == EVT_SHOUT_ATTACK
        Shout usedShout = targetRef as Shout
        if usedShout
            return ScoreRepeatableAction(eventType, DELTA_SHOUT_ATTACK, SHOUT_DAILY_CAP, SHOUT_COOLDOWN_DAYS)
        endIf
        return 0.0
    endIf

    ; Flat victim-type scoring (events 1-4) is now data-driven from PDV.LD.* keys
    ; (regression gate: must score identically to the prior hand-written ladder).
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_SKY_ROAD
        return DELTA_SKY_ROAD
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne recognizes the player as a Seeker.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne marks the player as Devoted.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kyne exalts the player as her Champion.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Kyne as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Kyne.")
    endIf
EndFunction
