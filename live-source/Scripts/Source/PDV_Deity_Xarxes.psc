;/
    PDV_Deity_Xarxes.psc
    PlayerDevotion - Altmer Xarxes focus deity
    -----------------------------------------------------------------------
    Xarxes is an Altmer-owned secondary focus (one secondary at a time with
    Magnus). He is the keeper of records and ancestry: rewards study and
    preservation, record-keeping, and honoring the ancestral line. Generic
    activity without the lineage/record frame is rejected (see
    PDV_AltmerRewardRecords.spec.json rejectedHooks).

    Signal block 1900-1999. Both signals are wired and routing today:
    LINEAGE_HONORED from AwardAltmerOrthodoxSignal when the reason names Xarxes
    (finite: bounded by the 3 curated lineage books), and SHARED_PACT_MEMORY from
    AwardActiveAltmerHeritageMemorySignal when Xarxes is the active patron.
    Corrected 2026-08-02: this block previously called the Altmer handlers
    telemetry stubs, which has been false since at least 1.0.3.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Xarxes extends PDV_DeityBase

Int Property SIGNAL_LINEAGE_HONORED = 1902 AutoReadOnly     ; honoring ancestry / the ancestral record (curated)
Int Property SIGNAL_SHARED_PACT_MEMORY = 1904 AutoReadOnly  ; small foundation-keeping pulse to the record
; P5 (2026-08-03). Xarxes's only RENEWABLE curated lane. 1902 is bounded by three curated books
; and 1904 needs him as active patron, so a non-patron follower previously had no curated income
; at all once the books were read. Id 3120 is in the 3110-3200 block (Syrabane holds 3110-3114;
; the MCM debug slider ceiling is 3200).
Int Property SIGNAL_RECORD_KEPT = 3120 AutoReadOnly         ; dawn cadence: the ledger notes yesterday's study

Float Property DELTA_LINEAGE_HONORED = 2.2 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_RECORD_KEPT = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_LINEAGE_HONORED
        return DELTA_LINEAGE_HONORED
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_RECORD_KEPT
        return DELTA_RECORD_KEPT
    endIf

    return 0.0
EndFunction
