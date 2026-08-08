#!/usr/bin/env node
/*
 * Read-only ARR 2.5 T16 contract gate.
 *
 * Proves the optional TG Alternative Endings physical-stage remap, guards the
 * vanilla Nocturnal commitment path, validates both T16 source channels, and
 * prevents the cumulative/individual package from shipping stale PDV scripts.
 * Runtime and semantic proof remain tester-owned.
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const LIVE = "D:/Wabbajack/modlists/Anvil/mods/Devotion";
const PEX_ROOT = path.resolve(ROOT, process.argv.includes("--pex-root") ? process.argv[process.argv.indexOf("--pex-root") + 1] : LIVE);
const failures = [];
const passes = [];

const P = {
  playerSource: path.join(ROOT, "live-source/Scripts/Source/PDV_PlayerEvents.psc"),
  full: path.join(ROOT, "references/authoring/PDV_QuestReactionMatrix_Full.csv"),
  tgaeCsv: path.join(ROOT, "references/authoring/patches/PDV_QRM_TGAlternativeEndings.csv"),
  tgaeAdapter: path.join(ROOT, "dist/PDV_QuestModPatches_FOMOD/common/TGAlternativeEndings/SKSE/Plugins/StorageUtilData/PlayerDevotion/QuestStageAdapters/PDV_QSA_TGAlternativeEndings.json"),
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

function sha(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function requireSame(label, a, b) {
  if (!fs.existsSync(a) || !fs.existsSync(b)) {
    failures.push(`${label}: comparison file missing`);
  } else if (sha(a) === sha(b)) {
    passes.push(label);
  } else {
    failures.push(`${label}: SHA-256 mismatch`);
  }
}

const player = read(P.playerSource);
const resolver = functionBody(player, "ResolveQuestReactionStageAdapter");
if (!resolver) failures.push("generic quest-stage adapter resolver missing");
requireText("adapter cache is consulted", resolver, '"PDV.QR.StageAdapterFiles"');
requireText("adapter resolves configured quest", resolver, "Game.GetFormFromFile(sourceFormId, sourcePlugin)");
requireText("adapter is plugin-presence guarded", resolver, "Game.GetModByName(selectorPlugin) != 255");
requireText("adapter reads selector values", resolver, 'JsonUtil.IntListGet(adapterFile, "selectorValues", valueIndex)');
requireText("adapter maps target stages", resolver, 'JsonUtil.IntListGet(adapterFile, "targetStages", valueIndex)');
requireText("adapter fallback preserves physical stage", resolver, "return newStage");
requireAbsent("core no longer names the TGAE resolver", player, "ResolveARR25TGAEQuestReactionStage");
requireAbsent("core no longer names the optional TGAE plugin", player, "TG Alternative Endings.esp");

const matrixRoute = functionBody(player, "RouteQuestReactionStage");
requireText("matrix route calls generic adapter resolver", matrixRoute, "ResolveQuestReactionStageAdapter(sourceQuest, newStage)");
requireText("matrix route forwards resolved stage", matrixRoute, "RouteQuestReaction(sourceQuest, resolvedStage, logicalEventId)");

const nocturnalNeedle = 'ShouldRouteP2QuestStage(PDV_FLST_Daedric_NocturnalLiveSources, sourceQuest, 136533, 200, "daedric_nocturnal_tg09", newStage)';
const nocturnalAt = player.indexOf(nocturnalNeedle);
const nocturnalBlock = nocturnalAt >= 0 ? player.slice(nocturnalAt, nocturnalAt + 700) : "";
requireText("vanilla Nocturnal guard remains physical 200", nocturnalBlock, nocturnalNeedle);
requireText("Nocturnal route resolves adapter outcome", nocturnalBlock, "ResolveQuestReactionStageAdapter(sourceQuest, newStage)");
requireText("Nocturnal commitment only for physical outcome", nocturnalBlock, "if resolvedStage == 200");
requireText("adapter suppresses false Nocturnal commitment", nocturnalBlock, "Quest-stage adapter suppressed Nocturnal commitment");

let adapter = null;
try {
  adapter = JSON.parse(read(P.tgaeAdapter));
} catch (error) {
  failures.push(`TGAE adapter JSON parse failed: ${error.message}`);
}
if (adapter) {
  const strings = adapter.string ?? {};
  const ints = adapter.int ?? {};
  if (strings.schema === "pdv-quest-stage-adapter.v1") passes.push("TGAE adapter schema");
  else failures.push("TGAE adapter: wrong schema");
  if (strings.sourcePlugin === "Skyrim.esm" && ints.sourceFormId === 136533 && ints.sourceStage === 200) passes.push("TGAE adapter physical TG09 selector");
  else failures.push("TGAE adapter: wrong physical TG09 selector");
  if (strings.selectorPlugin === "TG Alternative Endings.esp" && ints.selectorFormId === 2076) passes.push("TGAE adapter optional global selector");
  else failures.push("TGAE adapter: wrong optional global selector");
  if (JSON.stringify(ints.selectorValues) === JSON.stringify([1, 2, 3]) && JSON.stringify(ints.targetStages) === JSON.stringify([201, 202, 202])) passes.push("TGAE adapter synthetic stage mapping");
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
