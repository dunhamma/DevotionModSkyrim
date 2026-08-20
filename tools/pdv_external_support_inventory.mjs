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
 *   G4  item-keyword support (KID)               (mod-data/PDV_*_KID.ini)
 *   G5  shrine / world-object support (BOS)      (SWAP ini inside a G2 patch)
 *   G6  Papyrus activity hooks, no quest stage   (plugin literals in live-source .psc)
 *   G7  NPC religious recognition (SPID)         (mod-data/PDV_*_DISTR.ini)
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

import { assertKnownFlags } from './lib/pdv_cli.mjs';

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(['--check', '--print', '--coverage']);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: 'pdv_external_support_inventory' });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const R = (...p) => path.join(ROOT, ...p);

const MANIFEST = R('references', 'authoring', 'PDV_QuestReactionCompatibility.manifest.json');
const PACKAGE_ROOT = R('dist', 'PDV_QuestModPatches_FOMOD');
const OFFICIAL_CATALOG = R('SKSE', 'Plugins', 'StorageUtilData', 'PlayerDevotion', 'PDV_QuestReactionPatches.v2.json');
const PATCH_CSV_DIR = R('references', 'authoring', 'patches');
const CORE_CSV = R('references', 'authoring', 'PDV_QuestReactionMatrix_Full.csv');
const DISTRIBUTOR_DIR = R('mod-data');
const SPID_INI = R('mod-data', 'PDV_ReligiousRecognition_DISTR.ini');
const PSC_DIR = R('live-source', 'Scripts', 'Source');
const CURATED_DOC = R('references', 'authoring', 'PDV_ExternalModSupport_Inventory.md');
const STANCE_MATRIX = R('references', 'phase4', 'PDV_StanceMatrix.csv');
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
const uniq = (a) => [...new Set(a)];

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
  const rules = [];
  const templates = [];
  const files = fs.existsSync(DISTRIBUTOR_DIR)
    ? fs.readdirSync(DISTRIBUTOR_DIR).filter((f) => /_KID.*\.ini$/i.test(f)).sort()
    : [];
  for (const file of files) {
    const text = fs.readFileSync(path.join(DISTRIBUTOR_DIR, file), 'utf8');
    for (const raw of text.split(/\r?\n/)) {
      const line = raw.trim();
      const body = line.replace(/^;\s*/, '');
      const m = /^Keyword\s*=\s*(.+)$/i.exec(body);
      if (!m) continue;
      const parts = m[1].split('|');
      const entry = {
        file,
        keyword: (parts[0] || '').trim(),
        formType: (parts[1] || '').trim(),
        filters: (parts[2] || '').trim(),
        names: (parts[2] || '').split(',').map((s) => s.trim()).filter(Boolean),
      };
      if (line.startsWith(';')) templates.push(entry); else rules.push(entry);
    }
  }
  // The commented block declares one template line per Green Pact food family.
  // A family with a live rule below is NOT an empty lane -- only the families
  // that never got a real rule are.
  const liveKeywords = new Set(rules.map((r) => r.keyword.toLowerCase()));
  const declaredLanes = templates.filter((t) => !liveKeywords.has(t.keyword.toLowerCase()));
  return {
    paths: files.map((file) => path.relative(ROOT, path.join(DISTRIBUTOR_DIR, file)).replace(/\\/g, '/')),
    rules,
    declaredLanes,
    templates,
    // Which external plugins the live rules are aimed at is a comment fact, not
    // a grammar fact: these rules match by item NAME, so they name no plugin.
    targetedByName: true,
  };
}

function readSpid() {
  if (!fs.existsSync(SPID_INI)) return { path: null, rules: [], keywords: [], factions: [] };
  const rules = fs.readFileSync(SPID_INI, 'utf8').split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith(';'))
    .map((line) => {
      const [typeRaw, valueRaw = ''] = line.split(/\s*=\s*/, 2);
      const parts = valueRaw.split('|');
      return { type: typeRaw, form: parts[0] || '', stringFilters: parts[1] || '', formFilters: parts[2] || '' };
    });
  return {
    path: path.relative(ROOT, SPID_INI).replace(/\\/g, '/'),
    rules,
    keywords: rules.filter((r) => r.type === 'Keyword'),
    factions: rules.filter((r) => r.type === 'Faction'),
  };
}

/* ------------------------------- BaseObjectSwapper (SWAP) ini, wherever it is */

// Copies of the same SWAP ini may exist in canonical adapter source and in the generated
// package. Only a copy under the generated adapters/ tree installs, so group by content and
// record the package-owned copy without treating source duplication as a second integration.
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
        if (rel.includes('/dist/PDV_QuestModPatches_FOMOD/adapters/') || rel.startsWith('dist/PDV_QuestModPatches_FOMOD/adapters/')) rec.shippingPath = rel;
        rec.hubFolder = rec.shippingPath
          ? rec.shippingPath.split('/adapters/')[1].split('/')[0]
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
  const deityTally = {};
  for (const r of records) {
    if (r.deity) deityTally[r.deity] = (deityTally[r.deity] || 0) + 1;
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
  return { rows: records.length, editorIds: entries.length, entries, deityTally };
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
      const patchStages = m.sourceRecords
        .filter((row) => row.editor_id === editorId)
        .map((row) => row.outcome_stage)
        .filter(Boolean);
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

// V3 is deliberately not a PatchHub: data-only sources are consolidated into one
// required catalog and only the five narrow mechanism adapters become FOMOD options.
// Keep the inventory keyed by source identity, rather than reconstructing support from
// package folders, so an installer layout cannot become a second compatibility authority.
function build() {
  const manifest = readJson(MANIFEST);
  const sources = manifest.sources || [];
  const catalog = readJson(OFFICIAL_CATALOG);
  const questKeys = catalog.stringList?.questkeys || [];
  const packageFiles = fs.readdirSync(PACKAGE_ROOT, { recursive: true }).map((file) => String(file).replace(/\\/g, '/'));
  const packagedCatalog = 'required/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionPatches.v2.json';
  const patchCsvs = loadPatchCsvs();
  const core = loadCore();
  const mods = sources.map((source) => {
    const sourcePrefix = `source.${source.sourceId}.`.toLowerCase();
    const keys = catalog.stringList?.[`${sourcePrefix}questkeys`] || [];
    const semanticKeys = catalog.stringList?.[`${sourcePrefix}semantickeys`] || [];
    const cells = keys.map((key) => ({
      kind: 'quest',
      key,
      stage: key.split('|')[2] || '',
      deities: catalog.stringList?.[`quest.${key}.deities`.toLowerCase()] || [],
      valences: catalog.stringList?.[`quest.${key}.valences`.toLowerCase()] || [],
      magnitudes: catalog.stringList?.[`quest.${key}.magnitudes`.toLowerCase()] || [],
      tags: catalog.stringList?.[`quest.${key}.tags`.toLowerCase()] || [],
    })).concat(semanticKeys.map((key) => ({
      kind: 'semantic',
      key,
      stage: '',
      deities: catalog.stringList?.[`semantic.${key}.deities`.toLowerCase()] || [],
      valences: catalog.stringList?.[`semantic.${key}.valences`.toLowerCase()] || [],
      magnitudes: catalog.stringList?.[`semantic.${key}.magnitudes`.toLowerCase()] || [],
      tags: catalog.stringList?.[`semantic.${key}.tags`.toLowerCase()] || [],
    })));
    const sourceCsv = source.csv || source.semanticCsv || null;
    const sourceRecords = sourceCsv && fs.existsSync(R(sourceCsv)) ? parseCsv(fs.readFileSync(R(sourceCsv), 'utf8')).records : [];
    const csv = sourceCsv ? {
      file: path.basename(sourceCsv),
      rows: sourceRecords.length,
      reconstructed: sourceRecords.some((row) => /RECONSTRUCTED/i.test(row.citation || '')),
    } : null;
    const assets = { esp: [], scripts: [], seq: [], swapIni: [], other: [] };
    for (const asset of source.package?.assets || []) {
      const target = `adapters/${source.sourceId}/${asset.destination}`.replace(/\\/g, '/');
      if (!packageFiles.includes(target)) continue;
      if (/\.esp$|\.esl$|\.esm$/i.test(target)) assets.esp.push(target);
      else if (/\.pex$|\.psc$/i.test(target)) assets.scripts.push(target);
      else if (/\.seq$/i.test(target)) assets.seq.push(target);
      else if (/_SWAP\.ini$/i.test(target)) assets.swapIni.push(target);
      else assets.other.push(target);
    }
    const deityTally = {};
    for (const cell of cells) for (const deity of cell.deities) deityTally[deity] = (deityTally[deity] || 0) + 1;
    const mechanisms = [];
    if (keys.length || semanticKeys.length) mechanisms.push('official v2 catalog');
    if (assets.scripts.some((file) => /TIF_/i.test(file))) mechanisms.push('TIF fragment scripts');
    if (assets.scripts.some((file) => !/TIF_/i.test(file) && /\.pex$/i.test(file))) mechanisms.push('Papyrus observer script');
    if (assets.swapIni.length) mechanisms.push('BaseObjectSwapper swap');
    if (assets.esp.length && !mechanisms.length) mechanisms.push('plugin records only');
    return {
      folder: source.sourceId,
      name: source.displayName,
      inManifest: true,
      category: source.package?.category || null,
      dependency: source.pluginName,
      description: source.package?.description || null,
      group: source.delivery === 'data-only' ? 'G1' : 'G2',
      shipsPlugin: assets.esp.length > 0,
      mechanisms,
      pluginAssets: assets.esp.length ? assets : null,
      stagedUnderPluginsIndividual: false,
      hasChannel: false,
      questCount: new Set(keys.map((key) => key.split('|')[1])).size,
      cellCount: keys.length + semanticKeys.length,
      questEditorIds: uniq(sourceRecords.map((row) => row.editor_id).filter(Boolean)),
      questKeys: keys,
      sourceRecords,
      awardRows: cells.reduce((sum, cell) => sum + cell.deities.length, 0),
      deities: uniq(cells.flatMap((cell) => cell.deities)).sort(),
      deityTally,
      cells,
      sourceCsv: csv?.file || null,
      sourceCsvRows: csv?.rows || 0,
      reconstructedCsv: csv?.reconstructed || false,
      runtimeEvidenceOpen: true,
    };
  });
  const kid = readKid();
  const spid = readSpid();
  const swaps = findSwapInis();
  const papyrus = scanPapyrusHooks();
  const qe = findQuestExpansionCoverage(core);
  const split = findSplitCoverage(mods, core);
  const related = findRelatedCoreCoverage(mods, core);
  for (const mod of mods) delete mod.sourceRecords;
  const g1 = mods.filter((mod) => mod.group === 'G1');
  const g2 = mods.filter((mod) => mod.group === 'G2');
  return {
    generatedAt: new Date().toISOString(), sourceTree: 'git work tree',
    manifest: { updated: manifest.version, options: sources.length, moduleName: manifest.packageContract?.moduleName },
    counts: {
      g1DataOnlyPatches: g1.length, g2PluginPatches: g2.length,
      g1WithAwardRows: g1.filter((mod) => mod.awardRows > 0).length,
      g2WithAwardRows: g2.filter((mod) => mod.awardRows > 0).length,
      totalReactionCells: mods.reduce((sum, mod) => sum + mod.cellCount, 0),
      totalAwardRows: mods.reduce((sum, mod) => sum + mod.awardRows, 0),
      hubFoldersTotal: 0, hubSupportFolders: 0, manifestOptions: sources.length,
      sourceCsvs: sources.filter((source) => source.csv).length,
      reconstructedCsvs: 0, coreRows: core.rows, coreEditorIds: core.editorIds,
      coreQuestExpansionEditorIds: qe.length, coreCreationClubEditorIds: core.entries.filter((entry) => entry.kind === 'creation-club').length,
      splitCoverageMods: uniq(split.map((entry) => entry.folder)).length, splitCoverageCollisions: split.filter((entry) => entry.collidingStages.length).length,
      kidLiveRules: kid.rules.length, kidLiveRuleNames: kid.rules.reduce((sum, rule) => sum + rule.names.length, 0), kidDeclaredEmptyLanes: kid.declaredLanes.length,
      spidLiveRules: spid.rules.length, spidKeywordRules: spid.keywords.length, spidFactionRules: spid.factions.length,
      swapInisDistinct: swaps.filter((swap) => swap.ships).length, swapEntries: swaps.filter((swap) => swap.ships).reduce((sum, swap) => sum + swap.entries.length, 0), papyrusHookPlugins: papyrus.hooks.length,
      officialCatalogFiles: packageFiles.filter((file) => file === packagedCatalog).length,
      adapterOptions: sources.filter((source) => source.delivery !== 'data-only').length,
      dataOnlyFomodOptions: 0,
    },
    integrity: {
      hubFoldersWithoutChannel: [], hubFoldersWithZeroAwardRows: [], hubFoldersNotInManifest: [], manifestOptionsWithoutFolder: [], orphanPluginDirs: [],
      unmatchedSourceCsvs: Object.values(patchCsvs).filter((csv) => !sources.some((source) => path.basename(source.csv || '') === csv.file)).map((csv) => csv.file),
      supportFolders: [],
      officialCatalogExactlyOnce: packageFiles.filter((file) => file === packagedCatalog).length === 1,
      noLegacyChannelPayloads: !packageFiles.some((file) => file.includes('/Channels/') || file.includes('/QuestStageAdapters/')),
      adapterAssetsPresent: sources.filter((source) => source.delivery !== 'data-only').every((source) => (source.package?.assets || []).every((asset) => packageFiles.includes(`adapters/${source.sourceId}/${asset.destination}`.replace(/\\/g, '/')))),
    },
    categories: countBy(mods, (mod) => mod.category || '(uncategorised)'), mods, splitCoverage: split, relatedCoreCoverage: related,
    core: { rows: core.rows, editorIds: core.editorIds, questExpansions: qe, entries: core.entries, deityTally: core.deityTally }, kid, spid, swaps, papyrus,
  };
}

// ---------------------------------------------------------------------------------------
// COVERAGE -- who actually benefits, not just what ships.
//
// Everything above this line counts MECHANISMS: options, folders, channels, inis. None of
// it can answer "is the Hist getting as many opportunities as the others", which is the
// question that actually decides whether a race lane feels alive. That went unasked until
// 2026-08-09, when a hand-rolled script found Argonian last of ten lanes at 36 rows per god
// against a median of ~70, and the Hist itself 43rd of 44 deities. A number nobody has to
// remember to go and compute is the only kind that gets computed.
//
// The floor is RELATIVE (a fraction of the median), not a constant. A fixed floor needs
// retuning every time the matrix grows and silently stops meaning anything in between; a
// relative one keeps asking the same question -- "is this god far behind its peers" --
// at any scale.
const FLOOR_FRACTION = 0.6;
const COVERAGE_WAIVERS = R('references', 'authoring', 'PDV_CoverageFloorWaivers.csv');

function loadCoverageWaivers() {
  if (!fs.existsSync(COVERAGE_WAIVERS)) return new Map();
  const { records } = parseCsv(fs.readFileSync(COVERAGE_WAIVERS, 'utf8'));
  return new Map(records.filter((r) => r.subject).map((r) => [`${r.kind}:${r.subject}`, r.reason]));
}

const median = (ns) => {
  if (!ns.length) return 0;
  const s = [...ns].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : Math.round((s[m - 1] + s[m]) / 2);
};

function buildCoverage(inv) {
  // Deity totals: core matrix rows plus every channel's rows.
  const total = { ...inv.core.deityTally };
  for (const m of inv.mods) {
    for (const [d, n] of Object.entries(m.deityTally || {})) total[d] = (total[d] || 0) + n;
  }

  // Race rosters come from the stance matrix's NATIVE cells. A worship object whose name
  // differs from the matrix deity name (slash aliases like "Azura / Azurah") is resolved by
  // trying each slash-part; one that resolves to nothing is REPORTED, never silently
  // dropped -- a lane can only be judged thin if we know what is in it.
  const races = {};
  const unresolved = [];
  if (fs.existsSync(STANCE_MATRIX)) {
    const { header, records } = parseCsv(fs.readFileSync(STANCE_MATRIX, 'utf8'));
    const raceCols = header.slice(2, 12);
    for (const rc of raceCols) races[rc] = { gods: [], rows: 0 };
    for (const rec of records) {
      const god = (rec.WorshipObject || '').trim();
      if (!god) continue;
      for (const rc of raceCols) {
        if ((rec[rc] || '').trim() !== 'NATIVE') continue;
        // Three name shapes have to reconcile: the stance matrix's worship-object name, the
        // matrix deity name, and the slash-alias form. "Hist" vs "The Hist" is the one that
        // bites -- without the article variant the Argonian lane silently reports Sithis
        // alone, which is both wrong AND flattering, since it hides the thinnest god in the
        // pantheon behind a smaller divisor.
        const variants = god.split('/').flatMap((p) => {
          const t = p.trim();
          return [t, `The ${t}`, t.replace(/^The\s+/i, '')];
        });
        const name = variants.find((v) => total[v] != null);
        if (!name) { unresolved.push(`${rc}: ${god}`); continue; }
        races[rc].gods.push(name);
        races[rc].rows += total[name];
      }
    }
  }

  const deityRows = Object.entries(total).map(([deity, rows]) => ({ deity, rows })).sort((a, b) => a.rows - b.rows);
  const deityFloor = Math.round(median(deityRows.map((d) => d.rows)) * FLOOR_FRACTION);

  const raceRows = Object.entries(races)
    .filter(([, v]) => v.gods.length)
    .map(([race, v]) => ({ race, gods: v.gods.length, rows: v.rows, perGod: Math.round(v.rows / v.gods.length) }))
    .sort((a, b) => a.perGod - b.perGod);
  const raceFloor = Math.round(median(raceRows.map((r) => r.perGod)) * FLOOR_FRACTION);

  const waivers = loadCoverageWaivers();
  const under = [
    ...deityRows.filter((d) => d.rows < deityFloor)
      .map((d) => ({ kind: 'deity', subject: d.deity, value: d.rows, floor: deityFloor })),
    ...raceRows.filter((r) => r.perGod < raceFloor)
      .map((r) => ({ kind: 'race', subject: r.race, value: r.perGod, floor: raceFloor })),
  ].map((u) => ({ ...u, waiver: waivers.get(`${u.kind}:${u.subject}`) || null }));

  return {
    deityFloor, raceFloor, floorFraction: FLOOR_FRACTION,
    deityMedian: median(deityRows.map((d) => d.rows)),
    raceMedian: median(raceRows.map((r) => r.perGod)),
    deityRows, raceRows, unresolvedWorshipObjects: uniq(unresolved), under,
    breaches: under.filter((u) => !u.waiver),
  };
}

function reportCoverage(inv) {
  const c = buildCoverage(inv);
  console.log(`deity rows: median ${c.deityMedian}, floor ${c.deityFloor} (${Math.round(c.floorFraction * 100)}% of median)`);
  for (const d of c.deityRows.slice(0, 8)) {
    const w = c.under.find((u) => u.kind === 'deity' && u.subject === d.deity);
    console.log(`  ${String(d.rows).padStart(4)}  ${d.deity.padEnd(16)}${d.rows < c.deityFloor ? (w?.waiver ? 'UNDER-FLOOR (waived)' : 'UNDER-FLOOR') : ''}`);
  }
  console.log(`  ... ${c.deityRows.length} deities total, highest ${c.deityRows[c.deityRows.length - 1].rows}`);
  console.log(`\nrace lanes: median ${c.raceMedian} rows/god, floor ${c.raceFloor}`);
  for (const r of c.raceRows) {
    const w = c.under.find((u) => u.kind === 'race' && u.subject === r.race);
    console.log(`  ${String(r.perGod).padStart(4)}/god  ${r.race.padEnd(10)} ${String(r.gods).padStart(2)} gods, ${String(r.rows).padStart(4)} rows${r.perGod < c.raceFloor ? (w?.waiver ? '  UNDER-FLOOR (waived)' : '  UNDER-FLOOR') : ''}`);
  }
  if (c.unresolvedWorshipObjects.length) {
    console.log(`\nworship objects with no matrix rows (reported, not dropped): ${c.unresolvedWorshipObjects.length}`);
    for (const u of c.unresolvedWorshipObjects) console.log(`  ${u}`);
  }
  if (c.breaches.length) {
    console.log(`\nFAIL: ${c.breaches.length} unwaived under-floor entr${c.breaches.length === 1 ? 'y' : 'ies'}`);
    for (const b of c.breaches) console.error(`  ${b.kind} ${b.subject}: ${b.value} < ${b.floor}`);
    console.log(`Waive deliberately-thin entries in ${path.relative(ROOT, COVERAGE_WAIVERS)} with a reason.`);
  } else {
    console.log(`\nPASS: every deity and race lane is at or above its floor (${c.under.length} waived).`);
  }
  return c.breaches.length === 0;
}

function countBy(items, keyFn) {
  const out = {};
  for (const i of items) { const k = keyFn(i); out[k] = (out[k] || 0) + 1; }
  return out;
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
  L.push('## G7 -- SPID religious recognition');
  L.push('');
  L.push(`- ${inv.spid.rules.length} live rules: ${inv.spid.keywords.length} cohort classifiers and ${inv.spid.factions.length} cohort-faction assignments.`);
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
  // Deliberately NO early return here. Counts drift and prose drift are collected together
  // so one run shows everything that is wrong; returning on the first would hide the prose
  // failures behind the block failures and take two runs to find them all.

  // PROSE. The block above is machine-readable; the body of the doc restates the same
  // numbers in sentences and tables, and until 2026-08-09 nothing looked at those. Landing
  // one mod left "the 46 PatchHub options" and "534 deity award rows" in the text while the
  // block said 47 and 559 -- a GREEN gate on a lying document, which is worse than a red one
  // because nobody goes looking. Each pattern below names the metric its captured number
  // must equal.
  //
  // BOUNDARY, stated rather than implied: this checks the phrasings listed here. A NEW
  // sentence carrying a number is not covered until someone adds its pattern. That is a real
  // limit; it is still strictly better than checking no prose at all.
  const PROSE = [
    [/the (\d+) PatchHub options/g, 'manifestOptions'],
    [/1:1 with the (\d+) manifest entries/g, 'manifestOptions'],
    [/and the (\d+)\s*\n?`common\/` folders/g, 'hubFoldersTotal'],
    [/(\d+) quest-reaction cells/g, 'totalReactionCells'],
    [/(\d+) deity award rows/g, 'totalAwardRows'],
    [/against (\d+) in the whole hub/g, 'totalAwardRows'],
    [/spread across the FOMOD manifest, (\d+) per-mod/g, 'sourceCsvs'],
    [/\|\s*\*\*G1\*\*\s*\|[^|]*\|[^|]*\|\s*\*\*(\d+)\*\*\s*\|/g, 'g1DataOnlyPatches'],
    [/\|\s*\*\*G2\*\*\s*\|[^|]*\|[^|]*\|\s*\*\*(\d+)\*\*\s*\|/g, 'g2PluginPatches'],
  ];
  let proseChecked = 0;
  for (const [re, key] of PROSE) {
    for (const m of text.matchAll(re)) {
      proseChecked += 1;
      const found = Number(m[1]);
      if (found !== inv.counts[key]) {
        drift.push(`prose "${m[0].replace(/\s+/g, ' ').trim()}": says ${found}, ${key} is ${inv.counts[key]}`);
      }
    }
  }
  if (drift.length) {
    console.error('FAIL: curated doc has drifted from the shipped content.');
    for (const d of drift) console.error(`  - ${d}`);
    if (missing.length) console.error(`  (metrics not declared in the doc: ${missing.join(', ')})`);
    return 1;
  }
  console.log(`PASS: ${Object.keys(declared).length} declared counts and ${proseChecked} prose figure(s) match the shipped content.`);
  if (missing.length) console.log(`note: ${missing.length} measured metric(s) not declared in the doc: ${missing.join(', ')}`);
  return 0;
}

/* ------------------------------------------------------------------- main */

const argv = process.argv.slice(2);
const inv = build();

// --coverage answers "who benefits", --check answers "does the doc still describe what
// ships". Separate exits on purpose: a coverage floor breach is a CONTENT gap someone has to
// decide about, not a documentation error, and folding it into --check would make one red
// stand for two unrelated problems.
if (argv.includes('--coverage')) {
  process.exit(reportCoverage(inv) ? 0 : 1);
}

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
