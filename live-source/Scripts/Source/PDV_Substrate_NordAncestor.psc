;/
    PDV_Substrate_NordAncestor.psc
    PlayerDevotion - Nord ancestor-spine substrate
    -----------------------------------------------------------------------
    Always-on Nord identity layer. Route acts deepen ancestral standing and
    band into a highest-slot-only boon without requiring an active patron.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_NordAncestor extends PDV_SubstrateBase

Float Property AncestorStandingDelta = 5.0 Auto
Float Property DawnDecay = 1.0 Auto
Float Property DawnGraceDays = 3.0 Auto
Float Property NonCurseFloor = 20.0 Auto

Int Property POSTURE_FORGOTTEN = 0 AutoReadOnly
Int Property POSTURE_REMEMBERED = 1 AutoReadOnly
Int Property POSTURE_HONORED = 2 AutoReadOnly

Function RecordAncestorStanding(String reason)
    RecordAncestorStandingScaled(1.0, reason)
EndFunction

Function RecordAncestorStandingScaled(Float multiplier, String reason)
    Float delta = AncestorStandingDelta * ClampSignalMultiplier(multiplier)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.SourceCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastEvent", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastMaintenanceDay", Utility.GetCurrentGameTime() as Int)
    AdjustMetric(delta, "ancestor_spine_" + reason)
    Trace(2, "Ancestor standing recorded with delta " + delta)
EndFunction

Function ProcessAncestorDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastMaintenanceDay")
    Int dayDelta = currentDay - lastMaintenanceDay
    if lastMaintenanceDay <= 0
        dayDelta = (DawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (DawnGraceDays as Int)
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

    Float newStanding = oldStanding - DawnDecay
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

String Function GetPilotSummary()
    return "metric=" + GetAncestorStanding() + "; tier=" + GetSubstrateTier() + "; posture=" + GetAncestorPostureLabel() + "; sources=" + GetSourceCount() + "; last=" + StorageUtil.GetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.SourceCount", 0)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastReason", "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.NordAncestor.LastEvent", 0.0)
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
