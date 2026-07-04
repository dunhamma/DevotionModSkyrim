;/
    PDV__SM_AddToPlayer.psc
    Thin Player Add Item Story Manager receiver.
/;

Scriptname PDV__SM_AddToPlayer extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryAddToPlayer(ObjectReference akOwner, ObjectReference akContainer, Location akLocation, Form akItemBase, Int aiAcquireType)
    if PDV_Router
        PDV_Router.HandleStoryAddToPlayer(akOwner, akContainer, akLocation, akItemBase, aiAcquireType)
    else
        Debug.Trace("[PDV] PDV__SM_AddToPlayer: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
