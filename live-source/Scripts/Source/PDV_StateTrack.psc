;/
    PDV_StateTrack.psc
    PlayerDevotion - V3 Structural Skeleton state track base
    -----------------------------------------------------------------------
    Categorical state track for path, mode, tradition, and crisis state.
    Inert until attached to a CK quest record.
    -----------------------------------------------------------------------
/;

Scriptname PDV_StateTrack extends Quest

String Property TrackName Auto
GlobalVariable Property StateGlobal Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property UnsetSentinel = -1 AutoReadOnly
String[] Property StateLabels Auto
Bool Property AllowsTransition = True Auto
Float Property OfferCooldownDays = 7.0 Auto
Float Property TransitionLockoutDays = 7.0 Auto

Int Function GetCurrentState()
    EnsureStateStorage()

    if StateGlobal
        return StateGlobal.GetValueInt()
    endIf

    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.State.Value")
EndFunction

String Function GetStateLabel()
    return GetStateLabelAt(GetCurrentState())
EndFunction

Int Function GetOfferedState()
    EnsureStateStorage()
    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.State.OfferedState")
EndFunction

String Function GetOfferedStateLabel()
    Int offeredState = GetOfferedState()
    if offeredState < 0
        return "None"
    endIf

    return GetStateLabelAt(offeredState)
EndFunction

Bool Function HasOfferedTransition()
    return GetOfferedState() >= 0
EndFunction

Int Function GetPendingState()
    EnsureStateStorage()
    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.State.PendingState")
EndFunction

String Function GetPendingStateLabel()
    Int pendingState = GetPendingState()
    if pendingState < 0
        return "None"
    endIf

    return GetStateLabelAt(pendingState)
EndFunction

Bool Function IsTransitionPending()
    return GetPendingState() >= 0
EndFunction

Float Function GetLastOfferAt()
    EnsureStateStorage()
    return StorageUtil.GetFloatValue(GetTrackForm(), "PDV.State.OfferedAt")
EndFunction

Float Function GetPendingStartedAt()
    EnsureStateStorage()
    return StorageUtil.GetFloatValue(GetTrackForm(), "PDV.State.PendingStarted")
EndFunction

Float Function GetTransitionLockoutUntil()
    EnsureStateStorage()
    return StorageUtil.GetFloatValue(GetTrackForm(), "PDV.State.LockoutUntil")
EndFunction

Bool Function IsTransitionLockedOut()
    return Utility.GetCurrentGameTime() < GetTransitionLockoutUntil()
EndFunction

String Function GetStateLabelAt(Int stateIndex)
    if StateLabels && stateIndex >= 0 && stateIndex < StateLabels.Length
        return StateLabels[stateIndex]
    endIf

    return "Unset"
EndFunction

Bool Function CanSetState(Int newState)
    if newState == GetCurrentState()
        return False
    endIf

    if AllowsTransition
        return True
    endIf

    return GetCurrentState() == UnsetSentinel
EndFunction

Function SetState(Int newState, String reason)
    EnsureStateStorage()

    if !CanSetState(newState)
        Trace(2, "SetState blocked for " + TrackName + ": " + reason)
        return
    endIf

    if newState < UnsetSentinel
        newState = UnsetSentinel
    endIf

    if StateGlobal
        StateGlobal.SetValue(newState as Float)
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.Value", newState)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.LastChanged", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.Initialized", 1)
    ClearOfferedTransition("set_state")
    ClearPendingTransition("set_state")

    Trace(2, "SetState " + TrackName + " = " + GetStateLabelAt(newState) + " (" + reason + ")")
EndFunction

Bool Function CanOfferTransition(Int newState)
    if newState == GetCurrentState()
        return False
    endIf

    if IsTransitionLockedOut()
        return False
    endIf

    return True
EndFunction

Function OfferTransition(Int newState, String reason)
    EnsureStateStorage()

    if !CanOfferTransition(newState)
        Trace(2, "OfferTransition blocked for " + TrackName + ": " + reason)
        return
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.OfferedState", newState)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.OfferedAt", Utility.GetCurrentGameTime())
    Trace(2, "Offered " + TrackName + " -> " + GetStateLabelAt(newState) + " (" + reason + ")")
EndFunction

Function AcceptOfferedTransition(String reason)
    EnsureStateStorage()

    Int offeredState = GetOfferedState()
    if offeredState < 0
        Trace(2, "AcceptOfferedTransition ignored for " + TrackName + ": no offered state.")
        return
    endIf

    StartPendingTransition(offeredState, reason)
    ClearOfferedTransition("accept")
EndFunction

Function RefuseOfferedTransition(String reason)
    Int offeredState = GetOfferedState()
    if offeredState < 0
        return
    endIf

    ClearOfferedTransition("refuse")
    SetTransitionLockout(OfferCooldownDays, "refuse_" + reason)
EndFunction

Function StartPendingTransition(Int newState, String reason)
    EnsureStateStorage()

    if !CanOfferTransition(newState)
        Trace(2, "StartPendingTransition blocked for " + TrackName + ": " + reason)
        return
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.PendingState", newState)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.PendingStarted", Utility.GetCurrentGameTime())
    Trace(2, "Pending " + TrackName + " -> " + GetStateLabelAt(newState) + " (" + reason + ")")
EndFunction

Function ConfirmPendingTransition(String reason)
    Int pendingState = GetPendingState()
    if pendingState < 0
        return
    endIf

    SetState(pendingState, reason)
    SetTransitionLockout(TransitionLockoutDays, "confirm_" + reason)
EndFunction

Function ClearOfferedTransition(String reason)
    if !HasOfferedTransition()
        return
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.OfferedState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.OfferedAt", 0.0)
    Trace(2, "Offered transition cleared for " + TrackName + " (" + reason + ")")
EndFunction

Function ClearPendingTransition(String reason)
    if !IsTransitionPending()
        return
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.PendingState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.PendingStarted", 0.0)
    Trace(2, "Pending transition cleared for " + TrackName + " (" + reason + ")")
EndFunction

Function CancelPendingTransition(String reason)
    if !IsTransitionPending()
        return
    endIf

    ClearPendingTransition("cancel_" + reason)
    SetTransitionLockout(OfferCooldownDays, "cancel_" + reason)
EndFunction

Function SetTransitionLockout(Float lockoutDays, String reason)
    Float untilTime = 0.0
    if lockoutDays > 0.0
        untilTime = Utility.GetCurrentGameTime() + lockoutDays
    endIf

    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.LockoutUntil", untilTime)
    Trace(2, "Transition lockout set for " + TrackName + " until " + untilTime + " (" + reason + ")")
EndFunction

Function RecordEvidenceDay(Int stateValue, String reason)
    EnsureStateStorage()

    if stateValue < 0
        return
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int encodedDay = currentDay + 1
    String latestKey = GetEvidenceLatestKey(stateValue)
    String previousKey = GetEvidencePreviousKey(stateValue)
    String thirdKey = GetEvidenceThirdKey(stateValue)
    Int latestDay = StorageUtil.GetIntValue(GetTrackForm(), latestKey)
    Int previousDay = StorageUtil.GetIntValue(GetTrackForm(), previousKey)
    Int thirdDay = StorageUtil.GetIntValue(GetTrackForm(), thirdKey)

    if latestDay == encodedDay
        return
    endIf

    if latestDay > 0
        thirdDay = previousDay
        previousDay = latestDay
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), latestKey, encodedDay)
    StorageUtil.SetIntValue(GetTrackForm(), previousKey, previousDay)
    StorageUtil.SetIntValue(GetTrackForm(), thirdKey, thirdDay)
    Trace(2, "Evidence recorded for " + TrackName + " -> " + GetStateLabelAt(stateValue) + " (" + reason + ")")
EndFunction

Int Function GetRecentEvidenceDayCount(Int stateValue, Int windowDays)
    if stateValue < 0
        return 0
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int latestDay = StorageUtil.GetIntValue(GetTrackForm(), GetEvidenceLatestKey(stateValue))
    Int previousDay = StorageUtil.GetIntValue(GetTrackForm(), GetEvidencePreviousKey(stateValue))
    Int thirdDay = StorageUtil.GetIntValue(GetTrackForm(), GetEvidenceThirdKey(stateValue))
    Int count = 0

    if IsEncodedDayWithinWindow(latestDay, currentDay, windowDays)
        count += 1
    endIf

    if previousDay != latestDay && IsEncodedDayWithinWindow(previousDay, currentDay, windowDays)
        count += 1
    endIf

    if thirdDay != latestDay && thirdDay != previousDay && IsEncodedDayWithinWindow(thirdDay, currentDay, windowDays)
        count += 1
    endIf

    return count
EndFunction

Bool Function HasRecentEvidenceDays(Int stateValue, Int requiredCount, Int windowDays)
    return GetRecentEvidenceDayCount(stateValue, windowDays) >= requiredCount
EndFunction

Function ResetForDebug()
    EnsureStateStorage()

    if StateGlobal
        StateGlobal.SetValue(UnsetSentinel as Float)
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.Value", UnsetSentinel)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.OfferedState", -1)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.PendingState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.OfferedAt", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.PendingStarted", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.LockoutUntil", 0.0)
    Trace(2, "ResetForDebug " + TrackName)
EndFunction

Form Function GetTrackForm()
    return Self as Form
EndFunction

Function EnsureStateStorage()
    if StorageUtil.GetIntValue(GetTrackForm(), "PDV.State.Initialized") == 1
        return
    endIf

    Int initialState = UnsetSentinel
    if StateGlobal
        initialState = StateGlobal.GetValueInt()
    else
        initialState = StorageUtil.GetIntValue(GetTrackForm(), "PDV.State.Value")
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.Value", initialState)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.OfferedState", -1)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.PendingState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.OfferedAt", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.PendingStarted", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.State.LockoutUntil", 0.0)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.State.Initialized", 1)
    Trace(2, "Initialized state storage for " + TrackName + " at " + GetStateLabelAt(initialState))
EndFunction

String Function GetEvidenceLatestKey(Int stateValue)
    return "PDV.State.Evidence." + stateValue + ".LatestDay"
EndFunction

String Function GetEvidencePreviousKey(Int stateValue)
    return "PDV.State.Evidence." + stateValue + ".PreviousDay"
EndFunction

String Function GetEvidenceThirdKey(Int stateValue)
    return "PDV.State.Evidence." + stateValue + ".ThirdDay"
EndFunction

Bool Function IsEncodedDayWithinWindow(Int encodedDay, Int currentDay, Int windowDays)
    if encodedDay <= 0
        return False
    endIf

    Int dayValue = encodedDay - 1
    Int dayDelta = currentDay - dayValue
    if dayDelta < 0
        return False
    endIf

    return dayDelta < windowDays
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] StateTrack: " + traceText)
    endIf
EndFunction
