#!/usr/bin/env node
/*
 * PDV In-World Proof Gate (C-PLACEMENT-FINAL) - re-scoped 2026-07-07 with
 * user sign-off.
 *
 * "Final-world placement" in this project means: every immersive hook
 * contract has recorded EMPIRICAL IN-WORLD PROOF at its real context (a real
 * stronghold forge, tomb, nature site, quest stage), not that objects get
 * placed in cells. The hook contracts all carry newMeshRequired:false and
 * bind to existing world context; the PDV_REFR_* QASmoke activators are
 * permanent debug senders (relatedQASmokeProof), never player content.
 *
 * Gate = two fail-closed halves:
 *   1) REF INVENTORY: every PDV_REFR_* in Devotion.esp is classified in
 *      PDV_FinalPlacementManifest.json (dev-only / placed / not-applicable;
 *      qasmoke-only = unclassified = RED). Unlisted ESP ref or stale
 *      manifest entry = RED.
 *   2) HOOK PROOF: every immersiveHookContracts signalId in
 *      PDV_Phase20_NoInGameProof_Gates.json has a recorded slot in
 *      PDV_InWorldHookProofLedger.json (evidence-recorded / retro-credited /
 *      not-applicable; pending or missing = RED).
 *
 * Flags:
 *   --seed        merge current ESP REFR set into the manifest
 *   --seed-hooks  merge current hook contracts into the hook-proof ledger
 *   --json        JSON report
 *   --self-test   fixture test
 *
 * Emits PDV_FinalPlacementLedger.json/.md. Exit 0 iff PASS. Bridge down =>
 * ref half SKIPs (never PASS).
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = "references/authoring";
const MANIFEST = path.join(ROOT, AUTH, "PDV_FinalPlacementManifest.json");
const HOOK_LEDGER = path.join(ROOT, AUTH, "PDV_InWorldHookProofLedger.json");
const GATES = path.join(ROOT, AUTH, "PDV_Phase20_NoInGameProof_Gates.json");
const OUT_BASE = path.join(ROOT, AUTH, "PDV_FinalPlacementLedger");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const PDV_ESP = path.join(ANVIL_ROOT, "mods", "Devotion", "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe");

const flags = new Set(process.argv.slice(2));
const REF_STATUSES = ["qasmoke-only", "placed", "dev-only", "not-applicable"];
const HOOK_PASS = ["evidence-recorded", "retro-credited", "not-applicable"];

function scanRefs() {
  if (!fs.existsSync(MUTAGEN_BRIDGE) || !fs.existsSync(PDV_ESP)) return { down: true, reason: "bridge or ESP path absent" };
  const r = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify({ command: "scan", plugins: [PDV_ESP.replace(/\\/g, "/")] }),
    encoding: "utf8", timeout: 120_000, maxBuffer: 128 * 1024 * 1024, windowsHide: true,
  });
  if (r.error || !String(r.stdout ?? "").trim()) return { down: true, reason: r.error?.message ?? "no bridge output" };
  const payload = JSON.parse(r.stdout.trim());
  if (!payload.success) return { down: true, reason: payload.error ?? "bridge failed" };
  const refs = [];
  for (const rec of payload.plugins?.[0]?.records ?? []) {
    if (rec.type === "REFR" && rec.edid) refs.push({ edid: rec.edid, formid: rec.formid });
  }
  return { down: false, refs };
}

function loadHookContracts() {
  const gates = JSON.parse(fs.readFileSync(GATES, "utf8"));
  const hooks = [];
  for (const [race, r] of Object.entries(gates.races ?? {})) {
    for (const h of r.immersiveHookContracts ?? []) {
      hooks.push({ race, signalId: h.signalId, proofPath: h.proofPath ?? "", hookClass: h.hookClass ?? "" });
    }
  }
  return hooks;
}

export function evaluate(manifest, espRefs, hooks, hookLedger, bridgeDown) {
  const rows = [];

  // Half 1: ref inventory (fail-closed both directions).
  if (bridgeDown) {
    rows.push({ item: "(ref inventory)", kind: "ref", status: "SKIP", detail: "bridge down - ESP ref inventory SKIP, never PASS" });
  } else {
    const entries = manifest.refs ?? {};
    const espSet = new Set(espRefs.map((r) => r.edid));
    for (const ref of espRefs) {
      if (!entries[ref.edid]) rows.push({ item: ref.edid, kind: "ref", status: "RED", detail: "placed ESP reference has no manifest entry (run --seed then classify)" });
    }
    for (const [edid, entry] of Object.entries(entries)) {
      if (!espSet.has(edid)) { rows.push({ item: edid, kind: "ref", status: "RED", detail: "manifest entry no longer in Devotion.esp (stale)" }); continue; }
      if (!REF_STATUSES.includes(entry.status)) rows.push({ item: edid, kind: "ref", status: "RED", detail: `unknown status '${entry.status}'` });
      else if (entry.status === "qasmoke-only") rows.push({ item: edid, kind: "ref", status: "RED", detail: "unclassified (qasmoke-only): decide dev-only vs placed" });
      else if (entry.status === "placed" && !(entry.observed?.cell && entry.observed?.date && entry.observed?.evidence)) rows.push({ item: edid, kind: "ref", status: "RED", detail: "placed without observed cell/date/evidence readback" });
      else if ((entry.status === "dev-only" || entry.status === "not-applicable") && (entry.reason ?? "").length < 8) rows.push({ item: edid, kind: "ref", status: "RED", detail: `${entry.status} requires a real reason` });
      else rows.push({ item: edid, kind: "ref", status: "PASS", detail: entry.status });
    }
  }

  // Half 2: in-world hook proof (fail-closed on missing slots).
  const slots = hookLedger.hooks ?? {};
  for (const h of hooks) {
    const slot = slots[h.signalId];
    if (!slot) { rows.push({ item: h.signalId, kind: "hook", status: "RED", detail: `no proof slot (run --seed-hooks)` }); continue; }
    if (HOOK_PASS.includes(slot.status)) rows.push({ item: h.signalId, kind: "hook", status: "PASS", detail: `${slot.status} (${h.race})` });
    else rows.push({ item: h.signalId, kind: "hook", status: "RED", detail: `pending in-world proof (${h.race}): ${h.proofPath.slice(0, 90)}` });
  }
  for (const id of Object.keys(slots)) {
    if (!hooks.some((h) => h.signalId === id)) rows.push({ item: id, kind: "hook", status: "RED", detail: "ledger slot has no matching hook contract (stale)" });
  }

  const counts = { PASS: 0, RED: 0, SKIP: 0 };
  for (const r of rows) counts[r.status]++;
  const status = counts.RED ? "FAIL" : counts.SKIP ? "SKIP" : "PASS";
  return { status, counts, rows };
}

function seedRefs(espRefs) {
  let manifest = {
    schema: "pdv.final-placement-manifest.v1",
    purpose: "Classification inventory for every placed PDV reference in Devotion.esp. Per the immersive hook contracts (newMeshRequired:false everywhere), QASmoke activators are permanent debug senders: classify them dev-only with a reason. 'placed' requires observed cell/date/evidence readback.",
    rules: { allowedStatuses: REF_STATUSES, placedRequires: ["observed.cell", "observed.date", "observed.evidence"] },
    refs: {},
  };
  if (fs.existsSync(MANIFEST)) manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
  let added = 0;
  for (const ref of espRefs) {
    if (manifest.refs[ref.edid]) continue;
    manifest.refs[ref.edid] = { status: "qasmoke-only", formid: ref.formid, lane: ref.edid.replace(/^PDV_REFR_/, "").replace(/Signal$/, ""), intended: null, observed: null, reason: "" };
    added++;
  }
  manifest.updated = new Date().toISOString().slice(0, 10);
  fs.writeFileSync(MANIFEST, JSON.stringify(manifest, null, 2) + "\n", "utf8");
  return { added, total: Object.keys(manifest.refs).length };
}

function seedHooks(hooks) {
  let ledger = {
    schema: "pdv.in-world-hook-proof-ledger.v1",
    purpose: "One slot per immersive hook contract (C-PLACEMENT-FINAL): dated empirical proof that the hook fired from its REAL in-world context during play (not the QASmoke debug sender). Statuses: pending / evidence-recorded / retro-credited / not-applicable.",
    rules: { allowedStatuses: ["pending", ...HOOK_PASS] },
    hooks: {},
  };
  if (fs.existsSync(HOOK_LEDGER)) ledger = JSON.parse(fs.readFileSync(HOOK_LEDGER, "utf8"));
  let added = 0;
  for (const h of hooks) {
    if (ledger.hooks[h.signalId]) continue;
    ledger.hooks[h.signalId] = { race: h.race, status: "pending", expected: `In-world proof at real context: ${h.proofPath}`, note: "", creditedFrom: null };
    added++;
  }
  ledger.updated = new Date().toISOString().slice(0, 10);
  fs.writeFileSync(HOOK_LEDGER, JSON.stringify(ledger, null, 2) + "\n", "utf8");
  return { added, total: Object.keys(ledger.hooks).length };
}

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  const esp = [{ edid: "PDV_REFR_A", formid: "x:1" }, { edid: "PDV_REFR_ORPHAN", formid: "x:2" }];
  const manifest = { refs: { PDV_REFR_A: { status: "dev-only", reason: "debug sender per hook contract" }, PDV_REFR_B: { status: "qasmoke-only" } } };
  const hooks = [{ race: "Nord", signalId: "hook-a", proofPath: "p" }, { race: "Orc", signalId: "hook-b", proofPath: "p" }];
  const hookLedger = { hooks: { "hook-a": { status: "retro-credited" }, "hook-b": { status: "pending" }, "hook-stale": { status: "evidence-recorded" } } };
  const rep = evaluate(manifest, esp, hooks, hookLedger, false);
  expect("dev-only ref PASS", rep.rows.some((r) => r.item === "PDV_REFR_A" && r.status === "PASS"));
  expect("unlisted ESP ref RED", rep.rows.some((r) => r.item === "PDV_REFR_ORPHAN" && r.status === "RED"));
  expect("stale manifest ref RED", rep.rows.some((r) => r.item === "PDV_REFR_B" && r.status === "RED"));
  expect("credited hook PASS", rep.rows.some((r) => r.item === "hook-a" && r.status === "PASS"));
  expect("pending hook RED", rep.rows.some((r) => r.item === "hook-b" && r.status === "RED"));
  expect("stale hook slot RED", rep.rows.some((r) => r.item === "hook-stale" && r.status === "RED"));
  const rep2 = evaluate(manifest, esp, hooks, hookLedger, true);
  expect("bridge down -> ref half SKIP, overall not PASS", rep2.rows.some((r) => r.kind === "ref" && r.status === "SKIP") && rep2.status !== "PASS");
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

function main() {
  const scan = scanRefs();
  const hooks = loadHookContracts();
  if (flags.has("--seed") && !scan.down) console.log(`Manifest seeded: +${seedRefs(scan.refs).added} refs.`);
  if (flags.has("--seed-hooks")) console.log(`Hook ledger seeded: +${seedHooks(hooks).added} of ${hooks.length} hooks.`);
  const manifest = fs.existsSync(MANIFEST) ? JSON.parse(fs.readFileSync(MANIFEST, "utf8")) : { refs: {} };
  const hookLedger = fs.existsSync(HOOK_LEDGER) ? JSON.parse(fs.readFileSync(HOOK_LEDGER, "utf8")) : { hooks: {} };
  const report = evaluate(manifest, scan.down ? [] : scan.refs, hooks, hookLedger, scan.down);

  const out = {
    schema: "pdv.final-placement-ledger.v2",
    status: report.status,
    scope: "in-world hook proof + ref classification inventory (re-scoped 2026-07-07)",
    counts: report.counts,
    redRows: report.rows.filter((r) => r.status === "RED"),
  };
  fs.writeFileSync(`${OUT_BASE}.json`, JSON.stringify(out, null, 2) + "\n", "utf8");
  const md = [
    "# PDV In-World Proof Ledger (final placement)", "",
    "GENERATED by tools/pdv_placement_gate.mjs - do not hand-edit.", "",
    `Overall: **${report.status}** (PASS=${report.counts.PASS} RED=${report.counts.RED} SKIP=${report.counts.SKIP}). Scope: every immersive hook proven at its real in-world context; every ESP PDV_REFR classified.`, "",
    "| Item | Kind | Status | Detail |", "|---|---|---|---|",
  ];
  for (const r of report.rows.filter((x) => x.status !== "PASS")) md.push(`| ${r.item} | ${r.kind} | ${r.status} | ${r.detail.replace(/\|/g, "/")} |`);
  if (report.status === "PASS") md.push("| (all green) | | | |");
  md.push("");
  fs.writeFileSync(`${OUT_BASE}.md`, md.join("\n") + "\n", "utf8");

  if (flags.has("--json")) console.log(JSON.stringify(out, null, 2));
  else {
    console.log(`In-world proof gate: ${report.status} (PASS=${report.counts.PASS} RED=${report.counts.RED} SKIP=${report.counts.SKIP})`);
    for (const r of out.redRows.slice(0, 15)) console.log(`[RED] ${r.kind}:${r.item}: ${r.detail}`);
    if (out.redRows.length > 15) console.log(`... +${out.redRows.length - 15} more`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
