;/
    PDV_Deity_Leki.psc
    PlayerDevotion - Redguard (Yokudan) Saint of the Spirit Sword
    -----------------------------------------------------------------------
    OVERVIEW
    Leki, the Lady of Swords / ataxia of the Sword-Singers. The focused
    sword-singing / one-handed / critical-conduct patron for Redguard
    players, emphasized under Forebear and Crown (sword form / honor).

    DESIGN NOTES
    - Leki rewards martial CONDUCT and skilled sword-singing form, NOT raw
      kills. Requires conduct/context (duel, sword form, honorable defeat of
      a worthy foe). Generic combat and body count NEVER satisfy Leki.
    - The conduct gate is a MANAGER concern (PDV__ManagerQuest validates the
      duel / sword-form / honorable-defeat context, with a daily cap, before
      sending a curated signal here); this deity carries the honest piety
      pulse only and does not own the gate, keeping one anti-farm mechanism
      per act.
    - Conduct acts arrive as curated signals; this deity only scores curated
      signals (no raw combat / ScoreAction).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Leki extends PDV_DeityBase

Int Property SIGNAL_SWORD_SINGING = 2601 AutoReadOnly  ; sword-singing form / duel conduct (context-gated)
Int Property SIGNAL_HONORABLE_DUEL = 2602 AutoReadOnly ; honorable defeat of a worthy foe (larger conduct beat)

Float Property DELTA_SWORD_SINGING = 2.0 Auto
Float Property DELTA_HONORABLE_DUEL = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Leki deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_SWORD_SINGING
        return DELTA_SWORD_SINGING
    elseIf signalType == SIGNAL_HONORABLE_DUEL
        return DELTA_HONORABLE_DUEL
    endIf

    return 0.0
EndFunction
