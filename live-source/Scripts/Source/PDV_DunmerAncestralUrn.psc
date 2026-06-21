Scriptname PDV_DunmerAncestralUrn extends ObjectReference
{Readable inventory urn token for Dunmer ancestor prayer.}

Event OnRead()
    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteDunmerPortableShrinePrayer()
    else
        Debug.Trace("[PDV] Dunmer ancestral urn skipped: PDV_EventBus could not be resolved.")
    endIf
EndEvent
