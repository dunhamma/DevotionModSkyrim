Scriptname PDV_PotionArgonianHistSapEffect extends ActiveMagicEffect
{Attached to PDV_MGEF_ArgonianHistSap on the PDV_ALCH_ArgonianHistSap "Hist Sap" ritual potion. On consume it
 routes the Argonian Hist maintenance signal (the manager gates Argonian origin + the once/day Hist cap, so
 routing here is unconditional -- exactly like the old read-token) and immediately re-adds one Hist Sap to the
 player so the ritual vial is never spent. EventBus is resolved at runtime via PDV_FragmentBridge, so the
 effect needs no baked bus property; only the potion form is baked so it can replenish itself.}

Potion Property PDV_ALCH_ArgonianHistSap Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteArgonianHistMaintenance()
    else
        Debug.Trace("[PDV] Hist Sap potion skipped: PDV_EventBus could not be resolved.")
    endIf

    Actor player = Game.GetPlayer()
    if player && PDV_ALCH_ArgonianHistSap
        player.AddItem(PDV_ALCH_ArgonianHistSap, 1, True)
    endIf
EndEvent
