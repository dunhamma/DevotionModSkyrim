;/
    PDV_Substrate_ImperialAncestor.psc
    PlayerDevotion - Imperial civic substrate
    -----------------------------------------------------------------------
    Always-on Imperial identity layer. Civic service, honest work, disciplined
    Concordat pressure, and exact Talos defiance deepen civic standing and band
    into a highest-slot boon without requiring an active patron.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_ImperialAncestor extends PDV_SubstrateBase

Float Property DawnDecay = 1.0 Auto
Float Property DawnGraceDays = 3.0 Auto
Float Property NonCurseFloor = 20.0 Auto

Int Property POSTURE_QUIET = 0 AutoReadOnly
Int Property POSTURE_STEADY = 1 AutoReadOnly
Int Property POSTURE_DISCIPLINED = 2 AutoReadOnly

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "imperial_civic"
EndFunction

Function RecordCivicStanding(String reason)
    RecordCivicStandingScaled(1.0, reason)
EndFunction

Function RecordCivicStandingScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Civic standing blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.SourceCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("imperial_civic", reason, 1.0)
    Trace(2, "Civic standing recorded with daily credit " + awarded)
EndFunction

Function ProcessCivicDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = GetDevotionalDay()
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = GetLastAcceptedDevotionalDay()
    Int dayDelta = currentDay - lastMaintenanceDay
    if !HasAcceptedSubstrateCredit()
        dayDelta = (DawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (DawnGraceDays as Int)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Float floorValue = NonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldStanding = GetCivicStanding()
    if oldStanding <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastDecayDay", currentDay)
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

    SetMetric(newStanding, "civic_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastDecayDay", currentDay)
    Trace(2, "Civic dawn decay " + oldStanding + " -> " + newStanding)
EndFunction

Float Function GetCivicStanding()
    return GetMetric()
EndFunction

Int Function GetCivicPosture()
    Float standing = GetCivicStanding()
    if standing >= HighThreshold
        return POSTURE_DISCIPLINED
    elseIf standing >= MidThreshold
        return POSTURE_STEADY
    endIf

    return POSTURE_QUIET
EndFunction

String Function GetCivicPostureLabel()
    Int posture = GetCivicPosture()
    if posture == POSTURE_DISCIPLINED
        return "disciplined"
    elseIf posture == POSTURE_STEADY
        return "steady"
    endIf

    return "quiet"
EndFunction

Int Function GetSourceCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.SourceCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetCivicStanding() + "; tier=" + GetSubstrateTier() + "; posture=" + GetCivicPostureLabel() + "; sources=" + GetSourceCount() + "; last=" + StorageUtil.GetStringValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastReason")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.SourceCount", 0)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastReason", "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastEvent", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastMaintenanceDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ImperialAncestor.LastDecayDay", 0)
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
        Debug.Trace("[PDV] ImperialAncestor: " + traceText)
    endIf
EndFunction
