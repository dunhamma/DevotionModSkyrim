#!/usr/bin/env node
/*
 * Strict static/readback audit for the Helgen-to-Alduin quest-reaction slice.
 * This proves authored coverage, exact stages, runtime matrix counts, indexed
 * quest registration, the separate Paarthurnax choice roster, and the static
 * Prisma producer-to-glyph contract. It does not claim in-game route or
 * player-facing proof.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { familySourceText } from "./lib/pdv_symbol_home.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--check", "--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_main_quest_full_coverage_audit" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const AUTHORING = path.join(ROOT, "references", "authoring");
const CONTRACT_PATH = path.join(AUTHORING, "PDV_MainQuestFullCoverageContract.json");
const FULL_PATH = path.join(AUTHORING, "PDV_QuestReactionMatrix_Full.csv");
const T11_PATH = path.join(AUTHORING, "PDV_QuestReactionMatrix_Tranche11_MainQuestFullCoverage.csv");
const SIGNAL_SCENARIOS_PATH = path.join(AUTHORING, "PDV_SignalFloorSmokeScenarios_2026-07-09.json");
const SOURCE_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const EVENTS_PATH = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc");
const PRISMA_APP_PATH = path.join(ROOT, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "app.js");
const PRISMA_SYMBOLS = {
  "Akatosh": "akatosh", "Alkosh": "alkosh", "Arkay": "arkay", "Auri-El": "auri-el", "Azura": "azura", "Baan Dar": "baan-dar",
  "Boethiah": "boethiah", "Clavicus Vile": "clavicus-vile", "Dibella": "dibella", "Hermaeus Mora": "hermaeus-mora", "Hircine": "hircine",
  "HoonDing": "hoonding", "Julianos": "julianos", "Khenarthi": "khenarthi", "Kynareth": "kynareth", "Kyne": "kyne", "Leki": "leki",
  "Magnus": "magnus", "Malacath": "malacath", "Mara": "mara", "Mehrunes Dagon": "mehrunes-dagon", "Mephala": "mephala", "Meridia": "meridia",
  "Molag Bal": "molag-bal", "Namira": "namira", "Nocturnal": "nocturnal", "Peryite": "peryite", "Rajhin": "rajhin", "Sanguine": "sanguine",
  "Sheogorath": "sheogorath", "Shor": "shor", "Sithis": "sithis", "Stendarr": "stendarr", "Stuhn": "stuhn", "Syrabane": "syrabane",
  "Talos": "talos", "The Hist": "hist", "Trinimac": "trinimac", "Tsun": "tsun", "Tu'whacca": "tuwhacca", "Vaermina": "vaermina",
  "Xarxes": "xarxes", "Y'ffre": "yffre", "Z'en": "zen", "Zenithar": "zenithar",
};
const SAFE_MCM_PROBES = [
  { id: "t11_mq101_150_sheogorath_alias", index: 13, label: "T11: MQ101 150", formId: "0x0003372B", editorId: "MQ101", stage: "150" },
  { id: "t11_mq105_160_paired_equity", index: 14, label: "T11: MQ105 160", formId: "0x000242BA", editorId: "MQ105", stage: "160" },
  { id: "t11_mq106_200_syrabane", index: 15, label: "T11: MQ106 200 - Syrabane", formId: "0x00032926", editorId: "MQ106", stage: "200" },
];
const JSON_OUTPUT = process.argv.includes("--json");
const checks = [];

function add(status, check, detail) { checks.push({ status, check, detail }); }
function pass(check, detail) { add("PASS", check, detail); }
function fail(check, detail) { add("FAIL", check, detail); }

function parseCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (ch === '"') quoted = false;
      else field += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\n" || ch === "\r") {
      if (ch === "\r" && text[i + 1] === "\n") i++;
      row.push(field); field = "";
      if (row.some((cell) => cell !== "")) rows.push(row);
      row = [];
    } else field += ch;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  const header = rows.shift()?.map((cell) => cell.trim()) ?? [];
  return rows.map((cells) => Object.fromEntries(header.map((name, index) => [name, cells[index] ?? ""])));
}

function loadCsv(filePath) {
  if (!fs.existsSync(filePath)) throw new Error(`missing CSV: ${path.relative(ROOT, filePath)}`);
  return parseCsv(fs.readFileSync(filePath, "utf8"));
}

function cellKey(row) { return `${row.editor_id}|${row.outcome_stage}|${row.deity}`; }
function rosterKey(row) { return `${row.deity}|${row.intensity}|${row.valence}`; }

function checkContract(contract) {
  const deityUnique = new Set(contract.deities);
  const beatUnique = new Set(contract.beats.map((beat) => `${beat.editorId}|${beat.stage}`));
  const questUnique = new Set(contract.questRecords);
  const expected = contract.expected;
  if (contract.deities.length === expected.deities && deityUnique.size === expected.deities) pass("Contract deity roster", `${expected.deities} unique runtime identities.`);
  else fail("Contract deity roster", `${contract.deities.length} rows / ${deityUnique.size} unique; expected ${expected.deities}.`);
  if (contract.beats.length === expected.beats && beatUnique.size === expected.beats) pass("Contract beats", `${expected.beats} exact quest stages.`);
  else fail("Contract beats", `${contract.beats.length} rows / ${beatUnique.size} unique; expected ${expected.beats}.`);
  if (questUnique.size === 19) pass("Contract quest records", "19 unique main-quest records.");
  else fail("Contract quest records", `${questUnique.size} unique records; expected 19.`);
  if (expected.coverageCells === expected.deities * expected.beats) pass("Contract arithmetic", `${expected.deities} x ${expected.beats} = ${expected.coverageCells}.`);
  else fail("Contract arithmetic", `coverageCells=${expected.coverageCells}, expected ${expected.deities * expected.beats}.`);
}

function checkMatrix(contract, full, t11) {
  const expected = contract.expected;
  const badStages = full.filter((row) => !/^\d+$/.test(row.outcome_stage));
  if (!badStages.length) pass("Exact integer stages", `${full.length} canonical cells use one integer stage.`);
  else fail("Exact integer stages", `${badStages.length} non-exact stage rows: ${badStages.slice(0, 8).map(cellKey).join(", ")}`);

  const echoRows = full.filter((row) => row.magnitude === "echo");
  if (!echoRows.length) pass("Retired magnitude", "No canonical matrix cell uses echo.");
  else fail("Retired magnitude", `${echoRows.length} echo rows remain.`);

  const groups = new Map();
  for (const row of full) {
    const key = cellKey(row);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  const duplicates = [...groups.entries()].filter(([, rows]) => rows.length !== 1);
  if (!duplicates.length) pass("Canonical uniqueness", `${groups.size} deity-stage cells are unique.`);
  else fail("Canonical uniqueness", `${duplicates.length} duplicate deity-stage groups.`);

  if (t11.length === expected.tranche11Rows) pass("Tranche 11 size", `${t11.length} missing cells authored.`);
  else fail("Tranche 11 size", `${t11.length} rows; expected ${expected.tranche11Rows}.`);

  const allowedBeats = new Set(contract.beats.map((beat) => `${beat.editorId}|${beat.stage}`));
  const offContract = t11.filter((row) => !allowedBeats.has(`${row.editor_id}|${row.outcome_stage}`));
  if (!offContract.length) pass("Tranche 11 scope", "Every new row targets a contracted main-quest beat.");
  else fail("Tranche 11 scope", `${offContract.length} rows target off-contract stages.`);

  const silence = new Set((contract.approvedSilences ?? []).map((entry) => `${entry.editorId}|${entry.stage}|${entry.deity}`));
  const missing = [];
  const multiplyAuthored = [];
  for (const beat of contract.beats) {
    for (const deity of contract.deities) {
      const key = `${beat.editorId}|${beat.stage}|${deity}`;
      const count = groups.get(key)?.length ?? 0;
      if (count === 0 && !silence.has(key)) missing.push(key);
      if (count > 1) multiplyAuthored.push(key);
    }
  }
  const covered = expected.coverageCells - missing.length;
  if (!missing.length && !multiplyAuthored.length) pass("Full main-quest coverage", `${covered}/${expected.coverageCells} required cells present; ${silence.size} approved silences.`);
  else fail("Full main-quest coverage", `${missing.length} missing and ${multiplyAuthored.length} multiply-authored cells.`);

  const excluded = new Set(contract.excludedQuestRecords ?? []);
  const excludedRows = full.filter((row) => excluded.has(row.editor_id));
  if (!excludedRows.length) pass("Paarthurnax separation", "MQPaarthurnax remains outside the matrix and in its choice handler.");
  else fail("Paarthurnax separation", `${excludedRows.length} excluded quest rows found in Full.csv.`);
}

function checkCompiledCounts(contract) {
  const result = spawnSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_matrix_compile.mjs"), "--check", "--json"], {
    cwd: ROOT, encoding: "utf8", windowsHide: true, maxBuffer: 32 * 1024 * 1024,
  });
  if (result.status !== 0) {
    fail("Compiled matrix", `compiler exited ${result.status}: ${(result.stderr || result.stdout).trim().slice(0, 500)}`);
    return;
  }
  let report;
  try { report = JSON.parse(result.stdout); }
  catch (error) { fail("Compiled matrix", `compiler JSON unreadable: ${error.message}`); return; }
  const expected = contract.expected;
  const fields = ["questCells", "questKeys", "watchedQuests", "faucetActs"];
  const bad = fields.filter((field) => report[field] !== expected[field === "questCells" ? "matrixCells" : field]);
  if (!bad.length) pass("Compiled matrix", `${report.questCells} cells, ${report.questKeys} keys, ${report.watchedQuests} watched quests, ${report.faucetActs} faucets.`);
  else fail("Compiled matrix", bad.map((field) => `${field}=${report[field]}`).join(", "));
}

function extractFunction(text, name) {
  const match = text.match(new RegExp(`Function ${name}\\b[\\s\\S]*?EndFunction`));
  return match?.[0] ?? "";
}

function checkPaarthurnax(contract, manager) {
  for (const [lane, functionName] of [["kill", "HandlePaarthurnaxKill"], ["spare", "HandlePaarthurnaxSpare"]]) {
    const body = extractFunction(manager, functionName);
    const calls = [];
    const re = new RegExp(`ApplyPaarthurnax${lane === "kill" ? "Kill" : "Spare"}Reaction\\(\"([^\"]+)\", \"(C|S|m)\", sourceForm(?:, \"([+-])\")?\\)`, "g");
    let match;
    while ((match = re.exec(body))) calls.push({ deity: match[1], intensity: match[2], valence: match[3] ?? (lane === "kill" ? "-" : "+") });
    const actual = calls.map(rosterKey).sort();
    const expected = contract.paarthurnax[lane].map(rosterKey).sort();
    const exact = actual.length === expected.length && actual.every((key, index) => key === expected[index]);
    if (exact) pass(`Paarthurnax ${lane} roster`, `${actual.length} exact reactions.`);
    else fail(`Paarthurnax ${lane} roster`, `actual=${actual.length}, expected=${expected.length}; roster drift detected.`);
  }
}

function checkIndexedRegistration(events) {
  const body = extractFunction(events, "RegisterQuestReactionMatrixFile");
  const required = ["JsonUtil.StringListCount", "JsonUtil.StringListGet", "while sourceIndex < sourceCount"];
  const missing = required.filter((token) => !body.includes(token));
  const forbidden = body.includes("JsonUtil.StringListToArray");
  if (!missing.length && !forbidden) pass("Indexed quest registration", "Quest watches are read by index without materializing a capped Papyrus array.");
  else fail("Indexed quest registration", `missing=${missing.join(", ") || "none"}; StringListToArray=${forbidden}.`);
}

function checkPrismaSurface(contract, manager, app) {
  const missingMap = contract.deities.filter((deity) => !PRISMA_SYMBOLS[deity]);
  if (missingMap.length) {
    fail("Prisma symbol authority", `${missingMap.length} contracted deities lack a symbol mapping: ${missingMap.join(", ")}.`);
    return;
  }
  const managerBody = extractFunction(manager, "GetPrismaSymbolForDeity");
  const expectedSymbols = [...new Set(contract.deities.map((deity) => PRISMA_SYMBOLS[deity]))];
  const missingManagerSymbols = expectedSymbols.filter((symbol) => !managerBody.includes(`return "${symbol}"`));
  if (!missingManagerSymbols.length) pass("Prisma producer coverage", `${expectedSymbols.length}/${expectedSymbols.length} contracted identities resolve to an explicit toast/journal symbol.`);
  else fail("Prisma producer coverage", `Missing manager symbol returns: ${missingManagerSymbols.join(", ")}.`);

  const appSymbols = new Set([...app.matchAll(/^    (?:"([^"]+)"|([a-z][a-z0-9-]*)):\s*\[/gm)].map((match) => match[1] || match[2]));
  const missingGlyphs = expectedSymbols.filter((symbol) => !appSymbols.has(symbol));
  if (!missingGlyphs.length) pass("Prisma glyph coverage", `${expectedSymbols.length}/${expectedSymbols.length} contracted identities have an intentional rendered glyph; no journal fallback.`);
  else fail("Prisma glyph coverage", `Missing Prisma glyphs: ${missingGlyphs.join(", ")}.`);
}

function checkSafeMcmProbes(full, manager, scenarios) {
  const countBody = extractFunction(manager, "DebugGetSignalFloorSmokeScenarioCount");
  const labelBody = extractFunction(manager, "DebugGetSignalFloorSmokeLabel");
  const runBody = extractFunction(manager, "DebugRunSignalFloorSmokeScenario");
  const routeBody = extractFunction(manager, "DebugRouteSignalFloorQuest");
  const routeIsSafe = routeBody.includes("QueueQuestReactionJob(sourceQuest, stageValue)") && !routeBody.includes("SetStage(");
  if (routeIsSafe) pass("Safe MCM quest route", "Controlled quest probes queue the manager reaction without mutating vanilla quest stages.");
  else fail("Safe MCM quest route", "DebugRouteSignalFloorQuest must queue the manager reaction and never SetStage.");

  const failures = [];
  for (const probe of SAFE_MCM_PROBES) {
    const sourceRows = full.filter((row) => row.editor_id === probe.editorId && row.outcome_stage === probe.stage);
    const scenario = scenarios.scenarios?.find((entry) => entry.id === probe.id);
    const labelToken = `elseIf scenarioIndex == ${probe.index}\n        return "${probe.label}"`;
    const routeToken = `elseIf scenarioIndex == ${probe.index}\n        return DebugRouteSignalFloorQuest(${probe.formId}, "Skyrim.esm", ${probe.stage}, label)`;
    const scenarioMatches = scenario?.debugMcmScenario === probe.index
      && scenario?.trigger?.editorId === probe.editorId
      && Number.parseInt(scenario?.trigger?.formId, 16) === Number.parseInt(probe.formId, 16)
      && String(scenario?.trigger?.stage) === probe.stage;
    if (sourceRows.length !== 45) failures.push(`${probe.editorId}|${probe.stage} has ${sourceRows.length}/45 matrix cells`);
    if (!labelBody.includes(labelToken)) failures.push(`${probe.editorId}|${probe.stage} label missing`);
    if (!runBody.includes(routeToken)) failures.push(`${probe.editorId}|${probe.stage} safe route missing`);
    if (!scenarioMatches) failures.push(`${probe.editorId}|${probe.stage} scenario manifest drift`);
  }
  if (!failures.length && countBody.includes("return 15")) pass("T11 safe MCM probes", "MQ101, MQ105, and MQ106 use exact 45-cell manager routes without vanilla SetStage.");
  else fail("T11 safe MCM probes", `${failures.join("; ") || "scenario count is not 15"}.`);
}

function main() {
  try {
    const contract = JSON.parse(fs.readFileSync(CONTRACT_PATH, "utf8"));
    const full = loadCsv(FULL_PATH);
    const t11 = loadCsv(T11_PATH);
    const scenarios = JSON.parse(fs.readFileSync(SIGNAL_SCENARIOS_PATH, "utf8"));
    // Family text, not manager-only: the debug/probe and Paarthurnax roster bodies move
    // into extracted modules, and a manager-only read makes present code look absent.
    const manager = familySourceText(ROOT, SOURCE_DIR);
    const events = fs.readFileSync(EVENTS_PATH, "utf8");
    const app = fs.readFileSync(PRISMA_APP_PATH, "utf8");
    checkContract(contract);
    checkMatrix(contract, full, t11);
    checkCompiledCounts(contract);
    checkPaarthurnax(contract, manager);
    checkIndexedRegistration(events);
    checkPrismaSurface(contract, manager, app);
    checkSafeMcmProbes(full, manager, scenarios);
  } catch (error) {
    fail("Audit execution", error.stack || error.message);
  }

  const failures = checks.filter((check) => check.status === "FAIL");
  const report = { status: failures.length ? "FAIL" : "PASS", proofBoundary: "static-generated-readback-and-ui-contract-only", checks };
  if (JSON_OUTPUT) console.log(JSON.stringify(report, null, 2));
  else {
    for (const check of checks) console.log(`[${check.status}] ${check.check}: ${check.detail}`);
    console.log(`Summary: ${report.status} (${checks.length - failures.length} pass, ${failures.length} fail)`);
  }
  process.exitCode = failures.length ? 1 : 0;
}

main();
