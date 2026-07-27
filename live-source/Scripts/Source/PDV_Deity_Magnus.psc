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
Int Property SIGNAL_SHARED_PACT_MEMORY = 1804 AutoReadOnly  ; small foundation-keeping pulse to the arts

Float Property DELTA_DISCIPLINED_STUDY = 1.8 Auto
Float Property DELTA_MAGIC_MILESTONE = 1.5 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto

; Contract-declared tuning knob for the ancestral-spine lane (pdv_verify asserts
; DELTA_ANCESTOR_SPINE = 1.0 on this deity). Currently unread here -- the spine
; scoring for this lane is specced, not yet wired -- so do NOT "clean it up": the
; 1.0.4 Altmer Spine wire is what will read it, and deleting it now would throw
; away the intended value. Azura / Malacath / Tu'whacca already return theirs.
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DISCIPLINED_STUDY
        return DELTA_DISCIPLINED_STUDY
    elseIf signalType == SIGNAL_MAGIC_MILESTONE
        return DELTA_MAGIC_MILESTONE
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    endIf

    return 0.0
EndFunction
