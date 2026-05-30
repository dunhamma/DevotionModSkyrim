;/ 
    PDV_DaedricPath_Hircine.psc
    PlayerDevotion - Hircine proving pilot
    -----------------------------------------------------------------------
    Concrete proving helper attached alongside the Daedric base path.
    Exercises the first real boon/price/stigma contract with explicit hunt
    rites, commitment-signal gating, and renunciation/reset handling.
    -----------------------------------------------------------------------
/;

Scriptname PDV_DaedricPath_Hircine extends PDV_DaedricPathBase

Float Property HuntRitePietyDelta = 12.0 Auto
Float Property HuntRiteStigmaDelta = 1.0 Auto
Float Property CureResidueDays = 3.0 Auto
Float Property CureStigmaReduction = 2.0 Auto

Int Property CURSE_NONE = 0 AutoReadOnly
Int Property CURSE_WEREWOLF = 1 AutoReadOnly
Int Property CURSE_VAMPIRE = 2 AutoReadOnly

Function RecordHuntRite(String reason)
    RecordHuntRiteScaled(1.0, reason)
EndFunction

Function RecordHuntRiteScaled(Float multiplier, String reason)
    AddCommitmentSignal("hunt_rite_" + reason)
    Float appliedMultiplier = ClampSignalMultiplier(multiplier)
    AddStigma(HuntRiteStigmaDelta * appliedMultiplier, "hunt_rite_" + reason)

    if HasCommitmentSignalGateOpen()
        AdjustStoredPiety(HuntRitePietyDelta * appliedMultiplier, "hunt_rite_" + reason)
    endIf

    Trace(2, "Hunt rite recorded: " + GetPilotSummary())
EndFunction

Function RenouncePath(String reason)
    ResetDaedricForDebug()
    SetStoredPiety(0.0, "renounce_" + reason)
    BeginNordResidueRecovery("renounce_" + reason)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.Renounced", 1)
    Trace(1, "Hircine renunciation recorded.")
EndFunction

String Function GetPilotSummary()
    UpdateResidueRecovery()
    return GetContractSummary() + "; " + GetDaedricSpellSummary() + "; exit=" + GetExitDifficultyForPlayer() + "; residue=" + GetResidueSummary()
EndFunction

Function ResetPilotForDebug()
    ResetDaedricForDebug()
    SetStoredPiety(0.0, "pilot_reset")
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.Renounced", 0)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 0)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", 0.0)
    Trace(2, "ResetPilotForDebug")
EndFunction

Function HandleCurseTransition(Int oldState, Int newState, String reason)
    if oldState != CURSE_WEREWOLF && newState == CURSE_WEREWOLF
        AddCommitmentSignal("curse_entry_" + reason)
        AddStigma(HuntRiteStigmaDelta, "curse_entry_" + reason)
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.CurseTouched", 1)
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 0)
        StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", 0.0)
        Trace(1, "Curse entry recorded for Hircine.")
        return
    endIf

    if oldState == CURSE_WEREWOLF && newState != CURSE_WEREWOLF
        BeginNordResidueRecovery("cure_" + reason)
        AddStigma(-CureStigmaReduction, "cure_" + reason)
        Trace(1, "Werewolf cure recorded for Hircine.")
    endIf
EndFunction

Function UpdateResidueRecovery()
    if StorageUtil.GetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive") != 1
        return
    endIf

    if Utility.GetCurrentGameTime() >= StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil")
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 0)
        StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", 0.0)
        Trace(1, "Nord Hircine residue has faded.")
    endIf
EndFunction

Function BeginNordResidueRecovery(String reason)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 1)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", Utility.GetCurrentGameTime() + CureResidueDays)
    StorageUtil.SetStringValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueReason", reason)
EndFunction

String Function GetResidueSummary()
    if StorageUtil.GetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive") != 1
        return "clear"
    endIf

    Float daysRemaining = StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil") - Utility.GetCurrentGameTime()
    if daysRemaining < 0.0
        daysRemaining = 0.0
    endIf

    return "active/" + daysRemaining
EndFunction

Float Function ClampSignalMultiplier(Float multiplier)
    if multiplier < 0.0
        return 0.0
    endIf

    return multiplier
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] HircinePilot: " + traceText)
    endIf
EndFunction
