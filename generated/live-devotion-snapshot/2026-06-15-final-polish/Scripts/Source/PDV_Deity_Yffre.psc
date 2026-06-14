;/ 
    PDV_Deity_Yffre.psc
    PlayerDevotion - Bosmer Y'ffre path deity
    -----------------------------------------------------------------------
    One shared Y'ffre ledger backs both Old Contract and Living Story.
    Path state changes exclusivity and signal interpretation rather than
    creating separate deity variants.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Yffre extends PDV_DeityBase

Int Property SIGNAL_PACT_POSITIVE = 301 AutoReadOnly
Int Property SIGNAL_LIVING_STORY = 302 AutoReadOnly
Int Property SIGNAL_PACT_VIOLATION = 303 AutoReadOnly
Int Property SIGNAL_RECOMMITMENT = 304 AutoReadOnly
Int Property SIGNAL_SHARED_PACT_MEMORY = 305 AutoReadOnly

Float Property DELTA_PACT_POSITIVE = 2.0 Auto
Float Property DELTA_LIVING_STORY = 2.5 Auto
Float Property DELTA_PACT_VIOLATION = -2.0 Auto
Float Property DELTA_RECOMMITMENT = 4.0 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_PACT_POSITIVE
        return DELTA_PACT_POSITIVE
    elseIf signalType == SIGNAL_LIVING_STORY
        return DELTA_LIVING_STORY
    elseIf signalType == SIGNAL_PACT_VIOLATION
        return DELTA_PACT_VIOLATION
    elseIf signalType == SIGNAL_RECOMMITMENT
        return DELTA_RECOMMITMENT
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    endIf

    return 0.0
EndFunction
