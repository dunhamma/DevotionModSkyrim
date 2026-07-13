// Project-wide Requiem regen conversion (2026-07-13): positive Magicka/Stamina
// regen -> flat Fortify max-pool, plus the 2 overlooked Argonian HealRateMult
// survivors -> Fortify Health. Mirrors scratch/requiem_convert.mjs (health, June).
//
// Dry-run by default; --write applies (.bak-msconv backup per file).
// SKIPS: magnitude<=0 (penalties -> Phase 4, separate), and the two near-death
// SPELs (Phase 3 -> scripted flat restore in Papyrus). Preserves effect order
// (in-place field edits) so scripted saves at non-zero Effects index stay put.
import fs from 'fs';

const WRITE = process.argv.includes('--write');
const dir = 'references/authoring/';
const specs = [
  'PDV_AltmerRewardRecords.spec.json',
  'PDV_ArgonianRewardRecords.spec.json',
  'PDV_BosmerRewardRecords.spec.json',
  'PDV_BretonRewardRecords.spec.json',
  'PDV_DunmerRewardRecords.spec.json',
  'PDV_ImperialRewardRecords.spec.json',
  'PDV_KhajiitRewardRecords.spec.json',
  'PDV_NordRewardRecords.spec.json',
  'PDV_OrcRewardRecords.spec.json',
  'PDV_RedguardRewardRecords.spec.json',
].map(f => dir + f);

// Near-death bursts handled by Papyrus in Phase 3, not here.
const SKIP_IDS = new Set([
  'PDV_SPEL_ArgonianSithisNearDeathBurst',
  'PDV_SPEL_OrcHearthHeld',
]);

// Magicka/Stamina regen % -> flat Fortify pool points (provisional, tune in-game).
const mapPool = (old) => (old <= 5 ? 15 : old <= 12 ? 25 : 40);
// The 2 Argonian HealRateMult survivors -> Fortify Health (substrate Mid/High).
const mapHealth = (id, old) =>
  /Substrate_High/i.test(id) ? 30 : /Substrate_Mid/i.test(id) ? 20 : (old <= 5 ? 10 : old <= 14 ? 20 : 30);

const CONV = {
  MagickaRateMult: { av: 'Magicka', name: 'Fortify Magicka', map: mapPool, oldName: 'Magicka Regeneration', newText: 'Fortify Magicka' },
  StaminaRateMult: { av: 'Stamina', name: 'Fortify Stamina', map: mapPool, oldName: 'Stamina Regeneration', newText: 'Fortify Stamina' },
  HealRateMult:    { av: 'Health',  name: 'Fortify Health',  map: null,    oldName: 'Health Regeneration',  newText: 'Maximum Health' },
};

// Recursively collect every object that has a spellEditorId + effects[].
function collectRecords(node, acc) {
  if (Array.isArray(node)) { for (const x of node) collectRecords(x, acc); return acc; }
  if (node && typeof node === 'object') {
    if (Array.isArray(node.effects) && (node.spellEditorId || node.slotProperty)) acc.push(node);
    for (const k of Object.keys(node)) collectRecords(node[k], acc);
  }
  return acc;
}

const report = [];
let changedCount = 0;
const changedFiles = [];

for (const path of specs) {
  if (!fs.existsSync(path)) { report.push(`(missing: ${path.split('/').pop()})`); continue; }
  const raw = fs.readFileSync(path, 'utf8');
  const j = JSON.parse(raw);
  const records = collectRecords(j, []);
  let fileChanged = false;

  for (const rec of records) {
    const id = rec.spellEditorId || rec.slotProperty || '(unknown)';
    if (SKIP_IDS.has(id)) continue;
    for (const eff of rec.effects) {
      const conv = CONV[eff.actorValue];
      if (!conv || typeof eff.magnitude !== 'number' || eff.magnitude <= 0) continue;
      const oldMag = eff.magnitude;
      const newMag = conv.map ? conv.map(oldMag) : mapHealth(id, oldMag);
      eff.actorValue = conv.av;
      eff.effectName = conv.name;
      eff.magnitude = newMag;
      let textNote = '';
      if (typeof rec.playerFacingText === 'string') {
        const re = new RegExp(conv.oldName + ' \\+' + oldMag + '%');
        if (re.test(rec.playerFacingText)) {
          rec.playerFacingText = rec.playerFacingText.replace(re, conv.newText + ' +' + newMag);
        } else {
          textNote = '  [TEXT NOT MATCHED -- desc-regen pass will fix]';
        }
      }
      report.push(`${path.split('/').pop()} | ${id} | ${eff.actorValue === 'Health' ? 'HealRateMult' : conv.av + 'RateMult'} +${oldMag} -> ${conv.name} +${newMag}${textNote}`);
      changedCount++;
      fileChanged = true;
    }
  }

  if (fileChanged) {
    changedFiles.push(path);
    if (WRITE) {
      fs.writeFileSync(path + '.bak-msconv', raw, 'utf8');
      fs.writeFileSync(path, JSON.stringify(j, null, 2) + '\n', 'utf8');
    }
  }
}

console.log(report.join('\n'));
console.log(`\n${WRITE ? 'WROTE' : 'DRY-RUN'} | ${changedCount} effects in ${changedFiles.length} files`);
if (WRITE) console.log('changed: ' + changedFiles.map(f => f.split('/').pop()).join(', '));
