#!/usr/bin/env node
/*
 * Regenerate playerFacingText (spell Description) from the CURRENT effects so it
 * matches the cumulative magnitudes. Text-only: never touches magnitudes.
 *
 * Keeps each record's flavor lead (the leading sentences that contain no digit)
 * and appends an accurate, named effect summary built from the current effects.
 * Skips the Argonian spec (its text was hand-written accurately).
 *
 *   node tools/pdv_reward_desc_regen.mjs --dry     # print before -> after
 *   node tools/pdv_reward_desc_regen.mjs --write
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--write"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_reward_desc_regen" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const AUTHORING = path.resolve(__dirname, "..", "references", "authoring");
const RACES = ["Altmer", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"];

const PCT = new Set(["HealRateMult", "StaminaRateMult", "MagickaRateMult", "ResistMagic", "ResistFire",
  "ResistFrost", "ResistPoison", "ResistDisease", "CriticalChance", "SpeedMult"]);

const NAMES = {
  MagickaRateMult: "Magicka Regeneration", HealRateMult: "Health Regeneration", StaminaRateMult: "Stamina Regeneration",
  ResistMagic: "Magic Resistance", ResistFire: "Fire Resistance", ResistFrost: "Frost Resistance",
  ResistPoison: "Poison Resistance", ResistDisease: "Disease Resistance", DamageResist: "Armor",
  CarryWeight: "Carry Weight", Sneak: "Sneak", UnarmedDamage: "Unarmed Damage", SpeedMult: "Movement Speed",
  OneHanded: "One-Handed", TwoHanded: "Two-Handed", Block: "Block", BlockSkill: "Block", Smithing: "Smithing",
  HeavyArmor: "Heavy Armor", LightArmor: "Light Armor", Alteration: "Alteration", Restoration: "Restoration",
  Conjuration: "Conjuration", Illusion: "Illusion", Destruction: "Destruction", Enchanting: "Enchanting",
  Alchemy: "Alchemy", Speechcraft: "Speech", Speech: "Speech", Marksman: "Archery", Archery: "Archery",
  Lockpicking: "Lockpicking", Pickpocket: "Pickpocket",
};

function phrase(e) {
  const name = e.effectName || NAMES[e.actorValue] || e.actorValue;
  let p = `${name} +${e.magnitude}${PCT.has(e.actorValue) ? "%" : ""}`;
  if (e.nightOnly) p += " (at night)";
  return p;
}

// Leading sentences with no digit = flavor; drop the rest (old effect prose).
function flavorLead(text, fallback) {
  const sentences = String(text || "").split(/(?<=[.!?])\s+/);
  const kept = [];
  for (const s of sentences) {
    if (/\d/.test(s)) break;
    kept.push(s.trim());
  }
  const lead = kept.join(" ").trim();
  return lead.length ? lead : fallback;
}

const write = process.argv.includes("--write");
let count = 0;
const sample = [];

for (const race of RACES) {
  const file = path.join(AUTHORING, `PDV_${race}RewardRecords.spec.json`);
  const spec = JSON.parse(fs.readFileSync(file, "utf8"));

  const records = [];
  for (const r of spec.emphasisRewards || []) records.push(r);
  for (const r of spec.broadState?.rewards || []) records.push(r);
  for (const r of spec.substrateBoons?.slots || []) records.push(r);

  for (const r of records) {
    if (!r.effects || !r.effects.length) continue;
    const lead = flavorLead(r.playerFacingText, (r.displayName || "").trim());
    const list = r.effects.map(phrase).join(", ");
    const next = (lead ? lead + " " : "") + list + ".";
    if (next !== r.playerFacingText) {
      if (sample.length < 6) sample.push(`  ${race} ${r.spellEditorId}\n    OLD: ${r.playerFacingText}\n    NEW: ${next}`);
      r.playerFacingText = next;
      count += 1;
    }
  }

  if (write) fs.writeFileSync(file, JSON.stringify(spec, null, 2) + "\n", "utf8");
}

console.log(sample.join("\n\n"));
console.log(`\n${write ? "WROTE" : "DRY"}: ${count} descriptions regenerated across ${RACES.length} races.`);
