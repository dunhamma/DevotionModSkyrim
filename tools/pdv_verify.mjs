#!/usr/bin/env node
/*
 * Read-only verifier for the PlayerDevotion Anvil/MO2 development setup.
 *
 * The verifier checks disk files directly and asks the bundled MO2 MCP
 * Mutagen bridge to read Devotion.esp. It does not modify
 * the ESP, MO2 profile files, scripts, or generated output.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import net from "node:net";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { verifyPhase21RosterCoverage } from "./lib/pdv-roster-coverage.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const DEVOTION_SOURCE = path.join(DEVOTION_MOD, "Scripts", "Source");
const DEVOTION_PEX = path.join(DEVOTION_MOD, "Scripts");
const CUSTOM_RACE_DATA_DIR = path.join(DEVOTION_MOD, "SKSE", "Plugins", "StorageUtilData", "PlayerDevotion");
const REPO_CUSTOM_RACE_DATA_DIR = path.join(PROJECT_ROOT, "SKSE", "Plugins", "StorageUtilData", "PlayerDevotion");
const CUSTOM_RACE_MAP = path.join(REPO_CUSTOM_RACE_DATA_DIR, "PDV_RaceMap.json");
const CUSTOM_TEMPORARY_RACE_MAP = path.join(REPO_CUSTOM_RACE_DATA_DIR, "PDV_TemporaryRaceMap.json");
const CUSTOM_RACE_README = path.join(REPO_CUSTOM_RACE_DATA_DIR, "PDV_RaceMap_README.txt");
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const MUTAGEN_BRIDGE_MAX_BUFFER = 128 * 1024 * 1024;
const MO2_INI = path.join(ANVIL_ROOT, "ModOrganizer.ini");
const DEV_PROFILE = path.join(ANVIL_ROOT, "profiles", "Devotion Dev");
const DEV_PROFILE_PLUGINS = path.join(DEV_PROFILE, "plugins.txt");
const DEV_PROFILE_LOADORDER = path.join(DEV_PROFILE, "loadorder.txt");
const CK_OUTPUT = path.join(ANVIL_ROOT, "mods", "Anvil - Creation Kit Output");
const XEDIT_SEQ = path.join(
  ANVIL_ROOT,
  "mods",
  "Anvil - xEdit Output",
  "Seq",
  "Devotion.seq",
);
const DEVOTION_SEQ = path.join(DEVOTION_MOD, "Seq", "Devotion.seq");
const SLICE1_SIGNAL_RECEIVER_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Slice1SignalReceivers.manifest.json",
);
const PHASE7_SIGNAL_RECEIVER_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase7SignalReceivers.manifest.json",
);
const PHASE8_CONCORDAT_TALOS_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase8ConcordatTalos.manifest.json",
);
const PHASE9_BOSMER_STATE_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase9BosmerState.manifest.json",
);
const PHASE11_PRIVILEGE_PILOT_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase11PrivilegePilot.manifest.json",
);
const PHASE12_CONTEXTUAL_FAVOR_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase12ContextualFavorPilot.manifest.json",
);
const PHASE13_DAEDRIC_HIRCINE_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase13DaedricHircinePilot.manifest.json",
);
const PHASE14_COMMITMENT_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase14CommitmentPilot.manifest.json",
);
const PHASE15_CURSE_OVERLAY_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase15CurseOverlay.manifest.json",
);
const PHASE16_NEGLECT_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase16NeglectPilot.manifest.json",
);
const PHASE17_DECAY_MODEL_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase17DecayModel.manifest.json",
);
const PHASE18_STATUS_NORD_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase18StatusNord.manifest.json",
);
const PHASE20_DEITY_COVERAGE_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_DeityCoverageMatrix.json",
);
const PHASE20_MEDALLION_ROSTER_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_MedallionRoster.manifest.json",
);
const PHASE20_ALTMER_IMPLEMENTATION_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20AltmerImplementationCosting.manifest.json",
);
const PHASE20_RACE_IMPLEMENTATION_MANIFESTS = [
  PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
  path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase20ArgonianImplementationCosting.manifest.json"),
  path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase20OrcImplementationCosting.manifest.json"),
  path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase20RedguardImplementationCosting.manifest.json"),
  path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json"),
  path.join(PROJECT_ROOT, "references", "authoring", "PDV_Phase20KhajiitImplementationCosting.manifest.json"),
];
const DEITY_LIKES_DISLIKES_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DeityLikesDislikes.csv");
const PRINCE_LIKES_DISLIKES_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DeityLikesDislikes_Princes_V2.csv");
const EXPECTED_LIKES_DISLIKES_VERSION = 10;
const EXPECTED_PRINCE_LD_VERSION = 3;
const PHASE20_NO_IN_GAME_PROOF_GATES = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20_NoInGameProof_Gates.json",
);
const PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20_P2ImmersiveReceivers.manifest.json",
);
const PHASE20_REWARD_RECORD_CONTRACTS = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20_RewardRecordContracts.json",
);
const SHRINE_BLESSING_NEUTRALIZATION_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_ShrineBlessingNeutralization.manifest.json",
);
const PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20_ContentHook_ClaudeReviewPacket.md",
);
const CAT6_PROMOTION_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_CAT6PromotionPilot.manifest.json",
);
const PHASE20_MANUAL_EVIDENCE_LEDGER = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_Phase20_ManualEvidenceLedger.json",
);
const RACE_CONTENT_MANIFEST = path.join(
  PROJECT_ROOT,
  "race-sheets",
  "PDV_RaceContent_Manifest.md",
);
const PATCH_RULES_DIR = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "patch-rules",
);
const PHASE19_GENERATED_PATCH = path.join(DEVOTION_MOD, "PDV_ClassificationPatch.esp");
const PHASE19_PROOF_RULE_MANIFEST = path.join(PATCH_RULES_DIR, "PDV_Phase19ProofRules.json");
const PHASE19_TEMPLE_RULE_MANIFEST = path.join(PATCH_RULES_DIR, "PDV_Phase19TempleLocationRules.json");
const PHASE19_PROOF_BOOK_FORMID = "Skyrim.esm:0FBA57";
const PHASE19_PROOF_BOOK_KEYWORD = "Skyrim.esm:01CD56";
const PHASE19_PROOF_STATE_LIST_FORMID = "Devotion.esp:0499DB";
const PHASE19_PROOF_STATE_TRACK_FORMID = "Devotion.esp:07051C";
const SKYRIM_ESM = path.join(ANVIL_ROOT, "Stock Game", "Data", "Skyrim.esm");
const DAWNGUARD_ESM = path.join(ANVIL_ROOT, "mods", "Cleaned Base Game Masters", "Dawnguard.esm");
const PHASE19_TEMPLE_KEYWORD = "Skyrim.esm:01CD56";
const PHASE19_TEMPLE_LOCATION_RECORDS = [
  {
    edid: "DLC1FalmerValleyTempleLocation",
    formid: "Dawnguard.esm:01379F",
    sourcePlugin: "Dawnguard.esm",
    sourcePath: DAWNGUARD_ESM,
  },
  {
    edid: "MarkarthShrineofTalosLocation",
    formid: "Skyrim.esm:06E830",
    sourcePlugin: "Skyrim.esm",
    sourcePath: SKYRIM_ESM,
  },
  {
    edid: "ShrineofAzuraLocation",
    formid: "Skyrim.esm:092497",
    sourcePlugin: "Skyrim.esm",
    sourcePath: SKYRIM_ESM,
  },
  {
    edid: "ShrineofBoethiahLocation",
    formid: "Skyrim.esm:0F5BA7",
    sourcePlugin: "Skyrim.esm",
    sourcePath: SKYRIM_ESM,
  },
  {
    edid: "ShrineofMehrunesDagonLocation",
    formid: "Skyrim.esm:0240E6",
    sourcePlugin: "Skyrim.esm",
    sourcePath: SKYRIM_ESM,
  },
  {
    edid: "ShrineofPeryiteLocation",
    formid: "Skyrim.esm:0F5BA5",
    sourcePlugin: "Skyrim.esm",
    sourcePath: SKYRIM_ESM,
  },
];
const MANAGER_PATRON_WIRE_PATCH = "PDV_ManagerPatronWirePatch.esp";
const MCM_WIRE_PATCH = "PDV_MCMWirePatch.esp";
const RETIRED_OVERLAY_PATCHES = [MANAGER_PATRON_WIRE_PATCH, MCM_WIRE_PATCH];
const CANONICAL_PROPERTY_WIRING_PATCH = "PDV_PropertyWiringOverlay.esp";
const PREFLIGHT_ROUTER_OVERLAY_PATCH = "PDV_PreflightRouterServicesOverlay.esp";
const PHASE8_CONCORDAT_TALOS_OVERLAY_PATCH = "PDV_Phase8ConcordatTalosOverlay.esp";
const ONE_OFF_AUTHOR_PATCH_PREFIX = "PDV_Author_one_off_";
const MO2_MCP_HOST = "127.0.0.1";
const MO2_MCP_PORT = 27016;

const BASELINE_RECORDS = {
  PDV_GLO_OriginRace: "GLOB",
  PDV_GLO_PatronDeity: "GLOB",
  PDV_GLO_ActivePiety: "GLOB",
  PDV_GLO_ActiveTier: "GLOB",
  PDV_GLO_ActiveDeityIndex: "GLOB",
  PDV_GLO_DebugLevel: "GLOB",
  PDV__MainQuest: "QUST",
  PDV_Origin: "QUST",
  PDV__ManagerQuest: "QUST",
  PDV_Deity_Kyne: "QUST",
  PDV_Deity_Talos: "QUST",
  PDV_Deity_AuriEl: "QUST",
  PDV_FLST_AllDeities: "FLST",
  PDV_MCM: "QUST",
};

const PHASE3_RECORDS = {
  PDV_ActionRouter: "QUST",
  PDV__SM_KillActor: "QUST",
  PDV__SM_CraftItem: "QUST",
  PDV__SM_NewVoicePower: "QUST",
  PDV__SM_IncreaseSkill: "QUST",
  PDV__SM_ChangeLocation: "QUST",
  PDV__SM_PickLock: "QUST",
  PDV__SM_Trespass: "QUST",
  PDV__SM_AssaultActor: "QUST",
};

const PREFLIGHT_RECORDS = {
  PDV_GLO_PatronState: "GLOB",
  PDV_EventTypes: "QUST",
  PDV_EventBus: "QUST",
};

const PHASE9_RECORDS = {
  PDV_GLO_BosmerPath: "GLOB",
  PDV_StateTrack_BosmerPath: "QUST",
  PDV_Deity_Yffre: "QUST",
  PDV_Deity_Zen: "QUST",
  PDV_Deity_BaanDar: "QUST",
  PDV_MSG_BosmerSetupChoice: "MESG",
  PDV_MSG_BosmerSuggestLivingStory: "MESG",
  PDV_MSG_BosmerSuggestExchange: "MESG",
  PDV_MSG_BosmerSuggestBanditRoad: "MESG",
  PDV_MSG_BosmerSuggestOldContract: "MESG",
  PDV_MSG_BosmerReckoning: "MESG",
};

const PHASE18_RECORDS = {
  PDV_MGEF_SurveyDevotion: "MGEF",
  PDV_SPEL_SurveyDevotion: "SPEL",
  PDV_Msg_Nord_CurseState_WerewolfOnset: "MESG",
  PDV_Msg_Nord_CurseState_VampireOnset: "MESG",
  PDV_Msg_Nord_CurseState_VampireCured: "MESG",
};

const PHASE18_MANAGER_PROPERTIES = {
  PDV_SPEL_SurveyDevotion: "PDV_SPEL_SurveyDevotion",
  PDV_Msg_Nord_CurseState_WerewolfOnset: "PDV_Msg_Nord_CurseState_WerewolfOnset",
  PDV_Msg_Nord_CurseState_VampireOnset: "PDV_Msg_Nord_CurseState_VampireOnset",
  PDV_Msg_Nord_CurseState_VampireCured: "PDV_Msg_Nord_CurseState_VampireCured",
};

const PHASE18_EFFECT_PROPERTIES = {
  PDV_Manager: "PDV__ManagerQuest",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const PHASE18_NORD_DIALOGUE_CONTRACTS = [
  {
    id: "froki-kyne-champion",
    branch: "PDV_DIAL_Nord_Froki_KyneChampionBranch",
    topic: "PDV_TIF_Nord_Froki_KyneChampion",
    speaker: "Froki",
    speakerFormid: "Skyrim.esm:0185F6",
    prompt: "I sleep where Kyne sleeps. I hunt where she hunts.",
    response: "Then you know the old wind. Do not let temple smoke blind you.",
    gates: [
      { global: "PDV_GLO_OriginRace", op: "EqualTo", value: 0, label: "Nord origin" },
      { global: "PDV_GLO_ActiveDeityIndex", op: "EqualTo", value: 0, label: "active Kyne" },
      { global: "PDV_GLO_ActiveTier", op: "GreaterThanOrEqualTo", value: 3, label: "Champion tier" },
    ],
  },
  {
    id: "heimskr-talos-champion",
    branch: "PDV_DIAL_Nord_Heimskr_TalosChampionBranch",
    topic: "PDV_TIF_Nord_Heimskr_TalosChampion",
    speaker: "Heimskr",
    speakerFormid: "Skyrim.esm:013BAC",
    prompt: "The old breath is mine to carry. Tell me what is needed.",
    response: "Then let the cowards hear it. Talos needs no quiet servants.",
    gates: [
      { global: "PDV_GLO_OriginRace", op: "EqualTo", value: 0, label: "Nord origin" },
      { global: "PDV_GLO_ActiveDeityIndex", op: "EqualTo", value: 1, label: "active Talos" },
      { global: "PDV_GLO_ActiveTier", op: "GreaterThanOrEqualTo", value: 3, label: "Champion tier" },
    ],
  },
  {
    id: "andurs-broad-death-rite",
    branch: "PDV_DIAL_Nord_Andurs_DeathRiteBranch",
    topic: "PDV_TIF_Nord_Andurs_DeathRite",
    speaker: "Andurs",
    speakerFormid: "Skyrim.esm:013BA8",
    prompt: "I keep the rites. What is owed the dead here?",
    response: "A name, a prayer, and clean hands. That is more than many give.",
    gates: [
      { global: "PDV_GLO_OriginRace", op: "EqualTo", value: 0, label: "Nord origin" },
      { global: "PDV_GLO_PatronState", op: "EqualTo", value: 1, label: "broad patron state" },
      { global: "PDV_GLO_CurseState", op: "NotEqualTo", value: 2, label: "not vampire" },
    ],
  },
  {
    id: "aela-hircine-tension",
    branch: "PDV_DIAL_Nord_Aela_HircineTensionBranch",
    topic: "PDV_TIF_Nord_Aela_HircineTension",
    speaker: "Aela",
    speakerFormid: "Skyrim.esm:01A696",
    prompt: "The hunt pulls at Sovngarde. What do you see in me?",
    response: "I see someone standing between the hall and the hunt. Choose well.",
    gates: [
      { global: "PDV_GLO_OriginRace", op: "EqualTo", value: 0, label: "Nord origin" },
      { global: "PDV_GLO_CurseState", op: "EqualTo", value: 1, label: "werewolf curse state" },
    ],
  },
];

const PHASE18_SYSTEM_RUNTIME_CASES = [
  "player-surface-fresh-nord",
  "developer-options-persistence",
  "survey-broad-old-ways",
  "survey-broad-nine-divines",
  "survey-focused-kyne",
  "survey-focused-talos",
  "hircine-werewolf-tension",
  "nord-vampire-suppression",
  "nord-vampire-cure-scar",
  "save-load-persistence",
];

const PHASE18_DIALOGUE_RUNTIME_CASES = [
  "froki-kyne-champion",
  "heimskr-talos-champion",
  "andurs-broad-death-rite",
  "aela-hircine-tension",
];

const SKELETON_REPUTATION_TRACKS = [
  "ConcordatStanding",
  "ThalmorAlignment",
  "WitchcraftExposure",
  "KnightlyVowIntegrity",
  "DruidicStanding",
];

const SKELETON_STATE_TRACKS = [
  "BosmerPath",
  "OrcLifeMode",
  "NordWorship",
  "BretonTradition",
  "RedguardSect",
  "DunmerPath",
  "AltmerCrisis",
];

const SKELETON_FORMLISTS = {
  PDV_FLST_RepTracks_All: "FLST",
  PDV_FLST_RepTracks_DevOnly: "FLST",
  PDV_FLST_StateTracks_All: "FLST",
  PDV_FLST_StateTracks_DevOnly: "FLST",
  PDV_FLST_Substrates_All: "FLST",
  PDV_FLST_Substrates_DevOnly: "FLST",
  PDV_FLST_SacredPlaces_All: "FLST",
  PDV_FLST_SacredPlaces_DevOnly: "FLST",
  PDV_FLST_DaedricPaths_All: "FLST",
  PDV_FLST_DaedricPaths_DevOnly: "FLST",
};

const SKELETON_TRACK_DEFINITIONS = [
  ...SKELETON_REPUTATION_TRACKS.map((name) => ({
    name,
    type: "rep",
    questEdid: `PDV_RepTrack_${name}`,
    scriptName: "PDV_ReputationTrack",
    globalEdid: `PDV_GLO_${name}`,
    globalPropertyName: "StorageBacking",
  })),
  ...SKELETON_STATE_TRACKS.map((name) => ({
    name,
    type: "state",
    questEdid: `PDV_StateTrack_${name}`,
    scriptName: "PDV_StateTrack",
    globalEdid: `PDV_GLO_${name}`,
    globalPropertyName: "StateGlobal",
  })),
];

const SKELETON_SUBSTRATE_DEFINITIONS = [
  {
    questEdid: "PDV_Substrate_KhajiitLunar",
    scriptName: "PDV_SubstrateBase",
    substrateName: "KhajiitLunar",
    requiredOriginRace: 6,
  },
  {
    questEdid: "PDV_Substrate_DunmerAncestor",
    scriptName: "PDV_SubstrateBase",
    substrateName: "DunmerAncestor",
    requiredOriginRace: 5,
  },
  {
    questEdid: "PDV_Substrate_ArgonianHist",
    scriptName: "PDV_SubstrateBase",
    substrateName: "ArgonianHist",
    requiredOriginRace: 7,
  },
  {
    questEdid: "PDV_Substrate_NordAncestor",
    scriptName: "PDV_SubstrateBase",
    substrateName: "NordAncestor",
    requiredOriginRace: 0,
  },
  {
    questEdid: "PDV_Substrate_AltmerAncestor",
    scriptName: "PDV_SubstrateBase",
    substrateName: "AltmerAncestor",
    requiredOriginRace: 3,
  },
  {
    questEdid: "PDV_Substrate_BretonAncestor",
    scriptName: "PDV_SubstrateBase",
    substrateName: "BretonAncestor",
    requiredOriginRace: 2,
  },
  {
    questEdid: "PDV_Substrate_ImperialAncestor",
    scriptName: "PDV_SubstrateBase",
    substrateName: "ImperialAncestor",
    requiredOriginRace: 1,
  },
];

const SKELETON_SACRED_PLACE_DEFINITIONS = [
  {
    questEdid: "PDV_SacredPlace_ArgonianBedOfChoice",
    scriptName: "PDV_SacredPlace",
    placeName: "ArgonianBedOfChoice",
    requiredOriginRace: 7,
    maxLocations: 1,
  },
  {
    questEdid: "PDV_SacredPlace_KhajiitRoadHomes",
    scriptName: "PDV_SacredPlace",
    placeName: "KhajiitRoadHomes",
    requiredOriginRace: 6,
    maxLocations: 3,
  },
  {
    questEdid: "PDV_SacredPlace_OrcCommunity",
    scriptName: "PDV_SacredPlace",
    placeName: "OrcCommunity",
    requiredOriginRace: 8,
    maxLocations: 1,
  },
];

const SKELETON_DAEDRIC_PATH_DEFINITIONS = [
  {
    questEdid: "PDV_DaedricPath_Hircine",
    scriptName: "PDV_DaedricPathBase",
    deityName: "Hircine",
    deityDomain: "Hunt, Lycanthropy, Predation",
    deityIndex: 100,
    stigmaGlobalEdid: "PDV_GLO_HircineStigma",
    commitmentSignalsRequired: 3,
  },
];

const SKELETON_SERVICE_DEFINITIONS = [
  {
    questEdid: "PDV_CurseState",
    scriptName: "PDV_CurseState",
    globalPropertyName: "PDV_GLO_CurseState",
    globalEdid: "PDV_GLO_CurseState",
  },
];

const SLICE1_SIGNAL_RECEIVER_DEFINITIONS = [
  {
    recordEdid: "PDV_ACTI_DunmerPortableShrineSignal",
    recordType: "ACTI",
    scriptName: "PDV_EventSignalActivator",
    routeId: 30,
    requiredOriginRace: 5,
  },
  {
    recordEdid: "PDV_ACTI_DunmerPrivateShrineSignal",
    recordType: "ACTI",
    scriptName: "PDV_EventSignalActivator",
    routeId: 31,
    requiredOriginRace: 5,
  },
  {
    recordEdid: "PDV_MGEF_BosmerGreenPactViolationSignal",
    recordType: "MGEF",
    scriptName: "PDV_EventSignalEffect",
    routeId: 32,
    requiredOriginRace: 4,
  },
  {
    recordEdid: "PDV_ACTI_HircineHuntRiteSignal",
    recordType: "ACTI",
    scriptName: "PDV_EventSignalActivator",
    routeId: 34,
    requiredOriginRace: -1,
  },
];

const PHASE10_DUNMER_SIGNAL_RECEIVER_DEFINITIONS = SLICE1_SIGNAL_RECEIVER_DEFINITIONS.filter((definition) =>
  definition.recordEdid === "PDV_ACTI_DunmerPortableShrineSignal"
    || definition.recordEdid === "PDV_ACTI_DunmerPrivateShrineSignal"
).map((definition) => ({
  ...definition,
  expectedOncePerDayKey: definition.recordEdid === "PDV_ACTI_DunmerPortableShrineSignal"
    ? "PDV.Signal.DunmerPortableShrine.Activator"
    : "PDV.Signal.DunmerHome.Activator",
}));

const KHAJIIT_FOCUSED_EMPHASIS_GLOBAL = "PDV_GLO_KhajiitFocusedEmphasis";
const KYNE_NEGLECT_MAGIC_EFFECT = "PDV_MGEF_Neglect_Kyne";
const KYNE_NEGLECT_SPELL = "PDV_SPEL_Neglect_Kyne";
const PHASE11_ARNGEIR_BRANCH = "PDV_DIAL_Phase11ArngeirKyneRecognitionBranch";
const PHASE11_ARNGEIR_TOPIC = "PDV_DIAL_Phase11ArngeirKyneRecognitionTopic";
const PHASE11_ARNGEIR_INFO = "PDV_INFO_Phase11ArngeirKyneRecognition";
const PHASE11_ARNGEIR_INFO_FORMID = "Devotion.esp:0704F4";
const PHASE11_ARNGEIR_NPC_FORMID = "Skyrim.esm:02C6C7";
const PHASE11_ARNGEIR_PROMPT = "Has Kyne marked my path?";
const PHASE11_ARNGEIR_LINE = "The wind has marked you, Dragonborn. Walk with Kyne's breath.";

const PHASE7_SIGNAL_RECEIVER_DEFINITIONS = [
];

const PHASE7_RETIRED_SIGNAL_RECEIVER_DEFINITIONS = [
  {
    recordEdid: "PDV_REFR_TalosShrineDefianceSignal",
    recordType: "REFR",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; do not reattach PDV scripts to the visible vanilla shrine reference 10753E:Skyrim.esm",
  },
];

const PHASE9_SIGNAL_RECEIVER_DEFINITIONS = [
];

const PHASE9_RETIRED_SIGNAL_RECEIVER_DEFINITIONS = [
  {
    recordEdid: "PDV_ACTI_BosmerLivingStorySignal",
    recordType: "ACTI",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; Phase 9 proof activators must not be placed in live Windhelm spaces",
  },
  {
    recordEdid: "PDV_ACTI_BosmerExchangeSignal",
    recordType: "ACTI",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; Phase 9 proof activators must not be placed in live Windhelm spaces",
  },
  {
    recordEdid: "PDV_ACTI_BosmerBanditRoadSignal",
    recordType: "ACTI",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; Phase 9 proof activators must not be placed in live Windhelm spaces",
  },
  {
    recordEdid: "PDV_ACTI_BosmerPactPositiveSignal",
    recordType: "ACTI",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; Phase 9 proof activators must not be placed in live Windhelm spaces",
  },
  {
    recordEdid: "PDV_ACTI_StateTransitionConfirmRite",
    recordType: "ACTI",
    reason: "retired after 2026-06-16 Windhelm visual cleanup; Phase 9 proof activators must not be placed in live Windhelm spaces",
  },
];

const COMPILED_SCRIPTS = {
  PDV__MainQuest: "required",
  PDV_Origin: "required",
  PDV__ManagerQuest: "required",
  PDV_DeityBase: "required",
  PDV_Deity_Kyne: "required",
  PDV_Deity_Talos: "required",
  PDV_Deity_AuriEl: "required",
  PDV_Deity_Yffre: "required",
  PDV_Deity_Zen: "required",
  PDV_Deity_BaanDar: "required",
  PDV_EventTypes: "required",
  PDV_EventBus: "required",
  PDV_FragmentBridge: "required",
  PDV_EventSignalActivator: "required",
  PDV_EventSignalEffect: "required",
  PDV_PlayerEvents: "required",
  PDV_ReputationTrack: "required",
  PDV_StateTrack: "required",
  PDV_SubstrateBase: "required",
  PDV_SacredPlace: "required",
  PDV_DaedricPathBase: "required",
  PDV_CurseState: "required",
  PDV_Substrate_DunmerAncestor: "required",
  PDV_Substrate_KhajiitLunar: "required",
  PDV_Substrate_ArgonianHist: "required",
  PDV_Substrate_NordAncestor: "required",
  PDV_Substrate_AltmerAncestor: "required",
  PDV_Substrate_BretonAncestor: "required",
  PDV_Substrate_ImperialAncestor: "required",
  PDV_DaedricPath_Hircine: "required",
  PDV_ActionRouter: "phase3",
  PDV__SM_KillActor: "phase3",
  PDV__SM_CraftItem: "phase3",
  PDV__SM_NewVoicePower: "phase3",
  PDV__SM_IncreaseSkill: "phase3",
  PDV__SM_ChangeLocation: "phase3",
  PDV__SM_PickLock: "phase3",
  PDV__SM_Trespass: "phase3",
  PDV__SM_AssaultActor: "phase3",
  PDV_SurveyDevotionEffect: "required",
  PDV_MCM: "required",
};

const MANAGER_PROPERTIES = {
  PDV_GLO_ActivePiety: "PDV_GLO_ActivePiety",
  PDV_GLO_ActiveTier: "PDV_GLO_ActiveTier",
  PDV_GLO_ActiveDeityIndex: "PDV_GLO_ActiveDeityIndex",
  PDV_GLO_PatronDeity: "PDV_GLO_PatronDeity",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
};

const MANAGER_PREFLIGHT_PROPERTIES = {
  PDV_GLO_PatronState: "PDV_GLO_PatronState",
};

const MAINQUEST_PROPERTIES = {
  PDV_OriginQuest: "PDV_Origin",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const ORIGIN_PROPERTIES = {
  PDV_GLO_OriginRace: "PDV_GLO_OriginRace",
  PDV_Manager: "PDV__ManagerQuest",
  PDV_Kyne: "PDV_Deity_Kyne",
  PDV_Talos: "PDV_Deity_Talos",
  PDV_AuriEl: "PDV_Deity_AuriEl",
  PlayerRef: null,
  NordRace: null,
  ImperialRace: null,
  BretonRace: null,
  HighElfRace: null,
  WoodElfRace: null,
  DarkElfRace: null,
  KhajiitRace: null,
  ArgonianRace: null,
  OrcRace: null,
  RedguardRace: null,
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const KYNE_EXPECTED_DATA = {
  DeityName: "Kyne",
  DeityDomain: "Storms, Hunt, Warriors' Spirit",
  DeityIndex: 0,
  ThresholdSeeker: 25,
  ThresholdDevoted: 50,
  ThresholdChampion: 85,
  IsAedric: true,
  Stance_Nord: 0,
  Stance_Imperial: 1,
  Stance_Breton: 1,
  Stance_Altmer: 1,
  Stance_Bosmer: 1,
  Stance_Dunmer: 1,
  Stance_Khajiit: 1,
  Stance_Argonian: 1,
  Stance_Orc: 1,
  Stance_Redguard: 1,
};

const ROUTER_PROPERTIES = {
  PDV_Manager: "PDV__ManagerQuest",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
  PlayerRef: null,
  ActorTypeNPC: null,
  ActorTypeAnimal: null,
  ActorTypeCreature: null,
};

const ROUTER_GENERIC_FAUCET_PROPERTIES = {
  ActorTypeUndead: "Skyrim.esm:013796",
  ActorTypeDaedra: "Skyrim.esm:013797",
  ActorTypeDragon: "Skyrim.esm:035D59",
  PDV_FLST_FaucetSkillBooks: "PDV_FLST_FaucetSkillBooks",
  PDV_FLST_FaucetSpellTomes: "PDV_FLST_FaucetSpellTomes",
  CraftingSmithingArmorTable: "Skyrim.esm:0ADB78",
  CraftingSmithingForge: "Skyrim.esm:088105",
  CraftingSmithingSharpeningWheel: "Skyrim.esm:088108",
  CraftingSmithingSkyforge: "Skyrim.esm:0F46CE",
  CraftingCookpot: "Skyrim.esm:0A5CB3",
  isAlchemy: "Skyrim.esm:02A40B",
  isEnchanting: "Skyrim.esm:06E2A3",
};

const PLAYER_EVENTS_GENERIC_FAUCET_PROPERTIES = {
  PDV_FLST_FaucetSkillBooks: "PDV_FLST_FaucetSkillBooks",
  PDV_FLST_FaucetSpellTomes: "PDV_FLST_FaucetSpellTomes",
  PDV_FLST_FaucetDaedricArtifacts: "PDV_FLST_FaucetDaedricArtifacts",
  PDV_FLST_FaucetRaiseUndeadEffects: "PDV_FLST_FaucetRaiseUndeadEffects",
};

const STORY_MANAGER_RECEIVER_SCRIPTS = [
  "PDV__SM_KillActor",
  "PDV__SM_CraftItem",
  "PDV__SM_NewVoicePower",
  "PDV__SM_IncreaseSkill",
  "PDV__SM_ChangeLocation",
  "PDV__SM_PickLock",
  "PDV__SM_Trespass",
  "PDV__SM_AssaultActor",
];

const GENERIC_FAUCET_STORY_MANAGER_NODES = [
  {
    eventName: "Craft Item",
    nodeEdid: "PDV__SM_CraftItemNode",
    receiverQuest: "PDV__SM_CraftItem",
    parent: "Skyrim.esm:039D86",
    previousSibling: "Skyrim.esm:04F593",
  },
  {
    eventName: "New Voice Power",
    nodeEdid: "PDV__SM_NewVoicePowerNode",
    receiverQuest: "PDV__SM_NewVoicePower",
    parent: "Skyrim.esm:02D389",
    previousSibling: "Skyrim.esm:02D38A",
  },
  {
    eventName: "Increase Skill",
    nodeEdid: "PDV__SM_IncreaseSkillNode",
    receiverQuest: "PDV__SM_IncreaseSkill",
    parent: "Skyrim.esm:02D386",
    previousSibling: "Skyrim.esm:02D387",
  },
  {
    eventName: "Change Location",
    nodeEdid: "PDV__SM_ChangeLocationNode",
    receiverQuest: "PDV__SM_ChangeLocation",
    parent: "Skyrim.esm:01320E",
    previousSibling: "Skyrim.esm:0A39C6",
  },
  {
    eventName: "Pick Lock",
    nodeEdid: "PDV__SM_PickLockNode",
    receiverQuest: "PDV__SM_PickLock",
    parent: "Skyrim.esm:05BD7B",
    previousSibling: null,
  },
  {
    eventName: "Trespass",
    nodeEdid: "PDV__SM_TrespassNode",
    receiverQuest: "PDV__SM_Trespass",
    parent: "Devotion.esp:0714B1",
    previousSibling: null,
  },
  {
    eventName: "Assault Actor",
    nodeEdid: "PDV__SM_AssaultActorNode",
    receiverQuest: "PDV__SM_AssaultActor",
    parent: "Skyrim.esm:02C494",
    previousSibling: "Skyrim.esm:0A39C0",
  },
];

const ROUTER_PREFLIGHT_PROPERTIES = {
  PDV_EventBusService: "PDV_EventBus",
  PDV_EventTypesService: "PDV_EventTypes",
};

const ROUTER_PREFLIGHT_OVERLAY_PROPERTIES = {
  PDV_EventBusService: "PDV_ActionRouter",
  PDV_EventTypesService: "PDV_ActionRouter",
};

const EVENTBUS_OVERLAY_PROPERTIES = {
  PDV_Manager: "PDV__ManagerQuest",
  PDV_EventTypesService: "PDV_ActionRouter",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const EVENTBUS_RECORD_PROPERTIES = {
  PDV_Manager: "PDV__ManagerQuest",
  PDV_EventTypesService: "PDV_EventTypes",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const TALOS_EXPECTED_DATA = {
  DeityName: "Talos",
  DeityIndex: 1,
  ThresholdSeeker: 25,
  ThresholdDevoted: 50,
  ThresholdChampion: 85,
  IsAedric: true,
  Stance_Nord: 0,
  Stance_Imperial: 1,
  Stance_Breton: 0,
  Stance_Altmer: 3,
  Stance_Bosmer: 1,
  Stance_Dunmer: 1,
  Stance_Khajiit: 1,
  Stance_Argonian: 1,
  Stance_Orc: 1,
  Stance_Redguard: 1,
};

const AURIEL_EXPECTED_DATA = {
  DeityName: "Auri-El",
  DeityIndex: 2,
  ThresholdSeeker: 25,
  ThresholdDevoted: 50,
  ThresholdChampion: 85,
  IsAedric: true,
  Stance_Nord: 1,
  Stance_Imperial: 1,
  Stance_Breton: 1,
  Stance_Altmer: 0,
  Stance_Bosmer: 0,
  Stance_Dunmer: 1,
  Stance_Khajiit: 1,
  Stance_Argonian: 1,
  Stance_Orc: 3,
  Stance_Redguard: 1,
};

const RECEIVER_PROPERTIES = {
  PDV_Router: "PDV_ActionRouter",
};

const MCM_PROPERTIES = {
  PDV_Manager: "PDV__ManagerQuest",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
  PDV_GLO_ActivePiety: "PDV_GLO_ActivePiety",
  PDV_GLO_ActiveTier: "PDV_GLO_ActiveTier",
  PDV_GLO_ActiveDeityIndex: "PDV_GLO_ActiveDeityIndex",
  PDV_GLO_PatronDeity: "PDV_GLO_PatronDeity",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const MCM_SKELETON_PROPERTIES = {
  PDV_FLST_RepTracks_All: "PDV_FLST_RepTracks_All",
  PDV_FLST_StateTracks_All: "PDV_FLST_StateTracks_All",
  PDV_FLST_Substrates_All: "PDV_FLST_Substrates_All",
  PDV_FLST_SacredPlaces_All: "PDV_FLST_SacredPlaces_All",
  PDV_FLST_DaedricPaths_All: "PDV_FLST_DaedricPaths_All",
  PDV_CurseStateService: "PDV_CurseState",
};

const MANAGER_PATTERN_PROPERTIES = {
  PDV_GLO_OriginRace: "PDV_GLO_OriginRace",
  PDV_Kyne: "PDV_Deity_Kyne",
  PDV_Talos: "PDV_Deity_Talos",
  PDV_ConcordatStandingTrack: "PDV_RepTrack_ConcordatStanding",
  PDV_BosmerPathTrack: "PDV_StateTrack_BosmerPath",
  PDV_DunmerAncestorSubstrate: "PDV_Substrate_DunmerAncestor",
  PDV_KhajiitLunarSubstrate: "PDV_Substrate_KhajiitLunar",
  PDV_NordAncestorSubstrate: "PDV_Substrate_NordAncestor",
  PDV_AltmerAncestorSubstrate: "PDV_Substrate_AltmerAncestor",
  PDV_BretonAncestorSubstrate: "PDV_Substrate_BretonAncestor",
  PDV_ImperialAncestorSubstrate: "PDV_Substrate_ImperialAncestor",
  PDV_HircinePath: "PDV_DaedricPath_Hircine",
  PDV_CurseStateService: "PDV_CurseState",
};

const PHASE9_MANAGER_PROPERTIES = {
  PDV_Yffre: "PDV_Deity_Yffre",
  PDV_Zen: "PDV_Deity_Zen",
  PDV_BaanDar: "PDV_Deity_BaanDar",
  PDV_BosmerPathTrack: "PDV_StateTrack_BosmerPath",
  PDV_MSG_BosmerSetupChoice: "PDV_MSG_BosmerSetupChoice",
  PDV_MSG_BosmerSuggestLivingStory: "PDV_MSG_BosmerSuggestLivingStory",
  PDV_MSG_BosmerSuggestExchange: "PDV_MSG_BosmerSuggestExchange",
  PDV_MSG_BosmerSuggestBanditRoad: "PDV_MSG_BosmerSuggestBanditRoad",
  PDV_MSG_BosmerSuggestOldContract: "PDV_MSG_BosmerSuggestOldContract",
  PDV_MSG_BosmerReckoning: "PDV_MSG_BosmerReckoning",
};

const MCM_PATTERN_PROPERTIES = {
  PDV_EventBusService: "PDV_EventBus",
};

const PLAYER_ALIAS_PROPERTIES = {
  PDV_EventBusService: "PDV_EventBus",
  PDV_OriginQuest: "PDV_Origin",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
};

const PATTERN_PROVING_MANIFEST = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "PDV_PatternProvingCore.manifest.json",
);

class Verifier {
  constructor({
    strictPhase3 = false,
    strictPreflight = false,
    strictSkeleton = false,
    strictPatternProving = false,
    strictPhase7 = false,
    strictPhase8 = false,
    strictPhase9 = false,
    strictPhase10 = false,
    strictPhase11 = false,
    strictPhase12 = false,
    strictPhase13 = false,
    strictPhase14 = false,
    strictPhase15 = false,
    strictPhase16 = false,
    strictPhase17 = false,
    strictPhase18 = false,
    strictPhase19 = false,
    strictPhase20Roster = false,
    strictPhase20Altmer = false,
    strictPhase20RaceCosting = false,
    strictNord = false,
    strictKhajiit = false,
    strictCommitment = false,
    strictNeglectDecay = false,
  } = {}) {
    this.strictPhase3 = strictPhase3;
    this.strictPreflight = strictPreflight;
    this.strictSkeleton = strictSkeleton;
    this.strictPatternProving = strictPatternProving;
    this.strictPhase7 = strictPhase7;
    this.strictPhase8 = strictPhase8;
    this.strictPhase9 = strictPhase9;
    this.strictPhase10 = strictPhase10;
    this.strictPhase11 = strictPhase11;
    this.strictPhase12 = strictPhase12;
    this.strictPhase13 = strictPhase13;
    this.strictPhase14 = strictPhase14;
    this.strictPhase15 = strictPhase15;
    this.strictPhase16 = strictPhase16;
    this.strictPhase17 = strictPhase17;
    this.strictPhase18 = strictPhase18;
    this.strictPhase19 = strictPhase19;
    this.strictPhase20Roster = strictPhase20Roster;
    this.strictPhase20Altmer = strictPhase20Altmer;
    this.strictPhase20RaceCosting = strictPhase20RaceCosting;
    this.strictNord = strictNord;
    this.strictKhajiit = strictKhajiit;
    this.strictCommitment = strictCommitment;
    this.strictNeglectDecay = strictNeglectDecay;
    this.findings = [];
    this.recordsByEdid = new Map();
    this.recordsByFormid = new Map();
    this.recordDetails = new Map();
    this.recordDetailsByFormid = new Map();
  }

  add(status, check, detail, filePath = null) {
    this.findings.push({
      status,
      check,
      detail,
      path: filePath ? String(filePath) : null,
    });
  }

  pass(check, detail, filePath = null) {
    this.add("PASS", check, detail, filePath);
  }

  info(check, detail, filePath = null) {
    this.add("INFO", check, detail, filePath);
  }

  todo(check, detail, filePath = null) {
    this.add(this.strictPhase3 ? "FAIL" : "TODO", check, detail, filePath);
  }

  warn(check, detail, filePath = null) {
    this.add("WARN", check, detail, filePath);
  }

  fail(check, detail, filePath = null) {
    this.add("FAIL", check, detail, filePath);
  }

  preflightGap(check, detail, filePath = null) {
    if (this.strictPreflight) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  skeletonGap(check, detail, filePath = null) {
    if (this.strictSkeleton) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  patternGap(check, detail, filePath = null) {
    if (this.strictPatternProving) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase7Gap(check, detail, filePath = null) {
    if (this.strictPhase7) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase8Gap(check, detail, filePath = null) {
    if (this.strictPhase8) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase9Gap(check, detail, filePath = null) {
    if (this.strictPhase9) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase10Gap(check, detail, filePath = null) {
    if (this.strictPhase10) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase11Gap(check, detail, filePath = null) {
    if (this.strictPhase11) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase12Gap(check, detail, filePath = null) {
    if (this.strictPhase12) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase13Gap(check, detail, filePath = null) {
    if (this.strictPhase13) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase14Gap(check, detail, filePath = null) {
    if (this.strictPhase14) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase15Gap(check, detail, filePath = null) {
    if (this.strictPhase15) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase16Gap(check, detail, filePath = null) {
    if (this.strictPhase16) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase17Gap(check, detail, filePath = null) {
    if (this.strictPhase17) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase18Gap(check, detail, filePath = null) {
    if (this.strictPhase18 || this.strictNord) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase19Gap(check, detail, filePath = null) {
    if (this.strictPhase19) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase20RosterGap(check, detail, filePath = null) {
    if (this.strictPhase20Roster) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase20AltmerGap(check, detail, filePath = null) {
    if (this.strictPhase20Altmer) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  phase20RaceCostingGap(check, detail, filePath = null) {
    if (this.strictPhase20RaceCosting) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  checkPhase20ImmersionProofContract(raceName, manifest, manifestPath, gapFn) {
    const proof = manifest.immersionProof || {};
    const issues = [];
    const stringFields = [
      "signaturePromise",
      "normalSessionFeel",
      "runtimePromotionGate",
    ];
    const arrayFields = [
      ["diegeticTriggerMeaning", 2],
      ["feedbackSurface", 2],
      ["rejectedGenericBehavior", 2],
    ];

    for (const field of stringFields) {
      if (typeof proof[field] !== "string" || proof[field].trim().length < 20) {
        issues.push(`${field} is missing or too thin`);
      }
    }

    for (const [field, minimum] of arrayFields) {
      const values = proof[field];
      if (!Array.isArray(values) || values.filter((value) => typeof value === "string" && value.trim().length >= 10).length < minimum) {
        issues.push(`${field} needs at least ${minimum} concrete item(s)`);
      }
    }

    const rejectedHooks = new Set(manifest.rejectedHooks || []);
    const rejectedGenericBehavior = Array.isArray(proof.rejectedGenericBehavior) ? proof.rejectedGenericBehavior : [];
    if (rejectedHooks.size > 0 && !rejectedGenericBehavior.some((hook) => rejectedHooks.has(hook))) {
      issues.push("rejectedGenericBehavior must include at least one exact rejectedHooks entry");
    }

    if (issues.length === 0) {
      this.pass(
        `Phase 20 ${raceName} immersion proof`,
        "Manifest declares diegetic trigger meaning, feedback, rejected generic behavior, normal-session feel, and runtime promotion gate.",
        manifestPath,
      );
    } else {
      gapFn(
        `Phase 20 ${raceName} immersion proof`,
        `Immersion proof issue(s): ${issues.join("; ")}.`,
        manifestPath,
      );
    }
  }

  khajiitGap(check, detail, filePath = null) {
    if (this.strictKhajiit) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  commitmentGap(check, detail, filePath = null) {
    if (this.strictCommitment) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  neglectDecayGap(check, detail, filePath = null) {
    if (this.strictNeglectDecay) {
      this.fail(check, detail, filePath);
    } else {
      this.info(check, detail, filePath);
    }
  }

  async run() {
    this.checkPaths();
    if (exists(PDV_ESP) && exists(MUTAGEN_BRIDGE)) {
      this.loadRecordInventory();
      this.loadRecordDetails();
      this.checkRecordInventory();
      this.checkMainQuestRecord();
      this.checkOriginRecord();
      this.checkManagerRecord();
      this.checkKyneRecord();
      this.checkTalosRecord();
      this.checkAuriElRecord();
      this.checkFormListRecord();
      this.checkMcmRecord();
      this.checkPhase3Records();
      this.checkSkeletonScaffold();
      this.checkPatternProving();
      this.checkPhase8();
      this.checkPhase7();
      this.checkPhase9();
      this.checkPhase10();
      this.checkKhajiit();
      this.checkNordSpineParityBuild();
      this.checkDunmerSpineParityBuild();
      this.checkOrcSpineParityBuild();
      this.checkAltmerSpineParityBuild();
      this.checkBretonSpineParityBuild();
      this.checkImperialSpineParityBuild();
      this.checkCommitment();
      this.checkNeglectDecay();
      this.checkPhase11();
      this.checkPhase12();
      this.checkPhase13();
      this.checkPhase14();
      this.checkPhase15();
      this.checkPhase16();
      this.checkPhase17();
      this.checkPhase18();
      this.checkOfflinePatcherRules();
      this.checkPhase19GeneratedPatch();
      this.checkPhase21RosterCoverage();
      if (exists(SHRINE_BLESSING_NEUTRALIZATION_MANIFEST)) {
        this.checkShrineBlessingNeutralization();
      }
      if (exists(PHASE20_MEDALLION_ROSTER_MANIFEST)) {
        this.checkPhase20MedallionRoster();
      }
      if (this.strictPhase20Altmer || exists(PHASE20_ALTMER_IMPLEMENTATION_MANIFEST)) {
        this.checkPhase20AltmerImplementationCosting();
      }
      if (
        this.strictPhase20RaceCosting
        || PHASE20_RACE_IMPLEMENTATION_MANIFESTS.some((manifestPath) => exists(manifestPath))
      ) {
        this.checkPhase20RaceImplementationCosting();
      }
      this.checkPreflightOverlayPatch();
    }
    this.checkSmallSignalTables();
    this.checkCustomRaceCompatibility();
    this.checkScripts();
    this.checkSeq();
    this.checkProfile();
    this.checkShadowOutputs();
    await this.checkMcpServer();
    return this.findings;
  }

  bridge(request, timeoutMs = 30_000) {
    const result = spawnSync(MUTAGEN_BRIDGE, {
      input: JSON.stringify(request),
      encoding: "utf8",
      timeout: timeoutMs,
      maxBuffer: MUTAGEN_BRIDGE_MAX_BUFFER,
      windowsHide: true,
    });

    if (result.error) {
      throw result.error;
    }

    const stdout = (result.stdout || "").trim();
    if (!stdout) {
      throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
    }

    let payload;
    try {
      payload = JSON.parse(stdout);
    } catch (error) {
      throw new Error(`mutagen-bridge returned invalid JSON: ${stdout.slice(0, 500)}`);
    }

    if (!payload.success) {
      throw new Error(payload.error || payload.message || "bridge call failed");
    }

    return payload;
  }

  checkPaths() {
    const requiredPaths = {
      "Project root": PROJECT_ROOT,
      "Anvil root": ANVIL_ROOT,
      "Devotion mod": DEVOTION_MOD,
      "Devotion source": DEVOTION_SOURCE,
      "Devotion compiled scripts": DEVOTION_PEX,
      "Devotion ESP": PDV_ESP,
      "Mutagen bridge": MUTAGEN_BRIDGE,
      "Devotion Dev profile": DEV_PROFILE,
      "ModOrganizer.ini": MO2_INI,
    };

    for (const [label, filePath] of Object.entries(requiredPaths)) {
      if (exists(filePath)) {
        this.pass(label, "Found.", filePath);
      } else {
        this.fail(label, "Missing expected path.", filePath);
      }
    }
  }

  loadRecordInventory() {
    let response;
    try {
      response = this.bridge(
        {
          command: "scan",
          plugins: [toPosix(PDV_ESP)],
        },
        60_000,
      );
    } catch (error) {
      this.fail("ESP scan", `Mutagen scan failed: ${error.message}`, PDV_ESP);
      return;
    }

    const plugin = response.plugins?.[0];
    if (!plugin) {
      this.fail("ESP scan", "Mutagen scan returned no plugin payload.", PDV_ESP);
      return;
    }

    for (const record of plugin.records || []) {
      if (record.formid) {
        this.recordsByFormid.set(record.formid, record);
      }
      if (record.edid) {
        this.recordsByEdid.set(record.edid, record);
      }
    }

    this.pass(
      "ESP scan",
      `Read ${plugin.record_count} major records from ${plugin.plugin_name}.`,
      PDV_ESP,
    );

    const unnamed = (plugin.records || [])
      .filter((record) => !record.edid && String(record.type || "").toUpperCase() !== "NAVI")
      .filter((record) => !this.isAllowedUnnamedRecord(record))
      .map((record) => `${record.type} ${record.formid}`);
    if (unnamed.length) {
      this.warn("Unnamed records", `Records without EditorID found: ${unnamed.join(", ")}`, PDV_ESP);
    }
  }

  loadRecordDetails() {
    const wantedFormids = [...this.recordsByEdid.values()]
      .map((record) => record.formid)
      .filter(Boolean);
    if (this.strictPhase11 || this.strictPhase18 || this.strictNord) {
      for (const record of this.recordsByFormid.values()) {
        if (record.type === "INFO" && record.formid) {
          wantedFormids.push(record.formid);
        }
      }
    }
    if (!wantedFormids.length) {
      return;
    }

    let response;
    try {
      response = this.bridge(
        {
          command: "read_records",
          // VMAD array properties such as Quest[] RivalDeities sit just past
          // the bridge default depth and otherwise truncate to max-depth
          // sentinels, creating false wiring warnings.
          max_depth: 10,
          records: wantedFormids.map((formid) => ({
            plugin_path: toPosix(PDV_ESP),
            formid,
          })),
        },
        60_000,
      );
    } catch (error) {
      this.fail("ESP detail read", `Mutagen detail read failed: ${error.message}`, PDV_ESP);
      return;
    }

    for (const record of response.records || []) {
      if (record.success && record.formid) {
        this.recordDetailsByFormid.set(record.formid, record);
      }
      if (record.success && record.editor_id) {
        this.recordDetails.set(record.editor_id, record);
      }
    }

    this.pass("ESP detail read", `Read details for ${this.recordDetails.size} records.`, PDV_ESP);
  }

  scanPlugin(pluginPath) {
    const response = this.bridge(
      {
        command: "scan",
        plugins: [toPosix(pluginPath)],
      },
      60_000,
    );

    const plugin = response.plugins?.[0];
    if (!plugin) {
      throw new Error(`Mutagen scan returned no plugin payload for ${pluginPath}.`);
    }

    const recordsByEdid = new Map();
    const recordsByFormid = new Map();
    for (const record of plugin.records || []) {
      if (record.formid) {
        recordsByFormid.set(record.formid, record);
      }
      if (record.edid) {
        recordsByEdid.set(record.edid, record);
      }
    }

    return {
      plugin,
      recordsByEdid,
      recordsByFormid,
    };
  }

  readPluginRecordDetail(pluginPath, formid) {
    const response = this.bridge(
      {
        command: "read_records",
        max_depth: 10,
        records: [
          {
            plugin_path: toPosix(pluginPath),
            formid,
          },
        ],
      },
      60_000,
    );

    const detail = response.records?.find((record) => record.success && record.formid === formid);
    if (!detail) {
      throw new Error(`Mutagen detail read returned no record payload for ${formid}.`);
    }

    return detail;
  }

  checkRecordInventory() {
    for (const [edid, expectedType] of Object.entries(BASELINE_RECORDS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.fail("Baseline record", `Missing ${expectedType} record ${edid}.`, PDV_ESP);
        continue;
      }
      if (record.type !== expectedType) {
        this.fail("Baseline record", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("Baseline record", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }

    for (const [edid, expectedType] of Object.entries(PHASE3_RECORDS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.todo("Phase 3 record", `${expectedType} record ${edid} is not in the ESP yet.`, PDV_ESP);
        continue;
      }
      if (record.type !== expectedType) {
        this.fail("Phase 3 record", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("Phase 3 record", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }

    for (const [edid, expectedType] of Object.entries(PREFLIGHT_RECORDS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.preflightGap("V3 Preflight record", `${expectedType} record ${edid} is not in the framework ESP yet; CK/xEdit wiring remains pending.`, PDV_ESP);
        continue;
      }
      if (record.type !== expectedType) {
        this.fail("V3 Preflight record", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("V3 Preflight record", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }
  }

  checkSkeletonScaffold() {
    this.checkSkeletonRecordInventory();
    this.checkSkeletonTrackWiring();
    this.checkSkeletonSystemWiring();
    this.checkSkeletonFormListMembership();
    this.checkSkeletonArrayReadback();
  }

  checkSkeletonRecordInventory() {
    for (const definition of SKELETON_TRACK_DEFINITIONS) {
      const questRecord = this.recordsByEdid.get(definition.questEdid);
      if (!questRecord) {
        this.skeletonGap("V3 Skeleton track record", `Missing QUST record ${definition.questEdid}.`, PDV_ESP);
      } else if (questRecord.type !== "QUST") {
        this.fail("V3 Skeleton track record", `${definition.questEdid} has type ${questRecord.type}, expected QUST.`, PDV_ESP);
      } else {
        this.pass("V3 Skeleton track record", `${definition.questEdid} exists as QUST.`, PDV_ESP);
      }

      const globalRecord = this.recordsByEdid.get(definition.globalEdid);
      if (!globalRecord) {
        this.skeletonGap("V3 Skeleton track global", `Missing GLOB record ${definition.globalEdid}.`, PDV_ESP);
      } else if (globalRecord.type !== "GLOB") {
        this.fail("V3 Skeleton track global", `${definition.globalEdid} has type ${globalRecord.type}, expected GLOB.`, PDV_ESP);
      } else {
        this.pass("V3 Skeleton track global", `${definition.globalEdid} exists as GLOB.`, PDV_ESP);
      }
    }

    for (const [edid, expectedType] of Object.entries(SKELETON_FORMLISTS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.skeletonGap("V3 Skeleton FormList", `Missing ${expectedType} record ${edid}.`, PDV_ESP);
      } else if (record.type !== expectedType) {
        this.fail("V3 Skeleton FormList", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("V3 Skeleton FormList", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }

    for (const definition of SKELETON_SUBSTRATE_DEFINITIONS) {
      this.checkSkeletonQuestRecord(definition.questEdid, "V3 Skeleton substrate record");
    }

    for (const definition of SKELETON_SACRED_PLACE_DEFINITIONS) {
      this.checkSkeletonQuestRecord(definition.questEdid, "V3 Skeleton sacred place record");
    }

    for (const definition of SKELETON_DAEDRIC_PATH_DEFINITIONS) {
      this.checkSkeletonQuestRecord(definition.questEdid, "V3 Skeleton Daedric path record");
      this.checkSkeletonGlobalRecord(definition.stigmaGlobalEdid, "V3 Skeleton Daedric stigma global");
    }

    for (const definition of SKELETON_SERVICE_DEFINITIONS) {
      this.checkSkeletonQuestRecord(definition.questEdid, "V3 Skeleton service record");
      this.checkSkeletonGlobalRecord(definition.globalEdid, "V3 Skeleton service global");
    }
  }

  checkSkeletonTrackWiring() {
    for (const definition of SKELETON_TRACK_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.skeletonGap(
          "V3 Skeleton track script",
          `${definition.scriptName} is not attached on ${definition.questEdid}.`,
          PDV_ESP,
        );
        continue;
      }

      this.pass("V3 Skeleton track script", `${definition.questEdid} has ${definition.scriptName} attached.`, PDV_ESP);
      const props = propertyMap(script);

      const globalProp = props.get(definition.globalPropertyName);
      if (!globalProp) {
        this.skeletonGap(
          "V3 Skeleton track property",
          `${definition.questEdid}.${definition.globalPropertyName} is missing.`,
          PDV_ESP,
        );
      } else {
        const actualEdid = objectEdid(globalProp, this.recordsByEdid);
        if (actualEdid === definition.globalEdid) {
          this.pass(
            "V3 Skeleton track property",
            `${definition.questEdid}.${definition.globalPropertyName} points at ${definition.globalEdid}.`,
            PDV_ESP,
          );
        } else {
          this.skeletonGap(
            "V3 Skeleton track property",
            `${definition.questEdid}.${definition.globalPropertyName} points at ${actualEdid || globalProp.Object || "unassigned"}, expected ${definition.globalEdid}.`,
            PDV_ESP,
          );
        }
      }

      const debugProp = props.get("PDV_GLO_DebugLevel");
      if (!debugProp) {
        this.skeletonGap("V3 Skeleton track property", `${definition.questEdid}.PDV_GLO_DebugLevel is missing.`, PDV_ESP);
      } else {
        const actualDebugEdid = objectEdid(debugProp, this.recordsByEdid);
        if (actualDebugEdid === "PDV_GLO_DebugLevel") {
          this.pass(
            "V3 Skeleton track property",
            `${definition.questEdid}.PDV_GLO_DebugLevel points at PDV_GLO_DebugLevel.`,
            PDV_ESP,
          );
        } else {
          this.skeletonGap(
            "V3 Skeleton track property",
            `${definition.questEdid}.PDV_GLO_DebugLevel points at ${actualDebugEdid || debugProp.Object || "unassigned"}, expected PDV_GLO_DebugLevel.`,
            PDV_ESP,
          );
        }
      }
    }
  }

  checkSkeletonSystemWiring() {
    for (const definition of SKELETON_SUBSTRATE_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.skeletonGap("V3 Skeleton substrate script", `${definition.scriptName} is not attached on ${definition.questEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Skeleton substrate script", `${definition.questEdid} has ${definition.scriptName} attached.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkScalarProperty("V3 Skeleton substrate property", props, "SubstrateName", definition.substrateName, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton substrate property", props, "RequiredOriginRace", definition.requiredOriginRace, this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton substrate property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton substrate property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.skeletonGap.bind(this));
    }

    for (const definition of SKELETON_SACRED_PLACE_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.skeletonGap("V3 Skeleton sacred place script", `${definition.scriptName} is not attached on ${definition.questEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Skeleton sacred place script", `${definition.questEdid} has ${definition.scriptName} attached.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkScalarProperty("V3 Skeleton sacred place property", props, "PlaceName", definition.placeName, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton sacred place property", props, "MaxLocations", definition.maxLocations, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton sacred place property", props, "RequiredOriginRace", definition.requiredOriginRace, this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton sacred place property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton sacred place property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.skeletonGap.bind(this));
    }

    for (const definition of SKELETON_DAEDRIC_PATH_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.skeletonGap("V3 Skeleton Daedric path script", `${definition.scriptName} is not attached on ${definition.questEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Skeleton Daedric path script", `${definition.questEdid} has ${definition.scriptName} attached.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkScalarProperty("V3 Skeleton Daedric path property", props, "DeityName", definition.deityName, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton Daedric path property", props, "DeityDomain", definition.deityDomain, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton Daedric path property", props, "DeityIndex", definition.deityIndex, this.skeletonGap.bind(this));
      this.checkScalarProperty("V3 Skeleton Daedric path property", props, "CommitmentSignalsRequired", definition.commitmentSignalsRequired, this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton Daedric path property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton Daedric path property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton Daedric path property", props, "StigmaGlobal", definition.stigmaGlobalEdid, this.skeletonGap.bind(this));
    }

    for (const definition of SKELETON_SERVICE_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.skeletonGap("V3 Skeleton service script", `${definition.scriptName} is not attached on ${definition.questEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Skeleton service script", `${definition.questEdid} has ${definition.scriptName} attached.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("V3 Skeleton service property", props, definition.globalPropertyName, definition.globalEdid, this.skeletonGap.bind(this));
      this.checkObjectPropertyTarget("V3 Skeleton service property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.skeletonGap.bind(this));
    }
  }

  checkSkeletonFormListMembership() {
    const repTrackEdids = SKELETON_TRACK_DEFINITIONS.filter((entry) => entry.type === "rep").map((entry) => entry.questEdid);
    const stateTrackEdids = SKELETON_TRACK_DEFINITIONS.filter((entry) => entry.type === "state").map((entry) => entry.questEdid);
    const substrateEdids = SKELETON_SUBSTRATE_DEFINITIONS.map((entry) => entry.questEdid);
    const sacredPlaceEdids = SKELETON_SACRED_PLACE_DEFINITIONS.map((entry) => entry.questEdid);
    const daedricPathEdids = SKELETON_DAEDRIC_PATH_DEFINITIONS.map((entry) => entry.questEdid);

    this.checkRequiredFormListMembers("PDV_FLST_RepTracks_All", repTrackEdids);
    this.checkRequiredFormListMembers("PDV_FLST_RepTracks_DevOnly", repTrackEdids);
    this.checkRequiredFormListMembers("PDV_FLST_StateTracks_All", stateTrackEdids);
    this.checkRequiredFormListMembers("PDV_FLST_StateTracks_DevOnly", stateTrackEdids);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", substrateEdids);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", substrateEdids);
    this.checkRequiredFormListMembers("PDV_FLST_SacredPlaces_All", sacredPlaceEdids);
    this.checkRequiredFormListMembers("PDV_FLST_SacredPlaces_DevOnly", sacredPlaceEdids);
    this.checkRequiredFormListMembers("PDV_FLST_DaedricPaths_All", daedricPathEdids);
    this.checkRequiredFormListMembers("PDV_FLST_DaedricPaths_DevOnly", daedricPathEdids);
    this.checkForbiddenFormListMembers("PDV_FLST_AllDeities", daedricPathEdids);
  }

  checkSkeletonArrayReadback() {
    for (const definition of SKELETON_TRACK_DEFINITIONS.filter((entry) => entry.type === "rep")) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        continue;
      }

      const props = propertyMap(script);
      const thresholdValues = extractNumericArrayProperty(props.get("ThresholdValues"));
      const thresholdLabels = extractStringArrayProperty(props.get("ThresholdLabels"));

      if (!thresholdValues.length && !thresholdLabels.length) {
        this.info("V3 Skeleton array readback", `${definition.questEdid} threshold arrays are still manual/deferred.`, PDV_ESP);
        continue;
      }

      if (thresholdLabels.length === thresholdValues.length + 1) {
        this.pass("V3 Skeleton array readback", `${definition.questEdid} threshold labels count matches threshold values + 1.`, PDV_ESP);
      } else {
        this.skeletonGap("V3 Skeleton array readback", `${definition.questEdid} threshold label/value counts are ${thresholdLabels.length}/${thresholdValues.length}; expected labels = values + 1.`, PDV_ESP);
      }
    }

    for (const definition of SKELETON_TRACK_DEFINITIONS.filter((entry) => entry.type === "state")) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        continue;
      }

      const props = propertyMap(script);
      const labels = extractStringArrayProperty(props.get("StateLabels"));
      if (!labels.length) {
        this.info("V3 Skeleton array readback", `${definition.questEdid} state labels are still manual/deferred.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Skeleton array readback", `${definition.questEdid} exposes ${labels.length} state labels.`, PDV_ESP);
    }

    for (const definition of SKELETON_DAEDRIC_PATH_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        continue;
      }

      const props = propertyMap(script);
      this.checkOptionalArrayLength("V3 Skeleton array readback", definition.questEdid, "StateByRace", extractNumericArrayProperty(props.get("StateByRace")), 10);
      this.checkOptionalArrayLength("V3 Skeleton array readback", definition.questEdid, "StigmaModByRace", extractNumericArrayProperty(props.get("StigmaModByRace")), 10);
      this.checkOptionalArrayLength("V3 Skeleton array readback", definition.questEdid, "ExitDifficultyByRace", extractNumericArrayProperty(props.get("ExitDifficultyByRace")), 10);
    }

    for (const definition of SKELETON_SACRED_PLACE_DEFINITIONS) {
      const detail = this.recordDetails.get(definition.questEdid);
      if (!detail) {
        continue;
      }

      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        continue;
      }

      const props = propertyMap(script);
      this.checkOptionalMinArrayLength("V3 Skeleton array readback", definition.questEdid, "DesignatedLocations", extractFormidsFromArrayProperty(props.get("DesignatedLocations")), definition.maxLocations);
      this.checkOptionalMinArrayLength("V3 Skeleton array readback", definition.questEdid, "LastVisitTime", extractNumericArrayProperty(props.get("LastVisitTime")), definition.maxLocations);
      this.checkOptionalMinArrayLength("V3 Skeleton array readback", definition.questEdid, "InvestmentLevel", extractNumericArrayProperty(props.get("InvestmentLevel")), definition.maxLocations);
    }
  }

  checkPatternProving() {
    this.checkPatternProvingManifest();
    this.checkPatternManagerRecord();
    this.checkPatternMcmRecord();
    this.checkPlayerAliasContract(this.patternGap.bind(this), "V3 player alias contract");
    this.checkPatternPilotScripts();
    this.checkPatternArrayReadback();
    this.checkSlice1SignalReceiverManifest();
    this.checkSlice1SignalReceiverRecords();
  }

  checkPhase7() {
    this.checkPlayerAliasContract(this.phase7Gap.bind(this), "Phase 7 player alias contract");
    this.checkPhase7SignalReceiverManifest();
    this.checkPhase7SignalReceiverRecords();
  }

  checkPhase8() {
    this.checkPhase8Manifest();
    this.checkPhase8ManagerRecord();
    this.checkPhase8ConcordatTrackRecord();
    this.checkPhase8TalosRecord();
  }

  checkPhase9() {
    this.checkPhase9Manifest();
    this.checkPhase9Records();
    this.checkPhase9ManagerRecord();
    this.checkPhase9BosmerTrackRecord();
    this.checkPhase9DeityRecord("PDV_Deity_Yffre", "PDV_Deity_Yffre", {
      DeityName: "Y'ffre",
      DeityIndex: 3,
      ThresholdSeeker: 25,
      ThresholdDevoted: 50,
      ThresholdChampion: 85,
      IsAedric: true,
      Stance_Bosmer: 0,
    });
    this.checkPhase9DeityRecord("PDV_Deity_Zen", "PDV_Deity_Zen", {
      DeityName: "Z'en",
      DeityIndex: 4,
      ThresholdSeeker: 25,
      ThresholdDevoted: 50,
      ThresholdChampion: 85,
      IsAedric: true,
      Stance_Bosmer: 0,
    });
    this.checkPhase9DeityRecord("PDV_Deity_BaanDar", "PDV_Deity_BaanDar", {
      DeityName: "Baan Dar",
      DeityIndex: 5,
      ThresholdSeeker: 25,
      ThresholdDevoted: 50,
      ThresholdChampion: 85,
      IsAedric: false,
      Stance_Bosmer: 0,
    });
    this.checkPhase9SignalReceiverRecords();
  }

  checkPhase10() {
    this.checkPhase10DunmerSubstrateRecord();
    this.checkPhase10ManagerRecord();
    this.checkPhase10SignalReceiverRecords();
  }

  checkKhajiit() {
    this.checkKhajiitFocusedEmphasisRecord();
    this.checkKhajiitManagerRecord();
  }

  checkCommitment() {
    this.checkCommitmentManagerRecord();
  }

  checkNeglectDecay() {
    this.checkNeglectDecayManagerRecord();
  }

  checkPhase11() {
    const manifest = this.checkPhase11PrivilegePilotManifest();
    if (manifest?.implementationStatus === "live-dialogue-authored") {
      this.checkPhase11ArngeirDialogueRecords();
    } else {
      this.info(
        "Phase 11 Arngeir dialogue records",
        "Live dialogue readback is skipped because the manifest is prep-only.",
        PHASE11_PRIVILEGE_PILOT_MANIFEST,
      );
    }
  }

  checkPhase12() {
    const manifest = this.checkPhase12ContextualFavorManifest();
    if (!manifest) {
      return;
    }

    this.checkPhase12LaneCounts(manifest);
    this.checkPhase12SourceContracts();
    this.checkPhase12ManagerRecord(manifest);
    this.checkPhase12NordBaselineTrack(manifest);
    this.checkPhase12FavorRecords(manifest);
  }

  checkPhase12ContextualFavorManifest() {
    if (!exists(PHASE12_CONTEXTUAL_FAVOR_MANIFEST)) {
      this.phase12Gap(
        "Phase 12 contextual favor manifest",
        "Phase 12 contextual favor manifest is missing.",
        PHASE12_CONTEXTUAL_FAVOR_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE12_CONTEXTUAL_FAVOR_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 12 contextual favor manifest", `Manifest could not be parsed: ${error.message}`, PHASE12_CONTEXTUAL_FAVOR_MANIFEST);
      return null;
    }

    const laneIds = (parsed.lanes || []).map((lane) => lane.laneId);
    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase12-contextual-favor-pilot"
      && parsed.manager?.record === "PDV__ManagerQuest"
      && laneIds.includes("Kyne")
      && laneIds.includes("NordBroadOldWays")
      && laneIds.includes("NordBroadNineDivines")
      && ["manual-shells-required", "helper-can-create-missing", "shells-filled", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 12 contextual favor manifest",
        `Manifest locks focused Kyne plus both Nord broad lanes with status ${implementationStatus}.`,
        PHASE12_CONTEXTUAL_FAVOR_MANIFEST,
      );
    } else {
      this.phase12Gap(
        "Phase 12 contextual favor manifest",
        "Manifest does not match the locked Phase 12 focused Kyne plus Nord broad-lane contract.",
        PHASE12_CONTEXTUAL_FAVOR_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase12LaneCounts(manifest) {
    for (const lane of manifest.lanes || []) {
      const familyCount = Array.isArray(lane.families) ? lane.families.length : 0;
      if (lane.laneId === "Kyne" && familyCount === 4) {
        this.pass("Phase 12 lane count", "Focused Kyne exposes 4 trigger families.", PHASE12_CONTEXTUAL_FAVOR_MANIFEST);
      } else if ((lane.laneId === "NordBroadOldWays" || lane.laneId === "NordBroadNineDivines") && familyCount === 5) {
        this.pass("Phase 12 lane count", `${lane.laneId} exposes 5 trigger families.`, PHASE12_CONTEXTUAL_FAVOR_MANIFEST);
      } else {
        this.phase12Gap("Phase 12 lane count", `${lane.laneId} exposes ${familyCount} trigger families.`, PHASE12_CONTEXTUAL_FAVOR_MANIFEST);
      }
    }
  }

  checkPhase12SourceContracts() {
    this.checkSourceContains("Phase 12 source", "PDV__ManagerQuest", [
      "PDV_StateTrack Property PDV_NordPantheonBaselineTrack Auto",
      "Spell Property PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery Auto",
      "Spell Property PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance Auto",
      "Spell Property PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine Auto",
      "Function UpdateContextualFavorRuntime()",
      "Bool Function TryActivateContextualFavor(Int laneValue, Int familyValue, String reason)",
      "StorageUtil.SetIntValue(None, \"PDV.Favor.ActiveLane\", laneValue)",
      "StorageUtil.SetIntValue(None, \"PDV.Favor.ActiveFamily\", familyValue)",
      "StorageUtil.SetStringValue(None, \"PDV.Favor.ActiveSpell\"",
      "StorageUtil.SetFloatValue(None, \"PDV.Favor.ActiveExpiresAt\"",
      "return FAVOR_LANE_NORD_BROAD_OLD_WAYS",
      "return FAVOR_LANE_NORD_BROAD_NINE_DIVINES",
      "ClearActiveFavor(\"patron_state_change\")",
      "String Function GetContextualFavorSummary()",
    ], this.phase12Gap.bind(this));

    this.checkSourceContains("Phase 12 source", "PDV_MCM", [
      "Set Broad worship",
      "Nord -> Old Ways",
      "Nord -> Nine Divines",
      "Cycle favor lane",
      "Cycle favor family",
      "Trigger selected favor",
      "Clear active favor",
      "manager.DebugTriggerSelectedContextualFavor()",
      "manager.DebugSetNordPantheonBaseline(manager.NORD_BASELINE_OLD_WAYS)",
      "manager.DebugSetNordPantheonBaseline(manager.NORD_BASELINE_NINE_DIVINES)",
    ], this.phase12Gap.bind(this));
  }

  checkPhase12ManagerRecord(manifest) {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    for (const propName of manifest.manager?.requiredProperties || []) {
      const expectedEdid = propName === "PDV_NordPantheonBaselineTrack"
        ? manifest.nordBaseline?.track
        : propName;
      this.checkObjectPropertyTarget("Phase 12 manager property", props, propName, expectedEdid, this.phase12Gap.bind(this));
    }
  }

  checkPhase12NordBaselineTrack(manifest) {
    const trackEdid = manifest.nordBaseline?.track;
    if (!trackEdid) {
      return;
    }

    this.checkPhase12RecordType(trackEdid, "QUST");
    const detail = this.recordDetails.get(trackEdid);
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_StateTrack");
    if (script) {
      this.pass("Phase 12 nord baseline track", `${trackEdid} is attached to PDV_StateTrack.`, PDV_ESP);
    } else {
      this.phase12Gap("Phase 12 nord baseline track", `${trackEdid} is missing the PDV_StateTrack VMAD attachment.`, PDV_ESP);
    }
  }

  checkPhase12FavorRecords(manifest) {
    const keywordTargets = new Map();
    for (const lane of manifest.lanes || []) {
      for (const family of lane.families || []) {
        this.checkPhase12RecordType(family.magicEffect, "MGEF");
        this.checkPhase12RecordType(family.spell, "SPEL");
        this.checkPhase12SpellEffect(family.spell, family.magicEffect);
        if (!keywordTargets.has(family.keyword)) {
          keywordTargets.set(family.keyword, []);
          this.checkPhase12RecordType(family.keyword, "KYWD");
        }
        keywordTargets.get(family.keyword).push(family.magicEffect);
      }
    }

    for (const [keywordEdid, effectEdids] of keywordTargets.entries()) {
      for (const effectEdid of effectEdids) {
        this.checkPhase12MagicEffectKeyword(effectEdid, keywordEdid);
      }
    }
  }

  checkPhase12RecordType(edid, expectedType) {
    const record = this.recordsByEdid.get(edid);
    if (record?.type === expectedType) {
      this.pass("Phase 12 favor record", `${edid} exists as ${expectedType}.`, PDV_ESP);
    } else {
      this.phase12Gap("Phase 12 favor record", `${edid} is missing or not a ${expectedType}.`, PDV_ESP);
    }
  }

  checkPhase12SpellEffect(spellEdid, effectEdid) {
    const detail = this.recordDetails.get(spellEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const effects = Array.isArray(fields.Effects) ? fields.Effects : [];
    const expectedFormid = this.recordsByEdid.get(effectEdid)?.formid;
    const firstEffect = effects[0] || {};
    if (expectedFormid && firstEffect.BaseEffect === expectedFormid) {
      this.pass("Phase 12 spell membership", `${spellEdid} points at ${effectEdid}.`, PDV_ESP);
    } else {
      this.phase12Gap("Phase 12 spell membership", `${spellEdid} does not point at ${effectEdid}.`, PDV_ESP);
    }
  }

  checkPhase12MagicEffectKeyword(effectEdid, keywordEdid) {
    const detail = this.recordDetails.get(effectEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const keywordValues = Array.isArray(fields.Keywords) ? fields.Keywords : [];
    const keywordEdids = keywordValues.map((value) => formidToEdid(value, this.recordsByEdid) || value);
    if (keywordEdids.includes(keywordEdid)) {
      this.pass("Phase 12 favor keyword", `${effectEdid} includes ${keywordEdid}.`, PDV_ESP);
    } else {
      this.phase12Gap("Phase 12 favor keyword", `${effectEdid} is missing ${keywordEdid}.`, PDV_ESP);
    }
  }

  checkPhase13() {
    const manifest = this.checkPhase13Manifest();
    if (!manifest) {
      return;
    }

    this.checkPhase13PilotRecord();
    this.checkPhase13SourceContracts();
  }

  checkPhase13Manifest() {
    if (!exists(PHASE13_DAEDRIC_HIRCINE_MANIFEST)) {
      this.phase13Gap(
        "Phase 13 Daedric manifest",
        "Phase 13 Daedric Hircine pilot manifest is missing.",
        PHASE13_DAEDRIC_HIRCINE_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE13_DAEDRIC_HIRCINE_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 13 Daedric manifest", `Manifest could not be parsed: ${error.message}`, PHASE13_DAEDRIC_HIRCINE_MANIFEST);
      return null;
    }

    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase13-daedric-hircine-pilot"
      && parsed.pilot?.quest === "PDV_DaedricPath_Hircine"
      && parsed.pilot?.stigmaGlobal === "PDV_GLO_HircineStigma"
      && parsed.pilot?.signalSurface === "PDV_ACTI_HircineHuntRiteSignal"
      && ["hircine-pilot-live-price-deferred", "price-packet-live", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 13 Daedric manifest",
        `Manifest locks the Hircine pilot with status ${implementationStatus}.`,
        PHASE13_DAEDRIC_HIRCINE_MANIFEST,
      );
    } else {
      this.phase13Gap(
        "Phase 13 Daedric manifest",
        "Manifest does not match the locked Hircine boon-price-stigma pilot contract.",
        PHASE13_DAEDRIC_HIRCINE_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase13PilotRecord() {
    const hircine = this.recordsByEdid.get("PDV_DaedricPath_Hircine");
    if (hircine?.type === "QUST") {
      this.pass("Phase 13 Daedric pilot", "PDV_DaedricPath_Hircine exists as QUST.", PDV_ESP);
    } else {
      this.phase13Gap("Phase 13 Daedric pilot", "PDV_DaedricPath_Hircine is missing or not a QUST.", PDV_ESP);
    }

    const stigma = this.recordsByEdid.get("PDV_GLO_HircineStigma");
    if (stigma?.type === "GLOB") {
      this.pass("Phase 13 stigma global", "PDV_GLO_HircineStigma exists as GLOB.", PDV_ESP);
    } else {
      this.phase13Gap("Phase 13 stigma global", "PDV_GLO_HircineStigma is missing or not a GLOB.", PDV_ESP);
    }

    const detail = this.recordDetails.get("PDV_DaedricPath_Hircine");
    const pilotScript = detail ? findScript(detail.fields || {}, "PDV_DaedricPath_Hircine") : null;
    const baseScript = detail ? findScript(detail.fields || {}, "PDV_DaedricPathBase") : null;
    const script = pilotScript || baseScript;
    if (script) {
      this.pass("Phase 13 Daedric pilot", "PDV_DaedricPath_Hircine exposes the expected pilot/base VMAD surface.", PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("Phase 13 Daedric pilot property", props, "StigmaGlobal", "PDV_GLO_HircineStigma", this.phase13Gap.bind(this));
      this.checkRequiredArrayLength("Phase 13 Daedric pilot array", "PDV_DaedricPath_Hircine", "StateByRace", extractNumericArrayProperty(props.get("StateByRace")), 10, this.phase13Gap.bind(this));
      this.checkRequiredArrayLength("Phase 13 Daedric pilot array", "PDV_DaedricPath_Hircine", "StigmaModByRace", extractNumericArrayProperty(props.get("StigmaModByRace")), 10, this.phase13Gap.bind(this));
      this.checkRequiredArrayLength("Phase 13 Daedric pilot array", "PDV_DaedricPath_Hircine", "ExitDifficultyByRace", extractNumericArrayProperty(props.get("ExitDifficultyByRace")), 10, this.phase13Gap.bind(this));
    }
    if (pilotScript) {
      const pilotProps = propertyMap(pilotScript);
      this.checkObjectPropertyTarget("Phase 13 Hircine price property", pilotProps, "Price_Seeker", "PDV_SPEL_HircinePrice_Seeker", this.phase13Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 13 Hircine price property", pilotProps, "Price_Devoted", "PDV_SPEL_HircinePrice_Devoted", this.phase13Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 13 Hircine price property", pilotProps, "Price_Champion", "PDV_SPEL_HircinePrice_Champion", this.phase13Gap.bind(this));
    } else {
      this.phase13Gap("Phase 13 Hircine price property", "PDV_DaedricPath_Hircine is missing the live pilot script VMAD attachment.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    if (managerDetail) {
      const managerScript = findScript(managerDetail.fields || {}, "PDV__ManagerQuest");
      if (managerScript) {
        const props = propertyMap(managerScript);
        this.checkObjectPropertyTarget("Phase 13 manager property", props, "PDV_HircinePath", "PDV_DaedricPath_Hircine", this.phase13Gap.bind(this));
        this.checkObjectPropertyTarget("Phase 13 manager property", props, "PDV_CurseStateService", "PDV_CurseState", this.phase13Gap.bind(this));
      }
    }
  }

  checkPhase13SourceContracts() {
    this.checkSourceContains("Phase 13 source", "PDV_DaedricPath_Hircine", [
      "Function RecordHuntRiteScaled(Float multiplier, String reason)",
      "AddCommitmentSignal(\"hunt_rite_\" + reason)",
      "AddStigma(HuntRiteStigmaDelta * appliedMultiplier, \"hunt_rite_\" + reason)",
      "Function RenouncePath(String reason)",
      "String Function GetPilotSummary()",
    ], this.phase13Gap.bind(this));

    this.checkSourceContains("Phase 13 source", "PDV__ManagerQuest", [
      "PDV_DaedricPath_Hircine Property PDV_HircinePath Auto",
      "PDV_CurseState Property PDV_CurseStateService Auto",
      "Function HandleHircineHuntRite(String reason)",
      "PDV_HircinePath.RecordHuntRiteScaled(multiplier, reason)",
      "Float Function GetDaedricStigmaGainMultiplier(PDV_DeityBase deity)",
      "Float stigma = PDV_HircinePath.GetStigma()",
    ], this.phase13Gap.bind(this));

    this.checkSourceContains("Phase 13 source", "PDV_EventBus", [
      "Function RouteHircineHuntRite()",
      "PDV_Manager.HandleHircineHuntRite(\"eventbus_\" + eventType)",
    ], this.phase13Gap.bind(this));
  }

  checkPhase14() {
    const manifest = this.checkPhase14Manifest();
    if (!manifest) {
      return;
    }

    this.checkPhase14SourceContracts();
  }

  checkPhase14Manifest() {
    if (!exists(PHASE14_COMMITMENT_MANIFEST)) {
      this.phase14Gap(
        "Phase 14 commitment manifest",
        "Phase 14 commitment pilot manifest is missing.",
        PHASE14_COMMITMENT_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE14_COMMITMENT_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 14 commitment manifest", `Manifest could not be parsed: ${error.message}`, PHASE14_COMMITMENT_MANIFEST);
      return null;
    }

    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase14-commitment-pilot"
      && parsed.pilot?.managerRecord === "PDV__ManagerQuest"
      && parsed.pilot?.deityRecord === "PDV_Deity_Kyne"
      && parsed.pilot?.stateGlobal === "PDV_GLO_PatronState"
      && ["kyne-pilot-live-generalization-deferred", "generalized-packet-live", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 14 commitment manifest",
        `Manifest locks the Kyne commitment pilot with status ${implementationStatus}.`,
        PHASE14_COMMITMENT_MANIFEST,
      );
    } else {
      this.phase14Gap(
        "Phase 14 commitment manifest",
        "Manifest does not match the current Kyne-first commitment pilot contract.",
        PHASE14_COMMITMENT_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase15() {
    const manifest = this.checkPhase15Manifest();
    if (!manifest) {
      return;
    }

    this.checkPhase15ServiceRecord();
    this.checkPhase15SourceContracts();
  }

  checkPhase15Manifest() {
    if (!exists(PHASE15_CURSE_OVERLAY_MANIFEST)) {
      this.phase15Gap(
        "Phase 15 curse manifest",
        "Phase 15 curse overlay manifest is missing.",
        PHASE15_CURSE_OVERLAY_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE15_CURSE_OVERLAY_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 15 curse manifest", `Manifest could not be parsed: ${error.message}`, PHASE15_CURSE_OVERLAY_MANIFEST);
      return null;
    }

    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase15-curse-overlay"
      && parsed.service?.record === "PDV_CurseState"
      && parsed.service?.global === "PDV_GLO_CurseState"
      && ["service-live-detection-deferred", "detection-live", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 15 curse manifest",
        `Manifest locks the curse service contract with status ${implementationStatus}.`,
        PHASE15_CURSE_OVERLAY_MANIFEST,
      );
    } else {
      this.phase15Gap(
        "Phase 15 curse manifest",
        "Manifest does not match the current curse service contract.",
        PHASE15_CURSE_OVERLAY_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase15ServiceRecord() {
    const service = this.recordsByEdid.get("PDV_CurseState");
    if (service?.type === "QUST") {
      this.pass("Phase 15 curse service", "PDV_CurseState exists as QUST.", PDV_ESP);
    } else {
      this.phase15Gap("Phase 15 curse service", "PDV_CurseState is missing or not a QUST.", PDV_ESP);
    }

    const global = this.recordsByEdid.get("PDV_GLO_CurseState");
    if (global?.type === "GLOB") {
      this.pass("Phase 15 curse global", "PDV_GLO_CurseState exists as GLOB.", PDV_ESP);
    } else {
      this.phase15Gap("Phase 15 curse global", "PDV_GLO_CurseState is missing or not a GLOB.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    if (managerDetail) {
      const managerScript = findScript(managerDetail.fields || {}, "PDV__ManagerQuest");
      if (managerScript) {
        const props = propertyMap(managerScript);
        this.checkObjectPropertyTarget("Phase 15 manager property", props, "PDV_CurseStateService", "PDV_CurseState", this.phase15Gap.bind(this));
      }
    }

    const mcmDetail = this.recordDetails.get("PDV_MCM");
    if (mcmDetail) {
      const mcmScript = findScript(mcmDetail.fields || {}, "PDV_MCM");
      if (mcmScript) {
        const props = propertyMap(mcmScript);
        this.checkObjectPropertyTarget("Phase 15 MCM property", props, "PDV_CurseStateService", "PDV_CurseState", this.phase15Gap.bind(this));
      }
    }
  }

  checkPhase15SourceContracts() {
    this.checkSourceContains("Phase 15 source", "PDV_CurseState", [
      "GlobalVariable Property PDV_GLO_CurseState Auto",
      "Function RefreshFromPlayerState()",
      "Int Function DetectCurseState(Actor playerRef)",
      "Bool Function IsWerewolfSignalActive(Actor playerRef)",
      "Bool Function IsVampireSignalActive(Actor playerRef)",
      "Function OnCurseStateChange(Int oldState, Int newState, String reason)",
    ], this.phase15Gap.bind(this));

    this.checkSourceContains("Phase 15 source", "PDV__ManagerQuest", [
      "PDV_CurseState Property PDV_CurseStateService Auto",
      "Float Function GetCurseGainMultiplier(PDV_DeityBase deity)",
      "if PDV_CurseStateService.IsWerewolf()",
      "elseIf PDV_CurseStateService.IsVampire()",
      "Function HandleCurseStateRefresh(String reason)",
      "Function HandleCurseStateTransition(Int oldState, Int newState, String reason)",
    ], this.phase15Gap.bind(this));

    this.checkSourceContains("Phase 15 source", "PDV_PlayerEvents", [
      "Event OnLycanthropyStateChanged(Bool abIsWerewolf)",
      "Event OnVampirismStateChanged(Bool abIsVampire)",
      "PDV_EventBusService.RouteCurseStateRefresh(reason)",
    ], this.phase15Gap.bind(this));

    this.checkSourceContains("Phase 15 source", "PDV_EventBus", [
      "Function RouteCurseStateRefresh(String reason)",
      "PDV_Manager.HandleCurseStateRefresh(\"eventbus_\" + reason)",
    ], this.phase15Gap.bind(this));

    this.checkSourceContains("Phase 15 source", "PDV_MCM", [
      "String Function RunCurseStateSmoke()",
      "PDV_CurseStateService.SetCurseState(PDV_CurseStateService.CURSE_UNKNOWN, \"mcm_scaffold_smoke\")",
    ], this.phase15Gap.bind(this));
  }

  checkPhase16() {
    const manifest = this.checkPhase16Manifest();
    if (!manifest) {
      return;
    }

    this.checkPhase16SourceContracts();
  }

  checkPhase17() {
    const manifest = this.checkPhase17Manifest();
    if (!manifest) {
      return;
    }

    this.checkPhase17SourceContracts();
  }

  checkPhase16Manifest() {
    if (!exists(PHASE16_NEGLECT_MANIFEST)) {
      this.phase16Gap(
        "Phase 16 neglect manifest",
        "Phase 16 neglect pilot manifest is missing.",
        PHASE16_NEGLECT_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE16_NEGLECT_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 16 neglect manifest", `Manifest could not be parsed: ${error.message}`, PHASE16_NEGLECT_MANIFEST);
      return null;
    }

    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase16-neglect-pilot"
      && parsed.pilot?.managerRecord === "PDV__ManagerQuest"
      && parsed.pilot?.spell === "PDV_SPEL_Neglect_Kyne"
      && parsed.pilot?.magicEffect === "PDV_MGEF_Neglect_Kyne"
      && ["kyne-live-generalization-deferred", "generalized-packet-live", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 16 neglect manifest",
        `Manifest locks the Kyne neglect pilot with status ${implementationStatus}.`,
        PHASE16_NEGLECT_MANIFEST,
      );
    } else {
      this.phase16Gap(
        "Phase 16 neglect manifest",
        "Manifest does not match the current Kyne-first neglect pilot contract.",
        PHASE16_NEGLECT_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase17Manifest() {
    if (!exists(PHASE17_DECAY_MODEL_MANIFEST)) {
      this.phase17Gap(
        "Phase 17 decay manifest",
        "Phase 17 decay model manifest is missing.",
        PHASE17_DECAY_MODEL_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE17_DECAY_MODEL_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 17 decay manifest", `Manifest could not be parsed: ${error.message}`, PHASE17_DECAY_MODEL_MANIFEST);
      return null;
    }

    const implementationStatus = parsed.implementationStatus;
    if (
      parsed.id === "phase17-decay-model"
      && parsed.model?.managerRecord === "PDV__ManagerQuest"
      && parsed.model?.decayPerDayValue === 0.5
      && parsed.model?.broadWorshipMultiplierValue === 0.2
      && ["source-readback", "runtime-proven"].includes(implementationStatus)
    ) {
      this.pass(
        "Phase 17 decay manifest",
        `Manifest locks the decay model with status ${implementationStatus}.`,
        PHASE17_DECAY_MODEL_MANIFEST,
      );
    } else {
      this.phase17Gap(
        "Phase 17 decay manifest",
        "Manifest does not match the current decay model contract.",
        PHASE17_DECAY_MODEL_MANIFEST,
      );
    }

    return parsed;
  }

  checkPhase14SourceContracts() {
    this.checkSourceContains("Phase 14 source", "PDV__ManagerQuest", [
      "Function EvaluateFormalCommitmentOffer()",
      "PDV_DeityBase Function GetBestFormalCommitmentOfferCandidate()",
      "Bool Function IsEligibleForFormalCommitmentOffer(PDV_DeityBase deity)",
      "Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)",
      "Function DebugAcceptPendingCommitment()",
    ], this.phase14Gap.bind(this));

    this.checkSourceContains("Phase 14 source", "PDV_MCM", [
      "AddTextOption(\"Evaluate commitment\", \"Dawn-equivalent\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Accept commitment\", \"Carry-over\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Decline commitment\", \"Postpone\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Refuse commitment\", \"Cooldown\", OPTION_FLAG_NONE)",
      "manager.DebugEvaluateCommitmentOffer()",
      "manager.DebugAcceptPendingCommitment()",
      "manager.DebugDeclinePendingCommitment()",
      "manager.DebugRefusePendingCommitment()",
    ], this.phase14Gap.bind(this));
  }

  checkPhase16SourceContracts() {
    this.checkSourceContains("Phase 16 source", "PDV__ManagerQuest", [
      "Int Property NEGLECT_ACTIVE_CAP = 3 AutoReadOnly",
      "Function RunDawnApplySpellAndNeglectLayers()",
      "if IsBroadWorshipActive()",
      "Int activeCount = ApplyGenericNeglectFlags()",
      "Int Function ApplyGenericNeglectFlags()",
      "Bool Function IsEligibleForNeglectSelection(PDV_DeityBase deity)",
      "SyncKyneNeglectSpell(IsNeglectFlagActive(PDV_Kyne))",
    ], this.phase16Gap.bind(this));
  }

  checkPhase17SourceContracts() {
    this.checkSourceContains("Phase 17 source", "PDV__ManagerQuest", [
      "Float Property PIETY_DAILY_MAX_DELTA = 4.3 AutoReadOnly",
      "Float Property DECAY_GRACE_DAYS = 2.0 AutoReadOnly",
      "Float Property DECAY_PER_DAY = 0.5 AutoReadOnly",
      "Float Property BROAD_WORSHIP_DECAY_MULTIPLIER = 0.2 AutoReadOnly",
      "Float Property GAIN_RATE_SCALE = 1.32 AutoReadOnly",
      "Float Property TIER_DOWN_HYSTERESIS = 5.0 AutoReadOnly",
      "Float Property ORC_RATE_MULT_CITY = 0.75 AutoReadOnly",
      "Function RunDawnApplyDecay()",
      "Function ApplyDecayToDeity(PDV_DeityBase deity, Float nowTime)",
      "if GetPatronState() == PATRON_STATE_ACTIVE && deity == _activeDeity",
      "StorageUtil.GetIntValue(deityForm, \"PDV.LastDecayAppliedDay\") == currentDay",
      "deity.GetEffectiveDecayMultiplier()",
      "GetCurseGainMultiplier(deity)",
      "GetDaedricStigmaGainMultiplier(deity)",
      "Function GetDecayFloorForDeity(PDV_DeityBase deity, Float currentPiety)",
      "PDV_CurseStateService.IsVampire() && deity.IsAedric",
      "StorageUtil.GetFloatValue(deity as Form, \"PDV.PassiveDecayFloor\")",
      "Function GetDecayFloorForTier(PDV_DeityBase deity, Int tierValue)",
      "Function RefreshPassiveDecayFloorForDeity(PDV_DeityBase deity, Int tierValue)",
      "StorageUtil.SetFloatValue(deityForm, \"PDV.PassiveDecayFloor\", tierFloor)",
      "Function DebugPrimeDecayGraceByIndex(Int deityIndex)",
      "Function DebugPrimeDecayEligibleByIndex(Int deityIndex)",
      "Function DebugRunDecayPass()",
      "Function DebugRunDecayProofDaysByIndex(Int deityIndex)",
      "String Function DebugGetDecaySummaryByIndex(Int deityIndex)",
      "Function GetOrcLifeModeGainMultiplier(PDV_DeityBase deity)",
      "Function ThresholdForTier(PDV_DeityBase deity, Int tierValue)",
    ], this.phase17Gap.bind(this));

    this.checkSourceContains("Phase 17 MCM source", "PDV_MCM", [
      "AddTextOption(\"Prime decay grace\", \"Proof\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Prime decay eligible\", \"Proof\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Run decay pass\", \"Targeted\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Run decay proof days\", \"Compressed\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Show decay summary\", \"Selected deity\", OPTION_FLAG_NONE)",
      "manager.DebugPrimeDecayGraceByIndex(selectedDeity.DeityIndex)",
      "manager.DebugPrimeDecayEligibleByIndex(selectedDeity.DeityIndex)",
      "manager.DebugRunDecayPass()",
      "manager.DebugRunDecayProofDaysByIndex(selectedDeity.DeityIndex)",
      "PDV_Manager.DebugGetDecaySummaryByIndex(deity.DeityIndex)",
    ], this.phase17Gap.bind(this));
  }

  checkPhase18() {
    const manifest = this.checkPhase18Manifest();
    this.checkPhase18SourceContracts();
    this.checkPhase18Records();
    this.checkPhase18ManagerRecord();
    this.checkPhase18SurveyEffectRecord();
    this.checkPhase18SpellEffect();
    this.checkPhase18DialogueContracts(manifest);
  }

  checkPhase18Manifest() {
    if (!exists(PHASE18_STATUS_NORD_MANIFEST)) {
      this.phase18Gap("Phase 18 status/Nord manifest", "Phase 18 status/Nord manifest is missing.", PHASE18_STATUS_NORD_MANIFEST);
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE18_STATUS_NORD_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 18 status/Nord manifest", `Manifest could not be parsed: ${error.message}`, PHASE18_STATUS_NORD_MANIFEST);
      return null;
    }

    const hasSurvey = parsed.survey?.spell === "PDV_SPEL_SurveyDevotion"
      && parsed.survey?.magicEffect === "PDV_MGEF_SurveyDevotion"
      && parsed.survey?.script === "PDV_SurveyDevotionEffect";
    const hasMessages = Array.isArray(parsed.messages)
      && ["PDV_Msg_Nord_CurseState_WerewolfOnset", "PDV_Msg_Nord_CurseState_VampireOnset", "PDV_Msg_Nord_CurseState_VampireCured"]
        .every((edid) => parsed.messages.some((message) => message.editorId === edid));
    const contracts = parsed.dialogue?.contracts || [];
    const hasDialogueContracts = PHASE18_NORD_DIALOGUE_CONTRACTS.every((expected) =>
      contracts.some((actual) =>
        actual.id === expected.id
        && actual.topic === expected.topic
        && actual.speaker === expected.speaker
        && actual.prompt === expected.prompt
        && actual.response === expected.response,
      ),
    );
    const systemCases = parsed.runtimeMatrix?.systemCases || [];
    const dialogueCases = parsed.runtimeMatrix?.dialogueCases || [];
    const runtimeMatrixStatuses = ["planned-pending-runtime-proof", "runtime-proven"];
    const hasRuntimeMatrix = runtimeMatrixStatuses.includes(parsed.runtimeMatrix?.status)
      && PHASE18_SYSTEM_RUNTIME_CASES.every((id) => systemCases.some((actual) => actual.id === id))
      && PHASE18_DIALOGUE_RUNTIME_CASES.every((id) => dialogueCases.some((actual) => actual.id === id));

    if (hasSurvey && hasMessages && hasDialogueContracts && hasRuntimeMatrix) {
      this.pass("Phase 18 status/Nord manifest", `Manifest locks Survey Devotion, Nord curse messages, dialogue contracts, and runtime matrix with status ${parsed.runtimeMatrix?.status}.`, PHASE18_STATUS_NORD_MANIFEST);
    } else {
      this.phase18Gap("Phase 18 status/Nord manifest", `Manifest contract mismatch: survey=${hasSurvey}, messages=${hasMessages}, dialogue=${hasDialogueContracts}, runtimeMatrix=${hasRuntimeMatrix}.`, PHASE18_STATUS_NORD_MANIFEST);
    }

    return parsed;
  }

  checkPhase18SourceContracts() {
    this.checkSourceContains("Phase 18 status source", "PDV_SurveyDevotionEffect", [
      "Scriptname PDV_SurveyDevotionEffect extends ActiveMagicEffect",
      "PDV__ManagerQuest Property PDV_Manager Auto",
      "PDV_Manager.GetSurveyDevotionText()",
    ], this.phase18Gap.bind(this));

    this.checkSourceContains("Phase 18 manager source", "PDV__ManagerQuest", [
      "Spell Property PDV_SPEL_SurveyDevotion Auto",
      "Function EnsureSurveyDevotionPower()",
      "GetEquippedShout() == None",
      "EquipSpell(PDV_SPEL_SurveyDevotion, 2)",
      "String Function GetSurveyDevotionText()",
      "Bool Function IsNordVampireSuppressed()",
      "PDV.Nord.VampireScar",
      "ClearActiveFavor(\"nord_vampire\")",
      "ClearPendingCommitment()",
    ], this.phase18Gap.bind(this));

    this.checkSourceContains("Phase 18 MCM source", "PDV_MCM", [
      "String Property PAGE_PLAYER = \"Player\" AutoReadOnly",
      "Developer Options",
      "Survey Devotion",
      "Enable Developer Options on the Player page to view this page.",
      "PDV.UI.DeveloperOptions",
    ], this.phase18Gap.bind(this));
  }

  checkPhase18Records() {
    for (const [edid, expectedType] of Object.entries(PHASE18_RECORDS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.phase18Gap("Phase 18 record", `${expectedType} record ${edid} is missing.`, PDV_ESP);
        continue;
      }
      if (record.type !== expectedType) {
        this.fail("Phase 18 record", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("Phase 18 record", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }
  }

  checkPhase18ManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    const script = detail ? findScript(detail.fields || {}, "PDV__ManagerQuest") : null;
    if (!script) {
      this.phase18Gap("Phase 18 manager property", "PDV__ManagerQuest script readback is missing.", PDV_ESP);
      return;
    }
    this.checkObjectProperties("Phase 18 manager property", propertyMap(script), PHASE18_MANAGER_PROPERTIES);
  }

  checkPhase18SurveyEffectRecord() {
    const detail = this.recordDetails.get("PDV_MGEF_SurveyDevotion");
    const script = detail ? findScript(detail.fields || {}, "PDV_SurveyDevotionEffect") : null;
    if (!script) {
      this.phase18Gap("Phase 18 Survey effect script", "PDV_SurveyDevotionEffect is not attached to PDV_MGEF_SurveyDevotion.", PDV_ESP);
      return;
    }
    this.pass("Phase 18 Survey effect script", "PDV_SurveyDevotionEffect is attached to PDV_MGEF_SurveyDevotion.", PDV_ESP);
    this.checkObjectProperties("Phase 18 Survey effect property", propertyMap(script), PHASE18_EFFECT_PROPERTIES);
  }

  checkPhase18SpellEffect() {
    const detail = this.recordDetails.get("PDV_SPEL_SurveyDevotion");
    const effects = detail?.fields?.Effects || [];
    const hasEffect = effects.some((effect) => formidToEdid(effect.BaseEffect, this.recordsByEdid) === "PDV_MGEF_SurveyDevotion");
    if (hasEffect && detail?.fields?.Type === "LesserPower") {
      this.pass("Phase 18 Survey spell", "PDV_SPEL_SurveyDevotion is a LesserPower using PDV_MGEF_SurveyDevotion.", PDV_ESP);
    } else {
      this.phase18Gap("Phase 18 Survey spell", `Survey spell readback mismatch: type=${detail?.fields?.Type || "missing"}, effect=${hasEffect}.`, PDV_ESP);
    }
  }

  checkPhase18DialogueContracts(manifest) {
    const status = manifest?.dialogue?.implementationStatus || "missing";
    if (status !== "live-dialogue-authored") {
      this.info("Phase 18 Nord dialogue records", `Live dialogue readback is skipped because dialogue implementationStatus is ${status}.`, PHASE18_STATUS_NORD_MANIFEST);
      return;
    }

    for (const contract of PHASE18_NORD_DIALOGUE_CONTRACTS) {
      const branchRecord = this.recordsByEdid.get(contract.branch);
      const topic = this.recordsByEdid.get(contract.topic);
      const branchFields = this.recordDetails.get(contract.branch)?.fields || {};
      const topicFields = this.recordDetails.get(contract.topic)?.fields || {};
      const infoCandidate = this.resolvePhase18NordDialogueInfo(contract, topicFields);

      if (branchRecord?.type === "DLBR") {
        this.pass("Phase 18 Nord dialogue branch", `${contract.branch} exists for ${contract.speaker}.`, PDV_ESP);
      } else {
        this.phase18Gap("Phase 18 Nord dialogue branch", `${contract.branch} is missing or not a DLBR record.`, PDV_ESP);
      }
      if (
        branchFields.Quest === this.recordsByEdid.get("PDV__ManagerQuest")?.formid
        && branchFields.Category === "Player"
        && branchFields.Flags === "TopLevel"
        && branchFields.StartingTopic === topic?.formid
      ) {
        this.pass("Phase 18 Nord dialogue branch", `${contract.branch} is a player top-level branch owned by PDV__ManagerQuest.`, PDV_ESP);
      } else {
        this.phase18Gap("Phase 18 Nord dialogue branch", `${contract.branch} ownership, flags, category, or starting topic do not match the contract.`, PDV_ESP);
      }

      if (topic?.type === "DIAL") {
        this.pass("Phase 18 Nord dialogue topic", `${contract.topic} exists for ${contract.speaker}.`, PDV_ESP);
      } else {
        this.phase18Gap("Phase 18 Nord dialogue topic", `${contract.topic} is missing or not a DIAL record.`, PDV_ESP);
      }
      if (
        topicFields.Quest === this.recordsByEdid.get("PDV__ManagerQuest")?.formid
        && topicFields.Branch === branchRecord?.formid
        && topicFields.Category === "Topic"
        && topicFields.Subtype === "Custom"
      ) {
        this.pass("Phase 18 Nord dialogue topic", `${contract.topic} is owned by PDV__ManagerQuest and linked to ${contract.branch}.`, PDV_ESP);
      } else {
        this.phase18Gap("Phase 18 Nord dialogue topic", `${contract.topic} quest, branch, category, or subtype do not match the contract.`, PDV_ESP);
      }

      this.checkPhase18NordDialogueInfo(contract, infoCandidate, topic?.formid);
    }
  }

  resolvePhase18NordDialogueInfo(contract, topic) {
    const topicResponses = Array.isArray(topic.Responses) ? topic.Responses : [];
    const topicInfo = topicResponses.find((candidate) =>
      candidate?.Prompt === contract.prompt
      && candidate?.Responses?.[0]?.Text === contract.response
      && this.hasSpeakerGate(candidate, contract.speakerFormid));
    const unnamedInfoRecord = [...this.recordsByFormid.values()].find((record) => {
      if (record.type !== "INFO" || record.edid) {
        return false;
      }
      const detail = this.recordDetailsByFormid.get(record.formid)?.fields || {};
      return detail.Prompt === contract.prompt
        && detail.Responses?.[0]?.Text === contract.response
        && this.hasSpeakerGate(detail, contract.speakerFormid);
    });

    if (topicInfo || unnamedInfoRecord) {
      return {
        record: unnamedInfoRecord || { type: "INFO", formid: null },
        fields: topicInfo || this.recordDetailsByFormid.get(unnamedInfoRecord.formid)?.fields || {},
        source: unnamedInfoRecord ? "CK-authored unnamed INFO" : "topic embedded INFO payload",
      };
    }

    return null;
  }

  checkPhase18NordDialogueInfo(contract, infoCandidate, topicFormid) {
    const info = infoCandidate?.fields || {};
    if (!info || !Object.keys(info).length) {
      this.phase18Gap("Phase 18 Nord dialogue info", `${contract.id} INFO detail readback is missing.`, PDV_ESP);
      return;
    }

    const topicMatches = !info.Topic || info.Topic === topicFormid;
    if (topicMatches && info.Prompt === contract.prompt) {
      this.pass("Phase 18 Nord dialogue info", `${contract.id} prompt matches (${infoCandidate.source}).`, PDV_ESP);
    } else {
      this.phase18Gap("Phase 18 Nord dialogue info", `${contract.id} prompt/topic readback does not match the contract.`, PDV_ESP);
    }

    const responseLine = info.Responses?.[0]?.Text;
    if (responseLine === contract.response) {
      this.pass("Phase 18 Nord dialogue info", `${contract.id} response line matches the locked text.`, PDV_ESP);
    } else {
      this.phase18Gap("Phase 18 Nord dialogue info", `${contract.id} response line is ${JSON.stringify(responseLine)}, expected ${JSON.stringify(contract.response)}.`, PDV_ESP);
    }

    const conditions = Array.isArray(info.Conditions) ? info.Conditions : [];
    const hasSpeakerCondition = this.hasSpeakerGate(info, contract.speakerFormid);
    const gateResults = contract.gates.map((gate) => ({
      label: gate.label,
      ok: this.hasGlobalCondition(conditions, gate.global, gate.op, gate.value),
    }));
    const missing = gateResults.filter((gate) => !gate.ok).map((gate) => gate.label);

    if (hasSpeakerCondition && missing.length === 0) {
      this.pass("Phase 18 Nord dialogue conditions", `${contract.id} gates on ${contract.speaker} plus ${contract.gates.map((gate) => gate.label).join(", ")}.`, PDV_ESP);
    } else {
      this.phase18Gap(
        "Phase 18 Nord dialogue conditions",
        `${contract.id} condition readback missing expected gates: speaker=${hasSpeakerCondition}, missing=${missing.join(", ") || "none"}.`,
        PDV_ESP,
      );
    }
  }

  checkOfflinePatcherRules() {
    if (!exists(PATCH_RULES_DIR)) {
      this.info("Offline patch rule manifests", "Patch-rules directory is not present yet.", PATCH_RULES_DIR);
      return;
    }

    const files = fs.readdirSync(PATCH_RULES_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".json"))
      .map((entry) => path.join(PATCH_RULES_DIR, entry.name))
      .sort((left, right) => left.localeCompare(right));

    if (!files.length) {
      this.info("Offline patch rule manifests", "Patch-rules directory exists but has no JSON manifests yet.", PATCH_RULES_DIR);
      return;
    }

    this.pass("Offline patch rule manifests", `Found ${files.length} patch-rule manifest(s).`, PATCH_RULES_DIR);
    for (const filePath of files) {
      try {
        const parsed = JSON.parse(fs.readFileSync(filePath, "utf8"));
        if (parsed.ruleType === "pdv_patch_rules_v0" && Array.isArray(parsed.rules)) {
          this.pass("Offline patch rule manifest", `${path.basename(filePath)} parsed and declares pdv_patch_rules_v0.`, filePath);
        } else {
          this.warn("Offline patch rule manifest", `${path.basename(filePath)} parsed, but does not look like a pdv_patch_rules_v0 manifest.`, filePath);
        }
      } catch (error) {
        this.fail("Offline patch rule manifest", `${path.basename(filePath)} could not be parsed: ${error.message}`, filePath);
      }
    }

    this.checkOfflinePatcherDryRun();
  }

  checkOfflinePatcherDryRun() {
    const patcherPath = path.join(PROJECT_ROOT, "tools", "pdv_patch.mjs");
    if (!exists(patcherPath)) {
      this.phase19Gap("Phase 19 patcher dry-run", "tools/pdv_patch.mjs is missing.", patcherPath);
      return;
    }

    const result = spawnSync(process.execPath, [patcherPath, "build", "--dry-run", "--json"], {
      cwd: PROJECT_ROOT,
      encoding: "utf8",
      timeout: 120_000,
      windowsHide: true,
      maxBuffer: 128 * 1024 * 1024,
    });

    if (result.error) {
      this.phase19Gap("Phase 19 patcher dry-run", `pdv_patch build --dry-run failed to run: ${result.error.message}`, patcherPath);
      return;
    }
    if (result.status !== 0) {
      this.phase19Gap("Phase 19 patcher dry-run", `pdv_patch build --dry-run exited ${result.status}: ${(result.stderr || result.stdout || "").slice(0, 500)}`, patcherPath);
      return;
    }

    let parsed;
    try {
      parsed = JSON.parse(result.stdout);
    } catch (error) {
      this.phase19Gap("Phase 19 patcher dry-run", `pdv_patch JSON output could not be parsed: ${error.message}`, patcherPath);
      return;
    }

    if (
      parsed.schema === "pdv_patch_rules_v0"
        && parsed.summary?.buildReady >= PHASE19_TEMPLE_LOCATION_RECORDS.length
        && parsed.summary?.buildBlocked === 0
        && parsed.build?.patchRecordCount === PHASE19_TEMPLE_LOCATION_RECORDS.length
        && parsed.build?.buildRuleCount === PHASE19_TEMPLE_LOCATION_RECORDS.length
    ) {
      this.pass("Phase 19 patcher dry-run", `Dry-run emits ${parsed.build.patchRecordCount} approved Temple LCTN patch record(s), keeps ${parsed.summary.planOnly} proof/tooling rule(s) plan-only, and has ${parsed.summary.buildBlocked} build-blocked rule(s).`, patcherPath);
    } else {
      this.phase19Gap("Phase 19 patcher dry-run", `Unexpected dry-run summary: ${JSON.stringify(parsed.summary || {})}.`, patcherPath);
    }

    if (parsed.build?.patchRequest?.output_path?.replace(/\\/g, "/").endsWith("/PDV_ClassificationPatch.esp")) {
      this.pass("Phase 19 patch request", `Dry-run generated ${parsed.build.patchRecordCount} patch record(s) for PDV_ClassificationPatch.esp.`, patcherPath);
    } else {
      this.phase19Gap("Phase 19 patch request", "Dry-run did not produce the expected PDV_ClassificationPatch.esp patch request.", patcherPath);
    }
  }

  checkPhase19GeneratedPatch() {
    if (!exists(PHASE19_PROOF_RULE_MANIFEST)) {
      this.phase19Gap("Phase 19 proof rules", "Phase 19 proof rule manifest is missing.", PHASE19_PROOF_RULE_MANIFEST);
      return;
    }
    if (!exists(PHASE19_TEMPLE_RULE_MANIFEST)) {
      this.phase19Gap("Phase 19 Temple rules", "Approved Phase 19 Temple LCTN rule manifest is missing.", PHASE19_TEMPLE_RULE_MANIFEST);
      return;
    }

    if (!exists(PHASE19_GENERATED_PATCH)) {
      this.phase19Gap("Phase 19 generated patch", "PDV_ClassificationPatch.esp has not been generated yet.", PHASE19_GENERATED_PATCH);
      return;
    }

    let scan;
    try {
      scan = this.scanPlugin(PHASE19_GENERATED_PATCH);
    } catch (error) {
      this.phase19Gap("Phase 19 generated patch", `Generated patch scan failed: ${error.message}`, PHASE19_GENERATED_PATCH);
      return;
    }

    const plugin = scan.plugin;
    const masters = plugin.masters || [];
    if (plugin.is_light && masters.includes("Skyrim.esm") && masters.includes("Dawnguard.esm")) {
      this.pass("Phase 19 generated patch", "PDV_ClassificationPatch.esp is ESL-flagged and carries the expected Skyrim/Dawnguard masters.", PHASE19_GENERATED_PATCH);
    } else {
      this.phase19Gap("Phase 19 generated patch", `Generated patch flags/masters mismatch: is_light=${plugin.is_light}, masters=${masters.join(", ")}.`, PHASE19_GENERATED_PATCH);
    }

    const activePlugins = exists(DEV_PROFILE_PLUGINS) ? readLines(DEV_PROFILE_PLUGINS).map((line) => line.trim().toLowerCase()) : [];
    if (activePlugins.includes("*pdv_classificationpatch.esp")) {
      this.pass("Phase 19 generated patch profile", "PDV_ClassificationPatch.esp is active in the Devotion Dev profile.", DEV_PROFILE_PLUGINS);
    } else {
      this.phase19Gap("Phase 19 generated patch profile", "PDV_ClassificationPatch.esp is not active in the Devotion Dev profile.", DEV_PROFILE_PLUGINS);
    }

    const loadorder = exists(DEV_PROFILE_LOADORDER) ? readLines(DEV_PROFILE_LOADORDER).map((line) => line.trim()).filter((line) => line && !line.startsWith("#")) : [];
    const frameworkIndex = loadorder.findIndex((line) => line.toLowerCase() === "playerdevotion_framework.esp");
    const patchIndex = loadorder.findIndex((line) => line.toLowerCase() === "pdv_classificationpatch.esp");
    if (frameworkIndex >= 0 && patchIndex === frameworkIndex + 1) {
      this.pass("Phase 19 generated patch load order", "PDV_ClassificationPatch.esp is listed immediately after Devotion.esp.", DEV_PROFILE_LOADORDER);
    } else {
      this.phase19Gap("Phase 19 generated patch load order", "PDV_ClassificationPatch.esp is not listed immediately after Devotion.esp.", DEV_PROFILE_LOADORDER);
    }

    for (const location of PHASE19_TEMPLE_LOCATION_RECORDS) {
      const locationPatch = this.readPluginRecordDetail(PHASE19_GENERATED_PATCH, location.formid)?.fields || {};
      const keywords = normalizeStringList(locationPatch.Keywords || []);
      if (keywords.includes(PHASE19_TEMPLE_KEYWORD)) {
        this.pass("Phase 19 Temple LCTN readback", `Generated patch adds LocTypeTemple to ${location.edid}.`, PHASE19_GENERATED_PATCH);
      } else {
        this.phase19Gap("Phase 19 Temple LCTN readback", `Generated patch is missing LocTypeTemple on ${location.edid}.`, PHASE19_GENERATED_PATCH);
      }
    }

    if (!scan.recordsByFormid.has(PHASE19_PROOF_BOOK_FORMID)) {
      this.pass("Phase 19 proof override absence", "Generated live patch does not include the retired MQ103FarengarBook proof override.", PHASE19_GENERATED_PATCH);
    } else {
      this.phase19Gap("Phase 19 proof override absence", "Generated live patch still includes the retired MQ103FarengarBook proof override.", PHASE19_GENERATED_PATCH);
    }
    if (!scan.recordsByFormid.has(PHASE19_PROOF_STATE_LIST_FORMID)) {
      this.pass("Phase 19 proof override absence", "Generated live patch does not include the retired state-track FormList proof override.", PHASE19_GENERATED_PATCH);
    } else {
      this.phase19Gap("Phase 19 proof override absence", "Generated live patch still includes the retired state-track FormList proof override.", PHASE19_GENERATED_PATCH);
    }

    this.checkPhase19SourcePluginNotMutated();
  }

  checkPhase19SourcePluginNotMutated() {
    const bookSource = this.readPluginRecordDetail(SKYRIM_ESM, PHASE19_PROOF_BOOK_FORMID)?.fields || {};
    const sourceBookKeywords = normalizeStringList(bookSource.Keywords || []);
    if (!sourceBookKeywords.includes(PHASE19_PROOF_BOOK_KEYWORD)) {
      this.pass("Phase 19 source plugin safety", "Skyrim.esm does not contain the retired proof-only LocTypeTemple book keyword.", SKYRIM_ESM);
    } else {
      this.phase19Gap("Phase 19 source plugin safety", "Skyrim.esm unexpectedly contains the retired proof-only book keyword.", SKYRIM_ESM);
    }

    for (const location of PHASE19_TEMPLE_LOCATION_RECORDS) {
      const locationSource = this.readPluginRecordDetail(location.sourcePath, location.formid)?.fields || {};
      const sourceKeywords = normalizeStringList(locationSource.Keywords || []);
      if (!sourceKeywords.includes(PHASE19_TEMPLE_KEYWORD)) {
        this.pass("Phase 19 source plugin safety", `${location.sourcePlugin} source record ${location.edid} remains unmodified; the generated patch owns LocTypeTemple.`, location.sourcePath);
      } else {
        this.phase19Gap("Phase 19 source plugin safety", `${location.sourcePlugin} source record ${location.edid} unexpectedly contains LocTypeTemple.`, location.sourcePath);
      }
    }

    const listSource = this.readPluginRecordDetail(PDV_ESP, PHASE19_PROOF_STATE_LIST_FORMID)?.fields || {};
    const sourceListItems = normalizeStringList(listSource.Items || []);
    if (!sourceListItems.includes(PHASE19_PROOF_STATE_TRACK_FORMID)) {
      this.pass("Phase 19 source plugin safety", "Devotion.esp does not contain the retired proof-only state-track list injection.", PDV_ESP);
    } else {
      this.phase19Gap("Phase 19 source plugin safety", "Devotion.esp unexpectedly contains the retired proof-only state-track list injection.", PDV_ESP);
    }
  }

  checkPhase21RosterCoverage() {
    const findings = verifyPhase21RosterCoverage(PROJECT_ROOT, {
      strictContentReady: this.strictPhase20Roster,
    });
    for (const finding of findings) {
      const filePath = finding.path || PHASE20_DEITY_COVERAGE_MANIFEST;
      if (finding.status === "PASS") {
        this.pass(finding.check, finding.detail, filePath);
      } else if (finding.status === "INFO") {
        this.info(finding.check, finding.detail, filePath);
      } else if (finding.status === "WARN") {
        this.warn(finding.check, finding.detail, filePath);
      } else {
        this.phase20RosterGap(finding.check, finding.detail, filePath);
      }
    }
  }

  checkPhase20MedallionRoster() {
    let manifest;
    try {
      manifest = JSON.parse(fs.readFileSync(PHASE20_MEDALLION_ROSTER_MANIFEST, "utf8"));
    } catch (error) {
      this.phase20RosterGap(
        "Phase 20 medallion roster manifest",
        `Could not parse medallion roster manifest: ${error.message}`,
        PHASE20_MEDALLION_ROSTER_MANIFEST,
      );
      return;
    }

    if (
      manifest.schema === "pdv-medallion-roster.v1"
      && manifest.id === "phase20-medallion-native-roster"
      && manifest.runtimePolicy?.selectablePolicy === "requires-live-scorable-deity"
      && manifest.runtimePolicy?.unwiredEntryPolicy === "visible-disabled"
    ) {
      this.pass("Phase 20 medallion roster manifest", "Manifest owns native roster intent with live-readback selectability policy.", PHASE20_MEDALLION_ROSTER_MANIFEST);
    } else {
      this.phase20RosterGap(
        "Phase 20 medallion roster manifest",
        "Manifest identity or runtime policy does not match the intent-plus-readback contract.",
        PHASE20_MEDALLION_ROSTER_MANIFEST,
      );
    }

    const raceEntries = Array.isArray(manifest.races) ? manifest.races : [];
    const raceIds = raceEntries.map((race) => race.raceId).filter(Boolean);
    const expectedRaces = ["nord", "imperial", "breton", "altmer", "bosmer", "dunmer", "khajiit", "argonian", "orc", "redguard"];
    const missingRaces = expectedRaces.filter((race) => !raceIds.includes(race));
    if (missingRaces.length) {
      this.phase20RosterGap("Phase 20 medallion race coverage", `Missing medallion race roster(s): ${missingRaces.join(", ")}.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
    } else {
      this.pass("Phase 20 medallion race coverage", "Medallion manifest declares all ten race rosters.", PHASE20_MEDALLION_ROSTER_MANIFEST);
    }

    const entries = this.collectMedallionEntries(manifest);
    if (entries.length >= 60) {
      this.pass("Phase 20 medallion entry coverage", `Medallion manifest declares ${entries.length} visible roster entry surfaces.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
    } else {
      this.phase20RosterGap("Phase 20 medallion entry coverage", `Medallion manifest only declares ${entries.length} entries; expected the full native roster surface.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
    }

    const allDeities = this.recordDetails.get("PDV_FLST_AllDeities");
    const allDeityItems = new Set(allDeities?.fields?.Items || []);
    if (allDeities) {
      this.pass("Phase 20 medallion readback", `Read PDV_FLST_AllDeities with ${allDeityItems.size} live scorable member(s).`, PDV_ESP);
    } else {
      this.phase20RosterGap("Phase 20 medallion readback", "PDV_FLST_AllDeities readback is missing; selectable medallion entries cannot be proven.", PDV_ESP);
    }

    const missingSymbols = new Set();
    const symbolKeys = this.readPrismaSymbolKeys();
    const liveSelectableRecords = new Set();
    for (const entry of entries) {
      const label = `${entry.raceId}/${entry.optionId}`;
      if (entry.visible !== true) {
        this.phase20RosterGap("Phase 20 medallion visibility", `${label} is not marked visible; native roster entries must be visible even while pending.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
      }

      if (!entry.title || !entry.summary || !entry.description || !entry.symbol || !entry.kind) {
        this.phase20RosterGap("Phase 20 medallion entry shape", `${label} is missing title, summary, description, symbol, or kind.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
      }

      if (entry.symbol && !symbolKeys.has(entry.symbol)) {
        missingSymbols.add(entry.symbol);
      }

      if (entry.selectable === true) {
        if (!entry.deityRecord) {
          this.phase20RosterGap("Phase 20 medallion selectability", `${label} is selectable without a deityRecord.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
          continue;
        }

        const record = this.recordsByEdid.get(entry.deityRecord);
        if (!record) {
          this.phase20RosterGap("Phase 20 medallion selectability", `${label} points at missing record ${entry.deityRecord}.`, PDV_ESP);
          continue;
        }

        if (!allDeityItems.has(record.formid)) {
          this.phase20RosterGap("Phase 20 medallion selectability", `${label} points at ${entry.deityRecord}, but it is not in PDV_FLST_AllDeities.`, PDV_ESP);
          continue;
        }

        liveSelectableRecords.add(entry.deityRecord);
      } else if (!entry.disabledReason) {
        this.phase20RosterGap("Phase 20 medallion disabled entry", `${label} is not selectable and lacks disabledReason.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
      }
    }

    if (missingSymbols.size) {
      this.warn("Phase 20 medallion glyph fallback", `Medallion entries will fall back to journal until glyphs land: ${[...missingSymbols].sort().join(", ")}.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
    } else {
      this.pass("Phase 20 medallion glyph coverage", "All medallion symbols resolve in the Prisma UI glyph table.", PHASE20_MEDALLION_ROSTER_MANIFEST);
    }

    const liveDeityEdids = [...allDeityItems]
      .map((formid) => formidToEdid(formid, this.recordsByEdid))
      .filter(Boolean)
      .filter((edid) => edid.startsWith("PDV_Deity_"));
    const unrepresentedLive = liveDeityEdids.filter((edid) => !liveSelectableRecords.has(edid));
    if (unrepresentedLive.length) {
      this.info("Phase 20 medallion live roster", `Live scorable deity record(s) not selectable in the medallion manifest: ${unrepresentedLive.join(", ")}.`, PHASE20_MEDALLION_ROSTER_MANIFEST);
    } else {
      this.pass("Phase 20 medallion live roster", "Every live scorable deity record is represented by at least one selectable medallion entry.", PHASE20_MEDALLION_ROSTER_MANIFEST);
    }

    this.checkSourceContains("Phase 20 medallion manager source", "PDV__ManagerQuest", [
      "Function SendPrismaMedallionPayload(Int originRace)",
      "Bool Function SelectMedallionEntry(String optionId)",
      "Bool Function CanSelectMedallionEntry(String optionId)",
      "String Function GetMedallionSectionsJson(Int originRace)",
      "Bool Function IsMedallionDeitySelectable(PDV_DeityBase deity)",
    ], this.phase20RosterGap.bind(this));

    const livePrismaApp = path.join(DEVOTION_MOD, "PrismaUI", "views", "Devotion", "app.js");
    if (exists(livePrismaApp)) {
      const livePrismaSource = fs.readFileSync(livePrismaApp, "utf8");
      const requiredSnippets = [
        "const renderMedallion = (medallion = {}) =>",
        "payload.mode === \"startup\" || payload.mode === \"medallion\"",
        "window.PDVDemoMedallion",
      ];
      for (const snippet of requiredSnippets) {
        if (livePrismaSource.includes(snippet)) {
          this.pass("Phase 20 medallion Prisma source", `Live Prisma app contains ${snippet}.`, livePrismaApp);
        } else {
          this.phase20RosterGap("Phase 20 medallion Prisma source", `Live Prisma app is missing ${snippet}.`, livePrismaApp);
        }
      }
    } else {
      this.phase20RosterGap("Phase 20 medallion Prisma source", "Live Prisma app.js is missing.", livePrismaApp);
    }
  }

  collectMedallionEntries(manifest) {
    const entries = [];
    for (const race of Array.isArray(manifest.races) ? manifest.races : []) {
      for (const section of Array.isArray(race.sections) ? race.sections : []) {
        for (const entry of Array.isArray(section.entries) ? section.entries : []) {
          entries.push({
            ...entry,
            raceId: race.raceId || "",
            sectionId: section.sectionId || "",
          });
        }
      }
    }
    return entries;
  }

  readPrismaSymbolKeys() {
    const appJsPath = path.join(PROJECT_ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "app.js");
    const keys = new Set(["journal"]);
    if (!exists(appJsPath)) {
      return keys;
    }

    const source = fs.readFileSync(appJsPath, "utf8");
    const symbolBlock = source.match(/const symbolSpecs = \{([\s\S]*?)\n  \};/);
    if (!symbolBlock) {
      return keys;
    }

    for (const line of symbolBlock[1].split(/\r?\n/)) {
      const match = line.match(/^\s{4}(?:"([^"]+)"|([A-Za-z0-9_-]+)):\s*\[/);
      if (match) {
        keys.add(match[1] || match[2]);
      }
    }
    return keys;
  }

  checkPhase20AltmerImplementationCosting() {
    if (!exists(PHASE20_ALTMER_IMPLEMENTATION_MANIFEST)) {
      this.phase20AltmerGap(
        "Phase 20 Altmer costing manifest",
        "Altmer implementation-costing manifest is missing.",
        PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
      );
      return;
    }

    let manifest;
    try {
      manifest = JSON.parse(fs.readFileSync(PHASE20_ALTMER_IMPLEMENTATION_MANIFEST, "utf8"));
    } catch (error) {
      this.phase20AltmerGap(
        "Phase 20 Altmer costing manifest",
        `Altmer implementation-costing manifest could not be parsed: ${error.message}`,
        PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
      );
      return;
    }

    if (
      manifest.schema === "pdv-race-implementation-costing.v1"
      && manifest.id === "phase20-altmer-implementation-costing"
      && manifest.race === "Altmer"
    ) {
      this.pass("Phase 20 Altmer costing manifest", "Altmer costing manifest parsed with the expected schema, id, and race.", PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    } else {
      this.phase20AltmerGap(
        "Phase 20 Altmer costing manifest",
        `Manifest identity mismatch: schema=${manifest.schema}, id=${manifest.id}, race=${manifest.race}.`,
        PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
      );
    }

    for (const source of manifest.decisionSources || []) {
      const relativePath = String(source).split("#")[0];
      const sourcePath = path.join(PROJECT_ROOT, relativePath);
      if (exists(sourcePath)) {
        this.pass("Phase 20 Altmer decision source", `${relativePath} exists.`, sourcePath);
      } else {
        this.phase20AltmerGap("Phase 20 Altmer decision source", `${relativePath} is missing.`, sourcePath);
      }
    }

    const crisisState = (manifest.stateSurfaces || []).find((surface) => surface.editorId === "PDV_State_AltmerCrisis");
    const expectedEnum = {
      None: 0,
      Dissonant: 1,
      Questioning: 2,
      Reasserting: 3,
      ScarredResolved: 4,
    };
    const actualEnum = new Map((crisisState?.enum || []).map((entry) => [entry.name, entry.value]));
    const enumMismatches = Object.entries(expectedEnum)
      .filter(([name, value]) => actualEnum.get(name) !== value)
      .map(([name, value]) => `${name}=${actualEnum.get(name)} expected ${value}`);
    if (crisisState && enumMismatches.length === 0 && actualEnum.size === Object.keys(expectedEnum).length) {
      this.pass("Phase 20 Altmer crisis enum", "PDV_State_AltmerCrisis declares the locked crisis enum values.", PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    } else {
      this.phase20AltmerGap(
        "Phase 20 Altmer crisis enum",
        `PDV_State_AltmerCrisis enum mismatch: ${enumMismatches.join("; ") || "unexpected extra/missing enum entries"}.`,
        PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
      );
    }

    const implementationStatus = manifest.implementationStatus || "missing";
    const sourceStatuses = new Set(["source-scaffolded", "source-wired", "record-wired", "favor-records-wired", "trigger-proof-wired", "curse-message-wired", "runtime-proven"]);
    const recordRequiredStatuses = new Set(["record-wired", "favor-records-wired", "trigger-proof-wired", "curse-message-wired", "runtime-proven"]);
    const crisisRecord = this.recordsByEdid.get("PDV_State_AltmerCrisis");
    if (recordRequiredStatuses.has(implementationStatus)) {
      if (crisisRecord) {
        this.pass("Phase 20 Altmer crisis record", `PDV_State_AltmerCrisis exists as ${crisisRecord.type}.`, PDV_ESP);
      } else {
        this.phase20AltmerGap("Phase 20 Altmer crisis record", "PDV_State_AltmerCrisis is missing after manifest status moved beyond costing.", PDV_ESP);
      }
    } else {
      this.info("Phase 20 Altmer crisis record", `Record readback is not required while manifest status is ${implementationStatus}.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    }

    if (sourceStatuses.has(implementationStatus)) {
      const sourceContracts = [
        {
          name: "Phase 20 Altmer manager source contract",
          filePath: path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc"),
          snippets: [
            "Int Property ALTMER_CRISIS_NONE = 0 AutoReadOnly",
            "Int Property ALTMER_CRISIS_SCARRED_RESOLVED = 4 AutoReadOnly",
            "Int Property FAVOR_LANE_ALTMER = 4 AutoReadOnly",
            "PDV_StateTrack Property PDV_AltmerCrisisTrack Auto",
            "Spell Property PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness Auto",
            "Spell Property PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement Auto",
            "Message Property PDV_Msg_Altmer_VampireExiledPath_Entry Auto",
            "Message Property PDV_Msg_Altmer_VampireExiledPath_Recognition Auto",
            "Message Property PDV_Msg_Altmer_CurseState_WerewolfHardHalt Auto",
            "FAVOR_FAMILY_ALTMER_DAWN_STEADINESS",
            "FAVOR_FAMILY_ALTMER_ORTHODOX_COST",
            "Bool Function IsAltmerFavorSuppressedByCurse",
            "Function ApplyAltmerCurseHandlers",
            "Function HandleAltmerLorkhanPressure",
            "Function HandleAltmerCrisisSource",
            "Function HandleAltmerDawnSteadiness",
            "Function HandleAltmerOrthodoxCostlyEnforcement",
            "TryActivateContextualFavor(FAVOR_LANE_ALTMER",
            "PDV.Altmer.VampireExileActive",
            "PDV.Altmer.WerewolfHalt",
            "Bool Function IsAltmerRejectedLorkhanSurface",
            "Bool Function DebugAssertAltmerRejectedSurface",
            "String Function GetAltmerCurseSummary",
            "String Function GetAltmerSummary",
          ],
        },
        {
          name: "Phase 20 Altmer event bus source contract",
          filePath: path.join(DEVOTION_SOURCE, "PDV_EventBus.psc"),
          snippets: [
            "Function RouteAltmerLorkhanPressure",
            "Function RouteAltmerCrisisSource",
            "Function RouteAltmerDawnSteadiness",
            "Function RouteAltmerOrthodoxCostlyEnforcement",
          ],
        },
        {
          name: "Phase 20 Altmer event type source contract",
          filePath: path.join(DEVOTION_SOURCE, "PDV_EventTypes.psc"),
          snippets: [
            "EVT_ALTMER_LORKHAN_PRESSURE",
            "EVT_ALTMER_CRISIS_SOURCE",
            "EVT_ALTMER_DAWN_STEADINESS",
            "EVT_ALTMER_ORTHODOX_COST",
          ],
        },
        {
          name: "Phase 20 Altmer activator source contract",
          filePath: path.join(DEVOTION_SOURCE, "PDV_EventSignalActivator.psc"),
          snippets: [
            "Int Property SignalValue = 0 Auto",
            "String Property SignalSourceId = \"\" Auto",
            "ROUTE_ALTMER_LORKHAN_PRESSURE",
            "ROUTE_ALTMER_CRISIS_SOURCE",
            "ROUTE_ALTMER_DAWN_STEADINESS",
            "ROUTE_ALTMER_ORTHODOX_COST",
            "RouteAltmerLorkhanPressure(pressureTier, GetSignalSourceId())",
            "RouteAltmerCrisisSource(crisisSource, GetSignalSourceId())",
            "Function GetSignalSourceId()",
          ],
        },
        {
          name: "Phase 20 Altmer effect source contract",
          filePath: path.join(DEVOTION_SOURCE, "PDV_EventSignalEffect.psc"),
          snippets: [
            "Int Property SignalValue = 0 Auto",
            "String Property SignalSourceId = \"\" Auto",
            "ROUTE_ALTMER_LORKHAN_PRESSURE",
            "ROUTE_ALTMER_CRISIS_SOURCE",
            "ROUTE_ALTMER_DAWN_STEADINESS",
            "ROUTE_ALTMER_ORTHODOX_COST",
            "RouteAltmerLorkhanPressure(pressureTier, GetSignalSourceId())",
            "RouteAltmerCrisisSource(crisisSource, GetSignalSourceId())",
            "Function GetSignalSourceId()",
          ],
        },
      ];

      for (const contract of sourceContracts) {
        const source = exists(contract.filePath) ? fs.readFileSync(contract.filePath, "utf8") : "";
        const missingSnippets = contract.snippets.filter((snippet) => !source.includes(snippet));
        if (source && missingSnippets.length === 0) {
          this.pass(contract.name, `${path.basename(contract.filePath)} carries the expected Altmer source hooks.`, contract.filePath);
        } else {
          this.phase20AltmerGap(
            contract.name,
            `Missing source hook(s): ${missingSnippets.join(", ") || "source file missing"}.`,
            contract.filePath,
          );
        }
      }
    } else {
      this.info("Phase 20 Altmer source contract", `Source hook checks are not required while manifest status is ${implementationStatus}.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    }

    if (recordRequiredStatuses.has(implementationStatus)) {
      const trackDetail = this.recordDetails.get("PDV_State_AltmerCrisis");
      const trackScript = trackDetail ? findScript(trackDetail.fields || {}, "PDV_StateTrack") : null;
      if (trackScript) {
        const props = propertyMap(trackScript);
        this.pass("Phase 20 Altmer crisis track script", "PDV_State_AltmerCrisis carries PDV_StateTrack.", PDV_ESP);
        this.checkScalarProperty("Phase 20 Altmer crisis track property", props, "TrackName", "AltmerCrisis", this.phase20AltmerGap.bind(this));
        this.checkObjectPropertyTarget("Phase 20 Altmer crisis track property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20AltmerGap.bind(this));
        const labels = propValue(props.get("StateLabels")) || [];
        const expectedLabels = ["None", "Dissonant", "Questioning", "Reasserting", "ScarredResolved"];
        if (Array.isArray(labels) && labels.length === expectedLabels.length && labels.every((label, index) => label === expectedLabels[index])) {
          this.pass("Phase 20 Altmer crisis track property", "StateLabels match the locked crisis enum order.", PDV_ESP);
        } else {
          this.phase20AltmerGap("Phase 20 Altmer crisis track property", `StateLabels are ${JSON.stringify(labels)}, expected ${JSON.stringify(expectedLabels)}.`, PDV_ESP);
        }
      } else {
        this.phase20AltmerGap("Phase 20 Altmer crisis track script", "PDV_State_AltmerCrisis is missing PDV_StateTrack.", PDV_ESP);
      }

      const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
      const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
      if (managerScript) {
        const managerProps = propertyMap(managerScript);
        this.checkObjectPropertyTarget("Phase 20 Altmer manager property", managerProps, "PDV_AltmerCrisisTrack", "PDV_State_AltmerCrisis", this.phase20AltmerGap.bind(this));
        for (const family of (manifest.favorFamilies || []).filter((entry) => entry.recordStatus === "record-wired")) {
          if (family.spell) {
            this.checkObjectPropertyTarget("Phase 20 Altmer favor manager property", managerProps, family.spell, family.spell, this.phase20AltmerGap.bind(this));
          }
        }
        for (const rule of (manifest.curseAndExileRules || []).filter((entry) => entry.recordStatus === "record-wired")) {
          if (rule.row) {
            this.checkObjectPropertyTarget("Phase 20 Altmer curse manager property", managerProps, rule.row, rule.row, this.phase20AltmerGap.bind(this));
          }
        }
      } else {
        this.phase20AltmerGap("Phase 20 Altmer manager property", "PDV__ManagerQuest script readback is missing.", PDV_ESP);
      }
    }

    for (const family of (manifest.favorFamilies || []).filter((entry) => entry.recordStatus === "record-wired")) {
      this.checkPhase20AltmerRecordType(family.keyword, "KYWD");
      this.checkPhase20AltmerRecordType(family.magicEffect, "MGEF");
      this.checkPhase20AltmerRecordType(family.spell, "SPEL");
      this.checkPhase20AltmerSpellEffect(family.spell, family.magicEffect);
      this.checkPhase20AltmerMagicEffectKeyword(family.magicEffect, family.keyword);
    }

    for (const trigger of (manifest.triggerSurfaces || []).filter((entry) => entry.recordStatus === "record-wired")) {
      this.checkPhase20AltmerTriggerSurface(trigger);
    }

    for (const rule of (manifest.curseAndExileRules || []).filter((entry) => entry.recordStatus === "record-wired")) {
      this.checkPhase20AltmerCurseMessage(rule);
    }

    const requiredRows = [
      ...(manifest.crisisSources || []).map((entry) => entry.contentRow),
      ...(manifest.favorFamilies || []).map((entry) => entry.row),
      ...(manifest.curseAndExileRules || []).map((entry) => entry.row),
    ].filter(Boolean);
    const raceContent = exists(RACE_CONTENT_MANIFEST) ? fs.readFileSync(RACE_CONTENT_MANIFEST, "utf8") : "";
    if (!raceContent) {
      this.phase20AltmerGap("Phase 20 Altmer race content", "Race content manifest is missing or empty.", RACE_CONTENT_MANIFEST);
    }
    for (const row of requiredRows) {
      if (raceContent.includes(row)) {
        this.pass("Phase 20 Altmer content row", `${row} is present in the race content manifest.`, RACE_CONTENT_MANIFEST);
      } else {
        this.phase20AltmerGap("Phase 20 Altmer content row", `${row} is missing from the race content manifest.`, RACE_CONTENT_MANIFEST);
      }
    }

    const requiredRejectedHooks = [
      "ordinary existence in Skyrim",
      "ordinary friendship with Nords or non-Altmer",
      "generic spellcasting spam",
      "generic anti-Thalmor violence",
      "post-first-crisis Dragonborn identity as repeated penalty",
      "vampire power as a clean devotion route",
    ];
    const rejectedHooks = new Set(manifest.rejectedHooks || []);
    const missingRejected = requiredRejectedHooks.filter((hook) => !rejectedHooks.has(hook));
    if (missingRejected.length === 0) {
      this.pass("Phase 20 Altmer rejected hooks", "Manifest names the high-risk rejected Altmer hook families.", PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer rejected hooks", `Manifest is missing rejected hook(s): ${missingRejected.join(", ")}.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    }

    this.checkPhase20ImmersionProofContract(
      "Altmer",
      manifest,
      PHASE20_ALTMER_IMPLEMENTATION_MANIFEST,
      this.phase20AltmerGap.bind(this),
    );

    if (manifest.verifierExpectations?.strictFlag === "--strict-phase20-altmer") {
      this.pass("Phase 20 Altmer verifier contract", "Manifest declares --strict-phase20-altmer as the verifier gate.", PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer verifier contract", "Manifest does not declare --strict-phase20-altmer.", PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    }

    const positiveProof = manifest.runtimeProof?.positive || [];
    const negativeProof = manifest.runtimeProof?.negative || [];
    if (positiveProof.length >= 4 && negativeProof.length >= 5) {
      this.pass("Phase 20 Altmer runtime proof contract", `Manifest has ${positiveProof.length} positive and ${negativeProof.length} negative runtime proof cases.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer runtime proof contract", `Manifest has ${positiveProof.length} positive and ${negativeProof.length} negative proof cases; expected at least 4 and 5.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
    }
  }

  checkPhase20AltmerRecordType(edid, expectedType) {
    if (!edid) {
      this.phase20AltmerGap("Phase 20 Altmer favor record", `Favor record metadata is missing a ${expectedType} editor ID.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
      return;
    }

    const record = this.recordsByEdid.get(edid);
    if (record?.type === expectedType) {
      this.pass("Phase 20 Altmer favor record", `${edid} exists as ${expectedType}.`, PDV_ESP);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer favor record", `${edid} is missing or not a ${expectedType}.`, PDV_ESP);
    }
  }

  checkPhase20AltmerSpellEffect(spellEdid, effectEdid) {
    if (!spellEdid || !effectEdid) {
      return;
    }

    const detail = this.recordDetails.get(spellEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const effects = Array.isArray(fields.Effects) ? fields.Effects : [];
    const expectedFormid = this.recordsByEdid.get(effectEdid)?.formid;
    const firstEffect = effects[0] || {};
    if (expectedFormid && firstEffect.BaseEffect === expectedFormid) {
      this.pass("Phase 20 Altmer spell membership", `${spellEdid} points at ${effectEdid}.`, PDV_ESP);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer spell membership", `${spellEdid} does not point at ${effectEdid}.`, PDV_ESP);
    }
  }

  checkPhase20AltmerMagicEffectKeyword(effectEdid, keywordEdid) {
    if (!effectEdid || !keywordEdid) {
      return;
    }

    const detail = this.recordDetails.get(effectEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const keywordValues = Array.isArray(fields.Keywords) ? fields.Keywords : [];
    const keywordEdids = keywordValues.map((value) => formidToEdid(value, this.recordsByEdid) || value);
    if (keywordEdids.includes(keywordEdid)) {
      this.pass("Phase 20 Altmer favor keyword", `${effectEdid} includes ${keywordEdid}.`, PDV_ESP);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer favor keyword", `${effectEdid} is missing ${keywordEdid}.`, PDV_ESP);
    }
  }

  checkPhase20AltmerTriggerSurface(trigger) {
    const edid = trigger.editorId;
    const expectedType = trigger.recordType || "ACTI";
    const record = this.recordsByEdid.get(edid);
    const detail = this.recordDetails.get(edid);
    if (!record || !detail) {
      this.phase20AltmerGap("Phase 20 Altmer trigger surface", `${edid || "(missing editorId)"} is missing.`, PDV_ESP);
      return;
    }

    if (record.type === expectedType) {
      this.pass("Phase 20 Altmer trigger surface", `${edid} exists as ${expectedType}.`, PDV_ESP);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer trigger surface", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_EventSignalActivator");
    if (!script) {
      this.phase20AltmerGap("Phase 20 Altmer trigger script", `PDV_EventSignalActivator is not attached to ${edid}.`, PDV_ESP);
      return;
    }

    this.pass("Phase 20 Altmer trigger script", `PDV_EventSignalActivator is attached to ${edid}.`, PDV_ESP);
    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Phase 20 Altmer trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20AltmerGap.bind(this));
    this.checkObjectPropertyTarget("Phase 20 Altmer trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20AltmerGap.bind(this));
    this.checkObjectPropertyTarget("Phase 20 Altmer trigger property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20AltmerGap.bind(this));
    this.checkScalarProperty("Phase 20 Altmer trigger property", props, "RouteId", trigger.routeId, this.phase20AltmerGap.bind(this));
    this.checkScalarProperty("Phase 20 Altmer trigger property", props, "RequiredOriginRace", trigger.requiredOriginRace, this.phase20AltmerGap.bind(this));
    this.checkScalarProperty("Phase 20 Altmer trigger property", props, "SignalValue", trigger.signalValue || 0, this.phase20AltmerGap.bind(this));
    this.checkScalarProperty("Phase 20 Altmer trigger property", props, "SignalSourceId", trigger.signalSourceId, this.phase20AltmerGap.bind(this));
    this.checkScalarProperty("Phase 20 Altmer trigger property", props, "TraceLabel", edid, this.phase20AltmerGap.bind(this));
    if (trigger.oncePerDayKey) {
      this.checkScalarProperty("Phase 20 Altmer trigger property", props, "OncePerDayKey", trigger.oncePerDayKey, this.phase20AltmerGap.bind(this));
    }

    if (trigger.placementStatus === "manual-placement-required") {
      this.pass("Phase 20 Altmer trigger placement", `${edid} declares manual placement before runtime proof.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
      if (trigger.placementRefEditorId) {
        this.pass("Phase 20 Altmer trigger placement contract", `${edid} expects placed reference ${trigger.placementRefEditorId}.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
      } else {
        this.phase20AltmerGap("Phase 20 Altmer trigger placement contract", `${edid} is missing placementRefEditorId.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
      }
    } else {
      this.checkPhase20AltmerTriggerPlacement(trigger);
    }
  }

  checkPhase20AltmerTriggerPlacement(trigger) {
    const refEdid = trigger.placementRefEditorId;
    if (!refEdid) {
      this.phase20AltmerGap("Phase 20 Altmer trigger placement", `${trigger.editorId || "(missing editorId)"} does not declare placementRefEditorId.`, PHASE20_ALTMER_IMPLEMENTATION_MANIFEST);
      return;
    }

    const record = this.recordsByEdid.get(refEdid);
    const detail = this.recordDetails.get(refEdid);
    if (!record || !detail) {
      this.phase20AltmerGap("Phase 20 Altmer trigger placement", `${refEdid} is missing after placementStatus moved beyond manual placement.`, PDV_ESP);
      return;
    }

    if (record.type !== "REFR") {
      this.phase20AltmerGap("Phase 20 Altmer trigger placement", `${refEdid} has type ${record.type}, expected REFR.`, PDV_ESP);
      return;
    }

    const baseEdid = formidToEdid(detail.fields?.Base, this.recordsByEdid);
    if (baseEdid !== trigger.editorId) {
      this.phase20AltmerGap("Phase 20 Altmer trigger placement", `${refEdid} points at ${baseEdid || detail.fields?.Base || "(missing base)"}, expected ${trigger.editorId}.`, PDV_ESP);
      return;
    }

    this.pass("Phase 20 Altmer trigger placement", `${refEdid} points at ${trigger.editorId}.`, PDV_ESP);
  }

  checkPhase20RaceTriggerPlacement(label, trigger, manifestPath) {
    const refEdid = trigger.placementRefEditorId;
    if (!refEdid) {
      this.phase20RaceCostingGap(label, `${trigger.editorId || "(missing editorId)"} does not declare placementRefEditorId.`, manifestPath);
      return;
    }

    if (trigger.placementStatus === "manual-placement-required" || !trigger.placementStatus) {
      this.pass(label, `${trigger.editorId || "(missing editorId)"} declares placement reference ${refEdid}; readback waits for placementStatus promotion.`, manifestPath);
      return;
    }

    const record = this.recordsByEdid.get(refEdid);
    const detail = this.recordDetails.get(refEdid);
    if (!record || !detail) {
      this.phase20RaceCostingGap(label, `${refEdid} is missing after placementStatus moved to ${trigger.placementStatus}.`, PDV_ESP);
      return;
    }

    if (record.type !== "REFR") {
      this.phase20RaceCostingGap(label, `${refEdid} has type ${record.type}, expected REFR.`, PDV_ESP);
      return;
    }

    const baseEdid = formidToEdid(detail.fields?.Base, this.recordsByEdid);
    if (baseEdid !== trigger.editorId) {
      this.phase20RaceCostingGap(label, `${refEdid} points at ${baseEdid || detail.fields?.Base || "(missing base)"}, expected ${trigger.editorId}.`, PDV_ESP);
      return;
    }

    this.pass(label, `${refEdid} points at ${trigger.editorId}.`, PDV_ESP);
  }

  checkPhase20AltmerCurseMessage(rule) {
    const edid = rule.row;
    const expectedType = rule.recordType || "MESG";
    const record = this.recordsByEdid.get(edid);
    if (record?.type === expectedType) {
      this.pass("Phase 20 Altmer curse message", `${edid} exists as ${expectedType}.`, PDV_ESP);
    } else {
      this.phase20AltmerGap("Phase 20 Altmer curse message", `${edid || "(missing editorId)"} is missing or not a ${expectedType}.`, PDV_ESP);
    }
  }

  checkPhase20RaceImplementationCosting() {
    const raceContent = exists(RACE_CONTENT_MANIFEST) ? fs.readFileSync(RACE_CONTENT_MANIFEST, "utf8") : "";
    if (!raceContent) {
      this.phase20RaceCostingGap("Phase 20 race costing content source", "Race content manifest is missing or empty.", RACE_CONTENT_MANIFEST);
    }

    for (const manifestPath of PHASE20_RACE_IMPLEMENTATION_MANIFESTS) {
      if (!exists(manifestPath)) {
        this.phase20RaceCostingGap("Phase 20 race costing manifest", `${path.basename(manifestPath)} is missing.`, manifestPath);
        continue;
      }

      let manifest;
      try {
        manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
      } catch (error) {
        this.phase20RaceCostingGap(
          "Phase 20 race costing manifest",
          `${path.basename(manifestPath)} could not be parsed: ${error.message}`,
          manifestPath,
        );
        continue;
      }

      const raceName = manifest.race || path.basename(manifestPath);
      if (
        manifest.schema === "pdv-race-implementation-costing.v1"
        && typeof manifest.id === "string"
        && manifest.id.startsWith("phase20-")
        && typeof manifest.race === "string"
      ) {
        this.pass(`Phase 20 ${raceName} costing manifest`, "Manifest parsed with the expected schema, id, and race.", manifestPath);
      } else {
        this.phase20RaceCostingGap(
          `Phase 20 ${raceName} costing manifest`,
          `Manifest identity mismatch: schema=${manifest.schema}, id=${manifest.id}, race=${manifest.race}.`,
          manifestPath,
        );
      }

      const allowedStatuses = new Set(["costed-not-built", "source-scaffolded", "source-wired", "record-wired", "favor-records-wired", "trigger-proof-wired", "curse-message-wired", "runtime-proven"]);
      if (allowedStatuses.has(manifest.implementationStatus)) {
        this.pass(`Phase 20 ${raceName} implementation status`, `Status is ${manifest.implementationStatus}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(
          `Phase 20 ${raceName} implementation status`,
          `Unexpected implementationStatus: ${manifest.implementationStatus}.`,
          manifestPath,
        );
      }

      for (const source of manifest.decisionSources || []) {
        const relativePath = String(source).split("#")[0];
        const sourcePath = path.join(PROJECT_ROOT, relativePath);
        if (exists(sourcePath)) {
          this.pass(`Phase 20 ${raceName} decision source`, `${relativePath} exists.`, sourcePath);
        } else {
          this.phase20RaceCostingGap(`Phase 20 ${raceName} decision source`, `${relativePath} is missing.`, sourcePath);
        }
      }

      const stateSurfaces = manifest.stateSurfaces || [];
      if (stateSurfaces.length > 0) {
        this.pass(`Phase 20 ${raceName} state surfaces`, `${stateSurfaces.length} planned or existing state surface(s) declared.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(`Phase 20 ${raceName} state surfaces`, "Manifest declares no state surfaces.", manifestPath);
      }

      for (const surface of stateSurfaces) {
        if (!surface.enum) {
          continue;
        }
        const enumNames = new Set();
        const enumValues = new Set();
        const enumErrors = [];
        for (const entry of surface.enum) {
          if (typeof entry.name !== "string" || entry.name.length === 0) {
            enumErrors.push("missing enum name");
          }
          if (typeof entry.value !== "number") {
            enumErrors.push(`${entry.name || "unknown"} has non-numeric value`);
          }
          if (enumNames.has(entry.name)) {
            enumErrors.push(`duplicate name ${entry.name}`);
          }
          if (enumValues.has(entry.value)) {
            enumErrors.push(`duplicate value ${entry.value}`);
          }
          enumNames.add(entry.name);
          enumValues.add(entry.value);
        }
        if (enumErrors.length === 0 && enumNames.size > 0) {
          this.pass(`Phase 20 ${raceName} enum contract`, `${surface.editorId || "state surface"} has stable unique enum entries.`, manifestPath);
        } else {
          this.phase20RaceCostingGap(
            `Phase 20 ${raceName} enum contract`,
            `${surface.editorId || "state surface"} enum issue(s): ${enumErrors.join("; ") || "missing enum entries"}.`,
            manifestPath,
          );
        }
      }

      const rowSources = [
        ...(manifest.requiredContentRows || []),
        ...(manifest.crisisSources || []).map((entry) => entry.contentRow),
        ...(manifest.favorFamilies || []).map((entry) => entry.row),
        ...(manifest.curseAndExileRules || []).map((entry) => entry.row),
      ].filter(Boolean);
      const requiredRows = [...new Set(rowSources)];
      if (requiredRows.length >= 4) {
        this.pass(`Phase 20 ${raceName} content contract`, `${requiredRows.length} content row(s) are required by the manifest.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(`Phase 20 ${raceName} content contract`, `Only ${requiredRows.length} required content row(s) declared.`, manifestPath);
      }
      for (const row of requiredRows) {
        if (raceContent.includes(row)) {
          this.pass(`Phase 20 ${raceName} content row`, `${row} is present in the race content manifest.`, RACE_CONTENT_MANIFEST);
        } else {
          this.phase20RaceCostingGap(`Phase 20 ${raceName} content row`, `${row} is missing from the race content manifest.`, RACE_CONTENT_MANIFEST);
        }
      }

      const rejectedHooks = manifest.rejectedHooks || [];
      if (rejectedHooks.length >= 5) {
        this.pass(`Phase 20 ${raceName} rejected hooks`, `${rejectedHooks.length} rejected hook families are named.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(`Phase 20 ${raceName} rejected hooks`, `Only ${rejectedHooks.length} rejected hook families are named.`, manifestPath);
      }

      this.checkPhase20ImmersionProofContract(
        raceName,
        manifest,
        manifestPath,
        this.phase20RaceCostingGap.bind(this),
      );

      const strictFlags = new Set([
        manifest.verifierExpectations?.strictFlag,
        ...(manifest.verifierExpectations?.strictFlags || []),
      ].filter(Boolean));
      if (strictFlags.has("--strict-phase20-race-costing")) {
        this.pass(`Phase 20 ${raceName} verifier contract`, "Manifest declares --strict-phase20-race-costing as a verifier gate.", manifestPath);
      } else {
        this.phase20RaceCostingGap(`Phase 20 ${raceName} verifier contract`, "Manifest does not declare --strict-phase20-race-costing.", manifestPath);
      }

      const positiveProof = manifest.runtimeProof?.positive || [];
      const negativeProof = manifest.runtimeProof?.negative || [];
      if (positiveProof.length >= 3 && negativeProof.length >= 3) {
        this.pass(`Phase 20 ${raceName} runtime proof contract`, `Manifest has ${positiveProof.length} positive and ${negativeProof.length} negative runtime proof cases.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(
          `Phase 20 ${raceName} runtime proof contract`,
          `Manifest has ${positiveProof.length} positive and ${negativeProof.length} negative proof cases; expected at least 3 and 3.`,
          manifestPath,
        );
      }

      const firstSlice = manifest.firstImplementationSlice || [];
      if (firstSlice.length >= 3) {
        this.pass(`Phase 20 ${raceName} first implementation slice`, `${firstSlice.length} first-slice step(s) declared.`, manifestPath);
      } else {
        this.phase20RaceCostingGap(`Phase 20 ${raceName} first implementation slice`, `Only ${firstSlice.length} first-slice step(s) declared.`, manifestPath);
      }

      if (raceName === "Argonian" && manifest.implementationStatus !== "costed-not-built") {
        this.checkPhase20ArgonianSourceScaffold(manifest, manifestPath);
      }

      if (raceName === "Orc" && manifest.implementationStatus !== "costed-not-built") {
        this.checkPhase20OrcSourceScaffold(manifest, manifestPath);
      }

      if (raceName === "Redguard" && manifest.implementationStatus !== "costed-not-built") {
        this.checkPhase20RedguardSourceScaffold(manifest, manifestPath);
      }

      if (raceName === "Bosmer" && manifest.implementationStatus !== "costed-not-built") {
        this.checkPhase20BosmerSourceScaffold(manifest, manifestPath);
      }

      if (raceName === "Khajiit" && manifest.implementationStatus !== "costed-not-built") {
        this.checkPhase20KhajiitSourceScaffold(manifest, manifestPath);
      }
    }

    this.checkPhase20PreBetaSurveySourceScaffold();
    this.checkPhase20ImmersiveHookSourceScaffold();
    this.checkRestoreBoundaryRecoverySourceScaffold();
    this.checkPhase20P2ImmersiveReceiverManifest();
    this.checkPhase20NoInGameProofGates();
    this.checkPhase20Cat6PromotionPilot();
    this.checkPhase20ManualEvidenceLedger();
  }

  checkPhase20PreBetaSurveySourceScaffold() {
    this.checkSourceContains("Phase 20 pre-beta Survey source", "PDV__ManagerQuest", [
      "String Function GetSurveyDevotionText()",
      "return AppendRecentDevotionEvents(GetAltmerSurveyText())",
      "return AppendRecentDevotionEvents(GetKhajiitSurveyText())",
      "return AppendRecentDevotionEvents(GetBosmerSurveyText())",
      "return AppendRecentDevotionEvents(GetArgonianSurveyText())",
      "return AppendRecentDevotionEvents(GetOrcSurveyText())",
      "return AppendRecentDevotionEvents(GetRedguardSurveyText())",
      "return AppendRecentDevotionEvents(GetImperialSurveyText())",
      "return AppendRecentDevotionEvents(GetBretonSurveyText())",
      "return AppendRecentDevotionEvents(GetDunmerSurveyText())",
      "String Function GetAltmerSurveyText()",
      "String Function GetKhajiitSurveyText()",
      "String Function GetBosmerSurveyText()",
      "String Function GetArgonianSurveyText()",
      "String Function GetOrcSurveyText()",
      "String Function GetRedguardSurveyText()",
      "String Function GetImperialSurveyText()",
      "String Function GetBretonSurveyText()",
      "String Function GetDunmerSurveyText()",
      "String Function GetPlayerMcmSummaryLine()",
      "String Function GetPlayerMcmModeLine()",
    ], this.phase20RaceCostingGap.bind(this));
  }

  checkPhase20ImmersiveHookSourceScaffold() {
    this.checkSourceContains("Phase 20 immersive hook EventTypes source", "PDV_EventTypes", [
      "EVT_BRETON_TRADITION_CHOICE = 120",
      "EVT_BRETON_KNIGHTLY_VOW = 121",
      "EVT_BRETON_HIDDEN_ART_EXPOSURE = 122",
      "EVT_BRETON_GREEN_WAY_STANDING = 123",
      "EVT_DUNMER_RECLAMATION_FOCUS = 130",
      "EVT_DUNMER_DEVIATION_PRICE = 131",
      "EVT_IMPERIAL_CIVIC_SERVICE = 140",
      "EVT_IMPERIAL_TALOS_PRESSURE = 141",
      "EVT_IMPERIAL_PATRON_CIVIC_FAVOR = 142",
      "EVT_NORD_OLD_WAYS_STATE = 150",
      "EVT_NORD_KYNE_TALOS_CONTEXT = 151",
      "EVT_NORD_HIRCINE_ARKAY_EDGE = 152",
      "breton-tradition-choice",
      "dunmer-reclamation-focus",
      "imperial-civic-service",
      "nord-hircine-arkay-edge",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Phase 20 immersive hook EventBus source", "PDV_EventBus", [
      "Function RouteBretonTraditionChoice(Int traditionValue, String sourceId)",
      "Function RouteBretonKnightlyVow(String sourceId)",
      "Function RouteBretonHiddenArtExposure(String sourceId)",
      "Function RouteBretonGreenWayStanding(String sourceId)",
      "Function RouteDunmerReclamationFocus(Int focusValue, String sourceId)",
      "Function RouteDunmerDeviationPrice(String sourceId)",
      "Function RouteImperialCivicService(String sourceId)",
      "Function RouteImperialTalosPressure(Bool isPrivate, String sourceId)",
      "Function RouteImperialPatronCivicFavor(String sourceId)",
      "Function RouteNordOldWaysState(String sourceId)",
      "Function RouteNordKyneTalosContext(String sourceId)",
      "Function RouteNordHircineArkayEdge(String sourceId)",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Phase 20 immersive hook manager source", "PDV__ManagerQuest", [
      "Function HandleBretonTraditionChoice(Int traditionValue, String reason)",
      "Function HandleBretonKnightlyVow(String reason)",
      "Function HandleBretonHiddenArtExposure(String reason)",
      "Function HandleBretonGreenWayStanding(String reason)",
      "Function HandleDunmerReclamationFocus(Int focusValue, String reason)",
      "Function HandleDunmerDeviationPrice(String reason)",
      "Function HandleImperialCivicService(String reason)",
      "Function HandleImperialTalosPressure(Bool isPrivate, String reason)",
      "Function HandleImperialPatronCivicFavor(String reason)",
      "Function HandleNordOldWaysState(String reason)",
      "Function HandleNordKyneTalosContext(String reason)",
      "Function HandleNordHircineArkayEdge(String reason)",
      "Function HandleOrcMalacathConduct(Int modeValue, String reason)",
      "Function HandleOrcOathBreak(String reason)",
      "Function HandleRedguardAncestorSpine(String reason)",
      "String Function GetNordContextSurveyText()",
      "String Function GetDunmerReclamationFocusLabel(Int focusValue)",
      "PDV.Breton.TraditionHookCount",
      "PDV.Dunmer.ReclamationFocusCount",
      "PDV.Signal.DunmerTwilight.",
      "PDV.Imperial.CivicServiceCount",
      "PDV.Nord.HircineArkayEdgeCount",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Phase 20 immersive hook receiver source", "PDV_PlayerEvents", [
      "Function RegisterForP2ImmersiveSignals()",
      "PO3_Events_Alias.RegisterForBookRead(Self)",
      "PO3_Events_Alias.RegisterForSpellLearned(Self)",
      "PO3_Events_Alias.RegisterForItemHarvested(Self)",
      "PO3_Events_Alias.RegisterForWeatherChange(Self)",
      "PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)",
      "Event OnBookRead(Book akBook)",
      "Event OnSpellLearned(Spell akSpell)",
      "Event OnItemHarvested(Form akProduce)",
      "Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)",
      "Event OnQuestStageChange(Quest akQuest, Int aiNewStage)",
      "Function RouteP2ImmersiveSource(Form sourceForm, String sourceKind)",
      "Function RouteP2ImmersiveQuestStage(Quest sourceQuest, Int newStage)",
      "Function ShouldRouteP2Source(FormList sourceList, Form sourceForm, String routeKey, String sourceKind)",
      "Function ShouldRouteP2QuestStage(FormList sourceList, Quest sourceQuest, Int expectedFormId, Int approvedStage, String routeKey, Int newStage)",
      "Function MarkP2SourceRoute(Form sourceForm, String routeKey, String sourceKind)",
      "Function HasListedForm(FormList sourceList, Form sourceForm)",
      "PDV.P2Source.",
      "PDV_FLST_P2_BretonKnightsRoadSources",
      "PDV_FLST_P2_DunmerAzuraSources",
      "PDV_FLST_P2_ImperialCivicSources",
      "PDV_FLST_P2_NordHircineArkaySources",
      "PDV_FLST_P2_AltmerAurielSources",
      "PDV_FLST_P2_ArgonianHistSources",
      "PDV_FLST_P2_BosmerYffreSources",
      "PDV_FLST_P2_KhajiitLunarSources",
      "PDV_FLST_P2_OrcMalacathSources",
      "PDV_FLST_P2_RedguardSpineSources",
    ], this.phase20RaceCostingGap.bind(this));
  }

  checkRestoreBoundaryRecoverySourceScaffold() {
    this.checkSourceContains("Restore boundary book notice source", "PDV__ManagerQuest", [
      "Bool Function IsP2BookNoticeReason(String reason)",
      "return StringContainsToken(reason, \"po3_book\")",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary startup confirm source", "PDV__ManagerQuest", [
      "Message Property PDV_MSG_Confirm_Redguard_Crown Auto",
      "Message Property PDV_MSG_Confirm_Breton_HiddenArt Auto",
      "Message Property PDV_MSG_Confirm_Orc_LegionExile Auto",
      "Message Property PDV_MSG_Confirm_Bosmer_BanditRoad Auto",
      "Bool Function ConfirmStartupSelection(Int originRace, Message choiceMessage, Int expectedSelection)",
      "Message Function GetStartupConfirmMessage(Int originRace, Int optionValue)",
      "confirmMessage.Show()",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceNotContains("Restore boundary startup confirm source", "PDV__ManagerQuest", [
      "Debug.MessageBox(GetStartupOptionDetailText",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary Orc organic source", "PDV__ManagerQuest", [
      "Function HandleOrcLocationChange(Location newLocation)",
      "Function HandleOrcStrongholdPresence(Int holdId, String reason)",
      "Function HandleOrcBloodKinCrisis(String reason)",
      "Int Function GetOrcStrongholdHoldId(Location newLocation)",
      "return StringContainsToken(reason, \"orc_bloodkin_crisis\") || StringContainsToken(reason, \"orc_cursed_tribe_resolved\") || StringContainsToken(reason, \"orc_major_gate\")",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceContains("Restore boundary Orc organic router source", "PDV_ActionRouter", [
      "PDV_Manager.HandleOrcLocationChange(akNewLocation)",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceContains("Restore boundary Orc organic EventBus source", "PDV_EventBus", [
      "Function RouteOrcStrongholdPresence(Int holdId, String sourceId = \"\")",
      "Function RouteOrcBloodKinCrisis(String sourceId = \"orc_cursed_tribe_resolved\")",
      "Function RouteOrcCityDignity(String sourceId = \"\")",
      "Function RouteOrcLegionService(String sourceId = \"\")",
      "Function RouteOrcSelfMadeCommunity(String sourceId = \"\")",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceContains("Restore boundary Orc organic PO3 source", "PDV_PlayerEvents", [
      "Function RegisterOrcLifeModeQuestSources()",
      "Function RouteOrcLifeModeQuestStage(Quest sourceQuest, Int newStage)",
      "RouteOrcBloodKinCrisis(\"orc_cursed_tribe_resolved\")",
      "RouteOrcCityDignity(\"po3_queststage_orc_city_thane\")",
      "RouteOrcLegionService(\"po3_queststage_orc_cw02a\")",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary Breton Hidden Art notice source", "PDV__ManagerQuest", [
      "ShowP2BookNotice(reason, GetBretonHiddenArtNoticeTitle(reason), GetBretonHiddenArtNoticeText(reason))",
      "String Function GetBretonHiddenArtNoticeTitle(String reason)",
      "String Function GetBretonHiddenArtNoticeText(String reason)",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceContains("Restore boundary Breton Hidden Art PO3 source", "PDV_PlayerEvents", [
      "Function GetBretonHiddenArtSourceToken(Form sourceForm)",
      "RouteBretonHiddenArtExposure(sourceKind + \"_breton_hidden_art_\" + GetBretonHiddenArtSourceToken(sourceForm))",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary Argonian move-home source", "PDV__ManagerQuest", [
      "Bool Function TryArgonianBedOfChoiceSleep(Actor playerRef, Int sleepCellId, String reason)",
      "StorageUtil.SetIntValue(None, \"PDV.ArgBed.CandidateFormID\", sleepCellId)",
      "SetArgonianHome(playerRef, sleepCellId, today, reason)",
      "Function SetArgonianHome(Actor playerRef, Int sleepCellId, Int today, String reason)",
      "Function ClearArgonianAdaptation(Actor playerRef)",
      "StorageUtil.SetIntValue(None, \"PDV.Adapt.DueDay\", today + Utility.RandomInt(10, 14) + 1)",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary Book of Days payload source", "PDV__ManagerQuest", [
      "String Function BuildJournalPayloadJson()",
      "String pathInfo = GetOriginRaceLabel(GetPlayerOriginRaceIndex())",
      "pathInfo = pathInfo + \" | \" + GetPlayerMcmModeLine()",
      "j = j + \",\\\"survey\\\":\\\"\" + JsonSafeString(pathInfo) + \"\\\"\"",
      "String Function GetPlayerMcmModeLine()",
      "return GetRedguardSectLabel()",
    ], this.phase20RaceCostingGap.bind(this));
    this.checkSourceNotContains("Restore boundary Book of Days payload source", "PDV__ManagerQuest", [
      "pathInfo = pathInfo + \" | \" + GetPlayerMcmSummaryLine()",
      "pathInfo = pathInfo + \" | \" + GetCurrentStandingLabel()",
    ], this.phase20RaceCostingGap.bind(this));

    this.checkSourceContains("Restore boundary Book of Days MCM source", "PDV_MCM", [
      "Function RegisterJournalHotkey()",
      "Event OnKeyDown(Int a_keyCode)",
      "StorageUtil.SetIntValue(None, \"PDV.Diegetic.Journal.Open\", 0)",
      "PDV_Manager.ClosePrismaJournal()",
      "PDV_Manager.SendPrismaJournalPayload(True)",
      "_oidJournalHotkey = AddKeyMapOption(\"Open Book of Days\", currentJournalKey, OPTION_FLAG_NONE)",
    ], this.phase20RaceCostingGap.bind(this));
  }

  checkPhase20P2ImmersiveReceiverManifest() {
    if (!exists(PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST)) {
      this.phase20RaceCostingGap("Phase 20 P2 immersive receiver manifest", "Manifest is missing.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      return;
    }

    let manifest = null;
    try {
      manifest = JSON.parse(fs.readFileSync(PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST, "utf8"));
    } catch (error) {
      this.phase20RaceCostingGap("Phase 20 P2 immersive receiver manifest", `Could not parse manifest: ${error.message}`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      return;
    }

    if (manifest.schema === "pdv.phase20.p2-immersive-receivers.v1") {
      this.pass("Phase 20 P2 immersive receiver manifest", "Schema is current.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 immersive receiver manifest", `Unexpected schema ${manifest.schema || "(missing)"}.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }

    const allowedStatuses = new Set([
      "source-scaffolded-pending-ck-wiring",
      "formlist-shells-wired-pending-alias-property-wiring",
      "alias-properties-wired-pending-curated-source-fill",
      "source-fill-tooling-ready-pending-curated-source-fill",
      "p2-book-fill-live-readback-pass-pending-runtime-proof",
    ]);
    const formListWiredStatuses = new Set([
      "formlist-shells-wired-pending-alias-property-wiring",
      "alias-properties-wired-pending-curated-source-fill",
      "source-fill-tooling-ready-pending-curated-source-fill",
      "p2-book-fill-live-readback-pass-pending-runtime-proof",
    ]);
    const aliasWiredStatuses = new Set([
      "alias-properties-wired-pending-curated-source-fill",
      "source-fill-tooling-ready-pending-curated-source-fill",
      "p2-book-fill-live-readback-pass-pending-runtime-proof",
    ]);
    const sourceFillStatuses = new Set([
      "source-fill-tooling-ready-pending-curated-source-fill",
      "p2-book-fill-live-readback-pass-pending-runtime-proof",
    ]);
    const sourceFillPlanStatuses = new Set([
      "tooling-ready-pending-exact-source-curation",
      "p2-book-fill-live-readback-pass-pending-runtime-proof",
      "p2-book-and-exact-stage-fill-live-readback-pass-pending-runtime-proof",
    ]);
    if (allowedStatuses.has(manifest.status)) {
      this.pass("Phase 20 P2 immersive receiver status", "Receiver status preserves CK/runtime boundary.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 immersive receiver status", `Unexpected status ${manifest.status || "(missing)"}.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }

    const expectedPo3Events = ["RegisterForBookRead", "RegisterForSpellLearned", "RegisterForItemHarvested", "RegisterForWeatherChange", "RegisterForQuestStage"];
    const po3Events = new Set(Array.isArray(manifest.po3Events) ? manifest.po3Events : []);
    for (const eventName of expectedPo3Events) {
      if (po3Events.has(eventName)) {
        this.pass("Phase 20 P2 immersive PO3 event", `${eventName} is declared.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive PO3 event", `${eventName} is missing.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }
    }

    const properties = Array.isArray(manifest.sourceProperties) ? manifest.sourceProperties : [];
    if (properties.length >= 17) {
      this.pass("Phase 20 P2 immersive source properties", `${properties.length} receiver source properties are declared.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 immersive source properties", `${properties.length} receiver source properties are declared; expected at least 17.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }

    const expectedRaces = new Set(["Altmer", "Argonian", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"]);
    const seenRaces = new Set();
    for (const property of properties) {
      const requiredFields = ["property", "race", "route", "acceptedUse", "rejectedUse"];
      const missingFields = requiredFields.filter((field) => !(typeof property[field] === "string" && property[field].trim().length > 0));
      if (!Array.isArray(property.sourceKinds) || property.sourceKinds.length === 0) {
        missingFields.push("sourceKinds");
      }

      const propertyName = typeof property.property === "string" && property.property.trim().length > 0 ? property.property : "(unnamed property)";
      if (missingFields.length === 0) {
        this.pass("Phase 20 P2 immersive source property", `${propertyName} declares race, source kinds, route, accepted use, and rejected use.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive source property", `${propertyName} missing ${missingFields.join(", ")}.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      if (formListWiredStatuses.has(manifest.status) && propertyName !== "(unnamed property)") {
        const record = this.recordsByEdid.get(propertyName);
        if (record?.type === "FLST") {
          this.pass("Phase 20 P2 immersive FormList shell", `${propertyName} exists as FLST.`, PDV_ESP);
        } else if (record) {
          this.phase20RaceCostingGap("Phase 20 P2 immersive FormList shell", `${propertyName} exists as ${record.type}, expected FLST.`, PDV_ESP);
        } else {
          this.phase20RaceCostingGap("Phase 20 P2 immersive FormList shell", `${propertyName} is missing from the framework ESP.`, PDV_ESP);
        }
      }

      if (expectedRaces.has(property.race)) {
        seenRaces.add(property.race);
      }
    }

    if (formListWiredStatuses.has(manifest.status)) {
      const readback = manifest.formListShellReadback || {};
      if (readback.status === "record-wired" && typeof readback.backupPath === "string" && readback.backupPath.trim().length > 0) {
        this.pass("Phase 20 P2 immersive FormList readback", "Manifest records FormList shell readback and backup path.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive FormList readback", "Manifest status is FormList-wired but readback/backup metadata is incomplete.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }
    }

    if (aliasWiredStatuses.has(manifest.status)) {
      const readback = manifest.aliasPropertyReadback || {};
      if (readback.status === "alias-properties-wired" && typeof readback.backupPath === "string" && readback.backupPath.trim().length > 0) {
        this.pass("Phase 20 P2 immersive alias readback", "Manifest records alias property readback and backup path.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive alias readback", "Manifest status is alias-wired but alias readback/backup metadata is incomplete.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      const detail = this.recordDetails.get("PDV__ManagerQuest");
      const fields = detail?.fields || {};
      const questAlias = findQuestAlias(fields, "PDV_Player");
      const aliasScript = questAlias ? findAliasScript(fields, questAlias.ID, "PDV_PlayerEvents") : null;
      if (!aliasScript) {
        this.phase20RaceCostingGap("Phase 20 P2 immersive alias property", "PDV_Player alias is missing PDV_PlayerEvents readback.", PDV_ESP);
      } else {
        const aliasProps = propertyMap(aliasScript);
        for (const property of properties) {
          const propertyName = typeof property.property === "string" && property.property.trim().length > 0 ? property.property : null;
          if (propertyName) {
            this.checkObjectPropertyTarget("Phase 20 P2 immersive alias property", aliasProps, propertyName, propertyName, this.phase20RaceCostingGap.bind(this));
          }
        }
      }
    }

    if (sourceFillStatuses.has(manifest.status)) {
      const fillPlan = manifest.sourceFillPlan || {};
      const entries = Array.isArray(manifest.sourceFillEntries) ? manifest.sourceFillEntries : null;
      const requiredFillFields = ["status", "fillCommand", "checkCommand", "readbackResult", "entryRule", "formKeyFormat", "fillToolSafety"];
      const missingFillFields = requiredFillFields.filter((field) => !(typeof fillPlan[field] === "string" && fillPlan[field].trim().length > 0));
      if (missingFillFields.length === 0 && sourceFillPlanStatuses.has(fillPlan.status)) {
        this.pass("Phase 20 P2 immersive source-fill plan", "Manifest records source-fill tooling, commands, readback, and safety rules.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive source-fill plan", `Source-fill plan metadata is incomplete: ${missingFillFields.join(", ") || "unexpected status"}.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      if (entries) {
        this.pass("Phase 20 P2 immersive source-fill entries", `${entries.length} approved source-fill group(s) are declared.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive source-fill entries", "sourceFillEntries must be an array, even while empty.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      const questStageGate = manifest.questStageGate || {};
      const approvedQuestStageEntries = (entries || []).flatMap((group) => (
        Array.isArray(group.sources) ? group.sources : []
      )).filter((source) => source.sourceKind === "quest-stage" && source.status === "approved-for-fill");
      if (typeof questStageGate.rule === "string"
          && questStageGate.rule.includes("aiNewStage")
          && typeof questStageGate.checkCommand === "string"
          && questStageGate.checkCommand.includes("--check-exact-stage-gates")) {
        this.pass("Phase 20 P2 exact-stage quest gate", "Manifest declares the exact-stage quest-source gate and checker command.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 exact-stage quest gate", "Manifest must declare an aiNewStage-aware quest-stage gate and checker command.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      if (approvedQuestStageEntries.length === 0 && questStageGate.receiverStatus !== "exact-stage-supported") {
        this.pass("Phase 20 P2 exact-stage quest fill", "No approved quest-stage entries are declared while exact-stage receiver support is blocked.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else if (approvedQuestStageEntries.length > 0 && questStageGate.receiverStatus !== "exact-stage-supported") {
        this.phase20RaceCostingGap("Phase 20 P2 exact-stage quest fill", `${approvedQuestStageEntries.length} approved quest-stage entries exist before exact-stage receiver support is live.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        const missingStageMetadata = approvedQuestStageEntries.filter((source) => (
          !Array.isArray(source.approvedStages)
          || source.approvedStages.length === 0
          || typeof source.stageReadbackEvidence !== "string"
          || source.stageReadbackEvidence.trim().length === 0
          || typeof source.rejectedStageContext !== "string"
          || source.rejectedStageContext.trim().length === 0
          || typeof source.duplicateGuard !== "string"
          || source.duplicateGuard.trim().length === 0
        ));
        if (missingStageMetadata.length === 0) {
          this.pass("Phase 20 P2 exact-stage quest fill", `${approvedQuestStageEntries.length} approved quest-stage entries carry stage metadata.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
        } else {
          this.phase20RaceCostingGap("Phase 20 P2 exact-stage quest fill", `${missingStageMetadata.length} approved quest-stage entries are missing approvedStages/readback/rejection/duplicate metadata.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
        }
      }
    }

    const routeContract = manifest.routeContract || {};
    const routeEntries = Array.isArray(manifest.routeEntries) ? manifest.routeEntries : null;
    if (routeContract.sourceOfTruth === "routeEntries"
        && typeof routeContract.verificationCommand === "string"
        && routeContract.verificationCommand.includes("--check-route-entries")) {
      this.pass("Phase 20 P2 route contract", "Manifest declares routeEntries as the static route source of truth and names the route checker.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 route contract", "Manifest must declare routeEntries as source of truth and include --check-route-entries.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }

    if (routeEntries && routeEntries.length >= 24) {
      this.pass("Phase 20 P2 route entries", `${routeEntries.length} exact-stage route entries are declared.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 route entries", `${routeEntries ? routeEntries.length : 0} exact-stage route entries are declared; expected at least 24.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }

    const declaredPropertyNames = new Set(properties.map((property) => property.property).filter(Boolean));
    const routeKeys = new Set();
    const routeRaces = new Set();
    for (const entry of routeEntries || []) {
      const missingFields = ["id", "race", "property", "sourceKind", "routeKey", "dispatch", "acceptedContext", "rejectedContext", "duplicateGuard", "stageReadbackEvidence", "implementationStatus", "reviewStatus"]
        .filter((field) => !(typeof entry[field] === "string" && entry[field].trim().length > 0));
      if (!(Number.isInteger(entry.expectedFormId) && entry.expectedFormId > 0)) {
        missingFields.push("expectedFormId");
      }
      if (!(Number.isInteger(entry.approvedStage) && entry.approvedStage >= 0 && entry.approvedStage <= 65535)) {
        missingFields.push("approvedStage");
      }

      const entryLabel = entry.id || "(unnamed route entry)";
      if (missingFields.length === 0 && declaredPropertyNames.has(entry.property)) {
        this.pass("Phase 20 P2 route entry", `${entryLabel} declares exact-stage route metadata.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 route entry", `${entryLabel} missing ${missingFields.join(", ") || "declared property"}.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }

      if (typeof entry.routeKey === "string" && entry.routeKey.trim().length > 0) {
        if (routeKeys.has(entry.routeKey)) {
          this.phase20RaceCostingGap("Phase 20 P2 route key", `${entry.routeKey} is declared more than once.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
        }
        routeKeys.add(entry.routeKey);
      }
      if (typeof entry.race === "string") {
        routeRaces.add(entry.race);
      }
    }

    for (const race of ["Altmer", "Argonian", "Bosmer", "Dunmer", "Khajiit", "Nord", "Orc", "Redguard"]) {
      if (routeRaces.has(race)) {
        this.pass("Phase 20 P2 exact-stage route race", `${race} has exact-stage route entries.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 exact-stage route race", `${race} has no exact-stage route entry.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }
    }

    if (exists(PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET)) {
      const reviewPacket = fs.readFileSync(PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET, "utf8");
      if (reviewPacket.includes("not live-fill authority") && reviewPacket.includes("local quest-stage readback is authoritative")) {
        this.pass("Phase 20 content hook review packet", "Weak/broad hooks are separated from live-fill authority.", PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET);
      } else {
        this.phase20RaceCostingGap("Phase 20 content hook review packet", "Review packet must state that it is not live-fill authority and that local quest-stage readback is authoritative.", PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET);
      }
    } else {
      this.phase20RaceCostingGap("Phase 20 content hook review packet", "Claude-review packet is missing.", PHASE20_CONTENT_HOOK_CLAUDE_REVIEW_PACKET);
    }

    this.checkPhase20RewardRecordContracts();

    for (const race of expectedRaces) {
      if (seenRaces.has(race)) {
        this.pass("Phase 20 P2 immersive race coverage", `${race} has receiver source properties.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      } else {
        this.phase20RaceCostingGap("Phase 20 P2 immersive race coverage", `${race} has no receiver source property.`, PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
      }
    }

    if (manifest.newMeshRequired === false && typeof manifest.assetRequirement === "string" && manifest.assetRequirement.toLowerCase().includes("no new mesh required")) {
      this.pass("Phase 20 P2 immersive asset policy", "Receiver manifest requires no new mesh.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 P2 immersive asset policy", "Receiver manifest must explicitly state no new mesh is required.", PHASE20_P2_IMMERSIVE_RECEIVERS_MANIFEST);
    }
  }

  checkPhase20RewardRecordContracts() {
    if (!exists(PHASE20_REWARD_RECORD_CONTRACTS)) {
      this.phase20RaceCostingGap("Phase 20 reward record contracts", "Reward contract file is missing.", PHASE20_REWARD_RECORD_CONTRACTS);
      return;
    }

    let contracts = null;
    try {
      contracts = JSON.parse(fs.readFileSync(PHASE20_REWARD_RECORD_CONTRACTS, "utf8"));
    } catch (error) {
      this.phase20RaceCostingGap("Phase 20 reward record contracts", `Could not parse reward contracts: ${error.message}`, PHASE20_REWARD_RECORD_CONTRACTS);
      return;
    }

    if (contracts.schema === "pdv.phase20.reward-record-contracts.v1") {
      this.pass("Phase 20 reward record contracts", "Reward contract schema is current.", PHASE20_REWARD_RECORD_CONTRACTS);
    } else {
      this.phase20RaceCostingGap("Phase 20 reward record contracts", `Unexpected schema ${contracts.schema || "(missing)"}.`, PHASE20_REWARD_RECORD_CONTRACTS);
    }

    const recordsPending = contracts.status === "record-contracts-pending-esp-authoring";
    const recordsAuthored = contracts.status === "records-authored-pending-manager-vmad-wire"
      || contracts.status === "records-authored-manager-wired-pending-runtime-proof";
    const managerWired = contracts.runtimeGrantStatus === "manager-wired-pending-runtime-proof";
    const grantGateMentionsSmoke = typeof contracts.grantGate === "string"
      && contracts.grantGate.includes("automated smoke");

    if (recordsPending
        && contracts.runtimeGrantStatus === "not-wired"
        && grantGateMentionsSmoke) {
      this.pass("Phase 20 reward grant boundary", "Reward contracts preserve the no-runtime-grant boundary before smoke.", PHASE20_REWARD_RECORD_CONTRACTS);
    } else if (recordsAuthored
        && managerWired
        && grantGateMentionsSmoke
        && contracts.grantGate.includes("runtime/manual")) {
      this.pass("Phase 20 reward grant boundary", "Reward contracts are manager-wired but still gated before runtime/manual proof.", PHASE20_REWARD_RECORD_CONTRACTS);
    } else {
      this.phase20RaceCostingGap("Phase 20 reward grant boundary", "Reward contracts must be either pending/no-runtime-grant or manager-wired with automated smoke plus runtime/manual proof gates.", PHASE20_REWARD_RECORD_CONTRACTS);
    }

    if (typeof contracts.authorCommand === "string"
        && contracts.authorCommand.includes("pdv-phase20-reward-author")
        && typeof contracts.checkCommand === "string"
        && contracts.checkCommand.includes("--check")
        && typeof contracts.wireCommand === "string"
        && contracts.wireCommand.includes("--wire-manager")) {
      this.pass("Phase 20 reward authoring commands", "Reward contracts declare author, wire, and readback commands.", PHASE20_REWARD_RECORD_CONTRACTS);
    } else {
      this.phase20RaceCostingGap("Phase 20 reward authoring commands", "Reward contracts must declare pdv-phase20-reward-author create/wire/check commands.", PHASE20_REWARD_RECORD_CONTRACTS);
    }

    this.checkSourceContains("Phase 20 reward manager source", "PDV__ManagerQuest", [
      "Spell Property PDV_Bless_Altmer_Orthodox_T1 Auto",
      "Spell Property PDV_Bless_Argonian_Hist_T1 Auto",
      "Spell Property PDV_Bless_Bosmer_Yffre_T1 Auto",
      "Spell Property PDV_Bless_Breton_Tradition_T1 Auto",
      "Spell Property PDV_Bless_Dunmer_Reclamation_T1 Auto",
      "Spell Property PDV_Bless_Imperial_Civic_T1 Auto",
      "Spell Property PDV_Bless_Khajiit_Lunar_T1 Auto",
      "Spell Property PDV_Bless_Nord_OldWays_T1 Auto",
      "Spell Property PDV_Bless_Orc_Malacath_T1 Auto",
      "Spell Property PDV_Bless_Redguard_AncestorSpine_T1 Auto",
      "Function SyncFirstTierRaceRewardRuntime()",
      "Function IsFirstTierRaceRewardEligible()",
      "Function SyncRaceRewardSpell(Actor playerRef, Spell rewardSpell, Bool shouldBeActive, String rewardLabel)",
      "StorageUtil.SetIntValue(None, \"PDV.RaceReward.T1Active\", 1)",
      "GetPatronState() == PATRON_STATE_ACTIVE",
    ], this.phase20RaceCostingGap.bind(this));

    const entries = Array.isArray(contracts.races) ? contracts.races : [];
    const seenRaces = new Set();
    const requiredFields = [
      "race",
      "tier",
      "spellEditorId",
      "magicEffectEditorId",
      "displayName",
      "playerFacingText",
      "recordReadbackAssertion",
      "grantRemovalOwner",
      "stackCapRule",
      "daedricInteraction",
      "implementationStatus",
    ];
    for (const entry of entries) {
      const missing = requiredFields.filter((field) => !(typeof entry[field] === "string" && entry[field].trim().length > 0));
      if (!Array.isArray(entry.effects) || entry.effects.length === 0) {
        missing.push("effects");
      }
      const race = entry.race || "(unnamed race)";
      if (missing.length === 0) {
        this.pass("Phase 20 reward race contract", `${race} declares first-tier reward record and grant-boundary metadata.`, PHASE20_REWARD_RECORD_CONTRACTS);
      } else {
        this.phase20RaceCostingGap("Phase 20 reward race contract", `${race} missing ${missing.join(", ")}.`, PHASE20_REWARD_RECORD_CONTRACTS);
      }

      if (entry.race) {
        seenRaces.add(entry.race);
      }

      const text = `${entry.playerFacingText || ""} ${entry.notes || ""}`;
      if (/[\u0080-\uffff]/.test(text)) {
        this.phase20RaceCostingGap("Phase 20 reward text encoding", `${race} reward text must remain ASCII-safe.`, PHASE20_REWARD_RECORD_CONTRACTS);
      }

      for (const effect of entry.effects || []) {
        const missingEffectFields = ["magicEffectEditorId", "displayName", "actorValue"].filter((field) => !(typeof effect[field] === "string" && effect[field].trim().length > 0));
        if (!(typeof effect.magnitude === "number")) {
          missingEffectFields.push("magnitude");
        }
        if (missingEffectFields.length === 0) {
          this.pass("Phase 20 reward effect contract", `${race} effect ${effect.magicEffectEditorId} declares actor value and provisional magnitude.`, PHASE20_REWARD_RECORD_CONTRACTS);
        } else {
          this.phase20RaceCostingGap("Phase 20 reward effect contract", `${race} effect is missing ${missingEffectFields.join(", ")}.`, PHASE20_REWARD_RECORD_CONTRACTS);
        }
      }

      if (!recordsPending) {
        const spellRecord = this.recordsByEdid.get(entry.spellEditorId);
        if (spellRecord?.type === "SPEL") {
          this.pass("Phase 20 reward spell record", `${entry.spellEditorId} exists as SPEL.`, PDV_ESP);
        } else {
          this.phase20RaceCostingGap("Phase 20 reward spell record", `${entry.spellEditorId} is missing as SPEL.`, PDV_ESP);
        }

        for (const effect of entry.effects || []) {
          const effectRecord = this.recordsByEdid.get(effect.magicEffectEditorId);
          if (effectRecord?.type === "MGEF") {
            this.pass("Phase 20 reward magic effect record", `${effect.magicEffectEditorId} exists as MGEF.`, PDV_ESP);
          } else {
            this.phase20RaceCostingGap("Phase 20 reward magic effect record", `${effect.magicEffectEditorId} is missing as MGEF.`, PDV_ESP);
          }
        }
      }
    }

    for (const race of ["Altmer", "Argonian", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"]) {
      if (seenRaces.has(race)) {
        this.pass("Phase 20 reward race coverage", `${race} has a first-tier reward contract.`, PHASE20_REWARD_RECORD_CONTRACTS);
      } else {
        this.phase20RaceCostingGap("Phase 20 reward race coverage", `${race} reward contract is missing.`, PHASE20_REWARD_RECORD_CONTRACTS);
      }
    }

    if (managerWired) {
      const manager = this.recordDetails.get("PDV__ManagerQuest");
      const managerScript = manager ? findScript(manager.fields, "PDV__ManagerQuest") : null;
      if (!managerScript) {
        this.phase20RaceCostingGap("Phase 20 reward manager property", "PDV__ManagerQuest VMAD script is missing.", PDV_ESP);
      } else {
        const props = propertyMap(managerScript);
        for (const entry of entries) {
          this.checkObjectPropertyTarget("Phase 20 reward manager property", props, entry.spellEditorId, entry.spellEditorId, this.phase20RaceCostingGap.bind(this));
        }
      }
    }
  }

  checkShrineBlessingNeutralization() {
    let manifest = null;
    try {
      manifest = JSON.parse(fs.readFileSync(SHRINE_BLESSING_NEUTRALIZATION_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Shrine blessing neutralization manifest", `Could not parse manifest: ${error.message}`, SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
      return;
    }

    if (manifest.schema === "pdv.shrine-blessing-neutralization.v2"
        && manifest.policy === "cure-only"
        && manifest.presentationPolicy === "override-temple-blessing-message"
        && manifest.output === "main-esp") {
      this.pass("Shrine blessing neutralization manifest", "Manifest declares cure-only main-ESP normalization plus BlessingMessage prayer text overrides.", SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
    } else {
      this.fail("Shrine blessing neutralization manifest", "Manifest must use schema v2, policy cure-only, presentationPolicy override-temple-blessing-message, and output main-esp.", SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
      return;
    }

    const targets = Array.isArray(manifest.baselineSpellTargets) ? manifest.baselineSpellTargets : [];
    if (targets.length === 14) {
      this.pass("Shrine blessing target count", "Manifest contains the fourteen approved baseline shrine blessing spells.", SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
    } else {
      this.fail("Shrine blessing target count", `Manifest contains ${targets.length} baseline targets; expected 14.`, SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
    }

    const activatorOverrideKeys = new Set();
    for (const target of targets) {
      if (target.sourceActivator) {
        const normalized = normalizeFormidToken(target.sourceActivator);
        if (normalized) activatorOverrideKeys.add(normalized);
      }
    }
    for (const target of manifest.activatorTargets || []) {
      if (target.activatorFormId) {
        const normalized = normalizeFormidToken(target.activatorFormId);
        if (normalized) activatorOverrideKeys.add(normalized);
      }
    }

    const unexpectedActivatorOverrides = [...this.recordsByFormid.values()]
      .filter((record) => record.type === "ACTI")
      .filter((record) => activatorOverrideKeys.has(normalizeFormidToken(record.formid)));
    if (unexpectedActivatorOverrides.length === 0) {
      this.pass("Shrine activator override boundary", "Main ESP does not replace vanilla/mod-added clickable shrine activators or their scripts.", PDV_ESP);
    } else {
      this.fail(
        "Shrine activator override boundary",
        `Unexpected shrine ACTI override(s): ${unexpectedActivatorOverrides.map((record) => record.formid).join(", ")}.`,
        PDV_ESP,
      );
    }

    for (const target of targets) {
      const record = [...this.recordsByFormid.values()]
        .find((candidate) => formidsEqual(candidate.formid, target.spellFormId));
      if (record?.type === "SPEL") {
        this.pass("Shrine blessing spell override", `${target.spellEditorId} is owned by the main ESP as a SPEL override.`, PDV_ESP);
      } else {
        this.fail("Shrine blessing spell override", `${target.spellEditorId} (${target.spellFormId}) is missing as a main-ESP SPEL override.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetailsByFormid.get(record.formid) || this.recordDetails.get(target.spellEditorId);
      const effects = Array.isArray(detail?.fields?.Effects) ? detail.fields.Effects : [];
      const cureEffects = effects.filter((effect) => formidsEqual(effect.BaseEffect, target.expectedCureEffect));
      const removedEffects = (target.expectedRemovedEffects || [])
        .filter((effectFormId) => effects.some((effect) => formidsEqual(effect.BaseEffect, effectFormId)));
      if (effects.length === 1 && cureEffects.length === 1 && removedEffects.length === 0) {
        this.pass("Shrine blessing cure-only readback", `${target.spellEditorId} retains only ${target.expectedCureEffect}.`, PDV_ESP);
      } else {
        this.fail(
          "Shrine blessing cure-only readback",
          `${target.spellEditorId} effects=${effects.length}, cure=${cureEffects.length}, removed-still-present=${removedEffects.join(", ") || "none"}.`,
          PDV_ESP,
        );
      }

      const messageRecord = [...this.recordsByFormid.values()]
        .find((candidate) => formidsEqual(candidate.formid, target.expectedBlessingMessage));
      if (messageRecord && (messageRecord.type === "MESG" || messageRecord.type === "MESSAGE")) {
        this.pass("Shrine prayer message override", `${target.expectedBlessingMessage} is owned by the main ESP for ${target.spellEditorId}.`, PDV_ESP);
      } else {
        this.fail("Shrine prayer message override", `${target.spellEditorId} is missing main-ESP MESG override ${target.expectedBlessingMessage}.`, PDV_ESP);
        continue;
      }

      const messageDetail = this.recordDetailsByFormid.get(messageRecord.formid) || this.recordDetails.get(messageRecord.edid);
      const actualPrayerText = messageDetail?.fields?.Description || "";
      const textIsAscii = !/[\u0080-\uffff]/.test(actualPrayerText);
      const hasVanillaBlessingLanguage = /\bBlessing of\b/i.test(actualPrayerText) || /\badded\b/i.test(actualPrayerText);
      if (actualPrayerText === target.expectedPrayerText && textIsAscii && !hasVanillaBlessingLanguage) {
        this.pass("Shrine prayer message text", `${target.spellEditorId} shows "${target.expectedPrayerText}".`, PDV_ESP);
      } else {
        this.fail(
          "Shrine prayer message text",
          `${target.spellEditorId} message text is "${actualPrayerText}", expected "${target.expectedPrayerText}" with no vanilla blessing-added language.`,
          PDV_ESP,
        );
      }
    }

    const coveredActivators = Array.isArray(manifest.activatorTargets)
      && manifest.activatorTargets.length >= 6
      && manifest.activatorTargets.every((target) => target.status === "covered-by-baseline-spell");
    const candidateQueue = Array.isArray(manifest.candidateActivatorTargets)
      && manifest.candidateActivatorTargets.length >= 5
      && manifest.candidateActivatorTargets.every((target) => target.status === "review-only");
    if (coveredActivators && candidateQueue) {
      this.pass("Shrine activator coverage manifest", "Clickable reused-spell activators are marked covered and non-blessing shrine-like activators stay review-only.", SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
    } else {
      this.fail("Shrine activator coverage manifest", "Manifest must keep covered activators and review-only candidates explicit.", SHRINE_BLESSING_NEUTRALIZATION_MANIFEST);
    }
  }

  checkPhase20NoInGameProofGates() {
    if (!exists(PHASE20_NO_IN_GAME_PROOF_GATES)) {
      this.phase20RaceCostingGap("Phase 20 no-in-game gates", "Structured no-in-game gate file is missing.", PHASE20_NO_IN_GAME_PROOF_GATES);
      return;
    }

    let gates = null;
    try {
      gates = JSON.parse(fs.readFileSync(PHASE20_NO_IN_GAME_PROOF_GATES, "utf8"));
    } catch (error) {
      this.phase20RaceCostingGap("Phase 20 no-in-game gates", `Could not parse gate file: ${error.message}`, PHASE20_NO_IN_GAME_PROOF_GATES);
      return;
    }

    if (gates.schema === "pdv.phase20.no-in-game-proof-gates.v2") {
      this.pass("Phase 20 no-in-game gates", "Gate schema is current.", PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 no-in-game gates", `Unexpected schema ${gates.schema || "(missing)"}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
    }

    const races = gates.races || {};
    const requiredRaces = ["Altmer", "Khajiit", "Argonian", "Orc", "Redguard", "Bosmer", "Breton", "Dunmer", "Imperial", "Nord"];
    const p0p1 = new Set(["Altmer", "Khajiit", "Argonian", "Orc", "Redguard", "Bosmer"]);
    const p2 = new Set(["Breton", "Dunmer", "Imperial", "Nord"]);
    const allowedStatuses = new Set(gates.rules?.allowedStatuses || []);
    const requiredVerdict = gates.rules?.raceVerdict || "Fail - runtime/manual proof deferred";
    const p0p1MinimumRejectedHooks = Number(gates.rules?.p0p1MinimumRejectedHooks || 6);
    const p2MinimumRejectedHooks = Number(gates.rules?.p2MinimumRejectedHooks || 4);
    if (typeof gates.rules?.allRaceSourceCurationPolicy === "string"
        && gates.rules.allRaceSourceCurationPolicy.includes("Do not promote scan-only quest candidates")
        && gates.sourceCurationRunbook === "references/authoring/PDV_Phase20_AllRaceSourceCuration_Runbook.md") {
      this.pass("Phase 20 all-race source curation policy", "Gate records the all-race exact-source policy and runbook.", PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 all-race source curation policy", "Gate must record the all-race exact-source policy and curation runbook.", PHASE20_NO_IN_GAME_PROOF_GATES);
    }

    for (const race of requiredRaces) {
      const packet = races[race];
      if (!packet) {
        this.phase20RaceCostingGap("Phase 20 no-in-game race packet", `${race} packet is missing.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        continue;
      }

      if (packet.verdict === requiredVerdict) {
        this.pass("Phase 20 no-in-game race verdict", `${race} remains runtime/manual proof deferred.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game race verdict", `${race} verdict is ${packet.verdict || "(missing)"}, expected ${requiredVerdict}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      if (allowedStatuses.has(packet.noInGameStatus)) {
        this.pass("Phase 20 no-in-game race status", `${race} status is ${packet.noInGameStatus}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game race status", `${race} has invalid no-in-game status ${packet.noInGameStatus || "(missing)"}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      if (packet.sourceCurationStatus === "exact-source-curation-pending"
          && packet.sourceCurationRunbook === "references/authoring/PDV_Phase20_AllRaceSourceCuration_Runbook.md"
          && typeof packet.questCandidatePolicy === "string"
          && packet.questCandidatePolicy.includes("Scan-only quest candidates")) {
        this.pass("Phase 20 no-in-game source curation status", `${race} is held at exact-source curation pending.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game source curation status", `${race} is missing the exact-source curation/runbook policy.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      for (const field of ["expectedBuild", "edgeBuild", "normalSessionRoute", "surveyStatusRequirement", "rewardFloor", "rewardCeiling", "nextAutomatableAction", "deferredManualProof"]) {
        if (typeof packet[field] === "string" && packet[field].trim().length > 0) {
          this.pass("Phase 20 no-in-game race field", `${race} declares ${field}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        } else {
          this.phase20RaceCostingGap("Phase 20 no-in-game race field", `${race} is missing ${field}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        }
      }

      const rejectedHooks = packet.rejectedHooks || [];
      const minimumRejectedHooks = p2.has(race) ? p2MinimumRejectedHooks : p0p1MinimumRejectedHooks;
      if (rejectedHooks.length >= minimumRejectedHooks) {
        this.pass("Phase 20 no-in-game rejected hooks", `${race} names ${rejectedHooks.length} rejected hook families.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game rejected hooks", `${race} names ${rejectedHooks.length}; expected at least ${minimumRejectedHooks}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      const antiFarmRules = packet.antiFarmRules || [];
      if (antiFarmRules.length >= 2) {
        this.pass("Phase 20 no-in-game anti-farm rules", `${race} names ${antiFarmRules.length} anti-farm rule(s).`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game anti-farm rules", `${race} names ${antiFarmRules.length}; expected at least 2.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      const stack = packet.stackSnapshot || {};
      const stackFields = ["expected", "edge", "allowedLoudLayers", "suppressedLayers", "contextualFavorCap", "curseDaedricModifierNote"];
      const missingStackFields = stackFields.filter((field) => {
        const value = stack[field];
        return Array.isArray(value) ? value.length === 0 : !(typeof value === "string" && value.trim().length > 0);
      });
      if (missingStackFields.length === 0) {
        this.pass("Phase 20 no-in-game stack snapshot", `${race} declares expected/edge stack and ceiling controls.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game stack snapshot", `${race} missing stack field(s): ${missingStackFields.join(", ")}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      const finalPlacementContracts = packet.finalPlacementContracts || [];
      if (finalPlacementContracts.length === 0) {
        this.pass("Phase 20 no-in-game legacy placement contracts retired", `${race} no longer uses finalPlacementContracts as the final-world proof model.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game legacy placement contracts retired", `${race} still declares ${finalPlacementContracts.length} legacy finalPlacementContracts; use immersiveHookContracts plus devProofContracts.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      const immersiveHookContracts = packet.immersiveHookContracts || [];
      const minimumImmersiveHookContracts = Number(gates.rules?.minimumImmersiveHookContracts || 2);
      if (immersiveHookContracts.length >= minimumImmersiveHookContracts) {
        this.pass("Phase 20 no-in-game immersive hook contracts", `${race} declares ${immersiveHookContracts.length} immersive hook contract(s).`, PHASE20_NO_IN_GAME_PROOF_GATES);
      } else {
        this.phase20RaceCostingGap("Phase 20 no-in-game immersive hook contracts", `${race} declares ${immersiveHookContracts.length}; expected at least ${minimumImmersiveHookContracts}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
      }

      const requiredImmersiveHookFields = gates.rules?.requiredImmersiveHookContractFields || [
        "signalId",
        "playerExperience",
        "hookClass",
        "receiverPlan",
        "vanillaOrPo3Source",
        "routeTarget",
        "acceptedContext",
        "rejectedContext",
        "antiFarmRule",
        "proofPath",
        "assetRequirement",
        "newMeshRequired",
        "missingAssetIfRequired",
      ];
      for (const contract of immersiveHookContracts) {
        const missing = requiredImmersiveHookFields.filter((field) => {
          const value = contract[field];
          if (field === "newMeshRequired") return typeof value !== "boolean";
          return !(typeof value === "string" && value.trim().length > 0);
        });
        const signalId = typeof contract.signalId === "string" && contract.signalId.trim().length > 0 ? contract.signalId : "(unnamed signal)";
        if (missing.length === 0) {
          this.pass("Phase 20 no-in-game immersive hook contract", `${race} ${signalId} declares receiver, route, proof, and asset policy.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        } else {
          this.phase20RaceCostingGap("Phase 20 no-in-game immersive hook contract", `${race} ${signalId} is missing ${missing.join(", ")}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        }

        if (contract.newMeshRequired === true) {
          if (typeof contract.missingAssetIfRequired === "string" && contract.missingAssetIfRequired.trim().length > 0 && contract.missingAssetIfRequired.trim().toLowerCase() !== "none") {
            this.pass("Phase 20 no-in-game immersive hook asset request", `${race} ${signalId} names required new mesh asset: ${contract.missingAssetIfRequired}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          } else {
            this.phase20RaceCostingGap("Phase 20 no-in-game immersive hook asset request", `${race} ${signalId} marks newMeshRequired=true but does not name the missing asset.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          }
        } else if (contract.newMeshRequired === false) {
          if (typeof contract.assetRequirement === "string" && contract.assetRequirement.toLowerCase().includes("no new mesh required")) {
            this.pass("Phase 20 no-in-game immersive hook asset status", `${race} ${signalId} explicitly requires no new mesh.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          } else {
            this.phase20RaceCostingGap("Phase 20 no-in-game immersive hook asset status", `${race} ${signalId} marks newMeshRequired=false but assetRequirement does not explicitly say no new mesh is required.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          }
        }
      }

      if (p2.has(race)) {
        const audit = packet.p2AuditContract || {};
        if (audit.evidenceMode === "full-end-state-wiring-with-stack-audit") {
          this.pass("Phase 20 no-in-game P2 audit mode", `${race} declares full end-state wiring with stack audit controls.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        } else {
          this.phase20RaceCostingGap("Phase 20 no-in-game P2 audit mode", `${race} is missing full-end-state-wiring-with-stack-audit mode.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        }

        const auditArrayChecks = [
          ["positiveProbeFamilies", 3],
          ["rejectedProbeFamilies", 4],
          ["requiredStackEvidence", 6],
          ["passBlockers", 3],
        ];
        for (const [field, minimum] of auditArrayChecks) {
          const values = Array.isArray(audit[field]) ? audit[field] : [];
          if (values.length >= minimum) {
            this.pass("Phase 20 no-in-game P2 audit contract", `${race} declares ${values.length} ${field}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          } else {
            this.phase20RaceCostingGap("Phase 20 no-in-game P2 audit contract", `${race} declares ${values.length} ${field}; expected at least ${minimum}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
          }
        }

        if (typeof audit.manualEvidenceTarget === "string" && audit.manualEvidenceTarget.trim().length > 0) {
          this.pass("Phase 20 no-in-game P2 evidence target", `${race} names the manual evidence target.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        } else {
          this.phase20RaceCostingGap("Phase 20 no-in-game P2 evidence target", `${race} is missing a manual evidence target.`, PHASE20_NO_IN_GAME_PROOF_GATES);
        }
      }
    }

    const cat6 = gates.cat6 || {};
    const firstTargetPresent = this.recordsByEdid.has(cat6.firstCandidate);
    const fallbackTargetPresent = this.recordsByEdid.has(cat6.fallbackCandidate);
    if ((cat6.status === "target-record-needed" || cat6.status === "pilot-record-readback-proven") && cat6.firstTargetRecordPresent === firstTargetPresent && cat6.fallbackTargetRecordPresent === fallbackTargetPresent) {
      this.pass("Phase 20 CAT-6 target readback status", `CAT-6 target availability is documented: first=${firstTargetPresent}, fallback=${fallbackTargetPresent}.`, PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 target readback status", "CAT-6 target availability in the gate file does not match live readback or an allowed CAT-6 status.", PHASE20_NO_IN_GAME_PROOF_GATES);
    }
    if (typeof cat6.ownerDecision === "string" && cat6.ownerDecision.includes("target")) {
      this.pass("Phase 20 CAT-6 owner decision", "CAT-6 names the target-record owner decision still needed.", PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 owner decision", "CAT-6 does not name the target-record owner decision.", PHASE20_NO_IN_GAME_PROOF_GATES);
    }

    const recognition = gates.recognition || {};
    if ((recognition.positiveGate || []).length >= 3 && (recognition.negativeGates || []).length >= 3 && (recognition.recordIdentityPlan || []).length >= 3) {
      this.pass("Phase 20 recognition packet prep", "Recognition packet has positive gates, negative gates, and planned CK identities.", PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 recognition packet prep", "Recognition packet is missing positive gates, negative gates, or CK identity plan.", PHASE20_NO_IN_GAME_PROOF_GATES);
    }

    const daedric = gates.daedricBlockers || {};
    const batch0 = Array.isArray(daedric.batch0TemplateProof) ? daedric.batch0TemplateProof : [];
    const lockedByDecision = (value, id) =>
      value === `locked-${id}` || value === `resolved-by-${id}`;
    const decisionsLocked =
      lockedByDecision(daedric.stigmaRowContract, "D15") &&
      lockedByDecision(daedric.hircineMolagBalCurseAccessTemplate, "D16") &&
      lockedByDecision(daedric.princePromotionOrder, "D17") &&
      lockedByDecision(daedric.contentReadyDefinition, "D18");
    const proofStillBlocked =
      daedric.runtimePromotionAllowed === false &&
      typeof daedric.promotionGatedBy === "string" &&
      daedric.promotionGatedBy.includes("CAT-6") &&
      typeof daedric.readinessLedger === "string" &&
      daedric.readinessLedger.includes("PDV_AllRaceDaedricBetaReadinessLedger.md") &&
      typeof daedric.batch0ProofLedger === "string" &&
      daedric.batch0ProofLedger.includes("PDV_DaedricBatch0_D18ProofLedger.md") &&
      daedric.batch0StaticD18Proof === "complete-no-esp-writes" &&
      batch0.includes("Azura / Azurah") &&
      batch0.includes("Vaermina") &&
      batch0.includes("Meridia") &&
      batch0.includes("Molag Bal");
    if (decisionsLocked && proofStillBlocked) {
      this.pass("Phase 20 Daedric blocker state", "Daedric decisions D-15..D-18 are locked, and runtime promotion remains blocked on per-Prince proof.", PHASE20_NO_IN_GAME_PROOF_GATES);
    } else {
      this.phase20RaceCostingGap("Phase 20 Daedric blocker state", "Daedric blocker state is missing or implies runtime promotion is allowed too early.", PHASE20_NO_IN_GAME_PROOF_GATES);
    }
  }

  checkPhase20Cat6PromotionPilot() {
    if (!exists(CAT6_PROMOTION_MANIFEST)) {
      this.phase20RaceCostingGap("Phase 20 CAT-6 promotion pilot", "CAT-6 promotion manifest is missing.", CAT6_PROMOTION_MANIFEST);
      return;
    }

    let manifest = null;
    try {
      manifest = JSON.parse(fs.readFileSync(CAT6_PROMOTION_MANIFEST, "utf8"));
    } catch (error) {
      this.phase20RaceCostingGap("Phase 20 CAT-6 promotion pilot", `Could not parse CAT-6 manifest: ${error.message}`, CAT6_PROMOTION_MANIFEST);
      return;
    }

    if (manifest.schema === "pdv.cat6.promotion-pilot.v1") {
      this.pass("Phase 20 CAT-6 promotion pilot", "CAT-6 promotion manifest schema is current.", CAT6_PROMOTION_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 promotion pilot", `Unexpected CAT-6 manifest schema ${manifest.schema || "(missing)"}.`, CAT6_PROMOTION_MANIFEST);
    }

    const packet = manifest.packets?.[0];
    if (manifest.packets?.length === 1 && packet?.sourceRow === "PDV_Bless_Khajiit_Lunar_T1" && packet?.spell === "PDV_Bless_Khajiit_Lunar_T1") {
      this.pass("Phase 20 CAT-6 packet scope", "CAT-6 pilot is restricted to PDV_Bless_Khajiit_Lunar_T1.", CAT6_PROMOTION_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 packet scope", "CAT-6 pilot must contain exactly the Khajiit Lunar Tier 1 blessing packet.", CAT6_PROMOTION_MANIFEST);
      return;
    }

    const sourceText = this.extractContentManifestRowText(packet.sourceRow);
    if (!sourceText) {
      this.phase20RaceCostingGap("Phase 20 CAT-6 source row", `${packet.sourceRow} source row text was not found.`, RACE_CONTENT_MANIFEST);
      return;
    }
    if (/at night/i.test(sourceText) && !/moving outdoors at night/i.test(sourceText)) {
      this.pass("Phase 20 CAT-6 source row", "Khajiit Tier 1 source text matches the night-only pilot wording.", RACE_CONTENT_MANIFEST);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 source row", "Khajiit Tier 1 source text must describe the pilot as night-only, not outdoor/moving-gated.", RACE_CONTENT_MANIFEST);
    }

    const spellRecord = this.recordsByEdid.get(packet.spell);
    const spellDetail = this.recordDetails.get(packet.spell);
    if (spellRecord?.type === "SPEL" && spellDetail?.fields) {
      this.pass("Phase 20 CAT-6 spell record", `${packet.spell} exists as SPEL.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 spell record", `${packet.spell} is missing as a live SPEL.`, PDV_ESP);
      return;
    }

    const spellFields = spellDetail.fields || {};
    this.checkCat6Text("Phase 20 CAT-6 spell text", packet.spell, spellFields.Description, sourceText, PDV_ESP);
    if (spellFields.Type === "Ability" && spellFields.CastType === "ConstantEffect" && spellFields.TargetType === "Self") {
      this.pass("Phase 20 CAT-6 spell shape", "Khajiit Tier 1 spell is a constant self ability.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 spell shape", "Khajiit Tier 1 spell is not a constant self ability.", PDV_ESP);
    }

    const effects = Array.isArray(packet.effects) ? packet.effects : [];
    const spellEffects = Array.isArray(spellFields.Effects) ? spellFields.Effects : [];
    if (effects.length === 2 && spellEffects.length === 2) {
      this.pass("Phase 20 CAT-6 spell effects", "Khajiit Tier 1 spell has the two pilot effect entries.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 spell effects", `Khajiit Tier 1 spell has ${spellEffects.length} effect entries; expected 2.`, PDV_ESP);
    }

    for (const effect of effects) {
      const record = this.recordsByEdid.get(effect.magicEffect);
      const detail = this.recordDetails.get(effect.magicEffect);
      if (record?.type === "MGEF" && detail?.fields) {
        this.pass("Phase 20 CAT-6 magic effect", `${effect.magicEffect} exists as MGEF.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 CAT-6 magic effect", `${effect.magicEffect} is missing as a live MGEF.`, PDV_ESP);
        continue;
      }

      const fields = detail.fields || {};
      this.checkCat6Text("Phase 20 CAT-6 magic effect text", effect.magicEffect, fields.Description, sourceText, PDV_ESP);
      const archetype = fields.Archetype || {};
      if (archetype.Type === effect.archetype && archetype.ActorValue === effect.actorValue) {
        this.pass("Phase 20 CAT-6 magic effect archetype", `${effect.magicEffect} is ${effect.archetype}/${effect.actorValue}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 CAT-6 magic effect archetype", `${effect.magicEffect} archetype readback did not match ${effect.archetype}/${effect.actorValue}.`, PDV_ESP);
      }

      const linked = spellEffects.find((entry) => formidToEdid(entry.BaseEffect, this.recordsByEdid) === effect.magicEffect);
      if (linked) {
        this.pass("Phase 20 CAT-6 spell link", `${packet.spell} links ${effect.magicEffect}.`, PDV_ESP);
        const magnitude = Number(linked.Data?.Magnitude);
        if (Number.isFinite(magnitude) && Math.abs(magnitude - Number(effect.magnitude)) < 0.001) {
          this.pass("Phase 20 CAT-6 effect magnitude", `${effect.magicEffect} magnitude is ${effect.magnitude}.`, PDV_ESP);
        } else {
          this.phase20RaceCostingGap("Phase 20 CAT-6 effect magnitude", `${effect.magicEffect} magnitude is ${linked.Data?.Magnitude}, expected ${effect.magnitude}.`, PDV_ESP);
        }
        this.checkCat6NightConditions(linked.Conditions || [], effect.magicEffect);
      } else {
        this.phase20RaceCostingGap("Phase 20 CAT-6 spell link", `${packet.spell} does not link ${effect.magicEffect}.`, PDV_ESP);
      }
    }

    const managerText = JSON.stringify(this.recordDetails.get("PDV__ManagerQuest")?.fields || {});
    const rewardContractOwnsKhajiit = this.phase20RewardContractOwnsSpell(packet.spell);
    if (!managerText.includes(packet.spell)) {
      this.pass("Phase 20 CAT-6 grant restraint", "CAT-6 pilot has no manager grant/property wiring.", PDV_ESP);
    } else if (rewardContractOwnsKhajiit) {
      this.pass("Phase 20 CAT-6 grant restraint", "Khajiit CAT-6 spell wiring is owned by the all-race reward contract.", PHASE20_REWARD_RECORD_CONTRACTS);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 grant restraint", "CAT-6 pilot spell is wired on the manager; grant logic is out of scope for this pilot.", PDV_ESP);
    }
  }

  phase20RewardContractOwnsSpell(spellEditorId) {
    if (!exists(PHASE20_REWARD_RECORD_CONTRACTS)) {
      return false;
    }

    try {
      const contracts = JSON.parse(fs.readFileSync(PHASE20_REWARD_RECORD_CONTRACTS, "utf8"));
      return contracts.schema === "pdv.phase20.reward-record-contracts.v1"
        && contracts.status === "records-authored-manager-wired-pending-runtime-proof"
        && contracts.runtimeGrantStatus === "manager-wired-pending-runtime-proof"
        && Array.isArray(contracts.races)
        && contracts.races.some((entry) => entry?.spellEditorId === spellEditorId);
    } catch {
      return false;
    }
  }

  checkCat6Text(check, edid, actual, expected, filePath) {
    if (actual === expected) {
      this.pass(check, `${edid} text matches the source manifest exactly.`, filePath);
    } else {
      this.phase20RaceCostingGap(check, `${edid} text does not match the source manifest exactly.`, filePath);
    }
  }

  checkCat6NightConditions(conditions, effectEdid) {
    const hasAfterSevenPm = conditions.some((condition) => condition.CompareOperator === "GreaterThanOrEqualTo"
      && Number(condition.ComparisonValue) === 19
      && String(condition.Flags || "").includes("OR"));
    const hasBeforeSevenAm = conditions.some((condition) => condition.CompareOperator === "LessThanOrEqualTo"
      && Number(condition.ComparisonValue) === 7);
    if (conditions.length === 2 && hasAfterSevenPm && hasBeforeSevenAm) {
      this.pass("Phase 20 CAT-6 night conditions", `${effectEdid} is gated to GetCurrentTime >= 19 OR <= 7.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 CAT-6 night conditions", `${effectEdid} does not read back the required 19:00-07:00 condition pair.`, PDV_ESP);
    }
  }

  extractContentManifestRowText(rowId) {
    const text = fs.readFileSync(RACE_CONTENT_MANIFEST, "utf8");
    const escaped = rowId.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const match = text.match(new RegExp(`\\|\\s*${escaped}\\s*\\|(?:[^|]*\\|){6}\\s*([^|]+?)\\s*\\|`));
    return match ? match[1].trim() : null;
  }

  checkPhase20ManualEvidenceLedger() {
    if (!exists(PHASE20_MANUAL_EVIDENCE_LEDGER)) {
      this.phase20RaceCostingGap("Phase 20 manual evidence ledger", "Structured manual evidence ledger is missing.", PHASE20_MANUAL_EVIDENCE_LEDGER);
      return;
    }

    let ledger = null;
    try {
      ledger = JSON.parse(fs.readFileSync(PHASE20_MANUAL_EVIDENCE_LEDGER, "utf8"));
    } catch (error) {
      this.phase20RaceCostingGap("Phase 20 manual evidence ledger", `Could not parse manual evidence ledger: ${error.message}`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      return;
    }

    if (ledger.schema === "pdv.phase20.manual-evidence-ledger.v2") {
      this.pass("Phase 20 manual evidence ledger", "Manual evidence ledger schema is current.", PHASE20_MANUAL_EVIDENCE_LEDGER);
    } else {
      this.phase20RaceCostingGap("Phase 20 manual evidence ledger", `Unexpected schema ${ledger.schema || "(missing)"}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
    }

    if (ledger.status === "pending-manual-runtime-proof") {
      this.pass("Phase 20 manual evidence status", "Manual evidence ledger remains pending until in-game proof is recorded.", PHASE20_MANUAL_EVIDENCE_LEDGER);
    } else {
      this.phase20RaceCostingGap("Phase 20 manual evidence status", `Manual evidence ledger status is ${ledger.status || "(missing)"}, expected pending-manual-runtime-proof.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
    }

    const requiredRaces = ["Altmer", "Khajiit", "Argonian", "Orc", "Redguard", "Bosmer", "Breton", "Dunmer", "Imperial", "Nord"];
    const requiredSlots = ledger.rules?.requiredSlots || [
      "wrongOriginRejection",
      "genericHookRejection",
      "surveyStatusClarity",
      "immersiveHookProof",
      "assetStatus",
      "stackSnapshot",
      "manualFeelNote",
    ];
    const allowedSlotStatuses = new Set(ledger.rules?.allowedSlotStatuses || ["pending", "not-applicable"]);
    const disallowedCompletionStatuses = new Set((ledger.rules?.disallowedCompletionStatuses || []).map((status) => status.toLowerCase()));
    const requiredVerdict = ledger.rules?.raceVerdictBeforeEvidence || "Fail - runtime/manual proof deferred";
    const races = ledger.races || {};

    for (const race of requiredRaces) {
      const packet = races[race];
      if (!packet) {
        this.phase20RaceCostingGap("Phase 20 manual evidence race packet", `${race} manual evidence packet is missing.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
        continue;
      }

      if (packet.status === "pending") {
        this.pass("Phase 20 manual evidence race status", `${race} manual evidence remains pending.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      } else {
        this.phase20RaceCostingGap("Phase 20 manual evidence race status", `${race} manual evidence status is ${packet.status || "(missing)"}, expected pending.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      }

      if (packet.raceVerdictBeforeEvidence === requiredVerdict) {
        this.pass("Phase 20 manual evidence race verdict", `${race} keeps the deferred verdict before evidence is recorded.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      } else {
        this.phase20RaceCostingGap("Phase 20 manual evidence race verdict", `${race} verdict before evidence is ${packet.raceVerdictBeforeEvidence || "(missing)"}, expected ${requiredVerdict}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      }

      if (typeof packet.runtimeProofCommand === "string" && packet.runtimeProofCommand.trim().length > 0) {
        this.pass("Phase 20 manual evidence runtime route", `${race} declares a runtime/manual proof route.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      } else {
        this.phase20RaceCostingGap("Phase 20 manual evidence runtime route", `${race} is missing a runtime/manual proof route.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      }

      const slots = packet.manualEvidenceSlots || {};
      for (const slotName of requiredSlots) {
        const slot = slots[slotName];
        if (!slot) {
          this.phase20RaceCostingGap("Phase 20 manual evidence slot", `${race} is missing ${slotName}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
          continue;
        }

        const slotStatus = String(slot.status || "").toLowerCase();
        if (allowedSlotStatuses.has(slotStatus) && !disallowedCompletionStatuses.has(slotStatus)) {
          this.pass("Phase 20 manual evidence slot status", `${race} ${slotName} is ${slotStatus}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
        } else {
          this.phase20RaceCostingGap("Phase 20 manual evidence slot status", `${race} ${slotName} has invalid status ${slot.status || "(missing)"}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
        }

        if (typeof slot.expected === "string" && slot.expected.trim().length > 0) {
          this.pass("Phase 20 manual evidence expectation", `${race} ${slotName} has an expected result.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
        } else {
          this.phase20RaceCostingGap("Phase 20 manual evidence expectation", `${race} ${slotName} is missing its expected result.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
        }
      }

      const immersiveHookStatus = String(slots.immersiveHookProof?.status || "").toLowerCase();
      if (immersiveHookStatus === "pending" || immersiveHookStatus === "evidence-recorded") {
        this.pass("Phase 20 manual evidence immersive hook posture", `${race} immersive hook proof is tracked as ${immersiveHookStatus}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      } else {
        this.phase20RaceCostingGap("Phase 20 manual evidence immersive hook posture", `${race} immersive hook proof status ${immersiveHookStatus || "(missing)"} must be pending or evidence-recorded.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      }

      const assetStatus = String(slots.assetStatus?.status || "").toLowerCase();
      if (assetStatus === "pending" || assetStatus === "evidence-recorded") {
        this.pass("Phase 20 manual evidence asset status", `${race} asset status is tracked as ${assetStatus}.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      } else {
        this.phase20RaceCostingGap("Phase 20 manual evidence asset status", `${race} asset status ${assetStatus || "(missing)"} must be pending or evidence-recorded.`, PHASE20_MANUAL_EVIDENCE_LEDGER);
      }
    }
  }

  checkPhase20ArgonianSourceScaffold(manifest, manifestPath) {
    this.checkSourceContains("Phase 20 Argonian source", "PDV_Substrate_ArgonianHist", [
      "Scriptname PDV_Substrate_ArgonianHist extends PDV_SubstrateBase",
      "Function RecordHistMaintenanceScaled(Float multiplier, String reason)",
      "Function RecordPeopleSupportScaled(Float multiplier, String reason)",
      "Function RecordBedOfChoiceReturnScaled(Float multiplier, String reason)",
      "Function RecordVoidSignalScaled(Float multiplier, String reason)",
      "Function ProcessHistDistanceDawn(Bool curseActive, String reason)",
      "\"PDV.Substrate.ArgonianHist.Hist\"",
      "\"PDV.Substrate.ArgonianHist.People\"",
      "\"PDV.Substrate.ArgonianHist.Void\"",
      "VoidActivationSignalsRequired = 3",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Phase 20 Argonian manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_ArgonianHist Property PDV_ArgonianHistSubstrate Auto",
      "PDV_StateTrack Property PDV_ArgonianHistPostureTrack Auto",
      "ORIGIN_ARGONIAN = 7",
      "Function HandleArgonianHistMaintenance(String reason)",
      "Function HandleArgonianPeopleSupport(String reason)",
      "Function HandleArgonianBedOfChoiceReturn(String reason)",
      "Function HandleArgonianVoidSignal(String reason)",
      "Function RunDawnRefreshArgonianHist()",
      "Function RefreshArgonianHistPosture(String reason)",
      "String Function GetArgonianSurveyText()",
      "String Function GetArgonianHistSummary()",
    ]);
    this.checkSourceContains("Phase 20 Argonian EventTypes source", "PDV_EventTypes", [
      "EVT_ARGONIAN_HIST_MAINTENANCE = 60",
      "EVT_ARGONIAN_PEOPLE_SUPPORT = 61",
      "EVT_ARGONIAN_VOID_SIGNAL = 62",
      "EVT_ARGONIAN_BED_OF_CHOICE = 63",
      "argonian-hist-maintenance",
      "argonian-bed-of-choice",
    ]);
    this.checkSourceContains("Phase 20 Argonian EventBus source", "PDV_EventBus", [
      "Function RouteArgonianHistMaintenance()",
      "Function RouteArgonianPeopleSupport()",
      "Function RouteArgonianVoidSignal()",
      "Function RouteArgonianBedOfChoice()",
      "PDV_Manager.HandleArgonianHistMaintenance(\"eventbus_\" + eventType)",
      "PDV_Manager.HandleArgonianBedOfChoiceReturn(\"eventbus_\" + eventType)",
    ]);
    this.checkSourceContains("Phase 20 Argonian receiver source", "PDV_EventSignalActivator", [
      "ROUTE_ARGONIAN_HIST_MAINTENANCE = 60",
      "ROUTE_ARGONIAN_PEOPLE_SUPPORT = 61",
      "ROUTE_ARGONIAN_VOID_SIGNAL = 62",
      "ROUTE_ARGONIAN_BED_OF_CHOICE = 63",
      "PDV_EventBusService.RouteArgonianHistMaintenance()",
      "PDV_EventBusService.RouteArgonianBedOfChoice()",
    ]);

    const triggerSurfaces = manifest.triggerSurfaces || [];
    if (triggerSurfaces.length >= 4) {
      this.pass("Phase 20 Argonian trigger contract", `${triggerSurfaces.length} trigger surface(s) declared for the first proof slice.`, manifestPath);
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian trigger contract", `Only ${triggerSurfaces.length} trigger surface(s) declared.`, manifestPath);
    }

    for (const trigger of triggerSurfaces) {
      if (typeof trigger.placementRefEditorId === "string" && trigger.placementRefEditorId.startsWith("PDV_REFR_")) {
        this.pass("Phase 20 Argonian placement contract", `${trigger.editorId} declares CK placement reference ${trigger.placementRefEditorId}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap("Phase 20 Argonian placement contract", `${trigger.editorId || "(missing editorId)"} is missing placementRefEditorId.`, manifestPath);
      }
    }

    if (manifest.implementationStatus === "record-wired" || manifest.implementationStatus === "runtime-proven") {
      this.checkPhase20ArgonianRecordReadback(manifest, manifestPath);
    }
  }

  checkPhase20ArgonianRecordReadback(manifest, manifestPath) {
    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_ArgonianHist");
    if (substrateRecord?.type === "QUST") {
      this.pass("Phase 20 Argonian substrate record", "PDV_Substrate_ArgonianHist exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian substrate record", "PDV_Substrate_ArgonianHist is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_ArgonianHist");
    const substrateScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_ArgonianHist") : null;
    if (substrateScript) {
      this.pass("Phase 20 Argonian substrate script", "PDV_Substrate_ArgonianHist script is attached.", PDV_ESP);
      const props = propertyMap(substrateScript);
      this.checkScalarProperty("Phase 20 Argonian substrate property", props, "SubstrateName", "ArgonianHist", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Argonian substrate property", props, "RequiredOriginRace", 7, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian substrate property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian substrate property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian substrate script", "PDV_Substrate_ArgonianHist script is not attached.", PDV_ESP);
    }

    const postureRecord = this.recordsByEdid.get("PDV_State_ArgonianHistPosture");
    if (postureRecord?.type === "QUST") {
      this.pass("Phase 20 Argonian posture record", "PDV_State_ArgonianHistPosture exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian posture record", "PDV_State_ArgonianHistPosture is missing or not a QUST.", PDV_ESP);
    }

    const postureDetail = this.recordDetails.get("PDV_State_ArgonianHistPosture");
    const postureScript = postureDetail ? findScript(postureDetail.fields || {}, "PDV_StateTrack") : null;
    if (postureScript) {
      this.pass("Phase 20 Argonian posture script", "PDV_StateTrack is attached to PDV_State_ArgonianHistPosture.", PDV_ESP);
      const props = propertyMap(postureScript);
      this.checkScalarProperty("Phase 20 Argonian posture property", props, "TrackName", "ArgonianHistPosture", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian posture property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian posture script", "PDV_StateTrack is not attached to PDV_State_ArgonianHistPosture.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      const props = propertyMap(managerScript);
      this.checkObjectPropertyTarget("Phase 20 Argonian manager property", props, "PDV_ArgonianHistSubstrate", "PDV_Substrate_ArgonianHist", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian manager property", props, "PDV_ArgonianHistPostureTrack", "PDV_State_ArgonianHistPosture", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Argonian manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    for (const trigger of manifest.triggerSurfaces || []) {
      if (!trigger.editorId) {
        continue;
      }

      const record = this.recordsByEdid.get(trigger.editorId);
      if (record?.type === "ACTI") {
        this.pass("Phase 20 Argonian trigger record", `${trigger.editorId} exists as ACTI.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Argonian trigger record", `${trigger.editorId} is missing or not an ACTI.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetails.get(trigger.editorId);
      const script = detail ? findScript(detail.fields || {}, "PDV_EventSignalActivator") : null;
      if (!script) {
        this.phase20RaceCostingGap("Phase 20 Argonian trigger script", `${trigger.editorId} is missing PDV_EventSignalActivator.`, PDV_ESP);
        continue;
      }

      const props = propertyMap(script);
      this.checkScalarProperty("Phase 20 Argonian trigger property", props, "RouteId", trigger.routeId, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Argonian trigger property", props, "RequiredOriginRace", 7, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Argonian trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkPhase20RaceTriggerPlacement("Phase 20 Argonian trigger placement", trigger, manifestPath);
    }
  }

  checkPhase20OrcSourceScaffold(manifest, manifestPath) {
    this.checkSourceContains("Phase 20 Orc manager source", "PDV__ManagerQuest", [
      "PDV_StateTrack Property PDV_OrcLifeModeTrack Auto",
      "ORIGIN_ORC = 8",
      "ORC_LIFE_MODE_CITY = 0",
      "ORC_LIFE_MODE_STRONGHOLD = 1",
      "ORC_LIFE_MODE_LEGION_EXILE = 2",
      "Function HandleOrcStrongholdForge(String reason)",
      "Function HandleOrcCityDignity(String reason)",
      "Function HandleOrcLegionService(String reason)",
      "Function HandleOrcSelfMadeCommunity(String reason)",
      "Function RecordOrcLifeModeSignal(Int modeValue, Float multiplier, String reason)",
      "Function HandleOrcOathBreak(String reason)",
      "Function AwardOrcOathBreakSignal()",
      "Function HandleOrcFourHoldsVisit(Int holdId, String reason)",
      "Function AwardOrcFourHoldsVisitSignal()",
      "PDV.Orc.FourHolds.",
      "String Function GetOrcSurveyText()",
      "String Function GetOrcSummary()",
      "\"PDV.Curse.Orc.CodePressure\"",
    ]);
    this.checkSourceContains("Phase 20 Orc EventTypes source", "PDV_EventTypes", [
      "EVT_ORC_STRONGHOLD_FORGE = 70",
      "EVT_ORC_CITY_DIGNITY = 71",
      "EVT_ORC_LEGION_SERVICE = 72",
      "EVT_ORC_SELF_MADE_COMMUNITY = 73",
      "EVT_ORC_OATH_BREAK = 74",
      "EVT_ORC_FOUR_HOLDS_VISIT = 75",
      "orc-stronghold-forge",
      "orc-self-made-community",
      "orc-oath-break",
      "orc-four-holds-visit",
    ]);
    this.checkSourceContains("Phase 20 Orc EventBus source", "PDV_EventBus", [
      "Function RouteOrcStrongholdForge()",
      "Function RouteOrcStrongholdPresence(Int holdId, String sourceId = \"\")",
      "Function RouteOrcBloodKinCrisis(String sourceId = \"orc_cursed_tribe_resolved\")",
      "Function RouteOrcCityDignity(String sourceId = \"\")",
      "Function RouteOrcLegionService(String sourceId = \"\")",
      "Function RouteOrcSelfMadeCommunity(String sourceId = \"\")",
      "Function RouteOrcOathBreak(String sourceId)",
      "Function RouteOrcFourHoldsVisit(Int holdId, String sourceId)",
      "PDV_Manager.HandleOrcStrongholdForge(\"eventbus_\" + eventType)",
      "PDV_Manager.HandleOrcStrongholdPresence(holdId, \"eventbus_\" + eventType + \"_\" + sourceId)",
      "PDV_Manager.HandleOrcBloodKinCrisis(\"eventbus_\" + eventType + \"_\" + sourceId)",
      "PDV_Manager.HandleOrcSelfMadeCommunity(reason)",
      "PDV_Manager.HandleOrcOathBreak(\"eventbus_\" + eventType + \"_\" + sourceId)",
      "PDV_Manager.HandleOrcFourHoldsVisit(holdId, \"eventbus_\" + eventType + \"_\" + sourceId)",
    ]);
    this.checkSourceContains("Phase 20 Orc Malacath source", "PDV_Deity_Malacath", [
      "SIGNAL_FOUR_HOLDS_VISIT = 2208",
      "DELTA_FOUR_HOLDS_VISIT = 1.0",
      "return DELTA_FOUR_HOLDS_VISIT",
      "SIGNAL_ANCESTOR_SPINE = 2209",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "return DELTA_ANCESTOR_SPINE",
      "SIGNAL_OATH_BREAK = 2253",
      "DELTA_OATH_BREAK = -1.5",
      "return DELTA_OATH_BREAK",
    ]);
    this.checkSourceContains("Phase 20 Orc receiver source", "PDV_EventSignalActivator", [
      "ROUTE_ORC_STRONGHOLD_FORGE = 70",
      "ROUTE_ORC_CITY_DIGNITY = 71",
      "ROUTE_ORC_LEGION_SERVICE = 72",
      "ROUTE_ORC_SELF_MADE_COMMUNITY = 73",
      "ROUTE_ORC_OATH_BREAK = 74",
      "ROUTE_ORC_FOUR_HOLDS_VISIT = 75",
      "PDV_EventBusService.RouteOrcStrongholdForge()",
      "PDV_EventBusService.RouteOrcSelfMadeCommunity()",
      "PDV_EventBusService.RouteOrcOathBreak(GetSignalSourceId())",
      "PDV_EventBusService.RouteOrcFourHoldsVisit(SignalValue, GetSignalSourceId())",
    ]);
    this.checkSourceContains("Phase 20 Orc receiver source", "PDV_EventSignalEffect", [
      "ROUTE_ORC_STRONGHOLD_FORGE = 70",
      "ROUTE_ORC_CITY_DIGNITY = 71",
      "ROUTE_ORC_LEGION_SERVICE = 72",
      "ROUTE_ORC_SELF_MADE_COMMUNITY = 73",
      "ROUTE_ORC_OATH_BREAK = 74",
      "ROUTE_ORC_FOUR_HOLDS_VISIT = 75",
      "PDV_EventBusService.RouteOrcStrongholdForge()",
      "PDV_EventBusService.RouteOrcSelfMadeCommunity()",
      "PDV_EventBusService.RouteOrcOathBreak(GetSignalSourceId())",
      "PDV_EventBusService.RouteOrcFourHoldsVisit(SignalValue, GetSignalSourceId())",
    ]);

    const triggerSurfaces = manifest.triggerSurfaces || [];
    if (triggerSurfaces.length >= 4) {
      this.pass("Phase 20 Orc trigger contract", `${triggerSurfaces.length} trigger surface(s) declared for the first proof slice.`, manifestPath);
    } else {
      this.phase20RaceCostingGap("Phase 20 Orc trigger contract", `Only ${triggerSurfaces.length} trigger surface(s) declared.`, manifestPath);
    }

    for (const trigger of triggerSurfaces) {
      if (typeof trigger.placementRefEditorId === "string" && trigger.placementRefEditorId.startsWith("PDV_REFR_")) {
        this.pass("Phase 20 Orc placement contract", `${trigger.editorId} declares CK placement reference ${trigger.placementRefEditorId}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap("Phase 20 Orc placement contract", `${trigger.editorId || "(missing editorId)"} is missing placementRefEditorId.`, manifestPath);
      }
    }

    if (manifest.implementationStatus === "record-wired" || manifest.implementationStatus === "runtime-proven") {
      this.checkPhase20OrcRecordReadback(manifest, manifestPath);
    }
  }

  checkPhase20OrcRecordReadback(manifest, manifestPath) {
    const trackRecord = this.recordsByEdid.get("PDV_StateTrack_OrcLifeMode");
    if (trackRecord?.type === "QUST") {
      this.pass("Phase 20 Orc life-mode record", "PDV_StateTrack_OrcLifeMode exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Orc life-mode record", "PDV_StateTrack_OrcLifeMode is missing or not a QUST.", PDV_ESP);
    }

    const trackDetail = this.recordDetails.get("PDV_StateTrack_OrcLifeMode");
    const trackScript = trackDetail ? findScript(trackDetail.fields || {}, "PDV_StateTrack") : null;
    if (trackScript) {
      this.pass("Phase 20 Orc life-mode script", "PDV_StateTrack is attached to PDV_StateTrack_OrcLifeMode.", PDV_ESP);
      const props = propertyMap(trackScript);
      this.checkScalarProperty("Phase 20 Orc life-mode property", props, "TrackName", "OrcLifeMode", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Orc life-mode property", props, "StateGlobal", "PDV_GLO_OrcLifeMode", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Orc life-mode property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      const labels = propValue(props.get("StateLabels")) || [];
      const expectedLabels = ["City", "Stronghold", "LegionExile"];
      if (Array.isArray(labels) && labels.length === expectedLabels.length && labels.every((label, index) => label === expectedLabels[index])) {
        this.pass("Phase 20 Orc life-mode property", "StateLabels match the locked Orc life-mode enum order.", PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Orc life-mode property", `StateLabels are ${JSON.stringify(labels)}, expected ${JSON.stringify(expectedLabels)}.`, PDV_ESP);
      }
    } else {
      this.phase20RaceCostingGap("Phase 20 Orc life-mode script", "PDV_StateTrack is not attached to PDV_StateTrack_OrcLifeMode.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      const props = propertyMap(managerScript);
      this.checkObjectPropertyTarget("Phase 20 Orc manager property", props, "PDV_OrcLifeModeTrack", "PDV_StateTrack_OrcLifeMode", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Orc manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    for (const trigger of manifest.triggerSurfaces || []) {
      if (!trigger.editorId) {
        continue;
      }

      const record = this.recordsByEdid.get(trigger.editorId);
      if (record?.type === "ACTI") {
        this.pass("Phase 20 Orc trigger record", `${trigger.editorId} exists as ACTI.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Orc trigger record", `${trigger.editorId} is missing or not an ACTI.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetails.get(trigger.editorId);
      const script = detail ? findScript(detail.fields || {}, "PDV_EventSignalActivator") : null;
      if (!script) {
        this.phase20RaceCostingGap("Phase 20 Orc trigger script", `${trigger.editorId} is missing PDV_EventSignalActivator.`, PDV_ESP);
        continue;
      }

      const props = propertyMap(script);
      this.checkScalarProperty("Phase 20 Orc trigger property", props, "RouteId", trigger.routeId, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Orc trigger property", props, "RequiredOriginRace", 8, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Orc trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Orc trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkPhase20RaceTriggerPlacement("Phase 20 Orc trigger placement", trigger, manifestPath);
    }
  }

  checkPhase20RedguardSourceScaffold(manifest, manifestPath) {
    this.checkSourceContains("Phase 20 Redguard manager source", "PDV__ManagerQuest", [
      "PDV_StateTrack Property PDV_RedguardSectTrack Auto",
      "ORIGIN_REDGUARD = 9",
      "REDGUARD_SECT_CROWN = 0",
      "REDGUARD_SECT_FOREBEAR = 1",
      "REDGUARD_SECT_ASHABAH = 2",
      "Function HandleRedguardCrownTombRespect(String reason)",
      "Function HandleRedguardForebearRoadPassage(String reason)",
      "Function HandleRedguardAshAbahDeathDuty(String reason)",
      "Function HandleRedguardFarShoresToken(String reason)",
      "Function RecordRedguardSectSignal(Int sectValue, Float multiplier, String reason)",
      "String Function GetRedguardSurveyText()",
      "String Function GetRedguardSummary()",
      "\"PDV.Redguard.FarShoresToken\"",
      "\"PDV.Curse.Redguard.CyclePressure\"",
    ]);
    this.checkSourceContains("Phase 20 Redguard EventTypes source", "PDV_EventTypes", [
      "EVT_REDGUARD_CROWN_TOMB_RESPECT = 80",
      "EVT_REDGUARD_FOREBEAR_ROAD = 81",
      "EVT_REDGUARD_ASHABAH_DEATH_DUTY = 82",
      "EVT_REDGUARD_FAR_SHORES_TOKEN = 83",
      "redguard-crown-tomb-respect",
      "redguard-far-shores-token",
    ]);
    this.checkSourceContains("Phase 20 Redguard EventBus source", "PDV_EventBus", [
      "Function RouteRedguardCrownTombRespect()",
      "Function RouteRedguardForebearRoadPassage()",
      "Function RouteRedguardAshAbahDeathDuty()",
      "Function RouteRedguardFarShoresToken()",
      "PDV_Manager.HandleRedguardCrownTombRespect(\"eventbus_\" + eventType)",
      "PDV_Manager.HandleRedguardFarShoresToken(\"eventbus_\" + eventType)",
    ]);
    this.checkSourceContains("Phase 20 Redguard receiver source", "PDV_EventSignalActivator", [
      "ROUTE_REDGUARD_CROWN_TOMB_RESPECT = 80",
      "ROUTE_REDGUARD_FOREBEAR_ROAD = 81",
      "ROUTE_REDGUARD_ASHABAH_DEATH_DUTY = 82",
      "ROUTE_REDGUARD_FAR_SHORES_TOKEN = 83",
      "PDV_EventBusService.RouteRedguardCrownTombRespect()",
      "PDV_EventBusService.RouteRedguardFarShoresToken()",
    ]);

    const triggerSurfaces = manifest.triggerSurfaces || [];
    if (triggerSurfaces.length >= 4) {
      this.pass("Phase 20 Redguard trigger contract", `${triggerSurfaces.length} trigger surface(s) declared for the first proof slice.`, manifestPath);
    } else {
      this.phase20RaceCostingGap("Phase 20 Redguard trigger contract", `Only ${triggerSurfaces.length} trigger surface(s) declared.`, manifestPath);
    }

    for (const trigger of triggerSurfaces) {
      if (typeof trigger.placementRefEditorId === "string" && trigger.placementRefEditorId.startsWith("PDV_REFR_")) {
        this.pass("Phase 20 Redguard placement contract", `${trigger.editorId} declares CK placement reference ${trigger.placementRefEditorId}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap("Phase 20 Redguard placement contract", `${trigger.editorId || "(missing editorId)"} is missing placementRefEditorId.`, manifestPath);
      }
    }

    if (manifest.implementationStatus === "record-wired" || manifest.implementationStatus === "runtime-proven") {
      this.checkPhase20RedguardRecordReadback(manifest, manifestPath);
    }
  }

  checkPhase20RedguardRecordReadback(manifest, manifestPath) {
    const trackRecord = this.recordsByEdid.get("PDV_StateTrack_RedguardSect");
    if (trackRecord?.type === "QUST") {
      this.pass("Phase 20 Redguard sect record", "PDV_StateTrack_RedguardSect exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Redguard sect record", "PDV_StateTrack_RedguardSect is missing or not a QUST.", PDV_ESP);
    }

    const trackDetail = this.recordDetails.get("PDV_StateTrack_RedguardSect");
    const trackScript = trackDetail ? findScript(trackDetail.fields || {}, "PDV_StateTrack") : null;
    if (trackScript) {
      this.pass("Phase 20 Redguard sect script", "PDV_StateTrack is attached to PDV_StateTrack_RedguardSect.", PDV_ESP);
      const props = propertyMap(trackScript);
      this.checkScalarProperty("Phase 20 Redguard sect property", props, "TrackName", "RedguardSect", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Redguard sect property", props, "StateGlobal", "PDV_GLO_RedguardSect", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Redguard sect property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      const labels = propValue(props.get("StateLabels")) || [];
      const expectedLabels = ["Crown", "Forebear", "AshAbah"];
      if (Array.isArray(labels) && labels.length === expectedLabels.length && labels.every((label, index) => label === expectedLabels[index])) {
        this.pass("Phase 20 Redguard sect property", "StateLabels match the locked Redguard sect enum order.", PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Redguard sect property", `StateLabels are ${JSON.stringify(labels)}, expected ${JSON.stringify(expectedLabels)}.`, PDV_ESP);
      }
    } else {
      this.phase20RaceCostingGap("Phase 20 Redguard sect script", "PDV_StateTrack is not attached to PDV_StateTrack_RedguardSect.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      const props = propertyMap(managerScript);
      this.checkObjectPropertyTarget("Phase 20 Redguard manager property", props, "PDV_RedguardSectTrack", "PDV_StateTrack_RedguardSect", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Redguard manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    for (const trigger of manifest.triggerSurfaces || []) {
      if (!trigger.editorId) {
        continue;
      }

      const record = this.recordsByEdid.get(trigger.editorId);
      if (record?.type === "ACTI") {
        this.pass("Phase 20 Redguard trigger record", `${trigger.editorId} exists as ACTI.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Redguard trigger record", `${trigger.editorId} is missing or not an ACTI.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetails.get(trigger.editorId);
      const script = detail ? findScript(detail.fields || {}, "PDV_EventSignalActivator") : null;
      if (!script) {
        this.phase20RaceCostingGap("Phase 20 Redguard trigger script", `${trigger.editorId} is missing PDV_EventSignalActivator.`, PDV_ESP);
        continue;
      }

      const props = propertyMap(script);
      this.checkScalarProperty("Phase 20 Redguard trigger property", props, "RouteId", trigger.routeId, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Redguard trigger property", props, "RequiredOriginRace", 9, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Redguard trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Redguard trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkPhase20RaceTriggerPlacement("Phase 20 Redguard trigger placement", trigger, manifestPath);
    }
  }

  checkPhase20BosmerSourceScaffold(manifest, manifestPath) {
    this.checkSourceContains("Phase 20 Bosmer manager source", "PDV__ManagerQuest", [
      "ORIGIN_BOSMER = 4",
      "Function HandleBosmerOldContractProperHunt(String reason)",
      "Function HandleBosmerOldContractForestKept(String reason)",
      "Function HandleBosmerLivingStoryCommunityKept(String reason)",
      "Function HandleBosmerLivingStoryNatureSite(String reason)",
      "Function HandleBosmerExchangeDebtSettled(String reason)",
      "Function HandleBosmerExchangeProportionateVengeance(String reason)",
      "Function HandleBosmerBanditRoadRoadLife(String reason)",
      "Function HandleBosmerBanditRoadReversal(String reason)",
      "Bool Function RecordBosmerFavorSignal(String favorKey, Int pathState, String reason)",
      "Bool Function CanRecordBosmerMajorFavor(String favorKey, Float cooldownDays, String reason)",
      "String Function GetBosmerFavorSummary()",
      "\"PDV.Bosmer.Favor.\"",
    ]);
    this.checkSourceContains("Phase 20 Bosmer EventTypes source", "PDV_EventTypes", [
      "EVT_BOSMER_OLD_CONTRACT_PROPER_HUNT = 100",
      "EVT_BOSMER_OLD_CONTRACT_FOREST_KEPT = 101",
      "EVT_BOSMER_LIVING_STORY_COMMUNITY = 102",
      "EVT_BOSMER_EXCHANGE_DEBT_SETTLED = 104",
      "EVT_BOSMER_BANDIT_ROAD_REVERSAL = 107",
      "bosmer-old-contract-proper-hunt",
      "bosmer-living-story-community",
      "bosmer-bandit-road-reversal",
    ]);
    this.checkSourceContains("Phase 20 Bosmer EventBus source", "PDV_EventBus", [
      "Function RouteBosmerOldContractProperHunt()",
      "Function RouteBosmerLivingStoryCommunityKept()",
      "Function RouteBosmerExchangeDebtSettled()",
      "Function RouteBosmerBanditRoadReversal()",
      "PDV_Manager.HandleBosmerOldContractProperHunt(\"eventbus_\" + eventType)",
      "PDV_Manager.HandleBosmerBanditRoadReversal(\"eventbus_\" + eventType)",
    ]);
    this.checkSourceContains("Phase 20 Bosmer receiver source", "PDV_EventSignalActivator", [
      "ROUTE_BOSMER_OLD_CONTRACT_PROPER_HUNT = 100",
      "ROUTE_BOSMER_LIVING_STORY_COMMUNITY = 102",
      "ROUTE_BOSMER_EXCHANGE_DEBT_SETTLED = 104",
      "ROUTE_BOSMER_BANDIT_ROAD_REVERSAL = 107",
      "PDV_EventBusService.RouteBosmerOldContractProperHunt()",
      "PDV_EventBusService.RouteBosmerBanditRoadReversal()",
    ]);

    const triggerSurfaces = manifest.triggerSurfaces || [];
    if (triggerSurfaces.length >= 8) {
      this.pass("Phase 20 Bosmer trigger contract", `${triggerSurfaces.length} trigger surface(s) declared for the non-hunter parity proof slice.`, manifestPath);
    } else {
      this.phase20RaceCostingGap("Phase 20 Bosmer trigger contract", `Only ${triggerSurfaces.length} trigger surface(s) declared.`, manifestPath);
    }

    for (const trigger of triggerSurfaces) {
      if (typeof trigger.placementRefEditorId === "string" && trigger.placementRefEditorId.startsWith("PDV_REFR_")) {
        this.pass("Phase 20 Bosmer placement contract", `${trigger.editorId} declares CK placement reference ${trigger.placementRefEditorId}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap("Phase 20 Bosmer placement contract", `${trigger.editorId || "(missing editorId)"} is missing placementRefEditorId.`, manifestPath);
      }
    }

    if (manifest.implementationStatus === "record-wired" || manifest.implementationStatus === "runtime-proven") {
      this.checkPhase20BosmerRecordReadback(manifest, manifestPath);
    }
  }

  checkPhase20BosmerRecordReadback(manifest, manifestPath) {
    for (const trigger of manifest.triggerSurfaces || []) {
      if (!trigger.editorId) {
        continue;
      }

      const record = this.recordsByEdid.get(trigger.editorId);
      if (record?.type === "ACTI") {
        this.pass("Phase 20 Bosmer trigger record", `${trigger.editorId} exists as ACTI.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Bosmer trigger record", `${trigger.editorId} is missing or not an ACTI.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetails.get(trigger.editorId);
      const script = detail ? findScript(detail.fields || {}, "PDV_EventSignalActivator") : null;
      if (!script) {
        this.phase20RaceCostingGap("Phase 20 Bosmer trigger script", `${trigger.editorId} is missing PDV_EventSignalActivator.`, PDV_ESP);
        continue;
      }

      const props = propertyMap(script);
      this.checkScalarProperty("Phase 20 Bosmer trigger property", props, "RouteId", trigger.routeId, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Bosmer trigger property", props, "RequiredOriginRace", 4, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Bosmer trigger property", props, "SignalValue", trigger.signalValue || 0, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Bosmer trigger property", props, "SignalSourceId", trigger.signalSourceId || "", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Bosmer trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Bosmer trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Bosmer trigger property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      this.checkPhase20RaceTriggerPlacement("Phase 20 Bosmer trigger placement", trigger, manifestPath);
    }
  }

  checkPhase20KhajiitSourceScaffold(manifest, manifestPath) {
    this.checkSourceContains("Phase 20 Khajiit substrate source", "PDV_Substrate_KhajiitLunar", [
      "Scriptname PDV_Substrate_KhajiitLunar extends PDV_SubstrateBase",
      "Function ObserveMoonPhaseScaled(Int phaseIndex, Float multiplier, String reason)",
      "Function RecordRoadHomeCadenceScaled(Float multiplier, String reason)",
      "\"PDV.Substrate.KhajiitLunar.LastPhase\"",
      "\"PDV.Substrate.KhajiitLunar.RoadHomeCount\"",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Phase 20 Khajiit manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_KhajiitLunar Property PDV_KhajiitLunarSubstrate Auto",
      "GlobalVariable Property PDV_GLO_KhajiitFocusedEmphasis Auto",
      "ORIGIN_KHAJIIT = 6",
      "KHAJIIT_FOCUS_BAANDAR = 3",
      "KHAJIIT_FOCUS_RAJHIN = 4",
      "KHAJIIT_FOCUS_ALKOSH = 5",
      "Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)",
      "Function HandleKhajiitRoadHomeAnchor(Int anchorId, String reason)",
      "Function HandleKhajiitBaanDarRoadTrick(String reason)",
      "Function HandleKhajiitRajhinElegantTheft(String reason)",
      "Function HandleKhajiitAlkoshDragonOrder(String reason)",
      "Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)",
      "Bool Function IsKhajiitOrigin()",
      "\"PDV.Khajiit.RoadHome.LastAnchor\"",
      "\"PDV.Khajiit.RoadHome.RepeatRejectCount\"",
      "\"PDV.Signal.KhajiitBaanDarRoadTrick\"",
      "bd=",
    ]);
    this.checkSourceContains("Phase 20 Khajiit EventTypes source", "PDV_EventTypes", [
      "EVT_KHAJIIT_ROAD_HOME = 33",
      "EVT_KHAJIIT_BAANDAR_ROAD_TRICK = 90",
      "EVT_KHAJIIT_RAJHIN_ELEGANT_THEFT = 91",
      "EVT_KHAJIIT_ALKOSH_DRAGON_ORDER = 92",
      "khajiit-road-home",
      "khajiit-baandar-road-trick",
      "khajiit-alkosh-dragon-order",
    ]);
    this.checkSourceContains("Phase 20 Khajiit EventBus source", "PDV_EventBus", [
      "Function RouteKhajiitMoonObservance(Int phaseIndex)",
      "Function RouteKhajiitRoadHomeAnchor(Int anchorId)",
      "Function RouteKhajiitBaanDarRoadTrick(String asSourceId = \"\")",
      "Function RouteKhajiitRajhinElegantTheft(String asSourceId = \"\")",
      "Function RouteKhajiitAlkoshDragonOrder(String asSourceId = \"\")",
      "Function RouteKhajiitBaanDarReversal(String asSourceId = \"\")",
      "Function RouteKhajiitAlkoshGenericDragon(String asSourceId = \"\")",
      "PDV_Manager.HandleKhajiitRoadHomeAnchor(anchorId, \"eventbus_\" + eventType)",
      "PDV_Manager.HandleKhajiitBaanDarRoadTrick(reason)",
      "PDV_Manager.HandleKhajiitRajhinElegantTheft(reason)",
      "PDV_Manager.HandleKhajiitAlkoshDragonOrder(reason)",
      "PDV_Manager.HandleKhajiitBaanDarReversal(reason)",
      "PDV_Manager.HandleKhajiitAlkoshGenericDragon(reason)",
    ]);
    this.checkSourceContains("Phase 20 Khajiit receiver source", "PDV_EventSignalActivator", [
      "ROUTE_KHAJIIT_MOON_OBSERVANCE = 10",
      "ROUTE_KHAJIIT_ROAD_HOME = 33",
      "ROUTE_KHAJIIT_BAANDAR_ROAD_TRICK = 90",
      "ROUTE_KHAJIIT_RAJHIN_ELEGANT_THEFT = 91",
      "ROUTE_KHAJIIT_ALKOSH_DRAGON_ORDER = 92",
      "PDV_EventBusService.RouteKhajiitMoonObservance(SignalValue)",
      "PDV_EventBusService.RouteKhajiitRoadHomeAnchor(SignalValue)",
      "PDV_EventBusService.RouteKhajiitBaanDarRoadTrick()",
      "PDV_EventBusService.RouteKhajiitAlkoshDragonOrder()",
    ]);

    const triggerSurfaces = manifest.triggerSurfaces || [];
    if (triggerSurfaces.length >= 6) {
      this.pass("Phase 20 Khajiit trigger contract", `${triggerSurfaces.length} trigger surface(s) declared for the first proof slice.`, manifestPath);
    } else {
      this.phase20RaceCostingGap("Phase 20 Khajiit trigger contract", `Only ${triggerSurfaces.length} trigger surface(s) declared.`, manifestPath);
    }

    for (const trigger of triggerSurfaces) {
      if (typeof trigger.placementRefEditorId === "string" && trigger.placementRefEditorId.startsWith("PDV_REFR_")) {
        this.pass("Phase 20 Khajiit placement contract", `${trigger.editorId} declares CK placement reference ${trigger.placementRefEditorId}.`, manifestPath);
      } else {
        this.phase20RaceCostingGap("Phase 20 Khajiit placement contract", `${trigger.editorId || "(missing editorId)"} is missing placementRefEditorId.`, manifestPath);
      }
    }

    if (manifest.implementationStatus === "record-wired" || manifest.implementationStatus === "runtime-proven") {
      this.checkPhase20KhajiitRecordReadback(manifest, manifestPath);
    }
  }

  checkPhase20KhajiitRecordReadback(manifest, manifestPath) {
    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_KhajiitLunar");
    if (substrateRecord?.type === "QUST") {
      this.pass("Phase 20 Khajiit lunar substrate record", "PDV_Substrate_KhajiitLunar exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Khajiit lunar substrate record", "PDV_Substrate_KhajiitLunar is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_KhajiitLunar");
    const substrateScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_KhajiitLunar") : null;
    if (substrateScript) {
      this.pass("Phase 20 Khajiit lunar substrate script", "PDV_Substrate_KhajiitLunar is attached to the substrate quest.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Khajiit lunar substrate script", "PDV_Substrate_KhajiitLunar script is not attached.", PDV_ESP);
    }

    const focusGlobal = this.recordsByEdid.get("PDV_GLO_KhajiitFocusedEmphasis");
    if (focusGlobal?.type === "GLOB") {
      this.pass("Phase 20 Khajiit focus mirror", "PDV_GLO_KhajiitFocusedEmphasis exists as GLOB.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Phase 20 Khajiit focus mirror", "PDV_GLO_KhajiitFocusedEmphasis is missing or not a GLOB.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      const props = propertyMap(managerScript);
      this.checkObjectPropertyTarget("Phase 20 Khajiit manager property", props, "PDV_KhajiitLunarSubstrate", "PDV_Substrate_KhajiitLunar", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Khajiit manager property", props, "PDV_GLO_KhajiitFocusedEmphasis", "PDV_GLO_KhajiitFocusedEmphasis", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Phase 20 Khajiit manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    for (const trigger of manifest.triggerSurfaces || []) {
      if (!trigger.editorId) {
        continue;
      }

      const record = this.recordsByEdid.get(trigger.editorId);
      if (record?.type === "ACTI") {
        this.pass("Phase 20 Khajiit trigger record", `${trigger.editorId} exists as ACTI.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Phase 20 Khajiit trigger record", `${trigger.editorId} is missing or not an ACTI.`, PDV_ESP);
        continue;
      }

      const detail = this.recordDetails.get(trigger.editorId);
      const script = detail ? findScript(detail.fields || {}, "PDV_EventSignalActivator") : null;
      if (!script) {
        this.phase20RaceCostingGap("Phase 20 Khajiit trigger script", `${trigger.editorId} is missing PDV_EventSignalActivator.`, PDV_ESP);
        continue;
      }

      const props = propertyMap(script);
      this.checkScalarProperty("Phase 20 Khajiit trigger property", props, "RouteId", trigger.routeId, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Khajiit trigger property", props, "RequiredOriginRace", 6, this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Phase 20 Khajiit trigger property", props, "SignalValue", trigger.signalValue || 0, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Khajiit trigger property", props, "PDV_EventBusService", "PDV_EventBus", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Phase 20 Khajiit trigger property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkPhase20RaceTriggerPlacement("Phase 20 Khajiit trigger placement", trigger, manifestPath);
    }
  }

  checkNordSpineParityBuild() {
    this.checkSourceContains("Nord spine substrate source", "PDV_Substrate_NordAncestor", [
      "Scriptname PDV_Substrate_NordAncestor extends PDV_SubstrateBase",
      "Function RecordAncestorStandingScaled(Float multiplier, String reason)",
      "Function ProcessAncestorDawn(Bool curseActive, String reason)",
      "\"PDV.Substrate.NordAncestor.SourceCount\"",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Nord spine Shor source", "PDV_Deity_Shor", [
      "SIGNAL_ANCESTOR_SPINE = 2903",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Nord spine manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_NordAncestor Property PDV_NordAncestorSubstrate Auto",
      "Function HandleNordAncestorSpine(String reason)",
      "Function RecordNordAncestorSpine(String reason, Float multiplier)",
      "PDV_NordAncestorSubstrate.RecordAncestorStandingScaled(multiplier, reason)",
      "PDV_Shor.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Nord.AncestralStanding\"",
      "Function RunDawnRefreshNordAncestor()",
      "PDV_Notif_Nord_General_AncestorsQuiet",
      "PDV_Notif_Nord_Kyne_ChampionAmbient_Storm",
      "Function SyncNordAncestorSubstrate(Actor playerRef, Bool isNord)",
      "String Function GetNordAncestorSummary()",
    ]);

    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_NordAncestor");
    if (substrateRecord?.type === "QUST") {
      this.pass("Nord spine substrate record", "PDV_Substrate_NordAncestor exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Nord spine substrate record", "PDV_Substrate_NordAncestor is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_NordAncestor");
    const baseScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_SubstrateBase") : null;
    if (baseScript) {
      this.pass("Nord spine substrate base script", "PDV_SubstrateBase is attached.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Nord spine substrate base script", "PDV_SubstrateBase is not attached.", PDV_ESP);
    }

    const concreteScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_NordAncestor") : null;
    if (concreteScript) {
      this.pass("Nord spine substrate script", "PDV_Substrate_NordAncestor is attached.", PDV_ESP);
      const props = propertyMap(concreteScript);
      this.checkScalarProperty("Nord spine substrate property", props, "SubstrateName", "NordAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Nord spine substrate property", props, "RequiredOriginRace", 0, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Nord spine substrate property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Nord spine substrate property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Nord spine substrate property", props, "Substrate_Always", "PDV_Bless_Nord_Substrate_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Nord spine substrate property", props, "Substrate_Mid", "PDV_Bless_Nord_Substrate_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Nord spine substrate property", props, "Substrate_High", "PDV_Bless_Nord_Substrate_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Nord spine substrate script", "PDV_Substrate_NordAncestor is not attached.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      this.checkObjectPropertyTarget("Nord spine manager property", propertyMap(managerScript), "PDV_NordAncestorSubstrate", "PDV_Substrate_NordAncestor", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Nord spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", ["PDV_Substrate_NordAncestor"]);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", ["PDV_Substrate_NordAncestor"]);

    const spellSpecs = [
      {
        spell: "PDV_Bless_Nord_Substrate_Always",
        effects: [
          { effect: "PDV_MGEF_Nord_Substrate_Always_Frost", magnitude: 5, actorValue: "ResistFrost" },
          { effect: "PDV_MGEF_Nord_Substrate_Always_Health", magnitude: 10, actorValue: "Health" },
        ],
      },
      {
        spell: "PDV_Bless_Nord_Substrate_Mid",
        effects: [
          { effect: "PDV_MGEF_Nord_Substrate_Mid_Frost", magnitude: 15, actorValue: "ResistFrost" },
          { effect: "PDV_MGEF_Nord_Substrate_Mid_Health", magnitude: 25, actorValue: "Health" },
        ],
      },
      {
        spell: "PDV_Bless_Nord_Substrate_High",
        effects: [
          { effect: "PDV_MGEF_Nord_Substrate_High_Frost", magnitude: 30, actorValue: "ResistFrost" },
          { effect: "PDV_MGEF_Nord_Substrate_High_Health", magnitude: 50, actorValue: "Health" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkNordSpineSpellPacket(spec);
    }
  }

  checkNordSpineSpellPacket(spec) {
    const record = this.recordsByEdid.get(spec.spell);
    if (record?.type === "SPEL") {
      this.pass("Nord spine boon spell", `${spec.spell} exists as SPEL.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Nord spine boon spell", `${spec.spell} is missing or not a SPEL.`, PDV_ESP);
      return;
    }

    const detail = this.recordDetails.get(spec.spell);
    const effects = Array.isArray(detail?.fields?.Effects) ? detail.fields.Effects : [];
    for (const expected of spec.effects) {
      const effectRecord = this.recordsByEdid.get(expected.effect);
      if (effectRecord?.type === "MGEF") {
        this.pass("Nord spine boon effect", `${expected.effect} exists as MGEF.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Nord spine boon effect", `${expected.effect} is missing or not a MGEF.`, PDV_ESP);
        continue;
      }

      const spellEffect = effects.find((effect) => effect.BaseEffect === effectRecord.formid);
      if (!spellEffect) {
        this.phase20RaceCostingGap("Nord spine boon spell effect", `${spec.spell} is missing ${expected.effect}.`, PDV_ESP);
        continue;
      }
      const data = spellEffect.Data || {};
      if (Math.abs((data.Magnitude || 0) - expected.magnitude) < 0.001 && (data.Duration || 0) === 0) {
        this.pass("Nord spine boon spell effect", `${spec.spell}.${expected.effect} magnitude is ${expected.magnitude}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Nord spine boon spell effect", `${spec.spell}.${expected.effect} data is ${JSON.stringify(data)}, expected magnitude ${expected.magnitude} duration 0.`, PDV_ESP);
      }

      const effectDetail = this.recordDetails.get(expected.effect);
      const actorValue = String(effectDetail?.fields?.Archetype?.ActorValue || effectDetail?.fields?.ActorValue || "");
      if (!actorValue || actorValue.toLowerCase() === expected.actorValue.toLowerCase()) {
        this.pass("Nord spine boon effect actor value", `${expected.effect} actor value is ${expected.actorValue}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Nord spine boon effect actor value", `${expected.effect} actor value is ${actorValue}, expected ${expected.actorValue}.`, PDV_ESP);
      }
    }
  }

  checkDunmerSpineParityBuild() {
    this.checkSourceContains("Dunmer spine Azura source", "PDV_Deity_Azura", [
      "SIGNAL_ANCESTOR_SPINE = 705",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Dunmer spine manager source", "PDV__ManagerQuest", [
      "Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)",
      "PDV_Azura.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Dunmer.AncestorSpine\"",
      "AwardDunmerAncestorSpinePulse(multiplier, reason)",
    ]);

    const substrateDetail = this.recordDetails.get("PDV_Substrate_DunmerAncestor");
    const baseScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_SubstrateBase") : null;
    if (baseScript) {
      this.pass("Dunmer spine substrate base script", "PDV_SubstrateBase is attached.", PDV_ESP);
      const baseProps = propertyMap(baseScript);
      this.checkScalarProperty("Dunmer spine substrate property", baseProps, "SubstrateName", "DunmerAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Dunmer spine substrate property", baseProps, "RequiredOriginRace", 5, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", baseProps, "Substrate_Always", "PDV_Bless_Dunmer_Substrate_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", baseProps, "Substrate_Mid", "PDV_Bless_Dunmer_Substrate_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", baseProps, "Substrate_High", "PDV_Bless_Dunmer_Substrate_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Dunmer spine substrate base script", "PDV_SubstrateBase is not attached to PDV_Substrate_DunmerAncestor.", PDV_ESP);
    }

    const concreteScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_DunmerAncestor") : null;
    if (concreteScript) {
      this.pass("Dunmer spine substrate script", "PDV_Substrate_DunmerAncestor is attached.", PDV_ESP);
      const props = propertyMap(concreteScript);
      this.checkScalarProperty("Dunmer spine substrate property", props, "SubstrateName", "DunmerAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Dunmer spine substrate property", props, "RequiredOriginRace", 5, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", props, "Substrate_Always", "PDV_Bless_Dunmer_Substrate_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", props, "Substrate_Mid", "PDV_Bless_Dunmer_Substrate_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Dunmer spine substrate property", props, "Substrate_High", "PDV_Bless_Dunmer_Substrate_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Dunmer spine substrate script", "PDV_Substrate_DunmerAncestor is not attached.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      this.checkObjectPropertyTarget("Dunmer spine manager property", propertyMap(managerScript), "PDV_DunmerAncestorSubstrate", "PDV_Substrate_DunmerAncestor", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Dunmer spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", ["PDV_Substrate_DunmerAncestor"]);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", ["PDV_Substrate_DunmerAncestor"]);

    const spellSpecs = [
      {
        spell: "PDV_Bless_Dunmer_Substrate_Always",
        effects: [
          { effect: "PDV_MGEF_Dunmer_Substrate_Always_Magic", magnitude: 3, actorValue: "ResistMagic" },
        ],
      },
      {
        spell: "PDV_Bless_Dunmer_Substrate_Mid",
        effects: [
          { effect: "PDV_MGEF_Dunmer_Substrate_Mid_Magic", magnitude: 9, actorValue: "ResistMagic" },
        ],
      },
      {
        spell: "PDV_Bless_Dunmer_Substrate_High",
        effects: [
          { effect: "PDV_MGEF_Dunmer_Substrate_High_Magic", magnitude: 20, actorValue: "ResistMagic" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkDunmerSpineSpellPacket(spec);
    }
  }

  checkDunmerSpineSpellPacket(spec) {
    const record = this.recordsByEdid.get(spec.spell);
    if (record?.type === "SPEL") {
      this.pass("Dunmer spine boon spell", `${spec.spell} exists as SPEL.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Dunmer spine boon spell", `${spec.spell} is missing or not a SPEL.`, PDV_ESP);
      return;
    }

    const detail = this.recordDetails.get(spec.spell);
    const effects = Array.isArray(detail?.fields?.Effects) ? detail.fields.Effects : [];
    for (const expected of spec.effects) {
      const effectRecord = this.recordsByEdid.get(expected.effect);
      if (effectRecord?.type === "MGEF") {
        this.pass("Dunmer spine boon effect", `${expected.effect} exists as MGEF.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Dunmer spine boon effect", `${expected.effect} is missing or not a MGEF.`, PDV_ESP);
        continue;
      }

      const spellEffect = effects.find((effect) => effect.BaseEffect === effectRecord.formid);
      if (!spellEffect) {
        this.phase20RaceCostingGap("Dunmer spine boon spell effect", `${spec.spell} is missing ${expected.effect}.`, PDV_ESP);
        continue;
      }
      const data = spellEffect.Data || {};
      if (Math.abs((data.Magnitude || 0) - expected.magnitude) < 0.001 && (data.Duration || 0) === 0) {
        this.pass("Dunmer spine boon spell effect", `${spec.spell}.${expected.effect} magnitude is ${expected.magnitude}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Dunmer spine boon spell effect", `${spec.spell}.${expected.effect} data is ${JSON.stringify(data)}, expected magnitude ${expected.magnitude} duration 0.`, PDV_ESP);
      }

      const effectDetail = this.recordDetails.get(expected.effect);
      const actorValue = String(effectDetail?.fields?.Archetype?.ActorValue || effectDetail?.fields?.ActorValue || "");
      if (!actorValue || actorValue.toLowerCase() === expected.actorValue.toLowerCase()) {
        this.pass("Dunmer spine boon effect actor value", `${expected.effect} actor value is ${expected.actorValue}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Dunmer spine boon effect actor value", `${expected.effect} actor value is ${actorValue}, expected ${expected.actorValue}.`, PDV_ESP);
      }
    }
  }

  checkOrcSpineParityBuild() {
    this.checkSourceContains("Orc spine Malacath source", "PDV_Deity_Malacath", [
      "SIGNAL_ANCESTOR_SPINE = 2209",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Orc spine manager source", "PDV__ManagerQuest", [
      "Spell Property PDV_Bless_Orc_Spine_City Auto",
      "Spell Property PDV_Bless_Orc_Spine_Stronghold Auto",
      "Spell Property PDV_Bless_Orc_Spine_LegionExile Auto",
      "Function AwardOrcAncestorSpineSignal(Float multiplier, String reason)",
      "PDV_Malacath.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Orc.AncestorSpine\"",
      "AwardOrcAncestorSpineSignal(multiplier, reason)",
      "Function SyncOrcSpineBoon(Actor playerRef, Bool isOrc, Int activeMode)",
      "Function MaybeShowOrcWatchersNotice(Int modeValue, String reason)",
      "PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold",
      "PDV_Notif_Orc_Witnessed_TheWatchers_City",
      "PDV_Notif_Orc_Witnessed_TheWatchers_LegionExile",
      "Function MaybeShowOrcHearthHeldNotice(String reason)",
      "PDV_Notif_Orc_HearthHeld_Declare",
      "PDV_Notif_Orc_HearthHeld_Return",
      "PDV_Notif_Orc_HearthHeld_MissedCadence",
    ]);

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      const props = propertyMap(managerScript);
      this.checkObjectPropertyTarget("Orc spine manager property", props, "PDV_Bless_Orc_Spine_City", "PDV_Bless_Orc_Spine_City", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Orc spine manager property", props, "PDV_Bless_Orc_Spine_Stronghold", "PDV_Bless_Orc_Spine_Stronghold", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Orc spine manager property", props, "PDV_Bless_Orc_Spine_LegionExile", "PDV_Bless_Orc_Spine_LegionExile", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Orc spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    const spellSpecs = [
      {
        spell: "PDV_Bless_Orc_Spine_City",
        effects: [
          { effect: "PDV_MGEF_Orc_Spine_City_Armor", magnitude: 5, actorValue: "DamageResist" },
          { effect: "PDV_MGEF_Orc_Spine_City_Health", magnitude: 10, actorValue: "Health" },
        ],
      },
      {
        spell: "PDV_Bless_Orc_Spine_Stronghold",
        effects: [
          { effect: "PDV_MGEF_Orc_Spine_Stronghold_Armor", magnitude: 8, actorValue: "DamageResist" },
          { effect: "PDV_MGEF_Orc_Spine_Stronghold_Health", magnitude: 10, actorValue: "Health" },
        ],
      },
      {
        spell: "PDV_Bless_Orc_Spine_LegionExile",
        effects: [
          { effect: "PDV_MGEF_Orc_Spine_LegionExile_Armor", magnitude: 5, actorValue: "DamageResist" },
          { effect: "PDV_MGEF_Orc_Spine_LegionExile_Health", magnitude: 15, actorValue: "Health" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkOrcSpineSpellPacket(spec);
    }
  }

  checkOrcSpineSpellPacket(spec) {
    const record = this.recordsByEdid.get(spec.spell);
    if (record?.type === "SPEL") {
      this.pass("Orc spine boon spell", `${spec.spell} exists as SPEL.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Orc spine boon spell", `${spec.spell} is missing or not a SPEL.`, PDV_ESP);
      return;
    }

    const detail = this.recordDetails.get(spec.spell);
    const effects = Array.isArray(detail?.fields?.Effects) ? detail.fields.Effects : [];
    for (const expected of spec.effects) {
      const effectRecord = this.recordsByEdid.get(expected.effect);
      if (effectRecord?.type === "MGEF") {
        this.pass("Orc spine boon effect", `${expected.effect} exists as MGEF.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Orc spine boon effect", `${expected.effect} is missing or not a MGEF.`, PDV_ESP);
        continue;
      }

      const spellEffect = effects.find((effect) => effect.BaseEffect === effectRecord.formid);
      if (!spellEffect) {
        this.phase20RaceCostingGap("Orc spine boon spell effect", `${spec.spell} is missing ${expected.effect}.`, PDV_ESP);
        continue;
      }
      const data = spellEffect.Data || {};
      if (Math.abs((data.Magnitude || 0) - expected.magnitude) < 0.001 && (data.Duration || 0) === 0) {
        this.pass("Orc spine boon spell effect", `${spec.spell}.${expected.effect} magnitude is ${expected.magnitude}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Orc spine boon spell effect", `${spec.spell}.${expected.effect} data is ${JSON.stringify(data)}, expected magnitude ${expected.magnitude} duration 0.`, PDV_ESP);
      }

      const effectDetail = this.recordDetails.get(expected.effect);
      const actorValue = String(effectDetail?.fields?.Archetype?.ActorValue || effectDetail?.fields?.ActorValue || "");
      if (!actorValue || actorValue.toLowerCase() === expected.actorValue.toLowerCase()) {
        this.pass("Orc spine boon effect actor value", `${expected.effect} actor value is ${expected.actorValue}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap("Orc spine boon effect actor value", `${expected.effect} actor value is ${actorValue}, expected ${expected.actorValue}.`, PDV_ESP);
      }
    }
  }

  checkAltmerSpineParityBuild() {
    this.checkSourceContains("Altmer spine Auri-El source", "PDV_Deity_AuriEl", [
      "SIGNAL_ANCESTOR_SPINE = 203",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Altmer spine substrate source", "PDV_Substrate_AltmerAncestor", [
      "Scriptname PDV_Substrate_AltmerAncestor extends PDV_SubstrateBase",
      "Function RecordHeritageStandingScaled(Float multiplier, String reason)",
      "Function ProcessHeritageDawn(Bool curseActive, String reason)",
      "\"PDV.Substrate.AltmerAncestor.SourceCount\"",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Altmer spine manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_AltmerAncestor Property PDV_AltmerAncestorSubstrate Auto",
      "Function AwardAltmerAncestorSpinePulse(Float multiplier, String reason)",
      "PDV_AuriEl.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Altmer.AncestralStanding\"",
      "AwardAltmerAncestorSpinePulse(multiplier, reason)",
      "Function SyncAltmerAncestorSubstrate(Actor playerRef, Bool isAltmer)",
      "Function HandleAltmerSleepEvents(Actor playerRef, String reason)",
      "String Function GetAltmerHeritageLayerLabel()",
    ]);

    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_AltmerAncestor");
    if (substrateRecord?.type === "QUST") {
      this.pass("Altmer spine substrate record", "PDV_Substrate_AltmerAncestor exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Altmer spine substrate record", "PDV_Substrate_AltmerAncestor is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_AltmerAncestor");
    const baseScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_SubstrateBase") : null;
    if (baseScript) {
      this.pass("Altmer spine substrate base script", "PDV_SubstrateBase is attached.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Altmer spine substrate base script", "PDV_SubstrateBase is not attached.", PDV_ESP);
    }

    const concreteScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_AltmerAncestor") : null;
    if (concreteScript) {
      this.pass("Altmer spine substrate script", "PDV_Substrate_AltmerAncestor is attached.", PDV_ESP);
      const props = propertyMap(concreteScript);
      this.checkScalarProperty("Altmer spine substrate property", props, "SubstrateName", "AltmerAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Altmer spine substrate property", props, "RequiredOriginRace", 3, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Altmer spine substrate property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Altmer spine substrate property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Altmer spine substrate property", props, "Substrate_Always", "PDV_Bless_Altmer_Spine_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Altmer spine substrate property", props, "Substrate_Mid", "PDV_Bless_Altmer_Spine_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Altmer spine substrate property", props, "Substrate_High", "PDV_Bless_Altmer_Spine_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Altmer spine substrate script", "PDV_Substrate_AltmerAncestor is not attached.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      this.checkObjectPropertyTarget("Altmer spine manager property", propertyMap(managerScript), "PDV_AltmerAncestorSubstrate", "PDV_Substrate_AltmerAncestor", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Altmer spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", ["PDV_Substrate_AltmerAncestor"]);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", ["PDV_Substrate_AltmerAncestor"]);

    const spellSpecs = [
      {
        spell: "PDV_Bless_Altmer_Spine_Always",
        effects: [
          { effect: "PDV_MGEF_Altmer_Spine_Always_Magicka", magnitude: 10, actorValue: "Magicka" },
        ],
      },
      {
        spell: "PDV_Bless_Altmer_Spine_Mid",
        effects: [
          { effect: "PDV_MGEF_Altmer_Spine_Mid_Magicka", magnitude: 20, actorValue: "Magicka" },
        ],
      },
      {
        spell: "PDV_Bless_Altmer_Spine_High",
        effects: [
          { effect: "PDV_MGEF_Altmer_Spine_High_Magicka", magnitude: 30, actorValue: "Magicka" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkAltmerSpineSpellPacket(spec);
    }
  }

  checkAltmerSpineSpellPacket(spec) {
    const label = spec.raceLabel || "Altmer";
    const record = this.recordsByEdid.get(spec.spell);
    if (record?.type === "SPEL") {
      this.pass(`${label} spine boon spell`, `${spec.spell} exists as SPEL.`, PDV_ESP);
    } else {
      this.phase20RaceCostingGap(`${label} spine boon spell`, `${spec.spell} is missing or not a SPEL.`, PDV_ESP);
      return;
    }

    const detail = this.recordDetails.get(spec.spell);
    const effects = Array.isArray(detail?.fields?.Effects) ? detail.fields.Effects : [];
    for (const expected of spec.effects) {
      const effectRecord = this.recordsByEdid.get(expected.effect);
      if (effectRecord?.type === "MGEF") {
        this.pass(`${label} spine boon effect`, `${expected.effect} exists as MGEF.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap(`${label} spine boon effect`, `${expected.effect} is missing or not a MGEF.`, PDV_ESP);
        continue;
      }

      const spellEffect = effects.find((effect) => effect.BaseEffect === effectRecord.formid);
      if (!spellEffect) {
        this.phase20RaceCostingGap(`${label} spine boon spell effect`, `${spec.spell} is missing ${expected.effect}.`, PDV_ESP);
        continue;
      }
      const data = spellEffect.Data || {};
      if (Math.abs((data.Magnitude || 0) - expected.magnitude) < 0.001 && (data.Duration || 0) === 0) {
        this.pass(`${label} spine boon spell effect`, `${spec.spell}.${expected.effect} magnitude is ${expected.magnitude}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap(`${label} spine boon spell effect`, `${spec.spell}.${expected.effect} data is ${JSON.stringify(data)}, expected magnitude ${expected.magnitude} duration 0.`, PDV_ESP);
      }

      const effectDetail = this.recordDetails.get(expected.effect);
      const actorValue = String(effectDetail?.fields?.Archetype?.ActorValue || effectDetail?.fields?.ActorValue || "");
      if (!actorValue || actorValue.toLowerCase() === expected.actorValue.toLowerCase()) {
        this.pass(`${label} spine boon effect actor value`, `${expected.effect} actor value is ${expected.actorValue}.`, PDV_ESP);
      } else {
        this.phase20RaceCostingGap(`${label} spine boon effect actor value`, `${expected.effect} actor value is ${actorValue}, expected ${expected.actorValue}.`, PDV_ESP);
      }
    }
  }

  checkBretonSpineParityBuild() {
    this.checkSourceContains("Breton spine Magnus source", "PDV_Deity_Magnus", [
      "SIGNAL_ANCESTOR_SPINE = 1807",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Breton spine substrate source", "PDV_Substrate_BretonAncestor", [
      "Scriptname PDV_Substrate_BretonAncestor extends PDV_SubstrateBase",
      "Function RecordAncestralResistanceScaled(Float multiplier, String reason)",
      "Function ProcessAncestralDawn(Bool curseActive, String reason)",
      "\"PDV.Substrate.BretonAncestor.SourceCount\"",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Breton spine manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_BretonAncestor Property PDV_BretonAncestorSubstrate Auto",
      "Function AwardBretonAncestorSpinePulse(Float multiplier, String reason)",
      "PDV_Magnus.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Breton.AncestralStanding\"",
      "AwardBretonAncestorSpinePulse(multiplier, reason)",
      "Function SyncBretonAncestorSubstrate(Actor playerRef, Bool isBreton)",
      "Function HandleBretonSleepEvents(Actor playerRef, String reason)",
      "String Function GetBretonAncestorLayerLabel()",
    ]);

    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_BretonAncestor");
    if (substrateRecord?.type === "QUST") {
      this.pass("Breton spine substrate record", "PDV_Substrate_BretonAncestor exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Breton spine substrate record", "PDV_Substrate_BretonAncestor is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_BretonAncestor");
    const concreteScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_BretonAncestor") : null;
    if (concreteScript) {
      this.pass("Breton spine substrate script", "PDV_Substrate_BretonAncestor is attached.", PDV_ESP);
      const props = propertyMap(concreteScript);
      this.checkScalarProperty("Breton spine substrate property", props, "SubstrateName", "BretonAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Breton spine substrate property", props, "RequiredOriginRace", 2, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Breton spine substrate property", props, "Substrate_Always", "PDV_Bless_Breton_Spine_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Breton spine substrate property", props, "Substrate_Mid", "PDV_Bless_Breton_Spine_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Breton spine substrate property", props, "Substrate_High", "PDV_Bless_Breton_Spine_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Breton spine substrate script", "PDV_Substrate_BretonAncestor is not attached.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      this.checkObjectPropertyTarget("Breton spine manager property", propertyMap(managerScript), "PDV_BretonAncestorSubstrate", "PDV_Substrate_BretonAncestor", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Breton spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", ["PDV_Substrate_BretonAncestor"]);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", ["PDV_Substrate_BretonAncestor"]);

    const spellSpecs = [
      {
        spell: "PDV_Bless_Breton_Spine_Always",
        effects: [
          { effect: "PDV_MGEF_Breton_Spine_Always_ResistMagic", magnitude: 3, actorValue: "ResistMagic" },
        ],
      },
      {
        spell: "PDV_Bless_Breton_Spine_Mid",
        effects: [
          { effect: "PDV_MGEF_Breton_Spine_Mid_ResistMagic", magnitude: 7, actorValue: "ResistMagic" },
        ],
      },
      {
        spell: "PDV_Bless_Breton_Spine_High",
        effects: [
          { effect: "PDV_MGEF_Breton_Spine_High_ResistMagic", magnitude: 12, actorValue: "ResistMagic" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkAltmerSpineSpellPacket({ ...spec, raceLabel: "Breton" });
    }
  }

  checkImperialSpineParityBuild() {
    this.checkSourceContains("Imperial spine Talos source", "PDV_Deity_Talos", [
      "SIGNAL_ANCESTOR_SPINE = 104",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "signalType == SIGNAL_ANCESTOR_SPINE",
      "return DELTA_ANCESTOR_SPINE",
    ]);
    this.checkSourceContains("Imperial spine substrate source", "PDV_Substrate_ImperialAncestor", [
      "Scriptname PDV_Substrate_ImperialAncestor extends PDV_SubstrateBase",
      "Function RecordCivicStandingScaled(Float multiplier, String reason)",
      "Function ProcessCivicDawn(Bool curseActive, String reason)",
      "\"PDV.Substrate.ImperialAncestor.SourceCount\"",
      "String Function GetPilotSummary()",
    ]);
    this.checkSourceContains("Imperial spine manager source", "PDV__ManagerQuest", [
      "PDV_Substrate_ImperialAncestor Property PDV_ImperialAncestorSubstrate Auto",
      "Function AwardImperialAncestorSpinePulse(Float multiplier, String reason)",
      "PDV_Talos.SIGNAL_ANCESTOR_SPINE",
      "\"PDV.Imperial.AncestralStanding\"",
      "AwardImperialAncestorSpinePulse(multiplier, reason)",
      "Function SyncImperialAncestorSubstrate(Actor playerRef, Bool isImperial)",
      "Function HandleImperialSleepEvents(Actor playerRef, String reason)",
      "String Function GetImperialCivicLayerLabel()",
    ]);

    const substrateRecord = this.recordsByEdid.get("PDV_Substrate_ImperialAncestor");
    if (substrateRecord?.type === "QUST") {
      this.pass("Imperial spine substrate record", "PDV_Substrate_ImperialAncestor exists as QUST.", PDV_ESP);
    } else {
      this.phase20RaceCostingGap("Imperial spine substrate record", "PDV_Substrate_ImperialAncestor is missing or not a QUST.", PDV_ESP);
    }

    const substrateDetail = this.recordDetails.get("PDV_Substrate_ImperialAncestor");
    const concreteScript = substrateDetail ? findScript(substrateDetail.fields || {}, "PDV_Substrate_ImperialAncestor") : null;
    if (concreteScript) {
      this.pass("Imperial spine substrate script", "PDV_Substrate_ImperialAncestor is attached.", PDV_ESP);
      const props = propertyMap(concreteScript);
      this.checkScalarProperty("Imperial spine substrate property", props, "SubstrateName", "ImperialAncestor", this.phase20RaceCostingGap.bind(this));
      this.checkScalarProperty("Imperial spine substrate property", props, "RequiredOriginRace", 1, this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Imperial spine substrate property", props, "Substrate_Always", "PDV_Bless_Imperial_Spine_Always", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Imperial spine substrate property", props, "Substrate_Mid", "PDV_Bless_Imperial_Spine_Mid", this.phase20RaceCostingGap.bind(this));
      this.checkObjectPropertyTarget("Imperial spine substrate property", props, "Substrate_High", "PDV_Bless_Imperial_Spine_High", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Imperial spine substrate script", "PDV_Substrate_ImperialAncestor is not attached.", PDV_ESP);
    }

    const managerDetail = this.recordDetails.get("PDV__ManagerQuest");
    const managerScript = managerDetail ? findScript(managerDetail.fields || {}, "PDV__ManagerQuest") : null;
    if (managerScript) {
      this.checkObjectPropertyTarget("Imperial spine manager property", propertyMap(managerScript), "PDV_ImperialAncestorSubstrate", "PDV_Substrate_ImperialAncestor", this.phase20RaceCostingGap.bind(this));
    } else {
      this.phase20RaceCostingGap("Imperial spine manager property", "PDV__ManagerQuest script readback failed.", PDV_ESP);
    }

    this.checkRequiredFormListMembers("PDV_FLST_Substrates_All", ["PDV_Substrate_ImperialAncestor"]);
    this.checkRequiredFormListMembers("PDV_FLST_Substrates_DevOnly", ["PDV_Substrate_ImperialAncestor"]);

    const spellSpecs = [
      {
        spell: "PDV_Bless_Imperial_Spine_Always",
        effects: [
          { effect: "PDV_MGEF_Imperial_Spine_Always_Health", magnitude: 5, actorValue: "Health" },
          { effect: "PDV_MGEF_Imperial_Spine_Always_Stamina", magnitude: 5, actorValue: "Stamina" },
        ],
      },
      {
        spell: "PDV_Bless_Imperial_Spine_Mid",
        effects: [
          { effect: "PDV_MGEF_Imperial_Spine_Mid_Health", magnitude: 10, actorValue: "Health" },
          { effect: "PDV_MGEF_Imperial_Spine_Mid_Stamina", magnitude: 10, actorValue: "Stamina" },
        ],
      },
      {
        spell: "PDV_Bless_Imperial_Spine_High",
        effects: [
          { effect: "PDV_MGEF_Imperial_Spine_High_Health", magnitude: 15, actorValue: "Health" },
          { effect: "PDV_MGEF_Imperial_Spine_High_Stamina", magnitude: 15, actorValue: "Stamina" },
        ],
      },
    ];
    for (const spec of spellSpecs) {
      this.checkAltmerSpineSpellPacket({ ...spec, raceLabel: "Imperial" });
    }
  }

  checkPatternProvingManifest() {
    if (exists(PATTERN_PROVING_MANIFEST)) {
      this.pass("V3 Pattern Proving manifest", "Pattern proving manifest exists.", PATTERN_PROVING_MANIFEST);
    } else {
      this.patternGap("V3 Pattern Proving manifest", "Pattern proving manifest is missing.", PATTERN_PROVING_MANIFEST);
    }
  }

  checkSlice1SignalReceiverManifest() {
    if (exists(SLICE1_SIGNAL_RECEIVER_MANIFEST)) {
      this.pass(
        "V3 Slice 1 signal receiver manifest",
        "Slice 1 signal receiver CK record manifest exists.",
        SLICE1_SIGNAL_RECEIVER_MANIFEST,
      );
    } else {
      this.patternGap(
        "V3 Slice 1 signal receiver manifest",
        "Slice 1 signal receiver CK record manifest is missing.",
        SLICE1_SIGNAL_RECEIVER_MANIFEST,
      );
    }
  }

  checkPhase7SignalReceiverManifest() {
    if (exists(PHASE7_SIGNAL_RECEIVER_MANIFEST)) {
      this.pass(
        "Phase 7 signal receiver manifest",
        "Phase 7 signal receiver CK record manifest exists.",
        PHASE7_SIGNAL_RECEIVER_MANIFEST,
      );
    } else {
      this.phase7Gap(
        "Phase 7 signal receiver manifest",
        "Phase 7 signal receiver CK record manifest is missing.",
        PHASE7_SIGNAL_RECEIVER_MANIFEST,
      );
    }
  }

  checkPhase8Manifest() {
    if (exists(PHASE8_CONCORDAT_TALOS_MANIFEST)) {
      this.pass(
        "Phase 8 manifest",
        "Phase 8 Concordat/Talos property manifest exists.",
        PHASE8_CONCORDAT_TALOS_MANIFEST,
      );
    } else {
      this.phase8Gap(
        "Phase 8 manifest",
        "Phase 8 Concordat/Talos property manifest is missing.",
        PHASE8_CONCORDAT_TALOS_MANIFEST,
      );
    }
  }

  checkPhase9Manifest() {
    if (exists(PHASE9_BOSMER_STATE_MANIFEST)) {
      this.pass(
        "Phase 9 manifest",
        "Phase 9 Bosmer state/property manifest exists.",
        PHASE9_BOSMER_STATE_MANIFEST,
      );
    } else {
      this.phase9Gap(
        "Phase 9 manifest",
        "Phase 9 Bosmer state/property manifest is missing.",
        PHASE9_BOSMER_STATE_MANIFEST,
      );
    }
  }

  checkPhase9Records() {
    for (const [edid, expectedType] of Object.entries(PHASE9_RECORDS)) {
      const record = this.recordsByEdid.get(edid);
      if (!record) {
        this.phase9Gap("Phase 9 record", `${expectedType} record ${edid} is not in the framework ESP yet; CK/xEdit creation or wiring remains pending.`, PDV_ESP);
        continue;
      }
      if (record.type !== expectedType) {
        this.fail("Phase 9 record", `${edid} has type ${record.type}, expected ${expectedType}.`, PDV_ESP);
      } else {
        this.pass("Phase 9 record", `${edid} exists as ${expectedType}.`, PDV_ESP);
      }
    }
  }

  checkPatternManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    for (const [propName, expectedEdid] of Object.entries(MANAGER_PATTERN_PROPERTIES)) {
      this.checkObjectPropertyTarget("V3 Pattern Proving manager property", props, propName, expectedEdid, this.patternGap.bind(this));
    }
  }

  checkPatternMcmRecord() {
    const detail = this.recordDetails.get("PDV_MCM");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_MCM");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    for (const [propName, expectedEdid] of Object.entries(MCM_PATTERN_PROPERTIES)) {
      this.checkObjectPropertyTarget("V3 Pattern Proving MCM property", props, propName, expectedEdid, this.patternGap.bind(this));
    }
  }

  checkPhase8ManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Phase 8 manager property", props, "PDV_ConcordatStandingTrack", "PDV_RepTrack_ConcordatStanding", this.phase8Gap.bind(this));
  }

  checkPhase9ManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    for (const [propName, expectedEdid] of Object.entries(PHASE9_MANAGER_PROPERTIES)) {
      this.checkObjectPropertyTarget("Phase 9 manager property", props, propName, expectedEdid, this.phase9Gap.bind(this));
    }
  }

  checkPhase9BosmerTrackRecord() {
    const detail = this.recordDetails.get("PDV_StateTrack_BosmerPath");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_StateTrack");
    if (!script) {
      this.phase9Gap("Phase 9 Bosmer track", "PDV_StateTrack is not attached to PDV_StateTrack_BosmerPath.", PDV_ESP);
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Phase 9 Bosmer track property", props, "StateGlobal", "PDV_GLO_BosmerPath", this.phase9Gap.bind(this));
    this.checkRequiredArrayLength(
      "Phase 9 Bosmer track property",
      "PDV_StateTrack_BosmerPath",
      "StateLabels",
      extractStringArrayProperty(props.get("StateLabels")),
      4,
      this.phase9Gap.bind(this),
    );
  }

  checkPhase9DeityRecord(recordEdid, scriptName, expectedData) {
    const detail = this.recordDetails.get(recordEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, scriptName);
    if (!script) {
      this.phase9Gap("Phase 9 deity script", `${scriptName} is not attached to ${recordEdid}.`, PDV_ESP);
      return;
    }

    this.pass("Phase 9 deity script", `${scriptName} is attached to ${recordEdid}.`, PDV_ESP);
    const props = propertyMap(script);
    for (const [propName, expected] of Object.entries(expectedData)) {
      const actual = propValue(props.get(propName));
      if (valuesEqual(actual, expected)) {
        this.pass("Phase 9 deity property", `${recordEdid}.${propName} = ${JSON.stringify(expected)}.`, PDV_ESP);
      } else {
        this.phase9Gap("Phase 9 deity property", `${recordEdid}.${propName} is ${JSON.stringify(actual)}, expected ${JSON.stringify(expected)}.`, PDV_ESP);
      }
    }

    this.checkObjectPropertyTarget("Phase 9 deity property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase9Gap.bind(this));
    this.checkObjectPropertyTarget("Phase 9 deity property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase9Gap.bind(this));
    this.checkObjectPropertyTarget("Phase 9 deity property", props, "EligibleStateTrack", "PDV_StateTrack_BosmerPath", this.phase9Gap.bind(this));
  }

  checkPhase9SignalReceiverRecords() {
    for (const definition of PHASE9_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      const detail = this.recordDetails.get(definition.recordEdid);
      if (!record || !detail) {
        this.phase9Gap(
          "Phase 9 signal receiver record",
          `${definition.recordEdid} is not present yet; manual CK/xEdit Bosmer proof-surface creation remains pending.`,
          PDV_ESP,
        );
        continue;
      }

      if (record.type !== definition.recordType) {
        this.fail(
          "Phase 9 signal receiver record",
          `${definition.recordEdid} has type ${record.type}, expected ${definition.recordType}.`,
          PDV_ESP,
        );
        continue;
      }

      this.pass("Phase 9 signal receiver record", `${definition.recordEdid} exists as ${definition.recordType}.`, PDV_ESP);
      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.phase9Gap("Phase 9 signal receiver script", `${definition.scriptName} is not attached to ${definition.recordEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("Phase 9 signal receiver script", `${definition.scriptName} is attached to ${definition.recordEdid}.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("Phase 9 signal receiver property", props, "PDV_EventBusService", "PDV_EventBus", this.phase9Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 9 signal receiver property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase9Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 9 signal receiver property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase9Gap.bind(this));
      this.checkScalarProperty("Phase 9 signal receiver property", props, "RouteId", definition.routeId, this.phase9Gap.bind(this));
      this.checkScalarProperty("Phase 9 signal receiver property", props, "RequiredOriginRace", definition.requiredOriginRace, this.phase9Gap.bind(this));
    }

    for (const definition of PHASE9_RETIRED_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      if (record) {
        this.fail(
          "Phase 9 retired signal receiver",
          `${definition.recordEdid} exists as ${record.type}; ${definition.reason}.`,
          PDV_ESP,
        );
      } else {
        this.pass(
          "Phase 9 retired signal receiver",
          `${definition.recordEdid} is absent from the active Devotion record set.`,
          PDV_ESP,
        );
      }
    }
  }

  checkPhase10DunmerSubstrateRecord() {
    const detail = this.recordDetails.get("PDV_Substrate_DunmerAncestor");
    if (!detail) {
      this.phase10Gap(
        "Phase 10 Dunmer substrate record",
        "PDV_Substrate_DunmerAncestor is missing; Phase 10 substrate graduation cannot be verified.",
        PDV_ESP,
      );
      return;
    }

    const baseScript = findScript(detail.fields || {}, "PDV_SubstrateBase");
    if (!baseScript) {
      this.phase10Gap(
        "Phase 10 Dunmer substrate script",
        "PDV_SubstrateBase is not attached to PDV_Substrate_DunmerAncestor.",
        PDV_ESP,
      );
    } else {
      this.pass("Phase 10 Dunmer substrate script", "PDV_SubstrateBase is attached to PDV_Substrate_DunmerAncestor.", PDV_ESP);
      const baseProps = propertyMap(baseScript);
      this.checkScalarProperty("Phase 10 Dunmer substrate property", baseProps, "SubstrateName", "DunmerAncestor", this.phase10Gap.bind(this));
      this.checkScalarProperty("Phase 10 Dunmer substrate property", baseProps, "RequiredOriginRace", 5, this.phase10Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 10 Dunmer substrate property", baseProps, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase10Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 10 Dunmer substrate property", baseProps, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase10Gap.bind(this));
    }

    const pilotScript = findScript(detail.fields || {}, "PDV_Substrate_DunmerAncestor");
    if (!pilotScript) {
      this.phase10Gap(
        "Phase 10 Dunmer substrate pilot script",
        "PDV_Substrate_DunmerAncestor is not attached to PDV_Substrate_DunmerAncestor.",
        PDV_ESP,
      );
    } else {
      this.pass("Phase 10 Dunmer substrate pilot script", "PDV_Substrate_DunmerAncestor is attached to PDV_Substrate_DunmerAncestor.", PDV_ESP);
    }
  }

  checkPhase10ManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget(
      "Phase 10 manager property",
      props,
      "PDV_DunmerAncestorSubstrate",
      "PDV_Substrate_DunmerAncestor",
      this.phase10Gap.bind(this),
    );
  }

  checkPhase10SignalReceiverRecords() {
    for (const definition of PHASE10_DUNMER_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      const detail = this.recordDetails.get(definition.recordEdid);
      if (!record || !detail) {
        this.phase10Gap(
          "Phase 10 Dunmer signal receiver record",
          `${definition.recordEdid} is missing; Phase 10 should reuse the existing Slice 1 Dunmer proof surface.`,
          PDV_ESP,
        );
        continue;
      }

      if (record.type !== definition.recordType) {
        this.fail(
          "Phase 10 Dunmer signal receiver record",
          `${definition.recordEdid} has type ${record.type}, expected ${definition.recordType}.`,
          PDV_ESP,
        );
        continue;
      }

      this.pass("Phase 10 Dunmer signal receiver record", `${definition.recordEdid} exists as ${definition.recordType}.`, PDV_ESP);
      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.phase10Gap("Phase 10 Dunmer signal receiver script", `${definition.scriptName} is not attached to ${definition.recordEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("Phase 10 Dunmer signal receiver script", `${definition.scriptName} is attached to ${definition.recordEdid}.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("Phase 10 Dunmer signal receiver property", props, "PDV_EventBusService", "PDV_EventBus", this.phase10Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 10 Dunmer signal receiver property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase10Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 10 Dunmer signal receiver property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase10Gap.bind(this));
      this.checkScalarProperty("Phase 10 Dunmer signal receiver property", props, "RouteId", definition.routeId, this.phase10Gap.bind(this));
      this.checkScalarProperty("Phase 10 Dunmer signal receiver property", props, "RequiredOriginRace", definition.requiredOriginRace, this.phase10Gap.bind(this));
      this.checkScalarProperty("Phase 10 Dunmer signal receiver property", props, "OncePerDayKey", definition.expectedOncePerDayKey, this.phase10Gap.bind(this));
    }

    const keys = PHASE10_DUNMER_SIGNAL_RECEIVER_DEFINITIONS
      .map((definition) => {
        const detail = this.recordDetails.get(definition.recordEdid);
        const script = detail ? findScript(detail.fields || {}, definition.scriptName) : null;
        const prop = script ? propertyMap(script).get("OncePerDayKey") : null;
        return prop ? propValue(prop) : null;
      })
      .filter(Boolean);
    if (keys.length === 2 && keys[0] !== keys[1]) {
      this.pass("Phase 10 Dunmer signal receiver property", "Portable and private shrine OncePerDayKey values are distinct.", PDV_ESP);
    } else {
      this.phase10Gap("Phase 10 Dunmer signal receiver property", "Portable and private shrine OncePerDayKey values must be distinct.", PDV_ESP);
    }
  }

  checkKhajiitFocusedEmphasisRecord() {
    const record = this.recordsByEdid.get(KHAJIIT_FOCUSED_EMPHASIS_GLOBAL);
    if (record?.type === "GLOB") {
      this.pass("Khajiit focused-emphasis global", `${KHAJIIT_FOCUSED_EMPHASIS_GLOBAL} exists as GLOB.`, PDV_ESP);
    } else {
      this.khajiitGap(
        "Khajiit focused-emphasis global",
        `${KHAJIIT_FOCUSED_EMPHASIS_GLOBAL} is missing; Khajiit focus needs CK-readable mirror readback.`,
        PDV_ESP,
      );
    }
  }

  checkKhajiitManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget(
      "Khajiit focused-emphasis manager property",
      props,
      "PDV_GLO_KhajiitFocusedEmphasis",
      KHAJIIT_FOCUSED_EMPHASIS_GLOBAL,
      this.khajiitGap.bind(this),
    );
  }

  checkCommitmentManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Commitment manager property", props, "PDV_Kyne", "PDV_Deity_Kyne", this.commitmentGap.bind(this));
    this.checkObjectPropertyTarget("Commitment manager property", props, "PDV_GLO_PatronState", "PDV_GLO_PatronState", this.commitmentGap.bind(this));
  }

  checkNeglectDecayManagerRecord() {
    const magicEffect = this.recordsByEdid.get(KYNE_NEGLECT_MAGIC_EFFECT);
    if (magicEffect?.type === "MGEF") {
      this.pass("Neglect/decay Kyne magic effect", `${KYNE_NEGLECT_MAGIC_EFFECT} exists as MGEF.`, PDV_ESP);
    } else {
      this.neglectDecayGap(
        "Neglect/decay Kyne magic effect",
        `${KYNE_NEGLECT_MAGIC_EFFECT} is missing; Slice 7 needs a real magic-effect surface.`,
        PDV_ESP,
      );
    }

    const spell = this.recordsByEdid.get(KYNE_NEGLECT_SPELL);
    if (spell?.type === "SPEL") {
      this.pass("Neglect/decay Kyne spell", `${KYNE_NEGLECT_SPELL} exists as SPEL.`, PDV_ESP);
    } else {
      this.neglectDecayGap(
        "Neglect/decay Kyne spell",
        `${KYNE_NEGLECT_SPELL} is missing; Slice 7 needs a real spell apply/remove surface.`,
        PDV_ESP,
      );
    }

    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV__ManagerQuest");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Neglect/decay manager property", props, "PDV_SPEL_Neglect_Kyne", KYNE_NEGLECT_SPELL, this.neglectDecayGap.bind(this));
  }

  checkPhase11PrivilegePilotManifest() {
    if (!exists(PHASE11_PRIVILEGE_PILOT_MANIFEST)) {
      this.phase11Gap(
        "Phase 11 privilege pilot manifest",
        "Phase 11 privilege pilot prep manifest is missing.",
        PHASE11_PRIVILEGE_PILOT_MANIFEST,
      );
      return null;
    }

    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(PHASE11_PRIVILEGE_PILOT_MANIFEST, "utf8"));
    } catch (error) {
      this.fail("Phase 11 privilege pilot manifest", `Manifest could not be parsed: ${error.message}`, PHASE11_PRIVILEGE_PILOT_MANIFEST);
      return null;
    }

    const gate = parsed.pilot?.gate || {};
    const expectedGate = {
      originRace: "Nord",
      activeDeityIndex: "Kyne",
      minimumActiveTier: 3,
    };
    if (
      parsed.id === "phase11-privilege-pilot"
      && parsed.pilot?.name === "Arngeir Kynareth recognition"
      && gate.originRace === expectedGate.originRace
      && gate.activeDeityIndex === expectedGate.activeDeityIndex
      && gate.minimumActiveTier === expectedGate.minimumActiveTier
      && ["prep-only", "live-dialogue-authored"].includes(parsed.implementationStatus)
    ) {
      this.pass(
        "Phase 11 privilege pilot manifest",
        `D-10 manifest locks the Arngeir/Kynareth gate with status ${parsed.implementationStatus}.`,
        PHASE11_PRIVILEGE_PILOT_MANIFEST,
      );
    } else {
      this.phase11Gap(
        "Phase 11 privilege pilot manifest",
        "Manifest does not match the locked D-10 Arngeir/Kynareth prep-only contract.",
        PHASE11_PRIVILEGE_PILOT_MANIFEST,
      );
    }
    return parsed;
  }

  checkPhase11ArngeirDialogueRecords() {
    const branchRecord = this.recordsByEdid.get(PHASE11_ARNGEIR_BRANCH);
    const topicRecord = this.recordsByEdid.get(PHASE11_ARNGEIR_TOPIC);
    const topic = this.recordDetails.get(PHASE11_ARNGEIR_TOPIC)?.fields || {};
    const infoCandidate = this.resolvePhase11ArngeirInfo(topic);
    const infoRecord = infoCandidate?.record || this.recordsByEdid.get(PHASE11_ARNGEIR_INFO);

    if (branchRecord?.type === "DLBR") {
      this.pass("Phase 11 Arngeir dialogue record", `${PHASE11_ARNGEIR_BRANCH} exists as DLBR.`, PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue record", `${PHASE11_ARNGEIR_BRANCH} is missing or not a DLBR.`, PDV_ESP);
    }

    if (topicRecord?.type === "DIAL") {
      this.pass("Phase 11 Arngeir dialogue record", `${PHASE11_ARNGEIR_TOPIC} exists as DIAL.`, PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue record", `${PHASE11_ARNGEIR_TOPIC} is missing or not a DIAL.`, PDV_ESP);
    }

    if (infoRecord?.type === "INFO") {
      const label = infoRecord.edid || infoRecord.formid || PHASE11_ARNGEIR_INFO;
      this.pass("Phase 11 Arngeir dialogue record", `${label} exists as INFO.`, PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue record", `${PHASE11_ARNGEIR_INFO} is missing or not an INFO.`, PDV_ESP);
    }

    const branch = this.recordDetails.get(PHASE11_ARNGEIR_BRANCH)?.fields || {};
    if (branch.Quest === this.recordsByEdid.get("PDV__ManagerQuest")?.formid) {
      this.pass("Phase 11 Arngeir dialogue branch", "Branch is owned by PDV__ManagerQuest.", PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue branch", "Branch is not owned by PDV__ManagerQuest.", PDV_ESP);
    }
    if (branch.Category === "Player" && branch.Flags === "TopLevel" && branch.StartingTopic === topicRecord?.formid) {
      this.pass("Phase 11 Arngeir dialogue branch", "Branch is a player top-level branch pointing at the PDV topic.", PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue branch", "Branch category/flags/starting topic do not match the PDV top-level contract.", PDV_ESP);
    }

    if (topic.Quest === this.recordsByEdid.get("PDV__ManagerQuest")?.formid && topic.Branch === branchRecord?.formid) {
      this.pass("Phase 11 Arngeir dialogue topic", "Topic is owned by PDV__ManagerQuest and linked to the PDV branch.", PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue topic", "Topic quest/branch links do not match the PDV branch contract.", PDV_ESP);
    }
    if (topic.Name === PHASE11_ARNGEIR_PROMPT && topic.Category === "Topic" && topic.Subtype === "Custom") {
      this.pass("Phase 11 Arngeir dialogue topic", `Topic prompt is "${PHASE11_ARNGEIR_PROMPT}".`, PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue topic", "Topic prompt/category/subtype do not match the contract.", PDV_ESP);
    }

    const info = infoCandidate?.fields || {};
    this.checkPhase11ArngeirInfo(info, infoRecord?.formid, topicRecord?.formid, infoCandidate?.source);
  }

  resolvePhase11ArngeirInfo(topic) {
    const namedInfoRecord = this.recordsByEdid.get(PHASE11_ARNGEIR_INFO);
    const namedInfo = namedInfoRecord ? this.recordDetailsByFormid.get(namedInfoRecord.formid)?.fields : null;
    if (namedInfo) {
      return { record: namedInfoRecord, fields: namedInfo, source: "named INFO EditorID" };
    }

    const topicResponses = Array.isArray(topic.Responses) ? topic.Responses : [];
    const topicInfo = topicResponses.find((candidate) =>
      candidate?.Prompt === PHASE11_ARNGEIR_PROMPT
      && candidate?.Speaker === PHASE11_ARNGEIR_NPC_FORMID
      && candidate?.Responses?.[0]?.Text === PHASE11_ARNGEIR_LINE);
    const unnamedInfoRecord = [...this.recordsByFormid.values()].find((record) => {
      if (record.type !== "INFO" || record.edid) {
        return false;
      }
      const detail = this.recordDetailsByFormid.get(record.formid)?.fields || {};
      return detail.Prompt === PHASE11_ARNGEIR_PROMPT
        && detail.Speaker === PHASE11_ARNGEIR_NPC_FORMID
        && detail.Responses?.[0]?.Text === PHASE11_ARNGEIR_LINE;
    });

    if (topicInfo || unnamedInfoRecord) {
      return {
        record: unnamedInfoRecord || { type: "INFO", formid: null },
        fields: topicInfo || this.recordDetailsByFormid.get(unnamedInfoRecord.formid)?.fields || {},
        source: unnamedInfoRecord ? "CK-authored unnamed INFO" : "topic embedded INFO payload",
      };
    }

    return null;
  }

  isAllowedUnnamedRecord(record) {
    const recordType = String(record?.type || "").toUpperCase();
    if (recordType !== "INFO") {
      return false;
    }

    if (record?.formid === PHASE11_ARNGEIR_INFO_FORMID) {
      return true;
    }

    return this.strictPhase11 || this.strictPhase18 || this.strictPhase19 || this.strictNord;
  }

  checkPhase11ArngeirInfo(info, infoFormid, topicFormid, source = "INFO") {
    if (!info || !Object.keys(info).length) {
      this.phase11Gap("Phase 11 Arngeir dialogue info", "INFO detail readback is missing.", PDV_ESP);
      return;
    }

    const topicMatches = !info.Topic || info.Topic === topicFormid;
    if (topicMatches && info.Speaker === PHASE11_ARNGEIR_NPC_FORMID && info.Prompt === PHASE11_ARNGEIR_PROMPT) {
      this.pass("Phase 11 Arngeir dialogue info", `INFO is tied to the PDV topic, Arngeir speaker, and expected prompt (${source}).`, PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue info", "INFO topic/speaker/prompt readback does not match the Arngeir contract.", PDV_ESP);
    }

    const responseLine = info.Responses?.[0]?.Text;
    if (responseLine === PHASE11_ARNGEIR_LINE) {
      this.pass("Phase 11 Arngeir dialogue info", "INFO response line matches the locked recognition text.", PDV_ESP);
    } else {
      this.phase11Gap("Phase 11 Arngeir dialogue info", `INFO response line is ${JSON.stringify(responseLine)}, expected ${JSON.stringify(PHASE11_ARNGEIR_LINE)}.`, PDV_ESP);
    }

    const conditions = Array.isArray(info.Conditions) ? info.Conditions : [];
    const hasArngeirCondition = conditions.some((condition) =>
      condition.CompareOperator === "EqualTo"
      && condition.ComparisonValue === 1
      && condition.Data?.Object?.Link === PHASE11_ARNGEIR_NPC_FORMID);
    const hasOriginCondition = this.hasGlobalCondition(conditions, "PDV_GLO_OriginRace", "EqualTo", 0);
    const hasDeityCondition = this.hasGlobalCondition(conditions, "PDV_GLO_ActiveDeityIndex", "EqualTo", 0);
    const hasTierCondition = this.hasGlobalCondition(conditions, "PDV_GLO_ActiveTier", "GreaterThanOrEqualTo", 3);

    if (hasArngeirCondition && hasOriginCondition && hasDeityCondition && hasTierCondition) {
      this.pass("Phase 11 Arngeir dialogue conditions", "INFO gates on Arngeir, Nord origin, active Kyne, and Champion tier.", PDV_ESP);
    } else {
      this.phase11Gap(
        "Phase 11 Arngeir dialogue conditions",
        `Condition readback missing expected gates: Arngeir=${hasArngeirCondition}, Origin=${hasOriginCondition}, Deity=${hasDeityCondition}, Tier=${hasTierCondition}.`,
        PDV_ESP,
      );
    }
  }

  hasGlobalCondition(conditions, globalEdid, compareOperator, comparisonValue) {
    const globalFormid = this.recordsByEdid.get(globalEdid)?.formid;
    return conditions.some((condition) =>
      condition.CompareOperator === compareOperator
      && condition.ComparisonValue === comparisonValue
      && condition.Data?.Global?.Link === globalFormid);
  }

  hasSpeakerGate(info, speakerFormid) {
    if (info?.Speaker === speakerFormid) {
      return true;
    }

    const conditions = Array.isArray(info?.Conditions) ? info.Conditions : [];
    return conditions.some((condition) =>
      condition.CompareOperator === "EqualTo"
      && condition.ComparisonValue === 1
      && condition.Data?.Object?.Link === speakerFormid);
  }

  checkPhase8ConcordatTrackRecord() {
    const detail = this.recordDetails.get("PDV_RepTrack_ConcordatStanding");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_ReputationTrack");
    if (!script) {
      this.phase8Gap("Phase 8 Concordat track", "PDV_ReputationTrack is not attached to PDV_RepTrack_ConcordatStanding.", PDV_ESP);
      return;
    }

    const props = propertyMap(script);
    this.checkObjectPropertyTarget("Phase 8 Concordat track property", props, "StorageBacking", "PDV_GLO_ConcordatStanding", this.phase8Gap.bind(this));
    this.checkRequiredArrayLength(
      "Phase 8 Concordat track property",
      "PDV_RepTrack_ConcordatStanding",
      "ThresholdValues",
      extractNumericArrayProperty(props.get("ThresholdValues")),
      4,
      this.phase8Gap.bind(this),
    );
    this.checkRequiredArrayLength(
      "Phase 8 Concordat track property",
      "PDV_RepTrack_ConcordatStanding",
      "ThresholdLabels",
      extractStringArrayProperty(props.get("ThresholdLabels")),
      5,
      this.phase8Gap.bind(this),
    );
  }

  checkPhase8TalosRecord() {
    const detail = this.recordDetails.get("PDV_Deity_Talos");
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, "PDV_Deity_Talos");
    if (!script) {
      return;
    }

    const props = propertyMap(script);
    const overlayContext = this.getActiveOverlayScriptContext(
      PHASE8_CONCORDAT_TALOS_OVERLAY_PATCH,
      "PDV_Deity_Talos",
      "PDV_Deity_Talos",
      "Phase 8 overlay",
    );
    const managerSource = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
    const managerText = exists(managerSource) ? fs.readFileSync(managerSource, "utf8") : "";
    const hasRuntimeWiring = managerText.includes("Function EnsurePhase8RuntimeWiring()")
      && managerText.includes("PDV_Talos.GainModifyingTrack = PDV_ConcordatStandingTrack")
      && managerText.includes("PDV_Talos.DecayModifyingTrack = PDV_ConcordatStandingTrack");
    this.checkObjectPropertyTargetWithOverlay("Phase 8 Talos property", props, "GainModifyingTrack", "PDV_RepTrack_ConcordatStanding", overlayContext, this.phase8Gap.bind(this), hasRuntimeWiring);
    this.checkObjectPropertyTargetWithOverlay("Phase 8 Talos property", props, "DecayModifyingTrack", "PDV_RepTrack_ConcordatStanding", overlayContext, this.phase8Gap.bind(this), hasRuntimeWiring);

    const gainMultipliers = extractNumericArrayProperty(props.get("GainMultiplierPerTrackState"));
    if (gainMultipliers.length === 5) {
      this.pass("Phase 8 Talos property", "GainMultiplierPerTrackState exposes 5 entries.", PDV_ESP);
    } else {
      this.checkSourceContains("Phase 8 Talos source fallback", "PDV_DeityBase", [
        "DeityName == \"Talos\" && track.TrackName == \"ConcordatStanding\"",
        "if stateIndex == 0",
        "return 1.5",
        "elseIf stateIndex >= 4",
        "return 0.5",
      ], this.phase8Gap.bind(this));
    }

    const decayMultipliers = extractNumericArrayProperty(props.get("DecayMultiplierPerTrackState"));
    if (decayMultipliers.length === 5) {
      this.pass("Phase 8 Talos property", "DecayMultiplierPerTrackState exposes 5 entries.", PDV_ESP);
    } else {
      this.checkSourceContains("Phase 8 Talos source fallback", "PDV_DeityBase", [
        "elseIf stateIndex == 3",
        "return 1.25",
        "elseIf stateIndex >= 4",
        "return 1.5",
      ], this.phase8Gap.bind(this));
    }
  }

  getActiveOverlayScriptContext(overlayPatchName, editorId, scriptName, checkName) {
    const overlayPath = path.join(DEVOTION_MOD, overlayPatchName);
    if (!exists(overlayPath) || !exists(DEV_PROFILE_PLUGINS)) {
      return null;
    }

    const overlayLine = readLines(DEV_PROFILE_PLUGINS)
      .find((line) => line.replace(/^\*/, "").toLowerCase() === overlayPatchName.toLowerCase());
    if (overlayLine !== `*${overlayPatchName}`) {
      return null;
    }

    let overlayInventory;
    try {
      overlayInventory = this.scanPlugin(overlayPath);
    } catch (error) {
      this.phase8Gap(checkName, `${overlayPatchName} scan failed: ${error.message}`, overlayPath);
      return null;
    }

    const overlayRecord = overlayInventory.recordsByEdid.get(editorId);
    if (!overlayRecord) {
      this.phase8Gap(checkName, `${overlayPatchName} does not override ${editorId}.`, overlayPath);
      return null;
    }

    let overlayDetail;
    try {
      overlayDetail = this.readPluginRecordDetail(overlayPath, overlayRecord.formid);
    } catch (error) {
      this.phase8Gap(checkName, `${overlayPatchName} detail read failed: ${error.message}`, overlayPath);
      return null;
    }

    const overlayScript = findScript(overlayDetail.fields || {}, scriptName);
    if (!overlayScript) {
      this.phase8Gap(checkName, `${scriptName} is missing from ${overlayPatchName}.`, overlayPath);
      return null;
    }

    const combinedRecordsByEdid = new Map(this.recordsByEdid);
    for (const [edid, record] of overlayInventory.recordsByEdid.entries()) {
      combinedRecordsByEdid.set(edid, record);
    }

    return {
      path: overlayPath,
      props: propertyMap(overlayScript),
      recordsByEdid: combinedRecordsByEdid,
    };
  }

  checkObjectPropertyTargetWithOverlay(checkName, baseProps, propName, expectedEdid, overlayContext, gapFn, allowRuntimeFallback = false) {
    const baseProp = baseProps.get(propName);
    if (baseProp) {
      const baseEdid = objectEdid(baseProp, this.recordsByEdid);
      if (baseEdid === expectedEdid) {
        this.pass(checkName, `${propName} points at ${expectedEdid}.`, PDV_ESP);
        return;
      }
    }

    if (overlayContext?.props) {
      const overlayProp = overlayContext.props.get(propName);
      if (overlayProp) {
        const overlayEdid = objectEdid(overlayProp, overlayContext.recordsByEdid);
        if (overlayEdid === expectedEdid) {
          this.pass(checkName, `${propName} points at ${expectedEdid} via active overlay.`, overlayContext.path);
          return;
        }
      }
    }

    if (allowRuntimeFallback) {
      this.pass(checkName, `${propName} is runtime-wired by PDV__ManagerQuest.`, path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc"));
      return;
    }

    if (!baseProp) {
      gapFn(checkName, `${propName} is missing.`, PDV_ESP);
      return;
    }

    const actualEdid = objectEdid(baseProp, this.recordsByEdid);
    gapFn(checkName, `${propName} points at ${actualEdid || baseProp.Object || "unassigned"}, expected ${expectedEdid}.`, PDV_ESP);
  }

  checkPlayerAliasContract(gapFn, checkLabel) {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const questAlias = findQuestAlias(fields, "PDV_Player");
    if (!questAlias) {
      gapFn(checkLabel, "PDV__ManagerQuest is missing quest alias PDV_Player.", PDV_ESP);
      return;
    }

    this.pass(checkLabel, "PDV_Player alias exists on PDV__ManagerQuest.", PDV_ESP);
    const aliasScript = findAliasScript(fields, questAlias.ID, "PDV_PlayerEvents");
    if (!aliasScript) {
      gapFn(checkLabel, "PDV_Player alias is missing PDV_PlayerEvents.", PDV_ESP);
      return;
    }

    this.pass(checkLabel, "PDV_Player alias has PDV_PlayerEvents attached.", PDV_ESP);
    this.checkObjectProperties("PDV_Player alias property", propertyMap(aliasScript), PLAYER_ALIAS_PROPERTIES);
  }

  checkPatternPilotScripts() {
    this.checkPatternPilotScript("PDV_Substrate_DunmerAncestor", "PDV_Substrate_DunmerAncestor");
    this.checkPatternPilotScript("PDV_Substrate_KhajiitLunar", "PDV_Substrate_KhajiitLunar");
    this.checkPatternPilotScript("PDV_DaedricPath_Hircine", "PDV_DaedricPath_Hircine");
  }

  checkPatternPilotScript(questEdid, scriptName) {
    const detail = this.recordDetails.get(questEdid);
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, scriptName);
    if (!script) {
      this.patternGap("V3 Pattern Proving pilot script", `${scriptName} is not attached to ${questEdid}.`, PDV_ESP);
      return;
    }

    this.pass("V3 Pattern Proving pilot script", `${scriptName} is attached to ${questEdid}.`, PDV_ESP);
  }

  checkPatternArrayReadback() {
    const concordat = this.recordDetails.get("PDV_RepTrack_ConcordatStanding");
    if (concordat) {
      const script = findScript(concordat.fields || {}, "PDV_ReputationTrack");
      if (script) {
        const props = propertyMap(script);
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_RepTrack_ConcordatStanding",
          "ThresholdValues",
          extractNumericArrayProperty(props.get("ThresholdValues")),
          4,
        );
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_RepTrack_ConcordatStanding",
          "ThresholdLabels",
          extractStringArrayProperty(props.get("ThresholdLabels")),
          5,
        );
      }
    }

    const bosmer = this.recordDetails.get("PDV_StateTrack_BosmerPath");
    if (bosmer) {
      const script = findScript(bosmer.fields || {}, "PDV_StateTrack");
      if (script) {
        const props = propertyMap(script);
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_StateTrack_BosmerPath",
          "StateLabels",
          extractStringArrayProperty(props.get("StateLabels")),
          4,
        );
      }
    }

    const hircine = this.recordDetails.get("PDV_DaedricPath_Hircine");
    if (hircine) {
      const script = findFirstScript(hircine.fields || {}, ["PDV_DaedricPath_Hircine", "PDV_DaedricPathBase"]);
      if (script) {
        const props = propertyMap(script);
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_DaedricPath_Hircine",
          "StateByRace",
          extractNumericArrayProperty(props.get("StateByRace")),
          10,
        );
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_DaedricPath_Hircine",
          "StigmaModByRace",
          extractNumericArrayProperty(props.get("StigmaModByRace")),
          10,
        );
        this.checkRequiredArrayLength(
          "V3 Pattern Proving array readback",
          "PDV_DaedricPath_Hircine",
          "ExitDifficultyByRace",
          extractNumericArrayProperty(props.get("ExitDifficultyByRace")),
          10,
        );
      }
    }
  }

  checkSlice1SignalReceiverRecords() {
    for (const definition of SLICE1_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      const detail = this.recordDetails.get(definition.recordEdid);
      if (!record || !detail) {
        this.info(
          "V3 Slice 1 signal receiver record",
          `${definition.recordEdid} is not present yet; manual CK/xEdit proof-record creation remains pending.`,
          PDV_ESP,
        );
        continue;
      }

      if (record.type !== definition.recordType) {
        this.fail(
          "V3 Slice 1 signal receiver record",
          `${definition.recordEdid} has type ${record.type}, expected ${definition.recordType}.`,
          PDV_ESP,
        );
        continue;
      }

      this.pass("V3 Slice 1 signal receiver record", `${definition.recordEdid} exists as ${definition.recordType}.`, PDV_ESP);
      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.patternGap("V3 Slice 1 signal receiver script", `${definition.scriptName} is not attached to ${definition.recordEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("V3 Slice 1 signal receiver script", `${definition.scriptName} is attached to ${definition.recordEdid}.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("V3 Slice 1 signal receiver property", props, "PDV_EventBusService", "PDV_EventBus", this.patternGap.bind(this));
      this.checkObjectPropertyTarget("V3 Slice 1 signal receiver property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.patternGap.bind(this));
      this.checkObjectPropertyTarget("V3 Slice 1 signal receiver property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.patternGap.bind(this));
      this.checkScalarProperty("V3 Slice 1 signal receiver property", props, "RouteId", definition.routeId, this.patternGap.bind(this));
      this.checkScalarProperty("V3 Slice 1 signal receiver property", props, "RequiredOriginRace", definition.requiredOriginRace, this.patternGap.bind(this));
    }
  }

  checkPhase7SignalReceiverRecords() {
    for (const definition of PHASE7_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      const detail = this.recordDetails.get(definition.recordEdid);
      if (!record || !detail) {
        this.phase7Gap(
          "Phase 7 signal receiver record",
          `${definition.recordEdid} is not present yet; manual CK/xEdit co-attachment on the real hidden shrine reference remains pending.`,
          PDV_ESP,
        );
        continue;
      }

      if (record.type !== definition.recordType) {
        this.fail(
          "Phase 7 signal receiver record",
          `${definition.recordEdid} has type ${record.type}, expected ${definition.recordType}.`,
          PDV_ESP,
        );
        continue;
      }

      this.pass("Phase 7 signal receiver record", `${definition.recordEdid} exists as ${definition.recordType}.`, PDV_ESP);
      const script = findScript(detail.fields || {}, definition.scriptName);
      if (!script) {
        this.phase7Gap("Phase 7 signal receiver script", `${definition.scriptName} is not attached to ${definition.recordEdid}.`, PDV_ESP);
        continue;
      }

      this.pass("Phase 7 signal receiver script", `${definition.scriptName} is attached to ${definition.recordEdid}.`, PDV_ESP);
      const props = propertyMap(script);
      this.checkObjectPropertyTarget("Phase 7 signal receiver property", props, "PDV_EventBusService", "PDV_EventBus", this.phase7Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 7 signal receiver property", props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace", this.phase7Gap.bind(this));
      this.checkObjectPropertyTarget("Phase 7 signal receiver property", props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel", this.phase7Gap.bind(this));
      this.checkScalarProperty("Phase 7 signal receiver property", props, "RouteId", definition.routeId, this.phase7Gap.bind(this));
      this.checkScalarProperty("Phase 7 signal receiver property", props, "RequiredOriginRace", definition.requiredOriginRace, this.phase7Gap.bind(this));
    }

    for (const definition of PHASE7_RETIRED_SIGNAL_RECEIVER_DEFINITIONS) {
      const record = this.recordsByEdid.get(definition.recordEdid);
      if (record) {
        this.fail(
          "Phase 7 retired signal receiver",
          `${definition.recordEdid} exists as ${record.type}; ${definition.reason}.`,
          PDV_ESP,
        );
      } else {
        this.pass(
          "Phase 7 retired signal receiver",
          `${definition.recordEdid} is absent from the active Devotion record set.`,
          PDV_ESP,
        );
      }
    }

    const legacyHelper = this.recordsByEdid.get("PDV_ACTI_TalosShrineDefianceSignal");
    if (legacyHelper) {
      this.fail(
        "Phase 7 legacy helper activator",
        "PDV_ACTI_TalosShrineDefianceSignal still exists. The hidden Talos receiver surface is retired until a non-rendered or visually audited replacement contract exists.",
        PDV_ESP,
      );
    }
  }

  checkRequiredFormListMembers(formListEdid, requiredEdids) {
    const detail = this.recordDetails.get(formListEdid);
    if (!detail) {
      return;
    }

    const items = detail.fields?.Items || [];
    for (const requiredEdid of requiredEdids) {
      const record = this.recordsByEdid.get(requiredEdid);
      if (!record) {
        this.skeletonGap(
          "V3 Skeleton FormList membership",
          `${formListEdid} cannot be validated for ${requiredEdid} because the record does not exist yet.`,
          PDV_ESP,
        );
        continue;
      }

      if (items.includes(record.formid)) {
        this.pass("V3 Skeleton FormList membership", `${formListEdid} contains ${requiredEdid}.`, PDV_ESP);
      } else {
        this.skeletonGap(
          "V3 Skeleton FormList membership",
          `${formListEdid} does not contain ${requiredEdid} (${record.formid}).`,
          PDV_ESP,
        );
      }
    }
  }

  checkForbiddenFormListMembers(formListEdid, forbiddenEdids) {
    const detail = this.recordDetails.get(formListEdid);
    if (!detail) {
      return;
    }

    const items = detail.fields?.Items || [];
    for (const forbiddenEdid of forbiddenEdids) {
      const record = this.recordsByEdid.get(forbiddenEdid);
      if (!record) {
        continue;
      }

      if (items.includes(record.formid)) {
        this.skeletonGap("V3 Skeleton FormList contradiction", `${formListEdid} should not contain ${forbiddenEdid} (${record.formid}).`, PDV_ESP);
      } else {
        this.pass("V3 Skeleton FormList contradiction", `${formListEdid} does not contain ${forbiddenEdid}.`, PDV_ESP);
      }
    }
  }

  checkSkeletonQuestRecord(edid, checkName) {
    const record = this.recordsByEdid.get(edid);
    if (!record) {
      this.skeletonGap(checkName, `Missing QUST record ${edid}.`, PDV_ESP);
    } else if (record.type !== "QUST") {
      this.fail(checkName, `${edid} has type ${record.type}, expected QUST.`, PDV_ESP);
    } else {
      this.pass(checkName, `${edid} exists as QUST.`, PDV_ESP);
    }
  }

  checkSkeletonGlobalRecord(edid, checkName) {
    const record = this.recordsByEdid.get(edid);
    if (!record) {
      this.skeletonGap(checkName, `Missing GLOB record ${edid}.`, PDV_ESP);
    } else if (record.type !== "GLOB") {
      this.fail(checkName, `${edid} has type ${record.type}, expected GLOB.`, PDV_ESP);
    } else {
      this.pass(checkName, `${edid} exists as GLOB.`, PDV_ESP);
    }
  }

  checkScalarProperty(checkName, props, propName, expectedValue, gapFn) {
    const prop = props.get(propName);
    if (!prop) {
      gapFn(checkName, `${propName} is missing.`, PDV_ESP);
      return;
    }

    const actualValue = propValue(prop);
    if (valuesEqual(actualValue, expectedValue)) {
      this.pass(checkName, `${propName} = ${JSON.stringify(expectedValue)}.`, PDV_ESP);
    } else {
      gapFn(checkName, `${propName} is ${JSON.stringify(actualValue)}, expected ${JSON.stringify(expectedValue)}.`, PDV_ESP);
    }
  }

  checkObjectPropertyTarget(checkName, props, propName, expectedEdid, gapFn) {
    const prop = props.get(propName);
    if (!prop) {
      gapFn(checkName, `${propName} is missing.`, PDV_ESP);
      return;
    }

    const actualEdid = objectEdid(prop, this.recordsByEdid);
    if (actualEdid === expectedEdid || formidsEqual(prop.Object, expectedEdid)) {
      this.pass(checkName, `${propName} points at ${expectedEdid}.`, PDV_ESP);
    } else {
      gapFn(checkName, `${propName} points at ${actualEdid || prop.Object || "unassigned"}, expected ${expectedEdid}.`, PDV_ESP);
    }
  }

  checkOptionalArrayLength(checkName, recordEdid, propName, values, expectedLength) {
    if (!values.length) {
      this.info(checkName, `${recordEdid}.${propName} is still manual/deferred.`, PDV_ESP);
      return;
    }

    if (values.length === expectedLength) {
      this.pass(checkName, `${recordEdid}.${propName} length is ${expectedLength}.`, PDV_ESP);
    } else {
      this.skeletonGap(checkName, `${recordEdid}.${propName} length is ${values.length}, expected ${expectedLength}.`, PDV_ESP);
    }
  }

  checkOptionalMinArrayLength(checkName, recordEdid, propName, values, minLength) {
    if (!values.length) {
      this.info(checkName, `${recordEdid}.${propName} is still manual/deferred.`, PDV_ESP);
      return;
    }

    if (values.length >= minLength) {
      this.pass(checkName, `${recordEdid}.${propName} length ${values.length} satisfies minimum ${minLength}.`, PDV_ESP);
    } else {
      this.skeletonGap(checkName, `${recordEdid}.${propName} length is ${values.length}, expected at least ${minLength}.`, PDV_ESP);
    }
  }

  checkRequiredArrayLength(checkName, recordEdid, propName, values, expectedLength, gapFn = null) {
    const reportGap = gapFn || this.patternGap.bind(this);
    if (!values.length) {
      reportGap(checkName, `${recordEdid}.${propName} is missing; expected length ${expectedLength}.`, PDV_ESP);
      return;
    }

    if (values.length === expectedLength) {
      this.pass(checkName, `${recordEdid}.${propName} length is ${expectedLength}.`, PDV_ESP);
    } else {
      reportGap(checkName, `${recordEdid}.${propName} length is ${values.length}, expected ${expectedLength}.`, PDV_ESP);
    }
  }

  checkManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    this.checkDuplicateScriptAttachments("PDV__ManagerQuest", fields, "PDV__ManagerQuest", "Manager script attachments");
    const script = findScript(fields, "PDV__ManagerQuest");
    if (!script) {
      this.fail("Manager script", "PDV__ManagerQuest script is not attached.", PDV_ESP);
      return;
    }

    this.pass("Manager script", "PDV__ManagerQuest script is attached.", PDV_ESP);
    const props = propertyMap(script);
    this.checkObjectProperties("Manager property", props, MANAGER_PROPERTIES);

    if (this.recordsByEdid.has("PDV_GLO_PatronState")) {
      this.checkObjectProperties("Manager preflight property", props, MANAGER_PREFLIGHT_PROPERTIES);
    } else {
      this.preflightGap("Manager preflight property", "PDV_GLO_PatronState is script-ready but CK/global wiring is pending.", PDV_ESP);
    }

    const vmad = fields.VirtualMachineAdapter || {};
    const fragments = vmad.Fragments || [];
    const qfScripts = (vmad.Scripts || [])
      .map((entry) => entry.Name)
      .filter((name) => String(name || "").startsWith("QF_"));

    if (fragments.length || qfScripts.length) {
      this.warn(
        "Manager fragments",
        `Quest still has CK fragment metadata/scripts (fragments=${fragments.length}, qf_scripts=${qfScripts.join(", ") || "none"}). PDV currently avoids CK stage fragments.`,
        PDV_ESP,
      );
    }

    const missingQfFiles = qfScripts.filter((name) => {
      return !exists(path.join(DEVOTION_SOURCE, `${name}.psc`)) && !exists(path.join(DEVOTION_PEX, `${name}.pex`));
    });
    if (missingQfFiles.length) {
      this.warn(
        "Missing QF files",
        `VMAD references fragment scripts with no source or pex on disk: ${missingQfFiles.join(", ")}`,
        PDV_ESP,
      );
    }
  }

  checkMainQuestRecord() {
    const detail = this.recordDetails.get("PDV__MainQuest");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, "PDV__MainQuest");
    if (!script) {
      this.fail("MainQuest script", "PDV__MainQuest script is not attached.", PDV_ESP);
      return;
    }

    this.pass("MainQuest script", "PDV__MainQuest script is attached.", PDV_ESP);
    this.checkObjectProperties("MainQuest property", propertyMap(script), MAINQUEST_PROPERTIES);
  }

  checkOriginRecord() {
    const detail = this.recordDetails.get("PDV_Origin");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, "PDV_Origin");
    if (!script) {
      this.fail("Origin script", "PDV_Origin script is not attached.", PDV_ESP);
      return;
    }

    this.pass("Origin script", "PDV_Origin script is attached.", PDV_ESP);
    this.checkObjectProperties("Origin property", propertyMap(script), ORIGIN_PROPERTIES);
  }

  checkKyneRecord() {
    const detail = this.recordDetails.get("PDV_Deity_Kyne");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, "PDV_Deity_Kyne");
    if (!script) {
      this.fail("Kyne script", "PDV_Deity_Kyne script is not attached.", PDV_ESP);
      return;
    }

    this.pass("Kyne script", "PDV_Deity_Kyne script is attached.", PDV_ESP);
    const props = propertyMap(script);
    for (const [propName, expected] of Object.entries(KYNE_EXPECTED_DATA)) {
      const actual = propValue(props.get(propName));
      if (valuesEqual(actual, expected)) {
        this.pass("Kyne property", `${propName} = ${expected}.`, PDV_ESP);
      } else {
        this.warn("Kyne property", `${propName} is ${JSON.stringify(actual)}, expected ${JSON.stringify(expected)}.`, PDV_ESP);
      }
    }

    const debugProp = props.get("PDV_GLO_DebugLevel");
    if (debugProp && objectEdid(debugProp, this.recordsByEdid) === "PDV_GLO_DebugLevel") {
      this.pass("Kyne property", "PDV_GLO_DebugLevel points at PDV_GLO_DebugLevel.", PDV_ESP);
    } else {
      this.warn("Kyne property", "PDV_GLO_DebugLevel is missing or points elsewhere.", PDV_ESP);
    }

    const originProp = props.get("PDV_GLO_OriginRace");
    if (originProp && objectEdid(originProp, this.recordsByEdid) === "PDV_GLO_OriginRace") {
      this.pass("Kyne property", "PDV_GLO_OriginRace points at PDV_GLO_OriginRace.", PDV_ESP);
    } else {
      this.warn("Kyne property", "PDV_GLO_OriginRace is missing or points elsewhere.", PDV_ESP);
    }

    this.checkAssignedObjectProperty("Kyne boon", props, "Boon_Seeker");
    this.checkAssignedObjectProperty("Kyne boon", props, "Boon_Devoted");
    this.checkAssignedObjectProperty("Kyne boon", props, "Boon_Champion");
  }

  checkTalosRecord() {
    this.checkDeityRecord("PDV_Deity_Talos", "PDV_Deity_Talos", TALOS_EXPECTED_DATA, {
      requireBoons: true,
      requireOriginGlobal: true,
      requireDebugGlobal: true,
      rivalEdids: ["PDV_Deity_AuriEl"],
    });
  }

  checkAuriElRecord() {
    this.checkDeityRecord("PDV_Deity_AuriEl", "PDV_Deity_AuriEl", AURIEL_EXPECTED_DATA, {
      requireBoons: true,
      requireOriginGlobal: true,
      requireDebugGlobal: true,
      rivalEdids: [],
    });
  }

  checkDeityRecord(recordEdid, scriptName, expectedData, options = {}) {
    const detail = this.recordDetails.get(recordEdid);
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, scriptName);
    if (!script) {
      this.fail(`${recordEdid} script`, `${scriptName} is not attached.`, PDV_ESP);
      return;
    }

    this.pass(`${recordEdid} script`, `${scriptName} is attached.`, PDV_ESP);
    const props = propertyMap(script);

    for (const [propName, expected] of Object.entries(expectedData)) {
      const actual = propValue(props.get(propName));
      if (valuesEqual(actual, expected)) {
        this.pass(`${recordEdid} property`, `${propName} = ${expected}.`, PDV_ESP);
      } else {
        this.warn(`${recordEdid} property`, `${propName} is ${JSON.stringify(actual)}, expected ${JSON.stringify(expected)}.`, PDV_ESP);
      }
    }

    if (options.requireDebugGlobal) {
      this.checkLinkedObjectProperty(`${recordEdid} property`, props, "PDV_GLO_DebugLevel", "PDV_GLO_DebugLevel");
    }

    if (options.requireOriginGlobal) {
      this.checkLinkedObjectProperty(`${recordEdid} property`, props, "PDV_GLO_OriginRace", "PDV_GLO_OriginRace");
    }

    if (options.requireBoons) {
      this.checkAssignedObjectProperty(`${recordEdid} boon`, props, "Boon_Seeker");
      this.checkAssignedObjectProperty(`${recordEdid} boon`, props, "Boon_Devoted");
      this.checkAssignedObjectProperty(`${recordEdid} boon`, props, "Boon_Champion");
    }

    if (Object.hasOwn(options, "rivalEdids")) {
      this.checkRivalList(`${recordEdid} rivals`, props, options.rivalEdids);
    }
  }

  checkRivalList(checkName, props, expectedEdids) {
    const rivalProp = props.get("RivalDeities");
    if (!rivalProp) {
      if (!expectedEdids.length) {
        this.pass(checkName, "RivalDeities is absent, which is acceptable for an empty first-pass rivalry list.", PDV_ESP);
      } else {
        this.fail(checkName, "RivalDeities is missing.", PDV_ESP);
      }
      return;
    }

    const rivals = extractFormidsFromArrayProperty(rivalProp);
    const actualEdids = rivals.map((formid) => formidToEdid(formid, this.recordsByEdid)).filter(Boolean);

    if (actualEdids.length !== expectedEdids.length || !expectedEdids.every((edid) => actualEdids.includes(edid))) {
      this.warn(checkName, `RivalDeities are [${actualEdids.join(", ")}], expected [${expectedEdids.join(", ")}].`, PDV_ESP);
    } else {
      this.pass(checkName, `RivalDeities match [${expectedEdids.join(", ")}].`, PDV_ESP);
    }

    const multProp = props.get("RivalMultipliers");
    if (!multProp) {
      if (!expectedEdids.length) {
        this.pass(checkName, "RivalMultipliers is absent, which is acceptable for an empty first-pass rivalry list.", PDV_ESP);
      } else {
        this.fail(checkName, "RivalMultipliers is missing.", PDV_ESP);
      }
      return;
    }

    const multipliers = extractNumericArrayProperty(multProp);
    if (multipliers.length !== expectedEdids.length) {
      this.warn(checkName, `RivalMultipliers count is ${multipliers.length}, expected ${expectedEdids.length}.`, PDV_ESP);
    } else {
      this.pass(checkName, `RivalMultipliers count matches ${expectedEdids.length}.`, PDV_ESP);
    }
  }

  checkFormListRecord() {
    const detail = this.recordDetails.get("PDV_FLST_AllDeities");
    if (!detail) {
      return;
    }

    const items = detail.fields?.Items || [];
    for (const deityEdid of ["PDV_Deity_Kyne", "PDV_Deity_Talos", "PDV_Deity_AuriEl"]) {
      const deity = this.recordsByEdid.get(deityEdid);
      if (!deity) {
        continue;
      }

      if (items.includes(deity.formid)) {
        this.pass("Deity FormList", `PDV_FLST_AllDeities contains ${deityEdid}.`, PDV_ESP);
      } else {
        this.fail("Deity FormList", `PDV_FLST_AllDeities does not contain ${deityEdid} (${deity.formid}).`, PDV_ESP);
      }
    }
  }

  checkPhase3Records() {
    this.checkOptionalQuestScript("PDV_ActionRouter", "PDV_ActionRouter", ROUTER_PROPERTIES);
    for (const receiverScript of STORY_MANAGER_RECEIVER_SCRIPTS) {
      this.checkOptionalQuestScript(receiverScript, receiverScript, RECEIVER_PROPERTIES);
    }
    const hasEventBusRecord = this.recordsByEdid.has("PDV_EventBus");
    const hasEventTypesRecord = this.recordsByEdid.has("PDV_EventTypes");

    if (hasEventBusRecord) {
      this.checkOptionalQuestScript("PDV_EventBus", "PDV_EventBus", EVENTBUS_RECORD_PROPERTIES);
    }
    if (hasEventTypesRecord) {
      this.checkOptionalQuestScript("PDV_EventTypes", "PDV_EventTypes", {});
    }

    const routerDetail = this.recordDetails.get("PDV_ActionRouter");
    const routerScript = routerDetail ? findScript(routerDetail.fields || {}, "PDV_ActionRouter") : null;
    if (routerScript) {
      const routerProps = propertyMap(routerScript);
      for (const [propName, expectedEdid] of Object.entries(ROUTER_GENERIC_FAUCET_PROPERTIES)) {
        this.checkObjectPropertyTarget("Generic faucet router property", routerProps, propName, expectedEdid, this.todo.bind(this));
      }
    }
    if (routerScript && hasEventBusRecord && hasEventTypesRecord) {
      this.checkObjectProperties("PDV_ActionRouter preflight property", propertyMap(routerScript), ROUTER_PREFLIGHT_PROPERTIES);
    } else if (routerScript) {
      this.checkPreflightQuestScript("PDV_ActionRouter", "PDV_EventBus", EVENTBUS_OVERLAY_PROPERTIES);
      this.checkPreflightQuestScript("PDV_ActionRouter", "PDV_EventTypes", {});
      this.info("PDV_ActionRouter preflight property", "EventBus/EventTypes properties are script-ready; CK co-attachment or quest wiring is pending.", PDV_ESP);
    }

    this.checkGenericFaucetPlayerAliasProperties();
    this.checkGenericFaucetSourceContracts();

    const smRecords = [...this.recordsByFormid.values()].filter((record) => String(record.type || "").toUpperCase().startsWith("SM"));
    if (smRecords.length) {
      this.info(
        "Story Manager records",
        `PDV plugin contains Story Manager-shaped records: ${smRecords.map((record) => `${record.type} ${record.formid}`).join(", ")}`,
        PDV_ESP,
      );
    } else {
      this.todo(
        "Story Manager records",
        "No SM* records found in the ESP. Kill Actor node wiring still needs CK/xEdit verification.",
        PDV_ESP,
      );
    }
    this.checkGenericFaucetStoryManagerNodes();
  }

  checkGenericFaucetStoryManagerNodes() {
    for (const node of GENERIC_FAUCET_STORY_MANAGER_NODES) {
      if (!node.nodeEdid) {
        this.todo(
          "Generic faucet Story Manager node",
          `${node.eventName} -> ${node.receiverQuest} remains blocked: installed Skyrim.esm readback has no local TrespassActorEvent SMEN root.`,
          PDV_ESP,
        );
        continue;
      }

      const detail = this.recordDetails.get(node.nodeEdid);
      if (!detail) {
        this.todo(
          "Generic faucet Story Manager node",
          `${node.eventName} -> ${node.receiverQuest} Shares Event node ${node.nodeEdid} still needs source-ESP readback proof.`,
          PDV_ESP,
        );
        continue;
      }

      const fields = detail.fields || {};
      const receiver = this.recordsByEdid.get(node.receiverQuest);
      if (!receiver?.formid) {
        this.todo(
          "Generic faucet Story Manager node",
          `${node.nodeEdid} cannot verify receiver quest because ${node.receiverQuest} was not read from the ESP.`,
          PDV_ESP,
        );
        continue;
      }

      const failures = [];
      if (String(detail.record_type || "").toUpperCase() !== "STORYMANAGERQUESTNODE") {
        failures.push(`type is ${detail.record_type || "(missing)"}, expected STORYMANAGERQUESTNODE`);
      }
      if (fields.Parent !== node.parent) {
        failures.push(`parent is ${fields.Parent || "(missing)"}, expected ${node.parent}`);
      }
      if ((fields.PreviousSibling || null) !== (node.previousSibling || null)) {
        failures.push(`previous sibling is ${fields.PreviousSibling || "(none)"}, expected ${node.previousSibling || "(none)"}`);
      }
      if (!String(fields.QuestFlags || "").split(",").map((part) => part.trim()).includes("SharesEvent")) {
        failures.push(`QuestFlags are ${fields.QuestFlags || "(missing)"}, expected SharesEvent`);
      }
      const quests = Array.isArray(fields.Quests) ? fields.Quests : [];
      if (!quests.some((quest) => quest?.Quest === receiver.formid)) {
        failures.push(`quest target does not include ${node.receiverQuest} (${receiver.formid})`);
      }

      if (failures.length) {
        this.fail("Generic faucet Story Manager node", `${node.nodeEdid}: ${failures.join("; ")}.`, PDV_ESP);
      } else {
        this.pass(
          "Generic faucet Story Manager node",
          `${node.nodeEdid} routes ${node.eventName} to ${node.receiverQuest} with Shares Event.`,
          PDV_ESP,
        );
      }
    }
  }

  checkGenericFaucetPlayerAliasProperties() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    const fields = detail?.fields || {};
    const questAlias = findQuestAlias(fields, "PDV_Player");
    const aliasScript = questAlias ? findAliasScript(fields, questAlias.ID, "PDV_PlayerEvents") : null;
    if (!aliasScript) {
      this.todo("Generic faucet player alias property", "PDV_Player alias is missing PDV_PlayerEvents readback.", PDV_ESP);
      return;
    }

    const aliasProps = propertyMap(aliasScript);
    for (const [propName, expectedEdid] of Object.entries(PLAYER_EVENTS_GENERIC_FAUCET_PROPERTIES)) {
      this.checkObjectPropertyTarget("Generic faucet player alias property", aliasProps, propName, expectedEdid, this.todo.bind(this));
    }
  }

  checkGenericFaucetSourceContracts() {
    this.checkSourceContains("Generic faucet router source", "PDV_ActionRouter", [
      "Function HandleStoryCraftItem(ObjectReference akBench, Location akLocation, Form akCreatedItem)",
      "Function HandleStoryNewVoicePower(ObjectReference akActor, Form akVoicePower)",
      "Function HandleStoryIncreaseSkill(String asSkill)",
      "Function HandleStoryChangeLocation(ObjectReference akActor, Location akOldLocation, Location akNewLocation)",
      "Function HandleStoryPickLock(ObjectReference akActor, ObjectReference akLock)",
      "Function HandleStoryTrespass(ObjectReference akVictim, ObjectReference akTrespasser, Location akLocation, Int aiCrime)",
      "Function HandleStoryAssaultActor(ObjectReference akVictim, ObjectReference akAttacker, Location akLocation, Int aiCrime)",
      "Function ClassifyNonHostileKillVictim(Actor victimActor, Int aiCrimeStatus)",
      "Function ClassifyCraftBench(ObjectReference benchRef)",
      "Function ClassifyBook(Book bookRef)",
      "EVT_KILL_ANIMAL_NONCOMBAT",
      "EVT_MURDER_DEFENSELESS",
      "EVT_SMITH_ITEM",
      "EVT_ENCHANT_ITEM",
      "EVT_BREW_POTION",
      "EVT_COOK_MEAL",
      "EVT_LEARN_WORD_OF_POWER",
      "EVT_INCREASE_SKILL",
      "EVT_DISCOVER_LOCATION",
      "EVT_PICK_OWNED_LOCK",
      "EVT_TRESPASS",
      "EVT_ASSAULT_INNOCENT",
    ], this.todo.bind(this));

    this.checkSourceContains("Generic faucet PO3 source", "PDV_PlayerEvents", [
      "RouteGenericBookRead(akBook)",
      "RouteGenericAction(EVT_HARVEST_INGREDIENT",
      "RouteGenericAction(EVT_ACCEPT_DAEDRIC_ARTIFACT",
      "RouteGenericAction(EVT_RAISE_UNDEAD",
      "RouteGenericAction(EVT_REST_UNDER_OPEN_SKY",
      "RouteGenericAction(EVT_SLEEP_IN_BED",
      "Function RegisterGenericEffectList(FormList effectList)",
      "PO3_Events_Alias.RegisterForBookRead(Self)",
      "PO3_Events_Alias.RegisterForItemHarvested(Self)",
    ], this.todo.bind(this));
  }

  checkPreflightOverlayPatch() {
    const overlayPath = path.join(DEVOTION_MOD, PREFLIGHT_ROUTER_OVERLAY_PATCH);
    const hasEventBusRecord = this.recordsByEdid.has("PDV_EventBus");
    const hasEventTypesRecord = this.recordsByEdid.has("PDV_EventTypes");
    const requireOverlayCanary = !hasEventBusRecord || !hasEventTypesRecord;
    if (!exists(overlayPath)) {
      if (requireOverlayCanary) {
        this.preflightGap(
          "V3 Preflight overlay",
          `${PREFLIGHT_ROUTER_OVERLAY_PATCH} has not been generated yet.`,
          overlayPath,
        );
      } else {
        this.info(
          "V3 Preflight overlay",
          `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is not required because framework-owned EventBus/EventTypes records exist.`,
          overlayPath,
        );
      }
      return;
    }

    this.pass(
      "V3 Preflight overlay",
      `${PREFLIGHT_ROUTER_OVERLAY_PATCH} exists in the Devotion mod.`,
      overlayPath,
    );

    if (!requireOverlayCanary) {
      this.info(
        "V3 Preflight overlay",
        `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is an inactive historical canary; framework-owned EventBus/EventTypes records exist in Devotion.esp.`,
        overlayPath,
      );
      return;
    }

    let overlayInventory;
    try {
      overlayInventory = this.scanPlugin(overlayPath);
    } catch (error) {
      this.fail("V3 Preflight overlay", `Overlay scan failed: ${error.message}`, overlayPath);
      return;
    }

    const overlayRecord = overlayInventory.recordsByEdid.get("PDV_ActionRouter");
    if (!overlayRecord) {
      this.fail(
        "V3 Preflight overlay",
        `${PREFLIGHT_ROUTER_OVERLAY_PATCH} does not override PDV_ActionRouter.`,
        overlayPath,
      );
      return;
    }

    let overlayDetail;
    try {
      overlayDetail = this.readPluginRecordDetail(overlayPath, overlayRecord.formid);
    } catch (error) {
      this.fail("V3 Preflight overlay", `Overlay detail read failed: ${error.message}`, overlayPath);
      return;
    }

    const combinedRecordsByEdid = new Map(this.recordsByEdid);
    for (const [edid, record] of overlayInventory.recordsByEdid.entries()) {
      combinedRecordsByEdid.set(edid, record);
    }

    const fields = overlayDetail.fields || {};
    const routerScript = findScript(fields, "PDV_ActionRouter");
    if (!routerScript) {
      this.fail(
        "V3 overlay router script",
        "PDV_ActionRouter script is missing from the overlay override.",
        overlayPath,
      );
      return;
    }

    this.pass("V3 overlay router script", "PDV_ActionRouter script is present in the overlay.", overlayPath);
    this.checkObjectProperties(
      "V3 overlay router property",
      propertyMap(routerScript),
      ROUTER_PREFLIGHT_OVERLAY_PROPERTIES,
      { filePath: overlayPath, recordsByEdid: combinedRecordsByEdid },
    );

    const eventBusScript = findScript(fields, "PDV_EventBus");
    if (!eventBusScript) {
      this.fail(
        "V3 overlay EventBus script",
        "PDV_EventBus is not attached to the overlay override.",
        overlayPath,
      );
    } else {
      this.pass("V3 overlay EventBus script", "PDV_EventBus is attached in the overlay.", overlayPath);
      this.checkObjectProperties(
        "V3 overlay EventBus property",
        propertyMap(eventBusScript),
        EVENTBUS_OVERLAY_PROPERTIES,
        { filePath: overlayPath, recordsByEdid: combinedRecordsByEdid },
      );
    }

    const eventTypesScript = findScript(fields, "PDV_EventTypes");
    if (!eventTypesScript) {
      this.fail(
        "V3 overlay EventTypes script",
        "PDV_EventTypes is not attached to the overlay override.",
        overlayPath,
      );
    } else {
      this.pass("V3 overlay EventTypes script", "PDV_EventTypes is attached in the overlay.", overlayPath);
    }
  }

  checkMcmRecord() {
    const detail = this.recordDetails.get("PDV_MCM");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    this.checkDuplicateScriptAttachments("PDV_MCM", fields, "PDV_MCM", "PDV_MCM script attachments");
    const script = findScript(fields, "PDV_MCM");
    if (!script) {
      this.fail("PDV_MCM script", "PDV_MCM is not attached.", PDV_ESP);
      return;
    }

    this.pass("PDV_MCM script", "PDV_MCM is attached.", PDV_ESP);
    const props = propertyMap(script);
    this.checkObjectProperties("PDV_MCM property", props, MCM_PROPERTIES);
    for (const [propName, expectedEdid] of Object.entries(MCM_SKELETON_PROPERTIES)) {
      this.checkObjectPropertyTarget("V3 Skeleton MCM property", props, propName, expectedEdid, this.skeletonGap.bind(this));
    }
  }

  checkOptionalQuestScript(questEdid, scriptName, expectedProperties) {
    const detail = this.recordDetails.get(questEdid);
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, scriptName);
    if (!script) {
      this.fail(`${questEdid} script`, `${scriptName} is not attached.`, PDV_ESP);
      return;
    }

    this.pass(`${questEdid} script`, `${scriptName} is attached.`, PDV_ESP);
    this.checkObjectProperties(`${questEdid} property`, propertyMap(script), expectedProperties);
  }

  checkPreflightQuestScript(questEdid, scriptName, expectedProperties) {
    const detail = this.recordDetails.get(questEdid);
    if (!detail) {
      return;
    }

    const script = findScript(detail.fields || {}, scriptName);
    if (!script) {
      this.info(`${scriptName} script`, `${scriptName} is not attached yet; V3 Preflight CK wiring remains pending.`, PDV_ESP);
      return;
    }

    this.pass(`${scriptName} script`, `${scriptName} is attached.`, PDV_ESP);
    this.checkObjectProperties(`${scriptName} property`, propertyMap(script), expectedProperties);
  }

  checkDuplicateScriptAttachments(recordEdid, fields, scriptName, checkName) {
    const scripts = findScripts(fields, scriptName);
    if (scripts.length <= 1) {
      this.pass(checkName, `${recordEdid} has a single ${scriptName} VMAD entry.`, PDV_ESP);
      return;
    }

    const propertySets = scripts.map((script, index) => {
      const names = (script.Properties || [])
        .map((prop) => prop.Name)
        .filter(Boolean)
        .sort();
      return `#${index}=[${names.join(", ")}]`;
    });

    this.warn(
      checkName,
      `${recordEdid} has ${scripts.length} duplicate ${scriptName} VMAD entries split across ${propertySets.join("; ")}. Prefer one canonical script attachment per record.`,
      PDV_ESP,
    );
  }

  checkObjectProperties(checkName, props, expectedProperties, options = {}) {
    const recordsByEdid = options.recordsByEdid || this.recordsByEdid;
    const filePath = options.filePath || PDV_ESP;
    for (const [propName, expectedEdid] of Object.entries(expectedProperties)) {
      const prop = props.get(propName);
      if (!prop) {
        this.fail(checkName, `${propName} is missing.`, filePath);
        continue;
      }

      if (expectedEdid === null) {
        if (prop.Object || prop.Alias !== -1 || Object.hasOwn(prop, "Data")) {
          this.pass(checkName, `${propName} is assigned.`, filePath);
        } else {
          this.fail(checkName, `${propName} appears unassigned.`, filePath);
        }
        continue;
      }

      const actualEdid = objectEdid(prop, recordsByEdid);
      if (actualEdid === expectedEdid) {
        this.pass(checkName, `${propName} points at ${expectedEdid}.`, filePath);
      } else {
        this.fail(
          checkName,
          `${propName} points at ${actualEdid || prop.Object || "unassigned"}, expected ${expectedEdid}.`,
          filePath,
        );
      }
    }
  }

  checkAssignedObjectProperty(checkName, props, propName) {
    const prop = props.get(propName);
    if (!prop) {
      this.fail(checkName, `${propName} is missing.`, PDV_ESP);
      return;
    }

    if (prop.Object) {
      this.pass(checkName, `${propName} is assigned.`, PDV_ESP);
    } else {
      this.warn(checkName, `${propName} is unassigned.`, PDV_ESP);
    }
  }

  checkLinkedObjectProperty(checkName, props, propName, expectedEdid) {
    const prop = props.get(propName);
    if (!prop) {
      this.fail(checkName, `${propName} is missing.`, PDV_ESP);
      return;
    }

    const actualEdid = objectEdid(prop, this.recordsByEdid);
    if (actualEdid === expectedEdid) {
      this.pass(checkName, `${propName} points at ${expectedEdid}.`, PDV_ESP);
    } else {
      this.warn(checkName, `${propName} is missing or points elsewhere.`, PDV_ESP);
    }
  }

  checkCustomRaceCompatibility() {
    this.checkCustomRaceMapFiles();
    this.checkSourceContains("Custom race origin source", "PDV_Origin", [
      "String Property RACEMAP_FILE = \"PlayerDevotion/PDV_RaceMap\" AutoReadOnly",
      "String Property TEMPORARY_RACEMAP_FILE = \"PlayerDevotion/PDV_TemporaryRaceMap\" AutoReadOnly",
      "Function IsCustomTemporaryRace",
      "temporaryRaceForms",
      "ResolveViaActorProxy",
      "PDV.Compat.CustomRaceMapping",
    ]);
    this.checkSourceContains("Custom race MCM source", "PDV_MCM", [
      "Custom race mapping",
      "Defer origin capture",
      "temporary-race defer list",
    ]);
  }

  checkCustomRaceMapFiles() {
    const raceMap = this.readJsonForCheck("Custom race map", CUSTOM_RACE_MAP);
    const temporaryMap = this.readJsonForCheck("Custom temporary race map", CUSTOM_TEMPORARY_RACE_MAP);

    if (exists(CUSTOM_RACE_README)) {
      const readme = fs.readFileSync(CUSTOM_RACE_README, "utf8");
      const requiredReadmeSnippets = [
        "0 Nord",
        "6 Khajiit",
        "RaceCompatibility",
        "Race Blood Test",
        "temporaryRaceForms",
        "Do not put temporary transformation races in",
      ];
      for (const snippet of requiredReadmeSnippets) {
        if (readme.includes(snippet)) {
          this.pass("Custom race README", `README mentions ${snippet}.`, CUSTOM_RACE_README);
        } else {
          this.fail("Custom race README", `README is missing ${snippet}.`, CUSTOM_RACE_README);
        }
      }
    } else {
      this.fail("Custom race README", "PDV_RaceMap_README.txt is missing.", CUSTOM_RACE_README);
    }

    if (!raceMap || !temporaryMap) {
      return;
    }

    const raceForms = Array.isArray(raceMap.raceForms) ? raceMap.raceForms : null;
    const raceIndices = Array.isArray(raceMap.raceIndices) ? raceMap.raceIndices : null;
    if (!raceForms || !raceIndices) {
      this.fail("Custom race map", "raceForms and raceIndices must both be arrays.", CUSTOM_RACE_MAP);
      return;
    }

    if (raceForms.length === raceIndices.length) {
      this.pass("Custom race map", `${raceForms.length} race mapping entries have matching indices.`, CUSTOM_RACE_MAP);
    } else {
      this.fail("Custom race map", `raceForms length ${raceForms.length} does not match raceIndices length ${raceIndices.length}.`, CUSTOM_RACE_MAP);
    }

    const expectedEntries = new Map([
      ["0x03322B|HalfKhajiit.esp", 6],
      ["0x05693A|HalfKhajiit.esp", 6],
    ]);
    const normalizedMappings = new Map();
    for (let entryIndex = 0; entryIndex < raceForms.length; entryIndex += 1) {
      const raceForm = raceForms[entryIndex];
      const raceIndex = raceIndices[entryIndex];
      if (typeof raceForm !== "string" || !/^0x[0-9a-f]{6}\|[^|]+\.es[mlp]$/i.test(raceForm)) {
        this.fail("Custom race map", `raceForms[${entryIndex}] is not a PapyrusUtil form token: ${JSON.stringify(raceForm)}.`, CUSTOM_RACE_MAP);
        continue;
      }
      if (!Number.isInteger(raceIndex) || raceIndex < 0 || raceIndex > 9) {
        this.fail("Custom race map", `raceIndices[${entryIndex}] must be an integer 0..9, got ${JSON.stringify(raceIndex)}.`, CUSTOM_RACE_MAP);
        continue;
      }
      normalizedMappings.set(raceForm.toLowerCase(), raceIndex);
    }

    for (const [raceForm, expectedIndex] of expectedEntries.entries()) {
      const actualIndex = normalizedMappings.get(raceForm.toLowerCase());
      if (actualIndex === expectedIndex) {
        this.pass("Ohmes-Raht custom race map", `${raceForm} maps to race index ${expectedIndex}.`, CUSTOM_RACE_MAP);
      } else {
        this.fail("Ohmes-Raht custom race map", `${raceForm} must map to race index ${expectedIndex}.`, CUSTOM_RACE_MAP);
      }
    }

    const temporaryRaceForms = Array.isArray(temporaryMap.temporaryRaceForms) ? temporaryMap.temporaryRaceForms : null;
    if (!temporaryRaceForms) {
      this.fail("Custom temporary race map", "temporaryRaceForms must be an array.", CUSTOM_TEMPORARY_RACE_MAP);
      return;
    }

    const normalizedTemporaryForms = new Set();
    for (let entryIndex = 0; entryIndex < temporaryRaceForms.length; entryIndex += 1) {
      const raceForm = temporaryRaceForms[entryIndex];
      if (typeof raceForm !== "string" || !/^0x[0-9a-f]{6}\|[^|]+\.es[mlp]$/i.test(raceForm)) {
        this.fail("Custom temporary race map", `temporaryRaceForms[${entryIndex}] is not a PapyrusUtil form token: ${JSON.stringify(raceForm)}.`, CUSTOM_TEMPORARY_RACE_MAP);
        continue;
      }
      normalizedTemporaryForms.add(raceForm.toLowerCase());
    }

    let overlapCount = 0;
    for (const raceForm of normalizedTemporaryForms) {
      if (normalizedMappings.has(raceForm)) {
        overlapCount += 1;
        this.fail("Custom race map overlap", `${raceForm} is both a permanent race map entry and a temporary race entry.`, CUSTOM_TEMPORARY_RACE_MAP);
      }
    }
    if (overlapCount === 0) {
      this.pass("Custom race map overlap", "No permanent custom-race entries are also temporary transformation entries.", CUSTOM_TEMPORARY_RACE_MAP);
    }
  }

  readJsonForCheck(checkName, filePath) {
    if (!exists(filePath)) {
      this.fail(checkName, "JSON file is missing.", filePath);
      return null;
    }
    try {
      const parsed = JSON.parse(fs.readFileSync(filePath, "utf8"));
      this.pass(checkName, "JSON parses.", filePath);
      return parsed;
    } catch (error) {
      this.fail(checkName, `JSON parse failed: ${error.message}`, filePath);
      return null;
    }
  }

  checkScripts() {
    for (const [scriptName, requirement] of Object.entries(COMPILED_SCRIPTS)) {
      const source = path.join(DEVOTION_SOURCE, `${scriptName}.psc`);
      const pex = path.join(DEVOTION_PEX, `${scriptName}.pex`);

      if (exists(source)) {
        this.pass("Script source", `${scriptName}.psc exists.`, source);
      } else {
        this.fail("Script source", `${scriptName}.psc is missing.`, source);
      }

      if (exists(pex)) {
        this.pass("Compiled script", `${scriptName}.pex exists.`, pex);
      } else if (requirement === "phase3") {
        this.todo("Compiled script", `${scriptName}.pex is missing.`, pex);
        continue;
      } else {
        this.fail("Compiled script", `${scriptName}.pex is missing.`, pex);
        continue;
      }

      if (exists(source) && exists(pex)) {
        if (mtimeMs(pex) >= mtimeMs(source)) {
          this.pass("Script freshness", `${scriptName}.pex is newer than or equal to source.`, pex);
        } else {
          this.warn("Script freshness", `${scriptName}.pex is older than source.`, pex);
        }
      }
    }

    const straySkyuiOutputs = findStraySkyuiOutputs();
    if (straySkyuiOutputs.length) {
      this.fail("SkyUI output hygiene", `Unexpected SkyUI outputs found in Devotion\\Scripts: ${straySkyuiOutputs.join(", ")}.`, DEVOTION_PEX);
    } else {
      this.pass("SkyUI output hygiene", "No stray SKI_*.pex files found in Devotion\\Scripts.", DEVOTION_PEX);
    }

    this.checkPreflightSourceContracts();
    this.checkPhase8SourceContracts();
    this.checkPhase7SourceContracts();
    this.checkPhase9SourceContracts();
    this.checkPhase10SourceContracts();
    this.checkKhajiitSourceContracts();
    this.checkCommitmentSourceContracts();
    this.checkNeglectDecaySourceContracts();
  }

  checkPreflightSourceContracts() {
    this.checkSourceContains("V3 Preflight source", "PDV__ManagerQuest", [
      "Function RunGainPipeline",
      "Function RunDawnConsolidateScratch",
      "Function RunDawnApplyDecayNoop",
      "Function SetBroadWorship",
      "Function GetPatronStateLabel",
    ]);
    this.checkSourceContains("V3 Preflight source", "PDV_ActionRouter", [
      "Function RouteActionWithAttribution",
      "Function RouteNonScoringKillPayload",
      "PDV_EventBus Property PDV_EventBusService",
    ]);
    this.checkSourceContains("V3 Preflight source", "PDV__MainQuest", [
      "Function CheckPapyrusUtilDependency",
      "PapyrusUtil.GetVersion",
    ]);
    this.checkSourceContains("V3 Preflight source", "PDV_Origin", [
      "Function RecordCustomRaceFallback",
      "PDV.CustomRaceFallback",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV__ManagerQuest", [
      "Function ApplyConcordatPressure",
      "Function RunDawnApplyDecay()",
      "Function EvaluateKyneCommitmentOffer()",
      "Function DebugGetPatternProvingSummary()",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_MCM", [
      "Show pattern summary",
      "Concordat defiance",
      "Evaluate commitment",
      "Hircine hunt rite",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_EventBus", [
      "Function RouteConcordatPressure",
      "Function RouteSleepStop",
      "Function RouteDunmerPortableShrinePrayer",
      "Function RouteDunmerPlayerHomeBonus",
      "Function RouteGreenPactViolation",
      "Function RouteHircineHuntRite",
      "Function RouteKhajiitMoonObservance",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_EventTypes", [
      "EVT_CONCORDAT_COMPLIANCE",
      "EVT_CONCORDAT_DEFIANCE",
      "EVT_SLEEP_MOON_OBSERVANCE",
      "EVT_DUNMER_PORTABLE_SHRINE",
      "EVT_KHAJIIT_ROAD_HOME",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_DaedricPathBase", [
      "DAEDRIC_STATE_FOREIGN",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_PlayerEvents", [
      "Event OnPlayerLoadGame()",
      "Event OnSleepStop(Bool abInterrupted)",
      "PDV_EventBus Property PDV_EventBusService",
      "PDV_Origin Property PDV_OriginQuest",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_EventSignalActivator", [
      "Scriptname PDV_EventSignalActivator extends ObjectReference",
      "PDV_EventBus Property PDV_EventBusService",
      "Actor Property PlayerREF",
      "GlobalVariable Property PDV_GLO_OriginRace",
      "Int Property RouteId",
      "Int Property RequiredOriginRace",
      "String Property OncePerDayKey",
      "Event OnActivate(ObjectReference akActionRef)",
      "Function RouteSignal()",
      "RouteDunmerPortableShrinePrayer",
      "RouteDunmerPlayerHomeBonus",
      "RouteGreenPactViolation",
      "RouteHircineHuntRite",
    ]);
    this.checkSourceContains("V3 Pattern Proving source", "PDV_EventSignalEffect", [
      "Scriptname PDV_EventSignalEffect extends ActiveMagicEffect",
      "PDV_EventBus Property PDV_EventBusService",
      "Actor Property PlayerREF",
      "GlobalVariable Property PDV_GLO_OriginRace",
      "Int Property RouteId",
      "Int Property RequiredOriginRace",
      "String Property OncePerDayKey",
      "Event OnEffectStart(Actor akTarget, Actor akCaster)",
      "Function RouteSignal()",
      "RouteDunmerPortableShrinePrayer",
      "RouteDunmerPlayerHomeBonus",
      "RouteGreenPactViolation",
      "RouteHircineHuntRite",
    ]);
  }

  checkPhase8SourceContracts() {
    this.checkSourceContains("Phase 8 source", "PDV_ReputationTrack", [
      "Int Function GetRawStateIndex()",
      "Int Function GetPendingStateIndex()",
      "Bool Function IsTransitionPending()",
      "Float Function GetLockInUntil()",
      "Function RefreshState()",
      "Function EnsureStateStorage()",
      "Function StartPendingTransition(Int pendingState)",
      "Function CommitState(Int newState, String reason)",
      "Bool Function ShouldHalveInwardAdjustment(Int adjustment)",
      "\"PDV.Track.CommittedState\"",
      "\"PDV.Track.PendingState\"",
    ], this.phase8Gap.bind(this));
    this.checkSourceContains("Phase 8 source", "PDV_DeityBase", [
      "PDV_ReputationTrack Property GainModifyingTrack Auto",
      "Float[] Property GainMultiplierPerTrackState Auto",
      "PDV_ReputationTrack Property DecayModifyingTrack Auto",
      "Float[] Property DecayMultiplierPerTrackState Auto",
      "Float Function GetTrackGainMultiplier()",
      "Float Function GetEffectiveGainMultiplier()",
      "Float Function GetEffectiveDecayMultiplier()",
    ], this.phase8Gap.bind(this));
    this.checkSourceContains("Phase 8 source", "PDV__ManagerQuest", [
      "Function EnsurePhase8RuntimeWiring()",
      "PDV_Talos.GainModifyingTrack = PDV_ConcordatStandingTrack",
      "PDV_Talos.DecayModifyingTrack = PDV_ConcordatStandingTrack",
      "Function RunDawnRefreshTrackStates()",
      "appliedAmount = appliedAmount * deity.GetEffectiveGainMultiplier()",
      "deity.GetEffectiveDecayMultiplier()",
      "String Function DebugGetConcordatStateLabel()",
      "String Function DebugGetConcordatPendingStateLabel()",
      "String Function DebugGetConcordatGateLabel()",
      "Float Function GetTalosEffectiveGainMultiplier()",
    ], this.phase8Gap.bind(this));
    this.checkSourceContains("Phase 8 source", "PDV_MCM", [
      "AddHeaderOption(\"Phase 8 Concordat\", OPTION_FLAG_NONE)",
      "AddTextOption(\"Committed state\", GetConcordatStateLabel(), OPTION_FLAG_DISABLED)",
      "AddTextOption(\"Pending state\", GetConcordatPendingStateLabel(), OPTION_FLAG_DISABLED)",
      "AddTextOption(\"Extreme gate\", GetConcordatGateLabel(), OPTION_FLAG_DISABLED)",
      "AddTextOption(\"Talos gain x\", GetTalosGainMultiplierLabel(), OPTION_FLAG_DISABLED)",
    ], this.phase8Gap.bind(this));
    this.checkSourceContains("Phase 8 source", "PDV_PlayerEvents", [
      "PDV_EventBusService.RouteConcordatPressure(true)",
      "PDV_EventBusService.RouteConcordatPressure(false)",
    ], this.phase8Gap.bind(this));
    this.checkSourceContains("Phase 8 source", "PDV_EventBus", [
      "Function RouteConcordatPressure(Bool isCompliance)",
      "PDV_Manager.ApplyConcordatPressure(adjustment, \"eventbus_\" + eventType)",
      "Function RouteTalosShrineDefiance()",
    ], this.phase8Gap.bind(this));
  }

  checkPhase7SourceContracts() {
    this.checkSourceContains("Phase 7 source", "PDV_PlayerEvents", [
      "PO3_Events_Alias.RegisterForShoutAttack(Self)",
      "Event OnShoutAttack(Shout akShout)",
      "PDV_EventBusService.RouteShoutAttack(GetActorRef(), akShout)",
      "String Property MOD_EVENT_CONCORDAT_COMPLIANCE = \"PDV.ConcordatCompliance\" AutoReadOnly",
      "String Property MOD_EVENT_CONCORDAT_DEFIANCE = \"PDV.ConcordatDefiance\" AutoReadOnly",
      "RegisterForCivilWarSignals()",
      "RegisterForModEvent(MOD_EVENT_CONCORDAT_COMPLIANCE, \"OnPDVConcordatCompliance\")",
      "RegisterForModEvent(MOD_EVENT_CONCORDAT_DEFIANCE, \"OnPDVConcordatDefiance\")",
      "Event OnPDVConcordatCompliance(String eventName, String strArg, Float numArg, Form sender)",
      "Event OnPDVConcordatDefiance(String eventName, String strArg, Float numArg, Form sender)",
      "PDV_EventBusService.RouteConcordatPressure(true)",
      "PDV_EventBusService.RouteConcordatPressure(false)",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_EventBus", [
      "Function RouteShoutAttack(Actor playerRef, Shout shoutUsed)",
      "Function RouteTalosShrineDefiance()",
      "PDV_Manager.HandleShoutAttack(eventType, playerRef, shoutUsed, \"eventbus_\" + eventType)",
      "PDV_Manager.HandleTalosShrineDefiance(\"eventbus_\" + eventType)",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_FragmentBridge", [
      "Scriptname PDV_FragmentBridge Hidden",
      "Bool Function RouteConcordatFromQuest(Quest eventBusQuest, Bool isCompliance) Global",
      "PDV_EventBus eventBus = eventBusQuest as PDV_EventBus",
      "eventBus.RouteConcordatPressure(isCompliance)",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_EventTypes", [
      "EVT_TALOS_SHRINE_DEFIANCE = 35",
      "EVT_SHOUT_ATTACK = 40",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV__ManagerQuest", [
      "PO3_Events_Form.RegisterForShoutAttack(Self)",
      "Event OnPlayerShoutAttack(Shout akShout)",
      "Function RegisterManagerShoutSignals()",
      "ShouldSuppressDuplicateShoutAttack()",
      "Function HandleTalosShrineDefiance(String reason)",
      "Function HandleShoutAttack(Int eventType, Actor playerRef, Shout shoutUsed, String reason)",
      "ApplyConcordatPressure(-15, \"talos_shrine_\" + reason)",
      "AwardCuratedSignalScaled(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_EventSignalActivator", [
      "Int Property ROUTE_TALOS_SHRINE_DEFIANCE = 35 AutoReadOnly",
      "PDV_EventBusService.RouteTalosShrineDefiance()",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_DeityBase", [
      "Float Function ScoreRepeatableAction(Int eventType, Float delta, Int dailyCap, Float cooldownDays)",
      "String keyPrefix = \"PDV.Event.\" + eventType",
      "String countKey = keyPrefix + \".Count\"",
      "String lastFireKey = keyPrefix + \".LastFire\"",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_Deity_Kyne", [
      "Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly",
      "Float Property DELTA_SHOUT_ATTACK = 0.35 Auto",
      "ScoreRepeatableAction(eventType, DELTA_SHOUT_ATTACK, SHOUT_DAILY_CAP, SHOUT_COOLDOWN_DAYS)",
    ]);
    this.checkSourceContains("Phase 7 source", "PDV_Deity_Talos", [
      "Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly",
      "Float Property DELTA_SHOUT_ATTACK = 0.5 Auto",
      "ScoreRepeatableAction(eventType, DELTA_SHOUT_ATTACK, SHOUT_DAILY_CAP, SHOUT_COOLDOWN_DAYS)",
    ]);
  }

  checkPhase9SourceContracts() {
    this.checkSourceContains("Phase 9 source", "PDV_StateTrack", [
      "Float Property OfferCooldownDays = 7.0 Auto",
      "Float Property TransitionLockoutDays = 7.0 Auto",
      "Int Function GetOfferedState()",
      "Int Function GetPendingState()",
      "Function OfferTransition(Int newState, String reason)",
      "Function AcceptOfferedTransition(String reason)",
      "Function RefuseOfferedTransition(String reason)",
      "Function ConfirmPendingTransition(String reason)",
      "Function CancelPendingTransition(String reason)",
      "Function RecordEvidenceDay(Int stateValue, String reason)",
      "Int Function GetRecentEvidenceDayCount(Int stateValue, Int windowDays)",
      "Bool Function HasRecentEvidenceDays(Int stateValue, Int requiredCount, Int windowDays)",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_DeityBase", [
      "PDV_StateTrack Property EligibleStateTrack Auto",
      "Int[] Property EligibleStateValues Auto",
      "Float Property InactivePathGainMultiplier = 0.25 Auto",
      "Float Function GetEligibilityGainMultiplier()",
      "Bool Function IsEligibleForPlayer()",
      "Bool Function IsEligibleForState(Int currentState)",
      "Int Function GetTierCap()",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV__ManagerQuest", [
      "Function EnsureBosmerRuntimeWiring()",
      "Function EnsureBosmerSetupChoice()",
      "Function ApplyBosmerInitialChoice(Int pathState, String reason)",
      "Function EnterBosmerOldContract(Bool isStartupChoice, String reason)",
      "Function ExitBosmerOldContract(Bool countLapse, String reason)",
      "Function EvaluateBosmerForcedReckoning()",
      "Function EvaluateBosmerPathSuggestion()",
      "Function ConfirmBosmerPendingTransition(String reason)",
      "Function CanConfirmBosmerPathState(Int targetState)",
      "Function RestoreActiveDeityFromStoredPatron()",
      "return originRace == ORIGIN_KHAJIIT || originRace == ORIGIN_BOSMER",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_EventBus", [
      "Function RouteBosmerLivingStory()",
      "Function RouteBosmerExchange()",
      "Function RouteBosmerBanditRoad()",
      "Function RouteBosmerPactPositive()",
      "Function RouteStateTransitionConfirmationRite()",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_EventTypes", [
      "EVT_BOSMER_LIVING_STORY = 41",
      "EVT_BOSMER_EXCHANGE = 42",
      "EVT_BOSMER_BANDIT_ROAD = 43",
      "EVT_BOSMER_PACT_POSITIVE = 44",
      "EVT_STATE_TRANSITION_CONFIRM_RITE = 45",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_EventSignalActivator", [
      "Int Property ROUTE_BOSMER_LIVING_STORY = 41 AutoReadOnly",
      "Int Property ROUTE_BOSMER_EXCHANGE = 42 AutoReadOnly",
      "Int Property ROUTE_BOSMER_BANDIT_ROAD = 43 AutoReadOnly",
      "Int Property ROUTE_BOSMER_PACT_POSITIVE = 44 AutoReadOnly",
      "Int Property ROUTE_STATE_TRANSITION_CONFIRM_RITE = 45 AutoReadOnly",
      "PDV_EventBusService.RouteBosmerLivingStory()",
      "PDV_EventBusService.RouteBosmerExchange()",
      "PDV_EventBusService.RouteBosmerBanditRoad()",
      "PDV_EventBusService.RouteBosmerPactPositive()",
      "PDV_EventBusService.RouteStateTransitionConfirmationRite()",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_EventSignalEffect", [
      "Int Property ROUTE_BOSMER_LIVING_STORY = 41 AutoReadOnly",
      "Int Property ROUTE_BOSMER_EXCHANGE = 42 AutoReadOnly",
      "Int Property ROUTE_BOSMER_BANDIT_ROAD = 43 AutoReadOnly",
      "Int Property ROUTE_BOSMER_PACT_POSITIVE = 44 AutoReadOnly",
      "Int Property ROUTE_STATE_TRANSITION_CONFIRM_RITE = 45 AutoReadOnly",
      "PDV_EventBusService.RouteBosmerLivingStory()",
      "PDV_EventBusService.RouteBosmerExchange()",
      "PDV_EventBusService.RouteBosmerBanditRoad()",
      "PDV_EventBusService.RouteBosmerPactPositive()",
      "PDV_EventBusService.RouteStateTransitionConfirmationRite()",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_MCM", [
      "Bosmer Living Story",
      "Bosmer Exchange",
      "Bosmer Bandit Road",
      "Bosmer Pact-positive",
      "Bosmer confirm rite",
      "RouteStateTransitionConfirmationRite()",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_Deity_Yffre", [
      "SIGNAL_PACT_POSITIVE = 301",
      "SIGNAL_LIVING_STORY = 302",
      "SIGNAL_PACT_VIOLATION = 303",
      "SIGNAL_RECOMMITMENT = 304",
      "SIGNAL_SHARED_PACT_MEMORY = 305",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_Deity_Zen", [
      "SIGNAL_EXCHANGE = 401",
      "SIGNAL_SHARED_PACT_MEMORY = 402",
      "SIGNAL_CONFIRMATION = 403",
    ], this.phase9Gap.bind(this));
    this.checkSourceContains("Phase 9 source", "PDV_Deity_BaanDar", [
      "SIGNAL_BANDIT_ROAD = 501",
      "SIGNAL_SHARED_PACT_MEMORY = 502",
      "SIGNAL_CONFIRMATION = 503",
    ], this.phase9Gap.bind(this));
  }

  checkPhase10SourceContracts() {
    this.checkSourceContains("Phase 10 source", "PDV_Substrate_DunmerAncestor", [
      "Function RecordPortableShrinePrayerScaled(Float multiplier, String reason)",
      "Function RecordPlayerHomeBonusScaled(Float multiplier, String reason)",
      "\"PDV.Substrate.DunmerAncestor.PrayerCount\"",
      "\"PDV.Substrate.DunmerAncestor.HomeCount\"",
      "String Function GetPilotSummary()",
      "Function ResetPilotForDebug()",
    ], this.phase10Gap.bind(this));
    this.checkSourceContains("Phase 10 source", "PDV__ManagerQuest", [
      "Function HandleDunmerPortableShrinePrayer(String reason)",
      "Function HandleDunmerPlayerHomeBonus(String reason)",
      "PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)",
      "PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)",
      "Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)",
      "PDV_Azura.SIGNAL_ANCESTOR_SPINE",
      "Function TryAwardDunmerTwilightWindowSignal(String reason)",
      "Function GetDunmerTwilightWindow(Float gameTime)",
      "PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE",
      "PDV.Signal.DunmerTwilight.",
      "String Function GetDunmerAncestorSummary()",
    ], this.phase10Gap.bind(this));
    this.checkSourceContains("Phase 10 Azura source", "PDV_Deity_Azura", [
      "SIGNAL_DUNMER_TWILIGHT_RITE = 704",
      "DELTA_DUNMER_TWILIGHT_RITE = 0.25",
      "return DELTA_DUNMER_TWILIGHT_RITE",
      "SIGNAL_ANCESTOR_SPINE = 705",
      "DELTA_ANCESTOR_SPINE = 1.0",
      "return DELTA_ANCESTOR_SPINE",
    ], this.phase10Gap.bind(this));
    this.checkSourceContains("Phase 10 source", "PDV_EventBus", [
      "Function RouteDunmerPortableShrinePrayer()",
      "Function RouteDunmerPlayerHomeBonus()",
      "PDV_Manager.HandleDunmerPortableShrinePrayer(\"eventbus_\" + eventType)",
      "PDV_Manager.HandleDunmerPlayerHomeBonus(\"eventbus_\" + eventType)",
    ], this.phase10Gap.bind(this));
    this.checkSourceContains("Phase 10 source", "PDV_EventSignalActivator", [
      "PDV_EventBusService.RouteDunmerPortableShrinePrayer()",
      "PDV_EventBusService.RouteDunmerPlayerHomeBonus()",
    ], this.phase10Gap.bind(this));
  }

  checkKhajiitSourceContracts() {
    this.checkSourceContains("Khajiit source", "PDV__ManagerQuest", [
      "GlobalVariable Property PDV_GLO_KhajiitFocusedEmphasis Auto",
      "KHAJIIT_FOCUS_KHENARTHI = 1",
      "KHAJIIT_FOCUS_AZURAH = 2",
      "KHAJIIT_FOCUS_THRESHOLD = 50.0",
      "KHAJIIT_FOCUS_LEAD_REQUIRED = 15.0",
      "Function AdjustKhajiitFocusedEmphasis(Int focusValue, Float amount, String reason)",
      "Function EvaluateKhajiitFocusedEmphasis()",
      "Function SetKhajiitFocusedEmphasis(Int focusValue, String reason)",
      "PDV_GLO_KhajiitFocusedEmphasis.SetValue(focusValue as Float)",
      "AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_AZURAH",
      "AdjustKhajiitFocusedEmphasis(KHAJIIT_FOCUS_KHENARTHI",
      "focus=",
    ], this.khajiitGap.bind(this));
    this.checkSourceContains("Khajiit source", "PDV_MCM", [
      "Khajiit moon observance",
      "Khajiit road-home cadence",
      "RouteKhajiitMoonObservance(0)",
      "RouteKhajiitRoadHome()",
    ], this.khajiitGap.bind(this));
  }

  checkCommitmentSourceContracts() {
    this.checkSourceContains("Commitment source", "PDV__ManagerQuest", [
      "Float Property COMMITMENT_OFFER_THRESHOLD = 50.0 AutoReadOnly",
      "Float Property COMMITMENT_CARRYOVER_MULTIPLIER = 0.7 AutoReadOnly",
      "Function EvaluateKyneCommitmentOffer()",
      "HasRecentCommitmentSignalDays(PDV_Kyne, 2, 7)",
      "Function DebugAcceptPendingCommitment()",
      "Function DebugDeclinePendingCommitment()",
      "Function DebugRefusePendingCommitment()",
      "StorageUtil.SetFloatValue(None, \"PDV.Commitment.LastCarryover\", carryAmount)",
      "return originRace == ORIGIN_KHAJIIT || originRace == ORIGIN_BOSMER",
    ], this.commitmentGap.bind(this));
    this.checkSourceContains("Commitment source", "PDV_MCM", [
      "Evaluate commitment",
      "Accept commitment",
      "Decline commitment",
      "Refuse commitment",
    ], this.commitmentGap.bind(this));
  }

  checkNeglectDecaySourceContracts() {
    this.checkSourceContains("Neglect/decay source", "PDV__ManagerQuest", [
      "Spell Property PDV_SPEL_Neglect_Kyne Auto",
      "Function RunDawnApplyDecay()",
      "Function ApplyDecayToDeity(PDV_DeityBase deity, Float nowTime)",
      "StorageUtil.GetIntValue(deityForm, \"PDV.LastDecayAppliedDay\") == currentDay",
      "BROAD_WORSHIP_DECAY_MULTIPLIER",
      "Function RunDawnApplySpellAndNeglectLayers()",
      "GetPatronState() != PATRON_STATE_ACTIVE",
      "Function SyncKyneNeglectSpell(Bool shouldBeActive)",
      "playerRef.AddSpell(PDV_SPEL_Neglect_Kyne, False)",
      "playerRef.RemoveSpell(PDV_SPEL_Neglect_Kyne)",
      "PDV.Neglect.KyneSpellActive",
      "String Function GetNeglectSummary()",
    ], this.neglectDecayGap.bind(this));
  }

  checkSourceContains(checkName, scriptName, snippets, gapFn = null) {
    const reportGap = gapFn || this.fail.bind(this);
    const source = path.join(DEVOTION_SOURCE, `${scriptName}.psc`);
    if (!exists(source)) {
      reportGap(checkName, `${scriptName}.psc is missing.`, source);
      return;
    }

    const text = fs.readFileSync(source, "utf8");
    for (const snippet of snippets) {
      if (text.includes(snippet)) {
        this.pass(checkName, `${scriptName}.psc contains ${snippet}.`, source);
      } else {
        reportGap(checkName, `${scriptName}.psc is missing ${snippet}.`, source);
      }
    }
  }

  checkSourceNotContains(checkName, scriptName, snippets, gapFn = null) {
    const reportGap = gapFn || this.fail.bind(this);
    const source = path.join(DEVOTION_SOURCE, `${scriptName}.psc`);
    if (!exists(source)) {
      reportGap(checkName, `${scriptName}.psc is missing.`, source);
      return;
    }

    const text = fs.readFileSync(source, "utf8");
    for (const snippet of snippets) {
      if (text.includes(snippet)) {
        reportGap(checkName, `${scriptName}.psc still contains ${snippet}.`, source);
      } else {
        this.pass(checkName, `${scriptName}.psc does not contain ${snippet}.`, source);
      }
    }
  }

  checkSmallSignalTables() {
    const managerSource = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
    if (!exists(managerSource)) {
      this.fail("Small-signal table source", "PDV__ManagerQuest.psc is missing.", managerSource);
      return;
    }
    if (!exists(DEITY_LIKES_DISLIKES_CSV)) {
      this.fail("Small-signal table source", "PDV_DeityLikesDislikes.csv is missing.", DEITY_LIKES_DISLIKES_CSV);
      return;
    }
    if (!exists(PRINCE_LIKES_DISLIKES_CSV)) {
      this.fail("Small-signal table source", "PDV_DeityLikesDislikes_Princes_V2.csv is missing.", PRINCE_LIKES_DISLIKES_CSV);
      return;
    }

    const sourceText = fs.readFileSync(managerSource, "utf8");
    const deityGenerated = buildLikesDislikesFunction(DEITY_LIKES_DISLIKES_CSV, {
      functionName: "LoadRowsForDeity",
      argumentType: "PDV_DeityBase",
      argumentName: "deity",
      nameSource: "deity.DeityName",
      writerName: "WriteLD",
      stripPrefix: null,
      originGate: true,
    });
    const princeGenerated = buildLikesDislikesFunction(PRINCE_LIKES_DISLIKES_CSV, {
      functionName: "LoadPrinceRowsForPath",
      argumentType: "PDV_DaedricPathBase",
      argumentName: "path",
      nameSource: "path.DeityName",
      writerName: "WritePLD",
      stripPrefix: "Daedric:",
    });

    this.checkSourceContains("Small-signal table versions", "PDV__ManagerQuest", [
      `Int Property LIKES_DISLIKES_VERSION = ${EXPECTED_LIKES_DISLIKES_VERSION} AutoReadOnly`,
      `Int Property PRINCE_LD_VERSION = ${EXPECTED_PRINCE_LD_VERSION} AutoReadOnly`,
    ]);
    this.checkGeneratedFunction(
      "Small-signal deity table",
      sourceText,
      managerSource,
      deityGenerated,
      "LoadRowsForDeity",
      "WriteLD",
      "deities",
    );
    this.checkGeneratedFunction(
      "Small-signal Prince table",
      sourceText,
      managerSource,
      princeGenerated,
      "LoadPrinceRowsForPath",
      "WritePLD",
      "paths",
    );
    this.checkLikesDislikesClearSuperset(sourceText, managerSource, deityGenerated.eventIds);
  }

  checkGeneratedFunction(checkName, sourceText, managerSource, generated, functionName, writerName, actorLabel) {
    const liveFunction = extractPapyrusFunction(sourceText, functionName);
    if (!liveFunction) {
      this.fail(checkName, `${functionName} is missing from the deployed manager.`, managerSource);
      return;
    }

    const liveRows = countOccurrences(liveFunction, `${writerName}(`);
    const liveActors = countOccurrences(liveFunction, "ldName ==");
    if (liveRows === generated.rowCount && liveActors === generated.actorCount) {
      this.pass(checkName, `${functionName} has ${generated.actorCount} ${actorLabel} and ${generated.rowCount} row(s).`, managerSource);
    } else {
      this.fail(
        checkName,
        `${functionName} has ${liveActors} ${actorLabel}/${liveRows} row(s), expected ${generated.actorCount}/${generated.rowCount}.`,
        managerSource,
      );
    }

    if (normalizeSourceBlock(liveFunction) === normalizeSourceBlock(generated.source)) {
      this.pass(checkName, `${functionName} matches the current CSV-generated body exactly.`, managerSource);
    } else {
      this.fail(checkName, `${functionName} differs from the current CSV-generated body; rerun the generator onto the deployed manager.`, managerSource);
    }
  }

  checkLikesDislikesClearSuperset(sourceText, managerSource, eventIds) {
    const clearFunction = extractPapyrusFunction(sourceText, "GetLikesDislikesEventTypes");
    if (!clearFunction) {
      this.fail("Small-signal deity clear superset", "GetLikesDislikesEventTypes is missing from the deployed manager.", managerSource);
      return;
    }

    const clearIds = new Set([...clearFunction.matchAll(/ldEvents\[\d+\]\s*=\s*(\d+)/g)].map((match) => Number(match[1])));
    const missing = [...eventIds].filter((eventId) => !clearIds.has(eventId)).sort((a, b) => a - b);
    if (missing.length === 0) {
      this.pass("Small-signal deity clear superset", `GetLikesDislikesEventTypes covers all ${eventIds.size} CSV event id(s).`, managerSource);
    } else {
      this.fail(
        "Small-signal deity clear superset",
        `GetLikesDislikesEventTypes is missing CSV event id(s): ${missing.join(", ")}.`,
        managerSource,
      );
    }
  }

  checkSeq() {
    const hasXeditSeq = exists(XEDIT_SEQ);
    const hasDevotionSeq = exists(DEVOTION_SEQ);

    if (hasXeditSeq) {
      this.pass("SEQ file", "xEdit output SEQ exists.", XEDIT_SEQ);
      if (exists(PDV_ESP) && mtimeMs(XEDIT_SEQ) < mtimeMs(PDV_ESP)) {
        this.warn("SEQ freshness", "xEdit output SEQ is older than the ESP.", XEDIT_SEQ);
      }
    } else if (hasDevotionSeq) {
      this.info(
        "SEQ file",
        "xEdit output SEQ is absent, but the generated SEQ already exists in Devotion.",
        XEDIT_SEQ,
      );
    } else {
      this.warn("SEQ file", "xEdit output SEQ is missing.", XEDIT_SEQ);
    }

    if (hasDevotionSeq) {
      this.pass("SEQ file", "Devotion mod SEQ exists.", DEVOTION_SEQ);
      if (exists(PDV_ESP) && mtimeMs(DEVOTION_SEQ) < mtimeMs(PDV_ESP)) {
        this.warn("SEQ freshness", "Devotion mod SEQ is older than the ESP.", DEVOTION_SEQ);
      }
    } else {
      this.warn(
        "SEQ location",
        "No SEQ file found inside the Devotion mod. Current workflow may rely on Anvil - xEdit Output.",
        DEVOTION_SEQ,
      );
    }
  }

  checkProfile() {
    const pluginsTxt = DEV_PROFILE_PLUGINS;
    const loadorderTxt = DEV_PROFILE_LOADORDER;

    if (!exists(pluginsTxt)) {
      this.warn("MO2 profile", "plugins.txt missing.", pluginsTxt);
      return;
    }

    const pluginsLines = readLines(pluginsTxt);
    const activeLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === "devotion.esp");
    if (activeLine === "*Devotion.esp") {
      this.pass("MO2 profile", "Devotion.esp is active in Devotion Dev.", pluginsTxt);
    } else if (activeLine) {
      this.warn("MO2 profile", `Devotion.esp is present but not active: ${activeLine}`, pluginsTxt);
    } else {
      this.fail("MO2 profile", "Devotion.esp is missing from plugins.txt.", pluginsTxt);
    }

    for (const patchName of RETIRED_OVERLAY_PATCHES) {
      const patchLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === patchName.toLowerCase());
      if (patchLine === `*${patchName}`) {
        this.warn(
          "Retired overlay patch",
          `${patchName} is still active. Its VMAD data has been merged back into Devotion.esp, so leave it unticked.`,
          pluginsTxt,
        );
      } else if (patchLine) {
        this.pass("Retired overlay patch", `${patchName} is present but inactive.`, pluginsTxt);
      }
    }

    const oneOffPatchLines = pluginsLines.filter((line) => {
      const normalized = line.replace(/^\*/, "");
      return normalized.toLowerCase().startsWith(ONE_OFF_AUTHOR_PATCH_PREFIX.toLowerCase())
        && normalized.toLowerCase().endsWith(".esp");
    });
    for (const patchLine of oneOffPatchLines) {
      const patchName = patchLine.replace(/^\*/, "");
      if (patchLine.startsWith("*")) {
        this.warn(
          "One-off author patch",
          `${patchName} is active. Prefer the manifest-driven ${CANONICAL_PROPERTY_WIRING_PATCH} batch overlay so Devotion Dev does not accumulate per-property VMAD patches.`,
          pluginsTxt,
        );
      } else {
        this.info("One-off author patch", `${patchName} is present but inactive.`, pluginsTxt);
      }
    }

    const propertyWiringLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === CANONICAL_PROPERTY_WIRING_PATCH.toLowerCase());
    if (propertyWiringLine === `*${CANONICAL_PROPERTY_WIRING_PATCH}`) {
      this.pass("Property wiring overlay", `${CANONICAL_PROPERTY_WIRING_PATCH} is active as the canonical batch overlay.`, pluginsTxt);
    } else if (propertyWiringLine) {
      this.info("Property wiring overlay", `${CANONICAL_PROPERTY_WIRING_PATCH} is present but inactive.`, pluginsTxt);
    }

    const preflightOverlayPath = path.join(DEVOTION_MOD, PREFLIGHT_ROUTER_OVERLAY_PATCH);
    const canAssessPreflightRecords = this.recordsByEdid.size > 0;
    const hasEventBusRecord = this.recordsByEdid.has("PDV_EventBus");
    const hasEventTypesRecord = this.recordsByEdid.has("PDV_EventTypes");
    const requireOverlayCanary = canAssessPreflightRecords && (!hasEventBusRecord || !hasEventTypesRecord);
    const preflightOverlayLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === PREFLIGHT_ROUTER_OVERLAY_PATCH.toLowerCase());
    if (preflightOverlayLine === `*${PREFLIGHT_ROUTER_OVERLAY_PATCH}`) {
      this.pass("Preflight router overlay", `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is active in Devotion Dev.`, pluginsTxt);
    } else if (preflightOverlayLine) {
      if (requireOverlayCanary) {
        this.preflightGap(
          "Preflight router overlay",
          `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is present but inactive while framework-owned EventBus/EventTypes records are still missing.`,
          pluginsTxt,
        );
      } else {
        this.info("Preflight router overlay", `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is present but inactive.`, pluginsTxt);
      }
    } else if (exists(preflightOverlayPath)) {
      if (requireOverlayCanary) {
        this.preflightGap(
          "Preflight router overlay",
          `${PREFLIGHT_ROUTER_OVERLAY_PATCH} exists on disk but is not listed in plugins.txt yet.`,
          pluginsTxt,
        );
      } else {
        this.info(
          "Preflight router overlay",
          `${PREFLIGHT_ROUTER_OVERLAY_PATCH} exists on disk but is not listed in plugins.txt yet.`,
          pluginsTxt,
        );
      }
    } else if (requireOverlayCanary) {
      this.preflightGap(
        "Preflight router overlay",
        `${PREFLIGHT_ROUTER_OVERLAY_PATCH} is missing from disk and plugins.txt while framework-owned EventBus/EventTypes records are still missing.`,
        pluginsTxt,
      );
    }

    if (exists(loadorderTxt)) {
      const loadorder = readLines(loadorderTxt).filter((line) => line.trim() && !line.startsWith("#"));
      if (loadorder.at(-1)?.toLowerCase() === "devotion.esp") {
        this.pass("MO2 load order", "Devotion.esp is last in loadorder.txt.", loadorderTxt);
      } else if (loadorder.some((line) => line.toLowerCase() === "devotion.esp")) {
        this.info("MO2 load order", "Devotion.esp is active but not last in loadorder.txt.", loadorderTxt);
      }
    } else {
      this.warn("MO2 profile", "loadorder.txt missing.", loadorderTxt);
    }

    if (exists(MO2_INI)) {
      const ini = fs.readFileSync(MO2_INI, "utf8");
      if (ini.includes("selected_profile=@ByteArray(Devotion Dev)")) {
        this.pass("MO2 selected profile", "ModOrganizer.ini selected profile is Devotion Dev.", MO2_INI);
      } else {
        this.warn("MO2 selected profile", "Could not confirm selected profile is Devotion Dev.", MO2_INI);
      }
    }
  }

  checkShadowOutputs() {
    if (!exists(CK_OUTPUT)) {
      this.info("CK output", "Anvil - Creation Kit Output mod is missing.", CK_OUTPUT);
      return;
    }

    const found = [];
    for (const filePath of walk(CK_OUTPUT)) {
      const base = path.basename(filePath).toLowerCase();
      if (
        (base.startsWith("pdv") || base.startsWith("qf_pdv")) &&
        (base.endsWith(".psc") || base.endsWith(".pex"))
      ) {
        found.push(filePath);
      }
    }

    if (found.length) {
      this.warn("CK output shadow files", `Potential shadow files found: ${found.sort().join(", ")}`, CK_OUTPUT);
    } else {
      this.pass("CK output shadow files", "No PDV/QF shadow scripts found.", CK_OUTPUT);
    }
  }

  async checkMcpServer() {
    const endpoint = `${MO2_MCP_HOST}:${MO2_MCP_PORT}`;
    const accepting = await canConnect(MO2_MCP_HOST, MO2_MCP_PORT, 500);
    if (accepting) {
      this.info("MO2 MCP server", `Server is accepting connections on ${endpoint}.`);
    } else {
      this.info("MO2 MCP server", `Server is not currently accepting connections on ${endpoint}.`);
    }
  }

  counts() {
    const result = {};
    for (const finding of this.findings) {
      result[finding.status] = (result[finding.status] || 0) + 1;
    }
    return result;
  }
}

function findScripts(fields, name) {
  const vmad = fields.VirtualMachineAdapter || {};
  return (vmad.Scripts || []).filter((script) => script.Name === name);
}

function findScript(fields, name) {
  const matches = findScripts(fields, name);
  if (!matches.length) {
    return null;
  }
  if (matches.length === 1) {
    return matches[0];
  }

  return {
    ...matches.at(-1),
    Properties: matches.flatMap((script) => script.Properties || []),
  };
}

function findQuestAlias(fields, aliasName) {
  return (fields.Aliases || []).find((alias) => alias.Name === aliasName) || null;
}

function findAliasScript(fields, aliasId, scriptName) {
  const vmad = fields.VirtualMachineAdapter || {};
  const matches = (vmad.Aliases || [])
    .filter((aliasEntry) => Number(aliasEntry?.Property?.Alias) === Number(aliasId))
    .flatMap((aliasEntry) => (aliasEntry.Scripts || []).filter((script) => script.Name === scriptName));

  if (!matches.length) {
    return null;
  }
  if (matches.length === 1) {
    return matches[0];
  }

  return {
    ...matches.at(-1),
    Properties: matches.flatMap((script) => script.Properties || []),
  };
}

function propertyMap(script) {
  return new Map((script.Properties || []).filter((prop) => prop.Name).map((prop) => [prop.Name, prop]));
}

function propValue(prop) {
  if (!prop) {
    return null;
  }
  if (Object.hasOwn(prop, "Data")) {
    return prop.Data;
  }
  if (Object.hasOwn(prop, "Object")) {
    return prop.Object;
  }
  return null;
}

function objectEdid(prop, recordsByEdid) {
  const formid = prop.Object;
  if (!formid) {
    return null;
  }
  return formidToEdid(formid, recordsByEdid);
}

function formidToEdid(formid, recordsByEdid) {
  for (const [edid, record] of recordsByEdid.entries()) {
    if (record.formid === formid) {
      return edid;
    }
  }
  return null;
}

function formidsEqual(left, right) {
  const normalizedLeft = normalizeFormidToken(left);
  const normalizedRight = normalizeFormidToken(right);
  return Boolean(normalizedLeft && normalizedRight && normalizedLeft === normalizedRight);
}

function normalizeFormidToken(value) {
  if (!value || typeof value !== "string" || !value.includes(":")) {
    return null;
  }

  const [first, second] = value.split(":");
  if (!first || !second) {
    return null;
  }

  if (/^[0-9a-f]{6}$/i.test(first)) {
    return `${second.toLowerCase()}:${first.toUpperCase()}`;
  }

  if (/^[0-9a-f]{6}$/i.test(second)) {
    return `${first.toLowerCase()}:${second.toUpperCase()}`;
  }

  return value.toLowerCase();
}

function extractFormidsFromArrayProperty(prop) {
  if (!prop) {
    return [];
  }

  const raw = Array.isArray(prop.Objects)
    ? prop.Objects
    : Array.isArray(prop.Data)
      ? prop.Data
      : [];

  return raw
    .map((entry) => {
      if (typeof entry === "string") {
        return entry;
      }
      if (entry && typeof entry === "object" && typeof entry.Object === "string") {
        return entry.Object;
      }
      return null;
    })
    .filter(Boolean);
}

function extractNumericArrayProperty(prop) {
  if (!prop) {
    return [];
  }

  const raw = Array.isArray(prop.Datas)
    ? prop.Datas
    : Array.isArray(prop.Data)
      ? prop.Data
      : [];

  return raw
    .map((entry) => {
      if (typeof entry === "number") {
        return entry;
      }
      if (entry && typeof entry === "object" && typeof entry.Data === "number") {
        return entry.Data;
      }
      return null;
    })
    .filter((value) => typeof value === "number");
}

function extractStringArrayProperty(prop) {
  if (!prop) {
    return [];
  }

  const raw = Array.isArray(prop.Strings)
    ? prop.Strings
    : Array.isArray(prop.Data)
      ? prop.Data
      : [];

  return raw
    .map((entry) => {
      if (typeof entry === "string") {
        return entry;
      }
      if (entry && typeof entry === "object" && typeof entry.Data === "string") {
        return entry.Data;
      }
      return null;
    })
    .filter((value) => typeof value === "string");
}

function findFirstScript(fields, scriptNames) {
  for (const scriptName of scriptNames) {
    const script = findScript(fields, scriptName);
    if (script) {
      return script;
    }
  }
  return null;
}

function valuesEqual(actual, expected) {
  if (typeof actual === "number" && typeof expected === "number") {
    return Math.abs(actual - expected) < 0.0001;
  }
  return actual === expected;
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function normalizeStringList(values) {
  if (!Array.isArray(values)) {
    return [];
  }
  return values
    .map((value) => {
      if (typeof value === "string") {
        return value;
      }
      if (value && typeof value === "object") {
        return value.Object || value.FormKey || value.FormId || value.formid || null;
      }
      return null;
    })
    .filter(Boolean);
}

function mtimeMs(filePath) {
  return fs.statSync(filePath).mtimeMs;
}

function findStraySkyuiOutputs() {
  if (!exists(DEVOTION_PEX)) {
    return [];
  }

  return fs.readdirSync(DEVOTION_PEX)
    .filter((name) => /^SKI_.*\.pex$/i.test(name))
    .sort();
}

function readLines(filePath) {
  return fs.readFileSync(filePath, "utf8").split(/\r?\n/);
}

function buildLikesDislikesFunction(csvPath, options) {
  const lines = fs.readFileSync(csvPath, "utf8").split(/\r?\n/).filter((line) => line.trim().length > 0);
  const header = lines.shift().split(",").map((col) => col.trim());
  const actorIndex = requiredCsvColumn(header, "actor", csvPath);
  const eventIdIndex = requiredCsvColumn(header, "eventId", csvPath);
  const deltaIndex = requiredCsvColumn(header, "baseDelta", csvPath);
  const dailyCapIndex = requiredCsvColumn(header, "dailyCap", csvPath);
  const cooldownIndex = requiredCsvColumn(header, "cooldownDays", csvPath);
  const originGateIndex = options.originGate ? requiredCsvColumn(header, "originGate", csvPath) : -1;

  const order = [];
  const byActor = new Map();
  const eventIds = new Set();
  lines.forEach((line, lineIndex) => {
    const cols = line.split(",");
    let actor = String(cols[actorIndex] || "").trim();
    if (options.stripPrefix && actor.startsWith(options.stripPrefix)) {
      actor = actor.slice(options.stripPrefix.length).trim();
    }
    const eventId = String(cols[eventIdIndex] || "").trim();
    const delta = String(cols[deltaIndex] || "").trim();
    const dailyCap = String(cols[dailyCapIndex] || "").trim();
    const cooldown = String(cols[cooldownIndex] || "").trim();
    const originGate = options.originGate ? originGateValue(cols[originGateIndex], lineIndex + 2, csvPath) : -1;
    if (!actor || !eventId) {
      return;
    }
    if (!byActor.has(actor)) {
      byActor.set(actor, []);
      order.push(actor);
    }
    byActor.get(actor).push({ eventId, delta, dailyCap, cooldown, originGate });
    eventIds.add(Number(eventId));
  });

  const out = [];
  out.push(`Function ${options.functionName}(${options.argumentType} ${options.argumentName})`);
  out.push(`    String ldName = ${options.nameSource}`);
  order.forEach((actor, index) => {
    const keyword = index === 0 ? "if" : "elseIf";
    out.push(`    ${keyword} ldName == "${actor}"`);
    for (const row of byActor.get(actor)) {
      if (options.originGate) {
        out.push(
          `        ${options.writerName}(${options.argumentName}, ${row.eventId}, ${papyrusFloat(row.delta)}, ${row.dailyCap}, ${papyrusFloat(row.cooldown)}, ${row.originGate})`,
        );
      } else {
        out.push(
          `        ${options.writerName}(${options.argumentName}, ${row.eventId}, ${papyrusFloat(row.delta)}, ${row.dailyCap}, ${papyrusFloat(row.cooldown)})`,
        );
      }
    }
  });
  out.push("    endIf");
  out.push("EndFunction");

  return {
    source: out.join("\n"),
    actorCount: order.length,
    rowCount: lines.length,
    eventIds,
  };
}

function requiredCsvColumn(header, name, csvPath) {
  const index = header.indexOf(name);
  if (index < 0) {
    throw new Error(`${csvPath} missing required column ${name}`);
  }
  return index;
}

function originGateValue(rawValue, lineNumber, csvPath) {
  const token = String(rawValue || "").trim().toLowerCase();
  const origins = new Map([
    ["", -1],
    ["nord", 0],
    ["imperial", 1],
    ["breton", 2],
    ["altmer", 3],
    ["bosmer", 4],
    ["dunmer", 5],
    ["khajiit", 6],
    ["argonian", 7],
    ["saxhleel", 7],
    ["orc", 8],
    ["orsimer", 8],
    ["redguard", 9],
    ["yokudan", 9],
  ]);
  if (!origins.has(token)) {
    throw new Error(`${csvPath}:${lineNumber} unknown originGate ${rawValue}`);
  }
  return origins.get(token);
}

function papyrusFloat(value) {
  const text = String(value).trim();
  return text.includes(".") ? text : `${text}.0`;
}

function extractPapyrusFunction(sourceText, functionName) {
  const pattern = new RegExp(`^(?:[A-Za-z_][A-Za-z0-9_\\[\\]]*[ \\t]+)?Function[ \\t]+${escapeRegex(functionName)}\\([^\\r\\n]*\\)[\\s\\S]*?^EndFunction`, "m");
  const match = sourceText.match(pattern);
  return match ? match[0] : null;
}

function normalizeSourceBlock(text) {
  return String(text).replace(/\r\n/g, "\n").trim();
}

function countOccurrences(text, needle) {
  return String(text).split(needle).length - 1;
}

function escapeRegex(text) {
  return String(text).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function toPosix(filePath) {
  return filePath.replace(/\\/g, "/");
}

function* walk(root) {
  if (!exists(root)) {
    return;
  }
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      yield* walk(fullPath);
    } else {
      yield fullPath;
    }
  }
}

function canConnect(host, port, timeoutMs) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let settled = false;
    const finish = (value) => {
      if (settled) {
        return;
      }
      settled = true;
      socket.destroy();
      resolve(value);
    };
    socket.setTimeout(timeoutMs);
    socket.once("connect", () => finish(true));
    socket.once("timeout", () => finish(false));
    socket.once("error", () => finish(false));
    socket.connect(port, host);
  });
}

function printHuman(findings, counts) {
  console.log("PDV verifier");
  console.log(`Timestamp: ${localTimestamp()}`);
  console.log(
    `Summary: ${["FAIL", "WARN", "TODO", "PASS", "INFO"]
      .map((key) => `${key}=${counts[key] || 0}`)
      .join(", ")}`,
  );
  console.log();
  for (const finding of findings) {
    const location = finding.path ? ` [${finding.path}]` : "";
    console.log(`[${finding.status}] ${finding.check}: ${finding.detail}${location}`);
  }
}

function parseArgs(argv) {
  const args = {
    json: false,
    strictPhase3: false,
    strictPreflight: false,
    strictSkeleton: false,
    strictPatternProving: false,
    strictPhase7: false,
    strictPhase8: false,
    strictPhase9: false,
    strictPhase10: false,
    strictPhase11: false,
    strictPhase12: false,
    strictPhase13: false,
    strictPhase14: false,
    strictPhase15: false,
    strictPhase16: false,
    strictPhase17: false,
    strictPhase18: false,
    strictPhase19: false,
    strictPhase20Roster: false,
    strictPhase20Altmer: false,
    strictPhase20RaceCosting: false,
    strictNord: false,
    strictKhajiit: false,
    strictCommitment: false,
    strictNeglectDecay: false,
  };

  for (const arg of argv) {
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--strict-phase3") {
      args.strictPhase3 = true;
    } else if (arg === "--strict-preflight") {
      args.strictPreflight = true;
    } else if (arg === "--strict-skeleton") {
      args.strictSkeleton = true;
    } else if (arg === "--strict-pattern-proving") {
      args.strictPatternProving = true;
    } else if (arg === "--strict-phase7") {
      args.strictPhase7 = true;
    } else if (arg === "--strict-phase8") {
      args.strictPhase8 = true;
    } else if (arg === "--strict-phase9") {
      args.strictPhase9 = true;
    } else if (arg === "--strict-phase10") {
      args.strictPhase10 = true;
    } else if (arg === "--strict-phase11") {
      args.strictPhase11 = true;
    } else if (arg === "--strict-phase12") {
      args.strictPhase12 = true;
    } else if (arg === "--strict-phase13") {
      args.strictPhase13 = true;
    } else if (arg === "--strict-phase14") {
      args.strictPhase14 = true;
      args.strictCommitment = true;
    } else if (arg === "--strict-phase15") {
      args.strictPhase15 = true;
    } else if (arg === "--strict-phase16") {
      args.strictPhase16 = true;
    } else if (arg === "--strict-phase17") {
      args.strictPhase17 = true;
    } else if (arg === "--strict-phase18") {
      args.strictPhase18 = true;
    } else if (arg === "--strict-phase19") {
      args.strictPhase19 = true;
    } else if (arg === "--strict-phase20-roster" || arg === "--strict-phase21-roster") {
      args.strictPhase20Roster = true;
    } else if (arg === "--strict-phase20-altmer") {
      args.strictPhase20Altmer = true;
    } else if (arg === "--strict-phase20-race-costing") {
      args.strictPhase20RaceCosting = true;
    } else if (arg === "--strict-nord") {
      args.strictNord = true;
      args.strictPhase18 = true;
    } else if (arg === "--strict-khajiit") {
      args.strictKhajiit = true;
    } else if (arg === "--strict-commitment") {
      args.strictCommitment = true;
    } else if (arg === "--strict-neglect-decay") {
      args.strictNeglectDecay = true;
      args.strictPhase16 = true;
      args.strictPhase17 = true;
    } else if (arg === "-h" || arg === "--help") {
      console.log("Usage: node tools/pdv_verify.mjs [--json] [--strict-phase3] [--strict-preflight] [--strict-skeleton] [--strict-pattern-proving] [--strict-phase7] [--strict-phase8] [--strict-phase9] [--strict-phase10] [--strict-khajiit] [--strict-commitment] [--strict-neglect-decay] [--strict-phase11] [--strict-phase12] [--strict-phase13] [--strict-phase14] [--strict-phase15] [--strict-phase16] [--strict-phase17] [--strict-phase18] [--strict-phase19] [--strict-phase20-roster] [--strict-phase20-altmer] [--strict-phase20-race-costing] [--strict-nord]");
      process.exit(0);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }

  return args;
}

const args = parseArgs(process.argv.slice(2));
const verifier = new Verifier({
  strictPhase3: args.strictPhase3,
  strictPreflight: args.strictPreflight,
  strictSkeleton: args.strictSkeleton,
  strictPatternProving: args.strictPatternProving,
  strictPhase7: args.strictPhase7,
  strictPhase8: args.strictPhase8,
  strictPhase9: args.strictPhase9,
  strictPhase10: args.strictPhase10,
  strictPhase11: args.strictPhase11,
  strictPhase12: args.strictPhase12,
  strictPhase13: args.strictPhase13,
  strictPhase14: args.strictPhase14,
  strictPhase15: args.strictPhase15,
  strictPhase16: args.strictPhase16,
  strictPhase17: args.strictPhase17,
  strictPhase18: args.strictPhase18,
  strictPhase19: args.strictPhase19,
  strictPhase20Roster: args.strictPhase20Roster,
  strictPhase20Altmer: args.strictPhase20Altmer,
  strictPhase20RaceCosting: args.strictPhase20RaceCosting,
  strictNord: args.strictNord,
  strictKhajiit: args.strictKhajiit,
  strictCommitment: args.strictCommitment,
  strictNeglectDecay: args.strictNeglectDecay,
});
const findings = await verifier.run();
const counts = verifier.counts();

if (args.json) {
  console.log(
    JSON.stringify(
      {
        timestamp_utc: new Date().toISOString(),
        timestamp_local: localTimestamp(),
        counts,
        findings,
      },
      null,
      2,
    ),
  );
} else {
  printHuman(findings, counts);
}

process.exitCode = counts.FAIL ? 1 : 0;

function localTimestamp() {
  return new Date().toLocaleString(undefined, {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
    timeZoneName: "short",
  });
}
