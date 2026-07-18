;/
    PDV__SM_CraftItem.psc
    Thin Craft Item Story Manager receiver.
/;

Scriptname PDV__SM_CraftItem extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryCraftItem(ObjectReference akBench, Location akLocation, Form akCreatedItem)
    if PDV_Router
        PDV_Router.HandleStoryCraftItem(akBench, akLocation, akCreatedItem)
    else
        Debug.Trace("[PDV] PDV__SM_CraftItem: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    ; Defer teardown out of the story-event frame (issue #17 CTD class):
    ; Stop()/Reset() inside the story-event handler re-inits alias
    ; bookkeeping while the engine may still be marshalling a queued
    ; story event on the quest job thread.
    RegisterForSingleUpdate(0.1)
EndFunction

Event OnUpdate()
    Stop()
    Reset()
EndEvent
