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

; --- LD-P1 Living Deities (research slice) ---
; Mood gate: when RequiredMoodBand >= 0 the save fires only while the active
; patron's mood band (PDV_GLO_PatronMoodBand mirror, refreshed at dawn and on
; band-cross) is at or above it. -1 keeps the shipped ungated behavior, so
; existing VMAD instances (baked property values) are unaffected. This is a
; script-poll read at trigger time, not an MGEF live-global read, so it is
; legal despite the applied-MGEF global limitation.
Int Property RequiredMoodBand = -1 Auto
GlobalVariable Property PDV_GLO_PatronMoodBand Auto
; Deity theming for the save moment ("" = silent, shipped behavior).
String Property DeityLabel = "" Auto

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
    ; Mood gate BEFORE the day-key write so a blocked attempt does not burn
    ; the once-per-day charge.
    if RequiredMoodBand >= 0
        if !PDV_GLO_PatronMoodBand
            return
        endIf
        if PDV_GLO_PatronMoodBand.GetValueInt() < RequiredMoodBand
            Trace(2, "T3 save blocked by mood gate: " + StorageKey)
            return
        endIf
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int lastDay = StorageUtil.GetIntValue(watchedActor, StorageKey)
    if lastDay == currentDay
        return
    endIf

    StorageUtil.SetIntValue(watchedActor, StorageKey, currentDay)
    watchedActor.RestoreActorValue("Health", HealAmount)
    if DeityLabel != ""
        Debug.Notification(DeityLabel + " steadies your failing body.")
    endIf
    Trace(2, "T3 daily low-health save fired: " + StorageKey)
EndFunction

Function Trace(Int level, String traceText)
    if PDV_GLO_DebugLevel && (PDV_GLO_DebugLevel.GetValueInt() >= level)
        Debug.Trace("[PDV_T3DailyLowHealthSaveEffect] " + traceText)
    endIf
EndFunction
