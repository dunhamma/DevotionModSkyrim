#!/usr/bin/env node
// Build and verify the exact, Data-relative PlayerDevotion release payload.
//
// Usage:
//   node tools/pdv_package_release.mjs --preflight --version 1.0.3
//   node tools/pdv_package_release.mjs --version 1.0.3 --date 20260726
//   node tools/pdv_package_release.mjs --verify dist/Devotion-1.0.3-20260726.zip

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { hashByteFiles, hashBytes, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(TOOL_DIR, "..");
const MOD_ROOT = process.env.PDV_MOD_PATH || "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion";
const DIST_DIR = path.join(REPO_ROOT, "dist");
const RELEASE_META_DIR = path.join(DIST_DIR, "release-meta");
const MANIFEST_PATH = path.join(
  REPO_ROOT,
  "references",
  "authoring",
  "PDV_ReleasePayload.manifest.json",
);
const NATIVE_ROOT = path.join(REPO_ROOT, "native", "DevotionPrismaBridge");
const CANONICAL_PRISMA_ROOT =
  process.env.PDV_CANONICAL_PRISMA_ROOT || path.join(NATIVE_ROOT, "mod");

// These are candidate release surfaces. The manifest, not this list, decides
// which files may ship. A new non-excluded file beneath any surface therefore
// fails as unexpected until the exact manifest is intentionally updated.
const RELEASE_SURFACES = [
  "Devotion.esp",
  "Credits.txt",
  "PDV_Calian_DESC.ini",
  "PDV_GreenPact_KID.ini",
  "PDV_ItemRecognition_KID.ini",
  "PDV_ReligiousRecognition_DISTR.ini",
  "DialogueViews",
  "Meshes",
  "MS03 Calians",
  "PrismaUI",
  "SKSE",
  "Scripts",
  "Seq",
  "Textures",
];

const EXCLUDE_PATTERNS = [
  /\.bak(-|\.|$)/i,
  /\.orig$/i,
  /\.pdb$/i,
  /^meta\.ini$/i,
  /^Backups$/i,
  /live-devotion-backups/i,
  /\.tmp$/i,
  /^Thumbs\.db$/i,
  /^\.staging$/i,
];

function fail(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

function pass(message) {
  console.log(`[PASS] ${message}`);
}

function normalizeEntry(value) {
  return value.replaceAll("\\", "/").replace(/^\.?\//, "");
}

function isExcludedEntry(relativePath) {
  return normalizeEntry(relativePath)
    .split("/")
    .some((segment) => EXCLUDE_PATTERNS.some((pattern) => pattern.test(segment)));
}

function sha256(filePath) {
  return hashBytes(filePath).toUpperCase();
}

function mtime(filePath) {
  return fs.statSync(filePath).mtimeMs;
}

function isoMtime(filePath) {
  return fs.statSync(filePath).mtime.toISOString();
}

function readJson(filePath, label) {
  if (!fs.existsSync(filePath)) {
    fail(`${label} is missing: ${filePath}`);
  }
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    fail(`${label} is not valid JSON: ${error.message}`);
  }
}

function parseArgs(argv) {
  const args = {
    version: "1.0-rc1",
    date: null,
    verify: null,
    preflight: false,
    checkPlugins: [],
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--version") {
      args.version = argv[++index];
    } else if (arg === "--date") {
      args.date = argv[++index];
    } else if (arg === "--verify") {
      args.verify = argv[++index];
    } else if (arg === "--preflight") {
      args.preflight = true;
    } else if (arg === "--check-plugin") {
      // Repeatable. Gates plugins that live OUTSIDE the release payload -- the compat patch
      // hubs -- with the same header rule the payload sweep applies to Devotion.esp.
      args.checkPlugins.push(argv[++index]);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function loadManifest() {
  const manifest = readJson(MANIFEST_PATH, "Release payload manifest");
  if (manifest.schemaVersion !== 1) {
    fail(`Unsupported release payload manifest schema: ${manifest.schemaVersion}`);
  }
  if (!Array.isArray(manifest.fixedEntries) || !Array.isArray(manifest.sourceScripts)) {
    fail("Release payload manifest must define fixedEntries and sourceScripts arrays.");
  }
  if (manifest.sourceScripts.length !== manifest.scriptPairCount) {
    fail(
      `Manifest declares ${manifest.scriptPairCount} script pairs but lists ` +
        `${manifest.sourceScripts.length} source scripts.`,
    );
  }

  const entries = [
    ...(manifest.releaseMetadata || []),
    ...manifest.fixedEntries,
    ...manifest.sourceScripts.map((name) => `Scripts/Source/${name}.psc`),
  ].map(normalizeEntry);
  const uniqueEntries = new Set(entries);
  if (uniqueEntries.size !== entries.length) {
    const seen = new Set();
    const duplicates = entries.filter((entry) => {
      if (seen.has(entry)) return true;
      seen.add(entry);
      return false;
    });
    fail(`Release payload manifest contains duplicate entries: ${[...new Set(duplicates)].join(", ")}`);
  }
  if (entries.length !== manifest.expectedEntryCount) {
    fail(
      `Manifest resolves to ${entries.length} entries, expected ${manifest.expectedEntryCount}.`,
    );
  }

  const expectedPex = new Set(manifest.sourceScripts.map((name) => `Scripts/${name}.pex`));
  const listedPex = new Set(
    manifest.fixedEntries
      .map(normalizeEntry)
      .filter((entry) => /^Scripts\/[^/]+\.pex$/i.test(entry)),
  );
  const missingPex = [...expectedPex].filter((entry) => !listedPex.has(entry));
  const extraPex = [...listedPex].filter((entry) => !expectedPex.has(entry));
  if (missingPex.length || extraPex.length) {
    fail(
      `Manifest PSC/PEX pairs are not exact. Missing PEX: ${missingPex.join(", ") || "none"}; ` +
        `unpaired PEX: ${extraPex.join(", ") || "none"}.`,
    );
  }

  return {
    ...manifest,
    entries,
    entrySet: uniqueEntries,
    liveEntries: entries.filter((entry) => !(manifest.releaseMetadata || []).includes(entry)),
  };
}

function listFilesRecursively(rootPath, prefix) {
  const files = [];
  for (const entry of fs.readdirSync(rootPath, { withFileTypes: true })) {
    const relativePath = normalizeEntry(path.posix.join(prefix, entry.name));
    if (isExcludedEntry(relativePath)) {
      console.log(`  [excluded] ${relativePath}`);
      continue;
    }
    const absolutePath = path.join(rootPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...listFilesRecursively(absolutePath, relativePath));
    } else if (entry.isFile()) {
      files.push(relativePath);
    } else {
      fail(`Unsupported filesystem entry in live release surface: ${absolutePath}`);
    }
  }
  return files;
}

function enumerateLiveReleaseSurface() {
  const entries = [];
  for (const surface of RELEASE_SURFACES) {
    const absolutePath = path.join(MOD_ROOT, surface);
    if (!fs.existsSync(absolutePath)) {
      fail(`Required release surface is missing from the live mod: ${surface}`);
    }
    const stat = fs.statSync(absolutePath);
    if (stat.isDirectory()) {
      entries.push(...listFilesRecursively(absolutePath, normalizeEntry(surface)));
    } else {
      entries.push(normalizeEntry(surface));
    }
  }
  return entries.sort();
}

function verifyExactLivePayload(manifest) {
  const actual = enumerateLiveReleaseSurface();
  const actualSet = new Set(actual);
  const expectedSet = new Set(manifest.liveEntries);
  const missing = [...expectedSet].filter((entry) => !actualSet.has(entry));
  const unexpected = [...actualSet].filter((entry) => !expectedSet.has(entry));
  if (missing.length || unexpected.length) {
    for (const entry of missing) console.error(`  [MISSING] ${entry}`);
    for (const entry of unexpected) console.error(`  [UNEXPECTED] ${entry}`);
    fail(
      `Live release payload does not match the exact manifest ` +
        `(${missing.length} missing, ${unexpected.length} unexpected).`,
    );
  }

  for (const entry of manifest.releaseMetadata || []) {
    if (!fs.existsSync(path.join(RELEASE_META_DIR, entry))) {
      fail(`Required release metadata is missing: ${path.join(RELEASE_META_DIR, entry)}`);
    }
  }

  // The packaged changelog is GENERATED from CHANGELOG.md. Existing on disk is not enough -
  // it was present and two releases stale when 1.5.0 shipped, because nothing compared the
  // two. Gate on content, not presence.
  try {
    execFileSync(process.execPath, [path.join(REPO_ROOT, "tools", "pdv_changelog_sync.mjs"), "--check"], { cwd: REPO_ROOT, stdio: "pipe" });
  } catch (error) {
    const detail = `${error.stdout ?? ""}${error.stderr ?? ""}`.trim();
    fail(`Packaged changelog is out of sync with CHANGELOG.md. Run: node tools/pdv_changelog_sync.mjs --write\n${detail}`);
  }

  pass(`Live payload exactly matches the ${manifest.expectedEntryCount}-entry manifest.`);
}

function requireNewer(outputPath, dependencyPath, label) {
  if (!fs.existsSync(outputPath)) fail(`${label} output is missing: ${outputPath}`);
  if (!fs.existsSync(dependencyPath)) fail(`${label} dependency is missing: ${dependencyPath}`);
  if (mtime(outputPath) <= mtime(dependencyPath)) {
    fail(
      `${label} is stale: ${path.basename(outputPath)} ${isoMtime(outputPath)} is not newer than ` +
        `${path.basename(dependencyPath)} ${isoMtime(dependencyPath)}.`,
    );
  }
}

function verifyAllPapyrusFreshness(manifest) {
  const sourceRoot = path.join(MOD_ROOT, "Scripts", "Source");
  const pexRoot = path.join(MOD_ROOT, "Scripts");
  const hashes = [];
  for (const scriptName of manifest.sourceScripts) {
    const pscPath = path.join(sourceRoot, `${scriptName}.psc`);
    const pexPath = path.join(pexRoot, `${scriptName}.pex`);
    requireNewer(pexPath, pscPath, `${scriptName} compile freshness`);
    hashes.push({
      script: scriptName,
      pscSha256: sha256(pscPath),
      pexSha256: sha256(pexPath),
      pscMtime: isoMtime(pscPath),
      pexMtime: isoMtime(pexPath),
    });
  }

  const managerPsc = path.join(sourceRoot, "PDV__ManagerQuest.psc");
  const managerPex = path.join(pexRoot, "PDV__ManagerQuest.pex");
  const mcmPex = path.join(pexRoot, "PDV_MCM.pex");
  requireNewer(mcmPex, managerPsc, "PDV_MCM manager-source dependency");
  requireNewer(mcmPex, managerPex, "PDV_MCM manager-bytecode dependency");
  pass(
    `${hashes.length} PSC/PEX pairs are complete and fresh; PDV_MCM is newer than manager source and bytecode.`,
  );
  return hashes;
}

function nativeDependencies() {
  const dependencies = [
    path.join(NATIVE_ROOT, "xmake.lua"),
    path.join(NATIVE_ROOT, "xmake-requires.lock"),
  ];
  for (const relativeRoot of ["src", "include"]) {
    const root = path.join(NATIVE_ROOT, relativeRoot);
    for (const entry of fs.readdirSync(root, { recursive: true, withFileTypes: true })) {
      if (!entry.isFile()) continue;
      const entryPath = path.join(entry.parentPath || entry.path, entry.name);
      if (/\.(c|cc|cpp|cxx|h|hh|hpp|hxx|inl)$/i.test(entry.name)) {
        dependencies.push(entryPath);
      }
    }
  }
  return dependencies;
}

function verifyNativeFreshness() {
  const dllPath = path.join(MOD_ROOT, "SKSE", "Plugins", "DevotionPrismaBridge.dll");
  const dependencies = nativeDependencies();
  for (const dependency of dependencies) {
    requireNewer(dllPath, dependency, "DevotionPrismaBridge DLL");
  }
  pass(`Native DLL is newer than all ${dependencies.length} C++/build dependencies.`);
}

function verifyPrismaParity(manifest) {
  const prismaEntries = manifest.liveEntries.filter((entry) => entry.startsWith("PrismaUI/"));
  for (const entry of prismaEntries) {
    const livePath = path.join(MOD_ROOT, ...entry.split("/"));
    const canonicalPath = path.join(CANONICAL_PRISMA_ROOT, ...entry.split("/"));
    if (!fs.existsSync(canonicalPath)) {
      fail(`Canonical Prisma asset is missing: ${canonicalPath}`);
    }
    if (sha256(livePath) !== sha256(canonicalPath)) {
      fail(`Live Prisma asset differs from canonical native-mod copy: ${entry}`);
    }
  }

  const canonicalView = path.join(CANONICAL_PRISMA_ROOT, "PrismaUI", "views", "Devotion");
  const expectedKey = `pdv-${hashByteFiles([
    path.join(canonicalView, "app.js"),
    path.join(canonicalView, "styles.css"),
  ]).slice(0, 16)}`;
  const index = fs.readFileSync(path.join(canonicalView, "index.html"), "utf8");
  const actualKeys = [
    index.match(/styles\.css\?v=([A-Za-z0-9_-]+)/)?.[1],
    index.match(/app\.js\?v=([A-Za-z0-9_-]+)/)?.[1],
  ];
  if (actualKeys.some((key) => key !== expectedKey)) {
    fail(
      `Prisma cache key mismatch: expected ${expectedKey}, found ` +
        `${actualKeys.map((value) => value || "missing").join(", ")}.`,
    );
  }
  pass(`${prismaEntries.length} Prisma assets match canonical bytes and cache key ${expectedKey}.`);
}

function verifyHousecarlProof() {
  const checker = path.join(REPO_ROOT, "tools", "pdv_release_proof_refresh.mjs");
  let output = "";
  try {
    output = execFileSync(process.execPath, [checker, "--check"], {
      cwd: REPO_ROOT,
      encoding: "utf8",
      maxBuffer: 32 * 1024 * 1024,
      timeout: 300_000,
    });
  } catch (error) {
    const detail = [error.stdout, error.stderr].filter(Boolean).join("\n").trim();
    fail(`live houseCARL release-proof check failed.\n${detail || error.message}`);
  }
  for (const line of output.trim().split(/\r?\n/)) console.log(`  ${line}`);
  pass("houseCARL release proof was independently re-derived against the live profile.");
}

function verifyBuildVersion(version) {
  const sourcePath = path.join(MOD_ROOT, "Scripts", "Source", "PDV__ManagerQuest.psc");
  const pexPath = path.join(MOD_ROOT, "Scripts", "PDV__ManagerQuest.pex");
  const source = fs.readFileSync(sourcePath, "utf8");
  const match = source.match(/PDV_BUILD_VERSION\s*=\s*"([^"]*)"/);
  if (!match) fail(`Version gate: PDV_BUILD_VERSION not found in ${sourcePath}`);
  if (match[1] !== version) {
    fail(`Version gate: --version ${version}, but manager source declares ${match[1]}.`);
  }
  if (!fs.readFileSync(pexPath).includes(Buffer.from(version, "utf8"))) {
    fail(`Version gate: manager PEX does not contain ${version}; recompile manager then MCM.`);
  }
  pass(`Version gate: manager source, bytecode, and archive label agree on ${version}.`);
}

function verifyReceiverAnam() {
  const checker = path.join(REPO_ROOT, "tools", "pdv_fix_receiver_anam.mjs");
  const esp = path.join(MOD_ROOT, "Devotion.esp");
  let output = "";
  try {
    output = execFileSync(process.execPath, [checker, esp, "--dry"], { encoding: "utf8" });
  } catch (error) {
    fail(`ANAM gate checker failed: ${error.message}`);
  }
  if (/patching \(adding/i.test(output)) {
    fail("ANAM gate: one or more Story Manager receivers lack ANAM.");
  }
  pass("ANAM gate: every Story Manager receiver carries ANAM.");
}

// --- Plugin header gate (2026-08-07) -------------------------------------------------------------
// A plugin's load-order cost is the ESL flag in its TES4 header, not its file extension. The
// standing rule (memory `patches-must-be-esl-flagged`) is: every PDV patch plugin ships ESL-flagged
// (ESPFE -- zero full slots), and the main Devotion.esp must NEVER be flagged (it defines far more
// records than the light ceiling; an accidentally flagged main plugin is a catastrophic ship).
// This gate reads the header bytes directly so the claim is measured, not assumed.
const TES4_FLAG_ESM = 0x1;
const TES4_FLAG_ESL = 0x200;

function readPluginHeader(filePath) {
  const fd = fs.openSync(filePath, "r");
  try {
    const head = Buffer.alloc(24);
    const bytesRead = fs.readSync(fd, head, 0, 24, 0);
    if (bytesRead < 24) fail(`Plugin too short to carry a TES4 header: ${filePath}`);
    const signature = head.toString("ascii", 0, 4);
    if (signature !== "TES4") {
      fail(`Not a plugin (TES4 signature missing, found "${signature}"): ${filePath}`);
    }
    const flags = head.readUInt32LE(8);
    return {
      flags,
      esm: (flags & TES4_FLAG_ESM) !== 0,
      esl: (flags & TES4_FLAG_ESL) !== 0,
    };
  } finally {
    fs.closeSync(fd);
  }
}

function checkPluginHeader(filePath) {
  const baseName = path.basename(filePath);
  const header = readPluginHeader(filePath);
  const isMainMod = /^Devotion\.esp$/i.test(baseName);
  if (isMainMod && header.esl) {
    fail(
      `${baseName} carries the ESL flag (0x${header.flags.toString(16)}). The main mod defines far ` +
        `more records than the light ceiling and must ship as a full plugin.`,
    );
  }
  if (!isMainMod && !header.esl) {
    fail(
      `${baseName} is NOT ESL-flagged (0x${header.flags.toString(16)}). Patch plugins ship ` +
        `ESL-flagged (ESPFE) per the standing rule -- flag the header (housecarl_compact_plugin ` +
        `handles out-of-range FormIDs), never rename to .esl.`,
    );
  }
  pass(
    `${baseName}: TES4 header correct (${isMainMod ? "full plugin, no ESL flag" : "ESL-flagged light plugin"}).`,
  );
}

function verifyPluginHeaders(manifest) {
  const pluginEntries = manifest.entries.filter((entry) => /\.es[pml]$/i.test(entry));
  if (pluginEntries.length === 0) fail("Release payload lists no plugin at all.");
  for (const entry of pluginEntries) {
    checkPluginHeader(sourcePathForEntry(entry, manifest));
  }
}

function verifySeq() {
  const seqPath = path.join(MOD_ROOT, "Seq", "Devotion.seq");
  if (!fs.existsSync(seqPath) || fs.statSync(seqPath).size === 0) {
    fail(`SEQ gate: missing or empty ${seqPath}`);
  }
  pass(`SEQ gate: Devotion.seq is present (${fs.statSync(seqPath).size} bytes).`);
}

function powershell(script) {
  return execFileSync("powershell.exe", ["-NoProfile", "-NonInteractive", "-Command", script], {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
}

function zipEntries(zipPath) {
  const escaped = zipPath.replaceAll("'", "''");
  const script = `Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead('${escaped}')
$archive.Entries | ForEach-Object { $_.FullName }
$archive.Dispose()`;
  return powershell(script)
    .split(/\r?\n/)
    .map((line) => normalizeEntry(line.trim()))
    .filter(Boolean);
}

function compareExactEntries(actualEntries, expectedEntries, label) {
  const actualSet = new Set(actualEntries);
  const expectedSet = new Set(expectedEntries);
  const missing = [...expectedSet].filter((entry) => !actualSet.has(entry));
  const unexpected = [...actualSet].filter((entry) => !expectedSet.has(entry));
  if (actualEntries.length !== actualSet.size) {
    fail(`${label} contains duplicate paths.`);
  }
  if (missing.length || unexpected.length) {
    for (const entry of missing) console.error(`  [MISSING] ${entry}`);
    for (const entry of unexpected) console.error(`  [UNEXPECTED] ${entry}`);
    fail(`${label} differs from manifest (${missing.length} missing, ${unexpected.length} unexpected).`);
  }
}

function verifyArchive(zipPath, manifest) {
  const entries = zipEntries(zipPath);
  const leaked = entries.filter(isExcludedEntry);
  if (leaked.length) {
    for (const entry of leaked) console.error(`  [LEAK] ${entry}`);
    fail(`${leaked.length} excluded file(s) reached ${path.basename(zipPath)}.`);
  }
  compareExactEntries(entries, manifest.entries, path.basename(zipPath));
  const size = fs.statSync(zipPath).size;
  const checksum = sha256(zipPath);
  pass(`Archive exactly matches the ${manifest.expectedEntryCount}-entry manifest.`);
  console.log(`  entries : ${entries.length}`);
  console.log(`  size    : ${(size / 1024 / 1024).toFixed(1)} MB (${size} bytes)`);
  console.log(`  sha256  : ${checksum}`);
  return { entryCount: entries.length, size, sha256: checksum };
}

function runPreflight(version, manifest) {
  if (!fs.existsSync(MOD_ROOT)) {
    fail(`Live mod folder not found: ${MOD_ROOT} (set PDV_MOD_PATH to override).`);
  }
  verifyExactLivePayload(manifest);
  verifyPluginHeaders(manifest);
  const papyrusHashes = verifyAllPapyrusFreshness(manifest);
  verifyBuildVersion(version);
  verifyNativeFreshness();
  verifyPrismaParity(manifest);
  verifyReceiverAnam();
  verifySeq();
  verifyHousecarlProof();
  return papyrusHashes;
}

function sourcePathForEntry(entry, manifest) {
  if ((manifest.releaseMetadata || []).includes(entry)) {
    return path.join(RELEASE_META_DIR, ...entry.split("/"));
  }
  return path.join(MOD_ROOT, ...entry.split("/"));
}

function stageExactPayload(stagingDir, manifest) {
  for (const entry of manifest.entries) {
    const sourcePath = sourcePathForEntry(entry, manifest);
    const targetPath = path.join(stagingDir, ...entry.split("/"));
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.copyFileSync(sourcePath, targetPath);
  }
}

const args = parseArgs(process.argv.slice(2));
const manifest = loadManifest();

if (args.checkPlugins.length > 0) {
  console.log("PDV plugin header check");
  console.log("");
  for (const candidate of args.checkPlugins) {
    const pluginPath = path.resolve(candidate);
    if (!fs.existsSync(pluginPath)) fail(`Plugin not found: ${pluginPath}`);
    checkPluginHeader(pluginPath);
  }
  console.log("");
  console.log(`Plugin header check complete: ${args.checkPlugins.length} plugin(s), all correct.`);
  process.exit(0);
}

if (args.verify) {
  const zipPath = path.resolve(args.verify);
  if (!fs.existsSync(zipPath)) fail(`Archive not found: ${zipPath}`);
  console.log(`Verifying ${zipPath}`);
  verifyArchive(zipPath, manifest);
  process.exit(0);
}

console.log("PDV release preflight");
console.log(`  source   : ${MOD_ROOT}`);
console.log(`  manifest : ${MANIFEST_PATH}`);
console.log("");
const papyrusHashes = runPreflight(args.version, manifest);

if (args.preflight) {
  console.log("");
  console.log(`Preflight complete: ${papyrusHashes.length} script pairs, no archive written.`);
  process.exit(0);
}

const stamp = args.date || new Date().toISOString().slice(0, 10).replaceAll("-", "");
const zipName = `Devotion-${args.version}-${stamp}.zip`;
const zipPath = path.join(DIST_DIR, zipName);
const stagingRoot = path.join(DIST_DIR, ".staging");
const stagingDir = path.join(stagingRoot, `Devotion-${args.version}-${stamp}`);

console.log("");
console.log(`Staging ${manifest.entries.length} exact entries...`);
fs.rmSync(stagingRoot, { recursive: true, force: true });
fs.mkdirSync(stagingDir, { recursive: true });
stageExactPayload(stagingDir, manifest);

const stagedEntries = listFilesRecursively(stagingDir, "");
compareExactEntries(stagedEntries, manifest.entries, "Staged payload");

fs.rmSync(zipPath, { force: true });
const escapedStaging = stagingDir.replaceAll("'", "''");
const escapedZip = zipPath.replaceAll("'", "''");
powershell(`Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory('${escapedStaging}', '${escapedZip}', [IO.Compression.CompressionLevel]::Optimal, $false)`);
fs.rmSync(stagingRoot, { recursive: true, force: true });

console.log("");
const archive = verifyArchive(zipPath, manifest);
const receiptPath = `${zipPath}.proof.json`;
writeTextWithEol(
  receiptPath,
  `${JSON.stringify(
    {
      schemaVersion: 1,
      generatedAt: new Date().toISOString(),
      archive: path.basename(zipPath),
      manifest: path.relative(REPO_ROOT, MANIFEST_PATH).replaceAll("\\", "/"),
      manifestSha256: sha256(MANIFEST_PATH),
      entryCount: archive.entryCount,
      sizeBytes: archive.size,
      sha256: archive.sha256,
      papyrusPairCount: papyrusHashes.length,
      proofBoundary: {
        staticAndPackaging: "passed",
        housecarlReadback: "passed-for-esp-hash",
        runtimeAndManual: "not-claimed-by-packager",
      },
    },
    null,
    2,
  )}\n`,
  "lf",
);
console.log("");
console.log(`Built ${zipName}`);
console.log(`Proof receipt: ${receiptPath}`);
