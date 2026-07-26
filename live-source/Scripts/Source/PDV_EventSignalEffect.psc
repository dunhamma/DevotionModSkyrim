;/
    PDV_EventSignalEffect.psc
    PlayerDevotion - authored magic-effect signal receiver
    -----------------------------------------------------------------------
    Tiny CK-owned receiver for consumable/spell/MGEF proof signals. The effect
    validates player/origin/day gates, then calls one existing EventBus route.
    It does not write piety, substrate, pact, or Daedric state directly.
    -----------------------------------------------------------------------
/;

Scriptname PDV_EventSignalEffect extends ActiveMagicEffect

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
Int Property ROUTE_GREEN_PACT_VIOLATION = 32 AutoReadOnly
Int Property ROUTE_HIRCINE_HUNT_RITE = 34 AutoReadOnly
Int Property ROUTE_BOSMER_LIVING_STORY = 41 AutoReadOnly
Int Property ROUTE_BOSMER_EXCHANGE = 42 AutoReadOnly
Int Property ROUTE_BOSMER_BANDIT_ROAD = 43 AutoReadOnly
Int Property ROUTE_BOSMER_PACT_POSITIVE = 44 AutoReadOnly
Int Property ROUTE_STATE_TRANSITION_CONFIRM_RITE = 45 AutoReadOnly
Int Property ROUTE_ALTMER_LORKHAN_PRESSURE = 50 AutoReadOnly
Int Property ROUTE_ALTMER_CRISIS_SOURCE = 51 AutoReadOnly
Int Property ROUTE_ALTMER_DAWN_STEADINESS = 52 AutoReadOnly
Int Property ROUTE_ALTMER_ORTHODOX_COST = 53 AutoReadOnly
Int Property ROUTE_ORC_STRONGHOLD_FORGE = 70 AutoReadOnly
Int Property ROUTE_ORC_CITY_DIGNITY = 71 AutoReadOnly
Int Property ROUTE_ORC_LEGION_SERVICE = 72 AutoReadOnly
Int Property ROUTE_ORC_SELF_MADE_COMMUNITY = 73 AutoReadOnly
Int Property ROUTE_ORC_OATH_BREAK = 74 AutoReadOnly
Int Property ROUTE_ORC_FOUR_HOLDS_VISIT = 75 AutoReadOnly
Int Property ROUTE_DAEDRIC_PRINCE_SIGNAL = 200 AutoReadOnly
Int Property ROUTE_DAEDRIC_GENERIC_SILENCE = 201 AutoReadOnly

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Actor playerActor = GetPlayerActor()
    if !playerActor || akTarget != playerActor
        return
    endIf

    if !CanRouteSignal()
        return
    endIf

    ; B14 / fix-plan 4.4: stamp the once-per-day charge only on a route that succeeded.
    if RouteSignal()
        StampOncePerDayKey()
    endIf
EndEvent

Bool Function CanRouteSignal()
    if !PDV_EventBusService
        Trace(1, "Effect skipped: PDV_EventBusService not assigned.")
        return False
    endIf

    if RequiredOriginRace >= 0
        if !PDV_GLO_OriginRace
            Trace(1, "Effect skipped: origin global not assigned.")
            return False
        endIf

        if PDV_GLO_OriginRace.GetValueInt() != RequiredOriginRace
            Trace(2, "Effect ignored for origin " + PDV_GLO_OriginRace.GetValueInt())
            return False
        endIf
    endIf

    ; B14 / fix-plan 4.4. This used to CONSUME the day's charge here, in the "can I?"
    ; check, and then RouteSignal could still fall through its unsupported-RouteId else
    ; branch or hit a null PDV_Manager inside the bus -- charge gone, nothing routed,
    ; no feedback. It now only TESTS the key; StampOncePerDayKey is called by the event
    ; handler, and only when RouteSignal reports it actually dispatched.
    if OncePerDayKey != ""
        Float lastTime = StorageUtil.GetFloatValue(None, OncePerDayKey)
        if lastTime > 0.0 && (Utility.GetCurrentGameTime() - lastTime) < 1.0
            Trace(2, "Effect ignored by once-per-day key.")
            return False
        endIf
    endIf

    return True
EndFunction

Function StampOncePerDayKey()
    if OncePerDayKey != ""
        StorageUtil.SetFloatValue(None, OncePerDayKey, Utility.GetCurrentGameTime())
    endIf
EndFunction

Bool Function RouteSignal()
    ; Every Route* below no-ops when the bus has no PDV_Manager bound, which is exactly
    ; the early-after-load state that made this charge-burn visible. Fail before the
    ; charge is spent rather than after.
    if !PDV_EventBusService.PDV_Manager
        Trace(1, "Effect skipped: event bus has no manager bound.")
        return False
    endIf

    if RouteId == ROUTE_DUNMER_PORTABLE_SHRINE
        PDV_EventBusService.RouteDunmerPortableShrinePrayer()
    elseIf RouteId == ROUTE_DUNMER_HOME_BONUS
        PDV_EventBusService.RouteDunmerPlayerHomeBonus()
    elseIf RouteId == ROUTE_GREEN_PACT_VIOLATION
        PDV_EventBusService.RouteGreenPactViolation()
    elseIf RouteId == ROUTE_HIRCINE_HUNT_RITE
        PDV_EventBusService.RouteHircineHuntRite()
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
    elseIf RouteId == ROUTE_DAEDRIC_PRINCE_SIGNAL
        PDV_EventBusService.RouteDaedricPrinceSignal(SignalValue, GetSignalSourceId())
    elseIf RouteId == ROUTE_DAEDRIC_GENERIC_SILENCE
        PDV_EventBusService.RouteDaedricGenericSilenceProbe(GetSignalSourceId())
    else
        Trace(1, "Effect skipped: unsupported RouteId " + RouteId)
        return False
    endIf

    Trace(2, "Effect routed " + RouteId + " " + TraceLabel)
    return True
EndFunction

String Function GetSignalSourceId()
    if SignalSourceId != ""
        return SignalSourceId
    endIf

    if TraceLabel != ""
        return TraceLabel
    endIf

    return "effect_route_" + RouteId
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
        Debug.Trace("[PDV] EventSignalEffect: " + traceText)
    endIf
EndFunction
