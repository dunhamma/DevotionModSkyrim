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
    if !PDV_Manager || !akTarget
        return
    endIf

    Int observationToken = PDV_Manager.BeginKhajiitMoonObservation(akTarget)
    if observationToken > 0
        Utility.Wait(5.0)
        PDV_Manager.ProcessPendingKhajiitMoonObservation(observationToken)
    endIf
EndEvent
