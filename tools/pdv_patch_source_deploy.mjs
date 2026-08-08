#!/usr/bin/env node
// patch-source/ is the source of truth for patch-only Papyrus. This deploys it into the
// FOMOD tree and gates that the tree matches.
//
// WHY (issue #41). Ten .psc files existed ONLY under dist/PDV_QuestModPatches_FOMOD/ - not in
// live-source/, not in the live MO2 build. For that class the build output WAS the source:
// pdv_compile.mjs could not see them (neither DEVOTION_SOURCE nor TRACKED_SOURCE covers
// them), the FOMOD generator writes only the manifest and ModuleConfig.xml and never copied a
// script, and a dist/ wipe would have lost them permanently.
//
// They are NOT folded into live-source/ on purpose. pdv_arr25_nonquest_check asserts AFDI
// stays out of core, and the AFDI observer is an opt-in patch - putting patch code in the
// core build would be a different and worse bug.
//
// THE DISTRIBUTION IS STILL ONE FOMOD. patch-source/ is a SOURCE tree and never a second
// shipped lane. Everything continues to ship inside the single core-plus-patches installer;
// splitting core from patches is what produced the JoJ silent-underdelivery failure, and
// nothing here may reintroduce it.
//
// PDV_AFDIObserver ships at TWO paths - common/AFDI/ and plugins/individual/AFDI/ - because
// the two FOMOD options install different folder sets. Those copies were byte-identical and
// kept so BY HAND, which is the "one data item, one persistence backend" rule broken and a
// guaranteed future drift. They are now PRODUCED from one source.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { hashText, hashBytes, sameText, sameBytes } from "./lib/pdv_file_compare.mjs";

// Inline so this change stays independent of the shared tools/lib/pdv_cli.mjs guard landing;
// it should be migrated to that helper once both are on main.
const KNOWN_FLAGS = new Set(["--check", "--write", "--relock"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    console.error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
    process.exit(2);
  }
}
const CHECK = process.argv.includes("--check");
const RELOCK = process.argv.includes("--relock");
const WRITE = process.argv.includes("--write");

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SRC = path.join(REPO, "patch-source");
const HUB = path.join(REPO, "dist", "PDV_QuestModPatches_FOMOD");

// source subtree -> every destination it deploys to. A one-to-many entry is how the AFDI
// duplication becomes a build product instead of a hand-sync chore.
const DEPLOY = [
  { from: "AFDI", to: ["common/AFDI", "plugins/individual/AFDI"] },
  { from: "_Fragments/WarsFolly", to: ["common/_Fragments/WarsFolly"] },
  { from: "_Fragments/OnceWeWereHere", to: ["common/_Fragments/OnceWeWereHere"] },
  { from: "_Fragments/WhispersOfTheDepths", to: ["common/_Fragments/WhispersOfTheDepths"] },
];

const walk = (root) => {
  const out = [];
  const rec = (dir, rel) => {
    if (!fs.existsSync(dir)) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const r = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory()) rec(path.join(dir, e.name), r);
      else out.push(r);
    }
  };
  rec(root, "");
  return out.sort();
};

// FRESHNESS, and why it is not an mtime comparison.
//
// "Is the .psc newer than the .pex" is the obvious check and it is WRONG here, because git
// does not preserve mtimes. A fresh clone gets checkout-order timestamps, so an mtime gate
// reports stale bytecode on a tree nobody has touched - it did exactly that during this
// change, when git mv reset four files. A gate that cries wolf on a clean clone gets
// disabled, which leaves the real thing unguarded.
//
// So the signal is a committed lock: the sha256 of each .psc as of the last compile. Edit a
// .psc without recompiling and its hash stops matching, on every machine, forever, regardless
// of timestamps. Re-locking is an explicit act (--relock) that means "I have recompiled",
// which is the claim being made.
//
// The old arr25 check tested the .pex for size > 0, so a stale pairing passed. This is the
// replacement.
const LOCK = path.join(SRC, "PDV_PatchSource.lock.json");

// Hash TEXT by content and BINARY by bytes - see tools/lib/pdv_file_compare.mjs for why the
// distinction is the whole point. A .psc is normalised, so the lock is independent of how it
// was checked out; a .pex is bytecode where every byte is the claim, and .gitattributes marks
// it binary so git never translates it.
const sha = (p, { text = false } = {}) => (text ? hashText(p) : hashBytes(p));

function currentHashes() {
  const out = {};
  for (const psc of walk(SRC).filter((f) => f.endsWith(".psc"))) {
    const base = path.basename(psc, ".psc");
    const pexRel = path.join(path.dirname(path.dirname(psc)), `${base}.pex`).replaceAll("\\", "/");
    const pexAbs = path.join(SRC, pexRel);
    out[psc] = { psc: sha(path.join(SRC, psc), { text: true }), pex: fs.existsSync(pexAbs) ? sha(pexAbs) : null, pexPath: pexRel };
  }
  return out;
}

function freshnessProblems(hashes, lock) {
  const problems = [];
  for (const [rel, cur] of Object.entries(hashes)) {
    const base = path.basename(rel, ".psc");
    if (!cur.pex) { problems.push(`${base}: no compiled .pex beside it (expected ${cur.pexPath})`); continue; }
    const locked = lock?.scripts?.[rel];
    if (!locked) { problems.push(`${base}: not in the lock - run --relock after compiling`); continue; }
    if (locked.psc !== cur.psc) problems.push(`${base}: .psc changed since the last compile - recompile, then --relock`);
    else if (locked.pex !== cur.pex) problems.push(`${base}: .pex changed but .psc did not - relock to accept, or restore the bytecode`);
  }
  return problems;
}

const hashes = currentHashes();
const lock = fs.existsSync(LOCK) ? JSON.parse(fs.readFileSync(LOCK, "utf8")) : null;

if (RELOCK) {
  const missing = Object.entries(hashes).filter(([, v]) => !v.pex).map(([k]) => k);
  if (missing.length) {
    console.error(JSON.stringify({ status: "FAIL", reason: "cannot lock a script with no .pex", missing }, null, 2));
    process.exit(1);
  }
  fs.writeFileSync(LOCK, `${JSON.stringify({
    schema: "pdv.patch-source.lock.v1",
    note: "sha256 of each patch-only .psc as of its last compile, and of the .pex built from it. Timestamps are not used: git does not preserve mtimes, so an mtime check reports stale bytecode on a clean clone.",
    scripts: Object.fromEntries(Object.entries(hashes).map(([k, v]) => [k, { psc: v.psc, pex: v.pex }])),
  }, null, 2)}\n`, "utf8");
  console.log(JSON.stringify({ status: "PASS", relocked: Object.keys(hashes).length }, null, 2));
  process.exit(0);
}

const stale = lock === null
  ? ["no patch-source lock file - run: node tools/pdv_patch_source_deploy.mjs --relock"]
  : freshnessProblems(hashes, lock);

const planned = [];
for (const { from, to } of DEPLOY) {
  const files = walk(path.join(SRC, from));
  if (!files.length) { planned.push({ error: `patch-source/${from} has no files` }); continue; }
  for (const dest of to) for (const f of files) {
    planned.push({ src: path.join(SRC, from, f), dst: path.join(HUB, dest.replaceAll("/", path.sep), f.replaceAll("/", path.sep)), rel: `${dest}/${f}` });
  }
}
const errors = planned.filter((p) => p.error).map((p) => p.error);
const jobs = planned.filter((p) => !p.error);
// .psc by content, .pex by bytes. A working copy whose line endings came out CRLF is not
// drift, it is a checkout.
const drift = jobs.filter((j) => (j.src.endsWith(".psc") ? !sameText(j.src, j.dst) : !sameBytes(j.src, j.dst)));

if (CHECK) {
  const ok = !errors.length && !stale.length && !drift.length;
  const payload = {
    status: ok ? "PASS" : "FAIL",
    sourceFiles: jobs.length,
    ...(errors.length ? { errors } : {}),
    ...(stale.length ? { staleBytecode: stale } : {}),
    ...(drift.length ? { outOfSync: drift.map((d) => d.rel), fix: "node tools/pdv_patch_source_deploy.mjs --write" } : {}),
  };
  console[ok ? "log" : "error"](JSON.stringify(payload, null, 2));
  process.exit(ok ? 0 : 1);
}

if (errors.length || stale.length) {
  console.error(JSON.stringify({ status: "FAIL", errors, staleBytecode: stale }, null, 2));
  process.exit(1);
}

if (!WRITE) {
  console.log(JSON.stringify({
    status: drift.length ? "OUT-OF-SYNC" : "PASS",
    mode: "report-only (nothing written)",
    sourceFiles: jobs.length,
    wouldWrite: drift.map((d) => d.rel),
    fix: drift.length ? "node tools/pdv_patch_source_deploy.mjs --write" : null,
  }, null, 2));
  process.exit(0);
}

for (const j of drift) {
  fs.mkdirSync(path.dirname(j.dst), { recursive: true });
  fs.copyFileSync(j.src, j.dst);
}
console.log(JSON.stringify({ status: "PASS", deployed: drift.length, of: jobs.length, targets: DEPLOY.flatMap((d) => d.to) }, null, 2));
