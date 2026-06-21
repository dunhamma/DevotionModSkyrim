;/
    PDV_Deity_Alkosh.psc
    PlayerDevotion - Alkosh deity
    -----------------------------------------------------------------------
    The Dragon King of Time; one of the five focused Khajiit lunar emphases.
    Alkosh is also venerated in the wider First Era / Yokudan-adjacent sphere,
    so this deity may later be shared with Redguard content (reconcile in
    Phase 2). Rewards order-keeping and rare named-dragon beats; aiding the
    dragon cult or sowing chaos is anti-creed.

    Note: dragon kills are not scored through ScoreAction because PDV_ActionRouter
    does not classify dragons; named-dragon recognition routes as a curated signal.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Alkosh extends PDV_DeityBase

Int Property SIGNAL_DRAGON_ORDER = 901 AutoReadOnly  ; small repeatable order-keeping pulse
Int Property SIGNAL_NAMED_DRAGON = 902 AutoReadOnly  ; named dragon slain / cosmic-order beat, curated
Int Property SIGNAL_CHAOS_AID = 903 AutoReadOnly     ; anti-creed: aiding dragon cult / sowing chaos

Float Property DELTA_DRAGON_ORDER = 0.4 Auto
Float Property DELTA_NAMED_DRAGON = 2.0 Auto
Float Property DELTA_CHAOS_AID = -3.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DRAGON_ORDER
        return DELTA_DRAGON_ORDER
    elseIf signalType == SIGNAL_NAMED_DRAGON
        return DELTA_NAMED_DRAGON
    elseIf signalType == SIGNAL_CHAOS_AID
        return DELTA_CHAOS_AID
    endIf

    return 0.0
EndFunction
