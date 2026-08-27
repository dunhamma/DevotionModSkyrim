#!/usr/bin/env node
/**
 * pdv_journey_render.mjs - Render a race UX journey board from its JSON authority.
 *
 * One JSON per race under references/authoring/journeys/PDV_Journey_<Race>.json holds the
 * ordered player experience: acts, beats, and the verbatim text the game shows at each
 * beat with its source. This renders that into a visual board - words plus flow together.
 *
 * The JSON is the authority. The HTML is a generated report: gitignored, never hand-edited.
 *
 * Usage:
 *   node tools/pdv_journey_render.mjs --race Imperial
 *   node tools/pdv_journey_render.mjs --race Imperial --out <path>
 *   node tools/pdv_journey_render.mjs --race Imperial --check
 *   node tools/pdv_journey_render.mjs --all
 *
 * Exit code is the verdict: 0 = rendered/valid, 1 = invalid data.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, "..");
const DIR = path.join(REPO, "references", "authoring", "journeys");
const OUTDIR = path.join(REPO, "generated");

const STATUS = new Set(["built", "partial", "gap"]);
const CHANNEL = new Set(["push", "pull", "both", "none"]);
const CHANNEL_LABEL = { push: "push", pull: "pull", both: "push + pull", none: "nothing fires" };
const GAPKIND = new Set(["wiring", "writing", "design", "wiring + writing"]);
const GAPKIND_HELP = {
  "wiring": "code change - nothing to write until it exists",
  "writing": "it fires; the words are missing or thin",
  "design": "a decision is needed before wiring or writing",
  "wiring + writing": "needs a code change AND new words",
};

function parseArgs(argv) {
  const o = { race: null, out: null, check: false, all: false };
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--check") o.check = true;
    else if (a === "--all") o.all = true;
    else if (a === "--race") { o.race = argv[i + 1]; i += 1; }
    else if (a === "--out") { o.out = path.resolve(argv[i + 1] || ""); i += 1; }
    else if (a === "--help") { console.log("See header of tools/pdv_journey_render.mjs"); process.exit(0); }
    else { console.error(`pdv_journey_render: unknown flag ${a}`); process.exit(1); }
  }
  return o;
}

function validate(j, file) {
  const e = [];
  if (j.schema !== "pdv.race-journey.v1") e.push(`${file}: schema missing or unsupported`);
  if (!j.race) e.push(`${file}: race missing`);
  if (!j.meta || !j.meta.title) e.push(`${file}: meta.title missing`);
  const ids = new Set();
  const checkBeat = (b, where) => {
    if (!b.id) e.push(`${where}: beat with no id`);
    else if (ids.has(b.id)) e.push(`${where}: duplicate beat id "${b.id}"`);
    else ids.add(b.id);
    if (!b.title) e.push(`${where}/${b.id}: title missing`);
    if (!STATUS.has(b.status)) e.push(`${where}/${b.id}: bad status "${b.status}"`);
    if (!CHANNEL.has(b.channel)) e.push(`${where}/${b.id}: bad channel "${b.channel}"`);
    for (const l of b.lines || []) {
      if (!l.text) e.push(`${where}/${b.id}: line with no text`);
      if (!l.source) e.push(`${where}/${b.id}: line "${String(l.text).slice(0, 30)}..." has no source - every line must be traceable`);
    }
    if (b.channel === "none" && (b.lines || []).length) e.push(`${where}/${b.id}: channel "none" but lines are present`);
    if (b.status === "gap" && !b.gap) e.push(`${where}/${b.id}: status gap but no gap statement`);
    if (b.gap && !GAPKIND.has(b.gapKind)) e.push(`${where}/${b.id}: a gap must say what KIND it is - gapKind must be one of ${[...GAPKIND].join(", ")}, got "${b.gapKind}"`);
  };
  for (const act of j.acts || []) {
    if (!act.title) e.push(`${file}: act with no title`);
    for (const b of act.beats || []) checkBeat(b, act.id || act.title);
  }
  for (const b of j.branches || []) checkBeat(b, "branches");
  if (!(j.acts || []).length) e.push(`${file}: no acts`);
  return e;
}

const CSS = `
:root{
  --paper:#F4F2EE; --ink:#23262B; --ink-2:#4C525A; --ink-3:#7C848D;
  --card:#FFFFFF; --line:#DBD8D1; --accent:#7A4E36; --accent-soft:#F2E7DF;
  --push:#1F6F8B; --push-bg:#E2EFF4; --pull:#6B6382; --pull-bg:#EDEAF3;
  --built:#2E7D4F; --partial:#B07818; --gap:#B0392F; --gap-bg:#FBEAE7;
}
@media (prefers-color-scheme: dark){ :root:not([data-theme="light"]){
  --paper:#17181B; --ink:#E7E5E1; --ink-2:#AFB4BA; --ink-3:#7F868D;
  --card:#202327; --line:#343941; --accent:#D2A183; --accent-soft:#2E2621;
  --push:#7FBBD1; --push-bg:#1B2A31; --pull:#B0A5CC; --pull-bg:#25222E;
  --built:#67C08B; --partial:#D9A84E; --gap:#E8887C; --gap-bg:#331F1C;
}}
:root[data-theme="dark"]{
  --paper:#17181B; --ink:#E7E5E1; --ink-2:#AFB4BA; --ink-3:#7F868D;
  --card:#202327; --line:#343941; --accent:#D2A183; --accent-soft:#2E2621;
  --push:#7FBBD1; --push-bg:#1B2A31; --pull:#B0A5CC; --pull-bg:#25222E;
  --built:#67C08B; --partial:#D9A84E; --gap:#E8887C; --gap-bg:#331F1C;
}
*{box-sizing:border-box}
body{background:var(--paper);color:var(--ink);font-family:"Source Sans 3",system-ui,sans-serif;font-size:17px;line-height:1.6;margin:0;padding:0 22px 90px}
.wrap{max-width:1180px;margin:0 auto}
h1{font-family:"IM Fell English",Georgia,serif;font-weight:400;font-size:46px;margin:38px 0 6px;text-wrap:balance}
.sub{color:var(--ink-2);font-size:18px;max-width:66ch;margin:0 0 10px}
.meta{color:var(--ink-3);font-size:14px;font-family:"IBM Plex Mono",monospace;margin:0 0 6px}
.caveat{border-left:4px solid var(--accent);background:var(--card);border-radius:0 10px 10px 0;padding:12px 18px;margin:14px 0;font-size:16px;color:var(--ink-2);max-width:88ch}
.key{display:flex;flex-wrap:wrap;gap:10px;margin:22px 0 6px;font-size:15px}
.k{display:flex;align-items:center;gap:8px}
.dot{width:13px;height:13px;border-radius:50%;display:inline-block}
h2{font-family:"IM Fell English",Georgia,serif;font-weight:400;font-size:34px;margin:52px 0 2px;border-bottom:1px solid var(--line);padding-bottom:8px}
.actintro{color:var(--ink-2);font-size:16px;max-width:80ch;margin:6px 0 20px}
.beat{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:20px 22px;margin:0 0 16px;position:relative;border-left-width:5px}
.beat.built{border-left-color:var(--built)}
.beat.partial{border-left-color:var(--partial)}
.beat.gap{border-left-color:var(--gap)}
.bhead{display:flex;flex-wrap:wrap;align-items:baseline;gap:12px;margin-bottom:4px}
.bhead h3{margin:0;font-size:21px;font-weight:600;font-family:"IM Fell English",Georgia,serif;font-weight:400}
.chan{font-size:13px;font-weight:600;border-radius:20px;padding:2px 11px;letter-spacing:.02em}
.chan.push{color:var(--push);background:var(--push-bg)}
.chan.pull{color:var(--pull);background:var(--pull-bg)}
.chan.both{color:var(--push);background:var(--push-bg)}
.chan.none{color:var(--gap);background:var(--gap-bg)}
.trig{font-size:15px;color:var(--ink-3);margin:0 0 14px}
.trig b{color:var(--ink-2);font-weight:600}
.line{border-left:3px solid var(--accent-soft);padding:2px 0 2px 16px;margin:12px 0}
.line .txt{font-family:"IM Fell English",Georgia,serif;font-size:19px;line-height:1.55;color:var(--ink)}
.line .src{font-family:"IBM Plex Mono",monospace;font-size:12.5px;color:var(--ink-3);margin-top:5px}
.line .src b{color:var(--ink-2);font-weight:500}
.flag{display:inline-block;font-size:12.5px;font-weight:600;color:var(--gap);background:var(--gap-bg);border-radius:5px;padding:1px 8px;margin-left:8px}
.gapbox{background:var(--gap-bg);border-radius:10px;padding:12px 16px;margin:14px 0 0;font-size:16px;color:var(--ink)}
.gapbox b{color:var(--gap)}
.kindrow{margin-bottom:8px}
.kind{display:inline-block;font-size:12.5px;font-weight:600;letter-spacing:.06em;text-transform:uppercase;border-radius:5px;padding:2px 10px;color:#fff;background:var(--gap)}
.kind.kwiring{background:#1F6F8B}
.kind.kwriting{background:#7A4E36}
.kind.kdesign{background:#6B6382}
.kind.kwiringwriting{background:#8A5A2B}
.kindhelp{font-size:14px;color:var(--ink-2);margin-left:10px;font-style:italic}
.note{font-size:15px;color:var(--ink-2);margin:12px 0 0;font-style:italic}
.silent{font-family:"IM Fell English",Georgia,serif;font-size:19px;color:var(--ink-3);font-style:italic;padding:8px 0 2px}
ul.find{max-width:88ch;padding-left:22px}
ul.find li{margin:9px 0;font-size:17px}
.survey{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:20px 22px}
.survey .txt{font-family:"IM Fell English",Georgia,serif;font-size:18px;color:var(--ink);margin:8px 0 8px 14px}
@media (prefers-reduced-motion: no-preference){html{scroll-behavior:smooth}}
`;

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function line(l) {
  const flag = l.flag ? `<span class="flag">${esc(l.flag)}</span>` : "";
  return `<div class="line"><div class="txt">&ldquo;${esc(l.text)}&rdquo;${flag}</div>` +
    `<div class="src"><b>${esc(l.surface || "surface unstated")}</b> &middot; ${esc(l.source)}</div></div>`;
}

function beat(b) {
  const lines = (b.lines || []).length
    ? (b.lines || []).map(line).join("\n")
    : `<div class="silent">Nothing is shown to the player here.</div>`;
  const kind = b.gapKind
    ? `<span class="kind k-${b.gapKind.replace(/[^a-z]/g, "")}">${esc(b.gapKind)}</span><span class="kindhelp">${esc(GAPKIND_HELP[b.gapKind] || "")}</span>`
    : "";
  const gap = b.gap ? `<div class="gapbox"><div class="kindrow">${kind}</div>${esc(b.gap)}</div>` : "";
  const note = b.note ? `<p class="note">${esc(b.note)}</p>` : "";
  return `<div class="beat ${b.status}">
<div class="bhead"><h3>${esc(b.title)}</h3><span class="chan ${b.channel}">${CHANNEL_LABEL[b.channel]}</span></div>
<p class="trig"><b>Trigger:</b> ${esc(b.trigger || "unstated")}</p>
${lines}
${gap}${note}
</div>`;
}

function act(a) {
  return `<section id="${esc(a.id)}"><h2>${esc(a.title)}</h2>` +
    (a.intro ? `<p class="actintro">${esc(a.intro)}</p>` : "") +
    (a.beats || []).map(beat).join("\n") + `</section>`;
}

function render(j) {
  const counts = { built: 0, partial: 0, gap: 0 };
  const all = [...(j.acts || []).flatMap((a) => a.beats || []), ...(j.branches || [])];
  for (const b of all) counts[b.status] += 1;

  const survey = j.survey ? `<section id="survey"><h2>${esc(j.survey.title)}</h2>
<p class="actintro">${esc(j.survey.intro || "")}</p>
<div class="survey">
${(j.survey.base || []).map((t) => `<div class="txt">&ldquo;${esc(t)}&rdquo;</div>`).join("\n")}
<p class="note">Then, conditionally, in this order:</p>
${(j.survey.conditional || []).map((t) => `<div class="txt">&ldquo;${esc(t)}&rdquo;</div>`).join("\n")}
</div></section>` : "";

  return `<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(j.meta.title)}</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Source+Sans+3:wght@400;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>${CSS}</style>
<div class="wrap">
<h1>${esc(j.meta.title)}</h1>
<p class="sub">${esc(j.meta.subtitle || "")}</p>
<p class="meta">${esc(j.meta.statusLine || "")}</p>
<p class="meta">${counts.built} beats built &middot; ${counts.partial} partial &middot; ${counts.gap} with a real gap</p>
${(j.meta.caveats || []).map((c) => `<div class="caveat">${esc(c)}</div>`).join("\n")}
<div class="key">
  <div class="k"><span class="dot" style="background:var(--built)"></span> built</div>
  <div class="k"><span class="dot" style="background:var(--partial)"></span> partial &mdash; works, but something is missing or wrong</div>
  <div class="k"><span class="dot" style="background:var(--gap)"></span> gap &mdash; the player is told nothing</div>
  <div class="k"><span class="chan push">push</span> the game speaks</div>
  <div class="k"><span class="chan pull">pull</span> the player looks</div>
</div>
<div class="key">
  <div class="k"><span class="kind kwiring">wiring</span> code change needed</div>
  <div class="k"><span class="kind kwriting">writing</span> it fires, the words need work</div>
  <div class="k"><span class="kind kdesign">design</span> a decision comes first</div>
</div>
${(j.acts || []).map(act).join("\n")}
${(j.branches || []).length ? `<section id="branches"><h2>Branches</h2>` + j.branches.map(beat).join("\n") + `</section>` : ""}
${survey}
${(j.findings || []).length ? `<section id="findings"><h2>What this shows</h2><ul class="find">` +
    j.findings.map((f) => `<li>${esc(f)}</li>`).join("") + `</ul></section>` : ""}
</div>
`;
}

const opts = parseArgs(process.argv.slice(2));
let files = [];
if (opts.all) {
  files = fs.existsSync(DIR) ? fs.readdirSync(DIR).filter((f) => f.endsWith(".json")).map((f) => path.join(DIR, f)) : [];
} else if (opts.race) {
  files = [path.join(DIR, `PDV_Journey_${opts.race}.json`)];
} else {
  console.error("pdv_journey_render: pass --race <Race> or --all");
  process.exit(1);
}
if (!files.length) { console.error("pdv_journey_render: no journey files found"); process.exit(1); }

const results = [];
let bad = 0;
for (const file of files) {
  let j;
  try {
    j = JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (err) {
    console.error(`pdv_journey_render: cannot read ${path.relative(REPO, file)}: ${err.message}`);
    bad += 1;
    continue;
  }
  const errs = validate(j, path.basename(file));
  if (errs.length) {
    console.error(`pdv_journey_render: ${errs.length} problem(s) in ${path.basename(file)}:`);
    for (const e of errs) console.error(`  - ${e}`);
    bad += 1;
    continue;
  }
  const all = [...(j.acts || []).flatMap((a) => a.beats || []), ...(j.branches || [])];
  const counts = { built: 0, partial: 0, gap: 0 };
  for (const b of all) counts[b.status] += 1;
  const entry = { race: j.race, beats: all.length, ...counts };
  if (!opts.check) {
    const out = opts.out || path.join(OUTDIR, `PDV_Journey_${j.race}.html`);
    fs.mkdirSync(path.dirname(out), { recursive: true });
    fs.writeFileSync(out, render(j), "utf8");
    entry.out = path.relative(REPO, out).split(path.sep).join("/");
  }
  results.push(entry);
}
if (bad) process.exit(1);
console.log(JSON.stringify({ ok: true, mode: opts.check ? "check" : "render", journeys: results }));
