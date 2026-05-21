;/ 
    PDV_MCM.psc
    PlayerDevotion - development-facing SkyUI MCM
    -----------------------------------------------------------------------
    OVERVIEW
    Thin SkyUI shell for PDV status inspection and curated debug actions.
    This first slice is intentionally not the final player-facing devotion
    UI. It reads live deity state from the manager/FormList and routes only
    development-safe mutations through manager helpers.

    DESIGN NOTES
    - Scope is intentionally narrow: Status + Debug only.
    - Patron changes exposed here are debug overrides, not theology UX.
    - No config globals or player-facing tuning controls land in this slice.
    - All interactive option OIDs are stored for reliable event handling.
    -----------------------------------------------------------------------
/;

Scriptname PDV_MCM extends SKI_ConfigBase

PDV__ManagerQuest Property PDV_Manager Auto
PDV_EventBus Property PDV_EventBusService Auto
FormList Property PDV_FLST_AllDeities Auto
FormList Property PDV_FLST_RepTracks_All Auto
FormList Property PDV_FLST_StateTracks_All Auto
FormList Property PDV_FLST_Substrates_All Auto
FormList Property PDV_FLST_SacredPlaces_All Auto
FormList Property PDV_FLST_DaedricPaths_All Auto
GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_PatronDeity Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
PDV_CurseState Property PDV_CurseStateService Auto

Int Property DEBUG_LEVEL_MIN = 0 AutoReadOnly
Int Property DEBUG_LEVEL_MAX = 3 AutoReadOnly
Float Property PIETY_MIN = 0.0 AutoReadOnly
Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_TODAY_MIN = -5.0 AutoReadOnly
Float Property PIETY_TODAY_MAX = 5.0 AutoReadOnly
Float Property SIGNAL_TYPE_MIN = 0.0 AutoReadOnly
Float Property SIGNAL_TYPE_MAX = 299.0 AutoReadOnly

String Property PAGE_STATUS = "Status" AutoReadOnly
String Property PAGE_DEBUG = "Debug" AutoReadOnly

Int _oidSelectedDeity = -1
Int _oidDebugPatronOverride = -1
Int _oidDebugClearPatron = -1
Int _oidDebugResetDeity = -1
Int _oidDebugLevel = -1
Int _oidPendingPiety = -1
Int _oidApplyPiety = -1
Int _oidPendingPietyToday = -1
Int _oidApplyPietyToday = -1
Int _oidPendingSignalType = -1
Int _oidApplyCuratedSignal = -1
Int _oidRunDawn = -1
Int _oidShowPietyMap = -1
Int _oidShowStructuralMap = -1
Int _oidRunScaffoldApiSmoke = -1
Int _oidShowPatternSummary = -1
Int _oidConcordatDefiance = -1
Int _oidConcordatCompliance = -1
Int _oidTalosShrineDefiance = -1
Int _oidConcordatUnlockGate = -1
Int _oidBosmerOldContract = -1
Int _oidBosmerBanditRoad = -1
Int _oidBosmerGreenPactViolation = -1
Int _oidDunmerPrayer = -1
Int _oidDunmerHomeBonus = -1
Int _oidKhajiitMoonObservance = -1
Int _oidKhajiitRoadHome = -1
Int _oidKyneFavorCycle = -1
Int _oidEvaluateCommitmentOffer = -1
Int _oidAcceptCommitmentOffer = -1
Int _oidDeclineCommitmentOffer = -1
Int _oidRefuseCommitmentOffer = -1
Int _oidHircineHuntRite = -1
Int _oidHircineRenounce = -1

Int _selectedListIndex = 0
Float _pendingPiety = 10.0
Float _pendingPietyToday = 1.0
Int _pendingSignalType = 103

Event OnInit()
    InitializePages()
    Parent.OnInit()
EndEvent

Function OnGameReload()
    InitializePages()
    Parent.OnGameReload()
EndFunction

Function OnConfigInit()
    InitializePages()
EndFunction

Int Function GetVersion()
    return 1
EndFunction

Function OnPageReset(String a_page)
    InitializePages()

    if a_page == "" || a_page == PAGE_STATUS
        BuildStatusPage()
        return
    endIf

    if a_page == PAGE_DEBUG
        BuildDebugPage()
    endIf
EndFunction

Function OnOptionHighlight(Int a_option)
    if a_option == _oidSelectedDeity
        SetInfoText("Cycles the current debug target through the live deity roster.")
    elseIf a_option == _oidDebugPatronOverride
        SetInfoText("Development-only override. Real patron commitment should come from in-world threshold events.")
    elseIf a_option == _oidDebugClearPatron
        SetInfoText("Clears the current debug patron override without changing deity ledgers.")
    elseIf a_option == _oidDebugResetDeity
        SetInfoText("Zeros persistent piety, scratch piety, and tier for the selected deity only.")
    elseIf a_option == _oidDebugLevel
        SetInfoText("Sets PDV trace verbosity from 0 to 3 for development logging.")
    elseIf a_option == _oidPendingPiety
        SetInfoText("Choose the persistent piety value to force onto the selected deity.")
    elseIf a_option == _oidApplyPiety
        SetInfoText("Applies the chosen persistent piety to the selected deity and recomputes tier.")
    elseIf a_option == _oidPendingPietyToday
        SetInfoText("Choose the scratch piety value to force onto the selected deity before dawn.")
    elseIf a_option == _oidApplyPietyToday
        SetInfoText("Applies the chosen scratch piety to the selected deity only.")
    elseIf a_option == _oidPendingSignalType
        SetInfoText("Choose the curated signal ID to apply to the selected deity. Talos uses 101, 102, and 103. Auri-El uses 201 and 202.")
    elseIf a_option == _oidApplyCuratedSignal
        SetInfoText("Routes the chosen curated signal through the manager so stance and rivalry apply normally.")
    elseIf a_option == _oidRunDawn
        SetInfoText("Runs ProcessDawn immediately so scratch piety consolidates into stored piety.")
    elseIf a_option == _oidShowPietyMap
        SetInfoText("Shows a compact live summary of each deity's stored piety, scratch piety, and tier.")
    elseIf a_option == _oidShowStructuralMap
        SetInfoText("Shows the current dev-only scaffold inventory across tracks, substrates, sacred places, Daedric paths, and curse state.")
    elseIf a_option == _oidRunScaffoldApiSmoke
        SetInfoText("Exercises one safe set/read/reset path on each scaffold family and writes trace output.")
    elseIf a_option == _oidShowPatternSummary
        SetInfoText("Shows the integrated Pattern Proving summary across Concordat, Bosmer, substrate, Hircine, favor, commitment, and neglect state.")
    elseIf a_option == _oidConcordatDefiance
        SetInfoText("Routes one non-kill Concordat defiance event through EventBus and the ConcordatStanding track.")
    elseIf a_option == _oidConcordatCompliance
        SetInfoText("Routes one non-kill Concordat compliance event through EventBus and the ConcordatStanding track.")
    elseIf a_option == _oidTalosShrineDefiance
        SetInfoText("Routes the hidden Talos shrine defiance signal through EventBus and Talos/Concordat handling.")
    elseIf a_option == _oidConcordatUnlockGate
        SetInfoText("Unlocks the extreme Concordat walk-back gate so Open Defiant or Concordat Enforcer can be left.")
    elseIf a_option == _oidBosmerOldContract
        SetInfoText("Sets BosmerPath to OldContract for Green Pact proving.")
    elseIf a_option == _oidBosmerBanditRoad
        SetInfoText("Sets BosmerPath to BanditRoad to prove non-OldContract handling.")
    elseIf a_option == _oidBosmerGreenPactViolation
        SetInfoText("Triggers one PDV-owned Green Pact violation. Only OldContract should react.")
    elseIf a_option == _oidDunmerPrayer
        SetInfoText("Records one portable-shrine ancestor prayer on the Dunmer substrate.")
    elseIf a_option == _oidDunmerHomeBonus
        SetInfoText("Records one player-home ancestor bonus on the Dunmer substrate.")
    elseIf a_option == _oidKhajiitMoonObservance
        SetInfoText("Records one Khajiit moon observance and advances the observed phase for proving.")
    elseIf a_option == _oidKhajiitRoadHome
        SetInfoText("Records one Khajiit road-home cadence event.")
    elseIf a_option == _oidKyneFavorCycle
        SetInfoText("Cycles the three-condition Kyne contextual-favor mask and recomputes the family-cap result.")
    elseIf a_option == _oidEvaluateCommitmentOffer
        SetInfoText("Evaluates the first real non-Khajiit Kyne commitment offer in dev-safe form.")
    elseIf a_option == _oidAcceptCommitmentOffer
        SetInfoText("Accepts the pending commitment offer and applies carry-over behavior.")
    elseIf a_option == _oidDeclineCommitmentOffer
        SetInfoText("Declines the pending commitment offer and postpones it.")
    elseIf a_option == _oidRefuseCommitmentOffer
        SetInfoText("Refuses the pending commitment offer and applies rupture/cooldown.")
    elseIf a_option == _oidHircineHuntRite
        SetInfoText("Records one Hircine hunt rite and advances the boon/price/stigma contract.")
    elseIf a_option == _oidHircineRenounce
        SetInfoText("Renounces the Hircine path and resets the proving contract state.")
    else
        SetInfoText("")
    endIf
EndFunction

Function OnOptionSelect(Int a_option)
    if a_option == _oidSelectedDeity
        CycleSelectedDeity()
        ForcePageReset()
        return
    endIf

    if a_option == _oidDebugPatronOverride
        DebugOverridePatron()
        return
    endIf

    if a_option == _oidDebugClearPatron
        DebugClearPatron()
        return
    endIf

    if a_option == _oidDebugResetDeity
        DebugResetSelectedDeity()
        return
    endIf

    if a_option == _oidApplyPiety
        DebugApplySelectedPiety()
        return
    endIf

    if a_option == _oidApplyPietyToday
        DebugApplySelectedPietyToday()
        return
    endIf

    if a_option == _oidApplyCuratedSignal
        DebugApplyCuratedSignal()
        return
    endIf

    if a_option == _oidRunDawn
        if ShowMessage("Run ProcessDawn now?", True, "$Yes", "$No")
            PDV_Manager.ProcessDawn()
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidShowPietyMap
        ShowMessage(PDV_Manager.DebugGetPietyMapString(), False, "$OK", "")
        return
    endIf

    if a_option == _oidShowStructuralMap
        ShowMessage(BuildStructuralMapString(), False, "$OK", "")
        return
    endIf

    if a_option == _oidRunScaffoldApiSmoke
        if ShowMessage("Run the structural scaffold API smoke now?", True, "$Yes", "$No")
            ShowMessage(RunScaffoldApiSmoke(), False, "$OK", "")
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidShowPatternSummary
        ShowMessage(GetPatternSummaryString(), False, "$OK", "")
        return
    endIf

    if a_option == _oidConcordatDefiance
        RunPatternAction("Route one Concordat defiance event?", 1)
        return
    endIf

    if a_option == _oidConcordatCompliance
        RunPatternAction("Route one Concordat compliance event?", 2)
        return
    endIf

    if a_option == _oidTalosShrineDefiance
        RunPatternAction("Route one Talos shrine defiance signal?", 18)
        return
    endIf

    if a_option == _oidConcordatUnlockGate
        RunPatternAction("Unlock the Concordat extreme walk-back gate?", 3)
        return
    endIf

    if a_option == _oidBosmerOldContract
        RunPatternAction("Set BosmerPath to OldContract?", 4)
        return
    endIf

    if a_option == _oidBosmerBanditRoad
        RunPatternAction("Set BosmerPath to BanditRoad?", 5)
        return
    endIf

    if a_option == _oidBosmerGreenPactViolation
        RunPatternAction("Trigger one Green Pact violation?", 6)
        return
    endIf

    if a_option == _oidDunmerPrayer
        RunPatternAction("Record one Dunmer ancestor prayer?", 7)
        return
    endIf

    if a_option == _oidDunmerHomeBonus
        RunPatternAction("Record one Dunmer home bonus?", 8)
        return
    endIf

    if a_option == _oidKhajiitMoonObservance
        RunPatternAction("Record one Khajiit moon observance?", 9)
        return
    endIf

    if a_option == _oidKhajiitRoadHome
        RunPatternAction("Record one Khajiit road-home cadence event?", 10)
        return
    endIf

    if a_option == _oidKyneFavorCycle
        RunPatternAction("Cycle the Kyne contextual-favor condition mask?", 11)
        return
    endIf

    if a_option == _oidEvaluateCommitmentOffer
        RunPatternAction("Evaluate the Kyne commitment offer now?", 12)
        return
    endIf

    if a_option == _oidAcceptCommitmentOffer
        RunPatternAction("Accept the pending commitment offer?", 13)
        return
    endIf

    if a_option == _oidDeclineCommitmentOffer
        RunPatternAction("Decline the pending commitment offer?", 14)
        return
    endIf

    if a_option == _oidRefuseCommitmentOffer
        RunPatternAction("Refuse the pending commitment offer?", 15)
        return
    endIf

    if a_option == _oidHircineHuntRite
        RunPatternAction("Record one Hircine hunt rite?", 16)
        return
    endIf

    if a_option == _oidHircineRenounce
        RunPatternAction("Renounce the Hircine path?", 17)
    endIf
EndFunction

Function OnOptionSliderOpen(Int a_option)
    if a_option == _oidDebugLevel
        SetSliderDialogStartValue(GetDebugLevelValue())
        SetSliderDialogDefaultValue(GetDebugLevelValue())
        SetSliderDialogRange(DEBUG_LEVEL_MIN as Float, DEBUG_LEVEL_MAX as Float)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidPendingPiety
        SetSliderDialogStartValue(_pendingPiety)
        SetSliderDialogDefaultValue(GetSelectedDeityPiety())
        SetSliderDialogRange(PIETY_MIN, PIETY_MAX)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidPendingPietyToday
        SetSliderDialogStartValue(_pendingPietyToday)
        SetSliderDialogDefaultValue(GetSelectedDeityPietyToday())
        SetSliderDialogRange(PIETY_TODAY_MIN, PIETY_TODAY_MAX)
        SetSliderDialogInterval(0.25)
        return
    endIf

    if a_option == _oidPendingSignalType
        SetSliderDialogStartValue(_pendingSignalType as Float)
        SetSliderDialogDefaultValue(_pendingSignalType as Float)
        SetSliderDialogRange(SIGNAL_TYPE_MIN, SIGNAL_TYPE_MAX)
        SetSliderDialogInterval(1.0)
    endIf
EndFunction

Function OnOptionSliderAccept(Int a_option, Float a_value)
    if a_option == _oidDebugLevel
        PDV__ManagerQuest manager = GetManagerService()
        if manager
            manager.SetDebugLevel(a_value as Int)
        endIf
        SetSliderOptionValue(_oidDebugLevel, GetDebugLevelValue(), "{0}", False)
        return
    endIf

    if a_option == _oidPendingPiety
        _pendingPiety = ClampFloat(a_value, PIETY_MIN, PIETY_MAX)
        SetSliderOptionValue(_oidPendingPiety, _pendingPiety, "{0}", False)
        return
    endIf

    if a_option == _oidPendingPietyToday
        _pendingPietyToday = ClampFloat(a_value, PIETY_TODAY_MIN, PIETY_TODAY_MAX)
        SetSliderOptionValue(_oidPendingPietyToday, _pendingPietyToday, "{1}", False)
        return
    endIf

    if a_option == _oidPendingSignalType
        _pendingSignalType = ClampSignalType(a_value as Int)
        SetSliderOptionValue(_oidPendingSignalType, _pendingSignalType as Float, "{0}", False)
    endIf
EndFunction

Function BuildStatusPage()
    Int activeDeityIndex = GetActiveDeityIndexValue()
    Int deityCount = GetDeityCount()

    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Current state", OPTION_FLAG_NONE)
    AddTextOption("Active patron", GetActivePatronLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Patron state", GetPatronStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Active piety", FormatFloat(GetActivePietyValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active tier", TierToLabel(GetActiveTierValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active deity index", GetIndexLabel(activeDeityIndex), OPTION_FLAG_DISABLED)
    AddTextOption("Origin diagnostic", GetOriginDiagnosticLabel(), OPTION_FLAG_DISABLED)
    AddEmptyOption()
    AddHeaderOption("Phase 8 Concordat", OPTION_FLAG_NONE)
    AddTextOption("Raw value", GetConcordatRawLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Committed state", GetConcordatStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Pending state", GetConcordatPendingStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Extreme gate", GetConcordatGateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Talos gain x", GetTalosGainMultiplierLabel(), OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Deity roster", OPTION_FLAG_NONE)

    if deityCount <= 0
        AddTextOption("Roster", "No deity quests found.", OPTION_FLAG_DISABLED)
        SetCursorFillMode(LEFT_TO_RIGHT)
        return
    endIf

    Int i = 0
    while i < deityCount
        PDV_DeityBase deity = PDV_Manager.GetDeityAtListIndex(i)
        if deity
            String rowValue = TierToLabel(PDV_Manager.GetTier(deity)) + " | " + FormatFloat(PDV_Manager.GetPiety(deity))
            if deity.DeityIndex == activeDeityIndex
                rowValue = rowValue + " | active"
            endIf
            AddTextOption(deity.DeityName, rowValue, OPTION_FLAG_DISABLED)
        endIf
        i += 1
    endWhile

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function BuildDebugPage()
    SyncSelection()

    AddHeaderOption("Target deity", OPTION_FLAG_NONE)
    _oidSelectedDeity = AddTextOption("Selected deity", GetSelectedDeityLabel(), OPTION_FLAG_NONE)
    _oidDebugPatronOverride = AddTextOption("Debug patron override", "Set selected deity active", OPTION_FLAG_NONE)
    _oidDebugClearPatron = AddTextOption("Clear patron override", GetActivePatronLabel(), OPTION_FLAG_NONE)
    _oidDebugResetDeity = AddTextOption("Reset selected deity", "Zero ledger", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Debug values", OPTION_FLAG_NONE)
    _oidDebugLevel = AddSliderOption("Debug level", GetDebugLevelValue(), "{0}", OPTION_FLAG_NONE)
    _oidPendingPiety = AddSliderOption("Target piety", _pendingPiety, "{0}", OPTION_FLAG_NONE)
    _oidApplyPiety = AddTextOption("Apply target piety", FormatFloat(_pendingPiety), OPTION_FLAG_NONE)
    _oidPendingPietyToday = AddSliderOption("Target scratch", _pendingPietyToday, "{1}", OPTION_FLAG_NONE)
    _oidApplyPietyToday = AddTextOption("Apply target scratch", FormatFloat(_pendingPietyToday), OPTION_FLAG_NONE)
    _oidPendingSignalType = AddSliderOption("Curated signal ID", _pendingSignalType as Float, "{0}", OPTION_FLAG_NONE)
    _oidApplyCuratedSignal = AddTextOption("Apply curated signal", GetSelectedSignalLabel(), OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Actions", OPTION_FLAG_NONE)
    _oidRunDawn = AddTextOption("Run dawn pass", "Consolidate scratch", OPTION_FLAG_NONE)
    _oidShowPietyMap = AddTextOption("Show piety map", "Message", OPTION_FLAG_NONE)
    _oidShowStructuralMap = AddTextOption("Show structural map", "Message", OPTION_FLAG_NONE)
    _oidRunScaffoldApiSmoke = AddTextOption("Run scaffold smoke", "API set/read/reset", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Pattern proving", OPTION_FLAG_NONE)
    _oidShowPatternSummary = AddTextOption("Show pattern summary", "Message", OPTION_FLAG_NONE)
    _oidConcordatDefiance = AddTextOption("Concordat defiance", "EventBus route", OPTION_FLAG_NONE)
    _oidConcordatCompliance = AddTextOption("Concordat compliance", "EventBus route", OPTION_FLAG_NONE)
    _oidTalosShrineDefiance = AddTextOption("Talos shrine defiance", "Shrine route", OPTION_FLAG_NONE)
    _oidConcordatUnlockGate = AddTextOption("Unlock Concordat gate", "Extreme walk-back", OPTION_FLAG_NONE)
    _oidBosmerOldContract = AddTextOption("Bosmer set OldContract", "State pilot", OPTION_FLAG_NONE)
    _oidBosmerBanditRoad = AddTextOption("Bosmer set BanditRoad", "State pilot", OPTION_FLAG_NONE)
    _oidBosmerGreenPactViolation = AddTextOption("Green Pact violation", "OldContract only", OPTION_FLAG_NONE)
    _oidDunmerPrayer = AddTextOption("Dunmer ancestor prayer", "Substrate pilot", OPTION_FLAG_NONE)
    _oidDunmerHomeBonus = AddTextOption("Dunmer home bonus", "Substrate pilot", OPTION_FLAG_NONE)
    _oidKhajiitMoonObservance = AddTextOption("Khajiit moon observance", "Emergent lane", OPTION_FLAG_NONE)
    _oidKhajiitRoadHome = AddTextOption("Khajiit road-home cadence", "Emergent lane", OPTION_FLAG_NONE)
    _oidKyneFavorCycle = AddTextOption("Cycle Kyne favor mask", "3-condition family", OPTION_FLAG_NONE)
    _oidEvaluateCommitmentOffer = AddTextOption("Evaluate commitment", "Dawn-equivalent", OPTION_FLAG_NONE)
    _oidAcceptCommitmentOffer = AddTextOption("Accept commitment", "Carry-over", OPTION_FLAG_NONE)
    _oidDeclineCommitmentOffer = AddTextOption("Decline commitment", "Postpone", OPTION_FLAG_NONE)
    _oidRefuseCommitmentOffer = AddTextOption("Refuse commitment", "Cooldown", OPTION_FLAG_NONE)
    _oidHircineHuntRite = AddTextOption("Hircine hunt rite", "Boon/price/stigma", OPTION_FLAG_NONE)
    _oidHircineRenounce = AddTextOption("Hircine renounce", "Restore path", OPTION_FLAG_NONE)
EndFunction

Function InitializePages()
    ModName = "PlayerDevotion"
    String[] configuredPages = new String[2]
    configuredPages[0] = PAGE_STATUS
    configuredPages[1] = PAGE_DEBUG
    Pages = configuredPages
EndFunction

Function CycleSelectedDeity()
    Int deityCount = GetDeityCount()
    if deityCount <= 0
        _selectedListIndex = -1
        return
    endIf

    _selectedListIndex += 1
    if _selectedListIndex >= deityCount
        _selectedListIndex = 0
    endIf
EndFunction

Function DebugOverridePatron()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Apply a debug patron override to " + deity.DeityName + "?", True, "$Yes", "$No")
        PDV_Manager.ForceSetActiveDeityByIndex(deity.DeityIndex)
        ForcePageReset()
    endIf
EndFunction

Function DebugClearPatron()
    if ShowMessage("Clear the current debug patron override?", True, "$Yes", "$No")
        PDV_Manager.DebugClearActiveDeity()
        ForcePageReset()
    endIf
EndFunction

Function DebugResetSelectedDeity()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Reset " + deity.DeityName + " to zero piety and tier 0?", True, "$Yes", "$No")
        PDV_Manager.DebugResetDeityByIndex(deity.DeityIndex)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplySelectedPiety()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Force " + deity.DeityName + " piety to " + FormatFloat(_pendingPiety) + "?", True, "$Yes", "$No")
        PDV_Manager.DebugForceSetPietyByIndex(deity.DeityIndex, _pendingPiety)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplySelectedPietyToday()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Force " + deity.DeityName + " scratch piety to " + FormatFloat(_pendingPietyToday) + "?", True, "$Yes", "$No")
        PDV_Manager.DebugForceSetPietyTodayByIndex(deity.DeityIndex, _pendingPietyToday)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplyCuratedSignal()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Apply curated signal " + _pendingSignalType + " to " + deity.DeityName + "?", True, "$Yes", "$No")
        PDV_Manager.DebugAwardCuratedSignalByIndex(deity.DeityIndex, _pendingSignalType)
        ForcePageReset()
    endIf
EndFunction

Function SyncSelection()
    Int deityCount = GetDeityCount()
    if deityCount <= 0
        _selectedListIndex = -1
        return
    endIf

    if _selectedListIndex < 0
        _selectedListIndex = 0
    elseIf _selectedListIndex >= deityCount
        _selectedListIndex = deityCount - 1
    endIf
EndFunction

PDV_DeityBase Function GetSelectedDeity()
    SyncSelection()
    if _selectedListIndex < 0
        return None
    endIf
    return PDV_Manager.GetDeityAtListIndex(_selectedListIndex)
EndFunction

Int Function GetDeityCount()
    if PDV_Manager
        return PDV_Manager.GetDeityCount()
    endIf
    if PDV_FLST_AllDeities
        return PDV_FLST_AllDeities.GetSize()
    endIf
    return 0
EndFunction

String Function GetSelectedDeityLabel()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        return "None"
    endIf
    return deity.DeityName + " [" + deity.DeityIndex + "]"
EndFunction

String Function GetActivePatronLabel()
    Int activeDeityIndex = GetActiveDeityIndexValue()
    if activeDeityIndex < 0 || !PDV_Manager
        return "None"
    endIf

    PDV_DeityBase deity = PDV_Manager.GetDeityByIndex(activeDeityIndex)
    if deity
        return deity.DeityName + " [" + deity.DeityIndex + "]"
    endIf

    return "Unknown [" + activeDeityIndex + "]"
EndFunction

String Function GetPatronStateLabel()
    if PDV_Manager
        return PDV_Manager.GetPatronStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetOriginDiagnosticLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetOriginDiagnostic()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatRawLabel()
    if PDV_Manager
        return "" + PDV_Manager.DebugGetConcordatRawValue()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatStateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatPendingStateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatPendingStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatGateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatGateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetTalosGainMultiplierLabel()
    if PDV_Manager
        return FormatFloat(PDV_Manager.GetTalosEffectiveGainMultiplier()) + " (track " + FormatFloat(PDV_Manager.GetTalosTrackGainMultiplier()) + ")"
    endIf

    return "Unknown"
EndFunction

String Function GetSelectedSignalLabel()
    if _pendingSignalType == 101
        return "Talos shrine defiance"
    elseIf _pendingSignalType == 102
        return "Talos protect worshipper"
    elseIf _pendingSignalType == 103
        return "Talos defiance milestone"
    elseIf _pendingSignalType == 201
        return "Auri-El dawn acknowledgment"
    elseIf _pendingSignalType == 202
        return "Auri-El orthodoxy affirmation"
    endIf

    return "Signal " + _pendingSignalType
EndFunction

Float Function GetActivePietyValue()
    if PDV_GLO_ActivePiety
        return PDV_GLO_ActivePiety.GetValue()
    endIf
    return 0.0
EndFunction

Int Function GetActiveTierValue()
    if PDV_GLO_ActiveTier
        return PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return 0
EndFunction

Int Function GetActiveDeityIndexValue()
    if PDV_GLO_ActiveDeityIndex
        return PDV_GLO_ActiveDeityIndex.GetValueInt()
    endIf
    return -1
EndFunction

Float Function GetDebugLevelValue()
    GlobalVariable debugGlobal = GetDebugLevelGlobal()
    if debugGlobal
        return debugGlobal.GetValue()
    endIf
    return 0.0
EndFunction

Float Function GetPatronFormCacheValue()
    if PDV_GLO_PatronDeity
        return PDV_GLO_PatronDeity.GetValue()
    endIf
    return 0.0
EndFunction

Int Function ClampSignalType(Int value)
    if value < SIGNAL_TYPE_MIN as Int
        return SIGNAL_TYPE_MIN as Int
    elseIf value > SIGNAL_TYPE_MAX as Int
        return SIGNAL_TYPE_MAX as Int
    endIf
    return value
EndFunction

Float Function GetSelectedDeityPiety()
    PDV_DeityBase deity = GetSelectedDeity()
    if deity && PDV_Manager
        return PDV_Manager.GetPiety(deity)
    endIf
    return 0.0
EndFunction

Float Function GetSelectedDeityPietyToday()
    PDV_DeityBase deity = GetSelectedDeity()
    if deity && PDV_Manager
        return PDV_Manager.GetPietyToday(deity)
    endIf
    return 0.0
EndFunction

Function RunPatternAction(String promptText, Int actionId)
    PDV__ManagerQuest manager = GetManagerService()
    if !manager
        ShowMessage("PDV_Manager is not assigned.", False, "$OK", "")
        return
    endIf

    if !ShowMessage(promptText, True, "$Yes", "$No")
        return
    endIf

    if actionId == 1
        if PDV_EventBusService
            PDV_EventBusService.RouteConcordatPressure(False)
        endIf
    elseIf actionId == 2
        if PDV_EventBusService
            PDV_EventBusService.RouteConcordatPressure(True)
        endIf
    elseIf actionId == 3
        manager.DebugUnlockConcordatWalkback()
    elseIf actionId == 4
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_OLD_CONTRACT)
    elseIf actionId == 5
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_BANDIT_ROAD)
    elseIf actionId == 6
        if PDV_EventBusService
            PDV_EventBusService.RouteGreenPactViolation()
        else
            manager.DebugTriggerGreenPactViolation()
        endIf
    elseIf actionId == 7
        if PDV_EventBusService
            PDV_EventBusService.RouteDunmerPortableShrinePrayer()
        else
            manager.DebugRecordDunmerAncestorPrayer()
        endIf
    elseIf actionId == 8
        if PDV_EventBusService
            PDV_EventBusService.RouteDunmerPlayerHomeBonus()
        else
            manager.DebugRecordDunmerAncestorHomeBonus()
        endIf
    elseIf actionId == 9
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitMoonObservance(0)
        else
            manager.DebugRecordKhajiitMoonObservance()
        endIf
    elseIf actionId == 10
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitRoadHome()
        else
            manager.DebugRecordKhajiitRoadHome()
        endIf
    elseIf actionId == 11
        manager.DebugCycleKyneFavorMask()
    elseIf actionId == 12
        manager.DebugEvaluateCommitmentOffer()
    elseIf actionId == 13
        manager.DebugAcceptPendingCommitment()
    elseIf actionId == 14
        manager.DebugDeclinePendingCommitment()
    elseIf actionId == 15
        manager.DebugRefusePendingCommitment()
    elseIf actionId == 16
        if PDV_EventBusService
            PDV_EventBusService.RouteHircineHuntRite()
        else
            manager.DebugRecordHircineHuntRite()
        endIf
    elseIf actionId == 17
        manager.DebugRenounceHircinePath()
    elseIf actionId == 18
        if PDV_EventBusService
            PDV_EventBusService.RouteTalosShrineDefiance()
        else
            manager.DebugRecordTalosShrineDefiance()
        endIf
    endIf

    ShowMessage(GetPatternSummaryString(), False, "$OK", "")
    ForcePageReset()
EndFunction

String Function GetPatternSummaryString()
    PDV__ManagerQuest manager = GetManagerService()
    if manager
        return manager.DebugGetPatternProvingSummary()
    endIf

    return "Pattern proving summary unavailable."
EndFunction

PDV__ManagerQuest Function GetManagerService()
    if PDV_Manager
        return PDV_Manager
    endIf

    if PDV_EventBusService && PDV_EventBusService.PDV_Manager
        return PDV_EventBusService.PDV_Manager
    endIf

    return None
EndFunction

GlobalVariable Function GetDebugLevelGlobal()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel
    endIf

    if PDV_EventBusService && PDV_EventBusService.PDV_GLO_DebugLevel
        return PDV_EventBusService.PDV_GLO_DebugLevel
    endIf

    return None
EndFunction

String Function BuildStructuralMapString()
    String output = "Rep=" + GetFormListCount(PDV_FLST_RepTracks_All)
    output = output + "; State=" + GetFormListCount(PDV_FLST_StateTracks_All)
    output = output + "; Substrate=" + GetFormListCount(PDV_FLST_Substrates_All)
    output = output + "; Sacred=" + GetFormListCount(PDV_FLST_SacredPlaces_All)
    output = output + "; Daedric=" + GetFormListCount(PDV_FLST_DaedricPaths_All)
    output = output + "; Curse=" + GetCurseServiceLabel()
    return output
EndFunction

String Function RunScaffoldApiSmoke()
    String output = RunReputationTrackSmoke()
    output = output + "; " + RunStateTrackSmoke()
    output = output + "; " + RunSubstrateSmoke()
    output = output + "; " + RunSacredPlaceSmoke()
    output = output + "; " + RunDaedricSmoke()
    output = output + "; " + RunCurseStateSmoke()
    return output
EndFunction

String Function RunReputationTrackSmoke()
    PDV_ReputationTrack track = GetFirstReputationTrack()
    if !track
        return "Rep missing"
    endIf

    Int oldValue = track.GetValue()
    Int adjustment = 1
    if oldValue >= track.MaxValue
        adjustment = -1
    endIf

    track.Adjust(adjustment, "mcm_scaffold_smoke")
    Int adjustedValue = track.GetValue()
    track.ForceSet(oldValue, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: reputation " + track.TrackName + " " + oldValue + " -> " + adjustedValue + " -> " + track.GetValue())
    return "Rep ok"
EndFunction

String Function RunStateTrackSmoke()
    PDV_StateTrack track = GetFirstStateTrack()
    if !track
        return "State missing"
    endIf

    Int oldState = track.GetCurrentState()
    Int smokeState = 0
    if oldState == 0
        smokeState = 1
    endIf

    track.SetState(smokeState, "mcm_scaffold_smoke")
    Int adjustedState = track.GetCurrentState()
    track.SetState(oldState, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: state " + track.TrackName + " " + oldState + " -> " + adjustedState + " -> " + track.GetCurrentState())
    return "State ok"
EndFunction

String Function RunSubstrateSmoke()
    PDV_SubstrateBase substrate = GetFirstSubstrate()
    if !substrate
        return "Substrate missing"
    endIf

    Float oldMetric = substrate.GetMetric()
    substrate.AdjustMetric(1.0, "mcm_scaffold_smoke")
    Float adjustedMetric = substrate.GetMetric()
    substrate.ResetForDebug()
    substrate.SetMetric(oldMetric, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: substrate " + substrate.SubstrateName + " " + oldMetric + " -> " + adjustedMetric + " -> " + substrate.GetMetric())
    return "Substrate ok"
EndFunction

String Function RunSacredPlaceSmoke()
    PDV_SacredPlace place = GetFirstSacredPlace()
    if !place
        return "Sacred missing"
    endIf

    Float oldDecay = place.GetMissedVisitDecay()
    place.DebugForceMissedVisitDecay(oldDecay + 1.0)
    Float adjustedDecay = place.GetMissedVisitDecay()
    place.DebugForceMissedVisitDecay(oldDecay)
    Debug.Trace("[PDV] MCM ScaffoldSmoke: sacred place " + place.PlaceName + " " + oldDecay + " -> " + adjustedDecay + " -> " + place.GetMissedVisitDecay())
    return "Sacred ok"
EndFunction

String Function RunDaedricSmoke()
    PDV_DaedricPathBase path = GetFirstDaedricPath()
    if !path
        return "Daedric missing"
    endIf

    Int oldSignals = path.GetCommitmentSignalCount()
    Float oldStigma = path.GetStigma()
    path.AddCommitmentSignal("mcm_scaffold_smoke")
    path.AddStigma(1.0, "mcm_scaffold_smoke")
    Int adjustedSignals = path.GetCommitmentSignalCount()
    Float adjustedStigma = path.GetStigma()
    path.ResetDaedricForDebug()
    path.DebugForceCommitmentSignals(oldSignals, "mcm_scaffold_restore")
    path.DebugForceStigma(oldStigma, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: daedric " + path.DeityName + " sig " + oldSignals + " -> " + adjustedSignals + "; stigma " + oldStigma + " -> " + adjustedStigma)
    return "Daedric ok"
EndFunction

String Function RunCurseStateSmoke()
    if !PDV_CurseStateService
        return "Curse missing"
    endIf

    Int oldState = PDV_CurseStateService.GetCurseState()
    PDV_CurseStateService.SetCurseState(PDV_CurseStateService.CURSE_UNKNOWN, "mcm_scaffold_smoke")
    Int adjustedState = PDV_CurseStateService.GetCurseState()
    if oldState == PDV_CurseStateService.CURSE_NONE
        PDV_CurseStateService.ClearCurseState("mcm_scaffold_restore")
    else
        PDV_CurseStateService.SetCurseState(oldState, "mcm_scaffold_restore")
    endIf
    Debug.Trace("[PDV] MCM ScaffoldSmoke: curse " + oldState + " -> " + adjustedState + " -> " + PDV_CurseStateService.GetCurseState())
    return "Curse ok"
EndFunction

PDV_ReputationTrack Function GetFirstReputationTrack()
    if !PDV_FLST_RepTracks_All || PDV_FLST_RepTracks_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_RepTracks_All.GetAt(0) as PDV_ReputationTrack
EndFunction

PDV_StateTrack Function GetFirstStateTrack()
    if !PDV_FLST_StateTracks_All || PDV_FLST_StateTracks_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_StateTracks_All.GetAt(0) as PDV_StateTrack
EndFunction

PDV_SubstrateBase Function GetFirstSubstrate()
    if !PDV_FLST_Substrates_All || PDV_FLST_Substrates_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_Substrates_All.GetAt(0) as PDV_SubstrateBase
EndFunction

PDV_SacredPlace Function GetFirstSacredPlace()
    if !PDV_FLST_SacredPlaces_All || PDV_FLST_SacredPlaces_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_SacredPlaces_All.GetAt(0) as PDV_SacredPlace
EndFunction

PDV_DaedricPathBase Function GetFirstDaedricPath()
    if !PDV_FLST_DaedricPaths_All || PDV_FLST_DaedricPaths_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_DaedricPaths_All.GetAt(0) as PDV_DaedricPathBase
EndFunction

Int Function GetFormListCount(FormList listRef)
    if listRef
        return listRef.GetSize()
    endIf
    return 0
EndFunction

String Function GetCurseServiceLabel()
    if PDV_CurseStateService
        return PDV_CurseStateService.GetCurseStateLabel()
    endIf
    return "Missing"
EndFunction

String Function TierToLabel(Int tierValue)
    if tierValue == 3
        return "Champion"
    elseIf tierValue == 2
        return "Devoted"
    elseIf tierValue == 1
        return "Seeker"
    endIf
    return "None (0)"
EndFunction

String Function GetIndexLabel(Int indexValue)
    if indexValue < 0
        return "None"
    endIf
    return "" + indexValue
EndFunction

String Function FormatFloat(Float value)
    return "" + value
EndFunction

Float Function ClampFloat(Float value, Float minValue, Float maxValue)
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction
