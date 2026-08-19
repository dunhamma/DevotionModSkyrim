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
  const family = [MANAGER_SCRIPT];
  for (const m of Object.keys(rm.modules || {})) {
    const script = rm.modules[m].targetScript || m;
    if (!family.includes(script)) family.push(script);
    for (const f of rm.modules[m].functions || []) {
      byName[f.name.toLowerCase()] = { name: f.name, module: m, script };
    }
  }
  const actionByName = {};
  for (const row of led.rows || []) {
    if (row.kind === "function") actionByName[(row.symbol || "").toLowerCase()] = row.action;
  }
  _cache = { root, byName, actionByName, family };
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

// The manager's decomposition family: the manager plus every module targetScript.
// A gate that pins a needle to the manager can search this family so the needle
// tracks a symbol wherever the extraction moved it (durable across future moves).
export function decompositionFamily(repoRoot) {
  return load(repoRoot).family.slice();
}

// Strip backref / forward-ref qualifiers (Manager. / PDV_Manager. / <X>Runtime. /
// <X>RuntimeService.) so a needle matches regardless of the qualification a symbol
// picks up when it moves across the module boundary. Same qualifier-agnostic
// posture as callTokenPattern().
export function stripQualifiers(s) {
  return String(s).replace(/\b(?:PDV_Manager|Manager|[A-Za-z_]\w*Runtime(?:Service)?)\./g, "");
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

// Concatenated source text of the manager's decomposition family, for gates that
// read manager source and then search it for a function body or a call needle.
//
// The problem this solves: as functions move out of PDV__ManagerQuest.psc into
// deep modules, a gate that reads ONLY the manager goes blind. The body is simply
// absent, so every positive needle fails and every negated needle passes
// vacuously -- the gate reports a wall of red (or, worse, a quiet green) about
// code that is present and correct, just somewhere else.
//
// STRICTLY ADDITIVE, same posture as callTokenPattern(): the raw manager text is
// emitted FIRST and verbatim, so any needle that matched before this helper
// existed still matches at the same offset semantics. Module text is appended
// with qualifiers stripped, because a moved body calls Manager.X() where it used
// to call X(). Family scripts not yet extracted are skipped, so the same call is
// correct before AND after each future extraction -- no per-move hand-patching.
const _familyTextCache = new Map();
export function familySourceText(repoRoot, sourceDir) {
  const root = path.resolve(repoRoot);
  const dir = path.resolve(sourceDir);
  const key = root + "|" + dir;
  if (_familyTextCache.has(key)) return _familyTextCache.get(key);
  const parts = [];
  // A module may be SPLIT into sibling scripts the region map does not name -- ORIGIN is one
  // base plus ten PDV_OriginRuntime_<Race> adapters. Those carry real moved bodies, so a family
  // that stops at the region map's targetScript is blind to them and gates silently under-count.
  // The split scripts share the module's STEM, not its full name: the base is
  // PDV_OriginRuntimeBase but the adapters are PDV_OriginRuntime_<Race>, so a trailing "Base"
  // has to come off before matching.
  const siblingsOf = (script) => {
    const stems = [script, script.replace(/Base$/, "")];
    try {
      const files = fs.readdirSync(dir).filter((f) => f.endsWith(".psc"));
      const out = [];
      for (const stem of stems) {
        for (const f of files) {
          const name = f.slice(0, -4);
          if (name !== script && name.startsWith(stem + "_") && !out.includes(name)) out.push(name);
        }
      }
      return out;
    } catch { return []; }
  };
  const scripts = [];
  for (const script of decompositionFamily(root)) {
    scripts.push(script);
    for (const sib of siblingsOf(script)) if (!scripts.includes(sib)) scripts.push(sib);
  }
  for (const script of scripts) {
    const file = path.join(dir, script + ".psc");
    if (!fs.existsSync(file)) continue;
    const text = fs.readFileSync(file, "utf8");
    parts.push(script === MANAGER_SCRIPT ? text : stripQualifiers(text));
  }
  const out = parts.join("\n");
  _familyTextCache.set(key, out);
  return out;
}
