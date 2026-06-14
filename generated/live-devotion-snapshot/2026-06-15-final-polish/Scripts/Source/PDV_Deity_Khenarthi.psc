;/
    PDV_Deity_Khenarthi.psc
    PlayerDevotion - Khenarthi deity
    -----------------------------------------------------------------------
    Khajiit goddess of wind, sky, and the road home; one of the five focused
    lunar emphases. Rewards road-life cadence and caravan/community belonging
    without flattening into generic travel.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Khenarthi extends PDV_DeityBase

Int Property SIGNAL_ROAD_HOME = 601 AutoReadOnly     ; small repeatable road-home cadence pulse
Int Property SIGNAL_OPEN_ROAD = 602 AutoReadOnly     ; favorable open-road / weather travel
Int Property SIGNAL_CARAVAN_AID = 603 AutoReadOnly   ; caravan/community support, curated
Int Property SIGNAL_CARAVAN_HARM = 604 AutoReadOnly  ; anti-creed: harming caravan/kin

Float Property DELTA_ROAD_HOME = 0.4 Auto
Float Property DELTA_OPEN_ROAD = 0.3 Auto
Float Property DELTA_CARAVAN_AID = 1.5 Auto
Float Property DELTA_CARAVAN_HARM = -2.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_ROAD_HOME
        return DELTA_ROAD_HOME
    elseIf signalType == SIGNAL_OPEN_ROAD
        return DELTA_OPEN_ROAD
    elseIf signalType == SIGNAL_CARAVAN_AID
        return DELTA_CARAVAN_AID
    elseIf signalType == SIGNAL_CARAVAN_HARM
        return DELTA_CARAVAN_HARM
    endIf

    return 0.0
EndFunction
