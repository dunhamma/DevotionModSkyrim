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
const CK_OUTPUT = path.join(ANVIL_ROOT, "mods", "Anvil - Creation Kit Output");
const XEDIT_SEQ = path.join(
  ANVIL_ROOT,
  "mods",
  "Anvil - xEdit Output",
  "Seq",
  "PlayerDevotion_Framework.seq",
);
const DEVOTION_SEQ = path.join(DEVOTION_MOD, "Seq", "PlayerDevotion_Framework.seq");

const BASELINE_RECORDS = {
  PDV_GLO_ActivePiety: "GLOB",
  PDV_GLO_ActiveTier: "GLOB",
  PDV_GLO_ActiveDeityIndex: "GLOB",
  PDV_GLO_DebugLevel: "GLOB",
  PDV__ManagerQuest: "QUST",
  PDV_Deity_Kyne: "QUST",
  PDV_FLST_AllDeities: "FLST",
};

const PHASE3_RECORDS = {
  PDV_ActionRouter: "QUST",
  PDV__SM_KillActor: "QUST",
};

const COMPILED_SCRIPTS = {
  PDV__ManagerQuest: "required",
  PDV_DeityBase: "required",
  PDV_Deity_Kyne: "required",
  PDV_ActionRouter: "phase3",
  PDV__SM_KillActor: "phase3",
};

const MANAGER_PROPERTIES = {
  PDV_GLO_ActivePiety: "PDV_GLO_ActivePiety",
  PDV_GLO_ActiveTier: "PDV_GLO_ActiveTier",
  PDV_GLO_ActiveDeityIndex: "PDV_GLO_ActiveDeityIndex",
  PDV_GLO_DebugLevel: "PDV_GLO_DebugLevel",
  PDV_FLST_AllDeities: "PDV_FLST_AllDeities",
};

const KYNE_EXPECTED_DATA = {
  DeityName: "Kyne",
  DeityDomain: "Storms, Hunt, Warriors' Spirit",
  DeityIndex: 0,
  ThresholdSeeker: 10,
  ThresholdDevoted: 50,
  ThresholdChampion: 150,
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

const RECEIVER_PROPERTIES = {
  PDV_Router: "PDV_ActionRouter",
};

class Verifier {
  constructor({ strictPhase3 = false } = {}) {
    this.strictPhase3 = strictPhase3;
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

  async run() {
    this.checkPaths();
    if (exists(PDV_ESP) && exists(MUTAGEN_BRIDGE)) {
      this.loadRecordInventory();
      this.loadRecordDetails();
      this.checkRecordInventory();
      this.checkManagerRecord();
      this.checkKyneRecord();
      this.checkFormListRecord();
      this.checkPhase3Records();
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
  }

  checkManagerRecord() {
    const detail = this.recordDetails.get("PDV__ManagerQuest");
    if (!detail) {
      return;
    }

    const fields = detail.fields || {};
    const script = findScript(fields, "PDV__ManagerQuest");
    if (!script) {
      this.fail("Manager script", "PDV__ManagerQuest script is not attached.", PDV_ESP);
      return;
    }

    this.pass("Manager script", "PDV__ManagerQuest script is attached.", PDV_ESP);
    this.checkObjectProperties("Manager property", propertyMap(script), MANAGER_PROPERTIES);

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
  }

  checkFormListRecord() {
    const detail = this.recordDetails.get("PDV_FLST_AllDeities");
    const kyne = this.recordsByEdid.get("PDV_Deity_Kyne");
    if (!detail || !kyne) {
      return;
    }

    const items = detail.fields?.Items || [];
    if (items.includes(kyne.formid)) {
      this.pass("Deity FormList", "PDV_FLST_AllDeities contains PDV_Deity_Kyne.", PDV_ESP);
    } else {
      this.fail("Deity FormList", `PDV_FLST_AllDeities does not contain PDV_Deity_Kyne (${kyne.formid}).`, PDV_ESP);
    }
  }

  checkPhase3Records() {
    this.checkOptionalQuestScript("PDV_ActionRouter", "PDV_ActionRouter", ROUTER_PROPERTIES);
    this.checkOptionalQuestScript("PDV__SM_KillActor", "PDV__SM_KillActor", RECEIVER_PROPERTIES);

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

  checkObjectProperties(checkName, props, expectedProperties) {
    for (const [propName, expectedEdid] of Object.entries(expectedProperties)) {
      const prop = props.get(propName);
      if (!prop) {
        this.fail(checkName, `${propName} is missing.`, PDV_ESP);
        continue;
      }

      if (expectedEdid === null) {
        if (prop.Object || prop.Alias !== -1 || Object.hasOwn(prop, "Data")) {
          this.pass(checkName, `${propName} is assigned.`, PDV_ESP);
        } else {
          this.fail(checkName, `${propName} appears unassigned.`, PDV_ESP);
        }
        continue;
      }

      const actualEdid = objectEdid(prop, this.recordsByEdid);
      if (actualEdid === expectedEdid) {
        this.pass(checkName, `${propName} points at ${expectedEdid}.`, PDV_ESP);
      } else {
        this.fail(checkName, `${propName} points at ${actualEdid || prop.Object || "unassigned"}, expected ${expectedEdid}.`, PDV_ESP);
      }
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

    const mainSource = path.join(DEVOTION_SOURCE, "PDV__MainQuest.psc");
    const mainPex = path.join(DEVOTION_PEX, "PDV__MainQuest.pex");
    if (exists(mainSource) && !exists(mainPex)) {
      this.info(
        "MainQuest stub",
        "PDV__MainQuest.psc exists but no compiled .pex is present. This is informational unless the quest is reintroduced.",
        mainSource,
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
    const pluginsTxt = path.join(DEV_PROFILE, "plugins.txt");
    const loadorderTxt = path.join(DEV_PROFILE, "loadorder.txt");

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
    const accepting = await canConnect("127.0.0.1", 27015, 500);
    if (accepting) {
      this.info("MO2 MCP server", "Server is accepting connections on 127.0.0.1:27015.");
    } else {
      this.info("MO2 MCP server", "Server is not currently accepting connections on 127.0.0.1:27015.");
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

function findScript(fields, name) {
  const vmad = fields.VirtualMachineAdapter || {};
  return (vmad.Scripts || []).find((script) => script.Name === name) || null;
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
  for (const [edid, record] of recordsByEdid.entries()) {
    if (record.formid === formid) {
      return edid;
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
  };

  for (const arg of argv) {
    if (arg === "--json") {
      args.json = true;
    } else if (arg === "--strict-phase3") {
      args.strictPhase3 = true;
    } else if (arg === "-h" || arg === "--help") {
      console.log("Usage: node tools/pdv_verify.mjs [--json] [--strict-phase3]");
      process.exit(0);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }

  return args;
}

const args = parseArgs(process.argv.slice(2));
const verifier = new Verifier({ strictPhase3: args.strictPhase3 });
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
