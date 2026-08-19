// For each of the 13 surviving base functions that still call lane code, report whether the
// owning adapter already exposes that lane function under a signal/query id, or whether the
// re-route needs a NEW id.
import fs from "node:fs";

const SRC = "live-source/Scripts/Source";
const RACES = ["Altmer","Bosmer","Khajiit","Argonian","Breton","Redguard","Nord","Dunmer","Orc","Imperial"];

const DECL = /^[ \t]*(?:[A-Za-z_][\w\[\]]*[ \t]+)?(?:Function|Event)[ \t]+([A-Za-z_]\w*)[ \t]*\(/i;
const END = /^[ \t]*(?:EndFunction|EndEvent)\b/i;

function blocks(file) {
  const out = [];
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
  let cur = null;
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(DECL);
    if (m && !cur) { cur = { name: m[1], line: i + 1, body: [] }; continue; }
    if (cur && END.test(lines[i])) { cur.text = cur.body.join("\n"); out.push(cur); cur = null; continue; }
    if (cur) cur.body.push(lines[i]);
  }
  return out;
}

// laneFn -> {race, ids:[]}  : which ids expose it, from every dispatch-shaped override
const exposed = new Map();
const lane = new Map();
for (const r of RACES) {
  const f = `${SRC}/PDV_OriginRuntime_${r}.psc`;
  if (!fs.existsSync(f)) continue;
  const bs = blocks(f);
  for (const b of bs) lane.set(b.name.toLowerCase(), r);
  for (const b of bs) {
    // Walk the dispatch body: remember the most recent id literal, attribute calls to it.
    let curId = null;
    for (const line of b.text.split("\n")) {
      const idm = line.match(/(?:signalId|queryId|detailKey|key)[ \t]*==[ \t]*"([^"]+)"/i);
      if (idm) curId = idm[1];
      for (const cm of line.matchAll(/\b([A-Za-z_]\w*)[ \t]*\(/g)) {
        const n = cm[1];
        if (!curId) continue;
        if (/^(if|elseif|while|return)$/i.test(n)) continue;
        const key = n.toLowerCase();
        if (!exposed.has(key)) exposed.set(key, { race: r, ids: new Set(), via: b.name });
        exposed.get(key).ids.add(b.name + ':"' + curId + '"');
      }
    }
  }
}

// The 13 survivors, from the earlier source-derived map.
const baseBlocks = blocks(`${SRC}/PDV_OriginRuntimeBase.psc`);
const survivors = baseBlocks.filter(b => !lane.has(b.name.toLowerCase()));

let needNew = 0, haveId = 0;
console.log("=== re-route feasibility for each surviving base fn ===");
for (const s of survivors) {
  const hits = new Set();
  for (const m of s.text.matchAll(/\b([A-Za-z_]\w*)[ \t]*\(/g)) {
    if (lane.has(m[1].toLowerCase())) hits.add(m[1]);
  }
  if (!hits.size) continue;
  console.log("\n" + s.name + "  (base:" + s.line + ")");
  for (const h of hits) {
    const e = exposed.get(h.toLowerCase());
    if (e) { haveId++; console.log("   OK   " + h + "  [" + lane.get(h.toLowerCase()) + "]  via " + [...e.ids].slice(0, 2).join(", ")); }
    else { needNew++; console.log("   NEW  " + h + "  [" + lane.get(h.toLowerCase()) + "]  -- no id exposes this yet"); }
  }
}
console.log("\nsummary: " + haveId + " lane call(s) already reachable by id, " + needNew + " need a new id/virtual");
