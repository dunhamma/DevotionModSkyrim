#!/usr/bin/env node
/*
 * pdv_show_daedric_boon.mjs
 *
 * Prints the boon SPELL effects (actor value + magnitude) for one Daedric prince,
 * read straight out of a Devotion.esp -- a no-xEdit way to confirm what a boon
 * actually grants in the deployed plugin.
 *
 * Usage:  node tools/pdv_show_daedric_boon.mjs <path-to-Devotion.esp> <PrinceName>
 * e.g.    node tools/pdv_show_daedric_boon.mjs "D:\...\Devotion.esp" Namira
 *
 * Pure Node. SPEL effects: EFID (mgef formid) + EFIT (magnitude float, area, dur).
 */
import fs from 'node:fs';
import zlib from 'node:zlib';

const AV = {6:'OneHanded',7:'TwoHanded',8:'Marksman',9:'Block',10:'Smithing',11:'HeavyArmor',12:'LightArmor',
13:'Pickpocket',14:'LockPicking',15:'Sneak',16:'Alchemy',17:'Speechcraft',18:'Alteration',19:'Conjuration',
20:'Destruction',21:'Illusion',22:'Restoration',23:'Enchanting',24:'Health',25:'Magicka',26:'Stamina',
27:'HealRate',28:'MagickaRate',29:'StaminaRate',30:'SpeedMult',32:'CarryWeight',39:'DamageResist',
44:'ResistMagic',45:'ResistDisease',154:'AttackDamageMult',155:'HealRateMult',156:'MagickaRateMult',157:'StaminaRateMult'};
const REGEN = new Set([27,28,29,155,156,157]);

const esp = process.argv[2], prince = process.argv[3];
if (!esp || !prince) { console.error('usage: node tools/pdv_show_daedric_boon.mjs <Devotion.esp> <PrinceName>'); process.exit(2); }
const buf = fs.readFileSync(esp);

function walk(b,s,e,cb){let o=s;while(o<e){const t=b.toString('latin1',o,o+4);
  if(t==='GRUP'){const g=b.readUInt32LE(o+4);walk(b,o+24,o+g,cb);o+=g;}
  else{const ds=b.readUInt32LE(o+4),fl=b.readUInt32LE(o+8),fid=b.readUInt32LE(o+12);let d=b.subarray(o+24,o+24+ds);
    if(fl&0x40000){try{d=zlib.inflateSync(d.subarray(4));}catch{d=Buffer.alloc(0);}}cb(t,fid,d);o+=24+ds;}}}
function subs(d){const o=[];let p=0;while(p+6<=d.length){const s=d.toString('latin1',p,p+4),z=d.readUInt16LE(p+4);p+=6;o.push({s,b:d.subarray(p,p+z)});p+=z;}return o;}
function edid(ss){const e=ss.find(x=>x.s==='EDID');return e?e.b.toString('latin1').replace(/\0+$/,''):null;}

// pass 1: map MGEF formid -> {edid, av}
const mgef = new Map();
walk(buf,0,buf.length,(t,fid,d)=>{
  if(t!=='MGEF')return; const ss=subs(d); const e=edid(ss); const DA=ss.find(x=>x.s==='DATA');
  if(!e)return; mgef.set(fid & 0x00FFFFFF, {edid:e, av: DA&&DA.b.length>=72?DA.b.readInt32LE(0x44):null});
});

// pass 2: the prince's boon spells
const re = new RegExp(`^PDV_Bless_Daedric_${prince}_(Seeker|Devoted|Champion)$`,'i');
const spells = [];
walk(buf,0,buf.length,(t,fid,d)=>{
  if(t!=='SPEL')return; const ss=subs(d); const e=edid(ss); if(!e||!re.test(e))return;
  const effects=[]; let pending=null;
  for(const s of ss){
    if(s.s==='EFID'){pending=s.b.readUInt32LE(0)&0x00FFFFFF;}
    else if(s.s==='EFIT'&&pending!=null){const mag=s.b.readFloatLE(0);const m=mgef.get(pending);
      effects.push({mag, av:m?m.av:null, edid:m?m.edid:`?form ${pending.toString(16)}`});pending=null;}
  }
  spells.push({e,effects});
});

if(!spells.length){console.log(`No boon spells found for "${prince}". Check the name (e.g. Namira, Sheo, Hircine).`);process.exit(1);}
const order={Seeker:0,Devoted:1,Champion:2};
spells.sort((a,b)=>(order[a.e.split('_').pop()]??9)-(order[b.e.split('_').pop()]??9));
console.log(`\n${prince} boon (deployed in ${esp}):\n`);
let anyRegen=false;
for(const sp of spells){
  const parts=sp.effects.map(ef=>{const nm=AV[ef.av]||`AV#${ef.av}`;if(REGEN.has(ef.av))anyRegen=true;const bad=REGEN.has(ef.av)?' <<REGEN-RATE':'';return `${nm} +${Math.round(ef.mag)}${bad}`;});
  console.log(`  ${sp.e.padEnd(34)} ${parts.join(', ')}  (${sp.effects.length} effect${sp.effects.length===1?'':'s'})`);
}
console.log(anyRegen ? '\nWARNING: a regen-rate effect is still present.' : '\nOK: no regen-rate effects.');
