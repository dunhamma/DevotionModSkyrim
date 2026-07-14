;/
    PDV_Deity_Kynareth.psc
    PlayerDevotion - Kynareth, Goddess of the heavens, wind, and nature
    -----------------------------------------------------------------------
    OVERVIEW
    Kynareth is the Divine of the sky, air, wind, and the natural world. She
    is distinct from Kyne (PDV_Deity_Kyne, the Nord storm deity). Imperial is
    the owner race (NATIVE); Breton (Green Way) and Bosmer (Y'ffre proxy,
    tolerated) reuse this shared ledger later.

    DESIGN NOTES
    - Open-sky / nature service is a curated act of travel, wilds, or open-air
      devotion, never generic outdoor presence.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Kynareth extends PDV_DeityBase

Int Property SIGNAL_OPEN_SKY = 1701 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1702 AutoReadOnly

Float Property DELTA_CIVIC_SERVICE = 2.0 Auto
Float Property DELTA_OPEN_SKY = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Kynareth deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_OPEN_SKY
        return DELTA_OPEN_SKY
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kynareth notes the first breath of open air.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kynareth sustains the player beneath the heavens.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Kynareth opens the whole sky to the player.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Kynareth as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Kynareth.")
    endIf
EndFunction
