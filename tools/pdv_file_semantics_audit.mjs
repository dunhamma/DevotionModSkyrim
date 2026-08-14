#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  hashBytes,
  hashText,
  sameBytes,
  sameText,
  writeTextWithEol,
} from "./lib/pdv_file_compare.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CONTRACT = path.join(ROOT, "references", "authoring", "PDV_FileComparisonSemantics.json");
const failures = [];
const passes = [];
const pass = (message) => passes.push(message);
const fail = (message) => failures.push(message);

const contract = JSON.parse(fs.readFileSync(CONTRACT, "utf8"));
const expectedTools = new Set(contract.tools.map((entry) => entry.tool));
if (contract.tools.length === 22 && expectedTools.size === 22) pass("inventory contains twenty-two unique tools");
else fail(`inventory must contain twenty-two unique tools; got ${contract.tools.length}/${expectedTools.size}`);

for (const entry of contract.tools) {
  const toolPath = path.join(ROOT, "tools", entry.tool);
  if (!fs.existsSync(toolPath)) {
    fail(`${entry.tool}: tool is missing`);
    continue;
  }
  const source = fs.readFileSync(toolPath, "utf8");
  const helperImport = source.match(/import\s*\{([^}]*)\}\s*from\s*["']\.\/(?:lib\/)?pdv_file_compare\.mjs["']/m);
  const importedHelpers = new Set((helperImport?.[1] ?? "").split(",").map((name) => name.trim()).filter(Boolean));
  for (const helper of entry.requiredHelpers) {
    if (importedHelpers.has(helper)) pass(`${entry.tool}: imports ${helper}`);
    else fail(`${entry.tool}: required helper import ${helper} is absent`);
  }
  if (!["normalized-text", "exact-bytes", "mixed", "removed-dead-code"].includes(entry.semantics)) {
    fail(`${entry.tool}: invalid semantics ${entry.semantics}`);
  }
  if (!["none", "lf", "crlf", "binary"].includes(entry.writerEol)) {
    fail(`${entry.tool}: invalid writerEol ${entry.writerEol}`);
  }
}

const attributes = fs.readFileSync(path.join(ROOT, ".gitattributes"), "utf8").replaceAll("\r\n", "\n");
for (const rule of contract.requiredAttributes) {
  if (attributes.split("\n").includes(rule)) pass(`attribute pinned: ${rule}`);
  else fail(`missing .gitattributes rule: ${rule}`);
}

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-file-semantics-"));
try {
  const lf = path.join(tmp, "lf.txt");
  const crlf = path.join(tmp, "crlf.txt");
  fs.writeFileSync(lf, "alpha\nbeta\n", "utf8");
  fs.writeFileSync(crlf, "alpha\r\nbeta\r\n", "utf8");
  if (sameText(lf, crlf) && hashText(lf) === hashText(crlf)) pass("text helpers ignore checkout EOL shape");
  else fail("text helpers disagree on LF versus CRLF content");
  if (!sameBytes(lf, crlf) && hashBytes(lf) !== hashBytes(crlf)) pass("byte helpers preserve LF versus CRLF distinction");
  else fail("byte helpers erased a real byte difference");

  const writtenLf = path.join(tmp, "written-lf.txt");
  const writtenCrlf = path.join(tmp, "written-crlf.txt");
  writeTextWithEol(writtenLf, "alpha\r\nbeta\r\n", "lf");
  writeTextWithEol(writtenCrlf, "alpha\nbeta\n", "crlf");
  if (fs.readFileSync(writtenLf, "utf8") === "alpha\nbeta\n") pass("LF writer is host-independent");
  else fail("LF writer did not produce exact LF");
  if (fs.readFileSync(writtenCrlf, "utf8") === "alpha\r\nbeta\r\n") pass("CRLF writer is host-independent");
  else fail("CRLF writer did not produce exact CRLF");
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}

const report = {
  status: failures.length ? "FAIL" : "PASS",
  inventory: contract.tools.length,
  classifications: Object.fromEntries(["normalized-text", "exact-bytes", "mixed", "removed-dead-code"].map((kind) => [kind, contract.tools.filter((entry) => entry.semantics === kind).length])),
  passes,
  failures,
};
console.log(JSON.stringify(report, null, 2));
process.exitCode = failures.length ? 1 : 0;
