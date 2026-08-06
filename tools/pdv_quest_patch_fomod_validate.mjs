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

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const args = process.argv.slice(2);
const value = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : null;
};
const packageRoot = path.resolve(ROOT, value("--root") ?? "dist/PDV_QuestModPatches_FOMOD");
const archivePath = value("--archive") ? path.resolve(ROOT, value("--archive")) : null;
const receiptPath = path.resolve(ROOT, value("--receipt") ?? "references/authoring/PDV_QuestModPatches_FOMOD_Validation.json");
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
    options.push({ name: match[1], sources });
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

function archiveEntries(file) {
  const escaped = file.replaceAll("'", "''");
  const script = `$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead('${escaped}'); try {$z.Entries | Where-Object {-not [string]::IsNullOrEmpty($_.Name)} | ForEach-Object {$_.FullName.Replace('\\','/')}} finally {$z.Dispose()}`;
  return execFileSync("powershell", ["-NoProfile", "-Command", script], { encoding: "utf8", maxBuffer: 32 * 1024 * 1024 })
    .split(/\r?\n/).map((entry) => norm(entry.trim())).filter(Boolean).sort();
}

assertXmlParses();
const xml = fs.existsSync(xmlPath) ? fs.readFileSync(xmlPath, "utf8") : "";
const options = parseOptions(xml);
const authoria = options.find((option) => option.name.startsWith("Authoria "));
const individual = options.filter((option) => option.sources.length && option !== authoria);
if (!authoria) fail("Authoria combined option not found.");
if (!individual.length) fail("No individual FOMOD options found.");

const simulations = [];
if (authoria) simulations.push(expandSelection("authoria-combined", [authoria]));
simulations.push(expandSelection("all-individual", individual));
const representative = [individual[0], individual[Math.floor(individual.length / 2)], individual.at(-1)].filter(Boolean);
simulations.push(expandSelection("representative-subset", [...new Set(representative)]));

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

let archive = null;
if (archivePath) {
  if (!fs.existsSync(archivePath)) {
    fail(`Archive not found: ${path.relative(ROOT, archivePath)}`);
  } else {
    const entries = archiveEntries(archivePath);
    const manifestNames = packageFiles.map((entry) => entry.path).sort();
    const missing = manifestNames.filter((entry) => !entries.includes(entry));
    const extra = entries.filter((entry) => !manifestNames.includes(entry));
    if (missing.length) fail(`Archive is missing ${missing.length} manifest file(s): ${missing.slice(0, 10).join(", ")}`);
    if (extra.length) fail(`Archive has ${extra.length} extra file(s): ${extra.slice(0, 10).join(", ")}`);
    archive = { path: norm(path.relative(ROOT, archivePath)), entries: entries.length, size: fs.statSync(archivePath).size, sha256: sha256(archivePath), missing, extra };
  }
}

if (options.length !== 36) warnings.push(`Expected 36 total <plugin> nodes (2 mode + 34 content); found ${options.length}.`);
if (channelFiles.length !== 34) warnings.push(`Expected 34 channel JSON files; found ${channelFiles.length}.`);

const receipt = {
  schema: "pdv-quest-patch-fomod-validation.v1",
  generatedAt: new Date().toISOString(),
  status: failures.length ? "FAIL" : "PASS",
  proofBoundary: "Package structure and bytes only. This does not prove runtime routing, player surfaces, semantic correctness, or support status.",
  packageRoot: norm(path.relative(ROOT, packageRoot)),
  optionCounts: { totalPluginNodes: options.length, individualContentOptions: individual.length, channelFiles: channelFiles.length },
  simulations,
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
