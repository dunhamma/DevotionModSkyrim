#!/usr/bin/env node
/**
 * pdv_atlas_render.mjs - Render the Race Architecture Atlas from its JSON authority.
 *
 * The atlas DATA lives in references/authoring/PDV_RaceArchitectureAtlas.json and is the
 * single editable authority: both Claude and Codex edit that file. This script turns it
 * into a standalone HTML page for reading (and for publishing as an artifact).
 *
 * The HTML is a generated report. It is gitignored on purpose - never commit it, and
 * never hand-edit it, or the two copies drift and the JSON stops being the authority.
 *
 * Usage:
 *   node tools/pdv_atlas_render.mjs                 Render to generated/PDV_RaceArchitectureAtlas.html
 *   node tools/pdv_atlas_render.mjs --out <path>    Render to an explicit path
 *   node tools/pdv_atlas_render.mjs --check         Validate the JSON only; exit 1 on problems
 *
 * Exit code is the verdict: 0 = rendered/valid, 1 = invalid data.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, "..");
const DATA = path.join(REPO, "references", "authoring", "PDV_RaceArchitectureAtlas.json");
const DEFAULT_OUT = path.join(REPO, "generated", "PDV_RaceArchitectureAtlas.html");

const STATUS = new Set(["built", "partial", "designed", "absent", "na"]);
const AUDIT_VERDICT = new Set([
  "record-layer-reconciled", "partial-reconciliation", "missing-player-communication",
  "design-decision-required", "not-applicable", "verified",
]);
const BADGE = { built: "built", partial: "partial", designed: "designed", absent: "absent", na: "&mdash;" };
const PILL = { b: "b", p: "p", d: "d", n: "n" };

function parseArgs(argv) {
  const opts = { out: DEFAULT_OUT, check: false };
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--check") opts.check = true;
    else if (a === "--out") { opts.out = path.resolve(argv[i + 1] || ""); i += 1; }
    else if (a === "--help") { console.log("See header of tools/pdv_atlas_render.mjs"); process.exit(0); }
    else { console.error(`pdv_atlas_render: unknown flag ${a}`); process.exit(1); }
  }
  return opts;
}

function validate(atlas) {
  const errs = [];
  if (!atlas.meta || !atlas.meta.title) errs.push("meta.title missing");
  if (!Array.isArray(atlas.races) || atlas.races.length === 0) errs.push("races[] missing or empty");
  const seen = new Set();
  const nodeIds = new Set();
  const auditProfiles = atlas.implementationAudit?.auditProfiles || {};
  const checkAudit = (item, context) => {
    if (!item.nodeId) errs.push(`${context}: nodeId missing`);
    else if (nodeIds.has(item.nodeId)) errs.push(`${context}: duplicate nodeId "${item.nodeId}"`);
    else nodeIds.add(item.nodeId);
    if (!item.audit) { errs.push(`${context}: audit missing`); return; }
    const profile = auditProfiles[item.audit.profile];
    if (!profile) errs.push(`${context}: unknown audit profile "${item.audit.profile}"`);
    if (!AUDIT_VERDICT.has(item.audit.verdict)) errs.push(`${context}: bad audit verdict "${item.audit.verdict}"`);
    if (!profile?.papyrus?.status) errs.push(`${context}: Papyrus audit status missing from profile`);
    if (!profile?.esp?.status && !item.audit.espOverride?.status) errs.push(`${context}: ESP audit status missing from profile/override`);
    if (!profile?.reachability?.status) errs.push(`${context}: reachability audit status missing from profile`);
    if (item.audit.copy && !Array.isArray(item.audit.copy.copyIds)) errs.push(`${context}: copyIds must be an array`);
  };
  for (const race of atlas.races || []) {
    if (!race.id) { errs.push(`race "${race.name || "?"}" has no id`); continue; }
    if (seen.has(race.id)) errs.push(`duplicate race id "${race.id}"`);
    seen.add(race.id);
    for (const lane of race.lanes || []) {
      for (const node of lane.nodes || []) {
        if (!node.title) errs.push(`${race.id}/${lane.name}: node with no title`);
        if (!STATUS.has(node.status)) errs.push(`${race.id}/${lane.name}/${node.title}: bad status "${node.status}"`);
        checkAudit(node, `${race.id}/${lane.name}/${node.title}`);
      }
      for (const stub of lane.stubs || []) {
        if (!STATUS.has(stub.status)) errs.push(`${race.id}/${lane.name}: stub "${stub.label}" bad status "${stub.status}"`);
        checkAudit(stub, `${race.id}/${lane.name}/stub/${stub.label}`);
      }
    }
  }
  for (const node of (atlas.daedric && atlas.daedric.nodes) || []) {
    if (!STATUS.has(node.status)) errs.push(`daedric/${node.title}: bad status "${node.status}"`);
    checkAudit(node, `daedric/${node.title}`);
  }
  if (atlas.implementationAudit?.schema !== "pdv.race-implementation-audit.v1") errs.push("implementationAudit schema missing or unsupported");
  const queueIds = new Set();
  for (const row of atlas.implementationAudit?.queue || []) {
    if (!row.auditId) errs.push("implementationAudit queue row has no auditId");
    else if (queueIds.has(row.auditId)) errs.push(`duplicate queue auditId "${row.auditId}"`);
    else queueIds.add(row.auditId);
    if (!row.playerImpact || !row.question || !row.gapClass) errs.push(`${row.auditId || "queue row"}: incomplete visible queue contract`);
    for (const nodeId of row.nodeIds || []) if (!nodeIds.has(nodeId)) errs.push(`${row.auditId}: unknown nodeId "${nodeId}"`);
  }
  const cols = ((atlas.matrix && atlas.matrix.columns) || []).length;
  for (const row of (atlas.matrix && atlas.matrix.rows) || []) {
    if ((row.cells || []).length !== cols - 1) {
      errs.push(`matrix row "${row.race}": ${(row.cells || []).length} cells, expected ${cols - 1}`);
    }
  }
  return errs;
}

const CSS = `
:root{
  --paper:#F2F3F1; --ink:#22262A; --ink-2:#4A5158; --ink-3:#79828A;
  --card:#FFFFFF; --line:#D4D8D4; --accent:#3E5C76; --accent-soft:#E3EAF1;
  --built:#2E7D4F; --built-bg:#E8F2EC; --partial:#B07818; --partial-bg:#F7EFDE;
  --designed:#7A5CC4; --designed-bg:#EFEAF9; --unver:#79828A; --unver-bg:#ECEEEC;
}
@media (prefers-color-scheme: dark){ :root:not([data-theme="light"]){
  --paper:#16191C; --ink:#E4E6E3; --ink-2:#AEB4B9; --ink-3:#7E858C;
  --card:#1F2429; --line:#343B41; --accent:#8FB0CC; --accent-soft:#26313C;
  --built:#67C08B; --built-bg:#1D2E24; --partial:#D9A84E; --partial-bg:#332A18;
  --designed:#AC93E8; --designed-bg:#292138; --unver:#8B9299; --unver-bg:#23272B;
}}
:root[data-theme="dark"]{
  --paper:#16191C; --ink:#E4E6E3; --ink-2:#AEB4B9; --ink-3:#7E858C;
  --card:#1F2429; --line:#343B41; --accent:#8FB0CC; --accent-soft:#26313C;
  --built:#67C08B; --built-bg:#1D2E24; --partial:#D9A84E; --partial-bg:#332A18;
  --designed:#AC93E8; --designed-bg:#292138; --unver:#8B9299; --unver-bg:#23272B;
}
*{box-sizing:border-box}
body{background:var(--paper);color:var(--ink);font-family:"Source Sans 3",system-ui,sans-serif;font-size:16px;line-height:1.55;margin:0;padding:0 24px 80px}
.wrap{max-width:1240px;margin:0 auto}
h1{font-family:"IM Fell English",Georgia,serif;font-weight:400;font-size:44px;margin:40px 0 4px;text-wrap:balance}
.sub{color:var(--ink-2);font-size:17px;max-width:70ch;margin:0 0 8px}
.meta{color:var(--ink-3);font-size:14px;font-family:"IBM Plex Mono",monospace}
nav{position:sticky;top:0;background:var(--paper);padding:14px 0;margin:24px 0 8px;border-bottom:1px solid var(--line);z-index:5;display:flex;flex-wrap:wrap;gap:8px}
nav a{color:var(--accent);text-decoration:none;font-size:15px;font-weight:600;padding:4px 12px;border:1px solid var(--line);border-radius:16px;background:var(--card)}
h2{font-family:"IM Fell English",Georgia,serif;font-weight:400;font-size:34px;margin:56px 0 2px}
h2 .tag{font-family:"Source Sans 3",sans-serif;font-size:14px;color:var(--ink-3);vertical-align:middle;margin-left:10px}
.racesub{color:var(--ink-2);font-size:16px;max-width:78ch;margin:2px 0 18px}
.lane{margin:18px 0}
.lanehead{display:flex;align-items:baseline;gap:12px;margin-bottom:4px}
.lanehead b{font-size:15px;letter-spacing:.06em;text-transform:uppercase;color:var(--accent)}
.track{display:flex;align-items:stretch;overflow-x:auto;padding:18px 2px 14px}
.node{position:relative;flex:0 0 auto;width:216px;background:var(--card);border:1.5px solid var(--line);border-radius:10px;padding:12px 14px 10px;margin-right:34px}
.node:not(:last-child)::after{content:"";position:absolute;right:-26px;top:50%;width:18px;height:2px;background:var(--ink-3)}
.node:not(:last-child)::before{content:"";position:absolute;right:-12px;top:50%;margin-top:-4px;border:5px solid transparent;border-left-color:var(--ink-3)}
.node h4{margin:0 0 3px;font-size:16px;font-weight:600;line-height:1.3}
.node p{margin:0;font-size:14px;color:var(--ink-2);line-height:1.45}
.node .mid{display:inline-block;margin-top:7px;font-family:"IBM Plex Mono",monospace;font-size:13px;color:var(--accent);background:var(--accent-soft);border-radius:5px;padding:1px 7px}
.badge{position:absolute;top:-12px;right:10px;font-size:13px;font-weight:600;border-radius:11px;padding:1px 10px;border:1.5px solid;background:var(--card)}
.s-built{border-color:var(--built)} .s-built>.badge{color:var(--built);border-color:var(--built);background:var(--built-bg)}
.s-partial{border-color:var(--partial)} .s-partial>.badge{color:var(--partial);border-color:var(--partial);background:var(--partial-bg)}
.s-designed{border-style:dashed;border-color:var(--designed)} .s-designed>.badge{color:var(--designed);border-color:var(--designed);background:var(--designed-bg)}
.s-absent{border-color:var(--line)} .s-absent>.badge{color:var(--ink-3);border-color:var(--line);background:var(--unver-bg)}
.s-na{border-color:var(--line)} .s-na>.badge{color:var(--ink-3);border-color:var(--line);background:var(--unver-bg)}
.stubs{display:flex;flex-wrap:wrap;gap:10px;margin:2px 0 6px}
.stub{font-size:14px;border:1.5px solid var(--line);border-radius:8px;background:var(--card);padding:6px 12px;color:var(--ink-2)}
.stub b{color:var(--ink);font-weight:600}
.stub.s-built{border-color:var(--built)} .stub.s-partial{border-color:var(--partial)}
.stub.s-designed{border-style:dashed;border-color:var(--designed)}
.legend{display:flex;flex-wrap:wrap;gap:14px;margin:20px 0 6px}
.lg{display:flex;align-items:center;gap:9px;font-size:15px}
.sw{width:34px;height:22px;border-radius:6px;border:2px solid;background:var(--card)}
.note{border-left:3px solid var(--accent);background:var(--card);border-radius:0 10px 10px 0;padding:12px 16px;margin:18px 0;font-size:15px;color:var(--ink-2);max-width:86ch}
.note b{color:var(--ink)}
code{font-family:"IBM Plex Mono",monospace;font-size:.92em;background:var(--accent-soft);border-radius:4px;padding:0 5px}
.ev{font-size:13px;color:var(--ink-3);font-family:"IBM Plex Mono",monospace;margin-top:6px;line-height:1.4;overflow-wrap:anywhere}
.auditline{font-size:12.5px;color:var(--accent);font-family:"IBM Plex Mono",monospace;margin-top:7px;line-height:1.35;overflow-wrap:anywhere}
.auditline.major,.auditline.blocking{color:var(--partial);font-weight:600}
.auditgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:12px;margin:16px 0}
.auditcard{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:13px 15px}
.auditcard h4{margin:0 0 4px;font-size:16px}.auditcard p{margin:4px 0;color:var(--ink-2);font-size:14px}.auditcard .meta{font-size:12.5px}
.mtx{overflow-x:auto;margin:16px 0}
table{border-collapse:collapse;font-size:14px;min-width:1100px}
th{font-size:13px;letter-spacing:.05em;text-transform:uppercase;color:var(--accent);text-align:left;padding:8px 12px;border-bottom:2px solid var(--line);white-space:nowrap}
td{padding:8px 12px;border-bottom:1px solid var(--line);vertical-align:top;color:var(--ink-2);max-width:220px}
td.race{font-family:"IM Fell English",Georgia,serif;font-size:17px;color:var(--ink);white-space:nowrap}
.pill{display:inline-block;font-size:12.5px;font-weight:600;border-radius:9px;padding:0 8px;border:1.5px solid}
.pill.b{color:var(--built);border-color:var(--built);background:var(--built-bg)}
.pill.p{color:var(--partial);border-color:var(--partial);background:var(--partial-bg)}
.pill.d{color:var(--designed);border-color:var(--designed);background:var(--designed-bg);border-style:dashed}
.pill.n{color:var(--ink-3);border-color:var(--line);background:var(--unver-bg)}
@media (prefers-reduced-motion: no-preference){ html{scroll-behavior:smooth} }
`;

function node(n) {
  const mid = n.moment ? `<span class="mid">${n.moment}</span>` : "";
  const ev = n.evidence ? `<div class="ev">${n.evidence}</div>` : "";
  const impact = n.audit?.playerImpact ? ` · ${n.audit.playerImpact}` : "";
  const audit = n.audit ? `<div class="auditline ${(n.audit.playerImpact || "").toLowerCase()}">${n.audit.verdict}${impact}</div>` : "";
  return `  <div class="node s-${n.status}"><span class="badge">${BADGE[n.status]}</span>` +
    `<h4>${n.title}</h4><p>${n.body || ""}</p>${mid}${ev}${audit}</div>`;
}

function stub(s) {
  const ev = s.evidence ? ` <span class="meta">${s.evidence}</span>` : "";
  const impact = s.audit?.playerImpact ? ` · ${s.audit.playerImpact}` : "";
  const audit = s.audit ? ` <span class="auditline ${(s.audit.playerImpact || "").toLowerCase()}">${s.audit.verdict}${impact}</span>` : "";
  return `  <div class="stub s-${s.status}"><b>${s.label}</b> &mdash; ${s.text}${ev}${audit}</div>`;
}

function implementationAudit(audit) {
  const rows = (audit.queue || []).map((q) => `<article class="auditcard"><h4>${q.race} · ${q.moment}</h4>` +
    `<div class="meta">${q.playerImpact} · ${q.gapClass} · ${q.status}</div><p>${q.question}</p>` +
    `<p><b>ESP:</b> ${q.espResult}</p></article>`).join("\n");
  return `<section id="implementation-audit"><h2>Implementation audit</h2>` +
    `<p class="racesub">Actionable discrepancies only. Verified nodes stay in the race lanes; runtime and player-surface proof remain separate.</p>` +
    `<div class="note"><b>Shared blocker:</b> ${audit.sourceDrift.detail}</div><div class="auditgrid">${rows}</div></section>`;
}

function lane(l) {
  const track = `<div class="track">\n${(l.nodes || []).map(node).join("\n")}\n</div>`;
  const stubs = (l.stubs || []).length
    ? `\n<div class="stubs">\n${l.stubs.map(stub).join("\n")}\n</div>`
    : "";
  return `<div class="lane"><div class="lanehead"><b>${l.name}</b></div>\n${track}${stubs}</div>`;
}

function race(r) {
  return `<section id="${r.id}">\n<h2>${r.name} <span class="tag">${r.tag}</span></h2>\n` +
    `<p class="racesub">${r.intro}</p>\n${(r.lanes || []).map(lane).join("\n")}\n</section>`;
}

function matrix(m) {
  const head = `<tr>${m.columns.map((c) => `<th>${c}</th>`).join("")}</tr>`;
  const rows = m.rows.map((r) => {
    const cells = r.cells.map((c) => {
      const inner = c.p ? `<span class="pill ${PILL[c.p] || "n"}">${c.t}</span>` : (c.b ? `<b>${c.t}</b>` : c.t);
      return `<td>${inner}</td>`;
    }).join("");
    return `<tr><td class="race">${r.race}</td>${cells}</tr>`;
  }).join("\n");
  return `<section id="matrix">\n<h2>Comparison matrix</h2>\n` +
    `<p class="racesub">The unevenness at a glance. Pills: <span class="pill b">built</span> ` +
    `<span class="pill p">partial</span> <span class="pill d">designed</span> ` +
    `<span class="pill n">absent / deliberate none</span></p>\n` +
    `<div class="mtx"><table>\n${head}\n${rows}\n</table></div>\n` +
    `<div class="note">${m.note}</div>\n</section>`;
}

function render(atlas) {
  const navLinks = [`<a href="#legend">Legend</a>`, `<a href="#implementation-audit">Implementation audit</a>`, `<a href="#daedric">Daedric track</a>`]
    .concat(atlas.races.map((r) => `<a href="#${r.id}">${r.name}</a>`))
    .concat([`<a href="#matrix">Matrix</a>`]).join("");
  const legend = atlas.legend.map((l) => {
    const style = l.status === "designed"
      ? `border-style:dashed;border-color:var(--designed)`
      : (l.status === "absent" ? `border-color:var(--line)` : `border-color:var(--${l.status})`);
    return `  <div class="lg"><span class="sw" style="${style}"></span> ${l.label}</div>`;
  }).join("\n");
  const daedricLane = lane({ name: "", nodes: atlas.daedric.nodes })
    .replace(`<div class="lanehead"><b></b></div>\n`, "");

  return `<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${atlas.meta.title}</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Source+Sans+3:wght@400;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>${CSS}</style>

<div class="wrap">
<h1>${atlas.meta.title}</h1>
<p class="sub">${atlas.meta.intro}</p>
<p class="meta">${atlas.meta.statusLine}</p>

<nav>${navLinks}</nav>

<section id="legend">
<h2>How to read a page</h2>
<p class="racesub">${atlas.readingGuide}</p>
<div class="legend">
${legend}
</div>
${atlas.notes.map((n) => `<div class="note">${n}</div>`).join("\n")}
</section>

${implementationAudit(atlas.implementationAudit)}

<section id="daedric">
<h2>${atlas.daedric.title} <span class="tag">${atlas.daedric.tag}</span></h2>
<p class="racesub">${atlas.daedric.intro}</p>
${daedricLane}
</section>

${atlas.races.map(race).join("\n\n")}

${matrix(atlas.matrix)}

</div>
`;
}

const opts = parseArgs(process.argv.slice(2));
let atlas;
try {
  atlas = JSON.parse(fs.readFileSync(DATA, "utf8"));
} catch (err) {
  console.error(`pdv_atlas_render: cannot read ${path.relative(REPO, DATA)}: ${err.message}`);
  process.exit(1);
}

const errs = validate(atlas);
if (errs.length) {
  console.error(`pdv_atlas_render: ${errs.length} problem(s) in the atlas data:`);
  for (const e of errs) console.error(`  - ${e}`);
  process.exit(1);
}

const counts = { built: 0, partial: 0, designed: 0, absent: 0, na: 0 };
for (const r of atlas.races) {
  for (const l of r.lanes || []) {
    for (const n of l.nodes || []) counts[n.status] += 1;
    for (const s of l.stubs || []) counts[s.status] += 1;
  }
}

if (opts.check) {
  console.log(JSON.stringify({ ok: true, races: atlas.races.length, nodes: counts }));
  process.exit(0);
}

fs.mkdirSync(path.dirname(opts.out), { recursive: true });
fs.writeFileSync(opts.out, render(atlas), "utf8");
console.log(JSON.stringify({
  ok: true,
  out: path.relative(REPO, opts.out).split(path.sep).join("/"),
  races: atlas.races.length,
  nodes: counts,
}));
