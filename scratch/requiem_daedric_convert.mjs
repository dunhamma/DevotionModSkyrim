// Requiem regen conversion for the Daedric Prince contracts (2026-07-13):
// RateMult regen -> flat Fortify max-pool, sign-preserving so boons become
// positive Fortify and prices become mild negative Fortify. Tier-aware by the
// _Seeker/_Devoted/_Champion suffix. Magnitude 0 records (Namira placeholder)
// are skipped. Dry-run by default; --write applies (.bak-daedric backup).
import fs from 'fs';

const WRITE = process.argv.includes('--write');
const path = 'references/authoring/PDV_DaedricPrinceRecordContracts.json';

// Positive boon Fortify by tier (Seeker/Devoted/Champion). Provisional, tune in-game.
const BOON = { Seeker: 25, Devoted: 40, Champion: 50 };
// Negative price Fortify by tier -- mild bite (max-pool reduction). Health milder.
const PRICE_POOL = { Seeker: -10, Devoted: -20, Champion: -30 };
const PRICE_HEALTH = { Seeker: -8, Devoted: -15, Champion: -20 };

const CONV = {
  MagickaRateMult: { av: 'Magicka', name: 'Fortify Magicka' },
  StaminaRateMult: { av: 'Stamina', name: 'Fortify Stamina' },
  HealRateMult:    { av: 'Health',  name: 'Fortify Health' },
};

function tierOf(id) {
  if (/_Seeker\b/.test(id)) return 'Seeker';
  if (/_Devoted\b/.test(id)) return 'Devoted';
  if (/_Champion\b/.test(id)) return 'Champion';
  return null;
}

function collect(node, acc) {
  if (Array.isArray(node)) { for (const x of node) collect(x, acc); return acc; }
  if (node && typeof node === 'object') {
    if (Array.isArray(node.effects) && node.spellEditorId) acc.push(node);
    for (const k of Object.keys(node)) collect(node[k], acc);
  }
  return acc;
}

const raw = fs.readFileSync(path, 'utf8');
const j = JSON.parse(raw);
const records = collect(j, []);
const report = [];
let n = 0;

for (const rec of records) {
  const id = rec.spellEditorId;
  const tier = tierOf(id);
  for (const eff of rec.effects) {
    const conv = CONV[eff.actorValue];
    if (!conv || typeof eff.magnitude !== 'number' || eff.magnitude === 0 || !tier) continue;
    const isPrice = eff.magnitude < 0;
    const oldMag = eff.magnitude;
    let newMag;
    if (!isPrice) newMag = BOON[tier];
    else newMag = (conv.av === 'Health' ? PRICE_HEALTH : PRICE_POOL)[tier];
    const oldAvRegen = eff.actorValue;
    eff.actorValue = conv.av;
    eff.effectName = conv.name;
    eff.magnitude = newMag;
    // Text: case-insensitive "<AV> regeneration +/-N%" -> "Fortify <AV> +/-N".
    if (typeof rec.playerFacingText === 'string') {
      const avWord = conv.av; // Magicka / Stamina / Health
      const re = new RegExp(avWord + ' regeneration ([+-]?)' + Math.abs(oldMag) + '%', 'i');
      const sign = newMag < 0 ? '' : '+';
      if (re.test(rec.playerFacingText)) {
        rec.playerFacingText = rec.playerFacingText.replace(re, conv.name + ' ' + sign + newMag);
      } else {
        rec._textNote = 'FIX TEXT';
      }
    }
    report.push(`${id} | ${isPrice ? 'PRICE' : 'BOON'} ${oldAvRegen} ${oldMag} -> ${conv.name} ${newMag}${rec._textNote ? '  [TEXT?]' : ''}`);
    delete rec._textNote;
    n++;
  }
}

console.log(report.join('\n'));
console.log(`\n${WRITE ? 'WROTE' : 'DRY-RUN'} | ${n} Daedric effects`);
if (WRITE) { fs.writeFileSync(path + '.bak-daedric', raw, 'utf8'); fs.writeFileSync(path, JSON.stringify(j, null, 2) + '\n', 'utf8'); }
