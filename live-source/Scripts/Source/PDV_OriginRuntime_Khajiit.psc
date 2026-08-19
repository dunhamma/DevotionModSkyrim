Scriptname PDV_OriginRuntime_Khajiit extends PDV_OriginRuntimeBase

; Khajiit origin adapter (ORIGIN tranche 2). Lane functions moved verbatim from
; PDV_OriginRuntimeBase; only the virtual overrides below are new code, and each
; one delegates straight to the named lane function it replaces at the boundary
; (ADR: references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md).
;
; Lunar substrate, moon phase / observation, focus + emphasis, road-home, and the
; Baan Dar / Rajhin / Alkosh / Azurah / Khenarthi focus deities all live here.

; --- Khajiit moon-observation state (moved verbatim from PDV_OriginRuntimeBase;
;     every reference to these lives inside this lane, so they move whole) ---
Int _khajiitMoonObservationsValidatedVersion = -1
String _khajiitMoonObservationsValidatedKey = ""
Bool _khajiitMoonObservationPending = False
Int _khajiitMoonObservationGeneration = 0
Float _khajiitMoonObservationStartRealTime = 0.0
Cell _khajiitMoonObservationCell = None
Float _khajiitMoonObservationX = 0.0
Float _khajiitMoonObservationY = 0.0
Float _khajiitMoonObservationZ = 0.0

; ---------------------------------------------------------------------------
; ADAPTER OVERRIDES -- the only new code in this file.
; ---------------------------------------------------------------------------

; -- Lifecycle --

Function EnsureRuntimeWiring()
    EnsureKhajiitObserveMoonsPower()
EndFunction

Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyKhajiitCurseHandlers(oldState, newState, reason)
EndFunction

Function EvaluateAtDawn()
    EvaluateKhajiitFocusedEmphasis()
    RefreshKhajiitLunarPosture("dawn")
EndFunction

; ApplyInitialChoice is NOT overridden: the Khajiit lane has no initial-choice
; handler (focused emphasis is derived from accrued weights, never chosen).

; -- State --

String Function GetOriginStateLabel()
    return GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis())
EndFunction

Int Function GetOriginStateValue()
    return GetKhajiitFocusedEmphasis()
EndFunction

String Function GetOriginSummary()
    return GetKhajiitLunarSummary()
EndFunction

String Function GetSurveyFragment()
    return GetKhajiitSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsKhajiitLunarNeglected()
EndFunction

; Long-tail reads. Every key resolves against the CURRENT focus/posture, because
; the frozen accessor carries no numeric argument; callers that need an
; arbitrary focus or phase index still have to use a named lane read.
String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "focus"
        return GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "focus-storage"
        return GetKhajiitFocusStorageLabel(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "focus-symbol"
        return GetKhajiitFocusSymbol(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "focus-shift"
        return GetKhajiitFocusShiftText(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "focus-standing"
        return GetKhajiitFocusStandingLine(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "focus-weight-key"
        return GetKhajiitFocusWeightKey(GetKhajiitFocusedEmphasis())
    elseIf detailKey == "lunar-posture"
        return GetKhajiitLunarPostureLabel()
    elseIf detailKey == "lunar-posture-display"
        return GetKhajiitLunarPostureDisplayLabelAt(GetKhajiitLunarPosture())
    elseIf detailKey == "lunar-posture-readout"
        return GetKhajiitLunarPostureReadout(GetKhajiitLunarPosture())
    elseIf detailKey == "lunar-summary"
        return GetKhajiitLunarSummary()
    elseIf detailKey == "lunar-tier"
        if !Manager.PDV_KhajiitLunarSubstrate
            return GetKhajiitLunarTierLabel(0)
        endIf
        return GetKhajiitLunarTierLabel(Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier())
    elseIf detailKey == "medallion-entries"
        return GetKhajiitMedallionEntriesJson()
    elseIf detailKey == "survey"
        return GetKhajiitSurveyText()
    elseIf detailKey == "medallion-sections"
        return MedallionSection("native", "Native worship", GetKhajiitMedallionEntriesJson())
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "focus"
        return GetKhajiitFocusedEmphasis()
    elseIf detailKey == "presiding-focus"
        return GetCurrentLunarPresidingFocus()
    elseIf detailKey == "favored-focus"
        return GetActiveLunarFavoredFocus()
    elseIf detailKey == "lunar-posture"
        return GetKhajiitLunarPosture()
    elseIf detailKey == "lunar-posture-derived"
        return DeriveKhajiitLunarPosture()
    elseIf detailKey == "moon-phase"
        return GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    elseIf detailKey == "lunar-substrate-tier"
        if !Manager.PDV_KhajiitLunarSubstrate
            return 0
        endIf
        return Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    elseIf detailKey == "lattice-resonating"
        if IsKhajiitLatticeResonating()
            return 1
        endIf
        return 0
    elseIf detailKey == "shadow-drift"
        if HasKhajiitShadowDrift()
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
    if signalId == "moon-observance"
        HandleKhajiitMoonObservance(magnitude as Int, reason)
        return True
    elseIf signalId == "moon-observation-process"
        ProcessPendingKhajiitMoonObservation(magnitude as Int)
        return True
    elseIf signalId == "lunar-substrate"
        HandleKhajiitLunarSubstrate(reason)
        return True
    elseIf signalId == "road-home"
        HandleKhajiitRoadHome(reason)
        return True
    elseIf signalId == "road-home-anchor"
        HandleKhajiitRoadHomeAnchor(magnitude as Int, reason)
        return True
    elseIf signalId == "baandar-road-trick"
        HandleKhajiitBaanDarRoadTrick(reason)
        return True
    elseIf signalId == "baandar-reversal"
        HandleKhajiitBaanDarReversal(reason)
        return True
    elseIf signalId == "baandar-betrayal"
        HandleKhajiitBaanDarBetrayal(reason)
        return True
    elseIf signalId == "rajhin-elegant-theft"
        HandleKhajiitRajhinElegantTheft(reason)
        return True
    elseIf signalId == "rajhin-legend-made"
        HandleKhajiitRajhinLegendMade(reason)
        return True
    elseIf signalId == "rajhin-botched-theft"
        HandleKhajiitRajhinBotchedTheft(reason)
        return True
    elseIf signalId == "alkosh-dragon-order"
        HandleKhajiitAlkoshDragonOrder(reason)
        return True
    elseIf signalId == "alkosh-named-dragon"
        HandleKhajiitAlkoshNamedDragon(reason)
        return True
    elseIf signalId == "alkosh-generic-dragon"
        HandleKhajiitAlkoshGenericDragon(reason)
        return True
    elseIf signalId == "alkosh-chaos-aid"
        HandleKhajiitAlkoshChaosAid(reason)
        return True
    elseIf signalId == "alkosh-word-drip"
        ProcessKhajiitAlkoshWordDrip()
        return True
    elseIf signalId == "azurah-desecration"
        HandleKhajiitAzurahDesecration(reason)
        return True
    elseIf signalId == "azurah-portent"
        TryUseKhajiitAzurahPortent(contextForm as Actor)
        return True
    elseIf signalId == "khenarthi-caravan-harm"
        HandleKhajiitKhenarthiCaravanHarm(reason)
        return True
    elseIf signalId == "khenarthi-caravan-aid"
        HandleKhajiitKhenarthiCaravanAid(reason)
        return True
    elseIf signalId == "focused-source"
        HandleKhajiitFocusedSource(reason)
        return True
    elseIf signalId == "focused-source-for-focus"
        HandleKhajiitFocusedSourceForFocus(magnitude as Int, reason)
        return True
    elseIf signalId == "focus-emphasis-evaluate"
        EvaluateKhajiitFocusedEmphasis()
        return True
    elseIf signalId == "lunar-posture-refresh"
        RefreshKhajiitLunarPosture(reason)
        return True
    elseIf signalId == "shadow-evidence"
        RecordKhajiitShadowEvidence(reason)
        return True
    elseIf signalId == "runtime-state-sync"
        SyncKhajiitRuntimeState()
        return True
    elseIf signalId == "phase-blessing-sync"
        SyncKhajiitPhaseBlessing()
        return True
    elseIf signalId == "lattice-resonance-sync"
        SyncKhajiitLatticeResonance(contextForm as Actor)
        return True
    elseIf signalId == "portent-power-sync"
        SyncKhajiitPortentPower(contextForm as Actor)
        return True
    elseIf signalId == "god-strength-boundary"
        ScheduleNextKhajiitGodStrengthBoundary()
        return True
    elseIf signalId == "outdoor-rest"
        ; base HandlePlayerSleepStop, Khajiit arm. The base decides WHETHER to fire this from
        ; the captured sleep-START context (hadSleepStartContext && sleepStartedOutside);
        ; the adapter must not re-sample the wake cell. Khajiit answers no generic "sleep-stop".
        HandleKhajiitRoadHome("outdoor_rest_" + reason)
        return True
    elseIf signalId == "crypt-clear-focus"
        ; base ApplyUndeadCryptClearReaction tail. Deliberate slot reuse: the deity NAME rides
        ; the reason parameter here. The "small" magnitude was a literal at the base call site.
        BridgeKhajiitMatrixFocus(reason, "small")
        return True
    endIf

    return False
EndFunction

; Value-returning siblings. These lane entry points hand a payload back to their
; caller, so they cannot ride HandleContextualSignal (whose Bool only means
; handled / not-handled). Actor extends Form, so the player rides contextForm and
; is cast back here.
;
; "moon-observation-begin" is load-bearing: BeginKhajiitMoonObservation returns
; the GENERATION TOKEN that PDV_ObserveMoonsEffect holds across its two-second
; wait and passes back to the "moon-observation-process" signal, which rejects any
; token that is not the current generation. Dropping the return would break stale-
; completion rejection for the whole delayed-observation protocol.
Int Function HandleContextualQuery(String signalId, String reason = "", Form contextForm = None)
    if signalId == "moon-observation-begin"
        return BeginKhajiitMoonObservation(contextForm as Actor)
    elseIf signalId == "baandar-rescue-eligible"
        ; PDV_KhajiitBaanDarRescueEffect consumes this predicate, so it needs the
        ; value channel too. 1 / 0 rather than Bool, per the frozen Int return.
        if CanExecuteKhajiitBaanDarRescue(contextForm as Actor)
            return 1
        endIf
        return 0
    endIf

    return 0
EndFunction

; HandleLocationChange is NOT overridden: the Khajiit lane has no location verb
; of any kind, so the inert base default is the honest answer.

; -- Upkeep --

Function SyncRaceRewards()
    SyncKhajiitEmphasisRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncKhajiitNeglectSpell(IsKhajiitLunarNeglected())
EndFunction

; -- Presentation --

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
    ShowKhajiitMessage(messageRecord, fallbackText, suppressModal)
EndFunction

; ShowOriginNotification is NOT overridden: ShowKhajiitMessage is the lane's only
; notifier and it is curse-transition gated (it consumes the one-shot race curse
; surface). Routing a generic notification through it would suppress a curse
; message, so the base no-op is left in place rather than inventing a mapping.

; GetFormalCommitmentOfferMessage is NOT overridden: the Khajiit lane has no
; per-deity formal-commitment Message record.

; ---------------------------------------------------------------------------
; LANE FUNCTIONS -- moved verbatim from PDV_OriginRuntimeBase. Bodies are
; byte-identical to the originals so the split stays provable against
; origin_golden.json. Do not edit them here.
; ---------------------------------------------------------------------------

Int Function GetKhajiitFocusForDeityName(String deityName)
    if deityName == "Khenarthi"
        return Manager.KHAJIIT_FOCUS_KHENARTHI
    elseIf deityName == "Azurah" || deityName == "Azura"
        return Manager.KHAJIIT_FOCUS_AZURAH
    elseIf deityName == "Baan Dar"
        return Manager.KHAJIIT_FOCUS_BAANDAR
    elseIf deityName == "Rajhin"
        return Manager.KHAJIIT_FOCUS_RAJHIN
    elseIf deityName == "Alkosh"
        return Manager.KHAJIIT_FOCUS_ALKOSH
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
EndFunction

Function BridgeKhajiitMatrixFocus(String deityName, String magnitude)
    Int focusValue = GetKhajiitFocusForDeityName(deityName)
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        return
    endIf

    Float base = Manager.KHAJIIT_FOCUS_MATRIX_DELTA
    if magnitude == "milestone"
        base = Manager.KHAJIIT_FOCUS_MATRIX_DELTA * 2.0
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMatrixFocus." + deityName)
    if multiplier <= 0.0
        return
    endIf

    AdjustKhajiitFocusedEmphasis(focusValue, base * multiplier, "matrix_focus_" + deityName)
    Manager.Trace(2, "Khajiit matrix focus bridge: " + deityName + " focus +" + (base * multiplier))
EndFunction

Int Function GetLunarPresidingFocus(Int phaseIndex)
    if phaseIndex == 1
        return Manager.KHAJIIT_FOCUS_ALKOSH      ; full moon -- order at its height, the dragon-sun
    elseIf phaseIndex == 2
        return Manager.KHAJIIT_FOCUS_AZURAH      ; waning gibbous -- twilight descending
    elseIf phaseIndex == 3
        return Manager.KHAJIIT_FOCUS_KHENARTHI   ; last quarter -- the road in balance
    elseIf phaseIndex == 4
        return Manager.KHAJIIT_FOCUS_RAJHIN      ; waning crescent -- fading into shadow
    elseIf phaseIndex == 5
        return Manager.KHAJIIT_FOCUS_RAJHIN      ; new moon -- the deepest dark, quiet theft
    elseIf phaseIndex == 6
        return Manager.KHAJIIT_FOCUS_BAANDAR     ; waxing crescent -- the pariah's edge emerging
    elseIf phaseIndex == 7
        return Manager.KHAJIIT_FOCUS_KHENARTHI   ; first quarter -- the road in balance
    elseIf phaseIndex == 8
        return Manager.KHAJIIT_FOCUS_AZURAH      ; waxing gibbous -- twilight ascending
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
EndFunction

Int Function GetKhajiitFocusForDeity(PDV_DeityBase deity)
    if !deity
        return Manager.KHAJIIT_FOCUS_NONE
    elseIf deity == Manager.PDV_Khenarthi
        return Manager.KHAJIIT_FOCUS_KHENARTHI
    elseIf deity == Manager.PDV_Azura
        return Manager.KHAJIIT_FOCUS_AZURAH
    elseIf deity == Manager.PDV_BaanDar
        return Manager.KHAJIIT_FOCUS_BAANDAR
    elseIf deity == Manager.PDV_Rajhin
        return Manager.KHAJIIT_FOCUS_RAJHIN
    elseIf deity == Manager.PDV_Alkosh
        return Manager.KHAJIIT_FOCUS_ALKOSH
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
EndFunction

Int Function GetCurrentLunarPresidingFocus()
    if !IsKhajiitOrigin()
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    return GetLunarPresidingFocus(GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()))
EndFunction

Int Function GetActiveLunarFavoredFocus()
    Int presidingFocus = GetCurrentLunarPresidingFocus()
    if presidingFocus == Manager.KHAJIIT_FOCUS_NONE || presidingFocus != GetKhajiitFocusedEmphasis()
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    PDV_DeityBase deity = GetKhajiitEmphasisDeity(presidingFocus)
    if !deity || Manager.LedgerRuntime.GetPiety(deity) < 25.0
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    return presidingFocus
EndFunction

Spell Function GetKhajiitPhaseBlessing(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_Bless_Khajiit_Phase_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_Bless_Khajiit_Phase_Azurah
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_Bless_Khajiit_Phase_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_Bless_Khajiit_Phase_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_Bless_Khajiit_Phase_Alkosh
    endIf

    return None
EndFunction

Function SyncKhajiitPhaseBlessing()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Int focusValue = 1
    while focusValue <= 5
        Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, GetKhajiitPhaseBlessing(focusValue), False, "retired Khajiit phase blessing " + GetKhajiitFocusLabel(focusValue))
        focusValue += 1
    endWhile
EndFunction

Bool Function IsKhajiitLatticeResonating()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return False
    endIf
    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue == Manager.KHAJIIT_FOCUS_NONE || focusValue != GetCurrentLunarPresidingFocus()
        return False
    endIf
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    return deity && Manager.LedgerRuntime.GetPiety(deity) >= 25.0
EndFunction

Spell Function GetKhajiitFocusedRewardSpell(Int focusValue, Int tierValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Khenarthi_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Khenarthi_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Khenarthi_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Azurah_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Azurah_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Azurah_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_BaanDar_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_BaanDar_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_BaanDar_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Rajhin_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Rajhin_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Rajhin_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Alkosh_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Alkosh_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Alkosh_T1
        endIf
    endIf
    return None
EndFunction

Function RefreshKhajiitFocusedRewardForResonance(Actor playerRef)
    Int focusValue = GetKhajiitFocusedEmphasis()
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    if !playerRef || !deity
        return
    endIf
    Spell rewardSpell = GetKhajiitFocusedRewardSpell(focusValue, Manager.LedgerRuntime.GetTier(deity))
    if rewardSpell && playerRef.HasSpell(rewardSpell)
        playerRef.RemoveSpell(rewardSpell)
        playerRef.AddSpell(rewardSpell, False)
    endIf
EndFunction

Function SyncKhajiitLatticeResonance(Actor playerRef)
    if !playerRef
        return
    endIf
    Bool shouldResonate = IsKhajiitLatticeResonating()
    Bool wasResonating = StorageUtil.GetIntValue(None, "PDV.Khajiit.LatticeResonating") == 1
    if shouldResonate
        if Manager.PDV_PERK_Khajiit_LatticeResonance && !playerRef.HasPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
            playerRef.AddPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
        endIf
        if Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker && !playerRef.HasSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
            playerRef.AddSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker, False)
        endIf
    else
        if Manager.PDV_PERK_Khajiit_LatticeResonance && playerRef.HasPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
            playerRef.RemovePerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
        endIf
        if Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker && playerRef.HasSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
        endIf
    endIf
    if shouldResonate != wasResonating
        if shouldResonate
            StorageUtil.SetIntValue(None, "PDV.Khajiit.LatticeResonating", 1)
        else
            StorageUtil.SetIntValue(None, "PDV.Khajiit.LatticeResonating", 0)
        endIf
        RefreshKhajiitFocusedRewardForResonance(playerRef)
        Manager.RequestPanelRefresh()
        Manager.Trace(1, "Khajiit Lattice Resonance " + shouldResonate)
    endIf
EndFunction

Function SyncKhajiitPortentPower(Actor playerRef)
    if !playerRef || !Manager.PDV_Power_Khajiit_AzurahPortent
        return
    endIf
    PDV_DeityBase focusDeity = GetKhajiitEmphasisDeity(GetKhajiitFocusedEmphasis())
    Bool shouldHave = GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT && focusDeity == Manager.PDV_Azura && Manager.LedgerRuntime.GetTier(focusDeity) >= Manager.LedgerRuntime.TIER_CHAMPION && playerRef.HasSpell(Manager.PDV_Bless_Khajiit_Azurah_T3)
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Power_Khajiit_AzurahPortent, shouldHave, "Azurah Portent power")
EndFunction

Bool Function TryUseKhajiitAzurahPortent(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_AZURAH
        return False
    endIf
    if !Manager.PDV_Azura || Manager.LedgerRuntime.GetTier(Manager.PDV_Azura) < Manager.LedgerRuntime.TIER_CHAMPION || !Manager.PDV_Bless_Khajiit_Azurah_T3 || !playerRef.HasSpell(Manager.PDV_Bless_Khajiit_Azurah_T3)
        SyncKhajiitPortentPower(playerRef)
        return False
    endIf

    Int currentDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.AzurahPortent.Day") == currentDay
        if Manager.PDV_SND_Khajiit_AzurahPortentFizzle
            Manager.PDV_SND_Khajiit_AzurahPortentFizzle.Play(playerRef)
        endIf
        return False
    endIf
    if !Manager.PDV_SPEL_Khajiit_AzurahPortentDetect
        return False
    endIf

    StorageUtil.SetIntValue(None, "PDV.Khajiit.AzurahPortent.Day", currentDay)
    Manager.PDV_SPEL_Khajiit_AzurahPortentDetect.Cast(playerRef, playerRef)
    String portentText = "For a moment, living hearts, restless dead, fallen bodies, Daedra, and brass minds declare their places."
    Manager.SendPrismaToast("azurah", "good", "Azurah's Portent", portentText)
    Manager.AppendBookOfDaysEntry(portentText, Utility.GetCurrentGameTime() as Int, "champion.act", "azurah", False, 1, "Azurah's Portent")
    return True
EndFunction

Bool Function CanExecuteKhajiitBaanDarRescue(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_BAANDAR
        return False
    endIf
    if !Manager.PDV_BaanDar || Manager.LedgerRuntime.GetTier(Manager.PDV_BaanDar) < Manager.LedgerRuntime.TIER_CHAMPION || !Manager.PDV_Bless_Khajiit_BaanDar_T3
        return False
    endIf
    return playerRef.HasSpell(Manager.PDV_Bless_Khajiit_BaanDar_T3)
EndFunction

Function ScheduleNextKhajiitGodStrengthBoundary()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        UnregisterForUpdateGameTime()
        return
    endIf
    Float nowTime = Utility.GetCurrentGameTime()
    Int currentPhase = GetKhajiitMoonPhaseFromGameDay(nowTime)
    Int currentBucket = (nowTime + 0.5) as Int
    Int candidateBucket = currentBucket + 1
    while candidateBucket < currentBucket + 5 && GetKhajiitMoonPhaseFromGameDay((candidateBucket as Float) - 0.5) == currentPhase
        candidateBucket += 1
    endWhile
    Float hoursUntilBoundary = (((candidateBucket as Float) - 0.5) - nowTime) * 24.0
    if hoursUntilBoundary < 0.05
        hoursUntilBoundary = 0.05
    endIf
    RegisterForSingleUpdateGameTime(hoursUntilBoundary)
EndFunction

Function SyncKhajiitRuntimeState()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf
    if GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_NONE && StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged") == 0
        ; Existing focused saves are grandfathered without replaying the ceremony.
        StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged", 1)
    endIf
    SyncKhajiitEmphasisRewards(playerRef)
    SyncKhajiitPhaseBlessing()
    ScheduleNextKhajiitGodStrengthBoundary()
EndFunction

Function ProcessKhajiitAlkoshWordDrip()
    if !IsKhajiitOrigin()
        return
    endIf

    Int wordsNow = Game.QueryStat("Words Of Power Learned")
    Manager.Trace(3, "Khajiit Alkosh word drip: stat reads " + wordsNow)
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen.Init") == 0
        StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen.Init", 1)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen", wordsNow)
        return
    endIf

    Int wordsSeen = StorageUtil.GetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen")
    Int newWords = wordsNow - wordsSeen
    if newWords <= 0
        return
    endIf

    Int awarded = 0
    while awarded < newWords && awarded < 3
        Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitAlkoshWordOfPower")
        AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_ALKOSH, Manager.KHAJIIT_FOCUS_MATRIX_DELTA * multiplier, "alkosh_word_of_power")
        awarded += 1
    endWhile

    StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen", wordsSeen + awarded)
    Manager.Trace(2, "Khajiit Alkosh word-of-power drip awarded " + awarded + " of " + newWords + " new words")
    Manager.SendPrismaShiftToast("Words marked", "Alkosh orders new words.", GetKhajiitFocusSymbol(Manager.KHAJIIT_FOCUS_ALKOSH))
    Manager.LedgerRuntime.RecordRecentDevotionEvent("Alkosh: " + awarded + " words marked")
EndFunction

Float Function GetKhajiitLunarAlignmentMultiplier(PDV_DeityBase deity)
    return 1.0
EndFunction

Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)
    ; Compatibility ingress is intentionally inert. Only the validated
    ; two-second Observe the Moons power may award observance credit.
    Manager.Trace(2, "Legacy moon observance ignored: " + reason)
EndFunction

Function HandleKhajiitLunarSubstrate(String sourceId)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || !Manager.PDV_KhajiitLunarSubstrate
        return
    endIf

    ; Curated books and exact quest milestones are cultural substitutes. They
    ; claim the shared substrate day only; deity piety/focus remains on its own
    ; specifically authored receiver route.
    Manager.PDV_KhajiitLunarSubstrate.RecordCulturalSubstitute("khajiit_lunar_source", "p2_khajiit_lunar_" + sourceId)
    Manager.RequestPanelRefresh()
EndFunction

Function EnsureKhajiitObserveMoonsPower()
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_Power_Khajiit_ObserveMoons
        return
    endIf
    if IsKhajiitOrigin()
        if !playerRef.HasSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
            playerRef.AddSpell(Manager.PDV_Power_Khajiit_ObserveMoons, False)
        endIf
        ; One-time migration: clear an obsolete hand assignment without
        ; changing the player's selected lesser power. Observe the Moons and
        ; Survey Devotion are peers in the same Power slot; selecting either in
        ; the Magic menu replaces the other in the ordinary Skyrim way.
    elseIf playerRef.HasSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
        playerRef.RemoveSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
    endIf
EndFunction

Int Function BeginKhajiitMoonObservation(Actor playerRef)
    if !playerRef || playerRef != Game.GetPlayer() || !IsValidKhajiitMoonObservationContext(playerRef)
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "invalid_start_context")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected start: invalid_start_context")
        return 0
    endIf
    if _khajiitMoonObservationPending
        if Utility.GetCurrentRealTime() - _khajiitMoonObservationStartRealTime > 30.0
            _khajiitMoonObservationPending = False
            Manager.Trace(1, "[PDV][MOON_RITE] cleared stale pending observation")
        else
            StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "already_pending")
            Manager.Trace(1, "[PDV][MOON_RITE] rejected start: already_pending")
            return 0
        endIf
    endIf

    _khajiitMoonObservationGeneration += 1
    if _khajiitMoonObservationGeneration <= 0
        _khajiitMoonObservationGeneration = 1
    endIf
    _khajiitMoonObservationPending = True
    _khajiitMoonObservationStartRealTime = Utility.GetCurrentRealTime()
    _khajiitMoonObservationCell = playerRef.GetParentCell()
    _khajiitMoonObservationX = playerRef.GetPositionX()
    _khajiitMoonObservationY = playerRef.GetPositionY()
    _khajiitMoonObservationZ = playerRef.GetPositionZ()
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "")
    Manager.Trace(1, "[PDV][MOON_RITE] started token=" + _khajiitMoonObservationGeneration)
    return _khajiitMoonObservationGeneration
EndFunction

Function ProcessPendingKhajiitMoonObservation(Int observationToken)
    if !_khajiitMoonObservationPending || observationToken <= 0 || observationToken != _khajiitMoonObservationGeneration
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: stale_token=" + observationToken)
        return
    endIf
    if Utility.GetCurrentRealTime() - _khajiitMoonObservationStartRealTime < 2.0
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "delay_incomplete")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: delay_incomplete token=" + observationToken)
        return
    endIf
    _khajiitMoonObservationPending = False
    Actor playerRef = Game.GetPlayer()
    if !IsValidKhajiitMoonObservationContext(playerRef) || playerRef.GetParentCell() != _khajiitMoonObservationCell
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "interrupted_context")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: interrupted_context token=" + observationToken)
        return
    endIf

    Float dx = playerRef.GetPositionX() - _khajiitMoonObservationX
    Float dy = playerRef.GetPositionY() - _khajiitMoonObservationY
    Float dz = playerRef.GetPositionZ() - _khajiitMoonObservationZ
    if (dx * dx) + (dy * dy) + (dz * dz) > 16384.0
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "moved_too_far")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: moved_too_far token=" + observationToken)
        return
    endIf

    CompleteKhajiitMoonObservation(playerRef)
EndFunction

Bool Function IsValidKhajiitMoonObservationContext(Actor playerRef)
    if !playerRef || !IsKhajiitOrigin() || playerRef.IsInCombat() || playerRef.IsOnMount() || playerRef.IsSwimming()
        return False
    endIf
    Cell currentCell = playerRef.GetParentCell()
    if !currentCell || currentCell.IsInterior()
        return False
    endIf
    Float nowTime = Utility.GetCurrentGameTime()
    Float hourOfDay = (nowTime - ((nowTime as Int) as Float)) * 24.0
    return hourOfDay >= 20.0 || hourOfDay < 5.0
EndFunction

Function CompleteKhajiitMoonObservation(Actor playerRef)
    Float nowTime = Utility.GetCurrentGameTime()
    Int phaseIndex = GetKhajiitMoonPhaseFromGameDay(nowTime)
    Int focusValue = GetLunarPresidingFocus(phaseIndex)
    Int tierBefore = Manager.LedgerRuntime.TIER_NONE
    Int tierAfter = Manager.LedgerRuntime.TIER_NONE
    Float metricBefore = 0.0
    Float metricAfter = 0.0
    if Manager.PDV_KhajiitLunarSubstrate
        metricBefore = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
        tierBefore = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
        Manager.PDV_KhajiitLunarSubstrate.ObserveMoonPhase(phaseIndex, "observe_moons_power")
        tierAfter = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
        metricAfter = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
    endIf

    Bool firstRiteToday = False
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Khajiit.MoonRite.PietyDay") != todayStamp
        firstRiteToday = True
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Khajiit.MoonRite.PietyDay")
        PDV_DeityBase presidingDeity = GetKhajiitEmphasisDeity(focusValue)
        if presidingDeity
            Manager.LedgerRuntime.AwardPietyInternal(presidingDeity, 0.4, True, "observe_moons_power")
        endIf
        StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", nowTime)
        ; Preserve the common actual-delta accounting path without emitting a
        ; second toast or Book entry; the authored contemplation below owns
        ; this rite's single player-facing presentation.
        Manager.SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, metricAfter - metricBefore, "", "lunar", GetKhajiitLunarTierLabel(tierAfter), False)
    endIf

    ShowKhajiitMoonContemplation(focusValue, firstRiteToday)
    SyncKhajiitRuntimeState()
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastPhase", phaseIndex)
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastFocus", focusValue)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.MoonRite.LastSuccessTime", nowTime)
    Manager.Trace(1, "[PDV][MOON_RITE] success phase=" + phaseIndex + " focus=" + focusValue + " metricDelta=" + (metricAfter - metricBefore))
    Manager.RequestPanelRefresh()
EndFunction

Function ShowKhajiitMoonContemplation(Int focusValue, Bool firstRiteToday)
    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        return
    endIf
    if !IsKhajiitMoonObservationJsonValid(focusValue)
        ShowKhajiitMoonContemplationFallback(focusValue, firstRiteToday)
        return
    endIf

    String deityKey = GetKhajiitMoonObservationDeityKey(focusValue)
    String lastId = StorageUtil.GetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId")
    Int excludedPoolIndex = -1
    Int i = 0
    while i < 16 && excludedPoolIndex < 0
        String candidatePath = "." + deityKey + "[" + i + "].id"
        if i >= 10
            candidatePath = ".shared[" + (i - 10) + "].id"
        endIf
        if JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, candidatePath, "") == lastId
            excludedPoolIndex = i
        endIf
        i += 1
    endWhile

    Int poolIndex = Utility.RandomInt(0, 15)
    if excludedPoolIndex >= 0
        poolIndex = Utility.RandomInt(0, 14)
        if poolIndex >= excludedPoolIndex
            poolIndex += 1
        endIf
    endIf

    String entryPath = "." + deityKey + "[" + poolIndex + "]"
    if poolIndex >= 10
        entryPath = ".shared[" + (poolIndex - 10) + "]"
    endIf
    String resolvedId = JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".id", "")
    String titleText = GetKhajiitFocusLabel(focusValue) + " in Strength - " + JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".title", "")
    String bodyText = JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".body", "")
    Manager.SendPrismaToast(GetKhajiitFocusSymbol(focusValue), "good", titleText, bodyText)
    if firstRiteToday
        Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "substrate.act", GetKhajiitFocusSymbol(focusValue), False, 1, titleText)
    endIf
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId", resolvedId)
EndFunction

Bool Function IsKhajiitMoonObservationJsonValid(Int focusValue)
    ; Load/IsGood run every call -- see _khajiitMoonObservationsValidatedVersion for why they are not
    ; cached. The cache is keyed on deityKey as well as VERSION: each focus deity has its own 10-entry
    ; pool, so validating khenarthi says nothing about alkosh.
    String deityKey = GetKhajiitMoonObservationDeityKey(focusValue)
    if deityKey == "" || !JsonUtil.Load(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE) || !JsonUtil.IsGood(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE)
        _khajiitMoonObservationsValidatedVersion = -1
        _khajiitMoonObservationsValidatedKey = ""
        return False
    endIf
    if _khajiitMoonObservationsValidatedVersion == Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION && _khajiitMoonObservationsValidatedKey == deityKey
        return True
    endIf
    if JsonUtil.GetPathIntValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, ".version", -1) != Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION
        return False
    endIf
    if JsonUtil.PathCount(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, ".shared") != 6 || JsonUtil.PathCount(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, "." + deityKey) != 10
        return False
    endIf
    Int poolIndex = 0
    while poolIndex < 16
        String entryPath = "." + deityKey + "[" + poolIndex + "]"
        if poolIndex >= 10
            entryPath = ".shared[" + (poolIndex - 10) + "]"
        endIf
        if JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".id", "") == "" || JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".title", "") == "" || JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".body", "") == ""
            return False
        endIf
        poolIndex += 1
    endWhile
    _khajiitMoonObservationsValidatedVersion = Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION
    _khajiitMoonObservationsValidatedKey = deityKey
    return True
EndFunction

String Function GetKhajiitMoonObservationDeityKey(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "azurah"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "baandar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "alkosh"
    endIf
    return ""
EndFunction

Function ShowKhajiitMoonContemplationFallback(Int focusValue, Bool firstRiteToday)
    Int localIndex = Utility.RandomInt(0, 3)
    Int messageIndex = ((focusValue - 1) * 4) + localIndex
    Int lastIndex = StorageUtil.GetIntValue(None, "PDV.Khajiit.MoonRite.LastMessage", -1)
    if messageIndex == lastIndex
        localIndex = (localIndex + 1) % 4
        messageIndex = ((focusValue - 1) * 4) + localIndex
    endIf
    String titleText = GetKhajiitFocusLabel(focusValue) + " in Strength - " + GetKhajiitMoonContemplationTitle(messageIndex)
    String bodyText = GetKhajiitMoonContemplationText(messageIndex)
    Manager.SendPrismaToast(GetKhajiitFocusSymbol(focusValue), "good", titleText, bodyText)
    if firstRiteToday
        Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "substrate.act", GetKhajiitFocusSymbol(focusValue), False, 1, titleText)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastMessage", messageIndex)
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId", "fallback_" + messageIndex)
EndFunction

String Function GetKhajiitMoonContemplationTitle(Int messageIndex)
    if messageIndex == 0
        return "The Road Breathes"
    elseIf messageIndex == 1
        return "A Windward Home"
    elseIf messageIndex == 2
        return "The Open Mile"
    elseIf messageIndex == 3
        return "Breath Between Steps"
    elseIf messageIndex == 4
        return "Twilight's Mirror"
    elseIf messageIndex == 5
        return "A Name at Dusk"
    elseIf messageIndex == 6
        return "Shadow With Shape"
    elseIf messageIndex == 7
        return "The Liminal Hour"
    elseIf messageIndex == 8
        return "The Unlatched Gate"
    elseIf messageIndex == 9
        return "Luck Turned Sideways"
    elseIf messageIndex == 10
        return "The Laughing Escape"
    elseIf messageIndex == 11
        return "Clever Hands, Clear Debt"
    elseIf messageIndex == 12
        return "A Secret Kept"
    elseIf messageIndex == 13
        return "The Audacious Step"
    elseIf messageIndex == 14
        return "Limits in Silver"
    elseIf messageIndex == 15
        return "The Purring Question"
    elseIf messageIndex == 16
        return "The Ordered Sky"
    elseIf messageIndex == 17
        return "A Dragon's Measure"
    elseIf messageIndex == 18
        return "The Hour Unbroken"
    endIf
    return "Duty Beneath the Moons"
EndFunction

String Function GetKhajiitMoonContemplationText(Int messageIndex)
    if messageIndex == 0
        return "The wind crosses your whiskers like a road remembered. Khenarthi asks where you will return when the path grows quiet."
    elseIf messageIndex == 1
        return "Cloud and branch lean the same way tonight. Khenarthi teaches that a home may be carried without being abandoned."
    elseIf messageIndex == 2
        return "The sky leaves no walls around you. Khenarthi's road is freedom joined to the duty to return."
    elseIf messageIndex == 3
        return "For a moment, the wind stills. The pause belongs to Khenarthi as surely as the journey."
    elseIf messageIndex == 4
        return "Moonlight divides shadow from darkness. Azurah asks which parts of yourself you hide, and which you keep."
    elseIf messageIndex == 5
        return "The night changes every color without erasing it. Azurah keeps identity through every crossing."
    elseIf messageIndex == 6
        return "Your shadow lengthens beneath the moons. Azurah teaches that shadow can reveal the form that casts it."
    elseIf messageIndex == 7
        return "Neither day nor deepest night claims this hour. Azurah watches over the self made between worlds."
    elseIf messageIndex == 8
        return "A narrow opening is still an opening. Baan Dar favors the wit that finds a way without surrendering the self."
    elseIf messageIndex == 9
        return "The moons make familiar stones look strange. Baan Dar reminds you that reversal begins by seeing another angle."
    elseIf messageIndex == 10
        return "A distant night sound might be danger or laughter. Baan Dar prizes the survivor who can tell, then act."
    elseIf messageIndex == 11
        return "The road offers many exits. Baan Dar asks whether your cleverness frees only you, or those beside you."
    elseIf messageIndex == 12
        return "Moonlight reaches most places, but not all. Rajhin asks whether a secret is power, burden, or both."
    elseIf messageIndex == 13
        return "The next step lies beyond certainty. Rajhin honors audacity that knows the line it chooses to cross."
    elseIf messageIndex == 14
        return "The moons draw bright borders around the dark. Rajhin teaches that limits are clearest to those tempted to test them."
    elseIf messageIndex == 15
        return "Night keeps its answers close. Rajhin leaves you a question whose value lies in what you dare not say."
    elseIf messageIndex == 16
        return "The moons keep their courses without hurry. Alkosh teaches that order is not stillness, but motion kept true."
    elseIf messageIndex == 17
        return "Time stretches above you like a dragon's shadow. Alkosh asks what duty can survive both fear and glory."
    elseIf messageIndex == 18
        return "This moment will not return, yet it belongs to every moment after it. Alkosh keeps consequence within time."
    endIf
    return "The sky is vast, but each light holds its place. Alkosh reminds you that duty gives freedom a shape."
EndFunction

Function HandleKhajiitRoadHome(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_KhajiitLunarSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitRoadHome")
    Float metricBefore = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    Manager.PDV_KhajiitLunarSubstrate.RecordRoadHomeCadence(reason)
    Int tierAfter = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    Float grantedMetric = Manager.PDV_KhajiitLunarSubstrate.GetMetric() - metricBefore
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_KHENARTHI, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    if Manager.PDV_Khenarthi
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())

    ; Road-home recognition owns one presentation per 06:00 devotional cycle,
    ; independently of the shared lunar +4 budget. If another authentic lunar
    ; practice already spent that budget, the rest is still acknowledged without
    ; implying that it granted more substrate progress.
    String presentationDayKey = "PDV.Khajiit.RoadHome.PresentationDay"
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp(presentationDayKey) != todayStamp
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(presentationDayKey)
        if grantedMetric > 0.0
            Manager.SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, grantedMetric, "The road home was remembered.", "lunar", GetKhajiitLunarTierLabel(tierAfter))
        else
            String cappedContext = "The road home was remembered. Today's lunar practice was already marked."
            SendPrismaSubstrateToast("lunar", "act", cappedContext, "lunar", GetKhajiitLunarTierLabel(tierAfter))
            Manager.AppendBookOfDaysEntry(cappedContext, Utility.GetCurrentGameTime() as Int, "substrate.act", "lunar", False)
        endIf
    endIf
    Manager.NotifyDiegeticRoutineFavor("khajiit_road_home")
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier)
EndFunction

Function HandleKhajiitRoadHomeAnchor(Int anchorId, String reason)
    ; Retired anchor/circuit ingress must never award metric or piety.
    Manager.Trace(2, "Retired Khajiit road anchor ignored: " + anchorId + " (" + reason + ")")
EndFunction

Float Function ConsumeKhajiitLunarMetricBudget(Float requestedMetric)
    ; Compatibility-only. PDV_SubstrateBase owns the one daily +4 budget.
    return 0.0
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_BAANDAR, "PDV.Signal.KhajiitBaanDarRoadTrick", "Baan Dar road trick", reason)
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", "Rajhin elegant theft", reason)
    ; Night theft is shadow-coded behavior; it accrues toward the ShadowDrift boundary.
    RecordKhajiitShadowEvidence("rajhin_night_theft_" + reason)
    Manager.SendPrismaShiftToast("Elegant theft", "Rajhin purrs.", GetKhajiitFocusSymbol(Manager.KHAJIIT_FOCUS_RAJHIN))
    Manager.LedgerRuntime.RecordRecentDevotionEvent("Rajhin: theft with style")
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh dragon order", reason)
EndFunction

Function HandleKhajiitFocusedSource(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        focusValue = GetActiveLunarFavoredFocus()
    endIf
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        focusValue = Manager.KHAJIIT_FOCUS_AZURAH
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

Function HandleKhajiitFocusedSourceForFocus(Int focusValue, String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        HandleKhajiitFocusedSource(reason)
        return
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

Function HandleKhajiitAlkoshNamedDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh named dragon", reason)
    if Manager.PDV_Alkosh
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_NAMED_DRAGON, None, multiplier)
    endIf
    AwardKhajiitSubstrateSubstitute("khajiit_alkosh_milestone", reason)
    Manager.Trace(1, "Khajiit Alkosh named-dragon beat routed (" + reason + ")")
EndFunction

Function HandleKhajiitAlkoshGenericDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int weekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
    if StorageUtil.GetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week") == weekStamp
        Manager.Trace(2, "Khajiit Alkosh generic-dragon nudge suppressed by weekly cap (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week", weekStamp)
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_ALKOSH, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * 0.25, reason)
    Manager.Trace(2, "Khajiit Alkosh generic-dragon emphasis nudge routed (" + reason + ")")
EndFunction

Function HandleKhajiitBaanDarReversal(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitBaanDarReversal")
    StorageUtil.AdjustIntValue(None, "PDV.Signal.KhajiitBaanDarReversal.CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_BAANDAR, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * 2.0 * multiplier, reason)
    if Manager.PDV_BaanDar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_BANDIT_ROAD, None, multiplier)
    endIf
    AwardKhajiitSubstrateSubstitute("khajiit_baandar_reversal", reason)
    Manager.Trace(1, "Khajiit Baan Dar near-fatal reversal routed (" + reason + ")")
EndFunction

Float Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)
    if !IsKhajiitOrigin()
        return 0.0
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier(keyPrefix)
    StorageUtil.AdjustIntValue(None, keyPrefix + ".CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    ; The piety pulse must land before evaluation: focus emergence requires both
    ; behavioral dominance and actual Seeker piety on this same event.
    AdjustKhajiitFocusedEmphasis(focusValue, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason, False)
    PulseKhajiitFocusPiety(focusValue, multiplier)
    EvaluateKhajiitFocusedEmphasis()
    Manager.Trace(2, "Khajiit " + label + " routed with multiplier " + multiplier)
    return multiplier
EndFunction

PDV_DeityBase Function GetKhajiitEmphasisDeity(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_Azura
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_Alkosh
    endIf

    return None
EndFunction

Function PulseKhajiitFocusPiety(Int focusValue, Float multiplier)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI && Manager.PDV_Khenarthi
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR && Manager.PDV_BaanDar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_ROAD_TRICK, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN && Manager.PDV_Rajhin
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_ELEGANT_THEFT, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH && Manager.PDV_Alkosh
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_DRAGON_ORDER, None, multiplier)
    endIf
EndFunction

Function HandleKhajiitAzurahDesecration(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Azura
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DESECRATION, None)
    Manager.Trace(2, "Khajiit Azurah desecration routed (" + reason + ")")
EndFunction

Function HandleKhajiitKhenarthiCaravanHarm(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Khenarthi
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_CARAVAN_HARM, None)
    Manager.Trace(2, "Khajiit Khenarthi caravan-harm routed (" + reason + ")")
EndFunction

Function HandleKhajiitKhenarthiCaravanAid(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Khenarthi
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhenarthiCaravanAid")
    if multiplier <= 0.0
        Manager.Trace(2, "Khajiit Khenarthi caravan-aid blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_CARAVAN_AID, None, multiplier)
    AwardKhajiitSubstrateSubstitute("khajiit_caravan_defense", reason)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Khenarthi, "Caravan defended", "marks the caravan road kept safe.")
    Manager.Trace(2, "Khajiit Khenarthi caravan-aid routed (" + reason + ")")
EndFunction

Function HandleKhajiitRajhinLegendMade(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Rajhin
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RajhinLegendMade")
    if multiplier <= 0.0
        Manager.Trace(2, "Khajiit Rajhin legend-made blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_LEGEND_MADE, None, multiplier)
    AwardKhajiitSubstrateSubstitute("khajiit_rajhin_notable_theft", reason)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Rajhin, "Legend made", "marks a theft worth remembering.")
    Manager.Trace(2, "Khajiit Rajhin legend-made routed (" + reason + ")")
EndFunction

Function AwardKhajiitSubstrateSubstitute(String sourceId, String reason)
    if IsKhajiitOrigin() && Manager.PDV_KhajiitLunarSubstrate
        Manager.PDV_KhajiitLunarSubstrate.RecordCulturalSubstitute(sourceId, reason)
    endIf
EndFunction

Function HandleKhajiitRajhinBotchedTheft(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Rajhin
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_BOTCHED_THEFT, None)
    Manager.Trace(2, "Khajiit Rajhin botched-theft routed (" + reason + ")")
EndFunction

Function HandleKhajiitAlkoshChaosAid(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Alkosh
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_CHAOS_AID, None)
    Manager.Trace(2, "Khajiit Alkosh chaos-aid routed (" + reason + ")")
EndFunction

Function HandleKhajiitBaanDarBetrayal(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_BaanDar
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_BETRAYAL, None)
    Manager.Trace(2, "Khajiit Baan Dar betrayal routed (" + reason + ")")
EndFunction

Int Function GetKhajiitLunarPosture()
    if Manager.PDV_KhajiitLunarPostureTrack
        Int value = Manager.PDV_KhajiitLunarPostureTrack.GetCurrentState()
        if value < 0
            return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
        endIf
        return value
    endIf

    return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
EndFunction

Int Function DeriveKhajiitLunarPosture()
    if Manager.PDV_CurseStateService
        if Manager.PDV_CurseStateService.IsWerewolf()
            return Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        elseIf Manager.PDV_CurseStateService.IsVampire()
            return Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        endIf
    endIf

    if HasKhajiitShadowDrift()
        return Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
    endIf

    return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
EndFunction

Bool Function HasKhajiitShadowDrift()
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce") == 1
        return True
    endIf

    if !Manager.PDV_KhajiitLunarPostureTrack
        return False
    endIf

    return Manager.PDV_KhajiitLunarPostureTrack.HasRecentEvidenceDays(Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, Manager.KHAJIIT_SHADOWDRIFT_EVIDENCE_REQUIRED, Manager.KHAJIIT_SHADOWDRIFT_EVIDENCE_WINDOW)
EndFunction

Function RecordKhajiitShadowEvidence(String reason)
    if !Manager.PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Float gameTime = Utility.GetCurrentGameTime()
    Int dayInt = gameTime as Int
    Float hour = (gameTime - dayInt) * 24.0
    if hour < 19.0 && hour >= 7.0
        return
    endIf

    Manager.PDV_KhajiitLunarPostureTrack.RecordEvidenceDay(Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, reason)
    Manager.Trace(2, "Khajiit shadow-evidence day recorded (" + reason + ")")
EndFunction

Function RefreshKhajiitLunarPosture(String reason)
    if !Manager.PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Int oldPosture = GetKhajiitLunarPosture()
    Int newPosture = DeriveKhajiitLunarPosture()
    if newPosture == oldPosture
        return
    endIf

    Manager.PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    Manager.Trace(1, "Khajiit lunar posture " + oldPosture + " -> " + newPosture + " (" + reason + ")")

    if newPosture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars.", False)
    endIf

    if newPosture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        Manager.AppendBookOfDaysEntry("The moonlight scatters from your path. Corruption is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
    elseIf newPosture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        Manager.AppendBookOfDaysEntry("You slipped into the moons' shadow. Darkness is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
    endIf

    Manager.SendPrismaShiftToast(GetKhajiitLunarPostureDisplayLabelAt(newPosture), GetKhajiitLunarPostureReadout(newPosture), "lunar")
    Manager.RequestPanelRefresh()
EndFunction

String Function GetKhajiitLunarPostureLabel()
    return GetKhajiitLunarPostureLabelAt(GetKhajiitLunarPosture())
EndFunction

String Function GetKhajiitLunarPostureLabelAt(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Strained"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Corrupted"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "ShadowDrift"
    endIf

    return "Normal"
EndFunction

String Function GetKhajiitLunarPostureDisplayLabelAt(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Lattice strained"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Lattice thinned"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "Drifting to shadow"
    endIf

    return "Lattice clear"
EndFunction

String Function GetKhajiitLunarPostureReadout(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "The Lattice holds you, but strained. The beast-shape is a competing form, and the caravans keep their distance."
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "The Lattice still holds you, corrupted and thinned. The moons do not disown the undead, but the community does."
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars."
    endIf

    return "The Lunar Lattice holds you cleanly. The moons know your form, and the road knows your step."
EndFunction

Function ShowKhajiitMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("lunar", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyKhajiitCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.VampireOnsetShown") != 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_VampireOnset, "The thirst has taken you, little moon. The Lattice does not cast you out, but the caravans will fear you.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 1)
        endIf
    elseIf newState == 1
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown") != 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_WerewolfOnset, "Hircine has given you another shape. You are still Khajiit -- strained, watched, but not erased.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 1)
        endIf
    elseIf newState == 0
        if oldState == 2
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_VampireCured, "The thirst is gone. The corruption lifts from the Lattice; walk back into the moonlight.", False)
        elseIf oldState == 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_WerewolfCured, "The wolf is set down, little moon. The Lattice holds a single shape once more.", False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 0)
    endIf

    RefreshKhajiitLunarPosture("curse_" + reason)
EndFunction

Function AdjustKhajiitFocusedEmphasis(Int focusValue, Float amount, String reason, Bool evaluateNow = True)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return
    endIf

    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        return
    endIf

    String focusKey = GetKhajiitFocusWeightKey(focusValue)
    StorageUtil.AdjustFloatValue(None, focusKey, amount)
    if evaluateNow
        EvaluateKhajiitFocusedEmphasis()
    endIf
    Manager.Trace(2, "Khajiit focus " + GetKhajiitFocusLabel(focusValue) + " adjusted by " + amount + " (" + reason + ")")
EndFunction

Function EvaluateKhajiitFocusedEmphasis()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return
    endIf
    Float khenarthi = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_KHENARTHI)
    Float azurah = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_AZURAH)
    Float baanDar = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_BAANDAR)
    Float rajhin = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_RAJHIN)
    Float alkosh = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_ALKOSH)

    Int bestFocus = Manager.KHAJIIT_FOCUS_NONE
    Float bestWeight = 0.0
    if khenarthi > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_KHENARTHI
        bestWeight = khenarthi
    endIf
    if azurah > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_AZURAH
        bestWeight = azurah
    endIf
    if baanDar > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_BAANDAR
        bestWeight = baanDar
    endIf
    if rajhin > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_RAJHIN
        bestWeight = rajhin
    endIf
    if alkosh > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_ALKOSH
        bestWeight = alkosh
    endIf

    ; All five weights are already local. Re-reading the current leader from
    ; StorageUtil after every comparison added five external calls to every
    ; focus-bearing action without changing the strict-greater tie behavior.
    Float nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    ; Once a focus has emerged, a tie, lead loss, or later piety loss does not
    ; erase it. A replacement must independently satisfy both gates.
    if bestWeight < Manager.KHAJIIT_FOCUS_THRESHOLD || (bestWeight - nextWeight) < Manager.KHAJIIT_FOCUS_LEAD_REQUIRED
        return
    endIf

    PDV_DeityBase bestDeity = GetKhajiitEmphasisDeity(bestFocus)
    if !bestDeity || Manager.LedgerRuntime.GetPiety(bestDeity) < 25.0
        return
    endIf

    SetKhajiitFocusedEmphasis(bestFocus, "lead")
EndFunction

Float Function GetKhajiitSecondFocusWeight(Int bestFocus, Float khenarthi, Float azurah, Float baanDar, Float rajhin, Float alkosh)
    Float secondWeight = 0.0
    if bestFocus != Manager.KHAJIIT_FOCUS_KHENARTHI && khenarthi > secondWeight
        secondWeight = khenarthi
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_AZURAH && azurah > secondWeight
        secondWeight = azurah
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_BAANDAR && baanDar > secondWeight
        secondWeight = baanDar
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_RAJHIN && rajhin > secondWeight
        secondWeight = rajhin
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_ALKOSH && alkosh > secondWeight
        secondWeight = alkosh
    endIf
    return secondWeight
EndFunction

Function SetKhajiitFocusedEmphasis(Int focusValue, String reason)
    Int oldFocus = GetKhajiitFocusedEmphasis()
    if oldFocus != Manager.KHAJIIT_FOCUS_NONE && focusValue == Manager.KHAJIIT_FOCUS_NONE
        return
    endIf
    if oldFocus == focusValue
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusedEmphasis", focusValue)
    if Manager.PDV_GLO_KhajiitFocusedEmphasis
        Manager.PDV_GLO_KhajiitFocusedEmphasis.SetValue(focusValue as Float)
    endIf

    Manager.Trace(1, "Khajiit focused emphasis " + GetKhajiitFocusLabel(oldFocus) + " -> " + GetKhajiitFocusLabel(focusValue) + " (" + reason + ")")
    String focusText = GetKhajiitFocusShiftText(focusValue)
    Manager.SendPrismaShiftToast("Your road turns toward " + GetKhajiitFocusLabel(focusValue) + ".", focusText, GetKhajiitFocusSymbol(focusValue))
    Bool firstEmergence = oldFocus == Manager.KHAJIIT_FOCUS_NONE && StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged") == 0
    if firstEmergence
        StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged", 1)
        Message emergenceMessage = GetKhajiitFocusEmergenceMessage(focusValue)
        if emergenceMessage
            emergenceMessage.Show()
        else
            Debug.MessageBox(focusText)
        endIf
    endIf
    if firstEmergence
        Manager.AppendBookOfDaysEntry(focusText, Utility.GetCurrentGameTime() as Int, "focus.emergence", GetKhajiitFocusSymbol(focusValue), True, 1, GetKhajiitFocusLabel(focusValue) + " Emerges")
    else
        Manager.AppendBookOfDaysEntry(focusText, Utility.GetCurrentGameTime() as Int, "reorientation", GetKhajiitFocusSymbol(focusValue), False, 1, "The Road Turns")
    endIf
    SyncKhajiitRuntimeState()
    Manager.RequestPanelRefresh()
EndFunction

Message Function GetKhajiitFocusEmergenceMessage(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_MSG_KhajiitFocus_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_MSG_KhajiitFocus_Azurah
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_MSG_KhajiitFocus_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_MSG_KhajiitFocus_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_MSG_KhajiitFocus_Alkosh
    endIf
    return None
EndFunction

Int Function GetKhajiitFocusedEmphasis()
    return StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusedEmphasis")
EndFunction

PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)
    return GetKhajiitEmphasisDeity(focusValue)
EndFunction

Float Function GetKhajiitFocusWeight(Int focusValue)
    return StorageUtil.GetFloatValue(None, GetKhajiitFocusWeightKey(focusValue))
EndFunction

String Function GetKhajiitFocusWeightKey(Int focusValue)
    return "PDV.Khajiit.Focus." + GetKhajiitFocusStorageLabel(focusValue)
EndFunction

String Function GetKhajiitFocusLabel(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "Azurah"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "Rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "Alkosh"
    endIf

    return "None"
EndFunction

String Function GetKhajiitFocusStorageLabel(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "BaanDar"
    endIf

    return GetKhajiitFocusLabel(focusValue)
EndFunction

String Function GetKhajiitFocusShiftText(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi's wind has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "Azurah's dusk-bright road has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar's road has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "Rajhin's clever path has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "Alkosh's order has found your steps."
    endIf

    return "The Lunar Lattice has found a new shape in your practice."
EndFunction

Function SyncKhajiitEmphasisRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Int activeFocus = Manager.KHAJIIT_FOCUS_NONE
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
        activeFocus = GetKhajiitFocusedEmphasis()
        PDV_DeityBase deity = GetKhajiitEmphasisDeity(activeFocus)
        if deity
            activeTier = Manager.LedgerRuntime.GetTier(deity)
        endIf
    endIf

    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_KHENARTHI, activeFocus, activeTier, Manager.PDV_Khenarthi, Manager.PDV_Bless_Khajiit_Khenarthi_T1, Manager.PDV_Bless_Khajiit_Khenarthi_T2, Manager.PDV_Bless_Khajiit_Khenarthi_T3, "Khenarthi")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_AZURAH, activeFocus, activeTier, Manager.PDV_Azura, Manager.PDV_Bless_Khajiit_Azurah_T1, Manager.PDV_Bless_Khajiit_Azurah_T2, Manager.PDV_Bless_Khajiit_Azurah_T3, "Azurah")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_BAANDAR, activeFocus, activeTier, Manager.PDV_BaanDar, Manager.PDV_Bless_Khajiit_BaanDar_T1, Manager.PDV_Bless_Khajiit_BaanDar_T2, Manager.PDV_Bless_Khajiit_BaanDar_T3, "Baan Dar")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_RAJHIN, activeFocus, activeTier, Manager.PDV_Rajhin, Manager.PDV_Bless_Khajiit_Rajhin_T1, Manager.PDV_Bless_Khajiit_Rajhin_T2, Manager.PDV_Bless_Khajiit_Rajhin_T3, "Rajhin")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_ALKOSH, activeFocus, activeTier, Manager.PDV_Alkosh, Manager.PDV_Bless_Khajiit_Alkosh_T1, Manager.PDV_Bless_Khajiit_Alkosh_T2, Manager.PDV_Bless_Khajiit_Alkosh_T3, "Alkosh")
    SyncKhajiitLatticeResonance(playerRef)
    SyncKhajiitPortentPower(playerRef)
EndFunction

Function SyncKhajiitEmphasisFamily(Actor playerRef, Int thisFocus, Int activeFocus, Int activeTier, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = (thisFocus == activeFocus)
    Bool hadChampionSpell = False
    if t3
        hadChampionSpell = playerRef.HasSpell(t3)
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Khajiit " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Khajiit " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION, "Khajiit " + label + " T3")

    if isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION && t3 && !hadChampionSpell && playerRef.HasSpell(t3) && deity && Manager.LedgerRuntime.NotifyTierUp(deity, Manager.LedgerRuntime.TIER_CHAMPION)
        Manager.SendPrismaEventToast("tier", deity, "", Manager.GetPublicTierBand(Manager.LedgerRuntime.TIER_CHAMPION), "")
        Manager.SurfaceTransition("tier", deity.DeityName + " " + Manager.GetTierStandingLabel(Manager.LedgerRuntime.TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)
        Manager.Trace(1, "Khajiit Champion reward presentation shown: " + deity.DeityName)
    endIf
EndFunction

Bool Function IsKhajiitLunarNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > Manager.KHAJIIT_LUNAR_NEGLECT_GRACE_DAYS
EndFunction

Function SyncKhajiitNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_KhajiitLunar
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
    endIf
EndFunction

String Function GetKhajiitFocusSymbol(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "azura"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "baan-dar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "alkosh"
    endIf
    return "lunar"
EndFunction

String Function GetKhajiitMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("azura", "Azurah", "prince", "azura", Manager.PDV_Azura, "Dusk, dawn, moon-shadow, and fate.")
    entries = entries + "," + Manager.RosterMedallionEntry("boethiah", "Boethra", "prince", "boethiah", Manager.PDV_Boethiah, "Trial, edge, and hard lessons.")
    entries = entries + "," + Manager.RosterMedallionEntry("mephala", "Mafala", "prince", "mephala", Manager.PDV_Mephala, "Hidden paths, webs, and clan memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", Manager.PDV_BaanDar, "The bandit god, wit, and road survival.")
    entries = entries + "," + Manager.RosterMedallionEntry("rajhin", "Rajhin", "god", "rajhin", Manager.PDV_Rajhin, "The clever thief and impossible escape.")
    entries = entries + "," + Manager.RosterMedallionEntry("alkosh", "Alkosh", "god", "alkosh", Manager.PDV_Alkosh, "Dragon order and time in Khajiit memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("khenarthi", "Khenarthi", "god", "khenarthi", Manager.PDV_Khenarthi, "Wind, sky-road, and breath.")
    entries = entries + "," + Manager.PendingMedallionEntry("riddle-thar", "Riddle'Thar", "god", "riddle-thar", "Balance, ja-Kha'jay, and right conduct.")
    entries = entries + "," + Manager.PendingMedallionEntry("jone-jode", "Jone and Jode", "god", "lunar", "The moons, the lattice, and the road home.")
    return entries
EndFunction

String Function GetKhajiitSurveyText()
    String band = Manager.GetCurrentStandingBand()
    Int focusValue = GetKhajiitFocusedEmphasis()
    String text = ""
    if focusValue > Manager.KHAJIIT_FOCUS_NONE
        text = "You walk inside the Lunar Lattice, and " + GetKhajiitFocusLabel(focusValue) + " leads your devotion now. Standing: " + band + ". You did not choose it; you were walking it."
    else
        text = "You walk inside the Lunar Lattice, broad and unfocused, held by the moons and the road. Standing: " + band + ". No god leads yet, and that is whole."
    endIf

    if Manager.PDV_KhajiitLunarSubstrate
        text = text + " Your moon practice is " + GetKhajiitLunarTierLabel(Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()) + "."
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarSourceCount") > 0
            text = text + " A lunar source has been read and remembered."
        endIf
        if Manager.PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has begun to carry weight."
        endIf
    else
        text = text + " The moons have not yet taken the measure of your practice."
    endIf

    Int presiding = GetCurrentLunarPresidingFocus()
    if presiding > Manager.KHAJIIT_FOCUS_NONE
        if GetActiveLunarFavoredFocus() == presiding
            text = text + " " + GetKhajiitFocusLabel(presiding) + " is in strength, and your focused blessing resonates."
        else
            text = text + " " + GetKhajiitFocusLabel(presiding) + " is in strength."
        endIf
    endIf

    Int posture = GetKhajiitLunarPosture()
    if posture != Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
        text = text + "\n\n" + GetKhajiitLunarPostureReadout(posture)
    endIf

    return text
EndFunction

String Function GetKhajiitFocusStandingLine(Int focusValue)
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    if !deity
        return "not yet wired"
    endIf

    String line = Manager.GetTierStandingLabel(Manager.LedgerRuntime.GetTier(deity)) + ", piety " + PDV_DevotionRules.FormatTwoDecimals(Manager.LedgerRuntime.GetPiety(deity))
    if GetKhajiitFocusedEmphasis() == focusValue
        line = line + " (leading)"
    endIf
    if GetCurrentLunarPresidingFocus() == focusValue
        if GetActiveLunarFavoredFocus() == focusValue
            line = line + " (in strength, resonating)"
        else
            line = line + " (in strength)"
        endIf
    endIf

    return line
EndFunction

String Function GetKhajiitLunarTierLabel(Int tierValue)
    if tierValue >= 3
        return "strong"
    elseIf tierValue == 2
        return "steady"
    elseIf tierValue == 1
        return "beginning"
    endIf

    return "quiet"
EndFunction

String Function GetKhajiitLunarSummary()
    if !Manager.PDV_KhajiitLunarSubstrate
        return "missing"
    endIf

    return Manager.PDV_KhajiitLunarSubstrate.GetPilotSummary() + "; focus=" + GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()) + "; kh=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_KHENARTHI)) + "; az=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_AZURAH)) + "; bd=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_BAANDAR)) + "; rj=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_RAJHIN)) + "; ak=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_ALKOSH))
EndFunction

Int Function GetKhajiitMoonPhaseFromGameDay(Float gameDay)
    Int phaseTest = (gameDay + 0.5) as Int
    phaseTest = phaseTest % 24
    if phaseTest < 0
        phaseTest += 24
    endIf

    if phaseTest >= 22 || phaseTest == 0
        return 1    ; Full Moon
    elseIf phaseTest < 4
        return 2    ; Waning Gibbous
    elseIf phaseTest < 7
        return 3    ; Last Quarter
    elseIf phaseTest < 10
        return 4    ; Waning Crescent
    elseIf phaseTest < 13
        return 5    ; New Moon
    elseIf phaseTest < 16
        return 6    ; Waxing Crescent
    elseIf phaseTest < 19
        return 7    ; First Quarter
    endIf

    return 8        ; Waxing Gibbous
EndFunction
