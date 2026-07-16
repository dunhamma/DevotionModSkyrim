Scriptname PDV_QuestReactionWorker extends Quest

; Dedicated, bounded worker for matrix-backed quest reactions. The manager owns
; queue data and gameplay semantics; this quest owns only the short-lived
; single-update cadence so the manager's 1-second housekeeping update stays cheap.
PDV__ManagerQuest Property PDV_Manager Auto

Float Property QUEST_REACTION_QUEUE_TICK_SECONDS = 0.1 AutoReadOnly

Event OnInit()
    ResumeQuestReactionQueue(False)
EndEvent

Event OnPlayerLoadGame()
    ; StorageUtil queue entries survive a save/load. Re-arm only when work is
    ; still pending; this avoids a permanent update registration in a player's save.
    ResumeQuestReactionQueue(True)
EndEvent

Function EnsureQuestReactionQueueRunning()
    if PDV_Manager && PDV_Manager.HasQueuedQuestReactionJobs()
        RegisterForSingleUpdate(QUEST_REACTION_QUEUE_TICK_SECONDS)
    endIf
EndFunction

Function ResumeQuestReactionQueue(Bool fromLoad)
    if !PDV_Manager || !PDV_Manager.HasQueuedQuestReactionJobs()
        return
    endIf
    if fromLoad
        PDV_Manager.TraceQuestReactionQueue("RESUME pending=" + PDV_Manager.GetQuestReactionQueueStatus())
    endIf
    RegisterForSingleUpdate(QUEST_REACTION_QUEUE_TICK_SECONDS)
EndFunction

Event OnUpdate()
    if !PDV_Manager
        return
    endIf
    if PDV_Manager.ProcessQuestReactionQueueSlice()
        RegisterForSingleUpdate(QUEST_REACTION_QUEUE_TICK_SECONDS)
    endIf
EndEvent
