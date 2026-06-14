;/
    PDV_Deity_Tsun.psc
    PlayerDevotion - Nord Old Ways god of trials and adversity
    -----------------------------------------------------------------------
    OVERVIEW
    Concrete implementation of PDV_DeityBase for Tsun, the Nordic god of
    trials, adversity, and endurance; shield-thane of Shor who guards the
    whalebone bridge to Sovngarde. NEW Nord-owned focusable deity in the
    reworked Old Ways lane.

    DESIGN NOTES
    - Stance row is simple: Nord = NATIVE, everyone else = FOREIGN.
      No TABOO/HOSTILE entries, no rivalry list.
    - Tsun rewards trials weathered, not generic combat: his curated signals
      are adversity-survived beats (a hard fight at a disadvantage endured,
      a long ordeal completed) and an endurance-vigil milestone. There is
      no per-kill drip -- Tsun's domain is surviving the trial, not the
      killing, so ScoreAction returns 0 and all piety is curated.
    - Creed-violation negatives are OMITTED in V1: per the Nord reward spec,
      Tsun cowardice/oathbreaking reads as fiction-only texture and gentle
      neglect drift, with no concrete authored trigger yet.
    - T3 capstone carries the scripted signature "The Shield-Thane's Trial"
      (a 24h stamina-endurance vigil after a severe-disadvantage fight);
      that lives in the reward/signature layer, not in this scoring script.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Tsun extends PDV_DeityBase

Int Property SIGNAL_TRIAL_ENDURED = 3000 AutoReadOnly
Int Property SIGNAL_ADVERSITY_SURVIVED = 3001 AutoReadOnly
Int Property SIGNAL_ENDURANCE_VIGIL = 3002 AutoReadOnly

Float Property DELTA_TRIAL_ENDURED = 2.0 Auto
Float Property DELTA_ADVERSITY_SURVIVED = 2.5 Auto
Float Property DELTA_ENDURANCE_VIGIL = 4.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Tsun deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_TRIAL_ENDURED
        return DELTA_TRIAL_ENDURED
    elseIf signalType == SIGNAL_ADVERSITY_SURVIVED
        return DELTA_ADVERSITY_SURVIVED
    elseIf signalType == SIGNAL_ENDURANCE_VIGIL
        return DELTA_ENDURANCE_VIGIL
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Tsun weighs the player's first hard trial.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Tsun finds the player tested and standing.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Tsun keeps the bridge at the Champion's back.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Tsun as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Tsun.")
    endIf
EndFunction
