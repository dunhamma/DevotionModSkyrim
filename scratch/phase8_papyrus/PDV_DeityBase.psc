;/ 
    PDV_DeityBase.psc
    PlayerDevotion - Phase 4 deity contract / base class
    -----------------------------------------------------------------------
    OVERVIEW
    Abstract base class that every concrete deity script extends
    (PDV_Deity_Kyne, PDV_Deity_Talos, etc.). Establishes the contract
    that all deities honor: identity, tier thresholds, stance data,
    rivalry metadata, and patron-only cumulative boon handling.

    DESIGN NOTES
    - All piety reads/writes go through StorageUtil keyed by this quest's
      Form. Deities do not own canonical state in globals.
    - Phase 4 replaces the old GainMult_* origin floats with race-keyed
      stance properties.
    - Boons are cumulative across tiers, but only the active patron's
      boons are live on the player at a time.
    -----------------------------------------------------------------------
/;

Scriptname PDV_DeityBase extends Quest

String Property DeityName Auto
String Property DeityDomain Auto
Int Property DeityIndex Auto

Float Property ThresholdSeeker = 10.0 Auto
Float Property ThresholdDevoted = 50.0 Auto
Float Property ThresholdChampion = 150.0 Auto

Int Property STANCE_NATIVE = 0 AutoReadOnly
Int Property STANCE_FOREIGN = 1 AutoReadOnly
Int Property STANCE_TABOO = 2 AutoReadOnly
Int Property STANCE_HOSTILE = 3 AutoReadOnly

Int Property RACE_NORD = 0 AutoReadOnly
Int Property RACE_IMPERIAL = 1 AutoReadOnly
Int Property RACE_BRETON = 2 AutoReadOnly
Int Property RACE_ALTMER = 3 AutoReadOnly
Int Property RACE_BOSMER = 4 AutoReadOnly
Int Property RACE_DUNMER = 5 AutoReadOnly
Int Property RACE_KHAJIIT = 6 AutoReadOnly
Int Property RACE_ARGONIAN = 7 AutoReadOnly
Int Property RACE_ORSIMER = 8 AutoReadOnly
Int Property RACE_REDGUARD = 9 AutoReadOnly

Int Property Stance_Nord = 1 Auto
Int Property Stance_Imperial = 1 Auto
Int Property Stance_Breton = 1 Auto
Int Property Stance_Altmer = 1 Auto
Int Property Stance_Bosmer = 1 Auto
Int Property Stance_Dunmer = 1 Auto
Int Property Stance_Khajiit = 1 Auto
Int Property Stance_Argonian = 1 Auto
Int Property Stance_Orc = 1 Auto
Int Property Stance_Redguard = 1 Auto

Quest[] Property RivalDeities Auto
Float[] Property RivalMultipliers Auto

Spell Property Boon_Seeker Auto
Spell Property Boon_Devoted Auto
Spell Property Boon_Champion Auto

PDV_ReputationTrack Property GainModifyingTrack Auto
Float[] Property GainMultiplierPerTrackState Auto
PDV_ReputationTrack Property DecayModifyingTrack Auto
Float[] Property DecayMultiplierPerTrackState Auto

GlobalVariable Property PDV_GLO_DebugLevel Auto
GlobalVariable Property PDV_GLO_OriginRace Auto

Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return 0.0
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    SyncPatronBoonsToTier(newTier)

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " tier change: " + oldTier + " -> " + newTier)
    endIf
EndFunction

Function OnPatronStart()
    SyncPatronBoonsToTier(GetStoredTier())

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron start")
    endIf
EndFunction

Function OnPatronEnd()
    ClearAllBoons()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron end")
    endIf
EndFunction

Form Function GetDeityForm()
    return Self as Form
EndFunction

Int Function GetStoredTier()
    return StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Tier") as Int
EndFunction

Int Function GetStanceForPlayer()
    if PDV_GLO_OriginRace
        return GetStanceForRace(PDV_GLO_OriginRace.GetValueInt())
    endIf
    return STANCE_FOREIGN
EndFunction

Int Function GetStanceForRace(Int raceIndex)
    if raceIndex == RACE_NORD
        return Stance_Nord
    elseIf raceIndex == RACE_IMPERIAL
        return Stance_Imperial
    elseIf raceIndex == RACE_BRETON
        return Stance_Breton
    elseIf raceIndex == RACE_ALTMER
        return Stance_Altmer
    elseIf raceIndex == RACE_BOSMER
        return Stance_Bosmer
    elseIf raceIndex == RACE_DUNMER
        return Stance_Dunmer
    elseIf raceIndex == RACE_KHAJIIT
        return Stance_Khajiit
    elseIf raceIndex == RACE_ARGONIAN
        return Stance_Argonian
    elseIf raceIndex == RACE_ORSIMER
        return Stance_Orc
    elseIf raceIndex == RACE_REDGUARD
        return Stance_Redguard
    endIf

    return STANCE_FOREIGN
EndFunction

Float Function GetGainMultiplier(Int stance)
    if stance == STANCE_NATIVE
        return 1.0
    elseIf stance == STANCE_FOREIGN
        return 0.5
    elseIf stance == STANCE_TABOO
        return 0.75
    endIf

    return 1.0
EndFunction

Float Function GetTrackGainMultiplier()
    return ResolveTrackMultiplier(GainModifyingTrack, GainMultiplierPerTrackState, True)
EndFunction

Float Function GetTrackDecayMultiplier()
    return ResolveTrackMultiplier(DecayModifyingTrack, DecayMultiplierPerTrackState, False)
EndFunction

Float Function GetEffectiveGainMultiplier()
    return GetGainMultiplier(GetStanceForPlayer()) * GetTrackGainMultiplier()
EndFunction

Float Function GetEffectiveDecayMultiplier()
    return GetTrackDecayMultiplier()
EndFunction

Float Function ScoreRepeatableAction(Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    if delta == 0.0
        return 0.0
    endIf

    Form deityForm = GetDeityForm()
    String keyPrefix = "PDV.Event." + eventType
    String dayKey = keyPrefix + ".Day"
    String countKey = keyPrefix + ".Count"
    String lastFireKey = keyPrefix + ".LastFire"
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int currentCount = 0

    if StorageUtil.GetIntValue(deityForm, dayKey) == currentDay
        currentCount = StorageUtil.GetIntValue(deityForm, countKey)
    else
        StorageUtil.SetIntValue(deityForm, dayKey, currentDay)
        StorageUtil.SetIntValue(deityForm, countKey, 0)
    endIf

    if dailyCap > 0 && currentCount >= dailyCap
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] " + DeityName + " repeatable event " + eventType + " blocked by daily cap.")
        endIf
        return 0.0
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Float lastFireTime = StorageUtil.GetFloatValue(deityForm, lastFireKey)
    if cooldownDays > 0.0 && lastFireTime > 0.0 && (nowTime - lastFireTime) < cooldownDays
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] " + DeityName + " repeatable event " + eventType + " blocked by cooldown.")
        endIf
        return 0.0
    endIf

    StorageUtil.SetIntValue(deityForm, dayKey, currentDay)
    StorageUtil.SetIntValue(deityForm, countKey, currentCount + 1)
    StorageUtil.SetFloatValue(deityForm, lastFireKey, nowTime)
    return delta
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function SyncPatronBoonsToTier(Int tierValue)
    ClearAllBoons()

    if tierValue >= TIER_SEEKER && Boon_Seeker
        Game.GetPlayer().AddSpell(Boon_Seeker, False)
    endIf
    if tierValue >= TIER_DEVOTED && Boon_Devoted
        Game.GetPlayer().AddSpell(Boon_Devoted, False)
    endIf
    if tierValue >= TIER_CHAMPION && Boon_Champion
        Game.GetPlayer().AddSpell(Boon_Champion, False)
    endIf
EndFunction

Function ClearAllBoons()
    if Boon_Seeker
        Game.GetPlayer().RemoveSpell(Boon_Seeker)
    endIf
    if Boon_Devoted
        Game.GetPlayer().RemoveSpell(Boon_Devoted)
    endIf
    if Boon_Champion
        Game.GetPlayer().RemoveSpell(Boon_Champion)
    endIf
EndFunction

Float Function ResolveTrackMultiplier(PDV_ReputationTrack track, Float[] configuredMultipliers, Bool isGain)
    if !track
        return 1.0
    endIf

    Int stateIndex = track.GetStateIndex()
    if configuredMultipliers.Length > stateIndex && stateIndex >= 0
        return configuredMultipliers[stateIndex]
    endIf

    return GetFallbackTrackMultiplier(track, stateIndex, isGain)
EndFunction

Float Function GetFallbackTrackMultiplier(PDV_ReputationTrack track, Int stateIndex, Bool isGain)
    if !track
        return 1.0
    endIf

    if DeityName == "Talos" && track.TrackName == "ConcordatStanding"
        if isGain
            if stateIndex == 0
                return 1.5
            elseIf stateIndex == 1
                return 1.25
            elseIf stateIndex == 3
                return 0.75
            elseIf stateIndex >= 4
                return 0.5
            endIf
        elseIf stateIndex == 3
            return 1.25
        elseIf stateIndex >= 4
            return 1.5
        endIf
    endIf

    return 1.0
EndFunction
