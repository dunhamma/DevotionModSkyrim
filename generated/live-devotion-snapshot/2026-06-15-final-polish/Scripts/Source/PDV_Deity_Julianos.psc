;/
    PDV_Deity_Julianos.psc
    PlayerDevotion - Julianos, God of wisdom, logic, and law
    -----------------------------------------------------------------------
    OVERVIEW
    Julianos is the Divine of wisdom, logic, literature, and law. Imperial is
    the owner race (NATIVE); Breton (Hidden Art, lawful) reuses this shared
    ledger later.

    DESIGN NOTES
    - Lawful order is a curated court/Legion/lawful-resolution act, never
      ordinary bounty payment or generic lawfulness.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Julianos extends PDV_DeityBase

Int Property SIGNAL_CIVIC_SERVICE = 1600 AutoReadOnly
Int Property SIGNAL_LAWFUL_ORDER = 1601 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1602 AutoReadOnly

Float Property DELTA_CIVIC_SERVICE = 2.0 Auto
Float Property DELTA_LAWFUL_ORDER = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Julianos deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_CIVIC_SERVICE
        return DELTA_CIVIC_SERVICE
    elseIf signalType == SIGNAL_LAWFUL_ORDER
        return DELTA_LAWFUL_ORDER
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Julianos notes the first ordering of law.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Julianos sharpens the player's disciplined mind.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Julianos grants the player the insight of law and lore.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Julianos as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Julianos.")
    endIf
EndFunction
