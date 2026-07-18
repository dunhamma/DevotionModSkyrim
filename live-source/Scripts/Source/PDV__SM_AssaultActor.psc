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
