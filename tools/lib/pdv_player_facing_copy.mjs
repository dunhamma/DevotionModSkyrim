// Shared definition of "development status must never reach a player".
//
// OWNER RULING 2026-08-08. The trigger: the quest-patch FOMOD shipped
// "Machine-verified; runtime evidence remains open." appended to 34 of its 46 option
// descriptions, and it reached a real install. A player-facing surface carries the mod
// name and a short plain description of what the thing does. Proof state belongs in
// AGENTS.md, commit messages, PR bodies and the gates -- never in the shipped artifact.
//
// This module is the SINGLE definition. tools/pdv_quest_patch_fomod_generate.mjs (build
// time), tools/pdv_quest_patch_fomod_validate.mjs (shipped artifact) and
// tools/pdv_player_facing_copy_gate.mjs (every surface) all import from here, so the
// pattern cannot drift between them.

import fs from "node:fs";
import path from "node:path";

export const DEV_STATUS_PATTERN =
  /machine[- ]verified|runtime evidence|evidence remains? open|evidence remain open|runtime[- ]verify|proof[- ]pending|proof state|proof boundary|readback|read back from disk|compiler check|unverified|smoke gate|gate exit|exit code/i;

export function findDevStatus(value) {
  return String(value ?? "").match(DEV_STATUS_PATTERN)?.[0] ?? null;
}

export function assertNoDevStatus(label, value) {
  const hit = findDevStatus(value);
  if (hit) {
    throw new Error(
      `Player-facing text carries development status: ${label} contains "${hit}".\n` +
      `  Player-facing surfaces carry the mod name and a short plain description of what\n` +
      `  the thing does, nothing else. Proof state belongs in AGENTS.md and the gates.\n` +
      `  Offending text: ${value}`
    );
  }
}

export function filesUnder(root, filter = () => true) {
  const out = [];
  if (!fs.existsSync(root)) return out;
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const full = path.join(root, entry.name);
    if (entry.isDirectory()) out.push(...filesUnder(full, filter));
    else if (entry.isFile() && filter(full)) out.push(full);
  }
  return out;
}

// Every surface that reaches a player: the installer they read while choosing options, the
// files that land in their mod folder, and the mod page they read before downloading.
//
// NOT listed, deliberately: AGENTS.md and references/ (internal), tools/ (internal),
// *.pdb (excluded from the release package by pdv_package_release.mjs), and Debug.Trace
// output (a log file, not a surface).
export function shippedSurfaces(repoRoot) {
  const at = (...parts) => path.join(repoRoot, ...parts);
  const md = (f) => /\.md$/i.test(f);
  const web = (f) => /\.(html?|js|css)$/i.test(f);
  const txt = (f) => /\.txt$/i.test(f);
  const surfaces = [];

  const pushFile = (label, file) => { if (fs.existsSync(file)) surfaces.push({ label, file }); };
  const pushDir = (label, dir, filter) =>
    filesUnder(dir, filter).forEach((file) => surfaces.push({ label, file }));

  // The quest-patch installer: option list AND the header/description page.
  pushFile("patchhub installer", at("dist/PDV_QuestModPatches_FOMOD/fomod/ModuleConfig.xml"));
  pushFile("patchhub installer info", at("dist/PDV_QuestModPatches_FOMOD/fomod/info.xml"));
  // EVERY .md/.txt anywhere in the FOMOD tree, not just common/*/Docs/. Scoping this to
  // Docs/ once let README-ARR25-EXPERIMENTAL.md at the package root ship with
  // "machine-verified experimental" in it -- the gate passed and the ZIP was still dirty.
  // Anything inside this tree gets installed, so anything inside it is player-facing.
  pushDir("patchhub shipped text", at("dist/PDV_QuestModPatches_FOMOD"),
    (f) => (md(f) || txt(f)));
  // Core release text.
  pushDir("release meta", at("dist/release-meta"), (f) => txt(f) || md(f));
  pushFile("credits", at("Credits.txt"));
  // Config-folder readmes ship inside SKSE data.
  pushDir("shipped SKSE readme", at("SKSE/Plugins/StorageUtilData/PlayerDevotion"), txt);
  // The Nexus mod page and player guides.
  pushDir("player guide", at("docs/player-guides"), md);
  // The in-game dashboard.
  pushDir("PrismaUI view", at("native/DevotionPrismaBridge/mod/PrismaUI"), web);

  return surfaces;
}

// Papyrus is ADVISORY, not a hard failure, and the reason matters: the MCM debug pages
// legitimately say "proof" to a tester, and they reach the screen through the same
// Debug.Notification/MessageBox calls as real player text. The enclosing function name does
// not distinguish them either -- two of the three known cases sit in OnOptionSelect and
// RunPatternAction, not in anything called Debug*. So these are reported for a human to
// adjudicate rather than failed automatically. Do not "fix" this by banning the vocabulary
// outright; that would gut the debug harness.
// Deliberately BROADER than DEV_STATUS_PATTERN: bare "proof", "seed", "verified" are far
// too false-positive-prone to ever hard-fail on, but they are exactly the words a debug
// string uses, so an advisory list that missed them would be useless. Advisory only.
export const PAPYRUS_ADVISORY_PATTERN =
  /\bproof\b|\bverified\b|\breadback\b|\bsmoke\b|\bgate\b|\bassert\b|\bdebug seed\b|\bharness\b/i;

export function papyrusPlayerFacingAdvisories(repoRoot) {
  const out = [];
  const dir = path.join(repoRoot, "live-source/Scripts/Source");
  for (const file of filesUnder(dir, (f) => /\.psc$/i.test(f))) {
    const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
    lines.forEach((line, index) => {
      if (!/(Debug\.Notification|Debug\.MessageBox|\bMessageBox)\s*\(/.test(line)) return;
      const hit = findDevStatus(line) ?? line.match(PAPYRUS_ADVISORY_PATTERN)?.[0];
      if (hit) out.push({ file: path.relative(repoRoot, file).replaceAll("\\", "/"), line: index + 1, hit, text: line.trim().slice(0, 160) });
    });
  }
  return out;
}
