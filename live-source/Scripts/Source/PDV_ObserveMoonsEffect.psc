;/
    PDV_ObserveMoonsEffect.psc
    PlayerDevotion - Khajiit moon-observation entry effect
    -----------------------------------------------------------------------
    Thin, event-driven entrypoint. The manager owns validation, timing,
    interruption handling, phase selection, message choice, and rewards.
    -----------------------------------------------------------------------
/;

Scriptname PDV_ObserveMoonsEffect extends ActiveMagicEffect

PDV__ManagerQuest Property PDV_Manager Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Actor playerActor = Game.GetPlayer()
    if !playerActor
        Debug.Trace("[PDV][MOON_RITE] skipped start: player_unavailable")
        return
    endIf

    ; Match Survey Devotion's player-owned lesser-power contract.  The engine
    ; may supply the player as caster rather than target for self powers.
    if akTarget != playerActor && akCaster != playerActor
        Debug.Trace("[PDV][MOON_RITE] skipped start: non_player_effect")
        return
    endIf

    if !PDV_Manager
        Debug.Trace("[PDV][MOON_RITE] skipped start: manager_unavailable")
        return
    endIf

    Int observationToken = PDV_Manager.BeginKhajiitMoonObservation(playerActor)
    if observationToken > 0
        Utility.Wait(2.0)
        PDV_Manager.ProcessPendingKhajiitMoonObservation(observationToken)
    endIf
EndEvent
