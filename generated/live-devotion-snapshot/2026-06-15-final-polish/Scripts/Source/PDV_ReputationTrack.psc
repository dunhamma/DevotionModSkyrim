;/
    PDV_ReputationTrack.psc
    PlayerDevotion - V3 Structural Skeleton reputation track base
    -----------------------------------------------------------------------
    Continuous integer track for race-specific pressure such as Imperial
    ConcordatStanding, Altmer ThalmorAlignment, or Breton WitchcraftExposure.
    Inert until attached to a CK quest record.
    -----------------------------------------------------------------------
/;

Scriptname PDV_ReputationTrack extends Quest

String Property TrackName Auto
GlobalVariable Property StorageBacking Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property MinValue = -100 AutoReadOnly
Int Property MaxValue = 100 AutoReadOnly
Int[] Property ThresholdValues Auto
String[] Property ThresholdLabels Auto

Bool Property LockInOnCross = True Auto
Int Property LockInGraceDays = 3 Auto
Bool Property NarrativeGateRequiredForExtremeReset = False Auto
Int[] Property ExtremeStateIndexes Auto

Int Function GetValue()
    if StorageBacking
        return StorageBacking.GetValueInt()
    endIf

    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.Value")
EndFunction

Int Function GetStateIndex()
    RefreshState()
    return GetCommittedStateIndex()
EndFunction

String Function GetStateLabel()
    return GetStateLabelAt(GetStateIndex())
EndFunction

Int Function GetRawStateIndex()
    return ComputeStateIndexForValue(GetValue())
EndFunction

String Function GetRawStateLabel()
    return GetStateLabelAt(GetRawStateIndex())
EndFunction

Int Function GetPendingStateIndex()
    RefreshState()
    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.PendingState")
EndFunction

String Function GetPendingStateLabel()
    Int pendingState = GetPendingStateIndex()
    if pendingState < 0
        return "None"
    endIf

    return GetStateLabelAt(pendingState)
EndFunction

Bool Function IsTransitionPending()
    return GetPendingStateIndex() >= 0
EndFunction

Float Function GetLockInUntil()
    EnsureStateStorage()
    return StorageUtil.GetFloatValue(GetTrackForm(), "PDV.Track.LockInUntil")
EndFunction

String Function GetStateLabelAt(Int stateIndex)
    if stateIndex >= 0 && stateIndex < ThresholdLabels.Length
        return ThresholdLabels[stateIndex]
    endIf

    return "Unknown"
EndFunction

Bool Function CanAdvance(Int adjustment)
    return adjustment != 0
EndFunction

Bool Function RequiresExtremeResetGate()
    if NarrativeGateRequiredForExtremeReset
        return True
    endIf

    return TrackName == "ConcordatStanding"
EndFunction

Function Adjust(Int adjustment, String reason)
    if !CanAdvance(adjustment)
        Trace(2, "Adjust blocked for " + TrackName + ": " + reason)
        return
    endIf

    Int effectiveAdjustment = adjustment
    if ShouldHalveInwardAdjustment(adjustment)
        effectiveAdjustment = HalveAdjustment(adjustment)
        Trace(2, "Adjust halved at extreme for " + TrackName + ": " + adjustment + " -> " + effectiveAdjustment)
    endIf

    ForceSet(GetValue() + effectiveAdjustment, reason)
EndFunction

Function ForceSet(Int newValue, String reason)
    EnsureStateStorage()
    Int normalizedValue = ClampInt(newValue, MinValue, MaxValue)

    if StorageBacking
        StorageBacking.SetValue(normalizedValue as Float)
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.Value", normalizedValue)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.LastChanged", Utility.GetCurrentGameTime())

    RefreshState()

    Trace(2, "ForceSet " + TrackName + " raw=" + normalizedValue + ", state=" + GetStateLabel() + " (" + reason + ")")
EndFunction

Bool Function HasExtremeResetGate()
    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.ExtremeResetGate") == 1
EndFunction

Function UnlockExtremeResetGate(String reason)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.ExtremeResetGate", 1)
    Trace(2, "UnlockExtremeResetGate " + TrackName + " (" + reason + ")")
EndFunction

Function ClearExtremeResetGate(String reason)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.ExtremeResetGate", 0)
    Trace(2, "ClearExtremeResetGate " + TrackName + " (" + reason + ")")
EndFunction

Bool Function IsExtremeStateIndex(Int stateIndex)
    Int i = 0
    while i < ExtremeStateIndexes.Length
        if stateIndex == ExtremeStateIndexes[i]
            return True
        endIf
        i += 1
    endWhile

    if TrackName == "ConcordatStanding"
        return stateIndex == 0 || stateIndex == 4
    endIf

    return False
EndFunction

Int Function GetLowestExtremeStateIndex()
    if TrackName == "ConcordatStanding"
        return 0
    endIf

    Int lowestValue = 999
    Int i = 0
    while i < ExtremeStateIndexes.Length
        if ExtremeStateIndexes[i] < lowestValue
            lowestValue = ExtremeStateIndexes[i]
        endIf
        i += 1
    endWhile

    if lowestValue == 999
        return -1
    endIf

    return lowestValue
EndFunction

Int Function GetHighestExtremeStateIndex()
    if TrackName == "ConcordatStanding"
        return 4
    endIf

    Int highestValue = -1
    Int i = 0
    while i < ExtremeStateIndexes.Length
        if ExtremeStateIndexes[i] > highestValue
            highestValue = ExtremeStateIndexes[i]
        endIf
        i += 1
    endWhile

    return highestValue
EndFunction

Function RefreshState()
    EnsureStateStorage()

    if !LockInOnCross
        SyncCommittedStateToRaw()
        return
    endIf

    Int committedState = GetCommittedStateIndex()
    Int rawState = GetRawStateIndex()
    Int targetState = GetNextStateToward(committedState, rawState)

    if rawState == committedState
        ClearPendingTransition("raw_matches_committed")
        return
    endIf

    if ShouldBlockTransition(committedState, targetState)
        ClearPendingTransition("extreme_gate_locked")
        return
    endIf

    Int pendingState = StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.PendingState")
    if pendingState != targetState
        StartPendingTransition(targetState)
        return
    endIf

    if Utility.GetCurrentGameTime() >= GetLockInUntil()
        CommitState(targetState, "lockin_complete")
    endIf
EndFunction

Function EnsureStateStorage()
    if StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.Initialized") == 1
        return
    endIf

    Int rawState = GetRawStateIndex()
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.CommittedState", rawState)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.PendingState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.PendingStarted", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.LockInUntil", 0.0)
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.Initialized", 1)
    Trace(2, "Initialized state cache for " + TrackName + " at " + GetStateLabelAt(rawState))
EndFunction

Function SyncCommittedStateToRaw()
    Int rawState = GetRawStateIndex()
    Int committedState = GetCommittedStateIndex()
    if committedState != rawState
        CommitState(rawState, "sync_raw")
    else
        ClearPendingTransition("sync_raw")
    endIf
EndFunction

Int Function GetCommittedStateIndex()
    EnsureStateStorage()
    return StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.CommittedState")
EndFunction

Int Function ComputeStateIndexForValue(Int currentValue)
    Int currentState = 0
    Int i = 0

    while i < ThresholdValues.Length
        if currentValue > ThresholdValues[i]
            currentState += 1
        endIf
        i += 1
    endWhile

    return currentState
EndFunction

Int Function GetNextStateToward(Int currentState, Int targetState)
    if targetState > currentState
        return currentState + 1
    elseIf targetState < currentState
        return currentState - 1
    endIf

    return currentState
EndFunction

Bool Function ShouldBlockTransition(Int committedState, Int targetState)
    if !RequiresExtremeResetGate()
        return False
    endIf

    if !IsExtremeStateIndex(committedState)
        return False
    endIf

    if IsExtremeStateIndex(targetState)
        return False
    endIf

    return !HasExtremeResetGate()
EndFunction

Bool Function ShouldHalveInwardAdjustment(Int adjustment)
    if !RequiresExtremeResetGate()
        return False
    endIf

    if HasExtremeResetGate()
        return False
    endIf

    Int committedState = GetCommittedStateIndex()
    if committedState == GetLowestExtremeStateIndex() && adjustment > 0
        return True
    endIf

    if committedState == GetHighestExtremeStateIndex() && adjustment < 0
        return True
    endIf

    return False
EndFunction

Int Function HalveAdjustment(Int adjustment)
    if adjustment > 0
        Int halvedPositive = adjustment / 2
        if halvedPositive < 1
            return 1
        endIf
        return halvedPositive
    elseIf adjustment < 0
        Int halvedNegative = ((0 - adjustment) / 2)
        if halvedNegative < 1
            halvedNegative = 1
        endIf
        return 0 - halvedNegative
    endIf

    return 0
EndFunction

Function StartPendingTransition(Int pendingState)
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.PendingState", pendingState)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.PendingStarted", nowTime)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.LockInUntil", nowTime + (LockInGraceDays as Float))
    Trace(2, "Pending " + TrackName + " -> " + GetStateLabelAt(pendingState))
EndFunction

Function ClearPendingTransition(String reason)
    if StorageUtil.GetIntValue(GetTrackForm(), "PDV.Track.PendingState") < 0
        return
    endIf

    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.PendingState", -1)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.PendingStarted", 0.0)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.LockInUntil", 0.0)
    Trace(2, "Pending cleared for " + TrackName + " (" + reason + ")")
EndFunction

Function CommitState(Int newState, String reason)
    Int oldState = GetCommittedStateIndex()
    StorageUtil.SetIntValue(GetTrackForm(), "PDV.Track.CommittedState", newState)
    StorageUtil.SetFloatValue(GetTrackForm(), "PDV.Track.CommittedChanged", Utility.GetCurrentGameTime())
    ClearPendingTransition("commit")

    if IsExtremeStateIndex(oldState) && !IsExtremeStateIndex(newState)
        ClearExtremeResetGate("commit_" + reason)
    endIf

    Trace(2, "Committed " + TrackName + " " + GetStateLabelAt(oldState) + " -> " + GetStateLabelAt(newState) + " (" + reason + ")")
EndFunction

Form Function GetTrackForm()
    return Self as Form
EndFunction

Int Function ClampInt(Int value, Int minValue, Int maxValue)
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf

    return value
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] ReputationTrack: " + traceText)
    endIf
EndFunction

