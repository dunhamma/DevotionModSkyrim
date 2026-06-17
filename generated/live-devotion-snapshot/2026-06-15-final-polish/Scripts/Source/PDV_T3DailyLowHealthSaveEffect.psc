;/
    PDV_T3DailyLowHealthSaveEffect.psc
    Shared Phase 2 T3 fallback capstone skeleton.
/;

Scriptname PDV_T3DailyLowHealthSaveEffect extends ActiveMagicEffect

String Property StorageKey = "PDV.Capstone.LowHealthSave.Generic" Auto
Float Property TriggerHealthPercent = 0.20 Auto
Float Property HealAmount = 0.0 Auto ; <= 0 restores to current max health.
Float Property WatchIntervalSeconds = 0.1 Auto ; Retained for old VMAD compatibility; OnHit drives the save.
Spell Property HealSpell Auto ; Optional vanilla-style heal spell. Falls back to RestoreActorValue when unset.
GlobalVariable Property PDV_GLO_DebugLevel Auto

Actor watchedActor
Bool watching = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
    watchedActor = akTarget
    watching = watchedActor != None
    if watching
        Trace(1, "start key=" + StorageKey + " threshold=" + TriggerHealthPercent + " heal=" + HealAmount + " trigger=OnHit")
    else
        Trace(1, "start failed: no target key=" + StorageKey)
    endIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    Trace(1, "finish key=" + StorageKey)
    watching = false
    watchedActor = None
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
    if !watching || watchedActor == None
        return
    endIf

    TryApplyDailySave("hit")
EndEvent

Event OnDying(Actor akKiller)
    if !watching || watchedActor == None
        return
    endIf

    TryApplyDailySave("dying")
EndEvent

Function TryApplyDailySave(String triggerReason)
    Float healthPercent = watchedActor.GetActorValuePercentage("Health")
    if healthPercent > TriggerHealthPercent
        return
    endIf

    Trace(1, "low-health sample key=" + StorageKey + " trigger=" + triggerReason + " percent=" + healthPercent + " threshold=" + TriggerHealthPercent)

    Int currentDay = (Utility.GetCurrentGameTime() as Int) + 1
    Int lastDay = StorageUtil.GetIntValue(watchedActor, StorageKey)
    if lastDay == currentDay
        Trace(1, "daily block key=" + StorageKey + " day=" + currentDay)
        return
    endIf

    if HealSpell != None
        HealSpell.Cast(watchedActor)
        StorageUtil.SetIntValue(watchedActor, StorageKey, currentDay)
        Trace(1, "T3 daily low-health save fired key=" + StorageKey + " trigger=" + triggerReason + " day=" + currentDay + " restore=healSpell")
        return
    endIf

    Float restoreAmount = HealAmount
    Float currentHealth = watchedActor.GetActorValue("Health")
    healthPercent = watchedActor.GetActorValuePercentage("Health")
    if restoreAmount <= 0.0
        if healthPercent > 0.0
            restoreAmount = (currentHealth / healthPercent) - currentHealth
        else
            restoreAmount = 10000.0
        endIf
    endIf

    if restoreAmount <= 0.0
        Trace(1, "blocked non-positive restore key=" + StorageKey + " current=" + currentHealth + " percent=" + healthPercent)
        return
    endIf

    watchedActor.RestoreActorValue("Health", restoreAmount)
    StorageUtil.SetIntValue(watchedActor, StorageKey, currentDay)
    Trace(1, "T3 daily low-health save fired key=" + StorageKey + " trigger=" + triggerReason + " day=" + currentDay + " current=" + currentHealth + " percent=" + healthPercent + " restore=" + restoreAmount)
EndFunction

Function Trace(Int level, String traceText)
    if PDV_GLO_DebugLevel && (PDV_GLO_DebugLevel.GetValueInt() >= level)
        Debug.Trace("[PDV_T3DailyLowHealthSaveEffect] " + traceText)
    endIf
EndFunction
