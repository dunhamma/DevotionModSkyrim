#!/usr/bin/env node
// CHANGELOG.md is the ONE changelog. This writes the packaged copy from it.
//
// WHY. There were two hand-maintained changelogs and nothing compared them, so they drifted
// for at least three releases in OPPOSITE directions: the repo copy carried 1.0.4 and was
// missing 1.0.2 and 2026-07-17, while dist/release-meta/CHANGELOG.txt carried those and was
// missing 1.0.4. release-meta is the one that SHIPS - pdv_package_release.mjs stages it into
// the core payload as CHANGELOG.txt - so the 1.5.0 tester build went out with a changelog
// whose newest entry was 1.0.2, two releases behind the thing it was packaged with. Nobody
// noticed because no gate existed to notice.
//
// Same shape as PDV_QuestReactionMatrix_Full.csv: generated, committed (the packager needs
// it on disk), and gated with --check so drift turns a gate red instead of shipping.
//
// Their prose had also diverged, not just their coverage. The shipped 1.0.1 dropped a code
// identifier and an internal progress note that the repo copy still carried - a manual
// player-copy polish that never came back upstream. That polish is now IN CHANGELOG.md and
// the copy is verbatim, so the better wording is the only wording. If a future entry needs
// to read differently for players, fix it in CHANGELOG.md; do not fork the file again.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { findDevStatus } from "./lib/pdv_player_facing_copy.mjs";
import { readTextNormalised, sameText, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const KNOWN_FLAGS = new Set(["--check", "--write"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    console.error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
    process.exit(2);
  }
}
// Report-only unless told otherwise, same convention as the Daedric contract generator: a
// tool that writes a tracked file on a bare run is one mistyped command away from a silent
// edit. --check is the gate; --write is the intent.
const CHECK = process.argv.includes("--check");
const WRITE = process.argv.includes("--write");

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE = path.join(REPO, "CHANGELOG.md");
const PACKAGED = path.join(REPO, "dist", "release-meta", "CHANGELOG.txt");

const source = fs.readFileSync(SOURCE, "utf8");

// This file ships to players, so the same scan the FOMOD packager runs applies here - catch
// it at the source rather than at package time, where it is far too late.
const devHits = source
  .split(/\r?\n/)
  .map((line, i) => ({ line: i + 1, hit: findDevStatus(line), text: line.trim() }))
  .filter((x) => x.hit);
if (devHits.length) {
  console.error(JSON.stringify({
    status: "FAIL",
    reason: "development status language in CHANGELOG.md, which ships to players",
    hits: devHits.slice(0, 10),
  }, null, 2));
  process.exit(1);
}

const headings = [...source.matchAll(/^## (.+)$/gm)].map((m) => m[1].trim());
const packaged = fs.existsSync(PACKAGED) ? readTextNormalised(PACKAGED) : null;

// Compared as TEXT, not bytes, and the difference is load-bearing here. The two files are
// treated DIFFERENTLY by git: dist/release-meta/CHANGELOG.txt carries an explicit `-text`
// rule so it is stored and checked out verbatim (CRLF), while CHANGELOG.md has no rule and
// follows core.autocrlf. On a machine with autocrlf=true both land CRLF and a raw comparison
// passes by luck; with autocrlf=false or input the .md checks out LF, the .txt stays CRLF,
// and a raw comparison fails on a tree nobody has touched.
const inSync = packaged !== null && sameText(SOURCE, PACKAGED);

if (CHECK) {
  if (inSync) {
    console.log(JSON.stringify({ status: "PASS", source: "CHANGELOG.md", packaged: "dist/release-meta/CHANGELOG.txt", sections: headings.length }, null, 2));
    process.exit(0);
  }
  const packagedHeadings = packaged ? [...packaged.matchAll(/^## (.+)$/gm)].map((m) => m[1].trim()) : [];
  console.error(JSON.stringify({
    status: "FAIL",
    reason: packaged === null
      ? "packaged changelog is missing"
      : "packaged changelog does not match CHANGELOG.md",
    fix: "node tools/pdv_changelog_sync.mjs --write",
    onlyInSource: headings.filter((h) => !packagedHeadings.includes(h)),
    onlyInPackaged: packagedHeadings.filter((h) => !headings.includes(h)),
  }, null, 2));
  process.exit(1);
}

if (!WRITE) {
  console.log(JSON.stringify({
    status: inSync ? "PASS" : "OUT-OF-SYNC",
    mode: "report-only (nothing written)",
    fix: inSync ? null : "node tools/pdv_changelog_sync.mjs --write",
    sections: headings.length,
    newest: headings[0] ?? "(none)",
  }, null, 2));
  process.exit(0);
}

// Write CRLF explicitly rather than echoing whatever the source happened to check out as.
// The packaged file is `-text` in .gitattributes, so git stores exactly these bytes and does
// not normalise them - which means a generator that echoed its input would commit LF from a
// Linux checkout and CRLF from a Windows one, turning "regenerate" into a diff for the next
// person on a different OS. CRLF is the committed form and the form that ships to players.
fs.mkdirSync(path.dirname(PACKAGED), { recursive: true });
writeTextWithEol(PACKAGED, source, "crlf");
console.log(JSON.stringify({
  status: "PASS",
  wrote: "dist/release-meta/CHANGELOG.txt",
  from: "CHANGELOG.md",
  sections: headings.length,
  newest: headings[0] ?? "(none)",
}, null, 2));
