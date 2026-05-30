;/
    PDV_CurseState.psc
    PlayerDevotion - V3 Structural Skeleton curse state service
    -----------------------------------------------------------------------
    Central curse-state owner for Werewolf/Vampire interpretation. Detection
    is intentionally conservative in the scaffold; concrete detection lands
    with the curse-state phase after vanilla behavior is tested.
    -----------------------------------------------------------------------
/;

Scriptname PDV_CurseState extends Quest

GlobalVariable Property PDV_GLO_CurseState Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property CURSE_NONE = 0 AutoReadOnly
Int Property CURSE_WEREWOLF = 1 AutoReadOnly
Int Property CURSE_VAMPIRE = 2 AutoReadOnly
Int Property CURSE_UNKNOWN = 3 AutoReadOnly

String Property SKYRIM_MASTER = "Skyrim.esm" AutoReadOnly
String Property DAWNGUARD_MASTER = "Dawnguard.esm" AutoReadOnly

Int Property FORMID_WEREWOLF_BEAST_RACE = 843140 AutoReadOnly
Int Property FORMID_PLAYER_WEREWOLF_FACTION = 596002 AutoReadOnly
Int Property FORMID_WEREWOLF_IMMUNITY = 1006496 AutoReadOnly
Int Property FORMID_VAMPIRE_VAMPIRISM = 970920 AutoReadOnly
Int Property FORMID_VAMPIRE_PC_FACTION = 806368 AutoReadOnly
Int Property FORMID_DLC1_PLAYER_VAMPIRE_LORD_FACTION = 29139 AutoReadOnly

Race _werewolfBeastRace
Faction _playerWerewolfFaction
Spell _werewolfImmunitySpell
Spell _vampireVampirismSpell
Faction _vampirePcFaction
Faction _playerVampireLordFaction
Bool _cachedVanillaForms = False

Int Function GetCurseState()
    if PDV_GLO_CurseState
        return PDV_GLO_CurseState.GetValueInt()
    endIf

    return StorageUtil.GetIntValue(GetCurseForm(), "PDV.Curse.State")
EndFunction

String Function GetCurseStateLabel()
    Int currentState = GetCurseState()
    if currentState == CURSE_WEREWOLF
        return "Werewolf"
    elseIf currentState == CURSE_VAMPIRE
        return "Vampire"
    elseIf currentState == CURSE_UNKNOWN
        return "Unknown"
    endIf

    return "None"
EndFunction

Bool Function IsWerewolf()
    return GetCurseState() == CURSE_WEREWOLF
EndFunction

Bool Function IsVampire()
    return GetCurseState() == CURSE_VAMPIRE
EndFunction

Function SetCurseState(Int newState, String reason)
    Int normalizedState = NormalizeCurseState(newState)
    Int oldState = GetCurseState()

    if oldState == normalizedState
        return
    endIf

    StorageUtil.SetIntValue(GetCurseForm(), "PDV.Curse.State", normalizedState)
    StorageUtil.SetFloatValue(GetCurseForm(), "PDV.Curse.LastChanged", Utility.GetCurrentGameTime())

    if PDV_GLO_CurseState
        PDV_GLO_CurseState.SetValue(normalizedState as Float)
    endIf

    OnCurseStateChange(oldState, normalizedState, reason)
EndFunction

Function ClearCurseState(String reason)
    SetCurseState(CURSE_NONE, reason)
EndFunction

Function RefreshFromPlayerState()
    ; RefreshFromPlayerState no-op in Structural Skeleton.
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        Trace(1, "RefreshFromPlayerState skipped: player missing.")
        return
    endIf

    EnsureVanillaCurseForms()
    SetCurseState(DetectCurseState(playerRef), "player_state")
    Trace(2, "RefreshFromPlayerState -> " + GetCurseStateLabel())
EndFunction

Function OnCurseStateChange(Int oldState, Int newState, String reason)
    StorageUtil.SetIntValue(GetCurseForm(), "PDV.Curse.OldState", oldState)
    StorageUtil.SetIntValue(GetCurseForm(), "PDV.Curse.NewState", newState)
    StorageUtil.SetFloatValue(GetCurseForm(), "PDV.Curse.LastChanged", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(GetCurseForm(), "PDV.Curse.LastReason", reason)
    Trace(1, "Curse state " + oldState + " -> " + newState + " (" + reason + ")")
EndFunction

Int Function NormalizeCurseState(Int stateValue)
    if stateValue == CURSE_WEREWOLF || stateValue == CURSE_VAMPIRE || stateValue == CURSE_UNKNOWN
        return stateValue
    endIf

    return CURSE_NONE
EndFunction

Form Function GetCurseForm()
    return Self as Form
EndFunction

Function EnsureVanillaCurseForms()
    if _cachedVanillaForms
        return
    endIf

    _werewolfBeastRace = Game.GetFormFromFile(FORMID_WEREWOLF_BEAST_RACE, SKYRIM_MASTER) as Race
    _playerWerewolfFaction = Game.GetFormFromFile(FORMID_PLAYER_WEREWOLF_FACTION, SKYRIM_MASTER) as Faction
    _werewolfImmunitySpell = Game.GetFormFromFile(FORMID_WEREWOLF_IMMUNITY, SKYRIM_MASTER) as Spell
    _vampireVampirismSpell = Game.GetFormFromFile(FORMID_VAMPIRE_VAMPIRISM, SKYRIM_MASTER) as Spell
    _vampirePcFaction = Game.GetFormFromFile(FORMID_VAMPIRE_PC_FACTION, SKYRIM_MASTER) as Faction
    _playerVampireLordFaction = Game.GetFormFromFile(FORMID_DLC1_PLAYER_VAMPIRE_LORD_FACTION, DAWNGUARD_MASTER) as Faction
    _cachedVanillaForms = True
EndFunction

Int Function DetectCurseState(Actor playerRef)
    if IsWerewolfSignalActive(playerRef)
        return CURSE_WEREWOLF
    endIf

    if IsVampireSignalActive(playerRef)
        return CURSE_VAMPIRE
    endIf

    return CURSE_NONE
EndFunction

Bool Function IsWerewolfSignalActive(Actor playerRef)
    if !playerRef
        return False
    endIf

    if _werewolfBeastRace && playerRef.GetRace() == _werewolfBeastRace
        return True
    endIf

    if _playerWerewolfFaction && playerRef.IsInFaction(_playerWerewolfFaction)
        return True
    endIf

    if _werewolfImmunitySpell && playerRef.HasSpell(_werewolfImmunitySpell)
        return True
    endIf

    return False
EndFunction

Bool Function IsVampireSignalActive(Actor playerRef)
    if !playerRef
        return False
    endIf

    if _vampireVampirismSpell && playerRef.HasSpell(_vampireVampirismSpell)
        return True
    endIf

    if _vampirePcFaction && playerRef.IsInFaction(_vampirePcFaction)
        return True
    endIf

    if _playerVampireLordFaction && playerRef.IsInFaction(_playerVampireLordFaction)
        return True
    endIf

    return False
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] CurseState: " + traceText)
    endIf
EndFunction
