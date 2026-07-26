;/ 
    PDV_Deity_Talos.psc
    PlayerDevotion - Talos hostile-path proof deity
    -----------------------------------------------------------------------
    OVERVIEW
    Talos is the first real proof of hostile-path devotion. In the current
    slice, he proves explicit defiance signals and one-way rivalry against
    Auri-El for Altmer players.

    DESIGN NOTES
    - No ordinary hostile-humanoid combat drift in this slice.
    - Curated explicit Talos-facing acts drive the first proof.
    - Hostile Altmer worship is reachable immediately, with rivalry cost
      providing the friction rather than a hard gate.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Talos extends PDV_DeityBase

Int Property SIGNAL_SHRINE_DEFIANCE = 101 AutoReadOnly
Int Property SIGNAL_PROTECT_WORSHIPPER = 102 AutoReadOnly
Int Property SIGNAL_DEFIANCE_MILESTONE = 103 AutoReadOnly
Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly

Float Property DELTA_SHRINE_DEFIANCE = 3.0 Auto
Float Property DELTA_PROTECT_WORSHIPPER = 4.0 Auto
Float Property DELTA_DEFIANCE_MILESTONE = 5.0 Auto
Float Property DELTA_SHOUT_ATTACK = 0.5 Auto

; Contract-declared tuning knob for the ancestral-spine lane (pdv_verify asserts
; DELTA_ANCESTOR_SPINE = 1.0 on this deity). Currently unread here -- the spine
; scoring for this lane is specced, not yet wired -- so do NOT "clean it up": the
; 1.0.4 Altmer Spine wire is what will read it, and deleting it now would throw
; away the intended value. Azura / Malacath / Tu'whacca already return theirs.
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto
Int Property SHOUT_DAILY_CAP = 2 Auto
Float Property SHOUT_COOLDOWN_DAYS = 0.0208 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Talos deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; Race-eligibility gate: generic acts only score deities native to the player's race.
    if !IsRaceNativeForPlayer()
        return 0.0
    endIf
    if eventType == EVT_SHOUT_ATTACK
        Shout usedShout = targetRef as Shout
        if usedShout
            return ScoreRepeatableAction(eventType, DELTA_SHOUT_ATTACK, SHOUT_DAILY_CAP, SHOUT_COOLDOWN_DAYS)
        endIf
        return 0.0
    endIf

    ; All other (non-shout) events are data-driven from the likes/dislikes table.
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_SHRINE_DEFIANCE
        return DELTA_SHRINE_DEFIANCE
    elseIf signalType == SIGNAL_PROTECT_WORSHIPPER
        return DELTA_PROTECT_WORSHIPPER
    elseIf signalType == SIGNAL_DEFIANCE_MILESTONE
        return DELTA_DEFIANCE_MILESTONE
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    ClearLegacyTalosBoons()

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos acknowledges the first open defiance.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos marks the player as steadfast.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Talos crowns the player in open defiance.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    ClearLegacyTalosBoons()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Talos patron start")
        Debug.Trace("[PDV] Player has chosen Talos as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    ClearLegacyTalosBoons()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Talos patron end")
        Debug.Trace("[PDV] Player has ceased worshipping Talos.")
    endIf
EndFunction

Function ClearLegacyTalosBoons()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if Boon_Seeker
        playerRef.RemoveSpell(Boon_Seeker)
    endIf
    if Boon_Devoted
        playerRef.RemoveSpell(Boon_Devoted)
    endIf
    if Boon_Champion
        playerRef.RemoveSpell(Boon_Champion)
    endIf
EndFunction

Bool Function ShouldSyncLegacyPatronBoons()
    return False
EndFunction
