Scriptname PDV_DunmerAncestralUrn extends ObjectReference
{Usable inventory urn token for Dunmer ancestor prayer. The MISC urn routes the prayer when
used from the inventory (OnEquipped fires for MISC items on inventory activate); the retired
model-less BOOK token routed via OnRead and is removed by EnsureDunmerAncestralUrn migration.}

Idle Property PDV_IdlePray Auto
{Optional pray idle played once the menus close. Safe to leave unfilled.}

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

    if bus && PDV_IdlePray && playerRef
        if !playerRef.IsInCombat() && !playerRef.IsWeaponDrawn() && !playerRef.IsSneaking() && playerRef.GetSitState() == 0
            Utility.Wait(0.2)
            playerRef.PlayIdle(PDV_IdlePray)
        endIf
    endIf

    _prayBusy = false
EndFunction
