Scriptname PDV_FragmentBridge Hidden
{Tiny helper surface for CK vanilla fragments that need to reach PDV quest services without inline custom-script casts.}

Int Function GetEventBusLocalFormId() Global
    return 289527 ; 0x00046AF7 within Devotion.esp
EndFunction

String Function GetFrameworkPluginName() Global
    return "Devotion.esp"
EndFunction

PDV_EventBus Function ResolveEventBusService() Global
    return Game.GetFormFromFile(GetEventBusLocalFormId(), GetFrameworkPluginName()) as PDV_EventBus
EndFunction

Bool Function RouteConcordatCompliance() Global
    return RouteResolvedConcordat(True)
EndFunction

Bool Function RouteConcordatDefiance() Global
    return RouteResolvedConcordat(False)
EndFunction

Bool Function RouteConcordatFromQuest(Quest eventBusQuest, Bool isCompliance) Global
    PDV_EventBus eventBus = eventBusQuest as PDV_EventBus
    if !eventBus
        eventBus = ResolveEventBusService()
    endIf

    if !eventBus
        Debug.Trace("[PDV] FragmentBridge: RouteConcordatFromQuest skipped: event bus quest missing or wrong type.")
        return false
    endIf

    eventBus.RouteConcordatPressure(isCompliance)
    return true
EndFunction

Bool Function RouteResolvedConcordat(Bool isCompliance) Global
    PDV_EventBus eventBus = ResolveEventBusService()
    if !eventBus
        Debug.Trace("[PDV] FragmentBridge: RouteResolvedConcordat skipped: PDV_EventBus could not be resolved.")
        return false
    endIf

    eventBus.RouteConcordatPressure(isCompliance)
    return true
EndFunction
