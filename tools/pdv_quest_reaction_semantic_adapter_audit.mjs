#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const at = (...parts) => path.join(ROOT, ...parts);
const read = (...parts) => fs.readFileSync(at(...parts), "utf8");
const fail = (findings, code, detail) => findings.push({ code, detail });

const AFDI_ENTRIES = [
  [0, "000FD4", "azura"], [1, "000FD5", "black_star"], [2, "000FD6", "clavicus_vile"], [3, "000FD7", "hircine"],
  [4, "000FD8", "mehrunes_dagon"], [5, "000FD9", "meridia"], [6, "000FDA", "molag_bal"], [7, "000FDB", "vaermina"],
  [8, "000FDC", "boethiah"], [9, "000FDD", "hermaeus_mora"], [10, "000FE7", "hermaeus_mora"], [11, "000FE8", "hermaeus_mora"],
  [12, "000FE9", "hermaeus_mora"], [13, "000FEA", "hermaeus_mora"], [14, "000FEB", "hermaeus_mora"], [15, "000FEC", "hermaeus_mora"],
  [16, "000FED", "hermaeus_mora"], [17, "000093", "hermaeus_mora"], [18, "000FDE", "malacath"], [19, "000FDF", "mephala"],
  [20, "000FE0", "namira"], [21, "000FE1", "peryite"], [22, "000FE2", "sanguine"], [23, "000FE3", "sheogorath"],
  [24, "000FD3", "nocturnal"], [25, "000F56", "auriel_bow"], [26, "000F55", "auriel_shield"], [27, "0000D9", "jyggalag"],
  [28, "000F54", "necromancer_amulet"], [29, "000110", "sithis"],
];
const EXPECTED_EVENTS = new Map(AFDI_ENTRIES.filter(([index]) => index !== 27).map(([index, , key]) => [index, `artifact_destroyed.${String(index).padStart(2, "0")}.${key}`]));
const EXPECTED_ROWS = new Map([...EXPECTED_EVENTS.keys()].map((index) => [index, index <= 24 ? 3 : index === 28 ? 2 : 1]));
const OUTCOME_LITERALS = ["Azura", "Auri-El", "Arkay", "Stendarr", "Syrabane", "Sithis", "Clavicus Vile", "Hircine", "Mehrunes Dagon", "Meridia", "Molag Bal", "Vaermina", "Boethiah", "Hermaeus Mora", "Malacath", "Mephala", "Namira", "Peryite", "Sanguine", "Sheogorath", "Nocturnal"];
const RETIRED_BATCH = ["BeginExternalReactionBatch", "ApplyExternalReaction", "EndExternalReactionBatch"];

function parseCsv(csv) {
  const lines = csv.trim().split(/\r?\n/);
  if (lines.shift() !== "source_id,event_id,outcome,deity,valence,intensity,magnitude,act_tags") throw new Error("unexpected AFDI semantic CSV header");
  return lines.map((line) => {
    const fields = line.split(",");
    if (fields.length !== 8) throw new Error(`invalid AFDI semantic CSV row: ${line}`);
    return { sourceId: fields[0], eventId: fields[1] };
  });
}

function audit({ observer, csv, activeSources }) {
  const findings = [];
  const requiredObserver = [
    "PDV_QuestReactionRuntime Property PDV_QuestReactionRuntimeService Auto",
    "RegisterForUpdate(POLL_INTERVAL)",
    "RegisterForUpdate(RESOLVE_BACKOFF_INTERVAL)",
    "RESOLVE_ATTEMPT_LIMIT",
    "Bool baselineOnly = StorageUtil.GetIntValue(None, versionKey, 0) < BASELINE_VERSION",
    "StorageUtil.SetIntValue(None, versionKey, BASELINE_VERSION)",
    "StorageUtil.SetIntValue(None, seenKey, 1)",
    "if _unseenRemaining <= 0",
    "_pollRetired = true",
    "UnregisterForUpdate()",
    "_destroyedGlobals = new GlobalVariable[30]",
    "_artifactKeys = new String[30]",
  ];
  for (const token of requiredObserver) if (!observer.includes(token)) fail(findings, "observer.lifecycle", `missing ${token}`);

  for (const [index, formId, key] of AFDI_ENTRIES) {
    const expected = `SetEntry(${index}, 0x${formId}, "${key}")`;
    if (!observer.includes(expected)) fail(findings, "observer.entries", `missing ${expected}`);
  }
  const entries = [...observer.matchAll(/SetEntry\((\d+),\s*0x[0-9A-F]+,\s*"[^"]+"\)/g)];
  if (entries.length !== 30) fail(findings, "observer.entries", `expected 30 dynamic globals, found ${entries.length}`);

  const semanticCall = 'PDV_QuestReactionRuntimeService.SubmitSemanticEvent("afdi", eventId, sourceForm)';
  const semanticCalls = observer.split(semanticCall).length - 1;
  if (semanticCalls !== 1) fail(findings, "observer.semantic-ingress", `expected one exact runtime semantic submission, found ${semanticCalls}`);
  for (const token of RETIRED_BATCH) if (observer.includes(token)) fail(findings, "observer.retired-batch", `contains ${token}`);
  for (const literal of OUTCOME_LITERALS) if (observer.includes(`"${literal}"`)) fail(findings, "observer.outcomes", `contains deity outcome literal ${literal}`);
  if (/ApplyExternalReaction|"[+-]"\s*,\s*"[CSm]"\s*,\s*"(?:small|milestone)"/.test(observer)) fail(findings, "observer.outcomes", "contains valence/intensity/magnitude reaction tuple");
  for (const token of ["JsonUtil.", "PDV.V3.QR.", "PDV.QR.", "SubmitQuestStage(", "ResolveQuestStage(", "DebugQueuePerformanceSweep(", "Configure("]) {
    if (observer.includes(token)) fail(findings, "observer.runtime-boundary", `adapter contains forbidden runtime concern ${token}`);
  }

  let rows;
  try { rows = parseCsv(csv); } catch (error) { fail(findings, "semantic.csv", error.message); return findings; }
  const byEvent = new Map();
  for (const row of rows) {
    if (row.sourceId !== "afdi") fail(findings, "semantic.csv", `unexpected source ${row.sourceId}`);
    byEvent.set(row.eventId, (byEvent.get(row.eventId) ?? 0) + 1);
  }
  if (rows.length !== 80) fail(findings, "semantic.csv", `expected 80 rows, found ${rows.length}`);
  if (byEvent.size !== EXPECTED_EVENTS.size) fail(findings, "semantic.csv", `expected ${EXPECTED_EVENTS.size} event IDs, found ${byEvent.size}`);
  for (const [index, eventId] of EXPECTED_EVENTS) {
    if (!byEvent.has(eventId)) fail(findings, "semantic.csv", `missing event for observer index ${index}: ${eventId}`);
    if (byEvent.get(eventId) !== EXPECTED_ROWS.get(index)) fail(findings, "semantic.csv", `${eventId} expected ${EXPECTED_ROWS.get(index)} rows, found ${byEvent.get(eventId) ?? 0}`);
  }
  for (const eventId of byEvent.keys()) if (![...EXPECTED_EVENTS.values()].includes(eventId)) fail(findings, "semantic.csv", `unexpected event ${eventId}`);

  for (const [label, text] of activeSources) {
    for (const token of RETIRED_BATCH) if (text.includes(token)) fail(findings, "retired-batch.package", `${label} contains ${token}`);
  }
  return findings;
}

function liveInputs() {
  const observer = read("patch-source", "AFDI", "Scripts", "Source", "PDV_AFDIObserver.psc");
  const csv = read("references", "authoring", "patches", "PDV_QRE_AFDI.csv");
  const sourceRoots = [
    ["live-source", at("live-source", "Scripts", "Source")],
    ["patch-source", at("patch-source")],
    ["dist", at("dist", "PDV_QuestModPatches_FOMOD")],
  ];
  const activeSources = [];
  for (const [label, root] of sourceRoots) {
    if (!fs.existsSync(root)) continue;
    const stack = [root];
    while (stack.length) {
      const current = stack.pop();
      for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
        const target = path.join(current, entry.name);
        if (entry.isDirectory()) stack.push(target);
        else if (/\.(?:psc|json|ini|xml)$/i.test(entry.name)) activeSources.push([`${label}:${path.relative(ROOT, target)}`, fs.readFileSync(target, "utf8")]);
      }
    }
  }
  return { observer, csv, activeSources };
}

function selfTest() {
  const base = liveInputs();
  const sourceOnly = { ...base, activeSources: [["source", `${base.observer}\n${read("live-source", "Scripts", "Source", "PDV__ManagerQuest.psc")}`]] };
  const cases = [
    ["baseline", sourceOnly, 0],
    ["semantic call", { ...sourceOnly, observer: base.observer.replace("SubmitSemanticEvent", "SubmitQuestStage") }, 1],
    ["batch resurrection", { ...sourceOnly, observer: `${base.observer}\nPDV_Manager.ApplyExternalReaction()` }, 1],
    ["CSV coverage", { ...sourceOnly, csv: base.csv.replace(/^.*artifact_destroyed\.29\.sithis.*\r?\n?/m, "") }, 1],
    ["package batch caller", { ...sourceOnly, activeSources: [["mutation", "PDV_Manager.EndExternalReactionBatch()"]] }, 1],
  ];
  const failures = [];
  for (const [name, input, minimumFindings] of cases) {
    const findings = audit(input);
    if ((minimumFindings === 0 && findings.length !== 0) || (minimumFindings > 0 && findings.length < minimumFindings)) failures.push(`${name}: expected ${minimumFindings === 0 ? "clean" : "rejection"}, got ${findings.length} findings`);
  }
  console.log(JSON.stringify({ status: failures.length ? "FAIL" : "PASS", cases: cases.length, failures }, null, 2));
  process.exitCode = failures.length ? 1 : 0;
}

if (process.argv.includes("--self-test")) {
  selfTest();
} else {
  const findings = audit(liveInputs());
  console.log(JSON.stringify({ status: findings.length ? "FAIL" : "PASS", findings }, null, 2));
  process.exitCode = findings.length ? 1 : 0;
}
