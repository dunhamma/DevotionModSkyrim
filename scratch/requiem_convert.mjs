// One-off Requiem-regen conversion: HealRateMult (positive rewards) -> Fortify Health.
// Dry-run by default; --write applies (with a .bak-reqconv backup per file).
// Skips penalties (magnitude<=0), non-Health regen, and event-driven races (Redguard
// Tuwhacca, Imperial Mara, Dunmer -- handled separately). Preserves effect order
// (in-place field edits), so cheat-death saves at non-zero Effects index stay put.
import fs from 'fs';

const WRITE = process.argv.includes('--write');
const dir = 'references/authoring/';
const specs = [
  'PDV_ArgonianRewardRecords.spec.json',
  'PDV_KhajiitRewardRecords.spec.json',
  'PDV_BosmerRewardRecords.spec.json',
  'PDV_BretonRewardRecords.spec.json',
  'PDV_OrcRewardRecords.spec.json',
  'PDV_NordRewardRecords.spec.json',
].map(f => dir + f);

const mapHP = (old) => (old <= 5 ? 10 : old <= 14 ? 20 : 30);

const report = [];
let changedCount = 0;
const changedFiles = [];

for (const path of specs) {
  const raw = fs.readFileSync(path, 'utf8');
  const j = JSON.parse(raw);
  const records = [];
  if (Array.isArray(j.emphasisRewards)) records.push(...j.emphasisRewards);
  if (j.substrateBoons && Array.isArray(j.substrateBoons.slots)) records.push(...j.substrateBoons.slots);

  let fileChanged = false;
  for (const rec of records) {
    if (!Array.isArray(rec.effects)) continue;
    for (const eff of rec.effects) {
      if (eff.actorValue !== 'HealRateMult' || typeof eff.magnitude !== 'number' || eff.magnitude <= 0) continue;
      const oldMag = eff.magnitude;
      const newMag = mapHP(oldMag);
      const id = rec.spellEditorId || rec.slotProperty || '(unknown)';
      eff.actorValue = 'Health';
      eff.effectName = 'Fortify Health';
      eff.magnitude = newMag;
      let textNote = '';
      if (typeof rec.playerFacingText === 'string') {
        const re = new RegExp('Health Regeneration \\+' + oldMag + '%');
        if (re.test(rec.playerFacingText)) {
          rec.playerFacingText = rec.playerFacingText.replace(re, 'Maximum Health +' + newMag);
        } else {
          textNote = '  [TEXT NOT MATCHED -- FIX MANUALLY]';
        }
      }
      report.push(`${path.split('/').pop()} | ${id} | +${oldMag}% regen -> Fortify Health +${newMag}${textNote}`);
      changedCount++;
      fileChanged = true;
    }
  }
  if (fileChanged) {
    changedFiles.push(path);
    if (WRITE) {
      fs.writeFileSync(path + '.bak-reqconv', raw, 'utf8');
      fs.writeFileSync(path, JSON.stringify(j, null, 2) + '\n', 'utf8');
    }
  }
}

console.log(report.join('\n'));
console.log(`\n${WRITE ? 'WROTE' : 'DRY-RUN'} | ${changedCount} effects in ${changedFiles.length} files`);
if (WRITE) console.log('changed: ' + changedFiles.map(f => f.split('/').pop()).join(', '));
