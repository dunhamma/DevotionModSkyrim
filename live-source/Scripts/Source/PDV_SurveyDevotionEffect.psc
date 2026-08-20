;/
    PDV_SurveyDevotionEffect.psc
    PlayerDevotion - player survey lesser-power effect
    -----------------------------------------------------------------------
    Shows the manager-owned thematic devotion readout. This effect is a
    display surface only: it never writes piety, patron, favor, or curse state.
    -----------------------------------------------------------------------
/;

Scriptname PDV_SurveyDevotionEffect extends ActiveMagicEffect

PDV__ManagerQuest Property PDV_Manager Auto
Actor Property PlayerREF Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Actor playerActor = GetPlayerActor()
    if !playerActor
        Trace(1, "Survey skipped: player actor unavailable.")
        return
    endIf

    if akTarget != playerActor && akCaster != playerActor
        Trace(1, "Survey skipped: effect did not target or come from player.")
        return
    endIf

    if !PDV_Manager
        Debug.MessageBox("Devotion is still starting up.")
        Trace(1, "Survey skipped: PDV_Manager not assigned.")
        return
    endIf

    Trace(1, "Survey readout displayed.")
    Debug.MessageBox(PDV_Manager.Prisma.GetSurveyDevotionText())
EndEvent

Actor Function GetPlayerActor()
    if PlayerREF
        return PlayerREF
    endIf

    return Game.GetPlayer()
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] SurveyDevotionEffect: " + traceText)
    endIf
EndFunction
