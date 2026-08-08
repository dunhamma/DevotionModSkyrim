// Phase 1a - cross-instance candidate queue.
// Bounds each installed modlist to its CONTENT mods using MO2's own separators,
// subtracts plugins the patch hub already targets, dedupes across lists, and
// ranks by how many lists carry the mod. No record reads, no houseCARL.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const HUB = path.join(REPO, 'dist/PDV_QuestModPatches_FOMOD/common');

// One profile per real TARGET list. Anvil is the dev environment, not a target.
const LISTS = [
  { list: 'ARR', inst: 'D:/Wabbajack/modlists/ARR 2.5', profile: 'KoK R11' },
  { list: 'DoD', inst: 'D:/Wabbajack/modlists/DoD', profile: "Diaries of Dibella - Lord's Vision" },
  { list: 'JoJ', inst: 'D:/Wabbajack/modlists/JoJ', profile: 'R11 Dev' },
];

// Separator name -> is this a CONTENT section?
const INCLUDE = /quest|newland|follower|adventure|dialogue|companion/i;
const EXCLUDE = /overhaul|resource|appearance|visual|replacer|face|weaker|bug ?fix|preset|patch/i;
const isContentSection = (s) => INCLUDE.test(s) && !EXCLUDE.test(s);

const read = (p) => fs.readFileSync(p, 'latin1').replace(/\r\n/g, '\n').split('\n');

// --- hub coverage: plugins already targeted by a shipped channel ---------------
const hubPlugins = new Set();
for (const dir of fs.readdirSync(HUB)) {
  const ch = path.join(HUB, dir, 'SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels');
  if (!fs.existsSync(ch)) continue;
  for (const f of fs.readdirSync(ch)) {
    const j = JSON.parse(fs.readFileSync(path.join(ch, f), 'utf8'));
    for (const p of j.stringList?.questWatchPlugins ?? []) hubPlugins.add(p.toLowerCase());
  }
}

// --- walk each list -----------------------------------------------------------
const mods = new Map(); // key: plugin filename (lc) -> {plugin, names, lists, sections}
const modFolderPlugins = []; // per list+folder: the plugin filenames it ships, for union-find
const sectionReport = [];

for (const { list, inst, profile } of LISTS) {
  const prof = path.join(inst, 'profiles', profile);
  if (!fs.existsSync(path.join(prof, 'modlist.txt'))) {
    sectionReport.push(`${list}: NO modlist.txt - skipped`);
    continue;
  }
  const active = new Set(
    read(path.join(prof, 'plugins.txt'))
      .filter((l) => l.startsWith('*'))
      .map((l) => l.slice(1).trim().toLowerCase())
      .filter(Boolean),
  );

  // index plugin filename -> mod folder, for this instance
  const modsRoot = path.join(inst, 'mods');
  const pluginOwner = new Map();
  for (const m of fs.readdirSync(modsRoot)) {
    let files;
    try { files = fs.readdirSync(path.join(modsRoot, m)); } catch { continue; }
    for (const f of files) {
      if (/\.es[pml]$/i.test(f)) {
        if (!pluginOwner.has(m)) pluginOwner.set(m, []);
        pluginOwner.get(m).push(f);
      }
    }
  }

  // modlist.txt is reverse-priority: a separator's members are the lines ABOVE it
  const ml = read(path.join(prof, 'modlist.txt')).filter(Boolean);
  let bucket = [];
  let matched = 0;
  const secNames = [];
  for (const line of ml) {
    const name = line.slice(1);
    if (name.endsWith('_separator')) {
      const sect = name.replace(/_separator$/, '');
      if (isContentSection(sect)) {
        secNames.push(`${sect} (${bucket.length})`);
        matched += bucket.length;
        // KEY ON THE PLUGIN FILENAME, not the MO2 mod folder name. Folder names
        // differ between lists for the same mod ("Tools of Kagrenac" vs "The Tools
        // of Kagrenac"), so folder-keying both under-dedupes and makes crossover a
        // fuzzy-name guess. The esp filename is stable across lists and is exactly
        // what the hub channels record in questWatchPlugins, so coverage becomes a
        // lookup instead of a heuristic.
        for (const m of bucket) {
          const plugins = (pluginOwner.get(m) ?? []).filter((f) => active.has(f.toLowerCase()));
          if (plugins.length > 1) modFolderPlugins.push(plugins);
          for (const p of plugins) {
            const key = p.toLowerCase();
            if (!mods.has(key)) mods.set(key, { plugin: p, names: new Set(), lists: new Set(), sections: new Set() });
            const e = mods.get(key);
            e.names.add(m);
            e.lists.add(list);
            e.sections.add(sect);
          }
        }
      }
      bucket = [];
      continue;
    }
    if (line.startsWith('+')) bucket.push(name);
  }
  sectionReport.push(`${list}: ${secNames.length} content sections, ${matched} mods in them`);
}

// --- coverage signals beyond plugin match -------------------------------------
// A QE mod usually adds stages to the VANILLA editor id, so its channel targets
// Skyrim.esm and a plugin-name match misses it entirely. Two extra signals.
const norm = (s) =>
  s.toLowerCase().replace(/[^a-z0-9]/g, '').replace(/questexpansion/g, 'qe');

const hubFolders = new Set(fs.readdirSync(HUB).filter((d) => !d.startsWith('_')).map(norm));

// Token-subset matching: substring alone cannot see through an infix
// ("Nilheim - Misc Quest Expansion" vs hub folder "NilheimQE").
const STOP = new Set(['the', 'of', 'a', 'and', 'misc', 'se', 'sse', 'mod', 'quest', 'expansion', 'dialogue']);
const toks = (s) =>
  new Set(
    s
      .replace(/([a-z])([A-Z])/g, '$1 $2')          // split CamelCase
      .replace(/quest expansion/gi, ' qe ')
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter((t) => t && t.length > 1 && !STOP.has(t)),
  );
const hubTokenSets = fs
  .readdirSync(HUB)
  .filter((d) => !d.startsWith('_'))
  .map((d) => ({ folder: d, t: toks(d) }));
const subset = (small, big) => small.size > 0 && [...small].every((x) => big.has(x));

// Full.csv quest_name column - what the matrix already reacts to, by name.
const full = read(path.join(REPO, 'references/authoring/PDV_QuestReactionMatrix_Full.csv'));
const questNames = new Set();
for (const line of full.slice(1)) {
  const cells = line.split(',');
  if (cells[1]) questNames.add(norm(cells[1]));
}

// Mod-name patterns that are never standalone content.
const NOISE =
  /\b(patch(es)?|replacer|retexture|bodyslide|3ba|himbo|cbbe|unp|smp|voiced|elevenlabs|xvasynth|revoiced|addon|fix(es|er)?|tweaks|ussep|bugfix|refit|preset|hotfix|update|esl version|eslified|files for|visual)\b/i;

// Addons that only EXTEND an already-covered mod - delayed-start gates, music
// fixers, banter/commentary patches, marker helpers. Their quests belong to the
// parent mod, which is either already patched or already in the queue on its own
// row, so treating them as separate work would double-count and mislead.
//
// "rerun" was here and was WRONG. It is not a content descriptor - it is a Wabbajack
// re-upload suffix a list appends to a mod FOLDER name. It excluded
// "Immersive Kaidan AIO - rerun", a 35-plugin content bundle carried by all three lists,
// on the strength of the packaging suffix alone. Repackaging notation says nothing about
// what a mod contains, so it must not decide a content bucket.
const ADDON = /\b(delayed start|music fix|map markers|quest markers|banter|commentary)\b/i;

const isNoiseName = (n) => NOISE.test(n) || ADDON.test(n);

// Identity joins on PLUGINS; work groups by MOD. Two lists' folders are the same
// mod iff their plugin sets intersect - so union-find over plugin filenames, and
// each component is one mod, one queue row, one future patch folder.
const parent = new Map();
const find = (x) => { while (parent.get(x) !== x) { parent.set(x, parent.get(parent.get(x))); x = parent.get(x); } return x; };
const union = (a, b) => { const ra = find(a), rb = find(b); if (ra !== rb) parent.set(ra, rb); };
for (const k of mods.keys()) parent.set(k, k);
for (const e of modFolderPlugins) {
  const ks = e.map((p) => p.toLowerCase()).filter((k) => mods.has(k));
  for (let i = 1; i < ks.length; i += 1) union(ks[0], ks[i]);
}

const groups = new Map();
for (const [key, e] of mods) {
  const root = find(key);
  if (!groups.has(root)) groups.set(root, { plugins: new Set(), names: new Set(), lists: new Set(), sections: new Set() });
  const g = groups.get(root);
  g.plugins.add(e.plugin);
  e.names.forEach((n) => g.names.add(n));
  e.lists.forEach((l) => g.lists.add(l));
  e.sections.forEach((s) => g.sections.add(s));
}

const rows = [...groups.values()].map((g) => {
  const plugins = [...g.plugins];
  const mod = [...g.names].sort((a, b) => a.length - b.length)[0];
  const covered = plugins.filter((p) => hubPlugins.has(p.toLowerCase())); // exact - definitive
  const mt = toks(mod);
  const hubMatch = hubTokenSets.find((h) => subset(h.t, mt) || subset(mt, h.t));
  // Judge EVERY folder name in the group, not just the representative one. The same mod
  // is named differently per list, and `mod` above is merely the SHORTEST of those names -
  // so testing it alone let one list's unlucky folder name bury the whole group. Immersive
  // Kaidan AIO lost by a single character: ARR's "- rerun" (28 chars) beat DoD's and JoJ's
  // "- V5.1.1"/"- V5.1.2" (29) to become the representative, and took 35 plugins with it.
  //
  // A group is noise only when NO alias reads as content. The error directions are not
  // symmetric: a wrong QUEUE row costs one triage read in Phase 1b, while a wrong NOISE
  // row is invisible and silently drops real content from the work list.
  const aliases = [...g.names];
  const cleanAliases = aliases.filter((a) => !isNoiseName(a));
  return {
    plugin: plugins.sort((a, b) => a.length - b.length)[0], plugins, mod,
    aliases, cleanAliases,
    lists: [...g.lists].sort(),
    sections: [...g.sections],
    bucket: covered.length ? 'COVERED'
      : cleanAliases.length ? 'QUEUE'
      : 'NOISE',
    // Advisory only. A hub folder with a similar name does NOT prove coverage:
    // Caught Red Handed QE overrides vanilla FreeformRiften11b and is absent from
    // Full.csv despite looking covered. Only a Phase 1b editor_id read settles it.
    hint: hubMatch ? `similar hub folder: ${hubMatch.folder} - VERIFY by editor_id` : '',
  };
});

const bySize = (a, b) => b.lists.length - a.lists.length || a.mod.localeCompare(b.mod);
const uncovered = rows.filter((r) => r.bucket === 'QUEUE').sort(bySize);
const noise = rows.filter((r) => r.bucket === 'NOISE').sort(bySize);
const covered = rows.filter((r) => r.bucket === 'COVERED');

const out = [];
out.push('# Phase 1a - cross-instance candidate queue');
out.push('');
sectionReport.forEach((s) => out.push(`- ${s}`));
out.push('');
out.push(`hub-targeted plugins        : ${hubPlugins.size}`);
out.push(`distinct content PLUGINS    : ${rows.length}`);
out.push(`  COVERED (exact plugin)    : ${covered.length}`);
out.push(`  NOISE (not standalone)    : ${noise.length}`);
out.push(`  QUEUE (real work)         : ${uncovered.length}`);
out.push('');
const byCount = {};
uncovered.forEach((r) => { byCount[r.lists.length] = (byCount[r.lists.length] ?? 0) + 1; });
out.push('queue by number of lists carrying the mod:');
Object.keys(byCount).sort((a, b) => b - a).forEach((k) => out.push(`  ${k} list(s): ${byCount[k]}`));
out.push('');
out.push('## QUEUE (ranked: most lists first)');
for (const r of uncovered) {
  out.push(`${r.lists.length}  [${r.lists.join(',')}]  ${r.plugin}`);
  out.push(`      mod: ${r.mod}${r.hint ? '   [' + r.hint + ']' : ''}`);
}
out.push('');
out.push('## NOISE - excluded as not-standalone-content. Listed, not silently dropped.');
out.push('');
out.push('Every folder name for the mod is shown, because the exclusion had to hold for all');
out.push('of them. PLUGINS is the group size - a large bundle called "not standalone" is the');
out.push('shape of a misclassification and is worth a second look before it is trusted.');
out.push('');
for (const r of noise) {
  out.push(`   [${r.lists.join(',')}]  ${r.plugin}  (${r.plugins.length} plugin${r.plugins.length === 1 ? '' : 's'})`);
  out.push(`        name${r.aliases.length === 1 ? '' : 's'}: ${r.aliases.join(' | ')}`);
}
out.push('');
out.push('## COVERED by EXACT plugin match (no new work)');
for (const r of covered.sort((a, b) => a.plugin.localeCompare(b.plugin))) {
  out.push(`   [${r.lists.join(',')}]  ${r.plugin}  (${r.mod})`);
}

const dest = process.env.PDV_QUEUE_OUT || path.join(REPO, 'generated', 'PDV_CandidateQueue.md');
fs.mkdirSync(path.dirname(dest), { recursive: true });
fs.writeFileSync(dest, out.join('\n'), 'utf8');
console.log(out.slice(0, 18).join('\n'));
console.log(`\nwrote ${dest}`);
