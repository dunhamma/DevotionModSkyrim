;/
    PDV_SacredPlace.psc
    PlayerDevotion - V3 Structural Skeleton sacred place helper
    -----------------------------------------------------------------------
    Shared location-memory helper for Argonian bed-of-choice, Khajiit road
    homes, and Orc community investment. Inert until attached to a CK record.
    -----------------------------------------------------------------------
/;

Scriptname PDV_SacredPlace extends Quest

String Property PlaceName Auto
Int Property MaxLocations = 1 Auto
Int Property RequiredOriginRace Auto

ObjectReference[] Property DesignatedLocations Auto
Float[] Property LastVisitTime Auto
Int[] Property InvestmentLevel Auto

Float Property VisitFrequencyDays = 7.0 Auto
Float Property DecayRatePerMiss = 5.0 Auto
Float Property RewardModifier = 1.0 Auto

GlobalVariable Property PDV_GLO_OriginRace Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

Float Function GetMissedVisitDecay()
    return StorageUtil.GetFloatValue(GetPlaceForm(), GetDecayKey())
EndFunction

Function DebugForceMissedVisitDecay(Float amount)
    if amount < 0.0
        amount = 0.0
    endIf

    StorageUtil.SetFloatValue(GetPlaceForm(), GetDecayKey(), amount)
    Trace(2, "DebugForceMissedVisitDecay " + PlaceName + " = " + amount)
EndFunction

Function DesignateLocation(ObjectReference locationRef)
    if !locationRef
        Trace(1, "DesignateLocation skipped: no location ref.")
        return
    endIf

    Int slotIndex = FindLocationSlot(locationRef)
    if slotIndex < 0
        slotIndex = FindEmptySlot()
    endIf
    if slotIndex < 0
        slotIndex = 0
    endIf

    if slotIndex >= 0 && slotIndex < DesignatedLocations.Length
        DesignatedLocations[slotIndex] = locationRef
        SetLastVisit(slotIndex, Utility.GetCurrentGameTime())
        Trace(2, "Designated " + PlaceName + " slot " + slotIndex)
    endIf
EndFunction

Function RecordVisit(ObjectReference locationRef)
    Int slotIndex = FindLocationSlot(locationRef)
    if slotIndex < 0
        Trace(3, "RecordVisit ignored untracked location for " + PlaceName)
        return
    endIf

    SetLastVisit(slotIndex, Utility.GetCurrentGameTime())
    Trace(2, "Recorded visit for " + PlaceName + " slot " + slotIndex)
EndFunction

Function ProcessDecay()
    if !IsOriginActive()
        return
    endIf

    Float now = Utility.GetCurrentGameTime()
    Int i = 0
    Int count = GetSlotCount()

    while i < count
        if DesignatedLocations[i]
            Float lastVisit = GetLastVisit(i)
            if lastVisit > 0.0 && (now - lastVisit) > VisitFrequencyDays
                StorageUtil.SetFloatValue(GetPlaceForm(), GetDecayKey(), StorageUtil.GetFloatValue(GetPlaceForm(), GetDecayKey()) + DecayRatePerMiss)
                SetLastVisit(i, now)
                Trace(2, "Applied missed-visit decay for " + PlaceName + " slot " + i)
            endIf
        endIf
        i += 1
    endWhile
EndFunction

Float Function GetPlaceBonus()
    if !IsOriginActive()
        return 0.0
    endIf

    Float bonus = RewardModifier
    Int highestInvestment = GetHighestInvestmentLevel()
    if highestInvestment > 0
        bonus = bonus + (highestInvestment as Float)
    endIf

    return bonus
EndFunction

Bool Function IsOriginActive()
    if !PDV_GLO_OriginRace
        return False
    endIf

    return PDV_GLO_OriginRace.GetValueInt() == RequiredOriginRace
EndFunction

Int Function FindLocationSlot(ObjectReference locationRef)
    if !locationRef
        return -1
    endIf

    Int i = 0
    Int count = GetSlotCount()
    while i < count
        if DesignatedLocations[i] == locationRef
            return i
        endIf
        i += 1
    endWhile

    return -1
EndFunction

Int Function FindEmptySlot()
    Int i = 0
    Int count = GetSlotCount()
    while i < count
        if !DesignatedLocations[i]
            return i
        endIf
        i += 1
    endWhile

    return -1
EndFunction

Int Function GetSlotCount()
    Int count = MaxLocations
    if DesignatedLocations.Length < count
        count = DesignatedLocations.Length
    endIf
    if LastVisitTime.Length < count
        count = LastVisitTime.Length
    endIf

    return count
EndFunction

Float Function GetLastVisit(Int slotIndex)
    if slotIndex >= 0 && slotIndex < LastVisitTime.Length
        return LastVisitTime[slotIndex]
    endIf

    return 0.0
EndFunction

Function SetLastVisit(Int slotIndex, Float gameTime)
    if slotIndex >= 0 && slotIndex < LastVisitTime.Length
        LastVisitTime[slotIndex] = gameTime
    endIf
EndFunction

Function ResetForDebug()
    Int i = 0

    while i < DesignatedLocations.Length
        DesignatedLocations[i] = None
        i += 1
    endWhile

    i = 0
    while i < LastVisitTime.Length
        LastVisitTime[i] = 0.0
        i += 1
    endWhile

    i = 0
    while i < InvestmentLevel.Length
        InvestmentLevel[i] = 0
        i += 1
    endWhile

    StorageUtil.SetFloatValue(GetPlaceForm(), GetDecayKey(), 0.0)
    Trace(2, "ResetForDebug " + PlaceName)
EndFunction

Int Function GetHighestInvestmentLevel()
    Int bestValue = 0
    Int i = 0
    while i < InvestmentLevel.Length
        if InvestmentLevel[i] > bestValue
            bestValue = InvestmentLevel[i]
        endIf
        i += 1
    endWhile

    return bestValue
EndFunction

String Function GetDecayKey()
    return "PDV.SacredPlace." + PlaceName + ".MissedVisitDecay"
EndFunction

Form Function GetPlaceForm()
    return Self as Form
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] SacredPlace: " + traceText)
    endIf
EndFunction
