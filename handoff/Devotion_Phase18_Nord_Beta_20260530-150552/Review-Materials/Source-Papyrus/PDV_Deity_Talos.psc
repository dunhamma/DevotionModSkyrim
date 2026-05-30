;/ 
    PDV_Deity_Talos.psc
    PlayerDevotion - Talos hostile-path proof deity
    -----------------------------------------------------------------------
    OVERVIEW
    Talos is the first real proof of hostile-path devotion. In the current
    slice, he proves explicit defiance signals and one-way rivalry against
    Auri-El for Altmer players.

    DESIGN NOTES
    - No ordinary hostile-humanoid combat drift in this slice.
    - Curated explicit Talos-facing acts drive the first proof.
    - Hostile Altmer worship is reachable immediately, with rivalry cost
      providing the friction rather than a hard gate.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Talos extends PDV_DeityBase

Int Property SIGNAL_SHRINE_DEFIANCE = 101 AutoReadOnly
Int Property SIGNAL_PROTECT_WORSHIPPER = 102 AutoReadOnly
Int Property SIGNAL_DEFIANCE_MILESTONE = 103 AutoReadOnly
Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly

Float Property DELTA_SHRINE_DEFIANCE = 3.0 Auto
Float Property DELTA_PROTECT_WORSHIPPER = 4.0 Auto
Float Property DELTA_DEFIANCE_MILESTONE = 5.0 Auto
Float Property DELTA_SHOUT_ATTACK = 0.5 Auto
Int Property SHOUT_DAILY_CAP = 2 Auto
Float Property SHOUT_COOLDOWN_DAYS = 0.0208 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Talos deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    if eventType == EVT_SHOUT_ATTACK
        Shout usedShout = targetRef as Shout
        if usedShout
            return ScoreRepeatableAction(eventType, DELTA_SHOUT_ATTACK, SHOUT_DAILY_CAP, SHOUT_COOLDOWN_DAYS)
        endIf
    endIf

    return 0.0
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_SHRINE_DEFIANCE
        return DELTA_SHRINE_DEFIANCE
    elseIf signalType == SIGNAL_PROTECT_WORSHIPPER
        return DELTA_PROTECT_WORSHIPPER
    elseIf signalType == SIGNAL_DEFIANCE_MILESTONE
        return DELTA_DEFIANCE_MILESTONE
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos acknowledges the first open defiance.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos marks the player as steadfast.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos crowns the player in open defiance.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Talos as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Talos.")
    endIf
EndFunction
