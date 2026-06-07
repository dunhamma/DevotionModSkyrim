;/ 
    PDV_PlayerEvents.psc
    PlayerDevotion - player alias event ingress
    -----------------------------------------------------------------------
    Player-attached alias script for low-noise runtime signal ingress.
    This stage wires sleep-based Khajiit moon observance through EventBus
    and leaves the rest of the future player-event surface compile-clean
    for CK alias attachment.
    -----------------------------------------------------------------------
/;

Scriptname PDV_PlayerEvents extends ReferenceAlias

PDV_EventBus Property PDV_EventBusService Auto
PDV_Origin Property PDV_OriginQuest Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

FormList Property PDV_FLST_P2_BretonKnightsRoadSources Auto
FormList Property PDV_FLST_P2_BretonHiddenArtSources Auto
FormList Property PDV_FLST_P2_BretonGreenWaySources Auto
FormList Property PDV_FLST_P2_BretonVowSources Auto
FormList Property PDV_FLST_P2_BretonHiddenArtSpells Auto
FormList Property PDV_FLST_P2_BretonGreenWayHarvests Auto
FormList Property PDV_FLST_P2_DunmerAzuraSources Auto
FormList Property PDV_FLST_P2_DunmerBoethiahSources Auto
FormList Property PDV_FLST_P2_DunmerMephalaSources Auto
FormList Property PDV_FLST_P2_DunmerDeviationSources Auto
FormList Property PDV_FLST_P2_ImperialCivicSources Auto
FormList Property PDV_FLST_P2_ImperialPublicServiceSources Auto
FormList Property PDV_FLST_P2_ImperialMercySources Auto
FormList Property PDV_FLST_P2_ImperialLawfulOrderSources Auto
FormList Property PDV_FLST_P2_ImperialHonestWorkSources Auto
FormList Property PDV_FLST_P2_ImperialDeathDutySources Auto
FormList Property PDV_FLST_P2_ImperialPrivateTalosSources Auto
FormList Property PDV_FLST_P2_ImperialPublicTalosSources Auto
FormList Property PDV_FLST_P2_ImperialPatronCivicSources Auto
FormList Property PDV_FLST_P2_NordOldWaysSources Auto
FormList Property PDV_FLST_P2_NordKyneTalosSources Auto
FormList Property PDV_FLST_P2_NordHircineArkaySources Auto
FormList Property PDV_FLST_P2_AltmerAurielSources Auto
FormList Property PDV_FLST_P2_AltmerMagnusSources Auto
FormList Property PDV_FLST_P2_AltmerXarxesSources Auto
FormList Property PDV_FLST_P2_AltmerLorkhanPenalties Auto
FormList Property PDV_FLST_P2_ArgonianHistSources Auto
FormList Property PDV_FLST_P2_ArgonianCommunitySources Auto
FormList Property PDV_FLST_P2_ArgonianSithisSources Auto
FormList Property PDV_FLST_P2_BosmerYffreSources Auto
FormList Property PDV_FLST_P2_BosmerZenSources Auto
FormList Property PDV_FLST_P2_BosmerBaanDarSources Auto
FormList Property PDV_FLST_P2_KhajiitLunarSources Auto
FormList Property PDV_FLST_P2_KhajiitFocusedSources Auto
FormList Property PDV_FLST_P2_OrcMalacathSources Auto
FormList Property PDV_FLST_P2_RedguardSpineSources Auto
FormList Property PDV_FLST_P2_RedguardCrownSources Auto
FormList Property PDV_FLST_P2_RedguardForebearSources Auto
FormList Property PDV_FLST_P2_RedguardAshAbahSources Auto
FormList Property PDV_FLST_GreenPact_PlantFoods Auto
FormList Property PDV_FLST_GreenPact_MeatFoods Auto
FormList Property PDV_FLST_GreenPact_FungiFoods Auto
FormList Property PDV_FLST_GreenPact_EggFoods Auto
FormList Property PDV_FLST_GreenPact_InsectFoods Auto
Keyword Property PDV_KW_GreenPact_Plant Auto
Keyword Property PDV_KW_GreenPact_Meat Auto
Keyword Property PDV_KW_GreenPact_Fungi Auto
Keyword Property PDV_KW_GreenPact_Egg Auto
Keyword Property PDV_KW_GreenPact_Insect Auto

String Property MOD_EVENT_CONCORDAT_COMPLIANCE = "PDV.ConcordatCompliance" AutoReadOnly
String Property MOD_EVENT_CONCORDAT_DEFIANCE = "PDV.ConcordatDefiance" AutoReadOnly

Event OnInit()
    RegisterForPlayerEvents()
    QueueOriginInitialization()
    RouteCurseRefresh("alias_init")
    Trace(2, "Player alias initialized.")
EndEvent

Event OnPlayerLoadGame()
    RegisterForPlayerEvents()
    QueueOriginInitialization()
    RouteCurseRefresh("load")
    Trace(2, "Player load observed; sleep hooks refreshed.")
EndEvent

Event OnUpdate()
    if GetOriginRaceValue() >= 0
        return
    endIf

    if !IsOriginCaptureSafe()
        RegisterForSingleUpdate(2.0)
        Trace(2, "Origin capture waiting for playable controls.")
        return
    endIf

    EnsureOriginInitialized()

    if GetOriginRaceValue() < 0
        RegisterForSingleUpdate(2.0)
        Trace(2, "Origin still unresolved; retry queued.")
    else
        Trace(2, "Origin initialization completed.")
    endIf
EndEvent

Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
    Trace(3, "Player sleep start observed.")
EndEvent

Event OnSleepStop(Bool abInterrupted)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "Player sleep stop skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteSleepStop(GetActorRef(), abInterrupted)
EndEvent

Event OnLycanthropyStateChanged(Bool abIsWerewolf)
    if abIsWerewolf
        RouteCurseRefresh("lycanthropy_on")
    else
        RouteCurseRefresh("lycanthropy_off")
    endIf
EndEvent

Event OnVampirismStateChanged(Bool abIsVampire)
    if abIsVampire
        RouteCurseRefresh("vampirism_on")
    else
        RouteCurseRefresh("vampirism_off")
    endIf
EndEvent

Event OnShoutAttack(Shout akShout)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "Shout attack skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteShoutAttack(GetActorRef(), akShout)
EndEvent

Event OnBookRead(Book akBook)
    RouteP2ImmersiveSource(akBook as Form, "po3_book")
EndEvent

Event OnSpellLearned(Spell akSpell)
    RouteP2ImmersiveSource(akSpell as Form, "po3_spell")
EndEvent

Event OnItemHarvested(Form akProduce)
    RouteP2ImmersiveSource(akProduce, "po3_harvest")
EndEvent

Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)
    RouteP2ImmersiveSource(akNewWeather as Form, "po3_weather")
EndEvent

Event OnQuestStageChange(Quest akQuest, Int aiNewStage)
    RouteP2ImmersiveQuestStage(akQuest, aiNewStage)
EndEvent

Event OnPDVConcordatCompliance(String eventName, String strArg, Float numArg, Form sender)
    if !PDV_EventBusService
        Trace(1, "Concordat compliance mod event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteConcordatPressure(true)
    Trace(2, "Concordat compliance mod event routed.")
EndEvent

Event OnPDVConcordatDefiance(String eventName, String strArg, Float numArg, Form sender)
    if !PDV_EventBusService
        Trace(1, "Concordat defiance mod event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteConcordatPressure(false)
    Trace(2, "Concordat defiance mod event routed.")
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    RouteBosmerGreenPactFood(akBaseObject)
EndEvent

Function RouteBosmerGreenPactFood(Form baseObject)
    if !baseObject || !PDV_EventBusService
        return
    endIf

    if GetOriginRaceValue() != 4
        return
    endIf

    Potion foodItem = baseObject as Potion
    if !foodItem || !foodItem.IsFood()
        return
    endIf

    if FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_PlantFoods, PDV_KW_GreenPact_Plant)
        PDV_EventBusService.RouteGreenPactViolation()
        Trace(2, "Green Pact plant food violation routed.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_MeatFoods, PDV_KW_GreenPact_Meat)
        PDV_EventBusService.RouteBosmerPactPositive()
        Trace(2, "Green Pact meat food positive routed.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_FungiFoods, PDV_KW_GreenPact_Fungi)
        Trace(3, "Green Pact fungi food ignored.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_EggFoods, PDV_KW_GreenPact_Egg)
        Trace(3, "Green Pact egg food ignored.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_InsectFoods, PDV_KW_GreenPact_Insect)
        PDV_EventBusService.RouteBosmerPactPositive()
        Trace(2, "Green Pact insect food positive routed.")
    endIf
EndFunction

Bool Function FormMatchesListOrKeyword(Form baseObject, FormList listRef, Keyword keywordRef)
    if listRef && listRef.HasForm(baseObject)
        return true
    endIf

    if keywordRef && baseObject.HasKeyword(keywordRef)
        return true
    endIf

    return false
EndFunction

Event OnMenuClose(String menuName)
    if menuName == "RaceSex Menu"
        QueueOriginInitialization()
        Trace(2, "RaceSex menu closed; origin retry queued.")
    endIf
EndEvent

Function RegisterForPlayerEvents()
    RegisterForSleep()
    RegisterForMenu("RaceSex Menu")
    RegisterForShoutSignals()
    RegisterForCivilWarSignals()
    RegisterForP2ImmersiveSignals()
EndFunction

Function RegisterForShoutSignals()
    PO3_Events_Alias.RegisterForShoutAttack(Self)
    Trace(2, "Shout hooks refreshed.")
EndFunction

Function RegisterForCivilWarSignals()
    UnregisterForModEvent(MOD_EVENT_CONCORDAT_COMPLIANCE)
    UnregisterForModEvent(MOD_EVENT_CONCORDAT_DEFIANCE)
    RegisterForModEvent(MOD_EVENT_CONCORDAT_COMPLIANCE, "OnPDVConcordatCompliance")
    RegisterForModEvent(MOD_EVENT_CONCORDAT_DEFIANCE, "OnPDVConcordatDefiance")
    Trace(2, "Civil War mod-event hooks refreshed.")
EndFunction

Function RegisterForP2ImmersiveSignals()
    PO3_Events_Alias.RegisterForBookRead(Self)
    PO3_Events_Alias.RegisterForSpellLearned(Self)
    PO3_Events_Alias.RegisterForItemHarvested(Self)
    PO3_Events_Alias.RegisterForWeatherChange(Self)
    RegisterQuestStageList(PDV_FLST_P2_BretonKnightsRoadSources)
    RegisterQuestStageList(PDV_FLST_P2_BretonHiddenArtSources)
    RegisterQuestStageList(PDV_FLST_P2_BretonGreenWaySources)
    RegisterQuestStageList(PDV_FLST_P2_BretonVowSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerAzuraSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerBoethiahSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerMephalaSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerDeviationSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialCivicSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPrivateTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPublicTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPatronCivicSources)
    RegisterQuestStageList(PDV_FLST_P2_NordOldWaysSources)
    RegisterQuestStageList(PDV_FLST_P2_NordKyneTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_NordHircineArkaySources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerAurielSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerMagnusSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerXarxesSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerLorkhanPenalties)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianHistSources)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianCommunitySources)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianSithisSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerYffreSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerZenSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerBaanDarSources)
    RegisterQuestStageList(PDV_FLST_P2_KhajiitLunarSources)
    RegisterQuestStageList(PDV_FLST_P2_KhajiitFocusedSources)
    RegisterQuestStageList(PDV_FLST_P2_OrcMalacathSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardSpineSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardCrownSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardForebearSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardAshAbahSources)
    Trace(2, "P2 immersive PO3 hooks refreshed.")
EndFunction

Function RegisterQuestStageList(FormList sourceList)
    if !sourceList
        return
    endIf

    Int sourceIndex = 0
    Int sourceCount = sourceList.GetSize()
    while sourceIndex < sourceCount
        Quest sourceQuest = sourceList.GetAt(sourceIndex) as Quest
        if sourceQuest
            PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
        endIf
        sourceIndex += 1
    endWhile
EndFunction

Function RouteP2ImmersiveSource(Form sourceForm, String sourceKind)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "P2 immersive source skipped: PDV_EventBusService not assigned.")
        return
    endIf

    if !sourceForm
        Trace(2, "P2 immersive source skipped: no source form.")
        return
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_BretonKnightsRoadSources, sourceForm, "breton_knights_road", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(0, sourceKind + "_breton_knights_road")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonHiddenArtSources, sourceForm, "breton_hidden_art", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(1, sourceKind + "_breton_hidden_art")
        PDV_EventBusService.RouteBretonHiddenArtExposure(sourceKind + "_breton_hidden_art")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonGreenWaySources, sourceForm, "breton_green_way", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(2, sourceKind + "_breton_green_way")
        PDV_EventBusService.RouteBretonGreenWayStanding(sourceKind + "_breton_green_way")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonVowSources, sourceForm, "breton_vow", sourceKind)
        PDV_EventBusService.RouteBretonKnightlyVow(sourceKind + "_breton_vow")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonHiddenArtSpells, sourceForm, "breton_hidden_art_spell", sourceKind)
        PDV_EventBusService.RouteBretonHiddenArtExposure(sourceKind + "_breton_hidden_art_spell")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonGreenWayHarvests, sourceForm, "breton_green_way_harvest", sourceKind)
        PDV_EventBusService.RouteBretonGreenWayStanding(sourceKind + "_breton_green_way_harvest")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_DunmerAzuraSources, sourceForm, "dunmer_azura", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(0, sourceKind + "_dunmer_azura")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerBoethiahSources, sourceForm, "dunmer_boethiah", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(1, sourceKind + "_dunmer_boethiah")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerMephalaSources, sourceForm, "dunmer_mephala", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(2, sourceKind + "_dunmer_mephala")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerDeviationSources, sourceForm, "dunmer_deviation", sourceKind)
        PDV_EventBusService.RouteDunmerDeviationPrice(sourceKind + "_dunmer_deviation")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_ImperialCivicSources, sourceForm, "imperial_civic", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_civic_public_service")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPublicServiceSources, sourceForm, "imperial_public_service", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_public_service")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialMercySources, sourceForm, "imperial_mercy", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_mercy")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialLawfulOrderSources, sourceForm, "imperial_lawful_order", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_lawful_order")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialHonestWorkSources, sourceForm, "imperial_honest_work", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_honest_work")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialDeathDutySources, sourceForm, "imperial_death_duty", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_death_duty")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPrivateTalosSources, sourceForm, "imperial_private_talos", sourceKind)
        PDV_EventBusService.RouteImperialTalosPressure(true, sourceKind + "_imperial_private_talos")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPublicTalosSources, sourceForm, "imperial_public_talos", sourceKind)
        PDV_EventBusService.RouteImperialTalosPressure(false, sourceKind + "_imperial_public_talos")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPatronCivicSources, sourceForm, "imperial_patron_civic", sourceKind)
        PDV_EventBusService.RouteImperialPatronCivicFavor(sourceKind + "_imperial_patron_civic")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_NordOldWaysSources, sourceForm, "nord_old_ways", sourceKind)
        PDV_EventBusService.RouteNordOldWaysState(sourceKind + "_nord_old_ways_ancestor")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_NordKyneTalosSources, sourceForm, "nord_kyne_talos", sourceKind)
        PDV_EventBusService.RouteNordKyneTalosContext(sourceKind + "_nord_kyne_talos_sky_road")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_NordHircineArkaySources, sourceForm, "nord_hircine_arkay", sourceKind)
        PDV_EventBusService.RouteNordHircineArkayEdge(sourceKind + "_nord_hircine_arkay_arkay")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_AltmerAurielSources, sourceForm, "altmer_auriel", sourceKind)
        PDV_EventBusService.RouteAltmerAurielFoundation(sourceKind + "_altmer_auriel")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerMagnusSources, sourceForm, "altmer_magnus", sourceKind)
        PDV_EventBusService.RouteAltmerMagnusScholarship(sourceKind + "_altmer_magnus")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerXarxesSources, sourceForm, "altmer_xarxes", sourceKind)
        PDV_EventBusService.RouteAltmerXarxesLineage(sourceKind + "_altmer_xarxes")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerLorkhanPenalties, sourceForm, "altmer_lorkhan_penalty", sourceKind)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(4, sourceKind + "_altmer_lorkhan_penalty")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianHistSources, sourceForm, "argonian_hist", sourceKind)
        PDV_EventBusService.RouteArgonianHistMaintenanceSource(sourceKind + "_argonian_hist")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianCommunitySources, sourceForm, "argonian_community", sourceKind)
        PDV_EventBusService.RouteArgonianCommunity(sourceKind + "_argonian_community")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianSithisSources, sourceForm, "argonian_sithis", sourceKind)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment(sourceKind + "_argonian_sithis")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_BosmerYffreSources, sourceForm, "bosmer_yffre", sourceKind)
        PDV_EventBusService.RouteBosmerYffre(0, sourceKind + "_bosmer_yffre")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BosmerZenSources, sourceForm, "bosmer_zen", sourceKind)
        PDV_EventBusService.RouteBosmerZenExchange(sourceKind + "_bosmer_zen")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BosmerBaanDarSources, sourceForm, "bosmer_baandar", sourceKind)
        PDV_EventBusService.RouteBosmerBaanDarRoad(sourceKind + "_bosmer_baandar")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_KhajiitLunarSources, sourceForm, "khajiit_lunar", sourceKind)
        PDV_EventBusService.RouteKhajiitLunarSubstrate(sourceKind + "_khajiit_lunar")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_KhajiitFocusedSources, sourceForm, "khajiit_focused", sourceKind)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(0, sourceKind + "_khajiit_focused")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_OrcMalacathSources, sourceForm, "orc_malacath", sourceKind)
        PDV_EventBusService.RouteOrcMalacathConduct(0, sourceKind + "_orc_malacath")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_RedguardSpineSources, sourceForm, "redguard_spine", sourceKind)
        PDV_EventBusService.RouteRedguardAncestorSpine(sourceKind + "_redguard_spine")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardCrownSources, sourceForm, "redguard_crown", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(0, sourceKind + "_redguard_crown")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardForebearSources, sourceForm, "redguard_forebear", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(1, sourceKind + "_redguard_forebear")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardAshAbahSources, sourceForm, "redguard_ashabah", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(2, sourceKind + "_redguard_ashabah")
    endIf
EndFunction

Function RouteP2ImmersiveQuestStage(Quest sourceQuest, Int newStage)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "P2 immersive quest stage skipped: PDV_EventBusService not assigned.")
        return
    endIf

    if !sourceQuest
        Trace(2, "P2 immersive quest stage skipped: no source quest.")
        return
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordOldWaysSources, sourceQuest, 155916, 160, "nord_mq104_old_ways", newStage)
        PDV_EventBusService.RouteNordOldWaysState("po3_queststage_nord_mq104_old_ordeal")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordOldWaysSources, sourceQuest, 290545, 200, "nord_mq304_old_ways", newStage)
        PDV_EventBusService.RouteNordOldWaysState("po3_queststage_nord_mq304_old_ancestor")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordKyneTalosSources, sourceQuest, 148154, 160, "nord_mq105_kyne_talos", newStage)
        PDV_EventBusService.RouteNordKyneTalosContext("po3_queststage_nord_mq105_sky_road")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 118516, 200, "nord_c03_hircine_arkay", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_c03_hircine")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 118518, 200, "nord_c06_hircine_arkay", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_c06_hircine")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 173210, 100, "nord_da05_hircine_hunt", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_da05_kill_hircine")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 173210, 105, "nord_da05_arkay_mercy", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_da05_mercy_arkay")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerAzuraSources, sourceQuest, 166614, 100, "dunmer_da01_azura", newStage)
        PDV_EventBusService.RouteDunmerReclamationFocus(0, "po3_queststage_dunmer_da01_azura")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerDeviationSources, sourceQuest, 166614, 110, "dunmer_da01_black_star", newStage)
        PDV_EventBusService.RouteDunmerDeviationPrice("po3_queststage_dunmer_da01_black_star")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerBoethiahSources, sourceQuest, 317654, 100, "dunmer_da02_boethiah", newStage)
        PDV_EventBusService.RouteDunmerReclamationFocus(1, "po3_queststage_dunmer_da02")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerMagnusSources, sourceQuest, 127576, 200, "altmer_mg08_magnus", newStage)
        PDV_EventBusService.RouteAltmerMagnusScholarship("po3_queststage_altmer_mg08")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 155916, 160, "altmer_mq104_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(2, "po3_queststage_altmer_mq104")
        PDV_EventBusService.RouteAltmerCrisisSource(1, "po3_queststage_altmer_mq104")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 290545, 200, "altmer_mq304_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(1, "po3_queststage_altmer_mq304")
        PDV_EventBusService.RouteAltmerCrisisSource(2, "po3_queststage_altmer_mq304")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 118516, 200, "altmer_c03_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(2, "po3_queststage_altmer_c03")
        PDV_EventBusService.RouteAltmerCrisisSource(4, "po3_queststage_altmer_c03")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_ArgonianSithisSources, sourceQuest, 125520, 200, "argonian_db01_sithis", newStage)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment("po3_queststage_argonian_db01")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ArgonianSithisSources, sourceQuest, 125529, 200, "argonian_db11_sithis", newStage)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment("po3_queststage_argonian_db11")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 173210, 100, "bosmer_da05_yffre_hunt", newStage)
        PDV_EventBusService.RouteBosmerYffre(0, "po3_queststage_bosmer_da05_kill")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 173210, 105, "bosmer_da05_yffre_mercy", newStage)
        PDV_EventBusService.RouteBosmerYffre(1, "po3_queststage_bosmer_da05_mercy")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 127576, 200, "bosmer_mg08_living_story", newStage)
        PDV_EventBusService.RouteBosmerYffre(1, "po3_queststage_bosmer_mg08")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitFocusedSources, sourceQuest, 155916, 160, "khajiit_mq104_alkosh", newStage)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(5, "po3_queststage_khajiit_mq104")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitFocusedSources, sourceQuest, 166614, 100, "khajiit_da01_azurah", newStage)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(2, "po3_queststage_khajiit_da01")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_OrcMalacathSources, sourceQuest, 243329, 200, "orc_da06_malacath", newStage)
        PDV_EventBusService.RouteOrcMalacathConduct(1, "po3_queststage_orc_da06")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_RedguardCrownSources, sourceQuest, 118565, 201, "redguard_ms08_crown", newStage)
        PDV_EventBusService.RouteRedguardSectSignal(0, "po3_queststage_redguard_ms08_crown")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_RedguardForebearSources, sourceQuest, 118565, 200, "redguard_ms08_forebear", newStage)
        PDV_EventBusService.RouteRedguardSectSignal(1, "po3_queststage_redguard_ms08_forebear")
    endIf
EndFunction

Bool Function ShouldRouteP2Source(FormList sourceList, Form sourceForm, String routeKey, String sourceKind)
    if !HasListedForm(sourceList, sourceForm)
        return false
    endIf

    if !MarkP2SourceRoute(sourceForm, routeKey, sourceKind)
        Trace(2, "P2 immersive source repeat skipped: " + routeKey)
        return false
    endIf

    return true
EndFunction

Bool Function ShouldRouteP2QuestStage(FormList sourceList, Quest sourceQuest, Int expectedFormId, Int approvedStage, String routeKey, Int newStage)
    if newStage != approvedStage
        return false
    endIf

    if sourceQuest.GetFormID() != expectedFormId
        return false
    endIf

    return ShouldRouteP2Source(sourceList, sourceQuest as Form, routeKey + "_stage_" + approvedStage, "po3_queststage")
EndFunction

Bool Function MarkP2SourceRoute(Form sourceForm, String routeKey, String sourceKind)
    if !sourceForm
        return false
    endIf

    String baseKey = "PDV.P2Source." + routeKey + "." + sourceForm.GetFormID()
    if sourceKind == "po3_weather" || sourceKind == "po3_harvest"
        Int currentDay = Utility.GetCurrentGameTime() as Int
        String dayKey = baseKey + ".Day"
        if StorageUtil.GetIntValue(None, dayKey) == currentDay
            return false
        endIf

        StorageUtil.SetIntValue(None, dayKey, currentDay)
        return true
    endIf

    String seenKey = baseKey + ".Seen"
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return false
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    return true
EndFunction

Bool Function HasListedForm(FormList sourceList, Form sourceForm)
    if !sourceList
        return false
    endIf

    if !sourceForm
        return false
    endIf

    return sourceList.HasForm(sourceForm)
EndFunction

Function QueueOriginInitialization()
    if GetOriginRaceValue() >= 0
        return
    endIf

    RegisterForSingleUpdate(2.0)
    Trace(2, "Origin initialization queued after player load.")
EndFunction

Function EnsureOriginInitialized()
    if !PDV_OriginQuest
        Trace(1, "Origin init skipped: PDV_OriginQuest not assigned.")
        return
    endIf

    if !IsOriginCaptureSafe()
        Trace(2, "Origin init skipped: controls are not settled.")
        return
    endIf

    PDV_OriginQuest.InitializeOrigin()
EndFunction

Function RouteCurseRefresh(String reason)
    if !PDV_EventBusService
        Trace(1, "Curse refresh skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteCurseStateRefresh(reason)
EndFunction

Bool Function IsOriginCaptureSafe()
    if !Game.IsMovementControlsEnabled()
        return false
    endIf

    if !Game.IsMenuControlsEnabled()
        return false
    endIf

    return true
EndFunction

Int Function GetOriginRaceValue()
    if !PDV_OriginQuest
        return -1
    endIf

    GlobalVariable originGlobal = PDV_OriginQuest.PDV_GLO_OriginRace
    if originGlobal
        return originGlobal.GetValueInt()
    endIf

    return -1
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] PlayerEvents: " + traceText)
    endIf
EndFunction
