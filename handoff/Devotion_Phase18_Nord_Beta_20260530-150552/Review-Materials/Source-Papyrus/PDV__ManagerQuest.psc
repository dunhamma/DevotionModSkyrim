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
GlobalVariable Property PDV_GLO_KhajiitFocusedEmphasis Auto

FormList Property PDV_FLST_AllDeities Auto

PDV_Deity_Kyne Property PDV_Kyne Auto
PDV_Deity_Talos Property PDV_Talos Auto
PDV_Deity_Yffre Property PDV_Yffre Auto
PDV_Deity_Zen Property PDV_Zen Auto
PDV_Deity_BaanDar Property PDV_BaanDar Auto
PDV_ReputationTrack Property PDV_ConcordatStandingTrack Auto
PDV_StateTrack Property PDV_BosmerPathTrack Auto
PDV_StateTrack Property PDV_NordPantheonBaselineTrack Auto
PDV_Substrate_DunmerAncestor Property PDV_DunmerAncestorSubstrate Auto
PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto
PDV_DaedricPath_Hircine Property PDV_HircinePath Auto
PDV_CurseState Property PDV_CurseStateService Auto
Spell Property PDV_SPEL_SurveyDevotion Auto
Spell Property PDV_SPEL_Neglect_Kyne Auto
Spell Property PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery Auto
Spell Property PDV_SPEL_Favor_Kyne_StormRoadGrace Auto
Spell Property PDV_SPEL_Favor_Kyne_GuidedHunt Auto
Spell Property PDV_SPEL_Favor_Kyne_WindMarkedPassage Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine Auto
Message Property PDV_MSG_BosmerSetupChoice Auto
Message Property PDV_MSG_BosmerSuggestLivingStory Auto
Message Property PDV_MSG_BosmerSuggestExchange Auto
Message Property PDV_MSG_BosmerSuggestBanditRoad Auto
Message Property PDV_MSG_BosmerSuggestOldContract Auto
Message Property PDV_MSG_BosmerReckoning Auto
Message Property PDV_Msg_Nord_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireCured Auto

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
Int Property ORIGIN_NORD = 0 AutoReadOnly
Int Property ORIGIN_BRETON = 2 AutoReadOnly
Int Property ORIGIN_ALTMER = 3 AutoReadOnly
Int Property ORIGIN_BOSMER = 4 AutoReadOnly
Int Property ORIGIN_DUNMER = 5 AutoReadOnly
Int Property ORIGIN_KHAJIIT = 6 AutoReadOnly
Int Property NORD_BASELINE_OLD_WAYS = 0 AutoReadOnly
Int Property NORD_BASELINE_NINE_DIVINES = 1 AutoReadOnly
Int Property FAVOR_LANE_NONE = 0 AutoReadOnly
Int Property FAVOR_LANE_KYNE = 1 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_OLD_WAYS = 2 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_NINE_DIVINES = 3 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_OPEN_SKY_REST = 1 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_STORM_ROAD = 2 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_GUIDED_HUNT = 3 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE = 4 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_SKY_ROAD = 11 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL = 12 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD = 13 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET = 14 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE = 15 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_ROAD_GRACE = 21 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY = 22 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_PROPER_DEATH = 23 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HONEST_WORK = 24 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_TALOS_PRESSURE = 25 AutoReadOnly
Int Property KHAJIIT_FOCUS_NONE = 0 AutoReadOnly
Int Property KHAJIIT_FOCUS_KHENARTHI = 1 AutoReadOnly
Int Property KHAJIIT_FOCUS_AZURAH = 2 AutoReadOnly
Int Property KHAJIIT_FOCUS_BAANDAR = 3 AutoReadOnly
Int Property KHAJIIT_FOCUS_RAJHIN = 4 AutoReadOnly
Int Property KHAJIIT_FOCUS_ALKOSH = 5 AutoReadOnly
Float Property KHAJIIT_FOCUS_THRESHOLD = 50.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_LEAD_REQUIRED = 15.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_SIGNAL_DELTA = 25.0 AutoReadOnly
Float Property FAVOR_DURATION_MOMENTARY_DAYS = 0.001 AutoReadOnly
Float Property FAVOR_DURATION_AFTER_ACT_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_DURATION_ENVIRONMENTAL_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_FAMILY_MOMENTARY_COOLDOWN_DAYS = 0.02 AutoReadOnly
Float Property FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS = 0.5 AutoReadOnly

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
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    RegisterManagerShoutSignals()
    RefreshPatronMirrors()
    UpdateContextualFavorRuntime()
    EnsureSurveyDevotionPower()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    EnsurePhase8RuntimeWiring()
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    EnsureBosmerSetupChoice()
    UpdateContextualFavorRuntime()
    EnsureSurveyDevotionPower()

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

Function EnsureBosmerRuntimeWiring()
    if PDV_BosmerPathTrack
        if PDV_BosmerPathTrack.TrackName != "BosmerPath"
            PDV_BosmerPathTrack.TrackName = "BosmerPath"
        endIf

        if PDV_BosmerPathTrack.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
            PDV_BosmerPathTrack.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
        endIf

        if PDV_BosmerPathTrack.StateLabels.Length != 4
            String[] labels = new String[4]
            labels[0] = "OldContract"
            labels[1] = "LivingStory"
            labels[2] = "Exchange"
            labels[3] = "BanditRoad"
            PDV_BosmerPathTrack.StateLabels = labels
        endIf
    endIf

    EnsureBosmerYffreRuntimeIdentity()
    EnsureBosmerZenRuntimeIdentity()
    EnsureBosmerBaanDarRuntimeIdentity()
EndFunction

Function EnsureNordRuntimeWiring()
    if !PDV_NordPantheonBaselineTrack
        return
    endIf

    if PDV_NordPantheonBaselineTrack.TrackName != "NordPantheonBaseline"
        PDV_NordPantheonBaselineTrack.TrackName = "NordPantheonBaseline"
    endIf

    if PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
    endIf

    if PDV_NordPantheonBaselineTrack.StateLabels.Length != 2
        String[] labels = new String[2]
        labels[0] = "OldWays"
        labels[1] = "NineDivines"
        PDV_NordPantheonBaselineTrack.StateLabels = labels
    endIf
EndFunction

Function EnsureBosmerYffreRuntimeIdentity()
    if !PDV_Yffre
        return
    endIf

    if PDV_Yffre.DeityName != "Y'ffre"
        PDV_Yffre.DeityName = "Y'ffre"
    endIf

    if PDV_Yffre.DeityDomain == ""
        PDV_Yffre.DeityDomain = "Story, Green Pact, Forest Law"
    endIf

    if PDV_Yffre.DeityIndex != 3
        PDV_Yffre.DeityIndex = 3
    endIf

    if PDV_Yffre.Stance_Bosmer != PDV_Yffre.STANCE_NATIVE
        PDV_Yffre.Stance_Bosmer = PDV_Yffre.STANCE_NATIVE
    endIf

    if PDV_Yffre.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_Yffre.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
    endIf

    if PDV_Yffre.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        PDV_Yffre.PDV_GLO_OriginRace = PDV_GLO_OriginRace
    endIf

    if PDV_Yffre.EligibleStateTrack != PDV_BosmerPathTrack
        PDV_Yffre.EligibleStateTrack = PDV_BosmerPathTrack
    endIf

    if PDV_Yffre.EligibleStateValues.Length != 2
        Int[] eligibleStates = new Int[2]
        eligibleStates[0] = BOSMER_PATH_OLD_CONTRACT
        eligibleStates[1] = BOSMER_PATH_LIVING_STORY
        PDV_Yffre.EligibleStateValues = eligibleStates
    endIf
EndFunction

Function EnsureBosmerZenRuntimeIdentity()
    if !PDV_Zen
        return
    endIf

    if PDV_Zen.DeityName != "Z'en"
        PDV_Zen.DeityName = "Z'en"
    endIf

    if PDV_Zen.DeityDomain == ""
        PDV_Zen.DeityDomain = "Exchange, Reciprocity, Restitution"
    endIf

    if PDV_Zen.DeityIndex != 4
        PDV_Zen.DeityIndex = 4
    endIf

    if PDV_Zen.Stance_Bosmer != PDV_Zen.STANCE_NATIVE
        PDV_Zen.Stance_Bosmer = PDV_Zen.STANCE_NATIVE
    endIf

    if PDV_Zen.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_Zen.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
    endIf

    if PDV_Zen.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        PDV_Zen.PDV_GLO_OriginRace = PDV_GLO_OriginRace
    endIf

    if PDV_Zen.EligibleStateTrack != PDV_BosmerPathTrack
        PDV_Zen.EligibleStateTrack = PDV_BosmerPathTrack
    endIf

    if PDV_Zen.EligibleStateValues.Length != 1 || PDV_Zen.EligibleStateValues[0] != BOSMER_PATH_EXCHANGE
        Int[] eligibleStates = new Int[1]
        eligibleStates[0] = BOSMER_PATH_EXCHANGE
        PDV_Zen.EligibleStateValues = eligibleStates
    endIf
EndFunction

Function EnsureBosmerBaanDarRuntimeIdentity()
    if !PDV_BaanDar
        return
    endIf

    if PDV_BaanDar.DeityName != "Baan Dar"
        PDV_BaanDar.DeityName = "Baan Dar"
    endIf

    if PDV_BaanDar.DeityDomain == ""
        PDV_BaanDar.DeityDomain = "Road, Theft, Survival Cunning"
    endIf

    if PDV_BaanDar.DeityIndex != 5
        PDV_BaanDar.DeityIndex = 5
    endIf

    if PDV_BaanDar.Stance_Bosmer != PDV_BaanDar.STANCE_NATIVE
        PDV_BaanDar.Stance_Bosmer = PDV_BaanDar.STANCE_NATIVE
    endIf

    if PDV_BaanDar.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_BaanDar.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
    endIf

    if PDV_BaanDar.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        PDV_BaanDar.PDV_GLO_OriginRace = PDV_GLO_OriginRace
    endIf

    if PDV_BaanDar.EligibleStateTrack != PDV_BosmerPathTrack
        PDV_BaanDar.EligibleStateTrack = PDV_BosmerPathTrack
    endIf

    if PDV_BaanDar.EligibleStateValues.Length != 1 || PDV_BaanDar.EligibleStateValues[0] != BOSMER_PATH_BANDIT_ROAD
        Int[] eligibleStates = new Int[1]
        eligibleStates[0] = BOSMER_PATH_BANDIT_ROAD
        PDV_BaanDar.EligibleStateValues = eligibleStates
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
    ClearActiveFavor("patron_state_change")

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
    ClearActiveFavor("patron_state_change")
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

    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        HandleKhajiitMoonObservance(GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()), reason)
    endIf
EndFunction

Function HandleGreenPactViolation(String reason)
    if !IsBosmerOrigin()
        return
    endIf

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

    AdjustBosmerGreenPactCompliance(-15, reason)
    if PDV_Yffre
        AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_PACT_VIOLATION, None)
    endIf

    Trace(2, "Green Pact violation count " + violationCount + " (" + reason + ")")
EndFunction

Function HandleBosmerLivingStorySignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_LIVING_STORY, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_LIVING_STORY && PDV_Yffre
        AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_LIVING_STORY, None)
    endIf
EndFunction

Function HandleBosmerExchangeSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_EXCHANGE, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_EXCHANGE && PDV_Zen
        AwardCuratedSignal(PDV_Zen, PDV_Zen.SIGNAL_EXCHANGE, None)
    endIf
EndFunction

Function HandleBosmerBanditRoadSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_BANDIT_ROAD, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_BANDIT_ROAD && PDV_BaanDar
        AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_BANDIT_ROAD, None)
    endIf
EndFunction

Function HandleBosmerPactPositiveSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_OLD_CONTRACT, reason)
    if IsBosmerPactBound()
        AdjustBosmerGreenPactCompliance(5, reason)
        if PDV_Yffre
            AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_PACT_POSITIVE, None)
        endIf
        return
    endIf

    Int currentPath = PDV_BosmerPathTrack.GetCurrentState()
    if currentPath == BOSMER_PATH_LIVING_STORY && PDV_Yffre
        AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_SHARED_PACT_MEMORY, None)
    elseIf currentPath == BOSMER_PATH_EXCHANGE && PDV_Zen
        AwardCuratedSignal(PDV_Zen, PDV_Zen.SIGNAL_SHARED_PACT_MEMORY, None)
    elseIf currentPath == BOSMER_PATH_BANDIT_ROAD && PDV_BaanDar
        AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_SHARED_PACT_MEMORY, None)
    endIf
EndFunction

Function HandleStateTransitionConfirmationRite(String reason)
    if IsBosmerOrigin()
        ConfirmBosmerPendingTransition(reason)
    endIf
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
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_AZURAH, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    Trace(2, "Khajiit moon observance routed for phase " + phaseIndex + " with multiplier " + multiplier)
EndFunction

Function HandleKhajiitRoadHome(String reason)
    if PDV_KhajiitLunarSubstrate
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitRoadHome")
        PDV_KhajiitLunarSubstrate.RecordRoadHomeCadenceScaled(multiplier, reason)
        AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_KHENARTHI, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
        Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier)
    endIf
EndFunction

Function AdjustKhajiitFocusedEmphasis(Int focusValue, Float amount, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_KHAJIIT
        return
    endIf

    if focusValue < KHAJIIT_FOCUS_KHENARTHI || focusValue > KHAJIIT_FOCUS_ALKOSH
        return
    endIf

    String focusKey = GetKhajiitFocusWeightKey(focusValue)
    StorageUtil.AdjustFloatValue(None, focusKey, amount)
    EvaluateKhajiitFocusedEmphasis()
    Trace(2, "Khajiit focus " + GetKhajiitFocusLabel(focusValue) + " adjusted by " + amount + " (" + reason + ")")
EndFunction

Function EvaluateKhajiitFocusedEmphasis()
    Float khenarthi = GetKhajiitFocusWeight(KHAJIIT_FOCUS_KHENARTHI)
    Float azurah = GetKhajiitFocusWeight(KHAJIIT_FOCUS_AZURAH)
    Float baanDar = GetKhajiitFocusWeight(KHAJIIT_FOCUS_BAANDAR)
    Float rajhin = GetKhajiitFocusWeight(KHAJIIT_FOCUS_RAJHIN)
    Float alkosh = GetKhajiitFocusWeight(KHAJIIT_FOCUS_ALKOSH)

    Int bestFocus = KHAJIIT_FOCUS_NONE
    Float bestWeight = 0.0
    Float nextWeight = 0.0

    bestFocus = PickKhajiitFocusCandidate(KHAJIIT_FOCUS_KHENARTHI, khenarthi, bestFocus, bestWeight)
    bestWeight = GetKhajiitFocusWeight(bestFocus)
    nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    bestFocus = PickKhajiitFocusCandidate(KHAJIIT_FOCUS_AZURAH, azurah, bestFocus, bestWeight)
    bestWeight = GetKhajiitFocusWeight(bestFocus)
    nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    bestFocus = PickKhajiitFocusCandidate(KHAJIIT_FOCUS_BAANDAR, baanDar, bestFocus, bestWeight)
    bestWeight = GetKhajiitFocusWeight(bestFocus)
    nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    bestFocus = PickKhajiitFocusCandidate(KHAJIIT_FOCUS_RAJHIN, rajhin, bestFocus, bestWeight)
    bestWeight = GetKhajiitFocusWeight(bestFocus)
    nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    bestFocus = PickKhajiitFocusCandidate(KHAJIIT_FOCUS_ALKOSH, alkosh, bestFocus, bestWeight)
    bestWeight = GetKhajiitFocusWeight(bestFocus)
    nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    if bestWeight < KHAJIIT_FOCUS_THRESHOLD || (bestWeight - nextWeight) < KHAJIIT_FOCUS_LEAD_REQUIRED
        SetKhajiitFocusedEmphasis(KHAJIIT_FOCUS_NONE, "no_clear_lead")
        return
    endIf

    SetKhajiitFocusedEmphasis(bestFocus, "lead")
EndFunction

Int Function PickKhajiitFocusCandidate(Int candidateFocus, Float candidateWeight, Int currentBest, Float currentBestWeight)
    if candidateWeight > currentBestWeight
        return candidateFocus
    endIf

    return currentBest
EndFunction

Float Function GetKhajiitSecondFocusWeight(Int bestFocus, Float khenarthi, Float azurah, Float baanDar, Float rajhin, Float alkosh)
    Float secondWeight = 0.0
    if bestFocus != KHAJIIT_FOCUS_KHENARTHI && khenarthi > secondWeight
        secondWeight = khenarthi
    endIf
    if bestFocus != KHAJIIT_FOCUS_AZURAH && azurah > secondWeight
        secondWeight = azurah
    endIf
    if bestFocus != KHAJIIT_FOCUS_BAANDAR && baanDar > secondWeight
        secondWeight = baanDar
    endIf
    if bestFocus != KHAJIIT_FOCUS_RAJHIN && rajhin > secondWeight
        secondWeight = rajhin
    endIf
    if bestFocus != KHAJIIT_FOCUS_ALKOSH && alkosh > secondWeight
        secondWeight = alkosh
    endIf
    return secondWeight
EndFunction

Function SetKhajiitFocusedEmphasis(Int focusValue, String reason)
    Int oldFocus = GetKhajiitFocusedEmphasis()
    StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusedEmphasis", focusValue)
    if PDV_GLO_KhajiitFocusedEmphasis
        PDV_GLO_KhajiitFocusedEmphasis.SetValue(focusValue as Float)
    endIf

    if oldFocus != focusValue
        Trace(1, "Khajiit focused emphasis " + GetKhajiitFocusLabel(oldFocus) + " -> " + GetKhajiitFocusLabel(focusValue) + " (" + reason + ")")
    endIf
EndFunction

Int Function GetKhajiitFocusedEmphasis()
    return StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusedEmphasis")
EndFunction

Float Function GetKhajiitFocusWeight(Int focusValue)
    return StorageUtil.GetFloatValue(None, GetKhajiitFocusWeightKey(focusValue))
EndFunction

String Function GetKhajiitFocusWeightKey(Int focusValue)
    return "PDV.Khajiit.Focus." + GetKhajiitFocusLabel(focusValue)
EndFunction

String Function GetKhajiitFocusLabel(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi"
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return "Azurah"
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return "BaanDar"
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return "Rajhin"
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return "Alkosh"
    endIf

    return "None"
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
    RefreshPassiveDecayFloorForDeity(deity, newTier)

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

    if GetPatronState() == PATRON_STATE_ACTIVE
        RestoreActiveDeityFromStoredPatron()
        if !_activeDeity
            SetPatronState(PATRON_STATE_UNSET)
        else
            SyncPatronStateGlobal()
            RefreshPatronMirrors()
        endIf
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
    HandleCurseStateRefresh("dawn")

    if PDV_ConcordatStandingTrack
        PDV_ConcordatStandingTrack.RefreshState()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        EvaluateKhajiitFocusedEmphasis()
    endIf

    if IsBosmerOrigin() && PDV_BosmerPathTrack
        EnsureBosmerCurrentPathFallback()
        EvaluateBosmerForcedReckoning()
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
        SyncKyneNeglectSpell(False)
        UpdateContextualFavorRuntime()
        return
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || !_activeDeity
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        SyncKyneNeglectSpell(False)
        UpdateContextualFavorRuntime()
        return
    endIf

    ClearAllNeglectFlags()
    Int activeCount = ApplyGenericNeglectFlags()
    StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", activeCount)
    SyncKyneNeglectSpell(IsNeglectFlagActive(PDV_Kyne))
    UpdateContextualFavorRuntime()
EndFunction

Function RunDawnProcessCommitmentOffers()
    if IsBosmerOrigin()
        EvaluateBosmerPathSuggestion()
        return
    endIf

    EvaluateFormalCommitmentOffer()
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
    if lastEventTime == 0.0
        return
    endIf

    if (nowTime - lastEventTime) < DECAY_GRACE_DAYS
        return
    endIf

    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        return
    endIf

    Int currentDay = nowTime as Int
    if StorageUtil.GetIntValue(deityForm, "PDV.LastDecayAppliedDay") == currentDay
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

    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", currentDay)

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

Function DebugPrimeDecayGraceByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayGraceByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", (nowTime as Int) - 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    RecomputeTier(deity)
    Trace(1, "Decay grace primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugPrimeDecayEligibleByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayEligibleByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - DECAY_GRACE_DAYS - 1.0)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", (nowTime as Int) - 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    RecomputeTier(deity)
    Trace(1, "Decay eligible primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugRunDecayPass()
    RunDawnApplyDecay()
    Trace(1, "Decay pass debug run.")
EndFunction

Function DebugRunDecayProofDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugRunDecayProofDaysByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    endIf
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - DECAY_GRACE_DAYS - 1.0)
    RecomputeTier(deity)

    Int i = 0
    while i < 400
        currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
        Float floorValue = GetDecayFloorForDeity(deity, currentPiety)
        if currentPiety <= floorValue
            i = 400
        else
            StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", ((nowTime + i) as Int) - 1)
            ApplyDecayToDeity(deity, nowTime + i)
        endIf
        i += 1
    endWhile
    Trace(1, "Decay proof days run for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
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
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)

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
    if appliedAmount > 0.0
        RecordCommitmentSignalDay(deity)
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
    Float storedFloor = StorageUtil.GetFloatValue(deity as Form, "PDV.PassiveDecayFloor")
    Float currentFloor = GetDecayFloorForTier(deity, tierValue)
    if storedFloor > currentFloor
        return storedFloor
    endIf

    return currentFloor
EndFunction

Float Function GetDecayFloorForTier(PDV_DeityBase deity, Int tierValue)
    if !deity
        return 0.0
    endIf

    if tierValue >= TIER_CHAMPION
        return deity.ThresholdDevoted
    elseIf tierValue >= TIER_DEVOTED
        return deity.ThresholdSeeker
    endIf

    return 0.0
EndFunction

Function RefreshPassiveDecayFloorForDeity(PDV_DeityBase deity, Int tierValue)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        return
    endIf

    Float tierFloor = GetDecayFloorForTier(deity, tierValue)
    Float storedFloor = StorageUtil.GetFloatValue(deityForm, "PDV.PassiveDecayFloor")
    if tierFloor > storedFloor
        StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", tierFloor)
    endIf
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

Bool Function IsNeglectFlagActive(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Neglect.Active") == 1
EndFunction

Bool Function IsKyneNeglectActive()
    return IsNeglectFlagActive(PDV_Kyne)
EndFunction

Function SyncKyneNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Kyne
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Kyne)
            playerRef.AddSpell(PDV_SPEL_Neglect_Kyne, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Kyne)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Kyne)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
    endIf
EndFunction

Int Function ApplyGenericNeglectFlags()
    PDV_DeityBase firstDeity = None
    PDV_DeityBase secondDeity = None
    PDV_DeityBase thirdDeity = None
    Float firstPiety = PIETY_MAX + 1.0
    Float secondPiety = PIETY_MAX + 1.0
    Float thirdPiety = PIETY_MAX + 1.0

    Int i = 0
    Int count = GetDeityCount()
    while i < count
        PDV_DeityBase deity = GetDeityAtListIndex(i)
        if IsEligibleForNeglectSelection(deity)
            Float piety = GetPiety(deity)
            if piety <= NEGLECT_ACTIVE_PIETY_MAX
                if !firstDeity || piety < firstPiety
                    thirdDeity = secondDeity
                    thirdPiety = secondPiety
                    secondDeity = firstDeity
                    secondPiety = firstPiety
                    firstDeity = deity
                    firstPiety = piety
                elseIf deity != firstDeity && (!secondDeity || piety < secondPiety)
                    thirdDeity = secondDeity
                    thirdPiety = secondPiety
                    secondDeity = deity
                    secondPiety = piety
                elseIf deity != firstDeity && deity != secondDeity && (!thirdDeity || piety < thirdPiety)
                    thirdDeity = deity
                    thirdPiety = piety
                endIf
            endIf
        endIf
        i += 1
    endWhile

    Int activeCount = 0
    if firstDeity
        SetNeglectFlag(firstDeity, True)
        activeCount += 1
    endIf
    if secondDeity
        SetNeglectFlag(secondDeity, True)
        activeCount += 1
    endIf
    if thirdDeity
        SetNeglectFlag(thirdDeity, True)
        activeCount += 1
    endIf

    return activeCount
EndFunction

Bool Function IsEligibleForNeglectSelection(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPiety(deity) > 0.0
        return True
    endIf

    return deity == _activeDeity
EndFunction

Function EvaluateKyneContextualFavorFamily()
    UpdateContextualFavorRuntime()
EndFunction

Function UpdateContextualFavorRuntime()
    if IsActiveFavorExpired()
        ClearActiveFavor("expired")
    elseIf IsFavorActive()
        if !IsActiveFavorStillEligible()
            ClearActiveFavor("no_longer_eligible")
        else
            EnsureActiveFavorApplied()
        endIf
    endIf

    SyncKyneFavorDebugState()
EndFunction

Function SyncKyneFavorDebugState()
    Int activeCount = 0
    if GetActiveFavorLane() == FAVOR_LANE_KYNE
        activeCount = 1
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ActiveCount", activeCount)
EndFunction

Bool Function TryActivateContextualFavor(Int laneValue, Int familyValue, String reason)
    UpdateContextualFavorRuntime()
    if IsFavorActive()
        Trace(2, "Contextual favor suppressed: another favor is active.")
        return False
    endIf

    if !IsEligibleForFavorLane(laneValue)
        Trace(2, "Contextual favor blocked: lane " + GetContextualFavorLaneLabel(laneValue) + " is not currently eligible.")
        return False
    endIf

    if !IsValidFavorFamilyForLane(laneValue, familyValue)
        Trace(1, "Contextual favor blocked: family " + familyValue + " is not valid for lane " + laneValue)
        return False
    endIf

    if IsFavorFamilyOnCooldown(laneValue, familyValue)
        Trace(2, "Contextual favor blocked: family cooldown still active for " + GetContextualFavorFamilyLabel(laneValue, familyValue))
        return False
    endIf

    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()
    if !favorSpell || !playerRef
        Trace(1, "Contextual favor blocked: missing player or spell for " + GetContextualFavorFamilyLabel(laneValue, familyValue))
        return False
    endIf

    playerRef.AddSpell(favorSpell, False)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveLane", laneValue)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveFamily", familyValue)
    StorageUtil.SetStringValue(None, "PDV.Favor.ActiveSpell", GetFavorSpellEditorId(laneValue, familyValue))
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveStartedAt", Utility.GetCurrentGameTime())
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveExpiresAt", Utility.GetCurrentGameTime() + GetFavorDurationDays(laneValue, familyValue))
    StorageUtil.SetFloatValue(None, GetFavorLastTriggerKey(laneValue, familyValue), Utility.GetCurrentGameTime())
    Trace(1, "Contextual favor applied: " + GetContextualFavorFamilyLabel(laneValue, familyValue) + " (" + reason + ")")
    SendContextualFavorToast(laneValue, familyValue)
    SyncKyneFavorDebugState()
    return True
EndFunction

Function SendContextualFavorToast(Int laneValue, Int familyValue)
    String surfacing = GetFavorSurfacingLabel(laneValue, familyValue)
    if surfacing == "Quiet"
        return
    endIf

    String titleText = GetContextualFavorLaneLabel(laneValue)
    String messageText = GetContextualFavorFamilyLabel(laneValue, familyValue)
    if laneValue == FAVOR_LANE_KYNE && PDV_Kyne
        SendPrismaDeityToast(PDV_Kyne, "good", titleText, messageText)
        return
    endIf

    SendPrismaToast("journal", "good", titleText, messageText)
EndFunction

Function EnsureActiveFavorApplied()
    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    if laneValue == FAVOR_LANE_NONE || familyValue <= 0
        return
    endIf

    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()
    if !favorSpell || !playerRef
        return
    endIf

    if !playerRef.HasSpell(favorSpell)
        playerRef.AddSpell(favorSpell, False)
    endIf
EndFunction

Function ClearActiveFavor(String reason)
    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    Spell favorSpell = GetFavorSpell(laneValue, familyValue)
    Actor playerRef = Game.GetPlayer()

    if playerRef && favorSpell && playerRef.HasSpell(favorSpell)
        playerRef.RemoveSpell(favorSpell)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveLane", FAVOR_LANE_NONE)
    StorageUtil.SetIntValue(None, "PDV.Favor.ActiveFamily", 0)
    StorageUtil.SetStringValue(None, "PDV.Favor.ActiveSpell", "")
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveStartedAt", 0.0)
    StorageUtil.SetFloatValue(None, "PDV.Favor.ActiveExpiresAt", 0.0)
    Trace(2, "Contextual favor cleared (" + reason + ")")
    SyncKyneFavorDebugState()
EndFunction

Bool Function IsFavorActive()
    return GetActiveFavorLane() != FAVOR_LANE_NONE && GetActiveFavorFamily() > 0
EndFunction

Bool Function IsActiveFavorExpired()
    if !IsFavorActive()
        return False
    endIf

    Float expiresAt = StorageUtil.GetFloatValue(None, "PDV.Favor.ActiveExpiresAt")
    return expiresAt > 0.0 && Utility.GetCurrentGameTime() >= expiresAt
EndFunction

Bool Function IsActiveFavorStillEligible()
    if !IsFavorActive()
        return False
    endIf

    return ResolveEligibleFavorLane() == GetActiveFavorLane()
EndFunction

Bool Function IsEligibleForFavorLane(Int laneValue)
    return ResolveEligibleFavorLane() == laneValue
EndFunction

Int Function ResolveEligibleFavorLane()
    if IsNordVampireSuppressed()
        return FAVOR_LANE_NONE
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == PDV_Kyne && GetTier(PDV_Kyne) >= TIER_CHAMPION
        return FAVOR_LANE_KYNE
    endIf

    if GetPatronState() != PATRON_STATE_BROAD
        return FAVOR_LANE_NONE
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return FAVOR_LANE_NONE
    endIf

    Int baselineState = GetNordPantheonBaselineState()
    if baselineState == NORD_BASELINE_OLD_WAYS
        return FAVOR_LANE_NORD_BROAD_OLD_WAYS
    elseIf baselineState == NORD_BASELINE_NINE_DIVINES
        return FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    return FAVOR_LANE_NONE
EndFunction

Int Function GetNordPantheonBaselineState()
    if PDV_NordPantheonBaselineTrack
        return PDV_NordPantheonBaselineTrack.GetCurrentState()
    endIf

    return StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState")
EndFunction

Bool Function IsFavorFamilyOnCooldown(Int laneValue, Int familyValue)
    Float lastTriggerAt = StorageUtil.GetFloatValue(None, GetFavorLastTriggerKey(laneValue, familyValue))
    if lastTriggerAt <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastTriggerAt) < GetFavorCooldownDays(laneValue, familyValue)
EndFunction

String Function GetFavorLastTriggerKey(Int laneValue, Int familyValue)
    return "PDV.Favor.LastTrigger." + laneValue + "." + familyValue
EndFunction

Int Function GetActiveFavorLane()
    return StorageUtil.GetIntValue(None, "PDV.Favor.ActiveLane")
EndFunction

Int Function GetActiveFavorFamily()
    return StorageUtil.GetIntValue(None, "PDV.Favor.ActiveFamily")
EndFunction

Float Function GetFavorDurationDays(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
        return FAVOR_DURATION_MOMENTARY_DAYS
    endIf

    if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST || familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD || familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD || familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
        return FAVOR_DURATION_ENVIRONMENTAL_DAYS
    endIf

    return FAVOR_DURATION_AFTER_ACT_DAYS
EndFunction

Float Function GetFavorCooldownDays(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
        return FAVOR_FAMILY_MOMENTARY_COOLDOWN_DAYS
    endIf

    return FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS
EndFunction

Bool Function IsValidFavorFamilyForLane(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        return familyValue >= FAVOR_FAMILY_KYNE_OPEN_SKY_REST && familyValue <= FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return familyValue >= FAVOR_FAMILY_OLD_WAYS_SKY_ROAD && familyValue <= FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        return familyValue >= FAVOR_FAMILY_NINE_ROAD_GRACE && familyValue <= FAVOR_FAMILY_NINE_TALOS_PRESSURE
    endIf

    return False
EndFunction

Spell Function GetFavorSpell(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return PDV_SPEL_Favor_Kyne_StormRoadGrace
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return PDV_SPEL_Favor_Kyne_GuidedHunt
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return PDV_SPEL_Favor_Kyne_WindMarkedPassage
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine
        endIf
    endIf

    return None
EndFunction

String Function GetFavorSpellEditorId(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return "PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery"
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return "PDV_SPEL_Favor_Kyne_StormRoadGrace"
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return "PDV_SPEL_Favor_Kyne_GuidedHunt"
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return "PDV_SPEL_Favor_Kyne_WindMarkedPassage"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return "PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return "PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return "PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return "PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return "PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return "PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace"
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return "PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty"
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return "PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy"
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return "PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft"
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return "PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine"
        endIf
    endIf

    return ""
EndFunction

String Function GetContextualFavorLaneLabel(Int laneValue)
    if laneValue == FAVOR_LANE_KYNE
        return "Kyne"
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return "Nord Broad Old Ways"
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        return "Nord Broad Nine Divines"
    endIf

    return "None"
EndFunction

String Function GetContextualFavorFamilyLabel(Int laneValue, Int familyValue)
    if laneValue == FAVOR_LANE_KYNE
        if familyValue == FAVOR_FAMILY_KYNE_OPEN_SKY_REST
            return "Open-sky rest recovery"
        elseIf familyValue == FAVOR_FAMILY_KYNE_STORM_ROAD
            return "Storm-road grace"
        elseIf familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT
            return "Guided hunt"
        elseIf familyValue == FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return "Wind-marked passage"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        if familyValue == FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
            return "Sky-road endurance"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
            return "Honorable ordeal"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
            return "Hearth and hold defense"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
            return "Death-right and ancestor quiet"
        elseIf familyValue == FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return "Hidden Talos defiance"
        endIf
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        if familyValue == FAVOR_FAMILY_NINE_ROAD_GRACE
            return "Kynareth's road grace"
        elseIf familyValue == FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
            return "Household and mercy duty"
        elseIf familyValue == FAVOR_FAMILY_NINE_PROPER_DEATH
            return "Proper death and anti-necromancy"
        elseIf familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
            return "Honest work and learned craft"
        elseIf familyValue == FAVOR_FAMILY_NINE_TALOS_PRESSURE
            return "Talos pressure inside the Nine"
        endIf
    endIf

    return "Unknown"
EndFunction

String Function GetFavorSurfacingLabel(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL || familyValue == FAVOR_FAMILY_NINE_HONEST_WORK
        return "Quiet"
    endIf

    return "Noted"
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
    if !PDV_BosmerPathTrack
        return
    endIf

    InitializeBosmerStorage()
    PDV_BosmerPathTrack.SetState(stateValue, "mcm_pattern")
    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)

    if stateValue == BOSMER_PATH_OLD_CONTRACT
        SetBosmerPactBound(True, "mcm_pattern")
        SetBosmerGreenPactCompliance(80, "mcm_pattern")
    else
        SetBosmerPactBound(False, "mcm_pattern")
        SetBosmerGreenPactCompliance(0, "mcm_pattern")
    endIf

    ApplyBosmerPathPatron(stateValue, "mcm_pattern")
EndFunction

Function DebugTriggerGreenPactViolation()
    HandleGreenPactViolation("mcm")
EndFunction

Function DebugRecordBosmerLivingStorySignal()
    HandleBosmerLivingStorySignal("mcm")
EndFunction

Function DebugRecordBosmerExchangeSignal()
    HandleBosmerExchangeSignal("mcm")
EndFunction

Function DebugRecordBosmerBanditRoadSignal()
    HandleBosmerBanditRoadSignal("mcm")
EndFunction

Function DebugRecordBosmerPactPositiveSignal()
    HandleBosmerPactPositiveSignal("mcm")
EndFunction

Function DebugConfirmStateTransitionRite()
    HandleStateTransitionConfirmationRite("mcm")
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

Function DebugSetNordPantheonBaseline(Int stateValue)
    Int normalizedState = ClampInt(stateValue, NORD_BASELINE_OLD_WAYS, NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalizedState)
    if PDV_NordPantheonBaselineTrack && PDV_NordPantheonBaselineTrack.GetCurrentState() != normalizedState
        PDV_NordPantheonBaselineTrack.SetState(normalizedState, "mcm_pattern")
    endIf
EndFunction

Int Function GetSelectedContextualFavorLane()
    Int laneValue = StorageUtil.GetIntValue(None, "PDV.Favor.DebugLane")
    if laneValue < FAVOR_LANE_KYNE || laneValue > FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        laneValue = FAVOR_LANE_KYNE
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugLane", laneValue)
    endIf

    return laneValue
EndFunction

Function SetSelectedContextualFavorLane(Int laneValue)
    Int normalizedLane = ClampInt(laneValue, FAVOR_LANE_KYNE, FAVOR_LANE_NORD_BROAD_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.Favor.DebugLane", normalizedLane)
    if !IsValidFavorFamilyForLane(normalizedLane, GetSelectedContextualFavorFamily())
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", GetFirstFavorFamilyForLane(normalizedLane))
    endIf
EndFunction

Int Function GetSelectedContextualFavorFamily()
    Int familyValue = StorageUtil.GetIntValue(None, "PDV.Favor.DebugFamily")
    if !IsValidFavorFamilyForLane(GetSelectedContextualFavorLane(), familyValue)
        familyValue = GetFirstFavorFamilyForLane(GetSelectedContextualFavorLane())
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", familyValue)
    endIf

    return familyValue
EndFunction

Int Function GetFirstFavorFamilyForLane(Int laneValue)
    if laneValue == FAVOR_LANE_KYNE
        return FAVOR_FAMILY_KYNE_OPEN_SKY_REST
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        return FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    endIf

    return FAVOR_FAMILY_NINE_ROAD_GRACE
EndFunction

Int Function GetNextFavorFamilyForLane(Int laneValue, Int currentFamily)
    if laneValue == FAVOR_LANE_KYNE
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE
            return FAVOR_FAMILY_KYNE_OPEN_SKY_REST
        endIf
        return currentFamily
    elseIf laneValue == FAVOR_LANE_NORD_BROAD_OLD_WAYS
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
            return FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
        endIf
        return currentFamily
    endIf

    currentFamily += 1
    if currentFamily > FAVOR_FAMILY_NINE_TALOS_PRESSURE
        return FAVOR_FAMILY_NINE_ROAD_GRACE
    endIf

    return currentFamily
EndFunction

Function DebugCycleContextualFavorLane()
    Int laneValue = GetSelectedContextualFavorLane() + 1
    if laneValue > FAVOR_LANE_NORD_BROAD_NINE_DIVINES
        laneValue = FAVOR_LANE_KYNE
    endIf

    SetSelectedContextualFavorLane(laneValue)
EndFunction

Function DebugCycleContextualFavorFamily()
    Int laneValue = GetSelectedContextualFavorLane()
    Int nextFamily = GetNextFavorFamilyForLane(laneValue, GetSelectedContextualFavorFamily())
    StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", nextFamily)
EndFunction

Function DebugTriggerSelectedContextualFavor()
    TryActivateContextualFavor(GetSelectedContextualFavorLane(), GetSelectedContextualFavorFamily(), "mcm")
EndFunction

Function DebugExpireActiveFavor()
    ClearActiveFavor("mcm")
EndFunction

String Function GetSelectedContextualFavorLaneLabel()
    return GetContextualFavorLaneLabel(GetSelectedContextualFavorLane())
EndFunction

String Function GetSelectedContextualFavorFamilyLabel()
    return GetContextualFavorFamilyLabel(GetSelectedContextualFavorLane(), GetSelectedContextualFavorFamily())
EndFunction

Function DebugCycleKyneFavorMask()
    Int currentMask = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    currentMask += 1
    if currentMask > 7
        currentMask = 0
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ConditionMask", currentMask)
    SetSelectedContextualFavorLane(FAVOR_LANE_KYNE)
    DebugCycleContextualFavorFamily()
    UpdateContextualFavorRuntime()
EndFunction

Function DebugRecordHircineHuntRite()
    HandleHircineHuntRite("mcm")
EndFunction

Function DebugResetHircinePath()
    if PDV_HircinePath
        PDV_HircinePath.ResetPilotForDebug()
    endIf

    if PDV_CurseStateService
        PDV_CurseStateService.ClearCurseState("hircine_reset")
    endIf

    StorageUtil.SetIntValue(None, "PDV.Curse.State", 0)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", 0.0)
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", "hircine_reset")
EndFunction

Function DebugRenounceHircinePath()
    if PDV_HircinePath
        PDV_HircinePath.RenouncePath("mcm")
    endIf
EndFunction

Function DebugForceCurseNone()
    DebugForceCurseState(0, "mcm_force_none")
EndFunction

Function DebugForceCurseWerewolf()
    DebugForceCurseState(1, "mcm_force_werewolf")
EndFunction

Function DebugForceCurseVampire()
    DebugForceCurseState(2, "mcm_force_vampire")
EndFunction

Function DebugForceCurseState(Int newState, String reason)
    if !PDV_CurseStateService
        return
    endIf

    Int oldState = PDV_CurseStateService.GetCurseState()
    PDV_CurseStateService.SetCurseState(newState, reason)
    Int appliedState = PDV_CurseStateService.GetCurseState()

    if oldState != appliedState
        HandleCurseStateTransition(oldState, appliedState, reason)
    elseIf PDV_HircinePath
        PDV_HircinePath.UpdateResidueRecovery()
    endIf
EndFunction

Function DebugRefreshCurseFromPlayerState()
    HandleCurseStateRefresh("mcm_refresh")
EndFunction

Function DebugSetOriginRace(Int originRace)
    if PDV_GLO_OriginRace
        PDV_GLO_OriginRace.SetValue(originRace as Float)
    endIf

    RefreshPatronMirrors()
    UpdateContextualFavorRuntime()
EndFunction

Function DebugEvaluateCommitmentOffer()
    Int pendingBefore = GetPendingCommitmentDeityIndex()
    EvaluateFormalCommitmentOffer()
    Int pendingAfter = GetPendingCommitmentDeityIndex()
    Trace(1, "Commitment evaluate debug: pending " + pendingBefore + " -> " + pendingAfter + "; kyneDays=" + GetRecentCommitmentSignalDayCount(PDV_Kyne, 7) + "; kynePiety=" + FormatTwoDecimals(GetPiety(PDV_Kyne)))
EndFunction

Function DebugSeedCommitmentSignalDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int encodedLatestDay = currentDay + 1
    Int encodedPreviousDay = currentDay
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", encodedLatestDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", encodedPreviousDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", currentDay)
    Trace(1, "Commitment seed debug: " + deity.DeityName + "[" + deity.DeityIndex + "] days=" + GetRecentCommitmentSignalDayCount(deity, 7))
EndFunction

Function DebugResetCommitmentStateByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if deity
        Form deityForm = deity as Form
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", 0)
        StorageUtil.SetFloatValue(deityForm, "PDV.Commitment.OfferCooldownUntil", 0.0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DeclineCount", 0)
        if GetPendingCommitmentDeityIndex() == deity.DeityIndex
            ClearPendingCommitment()
        endIf
        Trace(1, "Commitment reset debug: " + deity.DeityName + "[" + deity.DeityIndex + "]")
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
EndFunction

Function EvaluateKyneCommitmentOffer()
    EvaluateFormalCommitmentOffer()
EndFunction

Function EvaluateFormalCommitmentOffer()
    if GetPatronState() == PATRON_STATE_ACTIVE
        return
    endIf

    if ShouldBypassFormalCommitmentOffers()
        return
    endIf

    PDV_DeityBase candidate = GetBestFormalCommitmentOfferCandidate()
    if !candidate
        return
    endIf

    if GetPendingCommitmentDeityIndex() == candidate.DeityIndex
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", candidate.DeityIndex)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", Utility.GetCurrentGameTime())
    Trace(1, "Commitment offer pending for " + candidate.DeityName + ".")
EndFunction

Function DebugAcceptPendingCommitment()
    PDV_DeityBase pendingDeity = GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    Float carrySource = 0.0
    if _activeDeity && _activeDeity != pendingDeity
        carrySource = GetPiety(_activeDeity)
    endIf

    Float carryAmount = carrySource * COMMITMENT_CARRYOVER_MULTIPLIER
    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", carryAmount)
    if carryAmount > 0.0
        DebugForceSetPietyByIndex(pendingDeity.DeityIndex, ClampValue(GetPiety(pendingDeity) + carryAmount, 0.0, PIETY_MAX))
    endIf

    ClearCommitmentOfferCooldown(pendingDeity)
    SetActiveDeity(pendingDeity)
    ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
    Trace(1, "Commitment accepted for " + pendingDeity.DeityName + ".")
EndFunction

PDV_DeityBase Function GetBestFormalCommitmentOfferCandidate()
    if !PDV_FLST_AllDeities
        return None
    endIf

    PDV_DeityBase bestDeity = None
    Float bestWeight = -1.0
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if IsEligibleForFormalCommitmentOffer(deity)
            Float weight = GetFormalCommitmentOfferWeight(deity)
            if !bestDeity || weight > bestWeight
                bestDeity = deity
                bestWeight = weight
            endIf
        endIf
        i += 1
    endWhile

    return bestDeity
EndFunction

Bool Function IsEligibleForFormalCommitmentOffer(PDV_DeityBase deity)
    if !UsesFormalCommitmentOffersForDeity(deity)
        return False
    endIf

    if deity == PDV_Kyne && !IsKyneCommitmentSignalReady()
        return False
    endIf

    if IsCommitmentOfferOnCooldown(deity)
        return False
    endIf

    if GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD
        return False
    endIf

    if !HasRecentCommitmentSignalDays(deity, 2, 7)
        return False
    endIf

    return True
EndFunction

Bool Function IsKyneCommitmentSignalReady()
    if !PDV_Kyne
        return False
    endIf

    return HasRecentCommitmentSignalDays(PDV_Kyne, 2, 7)
EndFunction

Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if deity == PDV_Kyne
        return True
    endIf

    return False
EndFunction

Float Function GetFormalCommitmentOfferWeight(PDV_DeityBase deity)
    if !deity
        return -1.0
    endIf

    Float weight = GetPiety(deity)
    weight += (GetRecentCommitmentSignalDayCount(deity, 7) as Float) * 10.0
    if deity == PDV_Kyne
        weight += 5.0
    endIf

    return weight
EndFunction

Function DebugDeclinePendingCommitment()
    PDV_DeityBase pendingDeity = GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    ApplyCommitmentDeclineCooldown(pendingDeity)
    ClearPendingCommitment()
    Trace(1, "Commitment declined/postponed.")
EndFunction

Function DebugRefusePendingCommitment()
    PDV_DeityBase pendingDeity = GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    ApplyCommitmentRefuseCooldown(pendingDeity)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 1)
    ClearPendingCommitment()
    Trace(1, "Commitment refused.")
EndFunction

Function DebugRunNeglectPass()
    RunDawnApplySpellAndNeglectLayers()
EndFunction

Function ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", -1)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", 0.0)
EndFunction

Int Function GetPendingCommitmentDeityIndex()
    return StorageUtil.GetIntValue(None, "PDV.Commitment.PendingDeityIndex")
EndFunction

PDV_DeityBase Function GetPendingCommitmentDeity()
    Int deityIndex = GetPendingCommitmentDeityIndex()
    if deityIndex < 0
        return None
    endIf

    return GetDeityByIndex(deityIndex)
EndFunction

Bool Function IsCommitmentOfferOnCooldown(PDV_DeityBase deity)
    return Utility.GetCurrentGameTime() < GetCommitmentOfferCooldownUntil(deity)
EndFunction

Float Function GetCommitmentOfferCooldownUntil(PDV_DeityBase deity)
    if !deity
        return 0.0
    endIf

    return StorageUtil.GetFloatValue(deity as Form, "PDV.Commitment.OfferCooldownUntil")
EndFunction

Float Function GetCommitmentOfferCooldownRemaining(PDV_DeityBase deity)
    Float remaining = GetCommitmentOfferCooldownUntil(deity) - Utility.GetCurrentGameTime()
    if remaining <= 0.0
        return 0.0
    endIf

    return remaining
EndFunction

Int Function GetCommitmentDeclineCount(PDV_DeityBase deity)
    if !deity
        return 0
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.DeclineCount")
EndFunction

Function ApplyCommitmentDeclineCooldown(PDV_DeityBase deity)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    Int declineCount = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.DeclineCount")
    Float cooldownDays = 7.0
    if declineCount >= 1
        cooldownDays = 14.0
    endIf

    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DeclineCount", declineCount + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.Commitment.OfferCooldownUntil", Utility.GetCurrentGameTime() + cooldownDays)
EndFunction

Function ApplyCommitmentRefuseCooldown(PDV_DeityBase deity)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Commitment.OfferCooldownUntil", Utility.GetCurrentGameTime() + 14.0)
EndFunction

Function ClearCommitmentOfferCooldown(PDV_DeityBase deity)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Commitment.OfferCooldownUntil", 0.0)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DeclineCount", 0)
EndFunction

Function RecordCommitmentSignalDay(PDV_DeityBase deity)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int encodedDay = currentDay + 1
    Int latestDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalLatestDay")
    Int previousDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay")

    if latestDay == encodedDay
        return
    endIf

    if !IsEncodedDayWithinWindow(latestDay, currentDay, 7)
        latestDay = 0
        previousDay = 0
    elseIf !IsEncodedDayWithinWindow(previousDay, currentDay, 7)
        previousDay = 0
    endIf

    if latestDay > 0
        previousDay = latestDay
    endIf

    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", encodedDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", previousDay)
EndFunction

Bool Function HasRecentCommitmentSignalDays(PDV_DeityBase deity, Int requiredCount, Int windowDays)
    return GetRecentCommitmentSignalDayCount(deity, windowDays) >= requiredCount
EndFunction

Int Function GetRecentCommitmentSignalDayCount(PDV_DeityBase deity, Int windowDays)
    if !deity
        return 0
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int latestDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalLatestDay")
    Int previousDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay")
    Int count = 0

    if IsEncodedDayWithinWindow(latestDay, currentDay, windowDays)
        count += 1
    endIf

    if previousDay != latestDay && IsEncodedDayWithinWindow(previousDay, currentDay, windowDays)
        count += 1
    endIf

    if count < 2 && StorageUtil.GetIntValue(deityForm, "PDV.Commitment.DebugSeedActive") == 1
        Int debugSeedDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.DebugSeedDay")
        Int debugDayDelta = currentDay - debugSeedDay
        if debugDayDelta >= 0 && debugDayDelta < windowDays
            count = 2
        endIf
    endIf

    return count
EndFunction

Bool Function IsEncodedDayWithinWindow(Int encodedDay, Int currentDay, Int windowDays)
    if encodedDay <= 0
        return False
    endIf

    Int dayValue = encodedDay - 1
    Int dayDelta = currentDay - dayValue
    if dayDelta < 0
        return False
    endIf

    return dayDelta < windowDays
EndFunction

Bool Function ShouldBypassFormalCommitmentOffers()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD && IsNordVampireSuppressed()
        return True
    endIf

    return originRace == ORIGIN_KHAJIIT || originRace == ORIGIN_BOSMER
EndFunction

Function HandleCurseStateRefresh(String reason)
    if !PDV_CurseStateService
        return
    endIf

    Int oldState = PDV_CurseStateService.GetCurseState()
    PDV_CurseStateService.RefreshFromPlayerState()
    Int newState = PDV_CurseStateService.GetCurseState()

    if oldState != newState
        HandleCurseStateTransition(oldState, newState, reason)
    elseIf PDV_HircinePath
        PDV_HircinePath.UpdateResidueRecovery()
    endIf
EndFunction

Function HandleCurseStateTransition(Int oldState, Int newState, String reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.State", newState)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", reason)
    ApplyCurseRaceHandlers(oldState, newState, reason)
    Trace(1, "Curse transition " + oldState + " -> " + newState + " (" + reason + ")")
EndFunction

Function ApplyCurseRaceHandlers(Int oldState, Int newState, String reason)
    Int originRace = GetPlayerOriginRaceIndex()
    Bool curseActive = newState != 0

    if originRace == ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.Curse.Bosmer.RoutePressure", BoolToInt(curseActive))
    elseIf originRace == ORIGIN_BRETON
        if curseActive
            StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 2)
        elseIf oldState != 0
            StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 1)
        else
            StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 0)
        endIf
    elseIf originRace == ORIGIN_DUNMER
        if curseActive
            StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 1)
        elseIf oldState != 0
            StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 2)
        else
            StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 0)
        endIf
    elseIf originRace == ORIGIN_ALTMER
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", BoolToInt(curseActive))
    elseIf originRace == ORIGIN_NORD
        ApplyNordCurseHandlers(oldState, newState, reason)
        if PDV_HircinePath
            PDV_HircinePath.HandleCurseTransition(oldState, newState, reason)
            PDV_HircinePath.UpdateResidueRecovery()
        endIf
    endIf
EndFunction

Function ApplyNordCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressNordCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 0)
        ClearActiveFavor("nord_vampire")
        ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireFeedbackShown") != 1
            ShowNordMessage(PDV_Msg_Nord_CurseState_VampireOnset, "Sovngarde is closed while the thirst remains. Cure the curse, and the scar will still be remembered.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 1)
        endIf
    elseIf oldState == 2 && newState != 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireCureFeedbackShown") != 1
            ShowNordMessage(PDV_Msg_Nord_CurseState_VampireCured, "The thirst is gone. The road opens again, but the scar remains.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 1)
        endIf
    elseIf newState == 1
        if StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfFeedbackShown") != 1
            ShowNordMessage(PDV_Msg_Nord_CurseState_WerewolfOnset, "The hunt pulls against Sovngarde. Master the beast, or it will name the road for you.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 0)
    endIf
EndFunction

Bool Function ShouldSuppressNordCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowNordMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if suppressModal
        Debug.Notification(fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Bool Function IsBosmerOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
EndFunction

Function EnsureBosmerSetupChoice()
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    if HasBosmerSetupCompleted()
        return
    endIf

    if GetPlayerOriginRaceIndex() < 0
        return
    endIf

    if !PDV_MSG_BosmerSetupChoice
        Debug.MessageBox("PlayerDevotion is missing the Bosmer setup message record.")
        Trace(1, "Bosmer setup choice blocked: message record missing.")
        return
    endIf

    Int selection = PDV_MSG_BosmerSetupChoice.Show()
    if selection < BOSMER_PATH_OLD_CONTRACT || selection > BOSMER_PATH_BANDIT_ROAD
        Trace(1, "Bosmer setup choice returned unsupported option " + selection)
        return
    endIf

    ApplyBosmerInitialChoice(selection, "startup_choice")
EndFunction

Bool Function HasBosmerSetupCompleted()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.SetupComplete") == 1
EndFunction

Function ApplyBosmerInitialChoice(Int pathState, String reason)
    if !PDV_BosmerPathTrack
        return
    endIf

    InitializeBosmerStorage()
    PDV_BosmerPathTrack.SetState(pathState, reason)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 1)

    if pathState == BOSMER_PATH_OLD_CONTRACT
        EnterBosmerOldContract(True, reason)
    else
        SetBosmerPactBound(False, reason)
        SetBosmerGreenPactCompliance(0, reason)
        ApplyBosmerPathPatron(pathState, reason)
    endIf
EndFunction

Function InitializeBosmerStorage()
    if StorageUtil.GetIntValue(None, "PDV.Bosmer.Initialized") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.PactBound", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactCompliance", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.LapsedFromPact", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.Initialized", 1)
EndFunction

Bool Function IsBosmerPactBound()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.PactBound") == 1
EndFunction

Function SetBosmerPactBound(Bool isBound, String reason)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.PactBound", BoolToInt(isBound))
    Trace(2, "Bosmer PactBound -> " + BoolToInt(isBound) + " (" + reason + ")")
EndFunction

Int Function GetBosmerGreenPactCompliance()
    return ClampInt(StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactCompliance"), 0, 100)
EndFunction

Function SetBosmerGreenPactCompliance(Int value, String reason)
    Int normalizedValue = ClampInt(value, 0, 100)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactCompliance", normalizedValue)
    Trace(2, "Bosmer GreenPactCompliance -> " + normalizedValue + " (" + reason + ")")
EndFunction

Function AdjustBosmerGreenPactCompliance(Int delta, String reason)
    SetBosmerGreenPactCompliance(GetBosmerGreenPactCompliance() + delta, reason)
EndFunction

Int Function GetBosmerLapsedFromPact()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.LapsedFromPact")
EndFunction

Function SetBosmerLapsedFromPact(Int value, String reason)
    Int normalizedValue = value
    if normalizedValue < 0
        normalizedValue = 0
    elseIf normalizedValue > 2
        normalizedValue = 2
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.LapsedFromPact", normalizedValue)
    Trace(2, "Bosmer LapsedFromPact -> " + normalizedValue + " (" + reason + ")")
EndFunction

Bool Function HasBosmerTerminalRenunciation()
    return GetBosmerLapsedFromPact() >= 2
EndFunction

Function EnterBosmerOldContract(Bool isStartupChoice, String reason)
    if HasBosmerTerminalRenunciation()
        Trace(1, "Old Contract entry blocked by terminal renunciation.")
        return
    endIf

    SetBosmerPactBound(True, reason)
    if GetBosmerLapsedFromPact() > 0
        SetBosmerGreenPactCompliance(30, reason)
    elseIf isStartupChoice
        SetBosmerGreenPactCompliance(80, reason)
    else
        SetBosmerGreenPactCompliance(60, reason)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
    ApplyBosmerPathPatron(BOSMER_PATH_OLD_CONTRACT, reason)

    if PDV_Yffre && GetBosmerLapsedFromPact() > 0
        AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_RECOMMITMENT, None)
    endIf
EndFunction

Function ExitBosmerOldContract(Bool countLapse, String reason)
    if !IsBosmerPactBound()
        return
    endIf

    SetBosmerPactBound(False, reason)
    if countLapse
        SetBosmerLapsedFromPact(GetBosmerLapsedFromPact() + 1, reason)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
EndFunction

Function ApplyBosmerPathPatron(Int pathState, String reason)
    PDV_DeityBase deity = GetBosmerForegroundDeity(pathState)
    if !deity
        Trace(1, "Bosmer foreground deity missing for state " + pathState + " (" + reason + ")")
        return
    endIf

    SetActiveDeity(deity)
    Trace(2, "Bosmer foreground patron -> " + deity.DeityName + " (" + reason + ")")
EndFunction

PDV_DeityBase Function GetBosmerForegroundDeity(Int pathState)
    if pathState == BOSMER_PATH_OLD_CONTRACT || pathState == BOSMER_PATH_LIVING_STORY
        return PDV_Yffre
    elseIf pathState == BOSMER_PATH_EXCHANGE
        return PDV_Zen
    elseIf pathState == BOSMER_PATH_BANDIT_ROAD
        return PDV_BaanDar
    endIf

    return None
EndFunction

Function EnsureBosmerCurrentPathFallback()
    if !PDV_BosmerPathTrack || !HasBosmerSetupCompleted()
        return
    endIf

    if PDV_BosmerPathTrack.GetCurrentState() != PDV_BosmerPathTrack.UnsetSentinel
        return
    endIf

    PDV_BosmerPathTrack.SetState(BOSMER_PATH_LIVING_STORY, "fallback")
    SetBosmerPactBound(False, "fallback")
    ApplyBosmerPathPatron(BOSMER_PATH_LIVING_STORY, "fallback")
EndFunction

Function EvaluateBosmerForcedReckoning()
    if !IsBosmerPactBound()
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        return
    endIf

    if GetBosmerGreenPactCompliance() >= 20
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        return
    endIf

    Int apostateDays = StorageUtil.GetIntValue(None, "PDV.Bosmer.ApostateDays") + 1
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", apostateDays)
    if apostateDays < 3
        return
    endIf

    if !PDV_MSG_BosmerReckoning
        Debug.MessageBox("PlayerDevotion is missing the Bosmer reckoning message record.")
        Trace(1, "Bosmer reckoning blocked: message record missing.")
        return
    endIf

    Int choice = PDV_MSG_BosmerReckoning.Show()
    if choice == 0
        SetBosmerGreenPactCompliance(30, "reckoning_recommit")
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        if PDV_Yffre
            AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_RECOMMITMENT, None)
        endIf
    else
        ExitBosmerOldContract(True, "reckoning_renounce")
        PDV_BosmerPathTrack.SetState(BOSMER_PATH_LIVING_STORY, "reckoning_renounce")
        ApplyBosmerPathPatron(BOSMER_PATH_LIVING_STORY, "reckoning_renounce")
    endIf
EndFunction

Function EvaluateBosmerPathSuggestion()
    if !PDV_BosmerPathTrack || !HasBosmerSetupCompleted()
        return
    endIf

    if PDV_BosmerPathTrack.HasOfferedTransition() || PDV_BosmerPathTrack.IsTransitionPending() || PDV_BosmerPathTrack.IsTransitionLockedOut()
        return
    endIf

    Int targetState = GetSuggestedBosmerPathState()
    if targetState < 0
        return
    endIf

    PDV_BosmerPathTrack.OfferTransition(targetState, "dawn_suggestion")
    HandleBosmerSuggestionPopup(targetState)
EndFunction

Int Function GetSuggestedBosmerPathState()
    if !PDV_BosmerPathTrack
        return -1
    endIf

    Int currentState = PDV_BosmerPathTrack.GetCurrentState()
    Int bestState = -1
    Int bestScore = -1

    Int livingCount = PDV_BosmerPathTrack.GetRecentEvidenceDayCount(BOSMER_PATH_LIVING_STORY, 7)
    if currentState != BOSMER_PATH_LIVING_STORY && livingCount >= 1
        bestState = BOSMER_PATH_LIVING_STORY
        bestScore = 10 + livingCount
    endIf

    Int exchangeCount = PDV_BosmerPathTrack.GetRecentEvidenceDayCount(BOSMER_PATH_EXCHANGE, 7)
    if currentState != BOSMER_PATH_EXCHANGE && exchangeCount >= 2 && (20 + exchangeCount) > bestScore
        bestState = BOSMER_PATH_EXCHANGE
        bestScore = 20 + exchangeCount
    endIf

    Int banditCount = PDV_BosmerPathTrack.GetRecentEvidenceDayCount(BOSMER_PATH_BANDIT_ROAD, 7)
    if currentState != BOSMER_PATH_BANDIT_ROAD && banditCount >= 2 && (20 + banditCount) > bestScore
        bestState = BOSMER_PATH_BANDIT_ROAD
        bestScore = 20 + banditCount
    endIf

    Int pactCount = PDV_BosmerPathTrack.GetRecentEvidenceDayCount(BOSMER_PATH_OLD_CONTRACT, 7)
    if currentState != BOSMER_PATH_OLD_CONTRACT && !HasBosmerTerminalRenunciation() && pactCount >= 3 && (30 + pactCount) > bestScore
        bestState = BOSMER_PATH_OLD_CONTRACT
    endIf

    return bestState
EndFunction

Function HandleBosmerSuggestionPopup(Int targetState)
    Message suggestionMessage = GetBosmerSuggestionMessage(targetState)
    if !suggestionMessage
        Debug.MessageBox("PlayerDevotion is missing the Bosmer path suggestion message record.")
        PDV_BosmerPathTrack.ClearOfferedTransition("missing_message")
        Trace(1, "Bosmer suggestion popup blocked for " + targetState + ": message record missing.")
        return
    endIf

    Int choice = suggestionMessage.Show()
    if choice == 0
        PDV_BosmerPathTrack.AcceptOfferedTransition("popup_accept")
        SendPrismaToast("journal", "good", "A new path stirs", "Confirm the change at the next rite.")
    else
        PDV_BosmerPathTrack.RefuseOfferedTransition("popup_refuse")
        SendPrismaToast("journal", "neutral", "The call fades", "You turn aside from that path for now.")
    endIf
EndFunction

Message Function GetBosmerSuggestionMessage(Int targetState)
    if targetState == BOSMER_PATH_LIVING_STORY
        return PDV_MSG_BosmerSuggestLivingStory
    elseIf targetState == BOSMER_PATH_EXCHANGE
        return PDV_MSG_BosmerSuggestExchange
    elseIf targetState == BOSMER_PATH_BANDIT_ROAD
        return PDV_MSG_BosmerSuggestBanditRoad
    elseIf targetState == BOSMER_PATH_OLD_CONTRACT
        return PDV_MSG_BosmerSuggestOldContract
    endIf

    return None
EndFunction

Function ConfirmBosmerPendingTransition(String reason)
    if !PDV_BosmerPathTrack || !PDV_BosmerPathTrack.IsTransitionPending()
        return
    endIf

    Int pendingState = PDV_BosmerPathTrack.GetPendingState()
    if !CanConfirmBosmerPathState(pendingState)
        PDV_BosmerPathTrack.CancelPendingTransition("rite_invalid")
        SendPrismaToast("journal", "bad", "The rite fails", "The new path has not yet been proven.")
        return
    endIf

    Int currentState = PDV_BosmerPathTrack.GetCurrentState()
    if currentState == BOSMER_PATH_OLD_CONTRACT && pendingState != BOSMER_PATH_OLD_CONTRACT
        ExitBosmerOldContract(True, reason)
    endIf

    PDV_BosmerPathTrack.ConfirmPendingTransition(reason)
    if pendingState == BOSMER_PATH_OLD_CONTRACT
        EnterBosmerOldContract(False, reason)
    else
        SetBosmerPactBound(False, reason)
        ApplyBosmerPathPatron(pendingState, reason)
        if pendingState == BOSMER_PATH_LIVING_STORY && PDV_Yffre
            AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_LIVING_STORY, None)
        elseIf pendingState == BOSMER_PATH_EXCHANGE && PDV_Zen
            AwardCuratedSignal(PDV_Zen, PDV_Zen.SIGNAL_CONFIRMATION, None)
        elseIf pendingState == BOSMER_PATH_BANDIT_ROAD && PDV_BaanDar
            AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_CONFIRMATION, None)
        endIf
    endIf

    SendPrismaToast("journal", "good", "The path settles", "Your devotion takes a clearer shape.")
EndFunction

Bool Function CanConfirmBosmerPathState(Int targetState)
    if !PDV_BosmerPathTrack
        return False
    endIf

    if targetState == BOSMER_PATH_LIVING_STORY
        return PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 1, 7)
    elseIf targetState == BOSMER_PATH_EXCHANGE
        return PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 2, 7)
    elseIf targetState == BOSMER_PATH_BANDIT_ROAD
        return PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 2, 7)
    elseIf targetState == BOSMER_PATH_OLD_CONTRACT
        if HasBosmerTerminalRenunciation()
            return False
        endIf
        return PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 3, 7)
    endIf

    return False
EndFunction

Int Function GetPlayerOriginRaceIndex()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf

    return -1
EndFunction

Function EnsureSurveyDevotionPower()
    if !PDV_SPEL_SurveyDevotion
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if !playerRef.HasSpell(PDV_SPEL_SurveyDevotion)
        playerRef.AddSpell(PDV_SPEL_SurveyDevotion, False)
    endIf

    if playerRef.GetEquippedSpell(2) == None && playerRef.GetEquippedShout() == None
        playerRef.EquipSpell(PDV_SPEL_SurveyDevotion, 2)
    endIf
EndFunction

Bool Function IsNordVampireSuppressed()
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return False
    endIf

    if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Nord.VampireActive") == 1
EndFunction

Bool Function HasNordVampireScar()
    return GetPlayerOriginRaceIndex() == ORIGIN_NORD && StorageUtil.GetIntValue(None, "PDV.Nord.VampireScar") == 1
EndFunction

String Function GetSurveyDevotionText()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace < 0
        return "Devotion has not settled yet. Wait a moment, then survey again."
    endIf

    if originRace != ORIGIN_NORD
        return "Your devotion is being watched. Current standing: " + GetCurrentStandingLabel() + "."
    endIf

    String text = GetNordSurveyBaseText()
    String scarText = GetNordScarLabel()
    if scarText != ""
        text = text + "\n\n" + scarText
    endIf

    return text
EndFunction

String Function GetPlayerMcmSummaryLine()
    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return GetNordDevotionModeLabel() + " | " + GetCurrentStandingLabel() + " | " + GetPlayerCursePublicLabel()
    endIf

    return GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + " | " + GetPatronStateLabel() + " | " + GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmPatronLine()
    if _activeDeity
        return _activeDeity.DeityName
    endIf

    return GetPatronStateLabel()
EndFunction

String Function GetPlayerMcmStandingLine()
    return GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmModeLine()
    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return GetNordDevotionModeLabel()
    endIf

    return GetPatronStateLabel()
EndFunction

String Function GetPlayerMcmCurseLine()
    return GetPlayerCursePublicLabel()
EndFunction

String Function GetPlayerMcmFavorLine()
    if IsNordVampireSuppressed()
        return "Suppressed by vampire curse"
    endIf

    Int laneValue = GetActiveFavorLane()
    Int familyValue = GetActiveFavorFamily()
    if laneValue != FAVOR_LANE_NONE && familyValue > 0
        return GetContextualFavorLaneLabel(laneValue)
    endIf

    Int eligibleLane = ResolveEligibleFavorLane()
    if eligibleLane != FAVOR_LANE_NONE
        return GetContextualFavorLaneLabel(eligibleLane)
    endIf

    return "None active"
EndFunction

String Function GetPlayerMcmNeglectLine()
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount")
    if activeCount > 0
        return "Attention needed"
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE
        return "Steady"
    endIf

    return "None"
EndFunction

String Function GetNordSurveyBaseText()
    if IsNordVampireSuppressed()
        return "Sovngarde is closed while the thirst remains. Current standing: " + GetCurrentStandingLabel() + ". Cure the curse to reopen the road."
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        String focusedText = _activeDeity.DeityName + " names you. Current standing: " + GetCurrentStandingLabel() + "."
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention."
        endIf
        return focusedText + " The bond holds."
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == NORD_BASELINE_NINE_DIVINES
            return "You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath. Current standing: " + GetCurrentStandingLabel() + "."
        endIf

        return "You honor the Old Ways broadly. The pantheon has noted you. Current standing: " + GetCurrentStandingLabel() + "."
    endIf

    if PDV_HircinePath
        String hircineSummary = PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "The hunt pulls at the edge of the old road. Current standing: " + GetCurrentStandingLabel() + "."
        endIf
    endIf

    return "No Nord patron has fully answered yet. Keep the rites, and the road will become clearer."
EndFunction

String Function GetNordDevotionModeLabel()
    if IsNordVampireSuppressed()
        return "Vampire rupture"
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        return "Focused " + _activeDeity.DeityName
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return "Broad Nine Divines"
        endIf

        return "Broad Old Ways"
    endIf

    return "Unsettled"
EndFunction

String Function GetCurrentStandingLabel()
    Int tierValue = TIER_NONE
    if _activeDeity
        tierValue = GetTier(_activeDeity)
    elseIf PDV_GLO_ActiveTier
        tierValue = PDV_GLO_ActiveTier.GetValueInt()
    endIf

    if tierValue >= TIER_CHAMPION
        return "Champion"
    elseIf tierValue == TIER_DEVOTED
        return "Devoted"
    elseIf tierValue == TIER_SEEKER
        return "Seeker"
    endIf

    return "Unproven"
EndFunction

String Function GetPlayerCursePublicLabel()
    if PDV_CurseStateService
        String curseLabel = PDV_CurseStateService.GetCurseStateLabel()
        if curseLabel != "None"
            return curseLabel
        endIf
    endIf

    if HasNordVampireScar()
        return "Cured vampire scar"
    endIf

    return "None"
EndFunction

String Function GetNordScarLabel()
    if HasNordVampireScar() && !IsNordVampireSuppressed()
        return "The vampire scar remains visible. The road is open again, but not unmarked."
    endIf

    return ""
EndFunction

String Function DebugGetPatternProvingSummary()
    String summary = "Concordat=" + GetConcordatSummary()
    summary = summary + "; Bosmer=" + GetBosmerSummary()
    summary = summary + "; DunmerAncestor=" + GetDunmerAncestorSummary()
    summary = summary + "; KhajiitLunar=" + GetKhajiitLunarSummary()
    summary = summary + "; Favor=" + GetContextualFavorSummary()
    summary = summary + "; Commitment=" + GetCommitmentSummary()
    summary = summary + "; Neglect=" + GetNeglectSummary()
    summary = summary + "; Hircine=" + GetHircineSummary()
    summary = summary + "; Curse=" + GetCurseStateSummary()
    summary = summary + "; CurseHandlers=" + GetCurseHandlerSummary()
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

    return PDV_BosmerPathTrack.GetStateLabel() + ";offered=" + PDV_BosmerPathTrack.GetOfferedStateLabel() + ";pending=" + PDV_BosmerPathTrack.GetPendingStateLabel() + ";pact=" + BoolToInt(IsBosmerPactBound()) + ";gpc=" + GetBosmerGreenPactCompliance() + ";lapsed=" + GetBosmerLapsedFromPact() + ";gp=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount") + ";penalty=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive")
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

    return PDV_KhajiitLunarSubstrate.GetPilotSummary() + "; focus=" + GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()) + "; kh=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_KHENARTHI)) + "; az=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_AZURAH))
EndFunction

String Function GetContextualFavorSummary()
    Int activeLane = GetActiveFavorLane()
    Int activeFamily = GetActiveFavorFamily()
    Float remainingDays = StorageUtil.GetFloatValue(None, "PDV.Favor.ActiveExpiresAt") - Utility.GetCurrentGameTime()
    if remainingDays < 0.0
        remainingDays = 0.0
    endIf
    String summary = "lane=" + GetContextualFavorLaneLabel(activeLane)
    summary = summary + ";family=" + GetContextualFavorFamilyLabel(activeLane, activeFamily)
    summary = summary + ";spell=" + StorageUtil.GetStringValue(None, "PDV.Favor.ActiveSpell")
    summary = summary + ";expires=" + FormatTwoDecimals(remainingDays)
    summary = summary + ";selected=" + GetSelectedContextualFavorLaneLabel() + "/" + GetSelectedContextualFavorFamilyLabel()
    return summary
EndFunction

String Function GetKyneFavorSummary()
    Int maskValue = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ActiveCount")
    return "mask=" + maskValue + ";conds=" + CountSetBits(maskValue) + ";active=" + activeCount + ";generic=" + GetContextualFavorSummary()
EndFunction

String Function GetCommitmentSummary()
    PDV_DeityBase pending = GetPendingCommitmentDeity()
    String summary = "state=" + GetPatronStateLabel() + ";active=" + GetDeitySummaryLabel(_activeDeity) + ";pending=" + GetPendingCommitmentDeityIndex() + ";label=" + GetDeitySummaryLabel(pending) + ";carry=" + StorageUtil.GetFloatValue(None, "PDV.Commitment.LastCarryover") + ";rupture=" + StorageUtil.GetIntValue(None, "PDV.Commitment.Rupture")
    if pending
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(pending, 7) + ";cooldown=" + FormatTwoDecimals(GetCommitmentOfferCooldownRemaining(pending))
    elseIf PDV_Kyne
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(PDV_Kyne, 7) + ";cooldown=" + FormatTwoDecimals(GetCommitmentOfferCooldownRemaining(PDV_Kyne))
    endIf

    return summary
EndFunction

String Function GetNeglectSummary()
    return "state=" + GetPatronStateLabel() + ";broad=" + BoolToInt(IsBroadWorshipActive()) + ";activeDeity=" + GetDeitySummaryLabel(_activeDeity) + ";count=" + StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") + ";active=" + GetNeglectActiveSummary() + ";kyneSpell=" + StorageUtil.GetIntValue(None, "PDV.Neglect.KyneSpellActive")
EndFunction

String Function DebugGetDecaySummaryByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        return "missing deity " + deityIndex
    endIf

    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float lastEvent = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    Int lastDecayDay = StorageUtil.GetIntValue(deityForm, "PDV.LastDecayAppliedDay")
    Float multiplier = 1.0
    if IsBroadWorshipActive()
        multiplier = BROAD_WORSHIP_DECAY_MULTIPLIER
    endIf

    return "deity=" + deity.DeityName + ";state=" + GetPatronStateLabel() + ";active=" + BoolToInt(deity == _activeDeity) + ";broad=" + BoolToInt(IsBroadWorshipActive()) + ";p=" + FormatTwoDecimals(piety) + ";tier=" + GetTier(deity) + ";lastEvent=" + FormatTwoDecimals(lastEvent) + ";lastDecayDay=" + lastDecayDay + ";rate=" + FormatTwoDecimals(DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity)) + ";floor=" + FormatTwoDecimals(GetDecayFloorForDeity(deity, piety))
EndFunction

String Function GetHircineSummary()
    if !PDV_HircinePath
        return "missing"
    endIf

    return PDV_HircinePath.GetPilotSummary()
EndFunction

String Function GetCurseStateSummary()
    if !PDV_CurseStateService
        return "missing"
    endIf

    return PDV_CurseStateService.GetCurseStateLabel()
EndFunction

String Function GetCurseHandlerSummary()
    return "origin=" + GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + ";bosmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Bosmer.RoutePressure") + ";breton=" + StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState") + ";dunmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture") + ";altmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Altmer.ExilePressure")
EndFunction

String Function GetOriginRaceLabel(Int originRace)
    if originRace == ORIGIN_NORD
        return "Nord"
    elseIf originRace == ORIGIN_BRETON
        return "Breton"
    elseIf originRace == ORIGIN_ALTMER
        return "Altmer"
    elseIf originRace == ORIGIN_BOSMER
        return "Bosmer"
    elseIf originRace == ORIGIN_DUNMER
        return "Dunmer"
    elseIf originRace == ORIGIN_KHAJIIT
        return "Khajiit"
    endIf

    return "" + originRace
EndFunction

String Function GetNeglectActiveSummary()
    if !PDV_FLST_AllDeities
        return "none"
    endIf

    String output = ""
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && IsNeglectFlagActive(deity)
            if output == ""
                output = deity.DeityName
            else
                output = output + "," + deity.DeityName
            endIf
        endIf
        i += 1
    endWhile

    if output == ""
        return "none"
    endIf

    return output
EndFunction

String Function GetDeitySummaryLabel(PDV_DeityBase deity)
    if deity
        return deity.DeityName
    endIf

    return "none"
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

    Int tierCap = deity.GetTierCap()
    if piety >= deity.ThresholdChampion
        if tierCap < TIER_CHAMPION
            return tierCap
        endIf
        return TIER_CHAMPION
    elseIf piety >= deity.ThresholdDevoted
        if tierCap < TIER_DEVOTED
            return tierCap
        endIf
        return TIER_DEVOTED
    elseIf piety >= deity.ThresholdSeeker
        if tierCap < TIER_SEEKER
            return tierCap
        endIf
        return TIER_SEEKER
    endIf

    return TIER_NONE
EndFunction

PDV_DeityBase Function GetDeityByIndex(Int deityIndex)
    if deityIndex < 0 || !PDV_FLST_AllDeities
        return GetKnownDeityByIndex(deityIndex)
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

    return GetKnownDeityByIndex(deityIndex)
EndFunction

PDV_DeityBase Function GetKnownDeityByIndex(Int deityIndex)
    if PDV_Kyne && PDV_Kyne.DeityIndex == deityIndex
        return PDV_Kyne
    endIf

    if PDV_Talos && PDV_Talos.DeityIndex == deityIndex
        return PDV_Talos
    endIf

    if PDV_Yffre && PDV_Yffre.DeityIndex == deityIndex
        return PDV_Yffre
    endIf

    if PDV_Zen && PDV_Zen.DeityIndex == deityIndex
        return PDV_Zen
    endIf

    if PDV_BaanDar && PDV_BaanDar.DeityIndex == deityIndex
        return PDV_BaanDar
    endIf

    return None
EndFunction

Function UpdatePatronDeityGlobal()
    if _activeDeity
        StorageUtil.SetIntValue(None, "PDV.PatronDeityIndex", _activeDeity.DeityIndex)
    else
        StorageUtil.SetIntValue(None, "PDV.PatronDeityIndex", -1)
    endIf

    if !PDV_GLO_PatronDeity
        return
    endIf

    if !_activeDeity
        PDV_GLO_PatronDeity.SetValue(0.0)
        return
    endIf

    PDV_GLO_PatronDeity.SetValue((_activeDeity as Form).GetFormID() as Float)
EndFunction

Function RestoreActiveDeityFromStoredPatron()
    Int deityIndex = StorageUtil.GetIntValue(None, "PDV.PatronDeityIndex")
    if deityIndex < 0
        return
    endIf

    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        Trace(1, "Stored patron deity index " + deityIndex + " could not be restored.")
        return
    endIf

    _activeDeity = deity
    EnsureDeityState(_activeDeity)
    _activeDeity.OnPatronStart()
    Trace(2, "Restored active deity from stored patron index " + deityIndex)
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

    if deity.DeityName == "Y'ffre"
        return "yffre"
    endIf

    if deity.DeityName == "Z'en"
        return "zen"
    endIf

    if deity.DeityName == "Baan Dar"
        return "baan-dar"
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
