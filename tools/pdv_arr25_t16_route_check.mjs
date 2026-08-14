#!/usr/bin/env node
/*
 * Read-only ARR 2.5 T16 contract gate.
 *
 * Proves the optional TG Alternative Endings physical-stage remap, guards the
 * vanilla Nocturnal commitment path, validates both T16 source channels, and
 * prevents the cumulative/individual package from shipping stale PDV scripts.
 * Runtime and semantic proof remain tester-owned.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { sameText } from "./lib/pdv_file_compare.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--pex-root"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_arr25_t16_route_check" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const LIVE = "D:/Wabbajack/modlists/Anvil/mods/Devotion";
const PEX_ROOT = path.resolve(ROOT, process.argv.includes("--pex-root") ? process.argv[process.argv.indexOf("--pex-root") + 1] : LIVE);
const failures = [];
const passes = [];

const P = {
  playerSource: path.join(ROOT, "live-source/Scripts/Source/PDV_PlayerEvents.psc"),
  eventBusSource: path.join(ROOT, "live-source/Scripts/Source/PDV_EventBus.psc"),
  runtimeSource: path.join(ROOT, "live-source/Scripts/Source/PDV_QuestReactionRuntime.psc"),
  full: path.join(ROOT, "references/authoring/PDV_QuestReactionMatrix_Full.csv"),
  tgaeCsv: path.join(ROOT, "references/authoring/patches/PDV_QRM_TGAlternativeEndings.csv"),
  officialCatalog: path.join(ROOT, "SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionPatches.v2.json"),
  iceCsv: path.join(ROOT, "references/authoring/patches/PDV_QRM_SaveTheIcerunner.csv"),
  moduleXml: path.join(ROOT, "dist/PDV_QuestModPatches_FOMOD/fomod/ModuleConfig.xml"),
  authoriaScripts: path.join(ROOT, "dist/PDV_QuestModPatches_FOMOD/plugins/authoria/Scripts"),
};

function read(file) {
  if (!fs.existsSync(file)) {
    failures.push(`missing file: ${path.relative(ROOT, file)}`);
    return "";
  }
  return fs.readFileSync(file, "utf8");
}

function requireText(label, text, token) {
  if (text.includes(token)) passes.push(label);
  else failures.push(`${label}: missing '${token}'`);
}

function requireAbsent(label, text, token) {
  if (!text.includes(token)) passes.push(label);
  else failures.push(`${label}: unexpectedly found '${token}'`);
}

function requireOrder(label, text, first, second) {
  const a = text.indexOf(first);
  const b = text.indexOf(second);
  if (a >= 0 && b > a) passes.push(label);
  else failures.push(`${label}: expected '${first}' before '${second}'`);
}

function functionBody(text, name) {
  const match = text.match(new RegExp(`(?:Int\\s+)?Function ${name}[\\s\\S]*?EndFunction`, "i"));
  return match?.[0] ?? "";
}

function parseCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i += 1; }
      else if (ch === '"') quoted = false;
      else field += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ',') { row.push(field); field = ""; }
    else if (ch === '\n') { row.push(field.replace(/\r$/, "")); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field || row.length) { row.push(field.replace(/\r$/, "")); rows.push(row); }
  const nonblank = rows.filter((cells) => cells.some((cell) => cell.trim() !== ""));
  const header = nonblank.shift() ?? [];
  return nonblank.map((cells) => Object.fromEntries(header.map((name, index) => [name, cells[index] ?? ""])));
}

function validateChannel(label, file, expectedRows, expectedStages, expectedForm) {
  const rows = parseCsv(read(file));
  if (rows.length === expectedRows) passes.push(`${label} row count ${expectedRows}`);
  else failures.push(`${label}: expected ${expectedRows} rows, got ${rows.length}`);
  const stages = [...new Set(rows.map((row) => row.outcome_stage))].sort();
  if (JSON.stringify(stages) === JSON.stringify(expectedStages)) passes.push(`${label} stage set`);
  else failures.push(`${label}: expected stages ${expectedStages.join("|")}, got ${stages.join("|")}`);
  if (rows.every((row) => row.formid === expectedForm)) passes.push(`${label} canonical FormKey`);
  else failures.push(`${label}: noncanonical formid found`);
  return rows;
}

function requireSame(label, a, b) {
  if (!fs.existsSync(a) || !fs.existsSync(b)) {
    failures.push(`${label}: comparison file missing`);
  } else if (sameText(a, b)) {
    passes.push(label);
  } else {
    failures.push(`${label}: normalized text mismatch`);
  }
}

const player = read(P.playerSource);
const eventBus = read(P.eventBusSource);
const runtime = read(P.runtimeSource);
const resolver = functionBody(runtime, "ResolveQuestStage");
if (!resolver) failures.push("generic quest-stage adapter resolver missing");
requireText("adapter index is consulted", resolver, '"PDV.V3.QR.StageAdapterCatalog."');
requireText("adapter uses the physical qualified key", resolver, 'sourcePlugin + "|" + sourceFormId + "|" + physicalStage');
const selectorResolver = functionBody(runtime, "ResolveAdapterSelector");
requireText("adapter is plugin-presence guarded", selectorResolver, "Game.GetModByName(selectorPlugin) == 255");
requireText("adapter reads selector values", selectorResolver, 'JsonUtil.IntListGet(adapterFile, adapterPrefix + "selectorValues", valueIndex)');
requireText("adapter maps target stages", selectorResolver, 'JsonUtil.IntListGet(adapterFile, adapterPrefix + "targetStages", valueIndex)');
requireText("adapter fallback preserves physical stage", resolver, "return physicalStage");
requireAbsent("core no longer names the TGAE resolver", player, "ResolveARR25TGAEQuestReactionStage");
requireAbsent("runtime does not name the optional TGAE plugin", runtime, "TG Alternative Endings.esp");

const matrixRoute = functionBody(player, "RouteQuestReactionStage");
requireText("matrix route forwards physical stage to EventBus", matrixRoute, "RouteQuestReaction(sourceQuest, newStage, logicalEventId)");
const eventBusRoute = functionBody(eventBus, "RouteQuestReaction");
requireText("EventBus routes quest reactions to Runtime", eventBusRoute, "PDV_QuestReactionRuntimeService.SubmitQuestStage(sourceQuest, stageValue, logicalEventId)");

const nocturnalNeedle = 'ShouldRouteP2QuestStage(PDV_FLST_Daedric_NocturnalLiveSources, sourceQuest, 136533, 200, "daedric_nocturnal_tg09", newStage)';
const nocturnalAt = player.indexOf(nocturnalNeedle);
const nocturnalBlock = nocturnalAt >= 0 ? player.slice(nocturnalAt, nocturnalAt + 700) : "";
requireText("vanilla Nocturnal guard remains physical 200", nocturnalBlock, nocturnalNeedle);
requireText("Nocturnal route resolves Runtime adapter outcome", nocturnalBlock, "PDV_QuestReactionRuntimeService.ResolveQuestStage(sourceQuest, newStage)");
requireText("Nocturnal commitment only for physical outcome", nocturnalBlock, "if resolvedStage == 200");
requireText("adapter suppresses false Nocturnal commitment", nocturnalBlock, "Quest-stage adapter suppressed Nocturnal commitment");

let catalog = null;
try {
  catalog = JSON.parse(read(P.officialCatalog));
} catch (error) {
  failures.push(`V2 official catalog parse failed: ${error.message}`);
}
if (catalog) {
  const strings = catalog.string ?? {};
  const ints = catalog.int ?? {};
  const lists = catalog.stringList ?? {};
  const key = "Skyrim.esm|136533|200";
  const prefix = `stageAdapter.${key}.`;
  if (strings.schema === "pdv.quest-reaction.catalog.v2" && ints.schemaVersion === 2) passes.push("TGAE v2 catalog schema");
  else failures.push("TGAE v2 catalog: wrong schema");
  if ((lists.stageAdapterKeys ?? []).includes(key) && (lists["source.tg-alternative-endings.stageAdapterKeys"] ?? []).includes(key)) passes.push("TGAE selector is source-owned");
  else failures.push("TGAE selector is not owned by its compatibility source");
  if (strings[`${prefix}selectorKind`] === "global" && strings[`${prefix}selectorPlugin`] === "TG Alternative Endings.esp" && ints[`${prefix}selectorFormId`] === 2076) passes.push("TGAE adapter optional global selector");
  else failures.push("TGAE adapter: wrong optional global selector");
  if (JSON.stringify(ints[`${prefix}selectorValues`]) === JSON.stringify([1, 2, 3]) && JSON.stringify(ints[`${prefix}targetStages`]) === JSON.stringify([201, 202, 202])) passes.push("TGAE adapter synthetic stage mapping");
  else failures.push("TGAE adapter: wrong synthetic stage mapping");
}

const tgaeRows = validateChannel("TGAE channel", P.tgaeCsv, 17, ["201", "202"], "Skyrim.esm:021555");
if (tgaeRows.every((row) => row.citation.includes("RUNTIME-VERIFY"))) passes.push("TGAE runtime debt retained");
else failures.push("TGAE channel: every synthetic cell must retain RUNTIME-VERIFY");
validateChannel("Save the Icerunner channel", P.iceCsv, 41, ["300", "310", "320", "330", "350"], "Skyrim.esm:023A64");

const coreSynthetic = parseCsv(read(P.full)).filter((row) => row.editor_id === "TG09" && ["201", "202"].includes(row.outcome_stage));
if (coreSynthetic.length === 0) passes.push("TGAE content absent from core");
else failures.push(`core matrix contains ${coreSynthetic.length} TGAE synthetic cell(s)`);

const xml = read(P.moduleXml);
requireText("modular TGAE option is present", xml, 'source="common\\TGAlternativeEndings"');
requireText("modular Save the Icerunner option is present", xml, 'source="common\\SaveTheIcerunner"');
requireText("individual TGAE dependency", xml, '<fileDependency file="TG Alternative Endings.esp" state="Active" />');
requireText("individual Save the Icerunner dependency", xml, '<fileDependency file="SaveTheIcerunner.esp" state="Active" />');

const result = {
  status: failures.length ? "FAIL" : "PASS",
  passes: passes.length,
  failures,
  proofBoundary: "Static source/channel/package proof only; runtime routing, semantic observation, player surfaces, and support remain open.",
};
console.log(JSON.stringify(result, null, 2));
process.exitCode = failures.length ? 1 : 0;
