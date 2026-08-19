Scriptname PDV_OriginRuntime_Dunmer extends PDV_OriginRuntimeBase

; ORIGIN adapter -- DUNMER lane (tranche 4). Split out of PDV_OriginRuntimeBase per
; references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md. Covers the ancestor
; layers and ancestor substrate, the ancestral urn, the Reclamations focus
; (Azura / Boethiah / Mephala), the portable shrine prayer, the declared-home bonus,
; the deviation price, honorable victory, the twilight windows and the outdoor Good
; Daedra shrine.
;
; Lane function BODIES below are copied VERBATIM from PDV_OriginRuntimeBase so the
; move stays provable against origin_golden.json. The only new code is the thin
; dispatch layer: each base virtual override delegates to its named lane function.
; The originals remain on the base until the central removal pass runs; a
; same-signature child function is simply an override, so both compile.

; --- Lane-owned script variable (moved verbatim from PDV_OriginRuntimeBase; a
;     Papyrus child cannot reach a parent's script variables, only Properties.
;     Referenced ONLY by HandleDunmerPortableShrinePrayer /
;     HandleDunmerPlayerHomeBonus, both of which live in this adapter. ---
Bool _dunmerHomePrayerContext = False

; ===========================================================================
; Base virtual overrides (ADR interface). Delegation only -- no lane logic here.
; ===========================================================================

; -- Lifecycle --
; The Dunmer lane's only runtime-wiring verb is the ancestral-urn grant/migration.
; PDV__ManagerQuest calls it from the same two wiring points at which it calls
; EnsureNordRuntimeWiring (lines 842/854 and 942/944), so this is the lane's
; EnsureRuntimeWiring by construction, not by name.
Function EnsureRuntimeWiring()
    EnsureDunmerAncestralUrn()
EndFunction

; ApplyInitialChoice() is NOT overridden: the Dunmer lane has no startup-choice verb
; (PDV__ManagerQuest.ApplyStartupChoice does not dispatch ORIGIN_DUNMER).

; ApplyCurseHandlers() is NOT overridden: ApplyDunmerCurseHandlers(Int oldState,
; Int newState, String reason) needs the curse transition pair, and the frozen
; no-arg virtual carries neither value. See the manifest's interfaceGaps.

; EvaluateAtDawn() is NOT overridden: the Dunmer lane has no dawn verb.

; -- State --
String Function GetOriginStateLabel()
    return GetDunmerAncestorLayerLabel()
EndFunction

; The ancestor layer IS the Dunmer state track, and its value is the substrate tier
; that GetDunmerAncestorLayerLabel renders. The lane never exposed that Int on its
; own, so this reads the same source the label reads.
Int Function GetOriginStateValue()
    if !Manager.PDV_DunmerAncestorSubstrate
        return 0
    endIf

    return Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
EndFunction

String Function GetOriginSummary()
    return GetDunmerAncestorSummary()
EndFunction

String Function GetSurveyFragment()
    return GetDunmerSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsDunmerAncestorNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "ancestor-layer"
        return GetDunmerAncestorLayerLabel()
    elseIf detailKey == "book-of-days-ancestor"
        return GetBookOfDaysDunmerAncestorLabel()
    elseIf detailKey == "curse-posture"
        return GetDunmerCursePostureLabel()
    elseIf detailKey == "reclamation-focus"
        return GetDunmerReclamationFocusLabel(StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1))
    elseIf detailKey == "twilight-window"
        return GetDunmerTwilightWindowLabel(GetDunmerTwilightWindow(Utility.GetCurrentGameTime()))
    elseIf detailKey == "ancestor-summary"
        return GetDunmerAncestorSummary()
    elseIf detailKey == "medallion-entries"
        return GetDunmerMedallionEntriesJson()
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "reclamation-focus"
        return StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
    elseIf detailKey == "curse-posture"
        return StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    elseIf detailKey == "twilight-window"
        return GetDunmerTwilightWindow(Utility.GetCurrentGameTime())
    elseIf detailKey == "at-declared-home"
        return PDV_DevotionRules.BoolToInt(IsPlayerAtDunmerDeclaredHome(Game.GetPlayer()))
    endIf

    return 0
EndFunction

; -- Signals --
; signalId doubles as the lane functions' `reason` argument: the frozen virtual has
; no String channel, and most Dunmer signal verbs take one. Callers that need a
; distinct trace reason must send a distinct signalId. `magnitude` carries the
; Reclamation focus index and the AI relationship rank, both Ints by nature.
Bool Function HandleContextualSignal(String signalId, Form contextForm = None, Float magnitude = 0.0)
    if signalId == "portable-shrine-prayer"
        HandleDunmerPortableShrinePrayer(signalId)
        return True
    elseIf signalId == "player-home-bonus"
        HandleDunmerPlayerHomeBonus(signalId)
        return True
    elseIf signalId == "reclamation-focus"
        HandleDunmerReclamationFocus(magnitude as Int, signalId)
        return True
    elseIf signalId == "honorable-victory"
        HandleDunmerHonorableVictory(contextForm)
        return True
    elseIf signalId == "combat-victory-evidence"
        RecordDunmerCombatVictoryEvidence(contextForm)
        return True
    elseIf signalId == "story-victory-evidence"
        RecordDunmerStoryVictoryEvidence(contextForm, magnitude as Int)
        return True
    elseIf signalId == "deviation-price"
        HandleDunmerDeviationPrice(signalId)
        return True
    elseIf signalId == "outdoor-good-daedra-shrine"
        HandleDunmerOutdoorGoodDaedraShrine(signalId)
        return True
    elseIf signalId == "clumsy-crime"
        HandleDunmerClumsyCrime(signalId)
        return True
    elseIf signalId == "twilight-window-rite"
        TryAwardDunmerTwilightWindowSignal(signalId)
        return True
    elseIf signalId == "sleep-events"
        HandleDunmerSleepEvents(contextForm as Actor, signalId)
        return True
    elseIf signalId == "reclamation-memory"
        AwardActiveDunmerReclamationMemorySignal()
        return True
    elseIf signalId == "disarm-ancestor-watch"
        DisarmDunmerAncestorWatch()
        return True
    endIf

    return False
EndFunction

; HandleLocationChange() is NOT overridden: the Dunmer lane has no location verb.

; -- Upkeep --
Function SyncRaceRewards()
    SyncDunmerRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncDunmerNeglectSpell(IsDunmerAncestorNeglected())
EndFunction

; -- Patron and offers --
Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return IsDunmerOfferEligibleDeity(deity)
EndFunction

; GetFormalCommitmentOfferMessage() is NOT overridden: the frozen virtual returns a
; String and takes no deity, while GetDunmerFormalCommitmentOfferMessage(deity)
; returns a Message record chosen per deity. There is no lossless delegation.
; See the manifest's interfaceGaps.

; -- Presentation --
Function ShowOriginNotification(String messageKey)
    if messageKey == "deviation-price-notice"
        SurfaceDunmerDeviationPriceNotice()
    endIf
EndFunction

; ===========================================================================
; Dunmer lane functions -- copied VERBATIM from PDV_OriginRuntimeBase.
; ===========================================================================

Function HandleDunmerPortableShrinePrayer(String reason)
    if Manager.PDV_DunmerAncestorSubstrate
        ; Layer 1 (ancestor substrate) is silenced under vampirism, halved under the
        ; beast. Layer 2 (Reclamation memory) still answers, so it routes regardless.
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerPortableShrinePrayer") * layerWeight
            Float metricBefore = Manager.PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)
            Int tierAfter = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Ancestor prayer marked.", "ancestor", GetDunmerAncestorLayerLabel())
            ; The Ledger driver for the ancestral layer. Sits inside the layerWeight guard on purpose:
            ; vampirism silences this layer entirely, so a silenced prayer must not record one either.
            ; Self-caps to the first prayer of the devotional day; patron-independent by ruling.
            AwardDunmerAncestorSpinePulse(multiplier, reason)
        else
            Manager.Trace(2, "Dunmer ancestor layer silenced by curse posture (" + reason + ")")
        endIf
        Manager.NotifyDiegeticRoutineFavor("dunmer_portable_shrine")
        Bool twilightAwarded = TryAwardDunmerTwilightWindowSignal(reason)
        if !twilightAwarded
            AwardActiveDunmerReclamationMemorySignal()
        endIf
        ; Home presence changes the substrate/ward only. The portable prayer
        ; already supplied the one deity-piety pulse for this logical act.
        ; Home-prayer bonus (11a, reworked 2026-07-04): praying with the portable urn at
        ; your declared ancestor-home fires the bigger home progress step + arms the
        ; ancestor watch (once-per-day near-death save until dawn).
        ; HandleDunmerPlayerHomeBonus self-gates on curse posture.
        if IsPlayerAtDunmerDeclaredHome(Game.GetPlayer())
            _dunmerHomePrayerContext = True
            HandleDunmerPlayerHomeBonus(reason + "_home")
            _dunmerHomePrayerContext = False
        endIf
        Manager.RequestPanelRefresh()
        Manager.Trace(2, "Dunmer portable shrine prayer routed (" + reason + ")")
    endIf
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    Actor homePlayer = Game.GetPlayer()
    if !_dunmerHomePrayerContext || !IsPlayerAtDunmerDeclaredHome(homePlayer)
        if Manager.PDV_DunmerAncestorSubstrate
            Manager.PDV_DunmerAncestorSubstrate.RecordDailyCreditReject("dunmer_home_prayer", reason, "requires_paired_home_prayer")
        endIf
        Manager.Trace(2, "Dunmer home-only substrate route rejected (" + reason + ")")
        return
    endIf
    if Manager.PDV_DunmerAncestorSubstrate
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerHomeBonus") * layerWeight
            Float metricBefore = Manager.PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)
            Int tierAfter = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Prayers within the home feel more meaningful.", "ancestor", GetDunmerAncestorLayerLabel())
            ; Ancestor watch (11a rework 2026-07-04): the home prayer no longer heals on
            ; the spot; it arms a once-per-day near-death save that lasts until dawn (the
            ; BaanDar-style low-health watcher, PDV_T3DailyLowHealthSaveEffect on the
            ; PDV_SPEL_Dunmer_AncestorWatch ability). ProcessDawn disarms it, so each
            ; day's protection must be re-earned with a fresh home prayer.
            if homePlayer && Manager.PDV_SPEL_Dunmer_AncestorWatch && !homePlayer.HasSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
                homePlayer.AddSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch, False)
                Manager.Trace(2, "Dunmer ancestor watch armed (" + reason + ")")
            endIf
        else
            Manager.Trace(2, "Dunmer home rite silenced by curse posture (" + reason + ")")
        endIf
        Manager.NotifyDiegeticRoutineFavor("dunmer_home_bonus")
        Manager.RequestPanelRefresh()
        Manager.Trace(2, "Dunmer player-home bonus routed (" + reason + ")")
    endIf
EndFunction

Function DisarmDunmerAncestorWatch()
    ; The home-prayer ancestor watch lasts until dawn; remove it so each day's
    ; near-death protection must be re-earned with a fresh home prayer. The watcher
    ; script's own StorageUtil day-guard keeps the save once-per-day regardless.
    if !Manager.PDV_SPEL_Dunmer_AncestorWatch
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if playerRef && playerRef.HasSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
        playerRef.RemoveSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
        Manager.Trace(2, "Dunmer ancestor watch released at dawn.")
    endIf
EndFunction

Function HandleDunmerSleepEvents(Actor playerRef, String reason)
    if !Manager.PDV_DunmerAncestorSubstrate || !playerRef
        return
    endIf
    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return
    endIf

    Int sleepCellId = sleepCell.GetFormID()
    ; fix-plan 4.2: the ancestor-home cadence now runs on the shared 06:00 devotional
    ; day with the same zero-reserved +2 encoding the Argonian bed rite uses, so a
    ; midnight crossed mid-sleep can no longer shorten the decline window or split one
    ; night's sleep across two "days". ReadZeroReserved migrates the legacy +1 stamps.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID")
    if StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID") != 0
        if sleepCellId == declaredId && StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") > 0
            HandleDunmerDeviationPrice("sleep_deviation_" + reason)
        endIf
        if sleepCellId == declaredId
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
            return
        endIf
    endIf

    if !Manager.PDV_MESG_DunmerMarkHome
        if declaredId == 0
            SetDunmerHome(sleepCellId, todayStamp, reason)
        endIf
        return
    endIf

    Int declinedDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
    if declinedDay > 0 && (todayStamp - declinedDay) < 3
        return
    endIf

    Bool shouldPrompt = declaredId == 0
    if declaredId != 0
        Int candidateId = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateFormID")
        Int candidateCount = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateCount")
        Int candidateDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
        ; B13 / fix-plan 4.6. CandidateDay was written four times and read zero times, so
        ; the re-declare counter climbed on EVERY sleep -- sleep three times in one night
        ; and the "mark a new home" prompt fired instantly. Gate the increment on the day
        ; actually changing, exactly as TryArgonianBedOfChoiceSleep does.
        if candidateId != sleepCellId
            candidateCount = 1
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", sleepCellId)
        elseIf candidateDay != todayStamp
            candidateCount += 1
        endIf
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", candidateCount)
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
        shouldPrompt = candidateCount >= 3
    endIf

    if !shouldPrompt
        return
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_DunmerMarkHome.Show()
    ; B4 / fix-plan 3. -1 is "another menu was already up", not a decline: no 3-day
    ; suppression stamp and no wipe of the three-sleep candidacy the player earned.
    if pressed < 0
        Manager.Trace(2, "Dunmer ancestor-home menu not shown (menu busy); candidacy kept.")
        return
    endIf
    if pressed == 0
        SetDunmerHome(sleepCellId, todayStamp, reason)
    else
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    endIf
EndFunction

Function SetDunmerHome(Int sleepCellId, Int devotionalDayStamp, String reason)
    if sleepCellId == 0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredDay", devotionalDayStamp)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    Manager.SendPrismaToast("ancestor", "good", "Ancestor-space", "The ancestors will know this place.")
    Manager.Trace(2, "Dunmer ancestor-home declared: " + reason)
EndFunction

Bool Function IsPlayerAtDunmerDeclaredHome(Actor playerRef)
    if !playerRef
        return false
    endIf
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID")
    if declaredId == 0
        return false
    endIf
    Cell currentCell = playerRef.GetParentCell()
    if !currentCell
        return false
    endIf
    return currentCell.GetFormID() == declaredId
EndFunction

Function SyncDunmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isDunmer = GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER
    Bool broadReclamationFaithful = isDunmer && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Dunmer_Reclamation_T2, broadReclamationFaithful, "Dunmer Reclamation T2")

    SyncDunmerRewardFamily(playerRef, Manager.PDV_Azura, Manager.PDV_Bless_Dunmer_Azura_T1, Manager.PDV_Bless_Dunmer_Azura_T2, Manager.PDV_Bless_Dunmer_Azura_T3, "Azura")
    SyncDunmerRewardFamily(playerRef, Manager.PDV_Boethiah, Manager.PDV_Bless_Dunmer_Boethiah_T1, Manager.PDV_Bless_Dunmer_Boethiah_T2, Manager.PDV_Bless_Dunmer_Boethiah_T3, "Boethiah")
    SyncDunmerRewardFamily(playerRef, Manager.PDV_Mephala, Manager.PDV_Bless_Dunmer_Mephala_T1, Manager.PDV_Bless_Dunmer_Mephala_T2, Manager.PDV_Bless_Dunmer_Mephala_T3, "Mephala")
EndFunction

Function SyncDunmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Dunmer " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Dunmer " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Dunmer " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Dunmer " + label)
EndFunction

Bool Function IsDunmerAncestorNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        return False
    endIf

    Int dunmerPosture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    return dunmerPosture == 1 || dunmerPosture == 2
EndFunction

Function SyncDunmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Dunmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Dunmer)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Dunmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Dunmer)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Dunmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
    endIf
EndFunction

Function HandleDunmerClumsyCrime(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Mephala
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1) != 2
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MephalaSecretBetrayed")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SECRET_BETRAYED, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.SecretBetrayedCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastSecretBetrayedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastSecretBetrayedTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Mephala secret-betrayed routed: " + reason + " multiplier=" + multiplier)
EndFunction

Message Function GetDunmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Azura
        return Manager.PDV_Msg_Dunmer_Azura_Offer
    elseIf deity == Manager.PDV_Boethiah
        return Manager.PDV_Msg_Dunmer_Boethiah_Offer
    elseIf deity == Manager.PDV_Mephala
        return Manager.PDV_Msg_Dunmer_Mephala_Offer
    endIf

    return None
EndFunction

Bool Function IsDunmerOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        return False
    endIf

    return deity == Manager.PDV_Azura || deity == Manager.PDV_Boethiah || deity == Manager.PDV_Mephala
EndFunction

Function ApplyDunmerCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 2)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 1)
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 3)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 0)
    endIf
EndFunction

Float Function GetDunmerCurseLayerWeight(Int layer)
    Int posture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if layer == 1
        if posture == 2
            return 0.0
        elseIf posture == 1
            return 0.5
        endIf
    elseIf layer == 2
        if posture == 1
            return 0.75
        endIf
    endIf
    return 1.0
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        Manager.Trace(2, "Dunmer Reclamation focus ignored for non-Dunmer origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerReclamationFocus")
    if multiplier <= 0.0
        return
    endIf

    Float layerWeight = GetDunmerCurseLayerWeight(2) * multiplier
    if Manager.PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
        Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "reclamation_source_" + reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocus", PDV_DevotionRules.ClampInt(focusValue, 0, 2))
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocusCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastReclamationReason", reason)
    AwardDunmerReclamationFocusSignal(focusValue, layerWeight)
    if focusValue == 0
        Manager.SurfaceP2BookReadNotice(reason, "Azura's twilight", "The Reclamation turns toward her.")
    elseIf focusValue == 1
        Manager.SurfaceP2BookReadNotice(reason, "Boethiah's proving", "The Reclamation turns toward struggle.")
    else
        Manager.SurfaceP2BookReadNotice(reason, "Mephala's web", "The Reclamation turns toward secrets.")
    endIf
    Manager.Trace(2, "Dunmer Reclamation focus routed: " + reason + " weight " + layerWeight)
EndFunction

Function HandleDunmerHonorableVictory(Form victimForm)
    ; Canonical player-alias ingress. It records only the clean-combat half; a
    ; single caller cannot award until Story Manager independently confirms the
    ; hostile, non-murder classification for the same victim.
    RecordDunmerCombatVictoryEvidence(victimForm)
EndFunction

Function RecordDunmerCombatVictoryEvidence(Form victimForm)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !victimForm
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableCombatVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableCombatTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function RecordDunmerStoryVictoryEvidence(Form victimForm, Int relationshipRank)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !victimForm || relationshipRank > -2
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableStoryVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableStoryTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function TryResolveDunmerHonorableVictory(Form victimForm)
    if !Manager.PDV_DunmerAncestorSubstrate || !victimForm
        return
    endIf
    Int victimId = victimForm.GetFormID()
    if StorageUtil.GetIntValue(None, "PDV.Dunmer.HonorableCombatVictim") != victimId || StorageUtil.GetIntValue(None, "PDV.Dunmer.HonorableStoryVictim") != victimId
        return
    endIf
    Float combatTime = StorageUtil.GetFloatValue(None, "PDV.Dunmer.HonorableCombatTime")
    Float storyTime = StorageUtil.GetFloatValue(None, "PDV.Dunmer.HonorableStoryTime")
    if combatTime <= 0.0 || storyTime <= 0.0 || combatTime - storyTime > 0.02 || storyTime - combatTime > 0.02
        return
    endIf
    Actor victim = victimForm as Actor
    Actor playerRef = Game.GetPlayer()
    if !victim || !playerRef || victim.GetLevel() < playerRef.GetLevel()
        return
    endIf

    ; Clear both halves before awarding so repeated callbacks cannot double-fire.
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableCombatVictim", 0)
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableStoryVictim", 0)
    Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "honorable_victory_" + victim.GetFormID())
    Manager.Trace(2, "Dunmer honorable victory accepted for " + victim.GetFormID())
EndFunction

Function HandleDunmerDeviationPrice(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        Manager.Trace(2, "Dunmer deviation price ignored for non-Dunmer origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerDeviationPrice")
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.DeviationPriceCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastDeviationReason", reason)
    AwardDunmerDeviationPriceSignal(multiplier)
    SurfaceDunmerDeviationPriceNotice()
    Manager.Trace(2, "Dunmer deviation price routed: " + reason)
EndFunction

Function SurfaceDunmerDeviationPriceNotice()
    if !Manager.GetActiveDeity()
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    String activeName = Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity())
    String symbolName = Manager.GetPrismaSymbolForDeity(Manager.GetActiveDeity())
    String line = "The ash-prayer thins; " + activeName + " marks the wound."
    Manager.AppendBookOfDaysEntry(line, today, "creed.drop", symbolName, False, 2, "Reclamation strained")

    ; fix-plan 4.2: one notice per devotional day (the journal line above keeps the
    ; wall-clock date on purpose -- that is a display timestamp, not a cap).
    String toastKey = "PDV.Toast.DunmerDeviationPrice.Day"
    Int toastDayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, toastKey, -1) != toastDayStamp
        StorageUtil.SetIntValue(None, toastKey, toastDayStamp)
        Manager.SendPrismaToast(symbolName, "warning", "Reclamation strained", line)
    endIf
EndFunction

Bool Function TryAwardDunmerTwilightWindowSignal(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Azura
        return False
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Int windowValue = GetDunmerTwilightWindow(nowTime)
    if windowValue <= 0
        return False
    endIf

    ; fix-plan 4.2: one rite per window per devotional day.
    Int dayIndex = Manager.LedgerRuntime.GetDevotionalDay() + 2
    String windowLabel = GetDunmerTwilightWindowLabel(windowValue)
    String dayKey = "PDV.Signal.DunmerTwilight." + windowLabel + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, -1) == dayIndex
        Manager.Trace(2, "Dunmer " + windowLabel + " twilight rite already recorded today (" + reason + ")")
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, dayIndex)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.TwilightWindowCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightWindow", windowLabel)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastTwilightTime", nowTime)
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE, None)
    Manager.Trace(2, "Dunmer " + windowLabel + " twilight rite routed: " + reason)
    return True
EndFunction

Function HandleDunmerOutdoorGoodDaedraShrine(String reason)
    if TryAwardDunmerTwilightWindowSignal(reason)
        if Manager.PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
            Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "good_daedra_altar_" + reason)
        endIf
        Manager.SendPrismaToast("journal", "good", "Good Daedra", "The Good Daedra hear the ash-prayer.")
    elseIf GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER
        Manager.SendPrismaToast("journal", "neutral", "Shrine quiet", "The shrine is quiet in this hour.")
    endIf
EndFunction

Int Function GetDunmerTwilightWindow(Float gameTime)
    Int dayIndex = gameTime as Int
    Float dayFraction = gameTime - dayIndex
    if dayFraction >= 0.25 && dayFraction < 0.375
        return 1
    elseIf dayFraction >= 0.75 && dayFraction < 0.875
        return 2
    endIf
    return 0
EndFunction

String Function GetDunmerTwilightWindowLabel(Int windowValue)
    if windowValue == 1
        return "Dawn"
    elseIf windowValue == 2
        return "Dusk"
    endIf
    return "None"
EndFunction

Function AwardActiveDunmerReclamationMemorySignal()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return
    endIf

    ; Anti-farm: the ancestor-memory piety pulse (portable-shrine prayer and the
    ; home rite share it) banks at most once per dawn cycle, keyed on the same
    ; day-int boundary as the rest of the daily gates. The substrate side keeps its
    ; own 0.7^n decay separately; this stops the pulse from stacking linearly.
    ; fix-plan 4.2: the comment above already says "once per dawn cycle" -- it now uses
    ; the dawn day boundary instead of raw midnight.
    Int pdvAncestorMemoryDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day") == pdvAncestorMemoryDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day", pdvAncestorMemoryDay)

    Float layerWeight = GetDunmerCurseLayerWeight(2)
    if Manager.GetActiveDeity() == Manager.PDV_Boethiah && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Mephala && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Azura && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Azura || multiplier <= 0.0
        return
    endIf

    Int pdvAncestorSpineDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day") == pdvAncestorSpineDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day", pdvAncestorSpineDay)

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Dunmer.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
EndFunction

Function AwardDunmerReclamationFocusSignal(Int focusValue, Float layerWeight)
    if focusValue == 0 && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_THRESHOLD_RITE, None, layerWeight)
    elseIf focusValue == 1 && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE, None, layerWeight)
    elseIf focusValue == 2 && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SECRET_KEPT, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerDeviationPriceSignal(Float multiplier)
    if Manager.GetActiveDeity() == Manager.PDV_Boethiah && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Mephala && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Azura && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DESECRATION, None, multiplier)
    endIf
EndFunction

String Function GetBookOfDaysDunmerAncestorLabel()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "Unreadable"
    endIf

    Int tierValue = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= 3
        return "Strong"
    elseIf tierValue == 2
        return "Steady"
    elseIf tierValue == 1
        return "Beginning"
    endIf

    return "Quiet"
EndFunction

String Function GetDunmerMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("azura", "Azura", "prince", "azura", Manager.PDV_Azura, "Dawn, dusk, prophecy, and fate.")
    entries = entries + "," + Manager.RosterMedallionEntry("boethiah", "Boethiah", "prince", "boethiah", Manager.PDV_Boethiah, "Trial, overthrow, and hard becoming.")
    entries = entries + "," + Manager.RosterMedallionEntry("mephala", "Mephala", "prince", "mephala", Manager.PDV_Mephala, "Web, secrecy, clan, and hidden duty.")
    return entries
EndFunction

Function EnsureDunmerAncestralUrn()
    ; V1: grant the usable MISC urn (PDV_MISC_DunmerAncestralUrn); clicking it in the inventory
    ; fires OnEquipped and routes the ancestor prayer. The retired model-less BOOK token crashed
    ; the book menu on read, so migration removes any copies before granting the MISC urn.
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_MISC_DunmerAncestralUrn
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if Manager.PDV_BOOK_DunmerAncestralUrn
        int staleBookCount = playerRef.GetItemCount(Manager.PDV_BOOK_DunmerAncestralUrn)
        if staleBookCount > 0
            playerRef.RemoveItem(Manager.PDV_BOOK_DunmerAncestralUrn, staleBookCount, True)
            Manager.Trace(2, "Dunmer ancestral urn book token retired.")
        endIf
    endIf

    if playerRef.GetItemCount(Manager.PDV_MISC_DunmerAncestralUrn) <= 0
        playerRef.AddItem(Manager.PDV_MISC_DunmerAncestralUrn, 1, True)
        Manager.Trace(2, "Dunmer ancestral urn granted.")
    endIf
EndFunction

String Function GetDunmerSurveyText()
    String band = Manager.GetCurrentStandingBand()
    Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
    String text = ""
    if reclamationFocus == 0
        text = "Azura holds your focus; the ash-prayer carries beneath her. Your standing with Azura is " + band + "."
    elseIf reclamationFocus == 1
        text = "Boethiah holds your focus; the ash-prayer carries beneath. Your standing with Boethiah is " + band + "."
    elseIf reclamationFocus == 2
        text = "Mephala holds your focus; the ash-prayer carries beneath. Your standing with Mephala is " + band + "."
    else
        text = "The ash-prayer holds and the three Good Daedra answer together. Your standing with the Reclamations is " + band + ". No single Reclamation has your name yet."
    endIf

    Int posture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if posture == 1
        text = text + " Something in you pulls against the ancestors. The beast, or an unclean rite, makes the ash-prayer carry thinly."
    elseIf posture == 2
        text = text + " The ash-prayer meets no answer; the ancestors do not speak to the undead."
    elseIf posture == 3
        text = text + " The ancestors answer again; your posture is restored, but scarred."
    endIf

    return text
EndFunction

String Function GetDunmerAncestorLayerLabel()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "unreadable"
    endIf

    Int tierValue = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= 3
        return "strong"
    elseIf tierValue == 2
        return "steady"
    elseIf tierValue == 1
        return "beginning"
    endIf

    return "quiet"
EndFunction

String Function GetDunmerCursePostureLabel()
    Int postureValue = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if postureValue == 1
        return "strained, the beast pulls at the ancestors"
    elseIf postureValue == 2
        return "silent, the ancestors cannot reach you"
    elseIf postureValue == 3
        return "restored, but scarred"
    endIf

    return ""
EndFunction

String Function GetDunmerReclamationFocusLabel(Int focusValue)
    if focusValue == 0
        return "Azura"
    elseIf focusValue == 1
        return "Boethiah"
    elseIf focusValue == 2
        return "Mephala"
    endIf

    return "unset"
EndFunction

String Function GetDunmerAncestorSummary()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "missing"
    endIf

    return Manager.PDV_DunmerAncestorSubstrate.GetPilotSummary()
EndFunction
