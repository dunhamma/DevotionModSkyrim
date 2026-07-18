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
