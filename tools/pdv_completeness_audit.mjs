#!/usr/bin/env node
/*
 * Contract-coverage completeness gate for PDV.
 *
 * Driven by references/authoring/PDV_BetaContract.csv (765 rows extracted
 * 2026-06-10 from the canonical docs; baseline = Content-Feel Beta bar +
 * player-reachability rule). Verifies each BETA-tier contract row against
 * the layer its verify_layer names:
 *
 *   data           - repo CSVs/docs (matrix cells, Part B profiles, faucets,
 *                    stance rows, name resolution)
 *   source         - static .psc analysis of the live Devotion source:
 *                    identifier existence, SIGNAL_* call sites, and
 *                    handler piety-reachability (the telemetry-stub class:
 *                    a Handle- or Route- handler that bumps counters but
 *                    never reaches AwardCuratedSignal, AwardPiety,
 *                    ApplyDeityReaction, or a Record...Scaled call feeds
 *                    nothing)
 *   esp            - EditorID existence via the MO2 Mutagen bridge scan of
 *                    PlayerDevotion_Framework.esp (same bridge pdv_verify
 *                    uses; this tool never edits pdv_verify)
 *   runtime-status - carried READ-ONLY from PDV_PreBetaRaceGateLedger.md;
 *                    never a machine pass/fail here
 *
 * Verdicts per row:
 *   PASS         - every extractable expectation found
 *   GAP          - a hard expectation missing (authority is structured
 *                  data: spec JSON / contracts JSON / CSV)
 *   GAP-REVIEW   - expectation missing but authority is prose (race sheet,
 *                  architecture doc) so the identifier may be a proposed
 *                  name, not a canonical one - review before treating as
 *                  a build gap
 *   NEEDS-MANUAL - no machine-checkable identifier could be extracted;
 *                  must be verified by a person (listed, never silently
 *                  passed)
 *   FUTURE       - tier=FUTURE; reported, never gated
 *   WAIVED       - present in PDV_CompletenessWaivers.csv with a reason
 *
 * Exit 1 when unwaived GAP rows exist (GAP-REVIEW and NEEDS-MANUAL are
 * reported but do not fail the gate; promote them via the waiver file's
 * inverse - editing the contract row's check_hint to a canonical
 * identifier - once adjudicated).
 *
 * Read-only everywhere. Emits references/authoring/PDV_CompletenessGapLedger.md
 * and .csv. ESP layer degrades to SKIPPED (explicit, never silent) when the
 * bridge or ESP is unavailable.
 *
 * Per PDV_STANDARDS.md 5.1 this tool is a citable completeness gate.
 * Plan: references/authoring/PDV_CompletenessAudit_Plan.md
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const CONTRACT_CSV = path.join(ROOT, "references", "authoring", "PDV_BetaContract.csv");
const WAIVER_CSV = path.join(ROOT, "references", "authoring", "PDV_CompletenessWaivers.csv");
const OUT_MD = path.join(ROOT, "references", "authoring", "PDV_CompletenessGapLedger.md");
const OUT_CSV = path.join(ROOT, "references", "authoring", "PDV_CompletenessGapLedger.csv");

const MATRIX_CSV = path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix_Full.csv");
const FAUCET_CSV = path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv");
const MATRIX_DOC = path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix.md");
const STANCE_CSV = path.join(ROOT, "references", "phase4", "PDV_StanceMatrix.csv");
const DAEDRIC_CSV = path.join(ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv");
const GATE_LEDGER = path.join(ROOT, "references", "authoring", "PDV_PreBetaRaceGateLedger.md");
const DAEDRIC_CONTRACTS = path.join(ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");

const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const SOURCE_DIR = path.join(ANVIL_ROOT, "mods", "Devotion", "Scripts", "Source");
const PDV_ESP = path.join(ANVIL_ROOT, "mods", "Devotion", "PlayerDevotion_Framework.esp");
const MUTAGEN_BRIDGE = path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe");

const PIETY_SINKS = /\b(AwardCuratedSignal|AwardPiety|ApplyDeityReaction|ApplyQuestReactionPiety|Record[A-Za-z]+Scaled|AddCommitmentSignal)\b/;

// Record EditorIDs use short Daedric stems; contract rows often carry the full
// theonym. Normalize so 'PDV_Msg_Daedric_Sheogorath_*' resolves the shipped
// 'PDV_Msg_Daedric_Sheo_*' (same alias trap that dropped Clavicus cells).
const DAEDRIC_STEM = [
  ["Hermaeus_Mora", "Mora"], ["Hermaeus", "Mora"], ["Sheogorath", "Sheo"],
  ["Mehrunes_Dagon", "Dagon"], ["Mehrunes", "Dagon"], ["Molag_Bal", "Molag"],
  ["Clavicus_Vile", "Vile"], ["Clavicus", "Vile"],
];
// Spec JSONs name state tracks PDV_State_<X>; the shipped ESP/scripts use
// PDV_StateTrack_<X>. Treat as the same record (drift, not absence).
function aliasCandidates(id) {
  const out = new Set([id]);
  for (const [full, stem] of DAEDRIC_STEM) {
    if (id.includes(full)) out.add(id.replaceAll(full, stem));
  }
  for (const v of [...out]) {
    if (v.includes("PDV_State_") && !v.includes("PDV_StateTrack_")) out.add(v.replace("PDV_State_", "PDV_StateTrack_"));
  }
  return [...out];
}

const args = process.argv.slice(2);
const jsonOnly = args.includes("--json");
const skipEsp = args.includes("--skip-esp");

// ---------------------------------------------------------------- csv utils
function parseCsv(text) {
  const rows = [];
  let row = [], cur = "", q = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (q) {
      if (ch === '"') { if (text[i + 1] === '"') { cur += '"'; i++; } else q = false; }
      else cur += ch;
    } else if (ch === '"') q = true;
    else if (ch === ",") { row.push(cur); cur = ""; }
    else if (ch === "\n" || ch === "\r") {
      if (cur !== "" || row.length) { row.push(cur); rows.push(row); row = []; cur = ""; }
      if (ch === "\r" && text[i + 1] === "\n") i++;
    } else cur += ch;
  }
  if (cur !== "" || row.length) { row.push(cur); rows.push(row); }
  return rows;
}

function readCsvObjects(file) {
  if (!fs.existsSync(file)) return null;
  const rows = parseCsv(fs.readFileSync(file, "utf8").replace(/^﻿/, ""));
  const header = rows.shift();
  return rows
    .filter((r) => r.some((f) => f.trim() !== ""))
    .map((r) => Object.fromEntries(header.map((h, i) => [h.trim(), (r[i] ?? "").trim()])));
}

// ------------------------------------------------------------- fact indexes
function buildSourceFacts() {
  const facts = {
    available: fs.existsSync(SOURCE_DIR),
    identifiers: new Set(),       // every Function/Property/ScriptName/const name
    functions: new Map(),         // name -> { script, body }
    signalDefs: new Set(),        // SIGNAL_* constant names defined
    signalCallSites: new Set(),   // SIGNAL_* names appearing OUTSIDE their definition line
    pietyReach: new Map(),        // function name -> bool (reaches a piety sink, depth 2)
  };
  if (!facts.available) return facts;

  const files = fs.readdirSync(SOURCE_DIR).filter((f) => f.toLowerCase().endsWith(".psc"));
  const fnBodies = new Map();
  for (const file of files) {
    const src = fs.readFileSync(path.join(SOURCE_DIR, file), "utf8");
    const scriptName = file.replace(/\.psc$/i, "");
    facts.identifiers.add(scriptName);

    for (const m of src.matchAll(/^\s*(?:[A-Za-z_][\w[\]]*\s+)?Function\s+([A-Za-z_]\w*)\s*\(/gim)) {
      facts.identifiers.add(m[1]);
    }
    for (const m of src.matchAll(/^\s*[A-Za-z_][\w[\]]*\s+Property\s+([A-Za-z_]\w*)/gim)) {
      facts.identifiers.add(m[1]);
    }
    // quoted string literals: StorageUtil keys, track names, state labels
    // (e.g. "PDV_State_BosmerPath" never appears as a declared symbol)
    for (const m of src.matchAll(/"([A-Za-z_][\w.]{2,60})"/g)) {
      facts.identifiers.add(m[1]);
    }
    for (const m of src.matchAll(/\b(SIGNAL_[A-Z0-9_]+)\b/g)) {
      facts.identifiers.add(m[1]);
    }
    for (const m of src.matchAll(/^\s*Int\s+Property\s+(SIGNAL_[A-Z0-9_]+)\s*=/gim)) {
      facts.signalDefs.add(m[1]);
      if (!facts.signalDefScript) facts.signalDefScript = new Map();
      facts.signalDefScript.set(m[1], scriptName);
    }
    // call sites = SIGNAL_ usage that can SEND the signal: any occurrence in
    // a script other than the defining one (cross-script dispatch like
    // AwardCuratedSignal(PDV_Talos, PDV_Talos.SIGNAL_X, ...)), or a same-
    // script line that awards/routes. The defining script's own
    // ScoreCuratedSignal dispatch does NOT count - a signal that is defined
    // and handled but never sent is the Talos-102/103 dead-signal class.
    for (const line of src.split(/\r?\n/)) {
      if (/^\s*Int\s+Property\s+SIGNAL_/i.test(line)) continue;
      const sends = /\b(AwardCuratedSignal|Route[A-Za-z]+|Send[A-Za-z]+)\s*\(/.test(line);
      for (const m of line.matchAll(/\b(SIGNAL_[A-Z0-9_]+)\b/g)) {
        facts.signalUse ??= [];
        facts.signalUse.push({ name: m[1], script: scriptName, sends });
      }
    }
    // function bodies for reachability
    const fnRe = /^\s*(?:[A-Za-z_][\w[\]]*\s+)?Function\s+([A-Za-z_]\w*)\s*\([^)]*\)[\s\S]*?^\s*EndFunction/gim;
    for (const m of src.matchAll(fnRe)) {
      fnBodies.set(m[1], { script: scriptName, body: m[0] });
      facts.functions.set(m[1], { script: scriptName, body: m[0] });
    }
  }

  // resolve dead signals: defined but never sent from outside the defining
  // script (or via a same-script award/route line)
  for (const def of facts.signalDefs) {
    const defScript = facts.signalDefScript?.get(def);
    const sent = (facts.signalUse ?? []).some((u) => u.name === def && (u.script !== defScript || u.sends));
    if (sent) facts.signalCallSites.add(def);
  }

  // piety reachability, depth 2: direct sink, or calls a function that
  // directly hits a sink.
  const direct = new Map();
  for (const [name, f] of fnBodies) direct.set(name, PIETY_SINKS.test(f.body));
  for (const [name, f] of fnBodies) {
    if (direct.get(name)) { facts.pietyReach.set(name, true); continue; }
    let reach = false;
    for (const m of f.body.matchAll(/\b([A-Za-z_]\w*)\s*\(/g)) {
      if (m[1] !== name && direct.get(m[1])) { reach = true; break; }
    }
    facts.pietyReach.set(name, reach);
  }
  return facts;
}

function buildDataFacts() {
  const facts = {
    matrixDeities: new Map(),  // deity -> gain count
    matrixQuests: new Set(),   // editor_id
    faucetDeities: new Map(),  // deity -> [acts]
    faucetCaps: new Map(),     // deity.act -> cap
    partB: new Map(),          // deity name -> profile block text
    stanceNames: new Set(),
    docs: new Map(),           // repo-relative doc path -> exists
  };
  const matrix = readCsvObjects(MATRIX_CSV) ?? [];
  for (const row of matrix) {
    if (row.valence === "+") facts.matrixDeities.set(row.deity, (facts.matrixDeities.get(row.deity) ?? 0) + 1);
    else if (!facts.matrixDeities.has(row.deity)) facts.matrixDeities.set(row.deity, facts.matrixDeities.get(row.deity) ?? 0);
    facts.matrixQuests.add(row.editor_id);
  }
  for (const row of readCsvObjects(FAUCET_CSV) ?? []) {
    if (!facts.faucetDeities.has(row.deity)) facts.faucetDeities.set(row.deity, []);
    facts.faucetDeities.get(row.deity).push(row.act_tag);
    facts.faucetCaps.set(`${row.deity}.${row.act_tag}`, row.anti_farm_cap);
  }
  if (fs.existsSync(MATRIX_DOC)) {
    const doc = fs.readFileSync(MATRIX_DOC, "utf8");
    const partB = doc.split(/^## Part B /m)[1]?.split(/^## Part C /m)[0] ?? "";
    for (const m of partB.matchAll(/^\*\*([^*]+)\*\*([\s\S]*?)(?=^\*\*|^### |^## )/gim)) {
      facts.partB.set(m[1].split(/[—-]/)[0].trim(), m[2]);
      // also index alias halves like "Azurah / Azura"
      for (const half of m[1].split(/[—-]/)[0].split("/")) facts.partB.set(half.trim(), m[2]);
    }
  }
  for (const row of readCsvObjects(STANCE_CSV) ?? []) facts.stanceNames.add(row.WorshipObject);
  for (const row of readCsvObjects(DAEDRIC_CSV) ?? []) facts.stanceNames.add(row.Prince);

  // Native-state map per Prince stem. A Daedric *response* message
  // (PDV_Msg_Daedric_<stem>_Response_<race>) is the transgression/stigma
  // surface for NON-native dabblers; a race that is Native to the Prince
  // worships through the positive patron-deity path (PDV_Deity_<stem>) and
  // correctly has no Daedric stigma response. So a missing response message
  // for a Native race is satisfied-by-design, not a gap. Invariant verified
  // 2026-06-10: across all 16 Princes, missing-message set == Native-race set.
  facts.princeNative = new Map(); // stem(lowercased) -> Set(native races)
  if (fs.existsSync(DAEDRIC_CONTRACTS)) {
    try {
      const princes = JSON.parse(fs.readFileSync(DAEDRIC_CONTRACTS, "utf8")).princes ?? [];
      for (const p of princes) {
        const natives = new Set(Object.entries(p.statesByRace ?? {}).filter(([, s]) => s === "Native").map(([r]) => r));
        facts.princeNative.set((p.stem || "").toLowerCase(), natives);
      }
    } catch { /* leave map empty; rows fall through to normal checks */ }
  }
  return facts;
}

function buildEspFacts() {
  const facts = { available: false, skipped: true, edids: new Set(), reason: "" };
  if (skipEsp) { facts.reason = "--skip-esp"; return facts; }
  if (!fs.existsSync(MUTAGEN_BRIDGE) || !fs.existsSync(PDV_ESP)) {
    facts.reason = "bridge or ESP not found";
    return facts;
  }
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify({ command: "scan", plugins: [PDV_ESP.replace(/\\/g, "/")] }),
    encoding: "utf8",
    timeout: 60_000,
    maxBuffer: 128 * 1024 * 1024,
    windowsHide: true,
  });
  try {
    const payload = JSON.parse((result.stdout || "").trim());
    if (!payload.success) throw new Error(payload.error || "bridge failure");
    for (const rec of payload.plugins?.[0]?.records ?? []) {
      if (rec.edid) facts.edids.add(rec.edid);
    }
    facts.available = true;
    facts.skipped = false;
  } catch (e) {
    facts.reason = `bridge scan failed: ${e.message}`;
  }
  return facts;
}

function buildRuntimeFacts() {
  const facts = new Map(); // race -> verdict line
  if (!fs.existsSync(GATE_LEDGER)) return facts;
  const text = fs.readFileSync(GATE_LEDGER, "utf8");
  const races = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];
  for (const race of races) {
    const m = text.match(new RegExp(`##+[^\\n]*${race}[\\s\\S]{0,800}?[Vv]erdict[^\\n]*?:?\\s*\\**\\s*(Pass|Conditional|Fail)`, ""));
    if (m) facts.set(race, m[1]);
  }
  return facts;
}

// -------------------------------------------------------- row evaluation
const ID_RE = /\b(PDV_[A-Za-z0-9_*]+|SIGNAL_[A-Z0-9_]+|Handle[A-Z]\w+|Route[A-Z]\w+|Sync[A-Z]\w+|Process[A-Z]\w+|Score[A-Z]\w+)\b/g;

// Basenames of the authoring/spec docs themselves, so an extracted token like
// 'PDV_Phase20_RewardRecordContracts' (a JSON filename cited in a requirement)
// is not mistaken for a missing game record.
const DOC_BASENAMES = (() => {
  const set = new Set();
  for (const dir of [path.join(ROOT, "references", "authoring"), path.join(ROOT, "references", "phase4")]) {
    if (!fs.existsSync(dir)) continue;
    for (const f of fs.readdirSync(dir)) set.add(f.replace(/\.[^.]+$/, ""));
  }
  return set;
})();

function extractIdentifiers(row) {
  const text = `${row.requirement} ${row.check_hint ?? ""}`;
  const ids = new Set();
  for (const m of text.matchAll(ID_RE)) {
    if (DOC_BASENAMES.has(m[1])) continue; // doc/spec filename, not a record
    ids.add(m[1]);
  }
  return [...ids];
}

function authorityIsStructured(row) {
  return /\.(json|csv)\b/i.test(row.authority || "");
}

// PDV_ record-type prefixes: these name ESP records, so presence MUST be
// proven in the ESP, not by a source property declaration (a manager can
// declare a Spell Property whose record was never authored - exactly the
// PDV_Bless_Altmer_Orthodox_T2 case). Everything else CamelCase (Sync*,
// Handle*, Route*, Is*, ...) is a Papyrus function/symbol, proven in source.
const RECORD_PREFIX = /^PDV_(SPEL|SPELL|MGEF|Bless|Msg|MESG|Notif|GLO|GLOB|State|StateTrack|RepTrack|Deity|QUST|Quest|ACTI|REFR|FLST|KW|KYWD|Favor|Bless_Daedric|Path)_/i;

function idExists(id, sourceFacts, espFacts, layer) {
  // Route by identifier SHAPE, not the row's single verify_layer label (a row
  // often mixes an ESP record with its Papyrus wiring). Record-shaped -> ESP;
  // function/symbol-shaped -> source. PDV_ names that aren't a known record
  // type fall back to both (e.g. a script/property name).
  const pools = RECORD_PREFIX.test(id)
    ? [espFacts.edids]
    : id.startsWith("PDV_")
      ? [espFacts.edids, sourceFacts.identifiers]
      : [sourceFacts.identifiers];
  for (const cand of aliasCandidates(id)) {
    if (cand.includes("*") || cand.endsWith("_")) {
      // explicit wildcard, or a truncated family name like
      // PDV_Msg_Daedric_Azura_Response_ (the <Race> suffix was not part of
      // the identifier token) - treat as prefix/pattern match
      const pattern = cand.endsWith("_") && !cand.includes("*") ? cand + "*" : cand;
      const re = new RegExp("^" + pattern.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*") + "$", "i");
      if (pools.some((p) => [...p].some((x) => re.test(x)))) return true;
    } else if (pools.some((p) => p.has(cand))) {
      return true;
    }
  }
  return false;
}

function evaluateRow(row, facts) {
  const { sourceFacts, dataFacts, espFacts, runtimeFacts } = facts;

  if (row.tier === "FUTURE") return { verdict: "FUTURE", detail: "1.0/V2 tier; tracked, not gated." };

  if (row.verify_layer === "runtime-status") {
    const v = runtimeFacts.get(row.race);
    return { verdict: "NEEDS-MANUAL", detail: v ? `Gate ledger verdict: ${v} (runtime proof is the user's smoke lane).` : "No gate-ledger verdict found for this race." };
  }

  const ids = extractIdentifiers(row);
  const missing = [];
  const stubs = [];
  const deadSignals = [];
  const nativeByDesign = [];

  // layer-specific structural checks first
  if (row.verify_layer === "data" && row.surface === "part_b_profile") {
    const deity = row.target.split(/[(/]/)[0].trim();
    const block = dataFacts.partB.get(deity) ?? [...dataFacts.partB.entries()].find(([k]) => k.toLowerCase().includes(deity.toLowerCase()))?.[1];
    if (!block) return { verdict: gapKind(row), detail: `No Part B profile block found for '${deity}'.` };
    // verify each tag(intensity) named in the requirement appears in the block
    const missingTags = [];
    for (const m of row.requirement.matchAll(/([a-z_]+:?[a-z_*]*)\((C|S|m)\)/g)) {
      if (!block.includes(m[1])) missingTags.push(`${m[1]}(${m[2]})`);
    }
    if (missingTags.length) return { verdict: gapKind(row), detail: `Part B profile for '${deity}' exists but lacks: ${missingTags.join(", ")}` };
    return { verdict: "PASS", detail: "Part B profile present with all named tags." };
  }

  if (!sourceFacts.available && row.verify_layer === "source") {
    return { verdict: "NEEDS-MANUAL", detail: `Source dir unavailable (${SOURCE_DIR}).` };
  }
  if (espFacts.skipped && row.verify_layer === "esp") {
    return { verdict: "NEEDS-MANUAL", detail: `ESP layer SKIPPED (${espFacts.reason}).` };
  }

  if (!ids.length) {
    return { verdict: "NEEDS-MANUAL", detail: "No machine-checkable identifier extractable from requirement/check_hint." };
  }

  for (const id of ids) {
    if (!idExists(id, sourceFacts, espFacts, row.verify_layer)) {
      // Native-race Daedric response message: correct-by-absence (natives
      // worship via the patron path, not the stigma surface).
      const dm = id.match(/^PDV_Msg_Daedric_([A-Za-z]+)_Response_([A-Za-z]+)$/);
      if (dm) {
        const stem = (DAEDRIC_STEM.find(([full]) => full.replace(/_/g, "") === dm[1])?.[1] ?? dm[1]).toLowerCase();
        if (dataFacts.princeNative.get(stem)?.has(dm[2])) { nativeByDesign.push(id); continue; }
      }
      const near = nearMiss(id, sourceFacts, espFacts);
      missing.push(near ? `${id} (NAMING-DRIFT? found ${near})` : id);
      continue;
    }
    if (/^(Handle|Route)[A-Z]/.test(id) && sourceFacts.functions.has(id) && sourceFacts.pietyReach.get(id) === false) {
      stubs.push(id);
    }
    if (/^SIGNAL_/.test(id) && sourceFacts.signalDefs.has(id) && !sourceFacts.signalCallSites.has(id)) {
      deadSignals.push(id);
    }
  }

  if (missing.length || stubs.length || deadSignals.length) {
    const parts = [];
    if (missing.length) parts.push(`missing: ${missing.join(", ")}`);
    if (stubs.push && stubs.length) parts.push(`TELEMETRY-STUB (no piety sink within depth 2): ${stubs.join(", ")}`);
    if (deadSignals.length) parts.push(`defined-but-never-called: ${deadSignals.join(", ")}`);
    return { verdict: gapKind(row), detail: parts.join(" | ") };
  }
  const designNote = nativeByDesign.length ? ` (${nativeByDesign.length} native-race Daedric response message(s) correctly absent: natives worship via the patron path)` : "";
  return { verdict: "PASS", detail: `All checkable identifiers present${row.verify_layer === "source" ? " and reachability clean" : ""}${designNote}.` };
}

function gapKind(row) {
  return authorityIsStructured(row) ? "GAP" : "GAP-REVIEW";
}

// when an exact id is absent, look for a family member sharing the id's
// trailing segments (e.g. PDV_State_BosmerPath -> PDV_StateTrack_BosmerPath)
// so spec/ESP naming drift reads as drift, not as missing functionality
function nearMiss(id, sourceFacts, espFacts) {
  const tail = id.replace(/\*+$/, "").split("_").filter(Boolean).slice(-2).join("_");
  if (tail.length < 6) return null;
  for (const pool of [espFacts.edids, sourceFacts.identifiers]) {
    for (const x of pool) {
      if (x !== id && x.toLowerCase().includes(tail.toLowerCase())) return x;
    }
  }
  return null;
}

// ------------------------------------------------------------------- main
function main() {
  const contract = readCsvObjects(CONTRACT_CSV);
  if (!contract) throw new Error(`Missing ${CONTRACT_CSV}`);
  const waivers = readCsvObjects(WAIVER_CSV) ?? [];
  const waived = new Map(waivers.map((w) => [w.id, w.reason]));

  const facts = {
    sourceFacts: buildSourceFacts(),
    dataFacts: buildDataFacts(),
    espFacts: buildEspFacts(),
    runtimeFacts: buildRuntimeFacts(),
  };

  const results = [];
  for (const row of contract) {
    let { verdict, detail } = evaluateRow(row, facts);
    if (waived.has(row.id) && verdict !== "PASS") {
      detail = `${detail} [WAIVED: ${waived.get(row.id)}]`;
      verdict = "WAIVED";
    }
    results.push({ ...row, verdict, detail });
  }

  const counts = {};
  for (const r of results) counts[r.verdict] = (counts[r.verdict] ?? 0) + 1;
  const hardGaps = results.filter((r) => r.verdict === "GAP");

  writeLedger(results, counts, facts);

  const summary = {
    status: hardGaps.length ? "FAIL" : "PASS",
    contractRows: contract.length,
    counts,
    espLayer: facts.espFacts.skipped ? `SKIPPED (${facts.espFacts.reason})` : `scanned ${facts.espFacts.edids.size} EditorIDs`,
    sourceLayer: facts.sourceFacts.available ? `indexed ${facts.sourceFacts.functions.size} functions, ${facts.sourceFacts.signalDefs.size} signal consts` : "UNAVAILABLE",
    ledger: path.relative(ROOT, OUT_MD),
  };
  console.log(JSON.stringify(summary, null, 2));
  process.exitCode = hardGaps.length ? 1 : 0;
}

function writeLedger(results, counts, facts) {
  const order = { GAP: 0, "GAP-REVIEW": 1, "NEEDS-MANUAL": 2, WAIVED: 3, FUTURE: 4, PASS: 5 };
  const sorted = [...results].sort((a, b) => (order[a.verdict] ?? 9) - (order[b.verdict] ?? 9) || a.id.localeCompare(b.id));

  const lines = [];
  lines.push("# PDV Completeness Gap Ledger");
  lines.push("");
  lines.push("GENERATED by tools/pdv_completeness_audit.mjs - do not hand-edit.");
  lines.push(`Contract: PDV_BetaContract.csv (${results.length} rows). Gate fails on unwaived GAP only;`);
  lines.push("GAP-REVIEW = authority is prose, identifier may be a proposed name (adjudicate, then either");
  lines.push("fix the build or correct the contract row's check_hint). NEEDS-MANUAL = not machine-checkable.");
  lines.push("");
  lines.push(`Verdicts: ${Object.entries(counts).map(([k, v]) => `${k}=${v}`).join(" | ")}`);
  lines.push(`Layers: source=${facts.sourceFacts.available ? "live" : "UNAVAILABLE"}; esp=${facts.espFacts.skipped ? "SKIPPED (" + facts.espFacts.reason + ")" : facts.espFacts.edids.size + " EditorIDs"}; runtime=read-only from gate ledger.`);
  lines.push("");
  for (const verdict of Object.keys(order)) {
    const rows = sorted.filter((r) => r.verdict === verdict);
    if (!rows.length) continue;
    lines.push(`## ${verdict} (${rows.length})`);
    lines.push("");
    if (verdict === "PASS") {
      lines.push("(passing rows listed in the CSV only)");
      lines.push("");
      continue;
    }
    lines.push("| ID | Surface | Race | Target | Detail | Authority |");
    lines.push("|---|---|---|---|---|---|");
    for (const r of rows) {
      lines.push(`| ${r.id} | ${r.surface} | ${r.race} | ${r.target} | ${r.detail.replace(/\|/g, "/")} | ${r.authority.replace(/\|/g, "/").slice(0, 90)} |`);
    }
    lines.push("");
  }
  fs.writeFileSync(OUT_MD, lines.join("\n") + "\n", "utf8");

  const cols = ["id", "surface", "race", "target", "tier", "verify_layer", "verdict", "detail", "requirement", "authority"];
  const esc = (v) => (/[",\n\r]/.test(String(v ?? "")) ? `"${String(v ?? "").replace(/"/g, '""')}"` : String(v ?? ""));
  const csv = [cols.join(","), ...sorted.map((r) => cols.map((c) => esc(r[c])).join(","))];
  fs.writeFileSync(OUT_CSV, csv.join("\r\n") + "\r\n", "utf8");
}

main();
