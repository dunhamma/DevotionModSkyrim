;/ 
    PDV_Deity_Zen.psc
    PlayerDevotion - Bosmer Z'en path deity
    -----------------------------------------------------------------------
    Z'en is the foreground deity for The Exchange. This slice keeps the
    scoring contract explicit and justice-first rather than using Zenithar
    as a theological stand-in.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Zen extends PDV_DeityBase

Int Property SIGNAL_EXCHANGE = 401 AutoReadOnly
Int Property SIGNAL_SHARED_PACT_MEMORY = 402 AutoReadOnly
Int Property SIGNAL_CONFIRMATION = 403 AutoReadOnly

Float Property DELTA_EXCHANGE = 3.0 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_CONFIRMATION = 2.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_EXCHANGE
        return DELTA_EXCHANGE
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_CONFIRMATION
        return DELTA_CONFIRMATION
    endIf

    return 0.0
EndFunction
