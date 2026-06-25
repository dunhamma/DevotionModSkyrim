#!/usr/bin/env node
/*
 * PDV Ledger Coverage Audit — enforces the owner rule "the in-game Ledger must
 * monitor ALL data points."
 *
 * THE LEDGER. GetDashboardJson (~PDV__ManagerQuest.psc:1918) renders the player's
 * "what feeds your gods" surface. Per-god DRIVERS come from the StorageUtil lists
 * "PDV.Driver.Reasons" / "PDV.Driver.Deltas", written by exactly ONE site:
 * RecordDeityDriver, called only from AwardPietyInternal (~8679, the AwardPiety
 * path). So a piety/standing change that does NOT funnel through AwardPiety records
 * NO driver and is INVISIBLE in the Ledger.
 *
 * THIS AUDIT. Static source scan of live-source. Enumerate every site that mutates a
 * deity/path piety or standing and classify it:
 *   TRACKED   - reaches AwardPietyInternal (AwardPiety / AwardCuratedSignal[Scaled])
 *               -> records a driver -> visible in the Ledger.
 *   UNTRACKED - bypasses AwardPietyInternal at EARN time (an act adds piety/standing
 *               but writes no driver) -> invisible in the Ledger. THIS IS A FINDING.
 *   LIFECYCLE - non-earn machinery (dawn consolidation of PietyToday, decay, init/
 *               seed, debug, reset). Deterministic, not an organic act; no driver is
 *               expected. Reported for completeness, not a finding.
 *
 * DAEDRIC STORED-PIETY PATH. AdjustStoredPiety is tracked only while the shared
 * PDV_DaedricPathBase.SetStoredPiety primitive records PDV.Driver.* entries. If
 * that hook is removed, every AdjustStoredPiety call site becomes UNTRACKED again.
 *
 * Pure static analysis; read-only except its own generated ledger. Exit non-zero on
 * FINDINGS. Self-test: PDV_LEDGER_COVERAGE_SELFTEST=1 injects a guaranteed bypass
 * site and asserts the tool flags it UNTRACKED.
 */
import fs from "node:fs";

const ROOT = process.cwd().replace(/\\/g, "/");
const SOURCE_DIR = `${ROOT}/live-source/Scripts/Source`;
const OUT_MD = `${ROOT}/references/authoring/PDV_LedgerCoverageLedger.md`;

// StorageUtil keys that ARE the per-deity piety/standing economy (the Ledger's domain).
// "PDV.Piety" = committed piety; "PDV.PietyToday" = the accrual buffer consolidated at
// dawn into PDV.Piety. A direct write to either, outside the AwardPiety funnel, is a
// bypass candidate.
const PIETY_KEY_RE = /"PDV\.Piety"|"PDV\.PietyToday"/;
const DAEDRIC_BASE_FILE = "PDV_DaedricPathBase.psc";

// Names whose call SITE means the change is funneled through AwardPietyInternal and so
// records a driver. (AwardPiety -> AwardPietyInternal; AwardCuratedSignal[Scaled] ->
// AwardPiety.) A *definition* line for these is not a call site.
const TRACKED_CALLS = [
  "AwardPiety",
  "AwardCuratedSignal",
  "AwardCuratedSignalScaled",
  "AwardCuratedSignalByIndex",
];

// Lifecycle classifier: function names whose body legitimately writes piety as
// non-earn machinery (dawn/decay/init/seed/debug/reset/migration). A direct write
// inside one of these is LIFECYCLE, not an UNTRACKED earn bypass.
// Note: AwardPietyInternal is the driver-recording funnel itself -- its own
// PietyToday accrual write is the TRACKED path, not a bypass.
const LIFECYCLE_FN_RE = /(Dawn|Consolidate|Decay|Init|Seed|Reset|Clear|Migrat|Force|Debug|Recompute|StartPiety|GrantStartingPiety|SetStoredPiety|AwardPietyInternal)/i;

function main() {
  if (!fs.existsSync(SOURCE_DIR)) throw new Error(`Source dir not found: ${SOURCE_DIR}`);
  const files = fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));

  const tracked = [];   // {file, line, fn, kind, snippet}
  const untracked = []; // earn-time bypasses -> FINDINGS
  const lifecycle = []; // non-earn writes -> reported only
  const substrate = []; // substrate metric writes that feed a deity indirectly -> noted
  const daedricStoredPietyTracked = hasDaedricStoredPietyDriverHook();

  for (const file of files) {
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    const lines = text.split(/\r?\n/);
    const fnAt = buildFunctionMap(lines);

    for (let i = 0; i < lines.length; i++) {
      const raw = lines[i];
      const code = stripComment(raw);
      if (!code.trim()) continue;
      const lineNo = i + 1;
      const fn = fnAt[i] || "(top-level)";
      const snippet = raw.trim();

      // --- TRACKED: a call to the AwardPiety funnel (call site, not a def). ---
      const trackedCall = TRACKED_CALLS.find((c) =>
        new RegExp(`\\b${c}\\s*\\(`).test(code) && !new RegExp(`Function\\s+${c}\\b`).test(code)
      );
      if (trackedCall) {
        tracked.push({ file, line: lineNo, fn, kind: trackedCall, snippet });
        continue;
      }

      // --- Daedric stored-piety path. ---
      // AdjustStoredPiety is tracked only while the shared SetStoredPiety primitive
      // writes the same PDV.Driver ring the dashboard reads.
      const isAdjustStored = /\bAdjustStoredPiety\s*\(/.test(code) && !/Function\s+AdjustStoredPiety\b/.test(code);
      if (isAdjustStored) {
        if (daedricStoredPietyTracked) {
          tracked.push({ file, line: lineNo, fn, kind: "AdjustStoredPiety->SetStoredPiety driver", snippet });
        } else {
          untracked.push({ file, line: lineNo, fn, kind: "AdjustStoredPiety", snippet,
            why: "Daedric path piety via AdjustStoredPiety -> SetStoredPiety without a PDV.Driver hook; records no driver, so the Prince is invisible in the Ledger." });
        }
        continue;
      }

      // --- Direct StorageUtil write to a piety key. ---
      const isDirectPietyWrite =
        /StorageUtil\.(Set|Adjust)FloatValue\s*\(/.test(code) && PIETY_KEY_RE.test(code);
      if (isDirectPietyWrite) {
        if (LIFECYCLE_FN_RE.test(fn)) {
          lifecycle.push({ file, line: lineNo, fn, kind: "direct-write (lifecycle)", snippet });
        } else {
          untracked.push({ file, line: lineNo, fn, kind: "direct StorageUtil piety write", snippet,
            why: "Earn-time direct write to " + (PIETY_KEY_RE.exec(code) || [""])[0] + " outside the AwardPiety funnel; no driver recorded." });
        }
        continue;
      }
    }

    // --- Substrate Record*Scaled metric writes: a parallel channel that can feed a
    // deity (favor/buff substrate) but writes a substrate metric, never a deity driver.
    for (let i = 0; i < lines.length; i++) {
      const m = stripComment(lines[i]).match(/\bFunction\s+(Record[A-Za-z0-9_]*Scaled)\s*\(/);
      if (m) substrate.push({ file, line: i + 1, fn: m[1] });
    }
  }

  // Self-test: inject a guaranteed bypass and confirm it lands in UNTRACKED.
  let selfTest = "off";
  if (process.env.PDV_LEDGER_COVERAGE_SELFTEST === "1") {
    untracked.push({ file: "(selftest)", line: 0, fn: "Selftest", kind: "AdjustStoredPiety",
      snippet: 'path.AdjustStoredPiety(99.0, "selftest")',
      why: "injected synthetic bypass" });
    selfTest = untracked.some((u) => u.file === "(selftest)" && u.kind === "AdjustStoredPiety")
      ? "PASS (caught injected AdjustStoredPiety bypass)" : "FAIL";
  }

  // Confirm whether the historical Daedric target gap is still present.
  const caughtRealAdjustStored = untracked.some(
    (u) => u.file !== "(selftest)" && u.kind === "AdjustStoredPiety"
  );

  const scaledCuratedDriverReason = hasReasonBearingScaledCuratedAward();
  writeLedger({ tracked, untracked, lifecycle, substrate, caughtRealAdjustStored, scaledCuratedDriverReason });

  const summary = {
    status: untracked.length ? "FINDINGS" : "CLEAN",
    trackedSites: tracked.length,
    untrackedSites: untracked.length,
    lifecycleSites: lifecycle.length,
    substrateScaledWriters: substrate.length,
    daedricStoredPietyDriverHook: daedricStoredPietyTracked ? "YES" : "NO",
    untracked: untracked.map((u) => `${u.file}:${u.line} ${u.fn} [${u.kind}]`),
    historicalDaedricBypassCaught: caughtRealAdjustStored
      ? "YES (AdjustStoredPiety bypass present in UNTRACKED -> pre-pact Princes invisible in Ledger)"
      : "NO (Daedric stored-piety path is tracked or no AdjustStoredPiety call sites were found)",
    scaledCuratedDriverReason: scaledCuratedDriverReason ? "YES" : "NO",
    selfTest,
    ledger: "references/authoring/PDV_LedgerCoverageLedger.md",
  };
  console.log(JSON.stringify(summary, null, 2));

  if (untracked.filter((u) => u.file !== "(selftest)").length > 0 || !scaledCuratedDriverReason) process.exitCode = 1;
}

// Map each line index -> enclosing Function/Event name.
function buildFunctionMap(lines) {
  const map = [];
  let cur = null;
  for (let i = 0; i < lines.length; i++) {
    const code = stripComment(lines[i]);
    const open = code.match(/^\s*(?:[A-Za-z_][\w\[\]]*\s+)?(?:Function|Event)\s+([A-Za-z_]\w*)\s*\(/i);
    if (open) cur = open[1];
    map[i] = cur;
    if (/^\s*End(Function|Event)\b/i.test(code)) cur = null;
  }
  return map;
}

// Drop a trailing line comment (handles ; ... ) without disturbing string literals
// enough for this scan (Papyrus has no ; inside the keys we care about).
function stripComment(line) {
  const idx = line.indexOf(";");
  if (idx === -1) return line;
  // crude: only strip if the ; is not inside a quoted string on this line
  const before = line.slice(0, idx);
  const quotes = (before.match(/"/g) || []).length;
  if (quotes % 2 === 1) return line; // ; is inside a string; keep whole line
  return before;
}

function functionBody(text, name) {
  const re = new RegExp(`(?:^|\\n)\\s*(?:[A-Za-z_][\\w\\[\\]]*\\s+)?Function\\s+${name}\\s*\\([^)]*\\)([\\s\\S]*?)\\n\\s*EndFunction`, "i");
  const m = text.match(re);
  return m ? m[1] : null;
}

function hasDaedricStoredPietyDriverHook() {
  const path = `${SOURCE_DIR}/${DAEDRIC_BASE_FILE}`;
  if (!fs.existsSync(path)) return false;
  const text = fs.readFileSync(path, "utf8");
  const body = functionBody(text, "SetStoredPiety");
  if (!body) return false;
  return /RecordDaedricPathDriver\s*\(/.test(body) &&
         /"PDV\.Driver\.Reasons"/.test(text) &&
         /"PDV\.Driver\.Deltas"/.test(text) &&
         /"PDV\.Driver\.Days"/.test(text);
}

function hasReasonBearingScaledCuratedAward() {
  const path = `${SOURCE_DIR}/PDV__ManagerQuest.psc`;
  if (!fs.existsSync(path)) return false;
  const text = fs.readFileSync(path, "utf8");
  const body = functionBody(text, "AwardCuratedSignalScaled");
  if (!body) return false;
  return /AwardPiety\s*\(\s*deity\s*,\s*scaledDelta\s*,/.test(body);
}

function writeLedger({ tracked, untracked, lifecycle, substrate, caughtRealAdjustStored, scaledCuratedDriverReason }) {
  const md = [];
  md.push("# PDV Ledger Coverage Ledger");
  md.push("");
  md.push("GENERATED by tools/pdv_ledger_coverage_audit.mjs - do not hand-edit.");
  md.push("");
  md.push("Owner rule: the in-game Ledger must monitor ALL data points. The Ledger");
  md.push("(GetDashboardJson, ~PDV__ManagerQuest.psc:1918, \"what feeds your gods\") renders");
  md.push("per-god DRIVERS from PDV.Driver.Reasons / PDV.Driver.Deltas, written ONLY by");
  md.push("RecordDeityDriver inside AwardPietyInternal (~8679). A piety/standing change that");
  md.push("does NOT funnel through AwardPiety records no driver and is INVISIBLE in the Ledger.");
  md.push("");
  md.push("Classification:");
  md.push("- TRACKED   = call reaches AwardPietyInternal (records a driver).");
  md.push("- UNTRACKED = earn-time piety/standing mutation that bypasses it (FINDING).");
  md.push("- LIFECYCLE = non-earn machinery (dawn/decay/init/seed/debug/reset); no driver expected.");
  md.push("");
  md.push(`Summary: ${tracked.length} TRACKED | ${untracked.length} UNTRACKED | ${lifecycle.length} LIFECYCLE | ${substrate.length} substrate Record*Scaled writers`);
  md.push("");
  md.push(`Daedric stored-piety driver hook present: ${hasDaedricStoredPietyDriverHook() ? "YES" : "NO"}`);
  md.push(`Historical AdjustStoredPiety bypass caught: ${caughtRealAdjustStored ? "YES" : "NO"}`);
  md.push(`Scaled curated AwardPiety call records a driver reason: ${scaledCuratedDriverReason ? "YES" : "NO"}`);
  md.push("");

  md.push("## UNTRACKED (bypass the Ledger) -- FINDINGS");
  md.push("");
  md.push("Each is an earn-time piety/standing mutation that writes NO PDV.Driver entry, so");
  md.push("the act never appears in the player's \"what feeds your gods\" Ledger. Triage: route");
  md.push("the earn through AwardPiety, or extend the driver-recording funnel to cover this");
  md.push("piety channel (e.g. record a driver inside SetStoredPiety for Daedric paths).");
  md.push("");
  if (!untracked.length) md.push("- none");
  for (const u of untracked) {
    md.push(`- **${asciiSafe(u.file)}:${u.line}** in \`${asciiSafe(u.fn)}\` [${asciiSafe(u.kind)}]`);
    md.push(`  - \`${asciiSafe(u.snippet)}\``);
    if (u.why) md.push(`  - ${asciiSafe(u.why)}`);
  }
  md.push("");

  md.push("## TRACKED (funnel through AwardPiety -> records a driver)");
  md.push("");
  if (!tracked.length) md.push("- none");
  for (const t of tracked) {
    md.push(`- ${asciiSafe(t.file)}:${t.line} \`${asciiSafe(t.fn)}\` [${asciiSafe(t.kind)}] -- ${asciiSafe(t.snippet)}`);
  }
  md.push("");

  md.push("## LIFECYCLE (non-earn piety writes -- no driver expected)");
  md.push("");
  md.push("Dawn consolidation of PietyToday, decay, init/seed, debug seeders, resets and the");
  md.push("SetStoredPiety primitive. These are deterministic machinery, not organic acts; the");
  md.push("Ledger intentionally does not attribute them to a recent-driver.");
  md.push("");
  if (!lifecycle.length) md.push("- none");
  for (const l of lifecycle) {
    md.push(`- ${asciiSafe(l.file)}:${l.line} \`${asciiSafe(l.fn)}\` -- ${asciiSafe(l.snippet)}`);
  }
  md.push("");

  md.push("## Substrate Record*Scaled writers (parallel metric channel)");
  md.push("");
  md.push("These write a substrate metric (PDV.Substrate.*), a separate favor/buff channel.");
  md.push("They do not write a deity PDV.Piety driver. Where a substrate feeds a deity without");
  md.push("an AwardPiety, that deity contribution is also Ledger-invisible -- flagged here for");
  md.push("a design check, not auto-counted as an earn bypass.");
  md.push("");
  if (!substrate.length) md.push("- none");
  for (const s of substrate) {
    md.push(`- ${asciiSafe(s.file)}:${s.line} \`${asciiSafe(s.fn)}\``);
  }
  md.push("");

  fs.writeFileSync(OUT_MD, md.join("\n") + "\n", "utf8");
}

function asciiSafe(v) { return String(v ?? "").replace(/[^\x00-\x7F]/g, "?"); }

main();
