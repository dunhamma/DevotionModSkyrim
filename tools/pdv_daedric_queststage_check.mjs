#!/usr/bin/env node
// pdv_daedric_queststage_check.mjs
//
// Static verifier for the 16 Daedric organic quest-stage route guards.
//
// Catches two silent-failure bug classes that compile/author clean but break
// the real (organic) gameplay path, and that MCM/QASmoke route proof cannot see:
//   1. silent-miss: a hardcoded (questFormID, stage) in PDV_PlayerEvents.psc that
//      does not resolve to a real vanilla quest stage, so OnQuestStageChange never
//      fires that route in normal play.
//   2. index-drift: a RouteDaedricPrinceSignal index that does not match the Prince's
//      position in the contract manifest order (the PDV_FLST_DaedricPaths_All index
//      the manager resolves), i.e. the FormList-order bug class, on the routing side.
//
// Sources of truth (read-only; this writes nothing):
//   - guards:        <Devotion>/Scripts/Source/PDV_PlayerEvents.psc
//   - vanilla stages: references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv
//   - manifest order: references/authoring/PDV_DaedricPrinceRecordContracts.json
//
// Refresh the CSV with tools/pdv_extract_quest_stage_readback.mjs if vanilla data changes.

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { devotionSource } from "./lib/pdv_paths.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_daedric_queststage_check" });

const ROOT = process.cwd();
const PLAYER_EVENTS = path.join(devotionSource(), "PDV_PlayerEvents.psc");
const STAGE_CSV = path.join(
  ROOT, "references", "vanilla-gameplay", "extracted", "vanilla-quest-stage-readback.csv"
);
const CONTRACT = path.join(
  ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json"
);
const EXPECTED_GUARDS = 16;

// Expected vanilla quest editor id per Prince stem. A guard whose FormID resolves
// to a real quest with the right stage but the WRONG quest (e.g. a copy/paste of
// another Prince's FormID) still fails here.
const EXPECTED_QUEST = {
  Boethiah: "DA02", Azura: "DA01", Vaermina: "DA16", Meridia: "DA09",
  Molag: "DA10", Mephala: "DA08", Hircine: "DA05", Malacath: "DA06",
  Dagon: "DA07", Sheo: "DA15", Namira: "DA11", Sanguine: "DA14",
  Vile: "DA03", Mora: "DA04", Nocturnal: "TG09", Peryite: "DA13",
};

function toHex6(decimal) {
  return Number(decimal).toString(16).toUpperCase().padStart(6, "0");
}

function parseCsvLine(line) {
  const out = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"') {
        if (line[i + 1] === '"') { cur += '"'; i += 1; } else { inQuotes = false; }
      } else { cur += ch; }
    } else if (ch === '"') {
      inQuotes = true;
    } else if (ch === ",") {
      out.push(cur); cur = "";
    } else {
      cur += ch;
    }
  }
  out.push(cur);
  return out;
}

function loadStageMap() {
  const text = fs.readFileSync(STAGE_CSV, "utf8");
  const lines = text.split(/\r?\n/).filter((l) => l.length > 0);
  const header = parseCsvLine(lines[0]);
  const col = {
    formid: header.indexOf("formid"),
    editor: header.indexOf("editor_id"),
    name: header.indexOf("quest_name"),
    stages: header.indexOf("stage_indices"),
  };
  const map = new Map();
  for (let i = 1; i < lines.length; i += 1) {
    const cols = parseCsvLine(lines[i]);
    const formid = cols[col.formid] || "";
    const hex = (formid.includes(":") ? formid.split(":")[1] : formid).toUpperCase().padStart(6, "0");
    const stages = new Set(
      (cols[col.stages] || "").split(";").map((s) => s.trim()).filter(Boolean)
    );
    map.set(hex, { editorId: cols[col.editor] || "", questName: cols[col.name] || "", stages });
  }
  return map;
}

function loadGuards() {
  const text = fs.readFileSync(PLAYER_EVENTS, "utf8");
  const re = /ShouldRouteP2QuestStage\(\s*PDV_FLST_Daedric_(\w+?)LiveSources\s*,\s*sourceQuest\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*"([^"]+)"[^)]*\)\s*[\r\n]+\s*PDV_EventBusService\.RouteDaedricPrinceSignal\(\s*(\d+)\s*,/g;
  const guards = [];
  let m;
  while ((m = re.exec(text)) !== null) {
    guards.push({
      stem: m[1],
      formIdHex: toHex6(m[2]),
      stage: m[3],
      label: m[4],
      routeIndex: Number(m[5]),
    });
  }
  return guards;
}

function loadManifestOrder() {
  const contract = JSON.parse(fs.readFileSync(CONTRACT, "utf8"));
  const order = new Map();
  (contract.princes || []).forEach((p, i) => order.set(p.stem, i));
  return order;
}

function main() {
  const json = process.argv.slice(2).includes("--json");
  const stageMap = loadStageMap();
  const guards = loadGuards();
  const order = loadManifestOrder();

  const results = guards.map((g) => {
    const quest = stageMap.get(g.formIdHex);
    const errors = [];
    if (!quest) {
      errors.push(`FormID ${g.formIdHex} not found in vanilla quest-stage readback.`);
    } else {
      if (!quest.stages.has(String(g.stage))) {
        errors.push(`${quest.editorId} has no stage ${g.stage} (route would never fire).`);
      }
      const expectedQuest = EXPECTED_QUEST[g.stem];
      if (expectedQuest && quest.editorId !== expectedQuest) {
        errors.push(`resolves to ${quest.editorId}, expected ${expectedQuest} for ${g.stem} (wrong quest FormID).`);
      }
    }
    const expectedIndex = order.has(g.stem) ? order.get(g.stem) : null;
    if (expectedIndex === null) {
      errors.push(`stem ${g.stem} not in contract princes (cannot verify route index).`);
    } else if (expectedIndex !== g.routeIndex) {
      errors.push(`route index ${g.routeIndex} != manifest position ${expectedIndex} for ${g.stem} (index drift).`);
    }
    return {
      stem: g.stem,
      formIdHex: g.formIdHex,
      stage: g.stage,
      routeIndex: g.routeIndex,
      questEditorId: quest ? quest.editorId : null,
      questName: quest ? quest.questName : null,
      status: errors.length === 0 ? "PASS" : "FAIL",
      errors,
    };
  });

  const countOk = guards.length === EXPECTED_GUARDS;
  const allPass = countOk && results.every((r) => r.status === "PASS");

  if (json) {
    console.log(JSON.stringify(
      { status: allPass ? "PASS" : "FAIL", expectedGuards: EXPECTED_GUARDS, foundGuards: guards.length, results },
      null, 2
    ));
  } else {
    console.log(`PDV Daedric quest-stage guard check: ${allPass ? "PASS" : "FAIL"}`);
    console.log(`Guards: ${guards.length}/${EXPECTED_GUARDS} in PDV_PlayerEvents.psc, checked vs vanilla-quest-stage-readback.csv + contract manifest order`);
    if (!countOk) {
      console.log(`  ! Expected ${EXPECTED_GUARDS} Daedric guards, found ${guards.length}.`);
    }
    for (const r of results) {
      const q = r.questEditorId ? `${r.questEditorId} (${r.questName || ""})`.trim() : "<unresolved>";
      console.log(`- ${r.status} ${r.stem.padEnd(10)} idx ${String(r.routeIndex).padStart(2)} -> ${r.formIdHex} ${q} stage ${r.stage}`);
      for (const e of r.errors) console.log(`    ${e}`);
    }
  }

  process.exit(allPass ? 0 : 1);
}

main();
