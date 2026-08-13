#!/usr/bin/env node
/*
 * pdv_p2_formlist_esp_audit.mjs
 *
 * ESP-TRUTH audit for the Phase 20 P2 immersive-receiver FormLists.
 *
 * The other signal audits (pdv_signal_floor_audit.mjs, pdv_signal_e2e_gate.mjs)
 * read git live-source + CSV ledgers. They CANNOT see the deployed Devotion.esp,
 * so when the Anvil HTTP MCP server is down the E2E gate SKIPs every live-ESP
 * column and stamps each surface INCOMPLETE with failing_step "shell". That is a
 * server-down artifact, NOT a claim the FormList is an empty shell -- but it reads
 * that way, and it forces every race-path UNDER-FLOOR in the signal-floor ledger.
 *
 * This audit closes that blind spot by reading the ACTUAL FormList population
 * directly from Devotion.esp through the standalone mutagen-bridge.exe (the same
 * binary pdv_verify.mjs uses; it works even when the HTTP MCP server is offline).
 * FLST contents live under the "Items" field (NOT "FormIDs").
 *
 * It FAILS on:
 *   (a) empty-routed   -- a FormList referenced by live routing but empty in the ESP
 *                         (a genuine, content-less shell).
 *   (b) ledger-drift   -- a ledger presents a surface as shell / unverified / not-wired
 *                         while the ESP proves it populated (the stale-ledger class the
 *                         Breton Green Way "2/5 types INCOMPLETE/shell" report was).
 *   (c) fill-missing   -- a manifest sourceFillEntries formKey marked approved-for-fill
 *                         is absent from the live ESP FormList (a real deploy gap).
 *
 * It also reports (non-fatal) esp-undeclared content: ESP Items not enumerated in the
 * manifest sourceFillEntries, so manifest/ESP governance drift is visible.
 *
 * Outputs (under references/authoring/):
 *   PDV_P2FormListEspLedger.csv
 *   PDV_P2FormListEspLedger.md
 *
 * Read-only except for its own two ledger files. No external deps beyond node:fs
 * and the mutagen-bridge.exe subprocess.
 *
 * Exit codes: 0 = clean, 1 = at least one FAIL finding, 2 = inconclusive (bridge
 * unavailable / ESP unreadable); inconclusive never reports a false PASS.
 */

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--anvil-root", "--bridge", "--esp", "--json", "--self-test", "--selftest", "--strict-undeclared"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_p2_formlist_esp_audit" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = path.join(ROOT, "references", "authoring");
const SOURCE = path.join(ROOT, "live-source", "Scripts", "Source");

const args = process.argv.slice(2);
const JSON_OUT = args.includes("--json");
const STRICT_UNDECLARED = args.includes("--strict-undeclared");

// Anvil/MO2 deployment paths. Match pdv_verify.mjs; overridable for portability.
const ANVIL_ROOT = getArg("--anvil-root") ?? process.env.PDV_ANVIL_ROOT ?? "D:/Wabbajack/modlists/Anvil";
const PDV_ESP = toPosix(getArg("--esp") ?? path.join(ANVIL_ROOT, "mods", "Devotion", "Devotion.esp"));
const MUTAGEN_BRIDGE = getArg("--bridge") ?? path.join(
  ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe",
);
const MUTAGEN_BRIDGE_MAX_BUFFER = 128 * 1024 * 1024;

const PATHS = {
  manifest: path.join(AUTH, "PDV_Phase20_P2ImmersiveReceivers.manifest.json"),
  e2eLedger: path.join(AUTH, "PDV_SignalE2EGateLedger.csv"),
  floorLedger: path.join(AUTH, "PDV_SignalFloorLedger.csv"),
  playerEvents: path.join(SOURCE, "PDV_PlayerEvents.psc"),
  eventBus: path.join(SOURCE, "PDV_EventBus.psc"),
  outCsv: path.join(AUTH, "PDV_P2FormListEspLedger.csv"),
  outMd: path.join(AUTH, "PDV_P2FormListEspLedger.md"),
};

function getArg(name) {
  const idx = args.indexOf(name);
  if (idx >= 0 && idx + 1 < args.length) return args[idx + 1];
  const prefix = `${name}=`;
  const inline = args.find((a) => a.startsWith(prefix));
  return inline ? inline.slice(prefix.length) : null;
}

function toPosix(p) {
  return String(p).replace(/\\/g, "/");
}

function readText(p) {
  return fs.existsSync(p) ? fs.readFileSync(p, "utf8") : "";
}

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8").replace(/^﻿/, ""));
}

// --- minimal RFC-4180-ish CSV parser (quoted fields, embedded commas) ----------
function parseCsv(txt) {
  const rows = [];
  let i = 0, field = "", row = [], inq = false;
  while (i < txt.length) {
    const c = txt[i];
    if (inq) {
      if (c === '"') {
        if (txt[i + 1] === '"') { field += '"'; i += 2; continue; }
        inq = false; i++; continue;
      }
      field += c; i++; continue;
    }
    if (c === '"') { inq = true; i++; continue; }
    if (c === ",") { row.push(field); field = ""; i++; continue; }
    if (c === "\r") { i++; continue; }
    if (c === "\n") { row.push(field); rows.push(row); row = []; field = ""; i++; continue; }
    field += c; i++;
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows;
}

function csvToObjects(txt) {
  const rows = parseCsv(txt).filter((r) => r.length > 1 || (r.length === 1 && r[0].trim() !== ""));
  if (!rows.length) return [];
  const hdr = rows[0].map((h) => h.trim());
  return rows.slice(1).map((r) => {
    const o = {};
    hdr.forEach((h, idx) => { o[h] = (r[idx] ?? "").trim(); });
    return o;
  });
}

// FormKey normalization: "Plugin.ext:HHHHHH" -> "plugin.ext:HHHHHH" (hex uppercased,
// low 6 digits). The mutagen bridge and the manifest both emit 6-hex local ids, but
// normalize defensively so a stray leading-zero or case difference never mis-compares.
function normFormKey(fk) {
  const s = String(fk || "").trim();
  const idx = s.lastIndexOf(":");
  if (idx < 0) return s.toLowerCase();
  const plugin = s.slice(0, idx).toLowerCase();
  let hex = s.slice(idx + 1).replace(/^0x/i, "").toUpperCase().replace(/[^0-9A-F]/g, "");
  if (hex.length > 6) hex = hex.slice(-6);
  hex = hex.padStart(6, "0");
  return `${plugin}:${hex}`;
}

// ---------------------------------------------------------------------------
function bridge(request, timeoutMs = 60_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: MUTAGEN_BRIDGE_MAX_BUFFER,
    windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  let payload;
  try {
    payload = JSON.parse(stdout);
  } catch {
    throw new Error(`mutagen-bridge returned invalid JSON: ${stdout.slice(0, 400)}`);
  }
  if (!payload.success) throw new Error(payload.error || payload.message || "bridge call failed");
  return payload;
}

// Read every P2 FormList's live Items from the ESP. Returns a Map(property -> {
//   exists, formid, items:[normFormKey], rawItems:[...] }) or throws / returns null
// on an inconclusive bridge state.
function readEspFormLists(properties) {
  if (!fs.existsSync(MUTAGEN_BRIDGE)) {
    return { ok: false, reason: `mutagen-bridge.exe not found at ${MUTAGEN_BRIDGE}` };
  }
  if (!fs.existsSync(PDV_ESP)) {
    return { ok: false, reason: `Devotion.esp not found at ${PDV_ESP}` };
  }

  let scan;
  try {
    scan = bridge({ command: "scan", plugins: [PDV_ESP] });
  } catch (err) {
    return { ok: false, reason: `ESP scan failed: ${err.message}` };
  }
  const records = scan.plugins?.[0]?.records ?? [];
  if (!records.length) return { ok: false, reason: "ESP scan returned no records." };

  const edidToFormid = new Map();
  for (const r of records) if (r.edid) edidToFormid.set(r.edid, r.formid);

  const present = properties.filter((p) => edidToFormid.has(p));
  const detailByEdid = new Map();
  if (present.length) {
    let detail;
    try {
      detail = bridge({
        command: "read_records",
        max_depth: 6,
        records: present.map((p) => ({ plugin_path: PDV_ESP, formid: edidToFormid.get(p) })),
      });
    } catch (err) {
      return { ok: false, reason: `ESP detail read failed: ${err.message}` };
    }
    for (const r of detail.records ?? []) {
      if (r.editor_id) detailByEdid.set(r.editor_id, r);
    }
  }

  const map = new Map();
  for (const p of properties) {
    const formid = edidToFormid.get(p) ?? "";
    if (!formid) {
      map.set(p, { exists: false, formid: "", items: [], rawItems: [] });
      continue;
    }
    const rec = detailByEdid.get(p);
    const raw = (rec && rec.success && rec.fields && Array.isArray(rec.fields.Items)) ? rec.fields.Items : [];
    map.set(p, { exists: true, formid, items: raw.map(normFormKey), rawItems: raw });
  }
  return { ok: true, map, recordCount: scan.plugins?.[0]?.record_count ?? records.length };
}

// Pure per-receiver evaluation. Takes resolved inputs (no IO) so it is testable in
// isolation and the --selftest mode can prove every FAIL direction fires.
//   espEntry: { exists, items:[normFormKey] } | null
//   approved: [{ formKey(normalized), editorId, sourceKind }]
//   e2e:      raw E2E ledger row | undefined
//   floorLabels: [signal-floor blocked_p2_surfaces labels for this property]
function computeRow({ prop, race, routed, approved, e2e, floorLabels, espOk, espEntry, strictUndeclared }) {
  const espExists = espEntry ? espEntry.exists : null;
  const espItems = espEntry ? espEntry.items : [];
  const itemCount = espEntry && espEntry.exists ? espItems.length : (espEntry ? 0 : null);

  const e2eShellStatus = String(e2e?.shell ?? "").toUpperCase();       // PASS/SKIP/FAIL/""
  const e2eVerdict = String(e2e?.verdict ?? "").toUpperCase();
  const e2eFailingStep = String(e2e?.failing_step ?? "").trim();
  const e2eShellClaim = Boolean(e2e) && e2eVerdict !== "GREEN"
    && (e2eShellStatus !== "PASS" || e2eFailingStep === "shell");
  const floorShellClaim = floorLabels.some((l) => /shell/i.test(l));
  const ledgerShellClaim = e2eShellClaim || floorShellClaim;

  const approvedMissing = espEntry && espEntry.exists
    ? approved.filter((a) => !espItems.includes(a.formKey))
    : [];
  const declaredKeys = new Set(approved.map((a) => a.formKey));
  const undeclared = espEntry && espEntry.exists ? espItems.filter((k) => !declaredKeys.has(k)) : [];

  const findings = [];
  if (espOk) {
    if (espExists === false) {
      findings.push({ kind: "missing-record", level: "FAIL", detail: "No FLST record for this receiver property exists in the ESP." });
    } else {
      if (itemCount === 0 && routed) {
        findings.push({ kind: "empty-routed", level: "FAIL", detail: "Referenced by live routing but the ESP FormList is empty (content-less shell)." });
      }
      if (itemCount > 0 && ledgerShellClaim) {
        const who = [
          e2eShellClaim ? `E2E(${e2eVerdict || "?"}/${e2eFailingStep || "shell"})` : "",
          floorShellClaim ? `signal-floor(${floorLabels.join(",")})` : "",
        ].filter(Boolean).join(" + ");
        findings.push({ kind: "ledger-drift", level: "FAIL", detail: `ESP FormList holds ${itemCount} item(s) but ${who} presents it as shell/unverified. Stale ledger, not a data gap.` });
      }
      if (approvedMissing.length) {
        findings.push({ kind: "fill-missing", level: "FAIL", detail: `Manifest approved-for-fill entr${approvedMissing.length === 1 ? "y" : "ies"} absent from ESP: ${approvedMissing.map((a) => `${a.editorId || a.formKey}`).join(", ")}.` });
      }
      if (undeclared.length && approved.length === 0) {
        findings.push({ kind: "esp-undeclared", level: strictUndeclared ? "FAIL" : "WARN", detail: `ESP holds ${undeclared.length} item(s) but the manifest declares no approved sourceFillEntries for this surface (undeclared ESP content).` });
      } else if (undeclared.length) {
        findings.push({ kind: "esp-undeclared", level: strictUndeclared ? "FAIL" : "WARN", detail: `ESP holds ${undeclared.length} item(s) beyond the ${approved.length} manifest-declared approved fill(s).` });
      }
    }
  }

  const verdict = !espOk
    ? "INCONCLUSIVE"
    : (findings.some((f) => f.level === "FAIL") ? "FAIL"
      : findings.some((f) => f.level === "WARN") ? "WARN" : "OK");

  return {
    prop, race, routed,
    espExists, itemCount,
    approvedCount: approved.length,
    approvedMissingCount: approvedMissing.length,
    undeclaredCount: undeclared.length,
    e2eVerdict: e2eVerdict || (e2e ? "" : "(no-row)"),
    e2eFailingStep,
    floorLabels,
    ledgerShellClaim,
    findings,
    verdict,
  };
}

// Deterministic FAIL-direction self-test: prove each finding kind fires so the gate is
// provably not a can-only-say-OK no-op. Mirrors the E2E gate's parity self-test.
function runSelftest() {
  const cases = [
    {
      name: "empty-routed",
      row: computeRow({ prop: "PDV_FLST_P2_Test", race: "Test", routed: true, approved: [], e2e: undefined, floorLabels: [], espOk: true, espEntry: { exists: true, items: [] }, strictUndeclared: false }),
      wantKind: "empty-routed",
    },
    {
      name: "ledger-drift",
      row: computeRow({ prop: "PDV_FLST_P2_Test", race: "Test", routed: true, approved: [], e2e: { verdict: "INCOMPLETE", failing_step: "shell", shell: "SKIP" }, floorLabels: ["INCOMPLETE/shell"], espOk: true, espEntry: { exists: true, items: ["skyrim.esm:000ABC"] }, strictUndeclared: false }),
      wantKind: "ledger-drift",
    },
    {
      name: "fill-missing",
      row: computeRow({ prop: "PDV_FLST_P2_Test", race: "Test", routed: true, approved: [{ formKey: "skyrim.esm:000DEF", editorId: "ApprovedBook", sourceKind: "book" }], e2e: { verdict: "GREEN" }, floorLabels: [], espOk: true, espEntry: { exists: true, items: ["skyrim.esm:000ABC"] }, strictUndeclared: false }),
      wantKind: "fill-missing",
    },
    {
      name: "missing-record",
      row: computeRow({ prop: "PDV_FLST_P2_Test", race: "Test", routed: true, approved: [], e2e: undefined, floorLabels: [], espOk: true, espEntry: { exists: false, items: [] }, strictUndeclared: false }),
      wantKind: "missing-record",
    },
    {
      name: "clean-OK",
      row: computeRow({ prop: "PDV_FLST_P2_Test", race: "Test", routed: true, approved: [{ formKey: "skyrim.esm:000ABC", editorId: "ApprovedBook", sourceKind: "book" }], e2e: { verdict: "GREEN" }, floorLabels: [], espOk: true, espEntry: { exists: true, items: ["skyrim.esm:000ABC"] }, strictUndeclared: false }),
      wantKind: null, // expect OK, no findings
    },
  ];

  let failed = 0;
  for (const c of cases) {
    const kinds = c.row.findings.map((f) => f.kind);
    const ok = c.wantKind === null
      ? (kinds.length === 0 && c.row.verdict === "OK")
      : (kinds.includes(c.wantKind) && c.row.verdict === "FAIL");
    console.log(`  [${ok ? "PASS" : "FAIL"}] ${c.name}: verdict=${c.row.verdict} findings=[${kinds.join(",") || "none"}]`);
    if (!ok) failed++;
  }
  console.log(`Self-test: ${failed ? `FAIL (${failed} case(s))` : "PASS (all FAIL directions fire; clean case stays OK)"}`);
  process.exitCode = failed ? 1 : 0;
}

// ===========================================================================
function main() {
  // `--self-test` is the canonical spelling across the other 18 self-testing tools; this
  // file was the lone `--selftest`, which made the wrong spelling elsewhere into a real flag
  // here and a silently-ignored one there. Both work now, canonical first.
  if (args.includes("--self-test") || args.includes("--selftest")) return runSelftest();
  const manifest = readJson(PATHS.manifest);
  const properties = (manifest.sourceProperties ?? [])
    .map((sp) => String(sp.property ?? "").trim())
    .filter((p) => p.startsWith("PDV_FLST_P2_"));
  const uniqueProps = [...new Set(properties)].sort();

  const raceByProp = new Map();
  for (const sp of manifest.sourceProperties ?? []) {
    const prop = String(sp.property ?? "").trim();
    if (!prop.startsWith("PDV_FLST_P2_")) continue;
    raceByProp.set(prop, String(sp.race ?? "").trim());
  }

  // Manifest approved-for-fill formKeys per property.
  const approvedByProp = new Map();
  for (const group of manifest.sourceFillEntries ?? []) {
    const prop = String(group.property ?? "").trim();
    if (!prop) continue;
    const approved = (group.sources ?? [])
      .filter((s) => String(s.status ?? "").toLowerCase() === "approved-for-fill")
      .map((s) => ({ formKey: normFormKey(s.formKey), editorId: String(s.editorId ?? ""), sourceKind: String(s.sourceKind ?? "") }));
    approvedByProp.set(prop, approved);
  }

  // Live routing reference set: a property token present in PlayerEvents/EventBus.
  const routingText = `${readText(PATHS.playerEvents)}\n${readText(PATHS.eventBus)}`;
  const routedProps = new Set(uniqueProps.filter((p) => routingText.includes(p)));

  // Ledger claims: E2E per-property, signal-floor blocked-surface labels.
  const e2eByProp = new Map();
  for (const row of csvToObjects(readText(PATHS.e2eLedger))) {
    if (row.property) e2eByProp.set(row.property, row);
  }
  const floorClaimByProp = new Map(); // property -> [label...] gathered from blocked_p2_surfaces
  for (const row of csvToObjects(readText(PATHS.floorLedger))) {
    const blocked = String(row.blocked_p2_surfaces ?? "");
    if (!blocked) continue;
    for (const chunk of blocked.split("|").map((s) => s.trim()).filter(Boolean)) {
      const sep = chunk.indexOf(":");
      if (sep < 0) continue;
      const prop = chunk.slice(0, sep).trim();
      const label = chunk.slice(sep + 1).trim();
      if (!floorClaimByProp.has(prop)) floorClaimByProp.set(prop, []);
      floorClaimByProp.get(prop).push(label);
    }
  }

  const esp = readEspFormLists(uniqueProps);
  const inconclusive = !esp.ok;

  const rows = uniqueProps.map((prop) => computeRow({
    prop,
    race: raceByProp.get(prop) ?? "",
    routed: routedProps.has(prop),
    approved: approvedByProp.get(prop) ?? [],
    e2e: e2eByProp.get(prop),
    floorLabels: floorClaimByProp.get(prop) ?? [],
    espOk: esp.ok,
    espEntry: esp.ok ? esp.map.get(prop) : null,
    strictUndeclared: STRICT_UNDECLARED,
  }));

  const summary = {
    generatedAt: new Date().toISOString(),
    esp: PDV_ESP,
    bridge: toPosix(MUTAGEN_BRIDGE),
    inconclusive,
    inconclusiveReason: inconclusive ? esp.reason : null,
    surfaces: rows.length,
    populated: rows.filter((r) => r.itemCount > 0).length,
    empty: rows.filter((r) => r.espExists && r.itemCount === 0).length,
    missingRecord: rows.filter((r) => r.espExists === false).length,
    fails: rows.filter((r) => r.verdict === "FAIL").length,
    warns: rows.filter((r) => r.verdict === "WARN").length,
    driftRows: rows.filter((r) => r.findings.some((f) => f.kind === "ledger-drift")).length,
    emptyRoutedRows: rows.filter((r) => r.findings.some((f) => f.kind === "empty-routed")).length,
    fillMissingRows: rows.filter((r) => r.findings.some((f) => f.kind === "fill-missing")).length,
  };

  writeLedgers(rows, summary);

  if (JSON_OUT) {
    console.log(JSON.stringify({ summary, rows }, null, 2));
  } else {
    printConsole(rows, summary);
  }

  process.exitCode = inconclusive ? 2 : (summary.fails > 0 ? 1 : 0);
}

function printConsole(rows, summary) {
  if (summary.inconclusive) {
    console.log(`P2 FormList ESP audit: INCONCLUSIVE -- ${summary.inconclusiveReason}`);
    console.log("The deployed ESP could not be read; no PASS is asserted. Start the Anvil MCP/bridge and re-run.");
    return;
  }
  console.log(`P2 FormList ESP audit: ${summary.fails ? "FAIL" : "PASS"} -- ${summary.surfaces} P2 receivers | ${summary.populated} populated, ${summary.empty} empty, ${summary.missingRecord} missing-record`);
  console.log(`  drift(ledger-shell vs populated ESP): ${summary.driftRows} | empty-routed: ${summary.emptyRoutedRows} | fill-missing: ${summary.fillMissingRows} | warn: ${summary.warns}`);
  const problems = rows.filter((r) => r.verdict === "FAIL" || r.verdict === "WARN");
  for (const r of problems) {
    for (const f of r.findings) {
      console.log(`  [${f.level}] ${r.prop} (${r.race}) ${f.kind}: ${f.detail}`);
    }
  }
  console.log(`Wrote: ${rel(PATHS.outCsv)}`);
  console.log(`Wrote: ${rel(PATHS.outMd)}`);
}

function rel(p) {
  return path.relative(ROOT, p).replace(/\\/g, "/");
}

function csvCell(s) {
  s = String(s ?? "");
  if (/[",\n]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
  return s;
}

function writeLedgers(rows, summary) {
  const header = [
    "property", "race", "routed", "esp_exists", "esp_item_count",
    "manifest_approved_fills", "manifest_fills_missing_in_esp", "esp_undeclared_items",
    "e2e_verdict", "e2e_failing_step", "ledger_shell_claim", "verdict", "findings",
  ];
  const lines = [header.join(",")];
  for (const r of rows) {
    lines.push([
      r.prop, r.race, r.routed ? "yes" : "no",
      r.espExists === null ? "" : (r.espExists ? "yes" : "no"),
      r.itemCount === null ? "" : r.itemCount,
      r.approvedCount, r.approvedMissingCount, r.undeclaredCount,
      r.e2eVerdict, r.e2eFailingStep, r.ledgerShellClaim ? "yes" : "no",
      r.verdict,
      r.findings.map((f) => `${f.level}:${f.kind}`).join("; "),
    ].map(csvCell).join(","));
  }
  fs.writeFileSync(PATHS.outCsv, lines.join("\n") + "\n", "utf8");

  const md = [];
  md.push("# PDV P2 FormList ESP-Truth Ledger");
  md.push("");
  md.push(`**Generated:** ${summary.generatedAt.slice(0, 10)} by \`tools/pdv_p2_formlist_esp_audit.mjs\` (reads the deployed Devotion.esp via mutagen-bridge.exe)`);
  md.push("");
  if (summary.inconclusive) {
    md.push(`> **INCONCLUSIVE** -- the ESP could not be read (${asciiSafe(summary.inconclusiveReason)}). No PASS is asserted.`);
    md.push("");
  }
  md.push("This audit is the server-independent counterpart to `pdv_signal_e2e_gate.mjs`. It reads the true FormList " +
    "population (`Items` field) straight from `Devotion.esp` and fails on empty-but-routed lists, on ledger drift " +
    "(a ledger calls a surface shell/unverified while the ESP proves it populated), and on manifest approved fills " +
    "missing from the live ESP.");
  md.push("");
  md.push("## Summary");
  md.push("");
  md.push(`- P2 receivers audited: **${summary.surfaces}**`);
  md.push(`- Populated: **${summary.populated}** | Empty: **${summary.empty}** | Missing FLST record: **${summary.missingRecord}**`);
  md.push(`- FAIL rows: **${summary.fails}** | WARN rows: **${summary.warns}**`);
  md.push(`- ledger-drift (shell claim vs populated ESP): **${summary.driftRows}** | empty-routed: **${summary.emptyRoutedRows}** | fill-missing: **${summary.fillMissingRows}**`);
  md.push("");
  const problems = rows.filter((r) => r.findings.length);
  if (problems.length) {
    md.push("## Findings");
    md.push("");
    md.push("| Level | Property | Race | Kind | Detail |");
    md.push("|---|---|---|---|---|");
    for (const r of problems) {
      for (const f of r.findings) {
        md.push(`| ${f.level} | \`${r.prop}\` | ${r.race} | ${f.kind} | ${asciiSafe(f.detail)} |`);
      }
    }
    md.push("");
  }
  md.push("## Full per-receiver table");
  md.push("");
  md.push("| Property | Race | Routed | ESP items | Approved fills | Fills missing | Undeclared | E2E verdict | Shell claim | Verdict |");
  md.push("|---|---|---|---|---|---|---|---|---|---|");
  for (const r of rows) {
    md.push(`| \`${r.prop}\` | ${r.race} | ${r.routed ? "yes" : "no"} | ${r.itemCount ?? "?"} | ${r.approvedCount} | ${r.approvedMissingCount} | ${r.undeclaredCount} | ${r.e2eVerdict}${r.e2eFailingStep ? `/${r.e2eFailingStep}` : ""} | ${r.ledgerShellClaim ? "yes" : "no"} | ${r.verdict} |`);
  }
  md.push("");
  fs.writeFileSync(PATHS.outMd, md.join("\n") + "\n", "utf8");
}

function asciiSafe(value) {
  return String(value ?? "")
    .replace(/—/g, "--")
    .replace(/[‐‑‒–]/g, "-")
    .replace(/→/g, "->")
    .replace(/[‘’]/g, "'")
    .replace(/[“”]/g, '"')
    .replace(/[^\x00-\x7F]/g, "?");
}

main();
