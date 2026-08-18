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
Bool _dunmerHomePrayerContext = False

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
Message _pendingNordKyneChampionMsg = None
String _pendingNordKyneChampionFallback = ""
Int _pendingNordKyneChampionDelayTicks = 0
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
; The bounded worker owns these separate accumulators. They never borrow the
; global broad-pantheon scope, so a long quest fan-out cannot block another
; manager event or merge its player-facing acknowledgement.
Bool _qrQueueTransactionActive = False
Bool _qrQueueNeedsCurseRefresh = False
Bool _qrQueueNeedsBretonRewardSync = False
String _qrQueueSurfPosNamesCsv = ""
String _qrQueueSurfNegNamesCsv = ""
Int _qrQueueSurfPosCount = 0
Int _qrQueueSurfNegCount = 0
Float _qrQueueSurfBestPosAmount = 0.0
Float _qrQueueSurfBestNegAmount = 0.0
String _qrQueueSurfBestPosName = ""
String _qrQueueSurfBestNegName = ""
String _qrQueueSurfBestPosSymbol = ""
String _qrQueueSurfBestNegSymbol = ""
Bool _qrQueueSurfMilestone = False
String _qrQueueBroadPool = ""
Float _qrQueueBroadBestPositive = 0.0
Float _qrQueueBroadWorstNegative = 0.0
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
PDV_DaedricPathBase _kidNamiraPath = None
PDV_DaedricPathBase _kidSanguinePath = None
Bool Property AutoPushPrismaPanel = False Auto
Bool Property AllowPrismaBlockingSurfaces = False Auto
PDV_DaedricPathBase _pendingDaedricMilestonePath = None
PDV_DeityBase _pendingCommitmentOfferDeity = None
Int _pendingDaedricMilestoneOldTier = 0
Int _pendingDaedricMilestoneNewTier = 0
String _pendingDaedricMilestoneReason = ""
Bool _pendingDaedricMilestoneReplayChampionOffer = False
Int _pendingDaedricMilestoneDelayTicks = 0

Event OnInit()
    InitializePreflightState()
    EnsurePhase8RuntimeWiring()
    EnsureAkatoshRuntimeIdentity()
    LedgerRuntime.EnsureCanonicalDeityDisplayNames()
    OriginRuntime.EnsureBosmerRuntimeWiring()
    EnsureNordRuntimeWiring()
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
    EnsureDunmerAncestralUrn()
    OriginRuntime.EnsureAltmerPracticeFocus()
    OriginRuntime.EnsureArgonianHistSapToken()
    OriginRuntime.EnsureKhajiitObserveMoonsPower()
    RequestPanelRefresh()
    HandleDiegeticLoad("init")
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    _optimizationTimerFires += 1

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
    ProcessQueuedDaedricMilestonePresentation()
    ProcessQueuedCommitmentOffer()
    ProcessQueuedNordKyneChampionEntry()
    ProcessPendingDaedricActivation()
    ProcessPendingDaedricLapse()
    ProcessPendingDaedricPrePactNotices()
    DrainHircineRenunciationJournal()
    ProcessDelayedHircineResiduePrismaToasts()
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
        EnsureNordRuntimeWiring()
        EnsureSurveyDevotionPower()
        EnsureDunmerAncestralUrn()
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

    EnsureTalosRuntimeIdentity()

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
                repaired += LedgerRuntime.RepairDeityRuntimeName(namedPath, canonicalPathName)
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


Function EnsureNordRuntimeWiring()
    EnsureNordOrkeyRewardRuntimeWiring()

    if !PDV_NordPantheonBaselineTrack
        return
    endIf

    if PDV_NordPantheonBaselineTrack.TrackName != "NordPantheonBaseline"
        PDV_NordPantheonBaselineTrack.TrackName = "NordPantheonBaseline"
    endIf

    if PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel != LedgerRuntime.PDV_GLO_DebugLevel
        PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel = LedgerRuntime.PDV_GLO_DebugLevel
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

    if PDV_Talos.PDV_GLO_DebugLevel != LedgerRuntime.PDV_GLO_DebugLevel
        PDV_Talos.PDV_GLO_DebugLevel = LedgerRuntime.PDV_GLO_DebugLevel
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



; Authoria bard-performance signal. Quality is the SGT expertise delta (1-8);
; Become a Bard-only performances enter at quality 1. The daily repeat
; multiplier is the global devotional anti-farm budget, while PlayerEvents
; separately enforces one award per tavern per devotional day.

; V3 Quest Reaction callback seam. The runtime owns catalogs, persistence,
; scheduling, and job lifecycle; Manager owns scoring and final presentation.
Bool Function ShouldQueueQuestReactionCell(String deityName, String valence, String intensity, String magnitude)
    return !IsQueuedQuestReactionCellCheapSkip(deityName, valence, intensity, magnitude)
EndFunction

Function PrepareQueuedQuestReactionTransaction()
    ResetQueuedQuestReactionSurface()
    _qrQueueNeedsCurseRefresh = False
    _qrQueueNeedsBretonRewardSync = False
    _qrQueueBroadPool = LedgerRuntime.GetActiveBroadPantheonPoolId()
    _qrQueueBroadBestPositive = 0.0
    _qrQueueBroadWorstNegative = 0.0
EndFunction

Function BeginQueuedQuestReactionSlice()
    _qrQueueTransactionActive = True
EndFunction

Function ApplyQueuedQuestReactionCell(String deityName, String valence, String intensity, String magnitude, String sourceTag, Form sourceForm)
    LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, magnitude, sourceTag, False, sourceForm)
EndFunction

Function EndQueuedQuestReactionSlice()
    _qrQueueTransactionActive = False
EndFunction

Function FinalizeQueuedQuestReaction(String sourceModName, String reactionKey)
    _qrQueueTransactionActive = False
    FlushQueuedQuestReactionSurface(sourceModName, reactionKey)
    CommitQueuedQuestReactionBroad(reactionKey)
    if _qrQueueNeedsCurseRefresh
        LedgerRuntime.HandleCurseStateRefresh("quest_reaction_queue")
    endIf
    if _qrQueueNeedsBretonRewardSync
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf
    RequestPanelRefresh()
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
    LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, magnitude, sourceTag, True, sourceForm)

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

    Int namiraTier = LedgerRuntime.GetTier(namira)
    if namiraTier < LedgerRuntime.TIER_SEEKER
        return
    endIf

    Float feedMultiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.NamiraFeedHeal")
    if feedMultiplier <= 0.0
        Trace(2, "Namira feed-heal decayed out for today; no restore.")
        return
    endIf

    Float feedHeal = 20.0
    if namiraTier >= LedgerRuntime.TIER_CHAMPION
        feedHeal = 40.0
    elseIf namiraTier >= LedgerRuntime.TIER_DEVOTED
        feedHeal = 30.0
    endIf
    feedHeal = feedHeal * feedMultiplier
    Float feedStamina = feedHeal
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", feedHeal)
    playerRef.RestoreActorValue("Stamina", feedStamina)
    Trace(2, "Namira feed-heal fired tier=" + namiraTier + " mult=" + feedMultiplier + " health=" + feedHeal + " stamina=" + feedStamina)
EndFunction

Bool Function IsQueuedQuestReactionCellCheapSkip(String deityName, String valence, String intensity, String magnitude)
    PDV_DeityBase deity = GetQuestReactionDeity(deityName)
    if !deity
        return True
    endIf

    Float amount = GetQuestReactionBaseValue(magnitude, intensity)
    if amount == 0.0
        return True
    endIf
    if valence == "-"
        amount = amount * -1.0
    endIf

    String stance = GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        return False
    endIf

    ; A named taboo/hostile cell is deliberate displeasure, not background
    ; favor: positive values become stigma and negative values become piety loss.
    ; Keep either form for a deity the player's origin roster can still show even
    ; when a Nord chose the other baseline. Every other cell must be reachable
    ; on the current lane before it enters the persisted worker snapshot.
    if (stance == "TABOO" || stance == "HOSTILE") && IsDashboardDeityInOriginRoster(deity, GetPlayerOriginRaceIndex())
        return False
    endIf

    return !IsQuestReactionDeityReachable(deity)
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
    ; A Daedric Prince stays out of Book-of-Days reaction surfaces (and their paired
    ; toast) until it reaches Seeker (25 piety); a still-uncommitted Prince below that
    ; only ever surfaces through the one pre-pact "taken notice" beat. Piety is still
    ; awarded upstream -- this gates DISPLAY only. Off-roster Aedric gods are already
    ; dropped by the reachability gate, so this leaves race-aligned gods untouched.
    PDV_DaedricPathBase daedricSurfacePath = deity as PDV_DaedricPathBase
    if daedricSurfacePath && daedricSurfacePath.GetStoredTier() < LedgerRuntime.TIER_SEEKER
        return
    endIf
    if _qrQueueTransactionActive
        AccumulateQueuedQuestReactionSurface(deity, amount, magnitude)
        return
    endIf
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
    if _qrQueueTransactionActive
        FlushQueuedQuestReactionSurface()
        return
    endIf
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

Function ResetQueuedQuestReactionSurface()
    _qrQueueSurfPosNamesCsv = ""
    _qrQueueSurfNegNamesCsv = ""
    _qrQueueSurfPosCount = 0
    _qrQueueSurfNegCount = 0
    _qrQueueSurfBestPosAmount = 0.0
    _qrQueueSurfBestNegAmount = 0.0
    _qrQueueSurfBestPosName = ""
    _qrQueueSurfBestNegName = ""
    _qrQueueSurfBestPosSymbol = ""
    _qrQueueSurfBestNegSymbol = ""
    _qrQueueSurfMilestone = False
EndFunction

Function AccumulateQueuedQuestReactionSurface(PDV_DeityBase deity, Float amount, String magnitude)
    if !deity || amount == 0.0
        return
    endIf
    String deityName = GetPublicDeityDisplayName(deity)
    if magnitude == "milestone"
        _qrQueueSurfMilestone = True
    endIf
    Bool alreadyListed = QueuedQuestReactionSurfaceHasName(deityName)
    if amount > 0.0
        if !alreadyListed
            if _qrQueueSurfPosNamesCsv != ""
                _qrQueueSurfPosNamesCsv = _qrQueueSurfPosNamesCsv + "|"
            endIf
            _qrQueueSurfPosNamesCsv = _qrQueueSurfPosNamesCsv + deityName
            _qrQueueSurfPosCount += 1
        endIf
        if amount > _qrQueueSurfBestPosAmount
            _qrQueueSurfBestPosAmount = amount
            _qrQueueSurfBestPosName = deityName
            _qrQueueSurfBestPosSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    else
        if !alreadyListed
            if _qrQueueSurfNegNamesCsv != ""
                _qrQueueSurfNegNamesCsv = _qrQueueSurfNegNamesCsv + "|"
            endIf
            _qrQueueSurfNegNamesCsv = _qrQueueSurfNegNamesCsv + deityName
            _qrQueueSurfNegCount += 1
        endIf
        if amount < _qrQueueSurfBestNegAmount
            _qrQueueSurfBestNegAmount = amount
            _qrQueueSurfBestNegName = deityName
            _qrQueueSurfBestNegSymbol = GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

Bool Function QueuedQuestReactionSurfaceHasName(String deityName)
    if deityName == ""
        return False
    endIf
    String token = "|" + deityName + "|"
    return StringUtil.Find("|" + _qrQueueSurfPosNamesCsv + "|", token) >= 0 || StringUtil.Find("|" + _qrQueueSurfNegNamesCsv + "|", token) >= 0
EndFunction

Function FlushQueuedQuestReactionSurface(String sourceModName = "", String reactionKey = "")
    if _qrQueueSurfPosCount == 0 && _qrQueueSurfNegCount == 0
        return
    endIf
    String surfaceSourceModName = NormalizePublicDeityDisplayText(sourceModName)
    if surfaceSourceModName == "Skyrim.esm" || surfaceSourceModName == "Update.esm" || surfaceSourceModName == "Dawnguard.esm" || surfaceSourceModName == "HearthFires.esm" || surfaceSourceModName == "Dragonborn.esm"
        surfaceSourceModName = ""
    endIf
    Int nowDay = Utility.GetCurrentGameTime() as Int
    Int bodMagnitude = 1
    if _qrQueueSurfMilestone
        bodMagnitude = 2
    endIf
    Bool toastSent = False
    if _qrQueueSurfNegCount == 0
        String posMsg = _qrQueueSurfBestPosName + " marks your deed."
        if _qrQueueSurfPosCount == 2
            posMsg = _qrQueueSurfBestPosName + " and 1 other mark your deed."
        elseIf _qrQueueSurfPosCount > 2
            posMsg = _qrQueueSurfBestPosName + " and " + (_qrQueueSurfPosCount - 1) + " others mark your deed."
        endIf
        toastSent = SendPrismaToastWithSource(_qrQueueSurfBestPosSymbol, "good", "A deed marked", posMsg, surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfPosNamesCsv) + " marked your deed.", nowDay, "favor.act", _qrQueueSurfBestPosSymbol, False, bodMagnitude, "A deed marked", False, surfaceSourceModName)
    elseIf _qrQueueSurfPosCount == 0
        String negMsg = _qrQueueSurfBestNegName + " takes offense at your deed."
        if _qrQueueSurfNegCount == 2
            negMsg = _qrQueueSurfBestNegName + " and 1 other take offense at your deed."
        elseIf _qrQueueSurfNegCount > 2
            negMsg = _qrQueueSurfBestNegName + " and " + (_qrQueueSurfNegCount - 1) + " others take offense at your deed."
        endIf
        toastSent = SendPrismaToastWithSource(_qrQueueSurfBestNegSymbol, "warning", "A deed ill-received", negMsg, surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfNegNamesCsv) + " took offense at your deed.", nowDay, "favor.loss", _qrQueueSurfBestNegSymbol, False, bodMagnitude, "A deed ill-received", False, surfaceSourceModName)
    else
        Bool positiveLeads = _qrQueueSurfBestPosAmount >= (_qrQueueSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _qrQueueSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _qrQueueSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        toastSent = SendPrismaToastWithSource(mixedSymbol, mixedTone, "A deed weighed", _qrQueueSurfBestPosName + " marks your deed; " + _qrQueueSurfBestNegName + " takes offense.", surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfPosNamesCsv) + " marked your deed; " + JoinQuestSurfaceNames(_qrQueueSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, bodMagnitude, "A deed weighed", False, surfaceSourceModName)
    endIf
    ResetQueuedQuestReactionSurface()
EndFunction

Function TraceQuestReactionToastResult(String reactionKey, Bool toastSent)
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV][PDV_TOAST_TRACE] questReaction correlation=" + reactionKey + " submitted=" + toastSent)
    endIf
EndFunction








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

PDV_DeityBase Function GetQuestReactionDeity(String deityName)
    ; Per-cell quest-reaction hot path. Resolution was an O(deities) FormList
    ; scan (plus a Daedric-path scan on a name miss) run once per cell -- twice
    ; for a runnable cell (cheap-skip check then ApplyDeityReaction). The
    ; name->deity mapping is static for the session, so cache the resolved form
    ; in a StorageUtil map keyed by name. Only non-None results are cached, so a
    ; name whose owning form is not loaded yet keeps re-scanning until it hits.
    if deityName == ""
        return None
    endIf

    Form cachedForm = StorageUtil.GetFormValue(None, "PDV.Manager.QuestReaction.DeityCache." + deityName)
    PDV_DeityBase cachedDeity = cachedForm as PDV_DeityBase
    if cachedDeity
        return cachedDeity
    endIf

    PDV_DeityBase deity = LedgerRuntime.GetDeityByName(deityName)
    if !deity && PDV_FLST_DaedricPaths_All
        Int i = 0
        Int count = PDV_FLST_DaedricPaths_All.GetSize()
        while i < count && !deity
            PDV_DeityBase path = PDV_FLST_DaedricPaths_All.GetAt(i) as PDV_DeityBase
            if path && IsQuestReactionNameMatch(path.DeityName, deityName)
                deity = path
            endIf
            i += 1
        endWhile
    endIf

    if deity
        StorageUtil.SetFormValue(None, "PDV.Manager.QuestReaction.DeityCache." + deityName, deity)
    endIf
    return deity
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

Float Function GetQuestReactionStanceMultiplier(String stance)
    if stance == "FOREIGN"
        return JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.FOREIGN", 0.4)
    elseIf stance == "TOLERATED"
        return JsonUtil.GetFloatValue(QUEST_REACTION_MATRIX_FILE, "stanceMult.TOLERATED", 0.4)
    endIf
    return 1.0
EndFunction

; A quest-reaction target is "reachable" when automatic piety can land on a
; player-facing, currently eligible lane. Daedric paths always qualify
; (pre-pact paths render as "watching"; pacts as patron), and an active
; off-roster patron restored from an older save remains reachable. Nords are
; deliberately narrower than their dashboard's union roster: the selected Old
; Ways or Nine Divines baseline decides which native god can receive an
; automatic quest reaction. DeityBase state tracks still own their documented
; reduced-gain/tier-cap behavior and are not duplicated as a binary gate here.
Bool Function IsQuestReactionDeityReachable(PDV_DeityBase deity)
    if deity as PDV_DaedricPathBase
        return True
    endIf
    if LedgerRuntime.IsGrandfatheredOffRosterPatron(deity)
        return True
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_NORD
        return IsNordOfferEligibleDeity(deity)
    endIf

    return IsDashboardDeityInOriginRoster(deity, originRace)
EndFunction


Function ApplyQuestReactionPiety(PDV_DeityBase deity, Float amount, String reason)
    Form deityForm = GetDeityFormOrNone(deity)
    if !deityForm || amount == 0.0
        return
    endIf

    ; The caller already applied the matrix stance multiplier. Preserve track,
    ; eligibility, curse, survival, and mode modifiers without double-scaling
    ; FOREIGN/TOLERATED through the record stance again.
    LedgerRuntime.AwardPietyInternal(deity, amount, True, reason, False)
    StorageUtil.SetStringValue(deityForm, "PDV.QuestReaction.LastReason", reason)
    if !_qrQueueTransactionActive
        RequestPanelRefresh()
    endIf

    if GetDebugLevel() >= 3 || (!_qrQueueTransactionActive && GetDebugLevel() >= 1)
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

    Int currentDayStamp = LedgerRuntime.GetDevotionalDay() + 2
    String dayKey = capKey + ".Day"
    if StorageUtil.GetIntValue(None, dayKey) == currentDayStamp
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDayStamp)
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
    String consequence = GetCurseContextForRace(phase, curseType)
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
        originLabel = GetOriginRaceLabel(originRace)
    endIf

    String titleText = "Devotion"
    String symbolName = "journal"
    Float piety = 0.0
    Float pietyToday = 0.0
    Int tierValue = LedgerRuntime.TIER_NONE
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
        if IsFocusedPantheonBoonSuspended()
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
        Int broadTier = GetBroadLaneTierForOrigin(originRace)
        if pantheonBroadPresentation || broadTier > LedgerRuntime.TIER_NONE
            titleText = GetBroadLaneDisplayName(originRace)
            symbolName = GetBroadLaneSymbol(originRace)
            tierValue = broadTier
            tierLabelOverride = GetBroadLaneStandingLabel(originRace, broadTier)
            piety = GetBroadLaneStandingValue(originRace)
            pietyToday = GetBroadLaneScratchValue(originRace)
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
    if IsFocusedPantheonBoonSuspended()
        nextText = "Focused boon returns at 50 piety"
    elseIf panelCommitment == None && originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        nextText = OriginRuntime.GetArgonianCulturalNextThresholdText(piety)
    elseIf panelCommitment == None && (pantheonBroadPresentation || GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        nextText = GetBroadLaneNextThresholdText(originRace)
    endIf
    j = j + ",\"nextText\":\"" + PDV_DevotionRules.JsonSafeString(nextText) + "\""
    j = j + ",\"piety\":" + piety
    if panelCommitment == None && (pantheonBroadPresentation || GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        if originRace == ORIGIN_BRETON
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + GetBroadLaneServiceCount(originRace) + " practice points") + "\""
        elseIf originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_NORD
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.FormatTwoDecimals(GetBroadLaneStandingValue(originRace)) + " pantheon standing") + "\""
        else
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + GetBroadLaneServiceCount(originRace) + " broad acts") + "\""
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
        PDV_DaedricPathBase dashPact = GetActiveDaedricPactPath()
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

    PDV_DaedricPathBase watchingPath = GetTopPrePactDaedricPath()
    if watchingPath && watchingPath != tracked
        gods = AppendDashboardGod(gods, watchingPath, "watching")
        shown += 1
    endIf

    if LedgerRuntime.PDV_FLST_AllDeities
        Int i = 0
        Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if deity && deity != tracked && IsDashboardDeityInOriginRoster(deity, originRace)
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

Bool Function IsDashboardDeityInOriginRoster(PDV_DeityBase deity, Int originRace)
    if !deity
        return False
    endIf

    if originRace == ORIGIN_NORD
        return deity == PDV_Kyne || deity == LedgerRuntime.PDV_Kynareth || deity == PDV_Talos || deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Stuhn || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Zenithar
    elseIf originRace == ORIGIN_IMPERIAL
        return deity == LedgerRuntime.PDV_Kynareth || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Zenithar
    elseIf originRace == ORIGIN_BRETON
        return deity == LedgerRuntime.PDV_Kynareth || deity == PDV_Talos || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Zenithar || deity == PDV_Magnus || deity == PDV_Yffre
    elseIf originRace == ORIGIN_ALTMER
        return deity == PDV_AuriEl || deity == PDV_Magnus || deity == PDV_Xarxes || deity == PDV_Trinimac || deity == PDV_Syrabane
    elseIf originRace == ORIGIN_BOSMER
        return deity == PDV_Yffre || deity == PDV_AuriEl || deity == PDV_Xarxes || deity == PDV_BaanDar || deity == LedgerRuntime.PDV_Zen
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
    if LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE
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
        return GetDunmerAncestorLayerLabel()
    elseIf kindText == "forge"
        return GetOrcLifeModeLabel()
    elseIf kindText == "sects"
        return GetRedguardSectLabel()
    elseIf kindText == "branch"
        return OriginRuntime.GetBosmerPathLabel()
    endIf
    return tierLabel
EndFunction

String Function GetPanelInstrumentDataJson(Int originRace, String kindText, Float piety)
    if kindText == "broad"
        if originRace == ORIGIN_IMPERIAL || originRace == ORIGIN_NORD
            return "{\"standing\":" + PDV_DevotionRules.FormatTwoDecimals(GetBroadLaneStandingValue(originRace)) + ",\"scratch\":" + PDV_DevotionRules.FormatTwoDecimals(GetBroadLaneScratchValue(originRace)) + ",\"pool\":\"" + PDV_DevotionRules.JsonSafeString(LedgerRuntime.GetActiveBroadPantheonPoolId()) + "\",\"baseline\":\"" + PDV_DevotionRules.JsonSafeString(GetBroadLaneDisplayName(originRace)) + "\"}"
        endIf
        return "{\"acts\":" + GetBroadLaneServiceCount(originRace) + "}"
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
        return "{\"depth\":" + depth + ",\"prayer\":" + prayer + ",\"home\":" + home + ",\"reclamation\":\"" + PDV_DevotionRules.JsonSafeString(GetDunmerAncestorLayerLabel()) + "\"}"
    elseIf kindText == "forge"
        return "{\"lifeMode\":\"" + PDV_DevotionRules.JsonSafeString(GetOrcLifeModeLabel()) + "\"}"
    elseIf kindText == "sects"
        return "{\"sect\":\"" + PDV_DevotionRules.JsonSafeString(GetRedguardSectLabel()) + "\"}"
    elseIf kindText == "branch"
        return "{\"path\":\"" + PDV_DevotionRules.JsonSafeString(OriginRuntime.GetBosmerPathLabel()) + "\",\"pactBound\":" + PDV_DevotionRules.BoolToJson(OriginRuntime.IsBosmerPactBound()) + ",\"evidenceDays\":" + OriginRuntime.GetBosmerPathEvidenceDays() + "}"
    endIf
    return "{\"piety\":" + PDV_DevotionRules.FormatTwoDecimals(piety) + ",\"pietyToday\":0.00}"
EndFunction


String Function GetPanelPatronNote()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose a path through play, prayer, and consequence."
    endIf
    PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
    if pactPath
        if GetPlayerOriginRaceIndex() == ORIGIN_BRETON && GetBretonTraditionValue() == BRETON_TRADITION_HIDDEN_ART && IsBretonHiddenArtDaedricOfferDeity(pactPath)
            return "The " + pactPath.DeityName + " pact stands within the Hidden Art; the tradition remains your practiced road."
        endIf
        return "A pact binds you; lesser devotions fall quiet."
    endIf
    if LedgerRuntime.IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    if IsFocusedPantheonBoonSuspended()
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
    if IsFocusedPantheonBoonSuspended()
        return "Suspended"
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        return "Thinning"
    endIf
    if GetActiveDaedricPactPath()
        return "Steady"
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        return "Steady"
    endIf
    return "Quiet"
EndFunction

String Function GetPanelActsJson()
    String items = ""
    PDV_DaedricPathBase actsPact = GetActiveDaedricPactPath()
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
    PDV_DaedricPathBase ritesPact = GetActiveDaedricPactPath()
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
    PDV_DaedricPathBase relsPact = GetActiveDaedricPactPath()
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
    j = j + ",\"Curse\":\"" + PDV_DevotionRules.JsonSafeString(GetPlayerCursePublicLabel()) + "\""
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
        return GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_KHAJIIT
        Int focus = OriginRuntime.GetKhajiitFocusedEmphasis()
        if focus > 0
            return "Focused: " + OriginRuntime.GetKhajiitFocusLabel(focus)
        endIf
        return "Lunar Lattice"
    elseIf originRace == ORIGIN_DUNMER
        return "Ancestor layer: " + GetDunmerAncestorLayerLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return GetRedguardSectLabel()
    elseIf originRace == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerPathLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_BRETON
        return GetBretonTraditionLabel()
    elseIf originRace == ORIGIN_NORD
        return GetNordDevotionModeLabel()
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

    ; Hard daily cap: one credited live signal per path per source per devotional day.
    ; Distinct key namespace (PDV.Daedric.Signal.<pathIndex>.<sourceId>) from any soft-cap
    ; prefix so the .Day book-keeping never collides.
    if !ConsumeOncePerDaySignal("PDV.Daedric.Signal." + pathIndex + "." + sourceId)
        if GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric live signal daily-capped for " + path.DeityName + ": " + sourceId)
        endIf
        return
    endIf
    ; Feed the offer recency gate (HasRecentCommitmentSignalDays) so the formal Prince
    ; offer can fire once enough distinct signal-days accrue.
    LedgerRuntime.RecordCommitmentSignalDay(path)

    Int tierBefore = path.GetStoredTier()
    path.AddCommitmentSignal(sourceId)
    path.AdjustStoredPiety(10.0, sourceId)
    OriginRuntime.RefreshArgonianDominationPressureForPath(path, "daedric_" + sourceId)
    Int tierAfter = path.GetStoredTier()
    ; Hard switch: re-engaging an already-committed (but dormant) Prince makes it the
    ; single active pact again, even without a tier change. OnTierChange covers
    ; first-commit and tier-ups; this covers switch-back. A sub-threshold (tier 0)
    ; Prince never steals the active pact from a committed one.
    if tierAfter > 0 && !path.IsActiveDaedricPact() && path.HasDaedricPactConsent()
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
    ; Pre-pact "taken notice" surfacing is owned by the source-agnostic path-piety seam
    ; (PDV_DaedricPathBase.UpdatePrePactNoticeState queues the crossing;
    ; ProcessPendingDaedricPrePactNotices drains it), so a Prince chronicles the first
    ; time it crosses the notice threshold from ANY piety source -- not only live signals
    ; -- and never below it. A tier gain is a commitment, surfaced above.
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

    ApplyUndeadCryptClearReactions(cryptLoc, 1.0)
    Trace(1, "SignalFloorSmoke crypt-clear debug fanout routed.")
    return "Crypt-clear fanout routed from FormList slot 0. Controlled backend route only; organic proof still requires entering and clearing a listed crypt."
EndFunction

String Function DebugRouteSignalFloorLikesDislikes()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", 0)
    LedgerRuntime.EnsureLikesDislikesTable()
    DebugFireDislike(GetQuestReactionDeity("Kyne"), 303)
    DebugFireDislike(GetQuestReactionDeity("Arkay"), 366)
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




; @module: FAVOR-prereq
; Public accessor so extracted modules (FAVOR) can read the active patron deity
; through the manager backref. _activeDeity is a bare script variable written in
; many manager sites; a getter is sufficient because external read-sites only read.
PDV_DeityBase Function GetActiveDeity()
    return _activeDeity
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
        if path && path.GetDeityForm() == activeForm && path.GetStoredTier() > LedgerRuntime.TIER_NONE
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
        if path && path.GetStoredTier() == LedgerRuntime.TIER_NONE
            Float piety = path.GetStoredPiety()
            ; Only a Prince past the pre-pact notice threshold surfaces (panel "watching"
            ; badge + the "taken notice" beat). Below it, the Prince accrues in silence.
            if piety > topPiety && piety >= path.DAEDRIC_PREPACT_NOTICE_PIETY
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

    if topPath.GetStoredTier() != LedgerRuntime.TIER_NONE || topPath.GetStoredPiety() < topPath.DAEDRIC_PREPACT_NOTICE_PIETY
        return
    endIf

    String symbolName = GetPrismaSymbolForDeity(topPath)
    if symbolName == "journal"
        symbolName = "daedric"
    endIf
    ; The single pre-pact beat: the first time a still-uncommitted Prince crosses the
    ; notice threshold, name it in Book of Days and fire one soft toast. Quest reactions
    ; stay silent until the Prince reaches Seeker (see AccumulateQuestReactionSurface).
    AppendBookOfDaysEntry(topPath.DeityName + " has taken notice of you.", Utility.GetCurrentGameTime() as Int, "daedric.pressure", symbolName, False, 1, "A Prince takes notice")
    SendPrismaDaedricToast(topPath.DeityName, "watching", "An interest taken, not yet a pact.", symbolName)
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
    ; Patron<->Prince severance is retired: an active divine patron is no longer cut when
    ; a Prince pact activates (a pact now requires explicit consent, so both can coexist).
    ; The Prisma shift toast above and this Book-of-Days line still surface the activation.
    if path && !HasRecentDaedricMilestoneJournal(path)
        AppendBookOfDaysEntry(path.DeityName + " claims your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "daedric", true)
    endIf
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

    if shrineLabel != ""
        return NormalizePublicDeityDisplayText(shrineLabel)
    endIf
    return NormalizePublicDeityDisplayText(primaryDeityName)
EndFunction




Function SetDebugLevel(Int levelValue)
    if LedgerRuntime.PDV_GLO_DebugLevel
        LedgerRuntime.PDV_GLO_DebugLevel.SetValue(PDV_DevotionRules.ClampInt(levelValue, 0, 3) as Float)
    endIf
EndFunction






Function HandlePlayerSleepStop(Actor playerRef, Bool wasInterrupted, Bool hadSleepStartContext, Bool sleepStartedOutside, String reason)
    if wasInterrupted
        Trace(3, "Player sleep stop ignored because sleep was interrupted.")
        return
    endIf

    if !playerRef
        Trace(1, "Player sleep stop skipped: player ref missing.")
        return
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == ORIGIN_KHAJIIT
        if !hadSleepStartContext
            Trace(1, "Khajiit road-home rest skipped: sleep-start context missing.")
        elseIf sleepStartedOutside
            OriginRuntime.HandleKhajiitRoadHome("outdoor_rest_" + reason)
        endIf
    endIf

    if originRace == ORIGIN_ARGONIAN
        OriginRuntime.HandleArgonianSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_BOSMER
        OriginRuntime.HandleBosmerSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_BRETON
        HandleBretonSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_DUNMER
        HandleDunmerSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_ALTMER
        OriginRuntime.HandleAltmerSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_NORD
        HandleNordSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_ORC
        HandleOrcSleepEvents(playerRef, reason)
    endIf

    if originRace == ORIGIN_REDGUARD
        HandleRedguardSleepEvents(playerRef, reason)
    endIf
EndFunction

; Production likes/dislikes events that are also authentic cultural-practice
; ingress converge here. Deity scoring remains separate in the event bus.
Function HandleSubstrateActionEvent(Int eventType, String reason)
    Int origin = GetPlayerOriginRaceIndex()
    if origin == ORIGIN_IMPERIAL && !IsImperialVampireStateActive() && PDV_ImperialAncestorSubstrate
        if eventType == 330 || eventType == 331 || eventType == 332
            Float metricBefore = PDV_ImperialAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
            PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(1.0, "craft_" + reason)
            SendPrismaSubstrateProgress("imperial-civic", tierBefore, PDV_ImperialAncestorSubstrate.GetSubstrateTier(), PDV_ImperialAncestorSubstrate.GetMetric() - metricBefore, "Completed craft strengthened civic practice.", "journal", GetImperialCivicTierName())
        endIf
    elseIf origin == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        if eventType == 333
            Float metricBefore = PDV_ArgonianHistSubstrate.GetMetric()
            Int tierBefore = PDV_ArgonianHistSubstrate.GetSubstrateTier()
            PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_cooked_meal", reason)
            SendPrismaSubstrateProgress("argonian-practice", tierBefore, PDV_ArgonianHistSubstrate.GetSubstrateTier(), PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The first cooked meal kept Saxhleel practice.", "journal", OriginRuntime.GetArgonianCulturalPracticeLabel())
        endIf
    elseIf origin == ORIGIN_NORD && PDV_NordAncestorSubstrate
        if eventType == 313
            Float metricBefore = PDV_NordAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
            PDV_NordAncestorSubstrate.RecordAncestralRestScaled(1.0, "open_sky_rest_" + reason)
            SendPrismaSubstrateProgress("ancestor", tierBefore, PDV_NordAncestorSubstrate.GetSubstrateTier(), PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The open sky kept the old practice.", "journal", GetNordAncestorLayerLabel())
        elseIf eventType == 333
            Float metricBefore = PDV_NordAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
            PDV_NordAncestorSubstrate.RecordHearthReturnScaled(1.0, "cooked_meal_" + reason)
            SendPrismaSubstrateProgress("ancestor", tierBefore, PDV_NordAncestorSubstrate.GetSubstrateTier(), PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The first cooked meal kept the hearth.", "journal", GetNordAncestorLayerLabel())
        endIf
    elseIf origin == ORIGIN_ALTMER && PDV_AltmerAncestorSubstrate && !OriginRuntime.IsAltmerFavorSuppressedByCurse()
        ; P2 (2026-08-04) widened the spine's feed set, and answers the question P5 deferred:
        ; YES, ordered study feeds the ancestral spine, as ordered craft already did.
        ;
        ; This adds NO income. TryAwardSubstrateDayCredit caps the substrate at ONE +4.0 credit per
        ; devotional day whatever the source, so extra feeds change only WHICH act can claim the
        ; day -- which is the whole point. A player is never stuck waiting on one specific chore.
        ;
        ; Routed through AwardAltmerAncestorSpinePulse rather than calling
        ; RecordHeritageStandingScaled inline, so every feed gets the same bookkeeping, the same
        ; Prisma progress push, and the same per-source Book of Days voice.
        ; NOTE: these arms deliberately keep their OWN metricBefore / RecordHeritageStandingScaled /
        ; SendPrismaSubstrateProgress rather than routing through AwardAltmerAncestorSpinePulse.
        ; Consolidating them reads cleaner but drops the manager's substrate-progress producer count
        ; below the floor asserted by tools/pdv_substrate_pacing_audit.mjs
        ; (`source.actual-substrate-delta`, >= 19 producers, each reporting the real post-award
        ; delta). The shared voice helper below is the part worth factoring out; the per-producer
        ; delta reporting is intentionally NOT.
        if eventType == 330 || eventType == 331
            String craftToken = "smithing_"
            if eventType == 331
                craftToken = "enchantment_"
            endIf
            Float metricBefore = PDV_AltmerAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_AltmerAncestorSubstrate.GetSubstrateTier()
            PDV_AltmerAncestorSubstrate.RecordHeritageStandingScaled(1.0, craftToken + reason)
            Float grantedMetric = PDV_AltmerAncestorSubstrate.GetMetric() - metricBefore
            SendPrismaSubstrateProgress("altmer-heritage", tierBefore, PDV_AltmerAncestorSubstrate.GetSubstrateTier(), grantedMetric, "", "auri-el", OriginRuntime.GetAltmerHeritageTierName())
            OriginRuntime.AppendAltmerHeritageVoice(grantedMetric, craftToken + reason)

            ; P4: Magnus's renewable curated beat. Enchanting specifically -- binding magicka into
            ; lawful form is his doctrine. Hard 1.2/day ceiling regardless of how many items.
            if eventType == 331 && PDV_Magnus && ConsumeOncePerDaySignal("PDV.Signal.MagnusApertureKept")
                LedgerRuntime.AwardCuratedSignalScaled(PDV_Magnus, PDV_Magnus.SIGNAL_APERTURE_KEPT, None, 1.0)
                LedgerRuntime.SurfaceReservedSignal(PDV_Magnus, "The design holds", "marks an enchantment made as the art demands.")
            endIf
        elseIf eventType == 340 || eventType == 341 || eventType == 342
            Float studyMetricBefore = PDV_AltmerAncestorSubstrate.GetMetric()
            Int studyTierBefore = PDV_AltmerAncestorSubstrate.GetSubstrateTier()
            PDV_AltmerAncestorSubstrate.RecordHeritageStandingScaled(1.0, "study_" + reason)
            Float studyGrantedMetric = PDV_AltmerAncestorSubstrate.GetMetric() - studyMetricBefore
            SendPrismaSubstrateProgress("altmer-heritage", studyTierBefore, PDV_AltmerAncestorSubstrate.GetSubstrateTier(), studyGrantedMetric, "", "auri-el", OriginRuntime.GetAltmerHeritageTierName())
            OriginRuntime.AppendAltmerHeritageVoice(studyGrantedMetric, "study_" + reason)

            ; P5: the Xarxes study stamp. RunDawnAwardAltmerXarxesRecord reads this at the NEXT
            ; dawn to decide whether the ledger noticed yesterday. Independent of the spine credit
            ; above -- the stamp records that study HAPPENED, whether or not it claimed the day.
            StorageUtil.SetIntValue(None, "PDV.Altmer.Xarxes.StudyDay", LedgerRuntime.GetDevotionalDay() + 2)
        endIf
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

    ; fix-plan 4.1 + 4.2. This shared Nord/Orc/Redguard rest-cell declaration compared a
    ; default-0 CandidateDay against raw game day 0 -- the same day-0 class as B13's shrine
    ; credit, here silently refusing the first candidacy sleep of a new save. Devotional
    ; +2 stamp: never 0, and it no longer splits one night's sleep across two days.
    Int today = LedgerRuntime.GetDevotionalDay() + 2
    Int candidateId = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateFormID")
    Int candidateDay = LedgerRuntime.ReadZeroReservedDevotionalDayStamp(keyPrefix + ".CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateCount")

    if candidateId != sleepCellId
        candidateCount = 0
    elseIf candidateDay == today
        return false
    endIf

    candidateCount += 1
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateFormID", sleepCellId)
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp(keyPrefix + ".CandidateDay")
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
    LedgerRuntime.AwardPiety(PDV_Malacath, 0.5, "Took up the Trial of Iron")
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
    LedgerRuntime.AwardPiety(PDV_Tuwhacca, 0.5, "Took up the Remembering of Names")
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
; discipline of magic. One-active, swap via re-rite (clear-before-add). "Not yet" records a
; short three-devotional-day prompt cooldown so declining cannot reopen the menu every rest.
; Returns true when the menu was shown so the dream is suppressed that night. The handler
; guard already blocks this while curse-suppressed.

; Clear-before-add: never two disciplines at once. Coherence reads current crisis state at
; dawn (no snapshot needed), so SyncAltmerDisciplines fades/restores on a crisis break.



; The discipline holds while the player is coherent (no unresolved crisis and not curse-
; suppressed). On a crisis break it goes quiet at dawn and returns at dawn on resolution.
; PDV.Alt.Disc.Active stays set while quiet so no re-rite is needed.



Function HandleImperialSleepEvents(Actor playerRef, String reason)
    ; Retained for save/script compatibility. Imperial sleep is not a civic or
    ; pantheon signal under the pacing contract.
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
    if LedgerRuntime.PDV_Julianos
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Julianos, LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    endIf
    if LedgerRuntime.PDV_Mara
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Mara, LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
    endIf
    AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_RENEWABLE_POINTS, "event_314", "sleep_in_bed_" + reason)
    SurfaceP2AmbientProgressNotice("Hidden reflection", "Rest gives the Hidden Art a hearth-kept shape.")
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
    OriginRuntime.SyncArgonianRewards(Game.GetPlayer())

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
Function HandlePlayerBelowHealthGate(Actor playerRef)
    OriginRuntime.TryBosmerBaanDarGap(playerRef)
    OriginRuntime.TryArgonianSithisNearDeathBurst(playerRef)
    TryOrcCodeHolds(playerRef)
EndFunction

Function HandlePlayerBelowHealthSurvived(Actor playerRef)
    ; Orc Code Holds now fires mid-fight from HandlePlayerBelowHealthGate (Baan Dar
    ; model), so the combat-exit survival path is intentionally a no-op. Left routed
    ; from the player alias for origin 8 without behavior.
EndFunction

; Baan Dar Opens the Gap (Bandit Road signature, once/day). Called from the
; shared player below-health gate when player health drops below 20% in combat.


Function TryOrcCodeHolds(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_ORC
        return
    endIf
    if !playerRef.IsInCombat() || (!PDV_SPEL_OrcCodeHolds && !PDV_SPEL_OrcCodeHolds_Devoted)
        return
    endIf

    Int malacathTier = LedgerRuntime.TIER_NONE
    if PDV_Malacath
        malacathTier = LedgerRuntime.GetTier(PDV_Malacath)
    endIf
    if malacathTier < LedgerRuntime.TIER_SEEKER
        return
    endIf

    ; B12 / fix-plan 4.5. The rescue latched once per COMBAT SESSION while both siblings
    ; -- the Bosmer Baan Dar gap and the Argonian Sithis burst, the two other below-health
    ; payloads fanned from the same HandlePlayerBelowHealthGate -- are once per DAY. An
    ; uncapped 40-60 HP (+30 stamina) clutch save every fight is a different power budget
    ; from what the design says it is. Same LastDay guard, same devotional-day encoding.
    if LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay") == (LedgerRuntime.GetDevotionalDay() + 2)
        Trace(2, "Orc Code Holds suppressed: already spent this devotional day.")
        return
    endIf

    ; The Code Holds is a near-death clutch save. It fires mid-fight the instant
    ; health drops past the below-health gate (Baan Dar Opens the Gap model), not on
    ; combat exit -- so it can actually save the player. Its old
    ; HealRate spell is not cast because Requiem swallows rate-mult healing on a
    ; near-zero base; the actual health save is a flat RestoreActorValue. Requiem-proof.
    if malacathTier >= LedgerRuntime.TIER_DEVOTED && PDV_SPEL_OrcCodeHolds_Devoted
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf PDV_SPEL_OrcCodeHolds
        playerRef.RestoreActorValue("Health", 40.0)
    endIf
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay")

    ; B12's second half asked for a Cast() of PDV_SPEL_OrcCodeHolds* "so the rescue has
    ; feedback". Checked against the records: 071534 and 071536 are both Type=Ability,
    ; CastType=ConstantEffect, TargetType=Self. A constant-effect ability is applied with
    ; AddSpell, never cast -- Spell.Cast() on one is an engine no-op, and the author's
    ; comment above says the HealRate payload is deliberately dead under Requiem anyway.
    ; So the feedback is delivered the way both siblings deliver theirs: a toast.
    SendPrismaToast("malacath", "good", "The Code holds", "The Code holds, and so do you.")

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCodeHolds")
    if multiplier > 0.0
        LedgerRuntime.AwardPiety(PDV_Malacath, 0.5 * multiplier)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CodeHolds.Count", 1)
    Trace(2, "Orc Code Holds fired.")
EndFunction

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

Function HandleGreenPactViolation(String reason)
    if !OriginRuntime.IsBosmerOrigin()
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

    OriginRuntime.AdjustBosmerGreenPactCompliance(-15, reason)
    if PDV_Yffre
        LedgerRuntime.AwardCuratedSignal(PDV_Yffre, PDV_Yffre.SIGNAL_PACT_VIOLATION, None)
        SendPrismaToast(GetPrismaSymbolForDeity(PDV_Yffre), "warning", "Green Pact broken", "You crossed Y'ffre's creed, and the path recoils.")
        SurfaceTransition("creed", "Green Pact", "drop", PDV_Yffre.DeityIndex, "absence", True)
    endIf

    Trace(2, "Green Pact violation count " + violationCount + " (" + reason + ")")
EndFunction















Function HandleStateTransitionConfirmationRite(String reason)
    if OriginRuntime.IsBosmerOrigin()
        OriginRuntime.ConfirmBosmerPendingTransition(reason)
    endIf
EndFunction

Function HandleDunmerPortableShrinePrayer(String reason)
    if PDV_DunmerAncestorSubstrate
        ; Layer 1 (ancestor substrate) is silenced under vampirism, halved under the
        ; beast. Layer 2 (Reclamation memory) still answers, so it routes regardless.
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerPortableShrinePrayer") * layerWeight
            Float metricBefore = PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Ancestor prayer marked.", "ancestor", GetDunmerAncestorLayerLabel())
            ; The Ledger driver for the ancestral layer. Sits inside the layerWeight guard on purpose:
            ; vampirism silences this layer entirely, so a silenced prayer must not record one either.
            ; Self-caps to the first prayer of the devotional day; patron-independent by ruling.
            AwardDunmerAncestorSpinePulse(multiplier, reason)
        else
            Trace(2, "Dunmer ancestor layer silenced by curse posture (" + reason + ")")
        endIf
        NotifyDiegeticRoutineFavor("dunmer_portable_shrine")
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
        RequestPanelRefresh()
        Trace(2, "Dunmer portable shrine prayer routed (" + reason + ")")
    endIf
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    Actor homePlayer = Game.GetPlayer()
    if !_dunmerHomePrayerContext || !IsPlayerAtDunmerDeclaredHome(homePlayer)
        if PDV_DunmerAncestorSubstrate
            PDV_DunmerAncestorSubstrate.RecordDailyCreditReject("dunmer_home_prayer", reason, "requires_paired_home_prayer")
        endIf
        Trace(2, "Dunmer home-only substrate route rejected (" + reason + ")")
        return
    endIf
    if PDV_DunmerAncestorSubstrate
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerHomeBonus") * layerWeight
            Float metricBefore = PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)
            Int tierAfter = PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Prayers within the home feel more meaningful.", "ancestor", GetDunmerAncestorLayerLabel())
            ; Ancestor watch (11a rework 2026-07-04): the home prayer no longer heals on
            ; the spot; it arms a once-per-day near-death save that lasts until dawn (the
            ; BaanDar-style low-health watcher, PDV_T3DailyLowHealthSaveEffect on the
            ; PDV_SPEL_Dunmer_AncestorWatch ability). ProcessDawn disarms it, so each
            ; day's protection must be re-earned with a fresh home prayer.
            if homePlayer && PDV_SPEL_Dunmer_AncestorWatch && !homePlayer.HasSpell(PDV_SPEL_Dunmer_AncestorWatch)
                homePlayer.AddSpell(PDV_SPEL_Dunmer_AncestorWatch, False)
                Trace(2, "Dunmer ancestor watch armed (" + reason + ")")
            endIf
        else
            Trace(2, "Dunmer home rite silenced by curse posture (" + reason + ")")
        endIf
        NotifyDiegeticRoutineFavor("dunmer_home_bonus")
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
    ; fix-plan 4.2: the ancestor-home cadence now runs on the shared 06:00 devotional
    ; day with the same zero-reserved +2 encoding the Argonian bed rite uses, so a
    ; midnight crossed mid-sleep can no longer shorten the decline window or split one
    ; night's sleep across two "days". ReadZeroReserved migrates the legacy +1 stamps.
    Int todayStamp = LedgerRuntime.GetDevotionalDay() + 2
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
            SetDunmerHome(sleepCellId, todayStamp, reason)
        endIf
        return
    endIf

    Int declinedDay = LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
    if declinedDay > 0 && (todayStamp - declinedDay) < 3
        return
    endIf

    Bool shouldPrompt = declaredId == 0
    if declaredId != 0
        Int candidateId = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateFormID")
        Int candidateCount = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateCount")
        Int candidateDay = LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
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
        LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
        shouldPrompt = candidateCount >= 3
    endIf

    if !shouldPrompt
        return
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_DunmerMarkHome.Show()
    ; B4 / fix-plan 3. -1 is "another menu was already up", not a decline: no 3-day
    ; suppression stamp and no wipe of the three-sleep candidacy the player earned.
    if pressed < 0
        Trace(2, "Dunmer ancestor-home menu not shown (menu busy); candidacy kept.")
        return
    endIf
    if pressed == 0
        SetDunmerHome(sleepCellId, todayStamp, reason)
    else
        LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
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


; Mephala/Boethiah serve BOTH the Dunmer Reclamations and the Khajiit roster, so
; these two gate on quest-reaction reachability, not a single origin.
Function HandleMephalaWebWoven(String reason)
    if !PDV_Mephala || !IsQuestReactionDeityReachable(PDV_Mephala)
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.MephalaWebWoven")
    if multiplier <= 0.0
        Trace(2, "Mephala web-woven blocked by daily cap (" + reason + ")")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_WEB_WOVEN, None, multiplier)
    LedgerRuntime.SurfaceReservedSignal(PDV_Mephala, "Web woven", "marks a web woven in shadow.")
    Trace(2, "Mephala web-woven routed (" + reason + ")")
EndFunction

Function HandleBoethiahHonorableDuel(String reason)
    if !PDV_Boethiah || !IsQuestReactionDeityReachable(PDV_Boethiah)
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BoethiahHonorableDuel")
    if multiplier <= 0.0
        Trace(2, "Boethiah honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_HONORABLE_DUEL, None, multiplier)
    LedgerRuntime.SurfaceReservedSignal(PDV_Boethiah, "Duel honored", "marks a trial honorably won.")
    Trace(2, "Boethiah honorable-duel routed (" + reason + ")")
EndFunction

Function HandleNordTsunAdversitySurvived(String reason)
    if !PDV_Tsun || !IsQuestReactionDeityReachable(PDV_Tsun)
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.NordTsunAdversity")
    if multiplier <= 0.0
        Trace(2, "Tsun adversity blocked by daily cap (" + reason + ")")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Tsun, PDV_Tsun.SIGNAL_ADVERSITY_SURVIVED, None, multiplier)
    LedgerRuntime.SurfaceReservedSignal(PDV_Tsun, "Adversity survived", "marks a hard fight endured to its end.")
    Trace(2, "Tsun adversity-survived routed (" + reason + ")")
EndFunction

Function HandleLekiHonorableDuel(String reason)
    if !PDV_Leki || !IsQuestReactionDeityReachable(PDV_Leki)
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.LekiHonorableDuel")
    if multiplier <= 0.0
        Trace(2, "Leki honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Leki, PDV_Leki.SIGNAL_HONORABLE_DUEL, None, multiplier)
    LedgerRuntime.SurfaceReservedSignal(PDV_Leki, "Duel honored", "marks single combat honorably won.")
    Trace(2, "Leki honorable-duel routed (" + reason + ")")
EndFunction

Function HandleTalosWorshipperRescued(String reason)
    if !PDV_Talos || !IsQuestReactionDeityReachable(PDV_Talos)
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Signal.TalosWorshipperRescue.Done") == 1
        Trace(2, "Talos worshipper-rescue already banked (" + reason + ")")
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.TalosWorshipperRescue.Done", 1)
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_PROTECT_WORSHIPPER, None, 1.0)
    LedgerRuntime.SurfaceReservedSignal(PDV_Talos, "A worshipper protected", "marks one of the faithful carried out of Thalmor hands.")
    Trace(1, "Talos protect-worshipper routed (" + reason + ")")
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
    ; 2026-07-15 full-pantheon expansion: the dragon of the covenant, repentant,
    ; slain at the Blades' demand -- the time-and-order gods mourn it, the
    ; treachery-and-dominion Princes savor it.
    ApplyPaarthurnaxKillReaction("Akatosh", "S", sourceForm)
    ; Alkosh is deliberately absent here: the kill path already routes
    ; RouteKhajiitAlkoshChaosAid for Khajiit players (PDV_PlayerEvents), and Alkosh is
    ; reachable to no one else, so a row here would only double-penalize a Khajiit.
    ApplyPaarthurnaxKillReaction("Talos", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Julianos", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Auri-El", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Khenarthi", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Kynareth", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Boethiah", "S", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Hircine", "S", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Molag Bal", "m", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Mehrunes Dagon", "m", sourceForm, "+")
    FlushQuestReactionSurface()
    Trace(2, "Paarthurnax kill fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxKillReaction(String deityName, String intensity, Form sourceForm, String valence = "-")
    LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, "small", "paarthurnax_kill", False, sourceForm)
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
    ; 2026-07-15 full-pantheon expansion: mercy for the repentant dragon honors
    ; the time-and-order gods; the treachery-and-dominion Princes read it as
    ; weakness.
    ApplyPaarthurnaxSpareReaction("Akatosh", "S", sourceForm)
    ApplyPaarthurnaxSpareReaction("Talos", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Alkosh", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Auri-El", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Kynareth", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Boethiah", "m", sourceForm, "-")
    ApplyPaarthurnaxSpareReaction("Molag Bal", "m", sourceForm, "-")
    FlushQuestReactionSurface()
    Trace(2, "Paarthurnax spare fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxSpareReaction(String deityName, String intensity, Form sourceForm, String valence = "+")
    LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, "small", "paarthurnax_spare", False, sourceForm)
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
            OriginRuntime.ShowKhajiitMessage(PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow.", False)
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
Function HandleOrcStoryCraftForge(Location craftLocation)
    if !IsOrcOrigin()
        return
    endIf
    if GetOrcStrongholdHoldId(craftLocation) <= 0
        return
    endIf
    HandleOrcStrongholdForge("story_craft_stronghold")
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

    if PDV_Malacath && PDV_OrcLifeModeTrack && PDV_OrcLifeModeTrack.GetCurrentState() == ORC_LIFE_MODE_LEGION_EXILE && StorageUtil.GetIntValue(None, "PDV.Signal.MalacathExileReturn.Done") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.MalacathExileReturn.Done", 1)
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_EXILE_RETURN, None, 1.0)
        LedgerRuntime.SurfaceReservedSignal(PDV_Malacath, "Burden carried home", "marks the Exile's return to a stronghold hearth.")
        Trace(1, "Malacath exile-return banked (location_stronghold)")
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
    if PDV_SPEL_OrcHearthHeld && PDV_OrcLifeModeTrack.GetCurrentState() == ORC_LIFE_MODE_STRONGHOLD && ConsumeOncePerDaySignal("PDV.Signal.OrcHearthHeld")
        Actor hearthPlayer = Game.GetPlayer()
        if hearthPlayer
            PDV_SPEL_OrcHearthHeld.Cast(hearthPlayer, hearthPlayer)
            Trace(2, "Orc hearth-held comfort cast (" + reason + ")")
        endIf
    endIf
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
    ; Curated award (dead-wiring burndown Wave 1, 2026-07-07): this handler recorded
    ; life-mode progress but -- unlike its CityDignity/LegionService/SelfMadeCommunity
    ; siblings -- never dispatched the curated signal, so BLOOD_KIN could never bank.
    ; The crisis is a one-shot quest milestone (The Cursed Tribe resolution); the latch
    ; keeps a save-reload edge from ever double-banking it.
    if StorageUtil.GetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded", 1)
        AwardOrcBloodKinSignal(1.0)
    endIf
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
    SurfaceP2BookReadNotice(reason, "The Code of Malacath", "Malacath weighs your conduct against it.")
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
    return PDV_DevotionRules.StringContainsToken(reason, "orc_bloodkin_crisis") || PDV_DevotionRules.StringContainsToken(reason, "orc_cursed_tribe_resolved") || PDV_DevotionRules.StringContainsToken(reason, "orc_major_gate")
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
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, None, multiplier)
    endIf
EndFunction

Function AwardOrcBloodKinSignal(Float multiplier)
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_BLOOD_KIN, None, multiplier)
    endIf
EndFunction

Function AwardOrcCityDignitySignal(Float multiplier)
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_CITY_DIGNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcLegionServiceSignal(Float multiplier)
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_LEGION_SERVICE, None, multiplier)
    endIf
EndFunction

Function AwardOrcSelfMadeCommunitySignal(Float multiplier)
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcBroadConductSignal(Float multiplier)
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_BROAD_CONDUCT, None, multiplier)
    endIf
EndFunction

Function AwardOrcOathBreakSignal()
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_OATH_BREAK, None)
    endIf
EndFunction

Function AwardOrcFourHoldsVisitSignal()
    if PDV_Malacath
        LedgerRuntime.AwardCuratedSignal(PDV_Malacath, PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT, None)
    endIf
EndFunction

Function AwardOrcAncestorSpineSignal(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_ORC || !PDV_Malacath || multiplier <= 0.0
        return
    endIf

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_ANCESTOR_SPINE, None, multiplier)
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
    ; fix-plan 4.2: devotional day, so a notice cannot re-fire at raw midnight.
    Int dayIndex = LedgerRuntime.GetDevotionalDay() + 2
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
        ; Declaring a hearth is a once-ever moment (the flag above guards it), so it
        ; earns a toast plus a permanent Book of Days beat rather than a transient
        ; corner notice. The toast honours the Notifications preference at the shared
        ; chokepoint while the Book entry always logs. PDV_Notif_Orc_HearthHeld_Declare
        ; is deliberately no longer shown here (it would double the surface); the
        ; record stays in the ESP, orphaned, with its text kept in sync.
        SendPrismaToast("malacath", "good", "A hearth held", "You claim this hearth as your own, and swear to hold it.")
        AppendBookOfDaysEntry("You claim this hearth as your own, and swear to hold it.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
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
        if _qrQueueTransactionActive
            _qrQueueNeedsCurseRefresh = True
        else
            LedgerRuntime.HandleCurseStateRefresh("quest_reaction_" + deityName)
        endIf
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

    Float stanceMultiplier = GetQuestReactionStanceMultiplier(stance)

    Float appliedReactionAmount = amount * stanceMultiplier
    _suppressAwardFavorToast = True
    ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    _suppressAwardFavorToast = False
    AccumulateQuestReactionSurface(deity, appliedReactionAmount, "small")

    if OriginRuntime.IsKhajiitOrigin()
        OriginRuntime.BridgeKhajiitMatrixFocus(deityName, "small")
    endIf
EndFunction

Bool Function IsRedguardNamedNecromancerBurden(Actor victimActor)
    if !victimActor
        return False
    endIf

    if LedgerRuntime.NecromancerFaction && victimActor.IsInFaction(LedgerRuntime.NecromancerFaction)
        return True
    endIf

    if LedgerRuntime.WarlockFaction && victimActor.IsInFaction(LedgerRuntime.WarlockFaction)
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

    Int tuwhaccaTier = LedgerRuntime.GetTier(PDV_Tuwhacca)
    if tuwhaccaTier < LedgerRuntime.TIER_DEVOTED
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay") == (LedgerRuntime.GetDevotionalDay() + 2)
        Trace(2, "Redguard Tu'whacca death-rite heal suppressed (already restored today).")
        return
    endIf
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay")

    Float deathRiteHeal = 30.0
    if tuwhaccaTier >= LedgerRuntime.TIER_CHAMPION
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

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf
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
    SurfaceP2BookReadNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")
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

; Tu'whacca vampire re-entry (2026-07-15, wire): the cure sets
; PDV.Redguard.VampireReentryNeeded; the next authentic sect act while mortal
; completes the return through Tu'whacca. The flag itself is the one-shot latch.
Function HandleRedguardVampireReentryComplete(String reason)
    if !PDV_Tuwhacca || !IsQuestReactionDeityReachable(PDV_Tuwhacca)
        return
    endIf
    LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_VAMPIRE_REENTRY, None, 1.0)
    LedgerRuntime.SurfaceReservedSignal(PDV_Tuwhacca, "The cycle restored", "marks the return through Tu'whacca after the curse.")
    Trace(1, "Tu'whacca vampire re-entry completed (" + reason + ")")
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

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf

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
    return PDV_DevotionRules.StringContainsToken(reason, "redguard_deathduty_major") || PDV_DevotionRules.StringContainsToken(reason, "redguard_ashabah_burden")
EndFunction

Function AwardRedguardCrownSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_CROWN_FORM, None, multiplier)
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
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Leki, PDV_Leki.SIGNAL_SWORD_SINGING, None, multiplier)
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

    LedgerRuntime.AwardCuratedSignalScaled(PDV_HoonDing, PDV_HoonDing.SIGNAL_MAKE_WAY, victimForm, multiplier)
    Trace(2, "HoonDing make-way fired: breakthrough " + traceLabel + " kill multiplier=" + multiplier)
EndFunction

Function AwardRedguardAshAbahSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "ashabah_death_duty_" + reason)
EndFunction

Function AwardRedguardFarShoresSignal(Float multiplier, String reason)
    if PDV_Tuwhacca
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "far_shores_" + reason)
EndFunction

Function AwardRedguardAncestorSpinePietyPulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || multiplier <= 0.0
        return
    endIf

    if PDV_Tuwhacca
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE, None, multiplier)
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
        Float metricBefore = PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordAncestorStandingScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line remembered.", "journal", GetNordAncestorLayerLabel())
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
        Float metricBefore = PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordAncestralRestScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line rested near.", "journal", GetNordAncestorLayerLabel())
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
        Float metricBefore = PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = PDV_NordAncestorSubstrate.GetSubstrateTier()
        PDV_NordAncestorSubstrate.RecordHearthReturnScaled(multiplier, reason)
        Int tierAfter = PDV_NordAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The hearth remembered your return.", "journal", GetNordAncestorLayerLabel())
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
        if PDV_Tuwhacca && LedgerRuntime.GetTier(PDV_Tuwhacca) >= LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Crown, "The Crown way has become more than memory. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Crown way is more than memory in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_FOREBEAR
        if PDV_HoonDing && LedgerRuntime.GetTier(PDV_HoonDing) >= LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_Forebear, "The Forebear way has become more than adaptation. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == REDGUARD_SECT_ASHABAH
        if PDV_Tuwhacca && LedgerRuntime.GetTier(PDV_Tuwhacca) >= LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(PDV_Msg_Redguard_ChampionEntry_AshAbah, "The Ash'abah duty has become more than necessity. It is a public shape of your devotion.", False)
            AppendBookOfDaysEntry("The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            SendPrismaShiftToast("The Ash'abah duty, made public.", "More than necessity now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    endIf
EndFunction

; Nord/Kyne counterpart to MaybeShowRedguardChampionEntry. The Redguard beat hangs off a SECT
; change, so it never collides with a tier surface; Kyne's recognition IS the tier reach, so this
; is deliberately ADDITIVE rather than a suppression like ShouldSuppressBretonFocusedChampionTierSurface.
; The universal surface above keeps the toast, the Book of Days entry and the Ledger feed; this
; only adds the authored modal on top. Suppressing the generic surface would silence all three.
Function MaybeShowNordKyneChampionEntry(PDV_DeityBase deity, Int newTier)
    if newTier < LedgerRuntime.TIER_CHAMPION
        return
    endIf
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return
    endIf
    if !PDV_Kyne || deity != PDV_Kyne
        return
    endIf
    if IsRaceSetupQuietPresentationActive()
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
    _pendingNordKyneChampionMsg = PDV_Msg_Nord_Kyne_ChampionEntry
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
    Trace(1, "Nord/Kyne champion recognition presented.")
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
    if GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && !IsImperialVampireStateActive()
        StorageUtil.SetIntValue(None, "PDV.Imperial.TalosBroadUnlocked", 1)
        Trace(1, "Imperial broad Talos roster unlocked by shrine defiance: " + reason)
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.TalosShrineDefiance")
    if PDV_Talos
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
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
Function HandleThalmorUnprovokedKill(Form victimForm)
    if OriginRuntime.IsAltmerOrigin()
        OriginRuntime.HandleAltmerAlignmentSignal("kill_thalmor_agent", victimForm, "thalmor_unprovoked_kill")
    elseIf GetPlayerOriginRaceIndex() == 1
        ApplyImperialConcordatAction("kill_thalmor_justiciar_unprovoked", "thalmor_unprovoked_kill")
    endIf
EndFunction



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
Bool Function IsSyrabaneSignalEligible()
    return OriginRuntime.IsAltmerOrigin() && PDV_Syrabane && !OriginRuntime.IsAltmerFavorSuppressedByCurse()
EndFunction

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










Function HandleShoutAttack(Int eventType, Actor playerRef, Shout shoutUsed, String reason)
    if !playerRef
        Trace(1, "Shout attack skipped: player ref missing.")
        return
    endIf

    if ShouldSuppressDuplicateShoutAttack()
        Trace(3, "Shout attack duplicate suppressed (" + reason + ")")
        return
    endIf

    if !LedgerRuntime.PDV_FLST_AllDeities
        Trace(1, "Shout attack skipped: deity roster missing.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.ShoutAttack")
    if multiplier <= 0.0
        Trace(2, "Shout attack decayed out for today; no piety award.")
        return
    endIf

    Int i = 0
    Int count = LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    Int scoredCount = 0
    LedgerRuntime.BeginBroadPantheonEvent("shout_attack_" + eventType + "_" + reason)

    while i < count
        PDV_DeityBase deity = LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float delta = deity.ScoreAction(eventType, playerRef as Form, shoutUsed as Form)
            if delta != 0.0
                LedgerRuntime.AwardPietyFromLikesDislikes(deity, delta * multiplier, eventType, reason)
                scoredCount += 1
            endIf
        endIf

        i += 1
    endWhile
    LedgerRuntime.FlushBroadPantheonEvent()

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
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
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
    Int[] pldEvents = new Int[33]
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
    pldEvents[31] = 305
    pldEvents[32] = 306
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
                ; fix-plan 4.3: the Prince lane applies its deepen delta directly to the
                ; path's own piety with no gain pipeline in between, so a nonzero delta
                ; here always lands -- spend the cap slot. (Nothing is queued when the
                ; delta is zero, so the else side needs no discard.)
                ropPath.CommitPendingRepeatableActions()
                ropPath.AdjustStoredPiety(ropDelta, "v2_" + eventType)
                OriginRuntime.RefreshArgonianDominationPressureForPath(ropPath, "prince_v2_" + eventType)
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
        WritePLD(path, 305, 0.5, 3, 0.0)
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
        WritePLD(path, 305, 0.5, 2, 0.5)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 364, 0.5, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 306, 0.5, 3, 0.0)
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
        WritePLD(path, 305, -0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 302, 1.0, 2, 0.5)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 360, -0.25, 3, 0.0)
    endIf
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
    EmitBookOfDaysBroadLaneTierChange(today)
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

Function EmitBookOfDaysBroadLaneTierChange(Int today)
    Int originRace = GetPlayerOriginRaceIndex()
    Int broadTier = GetBroadLaneTierForOrigin(originRace)
    if broadTier <= LedgerRuntime.TIER_NONE
        return
    endIf

    Int tier = LedgerRuntime.TIER_SEEKER
    while tier <= broadTier && tier <= LedgerRuntime.TIER_DEVOTED
        String guard = "PDV.BookOfDays.BroadLaneTierShown." + originRace + "." + tier
        if StorageUtil.GetIntValue(None, guard) != 1
            StorageUtil.SetIntValue(None, guard, 1)
            AppendBookOfDaysEntry(BuildBroadLaneTierReachJournalLine(originRace, tier), today, "tier.reach", GetBroadLaneSymbol(originRace), False, tier)
        endIf
        tier += 1
    endWhile
EndFunction

String Function BuildBroadLaneTierReachJournalLine(Int originRace, Int tier)
    return GetBroadLaneDisplayName(originRace) + " has reached " + GetBroadLaneStandingLabel(originRace, tier) + "."
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
        return "The ancestral record marks a turn in your discipline: " + modeLabel + "."
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




Function DebugForceSetPietyByIndex(Int deityIndex, Float amount)
    PDV_DeityBase deity = LedgerRuntime.GetDeityByIndex(deityIndex)
    if !deity
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] DebugForceSetPietyByIndex failed: no deity with index " + deityIndex)
        endIf
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
        SetBretonPracticeCount(GetBretonTraditionValue(), BRETON_PRACTICE_DEVOTED_POINTS)
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

    Int traditionValue = GetBretonTraditionValue()
    Int practicePoints = GetBretonPracticeCount(traditionValue)
    Int today = LedgerRuntime.GetDevotionalDay() + 2
    Int pointDay = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointDay", -1)
    Int pointsToday = 0
    if pointDay == today
        pointsToday = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointsToday")
    endIf
    pointsToday = PDV_DevotionRules.ClampInt(pointsToday, 0, BRETON_PRACTICE_DAILY_MAX_POINTS)
    Int remainingToday = BRETON_PRACTICE_DAILY_MAX_POINTS - pointsToday
    return GetBretonTraditionLabel() + ": " + practicePoints + "/" + BRETON_PRACTICE_DEVOTED_POINTS + " practice points (" + GetPublicTierBand(GetBretonPracticeTier(traditionValue)) + "). Today: " + pointsToday + "/" + BRETON_PRACTICE_DAILY_MAX_POINTS + "; remaining " + remainingToday + "."
EndFunction

String Function DebugSetBretonPracticePoints(Int practicePoints)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return "Breton practice target ignored: set Breton origin first."
    endIf

    Int traditionValue = GetBretonTraditionValue()
    SetBretonPracticeCount(traditionValue, practicePoints)
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
    Bool applied = AwardBretonPracticePulse(GetBretonTraditionValue(), requestedPoints, "mcm_debug_" + sequence, "mcm-debug-practice")
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



Function AccumulateQueuedQuestReactionBroadDelta(PDV_DeityBase deity, Float appliedDelta)
    if _qrQueueBroadPool == "" || !deity || !LedgerRuntime.IsDeityEligibleForBroadPantheon(deity, _qrQueueBroadPool)
        return
    endIf
    if appliedDelta > 0.0 && appliedDelta > _qrQueueBroadBestPositive
        _qrQueueBroadBestPositive = appliedDelta
    elseIf appliedDelta < 0.0 && appliedDelta < _qrQueueBroadWorstNegative
        _qrQueueBroadWorstNegative = appliedDelta
    endIf
EndFunction

Function CommitQueuedQuestReactionBroad(String reactionKey)
    Float chosenDelta = 0.0
    if _qrQueueBroadBestPositive > 0.0
        chosenDelta = _qrQueueBroadBestPositive
    elseIf _qrQueueBroadWorstNegative < 0.0
        chosenDelta = _qrQueueBroadWorstNegative
    endIf
    if _qrQueueBroadPool != "" && chosenDelta != 0.0
        Float nowTime = Utility.GetCurrentGameTime()
        if !LedgerRuntime.IsRecentBroadPantheonEventDuplicate(_qrQueueBroadPool, "quest_" + reactionKey, nowTime)
            LedgerRuntime.CatchUpBroadPantheonDecayBeforeCurrentDay(_qrQueueBroadPool)
            if LedgerRuntime.GetBroadPantheonScratch(_qrQueueBroadPool) == 0.0
                LedgerRuntime.WriteZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonScratchDayKey(_qrQueueBroadPool))
            endIf
            StorageUtil.AdjustFloatValue(None, LedgerRuntime.GetBroadPantheonScratchKey(_qrQueueBroadPool), chosenDelta)
            StorageUtil.SetStringValue(None, LedgerRuntime.GetBroadPantheonLastEventKey(_qrQueueBroadPool), "quest_" + reactionKey)
            StorageUtil.SetFloatValue(None, LedgerRuntime.GetBroadPantheonLastEventTimeKey(_qrQueueBroadPool), nowTime)
            LedgerRuntime.RememberBroadPantheonEvent(_qrQueueBroadPool, "quest_" + reactionKey, nowTime)
            if chosenDelta > 0.0
                LedgerRuntime.WriteZeroReservedDevotionalDayStamp(LedgerRuntime.GetBroadPantheonLastGainDayKey(_qrQueueBroadPool))
            endIf
        endIf
    endIf
    _qrQueueBroadPool = ""
    _qrQueueBroadBestPositive = 0.0
    _qrQueueBroadWorstNegative = 0.0
EndFunction


; Generic non-presented actions can spend several seconds scoring the full deity
; roster. Their broad result is carried in caller-local variables so that work
; never owns the Manager's shared temporary scope across the fan-out.




























; Manager-owned daily stamps use the same zero-reserved encoding as substrates.
; Existing +1 stamps are migrated once per key through a sibling encoding flag.



Bool Function IsImperialVampireStateActive()
    return StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
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

Function HandleWayfarerAkatoshLevel()
    if !LedgerRuntime.PDV_ModePresetRef || !LedgerRuntime.PDV_ModePresetRef.AllowCheapRepeatables()
        return
    endIf
    if !LedgerRuntime.PDV_Akatosh
        return
    endIf

    Float baseAmount = 1.0
    Float weight = LedgerRuntime.PDV_ModePresetRef.CheapRepeatableWeight()
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")
    Float amount = baseAmount * weight * multiplier
    if amount > 0.0
        LedgerRuntime.AwardPietyInternal(LedgerRuntime.PDV_Akatosh, amount, True, "wayfarer_akatosh_level")
    endIf
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
    if GetPlayerOriginRaceIndex() == ORIGIN_BRETON && GetBretonTraditionValue() == BRETON_TRADITION_HIDDEN_ART && IsBretonHiddenArtDaedricOfferDeity(deity) && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
        return 1.25
    endIf
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








Bool Function IsKyneNeglectActive()
    return LedgerRuntime.IsNeglectFlagActive(PDV_Kyne)
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


Bool Function IsBroadLaneLapsed()
    ; Broad-lane recency lapse: a full-pantheon (broad) worshipper who has practiced at least once
    ; and then goes quiet for NEGLECT_LAPSE_GRACE_DAYS feels gentle neglect too. Generalizes the
    ; Imperial civic-lapse model to the broad lane, keyed off the global PDV.Devotion.LastActTime.
    if !LedgerRuntime.IsBroadWorshipActive()
        return False
    endIf
    Float lastAct = StorageUtil.GetFloatValue(None, "PDV.Devotion.LastActTime")
    if lastAct <= 0.0
        return False
    endIf
    return (Utility.GetCurrentGameTime() - lastAct) > LedgerRuntime.NEGLECT_LAPSE_GRACE_DAYS
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
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Shor,  isNord && _activeDeity == PDV_Shor  && LedgerRuntime.IsNeglectFlagActive(PDV_Shor))
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Tsun,  isNord && _activeDeity == PDV_Tsun  && LedgerRuntime.IsNeglectFlagActive(PDV_Tsun))
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Stuhn, isNord && _activeDeity == PDV_Stuhn && LedgerRuntime.IsNeglectFlagActive(PDV_Stuhn))
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, PDV_SPEL_Neglect_Talos, isNord && _activeDeity == PDV_Talos && LedgerRuntime.IsNeglectFlagActive(PDV_Talos))
    ; Nord Old Ways patrons (Orkey/Dibella roster). _activeDeity keys on the internal Arkay/Dibella
    ; deity, not the "Orkey" display name; the spell record carries the Orkey-facing name.
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, LedgerRuntime.PDV_SPEL_Neglect_Arkay,   isNord && _activeDeity == LedgerRuntime.PDV_Arkay   && LedgerRuntime.IsNeglectFlagActive(LedgerRuntime.PDV_Arkay))
    LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, LedgerRuntime.PDV_SPEL_Neglect_Dibella, isNord && _activeDeity == LedgerRuntime.PDV_Dibella && LedgerRuntime.IsNeglectFlagActive(LedgerRuntime.PDV_Dibella))
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
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T1, False, "Breton Tradition T1 (retired)")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Tradition_T2, False, "Breton Tradition T2 (retired)")

    ; Unified model (2026-07-13): the tradition family grants T1/T2 practice only.
    ; The former T3 slots (KnightsRoad_T3 / GreenWay_T3 / HiddenArt_T3) are now
    ; patron-champion boons owned solely by SyncBretonChampionBoon, so the family
    ; sync must not touch them (else it would strip a boon the champion sync just
    ; granted - the reused-spell cross-lane strip, within Breton).
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_KNIGHTS_ROAD, traditionValue, PDV_Bless_Breton_KnightsRoad_T1, PDV_Bless_Breton_KnightsRoad_T2, "KnightsRoad")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_HIDDEN_ART, traditionValue, PDV_Bless_Breton_HiddenArt_T1, PDV_Bless_Breton_HiddenArt_T2, "HiddenArt")
    SyncBretonTraditionRewardFamily(playerRef, BRETON_TRADITION_GREEN_WAY, traditionValue, PDV_Bless_Breton_GreenWay_T1, PDV_Bless_Breton_GreenWay_T2, "GreenWay")
    SyncBretonChampionBoon(playerRef, isBreton, traditionValue)
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

; Unified model (2026-07-13): the tradition family grants T1/T2 practice tiers.
; A Champion boon that reuses this tradition's own T3 record replaces T2 because
; the T3 effects are absolute cumulative totals. A distinct patron boon remains
; beside T2 as the second family.
Function SyncBretonTraditionRewardFamily(Actor playerRef, Int thisTradition, Int activeTradition, Spell t1, Spell t2, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_BRETON && thisTradition == activeTradition
    if thisTradition == BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        isActive = False
    endIf

    Int activeTier = LedgerRuntime.TIER_NONE
    PDV_DeityBase presentationDeity = None
    if isActive
        activeTier = GetBretonTraditionTier(thisTradition)
        presentationDeity = GetBretonTraditionPresentationDeity(thisTradition)
    endIf

    Bool hadT1Spell = LedgerRuntime.HasRewardSpell(playerRef, t1)
    Bool hadT2Spell = LedgerRuntime.HasRewardSpell(playerRef, t2)
    Bool wantsT1Spell = isActive && activeTier == LedgerRuntime.TIER_SEEKER
    Bool championReplacesT2 = isActive && IsBretonPracticeTierReplacedByChampion(thisTradition)
    Bool wantsT2Spell = isActive && activeTier >= LedgerRuntime.TIER_DEVOTED && !championReplacesT2
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, wantsT1Spell, "Breton " + label + " T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, wantsT2Spell, "Breton " + label + " T2")
    MaybeShowBretonTraditionRewardPresentation(playerRef, t1, hadT1Spell, wantsT1Spell, presentationDeity, label, LedgerRuntime.TIER_SEEKER)
    MaybeShowBretonTraditionRewardPresentation(playerRef, t2, hadT2Spell, wantsT2Spell, presentationDeity, label, LedgerRuntime.TIER_DEVOTED)
EndFunction

Bool Function IsBretonPracticeTierReplacedByChampion(Int traditionValue)
    PDV_DeityBase championSource = GetBretonChampionSource(True, traditionValue)
    if !championSource
        return False
    endIf

    Spell championSpell = GetBretonPatronChampionBoon(championSource, traditionValue)
    Spell traditionChampionSpell = None
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        traditionChampionSpell = PDV_Bless_Breton_KnightsRoad_T3
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        traditionChampionSpell = PDV_Bless_Breton_HiddenArt_T3
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        traditionChampionSpell = PDV_Bless_Breton_GreenWay_T3
    endIf

    return championSpell && traditionChampionSpell && championSpell == traditionChampionSpell
EndFunction

PDV_DeityBase Function GetBretonChampionSource(Bool isBreton, Int traditionValue)
    if isBreton && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity && LedgerRuntime.GetTier(_activeDeity) >= LedgerRuntime.TIER_CHAMPION
        return _activeDeity
    endIf
    if isBreton && traditionValue == BRETON_TRADITION_HIDDEN_ART
        PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
        if activePact && activePact.GetStoredTier() >= LedgerRuntime.TIER_CHAMPION
            return activePact
        endIf
    endIf
    return None
EndFunction

; Unified model (2026-07-13): the active Champion patron brings their OWN
; champion boon, resonant or not. Exactly one is active at a time; every other
; Breton champion boon strips. Resonance selects the presentation line only.
Function SyncBretonChampionBoon(Actor playerRef, Bool isBreton, Int traditionValue)
    Spell wantSpell = None
    PDV_DeityBase championSource = GetBretonChampionSource(isBreton, traditionValue)
    if championSource
        wantSpell = GetBretonPatronChampionBoon(championSource, traditionValue)
    endIf

    Bool hadWanted = wantSpell && LedgerRuntime.HasRewardSpell(playerRef, wantSpell)
    SyncBretonChampionBoonExclusive(playerRef, wantSpell)
    MaybeShowBretonChampionBoonPresentation(playerRef, wantSpell, hadWanted, traditionValue, championSource)
EndFunction

; Grants wantSpell and strips every other Breton champion boon. Stendarr/Y'ffre/
; Daedric reuse the former tradition-T3 records; the nine below are the authored
; per-deity copies. SyncRaceRewardSpell no-ops on a None property, so an unbuilt
; record is safe.
Function SyncBretonChampionBoonExclusive(Actor playerRef, Spell wantSpell)
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_KnightsRoad_T3, wantSpell == PDV_Bless_Breton_KnightsRoad_T3, "Breton Champion Stendarr")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_GreenWay_T3, wantSpell == PDV_Bless_Breton_GreenWay_T3, "Breton Champion Yffre")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_HiddenArt_T3, wantSpell == PDV_Bless_Breton_HiddenArt_T3, "Breton Champion HiddenArt")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Mara, wantSpell == PDV_Bless_Breton_Champion_Mara, "Breton Champion Mara")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Arkay, wantSpell == PDV_Bless_Breton_Champion_Arkay, "Breton Champion Arkay")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Akatosh, wantSpell == PDV_Bless_Breton_Champion_Akatosh, "Breton Champion Akatosh")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Julianos, wantSpell == PDV_Bless_Breton_Champion_Julianos, "Breton Champion Julianos")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Kynareth, wantSpell == PDV_Bless_Breton_Champion_Kynareth, "Breton Champion Kynareth")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Dibella, wantSpell == PDV_Bless_Breton_Champion_Dibella, "Breton Champion Dibella")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Zenithar, wantSpell == PDV_Bless_Breton_Champion_Zenithar, "Breton Champion Zenithar")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Talos, wantSpell == PDV_Bless_Breton_Champion_Talos, "Breton Champion Talos")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Breton_Champion_Magnus, wantSpell == PDV_Bless_Breton_Champion_Magnus, "Breton Champion Magnus")
EndFunction

; Maps an active Champion patron to their Breton champion boon. Stendarr and
; Y'ffre reuse the tradition capstones they always were; a Daedric Hidden Art
; patron gets the occult practitioner cap (the prince's own reward flows through
; the 20C pact); the rest get their authored per-deity copy.
Spell Function GetBretonPatronChampionBoon(PDV_DeityBase deity, Int traditionValue)
    if !deity
        return None
    endIf
    if deity == LedgerRuntime.PDV_Stendarr
        return PDV_Bless_Breton_KnightsRoad_T3
    elseIf deity == PDV_Yffre
        return PDV_Bless_Breton_GreenWay_T3
    elseIf deity == LedgerRuntime.PDV_Mara
        return PDV_Bless_Breton_Champion_Mara
    elseIf deity == LedgerRuntime.PDV_Arkay
        return PDV_Bless_Breton_Champion_Arkay
    elseIf deity == LedgerRuntime.PDV_Akatosh
        return PDV_Bless_Breton_Champion_Akatosh
    elseIf deity == LedgerRuntime.PDV_Julianos
        return PDV_Bless_Breton_Champion_Julianos
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return PDV_Bless_Breton_Champion_Kynareth
    elseIf deity == LedgerRuntime.PDV_Dibella
        return PDV_Bless_Breton_Champion_Dibella
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return PDV_Bless_Breton_Champion_Zenithar
    elseIf deity == PDV_Talos
        return PDV_Bless_Breton_Champion_Talos
    elseIf deity == PDV_Magnus
        return PDV_Bless_Breton_Champion_Magnus
    endIf

    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if path && traditionValue == BRETON_TRADITION_HIDDEN_ART
        return PDV_Bless_Breton_HiddenArt_T3
    endIf
    return None
EndFunction

String Function GetBretonChampionBoonDisplayName(PDV_DeityBase deity)
    if deity == LedgerRuntime.PDV_Stendarr
        return "Knight's Bulwark - Champion"
    elseIf deity == PDV_Yffre
        return "Green Way - Champion"
    elseIf deity == LedgerRuntime.PDV_Mara
        return "Mara's Compassion - Champion"
    elseIf deity == LedgerRuntime.PDV_Arkay
        return "Arkay's Ward - Champion"
    elseIf deity == LedgerRuntime.PDV_Akatosh
        return "Akatosh's Endurance - Champion"
    elseIf deity == LedgerRuntime.PDV_Julianos
        return "Julianos's Insight - Champion"
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return "Kynareth's Sky - Champion"
    elseIf deity == LedgerRuntime.PDV_Dibella
        return "Dibella's Inspiration - Champion"
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return "Zenithar's Prosperity - Champion"
    elseIf deity == PDV_Talos
        return "Talos's Triumph - Champion"
    elseIf deity == PDV_Magnus
        return "Magnus's Aperture - Champion"
    endIf

    if deity as PDV_DaedricPathBase
        return "Hidden Art - Champion"
    endIf
    return "Champion blessing"
EndFunction

Function MaybeShowBretonChampionBoonPresentation(Actor playerRef, Spell wantSpell, Bool hadWanted, Int traditionValue, PDV_DeityBase championSource)
    if IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !wantSpell || !championSource || !playerRef.HasSpell(wantSpell)
        return
    endIf

    ; The Prince milestone path already owns its toast and Book entry. Hidden Art's
    ; practitioner capstone is an additional reward, not a second tier announcement.
    if championSource as PDV_DaedricPathBase
        return
    endIf

    String deityName = GetPublicDeityDisplayName(championSource)
    String shownKey = "PDV.Breton.ChampionBoonNoticeShown." + deityName
    if hadWanted && StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    String traditionLabel = GetBretonTraditionLabel()
    String symbolName = GetPrismaSymbolForDeity(championSource)
    String titleText = deityName + " names you Champion"
    String line = deityName + " names you Champion."
    if IsBretonResonantPatronChampion(traditionValue)
        line = deityName + " names you Champion through the " + traditionLabel + "."
    endIf
    if LedgerRuntime.NotifyTierUp(championSource, LedgerRuntime.TIER_CHAMPION)
        Trace(2, "Breton champion boon marked generic tier guard: " + deityName)
    endIf
    SendPrismaToast(symbolName, "good", titleText, line)
    AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, True, LedgerRuntime.TIER_CHAMPION, titleText)
    Trace(1, "Breton champion boon presentation shown: " + deityName + " / " + traditionLabel)
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
    String titleText = displayLabel + " deepens"
    String line = "The " + displayLabel + " names you " + tierLabel + "."
    if tierValue >= LedgerRuntime.TIER_CHAMPION && deity
        String deityName = GetPublicDeityDisplayName(deity)
        titleText = deityName + " names you " + tierLabel
        line = deityName + " names you " + tierLabel + " through the " + displayLabel + "."
        if LedgerRuntime.NotifyTierUp(deity, tierValue)
            Trace(2, "Breton focused Champion marked generic tier guard: " + deity.DeityName)
        endIf
    endIf
    SendPrismaToast(symbolName, "good", titleText, line)
    AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, tierValue >= LedgerRuntime.TIER_CHAMPION, tierValue, titleText)
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

; Breton two-axis model: tradition practice earns T1/T2 by count; an active
; Champion patron only lifts the tradition to T3 if that patron resonates with
; the chosen tradition. Non-resonant Champion patrons grant PatronChampion.
; Unified model (2026-07-13): the tradition tier is the PRACTICE tier and caps at
; Devoted (T2). Champion is a patron property (SyncBretonChampionBoon), no longer
; a tradition tier, so the old resonant->CHAMPION shortcut is gone.
Int Function GetBretonTraditionTier(Int traditionValue)
    return GetBretonPracticeTier(traditionValue)
EndFunction

Int Function GetBretonPracticeTier(Int traditionValue)
    Int practiceCount = GetBretonPracticeCount(traditionValue)
    if practiceCount >= BRETON_PRACTICE_DEVOTED_POINTS
        return LedgerRuntime.TIER_DEVOTED
    elseIf practiceCount >= BRETON_PRACTICE_SEEKER_POINTS
        return LedgerRuntime.TIER_SEEKER
    endIf
    return LedgerRuntime.TIER_NONE
EndFunction

Int Function GetBretonPracticeCount(Int traditionValue)
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        return StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount")
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        return StorageUtil.GetIntValue(None, "PDV.Breton.HiddenArtCount")
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount")
    endIf
    return 0
EndFunction

Function SetBretonPracticeCount(Int traditionValue, Int practicePoints)
    Int normalizedPoints = PDV_DevotionRules.ClampInt(practicePoints, 0, BRETON_PRACTICE_DEVOTED_POINTS)
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowCount", normalizedPoints)
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        StorageUtil.SetIntValue(None, "PDV.Breton.HiddenArtCount", normalizedPoints)
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        StorageUtil.SetIntValue(None, "PDV.Breton.GreenWayCount", normalizedPoints)
    endIf
EndFunction

Bool Function IsBretonResonantPatronChampion(Int traditionValue)
    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE || !_activeDeity
        return False
    endIf
    if LedgerRuntime.GetTier(_activeDeity) < LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    return IsDeityResonantWithBretonTradition(traditionValue, _activeDeity)
EndFunction

Bool Function IsBretonNonResonantPatronChampion(Int traditionValue)
    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE || !_activeDeity
        return False
    endIf
    if LedgerRuntime.GetTier(_activeDeity) < LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    return !IsDeityResonantWithBretonTradition(traditionValue, _activeDeity)
EndFunction

Bool Function IsDeityResonantWithBretonTradition(Int traditionValue, PDV_DeityBase deity)
    if !deity
        return False
    endIf
    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        return deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Akatosh || deity == PDV_Talos || deity == LedgerRuntime.PDV_Kynareth
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        return deity == PDV_Yffre || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Kynareth || deity == LedgerRuntime.PDV_Dibella
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
        if path
            return True
        endIf
        return deity == PDV_Magnus || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Dibella
    endIf
    return False
EndFunction

PDV_DeityBase Function GetBretonTraditionPresentationDeity(Int traditionValue)
    if IsBretonResonantPatronChampion(traditionValue)
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
        return LedgerRuntime.PDV_Stendarr
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
    Int normalized = PDV_DevotionRules.ClampInt(forkValue, BRETON_DRUIDIC_FORK_NONE, BRETON_DRUIDIC_FORK_BETRAYED)
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
    Bool broadReclamationFaithful = isDunmer && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") >= 6
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Dunmer_Reclamation_T2, broadReclamationFaithful, "Dunmer Reclamation T2")

    SyncDunmerRewardFamily(playerRef, PDV_Azura, PDV_Bless_Dunmer_Azura_T1, PDV_Bless_Dunmer_Azura_T2, PDV_Bless_Dunmer_Azura_T3, "Azura")
    SyncDunmerRewardFamily(playerRef, PDV_Boethiah, PDV_Bless_Dunmer_Boethiah_T1, PDV_Bless_Dunmer_Boethiah_T2, PDV_Bless_Dunmer_Boethiah_T3, "Boethiah")
    SyncDunmerRewardFamily(playerRef, PDV_Mephala, PDV_Bless_Dunmer_Mephala_T1, PDV_Bless_Dunmer_Mephala_T2, PDV_Bless_Dunmer_Mephala_T3, "Mephala")
EndFunction

Function SyncDunmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_DUNMER && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= LedgerRuntime.TIER_CHAMPION
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == LedgerRuntime.TIER_SEEKER, "Dunmer " + label + " T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == LedgerRuntime.TIER_DEVOTED, "Dunmer " + label + " T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Dunmer " + label + " T3")
    LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Dunmer " + label)
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

    Bool broadFaithful = isOrc && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") >= 6
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Malacath_T2, broadFaithful, "Orc Malacath T2")

    Bool focusActive = isOrc && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity == PDV_Malacath && PDV_Malacath
    Int activeTier = LedgerRuntime.TIER_NONE
    if focusActive
        activeTier = LedgerRuntime.GetTier(PDV_Malacath)
    endIf

    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_STRONGHOLD, activeMode, activeTier, focusActive, PDV_Bless_Orc_Stronghold_T1, PDV_Bless_Orc_Stronghold_T2, PDV_Bless_Orc_Stronghold_T3, "Stronghold")
    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_CITY, activeMode, activeTier, focusActive, PDV_Bless_Orc_City_T1, PDV_Bless_Orc_City_T2, PDV_Bless_Orc_City_T3, "City")
    SyncOrcRewardFamily(playerRef, ORC_LIFE_MODE_LEGION_EXILE, activeMode, activeTier, focusActive, PDV_Bless_Orc_LegionExile_T1, PDV_Bless_Orc_LegionExile_T2, PDV_Bless_Orc_LegionExile_T3, "LegionExile")
EndFunction

Function SyncOrcSpineBoon(Actor playerRef, Bool isOrc, Int activeMode)
    if !playerRef
        return
    endIf

    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_City, isOrc && activeMode == ORC_LIFE_MODE_CITY, "Orc Spine City")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_Stronghold, isOrc && activeMode == ORC_LIFE_MODE_STRONGHOLD, "Orc Spine Stronghold")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Orc_Spine_LegionExile, isOrc && activeMode == ORC_LIFE_MODE_LEGION_EXILE, "Orc Spine LegionExile")
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
    Bool hadChampionSpell = LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= LedgerRuntime.TIER_CHAMPION
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == LedgerRuntime.TIER_SEEKER, "Orc " + label + " T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == LedgerRuntime.TIER_DEVOTED, "Orc " + label + " T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Orc " + label + " T3")
    LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, PDV_Malacath, "Orc " + label)
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
    ; Option 2 (2026-07-16): the generic ancestor FLOOR (AncestorSpine_T1, "Ancestors' Regard -
    ; Observant") is descoped -- the sect spine (SyncRedguardSpineBoon) is the always-on ancestor
    ; layer. Broad progression is KEPT (owner ruling 2026-07-16): AncestorSpine_T2 remains the
    ; broad-worship Faithful reward, so a broad Redguard at 6+ ancestor-spine sources gains
    ; "Ancestors' Regard - Faithful" on top of the sect spine. Focused patrons stay broad-state gated
    ; out of T2, so they carry only their sect spine.
    Bool broadFaithful = isRedguard && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") >= 6
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_AncestorSpine_T2, broadFaithful, "Redguard AncestorSpine T2")

    SyncRedguardRewardFamily(playerRef, PDV_Tuwhacca, PDV_Bless_Redguard_Tuwhacca_T1, PDV_Bless_Redguard_Tuwhacca_T2, PDV_Bless_Redguard_Tuwhacca_T3, "Tuwhacca")
    SyncRedguardRewardFamily(playerRef, PDV_HoonDing, PDV_Bless_Redguard_HoonDing_T1, PDV_Bless_Redguard_HoonDing_T2, PDV_Bless_Redguard_HoonDing_T3, "HoonDing")
    SyncRedguardRewardFamily(playerRef, PDV_Leki, PDV_Bless_Redguard_Leki_T1, PDV_Bless_Redguard_Leki_T2, PDV_Bless_Redguard_Leki_T3, "Leki")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_FarShoresToken, isRedguard && StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken") > 0.0, "Redguard Far Shores Token")
    if isRedguard && PDV_RedguardSectTrack
        MaybeShowRedguardChampionEntry(PDV_RedguardSectTrack.GetCurrentState())
    endIf
EndFunction

Function SyncRedguardSpineBoon(Actor playerRef, Bool isRedguard, Int sectValue)
    if !playerRef
        return
    endIf

    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Crown, isRedguard && sectValue == REDGUARD_SECT_CROWN, "Redguard Spine Crown")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_Forebear, isRedguard && sectValue == REDGUARD_SECT_FOREBEAR, "Redguard Spine Forebear")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, PDV_Bless_Redguard_Spine_AshAbah, isRedguard && sectValue == REDGUARD_SECT_ASHABAH, "Redguard Spine AshAbah")
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
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_REDGUARD && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity == deity
    Int activeTier = LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= LedgerRuntime.TIER_CHAMPION
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == LedgerRuntime.TIER_SEEKER, "Redguard " + label + " T1")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == LedgerRuntime.TIER_DEVOTED, "Redguard " + label + " T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Redguard " + label + " T3")
    LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Redguard " + label)
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
        ; Pass 5 rubric sweep (carried from Pass 2). This asked the engine the same
        ; question twice in consecutive lines -- wasActive was computed and then the very
        ; next line re-ran HasSpell on the same spell and the same actor. Reuse the answer.
        Bool wasActive = playerRef.HasSpell(PDV_SPEL_Neglect_Redguard)
        if !wasActive
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

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT, None, multiplier)
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

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE, None, multiplier)
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

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Malacath, PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN, None, multiplier)
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

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SECRET_BETRAYED, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.SecretBetrayedCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastSecretBetrayedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastSecretBetrayedTime", Utility.GetCurrentGameTime())
    Trace(2, "Mephala secret-betrayed routed: " + reason + " multiplier=" + multiplier)
EndFunction

; Hist creed-violation minuses (curated medium/major only, per PDV_Deity_Hist), keyed to
; the substrate posture model: drifting Distant past grace is abandonment; domination-
; driven Corrupted posture is corruption; deep Void leaning (>=3 signals) while Hist has
; lapsed below the non-curse floor is Void overreach. Argonian-gated, anti-farmed.



Function SyncNordRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    EnsureNordOrkeyRewardRuntimeWiring()

    Bool isNord = GetPlayerOriginRaceIndex() == ORIGIN_NORD
    Int baselineState = GetNordPantheonBaselineState()
    SyncNordAncestorSubstrate(playerRef, isNord)
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Kyne, PDV_Bless_Nord_Kyne_T1, PDV_Bless_Nord_Kyne_T2, PDV_Bless_Nord_Kyne_T3, "Kyne")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Shor, PDV_Bless_Nord_Shor_T1, PDV_Bless_Nord_Shor_T2, PDV_Bless_Nord_Shor_T3, "Shor")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Tsun, PDV_Bless_Nord_Tsun_T1, PDV_Bless_Nord_Tsun_T2, PDV_Bless_Nord_Tsun_T3, "Tsun")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, PDV_Stuhn, PDV_Bless_Nord_Stuhn_T1, PDV_Bless_Nord_Stuhn_T2, PDV_Bless_Nord_Stuhn_T3, "Stuhn")
    SyncNordRewardFamily(playerRef, -1, PDV_Talos, PDV_Bless_Nord_Talos_T1, PDV_Bless_Nord_Talos_T2, PDV_Bless_Nord_Talos_T3, "Talos")

    ; Nord Nine Divines gods have no Nord-specific reward records (never authored); reuse the
    ; existing Imperial Divine reward spells (the canonical Nine Divines rewards), identical to
    ; the Mara fix. Owner ruling 2026-06-27. NOTE: Akatosh/Julianos/Kynareth Imperial rewards are
    ; regen-rate (~0 under Requiem) -- a pre-existing Imperial reward-feel gap to convert later.
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    ; Mara is focusable in BOTH lanes (Old Ways + Nine Divines), like Talos -- baseline -1.
    ; No Nord-specific Mara reward records exist, so reuse the Imperial Mara spells -- this IS
    ; the Nine Divines Mara reward (Restoration +5/+13/+23 + wake-mended), identical across lanes.
    SyncNordRewardFamily(playerRef, -1, LedgerRuntime.PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, "Mara")
    ; Arkay is focusable in BOTH lanes. Old Ways names him Orkey and uses
    ; Orkey-facing Nord reward records so Active Effects do not surface Arkay.
    ; Nine Divines keeps the existing Imperial Arkay rewards.
    SyncNordRewardFamily(playerRef, NORD_BASELINE_OLD_WAYS, LedgerRuntime.PDV_Arkay, PDV_Bless_Nord_Arkay_T1, PDV_Bless_Nord_Arkay_T2, PDV_Bless_Nord_Arkay_T3, "Orkey")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Arkay, PDV_Bless_Imperial_Arkay_T1, PDV_Bless_Imperial_Arkay_T2, PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Stendarr, PDV_Bless_Imperial_Stendarr_T1, PDV_Bless_Imperial_Stendarr_T2, PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Zenithar, PDV_Bless_Imperial_Zenithar_T1, PDV_Bless_Imperial_Zenithar_T2, PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    ; Dibella is focusable in BOTH lanes (owner directive 2026-07-05), like Mara --
    ; baseline -1, same Imperial reward reuse either way.
    SyncNordRewardFamily(playerRef, -1, LedgerRuntime.PDV_Dibella, PDV_Bless_Imperial_Dibella_T1, PDV_Bless_Imperial_Dibella_T2, PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Julianos, PDV_Bless_Imperial_Julianos_T1, PDV_Bless_Imperial_Julianos_T2, PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, LedgerRuntime.PDV_Kynareth, PDV_Bless_Imperial_Kynareth_T1, PDV_Bless_Imperial_Kynareth_T2, PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
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
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_NORD && baselineOk && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity == deity
    Float activePiety = 0.0
    if isActive && deity
        activePiety = LedgerRuntime.GetPiety(deity)
    endIf
    Bool hadChampionSpell = LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activePiety >= 85.0
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, False, "Nord " + label + " T1 compatibility")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activePiety >= 50.0 && activePiety < 85.0, "Nord " + label + " T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Nord " + label + " T3")
    LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Nord " + label)
EndFunction

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


Function SyncImperialRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isImperial = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL
    SyncImperialAncestorSubstrate(playerRef, isImperial)
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

    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, "Mara")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Arkay, PDV_Bless_Imperial_Arkay_T1, PDV_Bless_Imperial_Arkay_T2, PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Stendarr, PDV_Bless_Imperial_Stendarr_T1, PDV_Bless_Imperial_Stendarr_T2, PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Zenithar, PDV_Bless_Imperial_Zenithar_T1, PDV_Bless_Imperial_Zenithar_T2, PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Dibella, PDV_Bless_Imperial_Dibella_T1, PDV_Bless_Imperial_Dibella_T2, PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Julianos, PDV_Bless_Imperial_Julianos_T1, PDV_Bless_Imperial_Julianos_T2, PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncImperialRewardFamily(playerRef, LedgerRuntime.PDV_Kynareth, PDV_Bless_Imperial_Kynareth_T1, PDV_Bless_Imperial_Kynareth_T2, PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
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
    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity == deity && !IsImperialVampireStateActive()
    Float activePiety = 0.0
    if isActive && deity
        activePiety = LedgerRuntime.GetPiety(deity)
    endIf
    Bool hadChampionSpell = LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activePiety >= 85.0
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, False, "Imperial " + label + " T1 compatibility")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activePiety >= 50.0 && activePiety < 85.0, "Imperial " + label + " T2")
    LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Imperial " + label + " T3")
    LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Imperial " + label)
EndFunction

Bool Function IsImperialCivicNeglected()
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        return False
    endIf

    if !PDV_ImperialAncestorSubstrate || PDV_ImperialAncestorSubstrate.GetMetric() <= 0.0
        return False
    endIf

    Float lastSource = PDV_ImperialAncestorSubstrate.GetLastAcceptedTime()
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


; Broad-worship floor eligibility: the origin's first-tier reward also grants to a BROAD
; worshipper, not only an active patron. Mirrors the active path's "earned Seeker before the
; floor" by gating on the same accumulated-service count the Faithful (T2) reward uses;
; Seeker-equivalent = 3 acts (half the Faithful gate of 6). Nord's broad T1 is part of this
; shared floor helper too; the old runtime excluded it by mistake even though the reward spec
; and manager property already expose PDV_Bless_Nord_OldWays_T1 as the broad first tier.
Bool Function IsBroadFloorEligible()
    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_BROAD
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


Float Function GetBroadLaneStandingValue(Int origin)
    if origin == ORIGIN_IMPERIAL || origin == ORIGIN_NORD
        return LedgerRuntime.GetBroadPantheonStanding(LedgerRuntime.GetActiveBroadPantheonPoolId())
    endIf
    return GetBroadLaneServiceCount(origin) as Float
EndFunction

Float Function GetBroadLaneScratchValue(Int origin)
    if origin == ORIGIN_IMPERIAL || origin == ORIGIN_NORD
        return LedgerRuntime.GetBroadPantheonScratch(LedgerRuntime.GetActiveBroadPantheonPoolId())
    endIf
    return 0.0
EndFunction

Int Function GetBroadLaneServiceCount(Int origin)
    if origin == ORIGIN_IMPERIAL
        return LedgerRuntime.GetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_IMPERIAL) as Int
    elseIf origin == ORIGIN_BRETON
        return GetBretonPracticeCount(GetBretonTraditionValue())
    elseIf origin == ORIGIN_ORC
        return StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount")
    elseIf origin == ORIGIN_ALTMER
        return StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count") + StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count")
    elseIf origin == ORIGIN_NORD
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return LedgerRuntime.GetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_NORD_NINE) as Int
        endIf
        return LedgerRuntime.GetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_NORD_OLD) as Int
    elseIf origin == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerFavorSignalCount()
    elseIf origin == ORIGIN_DUNMER
        return StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount")
    elseIf origin == ORIGIN_REDGUARD
        return StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount")
    endIf
    return 0
EndFunction

Int Function GetBroadLaneTierForOrigin(Int origin)
    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_BROAD || !HasBroadLanePresentation(origin)
        return LedgerRuntime.TIER_NONE
    endIf

    Int count = GetBroadLaneServiceCount(origin)
    if origin == ORIGIN_IMPERIAL || origin == ORIGIN_NORD
        Float standing = GetBroadLaneStandingValue(origin)
        if standing >= LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD
            return LedgerRuntime.TIER_DEVOTED
        elseIf standing >= LedgerRuntime.BROAD_PANTHEON_SEEKER_THRESHOLD
            return LedgerRuntime.TIER_SEEKER
        endIf
        return LedgerRuntime.TIER_NONE
    elseIf count >= 6
        return LedgerRuntime.TIER_DEVOTED
    elseIf count >= 3
        return LedgerRuntime.TIER_SEEKER
    endIf
    return LedgerRuntime.TIER_NONE
EndFunction

String Function GetBroadLaneDisplayName(Int origin)
    if origin == ORIGIN_IMPERIAL
        return "The Divines' Regard"
    elseIf origin == ORIGIN_ALTMER
        return "Orthodox Faith"
    elseIf origin == ORIGIN_BOSMER
        return "Y'ffre's Broad Faith"
    elseIf origin == ORIGIN_BRETON
        return "Breton Tradition"
    elseIf origin == ORIGIN_DUNMER
        return "Reclamation Communion"
    elseIf origin == ORIGIN_NORD
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return "Faith of the Holds"
        endIf
        return "Old Ways"
    elseIf origin == ORIGIN_ORC
        return "Malacath's Code"
    elseIf origin == ORIGIN_REDGUARD
        return "Ancestors' Regard"
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
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return "akatosh"
        endIf
        return "kyne"
    elseIf origin == ORIGIN_ORC
        return "malacath"
    elseIf origin == ORIGIN_REDGUARD
        return "tu-whacca"
    endIf
    return "journal"
EndFunction

String Function GetBroadLaneStandingLabel(Int origin, Int tier)
    if tier >= LedgerRuntime.TIER_DEVOTED
        return "Faithful"
    elseIf tier >= LedgerRuntime.TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
EndFunction

String Function GetBroadLaneNextThresholdText(Int origin)
    Int count = GetBroadLaneServiceCount(origin)
    if origin == ORIGIN_IMPERIAL || origin == ORIGIN_NORD
        Float standing = GetBroadLaneStandingValue(origin)
        if standing < LedgerRuntime.BROAD_PANTHEON_SEEKER_THRESHOLD
            return "Observant at 25 pantheon standing"
        elseIf standing < LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD
            return "Faithful at 50 pantheon standing"
        endIf
        return "Pantheon standing cap reached"
    endIf
    if origin == ORIGIN_BRETON
        if count < BRETON_PRACTICE_SEEKER_POINTS
            return "Observant at 25 practice points"
        elseIf count < BRETON_PRACTICE_DEVOTED_POINTS
            return "Faithful at 50 practice points"
        endIf
        return "Practice cap reached"
    endIf
    if count < 3
        return "Observant at 3 broad acts"
    elseIf count < 6
        return "Faithful at 6 broad acts"
    endIf
    return "Broad lane cap reached"
EndFunction




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
    RemoveRedguardRememberSpells(playerRef)
    ; Same defect class, found while fixing B16: the Daedric pact boon + price spells
    ; are properties on the PDV_DaedricPath_* scripts, not on this manager, so the
    ; strip above could never reach them. Malacath's price is SpeedMult -- an
    ; uninstalled long-pact Orc stayed permanently slower.
    StripAllDaedricPactSpells()
EndFunction

; Clear every Daedric path's boon + price spells. StripPactSpells is the path base's
; own remover (ClearAllBoons + ClearPriceSpells), already used by the pact migration.
Function StripAllDaedricPactSpells()
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path
            path.StripPactSpells()
        endIf
        i += 1
    endWhile
EndFunction
















Int Function GetNordPantheonBaselineState()
    Int stateValue = StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState", NORD_BASELINE_OLD_WAYS)
    if PDV_NordPantheonBaselineTrack
        stateValue = PDV_NordPantheonBaselineTrack.GetCurrentState()
        StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", stateValue)
    endIf

    return stateValue
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

    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE || _activeDeity != PDV_Talos
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

    ; fix-plan 4.2: one betrayal charge per devotional day.
    String dayKey = "PDV.Creed." + reason + ".Day"
    if LedgerRuntime.ReadZeroReservedDevotionalDayStamp(dayKey) == (LedgerRuntime.GetDevotionalDay() + 2)
        Trace(2, "Talos betrayal suppressed for " + reason + ": already applied today.")
        return False
    endIf

    LedgerRuntime.WriteZeroReservedDevotionalDayStamp(dayKey)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalSource", sourceReason)

    LedgerRuntime.AwardPiety(PDV_Talos, pietyLoss, reason)
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
    HandleGreenPactViolation("mcm")
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
    HandleStateTransitionConfirmationRite("mcm")
EndFunction

Function DebugRecordDunmerAncestorPrayer()
    HandleDunmerPortableShrinePrayer("mcm")
EndFunction

Function DebugRecordDunmerAncestorHomeBonus()
    HandleDunmerPlayerHomeBonus("mcm")
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
    HandleMephalaWebWoven("mcm")
EndFunction

Function DebugRecordBoethiahHonorableDuel()
    HandleBoethiahHonorableDuel("mcm")
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
    HandleTalosShrineDefiance("mcm")
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
    if pending && !IsNordOfferEligibleDeity(pending)
        LedgerRuntime.ClearPendingCommitment()
    endIf
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity && !IsNordOfferEligibleDeity(_activeDeity)
        LedgerRuntime.SetBroadWorship()
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
EndFunction

PDV_SubstrateBase Function GetSubstrateForPacingOrigin(Int originValue)
    if originValue == ORIGIN_IMPERIAL
        return PDV_ImperialAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == ORIGIN_DUNMER
        return PDV_DunmerAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == ORIGIN_ARGONIAN
        return PDV_ArgonianHistSubstrate as PDV_SubstrateBase
    elseIf originValue == ORIGIN_NORD
        return PDV_NordAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == ORIGIN_ALTMER
        return PDV_AltmerAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == ORIGIN_KHAJIIT
        return PDV_KhajiitLunarSubstrate as PDV_SubstrateBase
    endIf
    return None
EndFunction

String Function DebugGetSubstratePacingSummary(Int originValue)
    PDV_SubstrateBase substrate = GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No active pacing substrate is wired for origin " + originValue + "."
    endIf
    String summary = "metric=" + substrate.GetMetric() + " tier=" + substrate.GetSubstrateTier() + " day=" + substrate.GetDevotionalDay() + " encodedStamp=" + substrate.GetEncodedDailyCreditStamp() + " spent=" + substrate.IsDailyCreditSpent() + " accepted=" + substrate.GetLastAcceptedSource() + " acceptedEvent=" + substrate.GetLastAcceptedLogicalEvent() + " rejected=" + substrate.GetLastRejectedSource() + " rejectedEvent=" + substrate.GetLastRejectedLogicalEvent() + " rejectReason=" + substrate.GetLastCreditRejectReason() + " decay=" + GetSubstrateDecaySummary(originValue)
    if originValue == ORIGIN_KHAJIIT
        summary = summary + " moonReject=" + StorageUtil.GetStringValue(None, "PDV.Khajiit.MoonRite.LastReject")
    endIf
    return summary
EndFunction

String Function GetSubstrateDecaySummary(Int originValue)
    if originValue == ORIGIN_DUNMER || originValue == ORIGIN_KHAJIIT
        return "none"
    elseIf originValue == ORIGIN_IMPERIAL || originValue == ORIGIN_ARGONIAN || originValue == ORIGIN_NORD || originValue == ORIGIN_ALTMER
        return "3-day grace, -1/dawn, floor 20 (curse floor 0)"
    endIf
    return "n/a"
EndFunction

String Function DebugTriggerSubstratePacingSource(Int originValue, Int sourceIndex = 0)
    if originValue == ORIGIN_IMPERIAL
        if sourceIndex == 0
            HandleImperialCivicService("mcm_debug_public_service")
        elseIf sourceIndex == 1
            LedgerRuntime.HandleSubstrateShrinePrayer("Mara", "", "", "mcm_debug_divine_prayer")
        else
            HandleImperialSleepEvents(Game.GetPlayer(), "mcm_debug_rejected_sleep")
            if PDV_ImperialAncestorSubstrate
                PDV_ImperialAncestorSubstrate.RecordDailyCreditReject("imperial_sleep", "mcm_debug_rejected_sleep", "retired_route")
            endIf
        endIf
    elseIf originValue == ORIGIN_DUNMER
        if sourceIndex == 0
            HandleDunmerPortableShrinePrayer("mcm_debug_portable_prayer")
        elseIf sourceIndex == 1
            HandleDunmerReclamationFocus(1, "mcm_debug_reclamation_book")
        else
            HandleDunmerPlayerHomeBonus("mcm_debug_rejected_home_only")
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
            if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
                HandleNordOldWaysState("mcm_debug_nine_road_grace")
            else
                HandleNordOldWaysState("mcm_debug_sky_road")
            endIf
        elseIf sourceIndex == 1 && PDV_NordAncestorSubstrate
            HandleSubstrateActionEvent(313, "mcm_debug_open_sky_rest")
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
    PDV_SubstrateBase substrate = GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    ResetSubstratePacingState(originValue)
    substrate.DebugSetMetric(PDV_DevotionRules.ClampValue(metricValue, 0.0, 75.0))
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

String Function DebugResetSubstratePacing(Int originValue)
    PDV_SubstrateBase substrate = GetSubstrateForPacingOrigin(originValue)
    if !substrate
        return "No substrate is wired."
    endIf
    ResetSubstratePacingState(originValue)
    return DebugGetSubstratePacingSummary(originValue)
EndFunction

Function ResetSubstratePacingState(Int originValue)
    if originValue == ORIGIN_IMPERIAL && PDV_ImperialAncestorSubstrate
        PDV_ImperialAncestorSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ImperialCivicService")
    elseIf originValue == ORIGIN_DUNMER && PDV_DunmerAncestorSubstrate
        PDV_DunmerAncestorSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.DunmerPortableShrinePrayer")
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.DunmerHomeBonus")
    elseIf originValue == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        PDV_ArgonianHistSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianHistMaintenance")
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianPeopleSupport")
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianBedOfChoice")
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianVoidSignal")
    elseIf originValue == ORIGIN_NORD && PDV_NordAncestorSubstrate
        PDV_NordAncestorSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.NordAncestorSpine")
        StorageUtil.SetIntValue(None, "PDV.Signal.NordAncestralRest.Day", -1)
    elseIf originValue == ORIGIN_ALTMER && PDV_AltmerAncestorSubstrate
        PDV_AltmerAncestorSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.AltmerAncestorSpine")
    elseIf originValue == ORIGIN_KHAJIIT && PDV_KhajiitLunarSubstrate
        PDV_KhajiitLunarSubstrate.ResetPilotForDebug()
        LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.KhajiitRoadHome")
        StorageUtil.SetIntValue(None, "PDV.Khajiit.RoadHome.PresentationDay", 0)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.RoadHome.PresentationDay.Encoding", 2)
    endIf
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
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_breton_tradition")
        if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0) < 50
            StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        endIf
    else
        SetBretonDruidicFork(BRETON_DRUIDIC_FORK_NONE, "mcm_breton_tradition")
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
    SetBretonDruidicFork(BRETON_DRUIDIC_FORK_DRUIDIC, "mcm_fray_test")
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
        LedgerRuntime.HandleCurseStateTransition(oldState, appliedState, reason)
    elseIf PDV_HircinePath
        PDV_HircinePath.UpdateResidueRecovery()
        DrainHircineResiduePrismaToasts()
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
    OriginRuntime.EnsureKhajiitObserveMoonsPower()
    RequestPanelRefresh()
    Trace(1, "Curse proof origin set to " + GetOriginRaceLabel(originRace) + " (" + originRace + ")")
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
    Trace(1, "Commitment seed debug: " + deity.DeityName + "[" + deity.DeityIndex + "] days=" + LedgerRuntime.GetRecentCommitmentSignalDayCount(deity, 7))
EndFunction

; Form-based twin of DebugSeedCommitmentSignalDaysByIndex. Daedric-path indices do not
; resolve through GetDeityByIndex, so the index seeder misses a Prince; seed by form
; directly to make a path offer-ready.
Function DebugSeedCommitmentSignalDaysForDeity(PDV_DeityBase deity)
    if !deity
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

Function EvaluateKyneCommitmentOffer()
    LedgerRuntime.EvaluateFormalCommitmentOffer()
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

Message Function GetNordFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == PDV_Kyne
        return PDV_Msg_Nord_Kyne_Offer
    elseIf deity == PDV_Shor
        return PDV_Msg_Nord_Shor_Offer
    elseIf deity == PDV_Tsun
        return PDV_Msg_Nord_Tsun_Offer
    elseIf deity == PDV_Stuhn
        return PDV_Msg_Nord_Stuhn_Offer
    elseIf deity == LedgerRuntime.PDV_Akatosh
        return PDV_Msg_Nord_Akatosh_Offer
    elseIf deity == LedgerRuntime.PDV_Mara
        return PDV_Msg_Nord_Mara_Offer
    elseIf deity == LedgerRuntime.PDV_Arkay
        if GetNordPantheonBaselineState() == NORD_BASELINE_OLD_WAYS
            return PDV_Msg_Nord_Orkey_Offer
        endIf
        return PDV_Msg_Nord_Arkay_Offer
    elseIf deity == LedgerRuntime.PDV_Stendarr
        return PDV_Msg_Nord_Stendarr_Offer
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return PDV_Msg_Nord_Zenithar_Offer
    elseIf deity == LedgerRuntime.PDV_Julianos
        return PDV_Msg_Nord_Julianos_Offer
    elseIf deity == LedgerRuntime.PDV_Dibella
        return PDV_Msg_Nord_Dibella_Offer
    elseIf deity == PDV_Talos
        return PDV_Msg_Nord_Talos_Offer
    elseIf deity == LedgerRuntime.PDV_Kynareth
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


Message Function GetBretonFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == LedgerRuntime.PDV_Stendarr
        return PDV_Msg_Breton_Stendarr_Offer
    elseIf deity == LedgerRuntime.PDV_Akatosh
        return PDV_Msg_Breton_Akatosh_Offer
    elseIf deity == LedgerRuntime.PDV_Mara
        return PDV_Msg_Breton_Mara_Offer
    elseIf deity == LedgerRuntime.PDV_Arkay
        return PDV_Msg_Breton_Arkay_Offer
    elseIf deity == LedgerRuntime.PDV_Julianos
        return PDV_Msg_Breton_Julianos_Offer
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return PDV_Msg_Breton_Zenithar_Offer
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return PDV_Msg_Breton_Kynareth_Offer
    elseIf deity == LedgerRuntime.PDV_Dibella
        return PDV_Msg_Breton_Dibella_Offer
    elseIf deity == PDV_Magnus
        return PDV_Msg_Breton_Magnus_Offer
    elseIf deity == PDV_Talos
        return PDV_Msg_Breton_Talos_Offer
    elseIf deity == PDV_Yffre
        return PDV_Msg_Breton_Yffre_Offer
    endIf

    return None
EndFunction

Message Function GetImperialFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == LedgerRuntime.PDV_Akatosh
        return PDV_Msg_Imperial_Akatosh_Offer
    elseIf deity == PDV_Talos && IsImperialTalosOfferAllowed()
        return PDV_Msg_Imperial_Talos_Offer
    elseIf deity == LedgerRuntime.PDV_Kynareth
        return PDV_Msg_Imperial_Kynareth_Offer
    elseIf deity == LedgerRuntime.PDV_Mara
        return PDV_Msg_Imperial_Mara_Offer
    elseIf deity == LedgerRuntime.PDV_Zenithar
        return PDV_Msg_Imperial_Zenithar_Offer
    elseIf deity == LedgerRuntime.PDV_Arkay
        return PDV_Msg_Imperial_Arkay_Offer
    elseIf deity == LedgerRuntime.PDV_Stendarr
        return PDV_Msg_Imperial_Stendarr_Offer
    elseIf deity == LedgerRuntime.PDV_Julianos
        return PDV_Msg_Imperial_Julianos_Offer
    elseIf deity == LedgerRuntime.PDV_Dibella
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




Bool Function IsKyneCommitmentSignalReady()
    if !PDV_Kyne
        return False
    endIf

    return LedgerRuntime.HasRecentCommitmentSignalDays(PDV_Kyne, 2, 7)
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
        return deity == PDV_Kyne || deity == PDV_Shor || deity == PDV_Tsun || deity == PDV_Stuhn || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Dibella
    elseIf baselineState == NORD_BASELINE_NINE_DIVINES
        return deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Zenithar || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Kynareth
    endIf

    return False
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


Bool Function IsBretonOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf

    return deity == LedgerRuntime.PDV_Kynareth || deity == PDV_Talos || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Zenithar || deity == PDV_Magnus || deity == PDV_Yffre || IsBretonHiddenArtDaedricOfferDeity(deity)
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

    return deity == LedgerRuntime.PDV_Akatosh || deity == LedgerRuntime.PDV_Mara || deity == LedgerRuntime.PDV_Arkay || deity == LedgerRuntime.PDV_Stendarr || deity == LedgerRuntime.PDV_Zenithar || deity == LedgerRuntime.PDV_Dibella || deity == LedgerRuntime.PDV_Julianos || deity == LedgerRuntime.PDV_Kynareth
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

Bool Function ShouldSuppressBretonFocusedChampionTierSurface(PDV_DeityBase deity, Int newTier)
    if newTier < LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf
    if LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE || !_activeDeity || deity != _activeDeity
        return False
    endIf

    return IsDeityResonantWithBretonTradition(GetBretonTraditionValue(), deity)
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
    PDV_DaedricPathBase sanguinePath = GetDaedricPathByName("Sanguine")
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
    PDV_DaedricPathBase sanguinePath = GetDaedricPathByName("Sanguine")
    if !sanguinePath
        return "Sanguine path is not available."
    endIf
    Int schema = StorageUtil.GetIntValue(None, "PDV.Daedric.ConsentSchema")
    return "Sanguine piety=" + PDV_DevotionRules.FormatTwoDecimals(sanguinePath.GetStoredPiety()) + " tier=" + sanguinePath.GetStoredTier() + "; consent=" + DebugYesNo(sanguinePath.HasDaedricPactConsent()) + "; activePact=" + DebugYesNo(sanguinePath.IsActiveDaedricPact()) + "; consentSchema=" + schema + " (target " + DAEDRIC_CONSENT_SCHEMA_VERSION + ")"
EndFunction

String Function DebugSeedSanguineOfferReady()
    if !GetDaedricPathByName("Sanguine")
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
    ; A divine patron must suppress the Daedric pact offer and survive the raise.
    LedgerRuntime.SetActiveDeity(LedgerRuntime.PDV_Akatosh, True)
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
    return "Divine patron=" + patronLabel + " (state " + LedgerRuntime.GetPatronStateLabel() + "); Sanguine raised to offer-ready; offer pending=" + pendingLabel + " (expect none -> suppressed)."
EndFunction

String Function DebugFireSanguineAlcoholTwice()
    PDV_DaedricPathBase sanguinePath = GetDaedricPathByName("Sanguine")
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
    PDV_DaedricPathBase sanguinePath = GetDaedricPathByName("Sanguine")
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













Bool Function IsCurseStateLoadReconciliation(String reason)
    return reason == "eventbus_Load" || reason == "eventbus_alias_init"
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
Bool Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String stateLabel, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"substrate\""
    j = j + ",\"substrate\":\"" + PDV_DevotionRules.JsonSafeString(substrate) + "\""
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if stateLabel != ""
        j = j + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(stateLabel) + "\""
    endIf
    j = j + "}}"
    String fallbackTitle = stateLabel
    if fallbackTitle == ""
        fallbackTitle = substrate
    endIf
    return SendPrismaToastPayloadOrFallback(j, fallbackTitle, context, allowFallback)
EndFunction

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
                SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
            else
                SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
            endIf
        endIf
        if tierAfter > tierBefore
            AppendBookOfDaysEntry(OriginRuntime.GetAltmerHeritageTierJournalLine(tierAfter), Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 2, "Ancestral inheritance deepens")
        endIf
        return
    endIf
    if surfacePresentation
        if tierAfter > tierBefore
            SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
        elseIf tierAfter < tierBefore
            SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)
        else
            SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
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

; Emit a "daedric" event for a Daedric Prince interaction.
; princeName = e.g. "Hircine", "Azura"
; phase      = "boon" | "price" | "lapse" | "residue" | "prayer"
; context    = optional short phrase
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Bool Function SendPrismaDaedricToast(String princeName, String phase, String context, String symbolName, Bool allowFallback = True)
    if phase == "price"
        PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
        if activePact && activePact.DeityName == princeName && activePact.ShouldWaivePriceForPlayer()
            Trace(2, "Daedric price toast suppressed for integrated Breton Hidden Art pact: " + princeName)
            return True
        endIf
    endIf

    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"prince\":\"" + PDV_DevotionRules.JsonSafeString(princeName) + "\""
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if phase == "boon"
        j = j + ",\"tone\":\"good\""
    endIf
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, princeName, context, allowFallback)
EndFunction

Bool Function ReplayConcreteDaedricChampionOffer(PDV_DaedricPathBase path, Int oldTier, Int newTier)
    if !path
        return False
    endIf

    Form pathForm = path.GetDeityForm()
    String princeName = path.DeityName
    if princeName == "Boethiah"
        PDV_DaedricPath_Boethiah concreteBoethiah = pathForm as PDV_DaedricPath_Boethiah
        if concreteBoethiah
            concreteBoethiah.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Azura"
        PDV_DaedricPath_Azura concreteAzura = pathForm as PDV_DaedricPath_Azura
        if concreteAzura
            concreteAzura.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Vaermina"
        PDV_DaedricPath_Vaermina concreteVaermina = pathForm as PDV_DaedricPath_Vaermina
        if concreteVaermina
            concreteVaermina.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Meridia"
        PDV_DaedricPath_Meridia concreteMeridia = pathForm as PDV_DaedricPath_Meridia
        if concreteMeridia
            concreteMeridia.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Molag Bal"
        PDV_DaedricPath_Molag concreteMolag = pathForm as PDV_DaedricPath_Molag
        if concreteMolag
            concreteMolag.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Mephala"
        PDV_DaedricPath_Mephala concreteMephala = pathForm as PDV_DaedricPath_Mephala
        if concreteMephala
            concreteMephala.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Malacath"
        PDV_DaedricPath_Malacath concreteMalacath = pathForm as PDV_DaedricPath_Malacath
        if concreteMalacath
            concreteMalacath.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Mehrunes Dagon"
        PDV_DaedricPath_Dagon concreteDagon = pathForm as PDV_DaedricPath_Dagon
        if concreteDagon
            concreteDagon.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Sheogorath"
        PDV_DaedricPath_Sheo concreteSheo = pathForm as PDV_DaedricPath_Sheo
        if concreteSheo
            concreteSheo.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Namira"
        PDV_DaedricPath_Namira concreteNamira = pathForm as PDV_DaedricPath_Namira
        if concreteNamira
            concreteNamira.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Sanguine"
        PDV_DaedricPath_Sanguine concreteSanguine = pathForm as PDV_DaedricPath_Sanguine
        if concreteSanguine
            concreteSanguine.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Clavicus Vile"
        PDV_DaedricPath_Vile concreteVile = pathForm as PDV_DaedricPath_Vile
        if concreteVile
            concreteVile.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Hermaeus Mora"
        PDV_DaedricPath_Mora concreteMora = pathForm as PDV_DaedricPath_Mora
        if concreteMora
            concreteMora.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Nocturnal"
        PDV_DaedricPath_Nocturnal concreteNocturnal = pathForm as PDV_DaedricPath_Nocturnal
        if concreteNocturnal
            concreteNocturnal.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Peryite"
        PDV_DaedricPath_Peryite concretePeryite = pathForm as PDV_DaedricPath_Peryite
        if concretePeryite
            concretePeryite.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Hircine"
        PDV_DaedricPath_Hircine concreteHircine = pathForm as PDV_DaedricPath_Hircine
        if concreteHircine
            concreteHircine.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    endIf

    Trace(1, "Daedric Champion offer replay failed to resolve concrete path: " + princeName)
    return False
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
    if !path || newTier <= LedgerRuntime.TIER_NONE
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
    if !path || newTier <= LedgerRuntime.TIER_NONE
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
    if currentTier <= LedgerRuntime.TIER_NONE
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
    if !path || newTier <= oldTier || newTier <= LedgerRuntime.TIER_NONE
        return
    endIf

    if replayChampionOffer && newTier == LedgerRuntime.TIER_CHAMPION
        if !ReplayConcreteDaedricChampionOffer(path, oldTier, newTier)
            return
        endIf
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        if path.GetStoredTier() < LedgerRuntime.TIER_CHAMPION
            if GetDebugLevel() >= 1
                Debug.Trace("[PDV] Daedric milestone presentation skipped after Champion decline: " + path.DeityName)
            endIf
            return
        endIf
    else
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf

    String princeName = path.DeityName
    String tierLabel = GetTierStandingLabel(newTier)
    String flavorText = GetDaedricMilestoneFlavor(princeName, newTier)
    String boonText = GetDaedricBoonMechanicText(princeName, newTier)
    String priceText = ""
    if !path.ShouldWaivePriceForPlayer()
        priceText = GetDaedricPriceMechanicText(princeName, newTier)
    endIf
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
    AppendBookOfDaysEntry(princeName + " names you " + tierLabel + ".", Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, newTier >= LedgerRuntime.TIER_CHAMPION)
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
    j = j + ",\"prince\":\"" + PDV_DevotionRules.JsonSafeString(princeName) + "\""
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    j = j + ",\"message\":\"" + PDV_DevotionRules.JsonSafeString(flavorText) + "\""
    j = j + ",\"duration\":9000"
    j = j + "}}"
    Bool sent = SendPrismaToastPayloadOrFallback(j, titleText, flavorText, allowFallback)
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone Prisma payload sent=" + sent + " prince=" + princeName + " tier=" + tierLabel)
    endIf
    return sent
EndFunction

; Contract-derived Daedric milestone copy. Source: PDV_DaedricPrinceRecordContracts.json.

String Function GetDaedricMilestoneFlavor(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Boethiah marks the seeker of trials."
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Boethiah's trial momentum is yours."
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Boethiah names you proven."
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Azura opens the threshold a little."
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Azura's twilight is yours."
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Azura names you her seer."
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Vaermina's touch opens the dream-path."
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Vaermina's nightmare deepens."
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Vaermina names you her nightmare-walker."
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Meridia's light stirs in you."
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Meridia's radiance is yours in full."
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Meridia names you her cleansing blade."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Molag Bal's domination-edge settles in you."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "The grip deepens."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "You carry the full weight of Molag Bal's domination."
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Mephala spins you a first thread."
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Mephala's web is yours to read."
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Mephala names you of the web."
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Malacath hardens the outcast."
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Malacath's endurance is yours."
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Malacath names you of the spurned-and-strong."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Dagon's edge settles in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Dagon's ruin deepens in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Dagon names you his ruin made walking."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Sheogorath's absurdity opens a crack."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Sheogorath's disruption deepens."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Sheogorath names you the Mad God's own."
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Namira's darkness settles around you."
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Namira's outcast fellowship deepens."
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Namira names you of the outcast faithful."
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Sanguine's ease settles in you."
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Sanguine's indulgence deepens."
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Sanguine names you his own."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Vile's transactional edge is yours."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Vile's contract deepens."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Vile names you his preferred client."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Mora's archive opens a corner."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Mora's collection deepens in you."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Mora names you archivist."
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Shadow luck covers you."
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Nocturnal's shade deepens."
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Nocturnal's debt runs in your favor."
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Peryite's resilience settles in you."
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Peryite's imposed order deepens."
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Peryite names you keeper of the lowest order."
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Hircine's hunt-sense is in you."
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "The hunt runs deeper now."
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "You see the whole arc of the hunt -- target, approach, kill, clean territory."
    endIf

    return "The pact has deepened."
EndFunction

String Function GetDaedricBoonMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 One-handed"
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Armor rating"
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35 Armor rating"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+15% Magic resistance"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35 Magicka"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Sneak"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Restoration"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25% Disease resistance"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35% Disease resistance"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Illusion"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Pickpocket"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Pickpocket"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+15 Armor rating"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Two-handed"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Two-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Destruction"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 One-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 One-handed"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35 Magicka"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_SEEKER
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+15 Stamina"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Speech"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Carry weight"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35 Carry weight"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Alteration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+20 Alteration; +20 Magicka"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Lockpicking"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Lockpicking"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+15% Disease resistance"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+25 Health"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+35 Health"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "+15 Stamina"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "+25 Sneak"
    endIf

    return "pact boon active"
EndFunction

String Function GetDaedricPriceMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Boethiah") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Azura") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Vaermina") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Illusion"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Illusion"
    elseIf (princeName == "Meridia") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Mephala") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-4% Movement speed"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-7% Movement speed"
    elseIf (princeName == "Malacath") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-10% Movement speed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Armor rating"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Namira") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Magicka"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Magicka"
    elseIf (princeName == "Sanguine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Magicka"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Peryite") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Hircine") && tierValue == LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    endIf

    return "pact price active"
EndFunction

; Map a Khajiit focus value to a Prisma symbol key.
; Glyphs for these fall back to journal until the Tier-1/2 design pass lands.


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




; Imperial vampire rupture: the Nine Divines path HALTS while undead (no civic piety
; accrues) and leaves a one-way history scar; cure lifts the halt but the scar remains.
Function ApplyImperialCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 1)
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHistory", 1)
        if PDV_ImperialAncestorSubstrate
            PDV_ImperialAncestorSubstrate.SetMetric(0.0, "vampire_onset")
            PDV_ImperialAncestorSubstrate.ClearSubstrateBoons()
        endIf
        StorageUtil.SetFloatValue(None, LedgerRuntime.GetBroadPantheonScratchKey(LedgerRuntime.BROAD_PANTHEON_IMPERIAL), 0.0)
        FavorRuntime.ClearActiveFavor("imperial_vampire")
    elseIf newState == 1
        ; Werewolf strains but does not halt the civic path the way undeath does.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    elseIf oldState == 2 && newState == 0
        ; Cured: the halt lifts, but VampireHistory stays set as the scar.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
        if PDV_ImperialAncestorSubstrate
            PDV_ImperialAncestorSubstrate.SetMetric(20.0, "vampire_cure_seed")
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    endIf
    LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    SyncImperialRewards(Game.GetPlayer())
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
            ShowRedguardMessage(PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry, "The thirst is gone, but the ancestors' protection stays withheld until you take up the death-duty and re-enter Tu'whacca's cycle.", suppressModal)
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
        FavorRuntime.ClearActiveFavor("nord_vampire")
        LedgerRuntime.ClearPendingCommitment()
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
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfFeedbackShown") != 1
            ShowNordMessage(PDV_Msg_Nord_CurseState_WerewolfOnset, "The hunt pulls against Sovngarde. Master the beast, or it will master you.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        ; oldState == 2 is claimed by the vampire-cure branch above, so reaching
        ; here with oldState == 1 is the werewolf cure and nothing else.
        if oldState == 1 && StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown") != 1
            ShowNordMessage(PDV_Msg_Nord_CurseState_WerewolfCured, "The hunt is set down. Hircine's hold is broken, and Sovngarde calls you once more.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 1)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 0)
    endIf
EndFunction

Bool Function ShouldSuppressNordCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Bool Function ShouldSuppressRedguardCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction


Function ShowNordMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if _suppressCurseTransitionOutputs
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    _raceCurseSurfaceShown = True

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
    if !NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    SendPrismaToast("kyne", "neutral", "", fallbackText)
EndFunction

Function ShowRedguardNotification(Message messageRecord, String fallbackText)
    if !NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    SendPrismaToast("tuwhacca", "neutral", "", fallbackText)
EndFunction

; P11 (2026-08-04): the Altmer sibling of the Nord/Redguard/Orc notification helpers.
; The fallback path is the reason every Altmer notification property has to be bound: a None
; record does not fail, it silently downgrades to a Prisma toast with no title.

Function ShowOrcNotification(Message messageRecord, String fallbackText)
    if !NotificationsEnabled()
        return
    endIf

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

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    _raceCurseSurfaceShown = True

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
    Int normalized = PDV_DevotionRules.ClampInt(traditionValue, 0, 2)
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
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    if PDV_RedguardSectTrack
        Int normalized = PDV_DevotionRules.ClampInt(sectValue, REDGUARD_SECT_CROWN, REDGUARD_SECT_ASHABAH)
        PDV_RedguardSectTrack.SetState(normalized, reason)
        AppendBookOfDaysEntry(BuildStartupRoadJournalLine(GetRedguardSectLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "sect", True, 3, "", True)
        ShowRedguardSectEntry(normalized)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.SetupComplete", 1)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyOrcInitialChoice(Int modeValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    if PDV_OrcLifeModeTrack
        PDV_OrcLifeModeTrack.SetState(PDV_DevotionRules.ClampInt(modeValue, ORC_LIFE_MODE_CITY, ORC_LIFE_MODE_LEGION_EXILE), reason)
        AppendBookOfDaysEntry(BuildStartupRoadJournalLine(GetOrcLifeModeLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "malacath", True, 3, "", True)
    endIf
    ; Malacath is the single innate Orc spine (not chosen, not offered) -- activate him as the
    ; patron at origin so the life-mode reward ladder (gated on _activeDeity==PDV_Malacath) is
    ; reachable in normal play; without this the whole Malacath progression was a dead no-op.
    ; Owner ruling 2026-06-27.
    if PDV_Malacath
        LedgerRuntime.SetActiveDeity(PDV_Malacath)
    endIf
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    RequestPanelRefresh()
    EndRaceSetupQuietPresentation()
EndFunction

Function ApplyNordInitialChoice(Int baselineValue, String reason)
    BeginRaceSetupQuietPresentation(reason)
    Int normalized = PDV_DevotionRules.ClampInt(baselineValue, NORD_BASELINE_OLD_WAYS, NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalized)
    if PDV_NordPantheonBaselineTrack
        PDV_NordPantheonBaselineTrack.SetState(normalized, reason)
    endIf

    LedgerRuntime.SetBroadWorship()
    String baselineLabel = "Old Ways"
    if normalized == NORD_BASELINE_NINE_DIVINES
        baselineLabel = "Nine Divines"
    endIf
    AppendBookOfDaysEntry(BuildStartupRoadJournalLine(baselineLabel), Utility.GetCurrentGameTime() as Int, "reorientation", "journal", True, 3, "", True)
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
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

    ; Once-per-dawn guard. fix-plan 4.2: the day+1 encoding already dodged the day-0
    ; self-suppression trap, but on the raw-midnight day -- now the actual dawn day.
    if LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Breton.DruidicDecayDay") == (LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf
    LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Breton.DruidicDecayDay")

    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    if standingValue <= 0
        return
    endIf
    standingValue = PDV_DevotionRules.ClampInt(standingValue - 1, 0, 100)
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

    Trace(2, "Retired Breton ancestor spine signal ignored: " + reason + " x" + multiplier)
EndFunction

Function RunDawnRefreshBretonAncestor()
    if !PDV_BretonAncestorSubstrate
        return
    endIf

    PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
EndFunction

Function HandleBretonActionPracticeSignal(Int eventType, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return
    endIf

    String sourceKey = "event_" + eventType
    if eventType == 350 || eventType == 351
        AwardBretonPracticePulse(BRETON_TRADITION_KNIGHTS_ROAD, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 300 || eventType == 301
        AwardBretonPracticePulse(BRETON_TRADITION_KNIGHTS_ROAD, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 304 || eventType == 364 || eventType == 362 || eventType == 366
        DamageBretonPracticePressure(BRETON_TRADITION_KNIGHTS_ROAD, 10, sourceKey, reason)
    endIf

    if eventType == 313 || eventType == 334 || eventType == 303 || eventType == 333 || eventType == 300
        AwardBretonPracticePulse(BRETON_TRADITION_GREEN_WAY, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 365 || eventType == 331 || eventType == 364
        DamageBretonPracticePressure(BRETON_TRADITION_GREEN_WAY, 10, sourceKey, reason)
    endIf

    if eventType == 341 || eventType == 342
        AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 331
        AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 333 || eventType == 314
        AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    endIf
EndFunction

Function HandleBretonQuestTagPracticeSignal(String sourceTag, Bool positive, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON || sourceTag == ""
        return
    endIf

    String sourceKey = "tag_" + sourceTag
    if positive
        if sourceTag == "mercy_spare" || sourceTag == "protect_the_weak" || sourceTag == "uphold_law_justice" || sourceTag == "keep_oath"
            AwardBretonPracticePulse(BRETON_TRADITION_KNIGHTS_ROAD, BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        elseIf sourceTag == "honor_the_wild" || sourceTag == "the_hunt"
            AwardBretonPracticePulse(BRETON_TRADITION_GREEN_WAY, BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        elseIf sourceTag == "forbidden_knowledge"
            AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        endIf
    else
        if sourceTag == "kill_the_helpless" || sourceTag == "murder_treacherous"
            DamageBretonPracticePressure(BRETON_TRADITION_KNIGHTS_ROAD, 12, sourceKey, reason)
        elseIf sourceTag == "defile_nature" || sourceTag == "necromancy"
            DamageBretonPracticePressure(BRETON_TRADITION_GREEN_WAY, 12, sourceKey, reason)
        elseIf sourceTag == "reckless_magic"
            DamageBretonPracticePressure(BRETON_TRADITION_HIDDEN_ART, 12, sourceKey, reason)
        endIf
    endIf
EndFunction

Int Function ConsumeBretonPracticePointBudget(Int requestedPoints)
    if requestedPoints <= 0
        return 0
    endIf

    ; fix-plan 4.2: the practice-point budget is a daily cap; devotional day.
    Int today = LedgerRuntime.GetDevotionalDay() + 2
    Int budgetDay = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointDay", -1)
    if budgetDay != today
        StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointDay", today)
        StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", 0)
    endIf

    Int pointsToday = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointsToday")
    Int remaining = BRETON_PRACTICE_DAILY_MAX_POINTS - pointsToday
    if remaining <= 0
        return 0
    endIf

    Int appliedPoints = requestedPoints
    if appliedPoints > remaining
        appliedPoints = remaining
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", pointsToday + appliedPoints)
    return appliedPoints
EndFunction

Bool Function AwardBretonPracticePulse(Int traditionValue, Int requestedPoints, String sourceKey, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != traditionValue
        return False
    endIf
    if traditionValue == BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        return False
    endIf
    if !ConsumeOncePerDaySignal("PDV.Signal.BretonPractice." + traditionValue + "." + sourceKey)
        return False
    endIf

    Int appliedPoints = ConsumeBretonPracticePointBudget(requestedPoints)
    if appliedPoints <= 0
        Trace(2, "Breton practice daily cap blocked " + sourceKey + ": " + reason)
        return False
    endIf

    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
        StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", PDV_DevotionRules.ClampInt(exposureValue + appliedPoints, 0, 100))
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastHiddenArtReason", reason)
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        EnsureBretonDruidicForkInitialized()
        Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", PDV_DevotionRules.ClampInt(standingValue + appliedPoints, 0, 100))
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if _qrQueueTransactionActive
        _qrQueueNeedsBretonRewardSync = True
    else
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        RequestPanelRefresh()
    endIf
    Trace(2, "Breton practice pulse " + traditionValue + " +" + appliedPoints + " from " + sourceKey + ": " + reason)
    return True
EndFunction

Bool Function DamageBretonPracticePressure(Int traditionValue, Int damageDelta, String sourceKey, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != traditionValue
        return False
    endIf
    if !ConsumeOncePerDaySignal("PDV.Signal.BretonPracticeDamage." + traditionValue + "." + sourceKey)
        return False
    endIf

    if traditionValue == BRETON_TRADITION_KNIGHTS_ROAD
        Int vowValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", PDV_DevotionRules.ClampInt(vowValue - damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    elseIf traditionValue == BRETON_TRADITION_HIDDEN_ART
        Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
        StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", PDV_DevotionRules.ClampInt(exposureValue + damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastHiddenArtReason", reason)
    elseIf traditionValue == BRETON_TRADITION_GREEN_WAY
        EnsureBretonDruidicForkInitialized()
        Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", PDV_DevotionRules.ClampInt(standingValue - damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if _qrQueueTransactionActive
        _qrQueueNeedsBretonRewardSync = True
    else
        LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        RequestPanelRefresh()
    endIf
    Trace(2, "Breton practice pressure " + traditionValue + " from " + sourceKey + ": " + reason)
    return True
EndFunction

Function MaybeRecordBretonCrossTraditionPressure(Int sourceTradition, String sourceKey, String reason)
    if StorageUtil.GetIntValue(None, "PDV.Breton.SetupComplete") != 1
        return
    endIf
    if GetBretonTraditionValue() == sourceTradition
        return
    endIf
    if !ConsumeOncePerDaySignal("PDV.Signal.BretonCrossTradition." + sourceTradition + "." + sourceKey)
        return
    endIf

    StorageUtil.AdjustIntValue(None, "PDV.Breton.CrossTraditionPressure", 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
EndFunction

Function HandleBretonKnightlyVow(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_BRETON
        Trace(2, "Breton Knightly Vow ignored for non-Breton origin.")
        return
    endIf

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")
    if multiplier <= 0.0
        return
    endIf

    if LedgerRuntime.PDV_Stendarr
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Stendarr, LedgerRuntime.PDV_Stendarr.SIGNAL_MERCY, None, multiplier)
    endIf
    if !AwardBretonPracticePulse(BRETON_TRADITION_KNIGHTS_ROAD, BRETON_PRACTICE_CURATED_POINTS, "handler_knightly_vow", reason)
        MaybeRecordBretonCrossTraditionPressure(BRETON_TRADITION_KNIGHTS_ROAD, "handler_knightly_vow", reason)
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

    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonHiddenArtExposure")
    if multiplier <= 0.0
        return
    endIf

    if PDV_Magnus
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Magnus, PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None, multiplier)
    endIf
    if LedgerRuntime.PDV_Mara && PDV_DevotionRules.StringContainsToken(reason, "home")
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Mara, LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
    endIf
    Bool practiceAwarded = AwardBretonPracticePulse(BRETON_TRADITION_HIDDEN_ART, BRETON_PRACTICE_CURATED_POINTS, "handler_hidden_art_exposure", reason)
    if !practiceAwarded
        MaybeRecordBretonCrossTraditionPressure(BRETON_TRADITION_HIDDEN_ART, "handler_hidden_art_exposure", reason)
    endIf
    AwardBretonAncestorSpinePulse(multiplier, reason)
    ; An approved P2 book is a distinct player acknowledgement even when the
    ; daily practice cap has already reduced its mechanical credit.
    SurfaceP2BookReadNotice(reason, GetBretonHiddenArtNoticeTitle(reason), GetBretonHiddenArtNoticeText(reason))
    Trace(2, "Breton Hidden Art exposure routed: " + reason)
EndFunction

String Function GetBretonHiddenArtNoticeTitle(String reason)
    if PDV_DevotionRules.StringContainsToken(reason, "hagravens")
        return "Hagraven lore"
    elseIf PDV_DevotionRules.StringContainsToken(reason, "madmen_reach")
        return "Reach-mad whispers"
    elseIf PDV_DevotionRules.StringContainsToken(reason, "witch_note")
        return "A witch's note"
    endIf

    return "The Hidden Art"
EndFunction

String Function GetBretonHiddenArtNoticeText(String reason)
    if PDV_DevotionRules.StringContainsToken(reason, "hagravens")
        return "Old bargains leave a mark on your cover."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "madmen_reach")
        return "Forbidden Reach lore stirs your hidden practice."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "witch_note")
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
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BretonGreenWayStanding")
    if multiplier <= 0.0
        return
    endIf
    if PDV_Yffre
        ; Breton-voiced Green Way signal; the Bosmer Living Story signal stays
        ; Bosmer-only so driver rows read in the right tradition's voice.
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Yffre, PDV_Yffre.SIGNAL_GREEN_WAY, None, multiplier)
    endIf
    if !AwardBretonPracticePulse(BRETON_TRADITION_GREEN_WAY, BRETON_PRACTICE_CURATED_POINTS, "handler_green_way_standing", reason)
        MaybeRecordBretonCrossTraditionPressure(BRETON_TRADITION_GREEN_WAY, "handler_green_way_standing", reason)
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
    if PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
        PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "reclamation_source_" + reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocus", PDV_DevotionRules.ClampInt(focusValue, 0, 2))
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocusCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastReclamationReason", reason)
    AwardDunmerReclamationFocusSignal(focusValue, layerWeight)
    if focusValue == 0
        SurfaceP2BookReadNotice(reason, "Azura's twilight", "The Reclamation turns toward her.")
    elseIf focusValue == 1
        SurfaceP2BookReadNotice(reason, "Boethiah's proving", "The Reclamation turns toward struggle.")
    else
        SurfaceP2BookReadNotice(reason, "Mephala's web", "The Reclamation turns toward secrets.")
    endIf
    Trace(2, "Dunmer Reclamation focus routed: " + reason + " weight " + layerWeight)
EndFunction

Function HandleDunmerHonorableVictory(Form victimForm)
    ; Canonical player-alias ingress. It records only the clean-combat half; a
    ; single caller cannot award until Story Manager independently confirms the
    ; hostile, non-murder classification for the same victim.
    RecordDunmerCombatVictoryEvidence(victimForm)
EndFunction

Function RecordDunmerCombatVictoryEvidence(Form victimForm)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !victimForm
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableCombatVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableCombatTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function RecordDunmerStoryVictoryEvidence(Form victimForm, Int relationshipRank)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !victimForm || relationshipRank > -2
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableStoryVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableStoryTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function TryResolveDunmerHonorableVictory(Form victimForm)
    if !PDV_DunmerAncestorSubstrate || !victimForm
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
    PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "honorable_victory_" + victim.GetFormID())
    Trace(2, "Dunmer honorable victory accepted for " + victim.GetFormID())
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

    ; fix-plan 4.2: one notice per devotional day (the journal line above keeps the
    ; wall-clock date on purpose -- that is a display timestamp, not a cap).
    String toastKey = "PDV.Toast.DunmerDeviationPrice.Day"
    Int toastDayStamp = LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, toastKey, -1) != toastDayStamp
        StorageUtil.SetIntValue(None, toastKey, toastDayStamp)
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

    ; fix-plan 4.2: one rite per window per devotional day.
    Int dayIndex = LedgerRuntime.GetDevotionalDay() + 2
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
    LedgerRuntime.AwardCuratedSignal(PDV_Azura, PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE, None)
    Trace(2, "Dunmer " + windowLabel + " twilight rite routed: " + reason)
    return True
EndFunction

; Outdoor Good Daedra shrine prayer (Solstheim DLC2 Azura/Boethiah/Mephala altars).
; The twilight-window award is the spec'd role for the outdoor shrine; TryAward already
; enforces Dunmer origin, the dawn/dusk window, and the once-per-window-per-day cap.
Function HandleDunmerOutdoorGoodDaedraShrine(String reason)
    if TryAwardDunmerTwilightWindowSignal(reason)
        if PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
            PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "good_daedra_altar_" + reason)
        endIf
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
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE
        return
    endIf

    ; Anti-farm: the ancestor-memory piety pulse (portable-shrine prayer and the
    ; home rite share it) banks at most once per dawn cycle, keyed on the same
    ; day-int boundary as the rest of the daily gates. The substrate side keeps its
    ; own 0.7^n decay separately; this stops the pulse from stacking linearly.
    ; fix-plan 4.2: the comment above already says "once per dawn cycle" -- it now uses
    ; the dawn day boundary instead of raw midnight.
    Int pdvAncestorMemoryDay = LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day") == pdvAncestorMemoryDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day", pdvAncestorMemoryDay)

    Float layerWeight = GetDunmerCurseLayerWeight(2)
    if _activeDeity == PDV_Boethiah && PDV_Boethiah
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf _activeDeity == PDV_Mephala && PDV_Mephala
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf _activeDeity == PDV_Azura && PDV_Azura
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, layerWeight)
    endIf
EndFunction

; Owner ruling 2026-08-07: this feeds the ANCESTRAL layer (layer 1), not the Reclamation lane, so it
; fires on the first ancestor prayer of the devotional day REGARDLESS of patron. Before this was
; wired, a Dunmer with no active patron -- or on any repeat prayer that day -- recorded NO Ledger
; driver at all, because AwardActiveDunmerReclamationMemorySignal was the only curated signal on the
; path and it is patron-gated. PDV_RunSheet_Dunmer_V1.md:184 calls that empty Ledger a FAIL.
; The anti-farm cap lives HERE rather than at the call site, so a second call site cannot reintroduce
; farming. It uses the same day-int boundary encoding as the Reclamation-memory pulse above.
Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_DUNMER || !PDV_Azura || multiplier <= 0.0
        return
    endIf

    Int pdvAncestorSpineDay = LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day") == pdvAncestorSpineDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day", pdvAncestorSpineDay)

    LedgerRuntime.AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Dunmer.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
EndFunction

Function AwardDunmerReclamationFocusSignal(Int focusValue, Float layerWeight)
    if focusValue == 0 && PDV_Azura
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_THRESHOLD_RITE, None, layerWeight)
    elseIf focusValue == 1 && PDV_Boethiah
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE, None, layerWeight)
    elseIf focusValue == 2 && PDV_Mephala
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_SECRET_KEPT, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerDeviationPriceSignal(Float multiplier)
    if _activeDeity == PDV_Boethiah && PDV_Boethiah
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf _activeDeity == PDV_Mephala && PDV_Mephala
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Mephala, PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf _activeDeity == PDV_Azura && PDV_Azura
        LedgerRuntime.AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_DESECRATION, None, multiplier)
    endIf
EndFunction

Int Function GetImperialCivicFamilyFromSource(String sourceId)
    if PDV_DevotionRules.StringContainsToken(sourceId, "public_service") || PDV_DevotionRules.StringContainsToken(sourceId, "public-service") || PDV_DevotionRules.StringContainsToken(sourceId, "civic_public")
        return IMPERIAL_CIVIC_PUBLIC_SERVICE
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "mercy")
        return IMPERIAL_CIVIC_MERCY
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "lawful_order") || PDV_DevotionRules.StringContainsToken(sourceId, "lawful-order") || PDV_DevotionRules.StringContainsToken(sourceId, "law")
        return IMPERIAL_CIVIC_LAWFUL_ORDER
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "honest_work") || PDV_DevotionRules.StringContainsToken(sourceId, "honest-work") || PDV_DevotionRules.StringContainsToken(sourceId, "work")
        return IMPERIAL_CIVIC_HONEST_WORK
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "death_duty") || PDV_DevotionRules.StringContainsToken(sourceId, "death-duty") || PDV_DevotionRules.StringContainsToken(sourceId, "arkay")
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
        if LedgerRuntime.PDV_Akatosh
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Akatosh, LedgerRuntime.PDV_Akatosh.SIGNAL_CIVIC_SERVICE, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_MERCY
        if LedgerRuntime.PDV_Mara
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Mara, LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_LAWFUL_ORDER
        if LedgerRuntime.PDV_Stendarr
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Stendarr, LedgerRuntime.PDV_Stendarr.SIGNAL_LAWFUL_ORDER, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_HONEST_WORK
        if LedgerRuntime.PDV_Zenithar
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Zenithar, LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
        endIf
    elseIf familyId == IMPERIAL_CIVIC_DEATH_DUTY
        if LedgerRuntime.PDV_Arkay
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Arkay, LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    endIf
EndFunction

Function AwardImperialPatronCivicSignal(Float multiplier)
    if !_activeDeity
        return
    endIf

    if _activeDeity == LedgerRuntime.PDV_Akatosh && LedgerRuntime.PDV_Akatosh
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Akatosh, LedgerRuntime.PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Mara && LedgerRuntime.PDV_Mara
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Mara, LedgerRuntime.PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Arkay && LedgerRuntime.PDV_Arkay
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Arkay, LedgerRuntime.PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Stendarr && LedgerRuntime.PDV_Stendarr
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Stendarr, LedgerRuntime.PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Zenithar && LedgerRuntime.PDV_Zenithar
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Zenithar, LedgerRuntime.PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Dibella && LedgerRuntime.PDV_Dibella
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Dibella, LedgerRuntime.PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Julianos && LedgerRuntime.PDV_Julianos
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Julianos, LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf _activeDeity == LedgerRuntime.PDV_Kynareth && LedgerRuntime.PDV_Kynareth
        LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Kynareth, LedgerRuntime.PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    endIf
EndFunction

Function AwardImperialAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL || multiplier <= 0.0 || IsImperialVampireStateActive()
        return
    endIf

    Int tierBefore = 0
    if PDV_ImperialAncestorSubstrate
        Float metricBefore = PDV_ImperialAncestorSubstrate.GetMetric()
        tierBefore = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(multiplier, reason)
        Int tierAfter = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        SendPrismaSubstrateProgress("imperial-civic", tierBefore, tierAfter, PDV_ImperialAncestorSubstrate.GetMetric() - metricBefore, "Your public service steadies your devotion.", "journal", GetImperialCivicTierName())
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

    PDV_ImperialAncestorSubstrate.ProcessCivicDawn(IsImperialVampireStateActive(), "dawn")
EndFunction

Function HandleImperialCivicService(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial civic service ignored for non-Imperial origin.")
        return
    endIf
    if IsImperialVampireStateActive()
        Trace(2, "Imperial civic service blocked by vampirism: " + reason)
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

    ; Legacy CivicServiceCount is frozen after broad-pool migration.
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
    if IsImperialVampireStateActive()
        Trace(2, "Imperial Talos pressure blocked by vampirism: " + reason)
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

    StorageUtil.SetIntValue(None, "PDV.Imperial.TalosBroadUnlocked", 1)

    if isPrivate
        StorageUtil.SetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") + 1)
        if PDV_Talos
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.PublicTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") + 1)
        if PDV_Talos
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_DEFIANCE_MILESTONE, None, multiplier)
        endIf
    endIf

    StorageUtil.SetStringValue(None, "PDV.Imperial.LastTalosPressureReason", reason)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    SurfaceP2BookReadNotice(reason, "The name of Talos", "The question of the Ninth presses harder.")
    Trace(2, "Imperial Talos pressure routed: " + reason)
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL
        Trace(2, "Imperial patron civic favor ignored for non-Imperial origin.")
        return
    endIf
    if IsImperialVampireStateActive()
        Trace(2, "Imperial patron civic favor blocked by vampirism: " + reason)
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

    if PDV_DevotionRules.StringContainsToken(sourceId, "sky_road") || PDV_DevotionRules.StringContainsToken(sourceId, "sky-road") || PDV_DevotionRules.StringContainsToken(sourceId, "storm_road") || PDV_DevotionRules.StringContainsToken(sourceId, "road_grace")
        if PDV_DevotionRules.StringContainsToken(sourceId, "nine")
            return NORD_ROUTE_NINE_ROAD
        endIf
        return NORD_ROUTE_OLD_SKY_ROAD
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ordeal") || PDV_DevotionRules.StringContainsToken(sourceId, "trial") || PDV_DevotionRules.StringContainsToken(sourceId, "adversity")
        return NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hearth") || PDV_DevotionRules.StringContainsToken(sourceId, "hold") || PDV_DevotionRules.StringContainsToken(sourceId, "protect_bond")
        return NORD_ROUTE_OLD_HEARTH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ancestor") || PDV_DevotionRules.StringContainsToken(sourceId, "honored_dead")
        return NORD_ROUTE_OLD_ANCESTOR
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hircine") || PDV_DevotionRules.StringContainsToken(sourceId, "hunt")
        return NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "household") || PDV_DevotionRules.StringContainsToken(sourceId, "mercy")
        return NORD_ROUTE_NINE_MERCY
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "proper_death") || PDV_DevotionRules.StringContainsToken(sourceId, "proper-death") || PDV_DevotionRules.StringContainsToken(sourceId, "anti_necromancy") || PDV_DevotionRules.StringContainsToken(sourceId, "arkay")
        return NORD_ROUTE_NINE_DEATH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "honest_work") || PDV_DevotionRules.StringContainsToken(sourceId, "honest-work") || PDV_DevotionRules.StringContainsToken(sourceId, "learned_craft") || PDV_DevotionRules.StringContainsToken(sourceId, "zenithar")
        return NORD_ROUTE_NINE_WORK
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos_pressure") || PDV_DevotionRules.StringContainsToken(sourceId, "talos-pressure")
        return NORD_ROUTE_NINE_TALOS
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos") || PDV_DevotionRules.StringContainsToken(sourceId, "defiance")
        return NORD_ROUTE_OLD_TALOS
    endIf

    return NORD_ROUTE_UNKNOWN
EndFunction

Int Function GetNordFavorLaneForRouteFamily(Int familyValue)
    if familyValue >= NORD_ROUTE_NINE_ROAD
        return FavorRuntime.FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    if familyValue > NORD_ROUTE_UNKNOWN
        return FavorRuntime.FAVOR_LANE_NORD_BROAD_OLD_WAYS
    endIf

    return FavorRuntime.FAVOR_LANE_NONE
EndFunction

Int Function GetNordFavorFamilyForRouteFamily(Int familyValue)
    if familyValue == NORD_ROUTE_OLD_SKY_ROAD
        return FavorRuntime.FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    elseIf familyValue == NORD_ROUTE_OLD_ORDEAL
        return FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
    elseIf familyValue == NORD_ROUTE_OLD_HEARTH
        return FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
    elseIf familyValue == NORD_ROUTE_OLD_ANCESTOR
        return FavorRuntime.FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
    elseIf familyValue == NORD_ROUTE_OLD_TALOS
        return FavorRuntime.FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf familyValue == NORD_ROUTE_NINE_ROAD
        return FavorRuntime.FAVOR_FAMILY_NINE_ROAD_GRACE
    elseIf familyValue == NORD_ROUTE_NINE_MERCY
        return FavorRuntime.FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
    elseIf familyValue == NORD_ROUTE_NINE_DEATH
        return FavorRuntime.FAVOR_FAMILY_NINE_PROPER_DEATH
    elseIf familyValue == NORD_ROUTE_NINE_WORK
        return FavorRuntime.FAVOR_FAMILY_NINE_HONEST_WORK
    elseIf familyValue == NORD_ROUTE_NINE_TALOS
        return FavorRuntime.FAVOR_FAMILY_NINE_TALOS_PRESSURE
    endIf

    return 0
EndFunction

Function AwardNordRouteFamilySignal(Int familyValue, Float multiplier)
    if familyValue == NORD_ROUTE_OLD_SKY_ROAD
        ; Kyne's curated sky-road milestone bump. Services broad Old Ways worship
        ; and a focused Kyne patron alike (direct deity award, patron-agnostic).
        if PDV_Kyne
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Kyne, PDV_Kyne.SIGNAL_SKY_ROAD, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_ORDEAL
        if PDV_Tsun
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Tsun, PDV_Tsun.SIGNAL_TRIAL_ENDURED, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_HEARTH
        if PDV_Stuhn
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Stuhn, PDV_Stuhn.SIGNAL_PROTECT_BOND, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_ANCESTOR
        if PDV_Shor
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_HONORED_DEAD, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_OLD_TALOS || familyValue == NORD_ROUTE_NINE_TALOS
        if PDV_Talos
            LedgerRuntime.AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_ROAD
        if LedgerRuntime.PDV_Kynareth
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Kynareth, LedgerRuntime.PDV_Kynareth.SIGNAL_OPEN_SKY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_MERCY
        if LedgerRuntime.PDV_Mara
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Mara, LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_DEATH
        if LedgerRuntime.PDV_Arkay
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Arkay, LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    elseIf familyValue == NORD_ROUTE_NINE_WORK
        if LedgerRuntime.PDV_Zenithar
            LedgerRuntime.AwardCuratedSignalScaled(LedgerRuntime.PDV_Zenithar, LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
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
    if laneValue != FavorRuntime.FAVOR_LANE_NONE && favorFamily > 0
        FavorRuntime.TryActivateContextualFavor(laneValue, favorFamily, reason)
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
    LedgerRuntime.SyncFirstTierRaceRewardRuntime()
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
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            SurfaceP2BookReadNotice(reason, "Faith of the Holds", "The Divines honored in the holds stand nearer.")
        else
            SurfaceP2BookReadNotice(reason, "The Old Ways", "The elder gods of the Nords stand nearer.")
        endIf
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
        SurfaceP2BookReadNotice(reason, "Hunt and grave", "Beast and rest blur at the edges.")
    endIf
EndFunction

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

        optionsJson = optionsJson + "{\"option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionId(originRace, optionValue)) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionTitle(originRace, optionValue)) + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionSummary(originRace, optionValue)) + "\",\"description\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionDescription(originRace, optionValue)) + "\"}"
        i += 1
    endWhile

    String modeText = "info_only"
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        modeText = "explicit_choice"
    endIf

    String payload = "{\"mode\":\"startup\",\"startup\":{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\",\"race_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupRaceId(originRace)) + "\",\"startup_mode\":\"" + modeText + "\",\"options\":[" + optionsJson + "],\"default_option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupOptionId(originRace, defaultOption)) + "\",\"advisory_line\":\"" + PDV_DevotionRules.JsonSafeString(STARTUP_ADVISORY_TEXT) + "\",\"confirm_required\":" + PDV_DevotionRules.BoolToJson(confirmRequired) + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(GetOriginRaceLabel(originRace) + " startup") + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetStartupCanonicalSummary(originRace)) + "\"}}"

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
    return GetOriginRaceLabel(originRace) + " - " + GetBookOfDaysPathStatusLabel(originRace)
EndFunction

String Function GetBookOfDaysPathStatusLabel(Int originRace)
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Path Not Yet Chosen"
    endIf

    if originRace == ORIGIN_BRETON
        return GetBretonBookOfDaysPathStatusLabel()
    endIf

    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
    if activePact
        return NormalizePublicDeityDisplayText(activePact.DeityName) + " Pact"
    endIf

    if _activeDeity && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        return GetPublicDeityDisplayName(_activeDeity)
    endIf

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD
        return GetBroadLaneDisplayName(originRace)
    endIf

    if originRace == ORIGIN_NORD
        return GetNordDevotionModeLabel()
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
        return GetOrcLifeModeLabel()
    elseIf originRace == ORIGIN_REDGUARD
        return GetRedguardSectLabel()
    elseIf originRace == ORIGIN_IMPERIAL
        return GetImperialConcordatLabel()
    elseIf originRace == ORIGIN_DUNMER
        Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
        if reclamationFocus >= 0
            return GetDunmerReclamationFocusLabel(reclamationFocus) + " Reclamation Focus"
        endIf
        return "Ancestor Rites " + GetBookOfDaysDunmerAncestorLabel()
    endIf

    return "Path Unsettled"
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
    Int bretonPracticeTier = LedgerRuntime.TIER_NONE
    if originRace == ORIGIN_BRETON
        bretonPracticeTier = GetBretonPracticeTier(GetBretonTraditionValue())
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
        if IsFocusedPantheonBoonSuspended()
            tierValue = LedgerRuntime.TIER_NONE
        endIf
    elseIf originRace == ORIGIN_BRETON
        if bretonPracticeTier > LedgerRuntime.TIER_NONE
            tierValue = bretonPracticeTier
            pietyValue = GetBretonPracticeCount(GetBretonTraditionValue()) as Float
        endIf
    elseIf originRace == ORIGIN_ARGONIAN && PDV_ArgonianHistSubstrate
        tierValue = PDV_ArgonianHistSubstrate.GetSubstrateTier()
        pietyValue = PDV_ArgonianHistSubstrate.GetMetric()
        championThreshold = 75.0
    else
        Int broadTier = GetBroadLaneTierForOrigin(originRace)
        if LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || broadTier > LedgerRuntime.TIER_NONE
            tierValue = broadTier
            pietyValue = GetBroadLaneStandingValue(originRace)
        endIf
    endIf

    String tierLabel = GetCurrentStandingLabel()
    if journalCommitment == None && originRace == ORIGIN_BRETON && bretonPracticeTier > LedgerRuntime.TIER_NONE
        tierLabel = GetPublicTierBand(bretonPracticeTier)
    elseIf journalCommitment == None && originRace == ORIGIN_ARGONIAN
        tierLabel = OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf journalCommitment == None && (LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || GetBroadLaneTierForOrigin(originRace) > LedgerRuntime.TIER_NONE)
        tierLabel = GetBroadLaneStandingLabel(originRace, GetBroadLaneTierForOrigin(originRace))
    elseIf journalCommitment && IsFocusedPantheonBoonSuspended()
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
Bool Function UsesNordOldWaysDeityNames()
    if GetPlayerOriginRaceIndex() != ORIGIN_NORD
        return False
    endIf
    return GetNordPantheonBaselineState() == NORD_BASELINE_OLD_WAYS
EndFunction

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
    if !UsesNordOldWaysDeityNames()
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

String Function GetMedallionSectionsJson(Int originRace)
    if originRace == ORIGIN_NORD
        return MedallionSection("native", "Native worship", GetNordMedallionEntriesJson())
    elseIf originRace == ORIGIN_IMPERIAL
        return MedallionSection("native", "Native worship", GetImperialMedallionEntriesJson())
    elseIf originRace == ORIGIN_BRETON
        return MedallionSection("native", "Native worship", GetBretonMedallionEntriesJson())
    elseIf originRace == ORIGIN_ALTMER
        return MedallionSection("native", "Native worship", OriginRuntime.GetAltmerMedallionEntriesJson())
    elseIf originRace == ORIGIN_BOSMER
        return MedallionSection("native", "Native worship", OriginRuntime.GetBosmerNativeMedallionEntriesJson()) + "," + MedallionSection("substrate_focus", "Path focus", OriginRuntime.GetBosmerFocusMedallionEntriesJson())
    elseIf originRace == ORIGIN_DUNMER
        return MedallionSection("native", "Native worship", GetDunmerMedallionEntriesJson())
    elseIf originRace == ORIGIN_KHAJIIT
        return MedallionSection("native", "Native worship", OriginRuntime.GetKhajiitMedallionEntriesJson())
    elseIf originRace == ORIGIN_ARGONIAN
        return MedallionSection("native", "Native worship", OriginRuntime.GetArgonianMedallionEntriesJson())
    elseIf originRace == ORIGIN_ORC
        return MedallionSection("native", "Native worship", GetOrcMedallionEntriesJson())
    elseIf originRace == ORIGIN_REDGUARD
        return MedallionSection("native", "Native worship", GetRedguardMedallionEntriesJson())
    endIf

    return MedallionSection("native", "Native worship", MedallionEntry("unknown", "Devotion", "substrate", "journal", None, False, "Your origin is not settled yet.", "Once your origin is known, the medallion can show the roster your people can name.", "Origin readback is pending."))
EndFunction

String Function GetNordMedallionEntriesJson()
    String entries = RosterMedallionEntry("kyne", "Kyne", "god", "kyne", PDV_Kyne, "Sky, storm, hunt, and warrior-spirit.")
    entries = entries + "," + RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", LedgerRuntime.PDV_Kynareth, "The Nine Divines sky road.")
    entries = entries + "," + RosterMedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, "Open defiance and human apotheosis.")
    entries = entries + "," + RosterMedallionEntry("shor", "Shor", "god", "shor", PDV_Shor, "The old king and afterlife road.")
    entries = entries + "," + RosterMedallionEntry("tsun", "Tsun", "god", "tsun", PDV_Tsun, "Trial, honor, and the threshold.")
    entries = entries + "," + RosterMedallionEntry("stuhn", "Stuhn", "god", "stuhn", PDV_Stuhn, "Mercy in war and fair ransom.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", LedgerRuntime.PDV_Mara, "Love, hearth, and compassion.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", LedgerRuntime.PDV_Akatosh, "Time, order, and dragon authority.")
    String arkayRosterName = "Arkay"
    if UsesNordOldWaysDeityNames()
        arkayRosterName = "Orkey"
    endIf
    entries = entries + "," + RosterMedallionEntry("arkay", arkayRosterName, "god", "arkay", LedgerRuntime.PDV_Arkay, "Death, burial, and proper passage.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", LedgerRuntime.PDV_Stendarr, "Mercy, justice, and protection.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", LedgerRuntime.PDV_Julianos, "Law, learning, and craft of mind.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", LedgerRuntime.PDV_Dibella, "Beauty, art, and embodied grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", LedgerRuntime.PDV_Zenithar, "Work, trade, and honest craft.")
    return entries
EndFunction

String Function GetImperialMedallionEntriesJson()
    String entries = RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", LedgerRuntime.PDV_Kynareth, "Road, wind, and natural order.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", LedgerRuntime.PDV_Mara, "Love, family, and mercy.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", LedgerRuntime.PDV_Akatosh, "Time, covenant, and empire.")
    entries = entries + "," + RosterMedallionEntry("arkay", "Arkay", "god", "arkay", LedgerRuntime.PDV_Arkay, "Life, death, and lawful burial.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", LedgerRuntime.PDV_Stendarr, "Mercy, protection, and civic virtue.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", LedgerRuntime.PDV_Julianos, "Law, learning, and reason.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", LedgerRuntime.PDV_Dibella, "Art, beauty, and human grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", LedgerRuntime.PDV_Zenithar, "Work, trade, and prosperity.")
    return entries
EndFunction

String Function GetBretonMedallionEntriesJson()
    String entries = RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", LedgerRuntime.PDV_Kynareth, "Sky, travel, and druidic memory.")
    entries = entries + "," + RosterMedallionEntry("talos", "Talos", "god", "talos", PDV_Talos, "Civic defiance and Septim inheritance.")
    entries = entries + "," + RosterMedallionEntry("mara", "Mara", "god", "mara", LedgerRuntime.PDV_Mara, "Household, mercy, and love.")
    entries = entries + "," + RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", LedgerRuntime.PDV_Akatosh, "Time, order, and covenant.")
    entries = entries + "," + RosterMedallionEntry("arkay", "Arkay", "god", "arkay", LedgerRuntime.PDV_Arkay, "Death, burial, and clean endings.")
    entries = entries + "," + RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", LedgerRuntime.PDV_Stendarr, "Mercy, protection, and oath.")
    entries = entries + "," + RosterMedallionEntry("julianos", "Julianos", "god", "julianos", LedgerRuntime.PDV_Julianos, "Learning, law, and formal craft.")
    entries = entries + "," + RosterMedallionEntry("dibella", "Dibella", "god", "dibella", LedgerRuntime.PDV_Dibella, "Beauty, courtliness, and grace.")
    entries = entries + "," + RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", LedgerRuntime.PDV_Zenithar, "Trade, craft, and honest work.")
    entries = entries + "," + RosterMedallionEntry("magnus", "Magnus", "god", "magnus", PDV_Magnus, "Magic, light, and hidden inheritance.")
    entries = entries + "," + PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Pilgrimage, endurance, and Elven memory.")
    entries = entries + "," + RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", PDV_Yffre, "Green memory, story, and law.")
    return entries
EndFunction




String Function GetDunmerMedallionEntriesJson()
    String entries = RosterMedallionEntry("azura", "Azura", "prince", "azura", PDV_Azura, "Dawn, dusk, prophecy, and fate.")
    entries = entries + "," + RosterMedallionEntry("boethiah", "Boethiah", "prince", "boethiah", PDV_Boethiah, "Trial, overthrow, and hard becoming.")
    entries = entries + "," + RosterMedallionEntry("mephala", "Mephala", "prince", "mephala", PDV_Mephala, "Web, secrecy, clan, and hidden duty.")
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
    return "{\"section_id\":\"" + PDV_DevotionRules.JsonSafeString(sectionId) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"entries\":[" + entriesJson + "]}"
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
    report = report + nl + "Race: " + GetOriginRaceLabel(originRace) + " (index " + originRace + ")"
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
        return LedgerRuntime.AppendRecentDevotionEvents(GetBretonSurveyText())
    endIf

    ; Prince-wins for races without a layered pact tradition. The tier>0 guard inside
    ; GetActiveDaedricPactPath prevents a stale-pointer ghost pact.
    PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
    if pactPath
        return LedgerRuntime.AppendRecentDevotionEvents(GetDaedricSurveyText(pactPath))
    endIf

    if originRace != ORIGIN_NORD
        if originRace == ORIGIN_ALTMER
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetAltmerSurveyText())
        elseIf originRace == ORIGIN_KHAJIIT
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetKhajiitSurveyText())
        elseIf originRace == ORIGIN_BOSMER
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetBosmerSurveyText())
        elseIf originRace == ORIGIN_ARGONIAN
            return LedgerRuntime.AppendRecentDevotionEvents(OriginRuntime.GetArgonianSurveyText())
        elseIf originRace == ORIGIN_ORC
            return LedgerRuntime.AppendRecentDevotionEvents(GetOrcSurveyText())
        elseIf originRace == ORIGIN_REDGUARD
            return LedgerRuntime.AppendRecentDevotionEvents(GetRedguardSurveyText())
        elseIf originRace == ORIGIN_IMPERIAL
            return LedgerRuntime.AppendRecentDevotionEvents(GetImperialSurveyText())
        elseIf originRace == ORIGIN_DUNMER
            return LedgerRuntime.AppendRecentDevotionEvents(GetDunmerSurveyText())
        endIf

        return LedgerRuntime.AppendRecentDevotionEvents("Your devotion is watched. Standing: " + GetCurrentStandingBand() + ".")
    endIf

    String text = GetNordSurveyBaseText()
    String scarText = GetNordScarLabel()
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
    PDV_DaedricPathBase summaryPact = GetActiveDaedricPactPath()
    if summaryPact
        return NormalizePublicDeityDisplayText(summaryPact.DeityName) + " | Pact | " + GetCurrentStandingLabel()
    endIf

    if GetPlayerOriginRaceIndex() == ORIGIN_NORD
        return GetNordDevotionModeLabel() + " | " + GetCurrentStandingLabel() + " | " + GetPlayerCursePublicLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return "Altmer | " + OriginRuntime.GetAltmerCrisisStateLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return "Khajiit | " + OriginRuntime.GetKhajiitFocusLabel(OriginRuntime.GetKhajiitFocusedEmphasis()) + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return "Bosmer | " + OriginRuntime.GetBosmerPathLabel() + " | " + GetCurrentStandingLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Argonian | " + OriginRuntime.GetArgonianHistPostureLabel() + " | " + GetCurrentStandingLabel()
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

    return GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + " | " + LedgerRuntime.GetPatronStateLabel() + " | " + GetCurrentStandingLabel()
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
        return GetNordDevotionModeLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        return OriginRuntime.GetAltmerCrisisStateLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_KHAJIIT
        return OriginRuntime.GetKhajiitFocusLabel(OriginRuntime.GetKhajiitFocusedEmphasis())
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        return OriginRuntime.GetBosmerPathLabel()
    elseIf GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN
        return "Hist " + OriginRuntime.GetArgonianHistPostureLabel()
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
    String curseLabel = GetPlayerCursePublicLabel()
    if curseLabel == "None"
        return "No curse"
    endIf
    return curseLabel
EndFunction



String Function GetNordSurveyBaseText()
    String band = GetCurrentStandingBand()
    if IsNordVampireSuppressed()
        return "Standing: " + band + ". Sovngarde is closed while the thirst remains. Cure the curse to reopen the road."
    endIf

    String contextText = GetNordContextSurveyText()
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity
        String focusedText = "Standing: " + band + ". " + GetPublicDeityDisplayName(_activeDeity) + " names you."
        if IsFocusedPantheonBoonSuspended()
            return focusedText + " The commitment remains, but its boon is suspended until 50 piety." + contextText
        endIf
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD
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
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if GetNordPantheonBaselineState() == NORD_BASELINE_OLD_WAYS && LedgerRuntime.GetBroadPantheonStanding(LedgerRuntime.BROAD_PANTHEON_NORD_OLD) > 0.0
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

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity
        return "Focused " + GetPublicDeityDisplayName(_activeDeity)
    endIf

    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_BROAD
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return "Broad Nine Divines"
        endIf

        return "Broad Old Ways"
    endIf

    return "Unsettled"
EndFunction

String Function GetCurrentStandingLabel()
    if IsFocusedPantheonBoonSuspended()
        return "Wavering"
    endIf
    Int tierValue = LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = LedgerRuntime.GetTier(_activeDeity)
    elseIf GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        tierValue = GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
    elseIf LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf

    if !_activeDeity && !standingPact && GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        return GetBroadLaneStandingLabel(GetPlayerOriginRaceIndex(), tierValue)
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
    if IsFocusedPantheonBoonSuspended()
        return "Distant"
    endIf
    Int tierValue = LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf _activeDeity
        tierValue = LedgerRuntime.GetTier(_activeDeity)
    elseIf GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex()) > LedgerRuntime.TIER_NONE
        tierValue = GetBroadLaneTierForOrigin(GetPlayerOriginRaceIndex())
    elseIf LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return GetPublicTierBand(tierValue)
EndFunction

Bool Function IsFocusedPantheonBoonSuspended()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace != ORIGIN_IMPERIAL && originRace != ORIGIN_NORD
        return False
    endIf
    return LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity && LedgerRuntime.GetPiety(_activeDeity) < LedgerRuntime.COMMITMENT_OFFER_THRESHOLD
EndFunction

String Function GetPlayerCursePublicLabel()
    if GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
        String altmerCurseLabel = OriginRuntime.GetAltmerCursePublicLabel()
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
        text = text + " You have read the words of the ancestors, and the dead are nearer for it."
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
        ashText = ashText + " The duty hardens you against death and plague, but it cools your welcome among the living (Speech -5)."
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
    Int tradition = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if tradition < 0
        String unchosenText = "You have not yet chosen a tradition. Breton faith takes shape on the Knight's Road, through the Hidden Art, or along the Green Way."
        return unchosenText
    endIf

    String text = ""
    Int practiceTier = GetBretonPracticeTier(tradition)
    String practiceText = " Practice: " + GetPublicTierBand(practiceTier) + "."
    if tradition == 0
        text = "You walk the Knight's Road: vow, mercy, and protective justice." + practiceText
        Int vow = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        if vow >= 70
            text = text + " Your knightly vow is intact."
        elseIf vow >= 30
            text = text + " Your knightly vow is strained, and the Road's favor comes harder."
        else
            text = text + " Your knightly vow is broken, and the Road is halted until you restore it."
        endIf
    elseIf tradition == 1
        text = "You walk the Hidden Art: occult practice and the double life." + practiceText
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
        text = "You walk the Green Way: the old druidic covenant." + practiceText
        Int druidic = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        if druidic >= 70
            text = text + " Y'ffre answers you steadily."
        elseIf druidic < 30
            text = text + " The Green Way is fraying, and the forest begins to forget you."
        else
            text = text + " Y'ffre is listening."
        endIf
    endIf

    text = text + GetBretonPatronSurveySentence(tradition)

    Int fork = GetBretonDruidicForkValue()
    if fork == 1
        text = text + " The beast in you serves the Green, and the old covenant accepts your shape."
    elseIf fork == 2
        text = text + " You claimed the beast for yourself, and the Green has closed against the wolf."
    elseIf fork == 3
        text = text + " The covenant names you betrayer, and the Green presses against the broken trust."
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

    return "no tradition yet"
EndFunction

String Function GetBretonBookOfDaysPathStatusLabel()
    String traditionLabel = GetBretonTraditionLabel()
    Int practiceTier = GetBretonPracticeTier(GetBretonTraditionValue())
    String status = traditionLabel + " Practice " + GetPublicTierBand(practiceTier)

    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
    if activePact
        return status + " / " + NormalizePublicDeityDisplayText(activePact.DeityName) + " Pact"
    endIf

    if _activeDeity && LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE
        return status + " / " + GetPublicDeityDisplayName(_activeDeity) + " Focus"
    endIf

    return status
EndFunction

String Function GetBretonPatronSurveySentence(Int traditionValue)
    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
    if activePact
        String pactName = GetPublicDeityDisplayName(activePact)
        if traditionValue == BRETON_TRADITION_HIDDEN_ART && activePact.GetStoredTier() >= LedgerRuntime.TIER_CHAMPION
            return " Your pact with " + pactName + " has opened Hidden Art - Champion."
        endIf
        return " Your pact with " + pactName + " stands beside the tradition."
    endIf

    if !_activeDeity || LedgerRuntime.GetPatronState() != LedgerRuntime.PATRON_STATE_ACTIVE
        return ""
    endIf

    String deityName = GetPublicDeityDisplayName(_activeDeity)
    Int patronTier = LedgerRuntime.GetTier(_activeDeity)
    if patronTier >= LedgerRuntime.TIER_CHAMPION
        String boonName = GetBretonChampionBoonDisplayName(_activeDeity)
        if IsDeityResonantWithBretonTradition(traditionValue, _activeDeity)
            return " " + deityName + " is your Champion patron through this tradition. " + boonName + " stands beside your practice."
        endIf
        return " " + deityName + " is your Champion patron beyond this tradition. " + boonName + " stands beside your practice."
    endIf

    return " " + deityName + " is your patron focus; your tradition advances through practiced deeds."
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
        return "fraying"
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
        return "a ruptured tradition"
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
    if LedgerRuntime.GetPatronState() == LedgerRuntime.PATRON_STATE_ACTIVE && _activeDeity
        text = GetPublicDeityDisplayName(_activeDeity) + " holds your focus among the Nine. Standing: " + band + ". " + BuildImperialConcordatSurveySentence(concordat)
        if IsFocusedPantheonBoonSuspended()
            text = text + " The commitment remains, but its boon is suspended until 50 piety."
        endIf
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
        text = text + " Civic practice: " + GetImperialCivicTierName() + "."
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

String Function GetImperialCivicTierName()
    if !PDV_ImperialAncestorSubstrate
        return "Civic practice quiet"
    endIf
    Int tierValue = PDV_ImperialAncestorSubstrate.GetSubstrateTier()
    if tierValue >= LedgerRuntime.TIER_CHAMPION
        return "Civic Exemplar"
    elseIf tierValue >= LedgerRuntime.TIER_DEVOTED
        return "Civic Discipline"
    elseIf tierValue >= LedgerRuntime.TIER_SEEKER
        return "Civic Steadiness"
    endIf
    return "Civic practice quiet"
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




String Function GetNordScarLabel()
    if HasNordVampireScar() && !IsNordVampireSuppressed()
        return "The vampire scar still shows. The road is open again, but not unmarked."
    endIf

    return ""
EndFunction

String Function DebugGetPatternProvingSummary()
    String summary = "Concordat=" + GetConcordatSummary()
    summary = summary + "; Bosmer=" + OriginRuntime.GetBosmerSummary()
    summary = summary + "; DunmerAncestor=" + GetDunmerAncestorSummary()
    summary = summary + "; KhajiitLunar=" + OriginRuntime.GetKhajiitLunarSummary()
    summary = summary + "; ArgonianHist=" + OriginRuntime.GetArgonianHistSummary()
    summary = summary + "; Altmer=" + OriginRuntime.GetAltmerSummary()
    summary = summary + "; Orc=" + GetOrcSummary()
    summary = summary + "; Redguard=" + GetRedguardSummary()
    summary = summary + "; Favor=" + FavorRuntime.GetContextualFavorSummary()
    summary = summary + "; Commitment=" + LedgerRuntime.GetCommitmentSummary()
    summary = summary + "; Neglect=" + LedgerRuntime.GetNeglectSummary()
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
        return "Bosmer: " + OriginRuntime.GetBosmerSummary()
    elseIf sectionIndex == 2
        return "Dunmer ancestor: " + GetDunmerAncestorSummary()
    elseIf sectionIndex == 3
        return "Khajiit lunar: " + OriginRuntime.GetKhajiitLunarSummary()
    elseIf sectionIndex == 4
        return "Argonian Hist: " + OriginRuntime.GetArgonianHistSummary()
    elseIf sectionIndex == 5
        return "Altmer: " + OriginRuntime.GetAltmerSummary()
    elseIf sectionIndex == 6
        return "Orc: " + GetOrcSummary()
    elseIf sectionIndex == 7
        return "Redguard: " + GetRedguardSummary()
    elseIf sectionIndex == 8
        return "Favor: " + FavorRuntime.GetContextualFavorSummary()
    elseIf sectionIndex == 9
        return "Commitment: " + LedgerRuntime.GetCommitmentSummary()
    elseIf sectionIndex == 10
        return "Neglect: " + LedgerRuntime.GetNeglectSummary()
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

    return "raw=" + PDV_ConcordatStandingTrack.GetValue() + ";state=" + PDV_ConcordatStandingTrack.GetStateLabel() + ";pending=" + PDV_ConcordatStandingTrack.GetPendingStateLabel() + ";gate=" + gateState + ";track=" + PDV_DevotionRules.FormatTwoDecimals(GetTalosTrackGainMultiplier()) + ";eff=" + PDV_DevotionRules.FormatTwoDecimals(GetTalosEffectiveGainMultiplier())
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




String Function GetDunmerAncestorSummary()
    if !PDV_DunmerAncestorSubstrate
        return "missing"
    endIf

    return PDV_DunmerAncestorSubstrate.GetPilotSummary()
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

    return "mode=" + GetOrcLifeModeLabel() + ";stronghold=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.Stronghold")) + ";city=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.City")) + ";legion=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.LegionExile")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Orc.LastLifeModeReason")
EndFunction

String Function GetRedguardSummary()
    if !PDV_RedguardSectTrack
        return "missing"
    endIf

    return "sect=" + GetRedguardSectLabel() + ";crown=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Crown")) + ";forebear=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Forebear")) + ";ashabah=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.AshAbah")) + ";farShores=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Redguard.LastSectReason")
EndFunction


String Function GetKyneFavorSummary()
    Int maskValue = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ActiveCount")
    return "mask=" + maskValue + ";conds=" + PDV_DevotionRules.CountSetBits(maskValue) + ";active=" + activeCount + ";generic=" + FavorRuntime.GetContextualFavorSummary()
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

    return "deity=" + deity.DeityName + ";state=" + LedgerRuntime.GetPatronStateLabel() + ";active=" + PDV_DevotionRules.BoolToInt(deity == _activeDeity) + ";broad=" + PDV_DevotionRules.BoolToInt(LedgerRuntime.IsBroadWorshipActive()) + ";p=" + PDV_DevotionRules.FormatTwoDecimals(piety) + ";tier=" + LedgerRuntime.GetTier(deity) + ";lastEvent=" + PDV_DevotionRules.FormatTwoDecimals(lastEvent) + ";lastDecayDay=" + lastDecayDay + ";rate=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity)) + ";floor=" + PDV_DevotionRules.FormatTwoDecimals(LedgerRuntime.GetDecayFloorForDeity(deity, piety))
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

    if GetActiveDaedricPactPath()
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
    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
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
    PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
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
        if GetNordPantheonBaselineState() == NORD_BASELINE_NINE_DIVINES
            return 46
        endIf
        return 45
    elseIf origin == ORIGIN_IMPERIAL
        return 47
    elseIf origin == ORIGIN_BRETON
        if GetBretonTraditionValue() == BRETON_TRADITION_GREEN_WAY
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
    Int tierValue = GetBroadLaneTierForOrigin(origin)
    if origin == ORIGIN_IMPERIAL && PDV_ImperialAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, PDV_ImperialAncestorSubstrate.GetSubstrateTier())
    elseIf origin == ORIGIN_BRETON
        tierValue = RecognitionMaxInt(tierValue, GetBretonPracticeTier(GetBretonTraditionValue()))
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

PDV_DaedricPathBase Function GetDaedricPathByName(String deityName)
    if deityName == "Namira" && _kidNamiraPath
        return _kidNamiraPath
    elseIf deityName == "Sanguine" && _kidSanguinePath
        return _kidSanguinePath
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.DeityName == deityName
            if deityName == "Namira"
                _kidNamiraPath = path
            elseIf deityName == "Sanguine"
                _kidSanguinePath = path
            endIf
            return path
        endIf
        i += 1
    endWhile
    return None
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
        PDV_DaedricPathBase namiraPath = GetDaedricPathByName("Namira")
        if namiraPath
            Int tierBefore = namiraPath.GetStoredTier()
            namiraPath.AdjustStoredPiety(1.0 * multiplier, "kid_taboo_food")
            ShowDaedricMilestonePresentation(namiraPath, tierBefore, namiraPath.GetStoredTier(), False)
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
        PDV_DaedricPathBase sanguinePath = GetDaedricPathByName("Sanguine")
        if sanguinePath
            Int tierBefore = sanguinePath.GetStoredTier()
            sanguinePath.AdjustStoredPiety(1.0, "kid_revel")
            ShowDaedricMilestonePresentation(sanguinePath, tierBefore, sanguinePath.GetStoredTier(), False)
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
            ShowDaedricMilestonePresentation(PDV_HircinePath, tierBefore, PDV_HircinePath.GetStoredTier(), False)
            MaybeEmitHircineStigmaPrice(stigmaBefore, PDV_HircinePath.GetStigma())
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
    ReconcileRedguardSpineRewardAfterLoad()
    OriginRuntime.SyncKhajiitRuntimeState()
    Trace(2, "Lifecycle watchdog: manager master poll re-armed on load.")
EndFunction

Function ReconcileRedguardSpineRewardAfterLoad()
    if GetPlayerOriginRaceIndex() != ORIGIN_REDGUARD
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1 && StorageUtil.GetIntValue(None, "PDV.Redguard.SetupComplete") != 1
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    SyncRedguardSpineBoon(playerRef, True, GetActiveRedguardSpineSect())
    RequestPanelRefresh()
    Trace(2, "Redguard spine reward reconciled after player load.")
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
    SyncRedguardRemembering(playerRef)
    ; The live Daedric pact re-grants its boon + price for its stored tier. Idempotent:
    ; the ActivePact pointer is unchanged, so no PendingActivation breadcrumb is left.
    PDV_DaedricPathBase livePact = GetActiveDaedricPactPath()
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
Bool Function GetQrQueueTransactionActive()
    return _qrQueueTransactionActive
EndFunction

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

Function SetQrQueueNeedsCurseRefresh(Bool value)
    _qrQueueNeedsCurseRefresh = value
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



