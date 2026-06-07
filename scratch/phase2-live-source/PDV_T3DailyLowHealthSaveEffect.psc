;/
    PDV_T3DailyLowHealthSaveEffect.psc
    Shared Phase 2 T3 fallback capstone skeleton.
/;

Scriptname PDV_T3DailyLowHealthSaveEffect extends ActiveMagicEffect

String Property StorageKey = "PDV.Capstone.LowHealthSave.Generic" Auto
Float Property TriggerHealthPercent = 0.10 Auto
Float Property HealAmount = 75.0 Auto
Float Property WatchIntervalSeconds = 2.0 Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Actor watchedActor
Bool watching = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
    watchedActor = akTarget
    watching = watchedActor != None
    if watching
        RegisterForSingleUpdate(WatchIntervalSeconds)
    endIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    watching = false
    watchedActor = None
EndEvent

Event OnUpdate()
    if !watching || watchedActor == None
        return
    endIf

    if watchedActor.IsDead()
        watching = false
        return
    endIf

    if watchedActor.GetActorValuePercentage("Health") <= TriggerHealthPercent
        TryApplyDailySave()
    endIf

    if watching
        RegisterForSingleUpdate(WatchIntervalSeconds)
    endIf
EndEvent

Function TryApplyDailySave()
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int lastDay = StorageUtil.GetIntValue(watchedActor, StorageKey)
    if lastDay == currentDay
        return
    endIf

    StorageUtil.SetIntValue(watchedActor, StorageKey, currentDay)
    watchedActor.RestoreActorValue("Health", HealAmount)
    Trace(2, "T3 daily low-health save fired: " + StorageKey)
EndFunction

Function Trace(Int level, String traceText)
    if PDV_GLO_DebugLevel && (PDV_GLO_DebugLevel.GetValueInt() >= level)
        Debug.Trace("[PDV_T3DailyLowHealthSaveEffect] " + traceText)
    endIf
EndFunction
