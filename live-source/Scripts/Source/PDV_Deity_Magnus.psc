;/
    PDV_Deity_Magnus.psc
    PlayerDevotion - Altmer Magnus focus deity
    -----------------------------------------------------------------------
    Magnus is an Altmer-owned secondary focus (one secondary at a time with
    Xarxes). He is the architect of magic: rewards disciplined study, magic
    milestones reached with restraint, and the recovery of arcane knowledge.
    Generic spellcasting spam or raw skill gain without context is rejected
    (see PDV_AltmerRewardRecords.spec.json rejectedHooks).

    Signal block 1800-1899 (freshly assigned; the Altmer manager handlers are
    telemetry stubs that do not yet route AwardCuratedSignal to Magnus).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Magnus extends PDV_DeityBase

Int Property SIGNAL_DISCIPLINED_STUDY = 1801 AutoReadOnly   ; curated rare-text / threshold study milestone
Int Property SIGNAL_MAGIC_MILESTONE = 1802 AutoReadOnly     ; magic milestone reached with restraint (study-framed)
Int Property SIGNAL_ARCANE_RECOVERY = 1803 AutoReadOnly     ; recovering / restoring lost arcane knowledge
Int Property SIGNAL_SHARED_PACT_MEMORY = 1804 AutoReadOnly  ; small foundation-keeping pulse to the arts
Int Property SIGNAL_ARTS_PROFANED = 1805 AutoReadOnly       ; anti-creed (medium): degrading the arts to spectacle / careless magic
Int Property SIGNAL_KNOWLEDGE_DESTROYED = 1806 AutoReadOnly ; anti-creed (major): destroying arcane knowledge at a curated beat
Int Property SIGNAL_ANCESTOR_SPINE = 1807 AutoReadOnly      ; Breton mixed-inheritance spine pulse

Float Property DELTA_DISCIPLINED_STUDY = 1.8 Auto
Float Property DELTA_MAGIC_MILESTONE = 1.5 Auto
Float Property DELTA_ARCANE_RECOVERY = 3.0 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_ARTS_PROFANED = -2.5 Auto
Float Property DELTA_KNOWLEDGE_DESTROYED = -3.0 Auto
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DISCIPLINED_STUDY
        return DELTA_DISCIPLINED_STUDY
    elseIf signalType == SIGNAL_MAGIC_MILESTONE
        return DELTA_MAGIC_MILESTONE
    elseIf signalType == SIGNAL_ARCANE_RECOVERY
        return DELTA_ARCANE_RECOVERY
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_ARTS_PROFANED
        return DELTA_ARTS_PROFANED
    elseIf signalType == SIGNAL_KNOWLEDGE_DESTROYED
        return DELTA_KNOWLEDGE_DESTROYED
    elseIf signalType == SIGNAL_ANCESTOR_SPINE
        return DELTA_ANCESTOR_SPINE
    endIf

    return 0.0
EndFunction
