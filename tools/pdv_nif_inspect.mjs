// Minimal SSE NIF (20.2.0.7 / BS stream 100) header parser + BSTriShape bounds reader.
import { readFileSync } from 'node:fs';

const file = process.argv[2];
const buf = readFileSync(file);
let o = 0;

// header string: newline-terminated
const nl = buf.indexOf(0x0a, 0);
const headerString = buf.toString('ascii', 0, nl);
o = nl + 1;

const version = buf.readUInt32LE(o); o += 4;
const endian = buf.readUInt8(o); o += 1;
const userVersion = buf.readUInt32LE(o); o += 4;
const numBlocks = buf.readUInt32LE(o); o += 4;
const bsVersion = buf.readUInt32LE(o); o += 4;

// export info: byte-length-prefixed strings (length includes trailing null? -> length is byte count, string follows)
function shortString() {
  const len = buf.readUInt8(o); o += 1;
  const s = buf.toString('ascii', o, o + len).replace(/\0+$/, '');
  o += len;
  return s;
}
const author = shortString();
if (bsVersion > 130) { buf.readUInt32LE(o); o += 4; } // unknown int stream >130
const proc = shortString();
const exp2 = shortString();
if (bsVersion === 130) { shortString(); } // maxFilepath only for FO4 130

const numBlockTypes = buf.readUInt16LE(o); o += 2;
const blockTypes = [];
for (let i = 0; i < numBlockTypes; i++) {
  const len = buf.readUInt32LE(o); o += 4;
  blockTypes.push(buf.toString('ascii', o, o + len)); o += len;
}
const typeIdx = [];
for (let i = 0; i < numBlocks; i++) { typeIdx.push(buf.readUInt16LE(o)); o += 2; }
const sizes = [];
for (let i = 0; i < numBlocks; i++) { sizes.push(buf.readUInt32LE(o)); o += 4; }
const numStrings = buf.readUInt32LE(o); o += 4;
const maxLen = buf.readUInt32LE(o); o += 4;
const strings = [];
for (let i = 0; i < numStrings; i++) {
  const len = buf.readUInt32LE(o); o += 4;
  strings.push(buf.toString('ascii', o, o + len)); o += len;
}
const numGroups = buf.readUInt32LE(o); o += 4;
for (let i = 0; i < numGroups; i++) { o += 4; }

console.log(`header: ${headerString}`);
console.log(`version=0x${version.toString(16)} user=${userVersion} bs=${bsVersion} blocks=${numBlocks}`);

// block offsets
const offsets = [];
let cur = o;
for (let i = 0; i < numBlocks; i++) { offsets.push(cur); cur += sizes[i]; }
console.log(`data starts at ${o}; file size ${buf.length}; computed end ${cur}`);

for (let i = 0; i < numBlocks; i++) {
  const t = blockTypes[typeIdx[i]];
  let line = `[${i}] ${t} @${offsets[i]} size=${sizes[i]}`;
  if (t === 'BSTriShape' || t === 'NiNode' || t === 'BSFadeNode') {
    let p = offsets[i];
    const nameRef = buf.readInt32LE(p); p += 4;
    const name = nameRef >= 0 ? strings[nameRef] : '(none)';
    const numExtra = buf.readUInt32LE(p); p += 4 + numExtra * 4;
    p += 4; // controller
    p += 4; // flags
    const tx = buf.readFloatLE(p), ty = buf.readFloatLE(p + 4), tz = buf.readFloatLE(p + 8); p += 12;
    p += 36; // rotation
    const scale = buf.readFloatLE(p); const scaleOff = p; p += 4;
    p += 4; // collision ref
    line += `  name="${name}" trans=(${tx.toFixed(1)},${ty.toFixed(1)},${tz.toFixed(1)}) scale=${scale} (scale@${scaleOff})`;
    if (t === 'BSTriShape') {
      const cx = buf.readFloatLE(p), cy = buf.readFloatLE(p + 4), cz = buf.readFloatLE(p + 8), r = buf.readFloatLE(p + 12);
      line += ` bound center=(${cx.toFixed(1)},${cy.toFixed(1)},${cz.toFixed(1)}) RADIUS=${r.toFixed(2)} (bound@${p})`;
    }
  }
  console.log(line);
}
