;/
    PDV_Deity_Stuhn.psc
    PlayerDevotion - Nord Old Ways shield-thane of ransom and justice
    -----------------------------------------------------------------------
    OVERVIEW
    Concrete implementation of PDV_DeityBase for Stuhn, the Nordic
    shield-thane, god of ransom, just spoils, and the protection of honored
    bonds; brother of Tsun. NEW Nord-owned focusable deity in the reworked
    Old Ways lane.

    DESIGN NOTES
    - Stance row is simple: Nord = NATIVE, everyone else = FOREIGN.
      No TABOO/HOSTILE entries, no rivalry list.
    - Stuhn's domain is mercy and just dealing, NOT generic combat. His
      curated signals are mercy beats: sparing/ransoming a defeated foe,
      taking only just spoils, and protecting an honored bond. There is no
      per-kill drip -- Stuhn would never reward the kill itself -- so
      ScoreAction returns 0 and all piety is curated mercy.
    - Creed-violation negatives are OMITTED in V1: per the Nord reward spec,
      Stuhn cruelty/plunder/betrayal reads as fiction-only texture and
      gentle neglect drift, with no concrete authored trigger yet.
    - T3 capstone carries the scripted signature "Just Spoils, Honored
      Bonds" (an ally-defense + armor shield triggered by sparing/freeing a
      captive); that lives in the reward/signature layer, not in this
      scoring script.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Stuhn extends PDV_DeityBase

Int Property SIGNAL_MERCY_GRANTED = 3100 AutoReadOnly
Int Property SIGNAL_JUST_SPOILS = 3101 AutoReadOnly
Int Property SIGNAL_PROTECT_BOND = 3102 AutoReadOnly

Float Property DELTA_MERCY_GRANTED = 2.5 Auto
Float Property DELTA_JUST_SPOILS = 1.5 Auto
Float Property DELTA_PROTECT_BOND = 3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Stuhn deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_MERCY_GRANTED
        return DELTA_MERCY_GRANTED
    elseIf signalType == SIGNAL_JUST_SPOILS
        return DELTA_JUST_SPOILS
    elseIf signalType == SIGNAL_PROTECT_BOND
        return DELTA_PROTECT_BOND
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Stuhn marks the player's first act of mercy.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Stuhn counts the player a keeper of honored bonds.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Stuhn holds the line for the Champion of just spoils.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Stuhn as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Stuhn.")
    endIf
EndFunction
