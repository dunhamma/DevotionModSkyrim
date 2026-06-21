Scriptname PDV_ArgonianHistSapToken extends ObjectReference
{Readable inventory sap token for Argonian Hist maintenance.}

Event OnRead()
    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteArgonianHistMaintenance()
    else
        Debug.Trace("[PDV] Argonian Hist sap token skipped: PDV_EventBus could not be resolved.")
    endIf
EndEvent
