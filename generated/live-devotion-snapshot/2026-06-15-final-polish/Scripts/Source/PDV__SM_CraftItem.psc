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
    Stop()
    Reset()
EndFunction
