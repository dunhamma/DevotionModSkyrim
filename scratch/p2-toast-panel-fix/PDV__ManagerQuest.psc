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
PDV_StateTrack Property PDV_AltmerCrisisTrack Auto
PDV_Substrate_DunmerAncestor Property PDV_DunmerAncestorSubstrate Auto
PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto
PDV_Substrate_ArgonianHist Property PDV_ArgonianHistSubstrate Auto
PDV_StateTrack Property PDV_ArgonianHistPostureTrack Auto
PDV_StateTrack Property PDV_OrcLifeModeTrack Auto
PDV_StateTrack Property PDV_RedguardSectTrack Auto
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
Spell Property PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness Auto
Spell Property PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement Auto
Message Property PDV_MSG_BosmerSetupChoice Auto
Message Property PDV_MSG_BosmerSuggestLivingStory Auto
Message Property PDV_MSG_BosmerSuggestExchange Auto
Message Property PDV_MSG_BosmerSuggestBanditRoad Auto
Message Property PDV_MSG_BosmerSuggestOldContract Auto
Message Property PDV_MSG_BosmerReckoning Auto
Message Property PDV_MSG_StartupBretonChoice Auto
Message Property PDV_MSG_StartupRedguardChoice Auto
Message Property PDV_MSG_StartupOrcChoice Auto
Message Property PDV_MSG_StartupConfirmChoice Auto
Message Property PDV_Msg_Nord_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireCured Auto
Message Property PDV_Msg_Altmer_VampireExiledPath_Entry Auto
Message Property PDV_Msg_Altmer_VampireExiledPath_Recognition Auto
Message Property PDV_Msg_Altmer_CurseState_WerewolfHardHalt Auto

Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly

Int Property FRAMEWORK_SCHEMA_VERSION = 3 AutoReadOnly
Int Property PATRON_STATE_UNSET = 0 AutoReadOnly
Int Property PATRON_STATE_BROAD = 1 AutoReadOnly
Int Property PATRON_STATE_ACTIVE = 2 AutoReadOnly

Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_DAILY_MAX_DELTA = 4.3 AutoReadOnly
Float Property DECAY_GRACE_DAYS = 2.0 AutoReadOnly
Float Property DECAY_PER_DAY = 0.5 AutoReadOnly
Float Property BROAD_WORSHIP_DECAY_MULTIPLIER = 0.2 AutoReadOnly
Float Property GAIN_RATE_SCALE = 1.32 AutoReadOnly
Float Property TIER_DOWN_HYSTERESIS = 5.0 AutoReadOnly
Float Property ORC_RATE_MULT_STRONGHOLD = 1.0 AutoReadOnly
Float Property ORC_RATE_MULT_CITY = 0.75 AutoReadOnly
Float Property ORC_RATE_MULT_LEGIONEXILE = 0.6 AutoReadOnly
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
Int Property ORIGIN_IMPERIAL = 1 AutoReadOnly
Int Property ORIGIN_BRETON = 2 AutoReadOnly
Int Property ORIGIN_ALTMER = 3 AutoReadOnly
Int Property ORIGIN_BOSMER = 4 AutoReadOnly
Int Property ORIGIN_DUNMER = 5 AutoReadOnly
Int Property ORIGIN_KHAJIIT = 6 AutoReadOnly
Int Property ORIGIN_ARGONIAN = 7 AutoReadOnly
Int Property ORIGIN_ORC = 8 AutoReadOnly
Int Property ORIGIN_REDGUARD = 9 AutoReadOnly
Int Property STARTUP_MODE_INFO_ONLY = 0 AutoReadOnly
Int Property STARTUP_MODE_EXPLICIT_CHOICE = 1 AutoReadOnly
String Property STARTUP_ADVISORY_TEXT = "This is only where your road begins. What you revere, neglect, or defy from here will shape the devotion that grows." AutoReadOnly
Int Property ORC_LIFE_MODE_CITY = 0 AutoReadOnly
Int Property ORC_LIFE_MODE_STRONGHOLD = 1 AutoReadOnly
Int Property ORC_LIFE_MODE_LEGION_EXILE = 2 AutoReadOnly
Int Property REDGUARD_SECT_CROWN = 0 AutoReadOnly
Int Property REDGUARD_SECT_FOREBEAR = 1 AutoReadOnly
Int Property REDGUARD_SECT_ASHABAH = 2 AutoReadOnly
Int Property NORD_BASELINE_OLD_WAYS = 0 AutoReadOnly
Int Property NORD_BASELINE_NINE_DIVINES = 1 AutoReadOnly
Int Property FAVOR_LANE_NONE = 0 AutoReadOnly
Int Property FAVOR_LANE_KYNE = 1 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_OLD_WAYS = 2 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_NINE_DIVINES = 3 AutoReadOnly
Int Property FAVOR_LANE_ALTMER = 4 AutoReadOnly
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
Int Property FAVOR_FAMILY_ALTMER_DAWN_STEADINESS = 31 AutoReadOnly
Int Property FAVOR_FAMILY_ALTMER_ORTHODOX_COST = 32 AutoReadOnly
Int Property ALTMER_CRISIS_NONE = 0 AutoReadOnly
Int Property ALTMER_CRISIS_DISSONANT = 1 AutoReadOnly
Int Property ALTMER_CRISIS_QUESTIONING = 2 AutoReadOnly
Int Property ALTMER_CRISIS_REASSERTING = 3 AutoReadOnly
Int Property ALTMER_CRISIS_SCARRED_RESOLVED = 4 AutoReadOnly
Int Property ALTMER_LORKHAN_PRESSURE_DIRECT = 1 AutoReadOnly
Int Property ALTMER_LORKHAN_PRESSURE_SHOR_ADJACENT = 2 AutoReadOnly
Int Property ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION = 3 AutoReadOnly
Int Property ALTMER_LORKHAN_PRESSURE_CONTEXTUAL = 4 AutoReadOnly
Int Property ALTMER_CRISIS_SOURCE_DRAGONBORN = 1 AutoReadOnly
Int Property ALTMER_CRISIS_SOURCE_SOVNGARDE = 2 AutoReadOnly
Int Property ALTMER_CRISIS_SOURCE_TALOS = 3 AutoReadOnly
Int Property ALTMER_CRISIS_SOURCE_COMPANIONS = 4 AutoReadOnly
Int Property ARGONIAN_HIST_POSTURE_NORMAL = 0 AutoReadOnly
Int Property ARGONIAN_HIST_POSTURE_DISTANT = 1 AutoReadOnly
Int Property ARGONIAN_HIST_POSTURE_STRAINED = 2 AutoReadOnly
Int Property ARGONIAN_HIST_POSTURE_SILENCED = 3 AutoReadOnly
Int Property ARGONIAN_HIST_POSTURE_CORRUPTED = 4 AutoReadOnly
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
Bool _panelDirty = False

Event OnInit()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    RegisterManagerShoutSignals()
    RefreshPatronMirrors()
    UpdateContextualFavorRuntime()
    EnsureSurveyDevotionPower()
    RequestPanelRefresh()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    EnsurePhase8RuntimeWiring()
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    EnsureUnifiedStartupChoice()
    UpdateContextualFavorRuntime()
    EnsureSurveyDevotionPower()

    if _panelDirty && PDV_PrismaBridge.IsAvailable()
        PushDevotionPanel()
        _panelDirty = False
    endIf

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

Bool Function SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival)
    if !PDV_PrismaBridge.IsAvailable()
        return False
    endIf
    String deityName = ""
    String symbolName = "journal"
    if deity
        deityName = deity.DeityName
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"" + JsonSafeString(eventName) + "\""
    j = j + ",\"deity\":\"" + JsonSafeString(deityName) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + JsonSafeString(rival) + "\""
    endIf
    j = j + "}}"
    return PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

; --- Main Prisma panel payload ---
; The panel has no Papyrus open-hook (open is native/SKSE), so we keep the last
; SendJson payload current by marking the panel dirty on every devotion-state
; change and flushing it from OnUpdate once the bridge is available.
Function RequestPanelRefresh()
    _panelDirty = True
EndFunction

Bool Function PushDevotionPanel()
    if !PDV_PrismaBridge.IsAvailable()
        return False
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    String originLabel = "Unknown"
    if originRace >= 0
        originLabel = GetOriginRaceLabel(originRace)
    endIf

    String titleText = "Devotion"
    String symbolName = "journal"
    Float piety = 0.0
    Float pietyToday = 0.0
    Int tierValue = TIER_NONE
    String tierLabelOverride = ""

    if _activeDeity
        titleText = _activeDeity.DeityName
        symbolName = GetPrismaSymbolForDeity(_activeDeity)
        piety = GetPiety(_activeDeity)
        pietyToday = GetPietyToday(_activeDeity)
        tierValue = GetTier(_activeDeity)
    else
        ; Quasi-patron: surface the race's substrate/state-track as panel identity.
        ; Piety stays 0 for substrate races — there is no single scoring float.
        ; The tierLabelOverride carries the meaningful state (e.g. "Hist: Strained").
        titleText = GetPanelQuasiPatronName(originRace)
        symbolName = GetPanelQuasiPatronSymbol(originRace)
        tierLabelOverride = GetPanelQuasiPatronTierLabel(originRace)
        if PDV_GLO_ActivePiety
            piety = PDV_GLO_ActivePiety.GetValue()
        endIf
        if PDV_GLO_ActiveTier
            tierValue = PDV_GLO_ActiveTier.GetValueInt()
        endIf
    endIf

    String tierLabel = tierLabelOverride
    if tierLabel == ""
        tierLabel = GetCurrentStandingLabel()
    endIf

    String j = "{\"title\":\"" + JsonSafeString(titleText) + "\""
    j = j + ",\"status\":\"Live\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    j = j + ",\"patron\":\"" + JsonSafeString(GetPlayerMcmPatronLine()) + "\""
    j = j + ",\"patronNote\":\"" + JsonSafeString(GetPanelPatronNote()) + "\""
    j = j + ",\"summary\":\"" + JsonSafeString(GetSurveyDevotionText()) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + JsonSafeString(tierLabel) + "\""
    j = j + ",\"piety\":" + piety
    j = j + ",\"pietyToday\":" + pietyToday
    j = j + ",\"todayMood\":\"" + JsonSafeString(GetPanelTodayMood(pietyToday)) + "\""
    j = j + ",\"driftLabel\":\"" + JsonSafeString(GetPanelDriftLabel()) + "\""
    j = j + ",\"originRace\":\"" + JsonSafeString(originLabel) + "\""
    j = j + ",\"patronState\":\"" + JsonSafeString(GetPatronStateLabel()) + "\""
    j = j + ",\"acts\":[" + GetPanelActsJson() + "]"
    j = j + ",\"rites\":[" + GetPanelRitesJson() + "]"
    j = j + ",\"relations\":[" + GetPanelRelationsJson() + "]"
    j = j + ",\"debug\":" + GetPanelDebugJson()
    j = j + "}"

    return PDV_PrismaBridge.SendJson(j)
EndFunction

String Function GetPanelPatronNote()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose a path through play, prayer, and consequence."
    endIf
    if IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    ; GetPlayerMcmModeLine handles all races — active patron, substrate, and
    ; state-track modes — so it works for both deity and quasi-patron cases.
    return GetPlayerMcmModeLine()
EndFunction

String Function GetPanelTodayMood(Float pietyToday)
    if pietyToday > 0.5
        return "The day's acts lean toward reverence."
    elseIf pietyToday < -0.5
        return "The day's acts have strained the bond."
    endIf
    return "No devotional acts have settled yet."
EndFunction

String Function GetPanelDriftLabel()
    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        return "Thinning"
    endIf
    if GetPatronState() == PATRON_STATE_ACTIVE
        return "Steady"
    endIf
    return "Quiet"
EndFunction

String Function GetPanelActsJson()
    String items = ""
    if _activeDeity
        Float today = GetPietyToday(_activeDeity)
        if today != 0.0
            String tone = "good"
            if today < 0.0
                tone = "warning"
            endIf
            items = AppendJsonItem(items, PanelEventObject("favor", _activeDeity, "", "Today's devotion is being weighed.", "" + today, tone, "", ""))
        endIf
    endIf

    if IsFavorActive()
        Int lane = GetActiveFavorLane()
        Int fam = GetActiveFavorFamily()
        items = AppendJsonItem(items, PanelPlainObject("journal", "good", GetContextualFavorLaneLabel(lane), GetContextualFavorFamilyLabel(lane, fam)))
    endIf

    ; Quasi-patron: show current substrate/state-track mode as the headline act
    ; when there is no scoring patron — gives the player their mode at a glance.
    if !_activeDeity
        Int originRace = GetPlayerOriginRaceIndex()
        String quasiLabel = GetPanelQuasiPatronTierLabel(originRace)
        if quasiLabel != ""
            items = AppendJsonItem(items, PanelPlainObject(GetPanelQuasiPatronSymbol(originRace), "neutral", "Current practice", quasiLabel))
        endIf
    endIf

    return items
EndFunction

String Function GetPanelRitesJson()
    String items = PanelPlainObject("journal", "", "Survey your devotion", "Call on the Survey Devotion power to read where your path stands.")
    if _activeDeity
        items = AppendJsonItem(items, PanelPlainObject(GetPrismaSymbolForDeity(_activeDeity), "", "Keep " + _activeDeity.DeityName + "'s rites", "Act in keeping with " + _activeDeity.DeityName + " to deepen this bond."))
    else
        ; Quasi-patron: tell the player what kind of acts build their path.
        Int originRace = GetPlayerOriginRaceIndex()
        String patronName = GetPanelQuasiPatronName(originRace)
        String patronSymbol = GetPanelQuasiPatronSymbol(originRace)
        if patronName != "Devotion"
            items = AppendJsonItem(items, PanelPlainObject(patronSymbol, "", "Deepen your practice", "Continue acting in keeping with " + patronName + " to build this path."))
        endIf
    endIf
    return items
EndFunction

String Function GetPanelRelationsJson()
    String items = ""
    if _activeDeity
        Int stance = _activeDeity.GetStanceForPlayer()
        String stanceText = ""
        String stanceTone = ""
        if stance == _activeDeity.STANCE_NATIVE
            stanceText = "Native practice: " + _activeDeity.DeityName + "'s rites answer you clearly."
            stanceTone = "good"
        elseIf stance == _activeDeity.STANCE_FOREIGN
            stanceText = "Foreign devotion: " + _activeDeity.DeityName + " answers, but as an outsider's god."
            stanceTone = "neutral"
        elseIf stance == _activeDeity.STANCE_TABOO
            stanceText = "Forbidden devotion: " + _activeDeity.DeityName + " is taboo to your people."
            stanceTone = "warning"
        elseIf stance == _activeDeity.STANCE_HOSTILE
            stanceText = "Hostile devotion: " + _activeDeity.DeityName + " stands against your people."
            stanceTone = "warning"
        endIf
        if stanceText != ""
            items = AppendJsonItem(items, PanelPlainObject("", stanceTone, "", stanceText))
        endIf

        Quest[] rivals = _activeDeity.RivalDeities
        if rivals && rivals.Length > 0
            PDV_DeityBase rivalDeity = rivals[0] as PDV_DeityBase
            if rivalDeity
                items = AppendJsonItem(items, PanelEventObject("rivalry", _activeDeity, "", "", "", "", "", rivalDeity.DeityName))
            endIf
        endIf
    endIf

    if IsBroadWorshipActive()
        items = AppendJsonItem(items, PanelPlainObject("", "neutral", "", "You keep the broad rites of your people, with no single patron named."))
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        items = AppendJsonItem(items, PanelPlainObject("", "warning", "", "Some of your rites have grown quiet and need attention."))
    endIf

    return items
EndFunction

String Function GetPanelDebugJson()
    String j = "{\"Favor\":\"" + JsonSafeString(GetPlayerMcmFavorLine()) + "\""
    j = j + ",\"Neglect\":\"" + JsonSafeString(GetPlayerMcmNeglectLine()) + "\""
    j = j + ",\"Curse\":\"" + JsonSafeString(GetPlayerCursePublicLabel()) + "\""
    j = j + "}"
    return j
EndFunction

; --- Quasi-patron helpers ---
; For races whose piety is tracked via substrate/state-track rather than a
; scoring PDV_DeityBase patron, these derive panel identity fields so the
; panel is never blank for non-deity races.

String Function GetPanelQuasiPatronName(Int originRace)
    if originRace == ORIGIN_ARGONIAN
        return "The Hist"
    elseIf originRace == ORIGIN_ORC
        return "Malacath"
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = GetKhajiitFocusedEmphasis()
        if focus > 0
            return GetKhajiitFocusLabel(focus)
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_DUNMER
        return "House Ancestors"
    elseIf originRace == ORIGIN_REDGUARD
        return "Yokudan Path"
    elseIf originRace == ORIGIN_BOSMER
        return "Path Unsettled"
    elseIf originRace == ORIGIN_IMPERIAL
        return "Nine Divines"
    elseIf originRace == ORIGIN_BRETON
        return "Breton Tradition"
    elseIf originRace == ORIGIN_NORD
        return "Nord Worship"
    elseIf originRace == ORIGIN_ALTMER
        return "Auri-El Foundation"
    endIf
    return "Devotion"
EndFunction

String Function GetPanelQuasiPatronSymbol(Int originRace)
    if originRace == ORIGIN_ARGONIAN
        return "hist"
    elseIf originRace == ORIGIN_ORC
        return "malacath"
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = GetKhajiitFocusedEmphasis()
        if focus > 0
            return GetKhajiitFocusSymbol(focus)
        endIf
        return "lunar"
    elseIf originRace == ORIGIN_DUNMER
        return "ancestor"
    elseIf originRace == ORIGIN_REDGUARD
        return "journal"
    elseIf originRace == ORIGIN_BOSMER
        return "yffre"
    elseIf originRace == ORIGIN_IMPERIAL
        return "akatosh"
    elseIf originRace == ORIGIN_BRETON
        return "journal"
    elseIf originRace == ORIGIN_NORD
        return "kyne"
    elseIf originRace == ORIGIN_ALTMER
        return "auri-el"
    endIf
    return "journal"
EndFunction

; Returns a short state label to use as tierLabel when there is no scoring patron.
; Uses the same label functions as MCM/Survey so the panel matches those surfaces.
String Function GetPanelQuasiPatronTierLabel(Int originRace)
    if originRace == ORIGIN_ARGONIAN
        return "Hist: " + GetArgonianHistPostureLabel()
    elseIf originRace == ORIGIN_ORC
        return GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = GetKhajiitFocusedEmphasis()
        if focus > 0
            return "Focused: " + GetKhajiitFocusLabel(focus)
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_DUNMER
        return "Ancestor layer: " + GetDunmerAncestorLayerLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return GetRedguardSectLabel()
    elseIf originRace == ORIGIN_BOSMER
        return GetBosmerPathLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_BRETON
        return GetBretonTraditionLabel()
    elseIf originRace == ORIGIN_NORD
        return GetNordDevotionModeLabel()
    elseIf originRace == ORIGIN_ALTMER
        return GetAltmerCrisisStateLabel()
    endIf
    return ""
EndFunction

String Function PanelEventObject(String eventName, PDV_DeityBase deity, String context, String itemText, String amountText, String tone, String tierLabel, String rival)
    String deityName = ""
    String symbolName = "journal"
    if deity
        deityName = deity.DeityName
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    String j = "{\"event\":\"" + JsonSafeString(eventName) + "\""
    if deityName != ""
        j = j + ",\"deity\":\"" + JsonSafeString(deityName) + "\""
    endIf
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if itemText != ""
        j = j + ",\"text\":\"" + JsonSafeString(itemText) + "\""
    endIf
    if amountText != ""
        j = j + ",\"amount\":" + amountText
    endIf
    if tone != ""
        j = j + ",\"tone\":\"" + JsonSafeString(tone) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + JsonSafeString(rival) + "\""
    endIf
    j = j + "}"
    return j
EndFunction

String Function PanelPlainObject(String symbolName, String tone, String listTitle, String listText)
    String j = "{\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if tone != ""
        j = j + ",\"tone\":\"" + JsonSafeString(tone) + "\""
    endIf
    if listTitle != ""
        j = j + ",\"listTitle\":\"" + JsonSafeString(listTitle) + "\""
    endIf
    j = j + ",\"listText\":\"" + JsonSafeString(listText) + "\""
    j = j + "}"
    return j
EndFunction

String Function AppendJsonItem(String accum, String item)
    if accum == ""
        return item
    endIf
    return accum + "," + item
EndFunction

Function ShowP2BookNotice(String reason, String titleText, String messageText)
    if !IsP2BookNoticeReason(reason)
        return
    endIf

    ; P2 book proof uses the vanilla notification lane until Prisma can own
    ; input without opening or trapping the full panel.
    Debug.Notification(titleText + ": " + messageText)
EndFunction

Bool Function IsP2BookNoticeReason(String reason)
    return reason == "eventbus_122_po3_book_breton_hidden_art" || reason == "eventbus_130_po3_book_dunmer_azura" || reason == "eventbus_130_po3_book_dunmer_boethiah" || reason == "eventbus_141_po3_book_imperial_public_talos" || reason == "eventbus_150_po3_book_nord_old_ways" || reason == "eventbus_152_po3_book_nord_hircine_arkay" || reason == "eventbus_p2_altmer_auriel_po3_book_altmer_auriel" || reason == "eventbus_p2_altmer_magnus_po3_book_altmer_magnus" || reason == "eventbus_p2_altmer_xarxes_po3_book_altmer_xarxes" || reason == "eventbus_p2_argonian_hist_po3_book_argonian_hist" || reason == "eventbus_p2_khajiit_lunar_po3_book_khajiit_lunar" || reason == "eventbus_p2_orc_malacath_po3_book_orc_malacath" || reason == "eventbus_p2_redguard_spine_po3_book_redguard_spine"
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
    RequestPanelRefresh()
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
    RequestPanelRefresh()
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

Function HandleBosmerOldContractProperHunt(String reason)
    if RecordBosmerFavorSignal("OldContract.ProperHunt", BOSMER_PATH_OLD_CONTRACT, reason)
        HandleBosmerPactPositiveSignal(reason + "_proper_hunt")
    endIf
EndFunction

Function HandleBosmerOldContractForestKept(String reason)
    if RecordBosmerFavorSignal("OldContract.ForestKept", BOSMER_PATH_OLD_CONTRACT, reason)
        HandleBosmerPactPositiveSignal(reason + "_forest_kept")
    endIf
EndFunction

Function HandleBosmerLivingStoryCommunityKept(String reason)
    if RecordBosmerFavorSignal("LivingStory.CommunityKept", BOSMER_PATH_LIVING_STORY, reason)
        HandleBosmerLivingStorySignal(reason + "_community_kept")
    endIf
EndFunction

Function HandleBosmerLivingStoryNatureSite(String reason)
    if RecordBosmerFavorSignal("LivingStory.NatureSite", BOSMER_PATH_LIVING_STORY, reason)
        HandleBosmerLivingStorySignal(reason + "_nature_site")
    endIf
EndFunction

Function HandleBosmerExchangeDebtSettled(String reason)
    if RecordBosmerFavorSignal("Exchange.DebtSettled", BOSMER_PATH_EXCHANGE, reason)
        HandleBosmerExchangeSignal(reason + "_debt_settled")
    endIf
EndFunction

Function HandleBosmerExchangeProportionateVengeance(String reason)
    if RecordBosmerFavorSignal("Exchange.ProportionateVengeance", BOSMER_PATH_EXCHANGE, reason)
        HandleBosmerExchangeSignal(reason + "_proportionate_vengeance")
    endIf
EndFunction

Function HandleBosmerBanditRoadRoadLife(String reason)
    if RecordBosmerFavorSignal("BanditRoad.RoadLife", BOSMER_PATH_BANDIT_ROAD, reason)
        HandleBosmerBanditRoadSignal(reason + "_road_life")
    endIf
EndFunction

Function HandleBosmerBanditRoadReversal(String reason)
    if !CanRecordBosmerMajorFavor("BanditRoad.Reversal", 7.0, reason)
        return
    endIf

    if RecordBosmerFavorSignal("BanditRoad.Reversal", BOSMER_PATH_BANDIT_ROAD, reason)
        HandleBosmerBanditRoadSignal(reason + "_reversal")
    endIf
EndFunction

Bool Function RecordBosmerFavorSignal(String favorKey, Int pathState, String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return False
    endIf

    String baseKey = "PDV.Bosmer.Favor." + favorKey
    StorageUtil.AdjustIntValue(None, baseKey + ".Count", 1)
    StorageUtil.SetIntValue(None, baseKey + ".Path", pathState)
    StorageUtil.SetFloatValue(None, baseKey + ".LastTime", Utility.GetCurrentGameTime())
    Trace(2, "Bosmer favor " + favorKey + " recorded for path " + pathState + " (" + reason + ")")
    return True
EndFunction

Bool Function CanRecordBosmerMajorFavor(String favorKey, Float cooldownDays, String reason)
    if !IsBosmerOrigin()
        return False
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    String baseKey = "PDV.Bosmer.Favor." + favorKey
    Float lastTime = StorageUtil.GetFloatValue(None, baseKey + ".LastMajorTime")
    if lastTime > 0.0 && nowTime - lastTime < cooldownDays
        StorageUtil.AdjustIntValue(None, baseKey + ".RejectCount", 1)
        Trace(2, "Bosmer major favor " + favorKey + " rejected by cooldown (" + reason + ")")
        return False
    endIf

    StorageUtil.SetFloatValue(None, baseKey + ".LastMajorTime", nowTime)
    return True
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
    if !IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return
    endIf

    if phaseIndex < 1 || phaseIndex > 8
        phaseIndex = GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMoonObservance")
    PDV_KhajiitLunarSubstrate.ObserveMoonPhaseScaled(phaseIndex, multiplier, reason)
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_AZURAH, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    StorageUtil.AdjustIntValue(None, "PDV.Khajiit.LunarSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    ShowP2BookNotice(reason, "Lunar source noted", "This reading gives the Lunar Lattice a visible source.")
    Trace(2, "Khajiit moon observance routed for phase " + phaseIndex + " with multiplier " + multiplier)
EndFunction

Function HandleKhajiitRoadHome(String reason)
    HandleKhajiitRoadHomeAnchor(0, reason)
EndFunction

Function HandleKhajiitRoadHomeAnchor(Int anchorId, String reason)
    if !IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return
    endIf

    if anchorId > 0
        Int lastAnchor = StorageUtil.GetIntValue(None, "PDV.Khajiit.RoadHome.LastAnchor")
        if lastAnchor == anchorId
            StorageUtil.AdjustIntValue(None, "PDV.Khajiit.RoadHome.RepeatRejectCount", 1)
            Trace(2, "Khajiit road-home repeat anchor rejected: " + anchorId)
            return
        endIf

        StorageUtil.SetIntValue(None, "PDV.Khajiit.RoadHome.LastAnchor", anchorId)
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitRoadHome")
    PDV_KhajiitLunarSubstrate.RecordRoadHomeCadenceScaled(multiplier, reason)
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_KHENARTHI, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier + " anchor " + anchorId)
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_BAANDAR, "PDV.Signal.KhajiitBaanDarRoadTrick", "Baan Dar road trick", reason)
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", "Rajhin elegant theft", reason)
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh dragon order", reason)
EndFunction

Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier(keyPrefix)
    StorageUtil.AdjustIntValue(None, keyPrefix + ".CountAll", 1)
    AdjustKhajiitFocusedEmphasis(focusValue, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    Trace(2, "Khajiit " + label + " routed with multiplier " + multiplier)
EndFunction

Bool Function IsKhajiitOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
EndFunction

Function HandleArgonianHistMaintenance(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianHistMaintenance")
    PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistSourceReason", reason)
    ShowP2BookNotice(reason, "Hist memory noted", "This reading gives the Hist memory a visible source.")
    Trace(2, "Argonian Hist maintenance routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianPeopleSupport(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianPeopleSupport")
    PDV_ArgonianHistSubstrate.RecordPeopleSupportScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Trace(2, "Argonian People support routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianBedOfChoiceReturn(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianBedOfChoice")
    PDV_ArgonianHistSubstrate.RecordBedOfChoiceReturnScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Trace(2, "Argonian bed-of-choice return routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianVoidSignal(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianVoidSignal")
    PDV_ArgonianHistSubstrate.RecordVoidSignalScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Trace(2, "Argonian Void signal routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshArgonianHist()
    if !PDV_ArgonianHistSubstrate
        return
    endIf

    Bool curseActive = False
    if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() != 0
        curseActive = True
    endIf

    PDV_ArgonianHistSubstrate.ProcessHistDistanceDawn(curseActive, "dawn")
    RefreshArgonianHistPosture("dawn")
EndFunction

Function RefreshArgonianHistPosture(String reason)
    if !PDV_ArgonianHistSubstrate
        return
    endIf

    Int curseState = 0
    if PDV_CurseStateService
        curseState = PDV_CurseStateService.GetCurseState()
    endIf

    Int oldPosture = 0
    if PDV_ArgonianHistPostureTrack
        oldPosture = PDV_ArgonianHistPostureTrack.GetCurrentState()
    endIf

    Bool dominationPressure = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure") == 1
    PDV_ArgonianHistSubstrate.RefreshHistPosture(curseState, dominationPressure, reason)
    if PDV_ArgonianHistPostureTrack
        PDV_ArgonianHistPostureTrack.SetState(PDV_ArgonianHistSubstrate.GetHistPosture(), reason)
        if PDV_ArgonianHistPostureTrack.GetCurrentState() != oldPosture
            SendPrismaShiftToast(GetArgonianHistPostureLabel(), "", "hist")
            RequestPanelRefresh()
        endIf
    endIf
EndFunction

Function HandleOrcStrongholdForge(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdForge")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    Trace(2, "Orc Stronghold forge routed with multiplier " + multiplier)
EndFunction

Function HandleOrcCityDignity(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCityDignity")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_CITY, multiplier, reason)
    Trace(2, "Orc City dignity routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLegionService(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcLegionService")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_LEGION_EXILE, multiplier, reason)
    Trace(2, "Orc Legion or exile service routed with multiplier " + multiplier)
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcSelfMadeCommunity")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_CITY, multiplier, reason)
    Trace(2, "Orc self-made community routed with multiplier " + multiplier)
EndFunction

Function HandleOrcMalacathConduct(Int modeValue, String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    EnsureOrcLifeModeInitialized()
    if modeValue < ORC_LIFE_MODE_CITY || modeValue > ORC_LIFE_MODE_LEGION_EXILE
        modeValue = PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcMalacathConduct")
    RecordOrcLifeModeSignal(modeValue, multiplier, reason)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.MalacathConduct", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.MalacathSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastMalacathSourceReason", reason)
    ShowP2BookNotice(reason, "Malacath code noted", "This reading gives the Orc code a visible source.")
    Trace(2, "Orc Malacath conduct routed with multiplier " + multiplier)
EndFunction

Function RecordOrcLifeModeSignal(Int modeValue, Float multiplier, String reason)
    if !PDV_OrcLifeModeTrack
        return
    endIf

    if modeValue < ORC_LIFE_MODE_CITY || modeValue > ORC_LIFE_MODE_LEGION_EXILE
        return
    endIf

    EnsureOrcLifeModeInitialized()
    PDV_OrcLifeModeTrack.RecordEvidenceDay(modeValue, reason)
    StorageUtil.AdjustFloatValue(None, GetOrcLifeModeWeightKey(modeValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastLifeModeSignal", modeValue)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastLifeModeReason", reason)

    if multiplier > 0.0 && PDV_OrcLifeModeTrack.GetCurrentState() != modeValue
        PDV_OrcLifeModeTrack.SetState(modeValue, reason)
        SendPrismaShiftToast(GetOrcLifeModeLabel(), "", "malacath")
        RequestPanelRefresh()
    endIf
EndFunction

Function EnsureOrcLifeModeInitialized()
    if !PDV_OrcLifeModeTrack
        return
    endIf

    if IsOrcOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if PDV_OrcLifeModeTrack.GetCurrentState() < ORC_LIFE_MODE_CITY
        PDV_OrcLifeModeTrack.SetState(ORC_LIFE_MODE_CITY, "orc_default_city")
    endIf
EndFunction

Bool Function IsOrcOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_ORC
EndFunction

Float Function GetOrcLifeModeGainMultiplier(PDV_DeityBase deity)
    if !deity || !IsOrcOrigin()
        return 1.0
    endIf

    if deity.DeityName != "Malacath"
        return 1.0
    endIf

    EnsureOrcLifeModeInitialized()
    if !PDV_OrcLifeModeTrack
        return 1.0
    endIf

    Int modeValue = PDV_OrcLifeModeTrack.GetCurrentState()
    if modeValue == ORC_LIFE_MODE_STRONGHOLD
        return ORC_RATE_MULT_STRONGHOLD
    elseIf modeValue == ORC_LIFE_MODE_LEGION_EXILE
        return ORC_RATE_MULT_LEGIONEXILE
    endIf

    return ORC_RATE_MULT_CITY
EndFunction

String Function GetOrcLifeModeWeightKey(Int modeValue)
    if modeValue == ORC_LIFE_MODE_STRONGHOLD
        return "PDV.Orc.LifeMode.Stronghold"
    elseIf modeValue == ORC_LIFE_MODE_LEGION_EXILE
        return "PDV.Orc.LifeMode.LegionExile"
    endIf

    return "PDV.Orc.LifeMode.City"
EndFunction

String Function GetOrcLifeModeLabel()
    if !PDV_OrcLifeModeTrack
        return "Life mode missing"
    endIf

    EnsureOrcLifeModeInitialized()
    return PDV_OrcLifeModeTrack.GetStateLabel()
EndFunction

Function HandleRedguardCrownTombRespect(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardCrownTombRespect")
    RecordRedguardSectSignal(REDGUARD_SECT_CROWN, multiplier, reason)
    Trace(2, "Redguard Crown tomb respect routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")
    RecordRedguardSectSignal(REDGUARD_SECT_FOREBEAR, multiplier, reason)
    Trace(2, "Redguard Forebear road passage routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")
    RecordRedguardSectSignal(REDGUARD_SECT_ASHABAH, multiplier, reason)
    Trace(2, "Redguard AshAbah death duty routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardFarShoresToken(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardFarShoresToken")
    EnsureRedguardSectInitialized()
    Int currentSect = PDV_RedguardSectTrack.GetCurrentState()
    PDV_RedguardSectTrack.RecordEvidenceDay(currentSect, reason)
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.FarShoresToken", multiplier)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)
    Trace(2, "Redguard Far Shores token routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAncestorSpine(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAncestorSpine")
    EnsureRedguardSectInitialized()
    Int currentSect = PDV_RedguardSectTrack.GetCurrentState()
    RecordRedguardSectSignal(currentSect, multiplier, reason)
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastAncestorSpineSourceReason", reason)
    ShowP2BookNotice(reason, "Ancestor spine noted", "This reading gives the Yokudan ancestor spine a visible source.")
    Trace(2, "Redguard ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardSectSignal(Int sectValue, Float multiplier, String reason)
    if !PDV_RedguardSectTrack
        return
    endIf

    if sectValue < REDGUARD_SECT_CROWN || sectValue > REDGUARD_SECT_ASHABAH
        return
    endIf

    EnsureRedguardSectInitialized()
    PDV_RedguardSectTrack.RecordEvidenceDay(sectValue, reason)
    StorageUtil.AdjustFloatValue(None, GetRedguardSectWeightKey(sectValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Redguard.LastSectSignal", sectValue)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)

    if multiplier > 0.0 && PDV_RedguardSectTrack.GetCurrentState() != sectValue
        PDV_RedguardSectTrack.SetState(sectValue, reason)
        SendPrismaShiftToast(GetRedguardSectLabel(), "", "journal")
        RequestPanelRefresh()
    endIf
EndFunction

Function EnsureRedguardSectInitialized()
    if !PDV_RedguardSectTrack
        return
    endIf

    if IsRedguardOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if PDV_RedguardSectTrack.GetCurrentState() < REDGUARD_SECT_CROWN
        PDV_RedguardSectTrack.SetState(REDGUARD_SECT_FOREBEAR, "redguard_default_forebear")
    endIf
EndFunction

Bool Function IsRedguardOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
EndFunction

String Function GetRedguardSectWeightKey(Int sectValue)
    if sectValue == REDGUARD_SECT_CROWN
        return "PDV.Redguard.Sect.Crown"
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.Sect.AshAbah"
    endIf

    return "PDV.Redguard.Sect.Forebear"
EndFunction

String Function GetRedguardSectLabel()
    if !PDV_RedguardSectTrack
        return "Sect missing"
    endIf

    EnsureRedguardSectInitialized()
    return PDV_RedguardSectTrack.GetStateLabel()
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
        SendPrismaShiftToast(GetKhajiitFocusLabel(focusValue), "", GetKhajiitFocusSymbol(focusValue))
        RequestPanelRefresh()
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
        Float stigmaBefore = PDV_HircinePath.GetStigma()
        PDV_HircinePath.RecordHuntRiteScaled(multiplier, reason)
        if multiplier > 0.0
            SendPrismaDaedricToast("Hircine", "boon", "", "hircine")
            MaybeEmitHircineStigmaPrice(stigmaBefore, PDV_HircinePath.GetStigma())
            RequestPanelRefresh()
        endIf
        Trace(2, "Hircine hunt rite routed with multiplier " + multiplier)
    endIf
EndFunction

; Surface the Hircine "price" only when stigma crosses a meaningful threshold, so the
; cost lands on a beat the player can feel rather than on every single hunt rite.
; Thresholds mirror GetDaedricStigmaGainMultiplier (3.0 stirring, 6.0 heavy).
Function MaybeEmitHircineStigmaPrice(Float stigmaBefore, Float stigmaAfter)
    if stigmaBefore < 6.0 && stigmaAfter >= 6.0
        SendPrismaDaedricToast("Hircine", "price", "The hunt's mark has grown heavy.", "hircine")
    elseIf stigmaBefore < 3.0 && stigmaAfter >= 3.0
        SendPrismaDaedricToast("Hircine", "price", "The hunt's stigma is beginning to stir.", "hircine")
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

Bool Function IsAltmerOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
EndFunction

Bool Function IsAltmerFavorSuppressedByCurse()
    if !IsAltmerOrigin()
        return False
    endIf

    if PDV_CurseStateService && (PDV_CurseStateService.IsWerewolf() || PDV_CurseStateService.IsVampire())
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Curse.Altmer.ExilePressure") == 1
EndFunction

Function HandleAltmerLorkhanPressure(Int pressureTier, String sourceId)
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerRejectedLorkhanSurface(sourceId)
        RecordAltmerRejectedSurface(sourceId, "lorkhan_surface_rejected")
        Trace(2, "Altmer Lorkhan pressure rejected for source " + sourceId)
        return
    endIf

    if pressureTier < ALTMER_LORKHAN_PRESSURE_DIRECT
        pressureTier = ALTMER_LORKHAN_PRESSURE_DIRECT
    elseIf pressureTier > ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
        pressureTier = ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastLorkhanPressureDay", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(None, "PDV.Altmer.LastLorkhanPressureTier", pressureTier)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastLorkhanPressureSource", sourceId)
    StorageUtil.SetIntValue(None, "PDV.Altmer.LorkhanPressureCount", StorageUtil.GetIntValue(None, "PDV.Altmer.LorkhanPressureCount") + 1)

    if pressureTier >= ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION && GetAltmerCrisisState() == ALTMER_CRISIS_NONE
        SetAltmerCrisisState(ALTMER_CRISIS_DISSONANT, "lorkhan_pressure_" + sourceId)
    endIf

    Trace(2, "Altmer Lorkhan pressure routed: tier " + pressureTier + " source " + sourceId)
EndFunction

Function HandleAltmerCrisisSource(Int crisisSource, String sourceId)
    if !IsAltmerOrigin()
        return
    endIf

    if crisisSource < ALTMER_CRISIS_SOURCE_DRAGONBORN || crisisSource > ALTMER_CRISIS_SOURCE_COMPANIONS
        RecordAltmerRejectedSurface(sourceId, "unknown_crisis_source")
        return
    endIf

    String seenKey = "PDV.Altmer.CrisisSeen." + crisisSource
    if StorageUtil.GetIntValue(None, seenKey) == 1
        RecordAltmerRejectedSurface(sourceId, "repeat_crisis_source")
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisSource", crisisSource)
    StorageUtil.SetStringValue(None, "PDV.Altmer.CrisisSourceId", sourceId)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisStartedAt", Utility.GetCurrentGameTime())

    if crisisSource == ALTMER_CRISIS_SOURCE_DRAGONBORN || crisisSource == ALTMER_CRISIS_SOURCE_SOVNGARDE
        SetAltmerCrisisState(ALTMER_CRISIS_DISSONANT, sourceId)
    elseIf crisisSource == ALTMER_CRISIS_SOURCE_TALOS || crisisSource == ALTMER_CRISIS_SOURCE_COMPANIONS
        SetAltmerCrisisState(ALTMER_CRISIS_QUESTIONING, sourceId)
    endIf

    Trace(1, "Altmer crisis source accepted: " + GetAltmerCrisisSourceLabel(crisisSource) + " (" + sourceId + ")")
EndFunction

Function ResolveAltmerCrisis(Bool reassertOrthodoxy, String reason)
    if !IsAltmerOrigin()
        return
    endIf

    if reassertOrthodoxy
        SetAltmerCrisisState(ALTMER_CRISIS_REASSERTING, reason)
    else
        SetAltmerCrisisState(ALTMER_CRISIS_SCARRED_RESOLVED, reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisResolvedAt", Utility.GetCurrentGameTime())
EndFunction

Function HandleAltmerDawnSteadiness(String reason)
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        RecordAltmerRejectedSurface(reason, "curse_suppressed_altmer_favor")
        ClearActiveFavor("altmer_curse")
        return
    endIf

    RecordAltmerSourceFavor(FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    TryActivateContextualFavor(FAVOR_LANE_ALTMER, FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    if reason == "eventbus_p2_altmer_auriel_po3_book_altmer_auriel"
        ShowP2BookNotice(reason, "Auri-El noted", "This reading gives Altmer dawn steadiness a visible source.")
    elseIf reason == "eventbus_p2_altmer_magnus_po3_book_altmer_magnus"
        ShowP2BookNotice(reason, "Magnus noted", "This reading gives Altmer dawn steadiness a visible source.")
    endIf
EndFunction

Function HandleAltmerOrthodoxCostlyEnforcement(String reason)
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        RecordAltmerRejectedSurface(reason, "curse_suppressed_altmer_favor")
        ClearActiveFavor("altmer_curse")
        return
    endIf

    RecordAltmerSourceFavor(FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    TryActivateContextualFavor(FAVOR_LANE_ALTMER, FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    ShowP2BookNotice(reason, "Xarxes noted", "This reading gives Altmer orthodoxy a visible source.")
EndFunction

Function RecordAltmerSourceFavor(Int familyValue, String reason)
    if !IsValidAltmerSourceFavorFamily(familyValue)
        RecordAltmerRejectedSurface(reason, "unknown_altmer_favor_family")
        return
    endIf

    String countKey = "PDV.Altmer.Favor." + GetAltmerFavorFamilyKey(familyValue) + ".Count"
    StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.LastFamily", familyValue)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Favor.LastReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Favor.LastSurfacing", GetFavorSurfacingLabel(FAVOR_LANE_ALTMER, familyValue))
    StorageUtil.SetFloatValue(None, "PDV.Altmer.Favor.LastGameTime", Utility.GetCurrentGameTime())

    Trace(2, "Altmer source favor recorded: " + GetContextualFavorFamilyLabel(FAVOR_LANE_ALTMER, familyValue) + " (" + reason + ")")
EndFunction

Bool Function IsValidAltmerSourceFavorFamily(Int familyValue)
    return familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS || familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
EndFunction

String Function GetAltmerFavorFamilyKey(Int familyValue)
    if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
        return "DawnSteadiness"
    elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
        return "OrthodoxCost"
    endIf

    return "Unknown"
EndFunction

Bool Function IsAltmerRejectedLorkhanSurface(String sourceId)
    return sourceId == "ordinary_travel" || sourceId == "ordinary_friendship" || sourceId == "generic_spellcasting" || sourceId == "generic_helping" || sourceId == "generic_combat" || sourceId == "generic_college_membership" || sourceId == "generic_anti_thalmor_violence" || sourceId == "dragonborn_repeat" || sourceId == "vampire_power_route"
EndFunction

Function RecordAltmerRejectedSurface(String sourceId, String reason)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastRejectedSurface", sourceId)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastRejectedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastRejectedAt", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(None, "PDV.Altmer.RejectedSurfaceCount", StorageUtil.GetIntValue(None, "PDV.Altmer.RejectedSurfaceCount") + 1)
EndFunction

Bool Function DebugAssertAltmerRejectedSurface(String sourceId)
    return IsAltmerRejectedLorkhanSurface(sourceId)
EndFunction

Int Function GetAltmerCrisisState()
    if PDV_AltmerCrisisTrack
        return PDV_AltmerCrisisTrack.GetCurrentState()
    endIf

    Int stateValue = StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisState")
    if stateValue < ALTMER_CRISIS_NONE || stateValue > ALTMER_CRISIS_SCARRED_RESOLVED
        return ALTMER_CRISIS_NONE
    endIf

    return stateValue
EndFunction

Function SetAltmerCrisisState(Int stateValue, String reason)
    if stateValue < ALTMER_CRISIS_NONE
        stateValue = ALTMER_CRISIS_NONE
    elseIf stateValue > ALTMER_CRISIS_SCARRED_RESOLVED
        stateValue = ALTMER_CRISIS_SCARRED_RESOLVED
    endIf

    Int oldState = GetAltmerCrisisState()
    StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisState", stateValue)
    StorageUtil.SetStringValue(None, "PDV.Altmer.CrisisReason", reason)
    if PDV_AltmerCrisisTrack && PDV_AltmerCrisisTrack.GetCurrentState() != stateValue
        PDV_AltmerCrisisTrack.SetState(stateValue, reason)
    endIf
    if oldState != stateValue
        Trace(1, "Altmer crisis state " + GetAltmerCrisisStateLabelForValue(oldState) + " -> " + GetAltmerCrisisStateLabelForValue(stateValue) + " (" + reason + ")")
    endIf
EndFunction

String Function GetAltmerCrisisStateLabel()
    return GetAltmerCrisisStateLabelForValue(GetAltmerCrisisState())
EndFunction

String Function GetAltmerCrisisStateLabelForValue(Int stateValue)
    if stateValue == ALTMER_CRISIS_DISSONANT
        return "Dissonant"
    elseIf stateValue == ALTMER_CRISIS_QUESTIONING
        return "Questioning"
    elseIf stateValue == ALTMER_CRISIS_REASSERTING
        return "Reasserting"
    elseIf stateValue == ALTMER_CRISIS_SCARRED_RESOLVED
        return "Scarred resolved"
    endIf

    return "None"
EndFunction

String Function GetAltmerCrisisSourceLabel(Int sourceValue)
    if sourceValue == ALTMER_CRISIS_SOURCE_DRAGONBORN
        return "Dragonborn identity"
    elseIf sourceValue == ALTMER_CRISIS_SOURCE_SOVNGARDE
        return "Sovngarde witness"
    elseIf sourceValue == ALTMER_CRISIS_SOURCE_TALOS
        return "Talos contradiction"
    elseIf sourceValue == ALTMER_CRISIS_SOURCE_COMPANIONS
        return "Companions contradiction"
    endIf

    return "Unknown"
EndFunction

String Function GetAltmerSummary()
    return "crisis=" + GetAltmerCrisisStateLabel() + ";source=" + GetAltmerCrisisSourceLabel(StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisSource")) + ";pressure=" + StorageUtil.GetIntValue(None, "PDV.Altmer.LorkhanPressureCount") + ";favor=" + GetContextualFavorFamilyLabel(FAVOR_LANE_ALTMER, StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.LastFamily")) + ";rejected=" + StorageUtil.GetIntValue(None, "PDV.Altmer.RejectedSurfaceCount") + ";curse=" + GetAltmerCurseSummary()
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
    if newTier < oldTier && piety >= (ThresholdForTier(deity, oldTier) - TIER_DOWN_HYSTERESIS)
        newTier = oldTier
    endIf

    RefreshPassiveDecayFloorForDeity(deity, newTier)

    if newTier != oldTier
        StorageUtil.SetFloatValue(deityForm, "PDV.Tier", newTier as Float)
        StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", Utility.GetCurrentGameTime())

        if deity == _activeDeity
            deity.OnTierChange(oldTier, newTier)
            RefreshPatronMirrors()
            if newTier > oldTier
                SendPrismaEventToast("tier", deity, "", GetCurrentStandingLabel(), "")
            endIf
        endIf

        RequestPanelRefresh()
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
    RequestPanelRefresh()

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
            Float scaledToday = pietyToday * GAIN_RATE_SCALE
            Float clampedToday = ClampValue(scaledToday, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)
            if clampedToday > 0.0
                clampedToday = clampedToday * GetOrcLifeModeGainMultiplier(deity)
            endIf
            Float oldPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
            Float newPiety = ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)

            StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
            StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
            if clampedToday != 0.0
                StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
            endIf

            Int newTier = RecomputeTier(deity)

            if GetDebugLevel() >= 2
                Debug.Trace("[PDV] ProcessDawn: " + deity.DeityName + " piety " + oldPiety + " -> " + newPiety + ", today " + pietyToday + " scaled to " + scaledToday + " clamped/applied to " + clampedToday + ", tier now " + newTier)
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

    if IsArgonianOrigin()
        RunDawnRefreshArgonianHist()
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
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", 0)
        SyncKyneNeglectSpell(False)
        UpdateContextualFavorRuntime()
        return
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || !_activeDeity
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", 0)
        SyncKyneNeglectSpell(False)
        UpdateContextualFavorRuntime()
        return
    endIf

    ClearAllNeglectFlags()
    Int activeCount = ApplyGenericNeglectFlags()
    StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", activeCount)
    SyncKyneNeglectSpell(IsNeglectFlagActive(PDV_Kyne))
    UpdateContextualFavorRuntime()

    Bool patronNeglected = IsNeglectFlagActive(_activeDeity)
    if patronNeglected && StorageUtil.GetIntValue(None, "PDV.Neglect.PatronToastState") == 0
        SendPrismaEventToast("neglect", _activeDeity, "", "", "")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", BoolToInt(patronNeglected))
EndFunction

Function RunDawnProcessCommitmentOffers()
    if IsBosmerOrigin()
        EvaluateBosmerPathSuggestion()
        return
    endIf

    EvaluateFormalCommitmentOffer()
EndFunction

Function RunDawnNotify()
    SendPrismaEventToast("dawn", None, "", "", "")
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
        SendPrismaEventToast("favor", deity, "", "", "")
    endIf

    if allowRivalry && appliedAmount > 0.0 && stance == deity.STANCE_HOSTILE
        ApplyRivalryPenalties(deity, appliedAmount)
    endIf

    if appliedAmount != 0.0
        RequestPanelRefresh()
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

    if PDV_CurseStateService && PDV_CurseStateService.IsVampire() && deity.IsAedric
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
    if !IsP2BookNoticeReason(reason)
        SendContextualFavorToast(laneValue, familyValue)
    endIf
    SyncKyneFavorDebugState()
    if !IsP2BookNoticeReason(reason)
        RequestPanelRefresh()
    endIf
    return True
EndFunction

Function SendContextualFavorToast(Int laneValue, Int familyValue)
    String surfacing = GetFavorSurfacingLabel(laneValue, familyValue)
    if surfacing == "Quiet"
        return
    endIf

    ; Route contextual favors through the UI-owned "favor" voice for continuity.
    ; The family label is the meaningful act, so it carries as the event context.
    ; Kyne-lane favors can fire under broad Nord worship (no _activeDeity), so they
    ; pin to Kyne explicitly; other lanes credit the active patron (e.g. Auri-El for
    ; the Altmer lane). Deity-less pantheon lanes fall back to the journal mark.
    String contextText = GetContextualFavorFamilyLabel(laneValue, familyValue)
    PDV_DeityBase favorDeity = _activeDeity
    if laneValue == FAVOR_LANE_KYNE && PDV_Kyne
        favorDeity = PDV_Kyne
    endIf

    SendPrismaEventToast("favor", favorDeity, contextText, "", "")
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
    RequestPanelRefresh()
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

    if GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        if IsAltmerFavorSuppressedByCurse()
            return FAVOR_LANE_NONE
        endIf

        return FAVOR_LANE_ALTMER
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        return IsValidAltmerSourceFavorFamily(familyValue)
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return "PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness"
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return "PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement"
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        return "Altmer Ancestral Order"
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        if familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
            return "Dawn steadiness"
        elseIf familyValue == FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return "Orthodox costly enforcement"
        endIf
    endIf

    return "Unknown"
EndFunction

String Function GetFavorSurfacingLabel(Int laneValue, Int familyValue)
    if familyValue == FAVOR_FAMILY_KYNE_GUIDED_HUNT || familyValue == FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL || familyValue == FAVOR_FAMILY_NINE_HONEST_WORK || familyValue == FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
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

Function DebugRecordArgonianHistMaintenance()
    HandleArgonianHistMaintenance("mcm")
EndFunction

Function DebugRecordArgonianPeopleSupport()
    HandleArgonianPeopleSupport("mcm")
EndFunction

Function DebugRecordArgonianBedOfChoiceReturn()
    HandleArgonianBedOfChoiceReturn("mcm")
EndFunction

Function DebugRecordArgonianVoidSignal()
    HandleArgonianVoidSignal("mcm")
EndFunction

Function DebugRecordTalosShrineDefiance()
    HandleTalosShrineDefiance("mcm")
EndFunction

Function DebugRecordAltmerDawnSteadiness()
    HandleAltmerDawnSteadiness("mcm")
EndFunction

Function DebugRecordAltmerOrthodoxCostlyEnforcement()
    HandleAltmerOrthodoxCostlyEnforcement("mcm")
EndFunction

Function DebugRecordAltmerDragonbornCrisis()
    HandleAltmerCrisisSource(ALTMER_CRISIS_SOURCE_DRAGONBORN, "mcm_dragonborn")
EndFunction

Function DebugRecordAltmerLorkhanPressure()
    HandleAltmerLorkhanPressure(ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION, "mcm_lorkhan_pressure")
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
    if laneValue < FAVOR_LANE_KYNE || laneValue > FAVOR_LANE_ALTMER
        laneValue = FAVOR_LANE_KYNE
        StorageUtil.SetIntValue(None, "PDV.Favor.DebugLane", laneValue)
    endIf

    return laneValue
EndFunction

Function SetSelectedContextualFavorLane(Int laneValue)
    Int normalizedLane = ClampInt(laneValue, FAVOR_LANE_KYNE, FAVOR_LANE_ALTMER)
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        return FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
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
    elseIf laneValue == FAVOR_LANE_ALTMER
        currentFamily += 1
        if currentFamily > FAVOR_FAMILY_ALTMER_ORTHODOX_COST
            return FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
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
    if laneValue > FAVOR_LANE_ALTMER
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
        SendPrismaDaedricToast("Hircine", "lapse", "", "hircine")
        RequestPanelRefresh()
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
    SendPrismaCurseToast(oldState, newState)
    RequestPanelRefresh()
EndFunction

; Derive a typed "curse" Prisma event from an old→new curse-state transition.
; Symbol names (curse-vampire, curse-werewolf) fall back to "journal" until
; the glyph design pass lands — no rendering breakage in the meantime.
Function SendPrismaCurseToast(Int oldState, Int newState)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    ; Phase: what kind of transition is this?
    String phase = ""
    if oldState == 0
        phase = "onset"
    elseIf newState == 0
        phase = "cure"
    else
        phase = "shift"
    endIf

    ; Curse type: use the *incoming* state for onset/shift; outgoing state for cure
    ; so the mark and wording match what the player just experienced.
    Int curseRef = newState
    if phase == "cure"
        curseRef = oldState
    endIf
    String curseType = ""
    String symbolName = "journal"
    if curseRef == 1
        curseType = "werewolf"
        symbolName = "curse-werewolf"
    elseIf curseRef == 2
        curseType = "vampire"
        symbolName = "curse-vampire"
    endIf

    ; Race-aware context so the toast reads right for each theology.
    String context = GetCurseContextForRace(phase, curseType)

    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"curse\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"curse\":\"" + JsonSafeString(curseType) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + JsonSafeString(_activeDeity.DeityName) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

; Short race-specific context phrase — feeds the UI's listText fallback and any
; future per-race voice extension. Kept brief; the lore detail stays in the
; existing modal messages (ShowNordMessage / ShowAltmerMessage).
String Function GetCurseContextForRace(String phase, String curseType)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD
        if phase == "onset" && curseType == "vampire"
            return "Sovngarde is closed while the thirst remains."
        elseIf phase == "cure" && curseType == "vampire"
            return "The road opens again. The scar remains."
        elseIf phase == "onset" && curseType == "werewolf"
            return "The hunt pulls against Sovngarde."
        endIf
    elseIf originRace == ORIGIN_ALTMER
        if phase == "onset" && curseType == "vampire"
            return "Auri-El's light is closed. Only exile remains."
        elseIf phase == "cure" && curseType == "vampire"
            return "Exiled from the dawn, not restored to it."
        elseIf phase == "onset" && curseType == "werewolf"
            return "Devotion stops here. You have become a beast."
        endIf
    elseIf originRace == ORIGIN_BOSMER
        if phase == "onset"
            return "The Green Pact does not speak to what you have become."
        endIf
    elseIf originRace == ORIGIN_ARGONIAN
        if phase == "onset" && curseType == "vampire"
            return "The Hist recoils from what stirs in your blood."
        elseIf phase == "onset" && curseType == "werewolf"
            return "The Hist feels the hunt-shape pulling at your form."
        endIf
    elseIf originRace == ORIGIN_ORC
        if phase == "onset"
            return "Malacath's code bends under this new shape."
        endIf
    endIf
    return ""
EndFunction

; Emit a "shift" event when a substrate/state-track mode changes.
; shiftMode = human-readable new state label (e.g. "Khenarthi", "Stronghold")
; context   = optional short phrase (empty is fine; UI templates the rest)
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Function SendPrismaShiftToast(String shiftMode, String context, String symbolName)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"shift\""
    j = j + ",\"shiftMode\":\"" + JsonSafeString(shiftMode) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + JsonSafeString(_activeDeity.DeityName) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

; Emit a "daedric" event for a Daedric Prince interaction.
; princeName = e.g. "Hircine", "Azura"
; phase      = "boon" | "price" | "lapse" | "residue"
; context    = optional short phrase
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Function SendPrismaDaedricToast(String princeName, String phase, String context, String symbolName)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"prince\":\"" + JsonSafeString(princeName) + "\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

; Map a Khajiit focus value to a Prisma symbol key.
; Glyphs for these fall back to journal until the Tier-1/2 design pass lands.
String Function GetKhajiitFocusSymbol(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return "khenarthi"
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return "azurah"
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return "baan-dar"
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return "rajhin"
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return "alkosh"
    endIf
    return "lunar"
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
        ApplyAltmerCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_ARGONIAN
        ApplyArgonianCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_ORC
        ApplyOrcCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_REDGUARD
        ApplyRedguardCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_NORD
        ApplyNordCurseHandlers(oldState, newState, reason)
        if PDV_HircinePath
            PDV_HircinePath.HandleCurseTransition(oldState, newState, reason)
            PDV_HircinePath.UpdateResidueRecovery()
        endIf
    endIf
EndFunction

Function ApplyAltmerCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressAltmerCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 0)
        ClearActiveFavor("altmer_vampire")
        ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown") != 1
            ShowAltmerMessage(PDV_Msg_Altmer_VampireExiledPath_Entry, "Auri-El is closed while you flee the sun. What remains is exile: a narrow discipline, never a full return.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 1)
        ClearActiveFavor("altmer_werewolf")
        ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown") != 1
            ShowAltmerMessage(PDV_Msg_Altmer_CurseState_WerewolfHardHalt, "The whole of Altmer faith is to become spirit again. You have become a beast. Devotion stops here.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown", 0)
        if oldState == 2 && StorageUtil.GetIntValue(None, "PDV.Altmer.VampireRecognitionShown") != 1
            ShowAltmerMessage(PDV_Msg_Altmer_VampireExiledPath_Recognition, "You are exiled from the dawn, not restored to it. A thin discipline remains, capped low.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.VampireRecognitionShown", 1)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", BoolToInt(newState != 0))
    endIf
EndFunction

Function ApplyArgonianCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_SILENCED)
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.VampireScar", 1)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_STRAINED)
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_DISTANT)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_NORMAL)
    endIf

    RefreshArgonianHistPosture(reason)
EndFunction

Function ApplyOrcCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.VampireScar", 1)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 1)
    elseIf oldState != 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    endIf
EndFunction

Function ApplyRedguardCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireScar", 1)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
    elseIf oldState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
    endIf

    StorageUtil.SetStringValue(None, "PDV.Curse.Redguard.LastReason", reason)
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

Bool Function ShouldSuppressAltmerCurseModal(String reason)
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

Function ShowAltmerMessage(Message messageRecord, String fallbackText, Bool suppressModal)
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

Bool Function IsArgonianOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
EndFunction

Function EnsureUnifiedStartupChoice()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace < 0
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") == 1
        return
    endIf

    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        if HasExplicitStartupState(originRace)
            ShowStartupMigrationInfo(originRace)
            StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
            StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
            return
        endIf

        EnsureExplicitStartupChoice(originRace)
        return
    endIf

    EnsureInfoOnlyStartup(originRace)
EndFunction

Int Function GetStartupModeForOrigin(Int originRace)
    if originRace == ORIGIN_BRETON || originRace == ORIGIN_BOSMER || originRace == ORIGIN_REDGUARD || originRace == ORIGIN_ORC
        return STARTUP_MODE_EXPLICIT_CHOICE
    endIf

    return STARTUP_MODE_INFO_ONLY
EndFunction

Bool Function HasExplicitStartupState(Int originRace)
    if originRace == ORIGIN_BOSMER
        return HasBosmerSetupCompleted()
    elseIf originRace == ORIGIN_BRETON
        return StorageUtil.GetIntValue(None, "PDV.Breton.SetupComplete") == 1 || StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) >= 0
    elseIf originRace == ORIGIN_REDGUARD
        if StorageUtil.GetIntValue(None, "PDV.Redguard.SetupComplete") == 1
            return True
        endIf
        if PDV_RedguardSectTrack
            return PDV_RedguardSectTrack.GetCurrentState() >= REDGUARD_SECT_CROWN
        endIf
        return False
    elseIf originRace == ORIGIN_ORC
        if StorageUtil.GetIntValue(None, "PDV.Orc.SetupComplete") == 1
            return True
        endIf
        if PDV_OrcLifeModeTrack
            return PDV_OrcLifeModeTrack.GetCurrentState() >= ORC_LIFE_MODE_CITY
        endIf
        return False
    endIf

    return False
EndFunction

Function EnsureExplicitStartupChoice(Int originRace)
    Message choiceMessage = GetStartupChoiceMessage(originRace)
    Int defaultOption = GetStartupDefaultOption(originRace)
    Int maxOption = GetStartupChoiceMaxOption(originRace)

    RecordStartupEvent("startup_shown")

    if !choiceMessage
        Trace(1, "Startup choice message missing for origin " + originRace + "; defaulting option " + defaultOption)
        ApplyStartupChoice(originRace, defaultOption, "startup_missing_message_default")
        RecordStartupEvent("startup_confirmed")
        StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
        StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
        return
    endIf

    Int selection = choiceMessage.Show()
    if selection < 0 || selection > maxOption
        Trace(1, "Startup choice canceled for origin " + originRace + " with selection " + selection)
        return
    endIf

    Debug.MessageBox(GetStartupOptionDetailText(originRace, selection))
    if !ConfirmStartupSelection(choiceMessage, selection)
        Trace(2, "Startup choice not confirmed for origin " + originRace + " selection " + selection)
        return
    endIf

    ApplyStartupChoice(originRace, selection, "startup_choice")
    RecordStartupEvent("startup_confirmed")
    StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
EndFunction

Bool Function ConfirmStartupSelection(Message choiceMessage, Int expectedSelection)
    if PDV_MSG_StartupConfirmChoice
        Int confirm = PDV_MSG_StartupConfirmChoice.Show()
        return confirm == 0
    endIf

    Int retrySelection = choiceMessage.Show()
    return retrySelection == expectedSelection
EndFunction

Function EnsureInfoOnlyStartup(Int originRace)
    RecordStartupEvent("startup_shown")
    Debug.MessageBox(GetStartupInfoOnlyText(originRace))
    RecordStartupEvent("startup_info_acknowledged")
    StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
EndFunction

Function ShowStartupMigrationInfo(Int originRace)
    Debug.MessageBox("PlayerDevotion keeps your existing startup state on this save.\n\n" + GetStartupCanonicalSummary(originRace) + "\n\n" + STARTUP_ADVISORY_TEXT)
    RecordStartupEvent("startup_info_acknowledged")
EndFunction

Function RecordStartupEvent(String eventName)
    StorageUtil.AdjustIntValue(None, "PDV.Startup.Event." + eventName, 1)
    StorageUtil.SetStringValue(None, "PDV.Startup.Event.Last", eventName)
    StorageUtil.SetFloatValue(None, "PDV.Startup.Event.LastAt", Utility.GetCurrentGameTime())
EndFunction

Message Function GetStartupChoiceMessage(Int originRace)
    if originRace == ORIGIN_BOSMER
        return PDV_MSG_BosmerSetupChoice
    elseIf originRace == ORIGIN_BRETON
        return PDV_MSG_StartupBretonChoice
    elseIf originRace == ORIGIN_REDGUARD
        return PDV_MSG_StartupRedguardChoice
    elseIf originRace == ORIGIN_ORC
        return PDV_MSG_StartupOrcChoice
    endIf

    return None
EndFunction

Int Function GetStartupChoiceMaxOption(Int originRace)
    if originRace == ORIGIN_BOSMER
        return BOSMER_PATH_BANDIT_ROAD
    endIf

    return 2
EndFunction

Int Function GetStartupDefaultOption(Int originRace)
    if originRace == ORIGIN_BOSMER
        return BOSMER_PATH_LIVING_STORY
    elseIf originRace == ORIGIN_BRETON
        return 0
    elseIf originRace == ORIGIN_REDGUARD
        return REDGUARD_SECT_FOREBEAR
    elseIf originRace == ORIGIN_ORC
        return ORC_LIFE_MODE_CITY
    endIf

    return 0
EndFunction

Function ApplyStartupChoice(Int originRace, Int optionValue, String reason)
    if originRace == ORIGIN_BOSMER
        ApplyBosmerInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_BRETON
        ApplyBretonInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_REDGUARD
        ApplyRedguardInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_ORC
        ApplyOrcInitialChoice(optionValue, reason)
    endIf
EndFunction

Function ApplyBretonInitialChoice(Int traditionValue, String reason)
    Int normalized = ClampInt(traditionValue, 0, 2)
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.StartupReason", reason)
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    if PDV_RedguardSectTrack
        PDV_RedguardSectTrack.SetState(ClampInt(sectValue, REDGUARD_SECT_CROWN, REDGUARD_SECT_ASHABAH), reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.SetupComplete", 1)
EndFunction

Function ApplyOrcInitialChoice(Int modeValue, String reason)
    if PDV_OrcLifeModeTrack
        PDV_OrcLifeModeTrack.SetState(ClampInt(modeValue, ORC_LIFE_MODE_CITY, ORC_LIFE_MODE_LEGION_EXILE), reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Orc.SetupComplete", 1)
EndFunction

Function HandleBretonTraditionChoice(Int traditionValue, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton tradition choice ignored for non-Breton origin.")
        return
    endIf

    ApplyBretonInitialChoice(traditionValue, reason)
    StorageUtil.SetIntValue(None, "PDV.Breton.TraditionHookCount", StorageUtil.GetIntValue(None, "PDV.Breton.TraditionHookCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
    Trace(2, "Breton tradition choice routed: " + reason)
EndFunction

Function HandleBretonKnightlyVow(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Knightly Vow ignored for non-Breton origin.")
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == 0
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowCount", StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount") + 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Breton.CrossTraditionPressure", StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") + 1)
    endIf

    StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    Trace(2, "Breton Knightly Vow routed: " + reason)
EndFunction

Function HandleBretonHiddenArtExposure(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Hidden Art ignored for non-Breton origin.")
        return
    endIf

    Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
    StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", ClampInt(exposureValue + 25, 0, 100))
    StorageUtil.SetIntValue(None, "PDV.Breton.HiddenArtCount", StorageUtil.GetIntValue(None, "PDV.Breton.HiddenArtCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastHiddenArtReason", reason)
    ShowP2BookNotice(reason, "Hidden Art noted", "This reading raises your Breton witchcraft exposure.")
    Trace(2, "Breton Hidden Art exposure routed: " + reason)
EndFunction

Function HandleBretonGreenWayStanding(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Green Way ignored for non-Breton origin.")
        return
    endIf

    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding")
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", ClampInt(standingValue + 25, 0, 100))
    StorageUtil.SetIntValue(None, "PDV.Breton.GreenWayCount", StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    Trace(2, "Breton Green Way standing routed: " + reason)
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        Trace(2, "Dunmer Reclamation focus ignored for non-Dunmer origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocus", ClampInt(focusValue, 0, 2))
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocusCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastReclamationReason", reason)
    if focusValue == 0
        ShowP2BookNotice(reason, "Azura noted", "This reading shapes your Dunmer Reclamation focus.")
    elseIf focusValue == 1
        ShowP2BookNotice(reason, "Boethiah noted", "This reading shapes your Dunmer Reclamation focus.")
    else
        ShowP2BookNotice(reason, "Reclamation noted", "This reading shapes your Dunmer Reclamation focus.")
    endIf
    Trace(2, "Dunmer Reclamation focus routed: " + reason)
EndFunction

Function HandleDunmerDeviationPrice(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        Trace(2, "Dunmer deviation price ignored for non-Dunmer origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.DeviationPriceCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastDeviationReason", reason)
    Trace(2, "Dunmer deviation price routed: " + reason)
EndFunction

Function HandleImperialCivicService(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial civic service ignored for non-Imperial origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.CivicServiceCount", StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicServiceReason", reason)
    Trace(2, "Imperial civic service routed: " + reason)
EndFunction

Function HandleImperialTalosPressure(Bool isPrivate, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial Talos pressure ignored for non-Imperial origin.")
        return
    endIf

    if isPrivate
        StorageUtil.SetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") + 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.PublicTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") + 1)
    endIf

    StorageUtil.SetStringValue(None, "PDV.Imperial.LastTalosPressureReason", reason)
    ShowP2BookNotice(reason, "Talos pressure noted", "This reading adds Imperial Talos pressure.")
    Trace(2, "Imperial Talos pressure routed: " + reason)
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial patron civic favor ignored for non-Imperial origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.PatronCivicFavorCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastPatronCivicFavorReason", reason)
    Trace(2, "Imperial patron civic favor routed: " + reason)
EndFunction

Function HandleNordOldWaysState(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Old Ways state ignored for non-Nord origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Nord.OldWaysContextCount", StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastOldWaysReason", reason)
    ShowP2BookNotice(reason, "Old Ways noted", "This reading strengthens your Nord old-ways context.")
    Trace(2, "Nord Old Ways state routed: " + reason)
EndFunction

Function HandleNordKyneTalosContext(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Kyne/Talos context ignored for non-Nord origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Nord.KyneTalosContextCount", StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastKyneTalosReason", reason)
    Trace(2, "Nord Kyne/Talos context routed: " + reason)
EndFunction

Function HandleNordHircineArkayEdge(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Hircine/Arkay edge ignored for non-Nord origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Nord.HircineArkayEdgeCount", StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastHircineArkayReason", reason)
    ShowP2BookNotice(reason, "Hircine and Arkay noted", "This reading adds Nord hunt-and-death context.")
    Trace(2, "Nord Hircine/Arkay edge routed: " + reason)
EndFunction

String Function GetStartupCanonicalSummary(Int originRace)
    if originRace == ORIGIN_NORD
        return "You begin among the broad worship of the Nords. No single god claims you yet; a patron will reveal itself through how you live, hunt, and weather the storms."
    elseIf originRace == ORIGIN_IMPERIAL
        return "You begin in the broad embrace of the Nine Divines, even as the White-Gold Concordat presses down on the open worship of Talos."
    elseIf originRace == ORIGIN_DUNMER
        return "You begin already grounded in ancestor and Reclamation. There is no path to choose here; the Dunmer carry their devotion in the blood."
    elseIf originRace == ORIGIN_ALTMER
        return "You begin beneath Auri-El, the founding light of the Altmer, and the lifelong pressure to keep your devotion pure and coherent."
    elseIf originRace == ORIGIN_KHAJIIT
        return "You begin within the Lunar Lattice, the two moons your road and your guide. Your focus will emerge quietly, in how you walk and where you rest."
    elseIf originRace == ORIGIN_ARGONIAN
        return "You begin in the layered devotion of your people: the Hist that shaped you, the world's gods you may yet borrow, and the Void that waits beneath."
    elseIf originRace == ORIGIN_BRETON
        return "You begin by choosing your tradition: the Knight's Road of vow and mercy, the Hidden Art of forbidden power, or the Green Way of the old druids."
    elseIf originRace == ORIGIN_BOSMER
        return "You begin by choosing your path: the Old Contract's hard covenant, the Living Story of your people, the Exchange of debt and redress, or the Bandit Road's trickster survival."
    elseIf originRace == ORIGIN_REDGUARD
        return "You begin by choosing your sect: the orthodox Crown, the adaptive Forebear, or the burdened Ash'abah who tend the unquiet dead."
    elseIf originRace == ORIGIN_ORC
        return "You begin by choosing your life-mode: the full Stronghold code of Malacath, dignity kept in the City, or honor carried into Legion and exile."
    endIf

    return "Your starting devotion is set by the traditions of your people."
EndFunction

String Function GetStartupInfoOnlyText(Int originRace)
    return GetStartupCanonicalSummary(originRace) + "\n\n" + STARTUP_ADVISORY_TEXT
EndFunction

String Function GetStartupOptionId(Int originRace, Int optionValue)
    if originRace == ORIGIN_BOSMER
        if optionValue == BOSMER_PATH_OLD_CONTRACT
            return "old_contract"
        elseIf optionValue == BOSMER_PATH_EXCHANGE
            return "exchange"
        elseIf optionValue == BOSMER_PATH_BANDIT_ROAD
            return "bandit_road"
        endIf
        return "living_story"
    elseIf originRace == ORIGIN_BRETON
        if optionValue == 0
            return "knights_road"
        elseIf optionValue == 1
            return "hidden_art"
        endIf
        return "green_way"
    elseIf originRace == ORIGIN_REDGUARD
        if optionValue == REDGUARD_SECT_CROWN
            return "crown"
        elseIf optionValue == REDGUARD_SECT_ASHABAH
            return "ashabah"
        endIf
        return "forebear"
    elseIf originRace == ORIGIN_ORC
        if optionValue == ORC_LIFE_MODE_STRONGHOLD
            return "stronghold"
        elseIf optionValue == ORC_LIFE_MODE_LEGION_EXILE
            return "legion_exile"
        endIf
        return "city"
    elseIf originRace == ORIGIN_NORD
        return "broad_nord"
    elseIf originRace == ORIGIN_IMPERIAL
        return "broad_nine"
    elseIf originRace == ORIGIN_DUNMER
        return "ancestor_layer"
    elseIf originRace == ORIGIN_ALTMER
        return "auriel_foundation"
    elseIf originRace == ORIGIN_KHAJIIT
        return "lunar_lattice"
    elseIf originRace == ORIGIN_ARGONIAN
        return "hist_people_void"
    endIf

    return "startup_context"
EndFunction

String Function GetStartupOptionTitle(Int originRace, Int optionValue)
    if originRace == ORIGIN_BOSMER
        if optionValue == BOSMER_PATH_OLD_CONTRACT
            return "Old Contract"
        elseIf optionValue == BOSMER_PATH_EXCHANGE
            return "Exchange"
        elseIf optionValue == BOSMER_PATH_BANDIT_ROAD
            return "Bandit Road"
        endIf
        return "Living Story"
    elseIf originRace == ORIGIN_BRETON
        if optionValue == 0
            return "Knight's Road"
        elseIf optionValue == 1
            return "Hidden Art"
        endIf
        return "Green Way"
    elseIf originRace == ORIGIN_REDGUARD
        if optionValue == REDGUARD_SECT_CROWN
            return "Crown"
        elseIf optionValue == REDGUARD_SECT_ASHABAH
            return "Ash'abah"
        endIf
        return "Forebear"
    elseIf originRace == ORIGIN_ORC
        if optionValue == ORC_LIFE_MODE_STRONGHOLD
            return "Stronghold"
        elseIf optionValue == ORC_LIFE_MODE_LEGION_EXILE
            return "Legion/Exile"
        endIf
        return "City"
    endIf

    return GetOriginRaceLabel(originRace)
EndFunction

String Function GetStartupOptionSummary(Int originRace, Int optionValue)
    if originRace == ORIGIN_BRETON
        if optionValue == 0
            return "Civic honor and vows kept, even when they cost you."
        elseIf optionValue == 1
            return "Forbidden power, carried at real social risk."
        endIf
        return "Druidic covenant and the rhythm of nature's rites."
    elseIf originRace == ORIGIN_BOSMER
        if optionValue == BOSMER_PATH_OLD_CONTRACT
            return "The hardest Green Pact burden, and the highest reward."
        elseIf optionValue == BOSMER_PATH_EXCHANGE
            return "Debt, restitution, and redress in fair measure."
        elseIf optionValue == BOSMER_PATH_BANDIT_ROAD
            return "Survival and reversal on the road, under Baan Dar."
        endIf
        return "Community kept and stories carried, under Y'ffre."
    elseIf originRace == ORIGIN_REDGUARD
        if optionValue == REDGUARD_SECT_CROWN
            return "Orthodox bearing and the preserved Yokudan form."
        elseIf optionValue == REDGUARD_SECT_ASHABAH
            return "Costly funerary duty, and the impurity you carry for others."
        endIf
        return "Adaptation and open life in mixed Skyrim."
    elseIf originRace == ORIGIN_ORC
        if optionValue == ORC_LIFE_MODE_STRONGHOLD
            return "Malacath's code in full, lived without compromise."
        elseIf optionValue == ORC_LIFE_MODE_LEGION_EXILE
            return "Honor kept privately under a foreign discipline."
        endIf
        return "Quiet fidelity beneath public compromise."
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction

String Function GetStartupOptionDescription(Int originRace, Int optionValue)
    if originRace == ORIGIN_BRETON
        if optionValue == 0
            return "The Knight's Road asks for mercy, protection, and public duty. Its friction is the pull of your vows against the easier, expedient choice."
        elseIf optionValue == 1
            return "The Hidden Art opens occult and Daedric power to you, with social exposure that rises as you go. It rewards risk taken openly, not power kept quiet."
        endIf
        return "The Green Way centers nature rites, the rhythm of the standing stones, and druidic belonging rather than civic standing."
    elseIf originRace == ORIGIN_BOSMER
        if optionValue == BOSMER_PATH_OLD_CONTRACT
            return "The Old Contract holds you to the strict Green Pact and to Y'ffre alone. It carries the highest ceiling and the hardest fall."
        elseIf optionValue == BOSMER_PATH_EXCHANGE
            return "The Exchange weighs debt, return, and proportionate vengeance under Z'en. It is a moral economy, not simple kindness."
        elseIf optionValue == BOSMER_PATH_BANDIT_ROAD
            return "The Bandit Road is Baan Dar's theology of the road: reversal, trickery, and survival bought at a price."
        endIf
        return "The Living Story keeps community memory and oral continuity alive. It asks for belonging first, not covenant pushed to its limit."
    elseIf originRace == ORIGIN_REDGUARD
        if optionValue == REDGUARD_SECT_CROWN
            return "The Crown keeps orthodox Yokudan structure, strong ancestor duty, and the old forms preserved against the pressure of exile."
        elseIf optionValue == REDGUARD_SECT_ASHABAH
            return "The Ash'abah bear funerary duty and the work of the unquiet dead at real social cost. This path is narrower and heavier by design."
        endIf
        return "The Forebear carries Redguard identity into mixed public life, bridging adaptation without letting the Yokudan spine break."
    elseIf originRace == ORIGIN_ORC
        if optionValue == ORC_LIFE_MODE_STRONGHOLD
            return "Stronghold life is the full expression of Malacath: labor, oath, strength, and provision held in common."
        elseIf optionValue == ORC_LIFE_MODE_LEGION_EXILE
            return "Legion and exile keep Malacath close in private, while the order around you belongs to others."
        endIf
        return "City life holds dignity and code in mixed society, where Orc faith is never simply given to you."
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction

String Function GetStartupOptionDetailText(Int originRace, Int optionValue)
    String text = GetOriginRaceLabel(originRace) + " - " + GetStartupOptionTitle(originRace, optionValue)
    text = text + "\n\n" + GetStartupOptionSummary(originRace, optionValue)
    text = text + "\n\n" + GetStartupOptionDescription(originRace, optionValue)
    text = text + "\n\n" + STARTUP_ADVISORY_TEXT
    return text
EndFunction

Function SendPrismaStartupPayload(Int originRace, Int startupMode, Int defaultOption, Bool confirmRequired, String eventName)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    Int optionCount = 1
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        optionCount = GetStartupChoiceMaxOption(originRace) + 1
    endIf

    String optionsJson = ""
    Int i = 0
    while i < optionCount
        Int optionValue = i
        if startupMode == STARTUP_MODE_INFO_ONLY
            optionValue = 0
        endIf

        if i > 0
            optionsJson = optionsJson + ","
        endIf

        optionsJson = optionsJson + "{\"option_id\":\"" + JsonSafeString(GetStartupOptionId(originRace, optionValue)) + "\",\"title\":\"" + JsonSafeString(GetStartupOptionTitle(originRace, optionValue)) + "\",\"summary\":\"" + JsonSafeString(GetStartupOptionSummary(originRace, optionValue)) + "\",\"description\":\"" + JsonSafeString(GetStartupOptionDescription(originRace, optionValue)) + "\"}"
        i += 1
    endWhile

    String modeText = "info_only"
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        modeText = "explicit_choice"
    endIf

    String payload = "{\"mode\":\"startup\",\"startup\":{\"event\":\"" + JsonSafeString(eventName) + "\",\"race_id\":\"" + JsonSafeString(GetStartupRaceId(originRace)) + "\",\"startup_mode\":\"" + modeText + "\",\"options\":[" + optionsJson + "],\"default_option_id\":\"" + JsonSafeString(GetStartupOptionId(originRace, defaultOption)) + "\",\"advisory_line\":\"" + JsonSafeString(STARTUP_ADVISORY_TEXT) + "\",\"confirm_required\":" + BoolToJson(confirmRequired) + ",\"title\":\"" + JsonSafeString(GetOriginRaceLabel(originRace) + " startup") + "\",\"summary\":\"" + JsonSafeString(GetStartupCanonicalSummary(originRace)) + "\"}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

String Function BoolToJson(Bool value)
    if value
        return "true"
    endIf

    return "false"
EndFunction

String Function GetStartupRaceId(Int originRace)
    if originRace == ORIGIN_NORD
        return "nord"
    elseIf originRace == ORIGIN_IMPERIAL
        return "imperial"
    elseIf originRace == ORIGIN_BRETON
        return "breton"
    elseIf originRace == ORIGIN_ALTMER
        return "altmer"
    elseIf originRace == ORIGIN_BOSMER
        return "bosmer"
    elseIf originRace == ORIGIN_DUNMER
        return "dunmer"
    elseIf originRace == ORIGIN_KHAJIIT
        return "khajiit"
    elseIf originRace == ORIGIN_ARGONIAN
        return "argonian"
    elseIf originRace == ORIGIN_ORC
        return "orc"
    elseIf originRace == ORIGIN_REDGUARD
        return "redguard"
    endIf

    return "unknown"
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

    SendPrismaShiftToast(GetBosmerPathLabel(), "", GetPrismaSymbolForDeity(_activeDeity))
    RequestPanelRefresh()
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
        if originRace == ORIGIN_ALTMER
            return GetAltmerSurveyText()
        elseIf originRace == ORIGIN_KHAJIIT
            return GetKhajiitSurveyText()
        elseIf originRace == ORIGIN_BOSMER
            return GetBosmerSurveyText()
        elseIf originRace == ORIGIN_ARGONIAN
            return GetArgonianSurveyText()
        elseIf originRace == ORIGIN_ORC
            return GetOrcSurveyText()
        elseIf originRace == ORIGIN_REDGUARD
            return GetRedguardSurveyText()
        elseIf originRace == ORIGIN_IMPERIAL
            return GetImperialSurveyText()
        elseIf originRace == ORIGIN_BRETON
            return GetBretonSurveyText()
        elseIf originRace == ORIGIN_DUNMER
            return GetDunmerSurveyText()
        endIf

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
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Startup pending | " + GetStartupMcmLine()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return GetNordDevotionModeLabel() + " | " + GetCurrentStandingLabel() + " | " + GetPlayerCursePublicLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return "Altmer | " + GetAltmerCrisisStateLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return "Khajiit | " + GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()) + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return "Bosmer | " + GetBosmerPathLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Argonian | " + GetArgonianHistPostureLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ORC
        return "Orc | " + GetOrcLifeModeLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
        return "Redguard | " + GetRedguardSectLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        return "Imperial | " + GetImperialConcordatLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        return "Breton | " + GetBretonTraditionLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        return "Dunmer | " + GetDunmerAncestorLayerLabel() + " | " + GetCurrentStandingLabel()
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
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return GetStartupMcmLine()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return GetNordDevotionModeLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return GetAltmerCrisisStateLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis())
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return GetBosmerPathLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Hist " + GetArgonianHistPostureLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ORC
        return GetOrcLifeModeLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
        return GetRedguardSectLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        return GetImperialConcordatLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        return GetBretonTraditionLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        return GetDunmerAncestorLayerLabel()
    endIf

    return GetPatronStateLabel()
EndFunction

String Function GetStartupMcmLine()
    Int originRace = GetPlayerOriginRaceIndex()
    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        return "Choose a starting path, then confirm."
    endIf

    return GetStartupCanonicalSummary(originRace)
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

    String contextText = GetNordContextSurveyText()
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        String focusedText = _activeDeity.DeityName + " names you. Current standing: " + GetCurrentStandingLabel() + "."
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == NORD_BASELINE_NINE_DIVINES
            return "You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath. Current standing: " + GetCurrentStandingLabel() + "." + contextText
        endIf

        return "You honor the Old Ways broadly. The pantheon has noted you. Current standing: " + GetCurrentStandingLabel() + "." + contextText
    endIf

    if PDV_HircinePath
        String hircineSummary = PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "The hunt pulls at the edge of the old road. Current standing: " + GetCurrentStandingLabel() + "." + contextText
        endIf
    endIf

    return "No Nord patron has fully answered yet. Keep the rites, and the road will become clearer." + contextText
EndFunction

String Function GetNordContextSurveyText()
    String text = ""
    Int oldWaysCount = StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount")
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if oldWaysCount > 0
        text = text + " Old Ways context has been noticed."
    endIf
    if kyneTalosCount > 0
        text = text + " Kyne or Talos context has weight."
    endIf
    if edgeCount > 0
        text = text + " Hunt and death-duty pressure is present."
    endIf
    return text
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
    if GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        String altmerCurseLabel = GetAltmerCursePublicLabel()
        if altmerCurseLabel != ""
            return altmerCurseLabel
        endIf
    endIf

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

String Function GetAltmerCursePublicLabel()
    if IsAltmerWerewolfHalted()
        return "Werewolf halt"
    endIf

    if IsAltmerVampireExiled()
        return "Exiled from dawn"
    endIf

    if HasAltmerVampireExileScar()
        return "Dawn-exile scar"
    endIf

    return ""
EndFunction

String Function GetAltmerCurseSummary()
    if IsAltmerWerewolfHalted()
        return "werewolf_halt"
    endIf

    if IsAltmerVampireExiled()
        return "vampire_exile"
    endIf

    if HasAltmerVampireExileScar()
        return "vampire_scar"
    endIf

    return "none"
EndFunction

String Function GetAltmerSurveyText()
    String text = "Auri-El remains the foundation. Current standing: " + GetCurrentStandingLabel() + "."
    Int crisisState = GetAltmerCrisisState()
    if crisisState == ALTMER_CRISIS_DISSONANT
        text = text + " The mortal world is pressing hard against your faith."
    elseIf crisisState == ALTMER_CRISIS_QUESTIONING
        text = text + " You are questioning how the old doctrine survives what you have seen."
    elseIf crisisState == ALTMER_CRISIS_REASSERTING
        text = text + " You are reasserting the return through discipline."
    elseIf crisisState == ALTMER_CRISIS_SCARRED_RESOLVED
        text = text + " The contradiction is scarred over, not forgotten."
    else
        text = text + " No active crisis is open."
    endIf

    Int pressureCount = StorageUtil.GetIntValue(None, "PDV.Altmer.LorkhanPressureCount")
    if pressureCount > 0
        text = text + " Lorkhan pressure has been named through authored acts."
    endIf

    Int favorFamily = StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.LastFamily")
    if favorFamily > 0
        text = text + " Last favor: " + GetContextualFavorFamilyLabel(FAVOR_LANE_ALTMER, favorFamily) + "."
    endIf

    String curseLabel = GetAltmerCursePublicLabel()
    if curseLabel != ""
        text = text + " Curse posture: " + curseLabel + "."
    endIf

    return text
EndFunction

String Function GetKhajiitSurveyText()
    String text = "The Lunar Lattice holds you. Current standing: " + GetCurrentStandingLabel() + "."
    if PDV_KhajiitLunarSubstrate
        text = text + " Moon practice is " + GetKhajiitLunarTierLabel(PDV_KhajiitLunarSubstrate.GetSubstrateTier()) + "."
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarSourceCount") > 0
            text = text + " A lunar source has been read."
        endIf
        if PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has weight."
        else
            text = text + " No road-home cadence has settled yet."
        endIf
    else
        text = text + " The moon substrate is not readable yet."
    endIf

    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue > KHAJIIT_FOCUS_NONE
        text = text + " Current focus: " + GetKhajiitFocusLabel(focusValue) + "."
    else
        text = text + " No single moon-path has pulled ahead."
    endIf

    return text
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

String Function GetBosmerSurveyText()
    if !PDV_BosmerPathTrack
        return "The Green has not found a readable path in the framework yet."
    endIf

    String text = "Your Bosmer path is " + GetBosmerPathLabel() + ". Current standing: " + GetCurrentStandingLabel() + "."
    if IsBosmerPactBound()
        text = text + " The Pact is presently binding."
    elseIf GetBosmerLapsedFromPact()
        text = text + " The Pact has lapsed and needs a reckoning."
    else
        text = text + " No Pact binding is active."
    endIf

    Int lastFamily = StorageUtil.GetIntValue(None, "PDV.Bosmer.Favor.LastFamily")
    if lastFamily > 0
        text = text + " A recent path favor is still remembered."
    endIf

    return text
EndFunction

String Function GetBosmerPathLabel()
    if PDV_BosmerPathTrack
        return PDV_BosmerPathTrack.GetStateLabel()
    endIf

    return "Unsettled"
EndFunction

String Function GetArgonianSurveyText()
    if !PDV_ArgonianHistSubstrate
        return "The Hist is distant, but the memory of it has not found a shape in the framework yet."
    endIf

    String text = "The Hist is " + GetArgonianHistPostureLabel() + ". " + GetArgonianHistLayerText()
    if StorageUtil.GetIntValue(None, "PDV.Argonian.HistSourceCount") > 0
        text = text + " A Hist source has been read."
    endIf
    return text
EndFunction

String Function GetArgonianHistLayerText()
    if !PDV_ArgonianHistSubstrate
        return "Hist, People, and Void are not yet readable."
    endIf

    String text = "Hist memory is " + GetArgonianLayerStrengthLabel(PDV_ArgonianHistSubstrate.GetHistRelation())
    text = text + "; People support is " + GetArgonianLayerStrengthLabel(PDV_ArgonianHistSubstrate.GetPeopleRelation())
    text = text + "; Void awareness is " + GetArgonianVoidStrengthLabel(PDV_ArgonianHistSubstrate.GetVoidRelation())
    Int bedCount = StorageUtil.GetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
    if bedCount > 0
        text = text + ". Your chosen bed has begun to matter."
    endIf
    if PDV_ArgonianHistSubstrate.IsVoidFullyActive()
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
    if PDV_ArgonianHistSubstrate && PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return "awake"
    elseIf value >= 35.0
        return "stirring"
    elseIf value > 0.0
        return "at the edge"
    endIf

    return "dormant"
EndFunction

String Function GetArgonianHistPostureLabel()
    if PDV_ArgonianHistSubstrate
        return PDV_ArgonianHistSubstrate.GetHistPostureLabel()
    endIf

    return "Missing"
EndFunction

String Function GetOrcSurveyText()
    if !PDV_OrcLifeModeTrack
        return "Malacath watches, but your life-mode has not found a shape in the framework yet."
    endIf

    String text = "Malacath watches the code through " + GetOrcLifeModeLabel() + " life. Current standing: " + GetCurrentStandingLabel() + "."
    if StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") > 0
        text = text + " A Malacath source has been read."
    endIf
    Int cursePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure")
    if cursePressure == 2
        text = text + " The vampire curse stands outside the test until it is cured."
    elseIf cursePressure == 1
        text = text + " The beast is being judged by the code."
    endIf

    return text
EndFunction

String Function GetRedguardSurveyText()
    if !PDV_RedguardSectTrack
        return "The Far Shores are named, but your Redguard sect has not found a shape in the framework yet."
    endIf

    String text = "Your Yokudan practice is walking the " + GetRedguardSectLabel() + " path. Current standing: " + GetCurrentStandingLabel() + "."
    if StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") > 0
        text = text + " An ancestor-spine source has been read."
    endIf
    Float farShoresWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")
    if farShoresWeight > 0.0
        text = text + " The Far Shores token has recent weight."
    endIf

    Int cyclePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure")
    if cyclePressure == 2
        text = text + " The vampire curse interrupts the cycle until Tu'whacca re-entry."
    elseIf cyclePressure == 1
        text = text + " The curse strains the route to proper mortality."
    endIf

    return text
EndFunction

String Function GetBretonSurveyText()
    String text = "Your Breton tradition is " + GetBretonTraditionLabel() + ". Current standing: " + GetCurrentStandingLabel() + "."
    text = text + " Vow: " + GetBretonKnightlyVowLabel() + "."
    text = text + " Hidden Art: " + GetBretonWitchcraftExposureLabel() + "."
    text = text + " Green Way: " + GetBretonDruidicStandingLabel() + "."
    if StorageUtil.GetIntValue(None, "PDV.Breton.TraditionHookCount") > 0
        text = text + " A tradition source has confirmed the road."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount") > 0
        text = text + " A vow source has been honored."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Breton.HiddenArtCount") > 0
        text = text + " Hidden learning has been noticed."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount") > 0
        text = text + " Green Way practice has been noticed."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") > 0
        text = text + " Cross-tradition pressure is present."
    endIf
    String curseLabel = GetBretonCursePostureLabel()
    if curseLabel != ""
        text = text + " Curse posture: " + curseLabel + "."
    endIf
    return text
EndFunction

String Function GetBretonTraditionLabel()
    Int traditionValue = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if traditionValue == 0
        return "Knight's Road"
    elseIf traditionValue == 1
        return "Hidden Art"
    elseIf traditionValue == 2
        return "Green Way"
    endIf

    return "Unchosen"
EndFunction

String Function GetBretonKnightlyVowLabel()
    Int integrityValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
    if integrityValue >= 70
        return "intact"
    elseIf integrityValue >= 30
        return "strained"
    endIf

    return "broken"
EndFunction

String Function GetBretonWitchcraftExposureLabel()
    Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure", 0)
    if exposureValue >= 75
        return "notorious"
    elseIf exposureValue >= 50
        return "known"
    elseIf exposureValue >= 25
        return "suspected"
    endIf

    return "hidden"
EndFunction

String Function GetBretonDruidicStandingLabel()
    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0)
    if standingValue >= 70
        return "acknowledged"
    elseIf standingValue < 0
        return "frayed"
    endIf

    return "open"
EndFunction

String Function GetBretonCursePostureLabel()
    Int curseValue = StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState")
    if curseValue == 2
        return "active rupture"
    elseIf curseValue == 1
        return "restoration needed"
    endIf

    return ""
EndFunction

String Function GetDunmerSurveyText()
    String text = "The ancestor layer remains the ground of your devotion. Current standing: " + GetCurrentStandingLabel() + "."
    text = text + " Ancestor practice is " + GetDunmerAncestorLayerLabel() + "."
    Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
    if reclamationFocus >= 0
        text = text + " Reclamation focus: " + GetDunmerReclamationFocusLabel(reclamationFocus) + "."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") > 0
        text = text + " A Reclamation source has been read."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") > 0
        text = text + " Deviation pressure is present."
    endIf
    if PDV_DunmerAncestorSubstrate
        if PDV_DunmerAncestorSubstrate.GetPrayerCount() > 0
            text = text + " Portable ash-prayer has been kept."
        endIf
        if PDV_DunmerAncestorSubstrate.GetHomeBonusCount() > 0
            text = text + " A private home rite has weight."
        endIf
    else
        text = text + " The ancestor substrate is not readable yet."
    endIf

    String postureLabel = GetDunmerCursePostureLabel()
    if postureLabel != ""
        text = text + " Curse posture: " + postureLabel + "."
    endIf
    return text
EndFunction

String Function GetDunmerAncestorLayerLabel()
    if !PDV_DunmerAncestorSubstrate
        return "unreadable"
    endIf

    Int tierValue = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
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
        return "strained"
    elseIf postureValue == 2
        return "restored, scarred"
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

String Function GetImperialSurveyText()
    String text = "Your Imperial faith is civic and public. Current standing: " + GetCurrentStandingLabel() + "."
    text = text + " Concordat posture: " + GetImperialConcordatLabel() + "."
    if StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") > 0
        text = text + " Civic service has been counted."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") > 0
        text = text + " Private Talos pressure is present."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") > 0
        text = text + " Public Talos pressure is present."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") > 0
        text = text + " Patron civic favor has been noticed."
    endIf
    if PDV_Talos
        Float talosMultiplier = GetTalosEffectiveGainMultiplier()
        if talosMultiplier > 1.0
            text = text + " Talos pressure is leaning defiant."
        elseIf talosMultiplier < 1.0
            text = text + " Talos pressure is constrained by the Concordat."
        else
            text = text + " Talos pressure is not presently tilted."
        endIf
    endIf

    if PDV_ConcordatStandingTrack && PDV_ConcordatStandingTrack.HasExtremeResetGate()
        text = text + " A repair gate has opened."
    endIf

    String curseLabel = GetImperialCursePostureLabel()
    if curseLabel != ""
        text = text + " Curse posture: " + curseLabel + "."
    endIf
    return text
EndFunction

String Function GetImperialConcordatLabel()
    if PDV_ConcordatStandingTrack
        return PDV_ConcordatStandingTrack.GetStateLabel()
    endIf

    return "Uncommitted"
EndFunction

String Function GetImperialCursePostureLabel()
    if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 2
        return "civic faith halted"
    elseIf PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 1
        return "civic faith strained"
    endIf

    return ""
EndFunction

Bool Function IsAltmerVampireExiled()
    if GetPlayerOriginRaceIndex() != ORIGIN_ALTMER
        return False
    endIf

    if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileActive") == 1
EndFunction

Bool Function IsAltmerWerewolfHalted()
    if GetPlayerOriginRaceIndex() != ORIGIN_ALTMER
        return False
    endIf

    if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 1
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHalt") == 1
EndFunction

Bool Function HasAltmerVampireExileScar()
    return GetPlayerOriginRaceIndex() == ORIGIN_ALTMER && StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileScar") == 1
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
    summary = summary + "; ArgonianHist=" + GetArgonianHistSummary()
    summary = summary + "; Altmer=" + GetAltmerSummary()
    summary = summary + "; Orc=" + GetOrcSummary()
    summary = summary + "; Redguard=" + GetRedguardSummary()
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

    return PDV_BosmerPathTrack.GetStateLabel() + ";offered=" + PDV_BosmerPathTrack.GetOfferedStateLabel() + ";pending=" + PDV_BosmerPathTrack.GetPendingStateLabel() + ";pact=" + BoolToInt(IsBosmerPactBound()) + ";gpc=" + GetBosmerGreenPactCompliance() + ";lapsed=" + GetBosmerLapsedFromPact() + ";gp=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount") + ";penalty=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive") + ";favor=" + GetBosmerFavorSummary()
EndFunction

String Function GetBosmerFavorSummary()
    return "oc=" + GetBosmerFavorCount("OldContract.ProperHunt") + "/" + GetBosmerFavorCount("OldContract.ForestKept") + ";ls=" + GetBosmerFavorCount("LivingStory.CommunityKept") + "/" + GetBosmerFavorCount("LivingStory.NatureSite") + ";ex=" + GetBosmerFavorCount("Exchange.DebtSettled") + "/" + GetBosmerFavorCount("Exchange.ProportionateVengeance") + ";br=" + GetBosmerFavorCount("BanditRoad.RoadLife") + "/" + GetBosmerFavorCount("BanditRoad.Reversal")
EndFunction

Int Function GetBosmerFavorCount(String favorKey)
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.Favor." + favorKey + ".Count")
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

    return PDV_KhajiitLunarSubstrate.GetPilotSummary() + "; focus=" + GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()) + "; kh=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_KHENARTHI)) + "; az=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_AZURAH)) + "; bd=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_BAANDAR)) + "; rj=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_RAJHIN)) + "; ak=" + FormatTwoDecimals(GetKhajiitFocusWeight(KHAJIIT_FOCUS_ALKOSH))
EndFunction

String Function GetArgonianHistSummary()
    if !PDV_ArgonianHistSubstrate
        return "missing"
    endIf

    return PDV_ArgonianHistSubstrate.GetPilotSummary()
EndFunction

String Function GetOrcSummary()
    if !PDV_OrcLifeModeTrack
        return "missing"
    endIf

    return "mode=" + GetOrcLifeModeLabel() + ";stronghold=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.Stronghold")) + ";city=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.City")) + ";legion=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.LegionExile")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Orc.LastLifeModeReason")
EndFunction

String Function GetRedguardSummary()
    if !PDV_RedguardSectTrack
        return "missing"
    endIf

    return "sect=" + GetRedguardSectLabel() + ";crown=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Crown")) + ";forebear=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Forebear")) + ";ashabah=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.AshAbah")) + ";farShores=" + FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Redguard.LastSectReason")
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
    return "origin=" + GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + ";bosmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Bosmer.RoutePressure") + ";breton=" + StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState") + ";dunmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture") + ";argonian=" + StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.HistPosture") + ";orc=" + StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure") + ";redguard=" + StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure") + ";altmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Altmer.ExilePressure") + ";altmerVampire=" + StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileActive") + ";altmerWerewolf=" + StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHalt")
EndFunction

String Function GetOriginRaceLabel(Int originRace)
    if originRace == ORIGIN_NORD
        return "Nord"
    elseIf originRace == ORIGIN_IMPERIAL
        return "Imperial"
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
    elseIf originRace == ORIGIN_ARGONIAN
        return "Argonian"
    elseIf originRace == ORIGIN_ORC
        return "Orc"
    elseIf originRace == ORIGIN_REDGUARD
        return "Redguard"
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

    Bool rivalToastShown = False
    Int i = 0
    Int rivalCount = rivalForms.Length
    while i < rivalCount
        if i < rivalMultipliers.Length
            PDV_DeityBase rivalDeity = rivalForms[i] as PDV_DeityBase
            Float rivalAmount = sourceAmount * rivalMultipliers[i] * -1.0

            if rivalDeity && rivalAmount != 0.0
                AwardPietyInternal(rivalDeity, rivalAmount, False)

                if !rivalToastShown
                    SendPrismaEventToast("rivalry", sourceDeity, "", "", rivalDeity.DeityName)
                    rivalToastShown = True
                endIf

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

Float Function ThresholdForTier(PDV_DeityBase deity, Int tierValue)
    if !deity
        return 0.0
    endIf

    if tierValue >= TIER_CHAMPION
        return deity.ThresholdChampion
    elseIf tierValue >= TIER_DEVOTED
        return deity.ThresholdDevoted
    elseIf tierValue >= TIER_SEEKER
        return deity.ThresholdSeeker
    endIf

    return 0.0
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

