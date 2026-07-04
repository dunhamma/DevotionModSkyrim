Scriptname PDV_DunmerAncestralUrn extends ObjectReference
{Usable inventory urn token for Dunmer ancestor prayer. The MISC urn routes the prayer when
used from the inventory (OnEquipped fires for MISC items on inventory activate); the retired
model-less BOOK token routed via OnRead and is removed by EnsureDunmerAncestralUrn migration.}

Idle Property PDV_IdlePray Auto
{Optional pray idle played once the menus close. Safe to leave unfilled.}

Sound Property PDV_SND_Prayer Auto
{Optional prayer sound cue. Must be a SOUN SoundMarker (e.g. PDV_SND_Chime), never a SNDR
descriptor. Safe to leave unfilled.}

float Property PrayIdleSeconds = 4.0 Auto
{How long the pray idle holds before the script releases it back to normal movement.}

bool _prayBusy = false

Event OnEquipped(Actor akActor)
    if akActor != Game.GetPlayer()
        return
    endIf
    RouteAncestorPrayer(akActor)
EndEvent

Event OnRead()
    ; Legacy BOOK-token path; kept so any stale save token still prays instead of dead-ending.
    RouteAncestorPrayer(Game.GetPlayer())
EndEvent

Function RouteAncestorPrayer(Actor playerRef)
    if _prayBusy
        return
    endIf
    _prayBusy = true

    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteDunmerPortableShrinePrayer()
    else
        Debug.Trace("[PDV] Dunmer ancestral urn skipped: PDV_EventBus could not be resolved.")
    endIf

    if bus && playerRef
        ; The equip event fires while the inventory menu is still open; this wait resumes only
        ; once the game unpauses, so the cue and gesture land in-world, not inside the menu.
        Utility.Wait(0.2)

        if PDV_SND_Prayer
            PDV_SND_Prayer.Play(playerRef)
        endIf

        if PDV_IdlePray && !playerRef.IsInCombat() && !playerRef.IsWeaponDrawn() && !playerRef.IsSneaking() && playerRef.GetSitState() == 0
            if playerRef.PlayIdle(PDV_IdlePray)
                ; IdlePray is a looping idle that movement input alone does not break, so hold
                ; it for a short beat and then force the exit rather than trapping the player.
                Utility.Wait(PrayIdleSeconds)
                Debug.SendAnimationEvent(playerRef, "IdleForceDefaultState")
            endIf
        endIf
    endIf

    _prayBusy = false
EndFunction
