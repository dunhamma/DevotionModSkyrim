#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--check-alias-properties", "--check-all", "--check-formlists", "--check-source-fill"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_housecarl_p2_readback" });

const ROOT = process.cwd();
const MANIFEST_PATH = path.join(ROOT, "references", "authoring", "PDV_Phase20_P2ImmersiveReceivers.manifest.json");
const MANAGER_FORM = "00C325:Devotion.esp";
const mode = process.argv[2] || "--check-all";

const report = { Status: "PASS", Actions: [], Errors: [], Authority: "direct-houseCARL-v1.7+" };

function normalizeFormKey(value) {
  const raw = String(value ?? "").trim();
  const match = raw.match(/^([^:]+):([0-9A-Fa-f]{6})$/);
  if (match && /\.(?:esm|esp|esl)$/i.test(match[1])) return `${match[2].toUpperCase()}:${match[1].toLowerCase()}`;
  const canonical = raw.match(/^([0-9A-Fa-f]{6}):(.+)$/);
  return canonical ? `${canonical[1].toUpperCase()}:${canonical[2].toLowerCase()}` : raw.toLowerCase();
}

function parseInventory(text) {
  const rows = new Map();
  const pattern = /formid=([0-9A-Fa-f]{6}:[^\s]+)\s+editorid=(PDV_FLST_P2_[A-Za-z0-9_]+)/g;
  for (const match of text.matchAll(pattern)) rows.set(match[2], match[1]);
  return rows;
}

function parseFormListItems(text) {
  const byEditorId = new Map();
  const blocks = text.split(/(?=\r?\ntype=FormList\s)/i);
  for (const block of blocks) {
    const editorId = block.match(/EditorID\s*=\s*(PDV_FLST_P2_[A-Za-z0-9_]+)/)?.[1];
    if (!editorId) continue;
    const items = new Set();
    for (const match of block.matchAll(/Items\[\d+\](?:\.Item)?\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/g)) {
      items.add(normalizeFormKey(match[1]));
    }
    byEditorId.set(editorId, items);
  }
  return byEditorId;
}

function parseAliasProperties(text) {
  const out = new Map();
  const lines = String(text).split(/\r?\n/);
  const names = new Map();
  for (const line of lines) {
    const nameMatch = line.match(/Aliases\[0\]\.Scripts\[(\d+)\]\.Properties\[(\d+)\](?:\.Name)?\s*=.*?Name=(PDV_FLST_P2_[A-Za-z0-9_]+)/);
    if (nameMatch) names.set(`${nameMatch[1]}:${nameMatch[2]}`, nameMatch[3]);
    const scalarName = line.match(/Aliases\[0\]\.Scripts\[(\d+)\]\.Properties\[(\d+)\]\.Name\s*=\s*(PDV_FLST_P2_[A-Za-z0-9_]+)/);
    if (scalarName) names.set(`${scalarName[1]}:${scalarName[2]}`, scalarName[3]);
  }
  for (const line of lines) {
    const objectMatch = line.match(/Aliases\[0\]\.Scripts\[(\d+)\]\.Properties\[(\d+)\]\.Object\s*=\s*([0-9A-Fa-f]{6}:[^\s\r\n]+)/);
    if (!objectMatch) continue;
    const name = names.get(`${objectMatch[1]}:${objectMatch[2]}`);
    if (name) out.set(name, objectMatch[3]);
  }
  return out;
}

async function main() {
  const manifest = JSON.parse(fs.readFileSync(MANIFEST_PATH, "utf8").replace(/^\uFEFF/, ""));
  const expected = manifest.sourceProperties.filter((row) => String(row.property).startsWith("PDV_FLST_P2_"));
  const inventoryResult = await callHousecarl("housecarl_cross_plugin_query", {
    plugins: ["Devotion.esp"], type: "FLST", editorid_contains: "PDV_FLST_P2_", fields: ["EditorID"], limit: 100, max_chars: 40_000,
  });
  const inventory = parseInventory(extractHousecarlText(inventoryResult));

  if (["--check-all", "--check-formlists", "--check-source-fill"].includes(mode)) {
    for (const row of expected) {
      if (inventory.has(row.property)) report.Actions.push(`${row.property} exists as FLST.`);
      else report.Errors.push(`${row.property} is missing as FLST.`);
    }
  }

  let itemMap = new Map();
  if (["--check-all", "--check-source-fill"].includes(mode) && inventory.size) {
    const detailResult = await callHousecarl("housecarl_batch_record_detail", {
      formids: [...inventory.values()], fields: ["EditorID", "Items"], depth: 3, max_chars: 250_000,
    }, { timeoutMs: 90_000 });
    itemMap = parseFormListItems(extractHousecarlText(detailResult));
    const approvedByProperty = new Map(expected.map((row) => [row.property, new Map()]));
    for (const group of manifest.sourceFillEntries ?? []) {
      const approved = approvedByProperty.get(group.property) ?? new Map();
      for (const source of group.sources ?? []) {
        if (source.status === "approved-for-fill") approved.set(normalizeFormKey(source.formKey), source.formKey);
      }
      approvedByProperty.set(group.property, approved);
    }
    for (const row of expected) {
      const approved = approvedByProperty.get(row.property) ?? new Map();
      const liveItems = itemMap.get(row.property) ?? new Set();
      for (const [wanted, display] of approved) {
        if (liveItems.has(wanted)) report.Actions.push(`${row.property} contains ${display}.`);
        else report.Errors.push(`${row.property} is missing ${display}.`);
      }
      for (const liveItem of liveItems) {
        if (!approved.has(liveItem)) report.Errors.push(`${row.property} is missing manifest authority for live member ${liveItem}.`);
      }
    }
  }

  if (["--check-all", "--check-alias-properties"].includes(mode)) {
    const managerResult = await callHousecarl("housecarl_read_record", {
      formid: MANAGER_FORM, fields: ["VirtualMachineAdapter.Aliases[0].Scripts"], depth: 5, max_chars: 250_000,
    }, { timeoutMs: 90_000 });
    const aliases = parseAliasProperties(extractHousecarlText(managerResult));
    for (const row of expected) {
      const target = aliases.get(row.property);
      const expectedTarget = inventory.get(row.property);
      if (target && expectedTarget && normalizeFormKey(target) === normalizeFormKey(expectedTarget)) {
        report.Actions.push(`PDV_PlayerEvents alias property ${row.property} points at ${target}.`);
      } else {
        report.Errors.push(`${row.property} alias property is missing or points at ${target || "nothing"}.`);
      }
    }
  }

  report.Status = report.Errors.length ? "FAIL" : "PASS";
  console.log(JSON.stringify(report, null, 2));
  process.exitCode = report.Status === "PASS" ? 0 : 1;
}

main().catch((error) => {
  report.Status = "FAIL";
  report.Errors.push(error.stack || error.message);
  console.log(JSON.stringify(report, null, 2));
  process.exitCode = 1;
});
