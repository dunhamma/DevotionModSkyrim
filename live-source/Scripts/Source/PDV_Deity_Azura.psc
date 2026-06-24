;/
    PDV_Deity_Azura.psc
    PlayerDevotion - Azura / Azurah deity
    -----------------------------------------------------------------------
    Shared deity quest. Dunmer venerate Azura as a Good Daedra (Reclamation
    focus); Khajiit venerate Azurah, the mother of the Khajiit and one of the
    five focused lunar emphases. One ledger, per-race stance.

    Phase 1 pilot scope wires the Khajiit emphasis signals (moon observance
    pulse, threshold rite, shadow-drift desecration). Dunmer Reclamation
    signals are added in Phase 2 propagation; do not duplicate this deity.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Azura extends PDV_DeityBase

; Khajiit emphasis signals (701-series)
Int Property SIGNAL_MOON_OBSERVANCE = 701 AutoReadOnly  ; small repeatable lunar-observance pulse
Int Property SIGNAL_THRESHOLD_RITE = 702 AutoReadOnly    ; dawn/dusk / major transition, curated
Int Property SIGNAL_DESECRATION = 703 AutoReadOnly       ; anti-creed: shadow-drift / desecration
Int Property SIGNAL_DUNMER_TWILIGHT_RITE = 704 AutoReadOnly ; Dunmer dawn/dusk shared Reclamation observance
Int Property SIGNAL_ANCESTOR_SPINE = 705 AutoReadOnly    ; Dunmer ancestor-spine prayer/home piety pulse

Float Property DELTA_MOON_OBSERVANCE = 0.4 Auto
Float Property DELTA_THRESHOLD_RITE = 1.5 Auto
Float Property DELTA_DESECRATION = -2.5 Auto
Float Property DELTA_DUNMER_TWILIGHT_RITE = 0.25 Auto
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_MOON_OBSERVANCE
        return DELTA_MOON_OBSERVANCE
    elseIf signalType == SIGNAL_THRESHOLD_RITE
        return DELTA_THRESHOLD_RITE
    elseIf signalType == SIGNAL_DESECRATION
        return DELTA_DESECRATION
    elseIf signalType == SIGNAL_DUNMER_TWILIGHT_RITE
        return DELTA_DUNMER_TWILIGHT_RITE
    elseIf signalType == SIGNAL_ANCESTOR_SPINE
        return DELTA_ANCESTOR_SPINE
    endIf

    return 0.0
EndFunction
