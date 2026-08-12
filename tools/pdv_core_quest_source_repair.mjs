#!/usr/bin/env node
/** Apply reviewed removals to historical core quest tranche sources. */

import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function parseCsvLine(line) {
  const out = [];
  let field = "", quoted = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (quoted) {
      if (ch === '"' && line[i + 1] === '"') { field += '"'; i++; }
      else if (ch === '"') quoted = false;
      else field += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ",") { out.push(field); field = ""; }
    else field += ch;
  }
  out.push(field);
  return out;
}

function matches(row, selector) {
  return Object.entries(selector).every(([key, value]) => String(row[key] ?? "") === String(value));
}

function main() {
  const argv = process.argv.slice(2);
  const write = argv.includes("--write");
  const manifestFlag = argv.indexOf("--manifest");
  if (argv.some((arg, index) => !["--write", "--manifest"].includes(arg) && index !== manifestFlag + 1)) {
    throw new Error("Use --manifest <path> [--write]");
  }
  if (manifestFlag < 0 || !argv[manifestFlag + 1]) throw new Error("Use --manifest <path> [--write]");
  const manifest = JSON.parse(readFileSync(path.resolve(ROOT, argv[manifestFlag + 1]), "utf8"));
  if (manifest.schema !== "pdv-core-quest-source-repairs-v1") throw new Error("Manifest schema drift");

  let removed = 0;
  for (const entry of manifest.files) {
    const file = path.resolve(ROOT, entry.path);
    const original = readFileSync(file, "utf8");
    const hadCrLf = original.includes("\r\n");
    const lines = original.split(/\r?\n/);
    const trailing = lines.at(-1) === "";
    if (trailing) lines.pop();
    const header = parseCsvLine(lines[0]);
    let body = lines.slice(1);

    for (const operation of entry.remove ?? []) {
      const hits = [];
      for (let i = 0; i < body.length; i++) {
        const cells = parseCsvLine(body[i]);
        const row = Object.fromEntries(header.map((key, index) => [key, cells[index] ?? ""]));
        if (matches(row, operation.selector)) hits.push(i);
      }
      if (!write) {
        if (hits.length) throw new Error(`${entry.path}: ${hits.length} reviewed-removed row(s) remain for ${JSON.stringify(operation.selector)}`);
        continue;
      }
      if (hits.length !== 0 && hits.length !== operation.expected_before) {
        throw new Error(`${entry.path}: expected ${operation.expected_before} pre-repair row(s), found ${hits.length}`);
      }
      const hitSet = new Set(hits);
      body = body.filter((_, index) => !hitSet.has(index));
      removed += hits.length;
    }

    if (write) {
      const eol = hadCrLf ? "\r\n" : "\n";
      writeFileSync(file, [lines[0], ...body].join(eol) + (trailing ? eol : ""), "utf8");
    }
  }
  console.log(`PASS pdv_core_quest_source_repair mode=${write ? "write" : "check"} removed=${removed}`);
}

try { main(); } catch (error) { console.error(`FAIL: ${error.message}`); process.exit(1); }
