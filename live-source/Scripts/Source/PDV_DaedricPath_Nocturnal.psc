;/
    PDV_DaedricPath_Nocturnal.psc
    PlayerDevotion - Nocturnal Daedric path
    Generated from PDV_DaedricPrinceRecordContracts.json.
/;

Scriptname PDV_DaedricPath_Nocturnal extends PDV_DaedricPathBase

Float Property ControlledSignalPietyDelta = 12.0 Auto
Float Property ControlledSignalStigmaDelta = 1.0 Auto

Message Property Msg_Commitment Auto
Message Property Msg_ChampionEntry Auto
Message Property Msg_Exit Auto
Message Property Notif_SeekerEntry Auto
Message Property Notif_DevotedEntry Auto
Message Property Notif_Lapse Auto
Message Property Notif_Stigma_Suspected Auto
Message Property Notif_Stigma_Known Auto
Message Property Notif_Stigma_Notorious Auto
Message Property Notif_NeglectTexture Auto
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
    StorageUtil.SetStringValue(GetDeityForm(), "PDV.Daedric.Nocturnal.LastLiveHook", hookId)
    TraceControlled(1, "Live sender proof recorded for " + hookId)
EndFunction

Function DebugRenouncePath()
    ResetDaedricForDebug()
    SetStoredPiety(0.0, "debug_renounce")
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.Nocturnal.Renounced", 1)
    if Msg_Exit
        Msg_Exit.Show()
    endIf
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

Function ShowTierEntryMessage(Int oldTier, Int newTier)
    if newTier <= oldTier
        return
    endIf
    if newTier == TIER_CHAMPION
        ShowIfPresent(Msg_ChampionEntry)
    elseIf newTier == TIER_DEVOTED
        ShowIfPresent(Notif_DevotedEntry)
    elseIf newTier == TIER_SEEKER
        ShowIfPresent(Notif_SeekerEntry)
    endIf
EndFunction

Function ShowCommitmentBeat()
    ShowIfPresent(Msg_Commitment)
EndFunction

; Surface this Prince's Msg_Commitment as the formal 3-button pact-offer message.
Message Function GetCommitmentOfferMessage()
    return Msg_Commitment
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

Function ShowIfPresent(Message messageRecord)
    if messageRecord
        messageRecord.Show()
    endIf
EndFunction

String Function GetControlledSummary()
    return GetContractSummary() + "; " + GetDaedricSpellSummary() + "; exit=" + GetExitDifficultyForPlayer()
EndFunction

Function TraceControlled(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] NocturnalPath: " + traceText)
    endIf
EndFunction
