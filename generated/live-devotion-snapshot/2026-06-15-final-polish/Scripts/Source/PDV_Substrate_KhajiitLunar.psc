;/ 
    PDV_Substrate_KhajiitLunar.psc
    PlayerDevotion - Khajiit lunar proving pilot
    -----------------------------------------------------------------------
    Concrete proving helper attached alongside the structural substrate base.
    Tracks moon observance and road-home cadence as separate dev-readable
    dimensions while keeping Khajiit patron emergence notification-free.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_KhajiitLunar extends PDV_SubstrateBase

Float Property MoonObservanceDelta = 4.0 Auto
Float Property RoadHomeDelta = 6.0 Auto

Function ObserveMoonPhase(Int phaseIndex, String reason)
    ObserveMoonPhaseScaled(phaseIndex, 1.0, reason)
EndFunction

Function ObserveMoonPhaseScaled(Int phaseIndex, Float multiplier, String reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.LastPhase", phaseIndex)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.ObservanceCount", 1)
    AdjustMetric(MoonObservanceDelta * ClampSignalMultiplier(multiplier), "moon_phase_" + phaseIndex + "_" + reason)
    Trace(2, "Moon observance recorded for phase " + phaseIndex)
EndFunction

Function RecordRoadHomeCadence(String reason)
    RecordRoadHomeCadenceScaled(1.0, reason)
EndFunction

Function RecordRoadHomeCadenceScaled(Float multiplier, String reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.RoadHomeCount", 1)
    AdjustMetric(RoadHomeDelta * ClampSignalMultiplier(multiplier), "road_home_" + reason)
    Trace(2, "Road-home cadence recorded.")
EndFunction

Int Function GetLastObservedPhase()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.LastPhase")
EndFunction

Int Function GetObservanceCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.ObservanceCount")
EndFunction

Int Function GetRoadHomeCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.RoadHomeCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetMetric() + "; tier=" + GetSubstrateTier() + "; phase=" + GetLastObservedPhase() + "; observance=" + GetObservanceCount() + "; roadhome=" + GetRoadHomeCount()
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.LastPhase", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.ObservanceCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.RoadHomeCount", 0)
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
        Debug.Trace("[PDV] KhajiitLunar: " + traceText)
    endIf
EndFunction
