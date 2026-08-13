#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

import { sameTextToString, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

// Refuse unrecognised flags. These tools read argv with includes()/indexOf(), so an
// unknown or mistyped flag would otherwise fall through to a default and the run would
// SUCCEED against something the caller never asked for. Matches the pdv_arr25_* convention.
const KNOWN_FLAGS = new Set(["--write", "--import-legacy", "--normalize-manifest"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}


const ROOT = "dist/PDV_QuestModPatches_FOMOD";
const XML = path.join(ROOT, "fomod/ModuleConfig.xml");
const MANIFEST = "references/authoring/PDV_QuestPatchHub.manifest.json";
const RETIRED_OPTIONS = new Set([
  "Creation Club - The Cause (T13 experimental)",
  "Creation Club - Ghosts of the Tribunal (T13 experimental)",
  "Creation Club - Divine Crusader (T13 experimental)",
]);
const NEW_OPTIONS = [
  ["DAc0da", "DAc0da", "DAc0da.esm", "Data-only reactions for the two directly evidenced DAc0da resolutions."],
  ["Ebony Blade Curse", "EbonyBladeCurse", "EbonyBladeCurse.esp", "Data-only reaction for breaking the Ebony Blade curse."],
  ["The Forgotten City", "ForgottenCity", "ForgottenCity.esp", "Data-only reactions for the directly evidenced Forgotten City resolutions."],
  ["Glenmoril", "Glenmoril", "Glenmoril.esm", "Data-only reactions for the directly evidenced Glenmoril resolutions."],
  ["Olenveld", "Olenveld", "Olenveld.esp", "Data-only reaction for the directly evidenced Olenveld resolution."],
  ["Skyrim Extended Cut - Saints and Seducers", "SkyrimExtendedCutSaintsAndSeducers", "Skyrim Extended Cut - Saints and Seducers.esp", "Data-only reaction for the directly evidenced Saints and Seducers resolution."],
  ["Unslaad", "Unslaad", "Unslaad.esm", "Data-only reactions for four directly evidenced Unslaad outcomes."],
  ["Vigilant", "Vigilant", "Vigilant.esm", "Data-only reactions for the directly evidenced Vigilant outcomes."],
];

// Player-facing installer text must never carry development or proof status. This fires at
// BUILD time, so a description like "... Machine-verified; runtime evidence remains open."
// cannot be rendered into ModuleConfig.xml at all. Owner ruling 2026-08-08, after 34 of 46
// option descriptions shipped with that sentence appended and reached a real install.
const DEV_STATUS_PATTERN =
  /machine[- ]verified|runtime evidence|evidence remains? open|evidence remain open|runtime-verify|runtime verify|proof[- ]pending|proof state|proof boundary|readback|read back from disk|compiler check|gate(?:s|d)? (?:pass|fail)|unverified/i;

function assertNoDevStatus(label, value) {
  const hit = String(value).match(DEV_STATUS_PATTERN);
  if (hit) {
    throw new Error(
      `Player-facing installer text carries development status: ${label} contains "${hit[0]}".\n` +
      `  The FOMOD is player-facing - mod name plus a short plain description of what the\n` +
      `  option does, nothing else. Proof state belongs in AGENTS.md and the gates.\n` +
      `  Offending text: ${value}`
    );
  }
}

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
  writeTextWithEol(MANIFEST, `${JSON.stringify(manifest, null, 2)}\n`, "lf");
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
    // description may be "" ON PURPOSE. Owner ruling 2026-08-08: an option's description is
    // the mod's own Nexus summary, never authored copy. DAc0da, Glenmoril and Ebony Blade
    // Curse are not on Nexus SE, so there is no summary to use and nothing is shown for
    // them. The key must still be present -- an absent one is a mistake, an empty one is a
    // decision. Do not "fix" this by writing a description.
    if (!option.name || typeof option.description !== "string" || !option.dependency || !Array.isArray(option.folders) || !option.folders.length) {
      throw new Error(`Incomplete PatchHub option: ${option.name ?? "<unnamed>"}`);
    }
    assertNoDevStatus(`option "${option.name}" name`, option.name);
    assertNoDevStatus(`option "${option.name}" description`, option.description);
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
  // The tickbox label is `plugin name`, and it is the ONLY text a player sees while
  // scanning the list - so it carries the mod name and nothing else. `description` is
  // shown in the side pane for the highlighted option, in both MO2 and Vortex.
  //
  // OWNER RULING 2026-08-08: NO development or proof status in either. The installer is
  // player-facing: it carries the mod name and a short plain description of what the
  // option does, and nothing else. Proof-boundary wording ("machine-verified; runtime
  // evidence remains open") used to be appended to every description and shipped to
  // players. It does not go here, ever. Proof state belongs in AGENTS.md and the gates.
  // assertNoDevStatus() below enforces this - do not weaken it to let a build through.
  //
  // Options are grouped by category and split across pages so 46 tickboxes are not one
  // undifferentiated wall. `installStep` = page, `group` = heading within it.
  const PAGES = [
    { name: "Quests and Adventures", groups: ["New Quests and Lands", "Quest Expansions"] },
    { name: "Followers, Bards and Systems", groups: ["Followers", "Bardic Life", "World Systems and Collections"] },
  ];
  const known = new Set(PAGES.flatMap((page) => page.groups));
  for (const option of manifest.options) {
    if (!option.category) throw new Error(`PatchHub option has no category: ${option.name}`);
    if (!known.has(option.category)) throw new Error(`Unknown PatchHub category "${option.category}" on: ${option.name}`);
  }

  const steps = PAGES.map((page) => {
    const groups = page.groups
      .map((groupName) => {
        const inGroup = manifest.options.filter((option) => option.category === groupName);
        if (!inGroup.length) return null;
        return `        <group name="${xmlEscape(groupName)}" type="SelectAny">
          <plugins order="Explicit">
${inGroup.map(renderOption).join("\n")}
          </plugins>
        </group>`;
      })
      .filter(Boolean)
      .join("\n");
    return `    <installStep name="${xmlEscape(page.name)}">
      <optionalFileGroups order="Explicit">
${groups}
      </optionalFileGroups>
    </installStep>`;
  }).join("\n");

  const xml = `<?xml version="1.0" encoding="utf-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>${xmlEscape(manifest.moduleName)}</moduleName>
  <installSteps order="Explicit">
${steps}
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
  writeTextWithEol(MANIFEST, `${JSON.stringify(manifest, null, 2)}\n`, "lf");
}
const rendered = render();
if (process.argv.includes("--write") || process.argv.includes("--import-legacy") || process.argv.includes("--normalize-manifest")) {
  writeTextWithEol(XML, rendered, "lf");
} else {
  if (!sameTextToString(XML, rendered)) throw new Error("ModuleConfig.xml drifted from the PatchHub manifest; run with --write");
}

console.log(JSON.stringify({ status: "PASS", mode: process.argv.includes("--import-legacy") ? "import" : process.argv.includes("--normalize-manifest") ? "normalize" : process.argv.includes("--write") ? "write" : "check" }, null, 2));
