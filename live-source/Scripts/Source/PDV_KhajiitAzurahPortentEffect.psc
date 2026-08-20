;/
    PDV_KhajiitAzurahPortentEffect.psc
    Champion-only activation gate for Azurah's Portent.
/;

Scriptname PDV_KhajiitAzurahPortentEffect extends ActiveMagicEffect

PDV__ManagerQuest Property PDV_Manager Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if PDV_Manager && akTarget == Game.GetPlayer()
        PDV_Manager.OriginRuntime.TryUseKhajiitAzurahPortent(akTarget)
    endIf
EndEvent

