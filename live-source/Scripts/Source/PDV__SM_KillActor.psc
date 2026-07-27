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

; D1 / audit "Cosmetic / cleanup". This receiver fires on EVERY kill in the game, and it
; used to open with an UNCONDITIONAL Debug.Trace -- the only ungated trace in any of the
; nine Story Manager receivers, and the only one on a per-kill path. Every user with
; Papyrus logging on paid a formatted line and a disk write for every corpse, whether or
; not they were debugging, and the log noise buried anything that mattered.
;
; It is now behind the same debug level every other PDV trace uses, reached through the
; router (this receiver has no debug-level property of its own, and ADDING one would
; leave an unbound VMAD property on the quest record -- silently None, and a new finding
; in the validate_scripts sweep -- so it borrows the router's, which is already bound).
; The level check comes BEFORE the string is built: Papyrus evaluates call arguments
; eagerly, so a suppressed trace whose message is still concatenated costs nearly as much
; as one that prints.
Event OnStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, Int aiCrimeStatus, Int aiRelationshipRank)
    if PDV_Router
        if PDV_Router.GetDebugLevel() >= 3
            Int hasVictim = 0
            Int hasKiller = 0
            if akVictim
                hasVictim = 1
            endIf
            if akKiller
                hasKiller = 1
            endIf
            Debug.Trace("[PDV] PDV__SM_KillActor: OnStoryKillActor received, victim=" + hasVictim + ", killer=" + hasKiller + ", crime=" + aiCrimeStatus + ", relationship=" + aiRelationshipRank)
        endIf

        PDV_Router.HandleStoryKillActor(akVictim, akKiller, akLocation, aiCrimeStatus, aiRelationshipRank)
    else
        ; Deliberately ungated: this fires only on a broken install (the receiver's router
        ; property was never filled), it cannot reach a debug level through the router it
        ; is complaining about, and it is one line per kill on a mod that is already dead.
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
