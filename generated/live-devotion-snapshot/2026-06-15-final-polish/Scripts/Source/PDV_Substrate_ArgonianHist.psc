;/ 
    PDV_Substrate_ArgonianHist.psc
    PlayerDevotion - Argonian Hist/People/Void proving pilot
    -----------------------------------------------------------------------
    Concrete Phase 20 helper for the Saxhleel exile substrate. Hist remains
    primary, People buffers exile, and Void/Sithis stays thresholded.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_ArgonianHist extends PDV_SubstrateBase

Float Property HistMaintenanceDelta = 5.0 Auto
Float Property PeopleSupportDelta = 4.0 Auto
Float Property BedOfChoiceDelta = 3.0 Auto
Float Property VoidSignalDelta = 2.0 Auto
Float Property HistPeopleBufferWeight = 0.25 Auto
Float Property HistVoidStabilizerWeight = 0.10 Auto
Float Property HistDawnDecay = 1.0 Auto
Float Property HistDawnGraceDays = 3.0 Auto
Float Property HistNonCurseFloor = 20.0 Auto
Int Property VoidActivationSignalsRequired = 3 Auto

Int Property HIST_POSTURE_NORMAL = 0 AutoReadOnly
Int Property HIST_POSTURE_DISTANT = 1 AutoReadOnly
Int Property HIST_POSTURE_STRAINED = 2 AutoReadOnly
Int Property HIST_POSTURE_SILENCED = 3 AutoReadOnly
Int Property HIST_POSTURE_CORRUPTED = 4 AutoReadOnly

Function RecordHistMaintenance(String reason)
    RecordHistMaintenanceScaled(1.0, reason)
EndFunction

Function RecordHistMaintenanceScaled(Float multiplier, String reason)
    Float delta = HistMaintenanceDelta * ClampSignalMultiplier(multiplier)
    SetHistRelation(GetHistRelation() + delta, "hist_maintenance_" + reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastHistEvent", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceDay", Utility.GetCurrentGameTime() as Int)
    Trace(2, "Hist maintenance recorded with delta " + delta)
EndFunction

Function RecordPeopleSupport(String reason)
    RecordPeopleSupportScaled(1.0, reason)
EndFunction

Function RecordPeopleSupportScaled(Float multiplier, String reason)
    Float delta = PeopleSupportDelta * ClampSignalMultiplier(multiplier)
    SetPeopleRelation(GetPeopleRelation() + delta, "people_support_" + reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastPeopleEvent", Utility.GetCurrentGameTime())
    Trace(2, "People support recorded with delta " + delta)
EndFunction

Function RecordBedOfChoiceReturn(String reason)
    RecordBedOfChoiceReturnScaled(1.0, reason)
EndFunction

Function RecordBedOfChoiceReturnScaled(Float multiplier, String reason)
    Float delta = BedOfChoiceDelta * ClampSignalMultiplier(multiplier)
    SetPeopleRelation(GetPeopleRelation() + delta, "bed_of_choice_" + reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 1)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceLastSleep", Utility.GetCurrentGameTime())
    Trace(2, "Bed-of-choice return recorded with delta " + delta)
EndFunction

Function RecordVoidSignal(String reason)
    RecordVoidSignalScaled(1.0, reason)
EndFunction

Function RecordVoidSignalScaled(Float multiplier, String reason)
    Float delta = VoidSignalDelta * ClampSignalMultiplier(multiplier)
    SetVoidRelation(GetVoidRelation() + delta, "void_signal_" + reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", 1)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastVoidEvent", Utility.GetCurrentGameTime())
    Trace(2, "Void signal recorded with delta " + delta)
EndFunction

Function ProcessHistDistanceDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceDay")
    Int dayDelta = currentDay - lastMaintenanceDay
    if lastMaintenanceDay <= 0
        dayDelta = (HistDawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (HistDawnGraceDays as Int)
        return
    endIf

    Float floorValue = HistNonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldHist = GetHistRelation()
    if oldHist <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", currentDay)
        RefreshCompositeMetric(reason)
        return
    endIf

    Float newHist = oldHist - HistDawnDecay
    if newHist < floorValue
        newHist = floorValue
    endIf

    SetHistRelation(newHist, "hist_distance_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", currentDay)
    Trace(2, "Hist distance dawn decay " + oldHist + " -> " + newHist)
EndFunction

Function RefreshHistPosture(Int curseState, Bool dominationPressure, String reason)
    Int posture = HIST_POSTURE_NORMAL
    if curseState == 1
        posture = HIST_POSTURE_STRAINED
    elseIf curseState == 2
        posture = HIST_POSTURE_SILENCED
        if dominationPressure
            posture = HIST_POSTURE_CORRUPTED
        endIf
    elseIf GetHistRelation() <= HistNonCurseFloor
        posture = HIST_POSTURE_DISTANT
    endIf

    Int oldPosture = GetHistPosture()
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Posture", posture)
    if posture != oldPosture
        StorageUtil.SetIntValue(None, "PDV.ArgDream.Armed", 1)
        Trace(2, "Hist posture transition " + oldPosture + " -> " + posture + " armed a dream (" + reason + ")")
    endIf
    Trace(2, "Hist posture set to " + GetHistPostureLabel() + " (" + reason + ")")
EndFunction

; Hist dream lines keyed to posture. Pure flavor surface consumed by the
; manager's sleep-exit dispatcher; ASCII-only, short enough for the top-left
; notification lane.
String Function GetDreamTextForPosture(Int posture)
    Int variant = Utility.RandomInt(0, 2)
    if posture == HIST_POSTURE_DISTANT
        if variant == 0
            return "The dream is far away, a green light beyond cold water."
        elseIf variant == 1
            return "You hear the Hist as if through deep mud. The song is faint."
        endIf
        return "The root reaches for you and falls short. You wake reaching back."
    elseIf posture == HIST_POSTURE_STRAINED
        if variant == 0
            return "The dream tangles. Roots grip too tight, and the sap runs thin."
        elseIf variant == 1
            return "Something pulls between you and the trees. The song frays."
        endIf
        return "You dream of a storm bending the great trees. They call your name once."
    elseIf posture == HIST_POSTURE_SILENCED
        if variant == 0
            return "You dream of still black water. No root, no song, no name."
        elseIf variant == 1
            return "The marsh is empty in your sleep. Even the rain has stopped."
        endIf
        return "You call into the dream and nothing answers. The silence is total."
    elseIf posture == HIST_POSTURE_CORRUPTED
        if variant == 0
            return "The dream is wrong. The trees watch you with eyes that are not theirs."
        elseIf variant == 1
            return "Sap runs black in your sleep. The song plays backward."
        endIf
        return "Something else dreams through the root tonight. It knows your name."
    endIf

    if variant == 0
        return "You dream of warm sap and slow rivers. The root remembers your name."
    elseIf variant == 1
        return "In sleep the marsh breathes with you. The Hist hums, content."
    endIf
    return "You dream of home: reeds, rain, and the long memory of trees."
EndFunction

Float Function GetHistRelation()
    return StorageUtil.GetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Hist")
EndFunction

Float Function GetPeopleRelation()
    return StorageUtil.GetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.People")
EndFunction

Float Function GetVoidRelation()
    return StorageUtil.GetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Void")
EndFunction

Int Function GetSithisSignalCount()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount")
EndFunction

Bool Function IsVoidFullyActive()
    return GetSithisSignalCount() >= VoidActivationSignalsRequired
EndFunction

Int Function GetHistPosture()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Posture")
EndFunction

String Function GetHistPostureLabel()
    Int posture = GetHistPosture()
    if posture == HIST_POSTURE_DISTANT
        return "Distant"
    elseIf posture == HIST_POSTURE_STRAINED
        return "Strained"
    elseIf posture == HIST_POSTURE_SILENCED
        return "Silenced"
    elseIf posture == HIST_POSTURE_CORRUPTED
        return "Corrupted"
    endIf

    return "Normal"
EndFunction

String Function GetPilotSummary()
    return "hist=" + GetHistRelation() + ";people=" + GetPeopleRelation() + ";void=" + GetVoidRelation() + ";tier=" + GetSubstrateTier() + ";posture=" + GetHistPostureLabel() + ";sithis=" + GetSithisSignalCount() + "/" + VoidActivationSignalsRequired + ";bed=" + StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
EndFunction

Function ResetPilotForDebug()
    ResetForDebug()
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Hist", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.People", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Void", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastHistEvent", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastPeopleEvent", 0.0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastVoidEvent", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceLastSleep", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Posture", HIST_POSTURE_NORMAL)
    Trace(2, "ResetPilotForDebug")
EndFunction

Function SetHistRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Hist", ClampFloat(value, MetricMin, MetricMax))
    RefreshCompositeMetric(reason)
EndFunction

Function SetPeopleRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.People", ClampFloat(value, MetricMin, MetricMax))
    RefreshCompositeMetric(reason)
EndFunction

Function SetVoidRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Void", ClampFloat(value, MetricMin, MetricMax))
    RefreshCompositeMetric(reason)
EndFunction

Function RefreshCompositeMetric(String reason)
    Float composite = GetHistRelation() + (GetPeopleRelation() * HistPeopleBufferWeight)
    if IsVoidFullyActive()
        composite = composite + (GetVoidRelation() * HistVoidStabilizerWeight)
    endIf
    SetMetric(composite, "argonian_composite_" + reason)
EndFunction

Float Function ClampSignalMultiplier(Float multiplier)
    if multiplier < 0.0
        return 0.0
    endIf

    return multiplier
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] ArgonianHist: " + traceText)
    endIf
EndFunction
