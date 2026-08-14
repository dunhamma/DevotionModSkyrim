// Comparing and hashing files in a repo, without accidentally testing the checkout.
//
// WHY THIS EXISTS. The same defect was written twice in one afternoon, both times by someone
// who knew about the first one:
//
//   1. The former patch-source deployer first gated freshness on mtimes. git does not
//      preserve mtimes, so a clean clone reported stale bytecode on ten untouched scripts.
//   2. Its replacement hashed RAW BYTES. With core.autocrlf=true the bytes of a text file
//      depend on WHEN it was checked out, so the lock (written LF) failed against every
//      fresh checkout (CRLF). Same failure, one layer down.
//   3. tools/pdv_changelog_sync.mjs compares CHANGELOG.md against the packaged .txt with
//      `a === b`. dist/release-meta/CHANGELOG.txt carries an explicit `-text` rule so git
//      stores it verbatim (CRLF), while CHANGELOG.md has no rule and follows autocrlf. On
//      this machine both land CRLF and the gate passes; with autocrlf=false or input the
//      .md checks out LF, the .txt stays CRLF, and the gate fails on an untouched tree.
//
// The lesson is not "remember to normalise". It is that a gate comparing files across a git
// checkout is answering the wrong question unless it says which question it is asking:
//
//   TEXT     - do these have the same CONTENT? Line endings are a checkout artifact.
//   BINARY   - are these the same BYTES? For bytecode, archives, and release receipts, where
//              a line-ending rewrite would be corruption and the exact bytes are the claim.
//
// Pick deliberately. Do not default.
//
// This is the second layer. The first is .gitattributes: pin the text files a gate compares,
// so the checkout is deterministic too. Neither layer alone is enough - pinning can be
// missing or inconsistent between two files being compared (defect 3 above is exactly that),
// and normalising alone leaves the working tree churning.

import fs from "node:fs";
import crypto from "node:crypto";

/** Read a text file with line endings normalised to LF. */
export function readTextNormalised(filePath) {
  return fs.readFileSync(filePath, "utf8").replaceAll("\r\n", "\n");
}

/** sha256 of a text file's CONTENT, independent of how it was checked out. */
export function hashText(filePath) {
  return crypto.createHash("sha256").update(Buffer.from(readTextNormalised(filePath), "utf8")).digest("hex");
}

/** sha256 of a file's exact BYTES. For bytecode, archives, release receipts. */
export function hashBytes(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

/** sha256 of several files' exact bytes, in the supplied order. */
export function hashByteFiles(filePaths) {
  const hash = crypto.createHash("sha256");
  for (const filePath of filePaths) hash.update(fs.readFileSync(filePath));
  return hash.digest("hex");
}

/** Same content, ignoring line endings. Missing file counts as different, never as equal. */
export function sameText(a, b) {
  if (!fs.existsSync(a) || !fs.existsSync(b)) return false;
  return readTextNormalised(a) === readTextNormalised(b);
}

/** Same normalized text as an expected in-memory generated payload. */
export function sameTextToString(filePath, expected) {
  if (!fs.existsSync(filePath) || typeof expected !== "string") return false;
  return readTextNormalised(filePath) === expected.replaceAll("\r\n", "\n");
}

/** Same exact bytes. Missing file counts as different. */
export function sameBytes(a, b) {
  if (!fs.existsSync(a) || !fs.existsSync(b)) return false;
  return fs.readFileSync(a).equals(fs.readFileSync(b));
}

/** Same exact bytes as an expected in-memory binary payload. */
export function sameBytesToBuffer(filePath, expected) {
  if (!fs.existsSync(filePath) || !Buffer.isBuffer(expected)) return false;
  return fs.readFileSync(filePath).equals(expected);
}

/**
 * Write text with a DECLARED line ending, so the result does not depend on the platform or
 * on the line endings the content happened to arrive with.
 *
 * A generator that echoes its input's line endings produces different bytes on different
 * machines. When the target is a tracked file - especially one git stores verbatim - that
 * turns "regenerate" into a diff for the next person on a different OS.
 */
export function writeTextWithEol(filePath, content, eol) {
  if (eol !== "crlf" && eol !== "lf") throw new Error(`writeTextWithEol: eol must be "crlf" or "lf", got ${eol}`);
  const lf = content.replaceAll("\r\n", "\n");
  fs.writeFileSync(filePath, eol === "crlf" ? lf.replaceAll("\n", "\r\n") : lf, "utf8");
}

/** True if the file's bytes use CRLF. Useful for keeping a generated file in its committed form. */
export function detectEol(filePath) {
  if (!fs.existsSync(filePath)) return null;
  const b = fs.readFileSync(filePath);
  return b.includes("\r\n") ? "crlf" : "lf";
}
