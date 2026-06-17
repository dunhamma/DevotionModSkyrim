;/
    PDV__SM_PickLock.psc
    Thin Pick Lock Story Manager receiver.
/;

Scriptname PDV__SM_PickLock extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryPickLock(ObjectReference akActor, ObjectReference akLock)
    if PDV_Router
        PDV_Router.HandleStoryPickLock(akActor, akLock)
    else
        Debug.Trace("[PDV] PDV__SM_PickLock: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
