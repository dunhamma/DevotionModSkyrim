#!/usr/bin/env node
/*
  pdv_snapshot_live.mjs -- packet-boundary snapshots of the live Devotion mod.

  WHY THIS EXISTS
  The live Devotion.esp lives outside the repo (D:\Wabbajack\...\mods\Devotion) and is not
  git-tracked. Exactly one historical snapshot is in git
  (generated/live-devotion-snapshot/2026-06-15-final-polish/Devotion.esp, 2026-06-15) and the
  directory that would hold newer ones is gitignored, so it is frozen and ~7 weeks stale.
  Release zips on GitHub are recovery points at RELEASE cadence only -- opaque binary assets,
  not history you can diff or roll back per change.

  This tool gives per-packet rollback WITHOUT publishing in-development records: it writes into
  generated/live-devotion-backups/, which .gitignore:10 already excludes, on a PUBLIC repo.

  It captures .psc source as well as .pex, because the repo mirror (live-source/) and the live
  MO2 tree are two separate trees that can and do drift.

  USAGE
    node tools/pdv_snapshot_live.mjs --label P7-pre
    node tools/pdv_snapshot_live.mjs --list
    node tools/pdv_snapshot_live.mjs --verify <snapshot-dir-name>
    node tools/pdv_snapshot_live.mjs --restore <snapshot-dir-name> --confirm

  Restore takes its own auto-snapshot first, so a restore is itself reversible.
*/
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const TOOLS_DIR = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(TOOLS_DIR, "..");
const LIVE_ROOT =
  process.env.PDV_LIVE_MOD_DIR || "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion";
const STORE = path.join(ROOT, "generated", "live-devotion-backups");
const MANIFEST = "manifest.json";

// What a snapshot captures. Each entry is relative to LIVE_ROOT.
// dir entries are copied recursively, filtered by ext when given.
const TARGETS = [
  { kind: "file", rel: "Devotion.esp" },
  { kind: "dir", rel: "Scripts", ext: [".pex"], recursive: false },
  { kind: "dir", rel: path.join("Scripts", "Source"), ext: [".psc"], recursive: false },
  { kind: "dir", rel: path.join("PrismaUI", "views", "Devotion"), ext: null, recursive: true },
  { kind: "dir", rel: "Seq", ext: [".seq"], recursive: false },
];

const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const opt = (name) => {
  const i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
};
const JSON_OUT = flag("--json");
const out = [];
const say = (msg) => {
  if (!JSON_OUT) console.log(msg);
  out.push(msg);
};
const die = (msg) => {
  console.error(`ERROR: ${msg}`);
  process.exit(1);
};

const sha256 = (p) => crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const exists = (p) => fs.existsSync(p);

function stamp() {
  const d = new Date();
  const p2 = (n) => String(n).padStart(2, "0");
  return (
    `${d.getFullYear()}${p2(d.getMonth() + 1)}${p2(d.getDate())}` +
    `-${p2(d.getHours())}${p2(d.getMinutes())}${p2(d.getSeconds())}`
  );
}

function git(cmdArgs, fallback = "") {
  try {
    return execFileSync("git", cmdArgs, { cwd: ROOT, encoding: "utf8" }).trim();
  } catch {
    return fallback;
  }
}

function walk(dir, ext, recursive) {
  const found = [];
  if (!exists(dir)) return found;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (recursive) found.push(...walk(full, ext, recursive));
      continue;
    }
    if (ext && !ext.includes(path.extname(entry.name).toLowerCase())) continue;
    found.push(full);
  }
  return found;
}

function collect() {
  const files = [];
  for (const t of TARGETS) {
    const abs = path.join(LIVE_ROOT, t.rel);
    if (t.kind === "file") {
      if (exists(abs)) files.push(abs);
      continue;
    }
    files.push(...walk(abs, t.ext, t.recursive));
  }
  return files;
}

function createSnapshot(label, { auto = false } = {}) {
  if (!label) die("--label is required (e.g. --label P7-pre)");
  if (!/^[A-Za-z0-9._-]+$/.test(label)) die(`--label must be [A-Za-z0-9._-]; got "${label}"`);
  if (!exists(LIVE_ROOT)) die(`live mod dir not found: ${LIVE_ROOT}`);

  const files = collect();
  if (!files.length) die(`nothing to snapshot under ${LIVE_ROOT} -- check PDV_LIVE_MOD_DIR`);

  const name = `${label}-${stamp()}`;
  const dest = path.join(STORE, name);
  if (exists(dest)) die(`snapshot already exists: ${dest}`);
  if (flag("--dry-run")) {
    say(`[dry-run] would snapshot ${files.length} file(s) -> ${dest}`);
    return { name, dest, files: files.length, dryRun: true };
  }

  fs.mkdirSync(dest, { recursive: true });
  const entries = [];
  let bytes = 0;
  for (const src of files) {
    const rel = path.relative(LIVE_ROOT, src);
    const target = path.join(dest, rel);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(src, target);
    const size = fs.statSync(target).size;
    const digest = sha256(target);
    if (digest !== sha256(src)) die(`copy verify failed for ${rel}`);
    bytes += size;
    entries.push({ path: rel.split(path.sep).join("/"), bytes: size, sha256: digest });
  }

  const manifest = {
    label,
    name,
    auto,
    createdAt: new Date().toISOString(),
    liveRoot: LIVE_ROOT,
    git: {
      head: git(["rev-parse", "--short", "HEAD"]),
      branch: git(["rev-parse", "--abbrev-ref", "HEAD"]),
      dirty: git(["status", "--porcelain"]).length > 0,
    },
    fileCount: entries.length,
    totalBytes: bytes,
    files: entries,
  };
  fs.writeFileSync(path.join(dest, MANIFEST), `${JSON.stringify(manifest, null, 2)}\n`, "utf8");

  say(`snapshot created: ${name}`);
  say(`  ${entries.length} file(s), ${(bytes / 1024 / 1024).toFixed(2)} MB, all hashes verified`);
  say(`  ${dest}`);
  return manifest;
}

function loadManifest(name) {
  const dir = path.join(STORE, name);
  const mf = path.join(dir, MANIFEST);
  if (!exists(mf)) return null;
  try {
    return { dir, data: JSON.parse(fs.readFileSync(mf, "utf8")) };
  } catch {
    return null;
  }
}

function listSnapshots() {
  if (!exists(STORE)) {
    say("no snapshot store yet");
    return [];
  }
  const rows = [];
  for (const entry of fs.readdirSync(STORE, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const loaded = loadManifest(entry.name);
    rows.push({
      name: entry.name,
      managed: Boolean(loaded),
      createdAt: loaded?.data.createdAt ?? "(pre-tool backup, no manifest)",
      fileCount: loaded?.data.fileCount ?? null,
      head: loaded?.data.git?.head ?? "",
    });
  }
  rows.sort((a, b) => a.name.localeCompare(b.name));
  for (const r of rows) {
    const tag = r.managed ? "" : "  [unmanaged]";
    const files = r.fileCount === null ? "" : `  ${r.fileCount} file(s)`;
    const head = r.head ? `  @${r.head}` : "";
    say(`${r.name}${files}${head}${tag}`);
  }
  say(`${rows.length} snapshot(s) in ${STORE}`);
  return rows;
}

function verifySnapshot(name) {
  const loaded = loadManifest(name);
  if (!loaded) die(`no manifest for "${name}" -- unmanaged or missing`);
  let bad = 0;
  for (const f of loaded.data.files) {
    const abs = path.join(loaded.dir, f.path.split("/").join(path.sep));
    if (!exists(abs)) {
      say(`MISSING  ${f.path}`);
      bad += 1;
      continue;
    }
    if (sha256(abs) !== f.sha256) {
      say(`ALTERED  ${f.path}`);
      bad += 1;
    }
  }
  say(bad === 0 ? `verify OK: ${loaded.data.fileCount} file(s) intact` : `verify FAILED: ${bad} problem(s)`);
  if (bad > 0) process.exitCode = 1;
  return bad === 0;
}

function restoreSnapshot(name) {
  const loaded = loadManifest(name);
  if (!loaded) die(`no manifest for "${name}" -- refusing to restore an unverifiable snapshot`);
  if (!verifySnapshot(name)) die("snapshot failed verification; not restoring");

  if (!flag("--confirm")) {
    say(`[dry-run] would restore ${loaded.data.fileCount} file(s) into ${LIVE_ROOT}`);
    say("re-run with --confirm to actually restore (an auto-snapshot is taken first)");
    return false;
  }

  createSnapshot(`pre-restore-of-${loaded.data.label}`, { auto: true });

  for (const f of loaded.data.files) {
    const src = path.join(loaded.dir, f.path.split("/").join(path.sep));
    const dst = path.join(LIVE_ROOT, f.path.split("/").join(path.sep));
    fs.mkdirSync(path.dirname(dst), { recursive: true });
    fs.copyFileSync(src, dst);
    if (sha256(dst) !== f.sha256) die(`restore verify failed for ${f.path}`);
  }
  say(`restored ${loaded.data.fileCount} file(s) from ${name} into ${LIVE_ROOT}`);
  say("NOTE: restoring the ESP does not re-sync live-source/ -- check both trees agree.");
  return true;
}

// --- entry ---
if (flag("--help") || args.length === 0) {
  console.log(`Usage:
  node tools/pdv_snapshot_live.mjs --label <name>            create a snapshot
  node tools/pdv_snapshot_live.mjs --list                    list snapshots
  node tools/pdv_snapshot_live.mjs --verify <snapshot-name>  re-hash a snapshot
  node tools/pdv_snapshot_live.mjs --restore <name> --confirm  restore into the live mod dir

Options: --dry-run  --json
Env:     PDV_LIVE_MOD_DIR overrides the live mod directory
         (default ${LIVE_ROOT})

Snapshots live in generated/live-devotion-backups/, which .gitignore already excludes --
nothing here is published to the public repo.`);
  process.exit(0);
}

let result;
if (flag("--list")) result = listSnapshots();
else if (opt("--verify")) result = verifySnapshot(opt("--verify"));
else if (opt("--restore")) result = restoreSnapshot(opt("--restore"));
else result = createSnapshot(opt("--label"));

if (JSON_OUT) console.log(JSON.stringify(result, null, 2));
