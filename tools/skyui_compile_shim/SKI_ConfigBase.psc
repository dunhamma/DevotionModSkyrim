Scriptname SKI_ConfigBase extends SKI_QuestBase

String[] Property Pages Auto
String Property ModName Auto

Int Property OPTION_FLAG_NONE = 0 AutoReadOnly
Int Property OPTION_FLAG_DISABLED = 1 AutoReadOnly
Int Property LEFT_TO_RIGHT = 1 AutoReadOnly
Int Property TOP_TO_BOTTOM = 2 AutoReadOnly

Function SetInfoText(String a_text)
EndFunction

Function ForcePageReset()
EndFunction

Function SetCursorFillMode(Int a_fillMode)
EndFunction

Function SetCursorPosition(Int a_position)
EndFunction

Function OnGameReload()
EndFunction

Bool Function ShowMessage(String a_message, Bool a_withCancel, String a_acceptLabel, String a_cancelLabel)
    return True
EndFunction

Function SetSliderDialogStartValue(Float a_value)
EndFunction

Function SetSliderDialogDefaultValue(Float a_value)
EndFunction

Function SetSliderDialogRange(Float a_minValue, Float a_maxValue)
EndFunction

Function SetSliderDialogInterval(Float a_value)
EndFunction

Function SetSliderOptionValue(Int a_option, Float a_value, String a_formatString, Bool a_noUpdate)
EndFunction

Int Function AddHeaderOption(String a_text, Int a_flags)
    return -1
EndFunction

Int Function AddTextOption(String a_text, String a_value, Int a_flags)
    return -1
EndFunction

Int Function AddEmptyOption()
    return -1
EndFunction

Int Function AddSliderOption(String a_text, Float a_value, String a_formatString, Int a_flags)
    return -1
EndFunction

Function OnConfigInit()
EndFunction

Function OnPageReset(String a_page)
EndFunction

Function OnOptionHighlight(Int a_option)
EndFunction

Function OnOptionSelect(Int a_option)
EndFunction

Function OnOptionSliderOpen(Int a_option)
EndFunction

Function OnOptionSliderAccept(Int a_option, Float a_value)
EndFunction
