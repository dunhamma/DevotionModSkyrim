#!/usr/bin/env node
// Build a clean, Data-relative Devotion release zip from the live MO2 mod folder.
//
// Why this exists: the 1.0-rc1 zip was assembled by hand and shipped
// Scripts/Source/PDV__ManagerQuest.psc.orig -- 876 KB of stale source, ~11% of
// the download -- because the exclusions lived in someone's shell history rather
// than in the repo. This encodes them once. The zip is built from a staged tree
// that is filtered on the way in, so an excluded file cannot reach the archive
// even if the pattern list is later edited carelessly.
//
// Usage:
//   node tools/pdv_package_release.mjs --version 1.0-rc1
//   node tools/pdv_package_release.mjs --version 1.0 --date 20260716
//   node tools/pdv_package_release.mjs --verify dist/Devotion-1.0-rc1-20260716.zip
//
// Verification is a re-scan of the finished archive, not a claim about the
// staging tree: --verify reopens the zip and fails on any excluded pattern.

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";

const REPO_ROOT = process.cwd();
const MOD_ROOT = process.env.PDV_MOD_PATH || "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion";
const DIST_DIR = path.join(REPO_ROOT, "dist");
const RELEASE_META_DIR = path.join(DIST_DIR, "release-meta");

// Everything the player needs, Data-relative. Anything not listed never ships.
const INCLUDE_TOP_LEVEL = [
  "Devotion.esp",
  "Credits.txt",
  "DialogueViews",
  "Meshes",
  "PrismaUI",
  "SKSE",
  "Scripts",
  "Seq",
  "Textures",
];

// Loose files added at the archive root from a tracked source, so the release
// notes are versioned in git rather than surviving only inside a build artifact.
const RELEASE_META_FILES = ["README.txt", "CHANGELOG.txt"];

// Excluded by pattern, applied to every path segment. `.orig` is the one that
// leaked into 1.0-rc1; `.bak` covers the timestamped source and ESP snapshots.
const EXCLUDE_PATTERNS = [
  /\.bak(-|\.|$)/i,
  /\.orig$/i,
  /\.pdb$/i,
  /^meta\.ini$/i,
  /^Backups$/i,
  /live-devotion-backups/i,
  /\.tmp$/i,
  /^Thumbs\.db$/i,
];

function isExcluded(name) {
  return EXCLUDE_PATTERNS.some((pattern) => pattern.test(name));
}

function fail(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = { version: "1.0-rc1", date: null, verify: null };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--version") {
      args.version = argv[++i];
    } else if (argv[i] === "--date") {
      args.date = argv[++i];
    } else if (argv[i] === "--verify") {
      args.verify = argv[++i];
    }
  }
  return args;
}

// Copy a tree, dropping excluded entries. Returns the number of files staged.
function stageTree(sourceDir, targetDir) {
  let staged = 0;
  for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
    if (isExcluded(entry.name)) {
      console.log(`  [skip] ${path.relative(MOD_ROOT, path.join(sourceDir, entry.name))}`);
      continue;
    }
    const sourcePath = path.join(sourceDir, entry.name);
    const targetPath = path.join(targetDir, entry.name);
    if (entry.isDirectory()) {
      fs.mkdirSync(targetPath, { recursive: true });
      staged += stageTree(sourcePath, targetPath);
    } else {
      fs.copyFileSync(sourcePath, targetPath);
      staged += 1;
    }
  }
  return staged;
}

function powershell(script) {
  return execFileSync("powershell.exe", ["-NoProfile", "-NonInteractive", "-Command", script], {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
}

function zipEntries(zipPath) {
  const script = `Add-Type -A System.IO.Compression.FileSystem
$z = [IO.Compression.ZipFile]::OpenRead('${zipPath.replace(/'/g, "''")}')
$z.Entries | ForEach-Object { $_.FullName }
$z.Dispose()`;
  return powershell(script).split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex").toUpperCase();
}

// The archive is the artifact that ships, so verify the archive -- not the
// staging tree it was built from.
function verifyArchive(zipPath) {
  const entries = zipEntries(zipPath);
  const leaked = entries.filter((entry) => entry.split(/[\\/]/).some(isExcluded));
  if (leaked.length) {
    for (const entry of leaked) {
      console.error(`  [LEAK] ${entry}`);
    }
    fail(`${leaked.length} excluded file(s) reached ${path.basename(zipPath)}.`);
  }

  const size = fs.statSync(zipPath).size;
  console.log(`[PASS] No excluded files in the archive.`);
  console.log(`  entries : ${entries.length}`);
  console.log(`  size    : ${(size / 1024 / 1024).toFixed(1)} MB`);
  console.log(`  sha256  : ${sha256(zipPath)}`);
  return entries.length;
}

const args = parseArgs(process.argv.slice(2));

if (args.verify) {
  if (!fs.existsSync(args.verify)) {
    fail(`Archive not found: ${args.verify}`);
  }
  console.log(`Verifying ${args.verify}`);
  verifyArchive(path.resolve(args.verify));
  process.exit(0);
}

if (!fs.existsSync(MOD_ROOT)) {
  fail(`Live mod folder not found: ${MOD_ROOT} (set PDV_MOD_PATH to override).`);
}

const stamp = args.date || new Date().toISOString().slice(0, 10).replace(/-/g, "");
const zipName = `Devotion-${args.version}-${stamp}.zip`;
const zipPath = path.join(DIST_DIR, zipName);
const stagingDir = path.join(DIST_DIR, ".staging", `Devotion-${args.version}-${stamp}`);

console.log(`PDV release packager`);
console.log(`  source  : ${MOD_ROOT}`);
console.log(`  output  : ${zipPath}`);
console.log("");

fs.rmSync(path.join(DIST_DIR, ".staging"), { recursive: true, force: true });
fs.mkdirSync(stagingDir, { recursive: true });

let staged = 0;
for (const name of INCLUDE_TOP_LEVEL) {
  const sourcePath = path.join(MOD_ROOT, name);
  if (!fs.existsSync(sourcePath)) {
    fail(`Required release input is missing from the live mod folder: ${name}`);
  }
  const targetPath = path.join(stagingDir, name);
  if (fs.statSync(sourcePath).isDirectory()) {
    fs.mkdirSync(targetPath, { recursive: true });
    staged += stageTree(sourcePath, targetPath);
  } else {
    fs.copyFileSync(sourcePath, targetPath);
    staged += 1;
  }
}

for (const name of RELEASE_META_FILES) {
  const sourcePath = path.join(RELEASE_META_DIR, name);
  if (!fs.existsSync(sourcePath)) {
    fail(`Release metadata is missing: ${sourcePath}`);
  }
  fs.copyFileSync(sourcePath, path.join(stagingDir, name));
  staged += 1;
}

console.log("");
console.log(`Staged ${staged} file(s). Compressing...`);

fs.rmSync(zipPath, { force: true });
powershell(`Add-Type -A System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory('${stagingDir.replace(/'/g, "''")}', '${zipPath.replace(/'/g, "''")}', [IO.Compression.CompressionLevel]::Optimal, $false)`);

fs.rmSync(path.join(DIST_DIR, ".staging"), { recursive: true, force: true });

console.log("");
const entryCount = verifyArchive(zipPath);
if (entryCount !== staged) {
  fail(`Archive holds ${entryCount} entries but ${staged} files were staged.`);
}
console.log("");
console.log(`Built ${zipName}`);
