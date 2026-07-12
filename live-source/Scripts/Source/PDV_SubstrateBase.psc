;/
    PDV_SubstrateBase.psc
    PlayerDevotion - V3 Structural Skeleton substrate base
    -----------------------------------------------------------------------
    Origin-gated identity layer for races with strong persistent substrates.
    Inert until attached to a CK quest record.
    -----------------------------------------------------------------------
/;

Scriptname PDV_SubstrateBase extends Quest

String Property SubstrateName Auto
Int Property RequiredOriginRace Auto
String Property StorageKeyPrefix = "PDV.Substrate" Auto

Spell Property Substrate_Always Auto
Spell Property Substrate_Mid Auto
Spell Property Substrate_High Auto

Float Property MidThreshold = 25.0 Auto
Float Property HighThreshold = 75.0 Auto
Float Property MetricMin = 0.0 AutoReadOnly
Float Property MetricMax = 100.0 AutoReadOnly

GlobalVariable Property PDV_GLO_OriginRace Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property SUBSTRATE_TIER_NONE = 0 AutoReadOnly
Int Property SUBSTRATE_TIER_LOW = 1 AutoReadOnly
Int Property SUBSTRATE_TIER_MID = 2 AutoReadOnly
Int Property SUBSTRATE_TIER_HIGH = 3 AutoReadOnly

Event OnInit()
    RegisterForSubstrateEvents()
EndEvent

Function RegisterForSubstrateEvents()
    ; Override per concrete substrate.
EndFunction

Bool Function IsOriginActive()
    if !PDV_GLO_OriginRace
        return False
    endIf

    return PDV_GLO_OriginRace.GetValueInt() == RequiredOriginRace
EndFunction

Float Function GetMetric()
    return StorageUtil.GetFloatValue(GetSubstrateForm(), GetMetricKey())
EndFunction

Function AdjustMetric(Float amount, String reason)
    SetMetric(GetMetric() + amount, reason)
EndFunction

Function SetMetric(Float newMetric, String reason)
    Float normalizedMetric = ClampFloat(newMetric, MetricMin, MetricMax)
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetMetricKey(), normalizedMetric)
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetLastEventKey(), Utility.GetCurrentGameTime())
    RecomputeSubstrateTier()
    Trace(2, "SetMetric " + SubstrateName + " = " + normalizedMetric + " (" + reason + ")")
EndFunction

Function ResetForDebug()
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetMetricKey(), 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetLastEventKey(), 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetTierKey(), SUBSTRATE_TIER_NONE)
    ClearSubstrateBoons()
    Trace(2, "ResetForDebug " + SubstrateName)
EndFunction

Int Function GetSubstrateTier()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetTierKey())
EndFunction

Int Function RecomputeSubstrateTier()
    Int oldTier = GetSubstrateTier()
    Int newTier = SUBSTRATE_TIER_LOW
    Float metric = GetMetric()

    if metric >= HighThreshold
        newTier = SUBSTRATE_TIER_HIGH
    elseIf metric >= MidThreshold
        newTier = SUBSTRATE_TIER_MID
    endIf

    if !IsOriginActive()
        newTier = SUBSTRATE_TIER_NONE
    endIf

    if oldTier != newTier
        StorageUtil.SetIntValue(GetSubstrateForm(), GetTierKey(), newTier)
        SyncSubstrateBoonsToTier(newTier)
        Trace(1, SubstrateName + " tier " + oldTier + " -> " + newTier)
    elseIf !IsSubstrateBoonStateCurrent(newTier)
        SyncSubstrateBoonsToTier(newTier)
        Trace(2, SubstrateName + " boon reconciled for tier " + newTier)
    endIf

    return newTier
EndFunction

Bool Function IsSubstrateBoonStateCurrent(Int tierValue)
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return True
    endIf

    Spell expectedSpell = GetExpectedSubstrateBoon(tierValue)
    if expectedSpell && !playerRef.HasSpell(expectedSpell)
        return False
    endIf
    if Substrate_Always && Substrate_Always != expectedSpell && playerRef.HasSpell(Substrate_Always)
        return False
    endIf
    if Substrate_Mid && Substrate_Mid != expectedSpell && playerRef.HasSpell(Substrate_Mid)
        return False
    endIf
    if Substrate_High && Substrate_High != expectedSpell && playerRef.HasSpell(Substrate_High)
        return False
    endIf

    return True
EndFunction

Spell Function GetExpectedSubstrateBoon(Int tierValue)
    if tierValue >= SUBSTRATE_TIER_HIGH && Substrate_High
        return Substrate_High
    elseIf tierValue >= SUBSTRATE_TIER_MID && Substrate_Mid
        return Substrate_Mid
    elseIf tierValue >= SUBSTRATE_TIER_LOW && Substrate_Always
        return Substrate_Always
    endIf

    return None
EndFunction

; Highest-slot-only: only the top reached substrate slot is granted, and that
; slot carries the cumulative magnitude (Always < Mid < High). Keeps the Active
; Effects list to ONE substrate identity boon instead of the full triad.
Function SyncSubstrateBoonsToTier(Int tierValue)
    ClearSubstrateBoons()

    Spell expectedSpell = GetExpectedSubstrateBoon(tierValue)
    if expectedSpell
        Game.GetPlayer().AddSpell(expectedSpell, False)
    endIf
EndFunction

Function ClearSubstrateBoons()
    if Substrate_Always
        Game.GetPlayer().RemoveSpell(Substrate_Always)
    endIf
    if Substrate_Mid
        Game.GetPlayer().RemoveSpell(Substrate_Mid)
    endIf
    if Substrate_High
        Game.GetPlayer().RemoveSpell(Substrate_High)
    endIf
EndFunction

String Function GetMetricKey()
    return StorageKeyPrefix + "." + SubstrateName + ".Metric"
EndFunction

String Function GetLastEventKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastEvent"
EndFunction

String Function GetTierKey()
    return StorageKeyPrefix + "." + SubstrateName + ".Tier"
EndFunction

Form Function GetSubstrateForm()
    return Self as Form
EndFunction

Float Function ClampFloat(Float value, Float minValue, Float maxValue)
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
        Debug.Trace("[PDV] SubstrateBase: " + traceText)
    endIf
EndFunction
