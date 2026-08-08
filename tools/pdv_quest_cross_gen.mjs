#!/usr/bin/env node
// PDV quest-reaction cross-generation (matrix expansion Phase 2, 2026-07-04).
//
// Crosses every already-tagged quest OUTCOME (tranche CSV rows) against every Part B
// deity value-profile in PDV_QuestReactionMatrix.md and emits CANDIDATE cells for
// (deity, quest, stage) pairs that do not exist yet. Candidates are magnitude "small"
// (the cheap breadth tier) with the profile intensity stepped one down, per the
// Tranche-5 aspect-parity precedent. Output is a REVIEW slate, not a tranche: nothing
// is merged or compiled by this tool.
//
// Usage:
//   node tools/pdv_quest_cross_gen.mjs            # generate candidates + summary
//   node tools/pdv_quest_cross_gen.mjs --source <channel.csv> [--source ...] --output-prefix T13
//   node tools/pdv_quest_cross_gen.mjs --source <matrix.csv> --outcome-key-file <editor_stage.csv> --output-prefix Review
//   node tools/pdv_quest_cross_gen.mjs --self-test
//
// Outputs (generated/, do not hand-edit):
//   references/authoring/generated/PDV_QuestCrossGen_Candidates.csv
//   references/authoring/generated/PDV_QuestCrossGen_Conflicts.csv
//   references/authoring/generated/PDV_QuestCrossGen_Summary.md

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// Derived from this file's own flag literals. An unknown flag is a usage error (exit 2),
// not a silent no-op: this tool has a --self-test, and ignoring a typo meant printing PASS
// for fixtures that never ran.
const KNOWN_FLAGS = new Set(["--inventory", "--outcome-key-file", "--output-prefix", "--self-test", "--source"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_quest_cross_gen" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const AUTHORING = path.join(ROOT, "references", "authoring");
const MATRIX_MD = path.join(AUTHORING, "PDV_QuestReactionMatrix.md");
const OUT_DIR = path.join(AUTHORING, "generated");

// Part B header names -> canonical runtime deity token (matches the compile tool's
// DEITY_ALIASES + EnsureCanonicalDeityDisplayNames in PDV__ManagerQuest.psc).
const NAME_CANON = new Map([
  ["Azurah / Azura", "Azura"],
  ["Azura / Azurah", "Azura"],
  ["Azura", "Azura"],
  ["Boethiah / Boethra", "Boethiah"],
  ["Malacath / Mauloch", "Malacath"],
  ["Mephala / Mafala", "Mephala"],
  ["Hist", "The Hist"],
  ["The Hist", "The Hist"],
]);

const STEP_DOWN = new Map([["C", "S"], ["S", "m"], ["m", "m"]]);

function canonName(raw) {
  const name = raw.trim();
  return NAME_CANON.get(name) ?? name;
}

// --- CSV (quoted fields, embedded commas) ---
function parseCsv(text) {
  const rows = [];
  let row = [], field = "", inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (inQuotes) {
      if (ch === '"') {
        if (text[i + 1] === '"') { field += '"'; i++; } else { inQuotes = false; }
      } else { field += ch; }
    } else if (ch === '"') {
      inQuotes = true;
    } else if (ch === ",") {
      row.push(field); field = "";
    } else if (ch === "\n" || ch === "\r") {
      if (ch === "\r" && text[i + 1] === "\n") i++;
      row.push(field); field = "";
      if (row.length > 1 || row[0] !== "") rows.push(row);
      row = [];
    } else { field += ch; }
  }
  if (field !== "" || row.length) { row.push(field); if (row.length > 1 || row[0] !== "") rows.push(row); }
  return rows;
}

function csvEscape(value) {
  const s = String(value ?? "");
  return /[",\n\r]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

// --- Part B parser ---
// Profile lines look like:
//   **Kyne** — the hunt, ...
//   - approve: `the_hunt`(C, *note*), `honor_the_wild`(S), `defend_kin_home`(m)
//   - disapprove: `defile_nature`(C)
// Tags may be namespaced (`destroy_reject_daedra:molagbal`) or wildcarded (`...:*`).
// `<self>` prince self-references are skipped (owned by the Daedric 20C layer).
export function parsePartB(mdText) {
  const profiles = new Map(); // canon name -> { approve: Map(tag->intensity), disapprove: Map }
  const partBStart = mdText.search(/^## Part B\b/m);
  const partCEnd = mdText.search(/^## Part C\b/m);
  const partBText = partBStart >= 0
    ? mdText.slice(partBStart, partCEnd > partBStart ? partCEnd : undefined)
    : mdText;
  const lines = partBText.split(/\r?\n/);
  let current = null;
  const header = /^\*\*([^*]+)\*\*\s+(?:—|--|-)\s/;
  const tagRe = /`([a-z_':*<>a-z0-9]+)`\((C|S|m)(?:[,)])/g;
  for (const line of lines) {
    const h = line.match(header);
    if (h) {
      const canon = canonName(h[1]);
      if (!profiles.has(canon)) profiles.set(canon, { approve: new Map(), disapprove: new Map() });
      current = profiles.get(canon);
      continue;
    }
    if (!current) continue;
    const side = line.match(/^\s*-\s*(approve|disapprove):\s*(.*)$/);
    if (!side) continue;
    const bucket = side[1] === "approve" ? current.approve : current.disapprove;
    let m;
    tagRe.lastIndex = 0;
    while ((m = tagRe.exec(side[2])) !== null) {
      const tag = m[1];
      if (tag.includes("<self>")) continue;
      // keep the STRONGEST intensity if a tag repeats
      const prev = bucket.get(tag);
      const rank = { C: 3, S: 2, m: 1 };
      if (!prev || rank[m[2]] > rank[prev]) bucket.set(tag, m[2]);
    }
  }
  return profiles;
}

// tag match: exact, namespace wildcard (profile `x:*` matches outcome `x:anything`),
// and namespace base (profile `x` matches outcome `x:anything`? NO -- too broad; only
// exact and explicit `:*`).
export function profileTagMatch(profileTags, outcomeTag) {
  if (profileTags.has(outcomeTag)) return profileTags.get(outcomeTag);
  const colon = outcomeTag.indexOf(":");
  if (colon > 0) {
    const wild = outcomeTag.slice(0, colon) + ":*";
    if (profileTags.has(wild)) return profileTags.get(wild);
  }
  return null;
}

function argValues(flag) {
  const values = [];
  for (let i = 0; i < process.argv.length; i++) {
    if (process.argv[i] === flag) {
      const value = process.argv[i + 1];
      if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value`);
      values.push(...value.split(",").map((item) => item.trim()).filter(Boolean));
    }
  }
  return values;
}

function argValue(flag, fallback = null) {
  const values = argValues(flag);
  if (values.length > 1) throw new Error(`${flag} may only be provided once`);
  return values[0] ?? fallback;
}

function existingMatrixFiles() {
  const files = readdirSync(AUTHORING)
    .filter(f => /^PDV_QuestReactionMatrix_Tranche\d/.test(f) && f.endsWith(".csv"))
    .map((file) => path.join(AUTHORING, file));
  for (const file of ["PDV_QuestReactionMatrix_Full.csv"]) {
    const candidate = path.join(AUTHORING, file);
    if (readdirSync(AUTHORING).includes(file)) files.push(candidate);
  }
  const patches = path.join(AUTHORING, "patches");
  try {
    files.push(...readdirSync(patches).filter((file) => file.endsWith(".csv")).map((file) => path.join(patches, file)));
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
  }
  return files;
}

function loadTranches(sourceArgs = []) {
  const defaultFiles = readdirSync(AUTHORING)
    .filter(f => /^PDV_QuestReactionMatrix_Tranche\d/.test(f) && f.endsWith(".csv"))
    .map((file) => path.join(AUTHORING, file));
  // Phase-3 quest-outcome inventory: tagged outcomes for quests not yet in any tranche
  // (no deity column -- pure outcome rows that only feed the cross product).
  if (process.argv.includes("--inventory")) defaultFiles.push(path.join(AUTHORING, "PDV_QuestOutcomeInventory.csv"));
  const outcomeFiles = sourceArgs.length ? sourceArgs.map((file) => path.resolve(ROOT, file)) : defaultFiles;
  const existingFiles = [...new Set([...existingMatrixFiles(), ...outcomeFiles])];
  const outcomes = new Map(); // key editor|stage|outcome-> {editorId, questName, stage, outcome, tags:Set}
  const existingPairs = new Set(); // deity|editor|stage
  function readRows(file, collectOutcomes) {
    const rows = parseCsv(readFileSync(file, "utf8"));
    const headerRow = rows[0].map(s => s.trim());
    const idx = (name) => headerRow.indexOf(name);
    for (const r of rows.slice(1)) {
      const editorId = (r[idx("editor_id")] || "").trim();
      const stage = (r[idx("outcome_stage")] || "").trim();
      if (!editorId || !stage) continue;
      const questName = (r[idx("quest_name")] || "").trim();
      const outcome = (r[idx("outcome")] || "").trim();
      const tags = (r[idx("act_tags")] || "").split(",").map(s => s.trim()).filter(Boolean);
      const deity = canonName((r[idx("deity")] || "").trim());
      const formid = idx("formid") >= 0 ? (r[idx("formid")] || "").trim() : "";
      const oKey = editorId + "|" + stage;
      if (collectOutcomes) {
        if (!outcomes.has(oKey)) outcomes.set(oKey, { editorId, questName, stage, outcome, tags: new Set(), formid });
        const entry = outcomes.get(oKey);
        for (const t of tags) entry.tags.add(t);
        if (!entry.outcome && outcome) entry.outcome = outcome;
        if (!entry.formid && formid) entry.formid = formid;
      }
      if (deity) existingPairs.add(deity + "|" + oKey);
    }
  }
  for (const file of outcomeFiles) readRows(file, true);
  for (const file of existingFiles) readRows(file, false);
  return { outcomes, existingPairs };
}

export function crossGenerate(profiles, outcomes, existingPairs) {
  const candidates = [];
  const conflicts = [];
  for (const o of outcomes.values()) {
    for (const [deity, profile] of profiles) {
      const pairKey = deity + "|" + o.editorId + "|" + o.stage;
      if (existingPairs.has(pairKey)) continue;
      let bestApprove = null, bestDisapprove = null, approveTag = null, disapproveTag = null;
      const rank = { C: 3, S: 2, m: 1 };
      for (const tag of o.tags) {
        const a = profileTagMatch(profile.approve, tag);
        if (a && (!bestApprove || rank[a] > rank[bestApprove])) { bestApprove = a; approveTag = tag; }
        const d = profileTagMatch(profile.disapprove, tag);
        if (d && (!bestDisapprove || rank[d] > rank[bestDisapprove])) { bestDisapprove = d; disapproveTag = tag; }
      }
      if (!bestApprove && !bestDisapprove) continue;
      if (bestApprove && bestDisapprove) {
        conflicts.push({ ...o, deity, approveTag, approveIntensity: bestApprove, disapproveTag, disapproveIntensity: bestDisapprove });
        continue;
      }
      const valence = bestApprove ? "+" : "-";
      const srcIntensity = bestApprove ?? bestDisapprove;
      const srcTag = bestApprove ? approveTag : disapproveTag;
      candidates.push({
        editorId: o.editorId, questName: o.questName, stage: o.stage, outcome: o.outcome,
        tag: srcTag, deity, valence,
        intensity: STEP_DOWN.get(srcIntensity), magnitude: "small",
        citation: `cross-gen candidate: ${srcTag}(${srcIntensity}) from the ${deity} Part B profile, stepped down; REVIEW before promotion`,
        formid: o.formid ?? "",
      });
    }
  }
  return { candidates, conflicts };
}

function selfTest() {
  const md = [
    "**Testgod** — testing.",
    "- approve: `slay_undead`(C), `destroy_reject_daedra:*`(S)",
    "- disapprove: `necromancy`(C)",
  ].join("\n");
  const profiles = parsePartB(md);
  const p = profiles.get("Testgod");
  if (!p || p.approve.get("slay_undead") !== "C") throw new Error("self-test: approve parse failed");
  if (profileTagMatch(p.approve, "destroy_reject_daedra:molagbal") !== "S") throw new Error("self-test: wildcard match failed");
  const outcomes = new Map([["Q1|10", { editorId: "Q1", questName: "Test Quest", stage: "10", outcome: "slew undead", tags: new Set(["slay_undead"]) }]]);
  const { candidates } = crossGenerate(profiles, outcomes, new Set());
  const c = candidates.find(x => x.deity === "Testgod");
  if (!c || c.valence !== "+" || c.intensity !== "S" || c.magnitude !== "small") throw new Error("self-test: candidate shape wrong: " + JSON.stringify(c));
  const { candidates: deduped } = crossGenerate(profiles, outcomes, new Set(["Testgod|Q1|10"]));
  if (deduped.some(x => x.deity === "Testgod")) throw new Error("self-test: dedupe failed");
  console.log("self-test PASS");
}

function main() {
  if (process.argv.includes("--self-test")) { selfTest(); return; }
  const sourceArgs = argValues("--source");
  const outputPrefix = argValue("--output-prefix", "");
  const outcomeKeyFile = argValue("--outcome-key-file", "");
  if (outputPrefix && !/^[A-Za-z0-9_-]+$/.test(outputPrefix)) throw new Error("--output-prefix must be a simple filename token");
  const profiles = parsePartB(readFileSync(MATRIX_MD, "utf8"));
  const { outcomes, existingPairs } = loadTranches(sourceArgs);
  if (outcomeKeyFile) {
    const keyRows = parseCsv(readFileSync(path.resolve(ROOT, outcomeKeyFile), "utf8"));
    const header = keyRows[0].map((value) => value.trim());
    const editorIndex = header.indexOf("editor_id");
    const stageIndex = header.indexOf("outcome_stage");
    if (editorIndex < 0 || stageIndex < 0) throw new Error("--outcome-key-file requires editor_id and outcome_stage columns");
    const allowed = new Set(keyRows.slice(1).map((row) => `${(row[editorIndex] || "").trim()}|${(row[stageIndex] || "").trim()}`).filter((key) => key !== "|"));
    const missing = [...allowed].filter((key) => !outcomes.has(key));
    if (missing.length) throw new Error(`--outcome-key-file contains unknown outcome key(s): ${missing.join(", ")}`);
    for (const key of outcomes.keys()) if (!allowed.has(key)) outcomes.delete(key);
  }
  const { candidates, conflicts } = crossGenerate(profiles, outcomes, existingPairs);

  mkdirSync(OUT_DIR, { recursive: true });
  const suffix = outputPrefix ? `_${outputPrefix}` : "";
  const header = "editor_id,quest_name,outcome_stage,outcome,act_tags,deity,valence,intensity,magnitude,citation,formid";
  const candCsv = [header, ...candidates.map(c => [c.editorId, c.questName, c.stage, c.outcome, c.tag, c.deity, c.valence, c.intensity, c.magnitude, c.citation, c.formid].map(csvEscape).join(","))].join("\n") + "\n";
  writeFileSync(path.join(OUT_DIR, `PDV_QuestCrossGen${suffix}_Candidates.csv`), candCsv);
  const confCsv = ["editor_id,quest_name,outcome_stage,outcome,deity,approve_tag,approve_intensity,disapprove_tag,disapprove_intensity",
    ...conflicts.map(c => [c.editorId, c.questName, c.stage, c.outcome, c.deity, c.approveTag, c.approveIntensity, c.disapproveTag, c.disapproveIntensity].map(csvEscape).join(","))].join("\n") + "\n";
  writeFileSync(path.join(OUT_DIR, `PDV_QuestCrossGen${suffix}_Conflicts.csv`), confCsv);

  const byDeity = new Map();
  for (const c of candidates) {
    if (!byDeity.has(c.deity)) byDeity.set(c.deity, { plus: 0, minus: 0, quests: new Set() });
    const b = byDeity.get(c.deity);
    if (c.valence === "+") b.plus++; else b.minus++;
    b.quests.add(c.editorId);
  }
  const existingQuestsByDeity = new Map();
  for (const pair of existingPairs) {
    const [deity, editorId] = pair.split("|");
    if (!existingQuestsByDeity.has(deity)) existingQuestsByDeity.set(deity, new Set());
    existingQuestsByDeity.get(deity).add(editorId);
  }
  const summaryRows = [...byDeity.entries()]
    .map(([deity, b]) => ({ deity, plus: b.plus, minus: b.minus, newQuests: b.quests.size, existingQuests: (existingQuestsByDeity.get(deity) ?? new Set()).size }))
    .sort((a, b) => (b.newQuests + b.existingQuests) - (a.newQuests + a.existingQuests));
  const md = [
    "# Quest Cross-Gen Summary (GENERATED -- do not hand-edit)",
    "",
    `Outcomes crossed: ${outcomes.size} | Part B profiles: ${profiles.size} | candidates: ${candidates.length} | conflicts: ${conflicts.length}`,
    "",
    "| deity | + | - | new quests | existing quests | total quests |",
    "|---|---|---|---|---|---|",
    ...summaryRows.map(r => `| ${r.deity} | ${r.plus} | ${r.minus} | ${r.newQuests} | ${r.existingQuests} | ${r.newQuests + r.existingQuests} |`),
    "",
  ].join("\n");
  writeFileSync(path.join(OUT_DIR, `PDV_QuestCrossGen${suffix}_Summary.md`), md);
  console.log(`outcomes=${outcomes.size} profiles=${profiles.size} candidates=${candidates.length} conflicts=${conflicts.length}`);
  console.log("wrote generated/PDV_QuestCrossGen_{Candidates,Conflicts}.csv + Summary.md");
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) main();
