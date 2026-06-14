;/ 
    PDV_Substrate_DunmerAncestor.psc
    PlayerDevotion - Dunmer ancestor proving pilot
    -----------------------------------------------------------------------
    Concrete proving helper attached alongside the structural substrate base.
    Keeps ancestor metric inputs explicit so the first Pattern Proving wave
    can exercise prayer and home-bonus paths without changing patron piety.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_DunmerAncestor extends PDV_SubstrateBase

Float Property PrayerDelta = 5.0 Auto
Float Property HomeBonusDelta = 8.0 Auto

Function RecordPortableShrinePrayer(String reason)
    RecordPortableShrinePrayerScaled(1.0, reason)
EndFunction

Function RecordPortableShrinePrayerScaled(Float multiplier, String reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.PrayerCount", 1)
    AdjustMetric(PrayerDelta * ClampSignalMultiplier(multiplier), "ancestor_prayer_" + reason)
    Trace(2, "Portable shrine prayer recorded.")
EndFunction

Function RecordPlayerHomeBonus(String reason)
    RecordPlayerHomeBonusScaled(1.0, reason)
EndFunction

Function RecordPlayerHomeBonusScaled(Float multiplier, String reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.DunmerAncestor.HomeCount", 1)
    AdjustMetric(HomeBonusDelta * ClampSignalMultiplier(multiplier), "home_bonus_" + reason)
    Trace(2, "Player-home ancestor bonus recorded.")
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
