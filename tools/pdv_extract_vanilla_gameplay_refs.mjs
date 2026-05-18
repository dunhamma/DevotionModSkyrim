#!/usr/bin/env node
/**
 * Extract focused vanilla/DLC gameplay reference tables for PDV design work.
 *
 * This is a read-only Mutagen bridge client. It reads stock Skyrim master files
 * from the local Anvil install and writes generated CSV reference tables under
 * references/vanilla-gameplay/extracted/.
 */

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const PROJECT_ROOT = process.cwd();
const DATA_ROOT = "D:/Wabbajack/modlists/Anvil/Stock Game/Data";
const CLEANED_MASTERS_ROOT = "D:/Wabbajack/modlists/Anvil/mods/Cleaned Base Game Masters";
const BRIDGE = "D:/Wabbajack/modlists/Anvil/plugins/Anvilmo2_mcp/tools/mutagen-bridge/mutagen-bridge.exe";
const OUTPUT_DIR = path.join(PROJECT_ROOT, "references", "vanilla-gameplay", "extracted");
const MAX_BUFFER = 512 * 1024 * 1024;

const PLUGINS = [
  { name: "Skyrim.esm", root: DATA_ROOT },
  { name: "Update.esm", root: DATA_ROOT },
  { name: "Dawnguard.esm", root: CLEANED_MASTERS_ROOT },
  { name: "HearthFires.esm", root: CLEANED_MASTERS_ROOT },
  { name: "Dragonborn.esm", root: CLEANED_MASTERS_ROOT },
];

const RECORD_TYPES = new Set([
  "KYWD",
  "LCTN",
  "ACTI",
  "MGEF",
  "SPEL",
  "BOOK",
  "INGR",
  "ALCH",
  "FACT",
  "QUST",
  "COBJ",
  "NPC_",
  "WEAP",
  "ARMO",
  "RACE",
]);

const RELIGION_TERMS = [
  "aedra", "akatosh", "arkay", "auriel", "auriel", "azura", "azurah",
  "boeth", "daedra", "daedric", "dibella", "divine", "god", "gods",
  "hircine", "julianos", "kynareth", "kyne", "mara", "malacath",
  "mehrunes", "mephala", "meridia", "molag", "mora", "namira",
  "nocturnal", "peryite", "sanguine", "sheogorath", "shrine",
  "stendarr", "talos", "temple", "zenithar",
];

const QUEST_TERMS = [
  "darkbrotherhood", "college", "companion", "dawnguard", "temple", "thane",
  "vigil", "stendarr", "talos", "azura", "boeth", "hircine",
  "mephala", "molag", "mora", "namira", "nocturnal", "peryite",
  "sanguine", "sheogorath", "malacath", "mehrunes", "meridia",
];

const NPC_TERMS = [
  "priest", "temple", "vigil", "stendarr", "thalmor", "justiciar",
  "vampire", "werewolf", "silverhand", "cult", "daedra", "dremora",
  "orc", "stronghold", "khajiit", "caravan", "dawnguard", "bandit",
  "warlock", "necromancer", "forsworn",
];

const LOCATION_TERMS = [
  "temple", "shrine", "hallofdead", "hall", "city", "hold", "inn", "farm",
  "stronghold", "orc", "khajiit", "caravan", "tomb", "ruin", "barrow",
  "cave", "mine", "dungeon", "solstheim", "ravenrock", "thalmor", "vigil",
  "stendarr", "kynareth", "mara", "dibella", "talos", "azura", "boeth",
  "malacath",
];

const ITEM_TERMS = [
  "food", "meat", "venison", "rabbit", "pheasant", "horker", "salmon",
  "fish", "plant", "flower", "mushroom", "fungus", "root", "berry",
  "ore", "ingot", "hide", "leather", "pelt", "poison", "daedra",
  "heart", "salt", "ash", "moon", "nirnroot",
];

function main() {
  ensureOutputDir();

  const scans = [];
  const registry = new Map();
  for (const pluginSpec of PLUGINS) {
    const pluginName = pluginSpec.name;
    const pluginPath = path.posix.join(pluginSpec.root, pluginName);
    const scan = bridge({
      command: "scan",
      plugins: [pluginPath],
    }, 120_000).plugins?.[0];
    if (!scan) {
      throw new Error(`No scan payload for ${pluginName}`);
    }
    scans.push({ pluginName, pluginPath, scan });
    for (const record of scan.records || []) {
      if (record.formid) {
        registry.set(record.formid, {
          plugin: pluginName,
          formid: record.formid,
          type: record.type || "",
          edid: record.edid || "",
        });
      }
    }
  }

  const records = [];
  for (const entry of scans) {
    for (const record of entry.scan.records || []) {
      if (RECORD_TYPES.has(record.type)) {
        records.push({
          pluginName: entry.pluginName,
          pluginPath: entry.pluginPath,
          type: record.type,
          formid: record.formid,
          edid: record.edid || "",
        });
      }
    }
  }

  const byType = groupBy(records, (record) => record.type);

  writeCsv("vanilla-keyword-inventory.csv", (byType.get("KYWD") || [])
    .filter((record) => record.edid)
    .sort(sortByPluginEdid)
    .map((record) => ({
      plugin: record.pluginName,
      formid: record.formid,
      editor_id: record.edid,
      pdv_initial_read: classifyKeyword(record.edid),
      validation: "extracted",
    })));

  const locationDetails = candidateDetails(byType.get("LCTN") || [], (record) => termMatch(record.edid, LOCATION_TERMS), { maxDepth: 2, chunkSize: 40, timeoutMs: 180_000 });
  writeCsv("vanilla-location-signal-candidates.csv", locationDetails.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    parent_location: resolve(field(detail, "ParentLocation"), registry),
    keywords: resolveList(field(detail, "Keywords"), registry),
    pdv_initial_read: classifyLocation(base.edid, field(detail, "Name"), resolveList(field(detail, "Keywords"), registry)),
    validation: "extracted",
  })).sort(sortByPluginEdid));

  const shrineActivators = candidateDetails(byType.get("ACTI") || [], (record) => termMatch(record.edid, ["shrine", "altar", "blessing", "temple", "standingstone", "doomstone", ...RELIGION_TERMS]));
  writeCsv("vanilla-shrine-activator-candidates.csv", shrineActivators.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    model: field(detail, "Model.File"),
    keywords: resolveList(field(detail, "Keywords"), registry),
    pdv_use: classifyShrineActivator(base.edid, field(detail, "Name")),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const magicEffects = detailsFor(byType.get("MGEF") || [], { maxDepth: 5, chunkSize: 100, timeoutMs: 180_000 });
  writeCsv("vanilla-magic-effect-palette.csv", magicEffects.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    archetype: field(detail, "Archetype.Type"),
    actor_value: field(detail, "Archetype.ActorValue"),
    magic_skill: field(detail, "MagicSkill"),
    resist_value: field(detail, "ResistValue"),
    cast_type: field(detail, "CastType"),
    target_type: field(detail, "TargetType"),
    flags: field(detail, "Flags"),
    pdv_initial_read: classifyMagicEffect(base.edid, field(detail, "Name"), field(detail, "Archetype.ActorValue"), field(detail, "Flags")),
    validation: "extracted",
  })).sort(sortByPluginEdid));

  const spells = candidateDetails(byType.get("SPEL") || [], (record) => termMatch(record.edid, ["blessing", "disease", "doom", "stone", "shrine", "vampire", "werewolf", "beast", "voice", "shout", ...RELIGION_TERMS]));
  writeCsv("vanilla-spell-effect-candidates.csv", spells.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    spell_type: field(detail, "Type"),
    cast_type: field(detail, "CastType"),
    target_type: field(detail, "TargetType"),
    effects: effectList(field(detail, "Effects"), registry),
    pdv_use: classifySpell(base.edid, field(detail, "Name")),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const books = candidateDetails(byType.get("BOOK") || [], (record) => termMatch(record.edid, ["book", "tome", "journal", "note", "letter", ...RELIGION_TERMS]));
  writeCsv("vanilla-book-signal-candidates.csv", books.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    type: field(detail, "Type"),
    teaches: resolveTeaching(field(detail, "Teaches"), registry),
    keywords: resolveList(field(detail, "Keywords"), registry),
    value: field(detail, "Value"),
    pdv_use: classifyBook(base.edid, field(detail, "Name"), field(detail, "Teaches")),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const itemRecords = [
    ...(byType.get("INGR") || []),
    ...(byType.get("ALCH") || []),
    ...(byType.get("WEAP") || []),
    ...(byType.get("ARMO") || []),
  ].filter((record) => termMatch(record.edid, ITEM_TERMS));
  const itemDetails = detailsFor(itemRecords, { maxDepth: 5, chunkSize: 100, timeoutMs: 180_000 });
  writeCsv("vanilla-item-semantic-candidates.csv", itemDetails.map(({ base, detail }) => ({
    plugin: base.pluginName,
    record_type: base.type,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    keywords: resolveList(field(detail, "Keywords"), registry),
    flags: field(detail, "Flags"),
    value: field(detail, "Value"),
    weight: field(detail, "Weight"),
    pdv_keyword_candidate: classifyItem(base.type, base.edid, field(detail, "Name"), field(detail, "Keywords"), registry),
    validation: "candidate-extracted",
  })).sort(sortByPluginTypeEdid));

  const factions = candidateDetails(byType.get("FACT") || [], (record) => termMatch(record.edid, ["crime", "jail", "guard", "thanes", "faction", "guild", ...NPC_TERMS, ...RELIGION_TERMS]));
  writeCsv("vanilla-faction-signal-candidates.csv", factions.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    flags: field(detail, "Flags"),
    crime_values: crimeSummary(field(detail, "CrimeValues")),
    relations: relationSummary(field(detail, "Relations"), registry),
    ranks: rankSummary(field(detail, "Ranks")),
    pdv_use: classifyFaction(base.edid),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const quests = (byType.get("QUST") || []).filter(isQuestCandidate);
  writeCsv("vanilla-quest-candidates.csv", quests.map((base) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    pdv_use: classifyQuest(base.edid, ""),
    detail_status: "scan-only; read specific quest records before implementing stage hooks",
    validation: "candidate-scan",
  })).sort(sortByPluginEdid));

  const recipes = candidateDetails(byType.get("COBJ") || [], (record) => termMatch(record.edid, ["temper", "craft", "recipe", "forge", "smelt", "cook", "food", "armor", "weapon", "leather", "jewelry", "staff", "dawnguard", "stalhrim", "bonemold", "nordic", "daedric", "orcish"]));
  writeCsv("vanilla-crafting-recipe-candidates.csv", recipes.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    workbench_keyword: resolve(field(detail, "WorkbenchKeyword"), registry),
    created_object: resolve(field(detail, "CreatedObject"), registry),
    created_count: field(detail, "CreatedObjectCount"),
    ingredients: itemStackSummary(field(detail, "Items"), registry),
    pdv_use: classifyRecipe(base.edid, resolve(field(detail, "WorkbenchKeyword"), registry), resolve(field(detail, "CreatedObject"), registry)),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const npcs = candidateDetails(byType.get("NPC_") || [], (record) => termMatch(record.edid, NPC_TERMS));
  writeCsv("vanilla-npc-actor-candidates.csv", npcs.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    race: resolve(field(detail, "Race"), registry),
    template: resolve(field(detail, "Template"), registry),
    factions: npcFactionSummary(field(detail, "Factions"), registry),
    keywords: resolveList(field(detail, "Keywords"), registry),
    ai_aggression: field(detail, "AIData.Aggression"),
    ai_assistance: field(detail, "AIData.Assistance"),
    pdv_use: classifyNpc(base.edid, field(detail, "Name")),
    validation: "candidate-extracted",
  })).sort(sortByPluginEdid));

  const races = detailsFor(byType.get("RACE") || [], { maxDepth: 5, chunkSize: 100, timeoutMs: 180_000 });
  writeCsv("vanilla-race-records.csv", races.map(({ base, detail }) => ({
    plugin: base.pluginName,
    formid: base.formid,
    editor_id: base.edid,
    name: field(detail, "Name"),
    keywords: resolveList(field(detail, "Keywords"), registry),
    flags: field(detail, "Flags"),
    actor_effects: resolveList(field(detail, "ActorEffects"), registry),
    pdv_use: classifyRace(base.edid, field(detail, "Name")),
    validation: "extracted",
  })).sort(sortByPluginEdid));

  writeReadme();
  console.log(`Wrote generated reference tables to ${OUTPUT_DIR}`);
}

function ensureOutputDir() {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

function bridge(request, timeoutMs) {
  const result = spawnSync(BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: MAX_BUFFER,
    windowsHide: true,
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `mutagen-bridge failed with ${result.status}`);
  }
  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${result.stderr || ""}`);
  }
  const payload = JSON.parse(stdout);
  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }
  return payload;
}

function detailsFor(records, options = {}) {
  const maxDepth = options.maxDepth ?? 8;
  const chunkSize = options.chunkSize ?? 120;
  const timeoutMs = options.timeoutMs ?? 180_000;
  const out = [];
  const byPlugin = groupBy(records, (record) => record.pluginPath);
  for (const [pluginPath, pluginRecords] of byPlugin.entries()) {
    for (const chunk of chunks(pluginRecords, chunkSize)) {
      const payload = bridge({
        command: "read_records",
        max_depth: maxDepth,
        records: chunk.map((record) => ({
          plugin_path: pluginPath,
          formid: record.formid,
        })),
      }, timeoutMs);
      for (let i = 0; i < chunk.length; i += 1) {
        const detail = payload.records?.[i];
        if (detail?.success) {
          out.push({ base: chunk[i], detail });
        }
      }
    }
  }
  return out;
}

function candidateDetails(records, predicate, options = {}) {
  return detailsFor(records.filter(predicate), options);
}

function writeCsv(fileName, rows) {
  const filePath = path.join(OUTPUT_DIR, fileName);
  const columns = rows.length ? Object.keys(rows[0]) : ["note"];
  const lines = [
    columns.join(","),
    ...rows.map((row) => columns.map((column) => csvCell(row[column])).join(",")),
  ];
  fs.writeFileSync(filePath, `${lines.join("\n")}\n`, "utf8");
  console.log(`${fileName}: ${rows.length} rows`);
}

function writeReadme() {
  const body = `# Extracted Vanilla Gameplay Tables

Status: generated reference tables

Generated by \`node .\\tools\\pdv_extract_vanilla_gameplay_refs.mjs\`.

These tables are extracted from the local Anvil stock/cleaned base masters:
\`Skyrim.esm\` and \`Update.esm\` from Stock Game, plus \`Dawnguard.esm\`,
\`HearthFires.esm\`, and \`Dragonborn.esm\` from Anvil's Cleaned Base Game
Masters mod. Treat them as implementation reference data, not final PDV design
decisions. Curated design meaning belongs in the sibling \`pdv-crosswalk/\`
tables.
`;
  fs.writeFileSync(path.join(OUTPUT_DIR, "README.md"), body, "utf8");
}

function csvCell(value) {
  if (value === undefined || value === null) {
    return "";
  }
  const text = Array.isArray(value) ? value.join("; ") : String(value);
  if (/[",\n\r]/.test(text)) {
    return `"${text.replaceAll('"', '""')}"`;
  }
  return text;
}

function groupBy(items, keyFn) {
  const groups = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key).push(item);
  }
  return groups;
}

function chunks(items, size) {
  const out = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

function field(detail, pathText) {
  const parts = pathText.split(".");
  let current = detail.fields;
  for (const part of parts) {
    if (current === undefined || current === null) {
      return "";
    }
    current = current[part];
  }
  return current ?? "";
}

function resolve(value, registry) {
  if (!value) {
    return "";
  }
  if (typeof value === "object") {
    if (value.Link) {
      return resolve(value.Link, registry);
    }
    if (value.Item) {
      return resolve(value.Item, registry);
    }
  }
  const text = String(value);
  const entry = registry.get(text);
  if (!entry) {
    return text;
  }
  return entry.edid ? `${entry.edid} (${text})` : text;
}

function resolveList(value, registry) {
  if (!Array.isArray(value)) {
    return "";
  }
  return value.map((item) => resolve(item, registry)).filter(Boolean).join("; ");
}

function resolveTeaching(value, registry) {
  if (!value || typeof value !== "object") {
    return "";
  }
  const parts = [];
  for (const [key, val] of Object.entries(value)) {
    parts.push(`${key}:${resolve(val, registry)}`);
  }
  return parts.join("; ");
}

function effectList(effects, registry) {
  if (!Array.isArray(effects)) {
    return "";
  }
  return effects.map((effect) => {
    const base = resolve(effect.BaseEffect, registry);
    const data = effect.Data || {};
    return `${base}|mag=${data.Magnitude ?? ""}|area=${data.Area ?? ""}|dur=${data.Duration ?? ""}`;
  }).join("; ");
}

function itemStackSummary(items, registry) {
  if (!Array.isArray(items)) {
    return "";
  }
  return items.map((entry) => {
    const item = entry.Item || {};
    return `${resolve(item.Item, registry)} x${item.Count ?? ""}`;
  }).join("; ");
}

function npcFactionSummary(factions, registry) {
  if (!Array.isArray(factions)) {
    return "";
  }
  return factions.map((entry) => {
    const faction = resolve(entry.Faction || entry.FactionForm || entry.FormKey, registry);
    const rank = entry.Rank ?? "";
    return rank === "" ? faction : `${faction}:rank${rank}`;
  }).join("; ");
}

function crimeSummary(crimeValues) {
  if (!crimeValues || typeof crimeValues !== "object") {
    return "";
  }
  const keys = ["Arrest", "AttackOnSight", "Murder", "Assault", "Trespass", "Pickpocket", "StealMult", "Escape", "Werewolf"];
  return keys.map((key) => `${key}=${crimeValues[key] ?? ""}`).join("; ");
}

function relationSummary(relations, registry) {
  if (!Array.isArray(relations)) {
    return "";
  }
  return relations.slice(0, 8).map((relation) => `${resolve(relation.Target, registry)}:${relation.Reaction ?? ""}`).join("; ");
}

function rankSummary(ranks) {
  if (!Array.isArray(ranks)) {
    return "";
  }
  return ranks.map((rank) => `${rank.Index ?? ""}:${rank.MaleTitle || rank.FemaleTitle || ""}`).join("; ");
}

function stageSummary(stages) {
  if (!Array.isArray(stages)) {
    return "";
  }
  return stages.slice(0, 40).map((stage) => {
    const index = stage.Index ?? stage.Stage ?? "";
    const logCount = Array.isArray(stage.LogEntries) ? stage.LogEntries.length : "";
    return `${index}${logCount !== "" ? `(${logCount})` : ""}`;
  }).join("; ");
}

function termMatch(...values) {
  let terms;
  let textParts;
  if (Array.isArray(values.at(-1))) {
    terms = values.at(-1);
    textParts = values.slice(0, -1);
  } else {
    terms = [];
    textParts = values;
  }
  const text = textParts.filter(Boolean).join(" ").toLowerCase();
  return terms.some((term) => text.includes(String(term).toLowerCase()));
}

function isQuestCandidate(record) {
  const edid = (record.edid || "").toLowerCase();
  if (!edid) {
    return false;
  }
  if (/^da\d/.test(edid) || /^mq\d/.test(edid) || /^cw\d/.test(edid)) return true;
  if (/^tg\d/.test(edid) || /^db\d/.test(edid) || /^mg\d/.test(edid)) return true;
  if (/^c0\d/.test(edid) || /^c\d\d/.test(edid)) return true;
  if (/^dlc1/.test(edid) || /^dlc2/.test(edid) || /^byoh/.test(edid)) return true;
  return termMatch(edid, QUEST_TERMS);
}

function classifyKeyword(edid) {
  const lower = edid.toLowerCase();
  if (lower.startsWith("loctype")) return "location classification";
  if (lower.startsWith("actortype")) return "actor classification";
  if (lower.startsWith("weaptype") || lower.includes("armor") || lower.includes("clothing")) return "equipment classification";
  if (lower.includes("vendoritem")) return "item/economy classification";
  if (termMatch(lower, RELIGION_TERMS)) return "religion/theology candidate";
  return "general keyword";
}

function classifyLocation(edid, name, keywords) {
  const text = `${edid} ${name} ${keywords}`.toLowerCase();
  if (text.includes("temple") || text.includes("shrine")) return "temple/shrine/sacred-place candidate";
  if (text.includes("orc") || text.includes("stronghold")) return "orc community/sacred-place candidate";
  if (text.includes("city") || text.includes("hold")) return "civic/hold context candidate";
  if (text.includes("inn")) return "sleep/travel/community candidate";
  if (text.includes("dungeon") || text.includes("cave") || text.includes("ruin")) return "dungeon/pilgrimage/hostile-place candidate";
  return "location context candidate";
}

function classifyShrineActivator(edid, name) {
  const text = `${edid} ${name}`.toLowerCase();
  if (text.includes("standing") || text.includes("doom")) return "standing-stone contextual blessing";
  if (text.includes("shrine") || text.includes("altar")) return "shrine/prayer activation";
  return "religious activator candidate";
}

function classifyMagicEffect(edid, name, actorValue, flags) {
  const text = `${edid} ${name} ${actorValue} ${flags}`.toLowerCase();
  if (text.includes("blessing") || text.includes("shrine")) return "vanilla blessing/effect palette";
  if (text.includes("disease") || text.includes("vampire") || text.includes("werewolf")) return "curse/disease overlay";
  if (text.includes("resist") || text.includes("fortify") || text.includes("rate")) return "reward/neglect magnitude reference";
  if (text.includes("detrimental")) return "neglect/price effect reference";
  return "magic effect palette";
}

function classifySpell(edid, name) {
  const text = `${edid} ${name}`.toLowerCase();
  if (text.includes("blessing")) return "blessing spell/effect source";
  if (text.includes("disease") || text.includes("vampire") || text.includes("werewolf")) return "curse/disease state source";
  if (text.includes("doom") || text.includes("stone")) return "standing-stone pattern";
  return "spell signal/effect candidate";
}

function classifyBook(edid, name, teaches) {
  const text = `${edid} ${name}`.toLowerCase();
  if (teaches && Object.keys(teaches).length) return "spell-learned/book-read candidate";
  if (termMatch(text, RELIGION_TERMS)) return "sacred/forbidden text candidate";
  if (text.includes("journal") || text.includes("letter") || text.includes("note")) return "quest/document signal candidate";
  return "book-read candidate";
}

function classifyItem(type, edid, name, keywords, registry) {
  const text = `${type} ${edid} ${name} ${resolveList(keywords, registry)}`.toLowerCase();
  const tags = [];
  if (text.includes("food") || text.includes("meat") || text.includes("fish")) tags.push("PDV_FoodOrMeatCandidate");
  if (text.includes("plant") || text.includes("flower") || text.includes("mushroom") || text.includes("root")) tags.push("PDV_PlantMatterCandidate");
  if (text.includes("poison")) tags.push("PDV_PoisonCandidate");
  if (text.includes("ore") || text.includes("ingot") || text.includes("armor") || text.includes("weapon")) tags.push("PDV_CraftLaborCandidate");
  if (text.includes("daedra") || text.includes("heart")) tags.push("PDV_DaedricMaterialCandidate");
  return tags.join("; ") || "PDV_ItemReviewCandidate";
}

function classifyFaction(edid) {
  const lower = edid.toLowerCase();
  if (lower.includes("crime") || lower.includes("jail") || lower.includes("guard")) return "crime/hold/civic signal";
  if (lower.includes("thalmor") || lower.includes("justiciar")) return "Thalmor/Talos-ban pressure";
  if (lower.includes("vigil") || lower.includes("stendarr")) return "Vigilant/Stendarr signal";
  if (lower.includes("vampire") || lower.includes("necromancer") || lower.includes("warlock")) return "hostile occult signal";
  if (lower.includes("orc") || lower.includes("stronghold")) return "orc community signal";
  return "faction signal candidate";
}

function classifyQuest(edid, name) {
  const text = `${edid} ${name}`.toLowerCase();
  if (text.startsWith("da") || termMatch(text, ["azura", "boeth", "hircine", "molag", "mora", "namira", "nocturnal", "sanguine", "sheogorath", "peryite", "mehrunes", "meridia", "malacath", "mephala"])) return "Daedric/moral-choice candidate";
  if (text.startsWith("cw")) return "civil-war/Talos/civic candidate";
  if (text.startsWith("mq")) return "main-quest/Dragonborn candidate";
  if (text.includes("dawnguard") || text.startsWith("dlc1")) return "Dawnguard/vampire/Arkay-Stendarr candidate";
  if (text.startsWith("dlc2")) return "Solstheim/Hermaeus Mora/Dunmer candidate";
  if (text.startsWith("tg") || text.includes("thieves")) return "Nocturnal/theft candidate";
  if (text.startsWith("db") || text.includes("darkbrotherhood")) return "Sithis/assassination candidate";
  if (text.startsWith("mg") || text.includes("college")) return "Julianos/Magnus/magic-study candidate";
  return "quest-stage signal candidate";
}

function classifyRecipe(edid, workbench, created) {
  const text = `${edid} ${workbench} ${created}`.toLowerCase();
  if (text.includes("cook") || text.includes("food")) return "food/offering/Bosmer taboo craft";
  if (text.includes("forge") || text.includes("smith") || text.includes("temper") || text.includes("armor") || text.includes("weapon")) return "Malacath/Zenithar craft-labor";
  if (text.includes("smelt") || text.includes("ingot")) return "ore/smelting labor";
  if (text.includes("daedric")) return "Daedric material craft signal";
  return "crafting signal candidate";
}

function classifyNpc(edid, name) {
  const text = `${edid} ${name}`.toLowerCase();
  if (text.includes("priest") || text.includes("temple")) return "religious NPC/dialogue privilege candidate";
  if (text.includes("thalmor") || text.includes("justiciar")) return "Thalmor pressure actor";
  if (text.includes("vigil") || text.includes("stendarr")) return "Vigilant/Stendarr actor";
  if (text.includes("vampire") || text.includes("werewolf")) return "curse/hostile actor";
  if (text.includes("khajiit") || text.includes("caravan")) return "Khajiit community actor";
  if (text.includes("orc") || text.includes("stronghold")) return "Orc community actor";
  if (text.includes("bandit") || text.includes("warlock") || text.includes("necromancer")) return "hostile actor classification";
  return "NPC signal candidate";
}

function classifyRace(edid, name) {
  const text = `${edid} ${name}`.toLowerCase();
  if (text.includes("vampire")) return "origin normalization / vampire curse overlay";
  if (text.includes("werewolf") || text.includes("beast")) return "temporary beast-form / curse overlay";
  if (termMatch(text, ["argonian", "breton", "darkelf", "dunmer", "highelf", "altmer", "imperial", "khajiit", "nord", "orc", "redguard", "woodelf", "bosmer"])) return "playable-origin race";
  return "race reference";
}

function sortByPluginEdid(a, b) {
  return `${a.plugin || a.pluginName}|${a.editor_id || a.edid}`.localeCompare(`${b.plugin || b.pluginName}|${b.editor_id || b.edid}`);
}

function sortByPluginTypeEdid(a, b) {
  return `${a.plugin}|${a.record_type}|${a.editor_id}`.localeCompare(`${b.plugin}|${b.record_type}|${b.editor_id}`);
}

main();
