;/
    PDV_Substrate_NordAncestor.psc
    PlayerDevotion - Nord ancestral-standing substrate
    -----------------------------------------------------------------------
    Always-on Nord identity layer. Route acts deepen ancestral standing and
    band into a highest-slot-only boon without requiring an active patron.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_NordAncestor extends PDV_SubstrateBase

Float Property AncestorStandingDelta = 5.0 Auto ; Legacy VMAD compatibility.
Float Property AncestralRestDelta = 3.0 Auto ; Legacy VMAD compatibility.
Float Property HearthReturnDelta = 2.0 Auto ; Legacy VMAD compatibility.
Float Property DawnDecay = 1.0 Auto
Float Property DawnGraceDays = 3.0 Auto
Float Property NonCurseFloor = 20.0 Auto

Int Property POSTURE_FORGOTTEN = 0 AutoReadOnly
Int Property POSTURE_REMEMBERED = 1 AutoReadOnly
Int Property POSTURE_HONORED = 2 AutoReadOnly

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "nord_ancestor_standing" || sourceId == "nord_ancestral_rest" || sourceId == "nord_hearth_return"
EndFunction

Function RecordAncestorStanding(String reason)
    RecordAncestorStandingScaled(1.0, reason)
EndFunction

Function RecordAncestorStandingScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Ancestor standing blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.SourceCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("nord_ancestor_standing", reason, 1.0)
    Trace(2, "Ancestor standing recorded with daily credit " + awarded)
EndFunction

Function RecordAncestralRest(String reason)
    RecordAncestralRestScaled(1.0, reason)
EndFunction

Function RecordAncestralRestScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Ancestral rest blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.RestCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastRestReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastRestEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("nord_ancestral_rest", reason, 1.0)
    Trace(2, "Ancestral rest recorded with daily credit " + awarded)
EndFunction

Function RecordHearthReturn(String reason)
    RecordHearthReturnScaled(1.0, reason)
EndFunction

Function RecordHearthReturnScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Hearth return blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.HearthReturnCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastHearthReturnReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastHearthReturnEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("nord_hearth_return", reason, 1.0)
    Trace(2, "Hearth return recorded with daily credit " + awarded)
EndFunction

Function ProcessAncestorDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = GetDevotionalDay()
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = GetLastAcceptedDevotionalDay()
    Int dayDelta = currentDay - lastMaintenanceDay
    if !HasAcceptedSubstrateCredit()
        dayDelta = (DawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (DawnGraceDays as Int)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Float floorValue = NonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldStanding = GetAncestorStanding()
    if oldStanding <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Int graceEndDay = lastMaintenanceDay + (DawnGraceDays as Int)
    if !HasAcceptedSubstrateCredit()
        graceEndDay = currentDay - 1
    endIf
    Int decayDays = currentDay - lastDecayDay
    if lastDecayDay < graceEndDay
        decayDays = currentDay - graceEndDay
    endIf
    if decayDays < 1
        decayDays = 1
    endIf
    Float newStanding = oldStanding - (DawnDecay * decayDays)
    if newStanding < floorValue
        newStanding = floorValue
    endIf

    SetMetric(newStanding, "ancestor_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay", currentDay)
    Trace(2, "Ancestor dawn decay " + oldStanding + " -> " + newStanding)
EndFunction

Float Function GetAncestorStanding()
    return GetMetric()
EndFunction

Int Function GetAncestorPosture()
    Float standing = GetAncestorStanding()
    if standing >= HighThreshold
        return POSTURE_HONORED
    elseIf standing >= MidThreshold
        return POSTURE_REMEMBERED
    endIf

    return POSTURE_FORGOTTEN
EndFunction

String Function GetAncestorPostureLabel()
    Int posture = GetAncestorPosture()
    if posture == POSTURE_HONORED
        return "honored"
    elseIf posture == POSTURE_REMEMBERED
        return "remembered"
    endIf

    return "forgotten"
EndFunction

Int Function GetSourceCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.SourceCount")
EndFunction

Int Function GetRestCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.RestCount")
EndFunction

Int Function GetHearthReturnCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.HearthReturnCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetAncestorStanding() + "; tier=" + GetSubstrateTier() + "; posture=" + GetAncestorPostureLabel() + "; sources=" + GetSourceCount() + "; rests=" + GetRestCount() + "; hearths=" + GetHearthReturnCount() + "; last=" + StorageUtil.GetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.SourceCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.RestCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.HearthReturnCount", 0)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason", "")
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastRestReason", "")
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastHearthReturnReason", "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastEvent", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastRestEvent", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastHearthReturnEvent", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastMaintenanceDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay", 0)
    Trace(2, "ResetPilotForDebug")
EndFunction

Float Function ClampSignalMultiplier(Float multiplier)
    if multiplier < 0.0
        return 0.0
    endIf

    return multiplier
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] NordAncestor: " + traceText)
    endIf
EndFunction
