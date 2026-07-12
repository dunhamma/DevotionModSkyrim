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
PDV_ModePreset Property PDV_ModePresetRef Auto

FormList Property PDV_FLST_AllDeities Auto
FormList Property PDV_FLST_DaedricPaths_All Auto
FormList Property PDV_FLST_HoonDing_BreakthroughBosses Auto
FormList Property PDV_FLST_RedguardAshAbahUndeadClearSites Auto
FormList Property PDV_FLST_UndeadCryptClearSites Auto
Faction Property NecromancerFaction Auto
Faction Property WarlockFaction Auto
String Property QUEST_REACTION_MATRIX_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix" AutoReadOnly
; List-patch second channel (e.g. Authoria/ARR). Cells are read from whichever
; channel owns the (form|stage) key; shared stance/value tables stay on core.
String Property QUEST_REACTION_MATRIX_FILE_ARR = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR" AutoReadOnly

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
PDV_DeityBase Property PDV_Syrabane Auto
PDV_ReputationTrack Property PDV_ConcordatStandingTrack Auto
PDV_Substrate_ImperialAncestor Property PDV_ImperialAncestorSubstrate Auto
PDV_Substrate_BretonAncestor Property PDV_BretonAncestorSubstrate Auto
PDV_ReputationTrack Property PDV_ThalmorAlignmentTrack Auto
PDV_StateTrack Property PDV_BosmerPathTrack Auto
PDV_StateTrack Property PDV_NordPantheonBaselineTrack Auto
PDV_StateTrack Property PDV_AltmerCrisisTrack Auto
PDV_Substrate_AltmerAncestor Property PDV_AltmerAncestorSubstrate Auto
PDV_Substrate_NordAncestor Property PDV_NordAncestorSubstrate Auto
PDV_Substrate_DunmerAncestor Property PDV_DunmerAncestorSubstrate Auto
Book Property PDV_BOOK_DunmerAncestralUrn Auto
MiscObject Property PDV_MISC_DunmerAncestralUrn Auto
Spell Property PDV_SPEL_Dunmer_AncestorWatch Auto
Message Property PDV_MESG_DunmerMarkHome Auto
PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto
PDV_Substrate_ArgonianHist Property PDV_ArgonianHistSubstrate Auto
Book Property PDV_BOOK_ArgonianHistSapToken Auto
Potion Property PDV_ALCH_ArgonianHistSap Auto
PDV_StateTrack Property PDV_ArgonianHistPostureTrack Auto
PDV_StateTrack Property PDV_OrcLifeModeTrack Auto
PDV_StateTrack Property PDV_RedguardSectTrack Auto
PDV_StateTrack Property PDV_KhajiitLunarPostureTrack Auto
PDV_DaedricPath_Hircine Property PDV_HircinePath Auto
PDV_CurseState Property PDV_CurseStateService Auto
Spell Property PDV_SPEL_SurveyDevotion Auto
Spell Property PDV_SPEL_Neglect_Kyne Auto
; Per-patron Nord neglect (follow-on): one gentle flat neglect spell per focusable non-Kyne Nord
; patron. None until the ESP batch authors them; SyncNordPatronNeglectSpells no-ops until then.
Spell Property PDV_SPEL_Neglect_Shor Auto
Spell Property PDV_SPEL_Neglect_Tsun Auto
Spell Property PDV_SPEL_Neglect_Stuhn Auto
Spell Property PDV_SPEL_Neglect_Talos Auto
; Nord Old Ways patrons added after the per-patron batch (Orkey/Dibella roster). Arkay's neglect
; surfaces as "Orkey" in Old Ways context; the property/record key stays Arkay.
Spell Property PDV_SPEL_Neglect_Arkay Auto
Spell Property PDV_SPEL_Neglect_Dibella Auto
Spell Property PDV_SPEL_Disfavor_SkyStormHunt_Light Auto
Spell Property PDV_SPEL_Disfavor_SkyStormHunt_Sharp Auto
Spell Property PDV_SPEL_Disfavor_DeathAncestors_Light Auto
Spell Property PDV_SPEL_Disfavor_DeathAncestors_Sharp Auto
Spell Property PDV_SPEL_Disfavor_MercyProtection_Light Auto
Spell Property PDV_SPEL_Disfavor_MercyProtection_Sharp Auto
Spell Property PDV_SPEL_Disfavor_WarHonor_Light Auto
Spell Property PDV_SPEL_Disfavor_WarHonor_Sharp Auto
Spell Property PDV_SPEL_Disfavor_OrderTradeLore_Light Auto
Spell Property PDV_SPEL_Disfavor_OrderTradeLore_Sharp Auto
Spell Property PDV_SPEL_Disfavor_MoonLuckShadow_Light Auto
Spell Property PDV_SPEL_Disfavor_MoonLuckShadow_Sharp Auto
Spell Property PDV_SPEL_Disfavor_VoidSecrets_Light Auto
Spell Property PDV_SPEL_Disfavor_VoidSecrets_Sharp Auto
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
Spell Property PDV_Bless_Altmer_Trinimac_T1 Auto
Spell Property PDV_Bless_Altmer_Trinimac_T2 Auto
Spell Property PDV_Bless_Altmer_Trinimac_T3 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T1 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T2 Auto
Spell Property PDV_Bless_Altmer_Xarxes_T3 Auto
Spell Property PDV_Bless_Altmer_Syrabane_T1 Auto
Spell Property PDV_Bless_Altmer_Syrabane_T2 Auto
Spell Property PDV_Bless_Altmer_Syrabane_T3 Auto
Spell Property PDV_Bless_Altmer_Spine_Always Auto
Spell Property PDV_Bless_Altmer_Spine_Mid Auto
Spell Property PDV_Bless_Altmer_Spine_High Auto
Spell Property PDV_SPEL_AltmerDiscipline_Alteration Auto
Spell Property PDV_SPEL_AltmerDiscipline_Destruction Auto
Spell Property PDV_SPEL_AltmerDiscipline_Illusion Auto
Spell Property PDV_SPEL_AltmerDiscipline_Restoration Auto
Message Property PDV_MESG_AltmerDisciplines Auto
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
Spell Property PDV_Bless_Orc_Spine_City Auto
Spell Property PDV_Bless_Orc_Spine_Stronghold Auto
Spell Property PDV_Bless_Orc_Spine_LegionExile Auto
Spell Property PDV_SPEL_Neglect_Orc Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Tusk Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Shield Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Hammer Auto
Spell Property PDV_SPEL_Orc_TrialOfIron_Yoke Auto
Message Property PDV_MESG_Orc_TrialOfIron Auto
Spell Property PDV_SPEL_OrcCodeHolds Auto
Spell Property PDV_SPEL_OrcCodeHolds_Devoted Auto
Spell Property PDV_SPEL_OrcHearthHeld Auto
Spell Property PDV_Bless_Redguard_AncestorSpine_T1 Auto
Spell Property PDV_Bless_Redguard_AncestorSpine_T2 Auto
Spell Property PDV_Bless_Redguard_Spine_Crown Auto
Spell Property PDV_Bless_Redguard_Spine_Forebear Auto
Spell Property PDV_SPEL_RedguardRemember_Blade Auto
Spell Property PDV_SPEL_RedguardRemember_Road Auto
Spell Property PDV_SPEL_RedguardRemember_Rest Auto
Spell Property PDV_SPEL_RedguardRemember_Harvest Auto
Message Property PDV_MSG_RedguardRemembering Auto
Spell Property PDV_Bless_Redguard_Spine_AshAbah Auto
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
Message Property PDV_MSG_StartupNordChoice Auto
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
Message Property PDV_MSG_Confirm_Nord_OldWays Auto
Message Property PDV_MSG_Confirm_Nord_NineDivines Auto
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
Message Property PDV_Notif_Redguard_AncestorSpine_Rest Auto
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
Message Property PDV_Msg_Nord_Orkey_Offer Auto
Message Property PDV_Msg_Nord_Stendarr_Offer Auto
Message Property PDV_Msg_Nord_Zenithar_Offer Auto
Message Property PDV_Msg_Nord_Julianos_Offer Auto
Message Property PDV_Msg_Nord_Dibella_Offer Auto
Message Property PDV_Msg_Nord_Talos_Offer Auto
Message Property PDV_Msg_Nord_Kynareth_Offer Auto
Message Property PDV_Msg_Nord_OfferResponse_Accept Auto
Message Property PDV_Msg_Nord_OfferResponse_NotYet Auto
Message Property PDV_Msg_Nord_OfferResponse_Refuse Auto
Message Property PDV_Msg_Dunmer_Azura_Offer Auto
Message Property PDV_Msg_Dunmer_Boethiah_Offer Auto
Message Property PDV_Msg_Dunmer_Mephala_Offer Auto
Message Property PDV_Msg_Dunmer_OfferResponse_Accept Auto
Message Property PDV_Msg_Dunmer_OfferResponse_NotYet Auto
Message Property PDV_Msg_Dunmer_OfferResponse_Refuse Auto
Message Property PDV_Msg_Altmer_AuriEl_Offer Auto
Message Property PDV_Msg_Altmer_Magnus_Offer Auto
Message Property PDV_Msg_Altmer_Xarxes_Offer Auto
Message Property PDV_Msg_Altmer_Trinimac_Offer Auto
Message Property PDV_Msg_Altmer_Syrabane_Offer Auto
Message Property PDV_Msg_Altmer_OfferResponse_Accept Auto
Message Property PDV_Msg_Altmer_OfferResponse_NotYet Auto
Message Property PDV_Msg_Altmer_OfferResponse_Refuse Auto
Message Property PDV_Msg_Breton_Akatosh_Offer Auto
Message Property PDV_Msg_Breton_Arkay_Offer Auto
Message Property PDV_Msg_Breton_Dibella_Offer Auto
Message Property PDV_Msg_Breton_Julianos_Offer Auto
Message Property PDV_Msg_Breton_Kynareth_Offer Auto
Message Property PDV_Msg_Breton_Magnus_Offer Auto
Message Property PDV_Msg_Breton_Mara_Offer Auto
Message Property PDV_Msg_Breton_Stendarr_Offer Auto
Message Property PDV_Msg_Breton_Yffre_Offer Auto
Message Property PDV_Msg_Breton_Zenithar_Offer Auto
Message Property PDV_Msg_Breton_OfferResponse_Accept Auto
Message Property PDV_Msg_Breton_OfferResponse_NotYet Auto
Message Property PDV_Msg_Breton_OfferResponse_Refuse Auto
Message Property PDV_Msg_Imperial_Akatosh_Offer Auto
Message Property PDV_Msg_Imperial_Talos_Offer Auto
Message Property PDV_Msg_Imperial_Kynareth_Offer Auto
Message Property PDV_Msg_Imperial_Mara_Offer Auto
Message Property PDV_Msg_Imperial_Zenithar_Offer Auto
Message Property PDV_Msg_Imperial_Arkay_Offer Auto
Message Property PDV_Msg_Imperial_Stendarr_Offer Auto
Message Property PDV_Msg_Imperial_Julianos_Offer Auto
Message Property PDV_Msg_Imperial_Dibella_Offer Auto
Message Property PDV_Msg_Imperial_OfferResponse_Accept Auto
Message Property PDV_Msg_Imperial_OfferResponse_NotYet Auto
Message Property PDV_Msg_Imperial_OfferResponse_Refuse Auto
Message Property PDV_Msg_Redguard_Tuwhacca_Offer Auto
Message Property PDV_Msg_Redguard_Leki_Offer Auto
Message Property PDV_Msg_Redguard_HoonDing_Offer Auto
Message Property PDV_Msg_Redguard_OfferResponse_Accept Auto
Message Property PDV_Msg_Redguard_OfferResponse_NotYet Auto
Message Property PDV_Msg_Redguard_OfferResponse_Refuse Auto
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
Int Property LIKES_DISLIKES_VERSION = 16 AutoReadOnly
Int Property PRINCE_LD_VERSION = 4 AutoReadOnly
Int Property DISFAVOR_DOMAIN_NONE = 0 AutoReadOnly
Int Property DISFAVOR_DOMAIN_SKY_STORM_HUNT = 1 AutoReadOnly
Int Property DISFAVOR_DOMAIN_DEATH_ANCESTORS = 2 AutoReadOnly
Int Property DISFAVOR_DOMAIN_MERCY_PROTECTION = 3 AutoReadOnly
Int Property DISFAVOR_DOMAIN_WAR_HONOR = 4 AutoReadOnly
Int Property DISFAVOR_DOMAIN_ORDER_TRADE_LORE = 5 AutoReadOnly
Int Property DISFAVOR_DOMAIN_MOON_LUCK_SHADOW = 6 AutoReadOnly
Int Property DISFAVOR_DOMAIN_VOID_SECRETS = 7 AutoReadOnly
Float Property DISFAVOR_LIGHT_MIN_DELTA = 0.5 AutoReadOnly
Float Property DISFAVOR_SHARP_MIN_DELTA = 1.0 AutoReadOnly
Float Property DISFAVOR_LIGHT_DURATION_DAYS = 0.0833333 AutoReadOnly
Float Property DISFAVOR_SHARP_DURATION_DAYS = 0.1666667 AutoReadOnly
Int Property DISFAVOR_MAX_ACTIVE_DOMAINS = 3 AutoReadOnly
; Bump when the Daedric pact model changes so existing saves re-run the migration
; (v2: active-pact-only sync + milestone presentation refresh; v3: collapse a
; co-held patron+Prince, keep higher tier, tie -> Prince).
Int Property DAEDRIC_PACT_VERSION = 3 AutoReadOnly
Float Property TIER_DOWN_HYSTERESIS = 5.0 AutoReadOnly
Float Property ORC_RATE_MULT_STRONGHOLD = 1.0 AutoReadOnly
Float Property ORC_RATE_MULT_CITY = 0.75 AutoReadOnly
Float Property ORC_RATE_MULT_LEGIONEXILE = 0.6 AutoReadOnly
Float Property NEGLECT_ACTIVE_PIETY_MAX = 10.0 AutoReadOnly
Int Property NEGLECT_ACTIVE_CAP = 3 AutoReadOnly
; Recency-lapse grace (owner ruling 2026-06-27): neglect bites after this many days of no
; devotional act, regardless of piety -- the active patron is decay-shielded so the piety<=10
; floor almost never triggers from mere absence. Sits just past DECAY_GRACE_DAYS (2.0).
Float Property NEGLECT_LAPSE_GRACE_DAYS = 3.0 AutoReadOnly
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
Bool _suppressAwardFavorToast = False
Bool _suppressCurseTransitionOutputs = False
; Quest-reaction surface accumulator (2026-07-05): one quest fire = one toast +
; one Book of Days beat, no matter how many deities its cells fan to. Reset at
; the top of ApplyQuestReaction, filled per landed base cell, flushed after the
; cell loop. Two interleaved quest fires could merge into one beat; harmless.
String _qrSurfPosNamesCsv = ""
String _qrSurfNegNamesCsv = ""
Int _qrSurfPosCount = 0
Int _qrSurfNegCount = 0
Float _qrSurfBestPosAmount = 0.0
Float _qrSurfBestNegAmount = 0.0
String _qrSurfBestPosName = ""
String _qrSurfBestNegName = ""
String _qrSurfBestPosSymbol = ""
String _qrSurfBestNegSymbol = ""
Bool _qrSurfMilestone = False
; Likes/dislikes smoke surface accumulator (2026-07-11): event 303 and 366
; should score through the generic action router but still leave one visible
; toast + Book of Days beat for the whole fan-out.
Int _ldSurfEventType = -1
String _ldSurfPosNamesCsv = ""
String _ldSurfNegNamesCsv = ""
Int _ldSurfPosCount = 0
Int _ldSurfNegCount = 0
Float _ldSurfBestPosAmount = 0.0
Float _ldSurfBestNegAmount = 0.0
String _ldSurfBestPosName = ""
String _ldSurfBestNegName = ""
String _ldSurfBestPosSymbol = ""
String _ldSurfBestNegSymbol = ""
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
Int _pendingLikesDislikesEventType = -1

Event OnInit()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    EnsureAkatoshRuntimeIdentity()
    EnsureCanonicalDeityDisplayNames()
    RepairBookOfDaysJournalText()
    EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
    RegisterManagerShoutSignals()
    EnsureLikesDislikesTable()
    EnsurePrinceLikesDislikesTable()
    MigrateDaedricPactsIfNeeded()
    RefreshPatronMirrors()
    UpdateContextualFavorRuntime()
    UpdateDisfavorStingRuntime()
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
    UpdateDisfavorStingRuntime()
    if !_diegeticLoadHandled
        HandleDiegeticLoad("update")
    endIf
    ProcessQueuedDaedricMilestonePresentation()
    ProcessPendingDaedricActivation()
    ProcessPendingDaedricLapse()
    ProcessPendingDaedricPrePactNotices()
    DrainHircineRenunciationJournal()
    ProcessDelayedHircineResiduePrismaToasts()
    ProcessQueuedPrismaToastRetry()

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
        EnsureAkatoshRuntimeIdentity()
        EnsureCanonicalDeityDisplayNames()
        RepairBookOfDaysJournalText()
        EnsureBosmerRuntimeWiring()
        EnsureNordRuntimeWiring()
        EnsureSurveyDevotionPower()
        EnsureDunmerAncestralUrn()
        EnsureArgonianHistSapToken()
        InitCCContent()
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
    TryBosmerYffreTreeStoneProximity()
    TryCCSaintsRecognition()
    TryCCFishingDevotion()

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

Function EnsureAkatoshRuntimeIdentity()
    if !PDV_Akatosh
        return
    endIf

    Bool repaired = False

    if PDV_Akatosh.DeityName != "Akatosh"
        PDV_Akatosh.DeityName = "Akatosh"
        repaired = True
    endIf

    if PDV_Akatosh.PDV_GLO_DebugLevel != PDV_GLO_DebugLevel
        PDV_Akatosh.PDV_GLO_DebugLevel = PDV_GLO_DebugLevel
        repaired = True
    endIf

    if PDV_Akatosh.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        PDV_Akatosh.PDV_GLO_OriginRace = PDV_GLO_OriginRace
        repaired = True
    endIf

    if repaired && GetDebugLevel() >= 1
        Debug.Trace("[PDV] Akatosh runtime identity repaired.")
    endIf
EndFunction

Function EnsureCanonicalDeityDisplayNames()
    Int repaired = 0
    repaired += RepairDeityRuntimeName(PDV_Kyne, "Kyne")
    repaired += RepairDeityRuntimeName(PDV_Talos, "Talos")
    repaired += RepairDeityRuntimeName(PDV_Yffre, "Y'ffre")
    repaired += RepairDeityRuntimeName(PDV_Zen, "Z'en")
    repaired += RepairDeityRuntimeName(PDV_BaanDar, "Baan Dar")
    repaired += RepairDeityRuntimeName(PDV_Azura, "Azura")
    repaired += RepairDeityRuntimeName(PDV_Khenarthi, "Khenarthi")
    repaired += RepairDeityRuntimeName(PDV_Rajhin, "Rajhin")
    repaired += RepairDeityRuntimeName(PDV_Alkosh, "Alkosh")
    repaired += RepairDeityRuntimeName(PDV_Boethiah, "Boethiah")
    repaired += RepairDeityRuntimeName(PDV_Mephala, "Mephala")
    repaired += RepairDeityRuntimeName(PDV_Hist, "The Hist")
    repaired += RepairDeityRuntimeName(PDV_Sithis, "Sithis")
    repaired += RepairDeityRuntimeName(PDV_Malacath, "Malacath")
    repaired += RepairDeityRuntimeName(PDV_Trinimac, "Trinimac")
    repaired += RepairDeityRuntimeName(PDV_Tuwhacca, "Tu'whacca")
    repaired += RepairDeityRuntimeName(PDV_HoonDing, "HoonDing")
    repaired += RepairDeityRuntimeName(PDV_Leki, "Leki")
    repaired += RepairDeityRuntimeName(PDV_Shor, "Shor")
    repaired += RepairDeityRuntimeName(PDV_Tsun, "Tsun")
    repaired += RepairDeityRuntimeName(PDV_Stuhn, "Stuhn")
    repaired += RepairDeityRuntimeName(PDV_Akatosh, "Akatosh")
    repaired += RepairDeityRuntimeName(PDV_Mara, "Mara")
    repaired += RepairDeityRuntimeName(PDV_Arkay, "Arkay")
    repaired += RepairDeityRuntimeName(PDV_Stendarr, "Stendarr")
    repaired += RepairDeityRuntimeName(PDV_Zenithar, "Zenithar")
    repaired += RepairDeityRuntimeName(PDV_Dibella, "Dibella")
    repaired += RepairDeityRuntimeName(PDV_Julianos, "Julianos")
    repaired += RepairDeityRuntimeName(PDV_Kynareth, "Kynareth")
    repaired += RepairDeityRuntimeName(PDV_AuriEl, "Auri-El")
    repaired += RepairDeityRuntimeName(PDV_Magnus, "Magnus")
    repaired += RepairDeityRuntimeName(PDV_Xarxes, "Xarxes")
    repaired += RepairDeityRuntimeName(PDV_Syrabane, "Syrabane")
    repaired += RepairDaedricPathRuntimeNames()
    if repaired > 0 && GetDebugLevel() >= 1
        Debug.Trace("[PDV] Canonical deity display names repaired: " + repaired)
    endIf
EndFunction

Int Function RepairDeityRuntimeName(PDV_DeityBase deity, String canonicalName)
    if !deity || deity.DeityName == canonicalName
        return 0
    endIf
    deity.DeityName = canonicalName
    return 1
EndFunction

Int Function RepairDaedricPathRuntimeNames()
    if !PDV_FLST_DaedricPaths_All
        return 0
    endIf
    Int repaired = 0
    Int pathCount = PDV_FLST_DaedricPaths_All.GetSize()
    Int pathIndex = 0
    while pathIndex < pathCount
        PDV_DaedricPathBase namedPath = PDV_FLST_DaedricPaths_All.GetAt(pathIndex) as PDV_DaedricPathBase
        if namedPath
            String canonicalPathName = CanonicalDaedricPathName(namedPath)
            if canonicalPathName != ""
                repaired += RepairDeityRuntimeName(namedPath, canonicalPathName)
            endIf
        endIf
        pathIndex += 1
    endWhile
    return repaired
EndFunction

; Path identity via concrete-script downcast: immune to DeityName drift (the thing
; being repaired) and to FormList order drift. Canonical strings mirror
; PDV_DaedricPrinceRecordContracts.json displayName values exactly.
String Function CanonicalDaedricPathName(PDV_DaedricPathBase namedPath)
    if namedPath as PDV_DaedricPath_Azura
        return "Azura"
    elseIf namedPath as PDV_DaedricPath_Boethiah
        return "Boethiah"
    elseIf namedPath as PDV_DaedricPath_Dagon
        return "Mehrunes Dagon"
    elseIf namedPath as PDV_DaedricPath_Hircine
        return "Hircine"
    elseIf namedPath as PDV_DaedricPath_Malacath
        return "Malacath"
    elseIf namedPath as PDV_DaedricPath_Mephala
        return "Mephala"
    elseIf namedPath as PDV_DaedricPath_Meridia
        return "Meridia"
    elseIf namedPath as PDV_DaedricPath_Molag
        return "Molag Bal"
    elseIf namedPath as PDV_DaedricPath_Mora
        return "Hermaeus Mora"
    elseIf namedPath as PDV_DaedricPath_Namira
        return "Namira"
    elseIf namedPath as PDV_DaedricPath_Nocturnal
        return "Nocturnal"
    elseIf namedPath as PDV_DaedricPath_Peryite
        return "Peryite"
    elseIf namedPath as PDV_DaedricPath_Sanguine
        return "Sanguine"
    elseIf namedPath as PDV_DaedricPath_Sheo
        return "Sheogorath"
    elseIf namedPath as PDV_DaedricPath_Vaermina
        return "Vaermina"
    elseIf namedPath as PDV_DaedricPath_Vile
        return "Clavicus Vile"
    endIf
    return ""
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
    EnsureNordOrkeyRewardRuntimeWiring()

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

    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", PDV_NordPantheonBaselineTrack.GetCurrentState())
EndFunction

Function EnsureNordOrkeyRewardRuntimeWiring()
    Bool repaired = False

    if !PDV_Bless_Nord_Arkay_T1
        PDV_Bless_Nord_Arkay_T1 = Game.GetFormFromFile(0x071660, "Devotion.esp") as Spell
        if PDV_Bless_Nord_Arkay_T1
            repaired = True
        endIf
    endIf

    if !PDV_Bless_Nord_Arkay_T2
        PDV_Bless_Nord_Arkay_T2 = Game.GetFormFromFile(0x071663, "Devotion.esp") as Spell
        if PDV_Bless_Nord_Arkay_T2
            repaired = True
        endIf
    endIf

    if !PDV_Bless_Nord_Arkay_T3
        PDV_Bless_Nord_Arkay_T3 = Game.GetFormFromFile(0x071666, "Devotion.esp") as Spell
        if PDV_Bless_Nord_Arkay_T3
            repaired = True
        endIf
    endIf

    if repaired
        Trace(1, "Nord Orkey reward runtime wiring repaired.")
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

Function AwardPiety(PDV_DeityBase deity, Float amount, String reason = "")
    AwardPietyInternal(deity, amount, True, reason)
EndFunction

Function AwardPietyFromLikesDislikes(PDV_DeityBase deity, Float amount, Int eventType, String reason = "")
    Bool ownsSurface = False
    if ShouldSurfaceLikesDislikesEvent(eventType) && _ldSurfEventType != eventType
        BeginLikesDislikesSurface(eventType)
        ownsSurface = True
    endIf

    Int previousEventType = _pendingLikesDislikesEventType
    _pendingLikesDislikesEventType = eventType
    AwardPietyInternal(deity, amount, True, reason)
    _pendingLikesDislikesEventType = previousEventType
    AccumulateLikesDislikesSurface(deity, amount, eventType)

    if ownsSurface
        FlushLikesDislikesSurface(eventType)
    endIf
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

    Int runtimeFormId = sourceQuest.GetFormID()
    Int matrixFormId = StorageUtil.GetIntValue(None, "PDV.QuestReaction.LocalFormId." + runtimeFormId, runtimeFormId)
    String reactionKey = matrixFormId + "|" + stageValue
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

    ResetQuestReactionSurface()
    Int i = 0
    while i < cellCount
        if i < valences.Length && i < intensities.Length && i < magnitudes.Length && i < sourceTags.Length
            ApplyDeityReaction(deityNames[i], valences[i], intensities[i], magnitudes[i], sourceTags[i], False, sourceQuest as Form)
        endIf
        i += 1
    endWhile
    FlushQuestReactionSurface()

    StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastKey", reactionKey)
    StorageUtil.SetIntValue(None, "PDV.QuestReaction.LastCellCount", cellCount)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] QuestReaction: " + reactionKey + " applied " + cellCount + " cells.")
    endIf

    EvaluateQuestMetaFaucets(sourceQuest, reactionKey, cellPrefix, matrixFile)
EndFunction

Function EvaluateQuestMetaFaucets(Quest sourceQuest, String reactionKey, String cellPrefix, String matrixFile)
    ; Quest-meta-faucets (PDV_QuestExpansion_Architecture.md, 2026-07-05): one-shot per-quest
    ; lanes for thin-coverage deities, evaluated ONLY on watched-quest cell fires so the
    ; game-wide unwatched stage spam never reaches this. Class and metaSkip flags are
    ; compile-time INTEGER keys in the matrix JSON (no runtime string parsing); metaSkip
    ; encodes the yield rule (a deity holding a matrix cell anywhere on this quest never
    ; double-credits through a meta lane). The per-quest once-guard makes every lane finite
    ; by construction; values live at value.meta.* in the core JSON (0 = lane off).
    String[] keyParts = StringUtil.Split(reactionKey, "|")
    if keyParts.Length < 1
        return
    endIf
    String doneKey = "PDV.Meta.Done." + keyParts[0]
    if StorageUtil.GetIntValue(None, doneKey) == 1
        return
    endIf
    StorageUtil.SetIntValue(None, doneKey, 1)

    Form questForm = sourceQuest as Form
    Float nowTime = Utility.GetCurrentGameTime()
    Float hourOfDay = (nowTime - ((nowTime as Int) as Float)) * 24.0

    ; Z'en -- the wage taken (gold-rewarded quests only; compile-time class flag)
    Bool goldQuest = JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.gold") == 1
    if goldQuest && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Z'en") != 1
        ApplyDeityReaction("Z'en", "+", "zen", "meta", "meta_zen_wage", False, questForm)
    endIf

    ; Julianos -- wisdom served (mage-aid quests)
    Bool mageAidQuest = JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid") == 1
    if mageAidQuest && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Julianos") != 1
        ApplyDeityReaction("Julianos", "+", "julianos", "meta", "meta_julianos_wisdom", False, questForm)
    endIf

    ; Azura -- mage-aid quest OR sealed at the twilight threshold (dawn/dusk windows)
    Bool twilightWindow = (hourOfDay >= 5.0 && hourOfDay < 7.0) || (hourOfDay >= 17.0 && hourOfDay < 19.0)
    if (mageAidQuest || twilightWindow) && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Azura") != 1
        ApplyDeityReaction("Azura", "+", "azura", "meta", "meta_azura_threshold", False, questForm)
    endIf

    ; Nocturnal -- theft since the previous fulfillment (tier 1), else done in her dark (tier 2)
    if JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Nocturnal") != 1
        Float lastTheft = StorageUtil.GetFloatValue(None, "PDV.Meta.LastTheftTime")
        Float lastFulfill = StorageUtil.GetFloatValue(None, "PDV.Meta.LastFulfillTime")
        if lastTheft > 0.0 && lastTheft > lastFulfill
            ApplyDeityReaction("Nocturnal", "+", "nocturnalTheft", "meta", "meta_nocturnal_herway", False, questForm)
        elseIf hourOfDay >= 20.0 || hourOfDay < 6.0
            ApplyDeityReaction("Nocturnal", "+", "nocturnalNight", "meta", "meta_nocturnal_dark", False, questForm)
        endIf
    endIf

    ; Khenarthi -- the road honored (fulfilled outdoors under the sky)
    Actor metaPlayer = Game.GetPlayer()
    if metaPlayer && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Khenarthi") != 1
        Cell parentCell = metaPlayer.GetParentCell()
        if parentCell && !parentCell.IsInterior()
            ApplyDeityReaction("Khenarthi", "+", "khenarthi", "meta", "meta_khenarthi_road", False, questForm)
        endIf
    endIf

    ; Akatosh + Xarxes -- the wheel turns / the record kept (ONE shared lifetime counter)
    Int wheelCount = StorageUtil.AdjustIntValue(None, "PDV.Meta.QuestCount", 1)
    if wheelCount > 0 && wheelCount % 10 == 0
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Akatosh") != 1
            ApplyDeityReaction("Akatosh", "+", "wheel", "meta", "meta_akatosh_wheel", False, questForm)
        endIf
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Xarxes") != 1
            ApplyDeityReaction("Xarxes", "+", "wheel", "meta", "meta_xarxes_record", False, questForm)
        endIf
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Meta.LastFulfillTime", nowTime)
    Trace(2, "Quest meta-faucets evaluated (" + reactionKey + ")")
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

    ; Namira lifesteal: feeding on the dead restores the Namira-pathed faithful. The
    ; old boon's HealRateMult (rate on Requiem's ~0 base) was swallowed; the sustain
    ; is now this event-driven, Requiem-proof heal-on-feed. Tier-gated + daily decay.
    if faucetKey == "Namira.cannibalism"
        TryNamiraFeedHeal()
    endIf
EndFunction

; Namira lifesteal heal-on-feed. The Namira boon's "Namira sustains you" fantasy was
; authored as a swallowed always-on HealRateMult (felt as nothing under Requiem). It
; is re-themed to a flat, Requiem-proof restore fired when the Namira-pathed faithful
; feeds on the dead, scaled by Namira tier, with a daily soft-decay so repeated
; feeding in one day yields diminishing restoration (anti-farm). Magnitudes
; PROVISIONAL -- tune in-game (memory: requiem-proof-heal-flat-restore-not-rate).
Function TryNamiraFeedHeal()
    PDV_DeityBase namira = GetQuestReactionDeity("Namira")
    if !namira
        return
    endIf

    Int namiraTier = GetTier(namira)
    if namiraTier < TIER_SEEKER
        return
    endIf

    Float feedMultiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.NamiraFeedHeal")
    if feedMultiplier <= 0.0
        Trace(2, "Namira feed-heal decayed out for today; no restore.")
        return
    endIf

    Float feedHeal = 20.0
    if namiraTier >= TIER_CHAMPION
        feedHeal = 40.0
    elseIf namiraTier >= TIER_DEVOTED
        feedHeal = 30.0
    endIf
    feedHeal = feedHeal * feedMultiplier
    Float feedStamina = feedHeal
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", feedHeal)
    playerRef.RestoreActorValue("Stamina", feedStamina)
    Trace(2, "Namira feed-heal fired tier=" + namiraTier + " mult=" + feedMultiplier + " health=" + feedHeal + " stamina=" + feedStamina)
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
        if !IsQuestReactionDeityReachable(deity)
            if GetDebugLevel() >= 2
                Debug.Trace("[PDV] QuestReaction skipped unreachable taboo/hostile deity: " + deityName + " " + sourceTag)
            endIf
            return
        endIf

        if amount > 0.0
            ApplyQuestReactionStigma(deity, amount, sourceTag)
            ; A taboo deity reaction is a real negative piety award (paths take
            ; stigma instead, which is not piety) -- fold it into the quest-fire
            ; surface as displeasure so the loss is not invisible.
            if !isFaucet && magnitude != "meta" && !(deity as PDV_DaedricPathBase)
                AccumulateQuestReactionSurface(deity, amount * -1.0, magnitude)
            endIf
        else
            ApplyQuestReactionPiety(deity, amount, "taboo_" + sourceTag)
            if !isFaucet && magnitude != "meta"
                AccumulateQuestReactionSurface(deity, amount, magnitude)
            endIf
        endIf
        return
    endIf

    ; Reachability gate (2026-07-05): a FOREIGN/TOLERATED quest reaction for a god
    ; outside the player's origin roster (and not a Daedric path) writes piety no
    ; surface can ever read back -- the dashboard filters by
    ; IsDashboardDeityInOriginRoster and the formal commitment offer path is
    ; origin-gated, so the piety, driver ring, and signal-day writes are dead state.
    ; Skip the award entirely; generic acts (ScoreFromTable), the dashboard, and
    ; offers already hard-gate the same way. Daedric paths stay scored: a pre-pact
    ; path with piety renders as "watching", so path piety has a live consumer.
    ; Roster deities with a TOLERATED/FOREIGN stance (visible-but-foreign) keep
    ; their reduced-rate award below.
    if stance == "FOREIGN" || stance == "TOLERATED"
        if !IsQuestReactionDeityReachable(deity)
            if GetDebugLevel() >= 2
                Debug.Trace("[PDV] QuestReaction skipped unreachable foreign deity: " + deityName + " " + sourceTag)
            endIf
            return
        endIf
    endIf

    Float multiplier = 1.0
    if stance == "FOREIGN"
        multiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.FOREIGN", 0.4)
    elseIf stance == "TOLERATED"
        multiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.TOLERATED", 0.4)
    endIf

    Float appliedReactionAmount = amount * multiplier
    ; Milestone surfacing (below) owns the top-left toast for a landed base-cell
    ; reaction, so mute AwardPiety's generic active-patron favor pulse across the
    ; award to avoid a double toast. The panel driver ring is still fed inside
    ; AwardPiety regardless.
    _suppressAwardFavorToast = True
    ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    _suppressAwardFavorToast = False

    ; Milestone surfacing (2026-07-05): a base quest-reaction cell is a milestone-grade
    ; beat, so a landed reaction feeds the per-quest surface accumulator; the quest
    ; fire flushes ONE toast + ONE Book of Days beat for all its cells (owner ruling
    ; after the first per-cell build toasted 6 gods per assassination stage). Excluded,
    ; by design, from that loud surface:
    ;   - behavioral faucets (isFaucet): cannibalism / forbidden-knowledge signals, not
    ;     quests; they keep their daily/once caps and quiet-Ledger driver row.
    ;   - meta faucets (magnitude "meta"): thin-coverage background lanes that can fire
    ;     several at once per quest; surfacing them would burst. They already carry
    ;     bespoke humanized driver-row copy.
    ; The reachability gate above already dropped off-roster gods, so only gods the
    ; player actually follows reach this surface.
    if !isFaucet && magnitude != "meta"
        AccumulateQuestReactionSurface(deity, appliedReactionAmount, magnitude)
    endIf

    ; Bridge: a positive quest reaction for a Khajiit-focus deity also tilts which
    ; moon-path leads, so the matrix's existing Baan Dar / Rajhin / Alkosh /
    ; Khenarthi / Azurah cells drive the focused-emphasis system. Piety is already
    ; awarded above; this adds focus weight only. Behavior-driven focus per the
    ; LOCKED Khajiit design sheet.
    if amount > 0.0 && IsKhajiitOrigin()
        BridgeKhajiitMatrixFocus(deityName, magnitude)
    endIf
EndFunction

; --- Quest-fire surface accumulator -------------------------------------------------
; One quest fire = one toast + one Book of Days beat, however many deities its cells
; fan to (an assassination cell lands 6+ gods; per-cell toasts proved spammy). The
; panel driver ring keeps the per-god detail via AwardPiety. The toast names the
; strongest reactor ("Mephala and 3 others mark your deed."); the Book of Days line
; lists every landed god so the chronicle stays complete. A milestone-magnitude cell
; weighs the Book entry one step heavier so it can headline.

Function ResetQuestReactionSurface()
    _qrSurfPosNamesCsv = ""
    _qrSurfNegNamesCsv = ""
    _qrSurfPosCount = 0
    _qrSurfNegCount = 0
    _qrSurfBestPosAmount = 0.0
    _qrSurfBestNegAmount = 0.0
    _qrSurfBestPosName = ""
    _qrSurfBestNegName = ""
    _qrSurfBestPosSymbol = ""
    _qrSurfBestNegSymbol = ""
    _qrSurfMilestone = False
EndFunction

Function AccumulateQuestReactionSurface(PDV_DeityBase deity, Float amount, String magnitude)
    if !deity || amount == 0.0
        return
    endIf
    String deityName = GetPublicDeityDisplayName(deity)
    if magnitude == "milestone"
        _qrSurfMilestone = True
    endIf
    if amount > 0.0
        if _qrSurfPosNamesCsv != ""
            _qrSurfPosNamesCsv = _qrSurfPosNamesCsv + "|"
        endIf
        _qrSurfPosNamesCsv = _qrSurfPosNamesCsv + deityName
        _qrSurfPosCount += 1
        if amount > _qrSurfBestPosAmount
            _qrSurfBestPosAmount = amount
            _qrSurfBestPosName = deityName
            _qrSurfBestPosSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    else
        if _qrSurfNegNamesCsv != ""
            _qrSurfNegNamesCsv = _qrSurfNegNamesCsv + "|"
        endIf
        _qrSurfNegNamesCsv = _qrSurfNegNamesCsv + deityName
        _qrSurfNegCount += 1
        if amount < _qrSurfBestNegAmount
            _qrSurfBestNegAmount = amount
            _qrSurfBestNegName = deityName
            _qrSurfBestNegSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

; "Kyne", "Kyne and Mara", "Kyne, Mara and Dibella" from a pipe-joined name list.
String Function JoinQuestSurfaceNames(String namesCsv)
    String[] names = StringUtil.Split(namesCsv, "|")
    Int count = names.Length
    if count <= 0
        return ""
    elseIf count == 1
        return names[0]
    endIf
    String joined = names[0]
    Int i = 1
    while i < count
        if i == count - 1
            joined = joined + " and " + names[i]
        else
            joined = joined + ", " + names[i]
        endIf
        i += 1
    endWhile
    return joined
EndFunction

Function FlushQuestReactionSurface()
    if _qrSurfPosCount == 0 && _qrSurfNegCount == 0
        return
    endIf

    Int nowDay = Utility.GetCurrentGameTime() as Int
    Int bodMagnitude = 1
    if _qrSurfMilestone
        bodMagnitude = 2
    endIf

    if _qrSurfNegCount == 0
        String posMsg = _qrSurfBestPosName + " marks your deed."
        if _qrSurfPosCount == 2
            posMsg = _qrSurfBestPosName + " and 1 other mark your deed."
        elseIf _qrSurfPosCount > 2
            posMsg = _qrSurfBestPosName + " and " + (_qrSurfPosCount - 1) + " others mark your deed."
        endIf
        SendPrismaToast(_qrSurfBestPosSymbol, "good", "A deed marked", posMsg)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfPosNamesCsv) + " marked your deed.", nowDay, "favor.act", _qrSurfBestPosSymbol, False, bodMagnitude, "A deed marked")
    elseIf _qrSurfPosCount == 0
        String negMsg = _qrSurfBestNegName + " takes offense at your deed."
        if _qrSurfNegCount == 2
            negMsg = _qrSurfBestNegName + " and 1 other take offense at your deed."
        elseIf _qrSurfNegCount > 2
            negMsg = _qrSurfBestNegName + " and " + (_qrSurfNegCount - 1) + " others take offense at your deed."
        endIf
        SendPrismaToast(_qrSurfBestNegSymbol, "warning", "A deed ill-received", negMsg)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfNegNamesCsv) + " took offense at your deed.", nowDay, "favor.loss", _qrSurfBestNegSymbol, False, bodMagnitude, "A deed ill-received")
    else
        ; Mixed: lead with the stronger side for tone and symbol.
        Bool positiveLeads = _qrSurfBestPosAmount >= (_qrSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _qrSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _qrSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        SendPrismaToast(mixedSymbol, mixedTone, "A deed weighed", _qrSurfBestPosName + " marks your deed; " + _qrSurfBestNegName + " takes offense.")
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfPosNamesCsv) + " marked your deed; " + JoinQuestSurfaceNames(_qrSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, bodMagnitude, "A deed weighed")
    endIf

    ResetQuestReactionSurface()
EndFunction

Bool Function ShouldSurfaceLikesDislikesEvent(Int eventType)
    return eventType == 303 || eventType == 366
EndFunction

Function ResetLikesDislikesSurface()
    _ldSurfEventType = -1
    _ldSurfPosNamesCsv = ""
    _ldSurfNegNamesCsv = ""
    _ldSurfPosCount = 0
    _ldSurfNegCount = 0
    _ldSurfBestPosAmount = 0.0
    _ldSurfBestNegAmount = 0.0
    _ldSurfBestPosName = ""
    _ldSurfBestNegName = ""
    _ldSurfBestPosSymbol = ""
    _ldSurfBestNegSymbol = ""
EndFunction

Function BeginLikesDislikesSurface(Int eventType)
    if !ShouldSurfaceLikesDislikesEvent(eventType)
        return
    endIf

    ResetLikesDislikesSurface()
    _ldSurfEventType = eventType
EndFunction

Function AccumulateLikesDislikesSurface(PDV_DeityBase deity, Float amount, Int eventType)
    if !ShouldSurfaceLikesDislikesEvent(eventType) || !deity || amount == 0.0
        return
    endIf

    if _ldSurfEventType != eventType
        BeginLikesDislikesSurface(eventType)
    endIf

    String deityName = GetPublicDeityDisplayName(deity)
    if amount > 0.0
        if _ldSurfPosNamesCsv != ""
            _ldSurfPosNamesCsv = _ldSurfPosNamesCsv + "|"
        endIf
        _ldSurfPosNamesCsv = _ldSurfPosNamesCsv + deityName
        _ldSurfPosCount += 1
        if amount > _ldSurfBestPosAmount
            _ldSurfBestPosAmount = amount
            _ldSurfBestPosName = deityName
            _ldSurfBestPosSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    else
        if _ldSurfNegNamesCsv != ""
            _ldSurfNegNamesCsv = _ldSurfNegNamesCsv + "|"
        endIf
        _ldSurfNegNamesCsv = _ldSurfNegNamesCsv + deityName
        _ldSurfNegCount += 1
        if amount < _ldSurfBestNegAmount
            _ldSurfBestNegAmount = amount
            _ldSurfBestNegName = deityName
            _ldSurfBestNegSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

Function FlushLikesDislikesSurface(Int eventType)
    if !ShouldSurfaceLikesDislikesEvent(eventType)
        return
    endIf

    if _ldSurfPosCount == 0 && _ldSurfNegCount == 0
        ResetLikesDislikesSurface()
        return
    endIf

    Int nowDay = Utility.GetCurrentGameTime() as Int
    if _ldSurfNegCount == 0
        String posMsg = _ldSurfBestPosName + " marks the act."
        if _ldSurfPosCount == 2
            posMsg = JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " mark the act."
        elseIf _ldSurfPosCount > 2
            posMsg = _ldSurfBestPosName + " and " + (_ldSurfPosCount - 1) + " others mark the act."
        endIf
        SendPrismaToast(_ldSurfBestPosSymbol, "good", "A deed noticed", posMsg)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " marked the act.", nowDay, "favor.act", _ldSurfBestPosSymbol, False, 1, "A deed noticed")
    elseIf _ldSurfPosCount == 0
        String negMsg = _ldSurfBestNegName + " takes offense at the act."
        if _ldSurfNegCount == 2
            negMsg = JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " take offense at the act."
        elseIf _ldSurfNegCount > 2
            negMsg = _ldSurfBestNegName + " and " + (_ldSurfNegCount - 1) + " others take offense at the act."
        endIf
        SendPrismaToast(_ldSurfBestNegSymbol, "warning", "A deed ill-received", negMsg)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " took offense at the act.", nowDay, "favor.loss", _ldSurfBestNegSymbol, False, 1, "A deed ill-received")
    else
        Bool positiveLeads = _ldSurfBestPosAmount >= (_ldSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _ldSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _ldSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        SendPrismaToast(mixedSymbol, mixedTone, "A deed weighed", _ldSurfBestPosName + " marks the act; " + _ldSurfBestNegName + " takes offense.")
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " marked the act; " + JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, 1, "A deed weighed")
    endIf

    Trace(1, "Likes/dislikes surface flushed: event " + eventType + ", positive " + _ldSurfPosCount + ", negative " + _ldSurfNegCount)
    ResetLikesDislikesSurface()
EndFunction

Function SurfaceDebugDislikeEvent(PDV_DeityBase deity, Float amount, Int eventType)
    if !deity || amount >= 0.0
        return
    endIf

    String deityName = GetPublicDeityDisplayName(deity)
    String symbolName = GetPrismaSymbolForDeity(deity)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    SendPrismaToast(symbolName, "warning", "A deed ill-received", deityName + " takes offense at the act.")
    AppendBookOfDaysEntry(deityName + " took offense at the act.", nowDay, "favor.loss", symbolName, False, 1, "A deed ill-received")
    Trace(1, "Debug dislike surface flushed: " + deity.DeityName + " event " + eventType)
EndFunction

Bool Function ConsumeShrinePrayerCredit(PDV_DeityBase deity, String sourceId)
    if !deity
        return False
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    String deityKey = deity.DeityName
    if deityKey == ""
        deityKey = "" + deity.GetFormID()
    endIf
    String guardKey = "PDV.Signal.ShrinePrayer." + deityKey
    if StorageUtil.GetIntValue(None, guardKey) == today
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Shrine prayer daily cap blocked " + deityKey + " from " + sourceId)
        endIf
        return False
    endIf

    StorageUtil.SetIntValue(None, guardKey, today)
    return True
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

; A quest-reaction target is "reachable" when some surface can show its piety:
; Daedric paths always (pre-pact paths render as "watching"; pacts as patron),
; deity faces only when the player's origin roster lists them. Mirrors the
; dashboard's IsDashboardDeityInOriginRoster filter so scoring and display agree.
Bool Function IsQuestReactionDeityReachable(PDV_DeityBase deity)
    if deity as PDV_DaedricPathBase
        return True
    endIf
    return IsDashboardDeityInOriginRoster(deity, GetPlayerOriginRaceIndex())
EndFunction

Function ApplyQuestReactionPiety(PDV_DeityBase deity, Float amount, String reason)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm || amount == 0.0
        return
    endIf

    AwardPiety(deity, amount, reason)
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

String Function BuildToastFallbackText(String titleText, String messageText)
    if titleText != "" && messageText != ""
        return titleText + ": " + messageText
    endIf
    if messageText != ""
        return messageText
    endIf
    return titleText
EndFunction

Function ShowToastFallbackNotification(String titleText, String messageText)
    String fallbackText = BuildToastFallbackText(titleText, messageText)
    if fallbackText != ""
        Debug.Notification(fallbackText)
    endIf
EndFunction

Bool Function SendPrismaToastPayloadOrFallback(String payload, String fallbackTitle, String fallbackMessage, Bool allowFallback = True)
    if IsRaceSetupQuietPresentationActive()
        return False
    endIf

    Bool sent = False
    if PDV_PrismaBridge.IsAvailable()
        sent = PDV_PrismaBridge.SendOverlayJson(payload)
    endIf

    if !sent && allowFallback
        ShowToastFallbackNotification(fallbackTitle, fallbackMessage)
    endIf
    return sent
EndFunction

String Function BuildPrismaEventFallbackText(String eventName, String deityName, String context, String tierLabel, String rival)
    context = NormalizePublicDeityDisplayText(context)
    deityName = NormalizePublicDeityDisplayText(deityName)
    rival = NormalizePublicDeityDisplayText(rival)
    if context != ""
        return context
    endIf
    if eventName == "tier" && deityName != "" && tierLabel != ""
        return deityName + " marks you as " + tierLabel + "."
    elseIf eventName == "neglect" && deityName != ""
        return deityName + "'s regard fades as your devotion goes quiet."
    elseIf eventName == "dawn"
        return "Your devotions settle with the dawn."
    elseIf eventName == "favor" && deityName != ""
        return deityName + " marks the act."
    elseIf eventName == "shift" && deityName != ""
        return deityName + " marks the change."
    elseIf eventName == "rivalry" && rival != ""
        return rival + " pulls against your path."
    endIf
    return ""
EndFunction

Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText, Bool allowFallback = True)
    String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + JsonSafeString(symbolName) + "\",\"tone\":\"" + JsonSafeString(tone) + "\",\"title\":\"" + JsonSafeString(titleText) + "\",\"message\":\"" + JsonSafeString(messageText) + "\"}}"
    return SendPrismaToastPayloadOrFallback(payload, titleText, messageText, allowFallback)
EndFunction

Bool Function SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival, Bool allowFallback = True)
    String deityName = ""
    String symbolName = "journal"
    if deity
        deityName = GetPublicDeityDisplayName(deity)
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    context = NormalizePublicDeityDisplayText(context)
    rival = NormalizePublicDeityDisplayText(rival)
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
    return SendPrismaToastPayloadOrFallback(j, "", BuildPrismaEventFallbackText(eventName, deityName, context, tierLabel, rival), allowFallback)
EndFunction

; --- Main Prisma panel payload ---
; The focused Prisma panel is player-owned only. Runtime/gameplay refreshes can
; mark data dirty, but only an explicit player request may open or focus it.
Function RequestPanelRefresh()
    _panelDirty = True
EndFunction

Function BeginRaceSetupQuietPresentation(String reason)
    Int depth = StorageUtil.GetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth")
    StorageUtil.SetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth", depth + 1)
    StorageUtil.SetStringValue(None, "PDV.RaceSetup.QuietPresentationReason", reason)
EndFunction

Function EndRaceSetupQuietPresentation()
    Int depth = StorageUtil.GetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth")
    if depth <= 1
        StorageUtil.SetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth", depth - 1)
    endIf
EndFunction

Bool Function IsRaceSetupQuietPresentationActive()
    return StorageUtil.GetIntValue(None, "PDV.RaceSetup.QuietPresentationDepth") > 0
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

Function SurfaceTransition(String eventClass, String surfaceKey, String direction, Int deityIndex = -1, String toneOverride = "", Bool repeatable = false, Bool headline = false, Bool silent = false)
    if eventClass == "" || surfaceKey == "" || direction == ""
        return
    endIf
    surfaceKey = NormalizePublicDeityDisplayText(surfaceKey)
    if IsRaceSetupQuietPresentationActive()
        return
    endIf

    ; Guard. Non-repeatable transitions (curse/tier/neglect first-time) keep the
    ; original PERMANENT one-shot key -- zero behavior change for existing callers.
    ; Repeatable per-race transitions scope the guard by game-day so the same
    ; transition can re-surface on a later day; callers encode the destination state
    ; in surfaceKey so distinct destinations are distinct guards.
    String guard = "PDV.Surfaced." + eventClass + "." + surfaceKey + "." + direction
    if repeatable
        guard = guard + "." + (Utility.GetCurrentGameTime() as Int)
    endIf
    if StorageUtil.GetIntValue(None, guard) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, guard, 1)
    StorageUtil.SetStringValue(None, "PDV.Surfaced.Last", guard)
    ; A silent transition (e.g. a formal-offer REFUSAL) still writes the permanent pinned
    ; Book of Days chronicle below, but skips the transient director cue -- no screen wash,
    ; no D1 sound. A refusal is a quiet closing-of-the-door, not an announced moment.
    if PDV_DiegeticDirectorService && !silent
        PDV_DiegeticDirectorService.Dispatch(eventClass, surfaceKey, direction, deityIndex, toneOverride)
    endIf

    ; Feed the Book of Days chronicle (the entries BuildJournalPayloadJson renders).
    String line = ResolveTransitionJournalLine(eventClass, surfaceKey, direction, deityIndex)
    if line != ""
        Bool pinned = headline || eventClass == "curse" || eventClass == "reorientation"
        String toneKey = TransitionToneKey(eventClass, direction)
        AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, toneKey, ResolveTransitionJournalSymbol(eventClass, deityIndex), pinned, GetJournalMagnitudeForTone(toneKey), BuildJournalEventTitle(toneKey, ""))
    endIf
EndFunction

; Map a (eventClass, direction) transition to the Book of Days tone key recognized
; by JournalToneToTitle/JournalToneToValence. Most pass through as eventClass.direction
; (tier.reach, curse.onset, neglect.drop, substrate.act); the special cases below
; collapse to the bare tone the title/valence switches know.
String Function TransitionToneKey(String eventClass, String direction)
    if eventClass == "reorientation"
        return "reorientation"
    elseIf eventClass == "digest"
        return "dawn.digest"
    endIf
    return eventClass + "." + direction
EndFunction

; Resolve the in-voice journal line for a transition. Flagship/bespoke voice
; (Khajiit/Dunmer + generic curse/tier authored in the director resolvers) wins;
; otherwise fall back to a templated line. The per-race templated branches are
; expanded by the race routing helpers (see RouteRaceSetupJournal).
String Function ResolveTransitionJournalLine(String eventClass, String surfaceKey, String direction, Int deityIndex)
    String toneKey = eventClass + "." + direction
    if PDV_DiegeticDirectorService && !(eventClass == "tier" && direction == "reach")
        String bespoke = PDV_DiegeticDirectorService.ResolveJournalLine(deityIndex, toneKey)
        if bespoke != ""
            return bespoke
        endIf
    endIf

    if eventClass == "offer" && direction == "accept"
        return BuildCommitmentOfferAcceptJournalLine(deityIndex)
    elseIf eventClass == "offer" && direction == "refuse"
        return BuildCommitmentOfferRefuseJournalLine(deityIndex)
    elseIf eventClass == "reorientation" && direction == "shift"
        return BuildReorientationJournalLine(surfaceKey)
    elseIf eventClass == "tier" && direction == "reach"
        return BuildTierReachJournalLine(surfaceKey, deityIndex)
    elseIf eventClass == "curse" && direction == "onset"
        return "A curse changes the shape of devotion."
    elseIf eventClass == "curse" && direction == "cure"
        return "The curse lifts, and devotion may answer again."
    elseIf eventClass == "neglect" && direction == "drop"
        return "A rite has grown quiet and needs attention."
    elseIf eventClass == "neglect" && direction == "recover"
        return "You return to a rite you had let fall silent."
    elseIf eventClass == "creed" && direction == "drop"
        return "You crossed " + GetJournalDeityName(deityIndex) + "'s creed, and the path recoils."
    endIf
    return ""
EndFunction

String Function BuildTierReachJournalLine(String surfaceKey, Int deityIndex)
    String deityName = GetJournalDeityName(deityIndex)
    String tierLabel = ExtractTierLabelFromSurfaceKey(surfaceKey)
    if tierLabel == ""
        tierLabel = "a deeper standing"
    endIf
    return "Your devotion to " + deityName + " has reached " + tierLabel + "."
EndFunction

String Function ExtractTierLabelFromSurfaceKey(String surfaceKey)
    if StringContainsToken(surfaceKey, "Champion")
        return "Champion"
    elseIf StringContainsToken(surfaceKey, "Devoted")
        return "Devoted"
    elseIf StringContainsToken(surfaceKey, "Seeker")
        return "Seeker"
    elseIf StringContainsToken(surfaceKey, "Faithful")
        return "Faithful"
    elseIf StringContainsToken(surfaceKey, "Observant")
        return "Observant"
    endIf
    return ""
EndFunction

String Function BuildCommitmentOfferAcceptJournalLine(Int deityIndex)
    String patron = GetJournalDeityName(deityIndex)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_DUNMER
        return "The Reclamation deepens in you. You named " + patron + " as your focus."
    elseIf originRace == ORIGIN_ALTMER
        return "The foundation narrows to a single disciplined road. You named " + patron + " your focus."
    elseIf originRace == ORIGIN_REDGUARD
        return "The sect's broad worship narrows to one charge. You took " + patron + " as your own."
    endIf
    return "The broad faith narrows to one; " + patron + " has named you their own."
EndFunction

String Function BuildCommitmentOfferAcceptToastLine(PDV_DeityBase deity)
    String patron = GetPublicDeityDisplayName(deity)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_DUNMER
        return "The ash-prayer has a name: " + patron + "."
    elseIf originRace == ORIGIN_ALTMER
        return "You name " + patron + " your focus."
    elseIf originRace == ORIGIN_REDGUARD
        return "You walk under " + patron + " now."
    endIf
    return patron + " has named you their own."
EndFunction

String Function BuildCommitmentOfferRefuseJournalLine(Int deityIndex)
    String patron = GetJournalDeityName(deityIndex)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_DUNMER
        return "The Reclamation holds as it was. You set " + patron + " aside, and " + patron + " will not ask again."
    elseIf originRace == ORIGIN_ALTMER
        return "The foundation stands as it was. You kept to it alone, and " + patron + " will not ask again."
    elseIf originRace == ORIGIN_REDGUARD
        return "The sect's broad worship holds as it was. You set " + patron + "'s charge aside; " + patron + " will not ask again."
    endIf
    return "The broad faith stays whole; you turned " + patron + " away, and " + patron + " will not ask again."
EndFunction

String Function BuildCommitmentOfferRefuseToastLine(PDV_DeityBase deity)
    String patron = GetPublicDeityDisplayName(deity)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_DUNMER
        return "You set " + patron + " aside."
    elseIf originRace == ORIGIN_ALTMER
        return "You keep to the foundation."
    elseIf originRace == ORIGIN_REDGUARD
        return "You keep to the sect."
    endIf
    return "You turned " + patron + " away."
EndFunction

String Function BuildReorientationJournalLine(String surfaceKey)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_ALTMER
        return "Your soul records where you stand in the Thalmor question: " + surfaceKey + "."
    elseIf originRace == ORIGIN_BRETON
        return BuildStartupRoadJournalLine(surfaceKey)
    endIf
    return ""
EndFunction

String Function GetJournalDeityName(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if deity
        return GetPublicDeityDisplayName(deity)
    endIf
    return "the patron"
EndFunction

; Symbol for a journal entry: the deity's glyph when the transition belongs to a
; deity, else the generic journal mark.
String Function ResolveTransitionJournalSymbol(String eventClass, Int deityIndex)
    if deityIndex >= 0
        PDV_DeityBase deity = GetDeityByIndex(deityIndex)
        if deity
            return GetPrismaSymbolForDeity(deity)
        endIf
    endIf
    return "journal"
EndFunction

Bool Function PushDevotionPanel(Bool playerRequested = false)
    if !playerRequested
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

    PDV_DaedricPathBase panelPact = GetActiveDaedricPactPath()
    if panelPact
        ; Prince-wins: the active pact is the single commitment, so the WHOLE panel
        ; identity (not just the text fields) reflects it. _activeDeity is None here
        ; (severed under exclusivity), so without this the header/bar would fall to the
        ; race substrate at piety 0.
        titleText = NormalizePublicDeityDisplayText(panelPact.DeityName)
        symbolName = GetPrismaSymbolForDeity(panelPact)
        if symbolName == "journal"
            symbolName = "daedric"
        endIf
        piety = panelPact.GetStoredPiety()
        pietyToday = GetPietyToday(panelPact)
        tierValue = panelPact.GetStoredTier()
        if panelPact.ThresholdChampion > 0.0
            championThreshold = panelPact.ThresholdChampion
        endIf
    elseIf _activeDeity
        titleText = GetPublicDeityDisplayName(_activeDeity)
        symbolName = GetPrismaSymbolForDeity(_activeDeity)
        piety = GetPiety(_activeDeity)
        pietyToday = GetPietyToday(_activeDeity)
        tierValue = GetTier(_activeDeity)
        if _activeDeity.ThresholdChampion > 0.0
            championThreshold = _activeDeity.ThresholdChampion
        endIf
    else
        ; Quasi-patron: surface the race's substrate/state-track as panel identity.
        ; Piety stays 0 for substrate races; there is no single scoring float.
        ; The tierLabelOverride carries the meaningful state (e.g. "Hist: Strained").
        titleText = GetPanelQuasiPatronName(originRace)
        symbolName = GetPanelQuasiPatronSymbol(originRace)
        tierLabelOverride = GetPanelQuasiPatronTierLabel(originRace)
        Int broadTier = GetBroadLaneTierForOrigin(originRace)
        if broadTier > TIER_NONE
            titleText = GetBroadLaneDisplayName(originRace)
            symbolName = GetBroadLaneSymbol(originRace)
            tierValue = broadTier
            tierLabelOverride = GetBroadLaneStandingLabel(originRace, broadTier)
            piety = GetBroadLaneServiceCount(originRace) as Float
        endIf
        if PDV_GLO_ActivePiety
            if broadTier <= TIER_NONE
                piety = PDV_GLO_ActivePiety.GetValue()
            endIf
        endIf
        if PDV_GLO_ActiveTier
            if broadTier <= TIER_NONE
                tierValue = PDV_GLO_ActiveTier.GetValueInt()
            endIf
        endIf
    endIf

    ; The single active commitment (pact-wins, else patron) for the threshold + instrument.
    PDV_DeityBase panelCommitment = _activeDeity
    if panelPact
        panelCommitment = panelPact
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
    String nextText = GetPanelNextThresholdText(panelCommitment, piety)
    if panelCommitment == None && GetBroadLaneTierForOrigin(originRace) > TIER_NONE
        nextText = GetBroadLaneNextThresholdText(originRace)
    endIf
    j = j + ",\"nextText\":\"" + JsonSafeString(nextText) + "\""
    j = j + ",\"piety\":" + piety
    if panelCommitment == None && GetBroadLaneTierForOrigin(originRace) > TIER_NONE
        j = j + ",\"pietyLabel\":\"" + JsonSafeString("" + GetBroadLaneServiceCount(originRace) + " broad acts") + "\""
    endIf
    j = j + ",\"pietyToday\":" + pietyToday
    j = j + ",\"todayMood\":\"" + JsonSafeString(GetPanelTodayMood(pietyToday)) + "\""
    j = j + ",\"driftLabel\":\"" + JsonSafeString(GetPanelDriftLabel()) + "\""
    j = j + ",\"originRace\":\"" + JsonSafeString(originLabel) + "\""
    j = j + ",\"patronState\":\"" + JsonSafeString(GetPatronStateLabel()) + "\""
    j = j + ",\"acts\":[" + GetPanelActsJson() + "]"
    j = j + ",\"rites\":[" + GetPanelRitesJson() + "]"
    j = j + ",\"relations\":[" + GetPanelRelationsJson() + "]"
    j = j + ",\"instrument\":" + GetPanelInstrumentJson(originRace, panelCommitment != None, tierValue, tierLabel, piety, championThreshold)
    j = j + ",\"dashboard\":" + GetDashboardJson()
    j = j + ",\"debug\":" + GetPanelDebugJson()
    j = j + "}"

    return PDV_PrismaBridge.SendJson(j)
EndFunction

; --- Devotion dashboard payload (the analytical feedback tool, Today tab) ---
; Per-god rollup (state + recent drivers). Shows the tracked god first (active patron /
; Khajiit emphasis), then only gods in the player's origin roster with movement or
; neglect. Cross-race quest reactions still score, but the panel stays culturally scoped.
; Player-pulled panel content only -- never an auto-push surface. Does NOT expose the
; likes/dislikes table.
String Function GetDashboardJson()
    String gods = ""
    Int shown = 0
    Int originRace = GetPlayerOriginRaceIndex()

    PDV_DeityBase tracked = _activeDeity
    if !tracked
        ; An active Prince pact is the tracked commitment (it's not in PDV_FLST_AllDeities,
        ; so the pantheon loop below won't double-list it).
        PDV_DaedricPathBase dashPact = GetActiveDaedricPactPath()
        if dashPact
            tracked = dashPact
        endIf
    endIf
    if !tracked && IsKhajiitOrigin()
        tracked = GetKhajiitEmphasisDeity(GetKhajiitFocusedEmphasis())
    endIf
    if tracked
        gods = AppendDashboardGod(gods, tracked, "patron")
        shown += 1
    endIf

    PDV_DaedricPathBase watchingPath = GetTopPrePactDaedricPath()
    if watchingPath && watchingPath != tracked
        gods = AppendDashboardGod(gods, watchingPath, "watching")
        shown += 1
    endIf

    if PDV_FLST_AllDeities
        Int i = 0
        Int count = PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if deity && deity != tracked && IsDashboardDeityInOriginRoster(deity, originRace)
                Form deityForm = deity as Form
                Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
                Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
                if piety > 0.0 || pietyToday != 0.0 || IsNeglectFlagActive(deity) || HasRecentPietyMovement(deityForm)
                    gods = AppendDashboardGod(gods, deity, "pantheon")
                    shown += 1
                endIf
            endIf
            i += 1
        endWhile
    endIf

    String j = "{\"gods\":[" + gods + "]"
    j = j + ",\"systems\":[\"patron\",\"pantheon\",\"watching\",\"neglected\"]}"
    return j
EndFunction

Bool Function IsDashboardDeityInOriginRoster(PDV_DeityBase deity, Int originRace)
    if !deity
        return False
    endIf

    if originRace == ORIGIN_NORD
        return deity == PDV_Kyne || deity == PDV_Kynareth || deity == PDV_Talos || deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Stuhn || deity == PDV_Mara || deity == PDV_Akatosh || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Julianos || deity == PDV_Dibella || deity == PDV_Zenithar
    elseIf originRace == ORIGIN_IMPERIAL
        return deity == PDV_Kynareth || deity == PDV_Mara || deity == PDV_Akatosh || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Julianos || deity == PDV_Dibella || deity == PDV_Zenithar
    elseIf originRace == ORIGIN_BRETON
        return deity == PDV_Kynareth || deity == PDV_Talos || deity == PDV_Mara || deity == PDV_Akatosh || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Julianos || deity == PDV_Dibella || deity == PDV_Zenithar || deity == PDV_Magnus || deity == PDV_Yffre
    elseIf originRace == ORIGIN_ALTMER
        return deity == PDV_Mara || deity == PDV_Stendarr || deity == PDV_Magnus || deity == PDV_Yffre || deity == PDV_AuriEl || deity == PDV_Xarxes || deity == PDV_Trinimac || deity == PDV_Syrabane
    elseIf originRace == ORIGIN_BOSMER
        return deity == PDV_Yffre || deity == PDV_AuriEl || deity == PDV_Xarxes || deity == PDV_BaanDar || deity == PDV_Zen
    elseIf originRace == ORIGIN_DUNMER
        return deity == PDV_Azura || deity == PDV_Boethiah || deity == PDV_Mephala
    elseIf originRace == ORIGIN_KHAJIIT
        return deity == PDV_Azura || deity == PDV_Boethiah || deity == PDV_Mephala || deity == PDV_BaanDar || deity == PDV_Rajhin || deity == PDV_Alkosh || deity == PDV_Khenarthi
    elseIf originRace == ORIGIN_ARGONIAN
        return deity == PDV_Hist || deity == PDV_Sithis
    elseIf originRace == ORIGIN_ORC
        return deity == PDV_Malacath
    elseIf originRace == ORIGIN_REDGUARD
        return deity == PDV_Tuwhacca || deity == PDV_Leki || deity == PDV_HoonDing
    endIf

    return False
EndFunction

String Function AppendDashboardGod(String acc, PDV_DeityBase deity, String system)
    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    Int tier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int

    String entry = "{\"god\":\"" + JsonSafeString(GetPublicDeityDisplayName(deity)) + "\""
    entry = entry + ",\"symbol\":\"" + JsonSafeString(GetPrismaSymbolForDeity(deity)) + "\""
    entry = entry + ",\"system\":\"" + JsonSafeString(system) + "\""
    entry = entry + ",\"state\":\"" + JsonSafeString(GetGodRollupState(deity)) + "\""
    entry = entry + ",\"pietyToday\":" + pietyToday
    entry = entry + ",\"piety\":" + piety
    entry = entry + ",\"tier\":" + tier
    entry = entry + ",\"drivers\":[" + GetDeityDriversJson(deity) + "]"
    entry = entry + ",\"week\":[" + BuildWeekNetJson(deityForm) + "]}"

    if acc != ""
        acc = acc + ","
    endIf
    return acc + entry
EndFunction

; Raw recent-driver entries (newest-last) for one deity. The dashboard aggregates by
; reason client-side; each entry carries its signed delta and gain/loss direction.
String Function GetDeityDriversJson(PDV_DeityBase deity)
    Form deityForm = deity as Form
    Int count = StorageUtil.StringListCount(deityForm, "PDV.Driver.Reasons")
    String out = ""
    Int i = 0
    while i < count
        String reason = StorageUtil.StringListGet(deityForm, "PDV.Driver.Reasons", i)
        Float delta = StorageUtil.FloatListGet(deityForm, "PDV.Driver.Deltas", i)
        String dir = "gain"
        if delta < 0.0
            dir = "loss"
        endIf
        String entry = "{\"reason\":\"" + JsonSafeString(reason) + "\",\"count\":1,\"net\":" + delta + ",\"dir\":\"" + dir + "\"}"
        if out != ""
            out = out + ","
        endIf
        out = out + entry
        i += 1
    endWhile
    return out
EndFunction

; Dedicated 7-slot daily-net ring for the Weekly tab. Kept separate from the driver
; ring (which caps at 6 FIFO entries and can't reliably span 7 days). One write per
; surfaced form per dawn.
Function PushWeekNet(Form deityForm, Float dayNet)
    while StorageUtil.FloatListCount(deityForm, "PDV.Week.Net") >= 7
        StorageUtil.FloatListRemoveAt(deityForm, "PDV.Week.Net", 0)
    endWhile
    StorageUtil.FloatListAdd(deityForm, "PDV.Week.Net", dayNet, True)
EndFunction

; The dashboard surfaces a roster god the moment it has ANY tracked point
; movement -- gain OR loss -- not just positive standing, so a transgression
; that floors piety to zero (e.g. a lone assault against a Divine) still shows
; the player exactly what cost them. Detected from records that outlive the
; dawn PietyToday reset: the persistent 7-day Week ring (fed the raw daily net
; before the reset) plus the rolling driver log windowed to 7 days (catches a
; day whose gains and losses netted to zero in the ring). Owner ruling
; 2026-07-05: the panel must account for every negative and positive point set.
Bool Function HasRecentPietyMovement(Form deityForm)
    Int n = StorageUtil.FloatListCount(deityForm, "PDV.Week.Net")
    Int i = 0
    while i < n
        if StorageUtil.FloatListGet(deityForm, "PDV.Week.Net", i) != 0.0
            return True
        endIf
        i += 1
    endWhile

    Int today = Utility.GetCurrentGameTime() as Int
    Int driverDays = StorageUtil.IntListCount(deityForm, "PDV.Driver.Days")
    Int k = 0
    while k < driverDays
        if today - StorageUtil.IntListGet(deityForm, "PDV.Driver.Days", k) <= 7
            return True
        endIf
        k += 1
    endWhile

    return False
EndFunction

; week[] for the Weekly tab: stored daily nets (oldest->newest) plus the live,
; not-yet-folded day appended as the newest point. The UI keeps only the last 7.
String Function BuildWeekNetJson(Form deityForm)
    String out = ""
    Int n = StorageUtil.FloatListCount(deityForm, "PDV.Week.Net")
    Int i = 0
    while i < n
        if out != ""
            out = out + ","
        endIf
        out = out + StorageUtil.FloatListGet(deityForm, "PDV.Week.Net", i)
        i += 1
    endWhile
    Float todayNet = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    if out != ""
        out = out + ","
    endIf
    return out + todayNet
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
    if GetBroadLaneTierForOrigin(originRace) > TIER_NONE
        return "broad"
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
    if kindText == "broad"
        return "{\"acts\":" + GetBroadLaneServiceCount(originRace) + "}"
    endIf
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
    PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
    if pactPath
        return "A pact binds you; lesser devotions fall quiet."
    endIf
    if IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    ; GetPlayerMcmModeLine handles all races: active patron, substrate, and
    ; state-track modes, so it works for both deity and quasi-patron cases.
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
    if GetActiveDaedricPactPath()
        return "Steady"
    endIf
    if GetPatronState() == PATRON_STATE_ACTIVE
        return "Steady"
    endIf
    return "Quiet"
EndFunction

String Function GetPanelActsJson()
    String items = ""
    PDV_DaedricPathBase actsPact = GetActiveDaedricPactPath()
    if actsPact
        items = AppendJsonItem(items, PanelPlainObject("daedric", "neutral", "Keep the pact", "Act in keeping with " + actsPact.DeityName + " to hold this pact."))
    elseIf _activeDeity
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
    ; when there is no scoring patron; gives the player their mode at a glance.
    if !_activeDeity && !actsPact
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
    PDV_DaedricPathBase ritesPact = GetActiveDaedricPactPath()
    if ritesPact
        String pactName = NormalizePublicDeityDisplayText(ritesPact.DeityName)
        items = AppendJsonItem(items, PanelPlainObject("daedric", "", "Keep " + pactName + "'s pact", "Act in keeping with " + pactName + " to hold this pact."))
    elseIf _activeDeity
        String activeName = GetPublicDeityDisplayName(_activeDeity)
        items = AppendJsonItem(items, PanelPlainObject(GetPrismaSymbolForDeity(_activeDeity), "", "Keep " + activeName + "'s rites", "Act in keeping with " + activeName + " to deepen this bond."))
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
    PDV_DaedricPathBase relsPact = GetActiveDaedricPactPath()
    if relsPact
        Int dstate = relsPact.GetDaedricStateForPlayer()
        String dstateTone = "neutral"
        if dstate == relsPact.DAEDRIC_STATE_NATIVE
            dstateTone = "good"
        elseIf dstate >= relsPact.DAEDRIC_STATE_TABOO
            dstateTone = "warning"
        endIf
        items = AppendJsonItem(items, PanelPlainObject("", dstateTone, "", NormalizePublicDeityDisplayText(relsPact.DeityName) + "'s pact stands " + relsPact.GetDaedricStateLabel(dstate) + " among your people."))
    elseIf _activeDeity
        Int stance = _activeDeity.GetStanceForPlayer()
        String stanceText = ""
        String stanceTone = ""
        String activeName = GetPublicDeityDisplayName(_activeDeity)
        if stance == _activeDeity.STANCE_NATIVE
            stanceText = "Native practice: " + activeName + "'s rites answer you clearly."
            stanceTone = "good"
        elseIf stance == _activeDeity.STANCE_FOREIGN
            stanceText = "Foreign devotion: " + activeName + " answers, but as an outsider's god."
            stanceTone = "neutral"
        elseIf stance == _activeDeity.STANCE_TABOO
            stanceText = "Forbidden devotion: " + activeName + " is taboo to your people."
            stanceTone = "warning"
        elseIf stance == _activeDeity.STANCE_HOSTILE
            stanceText = "Hostile devotion: " + activeName + " stands against your people."
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
        deityName = GetPublicDeityDisplayName(deity)
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    context = NormalizePublicDeityDisplayText(context)
    itemText = NormalizePublicDeityDisplayText(itemText)
    rival = NormalizePublicDeityDisplayText(rival)
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

    SendPrismaToast("journal", "good", titleText, messageText)
    AppendBookOfDaysEntry(messageText, Utility.GetCurrentGameTime() as Int, "favor.act", "journal", False, 1, titleText)
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

    AwardPiety(deity, delta, CuratedSignalDriverReason(deity, signalType))

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
    AwardPiety(deity, scaledDelta, CuratedSignalDriverReason(deity, signalType))

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
        ; Activation itself is the exclusivity seam (handled in MakeActiveDaedricPact ->
        ; PendingActivation -> ProcessPendingDaedricActivation), so this funnel does not
        ; sever the patron directly: a tier-up already auto-activated via OnTierChange
        ; before this line. By design, a deliberately-abandoned (dormant, tier>0, not
        ; active) Prince re-seats ONLY via a tier crossing or this curated signal --
        ; same-tier ambient acts / shrine prayer do NOT re-seat it (RecomputeStoredTier's
        ; no-change branch strips, not activates). Every route that DOES re-activate
        ; passes through MakeActiveDaedricPact, which enforces exclusivity.
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
    ; Pre-pact "watching" onset. If this signal established interest without a
    ; commitment (still tier 0, piety now above zero), chronicle a NAMED Book of Days
    ; line + one soft cue so a Book-of-Days-only player learns WHICH Prince is watching
    ; -- panel-badge parity for the same pre-pact state. A tier gain is a commitment and
    ; is surfaced by ShowDaedricMilestonePresentation above, so this stays silent then.
    MaybeChronicleDaedricWatchingOnset(path, pathIndex, path.GetStoredPiety(), tierAfter)
    RequestPanelRefresh()

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric live signal: " + path.DeityName + " index " + pathIndex + " source " + sourceId)
    endIf
EndFunction

; One-shot NAMED pre-pact chronicle: fires the first time a Prince enters the "watching"
; state (tier 0 with piety above zero -- the same state the panel surfaces as a badge).
; Latched per Prince via "PDV.Daedric.WatchingChronicled" on the deity form; the latch is
; reset in PDV_DaedricPathBase.UpdatePrePactNoticeState the moment interest lapses to
; nothing or the Prince commits, so a genuine re-entry into watching chronicles again.
; Repeated sub-threshold signals that merely deepen an existing watch stay silent.
Function MaybeChronicleDaedricWatchingOnset(PDV_DaedricPathBase path, Int pathIndex, Float pietyAfter, Int tierAfter)
    if !path
        return
    endIf
    ; Only pre-pact watching chronicles here; a tier gain is a pact (milestone surface),
    ; and a signal that left the Prince at the zero floor is not yet watching.
    if tierAfter > TIER_NONE || pietyAfter <= 0.0
        return
    endIf

    Form deityForm = path.GetDeityForm()
    if StorageUtil.GetIntValue(deityForm, "PDV.Daedric.WatchingChronicled") == 1
        return
    endIf
    StorageUtil.SetIntValue(deityForm, "PDV.Daedric.WatchingChronicled", 1)

    String symbolName = GetPrismaSymbolForDeity(path)
    if symbolName == "journal"
        symbolName = "daedric"
    endIf

    ; Neutral/curiosity onset, unpinned (a soft interest, not a milestone). Names the
    ; Prince using the path's player-facing name (AppendBookOfDaysEntry normalizes it).
    ; The deeper "The world tilts toward <Prince>." pressure beat still fires later once
    ; piety crosses the half-Seeker threshold.
    AppendBookOfDaysEntry(path.DeityName + " has taken an interest in you.", Utility.GetCurrentGameTime() as Int, "daedric.pressure", symbolName, False, 1, "A Prince takes interest")

    ; Single soft transient cue that NAMES the Prince (the prior watching popup did not).
    ; One-shot alongside the journal line above -- never per-signal. The "watching" phase
    ; falls through to the Daedric toast defaults ("<Prince> takes note"), so no view
    ; change is needed; the context line carries the soft framing.
    SendPrismaDaedricToast(path.DeityName, "watching", "An interest taken, not yet a pact.", symbolName)

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric watching onset chronicled: " + path.DeityName + " index " + pathIndex)
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
    ; action is invisible. Top-left line always fires; Prisma gets an explicit
    ; repeatable Daedric toast. The diegetic D1 dispatch remains separate for
    ; screen/sound/journal work and can stay disabled without hiding the toast.
    SendPrismaDaedricToast(path.DeityName, "prayer", "Shrine prayer answered.", GetPrismaSymbolForDeity(path))
    AppendBookOfDaysEntry("You offered prayer at the shrine of " + path.DeityName + ".", Utility.GetCurrentGameTime() as Int, "favor.act", GetPrismaSymbolForDeity(path), False, 1, "Shrine prayer answered")
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

Int Function DebugGetSignalFloorSmokeScenarioCount()
    return 12
EndFunction

String Function DebugGetSignalFloorSmokeLabel(Int scenarioIndex)
    if scenarioIndex <= 0
        return "Reload matrix + LD v15"
    elseIf scenarioIndex == 1
        return "DLC2SV01 200"
    elseIf scenarioIndex == 2
        return "MQ305 200"
    elseIf scenarioIndex == 3
        return "MQ206 220"
    elseIf scenarioIndex == 4
        return "DBDestroy 200"
    elseIf scenarioIndex == 5
        return "MS10 100"
    elseIf scenarioIndex == 6
        return "CR13 200"
    elseIf scenarioIndex == 7
        return "MQ302 300"
    elseIf scenarioIndex == 8
        return "Crypt clear"
    elseIf scenarioIndex == 9
        return "Likes/dislikes v15"
    elseIf scenarioIndex == 10
        return "Green Way"
    elseIf scenarioIndex == 11
        return "Paarthurnax kill"
    elseIf scenarioIndex == 12
        return "Paarthurnax spare"
    endIf
    return "Unknown"
EndFunction

String Function DebugRunSignalFloorSmokeScenario(Int scenarioIndex)
    String label = DebugGetSignalFloorSmokeLabel(scenarioIndex)
    StorageUtil.SetStringValue(None, "PDV.SignalFloorSmoke.LastScenario", label)

    if scenarioIndex <= 0
        String reloadText = DebugReloadQuestMatrix()
        StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
        EnsureLikesDislikesTable()
        Trace(1, "SignalFloorSmoke debug reload completed.")
        return "Signal-floor baseline reloaded. " + reloadText
    elseIf scenarioIndex == 1
        return DebugRouteSignalFloorQuest(0x00019B4A, "Dragonborn.esm", 200, label)
    elseIf scenarioIndex == 2
        return DebugRouteSignalFloorQuest(0x00046EF2, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 3
        return DebugRouteSignalFloorQuest(0x00036193, "Skyrim.esm", 220, label)
    elseIf scenarioIndex == 4
        return DebugRouteSignalFloorQuest(0x000934FB, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 5
        return DebugRouteSignalFloorQuest(0x0001DBFC, "Skyrim.esm", 100, label)
    elseIf scenarioIndex == 6
        return DebugRouteSignalFloorQuest(0x000E3163, "Skyrim.esm", 200, label)
    elseIf scenarioIndex == 7
        return DebugRouteSignalFloorQuest(0x00045923, "Skyrim.esm", 300, label)
    elseIf scenarioIndex == 8
        return DebugRouteSignalFloorCryptClear()
    elseIf scenarioIndex == 9
        return DebugRouteSignalFloorLikesDislikes()
    elseIf scenarioIndex == 10
        return DebugRouteSignalFloorGreenWay()
    elseIf scenarioIndex == 11
        return DebugRouteSignalFloorPaarthurnaxKill()
    elseIf scenarioIndex == 12
        return DebugRouteSignalFloorPaarthurnaxSpare()
    endIf

    return "Unknown signal-floor smoke scenario."
EndFunction

String Function DebugRouteSignalFloorQuest(Int questFormId, String pluginName, Int stageValue, String label)
    DebugReloadQuestMatrix()
    Quest sourceQuest = Game.GetFormFromFile(questFormId, pluginName) as Quest
    if !sourceQuest
        Trace(1, "SignalFloorSmoke quest missing: " + label)
        return label + ": quest not found in " + pluginName + "."
    endIf

    ApplyQuestReaction(sourceQuest, stageValue)
    String reactionKey = StorageUtil.GetStringValue(None, "PDV.QuestReaction.LastKey")
    Int count = StorageUtil.GetIntValue(None, "PDV.QuestReaction.LastCellCount")
    Trace(1, "SignalFloorSmoke quest routed: " + label + " key " + reactionKey + " cells " + count)
    return label + ": routed " + reactionKey + " (" + count + " cells). Controlled backend route only; run organic smoke for route and display proof."
EndFunction

String Function DebugRouteSignalFloorCryptClear()
    if !PDV_FLST_UndeadCryptClearSites || PDV_FLST_UndeadCryptClearSites.GetSize() <= 0
        return "Crypt-clear FormList is missing or empty."
    endIf

    Location cryptLoc = PDV_FLST_UndeadCryptClearSites.GetAt(0) as Location
    if !cryptLoc
        return "Crypt-clear FormList slot 0 is not a Location."
    endIf

    ApplyUndeadCryptClearReactions(cryptLoc, 1.0)
    Trace(1, "SignalFloorSmoke crypt-clear debug fanout routed.")
    return "Crypt-clear fanout routed from FormList slot 0. Controlled backend route only; organic proof still requires entering and clearing a listed crypt."
EndFunction

String Function DebugRouteSignalFloorLikesDislikes()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
    EnsureLikesDislikesTable()
    DebugFireDislike(GetQuestReactionDeity("Kyne"), 303)
    DebugFireDislike(GetQuestReactionDeity("Arkay"), 366)
    Trace(1, "SignalFloorSmoke LD v15 debug fired events 303 and 366.")
    return "Likes/dislikes v15 reloaded; fired Kyne 303 and Arkay 366 through the debug dislike harness. Controlled backend route only."
EndFunction

String Function DebugRouteSignalFloorGreenWay()
    if !IsBosmerOrigin()
        return "Set origin to Bosmer before running Green Way signal-floor debug."
    endIf

    Bool siteRouted = TryAwardBosmerYffreGreenSite("mcm_signal_floor", "mcm_signal_floor_green_site")
    DebugTriggerGreenPactViolation()
    Trace(1, "SignalFloorSmoke Green Way debug routed; site=" + BoolToInt(siteRouted))
    return "Green Way backend routes fired. Site=" + BoolToInt(siteRouted) + ". Plant-food organic proof still requires consuming a listed plant food."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxKill()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    HandlePaarthurnaxKill(sourceForm, "mcm_signal_floor_kill")
    Trace(1, "SignalFloorSmoke Paarthurnax kill debug routed.")
    return "Paarthurnax kill fork routed with latches reset first. Controlled backend route only; organic kill proof still required."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxSpare()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    HandlePaarthurnaxSpare(sourceForm, "mcm_signal_floor_spare")
    Trace(1, "SignalFloorSmoke Paarthurnax spare debug routed.")
    return "Paarthurnax spare fork routed with latches reset first. Controlled backend route only; organic MQ305/alive proof still required."
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

; Resolve the single live Daedric pact to its path. Requires tier > NONE so a stale
; ActivePact pointer left at tier 0 reads as "no pact" (Survey/panel never render a
; ghost pact). Pure read; safe to call from Survey/panel/commit paths.
PDV_DaedricPathBase Function GetActiveDaedricPactPath()
    Form activeForm = StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact")
    if !activeForm
        return None
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetDeityForm() == activeForm && path.GetStoredTier() > TIER_NONE
            return path
        endIf
        i += 1
    endWhile
    return None
EndFunction

PDV_DaedricPathBase Function GetTopPrePactDaedricPath()
    if GetActiveDaedricPactPath()
        return None
    endIf

    PDV_DaedricPathBase topPath = None
    Float topPiety = 0.0
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetStoredTier() == TIER_NONE
            Float piety = path.GetStoredPiety()
            if piety > topPiety
                topPiety = piety
                topPath = path
            endIf
        endIf
        i += 1
    endWhile

    return topPath
EndFunction

; Look up a Daedric path by its deity Form regardless of tier (used for lapse
; surfacing, where the lapsed path is at tier 0).
PDV_DaedricPathBase Function GetDaedricPathByForm(Form deityForm)
    if !deityForm
        return None
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetDeityForm() == deityForm
            return path
        endIf
        i += 1
    endWhile
    return None
EndFunction

; Survey block for an active pact. Uses GetPublicTierBand so the Prince band reads
; identically to a patron band. PLACEHOLDER copy (user rewrites post-beta).
String Function GetDaedricSurveyText(PDV_DaedricPathBase path)
    return path.DeityName + " holds your pact. Standing: " + GetPublicTierBand(path.GetStoredTier()) + "."
EndFunction

; Switch-severance surface (patron<->Prince). Top-left notification + Book of Days
; entry + best-effort Prisma toast. PLACEHOLDER copy.
Function SurfaceSwitchSeverance(String mode, String severedName)
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
    String line = "You forsake the pact with " + severedName + ". A new devotion takes its place."
    if mode == "patron_to_prince"
        line = "You turn from your former patron to " + severedName + ". The old bond is severed."
    endIf
    SendPrismaEventToast("shift", None, line, "", "")
    AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "reorientation", "journal", true)
EndFunction

; Lapse surface (a Prince pact fell to none). PLACEHOLDER copy.
Function SurfaceDaedricLapse(PDV_DaedricPathBase path)
    if !path
        return
    endIf
    String line = "Your pact with " + path.DeityName + " has lapsed into silence."
    SendPrismaEventToast("neglect", path, line, "", "")
    AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "neglect.drop", "daedric", false)
EndFunction

; Drain the deferred-lapse flag the base script sets in OnTierChange when a pact
; lapses to none (the base has no manager handle, so it leaves a breadcrumb the
; manager tick picks up). Switch/migration severs clear the pointer directly and
; never set this flag, so they cannot false-fire a lapse here.
Function ProcessPendingDaedricLapse()
    Form pending = StorageUtil.GetFormValue(None, "PDV.Daedric.PendingLapse")
    if !pending
        return
    endIf
    StorageUtil.SetFormValue(None, "PDV.Daedric.PendingLapse", None)
    ; If the same Prince was re-committed within the tick, the pointer is back to it,
    ; so it did not actually lapse -- skip.
    if StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact") == pending
        return
    endIf
    SurfaceDaedricLapse(GetDaedricPathByForm(pending))
EndFunction

Function ProcessPendingDaedricPrePactNotices()
    Int count = StorageUtil.FormListCount(None, "PDV.Daedric.PendingPrePactNotices")
    if count <= 0
        return
    endIf

    PDV_DaedricPathBase topPath = GetTopPrePactDaedricPath()
    Form topForm = None
    if topPath
        topForm = topPath.GetDeityForm()
    endIf

    Bool topWasQueued = False
    while count > 0
        count -= 1
        Form queuedForm = StorageUtil.FormListGet(None, "PDV.Daedric.PendingPrePactNotices", count)
        if topForm && queuedForm == topForm
            topWasQueued = True
        endIf
        StorageUtil.FormListRemoveAt(None, "PDV.Daedric.PendingPrePactNotices", count)
    endWhile

    if !topPath || !topWasQueued || StorageUtil.GetIntValue(topForm, "PDV.Daedric.PrePactNoticeShown") == 1
        return
    endIf

    if topPath.GetStoredTier() != TIER_NONE || topPath.GetStoredPiety() <= 0.0
        return
    endIf

    AppendBookOfDaysEntry("The world tilts toward " + topPath.DeityName + ".", Utility.GetCurrentGameTime() as Int, "daedric.pressure", "daedric", false)
    StorageUtil.SetIntValue(topForm, "PDV.Daedric.PrePactNoticeShown", 1)
EndFunction

; Drain the deferred-activation flag the base sets in MakeActiveDaedricPact on a NEW
; pact activation (from ANY path: live funnel, ambient tier-up, shrine prayer, switch-
; back). This is where patron<->Prince exclusivity is enforced: if a single patron is
; still active when a Prince pact becomes the live commitment, sever the patron and
; surface the switch. (Broad worship has no competing single-patron boons and is left
; as a documented design decision.) Switch/migration severs clear the pointer directly
; and never set this flag, so they don't interfere.
Function ProcessPendingDaedricActivation()
    Form pending = StorageUtil.GetFormValue(None, "PDV.Daedric.PendingActivation")
    if !pending
        return
    endIf
    StorageUtil.SetFormValue(None, "PDV.Daedric.PendingActivation", None)
    ; Act only if this pact is still the live active pact (it may have lapsed/switched
    ; away in the interim).
    if StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact") != pending
        return
    endIf
    PDV_DaedricPathBase path = GetDaedricPathByForm(pending)
    if path
        SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")
    endIf
    if GetPatronState() == PATRON_STATE_ACTIVE
        SetActiveDeity(None)
        if path
            SurfaceSwitchSeverance("patron_to_prince", path.DeityName)
        endIf
    elseIf path && !HasRecentDaedricMilestoneJournal(path)
        AppendBookOfDaysEntry(path.DeityName + " claims your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "daedric", true)
    endIf
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

PDV_DeityBase Function GetShrinePrayerDeityByName(String deityName)
    if deityName == ""
        return None
    endIf

    if deityName == "Kyne"
        return PDV_Kyne
    elseIf deityName == "Kynareth"
        return PDV_Kynareth
    elseIf deityName == "Khenarthi"
        return PDV_Khenarthi
    elseIf deityName == "Akatosh"
        return PDV_Akatosh
    elseIf deityName == "Auri-El" || deityName == "Auriel"
        return PDV_AuriEl
    elseIf deityName == "Alkosh"
        return PDV_Alkosh
    elseIf deityName == "Arkay"
        return PDV_Arkay
    elseIf deityName == "Tu'whacca" || deityName == "Tuwhacca"
        return PDV_Tuwhacca
    elseIf deityName == "Zenithar"
        return PDV_Zenithar
    elseIf deityName == "Z'en" || deityName == "Zen"
        return PDV_Zen
    elseIf deityName == "Mara"
        return PDV_Mara
    elseIf deityName == "Dibella"
        return PDV_Dibella
    elseIf deityName == "Julianos"
        return PDV_Julianos
    elseIf deityName == "Stendarr"
        return PDV_Stendarr
    elseIf deityName == "Talos"
        return PDV_Talos
    endIf

    return GetDeityByName(deityName)
EndFunction

Function HandleShrinePrayer(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel, String sourceId)
    Bool awarded = False
    awarded = AwardShrinePrayerToDeityName(primaryDeityName, shrineLabel, sourceId) || awarded
    awarded = AwardShrinePrayerToDeityName(secondaryDeityName, shrineLabel, sourceId) || awarded
    awarded = AwardShrinePrayerToDeityName(tertiaryDeityName, shrineLabel, sourceId) || awarded

    if awarded
        String label = ResolveShrinePrayerJournalLabel(primaryDeityName, secondaryDeityName, tertiaryDeityName, shrineLabel)
        AppendBookOfDaysEntry("You offered prayer at " + label + "'s shrine.", Utility.GetCurrentGameTime() as Int, "favor.act", "journal", False, 1, "Shrine prayer answered")
    endIf
EndFunction

String Function ResolveShrinePrayerJournalLabel(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel)
    Int originRace = GetPlayerOriginRaceIndex()

    if originRace == ORIGIN_NORD && ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Kyne")
        return "Kyne"
    endIf

    if originRace == ORIGIN_KHAJIIT
        if ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Khenarthi")
            return "Khenarthi"
        endIf
        if ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Alkosh")
            return "Alkosh"
        endIf
    endIf

    if originRace == ORIGIN_ALTMER && ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
        return "Auri-El"
    endIf

    if originRace == ORIGIN_BOSMER
        if ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
            return "Auri-El"
        endIf
        if ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Z'en")
            return "Z'en"
        endIf
    endIf

    if originRace == ORIGIN_REDGUARD && ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Tu'whacca")
        return "Tu'whacca"
    endIf

    if shrineLabel != ""
        return NormalizePublicDeityDisplayText(shrineLabel)
    endIf
    return NormalizePublicDeityDisplayText(primaryDeityName)
EndFunction

Bool Function ShrinePrayerHasAlias(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String aliasName)
    return primaryDeityName == aliasName || secondaryDeityName == aliasName || tertiaryDeityName == aliasName
EndFunction

Bool Function AwardShrinePrayerToDeityName(String deityName, String shrineLabel, String sourceId)
    PDV_DeityBase deity = GetShrinePrayerDeityByName(deityName)
    if !deity
        if deityName != "" && GetDebugLevel() >= 1
            Debug.Trace("[PDV] Shrine prayer skipped unknown deity alias " + deityName + " source " + sourceId)
        endIf
        return False
    endIf

    ; Divine shrine prayers are ambient world clicks; only emit PDV piety/journal
    ; movement when that deity belongs to the player's cultural roster.
    if !IsDashboardDeityInOriginRoster(deity, GetPlayerOriginRaceIndex())
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Shrine prayer skipped outside origin roster: " + deity.DeityName + " from " + shrineLabel + " source " + sourceId)
        endIf
        return False
    endIf

    if !ConsumeShrinePrayerCredit(deity, sourceId)
        return False
    endIf

    AwardPiety(deity, 2.0, "shrine_prayer_" + sourceId)
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Shrine prayer awarded " + deity.DeityName + " from " + shrineLabel + " source " + sourceId)
    endIf
    return True
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

    ; Exclusivity (data-layer): committing a patron severs an active Prince pact.
    ; Guarded on newDeity != None so SetActiveDeity(None) (the patron-teardown path,
    ; incl. the Prince-commit sever above) cannot re-enter this and double-clear.
    if newDeity != None
        PDV_DaedricPathBase priorPact = GetActiveDaedricPactPath()
        if priorPact
            priorPact.ClearLiveDaedricPactSpells()
            StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
            SurfaceSwitchSeverance("prince_to_patron", priorPact.DeityName)
        endIf
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
        HandleImperialSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        HandleBretonSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        HandleDunmerSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        HandleAltmerSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        HandleNordSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_ORC
        HandleOrcSleepEvents(playerRef, reason)
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
        HandleRedguardSleepEvents(playerRef, reason)
    endIf
EndFunction

Int Function GetInteriorSleepCellId(Actor playerRef)
    if !playerRef
        return 0
    endIf

    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return 0
    endIf

    return sleepCell.GetFormID()
EndFunction

Bool Function IsPlayerAtDeclaredRestCell(Actor playerRef, String declaredKey)
    if !playerRef
        return false
    endIf

    Int declaredId = StorageUtil.GetIntValue(None, declaredKey)
    if declaredId == 0
        return false
    endIf

    Cell currentCell = playerRef.GetParentCell()
    if !currentCell
        return false
    endIf

    return currentCell.GetFormID() == declaredId
EndFunction

Bool Function TryDeclareRestCell(String keyPrefix, Int sleepCellId)
    if sleepCellId == 0 || StorageUtil.GetIntValue(None, keyPrefix + ".DeclaredFormID") != 0
        return false
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Int candidateId = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateFormID")
    Int candidateDay = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateCount")

    if candidateId != sleepCellId
        candidateCount = 0
    elseIf candidateDay == today
        return false
    endIf

    candidateCount += 1
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateFormID", sleepCellId)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateDay", today)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateCount", candidateCount)

    if candidateCount < 3
        return false
    endIf

    StorageUtil.SetIntValue(None, keyPrefix + ".DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, keyPrefix + ".DeclaredDay", today)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateFormID", 0)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateDay", 0)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateCount", 0)
    return true
EndFunction

Function HandleNordSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_NORD || !PDV_NordAncestorSubstrate
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
            Trace(2, "Nord hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if !ConsumeOncePerDaySignal("PDV.Signal.NordAncestralRest")
        return
    endIf

    RecordNordAncestralRest("sleep_rest_" + reason, 1.0)
EndFunction

Function HandleOrcSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ORC || !PDV_OrcLifeModeTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Orc.HearthRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Orc.HearthRest", sleepCellId)
            MaybeShowOrcHearthHeldNotice("sleep_rest_declare_" + reason)
            Trace(2, "Orc hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryOrcTrialOfIron(playerRef, sleepCellId, reason)
        return                          ; Trial menu shown; suppress the rest-notice this wake
    endIf

    if !ConsumeOncePerDaySignal("PDV.Signal.OrcAncestralRest")
        return
    endIf

    Int modeValue = GetActiveOrcRewardMode()
    RecordOrcLifeModeSignal(modeValue, 1.0, "sleep_hearth_rest_" + reason)
    MaybeShowOrcHearthHeldNotice("sleep_hearth_rest_" + reason)
    Trace(2, "Orc ancestral rest routed: " + reason)
EndFunction

; The Trial of Iron: at the declared community place (the Orc hearth-rest cell), with a
; 7-day cooldown, the player takes up one discipline of the Code. One-active discipline,
; swap via re-rite (clear-before-add). "Not yet" does not spend the cooldown. Returns true
; when the menu was shown so the wake-notice is suppressed that night.
Bool Function TryOrcTrialOfIron(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !PDV_MESG_Orc_TrialOfIron || GetPlayerOriginRaceIndex() != ORIGIN_ORC
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.OrcTrial.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_Orc_TrialOfIron.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyOrcTrialOfIron(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two disciplines at once. Records the life-mode standing the player
; swore it under so SyncOrcTrialOfIron can fade/restore on a standing collapse.
Function ApplyOrcTrialOfIron(Actor playerRef, Int index)
    RemoveOrcTrialSpells(playerRef)
    Spell chosen = GetOrcTrialSpell(index)
    if !chosen
        return
    endIf

    Int modeNow = 0
    if PDV_OrcLifeModeTrack
        modeNow = PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.ModeAtRite", modeNow)
    StorageUtil.SetFloatValue(None, "PDV.OrcTrial.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Malacath pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    AwardPiety(PDV_Malacath, 0.5, "Took up the Trial of Iron")
    AppendBookOfDaysEntry("You took up a discipline in the Trial of Iron. The Code is held in iron.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
    SendPrismaToast("malacath", "good", "Trial of Iron", "You take up a discipline of the Code. The Trial of Iron holds you to it.")
    Trace(2, "Orc Trial of Iron discipline applied: " + index)
EndFunction

Function RemoveOrcTrialSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell disc = GetOrcTrialSpell(i)
        if disc && playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetOrcTrialSpell(Int index)
    if index == 0
        return PDV_SPEL_Orc_TrialOfIron_Tusk
    elseIf index == 1
        return PDV_SPEL_Orc_TrialOfIron_Shield
    elseIf index == 2
        return PDV_SPEL_Orc_TrialOfIron_Hammer
    elseIf index == 3
        return PDV_SPEL_Orc_TrialOfIron_Yoke
    endIf
    return None
EndFunction

; The discipline holds while the life-mode standing it was sworn under is intact. If that
; standing collapses (a confirmed mode change -- exile, or a different hold), the discipline
; goes quiet at dawn and returns at dawn when the standing is recovered.
; PDV.OrcTrial.Active stays set while quiet so no re-rite is needed.
Function SyncOrcTrialOfIron(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.OrcTrial.Active")
    if active <= 0
        return
    endIf
    Spell disc = GetOrcTrialSpell(active - 1)
    if !disc
        return
    endIf

    Int modeAtRite = StorageUtil.GetIntValue(None, "PDV.OrcTrial.ModeAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == ORIGIN_ORC) && IsOrcTrialCoherent(modeAtRite)
    if eligible
        if !playerRef.HasSpell(disc)
            playerRef.AddSpell(disc, False)
            SendPrismaToast("malacath", "good", "The Code holds", "Your discipline returns.")
        endIf
    else
        if playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
            SendPrismaToast("malacath", "warning", "The discipline goes quiet", "The standing you swore it under has broken.")
        endIf
    endIf
EndFunction

Bool Function IsOrcTrialCoherent(Int modeAtRite)
    if !PDV_OrcLifeModeTrack
        return false
    endIf
    if PDV_OrcLifeModeTrack.GetCurrentState() != modeAtRite
        return false
    endIf
    return true
EndFunction

Function HandleRedguardSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_REDGUARD || !PDV_RedguardSectTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Redguard.AncestralRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Redguard.AncestralRest", sleepCellId)
            ShowRedguardNotification(None, "This resting place remembers the old line.")
            Trace(2, "Redguard ancestral-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryRedguardRemembering(playerRef, sleepCellId, reason)
        return                          ; Remembering menu shown; suppress the rest-notice this wake
    endIf

    if !ConsumeOncePerDaySignal("PDV.Signal.RedguardAncestralRest")
        return
    endIf

    RecordRedguardAncestralRest(1.0, "sleep_ancestor_rest_" + reason)
EndFunction

; The Remembering of Names: an ancestral observance taken at the declared rest cell, with a
; 7-day cooldown. One-active observance, swap via re-rite (clear-before-add). "Not yet" does
; not spend the cooldown. Returns true when the menu was shown so the rest-notice is
; suppressed that night.
Bool Function TryRedguardRemembering(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !PDV_MSG_RedguardRemembering || GetPlayerOriginRaceIndex() != ORIGIN_REDGUARD
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.RedRemember.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MSG_RedguardRemembering.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyRedguardRemembering(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two observances at once. Records the sect named-on so
; SyncRedguardRemembering can fade/restore on a sect shift.
Function ApplyRedguardRemembering(Actor playerRef, Int index)
    RemoveRedguardRememberSpells(playerRef)
    Spell chosen = GetRedguardRememberSpell(index)
    if !chosen
        return
    endIf

    Int sectNow = 0
    if PDV_RedguardSectTrack
        sectNow = PDV_RedguardSectTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.SectAtRite", sectNow)
    StorageUtil.SetFloatValue(None, "PDV.RedRemember.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Tu'whacca pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    AwardPiety(PDV_Tuwhacca, 0.5, "Took up the Remembering of Names")
    AppendBookOfDaysEntry("You remembered a name of the old line. The dead are kept in the telling.", Utility.GetCurrentGameTime() as Int, "substrate.act", "tu-whacca", False)
    SendPrismaToast("tuwhacca", "good", "Remembering of Names", "The observance settles into you.")
    Trace(2, "Redguard Remembering observance applied: " + index)
EndFunction

Function RemoveRedguardRememberSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell obs = GetRedguardRememberSpell(i)
        if obs && playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetRedguardRememberSpell(Int index)
    if index == 0
        return PDV_SPEL_RedguardRemember_Blade
    elseIf index == 1
        return PDV_SPEL_RedguardRemember_Road
    elseIf index == 2
        return PDV_SPEL_RedguardRemember_Rest
    elseIf index == 3
        return PDV_SPEL_RedguardRemember_Harvest
    endIf
    return None
EndFunction

; The observance holds while the sect it was named under is settled. During a sect switch
; (committed sect differs from the one named at rite) it goes quiet at dawn and returns at
; dawn once the sect settles. PDV.RedRemember.Active stays set while quiet.
Function SyncRedguardRemembering(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.RedRemember.Active")
    if active <= 0
        return
    endIf
    Spell obs = GetRedguardRememberSpell(active - 1)
    if !obs
        return
    endIf

    Int sectAtRite = StorageUtil.GetIntValue(None, "PDV.RedRemember.SectAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD) && IsRedguardRememberingCoherent(sectAtRite)
    if eligible
        if !playerRef.HasSpell(obs)
            playerRef.AddSpell(obs, False)
            SendPrismaToast("tuwhacca", "good", "The old line settles", "Your observance returns.")
        endIf
    else
        if playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
            SendPrismaToast("tuwhacca", "warning", "The observance goes quiet", "The line you named it under has shifted.")
        endIf
    endIf
EndFunction

Bool Function IsRedguardRememberingCoherent(Int sectAtRite)
    if !PDV_RedguardSectTrack
        return false
    endIf
    if PDV_RedguardSectTrack.GetCurrentState() != sectAtRite
        return false
    endIf
    return true
EndFunction

; The Disciplines of Return: at rest, with a 7-day cooldown, the player sets one cultivation
; discipline of magic. One-active, swap via re-rite (clear-before-add). "Not yet" does not
; spend the cooldown. Returns true when the menu was shown so the dream is suppressed that
; night. The handler guard already blocks this while curse-suppressed.
Bool Function TryAltmerDisciplinesRite(Actor playerRef, String reason)
    if !playerRef || !PDV_MESG_AltmerDisciplines || !IsAltmerOrigin()
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.Alt.Disc.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_AltmerDisciplines.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyAltmerDiscipline(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two disciplines at once. Coherence reads current crisis state at
; dawn (no snapshot needed), so SyncAltmerDisciplines fades/restores on a crisis break.
Function ApplyAltmerDiscipline(Actor playerRef, Int index)
    RemoveAltmerDisciplineSpells(playerRef)
    Spell chosen = GetAltmerDisciplineSpell(index)
    if !chosen
        return
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.Alt.Disc.Active", index + 1)
    StorageUtil.SetFloatValue(None, "PDV.Alt.Disc.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Auri-El pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    AwardPiety(PDV_AuriEl, 0.5, "Set a Discipline of Return")
    AppendBookOfDaysEntry("You set a discipline of the Return. The road back is walked daily.", Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False)
    SendPrismaToast("auriel", "good", "Discipline of Return", "It holds while you hold to the path.")
    Trace(2, "Altmer Discipline of Return applied: " + index)
EndFunction

Function RemoveAltmerDisciplineSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell disc = GetAltmerDisciplineSpell(i)
        if disc && playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetAltmerDisciplineSpell(Int index)
    if index == 0
        return PDV_SPEL_AltmerDiscipline_Alteration
    elseIf index == 1
        return PDV_SPEL_AltmerDiscipline_Destruction
    elseIf index == 2
        return PDV_SPEL_AltmerDiscipline_Illusion
    elseIf index == 3
        return PDV_SPEL_AltmerDiscipline_Restoration
    endIf
    return None
EndFunction

; The discipline holds while the player is coherent (no unresolved crisis and not curse-
; suppressed). On a crisis break it goes quiet at dawn and returns at dawn on resolution.
; PDV.Alt.Disc.Active stays set while quiet so no re-rite is needed.
Function SyncAltmerDisciplines(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.Alt.Disc.Active")
    if active <= 0
        return
    endIf
    Spell disc = GetAltmerDisciplineSpell(active - 1)
    if !disc
        return
    endIf

    Bool eligible = IsAltmerOrigin() && IsAltmerDisciplineCoherent()
    if eligible
        if !playerRef.HasSpell(disc)
            playerRef.AddSpell(disc, False)
            SendPrismaToast("auriel", "good", "Coherence restored", "The discipline holds again.")
        endIf
    else
        if playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
            SendPrismaToast("auriel", "warning", "The discipline goes quiet", "You have wandered from coherence.")
        endIf
    endIf
EndFunction

Bool Function IsAltmerDisciplineCoherent()
    if IsAltmerFavorSuppressedByCurse()
        return false
    endIf
    Int crisis = GetAltmerCrisisState()
    if crisis == ALTMER_CRISIS_NONE || crisis == ALTMER_CRISIS_SCARRED_RESOLVED
        return true
    endIf
    return false
EndFunction

Function HandleAltmerSleepEvents(Actor playerRef, String reason)
    if !playerRef || !IsAltmerOrigin() || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    if TryAltmerDisciplinesRite(playerRef, reason)
        return                          ; Disciplines menu shown; suppress the dream this wake
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerAncestralDream")
    if multiplier <= 0.0
        return
    endIf

    AwardAltmerAncestorSpinePulse(multiplier, "sleep_dream_" + reason)
    if _activeDeity == PDV_Magnus && PDV_Magnus
        AwardAltmerDawnSignal("magnus_sleep_dream_" + reason, multiplier)
    endIf
    ShowP2BookNotice("po3_book_altmer_sleep_dream", "Aldmeri dream", "The old line keeps its shape through rest.")
EndFunction

Function HandleImperialSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ImperialCivicRest")
    if multiplier <= 0.0
        return
    endIf

    AwardImperialAncestorSpinePulse(multiplier, "sleep_rest_" + reason)
EndFunction

Function HandleBretonSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonAncestralDream")
    if multiplier <= 0.0
        return
    endIf

    AwardBretonAncestorSpinePulse(multiplier, "sleep_dream_" + reason)
    if GetBretonTraditionValue() != BRETON_TRADITION_HIDDEN_ART
        return
    endIf
    if PDV_Julianos
        AwardCuratedSignalScaled(PDV_Julianos, PDV_Julianos.SIGNAL_LAWFUL_ORDER, None, multiplier)
    endIf
    ShowP2BookNotice("po3_book_breton_sleep_reflection", "Hidden reflection", "Rest gives the Hidden Art a lawful shape.")
EndFunction

; Mara's Mercy scripted heal-on-rest was retired 2026-07-06. It was the second
; half of the Mara reward but not a real passive effect (an event-driven
; RestoreActorValue that never showed in Active Effects and, being Imperial-gated,
; never fired on the reused Nord lane). It is replaced by a passive Resist Magic
; effect on PDV_Bless_Imperial_Mara_T2/T3 (see PDV_ImperialRewardRecords.spec.json),
; so Mara now reads as two Requiem-felt passives -- Restoration + Resist Magic --
; identically for Imperial and Nord patrons.

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
            SendPrismaToast("hist", "good", "Rooted rest", "You wake feeling rooted.")
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
        SendPrismaToast("hist", "good", "Place of rest", "The Hist remembers it now.")
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
    SendPrismaShiftToast("The Hist has reshaped you.", "", "hist")
    AppendBookOfDaysEntry("You took the Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its image.", Utility.GetCurrentGameTime() as Int, "reorientation", "hist", True, 3)
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
            SendPrismaToast("hist", "warning", "The root grows quiet", "The change fades from your scales.")
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
    AppendBookOfDaysEntry("A water that remembers.", Utility.GetCurrentGameTime() as Int, "substrate.act", "hist", False)

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
        AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    Float peopleRelation = PDV_ArgonianHistSubstrate.GetPeopleRelation()
    Float voidRelation = PDV_ArgonianHistSubstrate.GetVoidRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) == ARGONIAN_FOCUS_PEOPLE
        HandleArgonianPeopleSupport("near_water_people")
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

; DEBUG seeder for beta testing the substrate-gated Argonian features. Use the
; MCM debug page or the SetPQV poll harness declared at the top of this script;
; do not route tester instructions through cqf.
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
            SendPrismaToast("yffre", "good", "Hearth declared", "This is where your stories come home now.")
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
            SendPrismaToast("yffre", "good", "Tale carried", "You told the tale, and the telling settled.")
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
    SendPrismaToast("yffre", "good", "Naming", "You tell yourself anew. The shape settles into you.")
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
            SendPrismaToast("yffre", "good", "Told-self restored", "You are yourself again.")
        endIf
    else
        if playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
            SendPrismaToast("yffre", "warning", "The told-self goes quiet", "You have wandered from its path.")
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

    SendPrismaToast("yffre", "neutral", "Green dream", GetBosmerDreamText(GetBosmerPathState()))
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
; (for the Hearth discovery delta), awards the curated Songs sites once each,
; and dispatches the narrower Y'ffre green-site fanout for the signal floor.
; Eldergleam, Gildergreen, and the Tree Stone are held for bounded polls so
; broad parent locations do not fire before the player reaches the actual site.
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

    Bool armEldergleam = False
    if loc.GetFormID() == 0x000192AC
        armEldergleam = True
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", BoolToInt(armEldergleam))

    Bool armGildergreen = False
    if loc.GetFormID() == 0x00018A56
        armGildergreen = True
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", BoolToInt(armGildergreen))

    Bool armTreeStone = IsLocationFromFile(loc, 0x000142B6, "Dragonborn.esm")
    StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", BoolToInt(armTreeStone))

    if armEldergleam || armGildergreen || armTreeStone
        return
    endIf

    ; Temple of Kynareth interior (0x0001F87D) stays the Gildergreen song's FLST
    ; slot id (milestone-of-6 count + Naming-at-songs check), but the vision must
    ; NOT fire inside the temple -- suppress the interior direct award; the
    ; Gildergreen poll awards slot 0x0001F87D at the tree instead.
    if loc.GetFormID() == 0x0001F87D
        return
    endIf

    TryAwardBosmerYffreLocationSite(loc)

    if PDV_FLST_BosmerGreenSongs && PDV_FLST_BosmerGreenSongs.HasForm(loc)
        AwardBosmerSong(loc.GetFormID())
    endIf
EndFunction

Bool Function TryAwardBosmerYffreLocationSite(Location loc)
    if IsLocationFromFile(loc, 0x00003583, "Dawnguard.esm")
        return TryAwardBosmerYffreGreenSite("ancestor_glade", "location_ancestor_glade")
    elseIf IsLocationFromFile(loc, 0x000142DF, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_wind", "location_allmaker_wind")
    elseIf IsLocationFromFile(loc, 0x000142DE, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_water", "location_allmaker_water")
    elseIf IsLocationFromFile(loc, 0x000142DC, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_sun", "location_allmaker_sun")
    elseIf IsLocationFromFile(loc, 0x000142A4, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_earth", "location_allmaker_earth")
    elseIf IsLocationFromFile(loc, 0x00014296, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_beast", "location_allmaker_beast")
    endIf

    return False
EndFunction

Bool Function IsLocationFromFile(Location loc, Int sourceFormId, String pluginName)
    if !loc
        return False
    endIf

    Location expectedLoc = Game.GetFormFromFile(sourceFormId, pluginName) as Location
    if !expectedLoc
        return False
    endIf

    return loc == expectedLoc
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

    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Bool songSeen = StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.103084") == 1
    Bool yffreSeen = StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.eldergleam") == 1
    if songSeen && yffreSeen
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Cell parentCell = Game.GetPlayer().GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        if !songSeen
            AwardBosmerSong(0x000192AC)
        endIf
        TryAwardBosmerYffreGreenSite("eldergleam", "location_eldergleam")
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
ObjectReference _bosYffreTreeStoneRef

Function TryBosmerGildergreenProximity()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.GildergreenActive") != 1
        return
    endIf
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
        return
    endIf

    Bool songSeen = StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.129149") == 1
    Bool yffreSeen = StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.gildergreen") == 1
    if songSeen && yffreSeen
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
        if !songSeen
            AwardBosmerSong(0x0001F87D)
        endIf
        TryAwardBosmerYffreGreenSite("gildergreen", "location_gildergreen")
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
    endIf
EndFunction

Function TryBosmerYffreTreeStoneProximity()
    if StorageUtil.GetIntValue(None, "PDV.Yffre.TreeStoneActive") != 1
        return
    endIf
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.allmaker_tree") == 1
        StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", 0)
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Cell parentCell = playerRef.GetParentCell()
    if !parentCell || parentCell.IsInterior()
        return
    endIf

    if !_bosYffreTreeStoneRef
        _bosYffreTreeStoneRef = Game.GetFormFromFile(0x00026EEC, "Dragonborn.esm") as ObjectReference
    endIf
    if !_bosYffreTreeStoneRef
        return
    endIf

    if playerRef.GetDistance(_bosYffreTreeStoneRef) < 700.0
        TryAwardBosmerYffreGreenSite("allmaker_tree", "location_allmaker_tree")
        StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", 0)
    endIf
EndFunction

Bool Function TryAwardBosmerYffreGreenSite(String siteKey, String reason)
    String seenKey = "PDV.Yffre.Seen." + siteKey
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return False
    endIf

    if !ConsumeOncePerDaySignal("PDV.Signal.YffreGreenSite")
        Trace(2, "Y'ffre green site capped for today: " + siteKey)
        return False
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    StorageUtil.AdjustIntValue(None, "PDV.Yffre.SiteCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Yffre.LastSite", siteKey)
    StorageUtil.SetFloatValue(None, "PDV.Yffre.LastSiteTime", Utility.GetCurrentGameTime())
    HandleBosmerLivingStoryNatureSite(reason)
    Trace(2, "Y'ffre green site remembered: " + siteKey)
    return True
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
    Debug.MessageBox("For a breath, the Story enfolds you and names you a part of it. This place still holds the blessings of Y'ffre.")

    if PDV_FLST_BosmerGreenSongs && seenCount >= PDV_FLST_BosmerGreenSongs.GetSize()
        StorageUtil.SetIntValue(None, "PDV.BosSongs.Milestone", 1)
        Debug.MessageBox("Every Green Song is known to you now. Wherever the road goes, the Story travels with you.")
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
    SendPrismaToast("zenithar", "good", "Scales at rest", "The bargains fall your way for a while.")
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
    HandleBosmerBanditRoadReversal("baandar_gap_low_health")
    SendPrismaToast("baandar", "good", "Baan Dar opens the gap", "Run.")
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
    HandleArgonianVoidSignal("near_death_burst")
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

    ; The Code Holds is a near-death survival pulse. Its old HealRate spell is not
    ; cast because Requiem swallows rate-mult healing on a near-zero base; the
    ; actual health save is a flat RestoreActorValue. Requiem-proof.
    if malacathTier >= TIER_DEVOTED && PDV_SPEL_OrcCodeHolds_Devoted
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf PDV_SPEL_OrcCodeHolds
        playerRef.RestoreActorValue("Health", 40.0)
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCodeHolds")
    if multiplier > 0.0
        AwardPiety(PDV_Malacath, 0.5 * multiplier)
    endIf
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
        SendPrismaToast(GetPrismaSymbolForDeity(PDV_Yffre), "warning", "Green Pact broken", "You crossed Y'ffre's creed, and the path recoils.")
        SurfaceTransition("creed", "Green Pact", "drop", PDV_Yffre.DeityIndex, "absence", True)
    endIf

    Trace(2, "Green Pact violation count " + violationCount + " (" + reason + ")")
EndFunction

Function HandleBosmerLivingStorySignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerLivingStory")
    if multiplier <= 0.0
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_LIVING_STORY, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_LIVING_STORY && PDV_Yffre
        AwardCuratedSignalScaled(PDV_Yffre, PDV_Yffre.SIGNAL_LIVING_STORY, None, multiplier)
    endIf
EndFunction

Function HandleBosmerExchangeSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerExchange")
    if multiplier <= 0.0
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_EXCHANGE, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_EXCHANGE && PDV_Zen
        AwardCuratedSignalScaled(PDV_Zen, PDV_Zen.SIGNAL_EXCHANGE, None, multiplier)
    endIf

    TryBosmerScalesAtRest(Game.GetPlayer())
EndFunction

Function HandleBosmerBanditRoadSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerBanditRoad")
    if multiplier <= 0.0
        return
    endIf

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_BANDIT_ROAD, reason)
    if PDV_BosmerPathTrack.GetCurrentState() == BOSMER_PATH_BANDIT_ROAD && PDV_BaanDar
        AwardCuratedSignalScaled(PDV_BaanDar, PDV_BaanDar.SIGNAL_BANDIT_ROAD, None, multiplier)
    endIf
EndFunction

Function HandleBosmerPactPositiveSignal(String reason)
    if !IsBosmerOrigin() || !PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerPactPositive")

    PDV_BosmerPathTrack.RecordEvidenceDay(BOSMER_PATH_OLD_CONTRACT, reason)
    if IsBosmerPactBound()
        AdjustBosmerGreenPactCompliance(5, reason)
        if PDV_Yffre && multiplier > 0.0
            AwardCuratedSignalScaled(PDV_Yffre, PDV_Yffre.SIGNAL_PACT_POSITIVE, None, multiplier)
        endIf
        return
    endIf

    if multiplier > 0.0
        Int currentPath = PDV_BosmerPathTrack.GetCurrentState()
        if currentPath == BOSMER_PATH_LIVING_STORY && PDV_Yffre
            AwardCuratedSignalScaled(PDV_Yffre, PDV_Yffre.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        elseIf currentPath == BOSMER_PATH_EXCHANGE && PDV_Zen
            AwardCuratedSignalScaled(PDV_Zen, PDV_Zen.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        elseIf currentPath == BOSMER_PATH_BANDIT_ROAD && PDV_BaanDar
            AwardCuratedSignalScaled(PDV_BaanDar, PDV_BaanDar.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        endIf
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
            AwardDunmerAncestorSpinePulse(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "Ancestor prayer marked.", "ancestor", GetDunmerAncestorLayerLabel())
        else
            Trace(2, "Dunmer ancestor layer silenced by curse posture (" + reason + ")")
        endIf
        NotifyDiegeticRoutineFavor("dunmer_portable_shrine")
        TryAwardDunmerTwilightWindowSignal(reason)
        AwardActiveDunmerReclamationMemorySignal()
        ; Home-prayer bonus (11a, reworked 2026-07-04): praying with the portable urn at
        ; your declared ancestor-home fires the bigger home progress step + arms the
        ; ancestor watch (once-per-day near-death save until dawn).
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
            AwardDunmerAncestorSpinePulse(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "Prayers within the home feel more meaningful.", "ancestor", GetDunmerAncestorLayerLabel())
            ; Ancestor watch (11a rework 2026-07-04): the home prayer no longer heals on
            ; the spot; it arms a once-per-day near-death save that lasts until dawn (the
            ; BaanDar-style low-health watcher, PDV_T3DailyLowHealthSaveEffect on the
            ; PDV_SPEL_Dunmer_AncestorWatch ability). ProcessDawn disarms it, so each
            ; day's protection must be re-earned with a fresh home prayer.
            Actor homePlayer = Game.GetPlayer()
            if homePlayer && PDV_SPEL_Dunmer_AncestorWatch && !homePlayer.HasSpell(PDV_SPEL_Dunmer_AncestorWatch)
                homePlayer.AddSpell(PDV_SPEL_Dunmer_AncestorWatch, False)
                Trace(2, "Dunmer ancestor watch armed (" + reason + ")")
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

Function DisarmDunmerAncestorWatch()
    ; The home-prayer ancestor watch lasts until dawn; remove it so each day's
    ; near-death protection must be re-earned with a fresh home prayer. The watcher
    ; script's own StorageUtil day-guard keeps the save once-per-day regardless.
    if !PDV_SPEL_Dunmer_AncestorWatch
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if playerRef && playerRef.HasSpell(PDV_SPEL_Dunmer_AncestorWatch)
        playerRef.RemoveSpell(PDV_SPEL_Dunmer_AncestorWatch)
        Trace(2, "Dunmer ancestor watch released at dawn.")
    endIf
EndFunction

; Declare the player's Dunmer ancestor-home from sleep, keyed to the cell rather
; than the bed reference. First homes ask immediately; moving to a new place
; requires three consecutive sleeps in the same non-home cell so a one-night inn
; stop does not steal the rite.
Function HandleDunmerSleepEvents(Actor playerRef, String reason)
    if !PDV_DunmerAncestorSubstrate || !playerRef
        return
    endIf
    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return
    endIf

    Int sleepCellId = sleepCell.GetFormID()
    Int today = Utility.GetCurrentGameTime() as Int
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

    if !PDV_MESG_DunmerMarkHome
        if declaredId == 0
            SetDunmerHome(sleepCellId, today, reason)
        endIf
        return
    endIf

    Int declinedDay = StorageUtil.GetIntValue(None, "PDV.DunHome.DeclineDay")
    if declinedDay > 0 && (today + 1 - declinedDay) < 3
        return
    endIf

    Bool shouldPrompt = declaredId == 0
    if declaredId != 0
        Int candidateId = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateFormID")
        Int candidateCount = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateCount")
        if candidateId != sleepCellId
            candidateCount = 1
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", sleepCellId)
        else
            candidateCount += 1
        endIf
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", candidateCount)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", today + 1)
        shouldPrompt = candidateCount >= 3
    endIf

    if !shouldPrompt
        return
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_DunmerMarkHome.Show()
    if pressed == 0
        SetDunmerHome(sleepCellId, today, reason)
    else
        StorageUtil.SetIntValue(None, "PDV.DunHome.DeclineDay", today + 1)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    endIf
EndFunction

Function SetDunmerHome(Int sleepCellId, Int today, String reason)
    if sleepCellId == 0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredDay", today + 1)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    SendPrismaToast("ancestor", "good", "Ancestor-space", "The ancestors will know this place.")
    Trace(2, "Dunmer ancestor-home declared: " + reason)
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
        AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, multiplier)
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
        AwardCuratedSignalScaled(PDV_Khenarthi, PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, multiplier, "The road home was remembered.", "lunar", GetKhajiitLunarTierLabel(tierAfter))
    NotifyDiegeticRoutineFavor("khajiit_road_home")
    RequestPanelRefresh()
    Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier + " anchor " + anchorId)
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_BAANDAR, "PDV.Signal.KhajiitBaanDarRoadTrick", "Baan Dar road trick", reason)
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", "Rajhin elegant theft", reason)
    ; Night theft is shadow-coded behavior; it accrues toward the ShadowDrift boundary.
    RecordKhajiitShadowEvidence("rajhin_night_theft_" + reason)
    SendPrismaShiftToast("Elegant theft", "Rajhin purrs.", GetKhajiitFocusSymbol(KHAJIIT_FOCUS_RAJHIN))
    RecordRecentDevotionEvent("Rajhin: theft with style")
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh dragon order", reason)
EndFunction

Function HandleKhajiitFocusedSource(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue == KHAJIIT_FOCUS_NONE
        focusValue = GetActiveLunarFavoredFocus()
    endIf
    if focusValue == KHAJIIT_FOCUS_NONE
        focusValue = KHAJIIT_FOCUS_AZURAH
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

Function HandleKhajiitFocusedSourceForFocus(Int focusValue, String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    if focusValue < KHAJIIT_FOCUS_KHENARTHI || focusValue > KHAJIIT_FOCUS_ALKOSH
        HandleKhajiitFocusedSource(reason)
        return
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

; Named-dragon kill: the focus signal plus the curated named-dragon beat. The
; kill receiver one-shots each named ActorBase, so the large beat cannot repeat.
Function HandleKhajiitAlkoshNamedDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = RecordKhajiitFocusSignal(KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh named dragon", reason)
    if PDV_Alkosh
        AwardCuratedSignalScaled(PDV_Alkosh, PDV_Alkosh.SIGNAL_NAMED_DRAGON, None, multiplier)
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
        AwardCuratedSignalScaled(PDV_BaanDar, PDV_BaanDar.SIGNAL_BANDIT_ROAD, None, multiplier)
    endIf
    Trace(1, "Khajiit Baan Dar near-fatal reversal routed (" + reason + ")")
EndFunction

Float Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)
    if !IsKhajiitOrigin()
        return 0.0
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier(keyPrefix)
    StorageUtil.AdjustIntValue(None, keyPrefix + ".CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    AdjustKhajiitFocusedEmphasis(focusValue, KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    PulseKhajiitFocusPiety(focusValue, multiplier)
    Trace(2, "Khajiit " + label + " routed with multiplier " + multiplier)
    return multiplier
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
Function PulseKhajiitFocusPiety(Int focusValue, Float multiplier)
    if focusValue == KHAJIIT_FOCUS_KHENARTHI && PDV_Khenarthi
        AwardCuratedSignalScaled(PDV_Khenarthi, PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    elseIf focusValue == KHAJIIT_FOCUS_AZURAH && PDV_Azura
        AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, multiplier)
    elseIf focusValue == KHAJIIT_FOCUS_BAANDAR && PDV_BaanDar
        AwardCuratedSignalScaled(PDV_BaanDar, PDV_BaanDar.SIGNAL_ROAD_TRICK, None, multiplier)
    elseIf focusValue == KHAJIIT_FOCUS_RAJHIN && PDV_Rajhin
        AwardCuratedSignalScaled(PDV_Rajhin, PDV_Rajhin.SIGNAL_ELEGANT_THEFT, None, multiplier)
    elseIf focusValue == KHAJIIT_FOCUS_ALKOSH && PDV_Alkosh
        AwardCuratedSignalScaled(PDV_Alkosh, PDV_Alkosh.SIGNAL_DRAGON_ORDER, None, multiplier)
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

Function HandlePaarthurnaxKill(Form sourceForm, String reason)
    String killKey = "PDV.Paarthurnax.KillSeen"
    if StorageUtil.GetIntValue(None, killKey, 0) == 1
        Trace(2, "Paarthurnax kill repeat blocked (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, killKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Paarthurnax.KillReason", reason)
    ResetQuestReactionSurface()
    ApplyPaarthurnaxKillReaction("Shor", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Tsun", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Kyne", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Stendarr", "C", sourceForm)
    ApplyPaarthurnaxKillReaction("Stuhn", "C", sourceForm)
    ApplyPaarthurnaxKillReaction("Mara", "S", sourceForm)
    FlushQuestReactionSurface()
    Trace(2, "Paarthurnax kill fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxKillReaction(String deityName, String intensity, Form sourceForm)
    ApplyDeityReaction(deityName, "-", intensity, "small", "paarthurnax_kill", False, sourceForm)
EndFunction

Function HandlePaarthurnaxSpare(Form sourceForm, String reason)
    String spareKey = "PDV.Paarthurnax.SpareSeen"
    if StorageUtil.GetIntValue(None, spareKey, 0) == 1
        Trace(2, "Paarthurnax spare repeat blocked (" + reason + ")")
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Paarthurnax.KillSeen", 0) == 1
        Trace(2, "Paarthurnax spare blocked because kill fork already fired (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, spareKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Paarthurnax.SpareReason", reason)
    ResetQuestReactionSurface()
    ApplyPaarthurnaxSpareReaction("Stuhn", "C", sourceForm)
    ApplyPaarthurnaxSpareReaction("Stendarr", "C", sourceForm)
    ApplyPaarthurnaxSpareReaction("Mara", "S", sourceForm)
    ApplyPaarthurnaxSpareReaction("Kyne", "m", sourceForm)
    FlushQuestReactionSurface()
    Trace(2, "Paarthurnax spare fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxSpareReaction(String deityName, String intensity, Form sourceForm)
    ApplyDeityReaction(deityName, "+", intensity, "small", "paarthurnax_spare", False, sourceForm)
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

    if newPosture == KHAJIIT_LUNAR_POSTURE_CORRUPTED
        AppendBookOfDaysEntry("The moonlight scatters from your path. Corruption is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
    elseIf newPosture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        AppendBookOfDaysEntry("You slipped into the moons' shadow. Darkness is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
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
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal
        SendPrismaToast("lunar", "warning", "", fallbackText)
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
    ; the universal piety layer (decay/neglect/creed-loss) honest.
    if PDV_Hist
        AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
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
        AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
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
        AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
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
        AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    if PDV_Sithis && PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        AwardCuratedSignalScaled(PDV_Sithis, PDV_Sithis.SIGNAL_VOID_THRESHOLD, None, multiplier)
    endIf
    ; Void overreach: leaning deep into the Void (fully active) while Hist maintenance has
    ; lapsed below its non-curse floor is the curated major loss for the Hist.
    if PDV_ArgonianHistSubstrate.IsVoidFullyActive() && PDV_ArgonianHistSubstrate.GetHistRelation() <= PDV_ArgonianHistSubstrate.HistNonCurseFloor
        EmitHistVoidOverreachMinus(reason)
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
            Int newPosture = PDV_ArgonianHistSubstrate.GetHistPosture()
            if newPosture == PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
                EmitHistCorruptionMinus(reason)
            elseIf newPosture == PDV_ArgonianHistSubstrate.HIST_POSTURE_DISTANT
                EmitHistAbandonmentMinus(reason)
            endIf
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
    AwardOrcStrongholdForgeSignal(multiplier)
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

Function HandleNordLocationChange(Location newLocation)
    if !newLocation || GetPlayerOriginRaceIndex() != ORIGIN_NORD || !PDV_NordAncestorSubstrate
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(Game.GetPlayer(), "PDV.Nord.HearthRest.DeclaredFormID")
        return
    endIf

    if !ConsumeOncePerDaySignal("PDV.Signal.NordHearthReturn")
        return
    endIf

    RecordNordHearthReturn("location_hearth_return", 1.0)
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
    AwardOrcCityDignitySignal(multiplier)
    Trace(2, "Orc City dignity routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLegionService(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcLegionService")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_LEGION_EXILE, multiplier, reason)
    AwardOrcLegionServiceSignal(multiplier)
    Trace(2, "Orc Legion or exile service routed with multiplier " + multiplier)
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    if !IsOrcOrigin() || !PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcSelfMadeCommunity")
    RecordOrcLifeModeSignal(ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcSelfMadeCommunitySignal(multiplier)
    if multiplier > 0.0
        MaybeShowOrcHearthHeldNotice(reason)
    endIf
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
    AwardOrcBroadConductSignal(multiplier)
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
    AwardOrcAncestorSpineSignal(1.0, reason)

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

    AwardOrcAncestorSpineSignal(multiplier, reason)
    MaybeShowOrcWatchersNotice(modeValue, reason)

    if PDV_OrcLifeModeTrack.GetCurrentState() == modeValue
        SendPrismaSubstrateToast(GetOrcLifeModeSubstrateToken(modeValue), "act", "The code was marked.", "malacath", GetOrcLifeModeLabel())
        AppendBookOfDaysEntry("The code was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
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
    if PDV_OrcLifeModeTrack.GetCurrentState() == ORC_LIFE_MODE_LEGION_EXILE && modeValue != ORC_LIFE_MODE_LEGION_EXILE
        EmitMalacathBrokenFaithKinMinus("desert_legion_exile_" + reason)
    endIf
    PDV_OrcLifeModeTrack.SetState(modeValue, reason)
    PDV_OrcLifeModeTrack.SetTransitionLockout(3.0, reason)
    Int deityIndex = -1
    if PDV_Malacath
        deityIndex = PDV_Malacath.DeityIndex
    endIf
    SurfaceTransition("reorientation", GetOrcLifeModeLabel(), "shift", deityIndex, "turning")
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
        ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")
        RequestPanelRefresh()
    endIf
EndFunction

Function AwardOrcStrongholdForgeSignal(Float multiplier)
    if PDV_Malacath
        AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, None, multiplier)
    endIf
EndFunction

Function AwardOrcCityDignitySignal(Float multiplier)
    if PDV_Malacath
        AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_CITY_DIGNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcLegionServiceSignal(Float multiplier)
    if PDV_Malacath
        AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_LEGION_SERVICE, None, multiplier)
    endIf
EndFunction

Function AwardOrcSelfMadeCommunitySignal(Float multiplier)
    if PDV_Malacath
        AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcBroadConductSignal(Float multiplier)
    if PDV_Malacath
        AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_BROAD_CONDUCT, None, multiplier)
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

Function AwardOrcAncestorSpineSignal(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_ORC || !PDV_Malacath || multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastAncestorSpineTime", Utility.GetCurrentGameTime())
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

Bool Function ConsumeDailyOrcNotice(String noticeKey)
    Int dayIndex = Utility.GetCurrentGameTime() as Int
    String storageKey = "PDV.Orc.Notice." + noticeKey + ".Day"
    if StorageUtil.GetIntValue(None, storageKey, -1) == dayIndex
        return False
    endIf

    StorageUtil.SetIntValue(None, storageKey, dayIndex)
    return True
EndFunction

Function MaybeShowOrcWatchersNotice(Int modeValue, String reason)
    if !ConsumeDailyOrcNotice("Watchers")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastWatchersNoticeReason", reason)
    ShowOrcNotification(GetOrcWatchersNotice(modeValue), GetOrcWatchersFallback(modeValue))
EndFunction

Message Function GetOrcWatchersNotice(Int modeValue)
    if modeValue == ORC_LIFE_MODE_STRONGHOLD
        return PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold
    elseIf modeValue == ORC_LIFE_MODE_LEGION_EXILE
        return PDV_Notif_Orc_Witnessed_TheWatchers_LegionExile
    endIf

    return PDV_Notif_Orc_Witnessed_TheWatchers_City
EndFunction

String Function GetOrcWatchersFallback(Int modeValue)
    if modeValue == ORC_LIFE_MODE_STRONGHOLD
        return "The Watchers see the stronghold work. The code has witnesses."
    elseIf modeValue == ORC_LIFE_MODE_LEGION_EXILE
        return "The Watchers see the burden carried away from the hold. The code has witnesses."
    endIf

    return "The Watchers see the code kept under city stone. The code has witnesses."
EndFunction

Function MaybeShowOrcHearthHeldNotice(String reason)
    if StorageUtil.GetIntValue(None, "PDV.Orc.HearthHeldDeclared") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.HearthHeldDeclared", 1)
        StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldDeclareReason", reason)
        ShowOrcNotification(PDV_Notif_Orc_HearthHeld_Declare, "A hearth held by choice is declared. The code has a place to stand.")
        return
    endIf

    if !ConsumeDailyOrcNotice("HearthHeldReturn")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldReturnReason", reason)
    ShowOrcNotification(PDV_Notif_Orc_HearthHeld_Return, "You return to the hearth you hold. The code remembers the place.")
EndFunction

Function MaybeShowOrcHearthHeldMissedCadenceNotice()
    if !ConsumeDailyOrcNotice("HearthHeldMissed")
        return
    endIf

    ShowOrcNotification(PDV_Notif_Orc_HearthHeld_MissedCadence, "The held hearth has gone quiet. The code presses for proof.")
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
    AwardRedguardCrownSignal(multiplier, reason)
    Trace(2, "Redguard Crown tomb respect routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")
    RecordRedguardSectSignal(REDGUARD_SECT_FOREBEAR, multiplier, reason)
    AwardRedguardForebearSignal(multiplier)
    Trace(2, "Redguard Forebear road passage routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")
    RecordRedguardSectSignal(REDGUARD_SECT_ASHABAH, multiplier, reason)
    ApplyRedguardAshAbahDutyRewards(reason, multiplier)
    Trace(2, "Redguard AshAbah death duty routed with multiplier " + multiplier)
EndFunction

; Marked Ash'abah death-burden -- the wiring that makes mid-game Ash'abah sect ENTRY
; reachable. Design intent (PDV_OpenDecisions_RulingMemo / TargetEndStates): "Ash'abah is
; entered only by a marked death/funerary burden -- major tombs, major necromancer
; operations, lich/named-undead defeats, costly impurity choices." Routine death-duty
; (HandleRedguardAshAbahDeathDuty, reason "eventbus_<N>") deepens stigma + heals but NEVER
; switches sect, by design: RecordRedguardSectSignal gates the Ash'abah switch on
; IsRedguardAshAbahBurden, which the routine reason never satisfies -- the same
; exact-match-on-an-unproduced-token failure class as the P2 book-notice suffix bug
; (the gate was correct; no emit site ever PRODUCED the marked token). This emitter is the
; missing producer: the defeat of a UNIQUE (named/boss) undead -- the clean, iconic
; lich/named-undead moment, the undead analog of HoonDing's dragon make-way -- routes a
; death-duty with reason "redguard_deathduty_major", which the gate accepts, so a genuine
; named-undead defeat marks sect entry. V1 uses the in-engine Unique flag as the
; "named undead" signal (no new ESP record); routine draugr/skeletons are not Unique, so
; casual undead fighting still cannot switch sect ("casual undead fighting is not enough").
; The rest of the design list (major tombs, named necromancer leaders, costly impurity
; choices) needs curated FormLists / faction detection -- the deferred follow-up, the same
; class as HoonDing's deferred named-boss FormList (task #11). Independent daily anti-farm
; from routine duty so a real named-undead defeat reliably marks the burden even on a day
; routine death-duty already decayed. Called from PDV_ActionRouter.HandleStoryKillActor
; (the player's own killing blow only), alongside HandleHoonDingBreakthroughKill.
Function HandleRedguardAshAbahMajorBurden(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Actor victimActor = victimForm as Actor
    if !victimActor
        return
    endIf
    ActorBase victimBase = victimActor.GetLeveledActorBase()
    if !victimBase || !victimBase.IsUnique()
        return ; routine undead -- not a marked burden, no sect switch
    endIf

    String burdenReason = ""
    if eventType == 300 ; EVT_KILL_UNDEAD
        burdenReason = "redguard_deathduty_major"
    elseIf eventType == 2 && IsRedguardNamedNecromancerBurden(victimActor) ; EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
        burdenReason = "redguard_deathduty_major_necromancer"
    else
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahMajorBurden")
    if multiplier <= 0.0
        Trace(2, "Redguard Ash'abah major burden decayed out for today; no sect mark.")
        return
    endIf

    RecordRedguardSectSignal(REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Trace(2, "Redguard Ash'abah major burden fired: " + burdenReason + " marks sect entry (eventType=" + eventType + ").")
EndFunction

Function TrackRedguardAshAbahUndeadSiteVisit(Location currentLocation)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    if !currentLocation || !PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(currentLocation)
        return
    endIf

    if currentLocation.IsCleared()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahClearSiteArmed." + currentLocation.GetFormID(), 1)
EndFunction

Function HandleRedguardAshAbahUndeadSiteClear(Location clearedLocation)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    if !clearedLocation || !PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(clearedLocation)
        return
    endIf

    if !clearedLocation.IsCleared()
        return
    endIf

    String siteKey = "PDV.Redguard.AshAbahClearedSite." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, siteKey, 0) == 1
        return
    endIf

    String armKey = "PDV.Redguard.AshAbahClearSiteArmed." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, armKey, 0) != 1
        return
    endIf

    StorageUtil.SetIntValue(None, siteKey, 1)
    StorageUtil.SetIntValue(None, armKey, 0)
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahUndeadSiteClear")
    String burdenReason = "redguard_ashabah_burden_undead_site_clear"
    RecordRedguardSectSignal(REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Trace(2, "Redguard Ash'abah undead-site clear fired for location " + clearedLocation.GetFormID() + " multiplier=" + multiplier)
EndFunction

Function TrackUndeadCryptClearSiteVisit(Location currentLocation)
    if !currentLocation || !PDV_FLST_UndeadCryptClearSites
        return
    endIf

    if !PDV_FLST_UndeadCryptClearSites.HasForm(currentLocation)
        return
    endIf

    if currentLocation.IsCleared()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.UndeadCryptClear.Armed." + currentLocation.GetFormID(), 1)
EndFunction

Function HandleUndeadCryptSiteClear(Location clearedLocation)
    if !clearedLocation || !PDV_FLST_UndeadCryptClearSites
        return
    endIf

    if !PDV_FLST_UndeadCryptClearSites.HasForm(clearedLocation)
        return
    endIf

    if !clearedLocation.IsCleared()
        return
    endIf

    String siteKey = "PDV.UndeadCryptClear.Seen." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, siteKey, 0) == 1
        return
    endIf

    String armKey = "PDV.UndeadCryptClear.Armed." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, armKey, 0) != 1
        return
    endIf

    StorageUtil.SetIntValue(None, siteKey, 1)
    StorageUtil.SetIntValue(None, armKey, 0)
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.UndeadCryptClear")
    ApplyUndeadCryptClearReactions(clearedLocation, multiplier)
    Trace(2, "Undead crypt clear fired for location " + clearedLocation.GetFormID() + " multiplier=" + multiplier)
EndFunction

Function ApplyUndeadCryptClearReactions(Location clearedLocation, Float repeatMultiplier)
    if repeatMultiplier <= 0.0
        return
    endIf

    ResetQuestReactionSurface()
    ApplyUndeadCryptClearReaction("Arkay", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Meridia", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Stendarr", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Tu'whacca", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Azura", "m", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Y'ffre", "m", clearedLocation, repeatMultiplier)
    FlushQuestReactionSurface()
EndFunction

Function ApplyUndeadCryptClearReaction(String deityName, String intensity, Location clearedLocation, Float repeatMultiplier)
    PDV_DeityBase deity = GetQuestReactionDeity(deityName)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear skipped unknown deity: " + deityName)
        endIf
        return
    endIf

    Float amount = GetQuestReactionBaseValue("small", intensity) * repeatMultiplier
    if amount == 0.0
        return
    endIf

    String sourceTag = "undead_crypt_clear"
    String stance = GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastCurse", deityName + "." + sourceTag)
        HandleCurseStateRefresh("quest_reaction_" + deityName)
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear curse routed: " + deityName)
        endIf
        return
    endIf

    if stance == "TABOO" || stance == "HOSTILE"
        ApplyQuestReactionStigma(deity, amount, sourceTag)
        if !(deity as PDV_DaedricPathBase)
            AccumulateQuestReactionSurface(deity, amount * -1.0, "small")
        endIf
        return
    endIf

    if stance == "FOREIGN" || stance == "TOLERATED"
        if !IsQuestReactionDeityReachable(deity)
            if GetDebugLevel() >= 2
                Debug.Trace("[PDV] UndeadCryptClear skipped unreachable foreign deity: " + deityName)
            endIf
            return
        endIf
    endIf

    Float stanceMultiplier = 1.0
    if stance == "FOREIGN"
        stanceMultiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.FOREIGN", 0.4)
    elseIf stance == "TOLERATED"
        stanceMultiplier = JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.TOLERATED", 0.4)
    endIf

    Float appliedReactionAmount = amount * stanceMultiplier
    _suppressAwardFavorToast = True
    ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    _suppressAwardFavorToast = False
    AccumulateQuestReactionSurface(deity, appliedReactionAmount, "small")

    if IsKhajiitOrigin()
        BridgeKhajiitMatrixFocus(deityName, "small")
    endIf
EndFunction

Bool Function IsRedguardNamedNecromancerBurden(Actor victimActor)
    if !victimActor
        return False
    endIf

    if NecromancerFaction && victimActor.IsInFaction(NecromancerFaction)
        return True
    endIf

    if WarlockFaction && victimActor.IsInFaction(WarlockFaction)
        return True
    endIf

    return False
EndFunction

; Shared Ash'abah death-duty rewards (Tu'whacca death-rite signal + flat heal + social
; stigma), fired by both the routine duty and the marked major burden so the two paths
; cannot drift.
Function ApplyRedguardAshAbahDutyRewards(String reason, Float multiplier)
    AwardRedguardAshAbahSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    MarkRedguardAshAbahStigma(reason)
EndFunction

; Tu'whacca's Ward / Far Shores reward, converted from a swallowed always-on
; HealRateMult buff (a rate-mult on Requiem's ~0 base health-regen = unfelt) to a
; flat, event-driven death-rite restoration. Fires when a Tu'whacca death-rite is
; kept (death-duty or Far Shores token), scaled by Tu'whacca tier, once per day so
; repeated duty cannot farm it. Magnitudes PROVISIONAL -- tune against Requiem's
; health economy in-game (memory: requiem-proof-heal-flat-restore-not-rate).
Function TryRedguardTuwhaccaDeathRiteHeal(String reason)
    if !PDV_Tuwhacca
        return
    endIf

    Int tuwhaccaTier = GetTier(PDV_Tuwhacca)
    if tuwhaccaTier < TIER_DEVOTED
        return
    endIf

    Int healDay = (Utility.GetCurrentGameTime() as Int) + 1
    if StorageUtil.GetIntValue(None, "PDV.Redguard.TuwhaccaDeathRiteHealDay") == healDay
        Trace(2, "Redguard Tu'whacca death-rite heal suppressed (already restored today).")
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.TuwhaccaDeathRiteHealDay", healDay)

    Float deathRiteHeal = 30.0
    if tuwhaccaTier >= TIER_CHAMPION
        deathRiteHeal = 50.0
    endIf
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", deathRiteHeal)
    Trace(2, "Redguard Tu'whacca death-rite heal fired reason=" + reason + " tier=" + tuwhaccaTier + " restore=" + deathRiteHeal)
EndFunction

; Ash'abah social stigma -- text-only, modeled on the proven Altmer crisis surfacing
; (PDV_AltmerCrisisTrack / GetAltmerCrisisStateLabel) but WITHOUT any piety penalty
; (user ruling 2026-06-20). This is the Ash'abah death-duty handler (sect-2 routing
; only), so the duty act itself IS the burden -- every kept death-duty deepens the
; social stigma of the one who handles the unclean dead, paired with the Tu'whacca
; death-rite heal so the burden reads as earned. (NOTE: do NOT gate on
; IsRedguardAshAbahBurden -- the live reason is always "eventbus_<N>", never the
; marked-burden strings, so an exact-match gate would never fire. A routine-vs-major
; distinction the design wants will sharpen when major-burden sources are curated.)
; No service penalty, no voiced lines. The notice fires only on a band crossing so
; repeated duty does not spam the top-left.
Function MarkRedguardAshAbahStigma(String reason)
    Int before = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    Int stigma = before + 1
    if stigma > 5
        stigma = 5
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahStigma", stigma)

    if before < 3 && stigma >= 3
        ShowRedguardNotification(None, "The tomb-smell never fully leaves you now; the clean keep their distance from the one who tends the unclean dead.")
    elseIf before < 1 && stigma >= 1
        ShowRedguardNotification(None, "The mark of the death-duty settles on you. Few will carry this burden, and they know it when they see you.")
    endIf
    Trace(2, "Redguard Ash'abah stigma marked reason=" + reason + " stigma=" + stigma + " (was " + before + ")")
EndFunction

String Function GetAshAbahStigmaLabel()
    Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    if stigma >= 3
        return "hollow-eyed"
    elseIf stigma >= 1
        return "death-touched"
    endIf
    return "unmarked"
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
    AwardRedguardFarShoresSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    ShowRedguardNotification(PDV_Notif_Redguard_FarShoresToken_Activate, "You tend the Far Shores token and speak to Tu'whacca.")
    Trace(2, "Redguard Far Shores token routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAncestorSpine(String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAncestorSpine")
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    ShowP2BookNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")
    Trace(2, "Redguard ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardAncestralRest(Float multiplier, String reason)
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    Trace(2, "Redguard ancestral rest routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardAncestorSpinePulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || !PDV_RedguardSectTrack || multiplier <= 0.0
        return
    endIf

    EnsureRedguardSectInitialized()
    Int currentSect = PDV_RedguardSectTrack.GetCurrentState()
    RecordRedguardSectSignal(currentSect, multiplier, reason)
    AwardRedguardAncestorSpinePietyPulse(multiplier, reason)
    ShowRedguardNotification(PDV_Notif_Redguard_AncestorSpine_Rest, "The ancestor-line steadies behind you.")
    RequestPanelRefresh()
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
        AppendBookOfDaysEntry("The Yokudan path was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "sect", False)
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
        SurfaceTransition("reorientation", GetRedguardSectLabel(), "shift", -1, "turning")
        SendPrismaShiftToast(GetRedguardSectLabel(), "", "sect")
        RequestPanelRefresh()
    endIf
EndFunction

Bool Function IsRedguardAshAbahBurden(String reason)
    ; Token-contains, not exact-match: a marked-burden emit site may append a source
    ; suffix (e.g. "redguard_deathduty_major_krosis"), and the exact-match form was the
    ; original silent gap (gate correct, token never produced). Suffix/omission-proof per
    ; the P2 book-notice fix.
    return StringContainsToken(reason, "redguard_deathduty_major") || StringContainsToken(reason, "redguard_ashabah_burden")
EndFunction

Function AwardRedguardCrownSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_CROWN_FORM, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "crown_tomb_" + reason)
EndFunction

Function AwardRedguardForebearSignal(Float multiplier)
    ; Road-passage is the Forebear lane's own beat: the Forebear sect substrate credit
    ; is recorded by the caller (RecordRedguardSectSignal). HoonDing's make-way no
    ; longer rides road-passage -- it now fires on curated BREAKTHROUGH kills
    ; (HandleHoonDingBreakthroughKill), so the old blunt weekly cap is retired. Leki's
    ; sword-singing remains the focused-patron beat on the road.
    if _activeDeity == PDV_Leki && PDV_Leki
        AwardCuratedSignalScaled(PDV_Leki, PDV_Leki.SIGNAL_SWORD_SINGING, None, multiplier)
    endIf
EndFunction

; HoonDing make-way, rebuilt (user ruling 2026-06-20). Standard make-way (signal
; 2501) no longer rides the mis-wired Forebear road-passage; it now fires on a
; curated BREAKTHROUGH kill -- the Walker-Who-Makes-Way carving a path through what
; should have stopped you. V1 qualifies on DRAGON kills (the clean, iconic make-way
; moment; eventType 302 = EVT_KILL_DRAGON in PDV_ActionRouter). Named bosses /
; major-quest milestones / final bosses are a curated-FormList follow-up. Anti-farm:
; dragons soft-decay across the day (ConsumeDailyRepeatMultiplier) instead of the old
; weekly cap, so every genuine make-way registers but a dragon-farm day diminishes.
; Combat-odds detection stays post-1.0. Called from PDV_ActionRouter.HandleStoryKillActor
; (the player's own killing blow only).
Function HandleHoonDingBreakthroughKill(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !PDV_HoonDing
        return
    endIf
    if _activeDeity != PDV_HoonDing
        return
    endIf

    Bool dragonKill = eventType == 302 ; EVT_KILL_DRAGON
    Bool listedBossKill = False
    if !dragonKill && PDV_FLST_HoonDing_BreakthroughBosses
        Actor victimActor = victimForm as Actor
        if victimActor
            ActorBase victimBase = victimActor.GetLeveledActorBase()
            if victimBase && PDV_FLST_HoonDing_BreakthroughBosses.HasForm(victimBase)
                listedBossKill = True
            endIf
        endIf
    endIf

    if !dragonKill && !listedBossKill
        return
    endIf

    String repeatKey = "PDV.Signal.HoonDingDragon"
    String traceLabel = "dragon"
    if listedBossKill
        repeatKey = "PDV.Signal.HoonDingBreakthroughBoss"
        traceLabel = "listed boss"
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier(repeatKey)
    if multiplier <= 0.0
        Trace(2, "HoonDing make-way (" + traceLabel + ") decayed out for today; no award.")
        return
    endIf

    AwardCuratedSignalScaled(PDV_HoonDing, PDV_HoonDing.SIGNAL_MAKE_WAY, victimForm, multiplier)
    Trace(2, "HoonDing make-way fired: breakthrough " + traceLabel + " kill multiplier=" + multiplier)
EndFunction

Function AwardRedguardAshAbahSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "ashabah_death_duty_" + reason)
EndFunction

Function AwardRedguardFarShoresSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "far_shores_" + reason)
EndFunction

Function AwardRedguardAncestorSpinePietyPulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || multiplier <= 0.0
        return
    endIf

    if PDV_Tuwhacca
        AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastAncestorSpineSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastAncestorSpineSourceTime", Utility.GetCurrentGameTime())
EndFunction

Function HandleNordAncestorSpine(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        Trace(2, "Nord ancestor spine ignored for non-Nord origin.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.NordAncestorSpine")
    RecordNordAncestorSpine(reason, multiplier)
EndFunction

Function RecordNordAncestorSpine(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return
    endIf

    Int tierBefore = 0
    if PDV_NordAncestorSubstrate
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordAncestorStandingScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "The old line remembered.", "shor", GetNordAncestorLayerLabel())
    endIf

    if PDV_Shor
        AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Trace(2, "Nord ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordNordAncestralRest(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if PDV_NordAncestorSubstrate
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordAncestralRestScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "The old line rested near.", "shor", GetNordAncestorLayerLabel())
    endIf

    if PDV_Shor
        AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestralRestCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestralRestReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestralRestTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "You wake with the old line nearer.")
    Trace(2, "Nord ancestral rest routed with multiplier " + multiplier)
EndFunction

Function RecordNordHearthReturn(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if PDV_NordAncestorSubstrate
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordHearthReturnScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, multiplier, "The hearth remembered your return.", "shor", GetNordAncestorLayerLabel())
    endIf

    if PDV_Shor
        AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.HearthReturnCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastHearthReturnReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastHearthReturnTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "The hearth remembers your return.")
    Trace(2, "Nord hearth return routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshNordAncestor()
    if !PDV_NordAncestorSubstrate
        return
    endIf

    Int postureBefore = PDV_NordAncestorSubstrate.GetAncestorPosture()
    Bool curseActive = IsNordVampireSuppressed()
    PDV_NordAncestorSubstrate.ProcessAncestorDawn(curseActive, "dawn")
    Int postureAfter = PDV_NordAncestorSubstrate.GetAncestorPosture()
    if postureBefore > PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN && postureAfter == PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN
        ShowNordNotification(PDV_Notif_Nord_General_AncestorsQuiet, "The ancestors are quiet.")
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
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
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
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
    String shownKey = GetRedguardChampionEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == REDGUARD_SECT_CROWN
        if PDV_Tuwhacca && GetTier(PDV_Tuwhacca) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Crown, "The Crown way has become more than memory. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Crown way is more than memory in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        if PDV_HoonDing && GetTier(PDV_HoonDing) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Forebear, "The Forebear way has become more than adaptation. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        if PDV_Tuwhacca && GetTier(PDV_Tuwhacca) >= TIER_DEVOTED
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_AshAbah, "The Ash'abah duty has become more than necessity. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Ash'abah duty, made public.", "More than necessity now -- a public shape of your devotion.", "sect")
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
        SendPrismaShiftToast("Your road turns toward " + GetKhajiitFocusLabel(focusValue) + ".", "", GetKhajiitFocusSymbol(focusValue))
        PDV_DeityBase focusDeity = GetKhajiitFocusDeity(focusValue)
        if focusDeity
            SurfaceTransition("emergence", focusDeity.DeityName, "onset", focusDeity.DeityIndex, "revelation")
        endIf
        RequestPanelRefresh()
    endIf
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
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.TalosShrineDefiance")
    if PDV_Talos
        AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
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

    String oldBand = GetAltmerCommittedAlignmentJournalBand()
    PDV_ThalmorAlignmentTrack.Adjust(adjustment, reason)
    MaybeSurfaceAltmerAlignmentBandChange(oldBand, "alignment_" + actionKey)
    Trace(2, "Altmer ThalmorAlignment " + actionKey + " " + adjustment + " -> " + PDV_ThalmorAlignmentTrack.GetValue())
EndFunction

Function MaybeSurfaceAltmerAlignmentBandChange(String oldBand, String reason)
    if !IsAltmerOrigin() || !PDV_ThalmorAlignmentTrack
        return
    endIf

    String newBand = GetAltmerCommittedAlignmentJournalBand()
    if oldBand == "" || newBand == "" || oldBand == newBand
        StorageUtil.SetStringValue(None, "PDV.Altmer.Alignment.LastCommittedBand", newBand)
        return
    endIf

    SendPrismaShiftToast("The Thalmor question turns in you: " + newBand + ".", "", "auri-el")
    SurfaceTransition("reorientation", newBand, "shift", -1, "turning", True, False)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Alignment.LastCommittedBand", newBand)
    Trace(1, "Altmer committed alignment band " + oldBand + " -> " + newBand + " (" + reason + ")")
EndFunction

String Function GetAltmerCommittedAlignmentJournalBand()
    if !PDV_ThalmorAlignmentTrack
        return ""
    endIf

    String label = PDV_ThalmorAlignmentTrack.GetStateLabelAt(PDV_ThalmorAlignmentTrack.GetCommittedStateIndex())
    if label == "OpenHeterodox"
        return "Open Heterodoxy"
    elseIf label == "PrivateHeterodox"
        return "Private Heterodoxy"
    elseIf label == "PublicOrthodox"
        return "Public Orthodoxy"
    elseIf label == "ThalmorEnforcer"
        return "Thalmor-Devout"
    endIf
    return "Uncommitted"
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerDawnSteadiness")

    RecordAltmerSourceFavor(FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    TryActivateContextualFavor(FAVOR_LANE_ALTMER, FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    if multiplier > 0.0
        AwardAltmerDawnSignal(reason, multiplier)
        AwardAltmerAncestorSpinePulse(multiplier, reason)
    endIf
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerOrthodoxCostlyEnforcement")

    RecordAltmerSourceFavor(FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    TryActivateContextualFavor(FAVOR_LANE_ALTMER, FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    if multiplier > 0.0
        AwardAltmerOrthodoxSignal(reason, multiplier)
        AwardAltmerAncestorSpinePulse(multiplier, reason)
    endIf
    ShowP2BookNotice(reason, "The scribe Xarxes", "The old orthodoxy asks more of you.")
EndFunction

Function AwardAltmerDawnSignal(String reason, Float multiplier)
    if StringContainsToken(reason, "magnus") && PDV_Magnus
        AwardCuratedSignalScaled(PDV_Magnus, PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None, multiplier)
        return
    endIf

    if PDV_AuriEl
        AwardCuratedSignalScaled(PDV_AuriEl, PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None, multiplier)
    endIf
EndFunction

Function AwardAltmerOrthodoxSignal(String reason, Float multiplier)
    if StringContainsToken(reason, "xarxes") && PDV_Xarxes
        AwardCuratedSignalScaled(PDV_Xarxes, PDV_Xarxes.SIGNAL_LINEAGE_HONORED, None, multiplier)
        return
    endIf

    if PDV_AuriEl
        AwardCuratedSignalScaled(PDV_AuriEl, PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION, None, multiplier)
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
        AwardAltmerAncestorSpinePulse(awardedCount as Float, "magic_milestone_" + skillName)
        Trace(2, "Altmer magic milestone routed: " + skillName + " x" + awardedCount)
    endIf
EndFunction

Function AwardAltmerAncestorSpinePulse(Float multiplier, String reason)
    if !IsAltmerOrigin() || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if PDV_AltmerAncestorSubstrate
        tierBefore = PDV_AltmerAncestorSubstrate.GetSubstrateTier()
        PDV_AltmerAncestorSubstrate.RecordHeritageStandingScaled(multiplier, reason)
        Int tierAfter = PDV_AltmerAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("altmer-heritage", tierBefore, tierAfter, multiplier, "The old line holds its shape.", "auriel", GetAltmerHeritageLayerLabel())
    endIf

    if PDV_AuriEl
        AwardCuratedSignalScaled(PDV_AuriEl, PDV_AuriEl.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Altmer.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Altmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Trace(2, "Altmer ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshAltmerAncestor()
    if !PDV_AltmerAncestorSubstrate
        return
    endIf

    Bool curseActive = IsAltmerFavorSuppressedByCurse()
    PDV_AltmerAncestorSubstrate.ProcessHeritageDawn(curseActive, "dawn")
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
        if stateValue != ALTMER_CRISIS_NONE
            SendPrismaShiftToast("The old line turns: " + GetAltmerCrisisStateLabelForValue(stateValue) + ".", "", "auri-el")
        endIf
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ShoutAttack")
    if multiplier <= 0.0
        Trace(2, "Shout attack decayed out for today; no piety award.")
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
                AwardPietyFromLikesDislikes(deity, delta * multiplier, eventType, reason)
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

        ; Reward/mirror hooks fire only for the patron / focused-emphasis deity.
        if deity == _activeDeity
            deity.OnTierChange(oldTier, newTier)
            RefreshPatronMirrors()
        elseIf isFocusedEmphasis
            deity.OnTierChange(oldTier, newTier)
        endIf

        ; Universal milestone surfacing: notice + toast + Book of Days entry for EVERY
        ; tier reach -- including broad-worship / pantheon gods with no single patron.
        ; A Nord keeping the whole pantheon (no _activeDeity, not Khajiit emphasis)
        ; previously got nothing here; now each god's milestone is marked. NotifyTierUp's
        ; per-(deity,tier) guard prevents duplicate notices; the band in surfaceKey scopes
        ; the journal guard so Seeker/Devoted/Champion each log once, Champion pinned.
        if surfaceTierUp && newTier > oldTier
            if ShouldSuppressImperialTalosTierSurface(deity)
                Trace(2, "Tier reach surface suppressed for Imperial Talos while Concordat blocks offers.")
            elseIf NotifyTierUp(deity, newTier)
                StorageUtil.SetFormValue(None, "PDV.BookOfDays.LastTierDeity", deityForm)
                StorageUtil.SetIntValue(None, "PDV.BookOfDays.LastTierValue", newTier)
                SendPrismaEventToast("tier", deity, "", GetPublicTierBand(newTier), "")
                SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(newTier), "reach", deity.DeityIndex, "", false, newTier >= TIER_CHAMPION)
            endIf
        endIf

        RequestPanelRefresh()
    elseIf deity == _activeDeity
        RefreshPatronMirrors()
    endIf

    return newTier
EndFunction

; One-shot guard when a tracked deity advances a tier.
Bool Function NotifyTierUp(PDV_DeityBase deity, Int newTier)
    if !deity || newTier <= TIER_NONE
        return False
    endIf

    String shownKey = "PDV.TierNoticeShown." + deity.DeityIndex + "." + newTier
    if StorageUtil.GetIntValue(None, shownKey) == 1
        return False
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
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
; keys read by PDV_DeityBase.ScoreFromTable. Origin-gated overlay rows write to
; PDV.LD.<evt>.O<origin>.{D,C,O}. Version-gated so existing saves reload on a bump.
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

Function WriteLD(PDV_DeityBase deity, Int eventType, Float delta, Int dailyCap, Float cooldownDays, Int originGate)
    Form ldForm = deity as Form
    String ldPrefix = "PDV.LD." + eventType
    if originGate >= 0
        String originPrefix = ldPrefix + ".O" + originGate
        StorageUtil.SetFloatValue(ldForm, originPrefix + ".D", delta)
        StorageUtil.SetIntValue(ldForm, originPrefix + ".C", dailyCap)
        StorageUtil.SetFloatValue(ldForm, originPrefix + ".O", cooldownDays)
        return
    endIf

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
        Int originIndex = ORIGIN_NORD
        while originIndex <= ORIGIN_REDGUARD
            String originPrefix = ldPrefix + ".O" + originIndex
            StorageUtil.UnsetFloatValue(ldForm, originPrefix + ".D")
            StorageUtil.UnsetIntValue(ldForm, originPrefix + ".C")
            StorageUtil.UnsetFloatValue(ldForm, originPrefix + ".O")
            originIndex += 1
        endWhile
        ldIndex += 1
    endWhile
EndFunction

Int[] Function GetLikesDislikesEventTypes()
    Int[] ldEvents = new Int[34]
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
    ldEvents[31] = 315
    ldEvents[32] = 303
    ldEvents[33] = 366
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

    ; v3: enforce patron<->Prince exclusivity on legacy saves holding BOTH. Keep the
    ; higher tier (tie -> Prince, matching the live Prince-wins surface), sever the
    ; loser, and surface a one-time resolution note. The StripPactSpells loop above
    ; already cleaned stacked spells, so the sever fights nothing. SetActiveDeity(None)
    ; has newDeity==None, so it does not re-enter the patron-commit Prince-sever.
    Bool hasPatron = (GetPatronState() == PATRON_STATE_ACTIVE) && _activeDeity
    if hasPatron && topPath && topTier > 0
        Int patronTier = GetTier(_activeDeity)
        String resolvedName = ""
        if topTier >= patronTier
            resolvedName = topPath.DeityName
            SetActiveDeity(None)
        else
            resolvedName = _activeDeity.DeityName
            topPath.ClearLiveDaedricPactSpells()
            StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
        endIf
        SendPrismaEventToast("shift", None, "Your devotion has resolved to " + resolvedName + ".", "", "")
        AppendBookOfDaysEntry("Your devotion has resolved to " + resolvedName + ".", Utility.GetCurrentGameTime() as Int, "reorientation", "journal", true)
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
            ClearPrinceRowsForPath(pldPath)
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

Function ClearPrinceRowsForPath(PDV_DaedricPathBase path)
    Form pldForm = path as Form
    Int[] pldEvents = GetPrinceEventTypes()
    Int pldIndex = 0
    while pldIndex < pldEvents.Length
        String pldPrefix = "PDV.PLD." + pldEvents[pldIndex]
        StorageUtil.UnsetFloatValue(pldForm, pldPrefix + ".D")
        StorageUtil.UnsetIntValue(pldForm, pldPrefix + ".C")
        StorageUtil.UnsetFloatValue(pldForm, pldPrefix + ".O")
        pldIndex += 1
    endWhile
EndFunction

Int[] Function GetPrinceEventTypes()
    Int[] pldEvents = new Int[31]
    pldEvents[0] = 1
    pldEvents[1] = 2
    pldEvents[2] = 300
    pldEvents[3] = 302
    pldEvents[4] = 303
    pldEvents[5] = 304
    pldEvents[6] = 313
    pldEvents[7] = 314
    pldEvents[8] = 315
    pldEvents[9] = 330
    pldEvents[10] = 331
    pldEvents[11] = 332
    pldEvents[12] = 333
    pldEvents[13] = 334
    pldEvents[14] = 340
    pldEvents[15] = 341
    pldEvents[16] = 342
    pldEvents[17] = 343
    pldEvents[18] = 344
    pldEvents[19] = 345
    pldEvents[20] = 350
    pldEvents[21] = 351
    pldEvents[22] = 354
    pldEvents[23] = 360
    pldEvents[24] = 361
    pldEvents[25] = 362
    pldEvents[26] = 364
    pldEvents[27] = 365
    pldEvents[28] = 366
    pldEvents[29] = 367
    pldEvents[30] = 368
    return pldEvents
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
        WritePLD(path, 315, -0.25, 3, 0.0)
    elseIf ldName == "Hircine"
        WritePLD(path, 1, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 302, 0.5, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
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
        WritePLD(path, 315, -0.25, 3, 0.0)
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
        WritePLD(path, 315, -0.25, 3, 0.0)
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
        WritePLD(path, 315, -0.25, 3, 0.0)
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
        WritePLD(path, 315, -0.25, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
    elseIf ldName == "Sheogorath"
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 343, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
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
        WriteLD(deity, 1, -0.5, 2, 0.0, -1)
        WriteLD(deity, 2, 0.5, 0, 0.0, -1)
        WriteLD(deity, 40, 0.35, 3, 0.0208, -1)
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 303, -0.5, 3, 0.0, -1)
    elseIf ldName == "akatosh"
        WriteLD(deity, 302, -0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, 2)
        WriteLD(deity, 362, -0.75, 2, 0.5, 2)
    elseIf ldName == "Arkay"
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.75, 3, 0.0, 2)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Mara"
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 314, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 351, 0.5, 2, 0.0, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, 2)
        WriteLD(deity, 314, 0.35, 2, 0.5, 2)
        WriteLD(deity, 362, -0.5, 3, 0.0, 2)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Stendarr"
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, 2)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Zenithar"
        WriteLD(deity, 330, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -1.0, 2, 0.5, -1)
        WriteLD(deity, 360, -0.5, 3, 0.0, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 351, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
    elseIf ldName == "Julianos"
        WriteLD(deity, 340, 0.5, 3, 0.0, -1)
        WriteLD(deity, 341, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 331, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
    elseIf ldName == "Dibella"
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "Kynareth"
        WriteLD(deity, 313, 0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 1, 0.5, -1)
        WriteLD(deity, 334, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 2, 0.5, 2)
        WriteLD(deity, 303, -0.5, 3, 0.0, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Talos"
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 351, 0.5, 2, 0.5, 0)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "Shor"
        WriteLD(deity, 343, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, 0)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
    elseIf ldName == "Tsun"
        WriteLD(deity, 2, 0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 0.75, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
    elseIf ldName == "Stuhn"
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -2.0, 1, 1.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 360, -0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, 0)
        WriteLD(deity, 351, 0.5, 2, 0.5, 0)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
    elseIf ldName == "auri-el"
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "magnus"
        WriteLD(deity, 341, 0.75, 2, 0.5, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 1, 0.5, -1)
        WriteLD(deity, 341, 0.75, 2, 0.5, 2)
        WriteLD(deity, 342, 0.5, 3, 0.0, 2)
        WriteLD(deity, 331, 0.35, 2, 0.5, 2)
        WriteLD(deity, 365, -1.25, 1, 1.0, 2)
        WriteLD(deity, 366, -0.5, 3, 0.0, -1)
    elseIf ldName == "xarxes"
        WriteLD(deity, 342, 0.75, 2, 0.5, -1)
        WriteLD(deity, 340, 0.5, 3, 0.0, -1)
        WriteLD(deity, 341, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, -0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
    elseIf ldName == "trinimac"
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, -2.0, 1, 1.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 2, 0.35, 3, 0.0, 3)
        WriteLD(deity, 368, -1.5, 1, 1.0, 3)
        WriteLD(deity, 304, -1.0, 2, 0.5, 3)
    elseIf ldName == "Y'ffre"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 330, -0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.75, 2, 0.5, 2)
        WriteLD(deity, 334, 0.25, 3, 0.0, 2)
        WriteLD(deity, 331, -0.35, 3, 0.0, 2)
        WriteLD(deity, 303, 0.25, 3, 0.0, 2)
        WriteLD(deity, 333, 0.5, 3, 0.0, 2)
        WriteLD(deity, 300, 0.5, 3, 0.0, 2)
        WriteLD(deity, 350, 0.5, 3, 0.0, 2)
        WriteLD(deity, 365, -1.0, 2, 0.5, 2)
        WriteLD(deity, 364, -0.5, 3, 0.0, 2)
    elseIf ldName == "Z'en"
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 340, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 331, 0.25, 3, 0.0, -1)
        WriteLD(deity, 360, -0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
    elseIf ldName == "Baan Dar"
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 364, 0.5, 2, 0.0, -1)
        WriteLD(deity, 330, -0.25, 3, 0.0, -1)
        WriteLD(deity, 351, -0.25, 2, 0.5, -1)
    elseIf ldName == "khenarthi"
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, 6)
        WriteLD(deity, 350, 0.5, 3, 0.0, 6)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "rajhin"
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.35, 3, 0.0, 6)
        WriteLD(deity, 304, -0.75, 2, 0.5, 6)
        WriteLD(deity, 366, -0.5, 3, 0.0, -1)
    elseIf ldName == "alkosh"
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
    elseIf ldName == "azurah"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Boethiah"
        WriteLD(deity, 2, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, 1.5, 1, 1.0, -1)
        WriteLD(deity, 350, -0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 1, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.5, 3, 0.0, -1)
        WriteLD(deity, 362, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 333, -0.25, 3, 0.0, -1)
    elseIf ldName == "Mephala"
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 1.0, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, 1.5, 1, 1.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, 1.0, 2, 0.5, -1)
        WriteLD(deity, 2, -0.25, 3, 0.0, -1)
        WriteLD(deity, 350, -0.5, 2, 0.0, -1)
        WriteLD(deity, 313, -0.25, 2, 0.0, -1)
        WriteLD(deity, 366, 0.35, 3, 0.0, -1)
    elseIf ldName == "The Hist"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 334, 0.25, 3, 0.0, 7)
        WriteLD(deity, 314, 0.25, 1, 0.0, -1)
        WriteLD(deity, 332, 0.5, 3, 0.0, -1)
        WriteLD(deity, 334, 0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.25, 3, 0.0, -1)
    elseIf ldName == "sithis"
        WriteLD(deity, 304, 1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 315, -0.25, 1, 0.0, -1)
        WriteLD(deity, 364, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, -0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 330, -0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 0.35, 1, 1.0, 7)
        WriteLD(deity, 351, -0.25, 2, 0.5, 7)
        WriteLD(deity, 366, 0.5, 3, 0.0, -1)
    elseIf ldName == "Malacath"
        WriteLD(deity, 330, 0.75, 2, 0.5, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, 8)
        WriteLD(deity, 2, 0.25, 3, 0.0, -1)
        WriteLD(deity, 1, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 0.75, 1, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
    elseIf ldName == "Tu'whacca"
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.25, 3, 0.0, 9)
        WriteLD(deity, 314, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Leki"
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 330, 0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 362, -0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 340, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 360, -0.25, 3, 0.0, -1)
    elseIf ldName == "HoonDing"
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
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

    EnsureAkatoshRuntimeIdentity()
    RunDawnAwardAltmerAuriElDawn()
    RunDawnConsolidateScratch()
    RunDawnConsolidateDaedricWeek()
    RunDawnRefreshTrackStates()
    RunDawnApplyDecayNoop()
    RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnProcessCommitmentOffersNoop()
    RunDawnNotifyNoop()
    RunDawnBookOfDays()
    SyncKhajiitPhaseBlessing()
    ProcessKhajiitAlkoshWordDrip()
    DisarmDunmerAncestorWatch()
    RequestPanelRefresh()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] ProcessDawn complete.")
    endIf
EndFunction

; --- Book of Days dawn pass ---
; Ages out old entries (even on a silent day), records any per-race PRIMARY mode change
; as a pinned "reorientation" entry via a snapshot-diff (evidence-gated tracks change at
; dawn, so this catches sect/path/life-mode/baseline/focus/concordat/crisis/tradition/
; Hist-posture switches the same dawn they occur), and writes one named-acts digest if
; the day saw devotion. Secondary drift (stigma/compliance/vow/exposure/lunar-posture) is
; a backlog enhancement -- add more snapshot keys here.
Function RunDawnBookOfDays()
    Int today = Utility.GetCurrentGameTime() as Int
    PruneBookOfDays()
    EmitBookOfDaysStateChange(today)
    EmitBookOfDaysBroadLaneTierChange(today)
    if _dawnHadActivity
        AppendBookOfDaysEntry(BuildBookOfDaysDigestLine(), today, "dawn.digest", "journal", False)
    endIf
EndFunction

Function EmitBookOfDaysBroadLaneTierChange(Int today)
    Int originRace = GetPlayerOriginRaceIndex()
    Int broadTier = GetBroadLaneTierForOrigin(originRace)
    if broadTier <= TIER_NONE
        return
    endIf

    Int tier = TIER_SEEKER
    while tier <= broadTier && tier <= TIER_DEVOTED
        String guard = "PDV.BookOfDays.BroadLaneTierShown." + originRace + "." + tier
        if StorageUtil.GetIntValue(None, guard) != 1
            StorageUtil.SetIntValue(None, guard, 1)
            AppendBookOfDaysEntry(BuildBroadLaneTierReachJournalLine(originRace, tier), today, "tier.reach", GetBroadLaneSymbol(originRace), False, tier)
        endIf
        tier += 1
    endWhile
EndFunction

String Function BuildBroadLaneTierReachJournalLine(Int originRace, Int tier)
    return "Your " + GetBroadLaneDisplayName(originRace) + " has reached " + GetBroadLaneStandingLabel(originRace, tier) + "."
EndFunction

; Snapshot-diff of the player's per-race mode label. GetPlayerMcmModeLine already
; dispatches per race to the right state/sect/path/baseline/focus label, so one diff
; covers every race. The first snapshot only initializes (no phantom switch on a fresh
; game); thereafter a real change writes a pinned reorientation entry.
Function EmitBookOfDaysStateChange(Int today)
    String current = GetPlayerMcmModeLine()
    String last = StorageUtil.GetStringValue(None, "PDV.BookOfDays.LastModeSnapshot")
    if current != "" && last != "" && current != last
        AppendBookOfDaysEntry(BuildModeChangeLine(current), today, "reorientation", "journal", True)
    endIf
    StorageUtil.SetStringValue(None, "PDV.BookOfDays.LastModeSnapshot", current)
EndFunction

; Mode-change line: Nord/Dunmer/Khajiit/Altmer/Imperial/Breton carry a bespoke
; turn-of-the-path line; the rest use a clean templated line. (Per-transition journal
; voice lives in PDV_DiegeticDirector.ResolveJournalLine -- bespoke for Khajiit/Dunmer/
; Imperial/Altmer as of 6g; remaining races use the generic journal fallback.)
String Function BuildModeChangeLine(String modeLabel)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD
        return "The road turns beneath you. You keep the gods now as: " + modeLabel + "."
    elseIf originRace == ORIGIN_DUNMER
        return "The ash shifts, and your place among the dead settles anew: " + modeLabel + "."
    elseIf originRace == ORIGIN_KHAJIIT
        return "The moons mark a turning in your road: " + modeLabel + "."
    elseIf originRace == ORIGIN_ALTMER
        return "The old line records a turn in your discipline: " + modeLabel + "."
    elseIf originRace == ORIGIN_IMPERIAL
        return BuildImperialConcordatBookLine(modeLabel)
    elseIf originRace == ORIGIN_BRETON
        return "Your Breton road turns under the chosen tradition: " + modeLabel + "."
    endIf
    return "Your path turns. You walk now as: " + modeLabel + "."
EndFunction

String Function BuildImperialConcordatBookLine(String modeLabel)
    if modeLabel == "Concordat Enforcer"
        return "Under the White-Gold Concordat, you are a Concordat Enforcer."
    endIf

    return "Under the White-Gold Concordat, you are " + modeLabel + "."
EndFunction

; Named-acts dawn digest: names the gods and open Princes fed today (captured before
; piety-today is zeroed). Up to 5 named, then "and others"; falls back to a flavored
; generic line when activity happened but no positive gain was captured.
String Function BuildBookOfDaysDigestLine()
    Int fedCount = StorageUtil.StringListCount(None, "PDV.BookOfDays.TodayFed")
    Int shown = fedCount
    if shown > 5
        shown = 5
    endIf

    String names = ""
    Int i = 0
    while i < shown
        String godName = StorageUtil.StringListGet(None, "PDV.BookOfDays.TodayFed", i)
        if i == 0
            names = godName
        elseIf i == shown - 1 && shown == 2
            names = names + " and " + godName
        elseIf i == shown - 1
            names = names + ", and " + godName
        else
            names = names + ", " + godName
        endIf
        i += 1
    endWhile
    if fedCount > shown
        if names != ""
            names = names + ", and others"
        else
            names = "others"
        endIf
    endIf

    if names != ""
        return "At dawn, your acts fed " + names + "."
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_DUNMER
        return "The day's offerings were noted; the ash remembers, and settles with the dawn."
    elseIf originRace == ORIGIN_KHAJIIT
        return "The day's road was walked and noted; it settles beneath the moons at dawn."
    endIf
    return "The day's devotions were noted, and settle with the dawn."
EndFunction

Function RecordBookOfDaysFedName(String displayName)
    if displayName == ""
        return
    endIf
    StorageUtil.StringListAdd(None, "PDV.BookOfDays.TodayFed", displayName, False)
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
    StorageUtil.StringListClear(None, "PDV.BookOfDays.TodayFed")
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()

    while i < count
        Form deityForm = PDV_FLST_AllDeities.GetAt(i)
        PDV_DeityBase deity = deityForm as PDV_DeityBase

        ; Dawn skip (2026-07-05): a deity outside the origin roster with zero
        ; scratch and zero standing has nothing to consolidate and no surface
        ; that reads its Week ring or tier -- skip the per-dawn writes for it.
        ; Old saves with pre-gate foreign piety still consolidate (piety > 0
        ; falls through to the full body).
        Bool dawnSkip = False
        if deity && !IsDashboardDeityInOriginRoster(deity, GetPlayerOriginRaceIndex())
            if StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday") == 0.0 && StorageUtil.GetFloatValue(deityForm, "PDV.Piety") == 0.0
                dawnSkip = True
            endIf
        endIf

        if deity && !dawnSkip
            EnsureDeityState(deity)

            Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
            Float scaledToday = pietyToday * GAIN_RATE_SCALE
            Float dailyCap = PIETY_DAILY_MAX_DELTA
            if PDV_ModePresetRef
                dailyCap = dailyCap * PDV_ModePresetRef.DailyCapScalar()
            endIf
            Float clampedToday = ClampValue(scaledToday, -dailyCap, dailyCap)
            if clampedToday > 0.0
                clampedToday = clampedToday * GetOrcLifeModeGainMultiplier(deity)
                clampedToday = clampedToday * GetImperialCurseGainMultiplier(deity)
                ; Record the gods fed today so the dawn digest can name them.
                RecordBookOfDaysFedName(GetPublicDeityDisplayName(deity))
            endIf
            Float oldPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
            Float newPiety = ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)

            StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
            ; Feed the Weekly tab's 7-day ring with this day's net before clearing it.
            PushWeekNet(deityForm, pietyToday)
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

; Daedric Princes apply piety immediately (no per-day fold into PDV.Piety), so this
; only rolls the day's tally into the Weekly ring and clears it -- it must NOT touch
; PDV.Piety. PietyToday for paths is accumulated in PDV_DaedricPathBase.SetStoredPiety.
Function RunDawnConsolidateDaedricWeek()
    if !PDV_FLST_DaedricPaths_All
        return
    endIf
    Int i = 0
    Int count = PDV_FLST_DaedricPaths_All.GetSize()
    while i < count
        Form pathForm = PDV_FLST_DaedricPaths_All.GetAt(i)
        if pathForm
            PDV_DaedricPathBase path = pathForm as PDV_DaedricPathBase
            Float dayNet = StorageUtil.GetFloatValue(pathForm, "PDV.PietyToday")
            if path && dayNet > 0.0
                RecordBookOfDaysFedName(path.DeityName)
            endIf
            if dayNet != 0.0
                _dawnHadActivity = True
            endIf
            PushWeekNet(pathForm, dayNet)
            StorageUtil.SetFloatValue(pathForm, "PDV.PietyToday", 0.0)
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

    if GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        RunDawnRefreshImperialAncestor()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        EvaluateKhajiitFocusedEmphasis()
        RefreshKhajiitLunarPosture("dawn")
    endIf

    if IsArgonianOrigin()
        RunDawnRefreshArgonianHist()
    endIf

    if IsAltmerOrigin()
        String oldAltmerBand = GetAltmerCommittedAlignmentJournalBand()
        if PDV_ThalmorAlignmentTrack
            PDV_ThalmorAlignmentTrack.RefreshState()
            MaybeSurfaceAltmerAlignmentBandChange(oldAltmerBand, "dawn")
        endIf
        RunDawnRefreshAltmerAncestor()
        SyncAltmerDisciplines(Game.GetPlayer())
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        RunDawnRefreshNordAncestor()
    endIf

    if IsOrcOrigin()
        EvaluateOrcLifeModeAtDawn()
        SyncOrcTrialOfIron(Game.GetPlayer())
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        RunDawnRefreshBretonAncestor()
        DecayBretonWitchcraftExposureAtDawn()
        DecayBretonDruidicStandingAtDawn()
    endIf

    if IsBosmerOrigin() && PDV_BosmerPathTrack
        EnsureBosmerCurrentPathFallback()
        EvaluateBosmerForcedReckoning()
        SyncBosmerNaming(Game.GetPlayer())
        ArmBosmerDreamOnPathChange()
    endIf

    if IsRedguardOrigin() && PDV_RedguardSectTrack
        SyncRedguardRemembering(Game.GetPlayer())
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
        ; Broad-lane lapse neglect (owner ruling 2026-06-27): a broad / full-pantheon worshipper who
        ; goes quiet for a few days feels gentle neglect too, not just focused patrons. Nord broad
        ; (Old Ways / Nine Divines) reuses the Kyne weather spell as its broad-lane neglect for now;
        ; per-race broad-lane neglect spells are a follow-on. Other races: no broad spell yet.
        Bool nordBroadLapsed = IsBroadLaneLapsed() && GetPlayerOriginRaceIndex() == ORIGIN_NORD
        SyncKyneNeglectSpell(nordBroadLapsed)
        SyncNordPatronNeglectSpells()
        if nordBroadLapsed && StorageUtil.GetIntValue(None, "PDV.Neglect.PatronToastState") == 0
            SendPrismaToast("journal", "warning", "Devotion quiet", "The gods feel distant as your devotion goes quiet.")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", BoolToInt(nordBroadLapsed))
        UpdateContextualFavorRuntime()
        SyncFirstTierRaceRewardRuntime()
        return
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || !_activeDeity
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", 0)
        SyncKyneNeglectSpell(False)
        SyncNordPatronNeglectSpells()
        UpdateContextualFavorRuntime()
        SyncFirstTierRaceRewardRuntime()
        return
    endIf

    ClearAllNeglectFlags()
    Int activeCount = ApplyGenericNeglectFlags()
    ; Recency lapse (owner ruling 2026-06-27): the active patron bites after a few quiet days even
    ; though it is decay-shielded and rarely reaches the piety<=10 floor from absence. Force-flag it
    ; on lapse so the existing patron-spell (Kyne) + toast logic below fires. Non-Kyne patrons get
    ; the toast now; their own flat neglect spell is a follow-on (per-patron Nord neglect).
    if IsPatronLapsed(_activeDeity) && !IsNeglectFlagActive(_activeDeity)
        SetNeglectFlag(_activeDeity, True)
        activeCount += 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", activeCount)
    ; Owner ruling 2026-06-26: committing to a patron fades other gods' neglect. Kyne's
    ; weather-neglect now fires only when Kyne is the player's own active patron; any
    ; non-Kyne focus (any tier) suppresses it. Broad worship already had no Kyne penalty.
    SyncKyneNeglectSpell(IsNeglectFlagActive(PDV_Kyne) && _activeDeity == PDV_Kyne)
    SyncNordPatronNeglectSpells()
    UpdateContextualFavorRuntime()

    Bool patronNeglected = IsNeglectFlagActive(_activeDeity)
    Int priorPatronToastState = StorageUtil.GetIntValue(None, "PDV.Neglect.PatronToastState")
    if patronNeglected && priorPatronToastState == 0
        SendPrismaEventToast("neglect", _activeDeity, "", "", "")
        SurfaceTransition("neglect", _activeDeity.DeityName, "drop", _activeDeity.DeityIndex, "absence")
    elseIf !patronNeglected && priorPatronToastState == 1
        SurfaceTransition("neglect", _activeDeity.DeityName, "recover", _activeDeity.DeityIndex, "renewal")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", BoolToInt(patronNeglected))
    SyncFirstTierRaceRewardRuntime()
EndFunction

Function RunDawnProcessCommitmentOffers()
    if IsBosmerOrigin()
        EvaluateBosmerPathSuggestion()
        return
    endIf

    RefreshCommitmentOfferQualificationGuards()
    EvaluateFormalCommitmentOffer()
EndFunction

Function RefreshCommitmentOfferQualificationGuards()
    if !PDV_FLST_AllDeities
        return
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if UsesFormalCommitmentOffersForDeity(deity) && GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD
            StorageUtil.SetIntValue(deity as Form, "PDV.Commitment.Offered", 0)
        endIf
        i += 1
    endWhile
EndFunction

Function RunDawnNotify()
    SendPrismaEventToast("dawn", None, "", "", "", _dawnHadActivity)
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

    Float decayGraceDays = DECAY_GRACE_DAYS
    if PDV_ModePresetRef
        decayGraceDays = decayGraceDays * PDV_ModePresetRef.GraceScalar()
    endIf

    if (nowTime - lastEventTime) < decayGraceDays
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

    Float decayScalar = 1.0
    if PDV_ModePresetRef
        decayScalar = PDV_ModePresetRef.DecayScalar()
    endIf
    Float newPiety = currentPiety - (DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity) * decayScalar)
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
    elseIf commandId == 8
        DebugClosePrismaSurfaces()
    elseIf commandId == 9
        DebugSyncRewardsOnly()
    elseIf GetDebugLevel() >= 1
        Debug.Trace("[PDV] RunDebugCommand ignored unknown command " + commandId)
    endIf

    DebugCommand = 0
EndFunction

Function DebugClosePrismaSurfaces()
    _panelDirty = False
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson("{\"journalClose\":true}")
    PDV_PrismaBridge.CancelChoice()
    PDV_PrismaBridge.CloseDevotionPanel()
EndFunction

Function DebugSyncRewardsOnly()
    RunDawnApplySpellAndNeglectLayers()
    _panelDirty = False
    DebugClosePrismaSurfaces()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Debug reward sync complete.")
    endIf
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
    ; Resync the race reward families immediately (mirrors DebugForceSetPietyByIndex):
    ; without this a debug patron override surfaces every toast/panel/Survey cue but
    ; grants no reward spells until the next dawn pass -- reads as "rewards not wired".
    SyncFirstTierRaceRewardRuntime()
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
    ; Surface the tier change so a debug-forced tier reach is testable (notice + toast +
    ; Book of Days entry). Only fires on an UP-crossing from a lower tier -- if the deity
    ; is already at/above the target, reset it first, or use the piety-today + dawn path.
    RecomputeTier(deity, True)
    ; Resync the race reward family so a focused/emphasis reward (Khajiit emphasis, an
    ; Imperial/Altmer focused patron, etc.) actually grants on the seed. RecomputeTier only
    ; fires OnTierChange (Boon slots), not SyncFirstTierRaceRewardRuntime -- without this a
    ; debug piety seed reads a false 0 on the HP bar until a dawn pass.
    SyncFirstTierRaceRewardRuntime()
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
    ; Strip the now-unfocused patron's reward spells immediately (same dawn-lag class
    ; as ForceSetActiveDeityByIndex).
    SyncFirstTierRaceRewardRuntime()
EndFunction

Function DebugSetBroadWorship()
    SetBroadWorship()
EndFunction

; Debug: seed the player's race broad-worship lane to its Faithful (T2) reward so the
; broad Fortify-Health is testable. The broad lanes gate on PATRON_STATE_BROAD + a >=6
; COUNT accumulator (NOT deity piety), so "Apply target piety" cannot reach them. This
; sets broad worship + the origin race's accumulator to its threshold + refreshes the
; reward spells.
Function DebugSeedBroadLane()
    SetBroadWorship()
    Int origin = GetPlayerOriginRaceIndex()
    if origin == ORIGIN_IMPERIAL
        StorageUtil.SetIntValue(None, "PDV.Imperial.CivicServiceCount", 6)
    elseIf origin == ORIGIN_BRETON
        StorageUtil.SetIntValue(None, "PDV.Breton.TraditionHookCount", 6)
    elseIf origin == ORIGIN_ORC
        StorageUtil.SetIntValue(None, "PDV.Orc.MalacathSourceCount", 6)
    elseIf origin == ORIGIN_ALTMER
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count", 6)
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count", 6)
    else
        Trace(1, "DebugSeedBroadLane: origin " + origin + " has no broad-lane accumulator wired here (Nord/others not yet covered).")
    endIf
    SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    Trace(1, "DebugSeedBroadLane seeded broad lane for origin " + origin + ".")
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

Function AwardPietyInternal(PDV_DeityBase deity, Float amount, Bool allowRivalry, String reason = "")
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
        ; Global "last devotional act" stamp for broad-lane lapse neglect (IsBroadLaneLapsed);
        ; the broad lane has no single patron, so it tracks any positive pantheon act.
        StorageUtil.SetFloatValue(None, "PDV.Devotion.LastActTime", Utility.GetCurrentGameTime())
    endIf
    if allowRivalry && appliedAmount < 0.0 && _pendingLikesDislikesEventType >= 0
        ApplyDisfavorSting(deity, appliedAmount, reason)
    endIf

    ; Attribution: any deity with visible piety movement must carry the reason into
    ; its recent-driver ring. The dashboard shows every deity with PietyToday, so
    ; gating this to the active patron leaves broad-pantheon gains unexplained.
    if appliedAmount != 0.0
        RecordDeityDriver(deity, reason, appliedAmount)
    endIf

    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardPiety: " + deity.DeityName + " raw " + amount + ", applied " + appliedAmount + ", stance " + stance + ", today=" + StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday"))
    endIf

    if appliedAmount > 0.0 && deity == _activeDeity && !_suppressAwardFavorToast
        SendPrismaEventToast("favor", deity, "", "", "")
    endIf

    if allowRivalry && appliedAmount > 0.0 && stance == deity.STANCE_HOSTILE
        ApplyRivalryPenalties(deity, appliedAmount)
    endIf

    if appliedAmount != 0.0
        RequestPanelRefresh()
    endIf
EndFunction

Function ApplyDisfavorSting(PDV_DeityBase deity, Float appliedAmount, String sourceTag)
    if !deity || appliedAmount >= 0.0 || _pendingLikesDislikesEventType < 0
        return
    endIf

    Float baseDelta = GetDislikeBaseDeltaForEvent(deity, _pendingLikesDislikesEventType)
    if baseDelta >= 0.0
        return
    endIf

    Float absDelta = 0.0 - baseDelta
    if absDelta <= DISFAVOR_LIGHT_MIN_DELTA
        return
    endIf

    if !HasDisfavorStanding(deity)
        Trace(3, "Disfavor sting skipped: no standing for " + deity.DeityName)
        return
    endIf

    Int domainValue = DomainForDeity(deity)
    if domainValue == DISFAVOR_DOMAIN_NONE
        Trace(2, "Disfavor sting skipped: no domain for " + deity.DeityName)
        return
    endIf

    if IsDisfavorRepeatSuppressed(deity, domainValue, _pendingLikesDislikesEventType)
        Trace(3, "Disfavor sting suppressed for repeat " + deity.DeityName + " / " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    UpdateDisfavorStingRuntime()

    Bool domainAlreadyActive = IsDisfavorDomainActive(domainValue)
    if !domainAlreadyActive && CountActiveDisfavorStings() >= DISFAVOR_MAX_ACTIVE_DOMAINS
        Trace(2, "Disfavor sting suppressed by active-domain cap for " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    Bool sharpBand = absDelta > DISFAVOR_SHARP_MIN_DELTA
    Spell targetSpell = GetDisfavorSpell(domainValue, sharpBand)
    if !targetSpell
        Trace(1, "Disfavor sting skipped: missing spell for " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    playerRef.AddSpell(targetSpell, False)
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 1)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), Utility.GetCurrentGameTime() + GetDisfavorDurationDays(sharpBand))
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), GetDisfavorBandLabel(sharpBand))
    MarkDisfavorRepeatUsed(deity, domainValue, _pendingLikesDislikesEventType)
    Trace(1, "Disfavor sting applied: " + deity.DeityName + " -> " + GetDisfavorDomainLabel(domainValue) + " " + GetDisfavorBandLabel(sharpBand) + " (" + sourceTag + ")")
EndFunction

Float Function GetDislikeBaseDeltaForEvent(PDV_DeityBase deity, Int eventType)
    if !deity
        return 0.0
    endIf

    if !IsGenericLikesDislikesDeityReachable(deity)
        return 0.0
    endIf

    Form deityForm = deity as Form
    String tableKeyPrefix = "PDV.LD." + eventType
    Float baseDelta = StorageUtil.GetFloatValue(deityForm, tableKeyPrefix + ".D")
    if baseDelta < 0.0
        return baseDelta
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace >= 0
        Float originDelta = StorageUtil.GetFloatValue(deityForm, tableKeyPrefix + ".O" + originRace + ".D")
        if originDelta < 0.0
            return originDelta
        endIf
    endIf

    return 0.0
EndFunction

Bool Function HasDisfavorStanding(PDV_DeityBase deity)
    if !deity
        return False
    endIf
    if GetPatronState() == PATRON_STATE_ACTIVE && deity == _activeDeity
        return True
    endIf
    return GetPiety(deity) >= 25.0
EndFunction

Bool Function IsDisfavorRepeatSuppressed(PDV_DeityBase deity, Int domainValue, Int eventType)
    Int currentDay = GetDisfavorDayIndex()
    return StorageUtil.GetIntValue(deity as Form, GetDisfavorRepeatDayKey(domainValue, eventType), -1) == currentDay
EndFunction

Function MarkDisfavorRepeatUsed(PDV_DeityBase deity, Int domainValue, Int eventType)
    if !deity
        return
    endIf
    StorageUtil.SetIntValue(deity as Form, GetDisfavorRepeatDayKey(domainValue, eventType), GetDisfavorDayIndex())
EndFunction

Int Function GetDisfavorDayIndex()
    Float adjustedDayTime = Utility.GetCurrentGameTime() - 0.25
    return adjustedDayTime as Int
EndFunction

Int Function DomainForDeity(PDV_DeityBase deity)
    if deity == PDV_Kyne || deity == PDV_Kynareth || deity == PDV_Khenarthi || deity == PDV_HoonDing
        return DISFAVOR_DOMAIN_SKY_STORM_HUNT
    elseIf deity == PDV_Arkay || deity == PDV_Tuwhacca || deity == PDV_Xarxes || deity == PDV_Magnus
        return DISFAVOR_DOMAIN_DEATH_ANCESTORS
    elseIf deity == PDV_Mara || deity == PDV_Stendarr || deity == PDV_Dibella || deity == PDV_Stuhn
        return DISFAVOR_DOMAIN_MERCY_PROTECTION
    elseIf deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Talos || deity == PDV_Leki || deity == PDV_Trinimac || deity == PDV_Malacath
        return DISFAVOR_DOMAIN_WAR_HONOR
    elseIf deity == PDV_Zenithar || deity == PDV_Julianos || deity == PDV_Akatosh || deity == PDV_Zen || deity == PDV_Yffre || deity == PDV_AuriEl
        return DISFAVOR_DOMAIN_ORDER_TRADE_LORE
    elseIf deity == PDV_Azura || deity == PDV_Rajhin || deity == PDV_BaanDar || deity == PDV_Alkosh
        return DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
    elseIf deity == PDV_Sithis || deity == PDV_Mephala || deity == PDV_Hist || deity == PDV_Boethiah
        return DISFAVOR_DOMAIN_VOID_SECRETS
    endIf

    return DISFAVOR_DOMAIN_NONE
EndFunction

Function UpdateDisfavorStingRuntime()
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_SKY_STORM_HUNT)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_DEATH_ANCESTORS)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_MERCY_PROTECTION)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_WAR_HONOR)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_ORDER_TRADE_LORE)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_MOON_LUCK_SHADOW)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_VOID_SECRETS)
EndFunction

Function ClearDisfavorIfExpired(Int domainValue)
    if !IsDisfavorDomainActive(domainValue)
        return
    endIf

    Float expiresAt = StorageUtil.GetFloatValue(None, GetDisfavorExpiryKey(domainValue))
    if expiresAt > 0.0 && Utility.GetCurrentGameTime() < expiresAt
        return
    endIf

    ClearDisfavorDomain(domainValue, "expired")
EndFunction

Function ClearDisfavorDomain(Int domainValue, String reason)
    Actor playerRef = Game.GetPlayer()
    if playerRef
        ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    endIf
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 0)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), 0.0)
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), "")
    Trace(2, "Disfavor sting cleared: " + GetDisfavorDomainLabel(domainValue) + " (" + reason + ")")
EndFunction

Function ClearDisfavorDomainSpellOnly(Actor playerRef, Int domainValue)
    if !playerRef
        return
    endIf

    Spell lightSpell = GetDisfavorSpell(domainValue, False)
    Spell sharpSpell = GetDisfavorSpell(domainValue, True)
    if lightSpell && playerRef.HasSpell(lightSpell)
        playerRef.RemoveSpell(lightSpell)
    endIf
    if sharpSpell && playerRef.HasSpell(sharpSpell)
        playerRef.RemoveSpell(sharpSpell)
    endIf
EndFunction

Bool Function IsDisfavorDomainActive(Int domainValue)
    return StorageUtil.GetIntValue(None, GetDisfavorActiveKey(domainValue)) == 1
EndFunction

Int Function CountActiveDisfavorStings()
    Int activeCount = 0
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_SKY_STORM_HUNT)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_DEATH_ANCESTORS)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_MERCY_PROTECTION)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_WAR_HONOR)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_ORDER_TRADE_LORE)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_MOON_LUCK_SHADOW)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_VOID_SECRETS)
        activeCount += 1
    endIf
    return activeCount
EndFunction

Spell Function GetDisfavorSpell(Int domainValue, Bool sharpBand)
    if domainValue == DISFAVOR_DOMAIN_SKY_STORM_HUNT
        if sharpBand
            return PDV_SPEL_Disfavor_SkyStormHunt_Sharp
        endIf
        return PDV_SPEL_Disfavor_SkyStormHunt_Light
    elseIf domainValue == DISFAVOR_DOMAIN_DEATH_ANCESTORS
        if sharpBand
            return PDV_SPEL_Disfavor_DeathAncestors_Sharp
        endIf
        return PDV_SPEL_Disfavor_DeathAncestors_Light
    elseIf domainValue == DISFAVOR_DOMAIN_MERCY_PROTECTION
        if sharpBand
            return PDV_SPEL_Disfavor_MercyProtection_Sharp
        endIf
        return PDV_SPEL_Disfavor_MercyProtection_Light
    elseIf domainValue == DISFAVOR_DOMAIN_WAR_HONOR
        if sharpBand
            return PDV_SPEL_Disfavor_WarHonor_Sharp
        endIf
        return PDV_SPEL_Disfavor_WarHonor_Light
    elseIf domainValue == DISFAVOR_DOMAIN_ORDER_TRADE_LORE
        if sharpBand
            return PDV_SPEL_Disfavor_OrderTradeLore_Sharp
        endIf
        return PDV_SPEL_Disfavor_OrderTradeLore_Light
    elseIf domainValue == DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
        if sharpBand
            return PDV_SPEL_Disfavor_MoonLuckShadow_Sharp
        endIf
        return PDV_SPEL_Disfavor_MoonLuckShadow_Light
    elseIf domainValue == DISFAVOR_DOMAIN_VOID_SECRETS
        if sharpBand
            return PDV_SPEL_Disfavor_VoidSecrets_Sharp
        endIf
        return PDV_SPEL_Disfavor_VoidSecrets_Light
    endIf

    return None
EndFunction

Float Function GetDisfavorDurationDays(Bool sharpBand)
    if sharpBand
        return DISFAVOR_SHARP_DURATION_DAYS
    endIf
    return DISFAVOR_LIGHT_DURATION_DAYS
EndFunction

String Function GetDisfavorBandLabel(Bool sharpBand)
    if sharpBand
        return "sharp"
    endIf
    return "light"
EndFunction

String Function GetDisfavorDomainLabel(Int domainValue)
    if domainValue == DISFAVOR_DOMAIN_SKY_STORM_HUNT
        return "SkyStormHunt"
    elseIf domainValue == DISFAVOR_DOMAIN_DEATH_ANCESTORS
        return "DeathAncestors"
    elseIf domainValue == DISFAVOR_DOMAIN_MERCY_PROTECTION
        return "MercyProtection"
    elseIf domainValue == DISFAVOR_DOMAIN_WAR_HONOR
        return "WarHonor"
    elseIf domainValue == DISFAVOR_DOMAIN_ORDER_TRADE_LORE
        return "OrderTradeLore"
    elseIf domainValue == DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
        return "MoonLuckShadow"
    elseIf domainValue == DISFAVOR_DOMAIN_VOID_SECRETS
        return "VoidSecrets"
    endIf

    return "None"
EndFunction

String Function GetDisfavorActiveKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".Active"
EndFunction

String Function GetDisfavorExpiryKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".ExpiresAt"
EndFunction

String Function GetDisfavorBandKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".Band"
EndFunction

String Function GetDisfavorRepeatDayKey(Int domainValue, Int eventType)
    return "PDV.Disfavor.Repeat." + domainValue + "." + eventType + ".Day"
EndFunction

; ---------------------------------------------------------------------------
; Debug-only disfavor harness. Called ONLY from the MCM Debug page so a tester
; can prove the dislike losses + the 7 disfavor domain stings from menu clicks
; instead of performing each transgression in-world. No organic caller, no
; economy/dispatch change: DebugFireDislike routes the real dispatch entrypoint,
; the domain-sting path mirrors ApplyDisfavorSting's spell/expiry writes exactly.
; ---------------------------------------------------------------------------

; Fire the real dislike loss + sting path for one (deity, event) pair. Reads the
; live table delta the same way the runtime does; a non-negative delta means the
; deity has no dislike row for this event, so nothing fires. Clears the per-day
; repeat guard first so back-to-back fires on the same game-day are not suppressed.
Function DebugFireDislike(PDV_DeityBase deity, Int eventType)
    if !deity
        Trace(1, "DebugFireDislike skipped: no deity.")
        return
    endIf
    if !IsGenericLikesDislikesDeityReachable(deity)
        Trace(1, "DebugFireDislike: " + deity.DeityName + " is not reachable in the current origin/baseline.")
        return
    endIf
    Float delta = GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        Trace(1, "DebugFireDislike: no dislike row for " + deity.DeityName + " event " + eventType)
        return
    endIf
    Int domainValue = DomainForDeity(deity)
    if domainValue != DISFAVOR_DOMAIN_NONE
        StorageUtil.SetIntValue(deity as Form, GetDisfavorRepeatDayKey(domainValue, eventType), -1)
    endIf
    Bool nativeSurface = ShouldSurfaceLikesDislikesEvent(eventType)
    AwardPietyFromLikesDislikes(deity, delta, eventType, "debug_fire_dislike")
    if !nativeSurface
        SurfaceDebugDislikeEvent(deity, delta, eventType)
    endIf
    Trace(1, "DebugFireDislike: " + deity.DeityName + " event " + eventType + " delta " + delta)
EndFunction

; Directly add a domain sting spell + register its expiry the same way
; ApplyDisfavorSting does, so the eyeball check uses the real spell + real expiry.
; Bypasses the standing/repeat/cap gates on purpose (raw MGEF inspection).
Function DebugApplyDomainSting(Int domainValue, Bool sharp)
    ApplyDebugDomainSting(domainValue, sharp, False)
EndFunction

; Shared core for the debug sting apply. respectCap reproduces ApplyDisfavorSting's
; active-domain cap so DebugBurstAntiStack can demonstrate the 4th distinct domain
; is suppressed at the cap. Returns True when the sting was applied.
Bool Function ApplyDebugDomainSting(Int domainValue, Bool sharp, Bool respectCap)
    if domainValue < DISFAVOR_DOMAIN_SKY_STORM_HUNT || domainValue > DISFAVOR_DOMAIN_VOID_SECRETS
        Trace(1, "DebugApplyDomainSting skipped: bad domain " + domainValue)
        return False
    endIf
    UpdateDisfavorStingRuntime()
    Bool domainAlreadyActive = IsDisfavorDomainActive(domainValue)
    if respectCap && !domainAlreadyActive && CountActiveDisfavorStings() >= DISFAVOR_MAX_ACTIVE_DOMAINS
        Trace(2, "DebugApplyDomainSting suppressed by active-domain cap: " + GetDisfavorDomainLabel(domainValue))
        return False
    endIf
    Spell targetSpell = GetDisfavorSpell(domainValue, sharp)
    if !targetSpell
        Trace(1, "DebugApplyDomainSting skipped: missing spell for " + GetDisfavorDomainLabel(domainValue))
        return False
    endIf
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return False
    endIf
    ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    playerRef.AddSpell(targetSpell, False)
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 1)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), Utility.GetCurrentGameTime() + GetDisfavorDurationDays(sharp))
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), GetDisfavorBandLabel(sharp))
    Trace(1, "DebugApplyDomainSting applied: " + GetDisfavorDomainLabel(domainValue) + " " + GetDisfavorBandLabel(sharp))
    return True
EndFunction

; Clear first, then fire 4 distinct-domain stings (Sky, Death, War, Order) with the
; cap respected, so the tester sees 3 active and the 4th suppressed at the cap.
Function DebugBurstAntiStack()
    ClearAllDisfavorStings()
    ApplyDebugDomainSting(DISFAVOR_DOMAIN_SKY_STORM_HUNT, True, True)
    ApplyDebugDomainSting(DISFAVOR_DOMAIN_DEATH_ANCESTORS, True, True)
    ApplyDebugDomainSting(DISFAVOR_DOMAIN_WAR_HONOR, True, True)
    ApplyDebugDomainSting(DISFAVOR_DOMAIN_ORDER_TRADE_LORE, True, True)
    Trace(1, "DebugBurstAntiStack: " + GetActiveDisfavorSummary())
EndFunction

; One-line readout of every active disfavor domain with its band + remaining
; game-minutes; "none" when empty. Clears expired stings first so the count is live.
String Function GetActiveDisfavorSummary()
    UpdateDisfavorStingRuntime()
    String summary = ""
    Int domainValue = DISFAVOR_DOMAIN_SKY_STORM_HUNT
    while domainValue <= DISFAVOR_DOMAIN_VOID_SECRETS
        if IsDisfavorDomainActive(domainValue)
            Float expiresAt = StorageUtil.GetFloatValue(None, GetDisfavorExpiryKey(domainValue))
            Int remainMinutes = ((expiresAt - Utility.GetCurrentGameTime()) * 24.0 * 60.0) as Int
            if remainMinutes < 0
                remainMinutes = 0
            endIf
            String band = StorageUtil.GetStringValue(None, GetDisfavorBandKey(domainValue))
            if band == ""
                band = "?"
            endIf
            if summary != ""
                summary += "; "
            endIf
            summary += GetDisfavorDomainLabel(domainValue) + " " + band + " (~" + remainMinutes + "m)"
        endIf
        domainValue += 1
    endWhile
    if summary == ""
        return "Active disfavor: none (0/" + DISFAVOR_MAX_ACTIVE_DOMAINS + ")."
    endIf
    return "Active disfavor (" + CountActiveDisfavorStings() + "/" + DISFAVOR_MAX_ACTIVE_DOMAINS + "): " + summary
EndFunction

; Remove every active disfavor spell + clear its active/expiry/band keys, reusing
; the runtime's own ClearDisfavorDomain so the removal path matches expiry cleanup.
Function ClearAllDisfavorStings()
    Int domainValue = DISFAVOR_DOMAIN_SKY_STORM_HUNT
    while domainValue <= DISFAVOR_DOMAIN_VOID_SECRETS
        if IsDisfavorDomainActive(domainValue)
            ClearDisfavorDomain(domainValue, "debug_clear")
        endIf
        domainValue += 1
    endWhile
EndFunction

; Debug label helper: does the selected deity dislike this event, at what delta,
; into which domain? Lets the MCM button hint tell the tester whether a fire will land.
String Function DebugDislikeSummaryLine(PDV_DeityBase deity, Int eventType)
    if !deity
        return "event " + eventType + " | no deity"
    endIf
    if !IsGenericLikesDislikesDeityReachable(deity)
        return "event " + eventType + " | " + deity.DeityName + " | not current pantheon"
    endIf
    Float delta = GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        return "event " + eventType + " | " + deity.DeityName + " | no dislike row"
    endIf
    return "event " + eventType + " | " + deity.DeityName + " | " + delta + " -> " + GetDisfavorDomainLabel(DomainForDeity(deity))
EndFunction

; Per-deity recent-driver ring (the acts that recently moved this god), keyed on the
; deity form, capped at 6 FIFO. Powers the dashboard's "recent drivers".
Function RecordDeityDriver(PDV_DeityBase deity, String reason, Float delta)
    Form deityForm = deity as Form
    String humanized = HumanizeDriverReason(reason)
    while StorageUtil.StringListCount(deityForm, "PDV.Driver.Reasons") >= 6
        StorageUtil.StringListRemoveAt(deityForm, "PDV.Driver.Reasons", 0)
        StorageUtil.FloatListRemoveAt(deityForm, "PDV.Driver.Deltas", 0)
        StorageUtil.IntListRemoveAt(deityForm, "PDV.Driver.Days", 0)
    endWhile
    StorageUtil.StringListAdd(deityForm, "PDV.Driver.Reasons", humanized, True)
    StorageUtil.FloatListAdd(deityForm, "PDV.Driver.Deltas", delta, True)
    StorageUtil.IntListAdd(deityForm, "PDV.Driver.Days", Utility.GetCurrentGameTime() as Int, True)
EndFunction

; Map a raw routing/signal tag to a short player-facing driver phrase. Owner rule:
; phrases plainly describe the trigger ("a quest paid in gold"), never flavor copy --
; the deity card header supplies the mood; the row teaches the mechanics.
String Function HumanizeDriverReason(String raw)
    if raw == ""
        return "An act of devotion"
    endIf
    ; A reason carrying the display sentinel is ALREADY finished player-facing copy
    ; (a per-signal curated phrase from HumanizeCuratedSignalReason). Strip the marker
    ; and store it verbatim; do NOT re-humanize, which would drop the specific phrase
    ; to a generic fallback. Every other reason is a routing token resolved below.
    String dispMark = DisplayReasonMarker()
    if StringUtil.Find(raw, dispMark) == 0
        return StringUtil.Substring(raw, StringUtil.GetLength(dispMark))
    endIf
    if StringContainsToken(raw, "meta_zen_wage")
        return "a quest paid in gold"
    elseIf StringContainsToken(raw, "meta_julianos_wisdom")
        return "a mage-aid quest"
    elseIf StringContainsToken(raw, "meta_azura_threshold")
        return "a quest at twilight or aiding mages"
    elseIf StringContainsToken(raw, "meta_nocturnal_herway")
        return "a quest done after stealing"
    elseIf StringContainsToken(raw, "meta_nocturnal_dark")
        return "a quest done at night"
    elseIf StringContainsToken(raw, "meta_khenarthi_road")
        return "a quest finished outdoors"
    elseIf StringContainsToken(raw, "meta_akatosh_wheel")
        return "every tenth quest"
    elseIf StringContainsToken(raw, "meta_xarxes_record")
        return "every tenth quest"
    elseIf StringContainsToken(raw, "wayfarer_akatosh_level")
        return "leveling up under Wayfarer's Path"
    elseIf StringContainsToken(raw, "talos-shrine-defiance")
        return "defiant prayer at a Talos shrine"
    elseIf StringContainsToken(raw, "talos_betrayal_major")
        return "turning on Talos openly"
    elseIf StringContainsToken(raw, "talos_betrayal_compliance")
        return "bending to the Talos ban"
    elseIf StringContainsToken(raw, "imperial-talos-pressure")
        return "Concordat pressure over Talos"
    elseIf StringContainsToken(raw, "concordat-compliance")
        return "complying with the Concordat"
    elseIf StringContainsToken(raw, "concordat-defiance")
        return "defying the Concordat"
    elseIf StringContainsToken(raw, "imperial-patron-civic-favor")
        return "civic service (patron bonus)"
    elseIf StringContainsToken(raw, "imperial-civic-service")
        return "civic service"
    elseIf StringContainsToken(raw, "nord-old-ways-state")
        return "keeping the Old Ways"
    elseIf StringContainsToken(raw, "nord-kyne-talos-context")
        return "the Old Ways beside Talos"
    elseIf StringContainsToken(raw, "nord-hircine-arkay-edge")
        return "the hunt at Arkay's edge"
    elseIf StringContainsToken(raw, "sleep-moon-observance")
        return "sleeping under aligned moons"
    elseIf StringContainsToken(raw, "khajiit-road-home")
        return "returning by the road home"
    elseIf StringContainsToken(raw, "khajiit-baandar-road-trick")
        return "a trick on the road"
    elseIf StringContainsToken(raw, "khajiit-rajhin-elegant-theft")
        return "an artful theft"
    elseIf StringContainsToken(raw, "khajiit-alkosh-dragon-order")
        return "keeping dragon order"
    elseIf StringContainsToken(raw, "hircine-hunt-rite")
        return "a ritual hunt"
    elseIf StringContainsToken(raw, "green-pact-violation")
        return "breaking the Green Pact"
    elseIf StringContainsToken(raw, "bosmer-old-contract-proper-hunt")
        return "a proper hunt"
    elseIf StringContainsToken(raw, "bosmer-old-contract-forest-kept")
        return "keeping the forest"
    elseIf StringContainsToken(raw, "bosmer-living-story-community")
        return "sharing the living story"
    elseIf StringContainsToken(raw, "bosmer-living-story-nature-site")
        return "a tale at a wild place"
    elseIf StringContainsToken(raw, "bosmer-living-story")
        return "a Living Story deed"
    elseIf StringContainsToken(raw, "bosmer-exchange-debt-settled")
        return "settling a debt"
    elseIf StringContainsToken(raw, "bosmer-exchange-proportionate-vengeance")
        return "measured vengeance"
    elseIf StringContainsToken(raw, "bosmer-exchange")
        return "an Exchange deed"
    elseIf StringContainsToken(raw, "bosmer-bandit-road-road-life")
        return "living the road life"
    elseIf StringContainsToken(raw, "bosmer-bandit-road-reversal")
        return "a reversal on the road"
    elseIf StringContainsToken(raw, "bosmer-bandit-road")
        return "a Bandit Road deed"
    elseIf StringContainsToken(raw, "bosmer-pact-positive")
        return "keeping the Green Pact"
    elseIf StringContainsToken(raw, "dunmer-portable-shrine")
        return "prayer at your portable shrine"
    elseIf StringContainsToken(raw, "dunmer-home-bonus")
        return "devotions kept at home"
    elseIf StringContainsToken(raw, "dunmer-reclamation-focus")
        return "focus on the Reclamations"
    elseIf StringContainsToken(raw, "dunmer-deviation-price")
        return "straying from the Reclamations"
    elseIf StringContainsToken(raw, "altmer-lorkhan-pressure")
        return "leaning toward Lorkhan"
    elseIf StringContainsToken(raw, "altmer-crisis-source")
        return "feeding the crisis of faith"
    elseIf StringContainsToken(raw, "altmer-dawn-steadiness")
        return "steadiness at dawn"
    elseIf StringContainsToken(raw, "altmer-orthodox-cost")
        return "the cost of orthodoxy paid"
    elseIf StringContainsToken(raw, "argonian-hist-maintenance")
        return "tending the Hist bond"
    elseIf StringContainsToken(raw, "argonian-people-support")
        return "supporting the People"
    elseIf StringContainsToken(raw, "argonian-void-signal")
        return "a step toward the Void"
    elseIf StringContainsToken(raw, "argonian-bed-of-choice")
        return "rest in your chosen bed"
    elseIf StringContainsToken(raw, "orc-stronghold-forge")
        return "forge work in a stronghold"
    elseIf StringContainsToken(raw, "orc-city-dignity")
        return "dignity kept in city life"
    elseIf StringContainsToken(raw, "orc-legion-service")
        return "service with the Legion"
    elseIf StringContainsToken(raw, "orc-self-made-community")
        return "building a community"
    elseIf StringContainsToken(raw, "orc-oath-break")
        return "breaking an oath"
    elseIf StringContainsToken(raw, "orc-four-holds-visit")
        return "visiting the four holds"
    elseIf StringContainsToken(raw, "redguard-crown-tomb-respect")
        return "respect at a Crown tomb"
    elseIf StringContainsToken(raw, "redguard-forebear-road")
        return "walking the Forebear road"
    elseIf StringContainsToken(raw, "redguard-ashabah-death-duty")
        return "putting down the risen dead"
    elseIf StringContainsToken(raw, "redguard-far-shores-token")
        return "a Far Shores token earned"
    elseIf StringContainsToken(raw, "breton-tradition-choice")
        return "choosing a tradition"
    elseIf StringContainsToken(raw, "breton-knightly-vow")
        return "keeping a knightly vow"
    elseIf StringContainsToken(raw, "breton-hidden-art-exposure")
        return "a hidden art exposed"
    elseIf StringContainsToken(raw, "breton-green-way-standing")
        return "standing with the Green Way"
    elseIf StringContainsToken(raw, "state-transition-confirm-rite")
        return "a rite confirming your path"
    elseIf StringContainsToken(raw, "daedric-prince-signal")
        return "a deed the Prince claims"
    elseIf StringContainsToken(raw, "daedric-generic-silence")
        return "silence from the Princes"
    elseIf StringContainsToken(raw, "shout-to-open-sky")
        return "a shout to the open sky"
    elseIf StringContainsToken(raw, "rest-under-open-sky")
        return "resting under the open sky"
    elseIf StringContainsToken(raw, "sleep-in-bed")
        return "sleeping in a bed"
    elseIf StringContainsToken(raw, "take-blessing")
        return "taking a shrine blessing"
    elseIf StringContainsToken(raw, "Trial of Iron")
        return "taking up the Trial of Iron"
    elseIf StringContainsToken(raw, "Remembering of Names")
        return "taking up the Remembering of Names"
    elseIf StringContainsToken(raw, "Discipline of Return")
        return "setting a Discipline of Return"
    elseIf StringContainsToken(raw, "cc_fishing")
        return "fishing"
    elseIf StringContainsToken(raw, "commitment_carryover")
        return "devotion carried into commitment"
    elseIf StringContainsToken(raw, "rivalry with")
        return raw
    elseIf StringContainsToken(raw, "read-skill-book")
        return "reading instructive texts"
    elseIf StringContainsToken(raw, "read-spell-tome")
        return "reading a spell tome"
    elseIf StringContainsToken(raw, "read-lore-book")
        return "reading a lore book"
    elseIf StringContainsToken(raw, "po3_book") || StringContainsToken(raw, "book")
        return "reading a book"
    elseIf StringContainsToken(raw, "increase-skill")
        return "honing your skills"
    elseIf StringContainsToken(raw, "discover-location")
        return "discovering new roads"
    elseIf StringContainsToken(raw, "learn-word-of-power")
        return "learning a Word of Power"
    elseIf StringContainsToken(raw, "shout") || StringContainsToken(raw, "voice")
        return "using a shout"
    elseIf StringContainsToken(raw, "shrine") || StringContainsToken(raw, "prayer") || StringContainsToken(raw, "pray")
        return "prayer at a shrine"
    elseIf StringContainsToken(raw, "harvest-ingredient")
        return "harvesting ingredients"
    elseIf StringContainsToken(raw, "brew-potion")
        return "brewing potions"
    elseIf StringContainsToken(raw, "smith-item")
        return "smithing an item"
    elseIf StringContainsToken(raw, "enchant-item")
        return "enchanting an item"
    elseIf StringContainsToken(raw, "cook-meal")
        return "cooking a meal"
    elseIf StringContainsToken(raw, "mine-or-chop")
        return "mining or woodcutting"
    elseIf StringContainsToken(raw, "kill-daedra")
        return "killing Daedra"
    elseIf StringContainsToken(raw, "kill-undead")
        return "killing undead"
    elseIf StringContainsToken(raw, "kill-dragon")
        return "killing a dragon"
    elseIf StringContainsToken(raw, "killed-hostile-beast")
        return "killing hostile beasts"
    elseIf StringContainsToken(raw, "killed-hostile-humanoid")
        return "killing hostile people"
    elseIf StringContainsToken(raw, "kill-animal-noncombat")
        return "killing harmless animals"
    elseIf StringContainsToken(raw, "murder-defenseless")
        return "murdering the defenseless"
    elseIf StringContainsToken(raw, "assault-innocent")
        return "assaulting an innocent"
    elseIf StringContainsToken(raw, "kill") || StringContainsToken(raw, "combat") || StringContainsToken(raw, "hunt")
        return "combat or hunting kills"
    elseIf StringContainsToken(raw, "heal-or-cure-npc")
        return "healing or curing someone"
    elseIf StringContainsToken(raw, "clear-bounty")
        return "paying off a bounty"
    elseIf StringContainsToken(raw, "pick-owned-lock")
        return "picking an owned lock"
    elseIf StringContainsToken(raw, "trespass")
        return "trespassing"
    elseIf StringContainsToken(raw, "steal-item")
        return "stealing an item"
    elseIf StringContainsToken(raw, "pickpocket")
        return "pickpocketing"
    elseIf StringContainsToken(raw, "raise-undead")
        return "raising undead"
    elseIf StringContainsToken(raw, "vampire-feed")
        return "feeding as a vampire"
    elseIf StringContainsToken(raw, "accept-daedric-artifact")
        return "accepting a Daedric artifact"
    elseIf StringContainsToken(raw, "quest")
        return "completing a quest"
    elseIf StringContainsToken(raw, "curated") || StringContainsToken(raw, "rite")
        return "a devotional rite"
    endIf

    ; Quest-matrix reasons arrive as "DeityName.tag_one,tag_two" (semantic act tags
    ; from the reaction CSVs). Render the primary tag as plain trigger text
    ; ("quest: forbidden knowledge") instead of the generic fallback. Meta lanes and
    ; rivalry reasons matched above, so only cell tags reach this branch.
    Int dotIndex = StringUtil.Find(raw, ".")
    if dotIndex > 0 && dotIndex < StringUtil.GetLength(raw) - 1
        String tagText = StringUtil.Substring(raw, dotIndex + 1)
        String[] tagParts = StringUtil.Split(tagText, ",")
        tagParts = StringUtil.Split(tagParts[0], ":")
        String[] tagWords = StringUtil.Split(tagParts[0], "_")
        String prettyTag = ""
        Int wordIndex = 0
        while wordIndex < tagWords.Length
            if wordIndex > 0
                prettyTag = prettyTag + " "
            endIf
            prettyTag = prettyTag + tagWords[wordIndex]
            wordIndex += 1
        endWhile
        if prettyTag != ""
            return "quest: " + prettyTag
        endIf
    endIf

    return "An act of devotion"
EndFunction

String Function HumanizeCuratedSignalReason(PDV_DeityBase deity, Int signalType)
    if !deity
        return "a devotional rite"
    endIf

    if PDV_Talos && deity == PDV_Talos
        if signalType == PDV_Talos.SIGNAL_SHRINE_DEFIANCE
            return "defiant prayer at a Talos shrine"
        elseIf signalType == PDV_Talos.SIGNAL_PROTECT_WORSHIPPER
            return "protecting a Talos worshipper"
        elseIf signalType == PDV_Talos.SIGNAL_DEFIANCE_MILESTONE
            return "defiance of the Talos ban"
        elseIf signalType == PDV_Talos.SIGNAL_ANCESTOR_SPINE
            return "public civic service"
        endIf
    elseIf PDV_AuriEl && deity == PDV_AuriEl
        if signalType == PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT
            return "dawn observance"
        elseIf signalType == PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION
            return "orthodox lore study"
        elseIf signalType == PDV_AuriEl.SIGNAL_ANCESTOR_SPINE
            return "Altmer ancestor rites"
        endIf
    elseIf PDV_Yffre && deity == PDV_Yffre
        if signalType == PDV_Yffre.SIGNAL_PACT_POSITIVE
            return "keeping the Green Pact"
        elseIf signalType == PDV_Yffre.SIGNAL_LIVING_STORY
            return "a Living Story deed"
        elseIf signalType == PDV_Yffre.SIGNAL_PACT_VIOLATION
            return "breaking the Green Pact"
        elseIf signalType == PDV_Yffre.SIGNAL_RECOMMITMENT
            return "recommitting to the Green Pact"
        elseIf signalType == PDV_Yffre.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        elseIf signalType == PDV_Yffre.SIGNAL_GREEN_WAY
            return "keeping the Green Way"
        endIf
    elseIf PDV_Zen && deity == PDV_Zen
        if signalType == PDV_Zen.SIGNAL_EXCHANGE
            return "fair exchange"
        elseIf signalType == PDV_Zen.SIGNAL_CONFIRMATION
            return "a rite confirming your path"
        elseIf signalType == PDV_Zen.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        endIf
    elseIf PDV_BaanDar && deity == PDV_BaanDar
        if signalType == PDV_BaanDar.SIGNAL_BANDIT_ROAD
            return "a Bandit Road deed"
        elseIf signalType == PDV_BaanDar.SIGNAL_ROAD_TRICK
            return "roadside cunning"
        elseIf signalType == PDV_BaanDar.SIGNAL_CONFIRMATION
            return "a rite confirming your path"
        elseIf signalType == PDV_BaanDar.SIGNAL_BETRAYAL
            return "betraying someone who trusted you"
        elseIf signalType == PDV_BaanDar.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        endIf
    elseIf PDV_Khenarthi && deity == PDV_Khenarthi
        if signalType == PDV_Khenarthi.SIGNAL_ROAD_HOME
            return "returning by the road home"
        elseIf signalType == PDV_Khenarthi.SIGNAL_OPEN_ROAD
            return "fair weather on the open road"
        elseIf signalType == PDV_Khenarthi.SIGNAL_CARAVAN_AID
            return "aiding a caravan"
        elseIf signalType == PDV_Khenarthi.SIGNAL_CARAVAN_HARM
            return "harming a caravan"
        endIf
    elseIf PDV_Azura && deity == PDV_Azura
        if signalType == PDV_Azura.SIGNAL_MOON_OBSERVANCE
            return "moon observance"
        elseIf signalType == PDV_Azura.SIGNAL_THRESHOLD_RITE
            return "a threshold rite"
        elseIf signalType == PDV_Azura.SIGNAL_ANCESTOR_SPINE
            return "Dunmer ancestor rites"
        elseIf signalType == PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE
            return "a twilight rite of the Reclamations"
        elseIf signalType == PDV_Azura.SIGNAL_DESECRATION
            return "desecration"
        endIf
    elseIf PDV_Rajhin && deity == PDV_Rajhin
        if signalType == PDV_Rajhin.SIGNAL_ELEGANT_THEFT
            return "artful theft"
        elseIf signalType == PDV_Rajhin.SIGNAL_LEGEND_MADE
            return "a legendary heist"
        elseIf signalType == PDV_Rajhin.SIGNAL_BOTCHED_THEFT
            return "a botched theft"
        endIf
    elseIf PDV_Alkosh && deity == PDV_Alkosh
        if signalType == PDV_Alkosh.SIGNAL_DRAGON_ORDER
            return "keeping dragon order"
        elseIf signalType == PDV_Alkosh.SIGNAL_NAMED_DRAGON
            return "defeating a named dragon"
        elseIf signalType == PDV_Alkosh.SIGNAL_CHAOS_AID
            return "aiding the Dragon Cult"
        endIf
    elseIf PDV_Hist && deity == PDV_Hist
        if signalType == PDV_Hist.SIGNAL_HIST_PULSE
            return "answering the Hist"
        elseIf signalType == PDV_Hist.SIGNAL_HIST_ABANDONMENT
            return "abandoning the Hist"
        elseIf signalType == PDV_Hist.SIGNAL_HIST_CORRUPTION
            return "corrupting Hist memory"
        elseIf signalType == PDV_Hist.SIGNAL_VOID_OVERREACH
            return "overreaching into the Void"
        endIf
    elseIf PDV_Sithis && deity == PDV_Sithis
        if signalType == PDV_Sithis.SIGNAL_VOID_THRESHOLD
            return "crossing a Void threshold"
        elseIf signalType == PDV_Sithis.SIGNAL_VOID_MILESTONE
            return "a deeper turn toward the Void"
        endIf
    elseIf PDV_Malacath && deity == PDV_Malacath
        if signalType == PDV_Malacath.SIGNAL_STRONGHOLD_FORGE
            return "stronghold forge work"
        elseIf signalType == PDV_Malacath.SIGNAL_CITY_DIGNITY
            return "dignity kept in city life"
        elseIf signalType == PDV_Malacath.SIGNAL_LEGION_SERVICE
            return "Legion service"
        elseIf signalType == PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY
            return "building a community"
        elseIf signalType == PDV_Malacath.SIGNAL_BROAD_CONDUCT
            return "keeping the code"
        elseIf signalType == PDV_Malacath.SIGNAL_ANCESTOR_SPINE
            return "rest at your declared hearth"
        elseIf signalType == PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE
            return "breaking the code by curse"
        elseIf signalType == PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN
            return "breaking faith with kin"
        elseIf signalType == PDV_Malacath.SIGNAL_BLOOD_KIN
            return "standing with your Blood-Kin"
        elseIf signalType == PDV_Malacath.SIGNAL_EXILE_RETURN
            return "carrying a burden home from exile"
        elseIf signalType == PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT
            return "reaching an Orc stronghold"
        elseIf signalType == PDV_Malacath.SIGNAL_OATH_BREAK
            return "breaking an oath"
        endIf
    elseIf PDV_Tuwhacca && deity == PDV_Tuwhacca
        if signalType == PDV_Tuwhacca.SIGNAL_CROWN_FORM
            return "keeping Crown form"
        elseIf signalType == PDV_Tuwhacca.SIGNAL_DEATH_DUTY
            return "death duty"
        elseIf signalType == PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN
            return "honoring the Far Shores"
        elseIf signalType == PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE
            return "Yokudan ancestor rites"
        elseIf signalType == PDV_Tuwhacca.SIGNAL_VAMPIRE_REENTRY
            return "returning to the cycle after vampirism"
        elseIf signalType == PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT
            return "abandoning death duty"
        endIf
    elseIf PDV_Leki && deity == PDV_Leki
        if signalType == PDV_Leki.SIGNAL_SWORD_SINGING
            return "sword-singing"
        elseIf signalType == PDV_Leki.SIGNAL_HONORABLE_DUEL
            return "an honorable duel won"
        endIf
    elseIf PDV_HoonDing && deity == PDV_HoonDing
        if signalType == PDV_HoonDing.SIGNAL_MAKE_WAY
            return "making way past a mighty foe"
        endIf
    elseIf PDV_Magnus && deity == PDV_Magnus
        if signalType == PDV_Magnus.SIGNAL_DISCIPLINED_STUDY
            return "disciplined study"
        elseIf signalType == PDV_Magnus.SIGNAL_MAGIC_MILESTONE
            return "a magic milestone"
        elseIf signalType == PDV_Magnus.SIGNAL_ARCANE_RECOVERY
            return "recovering lost arcane knowledge"
        elseIf signalType == PDV_Magnus.SIGNAL_SHARED_PACT_MEMORY
            return "keeping faith with the arts"
        elseIf signalType == PDV_Magnus.SIGNAL_ANCESTOR_SPINE
            return "Breton ancestor rites"
        endIf
    elseIf PDV_Xarxes && deity == PDV_Xarxes
        if signalType == PDV_Xarxes.SIGNAL_LINEAGE_HONORED
            return "honoring lineage"
        elseIf signalType == PDV_Xarxes.SIGNAL_RECORD_KEEPING
            return "preserving knowledge and history"
        elseIf signalType == PDV_Xarxes.SIGNAL_LEDGER_RESTORED
            return "restoring a lost record"
        elseIf signalType == PDV_Xarxes.SIGNAL_SHARED_PACT_MEMORY
            return "keeping the long record"
        endIf
    elseIf PDV_Boethiah && deity == PDV_Boethiah
        if signalType == PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE
            return "righteous struggle"
        elseIf signalType == PDV_Boethiah.SIGNAL_HONORABLE_DUEL
            return "winning an honorable duel"
        elseIf signalType == PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY
            return "a deed for the Reclamations"
        elseIf signalType == PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED
            return "abandoning the Reclamations"
        endIf
    elseIf PDV_Mephala && deity == PDV_Mephala
        if signalType == PDV_Mephala.SIGNAL_SECRET_KEPT
            return "a secret kept"
        elseIf signalType == PDV_Mephala.SIGNAL_WEB_WOVEN
            return "weaving a plot by cunning"
        elseIf signalType == PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY
            return "a deed for the Reclamations"
        elseIf signalType == PDV_Mephala.SIGNAL_SECRET_BETRAYED
            return "a secret betrayed"
        elseIf signalType == PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED
            return "abandoning the Reclamations"
        endIf
    elseIf PDV_Akatosh && deity == PDV_Akatosh
        if signalType == PDV_Akatosh.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        elseIf signalType == PDV_Akatosh.SIGNAL_COVENANT_MILESTONE
            return "honoring the Covenant"
        endIf
    elseIf PDV_Mara && deity == PDV_Mara
        if signalType == PDV_Mara.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == PDV_Mara.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Arkay && deity == PDV_Arkay
        if signalType == PDV_Arkay.SIGNAL_DEATH_DUTY
            return "death duty"
        elseIf signalType == PDV_Arkay.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Stendarr && deity == PDV_Stendarr
        if signalType == PDV_Stendarr.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == PDV_Stendarr.SIGNAL_LAWFUL_ORDER
            return "upholding law and order"
        elseIf signalType == PDV_Stendarr.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Zenithar && deity == PDV_Zenithar
        if signalType == PDV_Zenithar.SIGNAL_HONEST_WORK
            return "honest work"
        elseIf signalType == PDV_Zenithar.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Julianos && deity == PDV_Julianos
        if signalType == PDV_Julianos.SIGNAL_LAWFUL_ORDER
            return "upholding law and order"
        elseIf signalType == PDV_Julianos.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Kynareth && deity == PDV_Kynareth
        if signalType == PDV_Kynareth.SIGNAL_OPEN_SKY
            return "deeds under the open sky"
        elseIf signalType == PDV_Kynareth.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Kyne && deity == PDV_Kyne
        if signalType == PDV_Kyne.SIGNAL_SKY_ROAD
            return "walking the sky road"
        endIf
    elseIf PDV_Tsun && deity == PDV_Tsun
        if signalType == PDV_Tsun.SIGNAL_TRIAL_ENDURED
            return "a trial endured"
        elseIf signalType == PDV_Tsun.SIGNAL_ADVERSITY_SURVIVED
            return "surviving hard adversity"
        elseIf signalType == PDV_Tsun.SIGNAL_ENDURANCE_VIGIL
            return "keeping an endurance vigil"
        endIf
    elseIf PDV_Stuhn && deity == PDV_Stuhn
        if signalType == PDV_Stuhn.SIGNAL_MERCY_GRANTED
            return "granting mercy to the beaten"
        elseIf signalType == PDV_Stuhn.SIGNAL_JUST_SPOILS
            return "claiming just spoils"
        elseIf signalType == PDV_Stuhn.SIGNAL_PROTECT_BOND
            return "protecting a bond"
        endIf
    elseIf PDV_Shor && deity == PDV_Shor
        if signalType == PDV_Shor.SIGNAL_HONORABLE_BATTLE
            return "an honorable battle"
        elseIf signalType == PDV_Shor.SIGNAL_HONORED_DEAD
            return "honoring the dead"
        elseIf signalType == PDV_Shor.SIGNAL_SOVNGARDE_VALOR
            return "valor worthy of Sovngarde"
        elseIf signalType == PDV_Shor.SIGNAL_ANCESTOR_SPINE
            return "Nord ancestor rites"
        endIf
    elseIf PDV_Dibella && deity == PDV_Dibella
        if signalType == PDV_Dibella.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == PDV_Dibella.SIGNAL_GRACE
            return "an act of grace"
        elseIf signalType == PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf PDV_Trinimac && deity == PDV_Trinimac
        if signalType == PDV_Trinimac.SIGNAL_FALLEN_GOD_ORTHODOXY
            return "honoring fallen Trinimac"
        elseIf signalType == PDV_Trinimac.SIGNAL_ALTMER_ORTHODOX_PRESSURE
            return "upholding elven orthodoxy"
        endIf
    endIf

    return "a devotional rite"
EndFunction

; Sentinel prefix that flags a reason string as ALREADY player-facing display copy.
; RecordDeityDriver runs every reason through HumanizeDriverReason before storing it;
; a reason carrying this marker is stored verbatim (marker stripped) instead of being
; re-humanized. The bracketed token can never collide with a real routing token
; (routing tokens never start with '['), and it is stripped before storage/display.
String Function DisplayReasonMarker()
    return "[disp]"
EndFunction

; Build the driver-ledger reason for a curated signal: the specific per-signal phrase
; from HumanizeCuratedSignalReason, marked so HumanizeDriverReason keeps it verbatim.
; This is the single wiring point that turns curated awards into distinct, trigger-
; stating Ledger rows instead of the generic "a devotional rite".
String Function CuratedSignalDriverReason(PDV_DeityBase deity, Int signalType)
    return DisplayReasonMarker() + HumanizeCuratedSignalReason(deity, signalType)
EndFunction

; Per-god rollup state for the Devotion dashboard, derived only from existing data
; (no new scoring). Precedence: neglected > starving > gaining > steady.
String Function GetGodRollupState(PDV_DeityBase deity)
    if !deity
        return "steady"
    endIf
    if IsNeglectFlagActive(deity)
        return "neglected"
    endIf
    Form deityForm = deity as Form
    Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float lastEvent = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    Float now = Utility.GetCurrentGameTime()
    if pietyToday > 0.5
        return "gaining"
    endIf
    if pietyToday < -0.5
        return "starving"
    endIf
    if piety > 0.0 && lastEvent > 0.0 && (now - lastEvent) >= DECAY_GRACE_DAYS
        return "starving"
    endIf
    return "steady"
EndFunction

Function HandleWayfarerAkatoshLevel()
    if !PDV_ModePresetRef || !PDV_ModePresetRef.AllowCheapRepeatables()
        return
    endIf
    if !PDV_Akatosh
        return
    endIf

    Float baseAmount = 1.0
    Float weight = PDV_ModePresetRef.CheapRepeatableWeight()
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")
    Float amount = baseAmount * weight * multiplier
    if amount > 0.0
        AwardPietyInternal(PDV_Akatosh, amount, True, "wayfarer_akatosh_level")
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
        if PDV_ModePresetRef
            appliedAmount = appliedAmount * PDV_ModePresetRef.GainMultiplier()
        endIf
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

;/ =====================================================================
    Creation Club / AE compatibility (SOFT OPTIONAL)
    ---------------------------------------------------------------------
    Optional, encouraged-not-required integration for supported Creation Club
    content. Detection is by filename, optional forms are cached once, and no
    Devotion.esp record takes a hard dependency on the CC masters.
    Form evidence: references/authoring/PDV_CCIntegration_Findings.md
   ===================================================================== /;
Bool _pdvCCContentInit = False
Bool _pdvCCSaintsPresent = False
Bool _pdvCCFishingPresent = False
Quest _pdvCCSaintsRestoringOrder
GlobalVariable _pdvCCFishingIsFishing
Int _pdvCCFishingLastFlag = 0

String Property COMPAT_CC_TOGGLE_KEY = "PDV.Compat.CCContentEnabled" AutoReadOnly

Function InitCCContent()
    if _pdvCCContentInit
        return
    endIf
    _pdvCCContentInit = True

    if Game.GetModByName("ccbgssse025-advdsgs.esm") != 255
        _pdvCCSaintsPresent = True
        _pdvCCSaintsRestoringOrder = Game.GetFormFromFile(0x000913, "ccbgssse025-advdsgs.esm") as Quest
    endIf

    if Game.GetModByName("ccbgssse001-fish.esm") != 255
        _pdvCCFishingPresent = True
        _pdvCCFishingIsFishing = Game.GetFormFromFile(0x000B26, "ccbgssse001-fish.esm") as GlobalVariable
    endIf
EndFunction

Bool Function IsCCContentEnabled()
    return StorageUtil.GetIntValue(None, COMPAT_CC_TOGGLE_KEY, 1) != 0
EndFunction

Function TryCCSaintsRecognition()
    if !IsCCContentEnabled()
        return
    endIf

    InitCCContent()
    if !_pdvCCSaintsPresent || !_pdvCCSaintsRestoringOrder
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.CC.SaintsRecognized") != 0
        return
    endIf

    if _pdvCCSaintsRestoringOrder.GetStageDone(200)
        PDV_DaedricPath_Sheo sheoPath = GetQuestReactionDeity("Sheogorath") as PDV_DaedricPath_Sheo
        if sheoPath
            sheoPath.RecordControlledSignal("cc_saints_restoring_order")
            StorageUtil.SetIntValue(None, "PDV.CC.SaintsRecognized", 1)
        endIf
    endIf
EndFunction

Function TryCCFishingDevotion()
    if !IsCCContentEnabled()
        return
    endIf

    InitCCContent()
    if !_pdvCCFishingPresent || !_pdvCCFishingIsFishing
        return
    endIf

    Int nowFlag = _pdvCCFishingIsFishing.GetValueInt()
    if nowFlag != 0 && _pdvCCFishingLastFlag == 0
        Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.CCFishingKyne")
        if multiplier > 0.0 && PDV_Kyne
            AwardPiety(PDV_Kyne, 0.5 * multiplier, "cc_fishing")
        endIf
    endIf
    _pdvCCFishingLastFlag = nowFlag
EndFunction

String Function GetCCContentStatusLine()
    InitCCContent()

    String detected = ""
    if _pdvCCSaintsPresent
        detected = "Saints & Seducers"
    endIf
    if _pdvCCFishingPresent
        if detected != ""
            detected = detected + ", "
        endIf
        detected = detected + "Fishing"
    endIf

    if detected == ""
        return "No supported CC content detected"
    endIf

    if !IsCCContentEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | integration on"
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

Bool Function IsPatronLapsed(PDV_DeityBase deity)
    ; Recency lapse: the active patron is "neglected" after NEGLECT_LAPSE_GRACE_DAYS of no
    ; devotional act, regardless of piety. The active patron is decay-shielded (ApplyDecayToDeity
    ; returns early for _activeDeity), so the piety<=10 floor almost never fires from mere absence.
    ; Mirrors the Imperial civic-lapse model (IsImperialCivicNeglected). Reuses the per-deity
    ; PDV.LastEventGameTime stamp that decay already consumes.
    if !deity
        return False
    endIf
    Float lastAct = StorageUtil.GetFloatValue(deity as Form, "PDV.LastEventGameTime")
    if lastAct <= 0.0
        return False
    endIf
    return (Utility.GetCurrentGameTime() - lastAct) > NEGLECT_LAPSE_GRACE_DAYS
EndFunction

Bool Function IsBroadLaneLapsed()
    ; Broad-lane recency lapse: a full-pantheon (broad) worshipper who has practiced at least once
    ; and then goes quiet for NEGLECT_LAPSE_GRACE_DAYS feels gentle neglect too. Generalizes the
    ; Imperial civic-lapse model to the broad lane, keyed off the global PDV.Devotion.LastActTime.
    if !IsBroadWorshipActive()
        return False
    endIf
    Float lastAct = StorageUtil.GetFloatValue(None, "PDV.Devotion.LastActTime")
    if lastAct <= 0.0
        return False
    endIf
    return (Utility.GetCurrentGameTime() - lastAct) > NEGLECT_LAPSE_GRACE_DAYS
EndFunction

Function SyncOnePatronNeglectSpell(Actor playerRef, Spell neglectSpell, Bool shouldBeActive)
    ; None-safe add/remove for one per-patron neglect spell. Guards on the spell so it no-ops while
    ; the record is unauthored (property still None until the ESP batch fills it).
    if !playerRef || !neglectSpell
        return
    endIf
    if shouldBeActive
        if !playerRef.HasSpell(neglectSpell)
            playerRef.AddSpell(neglectSpell, False)
        endIf
    else
        if playerRef.HasSpell(neglectSpell)
            playerRef.RemoveSpell(neglectSpell)
        endIf
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
    Bool isNord = GetPlayerOriginRaceIndex() == ORIGIN_NORD
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Shor,  isNord && _activeDeity == PDV_Shor  && IsNeglectFlagActive(PDV_Shor))
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Tsun,  isNord && _activeDeity == PDV_Tsun  && IsNeglectFlagActive(PDV_Tsun))
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Stuhn, isNord && _activeDeity == PDV_Stuhn && IsNeglectFlagActive(PDV_Stuhn))
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Talos, isNord && _activeDeity == PDV_Talos && IsNeglectFlagActive(PDV_Talos))
    ; Nord Old Ways patrons (Orkey/Dibella roster). _activeDeity keys on the internal Arkay/Dibella
    ; deity, not the "Orkey" display name; the spell record carries the Orkey-facing name.
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Arkay,   isNord && _activeDeity == PDV_Arkay   && IsNeglectFlagActive(PDV_Arkay))
    SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Dibella, isNord && _activeDeity == PDV_Dibella && IsNeglectFlagActive(PDV_Dibella))
EndFunction

Function SyncFirstTierRaceRewardRuntime()
    Actor playerRef = Game.GetPlayer()
    Spell activeReward = GetFirstTierRaceRewardSpellForOrigin()
    ; The origin's first-tier "+10" Health floor grants to an active patron (>= Seeker) OR a
    ; broad worshipper with accumulated service (IsBroadFloorEligible) -- without the broad arm
    ; a broad worshipper got nothing until the count-gated Faithful (T2) reward, a 0 -> +20 cliff.
    Bool shouldBeActive = (IsFirstTierRaceRewardEligible() || IsBroadFloorEligible()) && activeReward

    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T1, shouldBeActive && activeReward == PDV_Bless_Altmer_Orthodox_T1, "Altmer T1")
    ; Argonian Hist_T1 is intentionally absent here: SyncArgonianRewards owns it on the substrate
    ; tier (no-offer). Managing it in this active-patron path too would fight that grant.
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T1, shouldBeActive && activeReward == PDV_Bless_Bosmer_Yffre_T1, "Bosmer T1")
    ; Breton T1 is intentionally absent here: SyncBretonTraditionRewardFamily owns
    ; the tradition family T1 on the tradition-breadth tier (v3 12.5, no generic
    ; broad lane). Managing it in this floor path too would fight that grant.
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
    SyncAltmerAncestorSubstrate(playerRef, isAltmer)
    Bool broadOrthodoxFaithful = isAltmer && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count") + StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T2, broadOrthodoxFaithful, "Altmer Orthodox T2")

    SyncAltmerRewardFamily(playerRef, PDV_AuriEl, PDV_Bless_Altmer_AuriEl_T1, PDV_Bless_Altmer_AuriEl_T2, PDV_Bless_Altmer_AuriEl_T3, "Auri-El")
    SyncAltmerRewardFamily(playerRef, PDV_Magnus, PDV_Bless_Altmer_Magnus_T1, PDV_Bless_Altmer_Magnus_T2, PDV_Bless_Altmer_Magnus_T3, "Magnus")
    SyncAltmerRewardFamily(playerRef, PDV_Trinimac, PDV_Bless_Altmer_Trinimac_T1, PDV_Bless_Altmer_Trinimac_T2, PDV_Bless_Altmer_Trinimac_T3, "Trinimac")
    SyncAltmerRewardFamily(playerRef, PDV_Xarxes, PDV_Bless_Altmer_Xarxes_T1, PDV_Bless_Altmer_Xarxes_T2, PDV_Bless_Altmer_Xarxes_T3, "Xarxes")
    SyncAltmerRewardFamily(playerRef, PDV_Syrabane, PDV_Bless_Altmer_Syrabane_T1, PDV_Bless_Altmer_Syrabane_T2, PDV_Bless_Altmer_Syrabane_T3, "Syrabane")
EndFunction

Function SyncAltmerAncestorSubstrate(Actor playerRef, Bool isAltmer)
    if !playerRef || !PDV_AltmerAncestorSubstrate
        return
    endIf

    if isAltmer
        PDV_AltmerAncestorSubstrate.RecomputeSubstrateTier()
    else
        PDV_AltmerAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncAltmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_ALTMER && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Altmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Altmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Altmer " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Altmer " + label)
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

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Bosmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Bosmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Bosmer " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Bosmer " + label)
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
    SyncBretonAncestorSubstrate(playerRef, isBreton)
    if isBreton
        EnsureBretonDruidicForkInitialized()
    endIf

    Int traditionValue = GetBretonTraditionValue()
    ; v3 12.5 / race sheet 10.3: Breton has NO generic broad lane. The retired
    ; generic Tradition_T1/T2 spells are force-removed so a migrated save loses
    ; them; the broad role now lives in each tradition family's T1/T2 phase, and
    ; the focused patron unlocks T3.
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T1, False, "Breton Tradition T1 (retired)")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T2, False, "Breton Tradition T2 (retired)")

    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_KNIGHTS_ROAD, traditionValue, PDV_Bless_Breton_KnightsRoad_T1, PDV_Bless_Breton_KnightsRoad_T2, PDV_Bless_Breton_KnightsRoad_T3, "KnightsRoad")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_HIDDEN_ART, traditionValue, PDV_Bless_Breton_HiddenArt_T1, PDV_Bless_Breton_HiddenArt_T2, PDV_Bless_Breton_HiddenArt_T3, "HiddenArt")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_GREEN_WAY, traditionValue, PDV_Bless_Breton_GreenWay_T1, PDV_Bless_Breton_GreenWay_T2, PDV_Bless_Breton_GreenWay_T3, "GreenWay")
    SyncBretonKnightlyVowCreedLossSpells(isBreton && traditionValue == BRETON_TRADITION_KNIGHTS_ROAD)
    SyncBretonWitchcraftExposureRuptureSpell(isBreton)
    SyncBretonDruidicForkBetrayalSpell(isBreton && GetBretonDruidicForkValue() == BRETON_DRUIDIC_FORK_BETRAYED)
EndFunction

Function SyncBretonAncestorSubstrate(Actor playerRef, Bool isBreton)
    if !playerRef || !PDV_BretonAncestorSubstrate
        return
    endIf

    if isBreton
        Trace(2, "Breton ancestor substrate retired; clearing legacy boons.")
    endIf
    PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
EndFunction

Function SyncBretonTraditionRewardFamily(Actor playerRef, Int thisTradition, Int activeTradition, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_BRETON && thisTradition == activeTradition
    if thisTradition == BRETON_TRADITION_HIDDEN_ART && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
        isActive = False
    endIf
    if thisTradition == BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        isActive = False
    endIf

    Int activeTier = TIER_NONE
    PDV_DeityBase presentationDeity = None
    if isActive
        activeTier = GetBretonTraditionTier(thisTradition)
        presentationDeity = GetBretonTraditionPresentationDeity(thisTradition)
    endIf

    Bool hadT1Spell = HasRewardSpell(playerRef, t1)
    Bool hadT2Spell = HasRewardSpell(playerRef, t2)
    Bool hadT3Spell = HasRewardSpell(playerRef, t3)
    Bool wantsT1Spell = isActive && activeTier == TIER_SEEKER
    Bool wantsT2Spell = isActive && activeTier == TIER_DEVOTED
    Bool wantsT3Spell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, wantsT1Spell, "Breton " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, wantsT2Spell, "Breton " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsT3Spell, "Breton " + label + " T3")
    MaybeShowBretonTraditionRewardPresentation(playerRef, t1, hadT1Spell, wantsT1Spell, presentationDeity, label, TIER_SEEKER)
    MaybeShowBretonTraditionRewardPresentation(playerRef, t2, hadT2Spell, wantsT2Spell, presentationDeity, label, TIER_DEVOTED)
    MaybeShowBretonTraditionRewardPresentation(playerRef, t3, hadT3Spell, wantsT3Spell, presentationDeity, label, TIER_CHAMPION)
EndFunction

Function MaybeShowBretonTraditionRewardPresentation(Actor playerRef, Spell rewardSpell, Bool hadSpell, Bool wantsSpell, PDV_DeityBase deity, String traditionLabel, Int tierValue)
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !rewardSpell || !wantsSpell || !playerRef.HasSpell(rewardSpell)
        return
    endIf

    String displayLabel = GetBretonTraditionRewardDisplayLabel(traditionLabel)
    String shownKey = "PDV.Breton.TraditionRewardNoticeShown." + displayLabel + "." + tierValue
    if hadSpell && StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    String tierLabel = GetTierStandingLabel(tierValue)
    String symbolName = GetPrismaSymbolForDeity(deity)
    String line = "The " + displayLabel + " names you " + tierLabel + "."
    SendPrismaToast(symbolName, "good", displayLabel + " deepens", line)
    AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, tierValue >= TIER_CHAMPION, tierValue, displayLabel + " deepens")
EndFunction

String Function GetBretonTraditionRewardDisplayLabel(String label)
    if label == "KnightsRoad"
        return "Knight's Road"
    elseIf label == "HiddenArt"
        return "Hidden Art"
    elseIf label == "GreenWay"
        return "Green Way"
    endIf
    return label
EndFunction

; v3 12.5 + race sheet 10.3: the tradition IS the reward lane. Broad worship
; across the tradition's deity pool lights T1/T2 (capped at Tier 2); committing
; to a focused patron within the tradition unlocks Tier 3. Replaces the old
; single-deity (Stendarr/Magnus/Yffre) gate.
Int Function GetBretonTraditionTier(Int traditionValue)
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity && IsDeityInBretonTraditionPool(traditionValue, _activeDeity)
        return GetTier(_activeDeity)
    endIf

    Int bestTier = GetBretonTraditionPoolBestTier(traditionValue)
    if bestTier > TIER_DEVOTED
        return TIER_DEVOTED
    endIf
    return bestTier
EndFunction

Int Function GetBretonTraditionPoolBestTier(Int traditionValue)
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        Int best = GetTier(PDV_Stendarr)
        Int t = GetTier(PDV_Mara)
        if t > best
            best = t
        endIf
        t = GetTier(PDV_Arkay)
        if t > best
            best = t
        endIf
        t = GetTier(PDV_Julianos)
        if t > best
            best = t
        endIf
        t = GetTier(PDV_Akatosh)
        if t > best
            best = t
        endIf
        return best
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return GetTier(PDV_Yffre)
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        ; Broad Hidden Art breadth uses Magnus benign-magic practice; the real
        ; Hidden Art depth is the focused Daedric-via-20C patron (focused phase).
        return GetTier(PDV_Magnus)
    endIf
    return TIER_NONE
EndFunction

Bool Function IsDeityInBretonTraditionPool(Int traditionValue, PDV_DeityBase deity)
    if !deity
        return False
    endIf
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        return deity == PDV_Stendarr || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Julianos || deity == PDV_Akatosh
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return deity == PDV_Yffre
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        ; Hidden Art patron offers come only from the tradition (Magnus benign
        ; magic or a Daedric-via-20C prince), so any committed patron for a
        ; Hidden Art Breton is in-tradition by construction.
        return True
    endIf
    return False
EndFunction

PDV_DeityBase Function GetBretonTraditionPresentationDeity(Int traditionValue)
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity && IsDeityInBretonTraditionPool(traditionValue, _activeDeity)
        return _activeDeity
    endIf
    return GetBretonTraditionDeity(traditionValue)
EndFunction

Int Function GetBretonTraditionValue()
    Int traditionValue = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if traditionValue >= BRETON_TRADITION_KNIGHTS_ROAD && traditionValue <= BRETON_TRADITION_GREEN_WAY
        return traditionValue
    endIf

    return BRETON_TRADITION_KNIGHTS_ROAD
EndFunction

PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        return PDV_Stendarr
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        return PDV_Magnus
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return PDV_Yffre
    endIf

    return None
EndFunction

Int Function GetBretonDruidicForkValue()
    Int forkValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicFork", BRETON_DRUIDIC_FORK_NONE)
    if forkValue >= BRETON_DRUIDIC_FORK_NONE && forkValue <= BRETON_DRUIDIC_FORK_BETRAYED
        return forkValue
    endIf

    return BRETON_DRUIDIC_FORK_NONE
EndFunction

Function SetBretonDruidicFork(Int forkValue, String reason)
    Int oldFork = GetBretonDruidicForkValue()
    Int normalized = ClampInt(forkValue, BRETON_DRUIDIC_FORK_NONE, BRETON_DRUIDIC_FORK_BETRAYED)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicFork", normalized)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastDruidicForkReason", reason)
    if PDV_GLO_State_BretonDruidicFork
        PDV_GLO_State_BretonDruidicFork.SetValue(normalized as Float)
    endIf
    if GetPlayerOriginRaceIndex() == ORIGIN_BRETON && oldFork != normalized
        SurfaceBretonDruidicForkChange(normalized)
    endIf
EndFunction

Function SurfaceBretonDruidicForkChange(Int forkValue)
    if forkValue == BRETON_DRUIDIC_FORK_WEREWOLF
        SendPrismaShiftToast("The Green Way turns wild in you.", "", "kynareth")
        AppendBookOfDaysEntry("The beast-blood took your Green Way down a wilder road. The Werewolf path is yours now.", Utility.GetCurrentGameTime() as Int, "reorientation", "kynareth", False, 3)
    elseIf forkValue == BRETON_DRUIDIC_FORK_BETRAYED
        SendPrismaShiftToast("You broke faith with the Green.", "", "kynareth")
        AppendBookOfDaysEntry("You turned from the Green Way's trust. The path remembers the betrayal.", Utility.GetCurrentGameTime() as Int, "reorientation", "kynareth", False, 3)
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
            SendPrismaToast("journal", "warning", "Creed strained", noticeText)
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

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Dunmer " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Dunmer " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Dunmer " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Dunmer " + label)
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
    SyncOrcSpineBoon(playerRef, isOrc, activeMode)

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

Function SyncOrcSpineBoon(Actor playerRef, Bool isOrc, Int activeMode)
    if !playerRef
        return
    endIf

    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_City, isOrc && activeMode == ORC_LIFE_MODE_CITY, "Orc Spine City")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_Stronghold, isOrc && activeMode == ORC_LIFE_MODE_STRONGHOLD, "Orc Spine Stronghold")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_LegionExile, isOrc && activeMode == ORC_LIFE_MODE_LEGION_EXILE, "Orc Spine LegionExile")
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
    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Orc " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Orc " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Orc " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, PDV_Malacath, "Orc " + label)
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
            MaybeShowOrcHearthHeldMissedCadenceNotice()
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
    Int sectValue = GetActiveRedguardSpineSect()
    SyncRedguardSpineBoon(playerRef, isRedguard, sectValue)
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

Function SyncRedguardSpineBoon(Actor playerRef, Bool isRedguard, Int sectValue)
    if !playerRef
        return
    endIf

    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Crown, isRedguard && sectValue == REDGUARD_SECT_CROWN, "Redguard Spine Crown")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Forebear, isRedguard && sectValue == REDGUARD_SECT_FOREBEAR, "Redguard Spine Forebear")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_AshAbah, isRedguard && sectValue == REDGUARD_SECT_ASHABAH, "Redguard Spine AshAbah")
EndFunction

Int Function GetActiveRedguardSpineSect()
    if PDV_RedguardSectTrack
        EnsureRedguardSectInitialized()
        Int sectValue = PDV_RedguardSectTrack.GetCurrentState()
        if sectValue >= REDGUARD_SECT_CROWN && sectValue <= REDGUARD_SECT_ASHABAH
            return sectValue
        endIf
    endIf

    return REDGUARD_SECT_FOREBEAR
EndFunction

Function SyncRedguardRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Redguard " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Redguard " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Redguard " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Redguard " + label)
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
        Bool wasActive = playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
        if !playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
            playerRef.AddSpell(PDV_SPEL_Neglect_Redguard, False)
        endIf
        if !wasActive
            EmitRedguardDeathDutyAbandonmentMinus("redguard_ancestor_distance_neglect")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 1)
    else
        if playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
            playerRef.RemoveSpell(PDV_SPEL_Neglect_Redguard)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
    endIf
EndFunction

Function EmitRedguardDeathDutyAbandonmentMinus(String reason)
    if !IsRedguardOrigin() || !PDV_Tuwhacca
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardDeathDutyAbandonment")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.DeathDutyAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastDeathDutyAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastDeathDutyAbandonmentTime", Utility.GetCurrentGameTime())
    Trace(2, "Redguard death-duty abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

; Malacath creed-violation minus: werewolf onset is a Code rupture (the beast-blood
; cools Malacath's regard). Hooked from ApplyOrcCurseHandlers on a transition INTO the
; werewolf state; Orc-gated and anti-farmed (curse flicker cannot stack the penalty).
Function EmitMalacathCurseCodeRuptureMinus(String reason)
    if !IsOrcOrigin() || !PDV_Malacath
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathCurseCodeRupture")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CurseCodeRuptureCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastCurseCodeRuptureReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastCurseCodeRuptureTime", Utility.GetCurrentGameTime())
    Trace(2, "Malacath curse-code rupture routed: " + reason + " multiplier=" + multiplier)
EndFunction

; Malacath creed-violation minus: deserting sworn service. Hooked from
; ApplyOrcLifeModeSwitch on a PLAYER-DRIVEN switch away from Legion-Exile (the sworn-
; service life mode). The passive 14-day dawn lapse-to-City routes through SetState
; directly, NOT this switch path, so neglect-drift does not trip the betrayal penalty.
Function EmitMalacathBrokenFaithKinMinus(String reason)
    if !IsOrcOrigin() || !PDV_Malacath
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathBrokenFaithKin")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.BrokenFaithKinCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastBrokenFaithKinReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastBrokenFaithKinTime", Utility.GetCurrentGameTime())
    Trace(2, "Malacath broken-faith-kin routed: " + reason + " multiplier=" + multiplier)
EndFunction

; Mephala creed-violation minus: a clumsy crime (caught trespassing / assaulting an
; innocent) is the opposite of Mephala's subtlety -- a kept secret carelessly exposed.
; Dunmer-gated and only while the active Reclamation focus is Mephala (focus 2);
; anti-farmed so a string of same-day crimes does not stack the loss linearly.
Function HandleDunmerClumsyCrime(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_Mephala
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1) != 2
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.MephalaSecretBetrayed")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SECRET_BETRAYED, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.SecretBetrayedCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastSecretBetrayedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastSecretBetrayedTime", Utility.GetCurrentGameTime())
    Trace(2, "Mephala secret-betrayed routed: " + reason + " multiplier=" + multiplier)
EndFunction

; Hist creed-violation minuses (curated medium/major only, per PDV_Deity_Hist), keyed to
; the substrate posture model: drifting Distant past grace is abandonment; domination-
; driven Corrupted posture is corruption; deep Void leaning (>=3 signals) while Hist has
; lapsed below the non-curse floor is Void overreach. Argonian-gated, anti-farmed.
Function EmitHistAbandonmentMinus(String reason)
    if !IsArgonianOrigin() || !PDV_Hist
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.HistAbandonment")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistAbandonmentTime", Utility.GetCurrentGameTime())
    Trace(2, "Hist abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistCorruptionMinus(String reason)
    if !IsArgonianOrigin() || !PDV_Hist
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.HistCorruption")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_CORRUPTION, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistCorruptionCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistCorruptionReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistCorruptionTime", Utility.GetCurrentGameTime())
    Trace(2, "Hist corruption routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistVoidOverreachMinus(String reason)
    if !IsArgonianOrigin() || !PDV_Hist
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.HistVoidOverreach")
    if multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_VOID_OVERREACH, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.VoidOverreachCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastVoidOverreachReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastVoidOverreachTime", Utility.GetCurrentGameTime())
    Trace(2, "Hist void overreach routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function SyncNordRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    EnsureNordOrkeyRewardRuntimeWiring()

    Bool isNord = GetPlayerOriginRaceIndex() == ORIGIN_NORD
    Int baselineState = GetNordPantheonBaselineState()
    SyncNordAncestorSubstrate(playerRef, isNord)
    Bool broadOldWaysFaithful = isNord && GetPatronState() == PATRON_STATE_BROAD && baselineState == NORD_BASELINE_OLD_WAYS && StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T2, broadOldWaysFaithful, "Nord OldWays T2")

    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Kyne, PDV_Bless_Nord_Kyne_T1, PDV_Bless_Nord_Kyne_T2, PDV_Bless_Nord_Kyne_T3, "Kyne")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Shor, PDV_Bless_Nord_Shor_T1, PDV_Bless_Nord_Shor_T2, PDV_Bless_Nord_Shor_T3, "Shor")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Tsun, PDV_Bless_Nord_Tsun_T1, PDV_Bless_Nord_Tsun_T2, PDV_Bless_Nord_Tsun_T3, "Tsun")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Stuhn, PDV_Bless_Nord_Stuhn_T1, PDV_Bless_Nord_Stuhn_T2, PDV_Bless_Nord_Stuhn_T3, "Stuhn")
    SyncNordRewardFamily(playerRef, -1, PDV_Talos, PDV_Bless_Nord_Talos_T1, PDV_Bless_Nord_Talos_T2, PDV_Bless_Nord_Talos_T3, "Talos")

    ; Nord Nine Divines gods have no Nord-specific reward records (never authored); reuse the
    ; existing Imperial Divine reward spells (the canonical Nine Divines rewards), identical to
    ; the Mara fix. Owner ruling 2026-06-27. NOTE: Akatosh/Julianos/Kynareth Imperial rewards are
    ; regen-rate (~0 under Requiem) -- a pre-existing Imperial reward-feel gap to convert later.
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    ; Mara is focusable in BOTH lanes (Old Ways + Nine Divines), like Talos -- baseline -1.
    ; No Nord-specific Mara reward records exist, so reuse the Imperial Mara spells -- this IS
    ; the Nine Divines Mara reward (Restoration +5/+13/+23 + wake-mended), identical across lanes.
    SyncNordRewardFamily(playerRef, -1, PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, "Mara")
    ; Arkay is focusable in BOTH lanes. Old Ways names him Orkey and uses
    ; Orkey-facing Nord reward records so Active Effects do not surface Arkay.
    ; Nine Divines keeps the existing Imperial Arkay rewards.
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Arkay, PDV_Bless_Nord_Arkay_T1, PDV_Bless_Nord_Arkay_T2, PDV_Bless_Nord_Arkay_T3, "Orkey")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Arkay, PDV_Bless_Imperial_Arkay_T1, PDV_Bless_Imperial_Arkay_T2, PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Stendarr, PDV_Bless_Imperial_Stendarr_T1, PDV_Bless_Imperial_Stendarr_T2, PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Zenithar, PDV_Bless_Imperial_Zenithar_T1, PDV_Bless_Imperial_Zenithar_T2, PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    ; Dibella is focusable in BOTH lanes (owner directive 2026-07-05), like Mara --
    ; baseline -1, same Imperial reward reuse either way.
    SyncNordRewardFamily(playerRef, -1, PDV_Dibella, PDV_Bless_Imperial_Dibella_T1, PDV_Bless_Imperial_Dibella_T2, PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Julianos, PDV_Bless_Imperial_Julianos_T1, PDV_Bless_Imperial_Julianos_T2, PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Kynareth, PDV_Bless_Imperial_Kynareth_T1, PDV_Bless_Imperial_Kynareth_T2, PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
EndFunction

Function SyncNordAncestorSubstrate(Actor playerRef, Bool isNord)
    if !playerRef || !PDV_NordAncestorSubstrate
        return
    endIf

    if isNord
        PDV_NordAncestorSubstrate.RecomputeSubstrateTier()
    else
        PDV_NordAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncNordRewardFamily(Actor playerRef, Int requiredBaseline, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool baselineOk = requiredBaseline < 0 || GetNordPantheonBaselineState() == requiredBaseline
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_NORD && baselineOk && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Nord " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Nord " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Nord " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Nord " + label)
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
        SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)
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
    SyncImperialAncestorSubstrate(playerRef, isImperial)
    Bool broadCivicFaithful = isImperial && GetPatronState() == PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") >= 6
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T2, broadCivicFaithful, "Imperial Civic T2")

    ; The Divine reward SPELs below are REUSED by the Nord baseline lanes
    ; (SyncNordRewardFamily: Mara/Arkay/Dibella + the whole Nine Divines set, owner ruling
    ; 2026-06-27). SyncNordRewards runs BEFORE this in SyncFirstTierRaceRewardRuntime and
    ; grants the Nord patron's spell; running the Imperial family here on a non-Imperial save
    ; (isActive is false because origin != Imperial) would REMOVE that just-granted spell in
    ; the same pass -- which is why Nord reused-spell rewards never reached Active Effects.
    ; Only the player's own race lane should manage these records; skip entirely when not
    ; Imperial. SyncNordRewards runs unconditionally and already owns both grant and cleanup
    ; for these spells on every non-Imperial save (Civic_T2 above is Imperial-only, so it
    ; stays before this guard to keep self-clearing).
    if !isImperial
        return
    endIf

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

Function SyncImperialAncestorSubstrate(Actor playerRef, Bool isImperial)
    if !playerRef || !PDV_ImperialAncestorSubstrate
        return
    endIf

    if isImperial
        PDV_ImperialAncestorSubstrate.RecomputeSubstrateTier()
    else
        PDV_ImperialAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncImperialRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = TIER_NONE
    if isActive && deity
        activeTier = GetTier(deity)
    endIf

    Bool hadChampionSpell = HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= TIER_CHAMPION
    SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == TIER_SEEKER, "Imperial " + label + " T1")
    SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == TIER_DEVOTED, "Imperial " + label + " T2")
    SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Imperial " + label + " T3")
    MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Imperial " + label)
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

; Broad-worship floor eligibility: the origin's first-tier reward also grants to a BROAD
; worshipper, not only an active patron. Mirrors the active path's "earned Seeker before the
; floor" by gating on the same accumulated-service count the Faithful (T2) reward uses;
; Seeker-equivalent = 3 acts (half the Faithful gate of 6). Nord's broad T1 is part of this
; shared floor helper too; the old runtime excluded it by mistake even though the reward spec
; and manager property already expose PDV_Bless_Nord_OldWays_T1 as the broad first tier.
Bool Function IsBroadFloorEligible()
    if GetPatronState() != PATRON_STATE_BROAD
        return False
    endIf
    Int origin = GetPlayerOriginRaceIndex()
    if !HasBroadLanePresentation(origin)
        return False
    endIf
    return GetBroadLaneServiceCount(origin) >= 3
EndFunction

; Accumulated broad-worship service count for the origin's broad lane -- the same accumulator
; the Faithful/T2 reward gates on at >= 6. Altmer sums its two favor counters; Nord uses the
; Old Ways broad-state counter that already drives the broad-T2 lane.
Int Function GetBroadFloorServiceCount(Int origin)
    return GetBroadLaneServiceCount(origin)
EndFunction

Bool Function HasBroadLanePresentation(Int origin)
    return origin == ORIGIN_IMPERIAL || origin == ORIGIN_BRETON || origin == ORIGIN_ORC || origin == ORIGIN_ALTMER || origin == ORIGIN_NORD || origin == ORIGIN_BOSMER || origin == ORIGIN_DUNMER || origin == ORIGIN_REDGUARD
EndFunction

Int Function GetBroadLaneServiceCount(Int origin)
    if origin == ORIGIN_IMPERIAL
        return StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount")
    elseIf origin == ORIGIN_BRETON
        return StorageUtil.GetIntValue(None, "PDV.Breton.TraditionHookCount")
    elseIf origin == ORIGIN_ORC
        return StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount")
    elseIf origin == ORIGIN_ALTMER
        return StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count") + StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count")
    elseIf origin == ORIGIN_NORD
        if GetNordPantheonBaselineState() != NORD_BASELINE_OLD_WAYS
            return 0
        endIf
        return StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount")
    elseIf origin == ORIGIN_BOSMER
        return GetBosmerFavorSignalCount()
    elseIf origin == ORIGIN_DUNMER
        return StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount")
    elseIf origin == ORIGIN_REDGUARD
        return StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount")
    endIf
    return 0
EndFunction

Int Function GetBroadLaneTierForOrigin(Int origin)
    if GetPatronState() != PATRON_STATE_BROAD || !HasBroadLanePresentation(origin)
        return TIER_NONE
    endIf

    Int count = GetBroadLaneServiceCount(origin)
    if count >= 6
        return TIER_DEVOTED
    elseIf count >= 3
        return TIER_SEEKER
    endIf
    return TIER_NONE
EndFunction

String Function GetBroadLaneDisplayName(Int origin)
    if origin == ORIGIN_IMPERIAL
        return "Civic Faith"
    elseIf origin == ORIGIN_ALTMER
        return "Orthodox Faith"
    elseIf origin == ORIGIN_BOSMER
        return "Y'ffre's Broad Faith"
    elseIf origin == ORIGIN_BRETON
        return "Breton Tradition"
    elseIf origin == ORIGIN_DUNMER
        return "Reclamation Communion"
    elseIf origin == ORIGIN_NORD
        return "Old Ways"
    elseIf origin == ORIGIN_ORC
        return "Malacath's Code"
    elseIf origin == ORIGIN_REDGUARD
        return "Ancestor Spine"
    endIf
    return "Broad Faith"
EndFunction

String Function GetBroadLaneSymbol(Int origin)
    if origin == ORIGIN_IMPERIAL
        return "akatosh"
    elseIf origin == ORIGIN_ALTMER
        return "auri-el"
    elseIf origin == ORIGIN_BOSMER
        return "yffre"
    elseIf origin == ORIGIN_BRETON
        return "journal"
    elseIf origin == ORIGIN_DUNMER
        return "ancestor"
    elseIf origin == ORIGIN_NORD
        return "kyne"
    elseIf origin == ORIGIN_ORC
        return "malacath"
    elseIf origin == ORIGIN_REDGUARD
        return "tu-whacca"
    endIf
    return "journal"
EndFunction

String Function GetBroadLaneStandingLabel(Int origin, Int tier)
    if tier >= TIER_DEVOTED
        return "Faithful"
    elseIf tier >= TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
EndFunction

String Function GetBroadLaneNextThresholdText(Int origin)
    Int count = GetBroadLaneServiceCount(origin)
    if count < 3
        return "Observant at 3 broad acts"
    elseIf count < 6
        return "Faithful at 6 broad acts"
    endIf
    return "Broad lane cap reached"
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
        ; Readback selector only; the grant is owned by SyncBretonTraditionRewardFamily.
        Int bretonTradition = GetBretonTraditionValue()
        if bretonTradition == BRETON_TRADITION_HIDDEN_ART
            return PDV_Bless_Breton_HiddenArt_T1
        elseIf bretonTradition == BRETON_TRADITION_GREEN_WAY
            return PDV_Bless_Breton_GreenWay_T1
        endIf
        return PDV_Bless_Breton_KnightsRoad_T1
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

Bool Function HasRewardSpell(Actor playerRef, Spell rewardSpell)
    if !playerRef || !rewardSpell
        return False
    endIf

    return playerRef.HasSpell(rewardSpell)
EndFunction

Function PrepareForUninstall()
    Actor playerRef = Game.GetPlayer()

    StripAllPdvSpells(playerRef)

    if playerRef
        if NecromancerFaction
            playerRef.RemoveFromFaction(NecromancerFaction)
        endIf
        if WarlockFaction
            playerRef.RemoveFromFaction(WarlockFaction)
        endIf
    endIf

    ClearPdvStorageNamespaces()
    UnregisterForUpdate()
    Debug.MessageBox("Devotion has removed its spells, factions, and most of its saved data. You may now exit to the main menu, remove the mod, and load this save. This is BEST EFFORT and not a guaranteed clean save; some inert leftover data can remain. The only fully clean removal is to load a save made before Devotion was installed.")
    Self.Stop()
EndFunction

Function ClearPdvStorageNamespaces()
    Int clearedCount = StorageUtil.ClearAllPrefix("PDV.")
    Trace(1, "PrepareForUninstall: cleared StorageUtil PDV prefix count " + clearedCount)
EndFunction

Function StripAllPdvSpells(Actor playerRef)
    if !playerRef
        return
    endIf

    SyncRaceRewardSpell(playerRef, PDV_SPEL_SurveyDevotion, False, "PDV_SPEL_SurveyDevotion")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Kyne, False, "PDV_SPEL_Neglect_Kyne")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_SkyStormHunt_Light, False, "PDV_SPEL_Disfavor_SkyStormHunt_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_SkyStormHunt_Sharp, False, "PDV_SPEL_Disfavor_SkyStormHunt_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_DeathAncestors_Light, False, "PDV_SPEL_Disfavor_DeathAncestors_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_DeathAncestors_Sharp, False, "PDV_SPEL_Disfavor_DeathAncestors_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MercyProtection_Light, False, "PDV_SPEL_Disfavor_MercyProtection_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MercyProtection_Sharp, False, "PDV_SPEL_Disfavor_MercyProtection_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_WarHonor_Light, False, "PDV_SPEL_Disfavor_WarHonor_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_WarHonor_Sharp, False, "PDV_SPEL_Disfavor_WarHonor_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_OrderTradeLore_Light, False, "PDV_SPEL_Disfavor_OrderTradeLore_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_OrderTradeLore_Sharp, False, "PDV_SPEL_Disfavor_OrderTradeLore_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MoonLuckShadow_Light, False, "PDV_SPEL_Disfavor_MoonLuckShadow_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MoonLuckShadow_Sharp, False, "PDV_SPEL_Disfavor_MoonLuckShadow_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_VoidSecrets_Light, False, "PDV_SPEL_Disfavor_VoidSecrets_Light")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_VoidSecrets_Sharp, False, "PDV_SPEL_Disfavor_VoidSecrets_Sharp")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery, False, "PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Kyne_StormRoadGrace, False, "PDV_SPEL_Favor_Kyne_StormRoadGrace")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Kyne_GuidedHunt, False, "PDV_SPEL_Favor_Kyne_GuidedHunt")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Kyne_WindMarkedPassage, False, "PDV_SPEL_Favor_Kyne_WindMarkedPassage")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance, False, "PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal, False, "PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense, False, "PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet, False, "PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance, False, "PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace, False, "PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty, False, "PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy, False, "PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft, False, "PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine, False, "PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness, False, "PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement, False, "PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T1, False, "PDV_Bless_Altmer_Orthodox_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T2, False, "PDV_Bless_Altmer_Orthodox_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T1, False, "PDV_Bless_Altmer_AuriEl_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T2, False, "PDV_Bless_Altmer_AuriEl_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T3, False, "PDV_Bless_Altmer_AuriEl_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T1, False, "PDV_Bless_Altmer_Magnus_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T2, False, "PDV_Bless_Altmer_Magnus_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T3, False, "PDV_Bless_Altmer_Magnus_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T1, False, "PDV_Bless_Altmer_Xarxes_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T2, False, "PDV_Bless_Altmer_Xarxes_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T3, False, "PDV_Bless_Altmer_Xarxes_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_Always, False, "PDV_Bless_Altmer_Spine_Always")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_Mid, False, "PDV_Bless_Altmer_Spine_Mid")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_High, False, "PDV_Bless_Altmer_Spine_High")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Altmer, False, "PDV_SPEL_Neglect_Altmer")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T1, False, "PDV_Bless_Argonian_Hist_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T2, False, "PDV_Bless_Argonian_Hist_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_Signature, False, "PDV_Bless_Argonian_Hist_Signature")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T1, False, "PDV_Bless_Argonian_People_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T2, False, "PDV_Bless_Argonian_People_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T3, False, "PDV_Bless_Argonian_People_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianShadowscaleVeil, False, "PDV_SPEL_ArgonianShadowscaleVeil")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianRootedRest, False, "PDV_SPEL_ArgonianRootedRest")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Claws, False, "PDV_SPEL_ArgonianAdapt_Claws")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Skin, False, "PDV_SPEL_ArgonianAdapt_Skin")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Sap, False, "PDV_SPEL_ArgonianAdapt_Sap")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Marsh, False, "PDV_SPEL_ArgonianAdapt_Marsh")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerTaleCarried, False, "PDV_SPEL_BosmerTaleCarried")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerScalesAtRest, False, "PDV_SPEL_BosmerScalesAtRest")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerBaanDarGap, False, "PDV_SPEL_BosmerBaanDarGap")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Hunter, False, "PDV_SPEL_BosmerNaming_Hunter")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Speaker, False, "PDV_SPEL_BosmerNaming_Speaker")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Wanderer, False, "PDV_SPEL_BosmerNaming_Wanderer")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Keeper, False, "PDV_SPEL_BosmerNaming_Keeper")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T1, False, "PDV_Bless_Argonian_Sithis_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T2, False, "PDV_Bless_Argonian_Sithis_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T3, False, "PDV_Bless_Argonian_Sithis_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianSithisNearDeathBurst, False, "PDV_SPEL_ArgonianSithisNearDeathBurst")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_ArgonianHist, False, "PDV_SPEL_Neglect_ArgonianHist")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T1, False, "PDV_Bless_Bosmer_Yffre_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T2, False, "PDV_Bless_Bosmer_Yffre_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T1, False, "PDV_Bless_Bosmer_OldContract_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T2, False, "PDV_Bless_Bosmer_OldContract_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T3, False, "PDV_Bless_Bosmer_OldContract_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T1, False, "PDV_Bless_Bosmer_LivingStory_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T2, False, "PDV_Bless_Bosmer_LivingStory_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T3, False, "PDV_Bless_Bosmer_LivingStory_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T1, False, "PDV_Bless_Bosmer_Exchange_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T2, False, "PDV_Bless_Bosmer_Exchange_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T3, False, "PDV_Bless_Bosmer_Exchange_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T1, False, "PDV_Bless_Bosmer_BanditRoad_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T2, False, "PDV_Bless_Bosmer_BanditRoad_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T3, False, "PDV_Bless_Bosmer_BanditRoad_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Bosmer, False, "PDV_SPEL_Neglect_Bosmer")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T1, False, "PDV_Bless_Breton_Tradition_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T2, False, "PDV_Bless_Breton_Tradition_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T1, False, "PDV_Bless_Breton_KnightsRoad_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T2, False, "PDV_Bless_Breton_KnightsRoad_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T3, False, "PDV_Bless_Breton_KnightsRoad_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T1, False, "PDV_Bless_Breton_HiddenArt_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T2, False, "PDV_Bless_Breton_HiddenArt_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T3, False, "PDV_Bless_Breton_HiddenArt_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T1, False, "PDV_Bless_Breton_GreenWay_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T2, False, "PDV_Bless_Breton_GreenWay_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T3, False, "PDV_Bless_Breton_GreenWay_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Breton, False, "PDV_SPEL_Neglect_Breton")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_VowIntegrity, False, "PDV_SPEL_CreedLoss_Breton_VowIntegrity")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_ExposureRupture, False, "PDV_SPEL_CreedLoss_Breton_ExposureRupture")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_Excommunication, False, "PDV_SPEL_CreedLoss_Breton_Excommunication")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal, False, "PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T1, False, "PDV_Bless_Dunmer_Reclamation_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T2, False, "PDV_Bless_Dunmer_Reclamation_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T1, False, "PDV_Bless_Dunmer_Azura_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T2, False, "PDV_Bless_Dunmer_Azura_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T3, False, "PDV_Bless_Dunmer_Azura_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T1, False, "PDV_Bless_Dunmer_Boethiah_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T2, False, "PDV_Bless_Dunmer_Boethiah_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T3, False, "PDV_Bless_Dunmer_Boethiah_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T1, False, "PDV_Bless_Dunmer_Mephala_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T2, False, "PDV_Bless_Dunmer_Mephala_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T3, False, "PDV_Bless_Dunmer_Mephala_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Dunmer, False, "PDV_SPEL_Neglect_Dunmer")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T1, False, "PDV_Bless_Imperial_Civic_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T2, False, "PDV_Bless_Imperial_Civic_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T1, False, "PDV_Bless_Imperial_Akatosh_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T2, False, "PDV_Bless_Imperial_Akatosh_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T3, False, "PDV_Bless_Imperial_Akatosh_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T1, False, "PDV_Bless_Imperial_Mara_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T2, False, "PDV_Bless_Imperial_Mara_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T3, False, "PDV_Bless_Imperial_Mara_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T1, False, "PDV_Bless_Imperial_Arkay_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T2, False, "PDV_Bless_Imperial_Arkay_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T3, False, "PDV_Bless_Imperial_Arkay_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T1, False, "PDV_Bless_Imperial_Stendarr_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T2, False, "PDV_Bless_Imperial_Stendarr_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T3, False, "PDV_Bless_Imperial_Stendarr_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T1, False, "PDV_Bless_Imperial_Zenithar_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T2, False, "PDV_Bless_Imperial_Zenithar_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T3, False, "PDV_Bless_Imperial_Zenithar_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T1, False, "PDV_Bless_Imperial_Dibella_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T2, False, "PDV_Bless_Imperial_Dibella_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T3, False, "PDV_Bless_Imperial_Dibella_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T1, False, "PDV_Bless_Imperial_Julianos_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T2, False, "PDV_Bless_Imperial_Julianos_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T3, False, "PDV_Bless_Imperial_Julianos_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T1, False, "PDV_Bless_Imperial_Kynareth_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T2, False, "PDV_Bless_Imperial_Kynareth_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T3, False, "PDV_Bless_Imperial_Kynareth_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T1, False, "PDV_Bless_Imperial_Talos_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T2, False, "PDV_Bless_Imperial_Talos_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T3, False, "PDV_Bless_Imperial_Talos_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Imperial, False, "PDV_SPEL_Neglect_Imperial")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Lunar_T1, False, "PDV_Bless_Khajiit_Lunar_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Khenarthi, False, "PDV_Bless_Khajiit_Phase_Khenarthi")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Azurah, False, "PDV_Bless_Khajiit_Phase_Azurah")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_BaanDar, False, "PDV_Bless_Khajiit_Phase_BaanDar")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Rajhin, False, "PDV_Bless_Khajiit_Phase_Rajhin")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Alkosh, False, "PDV_Bless_Khajiit_Phase_Alkosh")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T1, False, "PDV_Bless_Khajiit_Khenarthi_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T2, False, "PDV_Bless_Khajiit_Khenarthi_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T3, False, "PDV_Bless_Khajiit_Khenarthi_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T1, False, "PDV_Bless_Khajiit_Azurah_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T2, False, "PDV_Bless_Khajiit_Azurah_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T3, False, "PDV_Bless_Khajiit_Azurah_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T1, False, "PDV_Bless_Khajiit_BaanDar_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T2, False, "PDV_Bless_Khajiit_BaanDar_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T3, False, "PDV_Bless_Khajiit_BaanDar_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T1, False, "PDV_Bless_Khajiit_Rajhin_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T2, False, "PDV_Bless_Khajiit_Rajhin_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T3, False, "PDV_Bless_Khajiit_Rajhin_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T1, False, "PDV_Bless_Khajiit_Alkosh_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T2, False, "PDV_Bless_Khajiit_Alkosh_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T3, False, "PDV_Bless_Khajiit_Alkosh_T3")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_KhajiitLunar, False, "PDV_SPEL_Neglect_KhajiitLunar")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T1, False, "PDV_Bless_Nord_OldWays_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T2, False, "PDV_Bless_Nord_OldWays_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T1, False, "PDV_Bless_Nord_Kyne_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T2, False, "PDV_Bless_Nord_Kyne_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T3, False, "PDV_Bless_Nord_Kyne_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T1, False, "PDV_Bless_Nord_Shor_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T2, False, "PDV_Bless_Nord_Shor_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T3, False, "PDV_Bless_Nord_Shor_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T1, False, "PDV_Bless_Nord_Tsun_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T2, False, "PDV_Bless_Nord_Tsun_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T3, False, "PDV_Bless_Nord_Tsun_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T1, False, "PDV_Bless_Nord_Stuhn_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T2, False, "PDV_Bless_Nord_Stuhn_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T3, False, "PDV_Bless_Nord_Stuhn_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T1, False, "PDV_Bless_Nord_Talos_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T2, False, "PDV_Bless_Nord_Talos_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T3, False, "PDV_Bless_Nord_Talos_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Akatosh_T1, False, "PDV_Bless_Nord_Akatosh_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Akatosh_T2, False, "PDV_Bless_Nord_Akatosh_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Akatosh_T3, False, "PDV_Bless_Nord_Akatosh_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Mara_T1, False, "PDV_Bless_Nord_Mara_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Mara_T2, False, "PDV_Bless_Nord_Mara_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Mara_T3, False, "PDV_Bless_Nord_Mara_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T1, False, "PDV_Bless_Nord_Arkay_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T2, False, "PDV_Bless_Nord_Arkay_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T3, False, "PDV_Bless_Nord_Arkay_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stendarr_T1, False, "PDV_Bless_Nord_Stendarr_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stendarr_T2, False, "PDV_Bless_Nord_Stendarr_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stendarr_T3, False, "PDV_Bless_Nord_Stendarr_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Zenithar_T1, False, "PDV_Bless_Nord_Zenithar_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Zenithar_T2, False, "PDV_Bless_Nord_Zenithar_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Zenithar_T3, False, "PDV_Bless_Nord_Zenithar_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Dibella_T1, False, "PDV_Bless_Nord_Dibella_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Dibella_T2, False, "PDV_Bless_Nord_Dibella_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Dibella_T3, False, "PDV_Bless_Nord_Dibella_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Julianos_T1, False, "PDV_Bless_Nord_Julianos_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Julianos_T2, False, "PDV_Bless_Nord_Julianos_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Julianos_T3, False, "PDV_Bless_Nord_Julianos_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kynareth_T1, False, "PDV_Bless_Nord_Kynareth_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kynareth_T2, False, "PDV_Bless_Nord_Kynareth_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kynareth_T3, False, "PDV_Bless_Nord_Kynareth_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T1, False, "PDV_Bless_Orc_Malacath_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T2, False, "PDV_Bless_Orc_Malacath_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T1, False, "PDV_Bless_Orc_Stronghold_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T2, False, "PDV_Bless_Orc_Stronghold_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T3, False, "PDV_Bless_Orc_Stronghold_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T1, False, "PDV_Bless_Orc_City_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T2, False, "PDV_Bless_Orc_City_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T3, False, "PDV_Bless_Orc_City_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T1, False, "PDV_Bless_Orc_LegionExile_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T2, False, "PDV_Bless_Orc_LegionExile_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T3, False, "PDV_Bless_Orc_LegionExile_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_City, False, "PDV_Bless_Orc_Spine_City")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_Stronghold, False, "PDV_Bless_Orc_Spine_Stronghold")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_LegionExile, False, "PDV_Bless_Orc_Spine_LegionExile")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Orc, False, "PDV_SPEL_Neglect_Orc")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Tusk, False, "PDV_SPEL_Orc_TrialOfIron_Tusk")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Shield, False, "PDV_SPEL_Orc_TrialOfIron_Shield")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Hammer, False, "PDV_SPEL_Orc_TrialOfIron_Hammer")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Yoke, False, "PDV_SPEL_Orc_TrialOfIron_Yoke")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcCodeHolds, False, "PDV_SPEL_OrcCodeHolds")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcCodeHolds_Devoted, False, "PDV_SPEL_OrcCodeHolds_Devoted")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcHearthHeld, False, "PDV_SPEL_OrcHearthHeld")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T1, False, "PDV_Bless_Redguard_AncestorSpine_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T2, False, "PDV_Bless_Redguard_AncestorSpine_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Crown, False, "PDV_Bless_Redguard_Spine_Crown")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Forebear, False, "PDV_Bless_Redguard_Spine_Forebear")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_AshAbah, False, "PDV_Bless_Redguard_Spine_AshAbah")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T1, False, "PDV_Bless_Redguard_Tuwhacca_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T2, False, "PDV_Bless_Redguard_Tuwhacca_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T3, False, "PDV_Bless_Redguard_Tuwhacca_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T1, False, "PDV_Bless_Redguard_HoonDing_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T2, False, "PDV_Bless_Redguard_HoonDing_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T3, False, "PDV_Bless_Redguard_HoonDing_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T1, False, "PDV_Bless_Redguard_Leki_T1")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T2, False, "PDV_Bless_Redguard_Leki_T2")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T3, False, "PDV_Bless_Redguard_Leki_T3")
    SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_FarShoresToken, False, "PDV_Bless_Redguard_FarShoresToken")
    SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Redguard, False, "PDV_SPEL_Neglect_Redguard")
EndFunction

Function MaybeShowChampionRewardPresentation(Actor playerRef, Spell championSpell, Bool hadChampionSpell, Bool wantsChampionSpell, PDV_DeityBase deity, String rewardLabel)
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !championSpell || !wantsChampionSpell || hadChampionSpell || !playerRef.HasSpell(championSpell) || !deity
        return
    endIf

    if NotifyTierUp(deity, TIER_CHAMPION)
        SendPrismaEventToast("tier", deity, "", GetPublicTierBand(TIER_CHAMPION), "")
        SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)
        if deity == PDV_Kyne
            ShowNordNotification(PDV_Notif_Nord_Kyne_ChampionAmbient_Storm, "The wind is blowing your way.")
        endIf
        Trace(1, "Champion reward presentation shown: " + rewardLabel + " / " + deity.DeityName)
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
    Int stateValue = StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState", NORD_BASELINE_OLD_WAYS)
    if PDV_NordPantheonBaselineTrack
        stateValue = PDV_NordPantheonBaselineTrack.GetCurrentState()
        StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", stateValue)
    endIf

    return stateValue
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
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "ApplyConcordatPressure ignored for non-Imperial origin.")
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

Bool Function HandleTalosBetrayal(Int severity, String sourceReason)
    if !PDV_Talos
        Trace(1, "Talos betrayal skipped: PDV_Talos missing.")
        return False
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || _activeDeity != PDV_Talos
        Trace(2, "Talos betrayal skipped: active patron is not Talos.")
        return False
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace != ORIGIN_IMPERIAL && originRace != ORIGIN_NORD
        Trace(2, "Talos betrayal skipped: origin is not Imperial or Nord.")
        return False
    endIf

    if originRace == ORIGIN_IMPERIAL
        if !PDV_ConcordatStandingTrack
            Trace(1, "Imperial Talos betrayal skipped: ConcordatStanding track missing.")
            return False
        endIf
        if PDV_ConcordatStandingTrack.GetValue() > 50
            Trace(2, "Imperial Talos betrayal skipped: raw ConcordatStanding is already compliant.")
            return False
        endIf
    endIf

    Int normalizedSeverity = 2
    if severity >= 3
        normalizedSeverity = 3
    endIf

    String reason = "talos_betrayal_compliance"
    String surfaceText = "You bent the knee where you once stood firm. The old faith feels distant."
    Float pietyLoss = -2.0
    Int concordatPressure = 15
    if normalizedSeverity >= 3
        reason = "talos_betrayal_major"
        surfaceText = "You turned on the Ninth in the open. The defiance that was faith is gone."
        pietyLoss = -3.0
        concordatPressure = 25
    endIf

    if originRace == ORIGIN_IMPERIAL
        reason = "imperial_" + reason
    else
        reason = "nord_" + reason
    endIf

    Int currentDay = (Utility.GetCurrentGameTime() as Int) + 1
    String dayKey = "PDV.Creed." + reason + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, 0) == currentDay
        Trace(2, "Talos betrayal suppressed for " + reason + ": already applied today.")
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDay)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalSource", sourceReason)

    AwardPiety(PDV_Talos, pietyLoss, reason)
    if originRace == ORIGIN_IMPERIAL
        ApplyConcordatPressure(concordatPressure, reason)
    endIf

    SendPrismaEventToast("creed", PDV_Talos, surfaceText, "", "")
    SurfaceTransition("creed", "Talos betrayal", "drop", PDV_Talos.DeityIndex, "betrayal")
    Trace(2, "Talos betrayal applied: " + reason + " piety=" + pietyLoss + " source=" + sourceReason)
    return True
EndFunction

Function DebugApplyTalosBetrayalCompliance()
    if !HandleTalosBetrayal(2, "mcm")
        Debug.Notification("Talos betrayal did not apply; check origin, active Talos, Concordat, or repeat state.")
    endIf
EndFunction

Function DebugApplyTalosBetrayalMajor()
    if !HandleTalosBetrayal(3, "mcm")
        Debug.Notification("Talos betrayal did not apply; check origin, active Talos, Concordat, or repeat state.")
    endIf
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

    BeginRaceSetupQuietPresentation("mcm_bosmer_path")
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
    EndRaceSetupQuietPresentation()
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
    SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
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

    BeginRaceSetupQuietPresentation("mcm_khajiit_focus")
    Int f = KHAJIIT_FOCUS_KHENARTHI
    while f <= KHAJIIT_FOCUS_ALKOSH
        StorageUtil.SetFloatValue(None, GetKhajiitFocusWeightKey(f), 0.0)
        f += 1
    endWhile

    StorageUtil.SetFloatValue(None, GetKhajiitFocusWeightKey(focusValue), KHAJIIT_FOCUS_THRESHOLD + KHAJIIT_FOCUS_LEAD_REQUIRED + 10.0)
    EvaluateKhajiitFocusedEmphasis()
    EndRaceSetupQuietPresentation()
    Trace(1, "Khajiit focus debug-set to " + GetKhajiitFocusLabel(focusValue))
EndFunction

; Forces the Breton tradition (Knights Road / Hidden Art / Green Way).
Function DebugSetBretonTradition(Int traditionValue)
    Int normalized = ClampInt(traditionValue, BRETON_TRADITION_KNIGHTS_ROAD, BRETON_TRADITION_GREEN_WAY)
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    Trace(1, "Breton tradition debug-set to " + normalized)
EndFunction

; MCM fray-test seed: forces a Green Way / Druidic-fork Breton with DruidicStanding
; one point above the fraying band and the decay day-key cleared, so the next one
; or two ProcessDawn passes drop it past <30 and the Survey/label read "frayed".
Function DebugSeedBretonDruidicFrayTest()
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", BRETON_TRADITION_GREEN_WAY)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_fray_test")
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 31)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicDecayDay", 0)
    Trace(1, "Breton Druidic fray test seeded: GreenWay/Druidic, standing=31")
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
        DrainHircineRenunciationJournal()
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
        DrainHircineResiduePrismaToasts()
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
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Offered", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Refused", 0)
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

    Message offerMessage = GetFormalCommitmentOfferMessage(candidate)
    if !offerMessage
        Trace(1, "Commitment offer skipped for " + candidate.DeityName + ": no offer message wired.")
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

    DispatchDiegeticCue("offer", deity.DeityName, "present", deity, "revelation")
    StorageUtil.SetIntValue(deity as Form, "PDV.Commitment.Offered", 1)
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
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD
        return GetNordFormalCommitmentOfferMessage(deity)
    elseIf originRace == ORIGIN_IMPERIAL
        return GetImperialFormalCommitmentOfferMessage(deity)
    elseIf originRace == ORIGIN_DUNMER
        return GetDunmerFormalCommitmentOfferMessage(deity)
    elseIf originRace == ORIGIN_ALTMER
        return GetAltmerFormalCommitmentOfferMessage(deity)
    elseIf originRace == ORIGIN_BRETON
        return GetBretonFormalCommitmentOfferMessage(deity)
    elseIf originRace == ORIGIN_REDGUARD
        return GetRedguardFormalCommitmentOfferMessage(deity)
    endIf

    return None
EndFunction

Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction, PDV_DeityBase deity, String toneOverride = "")
    Int deityIndex = -1
    if deity
        deityIndex = deity.DeityIndex
    endIf

    Bool headline = eventClass == "offer" && (direction == "accept" || direction == "refuse")
    SurfaceTransition(eventClass, surfaceKey, direction, deityIndex, toneOverride, False, headline)
EndFunction

Message Function GetNordFormalCommitmentOfferMessage(PDV_DeityBase deity)
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
        if GetNordPantheonBaselineState() == NORD_BASELINE_OLD_WAYS
            return PDV_Msg_Nord_Orkey_Offer
        endIf
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

Message Function GetDunmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Azura
        return PDV_Msg_Dunmer_Azura_Offer
    elseIf deity == PDV_Boethiah
        return PDV_Msg_Dunmer_Boethiah_Offer
    elseIf deity == PDV_Mephala
        return PDV_Msg_Dunmer_Mephala_Offer
    endIf

    return None
EndFunction

Message Function GetAltmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_AuriEl
        return PDV_Msg_Altmer_AuriEl_Offer
    elseIf deity == PDV_Magnus
        return PDV_Msg_Altmer_Magnus_Offer
    elseIf deity == PDV_Xarxes
        return PDV_Msg_Altmer_Xarxes_Offer
    elseIf deity == PDV_Trinimac
        return PDV_Msg_Altmer_Trinimac_Offer
    elseIf deity == PDV_Syrabane
        return PDV_Msg_Altmer_Syrabane_Offer
    endIf

    return None
EndFunction

Message Function GetBretonFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Stendarr
        return PDV_Msg_Breton_Stendarr_Offer
    elseIf deity == PDV_Akatosh
        return PDV_Msg_Breton_Akatosh_Offer
    elseIf deity == PDV_Mara
        return PDV_Msg_Breton_Mara_Offer
    elseIf deity == PDV_Arkay
        return PDV_Msg_Breton_Arkay_Offer
    elseIf deity == PDV_Julianos
        return PDV_Msg_Breton_Julianos_Offer
    elseIf deity == PDV_Zenithar
        return PDV_Msg_Breton_Zenithar_Offer
    elseIf deity == PDV_Kynareth
        return PDV_Msg_Breton_Kynareth_Offer
    elseIf deity == PDV_Dibella
        return PDV_Msg_Breton_Dibella_Offer
    elseIf deity == PDV_Magnus
        return PDV_Msg_Breton_Magnus_Offer
    elseIf deity == PDV_Yffre
        return PDV_Msg_Breton_Yffre_Offer
    endIf

    return None
EndFunction

Message Function GetImperialFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Akatosh
        return PDV_Msg_Imperial_Akatosh_Offer
    elseIf deity == PDV_Talos && IsImperialTalosOfferAllowed()
        return PDV_Msg_Imperial_Talos_Offer
    elseIf deity == PDV_Kynareth
        return PDV_Msg_Imperial_Kynareth_Offer
    elseIf deity == PDV_Mara
        return PDV_Msg_Imperial_Mara_Offer
    elseIf deity == PDV_Zenithar
        return PDV_Msg_Imperial_Zenithar_Offer
    elseIf deity == PDV_Arkay
        return PDV_Msg_Imperial_Arkay_Offer
    elseIf deity == PDV_Stendarr
        return PDV_Msg_Imperial_Stendarr_Offer
    elseIf deity == PDV_Julianos
        return PDV_Msg_Imperial_Julianos_Offer
    elseIf deity == PDV_Dibella
        return PDV_Msg_Imperial_Dibella_Offer
    endIf

    return None
EndFunction

Message Function GetRedguardFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Tuwhacca
        return PDV_Msg_Redguard_Tuwhacca_Offer
    elseIf deity == PDV_Leki
        return PDV_Msg_Redguard_Leki_Offer
    elseIf deity == PDV_HoonDing
        return PDV_Msg_Redguard_HoonDing_Offer
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

    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 0)
    SetActiveDeity(pendingDeity)
    SyncFirstTierRaceRewardRuntime()
    DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")
    SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "good", BuildCommitmentOfferAcceptToastLine(pendingDeity), "")
    if carryAmount > 0.0
        AwardPiety(pendingDeity, carryAmount, "commitment_carryover")
    endIf
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

    if IsCommitmentRefused(deity)
        return False
    endIf

    if IsCommitmentOffered(deity)
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

    return IsNordOfferEligibleDeity(deity) || IsImperialOfferEligibleDeity(deity) || IsDunmerOfferEligibleDeity(deity) || IsAltmerOfferEligibleDeity(deity) || IsRedguardOfferEligibleDeity(deity) || IsBretonOfferEligibleDeity(deity)
EndFunction

; Nord's defining mechanic: deeds reveal which god noticed you. Any deity in the
; chosen pantheon baseline (plus Talos/Ysmir, always) is offer-eligible -- not only
; Kyne. Their T1/T2/T3 reward spells are authored; this opens the organic path to
; them. The eligibility/weight/signal-day machinery is already generic.
; Old Ways also carries Arkay (surfaced under the Nord name Orkey) and Dibella
; (owner directive 2026-07-05); display-name handling lives in
; NormalizePublicDeityDisplayText, rewards reuse the Imperial spells (Mara pattern).
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
        return deity == PDV_Kyne || deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Stuhn || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Dibella
    elseIf baselineState == NORD_BASELINE_NINE_DIVINES
        return deity == PDV_Akatosh || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Zenithar || deity == PDV_Dibella || deity == PDV_Julianos || deity == PDV_Kynareth
    endIf

    return False
EndFunction

Bool Function IsGenericLikesDislikesDeityReachable(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD
        return IsNordOfferEligibleDeity(deity)
    endIf

    return deity.GetStanceForRace(originRace) == deity.STANCE_NATIVE
EndFunction

Bool Function IsDunmerOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        return False
    endIf

    return deity == PDV_Azura || deity == PDV_Boethiah || deity == PDV_Mephala
EndFunction

Bool Function IsAltmerOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_ALTMER
        return False
    endIf

    return deity == PDV_AuriEl || deity == PDV_Magnus || deity == PDV_Xarxes || deity == PDV_Trinimac || deity == PDV_Syrabane
EndFunction

Bool Function IsBretonOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf

    Int traditionValue = GetBretonTraditionValue()
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        return deity == PDV_Stendarr || deity == PDV_Akatosh || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Julianos || deity == PDV_Zenithar || deity == PDV_Kynareth || deity == PDV_Dibella
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        if deity == PDV_Magnus || deity == PDV_Mara
            return True
        endIf
        return IsBretonHiddenArtDaedricOfferDeity(deity)
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return deity == PDV_Yffre
    endIf

    return False
EndFunction

Bool Function IsBretonHiddenArtDaedricOfferDeity(PDV_DeityBase deity)
    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if !path
        return False
    endIf

    String pathName = path.DeityName
    return pathName == "Hermaeus Mora" || pathName == "Hircine" || pathName == "Namira" || pathName == "Nocturnal"
EndFunction

Bool Function IsImperialOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return False
    endIf

    if deity == PDV_Talos
        return IsImperialTalosOfferAllowed()
    endIf

    return deity == PDV_Akatosh || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Stendarr || deity == PDV_Zenithar || deity == PDV_Dibella || deity == PDV_Julianos || deity == PDV_Kynareth
EndFunction

Bool Function IsImperialTalosOfferAllowed()
    if !PDV_ConcordatStandingTrack
        return False
    endIf

    return PDV_ConcordatStandingTrack.GetValue() <= 50
EndFunction

Bool Function ShouldSuppressImperialTalosTierSurface(PDV_DeityBase deity)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return False
    endIf

    if deity != PDV_Talos
        return False
    endIf

    return !IsImperialTalosOfferAllowed()
EndFunction

Bool Function IsRedguardOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_REDGUARD
        return False
    endIf

    return deity == PDV_Tuwhacca || deity == PDV_HoonDing || deity == PDV_Leki
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

    ClearPendingCommitment()
    Trace(1, "Commitment declined/postponed.")
EndFunction

Function DebugRefusePendingCommitment()
    PDV_DeityBase pendingDeity = GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    ; Owner ruling (Mega Packet Sitting 1 U8): formal-offer REFUSAL is visible as
    ; a refusal toast and pinned Book of Days chronicle, but it must not fire the
    ; diegetic director's screen wash or D1 sound. SurfaceTransition with
    ; silent=True writes and pins the chronicle while skipping that director cue.
    ; The ACCEPT path keeps its revelation toast + sound.
    SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)
    SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "warning", BuildCommitmentOfferRefuseToastLine(pendingDeity), "")
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 1)
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

Bool Function IsCommitmentOffered(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Offered") == 1
EndFunction

Bool Function IsCommitmentRefused(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Refused") == 1
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
            DrainHircineResiduePrismaToasts()
        endIf
    endIf
EndFunction

Function HandleCurseStateTransition(Int oldState, Int newState, String reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.State", newState)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", reason)

    Bool suppressOutputs = IsCurseStateLoadReconciliation(reason)
    Bool previousSuppress = _suppressCurseTransitionOutputs
    _suppressCurseTransitionOutputs = suppressOutputs
    ApplyCurseRaceHandlers(oldState, newState, reason)
    _suppressCurseTransitionOutputs = previousSuppress

    Trace(1, "Curse transition " + oldState + " -> " + newState + " (" + reason + ")")
    if suppressOutputs
        Trace(2, "Curse transition surfaced silently during load reconciliation.")
    else
        SendPrismaCurseToast(oldState, newState)
        SurfaceCurseTransitionDiegetic(oldState, newState)
    endIf
    RequestPanelRefresh()
EndFunction

Bool Function IsCurseStateLoadReconciliation(String reason)
    return reason == "eventbus_Load" || reason == "eventbus_alias_init"
EndFunction

; Derive a typed "curse" Prisma event from an old-to-new curse-state transition.
; Symbol names (curse-vampire, curse-werewolf) fall back to "journal" until
; the glyph design pass lands; no rendering breakage in the meantime.
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

    ; Send explicit phase-correct title/message so app.js never falls to its no-phase
    ; "A curse stirs" default (it prefers an explicit title/message when present, like
    ; the working milestone toast). PLACEHOLDER copy.
    String curseLabel = "The curse"
    if curseType == "werewolf"
        curseLabel = "Lycanthropy"
    elseIf curseType == "vampire"
        curseLabel = "Vampirism"
    endIf
    String curseTitle = curseLabel + " stirs"
    String curseMessage = "Something has changed in your blood."
    if phase == "onset"
        curseTitle = curseLabel + " takes hold"
        curseMessage = curseLabel + " has taken root in your blood."
    elseIf phase == "cure"
        curseTitle = curseLabel + " is lifted"
        curseMessage = curseLabel + " has been driven out."
    elseIf phase == "shift"
        curseTitle = "The curse changes shape"
        curseMessage = "One curse gives way to another."
    endIf

    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"curse\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"curse\":\"" + JsonSafeString(curseType) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + JsonSafeString(curseTitle) + "\""
    j = j + ",\"message\":\"" + JsonSafeString(curseMessage) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + JsonSafeString(GetPublicDeityDisplayName(_activeDeity)) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction

; Short race-specific context phrase feeds the UI's listText fallback and any
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
Bool Function SendPrismaShiftToast(String shiftMode, String context, String symbolName, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"shift\""
    j = j + ",\"shiftMode\":\"" + JsonSafeString(shiftMode) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + JsonSafeString(GetPublicDeityDisplayName(_activeDeity)) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, shiftMode, context, allowFallback)
EndFunction

; Emit a substrate instrument event without making Prisma the gameplay proof lane.
Bool Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String stateLabel, Bool allowFallback = True)
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
    String fallbackTitle = stateLabel
    if fallbackTitle == ""
        fallbackTitle = substrate
    endIf
    return SendPrismaToastPayloadOrFallback(j, fallbackTitle, context, allowFallback)
EndFunction

Function SendPrismaSubstrateProgress(String substrate, Int tierBefore, Int tierAfter, Float multiplier, String context, String symbolName, String stateLabel)
    if tierAfter > tierBefore
        SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
    elseIf tierAfter < tierBefore
        SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)
    elseIf multiplier > 0.0
        SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
    endIf

    if multiplier > 0.0 && context != "" && tierAfter >= tierBefore
        AppendBookOfDaysEntry(context, Utility.GetCurrentGameTime() as Int, "substrate.act", symbolName, False)
    endIf
EndFunction

; Emit a "daedric" event for a Daedric Prince interaction.
; princeName = e.g. "Hircine", "Azura"
; phase      = "boon" | "price" | "lapse" | "residue" | "prayer"
; context    = optional short phrase
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Bool Function SendPrismaDaedricToast(String princeName, String phase, String context, String symbolName, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"prince\":\"" + JsonSafeString(princeName) + "\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, princeName, context, allowFallback)
EndFunction

Function DrainHircineResiduePrismaToasts()
    if !PDV_HircinePath
        return
    endIf

    Form hircineForm = PDV_HircinePath.GetDeityForm()
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks") > 0
        return
    endIf

    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastPending") == 1
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastPending", 0)
        SendPrismaDaedricToast("Hircine", "residue", "The hunt's old mark still follows.", "hircine")
    endIf
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueClearToastPending") == 1
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueClearToastPending", 0)
        SendPrismaDaedricToast("Hircine", "residue", "The hunt's old mark fades.", "hircine")
    endIf
EndFunction

Function ProcessDelayedHircineResiduePrismaToasts()
    if !PDV_HircinePath
        return
    endIf

    Form hircineForm = PDV_HircinePath.GetDeityForm()
    Int delayTicks = StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks")
    if delayTicks > 0
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks", delayTicks - 1)
        return
    endIf

    DrainHircineResiduePrismaToasts()
EndFunction

Function DrainHircineRenunciationJournal()
    if !PDV_HircinePath
        return
    endIf

    Form hircineForm = PDV_HircinePath.GetDeityForm()
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.RenunciationJournalPending") != 1
        return
    endIf

    StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.RenunciationJournalPending", 0)
    SendPrismaToast("hircine", "neutral", "You renounce the hunt.", "Hircine's pact is set down.")
    AppendBookOfDaysEntry("Hircine's mark fades from your blood, and the pack is no longer yours.", Utility.GetCurrentGameTime() as Int, "reorientation", "hircine", True, 3)
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
    SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone presentation: " + princeName + " " + tierLabel + " prisma=" + prismaSent)
    endIf
    ; Surface the Daedric tier gain in the Book of Days like a patron tier-up
    ; (tone tier.reach -> "Favor deepened"/good; Champion pinned). The toast already
    ; fired above; this adds the persistent journal entry. PLACEHOLDER copy.
    AppendBookOfDaysEntry(princeName + " names you " + tierLabel + ".", Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, newTier >= TIER_CHAMPION)
    StorageUtil.SetFormValue(None, "PDV.Daedric.LastMilestoneJournalPath", path.GetDeityForm())
    StorageUtil.SetFloatValue(None, "PDV.Daedric.LastMilestoneJournalTime", Utility.GetCurrentGameTime())
EndFunction

Bool Function HasRecentDaedricMilestoneJournal(PDV_DaedricPathBase path)
    if !path
        return false
    endIf
    if StorageUtil.GetFormValue(None, "PDV.Daedric.LastMilestoneJournalPath") != path.GetDeityForm()
        return false
    endIf
    Float lastTime = StorageUtil.GetFloatValue(None, "PDV.Daedric.LastMilestoneJournalTime")
    return lastTime > 0.0 && (Utility.GetCurrentGameTime() - lastTime) <= 0.0001
EndFunction

Bool Function SendPrismaDaedricMilestoneToast(String princeName, String tierLabel, String flavorText, String boonText, String priceText, String symbolName, Bool allowFallback = True)
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
    Bool sent = SendPrismaToastPayloadOrFallback(j, titleText, flavorText, allowFallback)
    if sent
        QueuePrismaToastRetry(j, princeName + " " + tierLabel)
    endIf
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
        return "azura"
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
            if !_suppressCurseTransitionOutputs
                PDV_HircinePath.HandleCurseTransition(oldState, newState, reason)
                if oldState != 1 && newState == 1
                    AppendBookOfDaysEntry("The beast-blood took you and stirred Hircine. The Hunt is in you now.", Utility.GetCurrentGameTime() as Int, "curse.onset", "hircine", False, 3)
                endIf
                PDV_HircinePath.UpdateResidueRecovery()
                DrainHircineResiduePrismaToasts()
            endIf
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
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal || !messageRecord
        SendPrismaToast("hist", "warning", "", fallback)
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
        if !_suppressCurseTransitionOutputs
            EmitMalacathCurseCodeRuptureMinus("werewolf_onset_" + reason)
        endIf
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
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal
        SendPrismaToast("kyne", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ShowNordNotification(Message messageRecord, String fallbackText)
    if messageRecord
        messageRecord.Show()
        return
    endIf

    SendPrismaToast("kyne", "neutral", "", fallbackText)
EndFunction

Function ShowRedguardNotification(Message messageRecord, String fallbackText)
    if messageRecord
        messageRecord.Show()
        return
    endIf

    SendPrismaToast("tuwhacca", "neutral", "", fallbackText)
EndFunction

Function ShowOrcNotification(Message messageRecord, String fallbackText)
    if messageRecord
        messageRecord.Show()
        return
    endIf

    SendPrismaToast("malacath", "neutral", "", fallbackText)
EndFunction

Function ShowOrcMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal
        SendPrismaToast("malacath", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ShowRedguardMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal
        SendPrismaToast("tuwhacca", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ShowAltmerMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if _suppressCurseTransitionOutputs
        return
    endIf

    if suppressModal
        SendPrismaToast("auriel", "warning", "", fallbackText)
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
    if originRace == ORIGIN_BRETON || originRace == ORIGIN_BOSMER || originRace == ORIGIN_REDGUARD || originRace == ORIGIN_ORC || originRace == ORIGIN_NORD
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
    elseIf originRace == ORIGIN_NORD
        return StorageUtil.GetIntValue(None, "PDV.Nord.SetupComplete") == 1
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
    elseIf originRace == ORIGIN_NORD
        if optionValue == NORD_BASELINE_NINE_DIVINES
            return PDV_MSG_Confirm_Nord_NineDivines
        endIf
        return PDV_MSG_Confirm_Nord_OldWays
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
    elseIf originRace == ORIGIN_NORD
        return PDV_MSG_StartupNordChoice
    endIf

    return None
EndFunction

Int Function GetStartupChoiceMaxOption(Int originRace)
    if originRace == ORIGIN_BOSMER
        return BOSMER_PATH_BANDIT_ROAD
    elseIf originRace == ORIGIN_NORD
        return NORD_BASELINE_NINE_DIVINES
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
    elseIf originRace == ORIGIN_NORD
        return NORD_BASELINE_OLD_WAYS
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
    elseIf originRace == ORIGIN_NORD
        ApplyNordInitialChoice(optionValue, reason)
    endIf
EndFunction

String Function BuildStartupRoadJournalLine(String pathLabel)
    if pathLabel == ""
        return "You've chosen your road."
    endIf
    return "You've chosen your road: " + pathLabel + "."
EndFunction

Function ApplyBretonInitialChoice(Int traditionValue, String reason)
    Int normalized = ClampInt(traditionValue, 0, 2)
    BeginRaceSetupQuietPresentation(reason)
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.StartupReason", reason)
    if normalized == BRETON_TRADITION_GREEN_WAY
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, reason)
        ; Seed the covenant at its open midpoint so a fresh Green Way Breton reads
        ; "open" (50), not the rebanded fraying band (<30). Never lowers an
        ; existing value.
        if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0) < 50
            StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        endIf
    else
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_NONE, reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    PDV_DeityBase traditionDeity = GetBretonTraditionDeity(normalized)
    if traditionDeity
        String traditionLabel = GetBretonTraditionLabel()
        SendPrismaShiftToast("You set your tradition: " + traditionLabel + ".", "", GetPrismaSymbolForDeity(traditionDeity))
        AppendBookOfDaysEntry(BuildStartupRoadJournalLine(traditionLabel), Utility.GetCurrentGameTime() as Int, "reorientation", GetPrismaSymbolForDeity(traditionDeity), True, 3, "", True)
        SurfaceTransition("emergence", traditionDeity.DeityName, "onset", traditionDeity.DeityIndex, "revelation")
    endIf
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    if PDV_RedguardSectTrack
        Int normalized = ClampInt(sectValue, REDGUARD_SECT_CROWN, REDGUARD_SECT_ASHABAH)
        PDV_RedguardSectTrack.SetState(normalized, reason)
        AppendBookOfDaysEntry(BuildStartupRoadJournalLine(GetRedguardSectLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "sect", True, 3, "", True)
        ShowRedguardSectEntry(normalized)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.SetupComplete", 1)
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyOrcInitialChoice(Int modeValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    if PDV_OrcLifeModeTrack
        PDV_OrcLifeModeTrack.SetState(ClampInt(modeValue, ORC_LIFE_MODE_CITY, ORC_LIFE_MODE_LEGION_EXILE), reason)
        AppendBookOfDaysEntry(BuildStartupRoadJournalLine(GetOrcLifeModeLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "malacath", True, 3, "", True)
    endIf
    ; Malacath is the single innate Orc spine (not chosen, not offered) -- activate him as the
    ; patron at origin so the life-mode reward ladder (gated on _activeDeity==PDV_Malacath) is
    ; reachable in normal play; without this the whole Malacath progression was a dead no-op.
    ; Owner ruling 2026-06-27.
    if PDV_Malacath
        SetActiveDeity(PDV_Malacath)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Orc.SetupComplete", 1)
    SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyNordInitialChoice(Int baselineValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    Int normalized = ClampInt(baselineValue, NORD_BASELINE_OLD_WAYS, NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalized)
    if PDV_NordPantheonBaselineTrack
        PDV_NordPantheonBaselineTrack.SetState(normalized, reason)
    endIf

    SetBroadWorship()
    String baselineLabel = "Old Ways"
    if normalized == NORD_BASELINE_NINE_DIVINES
        baselineLabel = "Nine Divines"
    endIf
    AppendBookOfDaysEntry(BuildStartupRoadJournalLine(baselineLabel), Utility.GetCurrentGameTime() as Int, "reorientation", "journal", True, 3, "", True)
    StorageUtil.SetIntValue(None, "PDV.Nord.SetupComplete", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.StartupReason", reason)
    SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
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

; The Green Way is an outdoor covenant. Skyrim keeps pulling a Breton into cities
; and dungeons, so a live druidic covenant quietly frays without recent outdoor
; observance -- a small per-dawn drop mirroring the WitchcraftExposure fade.
; Pressure-only: no boon is withdrawn (DruidicStanding gates no reward).
Function DecayBretonDruidicStandingAtDawn()
    if !ShouldBretonDruidicStandingFray()
        return
    endIf

    ; Once-per-dawn guard, day+1 encoding to dodge the day-0 self-suppression trap.
    Int today = (Utility.GetCurrentGameTime() as Int) + 1
    if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicDecayDay") == today
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicDecayDay", today)

    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    if standingValue <= 0
        return
    endIf
    standingValue = ClampInt(standingValue - 1, 0, 100)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", standingValue)
    Trace(2, "Breton DruidicStanding neglect decay -> " + standingValue)
EndFunction

; Green Way fraying applies to a live or contested druidic covenant only: the
; Druidic fork and the unresolved Werewolf fork. Excludes Betrayed (already under
; SyncBretonDruidicForkBetrayalSpell -- no double pressure) and any non-Green
; Breton (DruidicStanding is pressure-only and must not punish ordinary life).
Bool Function ShouldBretonDruidicStandingFray()
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != BRETON_TRADITION_GREEN_WAY
        return False
    endIf
    return GetBretonDruidicForkValue() != BRETON_DRUIDIC_FORK_BETRAYED
EndFunction

Function AwardBretonAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return
    endIf

    ; One-shot legacy sweep: the substrate boons only need stripping once per
    ; save (dawn refresh still covers stragglers); re-stripping on every signal
    ; repeats RemoveSpell work for no state change.
    if PDV_BretonAncestorSubstrate && StorageUtil.GetIntValue(None, "PDV.Breton.SubstrateLegacyCleared") != 1
        PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
        StorageUtil.SetIntValue(None, "PDV.Breton.SubstrateLegacyCleared", 1)
    endIf

    Trace(2, "Retired Breton ancestor spine signal ignored: " + reason + " x" + multiplier)
EndFunction

Function RunDawnRefreshBretonAncestor()
    if !PDV_BretonAncestorSubstrate
        return
    endIf

    PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
EndFunction

Function HandleBretonKnightlyVow(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Knightly Vow ignored for non-Breton origin.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")
    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == 0
        if multiplier <= 0.0
            return
        endIf

        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowCount", StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount") + 1)
        StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
        if PDV_Stendarr
            AwardCuratedSignalScaled(PDV_Stendarr, PDV_Stendarr.SIGNAL_MERCY, None, multiplier)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Breton.CrossTraditionPressure", StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") + 1)
    endIf

    AwardBretonAncestorSpinePulse(multiplier, reason)
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
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonHiddenArtExposure")
    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == BRETON_TRADITION_HIDDEN_ART && PDV_Magnus
        if multiplier > 0.0
            AwardCuratedSignalScaled(PDV_Magnus, PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None, multiplier)
        endIf
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) == BRETON_TRADITION_HIDDEN_ART && PDV_Mara
        if multiplier > 0.0 && StringContainsToken(reason, "home")
            AwardCuratedSignalScaled(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    endIf
    AwardBretonAncestorSpinePulse(multiplier, reason)
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
    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", ClampInt(standingValue + 25, 0, 100))
    StorageUtil.SetIntValue(None, "PDV.Breton.GreenWayCount", StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonGreenWayStanding")
    if IsBretonGreenWayForkEligible() && PDV_Yffre
        if multiplier > 0.0
            ; Breton-voiced Green Way signal; the Bosmer Living Story signal stays
            ; Bosmer-only so driver rows read in the right tradition's voice.
            AwardCuratedSignalScaled(PDV_Yffre, PDV_Yffre.SIGNAL_GREEN_WAY, None, multiplier)
        endIf
    endIf
    AwardBretonAncestorSpinePulse(multiplier, reason)
    Trace(2, "Breton Green Way standing routed: " + reason)
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER
        Trace(2, "Dunmer Reclamation focus ignored for non-Dunmer origin.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerReclamationFocus")
    if multiplier <= 0.0
        return
    endIf

    Float layerWeight = GetDunmerCurseLayerWeight(2) * multiplier
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerDeviationPrice")
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.DeviationPriceCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastDeviationReason", reason)
    AwardDunmerDeviationPriceSignal(multiplier)
    SurfaceDunmerDeviationPriceNotice()
    Trace(2, "Dunmer deviation price routed: " + reason)
EndFunction

Function SurfaceDunmerDeviationPriceNotice()
    if !_activeDeity
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    String activeName = GetPublicDeityDisplayName(_activeDeity)
    String symbolName = GetPrismaSymbolForDeity(_activeDeity)
    String line = "The ash-prayer thins; " + activeName + " marks the wound."
    AppendBookOfDaysEntry(line, today, "creed.drop", symbolName, False, 2, "Reclamation strained")

    String toastKey = "PDV.Toast.DunmerDeviationPrice.Day"
    if StorageUtil.GetIntValue(None, toastKey, -1) != today
        StorageUtil.SetIntValue(None, toastKey, today)
        SendPrismaToast(symbolName, "warning", "Reclamation strained", line)
    endIf
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
    if TryAwardDunmerTwilightWindowSignal(reason)
        SendPrismaToast("journal", "good", "Good Daedra", "The Good Daedra hear the ash-prayer.")
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        SendPrismaToast("journal", "neutral", "Shrine quiet", "The shrine is quiet in this hour.")
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

Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_Azura || multiplier <= 0.0
        return
    endIf

    AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Dunmer.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
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

Function AwardDunmerDeviationPriceSignal(Float multiplier)
    if _activeDeity == PDV_Boethiah && PDV_Boethiah
        AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf _activeDeity == PDV_Mephala && PDV_Mephala
        AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf _activeDeity == PDV_Azura && PDV_Azura
        AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_DESECRATION, None, multiplier)
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

Function AwardImperialCivicFamilySignal(Int familyId, Float multiplier)
    if familyId == IMPERIAL_CIVIC_PUBLIC_SERVICE
        if PDV_Akatosh
            AwardCuratedSignalScaled(PDV_Akatosh, PDV_Akatosh.SIGNAL_CIVIC_SERVICE, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_MERCY
        if PDV_Mara
            AwardCuratedSignalScaled(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_LAWFUL_ORDER
        if PDV_Stendarr
            AwardCuratedSignalScaled(PDV_Stendarr, PDV_Stendarr.SIGNAL_LAWFUL_ORDER, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_HONEST_WORK
        if PDV_Zenithar
            AwardCuratedSignalScaled(PDV_Zenithar, PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_DEATH_DUTY
        if PDV_Arkay
            AwardCuratedSignalScaled(PDV_Arkay, PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    endIf
EndFunction

Function AwardImperialPatronCivicSignal(Float multiplier)
    if !_activeDeity
        return
    endIf

    if _activeDeity == PDV_Akatosh && PDV_Akatosh
        AwardCuratedSignalScaled(PDV_Akatosh, PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Mara && PDV_Mara
        AwardCuratedSignalScaled(PDV_Mara, PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Arkay && PDV_Arkay
        AwardCuratedSignalScaled(PDV_Arkay, PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Stendarr && PDV_Stendarr
        AwardCuratedSignalScaled(PDV_Stendarr, PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Zenithar && PDV_Zenithar
        AwardCuratedSignalScaled(PDV_Zenithar, PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Dibella && PDV_Dibella
        AwardCuratedSignalScaled(PDV_Dibella, PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Julianos && PDV_Julianos
        AwardCuratedSignalScaled(PDV_Julianos, PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == PDV_Kynareth && PDV_Kynareth
        AwardCuratedSignalScaled(PDV_Kynareth, PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    endIf
EndFunction

Function AwardImperialAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if PDV_ImperialAncestorSubstrate
        tierBefore = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(multiplier, reason)
        Int tierAfter = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("imperial-civic", tierBefore, tierAfter, multiplier, "Your public service steadies your devotion.", "talos", GetImperialCivicLayerLabel())
    endIf

    if PDV_Talos
        AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Imperial.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Imperial.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Imperial.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Trace(2, "Imperial ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshImperialAncestor()
    if !PDV_ImperialAncestorSubstrate
        return
    endIf

    PDV_ImperialAncestorSubstrate.ProcessCivicDawn(False, "dawn")
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ImperialCivicService." + GetImperialCivicFamilyLabel(civicFamily))
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.CivicServiceCount", StorageUtil.GetIntValue(None, "PDV.Imperial.CivicServiceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicServiceReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicFamily", GetImperialCivicFamilyLabel(civicFamily))
    StorageUtil.SetFloatValue(None, "PDV.Imperial.LastCivicServiceTime", Utility.GetCurrentGameTime())
    AwardImperialCivicFamilySignal(civicFamily, multiplier)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    Trace(2, "Imperial civic service routed: " + reason + " family " + GetImperialCivicFamilyLabel(civicFamily))
EndFunction

Function HandleImperialTalosPressure(Bool isPrivate, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial Talos pressure ignored for non-Imperial origin.")
        return
    endIf

    String repeatKey = "PDV.Signal.ImperialPublicTalosPressure"
    if isPrivate
        repeatKey = "PDV.Signal.ImperialPrivateTalosPressure"
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier(repeatKey)
    if multiplier <= 0.0
        return
    endIf

    if isPrivate
        StorageUtil.SetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") + 1)
        if PDV_Talos
            AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.PublicTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") + 1)
        if PDV_Talos
            AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_DEFIANCE_MILESTONE, None, multiplier)
        endIf
    endIf

    StorageUtil.SetStringValue(None, "PDV.Imperial.LastTalosPressureReason", reason)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    ShowP2BookNotice(reason, "The name of Talos", "The question of the Ninth presses harder.")
    Trace(2, "Imperial Talos pressure routed: " + reason)
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial patron civic favor ignored for non-Imperial origin.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ImperialPatronCivicFavor")
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.PatronCivicFavorCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastPatronCivicFavorReason", reason)
    AwardImperialPatronCivicSignal(multiplier)
    AwardImperialAncestorSpinePulse(multiplier, reason)
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

Function AwardNordRouteFamilySignal(Int familyValue, Float multiplier)
    if familyValue == NORD_ROUTE_OLD_SKY_ROAD
        ; Kyne's curated sky-road milestone bump. Services broad Old Ways worship
        ; and a focused Kyne patron alike (direct deity award, patron-agnostic).
        if PDV_Kyne
            AwardCuratedSignalScaled(PDV_Kyne, PDV_Kyne.SIGNAL_SKY_ROAD, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_ORDEAL
        if PDV_Tsun
            AwardCuratedSignalScaled(PDV_Tsun, PDV_Tsun.SIGNAL_TRIAL_ENDURED, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_HEARTH
        if PDV_Stuhn
            AwardCuratedSignalScaled(PDV_Stuhn, PDV_Stuhn.SIGNAL_PROTECT_BOND, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_ANCESTOR
        if PDV_Shor
            AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_HONORED_DEAD, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_TALOS || familyValue == NORD_ROUTE_NINE_TALOS
        if PDV_Talos
            AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_ROAD
        if PDV_Kynareth
            AwardCuratedSignalScaled(PDV_Kynareth, PDV_Kynareth.SIGNAL_OPEN_SKY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_MERCY
        if PDV_Mara
            AwardCuratedSignalScaled(PDV_Mara, PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_DEATH
        if PDV_Arkay
            AwardCuratedSignalScaled(PDV_Arkay, PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_WORK
        if PDV_Zenithar
            AwardCuratedSignalScaled(PDV_Zenithar, PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.NordRouteFamily." + routeFamily)

    Int laneValue = GetNordFavorLaneForRouteFamily(routeFamily)
    Int favorFamily = GetNordFavorFamilyForRouteFamily(routeFamily)
    if laneValue != FAVOR_LANE_NONE && favorFamily > 0
        TryActivateContextualFavor(laneValue, favorFamily, reason)
    endIf

    StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    StorageUtil.SetStringValue(None, lastReasonKey, reason)
    StorageUtil.SetFloatValue(None, lastTimeKey, Utility.GetCurrentGameTime())
    if multiplier > 0.0
        RecordNordAncestorSpine(reason, multiplier)
        AwardNordRouteFamilySignal(routeFamily, multiplier)
    endIf
    ; Nord broad/focused survey + reward state should react on the accepted source itself, not wait
    ; for the next dawn pass. This is especially visible on broad Old Ways T1, which otherwise does
    ; not appear until ProcessDawn even after the third accepted source has already been read.
    SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
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
        return "You begin by choosing your pantheon baseline: the Old Ways of Kyne, Shor, Tsun, Stuhn, Mara, and Talos, or the Nine Divines as Skyrim now names them."
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
    return GetStartupCanonicalSummary(originRace) + "\n\n" + GetStartupInfoOnlyFollowup(originRace)
EndFunction

String Function GetStartupInfoOnlyFollowup(Int originRace)
    if originRace == ORIGIN_IMPERIAL
        return "Live under the Divines. Your choices will decide how Talos, law, and public duty weigh on you."
    elseIf originRace == ORIGIN_DUNMER
        return "Your choices will show whether ancestor, Tribunal memory, or Reclamation answers most clearly."
    elseIf originRace == ORIGIN_ALTMER
        return "Your choices will test that inheritance, and whether purity holds or bends."
    elseIf originRace == ORIGIN_KHAJIIT
        return "Your path will emerge through moon, road, rest, and the company you keep."
    elseIf originRace == ORIGIN_ARGONIAN
        return "Your choices will show whether Hist, people, borrowed gods, or Void draws nearest."
    endIf

    return "Your choices, rites, and conduct will shape which powers answer."
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
        if optionValue == NORD_BASELINE_NINE_DIVINES
            return "nine_divines"
        endIf
        return "old_ways"
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
    elseIf originRace == ORIGIN_NORD
        if optionValue == NORD_BASELINE_NINE_DIVINES
            return "Nine Divines"
        endIf
        return "Old Ways"
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
    elseIf originRace == ORIGIN_NORD
        if optionValue == NORD_BASELINE_NINE_DIVINES
            return "Skyrim's gods carried through the Imperial names and the public shrines."
        endIf
        return "Kyne, Shor, Tsun, Stuhn, Mara, and Talos kept as the old Nord spine."
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
    elseIf originRace == ORIGIN_NORD
        if optionValue == NORD_BASELINE_NINE_DIVINES
            return "The Nine Divines lane keeps Nord devotion inside Skyrim's public shrines and Imperial names, with Talos still central to the road ahead."
        endIf
        return "The Old Ways lane keeps Kyne, Shor, Tsun, Stuhn, Mara, and Talos as your native pantheon baseline."
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
    payload = payload + ",\"advisory_line\":\"" + JsonSafeString("The medallion shows the roster; commitment comes through an offer.") + "\""
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

String Function BuildBookOfDaysPathInfo(Int originRace)
    return GetOriginRaceLabel(originRace) + " - " + GetBookOfDaysPathStatusLabel(originRace)
EndFunction

String Function GetBookOfDaysPathStatusLabel(Int originRace)
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Path Not Yet Chosen"
    endIf

    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
    if activePact
        return NormalizePublicDeityDisplayText(activePact.DeityName) + " Pact"
    endIf

    if _activeDeity && GetPatronState() == PATRON_STATE_ACTIVE
        return GetPublicDeityDisplayName(_activeDeity) + " Focus"
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        return GetBroadLaneDisplayName(originRace)
    endIf

    if originRace == ORIGIN_NORD
        return GetNordDevotionModeLabel()
    elseIf originRace == ORIGIN_ALTMER
        return "Crisis " + GetBookOfDaysAltmerCrisisLabel()
    elseIf originRace == ORIGIN_KHAJIIT
        Int focusValue = GetKhajiitFocusedEmphasis()
        if focusValue > KHAJIIT_FOCUS_NONE
            return GetKhajiitFocusLabel(focusValue) + " Lunar Focus"
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_BOSMER
        return GetBosmerPathLabel()
    elseIf originRace == ORIGIN_ARGONIAN
        return "Hist " + GetArgonianHistPostureLabel()
    elseIf originRace == ORIGIN_ORC
        return GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return GetRedguardSectLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_BRETON
        return GetBretonTraditionLabel()
    elseIf originRace == ORIGIN_DUNMER
        Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
        if reclamationFocus >= 0
            return GetDunmerReclamationFocusLabel(reclamationFocus) + " Reclamation Focus"
        endIf
        return "Ancestor Rites " + GetBookOfDaysDunmerAncestorLabel()
    endIf

    return "Path Unsettled"
EndFunction

String Function GetBookOfDaysAltmerCrisisLabel()
    Int stateValue = GetAltmerCrisisState()
    if stateValue == ALTMER_CRISIS_DISSONANT
        return "Dissonant"
    elseIf stateValue == ALTMER_CRISIS_QUESTIONING
        return "Questioning"
    elseIf stateValue == ALTMER_CRISIS_REASSERTING
        return "Reasserting"
    elseIf stateValue == ALTMER_CRISIS_SCARRED_RESOLVED
        return "Scarred Resolved"
    endIf

    return "None"
EndFunction

String Function GetBookOfDaysDunmerAncestorLabel()
    if !PDV_DunmerAncestorSubstrate
        return "Unreadable"
    endIf

    Int tierValue = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= 3
        return "Strong"
    elseIf tierValue == 2
        return "Steady"
    elseIf tierValue == 1
        return "Beginning"
    endIf

    return "Quiet"
EndFunction

String Function BuildBookOfDaysSummary(Int originRace)
    if originRace == ORIGIN_NORD
        return "Old Gods, Divines, and chosen roads leave their marks here."
    elseIf originRace == ORIGIN_IMPERIAL
        return "Civic faith, Divines, and Concordat pressure leave their marks here."
    elseIf originRace == ORIGIN_BRETON
        return "Tradition, hidden practice, and old covenants leave their marks here."
    elseIf originRace == ORIGIN_ALTMER
        return "Auri-El, ancestry, and crisis of return leave their marks here."
    elseIf originRace == ORIGIN_BOSMER
        return "Green Pact, exchange, and story-path choices leave their marks here."
    elseIf originRace == ORIGIN_DUNMER
        return "Reclamations, ancestors, and ash-prayer duties leave their marks here."
    elseIf originRace == ORIGIN_KHAJIIT
        return "Moons, road-home ways, and chosen spirits leave their marks here."
    elseIf originRace == ORIGIN_ARGONIAN
        return "Hist memory, People, and the Void leave their marks here."
    elseIf originRace == ORIGIN_ORC
        return "Malacath, Code, and life-mode choices leave their marks here."
    elseIf originRace == ORIGIN_REDGUARD
        return "Yokudan duty, ancestors, and the Far Shores leave their marks here."
    endIf

    return "Faith, conduct, and consequence leave their marks here."
EndFunction

PDV_DeityBase Function ResolveBookOfDaysStandingDeity()
    PDV_DaedricPathBase journalPact = GetActiveDaedricPactPath()
    if journalPact
        return journalPact
    endIf

    if _activeDeity
        return _activeDeity
    endIf

    return StorageUtil.GetFormValue(None, "PDV.BookOfDays.LastTierDeity") as PDV_DeityBase
EndFunction

String Function BuildBookOfDaysInstrumentJson(Int originRace)
    Int tierValue = 0
    Float pietyValue = 0.0
    Float championThreshold = 85.0
    if PDV_GLO_ActiveTier
        tierValue = PDV_GLO_ActiveTier.GetValueInt()
    endIf
    if PDV_GLO_ActivePiety
        pietyValue = PDV_GLO_ActivePiety.GetValue()
    endIf

    PDV_DeityBase journalCommitment = ResolveBookOfDaysStandingDeity()
    if journalCommitment
        championThreshold = journalCommitment.ThresholdChampion
        tierValue = GetTier(journalCommitment)
        pietyValue = GetPiety(journalCommitment)
    else
        Int broadTier = GetBroadLaneTierForOrigin(originRace)
        if broadTier > TIER_NONE
            tierValue = broadTier
            pietyValue = GetBroadLaneServiceCount(originRace) as Float
        endIf
    endIf

    String tierLabel = GetCurrentStandingLabel()
    if journalCommitment == None && GetBroadLaneTierForOrigin(originRace) > TIER_NONE
        tierLabel = GetBroadLaneStandingLabel(originRace, GetBroadLaneTierForOrigin(originRace))
    endIf
    return GetPanelInstrumentJson(originRace, journalCommitment != None, tierValue, tierLabel, pietyValue, championThreshold)
EndFunction

; Build the Book of Days journal JSON payload.
; Entries are ordered oldest-first (index 0 = oldest, last index = newest).
String Function BuildJournalPayloadJson()
    RepairBookOfDaysJournalText()
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    Int titleCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
    Int magnitudeCount = StorageUtil.IntListCount(None, "PDV.Diegetic.Journal.Magnitudes")
    String entries = ""
    Int i = 0
    while i < count
        String line = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", i))
        Int gameDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        String tone = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", i))
        String symbol = JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Symbols", i))
        String fictionDate = JsonSafeString(JournalDayToFictionDate(gameDay))
        String entryTitle = ""
        if i < titleCount
            entryTitle = StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Titles", i)
        endIf
        if entryTitle == ""
            entryTitle = JournalToneToTitle(tone)
        endIf
        entryTitle = JsonSafeString(entryTitle)
        Int magnitude = GetJournalMagnitudeForTone(tone)
        if i < magnitudeCount
            magnitude = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Magnitudes", i)
        endIf
        String valence = JournalToneToValence(tone)
        String entry = "{\"date\":\"" + fictionDate + "\""
        entry = entry + ",\"day\":" + gameDay
        entry = entry + ",\"symbol\":\"" + symbol + "\""
        entry = entry + ",\"tone\":\"" + tone + "\""
        entry = entry + ",\"valence\":\"" + valence + "\""
        entry = entry + ",\"magnitude\":" + magnitude
        entry = entry + ",\"title\":\"" + entryTitle + "\""
        entry = entry + ",\"text\":\"" + line + "\"}"
        if i > 0
            entries = entries + ","
        endIf
        entries = entries + entry
        i += 1
    endWhile
    Int originRace = GetPlayerOriginRaceIndex()
    String pathInfo = BuildBookOfDaysPathInfo(originRace)
    String j = "{\"mode\":\"journal\",\"journal\":{"
    j = j + "\"title\":\"Book of Days\""
    j = j + ",\"by\":\"" + JsonSafeString(GetJournalByline()) + "\""
    j = j + ",\"summary\":\"" + JsonSafeString(BuildBookOfDaysSummary(originRace)) + "\""
    j = j + ",\"survey\":\"" + JsonSafeString(pathInfo) + "\""
    j = j + ",\"foot\":\"Press your Book of Days key again to close.\""
    j = j + ",\"instrument\":" + BuildBookOfDaysInstrumentJson(originRace)
    j = j + ",\"entries\":[" + entries + "]"
    j = j + "}}"
    return j
EndFunction

; --- Book of Days writer ---
; Appends one dated entry to the ring lists BuildJournalPayloadJson renders
; (oldest-first). Tone MUST be a key JournalToneToTitle/JournalToneToValence
; recognize, or the entry renders without a title/valence. headlinePinned entries
; are exempt from the day-window prune so curse/Champion/major-switch beats persist.
Function AppendBookOfDaysEntry(String line, Int gameDay, String tone, String symbol, Bool headlinePinned, Int magnitude = 1, String titleText = "", Bool allowDuringRaceSetup = False)
    if IsRaceSetupQuietPresentationActive() && !allowDuringRaceSetup
        return
    endIf
    if line == ""
        return
    endIf
    line = NormalizePublicDeityDisplayText(line)
    if tone == ""
        tone = "substrate.act"
    endIf
    if symbol == ""
        symbol = "journal"
    endIf

    ; De-dupe: skip when the newest entry is the same day + tone + line, so an
    ; immediate event and the dawn digest cannot restate the same beat, and a
    ; re-entrant dawn cannot double-write.
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    if count > 0
        Int last = count - 1
        if StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", last) == gameDay && StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", last) == tone && StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", last) == line
            return
        endIf
    endIf

    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Lines", line, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Days", gameDay, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Tones", tone, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Symbols", symbol, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Pinned", BoolToInt(headlinePinned), True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Magnitudes", ClampInt(magnitude, 1, 3), True)
    if titleText == ""
        titleText = BuildJournalEventTitle(tone, "")
    endIf
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Titles", titleText, True)

    PruneBookOfDays()

EndFunction

Function RepairBookOfDaysJournalText()
    Int repairVersion = 2
    if StorageUtil.GetIntValue(None, "PDV.BookOfDays.TextRepairVersion") >= repairVersion
        return
    endIf

    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    Int i = 0
    Int repaired = 0
    while i < count
        String oldLine = StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", i)
        String newLine = NormalizePublicDeityDisplayText(oldLine)
        if newLine != oldLine
            StorageUtil.StringListSet(None, "PDV.Diegetic.Journal.Lines", i, newLine)
            repaired += 1
        endIf
        i += 1
    endWhile

    Int titleCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
    i = 0
    while i < titleCount
        String oldTitle = StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Titles", i)
        String newTitle = oldTitle
        if oldTitle == "an act of devotion"
            newTitle = "An act of devotion"
        endIf
        if newTitle != oldTitle
            StorageUtil.StringListSet(None, "PDV.Diegetic.Journal.Titles", i, newTitle)
            repaired += 1
        endIf
        i += 1
    endWhile

    StorageUtil.SetIntValue(None, "PDV.BookOfDays.TextRepairVersion", repairVersion)
    if repaired > 0 && GetDebugLevel() >= 1
        Debug.Trace("[PDV] Book of Days display text repaired: " + repaired)
    endIf
EndFunction

String Function GetPublicDeityDisplayName(PDV_DeityBase deity)
    if !deity
        return ""
    endIf
    return NormalizePublicDeityDisplayText(deity.DeityName)
EndFunction

; Nord Old Ways knows Arkay by the older name Orkey (owner directive 2026-07-05).
; Display-only: DeityName stays "Arkay" for StorageUtil keys, symbol lookup, and
; matrix matching; only text resolved through NormalizePublicDeityDisplayText shifts.
Bool Function UsesNordOldWaysDeityNames()
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return False
    endIf
    return GetNordPantheonBaselineState() == NORD_BASELINE_OLD_WAYS
EndFunction

String Function NormalizePublicDeityDisplayText(String sourceText)
    String result = sourceText
    result = ReplaceText(result, "auri-el", "Auri-El")
    result = ReplaceText(result, "akatosh", "Akatosh")
    if UsesNordOldWaysDeityNames()
        result = ReplaceText(result, "arkay", "Orkey")
    else
        result = ReplaceText(result, "arkay", "Arkay")
    endIf
    result = ReplaceText(result, "orkey", "Orkey")
    result = ReplaceText(result, "dibella", "Dibella")
    result = ReplaceText(result, "julianos", "Julianos")
    result = ReplaceText(result, "mara", "Mara")
    result = ReplaceText(result, "stendarr", "Stendarr")
    result = ReplaceText(result, "zenithar", "Zenithar")
    result = ReplaceText(result, "talos", "Talos")
    result = ReplaceText(result, "kyne", "Kyne")
    result = ReplaceText(result, "kynareth", "Kynareth")
    result = ReplaceText(result, "magnus", "Magnus")
    result = ReplaceText(result, "xarxes", "Xarxes")
    result = ReplaceText(result, "y'ffre", "Y'ffre")
    result = ReplaceText(result, "z'en", "Z'en")
    result = ReplaceText(result, "baan dar", "Baan Dar")
    result = ReplaceText(result, "azura", "Azura")
    result = ReplaceText(result, "khenarthi", "Khenarthi")
    result = ReplaceText(result, "rajhin", "Rajhin")
    result = ReplaceText(result, "alkosh", "Alkosh")
    result = ReplaceText(result, "boethiah", "Boethiah")
    result = ReplaceText(result, "mephala", "Mephala")
    result = ReplaceText(result, "the hist", "The Hist")
    result = ReplaceText(result, "sithis", "Sithis")
    result = ReplaceText(result, "malacath", "Malacath")
    result = ReplaceText(result, "trinimac", "Trinimac")
    result = ReplaceText(result, "tu'whacca", "Tu'whacca")
    result = ReplaceText(result, "hoonding", "HoonDing")
    result = ReplaceText(result, "leki", "Leki")
    result = ReplaceText(result, "shor", "Shor")
    result = ReplaceText(result, "tsun", "Tsun")
    result = ReplaceText(result, "stuhn", "Stuhn")
    result = ReplaceText(result, "mehrunes dagon", "Mehrunes Dagon")
    result = ReplaceText(result, "molag bal", "Molag Bal")
    result = ReplaceText(result, "sheogorath", "Sheogorath")
    result = ReplaceText(result, "clavicus vile", "Clavicus Vile")
    result = ReplaceText(result, "hermaeus mora", "Hermaeus Mora")
    result = ReplaceText(result, "meridia", "Meridia")
    result = ReplaceText(result, "vaermina", "Vaermina")
    result = ReplaceText(result, "namira", "Namira")
    result = ReplaceText(result, "sanguine", "Sanguine")
    result = ReplaceText(result, "nocturnal", "Nocturnal")
    result = ReplaceText(result, "peryite", "Peryite")
    return result
EndFunction

String Function ReplaceText(String sourceText, String needleText, String replacementText)
    Int sourceLength = StringUtil.GetLength(sourceText)
    Int needleLength = StringUtil.GetLength(needleText)
    if sourceLength <= 0 || needleLength <= 0 || sourceLength < needleLength
        return sourceText
    endIf

    String result = ""
    Int sourceIndex = 0
    Int lastStart = sourceLength - needleLength
    while sourceIndex < sourceLength
        Bool matched = False
        if sourceIndex <= lastStart
            matched = StringMatchesAt(sourceText, needleText, sourceIndex)
        endIf

        if matched
            result = result + replacementText
            sourceIndex = sourceIndex + needleLength
        else
            result = result + StringUtil.GetNthChar(sourceText, sourceIndex)
            sourceIndex = sourceIndex + 1
        endIf
    endWhile

    return result
EndFunction

Bool Function StringMatchesAt(String sourceText, String needleText, Int startIndex)
    Int needleLength = StringUtil.GetLength(needleText)
    Int needleIndex = 0
    while needleIndex < needleLength
        if StringUtil.GetNthChar(sourceText, startIndex + needleIndex) != StringUtil.GetNthChar(needleText, needleIndex)
            return False
        endIf
        needleIndex += 1
    endWhile

    return True
EndFunction

; Day-window prune: unpinned entries older than the window are removed; pinned
; (headline) entries are exempt until the hard ceiling. Iterates backwards so a
; removal never shifts a not-yet-visited index. The 5 parallel lists stay
; index-aligned via RemoveBookOfDaysEntryAt.
Function PruneBookOfDays()
    Int windowDays = 21
    Int hardCeiling = 60
    Int now = Utility.GetCurrentGameTime() as Int

    Int i = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines") - 1
    while i >= 0
        Int entryDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        Int pinned = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Pinned", i)
        if pinned == 0 && (now - entryDay) >= windowDays
            RemoveBookOfDaysEntryAt(i)
        endIf
        i -= 1
    endWhile

    ; Hard ceiling backstop (includes pinned): drop oldest until within the cap.
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines") > hardCeiling
        RemoveBookOfDaysEntryAt(0)
    endWhile
EndFunction

; Remove one entry across all Book of Days lists at the same index.
Function RemoveBookOfDaysEntryAt(Int index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Lines", index)
    StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Days", index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Tones", index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Symbols", index)
    StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Pinned", index)
    if index < StorageUtil.IntListCount(None, "PDV.Diegetic.Journal.Magnitudes")
        StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Magnitudes", index)
    endIf
    if index < StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
        StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Titles", index)
    endIf
EndFunction

String Function GetJournalByline()
    PDV_DaedricPathBase pact = GetActiveDaedricPactPath()
    if pact
        return "kept by the terms of the pact"
    endIf
    if _activeDeity
        return "kept for " + GetPublicDeityDisplayName(_activeDeity)
    endIf
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_KHAJIIT
        return "kept beneath the moons"
    elseIf originRace == ORIGIN_ARGONIAN
        return "kept within the Hist"
    elseIf originRace == ORIGIN_DUNMER
        return "kept among the ancestors"
    endIf
    return "a record kept since the path began"
EndFunction

String Function BuildJournalEventTitle(String toneKey, String fallbackTitle)
    if fallbackTitle != ""
        return fallbackTitle
    endIf
    return JournalToneToTitle(toneKey)
EndFunction

Int Function GetJournalMagnitudeForTone(String toneKey)
    if toneKey == "tier.reach"
        return 3
    endIf
    if toneKey == "curse.onset" || toneKey == "curse.cure"
        return 3
    endIf
    if toneKey == "reorientation"
        return 3
    endIf
    if toneKey == "offer.accept" || toneKey == "offer.refuse"
        return 3
    endIf
    if toneKey == "neglect.drop" || toneKey == "neglect.recover"
        return 2
    endIf
    if toneKey == "creed.drop"
        return 2
    endIf
    if toneKey == "dawn.digest"
        return 2
    endIf
    return 1
EndFunction

Function RefreshOpenBookOfDays()
    Int bookOpen = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Open")
    if bookOpen == 0 || !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    if !PDV_PrismaBridge.IsJournalVisible()
        StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    endIf
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
    if toneKey == "creed.drop"
        return "Creed broken"
    endIf
    if toneKey == "emergence.onset"
        return "An emergence"
    endIf
    if toneKey == "offer.accept"
        return "Patron accepted"
    endIf
    if toneKey == "offer.refuse"
        return "Offer refused"
    endIf
    if toneKey == "substrate.act"
        return "An act of devotion"
    endIf
    if toneKey == "favor.act"
        return "Prayer answered"
    endIf
    if toneKey == "favor.loss"
        return "A deed ill-received"
    endIf
    if toneKey == "reorientation"
        return "A turning"
    endIf
    if toneKey == "dawn.digest"
        return "The day's reckoning"
    endIf
    if toneKey == "daedric.pressure"
        return "A Prince watches"
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
    if toneKey == "offer.accept"
        return "good"
    endIf
    if toneKey == "substrate.act"
        return "good"
    endIf
    if toneKey == "favor.act"
        return "good"
    endIf
    if toneKey == "favor.loss"
        return "warning"
    endIf
    if toneKey == "curse.onset"
        return "warning"
    endIf
    if toneKey == "neglect.drop"
        return "warning"
    endIf
    if toneKey == "creed.drop"
        return "warning"
    endIf
    if toneKey == "daedric.pressure"
        return "warning"
    endIf
    if toneKey == "offer.refuse"
        return "warning"
    endIf
    if toneKey == "reorientation"
        return "neutral"
    endIf
    if toneKey == "dawn.digest"
        return "neutral"
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
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson("{\"journalClose\":true}")
EndFunction

Bool Function SelectMedallionEntry(String optionId)
    Trace(1, "Medallion selection blocked for " + optionId + "; roster display is offer-only.")
    return False
EndFunction

Bool Function CanSelectMedallionEntry(String optionId)
    return False
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
    String entries = RosterMedallionEntry("kyne", "Kyne", "god", "kyne", PDV_Kyne, "Sky, storm, hunt, and warrior-spirit.")
    entries = entries + "," + RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", PDV_Kynareth, "The Nine Divines sky road.")
    entries = entries + "," + RosterMedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, "Open defiance and human apotheosis.")
    entries = entries + "," + RosterMedallionEntry("shor", "Shor", "god", "shor", PDV_Shor, "The old king and afterlife road.")
    entries = entries + "," + RosterMedallionEntry("tsun", "Tsun", "god", "tsun", PDV_Tsun, "Trial, honor, and the threshold.")
    entries = entries + "," + RosterMedallionEntry("stuhn", "Stuhn", "god", "stuhn", PDV_Stuhn, "Mercy in war and fair ransom.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", PDV_Mara, "Love, hearth, and compassion.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", PDV_Akatosh, "Time, order, and dragon authority.")
    String arkayRosterName = "Arkay"
    if UsesNordOldWaysDeityNames()
        arkayRosterName = "Orkey"
    endIf
    entries = entries + "," + RosterMedallionEntry("arkay", arkayRosterName, "god", "arkay", PDV_Arkay, "Death, burial, and proper passage.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", PDV_Stendarr, "Mercy, justice, and protection.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", PDV_Julianos, "Law, learning, and craft of mind.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", PDV_Dibella, "Beauty, art, and embodied grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", PDV_Zenithar, "Work, trade, and honest craft.")
    return entries
EndFunction

String Function GetImperialMedallionEntriesJson()
    String entries = RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", PDV_Kynareth, "Road, wind, and natural order.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", PDV_Mara, "Love, family, and mercy.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", PDV_Akatosh, "Time, covenant, and empire.")
    entries = entries + "," + RosterMedallionEntry("arkay", "Arkay", "god", "arkay", PDV_Arkay, "Life, death, and lawful burial.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", PDV_Stendarr, "Mercy, protection, and civic virtue.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", PDV_Julianos, "Law, learning, and reason.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", PDV_Dibella, "Art, beauty, and human grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", PDV_Zenithar, "Work, trade, and prosperity.")
    return entries
EndFunction

String Function GetBretonMedallionEntriesJson()
    String entries = RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", PDV_Kynareth, "Sky, travel, and druidic memory.")
    entries = entries + "," + RosterMedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, "Civic defiance and Septim inheritance.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", PDV_Mara, "Household, mercy, and love.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", PDV_Akatosh, "Time, order, and covenant.")
    entries = entries + "," + RosterMedallionEntry("arkay", "Arkay", "god", "arkay", PDV_Arkay, "Death, burial, and clean endings.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", PDV_Stendarr, "Mercy, protection, and oath.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", PDV_Julianos, "Learning, law, and formal craft.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", PDV_Dibella, "Beauty, courtliness, and grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", PDV_Zenithar, "Trade, craft, and honest work.")
    entries = entries + "," + RosterMedallionEntry("magnus", "Magnus", "god", "magnus", PDV_Magnus, "Magic, light, and hidden inheritance.")
    entries = entries + "," + PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Pilgrimage, endurance, and Elven memory.")
    entries = entries + "," + RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, "Green memory, story, and law.")
    return entries
EndFunction

String Function GetAltmerMedallionEntriesJson()
    String entries = RosterMedallionEntry("mara", "Mara", "god", "mara", PDV_Mara, "Kinship, care, and ordered mercy.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", PDV_Stendarr, "Mercy and lawful protection.")
    entries = entries + "," + RosterMedallionEntry("magnus", "Magnus", "god", "magnus", PDV_Magnus, "Light, magic, and origin memory.")
    entries = entries + "," + PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Endurance, pilgrimage, and old discipline.")
    entries = entries + "," + RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, "Story, form, and natural law.")
    entries = entries + "," + RosterMedallionEntry("auri-el", "Auri-El", "god", "auri-el", PDV_AuriEl, "The founding light and ancestral ascent.")
    entries = entries + "," + RosterMedallionEntry("syrabane", "Syrabane", "god", "syrabane", PDV_Syrabane, "Protection, apprentices, and survival through wisdom.")
    entries = entries + "," + RosterMedallionEntry("xarxes", "Xarxes", "god", "xarxes", PDV_Xarxes, "Lineage, record, and ordered memory.")
    entries = entries + "," + RosterMedallionEntry("trinimac", "Trinimac", "god", "trinimac", PDV_Trinimac, "Warrior order and unbroken nobility.")
    return entries
EndFunction

String Function GetBosmerNativeMedallionEntriesJson()
    String entries = RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, "The Green, story, and the Old Contract.")
    entries = entries + "," + RosterMedallionEntry("auri-el", "Auri-El", "god", "auri-el", PDV_AuriEl, "Elven ancestry and high memory.")
    entries = entries + "," + RosterMedallionEntry("xarxes", "Xarxes", "god", "xarxes", PDV_Xarxes, "Record, lineage, and written memory.")
    entries = entries + "," + RosterMedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", PDV_BaanDar, "Trickster road, masks, and survival.")
    return entries
EndFunction

String Function GetBosmerFocusMedallionEntriesJson()
    return RosterMedallionEntry("zen", "Z'en", "god", "zen", PDV_Zen, "Debt, toil, exchange, and obligation.")
EndFunction

String Function GetDunmerMedallionEntriesJson()
    String entries = RosterMedallionEntry("azura", "Azura", "prince", "azura", PDV_Azura, "Dawn, dusk, prophecy, and fate.")
    entries = entries + "," + RosterMedallionEntry("boethiah", "Boethiah", "prince", "boethiah", PDV_Boethiah, "Trial, overthrow, and hard becoming.")
    entries = entries + "," + RosterMedallionEntry("mephala", "Mephala", "prince", "mephala", PDV_Mephala, "Web, secrecy, clan, and hidden duty.")
    return entries
EndFunction

String Function GetKhajiitMedallionEntriesJson()
    String entries = RosterMedallionEntry("azura", "Azurah", "prince", "azura", PDV_Azura, "Dusk, dawn, moon-shadow, and fate.")
    entries = entries + "," + RosterMedallionEntry("boethiah", "Boethra", "prince", "boethiah", PDV_Boethiah, "Trial, edge, and hard lessons.")
    entries = entries + "," + RosterMedallionEntry("mephala", "Mafala", "prince", "mephala", PDV_Mephala, "Hidden paths, webs, and clan memory.")
    entries = entries + "," + RosterMedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", PDV_BaanDar, "The bandit god, wit, and road survival.")
    entries = entries + "," + RosterMedallionEntry("rajhin", "Rajhin", "god", "rajhin", PDV_Rajhin, "The clever thief and impossible escape.")
    entries = entries + "," + RosterMedallionEntry("alkosh", "Alkosh", "god", "alkosh", PDV_Alkosh, "Dragon order and time in Khajiit memory.")
    entries = entries + "," + RosterMedallionEntry("khenarthi", "Khenarthi", "god", "khenarthi", PDV_Khenarthi, "Wind, sky-road, and breath.")
    entries = entries + "," + PendingMedallionEntry("riddle-thar", "Riddle'Thar", "god", "riddle-thar", "Balance, ja-Kha'jay, and right conduct.")
    entries = entries + "," + PendingMedallionEntry("jone-jode", "Jone and Jode", "god", "lunar", "The moons, the lattice, and the road home.")
    return entries
EndFunction

String Function GetArgonianMedallionEntriesJson()
    String entries = RosterMedallionEntry("hist", "The Hist", "substrate", "hist", PDV_Hist, "Root, memory, people, and sap.")
    entries = entries + "," + RosterMedallionEntry("sithis", "Sithis", "god", "sithis", PDV_Sithis, "Void, change, and dangerous silence.")
    return entries
EndFunction

String Function GetOrcMedallionEntriesJson()
    return RosterMedallionEntry("malacath", "Malacath", "prince", "malacath", PDV_Malacath, "Oath, code, exile, and vengeance.")
EndFunction

String Function GetRedguardMedallionEntriesJson()
    String entries = PendingMedallionEntry("satakal", "Satakal", "god", "satakal", "Worldskin, cycle, and cosmic turning.")
    entries = entries + "," + PendingMedallionEntry("ruptga", "Ruptga", "god", "ruptga", "Tall Papa, ancestry, and guidance.")
    entries = entries + "," + RosterMedallionEntry("tuwhacca", "Tu'whacca", "god", "tu-whacca", PDV_Tuwhacca, "Death, passage, and the proper road.")
    entries = entries + "," + PendingMedallionEntry("tava", "Tava", "god", "tava", "Wind, sailors, and safe passage.")
    entries = entries + "," + RosterMedallionEntry("leki", "Leki", "god", "leki", PDV_Leki, "Sword-skill, discipline, and grace.")
    entries = entries + "," + PendingMedallionEntry("onsi", "Onsi", "god", "onsi", "The blade, craft, and warrior making.")
    entries = entries + "," + RosterMedallionEntry("hoon-ding", "HoonDing", "god", "hoon-ding", PDV_HoonDing, "Make-way spirit and impossible survival.")
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

; Roster-display entry for a LIVE native patron: shows the god as real and worshippable, but NOT
; directly selectable -- commitment happens through the organic offer, not a medallion pick (owner
; ruling 2026-06-27: medallion is a roster display, the offer is the commit path). Falls back to the
; pending "awaiting a record" message only when the deity record is not actually live.
String Function RosterMedallionEntry(String optionId, String titleText, String kindText, String symbolName, PDV_DeityBase deity, String summaryText)
    if deity && IsMedallionDeitySelectable(deity)
        String liveDesc = titleText + " is a living patron your people can name."
        String liveHint = "Build devotion and this god offers to take you as their own."
        return MedallionEntry(optionId, titleText, kindText, symbolName, deity, False, summaryText, liveDesc, liveHint)
    endIf
    return PendingMedallionEntry(optionId, titleText, kindText, symbolName, summaryText)
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
    elseIf optionId == "kynareth"
        return PDV_Kynareth
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
    elseIf deity == PDV_Kynareth
        return "kynareth"
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
    elseIf optionId == "kynareth"
        return originRace == ORIGIN_NORD || originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_BRETON
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

    BeginRaceSetupQuietPresentation(reason)
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
    AppendBookOfDaysEntry(BuildStartupRoadJournalLine(GetBosmerPathLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", GetBosmerPathSymbol(pathState), True, 3, "", True)
    EndRaceSetupQuietPresentation()
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
    SurfaceTransition("reorientation", GetBosmerPathLabel(), "shift", deity.DeityIndex, "turning")
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
    AppendBookOfDaysEntry("Y'ffre's song settles within you. Your road through the Green is the " + GetBosmerPathLabel() + ".", Utility.GetCurrentGameTime() as Int, "reorientation", GetPrismaSymbolForDeity(_activeDeity), False, 3)
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
    ; V1: grant the usable MISC urn (PDV_MISC_DunmerAncestralUrn); clicking it in the inventory
    ; fires OnEquipped and routes the ancestor prayer. The retired model-less BOOK token crashed
    ; the book menu on read, so migration removes any copies before granting the MISC urn.
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_MISC_DunmerAncestralUrn
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if PDV_BOOK_DunmerAncestralUrn
        int staleBookCount = playerRef.GetItemCount(PDV_BOOK_DunmerAncestralUrn)
        if staleBookCount > 0
            playerRef.RemoveItem(PDV_BOOK_DunmerAncestralUrn, staleBookCount, True)
            Trace(2, "Dunmer ancestral urn book token retired.")
        endIf
    endIf

    if playerRef.GetItemCount(PDV_MISC_DunmerAncestralUrn) <= 0
        playerRef.AddItem(PDV_MISC_DunmerAncestralUrn, 1, True)
        Trace(2, "Dunmer ancestral urn granted.")
    endIf
EndFunction

Function EnsureArgonianHistSapToken()
    ; V1: grant the self-replenishing Hist Sap POTION (PDV_ALCH_ArgonianHistSap) rather than the old read
    ; BOOK. Drinking it routes Hist maintenance (see PDV_PotionArgonianHistSapEffect) and re-adds itself, so
    ; the player keeps one ritual vial. The book property stays declared but is no longer granted.
    if GetPlayerOriginRaceIndex() != ORIGIN_ARGONIAN || !PDV_ALCH_ArgonianHistSap
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(PDV_ALCH_ArgonianHistSap) <= 0
        playerRef.AddItem(PDV_ALCH_ArgonianHistSap, 1, True)
        StorageUtil.SetIntValue(None, "PDV.Token.ArgonianHistSap.Granted", 1)
        Trace(2, "Argonian Hist sap potion granted.")
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

    ; Prince-wins: an active Daedric pact is the single commitment, surfaced for ALL
    ; races (exclusivity means the patron is severed, so this never co-renders). The
    ; tier>0 guard inside GetActiveDaedricPactPath prevents a stale-pointer ghost pact.
    PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
    if pactPath
        return AppendRecentDevotionEvents(GetDaedricSurveyText(pactPath))
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

    ; Prince-wins: an active pact is the single commitment (patron severed under
    ; exclusivity), surfaced for all races.
    PDV_DaedricPathBase summaryPact = GetActiveDaedricPactPath()
    if summaryPact
        return NormalizePublicDeityDisplayText(summaryPact.DeityName) + " | Pact | " + GetCurrentStandingLabel()
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
    ; An active Prince pact is the single commitment (patron severed under exclusivity);
    ; surface it here so the Prisma panel "patron" field matches the Survey.
    PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
    if pactPath
        return NormalizePublicDeityDisplayText(pactPath.DeityName)
    endIf

    if _activeDeity
        return GetPublicDeityDisplayName(_activeDeity)
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
        if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
            return "Choose a starting path, then confirm."
        endIf
        return "Set: " + GetPlayerMcmModeLine()
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction

String Function GetPlayerMcmCurseLine()
    ; The Anvil MCM font renders a bare "None" value as effectively blank, so map
    ; the no-curse state to an explicit phrase. Surgical to the MCM display only;
    ; GetPlayerCursePublicLabel keeps returning "None" for its other callers.
    String curseLabel = GetPlayerCursePublicLabel()
    if curseLabel == "None"
        return "No curse"
    endIf
    return curseLabel
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

    ; "No neglect" not bare "None": the Anvil MCM font renders a lone "None" blank.
    return "No neglect"
EndFunction

String Function GetNordSurveyBaseText()
    String band = GetCurrentStandingBand()
    if IsNordVampireSuppressed()
        return "Standing: " + band + ". Sovngarde is closed while the thirst remains. Cure the curse to reopen the road."
    endIf

    String contextText = GetNordContextSurveyText()
    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        String focusedText = "Standing: " + band + ". " + GetPublicDeityDisplayName(_activeDeity) + " names you."
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if GetPatronState() == PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == NORD_BASELINE_NINE_DIVINES
            return "Standing: " + band + ". You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath." + contextText
        endIf

        return "Standing: " + band + ". You honor the Old Ways broadly." + contextText
    endIf

    if PDV_HircinePath
        String hircineSummary = PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "Standing: " + band + ". The hunt pulls at the edge of the Old Ways. No patron has claimed you, but the beast is listening." + contextText
        endIf
    endIf

    return "Standing: " + band + ". No Nord patron has answered yet. Keep the rites, and the road will grow clearer." + contextText
EndFunction

String Function GetNordContextSurveyText()
    String text = ""
    Int oldWaysCount = StorageUtil.GetIntValue(None, "PDV.Nord.OldWaysContextCount")
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if oldWaysCount > 0
        text = text + " Recent acts confirm the old road."
    endIf
    if kyneTalosCount > 0
        text = text + " Kyne and Talos weigh on your road."
    endIf
    if edgeCount > 0
        text = text + " Hunt and death-duty are present, but remain edge pressures."
    endIf
    if PDV_NordAncestorSubstrate
        text = text + " The ancestor-line remains " + GetNordAncestorLayerLabel() + "."
    endIf
    return text
EndFunction

String Function GetNordAncestorLayerLabel()
    if !PDV_NordAncestorSubstrate
        return "quiet"
    endIf

    return PDV_NordAncestorSubstrate.GetAncestorPostureLabel()
EndFunction

String Function GetNordDevotionModeLabel()
    if IsNordVampireSuppressed()
        return "Vampire rupture"
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity
        return "Focused " + GetPublicDeityDisplayName(_activeDeity)
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
    PDV_DaedricPathBase standingPact = GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = GetTier(_activeDeity)
    elseIf GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > TIER_NONE
        tierValue = GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
    elseIf PDV_GLO_ActiveTier
        tierValue = PDV_GLO_ActiveTier.GetValueInt()
    endIf

    if !_activeDeity && !standingPact && GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > TIER_NONE
        return GetBroadLaneStandingLabel(GetPlayerOriginRaceIndex(), tierValue)
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
    PDV_DaedricPathBase standingPact = GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = GetTier(_activeDeity)
    elseIf GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > TIER_NONE
        tierValue = GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
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

    if PDV_AltmerAncestorSubstrate
        text = text + " Your Aldmeri heritage is " + GetAltmerHeritageLayerLabel() + "."
    endIf

    return text
EndFunction

String Function GetAltmerHeritageLayerLabel()
    if !PDV_AltmerAncestorSubstrate
        return "quiet"
    endIf

    return PDV_AltmerAncestorSubstrate.GetHeritagePostureLabel()
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
        String ashText = "You keep the Ash'abah duty: the unclean dead are your charge. Standing: " + standing + ". Tu'whacca honors the burden few will."
        Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
        if stigma >= 3
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the clean turn their faces, and the living keep their distance from the death-handler."
        elseIf stigma >= 1
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the mark of the duty is on you, and the squeamish step wide."
        endIf
        return ashText
    endIf

    return "You keep the Forebear way: Redguard identity lived among outsiders. Standing: " + standing + ". The road and the contract are your proving ground."
EndFunction

String Function GetBretonSurveyText()
    String band = GetCurrentStandingBand()
    Int tradition = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if tradition < 0
        String unchosenText = "You have not yet chosen a tradition. Breton faith takes its shape once you walk the Knight's Road, the Hidden Art, or the Green Way. Standing: " + band + "."
        return unchosenText
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
        if exposure >= 100
            text = text + " Your practice is notorious, openly named, and your patron rewards the full commitment."
        elseIf exposure >= 75
            text = text + " Your practice is known, and your cover is close to rupture."
        elseIf exposure >= 50
            text = text + " Your practice is known, and the Vigilants are a real danger now."
        elseIf exposure >= 25
            text = text + " Your practice is suspected, and watchful eyes have begun to turn."
        else
            text = text + " Your practice stays hidden, unseen by those who would object."
        endIf
    else
        text = "You walk the Green Way: the old druidic covenant. Standing: " + band + "."
        Int druidic = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        if druidic >= 70
            text = text + " The druidic covenant is acknowledged, and Y'ffre answers you steadily."
        elseIf druidic < 30
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
    if exposureValue >= 100
        return "notorious"
    elseIf exposureValue >= 50
        return "known"
    elseIf exposureValue >= 25
        return "suspected"
    endIf

    return "hidden"
EndFunction

String Function GetBretonDruidicStandingLabel()
    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    if standingValue >= 70
        return "acknowledged"
    elseIf standingValue < 30
        return "frayed"
    endIf

    return "open"
EndFunction

String Function GetBretonAncestorLayerLabel()
    if !PDV_BretonAncestorSubstrate
        return "retired"
    endIf

    return "retired"
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
        text = GetPublicDeityDisplayName(_activeDeity) + " holds your focus among the Nine. Standing: " + band + ". " + BuildImperialConcordatSurveySentence(concordat)
    else
        text = "You worship the Nine Divines broadly, and your standing is " + band + ". " + BuildImperialConcordatSurveySentence(concordat)
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
    if PDV_ImperialAncestorSubstrate
        text = text + " Your civic inheritance is " + GetImperialCivicLayerLabel() + "."
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
        return FormatImperialConcordatLabel(PDV_ConcordatStandingTrack.GetStateLabel())
    endIf

    return "Uncommitted"
EndFunction

String Function FormatImperialConcordatLabel(String label)
    if label == "OpenDefiant"
        return "Openly Defiant"
    elseIf label == "PrivateDefiant"
        return "Privately Defiant"
    elseIf label == "PublicCompliant"
        return "Publicly Compliant"
    elseIf label == "ConcordatEnforcer"
        return "Concordat Enforcer"
    endIf

    return label
EndFunction

String Function BuildImperialConcordatSurveySentence(String concordatLabel)
    if concordatLabel == "Concordat Enforcer"
        return "Under the Concordat, you are a Concordat Enforcer."
    endIf

    return "Under the Concordat, you are " + concordatLabel + "."
EndFunction

String Function GetImperialCivicLayerLabel()
    if !PDV_ImperialAncestorSubstrate
        return "quiet"
    endIf

    return PDV_ImperialAncestorSubstrate.GetCivicPostureLabel()
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

String Function GetNordAncestorSummary()
    if !PDV_NordAncestorSubstrate
        return "missing"
    endIf

    return PDV_NordAncestorSubstrate.GetPilotSummary()
EndFunction

String Function GetBretonAncestorSummary()
    if !PDV_BretonAncestorSubstrate
        return "retired"
    endIf

    return "retired"
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
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(pending, 7) + ";offered=" + BoolToInt(IsCommitmentOffered(pending)) + ";refused=" + BoolToInt(IsCommitmentRefused(pending))
    elseIf PDV_Kyne
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(PDV_Kyne, 7) + ";offered=" + BoolToInt(IsCommitmentOffered(PDV_Kyne)) + ";refused=" + BoolToInt(IsCommitmentRefused(PDV_Kyne))
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

Bool Function ConsumeOncePerDaySignal(String keyPrefix)
    Int currentDay = Utility.GetCurrentGameTime() as Int
    String dayKey = keyPrefix + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, -1) == currentDay
        StorageUtil.AdjustIntValue(None, keyPrefix + ".RejectCount", 1)
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDay)
    return True
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
                AwardPietyInternal(rivalDeity, rivalAmount, False, "rivalry with " + sourceDeity.DeityName)

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

    if PDV_Kynareth && PDV_Kynareth.DeityIndex == deityIndex
        return PDV_Kynareth
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
    if deity.DeityName == "Syrabane"
        return "syrabane"
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
