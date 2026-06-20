// Fix Argonian playerFacingText after the HealRateMult->Fortify Health conversion
// (the script could not auto-match Argonian's non-standard regen phrasing).
import fs from 'fs';
const path = 'references/authoring/PDV_ArgonianRewardRecords.spec.json';
let raw = fs.readFileSync(path, 'utf8');
const pairs = [
  ['The Hist keeps a steadying hand on you. Health regenerates 5% faster.',
   'The Hist keeps a steadying hand on you. Maximum Health +10.'],
  ['The Hist holds you close even in exile. Health regenerates 13% faster and stamina returns 10% faster.',
   'The Hist holds you close even in exile. Maximum Health +20 and stamina returns 10% faster.'],
  ['You carry the marsh within you. Health regenerates 23% faster, stamina returns 10% faster, and your resistance to poison rises 10%.',
   'You carry the marsh within you. Maximum Health +30, stamina returns 10% faster, and your resistance to poison rises 10%.'],
  ['Your chosen family steadies you. You carry 25 more weight, poison resistance rises 8%, and health regenerates 5% faster.',
   'Your chosen family steadies you. You carry 25 more weight, poison resistance rises 8%, and Maximum Health +10.'],
  ['You are a pillar of the people you gathered. You carry 50 more weight, poison resistance rises 8%, health regenerates 13% faster, and magic finds less purchase (5%).',
   'You are a pillar of the people you gathered. You carry 50 more weight, poison resistance rises 8%, Maximum Health +20, and magic finds less purchase (5%).'],
  ['The Hist reaches a little closer. Magic finds less purchase (5%), your health regenerates 6% faster, and your resistance to poison rises 10%.',
   'The Hist reaches a little closer. Magic finds less purchase (5%), Maximum Health +20, and your resistance to poison rises 10%.'],
  ["You are deeply attuned to the Hist even far from the marsh. Magic finds little purchase (5%), your health mends quickly (15%), poison fails (22%), and your claws carry the marsh's strength (+12 unarmed).",
   "You are deeply attuned to the Hist even far from the marsh. Magic finds little purchase (5%), Maximum Health +30, poison fails (22%), and your claws carry the marsh's strength (+12 unarmed)."],
];
let ok = 0, miss = [];
for (const [oldT, newT] of pairs) {
  if (raw.includes(oldT)) { raw = raw.replace(oldT, newT); ok++; }
  else miss.push(oldT.slice(0, 50));
}
if (miss.length) { console.log('MISSED (not applied):\n' + miss.join('\n')); process.exit(1); }
JSON.parse(raw); // validate
fs.writeFileSync(path, raw, 'utf8');
console.log('Argonian text fixed: ' + ok + '/7; JSON valid.');
