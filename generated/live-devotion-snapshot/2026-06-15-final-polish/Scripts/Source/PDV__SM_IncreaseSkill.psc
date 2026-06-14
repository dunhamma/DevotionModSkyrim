;/
    PDV__SM_IncreaseSkill.psc
    Thin Increase Skill Story Manager receiver.
/;

Scriptname PDV__SM_IncreaseSkill extends Quest

PDV_ActionRouter Property PDV_Router Auto

Event OnStoryIncreaseSkill(String asSkill)
    if PDV_Router
        PDV_Router.HandleStoryIncreaseSkill(asSkill)
    else
        Debug.Trace("[PDV] PDV__SM_IncreaseSkill: PDV_Router not assigned.")
    endIf

    FinishReceiver()
EndEvent

Function FinishReceiver()
    Stop()
    Reset()
EndFunction
