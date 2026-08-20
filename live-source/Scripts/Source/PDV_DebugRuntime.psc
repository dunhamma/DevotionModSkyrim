Scriptname PDV_DebugRuntime extends Quest

; MCM-driven test harness. Shipped behavior remains instance-only: no Debug function
; is Global or console-callable. RunDebugCommand and its registers stay on Manager.
PDV__ManagerQuest Property PDV_Manager Auto
PDV_DevotionLedger Property LedgerRuntime Auto
PDV_OriginRuntimeBase Property OriginRuntime Auto
PDV_DaedricRuntime Property DaedricRuntime Auto
PDV_ContextualFavorRuntime Property FavorRuntime Auto
PDV_QuestReactionRuntime Property PDV_QuestReactionRuntimeService Auto
PDV_CurseState Property PDV_CurseStateService Auto
PDV_DaedricPath_Hircine Property PDV_HircinePath Auto

Bool Function DebugGetDiegeticD1Enabled()
    if PDV_Manager.Prisma.PDV_DiegeticDirectorService
        return PDV_Manager.Prisma.PDV_DiegeticDirectorService.D1Enabled
    endIf
    return false
EndFunction

Function DebugSetDiegeticD1Enabled(Bool enabled)
    if PDV_Manager.Prisma.PDV_DiegeticDirectorService
        PDV_Manager.Prisma.PDV_DiegeticDirectorService.D1Enabled = enabled
    endIf
EndFunction

String Function DebugReloadQuestMatrix()
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugReloadCatalog()
    endIf
    return "Quest Reaction runtime is unavailable."
EndFunction

Int Function DebugGetSignalFloorSmokeScenarioCount()
    return 15
EndFunction

String Function DebugGetSignalFloorSmokeLabel(Int scenarioIndex)
    if scenarioIndex <= 0
        return "Reload matrix + LD v15"
    elseIf scenarioIndex == 1
        return "DLC2SV01 200"
    elseIf scenarioIndex == 2
        return "MQ305 200"
    elseIf scenarioIndex == 3
        return "MQ206 220"
    elseIf scenarioIndex == 4
        return "DBDestroy 200"
    elseIf scenarioIndex == 5
        return "MS10 100"
    elseIf scenarioIndex == 6
        return "CR13 200"
    elseIf scenarioIndex == 7
        return "MQ302 300"
    elseIf scenarioIndex == 8
        return "Crypt clear"
    elseIf scenarioIndex == 9
        return "Likes/dislikes v15"
    elseIf scenarioIndex == 10
        return "Green Way"
    elseIf scenarioIndex == 11
        return "Paarthurnax kill"
    elseIf scenarioIndex == 12
        return "Paarthurnax spare"
    elseIf scenarioIndex == 13
        return "T11: MQ101 150"
    elseIf scenarioIndex == 14
        return "T11: MQ105 160"
    elseIf scenarioIndex == 15
        return "T11: MQ106 200 - Syrabane"
    endIf
    return "Unknown"
EndFunction

String Function DebugRunSignalFloorSmokeScenario(Int scenarioIndex)
    String label = DebugGetSignalFloorSmokeLabel(scenarioIndex)
    StorageUtil.SetStringValue(None, "PDV.SignalFloorSmoke.LastScenario", label)

    if scenarioIndex <= 0
        String reloadText = DebugReloadQuestMatrix()
        StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
        LedgerRuntime.EnsureLikesDislikesTable()
        PDV_Manager.Trace(1, "SignalFloorSmoke debug reload completed.")
        return "Signal-floor baseline reloaded. " + reloadText
    elseIf scenarioIndex == 1
        return DebugRouteSignalFloorQuest(0x00019B4A, "Dragonborn.esm", 200, label)
    elseIf scenarioIndex == 2
        return DebugRouteSignalFloorQuest(0x00046EF2, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 3
        return DebugRouteSignalFloorQuest(0x00036193, "Skyrim.esm", 220, label)
    elseIf scenarioIndex == 4
        return DebugRouteSignalFloorQuest(0x000934FB, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 5
        return DebugRouteSignalFloorQuest(0x0001DBFC, "Skyrim.esm", 100, label)
    elseIf scenarioIndex == 6
        return DebugRouteSignalFloorQuest(0x000E3163, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 7
        return DebugRouteSignalFloorQuest(0x00045923, "Skyrim.esm", 300, label)
    elseIf scenarioIndex == 8
        return DebugRouteSignalFloorCryptClear()
    elseIf scenarioIndex == 9
        return DebugRouteSignalFloorLikesDislikes()
    elseIf scenarioIndex == 10
        return DebugRouteSignalFloorGreenWay()
    elseIf scenarioIndex == 11
        return DebugRouteSignalFloorPaarthurnaxKill()
    elseIf scenarioIndex == 12
        return DebugRouteSignalFloorPaarthurnaxSpare()
    elseIf scenarioIndex == 13
        return DebugRouteSignalFloorQuest(0x0003372B, "Skyrim.esm", 150, label)
    elseIf scenarioIndex == 14
        return DebugRouteSignalFloorQuest(0x000242BA, "Skyrim.esm", 160, label)
    elseIf scenarioIndex == 15
        return DebugRouteSignalFloorQuest(0x00032926, "Skyrim.esm", 200, label)
    endIf

    return "Unknown signal-floor smoke scenario."
EndFunction

String Function DebugRouteSignalFloorQuest(Int questFormId, String pluginName, Int stageValue, String label)
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugSubmitQuestStage(questFormId, pluginName, stageValue, label)
    endIf
    return label + ": Quest Reaction runtime is unavailable."
EndFunction

String Function DebugQueueQuestReactionPerformanceSweep()
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugQueuePerformanceSweep()
    endIf
    return "Quest Reaction runtime is unavailable."
EndFunction

String Function DebugRouteSignalFloorCryptClear()
    if !PDV_Manager.PDV_FLST_UndeadCryptClearSites || PDV_Manager.PDV_FLST_UndeadCryptClearSites.GetSize() <= 0
        return "Crypt-clear FormList is missing or empty."
    endIf

    Location cryptLoc = PDV_Manager.PDV_FLST_UndeadCryptClearSites.GetAt(0) as Location
    if !cryptLoc
        return "Crypt-clear FormList slot 0 is not a Location."
    endIf

    OriginRuntime.ApplyUndeadCryptClearReactions(cryptLoc, 1.0)
    PDV_Manager.Trace(1, "SignalFloorSmoke crypt-clear debug fanout routed.")
    return "Crypt-clear fanout routed from FormList slot 0. Controlled backend route only; organic proof still requires entering and clearing a listed crypt."
EndFunction

String Function DebugRouteSignalFloorLikesDislikes()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
    LedgerRuntime.EnsureLikesDislikesTable()
    DebugFireDislike(PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Kyne"), 303)
    DebugFireDislike(PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Arkay"), 366)
    PDV_Manager.Trace(1, "SignalFloorSmoke LD v15 debug fired events 303 and 366.")
    return "Likes/dislikes v15 reloaded; fired Kyne 303 and Arkay 366 through the debug dislike harness. Controlled backend route only."
EndFunction

String Function DebugRouteSignalFloorGreenWay()
    if !OriginRuntime.IsBosmerOrigin()
        return "Set origin to Bosmer before running Green Way signal-floor debug."
    endIf

    Bool siteRouted = OriginRuntime.TryAwardBosmerYffreGreenSite("mcm_signal_floor", "mcm_signal_floor_green_site")
    DebugTriggerGreenPactViolation()
    PDV_Manager.Trace(1, "SignalFloorSmoke Green Way debug routed; site=" + PDV_DevotionRules.BoolToInt(siteRouted))
    return "Green Way backend routes fired. Site=" + PDV_DevotionRules.BoolToInt(siteRouted) + ". Plant-food organic proof still requires consuming a listed plant food."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxKill()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    OriginRuntime.HandlePaarthurnaxKill(sourceForm, "mcm_signal_floor_kill")
    PDV_Manager.Trace(1, "SignalFloorSmoke Paarthurnax kill debug routed.")
    return "Paarthurnax kill fork routed with latches reset first. Controlled backend route only; organic kill proof still required."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxSpare()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    OriginRuntime.HandlePaarthurnaxSpare(sourceForm, "mcm_signal_floor_spare")
    PDV_Manager.Trace(1, "SignalFloorSmoke Paarthurnax spare debug routed.")
    return "Paarthurnax spare fork routed with latches reset first. Controlled backend route only; organic MQ305/alive proof still required."
EndFunction

Function DebugSeedArgonian(Float histValue, Float peopleValue, Float voidValue)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_ARGONIAN
        Debug.MessageBox("PDV seed: player origin is not Argonian (set PDV_Manager.PDV_GLO_OriginRace to 7 first).")
        return
    endIf

    if !PDV_Manager.PDV_ArgonianHistSubstrate
        Debug.MessageBox("PDV seed: Argonian substrate is not wired.")
        return
    endIf

    PDV_Manager.PDV_ArgonianHistSubstrate.SetHistRelation(histValue, "debug_seed")
    PDV_Manager.PDV_ArgonianHistSubstrate.SetPeopleRelation(peopleValue, "debug_seed")
    PDV_Manager.PDV_ArgonianHistSubstrate.SetVoidRelation(voidValue, "debug_seed")

    Int signals = 0
    if voidValue > 0.0
        signals = PDV_Manager.PDV_ArgonianHistSubstrate.VoidActivationSignalsRequired
    endIf
    StorageUtil.SetIntValue(PDV_Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", signals)

    OriginRuntime.RefreshArgonianHistPosture("debug_seed")
    OriginRuntime.SyncRaceRewards()

    Bool voidActive = PDV_Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
    Debug.MessageBox("PDV relation seed applied. Hist " + histValue + ", People " + peopleValue + ", Void " + voidValue + ". Cultural practice remains " + PDV_Manager.PDV_ArgonianHistSubstrate.GetMetric() + "; Void active " + voidActive + ". Use Debug: Pacing & Pantheons seed 75 separately for adaptation-threshold proof.")
EndFunction

Function DebugSeedBosmer(Int pathIndex)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BOSMER
        Debug.MessageBox("PDV seed: player origin is not Bosmer (set origin to Bosmer first).")
        return
    endIf
    if PDV_Manager.PDV_BosmerPathTrack
        PDV_Manager.PDV_BosmerPathTrack.SetState(pathIndex, "debug_seed")
    endIf
    DebugSeedBosmerVariety()
EndFunction

Function DebugSeedBosmerVariety()
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BOSMER
        Debug.MessageBox("PDV seed: player origin is not Bosmer (set origin to Bosmer first).")
        return
    endIf
    StorageUtil.SetFloatValue(None, "PDV.BosNaming.LastRiteTime", 0.0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.ScalesLastDay", 0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.GapLastDay", 0)
    StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 3)
    Debug.MessageBox("PDV seed: Bosmer variety cooldowns cleared; +3 discoveries seeded. Naming offered at your hearth or any green song next sleep.")
EndFunction

String Function DebugSetKhajiitLunarMetric(Float metricTarget)
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_Manager.PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    Float clampedTarget = metricTarget
    if clampedTarget < 0.0
        clampedTarget = 0.0
    elseIf clampedTarget > 100.0
        clampedTarget = 100.0
    endIf
    PDV_Manager.PDV_KhajiitLunarSubstrate.SetMetric(clampedTarget, "mcm_debug_lunar_seed")
    PDV_Manager.Prisma.RequestPanelRefresh()
    return "Lunar metric set to " + PDV_DevotionRules.FormatTwoDecimals(clampedTarget) + "; tier " + PDV_Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier() + ". Direct boundary seed; bypasses the daily metric budget."
EndFunction

String Function DebugResetKhajiitLunarSubstrate()
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_Manager.PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    PDV_Manager.PDV_KhajiitLunarSubstrate.ResetPilotForDebug()
    StorageUtil.SetIntValue(None, "PDV.Khajiit.LunarMetricDay", -1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LunarMetricToday", 0.0)
    PDV_Manager.Prisma.RequestPanelRefresh()
    return "Lunar substrate reset to zero; daily metric budget cleared."
EndFunction

String Function DebugGetKhajiitLunarBudgetSummary()
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_Manager.PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Float spentToday = 0.0
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarMetricDay", -1) == today
        spentToday = StorageUtil.GetFloatValue(None, "PDV.Khajiit.LunarMetricToday")
    endIf
    Float remaining = PDV_Manager.KHAJIIT_LUNAR_METRIC_DAILY_MAX - spentToday
    if remaining < 0.0
        remaining = 0.0
    endIf
    return "Lunar metric " + PDV_DevotionRules.FormatTwoDecimals(PDV_Manager.PDV_KhajiitLunarSubstrate.GetMetric()) + ", tier " + PDV_Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier() + ". Today " + PDV_DevotionRules.FormatTwoDecimals(spentToday) + " of " + PDV_DevotionRules.FormatTwoDecimals(PDV_Manager.KHAJIIT_LUNAR_METRIC_DAILY_MAX) + " metric used, " + PDV_DevotionRules.FormatTwoDecimals(remaining) + " remaining."
EndFunction

Function DebugForceKhajiitLunarPosture(Int newPosture, String reason)
    if !PDV_Manager.PDV_KhajiitLunarPostureTrack
        return
    endIf

    if newPosture == PDV_Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        StorageUtil.SetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce", 0)
    endIf

    Int oldPosture = OriginRuntime.GetKhajiitLunarPosture()
    PDV_Manager.PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    if newPosture != oldPosture
        if newPosture == PDV_Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
            OriginRuntime.ShowOriginMessage(PDV_Manager.PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow.", False)
        endIf
        PDV_Manager.Prisma.SendPrismaShiftToast(OriginRuntime.GetKhajiitLunarPostureDisplayLabelAt(newPosture), OriginRuntime.GetKhajiitLunarPostureReadout(newPosture), "lunar")
        PDV_Manager.Prisma.RequestPanelRefresh()
    endIf
EndFunction

Function DebugCycleKhajiitLunarPosture()
    Int nextPosture = OriginRuntime.GetKhajiitLunarPosture() + 1
    if nextPosture > PDV_Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        nextPosture = PDV_Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
    endIf

    DebugForceKhajiitLunarPosture(nextPosture, "mcm_cycle")
EndFunction

Bool Function DebugAssertAltmerRejectedSurface(String sourceId)
    return OriginRuntime.IsAltmerRejectedLorkhanSurface(sourceId)
EndFunction

Function DebugClosePrismaSurfaces()
    PDV_Manager.SetPanelDirty(False)
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson("{\"journalClose\":true}")
    PDV_PrismaBridge.CancelChoice()
    PDV_PrismaBridge.CloseDevotionPanel()
EndFunction

Function DebugSyncRewardsOnly()
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
    PDV_Manager.SetPanelDirty(False)
    DebugClosePrismaSurfaces()
    if PDV_Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Debug reward sync complete.")
    endIf
EndFunction

Function DebugForceSetPietyByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugForceSetPietyByIndex")
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", PDV_DevotionRules.ClampValue(amount, 0.0, LedgerRuntime.PIETY_MAX))
    ; Surface the tier change so a debug-forced tier reach is testable (notice + toast +
    ; Book of Days entry). Only fires on an UP-crossing from a lower tier -- if the deity
    ; is already at/above the target, reset it first, or use the piety-today + dawn path.
    LedgerRuntime.RecomputeTier(deity, True)
    if PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_KHAJIIT && OriginRuntime.GetKhajiitFocusForDeity(deity) != PDV_Manager.KHAJIIT_FOCUS_NONE
        OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    endIf
    ; Resync the race reward family so a focused/emphasis reward (Khajiit emphasis, an
    ; Imperial/Altmer focused patron, etc.) actually grants on the seed. RecomputeTier only
    ; fires OnTierChange (Boon slots), not SyncFirstTierRaceRewardRuntime -- without this a
    ; debug piety seed reads a false 0 on the HP bar until a dawn pass.
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
EndFunction

Function DebugForceSetPietyTodayByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyTodayByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugForceSetPietyTodayByIndex")
        return
    endIf

    StorageUtil.SetFloatValue(deity as Form, "PDV.PietyToday", amount)
EndFunction

Function DebugPrimeDecayGraceByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayGraceByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugPrimeDecayGraceByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", LedgerRuntime.GetDevotionalDay() + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    LedgerRuntime.RecomputeTier(deity)
    PDV_Manager.Trace(1, "Decay grace primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugPrimeDecayEligibleByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayEligibleByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugPrimeDecayEligibleByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - LedgerRuntime.DECAY_GRACE_DAYS - 1.0)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", LedgerRuntime.GetDevotionalDay() + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    LedgerRuntime.RecomputeTier(deity)
    PDV_Manager.Trace(1, "Decay eligible primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugRunDecayPass()
    LedgerRuntime.RunDawnApplyDecay()
    PDV_Manager.Trace(1, "Decay pass debug run.")
EndFunction

Function DebugRunDecayProofDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugRunDecayProofDaysByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugRunDecayProofDaysByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    endIf
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - LedgerRuntime.DECAY_GRACE_DAYS - 1.0)
    LedgerRuntime.RecomputeTier(deity)

    Int i = 0
    while i < 400
        currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
        Float floorValue = LedgerRuntime.GetDecayFloorForDeity(deity, currentPiety)
        if currentPiety <= floorValue
            i = 400
        else
            StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", ((nowTime + i) as Int) - 1)
            LedgerRuntime.ApplyDecayToDeity(deity, nowTime + i)
        endIf
        i += 1
    endWhile
    PDV_Manager.Trace(1, "Decay proof days run for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugAwardCuratedSignalByIndex(Int deityIndex, Int signalType)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugAwardCuratedSignalByIndex")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalByIndex(deityIndex, signalType)
EndFunction

String Function DebugGetPietyMapString()
    if !LedgerRuntime.PDV_FLST_AllDeities
        return "No deity roster is assigned."
    endIf

    Int i = 0
    Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    String output = ""
    Int shown = 0

    ; Only list deities that have moved (stored piety, scratch piety, or a tier), so the
    ; message box stays short and readable instead of dumping the whole roster at zero.
    while i < count
        PDV_DeityBase deity = LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float piety = LedgerRuntime.GetPiety(deity)
            Float today = LedgerRuntime.GetPietyToday(deity)
            Int tier = LedgerRuntime.GetTier(deity)
            if piety != 0.0 || today != 0.0 || tier != 0
                String entry = deity.DeityName + ": tier=" + tier + " piety=" + piety + " scratch=" + today
                if output == ""
                    output = entry
                else
                    output = output + "\n" + entry
                endIf
                shown += 1
            endIf
        endIf
        i += 1
    endWhile

    if shown == 0
        return "All " + count + " deities are at zero (no piety, scratch, or tier yet)."
    endIf

    return "Active deities (" + shown + " of " + count + "):\n" + output
EndFunction

Function DebugClearActiveDeity()
    if LedgerRuntime.IsUnsafeFaultInjectionActive()
        LedgerRuntime.ClearUnsafeFaultInjection()
        return
    endIf

    LedgerRuntime.SetActiveDeity(None)
    ; Strip the now-unfocused patron's reward spells immediately (same dawn-lag class
    ; as ForceSetActiveDeityByIndex).
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
EndFunction

Function DebugSetBroadWorship()
    LedgerRuntime.SetBroadWorship()
EndFunction

Function DebugSeedBroadLane()
    LedgerRuntime.SetBroadWorship()
    Int origin = PDV_Manager.GetPlayerOriginRaceIndex()
    if origin == PDV_Manager.ORIGIN_IMPERIAL
        LedgerRuntime.SetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_IMPERIAL, LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD, "debug_seed_broad_lane")
    elseIf origin == PDV_Manager.ORIGIN_BRETON
        OriginRuntime.SetBretonPracticeCount(OriginRuntime.GetBretonTraditionValue(), PDV_Manager.BRETON_PRACTICE_DEVOTED_POINTS)
    elseIf origin == PDV_Manager.ORIGIN_ORC
        StorageUtil.SetIntValue(None, "PDV.Orc.MalacathSourceCount", 6)
    elseIf origin == PDV_Manager.ORIGIN_ALTMER
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count", 6)
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count", 6)
    else
        PDV_Manager.Trace(1, "DebugSeedBroadLane: origin " + origin + " has no broad-lane accumulator wired here (Nord/others not yet covered).")
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    PDV_Manager.Trace(1, "DebugSeedBroadLane seeded broad lane for origin " + origin + ".")
EndFunction

String Function DebugGetBretonPracticeSummary()
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BRETON
        return "Breton practice controls require Breton origin."
    endIf

    Int traditionValue = OriginRuntime.GetBretonTraditionValue()
    Int practicePoints = OriginRuntime.GetBretonPracticeCount(traditionValue)
    Int today = LedgerRuntime.GetDevotionalDay() + 2
    Int pointDay = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointDay", -1)
    Int pointsToday = 0
    if pointDay == today
        pointsToday = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointsToday")
    endIf
    pointsToday = PDV_DevotionRules.ClampInt(pointsToday, 0, PDV_Manager.BRETON_PRACTICE_DAILY_MAX_POINTS)
    Int remainingToday = PDV_Manager.BRETON_PRACTICE_DAILY_MAX_POINTS - pointsToday
    return OriginRuntime.GetBretonTraditionLabel() + ": " + practicePoints + "/" + PDV_Manager.BRETON_PRACTICE_DEVOTED_POINTS + " practice points (" + PDV_Manager.Prisma.GetPublicTierBand(OriginRuntime.GetBretonPracticeTier(traditionValue)) + "). Today: " + pointsToday + "/" + PDV_Manager.BRETON_PRACTICE_DAILY_MAX_POINTS + "; remaining " + remainingToday + "."
EndFunction

String Function DebugSetBretonPracticePoints(Int practicePoints)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BRETON
        return "Breton practice target ignored: set Breton origin first."
    endIf

    Int traditionValue = OriginRuntime.GetBretonTraditionValue()
    OriginRuntime.SetBretonPracticeCount(traditionValue, practicePoints)
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointDay", LedgerRuntime.GetDevotionalDay() + 2)
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", 0)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    PDV_Manager.Trace(1, "DebugSetBretonPracticePoints: tradition " + traditionValue + " -> " + PDV_DevotionRules.ClampInt(practicePoints, 0, PDV_Manager.BRETON_PRACTICE_DEVOTED_POINTS) + ".")
    return DebugGetBretonPracticeSummary()
EndFunction

String Function DebugAddBretonPracticePoints(Int requestedPoints)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BRETON
        return "Breton practice pulse ignored: set Breton origin first."
    endIf
    if requestedPoints != PDV_Manager.BRETON_PRACTICE_RENEWABLE_POINTS && requestedPoints != PDV_Manager.BRETON_PRACTICE_CURATED_POINTS
        return "Breton practice pulse ignored: debug weight must be +1 or +2."
    endIf

    Int sequence = StorageUtil.GetIntValue(None, "PDV.Debug.BretonPracticePulseSeq") + 1
    StorageUtil.SetIntValue(None, "PDV.Debug.BretonPracticePulseSeq", sequence)
    Bool applied = OriginRuntime.AwardBretonPracticePulse(OriginRuntime.GetBretonTraditionValue(), requestedPoints, "mcm_debug_" + sequence, "mcm-debug-practice")
    if !applied
        return "No practice points applied. " + DebugGetBretonPracticeSummary()
    endIf
    return DebugGetBretonPracticeSummary()
EndFunction

String Function DebugResetBretonPracticePoints()
    String summary = DebugSetBretonPracticePoints(0)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BRETON
        return summary
    endIf
    return "Practice points and today's debug budget reset. " + summary
EndFunction

String Function DebugGetOriginDiagnostic()
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") == 1
        return "Custom race fallback: Imperial"
    endIf

    return "No custom race fallback"
EndFunction

Function DebugResetDeityByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if PDV_Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugResetDeityByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    Int oldTier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int

    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.Tier", LedgerRuntime.TIER_NONE as Float)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)

    if deity == PDV_Manager.GetActiveDeity()
        deity.OnTierChange(oldTier, LedgerRuntime.TIER_NONE)
        LedgerRuntime.RefreshPatronMirrors()
    endIf
    if PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_KHAJIIT
        OriginRuntime.EvaluateKhajiitFocusedEmphasis()
        OriginRuntime.SyncKhajiitRuntimeState()
    endIf
EndFunction

Function DebugFireDislike(PDV_DeityBase deity, Int eventType)
    if !deity
        PDV_Manager.Trace(1, "DebugFireDislike skipped: no deity.")
        return
    endIf
    if !LedgerRuntime.IsGenericLikesDislikesDeityReachable(deity)
        PDV_Manager.Trace(1, "DebugFireDislike: " + deity.DeityName + " is not reachable in the current origin/baseline.")
        return
    endIf
    Float delta = LedgerRuntime.GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        PDV_Manager.Trace(1, "DebugFireDislike: no dislike row for " + deity.DeityName + " event " + eventType)
        return
    endIf
    Int domainValue = LedgerRuntime.DomainForDeity(deity)
    if domainValue != LedgerRuntime.DISFAVOR_DOMAIN_NONE
        StorageUtil.SetIntValue(deity as Form, LedgerRuntime.GetDisfavorRepeatDayKey(domainValue, eventType), -1)
    endIf
    Bool nativeSurface = LedgerRuntime.ShouldSurfaceLikesDislikesEvent(eventType)
    LedgerRuntime.AwardPietyFromLikesDislikes(deity, delta, eventType, "debug_fire_dislike")
    if !nativeSurface
        LedgerRuntime.SurfaceDebugDislikeEvent(deity, delta, eventType)
    endIf
    PDV_Manager.Trace(1, "DebugFireDislike: " + deity.DeityName + " event " + eventType + " delta " + delta)
EndFunction

Function DebugApplyDomainSting(Int domainValue, Bool sharp)
    LedgerRuntime.ApplyDebugDomainSting(domainValue, sharp, False)
EndFunction

Function DebugBurstAntiStack()
    LedgerRuntime.ClearAllDisfavorStings()
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_SKY_STORM_HUNT, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_DEATH_ANCESTORS, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_WAR_HONOR, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_ORDER_TRADE_LORE, True, True)
    PDV_Manager.Trace(1, "DebugBurstAntiStack: " + LedgerRuntime.GetActiveDisfavorSummary())
EndFunction

String Function DebugDislikeSummaryLine(PDV_DeityBase deity, Int eventType)
    if !deity
        return "event " + eventType + " | no deity"
    endIf
    if !LedgerRuntime.IsGenericLikesDislikesDeityReachable(deity)
        return "event " + eventType + " | " + deity.DeityName + " | not current pantheon"
    endIf
    Float delta = LedgerRuntime.GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        return "event " + eventType + " | " + deity.DeityName + " | no dislike row"
    endIf
    return "event " + eventType + " | " + deity.DeityName + " | " + delta + " -> " + LedgerRuntime.GetDisfavorDomainLabel(LedgerRuntime.DomainForDeity(deity))
EndFunction

Function DebugApplyTalosBetrayalCompliance()
    if !OriginRuntime.HandleTalosBetrayal(2, "mcm")
        Debug.Notification("Talos betrayal did not apply; check origin, active Talos, Concordat, or repeat state.")
    endIf
EndFunction

Function DebugApplyTalosBetrayalMajor()
    if !OriginRuntime.HandleTalosBetrayal(3, "mcm")
        Debug.Notification("Talos betrayal did not apply; check origin, active Talos, Concordat, or repeat state.")
    endIf
EndFunction

Function DebugUnlockConcordatWalkback()
    if PDV_Manager.PDV_ConcordatStandingTrack
        PDV_Manager.PDV_ConcordatStandingTrack.UnlockExtremeResetGate("mcm_unlock")
    endIf
EndFunction

Function DebugSetBosmerPathState(Int stateValue)
    if !PDV_Manager.PDV_BosmerPathTrack
        return
    endIf

    PDV_Manager.BeginRaceSetupQuietPresentation("mcm_bosmer_path")
    OriginRuntime.InitializeBosmerStorage()
    PDV_Manager.PDV_BosmerPathTrack.SetState(stateValue, "mcm_pattern")
    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)

    if stateValue == PDV_Manager.BOSMER_PATH_OLD_CONTRACT
        OriginRuntime.SetBosmerPactBound(True, "mcm_pattern")
        OriginRuntime.SetBosmerGreenPactCompliance(80, "mcm_pattern")
    else
        OriginRuntime.SetBosmerPactBound(False, "mcm_pattern")
        OriginRuntime.SetBosmerGreenPactCompliance(0, "mcm_pattern")
    endIf

    OriginRuntime.ApplyBosmerPathPatron(stateValue, "mcm_pattern")
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
    PDV_Manager.EndRaceSetupQuietPresentation()
EndFunction

Function DebugTriggerGreenPactViolation()
    OriginRuntime.HandleGreenPactViolation("mcm")
EndFunction

Function DebugRecordBosmerLivingStorySignal()
    OriginRuntime.HandleBosmerLivingStorySignal("mcm")
EndFunction

Function DebugRecordBosmerExchangeSignal()
    OriginRuntime.HandleBosmerExchangeSignal("mcm")
EndFunction

Function DebugRecordBosmerBanditRoadSignal()
    OriginRuntime.HandleBosmerBanditRoadSignal("mcm")
EndFunction

Function DebugRecordBosmerPactPositiveSignal()
    OriginRuntime.HandleBosmerPactPositiveSignal("mcm")
EndFunction

Function DebugConfirmStateTransitionRite()
    OriginRuntime.HandleStateTransitionConfirmationRite("mcm")
EndFunction

Function DebugRecordDunmerAncestorPrayer()
    OriginRuntime.HandleDunmerPortableShrinePrayer("mcm")
EndFunction

Function DebugRecordDunmerAncestorHomeBonus()
    OriginRuntime.HandleDunmerPlayerHomeBonus("mcm")
EndFunction

Function DebugRecordKhajiitMoonObservance()
    Int nextPhase = OriginRuntime.GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    if PDV_Manager.PDV_KhajiitLunarSubstrate && PDV_Manager.PDV_KhajiitLunarSubstrate.GetLastObservedPhase() == nextPhase
        nextPhase += 1
        if nextPhase > 8
            nextPhase = 1
        endIf
    endIf
    OriginRuntime.HandleKhajiitMoonObservance(nextPhase, "mcm")
EndFunction

Function DebugRecordKhajiitRoadHome()
    OriginRuntime.HandleKhajiitRoadHome("mcm")
EndFunction

Function DebugRecordKhajiitCaravanAid()
    OriginRuntime.HandleKhajiitKhenarthiCaravanAid("mcm")
EndFunction

Function DebugRecordKhajiitLegendMade()
    OriginRuntime.HandleKhajiitRajhinLegendMade("mcm")
EndFunction

Function DebugRecordMephalaWebWoven()
    DaedricRuntime.HandleMephalaWebWoven("mcm")
EndFunction

Function DebugRecordBoethiahHonorableDuel()
    DaedricRuntime.HandleBoethiahHonorableDuel("mcm")
EndFunction

Function DebugRecordArgonianHistMaintenance()
    OriginRuntime.HandleArgonianHistMaintenance("mcm")
EndFunction

Function DebugRecordArgonianPeopleSupport()
    OriginRuntime.HandleArgonianPeopleSupport("mcm")
EndFunction

Function DebugRecordArgonianBedOfChoiceReturn()
    OriginRuntime.HandleArgonianBedOfChoiceReturn("mcm")
EndFunction

Function DebugRecordArgonianVoidSignal()
    OriginRuntime.HandleArgonianVoidSignal("mcm")
EndFunction

Function DebugRecordTalosShrineDefiance()
    OriginRuntime.HandleTalosShrineDefiance("mcm")
EndFunction

Function DebugRecordAltmerDawnSteadiness()
    OriginRuntime.HandleAltmerDawnSteadiness("mcm")
EndFunction

Function DebugRecordAltmerOrthodoxCostlyEnforcement()
    OriginRuntime.HandleAltmerOrthodoxCostlyEnforcement("mcm")
EndFunction

Function DebugRecordAltmerDragonbornCrisis()
    OriginRuntime.HandleAltmerCrisisSource(PDV_Manager.ALTMER_CRISIS_SOURCE_DRAGONBORN, "mcm_dragonborn")
EndFunction

Function DebugRecordAltmerLorkhanPressure()
    OriginRuntime.HandleAltmerLorkhanPressure(PDV_Manager.ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION, "mcm_lorkhan_pressure")
EndFunction

Function DebugSetNordPantheonBaseline(Int stateValue)
    Int normalizedState = PDV_DevotionRules.ClampInt(stateValue, PDV_Manager.NORD_BASELINE_OLD_WAYS, PDV_Manager.NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalizedState)
    if PDV_Manager.PDV_NordPantheonBaselineTrack && PDV_Manager.PDV_NordPantheonBaselineTrack.GetCurrentState() != normalizedState
        PDV_Manager.PDV_NordPantheonBaselineTrack.SetState(normalizedState, "mcm_pattern")
    endIf
    PDV_DeityBase pending = LedgerRuntime.GetPendingCommitmentDeity()
    if pending && !OriginRuntime.IsOfferEligibleDeity(pending)
        LedgerRuntime.ClearPendingCommitment()
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && PDV_Manager.GetActiveDeity() && !OriginRuntime.IsOfferEligibleDeity(PDV_Manager.GetActiveDeity())
        LedgerRuntime.SetBroadWorship()
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
EndFunction

String Function DebugGetSubstratePacingSummary(Int originValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No active pacing substrate is wired for origin " + originValue + "."
    endIf
    String summary = "metric=" + substrate.GetMetric() + " tier=" + substrate.GetSubstrateTier() + " day=" + substrate.GetDevotionalDay() + " encodedStamp=" + substrate.GetEncodedDailyCreditStamp() + " spent=" + substrate.IsDailyCreditSpent() + " accepted=" + substrate.GetLastAcceptedSource() + " acceptedEvent=" + substrate.GetLastAcceptedLogicalEvent() + " rejected=" + substrate.GetLastRejectedSource() + " rejectedEvent=" + substrate.GetLastRejectedLogicalEvent() + " rejectReason=" + substrate.GetLastCreditRejectReason() + " decay=" + OriginRuntime.GetSubstrateDecaySummary(originValue)
    if originValue == PDV_Manager.ORIGIN_KHAJIIT
        summary = summary + " moonReject=" + StorageUtil.GetStringValue(None, "PDV.Khajiit.MoonRite.LastReject")
    endIf
    return summary
EndFunction

String Function DebugTriggerSubstratePacingSource(Int originValue, Int sourceIndex = 0)
    if originValue == PDV_Manager.ORIGIN_IMPERIAL
        if sourceIndex == 0
            OriginRuntime.HandleImperialCivicService("mcm_debug_public_service")
        elseIf sourceIndex == 1
            LedgerRuntime.HandleSubstrateShrinePrayer("Mara", "", "", "mcm_debug_divine_prayer")
        else
            OriginRuntime.HandleImperialSleepEvents(Game.GetPlayer(), "mcm_debug_rejected_sleep")
            if PDV_Manager.PDV_ImperialAncestorSubstrate
                PDV_Manager.PDV_ImperialAncestorSubstrate.RecordDailyCreditReject("imperial_sleep", "mcm_debug_rejected_sleep", "retired_route")
            endIf
        endIf
    elseIf originValue == PDV_Manager.ORIGIN_DUNMER
        if sourceIndex == 0
            OriginRuntime.HandleDunmerPortableShrinePrayer("mcm_debug_portable_prayer")
        elseIf sourceIndex == 1
            OriginRuntime.HandleDunmerReclamationFocus(1, "mcm_debug_reclamation_book")
        else
            OriginRuntime.HandleDunmerPlayerHomeBonus("mcm_debug_rejected_home_only")
        endIf
    elseIf originValue == PDV_Manager.ORIGIN_ARGONIAN
        if sourceIndex == 0
            OriginRuntime.HandleArgonianHistMaintenance("mcm_debug_hist_maintenance")
        elseIf sourceIndex == 1
            OriginRuntime.HandleArgonianPeopleSupport("mcm_debug_people_support")
        elseIf PDV_Manager.PDV_ArgonianHistSubstrate
            PDV_Manager.PDV_ArgonianHistSubstrate.RecordDailyCreditReject("argonian_brief_swim", "mcm_debug_brief_swim", "duration_too_short")
        endIf
    elseIf originValue == PDV_Manager.ORIGIN_NORD
        if sourceIndex == 0
            if OriginRuntime.GetNordPantheonBaselineState() == PDV_Manager.NORD_BASELINE_NINE_DIVINES
                OriginRuntime.HandleNordOldWaysState("mcm_debug_nine_road_grace")
            else
                OriginRuntime.HandleNordOldWaysState("mcm_debug_sky_road")
            endIf
        elseIf sourceIndex == 1 && PDV_Manager.PDV_NordAncestorSubstrate
            OriginRuntime.HandleSubstrateActionEvent(313, "mcm_debug_open_sky_rest")
        elseIf PDV_Manager.PDV_NordAncestorSubstrate
            PDV_Manager.PDV_NordAncestorSubstrate.RecordDailyCreditReject("nord_universal_shor", "mcm_debug_universal_shor", "retired_route")
        endIf
    elseIf originValue == PDV_Manager.ORIGIN_ALTMER
        if sourceIndex == 0
            LedgerRuntime.HandleSubstrateShrinePrayer("Auri-El", "", "", "mcm_debug_auriel_rite")
        elseIf sourceIndex == 1
            OriginRuntime.HandleAltmerMagicSkillIncrease("Alteration")
        elseIf PDV_Manager.PDV_AltmerAncestorSubstrate
            PDV_Manager.PDV_AltmerAncestorSubstrate.RecordDailyCreditReject("altmer_passive_dawn", "mcm_debug_passive_dawn", "retired_route")
        endIf
    elseIf originValue == PDV_Manager.ORIGIN_KHAJIIT
        if sourceIndex == 0
            OriginRuntime.HandleKhajiitRoadHome("mcm_debug_outdoor_rest")
        elseIf sourceIndex == 1
            OriginRuntime.HandleKhajiitLunarSubstrate("mcm_debug_caravan_defense")
        else
            OriginRuntime.HandleKhajiitRoadHomeAnchor(1, "mcm_debug_rejected_anchor")
            if PDV_Manager.PDV_KhajiitLunarSubstrate
                PDV_Manager.PDV_KhajiitLunarSubstrate.RecordDailyCreditReject("khajiit_road_anchor", "mcm_debug_rejected_anchor", "retired_route")
            endIf
        endIf
    endIf
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugSeedSubstrateMetric(Int originValue, Float metricValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    OriginRuntime.ResetSubstratePacingState(originValue)
    substrate.DebugSetMetric(PDV_DevotionRules.ClampValue(metricValue, 0.0, 75.0))
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugResetSubstratePacing(Int originValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    OriginRuntime.ResetSubstratePacingState(originValue)
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugGetBroadPantheonSummary(Int poolIndex)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    Int gainStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastGainDayKey(poolId))
    Int processedStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastProcessedDayKey(poolId))
    Int scratchStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonScratchDayKey(poolId))
    return poolId + " roster=" + LedgerRuntime.GetBroadPantheonRosterForDebug(poolId) + " standing=" + LedgerRuntime.GetBroadPantheonStanding(poolId) + " scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId) + " scratchDay=" + (scratchStamp - 2) + " active=" + (LedgerRuntime.GetActiveBroadPantheonPoolId() == poolId) + " lastGainDay=" + (gainStamp - 2) + " lastProcessedDay=" + (processedStamp - 2) + " grace=2 decay=-0.1/day lastEvent=" + StorageUtil.GetStringValue(None, LedgerRuntime.GetBroadPantheonLastEventKey(poolId))
EndFunction

String Function DebugSeedBroadPantheonPool(Int poolIndex, Float standingValue)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    LedgerRuntime.SetBroadPantheonStanding(poolId, standingValue, "mcm_boundary_seed")
    LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    return DebugGetBroadPantheonSummary(poolIndex)
EndFunction

String Function DebugResetBroadPantheonPool(Int poolIndex)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    LedgerRuntime.ResetBroadPantheonPool(poolId)
    return DebugGetBroadPantheonSummary(poolIndex)
EndFunction

String Function DebugRunBroadPantheonFanoutTest()
    String poolId = LedgerRuntime.GetActiveBroadPantheonPoolId()
    if poolId == ""
        return "Set Imperial/Nord broad worship and an active baseline first."
    endIf
    PDV_Manager.SetBroadPantheonSelfEventSequence(PDV_Manager.GetBroadPantheonSelfEventSequence() + 1)
    String fixtureId = "mcm_signed_fanout_" + PDV_Manager.GetBroadPantheonSelfEventSequence()
    Float scratchBefore = LedgerRuntime.GetBroadPantheonScratch(poolId)
    LedgerRuntime.BeginBroadPantheonEvent(fixtureId)
    if poolId == LedgerRuntime.BROAD_PANTHEON_NORD_OLD
        LedgerRuntime.AwardPietyInternal(PDV_Manager.PDV_Kyne, 1.0, True, fixtureId + "_kyne")
        LedgerRuntime.AwardPietyInternal(PDV_Manager.PDV_Shor, 2.0, True, fixtureId + "_shor")
        LedgerRuntime.AwardPietyInternal(PDV_Manager.PDV_Tsun, -4.0, True, fixtureId + "_tsun")
    else
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Akatosh, 1.0, True, fixtureId + "_akatosh")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Mara, 2.0, True, fixtureId + "_mara")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Zenithar, -4.0, True, fixtureId + "_zenithar")
    endIf
    LedgerRuntime.FlushBroadPantheonEvent()
    Float positiveEventDelta = LedgerRuntime.GetBroadPantheonScratch(poolId) - scratchBefore
    LedgerRuntime.BeginBroadPantheonEvent(fixtureId + "_negative")
    if poolId == LedgerRuntime.BROAD_PANTHEON_NORD_OLD
        LedgerRuntime.AwardPietyInternal(PDV_Manager.PDV_Kyne, -1.0, False, fixtureId + "_kyne_negative")
        LedgerRuntime.AwardPietyInternal(PDV_Manager.PDV_Tsun, -4.0, False, fixtureId + "_tsun_negative")
    else
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Mara, -1.0, False, fixtureId + "_mara_negative")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Zenithar, -4.0, False, fixtureId + "_zenithar_negative")
    endIf
    LedgerRuntime.FlushBroadPantheonEvent()
    Float negativeEventDelta = LedgerRuntime.GetBroadPantheonScratch(poolId) - scratchBefore - positiveEventDelta
    PDV_Manager.Trace(1, "[PDV][PS-A4] pool=" + poolId + " strongestPositive=" + positiveEventDelta + " strongestNegative=" + negativeEventDelta + " scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId))
    return "Post-pipeline fan-out: strongest positive=" + positiveEventDelta + "; strongest negative=" + negativeEventDelta + "; final scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId)
EndFunction

String Function DebugPrimeBroadPantheonScratch(Int poolIndex, Float scratchValue)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    StorageUtil.SetFloatValue(None, LedgerRuntime.GetBroadPantheonScratchKey(poolId), scratchValue)
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonScratchDayKey(poolId))
    StorageUtil.SetStringValue(None, LedgerRuntime.GetBroadPantheonLastEventKey(poolId), "mcm_signed_cap_prime")
    PDV_Manager.Trace(1, "[PDV][PS-A5] staged pool=" + poolId + " scratch=" + scratchValue + "; wait through real dawn")
    return DebugGetBroadPantheonSummary(poolIndex) + " | Wait through real dawn; expected signed fold cap is 4.3."
EndFunction

String Function DebugRunBroadPantheonCatchupForPacing(Int poolIndex)
    ; PS-A11 uses this only after a real act has folded at a real dawn.  It
    ; drives the production catch-up routine through five days after that
    ; recorded gain without mutating Skyrim's clock or GameDaysPassed.
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    if LedgerRuntime.GetBroadPantheonStanding(poolId) <= 0.0
        return "PS-A11 needs standing from one real folded positive act first."
    endIf
    if LedgerRuntime.GetBroadPantheonScratch(poolId) != 0.0
        return "PS-A11 needs zero pending scratch. Fold or clear the pool first."
    endIf
    if LedgerRuntime.GetActiveBroadPantheonPoolId() == poolId
        return "PS-A11 needs this pool suppressed. Switch to another broad pool or focused worship first."
    endIf

    Int lastGainStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastGainDayKey(poolId))
    if lastGainStamp <= 0
        return "PS-A11 needs a recorded positive gain day from the real fold."
    endIf
    Int lastGainDay = lastGainStamp - 2
    Int targetDay = lastGainDay + 5
    Int processedStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastProcessedDayKey(poolId))
    Int lastProcessedDay = processedStamp - 2
    if targetDay <= lastProcessedDay
        return DebugGetBroadPantheonSummary(poolIndex) + " | PS-A11 target already processed; repeat is idempotent."
    endIf

    Float signedCap = LedgerRuntime.PIETY_DAILY_MAX_DELTA
    if LedgerRuntime.PDV_ModePresetRef
        signedCap = signedCap * LedgerRuntime.PDV_ModePresetRef.DailyCapScalar()
    endIf
    LedgerRuntime.ProcessBroadPantheonThroughDay(poolId, targetDay, signedCap, "mcm_ps_a11_catchup")
    LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    PDV_Manager.Trace(1, "[PDV][PS-A11] forced catch-up pool=" + poolId + " lastGainDay=" + lastGainDay + " through=" + targetDay + " standing=" + LedgerRuntime.GetBroadPantheonStanding(poolId))
    return DebugGetBroadPantheonSummary(poolIndex) + " | PS-A11 processed through gain day +5; expected two grace days then 0.1/day."
EndFunction

String Function DebugSetNordBaselineForPacing(Int baselineValue)
    DebugSetNordPantheonBaseline(baselineValue)
    return DebugGetBroadPantheonSummary(baselineValue + 1)
EndFunction

String Function DebugOfferAcceptRecoverySummary()
    String activeName = "none"
    if PDV_Manager.GetActiveDeity()
        activeName = PDV_Manager.GetActiveDeity().DeityName + " piety=" + LedgerRuntime.GetPiety(PDV_Manager.GetActiveDeity())
    endIf
    PDV_DeityBase pending = LedgerRuntime.GetPendingCommitmentDeity()
    String pendingName = "none"
    if pending
        pendingName = pending.DeityName
    endIf
    PDV_DeityBase candidate = pending
    if !candidate
        candidate = LedgerRuntime.GetPacingPatronCandidate()
    endIf
    Int qualifyingDays = 0
    Bool baselineEligible = False
    Float declinedAt = 0.0
    if candidate
        qualifyingDays = LedgerRuntime.GetRecentCommitmentSignalDayCount(candidate, 7)
        baselineEligible = LedgerRuntime.UsesFormalCommitmentOffersForDeity(candidate)
        declinedAt = StorageUtil.GetFloatValue(candidate as Form, "PDV.Commitment.DeclinedAt")
    endIf
    return "state=" + LedgerRuntime.GetPatronStateLabel() + " active=" + activeName + " pending=" + pendingName + " qualifyingDays=" + qualifyingDays + " baselineEligible=" + baselineEligible + " offeredAt=" + StorageUtil.GetFloatValue(None, "PDV.Commitment.OfferedAt") + " declinedAt=" + declinedAt
EndFunction

String Function DebugSetBroadWorshipForPacing()
    LedgerRuntime.ClearPendingCommitment()
    LedgerRuntime.SetBroadWorship()
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    PDV_Manager.Trace(1, "[PDV][BROAD_TEST] clean broad worship restored")
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugRunPatronOfferForPacing()
    PDV_DeityBase candidate = LedgerRuntime.GetPacingPatronCandidate()
    if !candidate
        return "Select Imperial or Nord broad worship before preparing an offer."
    endIf

    ; Deterministic clean-save setup: preserve all unrelated ledgers, return to
    ; broad worship, make one baseline-eligible candidate exactly qualified,
    ; clear its offer/cooldown state, and leave it pending for the separate
    ; Accept button. No message box races this controlled MCM sequence.
    LedgerRuntime.SetBroadWorship()
    LedgerRuntime.ClearPendingCommitment()
    Form candidateForm = candidate as Form
    StorageUtil.SetFloatValue(candidateForm, "PDV.Piety", LedgerRuntime.COMMITMENT_OFFER_THRESHOLD)
    StorageUtil.SetIntValue(candidateForm, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(candidateForm, "PDV.Commitment.Refused", 0)
    StorageUtil.SetFloatValue(candidateForm, "PDV.Commitment.DeclinedAt", 0.0)
    DebugSeedCommitmentSignalDaysByIndex(candidate.DeityIndex)
    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", candidate.DeityIndex)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", Utility.GetCurrentGameTime())
    LedgerRuntime.RecomputeTier(candidate)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugAcceptPatronForPacing()
    DebugAcceptPendingCommitment()
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugLapsePatronForPacing()
    if PDV_Manager.GetActiveDeity()
        StorageUtil.SetFloatValue(PDV_Manager.GetActiveDeity() as Form, "PDV.Piety", 49.0)
        LedgerRuntime.RecomputeTier(PDV_Manager.GetActiveDeity())
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        PDV_Manager.Prisma.RequestPanelRefresh()
    endIf
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugRecoverPatronForPacing()
    if PDV_Manager.GetActiveDeity()
        StorageUtil.SetFloatValue(PDV_Manager.GetActiveDeity() as Form, "PDV.Piety", 50.0)
        LedgerRuntime.RecomputeTier(PDV_Manager.GetActiveDeity())
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        PDV_Manager.Prisma.RequestPanelRefresh()
    endIf
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugSetImperialVampireForPacing(Bool vampireActive)
    if vampireActive
        DebugForceCurseVampire()
    else
        DebugForceCurseNone()
    endIf
    return DebugGetSubstratePacingSummary(PDV_Manager.ORIGIN_IMPERIAL)
EndFunction

Function DebugSetKhajiitFocus(Int focusValue)
    if focusValue < PDV_Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > PDV_Manager.KHAJIIT_FOCUS_ALKOSH
        return
    endIf

    PDV_Manager.BeginRaceSetupQuietPresentation("mcm_khajiit_focus")
    Int f = PDV_Manager.KHAJIIT_FOCUS_KHENARTHI
    while f <= PDV_Manager.KHAJIIT_FOCUS_ALKOSH
        StorageUtil.SetFloatValue(None, OriginRuntime.GetKhajiitFocusWeightKey(f), 0.0)
        f += 1
    endWhile

    StorageUtil.SetFloatValue(None, OriginRuntime.GetKhajiitFocusWeightKey(focusValue), PDV_Manager.KHAJIIT_FOCUS_THRESHOLD + PDV_Manager.KHAJIIT_FOCUS_LEAD_REQUIRED + 10.0)
    OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    OriginRuntime.SyncKhajiitRuntimeState()
    PDV_Manager.EndRaceSetupQuietPresentation()
    PDV_Manager.Trace(1, "Khajiit focus debug-set to " + OriginRuntime.GetKhajiitFocusLabel(focusValue))
EndFunction

Function DebugSetBretonTradition(Int traditionValue)
    if PDV_Manager.GetPlayerOriginRaceIndex() != PDV_Manager.ORIGIN_BRETON
        PDV_Manager.Trace(1, "Breton tradition debug-set ignored: set Breton origin first")
        return
    endIf

    Int normalized = PDV_DevotionRules.ClampInt(traditionValue, PDV_Manager.BRETON_TRADITION_KNIGHTS_ROAD, PDV_Manager.BRETON_TRADITION_GREEN_WAY)
    PDV_Manager.BeginRaceSetupQuietPresentation("mcm_breton_tradition")
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    if normalized == PDV_Manager.BRETON_TRADITION_GREEN_WAY
        OriginRuntime.SetBretonDruidicFork(PDV_Manager.BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_breton_tradition")
        if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0) < 50
            StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        endIf
    else
        OriginRuntime.SetBretonDruidicFork(PDV_Manager.BRETON_DRUIDIC_FORK_NONE, "mcm_breton_tradition")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    PDV_Manager.EndRaceSetupQuietPresentation()
    PDV_Manager.Trace(1, "Breton tradition debug-set to " + normalized)
EndFunction

Function DebugSeedBretonDruidicFrayTest()
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", PDV_Manager.BRETON_TRADITION_GREEN_WAY)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    OriginRuntime.SetBretonDruidicFork(PDV_Manager.BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_fray_test")
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 31)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicDecayDay", 0)
    PDV_Manager.Trace(1, "Breton Druidic fray test seeded: GreenWay/Druidic, standing=31")
EndFunction

Function DebugSetOrcLifeMode(Int modeValue)
    Int normalized = PDV_DevotionRules.ClampInt(modeValue, PDV_Manager.ORC_LIFE_MODE_CITY, PDV_Manager.ORC_LIFE_MODE_LEGION_EXILE)
    if PDV_Manager.PDV_OrcLifeModeTrack && PDV_Manager.PDV_OrcLifeModeTrack.GetCurrentState() != normalized
        PDV_Manager.PDV_OrcLifeModeTrack.SetState(normalized, "mcm_pattern")
    endIf
    PDV_Manager.Trace(1, "Orc life mode debug-set to " + normalized)
EndFunction

Function DebugSetArgonianFocus(Int focusValue)
    if focusValue == PDV_Manager.ARGONIAN_FOCUS_VOID
        DebugSeedArgonian(90.0, 0.0, 90.0)
    else
        DebugSeedArgonian(90.0, 90.0, 0.0)
    endIf
    PDV_Manager.Trace(1, "Argonian focus debug-set to " + focusValue)
EndFunction

Function DebugCycleContextualFavorLane()
    Int laneValue = FavorRuntime.GetSelectedContextualFavorLane() + 1
    if laneValue > FavorRuntime.FAVOR_LANE_ALTMER
        laneValue = FavorRuntime.FAVOR_LANE_KYNE
    endIf

    FavorRuntime.SetSelectedContextualFavorLane(laneValue)
EndFunction

Function DebugCycleContextualFavorFamily()
    Int laneValue = FavorRuntime.GetSelectedContextualFavorLane()
    Int nextFamily = FavorRuntime.GetNextFavorFamilyForLane(laneValue, FavorRuntime.GetSelectedContextualFavorFamily())
    StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", nextFamily)
EndFunction

Function DebugTriggerSelectedContextualFavor()
    FavorRuntime.TryActivateContextualFavor(FavorRuntime.GetSelectedContextualFavorLane(), FavorRuntime.GetSelectedContextualFavorFamily(), "mcm")
EndFunction

Function DebugExpireActiveFavor()
    FavorRuntime.ClearActiveFavor("mcm")
EndFunction

Function DebugPrimeRaceLaneNeglect()
    Int origin = PDV_Manager.GetPlayerOriginRaceIndex()
    ; Clamp to a tiny positive epsilon rather than letting this go <= 0.0 on any save whose
    ; clock hasn't reached day 10 yet -- every Is<Race>Neglected check guards lastSource <= 0.0
    ; as its "never set" sentinel, so a negative/zero backdate silently defeats the whole prime
    ; (bug found 2026-07-16: Redguard neglect never fired on an early save for exactly this reason).
    Float lapsed = Utility.GetCurrentGameTime() - 10.0
    if lapsed <= 0.0
        lapsed = 0.01
    endIf
    String laneLabel = ""
    if origin == PDV_Manager.ORIGIN_ALTMER
        StorageUtil.SetFloatValue(None, "PDV.Altmer.Favor.LastGameTime", lapsed)
        laneLabel = "Altmer coherence"
    elseIf origin == PDV_Manager.ORIGIN_REDGUARD
        StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", lapsed)
        laneLabel = "Redguard ancestor-distance"
    elseIf origin == PDV_Manager.ORIGIN_BRETON
        StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", lapsed)
        laneLabel = "Breton tradition"
    elseIf origin == PDV_Manager.ORIGIN_ORC
        StorageUtil.SetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime", lapsed)
        laneLabel = "Orc code"
    elseIf origin == PDV_Manager.ORIGIN_KHAJIIT
        StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", lapsed)
        laneLabel = "Khajiit lunar"
    else
        Debug.Notification("PDV: race-lane neglect prime not wired for this origin (Dunmer/Argonian/Imperial use curse/Hist/substrate).")
        return
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Debug.Notification("PDV: primed " + laneLabel + " neglect. Ensure Curse none, then check Active Effects.")
    PDV_Manager.Trace(1, "DebugPrimeRaceLaneNeglect: backdated " + laneLabel + " source and re-synced.")
EndFunction

Function DebugCycleKyneFavorMask()
    Int currentMask = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    currentMask += 1
    if currentMask > 7
        currentMask = 0
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ConditionMask", currentMask)
    FavorRuntime.SetSelectedContextualFavorLane(FavorRuntime.FAVOR_LANE_KYNE)
    DebugCycleContextualFavorFamily()
    FavorRuntime.UpdateContextualFavorRuntime()
EndFunction

Function DebugRecordHircineHuntRite()
    DaedricRuntime.HandleHircineHuntRite("mcm")
EndFunction

Function DebugResetHircinePath()
    if PDV_HircinePath
        PDV_HircinePath.ResetPilotForDebug()
    endIf

    if PDV_CurseStateService
        PDV_CurseStateService.ClearCurseState("hircine_reset")
    endIf

    StorageUtil.SetIntValue(None, "PDV.Curse.State", 0)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", 0.0)
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", "hircine_reset")
EndFunction

Function DebugRenounceHircinePath()
    if PDV_HircinePath
        PDV_HircinePath.RenouncePath("mcm")
        DaedricRuntime.DrainHircineRenunciationJournal()
        PDV_Manager.Prisma.RequestPanelRefresh()
    endIf
EndFunction

Function DebugForceCurseNone()
    DebugForceCurseState(0, "mcm_force_none")
EndFunction

Function DebugForceCurseWerewolf()
    DebugForceCurseState(1, "mcm_force_werewolf")
EndFunction

Function DebugForceCurseVampire()
    DebugForceCurseState(2, "mcm_force_vampire")
EndFunction

Function DebugForceCurseState(Int newState, String reason)
    if !PDV_CurseStateService
        return
    endIf

    Int oldState = PDV_CurseStateService.GetCurseState()
    PDV_CurseStateService.SetCurseState(newState, reason)
    Int appliedState = PDV_CurseStateService.GetCurseState()

    if oldState != appliedState
        LedgerRuntime.HandleCurseStateTransition(oldState, appliedState, reason)
    elseIf PDV_HircinePath
        PDV_HircinePath.UpdateResidueRecovery()
        DaedricRuntime.DrainHircineResiduePrismaToasts()
    endIf
EndFunction

Function DebugRefreshCurseFromPlayerState()
    LedgerRuntime.HandleCurseStateRefresh("mcm_refresh")
EndFunction

Bool Function DebugSetCurseProofOriginRace(Int originRace)
    if originRace < PDV_Manager.ORIGIN_NORD || originRace > PDV_Manager.ORIGIN_REDGUARD || !PDV_Manager.PDV_GLO_OriginRace || !PDV_CurseStateService
        return False
    endIf
    if PDV_CurseStateService.GetCurseState() != 0
        return False
    endIf

    PDV_Manager.PDV_GLO_OriginRace.SetValue(originRace as Float)
    ; The race just changed, so the bound adapter must change with it.
    PDV_Manager.ResolveOriginRuntime()
    if PDV_Manager.PDV_ImperialAncestorSubstrate
        PDV_Manager.PDV_ImperialAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_Manager.PDV_DunmerAncestorSubstrate
        PDV_Manager.PDV_DunmerAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_Manager.PDV_ArgonianHistSubstrate
        PDV_Manager.PDV_ArgonianHistSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_Manager.PDV_NordAncestorSubstrate
        PDV_Manager.PDV_NordAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_Manager.PDV_AltmerAncestorSubstrate
        PDV_Manager.PDV_AltmerAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_Manager.PDV_KhajiitLunarSubstrate
        PDV_Manager.PDV_KhajiitLunarSubstrate.RecomputeSubstrateTier()
    endIf
    LedgerRuntime.RefreshPatronMirrors()
    FavorRuntime.UpdateContextualFavorRuntime()
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    PDV_Manager.Prisma.RequestPanelRefresh()
    PDV_Manager.Trace(1, "Curse proof origin set to " + OriginRuntime.GetOriginRaceLabel(originRace) + " (" + originRace + ")")
    return True
EndFunction

Function DebugEvaluateCommitmentOffer()
    Int pendingBefore = LedgerRuntime.GetPendingCommitmentDeityIndex()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    PDV_Manager.Trace(1, "Commitment evaluate debug: pending " + pendingBefore + " -> " + pendingAfter + "; kyneDays=" + LedgerRuntime.GetRecentCommitmentSignalDayCount(PDV_Manager.PDV_Kyne, 7) + "; kynePiety=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.GetPiety(PDV_Manager.PDV_Kyne)))
EndFunction

Function DebugSeedCommitmentSignalDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugSeedCommitmentSignalDaysByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int encodedLatestDay = currentDay + 1
    Int encodedPreviousDay = currentDay
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", encodedLatestDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", encodedPreviousDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", currentDay)
    PDV_Manager.Trace(1, "Commitment seed debug: " + deity.DeityName + "[" + deity.DeityIndex + "] days=" + LedgerRuntime.GetRecentCommitmentSignalDayCount(deity, 7))
EndFunction

Function DebugSeedCommitmentSignalDaysForDeity(PDV_DeityBase deity)
    if !PDV_Manager.IsDebugDeityTargetEligible(deity, "DebugSeedCommitmentSignalDaysForDeity")
        return
    endIf
    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", currentDay + 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", currentDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", currentDay)
EndFunction

Function DebugResetCommitmentStateByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if deity
        Form deityForm = deity as Form
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Offered", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Refused", 0)
        if LedgerRuntime.GetPendingCommitmentDeityIndex() == deity.DeityIndex
            LedgerRuntime.ClearPendingCommitment()
        endIf
        PDV_Manager.Trace(1, "Commitment reset debug: " + deity.DeityName + "[" + deity.DeityIndex + "]")
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
EndFunction

Function DebugAcceptPendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    if !LedgerRuntime.IsPendingCommitmentStillAcceptable(pendingDeity)
        LedgerRuntime.ClearPendingCommitment()
        PDV_Manager.Trace(1, "Pending commitment invalidated before acceptance.")
        return
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)

    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 0)
    PDV_DaedricPathBase pendingPath = pendingDeity as PDV_DaedricPathBase
    if pendingPath
        ; A Prince pact: record consent (unblocks ClampPiety's Champion park) and make it
        ; the single active pact. A path is NOT a divine patron, so SetActiveDeity is not
        ; called for it.
        pendingPath.SetDaedricPactConsent(True)
        ; Commit PDV.Tier from current piety before activating the pact. The standing readers
        ; (GetActiveDaedricPactPath) ignore a pact whose tier is still 0, which left the Book
        ; of Days at Distant. The old auto-commit reached MakeActiveDaedricPact via
        ; RecomputeStoredTier; the direct consent call must do the same.
        pendingPath.RecomputeStoredTier("commitment_accept")
        pendingPath.MakeActiveDaedricPact()
        PDV_Manager.Prisma.RequestPanelRefresh()
    else
        LedgerRuntime.SetActiveDeity(pendingDeity)
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf
    PDV_Manager.Prisma.DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")
    PDV_Manager.Prisma.SendPrismaToast(PDV_Manager.Prisma.GetPrismaSymbolForDeity(pendingDeity), "good", LedgerRuntime.BuildCommitmentOfferAcceptToastLine(pendingDeity), "")
    LedgerRuntime.ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
    PDV_Manager.Trace(1, "Commitment accepted for " + pendingDeity.DeityName + ".")
EndFunction

Function DebugDeclinePendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Offered", 0)
    StorageUtil.SetFloatValue(pendingDeity as Form, "PDV.Commitment.DeclinedAt", Utility.GetCurrentGameTime())
    LedgerRuntime.ClearPendingCommitment()
    PDV_Manager.Trace(1, "Commitment declined/postponed.")
EndFunction

Function DebugRefusePendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    ; Owner ruling (Mega Packet Sitting 1 U8): formal-offer REFUSAL is visible as
    ; a refusal toast and pinned Book of Days chronicle, but it must not fire the
    ; diegetic director's screen wash or D1 sound. SurfaceTransition with
    ; silent=True writes and pins the chronicle while skipping that director cue.
    ; The ACCEPT path keeps its revelation toast + sound.
    PDV_Manager.Prisma.SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)
    PDV_Manager.Prisma.SendPrismaToast(PDV_Manager.Prisma.GetPrismaSymbolForDeity(pendingDeity), "warning", LedgerRuntime.BuildCommitmentOfferRefuseToastLine(pendingDeity), "")
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 1)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 1)
    LedgerRuntime.ClearPendingCommitment()
    PDV_Manager.Trace(1, "Commitment refused.")
EndFunction

Function DebugRunNeglectPass()
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
EndFunction

String Function DebugYesNo(Bool flag)
    if flag
        return "Y"
    endIf
    return "N"
EndFunction

Function DebugSeedSanguineOfferReadyCore()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return
    endIf
    sanguinePath.SetStoredPiety(LedgerRuntime.COMMITMENT_OFFER_THRESHOLD, "mcm_consent_seed")
    DebugSeedCommitmentSignalDaysForDeity(sanguinePath)
    Form sanguineForm = sanguinePath as Form
    StorageUtil.SetIntValue(sanguineForm, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(sanguineForm, "PDV.Commitment.Refused", 0)
    StorageUtil.SetFloatValue(sanguineForm, "PDV.Commitment.DeclinedAt", 0.0)
    LedgerRuntime.ClearPendingCommitment()
    sanguinePath.SetDaedricPactConsent(False)
    sanguinePath.ClearLiveDaedricPactSpells()
    StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
EndFunction

String Function DebugSanguineConsentReadback()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    Int schema = StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema")
    return "Sanguine piety=" + PDV_DevotionRules.FormatTwoDecimals(sanguinePath.GetStoredPiety()) + " tier=" + sanguinePath.GetStoredTier() + "; consent=" + DebugYesNo(sanguinePath.HasDaedricPactConsent()) + "; activePact=" + DebugYesNo(sanguinePath.IsActiveDaedricPact()) + "; consentSchema=" + schema + " (target " + PDV_Manager.DAEDRIC_CONSENT_SCHEMA_VERSION + ")"
EndFunction

String Function DebugSeedSanguineOfferReady()
    if !DaedricRuntime.GetDaedricPathByName("Sanguine")
        return "Sanguine path is not available."
    endIf
    DebugSeedSanguineOfferReadyCore()
    return "Seeded Sanguine offer-ready (no consent). " + DebugSanguineConsentReadback()
EndFunction

String Function DebugEvaluateConsentOfferReport()
    Int pendingBefore = LedgerRuntime.GetPendingCommitmentDeityIndex()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    if pendingAfter < 0
        return "Evaluate: no commitment offer fired (pending none). Patron state=" + LedgerRuntime.GetPatronStateLabel() + "."
    endIf
    PDV_DeityBase pendingDeity = LedgerRuntime.GetDeityByIndex(pendingAfter)
    String pendingName = "index " + pendingAfter
    if pendingDeity
        pendingName = pendingDeity.DeityName
    endIf
    return "Evaluate: offer pending for " + pendingName + " (was index " + pendingBefore + "). It replays as the 3-button pact message once the MCM closes."
EndFunction

String Function DebugConsentDivinePatronThenRaiseSanguine()
    if !LedgerRuntime.PDV_Akatosh
        return "PDV_Akatosh is not wired; cannot set a divine patron."
    endIf
    PDV_DeityBase previousPatron = PDV_Manager.GetActiveDeity()
    Int previousPatronState = LedgerRuntime.GetPatronState()
    if previousPatron && !LedgerRuntime.IsDeityReachableForCurrentOrigin(previousPatron)
        return "Unsafe consent fixture refused: the current patron is a grandfathered off-roster deity and cannot be restored through the ordinary setter."
    endIf
    if DaedricRuntime.GetActiveDaedricPactPath()
        return "Unsafe consent fixture refused: clear the active Daedric pact first so the fixture cannot sever player state it does not restore."
    endIf
    ; A divine patron must suppress the Daedric pact offer and survive the raise.
    LedgerRuntime.UnsafeFaultInjectActiveDeity(LedgerRuntime.PDV_Akatosh, "consent fixture: divine patron suppresses Sanguine offer")
    DebugSeedSanguineOfferReadyCore()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    String pendingLabel = "none"
    if pendingAfter >= 0
        PDV_DeityBase pendingDeity = LedgerRuntime.GetDeityByIndex(pendingAfter)
        if pendingDeity
            pendingLabel = pendingDeity.DeityName
        else
            pendingLabel = "index " + pendingAfter
        endIf
    endIf
    String patronLabel = "none"
    if PDV_Manager.GetActiveDeity()
        patronLabel = PDV_Manager.GetActiveDeity().DeityName
    endIf
    String result = "Divine patron=" + patronLabel + " (state " + LedgerRuntime.GetPatronStateLabel() + "); Sanguine raised to offer-ready; offer pending=" + pendingLabel + " (expect none -> suppressed)."
    LedgerRuntime.ClearUnsafeFaultInjection()
    if previousPatronState == LedgerRuntime.PATRON_STATE_ACTIVE && previousPatron
        LedgerRuntime.SetActiveDeity(previousPatron)
    elseIf previousPatronState == LedgerRuntime.PATRON_STATE_BROAD
        LedgerRuntime.SetBroadWorship()
    endIf
    return result + " Unsafe patron injection was cleared and the prior patron mode restored; the persistent unsafe marker still invalidates this run as gameplay proof."
EndFunction

String Function DebugFireSanguineAlcoholTwice()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    Float before = sanguinePath.GetStoredPiety()
    PDV_Manager.HandleKIDAction("sanguine_alcohol", None)
    Float afterFirst = sanguinePath.GetStoredPiety()
    PDV_Manager.HandleKIDAction("sanguine_alcohol", None)
    Float afterSecond = sanguinePath.GetStoredPiety()
    return "sanguine_alcohol x2: piety " + PDV_DevotionRules.FormatTwoDecimals(before) + " -> " + PDV_DevotionRules.FormatTwoDecimals(afterFirst) + " -> " + PDV_DevotionRules.FormatTwoDecimals(afterSecond) + " (2nd hit capped by once-per-day)."
EndFunction

String Function DebugForceUnconsentedPactThenMigrate()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    ; Reproduce the pre-consent defect: an ACTIVE pact with no recorded consent.
    sanguinePath.SetStoredPiety(LedgerRuntime.COMMITMENT_OFFER_THRESHOLD, "mcm_consent_unconsented")
    sanguinePath.SetDaedricPactConsent(False)
    sanguinePath.MakeActiveDaedricPact()
    sanguinePath.SetDaedricPactConsent(False)
    Float pietyBefore = sanguinePath.GetStoredPiety()
    Bool activeBefore = sanguinePath.IsActiveDaedricPact()
    ; Bump the consent schema back so the guarded migration re-runs against the state.
    StorageUtil.SetIntValue(None, "PDV.Daedric.ConsentSchema", 0)
    PDV_Manager.MigrateDaedricConsentIfNeeded()
    return "Un-consented pact forced (active=" + DebugYesNo(activeBefore) + ", piety " + PDV_DevotionRules.FormatTwoDecimals(pietyBefore) + "). After migrate: activePact=" + DebugYesNo(sanguinePath.IsActiveDaedricPact()) + " (expect N), piety=" + PDV_DevotionRules.FormatTwoDecimals(sanguinePath.GetStoredPiety()) + " (preserved), consentSchema=" + StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema") + "."
EndFunction

String Function DebugGetPatternProvingSummary()
    String summary = "Concordat=" + OriginRuntime.GetConcordatSummary()
    summary = summary + "; Bosmer=" + OriginRuntime.GetBosmerSummary()
    summary = summary + "; DunmerAncestor=" + OriginRuntime.GetDunmerAncestorSummary()
    summary = summary + "; KhajiitLunar=" + OriginRuntime.GetKhajiitLunarSummary()
    summary = summary + "; ArgonianHist=" + OriginRuntime.GetArgonianHistSummary()
    summary = summary + "; Altmer=" + OriginRuntime.GetAltmerSummary()
    summary = summary + "; Orc=" + OriginRuntime.GetOrcSummary()
    summary = summary + "; Redguard=" + OriginRuntime.GetRedguardSummary()
    summary = summary + "; Favor=" + FavorRuntime.GetContextualFavorSummary()
    summary = summary + "; Commitment=" + LedgerRuntime.GetCommitmentSummary()
    summary = summary + "; Neglect=" + LedgerRuntime.GetNeglectSummary()
    summary = summary + "; Hircine=" + DaedricRuntime.GetHircineSummary()
    summary = summary + "; Curse=" + OriginRuntime.GetCurseStateSummary()
    summary = summary + "; CurseHandlers=" + OriginRuntime.GetCurseHandlerSummary()
    return summary
EndFunction

String Function DebugGetPatternSummarySection(Int sectionIndex)
    if sectionIndex == 0
        return "Concordat: " + OriginRuntime.GetConcordatSummary()
    elseIf sectionIndex == 1
        return "Bosmer: " + OriginRuntime.GetBosmerSummary()
    elseIf sectionIndex == 2
        return "Dunmer ancestor: " + OriginRuntime.GetDunmerAncestorSummary()
    elseIf sectionIndex == 3
        return "Khajiit lunar: " + OriginRuntime.GetKhajiitLunarSummary()
    elseIf sectionIndex == 4
        return "Argonian Hist: " + OriginRuntime.GetArgonianHistSummary()
    elseIf sectionIndex == 5
        return "Altmer: " + OriginRuntime.GetAltmerSummary()
    elseIf sectionIndex == 6
        return "Orc: " + OriginRuntime.GetOrcSummary()
    elseIf sectionIndex == 7
        return "Redguard: " + OriginRuntime.GetRedguardSummary()
    elseIf sectionIndex == 8
        return "Favor: " + FavorRuntime.GetContextualFavorSummary()
    elseIf sectionIndex == 9
        return "Commitment: " + LedgerRuntime.GetCommitmentSummary()
    elseIf sectionIndex == 10
        return "Neglect: " + LedgerRuntime.GetNeglectSummary()
    elseIf sectionIndex == 11
        return "Hircine: " + DaedricRuntime.GetHircineSummary()
    elseIf sectionIndex == 12
        return "Curse: " + OriginRuntime.GetCurseStateSummary()
    elseIf sectionIndex == 13
        return "Curse handlers: " + OriginRuntime.GetCurseHandlerSummary()
    endIf

    return ""
EndFunction

Int Function DebugGetPatternSummarySectionCount()
    return 14
EndFunction

Int Function DebugGetPatternSummaryRaceSection(Int originRace)
    if originRace == PDV_Manager.ORIGIN_BOSMER
        return 1
    elseIf originRace == PDV_Manager.ORIGIN_DUNMER
        return 2
    elseIf originRace == PDV_Manager.ORIGIN_KHAJIIT
        return 3
    elseIf originRace == PDV_Manager.ORIGIN_ARGONIAN
        return 4
    elseIf originRace == PDV_Manager.ORIGIN_ALTMER
        return 5
    elseIf originRace == PDV_Manager.ORIGIN_ORC
        return 6
    elseIf originRace == PDV_Manager.ORIGIN_REDGUARD
        return 7
    endIf

    return -1
EndFunction

Int Function DebugGetConcordatRawValue()
    if !PDV_Manager.PDV_ConcordatStandingTrack
        return 0
    endIf

    return PDV_Manager.PDV_ConcordatStandingTrack.GetValue()
EndFunction

String Function DebugGetConcordatStateLabel()
    if !PDV_Manager.PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    return PDV_Manager.PDV_ConcordatStandingTrack.GetStateLabel()
EndFunction

String Function DebugGetConcordatPendingStateLabel()
    if !PDV_Manager.PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    return PDV_Manager.PDV_ConcordatStandingTrack.GetPendingStateLabel()
EndFunction

String Function DebugGetConcordatGateLabel()
    if !PDV_Manager.PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    if PDV_Manager.PDV_ConcordatStandingTrack.HasExtremeResetGate()
        return "Unlocked"
    endIf

    return "Locked"
EndFunction

String Function DebugGetDecaySummaryByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        return "missing deity " + deityIndex
    endIf

    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float lastEvent = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    Int lastDecayDay = StorageUtil.GetIntValue(deityForm, "PDV.LastDecayAppliedDay")
    Float multiplier = 1.0
    if LedgerRuntime.IsBroadWorshipActive()
        multiplier = LedgerRuntime.BROAD_WORSHIP_DECAY_MULTIPLIER
    endIf

    return "deity=" + deity.DeityName + ";state=" + LedgerRuntime.GetPatronStateLabel() + ";active=" + PDV_DevotionRules.BoolToInt(deity == PDV_Manager.GetActiveDeity()) + ";broad=" + PDV_DevotionRules.BoolToInt(LedgerRuntime.IsBroadWorshipActive()) + ";p=" + PDV_DevotionRules.FormatTwoDecimals(piety) + ";tier=" + LedgerRuntime.GetTier(deity) + ";lastEvent=" + PDV_DevotionRules.FormatTwoDecimals(lastEvent) + ";lastDecayDay=" + lastDecayDay + ";rate=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * OriginRuntime.GetCurseGainMultiplier(deity) * DaedricRuntime.GetDaedricStigmaGainMultiplier(deity)) + ";floor=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.GetDecayFloorForDeity(deity, piety))
EndFunction
