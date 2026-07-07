#!/usr/bin/env node
/*
 * PDV Final-World Placement Gate (C-PLACEMENT-FINAL).
 *
 * The 1.0 contract requires every player-reachable trigger reference placed
 * outside QASmoke/dev cells. This gate is manifest-driven and fail-closed in
 * BOTH directions:
 *
 *   - every PDV_REFR_* placed reference in Devotion.esp must have a manifest
 *     entry (unlisted ref -> RED)
 *   - every manifest entry must still exist in the ESP (stale entry -> RED)
 *   - entries gate by status: "placed" (with recorded worldspace/cell
 *     readback evidence) and "dev-only"/"not-applicable" (with reason) pass;
 *     "qasmoke-only" is the honest pending state and stays RED
 *
 * The mutagen bridge scan proves EDID existence but not parent cells; the
 * per-entry cell evidence is recorded from houseCARL readback (MO2 MCP up)
 * when placement work happens. Do not flip an entry to "placed" without that
 * readback note - the pdv-proof-boundary rules apply.
 *
 * Flags:
 *   --seed       create/merge the manifest from the current ESP REFR set
 *                (new entries default to status "qasmoke-only", intended TBD)
 *   --json       JSON report
 *   --self-test  fixture test
 *
 * Emits PDV_FinalPlacementLedger.json/.md. Exit 0 iff PASS.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = "references/authoring";
const MANIFEST = path.join(ROOT, AUTH, "PDV_FinalPlacementManifest.json");
const OUT_BASE = path.join(ROOT, AUTH, "PDV_FinalPlacementLedger");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const PDV_ESP = path.join(ANVIL_ROOT, "mods", "Devotion", "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe");

const flags = new Set(process.argv.slice(2));
const ALLOWED_STATUSES = ["qasmoke-only", "placed", "dev-only", "not-applicable"];

function scanRefs() {
  if (!fs.existsSync(MUTAGEN_BRIDGE) || !fs.existsSync(PDV_ESP)) return { down: true, reason: "bridge or ESP absent" };
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

export function evaluate(manifest, espRefs) {
  const rows = [];
  const entries = manifest.refs ?? {};
  const espSet = new Set(espRefs.map((r) => r.edid));

  for (const ref of espRefs) {
    if (!entries[ref.edid]) {
      rows.push({ edid: ref.edid, status: "RED", detail: "placed ESP reference has no manifest entry (fail-closed; run --seed then classify it)" });
    }
  }
  for (const [edid, entry] of Object.entries(entries)) {
    if (!espSet.has(edid)) {
      rows.push({ edid, status: "RED", detail: "manifest entry no longer exists in Devotion.esp (stale manifest)" });
      continue;
    }
    if (!ALLOWED_STATUSES.includes(entry.status)) {
      rows.push({ edid, status: "RED", detail: `unknown status '${entry.status}' (fail-closed)` });
    } else if (entry.status === "qasmoke-only") {
      rows.push({ edid, status: "RED", detail: `pending final placement (intended: ${entry.intended?.cell ?? "TBD"})` });
    } else if (entry.status === "placed") {
      const ok = entry.observed?.cell && entry.observed?.date && entry.observed?.evidence;
      rows.push(ok
        ? { edid, status: "PASS", detail: `placed in ${entry.observed.cell} (${entry.observed.date})` }
        : { edid, status: "RED", detail: "status 'placed' without observed cell/date/evidence readback (proof-boundary: record the houseCARL readback first)" });
    } else {
      const ok = (entry.reason ?? "").length >= 8;
      rows.push(ok
        ? { edid, status: "PASS", detail: `${entry.status}: ${entry.reason}` }
        : { edid, status: "RED", detail: `${entry.status} requires a real reason` });
    }
  }

  const counts = { PASS: 0, RED: 0 };
  for (const r of rows) counts[r.status]++;
  return { status: counts.RED ? "FAIL" : "PASS", counts, rows };
}

function seed(espRefs) {
  let manifest = {
    schema: "pdv.final-placement-manifest.v1",
    purpose: "Per-reference final-world placement tracker for C-PLACEMENT-FINAL. Fill intended worldspace/cell per ref (Wave-4 final placement contracts), place via CK/houseCARL, then record observed readback and flip status to 'placed'. Debug-only senders get status 'dev-only' with a reason.",
    rules: { allowedStatuses: ALLOWED_STATUSES, placedRequires: ["observed.cell", "observed.date", "observed.evidence"] },
    refs: {},
  };
  if (fs.existsSync(MANIFEST)) manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
  let added = 0;
  for (const ref of espRefs) {
    if (manifest.refs[ref.edid]) continue;
    manifest.refs[ref.edid] = {
      status: "qasmoke-only",
      formid: ref.formid,
      lane: ref.edid.replace(/^PDV_REFR_/, "").replace(/Signal$/, ""),
      intended: { worldspace: "TBD", cell: "TBD" },
      observed: null,
      reason: "",
    };
    added++;
  }
  manifest.updated = new Date().toISOString().slice(0, 10);
  fs.writeFileSync(MANIFEST, JSON.stringify(manifest, null, 2) + "\n", "utf8");
  return { added, total: Object.keys(manifest.refs).length };
}

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  const esp = [{ edid: "PDV_REFR_A", formid: "x:1" }, { edid: "PDV_REFR_B", formid: "x:2" }, { edid: "PDV_REFR_ORPHAN", formid: "x:3" }];
  const manifest = { refs: {
    PDV_REFR_A: { status: "placed", observed: { cell: "WhiterunTemple", date: "2026-07-07", evidence: "houseCARL readback" } },
    PDV_REFR_B: { status: "qasmoke-only", intended: { cell: "TBD" } },
    PDV_REFR_STALE: { status: "placed", observed: { cell: "X", date: "d", evidence: "e" } },
    PDV_REFR_BADPLACED_NOT_IN: undefined,
  } };
  delete manifest.refs.PDV_REFR_BADPLACED_NOT_IN;
  const rep = evaluate(manifest, esp);
  const byId = Object.fromEntries(rep.rows.map((r) => [r.edid + ":" + r.detail.slice(0, 10), r]));
  expect("placed with readback PASS", rep.rows.some((r) => r.edid === "PDV_REFR_A" && r.status === "PASS"));
  expect("qasmoke-only RED", rep.rows.some((r) => r.edid === "PDV_REFR_B" && r.status === "RED"));
  expect("unlisted ESP ref RED", rep.rows.some((r) => r.edid === "PDV_REFR_ORPHAN" && r.status === "RED"));
  expect("stale manifest entry RED", rep.rows.some((r) => r.edid === "PDV_REFR_STALE" && r.status === "RED"));
  expect("overall FAIL", rep.status === "FAIL");
  const rep2 = evaluate({ refs: { PDV_REFR_A: manifest.refs.PDV_REFR_A } }, [esp[0]]);
  expect("all placed -> PASS", rep2.status === "PASS");
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

function main() {
  const scan = scanRefs();
  if (scan.down) {
    const out = { schema: "pdv.final-placement-ledger.v1", status: "SKIP", reason: `bridge down: ${scan.reason} - SKIP, never PASS` };
    fs.writeFileSync(`${OUT_BASE}.json`, JSON.stringify(out, null, 2) + "\n", "utf8");
    console.log(`Placement gate: SKIP (${scan.reason})`);
    process.exitCode = 1;
    return;
  }
  if (flags.has("--seed")) {
    const r = seed(scan.refs);
    console.log(`Manifest seeded: +${r.added} new refs, ${r.total} total.`);
  }
  if (!fs.existsSync(MANIFEST)) {
    console.error("Manifest missing; run with --seed first.");
    process.exitCode = 1;
    return;
  }
  const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
  const report = evaluate(manifest, scan.refs);
  const out = { schema: "pdv.final-placement-ledger.v1", status: report.status, counts: report.counts, redRows: report.rows.filter((r) => r.status === "RED") };
  fs.writeFileSync(`${OUT_BASE}.json`, JSON.stringify(out, null, 2) + "\n", "utf8");

  const md = [
    "# PDV Final Placement Ledger", "",
    "GENERATED by tools/pdv_placement_gate.mjs - do not hand-edit.", "",
    `Overall: **${report.status}** (PASS=${report.counts.PASS} RED=${report.counts.RED} of ${report.rows.length} refs).`, "",
    "| Ref | Status | Detail |", "|---|---|---|",
  ];
  for (const r of report.rows) md.push(`| ${r.edid} | ${r.status} | ${r.detail.replace(/\|/g, "/")} |`);
  md.push("");
  fs.writeFileSync(`${OUT_BASE}.md`, md.join("\n") + "\n", "utf8");

  if (flags.has("--json")) console.log(JSON.stringify(out, null, 2));
  else {
    console.log(`Placement gate: ${report.status} (PASS=${report.counts.PASS} RED=${report.counts.RED})`);
    for (const r of out.redRows.slice(0, 10)) console.log(`[RED] ${r.edid}: ${r.detail}`);
    if (out.redRows.length > 10) console.log(`... +${out.redRows.length - 10} more in ${path.relative(ROOT, OUT_BASE)}.md`);
  }
  process.exitCode = report.status === "PASS" ? 0 : 1;
}

if (flags.has("--self-test")) selfTest();
else main();
