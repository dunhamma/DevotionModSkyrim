#!/usr/bin/env node
/*
 * pdv_parity_snapshot.mjs -- static behavior-parity harness for the 2.0 rebuild.
 *
 * The rebuild MOVES functions out of the 28k-line PDV__ManagerQuest.psc into deep
 * modules under STRICT BEHAVIOR PARITY: a moved function's body must be the same
 * logic, only relocated. This tool fingerprints every function/event body (line
 * and block comments stripped, respecting string literals; trailing whitespace
 * and blank lines normalized) so a "pure move" can be proven to have changed
 * nothing, and any real body change is surfaced.
 *
 * Fingerprint key = <container>.<name> (container = enclosing State or Property,
 * else GLOBAL) so Get/Set and per-state handlers do not collide. It spans the
 * declaration line through End* inclusive, so a signature change is caught too.
 *
 * Usage:
 *   node tools/pdv_parity_snapshot.mjs --snapshot <out.json> <file-or-dir> [...]
 *   node tools/pdv_parity_snapshot.mjs --compare <golden.json> <current.json>
 *
 * --compare classifies each function: UNCHANGED (same fingerprint, same file),
 * MOVED (same fingerprint, new file -- the pure-move success case), CHANGED
 * (fingerprint differs -- a body edit; expected only for delegation rewrites at
 * call sites, verify each is call-site-only), REMOVED (gone -- must be a ledger
 * retire), ADDED (new -- module scaffolding / delegation shims). Exits 1 if any
 * CHANGED or REMOVED unless --allow-changed / --allow-removed is passed (used
 * once the ledger accounts for them).
 */

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

// ---- comment stripping (respects "..." strings and ;/ ... /; block comments) ----
function makeStripper() {
  let inBlock = false;
  return function strip(line) {
    let out = "";
    let i = 0;
    let inString = false;
    while (i < line.length) {
      const c = line[i];
      const c2 = line[i + 1];
      if (inBlock) {
        // Inside a ;/ ... /; block comment: consume until the "/;" close.
        if (line.startsWith("/;", i)) { inBlock = false; i += 2; continue; }
        i++;
        continue;
      }
      if (inString) {
        out += c;
        if (c === '"') inString = false;
        i++;
        continue;
      }
      if (c === '"') { inString = true; out += c; i++; continue; }
      if (c === ";" && c2 === "/") {
        // block comment open; does it close on this same line?
        const close = line.indexOf("/;", i + 2);
        if (close === -1) { inBlock = true; break; }
        i = close + 2;
        continue;
      }
      if (c === ";") break; // line comment
      out += c;
      i++;
    }
    return out;
  };
}

const RE_FUNC = /^\s*(?:[A-Za-z_][A-Za-z0-9_\[\]]*\s+)?Function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/i;
const RE_EVENT = /^\s*Event\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/i;
const RE_END_FUNC = /^\s*EndFunction\b/i;
const RE_END_EVENT = /^\s*EndEvent\b/i;
const RE_STATE = /^\s*(?:Auto\s+)?State\s+([A-Za-z_][A-Za-z0-9_]*)/i;
const RE_END_STATE = /^\s*EndState\b/i;
const RE_PROP = /^\s*[A-Za-z_][A-Za-z0-9_\[\]]*\s+Property\s+([A-Za-z_][A-Za-z0-9_]*)/i;
const RE_END_PROP = /^\s*EndProperty\b/i;
const RE_NATIVE = /\bNative\b/i;
const RE_AUTO = /\b(?:Auto|AutoReadOnly|Conditional)\b/i;

function normLine(code) {
  return code.replace(/\s+$/g, "");
}

function parseFile(absPath, relPath) {
  const raw = fs.readFileSync(absPath, "utf8");
  const lines = raw.split(/\r?\n/);
  const strip = makeStripper();
  const funcs = {};
  let container = null; // enclosing State or Property name (with prefix)
  let stateName = null;
  let propName = null;
  let cur = null; // active function capture

  for (let n = 0; n < lines.length; n++) {
    const rawLine = lines[n];
    const code = strip(rawLine);

    if (cur) {
      cur.bodyNorm.push(normLine(code));
      if ((cur.kind === "function" && RE_END_FUNC.test(code)) ||
          (cur.kind === "event" && RE_END_EVENT.test(code))) {
        cur.endLine = n + 1;
        const kept = cur.bodyNorm.filter((l) => l.trim() !== "");
        const body = kept.join("\n");
        const bodyOnly = kept.slice(1).join("\n"); // exclude the declaration line (first kept line)
        const key = (cur.container ? cur.container + "." : "") + cur.name;
        funcs[key] = {
          key, name: cur.name, container: cur.container || "GLOBAL",
          file: relPath, startLine: cur.startLine, endLine: cur.endLine,
          loc: cur.endLine - cur.startLine + 1,
          fingerprint: crypto.createHash("sha256").update(body).digest("hex").slice(0, 16),
          bodyFingerprint: crypto.createHash("sha256").update(bodyOnly).digest("hex").slice(0, 16),
        };
        cur = null;
      }
      continue;
    }

    // structural containers
    if (propName === null && RE_STATE.test(code)) { stateName = code.match(RE_STATE)[1]; container = "State_" + stateName; continue; }
    if (stateName !== null && RE_END_STATE.test(code)) { stateName = null; container = null; continue; }
    if (stateName === null && RE_PROP.test(code) && !RE_AUTO.test(code)) { propName = code.match(RE_PROP)[1]; container = "Prop_" + propName; continue; }
    if (propName !== null && RE_END_PROP.test(code)) { propName = null; container = null; continue; }

    // function / event start
    let m = code.match(RE_FUNC);
    let kind = m ? "function" : null;
    if (!m) { m = code.match(RE_EVENT); kind = m ? "event" : null; }
    if (m) {
      if (kind === "function" && RE_NATIVE.test(code)) continue; // native decl, no body
      cur = { kind, name: m[1], container, startLine: n + 1, endLine: null, bodyNorm: [normLine(code)] };
    }
  }
  return funcs;
}

function collectFiles(targets) {
  const out = [];
  for (const t of targets) {
    const st = fs.statSync(t);
    if (st.isDirectory()) {
      for (const f of fs.readdirSync(t)) {
        if (f.toLowerCase().endsWith(".psc")) out.push(path.join(t, f));
      }
    } else if (t.toLowerCase().endsWith(".psc")) {
      out.push(t);
    }
  }
  return out;
}

function snapshot(outPath, targets) {
  const files = collectFiles(targets);
  const cwd = process.cwd();
  const functions = {};
  const collisions = [];
  const byFile = {};
  for (const f of files) {
    const rel = path.relative(cwd, f).replace(/\\/g, "/");
    const fns = parseFile(f, rel);
    byFile[rel] = Object.keys(fns).length;
    for (const [k, v] of Object.entries(fns)) {
      if (functions[k]) collisions.push({ key: k, files: [functions[k].file, v.file] });
      functions[k] = v;
    }
  }
  const snap = {
    schema: "pdv-parity-snapshot/1",
    sources: files.map((f) => path.relative(cwd, f).replace(/\\/g, "/")),
    counts: { functions: Object.keys(functions).length, byFile },
    collisions,
    functions,
  };
  fs.writeFileSync(outPath, JSON.stringify(snap, null, 2) + "\n");
  console.log(`[snapshot] ${Object.keys(functions).length} functions across ${files.length} file(s) -> ${outPath}`);
  if (collisions.length) console.log(`[warn] ${collisions.length} key collision(s) (same container.name in >1 file) -- inspect "collisions"`);
  return snap;
}

function compare(goldenPath, currentPath, opts) {
  const g = JSON.parse(fs.readFileSync(goldenPath, "utf8")).functions;
  const c = JSON.parse(fs.readFileSync(currentPath, "utf8")).functions;
  const res = { unchanged: [], moved: [], changed: [], removed: [], added: [] };
  for (const [k, gv] of Object.entries(g)) {
    const cv = c[k];
    if (!cv) { res.removed.push(k); continue; }
    const gf = opts.bodyOnly ? gv.bodyFingerprint : gv.fingerprint;
    const cf = opts.bodyOnly ? cv.bodyFingerprint : cv.fingerprint;
    if (cf === gf) {
      (cv.file === gv.file ? res.unchanged : res.moved).push({ key: k, from: gv.file, to: cv.file });
    } else {
      res.changed.push({ key: k, from: gv.file, to: cv.file });
    }
  }
  for (const k of Object.keys(c)) if (!g[k]) res.added.push(k);

  console.log(`[compare] unchanged=${res.unchanged.length} moved=${res.moved.length} changed=${res.changed.length} removed=${res.removed.length} added=${res.added.length}`);
  if (res.moved.length) console.log("  MOVED (pure-move OK):\n" + res.moved.map((x) => `    ${x.key}: ${x.from} -> ${x.to}`).join("\n"));
  if (res.changed.length) console.log("  CHANGED (verify each is call-site-only delegation):\n" + res.changed.map((x) => `    ${x.key} @ ${x.to}`).join("\n"));
  if (res.removed.length) console.log("  REMOVED (must be a ledger retire):\n" + res.removed.map((x) => `    ${x}`).join("\n"));
  if (res.added.length) console.log("  ADDED:\n" + res.added.map((x) => `    ${x}`).join("\n"));

  const fail = (res.changed.length && !opts.allowChanged) || (res.removed.length && !opts.allowRemoved);
  process.exitCode = fail ? 1 : 0;
  return res;
}

function main() {
  const argv = process.argv.slice(2);
  const opts = { allowChanged: argv.includes("--allow-changed"), allowRemoved: argv.includes("--allow-removed"), bodyOnly: argv.includes("--body-only") };
  const rest = argv.filter((a) => !a.startsWith("--allow") && a !== "--body-only");
  if (rest[0] === "--snapshot") {
    if (rest.length < 3) { console.error("usage: --snapshot <out.json> <file-or-dir>..."); process.exit(2); }
    snapshot(rest[1], rest.slice(2));
  } else if (rest[0] === "--compare") {
    if (rest.length !== 3) { console.error("usage: --compare <golden.json> <current.json>"); process.exit(2); }
    compare(rest[1], rest[2], opts);
  } else {
    console.error("usage:\n  --snapshot <out.json> <file-or-dir>...\n  --compare <golden.json> <current.json> [--allow-changed] [--allow-removed]");
    process.exit(2);
  }
}

main();
