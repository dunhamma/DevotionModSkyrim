;/
    PDV_Deity_Hist.psc
    PlayerDevotion - Argonian Hist substrate-pulse patron
    -----------------------------------------------------------------------
    The Hist is the scripted patron target for the Argonian double-route.
    The reward gating itself lives on PDV_Substrate_ArgonianHist; this deity
    only carries a small honest piety pulse so the universal piety layer
    (decay / neglect / creed-loss) stays honest under the substrate-led
    design. Each accepted devotional act (Hist maintenance, bed-of-choice
    return, chosen-people support) records on the substrate AND sends a small
    +1 pulse here. The substrate side and the pulse side never share an
    anti-farm magnitude: the substrate uses ConsumeDailyRepeatMultiplier and
    this pulse uses ScoreRepeatableAction.

    Hist creed-loss (abandonment / corruption / Void overreach) is curated
    medium/major only -- no minor-tier loss.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Hist extends PDV_DeityBase

Int Property SIGNAL_HIST_PULSE = 2701 AutoReadOnly       ; small honest +1 pulse for any accepted Argonian double-route act
Int Property SIGNAL_HIST_ABANDONMENT = 2702 AutoReadOnly ; anti-creed (medium): extended Hist neglect past grace into Distant
Int Property SIGNAL_HIST_CORRUPTION = 2703 AutoReadOnly  ; anti-creed (major): domination pressure driving posture Corrupted
Int Property SIGNAL_VOID_OVERREACH = 2704 AutoReadOnly   ; anti-creed (major): leaning into Void while Hist maintenance lapsed

Float Property DELTA_HIST_PULSE = 1.0 Auto
Float Property DELTA_HIST_ABANDONMENT = -4.0 Auto
Float Property DELTA_HIST_CORRUPTION = -8.0 Auto
Float Property DELTA_VOID_OVERREACH = -6.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_HIST_PULSE
        return DELTA_HIST_PULSE
    elseIf signalType == SIGNAL_HIST_ABANDONMENT
        return DELTA_HIST_ABANDONMENT
    elseIf signalType == SIGNAL_HIST_CORRUPTION
        return DELTA_HIST_CORRUPTION
    elseIf signalType == SIGNAL_VOID_OVERREACH
        return DELTA_VOID_OVERREACH
    endIf

    return 0.0
EndFunction
