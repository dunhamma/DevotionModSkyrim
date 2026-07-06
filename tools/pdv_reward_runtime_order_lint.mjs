#!/usr/bin/env node
/*
 * PDV reward runtime-order lint.
 *
 * The eligibility -> reward coverage audit (pdv_eligibility_reward_coverage_audit.mjs)
 * is a static existence/fill check: it proves each focusable deity's reward SPEL
 * exists and its manager VMAD property is filled. It CANNOT see an add-then-remove
 * ordering bug across reward lanes, because both the granting and the stripping call
 * pass their static existence check.
 *
 * The class this lint closes (noted in commit 2af9ba9d): the Nord baselines reuse the
 * Imperial Divine reward SPELs. In SyncFirstTierRaceRewardRuntime, SyncNordRewards runs
 * first and grants the reused spell (isActive requires origin == NORD), then
 * SyncImperialRewards runs after and -- on a non-Imperial save, before the fix -- ran the
 * same family unconditionally with isActive = origin == IMPERIAL (false), REMOVING the
 * spell the Nord lane had just added. Net: granted then stripped in the same pass; every
 * display cue passed, Active Effects were empty.
 *
 * This lint models the runtime the way the code actually executes it:
 *   1. Reads the dispatch ORDER of the Sync*Reward* calls in SyncFirstTierRaceRewardRuntime.
 *   2. For each managed SPEL, resolves which lane (top-level Sync*Rewards function) manages
 *      it, which origin race that management is bound to (grants for), and -- crucially --
 *      whether an origin early-return guard means the lane is SKIPPED (not run) for other
 *      origins, or runs and STRIPS the spell for other origins.
 *   3. For any SPEL managed by more than one lane, FAILs when, for some origin, a later-
 *      running lane would strip a grant an earlier-running lane made.
 *
 * Pure static source analysis: no ESP / mutagen bridge needed. Reads the git-tracked
 * live-source manager by default (the branch's source of truth); --source <path> overrides
 * (point it at the deployed MO2 copy to check the compiled/deployed state instead).
 *
 * Usage:
 *   node tools/pdv_reward_runtime_order_lint.mjs           human summary + ledger, exit 1 on FAIL
 *   node tools/pdv_reward_runtime_order_lint.mjs --json     machine summary
 *   node tools/pdv_reward_runtime_order_lint.mjs --source D:/.../PDV__ManagerQuest.psc
 *   node tools/pdv_reward_runtime_order_lint.mjs --self-test synthetic fixtures prove the class
 */

import fs from "node:fs";
import path from "node:path";

const REPO_ROOT = process.cwd();
const LIVE_SOURCE = path.join(REPO_ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const ANVIL_SOURCE = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV__ManagerQuest.psc";
const OUT_MD = path.join(REPO_ROOT, "references", "authoring", "PDV_RewardRuntimeOrderLintLedger.md");
const OUT_CSV = path.join(REPO_ROOT, "references", "authoring", "PDV_RewardRuntimeOrderLintLedger.csv");

const RUNTIME_ENTRY = "SyncFirstTierRaceRewardRuntime";
const REWARD_SPELL_RE = /^PDV_Bless_\w+$/;

const args = process.argv.slice(2);
const JSON_MODE = args.includes("--json");
const SELF_TEST = args.includes("--self-test");
const USE_MO2 = args.includes("--mo2");
const sourceArgIdx = args.indexOf("--source");
const SOURCE_OVERRIDE = sourceArgIdx >= 0 ? args[sourceArgIdx + 1] : null;

// ---------------------------------------------------------------------------
// Papyrus source helpers (line-based, robust to nested parens inside call args)
// ---------------------------------------------------------------------------

function toPosix(value) {
  return String(value).replace(/\\/g, "/");
}

// Strip a trailing line comment (";") that is not inside a string literal.
function stripComment(line) {
  let inString = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (ch === "\"") inString = !inString;
    else if (ch === ";" && !inString) return line.slice(0, i);
  }
  return line;
}

// Return the array of source lines forming a function body (between the header
// line and the matching EndFunction), each comment-stripped and right-trimmed.
function functionLines(source, name) {
  const lines = source.split(/\r?\n/);
  const headerRe = new RegExp(`^\\s*(?:[\\w\\[\\]]+\\s+)?Function\\s+${name}\\s*\\(`, "i");
  let start = -1;
  for (let i = 0; i < lines.length; i += 1) {
    if (headerRe.test(lines[i])) {
      start = i;
      break;
    }
  }
  if (start < 0) return { header: "", body: [] };
  const header = stripComment(lines[start]);
  const body = [];
  for (let i = start + 1; i < lines.length; i += 1) {
    if (/^\s*EndFunction\b/i.test(lines[i])) break;
    body.push(stripComment(lines[i]).replace(/\s+$/, ""));
  }
  return { header, body };
}

// Parse "(Type name, Type name = default, ...)" from a function header into an
// ordered list of {type, name}. Papyrus signatures have no nested parens.
function parseSignatureParams(headerLine) {
  const open = headerLine.indexOf("(");
  const close = headerLine.lastIndexOf(")");
  if (open < 0 || close < 0 || close < open) return [];
  const inside = headerLine.slice(open + 1, close).trim();
  if (!inside) return [];
  return inside.split(",").map((raw) => {
    const decl = raw.trim().split("=")[0].trim();
    const parts = decl.split(/\s+/);
    return { type: parts[0] || "", name: parts[1] || "" };
  });
}

// Given a string and the index of an opening "(", return the substring strictly
// inside the balanced parens (paren-depth and string aware).
function balancedParens(str, openIdx) {
  let depth = 0;
  let inString = false;
  for (let i = openIdx; i < str.length; i += 1) {
    const ch = str[i];
    if (ch === "\"") inString = !inString;
    if (inString) continue;
    if (ch === "(") depth += 1;
    else if (ch === ")") {
      depth -= 1;
      if (depth === 0) return str.slice(openIdx + 1, i);
    }
  }
  return null;
}

// Split a call-argument string on top-level commas (paren-depth and string aware).
function splitArgs(argStr) {
  if (argStr == null) return [];
  const out = [];
  let cur = "";
  let depth = 0;
  let inString = false;
  for (let i = 0; i < argStr.length; i += 1) {
    const ch = argStr[i];
    if (ch === "\"") inString = !inString;
    if (!inString && ch === "(") depth += 1;
    if (!inString && ch === ")") depth -= 1;
    if (!inString && depth === 0 && ch === ",") {
      out.push(cur.trim());
      cur = "";
    } else {
      cur += ch;
    }
  }
  if (cur.trim() !== "") out.push(cur.trim());
  return out;
}

// Find the first invocation of `fnName(` on a line and return its split args, or null.
function callArgsOnLine(line, fnName) {
  const idx = line.search(new RegExp(`\\b${fnName}\\s*\\(`));
  if (idx < 0) return null;
  const open = line.indexOf("(", idx);
  const inside = balancedParens(line, open);
  return inside == null ? null : splitArgs(inside);
}

function firstOriginToken(text) {
  const m = String(text).match(/GetPlayerOriginRaceIndex\(\)\s*==\s*(ORIGIN_\w+)/);
  return m ? m[1] : null;
}

// ---------------------------------------------------------------------------
// Static model of the reward runtime
// ---------------------------------------------------------------------------

// Parse GetFirstTierRaceRewardSpellForOrigin into { spellEditorId -> ORIGIN_token }.
// Used to bind the inline T1-floor dispatch calls to their origin race.
function parseFirstTierSelector(source) {
  const { body } = functionLines(source, "GetFirstTierRaceRewardSpellForOrigin");
  const map = new Map();
  let pendingOrigin = null;
  for (const line of body) {
    const trimmed = line.trim();
    const originMatch = trimmed.match(/originRace\s*==\s*(ORIGIN_\w+)/);
    if (originMatch) pendingOrigin = originMatch[1];
    const returnMatch = trimmed.match(/^return\s+(PDV_Bless_\w+)/);
    if (returnMatch && pendingOrigin) map.set(returnMatch[1], pendingOrigin);
  }
  return map;
}

// Parse a Sync*RewardFamily / Sync*EmphasisFamily helper: its signature params, the
// Spell-typed params it actually manages via SyncRaceRewardSpell, and the ORIGIN this
// family binds its grant to (null when the family gates on a caller-supplied flag,
// e.g. the Khajiit emphasis family -- the lane origin is used as the fallback).
function parseFamily(source, name) {
  const { header, body } = functionLines(source, name);
  const params = parseSignatureParams(header);
  const spellParamNames = new Set(params.filter((p) => p.type === "Spell").map((p) => p.name));
  const managed = [];
  for (const line of body) {
    const call = callArgsOnLine(line, "SyncRaceRewardSpell");
    if (!call || call.length < 2) continue;
    const spellArg = call[1];
    if (spellParamNames.has(spellArg) && !managed.includes(spellArg)) managed.push(spellArg);
  }
  return {
    name,
    params,
    managedSpellParams: managed,
    boundOrigin: firstOriginToken(body.join("\n")),
  };
}

function collectFamilies(source) {
  const map = new Map();
  const re = /\bFunction\s+(Sync\w*(?:RewardFamily|EmphasisFamily))\s*\(/g;
  let m;
  while ((m = re.exec(source)) !== null) {
    if (!map.has(m[1])) map.set(m[1], parseFamily(source, m[1]));
  }
  return map;
}

const FAMILY_RE = /\bSync(\w*(?:RewardFamily|EmphasisFamily))\s*\(/;

// Detect an origin early-return guard starting at bodyLines[idx]:
//   if !<originLocal>      ... return ... endIf
//   if GetPlayerOriginRaceIndex() != ORIGIN_X   ... return ... endIf
//   if <originLocal> == False   ... return ... endIf
// Returns { origin, endIdx } when the block returns unconditionally for the
// complementary origin (a dominating guard), else null.
function detectOriginGuard(bodyLines, idx, originLocals) {
  const head = bodyLines[idx].trim();
  let guardedOrigin = null;
  let mm;
  if ((mm = head.match(/^if\s*!\s*(\w+)\s*$/)) && originLocals.has(mm[1])) {
    guardedOrigin = originLocals.get(mm[1]);
  } else if ((mm = head.match(/^if\s+(\w+)\s*==\s*False\s*$/i)) && originLocals.has(mm[1])) {
    guardedOrigin = originLocals.get(mm[1]);
  } else if ((mm = head.match(/^if\s+GetPlayerOriginRaceIndex\(\)\s*!=\s*(ORIGIN_\w+)\s*$/))) {
    guardedOrigin = mm[1];
  }
  if (!guardedOrigin) return null;

  // Walk to the matching endIf; require a top-level (depth 1) unconditional return
  // and no top-level else/elseIf (which would make the return conditional).
  let depth = 1;
  let topLevelReturn = false;
  let hasElse = false;
  let endIdx = -1;
  for (let j = idx + 1; j < bodyLines.length; j += 1) {
    const t = bodyLines[j].trim();
    if (/^if\b/i.test(t)) depth += 1;
    else if (/^endif\b/i.test(t)) {
      depth -= 1;
      if (depth === 0) {
        endIdx = j;
        break;
      }
    } else if (depth === 1 && /^(else|elseif)\b/i.test(t)) {
      hasElse = true;
    } else if (depth === 1 && /^return\b/i.test(t)) {
      topLevelReturn = true;
    }
  }
  if (endIdx >= 0 && topLevelReturn && !hasElse) return { origin: guardedOrigin, endIdx };
  return null;
}

// Analyze one top-level lane function (a Sync*Rewards dispatched from the runtime).
// Emits a managed-spell event per (spell, call-site) it manages, recording the origin
// the grant is bound to and the origin guard (if any) that gates the call.
//   depth: recursion guard for helper Sync*(playerRef, ...) expansion.
//   paramOrigins: maps this function's Bool params to an ORIGIN token (for helpers
//                 called with an origin flag, e.g. SyncOrcSpineBoon(playerRef, isOrc, ...)).
function analyzeLane(source, laneName, laneDispatchIndex, families, firstTierSpells, opts = {}) {
  const depth = opts.depth || 0;
  const paramOrigins = opts.paramOrigins || new Map();
  const inheritedGuard = opts.inheritedGuard || null;
  const events = [];
  const { body } = functionLines(source, laneName);

  // Bool locals that mean "origin == ORIGIN_X" (exact origin flags), seeded with any
  // origin-bearing params passed in from the caller.
  const originLocals = new Map(paramOrigins);
  // The lane's principal origin: first GetPlayerOriginRaceIndex()==ORIGIN_X seen, used as
  // the fallback grant origin for families that gate on a caller flag (Khajiit emphasis).
  let laneOrigin = firstOriginToken(body.join("\n")) || opts.laneOrigin || null;

  let dominatingOrigin = inheritedGuard;
  let stmt = 0;

  for (let i = 0; i < body.length; i += 1) {
    const line = body[i];
    const trimmed = line.trim();
    if (trimmed === "") continue;

    // Track exact origin-flag locals: Bool isX = GetPlayerOriginRaceIndex() == ORIGIN_Y
    const localDecl = trimmed.match(/^Bool\s+(\w+)\s*=\s*GetPlayerOriginRaceIndex\(\)\s*==\s*(ORIGIN_\w+)\s*$/);
    if (localDecl) {
      originLocals.set(localDecl[1], localDecl[2]);
      if (!laneOrigin) laneOrigin = localDecl[2];
      continue;
    }

    // Origin early-return guard -> dominates all subsequent statements.
    if (/^if\b/i.test(trimmed)) {
      const guard = detectOriginGuard(body, i, originLocals);
      if (guard) {
        dominatingOrigin = guard.origin;
        i = guard.endIdx; // skip the guard block
        continue;
      }
    }

    // Family / emphasis invocation.
    const famMatch = trimmed.match(FAMILY_RE);
    if (famMatch) {
      const famName = "Sync" + famMatch[1];
      const fam = families.get(famName);
      const callArgs = callArgsOnLine(trimmed, famName);
      if (fam && callArgs) {
        const boundOrigin = fam.boundOrigin || laneOrigin || null;
        for (const paramName of fam.managedSpellParams) {
          const paramIdx = fam.params.findIndex((p) => p.name === paramName);
          const spell = paramIdx >= 0 ? callArgs[paramIdx] : undefined;
          if (spell && REWARD_SPELL_RE.test(spell)) {
            events.push(makeEvent(spell, boundOrigin, dominatingOrigin, laneName, laneDispatchIndex, stmt, `${famName}(${paramName})`));
            stmt += 1;
          }
        }
      }
      continue;
    }

    // Inline SyncRaceRewardSpell(playerRef, SPELL, expr, label).
    if (/\bSyncRaceRewardSpell\s*\(/.test(trimmed)) {
      const callArgs = callArgsOnLine(trimmed, "SyncRaceRewardSpell");
      if (callArgs && callArgs.length >= 3 && callArgs[0] === "playerRef") {
        const spell = callArgs[1];
        if (REWARD_SPELL_RE.test(spell)) {
          const boundOrigin = inlineBoundOrigin(callArgs[2], spell, originLocals, firstTierSpells);
          events.push(makeEvent(spell, boundOrigin, dominatingOrigin, laneName, laneDispatchIndex, stmt, "SyncRaceRewardSpell"));
          stmt += 1;
        }
      }
      continue;
    }

    // Helper Sync*(playerRef, ...) expansion (one level) -- e.g. SyncOrcSpineBoon. Keeps
    // the inventory complete so a future reuse buried in a helper is still seen. Attributed
    // to THIS lane and dispatch position; unresolved origins stay null (never a finding).
    if (depth < 1) {
      const helperMatch = trimmed.match(/\b(Sync\w+)\s*\(\s*playerRef\b/);
      if (helperMatch) {
        const helperName = helperMatch[1];
        if (helperName !== "SyncRaceRewardSpell" && !FAMILY_RE.test(trimmed) && functionLines(source, helperName).header) {
          const helperArgs = callArgsOnLine(trimmed, helperName) || [];
          const helperParams = parseSignatureParams(functionLines(source, helperName).header);
          const helperParamOrigins = new Map();
          for (let a = 0; a < helperArgs.length && a < helperParams.length; a += 1) {
            if (originLocals.has(helperArgs[a])) helperParamOrigins.set(helperParams[a].name, originLocals.get(helperArgs[a]));
          }
          const nested = analyzeLane(source, helperName, laneDispatchIndex, families, firstTierSpells, {
            depth: depth + 1,
            paramOrigins: helperParamOrigins,
            inheritedGuard: dominatingOrigin,
            laneOrigin,
          });
          for (const ev of nested) {
            events.push({ ...ev, laneName, stmt });
            stmt += 1;
          }
        }
      }
    }
  }
  return events;
}

function inlineBoundOrigin(expr, spell, originLocals, firstTierSpells) {
  const direct = firstOriginToken(expr);
  if (direct) return direct;
  // A local origin flag referenced in the expr (e.g. isRedguard && ...).
  for (const [local, origin] of originLocals.entries()) {
    if (new RegExp(`\\b${local}\\b`).test(expr)) return origin;
  }
  // Inline T1-floor dispatch: gated by "activeReward == PDV_Bless_X_T1".
  const cmp = expr.match(/activeReward\s*==\s*(PDV_Bless_\w+)/);
  if (cmp && firstTierSpells.has(cmp[1])) return firstTierSpells.get(cmp[1]);
  if (firstTierSpells.has(spell)) return firstTierSpells.get(spell);
  return null;
}

function makeEvent(spell, boundOrigin, guardOrigin, laneName, laneDispatchIndex, stmt, site) {
  return { spell, boundOrigin, guardOrigin, laneName, laneDispatchIndex, stmt, site };
}

// Parse SyncFirstTierRaceRewardRuntime into the ordered dispatch of inline reward calls
// and lane-function calls, then expand each lane into its managed-spell events.
function buildEvents(source) {
  const families = collectFamilies(source);
  const firstTierSpells = parseFirstTierSelector(source);
  const { body } = functionLines(source, RUNTIME_ENTRY);

  const events = [];
  let dispatchIndex = 0;

  for (const line of body) {
    const trimmed = line.trim();
    if (trimmed === "") continue;

    // Inline reward call directly in the dispatch (the T1-floor block).
    if (/\bSyncRaceRewardSpell\s*\(/.test(trimmed)) {
      const callArgs = callArgsOnLine(trimmed, "SyncRaceRewardSpell");
      if (callArgs && callArgs.length >= 3 && callArgs[0] === "playerRef" && REWARD_SPELL_RE.test(callArgs[1])) {
        const boundOrigin = inlineBoundOrigin(callArgs[2], callArgs[1], new Map(), firstTierSpells);
        events.push(makeEvent(callArgs[1], boundOrigin, null, "SyncFirstTierRaceRewardRuntime(inline)", dispatchIndex, 0, "SyncRaceRewardSpell(inline)"));
        dispatchIndex += 1;
      }
      continue;
    }

    // Lane dispatch: Sync<Name>Rewards(playerRef) / Sync<Name>EmphasisRewards(playerRef).
    // (Sync*NeglectSpell take a Bool first arg, so requiring `playerRef` excludes them.)
    const laneMatch = trimmed.match(/^(Sync\w+)\s*\(\s*playerRef\s*\)\s*$/);
    if (laneMatch) {
      const laneName = laneMatch[1];
      if (functionLines(source, laneName).header) {
        events.push(...analyzeLane(source, laneName, dispatchIndex, families, firstTierSpells));
        dispatchIndex += 1;
      }
    }
  }
  return events;
}

function globalPos(ev) {
  return ev.laneDispatchIndex * 100000 + ev.stmt;
}

// ---------------------------------------------------------------------------
// Collision analysis
// ---------------------------------------------------------------------------

function analyzeManagerSource(source) {
  const events = buildEvents(source);

  // Inventory: group events by spell; reuse-collision candidates are managed by >1 call site.
  const bySpell = new Map();
  for (const ev of events) {
    if (!bySpell.has(ev.spell)) bySpell.set(ev.spell, []);
    bySpell.get(ev.spell).push(ev);
  }

  const inventory = [];
  const findings = [];
  const seen = new Set();

  for (const [spell, spellEvents] of bySpell.entries()) {
    if (spellEvents.length < 2) continue; // single call site -> cannot collide
    const lanes = new Set(spellEvents.map((e) => e.laneName));
    inventory.push({
      spell,
      callSites: spellEvents.length,
      lanes: [...lanes],
      events: spellEvents
        .slice()
        .sort((a, b) => globalPos(a) - globalPos(b))
        .map((e) => ({ lane: e.laneName, origin: e.boundOrigin, guard: e.guardOrigin, site: e.site, pos: globalPos(e) })),
    });

    // Origins that some lane can GRANT this spell for.
    const grantOrigins = new Set(spellEvents.map((e) => e.boundOrigin).filter(Boolean));

    for (const origin of grantOrigins) {
      const grants = spellEvents.filter((e) => e.boundOrigin === origin);
      // A different-origin event STRIPS this spell on an `origin` save iff it actually runs
      // there: no guard (runs for all) or a guard whose origin equals this origin.
      const strips = spellEvents.filter(
        (e) => e.boundOrigin && e.boundOrigin !== origin && (e.guardOrigin === null || e.guardOrigin === origin)
      );
      for (const g of grants) {
        for (const s of strips) {
          if (globalPos(s) > globalPos(g)) {
            const key = `${spell}|${origin}|${g.laneName}|${s.laneName}`;
            if (seen.has(key)) continue;
            seen.add(key);
            findings.push({
              spell,
              origin,
              grantingLane: g.laneName,
              grantingSite: g.site,
              grantPos: globalPos(g),
              strippingLane: s.laneName,
              strippingSite: s.site,
              stripPos: globalPos(s),
            });
          }
        }
      }
    }
  }

  inventory.sort((a, b) => a.spell.localeCompare(b.spell));
  findings.sort((a, b) => (a.spell + a.origin).localeCompare(b.spell + b.origin));
  return { events, inventory, findings };
}

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

function csvCell(value) {
  const text = String(value ?? "");
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, "\"\"")}"` : text;
}

// Repo-relative posix path when the source lives inside the repo (portable for the
// committed ledger); absolute posix for an external source (e.g. the deployed MO2 copy).
function displaySourcePath(sourcePath) {
  const rel = path.relative(REPO_ROOT, sourcePath);
  return !rel.startsWith("..") && !path.isAbsolute(rel) ? toPosix(rel) : toPosix(sourcePath);
}

function writeLedgers(sourcePath, inventory, findings) {
  const status = findings.length ? "FAIL" : "PASS";
  const md = [
    "# PDV Reward Runtime-Order Lint Ledger",
    "",
    "GENERATED by tools/pdv_reward_runtime_order_lint.mjs - do not hand-edit.",
    "",
    `Source checked: \`${displaySourcePath(sourcePath)}\``,
    "",
    `Overall: **${status}** (${inventory.length} reused spells, ${findings.length} add-then-remove collisions)`,
    "",
    "## Reuse inventory (SPELs managed by more than one call site)",
    "",
  ];
  if (inventory.length === 0) {
    md.push("_No reward SPEL is managed by more than one lane._", "");
  } else {
    md.push("| Spell | Call sites | Lanes (in dispatch order) |", "|---|---|---|");
    for (const item of inventory) {
      const laneCol = item.events.map((e) => `${e.lane} [${e.origin || "?"}${e.guard ? " guard:" + e.guard : ""}]`).join(" -> ");
      md.push(`| ${item.spell} | ${item.callSites} | ${laneCol} |`);
    }
    md.push("");
  }
  md.push("## Findings (grant-then-strip across lanes)", "");
  if (findings.length === 0) {
    md.push("_None: no later-running lane strips a reused spell an earlier lane granted._", "");
  } else {
    md.push("| Spell | Origin | Granting lane | Stripping lane |", "|---|---|---|---|");
    for (const f of findings) {
      md.push(`| ${f.spell} | ${f.origin} | ${f.grantingLane} (${f.grantingSite}) | ${f.strippingLane} (${f.strippingSite}) |`);
    }
    md.push("");
  }

  const csv = [
    "spell,origin,grantingLane,grantingSite,grantPos,strippingLane,strippingSite,stripPos",
    ...findings.map((f) =>
      [f.spell, f.origin, f.grantingLane, f.grantingSite, f.grantPos, f.strippingLane, f.strippingSite, f.stripPos]
        .map(csvCell)
        .join(",")
    ),
  ].join("\n") + "\n";

  fs.mkdirSync(path.dirname(OUT_MD), { recursive: true });
  fs.writeFileSync(OUT_MD, md.join("\n"), "utf8");
  fs.writeFileSync(OUT_CSV, csv, "utf8");
}

function resolveSourcePath() {
  if (SOURCE_OVERRIDE) return SOURCE_OVERRIDE;
  if (USE_MO2) return ANVIL_SOURCE;
  if (fs.existsSync(LIVE_SOURCE)) return LIVE_SOURCE;
  if (fs.existsSync(ANVIL_SOURCE)) return ANVIL_SOURCE;
  return LIVE_SOURCE; // will surface a clear ENOENT
}

// ---------------------------------------------------------------------------
// Self-test: synthetic fixtures exercising the real analysis pipeline
// ---------------------------------------------------------------------------

function fixture({ imperialGuard = false, imperialFirst = false }) {
  const nordLane = [
    "Function SyncNordRewards(Actor playerRef)",
    "    Bool isNord = GetPlayerOriginRaceIndex() == ORIGIN_NORD",
    "    SyncNordRewardFamily(playerRef, -1, PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, \"Mara\")",
    "EndFunction",
  ];
  const imperialBody = [
    "Function SyncImperialRewards(Actor playerRef)",
    "    Bool isImperial = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL",
    "    SyncRaceRewardSpell(playerRef, PDV_Bless_Imperial_Civic_T2, isImperial, \"Imperial Civic T2\")",
  ];
  if (imperialGuard) {
    imperialBody.push("    if !isImperial", "        return", "    endIf");
  }
  imperialBody.push(
    "    SyncImperialRewardFamily(playerRef, PDV_Mara, PDV_Bless_Imperial_Mara_T1, PDV_Bless_Imperial_Mara_T2, PDV_Bless_Imperial_Mara_T3, \"Mara\")",
    "EndFunction"
  );

  const dispatch = ["Function SyncFirstTierRaceRewardRuntime()", "    Actor playerRef = Game.GetPlayer()"];
  if (imperialFirst) {
    dispatch.push("    SyncImperialRewards(playerRef)", "    SyncNordRewards(playerRef)");
  } else {
    dispatch.push("    SyncNordRewards(playerRef)", "    SyncImperialRewards(playerRef)");
  }
  dispatch.push("EndFunction");

  const families = [
    "Function SyncNordRewardFamily(Actor playerRef, Int requiredBaseline, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)",
    "    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_NORD && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity",
    "    SyncRaceRewardSpell(playerRef, t1, isActive, label + \" T1\")",
    "    SyncRaceRewardSpell(playerRef, t2, isActive, label + \" T2\")",
    "    SyncRaceRewardSpell(playerRef, t3, isActive, label + \" T3\")",
    "EndFunction",
    "Function SyncImperialRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)",
    "    Bool isActive = GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && GetPatronState() == PATRON_STATE_ACTIVE && _activeDeity == deity",
    "    SyncRaceRewardSpell(playerRef, t1, isActive, label + \" T1\")",
    "    SyncRaceRewardSpell(playerRef, t2, isActive, label + \" T2\")",
    "    SyncRaceRewardSpell(playerRef, t3, isActive, label + \" T3\")",
    "EndFunction",
    "Function SyncRaceRewardSpell(Actor playerRef, Spell rewardSpell, Bool shouldBeActive, String rewardLabel)",
    "    if shouldBeActive",
    "        playerRef.AddSpell(rewardSpell, False)",
    "    else",
    "        playerRef.RemoveSpell(rewardSpell)",
    "    endIf",
    "EndFunction",
  ];

  return [...dispatch, "", ...nordLane, "", ...imperialBody, "", ...families].join("\n");
}

function selfTest() {
  const cases = [];

  // 1. Buggy: Nord grants first, Imperial strips unconditionally after (the real class).
  const buggy = analyzeManagerSource(fixture({ imperialGuard: false, imperialFirst: false }));
  const caughtNordVictim = buggy.findings.some(
    (f) =>
      f.spell === "PDV_Bless_Imperial_Mara_T1" &&
      f.origin === "ORIGIN_NORD" &&
      f.grantingLane === "SyncNordRewards" &&
      f.strippingLane === "SyncImperialRewards"
  );
  cases.push(["buggy fixture catches Nord-grant/Imperial-strip", caughtNordVictim]);
  cases.push(["buggy fixture flags all three reused tiers", buggy.findings.length >= 3]);
  cases.push([
    "buggy fixture does NOT falsely flag the Imperial save",
    !buggy.findings.some((f) => f.origin === "ORIGIN_IMPERIAL"),
  ]);

  // 2. Fixed: Imperial early-returns for non-Imperial (the 2af9ba9d guard) -> no collision.
  const fixed = analyzeManagerSource(fixture({ imperialGuard: true, imperialFirst: false }));
  cases.push(["fixed fixture (origin guard) reports no findings", fixed.findings.length === 0]);
  cases.push(["fixed fixture still inventories the reuse", fixed.inventory.length >= 1]);

  // 3. Reversed order, still no guard: reordering alone does NOT fix the class -- it just
  //    moves the victim. Imperial now grants first and the (still unconditional) Nord lane
  //    strips it last, so an Imperial save breaks while the Nord save is fine. This is why
  //    the real fix is an origin guard, not a reorder.
  const reversed = analyzeManagerSource(fixture({ imperialGuard: false, imperialFirst: true }));
  cases.push([
    "reversed order moves the victim to Imperial (reorder alone is not a fix)",
    reversed.findings.some(
      (f) => f.origin === "ORIGIN_IMPERIAL" && f.grantingLane === "SyncImperialRewards" && f.strippingLane === "SyncNordRewards"
    ) && !reversed.findings.some((f) => f.origin === "ORIGIN_NORD"),
  ]);

  const ok = cases.every(([, pass]) => pass);
  console.log(
    JSON.stringify(
      {
        ok,
        checks: Object.fromEntries(cases.map(([name, pass]) => [name, pass])),
        buggyFindings: buggy.findings.map((f) => `${f.spell}[${f.origin}] ${f.grantingLane}->${f.strippingLane}`),
      },
      null,
      2
    )
  );
  process.exit(ok ? 0 : 1);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  if (SELF_TEST) {
    selfTest();
    return;
  }

  const sourcePath = resolveSourcePath();
  const source = fs.readFileSync(sourcePath, "utf8");
  const { inventory, findings } = analyzeManagerSource(source);
  writeLedgers(sourcePath, inventory, findings);

  const summary = {
    status: findings.length ? "FAIL" : "PASS",
    source: toPosix(sourcePath),
    reusedSpells: inventory.length,
    collisions: findings.length,
    findings: findings.map((f) => ({
      spell: f.spell,
      origin: f.origin,
      grantingLane: f.grantingLane,
      strippingLane: f.strippingLane,
    })),
    ledger: toPosix(path.relative(REPO_ROOT, OUT_MD)),
  };

  if (JSON_MODE) {
    console.log(JSON.stringify(summary, null, 2));
  } else {
    console.log(`PDV reward runtime-order lint: ${summary.status} (${summary.reusedSpells} reused spells, ${summary.collisions} collisions)`);
    console.log(`Source: ${summary.source}`);
    if (findings.length) {
      console.log("Add-then-remove collisions (a later lane strips a spell an earlier lane granted):");
      for (const f of findings) {
        console.log(`  - ${f.spell} on ${f.origin}: ${f.grantingLane} grants, then ${f.strippingLane} strips`);
      }
    }
    console.log(`Ledger: ${summary.ledger}`);
  }
  process.exitCode = findings.length ? 1 : 0;
}

try {
  main();
} catch (error) {
  if (JSON_MODE) {
    console.log(JSON.stringify({ status: "FAIL", reusedSpells: 0, collisions: 1, error: error.message }, null, 2));
  } else {
    console.error(`[FAIL] ${error.message}`);
  }
  process.exitCode = 1;
}
