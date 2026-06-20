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
GlobalVariable Property PDV_GLO_State_BretonDruidicFork Auto

FormList Property PDV_FLST_AllDeities Auto
FormList Property PDV_FLST_DaedricPaths_All Auto
String Property QUEST_REACTION_MATRIX_FILE = "PlayerDevotion/PDV_QuestReactionMatrix" AutoReadOnly
; List-patch second channel (e.g. Authoria/ARR). Cells are read from whichever
; channel owns the (form|stage) key; shared stance/value tables stay on core.
String Property QUEST_REACTION_MATRIX_FILE_ARR = "PlayerDevotion/PDV_QuestReactionMatrix_ARR" AutoReadOnly

PDV_Deity_Kyne Property PDV_Kyne Auto
PDV_Deity_Talos Property PDV_Talos Auto
PDV_Deity_Yffre Property PDV_Yffre Auto
PDV_Deity_Zen Property PDV_Zen Auto
PDV_Deity_BaanDar Property PDV_BaanDar Auto
; Khajiit focused-emphasis deities (Azura/BaanDar are shared cross-race; per-race stance).
PDV_Deity_Azura Property PDV_Azura Auto
PDV_Deity_Khenarthi Property PDV_Khenarthi Auto
PDV_Deity_Rajhin Property PDV_Rajhin Auto
PDV_Deity_Alkosh Property PDV_Alkosh Auto
; Dunmer-owned Reclamation patrons. Azura is shared with Khajiit and reused above.
PDV_Deity_Boethiah Property PDV_Boethiah Auto
PDV_Deity_Mephala Property PDV_Mephala Auto
; Argonian substrate / no-offer scripted patrons (Hist primary pulse + high-threshold Sithis).
PDV_Deity_Hist Property PDV_Hist Auto
PDV_Deity_Sithis Property PDV_Sithis Auto
; Orc spine and shared Trinimac pressure record.
PDV_Deity_Malacath Property PDV_Malacath Auto
PDV_Deity_Trinimac Property PDV_Trinimac Auto
; Redguard Yokudan patrons.
PDV_Deity_Tuwhacca Property PDV_Tuwhacca Auto
PDV_Deity_HoonDing Property PDV_HoonDing Auto
PDV_Deity_Leki Property PDV_Leki Auto
; Nord Old Ways patrons. Kyne/Talos are reused above.
PDV_Deity_Shor Property PDV_Shor Auto
PDV_Deity_Tsun Property PDV_Tsun Auto
PDV_Deity_Stuhn Property PDV_Stuhn Auto
; Imperial-owned shared Divines. Nord/Breton reuse these records by stance.
PDV_Deity_Akatosh Property PDV_Akatosh Auto
PDV_Deity_Mara Property PDV_Mara Auto
PDV_Deity_Arkay Property PDV_Arkay Auto
PDV_Deity_Stendarr Property PDV_Stendarr Auto
PDV_Deity_Zenithar Property PDV_Zenithar Auto
PDV_Deity_Dibella Property PDV_Dibella Auto
PDV_Deity_Julianos Property PDV_Julianos Auto
PDV_Deity_Kynareth Property PDV_Kynareth Auto
; Altmer offer patrons.
PDV_Deity_AuriEl Property PDV_AuriEl Auto
PDV_Deity_Magnus Property PDV_Magnus Auto
PDV_Deity_Xarxes Property PDV_Xarxes Auto
PDV_ReputationTrack Property PDV_ConcordatStandingTrack Auto
PDV_ReputationTrack Property PDV_ThalmorAlignmentTrack Auto
PDV_StateTrack Property PDV_BosmerPathTrack Auto
PDV_StateTrack Property PDV_NordPantheonBaselineTrack Auto
PDV_StateTrack Property PDV_AltmerCrisisTrack Auto
PDV_Substrate_DunmerAncestor Property PDV_DunmerAncestorSubstrate Auto
Book Property PDV_BOOK_DunmerAncestralUrn Auto
PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto
PDV_Substrate_ArgonianHist Property PDV_ArgonianHistSubstrate Auto
Book Property PDV_BOOK_ArgonianHistSapToken Auto
PDV_StateTrack Property PDV_ArgonianHistPostureTrack Auto
PDV_StateTrack Property PDV_OrcLifeModeTrack Auto
PDV_StateTrack Property PDV_RedguardSectTrack Auto
PDV_StateTrack Property PDV_KhajiitLunarPostureTrack Auto
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
Spell Property PDV_Bless_Altmer_Orthodox_T1 Auto
Spell Property PDV_Bless_Altmer_Orthodox_T2 Auto
Spell Property PDV_Bless_Altmer_AuriEl_T1 Auto
Spell Property PDV_Bless_Altmer_AuriEl_T2 Auto
Spell Property PDV_Bless_Altmer_AuriEl_T3 Auto
Spell Property PDV_Bless_Altmer_Magnus_T1 Auto
Spell Property PDV_Bless_Altmer_Magnus_T2 Auto
Spell Property PDV_Bless_Altmer_Magnus_T3 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T1 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T2 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T3 Auto
Spell Property PDV_SPEL_Neglect_Altmer Auto
Spell Property PDV_Bless_Argonian_Hist_T1 Auto
; Argonian no-offer reward families (substrate-tier gated, not active-patron gated).
Spell Property PDV_Bless_Argonian_Hist_T2 Auto
Spell Property PDV_Bless_Argonian_Hist_Signature Auto
Spell Property PDV_Bless_Argonian_People_T1 Auto
Spell Property PDV_Bless_Argonian_People_T2 Auto
Spell Property PDV_Bless_Argonian_People_T3 Auto
Spell Property PDV_SPEL_ArgonianShadowscaleVeil Auto
Spell Property PDV_SPEL_ArgonianRootedRest Auto
Message Property PDV_MESG_ArgonianMarkBed Auto
Message Property PDV_MESG_ArgonianAdaptRite Auto
Spell Property PDV_SPEL_ArgonianAdapt_Claws Auto
Spell Property PDV_SPEL_ArgonianAdapt_Skin Auto
Spell Property PDV_SPEL_ArgonianAdapt_Sap Auto
Spell Property PDV_SPEL_ArgonianAdapt_Marsh Auto
FormList Property PDV_FLST_ArgonianSacredWaters Auto

; --- Bosmer variety tranche ("The Story Goes On") ---
Spell Property PDV_SPEL_BosmerTaleCarried Auto
Spell Property PDV_SPEL_BosmerScalesAtRest Auto
Spell Property PDV_SPEL_BosmerBaanDarGap Auto
Message Property PDV_MESG_BosmerMarkHearth Auto
Message Property PDV_MESG_BosmerNaming Auto
Spell Property PDV_SPEL_BosmerNaming_Hunter Auto
Spell Property PDV_SPEL_BosmerNaming_Speaker Auto
Spell Property PDV_SPEL_BosmerNaming_Wanderer Auto
Spell Property PDV_SPEL_BosmerNaming_Keeper Auto
FormList Property PDV_FLST_BosmerGreenSongs Auto

; Debug seed harness (SetPQV path; cqf is unreliable). Set the three values,
; then flip DebugSeedGo to 1; the OnUpdate tick applies the seed and resets it.
Float Property DebugSeedHist Auto Hidden
Float Property DebugSeedPeople Auto Hidden
Float Property DebugSeedVoid Auto Hidden
Int Property DebugSeedGo Auto Hidden
; Extended Argonian debug seeds (applied on the same DebugSeedGo tick; each self-
; resets). Re-authored 2026-06-20 against the CURRENT manager's StorageUtil keys
; after a mod restore reverted the 06-19 originals. DeclareHomeNow: declare current
; cell as home + clear adaptation + re-arm the rite clock. BedCount: set rooted-rest
; sleep count (>=12 arms Rooted Rest). ArgWatersCount: set sacred-waters count
; (size-1 arms the all-six milestone on the next NEW site). AdaptDueNow: mature the
; 10-14 day adaptation rite clock to "due now" (sets PDV.Adapt.DueDay = today+1).
Int Property DebugSeedDeclareHomeNow Auto Hidden
Int Property DebugSeedBedCount Auto Hidden
Int Property DebugSeedArgWatersCount Auto Hidden
Int Property DebugSeedAdaptDueNow Auto Hidden
; Phase 0 Prisma choice-panel proof trigger (SetPQV path, like the seeds above):
;   setpqv PDV__ManagerQuest DebugPrismaChoiceGo 1
; The OnUpdate tick opens a throwaway 2-option Prisma choice (non-modal) and
; reports the pick (or Esc cancel) via a top-left notification. Debug-only; proves
; the JS->C++ return channel before any rite/manager wiring.
Int Property DebugPrismaChoiceGo Auto Hidden
Spell Property PDV_Bless_Argonian_Sithis_T1 Auto
Spell Property PDV_Bless_Argonian_Sithis_T2 Auto
Spell Property PDV_Bless_Argonian_Sithis_T3 Auto
Spell Property PDV_SPEL_ArgonianSithisNearDeathBurst Auto
Spell Property PDV_SPEL_Neglect_ArgonianHist Auto
Spell Property PDV_Bless_Bosmer_Yffre_T1 Auto
Spell Property PDV_Bless_Bosmer_Yffre_T2 Auto
Spell Property PDV_Bless_Bosmer_OldContract_T1 Auto
Spell Property PDV_Bless_Bosmer_OldContract_T2 Auto
Spell Property PDV_Bless_Bosmer_OldContract_T3 Auto
Spell Property PDV_Bless_Bosmer_LivingStory_T1 Auto
Spell Property PDV_Bless_Bosmer_LivingStory_T2 Auto
Spell Property PDV_Bless_Bosmer_LivingStory_T3 Auto
Spell Property PDV_Bless_Bosmer_Exchange_T1 Auto
Spell Property PDV_Bless_Bosmer_Exchange_T2 Auto
Spell Property PDV_Bless_Bosmer_Exchange_T3 Auto
Spell Property PDV_Bless_Bosmer_BanditRoad_T1 Auto
Spell Property PDV_Bless_Bosmer_BanditRoad_T2 Auto
Spell Property PDV_Bless_Bosmer_BanditRoad_T3 Auto
Spell Property PDV_SPEL_Neglect_Bosmer Auto
Spell Property PDV_Bless_Breton_Tradition_T1 Auto
Spell Property PDV_Bless_Breton_Tradition_T2 Auto
Spell Property PDV_Bless_Breton_KnightsRoad_T1 Auto
Spell Property PDV_Bless_Breton_KnightsRoad_T2 Auto
Spell Property PDV_Bless_Breton_KnightsRoad_T3 Auto
Spell Property PDV_Bless_Breton_HiddenArt_T1 Auto
Spell Property PDV_Bless_Breton_HiddenArt_T2 Auto
Spell Property PDV_Bless_Breton_HiddenArt_T3 Auto
Spell Property PDV_Bless_Breton_GreenWay_T1 Auto
Spell Property PDV_Bless_Breton_GreenWay_T2 Auto
Spell Property PDV_Bless_Breton_GreenWay_T3 Auto
Spell Property PDV_SPEL_Neglect_Breton Auto
Spell Property PDV_SPEL_CreedLoss_Breton_VowIntegrity Auto
Spell Property PDV_SPEL_CreedLoss_Breton_ExposureRupture Auto
Spell Property PDV_SPEL_CreedLoss_Breton_Excommunication Auto
Spell Property PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal Auto
Spell Property PDV_Bless_Dunmer_Reclamation_T1 Auto
Spell Property PDV_Bless_Dunmer_Reclamation_T2 Auto
Spell Property PDV_Bless_Dunmer_Azura_T1 Auto
Spell Property PDV_Bless_Dunmer_Azura_T2 Auto
Spell Property PDV_Bless_Dunmer_Azura_T3 Auto
Spell Property PDV_Bless_Dunmer_Boethiah_T1 Auto
Spell Property PDV_Bless_Dunmer_Boethiah_T2 Auto
Spell Property PDV_Bless_Dunmer_Boethiah_T3 Auto
Spell Property PDV_Bless_Dunmer_Mephala_T1 Auto
Spell Property PDV_Bless_Dunmer_Mephala_T2 Auto
Spell Property PDV_Bless_Dunmer_Mephala_T3 Auto
Spell Property PDV_SPEL_Neglect_Dunmer Auto
Spell Property PDV_Bless_Imperial_Civic_T1 Auto
Spell Property PDV_Bless_Imperial_Civic_T2 Auto
Spell Property PDV_Bless_Imperial_Akatosh_T1 Auto
Spell Property PDV_Bless_Imperial_Akatosh_T2 Auto
Spell Property PDV_Bless_Imperial_Akatosh_T3 Auto
Spell Property PDV_Bless_Imperial_Mara_T1 Auto
Spell Property PDV_Bless_Imperial_Mara_T2 Auto
Spell Property PDV_Bless_Imperial_Mara_T3 Auto
Spell Property PDV_Bless_Imperial_Arkay_T1 Auto
Spell Property PDV_Bless_Imperial_Arkay_T2 Auto
Spell Property PDV_Bless_Imperial_Arkay_T3 Auto
Spell Property PDV_Bless_Imperial_Stendarr_T1 Auto
Spell Property PDV_Bless_Imperial_Stendarr_T2 Auto
Spell Property PDV_Bless_Imperial_Stendarr_T3 Auto
Spell Property PDV_Bless_Imperial_Zenithar_T1 Auto
Spell Property PDV_Bless_Imperial_Zenithar_T2 Auto
Spell Property PDV_Bless_Imperial_Zenithar_T3 Auto
Spell Property PDV_Bless_Imperial_Dibella_T1 Auto
Spell Property PDV_Bless_Imperial_Dibella_T2 Auto
Spell Property PDV_Bless_Imperial_Dibella_T3 Auto
Spell Property PDV_Bless_Imperial_Julianos_T1 Auto
Spell Property PDV_Bless_Imperial_Julianos_T2 Auto
Spell Property PDV_Bless_Imperial_Julianos_T3 Auto
Spell Property PDV_Bless_Imperial_Kynareth_T1 Auto
Spell Property PDV_Bless_Imperial_Kynareth_T2 Auto
Spell Property PDV_Bless_Imperial_Kynareth_T3 Auto
Spell Property PDV_Bless_Imperial_Talos_T1 Auto
Spell Property PDV_Bless_Imperial_Talos_T2 Auto
Spell Property PDV_Bless_Imperial_Talos_T3 Auto
Spell Property PDV_SPEL_Neglect_Imperial Auto
Spell Property PDV_Bless_Khajiit_Lunar_T1 Auto
; Lattice phase blessings: one small (+5 / +5%) god-themed effect per presiding
; moon phase, active only while that god presides AND the player has cultivated
; it to Faithful. None-safe until the records are authored.
Spell Property PDV_Bless_Khajiit_Phase_Khenarthi Auto
Spell Property PDV_Bless_Khajiit_Phase_Azurah Auto
Spell Property PDV_Bless_Khajiit_Phase_BaanDar Auto
Spell Property PDV_Bless_Khajiit_Phase_Rajhin Auto
Spell Property PDV_Bless_Khajiit_Phase_Alkosh Auto
; Khajiit broad lunar reward is re-homed to the substrate boon layer (Substrate_Mid);
; the per-emphasis 3-tier sets below gate on the emphasis deity's piety tier.
Spell Property PDV_Bless_Khajiit_Khenarthi_T1 Auto
Spell Property PDV_Bless_Khajiit_Khenarthi_T2 Auto
Spell Property PDV_Bless_Khajiit_Khenarthi_T3 Auto
Spell Property PDV_Bless_Khajiit_Azurah_T1 Auto
Spell Property PDV_Bless_Khajiit_Azurah_T2 Auto
Spell Property PDV_Bless_Khajiit_Azurah_T3 Auto
Spell Property PDV_Bless_Khajiit_BaanDar_T1 Auto
Spell Property PDV_Bless_Khajiit_BaanDar_T2 Auto
Spell Property PDV_Bless_Khajiit_BaanDar_T3 Auto
Spell Property PDV_Bless_Khajiit_Rajhin_T1 Auto
Spell Property PDV_Bless_Khajiit_Rajhin_T2 Auto
Spell Property PDV_Bless_Khajiit_Rajhin_T3 Auto
Spell Property PDV_Bless_Khajiit_Alkosh_T1 Auto
Spell Property PDV_Bless_Khajiit_Alkosh_T2 Auto
Spell Property PDV_Bless_Khajiit_Alkosh_T3 Auto
Spell Property PDV_SPEL_Neglect_KhajiitLunar Auto
Spell Property PDV_Bless_Nord_OldWays_T1 Auto
Spell Property PDV_Bless_Nord_OldWays_T2 Auto
Spell Property PDV_Bless_Nord_Kyne_T1 Auto
Spell Property PDV_Bless_Nord_Kyne_T2 Auto
Spell Property PDV_Bless_Nord_Kyne_T3 Auto
Spell Property PDV_Bless_Nord_Shor_T1 Auto
Spell Property PDV_Bless_Nord_Shor_T2 Auto
Spell Property PDV_Bless_Nord_Shor_T3 Auto
Spell Property PDV_Bless_Nord_Tsun_T1 Auto
Spell Property PDV_Bless_Nord_Tsun_T2 Auto
Spell Property PDV_Bless_Nord_Tsun_T3 Auto
Spell Property PDV_Bless_Nord_Stuhn_T1 Auto
Spell Property PDV_Bless_Nord_Stuhn_T2 Auto
Spell Property PDV_Bless_Nord_Stuhn_T3 Auto
Spell Property PDV_Bless_Nord_Talos_T1 Auto
Spell Property PDV_Bless_Nord_Talos_T2 Auto
Spell Property PDV_Bless_Nord_Talos_T3 Auto
Spell Property PDV_Bless_Nord_Akatosh_T1 Auto
Spell Property PDV_Bless_Nord_Akatosh_T2 Auto
Spell Property PDV_Bless_Nord_Akatosh_T3 Auto
Spell Property PDV_Bless_Nord_Mara_T1 Auto
Spell Property PDV_Bless_Nord_Mara_T2 Auto
Spell Property PDV_Bless_Nord_Mara_T3 Auto
Spell Property PDV_Bless_Nord_Arkay_T1 Auto
Spell Property PDV_Bless_Nord_Arkay_T2 Auto
Spell Property PDV_Bless_Nord_Arkay_T3 Auto
Spell Property PDV_Bless_Nord_Stendarr_T1 Auto
Spell Property PDV_Bless_Nord_Stendarr_T2 Auto
Spell Property PDV_Bless_Nord_Stendarr_T3 Auto
Spell Property PDV_Bless_Nord_Zenithar_T1 Auto
Spell Property PDV_Bless_Nord_Zenithar_T2 Auto
Spell Property PDV_Bless_Nord_Zenithar_T3 Auto
Spell Property PDV_Bless_Nord_Dibella_T1 Auto
Spell Property PDV_Bless_Nord_Dibella_T2 Auto
Spell Property PDV_Bless_Nord_Dibella_T3 Auto
Spell Property PDV_Bless_Nord_Julianos_T1 Auto
Spell Property PDV_Bless_Nord_Julianos_T2 Auto
Spell Property PDV_Bless_Nord_Julianos_T3 Auto
Spell Property PDV_Bless_Nord_Kynareth_T1 Auto
Spell Property PDV_Bless_Nord_Kynareth_T2 Auto
Spell Property PDV_Bless_Nord_Kynareth_T3 Auto
Spell Property PDV_Bless_Orc_Malacath_T1 Auto
Spell Property PDV_Bless_Orc_Malacath_T2 Auto
Spell Property PDV_Bless_Orc_Stronghold_T1 Auto
Spell Property PDV_Bless_Orc_Stronghold_T2 Auto
Spell Property PDV_Bless_Orc_Stronghold_T3 Auto
Spell Property PDV_Bless_Orc_City_T1 Auto
Spell Property PDV_Bless_Orc_City_T2 Auto
Spell Property PDV_Bless_Orc_City_T3 Auto
Spell Property PDV_Bless_Orc_LegionExile_T1 Auto
Spell Property PDV_Bless_Orc_LegionExile_T2 Auto
Spell Property PDV_Bless_Orc_LegionExile_T3 Auto
Spell Property PDV_SPEL_Neglect_Orc Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Tusk Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Shield Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Hammer Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Yoke Auto
Spell Property PDV_SPEL_OrcCodeHolds Auto
Spell Property PDV_SPEL_OrcCodeHolds_Devoted Auto
Spell Property PDV_SPEL_OrcHearthHeld Auto
Spell Property PDV_Bless_Redguard_AncestorSpine_T1 Auto
Spell Property PDV_Bless_Redguard_AncestorSpine_T2 Auto
Spell Property PDV_Bless_Redguard_Tuwhacca_T1 Auto
Spell Property PDV_Bless_Redguard_Tuwhacca_T2 Auto
Spell Property PDV_Bless_Redguard_Tuwhacca_T3 Auto
Spell Property PDV_Bless_Redguard_HoonDing_T1 Auto
Spell Property PDV_Bless_Redguard_HoonDing_T2 Auto
Spell Property PDV_Bless_Redguard_HoonDing_T3 Auto
Spell Property PDV_Bless_Redguard_Leki_T1 Auto
Spell Property PDV_Bless_Redguard_Leki_T2 Auto
Spell Property PDV_Bless_Redguard_Leki_T3 Auto
Spell Property PDV_Bless_Redguard_FarShoresToken Auto
Spell Property PDV_SPEL_Neglect_Redguard Auto
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
Message Property PDV_MSG_Confirm_Redguard_Crown Auto
Message Property PDV_MSG_Confirm_Redguard_Forebear Auto
Message Property PDV_MSG_Confirm_Redguard_Ashabah Auto
Message Property PDV_MSG_Confirm_Breton_KnightsRoad Auto
Message Property PDV_MSG_Confirm_Breton_HiddenArt Auto
Message Property PDV_MSG_Confirm_Breton_GreenWay Auto
Message Property PDV_MSG_Confirm_Orc_City Auto
Message Property PDV_MSG_Confirm_Orc_Stronghold Auto
Message Property PDV_MSG_Confirm_Orc_LegionExile Auto
Message Property PDV_MSG_Confirm_Bosmer_OldContract Auto
Message Property PDV_MSG_Confirm_Bosmer_LivingStory Auto
Message Property PDV_MSG_Confirm_Bosmer_Exchange Auto
Message Property PDV_MSG_Confirm_Bosmer_BanditRoad Auto
Message Property PDV_Msg_Nord_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireOnset Auto
Message Property PDV_Msg_Nord_CurseState_VampireCured Auto
Message Property PDV_Msg_Altmer_VampireExiledPath_Entry Auto
Message Property PDV_Msg_Altmer_VampireExiledPath_Recognition Auto
Message Property PDV_Msg_Altmer_CurseState_WerewolfHardHalt Auto
Message Property PDV_Notif_Redguard_Sect_Crown_Entry Auto
Message Property PDV_Notif_Redguard_Sect_Forebear_Entry Auto
Message Property PDV_Notif_Redguard_Sect_AshAbah_Entry Auto
Message Property PDV_Msg_Redguard_Survey_Crown Auto
Message Property PDV_Msg_Redguard_Survey_Forebear Auto
Message Property PDV_Msg_Redguard_Survey_AshAbah Auto
Message Property PDV_Msg_Redguard_ChampionEntry_Crown Auto
Message Property PDV_Msg_Redguard_ChampionEntry_Forebear Auto
Message Property PDV_Msg_Redguard_ChampionEntry_AshAbah Auto
Message Property PDV_Notif_Redguard_FarShoresToken_Activate Auto
Message Property PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold Auto
Message Property PDV_Notif_Orc_Witnessed_TheWatchers_City Auto
Message Property PDV_Notif_Orc_Witnessed_TheWatchers_LegionExile Auto
Message Property PDV_Notif_Orc_HearthHeld_Declare Auto
Message Property PDV_Notif_Orc_HearthHeld_Return Auto
Message Property PDV_Notif_Orc_HearthHeld_MissedCadence Auto
Message Property PDV_Notif_Orc_FourHolds_DushnikhYal Auto
Message Property PDV_Notif_Orc_FourHolds_MorKhazgur Auto
Message Property PDV_Notif_Orc_FourHolds_Narzulbur Auto
Message Property PDV_Notif_Orc_FourHolds_Largashbur Auto
Message Property PDV_Msg_Orc_FourHolds_Milestone Auto
Message Property PDV_Msg_Redguard_CurseState_VampireOnset Auto
Message Property PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry Auto
Message Property PDV_Msg_Redguard_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Redguard_CurseState_WerewolfCured Auto
Message Property PDV_Msg_Khajiit_CurseState_VampireOnset Auto
Message Property PDV_Msg_Khajiit_CurseState_VampireCured Auto
Message Property PDV_Msg_Khajiit_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Khajiit_CurseState_WerewolfCured Auto
Message Property PDV_Msg_Khajiit_CurseState_ShadowDriftEntry Auto
Message Property PDV_Msg_Nord_Kyne_Offer Auto
Message Property PDV_Msg_Nord_Shor_Offer Auto
Message Property PDV_Msg_Nord_Tsun_Offer Auto
Message Property PDV_Msg_Nord_Stuhn_Offer Auto
Message Property PDV_Msg_Nord_Akatosh_Offer Auto
Message Property PDV_Msg_Nord_Mara_Offer Auto
Message Property PDV_Msg_Nord_Arkay_Offer Auto
Message Property PDV_Msg_Nord_Stendarr_Offer Auto
Message Property PDV_Msg_Nord_Zenithar_Offer Auto
Message Property PDV_Msg_Nord_Julianos_Offer Auto
Message Property PDV_Msg_Nord_Dibella_Offer Auto
Message Property PDV_Msg_Nord_Talos_Offer Auto
Message Property PDV_Msg_Nord_Kynareth_Offer Auto
Message Property PDV_Msg_Nord_OfferResponse_Accept Auto
Message Property PDV_Msg_Nord_OfferResponse_NotYet Auto
Message Property PDV_Msg_Nord_OfferResponse_Refuse Auto
Message Property PDV_Msg_Nord_CurseState_WerewolfCured Auto
Message Property PDV_Notif_Nord_General_AncestorsQuiet Auto
Message Property PDV_Notif_Nord_Kyne_ChampionAmbient_Storm Auto
Message Property PDV_Msg_Nord_Kyne_ChampionEntry Auto
Message Property PDV_Msg_Argonian_CurseState_VampireOnset Auto
Message Property PDV_Msg_Argonian_CurseState_VampireCured Auto
Message Property PDV_Msg_Argonian_CurseState_WerewolfOnset Auto
Message Property PDV_Msg_Argonian_CurseState_WerewolfCured Auto

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
; Bump when PDV_DeityLikesDislikes.csv OR the stance matrix changes so existing saves reload.
Int Property LIKES_DISLIKES_VERSION = 9 AutoReadOnly
Int Property PRINCE_LD_VERSION = 3 AutoReadOnly
; Bump when the Daedric pact model changes so existing saves re-run the migration
; (v2: active-pact-only sync + milestone presentation refresh).
Int Property DAEDRIC_PACT_VERSION = 2 AutoReadOnly
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
Int Property IMPERIAL_CIVIC_UNKNOWN = 0 AutoReadOnly
Int Property IMPERIAL_CIVIC_PUBLIC_SERVICE = 1 AutoReadOnly
Int Property IMPERIAL_CIVIC_MERCY = 2 AutoReadOnly
Int Property IMPERIAL_CIVIC_LAWFUL_ORDER = 3 AutoReadOnly
Int Property IMPERIAL_CIVIC_HONEST_WORK = 4 AutoReadOnly
Int Property IMPERIAL_CIVIC_DEATH_DUTY = 5 AutoReadOnly
Int Property BRETON_TRADITION_KNIGHTS_ROAD = 0 AutoReadOnly
Int Property BRETON_TRADITION_HIDDEN_ART = 1 AutoReadOnly
Int Property BRETON_TRADITION_GREEN_WAY = 2 AutoReadOnly
Int Property BRETON_DRUIDIC_FORK_NONE = 0 AutoReadOnly
Int Property BRETON_DRUIDIC_FORK_DRUIDIC = 1 AutoReadOnly
Int Property BRETON_DRUIDIC_FORK_WEREWOLF = 2 AutoReadOnly
Int Property BRETON_DRUIDIC_FORK_BETRAYED = 3 AutoReadOnly
Int Property STARTUP_MODE_INFO_ONLY = 0 AutoReadOnly
Int Property STARTUP_MODE_EXPLICIT_CHOICE = 1 AutoReadOnly
String Property STARTUP_ADVISORY_TEXT = "In Devotion, the gods notice how you live. Your quest choices, the company you keep, your conduct in battle, and the shrines you tend are all weighed, and at each dawn your standing with the divine rises or falls. Worship can be broad, honoring many at once, but to reach the deepest devotion you must let one god become your own - and that is a turn of the heart, not a menu setting. The gods reward meaningful, varied action; repetition alone does not move them. How you live from here will shape your devotion." AutoReadOnly
Int Property ORC_LIFE_MODE_CITY = 0 AutoReadOnly
Int Property ORC_LIFE_MODE_STRONGHOLD = 1 AutoReadOnly
Int Property ORC_LIFE_MODE_LEGION_EXILE = 2 AutoReadOnly
Int Property ORC_FOUR_HOLDS_DUSHNIKH_YAL = 1 AutoReadOnly
Int Property ORC_FOUR_HOLDS_MOR_KHAZGUR = 2 AutoReadOnly
Int Property ORC_FOUR_HOLDS_NARZULBUR = 3 AutoReadOnly
Int Property ORC_FOUR_HOLDS_LARGASHBUR = 4 AutoReadOnly
Int Property REDGUARD_SECT_CROWN = 0 AutoReadOnly
Int Property REDGUARD_SECT_FOREBEAR = 1 AutoReadOnly
Int Property REDGUARD_SECT_ASHABAH = 2 AutoReadOnly
Int Property NORD_BASELINE_OLD_WAYS = 0 AutoReadOnly
Int Property NORD_BASELINE_NINE_DIVINES = 1 AutoReadOnly
Int Property NORD_ROUTE_UNKNOWN = 0 AutoReadOnly
Int Property NORD_ROUTE_OLD_SKY_ROAD = 1 AutoReadOnly
Int Property NORD_ROUTE_OLD_ORDEAL = 2 AutoReadOnly
Int Property NORD_ROUTE_OLD_HEARTH = 3 AutoReadOnly
Int Property NORD_ROUTE_OLD_ANCESTOR = 4 AutoReadOnly
Int Property NORD_ROUTE_OLD_TALOS = 5 AutoReadOnly
Int Property NORD_ROUTE_NINE_ROAD = 6 AutoReadOnly
Int Property NORD_ROUTE_NINE_MERCY = 7 AutoReadOnly
Int Property NORD_ROUTE_NINE_DEATH = 8 AutoReadOnly
Int Property NORD_ROUTE_NINE_WORK = 9 AutoReadOnly
Int Property NORD_ROUTE_NINE_TALOS = 10 AutoReadOnly
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

Int Property KHAJIIT_LUNAR_POSTURE_NORMAL = 0 AutoReadOnly
Int Property KHAJIIT_LUNAR_POSTURE_STRAINED = 1 AutoReadOnly
Int Property KHAJIIT_LUNAR_POSTURE_CORRUPTED = 2 AutoReadOnly
Int Property KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT = 3 AutoReadOnly
Int Property KHAJIIT_SHADOWDRIFT_EVIDENCE_REQUIRED = 3 AutoReadOnly
Int Property KHAJIIT_SHADOWDRIFT_EVIDENCE_WINDOW = 7 AutoReadOnly
Float Property KHAJIIT_FOCUS_THRESHOLD = 50.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_LEAD_REQUIRED = 15.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_SIGNAL_DELTA = 25.0 AutoReadOnly
; Focus weight a quest-reaction piety award contributes to the Khajiit focused
; emphasis (the matrix->focus bridge). Smaller than a dedicated edge signal so a
; single quest cannot lock a focus; a milestone reaction counts double. With
; THRESHOLD 50 / LEAD 15, this means roughly a full questline (e.g. the Thieves
; Guild for Rajhin) establishes the lead, not one quest. Behavior-driven focus
; per the LOCKED Khajiit design sheet (moons are the substrate; behavior leads).
Float Property KHAJIIT_FOCUS_MATRIX_DELTA = 6.0 AutoReadOnly
; Layer 2: extra piety multiplier toward a Khajiit focus god while the current
; moon phase aligns to it and that god has reached Faithful (tier 2). Small by
; design -- the moons favor a cultivated god, they do not replace the work.
Float Property KHAJIIT_LUNAR_ALIGNMENT_BONUS = 0.10 AutoReadOnly
Float Property KHAJIIT_LUNAR_NEGLECT_GRACE_DAYS = 3.0 AutoReadOnly
; Argonian no-offer reward gating (substrate-relation thresholds + Hist-distance neglect grace).
Float Property ARGONIAN_HIST_NEGLECT_GRACE_DAYS = 3.0 AutoReadOnly
Float Property ARGONIAN_REWARD_T1_THRESHOLD = 25.0 AutoReadOnly
Float Property ARGONIAN_REWARD_T2_THRESHOLD = 50.0 AutoReadOnly
Float Property ARGONIAN_REWARD_SIGNATURE_THRESHOLD = 75.0 AutoReadOnly
Float Property ARGONIAN_REWARD_T3_THRESHOLD = 85.0 AutoReadOnly
Int Property ARGONIAN_FOCUS_NONE = 0 AutoReadOnly
Int Property ARGONIAN_FOCUS_PEOPLE = 1 AutoReadOnly
Int Property ARGONIAN_FOCUS_VOID = 2 AutoReadOnly
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
Bool _dawnHadActivity = False
Bool Property AutoPushPrismaPanel = False Auto
Bool Property AllowPrismaBlockingSurfaces = False Auto
PDV_DaedricPathBase _pendingDaedricMilestonePath = None
Int _pendingDaedricMilestoneOldTier = 0
Int _pendingDaedricMilestoneNewTier = 0
String _pendingDaedricMilestoneReason = ""
Bool _pendingDaedricMilestoneReplayChampionOffer = False
Int _pendingDaedricMilestoneDelayTicks = 0
String _pendingPrismaToastRetryPayload = ""
String _pendingPrismaToastRetryLabel = ""
Int _pendingPrismaToastRetryDelayTicks = 0

Event OnInit()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    RegisterManagerShoutSignals()
    EnsureLikesDislikesTable()
    EnsurePrinceLikesDislikesTable()
    MigrateDaedricPactsIfNeeded()
    RefreshPatronMirrors()
    UpdateContextualFavorRuntime()
    EnsureSurveyDevotionPower()
    EnsureDunmerAncestralUrn()
    EnsureArgonianHistSapToken()
    RequestPanelRefresh()
    HandleDiegeticLoad("init")
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    ; Time-sensitive every tick: contextual-favor expiry must clear promptly, and
    ; the one-time unified startup choice must fire promptly once the origin
    ; resolves (it self-disables via a StorageUtil flag after it completes).
    EnsureUnifiedStartupChoice()
    UpdateContextualFavorRuntime()
    if !_diegeticLoadHandled
        HandleDiegeticLoad("update")
    endIf
    ProcessQueuedDaedricMilestonePresentation()
    ProcessQueuedPrismaToastRetry()

    if _panelDirty && AutoPushPrismaPanel && PDV_PrismaBridge.IsAvailable()
        PushDevotionPanel()
        _panelDirty = False
    endIf

    if DebugCommand != 0
        RunDebugCommand()
    endIf

    ; Idempotent identity/track/power reconciliation is self-healing but never
    ; changes second-to-second (it is also performed once in OnInit). Re-confirm
    ; it on the slower 10s cadence already used by the shout-signal refresh
    ; instead of every tick, to cut redundant per-tick cross-script external
    ; calls (~10x fewer). Favor expiry above stays at the 1s tick.
    _shoutRefreshTicks += 1
    if _shoutRefreshTicks >= 10
        EnsurePhase8RuntimeWiring()
        EnsureBosmerRuntimeWiring()
        EnsureNordRuntimeWiring()
        EnsureSurveyDevotionPower()
        EnsureDunmerAncestralUrn()
        EnsureArgonianHistSapToken()
        RegisterManagerShoutSignals()
        EnsureLikesDislikesTable()
        EnsurePrinceLikesDislikesTable()
        MigrateDaedricPactsIfNeeded()
        _shoutRefreshTicks = 0
    endIf

    ; Auto daily dawn: nothing else triggers ProcessDawn in normal play (its only
    ; other callers are debug), so detect the in-game day rollover here on the same
    ; day-int boundary the anti-farm gates use and consolidate once per day. Lazy
    ; baseline (Init flag) handles existing saves where OnInit does not re-run.
    ; Fire at ~06:00 (dawn), not midnight: subtract 0.25 day (6h) before the day-int
    ; truncation so the rollover lands at dawn. 0.25 = 6/24; use 5.0/24.0 for 05:00.
    Float pdvDawnAdjustedTime = Utility.GetCurrentGameTime() - 0.25
    Int pdvCurrentDawnDay = pdvDawnAdjustedTime as Int
    if StorageUtil.GetIntValue(None, "PDV.DawnAuto.Init") == 0
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.Init", 1)
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.LastDay", pdvCurrentDawnDay)
    elseIf pdvCurrentDawnDay > StorageUtil.GetIntValue(None, "PDV.DawnAuto.LastDay")
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.LastDay", pdvCurrentDawnDay)
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auto-dawn: day rollover to " + pdvCurrentDawnDay + "; running ProcessDawn.")
        endIf
        ProcessDawn()
    endIf

    TryArgonianEldergleamInterior()
    TryArgonianNearWaterMaintenance()
    TryBosmerEldergleamInterior()
    TryBosmerGildergreenProximity()

    if DebugSeedGo != 0
        DebugSeedGo = 0
        DebugSeedArgonian(DebugSeedHist, DebugSeedPeople, DebugSeedVoid)

        ; --- Argonian extended seeds (debug-only; each self-resets) ---

        ; (1) Declare the player's CURRENT cell as their Argonian home now (skip the
        ; settle), and reset any active adaptation. Home identity is the parent-cell
        ; FormID, matching TryArgonianBedOfChoiceSleep.
        if DebugSeedDeclareHomeNow != 0
            DebugSeedDeclareHomeNow = 0
            Actor seedPlayer = Game.GetPlayer()
            Int seedCellId = 0
            Cell seedCell = seedPlayer.GetParentCell()
            if seedCell
                seedCellId = seedCell.GetFormID()
            endIf
            if seedCellId != 0
                SetArgonianHome(seedPlayer, seedCellId, Utility.GetCurrentGameTime() as Int, "debug_seed")
                Debug.Notification("PDV seed: this cell is now your Argonian home; adaptation cleared, rite clock re-armed.")
            else
                Debug.Notification("PDV seed: no parent cell; home not declared.")
            endIf
        endIf

        ; (2) Set the rooted-rest / bed-of-choice sleep count (>=12 arms Rooted Rest).
        ; MUST be held on the substrate form -- the Rooted Rest gate reads it there, NOT None.
        if DebugSeedBedCount != 0
            Int seedBed = DebugSeedBedCount
            DebugSeedBedCount = 0
            if PDV_ArgonianHistSubstrate
                StorageUtil.SetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", seedBed)
                Debug.Notification("PDV seed: bed-of-choice sleep count set to " + seedBed + ".")
            else
                Debug.Notification("PDV seed: Argonian substrate not wired; bed count unchanged.")
            endIf
        endIf

        ; (3) Set the sacred-waters running count (held on None). Seed to size-1 to make
        ; the next NEW (unseen) site trip the all-six milestone.
        if DebugSeedArgWatersCount != 0
            Int seedWaters = DebugSeedArgWatersCount
            DebugSeedArgWatersCount = 0
            StorageUtil.SetIntValue(None, "PDV.ArgWaters.Count", seedWaters)
            Debug.Notification("PDV seed: sacred-waters count set to " + seedWaters + ".")
        endIf

        ; (4) Mature the adaptation rite's 10-14 day clock to "due now" so the next
        ; qualifying sleep fires it (the rite still needs composite>=75 + no active
        ; adaptation; see TryArgonianAdaptationRite).
        if DebugSeedAdaptDueNow != 0
            DebugSeedAdaptDueNow = 0
            ; Mature the 10-14 day rite clock to "due now" (DueDay stored as today+1
            ; so the rite's todayDay >= dueDay-1 check passes on the next sleep). The
            ; rite still needs composite>=75 (seed DebugSeedHist) + no active adaptation;
            ; sleep at the declared home or a sacred water to fire it.
            StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", (Utility.GetCurrentGameTime() as Int) + 1)
            Debug.Notification("PDV seed: adaptation rite clock matured (due now); fires next sleep at home or a sacred water if composite>=75 and no active adaptation.")
        endIf
    endIf

    Phase0PrismaChoiceTick()

    RegisterForSingleUpdate(1.0)
EndEvent

; --- Phase 0 Prisma choice-panel round-trip proof (throwaway) ----------------
; Trigger: setpqv PDV__ManagerQuest DebugPrismaChoiceGo 1 (fresh launch after the
; DLL + PDV_PrismaBridge.pex + app.js are in place). Presents a 2-option grid via
; the Prisma choice channel (non-modal: pauseGame=false so this tick keeps running
; as a watchdog). The pick polls back on a later tick; ESC/cancel returns -1; a
; ~20s watchdog force-releases a stuck panel. Proves the return channel + escape
; before any rite/manager flow. Not gated by AllowPrismaBlockingSurfaces -- debug.
Function Phase0PrismaChoiceTick()
    if DebugPrismaChoiceGo != 0
        DebugPrismaChoiceGo = 0
        if !PDV_PrismaBridge.IsAvailable() || !PDV_PrismaBridge.SupportsChoice()
            Debug.Notification("PDV Phase 0: Prisma choice channel unavailable (rebuild the DLL). No round trip.")
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
            return
        endIf
        String optionsJson = "{\"choice\":{\"menu\":\"phase0_test\",\"title\":\"Phase 0 round-trip test\",\"prompt\":\"Pick an option, or press Esc to cancel.\",\"options\":[{\"index\":0,\"label\":\"Option A\"},{\"index\":1,\"label\":\"Option B\"}]}}"
        ; pauseGame=false on purpose: a paused game freezes this 1s OnUpdate
        ; watchdog, so a modal trap would be unrecoverable. Phase 0 stays non-modal.
        if PDV_PrismaBridge.ShowChoice("phase0_test", optionsJson, false)
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "phase0_test")
            StorageUtil.SetIntValue(None, "PDV.Phase0Choice.Ticks", 0)
        else
            Debug.Notification("PDV Phase 0: ShowChoice failed to open the panel.")
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
        endIf
        return
    endIf

    String pendingMenu = StorageUtil.GetStringValue(None, "PDV.Phase0Choice.Pending")
    if pendingMenu == ""
        return
    endIf
    Int status = PDV_PrismaBridge.ConsumePendingChoice(pendingMenu)
    if status == -2
        ; Watchdog: force-release if no pick within ~20 ticks (~20s) so a stuck
        ; panel never strands the player. Only effective because pauseGame=false.
        Int ticks = StorageUtil.GetIntValue(None, "PDV.Phase0Choice.Ticks") + 1
        StorageUtil.SetIntValue(None, "PDV.Phase0Choice.Ticks", ticks)
        if ticks >= 20
            PDV_PrismaBridge.CancelChoice()
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
            Debug.Notification("PDV Phase 0: watchdog forced unfocus after timeout.")
        endIf
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
    if status == -1
        Debug.Notification("PDV Phase 0: CANCELLED (Esc/cancel round trip OK).")
    elseIf status >= 0
        Debug.Notification("PDV Phase 0: picked option " + status + " (round trip OK).")
    else
        Debug.Notification("PDV Phase 0: no result (status " + status + ").")
    endIf
EndFunction

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
            labels[0] = "the Old Contract"
            labels[1] = "the Living Story"
            labels[2] = "the Exchange"
            labels[3] = "the Bandit Road"
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

String Function ResolveQuestReactionCellFile(String cellPrefix)
    ; Return the matrix channel that owns this (form|stage) cell: core first, then
    ; any list-patch channel. Returns "" when no channel has the cell.
    if JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, cellPrefix + "deitiesCsv") != ""
        return QUEST_REACTION_MATRIX_FILE
    endIf
    if JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE_ARR) && JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE_ARR, cellPrefix + "deitiesCsv") != ""
        return QUEST_REACTION_MATRIX_FILE_ARR
    endIf
    return ""
EndFunction

Function ApplyQuestReaction(Quest sourceQuest, Int stageValue)
    if !sourceQuest
        return
    endIf

    String reactionKey = sourceQuest.GetFormID() + "|" + stageValue
    String cellPrefix = "quest." + reactionKey + "."
    String matrixFile = ResolveQuestReactionCellFile(cellPrefix)
    if matrixFile == ""
        return
    endIf

    String deitiesCsv = JsonUtil.GetStringValue(matrixFile, cellPrefix + "deitiesCsv")
    String[] deityNames = StringUtil.Split(deitiesCsv, "|")
    String[] valences = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "valencesCsv"), "|")
    String[] intensities = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "intensitiesCsv"), "|")
    String[] magnitudes = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "magnitudesCsv"), "|")
    String[] sourceTags = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "tagsCsv"), "|")
    Int cellCount = deityNames.Length
    if cellCount <= 0
        return
    endIf

    Int i = 0
    while i < cellCount
        if i < valences.Length && i < intensities.Length && i < magnitudes.Length && i < sourceTags.Length
            ApplyDeityReaction(deityNames[i], valences[i], intensities[i], magnitudes[i], sourceTags[i], False, sourceQuest as Form)
        endIf
        i += 1
    endWhile

    StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastKey", reactionKey)
    StorageUtil.SetIntValue(None, "PDV.QuestReaction.LastCellCount", cellCount)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] QuestReaction: " + reactionKey + " applied " + cellCount + " cells.")
    endIf
EndFunction

Function ApplyQuestReactionFaucet(String faucetKey, Form sourceForm)
    if faucetKey == "" || !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        return
    endIf

    String deityName = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".deity")
    if deityName == ""
        return
    endIf

    String valence = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".valence")
    String intensity = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".intensity")
    String magnitude = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".magnitude")
    String sourceTag = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".tag")
    ApplyDeityReaction(deityName, valence, intensity, magnitude, sourceTag, True, sourceForm)
EndFunction

Function ApplyDeityReaction(String deityName, String valence, String intensity, String magnitude, String sourceTag, Bool isFaucet, Form sourceForm)
    PDV_DeityBase deity = GetQuestReactionDeity(deityName)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] QuestReaction skipped unknown deity: " + deityName)
        endIf
        return
    endIf

    Float amount = GetQuestReactionBaseValue(magnitude, intensity)
    if amount == 0.0
        return
    endIf

    if valence == "-"
        amount = amount * -1.0
    endIf

    if isFaucet && !MarkQuestReactionFaucet(deityName, sourceTag, sourceForm)
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] QuestReaction faucet repeat blocked: " + deityName + " " + sourceTag)
        endIf
        return
    endIf

    String stance = GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastCurse", deityName + "." + sourceTag)
        HandleCurseStateRefresh("quest_reaction_" + deityName)
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] QuestReaction curse routed: " + deityName + " " + sourceTag)
        endIf
        return
    endIf

    if stance == "TABOO" || stance == "HOSTILE"
        if amount > 0.0
            ApplyQuestReactionStigma(deity, amount, sourceTag)
        endIf
        return
    endIf

    Float multiplier = 1.0
    if stance == "FOREIGN"
        multiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.FOREIGN", 0.4)
    elseIf stance == "TOLERATED"
        multiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.TOLERATED", 0.4)
    endIf

    ApplyQuestReactionPiety(deity, amount * multiplier, deityName + "." + sourceTag)

    ; Bridge: a positive quest reaction for a Khajiit-focus deity also tilts which
    ; moon-path leads, so the matrix's existing Baan Dar / Rajhin / Alkosh /
    ; Khenarthi / Azurah cells drive the focused-emphasis system. Piety is already
    ; awarded above; this adds focus weight only. Behavior-driven focus per the
    ; LOCKED Khajiit design sheet.
    if amount > 0.0 && IsKhajiitOrigin()
        BridgeKhajiitMatrixFocus(deityName, magnitude)
    endIf
EndFunction

; Maps a quest-reaction deity name to its Khajiit focused-emphasis value, or
; KHAJIIT_FOCUS_NONE if the deity is not one of the five Khajiit focus paths.
Int Function GetKhajiitFocusForDeityName(String deityName)
    if deityName == "Khenarthi"
        return KHAJIIT_FOCUS_KHENARTHI
    elseIf deityName == "Azurah" || deityName == "Azura"
        return KHAJIIT_FOCUS_AZURAH
    elseIf deityName == "Baan Dar"
        return KHAJIIT_FOCUS_BAANDAR
    elseIf deityName == "Rajhin"
        return KHAJIIT_FOCUS_RAJHIN
    elseIf deityName == "Alkosh"
        return KHAJIIT_FOCUS_ALKOSH
    endIf

    return KHAJIIT_FOCUS_NONE
EndFunction

; Adds focus weight (not piety) toward a Khajiit emphasis from a matrix quest
; reaction. Milestone reactions count double. Carries its own per-deity daily
; anti-farm so repeating the same quest family does not slam a focus into the lead.
Function BridgeKhajiitMatrixFocus(String deityName, String magnitude)
    Int focusValue = GetKhajiitFocusForDeityName(deityName)
    if focusValue == KHAJIIT_FOCUS_NONE
        return
    endIf

    Float base = KHAJIIT_FOCUS_MATRIX_DELTA
    if magnitude == "milestone"
        base = KHAJIIT_FOCUS_MATRIX_DELTA * 2.0
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMatrixFocus." + deityName)
    if multiplier <= 0.0
        return
    endIf

    AdjustKhajiitFocusedEmphasis(focusValue, base * multiplier, "matrix_focus_" + deityName)
    Trace(2, "Khajiit matrix focus bridge: " + deityName + " focus +" + (base * multiplier))
EndFunction

; --- Lattice presiding gods ----------------------------------------------------
; The Lunar Lattice is god-aligned: each of the eight moon phases BELONGS to one
; of the five moon-path gods as part of Khajiit cosmology. The presiding god is
; always defined and always shown (flavor); its bonuses (extra piety gain and a
; small phase blessing) activate only once the player has cultivated that god to
; Faithful. The mapping lives in one place for easy tuning.
; Indices match GetKhajiitMoonPhaseFromGameDay (the real visible Skyrim phase).
Int Function GetLunarPresidingFocus(Int phaseIndex)
    if phaseIndex == 1
        return KHAJIIT_FOCUS_ALKOSH      ; full moon -- order at its height, the dragon-sun
    elseIf phaseIndex == 2
        return KHAJIIT_FOCUS_AZURAH      ; waning gibbous -- twilight descending
    elseIf phaseIndex == 3
        return KHAJIIT_FOCUS_KHENARTHI   ; last quarter -- the road in balance
    elseIf phaseIndex == 4
        return KHAJIIT_FOCUS_RAJHIN      ; waning crescent -- fading into shadow
    elseIf phaseIndex == 5
        return KHAJIIT_FOCUS_RAJHIN      ; new moon -- the deepest dark, quiet theft
    elseIf phaseIndex == 6
        return KHAJIIT_FOCUS_BAANDAR     ; waxing crescent -- the pariah's edge emerging
    elseIf phaseIndex == 7
        return KHAJIIT_FOCUS_KHENARTHI   ; first quarter -- the road in balance
    elseIf phaseIndex == 8
        return KHAJIIT_FOCUS_AZURAH      ; waxing gibbous -- twilight ascending
    endIf

    return KHAJIIT_FOCUS_NONE
EndFunction

; Inverse of GetKhajiitEmphasisDeity: resolves a deity to its Khajiit focus value.
Int Function GetKhajiitFocusForDeity(PDV_DeityBase deity)
    if !deity
        return KHAJIIT_FOCUS_NONE
    elseIf deity == PDV_Khenarthi
        return KHAJIIT_FOCUS_KHENARTHI
    elseIf deity == PDV_Azura
        return KHAJIIT_FOCUS_AZURAH
    elseIf deity == PDV_BaanDar
        return KHAJIIT_FOCUS_BAANDAR
    elseIf deity == PDV_Rajhin
        return KHAJIIT_FOCUS_RAJHIN
    elseIf deity == PDV_Alkosh
        return KHAJIIT_FOCUS_ALKOSH
    endIf

    return KHAJIIT_FOCUS_NONE
EndFunction

; Returns the focus presiding over the current moon phase (always defined for a
; Khajiit; cosmological, independent of the player's standing with that god).
Int Function GetCurrentLunarPresidingFocus()
    if !IsKhajiitOrigin()
        return KHAJIIT_FOCUS_NONE
    endIf

    return GetLunarPresidingFocus(GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()))
EndFunction

; Returns the presiding focus IF the player has cultivated that god to Faithful
; (tier 2) or better; KHAJIIT_FOCUS_NONE otherwise. Single source of truth for
; the gain multiplier, the phase blessing, and the Survey/MCM readout.
Int Function GetActiveLunarFavoredFocus()
    Int presidingFocus = GetCurrentLunarPresidingFocus()
    if presidingFocus == KHAJIIT_FOCUS_NONE
        return KHAJIIT_FOCUS_NONE
    endIf

    PDV_DeityBase deity = GetKhajiitEmphasisDeity(presidingFocus)
    if !deity || GetTier(deity) < TIER_DEVOTED
        return KHAJIIT_FOCUS_NONE
    endIf

    return presidingFocus
EndFunction

; Resolves the phase-blessing spell for a focus value (None until authored).
Spell Function GetKhajiitPhaseBlessing(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return PDV_Bless_Khajiit_Phase_Khenarthi
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return PDV_Bless_Khajiit_Phase_Azurah
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return PDV_Bless_Khajiit_Phase_BaanDar
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return PDV_Bless_Khajiit_Phase_Rajhin
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return PDV_Bless_Khajiit_Phase_Alkosh
    endIf

    return None
EndFunction

; Keeps exactly one phase blessing on the player: the presiding god's, and only
; while that god is Faithful. Re-synced at dawn (a phase lasts ~3.5 days, so the
; daily pass tracks the cycle closely enough without a dedicated tick).
Function SyncKhajiitPhaseBlessing()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Int favored = GetActiveLunarFavoredFocus()
    Int focusValue = 1
    while focusValue <= 5
        SyncRaceRewardSpell(playerRef, GetKhajiitPhaseBlessing(focusValue), focusValue == favored, "Khajiit phase blessing " + GetKhajiitFocusLabel(focusValue))
        focusValue += 1
    endWhile
EndFunction

; Dawn drip: each newly learned Word of Power nudges Alkosh emphasis (the dragon
; tongue as ordered speech). Baselines on first run so a mid-save install does
; not bulk-award the backlog; capped at 3 words per dawn, remainder carried.
Function ProcessKhajiitAlkoshWordDrip()
    if !IsKhajiitOrigin()
        return
    endIf

    Int wordsNow = Game.QueryStat("Words Of Power Learned")
    Trace(3, "Khajiit Alkosh word drip: stat reads " + wordsNow)
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
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitAlkoshWordOfPower")
        AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_ALKOSH, KHAJIIT_FOCUS_MATRIX_DELTA * multiplier, "alkosh_word_of_power")
        awarded += 1
    endWhile

    StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen", wordsSeen + awarded)
    Trace(2, "Khajiit Alkosh word-of-power drip awarded " + awarded + " of " + newWords + " new words")
    Debug.Notification("Alkosh marks the words you have learned.")
    SendPrismaShiftToast("Words marked", "Alkosh orders new words.", GetKhajiitFocusSymbol(KHAJIIT_FOCUS_ALKOSH))
    RecordRecentDevotionEvent("Alkosh: " + awarded + " words marked")
EndFunction

; Gain-pipeline multiplier for the lunar-aligned bonus (1.0 when inactive).
Float Function GetKhajiitLunarAlignmentMultiplier(PDV_DeityBase deity)
    Int favored = GetActiveLunarFavoredFocus()
    if favored != KHAJIIT_FOCUS_NONE && GetKhajiitFocusForDeity(deity) == favored
        return 1.0 + KHAJIIT_LUNAR_ALIGNMENT_BONUS
    endIf

    return 1.0
EndFunction

PDV_DeityBase Function GetQuestReactionDeity(String deityName)
    PDV_DeityBase deity = GetDeityByName(deityName)
    if deity
        return deity
    endIf

    if !PDV_FLST_DaedricPaths_All
        return None
    endIf

    Int i = 0
    Int count = PDV_FLST_DaedricPaths_All.GetSize()
    while i < count
        PDV_DeityBase path = PDV_FLST_DaedricPaths_All.GetAt(i) as PDV_DeityBase
        if path && IsQuestReactionNameMatch(path.DeityName, deityName)
            return path
        endIf
        i += 1
    endWhile

    return None
EndFunction

Bool Function IsQuestReactionNameMatch(String recordName, String requestedName)
    if recordName == requestedName
        return True
    endIf
    if requestedName == "Hermaeus Mora" && recordName == "Mora"
        return True
    endIf
    if requestedName == "Clavicus Vile" && recordName == "Vile"
        return True
    endIf
    if requestedName == "Mehrunes Dagon" && recordName == "Dagon"
        return True
    endIf
    if requestedName == "Molag Bal" && recordName == "Molag"
        return True
    endIf
    if requestedName == "Sheogorath" && recordName == "Sheo"
        return True
    endIf
    return False
EndFunction

String Function GetQuestReactionStance(String deityName, PDV_DeityBase deity)
    String raceLabel = GetOriginRaceLabel(GetPlayerOriginRaceIndex())
    String stance = JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "stance." + raceLabel + "." + deityName)
    if stance != ""
        return stance
    endIf

    Int stanceValue = deity.GetStanceForPlayer()
    if stanceValue == deity.STANCE_NATIVE
        return "NATIVE"
    elseIf stanceValue == deity.STANCE_TABOO
        return "TABOO"
    elseIf stanceValue == deity.STANCE_HOSTILE
        return "HOSTILE"
    endIf

    return "FOREIGN"
EndFunction

Float Function GetQuestReactionBaseValue(String magnitude, String intensity)
    return JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "value." + magnitude + "." + intensity, 0.0)
EndFunction

Function ApplyQuestReactionPiety(PDV_DeityBase deity, Float amount, String reason)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm || amount == 0.0
        return
    endIf

    EnsureDeityState(deity)
    StorageUtil.AdjustFloatValue(deityForm, "PDV.PietyToday", amount)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
    if amount > 0.0
        RecordCommitmentSignalDay(deity)
    endIf
    StorageUtil.SetStringValue(deityForm, "PDV.QuestReaction.LastReason", reason)
    RequestPanelRefresh()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] QuestReaction piety: " + deity.DeityName + " " + amount + " (" + reason + ")")
    endIf
EndFunction

Function ApplyQuestReactionStigma(PDV_DeityBase deity, Float amount, String reason)
    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if path
        path.AddStigma(amount, "quest_reaction_" + reason)
    else
        ApplyQuestReactionPiety(deity, amount * -1.0, "taboo_" + reason)
    endIf
EndFunction

Bool Function MarkQuestReactionFaucet(String deityName, String sourceTag, Form sourceForm)
    String capKey = "PDV.QuestReaction.Faucet." + deityName + "." + sourceTag
    if sourceTag == "forbidden_knowledge" && sourceForm
        String everKey = capKey + "." + sourceForm.GetFormID() + ".Seen"
        if StorageUtil.GetIntValue(None, everKey) == 1
            return False
        endIf
        StorageUtil.SetIntValue(None, everKey, 1)
        return True
    endIf

    Float adjustedDayTime = Utility.GetCurrentGameTime() - 0.25
    Int currentDay = adjustedDayTime as Int
    String dayKey = capKey + ".Day"
    if StorageUtil.GetIntValue(None, dayKey) == currentDay
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDay)
    return True
EndFunction

Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText)
    if !PDV_PrismaBridge.IsAvailable()
        return False
    endIf

    String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + JsonSafeString(symbolName) + "\",\"tone\":\"" + JsonSafeString(tone) + "\",\"title\":\"" + JsonSafeString(titleText) + "\",\"message\":\"" + JsonSafeString(messageText) + "\"}}"
    return PDV_PrismaBridge.SendOverlayJson(payload)
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
; Full-panel payload pushes are opt-in so gameplay events do not open or keep
; the Prisma panel visible over live play. RequestPanelRefresh still marks
; state dirty for deliberate panel debugging/manual refresh flows.
Function RequestPanelRefresh()
    _panelDirty = True
EndFunction

; --- Diegetic UX director hooks (additive). The director's D1Enabled gates all
; visible output, so these are inert at D0. SurfaceTransition self-guards via a
; StorageUtil one-shot so a transition surfaces once per direction. ---
PDV_DiegeticDirector Property PDV_DiegeticDirectorService Auto
Bool _diegeticLoadHandled = False

Function HandleDiegeticLoad(String reason)
    _diegeticLoadHandled = True
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.OnLoad()
        Trace(2, "Diegetic director load hook handled: " + reason)
    endIf
EndFunction

Function RefreshDiegeticMedallion(String reason)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.RefreshMedallion()
        Trace(2, "Diegetic medallion refresh requested: " + reason)
    endIf
EndFunction

Function NotifyDiegeticRoutineFavor(String reason)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.EmitRoutineFavor()
        Trace(2, "Diegetic routine favor refresh requested: " + reason)
    endIf
EndFunction

; Dev runtime control for the D1 diegetic surfaces. Flips the director's D1Enabled
; in-session so the visual layer can be previewed/tuned on the current save without an
; ESP edit; the ESP D1Enabled flag is the separate ship-time bake.
Bool Function DebugGetDiegeticD1Enabled()
    if PDV_DiegeticDirectorService
        return PDV_DiegeticDirectorService.D1Enabled
    endIf
    return false
EndFunction

Function DebugSetDiegeticD1Enabled(Bool enabled)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.D1Enabled = enabled
    endIf
EndFunction

Function SurfaceTransition(String eventClass, String surfaceKey, String direction, Int deityIndex = -1, String toneOverride = "")
    if eventClass == "" || surfaceKey == "" || direction == ""
        return
    endIf

    String guard = "PDV.Surfaced." + eventClass + "." + surfaceKey + "." + direction
    if StorageUtil.GetIntValue(None, guard) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, guard, 1)
    StorageUtil.SetStringValue(None, "PDV.Surfaced.Last", guard)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.Dispatch(eventClass, surfaceKey, direction, deityIndex, toneOverride)
    endIf
EndFunction

Bool Function PushDevotionPanel()
    if !AutoPushPrismaPanel
        return False
    endIf

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
    Float championThreshold = 85.0

    if _activeDeity
        titleText = _activeDeity.DeityName
        symbolName = GetPrismaSymbolForDeity(_activeDeity)
        piety = GetPiety(_activeDeity)
        pietyToday = GetPietyToday(_activeDeity)
        tierValue = GetTier(_activeDeity)
        if _activeDeity.ThresholdChampion > 0.0
            championThreshold = _activeDeity.ThresholdChampion
        endIf
    else
        ; Quasi-patron: surface the race's substrate/state-track as panel identity.
        ; Piety stays 0 for substrate races ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â there is no single scoring float.
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
    j = j + ",\"nextText\":\"" + JsonSafeString(GetPanelNextThresholdText(_activeDeity, piety)) + "\""
    j = j + ",\"piety\":" + piety
    j = j + ",\"pietyToday\":" + pietyToday
    j = j + ",\"todayMood\":\"" + JsonSafeString(GetPanelTodayMood(pietyToday)) + "\""
    j = j + ",\"driftLabel\":\"" + JsonSafeString(GetPanelDriftLabel()) + "\""
    j = j + ",\"originRace\":\"" + JsonSafeString(originLabel) + "\""
    j = j + ",\"patronState\":\"" + JsonSafeString(GetPatronStateLabel()) + "\""
    j = j + ",\"acts\":[" + GetPanelActsJson() + "]"
    j = j + ",\"rites\":[" + GetPanelRitesJson() + "]"
    j = j + ",\"relations\":[" + GetPanelRelationsJson() + "]"
    j = j + ",\"instrument\":" + GetPanelInstrumentJson(originRace, _activeDeity != None, tierValue, tierLabel, piety, championThreshold)
    j = j + ",\"debug\":" + GetPanelDebugJson()
    j = j + "}"

    return PDV_PrismaBridge.SendJson(j)
EndFunction

String Function GetPanelInstrumentJson(Int originRace, Bool hasActiveDeity, Int tierValue, String tierLabel, Float piety, Float championThreshold)
    String kindText = GetPanelInstrumentKind(originRace, hasActiveDeity)
    Float primary = 0.0
    if kindText == "piety"
        Float pietyDenom = championThreshold
        if pietyDenom <= 0.0
            pietyDenom = 85.0
        endIf
        primary = ClampValue(piety / pietyDenom, 0.0, 1.0)
    else
        primary = ClampValue((tierValue as Float) / 3.0, 0.0, 1.0)
    endIf

    String j = "{\"kind\":\"" + JsonSafeString(kindText) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + JsonSafeString(tierLabel) + "\""
    j = j + ",\"primary\":" + FormatTwoDecimals(primary)
    j = j + ",\"state\":\"" + JsonSafeString(GetPanelInstrumentState(originRace, kindText, tierLabel)) + "\""
    j = j + ",\"data\":" + GetPanelInstrumentDataJson(originRace, kindText, piety)
    j = j + "}"
    return j
EndFunction

String Function GetPanelNextThresholdText(PDV_DeityBase deity, Float piety)
    if !deity
        return ""
    endIf
    if piety < deity.ThresholdSeeker
        return "Seeker at " + (deity.ThresholdSeeker as Int)
    elseIf piety < deity.ThresholdDevoted
        return "Devoted at " + (deity.ThresholdDevoted as Int)
    elseIf piety < deity.ThresholdChampion
        return "Champion at " + (deity.ThresholdChampion as Int)
    endIf
    return "Champion path"
EndFunction

String Function GetPanelInstrumentKind(Int originRace, Bool hasActiveDeity)
    if hasActiveDeity
        return "piety"
    endIf
    if originRace == ORIGIN_KHAJIIT
        return "lunar"
    elseIf originRace == ORIGIN_ARGONIAN
        return "hist"
    elseIf originRace == ORIGIN_DUNMER
        return "ancestor"
    elseIf originRace == ORIGIN_ORC
        return "forge"
    elseIf originRace == ORIGIN_REDGUARD
        return "sects"
    elseIf originRace == ORIGIN_BOSMER
        return "branch"
    endIf
    return "piety"
EndFunction

String Function GetPanelInstrumentState(Int originRace, String kindText, String tierLabel)
    if kindText == "lunar"
        return GetPanelQuasiPatronTierLabel(originRace)
    elseIf kindText == "hist"
        return GetArgonianHistPostureLabel()
    elseIf kindText == "ancestor"
        return GetDunmerAncestorLayerLabel()
    elseIf kindText == "forge"
        return GetOrcLifeModeLabel()
    elseIf kindText == "sects"
        return GetRedguardSectLabel()
    elseIf kindText == "branch"
        return GetBosmerPathLabel()
    endIf
    return tierLabel
EndFunction

String Function GetPanelInstrumentDataJson(Int originRace, String kindText, Float piety)
    if kindText == "lunar"
        Int phase = GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
        if PDV_KhajiitLunarSubstrate && PDV_KhajiitLunarSubstrate.GetLastObservedPhase() > 0
            phase = PDV_KhajiitLunarSubstrate.GetLastObservedPhase()
        endIf
        Int focus = GetKhajiitFocusedEmphasis()
        String lunarTier = "Quiet"
        if PDV_KhajiitLunarSubstrate
            lunarTier = GetKhajiitLunarTierLabel(PDV_KhajiitLunarSubstrate.GetSubstrateTier())
        endIf
        return "{\"phase\":" + phase + ",\"focus\":\"" + JsonSafeString(GetKhajiitFocusLabel(focus)) + "\",\"lunarTier\":\"" + JsonSafeString(lunarTier) + "\"}"
    elseIf kindText == "hist"
        Float hist = 0.0
        Float people = 0.0
        Float voidValue = 0.0
        Bool voidActive = False
        if PDV_ArgonianHistSubstrate
            hist = PDV_ArgonianHistSubstrate.GetHistRelation()
            people = PDV_ArgonianHistSubstrate.GetPeopleRelation()
            voidValue = PDV_ArgonianHistSubstrate.GetVoidRelation()
            voidActive = PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        endIf
        return "{\"hist\":" + FormatTwoDecimals(hist) + ",\"people\":" + FormatTwoDecimals(people) + ",\"void\":" + FormatTwoDecimals(voidValue) + ",\"voidActive\":" + BoolToJson(voidActive) + "}"
    elseIf kindText == "ancestor"
        Int depth = 0
        Int prayer = 0
        Int home = 0
        if PDV_DunmerAncestorSubstrate
            depth = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            prayer = PDV_DunmerAncestorSubstrate.GetPrayerCount()
            home = PDV_DunmerAncestorSubstrate.GetHomeBonusCount()
        endIf
        return "{\"depth\":" + depth + ",\"prayer\":" + prayer + ",\"home\":" + home + ",\"reclamation\":\"" + JsonSafeString(GetDunmerAncestorLayerLabel()) + "\"}"
    elseIf kindText == "forge"
        return "{\"lifeMode\":\"" + JsonSafeString(GetOrcLifeModeLabel()) + "\"}"
    elseIf kindText == "sects"
        return "{\"sect\":\"" + JsonSafeString(GetRedguardSectLabel()) + "\"}"
    elseIf kindText == "branch"
        return "{\"path\":\"" + JsonSafeString(GetBosmerPathLabel()) + "\",\"pactBound\":" + BoolToJson(IsBosmerPactBound()) + ",\"evidenceDays\":" + GetBosmerPathEvidenceDays() + "}"
    endIf
    return "{\"piety\":" + FormatTwoDecimals(piety) + ",\"pietyToday\":0.00}"
EndFunction

Int Function GetBosmerPathEvidenceDays()
    if !PDV_BosmerPathTrack
        return 0
    endIf
    Int currentPath = PDV_BosmerPathTrack.GetCurrentState()
    if currentPath <= 0
        return 0
    endIf
    return PDV_BosmerPathTrack.GetRecentEvidenceDayCount(currentPath, 7)
EndFunction

String Function GetPanelPatronNote()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose a path through play, prayer, and consequence."
    endIf
    if IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    ; GetPlayerMcmModeLine handles all races ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â active patron, substrate, and
    ; state-track modes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â so it works for both deity and quasi-patron cases.
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
    ; when there is no scoring patron ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â gives the player their mode at a glance.
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
        return "sect"
    elseIf originRace == ORIGIN_BOSMER
        return "branch"
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
    return StringContainsToken(reason, "po3_book")
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

Function AwardCuratedSignalScaled(PDV_DeityBase deity, Int signalType, Form contextRef, Float multiplier)
    if multiplier <= 0.0
        return
    endIf

    if multiplier == 1.0
        AwardCuratedSignal(deity, signalType, contextRef)
        return
    endIf

    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignalScaled skipped: no deity supplied.")
        endIf
        return
    endIf

    Float delta = deity.ScoreCuratedSignal(signalType, contextRef)
    if delta == 0.0
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] AwardCuratedSignalScaled: " + deity.DeityName + " ignored signal " + signalType)
        endIf
        return
    endIf

    Float scaledDelta = delta * multiplier
    AwardPiety(deity, scaledDelta)

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardCuratedSignalScaled: " + deity.DeityName + " signal " + signalType + " delta " + scaledDelta + " multiplier " + multiplier)
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

Function HandleDaedricPrinceSignal(Int pathIndex, String sourceId)
    PDV_DaedricPathBase path = GetDaedricPathAtListIndex(pathIndex)
    if !path
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric live signal skipped: no path at index " + pathIndex)
        endIf
        return
    endIf

    if IsBlockedDaedricSourceId(sourceId)
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric live signal ignored generic source for " + path.DeityName + ": " + sourceId)
        endIf
        return
    endIf

    Int tierBefore = path.GetStoredTier()
    path.AddCommitmentSignal(sourceId)
    path.AdjustStoredPiety(10.0, sourceId)
    RefreshArgonianDominationPressureForPath(path, "daedric_" + sourceId)
    Int tierAfter = path.GetStoredTier()
    ; Hard switch: re-engaging an already-committed (but dormant) Prince makes it the
    ; single active pact again, even without a tier change. OnTierChange covers
    ; first-commit and tier-ups; this covers switch-back. A sub-threshold (tier 0)
    ; Prince never steals the active pact from a committed one.
    if tierAfter > 0 && !path.IsActiveDaedricPact()
        path.MakeActiveDaedricPact()
    endIf
    ; Player-facing fiction is owned by the path's authored MESG records, fired from
    ; PDV_DaedricPathBase.OnTierChange (tier entry) and ShowCommitmentBeat (gate open).
    ; Sub-threshold signals stay silent here, and the raw sourceId never reaches the
    ; player. Only surface the Prisma UI instrument on an actual tier gain.
    ; A tier-up grants this Prince's boon and its paired price; surface both so the
    ; gain/cost beat lands for every Prince organically, not just Hircine's bespoke
    ; hunt rite. The MCM debug page already surfaces all phases per selected Prince.
    ShowDaedricMilestonePresentation(path, tierBefore, tierAfter, False)
    RequestPanelRefresh()

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric live signal: " + path.DeityName + " index " + pathIndex + " source " + sourceId)
    endIf
EndFunction

Function HandleDaedricShrinePrayer(Int pathIndex, String sourceId)
    ; Casual once/day shrine prayer: a flat +2 to the Prince's piety, WITHOUT the
    ; commitment/tier/active-pact machinery of HandleDaedricPrinceSignal. The
    ; once-per-day gate lives on the activator (OncePerDayKey).
    PDV_DaedricPathBase path = GetDaedricPathAtListIndex(pathIndex)
    if !path
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric shrine prayer skipped: no path at index " + pathIndex)
        endIf
        return
    endIf
    path.AdjustStoredPiety(2.0, sourceId)
    RequestPanelRefresh()

    ; Player-facing confirmation. The shrine prayer is daily-repeatable and a Prince
    ; can be uncommitted (so it never surfaces in the panel), so without this the
    ; action is invisible. Top-left line always fires; the diegetic toast lane fires
    ; when D1 is enabled. We dispatch the toast directly rather than via
    ; SurfaceTransition because that helper permanently de-dups per surface key and
    ; this is a once-per-day repeat.
    Debug.Notification("You offer a prayer at the shrine of " + path.DeityName + ". " + path.DeityName + " hears you.")
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.Dispatch("prayer", path.DeityName, "offer", path.DeityIndex, "")
    endIf

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric shrine prayer: +2 " + path.DeityName + " index " + pathIndex + " source " + sourceId)
    endIf
EndFunction

; Forces a fresh disk re-read of the quest-reaction matrix channel(s) into the
; JsonUtil in-memory cache. Use after regenerating PDV_QuestReactionMatrix(_ARR)
; mid-session so already-watched quests pick up newly-authored (form|stage) cells
; without a full reload. Returns a short summary string for the MCM readout.
; NOTE: this refreshes CELL DATA only; brand-new watched quests are (re)registered
; for stage events on the next game load via RefreshP2Hooks.
String Function DebugReloadQuestMatrix()
    Int coreCells = 0
    Int arrCells = 0

    JsonUtil.Unload(QUEST_REACTION_MATRIX_FILE, false)
    if JsonUtil.Load(QUEST_REACTION_MATRIX_FILE)
        coreCells = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "questWatchFormIdsCsv"), ",").Length
    endIf

    String arrState = "absent"
    if JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE_ARR)
        JsonUtil.Unload(QUEST_REACTION_MATRIX_FILE_ARR, false)
        if JsonUtil.Load(QUEST_REACTION_MATRIX_FILE_ARR)
            arrCells = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE_ARR, "questWatchFormIdsCsv"), ",").Length
            arrState = arrCells + " watched"
        endIf
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Quest matrix reloaded: core " + coreCells + " watched, ARR " + arrState)
    endIf
    return "Quest matrix reloaded.\nCore: " + coreCells + " watched quests.\nARR channel: " + arrState + "."
EndFunction

Function HandleDaedricGenericSilenceProbe(String sourceId)
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric generic silence probe ignored: " + sourceId)
    endIf
EndFunction

Bool Function IsBlockedDaedricSourceId(String sourceId)
    return sourceId == "" || sourceId == "generic" || sourceId == "generic_combat" || sourceId == "generic_helping" || sourceId == "generic_spellcasting" || sourceId == "ordinary_travel" || sourceId == "ordinary_friendship" || sourceId == "ordinary_service" || sourceId == "debug_generic" || sourceId == "mcm_generic_probe" || sourceId == "eventbus_201_mcm_generic_probe"
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

Int Function GetDaedricPathCount()
    if !PDV_FLST_DaedricPaths_All
        return 0
    endIf

    return PDV_FLST_DaedricPaths_All.GetSize()
EndFunction

PDV_DaedricPathBase Function GetDaedricPathAtListIndex(Int listIndex)
    if listIndex < 0 || !PDV_FLST_DaedricPaths_All
        return None
    endIf

    if listIndex >= PDV_FLST_DaedricPaths_All.GetSize()
        return None
    endIf

    return PDV_FLST_DaedricPaths_All.GetAt(listIndex) as PDV_DaedricPathBase
EndFunction

PDV_DeityBase Function GetDeityByName(String deityName)
    if deityName == "" || !PDV_FLST_AllDeities
        return None
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && deity.DeityName == deityName
            return deity
        endIf
        i += 1
    endWhile

    return None
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

    if GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        HandleArgonianSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        HandleBosmerSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        HandleImperialMaraSleepMercy(playerRef)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        HandleDunmerSleepEvents(playerRef, reason)
    endIf
EndFunction

; Mara's Mercy heal-on-rest. Imperial event-driven heal authored as a flat
; RestoreActorValue (Requiem-proof) rather than a HealRateMult rate buff, which
; Requiem drives to ~0. Fires once per day when Mara is the active focused
; patron at Devoted+, scaled by tier. Rest is Requiem's intended recovery loop,
; so a mercy-on-rest reads on-design, not as re-introduced passive regen.
Function HandleImperialMaraSleepMercy(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL || !PDV_Mara
        return
    endIf
    if _activeDeity != PDV_Mara
        return
    endIf
    Int tier = GetTier(PDV_Mara)
    if tier < TIER_DEVOTED
        return
    endIf
    Int today = (Utility.GetCurrentGameTime() as Int) + 1
    if StorageUtil.GetIntValue(None, "PDV.Imperial.MaraMercyDay") == today
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Imperial.MaraMercyDay", today)
    Float healAmount = 25.0
    if tier >= TIER_CHAMPION
        healAmount = 40.0
    endIf
    playerRef.RestoreActorValue("Health", healAmount)
    Debug.Notification("You wake mended. Mara's mercy works through your rest.")
EndFunction

; Argonian sleep-exit dispatcher. Dreams fire here now; the bed-of-choice
; declaration and the adaptation rite join this entry point in later tranches.
; Fixed order: silent bookkeeping first, dream text last.
Function HandleArgonianSleepEvents(Actor playerRef, String reason)
    if !PDV_ArgonianHistSubstrate
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

; Bed-of-choice declaration and the rooted-rest wake-up. The declared bed is
; remembered as a raw FormID so no quest alias or VMAD change is needed. A new
; place must be slept in three times running before it can become home, so a
; one-night inn stop never steals the rite. A decline re-prompts only after 3 days.
; Returns true when the declaration menu was shown (the dream yields that
; night so a MessageBox and a dream toast never stack).
Bool Function TryArgonianBedOfChoiceSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return false
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if declaredId != 0 && sleepCellId == declaredId
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
        HandleArgonianBedOfChoiceReturn("declared_" + reason)
        if PDV_SPEL_ArgonianRootedRest && StorageUtil.GetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount") >= 12
            PDV_SPEL_ArgonianRootedRest.Cast(playerRef, playerRef)
            Debug.Notification("You wake feeling rooted.")
        endIf
        return false
    endIf

    if !PDV_MESG_ArgonianMarkBed
        return false
    endIf

    Int declinedDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclineDay")
    if declinedDay > 0 && (today + 1 - declinedDay) < 3
        return false
    endIf

    Int candidateId = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateFormID")
    Int candidateDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateCount")
    if candidateId != sleepCellId
        candidateCount = 1
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", sleepCellId)
    elseIf candidateDay != today + 1
        candidateCount += 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", candidateCount)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", today + 1)

    if candidateCount < 3
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_ArgonianMarkBed.Show()
    if pressed == 0
        SetArgonianHome(playerRef, sleepCellId, today, reason)
        Debug.Notification("You have made this your place of rest. The Hist remembers it now.")
    else
        StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", today + 1)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    endIf
    return true
EndFunction

Function SetArgonianHome(Actor playerRef, Int sleepCellId, Int today, String reason)
    if sleepCellId == 0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredDay", today + 1)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    if PDV_ArgonianHistSubstrate
        StorageUtil.SetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 0)
    endIf
    ClearArgonianAdaptation(playerRef)
    StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", today + Utility.RandomInt(10, 14) + 1)
    Trace(2, "Argonian home declared: " + reason)
EndFunction

Function ClearArgonianAdaptation(Actor playerRef)
    if playerRef
        RemoveArgonianAdaptationSpells(playerRef)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", 0)
    StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", 0)
EndFunction

; Hist Adaptation rite: once the player has kept a declared home at substrate
; HIGH for a randomized 10-14 in-game days, sleeping on rooted ground (the
; declared bed or a remembered water) lets the root reshape them ONCE. The clock
; is armed lazily on the first qualifying sleep; the choice is permanent once
; taken. The rite grants no piety. Returns true when the rite menu was shown so
; the dream yields that night.
Bool Function TryArgonianAdaptationRite(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !PDV_MESG_ArgonianAdaptRite || GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return false
    endIf

    if PDV_ArgonianHistSubstrate.GetMetric() < ARGONIAN_REWARD_SIGNATURE_THRESHOLD
        return false
    endIf

    Bool rooted = false
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if sleepCellId != 0 && declaredId != 0 && sleepCellId == declaredId
        rooted = true
    elseIf PDV_FLST_ArgonianSacredWaters && playerRef.GetCurrentLocation() && PDV_FLST_ArgonianSacredWaters.HasForm(playerRef.GetCurrentLocation())
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
    Int pressed = PDV_MESG_ArgonianAdaptRite.Show()
    if pressed < 0 || pressed > 3
        return true
    endIf

    ApplyArgonianAdaptation(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two adaptations at once.
Function ApplyArgonianAdaptation(Actor playerRef, Int adaptationIndex)
    RemoveArgonianAdaptationSpells(playerRef)
    Spell chosenAdaptation = GetArgonianAdaptationSpell(adaptationIndex)
    if !chosenAdaptation
        return
    endIf

    playerRef.AddSpell(chosenAdaptation, False)
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", adaptationIndex + 1)
    Debug.Notification("The Hist reshapes you. The change settles into your scales to stay.")
    Trace(2, "Argonian adaptation applied: " + adaptationIndex)
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
        return PDV_SPEL_ArgonianAdapt_Claws
    elseIf adaptationIndex == 1
        return PDV_SPEL_ArgonianAdapt_Skin
    elseIf adaptationIndex == 2
        return PDV_SPEL_ArgonianAdapt_Sap
    elseIf adaptationIndex == 3
        return PDV_SPEL_ArgonianAdapt_Marsh
    endIf

    return None
EndFunction

; Dawn-sync slot maintenance: self-heal the active adaptation if something
; stripped it, and let the root grow quiet below the signature threshold.
; PDV.Adapt.Active stays set while quiet so the change returns on its own
; when the composite recovers; no re-rite needed.
Function SyncArgonianAdaptation(Actor playerRef, Bool isArgonian)
    Int activeAdaptation = StorageUtil.GetIntValue(None, "PDV.Adapt.Active")
    if activeAdaptation <= 0
        return
    endIf

    Spell activeSpell = GetArgonianAdaptationSpell(activeAdaptation - 1)
    if !activeSpell
        return
    endIf

    Bool eligible = isArgonian && PDV_ArgonianHistSubstrate && PDV_ArgonianHistSubstrate.GetMetric() >= ARGONIAN_REWARD_SIGNATURE_THRESHOLD
    if eligible
        if !playerRef.HasSpell(activeSpell)
            playerRef.AddSpell(activeSpell, False)
        endIf
    else
        if playerRef.HasSpell(activeSpell)
            playerRef.RemoveSpell(activeSpell)
            Debug.Notification("The root grows quiet. The change fades from your scales.")
        endIf
    endIf
EndFunction

; Waters That Remember: curated sacred-water locations greet an Argonian once,
; each a one-shot vision beat with a small one-shot Hist pulse. Permanent
; one-shot keys make this inherently anti-farm.
Function HandleArgonianSacredWaterDiscovery(Location discoveredLocation)
    if !discoveredLocation || GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return
    endIf

    if !PDV_FLST_ArgonianSacredWaters || !PDV_ArgonianHistSubstrate
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

    if !PDV_FLST_ArgonianSacredWaters.HasForm(discoveredLocation)
        return
    endIf

    AwardArgonianSacredWater(discoveredLocation.GetFormID())
EndFunction

; Shared one-shot award for a sacred water site, keyed by the site's FormID
; (the LCTN FormID, including Eldergleam's, so the milestone count stays at 6).
Function AwardArgonianSacredWater(Int siteFormId)
    String seenKey = "PDV.ArgWaters.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.ArgWaters.Count", 1)

    PDV_ArgonianHistSubstrate.SetHistRelation(PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sacred_water")
    Debug.MessageBox("The water remembers. For one slow breath you stand in the marsh again, and the root speaks your name.")
    SendPrismaSubstrateToast("ArgonianHist", "water", "A water that remembers.", "hist", GetArgonianHistPostureLabel())

    if seenCount >= PDV_FLST_ArgonianSacredWaters.GetSize()
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.Milestone", 1)
        Debug.MessageBox("Every water that remembers has known you now. The marsh is never truly far -- the root holds you, wherever the road takes you.")
    endIf
    Trace(2, "Sacred water remembered: " + seenCount + " of " + PDV_FLST_ArgonianSacredWaters.GetSize())
EndFunction

; Set on every location change: 1 while inside the Eldergleam sanctuary location
; (exterior + interior share LCTN 0192AC), 0 anywhere else. Gates the interior
; poll so GetParentCell is only sampled while the player is actually at the site.
Function UpdateArgonianSanctuaryActive(Location loc)
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return
    endIf

    Int active = 0
    if loc && loc.GetFormID() == 0x000192AC
        active = 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", active)
EndFunction

; Bounded poll (OnUpdate): only while EldergleamActive. Fires the vision when the
; player reaches an Eldergleam interior cave cell -- where the water actually is
; -- not at the exterior approach. Disarms on award, on leaving, or once seen.
Function TryArgonianEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || StorageUtil.GetIntValue(None, "PDV.ArgWaters.Seen.103084") == 1
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

; Ambient near-water Hist maintenance -- the design centerpiece: the Hist recovers
; from being near water. While an Argonian is in water (swimming a river/lake/swamp),
; the Hist is gently maintained, at most once per in-game day so it stays a quiet
; floor rather than a farmable pulse. Polled on the manager 1s tick; the day-key is
; checked before IsSwimming so it short-circuits cheaply once credited for the day.
Function TryArgonianNearWaterMaintenance()
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_ArgonianHistSubstrate
        return
    endIf

    Int pdvEncodedWaterDay = (Utility.GetCurrentGameTime() as Int) + 1
    if StorageUtil.GetIntValue(None, "PDV.Argonian.NearWaterDay") == pdvEncodedWaterDay
        return
    endIf

    Actor argonianPlayer = Game.GetPlayer()
    if !argonianPlayer || !argonianPlayer.IsSwimming()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Argonian.NearWaterDay", pdvEncodedWaterDay)
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianNearWater")
    Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, "near_water")
    RefreshArgonianHistPosture("near_water")
    Int tierAfter = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    if PDV_Hist
        AwardCuratedSignal(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None)
    endIf
    SendPrismaSubstrateProgress("hist", tierBefore, tierAfter, multiplier, "The water remembers you.", "hist", GetArgonianHistPostureLabel())
    RequestPanelRefresh()
    Trace(2, "Argonian near-water Hist maintenance routed.")
EndFunction

; Sleeping Tree Sap: the strange tree's sap brushes the Hist once, ever.
Function HandleArgonianSapVision()
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_ArgonianHistSubstrate
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.SapVision") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.ArgWaters.SapVision", 1)
    PDV_ArgonianHistSubstrate.SetHistRelation(PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sleeping_tree_sap")
    Debug.MessageBox("The sap is strange and far from home, but for one heartbeat a root answers. Somewhere, the Hist turned to listen.")
    Trace(2, "Sleeping Tree Sap vision fired.")
EndFunction

; DEBUG seeder for beta testing the substrate-gated Argonian features. Call from
; console: cqf PDV__ManagerQuest DebugSeedArgonian <hist> <people> <void>
;   e.g. 90 90 0   -> Hist signature + People Champion rewards; adaptation rite
;        50 20 80  -> Void fully active + Void focus (void > people) for Shadowscale
; Any positive void seeds the 3 Sithis signals so IsVoidFullyActive() is true.
; Not gated behind debug level on purpose -- it is an explicit named dispatcher.
Function DebugSeedArgonian(Float histValue, Float peopleValue, Float voidValue)
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        Debug.MessageBox("PDV seed: player origin is not Argonian (set PDV_GLO_OriginRace to 7 first).")
        return
    endIf

    if !PDV_ArgonianHistSubstrate
        Debug.MessageBox("PDV seed: Argonian substrate is not wired.")
        return
    endIf

    PDV_ArgonianHistSubstrate.SetHistRelation(histValue, "debug_seed")
    PDV_ArgonianHistSubstrate.SetPeopleRelation(peopleValue, "debug_seed")
    PDV_ArgonianHistSubstrate.SetVoidRelation(voidValue, "debug_seed")

    Int signals = 0
    if voidValue > 0.0
        signals = PDV_ArgonianHistSubstrate.VoidActivationSignalsRequired
    endIf
    StorageUtil.SetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.SithisSignalCount", signals)

    PDV_ArgonianHistSubstrate.RefreshCompositeMetric("debug_seed")
    RefreshArgonianHistPosture("debug_seed")
    SyncArgonianRewards(Game.GetPlayer())

    Bool voidActive = PDV_ArgonianHistSubstrate.IsVoidFullyActive()
    Debug.MessageBox("PDV seed applied. Hist " + histValue + ", People " + peopleValue + ", Void " + voidValue + ". Composite " + PDV_ArgonianHistSubstrate.GetMetric() + ", Void active " + voidActive + ". Rewards re-synced; rite available at composite >= 75 next sleep at your bed or a sacred water.")
EndFunction

; Shadowscale signature: while the Void is the active foreground emphasis, a
; sneaking kill once per day pulls the shadow back over the player. Pure
; texture: a brief self-invisibility moment and a toast; no piety movement.
; Sneak state is polled at routing time, so a kill credited after leaving
; sneak can miss the veil; accepted approximation, documented in the packet.
Function HandleArgonianShadowscaleKill(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return
    endIf

    if !PDV_ArgonianHistSubstrate || !PDV_SPEL_ArgonianShadowscaleVeil
        return
    endIf

    if !playerRef.IsSneaking()
        return
    endIf

    if !PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != ARGONIAN_FOCUS_VOID
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.Shadowscale.LastInvisDay") == today + 1
        return
    endIf

    PDV_SPEL_ArgonianShadowscaleVeil.Cast(playerRef, playerRef)
    Debug.Notification("The shadow closes over you. The Void hides its own.")
    SendPrismaSubstrateToast("ArgonianHist", "shadowscale", "The shadow closes over you. The Void hides its own.", "void", PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    StorageUtil.SetIntValue(None, "PDV.Shadowscale.LastInvisDay", today + 1)
    Trace(2, "Shadowscale veil fired on sneak kill.")
EndFunction

; Hist dreams keyed to posture: armed by a posture transition (strong roll),
; otherwise a rare ambient murmur. Pure flavor; no piety, no substrate writes.
Function TryArgonianPostureDream(String reason)
    Int today = Utility.GetCurrentGameTime() as Int
    Int lastDreamDay = StorageUtil.GetIntValue(None, "PDV.ArgDream.LastDay")
    if lastDreamDay > 0 && (today - lastDreamDay) < 2
        return
    endIf

    Int posture = PDV_ArgonianHistSubstrate.GetHistPosture()
    Int dreamChance = 8
    if StorageUtil.GetIntValue(None, "PDV.ArgDream.Armed") == 1
        dreamChance = 60
    elseIf posture != PDV_ArgonianHistSubstrate.HIST_POSTURE_NORMAL
        dreamChance = 12
    endIf

    if Utility.RandomInt(1, 100) > dreamChance
        return
    endIf

    String dreamText = PDV_ArgonianHistSubstrate.GetDreamTextForPosture(posture)
    Debug.Notification(dreamText)
    SendPrismaSubstrateToast("ArgonianHist", "dream", dreamText, "hist", PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    StorageUtil.SetIntValue(None, "PDV.ArgDream.Armed", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgDream.LastDay", today)
    Trace(2, "Argonian posture dream fired (" + PDV_ArgonianHistSubstrate.GetHistPostureLabel() + ", " + reason + ")")
EndFunction

; ===================== Bosmer variety ("The Story Goes On") =====================

; Sleep-exit dispatcher. Order mirrors the Argonian one: silent declaration/rite
; menus first, dream text last, and a shown menu suppresses the dream that night
; so a MessageBox and a dream toast never stack.
Function HandleBosmerSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return
    endIf

    Int sleepCellId = 0
    Cell sleepCell = playerRef.GetParentCell()
    if sleepCell
        sleepCellId = sleepCell.GetFormID()
    endIf

    Bool menuShown = TryBosmerHearthSleep(playerRef, sleepCellId, reason)
    if !menuShown
        menuShown = TryBosmerNaming(playerRef, sleepCellId, reason)
    endIf
    if !menuShown
        TryBosmerPathDream(reason)
    endIf
EndFunction

; Hearth of the Telling uses the CELL you sleep in (reliable at sleep-stop).
; First eligible sleep prompts declaration on any Bosmer path so the Naming rite
; can use the same stable "declared rest place" pattern as Argonian adaptation.
; Tale Carried remains Living Story-only on return to the declared hearth.
Bool Function TryBosmerHearthSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef
        return false
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if declaredId == 0
        if !PDV_MESG_BosmerMarkHearth
            return false
        endIf
        Int declinedDay = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclineDay")
        if declinedDay > 0 && (today + 1 - declinedDay) < 3
            return false
        endIf

        Utility.Wait(0.5)
        Int pressed = PDV_MESG_BosmerMarkHearth.Show()
        if pressed == 0
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DeclaredCell", sleepCellId)
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount"))
            Debug.Notification("This hearth is where your stories come home now.")
        else
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DeclineDay", today + 1)
        endIf
        return true
    endIf

    if sleepCellId != declaredId
        return false
    endIf
    if GetBosmerPathState() != BOSMER_PATH_LIVING_STORY
        return false
    endIf

    ; Return sleep in the declared hearth: reward only when the player has been
    ; out gathering story (3+ new locations since last stay). Anti-farm is the
    ; discovery delta, not sleep count.
    Int discoveryNow = StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount")
    Int discoveryAtLastStay = StorageUtil.GetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay")
    if (discoveryNow - discoveryAtLastStay) >= 3
        StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", discoveryNow)
        if PDV_SPEL_BosmerTaleCarried
            PDV_SPEL_BosmerTaleCarried.Cast(playerRef, playerRef)
            Debug.Notification("You told the tale, and the telling settled.")
            HandleBosmerLivingStoryCommunityKept(reason + "_tale_carried")
        endIf
    endIf
    return false
EndFunction

; The Naming rite: at the declared hearth or any Songs site, with a 7-day cooldown,
; the player retells their own form. One-active told-self, swap via re-rite
; (clear-before-add). "Not yet" does not spend the cooldown. Returns true when the
; menu was shown so the dream yields that night.
Bool Function TryBosmerNaming(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !PDV_MESG_BosmerNaming || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return false
    endIf

    Bool atSite = false
    Int declaredHearth = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if sleepCellId != 0 && declaredHearth != 0 && sleepCellId == declaredHearth
        atSite = true
    elseIf PDV_FLST_BosmerGreenSongs && playerRef.GetCurrentLocation() && PDV_FLST_BosmerGreenSongs.HasForm(playerRef.GetCurrentLocation())
        atSite = true
    endIf
    if !atSite
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.BosNaming.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_BosmerNaming.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyBosmerNaming(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two told-selves at once. Records the path the player was
; on so SyncBosmerNaming can fade/restore on coherence break.
Function ApplyBosmerNaming(Actor playerRef, Int index)
    RemoveBosmerNamingSpells(playerRef)
    Spell chosen = GetBosmerNamingSpell(index)
    if !chosen
        return
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.BosNaming.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.BosNaming.PathAtRite", GetBosmerPathState())
    StorageUtil.SetFloatValue(None, "PDV.BosNaming.LastRiteTime", Utility.GetCurrentGameTime())
    Debug.Notification("You tell yourself anew. The shape settles into you.")
    Trace(2, "Bosmer Naming told-self applied: " + index)
EndFunction

Function RemoveBosmerNamingSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell told = GetBosmerNamingSpell(i)
        if told && playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetBosmerNamingSpell(Int index)
    if index == 0
        return PDV_SPEL_BosmerNaming_Hunter
    elseIf index == 1
        return PDV_SPEL_BosmerNaming_Speaker
    elseIf index == 2
        return PDV_SPEL_BosmerNaming_Wanderer
    elseIf index == 3
        return PDV_SPEL_BosmerNaming_Keeper
    endIf
    return None
EndFunction

; The told-self holds to the path it was named on. Off that path (or, on Old
; Contract, in the Apostate GPC band) it goes quiet at dawn and returns at dawn
; when the player comes back to coherence. PDV.BosNaming.Active stays set while
; quiet so no re-rite is needed.
Function SyncBosmerNaming(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.BosNaming.Active")
    if active <= 0
        return
    endIf
    Spell told = GetBosmerNamingSpell(active - 1)
    if !told
        return
    endIf

    Int pathAtRite = StorageUtil.GetIntValue(None, "PDV.BosNaming.PathAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == ORIGIN_BOSMER) && IsBosmerNamingCoherent(pathAtRite)
    if eligible
        if !playerRef.HasSpell(told)
            playerRef.AddSpell(told, False)
            Debug.Notification("You are yourself again. The told-self returns.")
        endIf
    else
        if playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
            Debug.Notification("The told-self goes quiet. You have wandered from its path.")
        endIf
    endIf
EndFunction

Bool Function IsBosmerNamingCoherent(Int pathAtRite)
    if GetBosmerPathState() != pathAtRite
        return false
    endIf
    if pathAtRite == BOSMER_PATH_OLD_CONTRACT && GetBosmerGreenPactCompliance() < 20
        return false                ; Apostate band
    endIf
    return true
EndFunction

; Green Dreams: armed (strong roll) the night after a path change, otherwise a
; rare ambient murmur. Pure flavor; no piety, no state writes beyond the dream
; bookkeeping keys.
Function TryBosmerPathDream(String reason)
    Int today = Utility.GetCurrentGameTime() as Int
    Int lastDreamDay = StorageUtil.GetIntValue(None, "PDV.BosDream.LastDay")
    if lastDreamDay > 0 && (today - lastDreamDay) < 2
        return
    endIf

    Int dreamChance = 10
    if StorageUtil.GetIntValue(None, "PDV.BosDream.Armed") == 1
        dreamChance = 60
    endIf

    if Utility.RandomInt(1, 100) > dreamChance
        return
    endIf

    Debug.Notification(GetBosmerDreamText(GetBosmerPathState()))
    StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 0)
    StorageUtil.SetIntValue(None, "PDV.BosDream.LastDay", today)
    Trace(2, "Bosmer path dream fired (" + reason + ")")
EndFunction

String Function GetBosmerDreamText(Int pathState)
    if pathState == BOSMER_PATH_OLD_CONTRACT
        if GetBosmerGreenPactCompliance() < 20
            return "You dream of green going grey, and a voice that has stopped expecting you to answer."
        endIf
        return "You dream the old green, ordered and exact, and you know your place in it."
    elseIf pathState == BOSMER_PATH_EXCHANGE
        return "You dream of a ledger no one keeps but you, and every line balancing at last."
    elseIf pathState == BOSMER_PATH_BANDIT_ROAD
        return "You dream of a fire on the road, and faces that owe you nothing and share anyway."
    endIf
    return "You dream the Story still telling itself, and you are a line in it that has not ended."
EndFunction

; Songs of the Green: one location-change entry. Counts every newly-seen location
; (for the Hearth discovery delta) and awards the curated Songs sites once each.
; Eldergleam is held for the interior poll (TryBosmerEldergleamInterior) so the
; vision lands in the cave at the water and the great tree, not at the exterior
; approach.
Function HandleBosmerLocationChange(Location loc)
    if !loc || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return
    endIf

    ; New-location counter feeds the Living Story Hearth "3+ since last stay" gate.
    String locSeenKey = "PDV.BosLoc.Seen." + loc.GetFormID()
    if StorageUtil.GetIntValue(None, locSeenKey) == 0
        StorageUtil.SetIntValue(None, locSeenKey, 1)
        StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 1)
    endIf

    ; Eldergleam's water and great tree are inside the cave, but the sanctuary
    ; LOCATION spans the exterior approach. Arm the interior catch and keep the
    ; flag in sync so it clears the moment the player leaves; the OnUpdate poll
    ; awards it on a cave cell. Same shared interior cells as the Argonian set.
    if loc.GetFormID() == 0x000192AC
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 1)
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)

    ; Gildergreen (outdoors): entering the Whiterun city LOCATION (0x00018A56)
    ; arms a proximity poll so the vision lands AT THE GILDERGREEN TREE in the
    ; Wind District, not inside the Temple of Kynareth. Mirrors Eldergleam
    ; arm/disarm; the OnUpdate poll TryBosmerGildergreenProximity awards at the tree.
    if loc.GetFormID() == 0x00018A56
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 1)
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)

    ; Temple of Kynareth interior (0x0001F87D) stays the Gildergreen song's FLST
    ; slot id (milestone-of-6 count + Naming-at-songs check), but the vision must
    ; NOT fire inside the temple -- suppress the interior direct award; the
    ; Gildergreen poll awards slot 0x0001F87D at the tree instead.
    if loc.GetFormID() == 0x0001F87D
        return
    endIf

    if PDV_FLST_BosmerGreenSongs && PDV_FLST_BosmerGreenSongs.HasForm(loc)
        AwardBosmerSong(loc.GetFormID())
    endIf
EndFunction

; Bounded poll (OnUpdate): only while inside the armed Eldergleam sanctuary
; LOCATION. Fires the green-song vision when the player reaches an Eldergleam
; interior cave cell -- where the water and great tree are -- not at the exterior
; approach. Disarms on award, on leaving, or once seen. Awards with the LCTN
; FormID so the milestone count stays at 6. Mirrors TryArgonianEldergleamInterior
; (shared interior cells); "Seen.103084" is the decimal render of LCTN 0x000192AC.
Function TryBosmerEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.103084") == 1
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Cell parentCell = Game.GetPlayer().GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        AwardBosmerSong(0x000192AC)
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
    endIf
EndFunction

; Bounded poll (OnUpdate): only while inside the armed Whiterun city LOCATION.
; Fires the green-song vision when the player walks up to the Gildergreen tree
; (Skyrim.esm ref 0x00023612, outdoors in the Wind District) -- NOT at the Temple
; of Kynareth interior. Awards the Temple LCTN FormID 0x0001F87D (the Gildergreen
; song's FLST slot id) so the milestone count stays at 6. The Gildergreen ref is
; resolved once and cached (vanilla static form; avoids a hot-loop lookup). The
; ~600 distance covers the Gildergreen planter without firing across the district.
ObjectReference _bosGildergreenRef

Function TryBosmerGildergreenProximity()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.GildergreenActive") != 1
        return
    endIf
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.129149") == 1
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
        return
    endIf

    if !_bosGildergreenRef
        _bosGildergreenRef = Game.GetFormFromFile(0x00023612, "Skyrim.esm") as ObjectReference
    endIf
    if !_bosGildergreenRef
        return
    endIf

    if Game.GetPlayer().GetDistance(_bosGildergreenRef) < 600.0
        AwardBosmerSong(0x0001F87D)
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
    endIf
EndFunction

; One-shot award per Songs site, keyed by LCTN FormID. Small path piety + vision
; line; milestone MessageBox once all six are known.
Function AwardBosmerSong(Int siteFormId)
    String seenKey = "PDV.BosSongs.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.BosSongs.Count", 1)

    ; Small path-keyed piety: route through the active path's living-world signal.
    HandleBosmerPactPositiveSignal("green_song")
    Debug.MessageBox("This green place still holds one of Y'ffre's old tellings. For a breath the Story leans close, and names you a part of it.")

    if PDV_FLST_BosmerGreenSongs && seenCount >= PDV_FLST_BosmerGreenSongs.GetSize()
        StorageUtil.SetIntValue(None, "PDV.BosSongs.Milestone", 1)
        Debug.MessageBox("Every green song has known you now. Wherever the road runs, the Story runs with you.")
    endIf
    Trace(2, "Bosmer green song remembered: " + seenCount)
EndFunction

; Scales at Rest (Exchange signature, once/day). Called from HandleBosmerExchangeSignal.
Function TryBosmerScalesAtRest(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || !PDV_SPEL_BosmerScalesAtRest
        return
    endIf
    if GetBosmerPathState() != BOSMER_PATH_EXCHANGE
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.BosSig.ScalesLastDay") == today + 1
        return
    endIf

    PDV_SPEL_BosmerScalesAtRest.Cast(playerRef, playerRef)
    StorageUtil.SetIntValue(None, "PDV.BosSig.ScalesLastDay", today + 1)
    Debug.Notification("The account is even. The bargains fall your way for a while.")
    Trace(2, "Bosmer Scales at Rest fired.")
EndFunction

; Shared below-health entry point. The player alias owns combat-session sampling;
; this manager fans the one low-health observation to race-specific payloads.
Function HandlePlayerBelowHealthGate(Actor playerRef)
    TryBosmerBaanDarGap(playerRef)
    TryArgonianSithisNearDeathBurst(playerRef)
    MarkOrcCodeHoldsPending(playerRef)
EndFunction

Function HandlePlayerBelowHealthSurvived(Actor playerRef)
    TryOrcCodeHolds(playerRef)
EndFunction

; Baan Dar Opens the Gap (Bandit Road signature, once/day). Called from the
; shared player below-health gate when player health drops below 20% in combat.
Function TryBosmerBaanDarGap(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || !PDV_SPEL_BosmerBaanDarGap
        return
    endIf
    if GetBosmerPathState() != BOSMER_PATH_BANDIT_ROAD
        return
    endIf
    if !playerRef.IsInCombat()
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.BosSig.GapLastDay") == today + 1
        return
    endIf

    PDV_SPEL_BosmerBaanDarGap.Cast(playerRef, playerRef)
    StorageUtil.SetIntValue(None, "PDV.BosSig.GapLastDay", today + 1)
    Debug.Notification("Baan Dar opens the gap. Run.")
    Trace(2, "Bosmer Baan Dar Opens the Gap fired.")
EndFunction

Function TryArgonianSithisNearDeathBurst(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_SPEL_ArgonianSithisNearDeathBurst
        return
    endIf
    if !playerRef.IsInCombat() || !PDV_ArgonianHistSubstrate
        return
    endIf
    if !PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != ARGONIAN_FOCUS_VOID || voidRelation < ARGONIAN_REWARD_T3_THRESHOLD
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.Argonian.SithisNearDeathLastDay") == today + 1
        return
    endIf

    PDV_SPEL_ArgonianSithisNearDeathBurst.Cast(playerRef, playerRef)
    StorageUtil.SetIntValue(None, "PDV.Argonian.SithisNearDeathLastDay", today + 1)
    Trace(2, "Argonian Sithis near-death burst fired.")
EndFunction

Function MarkOrcCodeHoldsPending(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ORC
        return
    endIf
    if !playerRef.IsInCombat() || (!PDV_SPEL_OrcCodeHolds && !PDV_SPEL_OrcCodeHolds_Devoted)
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Orc.CodeHolds.Pending", 1)
    Trace(2, "Orc Code Holds pending after below-health gate.")
EndFunction

Function TryOrcCodeHolds(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ORC
        StorageUtil.SetIntValue(None, "PDV.Orc.CodeHolds.Pending", 0)
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.CodeHolds.Pending") != 1
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Orc.CodeHolds.Pending", 0)

    Int malacathTier = TIER_NONE
    if PDV_Malacath
        malacathTier = GetTier(PDV_Malacath)
    endIf
    if malacathTier < TIER_SEEKER
        return
    endIf

    ; The Code Holds is a near-death survival pulse. Its HealRate MGEF is swallowed
    ; under Requiem (rate-mult on a ~0 base), so the actual health save is a flat
    ; RestoreActorValue -- mirroring the stamina half that already lands. Requiem-proof.
    if malacathTier >= TIER_DEVOTED && PDV_SPEL_OrcCodeHolds_Devoted
        PDV_SPEL_OrcCodeHolds_Devoted.Cast(playerRef, playerRef)
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf PDV_SPEL_OrcCodeHolds
        PDV_SPEL_OrcCodeHolds.Cast(playerRef, playerRef)
        playerRef.RestoreActorValue("Health", 40.0)
    endIf

    AwardPiety(PDV_Malacath, 0.5)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CodeHolds.Count", 1)
    Trace(2, "Orc Code Holds fired.")
EndFunction

; Dawn helper: arm an elevated dream the night after a path change.
Function ArmBosmerDreamOnPathChange()
    Int currentPath = GetBosmerPathState()
    if StorageUtil.GetIntValue(None, "PDV.BosDream.LastPath") != currentPath
        StorageUtil.SetIntValue(None, "PDV.BosDream.LastPath", currentPath)
        StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 1)
    endIf
EndFunction

; DEBUG seeder. Sets path, then clears the Naming/signature cooldowns and seeds
; the discovery counter so the Hearth/Naming gates are reachable fast. Driven from
; the debug MCM dev page (Bosmer path buttons + "Seed Bosmer variety"); the
; path-independent half is DebugSeedBosmerVariety below.
Function DebugSeedBosmer(Int pathIndex)
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        Debug.MessageBox("PDV seed: player origin is not Bosmer (set origin to Bosmer first).")
        return
    endIf
    if PDV_BosmerPathTrack
        PDV_BosmerPathTrack.SetState(pathIndex, "debug_seed")
    endIf
    DebugSeedBosmerVariety()
EndFunction

; Path-independent variety seed for the debug MCM: clears the Naming/signature
; once-day cooldowns and seeds +3 location discoveries so the Hearth/Naming gates
; are reachable on the CURRENT path without changing it. Wired to the dev-page
; "Seed Bosmer variety" button (RunPatternAction 56).
Function DebugSeedBosmerVariety()
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        Debug.MessageBox("PDV seed: player origin is not Bosmer (set origin to Bosmer first).")
        return
    endIf
    StorageUtil.SetFloatValue(None, "PDV.BosNaming.LastRiteTime", 0.0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.ScalesLastDay", 0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.GapLastDay", 0)
    StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 3)
    Debug.MessageBox("PDV seed: Bosmer variety cooldowns cleared; +3 discoveries seeded. Naming offered at your hearth or any green song next sleep.")
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

    TryBosmerScalesAtRest(Game.GetPlayer())
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
    StorageUtil.AdjustIntValue(None, "PDV.Bosmer.Favor.SignalCount", 1)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.Favor.LastSignalTime", Utility.GetCurrentGameTime())
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
        ; Layer 1 (ancestor substrate) is silenced under vampirism, halved under the
        ; beast. Layer 2 (Reclamation memory) still answers, so it routes regardless.
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerPortableShrinePrayer") * layerWeight
            Int tierBefore = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "Ancestor prayer marked.", "ancestor", GetDunmerAncestorLayerLabel())
        else
            Trace(2, "Dunmer ancestor layer silenced by curse posture (" + reason + ")")
        endIf
        NotifyDiegeticRoutineFavor("dunmer_portable_shrine")
        TryAwardDunmerTwilightWindowSignal(reason)
        AwardActiveDunmerReclamationMemorySignal()
        ; Home-prayer bonus (11a): praying with the portable urn at your declared
        ; ancestor-home fires the bigger home progress step + a flat Health pulse.
        ; HandleDunmerPlayerHomeBonus self-gates on curse posture.
        if IsPlayerAtDunmerDeclaredHome(Game.GetPlayer())
            HandleDunmerPlayerHomeBonus(reason + "_home")
        endIf
        RequestPanelRefresh()
        Trace(2, "Dunmer portable shrine prayer routed (" + reason + ")")
    endIf
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    if PDV_DunmerAncestorSubstrate
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerHomeBonus") * layerWeight
            Int tierBefore = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "House memory answered.", "ancestor", GetDunmerAncestorLayerLabel())
            ; Requiem-proof event-driven heal: a flat RestoreActorValue (NOT a
            ; HealRateMult, which Requiem swallows). This is the hearth/home bonus
            ; that replaced the old homeOrShrineOnly substrate regen (11a).
            Actor homePlayer = Game.GetPlayer()
            if homePlayer
                Float homeHeal = 15.0
                if tierAfter >= 2
                    homeHeal = 30.0
                endIf
                homePlayer.RestoreActorValue("Health", homeHeal)
            endIf
        else
            Trace(2, "Dunmer home rite silenced by curse posture (" + reason + ")")
        endIf
        NotifyDiegeticRoutineFavor("dunmer_home_bonus")
        AwardActiveDunmerReclamationMemorySignal()
        RequestPanelRefresh()
        Trace(2, "Dunmer player-home bonus routed (" + reason + ")")
    endIf
EndFunction

; Auto-declare the first interior bed-cell you rest in as your Dunmer
; ancestor-home (11a: immediate, no settle clock). In exile the rest-place is
; where the ancestors gather. A player-chosen prompt + move-home is a post-V1
; upgrade (needs a CK-authored MESG; houseCARL writes patches, not Devotion.esp).
Function HandleDunmerSleepEvents(Actor playerRef, String reason)
    if !PDV_DunmerAncestorSubstrate || !playerRef
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID") != 0
        return
    endIf
    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredFormID", sleepCell.GetFormID())
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredDay", (Utility.GetCurrentGameTime() as Int) + 1)
    Debug.Notification("You lay your rest here. This becomes your ancestor-space; the ancestors gather where you sleep.")
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

Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)
    if !IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return
    endIf

    if phaseIndex < 1 || phaseIndex > 8
        phaseIndex = GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMoonObservance")
    Int tierBefore = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    PDV_KhajiitLunarSubstrate.ObserveMoonPhaseScaled(phaseIndex, multiplier, reason)
    Int tierAfter = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_AZURAH, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    ; Double-route: the same observance feeds the lunar substrate (identity) AND a small
    ; foreground piety pulse to the emphasis deity (Azurah) so piety/decay/neglect stay honest.
    if PDV_Azura
        AwardCuratedSignal(PDV_Azura, PDV_Azura.SIGNAL_MOON_OBSERVANCE, None)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Khajiit.LunarSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    ShowP2BookNotice(reason, "The Lunar Lattice", "The moons sit nearer to your road.")
    SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, multiplier, "The moons marked this observance.", "lunar", GetKhajiitLunarTierLabel(tierAfter))
    NotifyDiegeticRoutineFavor("khajiit_moon_observance")
    RequestPanelRefresh()
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
    Int tierBefore = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    PDV_KhajiitLunarSubstrate.RecordRoadHomeCadenceScaled(multiplier, reason)
    Int tierAfter = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_KHENARTHI, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    if PDV_Khenarthi
        AwardCuratedSignal(PDV_Khenarthi, PDV_Khenarthi.SIGNAL_ROAD_HOME, None)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, multiplier, "The road home was remembered.", "lunar", GetKhajiitLunarTierLabel(tierAfter))
    NotifyDiegeticRoutineFavor("khajiit_road_home")
    RequestPanelRefresh()
    Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier + " anchor " + anchorId)
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_BAANDAR, "PDV.Signal.KhajiitBaanDarRoadTrick", "Baan Dar road trick", reason)
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", "Rajhin elegant theft", reason)
    ; Night theft is shadow-coded behavior; it accrues toward the ShadowDrift boundary.
    RecordKhajiitShadowEvidence("rajhin_night_theft_" + reason)
    Debug.Notification("Rajhin purrs. That theft had style.")
    SendPrismaShiftToast("Elegant theft", "Rajhin purrs.", GetKhajiitFocusSymbol(KHAJIIT_FOCUS_RAJHIN))
    RecordRecentDevotionEvent("Rajhin: theft with style")
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh dragon order", reason)
EndFunction

; Named-dragon kill: the focus signal plus the curated named-dragon beat. The
; kill receiver one-shots each named ActorBase, so the large beat cannot repeat.
Function HandleKhajiitAlkoshNamedDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh named dragon", reason)
    if PDV_Alkosh
        AwardCuratedSignal(PDV_Alkosh, PDV_Alkosh.SIGNAL_NAMED_DRAGON, None)
    endIf
    Trace(1, "Khajiit Alkosh named-dragon beat routed (" + reason + ")")
EndFunction

; Generic (unnamed) dragon kill: emphasis-only nudge at quarter weight, no piety
; pulse, at most once per game-week. Random dragons score lower by design.
Function HandleKhajiitAlkoshGenericDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int weekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
    if StorageUtil.GetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week") == weekStamp
        Trace(2, "Khajiit Alkosh generic-dragon nudge suppressed by weekly cap (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week", weekStamp)
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_ALKOSH, KHAJIIT_FOCUS_SIGNAL_DELTA * 0.25, reason)
    Trace(2, "Khajiit Alkosh generic-dragon emphasis nudge routed (" + reason + ")")
EndFunction

; Near-fatal reversal: the rare marked Baan Dar beat. Double emphasis weight and
; the large bandit-road curated signal; the receiver enforces the weekly cap.
Function HandleKhajiitBaanDarReversal(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitBaanDarReversal")
    StorageUtil.AdjustIntValue(None, "PDV.Signal.KhajiitBaanDarReversal.CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_BAANDAR, KHAJIIT_FOCUS_SIGNAL_DELTA * 2.0 * multiplier, reason)
    if PDV_BaanDar
        AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_BANDIT_ROAD, None)
    endIf
    Trace(1, "Khajiit Baan Dar near-fatal reversal routed (" + reason + ")")
EndFunction

Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier(keyPrefix)
    StorageUtil.AdjustIntValue(None, keyPrefix + ".CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    AdjustKhajiitFocusedEmphasis(focusValue, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    PulseKhajiitFocusPiety(focusValue)
    Trace(2, "Khajiit " + label + " routed with multiplier " + multiplier)
EndFunction

; Resolves the scripted deity for a Khajiit focused-emphasis value (None if unwired).
PDV_DeityBase Function GetKhajiitEmphasisDeity(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return PDV_Khenarthi
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return PDV_Azura
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return PDV_BaanDar
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return PDV_Rajhin
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return PDV_Alkosh
    endIf

    return None
EndFunction

; Small foreground piety pulse to the emphasis deity (the double-route partner of the
; substrate/focus-weight signal). Each concrete deity defines its own small pulse signal.
Function PulseKhajiitFocusPiety(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_BAANDAR && PDV_BaanDar
        AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_ROAD_TRICK, None)
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN && PDV_Rajhin
        AwardCuratedSignal(PDV_Rajhin, PDV_Rajhin.SIGNAL_ELEGANT_THEFT, None)
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH && PDV_Alkosh
        AwardCuratedSignal(PDV_Alkosh, PDV_Alkosh.SIGNAL_DRAGON_ORDER, None)
    endIf
EndFunction

; --- Khajiit anti-creed handlers: medium/major acts against a patron's creed cost piety with
; that patron (negative ScoreCuratedSignal delta). Routed only from curated triggers, never
; ambient behavior.
Function HandleKhajiitAzurahDesecration(String reason)
    if !IsKhajiitOrigin() || !PDV_Azura
        return
    endIf
    AwardCuratedSignal(PDV_Azura, PDV_Azura.SIGNAL_DESECRATION, None)
    Trace(2, "Khajiit Azurah desecration routed (" + reason + ")")
EndFunction

Function HandleKhajiitKhenarthiCaravanHarm(String reason)
    if !IsKhajiitOrigin() || !PDV_Khenarthi
        return
    endIf
    AwardCuratedSignal(PDV_Khenarthi, PDV_Khenarthi.SIGNAL_CARAVAN_HARM, None)
    Trace(2, "Khajiit Khenarthi caravan-harm routed (" + reason + ")")
EndFunction

Function HandleKhajiitRajhinBotchedTheft(String reason)
    if !IsKhajiitOrigin() || !PDV_Rajhin
        return
    endIf
    AwardCuratedSignal(PDV_Rajhin, PDV_Rajhin.SIGNAL_BOTCHED_THEFT, None)
    Trace(2, "Khajiit Rajhin botched-theft routed (" + reason + ")")
EndFunction

Function HandleKhajiitAlkoshChaosAid(String reason)
    if !IsKhajiitOrigin() || !PDV_Alkosh
        return
    endIf
    AwardCuratedSignal(PDV_Alkosh, PDV_Alkosh.SIGNAL_CHAOS_AID, None)
    Trace(2, "Khajiit Alkosh chaos-aid routed (" + reason + ")")
EndFunction

Function HandleKhajiitBaanDarBetrayal(String reason)
    if !IsKhajiitOrigin() || !PDV_BaanDar
        return
    endIf
    AwardCuratedSignal(PDV_BaanDar, PDV_BaanDar.SIGNAL_BETRAYAL, None)
    Trace(2, "Khajiit Baan Dar betrayal routed (" + reason + ")")
EndFunction

Bool Function IsKhajiitOrigin()
    return GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
EndFunction

; ----------------------------------------------------------------------------
; Khajiit Lunar Lattice posture (PDV_State_KhajiitLunarPosture):
;   Normal (0) / Strained (1, werewolf) / Corrupted (2, vampire) / ShadowDrift (3).
; Curse state takes structural precedence (an unambiguous werewolf/vampire
; detection). ShadowDrift is the non-curse behavioral drift, entered only on
; sustained shadow-coded evidence -- never ordinary night travel/stealth/
; observance (per the LOCKED ShadowDrift boundary in PDV_RaceDesign_Khajiit).
; The werewolf/vampire onset/cure MessageBoxes fire from ApplyKhajiitCurseHandlers;
; this owner fires only the ShadowDrift-entry narrator box and the posture readout.
; ----------------------------------------------------------------------------
Int Function GetKhajiitLunarPosture()
    if PDV_KhajiitLunarPostureTrack
        Int value = PDV_KhajiitLunarPostureTrack.GetCurrentState()
        if value < 0
            return KHAJIIT_LUNAR_POSTURE_NORMAL
        endIf
        return value
    endIf

    return KHAJIIT_LUNAR_POSTURE_NORMAL
EndFunction

Int Function DeriveKhajiitLunarPosture()
    if PDV_CurseStateService
        if PDV_CurseStateService.IsWerewolf()
            return KHAJIIT_LUNAR_POSTURE_STRAINED
        elseIf PDV_CurseStateService.IsVampire()
            return KHAJIIT_LUNAR_POSTURE_CORRUPTED
        endIf
    endIf

    if HasKhajiitShadowDrift()
        return KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
    endIf

    return KHAJIIT_LUNAR_POSTURE_NORMAL
EndFunction

Bool Function HasKhajiitShadowDrift()
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce") == 1
        return True
    endIf

    if !PDV_KhajiitLunarPostureTrack
        return False
    endIf

    return PDV_KhajiitLunarPostureTrack.HasRecentEvidenceDays(KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, KHAJIIT_SHADOWDRIFT_EVIDENCE_REQUIRED, KHAJIIT_SHADOWDRIFT_EVIDENCE_WINDOW)
EndFunction

; Night-only predatory shadow behavior accrues a shadow-evidence day. The
; once-per-day evidence guard plus the 3-in-7 threshold keep ShadowDrift a
; deliberate drift, not a consequence of a single night act.
Function RecordKhajiitShadowEvidence(String reason)
    if !PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Float gameTime = Utility.GetCurrentGameTime()
    Int dayInt = gameTime as Int
    Float hour = (gameTime - dayInt) * 24.0
    if hour < 19.0 && hour >= 7.0
        return
    endIf

    PDV_KhajiitLunarPostureTrack.RecordEvidenceDay(KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, reason)
    Trace(2, "Khajiit shadow-evidence day recorded (" + reason + ")")
EndFunction

Function RefreshKhajiitLunarPosture(String reason)
    if !PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Int oldPosture = GetKhajiitLunarPosture()
    Int newPosture = DeriveKhajiitLunarPosture()
    if newPosture == oldPosture
        return
    endIf

    PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    Trace(1, "Khajiit lunar posture " + oldPosture + " -> " + newPosture + " (" + reason + ")")

    if newPosture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars.", False)
    endIf

    SendPrismaShiftToast(GetKhajiitLunarPostureDisplayLabelAt(newPosture), GetKhajiitLunarPostureReadout(newPosture), "lunar")
    RequestPanelRefresh()
EndFunction

String Function GetKhajiitLunarPostureLabel()
    return GetKhajiitLunarPostureLabelAt(GetKhajiitLunarPosture())
EndFunction

String Function GetKhajiitLunarPostureLabelAt(Int posture)
    if posture == KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Strained"
    elseIf posture == KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Corrupted"
    elseIf posture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "ShadowDrift"
    endIf

    return "Normal"
EndFunction

String Function GetKhajiitLunarPostureDisplayLabelAt(Int posture)
    if posture == KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Lattice strained"
    elseIf posture == KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Lattice thinned"
    elseIf posture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "Drifting to shadow"
    endIf

    return "Lattice clear"
EndFunction

String Function GetKhajiitLunarPostureReadout(Int posture)
    if posture == KHAJIIT_LUNAR_POSTURE_STRAINED
        return "The Lattice holds you, but strained. The beast-shape is a competing form, and the caravans keep their distance."
    elseIf posture == KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "The Lattice still holds you, corrupted and thinned. The moons do not disown the undead, but the community does."
    elseIf posture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars."
    endIf

    return "The Lunar Lattice holds you cleanly. The moons know your form, and the road knows your step."
EndFunction

Function ShowKhajiitMessage(Message messageRecord, String fallbackText, Bool suppressModal)
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

; Khajiit branch of ApplyCurseRaceHandlers: fires the god-voice (Azurah) curse
; MessageBoxes on werewolf/vampire onset and cure (once-guarded), then re-derives
; the Lattice posture so a mid-day transition updates Survey immediately.
Function ApplyKhajiitCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.VampireOnsetShown") != 1
            ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_VampireOnset, "The thirst has taken you, little moon. The Lattice does not cast you out, but the caravans will fear you.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 1)
        endIf
    elseIf newState == 1
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown") != 1
            ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_WerewolfOnset, "Hircine has given you another shape. You are still Khajiit -- strained, watched, but not erased.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 1)
        endIf
    elseIf newState == 0
        if oldState == 2
            ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_VampireCured, "The thirst is gone. The corruption lifts from the Lattice; walk back into the moonlight.", False)
        elseIf oldState == 1
            ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_WerewolfCured, "The wolf is set down, little moon. The Lattice holds a single shape once more.", False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 0)
    endIf

    RefreshKhajiitLunarPosture("curse_" + reason)
EndFunction

; Debug seed for the MCM dev page: force a posture and surface it immediately.
; ShadowDrift sets a debug-force flag so it survives the dawn re-derive; any other
; posture clears it so the organic derivation resumes.
Function DebugForceKhajiitLunarPosture(Int newPosture, String reason)
    if !PDV_KhajiitLunarPostureTrack
        return
    endIf

    if newPosture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        StorageUtil.SetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce", 0)
    endIf

    Int oldPosture = GetKhajiitLunarPosture()
    PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    if newPosture != oldPosture
        if newPosture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
            ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow.", False)
        endIf
        SendPrismaShiftToast(GetKhajiitLunarPostureDisplayLabelAt(newPosture), GetKhajiitLunarPostureReadout(newPosture), "lunar")
        RequestPanelRefresh()
    endIf
EndFunction

; MCM dev-page seed: cycle Normal -> Strained -> Corrupted -> ShadowDrift -> Normal
; so every Lattice posture readout and message is reachable from the debug page,
; including ShadowDrift (otherwise gated behind sustained night-theft evidence).
Function DebugCycleKhajiitLunarPosture()
    Int nextPosture = GetKhajiitLunarPosture() + 1
    if nextPosture > KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        nextPosture = KHAJIIT_LUNAR_POSTURE_NORMAL
    endIf

    DebugForceKhajiitLunarPosture(nextPosture, "mcm_cycle")
EndFunction

Function HandleArgonianHistMaintenance(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianHistMaintenance")
    Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: the substrate carries the reward gating; a small honest +1 Hist pulse keeps
    ; the universal piety layer (decay/neglect/creed-loss) honest. Substrate anti-farm is the
    ; ConsumeDailyRepeatMultiplier above; the pulse anti-farm is the AwardPiety daily-max path.
    if PDV_Hist
        AwardCuratedSignal(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    ShowP2BookNotice(reason, "The Hist remembers", "The reading carries the smell of home.")
    SendPrismaSubstrateProgress("hist", tierBefore, tierAfter, multiplier, "The Hist memory stirred.", "hist", GetArgonianHistPostureLabel())
    RequestPanelRefresh()
    Trace(2, "Argonian Hist maintenance routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianPeopleSupport(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianPeopleSupport")
    Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    PDV_ArgonianHistSubstrate.RecordPeopleSupportScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: small honest +1 Hist pulse (the universal layer stays Hist-honest).
    if PDV_Hist
        AwardCuratedSignal(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    SendPrismaSubstrateProgress("hist", tierBefore, tierAfter, multiplier, "Your people were supported.", "hist", GetArgonianHistPostureLabel())
    RequestPanelRefresh()
    Trace(2, "Argonian People support routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianBedOfChoiceReturn(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianBedOfChoice")
    Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    PDV_ArgonianHistSubstrate.RecordBedOfChoiceReturnScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: small honest +1 Hist pulse (the universal layer stays Hist-honest).
    if PDV_Hist
        AwardCuratedSignal(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    SendPrismaSubstrateProgress("hist", tierBefore, tierAfter, multiplier, "The chosen rest took root.", "hist", GetArgonianHistPostureLabel())
    RequestPanelRefresh()
    Trace(2, "Argonian bed-of-choice return routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianVoidSignal(String reason)
    if !IsArgonianOrigin() || !PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianVoidSignal")
    Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    PDV_ArgonianHistSubstrate.RecordVoidSignalScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: the universal layer stays Hist-honest even on the Void route (small +1 Hist
    ; pulse). The Sithis threshold pulse only lands once the Void is fully active (>=3 signals).
    if PDV_Hist
        AwardCuratedSignal(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None)
    endIf
    if PDV_Sithis && PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        AwardCuratedSignal(PDV_Sithis, PDV_Sithis.SIGNAL_VOID_THRESHOLD, None)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    SendPrismaSubstrateProgress("hist", tierBefore, tierAfter, multiplier, "The Void was noticed.", "hist", GetArgonianHistPostureLabel())
    RequestPanelRefresh()
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

    RefreshArgonianDominationPressure(reason)

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
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", PDV_ArgonianHistSubstrate.GetHistPosture())
    if PDV_ArgonianHistPostureTrack
        PDV_ArgonianHistPostureTrack.SetState(PDV_ArgonianHistSubstrate.GetHistPosture(), reason)
        if PDV_ArgonianHistPostureTrack.GetCurrentState() != oldPosture
            SendPrismaShiftToast(GetArgonianHistPostureLabel(), "", "hist")
            RequestPanelRefresh()
        endIf
    endIf
EndFunction

Function RefreshArgonianDominationPressure(String reason)
    Bool active = IsArgonianMolagBalDominationPressureActive()
    Int oldValue = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure")
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.DominationPressure", BoolToInt(active))
    if BoolToInt(active) != oldValue
        Trace(1, "Argonian domination pressure -> " + BoolToInt(active) + " (" + reason + ")")
    endIf
EndFunction

Function RefreshArgonianDominationPressureForPath(PDV_DaedricPathBase path, String reason)
    if !path
        return
    endIf
    if path.DeityName != "Molag Bal" && path.DeityName != "Molag"
        return
    endIf
    if GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        RefreshArgonianHistPosture(reason)
    endIf
EndFunction

Bool Function IsArgonianMolagBalDominationPressureActive()
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN
        return False
    endIf
    if !PDV_CurseStateService || PDV_CurseStateService.GetCurseState() != 2
        return False
    endIf

    PDV_DeityBase deity = GetQuestReactionDeity("Molag Bal")
    PDV_DaedricPathBase molagPath = deity as PDV_DaedricPathBase
    if !molagPath
        return False
    endIf

    return molagPath.GetStoredTier() >= TIER_SEEKER
EndFunction

Function HandleOrcStrongholdForge(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdForge")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    AwardOrcStrongholdForgeSignal()
    Trace(2, "Orc Stronghold forge routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLocationChange(Location newLocation)
    if !newLocation || !IsOrcOrigin()
        return
    endIf

    Int holdId = GetOrcStrongholdHoldId(newLocation)
    if holdId <= 0
        return
    endIf

    HandleOrcStrongholdPresence(holdId, "location_stronghold")
EndFunction

Function HandleOrcStrongholdPresence(Int holdId, String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdPresence")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    if holdId > 0
        HandleOrcFourHoldsVisit(holdId, reason)
    endIf
    Trace(2, "Orc Stronghold presence routed with multiplier " + multiplier)
EndFunction

Function HandleOrcBloodKinCrisis(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    RecordOrcLifeModeSignal(ORC_LIFE_MODE_STRONGHOLD, 1.0, reason)
    Trace(2, "Orc Blood-Kin crisis routed: " + reason)
EndFunction

Function HandleOrcCityDignity(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCityDignity")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcCityDignitySignal()
    Trace(2, "Orc City dignity routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLegionService(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcLegionService")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_LEGION_EXILE, multiplier, reason)
    AwardOrcLegionServiceSignal()
    Trace(2, "Orc Legion or exile service routed with multiplier " + multiplier)
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcSelfMadeCommunity")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcSelfMadeCommunitySignal()
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
    AwardOrcBroadConductSignal()
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.MalacathConduct", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.MalacathSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastMalacathSourceReason", reason)
    ShowP2BookNotice(reason, "The Code of Malacath", "Malacath weighs your conduct against it.")
    Trace(2, "Orc Malacath conduct routed with multiplier " + multiplier)
EndFunction

Function HandleOrcOathBreak(String reason)
    if !IsOrcOrigin()
        return
    endIf

    AwardOrcOathBreakSignal()
    StorageUtil.AdjustIntValue(None, "PDV.Orc.OathBreakCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastOathBreakReason", reason)
    Trace(2, "Orc oath-break routed: " + reason)
EndFunction

Function HandleOrcFourHoldsVisit(Int holdId, String reason)
    if !IsOrcOrigin()
        return
    endIf

    if holdId < ORC_FOUR_HOLDS_DUSHNIKH_YAL || holdId > ORC_FOUR_HOLDS_LARGASHBUR
        Trace(1, "Orc Four Holds skipped: invalid hold id " + holdId)
        return
    endIf

    String visitedKey = "PDV.Orc.FourHolds." + holdId
    if StorageUtil.GetIntValue(None, visitedKey) > 0
        Trace(2, "Orc Four Holds skipped: already visited hold " + holdId)
        return
    endIf

    StorageUtil.SetIntValue(None, visitedKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastFourHoldsReason", reason)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastFourHoldsVisit", holdId)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastFourHoldsVisitTime", Utility.GetCurrentGameTime())
    AwardOrcFourHoldsVisitSignal()

    Int count = GetOrcFourHoldsVisitCount()
    StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.Count", count)
    ShowOrcNotification(GetOrcFourHoldsNotice(holdId), GetOrcFourHoldsFallback(holdId))
    if count >= 4 && StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown", 1)
        ShowOrcMessage(PDV_Msg_Orc_FourHolds_Milestone, "You have stood at all four strongholds. The code holds across distance.", False)
    endIf

    Trace(2, "Orc Four Holds routed: hold " + holdId + " count " + count)
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
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime", Utility.GetCurrentGameTime())

    if multiplier <= 0.0
        return
    endIf

    if PDV_OrcLifeModeTrack.GetCurrentState() == modeValue
        SendPrismaSubstrateToast(GetOrcLifeModeSubstrateToken(modeValue), "act", "The code was marked.", "malacath", GetOrcLifeModeLabel())
        RequestPanelRefresh()
        return
    endIf

    ; LOCKED life-mode switch rule: a soft switch needs two evidence days inside
    ; seven; only a major gate (Blood-Kin, Cursed Tribe resolved) switches at once.
    ; Other soft switches settle at dawn via EvaluateOrcLifeModeAtDawn. A confirmed
    ; switch holds for a three-day lock-in. One stray act no longer flips the mode.
    if IsOrcMajorLifeModeGate(reason)
        ApplyOrcLifeModeSwitch(modeValue, reason)
    elseIf PDV_OrcLifeModeTrack.HasRecentEvidenceDays(modeValue, 2, 7) && !PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        ApplyOrcLifeModeSwitch(modeValue, reason)
    endIf
EndFunction

Function ApplyOrcLifeModeSwitch(Int modeValue, String reason)
    PDV_OrcLifeModeTrack.SetState(modeValue, reason)
    PDV_OrcLifeModeTrack.SetTransitionLockout(3.0, reason)
    SendPrismaShiftToast(GetOrcLifeModeLabel(), "", "malacath")
    RequestPanelRefresh()
EndFunction

Bool Function IsOrcMajorLifeModeGate(String reason)
    return StringContainsToken(reason, "orc_bloodkin_crisis") || StringContainsToken(reason, "orc_cursed_tribe_resolved") || StringContainsToken(reason, "orc_major_gate")
EndFunction

String Function GetOrcLifeModeSubstrateToken(Int modeValue)
    if modeValue == ORC_LIFE_MODE_STRONGHOLD
        return "stronghold"
    elseIf modeValue == ORC_LIFE_MODE_LEGION_EXILE
        return "legionexile"
    endIf
    return "city"
EndFunction

; Soft life-mode switches settle at dawn per the LOCKED design: the non-current
; mode with two evidence days inside seven wins (highest accumulated weight on a
; tie), honoring the lock-in. A non-City mode with no evidence in fourteen days
; lapses back to City, the steady default -- getting Stronghold back is not easy.
Function EvaluateOrcLifeModeAtDawn()
    if !PDV_OrcLifeModeTrack || !IsOrcOrigin()
        return
    endIf

    EnsureOrcLifeModeInitialized()
    Int currentMode = PDV_OrcLifeModeTrack.GetCurrentState()

    if !PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        Int bestMode = -1
        Float bestWeight = -1.0
        Int candidate = ORC_LIFE_MODE_CITY
        while candidate <= ORC_LIFE_MODE_LEGION_EXILE
            if candidate != currentMode && PDV_OrcLifeModeTrack.HasRecentEvidenceDays(candidate, 2, 7)
                Float candidateWeight = StorageUtil.GetFloatValue(None, GetOrcLifeModeWeightKey(candidate))
                if bestMode < 0 || candidateWeight > bestWeight
                    bestMode = candidate
                    bestWeight = candidateWeight
                endIf
            endIf
            candidate += 1
        endWhile

        if bestMode >= 0
            ApplyOrcLifeModeSwitch(bestMode, "orc_dawn_softswitch")
            return
        endIf
    endIf

    if currentMode > ORC_LIFE_MODE_CITY && !PDV_OrcLifeModeTrack.HasRecentEvidenceDays(currentMode, 1, 14)
        PDV_OrcLifeModeTrack.SetState(ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")
        RequestPanelRefresh()
    endIf
EndFunction

Function AwardOrcStrongholdForgeSignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, None)
    endIf
EndFunction

Function AwardOrcCityDignitySignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_CITY_DIGNITY, None)
    endIf
EndFunction

Function AwardOrcLegionServiceSignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_LEGION_SERVICE, None)
    endIf
EndFunction

Function AwardOrcSelfMadeCommunitySignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY, None)
    endIf
EndFunction

Function AwardOrcBroadConductSignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_BROAD_CONDUCT, None)
    endIf
EndFunction

Function AwardOrcOathBreakSignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_OATH_BREAK, None)
    endIf
EndFunction

Function AwardOrcFourHoldsVisitSignal()
    if PDV_Malacath
        AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT, None)
    endIf
EndFunction

Int Function GetOrcFourHoldsVisitCount()
    Int count = 0
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + ORC_FOUR_HOLDS_DUSHNIKH_YAL) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + ORC_FOUR_HOLDS_MOR_KHAZGUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + ORC_FOUR_HOLDS_NARZULBUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + ORC_FOUR_HOLDS_LARGASHBUR) > 0
        count += 1
    endIf
    return count
EndFunction

Message Function GetOrcFourHoldsNotice(Int holdId)
    if holdId == ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return PDV_Notif_Orc_FourHolds_DushnikhYal
    elseIf holdId == ORC_FOUR_HOLDS_MOR_KHAZGUR
        return PDV_Notif_Orc_FourHolds_MorKhazgur
    elseIf holdId == ORC_FOUR_HOLDS_NARZULBUR
        return PDV_Notif_Orc_FourHolds_Narzulbur
    elseIf holdId == ORC_FOUR_HOLDS_LARGASHBUR
        return PDV_Notif_Orc_FourHolds_Largashbur
    endIf

    return None
EndFunction

String Function GetOrcFourHoldsFallback(Int holdId)
    if holdId == ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return "Dushnikh Yal is counted. The code has a western hold."
    elseIf holdId == ORC_FOUR_HOLDS_MOR_KHAZGUR
        return "Mor Khazgur is counted. The code has a northern hold."
    elseIf holdId == ORC_FOUR_HOLDS_NARZULBUR
        return "Narzulbur is counted. The code has an eastern hold."
    elseIf holdId == ORC_FOUR_HOLDS_LARGASHBUR
        return "Largashbur is counted. Even a troubled hold is still a hold."
    endIf

    return "The stronghold is counted. The code holds across distance."
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

Int Function GetOrcStrongholdHoldId(Location newLocation)
    if !newLocation
        return 0
    endIf

    Int locationFormId = newLocation.GetFormID()
    if locationFormId == 0x00019171
        return ORC_FOUR_HOLDS_DUSHNIKH_YAL
    elseIf locationFormId == 0x0001927C
        return ORC_FOUR_HOLDS_MOR_KHAZGUR
    elseIf locationFormId == 0x00019282
        return ORC_FOUR_HOLDS_NARZULBUR
    elseIf locationFormId == 0x00019263
        return ORC_FOUR_HOLDS_LARGASHBUR
    endIf

    return 0
EndFunction

Function HandleRedguardCrownTombRespect(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardCrownTombRespect")
    RecordRedguardSectSignal(REDGUARD_SECT_CROWN, multiplier, reason)
    AwardRedguardCrownSignal()
    Trace(2, "Redguard Crown tomb respect routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")
    RecordRedguardSectSignal(REDGUARD_SECT_FOREBEAR, multiplier, reason)
    AwardRedguardForebearSignal()
    Trace(2, "Redguard Forebear road passage routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")
    RecordRedguardSectSignal(REDGUARD_SECT_ASHABAH, multiplier, reason)
    AwardRedguardAshAbahSignal()
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
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())
    AwardRedguardFarShoresSignal()
    ShowRedguardNotification(PDV_Notif_Redguard_FarShoresToken_Activate, "You tend the Far Shores token and speak to Tu'whacca.")
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
    ShowP2BookNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")
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
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())

    if multiplier <= 0.0
        return
    endIf

    if PDV_RedguardSectTrack.GetCurrentState() == sectValue
        MaybeShowRedguardChampionEntry(sectValue)
        SendPrismaSubstrateToast("sect", "act", "The Yokudan path was marked.", "sect", GetRedguardSectLabel())
        RequestPanelRefresh()
        return
    endIf

    ; LOCKED sect-switch rule: Crown <-> Forebear needs two sect-coded evidence days
    ; inside seven, then a three-day lock-in -- one tomb visit no longer rewrites
    ; sect identity. Ash'abah is entered only by a marked death/funerary burden
    ; (casual undead fighting is not enough), and left by a Crown/Forebear switch.
    Bool allowSwitch = False
    if sectValue == REDGUARD_SECT_ASHABAH
        allowSwitch = IsRedguardAshAbahBurden(reason)
    else
        allowSwitch = PDV_RedguardSectTrack.HasRecentEvidenceDays(sectValue, 2, 7) && !PDV_RedguardSectTrack.IsTransitionLockedOut()
    endIf

    if allowSwitch
        PDV_RedguardSectTrack.SetState(sectValue, reason)
        PDV_RedguardSectTrack.SetTransitionLockout(3.0, reason)
        ShowRedguardSectEntry(sectValue)
        MaybeShowRedguardChampionEntry(sectValue)
        SendPrismaShiftToast(GetRedguardSectLabel(), "", "sect")
        RequestPanelRefresh()
    endIf
EndFunction

Bool Function IsRedguardAshAbahBurden(String reason)
    return reason == "redguard_ashabah_burden" || reason == "redguard_deathduty_major"
EndFunction

Function AwardRedguardCrownSignal()
    if PDV_Tuwhacca
        AwardCuratedSignal(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_CROWN_FORM, None)
    endIf
EndFunction

Function AwardRedguardForebearSignal()
    if _activeDeity == PDV_HoonDing && PDV_HoonDing
        ; HoonDing's make-way is deliberately rare: at most once per game-week, so
        ; the way being made stays a marked moment and cannot be farmed.
        Int weekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
        if StorageUtil.GetIntValue(None, "PDV.Redguard.HoonDingMakeWayWeek") == weekStamp
            Trace(2, "Redguard HoonDing make-way suppressed by weekly cap.")
            return
        endIf
        StorageUtil.SetIntValue(None, "PDV.Redguard.HoonDingMakeWayWeek", weekStamp)
        AwardCuratedSignal(PDV_HoonDing, PDV_HoonDing.SIGNAL_MAKE_WAY, None)
    elseIf _activeDeity == PDV_Leki && PDV_Leki
        AwardCuratedSignal(PDV_Leki, PDV_Leki.SIGNAL_SWORD_SINGING, None)
    endIf
EndFunction

Function AwardRedguardAshAbahSignal()
    if PDV_Tuwhacca
        AwardCuratedSignal(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY, None)
    endIf
EndFunction

Function AwardRedguardFarShoresSignal()
    if PDV_Tuwhacca
        AwardCuratedSignal(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN, None)
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

Function ShowRedguardSectEntry(Int sectValue)
    String shownKey = GetRedguardSectEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == REDGUARD_SECT_CROWN
        ShowRedguardNotification(PDV_Notif_Redguard_Sect_Crown_Entry, "You hold the Crown way: orthodoxy kept, the old inheritance intact.")
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        ShowRedguardNotification(PDV_Notif_Redguard_Sect_Forebear_Entry, "You hold the Forebear way: Redguard identity carried among outsiders.")
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        ShowRedguardNotification(PDV_Notif_Redguard_Sect_AshAbah_Entry, "You take up the Ash'abah duty: the unclean work others will not touch.")
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
EndFunction

String Function GetRedguardSectEntryShownKey(Int sectValue)
    if sectValue == REDGUARD_SECT_CROWN
        return "PDV.Redguard.SectEntryShown.Crown"
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.SectEntryShown.Forebear"
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.SectEntryShown.AshAbah"
    endIf

    return ""
EndFunction

Function MaybeShowRedguardChampionEntry(Int sectValue)
    String shownKey = GetRedguardChampionEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == REDGUARD_SECT_CROWN
        if PDV_Tuwhacca && GetTier(PDV_Tuwhacca) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Crown, "The Crown way has become more than memory. It is a public shape of your devotion.", False)
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        if PDV_HoonDing && GetTier(PDV_HoonDing) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Forebear, "The Forebear way has become more than adaptation. It is a public shape of your devotion.", False)
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        if PDV_Tuwhacca && GetTier(PDV_Tuwhacca) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_AshAbah, "The Ash'abah duty has become more than necessity. It is a public shape of your devotion.", False)
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    endIf
EndFunction

String Function GetRedguardChampionEntryShownKey(Int sectValue)
    if sectValue == REDGUARD_SECT_CROWN
        return "PDV.Redguard.ChampionEntryShown.Crown"
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.ChampionEntryShown.Forebear"
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.ChampionEntryShown.AshAbah"
    endIf

    return ""
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
        SendPrismaShiftToast(GetKhajiitFocusLabel(focusValue), GetKhajiitFocusShiftText(focusValue), GetKhajiitFocusSymbol(focusValue))
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
    return "PDV.Khajiit.Focus." + GetKhajiitFocusStorageLabel(focusValue)
EndFunction

String Function GetKhajiitFocusLabel(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi"
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return "Azurah"
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar"
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return "Rajhin"
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return "Alkosh"
    endIf

    return "None"
EndFunction

String Function GetKhajiitFocusStorageLabel(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_BAANDAR
        return "BaanDar"
    endIf

    return GetKhajiitFocusLabel(focusValue)
EndFunction

String Function GetKhajiitFocusShiftText(Int focusValue)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi's wind has found your steps."
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH
        return "Azurah's dusk-bright road has found your steps."
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar's road has found your steps."
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN
        return "Rajhin's clever path has found your steps."
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH
        return "Alkosh's order has found your steps."
    endIf

    return "The Lunar Lattice has found a new shape in your practice."
EndFunction

Function HandleHircineHuntRite(String reason)
    if PDV_HircinePath
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.HircineHuntRite")
        Float stigmaBefore = PDV_HircinePath.GetStigma()
        Int tierBefore = PDV_HircinePath.GetStoredTier()
        PDV_HircinePath.RecordHuntRiteScaled(multiplier, reason)
        if multiplier > 0.0
            ShowDaedricMilestonePresentation(PDV_HircinePath, tierBefore, PDV_HircinePath.GetStoredTier(), False)
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
        ; Phase 7 verifier compatibility: ApplyConcordatPressure(-15, "talos_shrine_" + reason)
        ApplyImperialConcordatAction("hidden_talos_shrine", "talos_shrine_" + reason)
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

    ; The defining Altmer friction: Lorkhan adjacency costs piety. Deduct the tiered
    ; penalty from the deity the player is building (Auri-El foundation by default),
    ; scaled by the ThalmorAlignment faction modifier. It flows through the normal
    ; scratch / daily-clamp path, so it paces with the rest of the economy.
    Float lorkhanPenalty = GetAltmerLorkhanPietyPenalty(pressureTier) * GetAltmerLorkhanFactionModifier()
    if lorkhanPenalty > 0.0
        PDV_DeityBase lorkhanDeity = _activeDeity
        if !lorkhanDeity
            lorkhanDeity = PDV_AuriEl
        endIf
        if lorkhanDeity
            AwardPiety(lorkhanDeity, -lorkhanPenalty)
            Trace(2, "Altmer Lorkhan penalty applied: -" + lorkhanPenalty + " to " + lorkhanDeity.DeityName)
        endIf
    endIf

    if pressureTier >= ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION && GetAltmerCrisisState() == ALTMER_CRISIS_NONE
        SetAltmerCrisisState(ALTMER_CRISIS_DISSONANT, "lorkhan_pressure_" + sourceId)
    endIf

    Trace(2, "Altmer Lorkhan pressure routed: tier " + pressureTier + " source " + sourceId)
EndFunction

; Tiered Lorkhan-adjacency penalty (LOCKED base values): the more directly an act
; affirms Lorkhan / mortal incarnation, the steeper the cost to Altmer divine devotion.
Float Function GetAltmerLorkhanPietyPenalty(Int pressureTier)
    if pressureTier == ALTMER_LORKHAN_PRESSURE_DIRECT
        return 10.0
    elseIf pressureTier == ALTMER_LORKHAN_PRESSURE_SHOR_ADJACENT
        return 7.0
    elseIf pressureTier == ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION
        return 5.0
    elseIf pressureTier == ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
        return 2.0
    endIf
    return 0.0
EndFunction

; ThalmorAlignment faction modifier scales the Lorkhan penalty. Negative bands
; are heterodox and soften the penalty; positive bands are orthodox and sharpen it.
Float Function GetAltmerLorkhanFactionModifier()
    if !PDV_ThalmorAlignmentTrack
        return 1.0
    endIf

    Int alignment = PDV_ThalmorAlignmentTrack.GetValue()
    if alignment <= -76
        return 0.75
    elseIf alignment <= -51
        return 0.875
    elseIf alignment >= 76
        return 1.5
    elseIf alignment >= 51
        return 1.25
    endIf

    return 1.0
EndFunction

; ThalmorAlignment is the Concordat-mirror reputation track (-100..+100, 5 states).
; Positive points push toward Thalmor orthodoxy (+100); negative points toward the
; heterodox/defiant pole. Points are absolute track adjustments (no band multiplier on
; the points themselves) per PDV_NextBuildPass_RecordSpec.md sec.1.
Function ApplyAltmerAlignmentAction(String actionKey, String reason)
    if !IsAltmerOrigin()
        return
    endIf
    if !PDV_ThalmorAlignmentTrack
        Trace(1, "ApplyAltmerAlignmentAction skipped: track missing.")
        return
    endIf

    Int adjustment = GetAltmerThalmorPointsForAction(actionKey)
    if adjustment == 0
        Trace(1, "ApplyAltmerAlignmentAction skipped: unknown action " + actionKey)
        return
    endIf

    PDV_ThalmorAlignmentTrack.Adjust(adjustment, reason)
    Trace(2, "Altmer ThalmorAlignment " + actionKey + " " + adjustment + " -> " + PDV_ThalmorAlignmentTrack.GetValue())
EndFunction

Int Function GetAltmerThalmorPointsForAction(String actionKey)
    if actionKey == "arrest_talos_worshipper"
        return 15
    elseIf actionKey == "complete_thalmor_mission"
        return 20
    elseIf actionKey == "help_thalmor_prisoner_escape"
        return -15
    elseIf actionKey == "kill_thalmor_agent"
        return -20
    elseIf actionKey == "read_banned_texts"
        return -5
    elseIf actionKey == "consort_with_daedra"
        return -25
    endIf

    return 0
EndFunction

; Emitter entry point for ThalmorAlignment actions. Enforces Altmer origin and a one-shot
; per (action, source form) so re-reading a banned text or re-equipping the same Daedric
; artifact does not repeatedly move the alignment track.
Function HandleAltmerAlignmentSignal(String actionKey, Form sourceForm, String reason)
    if !IsAltmerOrigin()
        return
    endIf

    Int sourceFormId = 0
    if sourceForm
        sourceFormId = sourceForm.GetFormID()
    endIf
    String guardKey = "PDV.Altmer.Alignment." + actionKey + "." + sourceFormId
    if StorageUtil.GetIntValue(None, guardKey) > 0
        Trace(2, "Altmer alignment signal skipped (one-shot): " + actionKey + " " + sourceFormId)
        return
    endIf
    StorageUtil.SetIntValue(None, guardKey, 1)

    ApplyAltmerAlignmentAction(actionKey, reason)
EndFunction

; Shared sink for an unprovoked Thalmor kill, routed from PDV_ActionRouter's non-hostile
; kill path. Altmer reads it as a -20 ThalmorAlignment heterodox act (one-shot per victim
; via HandleAltmerAlignmentSignal); Imperial reads it as -10 Concordat defiance.
Function HandleThalmorUnprovokedKill(Form victimForm)
    if IsAltmerOrigin()
        HandleAltmerAlignmentSignal("kill_thalmor_agent", victimForm, "thalmor_unprovoked_kill")
    elseIf GetPlayerOriginRaceIndex() == 1
        ApplyImperialConcordatAction("kill_thalmor_justiciar_unprovoked", "thalmor_unprovoked_kill")
    endIf
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
    AwardAltmerDawnSignal(reason)
    if reason == "eventbus_p2_altmer_auriel_po3_book_altmer_auriel"
        ShowP2BookNotice(reason, "Auri-El's dawn", "The morning rite settles deeper.")
    elseIf reason == "eventbus_p2_altmer_magnus_po3_book_altmer_magnus"
        ShowP2BookNotice(reason, "The road of Magnus", "The discipline of light holds you to the dawn.")
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
    AwardAltmerOrthodoxSignal(reason)
    ShowP2BookNotice(reason, "The scribe Xarxes", "The old orthodoxy asks more of you.")
EndFunction

Function AwardAltmerDawnSignal(String reason)
    if StringContainsToken(reason, "magnus") && PDV_Magnus
        AwardCuratedSignal(PDV_Magnus, PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None)
        return
    endIf

    if PDV_AuriEl
        AwardCuratedSignal(PDV_AuriEl, PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None)
    endIf
EndFunction

Function AwardAltmerOrthodoxSignal(String reason)
    if StringContainsToken(reason, "xarxes") && PDV_Xarxes
        AwardCuratedSignal(PDV_Xarxes, PDV_Xarxes.SIGNAL_LINEAGE_HONORED, None)
        return
    endIf

    if PDV_AuriEl
        AwardCuratedSignal(PDV_AuriEl, PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION, None)
    endIf
EndFunction

Function HandleAltmerMagicSkillIncrease(String skillName)
    if !IsAltmerOrigin() || !PDV_Magnus || !IsAltmerMagicMilestoneSkill(skillName)
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Float skillValue = playerRef.GetActorValue(skillName)
    Int awardedCount = 0

    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 25)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 50)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 75)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 100)

    if awardedCount > 0
        StorageUtil.SetStringValue(None, "PDV.Altmer.LastMagicMilestoneSkill", skillName)
        StorageUtil.SetIntValue(None, "PDV.Altmer.LastMagicMilestoneCount", awardedCount)
        StorageUtil.SetFloatValue(None, "PDV.Altmer.LastMagicMilestoneTime", Utility.GetCurrentGameTime())
        Trace(2, "Altmer magic milestone routed: " + skillName + " x" + awardedCount)
    endIf
EndFunction

Int Function TryAwardAltmerMagicMilestone(String skillName, Float skillValue, Int threshold)
    if skillValue < (threshold as Float)
        return 0
    endIf

    String milestoneKey = "PDV.Altmer.MagicMilestone." + skillName + "." + threshold
    if StorageUtil.GetIntValue(None, milestoneKey) == 1
        return 0
    endIf

    StorageUtil.SetIntValue(None, milestoneKey, 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.LastMagicMilestoneThreshold", threshold)
    AwardCuratedSignalScaled(PDV_Magnus, PDV_Magnus.SIGNAL_MAGIC_MILESTONE, None, 4.0)
    return 1
EndFunction

Bool Function IsAltmerMagicMilestoneSkill(String skillName)
    return skillName == "Alteration" || skillName == "Conjuration" || skillName == "Destruction" || skillName == "Enchanting" || skillName == "Illusion" || skillName == "Restoration"
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

Int Function RecomputeTier(PDV_DeityBase deity, Bool surfaceTierUp = True)
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

        Bool isFocusedEmphasis = IsKhajiitOrigin() && deity == GetKhajiitEmphasisDeity(GetKhajiitFocusedEmphasis())

        if deity == _activeDeity
            deity.OnTierChange(oldTier, newTier)
            RefreshPatronMirrors()
            if surfaceTierUp && newTier > oldTier && NotifyTierUp(deity, newTier)
                SendPrismaEventToast("tier", deity, "", GetPublicTierBand(newTier), "")
            endIf
        elseIf isFocusedEmphasis
            ; No-offer races (Khajiit) reach tiers on an emphasis deity that is never _activeDeity;
            ; still recognize the milestone so the player gets a medium-level notice.
            deity.OnTierChange(oldTier, newTier)
            if surfaceTierUp && newTier > oldTier && NotifyTierUp(deity, newTier)
                SendPrismaEventToast("tier", deity, "", GetPublicTierBand(newTier), "")
                SurfaceTransition("tier", deity.DeityName, "reach", deity.DeityIndex, "")
            endIf
        endIf

        RequestPanelRefresh()
    elseIf deity == _activeDeity
        RefreshPatronMirrors()
    endIf

    return newTier
EndFunction

; Concise top-left notice when a tracked deity advances a tier (active patron or focused emphasis).
Bool Function NotifyTierUp(PDV_DeityBase deity, Int newTier)
    if !deity || newTier <= TIER_NONE
        return False
    endIf

    String shownKey = "PDV.TierNoticeShown." + deity.DeityIndex + "." + newTier
    if StorageUtil.GetIntValue(None, shownKey) == 1
        return False
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    Debug.Notification(deity.DeityName + " marks you as " + GetPublicTierBand(newTier) + ".")
    return True
EndFunction

String Function GetTierStandingLabel(Int tier)
    if tier >= TIER_CHAMPION
        return "Champion"
    elseIf tier >= TIER_DEVOTED
        return "Devoted"
    elseIf tier >= TIER_SEEKER
        return "Seeker"
    endIf
    return "Unrecognized"
EndFunction

; Player-facing devotional band per Architecture v3 Section 2.1 (tier vocabulary
; boundary). PLAYER surfaces (Survey, tier-up notice, champion, neglect) use these
; bands; GetCurrentStandingLabel / GetTierStandingLabel keep the internal
; Seeker/Champion words for dev/MCM/code and the separate Daedric path naming.
String Function GetPublicTierBand(Int tier)
    if tier >= TIER_CHAMPION
        return "Devoted"
    elseIf tier >= TIER_DEVOTED
        return "Faithful"
    elseIf tier >= TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
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

; --- Likes/dislikes table loader (v0: hand-authored from PDV_DeityLikesDislikes.csv) ---
; Resolves deities by DeityName over PDV_FLST_AllDeities and writes the PDV.LD.<evt>.{D,C,O}
; keys read by PDV_DeityBase.ScoreFromTable. Version-gated so existing saves reload on a bump.
; PRODUCTIONIZE: regenerate this from the CSV via an author tool before scaling to all 48 actors.
Function EnsureLikesDislikesTable()
    if StorageUtil.GetIntValue(None, "PDV.LD.Version") == LIKES_DISLIKES_VERSION
        return
    endIf
    LoadLikesDislikesTable()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", LIKES_DISLIKES_VERSION)
EndFunction

Function LoadLikesDislikesTable()
    if !PDV_FLST_AllDeities
        return
    endIf
    Int ldIndex = 0
    Int ldCount = PDV_FLST_AllDeities.GetSize()
    while ldIndex < ldCount
        PDV_DeityBase ldDeity = PDV_FLST_AllDeities.GetAt(ldIndex) as PDV_DeityBase
        if ldDeity
            ClearRowsForDeity(ldDeity)
            LoadRowsForDeity(ldDeity)
            ApplyStancesForDeity(ldDeity)
        endIf
        ldIndex += 1
    endWhile
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Likes/dislikes table + stances loaded (version " + LIKES_DISLIKES_VERSION + ").")
    endIf
EndFunction

Function WriteLD(PDV_DeityBase deity, Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    Form ldForm = deity as Form
    String ldPrefix = "PDV.LD." + eventType
    StorageUtil.SetFloatValue(ldForm, ldPrefix + ".D", delta)
    StorageUtil.SetIntValue(ldForm, ldPrefix + ".C", dailyCap)
    StorageUtil.SetFloatValue(ldForm, ldPrefix + ".O", cooldownDays)
EndFunction

; Clear a deity's entire PDV.LD.* row set before LoadRowsForDeity rewrites it.
; Without this, a row REMOVED from the table (e.g. sithis kill-hostile) leaves
; an orphan StorageUtil key that still scores on every save that ever loaded the
; old version -- a version bump alone does not fix it. Clearing a superset of
; every event the table uses, then rewriting, makes removals actually take.
; MAINTENANCE: GetLikesDislikesEventTypes() must list every event id used in
; LoadRowsForDeity (plus any fully-retired id), or a removed row will not clear.
Function ClearRowsForDeity(PDV_DeityBase deity)
    Form ldForm = deity as Form
    Int[] ldEvents = GetLikesDislikesEventTypes()
    Int ldIndex = 0
    while ldIndex < ldEvents.Length
        String ldPrefix = "PDV.LD." + ldEvents[ldIndex]
        StorageUtil.UnsetFloatValue(ldForm, ldPrefix + ".D")
        StorageUtil.UnsetIntValue(ldForm, ldPrefix + ".C")
        StorageUtil.UnsetFloatValue(ldForm, ldPrefix + ".O")
        ldIndex += 1
    endWhile
EndFunction

Int[] Function GetLikesDislikesEventTypes()
    Int[] ldEvents = new Int[31]
    ldEvents[0] = 1
    ldEvents[1] = 2
    ldEvents[2] = 3
    ldEvents[3] = 4
    ldEvents[4] = 40
    ldEvents[5] = 300
    ldEvents[6] = 301
    ldEvents[7] = 302
    ldEvents[8] = 304
    ldEvents[9] = 313
    ldEvents[10] = 314
    ldEvents[11] = 330
    ldEvents[12] = 331
    ldEvents[13] = 332
    ldEvents[14] = 333
    ldEvents[15] = 334
    ldEvents[16] = 335
    ldEvents[17] = 340
    ldEvents[18] = 341
    ldEvents[19] = 342
    ldEvents[20] = 343
    ldEvents[21] = 344
    ldEvents[22] = 345
    ldEvents[23] = 350
    ldEvents[24] = 351
    ldEvents[25] = 360
    ldEvents[26] = 361
    ldEvents[27] = 362
    ldEvents[28] = 364
    ldEvents[29] = 365
    ldEvents[30] = 368
    return ldEvents
EndFunction

; --- V2 transgressive-Prince path-gated likes/dislikes (separate from the V1 PDV.LD.* table) ---
; The 12 transgressive Princes are PDV_DaedricPath_* actors (not in PDV_FLST_AllDeities), so the
; V1 fan-out never touches them. This loads their rows into PDV.PLD.* on the path form and, for an
; OPEN (committed) path only, deepens that path's OWN piety on a scored act. Version-gated by
; PRINCE_LD_VERSION. Source: PDV_DeityLikesDislikes_Princes_V2.csv via tools/pdv_princeld_gen.mjs.
Function EnsurePrinceLikesDislikesTable()
    if StorageUtil.GetIntValue(None, "PDV.PLD.Version") == PRINCE_LD_VERSION
        return
    endIf
    LoadPrinceLikesDislikesTable()
    StorageUtil.SetIntValue(None, "PDV.PLD.Version", PRINCE_LD_VERSION)
EndFunction

; Hard-switch migration. Saves from before the one-active-pact model could have
; stacked every committed Prince's boon+price spells. Strip all sixteen paths'
; pact spells, then re-establish a single active pact = the most-advanced committed
; Prince. Version-gated so it runs once per save. Curse spells are not pact spells
; and are untouched.
Function MigrateDaedricPactsIfNeeded()
    if StorageUtil.GetIntValue(None, "PDV.Daedric.PactVersion") >= DAEDRIC_PACT_VERSION
        return
    endIf

    Int i = 0
    Int count = GetDaedricPathCount()
    PDV_DaedricPathBase topPath = None
    Int topTier = 0
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path
            path.StripPactSpells()
            if path.GetStoredTier() > topTier
                topTier = path.GetStoredTier()
                topPath = path
            endIf
        endIf
        i += 1
    endWhile

    StorageUtil.FormListClear(None, "PDV.Daedric.LivePactSpells")
    StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
    if topPath && topTier > 0
        topPath.MakeActiveDaedricPact()
    endIf

    StorageUtil.SetIntValue(None, "PDV.Daedric.PactVersion", DAEDRIC_PACT_VERSION)
    if GetDebugLevel() >= 1
        if topPath
            Debug.Trace("[PDV] Daedric pact migration: stripped stacks, active pact = " + topPath.DeityName)
        else
            Debug.Trace("[PDV] Daedric pact migration: stripped stacks, no committed pact")
        endIf
    endIf
EndFunction

Function LoadPrinceLikesDislikesTable()
    if !PDV_FLST_DaedricPaths_All
        return
    endIf
    Int pldIndex = 0
    Int pldCount = PDV_FLST_DaedricPaths_All.GetSize()
    while pldIndex < pldCount
        PDV_DaedricPathBase pldPath = PDV_FLST_DaedricPaths_All.GetAt(pldIndex) as PDV_DaedricPathBase
        if pldPath
            LoadPrinceRowsForPath(pldPath)
        endIf
        pldIndex += 1
    endWhile
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Prince V2 path table loaded (version " + PRINCE_LD_VERSION + ").")
    endIf
EndFunction

Function WritePLD(PDV_DaedricPathBase path, Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    Form pldForm = path as Form
    String pldPrefix = "PDV.PLD." + eventType
    StorageUtil.SetFloatValue(pldForm, pldPrefix + ".D", delta)
    StorageUtil.SetIntValue(pldForm, pldPrefix + ".C", dailyCap)
    StorageUtil.SetFloatValue(pldForm, pldPrefix + ".O", cooldownDays)
EndFunction

; Fan a scored act over the OPEN Daedric paths. An open (committed) path deepens its OWN piety
; (progression + boons/prices), never the ambient V1 pool. ScorePrinceAction enforces the
; path-open gate + anti-farm. actorRef/targetRef kept for parity with the deity fan-out.
Function RouteActionToOpenPaths(Int eventType, Form actorRef, Form targetRef)
    if !PDV_FLST_DaedricPaths_All
        return
    endIf
    Int rop = 0
    Int ropCount = PDV_FLST_DaedricPaths_All.GetSize()
    while rop < ropCount
        PDV_DaedricPathBase ropPath = PDV_FLST_DaedricPaths_All.GetAt(rop) as PDV_DaedricPathBase
        if ropPath
            Float ropDelta = ropPath.ScorePrinceAction(eventType)
            if ropDelta != 0.0
                ropPath.AdjustStoredPiety(ropDelta, "v2_" + eventType)
                RefreshArgonianDominationPressureForPath(ropPath, "prince_v2_" + eventType)
                if GetDebugLevel() >= 2
                    Debug.Trace("[PDV] PrinceV2: " + ropPath.DeityName + " event " + eventType + " deepen " + ropDelta)
                endIf
            endIf
        endIf
        rop += 1
    endWhile
EndFunction

Function LoadPrinceRowsForPath(PDV_DaedricPathBase path)
    String ldName = path.DeityName
    if ldName == "Mehrunes Dagon"
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 302, 1.0, 2, 0.5)
        WritePLD(path, 304, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.5, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 300, 0.5, 3, 0.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 331, -0.25, 3, 0.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
    elseIf ldName == "Hircine"
        WritePLD(path, 1, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 302, 0.5, 3, 0.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
        WritePLD(path, 303, 0.75, 2, 0.5)
        WritePLD(path, 304, -0.5, 3, 0.0)
    elseIf ldName == "Meridia"
        WritePLD(path, 300, 1.0, 2, 0.5)
        WritePLD(path, 365, -2.0, 1, 1.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 303, -0.25, 3, 0.0)
    elseIf ldName == "Molag Bal"
        WritePLD(path, 364, 0.75, 2, 0.5)
        WritePLD(path, 304, 0.75, 2, 0.5)
        WritePLD(path, 366, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.5, 3, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 365, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.5, 3, 0.0)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
    elseIf ldName == "Hermaeus Mora"
        WritePLD(path, 342, 1.0, 2, 0.5)
        WritePLD(path, 341, 0.5, 3, 0.0)
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 343, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 340, 0.5, 3, 0.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 334, 0.25, 3, 0.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
        WritePLD(path, 351, -0.25, 3, 0.0)
    elseIf ldName == "Namira"
        WritePLD(path, 300, -0.5, 3, 0.0)
        WritePLD(path, 367, 2.0, 1, 1.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 313, -0.25, 3, 0.0)
        WritePLD(path, 365, 1.0, 1, 0.5)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
    elseIf ldName == "Nocturnal"
        WritePLD(path, 360, 0.5, 3, 0.0)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 345, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 2, -0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
    elseIf ldName == "Peryite"
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 330, 0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 314, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.25, 3, 0.0)
        WritePLD(path, 333, 0.25, 3, 0.0)
    elseIf ldName == "Sanguine"
        WritePLD(path, 333, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
    elseIf ldName == "Sheogorath"
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 343, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 314, -0.25, 3, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 302, 0.5, 3, 0.0)
        WritePLD(path, 350, 0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
    elseIf ldName == "Vaermina"
        WritePLD(path, 314, 0.5, 3, 0.0)
        WritePLD(path, 342, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.25, 3, 0.0)
        WritePLD(path, 343, 0.25, 3, 0.0)
        WritePLD(path, 304, 0.5, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 341, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 332, -0.25, 3, 0.0)
    elseIf ldName == "Clavicus Vile"
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 354, 0.5, 3, 0.0)
        WritePLD(path, 362, -0.25, 3, 0.0)
        WritePLD(path, 345, 0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
        WritePLD(path, 360, -0.25, 3, 0.0)
    elseIf ldName == "Azura"
        WritePLD(path, 313, 0.5, 3, 0.0)
        WritePLD(path, 350, 0.75, 2, 0.5)
        WritePLD(path, 343, 0.75, 2, 0.5)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 314, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
        WritePLD(path, 365, -0.75, 2, 0.5)
    elseIf ldName == "Boethiah"
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 344, 0.5, 3, 0.0)
        WritePLD(path, 304, 0.75, 2, 0.5)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.5, 2, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 351, -0.75, 1, 0.5)
    elseIf ldName == "Mephala"
        WritePLD(path, 360, 0.5, 3, 0.0)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 304, 1.0, 2, 0.5)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 364, 0.5, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 2, -0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 313, -0.25, 3, 0.0)
    elseIf ldName == "Malacath"
        WritePLD(path, 330, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 1, 0.25, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 362, -0.25, 3, 0.0)
        WritePLD(path, 364, -0.75, 2, 0.5)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 302, 1.0, 2, 0.5)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 360, -0.25, 3, 0.0)
    endIf
EndFunction

Function LoadRowsForDeity(PDV_DeityBase deity)
    String ldName = deity.DeityName
    if ldName == "kyne"
        WriteLD(deity, 1, -3.0, 0, 0.0)
        WriteLD(deity, 2, 0.5, 0, 0.0)
        WriteLD(deity, 3, 0.25, 0, 0.0)
        WriteLD(deity, 4, 0.5, 0, 0.0)
        WriteLD(deity, 40, 0.35, 3, 0.0208)
        WriteLD(deity, 343, 1.0, 2, 0.5)
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 345, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.25, 3, 0.0)
        WriteLD(deity, 302, 1.0, 1, 0.5)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
    elseIf ldName == "akatosh"
        WriteLD(deity, 302, -0.75, 2, 0.5)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.25, 3, 0.0)
        WriteLD(deity, 301, 0.5, 3, 0.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 368, -0.75, 2, 0.5)
    elseIf ldName == "Arkay"
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.5, 1, 1.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 350, 0.5, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 364, -1.0, 2, 0.5)
        WriteLD(deity, 368, -1.0, 2, 0.5)
    elseIf ldName == "Mara"
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 333, 0.5, 3, 0.0)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 314, 0.25, 3, 0.0)
        WriteLD(deity, 364, -1.0, 2, 0.5)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 362, -0.5, 3, 0.0)
        WriteLD(deity, 351, 0.5, 2, 0.0)
    elseIf ldName == "Stendarr"
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 350, 0.5, 3, 0.0)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 364, -1.0, 2, 0.5)
        WriteLD(deity, 368, -1.0, 2, 0.5)
        WriteLD(deity, 365, -1.5, 1, 1.0)
        WriteLD(deity, 362, -0.75, 2, 0.5)
        WriteLD(deity, 361, -0.25, 3, 0.0)
        WriteLD(deity, 351, 0.75, 1, 0.5)
    elseIf ldName == "Zenithar"
        WriteLD(deity, 330, 0.5, 3, 0.0)
        WriteLD(deity, 331, 0.5, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 362, -1.0, 2, 0.5)
        WriteLD(deity, 360, -0.5, 3, 0.0)
        WriteLD(deity, 361, -0.25, 3, 0.0)
        WriteLD(deity, 335, 0.5, 3, 0.0)
        WriteLD(deity, 333, 0.25, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 351, 0.5, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 368, -0.75, 2, 0.5)
    elseIf ldName == "Julianos"
        WriteLD(deity, 340, 0.5, 3, 0.0)
        WriteLD(deity, 341, 0.5, 3, 0.0)
        WriteLD(deity, 342, 0.5, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 331, 0.25, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 362, -0.5, 3, 0.0)
        WriteLD(deity, 364, -0.75, 2, 0.5)
        WriteLD(deity, 361, -0.25, 3, 0.0)
    elseIf ldName == "Dibella"
        WriteLD(deity, 331, 0.5, 3, 0.0)
        WriteLD(deity, 330, 0.25, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 333, 0.25, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 364, -0.5, 3, 0.0)
        WriteLD(deity, 365, -0.75, 2, 0.5)
    elseIf ldName == "Kynareth"
        WriteLD(deity, 313, 0.75, 2, 0.5)
        WriteLD(deity, 345, 0.5, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 350, 0.5, 3, 0.0)
        WriteLD(deity, 343, 1.0, 2, 0.5)
        WriteLD(deity, 301, 0.5, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 368, -1.0, 1, 0.5)
        WriteLD(deity, 334, 0.25, 3, 0.0)
    elseIf ldName == "Talos"
        WriteLD(deity, 343, 1.0, 2, 0.5)
        WriteLD(deity, 345, 0.5, 3, 0.0)
        WriteLD(deity, 2, 0.5, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 302, 1.5, 1, 1.0)
        WriteLD(deity, 362, -0.5, 3, 0.0)
        WriteLD(deity, 364, -0.75, 2, 0.5)
    elseIf ldName == "Shor"
        WriteLD(deity, 343, 0.5, 3, 0.0)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 2, 0.5, 3, 0.0)
        WriteLD(deity, 302, 1.0, 1, 0.5)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 364, -1.0, 2, 0.5)
        WriteLD(deity, 362, -0.5, 3, 0.0)
    elseIf ldName == "Tsun"
        WriteLD(deity, 2, 0.75, 2, 0.5)
        WriteLD(deity, 343, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 350, 0.25, 3, 0.0)
        WriteLD(deity, 302, 0.75, 1, 0.5)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 301, 0.5, 3, 0.0)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 364, -1.0, 2, 0.5)
        WriteLD(deity, 368, -1.0, 2, 0.5)
    elseIf ldName == "Stuhn"
        WriteLD(deity, 2, 0.5, 3, 0.0)
        WriteLD(deity, 304, -2.0, 1, 1.0)
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 300, 0.25, 3, 0.0)
        WriteLD(deity, 362, -0.75, 2, 0.5)
        WriteLD(deity, 360, -0.5, 3, 0.0)
    elseIf ldName == "auri-el"
        WriteLD(deity, 344, 0.5, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 304, -1.5, 1, 1.0)
        WriteLD(deity, 368, -1.0, 2, 0.5)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 365, -1.5, 1, 1.0)
        WriteLD(deity, 364, -0.5, 3, 0.0)
    elseIf ldName == "magnus"
        WriteLD(deity, 341, 0.75, 2, 0.5)
        WriteLD(deity, 331, 0.5, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 365, -0.75, 2, 0.5)
        WriteLD(deity, 368, -0.75, 1, 0.5)
    elseIf ldName == "xarxes"
        WriteLD(deity, 342, 0.75, 2, 0.5)
        WriteLD(deity, 340, 0.5, 3, 0.0)
        WriteLD(deity, 341, 0.5, 3, 0.0)
        WriteLD(deity, 331, 0.25, 3, 0.0)
        WriteLD(deity, 343, 0.25, 3, 0.0)
        WriteLD(deity, 368, -0.5, 3, 0.0)
        WriteLD(deity, 344, 0.5, 3, 0.0)
        WriteLD(deity, 345, 0.25, 3, 0.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 304, -0.75, 2, 0.5)
    elseIf ldName == "trinimac"
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 2, 0.5, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 368, -2.0, 1, 1.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 365, -0.75, 2, 0.5)
        WriteLD(deity, 302, 1.0, 1, 0.5)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 330, 0.25, 3, 0.0)
        WriteLD(deity, 362, -0.5, 3, 0.0)
        WriteLD(deity, 364, -0.75, 2, 0.5)
    elseIf ldName == "Y'ffre"
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 330, -0.25, 3, 0.0)
        WriteLD(deity, 364, -0.5, 3, 0.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 333, 0.5, 3, 0.0)
        WriteLD(deity, 331, -0.25, 3, 0.0)
    elseIf ldName == "Z'en"
        WriteLD(deity, 333, 0.5, 3, 0.0)
        WriteLD(deity, 330, 0.5, 3, 0.0)
        WriteLD(deity, 332, 0.25, 3, 0.0)
        WriteLD(deity, 340, 0.25, 3, 0.0)
        WriteLD(deity, 362, -0.75, 2, 0.5)
        WriteLD(deity, 331, 0.25, 3, 0.0)
        WriteLD(deity, 360, -0.25, 3, 0.0)
        WriteLD(deity, 350, 0.5, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 364, -0.5, 3, 0.0)
    elseIf ldName == "Baan Dar"
        WriteLD(deity, 360, 0.25, 3, 0.0)
        WriteLD(deity, 362, 0.5, 3, 0.0)
        WriteLD(deity, 361, 0.25, 3, 0.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 345, 0.5, 3, 0.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 364, 0.5, 2, 0.0)
        WriteLD(deity, 330, -0.25, 3, 0.0)
    elseIf ldName == "khenarthi"
        WriteLD(deity, 345, 0.5, 3, 0.0)
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 302, 0.75, 2, 0.5)
        WriteLD(deity, 365, -0.75, 2, 0.5)
        WriteLD(deity, 350, 0.25, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 304, -1.0, 2, 0.5)
    elseIf ldName == "rajhin"
        WriteLD(deity, 362, 0.5, 3, 0.0)
        WriteLD(deity, 360, 0.5, 3, 0.0)
        WriteLD(deity, 361, 0.25, 3, 0.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 345, 0.25, 3, 0.0)
        WriteLD(deity, 364, -0.5, 3, 0.0)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 314, -0.25, 3, 0.0)
    elseIf ldName == "alkosh"
        WriteLD(deity, 302, 1.5, 1, 1.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 364, -0.5, 3, 0.0)
        WriteLD(deity, 361, -0.25, 3, 0.0)
        WriteLD(deity, 365, -1.0, 2, 0.5)
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 368, -0.75, 2, 0.5)
        WriteLD(deity, 342, 0.25, 3, 0.0)
    elseIf ldName == "azurah"
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 368, 0.5, 3, 0.0)
        WriteLD(deity, 345, 0.5, 3, 0.0)
        WriteLD(deity, 331, 0.5, 3, 0.0)
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 365, -1.5, 1, 1.0)
        WriteLD(deity, 364, -1.0, 2, 0.5)
    elseIf ldName == "Boethiah"
        WriteLD(deity, 2, 0.25, 3, 0.0)
        WriteLD(deity, 344, 0.5, 3, 0.0)
        WriteLD(deity, 304, 0.75, 2, 0.5)
        WriteLD(deity, 368, 1.5, 1, 1.0)
        WriteLD(deity, 350, -0.25, 3, 0.0)
        WriteLD(deity, 360, 0.25, 3, 0.0)
        WriteLD(deity, 1, 0.25, 3, 0.0)
        WriteLD(deity, 343, 0.5, 3, 0.0)
        WriteLD(deity, 362, 0.25, 3, 0.0)
        WriteLD(deity, 314, -0.25, 3, 0.0)
        WriteLD(deity, 333, -0.25, 3, 0.0)
    elseIf ldName == "Mephala"
        WriteLD(deity, 360, 0.5, 3, 0.0)
        WriteLD(deity, 362, 0.5, 3, 0.0)
        WriteLD(deity, 304, 1.0, 2, 0.5)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 368, 1.5, 1, 1.0)
        WriteLD(deity, 361, 0.25, 3, 0.0)
        WriteLD(deity, 364, 1.0, 2, 0.5)
        WriteLD(deity, 2, -0.25, 3, 0.0)
        WriteLD(deity, 350, -0.5, 2, 0.0)
        WriteLD(deity, 313, -0.25, 2, 0.0)
    elseIf ldName == "The Hist"
        WriteLD(deity, 313, 0.5, 3, 0.0)
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 333, 0.25, 3, 0.0)
        WriteLD(deity, 304, -1.0, 2, 0.5)
        WriteLD(deity, 365, -0.75, 2, 0.5)
        WriteLD(deity, 314, 0.25, 1, 0.0)
        WriteLD(deity, 332, 0.5, 3, 0.0)
        WriteLD(deity, 334, 0.5, 3, 0.0)
        WriteLD(deity, 364, -0.5, 3, 0.0)
        WriteLD(deity, 331, -0.25, 3, 0.0)
    elseIf ldName == "sithis"
        WriteLD(deity, 304, 1.0, 2, 0.5)
        WriteLD(deity, 365, -0.75, 2, 0.5)
        WriteLD(deity, 314, -0.25, 1, 0.0)
        WriteLD(deity, 364, 0.5, 3, 0.0)
        WriteLD(deity, 350, -0.5, 3, 0.0)
        WriteLD(deity, 302, 1.0, 1, 0.5)
        WriteLD(deity, 360, 0.5, 3, 0.0)
        WriteLD(deity, 361, 0.25, 3, 0.0)
        WriteLD(deity, 330, -0.5, 3, 0.0)
        WriteLD(deity, 331, -0.5, 3, 0.0)
    elseIf ldName == "Malacath"
        WriteLD(deity, 330, 0.75, 2, 0.5)
        WriteLD(deity, 2, 0.25, 3, 0.0)
        WriteLD(deity, 1, 0.25, 3, 0.0)
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 362, -0.25, 3, 0.0)
        WriteLD(deity, 364, -0.75, 2, 0.5)
        WriteLD(deity, 302, 0.75, 1, 0.5)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 314, -0.25, 3, 0.0)
    elseIf ldName == "Tu'whacca"
        WriteLD(deity, 300, 0.5, 3, 0.0)
        WriteLD(deity, 314, 0.25, 3, 0.0)
        WriteLD(deity, 342, 0.25, 3, 0.0)
        WriteLD(deity, 350, 0.75, 2, 0.5)
        WriteLD(deity, 365, -1.5, 1, 1.0)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 301, 0.75, 2, 0.5)
        WriteLD(deity, 368, -1.0, 2, 0.5)
    elseIf ldName == "Leki"
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 330, 0.75, 2, 0.5)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 304, -0.75, 2, 0.5)
        WriteLD(deity, 362, -0.25, 3, 0.0)
        WriteLD(deity, 302, 1.0, 1, 0.5)
        WriteLD(deity, 340, 0.25, 3, 0.0)
        WriteLD(deity, 364, -0.75, 2, 0.5)
    elseIf ldName == "HoonDing"
        WriteLD(deity, 302, 1.5, 1, 1.0)
        WriteLD(deity, 344, 0.25, 3, 0.0)
        WriteLD(deity, 345, 0.25, 3, 0.0)
        WriteLD(deity, 343, 0.75, 2, 0.5)
        WriteLD(deity, 304, -0.25, 3, 0.0)
        WriteLD(deity, 313, 0.25, 3, 0.0)
        WriteLD(deity, 360, 0.25, 3, 0.0)
        WriteLD(deity, 361, 0.25, 3, 0.0)
        WriteLD(deity, 314, -0.25, 3, 0.0)
        WriteLD(deity, 365, -0.75, 2, 0.5)
    endIf
EndFunction

Function ApplyStances(PDV_DeityBase deity, Int sNord, Int sImperial, Int sBreton, Int sAltmer, Int sBosmer, Int sDunmer, Int sKhajiit, Int sArgonian, Int sOrc, Int sRedguard)
    deity.Stance_Nord = sNord
    deity.Stance_Imperial = sImperial
    deity.Stance_Breton = sBreton
    deity.Stance_Altmer = sAltmer
    deity.Stance_Bosmer = sBosmer
    deity.Stance_Dunmer = sDunmer
    deity.Stance_Khajiit = sKhajiit
    deity.Stance_Argonian = sArgonian
    deity.Stance_Orc = sOrc
    deity.Stance_Redguard = sRedguard
EndFunction

; Runtime stance migration from references/phase4/PDV_StanceMatrix.csv. Existing saves bake VMAD
; property values at first quest init and never re-read them, so the ESP stance write only reaches
; new games; this re-applies the correct stances on every save via the version gate. Mirror of
; tools/pdv-stance-author. NATIVE=0 FOREIGN=1 TABOO=2 HOSTILE=3; order Nord,Imp,Bret,Alt,Bos,Dun,Kha,Arg,Orc,Red.
Function ApplyStancesForDeity(PDV_DeityBase deity)
    String sName = deity.DeityName
    if sName == "kyne"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Talos"
        ApplyStances(deity, 0, 1, 0, 3, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Shor"
        ApplyStances(deity, 0, 1, 3, 3, 1, 1, 1, 1, 1, 3)
    elseIf sName == "Tsun"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Stuhn"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Kynareth"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Mara"
        ApplyStances(deity, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1)
    elseIf sName == "akatosh"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Arkay"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Stendarr"
        ApplyStances(deity, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Julianos"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Dibella"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Zenithar"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "magnus"
        ApplyStances(deity, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Y'ffre"
        ApplyStances(deity, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1)
    elseIf sName == "auri-el"
        ApplyStances(deity, 1, 1, 1, 0, 0, 1, 1, 1, 3, 1)
    elseIf sName == "xarxes"
        ApplyStances(deity, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1)
    elseIf sName == "azurah"
        ApplyStances(deity, 2, 2, 1, 2, 1, 0, 0, 1, 2, 1)
    elseIf sName == "Boethiah"
        ApplyStances(deity, 2, 2, 1, 3, 1, 0, 0, 1, 3, 1)
    elseIf sName == "Mephala"
        ApplyStances(deity, 2, 2, 1, 2, 1, 0, 0, 1, 2, 1)
    elseIf sName == "Baan Dar"
        ApplyStances(deity, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1)
    elseIf sName == "rajhin"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "alkosh"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "khenarthi"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "Tu'whacca"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "Leki"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "HoonDing"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "Malacath"
        ApplyStances(deity, 1, 2, 1, 2, 1, 2, 1, 1, 0, 3)
    elseIf sName == "The Hist"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1)
    elseIf sName == "sithis"
        ApplyStances(deity, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2)
    elseIf sName == "trinimac"
        ApplyStances(deity, 1, 1, 1, 0, 1, 1, 1, 1, 2, 1)
    elseIf sName == "Z'en"
        ApplyStances(deity, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1)
    endIf
EndFunction

Function ProcessDawn()
    if !PDV_FLST_AllDeities
        Debug.Trace("[PDV] ProcessDawn: PDV_FLST_AllDeities not assigned.")
        return
    endIf

    RunDawnAwardAltmerAuriElDawn()
    RunDawnConsolidateScratch()
    RunDawnRefreshTrackStates()
    RunDawnApplyDecayNoop()
    RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnProcessCommitmentOffersNoop()
    RunDawnNotifyNoop()
    SyncKhajiitPhaseBlessing()
    ProcessKhajiitAlkoshWordDrip()
    RequestPanelRefresh()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] ProcessDawn complete.")
    endIf
EndFunction

Function RunDawnAwardAltmerAuriElDawn()
    if !IsAltmerOrigin() || !PDV_AuriEl
        return
    endIf

    Int dawnDay = (Utility.GetCurrentGameTime() - 0.25) as Int
    if StorageUtil.GetIntValue(None, "PDV.Altmer.AuriElDawn.LastDay") == dawnDay
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Altmer.AuriElDawn.LastDay", dawnDay)
    AwardCuratedSignalScaled(PDV_AuriEl, PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None, 2.0)
    Trace(2, "Altmer Auri-El dawn acknowledgment routed for day " + dawnDay)
EndFunction

Function RunDawnConsolidateScratch()
    _dawnHadActivity = False
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
                clampedToday = clampedToday * GetImperialCurseGainMultiplier(deity)
            endIf
            Float oldPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
            Float newPiety = ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)

            StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
            StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
            if clampedToday != 0.0
                StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
                _dawnHadActivity = True
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
        RefreshKhajiitLunarPosture("dawn")
    endIf

    if IsArgonianOrigin()
        RunDawnRefreshArgonianHist()
    endIf

    if IsOrcOrigin()
        EvaluateOrcLifeModeAtDawn()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        DecayBretonWitchcraftExposureAtDawn()
    endIf

    if IsBosmerOrigin() && PDV_BosmerPathTrack
        EnsureBosmerCurrentPathFallback()
        EvaluateBosmerForcedReckoning()
        SyncBosmerNaming(Game.GetPlayer())
        ArmBosmerDreamOnPathChange()
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
        SyncFirstTierRaceRewardRuntime()
        return
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || !_activeDeity
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", 0)
        SyncKyneNeglectSpell(False)
        UpdateContextualFavorRuntime()
        SyncFirstTierRaceRewardRuntime()
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
        SurfaceTransition("neglect", _activeDeity.DeityName, "drop", _activeDeity.DeityIndex, "absence")
        ; Prisma toast is overlay-only; give a reliable vanilla top-left notice when
        ; a patron's regard first lapses, so neglect is not silent without the overlay.
        Debug.Notification(_activeDeity.DeityName + "'s regard fades as your devotion goes quiet.")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", BoolToInt(patronNeglected))
    SyncFirstTierRaceRewardRuntime()
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
    ; Prisma toast is overlay-only and no-ops without the bridge; give a reliable
    ; vanilla top-left notice when the dawn actually consolidated devotion this cycle.
    if _dawnHadActivity
        Debug.Notification("Your devotions settle with the dawn.")
    endIf
    RefreshDiegeticMedallion("dawn")
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
    RecomputeTier(_activeDeity, False)
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
    RecomputeTier(deity, False)
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
    Int shown = 0

    ; Only list deities that have moved (stored piety, scratch piety, or a tier), so the
    ; message box stays short and readable instead of dumping the whole roster at zero.
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float piety = GetPiety(deity)
            Float today = GetPietyToday(deity)
            Int tier = GetTier(deity)
            if piety != 0.0 || today != 0.0 || tier != 0
                String entry = deity.DeityName + ": tier=" + tier + " piety=" + piety + " scratch=" + today
                if output == ""
                    output = entry
                else
                    output = output + "\n" + entry
                endIf
                shown += 1
            endIf
        endIf
        i += 1
    endWhile

    if shown == 0
        return "All " + count + " deities are at zero (no piety, scratch, or tier yet)."
    endIf

    return "Active deities (" + shown + " of " + count + "):\n" + output
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
        appliedAmount = appliedAmount * GetSurvivalContextGainMultiplier(deity)
        appliedAmount = appliedAmount * GetKhajiitLunarAlignmentMultiplier(deity)
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

;/ =====================================================================
    Survival-mod compatibility (CONTEXT ONLY)
    ---------------------------------------------------------------------
    Optional, policy-compliant integration: a detected survival mod's needs
    state modulates earned piety as a bounded multiplier - it is never a piety
    source (it can only scale an already-earned gain, and only downward, as a
    mild anti-farm under hardship). Disabled cleanly when no survival mod is
    present or the toggle is off. All optional forms are resolved once via
    GetModByName / GetFormFromFile and cached, never re-read in the hot path.
    Form evidence: references/vanilla-gameplay/compatibility/PDV_CompatInvestigation_Findings.md
   ===================================================================== /;
Bool _pdvSurvivalContextInit = False
Bool _pdvSurvivalModePresent = False
Bool _pdvSunHelmPresent = False
GlobalVariable _pdvSurvModeEnabled
GlobalVariable _pdvSurvHunger
GlobalVariable _pdvSurvCold
GlobalVariable _pdvSurvExhaustion
GlobalVariable _pdvSunHelmEnabled
GlobalVariable _pdvSunHelmHunger
GlobalVariable _pdvSunHelmThirst
GlobalVariable _pdvSunHelmCold
GlobalVariable _pdvSunHelmFatigue

String Property COMPAT_SURVIVAL_TOGGLE_KEY = "PDV.Compat.SurvivalContextEnabled" AutoReadOnly
Float Property SURVIVAL_DAMP_PER_SEVERITY = 0.0267 AutoReadOnly

Function InitSurvivalContext()
    if _pdvSurvivalContextInit
        return
    endIf
    _pdvSurvivalContextInit = True

    if Game.GetModByName("ccQDRSSE001-SurvivalMode.esl") != 255
        _pdvSurvivalModePresent = True
        _pdvSurvModeEnabled = Game.GetFormFromFile(0x000826, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvHunger = Game.GetFormFromFile(0x00081A, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvCold = Game.GetFormFromFile(0x00081B, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvExhaustion = Game.GetFormFromFile(0x000816, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
    endIf

    if Game.GetModByName("SunHelmSurvival.esp") != 255
        _pdvSunHelmPresent = True
        _pdvSunHelmEnabled = Game.GetFormFromFile(0x02EB63, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmHunger = Game.GetFormFromFile(0x00EAAE, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmThirst = Game.GetFormFromFile(0x05C472, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmCold = Game.GetFormFromFile(0x6A13C5, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmFatigue = Game.GetFormFromFile(0x021E3F, "SunHelmSurvival.esp") as GlobalVariable
    endIf
EndFunction

Bool Function IsSurvivalContextEnabled()
    return StorageUtil.GetIntValue(None, COMPAT_SURVIVAL_TOGGLE_KEY, 1) != 0
EndFunction

Int Function GetSurvivalContextSeverity()
    if !IsSurvivalContextEnabled()
        return 0
    endIf

    InitSurvivalContext()

    Int severity = 0

    if _pdvSurvivalModePresent && _pdvSurvModeEnabled && _pdvSurvModeEnabled.GetValueInt() != 0
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSurvHunger))
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSurvCold))
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSurvExhaustion))
    endIf

    if _pdvSunHelmPresent && _pdvSunHelmEnabled && _pdvSunHelmEnabled.GetValueInt() != 0
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSunHelmHunger))
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSunHelmThirst))
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSunHelmCold))
        severity = MaxSeverity(severity, NeedToSeverity(_pdvSunHelmFatigue))
    endIf

    return severity
EndFunction

Int Function NeedToSeverity(GlobalVariable needGlobal)
    if !needGlobal
        return 0
    endIf

    Float needValue = needGlobal.GetValue()
    if needValue >= 75.0
        return 3
    elseIf needValue >= 50.0
        return 2
    elseIf needValue >= 25.0
        return 1
    endIf
    return 0
EndFunction

Int Function MaxSeverity(Int leftValue, Int rightValue)
    if leftValue >= rightValue
        return leftValue
    endIf
    return rightValue
EndFunction

Float Function GetSurvivalContextGainMultiplier(PDV_DeityBase deity)
    Int severity = GetSurvivalContextSeverity()
    if severity <= 0
        return 1.0
    endIf

    Float multiplier = 1.0 - (severity * SURVIVAL_DAMP_PER_SEVERITY)
    if multiplier < 0.9
        multiplier = 0.9
    endIf
    return multiplier
EndFunction

String Function GetSurvivalContextStatusLine()
    InitSurvivalContext()

    String detected = ""
    if _pdvSurvivalModePresent
        detected = "Survival Mode"
    endIf
    if _pdvSunHelmPresent
        if detected != ""
            detected = detected + ", "
        endIf
        detected = detected + "SunHelm"
    endIf

    if detected == ""
        return "No supported survival mod detected"
    endIf

    if !IsSurvivalContextEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | " + SeverityLabel(GetSurvivalContextSeverity())
EndFunction

String Function SeverityLabel(Int severity)
    if severity <= 0
        return "comfortable"
    elseIf severity == 1
        return "mild hardship"
    elseIf severity == 2
        return "moderate hardship"
    endIf
    return "severe hardship"
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

Function SyncFirstTierRaceRewardRuntime()
    Actor playerRef = Game.GetPlayer()
    Spell activeReward = GetFirstTierRaceRewardSpellForOrigin()
    Bool shouldBeActive = IsFirstTierRaceRewardEligible() && activeReward

    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T1, shouldBeActive && activeReward == PDV_Bless_Altmer_Orthodox_T1, "Altmer T1")
    ; Argonian Hist_T1 is intentionally absent here: SyncArgonianRewards owns it on the substrate
    ; tier (no-offer). Managing it in this active-patron path too would fight that grant.
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T1, shouldBeActive && activeReward == PDV_Bless_Bosmer_Yffre_T1, "Bosmer T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T1, shouldBeActive && activeReward == PDV_Bless_Breton_Tradition_T1, "Breton T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T1, shouldBeActive && activeReward == PDV_Bless_Dunmer_Reclamation_T1, "Dunmer T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T1, shouldBeActive && activeReward == PDV_Bless_Imperial_Civic_T1, "Imperial T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Lunar_T1, shouldBeActive && activeReward == PDV_Bless_Khajiit_Lunar_T1, "Khajiit T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T1, shouldBeActive && activeReward == PDV_Bless_Nord_OldWays_T1, "Nord T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T1, shouldBeActive && activeReward == PDV_Bless_Orc_Malacath_T1, "Orc T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T1, shouldBeActive && activeReward == PDV_Bless_Redguard_AncestorSpine_T1, "Redguard T1")

    if shouldBeActive
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Active", 1)
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Origin", GetPlayerOriginRaceIndex())
    else
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Active", 0)
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Origin", -1)
    endIf

    ; Khajiit is a no-offer race: its emphasis rewards gate on the focused emphasis deity's
    ; piety tier (not active-patron), and its broad lunar reward is the substrate boon layer.
    SyncKhajiitEmphasisRewards(playerRef)
    SyncKhajiitNeglectSpell(IsKhajiitLunarNeglected())

    ; Altmer is an offer race: broad orthodoxy T1 remains on the existing first-tier path while
    ; focused Auri-El/Magnus/Xarxes families gate on the active patron's tier.
    SyncAltmerRewards(playerRef)
    SyncAltmerNeglectSpell(IsAltmerCoherenceNeglected())

    ; Bosmer is path-state gated: Y'ffre broad remains soft/capped, and the active path family
    ; uses the path scoring deity tier while clearing every other path reward.
    SyncBosmerRewards(playerRef)
    SyncBosmerNeglectSpell(IsBosmerPathNeglected())

    ; Breton is tradition-state gated. The chosen tradition selects exactly one focused family;
    ; the broad tradition reward remains softer and capped at Faithful.
    SyncBretonRewards(playerRef)
    SyncBretonNeglectSpell(IsBretonTraditionNeglected())

    ; Dunmer is hybrid: ancestor substrate is always-on identity, while the Reclamation foreground
    ; remains an active-patron offer lane with one focused patron active at a time.
    SyncDunmerRewards(playerRef)
    SyncDunmerNeglectSpell(IsDunmerAncestorNeglected())

    ; Orc is state-enum gated: one life-mode focused family can be active at a time, all under
    ; Malacath as the single religious spine.
    SyncOrcRewards(playerRef)
    SyncOrcNeglectSpell(IsOrcCodeNeglected())

    ; Redguard is state-enum gated: the sect filters the Yokudan lane, then exactly one focused
    ; patron family can be active at a time.
    SyncRedguardRewards(playerRef)
    SyncRedguardNeglectSpell(IsRedguardAncestorDistanceNeglected())

    ; Nord is state-enum gated: the baseline selects Old Ways or Nine Divines, and only a patron
    ; from that baseline can carry focused rewards. Kyne neglect remains the existing Nord neglect.
    SyncNordRewards(playerRef)

    ; Argonian is the second no-offer race: rewards gate on the Hist substrate relations + People
    ; focus + Void-active (not active-patron), so the broad Hist set runs without an offer.
    SyncArgonianRewards(playerRef)
    SyncArgonianNeglectSpell(IsArgonianHistNeglected())

    ; Imperial is an offer race: broad civic T1 remains on the existing first-tier path while the
    ; focused Divine/Talos families gate on the active patron's tier.
    SyncImperialRewards(playerRef)
    SyncImperialNeglectSpell(IsImperialCivicNeglected())
EndFunction

Function SyncAltmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isAltmer = GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
    Bool broadOrthodoxFaithful = isAltmer && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count") + StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T2, broadOrthodoxFaithful, "Altmer Orthodox T2")

    SyncAltmerRewardFamily(playerRef, PDV_AuriEl, PDV_Bless_Altmer_AuriEl_T1, PDV_Bless_Altmer_AuriEl_T2, PDV_Bless_Altmer_AuriEl_T3, "Auri-El")
    SyncAltmerRewardFamily(playerRef, PDV_Magnus, PDV_Bless_Altmer_Magnus_T1, PDV_Bless_Altmer_Magnus_T2, PDV_Bless_Altmer_Magnus_T3, "Magnus")
    SyncAltmerRewardFamily(playerRef, PDV_Xarxes, PDV_Bless_Altmer_Xarxes_T1, PDV_Bless_Altmer_Xarxes_T2, PDV_Bless_Altmer_Xarxes_T3, "Xarxes")
EndFunction

Function SyncAltmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_ALTMER && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Altmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Altmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Altmer " + label + " T3")
EndFunction

Bool Function IsAltmerCoherenceNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_ALTMER
        return False
    endIf

    if IsAltmerFavorSuppressedByCurse()
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Altmer.Favor.LastGameTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 3.0
EndFunction

Function SyncAltmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Altmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Altmer)
            playerRef.AddSpell(PDV_SPEL_Neglect_Altmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Altmer)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Altmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 0)
    endIf
EndFunction

Function SyncBosmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isBosmer = GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
    Int pathState = GetBosmerPathState()
    Bool broadFaithful = isBosmer && GetPatronState() == PATRON_STATE_BROAD && GetBosmerFavorSignalCount() >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T2, broadFaithful, "Bosmer Yffre T2")

    SyncBosmerPathRewardFamily(playerRef, BOSMER_PATH_OLD_CONTRACT, pathState, PDV_Yffre, PDV_Bless_Bosmer_OldContract_T1, PDV_Bless_Bosmer_OldContract_T2, PDV_Bless_Bosmer_OldContract_T3, "OldContract")
    SyncBosmerPathRewardFamily(playerRef, BOSMER_PATH_LIVING_STORY, pathState, PDV_Yffre, PDV_Bless_Bosmer_LivingStory_T1, PDV_Bless_Bosmer_LivingStory_T2, PDV_Bless_Bosmer_LivingStory_T3, "LivingStory")
    SyncBosmerPathRewardFamily(playerRef, BOSMER_PATH_EXCHANGE, pathState, PDV_Zen, PDV_Bless_Bosmer_Exchange_T1, PDV_Bless_Bosmer_Exchange_T2, PDV_Bless_Bosmer_Exchange_T3, "Exchange")
    SyncBosmerPathRewardFamily(playerRef, BOSMER_PATH_BANDIT_ROAD, pathState, PDV_BaanDar, PDV_Bless_Bosmer_BanditRoad_T1, PDV_Bless_Bosmer_BanditRoad_T2, PDV_Bless_Bosmer_BanditRoad_T3, "BanditRoad")
EndFunction

Function SyncBosmerPathRewardFamily(Actor playerRef, Int thisPath, Int activePath, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_BOSMER && thisPath == activePath
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Bosmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Bosmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Bosmer " + label + " T3")
EndFunction

Int Function GetBosmerPathState()
    if PDV_BosmerPathTrack
        Int pathState = PDV_BosmerPathTrack.GetCurrentState()
        if pathState >= BOSMER_PATH_OLD_CONTRACT && pathState <= BOSMER_PATH_BANDIT_ROAD
            return pathState
        endIf
    endIf

    return BOSMER_PATH_LIVING_STORY
EndFunction

Int Function GetBosmerFavorSignalCount()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.Favor.SignalCount")
EndFunction

Bool Function IsBosmerPathNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return False
    endIf

    Int pathState = GetBosmerPathState()
    if pathState == BOSMER_PATH_EXCHANGE
        return IsNeglectFlagActive(PDV_Zen)
    elseIf pathState == BOSMER_PATH_BANDIT_ROAD
        return IsNeglectFlagActive(PDV_BaanDar)
    endIf

    return IsNeglectFlagActive(PDV_Yffre)
EndFunction

Function SyncBosmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Bosmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Bosmer)
            playerRef.AddSpell(PDV_SPEL_Neglect_Bosmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Bosmer)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Bosmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 0)
    endIf
EndFunction

Function SyncBretonRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isBreton = GetPlayerOriginRaceIndex() == ORIGIN_BRETON
    if isBreton
        EnsureBretonDruidicForkInitialized()
    endIf

    Int traditionValue = GetBretonTraditionValue()
    Bool broadFaithful = isBreton && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Breton.TraditionHookCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T2, broadFaithful, "Breton Tradition T2")

    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_KNIGHTS_ROAD, traditionValue, PDV_Stendarr, PDV_Bless_Breton_KnightsRoad_T1, PDV_Bless_Breton_KnightsRoad_T2, PDV_Bless_Breton_KnightsRoad_T3, "KnightsRoad")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_HIDDEN_ART, traditionValue, PDV_Julianos, PDV_Bless_Breton_HiddenArt_T1, PDV_Bless_Breton_HiddenArt_T2, PDV_Bless_Breton_HiddenArt_T3, "HiddenArt")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_GREEN_WAY, traditionValue, PDV_Kynareth, PDV_Bless_Breton_GreenWay_T1, PDV_Bless_Breton_GreenWay_T2, PDV_Bless_Breton_GreenWay_T3, "GreenWay")
    SyncBretonKnightlyVowCreedLossSpells(isBreton && traditionValue == BRETON_TRADITION_KNIGHTS_ROAD)
    SyncBretonWitchcraftExposureRuptureSpell(isBreton)
    SyncBretonDruidicForkBetrayalSpell(isBreton && GetBretonDruidicForkValue() == BRETON_DRUIDIC_FORK_BETRAYED)
EndFunction

Function SyncBretonTraditionRewardFamily(Actor playerRef, Int thisTradition, Int activeTradition, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_BRETON && thisTradition == activeTradition
    if thisTradition == BRETON_TRADITION_HIDDEN_ART && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
        isActive = False
    endIf
    if thisTradition == BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        isActive = False
    endIf

    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Breton " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Breton " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Breton " + label + " T3")
EndFunction

Int Function GetBretonTraditionValue()
    Int traditionValue = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if traditionValue >= BRETON_TRADITION_KNIGHTS_ROAD && traditionValue <= BRETON_TRADITION_GREEN_WAY
        return traditionValue
    endIf

    return BRETON_TRADITION_KNIGHTS_ROAD
EndFunction

Int Function GetBretonDruidicForkValue()
    Int forkValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicFork", BRETON_DRUIDIC_FORK_NONE)
    if forkValue >= BRETON_DRUIDIC_FORK_NONE && forkValue <= BRETON_DRUIDIC_FORK_BETRAYED
        return forkValue
    endIf

    return BRETON_DRUIDIC_FORK_NONE
EndFunction

Function SetBretonDruidicFork(Int forkValue, String reason)
    Int normalized = ClampInt(forkValue, BRETON_DRUIDIC_FORK_NONE, BRETON_DRUIDIC_FORK_BETRAYED)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicFork", normalized)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastDruidicForkReason", reason)
    if PDV_GLO_State_BretonDruidicFork
        PDV_GLO_State_BretonDruidicFork.SetValue(normalized as Float)
    endIf
EndFunction

Function EnsureBretonDruidicForkInitialized()
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return
    endIf

    Int current = GetBretonDruidicForkValue()
    if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicForkInitialized") != 1
        if GetBretonTraditionValue() == BRETON_TRADITION_GREEN_WAY
            SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "breton_greenway_default")
        else
            SetBretonDruidicFork(current, "breton_non_greenway_default")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    elseIf PDV_GLO_State_BretonDruidicFork
        PDV_GLO_State_BretonDruidicFork.SetValue(current as Float)
    endIf
EndFunction

Bool Function IsBretonGreenWayForkEligible()
    if GetBretonTraditionValue() != BRETON_TRADITION_GREEN_WAY
        return False
    endIf

    return GetBretonDruidicForkValue() == BRETON_DRUIDIC_FORK_DRUIDIC
EndFunction

String Function GetBretonDruidicForkLabel()
    Int forkValue = GetBretonDruidicForkValue()
    if forkValue == BRETON_DRUIDIC_FORK_DRUIDIC
        return "Druidic"
    elseIf forkValue == BRETON_DRUIDIC_FORK_WEREWOLF
        return "Werewolf"
    elseIf forkValue == BRETON_DRUIDIC_FORK_BETRAYED
        return "Betrayed"
    endIf

    return "None"
EndFunction

Bool Function IsBretonTraditionNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Breton.LastTraditionSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncBretonNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Breton
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Breton)
            playerRef.AddSpell(PDV_SPEL_Neglect_Breton, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Breton)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Breton)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 0)
    endIf
EndFunction

Function SyncBretonKnightlyVowCreedLossSpells(Bool isKnightsRoadBreton)
    Int integrityValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
    Bool isStrained = isKnightsRoadBreton && integrityValue >= 30 && integrityValue < 70
    Bool isBroken = isKnightsRoadBreton && integrityValue < 30

    SyncBretonCreedLossSpell(PDV_SPEL_CreedLoss_Breton_VowIntegrity, isStrained, "PDV.CreedLoss.BretonVowIntegrityActive", "The vow strains. Mercy and the shield come harder now.")
    SyncBretonCreedLossSpell(PDV_SPEL_CreedLoss_Breton_Excommunication, isBroken, "PDV.CreedLoss.BretonExcommunicationActive", "The vow breaks. The Knight's Road is halted until repair.")
EndFunction

Function SyncBretonWitchcraftExposureRuptureSpell(Bool isBreton)
    Bool isRuptured = isBreton && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
    SyncBretonCreedLossSpell(PDV_SPEL_CreedLoss_Breton_ExposureRupture, isRuptured, "PDV.CreedLoss.BretonExposureRuptureActive", "Your cover is blown. The hidden art turns against you.")
EndFunction

Function SyncBretonCreedLossSpell(Spell creedLossSpell, Bool shouldBeActive, String stateKey, String noticeText = "")
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !creedLossSpell
        StorageUtil.SetIntValue(None, stateKey, 0)
        return
    endIf

    if shouldBeActive
        Bool wasActive = StorageUtil.GetIntValue(None, stateKey) == 1
        if !playerRef.HasSpell(creedLossSpell)
            playerRef.AddSpell(creedLossSpell, False)
        endIf
        if !wasActive && noticeText != ""
            Debug.Notification(noticeText)
        endIf
        StorageUtil.SetIntValue(None, stateKey, 1)
    else
        if playerRef.HasSpell(creedLossSpell)
            playerRef.RemoveSpell(creedLossSpell)
        endIf
        StorageUtil.SetIntValue(None, stateKey, 0)
    endIf
EndFunction

Function SyncBretonDruidicForkBetrayalSpell(Bool shouldBeActive)
    SyncBretonCreedLossSpell(PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal, shouldBeActive, "PDV.CreedLoss.BretonDruidicForkBetrayalActive", "The Green has turned against the broken trust.")
EndFunction

Function SyncDunmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isDunmer = GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
    Bool broadReclamationFaithful = isDunmer && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T2, broadReclamationFaithful, "Dunmer Reclamation T2")

    SyncDunmerRewardFamily(playerRef, PDV_Azura, PDV_Bless_Dunmer_Azura_T1, PDV_Bless_Dunmer_Azura_T2, PDV_Bless_Dunmer_Azura_T3, "Azura")
    SyncDunmerRewardFamily(playerRef, PDV_Boethiah, PDV_Bless_Dunmer_Boethiah_T1, PDV_Bless_Dunmer_Boethiah_T2, PDV_Bless_Dunmer_Boethiah_T3, "Boethiah")
    SyncDunmerRewardFamily(playerRef, PDV_Mephala, PDV_Bless_Dunmer_Mephala_T1, PDV_Bless_Dunmer_Mephala_T2, PDV_Bless_Dunmer_Mephala_T3, "Mephala")
EndFunction

Function SyncDunmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_DUNMER && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Dunmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Dunmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Dunmer " + label + " T3")
EndFunction

Bool Function IsDunmerAncestorNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        return False
    endIf

    Int dunmerPosture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    return dunmerPosture == 1 || dunmerPosture == 2
EndFunction

Function SyncDunmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Dunmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Dunmer)
            playerRef.AddSpell(PDV_SPEL_Neglect_Dunmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Dunmer)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Dunmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
    endIf
EndFunction

Function SyncOrcRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isOrc = GetPlayerOriginRaceIndex() == ORIGIN_ORC
    Int activeMode = GetActiveOrcRewardMode()
    Bool broadFaithful = isOrc && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T2, broadFaithful, "Orc Malacath T2")

    Bool focusActive = isOrc && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == PDV_Malacath && PDV_Malacath
    Int activeTier = TIER_NONE
    if focusActive
        activeTier = GetTier(PDV_Malacath)
    endIf

    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_STRONGHOLD, activeMode, activeTier, focusActive, PDV_Bless_Orc_Stronghold_T1, PDV_Bless_Orc_Stronghold_T2, PDV_Bless_Orc_Stronghold_T3, "Stronghold")
    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_CITY, activeMode, activeTier, focusActive, PDV_Bless_Orc_City_T1, PDV_Bless_Orc_City_T2, PDV_Bless_Orc_City_T3, "City")
    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_LEGION_EXILE, activeMode, activeTier, focusActive, PDV_Bless_Orc_LegionExile_T1, PDV_Bless_Orc_LegionExile_T2, PDV_Bless_Orc_LegionExile_T3, "LegionExile")
EndFunction

Int Function GetActiveOrcRewardMode()
    if PDV_OrcLifeModeTrack
        Int modeValue = PDV_OrcLifeModeTrack.GetCurrentState()
        if modeValue >= ORC_LIFE_MODE_CITY && modeValue <= ORC_LIFE_MODE_LEGION_EXILE
            return modeValue
        endIf
    endIf

    return ORC_LIFE_MODE_CITY
EndFunction

Function SyncOrcRewardFamily(Actor playerRef, Int thisMode, Int activeMode, Int activeTier, Bool focusActive, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = focusActive && thisMode == activeMode
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Orc " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Orc " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Orc " + label + " T3")
EndFunction

Bool Function IsOrcCodeNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_ORC
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure") == 1
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncOrcNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Orc
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Orc)
            playerRef.AddSpell(PDV_SPEL_Neglect_Orc, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Orc)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Orc)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
    endIf
EndFunction

Function SyncRedguardRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isRedguard = GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
    Bool broadFaithful = isRedguard && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T2, broadFaithful, "Redguard AncestorSpine T2")

    SyncRedguardRewardFamily(playerRef, PDV_Tuwhacca, PDV_Bless_Redguard_Tuwhacca_T1, PDV_Bless_Redguard_Tuwhacca_T2, PDV_Bless_Redguard_Tuwhacca_T3, "Tuwhacca")
    SyncRedguardRewardFamily(playerRef, PDV_HoonDing, PDV_Bless_Redguard_HoonDing_T1, PDV_Bless_Redguard_HoonDing_T2, PDV_Bless_Redguard_HoonDing_T3, "HoonDing")
    SyncRedguardRewardFamily(playerRef, PDV_Leki, PDV_Bless_Redguard_Leki_T1, PDV_Bless_Redguard_Leki_T2, PDV_Bless_Redguard_Leki_T3, "Leki")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_FarShoresToken, isRedguard && StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken") > 0.0, "Redguard Far Shores Token")
    if isRedguard && PDV_RedguardSectTrack
        MaybeShowRedguardChampionEntry(PDV_RedguardSectTrack.GetCurrentState())
    endIf
EndFunction

Function SyncRedguardRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Redguard " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Redguard " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Redguard " + label + " T3")
EndFunction

Bool Function IsRedguardAncestorDistanceNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_REDGUARD
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure") > 0
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Redguard.LastSectSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncRedguardNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Redguard
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
            playerRef.AddSpell(PDV_SPEL_Neglect_Redguard, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Redguard)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
    endIf
EndFunction

Function SyncNordRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isNord = GetPlayerOriginRaceIndex() == ORIGIN_NORD
    Int baselineState = GetNordPantheonBaselineState()
    Bool broadOldWaysFaithful = isNord && GetPatronState() == PATRON_STATE_BROAD && baselineState == NORD_BASELINE_OLD_WAYS && StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T2, broadOldWaysFaithful, "Nord OldWays T2")

    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Kyne, PDV_Bless_Nord_Kyne_T1, PDV_Bless_Nord_Kyne_T2, PDV_Bless_Nord_Kyne_T3, "Kyne")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Shor, PDV_Bless_Nord_Shor_T1, PDV_Bless_Nord_Shor_T2, PDV_Bless_Nord_Shor_T3, "Shor")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Tsun, PDV_Bless_Nord_Tsun_T1, PDV_Bless_Nord_Tsun_T2, PDV_Bless_Nord_Tsun_T3, "Tsun")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Stuhn, PDV_Bless_Nord_Stuhn_T1, PDV_Bless_Nord_Stuhn_T2, PDV_Bless_Nord_Stuhn_T3, "Stuhn")
    SyncNordRewardFamily(playerRef, -1, PDV_Talos, PDV_Bless_Nord_Talos_T1, PDV_Bless_Nord_Talos_T2, PDV_Bless_Nord_Talos_T3, "Talos")

    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Akatosh, PDV_Bless_Nord_Akatosh_T1, PDV_Bless_Nord_Akatosh_T2, PDV_Bless_Nord_Akatosh_T3, "Akatosh")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Mara, PDV_Bless_Nord_Mara_T1, PDV_Bless_Nord_Mara_T2, PDV_Bless_Nord_Mara_T3, "Mara")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Arkay, PDV_Bless_Nord_Arkay_T1, PDV_Bless_Nord_Arkay_T2, PDV_Bless_Nord_Arkay_T3, "Arkay")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Stendarr, PDV_Bless_Nord_Stendarr_T1, PDV_Bless_Nord_Stendarr_T2, PDV_Bless_Nord_Stendarr_T3, "Stendarr")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Zenithar, PDV_Bless_Nord_Zenithar_T1, PDV_Bless_Nord_Zenithar_T2, PDV_Bless_Nord_Zenithar_T3, "Zenithar")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Dibella, PDV_Bless_Nord_Dibella_T1, PDV_Bless_Nord_Dibella_T2, PDV_Bless_Nord_Dibella_T3, "Dibella")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Julianos, PDV_Bless_Nord_Julianos_T1, PDV_Bless_Nord_Julianos_T2, PDV_Bless_Nord_Julianos_T3, "Julianos")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Kynareth, PDV_Bless_Nord_Kynareth_T1, PDV_Bless_Nord_Kynareth_T2, PDV_Bless_Nord_Kynareth_T3, "Kynareth")
EndFunction

Function SyncNordRewardFamily(Actor playerRef, Int requiredBaseline, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool baselineOk = requiredBaseline < 0 || GetNordPantheonBaselineState() == requiredBaseline
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_NORD && baselineOk && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Nord " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Nord " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Nord " + label + " T3")
EndFunction

; Grants the focused Khajiit emphasis's 3-tier reward set based on that emphasis deity's piety
; tier; clears every non-focused emphasis set (one active emphasis at a time).
Function SyncKhajiitEmphasisRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Int activeFocus = KHAJIIT_FOCUS_NONE
    Int activeTier = TIER_NONE
    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        activeFocus = GetKhajiitFocusedEmphasis()
        PDV_DeityBase deity = GetKhajiitEmphasisDeity(activeFocus)
        if deity
            activeTier = GetTier(deity)
        endIf
    endIf

    SyncKhajiitEmphasisFamily(playerRef, KHAJIIT_FOCUS_KHENARTHI, activeFocus, activeTier, PDV_Khenarthi, PDV_Bless_Khajiit_Khenarthi_T1, PDV_Bless_Khajiit_Khenarthi_T2, PDV_Bless_Khajiit_Khenarthi_T3, "Khenarthi")
    SyncKhajiitEmphasisFamily(playerRef, KHAJIIT_FOCUS_AZURAH, activeFocus, activeTier, PDV_Azura, PDV_Bless_Khajiit_Azurah_T1, PDV_Bless_Khajiit_Azurah_T2, PDV_Bless_Khajiit_Azurah_T3, "Azurah")
    SyncKhajiitEmphasisFamily(playerRef, KHAJIIT_FOCUS_BAANDAR, activeFocus, activeTier, PDV_BaanDar, PDV_Bless_Khajiit_BaanDar_T1, PDV_Bless_Khajiit_BaanDar_T2, PDV_Bless_Khajiit_BaanDar_T3, "Baan Dar")
    SyncKhajiitEmphasisFamily(playerRef, KHAJIIT_FOCUS_RAJHIN, activeFocus, activeTier, PDV_Rajhin, PDV_Bless_Khajiit_Rajhin_T1, PDV_Bless_Khajiit_Rajhin_T2, PDV_Bless_Khajiit_Rajhin_T3, "Rajhin")
    SyncKhajiitEmphasisFamily(playerRef, KHAJIIT_FOCUS_ALKOSH, activeFocus, activeTier, PDV_Alkosh, PDV_Bless_Khajiit_Alkosh_T1, PDV_Bless_Khajiit_Alkosh_T2, PDV_Bless_Khajiit_Alkosh_T3, "Alkosh")
EndFunction

Function SyncKhajiitEmphasisFamily(Actor playerRef, Int thisFocus, Int activeFocus, Int activeTier, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = (thisFocus == activeFocus)
    Bool hadChampionSpell = False
    if t3
        hadChampionSpell = playerRef.HasSpell(t3)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Khajiit " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Khajiit " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Khajiit " + label + " T3")

    if isActive && activeTier >= TIER_CHAMPION && t3 && !hadChampionSpell && playerRef.HasSpell(t3) && deity && NotifyTierUp(deity, TIER_CHAMPION)
        SendPrismaEventToast("tier", deity, "", GetPublicTierBand(TIER_CHAMPION), "")
        SurfaceTransition("tier", deity.DeityName, "reach", deity.DeityIndex, "")
        Trace(1, "Khajiit Champion reward presentation shown: " + deity.DeityName)
    endIf
EndFunction

; Gentle lunar neglect: the moons/road go quiet when no lunar source has fired within the grace
; window. Mechanical bite stays reserved for Corrupted/ShadowDrift posture elsewhere.
Bool Function IsKhajiitLunarNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_KHAJIIT
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > KHAJIIT_LUNAR_NEGLECT_GRACE_DAYS
EndFunction

Function SyncKhajiitNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_KhajiitLunar
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.AddSpell(PDV_SPEL_Neglect_KhajiitLunar, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_KhajiitLunar)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
    endIf
EndFunction

; --- Argonian (substrate / no-offer) reward spine. Mirrors the Khajiit no-offer pattern but
; gates on the PDV_Substrate_ArgonianHist relations rather than an emphasis deity's piety:
;   * Hist broad set (T1/T2/signature) gates on the Hist relation reaching its threshold.
;   * People is the single focused 3-tier set (T1/T2/T3 Champion), gated on People-focus state.
;   * Sithis is the high-threshold tertiary (T1/T2), gated on the Void being fully active.
; Only ONE foreground support emphasis runs at a time (People OR Void), like the Khajiit
; one-active-emphasis cap; People is the default and Void only competes once fully active.
Function SyncArgonianRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isArgonian = GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
    Float histRelation = 0.0
    Float peopleRelation = 0.0
    Float voidRelation = 0.0
    Bool voidActive = False
    Int activeFocus = ARGONIAN_FOCUS_NONE
    if isArgonian && PDV_ArgonianHistSubstrate
        histRelation = PDV_ArgonianHistSubstrate.GetHistRelation()
        peopleRelation = PDV_ArgonianHistSubstrate.GetPeopleRelation()
        voidRelation = PDV_ArgonianHistSubstrate.GetVoidRelation()
        voidActive = PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        activeFocus = GetArgonianActiveFocus(peopleRelation, voidRelation, voidActive)
    endIf

    ; Hist broad set, HIGHEST TIER ONLY (each tier spell carries the cumulative
    ; magnitude, so total power is unchanged but only one tier shows at a time).
    Bool wantHistSig = isArgonian && histRelation >= ARGONIAN_REWARD_SIGNATURE_THRESHOLD
    Bool wantHistT2 = isArgonian && !wantHistSig && histRelation >= ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantHistT1 = isArgonian && !wantHistSig && !wantHistT2 && histRelation >= ARGONIAN_REWARD_T1_THRESHOLD
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T1, wantHistT1, "Argonian Hist T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T2, wantHistT2, "Argonian Hist T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_Signature, wantHistSig, "Argonian Hist Signature")

    ; People focused set, highest tier only (active only when People is the focus).
    Bool peopleActive = isArgonian && activeFocus == ARGONIAN_FOCUS_PEOPLE
    Bool wantPeopleT3 = peopleActive && peopleRelation >= ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantPeopleT2 = peopleActive && !wantPeopleT3 && peopleRelation >= ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantPeopleT1 = peopleActive && !wantPeopleT3 && !wantPeopleT2 && peopleRelation >= ARGONIAN_REWARD_T1_THRESHOLD
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T1, wantPeopleT1, "Argonian People T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T2, wantPeopleT2, "Argonian People T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T3, wantPeopleT3, "Argonian People T3")

    ; Sithis tertiary, highest tier only (only when Void is fully active + the focus).
    Bool sithisActive = isArgonian && voidActive && activeFocus == ARGONIAN_FOCUS_VOID
    Bool wantSithisT3 = sithisActive && voidRelation >= ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantSithisT2 = sithisActive && !wantSithisT3 && voidRelation >= ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantSithisT1 = sithisActive && !wantSithisT3 && !wantSithisT2 && voidRelation >= ARGONIAN_REWARD_T1_THRESHOLD
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T1, wantSithisT1, "Argonian Sithis T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T2, wantSithisT2, "Argonian Sithis T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T3, wantSithisT3, "Argonian Sithis T3")

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

; Resolves the single active foreground support emphasis (People vs Void). People is the default;
; Void only competes once fully active and only when its relation leads People (one-active cap).
Int Function GetArgonianActiveFocus(Float peopleRelation, Float voidRelation, Bool voidActive)
    if voidActive && voidRelation > peopleRelation
        return ARGONIAN_FOCUS_VOID
    endIf

    return ARGONIAN_FOCUS_PEOPLE
EndFunction

; Gentle Hist-distance neglect: the Hist goes quiet when no accepted Hist source has fired within
; the grace window. Mechanical bite is reserved for posture Silenced/Corrupted (per the spec);
; this guard keeps the spell from biting outside those postures even past the grace window.
Bool Function IsArgonianHistNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_ArgonianHistSubstrate
        return False
    endIf

    Int posture = PDV_ArgonianHistSubstrate.GetHistPosture()
    if posture != PDV_ArgonianHistSubstrate.HIST_POSTURE_SILENCED && posture != PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Argonian.LastHistSourceTime")
    if lastSource <= 0.0
        return True
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > ARGONIAN_HIST_NEGLECT_GRACE_DAYS
EndFunction

Function SyncArgonianNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_ArgonianHist
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_ArgonianHist)
            playerRef.AddSpell(PDV_SPEL_Neglect_ArgonianHist, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_ArgonianHist)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_ArgonianHist)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
    endIf
EndFunction

Function SyncImperialRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isImperial = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
    Bool broadCivicFaithful = isImperial && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T2, broadCivicFaithful, "Imperial Civic T2")

    SyncImperialRewardFamily(playerRef, PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    SyncImperialRewardFamily(playerRef, PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, "Mara")
    SyncImperialRewardFamily(playerRef, PDV_Arkay, PDV_Bless_Imperial_Arkay_T1, PDV_Bless_Imperial_Arkay_T2, PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncImperialRewardFamily(playerRef, PDV_Stendarr, PDV_Bless_Imperial_Stendarr_T1, PDV_Bless_Imperial_Stendarr_T2, PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncImperialRewardFamily(playerRef, PDV_Zenithar, PDV_Bless_Imperial_Zenithar_T1, PDV_Bless_Imperial_Zenithar_T2, PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    SyncImperialRewardFamily(playerRef, PDV_Dibella, PDV_Bless_Imperial_Dibella_T1, PDV_Bless_Imperial_Dibella_T2, PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncImperialRewardFamily(playerRef, PDV_Julianos, PDV_Bless_Imperial_Julianos_T1, PDV_Bless_Imperial_Julianos_T2, PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncImperialRewardFamily(playerRef, PDV_Kynareth, PDV_Bless_Imperial_Kynareth_T1, PDV_Bless_Imperial_Kynareth_T2, PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
    SyncImperialRewardFamily(playerRef, PDV_Talos, PDV_Bless_Imperial_Talos_T1, PDV_Bless_Imperial_Talos_T2, PDV_Bless_Imperial_Talos_T3, "Talos")
EndFunction

Function SyncImperialRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Imperial " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Imperial " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= TIER_CHAMPION, "Imperial " + label + " T3")
EndFunction

Bool Function IsImperialCivicNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") <= 0
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Imperial.LastCivicServiceTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 3.0
EndFunction

Function SyncImperialNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !PDV_SPEL_Neglect_Imperial
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Imperial)
            playerRef.AddSpell(PDV_SPEL_Neglect_Imperial, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Imperial)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Imperial)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 0)
    endIf
EndFunction

Bool Function IsFirstTierRaceRewardEligible()
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity && GetTier(_activeDeity) >= TIER_SEEKER
        return True
    endIf

    return False
EndFunction

Spell Function GetFirstTierRaceRewardSpellForOrigin()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_ALTMER
        return PDV_Bless_Altmer_Orthodox_T1
    ; Argonian is a no-offer race: this selector exposes the fixed T1 spell for readback and
    ; shared reward contracts, while SyncArgonianRewards performs the actual substrate grant.
    elseIf originRace == ORIGIN_ARGONIAN
        return PDV_Bless_Argonian_Hist_T1
    elseIf originRace == ORIGIN_BOSMER
        return PDV_Bless_Bosmer_Yffre_T1
    elseIf originRace == ORIGIN_BRETON
        return PDV_Bless_Breton_Tradition_T1
    elseIf originRace == ORIGIN_DUNMER
        return PDV_Bless_Dunmer_Reclamation_T1
    elseIf originRace == ORIGIN_IMPERIAL
        return PDV_Bless_Imperial_Civic_T1
    elseIf originRace == ORIGIN_KHAJIIT
        return PDV_Bless_Khajiit_Lunar_T1
    elseIf originRace == ORIGIN_NORD
        return PDV_Bless_Nord_OldWays_T1
    elseIf originRace == ORIGIN_ORC
        return PDV_Bless_Orc_Malacath_T1
    elseIf originRace == ORIGIN_REDGUARD
        return PDV_Bless_Redguard_AncestorSpine_T1
    endIf

    return None
EndFunction

Function SyncRaceRewardSpell(Actor playerRef, Spell rewardSpell, Bool shouldBeActive, String rewardLabel)
    if !playerRef || !rewardSpell
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(rewardSpell)
            playerRef.AddSpell(rewardSpell, False)
            Trace(2, "Race reward added: " + rewardLabel)
        endIf
    else
        if playerRef.HasSpell(rewardSpell)
            playerRef.RemoveSpell(rewardSpell)
            Trace(2, "Race reward removed: " + rewardLabel)
        endIf
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

Function ApplyImperialConcordatAction(String actionKey, String reason)
    Int adjustment = GetImperialConcordatPressureForAction(actionKey)
    if adjustment == 0
        Trace(1, "ApplyImperialConcordatAction skipped: unknown action " + actionKey)
        return
    endIf

    ApplyConcordatPressure(adjustment, reason)
EndFunction

Int Function GetImperialConcordatPressureForAction(String actionKey)
    if actionKey == "hidden_talos_shrine"
        return -15
    elseIf actionKey == "help_talos_worshipper_escape"
        return -15
    elseIf actionKey == "kill_thalmor_justiciar_unprovoked"
        return -10
    elseIf actionKey == "side_with_stormcloaks"
        return -20
    elseIf actionKey == "refuse_report_talos_worshipper"
        return -5
    elseIf actionKey == "public_observe_talos_ban"
        return 5
    elseIf actionKey == "report_talos_worshipper"
        return 15
    elseIf actionKey == "attack_talos_worshipper"
        return 15
    endIf

    return 0
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
    RunDawnApplySpellAndNeglectLayers()
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

; --- State-axis debug setters: make focus/tradition/mode-gated Champion blessings
; testable via the standard force-piety + Run Dawn path. Each forces the state axis
; that the matching SyncXxxRewardFamily checks, so the blessing can qualify.

; Forces the Khajiit emergent focus to one moon-path by zeroing the five focus
; weights and seeding the target above the lead threshold, then re-evaluating.
Function DebugSetKhajiitFocus(Int focusValue)
    if focusValue < KHAJIIT_FOCUS_KHENARTHI || focusValue > KHAJIIT_FOCUS_ALKOSH
        return
    endIf

    Int f = KHAJIIT_FOCUS_KHENARTHI
    while f <= KHAJIIT_FOCUS_ALKOSH
        StorageUtil.SetFloatValue(None, GetKhajiitFocusWeightKey(f), 0.0)
        f += 1
    endWhile

    StorageUtil.SetFloatValue(None, GetKhajiitFocusWeightKey(focusValue), KHAJIIT_FOCUS_THRESHOLD + KHAJIIT_FOCUS_LEAD_REQUIRED + 10.0)
    EvaluateKhajiitFocusedEmphasis()
    Trace(1, "Khajiit focus debug-set to " + GetKhajiitFocusLabel(focusValue))
EndFunction

; Forces the Breton tradition (Knights Road / Hidden Art / Green Way).
Function DebugSetBretonTradition(Int traditionValue)
    Int normalized = ClampInt(traditionValue, BRETON_TRADITION_KNIGHTS_ROAD, BRETON_TRADITION_GREEN_WAY)
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    Trace(1, "Breton tradition debug-set to " + normalized)
EndFunction

; Forces the Orc life mode (City / Stronghold / Legion-Exile).
Function DebugSetOrcLifeMode(Int modeValue)
    Int normalized = ClampInt(modeValue, ORC_LIFE_MODE_CITY, ORC_LIFE_MODE_LEGION_EXILE)
    if PDV_OrcLifeModeTrack && PDV_OrcLifeModeTrack.GetCurrentState() != normalized
        PDV_OrcLifeModeTrack.SetState(normalized, "mcm_pattern")
    endIf
    Trace(1, "Orc life mode debug-set to " + normalized)
EndFunction

; Forces the Argonian focus (People / Void) by seeding relations; Void also seeds
; the Sithis activation signals. Reuses DebugSeedArgonian.
Function DebugSetArgonianFocus(Int focusValue)
    if focusValue == ARGONIAN_FOCUS_VOID
        DebugSeedArgonian(90.0, 0.0, 90.0)
    else
        DebugSeedArgonian(90.0, 90.0, 0.0)
    endIf
    Trace(1, "Argonian focus debug-set to " + focusValue)
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
    ShowFormalCommitmentOffer(candidate)
EndFunction

Function ShowFormalCommitmentOffer(PDV_DeityBase deity)
    Message offerMessage = GetFormalCommitmentOfferMessage(deity)
    if !offerMessage
        return
    endIf

    Int choice = offerMessage.Show()
    if choice == 0
        DebugAcceptPendingCommitment()
    elseIf choice == 1
        DebugDeclinePendingCommitment()
    elseIf choice == 2
        DebugRefusePendingCommitment()
    endIf
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Kyne
        return PDV_Msg_Nord_Kyne_Offer
    elseIf deity == PDV_Shor
        return PDV_Msg_Nord_Shor_Offer
    elseIf deity == PDV_Tsun
        return PDV_Msg_Nord_Tsun_Offer
    elseIf deity == PDV_Stuhn
        return PDV_Msg_Nord_Stuhn_Offer
    elseIf deity == PDV_Akatosh
        return PDV_Msg_Nord_Akatosh_Offer
    elseIf deity == PDV_Mara
        return PDV_Msg_Nord_Mara_Offer
    elseIf deity == PDV_Arkay
        return PDV_Msg_Nord_Arkay_Offer
    elseIf deity == PDV_Stendarr
        return PDV_Msg_Nord_Stendarr_Offer
    elseIf deity == PDV_Zenithar
        return PDV_Msg_Nord_Zenithar_Offer
    elseIf deity == PDV_Julianos
        return PDV_Msg_Nord_Julianos_Offer
    elseIf deity == PDV_Dibella
        return PDV_Msg_Nord_Dibella_Offer
    elseIf deity == PDV_Talos
        return PDV_Msg_Nord_Talos_Offer
    elseIf deity == PDV_Kynareth
        return PDV_Msg_Nord_Kynareth_Offer
    endIf

    return None
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

    return IsNordOfferEligibleDeity(deity)
EndFunction

; Nord's defining mechanic: deeds reveal which god noticed you. Any deity in the
; chosen pantheon baseline (plus Talos/Ysmir, always) is offer-eligible -- not only
; Kyne. Their T1/T2/T3 reward spells are authored; this opens the organic path to
; them. The eligibility/weight/cooldown/signal-day machinery is already generic.
Bool Function IsNordOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return False
    endIf

    if deity == PDV_Talos
        return True
    endIf

    Int baselineState = GetNordPantheonBaselineState()
    if baselineState == NORD_BASELINE_OLD_WAYS
        return deity == PDV_Kyne || deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Stuhn
    elseIf baselineState == NORD_BASELINE_NINE_DIVINES
        return deity == PDV_Akatosh || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Zenithar || deity == PDV_Dibella || deity == PDV_Julianos || deity == PDV_Kynareth
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
    else
        if GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
            RefreshArgonianHistPosture(reason)
        endIf
        if PDV_HircinePath
            PDV_HircinePath.UpdateResidueRecovery()
        endIf
    endIf
EndFunction

Function HandleCurseStateTransition(Int oldState, Int newState, String reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.State", newState)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", reason)
    ApplyCurseRaceHandlers(oldState, newState, reason)
    Trace(1, "Curse transition " + oldState + " -> " + newState + " (" + reason + ")")
    SendPrismaCurseToast(oldState, newState)
    SurfaceCurseTransitionDiegetic(oldState, newState)
    RequestPanelRefresh()
EndFunction

; Derive a typed "curse" Prisma event from an oldÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢new curse-state transition.
; Symbol names (curse-vampire, curse-werewolf) fall back to "journal" until
; the glyph design pass lands ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â no rendering breakage in the meantime.
Function SurfaceCurseTransitionDiegetic(Int oldState, Int newState)
    String direction = GetCurseSurfaceDirection(oldState, newState)
    String surfaceKey = GetCurseSurfaceKey(oldState, newState)
    if direction == "" || surfaceKey == ""
        return
    endIf

    String tone = "dread"
    if direction == "cure"
        tone = "release"
    endIf
    SurfaceTransition("curse", surfaceKey, direction, -1, tone)
EndFunction

String Function GetCurseSurfaceDirection(Int oldState, Int newState)
    if oldState == 0 && newState != 0
        return "onset"
    endIf
    if oldState != 0 && newState == 0
        return "cure"
    endIf
    if oldState != newState
        return "shift"
    endIf
    return ""
EndFunction

String Function GetCurseSurfaceKey(Int oldState, Int newState)
    Int curseRef = newState
    if newState == 0
        curseRef = oldState
    endIf
    if curseRef == 1
        return "werewolf"
    endIf
    if curseRef == 2
        return "vampire"
    endIf
    return ""
EndFunction

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

; Short race-specific context phrase ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â feeds the UI's listText fallback and any
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

; Emit a substrate instrument event without making Prisma the gameplay proof lane.
Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String stateLabel)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"substrate\""
    j = j + ",\"substrate\":\"" + JsonSafeString(substrate) + "\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if stateLabel != ""
        j = j + ",\"state\":\"" + JsonSafeString(stateLabel) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

Function SendPrismaSubstrateProgress(String substrate, Int tierBefore, Int tierAfter, Float multiplier, String context, String symbolName, String stateLabel)
    if tierAfter > tierBefore
        SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
    elseIf multiplier > 0.0
        SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
    endIf
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

Function QueueDaedricMilestonePresentation(PDV_DaedricPathBase path, Int oldTier, Int newTier, String reason)
    if !path || newTier <= TIER_NONE
        return
    endIf

    _pendingDaedricMilestonePath = path
    _pendingDaedricMilestoneOldTier = oldTier
    _pendingDaedricMilestoneNewTier = newTier
    _pendingDaedricMilestoneReason = reason
    _pendingDaedricMilestoneReplayChampionOffer = False
    _pendingDaedricMilestoneDelayTicks = 0
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone queued: " + path.DeityName + " " + GetTierStandingLabel(newTier) + " (" + reason + ")")
    endIf
EndFunction

Function QueueDaedricMilestoneMcmReplay(PDV_DaedricPathBase path, Int oldTier, Int newTier, String reason)
    if !path || newTier <= TIER_NONE
        return
    endIf

    _pendingDaedricMilestonePath = path
    _pendingDaedricMilestoneOldTier = oldTier
    _pendingDaedricMilestoneNewTier = newTier
    _pendingDaedricMilestoneReason = reason
    _pendingDaedricMilestoneReplayChampionOffer = True
    _pendingDaedricMilestoneDelayTicks = 2
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone MCM replay queued: " + path.DeityName + " " + GetTierStandingLabel(newTier) + " (" + reason + ")")
    endIf
EndFunction

Function ProcessQueuedDaedricMilestonePresentation()
    if !_pendingDaedricMilestonePath
        return
    endIf

    if _pendingDaedricMilestoneDelayTicks > 0
        _pendingDaedricMilestoneDelayTicks -= 1
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric milestone queue waiting: " + _pendingDaedricMilestonePath.DeityName + " ticks=" + _pendingDaedricMilestoneDelayTicks)
        endIf
        return
    endIf

    ; The Champion-offer replay shows a blocking authored Message that cannot display
    ; while a menu (the MCM) is open. Hold the pending presentation until menus close;
    ; OnUpdate re-checks each tick. Non-replay toasts are Prisma overlay and unaffected.
    if _pendingDaedricMilestoneReplayChampionOffer && Utility.IsInMenuMode()
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric Champion offer holding for menu close: " + _pendingDaedricMilestonePath.DeityName)
        endIf
        return
    endIf

    PDV_DaedricPathBase path = _pendingDaedricMilestonePath
    Int oldTier = _pendingDaedricMilestoneOldTier
    Int requestedTier = _pendingDaedricMilestoneNewTier
    String reason = _pendingDaedricMilestoneReason
    Bool replayChampionOffer = _pendingDaedricMilestoneReplayChampionOffer
    _pendingDaedricMilestonePath = None
    _pendingDaedricMilestoneOldTier = 0
    _pendingDaedricMilestoneNewTier = 0
    _pendingDaedricMilestoneReason = ""
    _pendingDaedricMilestoneReplayChampionOffer = False
    _pendingDaedricMilestoneDelayTicks = 0

    Int currentTier = path.GetStoredTier()
    if currentTier <= TIER_NONE
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric milestone queue skipped: " + path.DeityName + " has no active tier (" + reason + ")")
        endIf
        return
    endIf

    Int targetTier = requestedTier
    if targetTier > currentTier
        targetTier = currentTier
    endIf
    if targetTier <= oldTier
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric milestone queue skipped: " + path.DeityName + " target " + targetTier + " <= old " + oldTier + " (" + reason + ")")
        endIf
        return
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone queue processing: " + path.DeityName + " " + GetTierStandingLabel(targetTier) + " (" + reason + ")")
    endIf
    ShowDaedricMilestonePresentation(path, oldTier, targetTier, replayChampionOffer)
EndFunction

Function ShowDaedricMilestonePresentation(PDV_DaedricPathBase path, Int oldTier, Int newTier, Bool replayChampionOffer)
    if !path || newTier <= oldTier || newTier <= TIER_NONE
        return
    endIf

    if replayChampionOffer && newTier == TIER_CHAMPION
        path.ShowTierEntryMessage(oldTier, newTier)
        if path.GetStoredTier() < TIER_CHAMPION
            if GetDebugLevel() >= 1
                Debug.Trace("[PDV] Daedric milestone presentation skipped after Champion decline: " + path.DeityName)
            endIf
            return
        endIf
    endIf

    String princeName = path.DeityName
    String tierLabel = GetTierStandingLabel(newTier)
    String flavorText = GetDaedricMilestoneFlavor(princeName, newTier)
    String boonText = GetDaedricBoonMechanicText(princeName, newTier)
    String priceText = GetDaedricPriceMechanicText(princeName, newTier)
    String symbolName = GetPrismaSymbolForDeity(path)
    if symbolName == "journal"
        symbolName = "daedric"
    endIf

    Bool prismaSent = SendPrismaDaedricMilestoneToast(princeName, tierLabel, flavorText, boonText, priceText, symbolName)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone presentation: " + princeName + " " + tierLabel + " prisma=" + prismaSent)
    endIf
    Debug.Notification(princeName + " names you " + tierLabel + ".")
EndFunction

Bool Function SendPrismaDaedricMilestoneToast(String princeName, String tierLabel, String flavorText, String boonText, String priceText, String symbolName)
    if !PDV_PrismaBridge.IsAvailable()
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric milestone Prisma skipped: bridge unavailable.")
        endIf
        return False
    endIf

    String titleText = princeName + " names you " + tierLabel
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"phase\":\"milestone\""
    j = j + ",\"prince\":\"" + JsonSafeString(princeName) + "\""
    j = j + ",\"tierLabel\":\"" + JsonSafeString(tierLabel) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + JsonSafeString(titleText) + "\""
    j = j + ",\"message\":\"" + JsonSafeString(flavorText) + "\""
    j = j + ",\"duration\":9000"
    j = j + "}}"
    Bool sent = PDV_PrismaBridge.SendOverlayJson(j)
    QueuePrismaToastRetry(j, princeName + " " + tierLabel)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone Prisma payload sent=" + sent + " prince=" + princeName + " tier=" + tierLabel)
    endIf
    return sent
EndFunction

Function QueuePrismaToastRetry(String payload, String label)
    if payload == ""
        return
    endIf

    _pendingPrismaToastRetryPayload = payload
    _pendingPrismaToastRetryLabel = label
    _pendingPrismaToastRetryDelayTicks = 1
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Prisma toast retry queued: " + label)
    endIf
EndFunction

Function ProcessQueuedPrismaToastRetry()
    if _pendingPrismaToastRetryPayload == ""
        return
    endIf

    if _pendingPrismaToastRetryDelayTicks > 0
        _pendingPrismaToastRetryDelayTicks -= 1
        return
    endIf

    String payload = _pendingPrismaToastRetryPayload
    String label = _pendingPrismaToastRetryLabel
    _pendingPrismaToastRetryPayload = ""
    _pendingPrismaToastRetryLabel = ""
    _pendingPrismaToastRetryDelayTicks = 0

    if !PDV_PrismaBridge.IsAvailable()
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Prisma toast retry skipped: bridge unavailable for " + label)
        endIf
        return
    endIf

    Bool sent = PDV_PrismaBridge.SendOverlayJson(payload)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Prisma toast retry sent=" + sent + " label=" + label)
    endIf
EndFunction

; Contract-derived Daedric milestone copy. Source: PDV_DaedricPrinceRecordContracts.json.

String Function GetDaedricMilestoneFlavor(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == TIER_SEEKER
        return "Boethiah marks the seeker of trials."
    elseIf (princeName == "Boethiah") && tierValue == TIER_DEVOTED
        return "Boethiah's trial momentum is yours."
    elseIf (princeName == "Boethiah") && tierValue == TIER_CHAMPION
        return "Boethiah names you proven."
    elseIf (princeName == "Azura") && tierValue == TIER_SEEKER
        return "Azura opens the threshold a little."
    elseIf (princeName == "Azura") && tierValue == TIER_DEVOTED
        return "Azura's twilight is yours."
    elseIf (princeName == "Azura") && tierValue == TIER_CHAMPION
        return "Azura names you her seer."
    elseIf (princeName == "Vaermina") && tierValue == TIER_SEEKER
        return "Vaermina's touch opens the dream-path."
    elseIf (princeName == "Vaermina") && tierValue == TIER_DEVOTED
        return "Vaermina's nightmare deepens."
    elseIf (princeName == "Vaermina") && tierValue == TIER_CHAMPION
        return "Vaermina names you her nightmare-walker."
    elseIf (princeName == "Meridia") && tierValue == TIER_SEEKER
        return "Meridia's light stirs in you."
    elseIf (princeName == "Meridia") && tierValue == TIER_DEVOTED
        return "Meridia's radiance is yours in full."
    elseIf (princeName == "Meridia") && tierValue == TIER_CHAMPION
        return "Meridia names you her cleansing blade."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_SEEKER
        return "Molag Bal's domination-edge settles in you."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_DEVOTED
        return "The grip deepens."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_CHAMPION
        return "You carry the full weight of Molag Bal's domination."
    elseIf (princeName == "Mephala") && tierValue == TIER_SEEKER
        return "Mephala spins you a first thread."
    elseIf (princeName == "Mephala") && tierValue == TIER_DEVOTED
        return "Mephala's web is yours to read."
    elseIf (princeName == "Mephala") && tierValue == TIER_CHAMPION
        return "Mephala names you of the web."
    elseIf (princeName == "Malacath") && tierValue == TIER_SEEKER
        return "Malacath hardens the outcast."
    elseIf (princeName == "Malacath") && tierValue == TIER_DEVOTED
        return "Malacath's endurance is yours."
    elseIf (princeName == "Malacath") && tierValue == TIER_CHAMPION
        return "Malacath names you of the spurned-and-strong."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_SEEKER
        return "Dagon's edge settles in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_DEVOTED
        return "Dagon's ruin deepens in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_CHAMPION
        return "Dagon names you his ruin made walking."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_SEEKER
        return "Sheogorath's absurdity opens a crack."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_DEVOTED
        return "Sheogorath's disruption deepens."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_CHAMPION
        return "Sheogorath names you the Mad God's own."
    elseIf (princeName == "Namira") && tierValue == TIER_SEEKER
        return "Namira's darkness settles around you."
    elseIf (princeName == "Namira") && tierValue == TIER_DEVOTED
        return "Namira's outcast fellowship deepens."
    elseIf (princeName == "Namira") && tierValue == TIER_CHAMPION
        return "Namira names you of the outcast faithful."
    elseIf (princeName == "Sanguine") && tierValue == TIER_SEEKER
        return "Sanguine's ease settles in you."
    elseIf (princeName == "Sanguine") && tierValue == TIER_DEVOTED
        return "Sanguine's indulgence deepens."
    elseIf (princeName == "Sanguine") && tierValue == TIER_CHAMPION
        return "Sanguine names you his own."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_SEEKER
        return "Vile's transactional edge is yours."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_DEVOTED
        return "Vile's contract deepens."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_CHAMPION
        return "Vile names you his preferred client."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_SEEKER
        return "Mora's archive opens a corner."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_DEVOTED
        return "Mora's collection deepens in you."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_CHAMPION
        return "Mora names you archivist."
    elseIf (princeName == "Nocturnal") && tierValue == TIER_SEEKER
        return "Shadow luck covers you."
    elseIf (princeName == "Nocturnal") && tierValue == TIER_DEVOTED
        return "Nocturnal's shade deepens."
    elseIf (princeName == "Nocturnal") && tierValue == TIER_CHAMPION
        return "Nocturnal's debt runs in your favor."
    elseIf (princeName == "Peryite") && tierValue == TIER_SEEKER
        return "Peryite's resilience settles in you."
    elseIf (princeName == "Peryite") && tierValue == TIER_DEVOTED
        return "Peryite's imposed order deepens."
    elseIf (princeName == "Peryite") && tierValue == TIER_CHAMPION
        return "Peryite names you keeper of the lowest order."
    elseIf (princeName == "Hircine") && tierValue == TIER_SEEKER
        return "Hircine's hunt-sense is in you."
    elseIf (princeName == "Hircine") && tierValue == TIER_DEVOTED
        return "The hunt runs deeper now."
    elseIf (princeName == "Hircine") && tierValue == TIER_CHAMPION
        return "You see the whole arc of the hunt -- target, approach, kill, clean territory."
    endIf

    return "The pact has deepened."
EndFunction

String Function GetDaedricBoonMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == TIER_SEEKER
        return "+10 One-handed"
    elseIf (princeName == "Boethiah") && tierValue == TIER_DEVOTED
        return "+25 Armor rating"
    elseIf (princeName == "Boethiah") && tierValue == TIER_CHAMPION
        return "+35 Armor rating"
    elseIf (princeName == "Azura") && tierValue == TIER_SEEKER
        return "+15% Magic resistance"
    elseIf (princeName == "Azura") && tierValue == TIER_DEVOTED
        return "+25% Magicka regeneration"
    elseIf (princeName == "Azura") && tierValue == TIER_CHAMPION
        return "+35% Magicka regeneration"
    elseIf (princeName == "Vaermina") && tierValue == TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Vaermina") && tierValue == TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Vaermina") && tierValue == TIER_CHAMPION
        return "+25 Sneak"
    elseIf (princeName == "Meridia") && tierValue == TIER_SEEKER
        return "+10 Restoration"
    elseIf (princeName == "Meridia") && tierValue == TIER_DEVOTED
        return "+25% Disease resistance"
    elseIf (princeName == "Meridia") && tierValue == TIER_CHAMPION
        return "+35% Disease resistance"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_DEVOTED
        return "+18 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_CHAMPION
        return "+25 Illusion"
    elseIf (princeName == "Mephala") && tierValue == TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Mephala") && tierValue == TIER_DEVOTED
        return "+18 Pickpocket"
    elseIf (princeName == "Mephala") && tierValue == TIER_CHAMPION
        return "+25 Pickpocket"
    elseIf (princeName == "Malacath") && tierValue == TIER_SEEKER
        return "+15 Armor rating"
    elseIf (princeName == "Malacath") && tierValue == TIER_DEVOTED
        return "+18 Two-handed"
    elseIf (princeName == "Malacath") && tierValue == TIER_CHAMPION
        return "+25 Two-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_SEEKER
        return "+10 Destruction"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_DEVOTED
        return "+18 One-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_CHAMPION
        return "+25 One-handed"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_DEVOTED
        return "+25% Magicka regeneration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_CHAMPION
        return "+35% Magicka regeneration"
    elseIf (princeName == "Namira") && tierValue == TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Namira") && tierValue == TIER_DEVOTED
        return "+25% Health regeneration"
    elseIf (princeName == "Namira") && tierValue == TIER_CHAMPION
        return "+35% Health regeneration"
    elseIf (princeName == "Sanguine") && tierValue == TIER_SEEKER
        return "+15% Stamina regeneration"
    elseIf (princeName == "Sanguine") && tierValue == TIER_DEVOTED
        return "+18 Speech"
    elseIf (princeName == "Sanguine") && tierValue == TIER_CHAMPION
        return "+25 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_DEVOTED
        return "+25 Carry weight"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_CHAMPION
        return "+35 Carry weight"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_SEEKER
        return "+10 Alteration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_DEVOTED
        return "+25% Magicka regeneration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_CHAMPION
        return "+35% Magicka regeneration"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_DEVOTED
        return "+18 Lockpicking"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_CHAMPION
        return "+25 Lockpicking"
    elseIf (princeName == "Peryite") && tierValue == TIER_SEEKER
        return "+15% Disease resistance"
    elseIf (princeName == "Peryite") && tierValue == TIER_DEVOTED
        return "+25% Health regeneration"
    elseIf (princeName == "Peryite") && tierValue == TIER_CHAMPION
        return "+35% Health regeneration"
    elseIf (princeName == "Hircine") && tierValue == TIER_SEEKER
        return "+15% Stamina regeneration"
    elseIf (princeName == "Hircine") && tierValue == TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Hircine") && tierValue == TIER_CHAMPION
        return "+25 Sneak"
    endIf

    return "pact boon active"
EndFunction

String Function GetDaedricPriceMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Boethiah") && tierValue == TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Boethiah") && tierValue == TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Azura") && tierValue == TIER_SEEKER
        return "-10% Stamina regeneration"
    elseIf (princeName == "Azura") && tierValue == TIER_DEVOTED
        return "-20% Stamina regeneration"
    elseIf (princeName == "Azura") && tierValue == TIER_CHAMPION
        return "-30% Stamina regeneration"
    elseIf (princeName == "Vaermina") && tierValue == TIER_SEEKER
        return "-10% Health regeneration"
    elseIf (princeName == "Vaermina") && tierValue == TIER_DEVOTED
        return "-20% Health regeneration"
    elseIf (princeName == "Vaermina") && tierValue == TIER_CHAMPION
        return "-30% Health regeneration"
    elseIf (princeName == "Meridia") && tierValue == TIER_SEEKER
        return "-10 Illusion"
    elseIf (princeName == "Meridia") && tierValue == TIER_DEVOTED
        return "-18 Illusion"
    elseIf (princeName == "Meridia") && tierValue == TIER_CHAMPION
        return "-25 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_SEEKER
        return "-10% Health regeneration"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_DEVOTED
        return "-20% Health regeneration"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == TIER_CHAMPION
        return "-30% Health regeneration"
    elseIf (princeName == "Mephala") && tierValue == TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Mephala") && tierValue == TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Mephala") && tierValue == TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Malacath") && tierValue == TIER_SEEKER
        return "-10% movement speed"
    elseIf (princeName == "Malacath") && tierValue == TIER_DEVOTED
        return "-20% movement speed"
    elseIf (princeName == "Malacath") && tierValue == TIER_CHAMPION
        return "-30% movement speed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_SEEKER
        return "-10 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_DEVOTED
        return "-20 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == TIER_CHAMPION
        return "-30 Armor rating"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Namira") && tierValue == TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Namira") && tierValue == TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Namira") && tierValue == TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Sanguine") && tierValue == TIER_SEEKER
        return "-10% Magicka regeneration"
    elseIf (princeName == "Sanguine") && tierValue == TIER_DEVOTED
        return "-20% Magicka regeneration"
    elseIf (princeName == "Sanguine") && tierValue == TIER_CHAMPION
        return "-30% Magicka regeneration"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_SEEKER
        return "-10% Magicka regeneration"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_DEVOTED
        return "-20% Magicka regeneration"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == TIER_CHAMPION
        return "-30% Magicka regeneration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_SEEKER
        return "-10% Stamina regeneration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_DEVOTED
        return "-20% Stamina regeneration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == TIER_CHAMPION
        return "-30% Stamina regeneration"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Peryite") && tierValue == TIER_SEEKER
        return "-10% Stamina regeneration"
    elseIf (princeName == "Peryite") && tierValue == TIER_DEVOTED
        return "-20% Stamina regeneration"
    elseIf (princeName == "Peryite") && tierValue == TIER_CHAMPION
        return "-30% Stamina regeneration"
    elseIf (princeName == "Hircine") && tierValue == TIER_SEEKER
        return "-10% Health regeneration"
    elseIf (princeName == "Hircine") && tierValue == TIER_DEVOTED
        return "-20% Health regeneration"
    elseIf (princeName == "Hircine") && tierValue == TIER_CHAMPION
        return "-30% Health regeneration"
    endIf

    return "pact price active"
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
        ApplyBretonCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_DUNMER
        ApplyDunmerCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_ALTMER
        ApplyAltmerCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_ARGONIAN
        ApplyArgonianCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_IMPERIAL
        ApplyImperialCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_ORC
        ApplyOrcCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_REDGUARD
        ApplyRedguardCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_KHAJIIT
        ApplyKhajiitCurseHandlers(oldState, newState, reason)
    elseIf originRace == ORIGIN_NORD
        ApplyNordCurseHandlers(oldState, newState, reason)
        if PDV_HircinePath
            PDV_HircinePath.HandleCurseTransition(oldState, newState, reason)
            PDV_HircinePath.UpdateResidueRecovery()
        endIf
    endIf
EndFunction

Function ApplyBretonCurseHandlers(Int oldState, Int newState, String reason)
    Bool curseActive = newState != 0
    if curseActive
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 2)
    elseIf oldState != 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 0)
    endIf

    EnsureBretonDruidicForkInitialized()
    Int forkValue = GetBretonDruidicForkValue()
    if newState == 1 && GetBretonTraditionValue() == BRETON_TRADITION_GREEN_WAY && forkValue == BRETON_DRUIDIC_FORK_DRUIDIC
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_WEREWOLF, reason)
    elseIf oldState == 1 && newState == 0 && forkValue == BRETON_DRUIDIC_FORK_WEREWOLF
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, reason)
    endIf
EndFunction

; Dunmer 4-state curse posture (LOCKED): vampire silences the ancestor layer
; (Silent=2), werewolf strains it (Strained=1), a cure leaves it RestoredScarred
; (3); Normal=0. The ash-prayer silence under vampirism is the signature consequence.
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

; Per-layer scoring weight by curse posture. Layer 1 (ancestor substrate / ash-prayer)
; goes silent (0x) under vampirism and half under the beast; Layer 2 (Reclamation)
; keeps its vampire pressure path and is lightly strained (0.75x) under the beast.
; Posture: 0 Normal, 1 Strained, 2 Silent, 3 RestoredScarred.
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
        if StorageUtil.GetIntValue(None, "PDV.Argonian.VampireFeedbackShown") != 1
            ShowArgonianMessage(PDV_Msg_Argonian_CurseState_VampireOnset, "You are undead now. The Hist falls silent.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_STRAINED)
        if StorageUtil.GetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown") != 1
            ShowArgonianMessage(PDV_Msg_Argonian_CurseState_WerewolfOnset, "The beast is in you. The Hist relation strains, but does not sever.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_DISTANT)
        if oldState == 2
            ShowArgonianMessage(PDV_Msg_Argonian_CurseState_VampireCured, "The undeath is lifted. The Hist reaches again slowly.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 0)
        elseIf oldState == 1
            ShowArgonianMessage(PDV_Msg_Argonian_CurseState_WerewolfCured, "The beast is set down. The shape settles.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 0)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", ARGONIAN_HIST_POSTURE_NORMAL)
    endIf

    RefreshArgonianHistPosture(reason)
EndFunction

Function ShowArgonianMessage(Message messageRecord, String fallback, Bool suppressModal)
    if suppressModal || !messageRecord
        Debug.Notification(fallback)
        return
    endIf

    messageRecord.Show()
EndFunction

; Imperial vampire rupture: the Nine Divines path HALTS while undead (no civic piety
; accrues) and leaves a one-way history scar; cure lifts the halt but the scar remains.
Function ApplyImperialCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 1)
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHistory", 1)
        ClearActiveFavor("imperial_vampire")
    elseIf newState == 1
        ; Werewolf strains but does not halt the civic path the way undeath does.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    elseIf oldState == 2 && newState == 0
        ; Cured: the halt lifts, but VampireHistory stays set as the scar.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    endIf
EndFunction

; While an Imperial bears the vampire halt, the Nine Divines path stops growing:
; positive civic piety accrues at 0x. Losses still apply; the scar persists post-cure.
Float Function GetImperialCurseGainMultiplier(PDV_DeityBase deity)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return 1.0
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
        return 0.0
    endIf

    return 1.0
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
    Bool suppressModal = ShouldSuppressRedguardCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireFeedbackShown") != 1
            ShowRedguardMessage(PDV_Msg_Redguard_CurseState_VampireOnset, "The vampire curse interrupts Tu'whacca's cycle until cure and re-entry.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown") != 1
            ShowRedguardMessage(PDV_Msg_Redguard_CurseState_WerewolfOnset, "The beast blood strains the route to proper mortality.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown") != 1
            ShowRedguardMessage(PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry, "The thirst is gone. Tu'whacca's re-entry remains to restore the cycle.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 1)
        endIf
    elseIf oldState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown") != 1
            ShowRedguardMessage(PDV_Msg_Redguard_CurseState_WerewolfCured, "The beast blood is quiet. The mortal road steadies again.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 1)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
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

Bool Function ShouldSuppressRedguardCurseModal(String reason)
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

Function ShowRedguardNotification(Message messageRecord, String fallbackText)
    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.Notification(fallbackText)
EndFunction

Function ShowOrcNotification(Message messageRecord, String fallbackText)
    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.Notification(fallbackText)
EndFunction

Function ShowOrcMessage(Message messageRecord, String fallbackText, Bool suppressModal)
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

Function ShowRedguardMessage(Message messageRecord, String fallbackText, Bool suppressModal)
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

    if !ConfirmStartupSelection(originRace, choiceMessage, selection)
        Trace(2, "Startup choice not confirmed for origin " + originRace + " selection " + selection)
        return
    endIf

    ApplyStartupChoice(originRace, selection, "startup_choice")
    RecordStartupEvent("startup_confirmed")
    StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
EndFunction

Bool Function ConfirmStartupSelection(Int originRace, Message choiceMessage, Int expectedSelection)
    Message confirmMessage = GetStartupConfirmMessage(originRace, expectedSelection)
    if confirmMessage
        Int confirm = confirmMessage.Show()
        return confirm == 0
    endIf

    if PDV_MSG_StartupConfirmChoice
        Int genericConfirm = PDV_MSG_StartupConfirmChoice.Show()
        return genericConfirm == 0
    endIf

    Int retrySelection = choiceMessage.Show()
    return retrySelection == expectedSelection
EndFunction

Message Function GetStartupConfirmMessage(Int originRace, Int optionValue)
    if originRace == ORIGIN_BRETON
        if optionValue == 0
            return PDV_MSG_Confirm_Breton_KnightsRoad
        elseIf optionValue == 1
            return PDV_MSG_Confirm_Breton_HiddenArt
        endIf
        return PDV_MSG_Confirm_Breton_GreenWay
    elseIf originRace == ORIGIN_REDGUARD
        if optionValue == REDGUARD_SECT_CROWN
            return PDV_MSG_Confirm_Redguard_Crown
        elseIf optionValue == REDGUARD_SECT_ASHABAH
            return PDV_MSG_Confirm_Redguard_Ashabah
        endIf
        return PDV_MSG_Confirm_Redguard_Forebear
    elseIf originRace == ORIGIN_ORC
        if optionValue == ORC_LIFE_MODE_STRONGHOLD
            return PDV_MSG_Confirm_Orc_Stronghold
        elseIf optionValue == ORC_LIFE_MODE_LEGION_EXILE
            return PDV_MSG_Confirm_Orc_LegionExile
        endIf
        return PDV_MSG_Confirm_Orc_City
    elseIf originRace == ORIGIN_BOSMER
        if optionValue == BOSMER_PATH_OLD_CONTRACT
            return PDV_MSG_Confirm_Bosmer_OldContract
        elseIf optionValue == BOSMER_PATH_EXCHANGE
            return PDV_MSG_Confirm_Bosmer_Exchange
        elseIf optionValue == BOSMER_PATH_BANDIT_ROAD
            return PDV_MSG_Confirm_Bosmer_BanditRoad
        endIf
        return PDV_MSG_Confirm_Bosmer_LivingStory
    endIf

    return None
EndFunction

Function EnsureInfoOnlyStartup(Int originRace)
    RecordStartupEvent("startup_shown")
    Debug.MessageBox(GetStartupInfoOnlyText(originRace))
    RecordStartupEvent("startup_info_acknowledged")
    StorageUtil.SetIntValue(None, "PDV.Startup.UnifiedChoiceComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Startup.OriginHandled", originRace)
EndFunction

Function ShowStartupMigrationInfo(Int originRace)
    Debug.MessageBox("Devotion keeps your existing startup state on this save.\n\n" + GetStartupCanonicalSummary(originRace) + "\n\n" + STARTUP_ADVISORY_TEXT)
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
    if normalized == BRETON_TRADITION_GREEN_WAY
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, reason)
    else
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_NONE, reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    if PDV_RedguardSectTrack
        Int normalized = ClampInt(sectValue, REDGUARD_SECT_CROWN, REDGUARD_SECT_ASHABAH)
        PDV_RedguardSectTrack.SetState(normalized, reason)
        ShowRedguardSectEntry(normalized)
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

    ; Tradition onboarding is explicit and start-locked: the first choice latches
    ; it, and there is no silent mid-game switching in 1.0. A later off-tradition
    ; source becomes cross-tradition pressure, never a silent tradition rewrite.
    if StorageUtil.GetIntValue(None, "PDV.Breton.SetupComplete") == 1
        if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) != traditionValue
            StorageUtil.SetIntValue(None, "PDV.Breton.CrossTraditionPressure", StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") + 1)
            StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
            Trace(2, "Breton tradition locked; off-tradition source -> cross-tradition pressure: " + reason)
        endIf
        return
    endIf

    ApplyBretonInitialChoice(traditionValue, reason)
    StorageUtil.SetIntValue(None, "PDV.Breton.TraditionHookCount", StorageUtil.GetIntValue(None, "PDV.Breton.TraditionHookCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    Trace(2, "Breton tradition choice routed: " + reason)
EndFunction

; WitchcraftExposure is not a one-way ratchet: occult signals add +25, but exposure
; also fades by 1 each dawn, so clean living slowly lowers cover. (The faster public
; Divine-cover path and the rupture creed-loss spell are record-backed refinements.)
Function DecayBretonWitchcraftExposureAtDawn()
    Int exposure = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
    if exposure <= 0
        return
    endIf
    exposure -= 1
    StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", exposure)
    Trace(2, "Breton WitchcraftExposure passive decay -> " + exposure)
EndFunction

Function HandleBretonKnightlyVow(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Knightly Vow ignored for non-Breton origin.")
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == 0
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowCount", StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount") + 1)
        StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
        if PDV_Stendarr
            AwardCuratedSignal(PDV_Stendarr, PDV_Stendarr.SIGNAL_MERCY, None)
        endIf
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
    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == BRETON_TRADITION_HIDDEN_ART && PDV_Julianos
        AwardCuratedSignal(PDV_Julianos, PDV_Julianos.SIGNAL_LAWFUL_ORDER, None)
    endIf
    ShowP2BookNotice(reason, GetBretonHiddenArtNoticeTitle(reason), GetBretonHiddenArtNoticeText(reason))
    Trace(2, "Breton Hidden Art exposure routed: " + reason)
EndFunction

String Function GetBretonHiddenArtNoticeTitle(String reason)
    if StringContainsToken(reason, "hagravens")
        return "Hagraven lore"
    elseIf StringContainsToken(reason, "madmen_reach")
        return "Reach-mad whispers"
    elseIf StringContainsToken(reason, "witch_note")
        return "A witch's note"
    endIf

    return "The Hidden Art"
EndFunction

String Function GetBretonHiddenArtNoticeText(String reason)
    if StringContainsToken(reason, "hagravens")
        return "Old bargains leave a mark on your cover."
    elseIf StringContainsToken(reason, "madmen_reach")
        return "Forbidden Reach lore stirs your hidden practice."
    elseIf StringContainsToken(reason, "witch_note")
        return "A private craft presses closer to the surface."
    endIf

    return "Forbidden pages leave their mark on you."
EndFunction

Function HandleBretonGreenWayStanding(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Green Way ignored for non-Breton origin.")
        return
    endIf

    EnsureBretonDruidicForkInitialized()
    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding")
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", ClampInt(standingValue + 25, 0, 100))
    StorageUtil.SetIntValue(None, "PDV.Breton.GreenWayCount", StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if IsBretonGreenWayForkEligible() && PDV_Kynareth
        AwardCuratedSignal(PDV_Kynareth, PDV_Kynareth.SIGNAL_OPEN_SKY, None)
    endIf
    Trace(2, "Breton Green Way standing routed: " + reason)
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        Trace(2, "Dunmer Reclamation focus ignored for non-Dunmer origin.")
        return
    endIf

    Float layerWeight = GetDunmerCurseLayerWeight(2)
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocus", ClampInt(focusValue, 0, 2))
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocusCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastReclamationReason", reason)
    AwardDunmerReclamationFocusSignal(focusValue, layerWeight)
    if focusValue == 0
        ShowP2BookNotice(reason, "Azura's twilight", "The Reclamation turns toward her.")
    elseIf focusValue == 1
        ShowP2BookNotice(reason, "Boethiah's proving", "The Reclamation turns toward struggle.")
    else
        ShowP2BookNotice(reason, "Mephala's web", "The Reclamation turns toward secrets.")
    endIf
    Trace(2, "Dunmer Reclamation focus routed: " + reason + " weight " + layerWeight)
EndFunction

Function HandleDunmerDeviationPrice(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        Trace(2, "Dunmer deviation price ignored for non-Dunmer origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.DeviationPriceCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastDeviationReason", reason)
    AwardDunmerDeviationPriceSignal()
    Trace(2, "Dunmer deviation price routed: " + reason)
EndFunction

Bool Function TryAwardDunmerTwilightWindowSignal(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_Azura
        return False
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Int windowValue = GetDunmerTwilightWindow(nowTime)
    if windowValue <= 0
        return False
    endIf

    Int dayIndex = nowTime as Int
    String windowLabel = GetDunmerTwilightWindowLabel(windowValue)
    String dayKey = "PDV.Signal.DunmerTwilight." + windowLabel + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, -1) == dayIndex
        Trace(2, "Dunmer " + windowLabel + " twilight rite already recorded today (" + reason + ")")
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, dayIndex)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.TwilightWindowCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightWindow", windowLabel)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastTwilightTime", nowTime)
    AwardCuratedSignal(PDV_Azura, PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE, None)
    Trace(2, "Dunmer " + windowLabel + " twilight rite routed: " + reason)
    return True
EndFunction

; Outdoor Good Daedra shrine prayer (Solstheim DLC2 Azura/Boethiah/Mephala altars).
; The twilight-window award is the spec'd role for the outdoor shrine; TryAward already
; enforces Dunmer origin, the dawn/dusk window, and the once-per-window-per-day cap.
Function HandleDunmerOutdoorGoodDaedraShrine(String reason)
    TryAwardDunmerTwilightWindowSignal(reason)
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
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || GetPatronState() != PATRON_STATE_ACTIVE
        return
    endIf

    ; Anti-farm: the ancestor-memory piety pulse (portable-shrine prayer and the
    ; home rite share it) banks at most once per dawn cycle, keyed on the same
    ; day-int boundary as the rest of the daily gates. The substrate side keeps its
    ; own 0.7^n decay separately; this stops the pulse from stacking linearly.
    Int pdvAncestorMemoryDay = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day") == pdvAncestorMemoryDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day", pdvAncestorMemoryDay)

    Float layerWeight = GetDunmerCurseLayerWeight(2)
    if _activeDeity == PDV_Boethiah && PDV_Boethiah
        AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf _activeDeity == PDV_Mephala && PDV_Mephala
        AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf _activeDeity == PDV_Azura && PDV_Azura
        AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerReclamationFocusSignal(Int focusValue, Float layerWeight)
    if focusValue == 0 && PDV_Azura
        AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_THRESHOLD_RITE, None, layerWeight)
    elseIf focusValue == 1 && PDV_Boethiah
        AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE, None, layerWeight)
    elseIf focusValue == 2 && PDV_Mephala
        AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SECRET_KEPT, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerDeviationPriceSignal()
    if _activeDeity == PDV_Boethiah && PDV_Boethiah
        AwardCuratedSignal(PDV_Boethiah, PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED, None)
    elseIf _activeDeity == PDV_Mephala && PDV_Mephala
        AwardCuratedSignal(PDV_Mephala, PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED, None)
    elseIf _activeDeity == PDV_Azura && PDV_Azura
        AwardCuratedSignal(PDV_Azura, PDV_Azura.SIGNAL_DESECRATION, None)
    endIf
EndFunction

Bool Function StringContainsToken(String haystackText, String needleText)
    Int haystackLength = StringUtil.GetLength(haystackText)
    Int needleLength = StringUtil.GetLength(needleText)
    if needleLength <= 0 || haystackLength < needleLength
        return False
    endIf

    Int startIndex = 0
    Int lastStart = haystackLength - needleLength
    while startIndex <= lastStart
        Int needleIndex = 0
        Bool matched = True
        while needleIndex < needleLength && matched
            if StringUtil.GetNthChar(haystackText, startIndex + needleIndex) != StringUtil.GetNthChar(needleText, needleIndex)
                matched = False
            endIf
            needleIndex = needleIndex + 1
        endWhile

        if matched
            return True
        endIf
        startIndex = startIndex + 1
    endWhile

    return False
EndFunction

Int Function GetImperialCivicFamilyFromSource(String sourceId)
    if StringContainsToken(sourceId, "public_service") || StringContainsToken(sourceId, "public-service") || StringContainsToken(sourceId, "civic_public")
        return IMPERIAL_CIVIC_PUBLIC_SERVICE
    elseIf StringContainsToken(sourceId, "mercy")
        return IMPERIAL_CIVIC_MERCY
    elseIf StringContainsToken(sourceId, "lawful_order") || StringContainsToken(sourceId, "lawful-order") || StringContainsToken(sourceId, "law")
        return IMPERIAL_CIVIC_LAWFUL_ORDER
    elseIf StringContainsToken(sourceId, "honest_work") || StringContainsToken(sourceId, "honest-work") || StringContainsToken(sourceId, "work")
        return IMPERIAL_CIVIC_HONEST_WORK
    elseIf StringContainsToken(sourceId, "death_duty") || StringContainsToken(sourceId, "death-duty") || StringContainsToken(sourceId, "arkay")
        return IMPERIAL_CIVIC_DEATH_DUTY
    endIf

    return IMPERIAL_CIVIC_UNKNOWN
EndFunction

String Function GetImperialCivicFamilyLabel(Int familyId)
    if familyId == IMPERIAL_CIVIC_PUBLIC_SERVICE
        return "public_service"
    elseIf familyId == IMPERIAL_CIVIC_MERCY
        return "mercy"
    elseIf familyId == IMPERIAL_CIVIC_LAWFUL_ORDER
        return "lawful_order"
    elseIf familyId == IMPERIAL_CIVIC_HONEST_WORK
        return "honest_work"
    elseIf familyId == IMPERIAL_CIVIC_DEATH_DUTY
        return "death_duty"
    endIf

    return "unknown"
EndFunction

Function AwardImperialCivicFamilySignal(Int familyId)
    if familyId == IMPERIAL_CIVIC_PUBLIC_SERVICE
        if PDV_Akatosh
            AwardCuratedSignal(PDV_Akatosh, PDV_Akatosh.SIGNAL_CIVIC_SERVICE, None)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_MERCY
        if PDV_Mara
            AwardCuratedSignal(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_LAWFUL_ORDER
        if PDV_Stendarr
            AwardCuratedSignal(PDV_Stendarr, PDV_Stendarr.SIGNAL_LAWFUL_ORDER, None)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_HONEST_WORK
        if PDV_Zenithar
            AwardCuratedSignal(PDV_Zenithar, PDV_Zenithar.SIGNAL_HONEST_WORK, None)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_DEATH_DUTY
        if PDV_Arkay
            AwardCuratedSignal(PDV_Arkay, PDV_Arkay.SIGNAL_DEATH_DUTY, None)
        endIf
    endIf
EndFunction

Function AwardImperialPatronCivicSignal()
    if !_activeDeity
        return
    endIf

    if _activeDeity == PDV_Akatosh && PDV_Akatosh
        AwardCuratedSignal(PDV_Akatosh, PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Mara && PDV_Mara
        AwardCuratedSignal(PDV_Mara, PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Arkay && PDV_Arkay
        AwardCuratedSignal(PDV_Arkay, PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Stendarr && PDV_Stendarr
        AwardCuratedSignal(PDV_Stendarr, PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Zenithar && PDV_Zenithar
        AwardCuratedSignal(PDV_Zenithar, PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Dibella && PDV_Dibella
        AwardCuratedSignal(PDV_Dibella, PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Julianos && PDV_Julianos
        AwardCuratedSignal(PDV_Julianos, PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None)
    elseIf _activeDeity == PDV_Kynareth && PDV_Kynareth
        AwardCuratedSignal(PDV_Kynareth, PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR, None)
    endIf
EndFunction

Function HandleImperialCivicService(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial civic service ignored for non-Imperial origin.")
        return
    endIf

    Int civicFamily = GetImperialCivicFamilyFromSource(reason)
    if civicFamily == IMPERIAL_CIVIC_UNKNOWN
        Trace(1, "Imperial civic service ignored: missing civic family token in " + reason)
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.CivicServiceCount", StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicServiceReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicFamily", GetImperialCivicFamilyLabel(civicFamily))
    StorageUtil.SetFloatValue(None, "PDV.Imperial.LastCivicServiceTime", Utility.GetCurrentGameTime())
    AwardImperialCivicFamilySignal(civicFamily)
    Trace(2, "Imperial civic service routed: " + reason + " family " + GetImperialCivicFamilyLabel(civicFamily))
EndFunction

Function HandleImperialTalosPressure(Bool isPrivate, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial Talos pressure ignored for non-Imperial origin.")
        return
    endIf

    if isPrivate
        StorageUtil.SetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") + 1)
        if PDV_Talos
            AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.PublicTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") + 1)
        if PDV_Talos
            AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_DEFIANCE_MILESTONE, None)
        endIf
    endIf

    StorageUtil.SetStringValue(None, "PDV.Imperial.LastTalosPressureReason", reason)
    ShowP2BookNotice(reason, "The name of Talos", "The question of the Ninth presses harder.")
    Trace(2, "Imperial Talos pressure routed: " + reason)
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial patron civic favor ignored for non-Imperial origin.")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.PatronCivicFavorCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastPatronCivicFavorReason", reason)
    AwardImperialPatronCivicSignal()
    Trace(2, "Imperial patron civic favor routed: " + reason)
EndFunction

Int Function GetNordRouteFamilyFromSource(String sourceId)
    if sourceId == ""
        return NORD_ROUTE_UNKNOWN
    endIf

    if StringContainsToken(sourceId, "sky_road") || StringContainsToken(sourceId, "sky-road") || StringContainsToken(sourceId, "storm_road") || StringContainsToken(sourceId, "road_grace")
        if StringContainsToken(sourceId, "nine")
            return NORD_ROUTE_NINE_ROAD
        endIf
        return NORD_ROUTE_OLD_SKY_ROAD
    elseIf StringContainsToken(sourceId, "ordeal") || StringContainsToken(sourceId, "trial") || StringContainsToken(sourceId, "adversity")
        return NORD_ROUTE_OLD_ORDEAL
    elseIf StringContainsToken(sourceId, "hearth") || StringContainsToken(sourceId, "hold") || StringContainsToken(sourceId, "protect_bond")
        return NORD_ROUTE_OLD_HEARTH
    elseIf StringContainsToken(sourceId, "ancestor") || StringContainsToken(sourceId, "honored_dead")
        return NORD_ROUTE_OLD_ANCESTOR
    elseIf StringContainsToken(sourceId, "hircine") || StringContainsToken(sourceId, "hunt")
        return NORD_ROUTE_OLD_ORDEAL
    elseIf StringContainsToken(sourceId, "household") || StringContainsToken(sourceId, "mercy")
        return NORD_ROUTE_NINE_MERCY
    elseIf StringContainsToken(sourceId, "proper_death") || StringContainsToken(sourceId, "proper-death") || StringContainsToken(sourceId, "anti_necromancy") || StringContainsToken(sourceId, "arkay")
        return NORD_ROUTE_NINE_DEATH
    elseIf StringContainsToken(sourceId, "honest_work") || StringContainsToken(sourceId, "honest-work") || StringContainsToken(sourceId, "learned_craft") || StringContainsToken(sourceId, "zenithar")
        return NORD_ROUTE_NINE_WORK
    elseIf StringContainsToken(sourceId, "talos_pressure") || StringContainsToken(sourceId, "talos-pressure")
        return NORD_ROUTE_NINE_TALOS
    elseIf StringContainsToken(sourceId, "talos") || StringContainsToken(sourceId, "defiance")
        return NORD_ROUTE_OLD_TALOS
    endIf

    return NORD_ROUTE_UNKNOWN
EndFunction

Int Function GetNordFavorLaneForRouteFamily(Int familyValue)
    if familyValue >= NORD_ROUTE_NINE_ROAD
        return FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    if familyValue > NORD_ROUTE_UNKNOWN
        return FAVOR_LANE_NORD_BROAD_OLD_WAYS
    endIf

    return FAVOR_LANE_NONE
EndFunction

Int Function GetNordFavorFamilyForRouteFamily(Int familyValue)
    if familyValue == NORD_ROUTE_OLD_SKY_ROAD
        return FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    elseIf familyValue == NORD_ROUTE_OLD_ORDEAL
        return FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
    elseIf familyValue == NORD_ROUTE_OLD_HEARTH
        return FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
    elseIf familyValue == NORD_ROUTE_OLD_ANCESTOR
        return FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
    elseIf familyValue == NORD_ROUTE_OLD_TALOS
        return FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf familyValue == NORD_ROUTE_NINE_ROAD
        return FAVOR_FAMILY_NINE_ROAD_GRACE
    elseIf familyValue == NORD_ROUTE_NINE_MERCY
        return FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
    elseIf familyValue == NORD_ROUTE_NINE_DEATH
        return FAVOR_FAMILY_NINE_PROPER_DEATH
    elseIf familyValue == NORD_ROUTE_NINE_WORK
        return FAVOR_FAMILY_NINE_HONEST_WORK
    elseIf familyValue == NORD_ROUTE_NINE_TALOS
        return FAVOR_FAMILY_NINE_TALOS_PRESSURE
    endIf

    return 0
EndFunction

Function AwardNordRouteFamilySignal(Int familyValue)
    if familyValue == NORD_ROUTE_OLD_ORDEAL
        if PDV_Tsun
            AwardCuratedSignal(PDV_Tsun, PDV_Tsun.SIGNAL_TRIAL_ENDURED, None)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_HEARTH
        if PDV_Stuhn
            AwardCuratedSignal(PDV_Stuhn, PDV_Stuhn.SIGNAL_PROTECT_BOND, None)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_ANCESTOR
        if PDV_Shor
            AwardCuratedSignal(PDV_Shor, PDV_Shor.SIGNAL_HONORED_DEAD, None)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_TALOS || familyValue == NORD_ROUTE_NINE_TALOS
        if PDV_Talos
            AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_ROAD
        if PDV_Kynareth
            AwardCuratedSignal(PDV_Kynareth, PDV_Kynareth.SIGNAL_OPEN_SKY, None)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_MERCY
        if PDV_Mara
            AwardCuratedSignal(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_DEATH
        if PDV_Arkay
            AwardCuratedSignal(PDV_Arkay, PDV_Arkay.SIGNAL_DEATH_DUTY, None)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_WORK
        if PDV_Zenithar
            AwardCuratedSignal(PDV_Zenithar, PDV_Zenithar.SIGNAL_HONEST_WORK, None)
        endIf
    endIf
EndFunction

Bool Function RouteNordFamily(String reason, String countKey, String lastReasonKey, String lastTimeKey, String traceLabel)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, traceLabel + " ignored for non-Nord origin.")
        return False
    endIf

    Int routeFamily = GetNordRouteFamilyFromSource(reason)
    if routeFamily == NORD_ROUTE_UNKNOWN
        Trace(2, traceLabel + " ignored: unknown source family token in " + reason)
        return False
    endIf

    Int laneValue = GetNordFavorLaneForRouteFamily(routeFamily)
    Int favorFamily = GetNordFavorFamilyForRouteFamily(routeFamily)
    if laneValue != FAVOR_LANE_NONE && favorFamily > 0
        TryActivateContextualFavor(laneValue, favorFamily, reason)
    endIf

    StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    StorageUtil.SetStringValue(None, lastReasonKey, reason)
    StorageUtil.SetFloatValue(None, lastTimeKey, Utility.GetCurrentGameTime())
    AwardNordRouteFamilySignal(routeFamily)
    Trace(2, traceLabel + " routed: " + reason)
    return True
EndFunction

Function HandleNordOldWaysState(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Old Ways state ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.OldWaysContextCount", "PDV.Nord.LastOldWaysReason", "PDV.Nord.LastOldWaysSignalTime", "Nord Old Ways state")
        ShowP2BookNotice(reason, "The Old Ways", "The elder gods of the Nords stand nearer.")
    endIf
EndFunction

Function HandleNordKyneTalosContext(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Kyne/Talos context ignored for non-Nord origin.")
        return
    endIf

    RouteNordFamily(reason, "PDV.Nord.KyneTalosContextCount", "PDV.Nord.LastKyneTalosReason", "PDV.Nord.LastKyneTalosSignalTime", "Nord Kyne/Talos context")
EndFunction

Function HandleNordHircineArkayEdge(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord Hircine/Arkay edge ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.HircineArkayEdgeCount", "PDV.Nord.LastHircineArkayReason", "PDV.Nord.LastHircineArkaySignalTime", "Nord Hircine/Arkay edge")
        ShowP2BookNotice(reason, "Hunt and grave", "Beast and rest blur at the edges.")
    endIf
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
    if !AllowPrismaBlockingSurfaces
        return
    endIf

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

Function SendPrismaMedallionPayload(Int originRace)
    if !AllowPrismaBlockingSurfaces
        return
    endIf

    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    String sectionsJson = GetMedallionSectionsJson(originRace)
    String raceLabel = GetOriginRaceLabel(originRace)
    String payload = "{\"mode\":\"medallion\",\"medallion\":{\"race_id\":\"" + JsonSafeString(GetStartupRaceId(originRace)) + "\""
    payload = payload + ",\"title\":\"" + JsonSafeString(raceLabel + " Medallion") + "\""
    payload = payload + ",\"summary\":\"" + JsonSafeString("The medallion shows the native roster. Only live, scorable entries can be chosen.") + "\""
    payload = payload + ",\"active_option_id\":\"" + JsonSafeString(GetActiveMedallionOptionId()) + "\""
    payload = payload + ",\"advisory_line\":\"" + JsonSafeString("A selectable entry is already wired into the live devotion roster.") + "\""
    payload = payload + ",\"sections\":[" + sectionsJson + "]}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

; ---------------------------------------------------------------------------
; Book of Days journal payload
; ---------------------------------------------------------------------------

; Map an in-game day integer to a Tamriel fiction date string.
; Tamriel has 12 months of 30 days each.
String Function JournalDayToFictionDate(Int gameDay)
    String[] months = new String[12]
    months[0] = "Morning Star"
    months[1] = "Sun's Dawn"
    months[2] = "First Seed"
    months[3] = "Rain's Hand"
    months[4] = "Second Seed"
    months[5] = "Midyear"
    months[6] = "Sun's Height"
    months[7] = "Last Seed"
    months[8] = "Hearthfire"
    months[9] = "Frostfall"
    months[10] = "Sun's Dusk"
    months[11] = "Evening Star"
    Int dayOfYear = gameDay - ((gameDay / 360) * 360)
    if dayOfYear < 0
        dayOfYear = 0
    endIf
    Int monthIndex = dayOfYear / 30
    if monthIndex >= 12
        monthIndex = 11
    endIf
    Int dayOfMonth = dayOfYear - (monthIndex * 30) + 1
    return months[monthIndex] + " " + dayOfMonth
EndFunction

; Build the Book of Days journal JSON payload.
; Entries are ordered oldest-first (index 0 = oldest, last index = newest).
String Function BuildJournalPayloadJson()
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    String entries = ""
    Int i = 0
    while i < count
        String line = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", i))
        Int gameDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        String tone = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", i))
        String symbol = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Symbols", i))
        String fictionDate = JsonSafeString(JournalDayToFictionDate(gameDay))
        String entryTitle = JsonSafeString(JournalToneToTitle(tone))
        String valence = JournalToneToValence(tone)
        String entry = "{\"date\":\"" + fictionDate + "\""
        entry = entry + ",\"day\":" + gameDay
        entry = entry + ",\"symbol\":\"" + symbol + "\""
        entry = entry + ",\"tone\":\"" + tone + "\""
        entry = entry + ",\"valence\":\"" + valence + "\""
        entry = entry + ",\"title\":\"" + entryTitle + "\""
        entry = entry + ",\"text\":\"" + line + "\"}"
        if i > 0
            entries = entries + ","
        endIf
        entries = entries + entry
        i += 1
    endWhile
    ; Path info point: race + path only (no standing -- the STANDING meter below
    ; already shows standing). Same path source as Survey Devotion (GetPlayerMcmModeLine),
    ; shown regardless of standing, with a startup-pending form.
    String pathInfo = GetOriginRaceLabel(GetPlayerOriginRaceIndex())
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") == 1
        pathInfo = pathInfo + " | " + GetPlayerMcmModeLine()
    else
        pathInfo = pathInfo + " | path not yet chosen"
    endIf
    String j = "{\"mode\":\"journal\",\"journal\":{"
    j = j + "\"title\":\"Book of Days\""
    j = j + ",\"summary\":\"A record of devotional acts since the path began.\""
    j = j + ",\"survey\":\"" + JsonSafeString(pathInfo) + "\""
    j = j + ",\"entries\":[" + entries + "]}}"
    return j
EndFunction

; Short title derived from the tone/event key.
String Function JournalToneToTitle(String toneKey)
    if toneKey == "tier.reach"
        return "Favor deepened"
    endIf
    if toneKey == "curse.onset"
        return "A shadow falls"
    endIf
    if toneKey == "curse.cure"
        return "The curse lifts"
    endIf
    if toneKey == "neglect.drop"
        return "Silence grows"
    endIf
    if toneKey == "neglect.recover"
        return "Return to the path"
    endIf
    if toneKey == "emergence.onset"
        return "An emergence"
    endIf
    if toneKey == "substrate.act"
        return "An act of devotion"
    endIf
    return "A moment noted"
EndFunction

; Map the journal tone/event key to an accessible valence the UI renders as a
; direction mark + tag + color spine: good / warning / neutral. Color is never the
; only cue (the mark direction and tag word carry it for color-blind readers).
String Function JournalToneToValence(String toneKey)
    if toneKey == "tier.reach"
        return "good"
    endIf
    if toneKey == "curse.cure"
        return "good"
    endIf
    if toneKey == "neglect.recover"
        return "good"
    endIf
    if toneKey == "emergence.onset"
        return "good"
    endIf
    if toneKey == "substrate.act"
        return "good"
    endIf
    if toneKey == "curse.onset"
        return "warning"
    endIf
    if toneKey == "neglect.drop"
        return "warning"
    endIf
    return "neutral"
EndFunction

; Send the Book of Days journal to Prisma as a player-opened modal.
Function SendPrismaJournalPayload(Bool playerRequested = false)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    ; AllowPrismaBlockingSurfaces gates GAMEPLAY auto-push (default off). A player-pressed
    ; hotkey passes playerRequested=true to bypass that gate -- it is player-owned, not auto-push.
    if !AllowPrismaBlockingSurfaces && !playerRequested
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson(BuildJournalPayloadJson())
EndFunction

; Close the Book of Days overlay (hotkey toggle / second press). The journal view
; is a NON-FOCUSED overlay, so there is no in-view button click to rely on -- the
; close is driven from Papyrus by sending the {"journalClose":true} signal that
; app.js handleOverlayPayload already consumes (hides the journal modal). Uses the
; unfocused overlay channel, never the focused panel, so no input trap.
Function ClosePrismaJournal()
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson("{\"journalClose\":true}")
EndFunction

Bool Function SelectMedallionEntry(String optionId)
    if !CanSelectMedallionEntry(optionId)
        Trace(1, "Medallion selection blocked for " + optionId + ".")
        return False
    endIf

    PDV_DeityBase deity = GetMedallionDeityForOptionId(optionId)
    SetActiveDeity(deity)
    Trace(1, "Medallion selected " + deity.DeityName + ".")
    return True
EndFunction

Bool Function CanSelectMedallionEntry(String optionId)
    if !IsMedallionOptionAvailableForOrigin(optionId, GetPlayerOriginRaceIndex())
        return False
    endIf

    return IsMedallionDeitySelectable(GetMedallionDeityForOptionId(optionId))
EndFunction

String Function GetActiveMedallionOptionId()
    if !_activeDeity
        return ""
    endIf

    return GetMedallionOptionIdForDeity(_activeDeity)
EndFunction

String Function GetMedallionSectionsJson(Int originRace)
    if originRace == ORIGIN_NORD
        return MedallionSection("native", "Native worship", GetNordMedallionEntriesJson())
    elseIf originRace == ORIGIN_IMPERIAL
        return MedallionSection("native", "Native worship", GetImperialMedallionEntriesJson())
    elseIf originRace == ORIGIN_BRETON
        return MedallionSection("native", "Native worship", GetBretonMedallionEntriesJson())
    elseIf originRace == ORIGIN_ALTMER
        return MedallionSection("native", "Native worship", GetAltmerMedallionEntriesJson())
    elseIf originRace == ORIGIN_BOSMER
        return MedallionSection("native", "Native worship", GetBosmerNativeMedallionEntriesJson()) + "," + MedallionSection("substrate_focus", "Path focus", GetBosmerFocusMedallionEntriesJson())
    elseIf originRace == ORIGIN_DUNMER
        return MedallionSection("native", "Native worship", GetDunmerMedallionEntriesJson())
    elseIf originRace == ORIGIN_KHAJIIT
        return MedallionSection("native", "Native worship", GetKhajiitMedallionEntriesJson())
    elseIf originRace == ORIGIN_ARGONIAN
        return MedallionSection("native", "Native worship", GetArgonianMedallionEntriesJson())
    elseIf originRace == ORIGIN_ORC
        return MedallionSection("native", "Native worship", GetOrcMedallionEntriesJson())
    elseIf originRace == ORIGIN_REDGUARD
        return MedallionSection("native", "Native worship", GetRedguardMedallionEntriesJson())
    endIf

    return MedallionSection("native", "Native worship", MedallionEntry("unknown", "Devotion", "substrate", "journal", None, False, "Your origin is not settled yet.", "Once your origin is known, the medallion can show the roster your people can name.", "Origin readback is pending."))
EndFunction

String Function GetNordMedallionEntriesJson()
    String entries = MedallionEntry("kyne", "Kyne", "god", "kyne", PDV_Kyne, True, "Sky, storm, hunt, and warrior-spirit.", "Kyne is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("kynareth", "Kynareth", "god", "kyne", "The Nine Divines sky road.")
    entries = entries + "," + MedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, True, "Open defiance and human apotheosis.", "Talos is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("shor", "Shor", "god", "shor", "The old king and afterlife road.")
    entries = entries + "," + PendingMedallionEntry("tsun", "Tsun", "god", "tsun", "Trial, honor, and the threshold.")
    entries = entries + "," + PendingMedallionEntry("stuhn", "Stuhn", "god", "stuhn", "Mercy in war and fair ransom.")
    entries = entries + "," + PendingMedallionEntry("mara", "Mara", "god", "mara", "Love, hearth, and compassion.")
    entries = entries + "," + PendingMedallionEntry("akatosh", "Akatosh", "god", "akatosh", "Time, order, and dragon authority.")
    entries = entries + "," + PendingMedallionEntry("arkay", "Arkay", "god", "arkay", "Death, burial, and proper passage.")
    entries = entries + "," + PendingMedallionEntry("stendarr", "Stendarr", "god", "stendarr", "Mercy, justice, and protection.")
    entries = entries + "," + PendingMedallionEntry("julianos", "Julianos", "god", "julianos", "Law, learning, and craft of mind.")
    entries = entries + "," + PendingMedallionEntry("dibella", "Dibella", "god", "dibella", "Beauty, art, and embodied grace.")
    entries = entries + "," + PendingMedallionEntry("zenithar", "Zenithar", "god", "zenithar", "Work, trade, and honest craft.")
    return entries
EndFunction

String Function GetImperialMedallionEntriesJson()
    String entries = PendingMedallionEntry("kynareth", "Kynareth", "god", "kyne", "Road, wind, and natural order.")
    entries = entries + "," + PendingMedallionEntry("mara", "Mara", "god", "mara", "Love, family, and mercy.")
    entries = entries + "," + PendingMedallionEntry("akatosh", "Akatosh", "god", "akatosh", "Time, covenant, and empire.")
    entries = entries + "," + PendingMedallionEntry("arkay", "Arkay", "god", "arkay", "Life, death, and lawful burial.")
    entries = entries + "," + PendingMedallionEntry("stendarr", "Stendarr", "god", "stendarr", "Mercy, protection, and civic virtue.")
    entries = entries + "," + PendingMedallionEntry("julianos", "Julianos", "god", "julianos", "Law, learning, and reason.")
    entries = entries + "," + PendingMedallionEntry("dibella", "Dibella", "god", "dibella", "Art, beauty, and human grace.")
    entries = entries + "," + PendingMedallionEntry("zenithar", "Zenithar", "god", "zenithar", "Work, trade, and prosperity.")
    return entries
EndFunction

String Function GetBretonMedallionEntriesJson()
    String entries = PendingMedallionEntry("kynareth", "Kynareth", "god", "kyne", "Sky, travel, and druidic memory.")
    entries = entries + "," + MedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, True, "Civic defiance and Septim inheritance.", "Talos is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("mara", "Mara", "god", "mara", "Household, mercy, and love.")
    entries = entries + "," + PendingMedallionEntry("akatosh", "Akatosh", "god", "akatosh", "Time, order, and covenant.")
    entries = entries + "," + PendingMedallionEntry("arkay", "Arkay", "god", "arkay", "Death, burial, and clean endings.")
    entries = entries + "," + PendingMedallionEntry("stendarr", "Stendarr", "god", "stendarr", "Mercy, protection, and oath.")
    entries = entries + "," + PendingMedallionEntry("julianos", "Julianos", "god", "julianos", "Learning, law, and formal craft.")
    entries = entries + "," + PendingMedallionEntry("dibella", "Dibella", "god", "dibella", "Beauty, courtliness, and grace.")
    entries = entries + "," + PendingMedallionEntry("zenithar", "Zenithar", "god", "zenithar", "Trade, craft, and honest work.")
    entries = entries + "," + PendingMedallionEntry("magnus", "Magnus", "god", "magnus", "Magic, light, and hidden inheritance.")
    entries = entries + "," + PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Pilgrimage, endurance, and Elven memory.")
    entries = entries + "," + MedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, True, "Green memory, story, and law.", "Y'ffre is live and scorable in the current deity roster.", "")
    return entries
EndFunction

String Function GetAltmerMedallionEntriesJson()
    String entries = PendingMedallionEntry("mara", "Mara", "god", "mara", "Kinship, care, and ordered mercy.")
    entries = entries + "," + PendingMedallionEntry("stendarr", "Stendarr", "god", "stendarr", "Mercy and lawful protection.")
    entries = entries + "," + PendingMedallionEntry("magnus", "Magnus", "god", "magnus", "Light, magic, and origin memory.")
    entries = entries + "," + PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Endurance, pilgrimage, and old discipline.")
    entries = entries + "," + MedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, True, "Story, form, and natural law.", "Y'ffre is live and scorable in the current deity roster.", "")
    entries = entries + "," + MedallionEntry("auri-el", "Auri-El", "god", "auri-el", GetDeityByName("Auri-El"), True, "The founding light and ancestral ascent.", "Auri-El is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("syrabane", "Syrabane", "god", "syrabane", "Magic, craft, and survival through wisdom.")
    entries = entries + "," + PendingMedallionEntry("xarxes", "Xarxes", "god", "xarxes", "Lineage, record, and ordered memory.")
    entries = entries + "," + PendingMedallionEntry("trinimac", "Trinimac", "god", "trinimac", "Warrior order and unbroken nobility.")
    return entries
EndFunction

String Function GetBosmerNativeMedallionEntriesJson()
    String entries = MedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, True, "The Green, story, and the Old Contract.", "Y'ffre is live and scorable in the current deity roster.", "")
    entries = entries + "," + MedallionEntry("auri-el", "Auri-El", "god", "auri-el", GetDeityByName("Auri-El"), True, "Elven ancestry and high memory.", "Auri-El is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("xarxes", "Xarxes", "god", "xarxes", "Record, lineage, and written memory.")
    entries = entries + "," + MedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", PDV_BaanDar, True, "Trickster road, masks, and survival.", "Baan Dar is live and scorable in the current deity roster.", "")
    return entries
EndFunction

String Function GetBosmerFocusMedallionEntriesJson()
    return MedallionEntry("zen", "Z'en", "god", "zen", PDV_Zen, True, "Debt, toil, exchange, and obligation.", "Z'en is live and scorable as a Bosmer path focus in the current deity roster.", "")
EndFunction

String Function GetDunmerMedallionEntriesJson()
    String entries = PendingMedallionEntry("azura", "Azura", "prince", "azura", "Dawn, dusk, prophecy, and fate.")
    entries = entries + "," + PendingMedallionEntry("boethiah", "Boethiah", "prince", "boethiah", "Trial, overthrow, and hard becoming.")
    entries = entries + "," + PendingMedallionEntry("mephala", "Mephala", "prince", "mephala", "Web, secrecy, clan, and hidden duty.")
    return entries
EndFunction

String Function GetKhajiitMedallionEntriesJson()
    String entries = PendingMedallionEntry("azura", "Azurah", "prince", "azura", "Dusk, dawn, moon-shadow, and fate.")
    entries = entries + "," + PendingMedallionEntry("boethiah", "Boethra", "prince", "boethiah", "Trial, edge, and hard lessons.")
    entries = entries + "," + PendingMedallionEntry("mephala", "Mafala", "prince", "mephala", "Hidden paths, webs, and clan memory.")
    entries = entries + "," + MedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", PDV_BaanDar, True, "The bandit god, wit, and road survival.", "Baan Dar is live and scorable in the current deity roster.", "")
    entries = entries + "," + PendingMedallionEntry("rajhin", "Rajhin", "god", "rajhin", "The clever thief and impossible escape.")
    entries = entries + "," + PendingMedallionEntry("alkosh", "Alkosh", "god", "alkosh", "Dragon order and time in Khajiit memory.")
    entries = entries + "," + PendingMedallionEntry("khenarthi", "Khenarthi", "god", "khenarthi", "Wind, sky-road, and breath.")
    entries = entries + "," + PendingMedallionEntry("riddle-thar", "Riddle'Thar", "god", "riddle-thar", "Balance, ja-Kha'jay, and right conduct.")
    entries = entries + "," + PendingMedallionEntry("jone-jode", "Jone and Jode", "god", "lunar", "The moons, the lattice, and the road home.")
    return entries
EndFunction

String Function GetArgonianMedallionEntriesJson()
    String entries = PendingMedallionEntry("hist", "The Hist", "substrate", "hist", "Root, memory, people, and sap.")
    entries = entries + "," + PendingMedallionEntry("sithis", "Sithis", "god", "sithis", "Void, change, and dangerous silence.")
    return entries
EndFunction

String Function GetOrcMedallionEntriesJson()
    return PendingMedallionEntry("malacath", "Malacath", "prince", "malacath", "Oath, code, exile, and vengeance.")
EndFunction

String Function GetRedguardMedallionEntriesJson()
    String entries = PendingMedallionEntry("satakal", "Satakal", "god", "satakal", "Worldskin, cycle, and cosmic turning.")
    entries = entries + "," + PendingMedallionEntry("ruptga", "Ruptga", "god", "ruptga", "Tall Papa, ancestry, and guidance.")
    entries = entries + "," + PendingMedallionEntry("tuwhacca", "Tu'whacca", "god", "tu-whacca", "Death, passage, and the proper road.")
    entries = entries + "," + PendingMedallionEntry("tava", "Tava", "god", "tava", "Wind, sailors, and safe passage.")
    entries = entries + "," + PendingMedallionEntry("leki", "Leki", "god", "leki", "Sword-skill, discipline, and grace.")
    entries = entries + "," + PendingMedallionEntry("onsi", "Onsi", "god", "onsi", "The blade, craft, and warrior making.")
    entries = entries + "," + PendingMedallionEntry("hoon-ding", "HoonDing", "god", "hoon-ding", "Make-way spirit and impossible survival.")
    return entries
EndFunction

String Function MedallionSection(String sectionId, String titleText, String entriesJson)
    return "{\"section_id\":\"" + JsonSafeString(sectionId) + "\",\"title\":\"" + JsonSafeString(titleText) + "\",\"entries\":[" + entriesJson + "]}"
EndFunction

String Function PendingMedallionEntry(String optionId, String titleText, String kindText, String symbolName, String summaryText)
    String descriptionText = titleText + " belongs in this native roster, but is not yet a live scoring patron."
    String disabledText = "Awaiting live deity record and scoring path."
    if kindText == "prince"
        descriptionText = titleText + " belongs in this native roster, but is not yet a live Prince path."
        disabledText = "Awaiting live Prince path and scoring route."
    elseIf kindText == "substrate"
        descriptionText = titleText + " is live as a cultural substrate, but not yet as a selectable medallion patron."
        disabledText = "Awaiting medallion-safe substrate selection."
    endIf

    return MedallionEntry(optionId, titleText, kindText, symbolName, None, False, summaryText, descriptionText, disabledText)
EndFunction

String Function MedallionEntry(String optionId, String titleText, String kindText, String symbolName, PDV_DeityBase deity, Bool requestedSelectable, String summaryText, String descriptionText, String disabledReason)
    Bool selectable = requestedSelectable && IsMedallionDeitySelectable(deity)
    String disabledText = disabledReason
    if !selectable && disabledText == ""
        disabledText = "Awaiting live deity record and scoring path."
    endIf

    String entry = "{\"option_id\":\"" + JsonSafeString(optionId) + "\""
    entry = entry + ",\"title\":\"" + JsonSafeString(titleText) + "\""
    entry = entry + ",\"kind\":\"" + JsonSafeString(kindText) + "\""
    entry = entry + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    entry = entry + ",\"visible\":true"
    entry = entry + ",\"selectable\":" + BoolToJson(selectable)
    entry = entry + ",\"summary\":\"" + JsonSafeString(summaryText) + "\""
    entry = entry + ",\"description\":\"" + JsonSafeString(descriptionText) + "\""
    if disabledText != ""
        entry = entry + ",\"disabled_reason\":\"" + JsonSafeString(disabledText) + "\""
    endIf
    entry = entry + "}"
    return entry
EndFunction

Bool Function IsMedallionDeitySelectable(PDV_DeityBase deity)
    if !deity || !PDV_FLST_AllDeities
        return False
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        if (PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase) == deity
            return True
        endIf
        i += 1
    endWhile

    return False
EndFunction

PDV_DeityBase Function GetMedallionDeityForOptionId(String optionId)
    if optionId == "kyne"
        return PDV_Kyne
    elseIf optionId == "talos"
        return PDV_Talos
    elseIf optionId == "auri-el"
        return GetDeityByName("Auri-El")
    elseIf optionId == "yffre"
        return PDV_Yffre
    elseIf optionId == "zen"
        return PDV_Zen
    elseIf optionId == "baan-dar"
        return PDV_BaanDar
    endIf

    return None
EndFunction

String Function GetMedallionOptionIdForDeity(PDV_DeityBase deity)
    if deity == PDV_Kyne
        return "kyne"
    elseIf deity == PDV_Talos
        return "talos"
    elseIf deity == PDV_Yffre
        return "yffre"
    elseIf deity == PDV_Zen
        return "zen"
    elseIf deity == PDV_BaanDar
        return "baan-dar"
    elseIf deity && deity.DeityName == "Auri-El"
        return "auri-el"
    endIf

    return ""
EndFunction

Bool Function IsMedallionOptionAvailableForOrigin(String optionId, Int originRace)
    if optionId == "kyne"
        return originRace == ORIGIN_NORD
    elseIf optionId == "talos"
        return originRace == ORIGIN_NORD || originRace == ORIGIN_BRETON
    elseIf optionId == "auri-el"
        return originRace == ORIGIN_ALTMER || originRace == ORIGIN_BOSMER
    elseIf optionId == "yffre"
        return originRace == ORIGIN_BRETON || originRace == ORIGIN_ALTMER || originRace == ORIGIN_BOSMER
    elseIf optionId == "zen"
        return originRace == ORIGIN_BOSMER
    elseIf optionId == "baan-dar"
        return originRace == ORIGIN_BOSMER || originRace == ORIGIN_KHAJIIT
    endIf

    return False
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
        Debug.MessageBox("Devotion is missing the Bosmer reckoning message record.")
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
        Debug.MessageBox("Devotion is missing the Bosmer path suggestion message record.")
        PDV_BosmerPathTrack.ClearOfferedTransition("missing_message")
        Trace(1, "Bosmer suggestion popup blocked for " + targetState + ": message record missing.")
        return
    endIf

    String pathSymbol = GetBosmerPathSymbol(targetState)
    Int choice = suggestionMessage.Show()
    if choice == 0
        PDV_BosmerPathTrack.AcceptOfferedTransition("popup_accept")
        SendPrismaToast(pathSymbol, "good", "A new path stirs", "Confirm the change at the next rite.")
    else
        PDV_BosmerPathTrack.RefuseOfferedTransition("popup_refuse")
        SendPrismaToast(pathSymbol, "neutral", "The call fades", "You turn aside from that path for now.")
    endIf
EndFunction

; Prisma symbol for a Bosmer path state (used before the path is active, so we can't
; rely on _activeDeity). Old Contract and Living Story both center on Y'ffre.
String Function GetBosmerPathSymbol(Int pathState)
    if pathState == BOSMER_PATH_EXCHANGE
        return "zen"
    elseIf pathState == BOSMER_PATH_BANDIT_ROAD
        return "baan-dar"
    endIf
    return "yffre"
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
        SendPrismaToast(GetBosmerPathSymbol(pendingState), "warning", "The rite fails", "The new path has not yet been proven.")
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

Function EnsureDunmerAncestralUrn()
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_BOOK_DunmerAncestralUrn
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(PDV_BOOK_DunmerAncestralUrn) <= 0
        playerRef.AddItem(PDV_BOOK_DunmerAncestralUrn, 1, True)
        Trace(2, "Dunmer ancestral urn granted.")
    endIf
EndFunction

Function EnsureArgonianHistSapToken()
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_BOOK_ArgonianHistSapToken
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(PDV_BOOK_ArgonianHistSapToken) <= 0
        playerRef.AddItem(PDV_BOOK_ArgonianHistSapToken, 1, True)
        StorageUtil.SetIntValue(None, "PDV.Token.ArgonianHistSap.Granted", 1)
        Trace(2, "Argonian Hist sap token granted.")
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

; Builds a full dev-facing devotion snapshot and writes it to a text file so
; beta testers can attach one file to a bug report instead of digging for logs
; or numbers. Returns the written filename, or "" if the write failed.
String Function ExportDevotionReport()
    String nl = "\n"
    Int originRace = GetPlayerOriginRaceIndex()
    Float gameDay = Utility.GetCurrentGameTime()

    String report = "=== Devotion Bug Report Snapshot ==="
    report = report + nl + "Generated in-game. Attach this file to your report."
    report = report + nl
    report = report + nl + "-- Versions --"
    report = report + nl + "Framework schema: " + FRAMEWORK_SCHEMA_VERSION
    report = report + nl + "Likes/dislikes: " + LIKES_DISLIKES_VERSION
    report = report + nl + "Prince LD: " + PRINCE_LD_VERSION
    report = report + nl + "Daedric pact: " + DAEDRIC_PACT_VERSION
    report = report + nl + "In-game day: " + (gameDay as Int)
    report = report + nl
    report = report + nl + "-- Summary --"
    report = report + nl + "Race: " + GetOriginRaceLabel(originRace) + " (index " + originRace + ")"
    report = report + nl + "Summary: " + GetPlayerMcmSummaryLine()
    report = report + nl + "Mode: " + GetPlayerMcmModeLine()
    report = report + nl + "Patron: " + GetPlayerMcmPatronLine() + " | state " + GetPatronState() + " | activeIndex " + GetActiveDeityIndex()
    report = report + nl + "Standing: " + GetPlayerMcmStandingLine()
    report = report + nl + "Curse: " + GetPlayerMcmCurseLine()
    report = report + nl + "Favor: " + GetPlayerMcmFavorLine()
    report = report + nl + "Neglect: " + GetPlayerMcmNeglectLine()
    report = report + nl + "Startup: " + GetStartupMcmLine()
    report = report + nl
    report = report + nl + "-- Survey readout --"
    report = report + nl + GetSurveyDevotionText()
    report = report + nl
    report = report + nl + "-- Per-deity ledger (tier: 0 None 1 Seeker 2 Devoted 3 Champion) --"
    report = report + nl + "deity [index] | tier | piety | scratch"

    Int count = GetDeityCount()
    Int i = 0
    while i < count
        PDV_DeityBase deityEntry = GetDeityAtListIndex(i)
        if deityEntry
            report = report + nl + deityEntry.DeityName + " [" + deityEntry.DeityIndex + "] | " + GetTier(deityEntry) + " | " + GetPiety(deityEntry) + " | +" + GetPietyToday(deityEntry)
        endIf
        i += 1
    endWhile

    report = report + nl
    report = report + nl + "=== End of report ==="

    String fileName = "PDV_DevotionReport.txt"
    Bool wrote = MiscUtil.WriteToFile(fileName, report, False, False)
    Debug.Trace("[PDV] ExportDevotionReport wrote=" + wrote + " file=" + fileName)
    if wrote
        return fileName
    endIf
    return ""
EndFunction

String Function GetSurveyDevotionText()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace < 0
        return AppendRecentDevotionEvents("Devotion has not settled yet. Wait a moment, then survey again.")
    endIf

    if originRace != ORIGIN_NORD
        if originRace == ORIGIN_ALTMER
            return AppendRecentDevotionEvents(GetAltmerSurveyText())
        elseIf originRace == ORIGIN_KHAJIIT
            return AppendRecentDevotionEvents(GetKhajiitSurveyText())
        elseIf originRace == ORIGIN_BOSMER
            return AppendRecentDevotionEvents(GetBosmerSurveyText())
        elseIf originRace == ORIGIN_ARGONIAN
            return AppendRecentDevotionEvents(GetArgonianSurveyText())
        elseIf originRace == ORIGIN_ORC
            return AppendRecentDevotionEvents(GetOrcSurveyText())
        elseIf originRace == ORIGIN_REDGUARD
            return AppendRecentDevotionEvents(GetRedguardSurveyText())
        elseIf originRace == ORIGIN_IMPERIAL
            return AppendRecentDevotionEvents(GetImperialSurveyText())
        elseIf originRace == ORIGIN_BRETON
            return AppendRecentDevotionEvents(GetBretonSurveyText())
        elseIf originRace == ORIGIN_DUNMER
            return AppendRecentDevotionEvents(GetDunmerSurveyText())
        endIf

        return AppendRecentDevotionEvents("Your devotion is watched. Standing: " + GetCurrentStandingBand() + ".")
    endIf

    String text = GetNordSurveyBaseText()
    String scarText = GetNordScarLabel()
    if scarText != ""
        text = text + "\n\n" + scarText
    endIf

    return AppendRecentDevotionEvents(text)
EndFunction

Function RecordRecentDevotionEvent(String line)
    if line == ""
        return
    endIf

    while StorageUtil.StringListCount(None, "PDV.RecentDevotionEvents") >= 8
        StorageUtil.StringListShift(None, "PDV.RecentDevotionEvents")
    endWhile

    StorageUtil.StringListAdd(None, "PDV.RecentDevotionEvents", line, True)
EndFunction

String Function GetRecentDevotionEventsText()
    Int count = StorageUtil.StringListCount(None, "PDV.RecentDevotionEvents")
    if count <= 0
        return ""
    endIf

    String text = "Recent:"
    Int index = 0
    while index < count
        text = text + "\n" + StorageUtil.StringListGet(None, "PDV.RecentDevotionEvents", index)
        index = index + 1
    endWhile

    return text
EndFunction

String Function AppendRecentDevotionEvents(String text)
    String recent = GetRecentDevotionEventsText()
    if recent != ""
        return text + "\n\n" + recent
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
    String band = GetCurrentStandingBand()
    if IsNordVampireSuppressed()
        return "Sovngarde is closed while the thirst remains. Standing: " + band + ". Cure the curse to reopen the road."
    endIf

    String contextText = GetNordContextSurveyText()
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        String focusedText = _activeDeity.DeityName + " names you. Standing: " + band + "."
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == NORD_BASELINE_NINE_DIVINES
            return "You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath. Standing: " + band + "." + contextText
        endIf

        return "You honor the Old Ways broadly. The pantheon has noted you. Standing: " + band + "." + contextText
    endIf

    if PDV_HircinePath
        String hircineSummary = PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "The hunt pulls at the edge of the Old Ways. Standing: " + band + ". No patron has claimed you, but the beast is listening." + contextText
        endIf
    endIf

    return "No Nord patron has answered yet. Standing: " + band + ". Keep the rites, and the road will grow clearer." + contextText
EndFunction

String Function GetNordContextSurveyText()
    String text = ""
    Int oldWaysCount = StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount")
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if oldWaysCount > 0
        text = text + " The Old Ways have noticed how you live."
    endIf
    if kyneTalosCount > 0
        text = text + " Kyne and Talos weigh on your road."
    endIf
    if edgeCount > 0
        text = text + " Hunt and death-duty press at the edges."
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

; Player-facing devotional band for the active standing (Architecture v3 Section 2.1),
; mirroring GetCurrentStandingLabel's tier resolution. Survey + player surfaces use this;
; GetCurrentStandingLabel keeps the internal Seeker/Champion words for dev/MCM only.
String Function GetCurrentStandingBand()
    Int tierValue = TIER_NONE
    if _activeDeity
        tierValue = GetTier(_activeDeity)
    elseIf PDV_GLO_ActiveTier
        tierValue = PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return GetPublicTierBand(tierValue)
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
    String text = GetAltmerAlignmentSurveyBaseText()
    Int crisisState = GetAltmerCrisisState()
    if crisisState == ALTMER_CRISIS_DISSONANT
        text = text + " The crisis has not settled; each mortal exception still tests the doctrine."
    elseIf crisisState == ALTMER_CRISIS_SCARRED_RESOLVED
        text = text + " The crisis is resolved, but its scar still teaches caution."
    endIf

    if IsAltmerVampireExiled()
        text = text + " The thirst has exiled you from the dawn."
    elseIf HasAltmerVampireExileScar()
        text = text + " The vampire scar remains in the record, but the dawn can reach you again."
    endIf

    if IsAltmerWerewolfHalted()
        text = text + " The beast has stopped your devotion."
    endIf

    String favor = GetFavorSurfacingLabel(FAVOR_LANE_ALTMER, StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.LastFamily"))
    if favor != ""
        text = text + " Last favor: " + favor + "."
    endIf

    return text
EndFunction

String Function GetAltmerAlignmentSurveyBaseText()
    String band = GetCurrentStandingBand()
    if !PDV_ThalmorAlignmentTrack
        return "Auri-El remains the foundation. Standing: " + band + "."
    endIf

    Int alignment = PDV_ThalmorAlignmentTrack.GetValue()
    if alignment <= -76
        return "You hold open heterodoxy: Auri-El remains the foundation, but the Thalmor cannot own the path. Standing: " + band + "."
    elseIf alignment <= -51
        return "You keep private heterodoxy beneath the dawn, testing doctrine without surrendering it. Standing: " + band + "."
    elseIf alignment >= 76
        return "You stand Thalmor-devout, enforcing the return as law and doctrine together. Standing: " + band + "."
    elseIf alignment >= 51
        return "You walk public orthodoxy, letting Altmeri discipline answer Skyrim's compromises. Standing: " + band + "."
    endIf

    return "You remain uncommitted in the Thalmor question, holding Auri-El's foundation while the path sharpens. Standing: " + band + "."
EndFunction

String Function GetKhajiitSurveyText()
    String band = GetCurrentStandingBand()
    Int focusValue = GetKhajiitFocusedEmphasis()
    String text = ""
    if focusValue > KHAJIIT_FOCUS_NONE
        text = "You walk inside the Lunar Lattice, and " + GetKhajiitFocusLabel(focusValue) + " leads your devotion now. Standing: " + band + ". You did not choose it; you were walking it."
    else
        text = "You walk inside the Lunar Lattice, broad and unfocused, held by the moons and the road. Standing: " + band + ". No god leads yet, and that is whole."
    endIf

    if PDV_KhajiitLunarSubstrate
        text = text + " Your moon practice is " + GetKhajiitLunarTierLabel(PDV_KhajiitLunarSubstrate.GetSubstrateTier()) + "."
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarSourceCount") > 0
            text = text + " A lunar source has been read and remembered."
        endIf
        if PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has begun to carry weight."
        endIf
    else
        text = text + " The moons have not yet taken the measure of your practice."
    endIf

    Int presiding = GetCurrentLunarPresidingFocus()
    if presiding > KHAJIIT_FOCUS_NONE
        if GetActiveLunarFavoredFocus() == presiding
            text = text + " This phase of the Lattice belongs to " + GetKhajiitFocusLabel(presiding) + ", and the moons answer your standing."
        else
            text = text + " This phase of the Lattice belongs to " + GetKhajiitFocusLabel(presiding) + "."
        endIf
    endIf

    Int posture = GetKhajiitLunarPosture()
    if posture != KHAJIIT_LUNAR_POSTURE_NORMAL
        text = text + "\n\n" + GetKhajiitLunarPostureReadout(posture)
    endIf

    return text
EndFunction

; Per-god standing line for the Khajiit moon-paths MCM readout, so the silent
; focused-emphasis system stays legible. Shows standing, raw piety, and a marker
; for the leading path and the currently moon-favored path.
String Function GetKhajiitFocusStandingLine(Int focusValue)
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    if !deity
        return "not yet wired"
    endIf

    String line = GetTierStandingLabel(GetTier(deity)) + ", piety " + FormatTwoDecimals(GetPiety(deity))
    if GetKhajiitFocusedEmphasis() == focusValue
        line = line + " (leading)"
    endIf
    if GetCurrentLunarPresidingFocus() == focusValue
        if GetActiveLunarFavoredFocus() == focusValue
            line = line + " (presiding, favored)"
        else
            line = line + " (presiding)"
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

String Function GetBosmerSurveyText()
    if !PDV_BosmerPathTrack
        return "The Green is here, but no path has been declared yet. Sleep and choose the Old Contract, the Living Story, the Exchange, or the Bandit Road."
    endIf

    Int pathValue = PDV_BosmerPathTrack.GetCurrentState()
    String band = GetCurrentStandingBand()
    String text = ""
    if pathValue == BOSMER_PATH_OLD_CONTRACT
        text = "You walk the Old Contract, the Green Pact kept in full. Standing: " + band + ". Compliance: " + GetBosmerComplianceBand() + ". Y'ffre holds you to the terms."
        if IsBosmerPactBound()
            text = text + " The Pact is binding, and you are keeping to it."
        elseIf GetBosmerLapsedFromPact()
            text = text + " The Pact has lapsed, and a reckoning with Y'ffre is owed."
        else
            text = text + " The Pact is not yet taken up; the terms wait on your word."
        endIf
    elseIf pathValue == BOSMER_PATH_LIVING_STORY
        text = "You walk the Living Story, the covenant carried in memory and community. Standing: " + band + ". The Story passes through you."
    elseIf pathValue == BOSMER_PATH_EXCHANGE
        text = "You walk the Exchange, the world kept even debt by debt. Standing: " + band + ". Z'en weighs your account."
    else
        text = "You walk the Bandit Road, the exile's theology of the open road. Standing: " + band + ". Baan Dar favors the improbable."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Bosmer.RoutePressure") > 0
        text = text + " While the curse is on you, you stand outside the living world, and the path waits until it is lifted."
    endIf

    return text
EndFunction

String Function GetBosmerPathLabel()
    if PDV_BosmerPathTrack
        return PDV_BosmerPathTrack.GetStateLabel()
    endIf

    return "Unsettled"
EndFunction

; Green Pact compliance band for the Old Contract survey readout (Architecture v3
; GreenPactCompliance thresholds: Apostate 0-19 / Lapsed 20-49 / Observant 50-79 / Strict 80-100).
String Function GetBosmerComplianceBand()
    Int compliance = GetBosmerGreenPactCompliance()
    if compliance >= 80
        return "Strict"
    elseIf compliance >= 50
        return "Observant"
    elseIf compliance >= 20
        return "Lapsed"
    endIf
    return "Apostate"
EndFunction

String Function GetArgonianSurveyText()
    String band = GetCurrentStandingBand()
    if !PDV_ArgonianHistSubstrate
        return "The Hist is distant, far from Black Marsh, and your devotion is still settling. Standing: " + band + "."
    endIf

    String posture = GetArgonianHistPostureLabel()
    String text = ""
    if posture == "Normal"
        text = "You carry the Saxhleel exile, far from Black Marsh. The Hist is distant, as it always is in Skyrim, but it still reaches you. Standing: " + band + "."
    else
        text = "You carry the Saxhleel exile, far from Black Marsh. The Hist is " + posture + ". Standing: " + band + "."
    endIf

    Float histRel = PDV_ArgonianHistSubstrate.GetHistRelation()
    if histRel >= 70.0
        text = text + " Hist memory is held: the trees still reach you across all the miles."
    elseIf histRel >= 35.0
        text = text + " Hist memory is present, faint but real beneath the distance."
    elseIf histRel > 0.0
        text = text + " Hist memory is thin, more remembered than felt."
    else
        text = text + " Hist memory is distant, almost out of reach."
    endIf

    Float peopleRel = PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if peopleRel >= 70.0
        text = text + " The People hold you close; the exile community knows you well."
    elseIf peopleRel >= 35.0
        text = text + " The People are with you, the chosen family steady at your side."
    elseIf peopleRel > 0.0
        text = text + " The People are thin around you, the exile bonds loose."
    else
        text = text + " The People are far off; you walk this exile largely alone."
    endIf

    if PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        text = text + " Sithis is awake in you, a third way to make meaning in exile. The void is fully with you now, yet the Hist still comes first."
    else
        Float voidRel = PDV_ArgonianHistSubstrate.GetVoidRelation()
        if voidRel >= 35.0
            text = text + " Sithis stirs in you, the void no longer only a rumor at the edge."
        elseIf voidRel > 0.0
            text = text + " Sithis waits at the edge of you, acknowledged but not yet faced."
        endIf
    endIf

    Int bedCount = StorageUtil.GetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
    if bedCount > 0
        text = text + " The bed you chose has begun to matter; the root remembers where you rest."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Argonian.HistSourceCount") > 0
        text = text + " You have sat with the old Hist-lore, and it stays with you."
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
        return "Malacath watches, but the shape of your life has not settled yet. Carry the code a while, then survey again."
    endIf

    EnsureOrcLifeModeInitialized()
    String band = GetCurrentStandingBand()
    Int mode = PDV_OrcLifeModeTrack.GetCurrentState()
    String text = ""
    if mode == ORC_LIFE_MODE_STRONGHOLD
        text = "You carry Malacath's code inside the stronghold, where forge, kin, and oath hold it with you. Standing: " + band + "."
    elseIf mode == ORC_LIFE_MODE_LEGION_EXILE
        text = "You carry Malacath's code under foreign discipline. The contract is the oath; the endurance is the strength. Standing: " + band + "."
    else
        text = "You carry Malacath's code in the city, alone, with no stronghold to confirm it. Standing: " + band + ". Malacath watches what no one else does."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") > 0
        text = text + " You have sought out the old tellings of Malacath, and kept them."
    endIf
    Int cursePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure")
    if cursePressure == 2
        text = text + " The thirst sets you outside the test until it is cured."
    elseIf cursePressure == 1
        text = text + " The beast in you is being weighed against the code, not turned away from."
    endIf

    return text
EndFunction

String Function GetRedguardSurveyText()
    if !PDV_RedguardSectTrack
        return "The Far Shores are named, but your Redguard sect is not yet readable here."
    endIf

    String text = GetRedguardSurveySectText()
    if StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") > 0
        text = text + " You have read the words of an ancestor-spine, and the dead are nearer for it."
    endIf
    Float farShoresWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")
    if farShoresWeight > 0.0
        text = text + " The Far Shores token has been tended lately, and Tu'whacca holds the way open."
    endIf

    Int cyclePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure")
    if cyclePressure == 2
        text = text + " The vampire curse has set you outside the cycle, and the Far Shores stay shut until you cure it and return through Tu'whacca."
    elseIf cyclePressure == 1
        text = text + " The beast strains your road to a proper death, but the ancestors only watch the closer for it."
    endIf

    return text
EndFunction

String Function GetRedguardSurveySectText()
    Int sectValue = REDGUARD_SECT_FOREBEAR
    if PDV_RedguardSectTrack
        sectValue = PDV_RedguardSectTrack.GetCurrentState()
    endIf

    String standing = GetCurrentStandingBand()
    if sectValue == REDGUARD_SECT_CROWN
        return "You keep the Crown way: orthodox Yokudan practice carried intact in exile. Standing: " + standing + ". The ancestors are strong at your back."
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        return "You keep the Ash'abah duty: the unclean dead are your charge. Standing: " + standing + ". Tu'whacca honors the burden few will."
    endIf

    return "You keep the Forebear way: Redguard identity lived among outsiders. Standing: " + standing + ". The road and the contract are your proving ground."
EndFunction

String Function GetBretonSurveyText()
    String band = GetCurrentStandingBand()
    Int tradition = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if tradition < 0
        return "You have not yet chosen a tradition. Breton faith takes its shape once you walk the Knight's Road, the Hidden Art, or the Green Way. Standing: " + band + "."
    endIf

    String text = ""
    if tradition == 0
        text = "You walk the Knight's Road: vow, mercy, and protective justice. Standing: " + band + "."
        Int vow = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        if vow >= 70
            text = text + " Your knightly vow is intact."
        elseIf vow >= 30
            text = text + " Your knightly vow is strained, and the Road's favor comes harder."
        else
            text = text + " Your knightly vow is broken, and the Road is halted until you restore it."
        endIf
    elseIf tradition == 1
        text = "You walk the Hidden Art: occult practice and the double life. Standing: " + band + "."
        Int exposure = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure", 0)
        if exposure >= 75
            text = text + " Your practice is notorious, openly named, and your patron rewards the full commitment."
        elseIf exposure >= 50
            text = text + " Your practice is known, and the Vigilants are a real danger now."
        elseIf exposure >= 25
            text = text + " Your practice is suspected, and watchful eyes have begun to turn."
        else
            text = text + " Your practice stays hidden, unseen by those who would object."
        endIf
    else
        text = "You walk the Green Way: the old druidic covenant. Standing: " + band + "."
        Int druidic = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0)
        if druidic >= 70
            text = text + " The druidic covenant is acknowledged, and Y'ffre answers you steadily."
        elseIf druidic < 0
            text = text + " The druidic covenant is fraying, and the forest is beginning to forget you."
        else
            text = text + " The druidic covenant is open but unproven, and Y'ffre is waiting."
        endIf
    endIf

    Int fork = GetBretonDruidicForkValue()
    if fork == 1
        text = text + " The beast in you serves the Green, and the covenant has grown around the new shape."
    elseIf fork == 2
        text = text + " You took the beast for your own, and the Green has closed against the wolf."
    elseIf fork == 3
        text = text + " The covenant counts you a betrayer, and the Green presses back against the broken trust."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") > 0
        text = text + " You are being pulled toward another tradition, and the pull weighs against the one you walk."
    endIf

    Int restoration = StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState")
    if restoration == 2
        text = text + " A curse has ruptured your tradition, and its road is closed to you until you are cured."
    elseIf restoration == 1
        text = text + " A curse sits on you, and your tradition will not hold until it is restored."
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
    String band = GetCurrentStandingBand()
    Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
    String text = ""
    if reclamationFocus == 0
        text = "Azura holds your focus; the ash-prayer carries beneath her. Standing: " + band + ". The thresholds are watched."
    elseIf reclamationFocus == 1
        text = "Boethiah holds your focus; the ash-prayer carries beneath. Standing: " + band + ". The dead record your victories."
    elseIf reclamationFocus == 2
        text = "Mephala holds your focus; the ash-prayer carries beneath. Standing: " + band + ". The web holds you, and you hold it."
    else
        text = "The ash-prayer holds and the three Good Daedra answer together. Standing: " + band + ". No single Reclamation has your name yet."
    endIf

    if !PDV_DunmerAncestorSubstrate
        return text + " The ash has not been set yet; the practice is waiting on your first prayer."
    endIf

    Int layerTier = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if layerTier >= 3
        text = text + " The ancestors answer readily; the ash-prayer is deep in you now."
    elseIf layerTier == 2
        text = text + " The ancestors answer without strain; the ash-prayer is steady."
    elseIf layerTier == 1
        text = text + " The ancestors are beginning to answer; the ash-prayer is taking hold."
    else
        text = text + " The ancestors are quiet; the ash-prayer has not yet found its weight."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") > 0
        text = text + " You went seeking the Reclamations, and they answered where you looked."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") > 0
        text = text + " A bargain struck outside the ancestors sits against your name, unpaid."
    endIf
    if PDV_DunmerAncestorSubstrate.GetPrayerCount() > 0
        text = text + " The portable shrine has been set and prayed over; the ash travels with you."
    endIf
    if PDV_DunmerAncestorSubstrate.GetHomeBonusCount() > 0
        text = text + " Prayer kept within your own walls has gathered weight."
    endIf

    Int posture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if posture == 1
        text = text + " Something in you pulls against the ancestors -- the beast, or an unclean rite -- and the ash-prayer carries thinly."
    elseIf posture == 2
        text = text + " The ash-prayer meets no answer; the ancestors do not speak to the undead."
    elseIf posture == 3
        text = text + " The ancestors answer again, but they remember the silence, and so do you."
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

String Function GetImperialSurveyText()
    String band = GetCurrentStandingBand()
    String concordat = GetImperialConcordatLabel()
    String text = ""
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        text = _activeDeity.DeityName + " holds your focus among the Nine. Standing: " + band + ". On the Talos question you stand " + concordat + "."
    else
        text = "You worship the Nine Divines broadly, civic and public. Standing: " + band + ". On the Talos question you stand " + concordat + "."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") > 0
        text = text + " Your service to the public order has been felt as worship."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") > 0
        text = text + " You have kept Talos at hidden shrines, away from watching eyes."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") > 0
        text = text + " You have honored Talos in the open, where the Concordat forbids it."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") > 0
        text = text + " Your patron has taken note of the civic good you have done in their name."
    endIf

    if PDV_Talos
        Float talosMultiplier = GetTalosEffectiveGainMultiplier()
        if talosMultiplier > 1.0
            text = text + " Your defiance has the old breath leaning your way; Talos answers the louder for the risk."
        elseIf talosMultiplier < 1.0
            text = text + " Your standing with the Concordat keeps Talos at arm's length; the old breath comes only faintly."
        else
            text = text + " On the Talos question you have not yet leaned either way, and the old breath waits."
        endIf
    endIf

    if PDV_ConcordatStandingTrack && PDV_ConcordatStandingTrack.HasExtremeResetGate()
        text = text + " You have drifted far enough on the Talos question that a deliberate change of course could now bring you back."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1 || (PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 2)
        text = text + " Curse posture: the civic faith is halted while the undeath holds."
    elseIf PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 1
        text = text + " Curse posture: the civic faith runs strained while the beast is in you."
    elseIf StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHistory") == 1
        text = text + " Curse posture: the civic faith is whole again, but the community religion remembers the absence."
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
    if StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
        return "civic faith halted"
    elseIf PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 2
        return "civic faith halted"
    elseIf PDV_CurseStateService && PDV_CurseStateService.GetCurseState() == 1
        return "civic faith strained"
    elseIf StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHistory") == 1
        return "civic faith scarred"
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
        return "The vampire scar still shows. The road is open again, but not unmarked."
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

; One labeled pattern-summary section by index (0-13), so the MCM can page the
; readout instead of dumping all 14 into a single overflowing message box.
String Function DebugGetPatternSummarySection(Int sectionIndex)
    if sectionIndex == 0
        return "Concordat: " + GetConcordatSummary()
    elseIf sectionIndex == 1
        return "Bosmer: " + GetBosmerSummary()
    elseIf sectionIndex == 2
        return "Dunmer ancestor: " + GetDunmerAncestorSummary()
    elseIf sectionIndex == 3
        return "Khajiit lunar: " + GetKhajiitLunarSummary()
    elseIf sectionIndex == 4
        return "Argonian Hist: " + GetArgonianHistSummary()
    elseIf sectionIndex == 5
        return "Altmer: " + GetAltmerSummary()
    elseIf sectionIndex == 6
        return "Orc: " + GetOrcSummary()
    elseIf sectionIndex == 7
        return "Redguard: " + GetRedguardSummary()
    elseIf sectionIndex == 8
        return "Favor: " + GetContextualFavorSummary()
    elseIf sectionIndex == 9
        return "Commitment: " + GetCommitmentSummary()
    elseIf sectionIndex == 10
        return "Neglect: " + GetNeglectSummary()
    elseIf sectionIndex == 11
        return "Hircine: " + GetHircineSummary()
    elseIf sectionIndex == 12
        return "Curse: " + GetCurseStateSummary()
    elseIf sectionIndex == 13
        return "Curse handlers: " + GetCurseHandlerSummary()
    endIf

    return ""
EndFunction

; Total number of pattern-summary sections (for MCM pagination bounds).
Int Function DebugGetPatternSummarySectionCount()
    return 14
EndFunction

; Maps an origin race to its dedicated pattern-summary section index, or -1 when
; the race has no race-specific section (Nord/Imperial/Breton live in the globals).
Int Function DebugGetPatternSummaryRaceSection(Int originRace)
    if originRace == ORIGIN_BOSMER
        return 1
    elseIf originRace == ORIGIN_DUNMER
        return 2
    elseIf originRace == ORIGIN_KHAJIIT
        return 3
    elseIf originRace == ORIGIN_ARGONIAN
        return 4
    elseIf originRace == ORIGIN_ALTMER
        return 5
    elseIf originRace == ORIGIN_ORC
        return 6
    elseIf originRace == ORIGIN_REDGUARD
        return 7
    endIf

    return -1
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

; Real Skyrim moon phase: the engine renders an 8-phase, 24-day cycle driven by
; GameDaysPassed % 24, advancing the visible phase at midday. We replicate the
; Creation Kit GetCurrentMoonphase boundaries exactly so this index matches the
; moon the player actually sees (full moon on the wrap, new moon mid-cycle), then
; map it to a 1-8 index for the Lattice. gameDay comes from GetCurrentGameTime
; (game days, fractional); +0.5 rounds to the nearest day = the midday rollover.
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

    ; --- Phase 2 all-race roster (Group 1: existing JS glyphs) ---
    if deity.DeityName == "Azura" || deity.DeityName == "Azurah"
        return "azura"
    endIf
    if deity.DeityName == "Malacath"
        return "malacath"
    endIf
    if deity.DeityName == "The Hist"
        return "hist"
    endIf

    ; --- Phase 2 all-race roster (Group 2: glyphs land via prisma-glyphs-phase2-deities) ---
    if deity.DeityName == "Shor"
        return "shor"
    endIf
    if deity.DeityName == "Tsun"
        return "tsun"
    endIf
    if deity.DeityName == "Stuhn"
        return "stuhn"
    endIf
    if deity.DeityName == "Kynareth"
        return "kynareth"
    endIf
    if deity.DeityName == "Magnus"
        return "magnus"
    endIf
    if deity.DeityName == "Xarxes"
        return "xarxes"
    endIf
    if deity.DeityName == "Trinimac"
        return "trinimac"
    endIf
    if deity.DeityName == "Khenarthi"
        return "khenarthi"
    endIf
    if deity.DeityName == "Rajhin"
        return "rajhin"
    endIf
    if deity.DeityName == "Alkosh"
        return "alkosh"
    endIf
    if deity.DeityName == "Sithis"
        return "sithis"
    endIf
    if deity.DeityName == "Tu'whacca"
        return "tuwhacca"
    endIf
    if deity.DeityName == "HoonDing"
        return "hoonding"
    endIf
    if deity.DeityName == "Leki"
        return "leki"
    endIf
    if deity.DeityName == "Boethiah"
        return "boethiah"
    endIf
    if deity.DeityName == "Mephala"
        return "mephala"
    endIf
    if deity.DeityName == "Hircine"
        return "hircine"
    endIf
    if deity.DeityName == "Azura"
        return "azura"
    endIf
    if deity.DeityName == "Molag Bal" || deity.DeityName == "Molag"
        return "molag-bal"
    endIf
    if deity.DeityName == "Mehrunes Dagon" || deity.DeityName == "Dagon"
        return "mehrunes-dagon"
    endIf
    if deity.DeityName == "Sheogorath" || deity.DeityName == "Sheo"
        return "sheogorath"
    endIf
    if deity.DeityName == "Clavicus Vile" || deity.DeityName == "Vile"
        return "clavicus-vile"
    endIf
    if deity.DeityName == "Hermaeus Mora" || deity.DeityName == "Mora"
        return "hermaeus-mora"
    endIf
    if deity.DeityName == "Meridia"
        return "meridia"
    endIf
    if deity.DeityName == "Vaermina"
        return "vaermina"
    endIf
    if deity.DeityName == "Namira"
        return "namira"
    endIf
    if deity.DeityName == "Sanguine"
        return "sanguine"
    endIf
    if deity.DeityName == "Nocturnal"
        return "nocturnal"
    endIf
    if deity.DeityName == "Peryite"
        return "peryite"
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



