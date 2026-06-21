Scriptname PDV__MainQuest extends Quest

; -----------------------------------------------------------------------
; PDV bootstrap quest. RunOnce + Start Game Enabled.
;
; Phase 4 adds real one-shot bootstrap work here: detect the player's
; origin race, seed the proof-slice deity state, then get out of the way.
; Runtime ledger logic still lives in PDV__ManagerQuest.
; -----------------------------------------------------------------------

PDV_Origin Property PDV_OriginQuest Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Event OnInit()
    Trace(1, "MainQuest bootstrap initialized.")
    if !CheckPapyrusUtilDependency()
        return
    endIf
    Trace(2, "Origin bootstrap deferred to player load/sleep ingress.")
EndEvent

Bool Function CheckPapyrusUtilDependency()
    Int nativeVersion = PapyrusUtil.GetVersion()
    Int scriptVersion = PapyrusUtil.GetScriptVersion()

    if nativeVersion <= 0 || scriptVersion <= 0
        Debug.Trace("[PDV] MainQuest: PapyrusUtil dependency check failed. Native=" + nativeVersion + ", script=" + scriptVersion)
        Debug.MessageBox("Devotion requires PapyrusUtil. Install or enable PapyrusUtil, then start a new game or reload before PDV initializes.")
        return false
    endIf

    Trace(2, "PapyrusUtil dependency verified. Native=" + nativeVersion + ", script=" + scriptVersion)
    return true
EndFunction

Function InitializeBootstrap()
    if !PDV_OriginQuest
        Trace(1, "InitializeBootstrap skipped: PDV_OriginQuest not assigned.")
        return
    endIf

    PDV_OriginQuest.InitializeOrigin()
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] MainQuest: " + traceText)
    endIf
EndFunction
