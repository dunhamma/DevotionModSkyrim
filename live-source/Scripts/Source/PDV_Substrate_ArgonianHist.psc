;/ 
    PDV_Substrate_ArgonianHist.psc
    PlayerDevotion - Argonian cultural-practice substrate
    -----------------------------------------------------------------------
    Cultural practice is a dedicated daily-budget metric. Hist, People, and
    Void remain independent relation ledgers; relation changes do not derive
    or overwrite the cultural metric.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Substrate_ArgonianHist extends PDV_SubstrateBase

Float Property HistMaintenanceDelta = 5.0 Auto ; Relation delta, not metric gain.
Float Property PeopleSupportDelta = 4.0 Auto ; Relation delta, not metric gain.
Float Property BedOfChoiceDelta = 3.0 Auto ; Relation delta, not metric gain.
Float Property VoidSignalDelta = 2.0 Auto ; Relation delta, not metric gain.
Float Property HistPeopleBufferWeight = 0.25 Auto
Float Property HistVoidStabilizerWeight = 0.10 Auto
Float Property HistDawnDecay = 1.0 Auto
Float Property HistDawnGraceDays = 3.0 Auto
Float Property HistNonCurseFloor = 20.0 Auto
Float Property CulturalDawnDecay = 1.0 Auto
Float Property CulturalDawnGraceDays = 3.0 Auto
Float Property CulturalNonCurseFloor = 20.0 Auto
Int Property VoidActivationSignalsRequired = 3 Auto
Int Property CulturalMetricMigrationVersion = 1 AutoReadOnly

Int Property HIST_POSTURE_NORMAL = 0 AutoReadOnly
Int Property HIST_POSTURE_DISTANT = 1 AutoReadOnly
Int Property HIST_POSTURE_STRAINED = 2 AutoReadOnly
Int Property HIST_POSTURE_SILENCED = 3 AutoReadOnly
Int Property HIST_POSTURE_CORRUPTED = 4 AutoReadOnly

Bool Function IsAuthenticSubstrateSource(String sourceId)
    return sourceId == "argonian_hist" || sourceId == "argonian_people" || sourceId == "argonian_bed" || sourceId == "argonian_void" || sourceId == "argonian_cooked_meal" || sourceId == "argonian_sacred_water"
EndFunction

Function RecordHistMaintenance(String reason)
    RecordHistMaintenanceScaled(1.0, reason)
EndFunction

Function RecordHistMaintenanceScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Hist maintenance blocked for " + reason)
        return
    endIf

    Float delta = HistMaintenanceDelta * normalizedMultiplier
    SetHistRelation(GetHistRelation() + delta, "hist_maintenance_" + reason)
    StampHistMaintenance(reason)
    Float awarded = TryAwardSubstrateDayCredit("argonian_hist", reason, 1.0)
    Trace(2, "Hist maintenance recorded with relation delta " + delta + " and daily credit " + awarded)
EndFunction

Function RecordPeopleSupport(String reason)
    RecordPeopleSupportScaled(1.0, reason)
EndFunction

Function RecordPeopleSupportScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "People support blocked for " + reason)
        return
    endIf

    Float delta = PeopleSupportDelta * normalizedMultiplier
    SetPeopleRelation(GetPeopleRelation() + delta, "people_support_" + reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastPeopleEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("argonian_people", reason, 1.0)
    Trace(2, "People support recorded with relation delta " + delta + " and daily credit " + awarded)
EndFunction

Function RecordBedOfChoiceReturn(String reason)
    RecordBedOfChoiceReturnScaled(1.0, reason)
EndFunction

Function RecordBedOfChoiceReturnScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Bed-of-choice return blocked for " + reason)
        return
    endIf

    Float delta = BedOfChoiceDelta * normalizedMultiplier
    SetPeopleRelation(GetPeopleRelation() + delta, "bed_of_choice_" + reason)
    ; Rooted Rest is earned through twelve separate devotional days at the
    ; declared bed.  A sleep loop must never compress that history into one day.
    Int sleepStamp = GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepDay") != sleepStamp
        StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 1)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepDay", sleepStamp)
    endIf
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceLastSleep", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("argonian_bed", reason, 1.0)
    Trace(2, "Bed-of-choice return recorded with relation delta " + delta + " and daily credit " + awarded)
EndFunction

; Hist-maintenance timing is independent of the relation magnitude and the
; cultural-practice day credit.  Sacred water and Sleeping Tree Sap are both
; genuine Hist contact, so they use this same clock without receiving the
; routine +5 maintenance relation pulse.
Function StampHistMaintenance(String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastHistEvent", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceDay", GetDevotionalDay())
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp", GetDevotionalDay() + 2)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.MaintenanceStampVersion", 1)
    Trace(3, "Hist maintenance clock stamped for " + reason)
EndFunction

Function RecordVoidSignal(String reason)
    RecordVoidSignalScaled(1.0, reason)
EndFunction

Function RecordVoidSignalScaled(Float multiplier, String reason)
    Float normalizedMultiplier = ClampSignalMultiplier(multiplier)
    if normalizedMultiplier <= 0.0
        Trace(2, "Void signal blocked for " + reason)
        return
    endIf

    Float delta = VoidSignalDelta * normalizedMultiplier
    SetVoidRelation(GetVoidRelation() + delta, "void_signal_" + reason)
    StorageUtil.AdjustIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", 1)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastVoidEvent", Utility.GetCurrentGameTime())
    Float awarded = TryAwardSubstrateDayCredit("argonian_void", reason, 1.0)
    Trace(2, "Void signal recorded with relation delta " + delta + " and daily credit " + awarded)
EndFunction

; Cultural practices such as the first cooked meal affect the shared practice
; metric only. They do not invent Hist piety or move the People/Void ledgers.
Function RecordCulturalPractice(String sourceId, String reason)
    Float awarded = TryAwardSubstrateDayCredit(sourceId, reason, 1.0)
    Trace(2, "Cultural practice recorded with daily credit " + awarded + " (" + sourceId + ")")
EndFunction

Function EnsureHistMaintenanceStampEncoding()
    if StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.MaintenanceStampVersion") >= 1
        return
    endIf

    ; Legacy saves stored a raw devotional day, where zero was ambiguous. A
    ; nonzero event time proves that the raw day was an actual maintenance act.
    if StorageUtil.GetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastHistEvent") > 0.0
        Int legacyDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceDay")
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp", legacyDay + 2)
    endIf
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.MaintenanceStampVersion", 1)
EndFunction

Bool Function HasHistMaintenance()
    EnsureHistMaintenanceStampEncoding()
    return StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp") > 0
EndFunction

Int Function GetLastHistMaintenanceDevotionalDay()
    EnsureHistMaintenanceStampEncoding()
    Int stamp = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp")
    if stamp <= 0
        return -1
    endIf
    return stamp - 2
EndFunction

Function ProcessHistDistanceDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = GetDevotionalDay()
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay")
    if lastDecayDay == currentDay
        return
    endIf

    EnsureHistMaintenanceStampEncoding()
    Int maintenanceStamp = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp")
    Int lastMaintenanceDay = maintenanceStamp - 2
    Int dayDelta = currentDay - lastMaintenanceDay
    if maintenanceStamp <= 0
        dayDelta = (HistDawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (HistDawnGraceDays as Int)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", currentDay)
        return
    endIf

    Float floorValue = HistNonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldHist = GetHistRelation()
    if oldHist <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", currentDay)
        return
    endIf

    Int decayDays = currentDay - lastDecayDay
    Int graceEndDay = lastMaintenanceDay + (HistDawnGraceDays as Int)
    if lastDecayDay < graceEndDay
        decayDays = currentDay - graceEndDay
    endIf
    if decayDays < 1
        decayDays = 1
    endIf

    Float newHist = oldHist - (HistDawnDecay * decayDays)
    if newHist < floorValue
        newHist = floorValue
    endIf

    SetHistRelation(newHist, "hist_distance_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", currentDay)
    Trace(2, "Hist distance dawn decay " + oldHist + " -> " + newHist)
EndFunction

Function ProcessCulturalPracticeDawn(Bool curseActive, String reason)
    if !IsOriginActive()
        return
    endIf

    Int currentDay = GetDevotionalDay()
    Int lastDecayDay = StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastCulturalDecayDay", -1)
    if lastDecayDay == currentDay
        return
    endIf

    Int lastMaintenanceDay = GetLastAcceptedDevotionalDay()
    Int dayDelta = currentDay - lastMaintenanceDay
    if !HasAcceptedSubstrateCredit()
        dayDelta = (CulturalDawnGraceDays as Int) + 1
    endIf

    if dayDelta <= (CulturalDawnGraceDays as Int)
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastCulturalDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Float floorValue = CulturalNonCurseFloor
    if curseActive
        floorValue = MetricMin
    endIf

    Float oldPractice = GetMetric()
    if oldPractice <= floorValue
        StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastCulturalDecayDay", currentDay)
        RecomputeSubstrateTier()
        return
    endIf

    Int graceEndDay = lastMaintenanceDay + (CulturalDawnGraceDays as Int)
    if !HasAcceptedSubstrateCredit()
        graceEndDay = currentDay - 1
    endIf
    Int decayDays = currentDay - lastDecayDay
    if lastDecayDay < graceEndDay
        decayDays = currentDay - graceEndDay
    endIf
    if decayDays < 1
        decayDays = 1
    endIf
    Float newPractice = oldPractice - (CulturalDawnDecay * decayDays)
    if newPractice < floorValue
        newPractice = floorValue
    endIf

    SetMetric(newPractice, "argonian_cultural_dawn_" + reason)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastCulturalDecayDay", currentDay)
    Trace(2, "Cultural practice dawn decay " + oldPractice + " -> " + newPractice)
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
    return "metric=" + GetMetric() + ";hist=" + GetHistRelation() + ";people=" + GetPeopleRelation() + ";void=" + GetVoidRelation() + ";tier=" + GetSubstrateTier() + ";posture=" + GetHistPostureLabel() + ";sithis=" + GetSithisSignalCount() + "/" + VoidActivationSignalsRequired + ";bed=" + StorageUtil.GetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
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
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastMaintenanceStamp", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.MaintenanceStampVersion", 1)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastDecayDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.LastCulturalDecayDay", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepDay", 0)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceLastSleep", 0.0)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Posture", HIST_POSTURE_NORMAL)
    StorageUtil.SetIntValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.CulturalMetricMigrationVersion", CulturalMetricMigrationVersion)
    Trace(2, "ResetPilotForDebug")
EndFunction

Function SetHistRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Hist", ClampFloat(value, MetricMin, MetricMax))
    Trace(3, "Hist relation set (" + reason + ")")
EndFunction

Function SetPeopleRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.People", ClampFloat(value, MetricMin, MetricMax))
    Trace(3, "People relation set (" + reason + ")")
EndFunction

Function SetVoidRelation(Float value, String reason)
    StorageUtil.SetFloatValue(GetSubstrateForm(), "PDV.Substrate.ArgonianHist.Void", ClampFloat(value, MetricMin, MetricMax))
    Trace(3, "Void relation set (" + reason + ")")
EndFunction

Function RefreshCompositeMetric(String reason)
    Trace(1, "RefreshCompositeMetric is retired; cultural practice is event-fed (" + reason + ")")
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
