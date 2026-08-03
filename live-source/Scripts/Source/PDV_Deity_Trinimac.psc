;/
    PDV_Deity_Trinimac.psc
    PlayerDevotion - Trinimac, the fallen god (shared Orc / Altmer pressure)
    -----------------------------------------------------------------------
    OVERVIEW
    Trinimac is NOT a steady devotional lane. He is rare ideological
    pressure: the fallen-god tension behind Orc identity (Malacath is
    Trinimac transformed) and an orthodox-elven pressure for the Altmer.
    This record exists so that pressure and recognition can be routed and
    so future content has a focusable anchor; in V1 it grants NO always-on
    boon family.

    SHARED RECORD
    Orc OWNS this record (created first); the Altmer path reuses it and
    adds its own stance as orthodoxy pressure. Per-race meaning is the
    manager's concern via stance, not this script.

    DESIGN NOTES
    - Minimal signals by design: a fallen-god orthodoxy beat, an Altmer
      orthodox-pressure beat, and an apostasy/rejection loss. No forge,
      city, or service faucet lives here -- that is all Malacath's spine.
    - Keep this lane sparse: Trinimac must never read as a second Orc
      reward substrate or a steady Altmer patron lane.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Trinimac extends PDV_DeityBase

; --- Rare ideological-pressure signals (no steady faucet) ---
Int Property SIGNAL_FALLEN_GOD_ORTHODOXY = 2301 AutoReadOnly  ; fallen-god / Trinimac-as-Malacath orthodoxy beat
Int Property SIGNAL_ALTMER_ORTHODOX_PRESSURE = 2302 AutoReadOnly ; orthodox-elven pressure beat (Altmer shared use)

; P7 (2026-08-03). Trinimac's first RENEWABLE curated lane. 2301 fires from three one-shot books
; and the crisis beat; 2302 rides Xarxes's books and so is capped at three per playthrough. This is
; the only source that keeps paying. Band-keyed on ThalmorAlignment >= 70, which also gives that
; track a consumer -- it otherwise pins at +100 late game and drives nothing but a Lorkhan
; multiplier. Id 3122 is in the 3110-3200 block (Syrabane 3110-3114, Xarxes 3120, Magnus 3121).
Int Property SIGNAL_CIVILIZATION_DEFENDED = 3122 AutoReadOnly  ; a foe of the elven project put down, at orthodox alignment

Float Property DELTA_FALLEN_GOD_ORTHODOXY = 1.5 Auto
Float Property DELTA_ALTMER_ORTHODOX_PRESSURE = 1.5 Auto
Float Property DELTA_CIVILIZATION_DEFENDED = 1.2 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Trinimac deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_FALLEN_GOD_ORTHODOXY
        return DELTA_FALLEN_GOD_ORTHODOXY
    elseIf signalType == SIGNAL_ALTMER_ORTHODOX_PRESSURE
        return DELTA_ALTMER_ORTHODOX_PRESSURE
    elseIf signalType == SIGNAL_CIVILIZATION_DEFENDED
        return DELTA_CIVILIZATION_DEFENDED
    endIf

    return 0.0
EndFunction
