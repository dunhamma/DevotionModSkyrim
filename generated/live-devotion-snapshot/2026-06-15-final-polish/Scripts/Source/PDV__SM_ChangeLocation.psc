;/
    PDV__SM_ChangeLocation.psc
    Thin Change Location Story Manager receiver.
/;

Scriptname PDV__SM_ChangeLocation extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryChangeLocation(ObjectReference akActor, Location akOldLocation, Location akNewLocation)
    if PDV_Router
        PDV_Router.HandleStoryChangeLocation(akActor, akOldLocation, akNewLocation)
    else
        Debug.Trace("[PDV] PDV__SM_ChangeLocation: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
