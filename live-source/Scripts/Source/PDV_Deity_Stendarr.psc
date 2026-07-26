;/
    PDV_Deity_Stendarr.psc
    PlayerDevotion - Stendarr, God of mercy, justice, and righteous rule
    -----------------------------------------------------------------------
    OVERVIEW
    Stendarr is the Divine of mercy, justice, lawful order, and the defense
    of the weak. Imperial is the owner race (NATIVE); Breton (Knight's Road)
    reuses this shared ledger later.

    DESIGN NOTES
    - Mercy and lawful order must be concrete acts; ordinary bounty payment
      and lawful force against an active threat do not score or corrode.
    - Enforcer cruelty (major) and civic compromise (medium) corrode
      Stendarr; cruelty framed as order against a yielded/helpless target is
      the worst betrayal of his creed.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Stendarr extends PDV_DeityBase

Int Property SIGNAL_MERCY = 1301 AutoReadOnly
Int Property SIGNAL_LAWFUL_ORDER = 1302 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1303 AutoReadOnly

Float Property DELTA_MERCY = 3.0 Auto
Float Property DELTA_LAWFUL_ORDER = 2.5 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Stendarr deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_MERCY
        return DELTA_MERCY
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
            Debug.Trace("[PDV] Stendarr notes the first guard of the weak.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Stendarr steadies the player's guard.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Stendarr names the player a bulwark of mercy.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Stendarr as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Stendarr.")
    endIf
EndFunction
