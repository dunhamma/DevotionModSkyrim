;/
    PDV_Deity_Shor.psc
    PlayerDevotion - Nord Old Ways hero-god of Sovngarde
    -----------------------------------------------------------------------
    OVERVIEW
    Concrete implementation of PDV_DeityBase for Shor, the Nordic hero-god
    of Sovngarde, honorable battle, glory, and the honored dead. NEW
    Nord-owned focusable deity in the reworked Old Ways lane (alongside
    Kyne and Talos, with sibling new gods Tsun and Stuhn).

    DESIGN NOTES
    - Stance row is simple: Nord = NATIVE, everyone else = FOREIGN.
      No TABOO/HOSTILE entries, no rivalry list.
    - Shor's domain is honorable battle and the honored dead, so he scores
      a small repeatable piety drip on honorable open combat: the
      in-combat hostile-humanoid kill (EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT).
      He deliberately does NOT score beast kills (Kyne's domain) and the
      script has no signal for sneak/bash openers -- those are not honorable
      open battle. (Engine kill data does not flag opener type, so true
      sneak/bash rejection rides on the T3 signature and upstream curation;
      the deity script only scores the open in-combat humanoid kill here.)
    - Curated signals carry the named glory beats: an honorable-battle beat,
      a tending-the-honored-dead beat, and a Sovngarde-valor milestone.
    - Creed-violation negatives are OMITTED in V1: per the Nord reward spec,
      Shor dishonor/cowardice reads as fiction-only texture and gentle
      neglect drift, with no concrete authored trigger yet.
    - T3 capstone carries the scripted signature "Sovngarde Looks Back"
      (Nord's single allowed cheat-death/last-stand save); that lives in
      the reward/signature layer, not in this scoring script.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Shor extends PDV_DeityBase

Int Property SIGNAL_HONORED_DEAD = 2901 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2 AutoReadOnly

Float Property DELTA_HONORED_DEAD = 1.5 Auto

Float Property DELTA_HONORABLE_KILL = 0.5 Auto

; Contract-declared tuning knob for the ancestral-spine lane (pdv_verify asserts
; DELTA_ANCESTOR_SPINE = 1.0 on this deity). Currently unread here -- the spine
; scoring for this lane is specced, not yet wired -- so do NOT "clean it up": the
; 1.0.4 Altmer Spine wire is what will read it, and deleting it now would throw
; away the intended value. Azura / Malacath / Tu'whacca already return theirs.
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto
Int Property HONORABLE_KILL_DAILY_CAP = 4 Auto
Float Property HONORABLE_KILL_COOLDOWN_DAYS = 0.0104 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Shor deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; Race-eligibility gate: generic acts only score deities native to the player's race.
    if !IsRaceNativeForPlayer()
        return 0.0
    endIf
    if eventType == EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
        return ScoreRepeatableAction(eventType, DELTA_HONORABLE_KILL, HONORABLE_KILL_DAILY_CAP, HONORABLE_KILL_COOLDOWN_DAYS)
    endIf

    ; All other (non-honorable-kill) events are data-driven from the likes/dislikes table.
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_HONORED_DEAD
        return DELTA_HONORED_DEAD
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Shor marks the player's first honorable stand.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Shor counts the player among the brave.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Shor's hall remembers the player as a Champion.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Shor as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Shor.")
    endIf
EndFunction
