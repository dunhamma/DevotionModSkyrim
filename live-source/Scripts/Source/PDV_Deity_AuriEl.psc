;/ 
    PDV_Deity_AuriEl.psc
    PlayerDevotion - Auri-El minimal foundation deity
    -----------------------------------------------------------------------
    OVERVIEW
    Auri-El is the minimum viable Altmer foundation deity for the coupled
    Talos/Auri-El proof slice. He is a real ledger target and patron option,
    but this slice does not attempt the full layered Altmer theology.

    DESIGN NOTES
    - "Always active" in this slice means seeded Altmer standing plus
      curated foundational signals, not a bypass of patron-only boon rules.
    - Auri-El carries no direct rivalry against Talos in this first pass.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_AuriEl extends PDV_DeityBase

Int Property SIGNAL_DAWN_ACKNOWLEDGMENT = 201 AutoReadOnly
Int Property SIGNAL_ORTHODOXY_AFFIRMATION = 202 AutoReadOnly
Int Property SIGNAL_ANCESTOR_SPINE = 203 AutoReadOnly

Float Property DELTA_DAWN_ACKNOWLEDGMENT = 1.0 Auto
Float Property DELTA_ORTHODOXY_AFFIRMATION = 3.0 Auto
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Auri-El deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DAWN_ACKNOWLEDGMENT
        return DELTA_DAWN_ACKNOWLEDGMENT
    elseIf signalType == SIGNAL_ORTHODOXY_AFFIRMATION
        return DELTA_ORTHODOXY_AFFIRMATION
    elseIf signalType == SIGNAL_ANCESTOR_SPINE
        return DELTA_ANCESTOR_SPINE
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El recognizes the player's returnward discipline.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El strengthens the ancestral claim.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El marks the player as an exemplar of return.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Auri-El as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Auri-El.")
    endIf
EndFunction

Bool Function ShouldSyncLegacyPatronBoons()
    return False
EndFunction
