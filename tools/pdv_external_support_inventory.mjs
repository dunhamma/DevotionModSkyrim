#!/usr/bin/env node
/*
 * pdv_external_support_inventory.mjs
 *
 * Builds ONE machine-derived inventory of every piece of external-mod content
 * support Devotion ships, grouped by ATTACH MECHANISM (how the support reaches
 * the game), not by mod category.
 *
 * Groups:
 *   G1  per-mod quest-reaction patch, data-only  (common/<Mod>/ channel JSON, no plugin)
 *   G2  per-mod patch that ships a plugin        (plugins/individual/<Mod>/)
 *   G3  covered by the CORE mod, no patch        (rows in PDV_QuestReactionMatrix_Full.csv)
 *   G4  item-keyword support (KID)               (mod-data/.../PDV_GreenPact_KID.ini)
 *   G5  shrine / world-object support (BOS)      (SWAP ini inside a G2 patch)
 *   G6  Papyrus activity hooks, no quest stage   (plugin literals in live-source .psc)
 *
 * Output goes to generated/ and is GITIGNORED. Per PDV_STANDARDS, a report a
 * tool regenerates is never committed. The curated LIVING doc that cites these
 * numbers is references/authoring/PDV_ExternalModSupport_Inventory.md, and
 * --check gates that doc's declared counts against what this script measures.
 *
 * Usage:
 *   node tools/pdv_external_support_inventory.mjs                 # write generated/*.json + *.md
 *   node tools/pdv_external_support_inventory.mjs --check         # gate the curated doc's counts (exit 1 on drift)
 *   node tools/pdv_external_support_inventory.mjs --print         # dump the summary table to stdout
 *
 * SOURCE NOTE: this reads the GIT work tree, which is the audit source. The
 * compile toolchain reads the MO2 tree. If the two have drifted, the Papyrus
 * hook section (G6) can lag; see the source-drift entry in AGENTS.md.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const R = (...p) => path.join(ROOT, ...p);

const MANIFEST = R('references', 'authoring', 'PDV_QuestPatchHub.manifest.json');
const COMMON = R('dist', 'PDV_QuestModPatches_FOMOD', 'common');
const PLUGINS = R('dist', 'PDV_QuestModPatches_FOMOD', 'plugins', 'individual');
const PATCH_CSV_DIR = R('references', 'authoring', 'patches');
const CORE_CSV = R('references', 'authoring', 'PDV_QuestReactionMatrix_Full.csv');
const KID_INI = R('mod-data', 'SKSE', 'Plugins', 'KeywordItemDistributor', 'PDV_GreenPact_KID.ini');
const PSC_DIR = R('live-source', 'Scripts', 'Source');
const CURATED_DOC = R('references', 'authoring', 'PDV_ExternalModSupport_Inventory.md');
const OUT_DIR = R('generated');

/* ---------------------------------------------------------------- helpers */

// RFC4180-ish CSV reader. The matrix CSVs quote citation strings that contain
// commas and doubled quotes, so a naive split() silently shifts every column.
function parseCsv(text) {
  const rows = [];
  let row = [], field = '', inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') { field += '"'; i++; } else inQuotes = false;
      } else field += c;
    } else if (c === '"') inQuotes = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
    else if (c !== '\r') field += c;
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  if (!rows.length) return { header: [], records: [] };
  const header = rows[0].map((h) => h.trim());
  const records = rows.slice(1)
    .filter((r) => r.length > 1 && r.some((v) => v !== ''))
    .map((r) => Object.fromEntries(header.map((h, i) => [h, r[i] ?? ''])));
  return { header, records };
}

const readJson = (p) => JSON.parse(fs.readFileSync(p, 'utf8'));
const listDirs = (p) => (fs.existsSync(p)
  ? fs.readdirSync(p, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => d.name).sort()
  : []);
const uniq = (a) => [...new Set(a)];

/* -------------------------------------------------------- channel reading */

const CHANNEL_REL = path.join('SKSE', 'Plugins', 'StorageUtilData', 'PlayerDevotion', 'Channels');

// A channel carries the full shared faucet/stance table plus its own quest
// cells. Only the quest.<formid>|<stage>.* cells are mod-specific: those are
// the AWARD ROWS. A hub folder with a channel but no award rows ships nothing,
// which is exactly the "folder exists so it must be supported" trap.
function readChannel(modDir) {
  const dir = path.join(COMMON, modDir, CHANNEL_REL);
  if (!fs.existsSync(dir)) return null;
  const files = fs.readdirSync(dir).filter((f) => f.toLowerCase().endsWith('.json')).sort();
  if (!files.length) return null;

  const merged = {
    channelFiles: files,
    questKeys: [],
    questEditorIds: [],
    watchPlugins: [],
    awardRows: 0,
    deities: [],
    tags: [],
    cells: [],
  };

  for (const f of files) {
    const j = readJson(path.join(dir, f));
    const sl = j.stringList || {};
    const st = j.string || {};
    merged.questKeys.push(...(sl.questKeys || []));
    merged.questEditorIds.push(...(sl.questEditorIds || []));
    merged.watchPlugins.push(...(sl.questWatchPlugins || sl.questPlugins || []));

    for (const key of sl.questKeys || []) {
      const deities = sl[`quest.${key}.deities`] || [];
      const valences = sl[`quest.${key}.valences`] || [];
      const magnitudes = sl[`quest.${key}.magnitudes`] || [];
      const tags = sl[`quest.${key}.tags`] || [];
      const stage = String(key).split('|')[1] ?? '';
      merged.awardRows += deities.length;
      merged.deities.push(...deities);
      merged.tags.push(...tags);
      merged.cells.push({ key, stage, deities, valences, magnitudes, tags });
    }
    // runtimeVerify is a per-cell field the older ARR channel format carried.
    // The hub channels do not emit it; record it if a channel ever does again.
    for (const k of Object.keys(st)) {
      if (k.endsWith('.runtimeVerify')) {
        (merged.runtimeVerify ||= {})[k] = st[k];
      }
    }
  }

  merged.questKeys = uniq(merged.questKeys);
  merged.questEditorIds = uniq(merged.questEditorIds);
  merged.watchPlugins = uniq(merged.watchPlugins);
  merged.deities = uniq(merged.deities).sort();
  merged.tags = uniq(merged.tags).sort();
  return merged;
}

/* ------------------------------------------------------ per-mod source CSV */

// Source CSVs are named PDV_QRM_<Slug>.csv but the slug does NOT always equal
// the hub folder name (FrozenHeart/TheFrozenHeart, SlaysManyBeasts/
// WhispersOfTheDepths). Match on the DATA -- a CSV belongs to the mod whose
// channel watches the same target plugin -- and fall back to the name only
// when the data cannot decide.
function loadPatchCsvs() {
  const out = {};
  if (!fs.existsSync(PATCH_CSV_DIR)) return out;
  for (const f of fs.readdirSync(PATCH_CSV_DIR).filter((n) => /^PDV_QRM_.*\.csv$/i.test(n)).sort()) {
    const { records } = parseCsv(fs.readFileSync(path.join(PATCH_CSV_DIR, f), 'utf8'));
    const plugins = uniq(records.map((r) => (r.formid || '').split(':')[0]).filter(Boolean));
    out[f] = {
      file: f,
      slug: f.replace(/^PDV_QRM_/, '').replace(/\.csv$/i, ''),
      rows: records.length,
      editorIds: uniq(records.map((r) => r.editor_id).filter(Boolean)),
      plugins,
      deities: uniq(records.map((r) => r.deity).filter(Boolean)).sort(),
      reconstructed: records.some((r) => /RECONSTRUCTED/i.test(r.citation || '')),
      records,
    };
  }
  return out;
}

/* ------------------------------------------------------------ KID parsing */

function readKid() {
  if (!fs.existsSync(KID_INI)) return { path: null, rules: [], declaredLanes: [] };
  const text = fs.readFileSync(KID_INI, 'utf8');
  const rules = [];
  const templates = [];
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    const body = line.replace(/^;\s*/, '');
    const m = /^Keyword\s*=\s*(.+)$/i.exec(body);
    if (!m) continue;
    const parts = m[1].split('|');
    const entry = {
      keyword: (parts[0] || '').trim(),
      formType: (parts[1] || '').trim(),
      filters: (parts[2] || '').trim(),
      names: (parts[2] || '').split(',').map((s) => s.trim()).filter(Boolean),
    };
    if (line.startsWith(';')) templates.push(entry); else rules.push(entry);
  }
  // The commented block declares one template line per Green Pact food family.
  // A family with a live rule below is NOT an empty lane -- only the families
  // that never got a real rule are.
  const liveKeywords = new Set(rules.map((r) => r.keyword.toLowerCase()));
  const declaredLanes = templates.filter((t) => !liveKeywords.has(t.keyword.toLowerCase()));
  return {
    path: path.relative(ROOT, KID_INI).replace(/\\/g, '/'),
    rules,
    declaredLanes,
    templates,
    // Which external plugins the live rules are aimed at is a comment fact, not
    // a grammar fact: these rules match by item NAME, so they name no plugin.
    targetedByName: true,
  };
}

/* ------------------------------- BaseObjectSwapper (SWAP) ini, wherever it is */

// Copies of the same SWAP ini exist in the staging tree and in older packages.
// Only a copy under common/ actually installs (the FOMOD's <folder source> is
// always common\<Mod>), so group by content and record where each copy lives.
function findSwapInis() {
  const byContent = new Map();
  const walk = (dir) => {
    if (!fs.existsSync(dir)) return;
    for (const d of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, d.name);
      if (d.isDirectory()) walk(p);
      else if (/_SWAP\.ini$/i.test(d.name)) {
        const text = fs.readFileSync(p, 'utf8');
        const rel = path.relative(ROOT, p).replace(/\\/g, '/');
        if (!byContent.has(text)) {
          const entries = text.split(/\r?\n/)
            .map((l) => l.trim())
            .filter((l) => l && !l.startsWith(';') && !l.startsWith('[') && l.includes('|'))
            .map((l) => {
              const [from, to] = l.split('|');
              return { from: from.trim(), to: (to || '').trim(), sourcePlugin: (from.split('~')[1] || '').trim() };
            });
          byContent.set(text, {
            name: d.name,
            entries,
            sourcePlugins: uniq(entries.map((e) => e.sourcePlugin).filter(Boolean)).sort(),
            copies: [],
          });
        }
        const rec = byContent.get(text);
        rec.copies.push(rel);
        if (rel.includes('/common/')) rec.shippingPath = rel;
        rec.hubFolder = rec.shippingPath
          ? rec.shippingPath.split('/common/')[1].split('/')[0]
          : rec.hubFolder;
      }
    }
  };
  walk(R('dist'));
  walk(R('mod-data'));
  return [...byContent.values()].map((s) => ({ ...s, ships: Boolean(s.shippingPath) }));
}

/* -------------------------------------------- Papyrus external-plugin hooks */

// Anything the core scripts reach for by plugin NAME that is not the game's own
// masters or Devotion itself is an external integration wired in Papyrus with
// no quest-stage row and no patch folder. Guarded behind IsPluginInstalled /
// GetModByName, so an absent mod is a clean no-op.
const OWN_PLUGINS = new Set([
  'skyrim.esm', 'update.esm', 'dawnguard.esm', 'hearthfires.esm', 'dragonborn.esm', 'devotion.esp',
]);

function scanPapyrusHooks() {
  const hits = {};
  if (!fs.existsSync(PSC_DIR)) return { available: false, hooks: [] };
  for (const f of fs.readdirSync(PSC_DIR).filter((n) => n.toLowerCase().endsWith('.psc')).sort()) {
    const text = fs.readFileSync(path.join(PSC_DIR, f), 'utf8');
    const lines = text.split(/\r?\n/);
    lines.forEach((line, i) => {
      if (line.trim().startsWith(';')) return;
      for (const m of line.matchAll(/"([A-Za-z0-9_.'\- ]+\.(?:esp|esm|esl))"/g)) {
        const plugin = m[1];
        if (OWN_PLUGINS.has(plugin.toLowerCase())) continue;
        (hits[plugin] ||= { plugin, sites: [] }).sites.push(`${f}:${i + 1}`);
      }
    });
  }
  return { available: true, hooks: Object.values(hits).sort((a, b) => a.plugin.localeCompare(b.plugin)) };
}

/* ------------------------------------------------------------ core matrix */

// The core matrix has no formid column, so a row's owning plugin is inferred
// from the editor_id prefix. This is a CLASSIFICATION, not a readback -- an
// editor_id is only evidence of which quest, not of which file defines it.
function classifyCoreEditorId(id) {
  if (/^cc[A-Za-z0-9]+SSE\d+/i.test(id) || /^cc[A-Z]{3}SSE/i.test(id)) return 'creation-club';
  if (/^DLC[12]/i.test(id)) return 'dlc';
  return 'vanilla-or-dlc';
}

function loadCore() {
  const { records } = parseCsv(fs.readFileSync(CORE_CSV, 'utf8'));
  const byEditorId = new Map();
  for (const r of records) {
    const id = r.editor_id;
    if (!id) continue;
    if (!byEditorId.has(id)) {
      byEditorId.set(id, {
        editorId: id,
        questNames: new Set(),
        stages: new Set(),
        deities: new Set(),
        rows: 0,
        kind: classifyCoreEditorId(id),
      });
    }
    const e = byEditorId.get(id);
    e.rows++;
    if (r.quest_name) e.questNames.add(r.quest_name);
    if (r.outcome_stage) e.stages.add(r.outcome_stage);
    if (r.deity) e.deities.add(r.deity);
  }
  const entries = [...byEditorId.values()].map((e) => ({
    ...e,
    questNames: [...e.questNames].sort(),
    stages: [...e.stages].sort((a, b) => Number(a) - Number(b)),
    deities: [...e.deities].sort(),
  })).sort((a, b) => a.editorId.localeCompare(b.editorId));
  return { rows: records.length, editorIds: entries.length, entries };
}

// Quest-expansion mods that extend a VANILLA quest reach the player through the
// core matrix's vanilla editor_id -- no patch, no channel. These are the rows
// whose quest_name names the expansion explicitly.
function findQuestExpansionCoverage(core) {
  const marks = /\bQE\b|quest expansion|questexpansion/i;
  return core.entries.filter((e) => e.questNames.some((n) => marks.test(n)));
}

// The most confusing case in the whole inventory: a mod whose support is SPLIT
// -- core already reacts to the vanilla quest, and a hub patch adds only the
// mod's own new stages. Because ResolveQuestReactionCellFile checks core FIRST
// and takes the first hit, a patch cell that duplicates a (formid|stage) core
// already owns is DEAD. Report the overlap and whether any stage collides.
function findSplitCoverage(mods, core) {
  const byId = new Map(core.entries.map((e) => [e.editorId, e]));
  const split = [];
  for (const m of mods) {
    const shared = m.questEditorIds.filter((q) => byId.has(q));
    if (!shared.length) continue;
    for (const editorId of shared) {
      const coreEntry = byId.get(editorId);
      const idx = m.questEditorIds.indexOf(editorId);
      const patchKey = m.questKeys[idx];
      const patchStages = m.cells
        .filter((c) => c.key === patchKey || m.questKeys.length === 1)
        .map((c) => c.stage);
      const collidingStages = patchStages.filter((s) => coreEntry.stages.includes(String(s)));
      split.push({
        mod: m.name,
        folder: m.folder,
        dependency: m.dependency,
        editorId,
        coreStages: coreEntry.stages,
        coreRows: coreEntry.rows,
        coreQuestNames: coreEntry.questNames,
        patchStages: uniq(patchStages),
        collidingStages,
        verdict: collidingStages.length
          ? 'STAGE COLLISION -- core wins, the patch cell is dead'
          : 'clean split -- core owns the vanilla stages, the patch owns the mod stages',
      });
    }
  }
  return split;
}

// A patch can also be "split" without sharing an editor_id: the mod adds its own
// quest record that extends a vanilla questline core already covers. Detect via
// the mod's dependency name against core quest names.
//
// NOT EXHAUSTIVE, and deliberately so. This is a NAME heuristic, so a mod whose
// plugin name abbreviates its target (CH_IMBMDialougeAddon.esp for Ill Met By
// Moonlight) will not be found here even though its coverage is genuinely split.
// Absence from this list is not evidence that a mod is patch-only -- the curated
// doc carries the hand-confirmed cases.
function findRelatedCoreCoverage(mods, core) {
  const out = [];
  for (const m of mods) {
    if (!m.dependency) continue;
    const stem = m.dependency
      .replace(/\.(esp|esm|esl)$/i, '')
      .replace(/\b(quest expansion|dialogue addon|dialouge addon|addon|patch|mod)\b/gi, '')
      .replace(/[^A-Za-z ]/g, ' ')
      .trim();
    if (stem.length < 8) continue;
    const norm = (s) => s.toLowerCase().replace(/[^a-z]/g, '');
    const target = norm(stem);
    const hits = core.entries.filter((e) => e.questNames.some((n) => {
      const q = norm(n.replace(/\(.*\)/g, ''));
      if (q.length <= 6) return false;
      if (!q.includes(target) && !target.includes(q)) return false;
      // Require a substantial overlap. Without this, "Legacy of the Dragonborn"
      // swallows the vanilla quest literally named "Dragonborn".
      return Math.min(q.length, target.length) / Math.max(q.length, target.length) >= 0.6;
    }));
    if (hits.length) {
      out.push({
        mod: m.name,
        folder: m.folder,
        dependency: m.dependency,
        patchEditorIds: m.questEditorIds,
        coreEditorIds: hits.map((h) => ({ editorId: h.editorId, questNames: h.questNames, stages: h.stages, rows: h.rows })),
      });
    }
  }
  return out;
}

/* ------------------------------------------------------------------ build */

function build() {
  const manifest = readJson(MANIFEST);
  const commonDirs = listDirs(COMMON).filter((d) => !d.startsWith('_'));
  const supportDirs = listDirs(COMMON).filter((d) => d.startsWith('_'));
  const pluginDirs = listDirs(PLUGINS);
  const patchCsvs = loadPatchCsvs();
  const core = loadCore();

  // The unit of support is a manifest OPTION, not a folder: three options install
  // three folders each (channel + TIF fragments + the ESP staged under
  // plugins\individual), and two install a single folder that already contains an
  // ESP. Deriving "ships a plugin" from the channel folder alone gets both wrong.
  const optionByFolder = new Map();
  for (const opt of manifest.options || []) {
    const primary = (opt.folders || []).find((f) => /^common[\\/][^\\/]+$/i.test(f)) || (opt.folders || [])[0];
    if (primary) optionByFolder.set(primary.replace(/^common[\\/]/i, '').replace(/[\\/]+$/, ''), opt);
  }

  // Everything an option installs, flattened, so an ESP is found wherever it lives.
  const optionAssets = (opt) => {
    const merged = { esp: [], scripts: [], seq: [], swapIni: [], other: [] };
    for (const folder of opt?.folders || []) {
      const abs = R('dist', 'PDV_QuestModPatches_FOMOD', ...folder.split(/[\\/]/));
      if (!fs.existsSync(abs)) continue;
      const a = inventoryPluginDir(abs);
      for (const k of Object.keys(merged)) merged[k].push(...a[k].map((f) => `${folder.replace(/\\/g, '/')}/${f}`));
    }
    return merged;
  };

  const csvByPlugin = new Map();
  for (const c of Object.values(patchCsvs)) {
    for (const p of c.plugins) {
      if (!csvByPlugin.has(p.toLowerCase())) csvByPlugin.set(p.toLowerCase(), []);
      csvByPlugin.get(p.toLowerCase()).push(c);
    }
  }
  const usedCsvs = new Set();

  const mods = [];
  for (const dir of commonDirs) {
    const opt = optionByFolder.get(dir) || null;
    const channel = readChannel(dir);
    // What this option actually installs, across every folder it lists.
    const installed = opt
      ? optionAssets(opt)
      : inventoryPluginDir(path.join(COMMON, dir));
    const shipsPlugin = installed.esp.length > 0;

    // Resolve the source CSV by matching the target plugin the channel watches,
    // then by slug, then by the manifest dependency.
    let csv = null;
    const watchKeys = [
      ...(channel?.watchPlugins || []),
      ...(opt?.dependency ? [opt.dependency] : []),
    ].map((s) => s.toLowerCase());
    for (const k of watchKeys) {
      const hits = (csvByPlugin.get(k) || []).filter((c) => !usedCsvs.has(c.file));
      if (hits.length) { csv = hits[0]; break; }
    }
    if (!csv) {
      const bySlug = Object.values(patchCsvs).find((c) =>
        !usedCsvs.has(c.file) &&
        (c.slug.toLowerCase() === dir.toLowerCase() ||
         dir.toLowerCase().endsWith(c.slug.toLowerCase()) ||
         c.slug.toLowerCase().endsWith(dir.toLowerCase())));
      if (bySlug) csv = bySlug;
    }
    if (csv) usedCsvs.add(csv.file);

    // How the support actually reaches the game. A patch can ship a plugin and
    // award nothing through quest stages -- AFDI polls globals from a Papyrus
    // observer, DaedricShrinesAIO swaps statues to prayer activators -- so
    // "ships an ESP" and "reacts to quests" are independent facts.
    const mechanisms = [];
    if (channel?.awardRows) mechanisms.push('quest-reaction channel');
    if (installed.scripts.some((f) => /_Fragments\b/i.test(f) && /\.pex$/i.test(f))) mechanisms.push('TIF fragment scripts');
    if (installed.scripts.some((f) => !/_Fragments\b/i.test(f) && /\.pex$/i.test(f))) mechanisms.push('Papyrus observer script');
    if (installed.swapIni.length) mechanisms.push('BaseObjectSwapper swap');
    if (shipsPlugin && !mechanisms.length) mechanisms.push('plugin records only');

    mods.push({
      folder: dir,
      name: opt?.name || dir,
      inManifest: Boolean(opt),
      category: opt?.category || null,
      dependency: opt?.dependency || (channel?.watchPlugins?.[0] ?? null),
      description: opt?.description || null,
      group: shipsPlugin ? 'G2' : 'G1',
      shipsPlugin,
      mechanisms,
      pluginAssets: shipsPlugin ? installed : null,
      stagedUnderPluginsIndividual: pluginDirs.includes(dir),
      hasChannel: Boolean(channel),
      questCount: channel?.questEditorIds.length ?? 0,
      // A "cell" is one (formid|stage) resolution the channel reacts to. One
      // quest can carry several -- Bruma's four quests are eight resolutions.
      cellCount: channel?.questKeys.length ?? 0,
      questEditorIds: channel?.questEditorIds ?? [],
      questKeys: channel?.questKeys ?? [],
      awardRows: channel?.awardRows ?? 0,
      deities: channel?.deities ?? [],
      cells: channel?.cells ?? [],
      sourceCsv: csv ? csv.file : null,
      sourceCsvRows: csv ? csv.rows : 0,
      reconstructedCsv: csv ? csv.reconstructed : false,
      // Every hub option's description carries its own proof language. The
      // machine test is: does the description disclaim runtime evidence?
      runtimeEvidenceOpen: opt ? /runtime (evidence|branch evidence) remains open/i.test(opt.description || '') : null,
    });
  }

  // Plugin dirs with no hub folder would be a packaging hole; surface them.
  const orphanPluginDirs = pluginDirs.filter((d) => !commonDirs.includes(d));
  const orphanCsvs = Object.values(patchCsvs).filter((c) => !usedCsvs.has(c.file)).map((c) => c.file);
  const manifestWithoutFolder = (manifest.options || []).filter((o) =>
    (o.folders || []).every((f) => !commonDirs.includes(f.replace(/^common[\\/]/i, ''))));

  const kid = readKid();
  const swaps = findSwapInis();
  const papyrus = scanPapyrusHooks();
  const qe = findQuestExpansionCoverage(core);
  const split = findSplitCoverage(mods, core);
  const related = findRelatedCoreCoverage(mods, core);

  const g1 = mods.filter((m) => m.group === 'G1');
  const g2 = mods.filter((m) => m.group === 'G2');

  return {
    generatedAt: new Date().toISOString(),
    sourceTree: 'git work tree',
    manifest: { updated: manifest.updated, options: (manifest.options || []).length, moduleName: manifest.moduleName },
    counts: {
      g1DataOnlyPatches: g1.length,
      g2PluginPatches: g2.length,
      g1WithAwardRows: g1.filter((m) => m.awardRows > 0).length,
      g2WithAwardRows: g2.filter((m) => m.awardRows > 0).length,
      totalReactionCells: mods.reduce((n, m) => n + m.cellCount, 0),
      totalAwardRows: mods.reduce((n, m) => n + m.awardRows, 0),
      hubFoldersTotal: commonDirs.length,
      hubSupportFolders: supportDirs.length,
      manifestOptions: (manifest.options || []).length,
      sourceCsvs: Object.keys(patchCsvs).length,
      reconstructedCsvs: Object.values(patchCsvs).filter((c) => c.reconstructed).length,
      coreRows: core.rows,
      coreEditorIds: core.editorIds,
      coreQuestExpansionEditorIds: qe.length,
      coreCreationClubEditorIds: core.entries.filter((e) => e.kind === 'creation-club').length,
      splitCoverageMods: uniq(split.map((s) => s.folder)).length,
      splitCoverageCollisions: split.filter((s) => s.collidingStages.length).length,
      kidLiveRules: kid.rules.length,
      kidLiveRuleNames: kid.rules.reduce((n, r) => n + r.names.length, 0),
      kidDeclaredEmptyLanes: kid.declaredLanes.length,
      swapInisDistinct: swaps.filter((s) => s.ships).length,
      swapEntries: swaps.filter((s) => s.ships).reduce((n, s) => n + s.entries.length, 0),
      papyrusHookPlugins: papyrus.hooks.length,
    },
    integrity: {
      hubFoldersWithoutChannel: mods.filter((m) => !m.hasChannel).map((m) => m.folder),
      hubFoldersWithZeroAwardRows: mods.filter((m) => m.awardRows === 0).map((m) => m.folder),
      hubFoldersNotInManifest: mods.filter((m) => !m.inManifest).map((m) => m.folder),
      manifestOptionsWithoutFolder: manifestWithoutFolder.map((o) => o.name),
      orphanPluginDirs,
      unmatchedSourceCsvs: orphanCsvs,
      supportFolders: supportDirs,
    },
    categories: countBy(mods, (m) => m.category || '(uncategorised)'),
    mods,
    splitCoverage: split,
    relatedCoreCoverage: related,
    core: { rows: core.rows, editorIds: core.editorIds, questExpansions: qe, entries: core.entries },
    kid,
    swaps,
    papyrus,
  };
}

function countBy(items, keyFn) {
  const out = {};
  for (const i of items) { const k = keyFn(i); out[k] = (out[k] || 0) + 1; }
  return out;
}

function inventoryPluginDir(dir) {
  const assets = { esp: [], scripts: [], seq: [], swapIni: [], other: [] };
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) { walk(p); continue; }
      const rel = path.relative(dir, p).replace(/\\/g, '/');
      if (/\.esp$|\.esl$|\.esm$/i.test(e.name)) assets.esp.push(rel);
      else if (/\.pex$|\.psc$/i.test(e.name)) assets.scripts.push(rel);
      else if (/\.seq$/i.test(e.name)) assets.seq.push(rel);
      else if (/_SWAP\.ini$/i.test(e.name)) assets.swapIni.push(rel);
      else assets.other.push(rel);
    }
  };
  walk(dir);
  return assets;
}

/* ------------------------------------------------------------- rendering */

function renderMarkdown(inv) {
  const L = [];
  const c = inv.counts;
  L.push('# Devotion -- external-mod support inventory (GENERATED)');
  L.push('');
  L.push(`Generated ${inv.generatedAt} by \`tools/pdv_external_support_inventory.mjs\` from the git work tree.`);
  L.push('This file is gitignored. The curated LIVING doc is');
  L.push('`references/authoring/PDV_ExternalModSupport_Inventory.md`.');
  L.push('');
  L.push('## Counts');
  L.push('');
  L.push('| Metric | Value |');
  L.push('|---|---:|');
  for (const [k, v] of Object.entries(c)) L.push(`| ${k} | ${v} |`);
  L.push('');
  L.push('## G1/G2 -- per-mod patches');
  L.push('');
  L.push('| Mod | Group | Dependency | Category | Mechanism | Quests | Cells | Award rows | Deities | Source CSV | Reconstructed | Runtime open |');
  L.push('|---|---|---|---|---|---:|---:|---:|---|---|---|---|');
  for (const m of inv.mods) {
    L.push(`| ${m.name} | ${m.group} | \`${m.dependency ?? '?'}\` | ${m.category ?? '-'} | ${m.mechanisms.join(' + ')} | ${m.questCount} | ${m.cellCount} | ${m.awardRows} | ${m.deities.join(', ') || '-'} | ${m.sourceCsv ?? '-'} | ${m.reconstructedCsv ? 'yes' : ''} | ${m.runtimeEvidenceOpen ? 'yes' : ''} |`);
  }
  L.push('');
  L.push('## G3 -- core-matrix quest-expansion coverage');
  L.push('');
  for (const e of inv.core.questExpansions) {
    L.push(`- \`${e.editorId}\` -- ${e.questNames.join(' / ')} (stages ${e.stages.join(', ')}; ${e.rows} rows; ${e.deities.join(', ')})`);
  }
  L.push('');
  L.push('### Creation Club in core');
  L.push('');
  for (const e of inv.core.entries.filter((x) => x.kind === 'creation-club')) {
    L.push(`- \`${e.editorId}\` -- ${e.questNames.join(' / ')} (stage ${e.stages.join(', ')}; ${e.rows} rows; ${e.deities.join(', ')})`);
  }
  L.push('');
  L.push('### Split coverage (part core, part patch)');
  L.push('');
  for (const s of inv.splitCoverage) {
    L.push(`- **${s.mod}** \`${s.dependency}\`: core \`${s.editorId}\` stages ${s.coreStages.join(', ')} (${s.coreRows} rows); patch stages ${s.patchStages.join(', ')} -- ${s.verdict}`);
  }
  for (const r of inv.relatedCoreCoverage) {
    L.push(`- **${r.mod}** \`${r.dependency}\`: patch quests ${r.patchEditorIds.join(', ')}; core already covers ${r.coreEditorIds.map((c) => `${c.editorId} (${c.questNames.join('/')}, stages ${c.stages.join(', ')}, ${c.rows} rows)`).join('; ')}`);
  }
  L.push('');
  L.push('## G4 -- KID');
  L.push('');
  for (const r of inv.kid.rules) L.push(`- LIVE \`${r.keyword}\` | ${r.formType} | ${r.names.length} names: ${r.names.join(', ')}`);
  for (const r of inv.kid.declaredLanes) L.push(`- DECLARED-EMPTY \`${r.keyword}\` | ${r.formType}`);
  L.push('');
  L.push('## G5 -- BaseObjectSwapper');
  L.push('');
  for (const s of inv.swaps) {
    L.push(`- \`${s.name}\` ${s.ships ? `SHIPS via ${s.shippingPath}` : 'does not ship (staging/legacy copy only)'} -- ${s.entries.length} swaps from ${s.sourcePlugins.join(', ')}; ${s.copies.length} copy/copies on disk: ${s.copies.join(', ')}`);
  }
  L.push('');
  L.push('## G6 -- Papyrus hooks');
  L.push('');
  for (const h of inv.papyrus.hooks) L.push(`- \`${h.plugin}\` -- ${h.sites.length} site(s): ${h.sites.join(', ')}`);
  L.push('');
  L.push('## Integrity');
  L.push('');
  L.push('```json');
  L.push(JSON.stringify(inv.integrity, null, 2));
  L.push('```');
  L.push('');
  return L.join('\n');
}

/* ------------------------------------------------------------------ check */

// The curated doc declares its counts in an HTML comment block so this gate can
// compare them without parsing prose. Drift = exit 1.
const COUNT_BLOCK = /<!--\s*pdv-inventory-counts\s*(\{[\s\S]*?\})\s*-->/;

function check(inv) {
  if (!fs.existsSync(CURATED_DOC)) {
    console.error(`FAIL: curated doc missing: ${path.relative(ROOT, CURATED_DOC)}`);
    return 1;
  }
  const text = fs.readFileSync(CURATED_DOC, 'utf8');
  const m = COUNT_BLOCK.exec(text);
  if (!m) {
    console.error('FAIL: curated doc has no <!-- pdv-inventory-counts {...} --> block to gate against.');
    return 1;
  }
  let declared;
  try { declared = JSON.parse(m[1]); } catch (e) {
    console.error(`FAIL: counts block is not valid JSON: ${e.message}`);
    return 1;
  }
  const drift = [];
  for (const [k, v] of Object.entries(declared)) {
    if (!(k in inv.counts)) { drift.push(`${k}: declared ${v}, but the script measures no such metric`); continue; }
    if (inv.counts[k] !== v) drift.push(`${k}: doc says ${v}, live is ${inv.counts[k]}`);
  }
  const missing = Object.keys(inv.counts).filter((k) => !(k in declared));
  if (drift.length) {
    console.error('FAIL: curated doc has drifted from the shipped content.');
    for (const d of drift) console.error(`  - ${d}`);
    if (missing.length) console.error(`  (metrics not declared in the doc: ${missing.join(', ')})`);
    return 1;
  }
  console.log(`PASS: ${Object.keys(declared).length} declared counts match the shipped content.`);
  if (missing.length) console.log(`note: ${missing.length} measured metric(s) not declared in the doc: ${missing.join(', ')}`);
  return 0;
}

/* ------------------------------------------------------------------- main */

const argv = process.argv.slice(2);
const inv = build();

if (argv.includes('--check')) {
  process.exit(check(inv));
}

if (argv.includes('--print')) {
  console.log(JSON.stringify(inv.counts, null, 2));
  console.log(JSON.stringify(inv.integrity, null, 2));
  process.exit(0);
}

fs.mkdirSync(OUT_DIR, { recursive: true });
const jsonOut = path.join(OUT_DIR, 'PDV_ExternalModSupport_Inventory.json');
const mdOut = path.join(OUT_DIR, 'PDV_ExternalModSupport_Inventory.md');
fs.writeFileSync(jsonOut, JSON.stringify(inv, null, 2) + '\n', 'utf8');
fs.writeFileSync(mdOut, renderMarkdown(inv), 'utf8');
console.log(`wrote ${path.relative(ROOT, jsonOut)}`);
console.log(`wrote ${path.relative(ROOT, mdOut)}`);
console.log(JSON.stringify(inv.counts, null, 2));
