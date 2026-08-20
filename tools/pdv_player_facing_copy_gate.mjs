#!/usr/bin/env node
// Gate: no development or proof status on ANY player-facing surface.
//
// Owner ruling 2026-08-08. Covers the Quest Reaction installer (option list AND the info
// page), every shipped readme, the release meta text, the Nexus/player guides, the
// PrismaUI dashboard, and the config-folder readmes that ship inside SKSE data. The
// surface list and the pattern live in tools/lib/pdv_player_facing_copy.mjs so the
// V3 package builder, release archive builder and this gate cannot drift apart.
//
// Verdict is the EXIT CODE. Papyrus findings are advisory and never change it -- see
// papyrusPlayerFacingAdvisories() for why they cannot be failed automatically.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { findDevStatus, shippedSurfaces, papyrusPlayerFacingAdvisories } from "./lib/pdv_player_facing_copy.mjs";

const KNOWN_FLAGS = new Set(["--json", "--strict-papyrus"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const strictPapyrus = process.argv.includes("--strict-papyrus");

const failures = [];
const surfaces = shippedSurfaces(REPO_ROOT);
for (const { label, file } of surfaces) {
  const text = fs.readFileSync(file, "utf8");
  text.split(/\r?\n/).forEach((line, index) => {
    const hit = findDevStatus(line);
    if (hit) {
      failures.push({
        surface: label,
        file: path.relative(REPO_ROOT, file).replaceAll("\\", "/"),
        line: index + 1,
        match: hit,
        text: line.trim().slice(0, 200),
      });
    }
  });
}

const advisories = papyrusPlayerFacingAdvisories(REPO_ROOT);
if (strictPapyrus) failures.push(...advisories.map((a) => ({ surface: "papyrus player-facing call", ...a })));

const result = {
  status: failures.length ? "FAIL" : "PASS",
  surfacesScanned: surfaces.length,
  failures,
  papyrusAdvisories: strictPapyrus ? [] : advisories,
  note: strictPapyrus
    ? "Papyrus findings were treated as failures (--strict-papyrus)."
    : "Papyrus findings are ADVISORY: MCM debug pages legitimately use this vocabulary and reach the screen through the same calls as player text. Adjudicate by hand; run with --strict-papyrus to fail on them.",
};

console.log(JSON.stringify(result, null, 2));
process.exitCode = failures.length ? 1 : 0;
