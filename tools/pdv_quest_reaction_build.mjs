#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { hashBytes, hashText, readTextNormalised } from "./lib/pdv_file_compare.mjs";
import { validatePatchSourceLock, writePatchSourceLock } from "./lib/pdv_patch_source_lock.mjs";
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
import {
  assertReceiptMatches,
  buildPackageArtifacts,
  buildPackageReceipt,
  packageSnapshot,
  validatePackageArtifacts,
  validatePackageContract,
} from "./lib/pdv_quest_reaction_package_v3.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const MANIFEST_PATH = path.join(ROOT, "references", "authoring", "PDV_QuestReactionCompatibility.manifest.json");
const RECEIPT_PATH = path.join(ROOT, "references", "authoring", "PDV_QuestReactionCatalogV2.receipt.json");
const TEXT_BUILD_INPUT_EXTENSIONS = new Set([".csv", ".ini", ".json", ".md", ".psc", ".xml"]);
const KNOWN_FLAGS = new Set(["--check", "--write", "--self-test", "--json", "--package", "--output"]);
const args = process.argv.slice(2);
assertKnownFlags(args, KNOWN_FLAGS, { toolName: "pdv_quest_reaction_build" });

if (args.includes("--write") && args.includes("--check")) fail("Use either --write or --check, not both.");
const outputIndex = args.indexOf("--output");
const outputValue = outputIndex >= 0 ? args[outputIndex + 1] : null;
if (args.includes("--package") && !outputValue) fail("--package requires --output <archive.zip>.");
if (!args.includes("--package") && outputIndex >= 0) fail("--output is valid only with --package.");
if (outputValue?.startsWith("--")) fail("--output requires a path, not another flag.");

const mode = args.includes("--write") ? "write" : "check";
const jsonOutput = args.includes("--json");

function main() {
  const build = buildRepositoryCatalogs();
  if (args.includes("--self-test")) runSelfTest(build);
  if (mode === "write") {
    writeArtifacts(build);
    writePackageTree(build);
  } else {
    checkArtifacts(build);
    checkPackageTree(build);
  }
  const archive = args.includes("--package") ? buildAndVerifyArchive(build, path.resolve(ROOT, outputValue)) : null;
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
    packageFiles: build.packageReceipt.files.length,
    packageTreeSha256: build.packageReceipt.treeSha256,
    packageOptions: build.packageReceipt.adapterOptions.length,
    archive,
  };
  if (jsonOutput) console.log(JSON.stringify(report, null, 2));
  else {
    console.log(`Quest Reaction v2 build: ${report.status} (${report.mode})`);
    console.log(`  compatibility sources: ${report.sources} (${report.dataOnlySources} data-only, ${report.adapters} adapters)`);
    console.log(`  CSV sources: ${report.csvSources}`);
    console.log(`  core: ${report.coreQuestKeys} keys / ${report.coreCells} cells`);
    console.log(`  official: ${report.officialQuestKeys} keys / ${report.officialCells} cells / ${report.officialSemanticKeys} semantic events`);
    console.log(`  tree sha256: ${report.treeSha256}`);
    console.log(`  package: ${report.packageFiles} files / ${report.packageOptions} adapters / ${report.packageTreeSha256}`);
    if (archive) console.log(`  archive: ${archive.path} / ${archive.bytes} bytes / ${archive.sha256}`);
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
  const stageSelectorsBySource = new Map();
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
    if (source.stageSelectorInputs) stageSelectorsBySource.set(source.sourceId, source.stageSelectorInputs.map((relativePath) => compileStageSelector(relativePath)));
  }

  const stageSelectors = manifest.coreStageSelectorInputs.map((relativePath) => compileStageSelector(relativePath));
  const core = buildCoreCatalog(coreCompiled, { stageSelectors });
  const official = buildOfficialCatalog({ sources: manifest.sources, compiledBySource, semanticRowsBySource, stageSelectorsBySource });
  validateCatalog(core);
  validateCatalog(official, { requirePatchDelta: true });
  if (official.stringList.sourceIds.length !== 79) fail(`Official v2 catalog must contain 79 catalog-backed sources; found ${official.stringList.sourceIds.length}.`);
  assertParity({ coreCompiled, core, stageSelectors, compiledBySource, semanticRowsBySource, stageSelectorsBySource, official });
  const artifacts = {
    [normalizePath(manifest.coreCatalogOutput)]: stableJson(core),
    [normalizePath(manifest.officialPatchCatalogOutput)]: stableJson(official),
  };
  const inputDigest = hashInputs(manifest);
  const receipt = buildReceipt(artifacts, inputDigest);
  artifacts[normalizePath(path.relative(ROOT, RECEIPT_PATH))] = stableJson(receipt);
  const packageArtifacts = buildPackageArtifacts({
    manifest,
    officialCatalogText: artifacts[normalizePath(manifest.officialPatchCatalogOutput)],
    readAsset: (relativePath) => {
      const absolutePath = repositoryInputPath(relativePath);
      if (!fs.existsSync(absolutePath)) return null;
      if (isTextBuildInput(relativePath)) return Buffer.from(readTextNormalised(absolutePath), "utf8");
      return fs.readFileSync(absolutePath);
    },
  });
  const packageReceipt = buildPackageReceipt({ manifest, artifacts: packageArtifacts, inputSha256: inputDigest });
  artifacts[normalizePath(manifest.packageContract.receiptOutput)] = stableJson(packageReceipt);
  return { manifest, core, official, stageSelectors, artifacts, receipt, packageArtifacts, packageReceipt };
}

function validateManifest(manifest) {
  if (manifest.schema !== "pdv.quest-reaction.compatibility.v2" || manifest.version !== 2) {
    fail("Compatibility manifest schema/version is invalid.");
  }
  if (!manifest.coreSourceCsv || !Array.isArray(manifest.coreStageSelectorInputs) || !manifest.coreCatalogOutput || !manifest.officialPatchCatalogOutput || !manifest.externalExtensionsDirectory) {
    fail("Compatibility manifest core/runtime paths are incomplete.");
  }
  if (manifest.coreStageSelectorInputs.length !== 3 || new Set(manifest.coreStageSelectorInputs).size !== 3) {
    fail("Compatibility manifest must contain exactly three unique core stage-selector inputs.");
  }
  for (const relativePath of manifest.coreStageSelectorInputs) {
    if (!fs.existsSync(path.join(ROOT, relativePath))) fail(`Core stage-selector input is missing: ${relativePath}`);
  }
  if (manifest.extensionCatalogContract?.schema !== "pdv.quest-reaction.catalog.v2" || manifest.extensionCatalogContract?.version !== 2 || manifest.disabledSourceContract?.storageKey !== "PDV.V3.QR.DisabledSources") {
    fail("Compatibility manifest extension/disabled-source contracts are incomplete.");
  }
  validatePackageContract(manifest, { assetExists: (relativePath) => fs.existsSync(repositoryInputPath(relativePath)) });
  validatePatchSourceLock(path.join(ROOT, "patch-source"));
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
    if (!source.package || !source.package.dependency || typeof source.package.description !== "string") fail(`Source ${source.sourceId} lacks package metadata.`);
    if (source.csv) {
      const resolved = path.join(ROOT, source.csv);
      if (!fs.existsSync(resolved)) fail(`Source ${source.sourceId} CSV is missing: ${source.csv}`);
      if (csvPaths.has(normalizePath(source.csv))) fail(`CSV is mapped twice: ${source.csv}`);
      csvPaths.add(normalizePath(source.csv));
    }
    if (source.stageSelectorInputs) {
      if (!Array.isArray(source.stageSelectorInputs) || !source.stageSelectorInputs.length) fail(`Source ${source.sourceId} stageSelectorInputs is invalid.`);
      for (const relativePath of source.stageSelectorInputs) {
        if (normalizePath(relativePath).startsWith("dist/")) fail(`Source ${source.sourceId} reads a stage selector from generated dist: ${relativePath}`);
        if (!fs.existsSync(path.join(ROOT, relativePath))) fail(`Source ${source.sourceId} stage selector is missing: ${relativePath}`);
      }
    }
  }
  const dataOnly = manifest.sources.filter((source) => source.delivery === "data-only");
  const adapters = manifest.sources.filter((source) => source.delivery !== "data-only");
  if (dataOnly.length !== 75 || adapters.length !== 5) fail(`Expected 75 data-only sources and 5 adapters; found ${dataOnly.length}/${adapters.length}.`);
  if (manifest.sourceCounts?.total !== 80 || manifest.sourceCounts?.dataOnly !== 75 || manifest.sourceCounts?.pluginAdapters !== 5 || manifest.sourceCounts?.questCsvSources !== 78 || manifest.sourceCounts?.catalogBacked !== 79) {
    fail("Compatibility manifest sourceCounts does not match the locked 80/75/5/78-quest-CSV/79-catalog inventory.");
  }
  const afdi = manifest.sources.find((source) => source.sourceId === "afdi");
  if (afdi?.delivery !== "semantic-adapter" || afdi.adapterMasterPolicy !== "devotion-only-dynamic-source-resolution" || afdi.runtimeServiceFormKey !== "0716DF:Devotion.esp") {
    fail("AFDI semantic adapter master/runtime-service contract is invalid.");
  }
  if (csvPaths.size !== 78) fail(`Expected 78 explicitly mapped CSVs; found ${csvPaths.size}.`);
  const diskCsv = fs.readdirSync(path.join(ROOT, "references", "authoring", "patches"))
    .filter((name) => /^PDV_QRM_.*\.csv$/i.test(name))
    .map((name) => normalizePath(path.join("references", "authoring", "patches", name)));
  const missing = diskCsv.filter((csv) => !csvPaths.has(csv));
  const extra = [...csvPaths].filter((csv) => !diskCsv.includes(csv));
  if (missing.length || extra.length) fail(`CSV coverage mismatch. Missing: ${missing.join(", ") || "none"}; extra: ${extra.join(", ") || "none"}.`);
  const catalogBacked = manifest.sources.filter((source) => source.csv || source.semanticCsv);
  if (catalogBacked.length !== 79) fail(`Expected 79 catalog-backed sources; found ${catalogBacked.length}.`);
}

function assertParity({ coreCompiled, core, stageSelectors, compiledBySource, semanticRowsBySource, stageSelectorsBySource, official }) {
  if (coreCompiled.report.questCells !== countQuestCells(core)) {
    fail(`Core V1/v2 quest-cell parity failed: ${coreCompiled.report.questCells} != ${countQuestCells(core)}.`);
  }
  if (coreCompiled.report.questKeys !== core.stringList.questKeys.length) {
    fail(`Core V1/v2 quest-key parity failed: ${coreCompiled.report.questKeys} != ${core.stringList.questKeys.length}.`);
  }
  assertStageSelectorParity(stageSelectors, core);
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
  const expectedOfficialStageKeys = new Set([...stageSelectorsBySource.values()].flatMap((selectors) => selectors.map((selector) => selector.key)));
  assertSameSet(expectedOfficialStageKeys, new Set(official.stringList.stageAdapterKeys), "official stage-adapter coverage");
}

function compileStageSelector(relativePath) {
  const input = readJson(path.join(ROOT, relativePath));
  const string = input.string ?? {};
  const int = input.int ?? {};
  if (string.schema !== "pdv-quest-stage-adapter.v1") fail(`Stage selector ${relativePath} has an unsupported schema.`);
  const sourcePlugin = String(string.sourcePlugin ?? "");
  const selectorKind = String(string.selectorKind || "global");
  const selectorPlugin = String(string.selectorPlugin ?? "");
  const sourceFormId = int.sourceFormId;
  const sourceStage = int.sourceStage;
  const selectorFormId = int.selectorFormId;
  const selectorValues = int.selectorValues;
  const targetStages = int.targetStages;
  if (!sourcePlugin || !selectorKind || !selectorPlugin || !Number.isInteger(sourceFormId) || sourceFormId < 0 || !Number.isInteger(sourceStage) || sourceStage < 0 || !Number.isInteger(selectorFormId) || selectorFormId < 0 || !Array.isArray(selectorValues) || !Array.isArray(targetStages) || !selectorValues.length || selectorValues.length !== targetStages.length || selectorValues.some((value) => !Number.isInteger(value)) || targetStages.some((value) => !Number.isInteger(value) || value < 0)) {
    fail(`Stage selector ${relativePath} is malformed.`);
  }
  return {
    key: `${sourcePlugin}|${sourceFormId}|${sourceStage}`,
    selectorKind,
    selectorPlugin,
    selectorFormId,
    selectorValues: [...selectorValues],
    targetStages: [...targetStages],
  };
}

function assertStageSelectorParity(stageSelectors, catalog) {
  const actualKeys = catalog.stringList.stageAdapterKeys ?? [];
  assertSameSet(new Set(stageSelectors.map((selector) => selector.key)), new Set(actualKeys), "core stage-adapter coverage");
  for (const selector of stageSelectors) {
    const prefix = `stageAdapter.${selector.key}.`;
    if (catalog.string[`${prefix}selectorKind`] !== selector.selectorKind || catalog.string[`${prefix}selectorPlugin`] !== selector.selectorPlugin || catalog.int[`${prefix}selectorFormId`] !== selector.selectorFormId || JSON.stringify(catalog.int[`${prefix}selectorValues`]) !== JSON.stringify(selector.selectorValues) || JSON.stringify(catalog.int[`${prefix}targetStages`]) !== JSON.stringify(selector.targetStages)) {
      fail(`Core stage-adapter parity failed for ${selector.key}.`);
    }
  }
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
  if (fs.existsSync(RECEIPT_PATH)) {
    const checkedReceipt = readJson(RECEIPT_PATH);
    const expectedPaths = build.receipt.files.map((file) => file.path).sort();
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

function packageRootFor(build) {
  const packageRoot = path.resolve(ROOT, build.manifest.packageContract.outputRoot);
  const expectedRoot = path.resolve(ROOT, "dist", "PDV_QuestModPatches_FOMOD");
  if (packageRoot !== expectedRoot) fail(`Refusing unexpected generated package root: ${packageRoot}`);
  return packageRoot;
}

function writePackageTree(build) {
  const packageRoot = packageRootFor(build);
  if (fs.existsSync(packageRoot) && fs.lstatSync(packageRoot).isSymbolicLink()) fail(`Refusing symlinked package root: ${packageRoot}`);
  fs.rmSync(packageRoot, { recursive: true, force: true });
  writeBufferTree(packageRoot, build.packageArtifacts);
}

function writeBufferTree(root, artifacts) {
  for (const [relativePath, content] of artifacts) {
    const outputPath = path.join(root, relativePath);
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, content);
  }
}

function readBufferTree(root) {
  const artifacts = new Map();
  for (const relativePath of listFiles(root).map(normalizePath)) artifacts.set(relativePath, fs.readFileSync(path.join(root, relativePath)));
  return artifacts;
}

function checkPackageTree(build) {
  const packageRoot = packageRootFor(build);
  if (!fs.existsSync(packageRoot)) fail(`Generated package tree is missing: ${normalizePath(path.relative(ROOT, packageRoot))}. Run --write.`);
  if (fs.lstatSync(packageRoot).isSymbolicLink()) fail(`Generated package root must not be a symlink: ${packageRoot}`);
  const actual = readBufferTree(packageRoot);
  const expectedSnapshot = packageSnapshot(build.packageArtifacts);
  const actualSnapshot = packageSnapshot(actual);
  if (JSON.stringify(expectedSnapshot) !== JSON.stringify(actualSnapshot)) {
    const expectedPaths = new Set(expectedSnapshot.map((entry) => entry.path));
    const actualPaths = new Set(actualSnapshot.map((entry) => entry.path));
    const missing = [...expectedPaths].filter((entry) => !actualPaths.has(entry));
    const extra = [...actualPaths].filter((entry) => !expectedPaths.has(entry));
    fail(`Generated package tree drifted. Missing=${missing.join(",") || "none"}; extra=${extra.join(",") || "none"}. Run --write.`);
  }
  assertReceiptMatches(build.packageReceipt, actual);
  validatePackageArtifacts({ manifest: build.manifest, artifacts: actual });
}

function buildAndVerifyArchive(build, outputPath) {
  if (fs.existsSync(outputPath)) fail(`Refusing to overwrite existing archive: ${outputPath}`);
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  const stageRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-package-stage-"));
  const verifyRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-package-verify-"));
  let created = false;
  try {
    writeBufferTree(stageRoot, build.packageArtifacts);
    const escapedStage = stageRoot.replaceAll("'", "''");
    const escapedOutput = outputPath.replaceAll("'", "''");
    const archiveScript = `$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression; $root='${escapedStage}'; $output='${escapedOutput}'; $stream=[IO.File]::Open($output,[IO.FileMode]::CreateNew); try { $zip=[IO.Compression.ZipArchive]::new($stream,[IO.Compression.ZipArchiveMode]::Create,$false); try { Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName | ForEach-Object { $relative=$_.FullName.Substring($root.Length).TrimStart([char[]]'\\/').Replace('\\','/'); $entry=$zip.CreateEntry($relative,[IO.Compression.CompressionLevel]::Optimal); $entry.LastWriteTime=[DateTimeOffset]::new(1980,1,1,0,0,0,[TimeSpan]::Zero); $input=[IO.File]::OpenRead($_.FullName); try { $target=$entry.Open(); try { $input.CopyTo($target) } finally { $target.Dispose() } } finally { $input.Dispose() } } } finally { $zip.Dispose() } } finally { $stream.Dispose() }`;
    execFileSync("powershell", ["-NoProfile", "-Command", archiveScript], { cwd: ROOT, stdio: "pipe" });
    created = true;
    const entryScript = `$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead('${escapedOutput}'); try {$z.Entries | Where-Object {-not [string]::IsNullOrEmpty($_.Name)} | ForEach-Object {$_.FullName}} finally {$z.Dispose()}`;
    const entries = execFileSync("powershell", ["-NoProfile", "-Command", entryScript], { encoding: "utf8", maxBuffer: 8 * 1024 * 1024 })
      .split(/\r?\n/).map((entry) => entry.trim()).filter(Boolean);
    if (entries.some((entry) => entry.includes("\\") || entry.startsWith("/") || entry.split("/").includes(".."))) fail("Archive contains non-normalized member metadata.");
    if (new Set(entries.map((entry) => entry.toLowerCase())).size !== entries.length) fail("Archive contains duplicate file entries.");
    const escapedVerify = verifyRoot.replaceAll("'", "''");
    execFileSync("powershell", ["-NoProfile", "-Command", `$ErrorActionPreference='Stop'; Expand-Archive -LiteralPath '${escapedOutput}' -DestinationPath '${escapedVerify}'`], { cwd: ROOT, stdio: "pipe" });
    const extracted = readBufferTree(verifyRoot);
    if (JSON.stringify(packageSnapshot(extracted)) !== JSON.stringify(packageSnapshot(build.packageArtifacts))) fail("Archive membership or member hashes differ from the generated package tree.");
    return {
      path: normalizePath(path.relative(ROOT, outputPath)),
      bytes: fs.statSync(outputPath).size,
      sha256: sha256(fs.readFileSync(outputPath)),
      entries: entries.length,
      membership: "exact",
      memberHashes: "exact",
      metadata: "normalized",
    };
  } catch (error) {
    if (created && fs.existsSync(outputPath)) fs.rmSync(outputPath);
    throw error;
  } finally {
    fs.rmSync(stageRoot, { recursive: true, force: true });
    fs.rmSync(verifyRoot, { recursive: true, force: true });
  }
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
  const selectorCore = buildCoreCatalog(fakeCompiled("Skyrim.esm", "340742|200", "Mara"), {
    stageSelectors: [{ key: "Skyrim.esm|340742|200", selectorKind: "global", selectorPlugin: "Skyrim.esm", selectorFormId: 1113756, selectorValues: [0, 1], targetStages: [201, 202] }],
  });
  validateCatalog(selectorCore);
  if (selectorCore.stringList.stageAdapterKeys[0] !== "Skyrim.esm|340742|200" || selectorCore.string[`stageAdapter.Skyrim.esm|340742|200.selectorKind`] !== "global" || selectorCore.int[`stageAdapter.Skyrim.esm|340742|200.selectorValues`].join("|") !== "0|1" || selectorCore.int[`stageAdapter.Skyrim.esm|340742|200.targetStages`].join("|") !== "201|202") {
    fail("Self-test: stage-adapter compilation lost its physical key or aligned routes.");
  }
  validatePackageArtifacts({ manifest: repositoryBuild.manifest, artifacts: repositoryBuild.packageArtifacts });
  assertReceiptMatches(repositoryBuild.packageReceipt, repositoryBuild.packageArtifacts);
  const missingRequired = new Map(repositoryBuild.packageArtifacts);
  missingRequired.delete(normalizePath(path.posix.join("required", repositoryBuild.manifest.packageContract.requiredCatalogDestination)));
  expectPackageReject("missing required catalog", () => validatePackageArtifacts({ manifest: repositoryBuild.manifest, artifacts: missingRequired }));
  const legacyMember = new Map(repositoryBuild.packageArtifacts);
  legacyMember.set("adapters/fixture/SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/PDV_QRM_Fixture.json", Buffer.from("{}"));
  expectPackageReject("legacy channel member", () => validatePackageArtifacts({ manifest: repositoryBuild.manifest, artifacts: legacyMember }));
  const sixthOption = new Map(repositoryBuild.packageArtifacts);
  const xml = sixthOption.get("fomod/ModuleConfig.xml").toString("utf8").replace("          </plugins>", "            <plugin name=\"Unexpected\"><description>x</description></plugin>\n          </plugins>");
  sixthOption.set("fomod/ModuleConfig.xml", Buffer.from(xml));
  expectPackageReject("sixth adapter option", () => validatePackageArtifacts({ manifest: repositoryBuild.manifest, artifacts: sixthOption }));
  const collisionManifest = structuredClone(repositoryBuild.manifest);
  const collisionAdapters = collisionManifest.sources.filter((source) => source.delivery !== "data-only");
  collisionAdapters[1].package.assets[0].destination = collisionAdapters[0].package.assets[0].destination;
  expectPackageReject("adapter collision", () => validatePackageContract(collisionManifest));
  expectPackageReject("missing adapter asset", () => validatePackageContract(repositoryBuild.manifest, { assetExists: (relativePath) => !relativePath.endsWith("PDV_Patch_AFDI.esp") }));
  const escapingManifest = structuredClone(repositoryBuild.manifest);
  escapingManifest.sources.find((source) => source.delivery !== "data-only").package.assets[0].source = "../outside-repository.bin";
  expectPackageReject("adapter source traversal", () => validatePackageContract(escapingManifest));
  const incompleteReadme = new Map(repositoryBuild.packageArtifacts);
  incompleteReadme.set("README.md", Buffer.from(incompleteReadme.get("README.md").toString("utf8").replace("- Above All Else\n", "")));
  expectPackageReject("incomplete public integration inventory", () => validatePackageArtifacts({ manifest: repositoryBuild.manifest, artifacts: incompleteReadme }));
  const lockRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-lock-"));
  try {
    fs.mkdirSync(path.join(lockRoot, "Fixture", "Scripts", "Source"), { recursive: true });
    fs.writeFileSync(path.join(lockRoot, "Fixture", "Scripts", "Source", "Fixture.psc"), "Scriptname Fixture extends Quest\n", "utf8");
    fs.writeFileSync(path.join(lockRoot, "Fixture", "Scripts", "Fixture.pex"), Buffer.from([1, 2, 3]));
    writePatchSourceLock(lockRoot);
    validatePatchSourceLock(lockRoot);
    fs.appendFileSync(path.join(lockRoot, "Fixture", "Scripts", "Source", "Fixture.psc"), "; drift\n", "utf8");
    expectPackageReject("stale adapter bytecode lock", () => validatePatchSourceLock(lockRoot));
  } finally {
    fs.rmSync(lockRoot, { recursive: true, force: true });
  }
  const firstRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-v2-a-"));
  const secondRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-qr-v2-b-"));
  try {
    writeArtifactTree(firstRoot, repositoryBuild.artifacts);
    writeArtifactTree(secondRoot, repositoryBuild.artifacts);
    const firstTree = snapshotArtifactTree(firstRoot, Object.keys(repositoryBuild.artifacts));
    const secondTree = snapshotArtifactTree(secondRoot, Object.keys(repositoryBuild.artifacts));
    if (JSON.stringify(firstTree) !== JSON.stringify(secondTree)) fail("Self-test: isolated artifact trees differ.");
    const firstPackageRoot = path.join(firstRoot, "package");
    const secondPackageRoot = path.join(secondRoot, "package");
    writeBufferTree(firstPackageRoot, repositoryBuild.packageArtifacts);
    writeBufferTree(secondPackageRoot, repositoryBuild.packageArtifacts);
    if (JSON.stringify(packageSnapshot(readBufferTree(firstPackageRoot))) !== JSON.stringify(packageSnapshot(readBufferTree(secondPackageRoot)))) {
      fail("Self-test: isolated generated package trees differ.");
    }
  } finally {
    fs.rmSync(firstRoot, { recursive: true, force: true });
    fs.rmSync(secondRoot, { recursive: true, force: true });
  }
}

function expectPackageReject(label, action) {
  try {
    action();
  } catch {
    return;
  }
  fail(`Self-test: ${label} mutation was accepted.`);
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
    "patch-source/PDV_PatchSource.lock.json",
    normalizePath(manifest.coreSourceCsv),
    ...manifest.coreStageSelectorInputs.map(normalizePath),
    "references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv",
    "references/phase4/PDV_StanceMatrix.csv",
    "references/phase4/PDV_DaedricRacePrinceMatrix.csv",
    "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
    "references/vanilla-gameplay/compatibility/PDV_CoreQuestAuditWorklist.csv",
  ]);
  for (const source of manifest.sources) {
    if (source.csv) paths.add(normalizePath(source.csv));
    if (source.semanticCsv) paths.add(normalizePath(source.semanticCsv));
    for (const relativePath of source.stageSelectorInputs ?? []) paths.add(normalizePath(relativePath));
    if (source.delivery !== "data-only") {
      for (const asset of source.package.assets) paths.add(normalizePath(asset.source));
    }
  }
  const payload = [...paths].sort().map((relativePath) => {
    const absolutePath = repositoryInputPath(relativePath);
    if (!fs.existsSync(absolutePath)) fail(`Build input missing: ${relativePath}`);
    const digest = isTextBuildInput(relativePath) ? hashText(absolutePath) : hashBytes(absolutePath);
    return `${relativePath}\0${digest}`;
  }).join("\n");
  return sha256(payload);
}

function isTextBuildInput(relativePath) {
  return TEXT_BUILD_INPUT_EXTENSIONS.has(path.extname(relativePath).toLowerCase());
}

function repositoryInputPath(relativePath) {
  const raw = String(relativePath ?? "");
  if (!raw || path.posix.isAbsolute(raw) || path.win32.isAbsolute(raw)) fail(`Build input path must be repository-relative: ${raw || "<empty>"}`);
  const absolutePath = path.resolve(ROOT, raw);
  const rootPrefix = `${ROOT}${path.sep}`;
  if (!absolutePath.startsWith(rootPrefix)) fail(`Build input escapes the repository: ${raw}`);
  return absolutePath;
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
