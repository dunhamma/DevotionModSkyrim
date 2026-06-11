#!/usr/bin/env node
/*
 * Cumulative rebalance for the highest-tier-only reward consolidation.
 *
 * For each FOCUSED 3-tier family (emphasisRewards grouped by `emphasis` that has
 * a T3 tier), rewrites each tier spell's effects to the CUMULATIVE total up to
 * that tier (T2 = T1+T2, T3 = T1+T2+T3, summed per ActorValue) and adds a
 * per-effect `effectName` so the Active Effects list reads as named bonuses.
 * Power is preserved: with highest-tier-only sync, whichever single tier is
 * active now grants the accumulated total the additive stack used to give.
 *
 * SKIPS: 2-tier broad sets (already <=3 effects), broadState.rewards, substrate
 * slots (hand-done: explicit MGEF ids), and the Argonian spec (already done).
 *
 * Usage:
 *   node tools/pdv_cumulative_rebalance.mjs --dry    # print per-family result
 *   node tools/pdv_cumulative_rebalance.mjs --write   # rewrite the spec files
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const AUTHORING = path.resolve(__dirname, "..", "references", "authoring");

const RACES = ["Altmer", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"];

const TIER_RANK = { T1: 1, T2: 2, T3: 3, signature: 3 };

const EFFECT_NAMES = {
  MagickaRateMult: "Magicka Regeneration", HealRateMult: "Health Regeneration", StaminaRateMult: "Stamina Regeneration",
  ResistMagic: "Magic Resistance", ResistFire: "Fire Resistance", ResistFrost: "Frost Resistance",
  ResistPoison: "Poison Resistance", ResistDisease: "Disease Resistance", DamageResist: "Armor",
  CarryWeight: "Carry Weight", Sneak: "Sneak", UnarmedDamage: "Unarmed Damage", SpeedMult: "Movement Speed",
  OneHanded: "One-Handed", TwoHanded: "Two-Handed", Block: "Block", Smithing: "Smithing", HeavyArmor: "Heavy Armor",
  LightArmor: "Light Armor", Alteration: "Alteration", Restoration: "Restoration", Conjuration: "Conjuration",
  Illusion: "Illusion", Destruction: "Destruction", Enchanting: "Enchanting", Alchemy: "Alchemy",
  Speechcraft: "Speech", Speech: "Speech", Marksman: "Archery", Archery: "Archery", Lockpicking: "Lockpicking",
  Pickpocket: "Pickpocket", CriticalChance: "Critical Chance", Block: "Block", BlockSkill: "Block",
};

function effectName(av) {
  if (!EFFECT_NAMES[av]) {
    throw new Error(`No effectName mapping for ActorValue '${av}' -- add it to EFFECT_NAMES.`);
  }
  return EFFECT_NAMES[av];
}

const write = process.argv.includes("--write");
let totalFamilies = 0;
const report = [];

for (const race of RACES) {
  const file = path.join(AUTHORING, `PDV_${race}RewardRecords.spec.json`);
  const spec = JSON.parse(fs.readFileSync(file, "utf8"));
  const rewards = spec.emphasisRewards || [];

  // Group by emphasis, in first-seen order.
  const groups = new Map();
  for (const r of rewards) {
    if (!groups.has(r.emphasis)) groups.set(r.emphasis, []);
    groups.get(r.emphasis).push(r);
  }

  for (const [emphasis, members] of groups) {
    members.sort((a, b) => (TIER_RANK[a.tier] || 0) - (TIER_RANK[b.tier] || 0));
    const hasT3 = members.some((m) => TIER_RANK[m.tier] === 3);
    if (!hasT3 || members.length < 2) continue; // broad/2-tier -> leave additive

    totalFamilies += 1;
    // Accumulate per-ActorValue as we climb the tiers; each tier gets the
    // running total (union of all ActorValues seen so far).
    const running = new Map(); // av -> { sum, nightOnly }
    const order = [];
    const lines = [`  ${race} / ${emphasis}:`];
    for (const m of members) {
      for (const e of m.effects) {
        if (!running.has(e.actorValue)) { running.set(e.actorValue, { sum: 0, nightOnly: false }); order.push(e.actorValue); }
        const acc = running.get(e.actorValue);
        acc.sum += e.magnitude;
        if (e.nightOnly) acc.nightOnly = true;
      }
      // Rewrite this tier's effects to the running cumulative totals.
      m.effects = order.filter((av) => running.has(av)).map((av) => {
        const acc = running.get(av);
        const out = { actorValue: av, magnitude: acc.sum, effectName: effectName(av) };
        if (acc.nightOnly) out.nightOnly = true;
        return out;
      });
      lines.push(`    ${m.tier.padEnd(9)} ${m.effects.map((e) => `${e.actorValue}+${e.magnitude}`).join(", ")}`);
    }
    report.push(lines.join("\n"));
  }

  if (write) fs.writeFileSync(file, JSON.stringify(spec, null, 2) + "\n", "utf8");
}

console.log(report.join("\n\n"));
console.log(`\n${write ? "WROTE" : "DRY"}: ${totalFamilies} focused families across ${RACES.length} races.`);
