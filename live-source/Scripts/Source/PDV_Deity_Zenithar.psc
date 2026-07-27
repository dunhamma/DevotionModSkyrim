;/
    PDV_Deity_Zenithar.psc
    PlayerDevotion - Zenithar, God of work, commerce, and honest labor
    -----------------------------------------------------------------------
    OVERVIEW
    Zenithar is the Divine of honest work, fair trade, and commerce. He is
    distinct from Z'en (PDV_Deity_Zen, the Bosmer Exchange deity). Imperial
    is the owner race (NATIVE).

    DESIGN NOTES
    - Honest work must be a whitelisted trade/labor favor, never a grindable
      crafting loop; diminishing returns belong on the manager hook.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Zenithar extends PDV_DeityBase

Int Property SIGNAL_HONEST_WORK = 1401 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1402 AutoReadOnly

Float Property DELTA_HONEST_WORK = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Zenithar deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_HONEST_WORK
        return DELTA_HONEST_WORK
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Zenithar notes the first fair dealing.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Zenithar favors the player's honest labor.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Zenithar lets prosperity follow the player's work.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Zenithar as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Zenithar.")
    endIf
EndFunction
