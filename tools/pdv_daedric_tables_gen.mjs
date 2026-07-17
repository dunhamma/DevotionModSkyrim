#!/usr/bin/env node
// pdv_daedric_tables_gen.mjs
//
// Emits the per-Prince Boon/Price-by-tier tables for the Daedric Princes guide
// straight from references/authoring/PDV_DaedricBoonPriceReviewSheet.csv, so the
// guide can never drift from that sheet. Prints Markdown to stdout; hand-splice
// the output into docs/player-guides/Daedric_Princes_Guide.md under the
// "Boon and Price by Tier" heading (the same generate-then-splice flow as
// pdv_guide_tables_gen.mjs for the race guides).
//
// The sheet's magnitudes are spot-verified against the shipped Devotion.esp MGEF
// descriptions (e.g. PDV_MGEF_Bless_Daedric_Boethiah_Seeker reads
// "Boon: One-Handed +10"); these are the same numbers a player sees in Active
// Effects. They are current beta values and may be tuned before release.
//
// Usage:
//   node tools/pdv_daedric_tables_gen.mjs        # Markdown -> stdout

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const CSV = path.join(ROOT, 'references', 'authoring', 'PDV_DaedricBoonPriceReviewSheet.csv');

// Guide order -- matches the "Sixteen Princes" list in the guide body so the
// tables read in the same sequence the reader just met them.
const PRINCE_ORDER = [
  'Azura', 'Boethiah', 'Mephala', 'Malacath', 'Meridia', 'Hircine', 'Molag Bal',
  'Nocturnal', 'Hermaeus Mora', 'Mehrunes Dagon', 'Sheogorath', 'Namira',
  'Sanguine', 'Clavicus Vile', 'Peryite', 'Vaermina',
];
const TIER_ORDER = ['Seeker', 'Devoted', 'Champion'];

// Every field in the sheet is double-quoted and the Rationale cells contain
// commas, so a naive split(',') misaligns columns. Parse quoted CSV properly.
function splitCsvLine(line) {
  const cells = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"' && line[i + 1] === '"') { cur += '"'; i++; }
      else if (ch === '"') inQuotes = false;
      else cur += ch;
    } else if (ch === '"') inQuotes = true;
    else if (ch === ',') { cells.push(cur); cur = ''; }
    else cur += ch;
  }
  cells.push(cur);
  return cells.map((c) => c.trim());
}

function parseCsv(text) {
  const lines = text.replace(/\r\n/g, '\n').split('\n').filter((l) => l.trim());
  const headers = splitCsvLine(lines[0]);
  return lines.slice(1).map((line) => {
    const cells = splitCsvLine(line);
    const row = {};
    headers.forEach((h, i) => { row[h] = cells[i] || ''; });
    return row;
  });
}

const rows = parseCsv(fs.readFileSync(CSV, 'utf8'));
const effect = (prince, tier, slot) => {
  const r = rows.find((x) => x.Prince === prince && x.Tier === tier && x.Slot === slot);
  return r ? r['Current Effect'] : '';
};

const out = [];
for (const prince of PRINCE_ORDER) {
  const has = rows.some((x) => x.Prince === prince);
  if (!has) { console.error(`WARN no rows for ${prince}`); continue; }
  out.push(`**${prince}**`, '');
  out.push('| Tier | Boon | Price |');
  out.push('|------|------|-------|');
  for (const tier of TIER_ORDER) {
    const boon = effect(prince, tier, 'Boon') || '-';
    const price = effect(prince, tier, 'Price') || '-';
    out.push(`| ${tier} | ${boon} | ${price} |`);
  }
  out.push('');
}
process.stdout.write(out.join('\n') + '\n');
