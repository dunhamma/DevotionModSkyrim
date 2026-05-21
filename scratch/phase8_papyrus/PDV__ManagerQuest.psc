;/ 
    PDV__ManagerQuest.psc
    Devotion Mod - Phase 4 manager runtime
    -----------------------------------------------------------------------
    OVERVIEW
    Hidden runtime quest that owns the canonical piety/tier state,
    patron mirrors, dawn consolidation, stance-aware scratch writes, and
    rivalry dispatch for hostile worship paths.

    DESIGN NOTES
    - StorageUtil remains the source of truth for per-deity values.
    - AwardPiety writes PDV.PietyToday only. Persistent piety and tier
      still update at dawn through ProcessDawn().
    - Phase 4 uses race-keyed stance lookups from PDV_DeityBase.
    - Rivalry writes are never recursive: hostile-path penalties route
      through a private helper that suppresses further rivalry firing.
    - Patron boons are active-patron only. Non-patron deities can keep
      piety and tier state without granting live spells.
    -----------------------------------------------------------------------
/;

Scriptname PDV__ManagerQuest extends Quest

Import PO3_Events_Form

GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_PatronDeity Auto
GlobalVariable Property PDV_GLO_PatronState Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
GlobalVariable Property PDV_GLO_OriginRace Auto

FormList Property PDV_FLST_AllDeities Auto

PDV_Deity_Kyne Property PDV_Kyne Auto
PDV_Deity_Talos Property PDV_Talos Auto
PDV_ReputationTrack Property PDV_ConcordatStandingTrack Auto
PDV_StateTrack Property PDV_BosmerPathTrack Auto
PDV_Substrate_DunmerAncestor Property PDV_DunmerAncestorSubstrate Auto
PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto
PDV_DaedricPath_Hircine Property PDV_HircinePath Auto
PDV_CurseState Property PDV_CurseStateService Auto

Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly

Int Property FRAMEWORK_SCHEMA_VERSION = 3 AutoReadOnly
Int Property PATRON_STATE_UNSET = 0 AutoReadOnly
Int Property PATRON_STATE_BROAD = 1 AutoReadOnly
Int Property PATRON_STATE_ACTIVE = 2 AutoReadOnly

Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_DAILY_MAX_DELTA = 5.0 AutoReadOnly
Float Property DECAY_GRACE_DAYS = 3.0 AutoReadOnly
Float Property DECAY_PER_DAY = 0.5 AutoReadOnly
Float Property BROAD_WORSHIP_DECAY_MULTIPLIER = 0.2 AutoReadOnly
Float Property NEGLECT_ACTIVE_PIETY_MAX = 10.0 AutoReadOnly
Int Property NEGLECT_ACTIVE_CAP = 3 AutoReadOnly
Float Property COMMITMENT_OFFER_THRESHOLD = 50.0 AutoReadOnly
Float Property COMMITMENT_DECLINE_DELAY_DAYS = 1.0 AutoReadOnly
Float Property COMMITMENT_REFUSE_COOLDOWN_DAYS = 3.0 AutoReadOnly
Float Property COMMITMENT_CARRYOVER_MULTIPLIER = 0.7 AutoReadOnly

Int Property BOSMER_PATH_OLD_CONTRACT = 0 AutoReadOnly
Int Property BOSMER_PATH_LIVING_STORY = 1 AutoReadOnly
Int Property BOSMER_PATH_EXCHANGE = 2 AutoReadOnly
Int Property BOSMER_PATH_BANDIT_ROAD = 3 AutoReadOnly

PDV_DeityBase _activeDeity

Int Property DebugCommand = 0 Auto
Int Property DebugIndex = -1 Auto
Float Property DebugValue = 0.0 Auto
Int Property DebugSignalType = 0 Auto
Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly
Float Property SHOUT_DUPLICATE_WINDOW_DAYS = 0.00001 AutoReadOnly

String Property SHOUT_DUPLICATE_KEY = "PDV.ShoutAttack.LastTime" AutoReadOnly
Int _shoutRefreshTicks = 0

Event OnInit()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    RegisterManagerShoutSignals()
    RefreshPatronMirrors()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    EnsurePhase8RuntimeWiring()

    if DebugCommand != 0
        RunDebugCommand()
    endIf

    _shoutRefreshTicks += 1
    if _shoutRefreshTicks >= 10
        RegisterManagerShoutSignals()
        _shoutRefreshTicks = 0
    endIf

    RegisterForSingleUpdate(1.0)
EndEvent

Function EnsurePhase8RuntimeWiring()
    if !PDV_Talos || !PDV_ConcordatStandingTrack
        return
    endIf

    EnsureTalosRuntimeIdentity()

    if PDV_Talos.GainModifyingTrack != PDV_ConcordatStandingTrack
        PDV_Talos.GainModifyingTrack = PDV_ConcordatStandingTrack
    endIf

    if PDV_Talos.DecayModifyingTrack != PDV_ConcordatStandingTrack
        PDV_Talos.DecayModifyingTrack = PDV_ConcordatStandingTrack
    endIf
EndFunction

Function EnsureTalosRuntimeIdentity()
    if !PDV_Talos
        return
    endIf

    Bool repaired = False

    if PDV_Talos.DeityName != "Talos"
        PDV_Talos.DeityName = "Talos"
        repaired = True
    endIf

    if PDV_Talos.DeityDomain == ""
        PDV_Talos.DeityDomain = "Empire, War, Human Ascension"
        repaired = True
    endIf

    if PDV_Talos.DeityIndex != 1
        PDV_Talos.DeityIndex = 1
        repaired = True
    endIf

    if PDV_Talos.Stance_Nord != PDV_Talos.STANCE_NATIVE
        PDV_Talos.Stance_Nord = PDV_Talos.STANCE_NATIVE
        repaired = True
    endIf

    if PDV_Talos.Stance_Imperial != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Imperial = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Breton != PDV_Talos.STANCE_NATIVE
        PDV_Talos.Stance_Breton = PDV_Talos.STANCE_NATIVE
        repaired = True
    endIf

    if PDV_Talos.Stance_Altmer != PDV_Talos.STANCE_HOSTILE
        PDV_Talos.Stance_Altmer = PDV_Talos.STANCE_HOSTILE
        repaired = True
    endIf

    if PDV_Talos.Stance_Bosmer != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Bosmer = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Dunmer != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Dunmer = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Khajiit != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Khajiit = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Argonian != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Argonian = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Orc != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Orc = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.Stance_Redguard != PDV_Talos.STANCE_FOREIGN
        PDV_Talos.Stance_Redguard = PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if PDV_Talos.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_Talos.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
        repaired = True
    endIf

    if PDV_Talos.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        PDV_Talos.PDV_GLO_OriginRace = PDV_GLO_OriginRace
        repaired = True
    endIf

    if repaired
        Trace(1, "Talos runtime identity repaired for save compatibility.")
    endIf
EndFunction

Event OnPlayerShoutAttack(Shout akShout)
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        Trace(1, "Quest shout fallback skipped: player unavailable.")
        return
    endIf

    HandleShoutAttack(EVT_SHOUT_ATTACK, playerRef, akShout, "manager_form")
    Trace(2, "Quest shout fallback observed.")
EndEvent

Function AwardPiety(PDV_DeityBase deity, Float amount)
    AwardPietyInternal(deity, amount, True)
EndFunction

Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText)
    if !PDV_PrismaBridge.IsAvailable()
        return False
    endIf

    String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + JsonSafeString(symbolName) + "\",\"tone\":\"" + JsonSafeString(tone) + "\",\"title\":\"" + JsonSafeString(titleText) + "\",\"message\":\"" + JsonSafeString(messageText) + "\"}}"
    return PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

Bool Function SendPrismaDeityToast(PDV_DeityBase deity, String tone, String titleText, String messageText)
    return SendPrismaToast(GetPrismaSymbolForDeity(deity), tone, titleText, messageText)
EndFunction

Function AwardCuratedSignal(PDV_DeityBase deity, Int signalType, Form contextRef)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignal skipped: no deity supplied.")
        endIf
        return
    endIf

    Float delta = deity.ScoreCuratedSignal(signalType, contextRef)
    if delta == 0.0
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] AwardCuratedSignal: " + deity.DeityName + " ignored signal " + signalType)
        endIf
        return
    endIf

    AwardPiety(deity, delta)

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardCuratedSignal: " + deity.DeityName + " signal " + signalType + " delta " + delta)
    endIf
EndFunction

Function AwardCuratedSignalByIndex(Int deityIndex, Int signalType)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignalByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    AwardCuratedSignal(deity, signalType, None)
EndFunction

Float Function GetPiety(PDV_DeityBase deity)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
EndFunction

Float Function GetPietyToday(PDV_DeityBase deity)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
EndFunction

Int Function GetTier(PDV_DeityBase deity)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return TIER_NONE
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int
EndFunction

Int Function GetActiveDeityIndex()
    if _activeDeity
        return _activeDeity.DeityIndex
    endIf
    return -1
EndFunction

Int Function GetDeityCount()
    if !PDV_FLST_AllDeities
        return 0
    endIf
    return PDV_FLST_AllDeities.GetSize()
EndFunction

PDV_DeityBase Function GetDeityAtListIndex(Int listIndex)
    if listIndex < 0 || !PDV_FLST_AllDeities
        return None
    endIf

    if listIndex >= PDV_FLST_AllDeities.GetSize()
        return None
    endIf

    return PDV_FLST_AllDeities.GetAt(listIndex) as PDV_DeityBase
EndFunction

Float Function GetPietyByIndex(Int deityIndex)
    return GetPiety(GetDeityByIndex(deityIndex))
EndFunction

Float Function GetPietyTodayByIndex(Int deityIndex)
    return GetPietyToday(GetDeityByIndex(deityIndex))
EndFunction

Int Function GetTierByIndex(Int deityIndex)
    return GetTier(GetDeityByIndex(deityIndex))
EndFunction

Function SetDebugLevel(Int levelValue)
    if PDV_GLO_DebugLevel
        PDV_GLO_DebugLevel.SetValue(ClampInt(levelValue, 0, 3) as Float)
    endIf
EndFunction

Function SetActiveDeity(PDV_DeityBase newDeity)
    if newDeity == _activeDeity
        return
    endIf

    if _activeDeity
        _activeDeity.OnPatronEnd()
    endIf

    _activeDeity = newDeity

    if _activeDeity
        EnsureDeityState(_activeDeity)
        _activeDeity.OnPatronStart()
        SetPatronState(PATRON_STATE_ACTIVE)
    else
        SetPatronState(PATRON_STATE_UNSET)
    endIf

    UpdatePatronDeityGlobal()
    RefreshPatronMirrors()
EndFunction

Function SetBroadWorship()
    if _activeDeity
        _activeDeity.OnPatronEnd()
    endIf

    _activeDeity = None
    SetPatronState(PATRON_STATE_BROAD)
    UpdatePatronDeityGlobal()
    RefreshPatronMirrors()
EndFunction

Int Function GetPatronState()
    Int storedState = StorageUtil.GetIntValue(None, "PDV.PatronState")
    if storedState == PATRON_STATE_BROAD || storedState == PATRON_STATE_ACTIVE
        return storedState
    endIf

    if _activeDeity
        return PATRON_STATE_ACTIVE
    endIf

    return PATRON_STATE_UNSET
EndFunction

String Function GetPatronStateLabel()
    Int patronState = GetPatronState()
    if patronState == PATRON_STATE_ACTIVE
        return "Active patron"
    elseIf patronState == PATRON_STATE_BROAD
        return "Broad worship"
    endIf

    return "Unset"
EndFunction

Bool Function IsBroadWorshipActive()
    return GetPatronState() == PATRON_STATE_BROAD
EndFunction

Function HandlePlayerSleepStop(Actor playerRef, Bool wasInterrupted, String reason)
    if wasInterrupted
        Trace(3, "Player sleep stop ignored because sleep was interrupted.")
        return
    endIf

    if !playerRef
        Trace(1, "Player sleep stop skipped: player ref missing.")
        return
    endIf

    if GetPlayerOriginRaceIndex() == 6
        HandleKhajiitMoonObservance(GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()), reason)
    endIf
EndFunction

Function HandleGreenPactViolation(String reason)
    if !PDV_BosmerPathTrack
        Trace(1, "Green Pact violation skipped: Bosmer path missing.")
        return
    endIf

    if PDV_BosmerPathTrack.GetCurrentState() != BOSMER_PATH_OLD_CONTRACT
        Trace(2, "Green Pact violation ignored outside OldContract.")
        return
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Float windowStart = StorageUtil.GetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart")
    Int violationCount = StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount")
    if windowStart <= 0.0 || (nowTime - windowStart) > 2.0
        windowStart = nowTime
        violationCount = 0
    endIf

    violationCount += 1
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", windowStart)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", violationCount)

    if violationCount >= 5
        StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 1)
    endIf

    Trace(2, "Green Pact violation count " + violationCount + " (" + reason + ")")
EndFunction

Function HandleDunmerPortableShrinePrayer(String reason)
    if PDV_DunmerAncestorSubstrate
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerPortableShrinePrayer")
        PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)
        Trace(2, "Dunmer portable shrine prayer routed with multiplier " + multiplier)
    endIf
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    if PDV_DunmerAncestorSubstrate
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerHomeBonus")
        PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)
        Trace(2, "Dunmer player-home bonus routed with multiplier " + multiplier)
    endIf
EndFunction

Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)
    if !PDV_KhajiitLunarSubstrate
        return
    endIf

    if phaseIndex < 1 || phaseIndex > 8
        phaseIndex = GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMoonObservance")
    PDV_KhajiitLunarSubstrate.ObserveMoonPhaseScaled(phaseIndex, multiplier, reason)
    Trace(2, "Khajiit moon observance routed for phase " + phaseIndex + " with multiplier " + multiplier)
EndFunction

Function HandleKhajiitRoadHome(String reason)
    if PDV_KhajiitLunarSubstrate
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitRoadHome")
        PDV_KhajiitLunarSubstrate.RecordRoadHomeCadenceScaled(multiplier, reason)
        Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier)
    endIf
EndFunction

Function HandleHircineHuntRite(String reason)
    if PDV_HircinePath
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.HircineHuntRite")
        PDV_HircinePath.RecordHuntRiteScaled(multiplier, reason)
        Trace(2, "Hircine hunt rite routed with multiplier " + multiplier)
    endIf
EndFunction

Function HandleTalosShrineDefiance(String reason)
    if PDV_Talos
        AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None)
    else
        Trace(1, "Talos shrine defiance skipped: PDV_Talos missing.")
    endIf

    if GetPlayerOriginRaceIndex() == 1
        ApplyConcordatPressure(-15, "talos_shrine_" + reason)
        Trace(2, "Talos shrine defiance also applied Concordat pressure.")
    else
        Trace(2, "Talos shrine defiance awarded without Concordat pressure for non-Imperial origin.")
    endIf
EndFunction

Function HandleShoutAttack(Int eventType, Actor playerRef, Shout shoutUsed, String reason)
    if !playerRef
        Trace(1, "Shout attack skipped: player ref missing.")
        return
    endIf

    if ShouldSuppressDuplicateShoutAttack()
        Trace(3, "Shout attack duplicate suppressed (" + reason + ")")
        return
    endIf

    if !PDV_FLST_AllDeities
        Trace(1, "Shout attack skipped: deity roster missing.")
        return
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    Int scoredCount = 0

    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float delta = deity.ScoreAction(eventType, playerRef as Form, shoutUsed as Form)
            if delta != 0.0
                AwardPiety(deity, delta)
                scoredCount += 1
            endIf
        endIf

        i += 1
    endWhile

    Trace(2, "Shout attack routed: event " + eventType + ", scored deities " + scoredCount + " (" + reason + ")")
EndFunction

Function RegisterManagerShoutSignals()
    PO3_Events_Form.RegisterForShoutAttack(Self)
    Trace(3, "Quest shout fallback refreshed.")
EndFunction

Bool Function ShouldSuppressDuplicateShoutAttack()
    Float nowTime = Utility.GetCurrentGameTime()
    Float lastTime = StorageUtil.GetFloatValue(None, SHOUT_DUPLICATE_KEY)
    if lastTime > 0.0 && (nowTime - lastTime) < SHOUT_DUPLICATE_WINDOW_DAYS
        return True
    endIf

    StorageUtil.SetFloatValue(None, SHOUT_DUPLICATE_KEY, nowTime)
    return False
EndFunction

Int Function RecomputeTier(PDV_DeityBase deity)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return TIER_NONE
    endIf

    EnsureDeityState(deity)

    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Int oldTier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int
    Int newTier = ComputeTierFromPiety(deity, piety)

    if newTier != oldTier
        StorageUtil.SetFloatValue(deityForm, "PDV.Tier", newTier as Float)
        StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", Utility.GetCurrentGameTime())

        if deity == _activeDeity
            deity.OnTierChange(oldTier, newTier)
            RefreshPatronMirrors()
        endIf
    elseIf deity == _activeDeity
        RefreshPatronMirrors()
    endIf

    return newTier
EndFunction

Function RefreshPatronMirrors()
    if !_activeDeity
        PDV_GLO_ActivePiety.SetValue(0.0)
        PDV_GLO_ActiveTier.SetValue(TIER_NONE as Float)
        PDV_GLO_ActiveDeityIndex.SetValue(-1.0)
        return
    endIf

    EnsureDeityState(_activeDeity)
    Form deityForm = _activeDeity as Form

    PDV_GLO_ActivePiety.SetValue(StorageUtil.GetFloatValue(deityForm, "PDV.Piety"))
    PDV_GLO_ActiveTier.SetValue(StorageUtil.GetFloatValue(deityForm, "PDV.Tier"))
    PDV_GLO_ActiveDeityIndex.SetValue(_activeDeity.DeityIndex as Float)
EndFunction

Function InitializePreflightState()
    if StorageUtil.GetIntValue(None, "PDV.FrameworkSchemaVersion") != FRAMEWORK_SCHEMA_VERSION
        StorageUtil.SetIntValue(None, "PDV.FrameworkSchemaVersion", FRAMEWORK_SCHEMA_VERSION)
        Trace(2, "Framework schema version recorded as " + FRAMEWORK_SCHEMA_VERSION)
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && !_activeDeity
        SetPatronState(PATRON_STATE_UNSET)
    else
        SyncPatronStateGlobal()
    endIf
EndFunction

Function SetPatronState(Int patronState)
    Int normalizedState = patronState
    if normalizedState != PATRON_STATE_BROAD && normalizedState != PATRON_STATE_ACTIVE
        normalizedState = PATRON_STATE_UNSET
    endIf

    StorageUtil.SetIntValue(None, "PDV.PatronState", normalizedState)
    SyncPatronStateGlobal()
EndFunction

Function SyncPatronStateGlobal()
    if PDV_GLO_PatronState
        PDV_GLO_PatronState.SetValue(GetPatronState() as Float)
    endIf
EndFunction

Function ProcessDawn()
    if !PDV_FLST_AllDeities
        Debug.Trace("[PDV] ProcessDawn: PDV_FLST_AllDeities not assigned.")
        return
    endIf

    RunDawnConsolidateScratch()
    RunDawnRefreshTrackStates()
    RunDawnApplyDecayNoop()
    RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnProcessCommitmentOffersNoop()
    RunDawnNotifyNoop()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] ProcessDawn complete.")
    endIf
EndFunction

Function RunDawnConsolidateScratch()
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()

    while i < count
        Form deityForm = PDV_FLST_AllDeities.GetAt(i)
        PDV_DeityBase deity = deityForm as PDV_DeityBase

        if deity
            EnsureDeityState(deity)

            Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
            Float clampedToday = ClampValue(pietyToday, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)
            Float oldPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
            Float newPiety = ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)

            StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
            StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
            if clampedToday != 0.0
                StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
            endIf

            Int newTier = RecomputeTier(deity)

            if GetDebugLevel() >= 2
                Debug.Trace("[PDV] ProcessDawn: " + deity.DeityName + " piety " + oldPiety + " -> " + newPiety + ", today " + pietyToday + " clamped to " + clampedToday + ", tier now " + newTier)
            endIf
        endIf

        i += 1
    endWhile
EndFunction

Function RunDawnApplyDecayNoop()
    RunDawnApplyDecay()
EndFunction

Function RunDawnRefreshTrackStates()
    if PDV_ConcordatStandingTrack
        PDV_ConcordatStandingTrack.RefreshState()
    endIf
EndFunction

Function RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnApplySpellAndNeglectLayers()
EndFunction

Function RunDawnProcessCommitmentOffersNoop()
    RunDawnProcessCommitmentOffers()
EndFunction

Function RunDawnNotifyNoop()
    RunDawnNotify()
EndFunction

Function RunDawnApplyDecay()
    if !PDV_FLST_AllDeities
        return
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            ApplyDecayToDeity(deity, nowTime)
        endIf
        i += 1
    endWhile
EndFunction

Function RunDawnApplySpellAndNeglectLayers()
    if IsBroadWorshipActive()
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        EvaluateKyneContextualFavorFamily()
        return
    endIf

    PDV_DeityBase lowestA = None
    PDV_DeityBase lowestB = None
    PDV_DeityBase lowestC = None
    Float pietyA = 9999.0
    Float pietyB = 9999.0
    Float pietyC = 9999.0
    Int i = 0
    Int count = GetDeityCount()

    while i < count
        PDV_DeityBase deity = GetDeityAtListIndex(i)
        if deity
            Float currentPiety = GetPiety(deity)
            if currentPiety <= NEGLECT_ACTIVE_PIETY_MAX
                if currentPiety < pietyA
                    lowestC = lowestB
                    pietyC = pietyB
                    lowestB = lowestA
                    pietyB = pietyA
                    lowestA = deity
                    pietyA = currentPiety
                elseIf currentPiety < pietyB
                    lowestC = lowestB
                    pietyC = pietyB
                    lowestB = deity
                    pietyB = currentPiety
                elseIf currentPiety < pietyC
                    lowestC = deity
                    pietyC = currentPiety
                endIf
            endIf
        endIf
        i += 1
    endWhile

    ClearAllNeglectFlags()
    Int activeCount = 0
    if lowestA
        SetNeglectFlag(lowestA, True)
        activeCount += 1
    endIf
    if lowestB && activeCount < NEGLECT_ACTIVE_CAP
        SetNeglectFlag(lowestB, True)
        activeCount += 1
    endIf
    if lowestC && activeCount < NEGLECT_ACTIVE_CAP
        SetNeglectFlag(lowestC, True)
        activeCount += 1
    endIf

    StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", activeCount)
    EvaluateKyneContextualFavorFamily()
EndFunction

Function RunDawnProcessCommitmentOffers()
    EvaluateKyneCommitmentOffer()
EndFunction

Function RunDawnNotify()
    SendPrismaToast("dawn", "neutral", "Dawn settles", "Your prayers settle into practice.")
    Trace(2, "Pattern summary: " + DebugGetPatternProvingSummary())
EndFunction

Function ApplyDecayToDeity(PDV_DeityBase deity, Float nowTime)
    if !deity
        return
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && deity == _activeDeity
        return
    endIf

    EnsureDeityState(deity)
    Form deityForm = deity as Form
    Float lastEventTime = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    if lastEventTime <= 0.0
        return
    endIf

    if (nowTime - lastEventTime) < DECAY_GRACE_DAYS
        return
    endIf

    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        return
    endIf

    Float multiplier = 1.0
    if IsBroadWorshipActive()
        multiplier = BROAD_WORSHIP_DECAY_MULTIPLIER
    endIf

    Float newPiety = currentPiety - (DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity))
    Float floorValue = GetDecayFloorForDeity(deity, currentPiety)
    if newPiety < floorValue
        newPiety = floorValue
    endIf

    if newPiety != currentPiety
        StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
        RecomputeTier(deity)
        Trace(2, "Decay applied to " + deity.DeityName + ": " + currentPiety + " -> " + newPiety)
    endIf
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function RunDebugCommand()
    Int commandId = DebugCommand
    Int deityIndex = DebugIndex
    Float amount = DebugValue

    if commandId == 1
        DebugClearActiveDeity()
    elseIf commandId == 2
        DebugResetDeityByIndex(deityIndex)
    elseIf commandId == 3
        ForceSetActiveDeityByIndex(deityIndex)
    elseIf commandId == 4
        ForceSetPietyToday(amount)
    elseIf commandId == 5
        ProcessDawn()
    elseIf commandId == 6
        ForceSetPiety(amount)
    elseIf commandId == 7
        DebugAwardCuratedSignalByIndex(deityIndex, DebugSignalType)
    elseIf GetDebugLevel() >= 1
        Debug.Trace("[PDV] RunDebugCommand ignored unknown command " + commandId)
    endIf

    DebugCommand = 0
EndFunction

Function ForceSetPiety(Float amount)
    if !_activeDeity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetPiety skipped: no active patron.")
        endIf
        return
    endIf

    Form deityForm = _activeDeity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", ClampValue(amount, 0.0, PIETY_MAX))
    RecomputeTier(_activeDeity)
EndFunction

Function ForceSetActiveDeityByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity && deityIndex != -1
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetActiveDeityByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    SetActiveDeity(deity)
EndFunction

Function ForceSetPietyToday(Float amount)
    if !_activeDeity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetPietyToday skipped: no active patron.")
        endIf
        return
    endIf

    StorageUtil.SetFloatValue(_activeDeity as Form, "PDV.PietyToday", amount)
EndFunction

Function DebugForceSetPietyByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", ClampValue(amount, 0.0, PIETY_MAX))
    RecomputeTier(deity)
EndFunction

Function DebugForceSetPietyTodayByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyTodayByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    StorageUtil.SetFloatValue(deity as Form, "PDV.PietyToday", amount)
EndFunction

Function DebugAwardCuratedSignalByIndex(Int deityIndex, Int signalType)
    AwardCuratedSignalByIndex(deityIndex, signalType)
EndFunction

String Function DebugGetPietyMapString()
    if !PDV_FLST_AllDeities
        return "No deity roster is assigned."
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    String output = ""

    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            String entry = deity.DeityName + " p=" + GetPiety(deity) + " t=" + GetPietyToday(deity) + " tier=" + GetTier(deity)
            if output == ""
                output = entry
            else
                output = output + "; " + entry
            endIf
        endIf
        i += 1
    endWhile

    if output == ""
        return "No deity entries were found."
    endIf

    return output
EndFunction

Function DebugClearActiveDeity()
    SetActiveDeity(None)
EndFunction

Function DebugSetBroadWorship()
    SetBroadWorship()
EndFunction

String Function DebugGetOriginDiagnostic()
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") == 1
        return "Custom race fallback: Imperial"
    endIf

    return "No custom race fallback"
EndFunction

Function DebugResetDeityByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugResetDeityByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    Int oldTier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int

    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.Tier", TIER_NONE as Float)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", 0.0)

    if deity == _activeDeity
        deity.OnTierChange(oldTier, TIER_NONE)
        RefreshPatronMirrors()
    endIf
EndFunction

Function AwardPietyInternal(PDV_DeityBase deity, Float amount, Bool allowRivalry)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardPiety skipped: no deity supplied.")
        endIf
        return
    endIf

    EnsureDeityState(deity)

    Int stance = deity.GetStanceForPlayer()
    Float appliedAmount = RunGainPipeline(deity, amount, stance)

    StorageUtil.AdjustFloatValue(deityForm, "PDV.PietyToday", appliedAmount)
    if appliedAmount != 0.0
        StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
    endIf

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardPiety: " + deity.DeityName + " raw " + amount + ", applied " + appliedAmount + ", stance " + stance + ", today=" + StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday"))
    endIf

    if appliedAmount > 0.0 && deity == _activeDeity
        SendPrismaDeityToast(deity, "good", deity.DeityName + " remembers", "Your act did not pass unseen.")
    endIf

    if allowRivalry && appliedAmount > 0.0 && stance == deity.STANCE_HOSTILE
        ApplyRivalryPenalties(deity, appliedAmount)
    endIf
EndFunction

Float Function RunGainPipeline(PDV_DeityBase deity, Float amount, Int stance)
    Float appliedAmount = amount
    if amount > 0.0
        appliedAmount = appliedAmount * deity.GetEffectiveGainMultiplier()
        appliedAmount = appliedAmount * GetCurseGainMultiplierNoop(deity)
        appliedAmount = appliedAmount * GetDaedricStigmaGainMultiplierNoop(deity)
    endIf

    return appliedAmount
EndFunction

Float Function GetReputationGainMultiplierNoop(PDV_DeityBase deity)
    return GetReputationGainMultiplier(deity)
EndFunction

Float Function GetCurseGainMultiplierNoop(PDV_DeityBase deity)
    return GetCurseGainMultiplier(deity)
EndFunction

Float Function GetDaedricStigmaGainMultiplierNoop(PDV_DeityBase deity)
    return GetDaedricStigmaGainMultiplier(deity)
EndFunction

Float Function GetReputationGainMultiplier(PDV_DeityBase deity)
    if !deity
        return 1.0
    endIf

    return deity.GetTrackGainMultiplier()
EndFunction

Float Function GetCurseGainMultiplier(PDV_DeityBase deity)
    if !deity || !PDV_CurseStateService
        return 1.0
    endIf

    if deity == PDV_HircinePath
        if PDV_CurseStateService.IsWerewolf()
            return 1.5
        elseIf PDV_CurseStateService.IsVampire()
            return 0.5
        endIf
    endIf

    return 1.0
EndFunction

Float Function GetDaedricStigmaGainMultiplier(PDV_DeityBase deity)
    if PDV_HircinePath && deity == PDV_HircinePath
        Float stigma = PDV_HircinePath.GetStigma()
        if stigma >= 6.0
            return 1.25
        elseIf stigma >= 3.0
            return 1.1
        endIf
    endIf

    return 1.0
EndFunction

Float Function GetReputationDecayMultiplier(PDV_DeityBase deity)
    if deity
        return deity.GetTrackDecayMultiplier()
    endIf

    return 1.0
EndFunction

Float Function GetDecayFloorForDeity(PDV_DeityBase deity, Float currentPiety)
    if !deity
        return 0.0
    endIf

    Int tierValue = ComputeTierFromPiety(deity, currentPiety)
    if tierValue >= TIER_CHAMPION
        return deity.ThresholdDevoted
    elseIf tierValue >= TIER_DEVOTED
        return deity.ThresholdSeeker
    endIf

    return 0.0
EndFunction

Function ClearAllNeglectFlags()
    Int i = 0
    Int count = GetDeityCount()
    while i < count
        PDV_DeityBase deity = GetDeityAtListIndex(i)
        if deity
            SetNeglectFlag(deity, False)
        endIf
        i += 1
    endWhile
EndFunction

Function SetNeglectFlag(PDV_DeityBase deity, Bool isActive)
    if !deity
        return
    endIf

    StorageUtil.SetIntValue(deity as Form, "PDV.Neglect.Active", BoolToInt(isActive))
EndFunction

Function EvaluateKyneContextualFavorFamily()
    Int conditionMask = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeConditions = CountSetBits(conditionMask)
    Int familyActive = 0

    if _activeDeity == PDV_Kyne && GetTier(PDV_Kyne) >= TIER_DEVOTED && activeConditions > 0
        familyActive = 1
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ActiveCount", familyActive)
EndFunction

Function ApplyConcordatPressure(Int adjustment, String reason)
    if !PDV_ConcordatStandingTrack
        Trace(1, "ApplyConcordatPressure skipped: track missing.")
        return
    endIf

    PDV_ConcordatStandingTrack.Adjust(adjustment, reason)
    Trace(2, "Concordat pressure " + adjustment + " -> " + PDV_ConcordatStandingTrack.GetValue())
EndFunction

Function DebugUnlockConcordatWalkback()
    if PDV_ConcordatStandingTrack
        PDV_ConcordatStandingTrack.UnlockExtremeResetGate("mcm_unlock")
    endIf
EndFunction

Function DebugSetBosmerPathState(Int stateValue)
    if PDV_BosmerPathTrack
        PDV_BosmerPathTrack.SetState(stateValue, "mcm_pattern")
    endIf
EndFunction

Function DebugTriggerGreenPactViolation()
    HandleGreenPactViolation("mcm")
EndFunction

Function DebugRecordDunmerAncestorPrayer()
    HandleDunmerPortableShrinePrayer("mcm")
EndFunction

Function DebugRecordDunmerAncestorHomeBonus()
    HandleDunmerPlayerHomeBonus("mcm")
EndFunction

Function DebugRecordKhajiitMoonObservance()
    Int nextPhase = GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    if PDV_KhajiitLunarSubstrate && PDV_KhajiitLunarSubstrate.GetLastObservedPhase() == nextPhase
        nextPhase += 1
        if nextPhase > 8
            nextPhase = 1
        endIf
    endIf
    HandleKhajiitMoonObservance(nextPhase, "mcm")
EndFunction

Function DebugRecordKhajiitRoadHome()
    HandleKhajiitRoadHome("mcm")
EndFunction

Function DebugRecordTalosShrineDefiance()
    HandleTalosShrineDefiance("mcm")
EndFunction

Function DebugCycleKyneFavorMask()
    Int currentMask = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    currentMask += 1
    if currentMask > 7
        currentMask = 0
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ConditionMask", currentMask)
    EvaluateKyneContextualFavorFamily()
EndFunction

Function DebugRecordHircineHuntRite()
    HandleHircineHuntRite("mcm")
EndFunction

Function DebugRenounceHircinePath()
    if PDV_HircinePath
        PDV_HircinePath.RenouncePath("mcm")
    endIf
EndFunction

Function DebugEvaluateCommitmentOffer()
    EvaluateKyneCommitmentOffer()
EndFunction

Function EvaluateKyneCommitmentOffer()
    if !PDV_Kyne
        return
    endIf

    if ShouldBypassFormalCommitmentOffers()
        return
    endIf

    if GetPendingCommitmentDeityIndex() == PDV_Kyne.DeityIndex
        return
    endIf

    if Utility.GetCurrentGameTime() < StorageUtil.GetFloatValue(None, "PDV.Commitment.RefusedUntil")
        return
    endIf

    if Utility.GetCurrentGameTime() < StorageUtil.GetFloatValue(None, "PDV.Commitment.DeclineUntil")
        return
    endIf

    if GetPiety(PDV_Kyne) < COMMITMENT_OFFER_THRESHOLD
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", PDV_Kyne.DeityIndex)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", Utility.GetCurrentGameTime())
    Trace(1, "Commitment offer pending for Kyne.")
EndFunction

Function DebugAcceptPendingCommitment()
    if GetPendingCommitmentDeityIndex() != PDV_Kyne.DeityIndex
        return
    endIf

    Float carrySource = 0.0
    if _activeDeity && _activeDeity != PDV_Kyne
        carrySource = GetPiety(_activeDeity)
    endIf

    Float carryAmount = carrySource * COMMITMENT_CARRYOVER_MULTIPLIER
    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", carryAmount)
    if carryAmount > 0.0
        DebugForceSetPietyByIndex(PDV_Kyne.DeityIndex, ClampValue(GetPiety(PDV_Kyne) + carryAmount, 0.0, PIETY_MAX))
    endIf

    SetActiveDeity(PDV_Kyne)
    ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
    Trace(1, "Commitment accepted for Kyne.")
EndFunction

Function DebugDeclinePendingCommitment()
    if GetPendingCommitmentDeityIndex() == -1
        return
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.DeclineUntil", Utility.GetCurrentGameTime() + COMMITMENT_DECLINE_DELAY_DAYS)
    ClearPendingCommitment()
    Trace(1, "Commitment declined/postponed.")
EndFunction

Function DebugRefusePendingCommitment()
    if GetPendingCommitmentDeityIndex() == -1
        return
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.RefusedUntil", Utility.GetCurrentGameTime() + COMMITMENT_REFUSE_COOLDOWN_DAYS)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 1)
    ClearPendingCommitment()
    Trace(1, "Commitment refused.")
EndFunction

Function ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", -1)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", 0.0)
EndFunction

Int Function GetPendingCommitmentDeityIndex()
    return StorageUtil.GetIntValue(None, "PDV.Commitment.PendingDeityIndex")
EndFunction

Bool Function ShouldBypassFormalCommitmentOffers()
    return GetPlayerOriginRaceIndex() == 6
EndFunction

Int Function GetPlayerOriginRaceIndex()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf

    return -1
EndFunction

String Function DebugGetPatternProvingSummary()
    String summary = "Concordat=" + GetConcordatSummary()
    summary = summary + "; Bosmer=" + GetBosmerSummary()
    summary = summary + "; DunmerAncestor=" + GetDunmerAncestorSummary()
    summary = summary + "; KhajiitLunar=" + GetKhajiitLunarSummary()
    summary = summary + "; KyneFavor=" + GetKyneFavorSummary()
    summary = summary + "; Commitment=" + GetCommitmentSummary()
    summary = summary + "; Neglect=" + StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount")
    summary = summary + "; Hircine=" + GetHircineSummary()
    return summary
EndFunction

String Function GetConcordatSummary()
    if !PDV_ConcordatStandingTrack
        return "missing"
    endIf

    String gateState = "locked"
    if PDV_ConcordatStandingTrack.HasExtremeResetGate()
        gateState = "unlocked"
    endIf

    return "raw=" + PDV_ConcordatStandingTrack.GetValue() + ";state=" + PDV_ConcordatStandingTrack.GetStateLabel() + ";pending=" + PDV_ConcordatStandingTrack.GetPendingStateLabel() + ";gate=" + gateState + ";track=" + FormatTwoDecimals(GetTalosTrackGainMultiplier()) + ";eff=" + FormatTwoDecimals(GetTalosEffectiveGainMultiplier())
EndFunction

Int Function DebugGetConcordatRawValue()
    if !PDV_ConcordatStandingTrack
        return 0
    endIf

    return PDV_ConcordatStandingTrack.GetValue()
EndFunction

String Function DebugGetConcordatStateLabel()
    if !PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    return PDV_ConcordatStandingTrack.GetStateLabel()
EndFunction

String Function DebugGetConcordatPendingStateLabel()
    if !PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    return PDV_ConcordatStandingTrack.GetPendingStateLabel()
EndFunction

String Function DebugGetConcordatGateLabel()
    if !PDV_ConcordatStandingTrack
        return "Missing"
    endIf

    if PDV_ConcordatStandingTrack.HasExtremeResetGate()
        return "Unlocked"
    endIf

    return "Locked"
EndFunction

Float Function GetTalosTrackGainMultiplier()
    if PDV_Talos
        return PDV_Talos.GetTrackGainMultiplier()
    endIf

    return 1.0
EndFunction

Float Function GetTalosEffectiveGainMultiplier()
    if PDV_Talos
        return PDV_Talos.GetEffectiveGainMultiplier()
    endIf

    return 1.0
EndFunction

String Function FormatTwoDecimals(Float value)
    Int scaledValue = (value * 100.0) as Int
    Int remainder = AbsInt(scaledValue % 100)
    if remainder < 10
        return "" + (scaledValue / 100) + ".0" + remainder
    endIf

    return "" + (scaledValue / 100) + "." + remainder
EndFunction

Int Function AbsInt(Int value)
    if value < 0
        return 0 - value
    endIf

    return value
EndFunction

String Function GetBosmerSummary()
    if !PDV_BosmerPathTrack
        return "missing"
    endIf

    return PDV_BosmerPathTrack.GetStateLabel() + ";gp=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount") + ";penalty=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive")
EndFunction

String Function GetDunmerAncestorSummary()
    if !PDV_DunmerAncestorSubstrate
        return "missing"
    endIf

    return PDV_DunmerAncestorSubstrate.GetPilotSummary()
EndFunction

String Function GetKhajiitLunarSummary()
    if !PDV_KhajiitLunarSubstrate
        return "missing"
    endIf

    return PDV_KhajiitLunarSubstrate.GetPilotSummary()
EndFunction

String Function GetKyneFavorSummary()
    Int maskValue = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ActiveCount")
    return "mask=" + maskValue + ";conds=" + CountSetBits(maskValue) + ";active=" + activeCount
EndFunction

String Function GetCommitmentSummary()
    return "pending=" + GetPendingCommitmentDeityIndex() + ";carry=" + StorageUtil.GetFloatValue(None, "PDV.Commitment.LastCarryover") + ";rupture=" + StorageUtil.GetIntValue(None, "PDV.Commitment.Rupture")
EndFunction

String Function GetHircineSummary()
    if !PDV_HircinePath
        return "missing"
    endIf

    return PDV_HircinePath.GetPilotSummary()
EndFunction

Int Function GetKhajiitMoonPhaseFromGameDay(Float gameDay)
    Int dayIndex = gameDay as Int
    while dayIndex >= 28
        dayIndex -= 28
    endWhile
    while dayIndex < 0
        dayIndex += 28
    endWhile

    Int phaseIndex = ((dayIndex * 8) / 28) + 1
    if phaseIndex < 1
        return 1
    elseIf phaseIndex > 8
        return 8
    endIf

    return phaseIndex
EndFunction

Float Function ConsumeDailyRepeatMultiplier(String keyPrefix)
    Int currentDay = Utility.GetCurrentGameTime() as Int
    String dayKey = keyPrefix + ".Day"
    String countKey = keyPrefix + ".Count"
    Int repeatCount = 0

    if StorageUtil.GetIntValue(None, dayKey) == currentDay
        repeatCount = StorageUtil.GetIntValue(None, countKey)
    else
        StorageUtil.SetIntValue(None, dayKey, currentDay)
        StorageUtil.SetIntValue(None, countKey, 0)
    endIf

    Float multiplier = 1.0
    Int i = 0
    while i < repeatCount
        multiplier = multiplier * 0.7
        i += 1
    endWhile

    StorageUtil.SetIntValue(None, countKey, repeatCount + 1)
    return multiplier
EndFunction

Int Function CountSetBits(Int maskValue)
    Int count = 0
    Int remaining = maskValue
    if remaining >= 4
        count += 1
        remaining -= 4
    endIf
    if remaining >= 2
        count += 1
        remaining -= 2
    endIf
    if remaining >= 1
        count += 1
    endIf
    return count
EndFunction

Int Function BoolToInt(Bool value)
    if value
        return 1
    endIf
    return 0
EndFunction

Function ApplyRivalryPenalties(PDV_DeityBase sourceDeity, Float sourceAmount)
    Quest[] rivalForms = sourceDeity.RivalDeities
    Float[] rivalMultipliers = sourceDeity.RivalMultipliers

    if !rivalForms || !rivalMultipliers
        return
    endIf

    Int i = 0
    Int rivalCount = rivalForms.Length
    while i < rivalCount
        if i < rivalMultipliers.Length
            PDV_DeityBase rivalDeity = rivalForms[i] as PDV_DeityBase
            Float rivalAmount = sourceAmount * rivalMultipliers[i] * -1.0

            if rivalDeity && rivalAmount != 0.0
                AwardPietyInternal(rivalDeity, rivalAmount, False)

                if GetDebugLevel() >= 2
                    Debug.Trace("[PDV] Rivalry: " + sourceDeity.DeityName + " applied " + rivalAmount + " to " + rivalDeity.DeityName)
                endIf
            endIf
        endIf

        i += 1
    endWhile
EndFunction

Form Function GetDeityFormOrNone(PDV_DeityBase deity)
    if deity
        return deity as Form
    endIf
    return None
EndFunction

Function EnsureDeityState(PDV_DeityBase deity)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return
    endIf

    StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    StorageUtil.GetFloatValue(deityForm, "PDV.Tier")
    StorageUtil.GetFloatValue(deityForm, "PDV.LastTierChange")
EndFunction

Int Function ComputeTierFromPiety(PDV_DeityBase deity, Float piety)
    if !deity
        return TIER_NONE
    endIf

    if piety >= deity.ThresholdChampion
        return TIER_CHAMPION
    elseIf piety >= deity.ThresholdDevoted
        return TIER_DEVOTED
    elseIf piety >= deity.ThresholdSeeker
        return TIER_SEEKER
    endIf

    return TIER_NONE
EndFunction

PDV_DeityBase Function GetDeityByIndex(Int deityIndex)
    if deityIndex < 0 || !PDV_FLST_AllDeities
        return None
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && deity.DeityIndex == deityIndex
            return deity
        endIf
        i += 1
    endWhile

    return None
EndFunction

Function UpdatePatronDeityGlobal()
    if !PDV_GLO_PatronDeity
        return
    endIf

    if !_activeDeity
        PDV_GLO_PatronDeity.SetValue(0.0)
        return
    endIf

    PDV_GLO_PatronDeity.SetValue((_activeDeity as Form).GetFormID() as Float)
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] Manager: " + traceText)
    endIf
EndFunction

String Function GetPrismaSymbolForDeity(PDV_DeityBase deity)
    if !deity
        return "journal"
    endIf

    if deity == PDV_Kyne
        return "kyne"
    endIf

    if deity == PDV_Talos
        return "talos"
    endIf

    if deity.DeityName == "Auri-El"
        return "auri-el"
    endIf

    if deity.DeityName == "Akatosh"
        return "akatosh"
    endIf

    if deity.DeityName == "Arkay"
        return "arkay"
    endIf

    if deity.DeityName == "Dibella"
        return "dibella"
    endIf

    if deity.DeityName == "Julianos"
        return "julianos"
    endIf

    if deity.DeityName == "Mara"
        return "mara"
    endIf

    if deity.DeityName == "Stendarr"
        return "stendarr"
    endIf

    if deity.DeityName == "Zenithar"
        return "zenithar"
    endIf

    return "journal"
EndFunction

String Function JsonSafeString(String rawText)
    if rawText == ""
        return ""
    endIf

    String safeText = ""
    Int i = 0
    Int count = StringUtil.GetLength(rawText)
    while i < count
        String currentChar = StringUtil.GetNthChar(rawText, i)
        if currentChar == "\"" || currentChar == "\\"
            safeText = safeText + "'"
        else
            safeText = safeText + currentChar
        endIf
        i += 1
    endWhile

    return safeText
EndFunction

Float Function ClampValue(Float value, Float minValue, Float maxValue)
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction

Int Function ClampInt(Int value, Int minValue, Int maxValue)
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction
