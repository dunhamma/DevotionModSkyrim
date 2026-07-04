#!/usr/bin/env node
/*
 * Compile the frozen PDV quest-reaction matrix into PapyrusUtil-friendly JSON.
 *
 * Source CSVs remain authoritative. This tool emits a runtime file under
 * SKSE/Plugins/StorageUtilData/PlayerDevotion so Papyrus can register watched
 * quests and apply reaction cells without baking 317 cells into the ESP.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_OUTPUT = "D:/Wabbajack/modlists/Anvil/mods/Devotion/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix.json";

const DEFAULT_MATRIX_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
const FAUCET_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv");
const QUEST_READBACK_CSV = path.join(PROJECT_ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv");
const STANCE_CSV = path.join(PROJECT_ROOT, "references", "phase4", "PDV_StanceMatrix.csv");
const DAEDRIC_STANCE_CSV = path.join(PROJECT_ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv");

const args = process.argv.slice(2);
const outputPath = getArg("--output") ?? DEFAULT_OUTPUT;
const checkOnly = args.includes("--check");
const emitStdout = args.includes("--stdout");
const papyrusUtilCheck = args.includes("--papyrusutil-check");
// Resolved after `args` exists (getArg reads it). Defaults to the core Full.csv;
// list-patch channels (e.g. ARR) pass --matrix <their.csv> + --output <their.json>.
const MATRIX_CSV = getArg("--matrix") ?? DEFAULT_MATRIX_CSV;

const VALUE_TABLE = {
  "value.milestone.C": 18.0,
  "value.milestone.S": 12.0,
  "value.milestone.m": 8.0,
  "value.small.C": 6.0,
  "value.small.S": 4.0,
  "value.small.m": 2.0,
  // echo tier (2026-07-04): generated breadth cells from the Part B cross-generation
  // expansion. Half of small so ~40-quest-per-deity coverage cannot distort the
  // 4.3/day pacing envelope; tune these three knobs after in-game measurement.
  // GetQuestReactionBaseValue reads value.<magnitude>.<intensity> straight from the
  // compiled JSON, so no Papyrus change is needed for the new tier.
  "value.echo.C": 3.0,
  "value.echo.S": 2.0,
  "value.echo.m": 1.0,
  "stanceMult.NATIVE": 1.0,
  "stanceMult.FOREIGN": 0.4,
  "stanceMult.TOLERATED": 0.4,
};

const RACES = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];
const DEITY_ALIASES = new Map([
  ["Azura / Azurah", "Azura"],
  ["Boethiah / Boethra", "Boethiah"],
  ["Malacath / Mauloch", "Malacath"],
  ["Molag Bal", "Molag Bal"],
  ["Clavicus Vile", "Clavicus Vile"],
  ["Hermaeus Mora", "Hermaeus Mora"],
  ["Mehrunes Dagon", "Mehrunes Dagon"],
  ["Sheogorath", "Sheogorath"],
  ["Nocturnal", "Nocturnal"],
  ["Peryite", "Peryite"],
  ["Sanguine", "Sanguine"],
  ["Namira", "Namira"],
  ["Vaermina", "Vaermina"],
  ["Meridia", "Meridia"],
  ["Hircine", "Hircine"],
  ["Mephala / Mafala", "Mephala"],
]);

const FAUCET_FORM_LISTS = {
  "faucetForms.Namira.cannibalism": [
    "0x1016B3|Skyrim.esm", // Human Flesh
    "0x0B18CD|Skyrim.esm", // Human Heart
  ],
  "faucetForms.Sanguine.revel_indulge": [
    "0x034C5D|Skyrim.esm", // Ale
    "0x034C5E|Skyrim.esm", // Nord Mead
    "0x085D53|Skyrim.esm", // Honningbrew Mead
    "0x02C35A|Skyrim.esm", // Black-Briar Mead
    "0x034C5F|Skyrim.esm", // Wine
    "0x085D52|Skyrim.esm", // Alto Wine
  ],
  "faucetForms.Hermaeus Mora.forbidden_knowledge": [
    "0x016E2D|Dragonborn.esm",
    "0x016E2E|Dragonborn.esm",
    "0x01E99E|Dragonborn.esm",
    "0x01E99F|Dragonborn.esm",
    "0x01E9A0|Dragonborn.esm",
    "0x01E9A1|Dragonborn.esm",
    "0x01E9A2|Dragonborn.esm",
  ],
  "faucetForms.Hermaeus Mora.disciplined_study": [
    "0x02D513|Skyrim.esm", // Ruminations on the Elder Scrolls
    "0x01AD0F|Skyrim.esm", // The Old Ways
    "0x01AD0E|Skyrim.esm", // N'Gasta! Kvata! Kvakis!
    "0x01AD0C|Skyrim.esm", // Souls, Black and White
  ],
  "faucetForms.Azura.fate_threshold": [
    "0x01ACE9|Skyrim.esm", // Azura and the Box
    "0x01B245|Skyrim.esm", // Invocation of Azura
  ],
  "faucetForms.Dibella.aesthetic_devotion": [
    "0x088952|Skyrim.esm", // Fine Clothes
    "0x088953|Skyrim.esm", // Fine Clothes
    "0x0CEE80|Skyrim.esm", // Fine Boots
    "0x087719|Skyrim.esm", // Fine Hat
    "0x0C8911|Skyrim.esm", // Gold Diamond Ring
    "0x087733|Skyrim.esm", // Silver Sapphire Necklace
  ],
  "faucetForms.Clavicus Vile.serve_a_daedra:clavicus": [
    "0x0D2846|Skyrim.esm", // Masque of Clavicus Vile
  ],
  "faucetForms.Peryite.serve_a_daedra:peryite": [
    "0x045F96|Skyrim.esm", // Spellbreaker
  ],
  "faucetForms.Vaermina.serve_a_daedra:vaermina": [
    "0x035066|Skyrim.esm", // Skull of Corruption
  ],
  "faucetForms.Boethiah.serve_a_daedra:boethiah": [
    "0x052794|Skyrim.esm", // Ebony Mail
  ],
  "faucetForms.Mephala.serve_a_daedra:mephala": [
    "0x04A38F|Skyrim.esm", // Ebony Blade
  ],
  "faucetForms.Malacath.serve_a_daedra:malacath": [
    "0x02ACD2|Skyrim.esm", // Volendrung
  ],
  "faucetForms.Molag Bal.serve_a_daedra:molag_bal": [
    "0x0233E3|Skyrim.esm", // Mace of Molag Bal
  ],
  "faucetForms.Hircine.serve_a_daedra:hircine": [
    "0x02AC61|Skyrim.esm", // Savior's Hide
    "0x02AC60|Skyrim.esm", // Ring of Hircine
  ],
  "faucetForms.Meridia.serve_a_daedra:meridia": [
    "0x04E4EE|Skyrim.esm", // Dawnbreaker
  ],
  "faucetForms.Sheogorath.serve_a_daedra:sheogorath": [
    "0x02AC6F|Skyrim.esm", // Wabbajack
  ],
  "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunes_dagon": [
    "0x0240D2|Skyrim.esm", // Mehrunes' Razor
  ],
  "faucetForms.Nocturnal.serve_a_daedra:nocturnal": [
    "0x07A917|Skyrim.esm", // Nightingale Blade 01
    "0x0F6524|Skyrim.esm", // Nightingale Blade 02
    "0x0F6525|Skyrim.esm", // Nightingale Blade 03
    "0x0F6526|Skyrim.esm", // Nightingale Blade 04
    "0x0F6527|Skyrim.esm", // Nightingale Blade 05
    "0x07E5C3|Skyrim.esm", // Nightingale Bow 01
    "0x0F6529|Skyrim.esm", // Nightingale Bow 02
    "0x0F652A|Skyrim.esm", // Nightingale Bow 03
    "0x0F652B|Skyrim.esm", // Nightingale Bow 04
    "0x0F652C|Skyrim.esm", // Nightingale Bow 05
    "0x05DB86|Skyrim.esm", // Nightingale Armor 01
    "0x0FCC0E|Skyrim.esm", // Nightingale Armor 02
    "0x0FCC0F|Skyrim.esm", // Nightingale Armor 03
    "0x0FCC0C|Skyrim.esm", // Nightingale Boots 01
    "0x05DB85|Skyrim.esm", // Nightingale Boots 02
    "0x0FCC0D|Skyrim.esm", // Nightingale Boots 03
    "0x05DB87|Skyrim.esm", // Nightingale Gloves 01
    "0x0FCC10|Skyrim.esm", // Nightingale Gloves 02
    "0x0FCC11|Skyrim.esm", // Nightingale Gloves 03
    "0x05DB88|Skyrim.esm", // Nightingale Hood 01
    "0x0FCC13|Skyrim.esm", // Nightingale Hood 02
    "0x0FCC12|Skyrim.esm", // Nightingale Hood 03
  ],
};

const FAUCET_EFFECT_LISTS = {
  "faucetEffectForms.Namira.cannibalism": [
    "0x10F814|Skyrim.esm", // DA11AbFortifyHealth, Ring of Namira feed effect
  ],
  "faucetEffectForms.Dibella.charity": [
    "0x0F871B|Skyrim.esm", // FavorFortifySpeechcraft, Gift of Charity effect
  ],
};

const MANUAL_QUEST_FORMIDS = {
  // ARR compat-core promotion (Tranche6): CC + vanilla-FormID QE stages. editor_id fallback.
  DA10: "Skyrim.esm:022F08", // House of Horrors (QE adds s210 anti-Daedric outcome)
  DA13: "Skyrim.esm:08998D", // The Only Cure (QE adds s101/s102 refuse/destroy outcomes)
  DA06: "Skyrim.esm:03B681", // The Cursed Tribe (QE adds s210 ghost-variant)
  ccBGSSSE020_Quest: "ccbgssse020-graycowl.esl:00080F", // Gray Cowl of Nocturnal (CC)
  dunHunterQST: "Skyrim.esm:018601", // Kyne's Sacred Trials (Froki); s100 terminal blessing. Verified via houseCARL (USSEP-patched record).
  FreeformKolskeggrA: "Skyrim.esm:01FD72",
  MQ105U: "Skyrim.esm:0713DC",
  MS14: "Skyrim.esm:025F3E",
  T01: "Skyrim.esm:023B6C",
  t02: "Skyrim.esm:0211D5",
  T03: "Skyrim.esm:01C48E",
};

function main() {
  const questIndex = buildQuestIndex(readCsv(QUEST_READBACK_CSV));
  const matrixRows = readCsv(MATRIX_CSV);
  const faucetRows = readCsv(FAUCET_CSV);
  const stanceRows = readCsv(STANCE_CSV);
  const daedricRows = readCsv(DAEDRIC_STANCE_CSV);

  const out = {
    generatedAt: new Date().toISOString(),
    schema: "pdv-quest-reaction-matrix.v1",
    questKeys: [],
    questForms: [],
    questFormIds: [],
    questPlugins: [],
    questEditorIds: [],
    "questWatch.formIds": [],
    "questWatch.plugins": [],
    "questWatch.editorIds": [],
    questWatchFormIds: [],
    questWatchPlugins: [],
    questWatchEditorIds: [],
    questWatchFormIdsCsv: "",
    questWatchPluginsCsv: "",
    faucetKeys: [],
    ...VALUE_TABLE,
  };

  for (const [key, value] of Object.entries(compileStance(stanceRows, daedricRows))) {
    out[key] = value;
  }

  const questKeySet = new Set();
  const questWatchSet = new Set();
  for (const row of matrixRows) {
    const editorId = row.editor_id?.trim();
    const stage = Number.parseInt(row.outcome_stage, 10);
    // ARR/list-patch rows may carry an explicit PLUGIN:HEX formid (modded quests
    // absent from the vanilla readback). When present it resolves directly,
    // keeping third-party FormIDs out of MANUAL_QUEST_FORMIDS / the readback CSV.
    const inlineFormId = row.formid?.trim();
    const resolved = inlineFormId ? resolveQuestForm(inlineFormId) : questIndex.get(editorId);
    if (!resolved) {
      throw new Error(`No quest readback FormID for editor_id=${editorId}`);
    }
    if (!Number.isFinite(stage)) {
      throw new Error(`Invalid outcome_stage for ${editorId}: ${row.outcome_stage}`);
    }

    const key = `${resolved.decimal}|${stage}`;
    if (!questKeySet.has(key)) {
      questKeySet.add(key);
      out.questKeys.push(key);
      out.questForms.push(resolved.papyrusForm);
      out.questFormIds.push(resolved.decimal);
      out.questPlugins.push(resolved.plugin);
      out.questEditorIds.push(editorId);
      out[`quest.${key}.deities`] = [];
      out[`quest.${key}.valences`] = [];
      out[`quest.${key}.intensities`] = [];
      out[`quest.${key}.magnitudes`] = [];
      out[`quest.${key}.tags`] = [];
    }
    if (!questWatchSet.has(resolved.papyrusForm)) {
      questWatchSet.add(resolved.papyrusForm);
      out["questWatch.formIds"].push(resolved.decimal);
      out["questWatch.plugins"].push(resolved.plugin);
      out["questWatch.editorIds"].push(editorId);
      out.questWatchFormIds.push(resolved.decimal);
      out.questWatchPlugins.push(resolved.plugin);
      out.questWatchEditorIds.push(editorId);
    }

    out[`quest.${key}.deities`].push(row.deity.trim());
    out[`quest.${key}.valences`].push(row.valence.trim());
    out[`quest.${key}.intensities`].push(row.intensity.trim());
    out[`quest.${key}.magnitudes`].push(row.magnitude.trim());
    out[`quest.${key}.tags`].push(row.act_tags.trim());
  }

  for (const row of faucetRows) {
    if ((row.buildability || "").toUpperCase() === "DEFERRED") {
      continue;
    }

    const deity = row.deity.trim();
    const tag = row.act_tag.trim();
    const key = `${deity}.${tag}`;
    out.faucetKeys.push(key);
    out[`faucet.${key}.deity`] = deity;
    out[`faucet.${key}.valence`] = row.valence.trim();
    out[`faucet.${key}.intensity`] = row.intensity.trim();
    out[`faucet.${key}.magnitude`] = row.magnitude.trim();
    out[`faucet.${key}.tag`] = tag;
    out[`faucet.${key}.cap`] = row.anti_farm_cap.trim();
  }

  out.questWatchFormIdsCsv = out.questWatchFormIds.join(",");
  out.questWatchPluginsCsv = out.questWatchPlugins.join(",");
  for (const questKey of out.questKeys) {
    out[`quest.${questKey}.deitiesCsv`] = out[`quest.${questKey}.deities`].join("|");
    out[`quest.${questKey}.valencesCsv`] = out[`quest.${questKey}.valences`].join("|");
    out[`quest.${questKey}.intensitiesCsv`] = out[`quest.${questKey}.intensities`].join("|");
    out[`quest.${questKey}.magnitudesCsv`] = out[`quest.${questKey}.magnitudes`].join("|");
    out[`quest.${questKey}.tagsCsv`] = out[`quest.${questKey}.tags`].join("|");
  }

  for (const [key, forms] of Object.entries(FAUCET_FORM_LISTS)) {
    attachRuntimeFormList(out, key, forms);
  }
  for (const [key, forms] of Object.entries(FAUCET_EFFECT_LISTS)) {
    attachRuntimeFormList(out, key, forms);
  }

  validate(out);
  const papyrusUtilJson = toPapyrusUtilJson(out);
  validatePapyrusUtilJson(papyrusUtilJson, out);
  let papyrusUtilFileCheck = "generated";
  if (papyrusUtilCheck && checkOnly && exists(outputPath)) {
    validatePapyrusUtilJson(readJson(outputPath), out, outputPath);
    papyrusUtilFileCheck = "file";
  }

  if (emitStdout) {
    // Emit the full compiled object to stdout (no file write). Consumed by
    // tools/pdv_quest_matrix_selftest.mjs so the runtime JSON can be validated
    // without touching the Windows StorageUtilData output path.
    process.stdout.write(`${JSON.stringify(out, null, 2)}\n`);
    return;
  }
  if (!checkOnly) {
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, `${JSON.stringify(papyrusUtilJson, null, 2)}\n`, "utf8");
    if (papyrusUtilCheck) {
      validatePapyrusUtilJson(readJson(outputPath), out, outputPath);
      papyrusUtilFileCheck = "file";
    }
  }

  console.log(JSON.stringify({
    status: "PASS",
    outputPath: checkOnly ? null : path.resolve(outputPath),
    papyrusUtilContract: "PASS",
    papyrusUtilFileCheck,
    questCells: matrixRows.length,
    questKeys: out.questKeys.length,
    watchedQuests: new Set(out.questFormIds).size,
    faucetActs: out.faucetKeys.length,
  }, null, 2));
}

function validate(out) {
  if (out.questKeys.length === 0) throw new Error("No quest keys emitted.");
  if (out.faucetKeys.length === 0) throw new Error("No faucet keys emitted.");
  if (new Set(out.questKeys).size !== out.questKeys.length) throw new Error("Duplicate quest keys emitted.");
  if (out.questKeys.length !== out.questFormIds.length || out.questKeys.length !== out.questPlugins.length) {
    throw new Error("Quest key and FormID/plugin lists are out of sync.");
  }
  if (out["questWatch.formIds"].length !== out["questWatch.plugins"].length) {
    throw new Error("Quest watch FormID/plugin lists are out of sync.");
  }
  if (out["questWatch.formIds"].length !== new Set(out.questFormIds).size) {
    throw new Error("Quest watch list does not match unique watched quest count.");
  }
  if (out.questWatchFormIds.length !== out.questWatchPlugins.length) {
    throw new Error("Runtime quest watch FormID/plugin lists are out of sync.");
  }
  if (out.questWatchFormIds.length !== out["questWatch.formIds"].length) {
    throw new Error("Runtime quest watch list does not match compatibility watch list.");
  }
  if (out.questWatchFormIdsCsv.split(",").filter(Boolean).length !== out.questWatchFormIds.length) {
    throw new Error("Runtime quest watch FormID CSV is out of sync.");
  }
  if (out.questWatchPluginsCsv.split(",").filter(Boolean).length !== out.questWatchPlugins.length) {
    throw new Error("Runtime quest watch plugin CSV is out of sync.");
  }
  for (const key of [...Object.keys(FAUCET_FORM_LISTS), ...Object.keys(FAUCET_EFFECT_LISTS)]) {
    if (out[key].length !== out[`${key}.formIds`].length || out[key].length !== out[`${key}.plugins`].length) {
      throw new Error(`Faucet FormID/plugin lists are out of sync for ${key}.`);
    }
    const runtimeKey = runtimeFormListKey(key);
    if (out[key].length !== out[`${runtimeKey}FormIds`].length || out[key].length !== out[`${runtimeKey}Plugins`].length) {
      throw new Error(`Runtime faucet FormID/plugin lists are out of sync for ${key}.`);
    }
    if (out[`${runtimeKey}FormIdsCsv`].split(",").filter(Boolean).length !== out[key].length) {
      throw new Error(`Runtime faucet FormID CSV is out of sync for ${key}.`);
    }
    if (out[`${runtimeKey}PluginsCsv`].split(",").filter(Boolean).length !== out[key].length) {
      throw new Error(`Runtime faucet plugin CSV is out of sync for ${key}.`);
    }
  }
}

function validatePapyrusUtilJson(runtime, flat, filePath = "generated runtime JSON") {
  if (!runtime || typeof runtime !== "object") {
    throw new Error(`PapyrusUtil JSON ${filePath} is not an object.`);
  }
  for (const bucket of ["string", "float", "int", "stringList"]) {
    if (!runtime[bucket] || typeof runtime[bucket] !== "object" || Array.isArray(runtime[bucket])) {
      throw new Error(`PapyrusUtil JSON ${filePath} is missing ${bucket} bucket.`);
    }
  }
  if (Object.hasOwn(runtime, "questWatchFormIdsCsv") || Object.hasOwn(runtime, "questWatchFormIds")) {
    throw new Error(`PapyrusUtil JSON ${filePath} has flat matrix keys outside typed buckets.`);
  }

  const expectedWatchCount = flat.questWatchFormIds.length;
  const formIdsCsv = runtime.string.questWatchFormIdsCsv ?? "";
  const pluginsCsv = runtime.string.questWatchPluginsCsv ?? "";
  const formIdCsvCount = formIdsCsv.split(",").filter(Boolean).length;
  const pluginCsvCount = pluginsCsv.split(",").filter(Boolean).length;
  if (formIdCsvCount !== expectedWatchCount) {
    throw new Error(`PapyrusUtil JSON ${filePath} questWatchFormIdsCsv count ${formIdCsvCount}, expected ${expectedWatchCount}.`);
  }
  if (pluginCsvCount !== expectedWatchCount) {
    throw new Error(`PapyrusUtil JSON ${filePath} questWatchPluginsCsv count ${pluginCsvCount}, expected ${expectedWatchCount}.`);
  }
  if (!Array.isArray(runtime.stringList.questWatchFormIds) || runtime.stringList.questWatchFormIds.length !== expectedWatchCount) {
    throw new Error(`PapyrusUtil JSON ${filePath} stringList.questWatchFormIds is missing or wrong length.`);
  }
  if (!Array.isArray(runtime.stringList.questWatchPlugins) || runtime.stringList.questWatchPlugins.length !== expectedWatchCount) {
    throw new Error(`PapyrusUtil JSON ${filePath} stringList.questWatchPlugins is missing or wrong length.`);
  }
  if (typeof runtime.string.questwatchformidscsv !== "string" || runtime.string.questwatchformidscsv === "") {
    throw new Error(`PapyrusUtil JSON ${filePath} is missing lowercase questwatchformidscsv alias.`);
  }
  if (!Array.isArray(runtime.stringList.questwatchformids) || runtime.stringList.questwatchformids.length !== expectedWatchCount) {
    throw new Error(`PapyrusUtil JSON ${filePath} is missing lowercase questwatchformids alias.`);
  }

  const questKey = flat.questKeys[0];
  for (const suffix of ["deitiesCsv", "valencesCsv", "intensitiesCsv", "magnitudesCsv", "tagsCsv"]) {
    const key = `quest.${questKey}.${suffix}`;
    if (typeof runtime.string[key] !== "string" || runtime.string[key] === "") {
      throw new Error(`PapyrusUtil JSON ${filePath} is missing populated ${key}.`);
    }
  }
  if (typeof runtime.string["stance.Nord.Kyne"] !== "string") {
    throw new Error(`PapyrusUtil JSON ${filePath} is missing stance.Nord.Kyne.`);
  }
  if (runtime.float["value.small.m"] !== 2.0) {
    throw new Error(`PapyrusUtil JSON ${filePath} is missing value.small.m in float bucket.`);
  }
  if (runtime.float["stanceMult.FOREIGN"] !== 0.4) {
    throw new Error(`PapyrusUtil JSON ${filePath} is missing stanceMult.FOREIGN in float bucket.`);
  }
}

function toPapyrusUtilJson(out) {
  const runtime = {
    string: {},
    float: {},
    int: {},
    stringList: {},
  };

  for (const [key, value] of Object.entries(out)) {
    if (Array.isArray(value)) {
      setRuntimeValue(runtime.stringList, key, value.map((entry) => String(entry)));
    } else if (typeof value === "number") {
      if (key.startsWith("value.") || key.startsWith("stanceMult.")) {
        setRuntimeValue(runtime.float, key, value);
      } else if (Number.isInteger(value)) {
        setRuntimeValue(runtime.int, key, value);
      } else {
        setRuntimeValue(runtime.float, key, value);
      }
    } else if (typeof value === "string") {
      setRuntimeValue(runtime.string, key, value);
    } else if (typeof value === "boolean") {
      setRuntimeValue(runtime.int, key, value ? 1 : 0);
    }
  }

  return runtime;
}

function setRuntimeValue(bucket, key, value) {
  bucket[key] = value;
  const lowercaseKey = key.toLowerCase();
  if (lowercaseKey !== key) {
    bucket[lowercaseKey] = value;
  }
}

function buildQuestIndex(rows) {
  const index = new Map();
  for (const row of rows) {
    const editorId = row.editor_id?.trim();
    const formid = row.formid?.trim();
    if (!editorId || !formid || index.has(editorId)) {
      continue;
    }
    const [plugin, hex] = formid.split(":");
    if (!plugin || !hex) {
      continue;
    }
    const localHex = hex.slice(-6);
    const decimal = Number.parseInt(localHex, 16);
    index.set(editorId, {
      formid,
      decimal,
      plugin,
      papyrusForm: `0x${localHex}|${plugin}`,
    });
  }
  for (const [editorId, formid] of Object.entries(MANUAL_QUEST_FORMIDS)) {
    if (!index.has(editorId)) {
      index.set(editorId, resolveQuestForm(formid));
    }
  }
  return index;
}

function resolveQuestForm(formid) {
  const [plugin, hex] = formid.split(":");
  if (!plugin || !hex) {
    throw new Error(`Invalid quest FormID mapping: ${formid}`);
  }
  const localHex = hex.slice(-6);
  return {
    formid,
    decimal: Number.parseInt(localHex, 16),
    plugin,
    papyrusForm: `0x${localHex}|${plugin}`,
  };
}

function attachRuntimeFormList(out, key, forms) {
  out[key] = forms;
  out[`${key}.formIds`] = [];
  out[`${key}.plugins`] = [];
  const runtimeKey = runtimeFormListKey(key);
  out[`${runtimeKey}FormIds`] = [];
  out[`${runtimeKey}Plugins`] = [];
  for (const formRef of forms) {
    const resolved = resolveRuntimeFormRef(formRef);
    out[`${key}.formIds`].push(resolved.decimal);
    out[`${key}.plugins`].push(resolved.plugin);
    out[`${runtimeKey}FormIds`].push(resolved.decimal);
    out[`${runtimeKey}Plugins`].push(resolved.plugin);
  }
  out[`${runtimeKey}FormIdsCsv`] = out[`${runtimeKey}FormIds`].join(",");
  out[`${runtimeKey}PluginsCsv`] = out[`${runtimeKey}Plugins`].join(",");
}

function resolveRuntimeFormRef(formRef) {
  const [rawHex, plugin] = formRef.split("|");
  if (!rawHex || !plugin) {
    throw new Error(`Invalid runtime form reference: ${formRef}`);
  }
  const hex = rawHex.toLowerCase().startsWith("0x") ? rawHex.slice(2) : rawHex;
  return {
    decimal: Number.parseInt(hex, 16),
    plugin,
  };
}

function runtimeFormListKey(key) {
  return key
    .replace(/[^A-Za-z0-9]+(.)/g, (_, ch) => ch.toUpperCase())
    .replace(/^[^A-Za-z]+/, "");
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function compileStance(stanceRows, daedricRows) {
  const out = {};
  for (const row of stanceRows) {
    const deity = normalizeDeity(row.WorshipObject);
    for (const race of RACES) {
      const value = normalizeStance(row[race]);
      if (value) {
        out[`stance.${race}.${deity}`] = value;
      }
    }
  }
  for (const row of daedricRows) {
    const deity = normalizeDeity(row.Prince);
    for (const race of RACES) {
      const value = normalizeStance(row[race]);
      if (value) {
        out[`stance.${race}.${deity}`] = value;
      }
    }
  }
  return out;
}

function normalizeDeity(value) {
  const trimmed = (value || "").trim();
  return DEITY_ALIASES.get(trimmed) ?? trimmed;
}

function normalizeStance(value) {
  const text = (value || "").trim().toLowerCase();
  if (!text) return "";
  if (text.startsWith("native")) return "NATIVE";
  if (text.startsWith("tolerated")) return "TOLERATED";
  if (text.startsWith("legible")) return "TOLERATED";
  if (text.startsWith("foreign")) return "FOREIGN";
  if (text.startsWith("taboo")) return "TABOO";
  if (text.startsWith("hostile")) return "HOSTILE";
  if (text.startsWith("curse")) return "CURSE";
  return "FOREIGN";
}

function readCsv(filePath) {
  const text = fs.readFileSync(filePath, "utf8");
  const rows = parseCsv(text);
  const header = rows.shift();
  return rows
    .filter((row) => row.some((field) => field.trim() !== ""))
    .map((row) => Object.fromEntries(header.map((name, index) => [name, row[index] ?? ""])));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let inQuotes = false;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          field += '"';
          i += 1;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ",") {
      row.push(field);
      field = "";
    } else if (c === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else if (c !== "\r") {
      field += c;
    }
  }
  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

function getArg(name) {
  const index = args.indexOf(name);
  if (index >= 0) {
    return args[index + 1];
  }
  const prefix = `${name}=`;
  const match = args.find((arg) => arg.startsWith(prefix));
  return match ? match.slice(prefix.length) : null;
}

main();
