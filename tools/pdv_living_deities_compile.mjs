#!/usr/bin/env node
/*
 * Compile the LD-P1 "Living Deities" authoring tables into PapyrusUtil-friendly
 * JSON.
 *
 * Source CSVs remain authoritative. This tool emits a runtime file under
 * SKSE/Plugins/StorageUtilData/PlayerDevotion so Papyrus can read per-deity mood
 * tunables (alpha, band thresholds, stance ceiling), the demand table, and the
 * omen profile without baking them into the ESP.
 *
 * Pilot scope (LD-P1): Kyne + Hircine. Locked params per
 * references/research/living-deities/HANDOFF.md.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_OUTPUT = "D:/Wabbajack/modlists/Anvil/mods/Devotion/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_LivingDeities.json";

const MOOD_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DeityMood.csv");
const DEMAND_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DemandTable.csv");
const OMEN_CSV = path.join(PROJECT_ROOT, "references", "authoring", "PDV_OmenProfile.csv");

const args = process.argv.slice(2);
const outputPath = getArg("--output") ?? DEFAULT_OUTPUT;
const checkOnly = args.includes("--check");
const emitStdout = args.includes("--stdout");

// Stance-ceiling band caps (M2 / HANDOFF locked): FOREIGN -> Pleased; TABOO/HOSTILE -> Cool.
const STANCES = new Set(["NATIVE", "TOLERATED", "FOREIGN", "TABOO", "HOSTILE", "CURSE"]);
const BANDS = new Set(["Wroth", "Cool", "Pleased", "Exalted"]);

function main() {
  const moodRows = readCsv(MOOD_CSV);
  const demandRows = readCsv(DEMAND_CSV);
  const omenRows = readCsv(OMEN_CSV);

  const out = {
    generatedAt: new Date().toISOString(),
    schema: "pdv-living-deities.v1",
    deities: [],
    demandKeys: [],
    omenKeys: [],
  };

  const deitySet = new Set();
  for (const row of moodRows) {
    const deity = row.deity?.trim();
    if (!deity) {
      throw new Error("Mood row with empty deity.");
    }
    if (deitySet.has(deity)) {
      throw new Error(`Duplicate mood row for deity=${deity}`);
    }

    const alpha = Number.parseFloat(row.alpha);
    const wrothMax = Number.parseFloat(row.band_wroth_max);
    const coolMax = Number.parseFloat(row.band_cool_max);
    const pleasedMax = Number.parseFloat(row.band_pleased_max);
    if (!Number.isFinite(alpha)) throw new Error(`Invalid alpha for ${deity}: ${row.alpha}`);
    if (!Number.isFinite(wrothMax)) throw new Error(`Invalid band_wroth_max for ${deity}: ${row.band_wroth_max}`);
    if (!Number.isFinite(coolMax)) throw new Error(`Invalid band_cool_max for ${deity}: ${row.band_cool_max}`);
    if (!Number.isFinite(pleasedMax)) throw new Error(`Invalid band_pleased_max for ${deity}: ${row.band_pleased_max}`);

    deitySet.add(deity);
    out.deities.push(deity);
    out[`mood.${deity}.alpha`] = alpha;
    out[`mood.${deity}.bandWrothMax`] = wrothMax;
    out[`mood.${deity}.bandCoolMax`] = coolMax;
    out[`mood.${deity}.bandPleasedMax`] = pleasedMax;
    out[`mood.${deity}.stanceCeiling`] = parseStanceCeiling(row.stance_ceiling, deity);
  }

  for (const row of demandRows) {
    const deity = row.deity?.trim();
    const type = row.demand_type?.trim();
    if (!deity) throw new Error("Demand row with empty deity.");
    if (!type) throw new Error(`Demand row for ${deity} missing demand_type.`);

    const window = Number.parseInt(row.window_days, 10);
    if (!Number.isFinite(window)) throw new Error(`Invalid window_days for ${deity}: ${row.window_days}`);

    const key = `${deity}.${type}`;
    out.demandKeys.push(key);
    out[`demand.${key}.deity`] = deity;
    out[`demand.${key}.type`] = type;
    // Signal binding (M3 Spike 3 fix): no string act-tag exists in the award
    // path, so each demand binds to a concrete signal layer - faucet eventType
    // ints (router -> ScoreAction) and/or a curated quest-matrix tag
    // (ApplyQuestReaction).
    out[`demand.${key}.bindingLayer`] = (row.binding_layer || "").trim();
    out[`demand.${key}.eventTypes`] = (row.event_types || "")
      .trim()
      .split("|")
      .map((t) => t.trim())
      .filter(Boolean)
      .map((t) => {
        const n = Number.parseInt(t, 10);
        if (!Number.isFinite(n) || String(n) !== t) {
          throw new Error(`Invalid event_types entry "${t}" for ${deity} (must be an int eventType ID).`);
        }
        return n;
      });
    out[`demand.${key}.eventFilter`] = (row.event_filter || "").trim();
    out[`demand.${key}.questMatrixTag`] = (row.quest_matrix_tag || "").trim();
    out[`demand.${key}.wiredToday`] = (row.wired_today || "").trim();
    out[`demand.${key}.windowDays`] = window;
    out[`demand.${key}.rewardTag`] = (row.reward_tag || "").trim();
    out[`demand.${key}.penaltyTag`] = (row.penalty_tag || "").trim();
    out[`demand.${key}.cap`] = (row.anti_farm_cap || "").trim();
  }

  for (const row of omenRows) {
    const deity = row.deity?.trim();
    const transition = row.transition?.trim();
    if (!deity) throw new Error("Omen row with empty deity.");
    if (!transition) throw new Error(`Omen row for ${deity} missing transition.`);

    const key = `${deity}.${transition}`;
    out.omenKeys.push(key);
    out[`omen.${key}.deity`] = deity;
    out[`omen.${key}.transition`] = transition;
    out[`omen.${key}.toastKey`] = (row.toast_key || "").trim();
    out[`omen.${key}.dreamTextKey`] = (row.dream_text_key || "").trim();
    out[`omen.${key}.tone`] = (row.tone || "").trim();
  }

  validate(out);
  if (emitStdout) {
    // Emit the full compiled object to stdout (no file write). Consumed by
    // tools/pdv_living_deities_selftest.mjs so the runtime JSON can be validated
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
    deities: out.deities.length,
    demandKeys: out.demandKeys.length,
    omenKeys: out.omenKeys.length,
  }, null, 2));
}

function validate(out) {
  if (out.deities.length === 0) throw new Error("No deities emitted.");
  if (out.demandKeys.length === 0) throw new Error("No demand keys emitted.");
  if (out.omenKeys.length === 0) throw new Error("No omen keys emitted.");
  if (new Set(out.deities).size !== out.deities.length) throw new Error("Duplicate deities emitted.");
  if (new Set(out.demandKeys).size !== out.demandKeys.length) throw new Error("Duplicate demand keys emitted.");
  if (new Set(out.omenKeys).size !== out.omenKeys.length) throw new Error("Duplicate omen keys emitted.");
}

// Parse "FOREIGN:Pleased;TABOO:Cool;HOSTILE:Cool" into { FOREIGN: "Pleased", ... }.
function parseStanceCeiling(value, deity) {
  const out = {};
  const text = (value || "").trim();
  if (!text) {
    throw new Error(`Empty stance_ceiling for ${deity}.`);
  }
  for (const pair of text.split(";")) {
    const trimmed = pair.trim();
    if (!trimmed) continue;
    const [stance, band] = trimmed.split(":").map((s) => s.trim());
    if (!STANCES.has(stance)) {
      throw new Error(`Unknown stance "${stance}" in stance_ceiling for ${deity}.`);
    }
    if (!BANDS.has(band)) {
      throw new Error(`Unknown ceiling band "${band}" for stance ${stance} (${deity}).`);
    }
    out[stance] = band;
  }
  if (Object.keys(out).length === 0) {
    throw new Error(`No valid stance:band pairs in stance_ceiling for ${deity}.`);
  }
  return out;
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
