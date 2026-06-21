;/
    PDV__SM_NewVoicePower.psc
    Thin New Voice Power Story Manager receiver.
/;

Scriptname PDV__SM_NewVoicePower extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryNewVoicePower(ObjectReference akActor, Form akVoicePower)
    if PDV_Router
        PDV_Router.HandleStoryNewVoicePower(akActor, akVoicePower)
    else
        Debug.Trace("[PDV] PDV__SM_NewVoicePower: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
