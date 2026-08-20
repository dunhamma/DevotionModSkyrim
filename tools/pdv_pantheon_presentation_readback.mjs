#!/usr/bin/env node
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_pantheon_presentation_readback" });

const json = process.argv.includes("--json");
const findings = [];
const pass = (check, detail) => findings.push({ status: "PASS", check, detail });
const fail = (check, detail) => findings.push({ status: "FAIL", check, detail });
const norm = (value) => String(value ?? "").trim().toLowerCase();

function blocks(text, type) {
  return String(text).split(new RegExp(`(?=\\r?\\ntype=${type}\\s)`, "i")).filter((part) => part.includes(`type=${type}`));
}
function field(block, name) {
  return block.match(new RegExp(`\\n\\s*${name.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\$&")}\\s*=\\s*(.+)\\r?$`, "m"))?.[1]?.trim() ?? "";
}
function formIds(block, pattern) {
  return [...block.matchAll(pattern)].map((match) => match[1]);
}
function inventory(text, prefix) {
  const out = new Map();
  for (const match of String(text).matchAll(new RegExp(`formid=([0-9A-Fa-f]{6}:[^\\s]+)\\s+editorid=(${prefix}[A-Za-z0-9_]+)`, "g"))) out.set(match[2], match[1]);
  return out;
}
function scriptPropertyMap(block, scriptIndex) {
  const names = new Map();
  const values = new Map();
  const prefix = `VirtualMachineAdapter\\.Scripts\\[${scriptIndex}\\]\\.Properties`;
  for (const line of block.split(/\r?\n/)) {
    const item = line.match(new RegExp(`${prefix}\\[(\\d+)\\](?:\\.Name)?\\s*=.*?Name=([A-Za-z0-9_]+)`));
    if (item) names.set(item[1], item[2]);
    const scalar = line.match(new RegExp(`${prefix}\\[(\\d+)\\]\\.Name\\s*=\\s*([A-Za-z0-9_]+)`));
    if (scalar) names.set(scalar[1], scalar[2]);
  }
  for (const line of block.split(/\r?\n/)) {
    const object = line.match(new RegExp(`${prefix}\\[(\\d+)\\]\\.Object\\s*=\\s*([0-9A-Fa-f]{6}:[^\\s\\r\\n]+)`));
    if (object && names.has(object[1])) values.set(names.get(object[1]), object[2]);
  }
  return values;
}

async function main() {
  const imperialGods = ["Akatosh", "Mara", "Arkay", "Stendarr", "Zenithar", "Dibella", "Julianos", "Kynareth", "Talos"];
  const focusedEditors = [
    ...imperialGods.flatMap((god) => [1, 2, 3].map((tier) => `PDV_Bless_Imperial_${god}_T${tier}`)),
    ...[1, 2, 3].map((tier) => `PDV_Bless_Nord_Talos_T${tier}`),
  ];
  const [imperialInventory, nordTalosInventory] = await Promise.all([
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], type: "SPEL", editorid_contains: "PDV_Bless_Imperial_", fields: ["EditorID"], limit: 100, max_chars: 60_000 }),
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], type: "SPEL", editorid_contains: "PDV_Bless_Nord_Talos_", fields: ["EditorID"], limit: 20, max_chars: 20_000 }),
  ]);
  const spellInventory = new Map([
    ...inventory(extractHousecarlText(imperialInventory), "PDV_Bless_Imperial_").entries(),
    ...inventory(extractHousecarlText(nordTalosInventory), "PDV_Bless_Nord_Talos_").entries(),
  ]);
  const focusedIds = focusedEditors.map((editor) => spellInventory.get(editor)).filter(Boolean);
  const focusedSpellResult = await callHousecarl("housecarl_batch_record_detail", { formids: focusedIds, fields: ["EditorID", "Name", "Effects"], depth: 4, max_chars: 220_000 });
  const parentSpellNames = new Map();
  for (const block of blocks(extractHousecarlText(focusedSpellResult), "Spell")) {
    const editor = field(block, "EditorID");
    const name = field(block, "Name");
    if (!focusedEditors.includes(editor)) continue;
    for (const effect of formIds(block, /Effects\[\d+\]\.BaseEffect\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g)) parentSpellNames.set(effect, name);
  }
  const focusedMgefResult = await callHousecarl("housecarl_batch_record_detail", { formids: [...parentSpellNames.keys()], fields: ["EditorID", "Name"], depth: 2, max_chars: 140_000 });
  const actualMgefNames = new Map(blocks(extractHousecarlText(focusedMgefResult), "MagicEffect").map((block) => [field(block, "FormKey") || block.match(/formid=([0-9A-Fa-f]{6}:[^\s]+)/)?.[1], field(block, "Name")]));
  for (const [effect, parentName] of parentSpellNames) {
    const actualName = actualMgefNames.get(effect);
    if (actualName && actualName !== parentName) pass("focused Active Effects presentation", `${effect} uses its own mechanical label ${actualName}.`);
    else fail("focused Active Effects presentation", `${effect} is ${actualName || "unreadable"}; it must not duplicate parent boon ${parentName}.`);
  }

  const substrates = new Map([
    ["PDV_Substrate_KhajiitLunar", "04C8A4:Devotion.esp"],
    ["PDV_Substrate_DunmerAncestor", "04C8A5:Devotion.esp"],
    ["PDV_Substrate_ArgonianHist", "04C8A6:Devotion.esp"],
    ["PDV_Substrate_NordAncestor", "07159C:Devotion.esp"],
    ["PDV_Substrate_AltmerAncestor", "0715AC:Devotion.esp"],
    ["PDV_Substrate_ImperialAncestor", "0715B6:Devotion.esp"],
  ]);
  const [substrateResult, activeListResult] = await Promise.all([
    callHousecarl("housecarl_batch_record_detail", { formids: [...substrates.values()], fields: ["EditorID", "VirtualMachineAdapter.Scripts"], depth: 5, max_chars: 260_000 }),
    callHousecarl("housecarl_read_record", { formid: "04C8AE:Devotion.esp", fields: ["EditorID", "Items"], depth: 3, max_chars: 20_000 }),
  ]);
  const substrateText = extractHousecarlText(substrateResult);
  for (const [editor, formid] of substrates) {
    const block = blocks(substrateText, "Quest").find((part) => field(part, "EditorID") === editor) || "";
    const base = scriptPropertyMap(block, 0);
    const derived = scriptPropertyMap(block, 1);
    for (const property of ["Substrate_Always", "Substrate_Mid", "Substrate_High"]) {
      if (base.has(property) && norm(base.get(property)) === norm(derived.get(property))) pass("all-substrate inherited VMAD", `${editor} base and derived scripts agree on ${property}.`);
      else fail("all-substrate inherited VMAD", `${editor} does not bind the same ${property} on both scripts.`);
    }
    if (!block.includes(`formid=${formid.split(":")[0]}`)) fail("all-substrate identity", `${editor} did not resolve to ${formid}.`);
  }
  const activeItems = new Set(formIds(extractHousecarlText(activeListResult), /Items\[\d+\]\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g).map(norm));
  const expectedActive = new Set([...substrates.values()].map(norm));
  if (activeItems.size === expectedActive.size && [...activeItems].every((item) => expectedActive.has(item))) pass("active substrate FormList", "Exactly the six paced substrates are active; Breton compatibility is excluded.");
  else fail("active substrate FormList", `Active substrate membership is ${[...activeItems].join(", ")}.`);

  const broadSpecs = new Map([
    ["071071:Devotion.esp", { name: "The Divines' Regard - Observant", effects: [["PoisonResist", 10, "Poison Resistance"]] }],
    ["0710BB:Devotion.esp", { name: "The Divines' Regard - Faithful", effects: [["PoisonResist", 10, "Poison Resistance"], ["ResistDisease", 10, "Disease Resistance"]] }],
    ["071073:Devotion.esp", { name: "Old Ways - Observant", effects: [["Stamina", 15, "Fortify Stamina"]] }],
    ["0711B6:Devotion.esp", { name: "Old Ways - Faithful", effects: [["Stamina", 25, "Fortify Stamina"], ["ResistFrost", 10, "Frost Resistance"]] }],
    ["0716C4:Devotion.esp", { name: "Faith of the Holds - Observant", effects: [["PoisonResist", 10, "Poison Resistance"]] }],
    ["0716C5:Devotion.esp", { name: "Faith of the Holds - Faithful", effects: [["PoisonResist", 10, "Poison Resistance"], ["ResistDisease", 10, "Disease Resistance"]] }],
  ]);
  const broadSpellResult = await callHousecarl("housecarl_batch_record_detail", { formids: [...broadSpecs.keys()], fields: ["EditorID", "Name", "Effects"], depth: 4, max_chars: 70_000 });
  const broadBlocks = blocks(extractHousecarlText(broadSpellResult), "Spell");
  const broadMgefIds = [...new Set(broadBlocks.flatMap((block) => formIds(block, /Effects\[\d+\]\.BaseEffect\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g)))];
  const broadMgefResult = await callHousecarl("housecarl_batch_record_detail", { formids: broadMgefIds, fields: ["Name", "Archetype"], depth: 3, max_chars: 50_000 });
  const broadMgefDetails = new Map(blocks(extractHousecarlText(broadMgefResult), "MagicEffect").map((block) => [
    block.match(/formid=([0-9A-Fa-f]{6}:[^\s]+)/)?.[1],
    [field(block, "Archetype.ActorValue"), field(block, "Name")],
  ]));
  for (const [formid, spec] of broadSpecs) {
    const block = broadBlocks.find((part) => part.includes(`formid=${formid.split(":")[0]}`)) || "";
    const ids = formIds(block, /Effects\[\d+\]\.BaseEffect\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g);
    const magnitudes = [...block.matchAll(/Effects\[\d+\]\.Data\.Magnitude\s*=\s*([-0-9.]+)/g)].map((match) => Number(match[1]));
    const actual = ids.map((id, index) => [...(broadMgefDetails.get(id) || ["", ""]), magnitudes[index]]).map(([actorValue, effectName, magnitude]) => [actorValue, magnitude, effectName]);
    if (field(block, "Name") === spec.name && JSON.stringify(actual) === JSON.stringify(spec.effects)) pass("broad reward packet", `${spec.name} matches its locked effect packet.`);
    else fail("broad reward packet", `${formid} read ${field(block, "Name")} ${JSON.stringify(actual)}; expected ${spec.name} ${JSON.stringify(spec.effects)}.`);
  }

  const moonIds = Array.from({ length: 20 }, (_, index) => `${(0x716c8 + index).toString(16).toUpperCase().padStart(6, "0")}:Devotion.esp`);
  const [moonRecordsResult, moonMessagesResult, managerResult] = await Promise.all([
    callHousecarl("housecarl_batch_record_detail", { formids: ["0716C6:Devotion.esp", "0716C7:Devotion.esp", "0716DC:Devotion.esp", "070523:Devotion.esp", "070524:Devotion.esp"], fields: ["EditorID", "Name", "Effects", "Items", "Type", "TargetType", "CastType", "EquipmentType", "Flags"], depth: 4, max_chars: 60_000 }),
    callHousecarl("housecarl_batch_record_detail", { formids: moonIds, fields: ["EditorID", "Name", "Description"], depth: 2, max_chars: 100_000 }),
    callHousecarl("housecarl_read_record", { formid: "00C325:Devotion.esp", fields: Array.from({ length: 75 }, (_, i) => `VirtualMachineAdapter.Scripts[0].Properties[${440 + i}]`), depth: 3, max_chars: 180_000 }),
  ]);
  const moonText = extractHousecarlText(moonRecordsResult);
  const moonList = blocks(moonText, "FormList")[0] || "";
  const actualMoonIds = formIds(moonList, /Items\[\d+\]\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g);
  if (JSON.stringify(actualMoonIds.map(norm)) === JSON.stringify(moonIds.map(norm))) pass("Observe the Moons records", "The ordered contemplation FormList contains the exact 20 messages.");
  else fail("Observe the Moons records", "The ordered contemplation FormList is missing, reordered, or contains extra messages.");
  const moonSpell = blocks(moonText, "Spell").find((block) => block.includes("formid=0716C7:Devotion.esp")) || "";
  const moonEffect = blocks(moonText, "MagicEffect").find((block) => block.includes("formid=0716C6:Devotion.esp")) || "";
  const surveySpell = blocks(moonText, "Spell").find((block) => block.includes("formid=070524:Devotion.esp")) || "";
  const surveyEffect = blocks(moonText, "MagicEffect").find((block) => block.includes("formid=070523:Devotion.esp")) || "";
  if (field(moonSpell, "Name") === "Observe the Moons" && field(moonEffect, "Name") === "Observe the Moons" && moonSpell.includes("0716C6:Devotion.esp")) pass("Observe the Moons records", "Power and child effect names match and the power points at the effect.");
  else fail("Observe the Moons records", "Power/effect record family is not wired or named consistently.");
  const voicePowerContract = (spellBlock) => field(spellBlock, "Type") === "LesserPower"
    && field(spellBlock, "TargetType") === "Self"
    && field(spellBlock, "CastType") === "FireAndForget"
    && norm(field(spellBlock, "EquipmentType")) === norm("025BEE:Skyrim.esm");
  const powerMatchesSurvey = voicePowerContract(moonSpell)
    && voicePowerContract(surveySpell)
    && field(moonEffect, "Flags") === field(surveyEffect, "Flags");
  if (powerMatchesSurvey) pass("Observe the Moons power input", "Observe the Moons and Survey Devotion are self-targeted Lesser Powers bound to Skyrim's Voice slot with matching child-effect flags.");
  else fail("Observe the Moons power input", "Observe the Moons and Survey Devotion must both use Skyrim's Voice equipment type (025BEE), never EitherHand, and retain matching child-effect flags.");
  const managerProperties = scriptPropertyMap(extractHousecarlText(managerResult), 0);
  const moonBindings = new Map([
    ["PDV_Power_Khajiit_ObserveMoons", "0716C7:Devotion.esp"],
    ["PDV_FLST_KhajiitMoonContemplations", "0716DC:Devotion.esp"],
  ]);
  for (const [property, expected] of moonBindings) {
    if (norm(managerProperties.get(property)) === norm(expected)) pass("Observe the Moons manager VMAD", `${property} is bound to ${expected}.`);
    else fail("Observe the Moons manager VMAD", `${property} is ${managerProperties.get(property) || "unbound"}; expected ${expected}.`);
  }
  const deityOrder = ["Khenarthi", "Azurah", "BaanDar", "Rajhin", "Alkosh"];
  const messageBlocks = blocks(extractHousecarlText(moonMessagesResult), "Message");
  let ordered = messageBlocks.length === 20;
  for (let index = 0; index < messageBlocks.length; index++) ordered &&= field(messageBlocks[index], "EditorID").endsWith(`_${deityOrder[Math.floor(index / 4)]}`);
  if (ordered) pass("Observe the Moons messages", "Twenty authored messages are ordered four apiece for the five presiding gods.");
  else fail("Observe the Moons messages", "Message roster/order does not preserve four messages per presiding god.");

  const [visibleNameResult, visibleDescriptionResult] = await Promise.all([
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], where: ["Name contains Spine"], fields: ["EditorID", "Name"], limit: 100, max_chars: 30_000 }),
    callHousecarl("housecarl_cross_plugin_query", { plugins: ["Devotion.esp"], where: ["Description contains Spine"], fields: ["EditorID", "Description"], limit: 100, max_chars: 30_000 }),
  ]);
  const visibleText = `${extractHousecarlText(visibleNameResult)}\n${extractHousecarlText(visibleDescriptionResult)}`;
  if (!visibleText.match(/cross_plugin_query:\s*[1-9]\d* matches/i)) pass("player-visible Spine cleanup", "Winning plugin Name and Description fields contain zero Spine matches.");
  else fail("player-visible Spine cleanup", visibleText);

  const failures = findings.filter((finding) => finding.status === "FAIL").length;
  const report = { status: failures ? "FAIL" : "PASS", assertions: findings.length, failures, findings };
  if (json) console.log(JSON.stringify(report, null, 2));
  else {
    for (const finding of findings) console.log(`[${finding.status}] ${finding.check}: ${finding.detail}`);
    console.log(`Summary: ${report.status}; ${report.assertions} assertions; ${failures} failures`);
  }
  process.exitCode = failures ? 1 : 0;
}

main().catch((error) => {
  console.log(JSON.stringify({ status: "FAIL", assertions: findings.length, failures: 1, error: error.stack || error.message, findings }, null, 2));
  process.exitCode = 1;
});
