#!/usr/bin/env node
/*
 * PDV Deity-Chain Reverse-Trace Gate
 * -----------------------------------------------------------------------------
 * The audit the registry-driven gates could not be: it is driven by the live
 * CODE (the manager's actual reward-family wiring) and the live ESP ground truth
 * (via the MO2 Mutagen bridge), NOT by any spec/contract that can omit a lane.
 *
 * It asserts the two failure modes that slipped past 3 audit types + an
 * adversarial pass (2026-06-27, see PDV_DeityChainReverseTraceGate_Spec.md):
 *
 *   RESOLUTION   -- every reward SPEL and offer MESG the manager *references* in a
 *                   grant call resolves to a real, present record in Devotion.esp.
 *                   (Catches the Nord Nine Divines / Mara "declared-but-not-backed
 *                   -> binds to None -> no-op" class.)
 *   REACHABILITY -- every race whose reward family gates on an ACTIVE patron has an
 *                   organic activation path (offer-eligible, or its init sets the
 *                   patron). (Catches the Orc/Malacath "gate correct but no caller
 *                   ever satisfies it" class.)
 *
 * Read-only. Exits non-zero if any BLOCKER is found, so it can join the gate bundle.
 * Run `--self-test` to prove the checks actually catch planted gaps (no game/ESP needed).
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const MANAGER = path.join(DEVOTION_MOD, "Scripts", "Source", "PDV__ManagerQuest.psc");
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe",
);
const MAX_BUFFER = 128 * 1024 * 1024;

// Per-race wiring map. Small + explicit on purpose: 10 races, and naming the
// reward-family + init functions documents the architecture and avoids fragile
// guessing. Add a race here when a new one is built.
const RACES = [
  { race: "Nord", rewardFns: ["SyncNordRewards", "SyncNordRewardFamily"], initFn: "ApplyNordInitialChoice", offerFn: "IsNordOfferEligibleDeity" },
  { race: "Imperial", rewardFns: ["SyncImperialRewards", "SyncImperialRewardFamily"], initFn: "ApplyImperialInitialChoice", offerFn: "IsImperialOfferEligibleDeity" },
  { race: "Breton", rewardFns: ["SyncBretonRewards", "SyncBretonTraditionRewardFamily"], initFn: "ApplyBretonInitialChoice", offerFn: null },
  { race: "Altmer", rewardFns: ["SyncAltmerRewards", "SyncAltmerRewardFamily"], initFn: "ApplyAltmerInitialChoice", offerFn: "IsAltmerOfferEligibleDeity" },
  { race: "Bosmer", rewardFns: ["SyncBosmerRewards", "SyncBosmerPathRewardFamily"], initFn: "ApplyBosmerInitialChoice", offerFn: null },
  { race: "Dunmer", rewardFns: ["SyncDunmerRewards", "SyncDunmerRewardFamily"], initFn: "ApplyDunmerInitialChoice", offerFn: "IsDunmerOfferEligibleDeity" },
  { race: "Khajiit", rewardFns: ["SyncKhajiitEmphasisRewards", "SyncKhajiitEmphasisFamily"], initFn: "ApplyKhajiitInitialChoice", offerFn: null },
  { race: "Argonian", rewardFns: ["SyncArgonianRewards", "SyncArgonianRewardFamily"], initFn: "ApplyArgonianInitialChoice", offerFn: null },
  { race: "Orc", rewardFns: ["SyncOrcRewards", "SyncOrcRewardFamily"], initFn: "ApplyOrcInitialChoice", offerFn: "IsOrcOfferEligibleDeity" },
  { race: "Redguard", rewardFns: ["SyncRedguardRewards", "SyncRedguardRewardFamily"], initFn: "ApplyRedguardInitialChoice", offerFn: "IsRedguardOfferEligibleDeity" },
];

// Known by-design exemptions (`item::dim`). Empty for the two V1 checks; the
// documented 6 by-design items are neglect/fiction, not reward resolution.
const SUPPRESS = new Set([]);

function toPosix(p) { return p.replace(/\\/g, "/"); }

function bridge(request, timeoutMs = 90_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request), encoding: "utf8", timeout: timeoutMs,
    maxBuffer: MAX_BUFFER, windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  const payload = JSON.parse(stdout);
  if (!payload.success) throw new Error(payload.error || payload.message || "bridge call failed");
  return payload;
}

function scanEsp() {
  const resp = bridge({ command: "scan", plugins: [toPosix(PDV_ESP)] });
  const plugin = resp.plugins?.[0];
  if (!plugin) throw new Error("mutagen scan returned no plugin payload");
  const edids = new Set();
  for (const r of plugin.records || []) if (r.edid) edids.add(r.edid);
  return { edids, count: plugin.record_count ?? (plugin.records || []).length };
}

function fnBody(source, name) {
  const re = new RegExp(`(?:^|\\n)\\s*(?:\\w[\\w\\[\\]]*\\s+)?Function\\s+${name}\\s*\\([^)]*\\)([\\s\\S]*?)\\n\\s*EndFunction`, "i");
  const m = source.match(re);
  return m ? m[1] : null;
}

// Pure: given manager source + the set of editorids present in the ESP + the
// race config, return the list of findings. Injectable so --self-test can run it
// against a synthetic fixture with planted gaps.
function collectFindings(source, espEdids, racesConfig, suppress) {
  const findings = [];
  const add = (severity, dim, item, detail) => {
    if (suppress.has(`${item}::${dim}`)) return;
    findings.push({ severity, dim, item, detail });
  };

  // --- RESOLUTION: reward spells in *RewardFamily grant calls must exist -----
  const referenced = new Set();
  const familyCallRe = /Sync\w*RewardFamily\s*\([^)]*\)/g;
  let m;
  while ((m = familyCallRe.exec(source))) {
    for (const tok of m[0].match(/PDV_Bless_\w+/g) || []) referenced.add(tok);
  }
  for (const spell of [...referenced].sort()) {
    if (!espEdids.has(spell)) {
      add("BLOCKER", "resolution", spell,
        `reward spell referenced in a *RewardFamily grant call, but NO SPEL record '${spell}' exists in Devotion.esp -> the manager property binds to None and the blessing silently no-ops.`);
    }
  }

  // --- RESOLUTION: offer MESGs referenced in logic must exist ----------------
  const offerMsgs = new Set();
  for (const line of source.split(/\r?\n/)) {
    const t = line.trim();
    if (t.startsWith(";") || /^Message\s+Property\b/i.test(t)) continue;
    for (const tok of line.match(/PDV_Msg_\w+_Offer\b/g) || []) offerMsgs.add(tok);
  }
  for (const msg of [...offerMsgs].sort()) {
    if (!espEdids.has(msg)) {
      add("BLOCKER", "resolution", msg,
        `offer MESG referenced in manager logic, but NO MESG record '${msg}' exists in Devotion.esp -> the commitment offer pop-up resolves to None and cannot show.`);
    }
  }

  // --- REACHABILITY: active-patron-gated rewards need an activation path ------
  const usesFn = fnBody(source, "UsesFormalCommitmentOffersForDeity") || "";
  for (const cfg of racesConfig) {
    const combined = cfg.rewardFns.map((n) => fnBody(source, n)).filter(Boolean).join("\n");
    if (!combined) continue; // reward fn not found (race not built here) -> not a false blocker
    if (!/_activeDeity\s*==|PATRON_STATE_ACTIVE/.test(combined)) continue; // path/mode/emphasis-gated -> reachable via its track
    const offerEligible = cfg.offerFn ? usesFn.includes(cfg.offerFn) : false;
    const initBody = fnBody(source, cfg.initFn) || "";
    const initActivates = /SetActiveDeity\s*\(|SetBroadWorship\s*\(/.test(initBody);
    if (!offerEligible && !initActivates) {
      add("BLOCKER", "reachability", cfg.race,
        `reward family is gated on an active patron (_activeDeity / PATRON_STATE_ACTIVE) but ${cfg.race} is not offer-eligible (no ${cfg.offerFn || "offer fn"} in UsesFormalCommitmentOffersForDeity) and ${cfg.initFn} never calls SetActiveDeity/SetBroadWorship -> the reward ladder is unreachable in normal play.`);
    }
  }

  return { findings, referencedSpells: referenced.size, offerMsgs: offerMsgs.size };
}

function printFindings(findings) {
  for (const f of findings) {
    console.log(`[${f.severity}] ${f.dim}: ${f.item}`);
    console.log(`    ${f.detail}`);
  }
}

// --- self-test: prove the checks catch planted gaps (and don't false-flag) ---
function selfTest() {
  const synthSource = [
    "Function SyncFakeGoodRewardFamily(Actor playerRef)",
    "    SyncFakeGoodRewardFamily(playerRef, PDV_Bless_Fake_Present_T1, PDV_Bless_Fake_Missing_T1, \"Fake\")",
    "EndFunction",
    "String Function GetFakeOfferMessage(PDV_DeityBase deity)",
    "    return PDV_Msg_Fake_Missing_Offer",
    "EndFunction",
    "Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)",
    "    return IsReachableOfferEligibleDeity(deity)",
    "EndFunction",
    // Unreachable: active-gated rewards, not offer-eligible, init does not activate.
    "Function SyncDeadRewards(Actor playerRef)",
    "    Bool focusActive = GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == PDV_Dead",
    "EndFunction",
    "Function ApplyDeadInitialChoice(Int v, String reason)",
    "    StorageUtil.SetIntValue(None, \"X\", 1)",
    "EndFunction",
    // Reachable control A: active-gated but offer-eligible.
    "Function SyncReachableRewards(Actor playerRef)",
    "    Bool focusActive = _activeDeity == PDV_Reachable",
    "EndFunction",
    "Function ApplyReachableInitialChoice(Int v, String reason)",
    "    StorageUtil.SetIntValue(None, \"X\", 1)",
    "EndFunction",
    // Reachable control B: active-gated, not offer-eligible, but init activates.
    "Function SyncInnateRewards(Actor playerRef)",
    "    Bool focusActive = _activeDeity == PDV_Innate",
    "EndFunction",
    "Function ApplyInnateInitialChoice(Int v, String reason)",
    "    SetActiveDeity(PDV_Innate)",
    "EndFunction",
  ].join("\n");

  const synthEdids = new Set(["PDV_Bless_Fake_Present_T1"]); // Missing spell + missing offer MESG absent
  const synthRaces = [
    { race: "Dead", rewardFns: ["SyncDeadRewards"], initFn: "ApplyDeadInitialChoice", offerFn: "IsDeadOfferEligibleDeity" },
    { race: "Reachable", rewardFns: ["SyncReachableRewards"], initFn: "ApplyReachableInitialChoice", offerFn: "IsReachableOfferEligibleDeity" },
    { race: "Innate", rewardFns: ["SyncInnateRewards"], initFn: "ApplyInnateInitialChoice", offerFn: "IsInnateOfferEligibleDeity" },
  ];

  const { findings } = collectFindings(synthSource, synthEdids, synthRaces, new Set());
  const has = (dim, item) => findings.some((f) => f.dim === dim && f.item === item);
  const checks = [
    ["catches missing reward spell", has("resolution", "PDV_Bless_Fake_Missing_T1")],
    ["passes present reward spell", !has("resolution", "PDV_Bless_Fake_Present_T1")],
    ["catches missing offer MESG", has("resolution", "PDV_Msg_Fake_Missing_Offer")],
    ["catches unreachable active-gated race", has("reachability", "Dead")],
    ["no false-flag on offer-eligible race", !has("reachability", "Reachable")],
    ["no false-flag on init-activated race", !has("reachability", "Innate")],
  ];

  console.log("PDV Deity-Chain Gate -- self-test (synthetic fixture, no ESP):");
  let ok = true;
  for (const [label, pass] of checks) {
    console.log(`  ${pass ? "PASS" : "FAIL"}  ${label}`);
    if (!pass) ok = false;
  }
  console.log("");
  if (!ok) {
    console.log("RESULT: SELF-TEST FAILED -- the gate's checks are not behaving as specified.");
    process.exit(1);
  }
  console.log("RESULT: SELF-TEST PASSED -- the gate provably catches both failure modes and does not false-flag reachable races.");
  process.exit(0);
}

function main() {
  if (process.argv.includes("--self-test")) { selfTest(); return; }

  let esp;
  try {
    esp = scanEsp();
  } catch (err) {
    console.error(`pdv_deity_chain_audit: ESP scan failed via mutagen-bridge: ${err.message}`);
    console.error("  (Devotion.esp + mutagen-bridge.exe must be present; this gate needs live-ESP ground truth.)");
    process.exit(2);
  }

  const source = fs.readFileSync(MANAGER, "utf8");
  const { findings, referencedSpells, offerMsgs } = collectFindings(source, esp.edids, RACES, SUPPRESS);

  if (process.argv.includes("--json")) {
    const b = findings.filter((f) => f.severity === "BLOCKER");
    console.log(JSON.stringify({
      ok: b.length === 0,
      blockers: b.length,
      resolutionGaps: findings.filter((f) => f.dim === "resolution").length,
      reachabilityGaps: findings.filter((f) => f.dim === "reachability").length,
      espRecords: esp.count,
    }, null, 2));
    process.exit(b.length ? 1 : 0);
  }

  const activeGatedRaces = RACES.filter((c) => {
    const body = c.rewardFns.map((n) => fnBody(source, n)).filter(Boolean).join("\n");
    return /_activeDeity\s*==|PATRON_STATE_ACTIVE/.test(body);
  }).length;

  console.log("PDV Deity-Chain Reverse-Trace Gate");
  console.log(`  ESP records scanned: ${esp.count}`);
  console.log(`  RESOLUTION: ${referencedSpells} reward spells + ${offerMsgs} offer MESGs referenced`);
  console.log(`  REACHABILITY: ${activeGatedRaces} active-patron-gated races checked`);
  console.log("");

  const blockers = findings.filter((f) => f.severity === "BLOCKER");
  if (!findings.length) {
    console.log("RESULT: PASS -- 0 blockers. Every referenced reward spell + offer MESG resolves to a live record, and every active-patron-gated race has an activation path.");
    process.exit(0);
  }
  printFindings(findings);
  console.log("");
  console.log(`RESULT: FAIL -- ${blockers.length} blocker(s).`);
  process.exit(blockers.length ? 1 : 0);
}

main();
