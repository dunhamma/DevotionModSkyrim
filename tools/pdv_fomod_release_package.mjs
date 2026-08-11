#!/usr/bin/env node
// Build THE distribution: one FOMOD carrying core plus the optional per-mod patches.
//
// OWNER RULING 2026-08-08: there is exactly ONE distribution and this builds it. Do not
// ship a core-only archive and do not ship a patches-only archive -- a core-only package
// silently underdelivers, and a patches-only package is useless on its own. The plain
// core zip that pdv_package_release.mjs produces is an INPUT to this, not a release.
//
// Layout produced (matching the hand-assembled 1.5.0 package this replaces):
//   core/     required, always installed  <- the validated core payload
//   common/   the optional per-mod patch folders
//   plugins/  the individual patch plugin variants
//   fomod/    ModuleConfig.xml + info.xml, with core as <requiredInstallFiles>
//
// Every player-facing file in the staged tree is scanned before zipping, so development
// or proof status cannot reach a distributed package. See tools/lib/pdv_player_facing_copy.mjs.

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { findDevStatus, filesUnder } from "./lib/pdv_player_facing_copy.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PATCH_TREE = path.join(ROOT, "dist", "PDV_QuestModPatches_FOMOD");
const STAGE = path.join(ROOT, "dist", ".fomod-stage");

const KNOWN_FLAGS = new Set(["--version", "--output", "--reuse-core"]);
const argv = process.argv.slice(2);
for (const arg of argv) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}
const valueOf = (flag) => { const i = argv.indexOf(flag); return i >= 0 ? argv[i + 1] : null; };
const version = valueOf("--version");
if (!version) throw new Error("--version is required, e.g. --version 1.5.0");
const reuseCore = valueOf("--reuse-core");

const ps = (script) =>
  execFileSync("powershell", ["-NoProfile", "-Command", script], { cwd: ROOT, stdio: "pipe", encoding: "utf8" });

// ---- 1. The core payload. Built by the sanctioned packager unless one is handed in. ----
let coreZip = reuseCore;
if (!coreZip) {
  const out = execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_package_release.mjs"), "--version", version],
    { cwd: ROOT, encoding: "utf8" });
  const built = out.match(/^Built (.+\.zip)\s*$/m)?.[1];
  if (!built) throw new Error(`Could not determine the core zip from pdv_package_release output:\n${out}`);
  coreZip = path.join("dist", built);
}
if (!fs.existsSync(path.join(ROOT, coreZip))) throw new Error(`Core zip not found: ${coreZip}`);

// ---- 1b. The patch tree must match its source before any of it is staged ----
// PATCH_TREE is copied wholesale below, so a stale or hand-edited script in it ships without
// comment. The patch-only Papyrus now lives in patch-source/ and dist/ is produced from it;
// this refuses to package a tree that has drifted, or one whose .psc no longer matches the
// .pex compiled from it. Presence was never the question - correctness is.
try {
  execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_patch_source_deploy.mjs"), "--check"], { cwd: ROOT, stdio: "pipe" });
} catch (error) {
  const detail = `${error.stdout ?? ""}${error.stderr ?? ""}`.trim();
  throw new Error(`Patch tree is out of sync with patch-source/. Run: node tools/pdv_patch_source_deploy.mjs --write\n${detail}`);
}

// ---- 2. Stage ----
fs.rmSync(STAGE, { recursive: true, force: true });
fs.mkdirSync(path.join(STAGE, "core"), { recursive: true });
ps(`$ErrorActionPreference='Stop'; Expand-Archive -LiteralPath '${path.join(ROOT, coreZip).replaceAll("'", "''")}' -DestinationPath '${path.join(STAGE, "core").replaceAll("'", "''")}' -Force`);
for (const entry of fs.readdirSync(PATCH_TREE)) {
  fs.cpSync(path.join(PATCH_TREE, entry), path.join(STAGE, entry), { recursive: true });
}

// ---- 3. Make the installer core-aware ----
const configPath = path.join(STAGE, "fomod", "ModuleConfig.xml");
let config = fs.readFileSync(configPath, "utf8");
config = config.replace(/<moduleName>[^<]*<\/moduleName>/, "<moduleName>Devotion</moduleName>");
if (!/<requiredInstallFiles>/.test(config)) {
  config = config.replace(/(<\/moduleName>)/,
    `$1\n  <requiredInstallFiles>\n    <folder source="core" destination="" priority="0" />\n  </requiredInstallFiles>`);
}
if (!/source="core"/.test(config)) throw new Error("core was not registered as a required install");
fs.writeFileSync(configPath, config, "utf8");

// info.xml is GENERATED, not inherited. This header claimed to produce it and did not: the
// file was copied verbatim out of the patch tree, so every build shipped the ARR-era
// PatchHub's copy. The 1.5.0 installer told users its name was "Devotion - Modular Mod
// PatchHub", its version was "ARR 2.5 experimental candidate (2026-08-07)", and that it
// REQUIRED Devotion to be installed separately - which is the opposite of true now that core
// is inside this package. None of it errored, because nothing regenerated the file and
// nothing compared it to the build.
//
// Deriving it from --version is the point: a version string that is typed by hand somewhere
// is a version string that goes stale, and this one went stale by a whole release line.
const infoPath = path.join(STAGE, "fomod", "info.xml");
const machineVersion = `${/^\d+\.\d+\.\d+$/.test(version) ? version : "1.0.0"}.0`;
fs.writeFileSync(infoPath, `<?xml version="1.0" encoding="utf-8"?>
<fomod>
  <Name>Devotion</Name>
  <Author>Devotion (PDV)</Author>
  <Version MachineVersion="${machineVersion}">${version}</Version>
  <Website>https://www.nexusmods.com/skyrimspecialedition/</Website>
  <Description>
    Devotion tracks your character's religious devotion through the traditions their race
    actually holds, and adjusts each god's standing from what you do.

    This installer contains the whole mod. Devotion itself installs automatically and cannot
    be deselected. The optional per-mod patches below teach it how the gods react to other
    mods' content; each one is locked to its own source plugin, so an option you cannot use
    is not offered, and a patch for a mod you later remove goes quiet rather than breaking.
    The included README lists every quest patch plus the KID and SPID integration scope.
  </Description>
  <Groups>
    <element>Gameplay</element>
    <element>Quests and Adventures</element>
    <element>Patches</element>
  </Groups>
</fomod>
`, "utf8");

// ---- 4. Gate the staged tree BEFORE it becomes a package ----
const failures = [];
for (const file of filesUnder(STAGE, (f) => /\.(xml|md|txt|json|html?|js|css)$/i.test(f))) {
  fs.readFileSync(file, "utf8").split(/\r?\n/).forEach((line, index) => {
    const hit = findDevStatus(line);
    if (hit) failures.push({ file: path.relative(STAGE, file).replaceAll("\\", "/"), line: index + 1, match: hit });
  });
}
if (failures.length) {
  console.error(JSON.stringify({ status: "FAIL", reason: "development status in player-facing text", failures }, null, 2));
  process.exit(1);
}

// ---- 5. Package ----
const stamp = new Date().toISOString().slice(0, 10).replaceAll("-", "");
const output = valueOf("--output") ?? path.join("dist", `Devotion-FOMOD-${version}-${stamp}.zip`);
const outAbs = path.join(ROOT, output);
fs.rmSync(outAbs, { force: true });
ps(`$ErrorActionPreference='Stop'; Compress-Archive -LiteralPath (Get-ChildItem -LiteralPath '${STAGE.replaceAll("'", "''")}' | ForEach-Object {$_.FullName}) -DestinationPath '${outAbs.replaceAll("'", "''")}' -CompressionLevel Optimal`);

const entries = Number(ps(`Add-Type -A System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead('${outAbs.replaceAll("'", "''")}'); $z.Entries.Count; $z.Dispose()`).trim());
fs.rmSync(STAGE, { recursive: true, force: true });

console.log(JSON.stringify({
  status: "PASS",
  output: output.replaceAll("\\", "/"),
  coreZip: coreZip.replaceAll("\\", "/"),
  entries,
  bytes: fs.statSync(outAbs).size,
  playerFacingScan: "clean",
}, null, 2));
