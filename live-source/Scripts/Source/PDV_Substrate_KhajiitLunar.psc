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

Float Property MoonObservanceDelta = 4.0 Auto ; Legacy VMAD compatibility.
Float Property RoadHomeDelta = 6.0 Auto ; Legacy VMAD compatibility.

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "khajiit_moon" || sourceId == "khajiit_road_home" || sourceId == "khajiit_lunar_source" || sourceId == "khajiit_caravan_defense" || sourceId == "khajiit_baandar_reversal" || sourceId == "khajiit_rajhin_notable_theft" || sourceId == "khajiit_alkosh_milestone"
EndFunction

Function ObserveMoonPhase(Int phaseIndex, String reason)
    ObserveMoonPhaseScaled(phaseIndex, 1.0, reason)
EndFunction

Function ObserveMoonPhaseScaled(Int phaseIndex, Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Moon observance blocked for " + reason)
        return
    endIf

    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.LastPhase", phaseIndex)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.ObservanceCount", 1)
    Float awarded = TryAwardSubstrateDayCredit("khajiit_moon", reason, 1.0)
    Trace(2, "Moon observance recorded for phase " + phaseIndex + " with daily credit " + awarded)
EndFunction

Function RecordRoadHomeCadence(String reason)
    RecordRoadHomeCadenceScaled(1.0, reason)
EndFunction

Function RecordRoadHomeCadenceScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Road-home cadence blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.KhajiitLunar.RoadHomeCount", 1)
    Float awarded = TryAwardSubstrateDayCredit("khajiit_road_home", reason, 1.0)
    Trace(2, "Road-home cadence recorded with daily credit " + awarded)
EndFunction

Function RecordCulturalSubstitute(String sourceId, String reason)
    Float awarded = TryAwardSubstrateDayCredit(sourceId, reason, 1.0)
    Trace(2, "Cultural substitute recorded with daily credit " + awarded + " (" + sourceId + ")")
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
