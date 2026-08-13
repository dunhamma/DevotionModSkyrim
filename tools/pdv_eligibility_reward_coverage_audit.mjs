#!/usr/bin/env node
/*
 * PDV eligibility -> reward coverage audit.
 *
 * Read-only against source/ESP state except for its generated ledgers. This is
 * deliberately driven from live Papyrus reward wiring and offer-eligibility
 * functions, not the reward specs, so an omitted spec row cannot hide a live
 * focusable deity with no reward record.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_eligibility_reward_coverage_audit" });

const ROOT = process.cwd();
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const MANAGER = path.join(DEVOTION_MOD, "Scripts", "Source", "PDV__ManagerQuest.psc");
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe");
const OUT_MD = path.join(ROOT, "references", "authoring", "PDV_EligibilityRewardCoverageLedger.md");
const OUT_CSV = path.join(ROOT, "references", "authoring", "PDV_EligibilityRewardCoverageLedger.csv");
const JSON_MODE = process.argv.includes("--json");
const SELF_TEST = process.argv.includes("--self-test");
const MAX_BUFFER = 128 * 1024 * 1024;

const RACE_BY_FN = {
  SyncImperialRewardFamily: { race: "Imperial", laneIndex: null, deityIndex: 1, spellStart: 2, lane: "Divines" },
  SyncAltmerRewardFamily: { race: "Altmer", laneIndex: null, deityIndex: 1, spellStart: 2, lane: "Offer" },
  SyncDunmerRewardFamily: { race: "Dunmer", laneIndex: null, deityIndex: 1, spellStart: 2, lane: "Reclamation" },
  SyncRedguardRewardFamily: { race: "Redguard", laneIndex: null, deityIndex: 1, spellStart: 2, lane: "Sect" },
  SyncNordRewardFamily: { race: "Nord", laneIndex: 1, deityIndex: 2, spellStart: 3, lane: null },
  SyncBosmerPathRewardFamily: { race: "Bosmer", laneIndex: 1, deityIndex: 3, spellStart: 4, lane: null },
  SyncBretonTraditionRewardFamily: { race: "Breton", laneIndex: 1, deityIndex: 3, spellStart: 4, lane: null },
  SyncKhajiitEmphasisFamily: { race: "Khajiit", laneIndex: 1, deityIndex: 4, spellStart: 5, lane: null },
  SyncOrcRewardFamily: { race: "Orc", laneIndex: 1, deityIndex: null, spellStart: 5, lane: null, fixedDeity: "PDV_Malacath" },
};

const LANE_NAMES = new Map([
  ["-1", "All"],
  ["NORD_BASELINE_OLD_WAYS", "Old Ways"],
  ["NORD_BASELINE_NINE_DIVINES", "Nine Divines"],
  ["BOSMER_PATH_OLD_CONTRACT", "Old Contract"],
  ["BOSMER_PATH_LIVING_STORY", "Living Story"],
  ["BOSMER_PATH_EXCHANGE", "Exchange"],
  ["BOSMER_PATH_BANDIT_ROAD", "Bandit Road"],
  ["BRETON_TRADITION_KNIGHTS_ROAD", "Knight's Road"],
  ["BRETON_TRADITION_HIDDEN_ART", "Hidden Art"],
  ["BRETON_TRADITION_GREEN_WAY", "Green Way"],
  ["KHAJIIT_FOCUS_KHENARTHI", "Khenarthi"],
  ["KHAJIIT_FOCUS_AZURAH", "Azurah"],
  ["KHAJIIT_FOCUS_BAANDAR", "Baan Dar"],
  ["KHAJIIT_FOCUS_RAJHIN", "Rajhin"],
  ["KHAJIIT_FOCUS_ALKOSH", "Alkosh"],
  ["ORC_LIFE_MODE_STRONGHOLD", "Stronghold"],
  ["ORC_LIFE_MODE_CITY", "City"],
  ["ORC_LIFE_MODE_LEGION_EXILE", "Legion Exile"],
]);

const DEITY_NAMES = new Map([
  ["PDV_Akatosh", "Akatosh"],
  ["PDV_Alkosh", "Alkosh"],
  ["PDV_Arkay", "Arkay"],
  ["PDV_AuriEl", "Auri-El"],
  ["PDV_Azura", "Azura/Azurah"],
  ["PDV_BaanDar", "Baan Dar"],
  ["PDV_Boethiah", "Boethiah/Boethra"],
  ["PDV_Dibella", "Dibella"],
  ["PDV_Hist", "Hist"],
  ["PDV_HoonDing", "HoonDing"],
  ["PDV_Julianos", "Julianos"],
  ["PDV_Khenarthi", "Khenarthi"],
  ["PDV_Kyne", "Kyne"],
  ["PDV_Kynareth", "Kynareth"],
  ["PDV_Leki", "Leki"],
  ["PDV_Magnus", "Magnus"],
  ["PDV_Malacath", "Malacath"],
  ["PDV_Mara", "Mara"],
  ["PDV_Mephala", "Mephala/Mafala"],
  ["PDV_Rajhin", "Rajhin"],
  ["PDV_Shor", "Shor"],
  ["PDV_Sithis", "Sithis"],
  ["PDV_Stendarr", "Stendarr"],
  ["PDV_Stuhn", "Stuhn"],
  ["PDV_Talos", "Talos"],
  ["PDV_Tsun", "Tsun"],
  ["PDV_Tuwhacca", "Tu'whacca"],
  ["PDV_Xarxes", "Xarxes"],
  ["PDV_Yffre", "Y'ffre"],
  ["PDV_Zen", "Z'en"],
  ["PDV_Zenithar", "Zenithar"],
]);

function toPosix(value) {
  return String(value).replace(/\\/g, "/");
}

function bridge(request, timeoutMs = 90_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: MAX_BUFFER,
    windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  const payload = JSON.parse(stdout);
  if (!payload.success) throw new Error(payload.error || payload.message || "bridge call failed");
  return payload;
}

function scanEsp() {
  const scan = bridge({ command: "scan", plugins: [toPosix(PDV_ESP)] });
  const plugin = scan.plugins?.[0];
  if (!plugin) throw new Error("mutagen scan returned no plugin payload");
  const records = new Map();
  for (const record of plugin.records || []) {
    if (record.edid) records.set(record.edid, record);
  }
  return records;
}

function readManager(recordsByEdid) {
  const manager = recordsByEdid.get("PDV__ManagerQuest");
  if (!manager) throw new Error("PDV__ManagerQuest is missing from Devotion.esp");
  const detail = bridge({
    command: "read_records",
    max_depth: 8,
    records: [{ plugin_path: toPosix(PDV_ESP), formid: manager.formid }],
  });
  const record = (detail.records || []).find((entry) => entry.success && entry.editor_id === "PDV__ManagerQuest");
  if (!record) throw new Error("Could not read PDV__ManagerQuest VMAD detail");
  const script = findScript(record.fields || {}, "PDV__ManagerQuest");
  if (!script) throw new Error("PDV__ManagerQuest VMAD script is missing");
  return propertyMap(script);
}

function findScript(fields, name) {
  const scripts = fields?.VirtualMachineAdapter?.Scripts || [];
  const matches = scripts.filter((script) => script.Name === name);
  if (matches.length <= 1) return matches[0] || null;
  return { ...matches.at(-1), Properties: matches.flatMap((script) => script.Properties || []) };
}

function propertyMap(script) {
  return new Map((script?.Properties || []).filter((prop) => prop.Name).map((prop) => [prop.Name, prop]));
}

function propTarget(prop) {
  return prop?.Object || prop?.Data || null;
}

function formidToEdid(formid, recordsByEdid) {
  for (const [edid, record] of recordsByEdid.entries()) {
    if (record.formid === formid) return edid;
  }
  return null;
}

function fnBody(source, name) {
  const re = new RegExp(`(?:^|\\n)\\s*(?:\\w[\\w\\[\\]]*\\s+)?Function\\s+${name}\\s*\\([^)]*\\)([\\s\\S]*?)\\n\\s*EndFunction`, "i");
  const match = source.match(re);
  return match ? match[1] : "";
}

function splitArgs(text) {
  const args = [];
  let current = "";
  let inString = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (ch === "\"") inString = !inString;
    if (ch === "," && !inString) {
      args.push(current.trim());
      current = "";
    } else {
      current += ch;
    }
  }
  if (current.trim()) args.push(current.trim());
  return args;
}

function labelFromArg(value) {
  return String(value || "").replace(/^"/, "").replace(/"$/, "");
}

function laneFromToken(token, fallback) {
  return LANE_NAMES.get(token) || fallback || token || "Default";
}

function deityName(token) {
  return DEITY_NAMES.get(token) || token || "None";
}

function collectRewardRows(source) {
  const rows = [];
  const seen = new Set();
  const addRow = (row) => {
    const key = `${row.race}|${row.lane}|${row.deityProp}|${row.tier}|${row.spellEditorId}`;
    if (seen.has(key)) return;
    seen.add(key);
    rows.push(row);
  };

  for (const rawLine of source.split(/\r?\n/)) {
    const line = rawLine.split(";")[0];
    const match = line.match(/\b(Sync\w*(?:RewardFamily|EmphasisFamily))\s*\((.*)\)/);
    if (!match) continue;
    const cfg = RACE_BY_FN[match[1]];
    if (!cfg) continue;
    const args = splitArgs(match[2]);
    const laneToken = cfg.laneIndex === null ? null : args[cfg.laneIndex];
    const deityProp = cfg.fixedDeity || args[cfg.deityIndex];
    const spellArgs = args.slice(cfg.spellStart, cfg.spellStart + 3);
    const label = labelFromArg(args[cfg.spellStart + 3] || deityName(deityProp));
    for (let i = 0; i < spellArgs.length; i += 1) {
      const spellEditorId = spellArgs[i];
      if (!/^PDV_Bless_/.test(spellEditorId)) continue;
      addRow({
        race: cfg.race,
        lane: laneFromToken(laneToken, cfg.lane),
        deityProp,
        deity: deityName(deityProp),
        tier: `T${i + 1}`,
        spellEditorId,
        label,
        source: match[1],
      });
    }
  }

  const argonianBody = fnBody(source, "SyncArgonianRewards");
  for (const rawLine of argonianBody.split(/\r?\n/)) {
    const line = rawLine.split(";")[0];
    const match = line.match(/\bSyncRaceRewardSpell\s*\(\s*playerRef\s*,\s*(PDV_Bless_Argonian_\w+)\s*,[^,]+,\s*"([^"]+)"\s*\)/);
    if (!match) continue;
    const spellEditorId = match[1];
    const label = match[2];
    let deityProp = "PDV_Hist";
    let lane = "Hist";
    let tier = "T1";
    if (spellEditorId.includes("_People_")) {
      deityProp = "PDV_Hist";
      lane = "People";
    } else if (spellEditorId.includes("_Sithis_")) {
      deityProp = "PDV_Sithis";
      lane = "Sithis";
    }
    const tierMatch = spellEditorId.match(/_(T[123])$/);
    if (tierMatch) tier = tierMatch[1];
    if (spellEditorId.endsWith("_Signature")) tier = "Signature";
    addRow({
      race: "Argonian",
      lane,
      deityProp,
      deity: lane,
      tier,
      spellEditorId,
      label,
      source: "SyncArgonianRewards",
    });
  }

  return rows.sort((a, b) => [a.race, a.lane, a.deity, a.tier].join("|").localeCompare([b.race, b.lane, b.deity, b.tier].join("|")));
}

function collectOfferExpectations(source) {
  const expectations = [];
  const add = (race, lane, deityProp) => expectations.push({ race, lane, deityProp });

  const nord = fnBody(source, "IsNordOfferEligibleDeity");
  if (nord.includes("PDV_Talos")) {
    add("Nord", "Old Ways", "PDV_Talos");
    add("Nord", "Nine Divines", "PDV_Talos");
  }
  const oldWays = nord.match(/NORD_BASELINE_OLD_WAYS[\s\S]*?return\s+([^\n]+)/);
  if (oldWays) for (const deity of oldWays[1].match(/PDV_\w+/g) || []) add("Nord", "Old Ways", deity);
  const nineDivines = nord.match(/NORD_BASELINE_NINE_DIVINES[\s\S]*?return\s+([^\n]+)/);
  if (nineDivines) for (const deity of nineDivines[1].match(/PDV_\w+/g) || []) add("Nord", "Nine Divines", deity);

  for (const [race, fn, lane] of [
    ["Imperial", "IsImperialOfferEligibleDeity", "Divines"],
    ["Altmer", "IsAltmerOfferEligibleDeity", "Offer"],
    ["Dunmer", "IsDunmerOfferEligibleDeity", "Reclamation"],
  ]) {
    const body = fnBody(source, fn);
    for (const deity of body.match(/PDV_\w+/g) || []) {
      if (deity === "PDV_ConcordatStandingTrack") continue;
      add(race, lane, deity);
    }
  }

  return expectations;
}

function rowCoversExpectation(row, expected) {
  if (row.race !== expected.race || row.deityProp !== expected.deityProp) return false;
  return row.lane === expected.lane || row.lane === "All";
}

function auditRows(rows, recordsByEdid, managerProps, source) {
  const findings = [];
  const resolved = rows.map((row) => {
    const record = recordsByEdid.get(row.spellEditorId);
    const prop = managerProps.get(row.spellEditorId);
    const targetEdid = formidToEdid(propTarget(prop), recordsByEdid);
    const exists = record?.type === "SPEL";
    const filled = targetEdid === row.spellEditorId;
    const status = exists && filled ? "PASS" : "FAIL";
    if (!exists) findings.push({ status: "FAIL", check: "Reward SPEL", detail: `${row.race}/${row.lane}/${row.deity} ${row.tier} references missing SPEL ${row.spellEditorId}.` });
    if (!filled) findings.push({ status: "FAIL", check: "Manager VMAD property", detail: `${row.spellEditorId} resolves to ${targetEdid || "(missing)"}, expected itself.` });
    return { ...row, exists, filled, targetEdid: targetEdid || "", status };
  });

  for (const expected of collectOfferExpectations(source)) {
    if (!rows.some((row) => rowCoversExpectation(row, expected))) {
      findings.push({
        status: "FAIL",
        check: "Focusable reward mapping",
        detail: `${expected.race}/${expected.lane}/${deityName(expected.deityProp)} is offer-eligible but has no reward-family mapping.`,
      });
    }
  }

  return { rows: resolved, findings };
}

function writeLedgers(rows, findings) {
  const csv = [
    "status,race,lane,deity,tier,spellEditorId,exists,filled,targetEdid,source,label",
    ...rows.map((row) => [
      row.status,
      row.race,
      row.lane,
      row.deity,
      row.tier,
      row.spellEditorId,
      row.exists,
      row.filled,
      row.targetEdid,
      row.source,
      row.label,
    ].map(csvCell).join(",")),
  ].join("\n") + "\n";

  const md = [
    "# PDV Eligibility Reward Coverage Ledger",
    "",
    "GENERATED by tools/pdv_eligibility_reward_coverage_audit.mjs - do not hand-edit.",
    "",
    `Overall: **${findings.length ? "FAIL" : "PASS"}**`,
    "",
    "| Status | Race | Lane | Deity | Tier | Spell | Exists | Filled | Target |",
    "|---|---|---|---|---|---|---|---|---|",
    ...rows.map((row) => `| ${row.status} | ${row.race} | ${row.lane} | ${row.deity} | ${row.tier} | ${row.spellEditorId} | ${row.exists ? "yes" : "no"} | ${row.filled ? "yes" : "no"} | ${row.targetEdid || ""} |`),
    "",
  ];
  if (findings.length) {
    md.push("## Findings", "");
    for (const finding of findings) md.push(`- ${finding.check}: ${finding.detail}`);
    md.push("");
  }
  fs.writeFileSync(OUT_CSV, csv, "utf8");
  fs.writeFileSync(OUT_MD, md.join("\n"), "utf8");
}

function csvCell(value) {
  const text = String(value ?? "");
  if (/[",\r\n]/.test(text)) return `"${text.replace(/"/g, "\"\"")}"`;
  return text;
}

function selfTest() {
  const source = [
    "Function SyncNordRewards(Actor playerRef)",
    "    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, \"Akatosh\")",
    "    SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, \"Mara\")",
    "EndFunction",
    "Bool Function IsNordOfferEligibleDeity(PDV_DeityBase deity)",
    "    Int baselineState = GetNordPantheonBaselineState()",
    "    if baselineState == NORD_BASELINE_NINE_DIVINES",
    "        return deity == PDV_Akatosh || deity == PDV_Mara",
    "    endIf",
    "    return False",
    "EndFunction",
    "String Function GetNordMedallionEntriesJson()",
    "    return PendingMedallionEntry(\"pending\", \"Pending\", \"god\", \"x\", \"Not live yet\")",
    "EndFunction",
  ].join("\n");
  const records = new Map([
    ["PDV_Bless_Imperial_Akatosh_T1", { type: "SPEL", formid: "Devotion.esp:000001" }],
    ["PDV_Bless_Imperial_Akatosh_T2", { type: "SPEL", formid: "Devotion.esp:000002" }],
    ["PDV_Bless_Imperial_Mara_T1", { type: "SPEL", formid: "Devotion.esp:000004" }],
    ["PDV_Bless_Imperial_Mara_T2", { type: "SPEL", formid: "Devotion.esp:000005" }],
    ["PDV_Bless_Imperial_Mara_T3", { type: "SPEL", formid: "Devotion.esp:000006" }],
  ]);
  const props = new Map([
    ["PDV_Bless_Imperial_Akatosh_T1", { Name: "PDV_Bless_Imperial_Akatosh_T1", Object: "Devotion.esp:000001" }],
    ["PDV_Bless_Imperial_Akatosh_T2", { Name: "PDV_Bless_Imperial_Akatosh_T2", Object: "Devotion.esp:000002" }],
    ["PDV_Bless_Imperial_Mara_T1", { Name: "PDV_Bless_Imperial_Mara_T1", Object: "Devotion.esp:000004" }],
    ["PDV_Bless_Imperial_Mara_T2", { Name: "PDV_Bless_Imperial_Mara_T2", Object: "Devotion.esp:000005" }],
  ]);
  const rows = collectRewardRows(source);
  const result = auditRows(rows, records, props, source);
  const hasMissingSpell = result.findings.some((finding) => finding.detail.includes("PDV_Bless_Imperial_Akatosh_T3"));
  const hasUnfilled = result.findings.some((finding) => finding.detail.includes("PDV_Bless_Imperial_Mara_T3"));
  const hasPendingFalsePositive = result.findings.some((finding) => finding.detail.includes("PendingMedallionEntry"));
  const ok = hasMissingSpell && hasUnfilled && !hasPendingFalsePositive;
  console.log(JSON.stringify({
    ok,
    checks: {
      catchesMissingSpell: hasMissingSpell,
      catchesUnfilledProperty: hasUnfilled,
      ignoresPendingRosterEntry: !hasPendingFalsePositive,
    },
  }, null, 2));
  process.exit(ok ? 0 : 1);
}

function main() {
  if (SELF_TEST) {
    selfTest();
    return;
  }
  const source = fs.readFileSync(MANAGER, "utf8");
  const recordsByEdid = scanEsp();
  const managerProps = readManager(recordsByEdid);
  const rows = collectRewardRows(source);
  const { rows: auditedRows, findings } = auditRows(rows, recordsByEdid, managerProps, source);
  writeLedgers(auditedRows, findings);
  const summary = {
    status: findings.length ? "FAIL" : "PASS",
    rows: auditedRows.length,
    failures: findings.length,
    ledger: toPosix(path.relative(ROOT, OUT_MD)),
    csv: toPosix(path.relative(ROOT, OUT_CSV)),
  };
  if (JSON_MODE) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    console.log(`PDV eligibility reward coverage: ${summary.status} (${summary.rows} rows, ${summary.failures} failures)`);
    console.log(`Ledger: ${summary.ledger}`);
  }
  process.exitCode = findings.length ? 1 : 0;
}

try {
  main();
} catch (error) {
  if (JSON_MODE) {
    console.log(JSON.stringify({ status: "FAIL", rows: 0, failures: 1, error: error.message }, null, 2));
  } else {
    console.error(`[FAIL] ${error.message}`);
  }
  process.exitCode = 1;
}
