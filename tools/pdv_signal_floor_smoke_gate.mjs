#!/usr/bin/env node
/*
 * Backend/evidence gate for PDV_SignalFloor_MasterHandoff_2026-07-09.md.
 *
 * Default --check proves the smoke matrix is internally testable: source CSVs,
 * compiled PapyrusUtil JSON, live-source debug routes, and optional Papyrus log
 * markers agree. Missing in-game markers are reported as OPEN, not as backend
 * FAIL, unless --strict-runtime is supplied.
 *
 * Use --write-ledger to update references/authoring/PDV_SignalFloorSmokeLedger.*
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = path.join(ROOT, "references", "authoring");
const SOURCE = path.join(ROOT, "live-source", "Scripts", "Source");

const args = process.argv.slice(2);
const JSON_OUT = args.includes("--json");
const WRITE_LEDGER = args.includes("--write-ledger");
const STRICT_RUNTIME = args.includes("--strict-runtime");
const SCENARIO_PATH = getArg("--scenarios") ?? path.join(AUTH, "PDV_SignalFloorSmokeScenarios_2026-07-09.json");
const MATRIX_CSV = getArg("--matrix") ?? path.join(AUTH, "PDV_QuestReactionMatrix_Full.csv");
const LIKES_CSV = getArg("--likes") ?? path.join(AUTH, "PDV_DeityLikesDislikes.csv");
const FAUCET_CSV = getArg("--faucets") ?? path.join(AUTH, "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv");
const RUNTIME_JSON = getArg("--runtime-json") ?? "D:/Wabbajack/modlists/Anvil/mods/Devotion/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix.json";
const PAPYRUS_LOG = getArg("--log") ?? "C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log";
const MANUAL_LEDGER = getArg("--manual-ledger") ?? path.join(AUTH, "PDV_SignalFloorSmokeManualEvidence.json");
const OUT_MD = path.join(AUTH, "PDV_SignalFloorSmokeLedger.md");
const OUT_JSON = path.join(AUTH, "PDV_SignalFloorSmokeLedger.json");

const files = {
  manager: path.join(SOURCE, "PDV__ManagerQuest.psc"),
  mcm: path.join(SOURCE, "PDV_MCM.psc"),
  eventBus: path.join(SOURCE, "PDV_EventBus.psc"),
  playerEvents: path.join(SOURCE, "PDV_PlayerEvents.psc"),
};

const findings = [];

function main() {
  const scenarios = readJson(SCENARIO_PATH);
  const matrixRows = readCsv(MATRIX_CSV);
  const likesRows = readCsv(LIKES_CSV);
  const faucetRows = readCsv(FAUCET_CSV);
  const runtime = readJson(RUNTIME_JSON);
  const manualEvidence = readOptionalManualEvidence(MANUAL_LEDGER);
  const sourceText = readSources();
  const papyrusLog = fs.existsSync(PAPYRUS_LOG) ? fs.readFileSync(PAPYRUS_LOG, "utf8") : "";

  checkGlobalContracts(scenarios, matrixRows, likesRows, faucetRows, runtime, sourceText);

  const results = [];
  for (const scenario of scenarios.scenarios ?? []) {
    results.push(checkScenario(scenario, matrixRows, likesRows, runtime, sourceText, papyrusLog, manualEvidence, scenarios.expected ?? {}));
  }

  const counts = countFindings([...findings, ...results.flatMap((result) => result.findings)]);
  const backendStatus = counts.FAIL ? "FAIL" : "PASS";
  const runtimeOpen = results.reduce((total, result) => total + result.findings.filter((finding) => finding.status === "OPEN" && finding.check === "runtime marker").length, 0);
  const manualOpen = results.reduce((total, result) => total + result.findings.filter((finding) => finding.status === "OPEN" && finding.check.startsWith("manual ")).length, 0);
  const status = backendStatus === "FAIL" ? "FAIL" : (STRICT_RUNTIME && runtimeOpen > 0 ? "FAIL" : "PASS");
  const report = {
    generatedAt: new Date().toISOString(),
    status,
    backendStatus,
    strictRuntime: STRICT_RUNTIME,
    runtimeOpen,
    manualOpen,
    counts,
    proofBoundary: scenarios.proofBoundary,
    files: {
      scenarios: rel(SCENARIO_PATH),
      matrix: rel(MATRIX_CSV),
      likes: rel(LIKES_CSV),
      runtimeJson: RUNTIME_JSON,
      papyrusLog: PAPYRUS_LOG,
      manualEvidenceLedger: fs.existsSync(MANUAL_LEDGER) ? rel(MANUAL_LEDGER) : null,
    },
    findings,
    scenarios: results,
  };

  if (WRITE_LEDGER) writeLedgers(report);

  if (JSON_OUT) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`Signal-floor smoke gate: ${status} (backend ${backendStatus}, runtime OPEN ${runtimeOpen}, manual OPEN ${manualOpen})`);
    for (const finding of findings) console.log(`[${finding.status}] ${finding.check}: ${finding.detail}`);
    for (const result of results) {
      const localCounts = countFindings(result.findings);
      console.log(`- ${result.id}: ${result.status} (${formatCounts(localCounts)})`);
      for (const finding of result.findings.filter((entry) => entry.status !== "PASS")) {
        console.log(`  [${finding.status}] ${finding.check}: ${finding.detail}`);
      }
    }
    if (WRITE_LEDGER) {
      console.log(`Wrote: ${rel(OUT_MD)}`);
      console.log(`Wrote: ${rel(OUT_JSON)}`);
    }
  }

  process.exitCode = status === "PASS" ? 0 : 1;
}

function checkGlobalContracts(scenarios, matrixRows, likesRows, faucetRows, runtime, sourceText) {
  const expected = scenarios.expected ?? {};
  assert("scenario manifest", scenarios.schema === "pdv-signal-floor-smoke-scenarios.v1", "Scenario manifest schema is current.", "Scenario manifest schema is wrong.");

  const questKeys = getList(runtime, "questKeys");
  const watched = getList(runtime, "questWatchFormIds");
  const faucetKeys = getList(runtime, "faucetKeys");
  assert("runtime JSON shape", runtime?.string && runtime?.float && runtime?.int && runtime?.stringList, "Runtime JSON has PapyrusUtil typed buckets.", "Runtime JSON is missing PapyrusUtil typed buckets.");
  assert("matrix row count", matrixRows.length === expected.questCells, `Matrix has ${matrixRows.length} rows.`, `Matrix row count ${matrixRows.length}, expected ${expected.questCells}.`);
  assert("runtime quest key count", questKeys.length === expected.questKeys, `Runtime JSON has ${questKeys.length} quest keys.`, `Runtime quest key count ${questKeys.length}, expected ${expected.questKeys}.`);
  assert("runtime watched quest count", watched.length === expected.watchedQuests, `Runtime JSON has ${watched.length} watched quests.`, `Runtime watched quest count ${watched.length}, expected ${expected.watchedQuests}.`);
  assert("runtime faucet count", faucetKeys.length === expected.faucetActs, `Runtime JSON has ${faucetKeys.length} faucet acts.`, `Runtime faucet count ${faucetKeys.length}, expected ${expected.faucetActs}.`);

  const echoRows = matrixRows.filter((row) => row.magnitude === "echo");
  assert("echo tier retired", echoRows.length === 0, "No live quest matrix rows use retired echo magnitude.", `${echoRows.length} matrix rows still use retired echo magnitude.`);

  const activeFaucets = faucetRows.filter((row) => String(row.buildability ?? "").toUpperCase() !== "DEFERRED");
  assert("Part D faucet source count", activeFaucets.length === expected.faucetActs, `Part D has ${activeFaucets.length} active faucet rows.`, `Part D active faucet rows ${activeFaucets.length}, expected ${expected.faucetActs}.`);

  const manager = sourceText.manager;
  assert("likes/dislikes version", manager.includes(`LIKES_DISLIKES_VERSION = ${expected.likesDislikesVersion}`), `Manager pins LIKES_DISLIKES_VERSION ${expected.likesDislikesVersion}.`, `Manager does not pin LIKES_DISLIKES_VERSION ${expected.likesDislikesVersion}.`);
  for (const eventId of [303, 366]) {
    const rows = likesRows.filter((row) => Number(row.eventId) === eventId);
    assert(`likes/dislikes event ${eventId}`, rows.length > 0, `Event ${eventId} has ${rows.length} rows.`, `Event ${eventId} has no likes/dislikes rows.`);
    assert(`likes/dislikes clear superset ${eventId}`, manager.includes(`= ${eventId}`), `GetLikesDislikesEventTypes includes ${eventId}.`, `GetLikesDislikesEventTypes does not include ${eventId}.`);
  }

  assert("Debug MCM signal-floor section", sourceText.mcm.includes("Signal-floor smoke") && sourceText.mcm.includes("Run signal-floor smoke"), "Debug MCM exposes the signal-floor smoke section.", "Debug MCM does not expose the signal-floor smoke section.");
  assert("manager debug harness", manager.includes("Function DebugRunSignalFloorSmokeScenario") && manager.includes("Function DebugGetSignalFloorSmokeLabel"), "Manager exposes signal-floor debug harness functions.", "Manager signal-floor debug harness functions are missing.");
}

function checkScenario(scenario, matrixRows, likesRows, runtime, sourceText, papyrusLog, manualEvidence, expected) {
  const local = [];
  const add = (status, check, detail) => local.push({ status, check, detail });
  const ok = (check, condition, pass, fail) => add(condition ? "PASS" : "FAIL", check, condition ? pass : fail);

  if (scenario.trigger?.type === "quest-stage") {
    const rows = matrixRows.filter((row) => row.editor_id === scenario.trigger.editorId && Number(row.outcome_stage) === Number(scenario.trigger.stage));
    ok("quest matrix rows", rows.length > 0, `${rows.length} source rows found.`, `No source rows for ${scenario.trigger.editorId} ${scenario.trigger.stage}.`);
    if (scenario.exactRows) {
      ok("quest matrix exact row count", rows.length === (scenario.expectedRows ?? []).length, `${scenario.trigger.editorId} ${scenario.trigger.stage} has exactly ${rows.length} expected rows.`, `${scenario.trigger.editorId} ${scenario.trigger.stage} has ${rows.length} rows; expected ${(scenario.expectedRows ?? []).length}. Extra deities: ${rows.map((row) => row.deity).join(", ")}.`);
    }
    for (const expected of scenario.expectedRows ?? []) {
      const match = rows.find((row) =>
        row.deity === expected.deity &&
        row.valence === expected.valence &&
        row.intensity === expected.intensity &&
        row.magnitude === expected.magnitude &&
        (!expected.actTagIncludes || String(row.act_tags ?? "").includes(expected.actTagIncludes))
      );
      ok(`row ${expected.deity}`, Boolean(match), `${expected.deity} ${expected.valence}${expected.intensity}/${expected.magnitude} is present.`, `${expected.deity} ${expected.valence}${expected.intensity}/${expected.magnitude} is missing or drifted.`);
    }

    const runtimeKey = findRuntimeQuestKey(runtime, scenario.trigger.editorId, scenario.trigger.stage);
    ok("runtime key", Boolean(runtimeKey), `Runtime JSON has key ${runtimeKey}.`, `Runtime JSON lacks ${scenario.trigger.editorId} stage ${scenario.trigger.stage}.`);
    if (runtimeKey) {
      const prefix = `quest.${runtimeKey}.`;
      const runtimeDeities = getRuntimeCsv(runtime, `${prefix}deitiesCsv`);
      ok("runtime cell count", runtimeDeities.split("|").filter(Boolean).length === rows.length, `Runtime cell count matches source (${rows.length}).`, `Runtime cell count ${runtimeDeities.split("|").filter(Boolean).length}, source rows ${rows.length}.`);
      for (const expected of scenario.expectedRows ?? []) {
        ok(`runtime deity ${expected.deity}`, runtimeDeities.split("|").includes(expected.deity), `${expected.deity} is in runtime JSON.`, `${expected.deity} is missing from runtime JSON.`);
      }
      const marker = `QuestReaction: ${runtimeKey} applied`;
      add(papyrusLog.includes(marker) ? "PASS" : "OPEN", "runtime marker", papyrusLog.includes(marker) ? `Papyrus log contains ${marker}.` : `No current Papyrus log marker for ${marker}.`);
      for (const expected of scenario.expectedRows ?? []) {
        const unknownMarker = `QuestReaction skipped unknown deity: ${expected.deity}`;
        ok(`runtime deity resolved ${expected.deity}`, !papyrusLog.includes(unknownMarker), `${expected.deity} was not skipped as unknown in the Papyrus log.`, `${expected.deity} was skipped as an unknown deity in the Papyrus log.`);
      }
    }
  } else if (scenario.trigger?.type === "likes-dislikes") {
    for (const expected of scenario.expectedRows ?? []) {
      const match = likesRows.find((row) =>
        row.actor === expected.actor &&
        Number(row.eventId) === Number(expected.eventId) &&
        row.sentiment === expected.sentiment &&
        String(row.baseDelta) === String(expected.baseDelta)
      );
      ok(`LD ${expected.actor} ${expected.eventId}`, Boolean(match), `${expected.actor} event ${expected.eventId} row is present.`, `${expected.actor} event ${expected.eventId} row is missing or drifted.`);
    }
    for (const token of scenario.expectedSourceTokens ?? []) {
      ok(`source token ${token}`, sourceText.manager.includes(token), `${token} present in manager source.`, `${token} missing from manager source.`);
    }
    const ldVersion = expected.likesDislikesVersion;
    const marker = `Likes/dislikes table + stances loaded (version ${ldVersion})`;
    add(papyrusLog.includes(marker) ? "PASS" : "OPEN", "runtime marker", papyrusLog.includes(marker) ? `Papyrus log contains LD v${ldVersion} reload marker.` : `No current Papyrus log marker for LD v${ldVersion} reload.`);
  } else if (scenario.trigger?.type === "direct-manager" || scenario.trigger?.type === "special-route") {
    for (const token of scenario.expectedFunctions ?? []) {
      const haystack = `${sourceText.manager}\n${sourceText.playerEvents}\n${sourceText.eventBus}`;
      ok(`source token ${token}`, haystack.includes(token), `${token} present.`, `${token} missing.`);
    }
    for (const fn of scenario.trigger.managerFunctions ?? []) {
      ok(`manager function ${fn}`, sourceText.manager.includes(`Function ${fn}`) || sourceText.playerEvents.includes(`Function ${fn}`), `${fn} exists.`, `${fn} is missing.`);
    }
    if (scenario.id === "crypt_clear_undead") {
      const reactionsBody = functionBody(sourceText.manager, "ApplyUndeadCryptClearReactions");
      const reactionBody = functionBody(sourceText.manager, "ApplyUndeadCryptClearReaction");
      ok("crypt-clear surface reset", reactionsBody.includes("ResetQuestReactionSurface()"), "Crypt-clear resets the quest-reaction surface before fanout.", "Crypt-clear fanout does not reset the quest-reaction surface.");
      ok("crypt-clear surface flush", reactionsBody.includes("FlushQuestReactionSurface()"), "Crypt-clear flushes one aggregated quest-reaction surface after fanout.", "Crypt-clear fanout does not flush the quest-reaction surface.");
      ok("crypt-clear positive surface", reactionBody.includes('AccumulateQuestReactionSurface(deity, appliedReactionAmount, "small")'), "Crypt-clear positive awards are accumulated for toast/Book of Days.", "Crypt-clear positive awards are not accumulated for toast/Book of Days.");
      ok("crypt-clear taboo surface", reactionBody.includes('AccumulateQuestReactionSurface(deity, amount * -1.0, "small")'), "Crypt-clear taboo losses are accumulated for toast/Book of Days.", "Crypt-clear taboo losses are not accumulated for toast/Book of Days.");
    } else if (scenario.id === "paarthurnax_kill") {
      const killBody = functionBody(sourceText.manager, "HandlePaarthurnaxKill");
      const reactionBody = functionBody(sourceText.manager, "ApplyPaarthurnaxKillReaction");
      ok("paarthurnax kill surface reset", killBody.includes("ResetQuestReactionSurface()"), "Paarthurnax kill resets the quest-reaction surface before fanout.", "Paarthurnax kill fanout does not reset the quest-reaction surface.");
      ok("paarthurnax kill surface flush", killBody.includes("FlushQuestReactionSurface()"), "Paarthurnax kill flushes one aggregated quest-reaction surface after fanout.", "Paarthurnax kill fanout does not flush the quest-reaction surface.");
      ok("paarthurnax kill non-faucet surface", reactionBody.includes('ApplyDeityReaction(deityName, "-", intensity, "small", "paarthurnax_kill", False, sourceForm)'), "Paarthurnax kill reactions use the surfaced quest-reaction path.", "Paarthurnax kill reactions still use a quiet/faucet path.");
    } else if (scenario.id === "paarthurnax_spare") {
      const spareBody = functionBody(sourceText.manager, "HandlePaarthurnaxSpare");
      const reactionBody = functionBody(sourceText.manager, "ApplyPaarthurnaxSpareReaction");
      ok("paarthurnax spare surface reset", spareBody.includes("ResetQuestReactionSurface()"), "Paarthurnax spare resets the quest-reaction surface before fanout.", "Paarthurnax spare fanout does not reset the quest-reaction surface.");
      ok("paarthurnax spare surface flush", spareBody.includes("FlushQuestReactionSurface()"), "Paarthurnax spare flushes one aggregated quest-reaction surface after fanout.", "Paarthurnax spare fanout does not flush the quest-reaction surface.");
      ok("paarthurnax spare non-faucet surface", reactionBody.includes('ApplyDeityReaction(deityName, "+", intensity, "small", "paarthurnax_spare", False, sourceForm)'), "Paarthurnax spare reactions use the surfaced quest-reaction path.", "Paarthurnax spare reactions still use a quiet/faucet path.");
    }
    const markerNeedle = scenario.id === "crypt_clear_undead"
      ? "Undead crypt clear fired"
      : scenario.id === "green_way_behavioral"
        ? "Green Pact plant food violation routed"
      : scenario.id === "paarthurnax_kill"
          ? "SignalFloorSmoke Paarthurnax kill debug routed"
          : scenario.id === "paarthurnax_spare"
            ? "SignalFloorSmoke Paarthurnax spare debug routed"
            : "";
    if (markerNeedle) {
      add(papyrusLog.includes(markerNeedle) ? "PASS" : "OPEN", "runtime marker", papyrusLog.includes(markerNeedle) ? `Papyrus log contains ${markerNeedle}.` : `No current Papyrus log marker for ${markerNeedle}.`);
    }
  } else if (scenario.trigger?.type === "borderline-review") {
    for (const editorId of scenario.trigger.editorIds ?? []) {
      const rows = matrixRows.filter((row) => row.editor_id === editorId);
      add(rows.length ? "PASS" : "OPEN", `borderline ${editorId}`, rows.length ? `${editorId} has ${rows.length} matrix rows.` : `${editorId} has no current matrix rows; manual prove-or-drop remains open.`);
    }
  } else {
    add("FAIL", "scenario trigger", `Unknown trigger type ${scenario.trigger?.type ?? "(missing)"}.`);
  }

  if (Number.isInteger(scenario.debugMcmScenario)) {
    const labelToken = `elseIf scenarioIndex == ${scenario.debugMcmScenario}`;
    ok("Debug MCM scenario index", sourceText.manager.includes(labelToken), `Manager maps debug scenario ${scenario.debugMcmScenario}.`, `Manager lacks debug scenario ${scenario.debugMcmScenario}.`);
  }

  const manualRecord = manualEvidence?.scenarios?.[scenario.id] ?? null;
  const manualOpen = [];
  for (const check of scenario.manualChecks ?? []) {
    const record = manualRecord?.checks?.[check];
    if (record?.status === "evidence-recorded") {
      add("PASS", `manual ${check}`, record.note ? `${check}: ${record.note}` : `${check}: evidence recorded.`);
    } else if (record?.status === "not-applicable") {
      add("PASS", `manual ${check}`, record.note ? `${check}: not applicable - ${record.note}` : `${check}: not applicable.`);
    } else if (record?.status === "defect") {
      add("FAIL", `manual ${check}`, record.note ? `${check}: defect - ${record.note}` : `${check}: defect recorded.`);
    } else {
      manualOpen.push(check);
      add("OPEN", `manual ${check}`, `${check}: no manual evidence recorded.`);
    }
  }

  const localCounts = countFindings(local);
  const status = localCounts.FAIL ? "FAIL" : "PASS";
  return {
    id: scenario.id,
    title: scenario.title,
    bucket: scenario.bucket,
    status,
    findings: local,
    manualChecks: scenario.manualChecks ?? [],
    manualChecksOpen: manualOpen,
    manualEvidence: manualRecord ? {
      status: manualRecord.status ?? "unknown",
      route: manualRecord.route ?? "",
      origin: manualRecord.origin ?? "",
      observedAtLocal: manualRecord.observedAtLocal ?? "",
      artifacts: manualRecord.artifacts ?? [],
      notes: manualRecord.notes ?? [],
    } : null,
  };
}

function readSources() {
  return Object.fromEntries(Object.entries(files).map(([key, file]) => [key, fs.readFileSync(file, "utf8")]));
}

function findRuntimeQuestKey(runtime, editorId, stage) {
  const editorIds = getList(runtime, "questEditorIds");
  const formIds = getList(runtime, "questFormIds");
  const keys = getList(runtime, "questKeys");
  for (let i = 0; i < editorIds.length; i += 1) {
    if (editorIds[i] === editorId) {
      const candidate = `${formIds[i]}|${stage}`;
      if (keys.includes(candidate)) return candidate;
    }
  }
  return "";
}

function getRuntimeCsv(runtime, key) {
  return runtime?.string?.[key] ?? runtime?.string?.[key.toLowerCase()] ?? "";
}

function getList(runtime, key) {
  return runtime?.stringList?.[key] ?? runtime?.stringList?.[key.toLowerCase()] ?? [];
}

function assert(check, condition, passDetail, failDetail) {
  findings.push({ status: condition ? "PASS" : "FAIL", check, detail: condition ? passDetail : failDetail });
}

function writeLedgers(report) {
  fs.writeFileSync(OUT_JSON, JSON.stringify(report, null, 2) + "\n", "utf8");

  const md = [];
  md.push("# PDV Signal-Floor Smoke Ledger");
  md.push("");
  md.push("GENERATED by `tools/pdv_signal_floor_smoke_gate.mjs --write-ledger` - do not hand-edit result rows.");
  md.push("");
  md.push(`Generated: ${report.generatedAt}`);
  md.push("");
  md.push(`Status: **${report.status}** (backend: **${report.backendStatus}**, runtime OPEN: **${report.runtimeOpen}**, manual OPEN: **${report.manualOpen}**)`);
  md.push("");
  md.push(`Proof boundary: ${report.proofBoundary}`);
  md.push("");
  md.push("## Global Checks");
  md.push("");
  md.push("| Status | Check | Detail |");
  md.push("|---|---|---|");
  for (const finding of report.findings) {
    md.push(`| ${finding.status} | ${markdownCell(finding.check)} | ${markdownCell(finding.detail)} |`);
  }
  md.push("");
  md.push("## Scenario Checks");
  md.push("");
  md.push("| Scenario | Bucket | Status | Non-PASS findings | Manual checks still required | Manual evidence |");
  md.push("|---|---|---|---|---|---|");
  for (const scenario of report.scenarios) {
    const open = scenario.findings
      .filter((finding) => finding.status !== "PASS")
      .map((finding) => `${finding.status} ${finding.check}: ${finding.detail}`)
      .join("<br>");
    const manualRequired = (scenario.manualChecksOpen ?? scenario.manualChecks ?? []).join("; ") || "None";
    const evidence = scenario.manualEvidence
      ? [`${scenario.manualEvidence.status}`, scenario.manualEvidence.origin, scenario.manualEvidence.route, scenario.manualEvidence.observedAtLocal].filter(Boolean).join("; ")
      : "None";
    md.push(`| \`${scenario.id}\` | ${markdownCell(scenario.bucket)} | ${scenario.status} | ${markdownCell(open || "None")} | ${markdownCell(manualRequired)} | ${markdownCell(evidence)} |`);
  }
  md.push("");
  md.push("## Allowed Claim");
  md.push("");
  if (report.backendStatus === "PASS") {
    md.push("The signal-floor smoke matrix is backend/static-gate ready for controlled in-game testing. Runtime-route and manual-display proof remain open for any scenario whose runtime marker or manual checks are not recorded.");
  } else {
    md.push("The signal-floor smoke matrix is not backend-ready. Fix the FAIL rows before spending manual runtime time.");
  }
  fs.writeFileSync(OUT_MD, md.join("\n") + "\n", "utf8");
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
}

function readOptionalManualEvidence(file) {
  if (!fs.existsSync(file)) return null;
  const ledger = readJson(file);
  assert("manual evidence ledger", ledger.schema === "pdv-signal-floor-smoke-manual-evidence.v1", "Manual evidence ledger schema is current.", "Manual evidence ledger schema is wrong.");
  return ledger;
}

function functionBody(source, name) {
  const start = source.indexOf(`Function ${name}(`);
  if (start < 0) return "";
  const end = source.indexOf("EndFunction", start);
  return end < 0 ? source.slice(start) : source.slice(start, end + "EndFunction".length);
}

function readCsv(file) {
  const rows = parseCsv(fs.readFileSync(file, "utf8"));
  const header = rows.shift();
  return rows
    .filter((row) => row.some((field) => field.trim() !== ""))
    .map((row) => Object.fromEntries(header.map((name, index) => [name, row[index] ?? ""])));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let inQuotes = false;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (inQuotes) {
      if (c === "\"") {
        if (text[i + 1] === "\"") {
          field += "\"";
          i += 1;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
    } else if (c === "\"") {
      inQuotes = true;
    } else if (c === ",") {
      row.push(field);
      field = "";
    } else if (c === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else if (c !== "\r") {
      field += c;
    }
  }
  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

function countFindings(entries) {
  return entries.reduce((acc, finding) => {
    acc[finding.status] = (acc[finding.status] ?? 0) + 1;
    return acc;
  }, {});
}

function formatCounts(counts) {
  return Object.entries(counts).sort().map(([key, value]) => `${key}=${value}`).join(" ");
}

function markdownCell(value) {
  return String(value ?? "").replace(/\|/g, "/").replace(/\r?\n/g, " ");
}

function rel(file) {
  return path.relative(ROOT, file).replace(/\\/g, "/");
}

function getArg(name) {
  const idx = args.indexOf(name);
  if (idx >= 0 && idx + 1 < args.length) return args[idx + 1];
  const prefix = `${name}=`;
  const inline = args.find((arg) => arg.startsWith(prefix));
  return inline ? inline.slice(prefix.length) : null;
}

main();
