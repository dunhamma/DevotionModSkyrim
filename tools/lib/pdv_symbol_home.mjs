// pdv_symbol_home.mjs
//
// Ledger-driven symbol resolver for the 2.0 rebuild's audit gates.
//
// As functions move out of PDV__ManagerQuest.psc into deep modules, gates that
// hardcode a bare call needle ("ClampValue(") or a manager-side definition check
// ("Function JsonSafeString") go stale. This resolver lets a gate ask the
// authoritative region map + retirement ledger WHERE a symbol lives and HOW it is
// now called, so the gate's expectation tracks the extraction automatically
// instead of being hand-patched per move.
//
// Sources of truth (both under references/authoring/):
//   PDV_2_0RegionMap.json        -- module -> {targetScript, functions[]}
//   PDV_2_0Retirement.manifest.json -- per-symbol action (extract/retain/retire/...)
//
// Design note: callTokenPattern() is qualifier-AGNOSTIC by target script, so a
// needle matches whether or not the move has physically happened yet (bare
// `Name(` OR `TargetScript.Name(`). definitionFile() reads reality -- it scans
// the target script for the actual `Function Name` and only falls back to the
// manager -- so definition checks stay correct mid-extraction.

import fs from "node:fs";
import path from "node:path";

const MANAGER_SCRIPT = "PDV__ManagerQuest";
let _cache = null;

function load(repoRoot) {
  const root = path.resolve(repoRoot);
  if (_cache && _cache.root === root) return _cache;
  const authoring = path.join(root, "references", "authoring");
  const rm = JSON.parse(fs.readFileSync(path.join(authoring, "PDV_2_0RegionMap.json"), "utf8"));
  const led = JSON.parse(fs.readFileSync(path.join(authoring, "PDV_2_0Retirement.manifest.json"), "utf8"));
  const byName = {};
  for (const m of Object.keys(rm.modules || {})) {
    const script = rm.modules[m].targetScript || m;
    for (const f of rm.modules[m].functions || []) {
      byName[f.name.toLowerCase()] = { name: f.name, module: m, script };
    }
  }
  const actionByName = {};
  for (const row of led.rows || []) {
    if (row.kind === "function") actionByName[(row.symbol || "").toLowerCase()] = row.action;
  }
  _cache = { root, byName, actionByName };
  return _cache;
}

// { name, module, script, action } for a function symbol, or null if unknown.
export function symbolHome(name, repoRoot) {
  const d = load(repoRoot);
  const h = d.byName[String(name).toLowerCase()];
  if (!h) return null;
  return { ...h, action: d.actionByName[String(name).toLowerCase()] || "unknown" };
}

export function isRetired(name, repoRoot) {
  const h = symbolHome(name, repoRoot);
  return !!h && h.action === "retire";
}

function esc(s) {
  return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// A RegExp matching a call to `name` with an OPTIONAL owning-script qualifier, so
// it matches bare `Name(` (still in manager / pre-move) or `TargetScript.Name(`
// (post-move). For manager-owned symbols there is no qualifier.
export function callTokenPattern(name, repoRoot, flags) {
  const h = symbolHome(name, repoRoot);
  const n = esc(name);
  if (!h || h.script === MANAGER_SCRIPT) return new RegExp("\\b" + n + "\\s*\\(", flags);
  return new RegExp("(?:" + esc(h.script) + "\\.)?" + n + "\\s*\\(", flags);
}

// The .psc basename where `Function name` currently lives, read from reality:
// if the target script defines it, that; else the manager. sourceDir = the
// Scripts/Source folder to scan. Returns { script, file } (file may be null if
// neither source is present).
export function definitionFile(name, repoRoot, sourceDir) {
  const h = symbolHome(name, repoRoot);
  const target = h ? h.script : MANAGER_SCRIPT;
  const defRe = new RegExp("(^|\\n)\\s*(?:[A-Za-z_][\\w\\[\\]]*\\s+)?Function\\s+" + esc(name) + "\\s*\\(", "i");
  const candidates = target === MANAGER_SCRIPT ? [MANAGER_SCRIPT] : [target, MANAGER_SCRIPT];
  for (const script of candidates) {
    const file = path.join(sourceDir, script + ".psc");
    if (fs.existsSync(file) && defRe.test(fs.readFileSync(file, "utf8"))) return { script, file };
  }
  return { script: target, file: null };
}
