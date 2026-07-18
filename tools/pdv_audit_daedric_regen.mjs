#!/usr/bin/env node
/*
 * pdv_audit_daedric_regen.mjs
 *
 * Reads a Devotion.esp and reports every Daedric prince boon/price magic effect
 * (PDV_MGEF_Bless_Daedric_* / PDV_MGEF_Price_Daedric_*) whose modified actor value
 * is a REGEN-RATE type (HealRate/MagickaRate/StaminaRate or their *Mult forms).
 *
 * Those AVs are swallowed by Requiem (base regen ~0, so a rate mult multiplies
 * nothing) -- see issue for the Daedric regen fix. This is the ground-truth check
 * against what is actually DEPLOYED in the plugin, independent of the curated
 * contract JSON (which can be fixed on paper while the ESP is stale).
 *
 * Usage:  node tools/pdv_audit_daedric_regen.mjs <path-to-Devotion.esp>
 * Exit:   0 = clean (no regen-rate AVs), 1 = regen-rate AVs found, 2 = read error.
 *
 * Pure Node (node:fs + node:zlib). MGEF DATA "Primary Actor Value" is int32 at
 * offset 0x44 (validated against known effects: OneHanded=6, ResistMagic=44,
 * Health/Magicka/Stamina=24/25/26).
 */
import fs from 'node:fs';
import zlib from 'node:zlib';

const AV = {
  6: 'OneHanded', 7: 'TwoHanded', 8: 'Marksman', 9: 'Block', 10: 'Smithing',
  11: 'HeavyArmor', 12: 'LightArmor', 13: 'Pickpocket', 14: 'LockPicking', 15: 'Sneak',
  16: 'Alchemy', 17: 'Speechcraft', 18: 'Alteration', 19: 'Conjuration', 20: 'Destruction',
  21: 'Illusion', 22: 'Restoration', 23: 'Enchanting', 24: 'Health', 25: 'Magicka',
  26: 'Stamina', 27: 'HealRate', 28: 'MagickaRate', 29: 'StaminaRate', 30: 'SpeedMult',
  32: 'CarryWeight', 33: 'CritChance', 34: 'MeleeDamage', 39: 'DamageResist',
  44: 'ResistMagic', 45: 'ResistDisease',
  154: 'AttackDamageMult', 155: 'HealRateMult', 156: 'MagickaRateMult', 157: 'StaminaRateMult',
};
const REGEN_RATE = new Set([27, 28, 29, 155, 156, 157]);

const espPath = process.argv[2];
if (!espPath) { console.error('usage: node tools/pdv_audit_daedric_regen.mjs <Devotion.esp>'); process.exit(2); }
let buf;
try { buf = fs.readFileSync(espPath); } catch (e) { console.error('cannot read', espPath, e.message); process.exit(2); }

function walk(b, start, end, cb) {
  let off = start;
  while (off < end) {
    const t = b.toString('latin1', off, off + 4);
    if (t === 'GRUP') { const g = b.readUInt32LE(off + 4); walk(b, off + 24, off + g, cb); off += g; }
    else {
      const ds = b.readUInt32LE(off + 4), fl = b.readUInt32LE(off + 8);
      let d = b.subarray(off + 24, off + 24 + ds);
      if (fl & 0x40000) { try { d = zlib.inflateSync(d.subarray(4)); } catch { d = Buffer.alloc(0); } }
      cb(t, d); off += 24 + ds;
    }
  }
}
function subs(d) { const o = []; let p = 0; while (p + 6 <= d.length) { const s = d.toString('latin1', p, p + 4), z = d.readUInt16LE(p + 4); p += 6; o.push({ s, b: d.subarray(p, p + z) }); p += z; } return o; }

const boon = [], price = [];
walk(buf, 0, buf.length, (t, d) => {
  if (t !== 'MGEF') return;
  const ss = subs(d);
  const ed = ss.find(x => x.s === 'EDID'); const DA = ss.find(x => x.s === 'DATA');
  if (!ed || !DA || DA.b.length < 72) return;
  const e = ed.b.toString('latin1').replace(/\0+$/, '');
  const m = e.match(/^PDV_MGEF_(Bless|Price)_Daedric_([A-Za-z]+)_(Seeker|Devoted|Champion)$/);
  if (!m) return;
  const av = DA.b.readInt32LE(0x44);
  (m[1] === 'Bless' ? boon : price).push({ prince: m[2], tier: m[3], av });
});

function summarize(rows) {
  const byPrince = {};
  for (const r of rows) (byPrince[r.prince] = byPrince[r.prince] || new Set()).add(r.av);
  return byPrince;
}
function report(title, rows) {
  const byPrince = summarize(rows);
  let bad = 0;
  console.log(`\n=== ${title} ===`);
  for (const p of Object.keys(byPrince).sort()) {
    const avs = [...byPrince[p]];
    const isBad = avs.some(a => REGEN_RATE.has(a));
    if (isBad) bad++;
    const names = avs.map(a => AV[a] || `AV#${a}`).join(', ');
    console.log(`${isBad ? '>>> ' : '    '}${p.padEnd(12)} ${names}${isBad ? '   << REGEN-RATE (swallowed by Requiem)' : ''}`);
  }
  return bad;
}

const badBoons = report('BOONS', boon);
const badPrices = report('PRICES', price);
const total = badBoons + badPrices;
console.log(`\n${total === 0
  ? 'CLEAN: no regen-rate actor values on any Daedric boon or price.'
  : `FOUND: ${badBoons} prince(s) with regen-rate BOONS, ${badPrices} with regen-rate PRICES.`}`);
process.exit(total === 0 ? 0 : 1);
