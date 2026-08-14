import fs from "node:fs";
import path from "node:path";

import { hashBytes, hashText, writeTextWithEol } from "./pdv_file_compare.mjs";

const normalize = (value) => String(value).replaceAll("\\", "/");

function compiledRelativePath(pscRelative) {
  const base = path.basename(pscRelative, ".psc");
  return normalize(path.join(path.dirname(path.dirname(pscRelative)), `${base}.pex`));
}

function listFiles(root, relative = "") {
  const files = [];
  for (const entry of fs.readdirSync(path.join(root, relative), { withFileTypes: true }).sort((left, right) => left.name.localeCompare(right.name, "en"))) {
    const child = relative ? path.join(relative, entry.name) : entry.name;
    if (entry.isDirectory()) files.push(...listFiles(root, child));
    else if (entry.isFile()) files.push(normalize(child));
  }
  return files;
}

export function snapshotPatchSource(sourceRoot) {
  const scripts = {};
  for (const pscRelative of listFiles(sourceRoot).filter((relativePath) => relativePath.toLowerCase().endsWith(".psc"))) {
    const pexRelative = compiledRelativePath(pscRelative);
    const pscPath = path.join(sourceRoot, pscRelative);
    const pexPath = path.join(sourceRoot, pexRelative);
    if (!fs.existsSync(pexPath)) throw new Error(`Patch source has no compiled bytecode: ${pexRelative}.`);
    scripts[pscRelative] = { psc: hashText(pscPath), pex: hashBytes(pexPath) };
  }
  return scripts;
}

export function validatePatchSourceLock(sourceRoot) {
  const lockPath = path.join(sourceRoot, "PDV_PatchSource.lock.json");
  if (!fs.existsSync(lockPath)) throw new Error("Patch-source lock is missing.");
  const lock = JSON.parse(fs.readFileSync(lockPath, "utf8").replace(/^\uFEFF/, ""));
  if (lock.schema !== "pdv.patch-source.lock.v1" || !lock.scripts || typeof lock.scripts !== "object") {
    throw new Error("Patch-source lock schema is invalid.");
  }
  const current = snapshotPatchSource(sourceRoot);
  const lockedFiles = Object.keys(lock.scripts).map(normalize).sort((left, right) => left.localeCompare(right, "en"));
  const currentFiles = Object.keys(current).sort((left, right) => left.localeCompare(right, "en"));
  if (JSON.stringify(lockedFiles) !== JSON.stringify(currentFiles)) {
    throw new Error(`Patch-source lock membership drifted. Locked=${lockedFiles.length}; source=${currentFiles.length}.`);
  }
  for (const relativePath of currentFiles) {
    if (lock.scripts[relativePath].psc !== current[relativePath].psc) throw new Error(`Patch source changed since compilation: ${relativePath}.`);
    if (lock.scripts[relativePath].pex !== current[relativePath].pex) throw new Error(`Patch bytecode changed without relocking: ${compiledRelativePath(relativePath)}.`);
  }
  return { status: "PASS", scripts: currentFiles.length };
}

export function writePatchSourceLock(sourceRoot) {
  const scripts = snapshotPatchSource(sourceRoot);
  const lockPath = path.join(sourceRoot, "PDV_PatchSource.lock.json");
  writeTextWithEol(lockPath, `${JSON.stringify({
    schema: "pdv.patch-source.lock.v1",
    note: "sha256 of each patch-only .psc as of its last compile, and of the .pex built from it. Timestamps are not used: git does not preserve mtimes, so an mtime gate reports stale bytecode on a clean clone.",
    scripts,
  }, null, 2)}\n`, "lf");
  return { status: "PASS", relocked: Object.keys(scripts).length };
}
