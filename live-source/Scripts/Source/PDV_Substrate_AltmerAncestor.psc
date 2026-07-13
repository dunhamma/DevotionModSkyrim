;/
    PDV_Substrate_AltmerAncestor.psc
    PlayerDevotion - Altmer heritage substrate
    -----------------------------------------------------------------------
    Always-on Altmer identity layer. Ordered rest, orthodoxy, disciplined
    study, craft, and exact milestones deepen heritage standing and band into
    a highest-slot boon without requiring an active patron.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_AltmerAncestor extends PDV_SubstrateBase

Float Property HeritageStandingDelta = 5.0 Auto ; Legacy VMAD compatibility.
Float Property DawnDecay = 1.0 Auto
Float Property DawnGraceDays = 3.0 Auto
Float Property NonCurseFloor = 20.0 Auto

Int Property POSTURE_QUIET = 0 AutoReadOnly
Int Property POSTURE_ORDERED = 1 AutoReadOnly
Int Property POSTURE_EXEMPLAR = 2 AutoReadOnly

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "altmer_heritage"
EndFunction

Function RecordHeritageStanding(String reason)
    RecordHeritageStandingScaled(1.0, reason)
EndFunction

Function RecordHeritageStandingScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Heritage standing blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.SourceCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("altmer_heritage", reason, 1.0)
    Trace(2, "Heritage standing recorded with daily credit " + awarded)
EndFunction

Function ProcessHeritageDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = GetDevotionalDay()
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = GetLastAcceptedDevotionalDay()
    Int dayDelta = currentDay - lastMaintenanceDay
    if !HasAcceptedSubstrateCredit()
        dayDelta = (DawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (DawnGraceDays as Int)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Float floorValue = NonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldStanding = GetHeritageStanding()
    if oldStanding <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastDecayDay", currentDay)
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

    SetMetric(newStanding, "heritage_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastDecayDay", currentDay)
    Trace(2, "Heritage dawn decay " + oldStanding + " -> " + newStanding)
EndFunction

Float Function GetHeritageStanding()
    return GetMetric()
EndFunction

Int Function GetHeritagePosture()
    Float standing = GetHeritageStanding()
    if standing >= HighThreshold
        return POSTURE_EXEMPLAR
    elseIf standing >= MidThreshold
        return POSTURE_ORDERED
    endIf

    return POSTURE_QUIET
EndFunction

String Function GetHeritagePostureLabel()
    Int posture = GetHeritagePosture()
    if posture == POSTURE_EXEMPLAR
        return "exemplar"
    elseIf posture == POSTURE_ORDERED
        return "ordered"
    endIf

    return "quiet"
EndFunction

Int Function GetSourceCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.SourceCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetHeritageStanding() + "; tier=" + GetSubstrateTier() + "; posture=" + GetHeritagePostureLabel() + "; sources=" + GetSourceCount() + "; last=" + StorageUtil.GetStringValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastReason")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.SourceCount", 0)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastReason", "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastEvent", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastMaintenanceDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.AltmerAncestor.LastDecayDay", 0)
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
        Debug.Trace("[PDV] AltmerAncestor: " + traceText)
    endIf
EndFunction
