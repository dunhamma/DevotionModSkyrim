#!/usr/bin/env node
// pdv_guide_tables_gen.mjs
//
// Emits the player-facing "Bonuses by Tier" tables for the 10 Nexus race guides
// (docs/player-guides/races/*.md) straight from the authoritative per-race reward
// specs, so the guides can never drift from the shipped records again.
//
// Sources of truth (see memory: player-facing-tier-names-and-reward-sources):
//   - magnitudes + flavor : references/authoring/PDV_<Race>RewardRecords.spec.json
//   - tier vocabulary     : the shipped UI (app.js) -> Seeker 25 / Devoted 50 / Champion 85.
//     The specs' own displayName/tierName fields still carry the RETIRED design
//     vocabulary ("Observant"/"Faithful") on some records, so they are deliberately
//     NOT trusted for tier labels here.
//
// Usage:
//   node tools/pdv_guide_tables_gen.mjs                 # all races -> stdout
//   node tools/pdv_guide_tables_gen.mjs --race Khajiit  # one race
//   node tools/pdv_guide_tables_gen.mjs --json          # machine-readable

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const SPEC_DIR = path.join(ROOT, 'references', 'authoring');

const RACES = ['Altmer', 'Argonian', 'Bosmer', 'Breton', 'Dunmer', 'Imperial', 'Khajiit', 'Nord', 'Orc', 'Redguard'];

// Shipped tier vocabulary + thresholds (app.js). T1/T2/T3 are the spec's internal keys.
const TIER_LABEL = {
  T1: 'Seeker (25)',
  T2: 'Devoted (50)',
  T3: 'Champion (85)',
  Champion: 'Champion (85)',
  signature: 'Signature',
};
const TIER_ORDER = { T1: 1, T2: 2, T3: 3, Champion: 3, signature: 4 };

// 2026-07-15: the old "Observant/Faithful are retired design-sheet words" lint is
// itself retired -- BroadPantheonContracts playerFacingBands ratified
// Distant/Observant/Faithful as the PLAYER-FACING broad-lane vocabulary (Seeker/
// Devoted/Champion stay patron-ladder). A per-family vocabulary gate (broad names
// must use bands, patron names must not) is the tracked follow-up; a bare word
// blocklist can no longer express the rule.
const RETIRED_TIER_WORDS = /$^/;

// Reward records that EXIST in the specs and the ESP but which the manager
// deliberately never grants -- it hard-codes their sync to False, labelled
// "(retired)" or "T1 compatibility" (kept so old saves do not break).
// A player can never hold these, so a player guide must never advertise them.
// Source of truth: the `SyncRaceRewardSpell(..., False, ...)` calls in
// live-source/Scripts/Source/PDV__ManagerQuest.psc.
//   - Nord + Imperial patron lanes: T1 is dead; the patron blessing starts at Devoted.
//   - Breton Tradition + Argonian Hist: T1 and T2 both retired.
const NEVER_GRANTED = {
  // "Nord <deity> T1 compatibility" -- PDV__ManagerQuest.psc:15311
  Nord: ({ emphasis, tier }) => tier === 'T1' && ['Kyne', 'Shor', 'Tsun', 'Stuhn', 'Talos'].includes(emphasis),
  // "Imperial <deity> T1 compatibility" -- PDV__ManagerQuest.psc:15561
  Imperial: ({ emphasis, tier }) =>
    tier === 'T1' &&
    ['Akatosh', 'Mara', 'Arkay', 'Stendarr', 'Zenithar', 'Dibella', 'Julianos', 'Kynareth', 'Talos'].includes(emphasis),
  // "Breton Tradition T1/T2 (retired)" -- PDV__ManagerQuest.psc:14341-14342
  Breton: ({ emphasis, tier }) => emphasis === 'Tradition' && (tier === 'T1' || tier === 'T2'),
  // "Argonian Hist T1/T2/Signature retired" -- PDV__ManagerQuest.psc:15424-15426.
  // NB the whole Hist family is retired, signature included -- and the signature
  // record is the one that does NOT carry the runtimeStatus flag below.
  Argonian: ({ emphasis }) => emphasis === 'Hist',
};

/** Authoritative when present, but only 2 of the 18 dead records actually carry it,
 *  so it backstops NEVER_GRANTED rather than replacing it. */
function isRetiredByFlag(reward) {
  return /retired|never-granted/i.test(reward.runtimeStatus || '');
}

/** Split an authored playerFacingText into { flavor, mechanics }.
 *  Convention in the specs: "<flavor sentence(s)>. <mechanics clause with magnitudes>."
 *  The mechanics clause is the trailing run of sentences that carry a +/- magnitude. */
function splitPlayerFacingText(text) {
  if (!text) return { flavor: '', mechanics: '' };
  const sentences = text.trim().split(/(?<=\.)\s+/);
  const hasMagnitude = (s) => /[+-]\s?\d/.test(s);
  let firstMech = sentences.length;
  for (let i = sentences.length - 1; i >= 0; i--) {
    if (hasMagnitude(sentences[i])) firstMech = i;
    else break;
  }
  return {
    flavor: sentences.slice(0, firstMech).join(' ').trim(),
    mechanics: sentences.slice(firstMech).join(' ').trim().replace(/\.$/, ''),
  };
}

/** Fallback: synthesise a mechanics string from effects[] when playerFacingText has none.
 *  effectName is missing on 9 records, so fall back to the actorValue. */
function mechanicsFromEffects(effects) {
  return (effects || [])
    .map((f) => {
      const name = f.effectName || f.actorValue || 'Unknown';
      const sign = f.magnitude < 0 ? '' : '+';
      const gate = f.nearWaterOnly ? ' (near water only)' : '';
      return `${name} ${sign}${f.magnitude}${gate}`;
    })
    .join(', ');
}

function loadRace(race) {
  const file = path.join(SPEC_DIR, `PDV_${race}RewardRecords.spec.json`);
  const spec = JSON.parse(fs.readFileSync(file, 'utf8'));
  const byEmphasis = new Map();
  const isDead = NEVER_GRANTED[race] || (() => false);
  const suppressed = [];

  for (const reward of spec.emphasisRewards || []) {
    const emphasis = reward.emphasis || reward.deity || 'Unknown';

    // Never advertise a blessing the manager refuses to grant.
    if (isDead({ emphasis, tier: reward.tier }) || isRetiredByFlag(reward)) {
      suppressed.push(`${reward.spellEditorId} (${emphasis} ${reward.tier})`);
      continue;
    }

    if (!byEmphasis.has(emphasis)) byEmphasis.set(emphasis, []);

    const { flavor, mechanics } = splitPlayerFacingText(reward.playerFacingText);
    const effectsMechanics = mechanicsFromEffects(reward.effects);

    // The blessing's own name, minus the tier suffix -- the tier is its own column.
    const rawName = reward.displayName || reward.tierName || '';
    const blessing = rawName.replace(/\s*[-–]\s*(Seeker|Devoted|Champion|Observant|Faithful)\s*$/i, '').trim();

    byEmphasis.get(emphasis).push({
      tier: reward.tier,
      tierLabel: TIER_LABEL[reward.tier] || reward.tier,
      blessing,
      spellEditorId: reward.spellEditorId,
      mechanics: mechanics || effectsMechanics,
      flavor,
      // Surfaced so a caller can assert none of these reach a player.
      retiredTierName: RETIRED_TIER_WORDS.test(rawName) ? rawName : null,
    });
  }

  for (const rows of byEmphasis.values()) {
    rows.sort((a, b) => (TIER_ORDER[a.tier] || 9) - (TIER_ORDER[b.tier] || 9));
  }
  byEmphasis.suppressed = suppressed;
  return byEmphasis;
}

/** The always-on cultural layer (Khajiit Lattice, Dunmer ancestors, Argonian Hist, ...)
 *  and the neglect penalty. These live outside emphasisRewards, so without this the
 *  guides' substrate numbers are hand-written and unverifiable. */
function renderSubstrate(race, spec) {
  const out = [];
  const sub = spec.substrateBoons;
  if (sub && Array.isArray(sub.slots) && sub.slots.length) {
    out.push('**The always-on cultural layer** (only the highest slot you have reached is active)');
    out.push('');
    out.push('| Slot | Blessing | What you get |');
    out.push('|------|----------|--------------|');
    for (const slot of sub.slots) {
      const { mechanics } = splitPlayerFacingText(slot.playerFacingText);
      const mech = mechanics || mechanicsFromEffects(slot.effects);
      const nightOnly = (slot.effects || []).some((e) => e.nightOnly) ? ' (at night)' : '';
      out.push(`| ${(slot.slotProperty || '').replace('Substrate_', '')} | ${slot.displayName || '-'} | ${mech}${nightOnly} |`);
    }
    out.push('');
  }
  const neg = spec.neglect;
  if (neg && (neg.effects || neg.playerFacingText)) {
    const { mechanics } = splitPlayerFacingText(neg.playerFacingText);
    const mech = mechanics || mechanicsFromEffects(neg.effects);
    const nightOnly = (neg.effects || []).some((e) => e.nightOnly) ? ' (at night)' : '';
    out.push(`**If you neglect it** - "${neg.displayName || 'Neglect'}": ${mech}${nightOnly}`);
    out.push('');
  }
  return out;
}

function renderRace(race) {
  const byEmphasis = loadRace(race);
  const spec = JSON.parse(fs.readFileSync(path.join(SPEC_DIR, `PDV_${race}RewardRecords.spec.json`), 'utf8'));
  const out = [];
  const warnings = [];

  for (const s of byEmphasis.suppressed || []) {
    warnings.push(`${race}: OMITTED ${s} -- manager never grants it (retired/compatibility record)`);
  }

  for (const [emphasis, rows] of byEmphasis) {
    const title = rows[0]?.blessing || emphasis;
    out.push(`**${emphasis}** (${title})`);
    out.push('');
    out.push('| Tier | Blessing | What you get |');
    out.push('|------|----------|--------------|');
    for (const r of rows) {
      if (r.retiredTierName) warnings.push(`${race}/${r.spellEditorId}: retired tier name "${r.retiredTierName}"`);
      out.push(`| ${r.tierLabel} | ${r.blessing || '-'} | ${r.mechanics || '-'} |`);
    }
    out.push('');
  }

  out.push(...renderSubstrate(race, spec));
  return { markdown: out.join('\n'), warnings };
}

const args = process.argv.slice(2);
const only = args.includes('--race') ? args[args.indexOf('--race') + 1] : null;
const asJson = args.includes('--json');
const races = only ? [only] : RACES;

if (asJson) {
  const payload = {};
  for (const race of races) payload[race] = Object.fromEntries(loadRace(race));
  process.stdout.write(JSON.stringify(payload, null, 2) + '\n');
} else {
  const allWarnings = [];
  for (const race of races) {
    const { markdown, warnings } = renderRace(race);
    allWarnings.push(...warnings);
    process.stdout.write(`\n${'='.repeat(70)}\n## ${race}\n${'='.repeat(70)}\n\n${markdown}\n`);
  }
  if (allWarnings.length) {
    process.stderr.write(`\nWARN: ${allWarnings.length} record(s) still carry retired tier vocabulary:\n`);
    for (const w of allWarnings) process.stderr.write(`  - ${w}\n`);
  }
}
