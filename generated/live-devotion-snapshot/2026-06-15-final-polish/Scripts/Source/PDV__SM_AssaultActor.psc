;/
    PDV__SM_AssaultActor.psc
    Thin Assault Actor Story Manager receiver.
/;

Scriptname PDV__SM_AssaultActor extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryAssaultActor(ObjectReference akVictim, ObjectReference akAttacker, Location akLocation, Int aiCrime)
    if PDV_Router
        PDV_Router.HandleStoryAssaultActor(akVictim, akAttacker, akLocation, aiCrime)
    else
        Debug.Trace("[PDV] PDV__SM_AssaultActor: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
