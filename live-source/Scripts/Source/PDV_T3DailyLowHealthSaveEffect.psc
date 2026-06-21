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
String Property NotificationText = "Devotion pulls you back from the edge." Auto
String Property PrismaTitle = "Devotion" Auto
String Property PrismaText = "" Auto
String Property PrismaSymbol = "journal" Auto
String Property PrismaTone = "good" Auto
Bool Property SendPrismaToast = true Auto

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
        ShowCapstoneNotice(triggerReason)
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
    ShowCapstoneNotice(triggerReason)
    Trace(1, "T3 daily low-health save fired key=" + StorageKey + " trigger=" + triggerReason + " day=" + currentDay + " current=" + currentHealth + " percent=" + healthPercent + " restore=" + restoreAmount)
EndFunction

Function ShowCapstoneNotice(String triggerReason)
    String noticeText = NotificationText
    if noticeText == ""
        noticeText = "Devotion pulls you back from the edge."
    endIf

    Debug.Notification(noticeText)

    if SendPrismaToast && PDV_PrismaBridge.IsAvailable()
        String titleText = PrismaTitle
        if titleText == ""
            titleText = "Devotion"
        endIf

        String messageText = PrismaText
        if messageText == ""
            messageText = noticeText
        endIf

        String symbolName = PrismaSymbol
        if symbolName == ""
            symbolName = "journal"
        endIf

        String toneName = PrismaTone
        if toneName == ""
            toneName = "good"
        endIf

        String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + JsonSafeString(symbolName) + "\",\"tone\":\"" + JsonSafeString(toneName) + "\",\"title\":\"" + JsonSafeString(titleText) + "\",\"message\":\"" + JsonSafeString(messageText) + "\"}}"
        Bool sent = PDV_PrismaBridge.SendOverlayJson(payload)
        if !sent
            Trace(2, "Prisma capstone toast failed key=" + StorageKey + " trigger=" + triggerReason)
        endIf
    endIf

    ; Book of Days: log the capstone firing as a dated entry. Written directly to the
    ; global journal ring that PDV__ManagerQuest.BuildJournalPayloadJson renders (and
    ; prunes at dawn / on its next append) -- all keys are global StorageUtil on None,
    ; so no manager reference or MGEF property wiring is needed. Once per day by the
    ; StorageKey day-guard in TryApplyDailySave, so no de-dupe is required.
    String journalSymbol = PrismaSymbol
    if journalSymbol == ""
        journalSymbol = "journal"
    endIf
    Int journalDay = Utility.GetCurrentGameTime() as Int
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Lines", noticeText, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Days", journalDay, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Tones", "substrate.act", True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Symbols", journalSymbol, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Pinned", 0, True)
EndFunction

String Function JsonSafeString(String rawText)
    if rawText == ""
        return ""
    endIf

    String safeText = ""
    Int i = 0
    Int count = StringUtil.GetLength(rawText)
    while i < count
        String currentChar = StringUtil.GetNthChar(rawText, i)
        if currentChar == "\"" || currentChar == "\\"
            safeText = safeText + "'"
        else
            safeText = safeText + currentChar
        endIf
        i += 1
    endWhile

    return safeText
EndFunction

Function Trace(Int level, String traceText)
    if PDV_GLO_DebugLevel && (PDV_GLO_DebugLevel.GetValueInt() >= level)
        Debug.Trace("[PDV_T3DailyLowHealthSaveEffect] " + traceText)
    endIf
EndFunction
