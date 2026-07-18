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
