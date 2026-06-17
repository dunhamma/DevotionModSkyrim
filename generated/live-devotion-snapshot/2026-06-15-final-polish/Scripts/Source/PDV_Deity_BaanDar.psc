;/ 
    PDV_Deity_BaanDar.psc
    PlayerDevotion - Bosmer Baan Dar path deity
    -----------------------------------------------------------------------
    Baan Dar is the foreground deity for The Bandit Road. The first slice
    rewards survival-cunning and road-life reversal without flattening the
    lane into generic stealth crime.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_BaanDar extends PDV_DeityBase

Int Property SIGNAL_BANDIT_ROAD = 501 AutoReadOnly
Int Property SIGNAL_SHARED_PACT_MEMORY = 502 AutoReadOnly
Int Property SIGNAL_CONFIRMATION = 503 AutoReadOnly
; Khajiit emphasis usage (Baan Dar is shared Bosmer + Khajiit; per-race stance).
Int Property SIGNAL_BETRAYAL = 504 AutoReadOnly         ; anti-creed: betraying an outsider/ally who trusted you
Int Property SIGNAL_ROAD_TRICK = 505 AutoReadOnly       ; small repeatable Khajiit road-trick / survival-reversal pulse

Float Property DELTA_BANDIT_ROAD = 3.0 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_CONFIRMATION = 2.0 Auto
Float Property DELTA_BETRAYAL = -2.0 Auto
Float Property DELTA_ROAD_TRICK = 0.4 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_BANDIT_ROAD
        return DELTA_BANDIT_ROAD
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_CONFIRMATION
        return DELTA_CONFIRMATION
    elseIf signalType == SIGNAL_BETRAYAL
        return DELTA_BETRAYAL
    elseIf signalType == SIGNAL_ROAD_TRICK
        return DELTA_ROAD_TRICK
    endIf

    return 0.0
EndFunction
