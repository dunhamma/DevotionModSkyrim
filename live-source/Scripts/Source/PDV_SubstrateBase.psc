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
Float Property LowThreshold = 1.0 Auto
Float Property DailyCredit = 4.0 Auto
Float Property MetricMin = 0.0 AutoReadOnly
Float Property MetricMax = 75.0 AutoReadOnly

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

; One shared 06:00-to-06:00 cultural-practice budget for every substrate.
; Devotional day can be -1 before 06:00 on the first game day. The stored stamp
; therefore reserves zero and encodes devotionalDay + 2. Existing +1 stamps are
; migrated once so an unset value can never resemble a spent day. Route-specific
; soft-repeat multipliers do
; not scale the metric: callers pass 1.0 for an accepted act, 0.0 when a curse
; or other explicit gate blocks the act, and a documented fraction only for a
; real curse-specific reduced-credit rule.
Float Function TryAwardSubstrateDayCredit(String sourceId, String logicalEventId, Float creditMultiplier = 1.0)
    if !IsOriginActive()
        RecordDailyCreditReject(sourceId, logicalEventId, "wrong_origin")
        return 0.0
    endIf

    if creditMultiplier <= 0.0
        RecordDailyCreditReject(sourceId, logicalEventId, "blocked")
        return 0.0
    endIf

    if sourceId == "" || logicalEventId == ""
        RecordDailyCreditReject(sourceId, logicalEventId, "invalid_source")
        return 0.0
    endIf
    if !IsAuthenticSubstrateSource(sourceId)
        RecordDailyCreditReject(sourceId, logicalEventId, "unauthorized_source")
        return 0.0
    endIf

    EnsureDailyCreditStampEncoding()
    Int devotionalDay = GetDevotionalDay()
    Int dayStamp = GetDevotionalDayStamp()
    String previousLogicalEvent = StorageUtil.GetStringValue(GetSubstrateForm(), GetLastLogicalEventKey())
    if StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey()) == dayStamp
        if previousLogicalEvent == logicalEventId
            RecordDailyCreditReject(sourceId, logicalEventId, "duplicate_event")
        else
            RecordDailyCreditReject(sourceId, logicalEventId, "day_spent")
        endIf
        return 0.0
    endIf

    Float normalizedMultiplier = creditMultiplier
    if normalizedMultiplier > 1.0
        normalizedMultiplier = 1.0
    endIf

    StorageUtil.SetIntValue(GetSubstrateForm(), GetDailyCreditDayKey(), dayStamp)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastAcceptedSourceKey(), sourceId)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastLogicalEventKey(), logicalEventId)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectReasonKey(), "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetLastAcceptedTimeKey(), Utility.GetCurrentGameTime())
    StorageUtil.AdjustIntValue(GetSubstrateForm(), GetAcceptedCountKey(), 1)

    Float oldMetric = GetMetric()
    SetMetric(oldMetric + (DailyCredit * normalizedMultiplier), "daily_credit_" + sourceId)
    Float granted = GetMetric() - oldMetric
    Trace(2, "Daily credit accepted: " + sourceId + " event=" + logicalEventId + " granted=" + granted + " day=" + devotionalDay)
    return granted
EndFunction

Int Function GetDevotionalDayStamp()
    return GetDevotionalDay() + 2
EndFunction

Function EnsureDailyCreditStampEncoding()
    if StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditStampVersionKey()) >= 2
        return
    endIf

    Int oldStamp = StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey())
    if oldStamp > 0
        StorageUtil.SetIntValue(GetSubstrateForm(), GetDailyCreditDayKey(), oldStamp + 1)
    endIf
    StorageUtil.SetIntValue(GetSubstrateForm(), GetDailyCreditStampVersionKey(), 2)
EndFunction

Function RecordDailyCreditReject(String sourceId, String logicalEventId, String rejectReason)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectedSourceKey(), sourceId)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectedLogicalEventKey(), logicalEventId)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectReasonKey(), rejectReason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), GetRejectedCountKey(), 1)
    Trace(2, "Daily credit rejected: " + sourceId + " event=" + logicalEventId + " reason=" + rejectReason)
EndFunction

Int Function GetDevotionalDay()
    Float shiftedTime = Utility.GetCurrentGameTime() - 0.25
    Int truncatedDay = shiftedTime as Int
    if shiftedTime < 0.0 && shiftedTime != (truncatedDay as Float)
        return truncatedDay - 1
    endIf
    return truncatedDay
EndFunction

Bool Function IsAuthenticSubstrateSource(String sourceId)
    ; Concrete substrates must allowlist their own stable source-family IDs.
    return False
EndFunction

Int Function GetLastAcceptedDevotionalDay()
    EnsureDailyCreditStampEncoding()
    Int dayStamp = StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey())
    if dayStamp <= 0
        return -1
    endIf
    return dayStamp - 2
EndFunction

; A decoded devotional day of -1 is a legitimate credit earned before 06:00
; on game day zero. Callers must use this explicit presence test rather than
; treating a negative decoded day as an unset sentinel.
Bool Function HasAcceptedSubstrateCredit()
    EnsureDailyCreditStampEncoding()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey()) > 0
EndFunction

Int Function GetEncodedDailyCreditStamp()
    EnsureDailyCreditStampEncoding()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey())
EndFunction

Float Function GetLastAcceptedTime()
    return StorageUtil.GetFloatValue(GetSubstrateForm(), GetLastAcceptedTimeKey())
EndFunction

Bool Function IsDailyCreditSpent()
    EnsureDailyCreditStampEncoding()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetDailyCreditDayKey()) == GetDevotionalDayStamp()
EndFunction

String Function GetLastAcceptedSource()
    return StorageUtil.GetStringValue(GetSubstrateForm(), GetLastAcceptedSourceKey())
EndFunction

String Function GetLastRejectedSource()
    return StorageUtil.GetStringValue(GetSubstrateForm(), GetLastRejectedSourceKey())
EndFunction

String Function GetLastAcceptedLogicalEvent()
    return StorageUtil.GetStringValue(GetSubstrateForm(), GetLastLogicalEventKey())
EndFunction

String Function GetLastRejectedLogicalEvent()
    return StorageUtil.GetStringValue(GetSubstrateForm(), GetLastRejectedLogicalEventKey())
EndFunction

String Function GetLastCreditRejectReason()
    return StorageUtil.GetStringValue(GetSubstrateForm(), GetLastRejectReasonKey())
EndFunction

Int Function GetAcceptedCreditCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetAcceptedCountKey())
EndFunction

Int Function GetRejectedCreditCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetRejectedCountKey())
EndFunction

Function DebugSetMetric(Float metricValue)
    SetMetric(metricValue, "debug_seed")
EndFunction

Function ResetForDebug()
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetMetricKey(), 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetLastEventKey(), 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetTierKey(), SUBSTRATE_TIER_NONE)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetDailyCreditDayKey(), 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetDailyCreditStampVersionKey(), 2)
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastAcceptedSourceKey(), "")
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectedSourceKey(), "")
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastLogicalEventKey(), "")
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectedLogicalEventKey(), "")
    StorageUtil.SetStringValue(GetSubstrateForm(), GetLastRejectReasonKey(), "")
    StorageUtil.SetFloatValue(GetSubstrateForm(), GetLastAcceptedTimeKey(), 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetAcceptedCountKey(), 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), GetRejectedCountKey(), 0)
    ClearSubstrateBoons()
    Trace(2, "ResetForDebug " + SubstrateName)
EndFunction

Int Function GetSubstrateTier()
    return StorageUtil.GetIntValue(GetSubstrateForm(), GetTierKey())
EndFunction

Int Function RecomputeSubstrateTier()
    Int oldTier = GetSubstrateTier()
    Int newTier = SUBSTRATE_TIER_NONE
    Float metric = GetMetric()

    if metric >= HighThreshold
        newTier = SUBSTRATE_TIER_HIGH
    elseIf metric >= MidThreshold
        newTier = SUBSTRATE_TIER_MID
    elseIf metric >= LowThreshold
        newTier = SUBSTRATE_TIER_LOW
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

String Function GetDailyCreditDayKey()
    return StorageKeyPrefix + "." + SubstrateName + ".DailyCreditDay"
EndFunction

String Function GetDailyCreditStampVersionKey()
    return StorageKeyPrefix + "." + SubstrateName + ".DailyCreditDayStampVersion"
EndFunction

String Function GetLastAcceptedSourceKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastAcceptedSource"
EndFunction

String Function GetLastRejectedSourceKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastRejectedSource"
EndFunction

String Function GetLastLogicalEventKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastLogicalEvent"
EndFunction

String Function GetLastRejectedLogicalEventKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastRejectedLogicalEvent"
EndFunction

String Function GetLastRejectReasonKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastRejectReason"
EndFunction

String Function GetLastAcceptedTimeKey()
    return StorageKeyPrefix + "." + SubstrateName + ".LastAcceptedTime"
EndFunction

String Function GetAcceptedCountKey()
    return StorageKeyPrefix + "." + SubstrateName + ".AcceptedCount"
EndFunction

String Function GetRejectedCountKey()
    return StorageKeyPrefix + "." + SubstrateName + ".RejectedCount"
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
