#!/usr/bin/env node
/*
 * Regenerate Devotion.seq from live QUST flags.
 *
 * Skyrim SEQ files are a compact little-endian list of start-game-enabled quest
 * FormIDs for one plugin. xEdit can create the same artifact through its UI;
 * this helper keeps the PDV refresh path deterministic and verifier-friendly.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { sameBytesToBuffer } from "./lib/pdv_file_compare.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--check", "--json", "--write"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_refresh_seq" });

const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.resolve(
  process.env.PDV_DEVOTION_ROOT || path.join(ANVIL_ROOT, "mods", "Devotion"),
);
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const DEVOTION_SEQ = path.join(DEVOTION_MOD, "Seq", "Devotion.seq");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const PLUGIN_NAME = "Devotion.esp";
const START_GAME_ENABLED_FLAG = 0x10;

const args = new Set(process.argv.slice(2));
const write = args.has("--write");
const check = args.has("--check");
const json = args.has("--json");
if (check && write) {
  throw new Error("--check and --write are mutually exclusive.");
}

function bridge(request, timeoutMs = 60_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    windowsHide: true,
  });
  if (result.error) {
    throw result.error;
  }
  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  }
  const payload = JSON.parse(stdout);
  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }
  return payload;
}

function localId(formid) {
  const [, id] = String(formid).split(":");
  if (!id) {
    throw new Error(`Unexpected FormID shape: ${formid}`);
  }
  return Number.parseInt(id, 16);
}

function fullFormId(localFormId) {
  return 0x04000000 | localFormId;
}

function parseQuestFlags(value) {
  if (typeof value === "number") {
    return value;
  }
  if (typeof value !== "string") {
    return 0;
  }
  if (/^\d+$/.test(value)) {
    return Number.parseInt(value, 10);
  }
  let flags = 0;
  if (value.includes("StartGameEnabled")) {
    flags |= START_GAME_ENABLED_FLAG;
  }
  return flags;
}

function readQuestDetails() {
  const scan = bridge({
    command: "scan",
    plugins: [PDV_ESP.replaceAll("\\", "/")],
  });
  const plugin = scan.plugins?.[0];
  if (!plugin) {
    throw new Error("Mutagen scan returned no plugin payload.");
  }
  const questRecords = (plugin.records || [])
    .filter((record) => record.type === "QUST")
    .filter((record) => String(record.formid || "").startsWith(`${PLUGIN_NAME}:`));

  const detail = bridge({
    command: "read_records",
    max_depth: 6,
    records: questRecords.map((record) => ({
      plugin_path: PDV_ESP.replaceAll("\\", "/"),
      formid: record.formid,
    })),
  });

  return (detail.records || [])
    .filter((record) => record.success)
    .map((record) => ({
      editorId: record.editor_id,
      formid: record.formid,
      localId: localId(record.formid),
      flags: parseQuestFlags(record.fields?.Flags),
      rawFlags: record.fields?.Flags,
    }));
}

function makeSeqBytes(quests) {
  const bytes = Buffer.alloc(quests.length * 4);
  quests.forEach((quest, index) => {
    bytes.writeUInt32LE(fullFormId(quest.localId), index * 4);
  });
  return bytes;
}

function main() {
  const quests = readQuestDetails();
  const startEnabled = quests
    .filter((quest) => (quest.flags & START_GAME_ENABLED_FLAG) !== 0)
    .sort((left, right) => left.localId - right.localId);
  const seqBytes = makeSeqBytes(startEnabled);
  const changed = !sameBytesToBuffer(DEVOTION_SEQ, seqBytes);
  const report = {
    status: "PASS",
    mode: write ? "write" : "check",
    write,
    seqPath: DEVOTION_SEQ,
    changed,
    questCount: startEnabled.length,
    quests: startEnabled.map((quest) => ({
      editorId: quest.editorId,
      formid: quest.formid,
      rawFlags: quest.rawFlags,
    })),
    backupPath: null,
  };

  if (write) {
    fs.mkdirSync(path.dirname(DEVOTION_SEQ), { recursive: true });
    if (fs.existsSync(DEVOTION_SEQ)) {
      const stamp = new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "").replace("T", "-");
      const backupPath = path.join(path.dirname(DEVOTION_SEQ), `Devotion.seq.${stamp}.bak`);
      fs.copyFileSync(DEVOTION_SEQ, backupPath);
      report.backupPath = backupPath;
    }
    fs.writeFileSync(DEVOTION_SEQ, seqBytes);
  }

  if (json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`PDV SEQ refresh: ${write ? "wrote" : "checked"} ${startEnabled.length} quest FormIDs`);
    for (const quest of startEnabled) {
      console.log(`- ${quest.formid} ${quest.editorId} flags=${quest.rawFlags}`);
    }
    if (report.backupPath) {
      console.log(`Backup: ${report.backupPath}`);
    }
    if (!write) {
      console.log("Pass --write to update the SEQ file.");
    }
  }
}

try {
  main();
} catch (error) {
  if (json) {
    console.log(JSON.stringify({ status: "FAIL", error: error.message, stack: error.stack }, null, 2));
  } else {
    console.error(`PDV SEQ refresh failed: ${error.message}`);
  }
  process.exitCode = 1;
}
