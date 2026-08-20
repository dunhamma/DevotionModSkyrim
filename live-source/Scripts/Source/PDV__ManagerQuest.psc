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

GlobalVariable Property PDV_GLO_OriginRace Auto
GlobalVariable Property PDV_GLO_KhajiitFocusedEmphasis Auto
GlobalVariable Property PDV_GLO_State_BretonDruidicFork Auto

FormList Property PDV_FLST_DaedricPaths_All Auto
FormList Property PDV_FLST_HoonDing_BreakthroughBosses Auto
FormList Property PDV_FLST_RedguardAshAbahUndeadClearSites Auto
FormList Property PDV_FLST_UndeadCryptClearSites Auto
FormList Property PDV_FLST_KhajiitMoonContemplations Auto
String Property QUEST_REACTION_MATRIX_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionCore.v2" AutoReadOnly
PDV_QuestReactionRuntime Property PDV_QuestReactionRuntimeService Auto

PDV_Deity_Kyne Property PDV_Kyne Auto
PDV_Deity_Talos Property PDV_Talos Auto
PDV_Deity_Yffre Property PDV_Yffre Auto
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
; Altmer offer patrons.
PDV_Deity_AuriEl Property PDV_AuriEl Auto
PDV_Deity_Magnus Property PDV_Magnus Auto
PDV_Deity_Xarxes Property PDV_Xarxes Auto
; P9 (2026-08-03): narrowed from PDV_DeityBase to the concrete type, matching every sibling
; (PDV_Deity_Magnus/Xarxes/Trinimac/AuriEl). Required so his signal constants are referable, and
; required by tools/pdv_signal_e2e_gate.mjs: its dispatch-coverage regex only recognises an award
; whose second argument is the deity PROPERTY itself followed by the constant. Assigning the deity
; to a local variable first compiles fine but reads as UNDISPATCHED to that gate.
; The property name and its bound object are unchanged.
;
; Do NOT write an illustrative deity-dot-constant example in any comment in this file -- the
; curated-signal PARITY scanner treats such text as a real reference and then fails looking for a
; deity script that does not exist. That is what happened when this note was first written.
PDV_Deity_Syrabane Property PDV_Syrabane Auto
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
; P14 (2026-08-04). MUST be bound in the ESP or the focus is never granted and the whole lane is dead.
MiscObject Property PDV_MISC_AltmerPracticeFocus Auto
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
Spell Property PDV_Power_Khajiit_ObserveMoons Auto
Spell Property PDV_SPEL_Neglect_Kyne Auto
; Per-patron Nord neglect (follow-on): one gentle flat neglect spell per focusable non-Kyne Nord
; patron. None until the ESP batch authors them; SyncNordPatronNeglectSpells no-ops until then.
Spell Property PDV_SPEL_Neglect_Shor Auto
Spell Property PDV_SPEL_Neglect_Tsun Auto
Spell Property PDV_SPEL_Neglect_Stuhn Auto
Spell Property PDV_SPEL_Neglect_Talos Auto
; Nord Old Ways patrons added after the per-patron batch (Orkey/Dibella roster). Arkay's neglect
; surfaces as "Orkey" in Old Ways context; the property/record key stays Arkay.
Spell Property PDV_SPEL_Disfavor_MoonLuckShadow_Light Auto
Spell Property PDV_SPEL_Disfavor_MoonLuckShadow_Sharp Auto
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
Spell Property PDV_Bless_Breton_PatronChampion Auto ; retired 2026-07-13 (unified champion model); property kept declared+None for save-compat, no longer granted
; Unified patron-champion boons (2026-07-13): the active Champion patron brings
; their own signature boon regardless of tradition resonance. Stendarr reuses
; KnightsRoad_T3, Y'ffre reuses GreenWay_T3, a Daedric Hidden Art patron reuses
; HiddenArt_T3; the nine below are Breton copies of each deity's canonical T3.
Spell Property PDV_Bless_Breton_Champion_Mara Auto
Spell Property PDV_Bless_Breton_Champion_Arkay Auto
Spell Property PDV_Bless_Breton_Champion_Akatosh Auto
Spell Property PDV_Bless_Breton_Champion_Julianos Auto
Spell Property PDV_Bless_Breton_Champion_Kynareth Auto
Spell Property PDV_Bless_Breton_Champion_Dibella Auto
Spell Property PDV_Bless_Breton_Champion_Zenithar Auto
Spell Property PDV_Bless_Breton_Champion_Talos Auto
Spell Property PDV_Bless_Breton_Champion_Magnus Auto
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
; Retired rotating phase-stat spells. Properties remain only for save/FormID
; compatibility so reconciliation can remove stale instances.
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
Perk Property PDV_PERK_Khajiit_LatticeResonance Auto
Spell Property PDV_SPEL_Khajiit_LatticeResonanceMarker Auto
Spell Property PDV_Power_Khajiit_AzurahPortent Auto
Spell Property PDV_SPEL_Khajiit_AzurahPortentDetect Auto
Sound Property PDV_SND_Khajiit_AzurahPortentFizzle Auto
Message Property PDV_MSG_KhajiitFocus_Khenarthi Auto
Message Property PDV_MSG_KhajiitFocus_Azurah Auto
Message Property PDV_MSG_KhajiitFocus_BaanDar Auto
Message Property PDV_MSG_KhajiitFocus_Rajhin Auto
Message Property PDV_MSG_KhajiitFocus_Alkosh Auto
Spell Property PDV_SPEL_Neglect_KhajiitLunar Auto
Spell Property PDV_Bless_Nord_OldWays_T1 Auto
Spell Property PDV_Bless_Nord_OldWays_T2 Auto
Spell Property PDV_Bless_Nord_NineDivines_T1 Auto
Spell Property PDV_Bless_Nord_NineDivines_T2 Auto
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
; CUT (1.0.3): the 21 PDV_Bless_Nord_<god> properties for the seven Divines that
; route through the Imperial spells (Akatosh, Mara, Stendarr, Zenithar, Dibella,
; Julianos, Kynareth). Verified against the ESP: those spell records DO NOT EXIST --
; the properties pointed at nothing, and their only reader was the uninstall strip.
; Kyne/Shor/Tsun/Stuhn/Talos/Arkay/OldWays/NineDivines are live and kept.
Spell Property PDV_Bless_Nord_Arkay_T1 Auto
Spell Property PDV_Bless_Nord_Arkay_T2 Auto
Spell Property PDV_Bless_Nord_Arkay_T3 Auto
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
; P11 (2026-08-04): the Altmer ambient records. Two Champion variants per deity plus the two
; deity-agnostic heritage lines. Every one of these MUST be bound in the CK -- an unbound
; Message property is not a compile error and not a runtime error either; ShowAltmerNotification
; quietly falls back to a Prisma toast, so a missed binding looks like working software.
Message Property PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn Auto
Message Property PDV_Notif_Altmer_AuriEl_ChampionAmbient_Return Auto
Message Property PDV_Notif_Altmer_Magnus_ChampionAmbient_Study Auto
Message Property PDV_Notif_Altmer_Magnus_ChampionAmbient_ElderWay Auto
Message Property PDV_Notif_Altmer_Xarxes_ChampionAmbient_Record Auto
Message Property PDV_Notif_Altmer_Xarxes_ChampionAmbient_Lineage Auto
Message Property PDV_Notif_Altmer_Trinimac_ChampionAmbient_Watch Auto
Message Property PDV_Notif_Altmer_Trinimac_ChampionAmbient_Sword Auto
Message Property PDV_Notif_Altmer_Syrabane_ChampionAmbient_Ward Auto
Message Property PDV_Notif_Altmer_Syrabane_ChampionAmbient_Guard Auto
Message Property PDV_Notif_Altmer_General_HeritageExemplar Auto
Message Property PDV_Notif_Altmer_General_HeritageQuiet Auto
; The calian's two refusal surfaces. Before these the token was silent on both -- a player who
; clicked it twice in a day, or clicked it while cursed, got no answer at all and could not tell a
; working item from a broken one.
Message Property PDV_Notif_Altmer_Calian_AlreadyKept Auto
Message Property PDV_Notif_Altmer_Calian_Unanswered Auto
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
Message Property PDV_Msg_Breton_Talos_Offer Auto
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


; P11: devotional days between recurring ambient lines, per surfacing deity and for the
; heritage band. Four is deliberately slow -- this layer exists so a long-held Champion is not
; met with silence, not to fill the notification area.
Int Property AMBIENT_CHAMPION_CADENCE_DAYS = 4 AutoReadOnly

; Human-facing release stamp for the MCM Version readout and bug-report export.
; Bump on every public build so an attached report is orderable by build.
String Property PDV_BUILD_VERSION = "2.0.0-dev" AutoReadOnly

Int Property FRAMEWORK_SCHEMA_VERSION = 3 AutoReadOnly

; Bump when PDV_DeityLikesDislikes.csv OR the stance matrix changes so existing saves reload.
; Bumped 16 -> 17 (1.0.3): the Azura CSV-actor fix needs every existing save to reload
; its likes/dislikes rows and stance matrix, and that same rebuild is what builds and
; seals every deity's participating-event cache (12.4 / C4 in PDV_DeityBase) -- without
; it the caches stay unsealed forever on old saves (correct, they fail open, but the
; broadcast fan-out keeps paying the full per-deity probe the cache exists to remove).
Int Property PRINCE_LD_VERSION = 6 AutoReadOnly
; Bump when the Daedric pact model changes so existing saves re-run the migration
; (v2: active-pact-only sync + milestone presentation refresh; v3: collapse a
; co-held patron+Prince, keep higher tier, tie -> Prince).
Int Property DAEDRIC_PACT_VERSION = 3 AutoReadOnly
; Separate schema key from PDV.Daedric.PactVersion (owned by MigrateDaedricPactsIfNeeded).
; Bump when the consent-gate migration must re-run on existing saves.
Int Property DAEDRIC_CONSENT_SCHEMA_VERSION = 1 AutoReadOnly
; --- P10 (2026-08-03): Long Devotion, the post-Champion accrual layer -------------------------
; The ladder terminated flat at Champion (85) while PIETY_MAX is 200, so 115 points of headroom
; drove nothing, and MaybeShowChampionRewardPresentation is a hard one-shot -- a Champion who
; decayed out and re-climbed got total silence.
; Long Devotion is a DERIVED readout over the EXISTING 85..200 piety headroom. No new currency,
; no new decay, no new anti-farm doctrine, no new records. The alternative -- a parallel
; accumulator -- would need a second copy of the whole gain pipeline. Rejected.
; Marks grant NO SPELL in v1, deliberately: they are recognition plus a decay floor, so the
; accrual model can be judged before committing to a T4 reward family per race.
Float Property ORC_RATE_MULT_STRONGHOLD = 1.0 AutoReadOnly
Float Property ORC_RATE_MULT_CITY = 0.75 AutoReadOnly
Float Property ORC_RATE_MULT_LEGIONEXILE = 0.6 AutoReadOnly
; Recency-lapse grace (owner ruling 2026-06-27): neglect bites after this many days of no
; devotional act, regardless of piety -- the active patron is decay-shielded so the piety<=10
; floor almost never triggers from mere absence. Sits just past DECAY_GRACE_DAYS (2.0).

; Transient call-context guard: the home route is valid only as the second half
; of a portable prayer performed inside the declared Dunmer home.

Int Property BOSMER_PATH_OLD_CONTRACT = 0 AutoReadOnly
Int Property BOSMER_PATH_LIVING_STORY = 1 AutoReadOnly
Int Property BOSMER_PATH_EXCHANGE = 2 AutoReadOnly
Int Property BOSMER_PATH_BANDIT_ROAD = 3 AutoReadOnly
; Gain-provider phases (PDV_GainModifierProvider contract). Declared here because it is the
; one script every provider and the ledger can already reach.
Int Property PHASE_PER_EVENT = 0 AutoReadOnly
Int Property PHASE_AT_DAWN = 1 AutoReadOnly
Int Property PHASE_DECAY = 2 AutoReadOnly

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
Int Property BRETON_PRACTICE_SEEKER_POINTS = 25 AutoReadOnly
Int Property BRETON_PRACTICE_DEVOTED_POINTS = 50 AutoReadOnly
Int Property BRETON_PRACTICE_DAILY_MAX_POINTS = 4 AutoReadOnly
Int Property BRETON_PRACTICE_RENEWABLE_POINTS = 1 AutoReadOnly
Int Property BRETON_PRACTICE_CURATED_POINTS = 2 AutoReadOnly
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
Int Property ALTMER_CRISIS_NONE = 0 AutoReadOnly
Int Property ALTMER_CRISIS_DISSONANT = 1 AutoReadOnly
Int Property ALTMER_CRISIS_QUESTIONING = 2 AutoReadOnly
Int Property ALTMER_CRISIS_REASSERTING = 3 AutoReadOnly
Int Property ALTMER_CRISIS_SCARRED_RESOLVED = 4 AutoReadOnly
; P6 (2026-08-03): in-game days a scar must sit before the crisis arc can re-open.
; Before this, SetAltmerCrisisState(ALTMER_CRISIS_NONE, ...) was never called ANYWHERE, so the
; first crisis to resolve ended the arc permanently -- HandleAltmerLorkhanPressure can only open
; a crisis from state NONE, so Lorkhan pressure lost its teeth for the rest of the playthrough.
; Re-entry additionally requires a DIFFERENT source: the per-source PDV.Altmer.CrisisSeen.<n>
; guards are deliberately NOT cleared, which bounds a playthrough to at most one crisis per
; authored source rather than letting the arc become a loop.
Float Property ALTMER_CRISIS_REENTRY_DAYS = 30.0 AutoReadOnly
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
Float Property KHAJIIT_FOCUS_THRESHOLD = 25.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_LEAD_REQUIRED = 15.0 AutoReadOnly
Float Property KHAJIIT_FOCUS_SIGNAL_DELTA = 25.0 AutoReadOnly
; Khajiit lunar substrate pacing (owner decision 2026-07-13): the lunar identity
; metric advances at most KHAJIIT_LUNAR_METRIC_DAILY_MAX per game day across BOTH
; lanes (moon observance + road home), mirroring the Breton practice-point budget.
; Per-event metric requests are the small pulses below; the old per-lane geometric
; decay still shrinks the piety/focus side but no longer owns metric pacing.
; Earliest tier 2 (metric 25) = day 7; earliest tier 3 (metric 75) = day 19.
Float Property KHAJIIT_LUNAR_METRIC_DAILY_MAX = 4.0 AutoReadOnly
Float Property KHAJIIT_LUNAR_MOON_METRIC = 1.0 AutoReadOnly
Float Property KHAJIIT_LUNAR_ROAD_METRIC = 2.0 AutoReadOnly
; Focus weight a quest-reaction piety award contributes to the Khajiit focused
; emphasis (the matrix->focus bridge). Smaller than a dedicated edge signal so a
; single quest cannot lock a focus; a milestone reaction counts double. With
; THRESHOLD 25 / LEAD 15 lets an established behavioral lead emerge once the
; matching deity has also reached Seeker. Behavior-driven focus
; per the LOCKED Khajiit design sheet (moons are the substrate; behavior leads).
Float Property KHAJIIT_FOCUS_MATRIX_DELTA = 6.0 AutoReadOnly
String Property KHAJIIT_MOON_OBSERVATIONS_FILE = "../StorageUtilData/PlayerDevotion/PDV_KhajiitMoonObservations" AutoReadOnly
Int Property KHAJIIT_MOON_OBSERVATIONS_VERSION = 1 AutoReadOnly

; The Altmer calian's line pool, modelled on the Khajiit moon observations above: JSON data, a
; version gate, structural validation, no-immediate-repeat, and a compiled fallback if the file is
; missing or malformed. The calian is the mod's ONLY unlimited daily Altmer act, so its Book of Days
; line is the one a player sees most often -- a single fixed sentence would wear out fastest here.
String Property ALTMER_PRACTICE_LINES_FILE = "../StorageUtilData/PlayerDevotion/PDV_AltmerPracticeLines" AutoReadOnly
Int Property ALTMER_PRACTICE_LINES_VERSION = 2 AutoReadOnly
Int Property ALTMER_PRACTICE_LINES_COUNT = 20 AutoReadOnly
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

PDV_DeityBase _activeDeity

PDV_ContextualFavorRuntime Property FavorRuntime Auto
PDV_DevotionLedger Property LedgerRuntime Auto
PDV_OriginRuntimeBase Property OriginRuntime Auto
; The ten race adapters, in ORIGIN_* index order (NORD=0 .. REDGUARD=9). Exactly one is
; ever bound to OriginRuntime above, chosen by birth race in ResolveOriginRuntime().
FormList Property PDV_FLST_OriginAdapters Auto

; Which race OriginRuntime is currently bound to, or -1 for unbound. Compared against the
; origin global every tick so the binding follows the race whenever it is finally captured.
Int _boundOriginRace = -1
PDV_DaedricRuntime Property DaedricRuntime Auto

Int Property DebugCommand = 0 Auto
Int Property DebugIndex = -1 Auto
Float Property DebugValue = 0.0 Auto
Int Property DebugSignalType = 0 Auto
Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly
Float Property SHOUT_DUPLICATE_WINDOW_DAYS = 0.00001 AutoReadOnly
; PO3 can deliver the same watched quest stage more than once while the stage
; is resolving. Keep the debounce keyed to the exact matrix cell so a duplicate
; callback cannot award piety, a meta faucet, or a broad-pantheon fold twice.

String Property SHOUT_DUPLICATE_KEY = "PDV.ShoutAttack.LastTime" AutoReadOnly
Int _shoutRefreshTicks = 0
; Pass 5 Task 2. Sub-cadence counter for the location/context probes at the tail of
; OnUpdate -- they run every third master tick instead of every one.
Int _contextProbeTicks = 0
; 1.0.4 profiling counters. They add no external call to the hot path; one
; debug-level lookup and trace are performed per 60 timer fires. These markers
; align PapyrusProfiler/stack-profile windows with the manager's actual lanes
; before any cadence is changed.
Int _optimizationTimerFires = 0
Int _optimizationMenuEarlyOuts = 0
Int _optimizationHotLaneRuns = 0
Int _optimizationDisfavorRuns = 0
Int _optimizationReconcileRuns = 0
Int _optimizationContextProbeRuns = 0
Bool _panelDirty = False
Bool _suppressAwardFavorToast = False
Bool _suppressCurseTransitionOutputs = False
; Set by any race-voiced curse surface that actually emits, cleared at the top of each curse
; transition. SendPrismaCurseToast reads it so the generic "<Curse> is lifted / has been driven out"
; toast stands aside when a race already spoke -- a Nord curing lycanthropy was getting the race line
; AND the generic one describing the same event in placeholder copy.
; Deliberately a FLAG rather than a race list: only four races (Nord, Argonian, Khajiit, Redguard)
; have cure records at all, and the generic toast must keep covering the other five, or curing a
; curse goes completely silent for them. When a race gains its records the flag picks it up for free.
Bool _raceCurseSurfaceShown = False
; Deferred presentation for the authored Nord/Kyne recognition. A raw Message.Show() CANNOT display
; over an open config menu -- it returns the default button instantly with no dialog (AGENTS.md,
; 2026-06-13). The tier crossing that triggers this is reachable from an MCM piety seed, so showing
; it inline displayed nothing and burned the one-shot key. Same fix pattern as
; QueueDaedricMilestoneMcmReplay: hold it and present from OnUpdate once menus are closed.
; Pooled-line structural-validation cache (2026-08-07). Each validator probed every entry in its
; pool on EVERY pick -- ~64 native JsonUtil calls for the 20-entry Altmer pool, ~53 for a 16-entry
; Khajiit moon pool. The pools are static shipped content, so the structure cannot change under a
; running game; only the file's VERSION can, and it does so by contract when the content is
; regenerated. These stamps hold the VERSION each pool was last fully validated against, so a
; version bump (or a fresh install) re-validates and steady state costs two calls.
; JsonUtil.Load still runs on every call and is deliberately NOT cached: PapyrusUtil's parsed-file
; cache lives in the DLL, so it does not survive a game reload, and skipping Load would make every
; probe read its "missing" default after a load. The bundled Papyrus reference documents no caching
; semantics for Load, so nothing here assumes any.
; Quest-reaction surface accumulator (2026-07-05): one quest fire = one toast +
; one Book of Days beat, no matter how many deities its cells fan to. Reset at
; the top of ApplyQuestReaction, filled per landed base cell, flushed after the
; cell loop. Two interleaved quest fires could merge into one beat; harmless.
; The bounded worker owns these separate accumulators. They never borrow the
; global broad-pantheon scope, so a long quest fan-out cannot block another
; manager event or merge its player-facing acknowledgement.
; Likes/dislikes smoke surface accumulator (2026-07-11): event 303 and 366
; should score through the generic action router but still leave one visible
; toast + Book of Days beat for the whole fan-out.
Bool _dawnHadActivity = False
Int _broadPantheonSelfEventSequence = 0
; Recognition forms are owned by Devotion and never change at runtime. Resolve
; them once per saved script instance instead of repeating GetFormFromFile in
; the minute reconciliation and its 57-faction reset loop.
Faction _recognitionPlayerFaction = None
Faction[] _recognitionCohortFactions
Bool _recognitionFormsResolved = False
Bool Property AutoPushPrismaPanel = False Auto
Bool Property AllowPrismaBlockingSurfaces = False Auto
PDV_DeityBase _pendingCommitmentOfferDeity = None

; Bind OriginRuntime to the adapter for the player's birth race. This is the ONE place
; race selects behaviour: after this, every Manager.OriginRuntime.X call dispatches
; polymorphically and no caller tests the race. Idempotent and safe to call repeatedly --
; the origin global is written by the PDV_Origin bootstrap and can be rewritten by the
; curse-proof debug path, so re-resolving is how the binding stays truthful.
; Returns False (leaving the previous binding alone) when the race is not yet known.
; The player's origin race, read straight from the global. This is MANAGER state, not adapter
; state -- and it must stay here, because it is the gate that decides whether the adapter can
; be bound at all. Reaching it through OriginRuntime was a None trap: an unbound call does not
; halt in Papyrus, it logs and returns the default 0, which IS ORIGIN_NORD. That is what made
; the startup popup fire before RaceMenu and everything read as Nord.
; Returns -1 while the race is not yet captured.
Int Function GetPlayerOriginRaceIndex()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf

    return -1
EndFunction

; Hand LEDGER the providers that are actually live. Assembled here rather than filled in the
; ESP because all ten origin adapter quests run, but only the bound one may contribute -- a
; static array would apply another race's factor.
Function RefreshGainProviders()
    if !LedgerRuntime
        return
    endIf

    PDV_GainModifierProvider[] providers = new PDV_GainModifierProvider[2]
    providers[0] = OriginRuntime as PDV_GainModifierProvider
    providers[1] = DaedricRuntime as PDV_GainModifierProvider
    LedgerRuntime.SetGainProviders(providers)
EndFunction

Bool Function ResolveOriginRuntime()
    if !PDV_FLST_OriginAdapters || !PDV_GLO_OriginRace
        return False
    endIf

    ; TIMING, and it is the whole point of this function: the origin global defaults to -1 and
    ; is only written by PDV_Origin.InitializeOrigin(), which MainQuest defers to a player
    ; load/sleep ingress -- long AFTER this quest's OnInit. RaceMenu also reports Nord before
    ; the player commits, so the first Nord read is deliberately discarded as provisional.
    ; Binding once at OnInit therefore binds nothing (or a provisional Nord) and never corrects
    ; itself. This is called every tick and rebinds the moment the captured race changes.

    Int raceIndex = PDV_GLO_OriginRace.GetValueInt()
    if raceIndex < ORIGIN_NORD || raceIndex > ORIGIN_REDGUARD
        return False
    endIf

    if raceIndex == _boundOriginRace && OriginRuntime
        return False
    endIf

    PDV_OriginRuntimeBase picked = PDV_FLST_OriginAdapters.GetAt(raceIndex) as PDV_OriginRuntimeBase
    if !picked
        Trace(1, "Origin adapter missing for race index " + raceIndex)
        return False
    endIf

    OriginRuntime = picked
    _boundOriginRace = raceIndex
    Trace(1, "Origin runtime bound to race index " + raceIndex)
    OnOriginRuntimeBound()
    return True
EndFunction

; Per-race setup. This used to sit unconditionally in OnInit, where OriginRuntime was still
; None because the race was not captured yet -- so every one of these None-errored and the
; race package never ran. It now fires on each successful bind, and again on a re-capture or
; a debug race switch. The Ensure* verbs are idempotent by contract, so repeating is safe.
Function OnOriginRuntimeBound()
    if !OriginRuntime
        return
    endIf
    RefreshGainProviders()
    OriginRuntime.EnsureRuntimeWiring()
    OriginRuntime.EnsureBosmerRuntimeWiring()
    OriginRuntime.EnsureNordRuntimeWiring()
    OriginRuntime.EnsureDunmerAncestralUrn()
    OriginRuntime.EnsureAltmerPracticeFocus()
    OriginRuntime.EnsureArgonianHistSapToken()
    OriginRuntime.EnsureKhajiitObserveMoonsPower()
    RequestPanelRefresh()
EndFunction

Event OnInit()
    ; Attempted, but the race is NOT known yet at quest start (global is -1 until the
    ; player-load/sleep ingress captures it), so this normally binds nothing. The real bind
    ; happens from OnUpdate once the capture lands; per-race setup runs in OnOriginRuntimeBound.
    ResolveOriginRuntime()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    EnsureAkatoshRuntimeIdentity()
    LedgerRuntime.EnsureCanonicalDeityDisplayNames()
    RegisterManagerShoutSignals()
    LedgerRuntime.EnsureLikesDislikesTable()
    LedgerRuntime.EnsurePrinceLikesDislikesTable()
    ; MigrateDaedricPactsIfNeeded / MigrateBroadPantheonPools were removed on V3 (Part A
    ; migration sweep); only the consent-gate migration is carried over from 1.5.0e.
    MigrateDaedricConsentIfNeeded()
    EnsureRecognitionModEvents()
    LedgerRuntime.RefreshPatronMirrors()
    FavorRuntime.UpdateContextualFavorRuntime()
    LedgerRuntime.UpdateDisfavorStingRuntime()
    EnsureSurveyDevotionPower()
    RequestPanelRefresh()
    HandleDiegeticLoad("init")
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    _optimizationTimerFires += 1

    ; Bind the origin adapter as soon as the race is captured, and follow it if it changes.
    ; Two cheap reads; the work only happens on an actual change.
    if PDV_GLO_OriginRace && PDV_GLO_OriginRace.GetValueInt() != _boundOriginRace
        ResolveOriginRuntime()
    endIf

    ; Pass 5 Task 2 -- menu early-out. One native call in place of the ~15 StorageUtil and
    ; global reads below. Nothing this tick does can change while a menu owns the screen,
    ; and EnsureUnifiedStartupChoice below puts a MessageBox up, which is exactly what must
    ; not happen over another menu (that is B4's Show() == -1 case, arriving from the other
    ; side). The re-arm is INSIDE the early-out and comes first: a return that skipped it
    ; would kill the chain for the rest of the playthrough, which is the B3 defect Pass 2
    ; fixed. Practical yield is bounded -- RegisterForSingleUpdate is real-time and does not
    ; tick at all while a pausing menu is open, so this earns its keep on the non-pausing
    ; ones (dialogue, and the load-screen window) rather than on the inventory.
    if Utility.IsInMenuMode()
        _optimizationMenuEarlyOuts += 1
        MaybeEmitManagerOptimizationProfile()
        RegisterForSingleUpdate(1.0)
        return
    endIf

    ; Time-sensitive every tick: contextual favor re-checks eligibility and
    ; re-applies itself, so it must react the moment the player leaves the
    ; triggering context. The one-time unified startup choice must fire promptly
    ; once the origin resolves (it self-disables via a StorageUtil flag after it
    ; completes, and checks that flag before any other work).
    ; Disfavor is NOT here: it only clears on a game-time expiry, so it rides the
    ; 10s cadence below -- see the note on that block.
    EnsureUnifiedStartupChoice()
    FavorRuntime.UpdateContextualFavorRuntime()
    if !_diegeticLoadHandled
        HandleDiegeticLoad("update")
    endIf
    DaedricRuntime.ProcessQueuedDaedricMilestonePresentation()
    ProcessQueuedCommitmentOffer()
    OriginRuntime.ProcessQueuedNordKyneChampionEntry()
    DaedricRuntime.ProcessPendingDaedricActivation()
    DaedricRuntime.ProcessPendingDaedricLapse()
    DaedricRuntime.ProcessPendingDaedricPrePactNotices()
    DaedricRuntime.DrainHircineRenunciationJournal()
    DaedricRuntime.ProcessDelayedHircineResiduePrismaToasts()
    _optimizationHotLaneRuns += 1
    if DebugCommand != 0
        RunDebugCommand()
    endIf

    ; Idempotent identity/track/power reconciliation is self-healing but never
    ; changes second-to-second (it is also performed once in OnInit). Re-confirm
    ; it on the slower 10s cadence already used by the shout-signal refresh
    ; instead of every tick, to cut redundant per-tick cross-script external
    ; calls (~10x fewer). Contextual favor above stays at the 1s tick.
    ; The disfavor sweep rides this cadence too: ClearDisfavorIfExpired compares
    ; against Utility.GetCurrentGameTime(), so at the default timescale 20 a 10s
    ; real-time cadence is ~3 game-minutes of granularity on a sting that lasts
    ; game-hours -- imperceptible, and it drops ~6 StorageUtil reads/sec at idle.
    ; Pass 5 Task 2 -- the reconcile block is now two tiers instead of one.
    ;
    ; 10s tier (unchanged): the disfavor sweep. Its cadence has a stated reason --
    ; ClearDisfavorIfExpired compares against Utility.GetCurrentGameTime(), so at the
    ; default timescale 20 a 10s real-time cadence is ~3 game-minutes of granularity on a
    ; sting that lasts game-hours. That reason does not extend to anything else here.
    ;
    ; 30s tier (was 10s): the idempotent identity/track/power reconciliations. These are
    ; paranoia sweeps -- they repair state that nothing at runtime writes, and every one of
    ; them is also performed in OnInit. The expensive member is
    ; EnsureCanonicalDeityDisplayNames, which reads a DeityName across the script boundary
    ; for all ~34 deities and compares each against a literal; at 10s that was ~3.4
    ; cross-script reads a second forever. Tripling the interval triples the worst-case
    ; time a genuinely de-synced name, spell or power spends wrong -- from 10 seconds to 30
    ; -- for state that only de-syncs if a third-party mod strips something behind us.
    _shoutRefreshTicks += 1
    if _shoutRefreshTicks % 10 == 0
        _optimizationDisfavorRuns += 1
        LedgerRuntime.UpdateDisfavorStingRuntime()
    endIf
    if _shoutRefreshTicks >= 30
        _optimizationReconcileRuns += 1
        EnsurePhase8RuntimeWiring()
        EnsureAkatoshRuntimeIdentity()
        LedgerRuntime.EnsureCanonicalDeityDisplayNames()
        OriginRuntime.EnsureBosmerRuntimeWiring()
        OriginRuntime.EnsureNordRuntimeWiring()
        EnsureSurveyDevotionPower()
        OriginRuntime.EnsureDunmerAncestralUrn()
        OriginRuntime.EnsureAltmerPracticeFocus()
        OriginRuntime.EnsureArgonianHistSapToken()
        LedgerRuntime.InitCCContent()
        RegisterManagerShoutSignals()
        LedgerRuntime.EnsureLikesDislikesTable()
        LedgerRuntime.EnsurePrinceLikesDislikesTable()
        MigrateDaedricConsentIfNeeded()
        OriginRuntime.EnsureKhajiitObserveMoonsPower()
        _shoutRefreshTicks = 0
    endIf

    ; Auto daily dawn: nothing else triggers ProcessDawn in normal play (its only
    ; other callers are debug), so detect the in-game day rollover here on the same
    ; day-int boundary the anti-farm gates use and consolidate once per day. Lazy
    ; baseline (Init flag) handles existing saves where OnInit does not re-run.
    ; Fire at ~06:00 (dawn), not midnight: subtract 0.25 day (6h) before the day-int
    ; truncation so the rollover lands at dawn. 0.25 = 6/24; use 5.0/24.0 for 05:00.
    Int pdvCurrentDawnDay = LedgerRuntime.GetDevotionalDay()
    if StorageUtil.GetIntValue(None, "PDV.DawnAuto.Init") == 0
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.Init", 1)
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.LastDay", pdvCurrentDawnDay)
    elseIf pdvCurrentDawnDay > StorageUtil.GetIntValue(None, "PDV.DawnAuto.LastDay")
        StorageUtil.SetIntValue(None, "PDV.DawnAuto.LastDay", pdvCurrentDawnDay)
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auto-dawn: day rollover to " + pdvCurrentDawnDay + "; running ProcessDawn.")
        endIf
        LedgerRuntime.ProcessDawn()
    endIf

    ; Pass 5 Task 2 -- the seven location/context probes drop from 1s to 3s.
    ;
    ; They ask "is the player standing near the Gildergreen / inside Eldergleam's chamber /
    ; swimming outdoors / fishing / at a saint's shrine". None of those is an instant: the
    ; player walks into a 600-unit radius and stays there for many seconds, and the
    ; Argonian water probe accumulates REAL time rather than counting ticks, so a coarser
    ; sample changes when its ten seconds are reached by at most one interval, never
    ; whether. Each probe already opens with a cheap StorageUtil or origin early-out, so
    ; this is a modest saving -- roughly ten StorageUtil reads a second down to three --
    ; but it is free, and 1s bought nothing any of them could use.
    ;
    ; Deliberately NOT moved off the 1s tick above: EnsureUnifiedStartupChoice (a one-shot
    ; that must fire promptly the moment origin resolves), UpdateContextualFavorRuntime
    ; (documented as needing to react the moment the player leaves the triggering context),
    ; the Daedric presentation/activation/lapse drains, and the dawn rollover check.
    _contextProbeTicks += 1
    if _contextProbeTicks >= 3
        _contextProbeTicks = 0
        _optimizationContextProbeRuns += 1
        OriginRuntime.TryArgonianEldergleamInterior()
        OriginRuntime.TryArgonianNearWaterMaintenance()
        OriginRuntime.TryBosmerEldergleamInterior()
        OriginRuntime.TryBosmerGildergreenProximity()
        OriginRuntime.TryBosmerYffreTreeStoneProximity()
        LedgerRuntime.TryCCSaintsRecognition()
        LedgerRuntime.TryCCFishingDevotion()
    endIf

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
                OriginRuntime.SetArgonianHome(seedPlayer, seedCellId, LedgerRuntime.GetDevotionalDay() + 2, "debug_seed")
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

    MaybeEmitManagerOptimizationProfile()
    RegisterForSingleUpdate(1.0)

EndEvent

Function MaybeEmitManagerOptimizationProfile()
    if _optimizationTimerFires < 60
        return
    endIf

    if GetDebugLevel() >= 3
        Debug.Trace("[PDV] OPT_PROFILE manager60 timer=" + _optimizationTimerFires + " menu=" + _optimizationMenuEarlyOuts + " hot=" + _optimizationHotLaneRuns + " disfavor=" + _optimizationDisfavorRuns + " reconcile=" + _optimizationReconcileRuns + " context=" + _optimizationContextProbeRuns)
    endIf

    _optimizationTimerFires = 0
    _optimizationMenuEarlyOuts = 0
    _optimizationHotLaneRuns = 0
    _optimizationDisfavorRuns = 0
    _optimizationReconcileRuns = 0
    _optimizationContextProbeRuns = 0
EndFunction

Function EnsurePhase8RuntimeWiring()
    if !PDV_Talos || !PDV_ConcordatStandingTrack
        return
    endIf

    OriginRuntime.EnsureTalosRuntimeIdentity()

    if PDV_Talos.GainModifyingTrack != PDV_ConcordatStandingTrack
        PDV_Talos.GainModifyingTrack = PDV_ConcordatStandingTrack
    endIf

    if PDV_Talos.DecayModifyingTrack != PDV_ConcordatStandingTrack
        PDV_Talos.DecayModifyingTrack = PDV_ConcordatStandingTrack
    endIf
EndFunction

Function EnsureAkatoshRuntimeIdentity()
    if !LedgerRuntime.PDV_Akatosh
        return
    endIf

    Bool repaired = False

    if LedgerRuntime.PDV_Akatosh.DeityName != "Akatosh"
        LedgerRuntime.PDV_Akatosh.DeityName = "Akatosh"
        repaired = True
    endIf

    if LedgerRuntime.PDV_Akatosh.PDV_GLO_DebugLevel != LedgerRuntime.PDV_GLO_DebugLevel
        LedgerRuntime.PDV_Akatosh.PDV_GLO_DebugLevel = LedgerRuntime.PDV_GLO_DebugLevel
        repaired = True
    endIf

    if LedgerRuntime.PDV_Akatosh.PDV_GLO_OriginRace != PDV_GLO_OriginRace
        LedgerRuntime.PDV_Akatosh.PDV_GLO_OriginRace = PDV_GLO_OriginRace
        repaired = True
    endIf

    if repaired && GetDebugLevel() >= 1
        Debug.Trace("[PDV] Akatosh runtime identity repaired.")
    endIf
EndFunction










Event OnPlayerShoutAttack(Shout akShout)
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        Trace(1, "Quest shout fallback skipped: player unavailable.")
        return
    endIf

    OriginRuntime.HandleShoutAttack(EVT_SHOUT_ATTACK, playerRef, akShout, "manager_form")
    Trace(2, "Quest shout fallback observed.")
EndEvent



; Authoria bard-performance signal. Quality is the SGT expertise delta (1-8);
; Become a Bard-only performances enter at quality 1. The daily repeat
; multiplier is the global devotional anti-farm budget, while PlayerEvents
; separately enforces one award per tavern per devotional day.


; --- Quest-fire surface accumulator -------------------------------------------------
; One quest fire = one toast + one Book of Days beat, however many deities its cells
; fan to (an assassination cell lands 6+ gods; per-cell toasts proved spammy). The
; panel driver ring keeps the per-god detail via AwardPiety. The toast names the
; strongest reactor ("Mephala and 3 others mark your deed."); the Book of Days line
; lists every landed god so the chronicle stays complete. A milestone-magnitude cell
; weighs the Book entry one step heavier so it can headline.








; Maps a quest-reaction deity name to its Khajiit focused-emphasis value, or
; KHAJIIT_FOCUS_NONE if the deity is not one of the five Khajiit focus paths.

; Adds focus weight (not piety) toward a Khajiit emphasis from a matrix quest
; reaction. Milestone reactions count double. Carries its own per-deity daily
; anti-farm so repeating the same quest family does not slam a focus into the lead.

; --- Gods in strength ----------------------------------------------------------
; Each of the eight lunar slots names one moon-path god in strength. Matching a
; Seeker-or-higher focus activates Lattice Resonance; piety is never multiplied.
; The mapping lives in one place for easy tuning.
; Indices match GetKhajiitMoonPhaseFromGameDay (the real visible Skyrim phase).

; Inverse of GetKhajiitEmphasisDeity: resolves a deity to its Khajiit focus value.

; Returns the focus presiding over the current moon phase (always defined for a
; Khajiit; cosmological, independent of the player's standing with that god).

; Compatibility accessor retained for old callers. A god is favored when it is
; in strength and is also the player's current Seeker-or-higher focus.

; Resolves the phase-blessing spell for a focus value (None until authored).

; Compatibility cleanup for the retired five rotating stat spells. Their records
; remain in the plugin for save/FormID stability, but runtime reconciliation always
; removes them. Lattice Resonance owns the active god-strength mechanic.









Event OnUpdateGameTime()
    Actor playerRef = Game.GetPlayer()
    OriginRuntime.SyncKhajiitPhaseBlessing()
    OriginRuntime.SyncKhajiitLatticeResonance(playerRef)
    OriginRuntime.ScheduleNextKhajiitGodStrengthBoundary()
EndEvent


; Dawn drip: each newly learned Word of Power nudges Alkosh emphasis (the dragon
; tongue as ordered speech). Baselines on first run so a mid-save install does
; not bulk-award the backlog; capped at 3 words per dawn, remainder carried.

; Compatibility no-op. God strength modifies the focused reward through Lattice
; Resonance and never modifies piety gain.


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

; --- Prisma toast size preference (Normal/Large). Large targets 4K displays, where
; even the high-res auto-scaling reads small. Persisted, defaults to Normal. The size
; is injected into every toast payload at the single send choke point below (plus the
; one curse toast that sends directly), so all toast surfaces honour it without each
; builder having to carry the field. ---
Bool Function PrismaToastLargeEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Prisma.ToastLarge", 0) == 1
EndFunction

Function SetPrismaToastLargeEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Prisma.ToastLarge", PDV_DevotionRules.BoolToInt(enabled))
EndFunction

String Function WithPrismaToastSize(String payload)
    if !PrismaToastLargeEnabled()
        return payload
    endIf
    String marker = "\"toast\":{"
    Int idx = StringUtil.Find(payload, marker)
    if idx < 0
        return payload
    endIf
    Int insertAt = idx + StringUtil.GetLength(marker)
    return StringUtil.Substring(payload, 0, insertAt) + "\"size\":\"large\"," + StringUtil.Substring(payload, insertAt)
EndFunction

Bool Function SendPrismaToastPayloadOrFallback(String payload, String fallbackTitle, String fallbackMessage, Bool allowFallback = True, Bool allowDuringRaceSetup = False)
    if IsRaceSetupQuietPresentationActive() && !allowDuringRaceSetup
        return False
    endIf

    ; Player Notifications preference: when off, suppress the toast but leave the
    ; Book of Days ledger (a separate call path) untouched.
    if !NotificationsEnabled()
        return False
    endIf

    Bool sent = False
    if PDV_PrismaBridge.IsAvailable()
        sent = PDV_PrismaBridge.SendOverlayJson(WithPrismaToastSize(payload))
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

Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText, Bool allowFallback = True, Bool allowDuringRaceSetup = False)
    String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"message\":\"" + PDV_DevotionRules.JsonSafeString(messageText) + "\"}}"
    return SendPrismaToastPayloadOrFallback(payload, titleText, messageText, allowFallback, allowDuringRaceSetup)
EndFunction

Bool Function SendPrismaToastWithSource(String symbolName, String tone, String titleText, String messageText, String sourceModName, Bool allowFallback = True, String correlation = "")
    if sourceModName == "" && correlation == ""
        return SendPrismaToast(symbolName, tone, titleText, messageText, allowFallback)
    endIf
    sourceModName = NormalizePublicDeityDisplayText(sourceModName)
    String correlationPrefix = ""
    if correlation != ""
        correlationPrefix = "\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\","
    endIf
    String payload = "{\"mode\":\"toast\"," + correlationPrefix + "\"toast\":{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"message\":\"" + PDV_DevotionRules.JsonSafeString(messageText) + "\""
    if sourceModName != ""
        payload = payload + ",\"source\":\"" + PDV_DevotionRules.JsonSafeString(sourceModName) + "\""
    endIf
    if correlation != ""
        payload = payload + ",\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\""
    endIf
    payload = payload + "}}"
    String fallbackTitle = titleText
    if sourceModName != ""
        fallbackTitle = titleText + " - " + sourceModName
    endIf
    return SendPrismaToastPayloadOrFallback(payload, fallbackTitle, messageText, allowFallback)
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
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\""
    j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(deityName) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + PDV_DevotionRules.JsonSafeString(rival) + "\""
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

; Player-facing "In-Game Effects" preference (the D1 diegetic layer: screen, sound,
; music cues). Persists the choice in StorageUtil, default ON, and drives the
; director's D1Enabled. ApplyInGameEffectsPreference() is called on game load so the
; choice survives saves regardless of the baked ESP flag.
Bool Function InGameEffectsEnabled()
    return StorageUtil.GetIntValue(None, "PDV.UI.InGameEffects", 1) != 0
EndFunction

Function SetInGameEffectsEnabled(Bool enabled)
    if enabled
        StorageUtil.SetIntValue(None, "PDV.UI.InGameEffects", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.UI.InGameEffects", 0)
    endIf
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.D1Enabled = enabled
    endIf
EndFunction

Function ApplyInGameEffectsPreference()
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.D1Enabled = InGameEffectsEnabled()
    endIf
EndFunction

; Player-facing "Notifications" preference. Default ON. When OFF, on-screen toasts
; are suppressed at the shared chokepoint (and in the ethnic notification wrappers)
; while the Book of Days journal still records everything. Interactive choice
; prompts are never gated by this.
Bool Function NotificationsEnabled()
    return StorageUtil.GetIntValue(None, "PDV.UI.NotificationsEnabled", 1) != 0
EndFunction

Function SetNotificationsEnabled(Bool enabled)
    if enabled
        StorageUtil.SetIntValue(None, "PDV.UI.NotificationsEnabled", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.UI.NotificationsEnabled", 0)
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
        ; fix-plan 4.2: scope the repeatable guard by the devotional day so a transition
        ; cannot re-surface twice across a midnight the player slept through.
        guard = guard + "." + (LedgerRuntime.GetDevotionalDay() + 2)
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
    ; A curse SHIFT (e.g. werewolf -> vampire) reads, for the incoming curse, like that
    ; curse's onset. Reuse the onset frame so the shift still earns a Book of Days entry;
    ; previously curse.shift had no journal line, so a vampire reached from werewolf
    ; chronicled nothing while a fresh vampire onset did.
    String directorToneKey = toneKey
    if eventClass == "curse" && direction == "shift"
        directorToneKey = "curse.onset"
    endIf
    if PDV_DiegeticDirectorService && !(eventClass == "tier" && direction == "reach")
        String bespoke = PDV_DiegeticDirectorService.ResolveJournalLine(deityIndex, directorToneKey)
        if bespoke != ""
            if eventClass == "curse"
                return AppendCurseConsequenceLine(bespoke, direction, surfaceKey)
            endIf
            return bespoke
        endIf
    endIf

    if eventClass == "offer" && direction == "accept"
        return LedgerRuntime.BuildCommitmentOfferAcceptJournalLine(deityIndex)
    elseIf eventClass == "offer" && direction == "refuse"
        return LedgerRuntime.BuildCommitmentOfferRefuseJournalLine(deityIndex)
    elseIf eventClass == "reorientation" && direction == "shift"
        return BuildReorientationJournalLine(surfaceKey)
    elseIf eventClass == "tier" && direction == "reach"
        return BuildTierReachJournalLine(surfaceKey, deityIndex)
    elseIf eventClass == "curse" && direction == "onset"
        return AppendCurseConsequenceLine("A curse changes the shape of devotion.", direction, surfaceKey)
    elseIf eventClass == "curse" && direction == "shift"
        return AppendCurseConsequenceLine("A curse gives way to a new shape.", direction, surfaceKey)
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

; Append the crisp race/curse consequence line the curse toast shows onto the Book of
; Days frame, so the chronicle names werewolf vs vampire specifically instead of only the
; shared frame (e.g. the Altmer "divided self" onset line). Reuses the authored
; GetCurseContextForRace toast copy -- no new strings -- treating a shift into a curse like
; that curse's onset, and de-dups so a frame already carrying the line is left unchanged.
String Function AppendCurseConsequenceLine(String baseLine, String direction, String curseType)
    String phase = direction
    if direction == "shift"
        phase = "onset"
    endIf
    String consequence = OriginRuntime.GetCurseContextForRace(phase, curseType)
    if consequence == ""
        return baseLine
    endIf
    if StringUtil.Find(baseLine, consequence) >= 0
        return baseLine
    endIf
    return baseLine + " " + consequence
EndFunction

String Function BuildTierReachJournalLine(String surfaceKey, Int deityIndex)
    String deityName = GetJournalDeityName(deityIndex)
    String tierLabel = LedgerRuntime.ExtractTierLabelFromSurfaceKey(surfaceKey)
    if tierLabel == ""
        tierLabel = "a deeper standing"
    endIf
    return "Your devotion to " + deityName + " has reached " + tierLabel + "."
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
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if deity
        return GetPublicDeityDisplayName(deity)
    endIf
    return "the patron"
EndFunction

; Symbol for a journal entry: the deity's glyph when the transition belongs to a
; deity, else the generic journal mark.
String Function ResolveTransitionJournalSymbol(String eventClass, Int deityIndex)
    if deityIndex >= 0
        PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
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
    Bool pantheonBroadPresentation = LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace)
    String originLabel = "Unknown"
    if originRace >= 0
        originLabel = OriginRuntime.GetOriginRaceLabel(originRace)
    endIf

    String titleText = "Devotion"
    String symbolName = "journal"
    Float piety = 0.0
    Float pietyToday = 0.0
    Int tierValue = LedgerRuntime.TIER_NONE
    String tierLabelOverride = ""
    Float championThreshold = 85.0

    PDV_DaedricPathBase panelPact = DaedricRuntime.GetActiveDaedricPactPath()
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
        pietyToday = LedgerRuntime.GetPietyToday(panelPact)
        tierValue = panelPact.GetStoredTier()
        if panelPact.ThresholdChampion > 0.0
            championThreshold = panelPact.ThresholdChampion
        endIf
    elseIf _activeDeity
        titleText = GetPublicDeityDisplayName(_activeDeity)
        symbolName = GetPrismaSymbolForDeity(_activeDeity)
        piety = LedgerRuntime.GetPiety(_activeDeity)
        pietyToday = LedgerRuntime.GetPietyToday(_activeDeity)
        tierValue = LedgerRuntime.GetTier(_activeDeity)
        if OriginRuntime.IsFocusedPantheonBoonSuspended()
            tierValue = LedgerRuntime.TIER_NONE
            tierLabelOverride = "Wavering"
        endIf
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
        Int broadTier = OriginRuntime.GetBroadLaneTierForOrigin(originRace)
        if pantheonBroadPresentation || broadTier > LedgerRuntime.TIER_NONE
            titleText = OriginRuntime.GetBroadLaneDisplayName(originRace)
            symbolName = OriginRuntime.GetBroadLaneSymbol(originRace)
            tierValue = broadTier
            tierLabelOverride = OriginRuntime.GetBroadLaneStandingLabel(originRace, broadTier)
            piety = OriginRuntime.GetBroadLaneStandingValue(originRace)
            pietyToday = OriginRuntime.GetBroadLaneScratchValue(originRace)
        endIf
        if LedgerRuntime.PDV_GLO_ActivePiety
            if !pantheonBroadPresentation && broadTier <= LedgerRuntime.TIER_NONE
                piety = LedgerRuntime.PDV_GLO_ActivePiety.GetValue()
            endIf
        endIf
        if LedgerRuntime.PDV_GLO_ActiveTier
            if !pantheonBroadPresentation && broadTier <= LedgerRuntime.TIER_NONE
                tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
            endIf
        endIf
        if originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
            piety = PDV_ArgonianHistSubstrate.GetMetric()
            tierValue = PDV_ArgonianHistSubstrate.GetSubstrateTier()
            tierLabelOverride = OriginRuntime.GetArgonianCulturalPracticeLabel()
            championThreshold = 75.0
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

    String j = "{\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    j = j + ",\"status\":\"Live\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"patron\":\"" + PDV_DevotionRules.JsonSafeString(GetPlayerMcmPatronLine()) + "\""
    j = j + ",\"patronNote\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelPatronNote()) + "\""
    j = j + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetSurveyDevotionText()) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    String nextText = GetPanelNextThresholdText(panelCommitment, piety)
    if OriginRuntime.IsFocusedPantheonBoonSuspended()
        nextText = "Focused boon returns at 50 piety"
    elseIf panelCommitment == None && originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        nextText = OriginRuntime.GetArgonianCulturalNextThresholdText(piety)
    elseIf panelCommitment == None && (pantheonBroadPresentation || OriginRuntime.GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        nextText = OriginRuntime.GetBroadLaneNextThresholdText(originRace)
    endIf
    j = j + ",\"nextText\":\"" + PDV_DevotionRules.JsonSafeString(nextText) + "\""
    j = j + ",\"piety\":" + piety
    if panelCommitment == None && (pantheonBroadPresentation || OriginRuntime.GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        if originRace == ORIGIN_BRETON
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + OriginRuntime.GetBroadLaneServiceCount(originRace) + " practice points") + "\""
        elseIf originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_NORD
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.FormatTwoDecimals(OriginRuntime.GetBroadLaneStandingValue(originRace)) + " pantheon standing") + "\""
        else
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + OriginRuntime.GetBroadLaneServiceCount(originRace) + " broad acts") + "\""
        endIf
    elseIf panelCommitment == None && originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.FormatTwoDecimals(piety) + " cultural practice") + "\""
    endIf
    j = j + ",\"pietyToday\":" + pietyToday
    j = j + ",\"todayMood\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelTodayMood(pietyToday)) + "\""
    j = j + ",\"driftLabel\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelDriftLabel()) + "\""
    j = j + ",\"originRace\":\"" + PDV_DevotionRules.JsonSafeString(originLabel) + "\""
    j = j + ",\"patronState\":\"" + PDV_DevotionRules.JsonSafeString(LedgerRuntime.GetPatronStateLabel()) + "\""
    j = j + ",\"acts\":[" + GetPanelActsJson() + "]"
    j = j + ",\"rites\":[" + GetPanelRitesJson() + "]"
    j = j + ",\"relations\":[" + GetPanelRelationsJson() + "]"
    j = j + ",\"recognition\":" + GetNpcRecognitionPanelJson()
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
        PDV_DaedricPathBase dashPact = DaedricRuntime.GetActiveDaedricPactPath()
        if dashPact
            tracked = dashPact
        endIf
    endIf
    if !tracked && OriginRuntime.IsKhajiitOrigin()
        tracked = OriginRuntime.GetKhajiitEmphasisDeity(OriginRuntime.GetKhajiitFocusedEmphasis())
    endIf
    if tracked
        gods = AppendDashboardGod(gods, tracked, "patron")
        shown += 1
    endIf

    PDV_DaedricPathBase watchingPath = DaedricRuntime.GetTopPrePactDaedricPath()
    if watchingPath && watchingPath != tracked
        gods = AppendDashboardGod(gods, watchingPath, "watching")
        shown += 1
    endIf

    if LedgerRuntime.PDV_FLST_AllDeities
        Int i = 0
        Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if deity && deity != tracked && OriginRuntime.IsDashboardDeityInOriginRoster(deity, originRace)
                Form deityForm = deity as Form
                Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
                Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
                if piety > 0.0 || pietyToday != 0.0 || LedgerRuntime.IsNeglectFlagActive(deity) || LedgerRuntime.HasRecentPietyMovement(deityForm)
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


String Function AppendDashboardGod(String acc, PDV_DeityBase deity, String system)
    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    Int tier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int

    String entry = "{\"god\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(deity)) + "\""
    entry = entry + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(GetPrismaSymbolForDeity(deity)) + "\""
    entry = entry + ",\"system\":\"" + PDV_DevotionRules.JsonSafeString(system) + "\""
    entry = entry + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(LedgerRuntime.GetGodRollupState(deity)) + "\""
    entry = entry + ",\"pietyToday\":" + pietyToday
    entry = entry + ",\"piety\":" + piety
    entry = entry + ",\"tier\":" + tier
    entry = entry + ",\"drivers\":[" + LedgerRuntime.GetDeityDriversJson(deity) + "]"
    entry = entry + ",\"week\":[" + BuildWeekNetJson(deityForm) + "]}"

    if acc != ""
        acc = acc + ","
    endIf
    return acc + entry
EndFunction

; Raw recent-driver entries (newest-last) for one deity. The dashboard aggregates by
; reason client-side; each entry carries its signed delta and gain/loss direction.

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
    if kindText == "broad"
        primary = PDV_DevotionRules.ClampValue(piety / LedgerRuntime.BROAD_PANTHEON_POOL_MAX, 0.0, 1.0)
    elseIf kindText == "cultural"
        primary = PDV_DevotionRules.ClampValue(piety / 75.0, 0.0, 1.0)
    elseIf kindText == "piety"
        Float pietyDenom = championThreshold
        if pietyDenom <= 0.0
            pietyDenom = 85.0
        endIf
        primary = PDV_DevotionRules.ClampValue(piety / pietyDenom, 0.0, 1.0)
    else
        primary = PDV_DevotionRules.ClampValue((tierValue as Float) / 3.0, 0.0, 1.0)
    endIf

    String j = "{\"kind\":\"" + PDV_DevotionRules.JsonSafeString(kindText) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    j = j + ",\"primary\":" + PDV_DevotionRules.FormatTwoDecimals(primary)
    j = j + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelInstrumentState(originRace, kindText, tierLabel)) + "\""
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
    if LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || OriginRuntime.GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE
        return "broad"
    endIf
    if originRace == ORIGIN_KHAJIIT
        return "lunar"
    elseIf originRace == ORIGIN_ARGONIAN
        return "cultural"
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
    elseIf kindText == "cultural"
        return OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf kindText == "ancestor"
        return OriginRuntime.GetDunmerAncestorLayerLabel()
    elseIf kindText == "forge"
        return OriginRuntime.GetOrcLifeModeLabel()
    elseIf kindText == "sects"
        return OriginRuntime.GetRedguardSectLabel()
    elseIf kindText == "branch"
        return OriginRuntime.GetBosmerPathLabel()
    endIf
    return tierLabel
EndFunction

String Function GetPanelInstrumentDataJson(Int originRace, String kindText, Float piety)
    if kindText == "broad"
        if originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_NORD
            return "{\"standing\":" + PDV_DevotionRules.FormatTwoDecimals(OriginRuntime.GetBroadLaneStandingValue(originRace)) + ",\"scratch\":" + PDV_DevotionRules.FormatTwoDecimals(OriginRuntime.GetBroadLaneScratchValue(originRace)) + ",\"pool\":\"" + PDV_DevotionRules.JsonSafeString(LedgerRuntime.GetActiveBroadPantheonPoolId()) + "\",\"baseline\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetBroadLaneDisplayName(originRace)) + "\"}"
        endIf
        return "{\"acts\":" + OriginRuntime.GetBroadLaneServiceCount(originRace) + "}"
    endIf
    if kindText == "lunar"
        Int phase = OriginRuntime.GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
        Int focus = OriginRuntime.GetKhajiitFocusedEmphasis()
        String lunarTier = "Quiet"
        Int substrateTier = 0
        if PDV_KhajiitLunarSubstrate
            substrateTier = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
            lunarTier = OriginRuntime.GetKhajiitLunarTierLabel(substrateTier)
        endIf
        String standing = "Lunar Lattice"
        PDV_DeityBase focusDeity = OriginRuntime.GetKhajiitEmphasisDeity(focus)
        if focusDeity
            standing = GetPublicTierBand(LedgerRuntime.GetTier(focusDeity))
        endIf
        String focusLabel = OriginRuntime.GetKhajiitFocusLabel(focus)
        String strengthLabel = OriginRuntime.GetKhajiitFocusLabel(OriginRuntime.GetLunarPresidingFocus(phase))
        return "{\"phase\":" + phase + ",\"focus\":\"" + PDV_DevotionRules.JsonSafeString(focusLabel) + "\",\"lunarTier\":\"" + PDV_DevotionRules.JsonSafeString(lunarTier) + "\",\"currentFocus\":\"" + PDV_DevotionRules.JsonSafeString(focusLabel) + "\",\"godInStrength\":\"" + PDV_DevotionRules.JsonSafeString(strengthLabel) + "\",\"focusStanding\":\"" + PDV_DevotionRules.JsonSafeString(standing) + "\",\"substrateTier\":" + substrateTier + ",\"resonating\":" + PDV_DevotionRules.BoolToJson(OriginRuntime.IsKhajiitLatticeResonating()) + "}"
    elseIf kindText == "cultural"
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
        Float culturalMetric = 0.0
        Int culturalTier = LedgerRuntime.TIER_NONE
        if PDV_ArgonianHistSubstrate
            culturalMetric = PDV_ArgonianHistSubstrate.GetMetric()
            culturalTier = PDV_ArgonianHistSubstrate.GetSubstrateTier()
        endIf
        return "{\"metric\":" + PDV_DevotionRules.FormatTwoDecimals(culturalMetric) + ",\"culturalTier\":" + culturalTier + ",\"hist\":" + PDV_DevotionRules.FormatTwoDecimals(hist) + ",\"people\":" + PDV_DevotionRules.FormatTwoDecimals(people) + ",\"void\":" + PDV_DevotionRules.FormatTwoDecimals(voidValue) + ",\"voidActive\":" + PDV_DevotionRules.BoolToJson(voidActive) + "}"
    elseIf kindText == "ancestor"
        Int depth = 0
        Int prayer = 0
        Int home = 0
        if PDV_DunmerAncestorSubstrate
            depth = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            prayer = PDV_DunmerAncestorSubstrate.GetPrayerCount()
            home = PDV_DunmerAncestorSubstrate.GetHomeBonusCount()
        endIf
        return "{\"depth\":" + depth + ",\"prayer\":" + prayer + ",\"home\":" + home + ",\"reclamation\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetDunmerAncestorLayerLabel()) + "\"}"
    elseIf kindText == "forge"
        return "{\"lifeMode\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetOrcLifeModeLabel()) + "\"}"
    elseIf kindText == "sects"
        return "{\"sect\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetRedguardSectLabel()) + "\"}"
    elseIf kindText == "branch"
        return "{\"path\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetBosmerPathLabel()) + "\",\"pactBound\":" + PDV_DevotionRules.BoolToJson(OriginRuntime.IsBosmerPactBound()) + ",\"evidenceDays\":" + OriginRuntime.GetBosmerPathEvidenceDays() + "}"
    endIf
    return "{\"piety\":" + PDV_DevotionRules.FormatTwoDecimals(piety) + ",\"pietyToday\":0.00}"
EndFunction


String Function GetPanelPatronNote()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose a path through play, prayer, and consequence."
    endIf
    PDV_DaedricPathBase pactPath = DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        if GetPlayerOriginRaceIndex() == ORIGIN_BRETON && OriginRuntime.GetBretonTraditionValue() == BRETON_TRADITION_HIDDEN_ART && DaedricRuntime.IsBretonHiddenArtDaedricOfferDeity(pactPath)
            return "The " + pactPath.DeityName + " pact stands within the Hidden Art; the tradition remains your practiced road."
        endIf
        return "A pact binds you; lesser devotions fall quiet."
    endIf
    if LedgerRuntime.IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    if OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "The commitment remains, but its boon is suspended below 50 piety."
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
    if OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Suspended"
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        return "Thinning"
    endIf
    if DaedricRuntime.GetActiveDaedricPactPath()
        return "Steady"
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        return "Steady"
    endIf
    return "Quiet"
EndFunction

String Function GetPanelActsJson()
    String items = ""
    PDV_DaedricPathBase actsPact = DaedricRuntime.GetActiveDaedricPactPath()
    if actsPact
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("daedric", "neutral", "Keep the pact", "Act in keeping with " + actsPact.DeityName + " to hold this pact."))
    elseIf _activeDeity
        Float today = LedgerRuntime.GetPietyToday(_activeDeity)
        if today != 0.0
            String tone = "good"
            if today < 0.0
                tone = "warning"
            endIf
            items = PDV_DevotionRules.AppendJsonItem(items, PanelEventObject("favor", _activeDeity, "", "Today's devotion is being weighed.", "" + today, tone, "", ""))
        endIf
    endIf

    if FavorRuntime.IsFavorActive()
        Int lane = FavorRuntime.GetActiveFavorLane()
        Int fam = FavorRuntime.GetActiveFavorFamily()
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("journal", "good", FavorRuntime.GetContextualFavorLaneLabel(lane), FavorRuntime.GetContextualFavorFamilyLabel(lane, fam)))
    endIf

    ; Quasi-patron: show current substrate/state-track mode as the headline act
    ; when there is no scoring patron; gives the player their mode at a glance.
    if !_activeDeity && !actsPact
        Int originRace = GetPlayerOriginRaceIndex()
        String quasiLabel = GetPanelQuasiPatronTierLabel(originRace)
        if quasiLabel != ""
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(GetPanelQuasiPatronSymbol(originRace), "neutral", "Current practice", quasiLabel))
        endIf
    endIf

    return items
EndFunction

String Function GetPanelRitesJson()
    String items = PanelPlainObject("journal", "", "Survey your devotion", "Call on the Survey Devotion power to read where your path stands.")
    PDV_DaedricPathBase ritesPact = DaedricRuntime.GetActiveDaedricPactPath()
    if ritesPact
        String pactName = NormalizePublicDeityDisplayText(ritesPact.DeityName)
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("daedric", "", "Keep " + pactName + "'s pact", "Act in keeping with " + pactName + " to hold this pact."))
    elseIf _activeDeity
        String activeName = GetPublicDeityDisplayName(_activeDeity)
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(GetPrismaSymbolForDeity(_activeDeity), "", "Keep " + activeName + "'s rites", "Act in keeping with " + activeName + " to deepen this bond."))
    else
        ; Quasi-patron: tell the player what kind of acts build their path.
        Int originRace = GetPlayerOriginRaceIndex()
        String patronName = GetPanelQuasiPatronName(originRace)
        String patronSymbol = GetPanelQuasiPatronSymbol(originRace)
        if patronName != "Devotion"
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(patronSymbol, "", "Deepen your practice", "Continue acting in keeping with " + patronName + " to build this path."))
        endIf
    endIf
    return items
EndFunction

String Function GetPanelRelationsJson()
    String items = ""
    PDV_DaedricPathBase relsPact = DaedricRuntime.GetActiveDaedricPactPath()
    if relsPact
        Int dstate = relsPact.GetDaedricStateForPlayer()
        String dstateTone = "neutral"
        if dstate == relsPact.DAEDRIC_STATE_NATIVE
            dstateTone = "good"
        elseIf dstate >= relsPact.DAEDRIC_STATE_TABOO
            dstateTone = "warning"
        endIf
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", dstateTone, "", NormalizePublicDeityDisplayText(relsPact.DeityName) + "'s pact stands " + relsPact.GetDaedricStateLabel(dstate) + " among your people."))
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
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", stanceTone, "", stanceText))
        endIf

        Quest[] rivals = _activeDeity.RivalDeities
        if rivals && rivals.Length > 0
            PDV_DeityBase rivalDeity = rivals[0] as PDV_DeityBase
            if rivalDeity
                items = PDV_DevotionRules.AppendJsonItem(items, PanelEventObject("rivalry", _activeDeity, "", "", "", "", "", rivalDeity.DeityName))
            endIf
        endIf
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("hist", "neutral", "Hist relation", OriginRuntime.GetArgonianLayerStrengthLabel(PDV_ArgonianHistSubstrate.GetHistRelation())))
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("journal", "neutral", "People relation", OriginRuntime.GetArgonianLayerStrengthLabel(PDV_ArgonianHistSubstrate.GetPeopleRelation())))
        String voidTone = "neutral"
        if PDV_ArgonianHistSubstrate.IsVoidFullyActive()
            voidTone = "warning"
        endIf
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("sithis", voidTone, "Void relation", OriginRuntime.GetArgonianVoidStrengthLabel(PDV_ArgonianHistSubstrate.GetVoidRelation())))
    endIf

    if LedgerRuntime.IsBroadWorshipActive()
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", "neutral", "", "You keep the broad rites of your people, with no single patron named."))
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", "warning", "", "Some of your rites have grown quiet and need attention."))
    endIf

    return items
EndFunction

String Function GetPanelDebugJson()
    String j = "{\"Favor\":\"" + PDV_DevotionRules.JsonSafeString(FavorRuntime.GetPlayerMcmFavorLine()) + "\""
    j = j + ",\"Neglect\":\"" + PDV_DevotionRules.JsonSafeString(LedgerRuntime.GetPlayerMcmNeglectLine()) + "\""
    j = j + ",\"Curse\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetPlayerCursePublicLabel()) + "\""
    j = j + "}"
    return j
EndFunction

; --- Quasi-patron helpers ---
; For races whose piety is tracked via substrate/state-track rather than a
; scoring PDV_DeityBase patron, these derive panel identity fields so the
; panel is never blank for non-deity races.

String Function GetPanelQuasiPatronName(Int originRace)
    if originRace == ORIGIN_ARGONIAN
        return "Saxhleel Practice"
    elseIf originRace == ORIGIN_ORC
        return "Malacath"
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = OriginRuntime.GetKhajiitFocusedEmphasis()
        if focus > 0
            return OriginRuntime.GetKhajiitFocusLabel(focus)
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
        Int focus = OriginRuntime.GetKhajiitFocusedEmphasis()
        if focus > 0
            return OriginRuntime.GetKhajiitFocusSymbol(focus)
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
        return OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf originRace == ORIGIN_ORC
        return OriginRuntime.GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = OriginRuntime.GetKhajiitFocusedEmphasis()
        if focus > 0
            return "Focused: " + OriginRuntime.GetKhajiitFocusLabel(focus)
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_DUNMER
        return "Ancestor layer: " + OriginRuntime.GetDunmerAncestorLayerLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return OriginRuntime.GetRedguardSectLabel()
    elseIf originRace == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerPathLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return OriginRuntime.GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_BRETON
        return OriginRuntime.GetBretonTraditionLabel()
    elseIf originRace == ORIGIN_NORD
        return OriginRuntime.GetNordDevotionModeLabel()
    elseIf originRace == ORIGIN_ALTMER
        return OriginRuntime.GetAltmerCrisisStateLabel()
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
    String j = "{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\""
    if deityName != ""
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(deityName) + "\""
    endIf
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if itemText != ""
        j = j + ",\"text\":\"" + PDV_DevotionRules.JsonSafeString(itemText) + "\""
    endIf
    if amountText != ""
        j = j + ",\"amount\":" + amountText
    endIf
    if tone != ""
        j = j + ",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + PDV_DevotionRules.JsonSafeString(rival) + "\""
    endIf
    j = j + "}"
    return j
EndFunction

String Function PanelPlainObject(String symbolName, String tone, String listTitle, String listText)
    String j = "{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if tone != ""
        j = j + ",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\""
    endIf
    if listTitle != ""
        j = j + ",\"listTitle\":\"" + PDV_DevotionRules.JsonSafeString(listTitle) + "\""
    endIf
    j = j + ",\"listText\":\"" + PDV_DevotionRules.JsonSafeString(listText) + "\""
    j = j + "}"
    return j
EndFunction

; Compatibility wrapper for any older compiled caller. New book routes call the
; explicit book-read interface below; ambient progress must not use this path.
Function ShowP2BookNotice(String reason, String titleText, String messageText)
    SurfaceP2BookReadNotice(reason, titleText, messageText)
EndFunction

; A real P2 book read is an explicit player acknowledgement. It remains visible
; through a setup-quiet scope, unlike ambient progress produced during setup.
Function SurfaceP2BookReadNotice(String reason, String titleText, String messageText)
    if !IsP2BookNoticeReason(reason)
        return
    endIf
    SurfaceP2Acknowledgement(titleText, messageText, True, "P2 book notice surfaced: ")
EndFunction

; Ambient progression may be caused by sleep or automated state reconciliation.
; It uses the same paired delivery but respects the startup quiet scope.
Function SurfaceP2AmbientProgressNotice(String titleText, String messageText)
    SurfaceP2Acknowledgement(titleText, messageText, False, "P2 ambient notice surfaced: ")
EndFunction

; Private delivery module. Callers choose the semantic interface above instead
; of carrying quiet-presentation policy through every producer.
Function SurfaceP2Acknowledgement(String titleText, String messageText, Bool allowDuringRaceSetup, String tracePrefix)
    SendPrismaToast("journal", "good", titleText, messageText, True, allowDuringRaceSetup)
    AppendBookOfDaysEntry(messageText, Utility.GetCurrentGameTime() as Int, "favor.act", "journal", False, 1, titleText, allowDuringRaceSetup)
    Trace(2, tracePrefix + titleText)
EndFunction

Bool Function IsP2BookNoticeReason(String reason)
    return PDV_DevotionRules.StringContainsToken(reason, "po3_book")
EndFunction




; Forces a fresh disk re-read of the core matrix and discovered opt-in channels
; into the JsonUtil in-memory cache. Use after regenerating matrix data
; mid-session so already-watched quests pick up newly-authored (form|stage) cells
; without a full reload. Returns a short summary string for the MCM readout.
; NOTE: this refreshes CELL DATA only; brand-new watched quests are (re)registered
; for stage events on the next game load via RefreshP2Hooks.
String Function DebugReloadQuestMatrix()
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugReloadCatalog()
    endIf
    return "Quest Reaction runtime is unavailable."
EndFunction

Int Function DebugGetSignalFloorSmokeScenarioCount()
    return 15
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
    elseIf scenarioIndex == 13
        return "T11: MQ101 150"
    elseIf scenarioIndex == 14
        return "T11: MQ105 160"
    elseIf scenarioIndex == 15
        return "T11: MQ106 200 - Syrabane"
    endIf
    return "Unknown"
EndFunction

String Function DebugRunSignalFloorSmokeScenario(Int scenarioIndex)
    String label = DebugGetSignalFloorSmokeLabel(scenarioIndex)
    StorageUtil.SetStringValue(None, "PDV.SignalFloorSmoke.LastScenario", label)

    if scenarioIndex <= 0
        String reloadText = DebugReloadQuestMatrix()
        StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
        LedgerRuntime.EnsureLikesDislikesTable()
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
    elseIf scenarioIndex == 13
        return DebugRouteSignalFloorQuest(0x0003372B, "Skyrim.esm", 150, label)
    elseIf scenarioIndex == 14
        return DebugRouteSignalFloorQuest(0x000242BA, "Skyrim.esm", 160, label)
    elseIf scenarioIndex == 15
        return DebugRouteSignalFloorQuest(0x00032926, "Skyrim.esm", 200, label)
    endIf

    return "Unknown signal-floor smoke scenario."
EndFunction

String Function DebugRouteSignalFloorQuest(Int questFormId, String pluginName, Int stageValue, String label)
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugSubmitQuestStage(questFormId, pluginName, stageValue, label)
    endIf
    return label + ": Quest Reaction runtime is unavailable."
EndFunction

String Function DebugQueueQuestReactionPerformanceSweep()
    if PDV_QuestReactionRuntimeService
        return PDV_QuestReactionRuntimeService.DebugQueuePerformanceSweep()
    endIf
    return "Quest Reaction runtime is unavailable."
EndFunction

String Function DebugRouteSignalFloorCryptClear()
    if !PDV_FLST_UndeadCryptClearSites || PDV_FLST_UndeadCryptClearSites.GetSize() <= 0
        return "Crypt-clear FormList is missing or empty."
    endIf

    Location cryptLoc = PDV_FLST_UndeadCryptClearSites.GetAt(0) as Location
    if !cryptLoc
        return "Crypt-clear FormList slot 0 is not a Location."
    endIf

    OriginRuntime.ApplyUndeadCryptClearReactions(cryptLoc, 1.0)
    Trace(1, "SignalFloorSmoke crypt-clear debug fanout routed.")
    return "Crypt-clear fanout routed from FormList slot 0. Controlled backend route only; organic proof still requires entering and clearing a listed crypt."
EndFunction

String Function DebugRouteSignalFloorLikesDislikes()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
    LedgerRuntime.EnsureLikesDislikesTable()
    DebugFireDislike(PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Kyne"), 303)
    DebugFireDislike(PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Arkay"), 366)
    Trace(1, "SignalFloorSmoke LD v15 debug fired events 303 and 366.")
    return "Likes/dislikes v15 reloaded; fired Kyne 303 and Arkay 366 through the debug dislike harness. Controlled backend route only."
EndFunction

String Function DebugRouteSignalFloorGreenWay()
    if !OriginRuntime.IsBosmerOrigin()
        return "Set origin to Bosmer before running Green Way signal-floor debug."
    endIf

    Bool siteRouted = OriginRuntime.TryAwardBosmerYffreGreenSite("mcm_signal_floor", "mcm_signal_floor_green_site")
    DebugTriggerGreenPactViolation()
    Trace(1, "SignalFloorSmoke Green Way debug routed; site=" + PDV_DevotionRules.BoolToInt(siteRouted))
    return "Green Way backend routes fired. Site=" + PDV_DevotionRules.BoolToInt(siteRouted) + ". Plant-food organic proof still requires consuming a listed plant food."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxKill()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    OriginRuntime.HandlePaarthurnaxKill(sourceForm, "mcm_signal_floor_kill")
    Trace(1, "SignalFloorSmoke Paarthurnax kill debug routed.")
    return "Paarthurnax kill fork routed with latches reset first. Controlled backend route only; organic kill proof still required."
EndFunction

String Function DebugRouteSignalFloorPaarthurnaxSpare()
    Form sourceForm = Game.GetFormFromFile(0x00046EF2, "Skyrim.esm")
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.KillSeen", 0)
    StorageUtil.SetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0)
    OriginRuntime.HandlePaarthurnaxSpare(sourceForm, "mcm_signal_floor_spare")
    Trace(1, "SignalFloorSmoke Paarthurnax spare debug routed.")
    return "Paarthurnax spare fork routed with latches reset first. Controlled backend route only; organic MQ305/alive proof still required."
EndFunction




; @module: FAVOR-prereq
; Public accessor so extracted modules (FAVOR) can read the active patron deity
; through the manager backref. _activeDeity is a bare script variable written in
; many manager sites; a getter is sufficient because external read-sites only read.
PDV_DeityBase Function GetActiveDeity()
    return _activeDeity
EndFunction









String Function ResolveShrinePrayerJournalLabel(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel)
    Int originRace = GetPlayerOriginRaceIndex()

    if originRace == ORIGIN_NORD && LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Kyne")
        return "Kyne"
    endIf

    if originRace == ORIGIN_KHAJIIT
        if LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Khenarthi")
            return "Khenarthi"
        endIf
        if LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Alkosh")
            return "Alkosh"
        endIf
    endIf

    if originRace == ORIGIN_ALTMER && LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
        return "Auri-El"
    endIf

    if originRace == ORIGIN_BOSMER
        if LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
            return "Auri-El"
        endIf
        if LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Z'en")
            return "Z'en"
        endIf
    endIf

    if originRace == ORIGIN_REDGUARD && LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Tu'whacca")
        return "Tu'whacca"
    endIf

    ; Resolve the alias to its deity record and use the canonical display name (e.g. the
    ; lowercase catalog key "talos" -> "Talos"). The special-case returns above still win for
    ; race display overrides (Kyne, Auri-El, ...); this only fixes the default fallthrough,
    ; which previously returned the raw lowercase alias. Falls back to the old normalize path
    ; for a shrineLabel/name that does not resolve to a deity.
    if shrineLabel != ""
        PDV_DeityBase labelDeity = LedgerRuntime.GetShrinePrayerDeityByName(shrineLabel)
        if labelDeity
            return GetPublicDeityDisplayName(labelDeity)
        endIf
        return NormalizePublicDeityDisplayText(shrineLabel)
    endIf
    PDV_DeityBase primaryDeity = LedgerRuntime.GetShrinePrayerDeityByName(primaryDeityName)
    if primaryDeity
        return GetPublicDeityDisplayName(primaryDeity)
    endIf
    return NormalizePublicDeityDisplayText(primaryDeityName)
EndFunction




Function SetDebugLevel(Int levelValue)
    if LedgerRuntime.PDV_GLO_DebugLevel
        LedgerRuntime.PDV_GLO_DebugLevel.SetValue(PDV_DevotionRules.ClampInt(levelValue, 0, 3) as Float)
    endIf
EndFunction







; Production likes/dislikes events that are also authentic cultural-practice
; ingress converge here. Deity scoring remains separate in the event bus.






; The Trial of Iron: at the declared community place (the Orc hearth-rest cell), with a
; 7-day cooldown, the player takes up one discipline of the Code. One-active discipline,
; swap via re-rite (clear-before-add). "Not yet" does not spend the cooldown. Returns true
; when the menu was shown so the wake-notice is suppressed that night.

; Clear-before-add: never two disciplines at once. Records the life-mode standing the player
; swore it under so SyncOrcTrialOfIron can fade/restore on a standing collapse.



; The discipline holds while the life-mode standing it was sworn under is intact. If that
; standing collapses (a confirmed mode change -- exile, or a different hold), the discipline
; goes quiet at dawn and returns at dawn when the standing is recovered.
; PDV.OrcTrial.Active stays set while quiet so no re-rite is needed.



; The Remembering of Names: an ancestral observance taken at the declared rest cell, with a
; 7-day cooldown. One-active observance, swap via re-rite (clear-before-add). "Not yet" does
; not spend the cooldown. Returns true when the menu was shown so the rest-notice is
; suppressed that night.

; Clear-before-add: never two observances at once. Records the sect named-on so
; SyncRedguardRemembering can fade/restore on a sect shift.



; The observance holds while the sect it was named under is settled. During a sect switch
; (committed sect differs from the one named at rite) it goes quiet at dawn and returns at
; dawn once the sect settles. PDV.RedRemember.Active stays set while quiet.


; The Disciplines of Return: at rest, with a 7-day cooldown, the player sets one cultivation
; discipline of magic. One-active, swap via re-rite (clear-before-add). "Not yet" records a
; short three-devotional-day prompt cooldown so declining cannot reopen the menu every rest.
; Returns true when the menu was shown so the dream is suppressed that night. The handler
; guard already blocks this while curse-suppressed.

; Clear-before-add: never two disciplines at once. Coherence reads current crisis state at
; dawn (no snapshot needed), so SyncAltmerDisciplines fades/restores on a crisis break.



; The discipline holds while the player is coherent (no unresolved crisis and not curse-
; suppressed). On a crisis break it goes quiet at dawn and returns at dawn on resolution.
; PDV.Alt.Disc.Active stays set while quiet so no re-rite is needed.





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

; Bed-of-choice declaration and the rooted-rest wake-up. The declared bed is
; remembered as a raw FormID so no quest alias or VMAD change is needed. A new
; place must be slept in three times running before it can become home, so a
; one-night inn stop never steals the rite. A decline re-prompts only after 3 days.
; Returns true when the declaration menu was shown (the dream yields that
; night so a MessageBox and a dream toast never stack).



; Hist Adaptation rite: once the player has kept a declared home at substrate
; HIGH for a randomized 10-14 in-game days, sleeping on rooted ground (the
; declared bed or a remembered water) lets the root reshape them ONCE. The clock
; is armed lazily on the first qualifying sleep; the choice is permanent once
; taken. The rite grants no piety. Returns true when the rite menu was shown so
; the dream yields that night.

; Clear-before-add: never two adaptations at once.



; Dawn-sync slot maintenance: the chosen adaptation is a permanent bodily
; change. Metric 75 gates the one-time rite, not continued ownership.

; Waters That Remember: curated sacred-water locations greet an Argonian once,
; each a one-shot vision beat with a small one-shot Hist pulse. Permanent
; one-shot keys make this inherently anti-farm.

; Shared one-shot award for a sacred water site, keyed by the site's FormID
; (the LCTN FormID, including Eldergleam's, so the milestone count stays at 6).

; Set on every location change: 1 while inside the Eldergleam sanctuary location
; (exterior + interior share LCTN 0192AC), 0 anywhere else. Gates the interior
; poll so GetParentCell is only sampled while the player is actually at the site.

; Bounded poll (OnUpdate): only while EldergleamActive. Fires the vision when the
; player reaches an Eldergleam interior cave cell -- where the water actually is
; -- not at the exterior approach. Disarms on award, on leaving, or once seen.

; Ambient near-water Hist maintenance -- the design centerpiece: the Hist recovers
; from being near water. While an Argonian is in water (swimming a river/lake/swamp),
; the Hist is gently maintained, at most once per in-game day so it stays a quiet
; floor rather than a farmable pulse. Polled on the manager 1s tick; the day-key is
; checked before IsSwimming so it short-circuits cheaply once credited for the day.

; Sleeping Tree Sap: the strange tree's sap brushes the Hist once, ever.

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

    OriginRuntime.RefreshArgonianHistPosture("debug_seed")
    OriginRuntime.SyncRaceRewards()

    Bool voidActive = PDV_ArgonianHistSubstrate.IsVoidFullyActive()
    Debug.MessageBox("PDV relation seed applied. Hist " + histValue + ", People " + peopleValue + ", Void " + voidValue + ". Cultural practice remains " + PDV_ArgonianHistSubstrate.GetMetric() + "; Void active " + voidActive + ". Use Debug: Pacing & Pantheons seed 75 separately for adaptation-threshold proof.")
EndFunction

; Shadowscale signature: while the Void is the active foreground emphasis, a
; sneaking kill once per day pulls the shadow back over the player. Pure
; texture: a brief self-invisibility moment and a toast; no piety movement.
; Sneak state is polled at routing time, so a kill credited after leaving
; sneak can miss the veil; accepted approximation, documented in the packet.

; Hist dreams keyed to posture: armed by a posture transition (strong roll),
; otherwise a rare ambient murmur. Pure flavor; no piety, no substrate writes.

; ===================== Bosmer variety ("The Story Goes On") =====================

; Sleep-exit dispatcher. Order mirrors the Argonian one: silent declaration/rite
; menus first, dream text last, and a shown menu suppresses the dream that night
; so a MessageBox and a dream toast never stack.

; Hearth of the Telling uses the CELL you sleep in (reliable at sleep-stop).
; First eligible sleep prompts declaration on any Bosmer path so the Naming rite
; can use the same stable "declared rest place" pattern as Argonian adaptation.
; Tale Carried remains Living Story-only on return to the declared hearth.

; The Naming rite: at the declared hearth or any Songs site, with a 7-day cooldown,
; the player retells their own form. One-active told-self, swap via re-rite
; (clear-before-add). "Not yet" does not spend the cooldown. Returns true when the
; menu was shown so the dream yields that night.

; Clear-before-add: never two told-selves at once. Records the path the player was
; on so SyncBosmerNaming can fade/restore on coherence break.



; The told-self holds to the path it was named on. Off that path (or, on Old
; Contract, in the Apostate GPC band) it goes quiet at dawn and returns at dawn
; when the player comes back to coherence. PDV.BosNaming.Active stays set while
; quiet so no re-rite is needed.


; Green Dreams: armed (strong roll) the night after a path change, otherwise a
; rare ambient murmur. Pure flavor; no piety, no state writes beyond the dream
; bookkeeping keys.


; Songs of the Green: one location-change entry. Counts every newly-seen location
; (for the Hearth discovery delta), awards the curated Songs sites once each,
; and dispatches the narrower Y'ffre green-site fanout for the signal floor.
; Eldergleam, Gildergreen, and the Tree Stone are held for bounded polls so
; broad parent locations do not fire before the player reaches the actual site.



; Bounded poll (OnUpdate): only while inside the armed Eldergleam sanctuary
; LOCATION. Fires the green-song vision when the player reaches an Eldergleam
; interior cave cell -- where the water and great tree are -- not at the exterior
; approach. Disarms on award, on leaving, or once seen. Awards with the LCTN
; FormID so the milestone count stays at 6. Mirrors TryArgonianEldergleamInterior
; (shared interior cells); "Seen.103084" is the decimal render of LCTN 0x000192AC.

; Bounded poll (OnUpdate): only while inside the armed Whiterun city LOCATION.
; Fires the green-song vision when the player walks up to the Gildergreen tree
; (Skyrim.esm ref 0x00023612, outdoors in the Wind District) -- NOT at the Temple
; of Kynareth interior. Awards the Temple LCTN FormID 0x0001F87D (the Gildergreen
; song's FLST slot id) so the milestone count stays at 6. The Gildergreen ref is
; resolved once and cached (vanilla static form; avoids a hot-loop lookup). The
; ~600 distance covers the Gildergreen planter without firing across the district.




; One-shot award per Songs site, keyed by LCTN FormID. Small path piety + vision
; line; milestone MessageBox once all six are known.

; Scales at Rest (Exchange signature, once/day). Called from HandleBosmerExchangeSignal.

; Shared below-health entry point. The player alias owns combat-session sampling;
; this manager fans the one low-health observation to race-specific payloads.


; Baan Dar Opens the Gap (Bandit Road signature, once/day). Called from the
; shared player below-health gate when player health drops below 20% in combat.



; Dawn helper: arm an elevated dream the night after a path change.

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




















; Declare the player's Dunmer ancestor-home from sleep, keyed to the cell rather
; than the bed reference. First homes ask immediately; moving to a new place
; requires three consecutive sleeps in the same non-home cell so a one-night inn
; stop does not steal the rite.


















; Shared daily metric budget for the Khajiit lunar substrate (both lanes draw from
; one pool), mirroring ConsumeBretonPracticePointBudget. Returns the granted metric,
; clamped to the day's remaining budget (0 when exhausted).

; Direct boundary seed for reward/UI proof; explicitly bypasses the daily metric
; budget (mirrors DebugSetBretonPracticePoints).
String Function DebugSetKhajiitLunarMetric(Float metricTarget)
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    Float clampedTarget = metricTarget
    if clampedTarget < 0.0
        clampedTarget = 0.0
    elseIf clampedTarget > 100.0
        clampedTarget = 100.0
    endIf
    PDV_KhajiitLunarSubstrate.SetMetric(clampedTarget, "mcm_debug_lunar_seed")
    RequestPanelRefresh()
    return "Lunar metric set to " + PDV_DevotionRules.FormatTwoDecimals(clampedTarget) + "; tier " + PDV_KhajiitLunarSubstrate.GetSubstrateTier() + ". Direct boundary seed; bypasses the daily metric budget."
EndFunction

String Function DebugResetKhajiitLunarSubstrate()
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    PDV_KhajiitLunarSubstrate.ResetPilotForDebug()
    StorageUtil.SetIntValue(None, "PDV.Khajiit.LunarMetricDay", -1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LunarMetricToday", 0.0)
    RequestPanelRefresh()
    return "Lunar substrate reset to zero; daily metric budget cleared."
EndFunction

String Function DebugGetKhajiitLunarBudgetSummary()
    if !OriginRuntime.IsKhajiitOrigin() || !PDV_KhajiitLunarSubstrate
        return "Khajiit origin and lunar substrate are required."
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Float spentToday = 0.0
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarMetricDay", -1) == today
        spentToday = StorageUtil.GetFloatValue(None, "PDV.Khajiit.LunarMetricToday")
    endIf
    Float remaining = KHAJIIT_LUNAR_METRIC_DAILY_MAX - spentToday
    if remaining < 0.0
        remaining = 0.0
    endIf
    return "Lunar metric " + PDV_DevotionRules.FormatTwoDecimals(PDV_KhajiitLunarSubstrate.GetMetric()) + ", tier " + PDV_KhajiitLunarSubstrate.GetSubstrateTier() + ". Today " + PDV_DevotionRules.FormatTwoDecimals(spentToday) + " of " + PDV_DevotionRules.FormatTwoDecimals(KHAJIIT_LUNAR_METRIC_DAILY_MAX) + " metric used, " + PDV_DevotionRules.FormatTwoDecimals(remaining) + " remaining."
EndFunction






; Named-dragon kill: the focus signal plus the curated named-dragon beat. The
; kill receiver one-shots each named ActorBase, so the large beat cannot repeat.

; Generic (unnamed) dragon kill: emphasis-only nudge at quarter weight, no piety
; pulse, at most once per game-week. Random dragons score lower by design.

; Near-fatal reversal: the rare marked Baan Dar beat. Double emphasis weight and
; the large bandit-road curated signal; the receiver enforces the weekly cap.


; Resolves the scripted deity for a Khajiit focused-emphasis value (None if unwired).

; Small foreground piety pulse to the emphasis deity (the double-route partner of the
; substrate/focus-weight signal). Each concrete deity defines its own small pulse signal.

; --- Khajiit anti-creed handlers: medium/major acts against a patron's creed cost piety with
; that patron (negative ScoreCuratedSignal delta). Routed only from curated triggers, never
; ambient behavior.




; Positive twin of the caravan-harm route: defending or supporting a caravan.
; Repeatable, so unlike the anti-creed handlers it is daily-capped on the pulse.

; Big-heist milestone above the elegant-theft cadence: a single steal whose take
; is >= 500 gold (value gate lives at the ingress). Daily-capped on the pulse.













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



; Night-only predatory shadow behavior accrues a shadow-evidence day. The
; once-per-day evidence guard plus the 3-in-7 threshold keep ShadowDrift a
; deliberate drift, not a consequence of a single night act.







; Khajiit branch of ApplyCurseRaceHandlers: fires the god-voice (Azurah) curse
; MessageBoxes on werewolf/vampire onset and cure (once-guarded), then re-derives
; the Lattice posture so a mid-day transition updates Survey immediately.

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

    Int oldPosture = OriginRuntime.GetKhajiitLunarPosture()
    PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    if newPosture != oldPosture
        if newPosture == KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
            OriginRuntime.ShowOriginMessage(PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow.", False)
        endIf
        SendPrismaShiftToast(OriginRuntime.GetKhajiitLunarPostureDisplayLabelAt(newPosture), OriginRuntime.GetKhajiitLunarPostureReadout(newPosture), "lunar")
        RequestPanelRefresh()
    endIf
EndFunction

; MCM dev-page seed: cycle Normal -> Strained -> Corrupted -> ShadowDrift -> Normal
; so every Lattice posture readout and message is reachable from the debug page,
; including ShadowDrift (otherwise gated behind sustained night-theft evidence).
Function DebugCycleKhajiitLunarPosture()
    Int nextPosture = OriginRuntime.GetKhajiitLunarPosture() + 1
    if nextPosture > KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        nextPosture = KHAJIIT_LUNAR_POSTURE_NORMAL
    endIf

    DebugForceKhajiitLunarPosture(nextPosture, "mcm_cycle")
EndFunction










; Organic stronghold forge (2026-07-15, D1#11 fix): Story Manager craft events at
; a stronghold now reach the forge lane; the dev signal objects stay as debug.
















; Soft life-mode switches settle at dawn per the LOCKED design: the non-current
; mode with two evidence days inside seven wins (highest accumulated weight on a
; tie), honoring the lock-in. A non-City mode with no evidence in fourteen days
; lapses back to City, the steady default -- getting Stronghold back is not easy.




























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








; Shared Ash'abah death-duty rewards (Tu'whacca death-rite signal + flat heal + social
; stigma), fired by both the routine duty and the marked major burden so the two paths
; cannot drift.

; Tu'whacca's Ward / Far Shores reward, converted from a swallowed always-on
; HealRateMult buff (a rate-mult on Requiem's ~0 base health-regen = unfelt) to a
; flat, event-driven death-rite restoration. Fires when a Tu'whacca death-rite is
; kept (death-duty or Far Shores token), scaled by Tu'whacca tier, once per day so
; repeated duty cannot farm it. Magnitudes PROVISIONAL -- tune against Requiem's
; health economy in-game (memory: requiem-proof-heal-flat-restore-not-rate).

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






; Tu'whacca vampire re-entry (2026-07-15, wire): the cure sets
; PDV.Redguard.VampireReentryNeeded; the next authentic sect act while mortal
; completes the return through Tu'whacca. The flag itself is the one-shot latch.





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
















; Nord/Kyne counterpart to MaybeShowRedguardChampionEntry. The Redguard beat hangs off a SECT
; change, so it never collides with a tier surface; Kyne's recognition IS the tier reach, so this
; is deliberately ADDITIVE rather than a suppression like ShouldSuppressBretonFocusedChampionTierSurface.
; The universal surface above keeps the toast, the Book of Days entry and the Ledger feed; this
; only adds the authored modal on top. Suppressing the generic surface would silence all three.



















; Tiered Lorkhan-adjacency penalty (LOCKED base values): the more directly an act
; affirms Lorkhan / mortal incarnation, the steeper the cost to Altmer divine devotion.

; ThalmorAlignment faction modifier scales the Lorkhan penalty. Negative bands
; are heterodox and soften the penalty; positive bands are orthodox and sharpen it.

; ThalmorAlignment is the Concordat-mirror reputation track (-100..+100, 5 states).
; Positive points push toward Thalmor orthodoxy (+100); negative points toward the
; heterodox/defiant pole. Points are absolute track adjustments (no band multiplier on
; the points themselves) per PDV_NextBuildPass_RecordSpec.md sec.1.




; Emitter entry point for ThalmorAlignment actions. Enforces Altmer origin and a one-shot
; per (action, source form) so re-reading a banned text or re-equipping the same Daedric
; artifact does not repeatedly move the alignment track.

; Shared sink for an unprovoked Thalmor kill, routed from PDV_ActionRouter's non-hostile
; kill path. Altmer reads it as a -20 ThalmorAlignment heterodox act (one-shot per victim
; via HandleAltmerAlignmentSignal); Imperial reads it as -10 Concordat defiance.



; --- Altmer crisis exit (2026-07-15, D1#6 fix) ---
; Reassert: three distinct devotional days of orthodox rites while the crisis is
; open move the line to REASSERTING; a two-day lockout then settles it
; SCARRED_RESOLVED at dawn. Living with it instead: after seven open days on the
; heterodox side of the alignment track, the crisis settles on its own.


; Active-patron heritage memory: the Altmer mirror of the Dunmer ancestor-memory
; dawn pulse (parity gap closed 2026-07-15). Once per dawn cycle, the daily rite
; also keeps faith with an active Magnus or Xarxes patron.



; P7 (2026-08-03). Trinimac's curated book route. Revives SIGNAL_FALLEN_GOD_ORTHODOXY (2301), which
; had NO award site anywhere -- it was one of the live "wire" entries in tools/pdv_reserved_signals.json.
;
; The tail call into HandleAltmerOrthodoxCostlyEnforcement is deliberate and load-bearing for P3:
; the reason carries "trinimac" and not "xarxes", so AwardAltmerOrthodoxSignal falls through its
; Xarxes branch and reaches AURI-EL's SIGNAL_ORTHODOXY_AFFIRMATION. That is the second organic
; source P3 reserved this prefix for. Do not rename the prefix without re-reading that function.

; P7. Trinimac's renewable beat, and the only band-keyed signal in the mod. ThalmorAlignment
; otherwise pins at +100 late game with no consumer but a Lorkhan multiplier; this makes the pin
; mean something. Requires no new detection -- event 2 already fires on hostile-humanoid kills.

; --- P9 (2026-08-03): Syrabane's four wired signals -------------------------------------------
; He shipped with FIVE declared signals and ZERO award sites -- a closed ledger whose only income
; was the quest-reaction matrix. Four are wired here. SIGNAL_APPRENTICE_AID (3111) is deliberately
; NOT wired: every College-aid hook duplicates quest-reaction rows he already holds on MG01, MG02,
; MG03, MG05, MG07 and MG08, which would score him twice for one act. See the P9 respec.
;
; Every handler below is origin- and curse-gated, and every one caps the piety pulse.

; --- P14 (2026-08-04): the Altmer practice focus ----------------------------------------------
; The keystone durability act. Every Altmer lane except Trinimac's was built on a FINITE world pool
; -- curated books one-shot, Words of Power and map markers bounded, skills capped -- so a
; scholar-focused player eventually had nothing left to do. This never exhausts and needs no
; inventory bookkeeping.
;
; It also gives P18's dawn an INDOOR path: the outdoor observance is the free version, this is the
; one you can keep anywhere.
;
; Returns the idle kind for the token: 0 = pray, 1 = study.

; 0 = prayer pose (foundation and martial lanes), 1 = reading pose (scholar lanes).

; Grants the focus once, mirroring EnsureDunmerAncestralUrn.



; Weekly, not daily -- the detector already gates on a near-fatal mage fight with a kill, so the
; rarity is the guard. Mirrors the Nord/Tsun and Khajiit/Baan Dar cadence in PDV_PlayerEvents.

; The three vanilla ward tomes. Learning a Ward IS magical containment -- the most on-theme source
; in his lane. One-shot per tome via MarkP2SourceRoute upstream.


; The Auri-El arm below was PROVABLY UNREACHABLE in shipped play until 2026-08-03 (packet P3).
; SIGNAL_ORTHODOXY_AFFIRMATION carries delta 3.0 -- the largest curated delta in the Altmer set --
; but the only shipped ingress into HandleAltmerOrthodoxCostlyEnforcement was
; RouteAltmerXarxesLineage, whose reason ALWAYS contains "xarxes", so the Xarxes branch always
; returned first and Auri-El never scored outside the MCM debug button.
;
; TRAP: PDV_EventSignalActivator / PDV_EventSignalEffect make route 53 look reachable in a call
; graph. Those are QA test harness, never shipped world content -- do not read them as an ingress.
;
; The organic sources are ResolveAltmerCrisis (below, live now) and, once P7 lands, the Trinimac
; book route. That route's reason prefix "eventbus_p2_altmer_trinimac_" is reserved deliberately:
; it must NOT contain "xarxes" or it routes the award to the wrong god.



; The calian's rotating Book of Days line. Same shape as the Khajiit moon observations: validate the
; JSON, exclude whatever was shown last so the same sentence never lands twice running, and fall
; back to a compiled line if the file is missing or malformed. A bad JSON must never cost the player
; their acknowledgement -- the practice still happened.
; Returns a pool index, or -1 when the JSON cannot be trusted. Records the resolved id so the next
; call can exclude it -- one pick, one place, so the toast and the Book entry can never disagree
; about which line was drawn.


; P2: shared voice for the ancestral spine. Gated on the day credit ACTUALLY landing -- the
; substrate budget is one credit per devotional day, so most calls legitimately grant nothing and
; writing a line for a rejected credit would report practice that never happened.
; Returns the line it wrote, or "" when nothing was written, so the caller can reuse the exact text
; as the Prisma toast context. One resolution, two surfaces -- the toast and the chronicle can never
; name different pooled lines for the same act.

; Resolves one pooled line and writes it with its own title. Kept separate from
; AppendAltmerHeritageVoice so that function keeps exactly one Book of Days call, which the Prisma
; UI audit asserts.

; P2: per-source voice for the ancestral spine. The reason prefixes are set by each call site;
; keep this in sync with them rather than inventing new ones here.









Bool Function DebugAssertAltmerRejectedSurface(String sourceId)
    return OriginRuntime.IsAltmerRejectedLorkhanSurface(sourceId)
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


; One-shot guard when a tracked deity advances a tier.
; --- P10: Long Devotion accessors ------------------------------------------------------------
; Pure derivation over existing piety. Marks land at 100/115/130/145/160/175/190 for a standard
; 85-threshold deity, capped at LONG_DEVOTION_MARK_MAX so a 200-piety patron cannot run away.

; Ratchets MarkHigh (which gates the decay floor) and surfaces each mark exactly once.
; The ratchet is deliberately one-way: a patron who slips back below a mark keeps the floor they
; earned, so the floor cannot flap on and off with ordinary decay.

; Dawn tick. Only the patron / focused-emphasis deity accrues marks -- the same scope the reward
; and mirror hooks already use, so a broad worshipper's whole pantheon does not each start
; ratcheting floors.


String Function GetTierStandingLabel(Int tier)
    if tier >= LedgerRuntime.TIER_CHAMPION
        return "Champion"
    elseIf tier >= LedgerRuntime.TIER_DEVOTED
        return "Devoted"
    elseIf tier >= LedgerRuntime.TIER_SEEKER
        return "Seeker"
    endIf
    return "Unrecognized"
EndFunction

; Player-facing devotional band per Architecture v3 Section 2.1 (tier vocabulary
; boundary). PLAYER surfaces (Survey, tier-up notice, champion, neglect) use these
; bands; GetCurrentStandingLabel / GetTierStandingLabel keep the internal
; Seeker/Champion words for dev/MCM/code and the separate Daedric path naming.
String Function GetPublicTierBand(Int tier)
    if tier >= LedgerRuntime.TIER_CHAMPION
        return "Devoted"
    elseIf tier >= LedgerRuntime.TIER_DEVOTED
        return "Faithful"
    elseIf tier >= LedgerRuntime.TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
EndFunction


Function InitializePreflightState()
    if StorageUtil.GetIntValue(None, "PDV.FrameworkSchemaVersion") != FRAMEWORK_SCHEMA_VERSION
        StorageUtil.SetIntValue(None, "PDV.FrameworkSchemaVersion", FRAMEWORK_SCHEMA_VERSION)
        Trace(2, "Framework schema version recorded as " + FRAMEWORK_SCHEMA_VERSION)
    endIf

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        LedgerRuntime.RestoreActiveDeityFromStoredPatron()
        if !_activeDeity
            LedgerRuntime.SetPatronState(LedgerRuntime.PATRON_STATE_UNSET)
        else
            LedgerRuntime.SyncPatronStateGlobal()
            LedgerRuntime.RefreshPatronMirrors()
        endIf
    else
        LedgerRuntime.SyncPatronStateGlobal()
    endIf
EndFunction



; --- Likes/dislikes table loader (v0: hand-authored from PDV_DeityLikesDislikes.csv) ---
; Resolves deities by DeityName over PDV_FLST_AllDeities and writes the PDV.LD.<evt>.{D,C,O}
; keys read by PDV_DeityBase.ScoreFromTable. Origin-gated overlay rows write to
; PDV.LD.<evt>.O<origin>.{D,C,O}. Version-gated so existing saves reload on a bump.
; PRODUCTIONIZE: regenerate this from the CSV via an author tool before scaling to all 48 actors.



; Clear a deity's entire PDV.LD.* row set before LoadRowsForDeity rewrites it.
; Without this, a row REMOVED from the table (e.g. sithis kill-hostile) leaves
; an orphan StorageUtil key that still scores on every save that ever loaded the
; old version -- a version bump alone does not fix it. Clearing a superset of
; every event the table uses, then rewriting, makes removals actually take.
; MAINTENANCE: GetLikesDislikesEventTypes() must list every event id used in
; LoadRowsForDeity (plus any fully-retired id), or a removed row will not clear.


; --- V2 transgressive-Prince path-gated likes/dislikes (separate from the V1 PDV.LD.* table) ---
; The 12 transgressive Princes are PDV_DaedricPath_* actors (not in PDV_FLST_AllDeities), so the
; V1 fan-out never touches them. This loads their rows into PDV.PLD.* on the path form and, for an
; OPEN (committed) path only, deepens that path's OWN piety on a scored act. Version-gated by
; PRINCE_LD_VERSION. Source: PDV_DeityLikesDislikes_Princes_V2.csv via tools/pdv_princeld_gen.mjs.

; Consent-gate migration. Legacy saves could hold an active Prince pact committed before
; the consent latch existed. Such a pact would keep piety capped at 84 forever (ClampPiety
; parks below Champion without consent), so clear the un-consented pact and let the formal
; offer re-fire. PDV.Piety is PRESERVED (never touched here). Version-gated on a key that is
; SEPARATE from PDV.Daedric.PactVersion so it never fights MigrateDaedricPactsIfNeeded.
Function MigrateDaedricConsentIfNeeded()
    if StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema") >= DAEDRIC_CONSENT_SCHEMA_VERSION
        return
    endIf

    Int i = 0
    Int count = DaedricRuntime.GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = DaedricRuntime.GetDaedricPathAtListIndex(i)
        if path && path.IsActiveDaedricPact() && !path.HasDaedricPactConsent()
            ; Same clearing calls migration uses: strip the live pact spells and null the
            ; active-pact pointer. PDV.Piety is deliberately left intact.
            path.ClearLiveDaedricPactSpells()
            StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
            if GetDebugLevel() >= 1
                Debug.Trace("[PDV] Daedric consent migration: cleared un-consented pact for " + path.DeityName + " (piety preserved)")
            endIf
        endIf
        i += 1
    endWhile

    StorageUtil.SetIntValue(None, "PDV.Daedric.ConsentSchema", DAEDRIC_CONSENT_SCHEMA_VERSION)
    RequestPanelRefresh()
EndFunction




; Runtime record-compatible projection of the canonical matrix. Existing saves bake VMAD
; property values at first quest init and never re-read them, so ESP changes only reach new
; games; this re-applies the current values through the likes/dislikes version gate.
; TOLERATED/CURSE cannot be represented by PDV_DeityBase's four integer values and project
; to FOREIGN here: generic deeds stay closed while quest reactions read the richer JSON label.
; NATIVE=0 FOREIGN=1 TABOO=2 HOSTILE=3; order Nord,Imp,Bret,Alt,Bos,Dun,Kha,Arg,Orc,Red.



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
    OriginRuntime.EmitBookOfDaysBroadLaneTierChange(today)
    if _dawnHadActivity
        AppendBookOfDaysEntry(BuildBookOfDaysDigestLine(), today, "dawn.digest", "journal", False)
    endIf
EndFunction

; --- P11 (2026-08-04): the recurring ambient layer -------------------------------------------
;
; Until now the mod's ONLY per-deity ambient line was Kyne's, and it lived inside the one-shot
; Champion reward presentation, so it fired once ever. A player who had held Champion for a year
; heard nothing further from the god they had held it with -- the late game went quiet exactly
; where it should have felt most settled.
;
; This is a slow dawn heartbeat: one line per surfacing deity every
; AMBIENT_CHAMPION_CADENCE_DAYS devotional days, alternating between two variants, with the
; second variant reserved for a deity actually carried PAST Champion so the voice deepens rather
; than repeating flat.
;
; Text only. No piety, no metric, no state change, nothing to farm: the MCM notification toggle
; gates it and the cadence stamp bounds it.

; The surfacing deity is the active patron -- the same scope RunDawnRefreshDevotionMarks uses for
; Long Devotion marks, so the ambient voice and the mark ladder always agree about whose season is
; being counted. A worshipper with no patron gets the heritage arm below instead.

; Returns False for a deity that ships no ambient records, so the cadence stamp is never spent on
; a surfacing that did not happen -- a deity given records later starts speaking immediately
; instead of waiting out a phantom cooldown.

; The heritage arm is deity-agnostic: it speaks for the inheritance every Altmer keeps, so it
; reaches a broad worshipper with no patron at all. The fall line is a one-shot on the transition
; DOWN rather than a cadence -- a player who slips out of the top band should hear that once, not
; every fourth day for the rest of the game.



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
        return "The ancestral record marks a turn in your discipline: " + modeLabel + "."
    elseIf originRace == ORIGIN_IMPERIAL
        return OriginRuntime.BuildImperialConcordatBookLine(modeLabel)
    elseIf originRace == ORIGIN_BRETON
        return "Your Breton road turns under the chosen tradition: " + modeLabel + "."
    endIf
    return "Your path turns. You walk now as: " + modeLabel + "."
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

; P18 (2026-08-04) -- THE DAWN NOW BELONGS TO THE SPINE, NOT TO AURI-EL.
;
; This used to award +2.0 Auri-El piety gated on origin and curse ONLY: no act, no presence, no
; shrine. It fired for a sleeping player who did nothing, at net +1.5/day against decay, which
; carried every Altmer to Auri-El Champion in ~8 weeks of simply existing -- and made him
; out-rank a committed Trinimac or Syrabane patron on every ranked surface, for free.
;
; The owner's design call: keeping the dawn is the ORDERED LIFE every Altmer keeps because they
; are Altmer, not worship of one god. So it feeds the deity-agnostic ancestral spine. Auri-El
; keeps his own renewable -- the shrine rite, +2.0/day via AwardShrinePrayerToDeityName, on any
; vanilla Shrine of Akatosh. That is the right asymmetry: directed worship of a specific god costs
; you a trip to his shrine; keeping the dawn costs only doing it.
;
; This supersedes PDV_RaceDesign_Altmer.md lines 42-43 ("Dawn sun acknowledgment generates piety"),
; updated in the same change. It does NOT contradict the 2026-07-13 substrate addendum: that
; forbids "PASSIVE dawn" granting the cultural metric, and explicitly allows an accepted RITE to.
; An act-gated observance is a rite.
;
; Costs no income: the substrate is capped at one +4.0 credit per devotional day whatever claims it.

; P5 (2026-08-03): Xarxes's renewable curated lane, modelled on the Auri-El dawn above.
;
; This is a CADENCE, not an act reward. Xarxes's distinction from Magnus is the record kept over
; TIME, not the act itself -- so the beat is "you studied yesterday, and the ledger noted it."
; That shape is renewable forever, is capped at exactly one per devotional day by construction
; (two independent stamps), and lands under Auri-El's 2.0 so the foundation stays the foundation.
;
; Before this, Xarxes was table-only: SIGNAL_LINEAGE_HONORED is bounded by three curated books and
; SHARED_PACT_MEMORY requires him as the active patron, so a non-patron follower had no curated
; income whatsoever once those books were read.













Int Function GetDebugLevel()
    if LedgerRuntime.PDV_GLO_DebugLevel
        return LedgerRuntime.PDV_GLO_DebugLevel.GetValueInt()
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
        LedgerRuntime.ForceSetActiveDeityByIndex(deityIndex)
    elseIf commandId == 4
        LedgerRuntime.ForceSetPietyToday(amount)
    elseIf commandId == 5
        LedgerRuntime.ProcessDawn()
    elseIf commandId == 6
        LedgerRuntime.ForceSetPiety(amount)
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
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
    _panelDirty = False
    DebugClosePrismaSurfaces()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Debug reward sync complete.")
    endIf
EndFunction

Bool Function IsDebugDeityTargetEligible(PDV_DeityBase deity, String actionName = "debug action")
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] " + actionName + " rejected: no deity target.")
        endIf
        return False
    endIf
    if !LedgerRuntime.IsDeityReachableForCurrentOrigin(deity)
        Debug.Trace("[PDV] " + actionName + " blocked for " + deity.DeityName + ": deity is not reachable for the current origin.")
        return False
    endIf
    return True
EndFunction




Function DebugForceSetPietyByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !IsDebugDeityTargetEligible(deity, "DebugForceSetPietyByIndex")
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", PDV_DevotionRules.ClampValue(amount, 0.0, LedgerRuntime.PIETY_MAX))
    ; Surface the tier change so a debug-forced tier reach is testable (notice + toast +
    ; Book of Days entry). Only fires on an UP-crossing from a lower tier -- if the deity
    ; is already at/above the target, reset it first, or use the piety-today + dawn path.
    LedgerRuntime.RecomputeTier(deity, True)
    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT && OriginRuntime.GetKhajiitFocusForDeity(deity) != KHAJIIT_FOCUS_NONE
        OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    endIf
    ; Resync the race reward family so a focused/emphasis reward (Khajiit emphasis, an
    ; Imperial/Altmer focused patron, etc.) actually grants on the seed. RecomputeTier only
    ; fires OnTierChange (Boon slots), not SyncFirstTierRaceRewardRuntime -- without this a
    ; debug piety seed reads a false 0 on the HP bar until a dawn pass.
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
EndFunction

Function DebugForceSetPietyTodayByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyTodayByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !IsDebugDeityTargetEligible(deity, "DebugForceSetPietyTodayByIndex")
        return
    endIf

    StorageUtil.SetFloatValue(deity as Form, "PDV.PietyToday", amount)
EndFunction

Function DebugPrimeDecayGraceByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayGraceByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !IsDebugDeityTargetEligible(deity, "DebugPrimeDecayGraceByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", LedgerRuntime.GetDevotionalDay() + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    LedgerRuntime.RecomputeTier(deity)
    Trace(1, "Decay grace primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugPrimeDecayEligibleByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugPrimeDecayEligibleByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !IsDebugDeityTargetEligible(deity, "DebugPrimeDecayEligibleByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - LedgerRuntime.DECAY_GRACE_DAYS - 1.0)
    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", LedgerRuntime.GetDevotionalDay() + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)
    LedgerRuntime.RecomputeTier(deity)
    Trace(1, "Decay eligible primed for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugRunDecayPass()
    LedgerRuntime.RunDawnApplyDecay()
    Trace(1, "Decay pass debug run.")
EndFunction

Function DebugRunDecayProofDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugRunDecayProofDaysByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf
    if !IsDebugDeityTargetEligible(deity, "DebugRunDecayProofDaysByIndex")
        return
    endIf

    Form deityForm = deity as Form
    Float nowTime = Utility.GetCurrentGameTime()
    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        StorageUtil.SetFloatValue(deityForm, "PDV.Piety", 20.0)
    endIf
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", nowTime - LedgerRuntime.DECAY_GRACE_DAYS - 1.0)
    LedgerRuntime.RecomputeTier(deity)

    Int i = 0
    while i < 400
        currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
        Float floorValue = LedgerRuntime.GetDecayFloorForDeity(deity, currentPiety)
        if currentPiety <= floorValue
            i = 400
        else
            StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", ((nowTime + i) as Int) - 1)
            LedgerRuntime.ApplyDecayToDeity(deity, nowTime + i)
        endIf
        i += 1
    endWhile
    Trace(1, "Decay proof days run for " + deity.DeityName + ": " + DebugGetDecaySummaryByIndex(deityIndex))
EndFunction

Function DebugAwardCuratedSignalByIndex(Int deityIndex, Int signalType)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !IsDebugDeityTargetEligible(deity, "DebugAwardCuratedSignalByIndex")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalByIndex(deityIndex, signalType)
EndFunction

String Function DebugGetPietyMapString()
    if !LedgerRuntime.PDV_FLST_AllDeities
        return "No deity roster is assigned."
    endIf

    Int i = 0
    Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    String output = ""
    Int shown = 0

    ; Only list deities that have moved (stored piety, scratch piety, or a tier), so the
    ; message box stays short and readable instead of dumping the whole roster at zero.
    while i < count
        PDV_DeityBase deity = LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float piety = LedgerRuntime.GetPiety(deity)
            Float today = LedgerRuntime.GetPietyToday(deity)
            Int tier = LedgerRuntime.GetTier(deity)
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
    if LedgerRuntime.IsUnsafeFaultInjectionActive()
        LedgerRuntime.ClearUnsafeFaultInjection()
        return
    endIf

    LedgerRuntime.SetActiveDeity(None)
    ; Strip the now-unfocused patron's reward spells immediately (same dawn-lag class
    ; as ForceSetActiveDeityByIndex).
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
EndFunction

Function DebugSetBroadWorship()
    LedgerRuntime.SetBroadWorship()
EndFunction

; Debug: seed the player's race broad-worship lane to its T2 reward so the reward/UI
; surface is testable. Imperial uses the manager-owned broad-pantheon pool directly;
; frozen migration counters are never written. Breton seeds its separate active
; tradition to 50 practice points. This is not pacing proof.
Function DebugSeedBroadLane()
    LedgerRuntime.SetBroadWorship()
    Int origin = GetPlayerOriginRaceIndex()
    if origin == ORIGIN_IMPERIAL
        LedgerRuntime.SetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_IMPERIAL, LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD, "debug_seed_broad_lane")
    elseIf origin == ORIGIN_BRETON
        OriginRuntime.SetBretonPracticeCount(OriginRuntime.GetBretonTraditionValue(), BRETON_PRACTICE_DEVOTED_POINTS)
    elseIf origin == ORIGIN_ORC
        StorageUtil.SetIntValue(None, "PDV.Orc.MalacathSourceCount", 6)
    elseIf origin == ORIGIN_ALTMER
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count", 6)
        StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count", 6)
    else
        Trace(1, "DebugSeedBroadLane: origin " + origin + " has no broad-lane accumulator wired here (Nord/others not yet covered).")
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    Trace(1, "DebugSeedBroadLane seeded broad lane for origin " + origin + ".")
EndFunction

String Function DebugGetBretonPracticeSummary()
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return "Breton practice controls require Breton origin."
    endIf

    Int traditionValue = OriginRuntime.GetBretonTraditionValue()
    Int practicePoints = OriginRuntime.GetBretonPracticeCount(traditionValue)
    Int today = LedgerRuntime.GetDevotionalDay() + 2
    Int pointDay = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointDay", -1)
    Int pointsToday = 0
    if pointDay == today
        pointsToday = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointsToday")
    endIf
    pointsToday = PDV_DevotionRules.ClampInt(pointsToday, 0, BRETON_PRACTICE_DAILY_MAX_POINTS)
    Int remainingToday = BRETON_PRACTICE_DAILY_MAX_POINTS - pointsToday
    return OriginRuntime.GetBretonTraditionLabel() + ": " + practicePoints + "/" + BRETON_PRACTICE_DEVOTED_POINTS + " practice points (" + GetPublicTierBand(OriginRuntime.GetBretonPracticeTier(traditionValue)) + "). Today: " + pointsToday + "/" + BRETON_PRACTICE_DAILY_MAX_POINTS + "; remaining " + remainingToday + "."
EndFunction

String Function DebugSetBretonPracticePoints(Int practicePoints)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return "Breton practice target ignored: set Breton origin first."
    endIf

    Int traditionValue = OriginRuntime.GetBretonTraditionValue()
    OriginRuntime.SetBretonPracticeCount(traditionValue, practicePoints)
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointDay", LedgerRuntime.GetDevotionalDay() + 2)
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", 0)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    Trace(1, "DebugSetBretonPracticePoints: tradition " + traditionValue + " -> " + PDV_DevotionRules.ClampInt(practicePoints, 0, BRETON_PRACTICE_DEVOTED_POINTS) + ".")
    return DebugGetBretonPracticeSummary()
EndFunction

String Function DebugAddBretonPracticePoints(Int requestedPoints)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return "Breton practice pulse ignored: set Breton origin first."
    endIf
    if requestedPoints != BRETON_PRACTICE_RENEWABLE_POINTS && requestedPoints != BRETON_PRACTICE_CURATED_POINTS
        return "Breton practice pulse ignored: debug weight must be +1 or +2."
    endIf

    Int sequence = StorageUtil.GetIntValue(None, "PDV.Debug.BretonPracticePulseSeq") + 1
    StorageUtil.SetIntValue(None, "PDV.Debug.BretonPracticePulseSeq", sequence)
    Bool applied = OriginRuntime.AwardBretonPracticePulse(OriginRuntime.GetBretonTraditionValue(), requestedPoints, "mcm_debug_" + sequence, "mcm-debug-practice")
    if !applied
        return "No practice points applied. " + DebugGetBretonPracticeSummary()
    endIf
    return DebugGetBretonPracticeSummary()
EndFunction

String Function DebugResetBretonPracticePoints()
    String summary = DebugSetBretonPracticePoints(0)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return summary
    endIf
    return "Practice points and today's debug budget reset. " + summary
EndFunction

String Function DebugGetOriginDiagnostic()
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") == 1
        return "Custom race fallback: Imperial"
    endIf

    return "No custom race fallback"
EndFunction

Function DebugResetDeityByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
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
    StorageUtil.SetFloatValue(deityForm, "PDV.Tier", LedgerRuntime.TIER_NONE as Float)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", 0.0)

    if deity == _activeDeity
        deity.OnTierChange(oldTier, LedgerRuntime.TIER_NONE)
        LedgerRuntime.RefreshPatronMirrors()
    endIf
    if GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        OriginRuntime.EvaluateKhajiitFocusedEmphasis()
        OriginRuntime.SyncKhajiitRuntimeState()
    endIf
EndFunction

;/ =====================================================================
    B6 / C5 / fix-plan 7.1 -- the scope clobber and the 100 Hz spin
    ---------------------------------------------------------------------
    WAS: a second concurrent logical act spin-waited on WaitMenuMode(0.01) -- a
    100 Hz busy loop -- for up to two real seconds, and then FORCE-CLEARED the
    first act's live scope and installed its own. Both acts lost: the first
    thread's remaining Accumulate* calls landed in the second act's scope, and
    the first thread's Flush then cleared the second act's scope before it had
    committed. Silent piety mis-attribution whenever two acts landed close
    together (a quest stage during a book read is the everyday case).

    NOW: no spin, and never a clobber. A second act that arrives while one is
    live is CONTAINED as a nested depth of the live scope -- the same mechanism
    JoinBroadPantheonEvent already uses for a declared parent/child act, and
    which FlushBroadPantheonEvent already unwinds correctly (depth > 1
    decrements; only the outermost commits). Both acts' deltas aggregate into
    one broad-lane entry under the outer act's id instead of corrupting each
    other, and a delta for a deity ineligible for the outer act's pool is
    dropped by AccumulateBroadPantheonDelta's existing eligibility gate rather
    than being credited to the wrong pool.

    Why containment and not the fix plan's deferral-queue: deferring means
    Begin returns WITHOUT the scope while its caller runs on to its paired
    Accumulate* and Flush -- and Papyrus gives a script no way to tell which
    stack an Accumulate belongs to, so those deltas would land in the live
    scope anyway. Routing them correctly means passing the logical event id
    through every Accumulate call site, which is exactly the per-event keyed
    scope the fix plan itself set aside as the invasive option. Containment
    gets the whole benefit of the cheap fix (no spin, no clobber, no lost
    scope) with none of that reach.

    Removing the spin also has a second-order effect worth recording: the spin
    was the one latent call on the story-event -> router -> award chain, so
    that chain is only NOW actually synchronous. See the Pass 4 changelog note
    on 7.2 for why that still does not make the SM receivers safe to change.
   ===================================================================== /;




; Generic non-presented actions can spend several seconds scoring the full deity
; roster. Their broad result is carried in caller-local variables so that work
; never owns the Manager's shared temporary scope across the fan-out.




























; Manager-owned daily stamps use the same zero-reserved encoding as substrates.
; Existing +1 stamps are migrated once per key through a sibling encoding flag.


























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
    if !LedgerRuntime.IsGenericLikesDislikesDeityReachable(deity)
        Trace(1, "DebugFireDislike: " + deity.DeityName + " is not reachable in the current origin/baseline.")
        return
    endIf
    Float delta = LedgerRuntime.GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        Trace(1, "DebugFireDislike: no dislike row for " + deity.DeityName + " event " + eventType)
        return
    endIf
    Int domainValue = LedgerRuntime.DomainForDeity(deity)
    if domainValue != LedgerRuntime.DISFAVOR_DOMAIN_NONE
        StorageUtil.SetIntValue(deity as Form, LedgerRuntime.GetDisfavorRepeatDayKey(domainValue, eventType), -1)
    endIf
    Bool nativeSurface = LedgerRuntime.ShouldSurfaceLikesDislikesEvent(eventType)
    LedgerRuntime.AwardPietyFromLikesDislikes(deity, delta, eventType, "debug_fire_dislike")
    if !nativeSurface
        LedgerRuntime.SurfaceDebugDislikeEvent(deity, delta, eventType)
    endIf
    Trace(1, "DebugFireDislike: " + deity.DeityName + " event " + eventType + " delta " + delta)
EndFunction

; Directly add a domain sting spell + register its expiry the same way
; ApplyDisfavorSting does, so the eyeball check uses the real spell + real expiry.
; Bypasses the standing/repeat/cap gates on purpose (raw MGEF inspection).
Function DebugApplyDomainSting(Int domainValue, Bool sharp)
    LedgerRuntime.ApplyDebugDomainSting(domainValue, sharp, False)
EndFunction

; Shared core for the debug sting apply. respectCap reproduces ApplyDisfavorSting's
; active-domain cap so DebugBurstAntiStack can demonstrate the 4th distinct domain
; is suppressed at the cap. Returns True when the sting was applied.

; Clear first, then fire 4 distinct-domain stings (Sky, Death, War, Order) with the
; cap respected, so the tester sees 3 active and the 4th suppressed at the cap.
Function DebugBurstAntiStack()
    LedgerRuntime.ClearAllDisfavorStings()
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_SKY_STORM_HUNT, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_DEATH_ANCESTORS, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_WAR_HONOR, True, True)
    LedgerRuntime.ApplyDebugDomainSting(LedgerRuntime.DISFAVOR_DOMAIN_ORDER_TRADE_LORE, True, True)
    Trace(1, "DebugBurstAntiStack: " + LedgerRuntime.GetActiveDisfavorSummary())
EndFunction

; One-line readout of every active disfavor domain with its band + remaining
; game-minutes; "none" when empty. Clears expired stings first so the count is live.

; Remove every active disfavor spell + clear its active/expiry/band keys, reusing
; the runtime's own ClearDisfavorDomain so the removal path matches expiry cleanup.

; Debug label helper: does the selected deity dislike this event, at what delta,
; into which domain? Lets the MCM button hint tell the tester whether a fire will land.
String Function DebugDislikeSummaryLine(PDV_DeityBase deity, Int eventType)
    if !deity
        return "event " + eventType + " | no deity"
    endIf
    if !LedgerRuntime.IsGenericLikesDislikesDeityReachable(deity)
        return "event " + eventType + " | " + deity.DeityName + " | not current pantheon"
    endIf
    Float delta = LedgerRuntime.GetDislikeBaseDeltaForEvent(deity, eventType)
    if delta >= 0.0
        return "event " + eventType + " | " + deity.DeityName + " | no dislike row"
    endIf
    return "event " + eventType + " | " + deity.DeityName + " | " + delta + " -> " + LedgerRuntime.GetDisfavorDomainLabel(LedgerRuntime.DomainForDeity(deity))
EndFunction

; Per-deity recent-driver ring (the acts that recently moved this god), keyed on the
; deity form, capped at 6 FIFO. Powers the dashboard's "recent drivers".

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
    if PDV_DevotionRules.StringContainsToken(raw, "meta_zen_wage")
        return "a quest paid in gold"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_julianos_wisdom")
        return "a mage-aid quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_azura_threshold")
        return "a quest at twilight or aiding mages"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_nocturnal_herway")
        return "a quest done after stealing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_nocturnal_dark")
        return "a quest done at night"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_khenarthi_road")
        return "a quest finished outdoors"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_akatosh_wheel")
        return "every tenth quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_xarxes_record")
        return "every tenth quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "wayfarer_akatosh_level")
        return "leveling up under Wayfarer's Path"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos-shrine-defiance")
        return "defiant prayer at a Talos shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos_betrayal_major")
        return "turning on Talos openly"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos_betrayal_compliance")
        return "bending to the Talos ban"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-talos-pressure")
        return "Concordat pressure over Talos"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "concordat-compliance")
        return "complying with the Concordat"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "concordat-defiance")
        return "defying the Concordat"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-patron-civic-favor")
        return "civic service (patron bonus)"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-civic-service")
        return "civic service"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-old-ways-state")
        return "keeping the Old Ways"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-kyne-talos-context")
        return "the Old Ways beside Talos"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-hircine-arkay-edge")
        return "the hunt at Arkay's edge"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "sleep-moon-observance")
        return "sleeping under aligned moons"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-road-home")
        return "returning by the road home"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-baandar-road-trick")
        return "a trick on the road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-rajhin-elegant-theft")
        return "an artful theft"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-alkosh-dragon-order")
        return "keeping dragon order"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "hircine-hunt-rite")
        return "a ritual hunt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "green-pact-violation")
        return "breaking the Green Pact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-old-contract-proper-hunt")
        return "a proper hunt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-old-contract-forest-kept")
        return "keeping the forest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story-community")
        return "sharing the living story"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story-nature-site")
        return "a tale at a wild place"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story")
        return "a Living Story deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange-debt-settled")
        return "settling a debt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange-proportionate-vengeance")
        return "measured vengeance"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange")
        return "an Exchange deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road-road-life")
        return "living the road life"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road-reversal")
        return "a reversal on the road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road")
        return "a Bandit Road deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-pact-positive")
        return "keeping the Green Pact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-portable-shrine")
        return "prayer at your portable shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-home-bonus")
        return "devotions kept at home"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-reclamation-focus")
        return "focus on the Reclamations"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-deviation-price")
        return "straying from the Reclamations"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-lorkhan-pressure")
        return "leaning toward Lorkhan"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-crisis-source")
        return "feeding the crisis of faith"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-dawn-steadiness")
        return "steadiness at dawn"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-orthodox-cost")
        return "the cost of orthodoxy paid"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-hist-maintenance")
        return "tending the Hist bond"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-people-support")
        return "supporting the People"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-void-signal")
        return "a step toward the Void"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-bed-of-choice")
        return "rest in your chosen bed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-stronghold-forge")
        return "forge work in a stronghold"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-city-dignity")
        return "dignity kept in city life"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-legion-service")
        return "service with the Legion"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-self-made-community")
        return "building a community"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-oath-break")
        return "breaking an oath"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-four-holds-visit")
        return "visiting the four holds"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-crown-tomb-respect")
        return "respect at a Crown tomb"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-forebear-road")
        return "walking the Forebear road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-ashabah-death-duty")
        return "putting down the risen dead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-far-shores-token")
        return "a Far Shores token earned"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-tradition-choice")
        return "choosing a tradition"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-knightly-vow")
        return "keeping a knightly vow"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-hidden-art-exposure")
        return "a hidden art exposed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-green-way-standing")
        return "standing with the Green Way"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "state-transition-confirm-rite")
        return "a rite confirming your path"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "daedric-prince-signal")
        return "a deed the Prince claims"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "daedric-generic-silence")
        return "silence from the Princes"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shout-to-open-sky")
        return "a shout to the open sky"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "rest-under-open-sky")
        return "resting under the open sky"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "sleep-in-bed")
        return "sleeping in a bed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "take-blessing")
        return "taking a shrine blessing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Trial of Iron")
        return "taking up the Trial of Iron"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Remembering of Names")
        return "taking up the Remembering of Names"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Discipline of Return")
        return "setting a Discipline of Return"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "cc_fishing")
        return "fishing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "commitment_carryover")
        return "devotion carried into commitment"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "rivalry with")
        return raw
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-skill-book")
        return "reading instructive texts"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-spell-tome")
        return "reading a spell tome"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-lore-book")
        return "reading a lore book"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "po3_book") || PDV_DevotionRules.StringContainsToken(raw, "book")
        return "reading a book"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "increase-skill")
        return "honing your skills"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "discover-location")
        return "discovering new roads"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "learn-word-of-power")
        return "learning a Word of Power"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shout") || PDV_DevotionRules.StringContainsToken(raw, "voice")
        return "using a shout"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shrine") || PDV_DevotionRules.StringContainsToken(raw, "prayer") || PDV_DevotionRules.StringContainsToken(raw, "pray")
        return "prayer at a shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "harvest-ingredient")
        return "harvesting ingredients"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "brew-potion")
        return "brewing potions"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "smith-item")
        return "smithing an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "enchant-item")
        return "enchanting an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "cook-meal")
        return "cooking a meal"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "mine-or-chop")
        return "mining or woodcutting"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-daedra")
        return "killing Daedra"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-undead")
        return "killing undead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-dragon")
        return "killing a dragon"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "killed-hostile-beast")
        return "killing hostile beasts"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "killed-hostile-humanoid")
        return "killing hostile people"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-animal-noncombat")
        return "killing harmless animals"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "murder-defenseless")
        return "murdering the defenseless"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "assault-innocent")
        return "assaulting an innocent"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill") || PDV_DevotionRules.StringContainsToken(raw, "combat") || PDV_DevotionRules.StringContainsToken(raw, "hunt")
        return "combat or hunting kills"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "heal-or-cure-npc")
        return "healing or curing someone"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "clear-bounty")
        return "paying off a bounty"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "pick-owned-lock")
        return "picking an owned lock"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "trespass")
        return "trespassing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "steal-item")
        return "stealing an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "pickpocket")
        return "pickpocketing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "raise-undead")
        return "raising undead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "vampire-feed")
        return "feeding as a vampire"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "accept-daedric-artifact")
        return "accepting a Daedric artifact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "quest")
        return "completing a quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "curated") || PDV_DevotionRules.StringContainsToken(raw, "rite")
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
        endIf
    elseIf PDV_AuriEl && deity == PDV_AuriEl
        if signalType == PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT
            return "dawn observance"
        elseIf signalType == PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION
            return "orthodox lore study"
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
    elseIf LedgerRuntime.PDV_Zen && deity == LedgerRuntime.PDV_Zen
        if signalType == LedgerRuntime.PDV_Zen.SIGNAL_EXCHANGE
            return "fair exchange"
        elseIf signalType == LedgerRuntime.PDV_Zen.SIGNAL_CONFIRMATION
            return "a rite confirming your path"
        elseIf signalType == LedgerRuntime.PDV_Zen.SIGNAL_SHARED_PACT_MEMORY
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
        elseIf signalType == PDV_Magnus.SIGNAL_SHARED_PACT_MEMORY
            return "keeping faith with the arts"
        endIf
    elseIf PDV_Xarxes && deity == PDV_Xarxes
        if signalType == PDV_Xarxes.SIGNAL_LINEAGE_HONORED
            return "honoring lineage"
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
    elseIf LedgerRuntime.PDV_Akatosh && deity == LedgerRuntime.PDV_Akatosh
        if signalType == LedgerRuntime.PDV_Akatosh.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == LedgerRuntime.PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Mara && deity == LedgerRuntime.PDV_Mara
        if signalType == LedgerRuntime.PDV_Mara.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == LedgerRuntime.PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Arkay && deity == LedgerRuntime.PDV_Arkay
        if signalType == LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY
            return "death duty"
        elseIf signalType == LedgerRuntime.PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Stendarr && deity == LedgerRuntime.PDV_Stendarr
        if signalType == LedgerRuntime.PDV_Stendarr.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == LedgerRuntime.PDV_Stendarr.SIGNAL_LAWFUL_ORDER
            return "upholding law and order"
        elseIf signalType == LedgerRuntime.PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Zenithar && deity == LedgerRuntime.PDV_Zenithar
        if signalType == LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK
            return "honest work"
        elseIf signalType == LedgerRuntime.PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Julianos && deity == LedgerRuntime.PDV_Julianos
        if signalType == LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf LedgerRuntime.PDV_Kynareth && deity == LedgerRuntime.PDV_Kynareth
        if signalType == LedgerRuntime.PDV_Kynareth.SIGNAL_OPEN_SKY
            return "deeds under the open sky"
        elseIf signalType == LedgerRuntime.PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR
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
        if signalType == PDV_Shor.SIGNAL_HONORED_DEAD
            return "honoring the dead"
        endIf
    elseIf LedgerRuntime.PDV_Dibella && deity == LedgerRuntime.PDV_Dibella
        if signalType == LedgerRuntime.PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR
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
Bool _pdvSurvivalModePresent = False
Bool _pdvSunHelmPresent = False








String Function GetSurvivalContextStatusLine()
    LedgerRuntime.InitSurvivalContext()

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

    if !LedgerRuntime.IsSurvivalContextEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | " + PDV_DevotionRules.SeverityLabel(LedgerRuntime.GetSurvivalContextSeverity())
EndFunction

;/ =====================================================================
    Creation Club / AE compatibility (SOFT OPTIONAL)
    ---------------------------------------------------------------------
    Optional, encouraged-not-required integration for supported Creation Club
    content. Detection is by filename, optional forms are cached once, and no
    Devotion.esp record takes a hard dependency on the CC masters.
    Form evidence: references/authoring/PDV_CCIntegration_Findings.md
   ===================================================================== /;
Bool _pdvCCSaintsPresent = False
Bool _pdvCCFishingPresent = False






String Function GetCCContentStatusLine()
    LedgerRuntime.InitCCContent()

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

    if !LedgerRuntime.IsCCContentEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | integration on"
EndFunction





























; Unified model (2026-07-13): the tradition family grants T1/T2 practice tiers.
; A Champion boon that reuses this tradition's own T3 record replaces T2 because
; the T3 effects are absolute cumulative totals. A distinct patron boon remains
; beside T2 as the second family.



; Unified model (2026-07-13): the active Champion patron brings their OWN
; champion boon, resonant or not. Exactly one is active at a time; every other
; Breton champion boon strips. Resonance selects the presentation line only.

; Grants wantSpell and strips every other Breton champion boon. Stendarr/Y'ffre/
; Daedric reuse the former tradition-T3 records; the nine below are the authored
; per-deity copies. SyncRaceRewardSpell no-ops on a None property, so an unbuilt
; record is safe.

; Maps an active Champion patron to their Breton champion boon. Stendarr and
; Y'ffre reuse the tradition capstones they always were; a Daedric Hidden Art
; patron gets the occult practitioner cap (the prince's own reward flows through
; the 20C pact); the rest get their authored per-deity copy.





; Breton two-axis model: tradition practice earns T1/T2 by count; an active
; Champion patron only lifts the tradition to T3 if that patron resonates with
; the chosen tradition. Non-resonant Champion patrons grant PatronChampion.
; Unified model (2026-07-13): the tradition tier is the PRACTICE tier and caps at
; Devoted (T2). Champion is a patron property (SyncBretonChampionBoon), no longer
; a tradition tier, so the old resonant->CHAMPION shortcut is gone.







































; Malacath creed-violation minus: werewolf onset is a Code rupture (the beast-blood
; cools Malacath's regard). Hooked from ApplyOrcCurseHandlers on a transition INTO the
; werewolf state; Orc-gated and anti-farmed (curse flicker cannot stack the penalty).

; Malacath creed-violation minus: deserting sworn service. Hooked from
; ApplyOrcLifeModeSwitch on a PLAYER-DRIVEN switch away from Legion-Exile (the sworn-
; service life mode). The passive 14-day dawn lapse-to-City routes through SetState
; directly, NOT this switch path, so neglect-drift does not trip the betrayal penalty.

; Mephala creed-violation minus: a clumsy crime (caught trespassing / assaulting an
; innocent) is the opposite of Mephala's subtlety -- a kept secret carelessly exposed.
; Dunmer-gated and only while the active Reclamation focus is Mephala (focus 2);
; anti-farmed so a string of same-day crimes does not stack the loss linearly.

; Hist creed-violation minuses (curated medium/major only, per PDV_Deity_Hist), keyed to
; the substrate posture model: drifting Distant past grace is abandonment; domination-
; driven Corrupted posture is corruption; deep Void leaning (>=3 signals) while Hist has
; lapsed below the non-curse floor is Void overreach. Argonian-gated, anti-farmed.






; Grants the focused Khajiit emphasis's 3-tier reward set based on that emphasis deity's piety
; tier; clears every non-focused emphasis set (one active emphasis at a time).


; Gentle lunar neglect: the moons/road go quiet when no lunar source has fired within the grace
; window. Mechanical bite stays reserved for Corrupted/ShadowDrift posture elsewhere.


; --- Argonian (substrate / no-offer) reward spine. Mirrors the Khajiit no-offer pattern but
; gates on the PDV_Substrate_ArgonianHist relations rather than an emphasis deity's piety:
;   * Hist broad set (T1/T2/signature) gates on the Hist relation reaching its threshold.
;   * People is the single focused 3-tier set (T1/T2/T3 Champion), gated on People-focus state.
;   * Sithis is the high-threshold tertiary (T1/T2), gated on the Void being fully active.
; Only ONE foreground support emphasis runs at a time (People OR Void), like the Khajiit
; one-active-emphasis cap; People is the default and Void only competes once fully active.

; Resolves the single active foreground support emphasis (People vs Void). People is the default;
; Void only competes once fully active and only when its relation leads People (one-active cap).

; Gentle Hist-distance neglect: the Hist goes quiet when no accepted Hist source has fired within
; the grace window. Mechanical bite is reserved for posture Silenced/Corrupted (per the spec);
; this guard keeps the spell from biting outside those postures even past the grace window.








; Broad-worship floor eligibility: the origin's first-tier reward also grants to a BROAD
; worshipper, not only an active patron. Mirrors the active path's "earned Seeker before the
; floor" by gating on the same accumulated-service count the Faithful (T2) reward uses;
; Seeker-equivalent = 3 acts (half the Faithful gate of 6). Nord's broad T1 is part of this
; shared floor helper too; the old runtime excluded it by mistake even though the reward spec
; and manager property already expose PDV_Bless_Nord_OldWays_T1 as the broad first tier.

; Accumulated broad-worship service count for the origin's broad lane -- the same accumulator
; the Faithful/T2 reward gates on at >= 6. Altmer sums its two favor counters; Nord uses the
; Old Ways broad-state counter that already drives the broad-T2 lane.














Function PrepareForUninstall()
    Actor playerRef = Game.GetPlayer()

    ; A1 / fix-plan 11.2: stripping the abilities does not undo the actor-value drift
    ; their no-Recover value modifiers baked into the save, so run the stat repair
    ; FIRST -- it strips the spells itself, corrects what it can, and re-syncs. What it
    ; leaves behind is reported by the MCM "Repair stats" button.
    RunAuthoriaActorValueRepair(True, False)

    ; Substrate quests own their boon spells. The generic strip below cannot
    ; reliably remove records that are bound only on those quest scripts, so
    ; ask every substrate owner to clear its own tier slots before storage is
    ; erased and the manager stops.
    ClearAllSubstrateBoonsForUninstall()

    StripAllPdvSpells(playerRef)

    if playerRef
        if LedgerRuntime.NecromancerFaction
            playerRef.RemoveFromFaction(LedgerRuntime.NecromancerFaction)
        endIf
        if LedgerRuntime.WarlockFaction
            playerRef.RemoveFromFaction(LedgerRuntime.WarlockFaction)
        endIf
    endIf

    ClearPdvStorageNamespaces()
    UnregisterForUpdate()
    Debug.MessageBox("Devotion has repaired its permanent stat damage, then removed its spells, factions, and most of its saved data. The stat repair ran FIRST and zeroed the permanent modifier on every actor value Devotion could touch (magic/damage/disease/frost/fire/poison resistance, carry weight, speed, health, magicka, stamina and the weapon, magic and stealth skills) - note this also clears any permanent modifier another mod had placed on those same values, which is rare but real. You may now exit to the main menu, remove the mod, and load this save. This is BEST EFFORT and not a guaranteed clean save; some inert leftover data can remain. The only fully clean removal is to load a save made before Devotion was installed.")
    Self.Stop()
EndFunction

Function ClearAllSubstrateBoonsForUninstall()
    if PDV_ImperialAncestorSubstrate
        PDV_ImperialAncestorSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_BretonAncestorSubstrate
        PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_AltmerAncestorSubstrate
        PDV_AltmerAncestorSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_NordAncestorSubstrate
        PDV_NordAncestorSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_DunmerAncestorSubstrate
        PDV_DunmerAncestorSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_KhajiitLunarSubstrate
        PDV_KhajiitLunarSubstrate.ClearSubstrateBoons()
    endIf
    if PDV_ArgonianHistSubstrate
        PDV_ArgonianHistSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function ClearPdvStorageNamespaces()
    Int clearedCount = StorageUtil.ClearAllPrefix("PDV.")
    Trace(1, "PrepareForUninstall: cleared StorageUtil PDV prefix count " + clearedCount)
EndFunction

Function StripAllPdvSpells(Actor playerRef)
    if !playerRef
        return
    endIf

    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_SurveyDevotion, False, "PDV_SPEL_SurveyDevotion")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Kyne, False, "PDV_SPEL_Neglect_Kyne")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_SkyStormHunt_Light, False, "PDV_SPEL_Disfavor_SkyStormHunt_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_SkyStormHunt_Sharp, False, "PDV_SPEL_Disfavor_SkyStormHunt_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_DeathAncestors_Light, False, "PDV_SPEL_Disfavor_DeathAncestors_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_DeathAncestors_Sharp, False, "PDV_SPEL_Disfavor_DeathAncestors_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_MercyProtection_Light, False, "PDV_SPEL_Disfavor_MercyProtection_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_MercyProtection_Sharp, False, "PDV_SPEL_Disfavor_MercyProtection_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_WarHonor_Light, False, "PDV_SPEL_Disfavor_WarHonor_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_WarHonor_Sharp, False, "PDV_SPEL_Disfavor_WarHonor_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_OrderTradeLore_Light, False, "PDV_SPEL_Disfavor_OrderTradeLore_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_OrderTradeLore_Sharp, False, "PDV_SPEL_Disfavor_OrderTradeLore_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MoonLuckShadow_Light, False, "PDV_SPEL_Disfavor_MoonLuckShadow_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Disfavor_MoonLuckShadow_Sharp, False, "PDV_SPEL_Disfavor_MoonLuckShadow_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_VoidSecrets_Light, False, "PDV_SPEL_Disfavor_VoidSecrets_Light")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, LedgerRuntime.PDV_SPEL_Disfavor_VoidSecrets_Sharp, False, "PDV_SPEL_Disfavor_VoidSecrets_Sharp")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery, False, "PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Kyne_StormRoadGrace, False, "PDV_SPEL_Favor_Kyne_StormRoadGrace")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Kyne_GuidedHunt, False, "PDV_SPEL_Favor_Kyne_GuidedHunt")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Kyne_WindMarkedPassage, False, "PDV_SPEL_Favor_Kyne_WindMarkedPassage")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance, False, "PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal, False, "PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense, False, "PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet, False, "PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance, False, "PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace, False, "PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty, False, "PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy, False, "PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft, False, "PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine, False, "PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness, False, "PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, FavorRuntime.PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement, False, "PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T1, False, "PDV_Bless_Altmer_Orthodox_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Orthodox_T2, False, "PDV_Bless_Altmer_Orthodox_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T1, False, "PDV_Bless_Altmer_AuriEl_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T2, False, "PDV_Bless_Altmer_AuriEl_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_AuriEl_T3, False, "PDV_Bless_Altmer_AuriEl_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T1, False, "PDV_Bless_Altmer_Magnus_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T2, False, "PDV_Bless_Altmer_Magnus_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Magnus_T3, False, "PDV_Bless_Altmer_Magnus_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T1, False, "PDV_Bless_Altmer_Xarxes_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T2, False, "PDV_Bless_Altmer_Xarxes_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Xarxes_T3, False, "PDV_Bless_Altmer_Xarxes_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_Always, False, "PDV_Bless_Altmer_Spine_Always")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_Mid, False, "PDV_Bless_Altmer_Spine_Mid")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Altmer_Spine_High, False, "PDV_Bless_Altmer_Spine_High")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Altmer, False, "PDV_SPEL_Neglect_Altmer")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T1, False, "PDV_Bless_Argonian_Hist_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_T2, False, "PDV_Bless_Argonian_Hist_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Hist_Signature, False, "PDV_Bless_Argonian_Hist_Signature")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T1, False, "PDV_Bless_Argonian_People_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T2, False, "PDV_Bless_Argonian_People_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_People_T3, False, "PDV_Bless_Argonian_People_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianShadowscaleVeil, False, "PDV_SPEL_ArgonianShadowscaleVeil")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianRootedRest, False, "PDV_SPEL_ArgonianRootedRest")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Claws, False, "PDV_SPEL_ArgonianAdapt_Claws")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Skin, False, "PDV_SPEL_ArgonianAdapt_Skin")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Sap, False, "PDV_SPEL_ArgonianAdapt_Sap")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianAdapt_Marsh, False, "PDV_SPEL_ArgonianAdapt_Marsh")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerTaleCarried, False, "PDV_SPEL_BosmerTaleCarried")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerScalesAtRest, False, "PDV_SPEL_BosmerScalesAtRest")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerBaanDarGap, False, "PDV_SPEL_BosmerBaanDarGap")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Hunter, False, "PDV_SPEL_BosmerNaming_Hunter")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Speaker, False, "PDV_SPEL_BosmerNaming_Speaker")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Wanderer, False, "PDV_SPEL_BosmerNaming_Wanderer")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_BosmerNaming_Keeper, False, "PDV_SPEL_BosmerNaming_Keeper")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T1, False, "PDV_Bless_Argonian_Sithis_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T2, False, "PDV_Bless_Argonian_Sithis_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Argonian_Sithis_T3, False, "PDV_Bless_Argonian_Sithis_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_ArgonianSithisNearDeathBurst, False, "PDV_SPEL_ArgonianSithisNearDeathBurst")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_ArgonianHist, False, "PDV_SPEL_Neglect_ArgonianHist")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T1, False, "PDV_Bless_Bosmer_Yffre_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Yffre_T2, False, "PDV_Bless_Bosmer_Yffre_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T1, False, "PDV_Bless_Bosmer_OldContract_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T2, False, "PDV_Bless_Bosmer_OldContract_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_OldContract_T3, False, "PDV_Bless_Bosmer_OldContract_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T1, False, "PDV_Bless_Bosmer_LivingStory_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T2, False, "PDV_Bless_Bosmer_LivingStory_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_LivingStory_T3, False, "PDV_Bless_Bosmer_LivingStory_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T1, False, "PDV_Bless_Bosmer_Exchange_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T2, False, "PDV_Bless_Bosmer_Exchange_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_Exchange_T3, False, "PDV_Bless_Bosmer_Exchange_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T1, False, "PDV_Bless_Bosmer_BanditRoad_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T2, False, "PDV_Bless_Bosmer_BanditRoad_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Bosmer_BanditRoad_T3, False, "PDV_Bless_Bosmer_BanditRoad_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Bosmer, False, "PDV_SPEL_Neglect_Bosmer")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T1, False, "PDV_Bless_Breton_Tradition_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T2, False, "PDV_Bless_Breton_Tradition_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T1, False, "PDV_Bless_Breton_KnightsRoad_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T2, False, "PDV_Bless_Breton_KnightsRoad_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T3, False, "PDV_Bless_Breton_KnightsRoad_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T1, False, "PDV_Bless_Breton_HiddenArt_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T2, False, "PDV_Bless_Breton_HiddenArt_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T3, False, "PDV_Bless_Breton_HiddenArt_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T1, False, "PDV_Bless_Breton_GreenWay_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T2, False, "PDV_Bless_Breton_GreenWay_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T3, False, "PDV_Bless_Breton_GreenWay_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_PatronChampion, False, "PDV_Bless_Breton_PatronChampion")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Breton, False, "PDV_SPEL_Neglect_Breton")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_VowIntegrity, False, "PDV_SPEL_CreedLoss_Breton_VowIntegrity")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_ExposureRupture, False, "PDV_SPEL_CreedLoss_Breton_ExposureRupture")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_Excommunication, False, "PDV_SPEL_CreedLoss_Breton_Excommunication")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal, False, "PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T1, False, "PDV_Bless_Dunmer_Reclamation_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T2, False, "PDV_Bless_Dunmer_Reclamation_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T1, False, "PDV_Bless_Dunmer_Azura_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T2, False, "PDV_Bless_Dunmer_Azura_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Azura_T3, False, "PDV_Bless_Dunmer_Azura_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T1, False, "PDV_Bless_Dunmer_Boethiah_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T2, False, "PDV_Bless_Dunmer_Boethiah_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Boethiah_T3, False, "PDV_Bless_Dunmer_Boethiah_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T1, False, "PDV_Bless_Dunmer_Mephala_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T2, False, "PDV_Bless_Dunmer_Mephala_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Mephala_T3, False, "PDV_Bless_Dunmer_Mephala_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Dunmer, False, "PDV_SPEL_Neglect_Dunmer")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T1, False, "PDV_Bless_Imperial_Civic_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T2, False, "PDV_Bless_Imperial_Civic_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T1, False, "PDV_Bless_Imperial_Akatosh_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T2, False, "PDV_Bless_Imperial_Akatosh_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Akatosh_T3, False, "PDV_Bless_Imperial_Akatosh_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T1, False, "PDV_Bless_Imperial_Mara_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T2, False, "PDV_Bless_Imperial_Mara_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Mara_T3, False, "PDV_Bless_Imperial_Mara_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T1, False, "PDV_Bless_Imperial_Arkay_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T2, False, "PDV_Bless_Imperial_Arkay_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Arkay_T3, False, "PDV_Bless_Imperial_Arkay_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T1, False, "PDV_Bless_Imperial_Stendarr_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T2, False, "PDV_Bless_Imperial_Stendarr_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Stendarr_T3, False, "PDV_Bless_Imperial_Stendarr_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T1, False, "PDV_Bless_Imperial_Zenithar_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T2, False, "PDV_Bless_Imperial_Zenithar_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Zenithar_T3, False, "PDV_Bless_Imperial_Zenithar_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T1, False, "PDV_Bless_Imperial_Dibella_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T2, False, "PDV_Bless_Imperial_Dibella_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Dibella_T3, False, "PDV_Bless_Imperial_Dibella_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T1, False, "PDV_Bless_Imperial_Julianos_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T2, False, "PDV_Bless_Imperial_Julianos_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Julianos_T3, False, "PDV_Bless_Imperial_Julianos_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T1, False, "PDV_Bless_Imperial_Kynareth_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T2, False, "PDV_Bless_Imperial_Kynareth_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Kynareth_T3, False, "PDV_Bless_Imperial_Kynareth_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T1, False, "PDV_Bless_Imperial_Talos_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T2, False, "PDV_Bless_Imperial_Talos_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Talos_T3, False, "PDV_Bless_Imperial_Talos_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Imperial, False, "PDV_SPEL_Neglect_Imperial")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Lunar_T1, False, "PDV_Bless_Khajiit_Lunar_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Khenarthi, False, "PDV_Bless_Khajiit_Phase_Khenarthi")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Azurah, False, "PDV_Bless_Khajiit_Phase_Azurah")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_BaanDar, False, "PDV_Bless_Khajiit_Phase_BaanDar")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Rajhin, False, "PDV_Bless_Khajiit_Phase_Rajhin")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Phase_Alkosh, False, "PDV_Bless_Khajiit_Phase_Alkosh")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T1, False, "PDV_Bless_Khajiit_Khenarthi_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T2, False, "PDV_Bless_Khajiit_Khenarthi_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Khenarthi_T3, False, "PDV_Bless_Khajiit_Khenarthi_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T1, False, "PDV_Bless_Khajiit_Azurah_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T2, False, "PDV_Bless_Khajiit_Azurah_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Azurah_T3, False, "PDV_Bless_Khajiit_Azurah_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T1, False, "PDV_Bless_Khajiit_BaanDar_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T2, False, "PDV_Bless_Khajiit_BaanDar_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_BaanDar_T3, False, "PDV_Bless_Khajiit_BaanDar_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T1, False, "PDV_Bless_Khajiit_Rajhin_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T2, False, "PDV_Bless_Khajiit_Rajhin_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Rajhin_T3, False, "PDV_Bless_Khajiit_Rajhin_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T1, False, "PDV_Bless_Khajiit_Alkosh_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T2, False, "PDV_Bless_Khajiit_Alkosh_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Khajiit_Alkosh_T3, False, "PDV_Bless_Khajiit_Alkosh_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_KhajiitLunar, False, "PDV_SPEL_Neglect_KhajiitLunar")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T1, False, "PDV_Bless_Nord_OldWays_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_OldWays_T2, False, "PDV_Bless_Nord_OldWays_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T1, False, "PDV_Bless_Nord_Kyne_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T2, False, "PDV_Bless_Nord_Kyne_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Kyne_T3, False, "PDV_Bless_Nord_Kyne_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T1, False, "PDV_Bless_Nord_Shor_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T2, False, "PDV_Bless_Nord_Shor_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Shor_T3, False, "PDV_Bless_Nord_Shor_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T1, False, "PDV_Bless_Nord_Tsun_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T2, False, "PDV_Bless_Nord_Tsun_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Tsun_T3, False, "PDV_Bless_Nord_Tsun_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T1, False, "PDV_Bless_Nord_Stuhn_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T2, False, "PDV_Bless_Nord_Stuhn_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Stuhn_T3, False, "PDV_Bless_Nord_Stuhn_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T1, False, "PDV_Bless_Nord_Talos_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T2, False, "PDV_Bless_Nord_Talos_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Talos_T3, False, "PDV_Bless_Nord_Talos_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T1, False, "PDV_Bless_Nord_Arkay_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T2, False, "PDV_Bless_Nord_Arkay_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Nord_Arkay_T3, False, "PDV_Bless_Nord_Arkay_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T1, False, "PDV_Bless_Orc_Malacath_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T2, False, "PDV_Bless_Orc_Malacath_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T1, False, "PDV_Bless_Orc_Stronghold_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T2, False, "PDV_Bless_Orc_Stronghold_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Stronghold_T3, False, "PDV_Bless_Orc_Stronghold_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T1, False, "PDV_Bless_Orc_City_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T2, False, "PDV_Bless_Orc_City_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_City_T3, False, "PDV_Bless_Orc_City_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T1, False, "PDV_Bless_Orc_LegionExile_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T2, False, "PDV_Bless_Orc_LegionExile_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_LegionExile_T3, False, "PDV_Bless_Orc_LegionExile_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_City, False, "PDV_Bless_Orc_Spine_City")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_Stronghold, False, "PDV_Bless_Orc_Spine_Stronghold")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_LegionExile, False, "PDV_Bless_Orc_Spine_LegionExile")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Orc, False, "PDV_SPEL_Neglect_Orc")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Tusk, False, "PDV_SPEL_Orc_TrialOfIron_Tusk")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Shield, False, "PDV_SPEL_Orc_TrialOfIron_Shield")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Hammer, False, "PDV_SPEL_Orc_TrialOfIron_Hammer")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Orc_TrialOfIron_Yoke, False, "PDV_SPEL_Orc_TrialOfIron_Yoke")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcCodeHolds, False, "PDV_SPEL_OrcCodeHolds")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcCodeHolds_Devoted, False, "PDV_SPEL_OrcCodeHolds_Devoted")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_OrcHearthHeld, False, "PDV_SPEL_OrcHearthHeld")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T1, False, "PDV_Bless_Redguard_AncestorSpine_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T2, False, "PDV_Bless_Redguard_AncestorSpine_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Crown, False, "PDV_Bless_Redguard_Spine_Crown")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Forebear, False, "PDV_Bless_Redguard_Spine_Forebear")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_AshAbah, False, "PDV_Bless_Redguard_Spine_AshAbah")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T1, False, "PDV_Bless_Redguard_Tuwhacca_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T2, False, "PDV_Bless_Redguard_Tuwhacca_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Tuwhacca_T3, False, "PDV_Bless_Redguard_Tuwhacca_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T1, False, "PDV_Bless_Redguard_HoonDing_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T2, False, "PDV_Bless_Redguard_HoonDing_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_HoonDing_T3, False, "PDV_Bless_Redguard_HoonDing_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T1, False, "PDV_Bless_Redguard_Leki_T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T2, False, "PDV_Bless_Redguard_Leki_T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Leki_T3, False, "PDV_Bless_Redguard_Leki_T3")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_FarShoresToken, False, "PDV_Bless_Redguard_FarShoresToken")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_SPEL_Neglect_Redguard, False, "PDV_SPEL_Neglect_Redguard")

    ; B16 / fix-plan 11.1: the two observance families this property-by-property strip
    ; omitted, so an active Discipline of Return or Remembering of Names survived
    ; uninstall permanently while every sibling family was cleared. Both helpers are
    ; the same clear-before-add removers the rites themselves use.
    OriginRuntime.RemoveAltmerDisciplineSpells(playerRef)
    OriginRuntime.RemoveRedguardRememberSpells(playerRef)
    ; Same defect class, found while fixing B16: the Daedric pact boon + price spells
    ; are properties on the PDV_DaedricPath_* scripts, not on this manager, so the
    ; strip above could never reach them. Malacath's price is SpeedMult -- an
    ; uninstalled long-pact Orc stayed permanently slower.
    DaedricRuntime.StripAllDaedricPactSpells()
EndFunction

































Function DebugApplyTalosBetrayalCompliance()
    if !OriginRuntime.HandleTalosBetrayal(2, "mcm")
        Debug.Notification("Talos betrayal did not apply; check origin, active Talos, Concordat, or repeat state.")
    endIf
EndFunction

Function DebugApplyTalosBetrayalMajor()
    if !OriginRuntime.HandleTalosBetrayal(3, "mcm")
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
    OriginRuntime.InitializeBosmerStorage()
    PDV_BosmerPathTrack.SetState(stateValue, "mcm_pattern")
    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 1)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)

    if stateValue == BOSMER_PATH_OLD_CONTRACT
        OriginRuntime.SetBosmerPactBound(True, "mcm_pattern")
        OriginRuntime.SetBosmerGreenPactCompliance(80, "mcm_pattern")
    else
        OriginRuntime.SetBosmerPactBound(False, "mcm_pattern")
        OriginRuntime.SetBosmerGreenPactCompliance(0, "mcm_pattern")
    endIf

    OriginRuntime.ApplyBosmerPathPatron(stateValue, "mcm_pattern")
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
    EndRaceSetupQuietPresentation()
EndFunction

Function DebugTriggerGreenPactViolation()
    OriginRuntime.HandleGreenPactViolation("mcm")
EndFunction

Function DebugRecordBosmerLivingStorySignal()
    OriginRuntime.HandleBosmerLivingStorySignal("mcm")
EndFunction

Function DebugRecordBosmerExchangeSignal()
    OriginRuntime.HandleBosmerExchangeSignal("mcm")
EndFunction

Function DebugRecordBosmerBanditRoadSignal()
    OriginRuntime.HandleBosmerBanditRoadSignal("mcm")
EndFunction

Function DebugRecordBosmerPactPositiveSignal()
    OriginRuntime.HandleBosmerPactPositiveSignal("mcm")
EndFunction

Function DebugConfirmStateTransitionRite()
    OriginRuntime.HandleStateTransitionConfirmationRite("mcm")
EndFunction

Function DebugRecordDunmerAncestorPrayer()
    OriginRuntime.HandleDunmerPortableShrinePrayer("mcm")
EndFunction

Function DebugRecordDunmerAncestorHomeBonus()
    OriginRuntime.HandleDunmerPlayerHomeBonus("mcm")
EndFunction

Function DebugRecordKhajiitMoonObservance()
    Int nextPhase = OriginRuntime.GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
    if PDV_KhajiitLunarSubstrate && PDV_KhajiitLunarSubstrate.GetLastObservedPhase() == nextPhase
        nextPhase += 1
        if nextPhase > 8
            nextPhase = 1
        endIf
    endIf
    OriginRuntime.HandleKhajiitMoonObservance(nextPhase, "mcm")
EndFunction

Function DebugRecordKhajiitRoadHome()
    OriginRuntime.HandleKhajiitRoadHome("mcm")
EndFunction

Function DebugRecordKhajiitCaravanAid()
    OriginRuntime.HandleKhajiitKhenarthiCaravanAid("mcm")
EndFunction

Function DebugRecordKhajiitLegendMade()
    OriginRuntime.HandleKhajiitRajhinLegendMade("mcm")
EndFunction

Function DebugRecordMephalaWebWoven()
    DaedricRuntime.HandleMephalaWebWoven("mcm")
EndFunction

Function DebugRecordBoethiahHonorableDuel()
    DaedricRuntime.HandleBoethiahHonorableDuel("mcm")
EndFunction

Function DebugRecordArgonianHistMaintenance()
    OriginRuntime.HandleArgonianHistMaintenance("mcm")
EndFunction

Function DebugRecordArgonianPeopleSupport()
    OriginRuntime.HandleArgonianPeopleSupport("mcm")
EndFunction

Function DebugRecordArgonianBedOfChoiceReturn()
    OriginRuntime.HandleArgonianBedOfChoiceReturn("mcm")
EndFunction

Function DebugRecordArgonianVoidSignal()
    OriginRuntime.HandleArgonianVoidSignal("mcm")
EndFunction

Function DebugRecordTalosShrineDefiance()
    OriginRuntime.HandleTalosShrineDefiance("mcm")
EndFunction

Function DebugRecordAltmerDawnSteadiness()
    OriginRuntime.HandleAltmerDawnSteadiness("mcm")
EndFunction

Function DebugRecordAltmerOrthodoxCostlyEnforcement()
    OriginRuntime.HandleAltmerOrthodoxCostlyEnforcement("mcm")
EndFunction

Function DebugRecordAltmerDragonbornCrisis()
    OriginRuntime.HandleAltmerCrisisSource(ALTMER_CRISIS_SOURCE_DRAGONBORN, "mcm_dragonborn")
EndFunction

Function DebugRecordAltmerLorkhanPressure()
    OriginRuntime.HandleAltmerLorkhanPressure(ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION, "mcm_lorkhan_pressure")
EndFunction

Function DebugSetNordPantheonBaseline(Int stateValue)
    Int normalizedState = PDV_DevotionRules.ClampInt(stateValue, NORD_BASELINE_OLD_WAYS, NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalizedState)
    if PDV_NordPantheonBaselineTrack && PDV_NordPantheonBaselineTrack.GetCurrentState() != normalizedState
        PDV_NordPantheonBaselineTrack.SetState(normalizedState, "mcm_pattern")
    endIf
    PDV_DeityBase pending = LedgerRuntime.GetPendingCommitmentDeity()
    if pending && !OriginRuntime.IsOfferEligibleDeity(pending)
        LedgerRuntime.ClearPendingCommitment()
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity && !OriginRuntime.IsOfferEligibleDeity(_activeDeity)
        LedgerRuntime.SetBroadWorship()
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
EndFunction


String Function DebugGetSubstratePacingSummary(Int originValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No active pacing substrate is wired for origin " + originValue + "."
    endIf
    String summary = "metric=" + substrate.GetMetric() + " tier=" + substrate.GetSubstrateTier() + " day=" + substrate.GetDevotionalDay() + " encodedStamp=" + substrate.GetEncodedDailyCreditStamp() + " spent=" + substrate.IsDailyCreditSpent() + " accepted=" + substrate.GetLastAcceptedSource() + " acceptedEvent=" + substrate.GetLastAcceptedLogicalEvent() + " rejected=" + substrate.GetLastRejectedSource() + " rejectedEvent=" + substrate.GetLastRejectedLogicalEvent() + " rejectReason=" + substrate.GetLastCreditRejectReason() + " decay=" + OriginRuntime.GetSubstrateDecaySummary(originValue)
    if originValue == ORIGIN_KHAJIIT
        summary = summary + " moonReject=" + StorageUtil.GetStringValue(None, "PDV.Khajiit.MoonRite.LastReject")
    endIf
    return summary
EndFunction


String Function DebugTriggerSubstratePacingSource(Int originValue, Int sourceIndex = 0)
    if originValue == ORIGIN_IMPERIAL
        if sourceIndex == 0
            OriginRuntime.HandleImperialCivicService("mcm_debug_public_service")
        elseIf sourceIndex == 1
            LedgerRuntime.HandleSubstrateShrinePrayer("Mara", "", "", "mcm_debug_divine_prayer")
        else
            OriginRuntime.HandleImperialSleepEvents(Game.GetPlayer(), "mcm_debug_rejected_sleep")
            if PDV_ImperialAncestorSubstrate
                PDV_ImperialAncestorSubstrate.RecordDailyCreditReject("imperial_sleep", "mcm_debug_rejected_sleep", "retired_route")
            endIf
        endIf
    elseIf originValue == ORIGIN_DUNMER
        if sourceIndex == 0
            OriginRuntime.HandleDunmerPortableShrinePrayer("mcm_debug_portable_prayer")
        elseIf sourceIndex == 1
            OriginRuntime.HandleDunmerReclamationFocus(1, "mcm_debug_reclamation_book")
        else
            OriginRuntime.HandleDunmerPlayerHomeBonus("mcm_debug_rejected_home_only")
        endIf
    elseIf originValue == ORIGIN_ARGONIAN
        if sourceIndex == 0
            OriginRuntime.HandleArgonianHistMaintenance("mcm_debug_hist_maintenance")
        elseIf sourceIndex == 1
            OriginRuntime.HandleArgonianPeopleSupport("mcm_debug_people_support")
        elseIf PDV_ArgonianHistSubstrate
            PDV_ArgonianHistSubstrate.RecordDailyCreditReject("argonian_brief_swim", "mcm_debug_brief_swim", "duration_too_short")
        endIf
    elseIf originValue == ORIGIN_NORD
        if sourceIndex == 0
            if OriginRuntime.GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
                OriginRuntime.HandleNordOldWaysState("mcm_debug_nine_road_grace")
            else
                OriginRuntime.HandleNordOldWaysState("mcm_debug_sky_road")
            endIf
        elseIf sourceIndex == 1 && PDV_NordAncestorSubstrate
            OriginRuntime.HandleSubstrateActionEvent(313, "mcm_debug_open_sky_rest")
        elseIf PDV_NordAncestorSubstrate
            PDV_NordAncestorSubstrate.RecordDailyCreditReject("nord_universal_shor", "mcm_debug_universal_shor", "retired_route")
        endIf
    elseIf originValue == ORIGIN_ALTMER
        if sourceIndex == 0
            LedgerRuntime.HandleSubstrateShrinePrayer("Auri-El", "", "", "mcm_debug_auriel_rite")
        elseIf sourceIndex == 1
            OriginRuntime.HandleAltmerMagicSkillIncrease("Alteration")
        elseIf PDV_AltmerAncestorSubstrate
            PDV_AltmerAncestorSubstrate.RecordDailyCreditReject("altmer_passive_dawn", "mcm_debug_passive_dawn", "retired_route")
        endIf
    elseIf originValue == ORIGIN_KHAJIIT
        if sourceIndex == 0
            OriginRuntime.HandleKhajiitRoadHome("mcm_debug_outdoor_rest")
        elseIf sourceIndex == 1
            OriginRuntime.HandleKhajiitLunarSubstrate("mcm_debug_caravan_defense")
        else
            OriginRuntime.HandleKhajiitRoadHomeAnchor(1, "mcm_debug_rejected_anchor")
            if PDV_KhajiitLunarSubstrate
                PDV_KhajiitLunarSubstrate.RecordDailyCreditReject("khajiit_road_anchor", "mcm_debug_rejected_anchor", "retired_route")
            endIf
        endIf
    endIf
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugSeedSubstrateMetric(Int originValue, Float metricValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    OriginRuntime.ResetSubstratePacingState(originValue)
    substrate.DebugSetMetric(PDV_DevotionRules.ClampValue(metricValue, 0.0, 75.0))
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugResetSubstratePacing(Int originValue)
    PDV_SubstrateBase substrate = OriginRuntime.GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    OriginRuntime.ResetSubstratePacingState(originValue)
    return DebugGetSubstratePacingSummary(originValue)
EndFunction




String Function DebugGetBroadPantheonSummary(Int poolIndex)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    Int gainStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastGainDayKey(poolId))
    Int processedStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastProcessedDayKey(poolId))
    Int scratchStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonScratchDayKey(poolId))
    return poolId + " roster=" + LedgerRuntime.GetBroadPantheonRosterForDebug(poolId) + " standing=" + LedgerRuntime.GetBroadPantheonStanding(poolId) + " scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId) + " scratchDay=" + (scratchStamp - 2) + " active=" + (LedgerRuntime.GetActiveBroadPantheonPoolId() == poolId) + " lastGainDay=" + (gainStamp - 2) + " lastProcessedDay=" + (processedStamp - 2) + " grace=2 decay=-0.1/day lastEvent=" + StorageUtil.GetStringValue(None, LedgerRuntime.GetBroadPantheonLastEventKey(poolId))
EndFunction


String Function DebugSeedBroadPantheonPool(Int poolIndex, Float standingValue)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    LedgerRuntime.SetBroadPantheonStanding(poolId, standingValue, "mcm_boundary_seed")
    LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    return DebugGetBroadPantheonSummary(poolIndex)
EndFunction

String Function DebugResetBroadPantheonPool(Int poolIndex)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    LedgerRuntime.ResetBroadPantheonPool(poolId)
    return DebugGetBroadPantheonSummary(poolIndex)
EndFunction

String Function DebugRunBroadPantheonFanoutTest()
    String poolId = LedgerRuntime.GetActiveBroadPantheonPoolId()
    if poolId == ""
        return "Set Imperial/Nord broad worship and an active baseline first."
    endIf
    _broadPantheonSelfEventSequence += 1
    String fixtureId = "mcm_signed_fanout_" + _broadPantheonSelfEventSequence
    Float scratchBefore = LedgerRuntime.GetBroadPantheonScratch(poolId)
    LedgerRuntime.BeginBroadPantheonEvent(fixtureId)
    if poolId == LedgerRuntime.BROAD_PANTHEON_NORD_OLD
        LedgerRuntime.AwardPietyInternal(PDV_Kyne, 1.0, True, fixtureId + "_kyne")
        LedgerRuntime.AwardPietyInternal(PDV_Shor, 2.0, True, fixtureId + "_shor")
        LedgerRuntime.AwardPietyInternal(PDV_Tsun, -4.0, True, fixtureId + "_tsun")
    else
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Akatosh, 1.0, True, fixtureId + "_akatosh")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Mara, 2.0, True, fixtureId + "_mara")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Zenithar, -4.0, True, fixtureId + "_zenithar")
    endIf
    LedgerRuntime.FlushBroadPantheonEvent()
    Float positiveEventDelta = LedgerRuntime.GetBroadPantheonScratch(poolId) - scratchBefore
    LedgerRuntime.BeginBroadPantheonEvent(fixtureId + "_negative")
    if poolId == LedgerRuntime.BROAD_PANTHEON_NORD_OLD
        LedgerRuntime.AwardPietyInternal(PDV_Kyne, -1.0, False, fixtureId + "_kyne_negative")
        LedgerRuntime.AwardPietyInternal(PDV_Tsun, -4.0, False, fixtureId + "_tsun_negative")
    else
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Mara, -1.0, False, fixtureId + "_mara_negative")
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Zenithar, -4.0, False, fixtureId + "_zenithar_negative")
    endIf
    LedgerRuntime.FlushBroadPantheonEvent()
    Float negativeEventDelta = LedgerRuntime.GetBroadPantheonScratch(poolId) - scratchBefore - positiveEventDelta
    Trace(1, "[PDV][PS-A4] pool=" + poolId + " strongestPositive=" + positiveEventDelta + " strongestNegative=" + negativeEventDelta + " scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId))
    return "Post-pipeline fan-out: strongest positive=" + positiveEventDelta + "; strongest negative=" + negativeEventDelta + "; final scratch=" + LedgerRuntime.GetBroadPantheonScratch(poolId)
EndFunction

String Function DebugPrimeBroadPantheonScratch(Int poolIndex, Float scratchValue)
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    StorageUtil.SetFloatValue(None, LedgerRuntime.GetBroadPantheonScratchKey(poolId), scratchValue)
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonScratchDayKey(poolId))
    StorageUtil.SetStringValue(None, LedgerRuntime.GetBroadPantheonLastEventKey(poolId), "mcm_signed_cap_prime")
    Trace(1, "[PDV][PS-A5] staged pool=" + poolId + " scratch=" + scratchValue + "; wait through real dawn")
    return DebugGetBroadPantheonSummary(poolIndex) + " | Wait through real dawn; expected signed fold cap is 4.3."
EndFunction

String Function DebugRunBroadPantheonCatchupForPacing(Int poolIndex)
    ; PS-A11 uses this only after a real act has folded at a real dawn.  It
    ; drives the production catch-up routine through five days after that
    ; recorded gain without mutating Skyrim's clock or GameDaysPassed.
    String poolId = LedgerRuntime.GetBroadPantheonPoolIdByDebugIndex(poolIndex)
    if poolId == ""
        return "No broad pantheon pool selected."
    endIf
    if LedgerRuntime.GetBroadPantheonStanding(poolId) <= 0.0
        return "PS-A11 needs standing from one real folded positive act first."
    endIf
    if LedgerRuntime.GetBroadPantheonScratch(poolId) != 0.0
        return "PS-A11 needs zero pending scratch. Fold or clear the pool first."
    endIf
    if LedgerRuntime.GetActiveBroadPantheonPoolId() == poolId
        return "PS-A11 needs this pool suppressed. Switch to another broad pool or focused worship first."
    endIf

    Int lastGainStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastGainDayKey(poolId))
    if lastGainStamp <= 0
        return "PS-A11 needs a recorded positive gain day from the real fold."
    endIf
    Int lastGainDay = lastGainStamp - 2
    Int targetDay = lastGainDay + 5
    Int processedStamp = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastProcessedDayKey(poolId))
    Int lastProcessedDay = processedStamp - 2
    if targetDay <= lastProcessedDay
        return DebugGetBroadPantheonSummary(poolIndex) + " | PS-A11 target already processed; repeat is idempotent."
    endIf

    Float signedCap = LedgerRuntime.PIETY_DAILY_MAX_DELTA
    if LedgerRuntime.PDV_ModePresetRef
        signedCap = signedCap * LedgerRuntime.PDV_ModePresetRef.DailyCapScalar()
    endIf
    LedgerRuntime.ProcessBroadPantheonThroughDay(poolId, targetDay, signedCap, "mcm_ps_a11_catchup")
    LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    Trace(1, "[PDV][PS-A11] forced catch-up pool=" + poolId + " lastGainDay=" + lastGainDay + " through=" + targetDay + " standing=" + LedgerRuntime.GetBroadPantheonStanding(poolId))
    return DebugGetBroadPantheonSummary(poolIndex) + " | PS-A11 processed through gain day +5; expected two grace days then 0.1/day."
EndFunction

String Function DebugSetNordBaselineForPacing(Int baselineValue)
    DebugSetNordPantheonBaseline(baselineValue)
    return DebugGetBroadPantheonSummary(baselineValue + 1)
EndFunction

String Function DebugOfferAcceptRecoverySummary()
    String activeName = "none"
    if _activeDeity
        activeName = _activeDeity.DeityName + " piety=" + LedgerRuntime.GetPiety(_activeDeity)
    endIf
    PDV_DeityBase pending = LedgerRuntime.GetPendingCommitmentDeity()
    String pendingName = "none"
    if pending
        pendingName = pending.DeityName
    endIf
    PDV_DeityBase candidate = pending
    if !candidate
        candidate = LedgerRuntime.GetPacingPatronCandidate()
    endIf
    Int qualifyingDays = 0
    Bool baselineEligible = False
    Float declinedAt = 0.0
    if candidate
        qualifyingDays = LedgerRuntime.GetRecentCommitmentSignalDayCount(candidate, 7)
        baselineEligible = LedgerRuntime.UsesFormalCommitmentOffersForDeity(candidate)
        declinedAt = StorageUtil.GetFloatValue(candidate as Form, "PDV.Commitment.DeclinedAt")
    endIf
    return "state=" + LedgerRuntime.GetPatronStateLabel() + " active=" + activeName + " pending=" + pendingName + " qualifyingDays=" + qualifyingDays + " baselineEligible=" + baselineEligible + " offeredAt=" + StorageUtil.GetFloatValue(None, "PDV.Commitment.OfferedAt") + " declinedAt=" + declinedAt
EndFunction

String Function DebugSetBroadWorshipForPacing()
    LedgerRuntime.ClearPendingCommitment()
    LedgerRuntime.SetBroadWorship()
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    Trace(1, "[PDV][BROAD_TEST] clean broad worship restored")
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugRunPatronOfferForPacing()
    PDV_DeityBase candidate = LedgerRuntime.GetPacingPatronCandidate()
    if !candidate
        return "Select Imperial or Nord broad worship before preparing an offer."
    endIf

    ; Deterministic clean-save setup: preserve all unrelated ledgers, return to
    ; broad worship, make one baseline-eligible candidate exactly qualified,
    ; clear its offer/cooldown state, and leave it pending for the separate
    ; Accept button. No message box races this controlled MCM sequence.
    LedgerRuntime.SetBroadWorship()
    LedgerRuntime.ClearPendingCommitment()
    Form candidateForm = candidate as Form
    StorageUtil.SetFloatValue(candidateForm, "PDV.Piety", LedgerRuntime.COMMITMENT_OFFER_THRESHOLD)
    StorageUtil.SetIntValue(candidateForm, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(candidateForm, "PDV.Commitment.Refused", 0)
    StorageUtil.SetFloatValue(candidateForm, "PDV.Commitment.DeclinedAt", 0.0)
    DebugSeedCommitmentSignalDaysByIndex(candidate.DeityIndex)
    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", candidate.DeityIndex)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", Utility.GetCurrentGameTime())
    LedgerRuntime.RecomputeTier(candidate)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    return DebugOfferAcceptRecoverySummary()
EndFunction


String Function DebugAcceptPatronForPacing()
    DebugAcceptPendingCommitment()
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugLapsePatronForPacing()
    if _activeDeity
        StorageUtil.SetFloatValue(_activeDeity as Form, "PDV.Piety", 49.0)
        LedgerRuntime.RecomputeTier(_activeDeity)
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        RequestPanelRefresh()
    endIf
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugRecoverPatronForPacing()
    if _activeDeity
        StorageUtil.SetFloatValue(_activeDeity as Form, "PDV.Piety", 50.0)
        LedgerRuntime.RecomputeTier(_activeDeity)
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        RequestPanelRefresh()
    endIf
    return DebugOfferAcceptRecoverySummary()
EndFunction

String Function DebugSetImperialVampireForPacing(Bool vampireActive)
    if vampireActive
        DebugForceCurseVampire()
    else
        DebugForceCurseNone()
    endIf
    return DebugGetSubstratePacingSummary(ORIGIN_IMPERIAL)
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
        StorageUtil.SetFloatValue(None, OriginRuntime.GetKhajiitFocusWeightKey(f), 0.0)
        f += 1
    endWhile

    StorageUtil.SetFloatValue(None, OriginRuntime.GetKhajiitFocusWeightKey(focusValue), KHAJIIT_FOCUS_THRESHOLD + KHAJIIT_FOCUS_LEAD_REQUIRED + 10.0)
    OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    OriginRuntime.SyncKhajiitRuntimeState()
    EndRaceSetupQuietPresentation()
    Trace(1, "Khajiit focus debug-set to " + OriginRuntime.GetKhajiitFocusLabel(focusValue))
EndFunction

; Forces the Breton tradition (Knight's Road / Hidden Art / Green Way).
Function DebugSetBretonTradition(Int traditionValue)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(1, "Breton tradition debug-set ignored: set Breton origin first")
        return
    endIf

    Int normalized = PDV_DevotionRules.ClampInt(traditionValue, BRETON_TRADITION_KNIGHTS_ROAD, BRETON_TRADITION_GREEN_WAY)
    BeginRaceSetupQuietPresentation("mcm_breton_tradition")
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    if normalized == BRETON_TRADITION_GREEN_WAY
        OriginRuntime.SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_breton_tradition")
        if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0) < 50
            StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        endIf
    else
        OriginRuntime.SetBretonDruidicFork(BRETON_DRUIDIC_FORK_NONE, "mcm_breton_tradition")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
    Trace(1, "Breton tradition debug-set to " + normalized)
EndFunction

; MCM fray-test seed: forces a Green Way / Druidic-fork Breton with DruidicStanding
; one point above the fraying band and the decay day-key cleared, so the next one
; or two ProcessDawn passes drop it past <30 and the Survey/label read "frayed".
Function DebugSeedBretonDruidicFrayTest()
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", BRETON_TRADITION_GREEN_WAY)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    OriginRuntime.SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_fray_test")
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 31)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicDecayDay", 0)
    Trace(1, "Breton Druidic fray test seeded: GreenWay/Druidic, standing=31")
EndFunction

; Forces the Orc life mode (City / Stronghold / Legion-Exile).
Function DebugSetOrcLifeMode(Int modeValue)
    Int normalized = PDV_DevotionRules.ClampInt(modeValue, ORC_LIFE_MODE_CITY, ORC_LIFE_MODE_LEGION_EXILE)
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






Function DebugCycleContextualFavorLane()
    Int laneValue = FavorRuntime.GetSelectedContextualFavorLane() + 1
    if laneValue > FavorRuntime.FAVOR_LANE_ALTMER
        laneValue = FavorRuntime.FAVOR_LANE_KYNE
    endIf

    FavorRuntime.SetSelectedContextualFavorLane(laneValue)
EndFunction

Function DebugCycleContextualFavorFamily()
    Int laneValue = FavorRuntime.GetSelectedContextualFavorLane()
    Int nextFamily = FavorRuntime.GetNextFavorFamilyForLane(laneValue, FavorRuntime.GetSelectedContextualFavorFamily())
    StorageUtil.SetIntValue(None, "PDV.Favor.DebugFamily", nextFamily)
EndFunction

Function DebugTriggerSelectedContextualFavor()
    FavorRuntime.TryActivateContextualFavor(FavorRuntime.GetSelectedContextualFavorLane(), FavorRuntime.GetSelectedContextualFavorFamily(), "mcm")
EndFunction

Function DebugExpireActiveFavor()
    FavorRuntime.ClearActiveFavor("mcm")
EndFunction

; Debug: make the CURRENT origin's race-lane neglect eligible immediately by backdating its
; source-lapse timestamp well past the grace window, then re-syncing so the neglect debuff applies
; without a multi-day real wait. This exists because the source timestamp that the Is<Race>Neglected
; checks read (e.g. PDV.Altmer.Favor.LastGameTime) is only written by an organic favor act -- the
; "Trigger selected favor" debug applies the temporary favor spell but never records that source, so
; there was previously no way to prime a race-lane neglect. Covers the timestamp-lapse lanes; the
; curse/Hist/substrate lanes (Dunmer, Argonian, Imperial) use their own mechanisms and are not primed
; here. Ensure Curse none first (an active curse suppresses several lanes).
Function DebugPrimeRaceLaneNeglect()
    Int origin = GetPlayerOriginRaceIndex()
    ; Clamp to a tiny positive epsilon rather than letting this go <= 0.0 on any save whose
    ; clock hasn't reached day 10 yet -- every Is<Race>Neglected check guards lastSource <= 0.0
    ; as its "never set" sentinel, so a negative/zero backdate silently defeats the whole prime
    ; (bug found 2026-07-16: Redguard neglect never fired on an early save for exactly this reason).
    Float lapsed = Utility.GetCurrentGameTime() - 10.0
    if lapsed <= 0.0
        lapsed = 0.01
    endIf
    String laneLabel = ""
    if origin == ORIGIN_ALTMER
        StorageUtil.SetFloatValue(None, "PDV.Altmer.Favor.LastGameTime", lapsed)
        laneLabel = "Altmer coherence"
    elseIf origin == ORIGIN_REDGUARD
        StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", lapsed)
        laneLabel = "Redguard ancestor-distance"
    elseIf origin == ORIGIN_BRETON
        StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", lapsed)
        laneLabel = "Breton tradition"
    elseIf origin == ORIGIN_ORC
        StorageUtil.SetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime", lapsed)
        laneLabel = "Orc code"
    elseIf origin == ORIGIN_KHAJIIT
        StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", lapsed)
        laneLabel = "Khajiit lunar"
    else
        Debug.Notification("PDV: race-lane neglect prime not wired for this origin (Dunmer/Argonian/Imperial use curse/Hist/substrate).")
        return
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Debug.Notification("PDV: primed " + laneLabel + " neglect. Ensure Curse none, then check Active Effects.")
    Trace(1, "DebugPrimeRaceLaneNeglect: backdated " + laneLabel + " source and re-synced.")
EndFunction



Function DebugCycleKyneFavorMask()
    Int currentMask = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    currentMask += 1
    if currentMask > 7
        currentMask = 0
    endIf

    StorageUtil.SetIntValue(None, "PDV.KyneFavor.ConditionMask", currentMask)
    FavorRuntime.SetSelectedContextualFavorLane(FavorRuntime.FAVOR_LANE_KYNE)
    DebugCycleContextualFavorFamily()
    FavorRuntime.UpdateContextualFavorRuntime()
EndFunction

Function DebugRecordHircineHuntRite()
    DaedricRuntime.HandleHircineHuntRite("mcm")
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
        DaedricRuntime.DrainHircineRenunciationJournal()
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
        LedgerRuntime.HandleCurseStateTransition(oldState, appliedState, reason)
    elseIf PDV_HircinePath
        PDV_HircinePath.UpdateResidueRecovery()
        DaedricRuntime.DrainHircineResiduePrismaToasts()
    endIf
EndFunction

Function DebugRefreshCurseFromPlayerState()
    LedgerRuntime.HandleCurseStateRefresh("mcm_refresh")
EndFunction

Bool Function DebugSetCurseProofOriginRace(Int originRace)
    if originRace < ORIGIN_NORD || originRace > ORIGIN_REDGUARD || !PDV_GLO_OriginRace || !PDV_CurseStateService
        return False
    endIf
    if PDV_CurseStateService.GetCurseState() != 0
        return False
    endIf

    PDV_GLO_OriginRace.SetValue(originRace as Float)
    ; The race just changed, so the bound adapter must change with it.
    ResolveOriginRuntime()
    if PDV_ImperialAncestorSubstrate
        PDV_ImperialAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_DunmerAncestorSubstrate
        PDV_DunmerAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_ArgonianHistSubstrate
        PDV_ArgonianHistSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_NordAncestorSubstrate
        PDV_NordAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_AltmerAncestorSubstrate
        PDV_AltmerAncestorSubstrate.RecomputeSubstrateTier()
    endIf
    if PDV_KhajiitLunarSubstrate
        PDV_KhajiitLunarSubstrate.RecomputeSubstrateTier()
    endIf
    LedgerRuntime.RefreshPatronMirrors()
    FavorRuntime.UpdateContextualFavorRuntime()
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    Trace(1, "Curse proof origin set to " + OriginRuntime.GetOriginRaceLabel(originRace) + " (" + originRace + ")")
    return True
EndFunction

Function DebugEvaluateCommitmentOffer()
    Int pendingBefore = LedgerRuntime.GetPendingCommitmentDeityIndex()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    Trace(1, "Commitment evaluate debug: pending " + pendingBefore + " -> " + pendingAfter + "; kyneDays=" + LedgerRuntime.GetRecentCommitmentSignalDayCount(PDV_Kyne, 7) + "; kynePiety=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.GetPiety(PDV_Kyne)))
EndFunction

Function DebugSeedCommitmentSignalDaysByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !IsDebugDeityTargetEligible(deity, "DebugSeedCommitmentSignalDaysByIndex")
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
    Trace(1, "Commitment seed debug: " + deity.DeityName + "[" + deity.DeityIndex + "] days=" + LedgerRuntime.GetRecentCommitmentSignalDayCount(deity, 7))
EndFunction

; Form-based twin of DebugSeedCommitmentSignalDaysByIndex. Daedric-path indices do not
; resolve through GetDeityByIndex, so the index seeder misses a Prince; seed by form
; directly to make a path offer-ready.
Function DebugSeedCommitmentSignalDaysForDeity(PDV_DeityBase deity)
    if !IsDebugDeityTargetEligible(deity, "DebugSeedCommitmentSignalDaysForDeity")
        return
    endIf
    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", currentDay + 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", currentDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 1)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", currentDay)
EndFunction

Function DebugResetCommitmentStateByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if deity
        Form deityForm = deity as Form
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedActive", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.DebugSeedDay", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Offered", 0)
        StorageUtil.SetIntValue(deityForm, "PDV.Commitment.Refused", 0)
        if LedgerRuntime.GetPendingCommitmentDeityIndex() == deity.DeityIndex
            LedgerRuntime.ClearPendingCommitment()
        endIf
        Trace(1, "Commitment reset debug: " + deity.DeityName + "[" + deity.DeityIndex + "]")
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
EndFunction




Function ProcessQueuedCommitmentOffer()
    if !_pendingCommitmentOfferDeity
        return
    endIf

    PDV_DeityBase deity = _pendingCommitmentOfferDeity
    _pendingCommitmentOfferDeity = None
    ; ShowFormalCommitmentOffer re-stashes if a menu is somehow still open, so this drain
    ; is self-healing.
    LedgerRuntime.ShowFormalCommitmentOffer(deity)
EndFunction


Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction, PDV_DeityBase deity, String toneOverride = "")
    Int deityIndex = -1
    if deity
        deityIndex = deity.DeityIndex
    endIf

    Bool headline = eventClass == "offer" && (direction == "accept" || direction == "refuse")
    SurfaceTransition(eventClass, surfaceKey, direction, deityIndex, toneOverride, False, headline)
EndFunction







Function DebugAcceptPendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    if !LedgerRuntime.IsPendingCommitmentStillAcceptable(pendingDeity)
        LedgerRuntime.ClearPendingCommitment()
        Trace(1, "Pending commitment invalidated before acceptance.")
        return
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Commitment.LastCarryover", 0.0)

    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 0)
    PDV_DaedricPathBase pendingPath = pendingDeity as PDV_DaedricPathBase
    if pendingPath
        ; A Prince pact: record consent (unblocks ClampPiety's Champion park) and make it
        ; the single active pact. A path is NOT a divine patron, so SetActiveDeity is not
        ; called for it.
        pendingPath.SetDaedricPactConsent(True)
        ; Commit PDV.Tier from current piety before activating the pact. The standing readers
        ; (GetActiveDaedricPactPath) ignore a pact whose tier is still 0, which left the Book
        ; of Days at Distant. The old auto-commit reached MakeActiveDaedricPact via
        ; RecomputeStoredTier; the direct consent call must do the same.
        pendingPath.RecomputeStoredTier("commitment_accept")
        pendingPath.MakeActiveDaedricPact()
        RequestPanelRefresh()
    else
        LedgerRuntime.SetActiveDeity(pendingDeity)
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf
    DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")
    SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "good", LedgerRuntime.BuildCommitmentOfferAcceptToastLine(pendingDeity), "")
    LedgerRuntime.ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 0)
    Trace(1, "Commitment accepted for " + pendingDeity.DeityName + ".")
EndFunction






; Any Daedric path (a PDV_DaedricPathBase) is formal-offer-eligible regardless of origin
; race -- the pact is the consent gate for Champion. The Breton Hidden Art branch inside
; IsBretonOfferEligibleDeity is now a subset of this.
Bool Function IsDaedricPactOfferEligibleDeity(PDV_DeityBase deity)
    return (deity as PDV_DaedricPathBase) != None
EndFunction

; Nord's defining mechanic: deeds reveal which god noticed you. Any deity in the
; chosen pantheon baseline (plus Talos/Ysmir, always) is offer-eligible -- not only
; Kyne. Their T1/T2/T3 reward spells are authored; this opens the organic path to
; them. The eligibility/weight/signal-day machinery is already generic.
; Old Ways also carries Arkay (surfaced under the Nord name Orkey) and Dibella
; (owner directive 2026-07-05); display-name handling lives in
; NormalizePublicDeityDisplayText, rewards reuse the Imperial spells (Mara pattern).











Function DebugDeclinePendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Offered", 0)
    StorageUtil.SetFloatValue(pendingDeity as Form, "PDV.Commitment.DeclinedAt", Utility.GetCurrentGameTime())
    LedgerRuntime.ClearPendingCommitment()
    Trace(1, "Commitment declined/postponed.")
EndFunction

Function DebugRefusePendingCommitment()
    PDV_DeityBase pendingDeity = LedgerRuntime.GetPendingCommitmentDeity()
    if !pendingDeity
        return
    endIf

    ; Owner ruling (Mega Packet Sitting 1 U8): formal-offer REFUSAL is visible as
    ; a refusal toast and pinned Book of Days chronicle, but it must not fire the
    ; diegetic director's screen wash or D1 sound. SurfaceTransition with
    ; silent=True writes and pins the chronicle while skipping that director cue.
    ; The ACCEPT path keeps its revelation toast + sound.
    SurfaceTransition("offer", pendingDeity.DeityName, "refuse", pendingDeity.DeityIndex, "absence", False, True, True)
    SendPrismaToast(GetPrismaSymbolForDeity(pendingDeity), "warning", LedgerRuntime.BuildCommitmentOfferRefuseToastLine(pendingDeity), "")
    StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 1)
    StorageUtil.SetIntValue(None, "PDV.Commitment.Rupture", 1)
    LedgerRuntime.ClearPendingCommitment()
    Trace(1, "Commitment refused.")
EndFunction

Function DebugRunNeglectPass()
    LedgerRuntime.RunDawnApplySpellAndNeglectLayers()
EndFunction


; ===== Daedric pact-consent debug harness (Sanguine test subject) =====
; Deterministic MCM smoke for the 1.5.0e pact-consent gate. Sanguine is the
; reported-bug subject. Each helper composes existing surfaces -- SetStoredPiety,
; DebugSeedCommitmentSignalDaysByIndex, EvaluateFormalCommitmentOffer, the
; Accept/Decline/Refuse handlers, HandleKIDAction, MigrateDaedricConsentIfNeeded --
; and returns a one-line readback for the MCM to ShowMessage.

String Function DebugYesNo(Bool flag)
    if flag
        return "Y"
    endIf
    return "N"
EndFunction

; Shared setup: leave Sanguine offer-eligible (Devoted-threshold piety + two recent
; commitment signal-days, offer/refuse flags cleared) with consent withheld and no
; active pact. Preconditions met; the consent latch is the only thing missing.
Function DebugSeedSanguineOfferReadyCore()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return
    endIf
    sanguinePath.SetStoredPiety(LedgerRuntime.COMMITMENT_OFFER_THRESHOLD, "mcm_consent_seed")
    DebugSeedCommitmentSignalDaysForDeity(sanguinePath)
    Form sanguineForm = sanguinePath as Form
    StorageUtil.SetIntValue(sanguineForm, "PDV.Commitment.Offered", 0)
    StorageUtil.SetIntValue(sanguineForm, "PDV.Commitment.Refused", 0)
    StorageUtil.SetFloatValue(sanguineForm, "PDV.Commitment.DeclinedAt", 0.0)
    LedgerRuntime.ClearPendingCommitment()
    sanguinePath.SetDaedricPactConsent(False)
    sanguinePath.ClearLiveDaedricPactSpells()
    StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
EndFunction

String Function DebugSanguineConsentReadback()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    Int schema = StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema")
    return "Sanguine piety=" + PDV_DevotionRules.FormatTwoDecimals(sanguinePath.GetStoredPiety()) + " tier=" + sanguinePath.GetStoredTier() + "; consent=" + DebugYesNo(sanguinePath.HasDaedricPactConsent()) + "; activePact=" + DebugYesNo(sanguinePath.IsActiveDaedricPact()) + "; consentSchema=" + schema + " (target " + DAEDRIC_CONSENT_SCHEMA_VERSION + ")"
EndFunction

String Function DebugSeedSanguineOfferReady()
    if !DaedricRuntime.GetDaedricPathByName("Sanguine")
        return "Sanguine path is not available."
    endIf
    DebugSeedSanguineOfferReadyCore()
    return "Seeded Sanguine offer-ready (no consent). " + DebugSanguineConsentReadback()
EndFunction

String Function DebugEvaluateConsentOfferReport()
    Int pendingBefore = LedgerRuntime.GetPendingCommitmentDeityIndex()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    if pendingAfter < 0
        return "Evaluate: no commitment offer fired (pending none). Patron state=" + LedgerRuntime.GetPatronStateLabel() + "."
    endIf
    PDV_DeityBase pendingDeity = LedgerRuntime.GetDeityByIndex(pendingAfter)
    String pendingName = "index " + pendingAfter
    if pendingDeity
        pendingName = pendingDeity.DeityName
    endIf
    return "Evaluate: offer pending for " + pendingName + " (was index " + pendingBefore + "). It replays as the 3-button pact message once the MCM closes."
EndFunction

String Function DebugConsentDivinePatronThenRaiseSanguine()
    if !LedgerRuntime.PDV_Akatosh
        return "PDV_Akatosh is not wired; cannot set a divine patron."
    endIf
    PDV_DeityBase previousPatron = _activeDeity
    Int previousPatronState = LedgerRuntime.GetPatronState()
    if previousPatron && !LedgerRuntime.IsDeityReachableForCurrentOrigin(previousPatron)
        return "Unsafe consent fixture refused: the current patron is a grandfathered off-roster deity and cannot be restored through the ordinary setter."
    endIf
    if DaedricRuntime.GetActiveDaedricPactPath()
        return "Unsafe consent fixture refused: clear the active Daedric pact first so the fixture cannot sever player state it does not restore."
    endIf
    ; A divine patron must suppress the Daedric pact offer and survive the raise.
    LedgerRuntime.UnsafeFaultInjectActiveDeity(LedgerRuntime.PDV_Akatosh, "consent fixture: divine patron suppresses Sanguine offer")
    DebugSeedSanguineOfferReadyCore()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
    Int pendingAfter = LedgerRuntime.GetPendingCommitmentDeityIndex()
    String pendingLabel = "none"
    if pendingAfter >= 0
        PDV_DeityBase pendingDeity = LedgerRuntime.GetDeityByIndex(pendingAfter)
        if pendingDeity
            pendingLabel = pendingDeity.DeityName
        else
            pendingLabel = "index " + pendingAfter
        endIf
    endIf
    String patronLabel = "none"
    if _activeDeity
        patronLabel = _activeDeity.DeityName
    endIf
    String result = "Divine patron=" + patronLabel + " (state " + LedgerRuntime.GetPatronStateLabel() + "); Sanguine raised to offer-ready; offer pending=" + pendingLabel + " (expect none -> suppressed)."
    LedgerRuntime.ClearUnsafeFaultInjection()
    if previousPatronState == LedgerRuntime.PATRON_STATE_ACTIVE && previousPatron
        LedgerRuntime.SetActiveDeity(previousPatron)
    elseIf previousPatronState == LedgerRuntime.PATRON_STATE_BROAD
        LedgerRuntime.SetBroadWorship()
    endIf
    return result + " Unsafe patron injection was cleared and the prior patron mode restored; the persistent unsafe marker still invalidates this run as gameplay proof."
EndFunction

String Function DebugFireSanguineAlcoholTwice()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    Float before = sanguinePath.GetStoredPiety()
    HandleKIDAction("sanguine_alcohol", None)
    Float afterFirst = sanguinePath.GetStoredPiety()
    HandleKIDAction("sanguine_alcohol", None)
    Float afterSecond = sanguinePath.GetStoredPiety()
    return "sanguine_alcohol x2: piety " + PDV_DevotionRules.FormatTwoDecimals(before) + " -> " + PDV_DevotionRules.FormatTwoDecimals(afterFirst) + " -> " + PDV_DevotionRules.FormatTwoDecimals(afterSecond) + " (2nd hit capped by once-per-day)."
EndFunction

String Function DebugForceUnconsentedPactThenMigrate()
    PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    ; Reproduce the pre-consent defect: an ACTIVE pact with no recorded consent.
    sanguinePath.SetStoredPiety(LedgerRuntime.COMMITMENT_OFFER_THRESHOLD, "mcm_consent_unconsented")
    sanguinePath.SetDaedricPactConsent(False)
    sanguinePath.MakeActiveDaedricPact()
    sanguinePath.SetDaedricPactConsent(False)
    Float pietyBefore = sanguinePath.GetStoredPiety()
    Bool activeBefore = sanguinePath.IsActiveDaedricPact()
    ; Bump the consent schema back so the guarded migration re-runs against the state.
    StorageUtil.SetIntValue(None, "PDV.Daedric.ConsentSchema", 0)
    MigrateDaedricConsentIfNeeded()
    return "Un-consented pact forced (active=" + DebugYesNo(activeBefore) + ", piety " + PDV_DevotionRules.FormatTwoDecimals(pietyBefore) + "). After migrate: activePact=" + DebugYesNo(sanguinePath.IsActiveDaedricPact()) + " (expect N), piety=" + PDV_DevotionRules.FormatTwoDecimals(sanguinePath.GetStoredPiety()) + " (preserved), consentSchema=" + StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema") + "."
EndFunction














;/ D5 / fix-plan 9.3. Curse state lives in two places: PDV_CurseState keeps the real
   value on its own form, and HandleCurseStateTransition above mirrors it to the
   None-keyed "PDV.Curse.State" -- which is what the Redguard vampire-reentry gate and
   the diegetic director actually read. Anything that sets curse state through the
   SERVICE without going through the transition handler moves one and not the other.
   This re-points the mirror at the service's live value without re-firing the race
   handlers, which is what a caller that has just RESTORED a state wants: the state did
   not really change, so no onset should be surfaced a second time. /;

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

    ; Owner ruling 2026-08-07: on a CURE, stand aside when the race already spoke. A Nord curing
    ; lycanthropy was getting three surfaces for one event -- the race line, Hircine's residue toast,
    ; and this generic one, whose copy is marked PLACEHOLDER below and only restates the event flatly.
    ; Cure only, deliberately: onset has the same duplicate shape but was not part of the ruling.
    ; Only Nord, Argonian, Khajiit and Redguard have cure records, so for the other five races this
    ; generic toast is the ONLY cure surface and must keep firing.
    if phase == "cure" && _raceCurseSurfaceShown
        return
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
    String context = OriginRuntime.GetCurseContextForRace(phase, curseType)

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
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"curse\":\"" + PDV_DevotionRules.JsonSafeString(curseType) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(curseTitle) + "\""
    j = j + ",\"message\":\"" + PDV_DevotionRules.JsonSafeString(curseMessage) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(_activeDeity)) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(WithPrismaToastSize(j))
EndFunction

; Short race-specific context phrase feeds the UI's listText fallback and any
; future per-race voice extension. Kept brief; the lore detail stays in the
; existing modal messages (ShowNordMessage / ShowAltmerMessage).

; Emit a "shift" event when a substrate/state-track mode changes.
; shiftMode = human-readable new state label (e.g. "Khenarthi", "Stronghold")
; context   = optional short phrase (empty is fine; UI templates the rest)
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Bool Function SendPrismaShiftToast(String shiftMode, String context, String symbolName, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"shift\""
    j = j + ",\"shiftMode\":\"" + PDV_DevotionRules.JsonSafeString(shiftMode) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if _activeDeity
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(_activeDeity)) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, shiftMode, context, allowFallback)
EndFunction

; Emit a substrate instrument event without making Prisma the gameplay proof lane.

Function SendPrismaSubstrateProgress(String substrate, Int tierBefore, Int tierAfter, Float grantedMetric, String context, String symbolName, String stateLabel, Bool surfacePresentation = True)
    ; Presentation follows the actual daily-credit result, never a route's
    ; repeat multiplier. Same-day, duplicate, and capped acts therefore stay
    ; silent on substrate toasts and Book entries.
    if grantedMetric <= 0.0
        return
    endIf
    ; TOAST PARITY, owner ruling 2026-08-06. This branch used to return before any toast, so the
    ; Altmer spine was the only substrate in the mod that never surfaced one. That came from an
    ; earlier "slow cultural foundation, not an interruption" note written while depth was still
    ; being decided, and it was read more strictly than intended: it silenced the toast as well as
    ; the chatter. Altmer now surfaces like every other race.
    ;
    ; It still does NOT fall through to the generic path below, because that path also writes a
    ; Book of Days entry from the context. AppendAltmerHeritageVoice already owns the per-credit
    ; line and the tier crossing is handled here, so falling through would double-log every act.
    if substrate == "altmer-heritage"
        if surfacePresentation
            if tierAfter > tierBefore
                OriginRuntime.SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
            else
                OriginRuntime.SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
            endIf
        endIf
        if tierAfter > tierBefore
            AppendBookOfDaysEntry(OriginRuntime.GetAltmerHeritageTierJournalLine(tierAfter), Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 2, "Ancestral inheritance deepens")
        endIf
        return
    endIf
    if surfacePresentation
        if tierAfter > tierBefore
            OriginRuntime.SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
        elseIf tierAfter < tierBefore
            OriginRuntime.SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)
        else
            OriginRuntime.SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
        endIf

        if context != "" && tierAfter >= tierBefore
            String entryText = context
            if stateLabel != ""
                entryText = stateLabel + ": " + context
            endIf
            AppendBookOfDaysEntry(entryText, Utility.GetCurrentGameTime() as Int, "substrate.act", symbolName, False)
        endIf
    endIf
EndFunction

; Contract-derived Daedric milestone copy. Source: PDV_DaedricPrinceRecordContracts.json.

; Map a Khajiit focus value to a Prisma symbol key.
; Glyphs for these fall back to journal until the Tier-1/2 design pass lands.



; Dunmer 4-state curse posture (LOCKED): vampire silences the ancestor layer
; (Silent=2), werewolf strains it (Strained=1), a cure leaves it RestoredScarred
; (3); Normal=0. The ash-prayer silence under vampirism is the signature consequence.

; Per-layer scoring weight by curse posture. Layer 1 (ancestor substrate / ash-prayer)
; goes silent (0x) under vampirism and half under the beast; Layer 2 (Reclamation)
; keeps its vampire pressure path and is lightly strained (0.75x) under the beast.
; Posture: 0 Normal, 1 Strained, 2 Silent, 3 RestoredScarred.














; P11 (2026-08-04): the Altmer sibling of the Nord/Redguard/Orc notification helpers.
; The fallback path is the reason every Altmer notification property has to be bound: a None
; record does not fail, it silently downgrades to a Prisma toast with no title.







Function EnsureUnifiedStartupChoice()
    ; Self-disable flag first: this runs on the 1s tick, and once startup has
    ; completed it stays complete forever, so check the cheap StorageUtil flag
    ; before paying the GetPlayerOriginRaceIndex() cross-script call.
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") == 1
        return
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace < 0
        return
    endIf

    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        ; 2026-08-13: not-save-safe update -- the pre-unified migration branch (the removed
        ; "keeps your existing startup state" notice, then its silent-complete successor) is
        ; gone. A fresh save never hit it; a pre-unified save now just runs the normal choice
        ; flow once. No backward-compat startup state is preserved.
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
        OriginRuntime.ApplyBosmerInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_BRETON
        OriginRuntime.ApplyBretonInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_REDGUARD
        OriginRuntime.ApplyRedguardInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_ORC
        OriginRuntime.ApplyOrcInitialChoice(optionValue, reason)
    elseIf originRace == ORIGIN_NORD
        OriginRuntime.ApplyNordInitialChoice(optionValue, reason)
    endIf
EndFunction

String Function BuildStartupRoadJournalLine(String pathLabel)
    if pathLabel == ""
        return "You've chosen your road."
    endIf
    return "You've chosen your road: " + pathLabel + "."
EndFunction






; WitchcraftExposure is not a one-way ratchet: occult signals add +25, but exposure
; also fades by 1 each dawn, so clean living slowly lowers cover. (The faster public
; Divine-cover path and the rupture creed-loss spell are record-backed refinements.)

; The Green Way is an outdoor covenant. Skyrim keeps pulling a Breton into cities
; and dungeons, so a live druidic covenant quietly frays without recent outdoor
; observance -- a small per-dawn drop mirroring the WitchcraftExposure fade.
; Pressure-only: no boon is withdrawn (DruidicStanding gates no reward).

; Green Way fraying applies to a live or contested druidic covenant only: the
; Druidic fork and the unresolved Werewolf fork. Excludes Betrayed (already under
; SyncBretonDruidicForkBetrayalSpell -- no double pressure) and any non-Green
; Breton (DruidicStanding is pressure-only and must not punish ordinary life).






















; Outdoor Good Daedra shrine prayer (Solstheim DLC2 Azura/Boethiah/Mephala altars).
; The twilight-window award is the spec'd role for the outdoor shrine; TryAward already
; enforces Dunmer origin, the dawn/dusk window, and the once-per-window-per-day cap.




; Owner ruling 2026-08-07: this feeds the ANCESTRAL layer (layer 1), not the Reclamation lane, so it
; fires on the first ancestor prayer of the devotional day REGARDLESS of patron. Before this was
; wired, a Dunmer with no active patron -- or on any repeat prayer that day -- recorded NO Ledger
; driver at all, because AwardActiveDunmerReclamationMemorySignal was the only curated signal on the
; path and it is patron-gated. PDV_RunSheet_Dunmer_V1.md:184 calls that empty Ledger a FAIL.
; The anti-farm cap lives HERE rather than at the call site, so a second call site cannot reintroduce
; farming. It uses the same day-int boundary encoding as the Reclamation-memory pulse above.




















String Function GetStartupCanonicalSummary(Int originRace)
    if originRace == ORIGIN_NORD
        return "You begin by choosing your pantheon baseline: the Old Ways of Kyne, Shor, Tsun, Stuhn, Mara, Orkey, Dibella, and Talos, or the Nine Divines as Skyrim now names them."
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

    return OriginRuntime.GetOriginRaceLabel(originRace)
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
        return "Kyne, Shor, Tsun, Stuhn, Mara, Orkey, Dibella, and Talos kept as the Old Ways."
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
        return "The Forebear carries Redguard identity into mixed public life, adapting without letting the old road break."
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
        return "The Old Ways lane keeps Kyne, Shor, Tsun, Stuhn, Mara, Orkey, Dibella, and Talos as your native pantheon baseline."
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction

String Function GetStartupOptionDetailText(Int originRace, Int optionValue)
    String text = OriginRuntime.GetOriginRaceLabel(originRace) + " - " + GetStartupOptionTitle(originRace, optionValue)
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

        optionsJson = optionsJson + "{\"option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionId(originRace, optionValue)) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionTitle(originRace, optionValue)) + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionSummary(originRace, optionValue)) + "\",\"description\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionDescription(originRace, optionValue)) + "\"}"
        i += 1
    endWhile

    String modeText = "info_only"
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        modeText = "explicit_choice"
    endIf

    String payload = "{\"mode\":\"startup\",\"startup\":{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\",\"race_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupRaceId(originRace)) + "\",\"startup_mode\":\"" + modeText + "\",\"options\":[" + optionsJson + "],\"default_option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionId(originRace, defaultOption)) + "\",\"advisory_line\":\"" + PDV_DevotionRules.JsonSafeString(STARTUP_ADVISORY_TEXT) + "\",\"confirm_required\":" + PDV_DevotionRules.BoolToJson(confirmRequired) + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetOriginRaceLabel(originRace) + " startup") + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupCanonicalSummary(originRace)) + "\"}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

Function SendPrismaMedallionPayload(Int originRace)
    if !AllowPrismaBlockingSurfaces
        return
    endIf

    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    String sectionsJson = OriginRuntime.GetMedallionSectionsJson(originRace)
    String raceLabel = OriginRuntime.GetOriginRaceLabel(originRace)
    String payload = "{\"mode\":\"medallion\",\"medallion\":{\"race_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupRaceId(originRace)) + "\""
    payload = payload + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(raceLabel + " Medallion") + "\""
    payload = payload + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString("The medallion shows the native roster. Only live, scorable entries can be chosen.") + "\""
    payload = payload + ",\"active_option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetActiveMedallionOptionId()) + "\""
    payload = payload + ",\"advisory_line\":\"" + PDV_DevotionRules.JsonSafeString("The medallion shows the roster; commitment comes through an offer.") + "\""
    payload = payload + ",\"sections\":[" + sectionsJson + "]}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

; ---------------------------------------------------------------------------
; Book of Days journal payload
; ---------------------------------------------------------------------------

; Map an in-game day integer to a Tamriel fiction date string.
; Tamriel has 12 months of 30 days each.

String Function BuildBookOfDaysPathInfo(Int originRace)
    return OriginRuntime.GetOriginRaceLabel(originRace) + " - " + GetBookOfDaysPathStatusLabel(originRace)
EndFunction

String Function GetBookOfDaysPathStatusLabel(Int originRace)
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Path Not Yet Chosen"
    endIf

    if originRace == ORIGIN_BRETON
        return OriginRuntime.GetBretonBookOfDaysPathStatusLabel()
    endIf

    PDV_DaedricPathBase activePact = DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return NormalizePublicDeityDisplayText(activePact.DeityName) + " Pact"
    endIf

    if _activeDeity && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        return GetPublicDeityDisplayName(_activeDeity)
    endIf

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD
        return OriginRuntime.GetBroadLaneDisplayName(originRace)
    endIf

    if originRace == ORIGIN_NORD
        return OriginRuntime.GetNordDevotionModeLabel()
    elseIf originRace == ORIGIN_ALTMER
        return "Crisis " + OriginRuntime.GetBookOfDaysAltmerCrisisLabel()
    elseIf originRace == ORIGIN_KHAJIIT
        Int focusValue = OriginRuntime.GetKhajiitFocusedEmphasis()
        if focusValue > KHAJIIT_FOCUS_NONE
            return OriginRuntime.GetKhajiitFocusLabel(focusValue) + " Lunar Focus"
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerPathLabel()
    elseIf originRace == ORIGIN_ARGONIAN
        return "Hist " + OriginRuntime.GetArgonianHistPostureLabel()
    elseIf originRace == ORIGIN_ORC
        return OriginRuntime.GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return OriginRuntime.GetRedguardSectLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return OriginRuntime.GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_DUNMER
        Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
        if reclamationFocus >= 0
            return OriginRuntime.GetDunmerReclamationFocusLabel(reclamationFocus) + " Reclamation Focus"
        endIf
        return "Ancestor Rites " + OriginRuntime.GetBookOfDaysDunmerAncestorLabel()
    endIf

    return "Path Unsettled"
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
    PDV_DaedricPathBase journalPact = DaedricRuntime.GetActiveDaedricPactPath()
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
    Int bretonPracticeTier = LedgerRuntime.TIER_NONE
    if originRace == ORIGIN_BRETON
        bretonPracticeTier = OriginRuntime.GetBretonPracticeTier(OriginRuntime.GetBretonTraditionValue())
    endIf
    if LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf
    if LedgerRuntime.PDV_GLO_ActivePiety
        pietyValue = LedgerRuntime.PDV_GLO_ActivePiety.GetValue()
    endIf

    PDV_DeityBase journalCommitment = ResolveBookOfDaysStandingDeity()
    if LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || originRace == ORIGIN_ARGONIAN
        ; A remembered prior deity must not hide the active broad pool.
        journalCommitment = None
    endIf
    if journalCommitment
        championThreshold = journalCommitment.ThresholdChampion
        tierValue = LedgerRuntime.GetTier(journalCommitment)
        pietyValue = LedgerRuntime.GetPiety(journalCommitment)
        if OriginRuntime.IsFocusedPantheonBoonSuspended()
            tierValue = LedgerRuntime.TIER_NONE
        endIf
    elseIf originRace == ORIGIN_BRETON
        if bretonPracticeTier > LedgerRuntime.TIER_NONE
            tierValue = bretonPracticeTier
            pietyValue = OriginRuntime.GetBretonPracticeCount(OriginRuntime.GetBretonTraditionValue()) as Float
        endIf
    elseIf originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        tierValue = PDV_ArgonianHistSubstrate.GetSubstrateTier()
        pietyValue = PDV_ArgonianHistSubstrate.GetMetric()
        championThreshold = 75.0
    else
        Int broadTier = OriginRuntime.GetBroadLaneTierForOrigin(originRace)
        if LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || broadTier > LedgerRuntime.TIER_NONE
            tierValue = broadTier
            pietyValue = OriginRuntime.GetBroadLaneStandingValue(originRace)
        endIf
    endIf

    String tierLabel = GetCurrentStandingLabel()
    if journalCommitment == None && originRace == ORIGIN_BRETON && bretonPracticeTier > LedgerRuntime.TIER_NONE
        tierLabel = GetPublicTierBand(bretonPracticeTier)
    elseIf journalCommitment == None && originRace == ORIGIN_ARGONIAN
        tierLabel = OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf journalCommitment == None && (LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || OriginRuntime.GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        tierLabel = OriginRuntime.GetBroadLaneStandingLabel(originRace, OriginRuntime.GetBroadLaneTierForOrigin(originRace))
    elseIf journalCommitment && OriginRuntime.IsFocusedPantheonBoonSuspended()
        tierLabel = "Wavering"
    endIf
    return GetPanelInstrumentJson(originRace, journalCommitment != None, tierValue, tierLabel, pietyValue, championThreshold)
EndFunction

; Build the Book of Days journal JSON payload.
; Entries are ordered oldest-first (index 0 = oldest, last index = newest).
String Function BuildJournalPayloadJson()
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    Int titleCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
    Int magnitudeCount = StorageUtil.IntListCount(None, "PDV.Diegetic.Journal.Magnitudes")
    Int sourceCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources")
    String entries = ""
    Int i = 0
    while i < count
        String line = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", i))
        Int gameDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        String tone = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", i))
        String symbol = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Symbols", i))
        String fictionDate = PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.JournalDayToFictionDate(gameDay))
        String entryTitle = ""
        if i < titleCount
            entryTitle = StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Titles", i)
        endIf
        if entryTitle == ""
            entryTitle = JournalToneToTitle(tone)
        endIf
        entryTitle = PDV_DevotionRules.JsonSafeString(entryTitle)
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
        if i < sourceCount
            String sourceText = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Sources", i))
            if sourceText != ""
                entry = entry + ",\"source\":\"" + sourceText + "\""
            endIf
        endIf
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
    j = j + ",\"by\":\"" + PDV_DevotionRules.JsonSafeString(GetJournalByline()) + "\""
    j = j + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(BuildBookOfDaysSummary(originRace)) + "\""
    j = j + ",\"survey\":\"" + PDV_DevotionRules.JsonSafeString(pathInfo) + "\""
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
Function AppendBookOfDaysEntry(String line, Int gameDay, String tone, String symbol, Bool headlinePinned, Int magnitude = 1, String titleText = "", Bool allowDuringRaceSetup = False, String sourceText = "")
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
    sourceText = NormalizePublicDeityDisplayText(sourceText)

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

    ; Existing saves predate the optional source list. Pad it before adding a new
    ; entry so a patch label can never attach to an older journal line.
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources") < count
        StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Sources", "", True)
    endWhile

    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Lines", line, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Days", gameDay, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Tones", tone, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Symbols", symbol, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Pinned", PDV_DevotionRules.BoolToInt(headlinePinned), True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Magnitudes", PDV_DevotionRules.ClampInt(magnitude, 1, 3), True)
    if titleText == ""
        titleText = BuildJournalEventTitle(tone, "")
    endIf
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Titles", titleText, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Sources", sourceText, True)

    PruneBookOfDays()

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

; 12.1 / fix-plan 5.4 (audit C1) -- the single biggest perf win in the mod.
;
; This ran 44 sequential ReplaceText passes over EVERY toast, journal line, panel string
; and deity name. ReplaceText is a per-CHARACTER scan: one StringUtil.GetNthChar plus one
; string "+=" (each concat re-interns under the engine's global string-table lock) for
; every character of every pass, plus a StringMatchesAt probe per position. A 100-character
; journal line therefore cost on the order of 40,000 native calls -- inside the worker tick.
;
; 43 of the 44 passes could not change anything. Papyrus String comparison is
; CASE-INSENSITIVE and StringMatchesAt compares with "!=", so
; ReplaceText(text, "akatosh", "Akatosh") matches "Akatosh" and writes back "Akatosh".
; Their only reachable effect was re-casing a name that arrived mis-cased -- and every
; name arrives from DeityName, which EnsureCanonicalDeityDisplayNames already repairs to
; the canonical spelling on load. So they were no-ops on the only input they could see.
;
; One of them was actively harmful: "the hist" -> "The Hist" also matched authored prose
; mid-sentence (PDV_Substrate_ArgonianHist's "You hear the Hist as if through deep mud.")
; and capitalised it to "You hear The Hist...". Dropping the casing passes repairs that
; line as a side effect.
;
; What remains is the one mapping that did real work: Nord Old Ways knows Arkay as Orkey.
; For a non-Nord player the whole function is now one GlobalVariable read and a return --
; UsesNordOldWaysDeityNames checks the origin race first and never touches the baseline
; track. ReplaceText and StringMatchesAt are kept: this pass still needs them.
String Function NormalizePublicDeityDisplayText(String sourceText)
    if !OriginRuntime.UsesNordOldWaysDeityNames()
        return sourceText
    endIf

    return PDV_DevotionRules.ReplaceText(sourceText, "arkay", "Orkey")
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
    if index < StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources")
        StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Sources", index)
    endIf
EndFunction

String Function GetJournalByline()
    PDV_DaedricPathBase pact = DaedricRuntime.GetActiveDaedricPactPath()
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

; RefreshOpenBookOfDays was retired 2026-08-07. It reconciled a stale "PDV.Diegetic.Journal.Open"
; flag against PDV_PrismaBridge.IsJournalVisible(), but PDV_MCM's journal-hotkey OnKeyDown already
; does exactly that inline, at the only moment the answer is consumed -- so it was a superseded
; duplicate with no caller, and three gates asserted on its NAME rather than on the behaviour.
; Those gates now assert the reconciliation against PDV_MCM.psc. Do not re-add a periodic variant:
; a tick that re-checks state already reconciled for free at the consumption point is pure cost.

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
    if toneKey == "crisis.onset"
        return "Auri-El's path is shaken"
    endIf
    if toneKey == "crisis.resolve"
        return "Auri-El's path holds"
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
    if toneKey == "focus.emergence"
        return "A road emerges"
    endIf
    if toneKey == "champion.act"
        return "A champion's gift"
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
    if toneKey == "crisis.resolve"
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
    if toneKey == "focus.emergence"
        return "good"
    endIf
    if toneKey == "champion.act"
        return "good"
    endIf
    if toneKey == "favor.loss"
        return "warning"
    endIf
    if toneKey == "curse.onset"
        return "warning"
    endIf
    if toneKey == "crisis.onset"
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

    String entry = "{\"option_id\":\"" + PDV_DevotionRules.JsonSafeString(optionId) + "\""
    entry = entry + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    entry = entry + ",\"kind\":\"" + PDV_DevotionRules.JsonSafeString(kindText) + "\""
    entry = entry + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    entry = entry + ",\"visible\":true"
    entry = entry + ",\"selectable\":" + PDV_DevotionRules.BoolToJson(selectable)
    entry = entry + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(summaryText) + "\""
    entry = entry + ",\"description\":\"" + PDV_DevotionRules.JsonSafeString(descriptionText) + "\""
    if disabledText != ""
        entry = entry + ",\"disabled_reason\":\"" + PDV_DevotionRules.JsonSafeString(disabledText) + "\""
    endIf
    entry = entry + "}"
    return entry
EndFunction

Bool Function IsMedallionDeitySelectable(PDV_DeityBase deity)
    if !deity || !LedgerRuntime.PDV_FLST_AllDeities
        return False
    endIf

    Int i = 0
    Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    while i < count
        if (LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase) == deity
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
        return LedgerRuntime.PDV_Kynareth
    elseIf optionId == "talos"
        return PDV_Talos
    elseIf optionId == "auri-el"
        return LedgerRuntime.GetDeityByName("Auri-El")
    elseIf optionId == "yffre"
        return PDV_Yffre
    elseIf optionId == "zen"
        return LedgerRuntime.PDV_Zen
    elseIf optionId == "baan-dar"
        return PDV_BaanDar
    endIf

    return None
EndFunction

String Function GetMedallionOptionIdForDeity(PDV_DeityBase deity)
    if deity == PDV_Kyne
        return "kyne"
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return "kynareth"
    elseIf deity == PDV_Talos
        return "talos"
    elseIf deity == PDV_Yffre
        return "yffre"
    elseIf deity == LedgerRuntime.PDV_Zen
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





















; Prisma symbol for a Bosmer path state (used before the path is active, so we can't
; rely on _activeDeity). Old Contract and Living Story both center on Y'ffre.





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

EndFunction





; Builds a full dev-facing devotion snapshot and writes it to a text file so
; beta testers can attach one file to a bug report instead of digging for logs
; or numbers. Returns the written filename, or "" if the write failed.
String Function GetBuildVersion()
    return PDV_BUILD_VERSION
EndFunction

String Function OnOffForReport(Int v)
    if v != 0
        return "On"
    endIf
    return "Off"
EndFunction

String Function GetExperienceModeLabelForReport()
    if LedgerRuntime.PDV_ModePresetRef
        return LedgerRuntime.PDV_ModePresetRef.GetModeLabel()
    endIf
    return "Pilgrim's Path"
EndFunction

String Function PendingFormLabelForReport(String storageKey)
    if StorageUtil.GetFormValue(None, storageKey) != None
        return "set"
    endIf
    return "none"
EndFunction

String Function ExportDevotionReport()
    String nl = "\n"
    Int originRace = GetPlayerOriginRaceIndex()
    Float gameDay = Utility.GetCurrentGameTime()

    String report = "=== Devotion Bug Report Snapshot ==="
    report = report + nl + "Generated in-game. Attach this file to your report."
    report = report + nl
    report = report + nl + "-- Versions --"
    report = report + nl + "Devotion build: " + PDV_BUILD_VERSION
    report = report + nl + "Framework schema: " + FRAMEWORK_SCHEMA_VERSION
    report = report + nl + "Likes/dislikes: " + LedgerRuntime.LIKES_DISLIKES_VERSION
    report = report + nl + "Prince LD: " + PRINCE_LD_VERSION
    report = report + nl + "Daedric pact: " + DAEDRIC_PACT_VERSION
    report = report + nl + "PapyrusUtil: " + PapyrusUtil.GetVersion()
    report = report + nl + "In-game day: " + (gameDay as Int)
    report = report + nl
    report = report + nl + "-- Environment --"
    report = report + nl + "Experience Mode: " + GetExperienceModeLabelForReport()
    report = report + nl + "Custom race mapping: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.CustomRaceMapping", 1))
    report = report + nl + "Origin detect: " + DebugGetOriginDiagnostic()
    report = report + nl + "Survival integration: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.SurvivalContextEnabled", 1))
    report = report + nl + "CC integration: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.CCContentEnabled", 1))
    report = report + nl
    report = report + nl + "-- Summary --"
    report = report + nl + "Race: " + OriginRuntime.GetOriginRaceLabel(originRace) + " (index " + originRace + ")"
    report = report + nl + "Summary: " + GetPlayerMcmSummaryLine()
    report = report + nl + "Mode: " + GetPlayerMcmModeLine()
    report = report + nl + "Patron: " + GetPlayerMcmPatronLine() + " | state " + LedgerRuntime.GetPatronState() + " | activeIndex " + LedgerRuntime.GetActiveDeityIndex()
    report = report + nl + "Standing: " + GetPlayerMcmStandingLine()
    report = report + nl + "Curse: " + GetPlayerMcmCurseLine()
    report = report + nl + "Favor: " + FavorRuntime.GetPlayerMcmFavorLine()
    report = report + nl + "Neglect: " + LedgerRuntime.GetPlayerMcmNeglectLine()
    report = report + nl + "Startup: " + GetStartupMcmLine()
    report = report + nl
    report = report + nl + "-- Survey readout --"
    report = report + nl + GetSurveyDevotionText()
    report = report + nl
    report = report + nl + "-- Per-deity ledger (tier: 0 None 1 Seeker 2 Devoted 3 Champion) --"
    report = report + nl + "deity [index] | tier | piety | scratch"

    Int count = LedgerRuntime.GetDeityCount()
    Int i = 0
    while i < count
        PDV_DeityBase deityEntry = LedgerRuntime.GetDeityAtListIndex(i)
        if deityEntry
            report = report + nl + deityEntry.DeityName + " [" + deityEntry.DeityIndex + "] | " + LedgerRuntime.GetTier(deityEntry) + " | " + LedgerRuntime.GetPiety(deityEntry) + " | +" + LedgerRuntime.GetPietyToday(deityEntry)
        endIf
        i += 1
    endWhile

    report = report + nl
    report = report + nl + "-- Diagnostics --"
    report = report + nl + "Breton tradition: " + StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    report = report + nl + "Daedric pending lapse: " + PendingFormLabelForReport("PDV.Daedric.PendingLapse")
    report = report + nl + "Daedric pending activation: " + PendingFormLabelForReport("PDV.Daedric.PendingActivation")
    report = report + nl + "Last diegetic dispatch: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastDispatch", "none")
    report = report + nl + "Last diegetic tone: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastTone", "none")
    report = report + nl + "Last diegetic skipped: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastSkipped", "none")
    report = report + nl
    report = report + nl + "-- Logs (for deeper diagnosis) --"
    report = report + nl + "If asked, also attach the Papyrus log and any SKSE crash log:"
    report = report + nl + "Papyrus: Documents\\My Games\\Skyrim Special Edition\\Logs\\Script\\Papyrus.0.log"
    report = report + nl + "SKSE crash: Documents\\My Games\\Skyrim Special Edition\\SKSE\\crash-*.log"
    report = report + nl + "Papyrus logging is OFF by default; the beta guide explains how to turn it on."
    report = report + nl
    report = report + nl + "=== End of report ==="

    String fileName = "PDV_DevotionReport.txt"
    Bool wrote = MiscUtil.WriteToFile(fileName, report, False, False)
    ; D1 sweep. Gated like every other PDV trace. Nothing is lost by it: the function
    ; already returns the filename on success and "" on failure, which is what the MCM
    ; button surfaces to the user.
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] ExportDevotionReport wrote=" + wrote + " file=" + fileName)
    endIf
    if wrote
        return fileName
    endIf
    return ""
EndFunction

String Function GetSurveyDevotionText()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace < 0
        return LedgerRuntime.AppendRecentDevotionEvents("Devotion has not settled yet. Wait a moment, then survey again.")
    endIf

    ; Hidden Art is a layered Breton tradition: its Survey owns the base practice and
    ; exposure readout, then appends its integrated Prince through the patron sentence.
    if originRace == ORIGIN_BRETON
        return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
    endIf

    ; Prince-wins for races without a layered pact tradition. The tier>0 guard inside
    ; GetActiveDaedricPactPath prevents a stale-pointer ghost pact.
    PDV_DaedricPathBase pactPath = DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        return LedgerRuntime.AppendRecentDevotionEvents(DaedricRuntime.GetDaedricSurveyText(pactPath))
    endIf

    if originRace != ORIGIN_NORD
        if originRace == ORIGIN_ALTMER
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_KHAJIIT
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_BOSMER
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_ARGONIAN
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_ORC
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_REDGUARD
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_IMPERIAL
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        elseIf originRace == ORIGIN_DUNMER
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetSurveyFragment())
        endIf

        return LedgerRuntime.AppendRecentDevotionEvents("Your devotion is watched. Standing: " + GetCurrentStandingBand() + ".")
    endIf

    String text = OriginRuntime.GetSurveyFragment()
    String scarText = OriginRuntime.GetNordScarLabel()
    if scarText != ""
        text = text + "\n\n" + scarText
    endIf

    return LedgerRuntime.AppendRecentDevotionEvents(text)
EndFunction




String Function GetPlayerMcmSummaryLine()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Startup pending | " + GetStartupMcmLine()
    endIf

    ; Prince-wins: an active pact is the single commitment (patron severed under
    ; exclusivity), surfaced for all races.
    PDV_DaedricPathBase summaryPact = DaedricRuntime.GetActiveDaedricPactPath()
    if summaryPact
        return NormalizePublicDeityDisplayText(summaryPact.DeityName) + " | Pact | " + GetCurrentStandingLabel()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return OriginRuntime.GetNordDevotionModeLabel() + " | " + GetCurrentStandingLabel() + " | " + OriginRuntime.GetPlayerCursePublicLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return "Altmer | " + OriginRuntime.GetAltmerCrisisStateLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return "Khajiit | " + OriginRuntime.GetKhajiitFocusLabel(OriginRuntime.GetKhajiitFocusedEmphasis()) + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return "Bosmer | " + OriginRuntime.GetBosmerPathLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Argonian | " + OriginRuntime.GetArgonianHistPostureLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ORC
        return "Orc | " + OriginRuntime.GetOrcLifeModeLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
        return "Redguard | " + OriginRuntime.GetRedguardSectLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        return "Imperial | " + OriginRuntime.GetImperialConcordatLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        return "Breton | " + OriginRuntime.GetBretonTraditionLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        return "Dunmer | " + OriginRuntime.GetDunmerAncestorLayerLabel() + " | " + GetCurrentStandingLabel()
    endIf

    return OriginRuntime.GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + " | " + LedgerRuntime.GetPatronStateLabel() + " | " + GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmPatronLine()
    ; An active Prince pact is the single commitment (patron severed under exclusivity);
    ; surface it here so the Prisma panel "patron" field matches the Survey.
    PDV_DaedricPathBase pactPath = DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        return NormalizePublicDeityDisplayText(pactPath.DeityName)
    endIf

    if _activeDeity
        return GetPublicDeityDisplayName(_activeDeity)
    endIf

    return LedgerRuntime.GetPatronStateLabel()
EndFunction

String Function GetPlayerMcmStandingLine()
    return GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmModeLine()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return GetStartupMcmLine()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return OriginRuntime.GetNordDevotionModeLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return OriginRuntime.GetAltmerCrisisStateLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return OriginRuntime.GetKhajiitFocusLabel(OriginRuntime.GetKhajiitFocusedEmphasis())
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerPathLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Hist " + OriginRuntime.GetArgonianHistPostureLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ORC
        return OriginRuntime.GetOrcLifeModeLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD
        return OriginRuntime.GetRedguardSectLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
        return OriginRuntime.GetImperialConcordatLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BRETON
        return OriginRuntime.GetBretonTraditionLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_DUNMER
        return OriginRuntime.GetDunmerAncestorLayerLabel()
    endIf

    return LedgerRuntime.GetPatronStateLabel()
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
    String curseLabel = OriginRuntime.GetPlayerCursePublicLabel()
    if curseLabel == "None"
        return "No curse"
    endIf
    return curseLabel
EndFunction







String Function GetCurrentStandingLabel()
    if OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Wavering"
    endIf
    Int tierValue = LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = DaedricRuntime.GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = LedgerRuntime.GetTier(_activeDeity)
    elseIf OriginRuntime.GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        tierValue = OriginRuntime.GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
    elseIf LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf

    if !_activeDeity && !standingPact && OriginRuntime.GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        return OriginRuntime.GetBroadLaneStandingLabel(GetPlayerOriginRaceIndex(), tierValue)
    endIf

    if tierValue >= LedgerRuntime.TIER_CHAMPION
        return "Champion"
    elseIf tierValue == LedgerRuntime.TIER_DEVOTED
        return "Devoted"
    elseIf tierValue == LedgerRuntime.TIER_SEEKER
        return "Seeker"
    endIf

    return "Unproven"
EndFunction

; Player-facing devotional band for the active standing (Architecture v3 Section 2.1),
; mirroring GetCurrentStandingLabel's tier resolution. Survey + player surfaces use this;
; GetCurrentStandingLabel keeps the internal Seeker/Champion words for dev/MCM only.
String Function GetCurrentStandingBand()
    if OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Distant"
    endIf
    Int tierValue = LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = DaedricRuntime.GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = LedgerRuntime.GetTier(_activeDeity)
    elseIf OriginRuntime.GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        tierValue = OriginRuntime.GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
    elseIf LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return GetPublicTierBand(tierValue)
EndFunction











; Per-god standing line for the Khajiit moon-paths MCM readout. Shows standing,
; raw piety, and markers for the focused path and current god in strength.



; Player-facing path name. PDV_BosmerPathTrack's StateLabels are internal PascalCase
; tokens ("OldContract"), and EVERY caller of this function is a player surface --
; Book of Days, Prisma toast, Survey, panel payload -- so the token was reaching the
; player as one word. Map to the authored guide copy here instead. The article stays
; in the prose ("...is the Old Contract.") and out of the label, so "Exchange" is
; correct and "The Exchange" would render "is the The Exchange."


; Green Pact compliance band for the Old Contract survey readout (Architecture v3
; GreenPactCompliance thresholds: Apostate 0-19 / Lapsed 20-49 / Observant 50-79 / Strict 80-100).

































String Function DebugGetPatternProvingSummary()
    String summary = "Concordat=" + OriginRuntime.GetConcordatSummary()
    summary = summary + "; Bosmer=" + OriginRuntime.GetBosmerSummary()
    summary = summary + "; DunmerAncestor=" + OriginRuntime.GetDunmerAncestorSummary()
    summary = summary + "; KhajiitLunar=" + OriginRuntime.GetKhajiitLunarSummary()
    summary = summary + "; ArgonianHist=" + OriginRuntime.GetArgonianHistSummary()
    summary = summary + "; Altmer=" + OriginRuntime.GetAltmerSummary()
    summary = summary + "; Orc=" + OriginRuntime.GetOrcSummary()
    summary = summary + "; Redguard=" + OriginRuntime.GetRedguardSummary()
    summary = summary + "; Favor=" + FavorRuntime.GetContextualFavorSummary()
    summary = summary + "; Commitment=" + LedgerRuntime.GetCommitmentSummary()
    summary = summary + "; Neglect=" + LedgerRuntime.GetNeglectSummary()
    summary = summary + "; Hircine=" + DaedricRuntime.GetHircineSummary()
    summary = summary + "; Curse=" + OriginRuntime.GetCurseStateSummary()
    summary = summary + "; CurseHandlers=" + OriginRuntime.GetCurseHandlerSummary()
    return summary
EndFunction

; One labeled pattern-summary section by index (0-13), so the MCM can page the
; readout instead of dumping all 14 into a single overflowing message box.
String Function DebugGetPatternSummarySection(Int sectionIndex)
    if sectionIndex == 0
        return "Concordat: " + OriginRuntime.GetConcordatSummary()
    elseIf sectionIndex == 1
        return "Bosmer: " + OriginRuntime.GetBosmerSummary()
    elseIf sectionIndex == 2
        return "Dunmer ancestor: " + OriginRuntime.GetDunmerAncestorSummary()
    elseIf sectionIndex == 3
        return "Khajiit lunar: " + OriginRuntime.GetKhajiitLunarSummary()
    elseIf sectionIndex == 4
        return "Argonian Hist: " + OriginRuntime.GetArgonianHistSummary()
    elseIf sectionIndex == 5
        return "Altmer: " + OriginRuntime.GetAltmerSummary()
    elseIf sectionIndex == 6
        return "Orc: " + OriginRuntime.GetOrcSummary()
    elseIf sectionIndex == 7
        return "Redguard: " + OriginRuntime.GetRedguardSummary()
    elseIf sectionIndex == 8
        return "Favor: " + FavorRuntime.GetContextualFavorSummary()
    elseIf sectionIndex == 9
        return "Commitment: " + LedgerRuntime.GetCommitmentSummary()
    elseIf sectionIndex == 10
        return "Neglect: " + LedgerRuntime.GetNeglectSummary()
    elseIf sectionIndex == 11
        return "Hircine: " + DaedricRuntime.GetHircineSummary()
    elseIf sectionIndex == 12
        return "Curse: " + OriginRuntime.GetCurseStateSummary()
    elseIf sectionIndex == 13
        return "Curse handlers: " + OriginRuntime.GetCurseHandlerSummary()
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

















String Function DebugGetDecaySummaryByIndex(Int deityIndex)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        return "missing deity " + deityIndex
    endIf

    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float lastEvent = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    Int lastDecayDay = StorageUtil.GetIntValue(deityForm, "PDV.LastDecayAppliedDay")
    Float multiplier = 1.0
    if LedgerRuntime.IsBroadWorshipActive()
        multiplier = LedgerRuntime.BROAD_WORSHIP_DECAY_MULTIPLIER
    endIf

    return "deity=" + deity.DeityName + ";state=" + LedgerRuntime.GetPatronStateLabel() + ";active=" + PDV_DevotionRules.BoolToInt(deity == _activeDeity) + ";broad=" + PDV_DevotionRules.BoolToInt(LedgerRuntime.IsBroadWorshipActive()) + ";p=" + PDV_DevotionRules.FormatTwoDecimals(piety) + ";tier=" + LedgerRuntime.GetTier(deity) + ";lastEvent=" + PDV_DevotionRules.FormatTwoDecimals(lastEvent) + ";lastDecayDay=" + lastDecayDay + ";rate=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * OriginRuntime.GetCurseGainMultiplier(deity) * DaedricRuntime.GetDaedricStigmaGainMultiplier(deity)) + ";floor=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.GetDecayFloorForDeity(deity, piety))
EndFunction






; Real Skyrim moon phase: the engine renders an 8-phase, 24-day cycle driven by
; GameDaysPassed % 24, advancing the visible phase at midday. We replicate the
; Creation Kit GetCurrentMoonphase boundaries exactly so this index matches the
; moon the player actually sees (full moon on the wrap, new moon mid-cycle), then
; map it to a 1-8 index for the Lattice. gameDay comes from GetCurrentGameTime
; (game days, fractional); +0.5 rounds to the nearest day = the midday rollover.

; fix-plan 4.2. The two shared anti-farm helpers below are the single busiest "daily"
; gate in the mod -- dozens of signals route through them. They ran on the raw-midnight
; day while dawn consolidation runs on the 06:00 devotional day, so a midnight crossed
; during sleep reset every daily budget BEFORE the dawn pass that reads it. Both now use
; the same zero-reserved +2 devotional stamp as the rest of the tree; a stamp is >= 1 by
; construction, so the StorageUtil default of 0 can never collide with a real day.
Float Function ConsumeDailyRepeatMultiplier(String keyPrefix)
    Int currentDay = LedgerRuntime.GetDevotionalDay() + 2
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
    Int currentDay = LedgerRuntime.GetDevotionalDay() + 2
    String dayKey = keyPrefix + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, -1) == currentDay
        StorageUtil.AdjustIntValue(None, keyPrefix + ".RejectCount", 1)
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDay)
    return True
EndFunction



Form Function GetDeityFormOrNone(PDV_DeityBase deity)
    if deity
        return deity as Form
    endIf
    return None
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
    if deity.DeityName == "Phynaster"
        return "phynaster"
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

; ===========================================================================
; SPID religious recognition and KID item-action routing
; ===========================================================================

Int Property RECOGNITION_REACTION_NEUTRAL = 0 AutoReadOnly
Int Property RECOGNITION_REACTION_ENEMY = 1 AutoReadOnly
Int Property RECOGNITION_REACTION_ALLY = 2 AutoReadOnly
Int Property RECOGNITION_REACTION_FRIEND = 3 AutoReadOnly
Int Property RECOGNITION_IDENTITY_COUNT = 57 AutoReadOnly

; NPC religious recognition defaults OFF (missing key -> disabled). The feature is
; unadvertised in 1.5.0 and opt-in from the MCM while its in-game reactions are
; validated further; an explicit MCM toggle still persists via the same keys.
Bool Function NpcReligiousRecognitionEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Recognition.Disabled", 1) != 1
EndFunction

Bool Function NpcHostileRecognitionEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Recognition.HostilesDisabled", 1) != 1
EndFunction

Function SetNpcReligiousRecognitionEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Recognition.Disabled", PDV_DevotionRules.BoolToInt(!enabled))
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
EndFunction

Function SetNpcHostileRecognitionEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Recognition.HostilesDisabled", PDV_DevotionRules.BoolToInt(!enabled))
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
EndFunction

String Function GetNpcRecognitionStatusLine()
    if !NpcReligiousRecognitionEnabled()
        return "Off"
    endIf
    String owner = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    if owner != ""
        return "Managed by " + owner
    endIf
    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    if identityIndex < 0 || band <= LedgerRuntime.TIER_NONE
        return "On - no public standing"
    endIf
    return GetRecognitionIdentityDisplayName(identityIndex) + " - " + GetPublicTierBand(band) + " (" + GetNpcRecognitionRelationLabel(band) + ")"
EndFunction

String Function GetNpcRecognitionRelationLabel(Int band)
    if band >= LedgerRuntime.TIER_CHAMPION
        return "ally"
    elseIf band >= LedgerRuntime.TIER_DEVOTED
        return "friend"
    endIf
    return "neutral"
EndFunction

String Function GetNpcRecognitionAdvisory(Int identityIndex, Int band, Bool recognitionEnabled, String ownerName)
    if !recognitionEnabled
        return "Public religious recognition is off."
    elseIf ownerName != ""
        return "Religious recognition is managed by " + ownerName + "."
    elseIf identityIndex < 0
        return "No public religious identity is active."
    elseIf band >= LedgerRuntime.TIER_CHAMPION
        return "Adherents may regard you as an ally."
    elseIf band >= LedgerRuntime.TIER_DEVOTED
        return "Adherents may regard you as a friend."
    endIf
    return "Adherents remain neutral until your standing is Faithful."
EndFunction

String Function GetNpcRecognitionPanelJson()
    Bool recognitionEnabled = NpcReligiousRecognitionEnabled()
    String ownerName = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    String identityName = GetRecognitionIdentityDisplayName(identityIndex)
    String bandName = GetPublicTierBand(band)
    String statusText = GetNpcRecognitionStatusLine()
    String advisory = GetNpcRecognitionAdvisory(identityIndex, band, recognitionEnabled, ownerName)
    String j = "{\"enabled\":" + PDV_DevotionRules.BoolToJson(recognitionEnabled)
    j = j + ",\"managed\":" + PDV_DevotionRules.BoolToJson(ownerName != "")
    j = j + ",\"status\":\"" + PDV_DevotionRules.JsonSafeString(statusText) + "\""
    j = j + ",\"identity\":\"" + PDV_DevotionRules.JsonSafeString(identityName) + "\""
    j = j + ",\"band\":\"" + PDV_DevotionRules.JsonSafeString(bandName) + "\""
    j = j + ",\"advisory\":\"" + PDV_DevotionRules.JsonSafeString(advisory) + "\"}"
    return j
EndFunction

Function EnsureRecognitionModEvents()
    UnregisterForModEvent("PDV.Recognition.Claim")
    UnregisterForModEvent("PDV.Recognition.Release")
    RegisterForModEvent("PDV.Recognition.Claim", "OnRecognitionClaim")
    RegisterForModEvent("PDV.Recognition.Release", "OnRecognitionRelease")
EndFunction

Event OnRecognitionClaim(String eventName, String strArg, Float numArg, Form sender)
    if strArg == ""
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Recognition.Owner", strArg)
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
    Trace(1, "NPC religious recognition claimed by " + strArg + ".")
EndEvent

Event OnRecognitionRelease(String eventName, String strArg, Float numArg, Form sender)
    String owner = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    if owner == "" || !RecognitionOwnersMatch(owner, strArg)
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Recognition.Owner", "")
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
    Trace(1, "NPC religious recognition released by " + strArg + ".")
EndEvent

Bool Function RecognitionOwnersMatch(String firstOwner, String secondOwner)
    Int ownerLength = StringUtil.GetLength(firstOwner)
    if ownerLength != StringUtil.GetLength(secondOwner)
        return false
    endIf
    Int index = 0
    while index < ownerLength
        Int firstOrd = StringUtil.AsOrd(StringUtil.GetNthChar(firstOwner, index))
        Int secondOrd = StringUtil.AsOrd(StringUtil.GetNthChar(secondOwner, index))
        if firstOrd >= 65 && firstOrd <= 90
            firstOrd += 32
        endIf
        if secondOrd >= 65 && secondOrd <= 90
            secondOrd += 32
        endIf
        if firstOrd != secondOrd
            return false
        endIf
        index += 1
    endWhile
    return true
EndFunction

Function InvalidateNpcReligiousRecognition()
    StorageUtil.SetIntValue(None, "PDV.Recognition.LastSignature", -9999)
EndFunction

Faction Function GetRecognitionPlayerFaction()
    EnsureRecognitionForms()
    return _recognitionPlayerFaction
EndFunction

Faction Function GetRecognitionCohortFaction(Int identityIndex)
    if identityIndex < 0 || identityIndex >= RECOGNITION_IDENTITY_COUNT
        return None
    endIf
    EnsureRecognitionForms()
    return _recognitionCohortFactions[identityIndex]
EndFunction

Function EnsureRecognitionForms()
    if _recognitionFormsResolved && _recognitionPlayerFaction && _recognitionCohortFactions.Length == RECOGNITION_IDENTITY_COUNT
        return
    endIf
    if _recognitionCohortFactions.Length != RECOGNITION_IDENTITY_COUNT
        _recognitionCohortFactions = new Faction[57]
    endIf
    _recognitionPlayerFaction = Game.GetFormFromFile(0x00071756, "Devotion.esp") as Faction
    Int identityIndex = 0
    Bool allResolved = _recognitionPlayerFaction != None
    while identityIndex < RECOGNITION_IDENTITY_COUNT
        if !_recognitionCohortFactions[identityIndex]
            _recognitionCohortFactions[identityIndex] = Game.GetFormFromFile(0x00071757 + identityIndex, "Devotion.esp") as Faction
        endIf
        if !_recognitionCohortFactions[identityIndex]
            allResolved = False
        endIf
        identityIndex += 1
    endWhile
    _recognitionFormsResolved = allResolved
EndFunction

Function SetRecognitionPair(Faction cohort, Faction playerFaction, Int reaction)
    if !cohort || !playerFaction
        return
    endIf
    cohort.SetReaction(playerFaction, reaction)
    playerFaction.SetReaction(cohort, reaction)
EndFunction

Function ResetNpcRecognitionRelations(Faction playerFaction)
    Int i = 0
    while i < RECOGNITION_IDENTITY_COUNT
        SetRecognitionPair(GetRecognitionCohortFaction(i), playerFaction, RECOGNITION_REACTION_NEUTRAL)
        i += 1
    endWhile
EndFunction

Function SyncNpcReligiousRecognition()
    Faction playerFaction = GetRecognitionPlayerFaction()
    Actor playerRef = Game.GetPlayer()
    if !playerFaction || !playerRef
        return
    endIf
    if !playerRef.IsInFaction(playerFaction)
        playerRef.AddToFaction(playerFaction)
    endIf

    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    String ownerName = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    Bool owned = ownerName != ""
    Bool recognitionEnabled = NpcReligiousRecognitionEnabled()
    Bool hostileRecognitionEnabled = NpcHostileRecognitionEnabled()
    Int signature = identityIndex * 100 + band * 10 + PDV_DevotionRules.BoolToInt(recognitionEnabled) + (PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) * 2) + (PDV_DevotionRules.BoolToInt(owned) * 4)
    if StorageUtil.GetIntValue(None, "PDV.Recognition.LastSignature", -9999) == signature
        return
    endIf

    ResetNpcRecognitionRelations(playerFaction)
    if recognitionEnabled && !owned && identityIndex >= 0
        if band >= LedgerRuntime.TIER_CHAMPION
            SetRecognitionPair(GetRecognitionCohortFaction(identityIndex), playerFaction, RECOGNITION_REACTION_ALLY)
            if hostileRecognitionEnabled
                ApplyNpcRecognitionHardRivals(identityIndex, playerFaction)
            endIf
        elseIf band >= LedgerRuntime.TIER_DEVOTED
            SetRecognitionPair(GetRecognitionCohortFaction(identityIndex), playerFaction, RECOGNITION_REACTION_FRIEND)
        endIf
    endIf

    StorageUtil.SetIntValue(None, "PDV.Recognition.LastSignature", signature)
    EmitNpcRecognitionState(identityIndex, band, hostileRecognitionEnabled, ownerName)
    SurfaceNpcRecognitionTransition(identityIndex, band, recognitionEnabled, hostileRecognitionEnabled, ownerName)
    RequestPanelRefresh()
EndFunction

Function SurfaceNpcRecognitionTransition(Int identityIndex, Int band, Bool recognitionEnabled, Bool hostileRecognitionEnabled, String ownerName)
    Bool owned = ownerName != ""
    Int presentationSignature = identityIndex * 1000 + band * 100 + PDV_DevotionRules.BoolToInt(recognitionEnabled) * 10 + PDV_DevotionRules.BoolToInt(owned) * 20 + PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) * 40
    if StorageUtil.GetIntValue(None, "PDV.Recognition.PresentationInitialized") != 1
        StorageUtil.SetIntValue(None, "PDV.Recognition.PresentationInitialized", 1)
        StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature", presentationSignature)
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Recognition.LastPresentedSignature", -9999) == presentationSignature
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature", presentationSignature)
    ; Public recognition ships OFF. When neither friendly nor hostile recognition is enabled there
    ; is nothing to announce, so suppress the transition toast/journal -- a disabled feature must not
    ; nag on every patron/tier change. The signature above is still recorded, so the first change
    ; AFTER the owner enables recognition still surfaces cleanly.
    if !recognitionEnabled && !hostileRecognitionEnabled
        return
    endIf
    String identityName = GetRecognitionIdentityDisplayName(identityIndex)
    String bandName = GetPublicTierBand(band)
    String bodyText = GetNpcRecognitionAdvisory(identityIndex, band, recognitionEnabled, ownerName)
    if recognitionEnabled && ownerName == "" && identityIndex >= 0
        bodyText = identityName + " - " + bandName + ". " + bodyText
        if hostileRecognitionEnabled && band >= LedgerRuntime.TIER_CHAMPION
            bodyText = bodyText + " Explicit rival adherents may regard you as an enemy."
        endIf
    endIf
    SendPrismaToast("journal", "neutral", "Public recognition changed", bodyText)
    AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "reorientation", "journal", False, 1, "Public recognition changed")
EndFunction

Function ApplyNpcRecognitionHardRivals(Int identityIndex, Faction playerFaction)
    ; Explicit hard rivalries only. Enemy is a disposition relation, not an
    ; aggression package, so this never creates attack-on-sight behaviour.
    if identityIndex == 35 ; Molag Bal
        SetRecognitionPair(GetRecognitionCohortFaction(33), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 33 ; Meridia
        SetRecognitionPair(GetRecognitionCohortFaction(35), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 20 ; Malacath
        SetRecognitionPair(GetRecognitionCohortFaction(21), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 21 ; Trinimac
        SetRecognitionPair(GetRecognitionCohortFaction(20), playerFaction, RECOGNITION_REACTION_ENEMY)
    endIf

    if DaedricRuntime.GetActiveDaedricPactPath()
        SetRecognitionPair(GetRecognitionCohortFaction(13), playerFaction, RECOGNITION_REACTION_ENEMY)
    endIf
EndFunction

Function EmitNpcRecognitionState(Int identityIndex, Int band, Bool hostileRecognitionEnabled, String ownerName)
    Int handle = ModEvent.Create("PDV.Recognition.State")
    if handle == 0
        return
    endIf
    ModEvent.PushString(handle, GetRecognitionIdentityKey(identityIndex))
    ModEvent.PushString(handle, GetPublicTierBand(band))
    ModEvent.PushFloat(handle, PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) as Float)
    ModEvent.PushString(handle, ownerName)
    ModEvent.Send(handle)
EndFunction

Int Function ResolveNpcRecognitionIdentity()
    PDV_DaedricPathBase activePact = DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return GetRecognitionDaedricIndex(activePact.DeityName)
    endIf
    if _activeDeity
        return GetRecognitionFocusedIndex(_activeDeity)
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD
        return GetRecognitionBroadIndex(GetPlayerOriginRaceIndex())
    endIf
    return -1
EndFunction

Int Function ResolveNpcRecognitionBand(Int identityIndex)
    if identityIndex < 0
        return LedgerRuntime.TIER_NONE
    endIf
    PDV_DaedricPathBase activePact = DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return activePact.GetStoredTier()
    endIf
    if _activeDeity
        return LedgerRuntime.GetTier(_activeDeity)
    endIf
    return GetRecognitionBroadTier(GetPlayerOriginRaceIndex())
EndFunction

Int Function GetRecognitionFocusedIndex(PDV_DeityBase deity)
    if deity == PDV_Talos
        return 0
    elseIf deity == PDV_AuriEl
        return 1
    elseIf deity == PDV_Yffre
        return 2
    elseIf deity == LedgerRuntime.PDV_Zen
        return 3
    elseIf deity == PDV_BaanDar
        return 4
    elseIf deity == PDV_Kyne
        return 5
    elseIf deity == PDV_Azura
        return 6
    elseIf deity == PDV_Khenarthi
        return 7
    elseIf deity == PDV_Rajhin
        return 8
    elseIf deity == PDV_Alkosh
        return 9
    elseIf deity == LedgerRuntime.PDV_Akatosh
        return 10
    elseIf deity == LedgerRuntime.PDV_Mara
        return 11
    elseIf deity == LedgerRuntime.PDV_Arkay
        return 12
    elseIf deity == LedgerRuntime.PDV_Stendarr
        return 13
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return 14
    elseIf deity == LedgerRuntime.PDV_Dibella
        return 15
    elseIf deity == LedgerRuntime.PDV_Julianos
        return 16
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return 17
    elseIf deity == PDV_Hist
        return 18
    elseIf deity == PDV_Sithis
        return 19
    elseIf deity == PDV_Malacath
        return 20
    elseIf deity == PDV_Trinimac
        return 21
    elseIf deity == PDV_Boethiah
        return 22
    elseIf deity == PDV_Mephala
        return 23
    elseIf deity == PDV_Magnus
        return 24
    elseIf deity == PDV_Xarxes
        return 25
    elseIf deity == PDV_Tuwhacca
        return 26
    elseIf deity == PDV_HoonDing
        return 27
    elseIf deity == PDV_Leki
        return 28
    elseIf deity == PDV_Shor
        return 29
    elseIf deity == PDV_Tsun
        return 30
    elseIf deity == PDV_Stuhn
        return 31
    elseIf deity == PDV_Syrabane
        return 32
    endIf
    return -1
EndFunction

Int Function GetRecognitionDaedricIndex(String deityName)
    if deityName == "Azura" || deityName == "Azurah"
        return 6
    elseIf deityName == "Malacath"
        return 20
    elseIf deityName == "Boethiah"
        return 22
    elseIf deityName == "Mephala"
        return 23
    elseIf deityName == "Meridia"
        return 33
    elseIf deityName == "Hircine"
        return 34
    elseIf deityName == "Molag Bal" || deityName == "Molag"
        return 35
    elseIf deityName == "Nocturnal"
        return 36
    elseIf deityName == "Hermaeus Mora" || deityName == "Mora"
        return 37
    elseIf deityName == "Mehrunes Dagon" || deityName == "Dagon"
        return 38
    elseIf deityName == "Sheogorath" || deityName == "Sheo"
        return 39
    elseIf deityName == "Namira"
        return 40
    elseIf deityName == "Sanguine"
        return 41
    elseIf deityName == "Clavicus Vile" || deityName == "Vile"
        return 42
    elseIf deityName == "Peryite"
        return 43
    elseIf deityName == "Vaermina"
        return 44
    endIf
    return -1
EndFunction

Int Function GetRecognitionBroadIndex(Int origin)
    if origin == ORIGIN_NORD
        if OriginRuntime.GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return 46
        endIf
        return 45
    elseIf origin == ORIGIN_IMPERIAL
        return 47
    elseIf origin == ORIGIN_BRETON
        if OriginRuntime.GetBretonTraditionValue() == BRETON_TRADITION_GREEN_WAY
            return 49
        endIf
        return 48
    elseIf origin == ORIGIN_ALTMER
        return 50
    elseIf origin == ORIGIN_BOSMER
        return 51
    elseIf origin == ORIGIN_DUNMER
        return 52
    elseIf origin == ORIGIN_KHAJIIT
        return 53
    elseIf origin == ORIGIN_ARGONIAN
        return 54
    elseIf origin == ORIGIN_ORC
        return 55
    elseIf origin == ORIGIN_REDGUARD
        return 56
    endIf
    return -1
EndFunction

Int Function GetRecognitionBroadTier(Int origin)
    Int tierValue = OriginRuntime.GetBroadLaneTierForOrigin(origin)
    if origin == ORIGIN_IMPERIAL && PDV_ImperialAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_ImperialAncestorSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_BRETON
        tierValue = RecognitionMaxInt(tierValue, OriginRuntime.GetBretonPracticeTier(OriginRuntime.GetBretonTraditionValue()))
    elseIf origin == ORIGIN_ALTMER && PDV_AltmerAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_AltmerAncestorSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_NORD && PDV_NordAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_NordAncestorSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_DUNMER && PDV_DunmerAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_DunmerAncestorSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_KHAJIIT && PDV_KhajiitLunarSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_KhajiitLunarSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_ArgonianHistSubstrate.GetSubstrateTier())
    endIf
    return tierValue
EndFunction

Int Function RecognitionMaxInt(Int firstValue, Int secondValue)
    if secondValue > firstValue
        return secondValue
    endIf
    return firstValue
EndFunction

String Function GetRecognitionIdentityKey(Int identityIndex)
    if identityIndex < 0
        return "None"
    endIf
    String[] keys = new String[57]
    keys[0] = "Talos"
    keys[1] = "AuriEl"
    keys[2] = "Yffre"
    keys[3] = "Zen"
    keys[4] = "BaanDar"
    keys[5] = "Kyne"
    keys[6] = "Azura"
    keys[7] = "Khenarthi"
    keys[8] = "Rajhin"
    keys[9] = "Alkosh"
    keys[10] = "Akatosh"
    keys[11] = "Mara"
    keys[12] = "Arkay"
    keys[13] = "Stendarr"
    keys[14] = "Zenithar"
    keys[15] = "Dibella"
    keys[16] = "Julianos"
    keys[17] = "Kynareth"
    keys[18] = "Hist"
    keys[19] = "Sithis"
    keys[20] = "Malacath"
    keys[21] = "Trinimac"
    keys[22] = "Boethiah"
    keys[23] = "Mephala"
    keys[24] = "Magnus"
    keys[25] = "Xarxes"
    keys[26] = "Tuwhacca"
    keys[27] = "HoonDing"
    keys[28] = "Leki"
    keys[29] = "Shor"
    keys[30] = "Tsun"
    keys[31] = "Stuhn"
    keys[32] = "Syrabane"
    keys[33] = "Meridia"
    keys[34] = "Hircine"
    keys[35] = "MolagBal"
    keys[36] = "Nocturnal"
    keys[37] = "HermaeusMora"
    keys[38] = "MehrunesDagon"
    keys[39] = "Sheogorath"
    keys[40] = "Namira"
    keys[41] = "Sanguine"
    keys[42] = "ClavicusVile"
    keys[43] = "Peryite"
    keys[44] = "Vaermina"
    keys[45] = "NordOldWays"
    keys[46] = "NordNineDivines"
    keys[47] = "ImperialDivines"
    keys[48] = "BretonEightDivines"
    keys[49] = "BretonOldGods"
    keys[50] = "AltmerOrthodox"
    keys[51] = "BosmerGreenPact"
    keys[52] = "DunmerReclamations"
    keys[53] = "KhajiitLunarLattice"
    keys[54] = "ArgonianHistPeople"
    keys[55] = "OrcCode"
    keys[56] = "RedguardAncestorSpine"
    return keys[identityIndex]
EndFunction

String Function GetRecognitionIdentityDisplayName(Int identityIndex)
    if identityIndex < 0
        return "None"
    elseIf identityIndex == 1
        return "Auri-El"
    elseIf identityIndex == 2
        return "Y'ffre"
    elseIf identityIndex == 3
        return "Z'en"
    elseIf identityIndex == 4
        return "Baan Dar"
    elseIf identityIndex == 27
        return "HoonDing"
    elseIf identityIndex == 35
        return "Molag Bal"
    elseIf identityIndex == 37
        return "Hermaeus Mora"
    elseIf identityIndex == 38
        return "Mehrunes Dagon"
    elseIf identityIndex == 42
        return "Clavicus Vile"
    elseIf identityIndex == 45
        return "Nord Old Ways"
    elseIf identityIndex == 46
        return "Nord Nine Divines"
    elseIf identityIndex == 47
        return "Imperial Divines"
    elseIf identityIndex == 48
        return "Breton Eight Divines"
    elseIf identityIndex == 49
        return "Breton Old Gods"
    elseIf identityIndex == 50
        return "Altmer Orthodoxy"
    elseIf identityIndex == 51
        return "Bosmer Green Pact"
    elseIf identityIndex == 52
        return "Dunmer Reclamations"
    elseIf identityIndex == 53
        return "Khajiit Lunar Lattice"
    elseIf identityIndex == 54
        return "Argonian Hist and People"
    elseIf identityIndex == 55
        return "Orc Code"
    elseIf identityIndex == 56
        return "Redguard Ancestor Spine"
    endIf
    return GetRecognitionIdentityKey(identityIndex)
EndFunction

Function HandleKIDAction(String actionKey, Form sourceForm)
    if actionKey == ""
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.KID." + actionKey)
    if multiplier <= 0.0
        return
    endIf
    String sourceName = "the offering"
    if sourceForm
        String resolvedSourceName = sourceForm.GetName()
        if resolvedSourceName != ""
            sourceName = resolvedSourceName
        endIf
    endIf
    String titleText = "An act is marked"
    String bodyText = sourceName + " carried devotional meaning."
    String symbolName = "journal"

    if actionKey == "namira_taboo_food"
        PDV_DaedricPathBase namiraPath = DaedricRuntime.GetDaedricPathByName("Namira")
        if namiraPath
            Int tierBefore = namiraPath.GetStoredTier()
            namiraPath.AdjustStoredPiety(1.0 * multiplier, "kid_taboo_food")
            DaedricRuntime.ShowDaedricMilestonePresentation(namiraPath, tierBefore, namiraPath.GetStoredTier(), False)
        endIf
        titleText = "Namira's table"
        bodyText = "You consumed " + sourceName + "; Namira marks the taboo embraced."
        symbolName = "namira"
    elseIf actionKey == "sanguine_alcohol"
        ; Hard once-per-day cap (not the soft decaying multiplier): drinking spam credits
        ; Sanguine at most once per devotional day. Distinct key prefix (PDV.Signal.KIDOnce.*)
        ; from the soft-cap prefix (PDV.Signal.KID.*) so their .Day keys never collide.
        if !ConsumeOncePerDaySignal("PDV.Signal.KIDOnce.sanguine_alcohol")
            return
        endIf
        PDV_DaedricPathBase sanguinePath = DaedricRuntime.GetDaedricPathByName("Sanguine")
        if sanguinePath
            Int tierBefore = sanguinePath.GetStoredTier()
            sanguinePath.AdjustStoredPiety(1.0, "kid_revel")
            DaedricRuntime.ShowDaedricMilestonePresentation(sanguinePath, tierBefore, sanguinePath.GetStoredTier(), False)
        endIf
        titleText = "Sanguine's revel"
        bodyText = "You drank " + sourceName + "; Sanguine marks the revel."
        symbolName = "sanguine"
    elseIf actionKey == "zenithar_trade"
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Zenithar, LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, sourceForm, multiplier)
        titleText = "Honest trade"
        bodyText = "You brought " + sourceName + " to market; Zenithar marks the exchange."
        symbolName = "zenithar"
    elseIf actionKey == "hunt_trophy"
        if PDV_HircinePath
            Int tierBefore = PDV_HircinePath.GetStoredTier()
            Float stigmaBefore = PDV_HircinePath.GetStigma()
            PDV_HircinePath.RecordHuntRiteScaled(multiplier, "kid_trophy")
            DaedricRuntime.ShowDaedricMilestonePresentation(PDV_HircinePath, tierBefore, PDV_HircinePath.GetStoredTier(), False)
            DaedricRuntime.MaybeEmitHircineStigmaPrice(stigmaBefore, PDV_HircinePath.GetStigma())
        endIf
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Kyne, PDV_Kyne.SIGNAL_SKY_ROAD, sourceForm, multiplier)
        titleText = "Trophy of the hunt"
        bodyText = "You claimed " + sourceName + " from your quarry; Hircine and Kyne mark the hunt."
        symbolName = "hircine"
    elseIf actionKey == "funerary_offering"
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Arkay, LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, sourceForm, multiplier)
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY, sourceForm, multiplier)
        titleText = "Gift to the dead"
        bodyText = "You left " + sourceName + " with the dead; Arkay and Tu'whacca mark the duty."
        symbolName = "arkay"
    elseIf actionKey == "orcish_craft"
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, sourceForm, multiplier)
        titleText = "Orcish craft"
        bodyText = "You forged " + sourceName + "; Malacath weighs the work."
        symbolName = "malacath"
    elseIf actionKey == "amulet_akatosh"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Akatosh, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Akatosh honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "akatosh"
    elseIf actionKey == "amulet_arkay"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Arkay, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Arkay honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "arkay"
    elseIf actionKey == "amulet_dibella"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Dibella, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Dibella honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "dibella"
    elseIf actionKey == "amulet_julianos"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Julianos, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Julianos honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "julianos"
    elseIf actionKey == "amulet_kynareth"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Kynareth, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Kynareth honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "kynareth"
    elseIf actionKey == "amulet_mara"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Mara, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Mara honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "mara"
    elseIf actionKey == "amulet_stendarr"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Stendarr, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Stendarr honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "stendarr"
    elseIf actionKey == "amulet_talos"
        LedgerRuntime.AwardPiety(PDV_Talos, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Talos honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "talos"
    elseIf actionKey == "amulet_zenithar"
        LedgerRuntime.AwardPiety(LedgerRuntime.PDV_Zenithar, 0.5 * multiplier, "kid_amulet_honor")
        titleText = "Zenithar honoured"
        bodyText = "You put on " + sourceName + "."
        symbolName = "zenithar"
    else
        return
    endIf

    SendPrismaToast(symbolName, "good", titleText, bodyText, True)
    AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "favor.act", symbolName, False, 1, titleText)
    RequestPanelRefresh()
EndFunction

; ===========================================================================
; Authoria - Devotions Tweaks and Fixes (Pass 2)
; B3 / fix-plan Group 2    -- lifecycle watchdog
; A1 / fix-plan Group 11.2 -- one-shot actor-value repair
; ===========================================================================

; --- B3: lifecycle watchdog ------------------------------------------------
; The 1s master poll is a single-update chain re-armed only at the end of its own
; OnUpdate, and the manager and Quest Reaction runtime are Quest scripts, so their
; OnPlayerLoadGame can never fire (that event is alias-only). One tick lost to a
; Papyrus stack dump therefore stopped dawn processing, pact activation, the startup
; choice and the reconcile for the rest of the playthrough. PDV_PlayerEvents is a
; player ALIAS script and does receive OnPlayerLoadGame; it calls this from there.
; Re-registering a single update only resets the timer, so this is safe -- and in
; effect a no-op -- when the chain is already alive.
Function KickstartIfStalled()
    if !Self.IsRunning()
        ; Stopped by PrepareForUninstall. Never resurrect the chain.
        return
    endIf
    RegisterForSingleUpdate(1.0)
    EnsureRecognitionModEvents()
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
    OriginRuntime.ReconcileRedguardSpineRewardAfterLoad()
    OriginRuntime.SyncKhajiitRuntimeState()
    Trace(2, "Lifecycle watchdog: manager master poll re-armed on load.")
EndFunction


; --- A1 cure: one-shot actor-value repair ----------------------------------
; Pass 1 set the Recover flag on all 420 value-modifying magic effects that lacked it,
; which STOPS further drift. It does not heal what a save already carries: every past
; application of a no-Recover ValueModifier wrote a PERMANENT actor-value modifier that
; removing the ability never reverted (-22131 percent Magic Resistance and -5000 armour
; in the two user reports). This is the cure.
Int Property AUTHORIA_REPAIR_VERSION = 1 AutoReadOnly
String Property AUTHORIA_REPAIR_KEY = "PDV.Authoria.RepairVersion" AutoReadOnly
; PO3 GetActorValueModifier modifier index: 0 = permanent, 1 = temporary, 2 = damage.
; Devotion's no-Recover modifiers land in the PERMANENT slot; a recovering effect's
; contribution lives in the temporary slot and is not touched here.
Int Property AV_MODIFIER_PERMANENT = 0 AutoReadOnly
; PDV_MGEF_Neglect_Redguard_Magic magnitude ("Ancestors at a Distance", ResistMagic).
Float Property NEGLECT_REDGUARD_MAGNITUDE = 3.0 AutoReadOnly
Float Property AUTHORIA_REPAIR_EPSILON = 0.01 AutoReadOnly

; The automatic once-per-save pass was deliberately NOT adopted (owner decision,
; 1.0.3): the MCM "Check stat damage" / "Repair stats" buttons are the only entry
; points, so nothing runs unprompted on load.

; zeroPermanentModifiers = False -> the conservative automatic pass: correct only what
;   Devotion's own persisted counters can account for (see GetAuthoriaCounterResidue),
;   clamped so it can never over-correct, and log the shortfall.
; zeroPermanentModifiers = True  -> the MCM "Repair stats" button and the uninstall
;   path: zero the permanent modifier outright on the listed actor values. This also
;   clears any permanent modifier a THIRD-PARTY mod placed on those same values.
Function RunAuthoriaActorValueRepair(Bool zeroPermanentModifiers, Bool resyncAfterwards)
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        Trace(1, "Authoria stat repair skipped: player unavailable.")
        return
    endIf

    TraceAuthoriaRepair("START mode=" + GetAuthoriaRepairModeLabel(zeroPermanentModifiers))

    ; 1 - drop every Devotion penalty/boon ability so nothing re-applies mid-repair.
    ;     StripAllPdvSpells now also covers the two observance families and the Daedric
    ;     pact boon+price spells (see the B16 fix above).
    StripAllPdvSpells(playerRef)
    ; 2 - let the engine settle the removals before any modifier is read. WaitMenuMode,
    ;     not Wait: the uninstall and MCM callers run with the game paused in a menu,
    ;     where a plain Utility.Wait would never return.
    Utility.WaitMenuMode(0.5)

    ; 3 + 4 - correct each actor value Devotion's value modifiers can touch.
    String[] repairValues = GetAuthoriaRepairActorValues()
    Int i = 0
    while i < repairValues.Length
        RepairOneAuthoriaActorValue(playerRef, repairValues[i], zeroPermanentModifiers)
        i += 1
    endWhile

    ; 5 - put the live state back through the normal sync paths.
    if resyncAfterwards
        ResyncDevotionSpellsAfterRepair(playerRef)
    endIf

    StorageUtil.SetIntValue(None, AUTHORIA_REPAIR_KEY, AUTHORIA_REPAIR_VERSION)
    TraceAuthoriaRepair("DONE")
EndFunction

String Function GetAuthoriaRepairModeLabel(Bool zeroPermanentModifiers)
    if zeroPermanentModifiers
        return "zero-permanent-modifiers"
    endIf
    return "counter-reconcile"
EndFunction

; Every distinct actor value carried by Devotion.esp's 422 ValueModifier magic effects
; (the 4 whose ActorValue is None are inert and omitted), plus the two PeakValueModifier
; effects that also lacked Recover -- enumerated from the plugin itself, never guessed.
; The record enum name and the engine's actor-value NAME differ for eight of them, and
; only the engine name resolves at runtime:
;   ResistMagic    -> MagicResist      Speech              -> Speechcraft
;   Archery        -> Marksman         ResistFire          -> FireResist
;   ResistFrost    -> FrostResist      ResistDisease       -> DiseaseResist
;   CriticalChance -> CritChance       SpeechcraftModifier -> SpeechcraftMod
; Each name was cross-checked against the AVIF (ActorValueInformation) EditorIDs in
; Skyrim.esm and against real usage across the load order's Papyrus sources.
String[] Function GetAuthoriaRepairActorValues()
    String[] avNames = new String[33]
    avNames[0]  = "MagicResist"          ; 52 effects
    avNames[1]  = "DamageResist"         ; 45
    avNames[2]  = "Speechcraft"          ; 40
    avNames[3]  = "OneHanded"            ; 31
    avNames[4]  = "Restoration"          ; 29
    avNames[5]  = "DiseaseResist"        ; 25
    avNames[6]  = "CarryWeight"          ; 20
    avNames[7]  = "Sneak"                ; 19
    avNames[8]  = "Stamina"              ; 17
    avNames[9]  = "Magicka"              ; 15
    avNames[10] = "Illusion"             ; 15
    avNames[11] = "Block"                ; 15
    avNames[12] = "PoisonResist"         ; 11
    avNames[13] = "FrostResist"          ; 9
    avNames[14] = "Health"               ; 9
    avNames[15] = "UnarmedDamage"        ; 7
    avNames[16] = "SpeedMult"            ; 7  -- Malacath's price
    avNames[17] = "Alteration"           ; 7
    avNames[18] = "StaminaRateMult"      ; 6
    avNames[19] = "Lockpicking"          ; 5
    avNames[20] = "Smithing"             ; 4
    avNames[21] = "FireResist"           ; 4
    avNames[22] = "Conjuration"          ; 4
    avNames[23] = "AttackDamageMult"     ; 4
    avNames[24] = "Marksman"             ; 4
    avNames[25] = "TwoHanded"            ; 3
    avNames[26] = "Destruction"          ; 3
    avNames[27] = "MagickaRateMult"      ; 2
    avNames[28] = "CritChance"           ; 2
    avNames[29] = "WeaponSpeedMult"      ; 1
    avNames[30] = "SpeechcraftMod"       ; 1
    avNames[31] = "Pickpocket"           ; 1
    avNames[32] = "HealRateMult"         ; 1
    return avNames
EndFunction

Function RepairOneAuthoriaActorValue(Actor playerRef, String avName, Bool zeroPermanentModifiers)
    Float permBefore = PO3_SKSEFunctions.GetActorValueModifier(playerRef, AV_MODIFIER_PERMANENT, avName)
    if Math.abs(permBefore) < AUTHORIA_REPAIR_EPSILON
        return
    endIf

    Float correction = 0.0
    if zeroPermanentModifiers
        correction = 0.0 - permBefore
    else
        correction = ClampAuthoriaCorrection(GetAuthoriaCounterResidue(avName), permBefore)
    endIf

    if Math.abs(correction) < AUTHORIA_REPAIR_EPSILON
        TraceAuthoriaRepair(avName + ": permanent modifier " + permBefore + " LEFT IN PLACE (no counter-backed correction available; shortfall " + permBefore + ")")
        return
    endIf

    playerRef.ModActorValue(avName, correction)
    Float permAfter = PO3_SKSEFunctions.GetActorValueModifier(playerRef, AV_MODIFIER_PERMANENT, avName)
    ; Self-check: if the write did not move the permanent modifier toward zero, put it
    ; back rather than compound an error. An over-correction is worse than the drift.
    if Math.abs(permAfter) > Math.abs(permBefore)
        playerRef.ModActorValue(avName, 0.0 - correction)
        TraceAuthoriaRepair(avName + ": correction " + correction + " REVERTED -- permanent modifier moved " + permBefore + " -> " + permAfter)
        return
    endIf

    TraceAuthoriaRepair(avName + ": " + permBefore + " -> " + permAfter + " (applied " + correction + "; shortfall " + permAfter + ")")
EndFunction

; Never correct past the modifier that is actually present, and never flip its sign.
Float Function ClampAuthoriaCorrection(Float correction, Float permBefore)
    if correction > 0.0 && permBefore >= 0.0
        return 0.0
    endIf
    if correction < 0.0 && permBefore <= 0.0
        return 0.0
    endIf
    if Math.abs(correction) > Math.abs(permBefore)
        return 0.0 - permBefore
    endIf
    return correction
EndFunction

; The ONE cumulative counter in Devotion that increments on a penalty-ability ADD
; transition: PDV.Redguard.DeathDutyAbandonmentCount, written by
; EmitRedguardDeathDutyAbandonmentMinus off SyncRedguardNeglectSpell's !wasActive
; branch. Every other penalty and boon family persists CURRENT state only -- the
; per-race PDV.Neglect.*SpellActive flags, the disfavor domains' Active/ExpiresAt/Band
; keys, and PDV.Daedric.LivePactSpells -- so no application HISTORY survives to
; reconcile from. The counter that does exist is itself origin-gated, Tu'whacca-gated
; and daily anti-farm gated, so it undercounts the real transitions too. The automatic
; pass therefore under-corrects by design and logs the shortfall; the MCM
; "Repair stats" button is the full correction.
Float Function GetAuthoriaCounterResidue(String avName)
    if avName == "MagicResist"
        Int abandonments = StorageUtil.GetIntValue(None, "PDV.Redguard.DeathDutyAbandonmentCount", 0)
        if abandonments > 0
            ; Each transition applied -3 ResistMagic permanently; undo that many.
            return (abandonments as Float) * NEGLECT_REDGUARD_MAGNITUDE
        endIf
    endIf
    return 0.0
EndFunction

Function ResyncDevotionSpellsAfterRepair(Actor playerRef)
    if !playerRef
        return
    endIf

    ; The re-grants below are a restoration, not a fresh award -- suppress the tier and
    ; Champion presentations they would otherwise fire.
    BeginRaceSetupQuietPresentation("authoria_stat_repair")

    ; The normal reward path re-grants every race/patron family and re-applies the
    ; neglect spells from live state.
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    FavorRuntime.UpdateContextualFavorRuntime()
    LedgerRuntime.UpdateDisfavorStingRuntime()
    LedgerRuntime.ReapplyActiveDisfavorStings(playerRef)
    ; The two observance families B16 covers; both self-gate on their stored state.
    OriginRuntime.SyncAltmerDisciplines(playerRef)
    OriginRuntime.SyncRedguardRemembering(playerRef)
    ; The live Daedric pact re-grants its boon + price for its stored tier. Idempotent:
    ; the ActivePact pointer is unchanged, so no PendingActivation breadcrumb is left.
    PDV_DaedricPathBase livePact = DaedricRuntime.GetActiveDaedricPactPath()
    if livePact
        livePact.MakeActiveDaedricPact()
    endIf

    EndRaceSetupQuietPresentation()
EndFunction

; UpdateDisfavorStingRuntime only CLEARS expired stings -- nothing re-applies an
; unexpired one after a strip, so restore each active domain's band spell here.


; Reported at debug level 1 so a bug reporter can verify every correction. The
; per-value lines are the audit trail the fix plan asks for.
Function TraceAuthoriaRepair(String repairText)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Authoria stat repair: " + repairText)
    endIf
EndFunction

; Readout for the MCM button: how much permanent modifier is still sitting on the
; listed actor values right now. Read-only.
String Function GetAuthoriaResidueSummary()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "Player unavailable."
    endIf

    String summary = ""
    Int touched = 0
    String[] repairValues = GetAuthoriaRepairActorValues()
    Int i = 0
    while i < repairValues.Length
        Float perm = PO3_SKSEFunctions.GetActorValueModifier(playerRef, AV_MODIFIER_PERMANENT, repairValues[i])
        if Math.abs(perm) >= AUTHORIA_REPAIR_EPSILON
            summary += repairValues[i] + " " + perm + "\n"
            touched += 1
        endIf
        i += 1
    endWhile

    if touched == 0
        return "No permanent modifier remains on any actor value Devotion can touch."
    endIf
    return "Permanent modifier still present on " + touched + " actor value(s):\n" + summary
EndFunction


;/ =====================================================================
    LEDGER extraction accessors -- backref bridge for PDV_DevotionLedger.
    The moved LEDGER logic lives in PDV_DevotionLedger and reaches these
    manager script variables through the Manager backref. Getters/setters
    are thin passthroughs; behavior is identical to the pre-move bare access.
   ===================================================================== /;
Function SetActiveDeityRef(PDV_DeityBase value)
    _activeDeity = value
EndFunction

Bool Function GetSuppressAwardFavorToast()
    return _suppressAwardFavorToast
EndFunction

Function SetSuppressAwardFavorToast(Bool value)
    _suppressAwardFavorToast = value
EndFunction

Bool Function GetSuppressCurseTransitionOutputs()
    return _suppressCurseTransitionOutputs
EndFunction

Function SetSuppressCurseTransitionOutputs(Bool value)
    _suppressCurseTransitionOutputs = value
EndFunction

Function SetRaceCurseSurfaceShown(Bool value)
    _raceCurseSurfaceShown = value
EndFunction

Bool Function GetRaceCurseSurfaceShown()
    return _raceCurseSurfaceShown
EndFunction

Bool Function GetDawnHadActivity()
    return _dawnHadActivity
EndFunction

Function SetDawnHadActivity(Bool value)
    _dawnHadActivity = value
EndFunction

Int Function GetBroadPantheonSelfEventSequence()
    return _broadPantheonSelfEventSequence
EndFunction

Function SetBroadPantheonSelfEventSequence(Int value)
    _broadPantheonSelfEventSequence = value
EndFunction

Function SetPendingCommitmentOfferDeity(PDV_DeityBase value)
    _pendingCommitmentOfferDeity = value
EndFunction

Bool Function GetPdvSurvivalModePresent()
    return _pdvSurvivalModePresent
EndFunction

Function SetPdvSurvivalModePresent(Bool value)
    _pdvSurvivalModePresent = value
EndFunction

Bool Function GetPdvSunHelmPresent()
    return _pdvSunHelmPresent
EndFunction

Function SetPdvSunHelmPresent(Bool value)
    _pdvSunHelmPresent = value
EndFunction

Bool Function GetPdvCCSaintsPresent()
    return _pdvCCSaintsPresent
EndFunction

Function SetPdvCCSaintsPresent(Bool value)
    _pdvCCSaintsPresent = value
EndFunction

Bool Function GetPdvCCFishingPresent()
    return _pdvCCFishingPresent
EndFunction

Function SetPdvCCFishingPresent(Bool value)
    _pdvCCFishingPresent = value
EndFunction








