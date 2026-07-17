#!/usr/bin/env node
// pdv_guide_bbcode.mjs
//
// Converts the finished player guides into Nexus-Mods-ready BBCode at
// dist/nexus-articles/*.bb, for pasting straight into a Nexus article or mod
// description. Sources: the ten race guides (docs/player-guides/races/*.md) plus
// the non-race guides listed in DOCS (the mod page description).
//
// Why not just paste the Markdown: Nexus's editor speaks BBCode, and its BBCode
// dialect has NO table tag. A Markdown table pasted into Nexus renders as a wall
// of pipes. Tables are therefore rewritten as native [list] blocks, which is both
// supported everywhere and more readable on a narrow mod page.
//
// Usage:
//   node tools/pdv_guide_bbcode.mjs            # convert every guide
//   node tools/pdv_guide_bbcode.mjs --check    # verify only; non-zero exit on problems

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const GUIDES_DIR = path.join(ROOT, 'docs', 'player-guides');
const SRC_DIR = path.join(GUIDES_DIR, 'races');
const OUT_DIR = path.join(ROOT, 'dist', 'nexus-articles');

const RACES = ['Altmer', 'Argonian', 'Bosmer', 'Breton', 'Dunmer', 'Imperial', 'Khajiit', 'Nord', 'Orc', 'Redguard'];

// Guides that are not per-race but ship through the same converter and the same
// gate. The mod page description is one of these: Nexus speaks the same BBCode
// for a description as for an article, so it gets the same staleness/ASCII/
// review-tag checks instead of being hand-maintained and drifting unwatched.
const DOCS = [{ name: 'ModPage', src: path.join(GUIDES_DIR, 'Nexus_ModPage.md') }];

const TARGETS = [
  ...RACES.map((race) => ({ name: race, src: path.join(SRC_DIR, `${race}.md`) })),
  ...DOCS,
];

const normalizeEol = (s) => s.replace(/\r\n/g, '\n');

/** Inline Markdown -> BBCode. Order matters: bold before italic so ** is not eaten by *. */
function inline(text) {
  return text
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '[url=$2]$1[/url]')
    .replace(/\*\*(.+?)\*\*/g, '[b]$1[/b]')
    .replace(/(^|[^*])\*(?!\s)([^*]+?)\*(?!\*)/g, '$1[i]$2[/i]')
    .replace(/`([^`]+)`/g, '$1'); // no code spans in shipped player copy
}

/** A Markdown table -> a BBCode [list]. First column becomes the bolded lead-in. */
function tableToList(rows) {
  const cells = (line) => line.split('|').slice(1, -1).map((c) => c.trim());
  const body = rows.slice(2); // skip header + separator
  const out = ['[list]'];
  for (const row of body) {
    const c = cells(row);
    if (!c.length) continue;
    const lead = inline(c[0]);
    const rest = c.slice(1).map(inline).filter((x) => x && x !== '-');
    if (!rest.length) {
      out.push(`[*][b]${lead}[/b]`);
    } else if (rest.length === 1) {
      out.push(`[*][b]${lead}[/b] - ${rest[0]}`);
    } else {
      // e.g. Tier | Blessing | What you get  ->  **Seeker (25)** *Khenarthi's Road* - Fortify Stamina +15
      out.push(`[*][b]${lead}[/b] [i]${rest[0]}[/i] - ${rest.slice(1).join(' - ')}`);
    }
  }
  out.push('[/list]');
  return out;
}

function convert(markdown) {
  const lines = markdown.split(/\r?\n/);
  const out = [];
  const problems = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // A player must never see review scaffolding or an internal identifier.
    if (/<!--/.test(line)) {
      problems.push(`HTML comment survived into shipped copy: ${line.trim().slice(0, 60)}`);
      i++;
      continue;
    }
    if (/\[(WIRED|QUEST|PARTIAL|STUB|INERT)\b/.test(line)) {
      problems.push(`review tag survived into shipped copy: ${line.trim().slice(0, 60)}`);
    }

    // Table block
    if (/^\s*\|/.test(line) && /^\s*\|[\s:|-]+\|\s*$/.test(lines[i + 1] || '')) {
      const rows = [];
      while (i < lines.length && /^\s*\|/.test(lines[i])) rows.push(lines[i++]);
      out.push(...tableToList(rows));
      continue;
    }

    // Headings
    let m;
    if ((m = line.match(/^#\s+(.*)$/))) out.push(`[size=6][b]${inline(m[1])}[/b][/size]`);
    else if ((m = line.match(/^##\s+(.*)$/))) out.push(`[size=5][b]${inline(m[1])}[/b][/size]`);
    else if ((m = line.match(/^###\s+(.*)$/))) out.push(`[size=4][b]${inline(m[1])}[/b][/size]`);
    // Bullets -- collect a contiguous run into one [list]
    else if (/^\s*[-*]\s+/.test(line)) {
      out.push('[list]');
      while (i < lines.length && /^\s*[-*]\s+/.test(lines[i])) {
        out.push(`[*]${inline(lines[i].replace(/^\s*[-*]\s+/, ''))}`);
        i++;
      }
      out.push('[/list]');
      continue;
    }
    // Numbered runs -- [list=1] is the ordered list Nexus renders. Without this
    // the digits survive as literal text in an unstyled paragraph.
    else if (/^\s*\d+\.\s+/.test(line)) {
      out.push('[list=1]');
      while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
        out.push(`[*]${inline(lines[i].replace(/^\s*\d+\.\s+/, ''))}`);
        i++;
      }
      out.push('[/list]');
      continue;
    } else if (/^---+\s*$/.test(line)) out.push('[line]');
    else out.push(inline(line));

    i++;
  }

  // Collapse the blank-line runs BBCode would render as dead space.
  const text = out.join('\n').replace(/\n{3,}/g, '\n\n').trim() + '\n';
  return { text, problems };
}

const check = process.argv.includes('--check');
if (!check) fs.mkdirSync(OUT_DIR, { recursive: true });

let failed = 0;
for (const { name: race, src } of TARGETS) {
  if (!fs.existsSync(src)) {
    console.error(`MISSING ${path.relative(ROOT, src)}`);
    failed++;
    continue;
  }
  const md = fs.readFileSync(src, 'utf8');
  const { text, problems } = convert(md);

  // Shipped player copy is ASCII-only (hard project rule).
  const nonAscii = [...text].filter((ch) => ch.charCodeAt(0) > 127);
  if (nonAscii.length) problems.push(`${nonAscii.length} non-ASCII char(s): ${[...new Set(nonAscii)].join(' ')}`);

  if (problems.length) {
    failed++;
    console.error(`FAIL ${race}`);
    for (const p of problems) console.error(`   - ${p}`);
  } else {
    console.log(`ok   ${race}  (${text.length} chars)`);
  }
  const outPath = path.join(OUT_DIR, `${race}.bb`);
  if (check) {
    if (!fs.existsSync(outPath)) {
      failed++;
      console.error(`FAIL ${race}: generated BBCode is missing (${path.relative(ROOT, outPath)})`);
      // Compare on content, not bytes: a checkout under core.autocrlf can hand us
      // CRLF while we always write LF, and that must not read as a stale artifact.
    } else if (normalizeEol(fs.readFileSync(outPath, 'utf8')) !== normalizeEol(text)) {
      failed++;
      console.error(`FAIL ${race}: generated BBCode is stale (${path.relative(ROOT, outPath)})`);
    }
  } else {
    fs.writeFileSync(outPath, text, 'utf8');
  }
}

if (failed) {
  console.error(`\n${failed} guide(s) not clean.`);
  process.exit(1);
}
console.log(`\nAll ${TARGETS.length} guides clean${check ? '' : ` -> ${path.relative(ROOT, OUT_DIR)}`}.`);
