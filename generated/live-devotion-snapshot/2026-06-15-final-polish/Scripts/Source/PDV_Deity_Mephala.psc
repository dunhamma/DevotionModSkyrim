;/
    PDV_Deity_Mephala.psc
    PlayerDevotion - Dunmer Reclamation foreground deity (Mephala)
    -----------------------------------------------------------------------
    Mephala is a Dunmer-owned Good Daedra Reclamation foreground patron
    (one foreground focus at a time with Azura / Boethiah). Mephala rewards
    secrets kept, the weaving of webs of influence, and cunning. This is the
    Reclamation Mephala, NOT a patron of generic crime: generic crime/theft
    is rejected (see PDV_DunmerRewardRecords.spec.json doubleRoute /
    creedViolation).

    Signal block 2100-2199 (freshly assigned; the Dunmer manager handlers
    HandleDunmerReclamationFocus / portable-prayer / home-rite are telemetry
    stubs that do not yet route AwardCuratedSignal to Mephala).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Mephala extends PDV_DeityBase

Int Property SIGNAL_SECRET_KEPT = 2101 AutoReadOnly         ; curated Mephala Reclamation act / a secret rightly kept
Int Property SIGNAL_WEB_WOVEN = 2102 AutoReadOnly           ; weaving influence / a plot resolved by cunning, not brute force
Int Property SIGNAL_SHARED_PACT_MEMORY = 2103 AutoReadOnly  ; small honest piety pulse from ancestor-substrate maintenance
Int Property SIGNAL_SECRET_BETRAYED = 2104 AutoReadOnly     ; anti-creed (medium): carelessly exposing a kept secret / clumsy crime
Int Property SIGNAL_RECLAMATION_ABANDONED = 2105 AutoReadOnly ; anti-creed (major): turning from the Reclamations to a foreign bargain

Float Property DELTA_SECRET_KEPT = 3.0 Auto
Float Property DELTA_WEB_WOVEN = 2.2 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_SECRET_BETRAYED = -3.0 Auto
Float Property DELTA_RECLAMATION_ABANDONED = -6.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_SECRET_KEPT
        return DELTA_SECRET_KEPT
    elseIf signalType == SIGNAL_WEB_WOVEN
        return DELTA_WEB_WOVEN
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_SECRET_BETRAYED
        return DELTA_SECRET_BETRAYED
    elseIf signalType == SIGNAL_RECLAMATION_ABANDONED
        return DELTA_RECLAMATION_ABANDONED
    endIf

    return 0.0
EndFunction
