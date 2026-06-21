;/
    PDV_Deity_Dibella.psc
    PlayerDevotion - Dibella, Goddess of beauty, art, and grace
    -----------------------------------------------------------------------
    OVERVIEW
    Dibella is the Divine of beauty, art, persuasion, and grace. Imperial is
    the owner race (NATIVE).

    DESIGN NOTES
    - Grace is a curated act of beauty/art/persuasion in service, never a
      generic interaction faucet.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Dibella extends PDV_DeityBase

Int Property SIGNAL_CIVIC_SERVICE = 1500 AutoReadOnly
Int Property SIGNAL_GRACE = 1501 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1502 AutoReadOnly

Float Property DELTA_CIVIC_SERVICE = 2.0 Auto
Float Property DELTA_GRACE = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Dibella deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_CIVIC_SERVICE
        return DELTA_CIVIC_SERVICE
    elseIf signalType == SIGNAL_GRACE
        return DELTA_GRACE
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Dibella notes the first touch of grace.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Dibella lends the player her persuasion.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Dibella moves her inspiration through the player.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Dibella as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Dibella.")
    endIf
EndFunction
