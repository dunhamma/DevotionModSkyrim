;/
    PDV_Deity_Malacath.psc
    PlayerDevotion - Orsimer Malacath, the one Orc religious spine
    -----------------------------------------------------------------------
    OVERVIEW
    Malacath is the single religious spine of the Orsimer. There are no side
    gods and no deity shopping: Orc depth comes from how the code is kept
    inside the active life mode (Stronghold / City / Legion-Exile), not from
    venerating a second patron. Broad Malacath worship is the floor that
    holds in any mode; the three life-mode lanes are the focused expression
    of that one faith.

    DESIGN NOTES
    - This script owns scoring only. Life-mode gating (which lane is active,
      one-active-focus, per-mode tier caps and pace) is a MANAGER concern
      (PDV_State_OrcLifeMode + the SyncOrc* reward logic), not the deity.
    - Faucet acts are QUALITY-scaled, never raw loops: quality forge (not
      craft count), city quality-labor / dignity-under-pressure, and
      pressure-bearing service completion. The manager applies the
      anti-farm (quality/value/context + daily repeat multiplier, or
      one-shot service markers) before awarding a signal.
    - Creed-violation losses are MEDIUM/MAJOR only (dishonor under the
      code), distinct from the gentle neglect drift handled by the
      neglect spell. Curse-code rupture (werewolf) cools Malacath's regard.
    - Stronghold/City/Legion-Exile reach equal felt value; the slower
      calendars are pace, not lesser worth. Magnitudes live on the reward
      spells, not here.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Malacath extends PDV_DeityBase

; --- Life-mode devotional acts (positive faucet, manager applies anti-farm) ---
Int Property SIGNAL_STRONGHOLD_FORGE = 2201 AutoReadOnly      ; quality forge / worthy work at the hold
Int Property SIGNAL_BLOOD_KIN = 2202 AutoReadOnly             ; Blood-Kin crisis / stronghold belonging (T3 communal proof)
Int Property SIGNAL_CITY_DIGNITY = 2203 AutoReadOnly          ; private fidelity / dignity-under-pressure / quality labor
Int Property SIGNAL_SELF_MADE_COMMUNITY = 2204 AutoReadOnly   ; community built outside the hold (City T3 proof)
Int Property SIGNAL_LEGION_SERVICE = 2205 AutoReadOnly        ; pressure-bearing Legion / exile service completion
Int Property SIGNAL_EXILE_RETURN = 2206 AutoReadOnly          ; burden carried home (Legion-Exile T3 proof)
Int Property SIGNAL_BROAD_CONDUCT = 2207 AutoReadOnly         ; broad code-keeping (book/text), below focused
Int Property SIGNAL_FOUR_HOLDS_VISIT = 2208 AutoReadOnly      ; first arrival at one of the four Orc strongholds
Int Property SIGNAL_ANCESTOR_SPINE = 2209 AutoReadOnly        ; origin-spine pulse for Orc code/life-mode acts

; --- Creed-violation losses (medium/major dishonor only) ---
Int Property SIGNAL_SELF_ERASURE = 2250 AutoReadOnly          ; swallowed an insult the code says must be answered (major)
Int Property SIGNAL_BROKEN_FAITH_KIN = 2251 AutoReadOnly      ; betrayed Blood-Kin / deserted sworn service (medium)
Int Property SIGNAL_CURSE_CODE_RUPTURE = 2252 AutoReadOnly    ; werewolf onset judged against the code (medium)
Int Property SIGNAL_OATH_BREAK = 2253 AutoReadOnly            ; smaller oath break / lesser sworn-code breach (medium-light)

; --- Positive deltas ---
Float Property DELTA_STRONGHOLD_FORGE = 2.5 Auto
Float Property DELTA_BLOOD_KIN = 3.0 Auto
Float Property DELTA_CITY_DIGNITY = 2.0 Auto
Float Property DELTA_SELF_MADE_COMMUNITY = 3.0 Auto
Float Property DELTA_LEGION_SERVICE = 2.5 Auto
Float Property DELTA_EXILE_RETURN = 3.0 Auto
Float Property DELTA_BROAD_CONDUCT = 1.0 Auto
Float Property DELTA_FOUR_HOLDS_VISIT = 1.0 Auto
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

; --- Negative deltas (creed violations) ---
Float Property DELTA_SELF_ERASURE = -3.0 Auto
Float Property DELTA_BROKEN_FAITH_KIN = -2.0 Auto
Float Property DELTA_CURSE_CODE_RUPTURE = -2.0 Auto
Float Property DELTA_OATH_BREAK = -1.5 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Malacath deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_STRONGHOLD_FORGE
        return DELTA_STRONGHOLD_FORGE
    elseIf signalType == SIGNAL_BLOOD_KIN
        return DELTA_BLOOD_KIN
    elseIf signalType == SIGNAL_CITY_DIGNITY
        return DELTA_CITY_DIGNITY
    elseIf signalType == SIGNAL_SELF_MADE_COMMUNITY
        return DELTA_SELF_MADE_COMMUNITY
    elseIf signalType == SIGNAL_LEGION_SERVICE
        return DELTA_LEGION_SERVICE
    elseIf signalType == SIGNAL_EXILE_RETURN
        return DELTA_EXILE_RETURN
    elseIf signalType == SIGNAL_BROAD_CONDUCT
        return DELTA_BROAD_CONDUCT
    elseIf signalType == SIGNAL_FOUR_HOLDS_VISIT
        return DELTA_FOUR_HOLDS_VISIT
    elseIf signalType == SIGNAL_ANCESTOR_SPINE
        return DELTA_ANCESTOR_SPINE
    elseIf signalType == SIGNAL_SELF_ERASURE
        return DELTA_SELF_ERASURE
    elseIf signalType == SIGNAL_BROKEN_FAITH_KIN
        return DELTA_BROKEN_FAITH_KIN
    elseIf signalType == SIGNAL_CURSE_CODE_RUPTURE
        return DELTA_CURSE_CODE_RUPTURE
    elseIf signalType == SIGNAL_OATH_BREAK
        return DELTA_OATH_BREAK
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Malacath marks the first kept stretch of the code.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Malacath counts the player worthy and faithful.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Malacath names the player blood-kin of the code.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Malacath as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased keeping Malacath's code.")
    endIf
EndFunction
