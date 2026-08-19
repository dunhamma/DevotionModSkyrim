Scriptname PDV_OriginRuntime_Nord extends PDV_OriginRuntimeBase

; ORIGIN adapter -- NORD lane (tranche 4). Split out of PDV_OriginRuntimeBase per
; references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md. Covers the Old Ways /
; Nine Divines pantheon baseline, the Kyne lane (neglect, champion entry, commitment
; offer), Shor / Tsun / Stuhn / Orkey route families, the Nord ancestor substrate,
; the Hircine-Arkay edge, vampire suppression and the vampire scar.
;
; Lane function BODIES below are copied VERBATIM from PDV_OriginRuntimeBase so the
; move stays provable against origin_golden.json. The only new code is the thin
; dispatch layer: each base virtual override delegates to its named lane function.
; The originals remain on the base until the central removal pass runs; a
; same-signature child function is simply an override, so both compile.

; --- Lane-owned script variables (moved verbatim from PDV_OriginRuntimeBase; a
;     Papyrus child cannot reach a parent's script variables, only Properties.
;     Referenced ONLY by MaybeShowNordKyneChampionEntry /
;     ProcessQueuedNordKyneChampionEntry, both of which live in this adapter. ---
Message _pendingNordKyneChampionMsg = None
String _pendingNordKyneChampionFallback = ""
Int _pendingNordKyneChampionDelayTicks = 0

; ===========================================================================
; Base virtual overrides (ADR interface). Delegation only -- no lane logic here.
; ===========================================================================

; -- Lifecycle --
Function EnsureRuntimeWiring()
    EnsureNordRuntimeWiring()
EndFunction

Function EvaluateAtDawn()
    RunDawnRefreshNordAncestor()
EndFunction

; choiceValue is PDV__ManagerQuest.ApplyStartupChoice's optionValue and reason is its
; caller-composed trace string; both arrive unchanged now that the corrected virtual
; carries them, so this is a straight delegation.
Function ApplyInitialChoice(Int choiceValue, String reason)
    ApplyNordInitialChoice(choiceValue, reason)
EndFunction

; reason drives ShouldSuppressNordCurseModal inside the lane handler, so it must be
; the caller's own string -- a synthesised one would fire or wrongly suppress a modal.
Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyNordCurseHandlers(oldState, newState, reason)
EndFunction

; -- State --
String Function GetOriginStateLabel()
    return GetNordDevotionModeLabel()
EndFunction

Int Function GetOriginStateValue()
    return GetNordPantheonBaselineState()
EndFunction

String Function GetOriginSummary()
    return GetNordAncestorSummary()
EndFunction

String Function GetSurveyFragment()
    return GetNordSurveyBaseText()
EndFunction

; IsRaceLaneNeglected() is DELIBERATELY NOT overridden -- Nord inherits the base
; default False. Per the ADR ruling "neglect is THREE pools, and Nord has no
; race-lane one" (PDV_2_0_ADR_OriginAdapterInterface.md, 2026-08-19), neglect splits
; into a patron/deity pool, a race/culture-lane pool, and a broad-lane pool. Nord
; appears in the broad pool (the Kyne weather spell, reused as Nord's broad-lane
; neglect) and in the patron pool (SyncNordPatronNeglectSpells) ONLY; it has no
; race/culture-lane predicate at all, which is why the ADR counts nine such
; predicates, not ten. An earlier cut of this adapter mapped the virtual to
; IsNordVampireSuppressed(); that is OVERTURNED -- curse suppression is a third,
; unrelated thing, and equating it with lane lapse would answer a question Nord
; does not have. Consumers wanting "has the Nord broad lane gone quiet" must use
; the base's IsBroadLaneLapsed(); vampire suppression is still readable through
; GetOriginDetailValue("vampire-suppressed").

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "devotion-mode"
        return GetNordDevotionModeLabel()
    elseIf detailKey == "ancestor-layer"
        return GetNordAncestorLayerLabel()
    elseIf detailKey == "context-survey"
        return GetNordContextSurveyText()
    elseIf detailKey == "scar"
        return GetNordScarLabel()
    elseIf detailKey == "ancestor-summary"
        return GetNordAncestorSummary()
    elseIf detailKey == "kyne-favor-summary"
        return GetKyneFavorSummary()
    elseIf detailKey == "medallion-entries"
        return GetNordMedallionEntriesJson()
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "pantheon-baseline"
        return GetNordPantheonBaselineState()
    elseIf detailKey == "vampire-suppressed"
        return PDV_DevotionRules.BoolToInt(IsNordVampireSuppressed())
    elseIf detailKey == "vampire-scar"
        return PDV_DevotionRules.BoolToInt(HasNordVampireScar())
    elseIf detailKey == "old-ways-names"
        return PDV_DevotionRules.BoolToInt(UsesNordOldWaysDeityNames())
    elseIf detailKey == "kyne-neglect-active"
        return PDV_DevotionRules.BoolToInt(IsKyneNeglectActive())
    elseIf detailKey == "kyne-commitment-ready"
        return PDV_DevotionRules.BoolToInt(IsKyneCommitmentSignalReady())
    endIf

    return 0
EndFunction

; -- Signals --
; signalId selects the lane verb; `reason` is the caller's own trace string and is
; passed through UNCHANGED. It is never synthesised from signalId: reasons are
; player-visible in the Ledger and some lane bodies branch on the exact string, so
; substituting the id would silently change behaviour that no compile or
; reconstruction-parity check would catch (ADR, "Corrections after the pilot").
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "tsun-adversity-survived"
        HandleNordTsunAdversitySurvived(reason)
        return True
    elseIf signalId == "old-ways-state"
        HandleNordOldWaysState(reason)
        return True
    elseIf signalId == "kyne-talos-context"
        HandleNordKyneTalosContext(reason)
        return True
    elseIf signalId == "hircine-arkay-edge"
        HandleNordHircineArkayEdge(reason)
        return True
    elseIf signalId == "ancestor-spine"
        HandleNordAncestorSpine(reason)
        return True
    elseIf signalId == "ancestor-spine-pulse"
        RecordNordAncestorSpine(reason, magnitude)
        return True
    elseIf signalId == "ancestral-rest"
        RecordNordAncestralRest(reason, magnitude)
        return True
    elseIf signalId == "hearth-return"
        RecordNordHearthReturn(reason, magnitude)
        return True
    elseIf signalId == "sleep-events"
        HandleNordSleepEvents(contextForm as Actor, reason)
        return True
    elseIf signalId == "kyne-champion-entry"
        MaybeShowNordKyneChampionEntry(contextForm as PDV_DeityBase, magnitude as Int)
        return True
    elseIf signalId == "kyne-champion-entry-tick"
        ProcessQueuedNordKyneChampionEntry()
        return True
    elseIf signalId == "sleep-stop"
        ; base HandlePlayerSleepStop dispatched this by origin index.
        HandleNordSleepEvents(contextForm as Actor, reason)
        return True
    elseIf signalId == "substrate-action"
        ; base HandleSubstrateActionEvent, Nord arm. eventType rides the Float slot.
        ; Reproduced literally from the pre-change base: these arms do their OWN inline
        ; substrate + Prisma bookkeeping and deliberately do NOT route through
        ; RecordNordAncestralRest / RecordNordHearthReturn, which carry different copy and
        ; extra StorageUtil counters.
        Int eventType = magnitude as Int
        if Manager.PDV_NordAncestorSubstrate
            if eventType == 313
                Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
                Int tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
                Manager.PDV_NordAncestorSubstrate.RecordAncestralRestScaled(1.0, "open_sky_rest_" + reason)
                Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, Manager.PDV_NordAncestorSubstrate.GetSubstrateTier(), Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The open sky kept the old practice.", "journal", GetNordAncestorLayerLabel())
                return True
            elseIf eventType == 333
                Float hearthMetricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
                Int hearthTierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
                Manager.PDV_NordAncestorSubstrate.RecordHearthReturnScaled(1.0, "cooked_meal_" + reason)
                Manager.SendPrismaSubstrateProgress("ancestor", hearthTierBefore, Manager.PDV_NordAncestorSubstrate.GetSubstrateTier(), Manager.PDV_NordAncestorSubstrate.GetMetric() - hearthMetricBefore, "The first cooked meal kept the hearth.", "journal", GetNordAncestorLayerLabel())
                return True
            endIf
        endIf
        return False
    endIf

    return False
EndFunction

; The caller's akNewLocation rides through as a Form (Location extends Form) and is
; passed straight down. Re-sampling GetCurrentLocation() is NOT provably the same
; location the OnLocationChange event carried, so the pass-through is the honest
; wiring. HandleNordLocationChange already returns early on a None location.
Function HandleLocationChange(Form newLocation = None)
    HandleNordLocationChange(newLocation as Location)
EndFunction

; -- Upkeep --
Function SyncRaceRewards()
    SyncNordRewards(Game.GetPlayer())
EndFunction

; Patron-branch semantics, matching PDV_DevotionLedger's steady-state call site.
; The other two ledger sites pass a DIFFERENT Kyne boolean (broad-lane lapse, and a
; hard False when there is no active patron); a no-arg virtual cannot express those,
; so they must keep a caller-supplied path. See the manifest's callSiteDivergence.
Function SyncNeglectSpells()
    SyncKyneNeglectSpell(IsKyneNeglectActive() && Manager.GetActiveDeity() == Manager.PDV_Kyne)
    SyncNordPatronNeglectSpells()
EndFunction

; -- Patron and offers --
Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return IsNordOfferEligibleDeity(deity)
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    return GetNordFormalCommitmentOfferMessage(deity)
EndFunction

; -- Presentation --
; The corrected virtuals take the Message record and its fallback text, which is
; exactly what the two PDV_DevotionLedger call sites already pass, so both are a
; straight delegation. The earlier keyed ShowOriginNotification(String) is gone:
; it forced the notifier to own a per-key Message table that the caller already had.
Function ShowOriginNotification(Message messageRecord, String fallbackText)
    ShowNordNotification(messageRecord, fallbackText)
EndFunction

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
    ShowNordMessage(messageRecord, fallbackText, suppressModal)
EndFunction

; ===========================================================================
; Nord lane functions -- copied VERBATIM from PDV_OriginRuntimeBase.
; ===========================================================================

Function EnsureNordRuntimeWiring()
    EnsureNordOrkeyRewardRuntimeWiring()

    if !Manager.PDV_NordPantheonBaselineTrack
        return
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.TrackName != "NordPantheonBaseline"
        Manager.PDV_NordPantheonBaselineTrack.TrackName = "NordPantheonBaseline"
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.StateLabels.Length != 2
        String[] labels = new String[2]
        labels[0] = "OldWays"
        labels[1] = "NineDivines"
        Manager.PDV_NordPantheonBaselineTrack.StateLabels = labels
    endIf

    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", Manager.PDV_NordPantheonBaselineTrack.GetCurrentState())
EndFunction

Function EnsureNordOrkeyRewardRuntimeWiring()
    Bool repaired = False

    if !Manager.PDV_Bless_Nord_Arkay_T1
        Manager.PDV_Bless_Nord_Arkay_T1 = Game.GetFormFromFile(0x071660, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T1
            repaired = True
        endIf
    endIf

    if !Manager.PDV_Bless_Nord_Arkay_T2
        Manager.PDV_Bless_Nord_Arkay_T2 = Game.GetFormFromFile(0x071663, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T2
            repaired = True
        endIf
    endIf

    if !Manager.PDV_Bless_Nord_Arkay_T3
        Manager.PDV_Bless_Nord_Arkay_T3 = Game.GetFormFromFile(0x071666, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T3
            repaired = True
        endIf
    endIf

    if repaired
        Manager.Trace(1, "Nord Orkey reward runtime wiring repaired.")
    endIf
EndFunction

Function HandleNordSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Nord.HearthRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Nord.HearthRest", sleepCellId)
            ShowNordNotification(None, "This hearth becomes a remembered place of rest.")
            Manager.Trace(2, "Nord hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.NordAncestralRest")
        return
    endIf

    RecordNordAncestralRest("sleep_rest_" + reason, 1.0)
EndFunction

Function HandleNordTsunAdversitySurvived(String reason)
    if !Manager.PDV_Tsun || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Tsun)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordTsunAdversity")
    if multiplier <= 0.0
        Manager.Trace(2, "Tsun adversity blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tsun, Manager.PDV_Tsun.SIGNAL_ADVERSITY_SURVIVED, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Tsun, "Adversity survived", "marks a hard fight endured to its end.")
    Manager.Trace(2, "Tsun adversity-survived routed (" + reason + ")")
EndFunction

Function HandleNordLocationChange(Location newLocation)
    if !newLocation || GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(Game.GetPlayer(), "PDV.Nord.HearthRest.DeclaredFormID")
        return
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.NordHearthReturn")
        return
    endIf

    RecordNordHearthReturn("location_hearth_return", 1.0)
EndFunction

Function HandleNordAncestorSpine(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord ancestor spine ignored for non-Nord origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordAncestorSpine")
    RecordNordAncestorSpine(reason, multiplier)
EndFunction

Function RecordNordAncestorSpine(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordAncestorStandingScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line remembered.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Nord ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordNordAncestralRest(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordAncestralRestScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line rested near.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestralRestCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestralRestReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestralRestTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "You wake with the old line nearer.")
    Manager.Trace(2, "Nord ancestral rest routed with multiplier " + multiplier)
EndFunction

Function RecordNordHearthReturn(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordHearthReturnScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The hearth remembered your return.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.HearthReturnCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastHearthReturnReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastHearthReturnTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "The hearth remembers your return.")
    Manager.Trace(2, "Nord hearth return routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshNordAncestor()
    if !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    Int postureBefore = Manager.PDV_NordAncestorSubstrate.GetAncestorPosture()
    Bool curseActive = IsNordVampireSuppressed()
    Manager.PDV_NordAncestorSubstrate.ProcessAncestorDawn(curseActive, "dawn")
    Int postureAfter = Manager.PDV_NordAncestorSubstrate.GetAncestorPosture()
    if postureBefore > Manager.PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN && postureAfter == Manager.PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN
        ShowNordNotification(Manager.PDV_Notif_Nord_General_AncestorsQuiet, "The ancestors are quiet.")
    endIf
EndFunction

Function MaybeShowNordKyneChampionEntry(PDV_DeityBase deity, Int newTier)
    if newTier < Manager.LedgerRuntime.TIER_CHAMPION
        return
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return
    endIf
    if !Manager.PDV_Kyne || deity != Manager.PDV_Kyne
        return
    endIf
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Nord.ChampionEntryShown.Kyne") == 1
        return
    endIf
    if _pendingNordKyneChampionMsg
        return
    endIf

    ; Queued, never shown inline -- see _pendingNordKyneChampionMsg. The one-shot key is set when the
    ; modal actually PRESENTS, not here, so a recognition that could not display is not silently lost.
    _pendingNordKyneChampionMsg = Manager.PDV_Msg_Nord_Kyne_ChampionEntry
    _pendingNordKyneChampionFallback = "You sleep where the storm sleeps. You walk where the wind walks. Kyne has named her hunter."
    _pendingNordKyneChampionDelayTicks = 2
EndFunction

Function ProcessQueuedNordKyneChampionEntry()
    if !_pendingNordKyneChampionMsg && _pendingNordKyneChampionFallback == ""
        return
    endIf

    if _pendingNordKyneChampionDelayTicks > 0
        _pendingNordKyneChampionDelayTicks -= 1
        return
    endIf

    ; Belt and braces: OnUpdate already early-outs in menu mode, but the hold is cheap and this
    ; function is the thing that must never fire into an open menu.
    if Utility.IsInMenuMode()
        return
    endIf

    Message pendingRecord = _pendingNordKyneChampionMsg
    String pendingFallback = _pendingNordKyneChampionFallback
    _pendingNordKyneChampionMsg = None
    _pendingNordKyneChampionFallback = ""
    _pendingNordKyneChampionDelayTicks = 0

    ShowNordMessage(pendingRecord, pendingFallback, False)
    StorageUtil.SetIntValue(None, "PDV.Nord.ChampionEntryShown.Kyne", 1)
    Manager.Trace(1, "Nord/Kyne champion recognition presented.")
EndFunction

Bool Function IsKyneNeglectActive()
    return Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Kyne)
EndFunction

Function SyncKyneNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Kyne
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Kyne)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Kyne, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Kyne)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Kyne)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
    endIf
EndFunction

Function SyncNordPatronNeglectSpells()
    ; Per-patron Nord neglect (follow-on, owner ruling 2026-06-27): each focusable NON-Kyne Nord
    ; patron gets its own gentle flat neglect spell, applied only when it is the player's active
    ; patron AND flagged neglected (recency lapse). Kyne keeps its dedicated spell
    ; (SyncKyneNeglectSpell). Idempotent and self-clearing: each spell is set to its exact correct
    ; state, so calling this from any branch (focused / broad / uncommitted / Prince) removes a stale
    ; spell after a patron switch. No-ops entirely until the ESP batch authors the four records.
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf
    Bool isNord = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Shor,  isNord && Manager.GetActiveDeity() == Manager.PDV_Shor  && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Shor))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Tsun,  isNord && Manager.GetActiveDeity() == Manager.PDV_Tsun  && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Tsun))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Stuhn, isNord && Manager.GetActiveDeity() == Manager.PDV_Stuhn && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Stuhn))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Talos, isNord && Manager.GetActiveDeity() == Manager.PDV_Talos && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Talos))
    ; Nord Old Ways patrons (Orkey/Dibella roster). _activeDeity keys on the internal Arkay/Dibella
    ; deity, not the "Orkey" display name; the spell record carries the Orkey-facing name.
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.LedgerRuntime.PDV_SPEL_Neglect_Arkay,   isNord && Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Arkay   && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.LedgerRuntime.PDV_Arkay))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.LedgerRuntime.PDV_SPEL_Neglect_Dibella, isNord && Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Dibella && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.LedgerRuntime.PDV_Dibella))
EndFunction

Function SyncNordRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    EnsureNordOrkeyRewardRuntimeWiring()

    Bool isNord = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
    Int baselineState = GetNordPantheonBaselineState()
    SyncNordAncestorSubstrate(playerRef, isNord)
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Kyne, Manager.PDV_Bless_Nord_Kyne_T1, Manager.PDV_Bless_Nord_Kyne_T2, Manager.PDV_Bless_Nord_Kyne_T3, "Kyne")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Shor, Manager.PDV_Bless_Nord_Shor_T1, Manager.PDV_Bless_Nord_Shor_T2, Manager.PDV_Bless_Nord_Shor_T3, "Shor")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Tsun, Manager.PDV_Bless_Nord_Tsun_T1, Manager.PDV_Bless_Nord_Tsun_T2, Manager.PDV_Bless_Nord_Tsun_T3, "Tsun")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Stuhn, Manager.PDV_Bless_Nord_Stuhn_T1, Manager.PDV_Bless_Nord_Stuhn_T2, Manager.PDV_Bless_Nord_Stuhn_T3, "Stuhn")
    SyncNordRewardFamily(playerRef, -1, Manager.PDV_Talos, Manager.PDV_Bless_Nord_Talos_T1, Manager.PDV_Bless_Nord_Talos_T2, Manager.PDV_Bless_Nord_Talos_T3, "Talos")

    ; Nord Nine Divines gods have no Nord-specific reward records (never authored); reuse the
    ; existing Imperial Divine reward spells (the canonical Nine Divines rewards), identical to
    ; the Mara fix. Owner ruling 2026-06-27. NOTE: Akatosh/Julianos/Kynareth Imperial rewards are
    ; regen-rate (~0 under Requiem) -- a pre-existing Imperial reward-feel gap to convert later.
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Akatosh, Manager.PDV_Bless_Imperial_Akatosh_T1, Manager.PDV_Bless_Imperial_Akatosh_T2, Manager.PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    ; Mara is focusable in BOTH lanes (Old Ways + Nine Divines), like Talos -- baseline -1.
    ; No Nord-specific Mara reward records exist, so reuse the Imperial Mara spells -- this IS
    ; the Nine Divines Mara reward (Restoration +5/+13/+23 + wake-mended), identical across lanes.
    SyncNordRewardFamily(playerRef, -1, Manager.LedgerRuntime.PDV_Mara, Manager.PDV_Bless_Imperial_Mara_T1, Manager.PDV_Bless_Imperial_Mara_T2, Manager.PDV_Bless_Imperial_Mara_T3, "Mara")
    ; Arkay is focusable in BOTH lanes. Old Ways names him Orkey and uses
    ; Orkey-facing Nord reward records so Active Effects do not surface Arkay.
    ; Nine Divines keeps the existing Imperial Arkay rewards.
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.LedgerRuntime.PDV_Arkay, Manager.PDV_Bless_Nord_Arkay_T1, Manager.PDV_Bless_Nord_Arkay_T2, Manager.PDV_Bless_Nord_Arkay_T3, "Orkey")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Arkay, Manager.PDV_Bless_Imperial_Arkay_T1, Manager.PDV_Bless_Imperial_Arkay_T2, Manager.PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Stendarr, Manager.PDV_Bless_Imperial_Stendarr_T1, Manager.PDV_Bless_Imperial_Stendarr_T2, Manager.PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Zenithar, Manager.PDV_Bless_Imperial_Zenithar_T1, Manager.PDV_Bless_Imperial_Zenithar_T2, Manager.PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    ; Dibella is focusable in BOTH lanes (owner directive 2026-07-05), like Mara --
    ; baseline -1, same Imperial reward reuse either way.
    SyncNordRewardFamily(playerRef, -1, Manager.LedgerRuntime.PDV_Dibella, Manager.PDV_Bless_Imperial_Dibella_T1, Manager.PDV_Bless_Imperial_Dibella_T2, Manager.PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Julianos, Manager.PDV_Bless_Imperial_Julianos_T1, Manager.PDV_Bless_Imperial_Julianos_T2, Manager.PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Kynareth, Manager.PDV_Bless_Imperial_Kynareth_T1, Manager.PDV_Bless_Imperial_Kynareth_T2, Manager.PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
EndFunction

Function SyncNordAncestorSubstrate(Actor playerRef, Bool isNord)
    if !playerRef || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    if isNord
        Manager.PDV_NordAncestorSubstrate.RecomputeSubstrateTier()
    else
        Manager.PDV_NordAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncNordRewardFamily(Actor playerRef, Int requiredBaseline, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool baselineOk = requiredBaseline < 0 || GetNordPantheonBaselineState() == requiredBaseline
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD && baselineOk && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Float activePiety = 0.0
    if isActive && deity
        activePiety = Manager.LedgerRuntime.GetPiety(deity)
    endIf
    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activePiety >= 85.0
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, False, "Nord " + label + " T1 compatibility")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activePiety >= 50.0 && activePiety < 85.0, "Nord " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Nord " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Nord " + label)
EndFunction

Int Function GetNordPantheonBaselineState()
    Int stateValue = StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState", Manager.NORD_BASELINE_OLD_WAYS)
    if Manager.PDV_NordPantheonBaselineTrack
        stateValue = Manager.PDV_NordPantheonBaselineTrack.GetCurrentState()
        StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", stateValue)
    endIf

    return stateValue
EndFunction

Function EvaluateKyneCommitmentOffer()
    Manager.LedgerRuntime.EvaluateFormalCommitmentOffer()
EndFunction

Message Function GetNordFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Kyne
        return Manager.PDV_Msg_Nord_Kyne_Offer
    elseIf deity == Manager.PDV_Shor
        return Manager.PDV_Msg_Nord_Shor_Offer
    elseIf deity == Manager.PDV_Tsun
        return Manager.PDV_Msg_Nord_Tsun_Offer
    elseIf deity == Manager.PDV_Stuhn
        return Manager.PDV_Msg_Nord_Stuhn_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return Manager.PDV_Msg_Nord_Akatosh_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return Manager.PDV_Msg_Nord_Mara_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
            return Manager.PDV_Msg_Nord_Orkey_Offer
        endIf
        return Manager.PDV_Msg_Nord_Arkay_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Stendarr
        return Manager.PDV_Msg_Nord_Stendarr_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return Manager.PDV_Msg_Nord_Zenithar_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return Manager.PDV_Msg_Nord_Julianos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return Manager.PDV_Msg_Nord_Dibella_Offer
    elseIf deity == Manager.PDV_Talos
        return Manager.PDV_Msg_Nord_Talos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return Manager.PDV_Msg_Nord_Kynareth_Offer
    endIf

    return None
EndFunction

Bool Function IsKyneCommitmentSignalReady()
    if !Manager.PDV_Kyne
        return False
    endIf

    return Manager.LedgerRuntime.HasRecentCommitmentSignalDays(Manager.PDV_Kyne, 2, 7)
EndFunction

Bool Function IsNordOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf

    if deity == Manager.PDV_Talos
        return True
    endIf

    Int baselineState = GetNordPantheonBaselineState()
    if baselineState == Manager.NORD_BASELINE_OLD_WAYS
        return deity == Manager.PDV_Kyne || deity == Manager.PDV_Shor || deity == Manager.PDV_Tsun || deity == Manager.PDV_Stuhn || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Dibella
    elseIf baselineState == Manager.NORD_BASELINE_NINE_DIVINES
        return deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Zenithar || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Kynareth
    endIf

    return False
EndFunction

Function ApplyNordCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressNordCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 0)
        Manager.FavorRuntime.ClearActiveFavor("nord_vampire")
        Manager.LedgerRuntime.ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_VampireOnset, "Sovngarde is closed while the thirst remains. Cure the curse, and the scar will still be remembered.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 1)
        endIf
    elseIf oldState == 2 && newState != 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireCureFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_VampireCured, "The thirst is gone. The road opens again, but the scar remains.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_WerewolfOnset, "The hunt pulls against Sovngarde. Master the beast, or it will master you.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        ; oldState == 2 is claimed by the vampire-cure branch above, so reaching
        ; here with oldState == 1 is the werewolf cure and nothing else.
        if oldState == 1 && StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_WerewolfCured, "The hunt is set down. Hircine's hold is broken, and Sovngarde calls you once more.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 1)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 0)
    endIf
EndFunction

Bool Function ShouldSuppressNordCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowNordMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("kyne", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ShowNordNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("kyne", "neutral", "", fallbackText)
EndFunction

Function ApplyNordInitialChoice(Int baselineValue, String reason)
    Manager.BeginRaceSetupQuietPresentation(reason)
    Int normalized = PDV_DevotionRules.ClampInt(baselineValue, Manager.NORD_BASELINE_OLD_WAYS, Manager.NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalized)
    if Manager.PDV_NordPantheonBaselineTrack
        Manager.PDV_NordPantheonBaselineTrack.SetState(normalized, reason)
    endIf

    Manager.LedgerRuntime.SetBroadWorship()
    String baselineLabel = "Old Ways"
    if normalized == Manager.NORD_BASELINE_NINE_DIVINES
        baselineLabel = "Nine Divines"
    endIf
    Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(baselineLabel), Utility.GetCurrentGameTime() as Int, "reorientation", "journal", True, 3, "", True)
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

Int Function GetNordRouteFamilyFromSource(String sourceId)
    if sourceId == ""
        return Manager.NORD_ROUTE_UNKNOWN
    endIf

    if PDV_DevotionRules.StringContainsToken(sourceId, "sky_road") || PDV_DevotionRules.StringContainsToken(sourceId, "sky-road") || PDV_DevotionRules.StringContainsToken(sourceId, "storm_road") || PDV_DevotionRules.StringContainsToken(sourceId, "road_grace")
        if PDV_DevotionRules.StringContainsToken(sourceId, "nine")
            return Manager.NORD_ROUTE_NINE_ROAD
        endIf
        return Manager.NORD_ROUTE_OLD_SKY_ROAD
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ordeal") || PDV_DevotionRules.StringContainsToken(sourceId, "trial") || PDV_DevotionRules.StringContainsToken(sourceId, "adversity")
        return Manager.NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hearth") || PDV_DevotionRules.StringContainsToken(sourceId, "hold") || PDV_DevotionRules.StringContainsToken(sourceId, "protect_bond")
        return Manager.NORD_ROUTE_OLD_HEARTH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ancestor") || PDV_DevotionRules.StringContainsToken(sourceId, "honored_dead")
        return Manager.NORD_ROUTE_OLD_ANCESTOR
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hircine") || PDV_DevotionRules.StringContainsToken(sourceId, "hunt")
        return Manager.NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "household") || PDV_DevotionRules.StringContainsToken(sourceId, "mercy")
        return Manager.NORD_ROUTE_NINE_MERCY
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "proper_death") || PDV_DevotionRules.StringContainsToken(sourceId, "proper-death") || PDV_DevotionRules.StringContainsToken(sourceId, "anti_necromancy") || PDV_DevotionRules.StringContainsToken(sourceId, "arkay")
        return Manager.NORD_ROUTE_NINE_DEATH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "honest_work") || PDV_DevotionRules.StringContainsToken(sourceId, "honest-work") || PDV_DevotionRules.StringContainsToken(sourceId, "learned_craft") || PDV_DevotionRules.StringContainsToken(sourceId, "zenithar")
        return Manager.NORD_ROUTE_NINE_WORK
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos_pressure") || PDV_DevotionRules.StringContainsToken(sourceId, "talos-pressure")
        return Manager.NORD_ROUTE_NINE_TALOS
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos") || PDV_DevotionRules.StringContainsToken(sourceId, "defiance")
        return Manager.NORD_ROUTE_OLD_TALOS
    endIf

    return Manager.NORD_ROUTE_UNKNOWN
EndFunction

Int Function GetNordFavorLaneForRouteFamily(Int familyValue)
    if familyValue >= Manager.NORD_ROUTE_NINE_ROAD
        return Manager.FavorRuntime.FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    if familyValue > Manager.NORD_ROUTE_UNKNOWN
        return Manager.FavorRuntime.FAVOR_LANE_NORD_BROAD_OLD_WAYS
    endIf

    return Manager.FavorRuntime.FAVOR_LANE_NONE
EndFunction

Int Function GetNordFavorFamilyForRouteFamily(Int familyValue)
    if familyValue == Manager.NORD_ROUTE_OLD_SKY_ROAD
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ORDEAL
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
    elseIf familyValue == Manager.NORD_ROUTE_OLD_HEARTH
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ANCESTOR
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
    elseIf familyValue == Manager.NORD_ROUTE_OLD_TALOS
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf familyValue == Manager.NORD_ROUTE_NINE_ROAD
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_ROAD_GRACE
    elseIf familyValue == Manager.NORD_ROUTE_NINE_MERCY
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
    elseIf familyValue == Manager.NORD_ROUTE_NINE_DEATH
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_PROPER_DEATH
    elseIf familyValue == Manager.NORD_ROUTE_NINE_WORK
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_HONEST_WORK
    elseIf familyValue == Manager.NORD_ROUTE_NINE_TALOS
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_TALOS_PRESSURE
    endIf

    return 0
EndFunction

Function AwardNordRouteFamilySignal(Int familyValue, Float multiplier)
    if familyValue == Manager.NORD_ROUTE_OLD_SKY_ROAD
        ; Kyne's curated sky-road milestone bump. Services broad Old Ways worship
        ; and a focused Kyne patron alike (direct deity award, patron-agnostic).
        if Manager.PDV_Kyne
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Kyne, Manager.PDV_Kyne.SIGNAL_SKY_ROAD, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ORDEAL
        if Manager.PDV_Tsun
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tsun, Manager.PDV_Tsun.SIGNAL_TRIAL_ENDURED, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_HEARTH
        if Manager.PDV_Stuhn
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Stuhn, Manager.PDV_Stuhn.SIGNAL_PROTECT_BOND, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ANCESTOR
        if Manager.PDV_Shor
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Shor, Manager.PDV_Shor.SIGNAL_HONORED_DEAD, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_TALOS || familyValue == Manager.NORD_ROUTE_NINE_TALOS
        if Manager.PDV_Talos
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_ROAD
        if Manager.LedgerRuntime.PDV_Kynareth
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Kynareth, Manager.LedgerRuntime.PDV_Kynareth.SIGNAL_OPEN_SKY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_MERCY
        if Manager.LedgerRuntime.PDV_Mara
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_DEATH
        if Manager.LedgerRuntime.PDV_Arkay
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Arkay, Manager.LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_WORK
        if Manager.LedgerRuntime.PDV_Zenithar
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zenithar, Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
        endIf
    endIf
EndFunction

Bool Function RouteNordFamily(String reason, String countKey, String lastReasonKey, String lastTimeKey, String traceLabel)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, traceLabel + " ignored for non-Nord origin.")
        return False
    endIf

    Int routeFamily = GetNordRouteFamilyFromSource(reason)
    if routeFamily == Manager.NORD_ROUTE_UNKNOWN
        Manager.Trace(2, traceLabel + " ignored: unknown source family token in " + reason)
        return False
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordRouteFamily." + routeFamily)

    Int laneValue = GetNordFavorLaneForRouteFamily(routeFamily)
    Int favorFamily = GetNordFavorFamilyForRouteFamily(routeFamily)
    if laneValue != Manager.FavorRuntime.FAVOR_LANE_NONE && favorFamily > 0
        Manager.FavorRuntime.TryActivateContextualFavor(laneValue, favorFamily, reason)
    endIf

    ; The old OldWaysContextCount is frozen after migration; other route
    ; counters remain telemetry for their non-migration families.
    if countKey != "PDV.Nord.OldWaysContextCount"
        StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    endIf
    StorageUtil.SetStringValue(None, lastReasonKey, reason)
    StorageUtil.SetFloatValue(None, lastTimeKey, Utility.GetCurrentGameTime())
    if multiplier > 0.0
        RecordNordAncestorSpine(reason, multiplier)
        AwardNordRouteFamilySignal(routeFamily, multiplier)
    endIf
    ; Nord broad/focused survey + reward state should react on the accepted source itself, not wait
    ; for the next dawn pass. This is especially visible on broad Old Ways T1, which otherwise does
    ; not appear until ProcessDawn even after the third accepted source has already been read.
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.Trace(2, traceLabel + " routed: " + reason)
    return True
EndFunction

Function HandleNordOldWaysState(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Old Ways state ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.OldWaysContextCount", "PDV.Nord.LastOldWaysReason", "PDV.Nord.LastOldWaysSignalTime", "Nord Old Ways state")
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            Manager.SurfaceP2BookReadNotice(reason, "Faith of the Holds", "The Divines honored in the holds stand nearer.")
        else
            Manager.SurfaceP2BookReadNotice(reason, "The Old Ways", "The elder gods of the Nords stand nearer.")
        endIf
    endIf
EndFunction

Function HandleNordKyneTalosContext(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Kyne/Talos context ignored for non-Nord origin.")
        return
    endIf

    RouteNordFamily(reason, "PDV.Nord.KyneTalosContextCount", "PDV.Nord.LastKyneTalosReason", "PDV.Nord.LastKyneTalosSignalTime", "Nord Kyne/Talos context")
EndFunction

Function HandleNordHircineArkayEdge(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Hircine/Arkay edge ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.HircineArkayEdgeCount", "PDV.Nord.LastHircineArkayReason", "PDV.Nord.LastHircineArkaySignalTime", "Nord Hircine/Arkay edge")
        Manager.SurfaceP2BookReadNotice(reason, "Hunt and grave", "Beast and rest blur at the edges.")
    endIf
EndFunction

Bool Function UsesNordOldWaysDeityNames()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf
    return GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
EndFunction

String Function GetNordMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("kyne", "Kyne", "god", "kyne", Manager.PDV_Kyne, "Sky, storm, hunt, and warrior-spirit.")
    entries = entries + "," + Manager.RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", Manager.LedgerRuntime.PDV_Kynareth, "The Nine Divines sky road.")
    entries = entries + "," + Manager.RosterMedallionEntry("talos", "Talos", "god", "talos", Manager.PDV_Talos, "Open defiance and human apotheosis.")
    entries = entries + "," + Manager.RosterMedallionEntry("shor", "Shor", "god", "shor", Manager.PDV_Shor, "The old king and afterlife road.")
    entries = entries + "," + Manager.RosterMedallionEntry("tsun", "Tsun", "god", "tsun", Manager.PDV_Tsun, "Trial, honor, and the threshold.")
    entries = entries + "," + Manager.RosterMedallionEntry("stuhn", "Stuhn", "god", "stuhn", Manager.PDV_Stuhn, "Mercy in war and fair ransom.")
    entries = entries + "," + Manager.RosterMedallionEntry("mara", "Mara", "god", "mara", Manager.LedgerRuntime.PDV_Mara, "Love, hearth, and compassion.")
    entries = entries + "," + Manager.RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", Manager.LedgerRuntime.PDV_Akatosh, "Time, order, and dragon authority.")
    String arkayRosterName = "Arkay"
    if UsesNordOldWaysDeityNames()
        arkayRosterName = "Orkey"
    endIf
    entries = entries + "," + Manager.RosterMedallionEntry("arkay", arkayRosterName, "god", "arkay", Manager.LedgerRuntime.PDV_Arkay, "Death, burial, and proper passage.")
    entries = entries + "," + Manager.RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", Manager.LedgerRuntime.PDV_Stendarr, "Mercy, justice, and protection.")
    entries = entries + "," + Manager.RosterMedallionEntry("julianos", "Julianos", "god", "julianos", Manager.LedgerRuntime.PDV_Julianos, "Law, learning, and craft of mind.")
    entries = entries + "," + Manager.RosterMedallionEntry("dibella", "Dibella", "god", "dibella", Manager.LedgerRuntime.PDV_Dibella, "Beauty, art, and embodied grace.")
    entries = entries + "," + Manager.RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", Manager.LedgerRuntime.PDV_Zenithar, "Work, trade, and honest craft.")
    return entries
EndFunction

Bool Function IsNordVampireSuppressed()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Nord.VampireActive") == 1
EndFunction

Bool Function HasNordVampireScar()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD && StorageUtil.GetIntValue(None, "PDV.Nord.VampireScar") == 1
EndFunction

String Function GetNordSurveyBaseText()
    String band = Manager.GetCurrentStandingBand()
    if IsNordVampireSuppressed()
        return "Standing: " + band + ". Sovngarde is closed while the thirst remains. Cure the curse to reopen the road."
    endIf

    String contextText = GetNordContextSurveyText()
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        String focusedText = "Standing: " + band + ". " + Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity()) + " names you."
        if IsFocusedPantheonBoonSuspended()
            return focusedText + " The commitment remains, but its boon is suspended until 50 piety." + contextText
        endIf
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == Manager.NORD_BASELINE_NINE_DIVINES
            return "Standing: " + band + ". You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath." + contextText
        endIf

        return "Standing: " + band + ". You honor the Old Ways broadly." + contextText
    endIf

    if Manager.PDV_HircinePath
        String hircineSummary = Manager.PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "Standing: " + band + ". The hunt pulls at the edge of the Old Ways. No patron has claimed you, but the beast is listening." + contextText
        endIf
    endIf

    return "Standing: " + band + ". No Nord patron has answered yet. Keep the rites, and the road will grow clearer." + contextText
EndFunction

String Function GetNordContextSurveyText()
    String text = ""
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS && Manager.LedgerRuntime.GetBroadPantheonStanding(Manager.LedgerRuntime.BROAD_PANTHEON_NORD_OLD) > 0.0
        text = text + " Recent acts confirm the old road."
    endIf
    if kyneTalosCount > 0
        text = text + " Kyne and Talos weigh on your road."
    endIf
    if edgeCount > 0
        text = text + " Hunt and death-duty are present, but remain edge pressures."
    endIf
    if Manager.PDV_NordAncestorSubstrate
        text = text + " The ancestor-line remains " + GetNordAncestorLayerLabel() + "."
    endIf
    return text
EndFunction

String Function GetNordAncestorLayerLabel()
    if !Manager.PDV_NordAncestorSubstrate
        return "quiet"
    endIf

    return Manager.PDV_NordAncestorSubstrate.GetAncestorPostureLabel()
EndFunction

String Function GetNordDevotionModeLabel()
    if IsNordVampireSuppressed()
        return "Vampire rupture"
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        return "Focused " + Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity())
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            return "Broad Nine Divines"
        endIf

        return "Broad Old Ways"
    endIf

    return "Unsettled"
EndFunction

String Function GetNordScarLabel()
    if HasNordVampireScar() && !IsNordVampireSuppressed()
        return "The vampire scar still shows. The road is open again, but not unmarked."
    endIf

    return ""
EndFunction

String Function GetNordAncestorSummary()
    if !Manager.PDV_NordAncestorSubstrate
        return "missing"
    endIf

    return Manager.PDV_NordAncestorSubstrate.GetPilotSummary()
EndFunction

String Function GetKyneFavorSummary()
    Int maskValue = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ActiveCount")
    return "mask=" + maskValue + ";conds=" + PDV_DevotionRules.CountSetBits(maskValue) + ";active=" + activeCount + ";generic=" + Manager.FavorRuntime.GetContextualFavorSummary()
EndFunction
