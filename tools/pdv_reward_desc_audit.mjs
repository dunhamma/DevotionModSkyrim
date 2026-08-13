#!/usr/bin/env node
/*
 * Reward/boon/price description-clarity audit (task #16).
 *
 * The boon/price/reward descriptions are thematic but do not state the literal
 * mechanical effect (e.g. "+8 Illusion"). The user wants deity-parity clarity.
 * This tool walks every reward/contract spec JSON, pairs each playerFacingText
 * with its structured effects, and emits a REVIEW table proposing the magnitude
 * clause to append. The actual record re-author happens on the Windows box from
 * the approved copy; this is review-ready data, not a record writer.
 *
 * Run: node tools/pdv_reward_desc_audit.mjs            (writes the review .md)
 *      node tools/pdv_reward_desc_audit.mjs --stdout   (print, no write)
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--stdout"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_reward_desc_audit" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const SRC_DIR = path.join(ROOT, "references", "authoring");
const OUT = path.join(SRC_DIR, "PDV_RewardDescriptionClarity_Review_2026-06-09.md");

const SRC_RE = /(RewardRecords\.spec\.json|RecordContracts\.json)$/;

// AVs the player reads as a percentage; everything else is a flat skill/point value.
const PERCENT_AV = new Set([
  "MagickaRateMult", "StaminaRateMult", "HealRateMult", "SpeedMult", "WeaponSpeedMult",
  "CriticalChance", "ResistFire", "ResistFrost", "ResistMagic", "ResistPoison",
  "ResistDisease", "DamageResist",
]);

const AV_LABEL = {
  OneHanded: "One-Handed", TwoHanded: "Two-Handed", Marksman: "Archery",
  Block: "Block", BlockSkill: "Block", HeavyArmor: "Heavy Armor",
  UnarmedDamage: "Unarmed Damage", CriticalChance: "Critical Chance",
  Smithing: "Smithing", Alteration: "Alteration", Conjuration: "Conjuration",
  Destruction: "Destruction", Illusion: "Illusion", Restoration: "Restoration",
  Sneak: "Sneak", Lockpicking: "Lockpicking", Pickpocket: "Pickpocket",
  Speech: "Speech", Speechcraft: "Speech", SpeechcraftModifier: "Speech",
  CarryWeight: "Carry Weight", SpeedMult: "Movement Speed",
  WeaponSpeedMult: "Attack Speed", MagickaRateMult: "Magicka Regen",
  StaminaRateMult: "Stamina Regen", HealRateMult: "Health Regen",
  ResistFire: "Fire Resistance", ResistFrost: "Frost Resistance",
  ResistMagic: "Magic Resistance", ResistPoison: "Poison Resistance",
  ResistDisease: "Disease Resistance", DamageResist: "Armor Rating",
};

const COND_LABEL = {
  nearWaterOnly: "near water",
  nightOnly: "at night",
  homeOrShrineOnly: "at home or a shrine",
  homeOrPrivateOnly: "at home or in private",
  appliesAtPosture: "in the matching posture",
};

// Replace smart punctuation so the review copy stays ASCII-safe (repo rule).
function asciiSafe(s) {
  return String(s)
    .replace(/[‘’‛]/g, "'")
    .replace(/[“”]/g, '"')
    .replace(/[–—]/g, "-")
    .replace(/…/g, "...")
    .replace(/[^\x00-\x7F]/g, "");
}

function fmtEffect(e) {
  if (!e || e.actorValue === undefined || e.magnitude === undefined) return null;
  const label = AV_LABEL[e.actorValue] || e.actorValue;
  const mag = Number(e.magnitude);
  const sign = mag >= 0 ? "+" : "-";
  const unit = PERCENT_AV.has(e.actorValue) ? "%" : "";
  let s = `${sign}${Math.abs(mag)}${unit} ${label}`;
  const conds = Object.keys(COND_LABEL).filter((k) => e[k]);
  if (conds.length) s += ` (${conds.map((k) => COND_LABEL[k]).join(", ")})`;
  return s;
}

function effectsOf(rec) {
  if (Array.isArray(rec.effects)) return rec.effects;
  if (rec.effect && typeof rec.effect === "object") return [rec.effect];
  return [];
}

function recId(rec) {
  return rec.spellEditorId || rec.magicEffectEditorId || rec.editorId || rec.id || "(unnamed)";
}

function collect(node, file, out) {
  if (Array.isArray(node)) { node.forEach((n) => collect(n, file, out)); return; }
  if (!node || typeof node !== "object") return;
  if (typeof node.playerFacingText === "string") {
    const raw = effectsOf(node).filter((e) => e && e.actorValue !== undefined && e.magnitude !== undefined);
    const effects = raw.map(fmtEffect).filter(Boolean);
    if (effects.length) {
      const text = asciiSafe(node.playerFacingText).trim();
      // "clear" = every effect magnitude already appears as a number in the text.
      const allPresent = raw.every((e) => new RegExp(`\\b${Math.abs(Number(e.magnitude))}\\b`).test(text));
      out.push({
        file,
        id: recId(node),
        name: node.displayName || "",
        text,
        clause: effects.join(", "),
        status: allPresent ? "clear" : "ADD",
      });
    }
  }
  for (const k of Object.keys(node)) collect(node[k], file, out);
}

function proposed(text, clause) {
  const base = text.replace(/\s+$/, "");
  const head = base.endsWith(".") || base.endsWith("!") || base.endsWith("?") ? base : `${base}.`;
  return `${head} (Effect: ${clause}.)`;
}

function main() {
  const files = fs.readdirSync(SRC_DIR).filter((f) => SRC_RE.test(f)).sort();
  const records = [];
  for (const f of files) {
    let json;
    try { json = JSON.parse(fs.readFileSync(path.join(SRC_DIR, f), "utf8")); }
    catch (e) { console.error(`skip ${f}: ${e.message}`); continue; }
    collect(json, f, records);
  }

  // De-dupe by id (the same boon can be referenced in more than one place).
  const byId = new Map();
  for (const r of records) if (!byId.has(r.id)) byId.set(r.id, r);
  const rows = [...byId.values()];

  const byFile = new Map();
  for (const r of rows) {
    if (!byFile.has(r.file)) byFile.set(r.file, []);
    byFile.get(r.file).push(r);
  }

  const L = [];
  L.push("# Reward / Boon / Price Description Clarity - Review (task #16)");
  L.push("");
  L.push("**Generated:** 2026-06-09 by `tools/pdv_reward_desc_audit.mjs` (re-run to refresh).");
  L.push("**Status:** REVIEW-READY copy. Not yet authored into records.");
  L.push("");
  L.push("Each row keeps the existing thematic `playerFacingText` and appends a literal");
  L.push("mechanical clause so boon/price/reward descriptions reach deity-parity clarity.");
  L.push("All effects are constant (passive ability) -- the clause states the standing");
  L.push("magnitude, not a duration. Approve the wording, then re-author the MGEF/SPEL");
  L.push("`Description` from the `Proposed` column on the Windows box (author tools read");
  L.push("`playerFacingText`; update the spec text there so re-authoring is idempotent).");
  L.push("");
  const addCount = rows.filter((r) => r.status === "ADD").length;
  L.push(`**Coverage:** ${rows.length} records across ${byFile.size} spec files - ` +
    `**${addCount} need a magnitude clause (ADD)**, ${rows.length - addCount} already state it (clear).`);
  L.push("");
  L.push("`ADD` = the description does not state the magnitude and should get the clause.");
  L.push("`clear` = the magnitude already appears in the text (shown for audit; no change needed).");
  L.push("");

  const cell = (s) => s.replace(/\|/g, "\\|");

  // ADD rows first, as a single actionable worklist, then the per-file clear audit.
  L.push("## Worklist - records needing a magnitude clause (ADD)");
  L.push("");
  L.push("| EditorID | Effect clause | Proposed description |");
  L.push("| --- | --- | --- |");
  for (const r of rows.filter((x) => x.status === "ADD").sort((a, b) => a.id.localeCompare(b.id))) {
    L.push(`| \`${cell(r.id)}\` | ${cell(r.clause)} | ${cell(proposed(r.text, r.clause))} |`);
  }
  L.push("");

  L.push("## Audit - already-clear records (no change needed), by file");
  L.push("");
  for (const f of [...byFile.keys()].sort()) {
    const recs = byFile.get(f).filter((r) => r.status === "clear");
    if (!recs.length) continue;
    L.push(`### ${f} (${recs.length})`);
    L.push("");
    L.push("| EditorID | Effect clause | Current description |");
    L.push("| --- | --- | --- |");
    for (const r of recs.sort((a, b) => a.id.localeCompare(b.id))) {
      L.push(`| \`${cell(r.id)}\` | ${cell(r.clause)} | ${cell(r.text)} |`);
    }
    L.push("");
  }

  const doc = `${L.join("\n")}\n`;
  if (process.argv.includes("--stdout")) {
    process.stdout.write(doc);
  } else {
    fs.writeFileSync(OUT, doc, "utf8");
    console.log(`Wrote ${path.relative(ROOT, OUT)} (${rows.length} records, ${byFile.size} files).`);
  }
}

main();
