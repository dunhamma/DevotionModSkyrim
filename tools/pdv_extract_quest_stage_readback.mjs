#!/usr/bin/env node
/**
 * Extract exact quest-stage readback for Phase 20 source curation.
 *
 * This is read-only. It reads the generated vanilla/DLC quest candidate table,
 * asks the local Mutagen bridge for QUST details, and writes a searchable CSV.
 */

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--chunk-size", "--editor-id", "--formid", "--limit", "--max-depth", "--out", "--plugin"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_extract_quest_stage_readback" });

const PROJECT_ROOT = process.cwd();
const INPUT_CSV = path.join(PROJECT_ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-candidates.csv");
const OUTPUT_CSV = path.join(PROJECT_ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv");
const DATA_ROOT = "D:/Wabbajack/modlists/Anvil/Stock Game/Data";
const CLEANED_MASTERS_ROOT = "D:/Wabbajack/modlists/Anvil/mods/Cleaned Base Game Masters";
const BRIDGE = "D:/Wabbajack/modlists/Anvil/plugins/Anvilmo2_mcp/tools/mutagen-bridge/mutagen-bridge.exe";
const MAX_BUFFER = 512 * 1024 * 1024;

const PLUGIN_PATHS = new Map([
  ["Skyrim.esm", path.posix.join(DATA_ROOT, "Skyrim.esm")],
  ["Update.esm", path.posix.join(DATA_ROOT, "Update.esm")],
  ["Dawnguard.esm", path.posix.join(CLEANED_MASTERS_ROOT, "Dawnguard.esm")],
  ["HearthFires.esm", path.posix.join(CLEANED_MASTERS_ROOT, "HearthFires.esm")],
  ["Dragonborn.esm", path.posix.join(CLEANED_MASTERS_ROOT, "Dragonborn.esm")],
]);

const PINNED_READBACK_CANDIDATES = [
  // Signal-floor deep-dive refresh, 2026-07-09. These quests are exact
  // handoff targets that the broad candidate scan intentionally misses.
  pinnedQuest("Skyrim.esm", "Skyrim.esm:018B4B", "MS01", "Forsworn Conspiracy: Mephala/Clavicus deceit readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:040A5E", "MS02", "Cidhna Mine: Madanach betrayal, Nocturnal/Mephala readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0934FB", "DBDestroy", "Destroy the Dark Brotherhood: Sithis negative and expose-route readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0E3163", "CR13", "Companions Purity: Farkas/Vilkas cure readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0E3145", "CR12", "Totems of Hircine: radiant hunt-law readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:01DBFC", "MS10", "Rise in the East: actual EditorID for the EEC civic-prosperity target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:053511", "MS05", "Tending the Flames: Dibella provisional stage confirmation"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:023B6C", "T01", "Heart of Dibella: provisional stage confirmation"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0211D5", "t02", "Book of Love: provisional stage confirmation"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:074793", "RelationshipMarriage", "Bonds of Matrimony: direct wedding-row review target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:01FD72", "FreeformKolskeggrA", "Kolskeggr Mine: actual stock EditorID for the labor-restoration target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0E49E7", "FreeformShorsStone01", "Shor's Stone mine quest: labor-restoration readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:0E49E8", "FreeformShorsStone02", "Shor's Stone delivery quest: labor-restoration readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:06136B", "FreeformSoljundsSinkholeA", "Soljund's Sinkhole: labor-restoration readback target"),
  pinnedQuest("Skyrim.esm", "Skyrim.esm:01C48E", "T03", "Blessings of Nature: T03 stage 105 spot-check target"),
];

function main() {
  const args = process.argv.slice(2);
  const formidFilter = readArg(args, "--formid");
  const editorIdFilter = readArg(args, "--editor-id");
  const directPlugin = readArg(args, "--plugin");
  const outputPath = readArg(args, "--out") || OUTPUT_CSV;
  const limit = readIntArg(args, "--limit");
  const chunkSize = readIntArg(args, "--chunk-size") || 25;
  const maxDepth = readIntArg(args, "--max-depth") || 8;

  let candidates = appendPinnedCandidates(parseCsv(fs.readFileSync(INPUT_CSV, "utf8")))
    .filter((row) => !formidFilter || sameText(row.formid, formidFilter))
    .filter((row) => !editorIdFilter || sameText(row.editor_id, editorIdFilter))
    .slice(0, limit || undefined);

  if (candidates.length === 0 && formidFilter && directPlugin) {
    candidates = [{
      plugin: directPlugin,
      formid: formidFilter,
      editor_id: editorIdFilter || "",
      pdv_use: "direct quest-stage readback smoke",
      validation: "direct-readback",
    }];
  }

  if (candidates.length === 0) {
    throw new Error("No quest candidates matched the requested filters. Use --plugin with --formid for direct readback.");
  }

  const rows = [];
  const byPlugin = groupBy(candidates, (row) => row.plugin);
  for (const [plugin, pluginRows] of byPlugin.entries()) {
    const pluginPath = PLUGIN_PATHS.get(plugin);
    if (!pluginPath) {
      for (const row of pluginRows) {
        rows.push(errorRow(row, `No plugin path configured for ${plugin}.`));
      }
      continue;
    }

    for (const chunk of chunks(pluginRows, chunkSize)) {
      const payload = bridge({
        command: "read_records",
        max_depth: maxDepth,
        records: chunk.map((row) => ({
          plugin_path: pluginPath,
          formid: row.formid,
        })),
      }, 180_000);

      for (let i = 0; i < chunk.length; i += 1) {
        rows.push(toReadbackRow(chunk[i], payload.records?.[i]));
      }
    }
  }

  writeCsv(outputPath, rows);
  console.log(`Wrote ${rows.length} quest-stage readback rows to ${outputPath}`);
}

function pinnedQuest(plugin, formid, editorId, pdvUse) {
  return {
    plugin,
    formid,
    editor_id: editorId,
    pdv_use: `signal-floor deep-dive readback refresh: ${pdvUse}`,
    detail_status: "curated exact quest-stage readback target from PDV_SignalFloor_DeepDive_ConsolidatedCodexHandoff_2026-07-09.md",
    validation: "curated-readback-refresh-2026-07-09",
  };
}

function appendPinnedCandidates(rows) {
  const seen = new Set(rows.map(candidateKey));
  const out = [...rows];
  for (const row of PINNED_READBACK_CANDIDATES) {
    const key = candidateKey(row);
    if (!seen.has(key)) {
      out.push(row);
      seen.add(key);
    }
  }
  return out;
}

function candidateKey(row) {
  return `${row.plugin || ""}|${row.formid || ""}|${row.editor_id || ""}`.toLowerCase();
}

function toReadbackRow(candidate, record) {
  if (!record?.success) {
    return errorRow(candidate, record?.error || "No readback payload returned.");
  }

  const fields = record.fields || {};
  const stages = Array.isArray(fields.Stages) ? fields.Stages : [];
  const objectives = Array.isArray(fields.Objectives) ? fields.Objectives : [];
  const fragments = Array.isArray(fields.VirtualMachineAdapter?.Fragments)
    ? fields.VirtualMachineAdapter.Fragments
    : [];
  const aliases = Array.isArray(fields.Aliases) ? fields.Aliases : [];

  return {
    source_plugin: candidate.plugin,
    readback_plugin: record.plugin || "",
    formid: candidate.formid,
    editor_id: candidate.editor_id,
    readback_editor_id: record.editor_id || fields.EditorID || "",
    quest_name: fields.Name || "",
    quest_type: fields.Type || "",
    quest_flags: fields.Flags || "",
    quest_filter: fields.Filter || "",
    pdv_use: candidate.pdv_use || "",
    candidate_validation: candidate.validation || "",
    readback_status: "readback-ok",
    stage_count: stages.length,
    stage_indices: stages.map((stage) => stage.Index ?? stage.Stage ?? "").filter((value) => value !== "").join("; "),
    completion_stages: stagesWithFlag(stages, "CompleteQuest"),
    fail_stages: stagesWithFlag(stages, "FailQuest"),
    startup_stages: stagesWithFlag(stages, "StartUpStage"),
    stage_log_summary: summarizeStages(stages),
    objective_summary: summarizeObjectives(objectives),
    fragment_stage_indices: fragments.map((fragment) => fragment.Stage ?? "").filter((value) => value !== "").join("; "),
    fragment_scripts: unique(fragments.map((fragment) => fragment.ScriptName).filter(Boolean)).join("; "),
    alias_summary: summarizeAliases(aliases),
    approval_seed: "scan-only; exact stage/outcome semantics require dossier review",
  };
}

function errorRow(candidate, message) {
  return {
    source_plugin: candidate.plugin || "",
    readback_plugin: "",
    formid: candidate.formid || "",
    editor_id: candidate.editor_id || "",
    readback_editor_id: "",
    quest_name: "",
    quest_type: "",
    quest_flags: "",
    quest_filter: "",
    pdv_use: candidate.pdv_use || "",
    candidate_validation: candidate.validation || "",
    readback_status: `readback-error: ${message}`,
    stage_count: 0,
    stage_indices: "",
    completion_stages: "",
    fail_stages: "",
    startup_stages: "",
    stage_log_summary: "",
    objective_summary: "",
    fragment_stage_indices: "",
    fragment_scripts: "",
    alias_summary: "",
    approval_seed: "readback failed; do not approve",
  };
}

function stagesWithFlag(stages, flag) {
  return stages
    .filter((stage) => stageHasFlag(stage, flag))
    .map((stage) => stage.Index ?? stage.Stage ?? "")
    .filter((value) => value !== "")
    .join("; ");
}

function stageHasFlag(stage, flag) {
  if (String(stage.Flags || "").includes(flag)) {
    return true;
  }
  const entries = Array.isArray(stage.LogEntries) ? stage.LogEntries : [];
  return entries.some((entry) => String(entry.Flags || "").includes(flag));
}

function summarizeStages(stages) {
  return stages
    .map((stage) => {
      const index = stage.Index ?? stage.Stage ?? "";
      const flags = stage.Flags && stage.Flags !== "0" ? ` [${stage.Flags}]` : "";
      const entries = Array.isArray(stage.LogEntries) ? stage.LogEntries : [];
      const text = entries
        .map((entry) => String(entry.Entry || "").replace(/\s+/g, " ").trim())
        .find(Boolean);
      return text ? `${index}${flags}: ${text}` : `${index}${flags}`;
    })
    .join(" | ");
}

function summarizeObjectives(objectives) {
  return objectives
    .map((objective) => {
      const index = objective.Index ?? "";
      const text = String(objective.DisplayText || "").replace(/\s+/g, " ").trim();
      return text ? `${index}: ${text}` : `${index}`;
    })
    .join(" | ");
}

function summarizeAliases(aliases) {
  return aliases
    .map((alias) => {
      const id = alias.ID ?? "";
      const type = alias.Type || "";
      const name = alias.Name || "";
      return [id, type, name].filter((value) => value !== "").join(":");
    })
    .filter(Boolean)
    .slice(0, 40)
    .join("; ");
}

function bridge(request, timeoutMs) {
  const result = spawnSync(BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: MAX_BUFFER,
    windowsHide: true,
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `mutagen-bridge failed with ${result.status}`);
  }
  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${result.stderr || ""}`);
  }
  const payload = JSON.parse(stdout);
  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }
  return payload;
}

function writeCsv(filePath, rows) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const columns = [
    "source_plugin",
    "readback_plugin",
    "formid",
    "editor_id",
    "readback_editor_id",
    "quest_name",
    "quest_type",
    "quest_flags",
    "quest_filter",
    "pdv_use",
    "candidate_validation",
    "readback_status",
    "stage_count",
    "stage_indices",
    "completion_stages",
    "fail_stages",
    "startup_stages",
    "stage_log_summary",
    "objective_summary",
    "fragment_stage_indices",
    "fragment_scripts",
    "alias_summary",
    "approval_seed",
  ];
  const lines = [
    columns.join(","),
    ...rows.map((row) => columns.map((column) => csvCell(row[column])).join(",")),
  ];
  fs.writeFileSync(filePath, `${lines.join("\n")}\n`, "utf8");
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

function csvCell(value) {
  if (value === undefined || value === null) {
    return "";
  }
  const text = Array.isArray(value) ? value.join("; ") : String(value);
  if (/[",\n\r]/.test(text)) {
    return `"${text.replaceAll("\"", "\"\"")}"`;
  }
  return text;
}

function groupBy(items, keyFn) {
  const groups = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key).push(item);
  }
  return groups;
}

function chunks(items, size) {
  const out = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

function unique(items) {
  return [...new Set(items)];
}

function sameText(left, right) {
  return String(left || "").toLowerCase() === String(right || "").toLowerCase();
}

function readArg(args, name) {
  const index = args.indexOf(name);
  return index === -1 ? "" : args[index + 1] || "";
}

function readIntArg(args, name) {
  const value = readArg(args, name);
  if (!value) {
    return 0;
  }
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}

main();
