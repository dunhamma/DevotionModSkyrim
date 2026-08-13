#!/usr/bin/env node
/*
 * PDV post-coding hygiene harvest.
 *
 * MECHANICAL ONLY. This script finds CANDIDATES; it decides nothing. Every candidate needs a
 * prior-ruling check and independent verification before it can be called dead -- this repo has a
 * documented history of "dead" findings that were pre-disproven (see the guardrails in
 * PDV_STANDARDS.md "Post-coding hygiene").
 *
 * The point is token economy: the volume work happens here, and the model reads the summary plus
 * the candidate lists rather than 1.2 MB of Papyrus.
 *
 * Usage:
 *   node tools/pdv_hygiene_harvest.mjs [--since <ref>] [--json <path>] [--quiet]
 *
 * Outputs a JSON candidates document (default generated/pdv_hygiene_candidates.json) and prints a
 * short summary. The generated/ directory is gitignored.
 */
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const ROOT = process.cwd();
// Audits must read the source the COMPILER reads. The repo mirror under live-source/ goes stale
// whenever work is done directly in the MO2 tree, and an audit of a stale mirror is a fiction --
// on 2026-08-07 the mirror was up to seven weeks behind on 19 files. Default to the mirror (it is
// what git tracks) but allow PDV_SOURCE_DIR to point at the live tree, and always report which
// one was read so no finding is quotable without its source.
const SOURCE_DIR = process.env.PDV_SOURCE_DIR
  ? path.resolve(process.env.PDV_SOURCE_DIR)
  : path.join(ROOT, "live-source", "Scripts", "Source");
const TOOLS_DIR = path.join(ROOT, "tools");

function parseArgs(argv) {
  const args = { since: "817dd39b", json: path.join(ROOT, "generated", "pdv_hygiene_candidates.json"), quiet: false };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--since") args.since = argv[++i];
    else if (argv[i] === "--json") args.json = path.resolve(argv[++i]);
    else if (argv[i] === "--quiet") args.quiet = true;
    else {
      console.error(`Unknown argument: ${argv[i]}`);
      process.exit(2);
    }
  }
  return args;
}

// Papyrus line comments start with ';'. Block comments are {...} (doc) and ;/ ... /; .
// Stripping matters: a constant named in a comment is NOT a reference, and this repo has been
// bitten by comment text being scanned as code.
function stripComments(text) {
  return text
    .replace(/;\/[\s\S]*?\/;/g, " ")
    .replace(/\{[\s\S]*?\}/g, " ")
    .split(/\r?\n/)
    .map((line) => line.replace(/;.*$/, ""))
    .join("\n");
}

function sourceFiles() {
  return fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));
}

function readSource(file) {
  return fs.readFileSync(path.join(SOURCE_DIR, file), "utf8");
}

/** Every Function/Event block with its line range, per file. */
function functionBlocks(rawText) {
  const lines = rawText.split(/\r?\n/);
  const blocks = [];
  let current = null;
  lines.forEach((line, index) => {
    const open = line.match(/^\s*(?:[A-Za-z_][\w\[\]]*\s+)?(Function|Event)\s+(\w+)\s*\(/i);
    if (open && !current) {
      current = { kind: open[1], name: open[2], start: index + 1 };
      return;
    }
    if (current && new RegExp(`^\\s*End${current.kind}\\b`, "i").test(line)) {
      current.end = index + 1;
      blocks.push(current);
      current = null;
    }
  });
  return blocks;
}

/** git diff hunk line ranges per file, mapped to the functions they touch. */
function changedFunctions(since) {
  const diff = execFileSync("git", ["diff", "-U0", `${since}..HEAD`, "--", "live-source/"], {
    cwd: ROOT, encoding: "utf8", maxBuffer: 64 * 1024 * 1024,
  });
  const touchedByFile = new Map();
  let currentFile = null;
  for (const line of diff.split(/\r?\n/)) {
    const fileMatch = line.match(/^\+\+\+ b\/live-source\/Scripts\/Source\/(.+\.psc)$/i);
    if (fileMatch) { currentFile = fileMatch[1]; continue; }
    if (!currentFile) continue;
    const hunk = line.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/);
    if (!hunk) continue;
    const start = Number(hunk[1]);
    const count = hunk[2] === undefined ? 1 : Number(hunk[2]);
    if (count === 0) continue; // pure deletion; nothing in the new file to review
    if (!touchedByFile.has(currentFile)) touchedByFile.set(currentFile, []);
    touchedByFile.get(currentFile).push([start, start + count - 1]);
  }

  // Hunk line numbers are relative to the file git knows about -- the repo mirror. Mapping them
  // onto a live tree that has drifted by a hundred lines silently selects the WRONG functions.
  // So: resolve hunks to function NAMES against the mirror, then re-locate those names in
  // whichever source is being audited. Name-based mapping is immune to line drift.
  const MIRROR_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
  const out = [];
  for (const [file, ranges] of touchedByFile) {
    const mirrorPath = path.join(MIRROR_DIR, file);
    if (!fs.existsSync(mirrorPath)) continue;
    const mirrorBlocks = functionBlocks(fs.readFileSync(mirrorPath, "utf8"));
    const names = new Set();
    for (const [from, to] of ranges) {
      for (const block of mirrorBlocks) {
        if (block.end === undefined) continue;
        if (from <= block.end && to >= block.start) names.add(block.name);
      }
    }

    const auditPath = path.join(SOURCE_DIR, file);
    const auditBlocks = fs.existsSync(auditPath) ? functionBlocks(fs.readFileSync(auditPath, "utf8")) : [];
    for (const name of names) {
      const live = auditBlocks.find((b) => b.name === name && b.end !== undefined);
      out.push({
        file,
        name,
        kind: live ? live.kind : "unknown",
        start: live ? live.start : null,
        end: live ? live.end : null,
        lines: live ? live.end - live.start + 1 : null,
        // A changed function absent from the audited source is itself worth knowing about:
        // either renamed or deleted since the diff base.
        presentInAuditedSource: Boolean(live),
      });
    }
  }
  return out.sort((a, b) => a.file.localeCompare(b.file) || (a.start ?? 0) - (b.start ?? 0));
}

function harvest(since) {
  const files = sourceFiles();
  const raw = new Map();
  const code = new Map();
  for (const file of files) {
    const text = readSource(file);
    raw.set(file, text);
    code.set(file, stripComments(text));
  }
  const allCode = [...code.values()].join("\n");

  // --- properties declared but never referenced outside their declaration -------------------
  const propertyCandidates = [];
  for (const [file, text] of code) {
    for (const match of text.matchAll(/^\s*([A-Za-z_][\w\[\]]*)\s+Property\s+(\w+)\s+(?:=[^\r\n]*?)?(Auto|AutoReadOnly)\b/gim)) {
      const [, type, name] = match;
      const uses = (allCode.match(new RegExp(`\\b${name}\\b`, "g")) || []).length;
      // 1 = the declaration itself. Full property blocks (non-Auto) are skipped by the regex.
      if (uses <= 1) propertyCandidates.push({ file, name, type });
    }
  }

  // --- functions/events with no call site ---------------------------------------------------
  //
  // FALSE-POSITIVE CLASS, demonstrated 2026-08-07: a PUBLIC SEAM has no in-repo caller BY DESIGN.
  // BeginExternalReactionBatch / ApplyExternalReaction are the API third-party patch scripts call;
  // nothing in Devotion calls them, and deleting them would break every patch that uses the seam.
  // A call-site count cannot see across the mod boundary, so these are split out rather than mixed
  // into the dead pile. Detected from the seam language in the function's own preceding comment --
  // if a seam is not documented as one, it will still land in the plain list and needs the
  // prior-ruling check to catch it.
  const SEAM_MARKERS = /(compatibility seam|neutral seam|third-party|third party|external observer|opt-in patch|public api|patch authors?|called by (?:patch|external|other) )/i;
  const functionCandidates = [];
  const seamCandidates = [];
  for (const [file, text] of raw) {
    const lines = text.split(/\r?\n/);
    for (const block of functionBlocks(text)) {
      if (block.end === undefined) continue;
      if (/^On[A-Z]/.test(block.name)) continue; // engine callbacks
      const calls = (allCode.match(new RegExp(`\\b${block.name}\\s*\\(`, "g")) || []).length;
      if (calls > 1) continue;

      const preamble = lines.slice(Math.max(0, block.start - 13), block.start - 1).join("\n");
      const row = { file, name: block.name, kind: block.kind, start: block.start, lines: block.end - block.start + 1 };
      if (SEAM_MARKERS.test(preamble)) {
        row.seamEvidence = preamble.split(/\r?\n/).filter((l) => SEAM_MARKERS.test(l)).map((l) => l.trim()).slice(0, 2);
        seamCandidates.push(row);
      } else {
        functionCandidates.push(row);
      }
    }
  }

  // --- StorageUtil keys: written-never-read / read-never-written ----------------------------
  const writes = new Map();
  const reads = new Map();
  for (const [file, text] of code) {
    for (const m of text.matchAll(/StorageUtil\.(Set|Adjust)(?:Int|Float|String)Value\s*\(\s*[^,]+,\s*"([^"]+)"/g)) {
      if (!writes.has(m[2])) writes.set(m[2], new Set());
      writes.get(m[2]).add(file);
    }
    for (const m of text.matchAll(/StorageUtil\.Get(?:Int|Float|String)Value\s*\(\s*[^,]+,\s*"([^"]+)"/g)) {
      if (!reads.has(m[1])) reads.set(m[1], new Set());
      reads.get(m[1]).add(file);
    }
  }
  const writtenNeverRead = [...writes.keys()].filter((k) => !reads.has(k)).sort();
  const readNeverWritten = [...reads.keys()].filter((k) => !writes.has(k)).sort();

  // --- retired / inert / legacy scaffolding markers ------------------------------------------
  const MARKERS = /(retained for (?:save|script)|retired|deliberately inert|remains inert|legacy|superseded|no longer used|vestigial|deprecated)/i;
  const scaffolding = [];
  for (const [file, text] of raw) {
    const lines = text.split(/\r?\n/);
    const blocks = functionBlocks(text);
    lines.forEach((line, index) => {
      if (!MARKERS.test(line)) return;
      if (!/^\s*;/.test(line)) return; // comment lines only
      const lineNo = index + 1;
      const owner = blocks.find((b) => b.end !== undefined && lineNo >= b.start - 12 && lineNo <= b.end);
      scaffolding.push({ file, line: lineNo, owner: owner ? owner.name : "(file scope)", text: line.trim().slice(0, 200) });
    });
  }

  // --- tools nothing references --------------------------------------------------------------
  const toolFiles = fs.readdirSync(TOOLS_DIR).filter((f) => /\.mjs$/i.test(f));
  const corpus = [];
  const scanDirs = [ROOT, path.join(ROOT, "tools"), path.join(ROOT, "references", "authoring"), path.join(ROOT, "tools", "lib")];
  for (const dir of scanDirs) {
    if (!fs.existsSync(dir)) continue;
    for (const entry of fs.readdirSync(dir)) {
      const full = path.join(dir, entry);
      if (!fs.statSync(full).isFile()) continue;
      if (!/\.(mjs|json|md|ps1|txt)$/i.test(entry)) continue;
      corpus.push({ name: entry, text: fs.readFileSync(full, "utf8") });
    }
  }
  const unreferencedTools = toolFiles.filter((tool) => {
    const hits = corpus.filter((doc) => doc.name !== tool && doc.text.includes(tool));
    return hits.length === 0;
  });

  return {
    generatedFrom: since,
    sourceDir: SOURCE_DIR,
    sourceIsLiveTree: !SOURCE_DIR.includes(path.join("live-source", "Scripts")),
    changedFunctions: changedFunctions(since),
    candidates: {
      unreferencedProperties: propertyCandidates,
      uncalledFunctions: functionCandidates,
      publicSeamsNoInRepoCaller: seamCandidates,
      storageKeysWrittenNeverRead: writtenNeverRead,
      storageKeysReadNeverWritten: readNeverWritten,
      unreferencedTools,
    },
    retiredScaffolding: scaffolding,
  };
}

const args = parseArgs(process.argv.slice(2));
const report = harvest(args.since);
fs.mkdirSync(path.dirname(args.json), { recursive: true });
fs.writeFileSync(args.json, `${JSON.stringify(report, null, 2)}\n`);

if (!args.quiet) {
  const c = report.candidates;
  console.log("PDV hygiene harvest");
  console.log(`  source read                  : ${report.sourceDir}`);
  console.log(`  source is live MO2 tree      : ${report.sourceIsLiveTree ? "YES" : "no (repo mirror -- verify it is not stale)"}`);
  console.log(`  since ref                    : ${report.generatedFrom}`);
  console.log(`  changed functions            : ${report.changedFunctions.length}`);
  console.log(`  unreferenced properties      : ${c.unreferencedProperties.length}`);
  console.log(`  uncalled functions/events    : ${c.uncalledFunctions.length}`);
  console.log(`  public seams (no repo caller): ${c.publicSeamsNoInRepoCaller.length}  <- NOT dead; third-party API`);
  console.log(`  storage keys write-never-read: ${c.storageKeysWrittenNeverRead.length}`);
  console.log(`  storage keys read-never-write: ${c.storageKeysReadNeverWritten.length}`);
  console.log(`  unreferenced tools           : ${c.unreferencedTools.length}`);
  console.log(`  retired-scaffolding markers  : ${report.retiredScaffolding.length}`);
  console.log("");
  console.log(`CANDIDATES ONLY -- nothing here is a finding until a prior-ruling check and`);
  console.log(`independent verification have both passed. Written to ${args.json}`);
}
