;/
    PDV_Deity_Rajhin.psc
    PlayerDevotion - Rajhin deity
    -----------------------------------------------------------------------
    The Purring Liar, Khajiit god of thieves; one of the five focused lunar
    emphases. Rewards elegant, legend-making theft, not petty crime spam.
    Botched or innocent-harming theft is anti-creed.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Rajhin extends PDV_DeityBase

Int Property SIGNAL_ELEGANT_THEFT = 801 AutoReadOnly  ; small repeatable artful-theft pulse
Int Property SIGNAL_LEGEND_MADE = 802 AutoReadOnly    ; notable heist / legend beat, curated
Int Property SIGNAL_BOTCHED_THEFT = 803 AutoReadOnly  ; anti-creed: clumsy / innocent-harming theft

Float Property DELTA_ELEGANT_THEFT = 0.4 Auto
Float Property DELTA_LEGEND_MADE = 1.5 Auto
Float Property DELTA_BOTCHED_THEFT = -2.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_ELEGANT_THEFT
        return DELTA_ELEGANT_THEFT
    elseIf signalType == SIGNAL_LEGEND_MADE
        return DELTA_LEGEND_MADE
    elseIf signalType == SIGNAL_BOTCHED_THEFT
        return DELTA_BOTCHED_THEFT
    endIf

    return 0.0
EndFunction
