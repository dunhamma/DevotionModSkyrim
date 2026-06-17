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
    if PDV_Router
        PDV_Router.HandleStoryKillActor(akVictim, akKiller, akLocation, aiCrimeStatus, aiRelationshipRank)
    else
        Debug.Trace("[PDV] PDV__SM_KillActor: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
