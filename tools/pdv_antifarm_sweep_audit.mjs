#!/usr/bin/env node
/*
 * PDV Anti-Farm Sweep Audit -- enforces the anti-farm doctrine: every signal
 * handler that awards POSITIVE (gain) PIETY (AwardPiety / AwardCuratedSignal[Scaled])
 * must have an anti-farm gate on the PULSE -- a Consume* helper
 * (ConsumeOncePerDaySignal ~hard once/day, ConsumeDailyRepeatMultiplier ~0.7^n
 * soft) OR a per-handler StorageUtil day-key guard (e.g. encode day+1) OR a
 * single-fire once-ever flag / StateTrack lockout -- on the path to the award.
 *
 * Why GAIN-only is the gate: the anti-farm exploit is repeating a piety-EARNING
 * act for unbounded gain. A handler that only awards a NEGATIVE delta (an
 * anti-creed penalty, oath-break, Lorkhan-pressure cost) cannot be "farmed" for
 * gain -- repeating it only costs the player. Penalty-only uncapped handlers are
 * still reported (as friction-pacing review) but do not fail the build.
 *
 * The audit is caller-aware: the cap commonly lives in the OUTER handler that
 * computes the multiplier (e.g. HandleOrcStrongholdForge -> ConsumeDailyRepeatMultiplier)
 * and then calls a thin emit-wrapper (AwardOrcStrongholdForgeSignal) that itself
 * carries no cap. Such a wrapper is CAPPED-by-caller when EVERY function that
 * invokes it is itself capped.
 *
 * Pure static source scan (deterministic); read-only except its own ledger.
 * Conservative by design (inherent single-fire one-shots are allowlisted /
 * detected) to avoid false UNCAPPED. Mirrors tools/pdv_specced_minus_audit.mjs
 * conventions (node ESM, reads live-source, prints JSON status, writes a
 * generated ledger md, exit non-zero on FINDINGS).
 *
 * Self-test: PDV_ANTIFARM_SELFTEST=1 injects a synthetic uncapped GAIN handler
 * and confirms HandleNordSleepEvents reads as CAPPED.
 */
import fs from "node:fs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_antifarm_sweep_audit" });

const ROOT = process.cwd().replace(/\\/g, "/");
const SOURCE_DIR = `${ROOT}/live-source/Scripts/Source`;
const MANAGER_PATH = `${SOURCE_DIR}/PDV__ManagerQuest.psc`;
const OUT_MD = `${ROOT}/references/authoring/PDV_AntiFarmSweepLedger.md`;

// Pure piety-dispatch primitives: these ARE the award path, never "handlers",
// never need their own cap (the cap is per-signal, upstream). They define the
// leaf award boundary for the call-tree walk.
const AWARD_PRIMITIVES = new Set([
  "AwardPiety",
  "AwardPietyInternal",
  "AwardCuratedSignal",
  "AwardCuratedSignalScaled",
  "AwardCuratedSignalByIndex",
]);

// Handler-shaped names per the doctrine.
const HANDLER_RE = /^(Handle[A-Za-z0-9_]+|Record[A-Za-z0-9_]*Scaled|Try[A-Za-z0-9_]+|Award[A-Za-z0-9_]*Signal[A-Za-z0-9_]*)$/;

// Inherently single-fire / curated one-shots: an award here fires at most once
// ever (dev-only debug seeders). Allowlisted by exact name.
const ONESHOT_ALLOWLIST = new Set([
  "DebugSeedArgonian",
  "DebugSeedNord",
  "DebugSeedOrc",
  "DebugSeedRedguard",
]);

function main() {
  if (!fs.existsSync(MANAGER_PATH)) throw new Error(`Manager not found: ${MANAGER_PATH}`);
  const managerText = fs.readFileSync(MANAGER_PATH, "utf8");

  const signalDelta = buildSignalDeltaMap(managerText); // `${deityType}::SIGNAL_X` -> delta number

  const fns = parseFunctions(managerText); // name -> {body, calls:Set}
  if (process.env.PDV_ANTIFARM_SELFTEST === "1") {
    fns.set("HandleSelftestUncappedGain", {
      body: "    if PDV_Shor\n        AwardCuratedSignal(PDV_Shor, PDV_Shor.SIGNAL_ANCESTOR_SPINE, None)\n    endIf\n",
      calls: new Set(["AwardCuratedSignal"]),
    });
  }

  // reverse call graph
  const callers = new Map();
  for (const [name, info] of fns) {
    for (const callee of info.calls) {
      if (!callers.has(callee)) callers.set(callee, new Set());
      callers.get(callee).add(name);
    }
  }

  // which functions transitively reach a piety award
  const awardMemo = new Map();
  const reaches = (name, seen = new Set()) => {
    if (awardMemo.has(name)) return awardMemo.get(name);
    if (seen.has(name)) return false;
    seen.add(name);
    const info = fns.get(name);
    if (!info) return false;
    let r = [...info.calls].some((c) => AWARD_PRIMITIVES.has(c));
    if (!r) r = [...info.calls].some((c) => fns.has(c) && reaches(c, seen));
    awardMemo.set(name, r);
    return r;
  };

  // own cap?
  const ownCap = new Map();
  for (const [name, info] of fns) ownCap.set(name, detectCap(info.body));

  // tree cap (function + non-primitive callees)?
  const treeCapMemo = new Map();
  const treeHasCap = (name, seen = new Set()) => {
    if (treeCapMemo.has(name)) return treeCapMemo.get(name);
    if (seen.has(name)) return false;
    seen.add(name);
    const info = fns.get(name);
    if (!info) return false;
    let r = ownCap.get(name) === true;
    if (!r) {
      for (const c of info.calls) {
        if (AWARD_PRIMITIVES.has(c)) continue;
        if (fns.has(c) && treeHasCap(c, seen)) { r = true; break; }
      }
    }
    treeCapMemo.set(name, r);
    return r;
  };

  // caller-coverage: every caller capped (own tree or transitively covered)
  const callerCovMemo = new Map();
  const isCallerCovered = (name, seen = new Set()) => {
    if (callerCovMemo.has(name)) return callerCovMemo.get(name);
    if (seen.has(name)) return false;
    seen.add(name);
    const cs = callers.get(name);
    if (!cs || cs.size === 0) { callerCovMemo.set(name, false); return false; }
    let all = true;
    for (const c of cs) {
      if (!(treeHasCap(c) || isCallerCovered(c, seen))) { all = false; break; }
    }
    callerCovMemo.set(name, all);
    return all;
  };

  // does a handler (transitively, stopping at primitives) emit any POSITIVE-delta award?
  const gainMemo = new Map();
  const awardsGain = (name, seen = new Set()) => {
    if (gainMemo.has(name)) return gainMemo.get(name);
    if (seen.has(name)) return false;
    seen.add(name);
    const info = fns.get(name);
    if (!info) return false;
    let r = bodyAwardsPositive(info.body, signalDelta);
    if (!r) {
      for (const c of info.calls) {
        if (AWARD_PRIMITIVES.has(c)) continue;
        if (fns.has(c) && awardsGain(c, seen)) { r = true; break; }
      }
    }
    gainMemo.set(name, r);
    return r;
  };

  const capped = [];
  const uncappedGain = [];     // genuine anti-farm gaps (FINDINGS)
  const uncappedPenalty = [];  // penalty-only, informational
  const allowlisted = [];

  for (const [name, info] of fns) {
    if (AWARD_PRIMITIVES.has(name)) continue;
    if (!HANDLER_RE.test(name)) continue;
    if (!reaches(name)) continue;

    const ownTree = treeHasCap(name);
    const byCaller = !ownTree && isCallerCovered(name);
    const onAllowlist = ONESHOT_ALLOWLIST.has(name) || isSingleFire(info.body);

    if (ownTree) {
      capped.push({ name, via: ownCap.get(name) ? "own-handler-gate" : "called-fn-gate" });
    } else if (byCaller) {
      capped.push({ name, via: "caller-gate (thin emit-wrapper; every caller capped)" });
    } else if (onAllowlist) {
      allowlisted.push({ name, why: ONESHOT_ALLOWLIST.has(name) ? "named debug seeder" : "single-fire once-ever flag" });
    } else if (awardsGain(name)) {
      uncappedGain.push({ name, callers: [...(callers.get(name) || [])] });
    } else {
      uncappedPenalty.push({ name, callers: [...(callers.get(name) || [])] });
    }
  }

  capped.sort(byName); uncappedGain.sort(byName); uncappedPenalty.sort(byName); allowlisted.sort(byName);

  const selftest = process.env.PDV_ANTIFARM_SELFTEST === "1"
    ? (uncappedGain.some((u) => u.name === "HandleSelftestUncappedGain") &&
       capped.some((c) => c.name === "HandleNordSleepEvents")
        ? "PASS (caught injected uncapped GAIN; HandleNordSleepEvents reads CAPPED)"
        : "FAIL")
    : "off";

  writeLedger({ capped, uncappedGain, uncappedPenalty, allowlisted, selftest });

  const summary = {
    status: uncappedGain.length ? "FINDINGS" : "CLEAN",
    handlersAwardingPiety: capped.length + uncappedGain.length + uncappedPenalty.length + allowlisted.length,
    capped: capped.length,
    allowlistedOneShots: allowlisted.length,
    uncappedGain: uncappedGain.map((u) => u.name),
    uncappedPenaltyOnly: uncappedPenalty.map((u) => u.name),
    selftest,
    ledger: "references/authoring/PDV_AntiFarmSweepLedger.md",
  };
  console.log(JSON.stringify(summary, null, 2));
  process.exit(uncappedGain.length ? 1 : 0);
}

const byName = (a, b) => a.name.localeCompare(b.name);

// ---- signal -> delta resolution -----------------------------------------

function buildSignalDeltaMap(managerText) {
  // prop name (PDV_Shor) -> deity script type (PDV_Deity_Shor)
  const propType = new Map();
  for (const m of managerText.matchAll(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s+Property\s+(PDV_[A-Za-z0-9_]+)\s+Auto\b/gim)) {
    if (/^PDV_(Deity|DaedricPath)_/.test(m[1])) propType.set(m[2], m[1]);
  }
  const map = new Map(); // `${deityType}::SIGNAL_X` -> delta
  const files = fs.readdirSync(SOURCE_DIR).filter((f) => /^PDV_(Deity|DaedricPath)_.*\.psc$/i.test(f));
  for (const file of files) {
    const type = file.replace(/\.psc$/i, "");
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    const sigNum = new Map();   // SIGNAL_X -> number
    const deltaConst = new Map(); // DELTA_X -> number
    for (const m of text.matchAll(/Int\s+Property\s+(SIGNAL_[A-Za-z0-9_]+)\s*=\s*(-?\d+)/g)) sigNum.set(m[1], Number(m[2]));
    for (const m of text.matchAll(/Float\s+Property\s+(DELTA_[A-Za-z0-9_]+)\s*=\s*(-?\d+(?:\.\d+)?)/g)) deltaConst.set(m[1], Number(m[2]));
    // ScoreCuratedSignal branch: == SIGNAL_X ... return DELTA_X | literal
    const body = functionBody(text, "ScoreCuratedSignal");
    if (!body) continue;
    for (const m of body.matchAll(/==\s*(SIGNAL_[A-Za-z0-9_]+)\s*[\r\n]+\s*return\s+([A-Za-z0-9_.\-]+)/g)) {
      const sig = m[1]; const ret = m[2];
      let delta;
      if (deltaConst.has(ret)) delta = deltaConst.get(ret);
      else if (/^-?\d+(?:\.\d+)?$/.test(ret)) delta = Number(ret);
      else continue;
      map.set(`${type}::${sig}`, delta);
    }
  }
  // store propType for emit resolution
  map.__propType = propType;
  return map;
}

function bodyAwardsPositive(body, signalDelta) {
  const propType = signalDelta.__propType;
  // 1. curated-signal emits: AwardCuratedSignal[Scaled](PDV_Deity, PDV_Deity.SIGNAL_X, ...)
  for (const m of body.matchAll(/\bAwardCuratedSignal(?:Scaled)?\s*\(\s*(PDV_[A-Za-z0-9_]+)\s*,\s*(PDV_[A-Za-z0-9_]+)\.(SIGNAL_[A-Za-z0-9_]+)/g)) {
    const deityType = propType.get(m[2]) || `PDV_Deity_${m[2].replace(/^PDV_/, "")}`;
    const delta = signalDelta.get(`${deityType}::${m[3]}`);
    if (delta === undefined) return true; // unknown sign: be conservative, treat as gain-capable
    if (delta > 0) return true;
  }
  // AwardCuratedSignalByIndex(idx, signalType) -- sign unknown, treat as gain-capable
  if (/\bAwardCuratedSignalByIndex\s*\(/.test(body)) return true;
  // 2. direct AwardPiety(deity, <amount>) -- positive literal or non-negated expr = gain
  for (const m of body.matchAll(/\bAwardPiety\s*\(\s*[^,]+,\s*([^,)]+)/g)) {
    const amt = m[1].trim();
    if (/^-/.test(amt)) continue;                 // -penalty literal/expr
    if (/^\d+(?:\.\d+)?$/.test(amt)) { if (Number(amt) > 0) return true; continue; }
    // a variable/expr not obviously negated -> could be positive; conservative gain
    return true;
  }
  return false;
}

// ---- parsing -------------------------------------------------------------

function parseFunctions(text) {
  const lines = text.split(/\r?\n/);
  const fns = new Map();
  let cur = null; let bodyLines = [];
  const headerRe = /^\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/i;
  const endRe = /^\s*EndFunction\b/i;
  for (const line of lines) {
    if (!cur) {
      const m = line.match(headerRe);
      if (m && !/\bNative\b/i.test(line)) { cur = m[1]; bodyLines = []; }
    } else if (endRe.test(line)) {
      const body = bodyLines.join("\n");
      fns.set(cur, { body, calls: extractCalls(body) });
      cur = null;
    } else {
      bodyLines.push(line);
    }
  }
  return fns;
}

function extractCalls(body) {
  const calls = new Set();
  for (const m of body.matchAll(/(?:^|[^.\w])([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)) calls.add(m[1]);
  for (const m of body.matchAll(/\.([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)) calls.add(m[1]);
  return calls;
}

function functionBody(text, name) {
  const re = new RegExp(`(?:^|\\n)\\s*(?:[A-Za-z_][\\w\\[\\]]*\\s+)?Function\\s+${name}\\s*\\([^)]*\\)([\\s\\S]*?)\\n\\s*EndFunction`, "i");
  const m = text.match(re);
  return m ? m[1] : null;
}

// ---- cap detection -------------------------------------------------------

function detectCap(body) {
  // (a) Consume* anti-farm helpers
  if (/\bConsume(OncePerDaySignal|DailyRepeatMultiplier)\s*\(/.test(body)) return true;
  // (b) day-key guard: a StorageUtil int compared against the game-day index.
  //     Handles both the inline `GetCurrentGameTime() as Int` form and the
  //     two-step `Float t = ...GetCurrentGameTime()  ;  Int d = t as Int` form.
  const usesGameDay = /GetCurrentGameTime\(\)\s*as\s*Int/.test(body) ||
                      (/GetCurrentGameTime\(\)/.test(body) && /\bas\s+Int\b/.test(body));
  if (usesGameDay && /StorageUtil\.GetIntValue\([^)]*\)\s*==/.test(body)) return true;
  // (c) StateTrack rate-limit primitives
  if (/\b(HasRecentEvidenceDays|IsTransitionLockedOut)\s*\(/.test(body)) return true;
  // (d) single-fire once-ever flag
  if (isSingleFire(body)) return true;
  return false;
}

function isSingleFire(body) {
  // once-ever guard: read a sentinel flag, early-return if already set, then set it.
  // Accept the three equivalent "already fired" tests the codebase uses:
  //   == 1   (exact),  > 0   (any positive),  >= 1  (any positive).
  // Without the >0/>=1 forms, a per-anchor once-ever handler like
  // HandleOrcFourHoldsVisit (visitedKey > 0 early-return) would be missed by
  // own-cap detection -- safe today only because its sole caller is capped, but
  // a latent false-UNCAPPED for any such handler with no capped caller.
  // window allows a Trace(...)/Debug line between the guard test and the return
  // (the codebase logs a "skip" trace before bailing in several once-ever gates).
  const guardsReturn = /StorageUtil\.GetIntValue\([^)]*\)\s*(?:==\s*1|>\s*0|>=\s*1)[\s\S]{0,160}?\breturn\b/.test(body);
  const setsFlag = /StorageUtil\.SetIntValue\([^)]*,\s*1\s*\)/.test(body);
  return guardsReturn && setsFlag;
}

// ---- ledger --------------------------------------------------------------

function writeLedger({ capped, uncappedGain, uncappedPenalty, allowlisted, selftest }) {
  const md = [];
  md.push("# PDV Anti-Farm Sweep Ledger");
  md.push("");
  md.push("GENERATED by tools/pdv_antifarm_sweep_audit.mjs - do not hand-edit.");
  md.push("");
  md.push("Anti-farm doctrine: every signal handler that awards POSITIVE (gain) PIETY needs an anti-farm gate on the PULSE -- a Consume* helper (ConsumeOncePerDaySignal hard once/day, ConsumeDailyRepeatMultiplier 0.7^n soft), a per-handler StorageUtil day-key guard (encode day+1), a single-fire once-ever flag, or a StateTrack lockout -- on the path to the award.");
  md.push("");
  md.push("Scope: PDV__ManagerQuest.psc handler-shaped functions (Handle<X> / Record<X>Scaled / Try<X> / Award<X>Signal) that transitively reach AwardPiety / AwardCuratedSignal[Scaled]. Substrate AdjustMetric (the favor/buff channel, not the piety pulse) is intentionally out of scope. The audit is caller-aware (a thin emit-wrapper reads CAPPED when every caller is capped) and sign-aware: only POSITIVE-delta (gain) handlers are a farm exploit and fail the build; PENALTY-only handlers (negative delta -- anti-creed, oath-break, Lorkhan-pressure) cannot be farmed for gain and are reported as friction-pacing review only.");
  md.push("");
  md.push(`Summary: ${capped.length + uncappedGain.length + uncappedPenalty.length + allowlisted.length} piety-awarding handlers | ${capped.length} CAPPED | ${allowlisted.length} allowlisted one-shot | ${uncappedGain.length} UNCAPPED-GAIN (findings) | ${uncappedPenalty.length} uncapped-penalty-only (review)`);
  md.push(`Self-test: ${asciiSafe(selftest)}`);
  md.push("");

  md.push("## UNCAPPED GAIN -- genuine anti-farm gaps (the doctrine target)");
  md.push("");
  md.push("Each awards POSITIVE piety with neither an own-tree cap nor full caller coverage. Add a Consume*/day-key gate on the pulse, or (if inherently single-fire) add to ONESHOT_ALLOWLIST with justification.");
  md.push("");
  md.push(tableOrNone(uncappedGain, "handler", "callers", (u) => u.callers.length ? asciiSafe(u.callers.join(", ")) : "(top-level / event-driven)"));
  md.push("");

  md.push("## Uncapped PENALTY-only -- friction-pacing review (not a farm exploit)");
  md.push("");
  md.push("These award only a NEGATIVE delta, so repeating them costs the player -- not farmable for gain. They do NOT fail the build. Review only if the intended penalty pacing wants its own per-event/per-day rate-limit (e.g. so one in-world act cannot stack the same penalty many times in a tick).");
  md.push("");
  md.push(tableOrNone(uncappedPenalty, "handler", "callers", (u) => u.callers.length ? asciiSafe(u.callers.join(", ")) : "(top-level / event-driven)"));
  md.push("");

  md.push("## Allowlisted one-shots (inherently single-fire; not farmable)");
  md.push("");
  if (!allowlisted.length) md.push("- none");
  else for (const a of allowlisted) md.push(`- ${asciiSafe(a.name)} -- ${asciiSafe(a.why)}`);
  md.push("");

  md.push("## CAPPED (for reference)");
  md.push("");
  md.push(tableOrNone(capped, "handler", "gate", (c) => asciiSafe(c.via)));
  md.push("");

  fs.writeFileSync(OUT_MD, md.join("\n") + "\n", "utf8");
}

function tableOrNone(rows, colA, colB, colBVal) {
  if (!rows.length) return "- none";
  const out = [`| ${colA} | ${colB} |`, "|---|---|"];
  for (const r of rows) out.push(`| ${asciiSafe(r.name)} | ${colBVal(r)} |`);
  return out.join("\n");
}

function asciiSafe(v) { return String(v ?? "").replace(/[^\x00-\x7F]/g, "?"); }

main();
