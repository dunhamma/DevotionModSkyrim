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
PDV_RecognitionRuntime Property RecognitionRuntime Auto
PDV_PrismaPresenter Property Prisma Auto
PDV_DebugRuntime Property DebugRuntime Auto
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
Bool _unifiedStartupChoiceCacheInitialized = False
Bool _unifiedStartupChoiceComplete = False
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
    if DebugRuntime
        DebugRuntime.OriginRuntime = picked
    endIf
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
    Prisma.RequestPanelRefresh()
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
    RecognitionRuntime.EnsureRecognitionModEvents()
    LedgerRuntime.RefreshPatronMirrors()
    FavorRuntime.UpdateContextualFavorRuntime()
    LedgerRuntime.UpdateDisfavorStingRuntime()
    Prisma.EnsureSurveyDevotionPower()
    Prisma.RequestPanelRefresh()
    Prisma.HandleDiegeticLoad("init")
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
        Prisma.HandleDiegeticLoad("update")
    endIf
    DaedricRuntime.ProcessQueuedDaedricMilestonePresentation()
    ProcessQueuedCommitmentOffer()
    OriginRuntime.ProcessQueuedNordKyneChampionEntry()
    ; Keep the exact pending-work order inside the owning module while paying one
    ; cross-script call per tick instead of five.
    DaedricRuntime.ProcessPendingDaedricWork()
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
        Prisma.EnsureSurveyDevotionPower()
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
        ; The modules retain the original probe order. Batching turns seven
        ; manager-to-module calls into two without adding a timer or changing cadence.
        OriginRuntime.ProcessPeriodicContextProbes()
        LedgerRuntime.ProcessPeriodicContentProbes()
    endIf

    if DebugSeedGo != 0
        DebugSeedGo = 0
        DebugRuntime.DebugSeedArgonian(DebugSeedHist, DebugSeedPeople, DebugSeedVoid)

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
; --- Prisma toast size preference (Normal/Large). Large targets 4K displays, where
; even the high-res auto-scaling reads small. Persisted, defaults to Normal. The size
; is injected into every toast payload at the single send choke point below (plus the
; one curse toast that sends directly), so all toast surfaces honour it without each
; builder having to carry the field. ---
; --- Main Prisma panel payload ---
; The focused Prisma panel is player-owned only. Runtime/gameplay refreshes can
; mark data dirty, but only an explicit player request may open or focus it.
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
Bool _diegeticLoadHandled = False
; Dev runtime control for the D1 diegetic surfaces. Flips the director's D1Enabled
; in-session so the visual layer can be previewed/tuned on the current save without an
; ESP edit; the ESP D1Enabled flag is the separate ship-time bake.




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
    if Prisma.PDV_DiegeticDirectorService
        Prisma.PDV_DiegeticDirectorService.D1Enabled = enabled
    endIf
EndFunction

Function ApplyInGameEffectsPreference()
    if Prisma.PDV_DiegeticDirectorService
        Prisma.PDV_DiegeticDirectorService.D1Enabled = InGameEffectsEnabled()
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

; Map a (eventClass, direction) transition to the Book of Days tone key recognized
; by JournalToneToTitle/JournalToneToValence. Most pass through as eventClass.direction
; (tier.reach, curse.onset, neglect.drop, substrate.act); the special cases below
; collapse to the bare tone the title/valence switches know.
; Resolve the in-voice journal line for a transition. Flagship/bespoke voice
; (Khajiit/Dunmer + generic curse/tier authored in the director resolvers) wins;
; otherwise fall back to a templated line. The per-race templated branches are
; expanded by the race routing helpers (see RouteRaceSetupJournal).
; Append the crisp race/curse consequence line the curse toast shows onto the Book of
; Days frame, so the chronicle names werewolf vs vampire specifically instead of only the
; shared frame (e.g. the Altmer "divided self" onset line). Reuses the authored
; GetCurseContextForRace toast copy -- no new strings -- treating a shift into a curse like
; that curse's onset, and de-dups so a frame already carrying the line is left unchanged.
; Symbol for a journal entry: the deity's glyph when the transition belongs to a
; deity, else the generic journal mark.
; --- Devotion dashboard payload (the analytical feedback tool, Today tab) ---
; Per-god rollup (state + recent drivers). Shows the tracked god first (active patron /
; Khajiit emphasis), then only gods in the player's origin roster with movement or
; neglect. Cross-race quest reactions still score, but the panel stays culturally scoped.
; Player-pulled panel content only -- never an auto-push surface. Does NOT expose the
; likes/dislikes table.
; Raw recent-driver entries (newest-last) for one deity. The dashboard aggregates by
; reason client-side; each entry carries its signed delta and gain/loss direction.

; Dedicated 7-slot daily-net ring for the Weekly tab. Kept separate from the driver
; ring (which caps at 6 FIFO entries and can't reliably span 7 days). One write per
; surfaced form per dawn.
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
; --- Quasi-patron helpers ---
; For races whose piety is tracked via substrate/state-track rather than a
; scoring PDV_DeityBase patron, these derive panel identity fields so the
; panel is never blank for non-deity races.
; Returns a short state label to use as tierLabel when there is no scoring patron.
; Uses the same label functions as MCM/Survey so the panel matches those surfaces.
; Compatibility wrapper for any older compiled caller. New book routes call the
; explicit book-read interface below; ambient progress must not use this path.
; A real P2 book read is an explicit player acknowledgement. It remains visible
; through a setup-quiet scope, unlike ambient progress produced during setup.
; Ambient progression may be caused by sleep or automated state reconciliation.
; It uses the same paired delivery but respects the startup quiet scope.
; Private delivery module. Callers choose the semantic interface above instead
; of carrying quiet-presentation policy through every producer.
; Forces a fresh disk re-read of the core matrix and discovered opt-in channels
; into the JsonUtil in-memory cache. Use after regenerating matrix data
; mid-session so already-watched quests pick up newly-authored (form|stage) cells
; without a full reload. Returns a short summary string for the MCM readout.
; NOTE: this refreshes CELL DATA only; brand-new watched quests are (re)registered
; for stage events on the next game load via RefreshP2Hooks.

























; @module: FAVOR-prereq
; Public accessor so extracted modules (FAVOR) can read the active patron deity
; through the manager backref. _activeDeity is a bare script variable written in
; many manager sites; a getter is sufficient because external read-sites only read.
PDV_DeityBase Function GetActiveDeity()
    return _activeDeity
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


; Path-independent variety seed for the debug MCM: clears the Naming/signature
; once-day cooldowns and seeds +3 location discoveries so the Hearth/Naming gates
; are reachable on the CURRENT path without changing it. Wired to the dev-page
; "Seed Bosmer variety" button (RunPatternAction 56).





















; Declare the player's Dunmer ancestor-home from sleep, keyed to the cell rather
; than the bed reference. First homes ask immediately; moving to a new place
; requires three consecutive sleeps in the same non-home cell so a one-night inn
; stop does not steal the rite.


















; Shared daily metric budget for the Khajiit lunar substrate (both lanes draw from
; one pool), mirroring ConsumeBretonPracticePointBudget. Returns the granted metric,
; clamped to the day's remaining budget (0 when exhausted).

; Direct boundary seed for reward/UI proof; explicitly bypasses the daily metric
; budget (mirrors DebugSetBretonPracticePoints).











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


; MCM dev-page seed: cycle Normal -> Strained -> Corrupted -> ShadowDrift -> Normal
; so every Lattice posture readout and message is reachable from the debug page,
; including ShadowDrift (otherwise gated behind sustained night-theft evidence).











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
; Player-facing devotional band per Architecture v3 Section 2.1 (tier vocabulary
; boundary). PLAYER surfaces (Survey, tier-up notice, champion, neglect) use these
; bands; GetCurrentStandingLabel / GetTierStandingLabel keep the internal
; Seeker/Champion words for dev/MCM/code and the separate Daedric path naming.
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
    Prisma.RequestPanelRefresh()
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
; --- P11 (2026-08-04): the recurring ambient layer -------------------------------------------
;
; Until now the mod's ONLY per-deity ambient line was Kyne's, and it lived inside the one-shot
; Champion reward presentation, so it fired once ever. A player who had held Champion for a year
; heard nothing further from the god they had held it with -- the late game went quiet exactly
; where it should have felt most settled.
;
; This is a slow dawn heartbeat: one line per surfacing deity every
; Prisma.AMBIENT_CHAMPION_CADENCE_DAYS devotional days, alternating between two variants, with the
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
; Mode-change line: Nord/Dunmer/Khajiit/Altmer/Imperial/Breton carry a bespoke
; turn-of-the-path line; the rest use a clean templated line. (Per-transition journal
; voice lives in PDV_DiegeticDirector.ResolveJournalLine -- bespoke for Khajiit/Dunmer/
; Imperial/Altmer as of 6g; remaining races use the generic journal fallback.)
; Named-acts dawn digest: names the gods and open Princes fed today (captured before
; piety-today is zeroed). Up to 5 named, then "and others"; falls back to a flavored
; generic line when activity happened but no positive gain was captured.
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
        DebugRuntime.DebugClearActiveDeity()
    elseIf commandId == 2
        DebugRuntime.DebugResetDeityByIndex(deityIndex)
    elseIf commandId == 3
        LedgerRuntime.ForceSetActiveDeityByIndex(deityIndex)
    elseIf commandId == 4
        LedgerRuntime.ForceSetPietyToday(amount)
    elseIf commandId == 5
        LedgerRuntime.ProcessDawn()
    elseIf commandId == 6
        LedgerRuntime.ForceSetPiety(amount)
    elseIf commandId == 7
        DebugRuntime.DebugAwardCuratedSignalByIndex(deityIndex, DebugSignalType)
    elseIf commandId == 8
        DebugRuntime.DebugClosePrismaSurfaces()
    elseIf commandId == 9
        DebugRuntime.DebugSyncRewardsOnly()
    elseIf GetDebugLevel() >= 1
        Debug.Trace("[PDV] RunDebugCommand ignored unknown command " + commandId)
    endIf

    DebugCommand = 0
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
























; Debug: seed the player's race broad-worship lane to its T2 reward so the reward/UI
; surface is testable. Imperial uses the manager-owned broad-pantheon pool directly;
; frozen migration counters are never written. Breton seeds its separate active
; tradition to 50 practice points. This is not pacing proof.














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


; Directly add a domain sting spell + register its expiry the same way
; ApplyDisfavorSting does, so the eyeball check uses the real spell + real expiry.
; Bypasses the standing/repeat/cap gates on purpose (raw MGEF inspection).


; Shared core for the debug sting apply. respectCap reproduces ApplyDisfavorSting's
; active-domain cap so DebugBurstAntiStack can demonstrate the 4th distinct domain
; is suppressed at the cap. Returns True when the sting was applied.

; Clear first, then fire 4 distinct-domain stings (Sky, Death, War, Order) with the
; cap respected, so the tester sees 3 active and the 4th suppressed at the cap.


; One-line readout of every active disfavor domain with its band + remaining
; game-minutes; "none" when empty. Clears expired stings first so the count is live.

; Remove every active disfavor spell + clear its active/expiry/band keys, reusing
; the runtime's own ClearDisfavorDomain so the removal path matches expiry cleanup.

; Debug label helper: does the selected deity dislike this event, at what delta,
; into which domain? Lets the MCM button hint tell the tester whether a fire will land.


; Per-deity recent-driver ring (the acts that recently moved this god), keyed on the
; deity form, capped at 6 FIFO. Powers the dashboard's "recent drivers".

; Map a raw routing/signal tag to a short player-facing driver phrase. Owner rule:
; phrases plainly describe the trigger ("a quest paid in gold"), never flavor copy --
; the deity card header supplies the mood; the row teaches the mechanics.
; Sentinel prefix that flags a reason string as ALREADY player-facing display copy.
; RecordDeityDriver runs every reason through HumanizeDriverReason before storing it;
; a reason carrying this marker is stored verbatim (marker stripped) instead of being
; re-humanized. The bracketed token can never collide with a real routing token
; (routing tokens never start with '['), and it is stripped before storage/display.
; Build the driver-ledger reason for a curated signal: the specific per-signal phrase
; from HumanizeCuratedSignalReason, marked so HumanizeDriverReason keeps it verbatim.
; This is the single wiring point that turns curated awards into distinct, trigger-
; stating Ledger rows instead of the generic "a devotional rite".
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

    LedgerRuntime.SyncRaceRewardSpell(playerRef, Prisma.PDV_SPEL_SurveyDevotion, False, "Prisma.PDV_SPEL_SurveyDevotion")
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




































































































































; --- State-axis debug setters: make focus/tradition/mode-gated Champion blessings
; testable via the standard force-piety + Run Dawn path. Each forces the state axis
; that the matching SyncXxxRewardFamily checks, so the blessing can qualify.

; Forces the Khajiit emergent focus to one moon-path by zeroing the five focus
; weights and seeding the target above the lead threshold, then re-evaluating.


; Forces the Breton tradition (Knight's Road / Hidden Art / Green Way).


; MCM fray-test seed: forces a Green Way / Druidic-fork Breton with DruidicStanding
; one point above the fraying band and the decay day-key cleared, so the next one
; or two ProcessDawn passes drop it past <30 and the Survey/label read "frayed".


; Forces the Orc life mode (City / Stronghold / Legion-Exile).


; Forces the Argonian focus (People / Void) by seeding relations; Void also seeds
; the Sithis activation signals. Reuses DebugSeedArgonian.















; Debug: make the CURRENT origin's race-lane neglect eligible immediately by backdating its
; source-lapse timestamp well past the grace window, then re-syncing so the neglect debuff applies
; without a multi-day real wait. This exists because the source timestamp that the Is<Race>Neglected
; checks read (e.g. PDV.Altmer.Favor.LastGameTime) is only written by an organic favor act -- the
; "Trigger selected favor" debug applies the temporary favor spell but never records that source, so
; there was previously no way to prime a race-lane neglect. Covers the timestamp-lapse lanes; the
; curse/Hist/substrate lanes (Dunmer, Argonian, Imperial) use their own mechanisms and are not primed
; here. Ensure Curse none first (an active curse suppresses several lanes).




























; Form-based twin of DebugSeedCommitmentSignalDaysByIndex. Daedric-path indices do not
; resolve through GetDeityByIndex, so the index seeder misses a Prince; seed by form
; directly to make a path offer-ready.







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


















; ===== Daedric pact-consent debug harness (Sanguine test subject) =====
; Deterministic MCM smoke for the 1.5.0e pact-consent gate. Sanguine is the
; reported-bug subject. Each helper composes existing surfaces -- SetStoredPiety,
; DebugSeedCommitmentSignalDaysByIndex, EvaluateFormalCommitmentOffer, the
; Accept/Decline/Refuse handlers, HandleKIDAction, MigrateDaedricConsentIfNeeded --
; and returns a one-line readback for the MCM to ShowMessage.



; Shared setup: leave Sanguine offer-eligible (Devoted-threshold piety + two recent
; commitment signal-days, offer/refuse flags cleared) with consent withheld and no
; active pact. Preconditions met; the consent latch is the only thing missing.



























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
; Short race-specific context phrase feeds the UI's listText fallback and any
; future per-race voice extension. Kept brief; the lore detail stays in the
; existing modal messages (ShowNordMessage / ShowAltmerMessage).

; Emit a "shift" event when a substrate/state-track mode changes.
; shiftMode = human-readable new state label (e.g. "Khenarthi", "Stronghold")
; context   = optional short phrase (empty is fine; UI templates the rest)
; symbolName = Prisma symbol key; falls back to journal until glyphs land
; Emit a substrate instrument event without making Prisma the gameplay proof lane.
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
    ; This runs on the permanent 1s tick. Reconcile persistent authority once per
    ; load/script update, then stay entirely script-local after completion.
    if _unifiedStartupChoiceComplete
        return
    endIf
    if !_unifiedStartupChoiceCacheInitialized
        _unifiedStartupChoiceCacheInitialized = True
        _unifiedStartupChoiceComplete = StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") == 1
        if _unifiedStartupChoiceComplete
            return
        endIf
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
        _unifiedStartupChoiceComplete = True
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
    _unifiedStartupChoiceComplete = True
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
    _unifiedStartupChoiceComplete = True
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

; ---------------------------------------------------------------------------
; Book of Days journal payload
; ---------------------------------------------------------------------------

; Map an in-game day integer to a Tamriel fiction date string.
; Tamriel has 12 months of 30 days each.
; Build the Book of Days journal JSON payload.
; Entries are ordered oldest-first (index 0 = oldest, last index = newest).
; --- Book of Days writer ---
; Appends one dated entry to the ring lists BuildJournalPayloadJson renders
; (oldest-first). Tone MUST be a key JournalToneToTitle/JournalToneToValence
; recognize, or the entry renders without a title/valence. headlinePinned entries
; are exempt from the day-window prune so curse/Champion/major-switch beats persist.
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
; Remove one entry across all Book of Days lists at the same index.
; RefreshOpenBookOfDays was retired 2026-08-07. It reconciled a stale "PDV.Diegetic.Journal.Open"
; flag against PDV_PrismaBridge.IsJournalVisible(), but PDV_MCM's journal-hotkey OnKeyDown already
; does exactly that inline, at the only moment the answer is consumed -- so it was a superseded
; duplicate with no caller, and three gates asserted on its NAME rather than on the behaviour.
; Those gates now assert the reconciliation against PDV_MCM.psc. Do not re-add a periodic variant:
; a tick that re-checks state already reconciled for free at the consumption point is pure cost.

; Short title derived from the tone/event key.
; Map the journal tone/event key to an accessible valence the UI renders as a
; direction mark + tag + color spine: good / warning / neutral. Color is never the
; only cue (the mark direction and tag word carry it for color-blind readers).
; Send the Book of Days journal to Prisma as a player-opened modal.
; Close the Book of Days overlay (hotkey toggle / second press). The journal view
; is a NON-FOCUSED overlay, so there is no in-view button click to rely on -- the
; close is driven from Papyrus by sending the {"journalClose":true} signal that
; app.js handleOverlayPayload already consumes (hides the journal modal). Uses the
; unfocused overlay channel, never the focused panel, so no input trap.
; Roster-display entry for a LIVE native patron: shows the god as real and worshippable, but NOT
; directly selectable -- commitment happens through the organic offer, not a medallion pick (owner
; ruling 2026-06-27: medallion is a roster display, the offer is the commit path). Falls back to the
; pending "awaiting a record" message only when the deity record is not actually live.
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
; Builds a full dev-facing devotion snapshot and writes it to a text file so
; beta testers can attach one file to a bug report instead of digging for logs
; or numbers. Returns the written filename, or "" if the write failed.
String Function GetBuildVersion()
    return PDV_BUILD_VERSION
EndFunction

String Function GetStartupMcmLine()
    Int originRace = GetPlayerOriginRaceIndex()
    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
            return "Choose a starting path, then confirm."
        endIf
        return "Set: " + Prisma.GetPlayerMcmModeLine()
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction

; Player-facing devotional band for the active standing (Architecture v3 Section 2.1),
; mirroring GetCurrentStandingLabel's tier resolution. Survey + player surfaces use this;
; GetCurrentStandingLabel keeps the internal Seeker/Champion words for dev/MCM only.
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



































; One labeled pattern-summary section by index (0-13), so the MCM can page the
; readout instead of dumping all 14 into a single overflowing message box.


; Total number of pattern-summary sections (for MCM pagination bounds).


; Maps an origin race to its dedicated pattern-summary section index, or -1 when
; the race has no race-specific section (Nord/Imperial/Breton live in the globals).


































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

; ===========================================================================
; KID item-action routing
; ===========================================================================

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

    Prisma.SendPrismaToast(symbolName, "good", titleText, bodyText, True)
    Prisma.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "favor.act", symbolName, False, 1, titleText)
    Prisma.RequestPanelRefresh()
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
    RecognitionRuntime.EnsureRecognitionModEvents()
    RecognitionRuntime.InvalidateNpcReligiousRecognition()
    RecognitionRuntime.SyncNpcReligiousRecognition()
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

Function SetPanelDirty(Bool value)
    _panelDirty = value
EndFunction

Bool Function GetDiegeticLoadHandled()
    return _diegeticLoadHandled
EndFunction

Function SetDiegeticLoadHandled(Bool value)
    _diegeticLoadHandled = value
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








