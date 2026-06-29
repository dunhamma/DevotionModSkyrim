Scriptname PDV_ShrinePrayerEffect extends ActiveMagicEffect
{Hidden PDV signal attached to neutralized vanilla shrine blessing spells.
 It routes a once-per-day prayer to the named deity ledger, plus optional
 aspect-pair ledgers such as Kynareth -> Kyne.}

String Property PrimaryDeityName Auto
String Property SecondaryDeityName = "" Auto
String Property TertiaryDeityName = "" Auto
String Property ShrineLabel = "" Auto
String Property SourceId = "" Auto
String Property OncePerDayKey = "" Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || akTarget != playerRef
        return
    endIf

    if OncePerDayKey != ""
        Float nowTime = Utility.GetCurrentGameTime()
        Float lastTime = StorageUtil.GetFloatValue(None, OncePerDayKey)
        if lastTime > 0.0 && (nowTime - lastTime) < 1.0
            return
        endIf
        StorageUtil.SetFloatValue(None, OncePerDayKey, nowTime)
    endIf

    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteShrinePrayer(PrimaryDeityName, SecondaryDeityName, TertiaryDeityName, ShrineLabel, SourceId)
    endIf
EndEvent
