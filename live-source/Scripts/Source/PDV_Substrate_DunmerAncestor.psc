;/
    PDV_Substrate_DunmerAncestor.psc
    PlayerDevotion - Dunmer ancestor proving pilot
    -----------------------------------------------------------------------
    Concrete cultural-practice helper. Portable and home prayer are authentic
    routes into the same daily substrate budget; home presence is not a second
    metric bonus and this script does not change patron piety.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_DunmerAncestor extends PDV_SubstrateBase

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "dunmer_portable_prayer" || sourceId == "dunmer_home_prayer"
EndFunction

Float Property PrayerDelta = 5.0 Auto ; Legacy VMAD compatibility.
Float Property HomeBonusDelta = 8.0 Auto ; Legacy VMAD compatibility.

Function RecordPortableShrinePrayer(String reason)
    RecordPortableShrinePrayerScaled(1.0, reason)
EndFunction

Function RecordPortableShrinePrayerScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Portable shrine prayer blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.PrayerCount", 1)
    ; Dunmer curse posture is the explicit reduced-credit exception. Preserve
    ; the validated weight all the way into the shared +4 daily grant.
    Float awarded = TryAwardSubstrateDayCredit("dunmer_portable_prayer", reason, normalizedMultiplier)
    Trace(2, "Portable shrine prayer recorded with daily credit " + awarded)
EndFunction

Function RecordPlayerHomeBonus(String reason)
    RecordPlayerHomeBonusScaled(1.0, reason)
EndFunction

Function RecordPlayerHomeBonusScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Home prayer blocked for " + reason)
        return
    endIf

    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.HomeCount", 1)
    Float awarded = TryAwardSubstrateDayCredit("dunmer_home_prayer", reason, normalizedMultiplier)
    Trace(2, "Player-home prayer recorded with daily credit " + awarded)
EndFunction

Int Function GetPrayerCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.PrayerCount")
EndFunction

Int Function GetHomeBonusCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.HomeCount")
EndFunction

String Function GetPilotSummary()
    return "metric=" + GetMetric() + "; tier=" + GetSubstrateTier() + "; prayers=" + GetPrayerCount() + "; homes=" + GetHomeBonusCount()
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.PrayerCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.HomeCount", 0)
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
        Debug.Trace("[PDV] DunmerAncestor: " + traceText)
    endIf
EndFunction
