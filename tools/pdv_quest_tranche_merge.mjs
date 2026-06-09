import fs from "fs";
const Q = String.fromCharCode(34);
const files = [
  "references/authoring/PDV_QuestReactionMatrix_Tranche1.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche2.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche3_TempleFavor.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche4_ThinPantheon.csv",
];
let hdr = null;
const body = [];
for (const f of files) {
  const l = fs.readFileSync(f, "utf8").split(/\r?\n/).filter((x) => x.trim());
  if (!hdr) hdr = l[0];
  else if (l[0] !== hdr) { console.error("HEADER MISMATCH in " + f); process.exit(1); }
  body.push(...l.slice(1));
}
function eid(line) { let cur = "", q = false; for (const ch of line) { if (ch === Q) q = !q; else if (ch === "," && !q) return cur; else cur += ch; } return cur; }
const idx = body.map((line, i) => [line, i]);
idx.sort((a, b) => { const ea = eid(a[0]).toLowerCase(), eb = eid(b[0]).toLowerCase(); return ea < eb ? -1 : ea > eb ? 1 : a[1] - b[1]; });
fs.writeFileSync("references/authoring/PDV_QuestReactionMatrix_Full.csv", [hdr, ...idx.map((x) => x[0])].join("\r\n") + "\r\n");
console.log("Wrote Full.csv:", body.length, "cells (T1+T2+T3)");
function parse(f) { const t = fs.readFileSync(f, "utf8").split(/\r?\n/).filter((x) => x.trim()); t.shift(); return t.map((line) => { const c = []; let cur = "", q = false; for (const ch of line) { if (ch === Q) q = !q; else if (ch === "," && !q) { c.push(cur); cur = ""; } else cur += ch; } c.push(cur); return c; }); }
const r = parse("references/authoring/PDV_QuestReactionMatrix_Full.csv");
const d = {};
for (const row of r) { const dt = row[5], val = row[6], mag = row[8]; if (!d[dt]) d[dt] = { g: 0, gm: 0, l: 0, lm: 0 }; const o = d[dt]; if (val === "+") { o.g++; if (mag === "milestone") o.gm++; } else { o.l++; if (mag === "milestone") o.lm++; } }
console.log("Total cells:", r.length, "| Deities:", Object.keys(d).length, "| Quests:", new Set(r.map((x) => x[0])).size);
const focus = ["Dibella", "Mara", "Kynareth", "Zenithar", "Stendarr", "Arkay", "Meridia", "Tu" + String.fromCharCode(39) + "whacca"];
console.log("\nTHIN-AEDRA / TOUCHED DEITIES (gain[ms] / loss[ms] / net):");
for (const k of focus) { const v = d[k]; if (!v) { console.log(k, "(absent)"); continue; } console.log(k.padEnd(12), "gain " + v.g + "(" + v.gm + "ms)  loss " + v.l + "(" + v.lm + "ms)  net " + ((v.g - v.l) >= 0 ? "+" : "") + (v.g - v.l)); }
console.log("\nLoss-only deities now:", Object.entries(d).filter(([k, v]) => v.g === 0).map((x) => x[0]).join(", ") || "(none)");
console.log("Thin (<=2) now:", Object.entries(d).filter(([k, v]) => v.g + v.l <= 2).map((x) => x[0]).join(", "));
