Scriptname PDV_OriginRuntime_Orc extends PDV_OriginRuntimeBase

; ORIGIN adapter -- Orc lane (tranche t5). Per
; references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md: the base declares 21
; virtuals with inert defaults; this adapter overrides only what the Orc lane
; implements and delegates each override to the existing named Orc function,
; whose body is copied here VERBATIM so the split stays provable against
; origin_golden.json.
;
; Lane scope: life mode (Stronghold / City / Legion-Exile), Malacath conduct,
; oath-break, blood-kin, forge/craft, four holds, Trial of Iron.
;
; Script variables: the Orc lane bodies reference NO bare script variable, so
; nothing had to move and nothing is shared. (Papyrus children cannot reach a
; parent's script variables -- only Properties -- so this was checked per
; function, not per file.) The Manager backref is a Property on the base and is
; therefore reachable from here unchanged.
;
; Originals remain in PDV_OriginRuntimeBase for now; a same-signature child
; function is simply an override, so the duplication compiles and is removed by
; the central pass that consumes PDV_2_0_AdapterManifest_t5.json.
;
; INERT until the host QUST exists, Manager is filled, and the manager selects
; this adapter by birth race.

; ============================================================================
; Orc lane functions -- copied VERBATIM from PDV_OriginRuntimeBase
; (source ranges 9377-9518, 9525-10095, 10109-10233, 10462-10525,
;  10740-10772, 10894-10900).
; ============================================================================

Function HandleOrcSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Orc.HearthRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Orc.HearthRest", sleepCellId)
            MaybeShowOrcHearthHeldNotice("sleep_rest_declare_" + reason)
            Manager.Trace(2, "Orc hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryOrcTrialOfIron(playerRef, sleepCellId, reason)
        return                          ; Trial menu shown; suppress the rest-notice this wake
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.OrcAncestralRest")
        return
    endIf

    Int modeValue = GetActiveOrcRewardMode()
    RecordOrcLifeModeSignal(modeValue, 1.0, "sleep_hearth_rest_" + reason)
    MaybeShowOrcHearthHeldNotice("sleep_hearth_rest_" + reason)
    Manager.Trace(2, "Orc ancestral rest routed: " + reason)
EndFunction

Bool Function TryOrcTrialOfIron(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MESG_Orc_TrialOfIron || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.OrcTrial.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_Orc_TrialOfIron.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyOrcTrialOfIron(playerRef, pressed)
    return true
EndFunction

Function ApplyOrcTrialOfIron(Actor playerRef, Int index)
    RemoveOrcTrialSpells(playerRef)
    Spell chosen = GetOrcTrialSpell(index)
    if !chosen
        return
    endIf

    Int modeNow = 0
    if Manager.PDV_OrcLifeModeTrack
        modeNow = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.ModeAtRite", modeNow)
    StorageUtil.SetFloatValue(None, "PDV.OrcTrial.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Malacath pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    Manager.LedgerRuntime.AwardPiety(Manager.PDV_Malacath, 0.5, "Took up the Trial of Iron")
    Manager.AppendBookOfDaysEntry("You took up a discipline in the Trial of Iron. The Code is held in iron.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
    Manager.SendPrismaToast("malacath", "good", "Trial of Iron", "You take up a discipline of the Code. The Trial of Iron holds you to it.")
    Manager.Trace(2, "Orc Trial of Iron discipline applied: " + index)
EndFunction

Function RemoveOrcTrialSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell disc = GetOrcTrialSpell(i)
        if disc && playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetOrcTrialSpell(Int index)
    if index == 0
        return Manager.PDV_SPEL_Orc_TrialOfIron_Tusk
    elseIf index == 1
        return Manager.PDV_SPEL_Orc_TrialOfIron_Shield
    elseIf index == 2
        return Manager.PDV_SPEL_Orc_TrialOfIron_Hammer
    elseIf index == 3
        return Manager.PDV_SPEL_Orc_TrialOfIron_Yoke
    endIf
    return None
EndFunction

Function SyncOrcTrialOfIron(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.OrcTrial.Active")
    if active <= 0
        return
    endIf
    Spell disc = GetOrcTrialSpell(active - 1)
    if !disc
        return
    endIf

    Int modeAtRite = StorageUtil.GetIntValue(None, "PDV.OrcTrial.ModeAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC) && IsOrcTrialCoherent(modeAtRite)
    if eligible
        if !playerRef.HasSpell(disc)
            playerRef.AddSpell(disc, False)
            Manager.SendPrismaToast("malacath", "good", "The Code holds", "Your discipline returns.")
        endIf
    else
        if playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
            Manager.SendPrismaToast("malacath", "warning", "The discipline goes quiet", "The standing you swore it under has broken.")
        endIf
    endIf
EndFunction

Bool Function IsOrcTrialCoherent(Int modeAtRite)
    if !Manager.PDV_OrcLifeModeTrack
        return false
    endIf
    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() != modeAtRite
        return false
    endIf
    return true
EndFunction

Function TryOrcCodeHolds(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return
    endIf
    if !playerRef.IsInCombat() || (!Manager.PDV_SPEL_OrcCodeHolds && !Manager.PDV_SPEL_OrcCodeHolds_Devoted)
        return
    endIf

    Int malacathTier = Manager.LedgerRuntime.TIER_NONE
    if Manager.PDV_Malacath
        malacathTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Malacath)
    endIf
    if malacathTier < Manager.LedgerRuntime.TIER_SEEKER
        return
    endIf

    ; B12 / fix-plan 4.5. The rescue latched once per COMBAT SESSION while both siblings
    ; -- the Bosmer Baan Dar gap and the Argonian Sithis burst, the two other below-health
    ; payloads fanned from the same HandlePlayerBelowHealthGate -- are once per DAY. An
    ; uncapped 40-60 HP (+30 stamina) clutch save every fight is a different power budget
    ; from what the design says it is. Same LastDay guard, same devotional-day encoding.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        Manager.Trace(2, "Orc Code Holds suppressed: already spent this devotional day.")
        return
    endIf

    ; The Code Holds is a near-death clutch save. It fires mid-fight the instant
    ; health drops past the below-health gate (Baan Dar Opens the Gap model), not on
    ; combat exit -- so it can actually save the player. Its old
    ; HealRate spell is not cast because Requiem swallows rate-mult healing on a
    ; near-zero base; the actual health save is a flat RestoreActorValue. Requiem-proof.
    if malacathTier >= Manager.LedgerRuntime.TIER_DEVOTED && Manager.PDV_SPEL_OrcCodeHolds_Devoted
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf Manager.PDV_SPEL_OrcCodeHolds
        playerRef.RestoreActorValue("Health", 40.0)
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay")

    ; B12's second half asked for a Cast() of PDV_SPEL_OrcCodeHolds* "so the rescue has
    ; feedback". Checked against the records: 071534 and 071536 are both Type=Ability,
    ; CastType=ConstantEffect, TargetType=Self. A constant-effect ability is applied with
    ; AddSpell, never cast -- Spell.Cast() on one is an engine no-op, and the author's
    ; comment above says the HealRate payload is deliberately dead under Requiem anyway.
    ; So the feedback is delivered the way both siblings deliver theirs: a toast.
    Manager.SendPrismaToast("malacath", "good", "The Code holds", "The Code holds, and so do you.")

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCodeHolds")
    if multiplier > 0.0
        Manager.LedgerRuntime.AwardPiety(Manager.PDV_Malacath, 0.5 * multiplier)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CodeHolds.Count", 1)
    Manager.Trace(2, "Orc Code Holds fired.")
EndFunction

Function HandleOrcStoryCraftForge(Location craftLocation)
    if !IsOrcOrigin()
        return
    endIf
    if GetOrcStrongholdHoldId(craftLocation) <= 0
        return
    endIf
    HandleOrcStrongholdForge("story_craft_stronghold")
EndFunction

Function HandleOrcStrongholdForge(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdForge")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    AwardOrcStrongholdForgeSignal(multiplier)
    Manager.Trace(2, "Orc Stronghold forge routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLocationChange(Location newLocation)
    if !newLocation || !IsOrcOrigin()
        return
    endIf

    Int holdId = GetOrcStrongholdHoldId(newLocation)
    if holdId <= 0
        return
    endIf

    if Manager.PDV_Malacath && Manager.PDV_OrcLifeModeTrack && Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_LEGION_EXILE && StorageUtil.GetIntValue(None, "PDV.Signal.MalacathExileReturn.Done") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.MalacathExileReturn.Done", 1)
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_EXILE_RETURN, None, 1.0)
        Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Malacath, "Burden carried home", "marks the Exile's return to a stronghold hearth.")
        Manager.Trace(1, "Malacath exile-return banked (location_stronghold)")
    endIf

    HandleOrcStrongholdPresence(holdId, "location_stronghold")
EndFunction

Function HandleOrcStrongholdPresence(Int holdId, String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdPresence")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    if Manager.PDV_SPEL_OrcHearthHeld && Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_STRONGHOLD && Manager.ConsumeOncePerDaySignal("PDV.Signal.OrcHearthHeld")
        Actor hearthPlayer = Game.GetPlayer()
        if hearthPlayer
            Manager.PDV_SPEL_OrcHearthHeld.Cast(hearthPlayer, hearthPlayer)
            Manager.Trace(2, "Orc hearth-held comfort cast (" + reason + ")")
        endIf
    endIf
    if holdId > 0
        HandleOrcFourHoldsVisit(holdId, reason)
    endIf
    Manager.Trace(2, "Orc Stronghold presence routed with multiplier " + multiplier)
EndFunction

Function HandleOrcBloodKinCrisis(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, 1.0, reason)
    ; Curated award (dead-wiring burndown Wave 1, 2026-07-07): this handler recorded
    ; life-mode progress but -- unlike its CityDignity/LegionService/SelfMadeCommunity
    ; siblings -- never dispatched the curated signal, so BLOOD_KIN could never bank.
    ; The crisis is a one-shot quest milestone (The Cursed Tribe resolution); the latch
    ; keeps a save-reload edge from ever double-banking it.
    if StorageUtil.GetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded", 1)
        AwardOrcBloodKinSignal(1.0)
    endIf
    Manager.Trace(2, "Orc Blood-Kin crisis routed: " + reason)
EndFunction

Function HandleOrcCityDignity(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCityDignity")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcCityDignitySignal(multiplier)
    Manager.Trace(2, "Orc City dignity routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLegionService(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcLegionService")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_LEGION_EXILE, multiplier, reason)
    AwardOrcLegionServiceSignal(multiplier)
    Manager.Trace(2, "Orc Legion or exile service routed with multiplier " + multiplier)
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcSelfMadeCommunity")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcSelfMadeCommunitySignal(multiplier)
    if multiplier > 0.0
        MaybeShowOrcHearthHeldNotice(reason)
    endIf
    Manager.Trace(2, "Orc self-made community routed with multiplier " + multiplier)
EndFunction

Function HandleOrcMalacathConduct(Int modeValue, String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    EnsureOrcLifeModeInitialized()
    if modeValue < Manager.ORC_LIFE_MODE_CITY || modeValue > Manager.ORC_LIFE_MODE_LEGION_EXILE
        modeValue = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcMalacathConduct")
    RecordOrcLifeModeSignal(modeValue, multiplier, reason)
    AwardOrcBroadConductSignal(multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.MalacathConduct", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.MalacathSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastMalacathSourceReason", reason)
    Manager.SurfaceP2BookReadNotice(reason, "The Code of Malacath", "Malacath weighs your conduct against it.")
    Manager.Trace(2, "Orc Malacath conduct routed with multiplier " + multiplier)
EndFunction

Function HandleOrcOathBreak(String reason)
    if !IsOrcOrigin()
        return
    endIf

    AwardOrcOathBreakSignal()
    StorageUtil.AdjustIntValue(None, "PDV.Orc.OathBreakCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastOathBreakReason", reason)
    Manager.Trace(2, "Orc oath-break routed: " + reason)
EndFunction

Function HandleOrcFourHoldsVisit(Int holdId, String reason)
    if !IsOrcOrigin()
        return
    endIf

    if holdId < Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL || holdId > Manager.ORC_FOUR_HOLDS_LARGASHBUR
        Manager.Trace(1, "Orc Four Holds skipped: invalid hold id " + holdId)
        return
    endIf

    String visitedKey = "PDV.Orc.FourHolds." + holdId
    if StorageUtil.GetIntValue(None, visitedKey) > 0
        Manager.Trace(2, "Orc Four Holds skipped: already visited hold " + holdId)
        return
    endIf

    StorageUtil.SetIntValue(None, visitedKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastFourHoldsReason", reason)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastFourHoldsVisit", holdId)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastFourHoldsVisitTime", Utility.GetCurrentGameTime())
    AwardOrcFourHoldsVisitSignal()
    AwardOrcAncestorSpineSignal(1.0, reason)

    Int count = GetOrcFourHoldsVisitCount()
    StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.Count", count)
    ShowOrcNotification(GetOrcFourHoldsNotice(holdId), GetOrcFourHoldsFallback(holdId))
    if count >= 4 && StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown", 1)
        ShowOrcMessage(Manager.PDV_Msg_Orc_FourHolds_Milestone, "You have stood at all four strongholds. The code holds across distance.", False)
    endIf

    Manager.Trace(2, "Orc Four Holds routed: hold " + holdId + " count " + count)
EndFunction

Function RecordOrcLifeModeSignal(Int modeValue, Float multiplier, String reason)
    if !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    if modeValue < Manager.ORC_LIFE_MODE_CITY || modeValue > Manager.ORC_LIFE_MODE_LEGION_EXILE
        return
    endIf

    EnsureOrcLifeModeInitialized()
    Manager.PDV_OrcLifeModeTrack.RecordEvidenceDay(modeValue, reason)
    StorageUtil.AdjustFloatValue(None, GetOrcLifeModeWeightKey(modeValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastLifeModeSignal", modeValue)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastLifeModeReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime", Utility.GetCurrentGameTime())

    if multiplier <= 0.0
        return
    endIf

    AwardOrcAncestorSpineSignal(multiplier, reason)
    MaybeShowOrcWatchersNotice(modeValue, reason)

    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() == modeValue
        SendPrismaSubstrateToast(GetOrcLifeModeSubstrateToken(modeValue), "act", "The code was marked.", "malacath", GetOrcLifeModeLabel())
        Manager.AppendBookOfDaysEntry("The code was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
        Manager.RequestPanelRefresh()
        return
    endIf

    ; LOCKED life-mode switch rule: a soft switch needs two evidence days inside
    ; seven; only a major gate (Blood-Kin, Cursed Tribe resolved) switches at once.
    ; Other soft switches settle at dawn via EvaluateOrcLifeModeAtDawn. A confirmed
    ; switch holds for a three-day lock-in. One stray act no longer flips the mode.
    if IsOrcMajorLifeModeGate(reason)
        ApplyOrcLifeModeSwitch(modeValue, reason)
    elseIf Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(modeValue, 2, 7) && !Manager.PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        ApplyOrcLifeModeSwitch(modeValue, reason)
    endIf
EndFunction

Function ApplyOrcLifeModeSwitch(Int modeValue, String reason)
    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_LEGION_EXILE && modeValue != Manager.ORC_LIFE_MODE_LEGION_EXILE
        EmitMalacathBrokenFaithKinMinus("desert_legion_exile_" + reason)
    endIf
    Manager.PDV_OrcLifeModeTrack.SetState(modeValue, reason)
    Manager.PDV_OrcLifeModeTrack.SetTransitionLockout(3.0, reason)
    Int deityIndex = -1
    if Manager.PDV_Malacath
        deityIndex = Manager.PDV_Malacath.DeityIndex
    endIf
    Manager.SurfaceTransition("reorientation", GetOrcLifeModeLabel(), "shift", deityIndex, "turning")
    Manager.SendPrismaShiftToast(GetOrcLifeModeLabel(), "", "malacath")
    Manager.RequestPanelRefresh()
EndFunction

Bool Function IsOrcMajorLifeModeGate(String reason)
    return PDV_DevotionRules.StringContainsToken(reason, "orc_bloodkin_crisis") || PDV_DevotionRules.StringContainsToken(reason, "orc_cursed_tribe_resolved") || PDV_DevotionRules.StringContainsToken(reason, "orc_major_gate")
EndFunction

String Function GetOrcLifeModeSubstrateToken(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "stronghold"
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "legionexile"
    endIf
    return "city"
EndFunction

Function EvaluateOrcLifeModeAtDawn()
    if !Manager.PDV_OrcLifeModeTrack || !IsOrcOrigin()
        return
    endIf

    EnsureOrcLifeModeInitialized()
    Int currentMode = Manager.PDV_OrcLifeModeTrack.GetCurrentState()

    if !Manager.PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        Int bestMode = -1
        Float bestWeight = -1.0
        Int candidate = Manager.ORC_LIFE_MODE_CITY
        while candidate <= Manager.ORC_LIFE_MODE_LEGION_EXILE
            if candidate != currentMode && Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(candidate, 2, 7)
                Float candidateWeight = StorageUtil.GetFloatValue(None, GetOrcLifeModeWeightKey(candidate))
                if bestMode < 0 || candidateWeight > bestWeight
                    bestMode = candidate
                    bestWeight = candidateWeight
                endIf
            endIf
            candidate += 1
        endWhile

        if bestMode >= 0
            ApplyOrcLifeModeSwitch(bestMode, "orc_dawn_softswitch")
            return
        endIf
    endIf

    if currentMode > Manager.ORC_LIFE_MODE_CITY && !Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(currentMode, 1, 14)
        ApplyOrcLifeModeSwitch(Manager.ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")
        Manager.RequestPanelRefresh()
    endIf
EndFunction

Function AwardOrcStrongholdForgeSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, None, multiplier)
    endIf
EndFunction

Function AwardOrcBloodKinSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BLOOD_KIN, None, multiplier)
    endIf
EndFunction

Function AwardOrcCityDignitySignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_CITY_DIGNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcLegionServiceSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_LEGION_SERVICE, None, multiplier)
    endIf
EndFunction

Function AwardOrcSelfMadeCommunitySignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcBroadConductSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BROAD_CONDUCT, None, multiplier)
    endIf
EndFunction

Function AwardOrcOathBreakSignal()
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_OATH_BREAK, None)
    endIf
EndFunction

Function AwardOrcFourHoldsVisitSignal()
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT, None)
    endIf
EndFunction

Function AwardOrcAncestorSpineSignal(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC || !Manager.PDV_Malacath || multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastAncestorSpineTime", Utility.GetCurrentGameTime())
EndFunction

Int Function GetOrcFourHoldsVisitCount()
    Int count = 0
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_NARZULBUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_LARGASHBUR) > 0
        count += 1
    endIf
    return count
EndFunction

Message Function GetOrcFourHoldsNotice(Int holdId)
    if holdId == Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return Manager.PDV_Notif_Orc_FourHolds_DushnikhYal
    elseIf holdId == Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
        return Manager.PDV_Notif_Orc_FourHolds_MorKhazgur
    elseIf holdId == Manager.ORC_FOUR_HOLDS_NARZULBUR
        return Manager.PDV_Notif_Orc_FourHolds_Narzulbur
    elseIf holdId == Manager.ORC_FOUR_HOLDS_LARGASHBUR
        return Manager.PDV_Notif_Orc_FourHolds_Largashbur
    endIf

    return None
EndFunction

String Function GetOrcFourHoldsFallback(Int holdId)
    if holdId == Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return "Dushnikh Yal is counted. The code has a western hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
        return "Mor Khazgur is counted. The code has a northern hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_NARZULBUR
        return "Narzulbur is counted. The code has an eastern hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_LARGASHBUR
        return "Largashbur is counted. Even a troubled hold is still a hold."
    endIf

    return "The stronghold is counted. The code holds across distance."
EndFunction

Bool Function ConsumeDailyOrcNotice(String noticeKey)
    ; fix-plan 4.2: devotional day, so a notice cannot re-fire at raw midnight.
    Int dayIndex = Manager.LedgerRuntime.GetDevotionalDay() + 2
    String storageKey = "PDV.Orc.Notice." + noticeKey + ".Day"
    if StorageUtil.GetIntValue(None, storageKey, -1) == dayIndex
        return False
    endIf

    StorageUtil.SetIntValue(None, storageKey, dayIndex)
    return True
EndFunction

Function MaybeShowOrcWatchersNotice(Int modeValue, String reason)
    if !ConsumeDailyOrcNotice("Watchers")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastWatchersNoticeReason", reason)
    ShowOrcNotification(GetOrcWatchersNotice(modeValue), GetOrcWatchersFallback(modeValue))
EndFunction

Message Function GetOrcWatchersNotice(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_LegionExile
    endIf

    return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_City
EndFunction

String Function GetOrcWatchersFallback(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "The Watchers see the stronghold work. The code has witnesses."
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "The Watchers see the burden carried away from the hold. The code has witnesses."
    endIf

    return "The Watchers see the code kept under city stone. The code has witnesses."
EndFunction

Function MaybeShowOrcHearthHeldNotice(String reason)
    if StorageUtil.GetIntValue(None, "PDV.Orc.HearthHeldDeclared") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.HearthHeldDeclared", 1)
        StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldDeclareReason", reason)
        ; Declaring a hearth is a once-ever moment (the flag above guards it), so it
        ; earns a toast plus a permanent Book of Days beat rather than a transient
        ; corner notice. The toast honours the Notifications preference at the shared
        ; chokepoint while the Book entry always logs. PDV_Notif_Orc_HearthHeld_Declare
        ; is deliberately no longer shown here (it would double the surface); the
        ; record stays in the ESP, orphaned, with its text kept in sync.
        Manager.SendPrismaToast("malacath", "good", "A hearth held", "You claim this hearth as your own, and swear to hold it.")
        Manager.AppendBookOfDaysEntry("You claim this hearth as your own, and swear to hold it.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
        return
    endIf

    if !ConsumeDailyOrcNotice("HearthHeldReturn")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldReturnReason", reason)
    ShowOrcNotification(Manager.PDV_Notif_Orc_HearthHeld_Return, "You return to the hearth you hold. The code remembers the place.")
EndFunction

Function MaybeShowOrcHearthHeldMissedCadenceNotice()
    if !ConsumeDailyOrcNotice("HearthHeldMissed")
        return
    endIf

    ShowOrcNotification(Manager.PDV_Notif_Orc_HearthHeld_MissedCadence, "The held hearth has gone quiet. The code presses for proof.")
EndFunction

Function EnsureOrcLifeModeInitialized()
    if !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    if IsOrcOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() < Manager.ORC_LIFE_MODE_CITY
        Manager.PDV_OrcLifeModeTrack.SetState(Manager.ORC_LIFE_MODE_CITY, "orc_default_city")
    endIf
EndFunction

Bool Function IsOrcOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC
EndFunction

String Function GetOrcLifeModeWeightKey(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "PDV.Orc.LifeMode.Stronghold"
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "PDV.Orc.LifeMode.LegionExile"
    endIf

    return "PDV.Orc.LifeMode.City"
EndFunction

String Function GetOrcLifeModeLabel()
    if !Manager.PDV_OrcLifeModeTrack
        return "Life mode missing"
    endIf

    EnsureOrcLifeModeInitialized()
    return Manager.PDV_OrcLifeModeTrack.GetStateLabel()
EndFunction

Int Function GetOrcStrongholdHoldId(Location newLocation)
    if !newLocation
        return 0
    endIf

    Int locationFormId = newLocation.GetFormID()
    if locationFormId == 0x00019171
        return Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
    elseIf locationFormId == 0x0001927C
        return Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
    elseIf locationFormId == 0x00019282
        return Manager.ORC_FOUR_HOLDS_NARZULBUR
    elseIf locationFormId == 0x00019263
        return Manager.ORC_FOUR_HOLDS_LARGASHBUR
    endIf

    return 0
EndFunction

Function SyncOrcRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isOrc = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC
    Int activeMode = GetActiveOrcRewardMode()
    SyncOrcSpineBoon(playerRef, isOrc, activeMode)

    Bool broadFaithful = isOrc && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Malacath_T2, broadFaithful, "Orc Malacath T2")

    Bool focusActive = isOrc && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == Manager.PDV_Malacath && Manager.PDV_Malacath
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if focusActive
        activeTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Malacath)
    endIf

    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_STRONGHOLD, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_Stronghold_T1, Manager.PDV_Bless_Orc_Stronghold_T2, Manager.PDV_Bless_Orc_Stronghold_T3, "Stronghold")
    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_CITY, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_City_T1, Manager.PDV_Bless_Orc_City_T2, Manager.PDV_Bless_Orc_City_T3, "City")
    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_LEGION_EXILE, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_LegionExile_T1, Manager.PDV_Bless_Orc_LegionExile_T2, Manager.PDV_Bless_Orc_LegionExile_T3, "LegionExile")
EndFunction

Function SyncOrcSpineBoon(Actor playerRef, Bool isOrc, Int activeMode)
    if !playerRef
        return
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_City, isOrc && activeMode == Manager.ORC_LIFE_MODE_CITY, "Orc Spine City")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_Stronghold, isOrc && activeMode == Manager.ORC_LIFE_MODE_STRONGHOLD, "Orc Spine Stronghold")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_LegionExile, isOrc && activeMode == Manager.ORC_LIFE_MODE_LEGION_EXILE, "Orc Spine LegionExile")
EndFunction

Int Function GetActiveOrcRewardMode()
    if Manager.PDV_OrcLifeModeTrack
        Int modeValue = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
        if modeValue >= Manager.ORC_LIFE_MODE_CITY && modeValue <= Manager.ORC_LIFE_MODE_LEGION_EXILE
            return modeValue
        endIf
    endIf

    return Manager.ORC_LIFE_MODE_CITY
EndFunction

Function SyncOrcRewardFamily(Actor playerRef, Int thisMode, Int activeMode, Int activeTier, Bool focusActive, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = focusActive && thisMode == activeMode
    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Orc " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Orc " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Orc " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, Manager.PDV_Malacath, "Orc " + label)
EndFunction

Bool Function IsOrcCodeNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure") == 1
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncOrcNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Orc
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Orc)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Orc, False)
            MaybeShowOrcHearthHeldMissedCadenceNotice()
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Orc)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Orc)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
    endIf
EndFunction

Function EmitMalacathCurseCodeRuptureMinus(String reason)
    if !IsOrcOrigin() || !Manager.PDV_Malacath
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathCurseCodeRupture")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CurseCodeRuptureCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastCurseCodeRuptureReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastCurseCodeRuptureTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Malacath curse-code rupture routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitMalacathBrokenFaithKinMinus(String reason)
    if !IsOrcOrigin() || !Manager.PDV_Malacath
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathBrokenFaithKin")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.BrokenFaithKinCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastBrokenFaithKinReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastBrokenFaithKinTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Malacath broken-faith-kin routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function ApplyOrcCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.VampireScar", 1)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 1)
        if !Manager.GetSuppressCurseTransitionOutputs()
            EmitMalacathCurseCodeRuptureMinus("werewolf_onset_" + reason)
        endIf
    elseIf oldState != 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    endIf
EndFunction

Function ShowOrcNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("malacath", "neutral", "", fallbackText)
EndFunction

Function ShowOrcMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    if suppressModal
        Manager.SendPrismaToast("malacath", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyOrcInitialChoice(Int modeValue, String reason)
    Manager.BeginRaceSetupQuietPresentation(reason)
    if Manager.PDV_OrcLifeModeTrack
        Manager.PDV_OrcLifeModeTrack.SetState(PDV_DevotionRules.ClampInt(modeValue, Manager.ORC_LIFE_MODE_CITY, Manager.ORC_LIFE_MODE_LEGION_EXILE), reason)
        Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(GetOrcLifeModeLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "malacath", True, 3, "", True)
    endIf
    ; Malacath is the single innate Orc spine (not chosen, not offered) -- activate him as the
    ; patron at origin so the life-mode reward ladder (gated on _activeDeity==PDV_Malacath) is
    ; reachable in normal play; without this the whole Malacath progression was a dead no-op.
    ; Owner ruling 2026-06-27.
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.SetActiveDeity(Manager.PDV_Malacath)
    endIf
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

String Function GetOrcMedallionEntriesJson()
    return Manager.RosterMedallionEntry("malacath", "Malacath", "prince", "malacath", Manager.PDV_Malacath, "Oath, code, exile, and vengeance.")
EndFunction

String Function GetOrcSurveyText()
    if !Manager.PDV_OrcLifeModeTrack
        return "Malacath watches, but the shape of your life has not settled yet. Carry the code a while, then survey again."
    endIf

    EnsureOrcLifeModeInitialized()
    String band = Manager.GetCurrentStandingBand()
    Int mode = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    String text = ""
    if mode == Manager.ORC_LIFE_MODE_STRONGHOLD
        text = "You carry Malacath's code inside the stronghold, where forge, kin, and oath hold it with you. Standing: " + band + "."
    elseIf mode == Manager.ORC_LIFE_MODE_LEGION_EXILE
        text = "You carry Malacath's code under foreign discipline. The contract is the oath; the endurance is the strength. Standing: " + band + "."
    else
        text = "You carry Malacath's code in the city, alone, with no stronghold to confirm it. Standing: " + band + ". Malacath watches what no one else does."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") > 0
        text = text + " You have sought out the old tellings of Malacath, and kept them."
    endIf
    Int cursePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure")
    if cursePressure == 2
        text = text + " The thirst sets you outside the test until it is cured."
    elseIf cursePressure == 1
        text = text + " The beast in you is being weighed against the code, not turned away from."
    endIf

    return text
EndFunction

String Function GetOrcSummary()
    if !Manager.PDV_OrcLifeModeTrack
        return "missing"
    endIf

    return "mode=" + GetOrcLifeModeLabel() + ";stronghold=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.Stronghold")) + ";city=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.City")) + ";legion=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.LegionExile")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Orc.LastLifeModeReason")
EndFunction


; ============================================================================
; Base virtual overrides (ADR interface). Each is a thin delegation to the
; verbatim lane function above -- the hand-reviewable dispatch layer the ADR
; calls out as the one part parity cannot cover.
;
; NOT overridden here, deliberately: IsOfferEligibleDeity and
; GetFormalCommitmentOfferMessage (Malacath is the innate Orc spine -- there is
; no Orc offer lane, and no GetOrcFormalCommitmentOfferMessage exists), and
; HandleContextualQuery (no Orc lane entry point returns a value a caller
; outside ORIGIN consumes). See the manifest.
; ============================================================================

; -- Lifecycle --
Function ApplyInitialChoice(Int choiceValue, String reason)
    ApplyOrcInitialChoice(choiceValue, reason)
EndFunction

Function EnsureRuntimeWiring()
    EnsureOrcLifeModeInitialized()
EndFunction

Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyOrcCurseHandlers(oldState, newState, reason)
EndFunction

Function EvaluateAtDawn()
    EvaluateOrcLifeModeAtDawn()
EndFunction

; -- State --
String Function GetOriginStateLabel()
    return GetOrcLifeModeLabel()
EndFunction

Int Function GetOriginStateValue()
    return GetActiveOrcRewardMode()
EndFunction

String Function GetOriginSummary()
    return GetOrcSummary()
EndFunction

String Function GetSurveyFragment()
    return GetOrcSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsOrcCodeNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "medallion-entries"
        return GetOrcMedallionEntriesJson()
    elseIf detailKey == "life-mode"
        return GetOrcLifeModeLabel()
    elseIf detailKey == "life-mode-weight-key"
        return GetOrcLifeModeWeightKey(GetActiveOrcRewardMode())
    elseIf detailKey == "life-mode-substrate-token"
        return GetOrcLifeModeSubstrateToken(GetActiveOrcRewardMode())
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "life-mode"
        return GetActiveOrcRewardMode()
    elseIf detailKey == "four-holds-visits"
        return GetOrcFourHoldsVisitCount()
    endIf

    return 0
EndFunction

; -- Signals --
; `reason` is threaded through UNCHANGED. It is caller-composed (the EventBus
; builds "eventbus_" + eventType + "_" + sourceId) and it is player-visible in
; the Ledger, so substituting the signalId here would silently rewrite stored
; reason and trace text. The signalId selects the handler and nothing else.
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "sleep"
        Actor sleepActor = contextForm as Actor
        if !sleepActor
            sleepActor = Game.GetPlayer()
        endIf
        HandleOrcSleepEvents(sleepActor, reason)
        return True
    elseIf signalId == "story-craft-forge"
        HandleOrcStoryCraftForge(contextForm as Location)
        return True
    elseIf signalId == "stronghold-forge"
        HandleOrcStrongholdForge(reason)
        return True
    elseIf signalId == "stronghold-presence"
        HandleOrcStrongholdPresence(magnitude as Int, reason)
        return True
    elseIf signalId == "blood-kin-crisis"
        HandleOrcBloodKinCrisis(reason)
        return True
    elseIf signalId == "city-dignity"
        HandleOrcCityDignity(reason)
        return True
    elseIf signalId == "legion-service"
        HandleOrcLegionService(reason)
        return True
    elseIf signalId == "self-made-community"
        HandleOrcSelfMadeCommunity(reason)
        return True
    elseIf signalId == "malacath-conduct"
        HandleOrcMalacathConduct(magnitude as Int, reason)
        return True
    elseIf signalId == "oath-break"
        HandleOrcOathBreak(reason)
        return True
    elseIf signalId == "four-holds-visit"
        HandleOrcFourHoldsVisit(magnitude as Int, reason)
        return True
    elseIf signalId == "code-holds"
        ; base HandlePlayerBelowHealthGate used to call TryOrcCodeHolds directly.
        TryOrcCodeHolds(contextForm as Actor)
        return True
    elseIf signalId == "sleep-stop"
        ; base HandlePlayerSleepStop dispatched this by origin index.
        HandleOrcSleepEvents(contextForm as Actor, reason)
        return True
    endIf

    return False
EndFunction

; The caller's own location is passed in and used as-is -- the live caller
; (PDV_ActionRouter.HandleStoryChangeLocation) hands over akNewLocation. Nothing
; is re-sampled from Game.GetPlayer().GetCurrentLocation() any more, so the
; earlier "not provably the caller's akNewLocation" concern is gone.
Function HandleLocationChange(Form newLocation = None)
    HandleOrcLocationChange(newLocation as Location)
EndFunction

; -- Upkeep --
Function SyncRaceRewards()
    SyncOrcRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncOrcNeglectSpell(IsOrcCodeNeglected())
EndFunction

; -- Presentation --
; Corrected signatures: the real Orc notifiers take a Message RECORD plus a
; fallback string, and a modal variant exists. The earlier keyed
; ShowOriginNotification(String) form was written against the pre-correction
; interface and is replaced here. Nothing is lost by that: the three keys it
; dispatched (MaybeShowOrcHearthHeldNotice / ...MissedCadenceNotice /
; MaybeShowOrcWatchersNotice) have no caller outside ORIGIN -- they are only
; reached from inside the lane bodies above.
Function ShowOriginNotification(Message messageRecord, String fallbackText)
    ShowOrcNotification(messageRecord, fallbackText)
EndFunction

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
    ShowOrcMessage(messageRecord, fallbackText, suppressModal)
EndFunction

; -- Gain provider (ADR D1) --
; DELEGATING PLACEHOLDER. GetOrcLifeModeGainMultiplier still lives in
; PDV__ManagerQuest and is NOT moved by this tranche; this body changes when the
; provider seam lands and the function moves here. The Orc race gate inside the
; manager function becomes redundant once this override is race-selected, but it
; is deliberately left in place for now.
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    ; phase 1 == AT_DAWN. Delegates for now; the function moves here with the seam.
    if phase == 1
        return Manager.GetOrcLifeModeGainMultiplier(deity)
    endIf
    return 1.0
EndFunction
