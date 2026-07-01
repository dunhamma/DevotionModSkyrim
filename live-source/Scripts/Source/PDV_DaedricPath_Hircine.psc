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
Float Property ControlledSignalPietyDelta = 12.0 Auto
Float Property ControlledSignalStigmaDelta = 1.0 Auto
Float Property CureResidueDays = 3.0 Auto
Float Property CureStigmaReduction = 2.0 Auto

Message Property Notif_SeekerEntry Auto
Message Property Notif_DevotedEntry Auto
Message Property Notif_Lapse Auto
Message Property Notif_Stigma_Suspected Auto
Message Property Notif_Stigma_Known Auto
Message Property Notif_Stigma_Notorious Auto
Message Property Notif_NeglectTexture Auto
Message Property Msg_ChampionEntry Auto
Message Property Msg_Commitment Auto
Message Property Msg_Exit Auto
Message Property Msg_Response_Nord Auto
Message Property Msg_Response_Imperial Auto
Message Property Msg_Response_Breton Auto
Message Property Msg_Response_Altmer Auto
Message Property Msg_Response_Bosmer Auto
Message Property Msg_Response_Dunmer Auto
Message Property Msg_Response_Khajiit Auto
Message Property Msg_Response_Argonian Auto
Message Property Msg_Response_Orc Auto
Message Property Msg_Response_Redguard Auto

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

Function RecordControlledSignal(String reason)
    AddCommitmentSignal("controlled_" + reason)
    AddStigma(ControlledSignalStigmaDelta, "controlled_" + reason)

    if HasCommitmentSignalGateOpen()
        AdjustStoredPiety(ControlledSignalPietyDelta, "controlled_" + reason)
    endIf

    TraceControlled(1, "Controlled signal recorded: " + GetControlledSummary())
EndFunction

Function DebugRunControlledProof(Int targetTier)
    ResetDaedricForDebug()
    AddCommitmentSignal("debug_one")
    AddCommitmentSignal("debug_two")
    AddCommitmentSignal("debug_three")

    if targetTier >= TIER_CHAMPION
        SetStoredPiety(ThresholdChampion, "debug_controlled_proof")
    elseIf targetTier >= TIER_DEVOTED
        SetStoredPiety(ThresholdDevoted, "debug_controlled_proof")
    else
        SetStoredPiety(ThresholdSeeker, "debug_controlled_proof")
    endIf

    AddStigma(ControlledSignalStigmaDelta, "debug_controlled_proof")
    ShowControlledProofMessages()
    TraceControlled(1, "DebugRunControlledProof: " + GetControlledSummary())
EndFunction

Function DebugRunLiveSenderProof(String hookId)
    RecordControlledSignal("live_" + hookId)
    StorageUtil.SetStringValue(GetDeityForm(), "PDV.Daedric.Hircine.LastLiveHook", hookId)
    TraceControlled(1, "Live sender proof recorded for " + hookId)
EndFunction

Function DebugRenouncePath()
    RenouncePath("debug")
    TraceControlled(1, "DebugRenouncePath")
EndFunction

Function ShowControlledProofMessages()
    ShowIfPresent(Notif_SeekerEntry)
    ShowIfPresent(Notif_DevotedEntry)
    ShowIfPresent(Msg_Commitment)
    ShowIfPresent(Msg_ChampionEntry)
    ShowIfPresent(Notif_Stigma_Suspected)
    ShowIfPresent(Notif_Stigma_Known)
    ShowIfPresent(Notif_Stigma_Notorious)
    ShowIfPresent(Notif_NeglectTexture)
    ShowRaceResponseForPlayer()
EndFunction

Function RenouncePath(String reason)
    ResetDaedricForDebug()
    SetStoredPiety(0.0, "renounce_" + reason)
    BeginNordResidueRecovery("renounce_" + reason)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.Renounced", 1)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.RenunciationJournalPending", 1)
    ShowIfPresent(Msg_Exit)
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
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueToastPending", 0)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueClearToastPending", 0)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.RenunciationJournalPending", 0)
    Trace(2, "ResetPilotForDebug")
EndFunction

Function HandleCurseTransition(Int oldState, Int newState, String reason)
    if oldState != CURSE_WEREWOLF && newState == CURSE_WEREWOLF
        AddCommitmentSignal("curse_entry_" + reason)
        AddStigma(HuntRiteStigmaDelta, "curse_entry_" + reason)
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.CurseTouched", 1)
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 0)
        StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", 0.0)
        ShowRaceResponseForPlayer()
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
        StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueClearToastPending", 1)
        Trace(1, "Nord Hircine residue has faded.")
    endIf
EndFunction

Function BeginNordResidueRecovery(String reason)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueActive", 1)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueUntil", Utility.GetCurrentGameTime() + CureResidueDays)
    StorageUtil.SetStringValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueReason", reason)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueToastPending", 1)
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Hircine.ResidueClearToastPending", 0)
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

Int Function ShowIfPresent(Message messageRecord)
    if messageRecord
        return messageRecord.Show()
    endIf
    return -1
EndFunction

Function ShowTierEntryMessage(Int oldTier, Int newTier)
    if newTier <= oldTier
        return
    endIf
    if newTier == TIER_CHAMPION
        Int championChoice = ShowIfPresent(Msg_ChampionEntry)
        HandleChampionOfferResult(championChoice, "tier_entry")
    elseIf newTier == TIER_DEVOTED
        ShowIfPresent(Notif_DevotedEntry)
    elseIf newTier == TIER_SEEKER
        ShowIfPresent(Notif_SeekerEntry)
    endIf
EndFunction

Function ShowCommitmentBeat()
    ShowIfPresent(Msg_Commitment)
EndFunction

Function ShowRaceResponseForPlayer()
    Int originRace = GetPlayerOriginRace()
    if originRace == RACE_NORD
        ShowIfPresent(Msg_Response_Nord)
    elseIf originRace == RACE_IMPERIAL
        ShowIfPresent(Msg_Response_Imperial)
    elseIf originRace == RACE_BRETON
        ShowIfPresent(Msg_Response_Breton)
    elseIf originRace == RACE_ALTMER
        ShowIfPresent(Msg_Response_Altmer)
    elseIf originRace == RACE_BOSMER
        ShowIfPresent(Msg_Response_Bosmer)
    elseIf originRace == RACE_DUNMER
        ShowIfPresent(Msg_Response_Dunmer)
    elseIf originRace == RACE_KHAJIIT
        ShowIfPresent(Msg_Response_Khajiit)
    elseIf originRace == RACE_ARGONIAN
        ShowIfPresent(Msg_Response_Argonian)
    elseIf originRace == RACE_ORSIMER
        ShowIfPresent(Msg_Response_Orc)
    elseIf originRace == RACE_REDGUARD
        ShowIfPresent(Msg_Response_Redguard)
    endIf
EndFunction

String Function GetControlledSummary()
    return GetPilotSummary()
EndFunction

Function TraceControlled(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] HircinePath: " + traceText)
    endIf
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] HircinePilot: " + traceText)
    endIf
EndFunction
