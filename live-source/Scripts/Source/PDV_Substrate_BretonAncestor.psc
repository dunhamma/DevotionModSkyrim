;/
    PDV_Substrate_BretonAncestor.psc
    PlayerDevotion - Breton ancestral-spine substrate
    -----------------------------------------------------------------------
    Always-on Breton identity layer. Vows, hidden art, Green Way observance,
    and inherited dreams deepen mixed mortal/Aldmeri standing and band into a
    highest-slot boon without requiring an active patron or tradition choice.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_BretonAncestor extends PDV_SubstrateBase

Float Property AncestralResistanceDelta = 5.0 Auto
Float Property DawnDecay = 1.0 Auto
Float Property DawnGraceDays = 3.0 Auto
Float Property NonCurseFloor = 20.0 Auto

Int Property POSTURE_LATENT = 0 AutoReadOnly
Int Property POSTURE_WARDED = 1 AutoReadOnly
Int Property POSTURE_AWAKENED = 2 AutoReadOnly

Function RecordAncestralResistance(String reason)
    RecordAncestralResistanceScaled(1.0, reason)
EndFunction

Function RecordAncestralResistanceScaled(Float multiplier, String reason)
    Float delta = AncestralResistanceDelta * ClampSignalMultiplier(multiplier)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.SourceCount", 1)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastReason", reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastEvent", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastMaintenanceDay", Utility.GetCurrentGameTime() as Int)
    AdjustMetric(delta, "breton_ancestor_" + reason)
    Trace(2, "Ancestral resistance recorded with delta " + delta)
EndFunction

Function ProcessAncestralDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastMaintenanceDay")
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

    Float oldStanding = GetAncestralResistance()
    if oldStanding <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Float newStanding = oldStanding - DawnDecay
    if newStanding < floorValue
        newStanding = floorValue
    endIf

    SetMetric(newStanding, "breton_ancestral_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastDecayDay", currentDay)
    Trace(2, "Ancestral dawn decay " + oldStanding + " -> " + newStanding)
EndFunction

Float Function GetAncestralResistance()
    return GetMetric()
EndFunction

Int Function GetAncestralPosture()
    Float standing = GetAncestralResistance()
    if standing >= HighThreshold
        return POSTURE_AWAKENED
    elseIf standing >= MidThreshold
        return POSTURE_WARDED
    endIf

    return POSTURE_LATENT
EndFunction

String Function GetAncestralPostureLabel()
    Int posture = GetAncestralPosture()
    if posture == POSTURE_AWAKENED
        return "awakened"
    elseIf posture == POSTURE_WARDED
        return "warded"
    endIf

    return "latent"
EndFunction

Int Function GetSourceCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.SourceCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetAncestralResistance() + "; tier=" + GetSubstrateTier() + "; posture=" + GetAncestralPostureLabel() + "; sources=" + GetSourceCount() + "; last=" + StorageUtil.GetStringValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastReason")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.SourceCount", 0)
    StorageUtil.SetStringValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastReason", "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastEvent", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastMaintenanceDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.BretonAncestor.LastDecayDay", 0)
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
        Debug.Trace("[PDV] BretonAncestor: " + traceText)
    endIf
EndFunction
