;/
    PDV_Deity_Akatosh.psc
    PlayerDevotion - Akatosh, chief of the Nine Divines
    -----------------------------------------------------------------------
    OVERVIEW
    Akatosh is the Dragon God of Time and head of the Nine Divines. Imperial
    is the owner race (NATIVE); Nord (Nine Divines) and Breton (Knight's
    Road) reuse this shared ledger later.

    DESIGN NOTES
    - Civic devotion is concrete service feeding the active patron, never
      faction rank or generic temple attendance.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Akatosh extends PDV_DeityBase

Int Property SIGNAL_CIVIC_SERVICE = 1000 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1001 AutoReadOnly

Float Property DELTA_CIVIC_SERVICE = 2.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Akatosh deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_CIVIC_SERVICE
        return DELTA_CIVIC_SERVICE
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Akatosh marks the first keeping of the Covenant.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Akatosh affirms the player's steadfast service.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Akatosh names the player an exemplar of the Covenant.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Akatosh as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Akatosh.")
    endIf
EndFunction
