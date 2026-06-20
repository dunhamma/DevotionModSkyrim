;/
    PDV_Deity_HoonDing.psc
    PlayerDevotion - Redguard (Yokudan) Make-Way God
    -----------------------------------------------------------------------
    OVERVIEW
    HoonDing, the Make-Way God of the Yokudan pantheon. The focused
    way-making / movement / one-handed-burst patron for Redguard players,
    emphasized under Forebear (adaptation / road).

    DESIGN NOTES
    - HoonDing manifests only in curated make-way BREAKTHROUGH moments. Generic
      combat, dungeon clears, and body count NEVER satisfy HoonDing. (V1 make-way
      = the player's own dragon kills; named bosses / quest milestones / final
      bosses are a curated-FormList follow-up.)
    - ANTI-FARM is a MANAGER concern: PDV__ManagerQuest.HandleHoonDingBreakthroughKill
      gates qualification and applies a daily soft-decay on dragons (the old blunt
      weekly cap is retired). This deity carries the honest piety pulse only and
      does NOT own the cap, so a single act keeps one anti-farm mechanism.
    - Make-way acts arrive as curated signals; this deity only scores curated
      signals (no raw combat / ScoreAction).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_HoonDing extends PDV_DeityBase

Int Property SIGNAL_MAKE_WAY = 2501 AutoReadOnly          ; curated make-way: breakthrough kill (V1 dragons; named-boss / milestone follow-up)

Float Property DELTA_MAKE_WAY = 3.0 Auto

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
    endIf

    return 0.0
EndFunction
