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

Float Property DELTA_FALLEN_GOD_ORTHODOXY = 1.5 Auto
Float Property DELTA_ALTMER_ORTHODOX_PRESSURE = 1.5 Auto

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
    endIf

    return 0.0
EndFunction
