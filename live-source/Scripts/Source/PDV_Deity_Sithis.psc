;/
    PDV_Deity_Sithis.psc
    PlayerDevotion - Argonian high-threshold Void tertiary patron
    -----------------------------------------------------------------------
    Sithis is the high-threshold tertiary Void patron for the Argonian path.
    He is deliberately NOT the obvious Argonian route: Void signals are only
    meaningfully scored after the substrate reports IsVoidFullyActive()
    (>= 3 significant Void signals across separate beats, enforced by
    PDV_Substrate_ArgonianHist.VoidActivationSignalsRequired). That gate is
    enforced upstream in the substrate / manager; this deity script just
    returns the per-signal delta when asked.

    The universal piety layer stays Hist-honest even on the Void route -- the
    Hist +1 pulse still fires for Void acts; this Sithis score is the extra
    tertiary credit that only matters once the Void is fully active.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Sithis extends PDV_DeityBase

Int Property SIGNAL_VOID_THRESHOLD = 2801 AutoReadOnly  ; curated death-facing / Void threshold signal (post-activation)

Float Property DELTA_VOID_THRESHOLD = 2.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_VOID_THRESHOLD
        return DELTA_VOID_THRESHOLD
    endIf

    return 0.0
EndFunction
