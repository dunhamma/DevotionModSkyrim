;/
    PDV_EventBus.psc
    PlayerDevotion - V3 Preflight event dispatch service
    -----------------------------------------------------------------------
    Dispatches validated action payloads to deity rubrics. Preflight routes
    the existing direct-player kill path through this bus as a canary while
    carrying non-scoring attribution payloads for later signal phases.
    -----------------------------------------------------------------------
/;

Scriptname PDV_EventBus extends Quest

PDV__ManagerQuest Property PDV_Manager Auto
PDV_EventTypes Property PDV_EventTypesService Auto
FormList Property PDV_FLST_AllDeities Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Function BeginLogicalDevotionalAct(String logicalEventId)
    if PDV_Manager
        PDV_Manager.BeginBroadPantheonEvent(logicalEventId)
    endIf
EndFunction

Bool Function JoinLogicalDevotionalAct(String logicalEventId)
    if PDV_Manager
        return PDV_Manager.JoinBroadPantheonEvent(logicalEventId)
    endIf
    return False
EndFunction

Function FlushLogicalDevotionalAct()
    if PDV_Manager
        PDV_Manager.FlushBroadPantheonEvent()
    endIf
EndFunction

Function RouteDunmerHonorableVictory(Form victimForm)
    if PDV_Manager
        PDV_Manager.HandleDunmerHonorableVictory(victimForm)
    endIf
EndFunction

Function RouteAction(Int eventType, Form actorRef, Form targetRef, String logicalEventId = "")
    RouteActionWithAttribution(eventType, GetDirectPlayerAttribution(), actorRef, targetRef, logicalEventId)
EndFunction

Function RouteConcordatPressure(Bool isCompliance)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteConcordatPressure skipped: PDV_Manager not assigned.")
        return
    endIf

    Int adjustment = -15
    Int eventType = 21
    if isCompliance
        adjustment = 15
        eventType = 20
    else
        ; Concordat defiance is the canonical "side with the Stormcloaks" act; source its
        ; magnitude from the graduated Imperial point table so spec tuning propagates here
        ; without editing the proven CW quest fragments (default stays -15 if unmapped).
        Int defianceTableValue = PDV_Manager.GetImperialConcordatPressureForAction("side_with_stormcloaks")
        if defianceTableValue != 0
            adjustment = defianceTableValue
        endIf
    endIf

    if eventTypes
        if isCompliance
            eventType = eventTypes.EVT_CONCORDAT_COMPLIANCE
        else
            eventType = eventTypes.EVT_CONCORDAT_DEFIANCE
        endIf
    endIf

    PDV_Manager.ApplyConcordatPressure(adjustment, "eventbus_" + eventType)
    Trace(2, "RouteConcordatPressure complete: " + eventType + " adjustment " + adjustment)
EndFunction

Function RouteAltmerAlignmentSignal(String actionKey, Form sourceForm, String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerAlignmentSignal skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleAltmerAlignmentSignal(actionKey, sourceForm, "eventbus_" + sourceId)
    Trace(2, "RouteAltmerAlignmentSignal complete: " + actionKey + " source " + sourceId)
EndFunction

Function RouteDunmerOutdoorGoodDaedraShrine(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteDunmerOutdoorGoodDaedraShrine skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleDunmerOutdoorGoodDaedraShrine("eventbus_" + sourceId)
    Trace(2, "RouteDunmerOutdoorGoodDaedraShrine complete: " + sourceId)
EndFunction

Function RouteShrinePrayer(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel, String sourceId)
    if !PDV_Manager
        Trace(1, "RouteShrinePrayer skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleShrinePrayer(primaryDeityName, secondaryDeityName, tertiaryDeityName, shrineLabel, "eventbus_" + sourceId)
    Trace(2, "RouteShrinePrayer complete: " + primaryDeityName + " / " + secondaryDeityName + " / " + tertiaryDeityName)
EndFunction

Function RouteSleepStop(Actor playerRef, Bool wasInterrupted, Bool hadSleepStartContext, Bool sleepStartedOutside)
    if !PDV_Manager
        Trace(1, "RouteSleepStop skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandlePlayerSleepStop(playerRef, wasInterrupted, hadSleepStartContext, sleepStartedOutside, "eventbus_sleep")
    PDV_Manager.HandleCurseStateRefresh("eventbus_sleep")
    Trace(2, "RouteSleepStop complete.")
EndFunction

Function RouteCurseStateRefresh(String reason)
    if !PDV_Manager
        Trace(1, "RouteCurseStateRefresh skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleCurseStateRefresh("eventbus_" + reason)
    Trace(2, "RouteCurseStateRefresh complete: " + reason)
EndFunction

Function RouteQuestReaction(Quest sourceQuest, Int stageValue, String logicalEventId = "")
    if !PDV_Manager
        Trace(1, "RouteQuestReaction skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.ApplyQuestReaction(sourceQuest, stageValue, logicalEventId)
    Trace(2, "RouteQuestReaction complete: stage " + stageValue)
EndFunction

Function RouteQuestReactionFaucet(String faucetKey, Form sourceForm)
    if !PDV_Manager
        Trace(1, "RouteQuestReactionFaucet skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.ApplyQuestReactionFaucet(faucetKey, sourceForm)
    Trace(2, "RouteQuestReactionFaucet complete: " + faucetKey)
EndFunction

Function RouteBardPerformance(Int qualityDelta, Bool receivedOvation, Form contextForm)
    if !PDV_Manager
        Trace(1, "RouteBardPerformance skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleBardPerformance(qualityDelta, receivedOvation, contextForm)
    Trace(2, "RouteBardPerformance complete: quality " + qualityDelta)
EndFunction

Function RouteGreenPactViolation()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteGreenPactViolation skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 32
    if eventTypes
        eventType = eventTypes.EVT_GREEN_PACT_VIOLATION
    endIf

    PDV_Manager.HandleGreenPactViolation("eventbus_" + eventType)
    Trace(2, "RouteGreenPactViolation complete: " + eventType)
EndFunction

Function RouteDunmerPortableShrinePrayer()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDunmerPortableShrinePrayer skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 30
    if eventTypes
        eventType = eventTypes.EVT_DUNMER_PORTABLE_SHRINE
    endIf

    PDV_Manager.HandleDunmerPortableShrinePrayer("eventbus_" + eventType)
    Trace(2, "RouteDunmerPortableShrinePrayer complete: " + eventType)
EndFunction

Function RouteDunmerPlayerHomeBonus()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDunmerPlayerHomeBonus skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 31
    if eventTypes
        eventType = eventTypes.EVT_DUNMER_HOME_BONUS
    endIf

    PDV_Manager.HandleDunmerPlayerHomeBonus("eventbus_" + eventType)
    Trace(2, "RouteDunmerPlayerHomeBonus complete: " + eventType)
EndFunction

Function RouteKhajiitMoonObservance(Int phaseIndex)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitMoonObservance skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 10
    if eventTypes
        eventType = eventTypes.EVT_SLEEP_MOON_OBSERVANCE
    endIf

    PDV_Manager.HandleKhajiitMoonObservance(phaseIndex, "eventbus_" + eventType)
    Trace(2, "RouteKhajiitMoonObservance complete: " + eventType + " phase " + phaseIndex)
EndFunction

Function RouteKhajiitRoadHome()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitRoadHome skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 33
    if eventTypes
        eventType = eventTypes.EVT_KHAJIIT_ROAD_HOME
    endIf

    PDV_Manager.HandleKhajiitRoadHome("eventbus_" + eventType)
    Trace(2, "RouteKhajiitRoadHome complete: " + eventType)
EndFunction

Function RouteKhajiitRoadHomeAnchor(Int anchorId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitRoadHomeAnchor skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 33
    if eventTypes
        eventType = eventTypes.EVT_KHAJIIT_ROAD_HOME
    endIf

    PDV_Manager.HandleKhajiitRoadHomeAnchor(anchorId, "eventbus_" + eventType)
    Trace(2, "RouteKhajiitRoadHomeAnchor complete: " + eventType + " anchor " + anchorId)
EndFunction

Function RouteKhajiitBaanDarRoadTrick(String asSourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitBaanDarRoadTrick skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 90
    if eventTypes
        eventType = eventTypes.EVT_KHAJIIT_BAANDAR_ROAD_TRICK
    endIf

    String reason = "eventbus_" + eventType
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitBaanDarRoadTrick(reason)
    Trace(2, "RouteKhajiitBaanDarRoadTrick complete: " + reason)
EndFunction

Function RouteKhajiitBaanDarReversal(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteKhajiitBaanDarReversal skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_khajiit_baandar_reversal"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitBaanDarReversal(reason)
    Trace(2, "RouteKhajiitBaanDarReversal complete: " + reason)
EndFunction

Function RouteKhajiitRajhinElegantTheft(String asSourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitRajhinElegantTheft skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 91
    if eventTypes
        eventType = eventTypes.EVT_KHAJIIT_RAJHIN_ELEGANT_THEFT
    endIf

    String reason = "eventbus_" + eventType
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitRajhinElegantTheft(reason)
    Trace(2, "RouteKhajiitRajhinElegantTheft complete: " + reason)
EndFunction

Function RouteKhajiitAlkoshDragonOrder(String asSourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteKhajiitAlkoshDragonOrder skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 92
    if eventTypes
        eventType = eventTypes.EVT_KHAJIIT_ALKOSH_DRAGON_ORDER
    endIf

    String reason = "eventbus_" + eventType
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitAlkoshDragonOrder(reason)
    Trace(2, "RouteKhajiitAlkoshDragonOrder complete: " + reason)
EndFunction

Function RouteKhajiitAlkoshNamedDragon(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteKhajiitAlkoshNamedDragon skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_khajiit_alkosh_named_dragon"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitAlkoshNamedDragon(reason)
    Trace(2, "RouteKhajiitAlkoshNamedDragon complete: " + reason)
EndFunction

Function RouteKhajiitAlkoshGenericDragon(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteKhajiitAlkoshGenericDragon skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_khajiit_alkosh_generic_dragon"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitAlkoshGenericDragon(reason)
    Trace(2, "RouteKhajiitAlkoshGenericDragon complete: " + reason)
EndFunction

Function RouteKhajiitAzurahDesecration()
    if !PDV_Manager
        Trace(1, "RouteKhajiitAzurahDesecration skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleKhajiitAzurahDesecration("eventbus_khajiit_azurah_desecration")
    Trace(2, "RouteKhajiitAzurahDesecration complete")
EndFunction

Function RouteKhajiitKhenarthiCaravanHarm()
    if !PDV_Manager
        Trace(1, "RouteKhajiitKhenarthiCaravanHarm skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleKhajiitKhenarthiCaravanHarm("eventbus_khajiit_khenarthi_caravan_harm")
    Trace(2, "RouteKhajiitKhenarthiCaravanHarm complete")
EndFunction

Function RouteKhajiitKhenarthiCaravanAid(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteKhajiitKhenarthiCaravanAid skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_khajiit_khenarthi_caravan_aid"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitKhenarthiCaravanAid(reason)
    Trace(2, "RouteKhajiitKhenarthiCaravanAid complete: " + reason)
EndFunction

Function RouteKhajiitRajhinLegendMade(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteKhajiitRajhinLegendMade skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_khajiit_rajhin_legend_made"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleKhajiitRajhinLegendMade(reason)
    Trace(2, "RouteKhajiitRajhinLegendMade complete: " + reason)
EndFunction

Function RouteMephalaWebWoven(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteMephalaWebWoven skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_mephala_web_woven"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleMephalaWebWoven(reason)
    Trace(2, "RouteMephalaWebWoven complete: " + reason)
EndFunction

Function RouteBoethiahHonorableDuel(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteBoethiahHonorableDuel skipped: PDV_Manager not assigned.")
        return
    endIf

    String reason = "eventbus_boethiah_honorable_duel"
    if asSourceId != ""
        reason = reason + "_" + asSourceId
    endIf

    PDV_Manager.HandleBoethiahHonorableDuel(reason)
    Trace(2, "RouteBoethiahHonorableDuel complete: " + reason)
EndFunction

Function RouteKhajiitRajhinBotchedTheft()
    if !PDV_Manager
        Trace(1, "RouteKhajiitRajhinBotchedTheft skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleKhajiitRajhinBotchedTheft("eventbus_khajiit_rajhin_botched_theft")
    Trace(2, "RouteKhajiitRajhinBotchedTheft complete")
EndFunction

Function RouteKhajiitAlkoshChaosAid()
    if !PDV_Manager
        Trace(1, "RouteKhajiitAlkoshChaosAid skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleKhajiitAlkoshChaosAid("eventbus_khajiit_alkosh_chaos_aid")
    Trace(2, "RouteKhajiitAlkoshChaosAid complete")
EndFunction

Function RoutePaarthurnaxKill(Form sourceForm)
    if !PDV_Manager
        Trace(1, "RoutePaarthurnaxKill skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandlePaarthurnaxKill(sourceForm, "eventbus_paarthurnax_kill")
    Trace(2, "RoutePaarthurnaxKill complete")
EndFunction

Function RoutePaarthurnaxSpare(Form sourceForm)
    if !PDV_Manager
        Trace(1, "RoutePaarthurnaxSpare skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandlePaarthurnaxSpare(sourceForm, "eventbus_paarthurnax_spare")
    Trace(2, "RoutePaarthurnaxSpare complete")
EndFunction

Function RouteKhajiitBaanDarBetrayal()
    if !PDV_Manager
        Trace(1, "RouteKhajiitBaanDarBetrayal skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleKhajiitBaanDarBetrayal("eventbus_khajiit_baandar_betrayal")
    Trace(2, "RouteKhajiitBaanDarBetrayal complete")
EndFunction

Function RouteKhajiitLunarSubstrate(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteKhajiitLunarSubstrate skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleKhajiitLunarSubstrate(sourceId)
    Trace(2, "RouteKhajiitLunarSubstrate complete: " + sourceId)
EndFunction

Function RouteKhajiitFocusedEmphasis(Int deityId, String sourceId)
    if deityId == 2
        if PDV_Manager
            PDV_Manager.HandleKhajiitFocusedSourceForFocus(2, "eventbus_p2_khajiit_focused_" + sourceId)
        else
            RouteKhajiitMoonObservance(0)
        endIf
    elseIf deityId == 1
        if !PDV_Manager
            Trace(1, "RouteKhajiitFocusedEmphasis skipped: PDV_Manager not assigned.")
            return
        endIf
        PDV_Manager.HandleKhajiitFocusedSourceForFocus(1, "eventbus_p2_khajiit_focused_" + sourceId)
    elseIf deityId == 3
        RouteKhajiitBaanDarRoadTrick(sourceId)
    elseIf deityId == 4
        RouteKhajiitRajhinElegantTheft(sourceId)
    elseIf deityId == 5
        RouteKhajiitAlkoshDragonOrder(sourceId)
    else
        if !PDV_Manager
            Trace(1, "RouteKhajiitFocusedEmphasis skipped: PDV_Manager not assigned.")
            return
        endIf
        PDV_Manager.HandleKhajiitFocusedSource("eventbus_p2_khajiit_focused_" + sourceId)
    endIf

    Trace(2, "RouteKhajiitFocusedEmphasis complete: " + deityId + " source " + sourceId)
EndFunction

Function RouteHircineHuntRite()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteHircineHuntRite skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 34
    if eventTypes
        eventType = eventTypes.EVT_HIRCINE_HUNT_RITE
    endIf

    PDV_Manager.HandleHircineHuntRite("eventbus_" + eventType)
    Trace(2, "RouteHircineHuntRite complete: " + eventType)
EndFunction

Function RouteTalosShrineDefiance()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteTalosShrineDefiance skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 35
    if eventTypes
        eventType = eventTypes.EVT_TALOS_SHRINE_DEFIANCE
    endIf

    PDV_Manager.HandleTalosShrineDefiance("eventbus_" + eventType)
    Trace(2, "RouteTalosShrineDefiance complete: " + eventType)
EndFunction

Function RouteAltmerLorkhanPressure(Int pressureTier, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteAltmerLorkhanPressure skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 50
    if eventTypes
        eventType = eventTypes.EVT_ALTMER_LORKHAN_PRESSURE
    endIf

    PDV_Manager.HandleAltmerLorkhanPressure(pressureTier, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteAltmerLorkhanPressure complete: " + eventType + " tier " + pressureTier)
EndFunction

Function RouteAltmerCrisisSource(Int crisisSource, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteAltmerCrisisSource skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 51
    if eventTypes
        eventType = eventTypes.EVT_ALTMER_CRISIS_SOURCE
    endIf

    PDV_Manager.HandleAltmerCrisisSource(crisisSource, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteAltmerCrisisSource complete: " + eventType + " source " + crisisSource)
EndFunction

Function RouteAltmerDawnSteadiness()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteAltmerDawnSteadiness skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 52
    if eventTypes
        eventType = eventTypes.EVT_ALTMER_DAWN_STEADINESS
    endIf

    PDV_Manager.HandleAltmerDawnSteadiness("eventbus_" + eventType)
    Trace(2, "RouteAltmerDawnSteadiness complete: " + eventType)
EndFunction

Function RouteAltmerOrthodoxCostlyEnforcement()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteAltmerOrthodoxCostlyEnforcement skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 53
    if eventTypes
        eventType = eventTypes.EVT_ALTMER_ORTHODOX_COST
    endIf

    PDV_Manager.HandleAltmerOrthodoxCostlyEnforcement("eventbus_" + eventType)
    Trace(2, "RouteAltmerOrthodoxCostlyEnforcement complete: " + eventType)
EndFunction

Function RouteAltmerAurielFoundation(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerAurielFoundation skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleAltmerDawnSteadiness("eventbus_p2_altmer_auriel_" + sourceId)
    Trace(2, "RouteAltmerAurielFoundation complete: " + sourceId)
EndFunction

Function RouteAltmerMagnusScholarship(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerMagnusScholarship skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleAltmerDawnSteadiness("eventbus_p2_altmer_magnus_" + sourceId)
    Trace(2, "RouteAltmerMagnusScholarship complete: " + sourceId)
EndFunction

Function RouteAltmerXarxesLineage(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerXarxesLineage skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleAltmerOrthodoxCostlyEnforcement("eventbus_p2_altmer_xarxes_" + sourceId)
    Trace(2, "RouteAltmerXarxesLineage complete: " + sourceId)
EndFunction

; P7 (2026-08-03). The reason prefix carries "trinimac" and deliberately NOT "xarxes" -- the manager's
; AwardAltmerOrthodoxSignal branches on that token, so a "xarxes" substring here would silently
; misroute the whole award to the wrong god.
Function RouteAltmerTrinimacOrthodoxy(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerTrinimacOrthodoxy skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleAltmerTrinimacOrthodoxy("eventbus_p2_altmer_trinimac_" + sourceId)
    Trace(2, "RouteAltmerTrinimacOrthodoxy complete: " + sourceId)
EndFunction

; --- P9 (2026-08-03): Syrabane's four wired signals ------------------------------------------
; The bus only forwards; the manager owns every origin, curse, band and cap gate.
Function RouteAltmerSyrabaneCureWard(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerSyrabaneCureWard skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleAltmerSyrabaneCureWard("eventbus_syrabane_cure_" + sourceId)
EndFunction

Function RouteAltmerSyrabaneProtectiveWard(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerSyrabaneProtectiveWard skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleAltmerSyrabaneProtectiveWard("eventbus_syrabane_ward_" + sourceId)
EndFunction

Function RouteAltmerSyrabaneAntiMageSurvival(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerSyrabaneAntiMageSurvival skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleAltmerSyrabaneAntiMageSurvival("eventbus_syrabane_antimage_" + sourceId)
EndFunction

Function RouteAltmerSyrabaneContainment(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteAltmerSyrabaneContainment skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleAltmerSyrabaneContainment("eventbus_p2_altmer_syrabane_" + sourceId)
EndFunction

Function RouteAltmerLorkhanPenalty(Int pressureTier, String sourceId)
    RouteAltmerLorkhanPressure(pressureTier, sourceId)
    Trace(2, "RouteAltmerLorkhanPenalty complete: " + sourceId)
EndFunction

Function RouteArgonianHistMaintenance()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteArgonianHistMaintenance skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 60
    if eventTypes
        eventType = eventTypes.EVT_ARGONIAN_HIST_MAINTENANCE
    endIf

    PDV_Manager.HandleArgonianHistMaintenance("eventbus_" + eventType)
    Trace(2, "RouteArgonianHistMaintenance complete: " + eventType)
EndFunction

Function RouteArgonianPeopleSupport()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteArgonianPeopleSupport skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 61
    if eventTypes
        eventType = eventTypes.EVT_ARGONIAN_PEOPLE_SUPPORT
    endIf

    PDV_Manager.HandleArgonianPeopleSupport("eventbus_" + eventType)
    Trace(2, "RouteArgonianPeopleSupport complete: " + eventType)
EndFunction

Function RouteArgonianVoidSignal()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteArgonianVoidSignal skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 62
    if eventTypes
        eventType = eventTypes.EVT_ARGONIAN_VOID_SIGNAL
    endIf

    PDV_Manager.HandleArgonianVoidSignal("eventbus_" + eventType)
    Trace(2, "RouteArgonianVoidSignal complete: " + eventType)
EndFunction

Function RouteArgonianBedOfChoice()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteArgonianBedOfChoice skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 63
    if eventTypes
        eventType = eventTypes.EVT_ARGONIAN_BED_OF_CHOICE
    endIf

    PDV_Manager.HandleArgonianBedOfChoiceReturn("eventbus_" + eventType)
    Trace(2, "RouteArgonianBedOfChoice complete: " + eventType)
EndFunction

Function RouteArgonianCommunity(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteArgonianCommunity skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleArgonianPeopleSupport("eventbus_p2_argonian_community_" + sourceId)
    Trace(2, "RouteArgonianCommunity complete: " + sourceId)
EndFunction

Function RouteArgonianSapVision()
    if !PDV_Manager
        Trace(1, "RouteArgonianSapVision skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleArgonianSapVision()
    Trace(2, "RouteArgonianSapVision complete.")
EndFunction

Function RouteArgonianHistMaintenanceSource(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteArgonianHistMaintenanceSource skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleArgonianHistMaintenance("eventbus_p2_argonian_hist_" + sourceId)
    Trace(2, "RouteArgonianHistMaintenanceSource complete: " + sourceId)
EndFunction

Function RouteArgonianSithisAcknowledgment(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteArgonianSithisAcknowledgment skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleArgonianVoidSignal("eventbus_p2_argonian_sithis_" + sourceId)
    Trace(2, "RouteArgonianSithisAcknowledgment complete: " + sourceId)
EndFunction

Function RouteOrcStrongholdForge()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcStrongholdForge skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 70
    if eventTypes
        eventType = eventTypes.EVT_ORC_STRONGHOLD_FORGE
    endIf

    PDV_Manager.HandleOrcStrongholdForge("eventbus_" + eventType)
    Trace(2, "RouteOrcStrongholdForge complete: " + eventType)
EndFunction

Function RouteOrcStrongholdPresence(Int holdId, String sourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcStrongholdPresence skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 70
    if eventTypes
        eventType = eventTypes.EVT_ORC_STRONGHOLD_FORGE
    endIf

    PDV_Manager.HandleOrcStrongholdPresence(holdId, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteOrcStrongholdPresence complete: " + holdId + " source " + sourceId)
EndFunction

Function RouteOrcBloodKinCrisis(String sourceId = "orc_cursed_tribe_resolved")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcBloodKinCrisis skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 70
    if eventTypes
        eventType = eventTypes.EVT_ORC_STRONGHOLD_FORGE
    endIf

    PDV_Manager.HandleOrcBloodKinCrisis("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteOrcBloodKinCrisis complete: " + sourceId)
EndFunction

Function RouteOrcCityDignity(String sourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcCityDignity skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 71
    if eventTypes
        eventType = eventTypes.EVT_ORC_CITY_DIGNITY
    endIf

    String reason = "eventbus_" + eventType
    if sourceId != ""
        reason = reason + "_" + sourceId
    endIf
    PDV_Manager.HandleOrcCityDignity(reason)
    Trace(2, "RouteOrcCityDignity complete: " + eventType)
EndFunction

Function RouteOrcLegionService(String sourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcLegionService skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 72
    if eventTypes
        eventType = eventTypes.EVT_ORC_LEGION_SERVICE
    endIf

    String reason = "eventbus_" + eventType
    if sourceId != ""
        reason = reason + "_" + sourceId
    endIf
    PDV_Manager.HandleOrcLegionService(reason)
    Trace(2, "RouteOrcLegionService complete: " + eventType)
EndFunction

Function RouteOrcSelfMadeCommunity(String sourceId = "")
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcSelfMadeCommunity skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 73
    if eventTypes
        eventType = eventTypes.EVT_ORC_SELF_MADE_COMMUNITY
    endIf

    String reason = "eventbus_" + eventType
    if sourceId != ""
        reason = reason + "_" + sourceId
    endIf
    PDV_Manager.HandleOrcSelfMadeCommunity(reason)
    Trace(2, "RouteOrcSelfMadeCommunity complete: " + eventType)
EndFunction

Function RouteOrcOathBreak(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcOathBreak skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 74
    if eventTypes
        eventType = eventTypes.EVT_ORC_OATH_BREAK
    endIf

    PDV_Manager.HandleOrcOathBreak("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteOrcOathBreak complete: " + sourceId)
EndFunction

Function RouteOrcFourHoldsVisit(Int holdId, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteOrcFourHoldsVisit skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 75
    if eventTypes
        eventType = eventTypes.EVT_ORC_FOUR_HOLDS_VISIT
    endIf

    PDV_Manager.HandleOrcFourHoldsVisit(holdId, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteOrcFourHoldsVisit complete: " + holdId + " source " + sourceId)
EndFunction

Function RouteOrcMalacathConduct(Int modeId, String sourceId)
    if !PDV_Manager
        Trace(1, "RouteOrcMalacathConduct skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleOrcMalacathConduct(modeId, "eventbus_p2_orc_malacath_" + sourceId)
    Trace(2, "RouteOrcMalacathConduct complete: mode " + modeId + " source " + sourceId)
EndFunction

Function RouteRedguardCrownTombRespect()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteRedguardCrownTombRespect skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 80
    if eventTypes
        eventType = eventTypes.EVT_REDGUARD_CROWN_TOMB_RESPECT
    endIf

    PDV_Manager.HandleRedguardCrownTombRespect("eventbus_" + eventType)
    Trace(2, "RouteRedguardCrownTombRespect complete: " + eventType)
EndFunction

Function RouteRedguardForebearRoadPassage()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteRedguardForebearRoadPassage skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 81
    if eventTypes
        eventType = eventTypes.EVT_REDGUARD_FOREBEAR_ROAD
    endIf

    PDV_Manager.HandleRedguardForebearRoadPassage("eventbus_" + eventType)
    Trace(2, "RouteRedguardForebearRoadPassage complete: " + eventType)
EndFunction

Function RouteRedguardAshAbahDeathDuty()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteRedguardAshAbahDeathDuty skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 82
    if eventTypes
        eventType = eventTypes.EVT_REDGUARD_ASHABAH_DEATH_DUTY
    endIf

    PDV_Manager.HandleRedguardAshAbahDeathDuty("eventbus_" + eventType)
    Trace(2, "RouteRedguardAshAbahDeathDuty complete: " + eventType)
EndFunction

Function RouteRedguardFarShoresToken()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteRedguardFarShoresToken skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 83
    if eventTypes
        eventType = eventTypes.EVT_REDGUARD_FAR_SHORES_TOKEN
    endIf

    PDV_Manager.HandleRedguardFarShoresToken("eventbus_" + eventType)
    Trace(2, "RouteRedguardFarShoresToken complete: " + eventType)
EndFunction

Function RouteRedguardAncestorSpine(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteRedguardAncestorSpine skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleRedguardAncestorSpine("eventbus_p2_redguard_spine_" + sourceId)
    Trace(2, "RouteRedguardAncestorSpine complete: " + sourceId)
EndFunction

Function RouteRedguardSectSignal(Int sectId, String sourceId)
    if sectId == 0
        RouteRedguardCrownTombRespect()
    elseIf sectId == 1
        RouteRedguardForebearRoadPassage()
    elseIf sectId == 2
        RouteRedguardAshAbahDeathDuty()
    else
        Trace(1, "RouteRedguardSectSignal skipped: unknown sect " + sectId)
    endIf

    Trace(2, "RouteRedguardSectSignal complete: " + sourceId)
EndFunction

Function RouteShoutAttack(Actor playerRef, Shout shoutUsed)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteShoutAttack skipped: PDV_Manager not assigned.")
        return
    endIf

    if !playerRef
        Trace(1, "RouteShoutAttack skipped: player ref missing.")
        return
    endIf

    Int eventType = 40
    if eventTypes
        eventType = eventTypes.EVT_SHOUT_ATTACK
    endIf

    PDV_Manager.HandleShoutAttack(eventType, playerRef, shoutUsed, "eventbus_" + eventType)
    Trace(2, "RouteShoutAttack complete: " + eventType)
EndFunction

Function RouteBosmerLivingStory()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerLivingStory skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 41
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_LIVING_STORY
    endIf

    PDV_Manager.HandleBosmerLivingStorySignal("eventbus_" + eventType)
    Trace(2, "RouteBosmerLivingStory complete: " + eventType)
EndFunction

Function RouteBosmerExchange()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerExchange skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 42
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_EXCHANGE
    endIf

    PDV_Manager.HandleBosmerExchangeSignal("eventbus_" + eventType)
    Trace(2, "RouteBosmerExchange complete: " + eventType)
EndFunction

Function RouteBosmerBanditRoad()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerBanditRoad skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 43
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_BANDIT_ROAD
    endIf

    PDV_Manager.HandleBosmerBanditRoadSignal("eventbus_" + eventType)
    Trace(2, "RouteBosmerBanditRoad complete: " + eventType)
EndFunction

Function RouteBosmerPactPositive()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerPactPositive skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 44
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_PACT_POSITIVE
    endIf

    PDV_Manager.HandleBosmerPactPositiveSignal("eventbus_" + eventType)
    Trace(2, "RouteBosmerPactPositive complete: " + eventType)
EndFunction

; Shared player below-health gate. The player-alias combat session detects the
; first drop below 20% health; the manager fans out to the race-specific payloads.
Function RoutePlayerBelowHealthGate(Actor playerRef)
    if !PDV_Manager
        Trace(1, "RoutePlayerBelowHealthGate skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandlePlayerBelowHealthGate(playerRef)
    Trace(2, "RoutePlayerBelowHealthGate complete.")
EndFunction

Function RoutePlayerBelowHealthSurvived(Actor playerRef)
    if !PDV_Manager
        Trace(1, "RoutePlayerBelowHealthSurvived skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandlePlayerBelowHealthSurvived(playerRef)
    Trace(2, "RoutePlayerBelowHealthSurvived complete.")
EndFunction

; Backward-compatible Bosmer Bandit Road wrapper. New callers should route through
; RoutePlayerBelowHealthGate so Orc and Argonian can share the same detection hook.
Function RouteBosmerBaanDarGap(Actor playerRef)
    if !PDV_Manager
        Trace(1, "RouteBosmerBaanDarGap skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandlePlayerBelowHealthGate(playerRef)
    Trace(2, "RouteBosmerBaanDarGap complete.")
EndFunction

Function RouteBosmerOldContractProperHunt()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerOldContractProperHunt skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 100
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_OLD_CONTRACT_PROPER_HUNT
    endIf

    PDV_Manager.HandleBosmerOldContractProperHunt("eventbus_" + eventType)
    Trace(2, "RouteBosmerOldContractProperHunt complete: " + eventType)
EndFunction

Function RouteBosmerOldContractForestKept()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerOldContractForestKept skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 101
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_OLD_CONTRACT_FOREST_KEPT
    endIf

    PDV_Manager.HandleBosmerOldContractForestKept("eventbus_" + eventType)
    Trace(2, "RouteBosmerOldContractForestKept complete: " + eventType)
EndFunction

Function RouteBosmerLivingStoryCommunityKept()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerLivingStoryCommunityKept skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 102
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_LIVING_STORY_COMMUNITY
    endIf

    PDV_Manager.HandleBosmerLivingStoryCommunityKept("eventbus_" + eventType)
    Trace(2, "RouteBosmerLivingStoryCommunityKept complete: " + eventType)
EndFunction

Function RouteBosmerLivingStoryNatureSite()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerLivingStoryNatureSite skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 103
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_LIVING_STORY_NATURE_SITE
    endIf

    PDV_Manager.HandleBosmerLivingStoryNatureSite("eventbus_" + eventType)
    Trace(2, "RouteBosmerLivingStoryNatureSite complete: " + eventType)
EndFunction

Function RouteBosmerExchangeDebtSettled()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerExchangeDebtSettled skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 104
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_EXCHANGE_DEBT_SETTLED
    endIf

    PDV_Manager.HandleBosmerExchangeDebtSettled("eventbus_" + eventType)
    Trace(2, "RouteBosmerExchangeDebtSettled complete: " + eventType)
EndFunction

Function RouteBosmerExchangeProportionateVengeance()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerExchangeProportionateVengeance skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 105
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_EXCHANGE_PROPORTIONATE_VENGEANCE
    endIf

    PDV_Manager.HandleBosmerExchangeProportionateVengeance("eventbus_" + eventType)
    Trace(2, "RouteBosmerExchangeProportionateVengeance complete: " + eventType)
EndFunction

Function RouteBosmerBanditRoadRoadLife()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerBanditRoadRoadLife skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 106
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_BANDIT_ROAD_ROAD_LIFE
    endIf

    PDV_Manager.HandleBosmerBanditRoadRoadLife("eventbus_" + eventType)
    Trace(2, "RouteBosmerBanditRoadRoadLife complete: " + eventType)
EndFunction

Function RouteBosmerBanditRoadReversal()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBosmerBanditRoadReversal skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 107
    if eventTypes
        eventType = eventTypes.EVT_BOSMER_BANDIT_ROAD_REVERSAL
    endIf

    PDV_Manager.HandleBosmerBanditRoadReversal("eventbus_" + eventType)
    Trace(2, "RouteBosmerBanditRoadReversal complete: " + eventType)
EndFunction

Function RouteBosmerYffre(Int pathState, String sourceId)
    if !PDV_Manager
        Trace(1, "RouteBosmerYffre skipped: PDV_Manager not assigned.")
        return
    endIf

    if pathState == 1
        PDV_Manager.HandleBosmerLivingStoryCommunityKept("eventbus_p2_bosmer_yffre_" + sourceId)
    else
        PDV_Manager.HandleBosmerPactPositiveSignal("eventbus_p2_bosmer_yffre_" + sourceId)
    endIf

    Trace(2, "RouteBosmerYffre complete: " + pathState + " source " + sourceId)
EndFunction

Function RouteBosmerZenExchange(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteBosmerZenExchange skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleBosmerExchangeSignal("eventbus_p2_bosmer_zen_" + sourceId)
    Trace(2, "RouteBosmerZenExchange complete: " + sourceId)
EndFunction

Function RouteBosmerBaanDarRoad(String sourceId)
    if !PDV_Manager
        Trace(1, "RouteBosmerBaanDarRoad skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleBosmerBanditRoadSignal("eventbus_p2_bosmer_baandar_" + sourceId)
    Trace(2, "RouteBosmerBaanDarRoad complete: " + sourceId)
EndFunction

Function RouteStateTransitionConfirmationRite()
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteStateTransitionConfirmationRite skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 45
    if eventTypes
        eventType = eventTypes.EVT_STATE_TRANSITION_CONFIRM_RITE
    endIf

    PDV_Manager.HandleStateTransitionConfirmationRite("eventbus_" + eventType)
    Trace(2, "RouteStateTransitionConfirmationRite complete: " + eventType)
EndFunction

Function RouteBretonTraditionChoice(Int traditionValue, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBretonTraditionChoice skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 120
    if eventTypes
        eventType = eventTypes.EVT_BRETON_TRADITION_CHOICE
    endIf

    PDV_Manager.HandleBretonTraditionChoice(traditionValue, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteBretonTraditionChoice complete: " + eventType + " tradition " + traditionValue)
EndFunction

Function RouteBretonKnightlyVow(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBretonKnightlyVow skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 121
    if eventTypes
        eventType = eventTypes.EVT_BRETON_KNIGHTLY_VOW
    endIf

    PDV_Manager.HandleBretonKnightlyVow("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteBretonKnightlyVow complete: " + eventType)
EndFunction

Function RouteBretonHiddenArtExposure(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBretonHiddenArtExposure skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 122
    if eventTypes
        eventType = eventTypes.EVT_BRETON_HIDDEN_ART_EXPOSURE
    endIf

    PDV_Manager.HandleBretonHiddenArtExposure("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteBretonHiddenArtExposure complete: " + eventType)
EndFunction

Function RouteBretonGreenWayStanding(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteBretonGreenWayStanding skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 123
    if eventTypes
        eventType = eventTypes.EVT_BRETON_GREEN_WAY_STANDING
    endIf

    PDV_Manager.HandleBretonGreenWayStanding("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteBretonGreenWayStanding complete: " + eventType)
EndFunction

Function RouteDunmerReclamationFocus(Int focusValue, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDunmerReclamationFocus skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 130
    if eventTypes
        eventType = eventTypes.EVT_DUNMER_RECLAMATION_FOCUS
    endIf

    PDV_Manager.HandleDunmerReclamationFocus(focusValue, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteDunmerReclamationFocus complete: " + eventType + " focus " + focusValue)
EndFunction

Function RouteDunmerDeviationPrice(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDunmerDeviationPrice skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 131
    if eventTypes
        eventType = eventTypes.EVT_DUNMER_DEVIATION_PRICE
    endIf

    PDV_Manager.HandleDunmerDeviationPrice("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteDunmerDeviationPrice complete: " + eventType)
EndFunction

Function RouteImperialCivicService(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteImperialCivicService skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 140
    if eventTypes
        eventType = eventTypes.EVT_IMPERIAL_CIVIC_SERVICE
    endIf

    PDV_Manager.HandleImperialCivicService("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteImperialCivicService complete: " + eventType)
EndFunction

Function RouteImperialTalosPressure(Bool isPrivate, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteImperialTalosPressure skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 141
    if eventTypes
        eventType = eventTypes.EVT_IMPERIAL_TALOS_PRESSURE
    endIf

    PDV_Manager.HandleImperialTalosPressure(isPrivate, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteImperialTalosPressure complete: " + eventType)
EndFunction

Function RouteImperialPatronCivicFavor(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteImperialPatronCivicFavor skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 142
    if eventTypes
        eventType = eventTypes.EVT_IMPERIAL_PATRON_CIVIC_FAVOR
    endIf

    PDV_Manager.HandleImperialPatronCivicFavor("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteImperialPatronCivicFavor complete: " + eventType)
EndFunction

Function RouteNordOldWaysState(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteNordOldWaysState skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 150
    if eventTypes
        eventType = eventTypes.EVT_NORD_OLD_WAYS_STATE
    endIf

    PDV_Manager.HandleNordOldWaysState("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteNordOldWaysState complete: " + eventType)
EndFunction

Function RouteNordKyneTalosContext(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteNordKyneTalosContext skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 151
    if eventTypes
        eventType = eventTypes.EVT_NORD_KYNE_TALOS_CONTEXT
    endIf

    PDV_Manager.HandleNordKyneTalosContext("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteNordKyneTalosContext complete: " + eventType)
EndFunction

Function RouteNordHircineArkayEdge(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteNordHircineArkayEdge skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 152
    if eventTypes
        eventType = eventTypes.EVT_NORD_HIRCINE_ARKAY_EDGE
    endIf

    PDV_Manager.HandleNordHircineArkayEdge("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteNordHircineArkayEdge complete: " + eventType)
EndFunction

Function RouteDaedricPrinceSignal(Int pathIndex, String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDaedricPrinceSignal skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 200
    if eventTypes
        eventType = eventTypes.EVT_DAEDRIC_PRINCE_SIGNAL
    endIf

    PDV_Manager.HandleDaedricPrinceSignal(pathIndex, "eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteDaedricPrinceSignal complete: " + eventType + " index " + pathIndex)
EndFunction

Function RouteDaedricShrinePrayer(Int pathIndex, String sourceId)
    if !PDV_Manager
        Trace(1, "RouteDaedricShrinePrayer skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.HandleDaedricShrinePrayer(pathIndex, "eventbus_" + sourceId)
    Trace(2, "RouteDaedricShrinePrayer complete: index " + pathIndex)
EndFunction

Function RouteDaedricGenericSilenceProbe(String sourceId)
    PDV_EventTypes eventTypes = GetEventTypes()
    if !PDV_Manager
        Trace(1, "RouteDaedricGenericSilenceProbe skipped: PDV_Manager not assigned.")
        return
    endIf

    Int eventType = 201
    if eventTypes
        eventType = eventTypes.EVT_DAEDRIC_GENERIC_SILENCE
    endIf

    PDV_Manager.HandleDaedricGenericSilenceProbe("eventbus_" + eventType + "_" + sourceId)
    Trace(2, "RouteDaedricGenericSilenceProbe complete: " + eventType)
EndFunction

Function RouteActionWithAttribution(Int eventType, Int attributionType, Form actorRef, Form targetRef, String logicalEventId = "")
    if eventType == GetNoneEvent()
        return
    endIf

    if !CanScoreAttribution(attributionType)
        Trace(2, "RouteAction skipped non-scoring attribution " + GetAttributionLabel(attributionType) + " for event " + eventType)
        return
    endIf

    if !PDV_Manager
        Trace(1, "RouteAction skipped: PDV_Manager not assigned.")
        return
    endIf

    if !PDV_FLST_AllDeities
        Trace(1, "RouteAction skipped: PDV_FLST_AllDeities not assigned.")
        return
    endIf

    PDV_Manager.HandleSubstrateActionEvent(eventType, GetEventReason(eventType))

    ; Quest-meta-faucet theft stamp (PDV_QuestExpansion_Architecture.md, 2026-07-05):
    ; Nocturnal's "done her way" lane compares this against the last watched-quest
    ; fulfillment. Player-attributed theft-family acts only (the attribution guard
    ; above already filtered); one StorageUtil write, no new events.
    if eventType == 360 || eventType == 361 || eventType == 362
        StorageUtil.SetFloatValue(None, "PDV.Meta.LastTheftTime", Utility.GetCurrentGameTime())
    endIf

    ; Rajhin legend-made: a single steal whose base take is >= 500 gold rises above
    ; the elegant-theft cadence (SIGNAL_LEGEND_MADE). The manager handler owns the
    ; Khajiit-origin gate and the daily cap; this is only the value gate.
    if eventType == 362 && targetRef && (targetRef.GetGoldValue() >= 500)
        PDV_Manager.HandleKhajiitRajhinLegendMade("eventbus_362_grand_theft")
    endIf

    ; P7 (2026-08-03): Trinimac's renewable civilization-defence beat. The bus only forwards -- the
    ; manager owns the Altmer-origin gate, the ThalmorAlignment >= 70 band gate, and the daily cap.
    if eventType == 2
        PDV_Manager.HandleAltmerTrinimacCivilizationDefense("eventbus_2_civilization_defense")
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    Int scoredCount = 0

    PDV_Manager.HandleBretonActionPracticeSignal(eventType, GetEventReason(eventType))
    PDV_Manager.BeginLikesDislikesSurface(eventType, logicalEventId)
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float delta = deity.ScoreAction(eventType, actorRef, targetRef)
            if delta != 0.0
                PDV_Manager.AwardPietyFromLikesDislikes(deity, delta, eventType, GetEventReason(eventType))
                scoredCount += 1

                if GetDebugLevel() >= 2
                    Debug.Trace("[PDV] EventBus: " + deity.DeityName + " event " + eventType + " delta " + delta)
                endIf
            endIf
        else
            Trace(2, "RouteAction skipped invalid deity entry at index " + i)
        endIf

        i += 1
    endWhile
    PDV_Manager.FlushLikesDislikesSurface(eventType)

    ; V2: also deepen any OPEN transgressive-Prince paths (separate fan-out; path's own piety).
    PDV_Manager.RouteActionToOpenPaths(eventType, actorRef, targetRef)

    Trace(2, "RouteAction complete: event " + eventType + ", scored deities " + scoredCount)
EndFunction

String Function GetEventReason(Int eventType)
    PDV_EventTypes eventTypes = GetEventTypes()
    if eventTypes
        String label = eventTypes.EventLabel(eventType)
        if label != "" && label != "none"
            return label
        endIf
    endIf

    return "event-" + eventType
EndFunction

Bool Function CanScoreAttribution(Int attributionType)
    PDV_EventTypes eventTypes = GetEventTypes()
    if eventTypes
        return eventTypes.CanScoreAttribution(attributionType)
    endIf

    return attributionType == 1
EndFunction

Int Function GetNoneEvent()
    PDV_EventTypes eventTypes = GetEventTypes()
    if eventTypes
        return eventTypes.EVT_NONE
    endIf

    return 0
EndFunction

Int Function GetDirectPlayerAttribution()
    PDV_EventTypes eventTypes = GetEventTypes()
    if eventTypes
        return eventTypes.ATTR_DIRECT_PLAYER
    endIf

    return 1
EndFunction

String Function GetAttributionLabel(Int attributionType)
    PDV_EventTypes eventTypes = GetEventTypes()
    if eventTypes
        return eventTypes.AttributionLabel(attributionType)
    endIf

    return "" + attributionType
EndFunction

PDV_EventTypes Function GetEventTypes()
    if PDV_EventTypesService
        return PDV_EventTypesService
    endIf

    return None
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function RouteNordTsunAdversity(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteNordTsunAdversity skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleNordTsunAdversitySurvived("eventbus_nord_tsun_adversity_" + asSourceId)
    Trace(2, "RouteNordTsunAdversity complete: " + asSourceId)
EndFunction

Function RouteRedguardLekiDuel(Form victimForm)
    if !PDV_Manager
        Trace(1, "RouteRedguardLekiDuel skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleLekiHonorableDuel("eventbus_redguard_leki_duel")
    Trace(2, "RouteRedguardLekiDuel complete.")
EndFunction

Function RouteTalosWorshipperRescued(String asSourceId = "")
    if !PDV_Manager
        Trace(1, "RouteTalosWorshipperRescued skipped: PDV_Manager not assigned.")
        return
    endIf
    PDV_Manager.HandleTalosWorshipperRescued("eventbus_talos_worshipper_rescued_" + asSourceId)
    Trace(2, "RouteTalosWorshipperRescued complete: " + asSourceId)
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] EventBus: " + traceText)
    endIf
EndFunction
