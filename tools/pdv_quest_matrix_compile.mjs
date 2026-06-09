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

const MATRIX_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
const FAUCET_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv");
const QUEST_READBACK_CSV = path.join(PROJECT_ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv");
const STANCE_CSV = path.join(PROJECT_ROOT, "references", "phase4", "PDV_StanceMatrix.csv");
const DAEDRIC_STANCE_CSV = path.join(PROJECT_ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv");

const args = process.argv.slice(2);
const outputPath = getArg("--output") ?? DEFAULT_OUTPUT;
const checkOnly = args.includes("--check");
const emitStdout = args.includes("--stdout");

const VALUE_TABLE = {
  "value.milestone.C": 18.0,
  "value.milestone.S": 12.0,
  "value.milestone.m": 8.0,
  "value.small.C": 6.0,
  "value.small.S": 4.0,
  "value.small.m": 2.0,
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
    questEditorIds: [],
    faucetKeys: [],
    ...VALUE_TABLE,
  };

  for (const [key, value] of Object.entries(compileStance(stanceRows, daedricRows))) {
    out[key] = value;
  }

  const questKeySet = new Set();
  for (const row of matrixRows) {
    const editorId = row.editor_id?.trim();
    const stage = Number.parseInt(row.outcome_stage, 10);
    const resolved = questIndex.get(editorId);
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
      out.questEditorIds.push(editorId);
      out[`quest.${key}.deities`] = [];
      out[`quest.${key}.valences`] = [];
      out[`quest.${key}.intensities`] = [];
      out[`quest.${key}.magnitudes`] = [];
      out[`quest.${key}.tags`] = [];
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

  for (const [key, forms] of Object.entries(FAUCET_FORM_LISTS)) {
    out[key] = forms;
  }
  for (const [key, forms] of Object.entries(FAUCET_EFFECT_LISTS)) {
    out[key] = forms;
  }

  validate(out);
  if (emitStdout) {
    // Emit the full compiled object to stdout (no file write). Consumed by
    // tools/pdv_quest_matrix_selftest.mjs so the runtime JSON can be validated
    // without touching the Windows StorageUtilData output path.
    process.stdout.write(`${JSON.stringify(out, null, 2)}\n`);
    return;
  }
  if (!checkOnly) {
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, `${JSON.stringify(out, null, 2)}\n`, "utf8");
  }

  console.log(JSON.stringify({
    status: "PASS",
    outputPath: checkOnly ? null : path.resolve(outputPath),
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
    papyrusForm: `0x${localHex}|${plugin}`,
  };
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
