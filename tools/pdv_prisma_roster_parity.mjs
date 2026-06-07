#!/usr/bin/env node
// pdv_prisma_roster_parity.mjs
// Read-only parity audit between the Phase 2 all-race deity roster and the
// Prisma UI presentation layer. Closes the gap the entry-point audit
// (pdv_prisma_ui_audit.mjs) cannot see: roster glyph coverage and tier-threshold
// parity. The entry-point audit guards HOW the panel opens; this guards WHETHER
// every scored deity has a glyph and whether the panel's thresholds match the
// live 25/50/85 contract.
//
// Verdicts:
//   FAIL  - a roster deity has no GetPrismaSymbolForDeity mapping (renders the
//           generic "journal" icon in toasts), or a threshold parity break.
//   WARN  - a roster deity IS mapped but its symbol key has no symbolSpecs glyph
//           yet (Group 2 art lands via the prisma-glyphs-phase2-deities branch).
//           Escalates to FAIL under --strict (use after the glyph branch merges).
//   PASS  - mapped deity whose glyph exists; threshold parity holds.
//
// Flags: --json (machine output), --strict (missing-glyph WARN -> FAIL).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const TOOLS_DIR = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(TOOLS_DIR, "..");
const SPEC_DIR = path.join(PROJECT_ROOT, "references", "authoring");
const DEVOTION_SOURCE = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\Scripts\\Source";
const MANAGER_PATH = path.join(DEVOTION_SOURCE, "PDV__ManagerQuest.psc");
const DEITYBASE_PATH = path.join(DEVOTION_SOURCE, "PDV_DeityBase.psc");
const APP_JS_PATH = "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion\\PrismaUI\\views\\Devotion\\app.js";

const JSON_MODE = process.argv.includes("--json");
const STRICT = process.argv.includes("--strict");

const results = []; // { level: 'PASS'|'WARN'|'FAIL', message, source }
const add = (level, message, source = "") => results.push({ level, message, source });
const read = (p) => fs.readFileSync(p, "utf8");

// Form-comparison branches in GetPrismaSymbolForDeity resolve to these names.
const FORM_NAME_ALIASES = { PDV_Kyne: "Kyne", PDV_Talos: "Talos" };

// ---- 1. Collect the deity roster from the ten per-race reward specs ----
function collectDeityNames(node, out) {
  if (Array.isArray(node)) {
    for (const item of node) collectDeityNames(item, out);
  } else if (node && typeof node === "object") {
    for (const [key, value] of Object.entries(node)) {
      if (key === "deityName" && typeof value === "string" && value.trim()) {
        out.add(value.trim());
      } else {
        collectDeityNames(value, out);
      }
    }
  }
}

const roster = new Set();
let specFiles = [];
if (!fs.existsSync(SPEC_DIR)) {
  add("FAIL", "Spec directory is missing.", SPEC_DIR);
} else {
  specFiles = fs
    .readdirSync(SPEC_DIR)
    .filter((n) => /^PDV_.*RewardRecords\.spec\.json$/.test(n));
  if (specFiles.length === 0) {
    add("FAIL", "No PDV_*RewardRecords.spec.json files found.", SPEC_DIR);
  }
  for (const name of specFiles) {
    const filePath = path.join(SPEC_DIR, name);
    try {
      collectDeityNames(JSON.parse(read(filePath)), roster);
    } catch (err) {
      add("FAIL", `Could not parse ${name}: ${err.message}`, filePath);
    }
  }
}

// ---- 2. Parse GetPrismaSymbolForDeity -> name -> symbol key ----
const nameToSymbol = new Map();
if (!fs.existsSync(MANAGER_PATH)) {
  add("FAIL", "Manager source is missing.", MANAGER_PATH);
} else {
  const manager = read(MANAGER_PATH);
  const fnMatch = manager.match(/String\s+Function\s+GetPrismaSymbolForDeity\b[\s\S]*?EndFunction/i);
  if (!fnMatch) {
    add("FAIL", "GetPrismaSymbolForDeity not found in manager.", MANAGER_PATH);
  } else {
    const block = fnMatch[0];
    // Each conditional segment ends at endIf; pair its names with its return.
    for (const segment of block.split(/endIf/i)) {
      const symbolMatch = segment.match(/return\s+"([^"]+)"/);
      if (!symbolMatch) continue;
      const symbol = symbolMatch[1];
      let matched = false;
      for (const m of segment.matchAll(/deity\.DeityName\s*==\s*"([^"]+)"/g)) {
        nameToSymbol.set(m[1], symbol);
        matched = true;
      }
      for (const m of segment.matchAll(/deity\s*==\s*(PDV_\w+)/g)) {
        const alias = FORM_NAME_ALIASES[m[1]];
        if (alias) {
          nameToSymbol.set(alias, symbol);
          matched = true;
        }
      }
      // segments with no name (the trailing `return "journal"`) are ignored
      void matched;
    }
  }
}

// ---- 3. Parse available glyph keys from app.js symbolSpecs ----
const glyphKeys = new Set();
if (!fs.existsSync(APP_JS_PATH)) {
  add("FAIL", "Live Prisma UI app.js is missing.", APP_JS_PATH);
} else {
  const app = read(APP_JS_PATH);
  const specsStart = app.indexOf("const symbolSpecs = {");
  if (specsStart === -1) {
    add("FAIL", "symbolSpecs map not found in app.js.", APP_JS_PATH);
  } else {
    // Bound the block to its closing `  };` so unrelated 4-space keys later in
    // the file (acts/rites/relations defaults) are not mistaken for glyphs.
    const closeIdx = app.indexOf("\n  };", specsStart);
    const specsBlock = closeIdx === -1 ? app.slice(specsStart) : app.slice(specsStart, closeIdx);
    // Top-level keys are at 4-space indent and may be quoted: `    "auri-el": [`.
    for (const m of specsBlock.matchAll(/^ {4}"?([a-z0-9-]+)"?:\s*\[/gm)) {
      glyphKeys.add(m[1]);
    }
  }
}

// ---- 4. Roster coverage checks ----
const sortedRoster = [...roster].sort();
for (const deity of sortedRoster) {
  const symbol = nameToSymbol.get(deity);
  if (!symbol) {
    add("FAIL", `Deity "${deity}" has no Prisma symbol mapping (renders journal icon).`, MANAGER_PATH);
  } else if (!glyphKeys.has(symbol)) {
    const level = STRICT ? "FAIL" : "WARN";
    add(level, `Deity "${deity}" maps to "${symbol}" but that glyph is not authored in symbolSpecs yet (prisma-glyphs-phase2-deities).`, APP_JS_PATH);
  } else {
    add("PASS", `Deity "${deity}" maps to "${symbol}" (glyph present).`, MANAGER_PATH);
  }
}

// ---- 5. Tier-threshold parity ----
function readDeityBaseThresholds() {
  if (!fs.existsSync(DEITYBASE_PATH)) return null;
  const src = read(DEITYBASE_PATH);
  const grab = (name) => {
    const m = src.match(new RegExp(`Float\\s+Property\\s+${name}\\s*=\\s*([0-9.]+)`, "i"));
    return m ? Math.round(parseFloat(m[1])) : null;
  };
  return { seeker: grab("ThresholdSeeker"), devoted: grab("ThresholdDevoted"), champion: grab("ThresholdChampion") };
}

function readJsThresholds() {
  if (!fs.existsSync(APP_JS_PATH)) return null;
  const app = read(APP_JS_PATH);
  const block = app.match(/const\s+thresholds\s*=\s*\[([\s\S]*?)\]/);
  if (!block) return null;
  const out = {};
  for (const m of block[1].matchAll(/label:\s*"(\w+)",\s*value:\s*([0-9.]+)/g)) {
    out[m[1].toLowerCase()] = Math.round(parseFloat(m[2]));
  }
  return out;
}

const baseT = readDeityBaseThresholds();
const jsT = readJsThresholds();
if (!baseT || baseT.seeker == null) {
  add("FAIL", "Could not read DeityBase thresholds.", DEITYBASE_PATH);
} else if (!jsT || jsT.seeker == null) {
  add("FAIL", "Could not read JS panel thresholds.", APP_JS_PATH);
} else if (jsT.seeker !== baseT.seeker || jsT.devoted !== baseT.devoted || jsT.champion !== baseT.champion) {
  add("FAIL", `JS panel thresholds ${jsT.seeker}/${jsT.devoted}/${jsT.champion} != DeityBase ${baseT.seeker}/${baseT.devoted}/${baseT.champion}.`, APP_JS_PATH);
} else {
  add("PASS", `Panel thresholds match the ${baseT.seeker}/${baseT.devoted}/${baseT.champion} contract.`, APP_JS_PATH);
}

// Panel must emit a server-computed nextText and a per-deity champion denom.
if (fs.existsSync(MANAGER_PATH)) {
  const manager = read(MANAGER_PATH);
  if (manager.includes('GetPanelNextThresholdText') && manager.includes('\\"nextText\\"')) {
    add("PASS", "Manager emits per-deity nextText from real thresholds.", MANAGER_PATH);
  } else {
    add("FAIL", "Manager does not emit a per-deity nextText threshold string.", MANAGER_PATH);
  }
  if (manager.match(/primary\s*=\s*ClampValue\(piety\s*\/\s*150\.0/)) {
    add("FAIL", "Panel instrument still normalizes piety / 150.0 (stale champion scale).", MANAGER_PATH);
  } else {
    add("PASS", "Panel instrument normalizes piety against the champion threshold.", MANAGER_PATH);
  }
}

// ---- Report ----
const counts = { PASS: 0, WARN: 0, FAIL: 0 };
for (const r of results) counts[r.level]++;

if (JSON_MODE) {
  console.log(JSON.stringify({
    summary: counts,
    rosterSize: roster.size,
    specFiles: specFiles.length,
    mappedDeities: nameToSymbol.size,
    glyphKeys: glyphKeys.size,
    strict: STRICT,
    results,
  }, null, 2));
} else {
  for (const r of results) {
    const stream = r.level === "FAIL" ? console.error : console.log;
    stream(`[${r.level}] ${r.message}${r.source ? ` [${r.source}]` : ""}`);
  }
  console.log(`Prisma roster parity: PASS=${counts.PASS}, WARN=${counts.WARN}, FAIL=${counts.FAIL} (roster=${roster.size}, glyphs=${glyphKeys.size}${STRICT ? ", strict" : ""}).`);
}

process.exit(counts.FAIL > 0 ? 1 : 0);
