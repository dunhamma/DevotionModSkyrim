Scriptname SKI_QuestBase extends Quest Hidden

Int Property CurrentVersion Auto Hidden

Event OnInit()
EndEvent

Function CheckVersion()
EndFunction

Int Function GetVersion()
    return 1
EndFunction

Event OnVersionUpdate(Int a_version)
EndEvent

Event OnGameReload()
EndEvent
