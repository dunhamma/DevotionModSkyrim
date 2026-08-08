#!/usr/bin/env node
/*
 * Deterministic validator for dist/PDV_QuestModPatches_FOMOD.
 *
 * Validates XML syntax, every referenced source folder, install-path
 * collisions, representative FOMOD selections, channel filenames, the package
 * tree manifest and (when supplied) exact archive membership/checksum.
 *
 * Usage:
 *   node tools/pdv_quest_patch_fomod_validate.mjs
 *   node tools/pdv_quest_patch_fomod_validate.mjs --archive dist/<file>.zip
 *   node tools/pdv_quest_patch_fomod_validate.mjs --write-receipt
 */

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

// Refuse unrecognised flags. These tools read argv with includes()/indexOf(), so an
// unknown or mistyped flag would otherwise fall through to a default and the run would
// SUCCEED against something the caller never asked for. Matches the pdv_arr25_* convention.
const KNOWN_FLAGS = new Set(["--root", "--archive", "--receipt", "--manifest", "--write-receipt"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}


const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const args = process.argv.slice(2);
const value = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : null;
};
const packageRoot = path.resolve(ROOT, value("--root") ?? "dist/PDV_QuestModPatches_FOMOD");
const archivePath = value("--archive") ? path.resolve(ROOT, value("--archive")) : null;
const receiptPath = path.resolve(ROOT, value("--receipt") ?? "references/authoring/PDV_QuestModPatches_FOMOD_Validation.json");
const manifestPath = path.resolve(ROOT, value("--manifest") ?? "references/authoring/PDV_QuestPatchHub.manifest.json");
const xmlPath = path.join(packageRoot, "fomod", "ModuleConfig.xml");

const failures = [];
const warnings = [];
const fail = (message) => failures.push(message);
const sha256 = (file) => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex").toUpperCase();
const norm = (file) => file.replaceAll("\\", "/").replace(/^\.\//, "");

function filesUnder(root) {
  const out = [];
  if (!fs.existsSync(root)) return out;
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const full = path.join(root, entry.name);
    if (entry.isDirectory()) out.push(...filesUnder(full));
    else if (entry.isFile()) out.push(full);
  }
  return out;
}

function assertXmlParses() {
  if (!fs.existsSync(xmlPath)) return fail(`Missing ${path.relative(ROOT, xmlPath)}`);
  const escaped = xmlPath.replaceAll("'", "''");
  try {
    execFileSync("powershell", ["-NoProfile", "-Command", `$ErrorActionPreference='Stop'; [xml](Get-Content -LiteralPath '${escaped}' -Raw) | Out-Null`], { stdio: "pipe" });
  } catch (error) {
    fail(`ModuleConfig.xml is not well-formed XML: ${String(error.stderr ?? error.message).trim()}`);
  }
}

function parseOptions(xml) {
  const options = [];
  const re = /<plugin name="([^"]+)">([\s\S]*?)<\/plugin>/g;
  for (const match of xml.matchAll(re)) {
    const sources = [];
    const folderRe = /<folder source="([^"]+)" destination="([^"]*)" priority="[^"]+"\s*\/>/g;
    for (const folder of match[2].matchAll(folderRe)) sources.push({ source: folder[1], destination: folder[2] });
    const dependencies = [...match[2].matchAll(/<fileDependency file="([^"]+)" state="Active"\s*\/>/g)].map((item) => item[1]);
    options.push({ name: match[1], sources, dependencies });
  }
  return options;
}

function expandSelection(name, options) {
  const installed = new Map();
  const identicalCollisions = [];
  for (const option of options) {
    for (const folder of option.sources) {
      const sourceRoot = path.join(packageRoot, ...folder.source.split(/[\\/]/));
      if (!fs.existsSync(sourceRoot) || !fs.statSync(sourceRoot).isDirectory()) {
        fail(`${name}: missing referenced folder ${folder.source} (option ${option.name})`);
        continue;
      }
      const sourceFiles = filesUnder(sourceRoot);
      if (!sourceFiles.length) fail(`${name}: referenced folder is empty: ${folder.source} (option ${option.name})`);
      for (const file of sourceFiles) {
        const relative = norm(path.relative(sourceRoot, file));
        const destination = norm(path.join(folder.destination, relative));
        const hash = sha256(file);
        const prior = installed.get(destination.toLowerCase());
        if (prior && prior.hash !== hash) {
          fail(`${name}: differing install collision at ${destination}: ${prior.source} vs ${norm(path.relative(packageRoot, file))}`);
        } else if (prior) {
          identicalCollisions.push(destination);
        } else {
          installed.set(destination.toLowerCase(), { destination, hash, source: norm(path.relative(packageRoot, file)) });
        }
      }
    }
  }
  return { name, installedFiles: installed.size, identicalCollisions: [...new Set(identicalCollisions)].sort() };
}

function archiveManifest(file) {
  const escaped = file.replaceAll("'", "''");
  const script = `$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead('${escaped}'); $sha=[Security.Cryptography.SHA256]::Create(); try {$z.Entries | Where-Object {-not [string]::IsNullOrEmpty($_.Name)} | ForEach-Object {$s=$_.Open(); try {$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-',''); $_.FullName.Replace('\\','/') + [char]9 + $h} finally {$s.Dispose()}}} finally {$sha.Dispose(); $z.Dispose()}`;
  return execFileSync("powershell", ["-NoProfile", "-Command", script], { encoding: "utf8", maxBuffer: 32 * 1024 * 1024 })
    .split(/\r?\n/).map((line) => line.trim()).filter(Boolean).map((line) => {
      const [name, hash] = line.split("\t");
      return { path: norm(name), sha256: hash };
    }).sort((a, b) => a.path.localeCompare(b.path));
}

assertXmlParses();
const xml = fs.existsSync(xmlPath) ? fs.readFileSync(xmlPath, "utf8") : "";
const options = parseOptions(xml);
if (!fs.existsSync(manifestPath)) fail(`PatchHub manifest not found: ${path.relative(ROOT, manifestPath)}`);
const hubManifest = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath, "utf8")) : { options: [] };
if (hubManifest.schema !== "pdv-quest-patch-hub.v1" || !Array.isArray(hubManifest.options)) fail("PatchHub manifest schema/options are invalid.");
if ((xml.match(/<installStep\b/g) ?? []).length !== 1) fail("PatchHub must expose exactly one install step.");
if ((xml.match(/<group\b[^>]*type="SelectAny"/g) ?? []).length !== 1) fail("PatchHub must expose exactly one SelectAny group.");
if ((xml.match(/<group\b[^>]*type="SelectExactlyOne"/g) ?? []).length) fail("PatchHub must not expose a list-specific mode-selection group.");
if (/authoria|plugins[\\/]authoria|PDV_QuestReactionMatrix_ARR/i.test(xml)) fail("ModuleConfig.xml contains a retired list-specific lane or matrix.");
if (!options.length) fail("No modular FOMOD options found.");
if (options.length !== hubManifest.options.length) fail(`XML has ${options.length} options; manifest has ${hubManifest.options.length}.`);
for (const manifestOption of hubManifest.options) {
  const option = options.find((candidate) => candidate.name === manifestOption.name);
  if (!option) {
    fail(`Manifest option missing from XML: ${manifestOption.name}`);
    continue;
  }
  if (option.dependencies.length !== 1 || option.dependencies[0] !== manifestOption.dependency) {
    fail(`${option.name}: expected one dependency ${manifestOption.dependency}; found ${option.dependencies.join(", ") || "none"}.`);
  }
  const xmlFolders = option.sources.map((source) => source.source).sort();
  const manifestFolders = [...manifestOption.folders].sort();
  if (JSON.stringify(xmlFolders) !== JSON.stringify(manifestFolders)) fail(`${option.name}: XML source folders differ from manifest.`);

  // A BOS swap must never point at an ESP supplied by some other option. Build
  // the exact file set installed by this option and require every replacement
  // plugin named on the right-hand side to be present beside the BOS config.
  const optionFiles = option.sources.flatMap((source) => {
    const sourceRoot = path.join(packageRoot, ...source.source.split(/[\\/]/));
    return filesUnder(sourceRoot).map((file) => ({ file, destination: norm(path.join(source.destination, path.relative(sourceRoot, file))) }));
  });
  const installedPluginNames = new Set(optionFiles.filter((entry) => /\.(?:esp|esm|esl)$/i.test(entry.destination)).map((entry) => path.posix.basename(entry.destination).toLowerCase()));
  for (const entry of optionFiles.filter((candidate) => /SKSE\/Plugins\/BaseObjectSwapper\/.*\.ini$/i.test(candidate.destination))) {
    const replacements = [...fs.readFileSync(entry.file, "utf8").matchAll(/\|\s*0x[0-9a-f]+~([^|\r\n;]+)/gi)].map((match) => match[1].trim());
    for (const pluginName of replacements) {
      if (!installedPluginNames.has(pluginName.toLowerCase())) fail(`${option.name}: BOS target ${pluginName} is not installed by the same option.`);
    }
  }
}

const simulations = [];
simulations.push(expandSelection("all-options", options));
const representative = [options[0], options[Math.floor(options.length / 2)], options.at(-1)].filter(Boolean);
simulations.push(expandSelection("representative-subset", [...new Set(representative)]));
const individualSimulations = options.map((option) => expandSelection(`individual:${option.name}`, [option]));

const packageFiles = filesUnder(packageRoot).map((file) => ({
  path: norm(path.relative(packageRoot, file)),
  size: fs.statSync(file).size,
  sha256: sha256(file),
})).sort((a, b) => a.path.localeCompare(b.path));
const treeDigest = crypto.createHash("sha256")
  .update(packageFiles.map((entry) => `${entry.path}\0${entry.sha256}`).join("\n"))
  .digest("hex").toUpperCase();

const channelFiles = packageFiles.filter((entry) => entry.path.includes("/Channels/") && entry.path.endsWith(".json"));
const badChannelNames = channelFiles.filter((entry) => !/^PDV_QRM_[A-Za-z0-9_]+\.json$/.test(path.posix.basename(entry.path)));
for (const entry of badChannelNames) fail(`Malformed channel filename: ${entry.path}`);
for (const entry of packageFiles) {
  if (/authoria|PDV_QuestReactionMatrix_ARR/i.test(entry.path)) fail(`Retired list-specific package member: ${entry.path}`);
  if (/^common\/TGAlternativeEndings\/Scripts\//i.test(entry.path)) fail(`TG Alternative Endings must not install core scripts: ${entry.path}`);
}
const installedCoreOverrides = simulations[0]?.installedFiles
  ? filesUnder(packageRoot).filter((file) => /[\\/]Scripts[\\/](?:Source[\\/])?PDV_(?:_ManagerQuest|EventBus|PlayerEvents)\.(?:psc|pex)$/i.test(file))
  : [];
for (const file of installedCoreOverrides) fail(`PatchHub contains a core-script override: ${norm(path.relative(packageRoot, file))}`);

let archive = null;
if (archivePath) {
  if (!fs.existsSync(archivePath)) {
    fail(`Archive not found: ${path.relative(ROOT, archivePath)}`);
  } else {
    const archivedFiles = archiveManifest(archivePath);
    const entries = archivedFiles.map((entry) => entry.path);
    const manifestNames = packageFiles.map((entry) => entry.path).sort();
    const missing = manifestNames.filter((entry) => !entries.includes(entry));
    const extra = entries.filter((entry) => !manifestNames.includes(entry));
    const expectedHashes = new Map(packageFiles.map((entry) => [entry.path, entry.sha256]));
    const checksumMismatches = archivedFiles.filter((entry) => expectedHashes.has(entry.path) && expectedHashes.get(entry.path) !== entry.sha256);
    if (missing.length) fail(`Archive is missing ${missing.length} manifest file(s): ${missing.slice(0, 10).join(", ")}`);
    if (extra.length) fail(`Archive has ${extra.length} extra file(s): ${extra.slice(0, 10).join(", ")}`);
    if (checksumMismatches.length) fail(`Archive has ${checksumMismatches.length} checksum mismatch(es): ${checksumMismatches.slice(0, 10).map((entry) => entry.path).join(", ")}`);
    archive = { path: norm(path.relative(ROOT, archivePath)), entries: entries.length, size: fs.statSync(archivePath).size, sha256: sha256(archivePath), missing, extra, checksumMismatches };
  }
}

const receipt = {
  schema: "pdv-quest-patch-fomod-validation.v1",
  generatedAt: new Date().toISOString(),
  status: failures.length ? "FAIL" : "PASS",
  proofBoundary: "Package structure and bytes only. This does not prove runtime routing, player surfaces, semantic correctness, or support status.",
  packageRoot: norm(path.relative(ROOT, packageRoot)),
  optionCounts: { modularOptions: options.length, channelFiles: channelFiles.length },
  simulations,
  individualSimulations,
  manifest: { fileCount: packageFiles.length, treeSha256: treeDigest, files: packageFiles },
  archive,
  warnings,
  failures,
};

if (args.includes("--write-receipt")) {
  fs.mkdirSync(path.dirname(receiptPath), { recursive: true });
  fs.writeFileSync(receiptPath, JSON.stringify(receipt, null, 2) + "\n", "utf8");
}
console.log(JSON.stringify(receipt, null, 2));
process.exitCode = failures.length ? 1 : 0;
