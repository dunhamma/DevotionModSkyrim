;/
    PDV_Deity_Mara.psc
    PlayerDevotion - Mara, Mother-Goddess of mercy and compassion
    -----------------------------------------------------------------------
    OVERVIEW
    Mara is the Divine of love, mercy, and compassion. Imperial is the owner
    race (NATIVE); Nord (Nine Divines) and Breton (Knight's Road) reuse this
    shared ledger later.

    DESIGN NOTES
    - Mercy must be a concrete act (sparing/protecting a yielded or helpless
      target), never generic helping.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Mara extends PDV_DeityBase

Int Property SIGNAL_MERCY = 1101 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1102 AutoReadOnly

Float Property DELTA_CIVIC_SERVICE = 2.0 Auto
Float Property DELTA_MERCY = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Mara deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_MERCY
        return DELTA_MERCY
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Mara notes the first mercy shown.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Mara strengthens the player's compassion.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Mara works her compassion through the player.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Mara as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Mara.")
    endIf
EndFunction
