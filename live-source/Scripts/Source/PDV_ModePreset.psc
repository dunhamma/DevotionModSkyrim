;/
    PDV_ModePreset.psc
    PlayerDevotion - experience mode preset resolver
    -----------------------------------------------------------------------
    OVERVIEW
    Single owner of the two-mode preset table for Wayfarer's Path (easy)
    and Pilgrim's Path (hard, default). Other scripts call these helpers
    and never hard-code mode-aware scalars.

    DESIGN NOTES
    - StorageUtil PDV.Mode on PDV__ManagerQuest holds the canonical value.
    - Mirror PDV_GLO_Mode is for CK Condition reads only.
    - Default is 0 (Pilgrim's Path) so existing saves preserve authored
      behavior the first time the new resolver runs.
    -----------------------------------------------------------------------
/;

Scriptname PDV_ModePreset extends Quest

PDV__ManagerQuest Property PDV_Manager Auto
GlobalVariable Property PDV_GLO_Mode Auto

Int Property MODE_PILGRIM = 0 AutoReadOnly
Int Property MODE_WAYFARER = 1 AutoReadOnly

Float Property WAYFARER_GAIN = 1.25 AutoReadOnly
Float Property WAYFARER_DAILY_CAP = 1.5 AutoReadOnly
Float Property WAYFARER_DECAY = 0.5 AutoReadOnly
Float Property WAYFARER_GRACE = 2.0 AutoReadOnly
Float Property WAYFARER_CHEAP_WEIGHT = 0.5 AutoReadOnly

Int Function GetMode()
    if !PDV_Manager
        return MODE_PILGRIM
    endIf
    return StorageUtil.GetFloatValue(PDV_Manager as Form, "PDV.Mode") as Int
EndFunction

Function SetMode(Int newMode)
    if !PDV_Manager
        return
    endIf

    Int clamped = newMode
    if clamped != MODE_WAYFARER
        clamped = MODE_PILGRIM
    endIf

    StorageUtil.SetFloatValue(PDV_Manager as Form, "PDV.Mode", clamped as Float)

    if PDV_GLO_Mode
        PDV_GLO_Mode.SetValue(clamped as Float)
    endIf
EndFunction

String Function GetModeLabel()
    if GetMode() == MODE_WAYFARER
        return "Wayfarer's Path"
    endIf
    return "Pilgrim's Path"
EndFunction

Float Function GainMultiplier()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_GAIN
    endIf
    return 1.0
EndFunction

Float Function DailyCapScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_DAILY_CAP
    endIf
    return 1.0
EndFunction

Float Function DecayScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_DECAY
    endIf
    return 1.0
EndFunction

Float Function GraceScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_GRACE
    endIf
    return 1.0
EndFunction

Bool Function AllowCheapRepeatables()
    return GetMode() == MODE_WAYFARER
EndFunction

Float Function CheapRepeatableWeight()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_CHEAP_WEIGHT
    endIf
    return 0.0
EndFunction
