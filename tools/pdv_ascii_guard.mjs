#!/usr/bin/env node
/*
 * pdv_ascii_guard.mjs - Detect (and optionally fix) non-ASCII characters in PDV
 * source files before they reach Codex as mojibake.
 *
 * WHY THIS EXISTS
 * LLM-authored comments routinely contain "smart" punctuation: em dashes (U+2014),
 * curly quotes (U+2018/2019/201C/201D), ellipses (U+2026), arrows (U+2192). In
 * UTF-8 those are multi-byte. The instant any Windows-1252-assuming tool reads or
 * re-saves the file, the bytes garble: an em dash (E2 80 94) turns into a 3-char
 * "a-Euro-quote" sequence. Papyrus source is expected to be ASCII, so the safe,
 * checkable rule is: every code point in a .psc file is <= 0x7F.
 * This guard makes that rule enforceable instead of a prose convention.
 *
 * USAGE
 *   node tools/pdv_ascii_guard.mjs [paths...]         Report offenders; exit 1 if any.
 *   node tools/pdv_ascii_guard.mjs --fix [paths...]   Auto-replace known offenders in place.
 *   node tools/pdv_ascii_guard.mjs --hook             PostToolUse hook mode (reads stdin JSON).
 *   node tools/pdv_ascii_guard.mjs --ext .psc,.md ... Restrict/extend scanned extensions.
 *
 * When no paths are given, defaults to the live deployed Devotion script source.
 * Replacements produce only ASCII, so --fix is idempotent (re-running is a no-op).
 *
 * This file is deliberately written with numeric code-point comparisons and no
 * non-ASCII literals, so it passes its own check.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--ext", "--exts", "--fix", "--help", "--hook", "--summary"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_ascii_guard" });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");

// Same live source the compiler wrapper targets (keep in sync with pdv_compile.mjs).
const ANVIL_ROOT = process.env.PDV_ANVIL_ROOT || "D:/Wabbajack/modlists/Anvil";
const DEFAULT_SOURCE = path.join(ANVIL_ROOT, "mods", "Devotion", "Scripts", "Source");

// ASCII-safe replacements for the characters an LLM (or Office paste) actually
// emits. Keyed by code point. Anything non-ASCII NOT in this map is reported but
// left untouched by --fix (flagged "no auto-fix") so a human decides.
const REPLACEMENTS = new Map([
  [0x2010, "-"],    // hyphen
  [0x2011, "-"],    // non-breaking hyphen
  [0x2012, "-"],    // figure dash
  [0x2013, "-"],    // en dash
  [0x2014, "--"],   // em dash
  [0x2015, "--"],   // horizontal bar
  [0x2212, "-"],    // minus sign
  [0x2018, "'"],    // left single quote
  [0x2019, "'"],    // right single quote / curly apostrophe
  [0x201a, "'"],    // single low-9 quote
  [0x201b, "'"],    // single high-reversed-9 quote
  [0x2032, "'"],    // prime
  [0x201c, '"'],    // left double quote
  [0x201d, '"'],    // right double quote
  [0x201e, '"'],    // double low-9 quote
  [0x2033, '"'],    // double prime
  [0x2026, "..."],  // horizontal ellipsis
  [0x2190, "<-"],   // leftwards arrow
  [0x2192, "->"],   // rightwards arrow
  [0x2194, "<->"],  // left-right arrow
  [0x21d2, "=>"],   // rightwards double arrow
  [0x2022, "-"],    // bullet
  [0x2023, "-"],    // triangular bullet
  [0x25cf, "-"],    // black circle
  [0x00b7, "-"],    // middle dot
  [0x00d7, "x"],    // multiplication sign
  [0x00a9, "(C)"],  // copyright
  [0x00ae, "(R)"],  // registered
  [0x2122, "(TM)"], // trademark
  [0x00bc, "1/4"],  // one quarter
  [0x00bd, "1/2"],  // one half
  [0x00be, "3/4"],  // three quarters
  // Whitespace / invisible offenders -> space or removed.
  [0x00a0, " "],    // non-breaking space
  [0x2007, " "],    // figure space
  [0x2009, " "],    // thin space
  [0x202f, " "],    // narrow no-break space
  [0xfeff, ""],     // BOM / zero-width no-break space
  [0x200b, ""],     // zero-width space
  [0x200e, ""],     // left-to-right mark
  [0x200f, ""],     // right-to-left mark
]);

const NAMES = new Map([
  [0x2014, "em dash"], [0x2013, "en dash"], [0x2012, "figure dash"],
  [0x2018, "left single quote"], [0x2019, "right single quote"],
  [0x201c, "left double quote"], [0x201d, "right double quote"],
  [0x2026, "ellipsis"], [0x2192, "right arrow"], [0x2190, "left arrow"],
  [0x2022, "bullet"], [0x00a0, "non-breaking space"], [0xfeff, "BOM"],
  [0x00d7, "multiplication sign"], [0x2122, "trademark"],
]);

const ASCII_MAX = 0x7f;

function parseArgs(argv) {
  const opts = { fix: false, hook: false, summary: false, exts: [".psc"], paths: [] };
  const splitExts = (s) => (s || "").split(",").map((e) => (e.startsWith(".") ? e : "." + e)).filter(Boolean);
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--fix") opts.fix = true;
    else if (a === "--hook") opts.hook = true;
    else if (a === "--summary") opts.summary = true;
    else if (a === "--ext" || a === "--exts") opts.exts = splitExts(argv[++i]);
    else if (a.startsWith("--ext=")) opts.exts = splitExts(a.slice("--ext=".length));
    else if (a === "--help" || a === "-h") opts.help = true;
    else opts.paths.push(a);
  }
  return opts;
}

function codeStr(cp) {
  return "U+" + cp.toString(16).toUpperCase().padStart(4, "0");
}

function describe(cp) {
  const name = NAMES.get(cp);
  return name ? `${codeStr(cp)} (${name})` : codeStr(cp);
}

// Heuristic for text that is ALREADY double-encoded (UTF-8 bytes read as Latin-1),
// e.g. an accented char left as a 0xC3 lead byte + trailing high byte, or the
// 0xE2/0x80 lead of a garbled em dash. Pure numeric checks, no non-ASCII literals.
function looksDoubleEncoded(text) {
  for (let i = 0; i < text.length - 1; i++) {
    const a = text.charCodeAt(i);
    const b = text.charCodeAt(i + 1);
    if ((a === 0x00c2 || a === 0x00c3) && b >= 0x0080 && b <= 0x00bf) return true; // "A-tilde" + trailing
    if (a === 0x00e2 && (b === 0x20ac || b === 0x0080)) return true;               // "a-circumflex" + Euro/control
  }
  return false;
}

function walk(target, exts, out) {
  let stat;
  try {
    stat = fs.statSync(target);
  } catch {
    return;
  }
  if (stat.isDirectory()) {
    for (const entry of fs.readdirSync(target)) walk(path.join(target, entry), exts, out);
  } else if (stat.isFile()) {
    if (exts.length === 0 || exts.includes(path.extname(target).toLowerCase())) out.push(target);
  }
}

// Returns { findings:[{line,col,cp,char,fixable,replacement}], doubleEncoded }.
function scanText(text) {
  const findings = [];
  const lines = text.split(/\r?\n/);
  for (let li = 0; li < lines.length; li++) {
    let col = 0;
    for (const ch of lines[li]) {
      col++;
      const cp = ch.codePointAt(0);
      if (cp > ASCII_MAX) {
        const fixable = REPLACEMENTS.has(cp);
        findings.push({ line: li + 1, col, cp, char: ch, fixable, replacement: fixable ? REPLACEMENTS.get(cp) : null });
      }
    }
  }
  return { findings, doubleEncoded: looksDoubleEncoded(text) };
}

function applyFix(text) {
  let unfixable = 0;
  let out = "";
  for (const ch of text) {
    const cp = ch.codePointAt(0);
    if (cp <= ASCII_MAX) {
      out += ch;
    } else if (REPLACEMENTS.has(cp)) {
      out += REPLACEMENTS.get(cp);
    } else {
      unfixable++;
      out += ch;
    }
  }
  return { fixed: out, changed: out !== text, unfixable };
}

function rel(p) {
  const r = path.relative(PROJECT_ROOT, p);
  return r.startsWith("..") ? p : r;
}

// ---- Hook mode: read PostToolUse stdin JSON, scan the written file, block if dirty.
async function runHook() {
  const raw = await new Promise((resolve) => {
    let buf = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (d) => (buf += d));
    process.stdin.on("end", () => resolve(buf));
    process.stdin.on("error", () => resolve(buf));
  });
  let file = null;
  try {
    const payload = JSON.parse(raw || "{}");
    file = payload?.tool_input?.file_path || payload?.tool_input?.path || null;
  } catch {
    process.exit(0); // Not parseable -> do not interfere.
  }
  if (!file || path.extname(file).toLowerCase() !== ".psc") process.exit(0);
  let text;
  try {
    text = fs.readFileSync(file, "utf8");
  } catch {
    process.exit(0);
  }
  const { findings } = scanText(text);
  if (findings.length === 0) process.exit(0);
  const shown = findings.slice(0, 20).map((f) => {
    const sug = f.fixable ? `replace with "${f.replacement}"` : "no auto-fix - choose an ASCII equivalent";
    return `  line ${f.line}, col ${f.col}: ${describe(f.cp)} -> ${sug}`;
  });
  const more = findings.length > 20 ? `\n  ...and ${findings.length - 20} more` : "";
  process.stderr.write(
    `Non-ASCII characters in ${path.basename(file)} will become mojibake when read as Windows-1252.\n` +
      `Replace them with ASCII before this file is handed to Codex:\n` +
      shown.join("\n") +
      more +
      `\n(To auto-correct the known ones: node tools/pdv_ascii_guard.mjs --fix "${file}")\n`
  );
  process.exit(2); // Block: feed stderr back so the offending characters get fixed.
}

function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    const header = fs.readFileSync(fileURLToPath(import.meta.url), "utf8").split("*/")[0];
    console.log(header.replace(/^\/\*+/, "").trim());
    process.exit(0);
  }
  if (opts.hook) {
    runHook();
    return;
  }
  const targets = opts.paths.length ? opts.paths : [DEFAULT_SOURCE];
  const files = [];
  for (const t of targets) walk(path.resolve(t), opts.exts, files);
  if (files.length === 0) {
    console.error(`No matching files (${opts.exts.join(", ")}) under: ${targets.join(", ")}`);
    process.exit(2);
  }

  let totalFindings = 0;
  let totalFixed = 0;
  let totalUnfixable = 0;
  const dirtyFiles = [];

  for (const file of files.sort()) {
    let text;
    try {
      text = fs.readFileSync(file, "utf8");
    } catch (err) {
      console.error(`! Could not read ${rel(file)}: ${err.message}`);
      continue;
    }
    const { findings, doubleEncoded } = scanText(text);
    if (findings.length === 0) continue;

    totalFindings += findings.length;
    dirtyFiles.push(file);
    const flag = doubleEncoded ? "  [LOOKS ALREADY DOUBLE-ENCODED - review by hand]" : "";
    console.log(`\n${rel(file)}  (${findings.length} non-ASCII)${flag}`);
    if (!opts.summary) {
      for (const f of findings) {
        const sug = f.fixable ? `-> "${f.replacement}"` : "-> (no auto-fix)";
        console.log(`  ${f.line}:${f.col}  ${describe(f.cp)}  '${f.char}'  ${sug}`);
      }
    }

    if (opts.fix) {
      const { fixed, changed, unfixable } = applyFix(text);
      totalUnfixable += unfixable;
      if (changed) {
        fs.writeFileSync(file, fixed, "utf8"); // ASCII content, no BOM
        totalFixed++;
        const note = unfixable ? `  (${unfixable} char(s) left for manual review)` : "";
        console.log(`  fixed -> wrote ${rel(file)}${note}`);
      }
    }
  }

  console.log("");
  if (totalFindings === 0) {
    console.log(`OK: ${files.length} file(s) scanned, all ASCII-clean.`);
    process.exit(0);
  }
  if (opts.fix) {
    console.log(`Fixed ${totalFixed} file(s); ${totalFindings} occurrence(s) found, ${totalUnfixable} left for manual review.`);
    process.exit(totalUnfixable > 0 ? 1 : 0);
  }
  console.log(`FAIL: ${totalFindings} non-ASCII occurrence(s) in ${dirtyFiles.length} file(s). Re-run with --fix to auto-correct the known ones.`);
  process.exit(1);
}

main();
