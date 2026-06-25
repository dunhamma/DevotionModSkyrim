;/
    PDV_Deity_Xarxes.psc
    PlayerDevotion - Altmer Xarxes focus deity
    -----------------------------------------------------------------------
    Xarxes is an Altmer-owned secondary focus (one secondary at a time with
    Magnus). He is the keeper of records and ancestry: rewards study and
    preservation, record-keeping, and honoring the ancestral line. Generic
    activity without the lineage/record frame is rejected (see
    PDV_AltmerRewardRecords.spec.json rejectedHooks).

    Signal block 1900-1999 (freshly assigned; the Altmer manager handlers are
    telemetry stubs that do not yet route AwardCuratedSignal to Xarxes).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Xarxes extends PDV_DeityBase

Int Property SIGNAL_RECORD_KEEPING = 1901 AutoReadOnly      ; preserving / cataloguing knowledge and history
Int Property SIGNAL_LINEAGE_HONORED = 1902 AutoReadOnly     ; honoring ancestry / the ancestral record (curated)
Int Property SIGNAL_LEDGER_RESTORED = 1903 AutoReadOnly     ; recovering a lost record / writing a name into the long ledger
Int Property SIGNAL_SHARED_PACT_MEMORY = 1904 AutoReadOnly  ; small foundation-keeping pulse to the record
Int Property SIGNAL_RECORD_FALSIFIED = 1905 AutoReadOnly    ; anti-creed (medium): falsifying or defacing a record
Int Property SIGNAL_LINEAGE_REPUDIATED = 1906 AutoReadOnly  ; anti-creed (major): repudiating the ancestral line at a curated beat

Float Property DELTA_RECORD_KEEPING = 1.8 Auto
Float Property DELTA_LINEAGE_HONORED = 2.2 Auto
Float Property DELTA_LEDGER_RESTORED = 3.0 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_RECORD_FALSIFIED = -2.5 Auto
Float Property DELTA_LINEAGE_REPUDIATED = -3.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_RECORD_KEEPING
        return DELTA_RECORD_KEEPING
    elseIf signalType == SIGNAL_LINEAGE_HONORED
        return DELTA_LINEAGE_HONORED
    elseIf signalType == SIGNAL_LEDGER_RESTORED
        return DELTA_LEDGER_RESTORED
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_RECORD_FALSIFIED
        return DELTA_RECORD_FALSIFIED
    elseIf signalType == SIGNAL_LINEAGE_REPUDIATED
        return DELTA_LINEAGE_REPUDIATED
    endIf

    return 0.0
EndFunction
