Scriptname PDV_AltmerPracticeFocus extends ObjectReference
{Usable inventory focus for Altmer daily practice. Clicking it in the inventory fires OnEquipped
(MISC items route inventory-activate that way) and performs the day's devotional act.

P14 (2026-08-04). WHY THIS EXISTS: every Altmer lane except Trinimac's was built on a FINITE world
pool -- curated books are one-shot, Words of Power and map markers are bounded, skills cap at 100.
A scholar-focused player ran out of ways to practise. This is the one act that never exhausts and
needs no inventory bookkeeping, so no lane is ever left with nothing to do.

MUST STAY MISC. The retired model-less BOOK token crashed the book menu on read; the Dunmer urn
(PDV_DunmerAncestralUrn) records that lesson and this script is modelled on it.}

Idle Property PDV_IdlePray Auto
{Idle for the prayer lanes (Auri-El / broad / Trinimac). Vanilla IdlePray 06F300. Safe to leave unfilled.}

Idle Property PDV_IdleStudy Auto
{Idle for the scholar lanes (Magnus / Xarxes / Syrabane). Vanilla IdleBook_Reading 0BB052. Safe to leave unfilled.}

Sound Property PDV_SND_Practice Auto
{Optional cue. Must be a SOUN SoundMarker (e.g. PDV_SND_Chime), never a SNDR descriptor. Safe to leave unfilled.}

float Property PracticeIdleSeconds = 4.0 Auto
{How long the idle holds before the script releases it back to normal movement.}

bool _practiceBusy = false

Event OnEquipped(Actor akActor)
    if akActor != Game.GetPlayer()
        return
    endIf
    RoutePractice(akActor)
EndEvent

Function RoutePractice(Actor playerRef)
    if _practiceBusy
        return
    endIf
    _practiceBusy = true

    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if !bus
        Debug.Trace("[PDV] Altmer practice focus skipped: PDV_EventBus could not be resolved.")
        _practiceBusy = false
        return
    endIf

    ; The manager owns every gate -- origin, curse, the once-per-day cap, and which lane's signal
    ; this feeds. It also tells us which idle suits the active patron, so the gesture matches the
    ; practice: a prayer for the foundation lanes, a reading pose for the scholars.
    Int idleKind = bus.RouteAltmerPracticeFocus()

    if playerRef
        ; The equip event fires while the inventory menu is still open; this wait resumes only once
        ; the game unpauses, so the cue and gesture land in-world rather than inside the menu.
        Utility.Wait(0.2)

        if PDV_SND_Practice
            PDV_SND_Practice.Play(playerRef)
        endIf

        Idle chosenIdle = PDV_IdlePray
        if idleKind == 1 && PDV_IdleStudy
            chosenIdle = PDV_IdleStudy
        endIf

        if chosenIdle && !playerRef.IsInCombat() && !playerRef.IsWeaponDrawn() && !playerRef.IsSneaking() && playerRef.GetSitState() == 0
            if playerRef.PlayIdle(chosenIdle)
                ; These are looping idles that movement input alone does not break, so hold for a
                ; short beat and then force the exit rather than trapping the player in the pose.
                Utility.Wait(PracticeIdleSeconds)
                Debug.SendAnimationEvent(playerRef, "IdleForceDefaultState")
            endIf
        endIf
    endIf

    _practiceBusy = false
EndFunction
