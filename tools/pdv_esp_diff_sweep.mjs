#!/usr/bin/env node
// pdv_esp_diff_sweep.mjs -- answer "what changed in Devotion.esp" between a snapshot and live
// (or between two snapshots), by diffing the ESP files themselves.
//
// WHY THIS REPLACED RECORD FINGERPRINTING
// ---------------------------------------
// An earlier approach captured a "fingerprint" of every record's field leaves at snapshot time and
// diffed the fingerprints. It existed because housecarl_diff_record was believed to miss ADDED list
// elements (new FormList members, new VMAD script properties) -- i.e. most PDV record work.
//
// That was reproduced-disproven on 2026-08-05. The real cause was tools/lib/pdv_housecarl_stdio.mjs
// being pinned to a STALE houseCARL build that does not have housecarl_diff_record at all. Against
// the current build:
//   - a FormList that gained a member diffs as
//     "Items: 32 vs Devotion.esp 33 item(s) -- only in Devotion.esp: [32] 07164C:Devotion.esp"
//   - a quest whose VMAD went 4 -> 14 script properties reports the container asymmetry unscoped,
//     and with fields=["VirtualMachineAdapter.Scripts[0].Properties"] enumerates all 10 additions
//     by name and value.
//
// So no capture step is needed. This sweep works on the ~100 ESP copies ALREADY in the snapshot
// store, back to 2026-06-20 -- including every snapshot taken before any of this was written, which
// the fingerprint approach could never do (it could not be back-filled).
//
// TWO-TIER BY DESIGN: an unscoped diff DETECTS and localizes a change cheaply; a fields=-scoped
// re-diff ENUMERATES the leaves, and only for the records that actually moved.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { openHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--expect-clean", "--from", "--help", "--json", "--scope", "--to"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_esp_diff_sweep" });

const TOOLS_DIR = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(TOOLS_DIR, "..");
const STORE = path.join(ROOT, "generated", "live-devotion-backups");
const PLUGIN = "Devotion.esp";
const VMAD_PATH = "VirtualMachineAdapter.Scripts[0].Properties";

const args = process.argv.slice(2);
const flag = (n) => args.includes(n);
const opt = (n) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : null; };
const JSON_OUT = flag("--json");
const say = (m) => { if (!JSON_OUT) console.log(m); };
const die = (m) => { console.error(`ERROR: ${m}`); process.exit(2); };

if (flag("--help") || args.length === 0) {
  console.log(`Usage:
  node tools/pdv_esp_diff_sweep.mjs --from <snapshot|path> [--to <snapshot|path|live>] [options]

  --from    snapshot name under generated/live-devotion-backups/, or a full path to a Devotion.esp
  --to      same, or "live" (default) for the active load order
  --scope   vmad | flst | both (default) | all
              vmad = the ~183 records carrying a VirtualMachineAdapter
              flst = the ~97 FormLists
              both = vmad + flst, the records PDV work actually lands on
              all  = every record defined in ${PLUGIN} (~1950; much slower)
  --json          machine-readable output
  --expect-clean  exit 1 if ANY difference is found (gate mode; verdict is the EXIT CODE)

Exit codes: 0 = swept OK   1 = differences found under --expect-clean   2 = tool error

KNOWN BLIND SPOT: records are enumerated from the LIVE load order, because houseCARL cannot scope a
query to an off-load-order file. A record that existed in --from and was DELETED since is therefore
not enumerated and will not be reported. Records ADDED since --from are reported normally.`);
  process.exit(0);
}

function resolveEsp(which, value) {
  if (!value) die(`${which} is required`);
  if (value === "live") return { label: "live", plugin: PLUGIN, isLive: true };
  const direct = path.isAbsolute(value) ? value : path.join(STORE, value, PLUGIN);
  const asPath = value.toLowerCase().endsWith(".esp") ? value : direct;
  if (!fs.existsSync(asPath)) {
    die(`${which}: no ESP at ${asPath}\n  (snapshot names are directories under ${STORE})`);
  }
  return { label: value, plugin: asPath, isLive: false };
}

const from = resolveEsp("--from", opt("--from"));
const to = resolveEsp("--to", opt("--to") ?? "live");
const scope = (opt("--scope") ?? "both").toLowerCase();
if (!["vmad", "flst", "both", "all"].includes(scope)) die(`--scope must be vmad|flst|both|all, got "${scope}"`);
if (!from.isLive && !to.isLive && path.resolve(from.plugin) === path.resolve(to.plugin)) {
  die("--from and --to resolve to the same file");
}

const session = openHousecarl({ timeoutMs: 180_000 });

async function callJson(tool, payload) {
  const res = await session.call(tool, { ...payload, format: "json" }, { timeoutMs: 180_000 });
  const text = extractHousecarlText(res);
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`${tool} did not return JSON. Head of response:\n${text.slice(0, 300)}`);
  }
}

async function enumerate() {
  const queries = [];
  if (scope === "vmad" || scope === "both") queries.push({ where: ["VirtualMachineAdapter exists"], tag: "vmad" });
  if (scope === "flst" || scope === "both") queries.push({ type: "FLST", tag: "flst" });
  if (scope === "all") queries.push({ tag: "all" });

  const seen = new Map();
  for (const q of queries) {
    const { tag, ...filters } = q;
    const doc = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], defined_in: true, limit: 5000, max_chars: 4_000_000, ...filters,
    });
    // A capped enumeration would silently shrink the sweep, and a sweep that skipped records reads
    // as "nothing changed" -- exactly the false-clean this tool exists to avoid.
    if (doc.capped || doc.truncated) {
      throw new Error(`enumeration for scope "${tag}" was CAPPED/TRUNCATED (total=${doc.total}, rendered=${doc.rendered}); a partial sweep would read as false-clean. Raise limit=/max_chars=.`);
    }
    for (const m of doc.matches ?? []) {
      if (!seen.has(m.formid)) seen.set(m.formid, { formid: m.formid, type: m.type, editorid: m.editorid ?? "" });
    }
    say(`  scope ${tag}: ${doc.total} record(s)`);
  }
  return [...seen.values()];
}

async function diffOne(formid, fields) {
  const payload = { formid, plugin_a: from.plugin, plugin_b: to.plugin };
  if (fields) payload.fields = fields;
  try {
    return await callJson("housecarl_diff_record", payload);
  } catch (error) {
    return { formid, error: error.message };
  }
}

function classifyAbsence(message) {
  // houseCARL names the side that lacks the record, which is the added/removed signal.
  if (/plugin_a:/i.test(message)) return "added";     // absent in --from, present in --to
  if (/plugin_b:/i.test(message)) return "removed";   // present in --from, absent in --to
  return null;
}

const report = {
  from: from.label, to: to.label, scope,
  addedRecords: [], removedRecords: [], changed: [], errors: [], warnings: [],
};

try {
  say(`sweep ${from.label} -> ${to.label}  (scope: ${scope})`);
  say(`  a: ${from.plugin}`);
  say(`  b: ${to.plugin}`);
  const records = await enumerate();
  say(`enumerated ${records.length} record(s); diffing...`);

  let done = 0;
  for (const rec of records) {
    done += 1;
    if (done % 50 === 0) say(`  ...${done}/${records.length}`);

    const d = await diffOne(rec.formid);
    if (d.error) {
      const kind = classifyAbsence(d.error);
      if (kind === "added") report.addedRecords.push(rec);
      else if (kind === "removed") report.removedRecords.push(rec);
      else report.errors.push({ ...rec, error: d.error });
      continue;
    }
    // Never let a truncated read pass as "identical".
    if (d.truncated) {
      report.warnings.push(`${rec.formid} ${rec.editorid}: diff was TRUNCATED; treat as UNKNOWN, not identical`);
    }
    if (!d.delta_count) continue;

    const entry = { ...rec, deltas: d.deltas ?? [], deep: null };

    // Tier 2: a VMAD delta reported at container level ("[list: 4 item(s)]" vs "[list: 14 item(s)]")
    // says THAT the script properties moved but not WHICH. Re-read that subtree scoped to enumerate.
    if (entry.deltas.some((s) => s.includes("VirtualMachineAdapter"))) {
      const deep = await diffOne(rec.formid, [VMAD_PATH]);
      if (deep.error) {
        report.warnings.push(`${rec.formid}: deep VMAD pass failed: ${deep.error}`);
      } else if (!deep.delta_count && !deep.agreed_count) {
        // A fields= path matching NOTHING returns complete:true, delta_count:0 with no error --
        // a live false-identical hazard. agreed_count 0 alongside it is the only tell.
        report.warnings.push(`${rec.formid}: deep path "${VMAD_PATH}" matched nothing (0 deltas, 0 agreed) -- NOT proof of identity`);
      } else {
        entry.deep = deep.deltas ?? [];
      }
    }
    report.changed.push(entry);
  }
} catch (error) {
  session.close();
  die(error.message);
}
session.close();

if (JSON_OUT) {
  console.log(JSON.stringify(report, null, 2));
} else {
  say("");
  say(`records: +${report.addedRecords.length} added / -${report.removedRecords.length} removed / ${report.changed.length} changed`);
  for (const r of report.addedRecords) say(`  + RECORD ${r.formid} ${r.type} ${r.editorid}`);
  for (const r of report.removedRecords) say(`  - RECORD ${r.formid} ${r.type} ${r.editorid}`);
  for (const c of report.changed) {
    say(`  ~ ${c.formid} ${c.type} ${c.editorid}`);
    for (const line of c.deltas) say(`      ${line}`);
    if (c.deep?.length) {
      say(`      -- deep (${VMAD_PATH}) --`);
      for (const line of c.deep) say(`      ${line}`);
    }
  }
  for (const w of report.warnings) say(`  WARNING: ${w}`);
  for (const e of report.errors) say(`  ERROR: ${e.formid} ${e.editorid}: ${e.error}`);
  if (!report.addedRecords.length && !report.removedRecords.length && !report.changed.length) {
    say("  no differences in swept scope");
  }
  say("");
  say(`NOTE: enumerated from the LIVE load order; a record DELETED since "${from.label}" cannot be`);
  say("      enumerated and is not reported. Added and changed records are reported normally.");
}

const differences = report.addedRecords.length + report.removedRecords.length + report.changed.length;
if (report.errors.length) process.exitCode = 2;
else if (flag("--expect-clean") && differences) process.exitCode = 1;
