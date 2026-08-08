#!/usr/bin/env node
/*
 * Read-only Phase 2 reward readback audit.
 *
 * Compares the per-race reward specs against the live framework ESP without
 * modifying the ESP, scripts, SEQ, or MO2 profile state.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { normalizeActorValue } from "./lib/pdv_actor_value_aliases.mjs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_phase2_reward_readback_audit" });

const ROOT = process.cwd();
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const DEVOTION_SEQ = path.join(DEVOTION_MOD, "Seq", "Devotion.seq");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const PLUGIN_NAME = "Devotion.esp";
const START_GAME_ENABLED_FLAG = 0x10;
const SPEC_FILES = [
  "PDV_ImperialRewardRecords.spec.json",
  "PDV_ArgonianRewardRecords.spec.json",
  "PDV_OrcRewardRecords.spec.json",
  "PDV_DunmerRewardRecords.spec.json",
  "PDV_AltmerRewardRecords.spec.json",
  "PDV_RedguardRewardRecords.spec.json",
  "PDV_NordRewardRecords.spec.json",
  "PDV_BosmerRewardRecords.spec.json",
  "PDV_BretonRewardRecords.spec.json",
  "PDV_KhajiitRewardRecords.spec.json",
];
const CAPSTONE_FALLBACKS = [
  {
    spellEditorId: "PDV_Bless_Imperial_Akatosh_T3",
    storageKey: "PDV.Capstone.Imperial.AkatoshSave",
    notificationText: "Akatosh turns your end aside.",
    prismaTitle: "Akatosh's Covenant",
    prismaText: "Akatosh turns your end aside.",
    prismaSymbol: "akatosh",
  },
  {
    spellEditorId: "PDV_Bless_Altmer_AuriEl_T3",
    storageKey: "PDV.Capstone.Altmer.AuriElSave",
    notificationText: "Auri-El's light holds you from death.",
    prismaTitle: "Auri-El's Light",
    prismaText: "Auri-El's light holds you from death.",
    prismaSymbol: "auriel",
  },
  {
    spellEditorId: "PDV_Bless_Nord_Shor_T3",
    storageKey: "PDV.Capstone.LowHealthSave.Nord",
    notificationText: "Shor pulls you back from the edge.",
    prismaTitle: "Shor's Last Stand",
    prismaText: "Shor pulls you back from the edge.",
    prismaSymbol: "shor",
  },
  {
    spellEditorId: "PDV_Bless_Orc_LegionExile_T3",
    storageKey: "PDV.Capstone.Orc.LegionHoldLine",
    notificationText: "The line holds. You stay standing.",
    prismaTitle: "The Line Holds",
    prismaText: "The line holds. You stay standing.",
    prismaSymbol: "malacath",
  },
  {
    spellEditorId: "PDV_Bless_Redguard_Tuwhacca_T3",
    storageKey: "PDV.Capstone.Redguard.TuwhaccaSave",
    notificationText: "Tu'whacca turns you back from the Far Shores.",
    prismaTitle: "Tu'whacca's Ward",
    prismaText: "Tu'whacca turns you back from the Far Shores.",
    prismaSymbol: "tuwhacca",
  },
  {
    spellEditorId: "PDV_Bless_Redguard_HoonDing_T3",
    storageKey: "PDV.Capstone.LowHealthSave.HoonDing",
    notificationText: "HoonDing opens the road back from the edge.",
    prismaTitle: "HoonDing's Edge",
    prismaText: "HoonDing opens the road back from the edge.",
    prismaSymbol: "journal",
  },
  {
    spellEditorId: "PDV_Bless_Khajiit_BaanDar_T3",
    scriptName: "PDV_KhajiitBaanDarRescueEffect",
    storageKey: "PDV.Capstone.Khajiit.BaanDarSlip",
    notificationText: "Baan Dar slips you out of death's hand.",
    prismaTitle: "Baan Dar's Luck",
    prismaText: "Baan Dar slips you out of death's hand.",
    prismaSymbol: "baandar",
  },
  {
    spellEditorId: "PDV_Bless_Bosmer_BanditRoad_T3",
    storageKey: "PDV.Capstone.Bosmer.BaanDarSlip",
    notificationText: "Baan Dar's road bends away from death.",
    prismaTitle: "The Road Bends",
    prismaText: "Baan Dar's road bends away from death.",
    prismaSymbol: "baandar",
  },
];
const GREEN_PACT_FORM_LISTS = [
  "PDV_FLST_GreenPact_PlantFoods",
  "PDV_FLST_GreenPact_MeatFoods",
  "PDV_FLST_GreenPact_FungiFoods",
  "PDV_FLST_GreenPact_EggFoods",
  "PDV_FLST_GreenPact_InsectFoods",
];
const GREEN_PACT_KEYWORDS = [
  "PDV_KW_GreenPact_Plant",
  "PDV_KW_GreenPact_Meat",
  "PDV_KW_GreenPact_Fungi",
  "PDV_KW_GreenPact_Egg",
  "PDV_KW_GreenPact_Insect",
];
const GREEN_PACT_KID = path.join(DEVOTION_MOD, "SKSE", "Plugins", "KeywordItemDistributor", "PDV_GreenPact_KID.ini");
const GREEN_PACT_PLANT_FOODS = [
  { formKey: "HearthFires.esm:003533", label: "Apple Dumpling" },
  { formKey: "HearthFires.esm:0009DC", label: "Garlic Bread" },
  { formKey: "HearthFires.esm:003537", label: "Potato Bread" },
  { formKey: "Dawnguard.esm:014DC4", label: "Soul Husk" },
  { formKey: "Dragonborn.esm:0206E7", label: "Ash Yam" },
  { formKey: "Skyrim.esm:064B2E", label: "Red Apple" },
  { formKey: "Skyrim.esm:064B2F", label: "Green Apple" },
  { formKey: "Skyrim.esm:0EBA01", label: "Apple Cabbage Soup" },
  { formKey: "Skyrim.esm:065C97", label: "Bread" },
  { formKey: "Skyrim.esm:065C98", label: "Bread Slice" },
  { formKey: "Skyrim.esm:064B3F", label: "Cabbage" },
  { formKey: "Skyrim.esm:0F431B", label: "Potato Cabbage Soup" },
  { formKey: "Skyrim.esm:0EBA02", label: "Cabbage Soup" },
  { formKey: "Skyrim.esm:064B40", label: "Carrot" },
  { formKey: "Skyrim.esm:10D666", label: "Gourd" },
  { formKey: "Skyrim.esm:0669A5", label: "Leek" },
  { formKey: "Skyrim.esm:064B3E", label: "Grilled Leeks" },
  { formKey: "Skyrim.esm:064B43", label: "Apple Pie" },
  { formKey: "Skyrim.esm:064B41", label: "Potato" },
  { formKey: "Skyrim.esm:064B3A", label: "Baked Potatoes" },
  { formKey: "HearthFires.esm:00353D", label: "Potato Soup" },
  { formKey: "Skyrim.esm:064B42", label: "Tomato" },
  { formKey: "Skyrim.esm:0F431C", label: "Tomato Soup" },
  { formKey: "Skyrim.esm:0F431E", label: "Vegetable Soup" },
  { formKey: "HearthFires.esm:0009DB", label: "Braided Bread" },
];

const json = process.argv.includes("--json");
const findings = [];

function add(status, check, detail, location = PDV_ESP) {
  findings.push({ status, check, detail, path: location });
}

function pass(check, detail, location) {
  add("PASS", check, detail, location);
}

function fail(check, detail, location) {
  add("FAIL", check, detail, location);
}

function warn(check, detail, location) {
  add("WARN", check, detail, location);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function bridge(request, timeoutMs = 60_000) {
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
  const payload = JSON.parse(stdout);
  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }
  return payload;
}

function counts() {
  const result = {};
  for (const finding of findings) {
    result[finding.status] = (result[finding.status] || 0) + 1;
  }
  return result;
}


function generateMgefId(spellEditorId, actorValue) {
  if (spellEditorId.startsWith("PDV_Bless")) {
    return `PDV_MGEF${spellEditorId.slice("PDV_Bless".length)}_${actorValue}`;
  }
  return `${spellEditorId}_MGEF`;
}

function localId(formid) {
  const id = String(formid || "").split(":")[1];
  return id ? Number.parseInt(id, 16) : null;
}

function parseQuestFlags(value) {
  if (typeof value === "number") {
    return value;
  }
  if (typeof value !== "string") {
    return 0;
  }
  if (/^\d+$/.test(value)) {
    return Number.parseInt(value, 10);
  }
  let flags = 0;
  if (value.includes("StartGameEnabled")) {
    flags |= START_GAME_ENABLED_FLAG;
  }
  return flags;
}

function readSeqLocalIds() {
  if (!fs.existsSync(DEVOTION_SEQ)) {
    return new Set();
  }
  const bytes = fs.readFileSync(DEVOTION_SEQ);
  const ids = new Set();
  for (let offset = 0; offset + 4 <= bytes.length; offset += 4) {
    ids.add(bytes.readUInt32LE(offset) & 0x00ffffff);
  }
  return ids;
}

function findScript(fields, name) {
  const scripts = fields?.VirtualMachineAdapter?.Scripts || [];
  const matches = scripts.filter((script) => script.Name === name);
  if (matches.length <= 1) {
    return matches[0] || null;
  }
  return {
    ...matches.at(-1),
    Properties: matches.flatMap((script) => script.Properties || []),
  };
}

function propertyMap(script) {
  return new Map((script?.Properties || []).filter((prop) => prop.Name).map((prop) => [prop.Name, prop]));
}

function propTarget(prop) {
  return prop?.Object || prop?.Data || null;
}

function formListEntries(detailRecord) {
  return (detailRecord?.fields?.Items || detailRecord?.fields?.Entries || []).map((entry) => entry.FormKey || entry);
}

function formidToEdid(formid, recordsByEdid) {
  for (const [edid, record] of recordsByEdid.entries()) {
    if (record.formid === formid) {
      return edid;
    }
  }
  return null;
}

function collectRewardEntries(spec) {
  const entries = [];
  for (const boon of spec.substrateBoons?.boons || []) {
    entries.push({ ...boon, source: "substrateBoons" });
  }
  if (spec.neglect?.spellEditorId) {
    entries.push({ ...spec.neglect, source: "neglect" });
  }
  for (const reward of spec.emphasisRewards || []) {
    entries.push({ ...reward, source: "emphasisRewards" });
  }
  return entries;
}

function expectedMgefId(entry, effect) {
  return effect.magicEffectEditorId || generateMgefId(entry.spellEditorId, effect.actorValue);
}

function effectMagnitude(effect) {
  return Number(effect?.Data?.Magnitude ?? 0);
}

function almostEqual(left, right) {
  return Math.abs(Number(left) - Number(right)) < 0.001;
}

function main() {
  const specPaths = SPEC_FILES.map((fileName) => path.join(ROOT, "references", "authoring", fileName));
  const specs = specPaths.map((specPath) => ({ path: specPath, spec: readJson(specPath) }));
  const scan = bridge({ command: "scan", plugins: [PDV_ESP.replaceAll("\\", "/")] });
  const plugin = scan.plugins?.[0];
  if (!plugin) {
    throw new Error("Mutagen scan returned no plugin payload.");
  }

  const recordsByEdid = new Map((plugin.records || []).filter((record) => record.edid).map((record) => [record.edid, record]));
  const detailEdids = new Set(["PDV__ManagerQuest", "PDV_FLST_AllDeities"]);
  for (const { spec } of specs) {
    for (const deity of spec.deityQuests || []) {
      detailEdids.add(deity.editorId);
    }
    for (const entry of collectRewardEntries(spec)) {
      detailEdids.add(entry.spellEditorId);
      for (const effect of entry.effects || []) {
        detailEdids.add(expectedMgefId(entry, effect));
      }
    }
  }
  for (const capstone of CAPSTONE_FALLBACKS) {
    detailEdids.add(capstone.spellEditorId);
  }
  for (const editorId of [...GREEN_PACT_FORM_LISTS, ...GREEN_PACT_KEYWORDS]) {
    detailEdids.add(editorId);
  }

  const detailRecords = [...detailEdids]
    .map((edid) => recordsByEdid.get(edid))
    .filter(Boolean)
    .map((record) => ({ plugin_path: PDV_ESP.replaceAll("\\", "/"), formid: record.formid }));
  const detail = bridge({ command: "read_records", max_depth: 10, records: detailRecords }, 120_000);
  const detailsByEdid = new Map((detail.records || []).filter((record) => record.success).map((record) => [record.editor_id, record]));

  // The dedicated T3 capstone save MGEF (e.g. PDV_MGEF_Khajiit_BaanDar_T3_AvoidDeath) is authored
  // outside the reward specs, so it was not in the first depth read and its VMAD (the save script)
  // would be missing. Depth-read every effect MGEF of each capstone spell so the index-agnostic scan
  // below can find the save script at whatever effect index it lives.
  const capstoneEffectEdids = new Set();
  for (const capstone of CAPSTONE_FALLBACKS) {
    const spellDetail = detailsByEdid.get(capstone.spellEditorId);
    for (const effect of spellDetail?.fields?.Effects || []) {
      const effectEdid = effect?.BaseEffect ? formidToEdid(effect.BaseEffect, recordsByEdid) : null;
      if (effectEdid && !detailsByEdid.has(effectEdid)) {
        capstoneEffectEdids.add(effectEdid);
      }
    }
  }
  if (capstoneEffectEdids.size > 0) {
    const capstoneEffectRecords = [...capstoneEffectEdids]
      .map((edid) => recordsByEdid.get(edid))
      .filter(Boolean)
      .map((record) => ({ plugin_path: PDV_ESP.replaceAll("\\", "/"), formid: record.formid }));
    const capstoneDetail = bridge({ command: "read_records", max_depth: 10, records: capstoneEffectRecords }, 120_000);
    for (const record of (capstoneDetail.records || []).filter((entry) => entry.success)) {
      detailsByEdid.set(record.editor_id, record);
    }
  }

  const managerScript = findScript(detailsByEdid.get("PDV__ManagerQuest")?.fields, "PDV__ManagerQuest");
  const managerProps = propertyMap(managerScript);
  const allDeities = detailsByEdid.get("PDV_FLST_AllDeities");
  const allDeityEntries = new Set((allDeities?.fields?.Items || allDeities?.fields?.Entries || []).map((entry) => entry.FormKey || entry));
  const seqLocalIds = readSeqLocalIds();

  if (managerScript) {
    pass("Manager VMAD", "PDV__ManagerQuest script is attached.");
  } else {
    fail("Manager VMAD", "PDV__ManagerQuest script is missing.");
  }

  for (const { path: specPath, spec } of specs) {
    for (const deity of spec.deityQuests || []) {
      const record = recordsByEdid.get(deity.editorId);
      const detailRecord = detailsByEdid.get(deity.editorId);
      if (record?.type === "QUST") {
        pass("Deity QUST", `${deity.editorId} exists as QUST.`, specPath);
      } else {
        fail("Deity QUST", `${deity.editorId} is missing as QUST.`, specPath);
        continue;
      }

      if (deity.create !== false) {
        const flags = parseQuestFlags(detailRecord?.fields?.Flags);
        if ((flags & START_GAME_ENABLED_FLAG) !== 0) {
          pass("Deity SGE", `${deity.editorId} is Start Game Enabled.`, specPath);
        } else {
          fail("Deity SGE", `${deity.editorId} is not Start Game Enabled.`, specPath);
        }
        if (seqLocalIds.has(localId(record.formid))) {
          pass("Deity SEQ", `${deity.editorId} is present in Devotion.seq.`, specPath);
        } else {
          fail("Deity SEQ", `${deity.editorId} is missing from Devotion.seq.`, specPath);
        }
      }

      if (deity.addToFormList === "PDV_FLST_AllDeities" || deity.create !== false) {
        if (allDeityEntries.has(record.formid)) {
          pass("AllDeities membership", `${deity.editorId} is in PDV_FLST_AllDeities.`, specPath);
        } else {
          fail("AllDeities membership", `${deity.editorId} is not in PDV_FLST_AllDeities.`, specPath);
        }
      }
    }

    for (const property of spec.managerDeityProperties || []) {
      const prop = managerProps.get(property.property);
      const target = propTarget(prop);
      const targetEdid = target ? formidToEdid(target, recordsByEdid) : null;
      if (targetEdid === property.record) {
        pass("Manager deity property", `${property.property} resolves to ${property.record}.`, specPath);
      } else {
        fail("Manager deity property", `${property.property} resolves to ${targetEdid || "(missing)"}, expected ${property.record}.`, specPath);
      }
    }

    for (const entry of collectRewardEntries(spec)) {
      const spell = recordsByEdid.get(entry.spellEditorId);
      const spellDetail = detailsByEdid.get(entry.spellEditorId);
      if (spell?.type === "SPEL") {
        pass("Reward spell", `${entry.spellEditorId} exists as SPEL.`, specPath);
      } else {
        fail("Reward spell", `${entry.spellEditorId} is missing as SPEL.`, specPath);
        continue;
      }

      const effects = spellDetail?.fields?.Effects || [];
      for (const expectedEffect of entry.effects || []) {
        const mgefId = expectedMgefId(entry, expectedEffect);
        const mgef = recordsByEdid.get(mgefId);
        const mgefDetail = detailsByEdid.get(mgefId);
        if (mgef?.type === "MGEF") {
          pass("Reward MGEF", `${mgefId} exists as MGEF.`, specPath);
        } else {
          fail("Reward MGEF", `${mgefId} is missing as MGEF.`, specPath);
          continue;
        }

        const actualActorValue = mgefDetail?.fields?.Archetype?.ActorValue;
        const expectedActorValue = normalizeActorValue(expectedEffect.actorValue);
        if (actualActorValue === expectedActorValue) {
          pass("Reward actor value", `${mgefId} uses ${expectedActorValue}.`, specPath);
        } else {
          fail("Reward actor value", `${mgefId} uses ${actualActorValue || "(missing)"}, expected ${expectedActorValue}.`, specPath);
        }

        const spellEffect = effects.find((effect) => effect.BaseEffect === mgef.formid);
        if (!spellEffect) {
          fail("Reward spell effect", `${entry.spellEditorId} does not include ${mgefId}.`, specPath);
        } else if (almostEqual(effectMagnitude(spellEffect), expectedEffect.magnitude)) {
          pass("Reward magnitude", `${entry.spellEditorId}/${mgefId} magnitude ${expectedEffect.magnitude}.`, specPath);
        } else {
          fail(
            "Reward magnitude",
            `${entry.spellEditorId}/${mgefId} magnitude ${effectMagnitude(spellEffect)}, expected ${expectedEffect.magnitude}.`,
            specPath,
          );
        }
      }

      if (entry.wireTo === "PDV__ManagerQuest" || entry.source !== "substrateBoons") {
        const prop = managerProps.get(entry.spellEditorId);
        const target = propTarget(prop);
        const targetEdid = target ? formidToEdid(target, recordsByEdid) : null;
        if (targetEdid === entry.spellEditorId) {
          pass("Manager reward property", `${entry.spellEditorId} resolves to its SPEL.`, specPath);
        } else if (entry.source === "substrateBoons") {
          warn("Manager reward property", `${entry.spellEditorId} is substrate-wired elsewhere, not on manager.`, specPath);
        } else {
          fail("Manager reward property", `${entry.spellEditorId} resolves to ${targetEdid || "(missing)"}.`, specPath);
        }
      }
    }
  }

  for (const capstone of CAPSTONE_FALLBACKS) {
    const { spellEditorId, storageKey } = capstone;
    const expectedScriptName = capstone.scriptName || "PDV_T3DailyLowHealthSaveEffect";
    const spellDetail = detailsByEdid.get(spellEditorId);
    // The capstone save effect can sit at ANY effect index -- Khajiit BaanDar T3 orders its three
    // stat effects first and carries PDV_T3DailyLowHealthSaveEffect on its last (AvoidDeath) effect.
    // Scan every effect and match the save script by role rather than assuming Effects[0].
    let capstoneScript = null;
    let effectEdid = null;
    for (const effect of spellDetail?.fields?.Effects || []) {
      const candidateEdid = effect?.BaseEffect ? formidToEdid(effect.BaseEffect, recordsByEdid) : null;
      const candidateScript = candidateEdid ? findScript(detailsByEdid.get(candidateEdid)?.fields, expectedScriptName) : null;
      if (candidateScript) {
        capstoneScript = candidateScript;
        effectEdid = candidateEdid;
        break;
      }
    }
    const props = propertyMap(capstoneScript);
    if (capstoneScript) {
      pass("T3 capstone script", `${effectEdid} carries ${expectedScriptName}.`);
    } else {
      fail("T3 capstone script", `${spellEditorId} has no effect carrying ${expectedScriptName}.`);
      continue;
    }

    if (props.get("StorageKey")?.Data === storageKey) {
      pass("T3 capstone StorageKey", `${spellEditorId} uses ${storageKey}.`);
    } else {
      fail("T3 capstone StorageKey", `${spellEditorId} StorageKey is ${props.get("StorageKey")?.Data || "(missing)"}, expected ${storageKey}.`);
    }

    if (props.has("PDV_GLO_DebugLevel")) {
      pass("T3 capstone debug gate", `${spellEditorId} wires PDV_GLO_DebugLevel.`);
    } else {
      fail("T3 capstone debug gate", `${spellEditorId} is missing PDV_GLO_DebugLevel.`);
    }

    for (const [propName, expected] of [
      ["NotificationText", capstone.notificationText],
      ["PrismaTitle", capstone.prismaTitle],
      ["PrismaText", capstone.prismaText],
      ["PrismaSymbol", capstone.prismaSymbol],
      ["PrismaTone", "good"],
    ]) {
      if (props.get(propName)?.Data === expected) {
        pass("T3 capstone player notice", `${spellEditorId} ${propName} is wired.`);
      } else {
        fail("T3 capstone player notice", `${spellEditorId} ${propName} is ${props.get(propName)?.Data || "(missing)"}, expected ${expected}.`);
      }
    }
  }

  const playerEventsDetail = detailsByEdid.get("PDV__ManagerQuest");
  const playerEventsScript = (playerEventsDetail?.fields?.VirtualMachineAdapter?.Aliases || [])
    .flatMap((alias) => alias.Scripts || [])
    .find((script) => script.Name === "PDV_PlayerEvents");
  const playerEventsProps = propertyMap(playerEventsScript);
  for (const editorId of GREEN_PACT_FORM_LISTS) {
    const record = recordsByEdid.get(editorId);
    if (record?.type === "FLST") {
      pass("Green Pact FormList", `${editorId} exists as FLST.`);
    } else {
      fail("Green Pact FormList", `${editorId} is missing as FLST.`);
    }
    const targetEdid = formidToEdid(propTarget(playerEventsProps.get(editorId)), recordsByEdid);
    if (targetEdid === editorId) {
      pass("Green Pact alias property", `PDV_PlayerEvents.${editorId} resolves.`);
    } else {
      fail("Green Pact alias property", `PDV_PlayerEvents.${editorId} resolves to ${targetEdid || "(missing)"}.`);
    }
  }
  for (const editorId of GREEN_PACT_KEYWORDS) {
    const record = recordsByEdid.get(editorId);
    if (record?.type === "KYWD") {
      pass("Green Pact keyword", `${editorId} exists as KYWD.`);
    } else {
      fail("Green Pact keyword", `${editorId} is missing as KYWD.`);
    }
    const targetEdid = formidToEdid(propTarget(playerEventsProps.get(editorId)), recordsByEdid);
    if (targetEdid === editorId) {
      pass("Green Pact alias property", `PDV_PlayerEvents.${editorId} resolves.`);
    } else {
      fail("Green Pact alias property", `PDV_PlayerEvents.${editorId} resolves to ${targetEdid || "(missing)"}.`);
    }
  }
  const plantFoodEntries = formListEntries(detailsByEdid.get("PDV_FLST_GreenPact_PlantFoods"));
  const plantFoodSet = new Set(plantFoodEntries);
  const plantFoodDuplicates = plantFoodEntries.filter((entry, index) => plantFoodEntries.indexOf(entry) !== index);
  for (const duplicate of [...new Set(plantFoodDuplicates)]) {
    fail("Green Pact plant baseline", `PDV_FLST_GreenPact_PlantFoods contains duplicate entry ${duplicate}.`);
  }
  for (const expected of GREEN_PACT_PLANT_FOODS) {
    if (plantFoodSet.has(expected.formKey)) {
      pass("Green Pact plant baseline", `PDV_FLST_GreenPact_PlantFoods contains ${expected.label}.`);
    } else {
      fail("Green Pact plant baseline", `PDV_FLST_GreenPact_PlantFoods is missing ${expected.label} (${expected.formKey}).`);
    }
  }
  if (GREEN_PACT_PLANT_FOODS.every((expected) => plantFoodSet.has(expected.formKey))) {
    pass("Green Pact plant baseline", `PDV_FLST_GreenPact_PlantFoods contains the Authoria/Requiem baseline set (${GREEN_PACT_PLANT_FOODS.length} entries).`);
  }
  if (fs.existsSync(GREEN_PACT_KID)) {
    pass("Green Pact KID", "PDV_GreenPact_KID.ini exists.", GREEN_PACT_KID);
  } else {
    fail("Green Pact KID", "PDV_GreenPact_KID.ini is missing.", GREEN_PACT_KID);
  }

  const summary = counts();
  if (json) {
    console.log(JSON.stringify({ status: summary.FAIL ? "FAIL" : "PASS", summary, findings }, null, 2));
  } else {
    for (const finding of findings) {
      console.log(`[${finding.status}] ${finding.check}: ${finding.detail}`);
    }
    console.log(`SUMMARY PASS=${summary.PASS || 0} WARN=${summary.WARN || 0} FAIL=${summary.FAIL || 0}`);
  }
  process.exitCode = summary.FAIL ? 1 : 0;
}

try {
  main();
} catch (error) {
  if (json) {
    console.log(JSON.stringify({ status: "FAIL", summary: { FAIL: 1 }, error: error.message }, null, 2));
  } else {
    console.error(`[FAIL] Phase 2 reward readback audit: ${error.message}`);
  }
  process.exitCode = 1;
}
