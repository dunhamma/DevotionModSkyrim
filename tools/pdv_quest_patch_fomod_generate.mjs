#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const ROOT = "dist/PDV_QuestModPatches_FOMOD";
const XML = path.join(ROOT, "fomod/ModuleConfig.xml");
const MANIFEST = "references/authoring/PDV_QuestPatchHub.manifest.json";
const RETIRED_OPTIONS = new Set([
  "Creation Club - The Cause (T13 experimental)",
  "Creation Club - Ghosts of the Tribunal (T13 experimental)",
  "Creation Club - Divine Crusader (T13 experimental)",
]);
const NEW_OPTIONS = [
  ["DAc0da", "DAc0da", "DAc0da.esm", "Data-only reactions for the two directly evidenced DAc0da resolutions. Machine-verified; runtime evidence remains open."],
  ["Ebony Blade Curse", "EbonyBladeCurse", "EbonyBladeCurse.esp", "Data-only reaction for breaking the Ebony Blade curse. Machine-verified; runtime evidence remains open."],
  ["The Forgotten City", "ForgottenCity", "ForgottenCity.esp", "Data-only reactions for the directly evidenced Forgotten City resolutions. Machine-verified; runtime evidence remains open."],
  ["Glenmoril", "Glenmoril", "Glenmoril.esm", "Data-only reactions for the directly evidenced Glenmoril resolutions. Machine-verified; runtime evidence remains open."],
  ["Olenveld", "Olenveld", "Olenveld.esp", "Data-only reaction for the directly evidenced Olenveld resolution. Machine-verified; runtime evidence remains open."],
  ["Skyrim Extended Cut - Saints and Seducers", "SkyrimExtendedCutSaintsAndSeducers", "Skyrim Extended Cut - Saints and Seducers.esp", "Data-only reaction for the directly evidenced Saints and Seducers resolution. Machine-verified; runtime evidence remains open."],
  ["Unslaad", "Unslaad", "Unslaad.esm", "Data-only reactions for four directly evidenced Unslaad outcomes. Machine-verified; runtime evidence remains open."],
  ["Vigilant", "Vigilant", "Vigilant.esm", "Data-only reactions for the directly evidenced Vigilant outcomes. Machine-verified; runtime evidence remains open."],
];

function xmlEscape(value) {
  return value.replaceAll("&", "&amp;").replaceAll('"', "&quot;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

function importLegacy() {
  const xml = fs.readFileSync(XML, "utf8");
  const stepStart = xml.indexOf('<installStep name="Select Quest Mod Patches">');
  const stepEnd = xml.indexOf("</installStep>", stepStart);
  if (stepStart < 0 || stepEnd < 0) throw new Error("Legacy individual FOMOD step not found");
  const step = xml.slice(stepStart, stepEnd);
  const options = [];
  const expression = /^\s{12}<plugin name="([^"]+)">([\s\S]*?)^\s{12}<\/plugin>/gm;
  for (const match of step.matchAll(expression)) {
    const name = match[1];
    if (RETIRED_OPTIONS.has(name)) continue;
    const body = match[2];
    const description = body.match(/<description>([\s\S]*?)<\/description>/)?.[1]?.trim();
    const dependency = body.match(/<fileDependency file="([^"]+)" state="Active"\s*\/>/)?.[1];
    const folders = [...body.matchAll(/<folder source="([^"]+)" destination="" priority="0"\s*\/>/g)].map((item) => item[1]);
    if (!description || !dependency || !folders.length) throw new Error(`Cannot import complete option: ${name}`);
    options.push({ name, description, dependency, folders });
  }
  for (const [name, folder, dependency, description] of NEW_OPTIONS) {
    options.push({ name, description, dependency, folders: [`common\\${folder}`, "common\\_Runbook"] });
  }
  if (options.length !== 39) throw new Error(`Expected 39 data options after reconciliation, found ${options.length}`);
  const manifest = {
    schema: "pdv-quest-patch-hub.v1",
    updated: "2026-08-07",
    moduleName: "Devotion - Quest Mod PatchHub",
    proofBoundary: "Machine-verified experimental options; runtime, player-surface, semantic, save/load, and support proof remain separate.",
    options,
  };
  fs.writeFileSync(MANIFEST, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
}

function renderOption(option) {
  const folders = option.folders.map((folder) => `                <folder source="${xmlEscape(folder)}" destination="" priority="0" />`).join("\n");
  return `            <plugin name="${xmlEscape(option.name)}">
              <description>${xmlEscape(option.description)}</description>
              <files>
${folders}
              </files>
              <typeDescriptor>
                <dependencyType>
                  <defaultType name="NotUsable" />
                  <patterns>
                    <pattern>
                      <dependencies operator="And">
                        <fileDependency file="${xmlEscape(option.dependency)}" state="Active" />
                      </dependencies>
                      <type name="Recommended" />
                    </pattern>
                  </patterns>
                </dependencyType>
              </typeDescriptor>
            </plugin>`;
}

function render() {
  const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
  if (manifest.schema !== "pdv-quest-patch-hub.v1" || !Array.isArray(manifest.options) || !manifest.options.length) {
    throw new Error("PatchHub manifest is malformed");
  }
  const dependencySet = new Set();
  const folderSet = new Set();
  for (const option of manifest.options) {
    if (!option.name || !option.description || !option.dependency || !Array.isArray(option.folders) || !option.folders.length) {
      throw new Error(`Incomplete PatchHub option: ${option.name ?? "<unnamed>"}`);
    }
    const dependency = option.dependency.toLowerCase();
    if (dependencySet.has(dependency)) throw new Error(`Duplicate PatchHub dependency: ${option.dependency}`);
    dependencySet.add(dependency);
    for (const folder of option.folders) {
      if (!fs.existsSync(path.join(ROOT, folder.replaceAll("\\", path.sep)))) throw new Error(`Missing source folder: ${folder}`);
      if (/^common\\_Runbook$/i.test(folder)) continue;
      if (folderSet.has(folder.toLowerCase())) throw new Error(`Source folder is assigned to multiple options: ${folder}`);
      folderSet.add(folder.toLowerCase());
    }
  }
  const options = manifest.options.map(renderOption).join("\n");
  const xml = `<?xml version="1.0" encoding="utf-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>${xmlEscape(manifest.moduleName)}</moduleName>
  <installSteps order="Explicit">
    <installStep name="Select Devotion Patches">
      <optionalFileGroups order="Explicit">
        <group name="Devotion Mod Patches" type="SelectAny">
          <plugins order="Explicit">
${options}
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
</config>
`;
  return xml;
}

if (process.argv.includes("--import-legacy")) importLegacy();
if (process.argv.includes("--normalize-manifest")) {
  const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
  for (const option of manifest.options) {
    option.folders = option.folders.filter((folder) => !/^common\\_Runbook$/i.test(folder));
  }
  fs.writeFileSync(MANIFEST, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
}
const rendered = render();
if (process.argv.includes("--write") || process.argv.includes("--import-legacy") || process.argv.includes("--normalize-manifest")) {
  fs.writeFileSync(XML, rendered, "utf8");
} else {
  const before = fs.readFileSync(XML, "utf8").replace(/\r\n/g, "\n");
  if (before !== rendered) throw new Error("ModuleConfig.xml drifted from the PatchHub manifest; run with --write");
}

console.log(JSON.stringify({ status: "PASS", mode: process.argv.includes("--import-legacy") ? "import" : process.argv.includes("--normalize-manifest") ? "normalize" : process.argv.includes("--write") ? "write" : "check" }, null, 2));
