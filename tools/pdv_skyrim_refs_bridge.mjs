#!/usr/bin/env node
/**
 * Read-only bridge into the neutral SkyrimGamePlayReferences repository.
 *
 * This does not copy broad reference data into PDV. It locates the external
 * reference repo, reports which high-value tables are available, and can search
 * selected CSV tables for PDV planning work.
 */

import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--limit"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_skyrim_refs_bridge" });

const PROJECT_ROOT = process.cwd();

const TABLES = [
  {
    key: "reverse-keywords",
    file: "data/extracted/vanilla-reverse-keyword-index.csv",
    pdvUse: "Start from a CK keyword and find example vanilla records that use it.",
  },
  {
    key: "faction-relationships",
    file: "data/extracted/vanilla-faction-relationships.csv",
    pdvUse: "Inspect faction ranks, crime values, and reaction surfaces for civic/religious signals.",
  },
  {
    key: "condition-effects",
    file: "data/extracted/vanilla-condition-bearing-effects-index.csv",
    pdvUse: "Find vanilla effects, spells, perks, and enchantments that already use CK conditions.",
  },
  {
    key: "locations",
    file: "data/extracted/vanilla-location-signal-candidates.csv",
    pdvUse: "Review location records for sacred places, civic spaces, strongholds, ruins, and inns.",
  },
  {
    key: "cells",
    file: "data/extracted/vanilla-cell-location-candidates.csv",
    pdvUse: "Scan named cell candidates before focused xEdit/CK inspection.",
  },
  {
    key: "containers-furniture",
    file: "data/extracted/vanilla-container-furniture-candidates.csv",
    pdvUse: "Find beds, crafting stations, vendor containers, altars, and ritual interaction candidates.",
  },
  {
    key: "enchantments",
    file: "data/extracted/vanilla-enchantment-palette.csv",
    pdvUse: "Compare reward effect patterns and equipment-effect magnitudes.",
  },
  {
    key: "magic-effects",
    file: "data/extracted/vanilla-magic-effect-palette.csv",
    pdvUse: "Compare blessing, curse, boon, neglect, and active-effect implementation patterns.",
  },
  {
    key: "leveled-lists",
    file: "data/extracted/vanilla-leveled-list-signal-candidates.csv",
    pdvUse: "Inspect distribution candidates for future offline patcher rules.",
  },
  {
    key: "formlists",
    file: "data/extracted/vanilla-formlist-detail-candidates.csv",
    pdvUse: "Inspect curated vanilla record sets before designing PDV FormLists or patcher manifests.",
  },
  {
    key: "shouts",
    file: "data/extracted/vanilla-shout-records.csv",
    pdvUse: "Review voice-power records for Dragonborn or Thu'um-adjacent design.",
  },
  {
    key: "worldspaces",
    file: "data/extracted/vanilla-worldspace-records.csv",
    pdvUse: "Check worldspace scope for Skyrim, Solstheim, and mythic spaces.",
  },
];

function main() {
  const args = process.argv.slice(2);
  const command = args[0] || "status";
  const root = findReferenceRoot();

  if (command === "status") {
    printStatus(root);
    return;
  }
  if (command === "tables") {
    printTables(root);
    return;
  }
  if (command === "search") {
    searchTable(root, args.slice(1));
    return;
  }

  usage(`Unknown command: ${command}`);
}

function findReferenceRoot() {
  const candidates = [
    process.env.SKYRIM_GAMEPLAY_REFERENCES_ROOT,
    path.join(PROJECT_ROOT, "scratch", "SkyrimGamePlayReferences"),
    path.resolve(PROJECT_ROOT, "..", "SkyrimGamePlayReferences"),
  ].filter(Boolean);

  for (const candidate of candidates) {
    const resolved = path.resolve(candidate);
    if (fs.existsSync(path.join(resolved, "README.md"))
      && fs.existsSync(path.join(resolved, "data", "extracted"))) {
      return resolved;
    }
  }

  return "";
}

function printStatus(root) {
  if (!root) {
    console.log("SkyrimGamePlayReferences repo not found.");
    console.log("Set SKYRIM_GAMEPLAY_REFERENCES_ROOT to the local clone path.");
    process.exitCode = 1;
    return;
  }

  console.log(`reference_root: ${root}`);
  console.log(`git_head: ${gitHead(root) || "unknown"}`);
  printTables(root);
}

function printTables(root) {
  if (!root) {
    console.log("SkyrimGamePlayReferences repo not found.");
    console.log("Set SKYRIM_GAMEPLAY_REFERENCES_ROOT to the local clone path.");
    process.exitCode = 1;
    return;
  }

  for (const table of TABLES) {
    const filePath = path.join(root, table.file);
    const rows = fs.existsSync(filePath) ? countCsvRows(filePath) : "missing";
    console.log(`${table.key}\t${rows}\t${table.file}\t${table.pdvUse}`);
  }
}

function searchTable(root, args) {
  if (!root) {
    console.log("SkyrimGamePlayReferences repo not found.");
    console.log("Set SKYRIM_GAMEPLAY_REFERENCES_ROOT to the local clone path.");
    process.exitCode = 1;
    return;
  }

  const tableKey = args[0];
  const term = args[1];
  const limit = readLimit(args);
  if (!tableKey || !term) {
    usage("Search requires a table key and search term.");
    return;
  }

  const table = TABLES.find((entry) => entry.key === tableKey);
  if (!table) {
    usage(`Unknown table key: ${tableKey}`);
    return;
  }

  const filePath = path.join(root, table.file);
  if (!fs.existsSync(filePath)) {
    console.log(`Missing table: ${filePath}`);
    process.exitCode = 1;
    return;
  }

  const rows = parseCsv(fs.readFileSync(filePath, "utf8"));
  const needle = term.toLowerCase();
  const matches = rows.filter((row) => Object.values(row).some((value) => String(value).toLowerCase().includes(needle)));

  const selected = matches.slice(0, limit);
  console.log(`table: ${table.key}`);
  console.log(`matches: ${matches.length}`);
  console.log(`showing: ${selected.length}`);
  for (const row of selected) {
    console.log(JSON.stringify(row));
  }
}

function usage(message) {
  if (message) {
    console.log(message);
  }
  console.log("Usage:");
  console.log("  node .\\tools\\pdv_skyrim_refs_bridge.mjs status");
  console.log("  node .\\tools\\pdv_skyrim_refs_bridge.mjs tables");
  console.log("  node .\\tools\\pdv_skyrim_refs_bridge.mjs search <table-key> <term> [--limit N]");
  console.log("Example:");
  console.log("  node .\\tools\\pdv_skyrim_refs_bridge.mjs search reverse-keywords daedra --limit 10");
  process.exitCode = 1;
}

function readLimit(args) {
  const index = args.indexOf("--limit");
  if (index === -1) {
    return 20;
  }
  const value = Number.parseInt(args[index + 1] || "", 10);
  return Number.isFinite(value) && value > 0 ? value : 20;
}

function gitHead(root) {
  const dotGit = path.join(root, ".git");
  const headPath = path.join(dotGit, "HEAD");
  if (!fs.existsSync(headPath)) {
    return "";
  }
  const head = fs.readFileSync(headPath, "utf8").trim();
  if (head.startsWith("ref:")) {
    const refName = head.slice("ref:".length).trim();
    const refPath = path.join(dotGit, ...refName.split("/"));
    if (fs.existsSync(refPath)) {
      return fs.readFileSync(refPath, "utf8").trim().slice(0, 7);
    }
    return "";
  }
  return head.slice(0, 7);
}

function countCsvRows(filePath) {
  const text = fs.readFileSync(filePath, "utf8").trim();
  if (!text) {
    return 0;
  }
  return Math.max(0, parseCsv(text).length);
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let inQuotes = false;

  for (let i = 0; i < text.length; i += 1) {
    const char = text[i];
    const next = text[i + 1];

    if (inQuotes && char === "\"" && next === "\"") {
      cell += "\"";
      i += 1;
      continue;
    }
    if (char === "\"") {
      inQuotes = !inQuotes;
      continue;
    }
    if (!inQuotes && char === ",") {
      row.push(cell);
      cell = "";
      continue;
    }
    if (!inQuotes && (char === "\n" || char === "\r")) {
      if (char === "\r" && next === "\n") {
        i += 1;
      }
      row.push(cell);
      rows.push(row);
      row = [];
      cell = "";
      continue;
    }
    cell += char;
  }

  if (cell.length > 0 || row.length > 0) {
    row.push(cell);
    rows.push(row);
  }

  if (rows.length === 0) {
    return [];
  }

  const header = rows[0];
  return rows.slice(1).filter((values) => values.some((value) => value !== "")).map((values) => {
    const out = {};
    for (let i = 0; i < header.length; i += 1) {
      out[header[i]] = values[i] ?? "";
    }
    return out;
  });
}

main();
