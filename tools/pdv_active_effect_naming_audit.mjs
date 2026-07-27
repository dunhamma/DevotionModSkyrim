#!/usr/bin/env node
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";

const json = process.argv.includes("--json");
const labels = new Map([["Stamina", "Fortify Stamina"], ["Magicka", "Fortify Magicka"], ["Health", "Maximum Health"], ["ResistMagic", "Magic Resistance"], ["ResistDisease", "Disease Resistance"], ["ResistFrost", "Frost Resistance"], ["ResistFire", "Fire Resistance"], ["PoisonResist", "Poison Resistance"], ["DamageResist", "Armor"], ["StaminaRateMult", "Stamina Regeneration"], ["MagickaRateMult", "Magicka Regeneration"], ["HealRateMult", "Health Regeneration"], ["CarryWeight", "Carry Weight"], ["OneHanded", "One-Handed"], ["TwoHanded", "Two-Handed"], ["Speech", "Speech"], ["Block", "Block"], ["Sneak", "Sneak"], ["Lockpicking", "Lockpicking"], ["Pickpocket", "Pickpocket"], ["Alteration", "Alteration"], ["Restoration", "Restoration"], ["Illusion", "Illusion"], ["Destruction", "Destruction"], ["Conjuration", "Conjuration"], ["Smithing", "Smithing"], ["HeavyArmor", "Heavy Armor"], ["Archery", "Archery"], ["CriticalChance", "Critical Chance"], ["AttackDamageMult", "Weapon Damage"], ["SpeedMult", "Movement Speed"], ["UnarmedDamage", "Unarmed Damage"]]);
const text = (result) => extractHousecarlText(result);
const blocks = (source, type) => String(source).split(new RegExp(`(?=\\r?\\ntype=${type}\\s)`, "i")).filter((block) => block.includes(`type=${type}`));
const field = (block, name) => block.match(new RegExp(`\\n\\s*${name.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\$&")}\\s*=\\s*(.+)\\r?$`, "m"))?.[1]?.trim() ?? "";
const formId = (block) => block.match(/formid=([0-9A-F]{6}:Devotion\.esp)/i)?.[1] ?? "";
async function main() {
  const inventory = await callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], type: "SPEL", editorid_contains: "PDV_Bless_", fields: ["EditorID", "Name"], limit: 500, max_chars: 120_000 });
  const spells = [...text(inventory).matchAll(/formid=([0-9A-F]{6}:Devotion\.esp)\s+editorid=PDV_Bless_/gi)].map((match) => match[1]);
  const spellDetails = await callHousecarl("housecarl_batch_record_detail", { formids: spells, fields: ["Name", "Effects"], depth: 4, max_chars: 280_000 });
  const parents = new Map();
  for (const block of blocks(text(spellDetails), "Spell")) for (const match of block.matchAll(/Effects\[\d+\]\.BaseEffect\s*=\s*([0-9A-F]{6}:Devotion\.esp)/gi)) parents.set(match[1].toLowerCase(), field(block, "Name"));
  const effectDetails = await callHousecarl("housecarl_batch_record_detail", { formids: [...parents.keys()], fields: ["EditorID", "Name", "Archetype"], depth: 3, max_chars: 260_000 });
  const findings = blocks(text(effectDetails), "MagicEffect").map((block) => { const actorValue = field(block, "Archetype.ActorValue"); const expected = labels.get(actorValue); const name = field(block, "Name"); const parent = parents.get(formId(block).toLowerCase()); const editor = field(block, "EditorID"); const isDaedricBoon = /Bless_Daedric_/i.test(editor); const valid = isDaedricBoon ? name !== "" : (expected ? name === expected : actorValue === "None" && name !== "" && name !== parent); return { status: valid ? "PASS" : "FAIL", editor, name, parent, actorValue, expected: isDaedricBoon ? "a Daedric boon heading (contract-specified, PDV_DaedricPrinceRecordContracts.json)" : (expected ?? "a distinct scripted-effect name") }; });
  const failures = findings.filter((finding) => finding.status === "FAIL"); const report = { status: failures.length ? "FAIL" : "PASS", spells: spells.length, activeEffects: findings.length, failures: failures.length, findings };
  if (json) console.log(JSON.stringify(report, null, 2)); else { for (const finding of failures) console.log(`[FAIL] ${finding.editor}: ${finding.name || "(blank)"}; expected ${finding.expected} (${finding.actorValue}), parent=${finding.parent}`); console.log(`Active-effect names: ${report.status}; spells=${report.spells}; effects=${report.activeEffects}; failures=${report.failures}`); }
  process.exitCode = failures.length ? 1 : 0;
}
main().catch((error) => { console.error(error.stack || error.message); process.exitCode = 1; });
