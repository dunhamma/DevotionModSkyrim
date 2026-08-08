#!/usr/bin/env node
/*
 * PDV Felt-Effect Trace Audit (C-FELT-TRACE) - exhaustive machine trace of
 * every effect in PDV_FeltEffectRegistry.json:
 *
 *   declared -> wired (live-source reference / generated likes-dislikes row
 *   with matching delta+cap) -> record (ESP EDID readback via mutagen bridge)
 *
 * Dispatch-order and reachability for reward spells stay owned by
 * pdv_deity_chain_audit.mjs / pdv_reward_runtime_order_lint.mjs (this audit
 * does not re-derive them). CSV dislikes get a hard magnitude check: the
 * WriteLD/WritePLD row in the generated manager table must match the CSV
 * baseDelta and dailyCap, which machine-catches the "CSV edited but
 * pdv_likesdislikes_gen not re-run" failure class.
 *
 * SKIP-not-PASS: when the mutagen bridge is down, ESP record links report
 * SKIP and the overall status is SKIP (never PASS).
 *
 * Emits PDV_FeltTraceLedger.json/.md/.csv. Exit 0 iff overall PASS.
 * Flags: --json, --self-test
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_felt_trace_audit" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = "references/authoring";
const REGISTRY = path.join(ROOT, AUTH, "PDV_FeltEffectRegistry.json");
const OUT_BASE = path.join(ROOT, AUTH, "PDV_FeltTraceLedger");
const LIVE_SOURCE_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const PDV_ESP = path.join(ANVIL_ROOT, "mods", "Devotion", "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe");

const flags = new Set(process.argv.slice(2));

function loadCorpus(dir) {
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".psc"));
  let corpus = "";
  for (const f of files) {
    const text = fs.readFileSync(path.join(dir, f), "utf8");
    // Strip comment lines so a commented-out reference does not count as wired.
    corpus += text.split(/\r?\n/).filter((l) => !l.trim().startsWith(";")).join("\n") + "\n";
  }
  return corpus;
}

// Parse WriteLD / WritePLD branch tables out of the manager source.
export function parseGeneratedRows(managerSource) {
  const tables = { deity: new Map(), prince: new Map() };
  for (const [fnName, writer, map] of [
    ["LoadRowsForDeity", "WriteLD", tables.deity],
    ["LoadPrinceRowsForPath", "WritePLD", tables.prince],
  ]) {
    const fnRe = new RegExp(`Function\\s+${fnName}\\s*\\([^)]*\\)([\\s\\S]*?)\\nEndFunction`, "i");
    const m = managerSource.match(fnRe);
    if (!m) continue;
    let current = null;
    for (const line of m[1].split(/\r?\n/)) {
      const branch = line.match(/(?:if|elseIf)\s+ldName\s*==\s*"([^"]+)"/i);
      if (branch) { current = branch[1]; if (!map.has(current)) map.set(current, []); continue; }
      const call = line.match(new RegExp(`${writer}\\s*\\(\\s*\\w+\\s*,\\s*(\\d+)\\s*,\\s*(-?[\\d.]+)\\s*,\\s*(\\d+)\\s*,\\s*(-?[\\d.]+)(?:\\s*,\\s*(-?\\d+))?`));
      if (call && current) {
        map.get(current).push({ eventId: Number(call[1]), delta: Number(call[2]), cap: Number(call[3]), cooldown: Number(call[4]), originGate: call[5] === undefined ? null : Number(call[5]) });
      }
    }
  }
  return tables;
}

function bridgeScan() {
  if (!fs.existsSync(MUTAGEN_BRIDGE) || !fs.existsSync(PDV_ESP)) return { down: true, reason: "bridge or ESP path absent" };
  const r = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify({ command: "scan", plugins: [PDV_ESP.replace(/\\/g, "/")] }),
    encoding: "utf8", timeout: 120_000, maxBuffer: 128 * 1024 * 1024, windowsHide: true,
  });
  if (r.error || !String(r.stdout ?? "").trim()) return { down: true, reason: r.error ? r.error.message : "no bridge output" };
  try {
    const payload = JSON.parse(r.stdout.trim());
    if (!payload.success) return { down: true, reason: payload.error ?? "bridge call failed" };
    const edids = new Set();
    for (const rec of payload.plugins?.[0]?.records ?? []) if (rec.edid) edids.add(rec.edid);
    return { down: false, edids };
  } catch (e) {
    return { down: true, reason: `bridge output unparseable: ${e.message}` };
  }
}

// CSV actor -> generated-table branch name.
function branchNameFor(effect) {
  const m = effect.declaredIn.match(/actor=([^ ]+(?: [^ ]+)*?) eventId=/);
  const actor = m ? m[1] : null;
  if (!actor) return null;
  return actor.replace(/^Daedric:/, "");
}

export function traceEffects(registry, corpus, tables, esp) {
  const rows = [];
  for (const e of registry.effects) {
    let wired, record, detail = [];

    if (e.origin === "likes-dislikes-csv") {
      const branchName = branchNameFor(e);
      const table = e.declaredIn.includes("Princes_V2") ? tables.prince : tables.deity;
      const branch = [...table.entries()].find(([name]) => name.toLowerCase() === String(branchName).toLowerCase())?.[1];
      const eventId = Number(e.declaredIn.match(/eventId=(\d+)/)?.[1]);
      if (!branch) { wired = "RED"; detail.push(`no generated branch for actor '${branchName}' (run pdv_likesdislikes_gen + version bump)`); }
      else {
        const expectedOriginGate = Number.isFinite(e.expected.originGate) ? e.expected.originGate : null;
        const row = branch.find((r) => r.eventId === eventId && (expectedOriginGate === null || r.originGate === expectedOriginGate));
        if (!row) { wired = "RED"; detail.push(`eventId ${eventId} missing from generated '${branchName}' rows (CSV/codegen drift)`); }
        else if (Math.abs(row.delta - e.expected.delta) > 0.001) { wired = "RED"; detail.push(`delta drift: generated ${row.delta} vs CSV ${e.expected.delta}`); }
        else if (Number.isFinite(e.expected.dailyCap) && row.cap !== e.expected.dailyCap) { wired = "RED"; detail.push(`dailyCap drift: generated ${row.cap} vs CSV ${e.expected.dailyCap}`); }
        else wired = "PASS";
      }
      record = "N/A"; // StorageUtil rows, no ESP record expected.
    } else {
      const ids = e.expected.espEditorIds.length ? e.expected.espEditorIds : [e.effectId];
      const sourceRefs = ids.filter((id) => typeof id === "string" && id.startsWith("PDV_") && corpus.includes(id));
      if (e.origin === "prince-contract-curse") {
        wired = corpus.includes("PDV_CurseState") ? "PASS" : "RED";
        if (wired === "RED") detail.push("shared curse seam PDV_CurseState not referenced in live source");
        record = "N/A";
      } else {
        // Wired when at least one declared editor id (SPEL/MESG) is referenced
        // in live source, OR the effect's granting property (base-script
        // property such as Boon_Seeker / Substrate_High, bound to the record
        // via CK VMAD) exists in live source. MGEF-only ids live in records,
        // not scripts. Property->record VMAD binding readback stays owned by
        // pdv_verify record contracts, not this audit.
        const scriptVisible = ids.filter((id) => !/^PDV_MGEF_/.test(id));
        // Substrate spells bind to the shared PDV_SubstrateBase tier properties
        // via VMAD; derive the property when the spec does not name it.
        const substrateMatch = String(e.effectId).match(/_Substrate_(Always|Mid|High)$/);
        const wiringProperty = e.wiringProperty ?? (substrateMatch ? `Substrate_${substrateMatch[1]}` : null);
        const propertyWired = wiringProperty && new RegExp(`\\b${wiringProperty}\\b`).test(corpus);
        wired = scriptVisible.length === 0 || sourceRefs.some((id) => !/^PDV_MGEF_/.test(id)) || propertyWired ? "PASS" : "RED";
        if (wired === "RED") detail.push(`neither [${scriptVisible.join(", ")}] nor granting property '${wiringProperty ?? "(none)"}' referenced in live-source .psc (silent no-op risk)`);
        if (esp.down) { record = "SKIP"; }
        else {
          const missing = ids.filter((id) => typeof id === "string" && id.startsWith("PDV_") && !esp.edids.has(id));
          record = missing.length ? "RED" : "PASS";
          if (missing.length) detail.push(`ESP records missing: ${missing.join(", ")}`);
        }
      }
    }

    const status = [wired, record].includes("RED") ? "RED" : [wired, record].includes("SKIP") ? "SKIP" : "PASS";
    rows.push({ effectId: e.effectId, familyId: e.familyId, class: e.class, lane: e.lane, origin: e.origin, wired, record, status, detail: detail.join("; ") });
  }
  return rows;
}

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  const src = [
    "Function LoadRowsForDeity(PDV_DeityBase deity)",
    '    if ldName == "kyne"',
    "        WriteLD(deity, 1, -0.5, 2, 0.0, -1)",
    "        WriteLD(deity, 1, -0.75, 1, 1.0, 2)",
    '    elseIf ldName == "Arkay"',
    "        WriteLD(deity, 40, 0.35, 3, 0.0208, -1)",
    "    endIf",
    "EndFunction",
    "Function LoadPrinceRowsForPath(PDV_DaedricPathBase path)",
    '    if ldName == "Hircine"',
    "        WritePLD(path, 304, -0.5, 3, 0.0)",
    "    endIf",
    "EndFunction",
    "Spell Property PDV_Bless_Test_T1 Auto",
  ].join("\n");
  const tables = parseGeneratedRows(src);
  expect("deity branch parsed", tables.deity.get("kyne")?.[0]?.delta === -0.5);
  expect("deity origin gate parsed", tables.deity.get("kyne")?.[1]?.originGate === 2);
  expect("prince branch parsed", tables.prince.get("Hircine")?.[0]?.eventId === 304);

  const registry = { effects: [
    { effectId: "csv:kyne:1", familyId: "Kyne|price", class: "price", lane: "Kyne", origin: "likes-dislikes-csv",
      declaredIn: "x.csv actor=kyne eventId=1 originGate=-1", expected: { espEditorIds: [], delta: -0.5, dailyCap: 2, originGate: -1 } },
    { effectId: "csv:kyne:1:origin:2", familyId: "Kyne|price", class: "price", lane: "Kyne", origin: "likes-dislikes-csv",
      declaredIn: "x.csv actor=kyne eventId=1 originGate=2", expected: { espEditorIds: [], delta: -0.75, dailyCap: 1, originGate: 2 } },
    { effectId: "csv:kyne:99", familyId: "Kyne|price", class: "price", lane: "Kyne", origin: "likes-dislikes-csv",
      declaredIn: "x.csv actor=kyne eventId=99", expected: { espEditorIds: [], delta: -1, dailyCap: 0 } },
    { effectId: "csv:hircine:304", familyId: "Daedric-Hircine|price", class: "price", lane: "Daedric-Hircine", origin: "likes-dislikes-csv",
      declaredIn: "Princes_V2.csv actor=Daedric:Hircine eventId=304", expected: { espEditorIds: [], delta: -0.75, dailyCap: 3 } },
    { effectId: "PDV_Bless_Test_T1", familyId: "Test|boon", class: "boon", lane: "Test", origin: "race-spec",
      declaredIn: "spec", expected: { espEditorIds: ["PDV_Bless_Test_T1", "PDV_MGEF_Bless_Test_T1"], effects: [] } },
    { effectId: "PDV_Bless_Ghost_T1", familyId: "Ghost|boon", class: "boon", lane: "Ghost", origin: "race-spec",
      declaredIn: "spec", expected: { espEditorIds: ["PDV_Bless_Ghost_T1"], effects: [] } },
  ] };
  const rows = traceEffects(registry, src, tables, { down: true, reason: "self-test" });
  const byId = Object.fromEntries(rows.map((r) => [r.effectId, r]));
  expect("csv row match PASS", byId["csv:kyne:1"].wired === "PASS");
  expect("csv origin row match PASS", byId["csv:kyne:1:origin:2"].wired === "PASS");
  expect("csv missing row RED", byId["csv:kyne:99"].wired === "RED");
  expect("csv delta drift RED", byId["csv:hircine:304"].wired === "RED");
  expect("wired spell PASS + record SKIP on bridge down", byId["PDV_Bless_Test_T1"].wired === "PASS" && byId["PDV_Bless_Test_T1"].record === "SKIP");
  expect("unwired spell RED", byId["PDV_Bless_Ghost_T1"].wired === "RED");
  expect("overall never PASS with SKIPs", rows.some((r) => r.status === "SKIP"));

  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

function main() {
  const registry = JSON.parse(fs.readFileSync(REGISTRY, "utf8"));
  const corpus = loadCorpus(LIVE_SOURCE_DIR);
  const manager = fs.readFileSync(path.join(LIVE_SOURCE_DIR, "PDV__ManagerQuest.psc"), "utf8");
  const tables = parseGeneratedRows(manager);
  const esp = bridgeScan();
  const rows = traceEffects(registry, corpus, tables, esp);

  const counts = { PASS: 0, SKIP: 0, RED: 0 };
  for (const r of rows) counts[r.status]++;
  const status = counts.RED ? "FAIL" : counts.SKIP ? "SKIP" : "PASS";

  const report = {
    schema: "pdv.felt-trace-ledger.v1",
    status,
    bridge: esp.down ? `DOWN (${esp.reason}) - ESP record links SKIP, never PASS` : "live",
    counts,
    registryEffects: registry.effects.length,
    redRows: rows.filter((r) => r.status === "RED"),
    skipCount: counts.SKIP,
  };
  fs.writeFileSync(`${OUT_BASE}.json`, JSON.stringify(report, null, 2) + "\n", "utf8");

  const md = [
    "# PDV Felt-Effect Trace Ledger", "",
    "GENERATED by tools/pdv_felt_trace_audit.mjs - do not hand-edit.", "",
    `Overall: **${status}** (PASS=${counts.PASS} SKIP=${counts.SKIP} RED=${counts.RED} of ${rows.length} effects). Bridge: ${report.bridge}.`, "",
    "Proof boundary: the record link proves ESP EDID presence; field-level magnitude/duration readback stays owned by pdv-phase20-race-author --check-rewards and the pdv_verify record contracts. CSV rows are checked value-for-value against the generated WriteLD/WritePLD manager tables.", "",
    "RED rows (broken declared->wired->record chains):", "",
    "| Effect | Lane | Class | Wired | Record | Detail |", "|---|---|---|---|---|---|",
  ];
  for (const r of rows.filter((x) => x.status === "RED")) {
    md.push(`| ${r.effectId} | ${r.lane} | ${r.class} | ${r.wired} | ${r.record} | ${r.detail.replace(/\|/g, "/")} |`);
  }
  if (!counts.RED) md.push("| (none) | | | | | |");
  md.push("");
  fs.writeFileSync(`${OUT_BASE}.md`, md.join("\n") + "\n", "utf8");

  const csv = ["effectId,familyId,lane,class,origin,wired,record,status,detail"];
  for (const r of rows) csv.push([r.effectId, r.familyId, r.lane, r.class, r.origin, r.wired, r.record, r.status, `"${r.detail.replace(/"/g, "'")}"`].join(","));
  fs.writeFileSync(`${OUT_BASE}.csv`, csv.join("\n") + "\n", "utf8");

  if (flags.has("--json")) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`Felt trace: ${status} (PASS=${counts.PASS} SKIP=${counts.SKIP} RED=${counts.RED} of ${rows.length})`);
    if (esp.down) console.log(`Bridge DOWN: ${esp.reason} - ESP record links SKIP-not-PASS.`);
    for (const r of report.redRows.slice(0, 20)) console.log(`[RED] ${r.effectId}: ${r.detail}`);
    if (report.redRows.length > 20) console.log(`... +${report.redRows.length - 20} more RED rows in ${path.relative(ROOT, OUT_BASE)}.md`);
  }
  process.exitCode = status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
