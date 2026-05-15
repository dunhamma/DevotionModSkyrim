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
FormList Property PDV_FLST_AllDeities Auto
GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_PatronDeity Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property DEBUG_LEVEL_MIN = 0 AutoReadOnly
Int Property DEBUG_LEVEL_MAX = 3 AutoReadOnly
Float Property PIETY_MIN = 0.0 AutoReadOnly
Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_TODAY_MIN = -5.0 AutoReadOnly
Float Property PIETY_TODAY_MAX = 5.0 AutoReadOnly

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
Int _oidRunDawn = -1
Int _oidShowPietyMap = -1

Int _selectedListIndex = 0
Float _pendingPiety = 10.0
Float _pendingPietyToday = 1.0

Event OnInit()
    Parent.OnInit()
    InitializePages()
EndEvent

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
    elseIf a_option == _oidRunDawn
        SetInfoText("Runs ProcessDawn immediately so scratch piety consolidates into stored piety.")
    elseIf a_option == _oidShowPietyMap
        SetInfoText("Shows a compact live summary of each deity's stored piety, scratch piety, and tier.")
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

    if a_option == _oidRunDawn
        if ShowMessage("Run ProcessDawn now?", True, "$Yes", "$No")
            PDV_Manager.ProcessDawn()
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidShowPietyMap
        ShowMessage(PDV_Manager.DebugGetPietyMapString(), False, "$OK", "")
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
    endIf
EndFunction

Function OnOptionSliderAccept(Int a_option, Float a_value)
    if a_option == _oidDebugLevel
        PDV_Manager.SetDebugLevel(a_value as Int)
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
    endIf
EndFunction

Function BuildStatusPage()
    Int activeDeityIndex = GetActiveDeityIndexValue()
    Int deityCount = GetDeityCount()

    AddHeaderOption("Current state", OPTION_FLAG_NONE)
    AddTextOption("Active patron", GetActivePatronLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Active piety", FormatFloat(GetActivePietyValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active tier", TierToLabel(GetActiveTierValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active deity index", GetIndexLabel(activeDeityIndex), OPTION_FLAG_DISABLED)
    AddTextOption("Patron form cache", FormatFloat(GetPatronFormCacheValue()), OPTION_FLAG_DISABLED)
    AddEmptyOption()
    AddHeaderOption("Deity roster", OPTION_FLAG_NONE)

    if deityCount <= 0
        AddTextOption("Roster", "No deity quests found.", OPTION_FLAG_DISABLED)
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

    AddEmptyOption()
    AddHeaderOption("Actions", OPTION_FLAG_NONE)
    _oidRunDawn = AddTextOption("Run dawn pass", "Consolidate scratch", OPTION_FLAG_NONE)
    _oidShowPietyMap = AddTextOption("Show piety map", "Message", OPTION_FLAG_NONE)
EndFunction

Function InitializePages()
    ModName = "PlayerDevotion"
    if Pages == None || Pages.Length != 2
        Pages = new String[2]
    endIf
    Pages[0] = PAGE_STATUS
    Pages[1] = PAGE_DEBUG
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
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValue()
    endIf
    return 0.0
EndFunction

Float Function GetPatronFormCacheValue()
    if PDV_GLO_PatronDeity
        return PDV_GLO_PatronDeity.GetValue()
    endIf
    return 0.0
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

String Function TierToLabel(Int tierValue)
    if tierValue == 3
        return "Champion"
    elseIf tierValue == 2
        return "Devoted"
    elseIf tierValue == 1
        return "Seeker"
    endIf
    return "None"
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
