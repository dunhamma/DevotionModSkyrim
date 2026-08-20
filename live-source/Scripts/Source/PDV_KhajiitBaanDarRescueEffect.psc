;/
    PDV_KhajiitBaanDarRescueEffect.psc
    Baan Dar Champion specialization of the shared daily rescue effect.
/;

Scriptname PDV_KhajiitBaanDarRescueEffect extends PDV_T3DailyLowHealthSaveEffect

PDV__ManagerQuest Property PDV_Manager Auto

Bool Function HasRuntimeEligibility()
    Actor playerRef = Game.GetPlayer()
    return PDV_Manager && playerRef && PDV_Manager.OriginRuntime.HandleContextualQuery("baandar-rescue-eligible", "baan-dar-rescue", playerRef) == 1
EndFunction

Float Function GetRestoreTargetPercent()
    return 0.50
EndFunction
