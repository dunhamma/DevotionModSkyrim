#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { compileQuestMatrix } from "./pdv_quest_matrix_compile.mjs";
import {
  buildCoreCatalog,
  buildOfficialCatalog,
  buildReceipt,
  resolveCatalogPrecedence,
  sha256,
  stableJson,
  validateCatalog,
} from "./lib/pdv_quest_reaction_catalog_v2.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANIFEST_PATH = path.join(ROOT, "references", "authoring", "PDV_QuestReactionCompatibility.manifest.json");
const RECEIPT_PATH = path.join(ROOT, "references", "authoring", "PDV_QuestReactionCatalogV2.receipt.json");
const KNOWN_FLAGS = new Set(["--check", "--write", "--self-test", "--json"]);
const args = process.argv.slice(2);
assertKnownFlags(args, KNOWN_FLAGS, { toolName: "pdv_quest_reaction_build" });

if (args.includes("--write") && args.includes("--check")) fail("Use either --write or --check, not both.");

const mode = args.includes("--write") ? "write" : "check";
const jsonOutput = args.includes("--json");

function main() {
  const build = buildRepositoryCatalogs();
  if (args.includes("--self-test")) runSelfTest(build);
  if (mode === "write") writeArtifacts(build);
  else checkArtifacts(build);
  const report = {
    status: "PASS",
    mode,
    sources: build.manifest.sources.length,
    dataOnlySources: build.manifest.sources.filter((source) => source.delivery === "data-only").length,
    adapters: build.manifest.sources.filter((source) => source.delivery !== "data-only").length,
    csvSources: build.manifest.sources.filter((source) => source.csv).length,
    coreQuestKeys: build.core.stringList.questKeys.length,
    officialQuestKeys: build.official.stringList.questKeys.length,
    officialSemanticKeys: build.official.stringList.semanticKeys.length,
    coreCells: countCells(build.core),
    officialCells: countCells(build.official),
    treeSha256: build.receipt.treeSha256,
  };
  if (jsonOutput) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`Quest Reaction v2 build: ${report.status} (${report.mode})`);
    console.log(`  compatibility sources: ${report.sources} (${report.dataOnlySources} data-only, ${report.adapters} adapters)`);
    console.log(`  CSV sources: ${report.csvSources}`);
    console.log(`  core: ${report.coreQuestKeys} keys / ${report.coreCells} cells`);
    console.log(`  official: ${report.officialQuestKeys} keys / ${report.officialCells} cells / ${report.officialSemanticKeys} semantic events`);
    console.log(`  tree sha256: ${report.treeSha256}`);
  }
}

function buildRepositoryCatalogs() {
  const manifest = readJson(MANIFEST_PATH);
  validateManifest(manifest);
  const coreCompiled = compileQuestMatrix({
    library: true,
    matrixCsv: path.join(ROOT, manifest.coreSourceCsv),
    outputPath: path.join(ROOT, manifest.coreCatalogOutput),
  });
  const compiledBySource = new Map();
  const semanticRowsBySource = new Map();
  for (const source of manifest.sources) {
    if (source.csv) {
      compiledBySource.set(source.sourceId, compileQuestMatrix({
        library: true,
        matrixCsv: path.join(ROOT, source.csv),
        outputPath: path.join(ROOT, manifest.officialPatchCatalogOutput),
        sourceMod: source.displayName,
      }));
    }
    if (source.semanticCsv) semanticRowsBySource.set(source.sourceId, readCsv(path.join(ROOT, source.semanticCsv)));
  }

  const core = buildCoreCatalog(coreCompiled);
  const official = buildOfficialCatalog({ sources: manifest.sources, compiledBySource, semanticRowsBySource });
  validateCatalog(core);
  validateCatalog(official, { requirePatchDelta: true });
  assertParity({ coreCompiled, core, compiledBySource, semanticRowsBySource, official });
  const artifacts = {
    [normalizePath(manifest.coreCatalogOutput)]: stableJson(core),
    [normalizePath(manifest.officialPatchCatalogOutput)]: stableJson(official),
  };
  const inputDigest = hashInputs(manifest);
  const receipt = buildReceipt(artifacts, inputDigest);
  artifacts[normalizePath(path.relative(ROOT, RECEIPT_PATH))] = stableJson(receipt);
  return { manifest, core, official, artifacts, receipt };
}

function validateManifest(manifest) {
  if (manifest.schema !== "pdv.quest-reaction.compatibility.v2" || manifest.version !== 2) {
    fail("Compatibility manifest schema/version is invalid.");
  }
  if (!manifest.coreSourceCsv || !manifest.coreCatalogOutput || !manifest.officialPatchCatalogOutput || !manifest.externalExtensionsDirectory) {
    fail("Compatibility manifest core/runtime paths are incomplete.");
  }
  if (manifest.extensionCatalogContract?.schema !== "pdv.quest-reaction.catalog.v2" || manifest.extensionCatalogContract?.version !== 2 || manifest.disabledSourceContract?.storageKey !== "PDV.V3.QR.DisabledSources") {
    fail("Compatibility manifest extension/disabled-source contracts are incomplete.");
  }
  if (manifest.packageAssetValidation !== "adapter-folders-only-until-slice1d-b-generated-package-contract") {
    fail("Compatibility manifest must retain the explicit Slice 1D-B package-asset validation boundary.");
  }
  if (!Array.isArray(manifest.sources) || manifest.sources.length !== 80) {
    fail(`Compatibility manifest must contain exactly 80 sources; found ${manifest.sources?.length ?? 0}.`);
  }
  const ids = new Set();
  const csvPaths = new Set();
  for (const source of manifest.sources) {
    if (!source.sourceId || ids.has(source.sourceId)) fail(`Invalid or duplicate sourceId: ${source.sourceId}`);
    ids.add(source.sourceId);
    if (!source.displayName || !source.pluginName || !Array.isArray(source.sentinelForms) || !source.sentinelForms.length) {
      fail(`Source ${source.sourceId} lacks displayName, pluginName, or sentinelForms.`);
    }
    if (!source.package || !Array.isArray(source.package.folders)) fail(`Source ${source.sourceId} lacks package metadata.`);
    if (source.csv) {
      const resolved = path.join(ROOT, source.csv);
      if (!fs.existsSync(resolved)) fail(`Source ${source.sourceId} CSV is missing: ${source.csv}`);
      if (csvPaths.has(normalizePath(source.csv))) fail(`CSV is mapped twice: ${source.csv}`);
      csvPaths.add(normalizePath(source.csv));
    }
  }
  const dataOnly = manifest.sources.filter((source) => source.delivery === "data-only");
  const adapters = manifest.sources.filter((source) => source.delivery !== "data-only");
  if (dataOnly.length !== 75 || adapters.length !== 5) fail(`Expected 75 data-only sources and 5 adapters; found ${dataOnly.length}/${adapters.length}.`);
  if (manifest.sourceCounts?.total !== 80 || manifest.sourceCounts?.dataOnly !== 75 || manifest.sourceCounts?.pluginAdapters !== 5 || manifest.sourceCounts?.catalogBacked !== 78) {
    fail("Compatibility manifest sourceCounts does not match the locked 80/75/5/78 inventory.");
  }
  if (csvPaths.size !== 78) fail(`Expected 78 explicitly mapped CSVs; found ${csvPaths.size}.`);
  const diskCsv = fs.readdirSync(path.join(ROOT, "references", "authoring", "patches"))
    .filter((name) => /^PDV_QRM_.*\.csv$/i.test(name))
    .map((name) => normalizePath(path.join("references", "authoring", "patches", name)));
  const missing = diskCsv.filter((csv) => !csvPaths.has(csv));
  const extra = [...csvPaths].filter((csv) => !diskCsv.includes(csv));
  if (missing.length || extra.length) fail(`CSV coverage mismatch. Missing: ${missing.join(", ") || "none"}; extra: ${extra.join(", ") || "none"}.`);
  for (const source of adapters) {
    for (const folder of source.package.folders) {
      const currentAssetRoot = path.join(ROOT, "dist", "PDV_QuestModPatches_FOMOD", folder);
      if (!fs.existsSync(currentAssetRoot)) fail(`Adapter ${source.sourceId} asset folder is missing: ${normalizePath(path.relative(ROOT, currentAssetRoot))}`);
    }
  }
}

function assertParity({ coreCompiled, core, compiledBySource, semanticRowsBySource, official }) {
  if (coreCompiled.report.questCells !== countQuestCells(core)) {
    fail(`Core V1/v2 quest-cell parity failed: ${coreCompiled.report.questCells} != ${countQuestCells(core)}.`);
  }
  if (coreCompiled.report.questKeys !== core.stringList.questKeys.length) {
    fail(`Core V1/v2 quest-key parity failed: ${coreCompiled.report.questKeys} != ${core.stringList.questKeys.length}.`);
  }
  const expectedPatchQuestCells = [...compiledBySource.values()].reduce((sum, compiled) => sum + compiled.report.questCells, 0);
  const expectedPatchQuestKeys = [...compiledBySource.values()].reduce((sum, compiled) => sum + compiled.report.questKeys, 0);
  const expectedSemanticCells = [...semanticRowsBySource.values()].reduce((sum, rows) => sum + rows.length, 0);
  const actualPatchQuestCells = countQuestCells(official);
  const actualSemanticCells = countSemanticCells(official);
  if (expectedPatchQuestCells !== actualPatchQuestCells || expectedPatchQuestKeys !== official.stringList.questKeys.length) {
    fail(`Patch V1/v2 quest parity failed: expected ${expectedPatchQuestKeys} keys/${expectedPatchQuestCells} cells; generated ${official.stringList.questKeys.length}/${actualPatchQuestCells}.`);
  }
  if (expectedSemanticCells !== actualSemanticCells) {
    fail(`Semantic CSV coverage failed: expected ${expectedSemanticCells} rows; generated ${actualSemanticCells} cells.`);
  }
  assertCompiledPayloadParity(coreCompiled, core, "core");
  for (const [sourceId, compiled] of compiledBySource) assertCompiledPayloadParity(compiled, official, sourceId);
  const expectedQuestKeys = new Set([...compiledBySource.values()].flatMap((compiled) => qualifyCompiledKeys(compiled)));
  const expectedSemanticKeys = new Set([...semanticRowsBySource.entries()].flatMap(([sourceId, rows]) => rows.map((row) => `${sourceId}|${row.event_id.trim()}`)));
  assertSameSet(expectedQuestKeys, new Set(official.stringList.questKeys), "official quest key coverage");
  assertSameSet(expectedSemanticKeys, new Set(official.stringList.semanticKeys), "official semantic key coverage");
}

function assertCompiledPayloadParity(compiled, catalog, label) {
  const qualifiedKeys = qualifyCompiledKeys(compiled);
  for (let index = 0; index < compiled.flat.questKeys.length; index += 1) {
    const legacyKey = String(compiled.flat.questKeys[index]);
    const qualifiedKey = qualifiedKeys[index];
    const oldPrefix = `quest.${legacyKey}.`;
    const newPrefix = `quest.${qualifiedKey}.`;
    const tupleSet = new Set();
    const names = ["deities", "valences", "intensities", "magnitudes", "tags"];
    for (const name of names) {
      const expected = compiled.runtime.stringList[`${oldPrefix}${name}`] ?? [];
      const actual = catalog.stringList[`${newPrefix}${name}`] ?? [];
      if (JSON.stringify(expected) !== JSON.stringify(actual)) fail(`${label} payload parity failed for ${qualifiedKey}.${name}.`);
    }
    const arrays = names.map((name) => compiled.runtime.stringList[`${oldPrefix}${name}`] ?? []);
    for (let cell = 0; cell < arrays[0].length; cell += 1) {
      const tuple = arrays.map((values) => values[cell]).join("\0");
      if (tupleSet.has(tuple)) fail(`${label} contains a duplicate reaction tuple at ${qualifiedKey}.`);
      tupleSet.add(tuple);
    }
  }
  if (label === "core") {
    for (const bucket of ["string", "float", "int", "stringList"]) {
      for (const [key, expected] of Object.entries(compiled.runtime[bucket] ?? {})) {
        if (!isCoreSharedPolicyKey(key)) continue;
        if (JSON.stringify(catalog[bucket][key]) !== JSON.stringify(expected)) fail(`Core shared-policy parity failed for ${bucket}.${key}.`);
      }
    }
  }
}

function qualifyCompiledKeys(compiled) {
  if (compiled.flat.questKeys.length !== compiled.flat.questPlugins.length) fail("Compiled quest identity arrays are misaligned.");
  return compiled.flat.questKeys.map((legacyKey, index) => `${compiled.flat.questPlugins[index]}|${legacyKey}`);
}

function isCoreSharedPolicyKey(key) {
  return /^(stance|stancemult|value|faucet)/i.test(key);
}

function assertSameSet(expected, actual, label) {
  const missing = [...expected].filter((key) => !actual.has(key));
  const extra = [...actual].filter((key) => !expected.has(key));
  if (missing.length || extra.length) fail(`${label} mismatch; missing=${missing.join(",") || "none"}; extra=${extra.join(",") || "none"}.`);
}

function writeArtifacts(build) {
  writeArtifactTree(ROOT, build.artifacts);
}

function writeArtifactTree(root, artifacts) {
  for (const [relativePath, text] of Object.entries(artifacts)) {
    const outputPath = path.join(root, relativePath);
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, text, "utf8");
  }
}

function checkArtifacts(build) {
  const problems = [];
  for (const [relativePath, expected] of Object.entries(build.artifacts)) {
    const outputPath = path.join(ROOT, relativePath);
    if (!fs.existsSync(outputPath)) {
      problems.push(`${relativePath}: missing`);
      continue;
    }
    const actual = fs.readFileSync(outputPath, "utf8");
    if (actual !== expected) problems.push(`${relativePath}: exact generated content drift`);
  }
  const receiptPath = normalizePath(path.relative(ROOT, RECEIPT_PATH));
  if (fs.existsSync(RECEIPT_PATH)) {
    const checkedReceipt = readJson(RECEIPT_PATH);
    const expectedPaths = Object.keys(build.artifacts).filter((relativePath) => relativePath !== receiptPath).sort();
    const receiptPaths = (checkedReceipt.files ?? []).map((file) => file.path).sort();
    if (JSON.stringify(expectedPaths) !== JSON.stringify(receiptPaths)) problems.push(`${receiptPath}: receipt membership drift`);
    for (const entry of checkedReceipt.files ?? []) {
      const artifactPath = path.join(ROOT, entry.path);
      if (!fs.existsSync(artifactPath)) continue;
      const bytes = fs.readFileSync(artifactPath);
      if (bytes.length !== entry.bytes || sha256(bytes) !== entry.sha256) problems.push(`${entry.path}: receipt byte/hash mismatch`);
    }
  }
  if (problems.length) fail(`${problems.join("\n")}\nRun: node tools/pdv_quest_reaction_build.mjs --write`);
}

function runSelfTest(repositoryBuild) {
  const a = fakeCompiled("A.esp", "291|200", "Mara");
  const b = fakeCompiled("B.esp", "291|200", "Arkay");
  const sources = [
    fakeSource("a", "A.esp"),
    fakeSource("b", "B.esp"),
  ];
  const official = buildOfficialCatalog({ sources, compiledBySource: new Map([["a", a], ["b", b]]) });
  if (!official.stringList.questKeys.includes("A.esp|291|200") || !official.stringList.questKeys.includes("B.esp|291|200")) {
    fail("Self-test: same local FormID in different plugins did not remain independent.");
  }
  const core = fakeCatalog("core", "A.esp|291|200");
  const extB = fakeCatalog("external-extension", "C.esp|10|20");
  const extA = fakeCatalog("external-extension", "A.esp|291|200");
  const extOfficial = fakeCatalog("external-extension", "B.esp|291|200");
  const precedence = resolveCatalogPrecedence({
    core,
    official,
    extensions: [{ fileName: "z.json", catalog: extB }, { fileName: "b.json", catalog: extOfficial }, { fileName: "a.json", catalog: extA }],
  });
  if (precedence.resolved.get("quest:A.esp|291|200") !== "core") fail("Self-test: core precedence failed.");
  if (precedence.resolved.get("quest:B.esp|291|200") !== "official") fail("Self-test: official precedence failed.");
  if (precedence.rejected.length) fail(`Self-test: valid catalogs rejected: ${JSON.stringify(precedence.rejected)}`);
  const lexicalKey = "D.esp|10|20";
  const lexical = resolveCatalogPrecedence({
    core,
    official,
    extensions: [{ fileName: "z.json", catalog: fakeCatalog("external-extension", lexicalKey) }, { fileName: "a.json", catalog: fakeCatalog("external-extension", lexicalKey) }],
  });
  if (lexical.resolved.get(`quest:${lexicalKey}`) !== "a.json") fail("Self-test: lexical extension precedence failed.");
  const bad = structuredClone(extB);
  bad.string.schema = "unknown";
  const isolated = resolveCatalogPrecedence({ core, official, extensions: [{ fileName: "bad.json", catalog: bad }, { fileName: "good.json", catalog: extB }] });
  if (isolated.rejected.length !== 1 || isolated.resolved.get("quest:C.esp|10|20") !== "good.json") {
    fail("Self-test: malformed extension was not source-local.");
  }
  const duplicate = structuredClone(extB);
  duplicate.stringList.questKeys.push("C.esp|10|20");
  const duplicateIsolation = resolveCatalogPrecedence({ core, official, extensions: [{ fileName: "duplicate.json", catalog: duplicate }, { fileName: "good.json", catalog: extB }] });
  if (duplicateIsolation.rejected.length !== 1 || duplicateIsolation.resolved.get("quest:C.esp|10|20") !== "good.json") {
    fail("Self-test: duplicate-key extension was not rejected in isolation.");
  }
  if (stableJson(official) !== stableJson(structuredClone(official))) fail("Self-test: stable serializer is not deterministic.");
  const firstRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-v2-a-"));
  const secondRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-v2-b-"));
  try {
    writeArtifactTree(firstRoot, repositoryBuild.artifacts);
    writeArtifactTree(secondRoot, repositoryBuild.artifacts);
    const firstTree = snapshotArtifactTree(firstRoot, Object.keys(repositoryBuild.artifacts));
    const secondTree = snapshotArtifactTree(secondRoot, Object.keys(repositoryBuild.artifacts));
    if (JSON.stringify(firstTree) !== JSON.stringify(secondTree)) fail("Self-test: isolated artifact trees differ.");
  } finally {
    fs.rmSync(firstRoot, { recursive: true, force: true });
    fs.rmSync(secondRoot, { recursive: true, force: true });
  }
}

function snapshotArtifactTree(root, relativePaths) {
  return [...relativePaths].sort().map((relativePath) => {
    const bytes = fs.readFileSync(path.join(root, relativePath));
    return { path: relativePath, bytes: bytes.length, sha256: sha256(bytes) };
  });
}

function fakeCompiled(pluginName, legacyKey, deity) {
  const prefix = `quest.${legacyKey}.`;
  const payload = {
    [`${prefix}deities`]: [deity],
    [`${prefix}valences`]: ["+"],
    [`${prefix}intensities`]: ["S"],
    [`${prefix}magnitudes`]: ["small"],
    [`${prefix}tags`]: ["fixture"],
  };
  return {
    flat: { questKeys: [legacyKey], questPlugins: [pluginName] },
    runtime: {
      string: {
        [`${prefix}deitiesCsv`]: deity,
        [`${prefix}valencesCsv`]: "+",
        [`${prefix}intensitiesCsv`]: "S",
        [`${prefix}magnitudesCsv`]: "small",
        [`${prefix}tagsCsv`]: "fixture",
      },
      float: {},
      int: {},
      stringList: payload,
    },
  };
}

function fakeSource(sourceId, pluginName) {
  return { sourceId, displayName: sourceId, pluginName, sentinelForms: [`${pluginName}|291`] };
}

function fakeCatalog(kind, questKey) {
  const pluginName = questKey.split("|")[0];
  const sourceId = `${kind}-fixture`;
  const prefix = `quest.${questKey}.`;
  return {
    string: {
      schema: "pdv.quest-reaction.catalog.v2",
      catalogKind: kind,
      [`source.${sourceId}.displayName`]: sourceId,
      [`source.${sourceId}.pluginName`]: pluginName,
      [`${prefix}deitiesCsv`]: "Mara",
      [`${prefix}valencesCsv`]: "+",
      [`${prefix}intensitiesCsv`]: "S",
      [`${prefix}magnitudesCsv`]: "small",
      [`${prefix}tagsCsv`]: "fixture",
    },
    float: {},
    int: { schemaVersion: 2 },
    stringList: {
      sourceIds: [sourceId],
      questKeys: [questKey],
      semanticKeys: [],
      [`source.${sourceId}.sentinelForms`]: [`${pluginName}|1`],
      [`source.${sourceId}.questKeys`]: [questKey],
      [`source.${sourceId}.semanticKeys`]: [],
      [`${prefix}deities`]: ["Mara"],
      [`${prefix}valences`]: ["+"],
      [`${prefix}intensities`]: ["S"],
      [`${prefix}magnitudes`]: ["small"],
      [`${prefix}tags`]: ["fixture"],
    },
  };
}

function hashInputs(manifest) {
  const paths = new Set([
    normalizePath(path.relative(ROOT, MANIFEST_PATH)),
    normalizePath(manifest.coreSourceCsv),
    "references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv",
    "references/phase4/PDV_StanceMatrix.csv",
    "references/phase4/PDV_DaedricRacePrinceMatrix.csv",
    "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
    "references/vanilla-gameplay/compatibility/PDV_CoreQuestAuditWorklist.csv",
  ]);
  for (const source of manifest.sources) {
    if (source.csv) paths.add(normalizePath(source.csv));
    if (source.semanticCsv) paths.add(normalizePath(source.semanticCsv));
    if (source.delivery !== "data-only") {
      for (const folder of source.package.folders) {
        const relativeFolder = normalizePath(path.join("dist", "PDV_QuestModPatches_FOMOD", folder));
        for (const relativeFile of listFiles(path.join(ROOT, relativeFolder))) paths.add(normalizePath(path.join(relativeFolder, relativeFile)));
      }
    }
  }
  const payload = [...paths].sort().map((relativePath) => {
    const absolutePath = path.join(ROOT, relativePath);
    if (!fs.existsSync(absolutePath)) fail(`Build input missing: ${relativePath}`);
    return `${relativePath}\0${sha256(fs.readFileSync(absolutePath))}`;
  }).join("\n");
  return sha256(payload);
}

function listFiles(directory) {
  if (!fs.existsSync(directory)) return [];
  const files = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name, "en"))) {
    const nested = entry.isDirectory() ? listFiles(path.join(directory, entry.name)).map((name) => path.join(entry.name, name)) : [entry.name];
    files.push(...nested);
  }
  return files;
}

function countCells(catalog) {
  return countQuestCells(catalog) + countSemanticCells(catalog);
}

function countQuestCells(catalog) {
  return catalog.stringList.questKeys.reduce((sum, questKey) => sum + (catalog.stringList[`quest.${questKey}.deities`]?.length ?? 0), 0);
}

function countSemanticCells(catalog) {
  return catalog.stringList.semanticKeys.reduce((sum, semanticKey) => sum + (catalog.stringList[`semantic.${semanticKey}.deities`]?.length ?? 0), 0);
}

function readJson(filePath) {
  if (!fs.existsSync(filePath)) fail(`Missing file: ${normalizePath(path.relative(ROOT, filePath))}`);
  return JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
}

function readCsv(filePath) {
  const rows = parseCsv(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
  const headers = rows.shift();
  return rows.filter((row) => row.some((value) => value.trim() !== "")).map((row) => Object.fromEntries(headers.map((header, index) => [header.trim(), row[index] ?? ""])));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (quoted) {
      if (character === '"' && text[index + 1] === '"') { field += '"'; index += 1; }
      else if (character === '"') quoted = false;
      else field += character;
    } else if (character === '"') quoted = true;
    else if (character === ",") { row.push(field); field = ""; }
    else if (character === "\n") { row.push(field); rows.push(row); row = []; field = ""; }
    else if (character !== "\r") field += character;
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows;
}

function normalizePath(value) {
  return value.replaceAll("\\", "/");
}

function fail(message) {
  throw new Error(message);
}

try {
  main();
} catch (error) {
  console.error(`Quest Reaction v2 build: FAIL\n${error.stack ?? error.message}`);
  process.exitCode = 1;
}
