// Phase 1a - cross-instance candidate queue.
// Bounds each installed modlist to its CONTENT mods using MO2's own separators,
// subtracts plugins the patch hub already targets, dedupes across lists, and
// ranks by how many lists carry the mod.
//
// Names are a PRE-FILTER, not the answer. They were the answer once and were wrong in both
// directions: `Lucien - Immersive Fully Voiced Male Follower` was discarded because "Voiced"
// also appears in `VIGILANT - ElevenLabs Voiced` (Lucien defines 48 quests), while
// `Val Serano - Pirate Follower and Quest Adventure` was queued as real work on the strength
// of a doc calling it a verified negative (it defines 62). A structural QUST probe now runs
// alongside the names and the two are reported TOGETHER, with an explicit DISAGREEMENT
// section where they conflict. The probe supplies evidence; a human still decides.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { probePlugins } from './lib/pdv_qust_probe.mjs';

// Inline for now; migrates to the shared tools/lib/pdv_cli.mjs guard with the other 19
// self-test tools (issue #49).
const KNOWN_FLAGS = new Set(['--no-probe', '--no-cache']);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith('--') && !KNOWN_FLAGS.has(arg)) {
    console.error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(', ')}`);
    process.exit(2);
  }
}
const NO_PROBE = process.argv.includes('--no-probe');
const NO_CACHE = process.argv.includes('--no-cache');

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const HUB = path.join(REPO, 'dist/PDV_QuestModPatches_FOMOD/common');
const PROBE_CACHE = path.join(REPO, 'generated', 'PDV_CandidateQueue.probe-cache.json');

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
            if (!mods.has(key)) mods.set(key, { plugin: p, names: new Set(), lists: new Set(), sections: new Set(), paths: [] });
            const e = mods.get(key);
            e.names.add(m);
            e.lists.add(list);
            e.sections.add(sect);
            // Absolute path per list. The probe reads the FILE, so it needs a real path and
            // never an MO2 instance - which is also why it cannot disturb the shared,
            // persisted houseCARL instance pointer.
            e.paths.push(path.join(modsRoot, m, p));
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
  /\b(patch(es)?|replacer|retexture|bodyslide|3ba|himbo|cbbe|unp|smp|elevenlabs|xvasynth|revoiced|addon|fix(es|er)?|tweaks|ussep|bugfix|refit|preset|hotfix|update|esl version|eslified|files for|visual)\b/i;

// "voiced" was in the list above and INVERTED the result for five base follower mods.
//
// The word does two opposite jobs. In "Lucien - Immersive Fully Voiced Male Follower" or
// "Sa'chil - Custom Voiced Khajiit Follower" it is an adjective advertising the mod's own
// voice acting: that is CONTENT. In "VIGILANT - ElevenLabs Voiced" or "Olenveld Revoiced" it
// names the mod's whole purpose - re-dubbing a parent mod: that is an ADD-ON.
//
// Discriminate on which job it is doing. A voice ADD-ON leads with the parent mod and applies
// voicing to it; a voiced FOLLOWER carries a subject noun of its own. `revoiced`, `elevenlabs`
// and `xvasynth` stay in NOISE above because they only ever name the add-on job.
//
// The damage this did: Lucien (48 quests) and Remiel (55) were discarded on all three lists
// while their cosmetic makeovers were queued as real work.
const VOICE_ADDON = /\b(revoiced|re-voiced|voice(d)?\s+(addon|add-on|replacer|pack|patch)|(elevenlabs|xvasynth|ai)\s+voiced?)\b/i;
const VOICED_SUBJECT = /\b(voiced|voice acting)\b/i;
const isVoiceAddonName = (n) => VOICE_ADDON.test(n) || (VOICED_SUBJECT.test(n) && /\b(subtitle|missing lines|english addon|unsupported)\b/i.test(n));

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

const isNoiseName = (n) => NOISE.test(n) || ADDON.test(n) || isVoiceAddonName(n);

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
  if (!groups.has(root)) groups.set(root, { plugins: new Set(), names: new Set(), lists: new Set(), sections: new Set(), pathByPlugin: new Map() });
  const g = groups.get(root);
  g.plugins.add(e.plugin);
  e.names.forEach((n) => g.names.add(n));
  e.lists.forEach((l) => g.lists.add(l));
  e.sections.forEach((s) => g.sections.add(s));
  // One path per plugin is enough for evidence. Lists can carry different versions of the
  // same mod, so the first is representative rather than authoritative - a per-list version
  // difference is a Phase 1b concern, not a bucketing one.
  if (e.paths.length && !g.pathByPlugin.has(e.plugin)) g.pathByPlugin.set(e.plugin, e.paths[0]);
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
    paths: [...g.pathByPlugin.values()],
    lists: [...g.lists].sort(),
    sections: [...g.sections],
    nameBucket: covered.length ? 'COVERED'
      : cleanAliases.length ? 'QUEUE'
      : 'NOISE',
    bucket: covered.length ? 'COVERED'
      : cleanAliases.length ? 'QUEUE'
      : 'NOISE',
    // Advisory only. A hub folder with a similar name does NOT prove coverage:
    // Caught Red Handed QE overrides vanilla FreeformRiften11b and is absent from
    // Full.csv despite looking covered. Only a Phase 1b editor_id read settles it.
    hint: hubMatch ? `similar hub folder: ${hubMatch.folder} - VERIFY by editor_id` : '',
  };
});

// --- structural probe ----------------------------------------------------------
// COVERED rows are settled by an exact plugin match, so there is nothing to probe there.
const probeTargets = rows.filter((r) => r.bucket !== 'COVERED').flatMap((r) => r.paths);
let probeSummary = { probed: 0, cached: 0, degraded: NO_PROBE, reason: NO_PROBE ? '--no-probe' : '' };
let probeResults = new Map();

if (!NO_PROBE && probeTargets.length) {
  const res = await probePlugins(probeTargets, {
    cacheFile: NO_CACHE ? null : PROBE_CACHE,
    noCache: NO_CACHE,
    onProgress: (i, n) => { if (i === 1 || i % 25 === 0 || i === n) process.stderr.write(`\r  probing records ${i}/${n}   `); },
  });
  if (res.probed) process.stderr.write('\n');
  probeResults = res.results;
  probeSummary = { probed: res.probed, cached: res.cached, degraded: res.degraded, reason: res.reason ?? '' };
}

for (const r of rows) {
  const per = r.paths.map((p) => probeResults.get(p)).filter(Boolean);
  const known = per.filter((x) => typeof x.qustDefined === 'number');
  r.qustDefined = known.length ? known.reduce((a, x) => a + x.qustDefined, 0) : null;
  r.editorIds = known.flatMap((x) => x.editorIds ?? []);
  r.probeErrors = per.filter((x) => x.error).map((x) => x.error);
}

// The two directions are NOT the same finding and must not share a heading.
//
// Discarded-but-has-quests is the dangerous one: content the name threw away. Sorted by
// quest count because size is the tell - a dialogue patch defining ONE container quest is
// correctly noise, while a 40-quest mod in this list is a Lucien.
//
// Queued-but-defines-nothing is a pruning aid, not an error: it means the row cannot
// contribute quest-reaction rows. It does NOT mean the mod is unsupportable - the ARR
// non-quest sweep reached mods exactly like these through BaseObjectSwapper, Papyrus hooks
// and KID. It only means this lane is the wrong one.
const byQust = (a, b) => (b.qustDefined ?? 0) - (a.qustDefined ?? 0) || b.lists.length - a.lists.length;
const discardedWithQuests = rows
  .filter((r) => r.bucket === 'NOISE' && r.qustDefined > 0)
  .sort(byQust);
const queuedWithoutQuests = rows
  .filter((r) => r.bucket === 'QUEUE' && r.qustDefined === 0)
  .sort((a, b) => b.lists.length - a.lists.length || a.mod.localeCompare(b.mod));

const bySize = (a, b) => b.lists.length - a.lists.length || a.mod.localeCompare(b.mod);
const uncovered = rows.filter((r) => r.bucket === 'QUEUE').sort(bySize);
const noise = rows.filter((r) => r.bucket === 'NOISE').sort(bySize);
const covered = rows.filter((r) => r.bucket === 'COVERED');
const qustEvidence = (r) => (r.qustDefined === null ? 'QUST=?' : `QUST=${r.qustDefined}`);

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
if (probeSummary.degraded) {
  out.push('STRUCTURAL PROBE: **NOT RUN** - these buckets are NAME-DERIVED ONLY.');
  out.push(`  reason: ${probeSummary.reason}`);
  out.push('  Names alone have been wrong in both directions. Treat every bucket below as a');
  out.push('  hypothesis until a run with houseCARL available confirms it.');
} else {
  out.push(`structural QUST probe       : ${probeSummary.probed} read, ${probeSummary.cached} cached`);
  out.push(`  DISCARDED but defines quests   : ${discardedWithQuests.length}  <- possible lost content, triage first`);
  out.push(`  QUEUED but defines no quests   : ${queuedWithoutQuests.length}  <- cannot yield quest rows`);
}
out.push('');
const byCount = {};
uncovered.forEach((r) => { byCount[r.lists.length] = (byCount[r.lists.length] ?? 0) + 1; });
out.push('queue by number of lists carrying the mod:');
Object.keys(byCount).sort((a, b) => b - a).forEach((k) => out.push(`  ${k} list(s): ${byCount[k]}`));
out.push('');
if (!probeSummary.degraded) {
  out.push('## DISCARDED BY NAME, BUT DEFINES QUESTS - triage these first');
  out.push('');
  out.push('A QUST count proves records exist, NOT that they are player-facing content. The ARR');
  out.push('discovery waves already ruled out framework, controller, generated and appearance-only');
  out.push('quests, and a follower mod carries a pile of them (map-marker, riding, catch-up).');
  out.push('Size is the tell: ONE quest is usually a dialogue patch\'s container and correctly');
  out.push('noise; a large count in this list is a mod the name threw away. Read the ids, decide.');
  out.push('');
  if (discardedWithQuests.length === 0) out.push('   (none)');
  for (const r of discardedWithQuests) {
    out.push(`   [${r.lists.join(',')}]  ${r.plugin}  ${qustEvidence(r)}`);
    out.push(`        name${r.aliases.length === 1 ? '' : 's'}: ${r.aliases.join(' | ')}`);
    if (r.editorIds.length) out.push(`        quests: ${r.editorIds.slice(0, 10).join(', ')}${r.editorIds.length > 10 ? ` ... (+${r.editorIds.length - 10})` : ''}`);
  }
  out.push('');
  out.push('## QUEUED, BUT DEFINES NO QUESTS OF ITS OWN');
  out.push('');
  out.push('These cannot contribute quest-reaction rows - there is no stage to react to. That is');
  out.push('NOT the same as unsupportable: the ARR non-quest sweep reached mods like these through');
  out.push('BaseObjectSwapper, Papyrus hooks and KID. It only means this lane is the wrong one.');
  out.push('');
  if (queuedWithoutQuests.length === 0) out.push('   (none)');
  for (const r of queuedWithoutQuests) {
    out.push(`   [${r.lists.join(',')}]  ${r.plugin}  (${r.mod})`);
  }
  out.push('');
}
out.push('## QUEUE (ranked: most lists first)');
for (const r of uncovered) {
  out.push(`${r.lists.length}  [${r.lists.join(',')}]  ${r.plugin}  ${qustEvidence(r)}`);
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
  out.push(`   [${r.lists.join(',')}]  ${r.plugin}  (${r.plugins.length} plugin${r.plugins.length === 1 ? '' : 's'})  ${qustEvidence(r)}`);
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
