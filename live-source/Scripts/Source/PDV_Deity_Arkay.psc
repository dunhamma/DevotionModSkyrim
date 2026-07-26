;/
    PDV_Deity_Arkay.psc
    PlayerDevotion - Arkay, keeper of the cycle of life and death
    -----------------------------------------------------------------------
    OVERVIEW
    Arkay is the Divine of burial, the cycle of life and death, and the ward
    against necromancy. Imperial is the owner race (NATIVE); Nord (Nine
    Divines), Breton (Knight's Road), and Redguard (Tu'whacca fallback death
    infrastructure) reuse this shared ledger later.

    DESIGN NOTES
    - Death-duty must be a concrete burial / anti-necromancer act, never
      ordinary undead combat.
    - Civic compromise (medium) and abandoning a death-rite duty (medium)
      corrode Arkay; ordinary inconvenience does not.
    - Curated civic signals only; the Divines have no kill-based ScoreAction.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Arkay extends PDV_DeityBase

Int Property SIGNAL_DEATH_DUTY = 1201 AutoReadOnly
Int Property SIGNAL_PATRON_CIVIC_FAVOR = 1202 AutoReadOnly

Float Property DELTA_DEATH_DUTY = 3.0 Auto
Float Property DELTA_PATRON_CIVIC_FAVOR = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Arkay deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DEATH_DUTY
        return DELTA_DEATH_DUTY
    elseIf signalType == SIGNAL_PATRON_CIVIC_FAVOR
        return DELTA_PATRON_CIVIC_FAVOR
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Arkay notes the first keeping of the vigil.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Arkay strengthens the player's vigil over the cycle.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Arkay sets the player between the living and the grave.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Arkay as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Arkay.")
    endIf
EndFunction
