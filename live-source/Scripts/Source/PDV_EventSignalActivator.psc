;/
    PDV_EventSignalActivator.psc
    PlayerDevotion - authored activator signal receiver
    -----------------------------------------------------------------------
    Tiny CK-owned receiver for normal-play proof activators. The activator
    validates player/origin/day gates, then calls one existing EventBus route.
    It does not write piety, substrate, pact, or Daedric state directly.
    -----------------------------------------------------------------------
/;

Scriptname PDV_EventSignalActivator extends ObjectReference

PDV_EventBus Property PDV_EventBusService Auto
Actor Property PlayerREF Auto
GlobalVariable Property PDV_GLO_OriginRace Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property RouteId = 0 Auto
Int Property RequiredOriginRace = -1 Auto
String Property TraceLabel = "" Auto
String Property OncePerDayKey = "" Auto
Int Property SignalValue = 0 Auto
String Property SignalSourceId = "" Auto

Int Property ROUTE_DUNMER_PORTABLE_SHRINE = 30 AutoReadOnly
Int Property ROUTE_DUNMER_HOME_BONUS = 31 AutoReadOnly
Int Property ROUTE_KHAJIIT_MOON_OBSERVANCE = 10 AutoReadOnly
Int Property ROUTE_KHAJIIT_ROAD_HOME = 33 AutoReadOnly
Int Property ROUTE_GREEN_PACT_VIOLATION = 32 AutoReadOnly
Int Property ROUTE_HIRCINE_HUNT_RITE = 34 AutoReadOnly
Int Property ROUTE_TALOS_SHRINE_DEFIANCE = 35 AutoReadOnly
Int Property ROUTE_BOSMER_LIVING_STORY = 41 AutoReadOnly
Int Property ROUTE_BOSMER_EXCHANGE = 42 AutoReadOnly
Int Property ROUTE_BOSMER_BANDIT_ROAD = 43 AutoReadOnly
Int Property ROUTE_BOSMER_PACT_POSITIVE = 44 AutoReadOnly
Int Property ROUTE_STATE_TRANSITION_CONFIRM_RITE = 45 AutoReadOnly
Int Property ROUTE_ALTMER_LORKHAN_PRESSURE = 50 AutoReadOnly
Int Property ROUTE_ALTMER_CRISIS_SOURCE = 51 AutoReadOnly
Int Property ROUTE_ALTMER_DAWN_STEADINESS = 52 AutoReadOnly
Int Property ROUTE_ALTMER_ORTHODOX_COST = 53 AutoReadOnly
Int Property ROUTE_ARGONIAN_HIST_MAINTENANCE = 60 AutoReadOnly
Int Property ROUTE_ARGONIAN_PEOPLE_SUPPORT = 61 AutoReadOnly
Int Property ROUTE_ARGONIAN_VOID_SIGNAL = 62 AutoReadOnly
Int Property ROUTE_ARGONIAN_BED_OF_CHOICE = 63 AutoReadOnly
Int Property ROUTE_ORC_STRONGHOLD_FORGE = 70 AutoReadOnly
Int Property ROUTE_ORC_CITY_DIGNITY = 71 AutoReadOnly
Int Property ROUTE_ORC_LEGION_SERVICE = 72 AutoReadOnly
Int Property ROUTE_ORC_SELF_MADE_COMMUNITY = 73 AutoReadOnly
Int Property ROUTE_ORC_OATH_BREAK = 74 AutoReadOnly
Int Property ROUTE_ORC_FOUR_HOLDS_VISIT = 75 AutoReadOnly
Int Property ROUTE_REDGUARD_CROWN_TOMB_RESPECT = 80 AutoReadOnly
Int Property ROUTE_REDGUARD_FOREBEAR_ROAD = 81 AutoReadOnly
Int Property ROUTE_REDGUARD_ASHABAH_DEATH_DUTY = 82 AutoReadOnly
Int Property ROUTE_REDGUARD_FAR_SHORES_TOKEN = 83 AutoReadOnly
Int Property ROUTE_KHAJIIT_BAANDAR_ROAD_TRICK = 90 AutoReadOnly
Int Property ROUTE_KHAJIIT_RAJHIN_ELEGANT_THEFT = 91 AutoReadOnly
Int Property ROUTE_KHAJIIT_ALKOSH_DRAGON_ORDER = 92 AutoReadOnly
Int Property ROUTE_BOSMER_OLD_CONTRACT_PROPER_HUNT = 100 AutoReadOnly
Int Property ROUTE_BOSMER_OLD_CONTRACT_FOREST_KEPT = 101 AutoReadOnly
Int Property ROUTE_BOSMER_LIVING_STORY_COMMUNITY = 102 AutoReadOnly
Int Property ROUTE_BOSMER_LIVING_STORY_NATURE_SITE = 103 AutoReadOnly
Int Property ROUTE_BOSMER_EXCHANGE_DEBT_SETTLED = 104 AutoReadOnly
Int Property ROUTE_BOSMER_EXCHANGE_PROPORTIONATE_VENGEANCE = 105 AutoReadOnly
Int Property ROUTE_BOSMER_BANDIT_ROAD_ROAD_LIFE = 106 AutoReadOnly
Int Property ROUTE_BOSMER_BANDIT_ROAD_REVERSAL = 107 AutoReadOnly
; Khajiit anti-creed routes (creed-violation piety loss; curated triggers only)
Int Property ROUTE_KHAJIIT_AZURAH_DESECRATION = 110 AutoReadOnly
Int Property ROUTE_KHAJIIT_KHENARTHI_CARAVAN_HARM = 111 AutoReadOnly
Int Property ROUTE_KHAJIIT_RAJHIN_BOTCHED_THEFT = 112 AutoReadOnly
Int Property ROUTE_KHAJIIT_ALKOSH_CHAOS_AID = 113 AutoReadOnly
Int Property ROUTE_KHAJIIT_BAANDAR_BETRAYAL = 114 AutoReadOnly
Int Property ROUTE_KHAJIIT_KHENARTHI_CARAVAN_AID = 115 AutoReadOnly
Int Property ROUTE_DAEDRIC_PRINCE_SIGNAL = 200 AutoReadOnly
Int Property ROUTE_DAEDRIC_GENERIC_SILENCE = 201 AutoReadOnly
Int Property ROUTE_DAEDRIC_SHRINE_PRAYER = 202 AutoReadOnly

Event OnActivate(ObjectReference akActionRef)
    Actor playerActor = GetPlayerActor()
    if !playerActor || akActionRef != playerActor
        return
    endIf

    if !CanRouteSignal()
        return
    endIf

    RouteSignal()
EndEvent

Bool Function CanRouteSignal()
    if !PDV_EventBusService
        Trace(1, "Activator skipped: PDV_EventBusService not assigned.")
        return False
    endIf

    if RequiredOriginRace >= 0
        if !PDV_GLO_OriginRace
            Trace(1, "Activator skipped: origin global not assigned.")
            return False
        endIf

        if PDV_GLO_OriginRace.GetValueInt() != RequiredOriginRace
            Trace(2, "Activator ignored for origin " + PDV_GLO_OriginRace.GetValueInt())
            return False
        endIf
    endIf

    if OncePerDayKey != ""
        Float nowTime = Utility.GetCurrentGameTime()
        Float lastTime = StorageUtil.GetFloatValue(None, OncePerDayKey)
        if lastTime > 0.0 && (nowTime - lastTime) < 1.0
            Trace(2, "Activator ignored by once-per-day key.")
            return False
        endIf

        StorageUtil.SetFloatValue(None, OncePerDayKey, nowTime)
    endIf

    return True
EndFunction

Function RouteSignal()
    if RouteId == ROUTE_DUNMER_PORTABLE_SHRINE
        PDV_EventBusService.RouteDunmerPortableShrinePrayer()
    elseIf RouteId == ROUTE_DUNMER_HOME_BONUS
        PDV_EventBusService.RouteDunmerPlayerHomeBonus()
    elseIf RouteId == ROUTE_KHAJIIT_MOON_OBSERVANCE
        PDV_EventBusService.RouteKhajiitMoonObservance(SignalValue)
    elseIf RouteId == ROUTE_KHAJIIT_ROAD_HOME
        PDV_EventBusService.RouteKhajiitRoadHomeAnchor(SignalValue)
    elseIf RouteId == ROUTE_GREEN_PACT_VIOLATION
        PDV_EventBusService.RouteGreenPactViolation()
    elseIf RouteId == ROUTE_HIRCINE_HUNT_RITE
        PDV_EventBusService.RouteHircineHuntRite()
    elseIf RouteId == ROUTE_TALOS_SHRINE_DEFIANCE
        PDV_EventBusService.RouteTalosShrineDefiance()
    elseIf RouteId == ROUTE_BOSMER_LIVING_STORY
        PDV_EventBusService.RouteBosmerLivingStory()
    elseIf RouteId == ROUTE_BOSMER_EXCHANGE
        PDV_EventBusService.RouteBosmerExchange()
    elseIf RouteId == ROUTE_BOSMER_BANDIT_ROAD
        PDV_EventBusService.RouteBosmerBanditRoad()
    elseIf RouteId == ROUTE_BOSMER_PACT_POSITIVE
        PDV_EventBusService.RouteBosmerPactPositive()
    elseIf RouteId == ROUTE_STATE_TRANSITION_CONFIRM_RITE
        PDV_EventBusService.RouteStateTransitionConfirmationRite()
    elseIf RouteId == ROUTE_ALTMER_LORKHAN_PRESSURE
        Int pressureTier = SignalValue
        if pressureTier <= 0
            pressureTier = 1
        endIf
        PDV_EventBusService.RouteAltmerLorkhanPressure(pressureTier, GetSignalSourceId())
    elseIf RouteId == ROUTE_ALTMER_CRISIS_SOURCE
        Int crisisSource = SignalValue
        if crisisSource <= 0
            crisisSource = 1
        endIf
        PDV_EventBusService.RouteAltmerCrisisSource(crisisSource, GetSignalSourceId())
    elseIf RouteId == ROUTE_ALTMER_DAWN_STEADINESS
        PDV_EventBusService.RouteAltmerDawnSteadiness()
    elseIf RouteId == ROUTE_ALTMER_ORTHODOX_COST
        PDV_EventBusService.RouteAltmerOrthodoxCostlyEnforcement()
    elseIf RouteId == ROUTE_ARGONIAN_HIST_MAINTENANCE
        PDV_EventBusService.RouteArgonianHistMaintenance()
    elseIf RouteId == ROUTE_ARGONIAN_PEOPLE_SUPPORT
        PDV_EventBusService.RouteArgonianPeopleSupport()
    elseIf RouteId == ROUTE_ARGONIAN_VOID_SIGNAL
        PDV_EventBusService.RouteArgonianVoidSignal()
    elseIf RouteId == ROUTE_ARGONIAN_BED_OF_CHOICE
        PDV_EventBusService.RouteArgonianBedOfChoice()
    elseIf RouteId == ROUTE_ORC_STRONGHOLD_FORGE
        PDV_EventBusService.RouteOrcStrongholdForge()
    elseIf RouteId == ROUTE_ORC_CITY_DIGNITY
        PDV_EventBusService.RouteOrcCityDignity()
    elseIf RouteId == ROUTE_ORC_LEGION_SERVICE
        PDV_EventBusService.RouteOrcLegionService()
    elseIf RouteId == ROUTE_ORC_SELF_MADE_COMMUNITY
        PDV_EventBusService.RouteOrcSelfMadeCommunity()
    elseIf RouteId == ROUTE_ORC_OATH_BREAK
        PDV_EventBusService.RouteOrcOathBreak(GetSignalSourceId())
    elseIf RouteId == ROUTE_ORC_FOUR_HOLDS_VISIT
        PDV_EventBusService.RouteOrcFourHoldsVisit(SignalValue, GetSignalSourceId())
    elseIf RouteId == ROUTE_REDGUARD_CROWN_TOMB_RESPECT
        PDV_EventBusService.RouteRedguardCrownTombRespect()
    elseIf RouteId == ROUTE_REDGUARD_FOREBEAR_ROAD
        PDV_EventBusService.RouteRedguardForebearRoadPassage()
    elseIf RouteId == ROUTE_REDGUARD_ASHABAH_DEATH_DUTY
        PDV_EventBusService.RouteRedguardAshAbahDeathDuty()
    elseIf RouteId == ROUTE_REDGUARD_FAR_SHORES_TOKEN
        PDV_EventBusService.RouteRedguardFarShoresToken()
    elseIf RouteId == ROUTE_KHAJIIT_BAANDAR_ROAD_TRICK
        PDV_EventBusService.RouteKhajiitBaanDarRoadTrick()
    elseIf RouteId == ROUTE_KHAJIIT_RAJHIN_ELEGANT_THEFT
        PDV_EventBusService.RouteKhajiitRajhinElegantTheft()
    elseIf RouteId == ROUTE_KHAJIIT_ALKOSH_DRAGON_ORDER
        PDV_EventBusService.RouteKhajiitAlkoshDragonOrder()
    elseIf RouteId == ROUTE_KHAJIIT_AZURAH_DESECRATION
        PDV_EventBusService.RouteKhajiitAzurahDesecration()
    elseIf RouteId == ROUTE_KHAJIIT_KHENARTHI_CARAVAN_HARM
        PDV_EventBusService.RouteKhajiitKhenarthiCaravanHarm()
    elseIf RouteId == ROUTE_KHAJIIT_KHENARTHI_CARAVAN_AID
        PDV_EventBusService.RouteKhajiitKhenarthiCaravanAid("acti_trigger")
    elseIf RouteId == ROUTE_KHAJIIT_RAJHIN_BOTCHED_THEFT
        PDV_EventBusService.RouteKhajiitRajhinBotchedTheft()
    elseIf RouteId == ROUTE_KHAJIIT_ALKOSH_CHAOS_AID
        PDV_EventBusService.RouteKhajiitAlkoshChaosAid()
    elseIf RouteId == ROUTE_KHAJIIT_BAANDAR_BETRAYAL
        PDV_EventBusService.RouteKhajiitBaanDarBetrayal()
    elseIf RouteId == ROUTE_BOSMER_OLD_CONTRACT_PROPER_HUNT
        PDV_EventBusService.RouteBosmerOldContractProperHunt()
    elseIf RouteId == ROUTE_BOSMER_OLD_CONTRACT_FOREST_KEPT
        PDV_EventBusService.RouteBosmerOldContractForestKept()
    elseIf RouteId == ROUTE_BOSMER_LIVING_STORY_COMMUNITY
        PDV_EventBusService.RouteBosmerLivingStoryCommunityKept()
    elseIf RouteId == ROUTE_BOSMER_LIVING_STORY_NATURE_SITE
        PDV_EventBusService.RouteBosmerLivingStoryNatureSite()
    elseIf RouteId == ROUTE_BOSMER_EXCHANGE_DEBT_SETTLED
        PDV_EventBusService.RouteBosmerExchangeDebtSettled()
    elseIf RouteId == ROUTE_BOSMER_EXCHANGE_PROPORTIONATE_VENGEANCE
        PDV_EventBusService.RouteBosmerExchangeProportionateVengeance()
    elseIf RouteId == ROUTE_BOSMER_BANDIT_ROAD_ROAD_LIFE
        PDV_EventBusService.RouteBosmerBanditRoadRoadLife()
    elseIf RouteId == ROUTE_BOSMER_BANDIT_ROAD_REVERSAL
        PDV_EventBusService.RouteBosmerBanditRoadReversal()
    elseIf RouteId == ROUTE_DAEDRIC_PRINCE_SIGNAL
        PDV_EventBusService.RouteDaedricPrinceSignal(SignalValue, GetSignalSourceId())
    elseIf RouteId == ROUTE_DAEDRIC_GENERIC_SILENCE
        PDV_EventBusService.RouteDaedricGenericSilenceProbe(GetSignalSourceId())
    elseIf RouteId == ROUTE_DAEDRIC_SHRINE_PRAYER || RouteId == 202
        PDV_EventBusService.RouteDaedricShrinePrayer(SignalValue, GetSignalSourceId())
    else
        Trace(1, "Activator skipped: unsupported RouteId " + RouteId)
        return
    endIf

    Trace(2, "Activator routed " + RouteId + " " + TraceLabel)
EndFunction

String Function GetSignalSourceId()
    if SignalSourceId != ""
        return SignalSourceId
    endIf

    if TraceLabel != ""
        return TraceLabel
    endIf

    return "activator_route_" + RouteId
EndFunction

Actor Function GetPlayerActor()
    if PlayerREF
        return PlayerREF
    endIf

    return Game.GetPlayer()
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] EventSignalActivator: " + traceText)
    endIf
EndFunction
