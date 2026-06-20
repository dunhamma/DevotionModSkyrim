;/
    PDV_Deity_HoonDing.psc
    PlayerDevotion - Redguard (Yokudan) Make-Way God
    -----------------------------------------------------------------------
    OVERVIEW
    HoonDing, the Make-Way God of the Yokudan pantheon. The focused
    way-making / movement / one-handed-burst patron for Redguard players,
    emphasized under Forebear (adaptation / road).

    DESIGN NOTES
    - HoonDing manifests only in RARE honorable adversity / impossible-odds /
      curated make-way milestones. Generic combat, dungeon clears, and body
      count NEVER satisfy HoonDing.
    - WEEKLY CAP: at most one HoonDing make-way reward grant per 7 in-game
      days. The weekly cap is a MANAGER concern (PDV__ManagerQuest gates the
      curated make-way handler / reward grant before sending a signal here);
      this deity carries the honest piety pulse only. The deity intentionally
      does NOT own the cap so a single act keeps one anti-farm mechanism.
    - Make-way acts arrive as curated signals; this deity only scores curated
      signals (no raw combat / ScoreAction).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_HoonDing extends PDV_DeityBase

Int Property SIGNAL_MAKE_WAY = 2501 AutoReadOnly          ; rare curated make-way milestone (honorable adversity)
Int Property SIGNAL_MAKE_WAY_CHAMPION = 2502 AutoReadOnly ; impossible-odds make-way beat (larger, still weekly-capped)

Float Property DELTA_MAKE_WAY = 3.0 Auto
Float Property DELTA_MAKE_WAY_CHAMPION = 5.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] HoonDing deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_MAKE_WAY
        return DELTA_MAKE_WAY
    elseIf signalType == SIGNAL_MAKE_WAY_CHAMPION
        return DELTA_MAKE_WAY_CHAMPION
    endIf

    return 0.0
EndFunction
