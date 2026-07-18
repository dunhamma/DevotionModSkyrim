;/
    PDV__SM_KillActor.psc
    PlayerDevotion - Kill Actor Story Manager receiver
    -----------------------------------------------------------------------
    OVERVIEW
    Non-Start-Game-Enabled quest started by the Kill Actor Story Manager
    event. It forwards the event payload to PDV_ActionRouter, then stops
    and resets itself so later kill events can start a fresh instance.

    DESIGN NOTES
    - Keep this script intentionally thin. It is lifecycle glue only.
    - Do not score piety here.
    - Do not use CK stage fragments for this receiver unless the quest
      script event path fails in CKPE testing.
    -----------------------------------------------------------------------
/;

Scriptname PDV__SM_KillActor extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, Int aiCrimeStatus, Int aiRelationshipRank)
    Int hasVictim = 0
    Int hasKiller = 0
    if akVictim
        hasVictim = 1
    endIf
    if akKiller
        hasKiller = 1
    endIf
    Debug.Trace("[PDV] PDV__SM_KillActor: OnStoryKillActor received, victim=" + hasVictim + ", killer=" + hasKiller + ", crime=" + aiCrimeStatus + ", relationship=" + aiRelationshipRank)

    if PDV_Router
        PDV_Router.HandleStoryKillActor(akVictim, akKiller, akLocation, aiCrimeStatus, aiRelationshipRank)
    else
        Debug.Trace("[PDV] PDV__SM_KillActor: PDV_Router not assigned.")
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
