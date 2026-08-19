Scriptname PDV_ContextualFavorRuntime extends Quest

; Contextual-favor runtime, extracted from PDV__ManagerQuest for the 2.0 rebuild
; (FAVOR module). Behavior parity: bodies are the manager originals; only bare
; manager-member references were qualified through the Manager backref.
; INERT until the host QUST exists, Manager is filled, and the 16 Spell props are
; filled in the batched houseCARL/CK session (see PDV_2_0_FAVOR_ExtractionSpec.md).

PDV__ManagerQuest Property Manager Auto

; --- 16 filled Spell properties (need CK fills later; unfilled = inert) ---
Spell Property PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery Auto
Spell Property PDV_SPEL_Favor_Kyne_StormRoadGrace Auto
Spell Property PDV_SPEL_Favor_Kyne_GuidedHunt Auto
Spell Property PDV_SPEL_Favor_Kyne_WindMarkedPassage Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine Auto
Spell Property PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness Auto
Spell Property PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement Auto

; --- 26 AutoReadOnly constants (compile-time; move verbatim) ---
Int Property FAVOR_LANE_NONE = 0 AutoReadOnly
Int Property FAVOR_LANE_KYNE = 1 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_OLD_WAYS = 2 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_NINE_DIVINES = 3 AutoReadOnly
Int Property FAVOR_LANE_ALTMER = 4 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_OPEN_SKY_REST = 1 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_STORM_ROAD = 2 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_GUIDED_HUNT = 3 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE = 4 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_SKY_ROAD = 11 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL = 12 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD = 13 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET = 14 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE = 15 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_ROAD_GRACE = 21 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY = 22 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_PROPER_DEATH = 23 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HONEST_WORK = 24 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_TALOS_PRESSURE = 25 AutoReadOnly
Int Property FAVOR_FAMILY_ALTMER_DAWN_STEADINESS = 31 AutoReadOnly
Int Property FAVOR_FAMILY_ALTMER_ORTHODOX_COST = 32 AutoReadOnly
Float Property FAVOR_DURATION_MOMENTARY_DAYS = 0.001 AutoReadOnly
Float Property FAVOR_DURATION_AFTER_ACT_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_DURATION_ENVIRONMENTAL_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_FAMILY_MOMENTARY_COOLDOWN_DAYS = 0.02 AutoReadOnly
Float Property FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS = 0.5 AutoReadOnly

Function EvaluateKyneContextualFavorFamily()
    UpdateContextualFavorRuntime()
EndFunction

Function UpdateContextualFavorRuntime()
    if IsActiveFavorExpired()
        ClearActiveFavor("expired")
    elseIf IsFavorActive()
        if !IsActiveFavorStillEligible()
            ClearActiveFavor("no_longer_eligible")
        else
            EnsureActiveFavorApplied()
        endIf
    endIf

    SyncKyneFavorDebugState()
EndFunction

Function SyncKyneFavorDebugState()
    Int activeCount = 0
    if GetActiveFavorLane() == FAVOR_LANE_KYNE
        activeCount = 1
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ActiveCount", activeCount)
EndFunction

Bool Function TryActivateContextualFavor(Int laneValue, Int familyValue, String reason)
    UpdateContextualFavorRuntime()
    if !IsEligibleForFavorLane(laneValue)
        Manager.Trace(2, "Contextual favor blocked: lane " + GetContextualFavorLaneLabel(laneValue) + " is not currently eligible.")
        return False
    endIf

    if !IsValidFavorFamilyForLane(laneValue, familyValue)
        Manager.Trace(1, "Contextual favor blocked: family " + familyValue + " is not valid for lane " + laneValue)
        return False
    endIf

    if IsFavorFamilyOnCooldown(laneValue, familyValue)
        Manager.Trace(2, "Contextual favor blocked: family cooldown still active for " + GetContextualFavorFamilyLabel(laneValue, familyValue))
        return False
    endIf

    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()
    if !favorSpell || !playerRef
        Manager.Trace(1, "Contextual favor blocked: missing player or spell for " + GetContextualFavorFamilyLabel(laneValue, familyValue))
        return False
    endIf

    ; A newly earned favor SUPERSEDES the active one rather than being dropped: the
    ; player just earned this moment, so losing it silently reads as unresponsive.
    ; Retired HERE, after every gate has passed -- retiring at the old rejection site
    ; would clear the active favor even when the incoming one is then blocked by
    ; cooldown or eligibility, leaving the player with nothing.
    if IsFavorActive()
        ClearActiveFavor("superseded")
    endIf

    playerRef.AddSpell(favorSpell, False)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveLane", laneValue)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveFamily", familyValue)
    StorageUtil.SetStringValue(None, "PDV.Favor.ActiveSpell", GetFavorSpellEditorId(laneValue, familyValue))
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveStartedAt", Utility.GetCurrentGameTime())
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveExpiresAt", Utility.GetCurrentGameTime() + GetFavorDurationDays(laneValue, familyValue))
    StorageUtil.SetFloatValue(None, GetFavorLastTriggerKey(laneValue, familyValue), Utility.GetCurrentGameTime())
    Manager.Trace(1, "Contextual favor applied: " + GetContextualFavorFamilyLabel(laneValue, familyValue) + " (" + reason + ")")
    if !Manager.IsP2BookNoticeReason(reason)
        SendContextualFavorToast(laneValue, familyValue)
    endIf
    SyncKyneFavorDebugState()
    if !Manager.IsP2BookNoticeReason(reason)
        Manager.RequestPanelRefresh()
    endIf
    return True
EndFunction

Function SendContextualFavorToast(Int laneValue, Int familyValue)
    String surfacing = GetFavorSurfacingLabel(laneValue, familyValue)
    if surfacing == "Quiet"
        return
    endIf

    ; Route contextual favors through the UI-owned "favor" voice for continuity.
    ; The family label is the meaningful act, so it carries as the event context.
    ; Kyne-lane favors can fire under broad Nord worship (no _activeDeity), so they
    ; pin to Kyne explicitly; other lanes credit the active patron (e.g. Auri-El for
    ; the Altmer lane). Deity-less pantheon lanes fall back to the journal mark.
    String contextText = GetContextualFavorFamilyLabel(laneValue, familyValue)
    PDV_DeityBase favorDeity = Manager.GetActiveDeity()
    if laneValue == FAVOR_LANE_KYNE && Manager.PDV_Kyne
        favorDeity = Manager.PDV_Kyne
    endIf

    Manager.SendPrismaEventToast("favor", favorDeity, contextText, "", "")
EndFunction

Function EnsureActiveFavorApplied()
    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    if laneValue == FAVOR_LANE_NONE || familyValue <= 0
        return
    endIf

    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()
    if !favorSpell || !playerRef
        return
    endIf

    if !playerRef.HasSpell(favorSpell)
        playerRef.AddSpell(favorSpell, False)
    endIf
EndFunction

Function ClearActiveFavor(String reason)
    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()

    if playerRef && favorSpell && playerRef.HasSpell(favorSpell)
        playerRef.RemoveSpell(favorSpell)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveLane", FAVOR_LANE_NONE)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveFamily", 0)
    StorageUtil.SetStringValue(None, "PDV.Favor.ActiveSpell", "")
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveStartedAt", 0.0)
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveExpiresAt", 0.0)
    Manager.Trace(2, "Contextual favor cleared (" + reason + ")")
    SyncKyneFavorDebugState()
    Manager.RequestPanelRefresh()
EndFunction

Bool Function IsFavorActive()
    return GetActiveFavorLane() != FAVOR_LANE_NONE && GetActiveFavorFamily() > 0
EndFunction

Bool Function IsActiveFavorExpired()
    if !IsFavorActive()
        return False
    endIf

    Float expiresAt = StorageUtil.GetFloatValue(None, "PDV.Favor.ActiveExpiresAt")
    return expiresAt > 0.0 && Utility.GetCurrentGameTime() >= expiresAt
EndFunction

Bool Function IsActiveFavorStillEligible()
    if !IsFavorActive()
        return False
    endIf

    return ResolveEligibleFavorLane() == GetActiveFavorLane()
EndFunction

Bool Function IsEligibleForFavorLane(Int laneValue)
    return ResolveEligibleFavorLane() == laneValue
EndFunction

Int Function ResolveEligibleFavorLane()
    if Manager.OriginRuntime.IsNordVampireSuppressed()
        return FAVOR_LANE_NONE
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == Manager.PDV_Kyne && Manager.LedgerRuntime.GetTier(Manager.PDV_Kyne) >= Manager.LedgerRuntime.TIER_CHAMPION
        return FAVOR_LANE_KYNE
    endIf

    if Manager.OriginRuntime.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER
        if Manager.OriginRuntime.IsAltmerFavorSuppressedByCurse()
            return FAVOR_LANE_NONE
        endIf

        return FAVOR_LANE_ALTMER
    endIf

    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_BROAD
        return FAVOR_LANE_NONE
    endIf

    if Manager.OriginRuntime.GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return FAVOR_LANE_NONE
    endIf

    Int baselineState = Manager.OriginRuntime.GetNordPantheonBaselineState()
    if baselineState == Manager.NORD_BASELINE_OLD_WAYS
        return FAVOR_LANE_NORD_BROAD_OLD_WAYS
    elseIf baselineState == Manager.NORD_BASELINE_NINE_DIVINES
        return FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    return FAVOR_LANE_NONE
EndFunction

Bool Function IsFavorFamilyOnCooldown(Int laneValue, Int familyValue)
    Float lastTriggerAt = StorageUtil.GetFloatValue(None, GetFavorLastTriggerKey(laneValue, familyValue))
    if lastTriggerAt <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastTriggerAt) < GetFavorCooldownDays(laneValue, familyValue)
EndFunction

String Function GetFavorLastTriggerKey(Int laneValue, Int familyValue)
    return "PDV.Favor.LastTrigger." + laneValue + "." + familyValue
EndFunction

Int Function GetActiveFavorLane()
    return StorageUtil.GetIntValue(None, "PDV.Favor.ActiveLane")
EndFunction

Int Function GetActiveFavorFamily()
    return StorageUtil.GetIntValue(None, "PDV.Favor.ActiveFamily")
EndFunction

Float Function GetFavorDurationDays(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
        return FAVOR_DURATION_MOMENTARY_DAYS
    endIf

    if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST || familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD || familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD || familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
        return FAVOR_DURATION_ENVIRONMENTAL_DAYS
    endIf

    return FAVOR_DURATION_AFTER_ACT_DAYS
EndFunction

Float Function GetFavorCooldownDays(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
        return FAVOR_FAMILY_MOMENTARY_COOLDOWN_DAYS
    endIf

    return FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS
EndFunction

Bool Function IsValidFavorFamilyForLane(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        return familyValue >= FAVOR_FAMILY_KYNE_OPEN_SKY_REST && familyValue <= FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return familyValue >= FAVOR_FAMILY_OLD_WAYS_SKY_ROAD && familyValue <= FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        return familyValue >= FAVOR_FAMILY_NINE_ROAD_GRACE && familyValue <= FAVOR_FAMILY_NINE_TALOS_PRESSURE
    elseIf laneValue == FAVOR_LANE_ALTMER
        return Manager.OriginRuntime.IsValidAltmerSourceFavorFamily(familyValue)
    endIf

    return False
EndFunction

Spell Function GetFavorSpell(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return PDV_SPEL_Favor_Kyne_StormRoadGrace
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return PDV_SPEL_Favor_Kyne_GuidedHunt
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return PDV_SPEL_Favor_Kyne_WindMarkedPassage
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine
        endIf
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement
        endIf
    endIf

    return None
EndFunction

String Function GetFavorSpellEditorId(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return "PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery"
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return "PDV_SPEL_Favor_Kyne_StormRoadGrace"
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return "PDV_SPEL_Favor_Kyne_GuidedHunt"
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return "PDV_SPEL_Favor_Kyne_WindMarkedPassage"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return "PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return "PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return "PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return "PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return "PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return "PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace"
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return "PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty"
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return "PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy"
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return "PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft"
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return "PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine"
        endIf
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return "PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness"
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return "PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement"
        endIf
    endIf

    return ""
EndFunction

String Function GetContextualFavorLaneLabel(Int laneValue)
    if laneValue == FAVOR_LANE_KYNE
        return "Kyne"
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return "Nord Broad Old Ways"
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        return "Nord Broad Nine Divines"
    elseIf laneValue == FAVOR_LANE_ALTMER
        return "Altmer Ancestral Order"
    endIf

    return "None"
EndFunction

String Function GetContextualFavorFamilyLabel(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return "Open-sky rest recovery"
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return "Storm-road grace"
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return "Guided hunt"
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return "Wind-marked passage"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return "Sky-road endurance"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return "Honorable ordeal"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return "Hearth and hold defense"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return "Death-right and ancestor quiet"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return "Hidden Talos defiance"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return "Kynareth's road grace"
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return "Household and mercy duty"
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return "Proper death and anti-necromancy"
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return "Honest work and learned craft"
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return "Talos pressure inside the Nine"
        endIf
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return "Dawn steadiness"
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return "Orthodox costly enforcement"
        endIf
    endIf

    return "Unknown"
EndFunction

String Function GetFavorSurfacingLabel(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL || familyValue == FAVOR_FAMILY_NINE_HONEST_WORK || familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
        return "Quiet"
    endIf

    return "Noted"
EndFunction

Int Function GetSelectedContextualFavorLane()
    Int laneValue = StorageUtil.GetIntValue(None, "PDV.Favor.DebugLane")
    if laneValue < FAVOR_LANE_KYNE || laneValue > FAVOR_LANE_ALTMER
        laneValue = FAVOR_LANE_KYNE
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugLane", laneValue)
    endIf

    return laneValue
EndFunction

Function SetSelectedContextualFavorLane(Int laneValue)
    Int normalizedLane = PDV_DevotionRules.ClampInt(laneValue, FAVOR_LANE_KYNE, FAVOR_LANE_ALTMER)
    StorageUtil.SetIntValue(None, "PDV.Favor.DebugLane", normalizedLane)
    if !IsValidFavorFamilyForLane(normalizedLane, GetSelectedContextualFavorFamily())
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", GetFirstFavorFamilyForLane(normalizedLane))
    endIf
EndFunction

Int Function GetSelectedContextualFavorFamily()
    Int familyValue = StorageUtil.GetIntValue(None, "PDV.Favor.DebugFamily")
    if !IsValidFavorFamilyForLane(GetSelectedContextualFavorLane(), familyValue)
        familyValue = GetFirstFavorFamilyForLane(GetSelectedContextualFavorLane())
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", familyValue)
    endIf

    return familyValue
EndFunction

Int Function GetFirstFavorFamilyForLane(Int laneValue)
    if laneValue == FAVOR_LANE_KYNE
        return FAVOR_FAMILY_KYNE_OPEN_SKY_REST
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    elseIf laneValue == FAVOR_LANE_ALTMER
        return FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
    endIf

    return FAVOR_FAMILY_NINE_ROAD_GRACE
EndFunction

Int Function GetNextFavorFamilyForLane(Int laneValue, Int currentFamily)
    if laneValue == FAVOR_LANE_KYNE
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return FAVOR_FAMILY_KYNE_OPEN_SKY_REST
        endIf
        return currentFamily
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
        endIf
        return currentFamily
    elseIf laneValue == FAVOR_LANE_ALTMER
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
        endIf
        return currentFamily
    endIf

    currentFamily += 1
    if currentFamily > FAVOR_FAMILY_NINE_TALOS_PRESSURE
        return FAVOR_FAMILY_NINE_ROAD_GRACE
    endIf

    return currentFamily
EndFunction

String Function GetSelectedContextualFavorLaneLabel()
    return GetContextualFavorLaneLabel(GetSelectedContextualFavorLane())
EndFunction

String Function GetSelectedContextualFavorFamilyLabel()
    return GetContextualFavorFamilyLabel(GetSelectedContextualFavorLane(), GetSelectedContextualFavorFamily())
EndFunction

String Function GetPlayerMcmFavorLine()
    if Manager.OriginRuntime.IsNordVampireSuppressed()
        return "Suppressed by vampire curse"
    endIf

    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    if laneValue != FAVOR_LANE_NONE && familyValue > 0
        return GetContextualFavorLaneLabel(laneValue)
    endIf

    Int eligibleLane = ResolveEligibleFavorLane()
    if eligibleLane != FAVOR_LANE_NONE
        return GetContextualFavorLaneLabel(eligibleLane)
    endIf

    return "None active"
EndFunction

String Function GetContextualFavorSummary()
    Int activeLane = GetActiveFavorLane()
    Int activeFamily = GetActiveFavorFamily()
    Float remainingDays = StorageUtil.GetFloatValue(None, "PDV.Favor.ActiveExpiresAt") - Utility.GetCurrentGameTime()
    if remainingDays < 0.0
        remainingDays = 0.0
    endIf
    String summary = "lane=" + GetContextualFavorLaneLabel(activeLane)
    summary = summary + ";family=" + GetContextualFavorFamilyLabel(activeLane, activeFamily)
    summary = summary + ";spell=" + StorageUtil.GetStringValue(None, "PDV.Favor.ActiveSpell")
    summary = summary + ";expires=" + PDV_DevotionRules.FormatTwoDecimals(remainingDays)
    summary = summary + ";selected=" + GetSelectedContextualFavorLaneLabel() + "/" + GetSelectedContextualFavorFamilyLabel()
    return summary
EndFunction



