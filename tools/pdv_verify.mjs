#!/usr/bin/env node
/*
 * Read-only verifier for the PlayerDevotion Anvil/MO2 development setup.
 *
 * The verifier checks disk files directly and asks the bundled MO2 MCP
 * Mutagen bridge to read PlayerDevotion_Framework.esp. It does not modify
 * the ESP, MO2 profile files, scripts, or generated output.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import net from "node:net";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const DEVOTION_SOURCE = path.join(DEVOTION_MOD, "Scripts", "Source");
const DEVOTION_PEX = path.join(DEVOTION_MOD, "Scripts");
const PDV_ESP = path.join(DEVOTION_MOD, "PlayerDevotion_Framework.esp");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
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
  "PlayerDevotion_Framework.seq",
);
const DEVOTION_SEQ = path.join(DEVOTION_MOD, "Seq", "PlayerDevotion_Framework.seq");
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
const PATCH_RULES_DIR = path.join(
  PROJECT_ROOT,
  "references",
  "authoring",
  "patch-rules",
);
const MANAGER_PATRON_WIRE_PATCH = "PDV_ManagerPatronWirePatch.esp";
const MCM_WIRE_PATCH = "PDV_MCMWirePatch.esp";
const RETIRED_OVERLAY_PATCHES = [MANAGER_PATRON_WIRE_PATCH, MCM_WIRE_PATCH];
const CANONICAL_PROPERTY_WIRING_PATCH = "PDV_PropertyWiringOverlay.esp";
const PREFLIGHT_ROUTER_OVERLAY_PATCH = "PDV_PreflightRouterServicesOverlay.esp";
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
};

const PREFLIGHT_RECORDS = {
  PDV_GLO_PatronState: "GLOB",
  PDV_EventTypes: "QUST",
  PDV_EventBus: "QUST",
};

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

const PHASE7_SIGNAL_RECEIVER_DEFINITIONS = [
  {
    recordEdid: "PDV_REFR_TalosShrineDefianceSignal",
    recordType: "REFR",
    scriptName: "PDV_EventSignalActivator",
    routeId: 35,
    requiredOriginRace: -1,
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
  PDV_DaedricPath_Hircine: "required",
  PDV_ActionRouter: "phase3",
  PDV__SM_KillActor: "phase3",
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
  ThresholdSeeker: 10,
  ThresholdDevoted: 50,
  ThresholdChampion: 150,
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
  PDV_HircinePath: "PDV_DaedricPath_Hircine",
  PDV_CurseStateService: "PDV_CurseState",
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
  } = {}) {
    this.strictPhase3 = strictPhase3;
    this.strictPreflight = strictPreflight;
    this.strictSkeleton = strictSkeleton;
    this.strictPatternProving = strictPatternProving;
    this.strictPhase7 = strictPhase7;
    this.findings = [];
    this.recordsByEdid = new Map();
    this.recordsByFormid = new Map();
    this.recordDetails = new Map();
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
      this.checkPhase7();
      this.checkOfflinePatcherRules();
      this.checkPreflightOverlayPatch();
    }
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
      "PlayerDevotion ESP": PDV_ESP,
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
      .map((record) => `${record.type} ${record.formid}`);
    if (unnamed.length) {
      this.warn("Unnamed records", `Records without EditorID found: ${unnamed.join(", ")}`, PDV_ESP);
    }
  }

  loadRecordDetails() {
    const wantedFormids = [...this.recordsByEdid.values()]
      .map((record) => record.formid)
      .filter(Boolean);
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

    const legacyHelper = this.recordsByEdid.get("PDV_ACTI_TalosShrineDefianceSignal");
    if (legacyHelper) {
      this.info(
        "Phase 7 legacy helper activator",
        "PDV_ACTI_TalosShrineDefianceSignal still exists. Preferred posture is script co-attachment on the real shrine reference, not a nearby helper ACTI.",
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
    if (actualEdid === expectedEdid) {
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

  checkRequiredArrayLength(checkName, recordEdid, propName, values, expectedLength) {
    if (!values.length) {
      this.patternGap(checkName, `${recordEdid}.${propName} is missing; expected length ${expectedLength}.`, PDV_ESP);
      return;
    }

    if (values.length === expectedLength) {
      this.pass(checkName, `${recordEdid}.${propName} length is ${expectedLength}.`, PDV_ESP);
    } else {
      this.patternGap(checkName, `${recordEdid}.${propName} length is ${values.length}, expected ${expectedLength}.`, PDV_ESP);
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
    this.checkOptionalQuestScript("PDV__SM_KillActor", "PDV__SM_KillActor", RECEIVER_PROPERTIES);
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
    if (routerScript && hasEventBusRecord && hasEventTypesRecord) {
      this.checkObjectProperties("PDV_ActionRouter preflight property", propertyMap(routerScript), ROUTER_PREFLIGHT_PROPERTIES);
    } else if (routerScript) {
      this.checkPreflightQuestScript("PDV_ActionRouter", "PDV_EventBus", EVENTBUS_OVERLAY_PROPERTIES);
      this.checkPreflightQuestScript("PDV_ActionRouter", "PDV_EventTypes", {});
      this.info("PDV_ActionRouter preflight property", "EventBus/EventTypes properties are script-ready; CK co-attachment or quest wiring is pending.", PDV_ESP);
    }

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
    this.checkPhase7SourceContracts();
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

  checkPhase7SourceContracts() {
    this.checkSourceContains("Phase 7 source", "PDV_PlayerEvents", [
      "PO3_Events_Alias.RegisterForShoutAttack(Self)",
      "Event OnShoutAttack(Shout akShout)",
      "PDV_EventBusService.RouteShoutAttack(GetActorRef(), akShout)",
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
      "AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None)",
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

  checkSourceContains(checkName, scriptName, snippets) {
    const source = path.join(DEVOTION_SOURCE, `${scriptName}.psc`);
    if (!exists(source)) {
      this.fail(checkName, `${scriptName}.psc is missing.`, source);
      return;
    }

    const text = fs.readFileSync(source, "utf8");
    for (const snippet of snippets) {
      if (text.includes(snippet)) {
        this.pass(checkName, `${scriptName}.psc contains ${snippet}.`, source);
      } else {
        this.fail(checkName, `${scriptName}.psc is missing ${snippet}.`, source);
      }
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
    const activeLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === "playerdevotion_framework.esp");
    if (activeLine === "*PlayerDevotion_Framework.esp") {
      this.pass("MO2 profile", "PlayerDevotion_Framework.esp is active in Devotion Dev.", pluginsTxt);
    } else if (activeLine) {
      this.warn("MO2 profile", `PlayerDevotion_Framework.esp is present but not active: ${activeLine}`, pluginsTxt);
    } else {
      this.fail("MO2 profile", "PlayerDevotion_Framework.esp is missing from plugins.txt.", pluginsTxt);
    }

    for (const patchName of RETIRED_OVERLAY_PATCHES) {
      const patchLine = pluginsLines.find((line) => line.replace(/^\*/, "").toLowerCase() === patchName.toLowerCase());
      if (patchLine === `*${patchName}`) {
        this.warn(
          "Retired overlay patch",
          `${patchName} is still active. Its VMAD data has been merged back into PlayerDevotion_Framework.esp, so leave it unticked.`,
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
      if (loadorder.at(-1)?.toLowerCase() === "playerdevotion_framework.esp") {
        this.pass("MO2 load order", "PlayerDevotion_Framework.esp is last in loadorder.txt.", loadorderTxt);
      } else if (loadorder.some((line) => line.toLowerCase() === "playerdevotion_framework.esp")) {
        this.info("MO2 load order", "PlayerDevotion_Framework.esp is active but not last in loadorder.txt.", loadorderTxt);
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
    } else if (arg === "-h" || arg === "--help") {
      console.log("Usage: node tools/pdv_verify.mjs [--json] [--strict-phase3] [--strict-preflight] [--strict-skeleton] [--strict-pattern-proving] [--strict-phase7]");
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
