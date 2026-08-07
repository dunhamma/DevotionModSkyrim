import fs from "fs";
const Q = String.fromCharCode(34);
const files = [
  "references/authoring/PDV_QuestReactionMatrix_Tranche1.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche2.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche3_TempleFavor.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche4_ThinPantheon.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche5_AspectParity.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche6_CompatCore.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche7_CrossEcho.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche8_PoolExpansion.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche10_SignalFloor.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche11_MainQuestFullCoverage.csv",
  "references/authoring/PDV_QuestReactionMatrix_Tranche12_KhajiitFiveWealth.csv",
  // Reconciliation source, NOT a content tranche. The Innocence Lost QE s198
  // rows (ARR patchlist TODO-2, owner-ruled 2026-07-16) were authored straight
  // into Full.csv and never landed in a tranche, so the merge could not
  // reproduce them; the next regen would have silently dropped all four. Kept
  // as its own file so the historical tranches stay the record of what each
  // authoring pass actually shipped. See --check below.
  "references/authoring/PDV_QuestReactionMatrix_Reconciliation_2026-08-06.csv",
];
// A gate's verdict is its EXIT CODE. --check re-derives the merge, byte-compares
// against the on-disk Full.csv, and exits 1 on any drift WITHOUT writing.
// Callers must branch on the exit status, never on grepped output.
const checkOnly = process.argv.slice(2).includes("--check");
const FULL_CSV = "references/authoring/PDV_QuestReactionMatrix_Full.csv";
let hdr = null;
const rawBody = [];
for (const f of files) {
  const l = fs.readFileSync(f, "utf8").split(/\r?\n/).filter((x) => x.trim());
  if (!hdr) hdr = l[0];
  else if (l[0] !== hdr) { console.error("HEADER MISMATCH in " + f); process.exit(1); }
  rawBody.push(...l.slice(1));
}
function cells(line) {
  const out = [];
  let cur = "", q = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (q && ch === Q && line[i + 1] === Q) { cur += Q; i++; }
    else if (ch === Q) q = !q;
    else if (ch === "," && !q) { out.push(cur); cur = ""; }
    else cur += ch;
  }
  out.push(cur);
  return out;
}
const rank = (row) => (row[8] === "milestone" ? 100 : 0) + ({ C: 30, S: 20, m: 10 }[row[7]] ?? 0);
const byCell = new Map();
for (let i = 0; i < rawBody.length; i++) {
  const row = cells(rawBody[i]);
  const key = `${row[0]}|${row[2]}|${row[5]}`;
  if (!byCell.has(key)) byCell.set(key, []);
  byCell.get(key).push({ line: rawBody[i], row, order: i });
}
const body = [];
let duplicateRowsRemoved = 0;
for (const [key, entries] of byCell) {
  let candidates = entries;
  const valences = new Set(entries.map((entry) => entry.row[6]));
  if (valences.size > 1) {
    if (key === "T03|100|Kynareth" || key === "T03|100|Y'ffre") {
      candidates = entries.filter((entry) => entry.row[6] === "-");
    } else {
      console.error(`CONFLICTING VALENCE for ${key}`);
      process.exit(1);
    }
  }
  candidates.sort((a, b) => rank(b.row) - rank(a.row) || a.order - b.order);
  body.push(candidates[0].line);
  duplicateRowsRemoved += entries.length - 1;
}
function eid(line) { let cur = "", q = false; for (const ch of line) { if (ch === Q) q = !q; else if (ch === "," && !q) return cur; else cur += ch; } return cur; }
const idx = body.map((line, i) => [line, i]);
idx.sort((a, b) => { const ea = eid(a[0]).toLowerCase(), eb = eid(b[0]).toLowerCase(); return ea < eb ? -1 : ea > eb ? 1 : a[1] - b[1]; });
const rendered = [hdr, ...idx.map((x) => x[0])].join("\r\n") + "\r\n";
if (checkOnly) {
  const onDisk = fs.existsSync(FULL_CSV) ? fs.readFileSync(FULL_CSV, "utf8") : null;
  if (onDisk === rendered) {
    console.log("PASS: Full.csv reproduces from the tranche sources:", body.length, "cells");
  } else {
    // Report the differing KEYS, not a byte offset -- a single reordered row
    // would otherwise bury the real payload drift under a whole-file diff.
    const keyOf = (line) => { const c = cells(line); return `${c[0]}|${c[2]}|${c[5]}`; };
    const derivedMap = new Map(idx.map((x) => [keyOf(x[0]), x[0]]));
    const diskMap = new Map();
    if (onDisk !== null) {
      for (const line of onDisk.split(/\r?\n/).slice(1).filter((x) => x.trim())) diskMap.set(keyOf(line), line);
    }
    const onlyDisk = [...diskMap.keys()].filter((k) => !derivedMap.has(k));
    const onlyDerived = [...derivedMap.keys()].filter((k) => !diskMap.has(k));
    const changed = [...derivedMap].filter(([k, v]) => diskMap.has(k) && diskMap.get(k) !== v).map(([k]) => k);
    console.error("FAIL: Full.csv does not reproduce from the tranche sources.");
    if (onDisk === null) console.error("  " + FULL_CSV + " is missing.");
    console.error(`  derived ${derivedMap.size} cells | on-disk ${diskMap.size} cells`);
    for (const k of onlyDisk) console.error("  ONLY IN Full.csv (no tranche produces it): " + k);
    for (const k of onlyDerived) console.error("  ONLY IN tranches (missing from Full.csv): " + k);
    for (const k of changed) {
      console.error("  PAYLOAD DIFFERS: " + k);
      console.error("    Full.csv : " + diskMap.get(k));
      console.error("    tranches : " + derivedMap.get(k));
    }
    if (!onlyDisk.length && !onlyDerived.length && !changed.length) {
      console.error("  Cell sets and payloads agree; the difference is row ORDER or line endings.");
    }
    console.error("  Re-run without --check to regenerate, or fix the tranche source.");
    process.exit(1);
  }
} else {
  fs.writeFileSync(FULL_CSV, rendered);
  console.log("Wrote Full.csv:", body.length, `cells (${duplicateRowsRemoved} duplicate rows resolved by canonical merge)`);
}
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
