Scriptname PDV_OriginRuntime_Argonian extends PDV_OriginRuntimeBase

; Argonian origin adapter (ORIGIN tranche 2). Lane functions moved verbatim from
; PDV_OriginRuntimeBase; only the virtual overrides below are new code, and each
; one delegates straight to the named lane function it replaces at the boundary
; (ADR: references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md).
;
; Hist / People / Void relations, sacred water, sap visions, bed-of-choice and
; the shadowscale lane all live here. This adapter owns no script variables.

; ---------------------------------------------------------------------------
; ADAPTER OVERRIDES -- the only new code in this file.
; ---------------------------------------------------------------------------

; -- Lifecycle --

Function EnsureRuntimeWiring()
    EnsureArgonianHistSapToken()
EndFunction

Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyArgonianCurseHandlers(oldState, newState, reason)
EndFunction

Function EvaluateAtDawn()
    RunDawnRefreshArgonianHist()
EndFunction

; ApplyInitialChoice is NOT overridden: the Argonian lane has no initial-choice
; handler (cultural practice is derived from the Hist substrate tier).

; -- State --

String Function GetOriginStateLabel()
    return GetArgonianCulturalPracticeLabel()
EndFunction

; DERIVED, not a verbatim delegate: the Argonian lane has no zero-argument named
; reader for the cultural-practice VALUE. The guard and the source below mirror
; GetArgonianCulturalPracticeLabel exactly, so label and value stay coherent.
Int Function GetOriginStateValue()
    if !Manager.PDV_ArgonianHistSubstrate
        return 0
    endIf

    return Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
EndFunction

String Function GetOriginSummary()
    return GetArgonianHistSummary()
EndFunction

String Function GetSurveyFragment()
    return GetArgonianSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsArgonianHistNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "cultural-practice"
        return GetArgonianCulturalPracticeLabel()
    elseIf detailKey == "hist-posture"
        return GetArgonianHistPostureLabel()
    elseIf detailKey == "hist-layer"
        return GetArgonianHistLayerText()
    elseIf detailKey == "hist-summary"
        return GetArgonianHistSummary()
    elseIf detailKey == "medallion-entries"
        return GetArgonianMedallionEntriesJson()
    elseIf detailKey == "survey"
        return GetArgonianSurveyText()
    elseIf detailKey == "medallion-sections"
        return MedallionSection("native", "Native worship", GetArgonianMedallionEntriesJson())
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "cultural-tier"
        return GetOriginStateValue()
    elseIf detailKey == "domination-pressure"
        if IsArgonianMolagBalDominationPressureActive()
            return 1
        endIf
        return 0
    endIf

    return 0
EndFunction

; -- Signals --
;
; The caller-composed "reason" ("eventbus_" + eventType, an MCM debug tag, a
; curated source key) is threaded through UNCHANGED to every handler that takes
; one. It is not the signalId and must never be substituted for it: reasons are
; player-visible in the Ledger and some lane bodies branch on the exact string.
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "hist-maintenance"
        HandleArgonianHistMaintenance(reason)
        return True
    elseIf signalId == "people-support"
        HandleArgonianPeopleSupport(reason)
        return True
    elseIf signalId == "void"
        HandleArgonianVoidSignal(reason)
        return True
    elseIf signalId == "bed-of-choice-return"
        HandleArgonianBedOfChoiceReturn(reason)
        return True
    elseIf signalId == "sap-vision"
        HandleArgonianSapVision()
        return True
    elseIf signalId == "shadowscale-kill"
        HandleArgonianShadowscaleKill(contextForm as Actor)
        return True
    elseIf signalId == "sacred-water-discovery"
        HandleArgonianSacredWaterDiscovery(contextForm as Location)
        return True
    elseIf signalId == "sacred-water-award"
        AwardArgonianSacredWater(magnitude as Int)
        return True
    elseIf signalId == "sanctuary-active"
        UpdateArgonianSanctuaryActive(contextForm as Location)
        return True
    elseIf signalId == "eldergleam-interior"
        TryArgonianEldergleamInterior()
        return True
    elseIf signalId == "near-water-maintenance"
        TryArgonianNearWaterMaintenance()
        return True
    elseIf signalId == "sithis-near-death"
        TryArgonianSithisNearDeathBurst(contextForm as Actor)
        return True
    elseIf signalId == "posture-dream"
        TryArgonianPostureDream(reason)
        return True
    elseIf signalId == "sleep-events"
        HandleArgonianSleepEvents(contextForm as Actor, reason)
        return True
    elseIf signalId == "hist-posture-refresh"
        RefreshArgonianHistPosture(reason)
        return True
    elseIf signalId == "domination-pressure-refresh"
        RefreshArgonianDominationPressure(reason)
        return True
    elseIf signalId == "domination-pressure-path"
        RefreshArgonianDominationPressureForPath(contextForm as PDV_DaedricPathBase, reason)
        return True
    elseIf signalId == "adaptation-clear"
        ClearArgonianAdaptation(contextForm as Actor)
        return True
    elseIf signalId == "adaptation-sync"
        SyncArgonianAdaptation(contextForm as Actor, IsArgonianOrigin())
        return True
    elseIf signalId == "hist-abandonment-minus"
        EmitHistAbandonmentMinus(reason)
        return True
    elseIf signalId == "hist-corruption-minus"
        EmitHistCorruptionMinus(reason)
        return True
    elseIf signalId == "hist-void-overreach-minus"
        EmitHistVoidOverreachMinus(reason)
        return True
    elseIf signalId == "sleep-stop"
        ; base HandlePlayerSleepStop dispatched this by origin index.
        HandleArgonianSleepEvents(contextForm as Actor, reason)
        return True
    elseIf signalId == "substrate-action"
        ; base HandleSubstrateActionEvent, Argonian arm. eventType rides the Float slot.
        Int eventType = magnitude as Int
        if Manager.PDV_ArgonianHistSubstrate
            if eventType == 333
                Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
                Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
                Manager.PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_cooked_meal", reason)
                Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier(), Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The first cooked meal kept Saxhleel practice.", "journal", GetArgonianCulturalPracticeLabel())
                return True
            endIf
        endIf
        return False
    endIf

    return False
EndFunction

; The every-change location hook. PDV_ActionRouter.HandleStoryChangeLocation calls
; this on EVERY change (before its one-shot discovery gate) so the Eldergleam
; interior catch can arm and disarm; akNewLocation is passed through rather than
; re-sampled from GetCurrentLocation(). The sacred-water DISCOVERY handler stays on
; the signal path, because its caller only reaches it past the seen-once gate.
Function HandleLocationChange(Form newLocation = None)
    UpdateArgonianSanctuaryActive(newLocation as Location)
EndFunction

; HandleContextualQuery is NOT overridden: no Argonian lane entry point returns a
; value its caller consumes.

; -- Upkeep --

Function SyncRaceRewards()
    SyncArgonianRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncArgonianNeglectSpell(IsArgonianHistNeglected())
EndFunction

; -- Presentation --

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
    ShowArgonianMessage(messageRecord, fallbackText, suppressModal)
EndFunction

; ShowOriginNotification is NOT overridden: ShowArgonianMessage is the lane's only
; notifier and it is curse-transition gated (it consumes the one-shot race curse
; surface). Routing a generic notification through it would suppress a curse
; message, so the base no-op is left in place rather than inventing a mapping.

; GetFormalCommitmentOfferMessage is NOT overridden: the Argonian lane has no
; per-deity formal-commitment Message record.

; ---------------------------------------------------------------------------
; LANE FUNCTIONS -- moved verbatim from PDV_OriginRuntimeBase. Bodies are
; byte-identical to the originals so the split stays provable against
; origin_golden.json. Do not edit them here.
; ---------------------------------------------------------------------------

String Function GetArgonianCulturalNextThresholdText(Float metric)
    if metric < 1.0
        return "Root Memory at 1"
    elseIf metric < 25.0
        return "River-Kept Practice at 25"
    elseIf metric < 75.0
        return "Rooted Adaptation at 75"
    endIf
    return "Rooted Adaptation"
EndFunction

String Function GetArgonianCulturalPracticeLabel()
    if !Manager.PDV_ArgonianHistSubstrate
        return "Practice quiet"
    endIf
    Int tierValue = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Rooted Adaptation"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_DEVOTED
        return "River-Kept Practice"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_SEEKER
        return "Root Memory"
    endIf
    return "Practice quiet"
EndFunction

Function HandleArgonianSleepEvents(Actor playerRef, String reason)
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    ; Identity = the CELL you sleep in (reliable at sleep-stop), not the bed
    ; furniture ref (GetFurnitureReference is None at OnSleepStart). Your home
    ; room becomes your place of rest.
    Int sleepCellId = 0
    Cell sleepCell = playerRef.GetParentCell()
    if sleepCell
        sleepCellId = sleepCell.GetFormID()
    endIf

    Bool menuShown = TryArgonianBedOfChoiceSleep(playerRef, sleepCellId, reason)
    if !menuShown
        menuShown = TryArgonianAdaptationRite(playerRef, sleepCellId, reason)
    endIf
    if !menuShown
        TryArgonianPostureDream(reason)
    endIf
EndFunction

Bool Function TryArgonianBedOfChoiceSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return false
    endIf

    ; Every bed cadence uses the shared 06:00 devotional day, encoded with
    ; +2 so day zero cannot be mistaken for an unset legacy value.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if declaredId != 0 && sleepCellId == declaredId
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
        HandleArgonianBedOfChoiceReturn("declared_" + reason)
        if Manager.PDV_SPEL_ArgonianRootedRest && StorageUtil.GetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount") >= 12
            Int rootedRestStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
            if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.RootedRestDay") != rootedRestStamp
                Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.RootedRestDay")
                Manager.PDV_SPEL_ArgonianRootedRest.Cast(playerRef, playerRef)
                Manager.SendPrismaToast("hist", "good", "Rooted rest", "You wake feeling rooted.")
                Manager.Trace(1, "[PDV][ARGONIAN_ROOTED_REST] granted day=" + Manager.LedgerRuntime.GetDevotionalDay())
            else
                Manager.Trace(2, "Argonian Rooted Rest suppressed: already granted this devotional day")
            endIf
        endIf
        return false
    endIf

    if !Manager.PDV_MESG_ArgonianMarkBed
        return false
    endIf

    Int declinedDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclineDay")
    if declinedDay > 0 && (todayStamp - declinedDay) < 3
        return false
    endIf

    Int candidateId = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateFormID")
    Int candidateDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateCount")
    if candidateId != sleepCellId
        candidateCount = 1
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", sleepCellId)
    elseIf candidateDay != todayStamp
        candidateCount += 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", candidateCount)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", todayStamp)

    if candidateCount < 3
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_ArgonianMarkBed.Show()
    ; B4 / fix-plan 3. -1 is "another menu was already up", not a decline. Stamping the
    ; 3-day suppression AND wiping the 3-sleep candidacy counters on a menu the player
    ; never saw threw away three nights of progress silently.
    if pressed < 0
        Manager.Trace(2, "Argonian bed-of-choice menu not shown (menu busy); candidacy kept.")
        return false
    endIf
    if pressed == 0
        SetArgonianHome(playerRef, sleepCellId, todayStamp, reason)
        Manager.SendPrismaToast("hist", "good", "Place of rest", "The Hist remembers it now.")
    else
        StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", todayStamp)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    endIf
    return true
EndFunction

Function SetArgonianHome(Actor playerRef, Int sleepCellId, Int devotionalDayStamp, String reason)
    if sleepCellId == 0
        return
    endIf

    ; Adaptation's older maturation clock remains a raw game-day value.  The
    ; declaration/candidate cadence above is the one governed by 06:00 days.
    Int today = Utility.GetCurrentGameTime() as Int

    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredDay", devotionalDayStamp)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    if Manager.PDV_ArgonianHistSubstrate
        StorageUtil.SetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 0)
        StorageUtil.SetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepDay", 0)
    endIf
    ; A chosen adaptation is permanent and follows the player to a new home.
    ; Only an unadapted player rolls a new maturation clock.
    if StorageUtil.GetIntValue(None, "PDV.Adapt.Active") == 0
        StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", today + Utility.RandomInt(10, 14) + 1)
    endIf
    Manager.Trace(2, "Argonian home declared: " + reason)
EndFunction

Function ClearArgonianAdaptation(Actor playerRef)
    if playerRef
        RemoveArgonianAdaptationSpells(playerRef)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", 0)
    StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", 0)
EndFunction

Bool Function TryArgonianAdaptationRite(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MESG_ArgonianAdaptRite || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return false
    endIf

    if Manager.PDV_ArgonianHistSubstrate.GetMetric() < Manager.ARGONIAN_REWARD_SIGNATURE_THRESHOLD
        return false
    endIf

    Bool rooted = false
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if sleepCellId != 0 && declaredId != 0 && sleepCellId == declaredId
        rooted = true
    elseIf Manager.PDV_FLST_ArgonianSacredWaters && playerRef.GetCurrentLocation() && Manager.PDV_FLST_ArgonianSacredWaters.HasForm(playerRef.GetCurrentLocation())
        rooted = true
    endIf
    if !rooted
        return false
    endIf

    ; One-time, permanent choice: the rite is only offered while no adaptation is
    ; active. Once taken it is kept for good -- no swap, no re-rite.
    if StorageUtil.GetIntValue(None, "PDV.Adapt.Active") != 0
        return false
    endIf

    ; Grow into the home over time: wait out the randomized 10-14 day clock rolled
    ; on the first qualifying sleep at this home. DueDay is stored as targetDay + 1
    ; so 0 unambiguously means "never armed" (StorageUtil ints default to 0).
    Int dueDay = StorageUtil.GetIntValue(None, "PDV.Adapt.DueDay")
    Int todayDay = Utility.GetCurrentGameTime() as Int
    if dueDay <= 0
        StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", todayDay + Utility.RandomInt(10, 14) + 1)
        return false
    endIf
    if todayDay < (dueDay - 1)
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_ArgonianAdaptRite.Show()
    if pressed < 0 || pressed > 3
        return true
    endIf

    ApplyArgonianAdaptation(playerRef, pressed)
    return true
EndFunction

Function ApplyArgonianAdaptation(Actor playerRef, Int adaptationIndex)
    RemoveArgonianAdaptationSpells(playerRef)
    Spell chosenAdaptation = GetArgonianAdaptationSpell(adaptationIndex)
    if !chosenAdaptation
        return
    endIf

    playerRef.AddSpell(chosenAdaptation, False)
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", adaptationIndex + 1)
    Manager.SendPrismaShiftToast("The Hist has reshaped you.", "", "hist")
    Manager.AppendBookOfDaysEntry("You took the Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its image.", Utility.GetCurrentGameTime() as Int, "reorientation", "hist", True, 3)
    Manager.Trace(2, "Argonian adaptation applied: " + adaptationIndex)
EndFunction

Function RemoveArgonianAdaptationSpells(Actor playerRef)
    Int adaptationIndex = 0
    while adaptationIndex < 4
        Spell adaptationSpell = GetArgonianAdaptationSpell(adaptationIndex)
        if adaptationSpell && playerRef.HasSpell(adaptationSpell)
            playerRef.RemoveSpell(adaptationSpell)
        endIf
        adaptationIndex += 1
    endWhile
EndFunction

Spell Function GetArgonianAdaptationSpell(Int adaptationIndex)
    if adaptationIndex == 0
        return Manager.PDV_SPEL_ArgonianAdapt_Claws
    elseIf adaptationIndex == 1
        return Manager.PDV_SPEL_ArgonianAdapt_Skin
    elseIf adaptationIndex == 2
        return Manager.PDV_SPEL_ArgonianAdapt_Sap
    elseIf adaptationIndex == 3
        return Manager.PDV_SPEL_ArgonianAdapt_Marsh
    endIf

    return None
EndFunction

Function SyncArgonianAdaptation(Actor playerRef, Bool isArgonian)
    Int activeAdaptation = StorageUtil.GetIntValue(None, "PDV.Adapt.Active")
    if activeAdaptation <= 0
        return
    endIf

    Spell activeSpell = GetArgonianAdaptationSpell(activeAdaptation - 1)
    if !activeSpell
        return
    endIf

    if isArgonian
        if !playerRef.HasSpell(activeSpell)
            playerRef.AddSpell(activeSpell, False)
        endIf
    else
        if playerRef.HasSpell(activeSpell)
            playerRef.RemoveSpell(activeSpell)
        endIf
    endIf
EndFunction

Function HandleArgonianSacredWaterDiscovery(Location discoveredLocation)
    if !discoveredLocation || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    if !Manager.PDV_FLST_ArgonianSacredWaters || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    ; Eldergleam's water and great tree are inside the cave, but the sanctuary
    ; LOCATION spans the exterior approach too. Arm the interior-cell catch
    ; instead of firing at the door; TryArgonianEldergleamInterior awards it
    ; once the player is actually in a cave cell.
    if discoveredLocation.GetFormID() == 0x000192AC
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 1)
        return
    endIf

    if !Manager.PDV_FLST_ArgonianSacredWaters.HasForm(discoveredLocation)
        return
    endIf

    AwardArgonianSacredWater(discoveredLocation.GetFormID())
EndFunction

Function AwardArgonianSacredWater(Int siteFormId)
    String seenKey = "PDV.ArgWaters.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.ArgWaters.Count", 1)

    Manager.PDV_ArgonianHistSubstrate.SetHistRelation(Manager.PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sacred_water")
    Manager.PDV_ArgonianHistSubstrate.StampHistMaintenance("sacred_water_" + siteFormId)
    Manager.PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_sacred_water", "sacred_water_" + siteFormId)
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, 1.0)
    endIf
    Debug.MessageBox("The water remembers. For one slow breath you stand in the marsh again, and the root speaks your name.")
    SendPrismaSubstrateToast("ArgonianHist", "water", "A water that remembers.", "hist", GetArgonianHistPostureLabel())
    Manager.AppendBookOfDaysEntry("A water that remembers.", Utility.GetCurrentGameTime() as Int, "substrate.act", "hist", False)

    if seenCount >= Manager.PDV_FLST_ArgonianSacredWaters.GetSize()
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.Milestone", 1)
        Debug.MessageBox("Every water that remembers has known you now. The marsh is never truly far -- the root holds you, wherever the road takes you.")
    endIf
    Manager.Trace(2, "Sacred water remembered: " + seenCount + " of " + Manager.PDV_FLST_ArgonianSacredWaters.GetSize())
EndFunction

Function UpdateArgonianSanctuaryActive(Location loc)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    Int active = 0
    if loc && loc.GetFormID() == 0x000192AC
        active = 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", active)
EndFunction

Function TryArgonianEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || StorageUtil.GetIntValue(None, "PDV.ArgWaters.Seen.103084") == 1
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 0)
        return
    endIf

    Actor argonianPlayer = Game.GetPlayer()
    Cell parentCell = argonianPlayer.GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        AwardArgonianSacredWater(0x000192AC)
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 0)
    endIf
EndFunction

Function TryArgonianNearWaterMaintenance()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Int pdvEncodedWaterDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.NearWaterDay") == pdvEncodedWaterDay
        return
    endIf

    Actor argonianPlayer = Game.GetPlayer()
    Cell waterCell = None
    if argonianPlayer
        waterCell = argonianPlayer.GetParentCell()
    endIf
    if !argonianPlayer || !argonianPlayer.IsSwimming() || !waterCell || waterCell.IsInterior()
        StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", 0.0)
        return
    endIf

    Float startedAt = StorageUtil.GetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime")
    if startedAt <= 0.0
        StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", Utility.GetCurrentRealTime())
        return
    endIf
    if Utility.GetCurrentRealTime() - startedAt < 10.0
        return
    endIf

    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.NearWaterDay")
    StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", 0.0)
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianNearWater")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, "near_water")
    RefreshArgonianHistPosture("near_water")
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The water remembers you.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian near-water Hist maintenance routed.")
EndFunction

Function HandleArgonianSapVision()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.SapVision") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.ArgWaters.SapVision", 1)
    Manager.PDV_ArgonianHistSubstrate.SetHistRelation(Manager.PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sleeping_tree_sap")
    Manager.PDV_ArgonianHistSubstrate.StampHistMaintenance("sleeping_tree_sap")
    Manager.PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_hist", "sleeping_tree_sap")
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, 1.0)
    endIf
    Debug.MessageBox("The sap is strange and far from home, but it resonates, and the Hist stirs within.")
    Manager.Trace(2, "Sleeping Tree Sap vision fired.")
EndFunction

Function HandleArgonianShadowscaleKill(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    if !Manager.PDV_ArgonianHistSubstrate || !Manager.PDV_SPEL_ArgonianShadowscaleVeil
        return
    endIf

    if !playerRef.IsSneaking()
        return
    endIf

    if !Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != Manager.ARGONIAN_FOCUS_VOID
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Shadowscale.LastInvisDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_ArgonianShadowscaleVeil.Cast(playerRef, playerRef)
    SendPrismaSubstrateToast("ArgonianHist", "shadowscale", "The shadow closes over you. The Void hides its own.", "void", Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Shadowscale.LastInvisDay")
    Manager.Trace(2, "Shadowscale veil fired on sneak kill.")
EndFunction

Function TryArgonianPostureDream(String reason)
    ; fix-plan 4.2: the dream cadence is sleep-triggered, so a raw-midnight day boundary
    ; crossed mid-sleep was exactly the case that let it fire two nights running.
    Int today = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int lastDreamDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.ArgDream.LastDay")
    if lastDreamDay > 0 && (today - lastDreamDay) < 2
        return
    endIf

    Int posture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
    Int dreamChance = 8
    if StorageUtil.GetIntValue(None, "PDV.ArgDream.Armed") == 1
        dreamChance = 60
    elseIf posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_NORMAL
        dreamChance = 12
    endIf

    if Utility.RandomInt(1, 100) > dreamChance
        return
    endIf

    String dreamText = Manager.PDV_ArgonianHistSubstrate.GetDreamTextForPosture(posture)
    SendPrismaSubstrateToast("ArgonianHist", "dream", dreamText, "hist", Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    StorageUtil.SetIntValue(None, "PDV.ArgDream.Armed", 0)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.ArgDream.LastDay")
    Manager.Trace(2, "Argonian posture dream fired (" + Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel() + ", " + reason + ")")
EndFunction

Function TryArgonianSithisNearDeathBurst(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_SPEL_ArgonianSithisNearDeathBurst
        return
    endIf
    if !playerRef.IsInCombat() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf
    if !Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != Manager.ARGONIAN_FOCUS_VOID || voidRelation < Manager.ARGONIAN_REWARD_T3_THRESHOLD
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.SithisNearDeathLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_ArgonianSithisNearDeathBurst.Cast(playerRef, playerRef)
    ; Requiem parity (2026-07-13): the cast StaminaRateMult burst is muted under
    ; Requiem, so pair it with a felt flat stamina restore (TryOrcCodeHolds
    ; pattern) - the Void lends an instant surge you can actually spend.
    playerRef.RestoreActorValue("Stamina", 100.0)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.SithisNearDeathLastDay")
    HandleArgonianVoidSignal("near_death_burst")
    Manager.Trace(2, "Argonian Sithis near-death burst fired.")
EndFunction

Function HandleArgonianHistMaintenance(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianHistMaintenance")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: the substrate carries the reward gating; a small honest +1 Hist pulse keeps
    ; the universal piety layer (decay/neglect/creed-loss) honest.
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    Manager.SurfaceP2BookReadNotice(reason, "The Hist remembers", "The reading carries the smell of home.")
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The Hist memory stirred.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian Hist maintenance routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianPeopleSupport(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianPeopleSupport")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordPeopleSupportScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "Your people were supported.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian People support routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianBedOfChoiceReturn(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianBedOfChoice")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordBedOfChoiceReturnScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The chosen rest took root.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian bed-of-choice return routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianVoidSignal(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianVoidSignal")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordVoidSignalScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Void piety belongs to Sithis only after the relation is explicitly active.
    if Manager.PDV_Sithis && Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Sithis, Manager.PDV_Sithis.SIGNAL_VOID_THRESHOLD, None, multiplier)
    endIf
    ; Void overreach: leaning deep into the Void (fully active) while Hist maintenance has
    ; lapsed below its non-curse floor is the curated major loss for the Hist.
    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive() && Manager.PDV_ArgonianHistSubstrate.GetHistRelation() <= Manager.PDV_ArgonianHistSubstrate.HistNonCurseFloor
        EmitHistVoidOverreachMinus(reason)
    endIf
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The Void was noticed.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian Void signal routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshArgonianHist()
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Bool curseActive = False
    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() != 0
        curseActive = True
    endIf

    Manager.PDV_ArgonianHistSubstrate.ProcessHistDistanceDawn(curseActive, "dawn")
    Manager.PDV_ArgonianHistSubstrate.ProcessCulturalPracticeDawn(curseActive, "dawn")
    RefreshArgonianHistPosture("dawn")
EndFunction

Function RefreshArgonianHistPosture(String reason)
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    RefreshArgonianDominationPressure(reason)

    Int curseState = 0
    if Manager.PDV_CurseStateService
        curseState = Manager.PDV_CurseStateService.GetCurseState()
    endIf

    Int oldPosture = 0
    if Manager.PDV_ArgonianHistPostureTrack
        oldPosture = Manager.PDV_ArgonianHistPostureTrack.GetCurrentState()
    endIf

    Bool dominationPressure = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure") == 1
    Manager.PDV_ArgonianHistSubstrate.RefreshHistPosture(curseState, dominationPressure, reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.PDV_ArgonianHistSubstrate.GetHistPosture())
    if Manager.PDV_ArgonianHistPostureTrack
        Manager.PDV_ArgonianHistPostureTrack.SetState(Manager.PDV_ArgonianHistSubstrate.GetHistPosture(), reason)
        if Manager.PDV_ArgonianHistPostureTrack.GetCurrentState() != oldPosture
            Manager.SendPrismaShiftToast(GetArgonianHistPostureLabel(), "", "hist")
            Manager.RequestPanelRefresh()
            Int newPosture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
            if newPosture == Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
                EmitHistCorruptionMinus(reason)
            elseIf newPosture == Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_DISTANT
                EmitHistAbandonmentMinus(reason)
            endIf
        endIf
    endIf
EndFunction

Function RefreshArgonianDominationPressure(String reason)
    Bool active = IsArgonianMolagBalDominationPressureActive()
    Int oldValue = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure")
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.DominationPressure", PDV_DevotionRules.BoolToInt(active))
    if PDV_DevotionRules.BoolToInt(active) != oldValue
        Manager.Trace(1, "Argonian domination pressure -> " + PDV_DevotionRules.BoolToInt(active) + " (" + reason + ")")
    endIf
EndFunction

Function RefreshArgonianDominationPressureForPath(PDV_DaedricPathBase path, String reason)
    if !path
        return
    endIf
    if path.DeityName != "Molag Bal" && path.DeityName != "Molag"
        return
    endIf
    if GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
        RefreshArgonianHistPosture(reason)
    endIf
EndFunction

Bool Function IsArgonianMolagBalDominationPressureActive()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return False
    endIf
    if !Manager.PDV_CurseStateService || Manager.PDV_CurseStateService.GetCurseState() != 2
        return False
    endIf

    PDV_DeityBase deity = Manager.GetQuestReactionDeity("Molag Bal")
    PDV_DaedricPathBase molagPath = deity as PDV_DaedricPathBase
    if !molagPath
        return False
    endIf

    return molagPath.GetStoredTier() >= Manager.LedgerRuntime.TIER_SEEKER
EndFunction

Function EmitHistAbandonmentMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistAbandonment")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistAbandonmentTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistCorruptionMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistCorruption")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_CORRUPTION, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistCorruptionCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistCorruptionReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistCorruptionTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist corruption routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistVoidOverreachMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistVoidOverreach")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_VOID_OVERREACH, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.VoidOverreachCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastVoidOverreachReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastVoidOverreachTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist void overreach routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function SyncArgonianRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isArgonian = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
    Float histRelation = 0.0
    Float peopleRelation = 0.0
    Float voidRelation = 0.0
    Bool voidActive = False
    Int activeFocus = Manager.ARGONIAN_FOCUS_NONE
    if isArgonian && Manager.PDV_ArgonianHistSubstrate
        histRelation = Manager.PDV_ArgonianHistSubstrate.GetHistRelation()
        peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
        voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
        voidActive = Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        activeFocus = GetArgonianActiveFocus(peopleRelation, voidRelation, voidActive)
    endIf

    ; Hist broad set, HIGHEST TIER ONLY (each tier spell carries the cumulative
    ; magnitude, so total power is unchanged but only one tier shows at a time).
    ; Retired Hist Communion boon family: the cultural-practice substrate now
    ; owns the universal identity boon, while Hist remains a relation ledger.
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_T1, False, "Argonian Hist T1 retired")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_T2, False, "Argonian Hist T2 retired")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_Signature, False, "Argonian Hist Signature retired")

    ; People focused set, highest tier only (active only when People is the focus).
    Bool peopleActive = isArgonian && activeFocus == Manager.ARGONIAN_FOCUS_PEOPLE
    Bool wantPeopleT3 = peopleActive && peopleRelation >= Manager.ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantPeopleT2 = peopleActive && !wantPeopleT3 && peopleRelation >= Manager.ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantPeopleT1 = peopleActive && !wantPeopleT3 && !wantPeopleT2 && peopleRelation >= Manager.ARGONIAN_REWARD_T1_THRESHOLD
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T1, wantPeopleT1, "Argonian People T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T2, wantPeopleT2, "Argonian People T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T3, wantPeopleT3, "Argonian People T3")

    ; Sithis tertiary, highest tier only (only when Void is fully active + the focus).
    Bool sithisActive = isArgonian && voidActive && activeFocus == Manager.ARGONIAN_FOCUS_VOID
    Bool wantSithisT3 = sithisActive && voidRelation >= Manager.ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantSithisT2 = sithisActive && !wantSithisT3 && voidRelation >= Manager.ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantSithisT1 = sithisActive && !wantSithisT3 && !wantSithisT2 && voidRelation >= Manager.ARGONIAN_REWARD_T1_THRESHOLD
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T1, wantSithisT1, "Argonian Sithis T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T2, wantSithisT2, "Argonian Sithis T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T3, wantSithisT3, "Argonian Sithis T3")

    ; Hist Adaptation slot rides the same dawn sync (separate channel from the
    ; tier rewards above; never touched by SyncRaceRewardSpell).
    SyncArgonianAdaptation(playerRef, isArgonian)

    ; Existing-save fallback for Waters That Remember: discovery events never
    ; re-fire for already-known locations, so the dawn sync also offers the
    ; player's current location to the same one-shot gate.
    if isArgonian
        HandleArgonianSacredWaterDiscovery(playerRef.GetCurrentLocation())
    endIf
EndFunction

Int Function GetArgonianActiveFocus(Float peopleRelation, Float voidRelation, Bool voidActive)
    if voidActive && voidRelation > peopleRelation
        return Manager.ARGONIAN_FOCUS_VOID
    endIf

    return Manager.ARGONIAN_FOCUS_PEOPLE
EndFunction

Bool Function IsArgonianHistNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return False
    endIf

    Int posture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
    if posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_SILENCED && posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
        return False
    endIf

    if !Manager.PDV_ArgonianHistSubstrate.HasHistMaintenance()
        return True
    endIf

    Int elapsedDays = Manager.LedgerRuntime.GetDevotionalDay() - Manager.PDV_ArgonianHistSubstrate.GetLastHistMaintenanceDevotionalDay()
    return elapsedDays > (Manager.ARGONIAN_HIST_NEGLECT_GRACE_DAYS as Int)
EndFunction

Function SyncArgonianNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_ArgonianHist
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_ArgonianHist, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
    endIf
EndFunction

Function ApplyArgonianCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_SILENCED)
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.VampireScar", 1)
        if StorageUtil.GetIntValue(None, "PDV.Argonian.VampireFeedbackShown") != 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_VampireOnset, "You are undead now. The Hist falls silent.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_STRAINED)
        if StorageUtil.GetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown") != 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_WerewolfOnset, "The beast is in you. The Hist relation strains, but does not sever.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_DISTANT)
        if oldState == 2
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_VampireCured, "The undeath is lifted. The Hist reaches again slowly.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 0)
        elseIf oldState == 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_WerewolfCured, "The beast is set down. The shape settles.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 0)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_NORMAL)
    endIf

    RefreshArgonianHistPosture(reason)
EndFunction

Function ShowArgonianMessage(Message messageRecord, String fallback, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal || !messageRecord
        Manager.SendPrismaToast("hist", "warning", "", fallback)
        return
    endIf

    messageRecord.Show()
EndFunction

String Function GetArgonianMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("hist", "The Hist", "substrate", "hist", Manager.PDV_Hist, "Root, memory, people, and sap.")
    entries = entries + "," + Manager.RosterMedallionEntry("sithis", "Sithis", "god", "sithis", Manager.PDV_Sithis, "Void, change, and dangerous silence.")
    return entries
EndFunction

Function EnsureArgonianHistSapToken()
    ; V1: grant the self-replenishing Hist Sap POTION (PDV_ALCH_ArgonianHistSap) rather than the old read
    ; BOOK. Drinking it routes Hist maintenance (see PDV_PotionArgonianHistSapEffect) and re-adds itself, so
    ; the player keeps one ritual vial. The book property stays declared but is no longer granted.
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ALCH_ArgonianHistSap
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(Manager.PDV_ALCH_ArgonianHistSap) <= 0
        playerRef.AddItem(Manager.PDV_ALCH_ArgonianHistSap, 1, True)
        StorageUtil.SetIntValue(None, "PDV.Token.ArgonianHistSap.Granted", 1)
        Manager.Trace(2, "Argonian Hist sap potion granted.")
    endIf
EndFunction

String Function GetArgonianSurveyText()
    if !Manager.PDV_ArgonianHistSubstrate
        return "Far from Black Marsh, the Hist is distant and your practice is still settling."
    endIf

    Float histRel = Manager.PDV_ArgonianHistSubstrate.GetHistRelation()
    String text = "Far from Black Marsh, Hist memory is " + GetArgonianLayerStrengthLabel(histRel)
    Float peopleRel = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if peopleRel >= 70.0
        text = text + " and the People are near."
    elseIf peopleRel >= 35.0
        text = text + " and the People are with you."
    elseIf peopleRel > 0.0
        text = text + " and the People are scattered."
    else
        text = text + " and the People are far off."
    endIf

    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        text = text + " Sithis is awake, but the Hist remains first."
    else
        Float voidRel = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
        if voidRel >= 35.0
            text = text + " Sithis stirs at the edge."
        elseIf voidRel > 0.0
            text = text + " Sithis waits at the edge."
        endIf
    endIf

    text = text + " Cultural practice: " + GetArgonianCulturalPracticeLabel() + "."

    return text
EndFunction

String Function GetArgonianHistLayerText()
    if !Manager.PDV_ArgonianHistSubstrate
        return "Hist, People, and Void are not yet readable."
    endIf

    String text = "Hist memory is " + GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetHistRelation())
    text = text + "; People support is " + GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation())
    text = text + "; Void awareness is " + GetArgonianVoidStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetVoidRelation())
    Int bedCount = StorageUtil.GetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
    if bedCount > 0
        text = text + ". Your chosen bed has begun to matter."
    endIf
    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        text = text + ". Sithis is active, but the Hist remains first."
    else
        text = text + ". Sithis is only an awareness at the edge."
    endIf
    return text
EndFunction

String Function GetArgonianLayerStrengthLabel(Float value)
    if value >= 70.0
        return "held"
    elseIf value >= 35.0
        return "present"
    elseIf value > 0.0
        return "thin"
    endIf

    return "distant"
EndFunction

String Function GetArgonianVoidStrengthLabel(Float value)
    if Manager.PDV_ArgonianHistSubstrate && Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return "awake"
    elseIf value >= 35.0
        return "stirring"
    elseIf value > 0.0
        return "at the edge"
    endIf

    return "dormant"
EndFunction

String Function GetArgonianHistPostureLabel()
    if Manager.PDV_ArgonianHistSubstrate
        return Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel()
    endIf

    return "Missing"
EndFunction

String Function GetArgonianHistSummary()
    if !Manager.PDV_ArgonianHistSubstrate
        return "missing"
    endIf

    return Manager.PDV_ArgonianHistSubstrate.GetPilotSummary()
EndFunction
