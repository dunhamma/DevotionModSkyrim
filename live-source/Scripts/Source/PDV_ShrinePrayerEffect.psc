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

    Float nowTime = Utility.GetCurrentGameTime()
    if OncePerDayKey != ""
        Float lastTime = StorageUtil.GetFloatValue(None, OncePerDayKey)
        if lastTime > 0.0 && (nowTime - lastTime) < 1.0
            return
        endIf
    endIf

    ; B14 / fix-plan 4.4. The once-per-day charge used to be stamped HERE, before the
    ; event bus was even resolved -- so a prayer offered before the bus is wired (early
    ; after a load, the usual case) ate the day's charge and returned no piety and no
    ; feedback, and the player had no way to tell it had happened. The charge is now
    ; spent only after a route that can actually land: both the bus AND its manager must
    ; be present, since RouteShrinePrayer itself no-ops on a null PDV_Manager.
    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if !bus || !bus.PDV_Manager
        return
    endIf

    bus.RouteShrinePrayer(PrimaryDeityName, SecondaryDeityName, TertiaryDeityName, ShrineLabel, SourceId)

    if OncePerDayKey != ""
        StorageUtil.SetFloatValue(None, OncePerDayKey, nowTime)
    endIf
EndEvent
