#!/usr/bin/env node
/*
 * pdv_fix_receiver_anam.mjs
 *
 * Fix for issue #17 (Craft Item / cooking CTD).
 *
 * The Story Manager receiver quests authored by the (external) generic-faucet
 * receiver-author tool are missing the QUST `ANAM` (Next Alias ID) subrecord that
 * the Creation Kit writes for every quest. The malformed record makes the engine
 * read uninitialised alias bookkeeping when the Story Manager starts the quest to
 * deliver an event, and it dereferences an invalid handle (RAX=RDX=0xFFFFFFFF)
 * while marshalling the event arguments -> CTD. Cooking/tempering (the Craft Item
 * event) is the receiver players hit first.
 *
 * This patcher inserts `ANAM = 0x00000000` into every targeted receiver QUST that
 * is missing it, placing it immediately after the `NEXT` marker so the field order
 * matches the working PDV__SM_KillActor receiver. It updates the record dataSize
 * and every enclosing GRUP groupSize accordingly, and rewrites the plugin.
 *
 * Pure Node (node:fs + node:zlib), no Mutagen / dotnet required. Idempotent:
 * receivers that already carry ANAM are skipped.
 *
 * Usage:
 *   node tools/pdv_fix_receiver_anam.mjs <path-to-Devotion.esp> [--out <path>] [--dry]
 *
 * With no --out it writes <input>.patched.esp (never overwrites the input in place
 * unless you pass --out equal to the input). Always back up your plugin first.
 *
 * Exit codes: 0 = ok (patched or already-clean), 1 = error, 2 = no target records found.
 */

import fs from 'node:fs';
import zlib from 'node:zlib';

const TARGET_EDIDS = new Set([
  'PDV__SM_CraftItem',
  'PDV__SM_NewVoicePower',
  'PDV__SM_IncreaseSkill',
  'PDV__SM_ChangeLocation',
  'PDV__SM_PickLock',
  'PDV__SM_Trespass',
  'PDV__SM_AssaultActor',
  'PDV__SM_AddToPlayer',
]);

const ANAM_BYTES = (() => {
  const b = Buffer.alloc(10);
  b.write('ANAM', 0, 'latin1');
  b.writeUInt16LE(4, 4);       // field data size
  b.writeUInt32LE(0, 6);       // Next Alias ID = 0
  return b;
})();

function parseArgs(argv) {
  const a = { in: null, out: null, dry: false };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--out') a.out = argv[++i];
    else if (argv[i] === '--dry') a.dry = true;
    else if (!a.in) a.in = argv[i];
  }
  return a;
}

function edidOf(uncompressedData) {
  // EDID is always first (or near-first) subrecord: sig(4)+size(2)+body
  let off = 0;
  while (off + 6 <= uncompressedData.length) {
    const sig = uncompressedData.toString('latin1', off, off + 4);
    const size = uncompressedData.readUInt16LE(off + 4);
    off += 6;
    if (sig === 'EDID') return uncompressedData.toString('latin1', off, off + size).replace(/\0+$/, '');
    off += size;
  }
  return null;
}

// Find byte offset (within record data) just after the end of the NEXT subrecord.
// Falls back to just after DNAM, else end of data.
function anamInsertOffset(data) {
  let off = 0, afterNext = -1, afterDnam = -1, hasAnam = false;
  while (off + 6 <= data.length) {
    const sig = data.toString('latin1', off, off + 4);
    const size = data.readUInt16LE(off + 4);
    const end = off + 6 + size;
    if (sig === 'ANAM') hasAnam = true;
    if (sig === 'NEXT') afterNext = end;
    if (sig === 'DNAM') afterDnam = end;
    off = end;
  }
  if (hasAnam) return { hasAnam: true };
  const at = afterNext >= 0 ? afterNext : (afterDnam >= 0 ? afterDnam : data.length);
  return { hasAnam: false, at };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.in) {
    console.error('usage: node tools/pdv_fix_receiver_anam.mjs <Devotion.esp> [--out <path>] [--dry]');
    process.exit(1);
  }
  const buf = fs.readFileSync(args.in);

  // Pass 1: locate target records + their ancestor GRUP size-field offsets.
  const targets = [];      // { insertAbs, dataSizeFieldOff, grupSizeOffs:[], edid }
  const seen = [];

  function walk(start, end, grupStack) {
    let off = start;
    while (off < end) {
      const type = buf.toString('latin1', off, off + 4);
      if (type === 'GRUP') {
        const groupSize = buf.readUInt32LE(off + 4);
        walk(off + 24, off + groupSize, [...grupStack, off + 4]);
        off += groupSize;
      } else {
        const dataSize = buf.readUInt32LE(off + 4);
        const flags = buf.readUInt32LE(off + 8);
        const dataStart = off + 24;
        if (type === 'QUST') {
          const compressed = (flags & 0x00040000) !== 0;
          let data = buf.subarray(dataStart, dataStart + dataSize);
          let usable = data;
          if (compressed) { try { usable = zlib.inflateSync(data.subarray(4)); } catch { usable = Buffer.alloc(0); } }
          const edid = edidOf(usable);
          if (edid && TARGET_EDIDS.has(edid)) {
            const ins = anamInsertOffset(usable);
            seen.push({ edid, hasAnam: ins.hasAnam, compressed });
            if (!ins.hasAnam && !compressed) {
              targets.push({
                edid,
                insertAbs: dataStart + ins.at,
                dataSizeFieldOff: off + 4,
                grupSizeOffs: grupStack,
              });
            }
          }
        }
        off = dataStart + dataSize;
      }
    }
  }
  walk(0, buf.length, []);

  if (seen.length === 0) {
    console.error('No receiver QUST records found in this plugin. Wrong file?');
    process.exit(2);
  }

  const already = seen.filter(s => s.hasAnam).map(s => s.edid);
  const compressedTargets = seen.filter(s => s.compressed && !s.hasAnam).map(s => s.edid);
  console.log(`Found ${seen.length} receiver quest(s).`);
  if (already.length) console.log(`  already have ANAM (skipped): ${already.join(', ')}`);
  if (compressedTargets.length) console.log(`  WARNING: compressed & missing ANAM (not patched here): ${compressedTargets.join(', ')}`);
  if (targets.length === 0) {
    console.log('Nothing to patch — all target receivers already carry ANAM.');
    process.exit(0);
  }
  console.log(`  patching (adding ANAM=0): ${targets.map(t => t.edid).join(', ')}`);

  if (args.dry) { console.log('--dry: no file written.'); process.exit(0); }

  // Pass 2a: accumulate +10 into each affected size field (record dataSize + ancestor GRUP sizes).
  const sizeDelta = new Map(); // absOffset(uint32 LE) -> delta
  const bump = (o) => sizeDelta.set(o, (sizeDelta.get(o) || 0) + ANAM_BYTES.length);
  for (const t of targets) {
    bump(t.dataSizeFieldOff);
    for (const g of t.grupSizeOffs) bump(g);
  }

  // Work on a copy; apply in-place size increments (no length change yet).
  const out = Buffer.from(buf);
  for (const [o, d] of sizeDelta) out.writeUInt32LE(out.readUInt32LE(o) + d, o);

  // Pass 2b: apply insertions from highest offset to lowest so offsets stay valid.
  const inserts = targets.map(t => t.insertAbs).sort((a, b) => b - a);
  let result = out;
  for (const at of inserts) {
    result = Buffer.concat([result.subarray(0, at), ANAM_BYTES, result.subarray(at)]);
  }

  const outPath = args.out || (args.in.replace(/\.esp$/i, '') + '.patched.esp');
  fs.writeFileSync(outPath, result);
  console.log(`\nWrote ${outPath} (${result.length} bytes, +${result.length - buf.length}).`);
  console.log('Next: verify in xEdit/SSEEdit that ANAM is present on each receiver, then test in-game (cook a grilled leek, temper an item).');
}

main();
