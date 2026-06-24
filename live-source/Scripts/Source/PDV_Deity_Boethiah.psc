;/
    PDV_Deity_Boethiah.psc
    PlayerDevotion - Dunmer Reclamation foreground deity (Boethiah)
    -----------------------------------------------------------------------
    Boethiah is a Dunmer-owned Good Daedra Reclamation foreground patron
    (one foreground focus at a time with Azura / Mephala). Boethiah rewards
    righteous struggle, proving oneself, and the honorable duel. This is the
    Reclamation Boethiah, NOT the Daedric Prince of generic cruelty or
    treachery: generic crime/cruelty is rejected (see
    PDV_DunmerRewardRecords.spec.json doubleRoute / creedViolation).

    Signal block 2000-2099 (freshly assigned; the Dunmer manager handlers
    HandleDunmerReclamationFocus / portable-prayer / home-rite are telemetry
    stubs that do not yet route AwardCuratedSignal to Boethiah).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Boethiah extends PDV_DeityBase

Int Property SIGNAL_RIGHTEOUS_STRUGGLE = 2001 AutoReadOnly  ; curated Boethiah Reclamation act / proving through struggle
Int Property SIGNAL_HONORABLE_DUEL = 2002 AutoReadOnly      ; winning an honorable test / duel (proving, not murder)
Int Property SIGNAL_SHARED_PACT_MEMORY = 2003 AutoReadOnly  ; small honest piety pulse from ancestor-substrate maintenance
Int Property SIGNAL_RECLAMATION_ABANDONED = 2005 AutoReadOnly ; anti-creed (major): turning from the Reclamations to a foreign bargain

Float Property DELTA_RIGHTEOUS_STRUGGLE = 3.0 Auto
Float Property DELTA_HONORABLE_DUEL = 2.2 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_RECLAMATION_ABANDONED = -6.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_RIGHTEOUS_STRUGGLE
        return DELTA_RIGHTEOUS_STRUGGLE
    elseIf signalType == SIGNAL_HONORABLE_DUEL
        return DELTA_HONORABLE_DUEL
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_RECLAMATION_ABANDONED
        return DELTA_RECLAMATION_ABANDONED
    endIf

    return 0.0
EndFunction
