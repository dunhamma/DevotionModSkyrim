#!/usr/bin/env node
/*
 * Build the SHIPPING package: one FOMOD that installs the core mod AND the per-mod
 * patches, for both MO2 and Vortex.
 *
 * Why this exists. Core and patches used to be two separate deliverables, and that split
 * had a silent failure mode: a user (or a list author) installs core, every gate reports
 * green, and every already-covered mod awards NOTHING because its channel was never
 * installed. Nothing errors. Nothing warns. It was hit for real on the JoJ list on
 * 2026-08-08 - core went in, 18 covered mods sat inert, and only an explicit check for
 * common/<Mod> folders found it. One package makes that impossible to reach by accident.
 *
 * Core is installed through <requiredInstallFiles>, not an option group. That is the
 * honest expression of "not optional": it installs unconditionally, shows no tickbox, and
 * cannot be deselected. Both MO2 and Vortex honour it.
 *
 * Core is taken from the archive built by pdv_package_release.mjs rather than re-resolved
 * from the manifest here. That archive has already passed all nine release gates, so the
 * core inside this FOMOD is byte-identical to the gated core release by construction -
 * there is no second implementation to drift.
 */

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const KNOWN_FLAGS = new Set(["--core", "--output", "--keep-staging"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const HUB = path.join(ROOT, "dist", "PDV_QuestModPatches_FOMOD");
const STAGING = path.join(ROOT, "dist", "_staging_combined_fomod");

const argValue = (name) => {
  const i = process.argv.indexOf(name);
  if (i < 0) return null;
  const v = process.argv[i + 1];
  if (!v) throw new Error(`${name} requires a value`);
  return v;
};

// --- inputs ----------------------------------------------------------------------
const corePath = path.resolve(ROOT, argValue("--core") ?? "");
if (!argValue("--core")) throw new Error("--core <path to the core release zip> is required");
if (!fs.existsSync(corePath)) throw new Error(`Core archive not found: ${corePath}`);

const coreProof = `${corePath}.proof.json`;
if (!fs.existsSync(coreProof)) {
  throw new Error(
    `Core archive has no proof receipt: ${coreProof}\n` +
      "Refusing to ship a core build that did not come from pdv_package_release.mjs.",
  );
}
const proof = JSON.parse(fs.readFileSync(coreProof, "utf8"));
const coreSha = crypto.createHash("sha256").update(fs.readFileSync(corePath)).digest("hex").toUpperCase();
if (proof.sha256 !== coreSha) {
  throw new Error(`Core archive does not match its proof receipt (receipt ${proof.sha256}, actual ${coreSha}).`);
}

const output = path.resolve(ROOT, argValue("--output") ?? `dist/Devotion-FOMOD-${proof.archive.replace(/^Devotion-/, "").replace(/\.zip$/, "")}.zip`);
if (fs.existsSync(output)) throw new Error(`Refusing to overwrite existing archive: ${output}`);

// --- the patch hub must be self-consistent before it is bundled -------------------
execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_patch_fomod_generate.mjs")], { cwd: ROOT, stdio: "inherit" });
execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_patch_fomod_validate.mjs")], { cwd: ROOT, stdio: "inherit" });

// --- stage -----------------------------------------------------------------------
fs.rmSync(STAGING, { recursive: true, force: true });
fs.mkdirSync(path.join(STAGING, "fomod"), { recursive: true });

// core: extract the gated archive into core/
execFileSync("powershell", [
  "-NoProfile", "-Command",
  `$ErrorActionPreference='Stop'; Expand-Archive -LiteralPath '${corePath.replaceAll("'", "''")}' -DestinationPath '${path.join(STAGING, "core").replaceAll("'", "''")}' -Force`,
], { cwd: ROOT, stdio: "inherit" });

const copyTree = (from, to) => {
  fs.mkdirSync(to, { recursive: true });
  for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
    const src = path.join(from, entry.name);
    const dst = path.join(to, entry.name);
    if (entry.isDirectory()) copyTree(src, dst);
    else fs.copyFileSync(src, dst);
  }
};
copyTree(path.join(HUB, "common"), path.join(STAGING, "common"));
copyTree(path.join(HUB, "plugins"), path.join(STAGING, "plugins"));

// --- ModuleConfig: reuse the hub's generated steps, add core as required ----------
// The patch steps are NOT re-rendered here. They come from the hub's generated XML, so
// the option list, grouping and paging have exactly one source (the PatchHub manifest)
// and this tool cannot drift from it.
const hubXml = fs.readFileSync(path.join(HUB, "fomod", "ModuleConfig.xml"), "utf8").replace(/\r\n/g, "\n");
const stepsMatch = hubXml.match(/<installSteps[\s\S]*<\/installSteps>/);
if (!stepsMatch) throw new Error("Could not find <installSteps> in the patch hub ModuleConfig.xml");

const combinedXml = `<?xml version="1.0" encoding="utf-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>Devotion</moduleName>
  <requiredInstallFiles>
    <folder source="core" destination="" priority="0" />
  </requiredInstallFiles>
${stepsMatch[0].split("\n").map((line) => (line ? `  ${line}` : line)).join("\n")}
</config>
`;
fs.writeFileSync(path.join(STAGING, "fomod", "ModuleConfig.xml"), combinedXml, "utf8");

const infoXml = `<?xml version="1.0" encoding="utf-8"?>
<fomod>
  <Name>Devotion</Name>
  <Author>Devotion (PDV)</Author>
  <Version MachineVersion="${proof.archive.match(/(\d+\.\d+\.\d+)/)?.[1] ?? "1.0.0"}.0">${proof.archive.replace(/^Devotion-/, "").replace(/\.zip$/, "")}</Version>
  <Website>https://www.nexusmods.com/skyrimspecialedition/</Website>
  <Description>
    Devotion, plus optional per-mod patches that teach it how the gods react to other
    mods' content.

    The core mod installs automatically and cannot be deselected. Every patch below is
    optional and is gated on its own source plugin, so an option you cannot use is not
    offered. A patch you install for a mod you later remove goes inert rather than
    breaking - its quest simply resolves to nothing.

    Proof state: records, scripts, packaging and matrix channels are machine-verified.
    In-game runtime and player-surface proof remain pending for the patch options.
  </Description>
  <Groups>
    <element>Gameplay</element>
    <element>Patches</element>
    <element>Quests and Adventures</element>
  </Groups>
</fomod>
`;
fs.writeFileSync(path.join(STAGING, "fomod", "info.xml"), infoXml, "utf8");

// --- verify the staged tree before zipping ---------------------------------------
const countFiles = (dir) => {
  let n = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    n += entry.isDirectory() ? countFiles(path.join(dir, entry.name)) : 1;
  }
  return n;
};
const coreFiles = countFiles(path.join(STAGING, "core"));
if (coreFiles !== proof.entryCount) {
  throw new Error(`Staged core has ${coreFiles} files; the core archive receipt says ${proof.entryCount}.`);
}
// Every folder the installer references must exist in the staged tree, or an option
// installs nothing and the player is never told.
for (const ref of [...combinedXml.matchAll(/source="([^"]+)"/g)].map((m) => m[1])) {
  const resolved = path.join(STAGING, ref.replaceAll("\\", path.sep));
  if (!fs.existsSync(resolved)) throw new Error(`ModuleConfig references a folder missing from the staged tree: ${ref}`);
}

// --- zip -------------------------------------------------------------------------
fs.mkdirSync(path.dirname(output), { recursive: true });
execFileSync("powershell", [
  "-NoProfile", "-Command",
  `$ErrorActionPreference='Stop'; Compress-Archive -LiteralPath (Get-ChildItem -LiteralPath '${STAGING.replaceAll("'", "''")}' | ForEach-Object {$_.FullName}) -DestinationPath '${output.replaceAll("'", "''")}' -CompressionLevel Optimal`,
], { cwd: ROOT, stdio: "inherit" });

if (!process.argv.includes("--keep-staging")) fs.rmSync(STAGING, { recursive: true, force: true });

const archiveSha = crypto.createHash("sha256").update(fs.readFileSync(output)).digest("hex").toUpperCase();
const patchOptions = (combinedXml.match(/<plugin name=/g) ?? []).length;
const receipt = {
  schemaVersion: 1,
  archive: path.basename(output),
  sha256: archiveSha,
  sizeBytes: fs.statSync(output).size,
  core: { archive: proof.archive, sha256: proof.sha256, entryCount: proof.entryCount, installedVia: "requiredInstallFiles" },
  patchOptions,
  proofBoundary: {
    staticAndPackaging: "passed",
    coreReleaseGates: "inherited from the core archive receipt",
    runtimeAndManual: "not-claimed-by-packager",
  },
};
fs.writeFileSync(`${output}.proof.json`, `${JSON.stringify(receipt, null, 2)}\n`, "utf8");

console.log(JSON.stringify({ status: "PASS", ...receipt }, null, 2));
