#!/usr/bin/env node
/*
 * Paired-deity equity audit for the PDV quest-reaction matrix and signal channels.
 *
 * PDV keeps culturally-paired aspects of one divine as SEPARATE deity records
 * (Kyne != Kynareth, Akatosh != Auri-El != Alkosh, Arkay != Tu'whacca != Xarxes)
 * but the locked theology says same-coin gods share credit for the same acts
 * (precedent: T03 Gildergreen credits Kynareth C / Y'ffre S / Khenarthi m).
 * This tool audits that equity and gates regressions:
 *
 *   1. Per-deity coverage counts from a quote-aware parse of Full.csv.
 *   2. Cluster gap enumeration: cells where member A is credited and a paired
 *      member B (per the cluster's mirror policy) is not.
 *   3. Deity-name resolution: every matrix deity string must resolve through
 *      GetQuestReactionDeity (baked DeityName VMAD values + Daedric-path names
 *      + IsQuestReactionNameMatch aliases) or it is SILENTLY DROPPED at runtime.
 *   4. Stance-matrix presence (record-stance fallback flagged, not failed).
 *   5. Part B values-profile presence for all record deities (the Kyne-class
 *      root cause: no Part B profile -> invisible to every tranche pass).
 *   6. Deity x channel cross-tab (matrix / Part D faucets / ambient ScoreAction
 *      / curated signals / substrate) with a native-track-as-parity verdict.
 *
 * Read-only analysis. Emits references/authoring/PDV_PairedDeityEquityAudit.md
 * and .csv. Exit 1 on name-resolution errors or unwaived cluster gaps.
 * Waivers: references/authoring/PDV_PairedEquityWaivers.csv
 *   (cluster,editor_id,outcome_stage,deity,reason) — one row per accepted gap.
 *
 * Cluster table derivation sources (do not extend without rereading these):
 *   - references/phase4/PDV_StanceMatrix.csv DomainCluster column
 *   - references/skyrim-deity-reference.jsx cross-cultural equivalence notes
 *   - references/PDV_RaceArchitecture_DesignReference.md
 *   - references/authoring/PDV_Phase2_DeityRoster_and_ArchitectureRulings.md (R1-R8)
 *   - PDV_Architecture_v3.md section 3.3 (Lorkhan-family do-not-collapse LOCK)
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const ARGS = process.argv.slice(2);
function argValue(name) {
  const index = ARGS.indexOf(name);
  return index >= 0 ? ARGS[index + 1] : null;
}
function argValues(name) {
  const values = [];
  for (let index = 0; index < ARGS.length; index += 1) {
    if (ARGS[index] === name) values.push(ARGS[index + 1]);
  }
  return values;
}
const MATRIX_CSV = path.resolve(ROOT, argValue("--matrix") ?? "references/authoring/PDV_QuestReactionMatrix_Full.csv");
const APPEND_MATRIX_CSVS = argValues("--append-matrix").map((file) => path.resolve(ROOT, file));
const NO_WRITE = ARGS.includes("--no-write");
const FAUCET_CSV = path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv");
const STANCE_CSV = path.join(ROOT, "references", "phase4", "PDV_StanceMatrix.csv");
const DAEDRIC_STANCE_CSV = path.join(ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv");
const MATRIX_DOC = path.join(ROOT, "references", "authoring", "PDV_QuestReactionMatrix.md");
const WAIVER_CSV = path.join(ROOT, "references", "authoring", "PDV_PairedEquityWaivers.csv");
const OUT_MD = path.join(ROOT, "references", "authoring", "PDV_PairedDeityEquityAudit.md");
const OUT_CSV = path.join(ROOT, "references", "authoring", "PDV_PairedDeityEquityAudit.csv");
const DEITY_SCRIPT_DIR = "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source";

// The 33 record deities (PDV_Deity_*.psc / PDV_FLST_AllDeities). matrixName is
// the literal the quest-reaction CSVs use; bakedName is the VMAD DeityName the
// record carries at runtime (from the PDV_*RewardRecords.spec.json files plus
// the ManagerQuest Ensure*RuntimeIdentity migrations). Where they differ the
// name-resolution check reports how the cell actually resolves.
const RECORD_DEITIES = [
  { matrixName: "Akatosh", bakedName: "Akatosh", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Alkosh", bakedName: "Alkosh", races: ["Khajiit"] },
  { matrixName: "Arkay", bakedName: "Arkay", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Auri-El", bakedName: "Auri-El", races: ["Altmer"] },
  { matrixName: "Azura", bakedName: "Azurah", races: ["Khajiit", "Dunmer"], note: "record baked as Azurah (Khajiit creator); matrix 'Azura' resolves via the Daedric path record instead" },
  { matrixName: "Baan Dar", bakedName: "Baan Dar", races: ["Khajiit", "Bosmer"] },
  { matrixName: "Boethiah", bakedName: "Boethiah", races: ["Dunmer"] },
  { matrixName: "Dibella", bakedName: "Dibella", races: ["Imperial", "Nord"] },
  { matrixName: "Hist", bakedName: "The Hist", races: ["Argonian"], note: "substrate-by-design; record baked as 'The Hist'" },
  { matrixName: "HoonDing", bakedName: "HoonDing", races: ["Redguard"] },
  { matrixName: "Julianos", bakedName: "Julianos", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Khenarthi", bakedName: "Khenarthi", races: ["Khajiit"] },
  { matrixName: "Kynareth", bakedName: "Kynareth", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Kyne", bakedName: "Kyne", races: ["Nord"] },
  { matrixName: "Leki", bakedName: "Leki", races: ["Redguard"] },
  { matrixName: "Magnus", bakedName: "Magnus", races: ["Altmer"] },
  { matrixName: "Malacath", bakedName: "Malacath", races: ["Orc"] },
  { matrixName: "Mara", bakedName: "Mara", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Mephala", bakedName: "Mephala", races: ["Dunmer"] },
  { matrixName: "Rajhin", bakedName: "Rajhin", races: ["Khajiit"] },
  { matrixName: "Shor", bakedName: "Shor", races: ["Nord"] },
  { matrixName: "Sithis", bakedName: "Sithis", races: ["Argonian"] },
  { matrixName: "Stendarr", bakedName: "Stendarr", races: ["Imperial", "Nord", "Breton"] },
  { matrixName: "Stuhn", bakedName: "Stuhn", races: ["Nord"] },
  { matrixName: "Syrabane", bakedName: "Syrabane", races: ["Altmer"] },
  { matrixName: "Talos", bakedName: "Talos", races: ["Nord", "Imperial"] },
  { matrixName: "Trinimac", bakedName: "Trinimac", races: ["Orc", "Altmer"], note: "pressure-only by design (R5); thin coverage intentional" },
  { matrixName: "Tsun", bakedName: "Tsun", races: ["Nord"] },
  { matrixName: "Tu'whacca", bakedName: "Tu'whacca", races: ["Redguard"] },
  { matrixName: "Xarxes", bakedName: "Xarxes", races: ["Altmer"] },
  { matrixName: "Y'ffre", bakedName: "Y'ffre", races: ["Bosmer"] },
  { matrixName: "Z'en", bakedName: "Z'en", races: ["Bosmer"] },
  { matrixName: "Zenithar", bakedName: "Zenithar", races: ["Imperial", "Nord", "Breton"] },
];

// Daedric path records (PDV_DaedricPath_*) carry their own DeityName values;
// GetQuestReactionDeity falls back to them via IsQuestReactionNameMatch.
const DAEDRIC_PATH_NAMES = new Set([
  "Azura", "Boethiah", "Vaermina", "Meridia", "Molag", "Mephala", "Hircine",
  "Malacath", "Dagon", "Sheo", "Namira", "Sanguine", "Vile", "Mora",
  "Nocturnal", "Peryite",
]);
// IsQuestReactionNameMatch(recordName, requestedName) special cases.
const NAME_MATCH_ALIASES = new Map([
  ["Hermaeus Mora", "Mora"],
  ["Clavicus Vile", "Vile"],
  ["Mehrunes Dagon", "Dagon"],
  ["Molag Bal", "Molag"],
  ["Sheogorath", "Sheo"],
]);
// pdv_quest_matrix_compile.mjs DEITY_ALIASES (stance-key normalization).
const COMPILE_ALIASES = new Map([
  ["Azura / Azurah", "Azura"],
  ["Boethiah / Boethra", "Boethiah"],
  ["Malacath / Mauloch", "Malacath"],
  ["Mephala / Mafala", "Mephala"],
  ["Hermaeus Mora / Hermorah", "Hermaeus Mora"],
]);
// Matrix names whose deity is a Daedric Prince row in PDV_DaedricRacePrinceMatrix.csv.
const PRINCE_NAMES = new Set([
  "Azura", "Boethiah", "Mephala", "Malacath", "Meridia", "Hircine", "Molag Bal",
  "Nocturnal", "Hermaeus Mora", "Mehrunes Dagon", "Sheogorath", "Namira",
  "Sanguine", "Clavicus", "Clavicus Vile", "Peryite", "Vaermina",
]);

// Mirror policies:
//   full       — every credited cell of one member is a candidate for every other member.
//   tag-scoped — only cells whose act_tags intersect `tags` are candidates.
//   document   — no cells proposed; section is narrative (intentional asymmetry / locked / substrate).
const CLUSTERS = [
  {
    id: "sky_storm_nature",
    title: "Sky / storm / nature (Kyne, Kynareth)",
    policy: "full",
    members: ["Kyne", "Kynareth"],
    adjuncts: [
      { name: "Khenarthi", tags: ["honor_the_wild"] },
      { name: "Y'ffre", tags: ["honor_the_wild", "defile_nature"] },
    ],
    rationale: "Same goddess, Nord vs Imperial framing (Phase 2 ruling R4 note: distinct records, Nord may focus either).",
  },
  {
    id: "time_dragon",
    title: "Time / dragon (Akatosh, Auri-El, Alkosh)",
    policy: "tag-scoped",
    members: ["Akatosh", "Auri-El", "Alkosh"],
    tags: ["kill_honorable_combat", "serve_empire_order", "keep_oath", "sow_chaos_madness", "uphold_law_justice"],
    rationale: "Akatosh cluster (deity reference: Auri-El and Alkosh are cultural faces of the time-dragon). Dragon-kill beats must reach all three.",
  },
  {
    id: "death_order",
    title: "Death order (Arkay, Tu'whacca, Xarxes)",
    policy: "tag-scoped",
    members: ["Arkay", "Tu'whacca", "Xarxes"],
    tags: ["honor_the_dead", "desecrate_the_dead", "slay_undead", "necromancy", "cure_undeath", "embrace_vampirism"],
    adjuncts: [{ name: "Khenarthi", tags: ["honor_the_dead"] }],
    rationale: "All three keep the dead in order: Arkay the cycle, Tu'whacca the Far Shores soul-duty, Xarxes the ledger of ancestry. Xarxes scoped further by his Part B profile (record/ancestry, not undead-slaying).",
  },
  {
    id: "labor_commerce",
    title: "Labor / commerce (Zenithar, Z'en)",
    policy: "tag-scoped",
    members: ["Zenithar", "Z'en"],
    tags: ["honest_labor_trade", "master_craft_forge", "exploit_cheat", "theft_burglary"],
    rationale: "Z'en is the Bosmeri toil/debt face of Zenithar's space (separate records; Z'en framing is debt and proportionate redress).",
  },
  {
    id: "mercy_war",
    title: "Mercy in war (Stendarr, Stuhn)",
    policy: "tag-scoped",
    members: ["Stendarr", "Stuhn"],
    tags: ["mercy_spare", "kill_the_helpless"],
    rationale: "Stuhn is the Nord shield-thane of ransom and mercy-to-the-yielding; only Stendarr's mercy-in-combat lane mirrors, NOT his 30-cell vigil breadth.",
  },
  {
    id: "trickster_thief",
    title: "Trickster / thief (Nocturnal, Rajhin, Baan Dar)",
    policy: "tag-scoped",
    members: ["Nocturnal", "Rajhin", "Baan Dar"],
    tags: ["theft_burglary", "deceit"],
    rationale: "Rajhin is THE Khajiit thief-god and Baan Dar the pariah trickster; Thieves Guild beats crediting Nocturnal alone starve both. Scope to artful-theft/deceit tags; Nightingale oath cells stay Nocturnal-only.",
  },
  {
    id: "love_marriage",
    title: "Love / marriage (Mara, Dibella)",
    policy: "tag-scoped",
    members: ["Mara", "Dibella"],
    tags: ["marriage_family"],
    rationale: "Part D faucet doc: 'Dibella shares marriage with Mara'. Only the marriage_family tag mirrors; Mara's charity/heal lanes do not.",
  },
  {
    id: "knowledge_scribe",
    title: "Knowledge / scribe (Julianos, Magnus, Xarxes)",
    policy: "tag-scoped",
    members: ["Julianos", "Magnus", "Xarxes"],
    tags: ["disciplined_study"],
    rationale: "Shared disciplined-study lane only (College beats). reckless_magic/forbidden_knowledge stay per-profile (their valences differ).",
  },
  {
    id: "make_way_war",
    title: "Make-way / struggle (Talos, HoonDing)",
    policy: "tag-scoped",
    members: ["Talos", "HoonDing"],
    tags: ["prove_by_struggle"],
    rationale: "Lore pairing (Redguards read Tiber Septim as a HoonDing incarnation). HoonDing is rare/milestone by design (weekly-cap designNote) — candidates need a strong impossible-odds reading; expect most to be waived.",
  },
  {
    id: "hunt_ethics",
    title: "Hunt ethics (Hircine, Kyne, Y'ffre)",
    policy: "tag-scoped",
    members: ["Hircine", "Kyne", "Y'ffre"],
    tags: ["the_hunt"],
    rationale: "the_hunt currently exists only on Hircine's DA05 rows; Kyne (Sacred Trials, respectful hunt) and Y'ffre (Pact hunt) own the same act with different theology.",
  },
  {
    id: "trinimac_malacath",
    title: "Trinimac / Malacath",
    policy: "document",
    members: ["Trinimac", "Malacath"],
    rationale: "One entity, corruption pair, but asymmetry is INTENTIONAL: Trinimac is pressure-only (R5, no steady reward lane). Do not mirror Malacath's cells.",
  },
  {
    id: "lorkhan_family",
    title: "Shor / Lorkhaj / Sep / Lorkhan",
    policy: "document",
    members: ["Shor"],
    rationale: "LOCKED do-not-collapse (PDV_Architecture_v3.md section 3.3); Sep/Lorkhaj/Lorkhan have no records. Shor's 25 cells stand alone.",
  },
  {
    id: "substrate",
    title: "Substrate-by-design (Hist, Sithis, Khenarthi, Azura/Azurah)",
    policy: "document",
    members: ["Hist", "Sithis", "Khenarthi"],
    rationale: "Parity is carried by always-on substrates (Argonian Hist maintenance, Khajiit lunar/road), not quest cells (native-track-as-parity model).",
  },
];

// Channels other than the quest matrix, per the Phase 18/20 manager audit.
const SUBSTRATE_DEITIES = new Map([
  ["Hist", "Argonian Hist substrate (maintenance/People/Void handlers double-route AwardCuratedSignal)"],
  ["Sithis", "Argonian Void threshold (gated on IsVoidFullyActive)"],
  ["Khenarthi", "Khajiit lunar substrate road-home cadence (+ focused emphasis)"],
  ["Azura", "Khajiit lunar substrate moon observance (as Azurah) + Dunmer Reclamation foreground"],
  ["Y'ffre", "Bosmer path track (Old Contract / Living Story pulses, Green Pact violation)"],
  ["Z'en", "Bosmer Exchange path pulses"],
  ["Baan Dar", "Bosmer Bandit Road path pulses + Khajiit focus movement"],
  ["Malacath", "Orc life-mode track"],
  ["Boethiah", "Dunmer Reclamation foreground"],
  ["Mephala", "Dunmer Reclamation foreground"],
  ["Rajhin", "Khajiit focus movement"],
  ["Alkosh", "Khajiit focus movement"],
]);

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cur = "";
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"') {
        if (text[i + 1] === '"') { cur += '"'; i++; } else { quoted = false; }
      } else { cur += ch; }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === ",") {
      row.push(cur); cur = "";
    } else if (ch === "\n" || ch === "\r") {
      if (cur !== "" || row.length) { row.push(cur); rows.push(row); row = []; cur = ""; }
      if (ch === "\r" && text[i + 1] === "\n") i++;
    } else { cur += ch; }
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

function main() {
  const matrix = readCsvObjects(MATRIX_CSV);
  if (!matrix) throw new Error(`Missing ${MATRIX_CSV}`);
  for (const appendFile of APPEND_MATRIX_CSVS) {
    const rows = readCsvObjects(appendFile);
    if (!rows) throw new Error(`Missing ${appendFile}`);
    matrix.push(...rows);
  }
  const faucets = readCsvObjects(FAUCET_CSV) ?? [];
  const stanceRows = readCsvObjects(STANCE_CSV) ?? [];
  const daedricRows = readCsvObjects(DAEDRIC_STANCE_CSV) ?? [];
  const waivers = readCsvObjects(WAIVER_CSV) ?? [];
  const doc = fs.existsSync(MATRIX_DOC) ? fs.readFileSync(MATRIX_DOC, "utf8") : "";

  const errors = [];
  const warnings = [];

  // ---- 1. Per-deity coverage counts ----------------------------------------
  const counts = new Map();
  for (const row of matrix) {
    const d = row.deity;
    if (!counts.has(d)) counts.set(d, { gain: 0, gainMs: 0, loss: 0, lossMs: 0 });
    const c = counts.get(d);
    if (row.valence === "+") { c.gain++; if (row.magnitude === "milestone") c.gainMs++; }
    else { c.loss++; if (row.magnitude === "milestone") c.lossMs++; }
  }

  // ---- 3. Name resolution ---------------------------------------------------
  const bakedNames = new Set(RECORD_DEITIES.map((d) => d.bakedName));
  const nameRows = [];
  for (const name of new Set(matrix.map((r) => r.deity))) {
    const normalized = COMPILE_ALIASES.get(name) ?? name;
    let resolution = "";
    if (bakedNames.has(normalized)) {
      resolution = "record (PDV_FLST_AllDeities)";
    } else if (DAEDRIC_PATH_NAMES.has(normalized)) {
      resolution = "daedric path (PDV_FLST_DaedricPaths_All)";
    } else if (DAEDRIC_PATH_NAMES.has(NAME_MATCH_ALIASES.get(normalized) ?? "")) {
      resolution = `daedric path via IsQuestReactionNameMatch (${NAME_MATCH_ALIASES.get(normalized)})`;
    } else {
      const record = RECORD_DEITIES.find((d) => d.matrixName === normalized);
      if (record && record.bakedName !== normalized) {
        resolution = `MISMATCH: record baked as '${record.bakedName}'`;
        errors.push(`Matrix deity '${name}' does not resolve: record DeityName is '${record.bakedName}'. Cells are silently dropped by ApplyDeityReaction.`);
      } else {
        resolution = "UNRESOLVED";
        errors.push(`Matrix deity '${name}' resolves to no record or daedric path. Cells are silently dropped by ApplyDeityReaction.`);
      }
    }
    nameRows.push({ name, resolution });
  }
  // Informational: matrix 'Azura' resolves to the Daedric PATH record because
  // the shared deity record is baked 'Azurah'. Flag for review, not failure.
  const azura = RECORD_DEITIES.find((d) => d.matrixName === "Azura");
  if (azura && counts.has("Azura")) {
    warnings.push("Matrix 'Azura' cells route to PDV_DaedricPath_Azura (path DeityName 'Azura'), NOT the shared Aedric-style record (baked 'Azurah'). Review whether quest piety should land on the record instead.");
  }

  // ---- 4. Stance presence ---------------------------------------------------
  const stanceNames = new Set(stanceRows.map((r) => COMPILE_ALIASES.get(r.WorshipObject) ?? r.WorshipObject));
  const princeStance = new Set(daedricRows.map((r) => COMPILE_ALIASES.get(r.Prince) ?? r.Prince));
  const stanceGaps = [];
  for (const name of new Set(matrix.map((r) => r.deity))) {
    const n = name === "Clavicus" ? "Clavicus Vile" : name;
    if (!stanceNames.has(n) && !princeStance.has(n)) {
      stanceGaps.push(name);
      warnings.push(`'${name}' has no PDV_StanceMatrix/DaedricRacePrinceMatrix row; runtime falls back to the deity record's baked stance ints.`);
    }
  }

  // ---- 5. Part B profile presence -------------------------------------------
  const partB = doc.split(/^## Part B /m)[1]?.split(/^## Part C /m)[0] ?? "";
  const profileGaps = [];
  for (const d of RECORD_DEITIES) {
    const probes = [d.matrixName, d.bakedName, d.matrixName.replace("'", "")];
    if (d.matrixName === "Azura") probes.push("Azurah");
    const present = probes.some((p) => partB.includes(`**${p}`) || partB.includes(p + " **") || new RegExp(`\\*\\*[^*]*${p.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}`).test(partB));
    if (!present) {
      profileGaps.push(d.matrixName);
      errors.push(`Record deity '${d.matrixName}' has NO Part B values-profile in PDV_QuestReactionMatrix.md — invisible to every classification pass (the Kyne-class root cause).`);
    }
  }

  // ---- 2. Cluster gap enumeration -------------------------------------------
  const waived = new Set(waivers.map((w) => `${w.cluster}|${w.editor_id}|${w.outcome_stage}|${w.deity}`));
  const cells = new Map(); // quest|stage -> rows
  for (const row of matrix) {
    const key = `${row.editor_id}|${row.outcome_stage}`;
    if (!cells.has(key)) cells.set(key, []);
    cells.get(key).push(row);
  }

  const gapRows = [];
  for (const cluster of CLUSTERS) {
    if (cluster.policy === "document") continue;
    const participants = [
      ...cluster.members.map((m) => ({ name: m, tags: cluster.tags ?? null })),
      ...(cluster.adjuncts ?? []).map((a) => ({ name: a.name, tags: a.tags })),
    ];
    for (const [key, rows] of cells) {
      const present = new Map(rows.filter((r) => participants.some((p) => p.name === r.deity)).map((r) => [r.deity, r]));
      if (present.size === 0) continue;
      const cellTags = rows.flatMap((r) => r.act_tags.split(",").map((t) => t.trim()));
      for (const p of participants) {
        if (present.has(p.name)) continue;
        // tag scope: cluster-level for members, per-adjunct for adjuncts
        const scope = p.tags;
        if (scope && !cellTags.some((t) => scope.some((s) => t === s || t.startsWith(s + ":")))) continue;
        // members trigger on any member presence; adjuncts only when a core member is present
        const anchor = rows.find((r) => cluster.members.includes(r.deity));
        if (!anchor) continue;
        const [editorId, stage] = key.split("|");
        const wkey = `${cluster.id}|${editorId}|${stage}|${p.name}`;
        gapRows.push({
          cluster: cluster.id,
          editor_id: editorId,
          outcome_stage: stage,
          quest_name: anchor.quest_name,
          act_tags: anchor.act_tags,
          credited: [...present.keys()].map((n) => `${n}(${present.get(n).valence}${present.get(n).intensity}/${present.get(n).magnitude})`).join(" "),
          missing: p.name,
          waived: waived.has(wkey) ? "waived" : "",
        });
      }
    }
  }
  const openGaps = gapRows.filter((g) => !g.waived);

  // ---- 6. Channel cross-tab ---------------------------------------------------
  const faucetCounts = new Map();
  for (const f of faucets) {
    faucetCounts.set(f.deity, (faucetCounts.get(f.deity) ?? 0) + 1);
  }
  const channelRows = [];
  for (const d of RECORD_DEITIES) {
    const c = counts.get(d.matrixName) ?? { gain: 0, gainMs: 0, loss: 0, lossMs: 0 };
    let ambient = "";
    let curated = "";
    const scriptFile = path.join(DEITY_SCRIPT_DIR, `PDV_Deity_${d.matrixName.replace(/['\- ]/g, "")}.psc`);
    const altScript = path.join(DEITY_SCRIPT_DIR, `PDV_Deity_${d.bakedName.replace(/^The /, "").replace(/['\- ]/g, "")}.psc`);
    const file = fs.existsSync(scriptFile) ? scriptFile : (fs.existsSync(altScript) ? altScript : null);
    if (file) {
      const src = fs.readFileSync(file, "utf8");
      ambient = /Function ScoreAction|ScoreRepeatableAction/.test(src) ? "yes" : "";
      curated = /Function ScoreCuratedSignal|SIGNAL_/.test(src) ? "yes" : "";
    } else {
      warnings.push(`No deity script found for ${d.matrixName} under ${DEITY_SCRIPT_DIR} (looked for ${path.basename(scriptFile)})`);
    }
    const substrate = SUBSTRATE_DEITIES.get(d.matrixName) ?? "";
    const faucetCount = faucetCounts.get(d.matrixName) ?? 0;
    const hasAccess = c.gain > 0 || faucetCount > 0 || ambient || curated || substrate;
    channelRows.push({
      deity: d.matrixName,
      races: d.races.join("/"),
      matrixGain: `${c.gain}(${c.gainMs}ms)`,
      matrixLoss: `${c.loss}(${c.lossMs}ms)`,
      faucets: faucetCount,
      ambient: ambient || "-",
      curated: curated || "-",
      substrate: substrate ? "yes" : "-",
      verdict: hasAccess ? "OK" : "NO POSITIVE CHANNEL",
      note: d.note ?? "",
    });
    if (!hasAccess) errors.push(`'${d.matrixName}' has NO positive signal channel at all (no matrix gains, faucets, ambient, curated, or substrate).`);
  }

  // ---- Emit ---------------------------------------------------------------
  if (!NO_WRITE) {
    writeMd({ counts, nameRows, stanceGaps, profileGaps, gapRows, openGaps, channelRows, errors, warnings, waivers });
    writeCsv(gapRows);
  }

  const summary = {
    status: errors.length || openGaps.length ? "FAIL" : "PASS",
    matrixCells: matrix.length,
    recordDeities: RECORD_DEITIES.length,
    partBProfileGaps: profileGaps,
    nameErrors: errors.filter((e) => e.includes("silently dropped")).length,
    clusterGapsOpen: openGaps.length,
    clusterGapsWaived: gapRows.length - openGaps.length,
    openGapDetails: ARGS.includes("--gap-details") ? openGaps : undefined,
    warnings: warnings.length,
    matrixSources: [MATRIX_CSV, ...APPEND_MATRIX_CSVS].map((file) => path.relative(ROOT, file)),
    report: NO_WRITE ? null : path.relative(ROOT, OUT_MD),
  };
  console.log(JSON.stringify(summary, null, 2));
  if (errors.length) {
    for (const e of errors) console.error("ERROR: " + e);
  }
  process.exitCode = errors.length || openGaps.length ? 1 : 0;
}

function mdTable(headers, rows) {
  return [
    `| ${headers.join(" | ")} |`,
    `|${headers.map(() => "---").join("|")}|`,
    ...rows.map((r) => `| ${r.join(" | ")} |`),
  ].join("\n");
}

function writeMd(ctx) {
  const { counts, nameRows, stanceGaps, profileGaps, gapRows, openGaps, channelRows, errors, warnings } = ctx;
  const lines = [];
  lines.push("# PDV Paired-Deity Equity Audit");
  lines.push("");
  lines.push(`GENERATED by tools/pdv_paired_equity_audit.mjs — do not hand-edit. Re-run after any tranche/faucet/stance change.`);
  lines.push("");
  lines.push(`Status: ${errors.length || openGaps.length ? "FAIL" : "PASS"} | open cluster gaps: ${openGaps.length} | waived: ${gapRows.length - openGaps.length} | errors: ${errors.length} | warnings: ${warnings.length}`);
  lines.push("");
  lines.push("Equity model: native-track-as-parity. The goal is NOT identical cell counts;");
  lines.push("it is (a) every record deity has adequate total signal access for its");
  lines.push("worshipping race(s) through SOME channel, and (b) same-coin gods are never");
  lines.push("asymmetrically credited for the SAME act (T03 Gildergreen precedent).");
  lines.push("");

  lines.push("## 1. Per-deity matrix coverage (record deities)");
  lines.push("");
  lines.push(mdTable(
    ["Deity", "Races", "Gain (milestones)", "Loss (milestones)", "Faucets", "Ambient", "Curated", "Substrate", "Verdict"],
    channelRows.map((r) => [r.deity, r.races, r.matrixGain, r.matrixLoss, r.faucets, r.ambient, r.curated, r.substrate, r.verdict + (r.note ? ` -- ${r.note}` : "")]),
  ));
  lines.push("");

  lines.push("## 2. Cluster gaps");
  lines.push("");
  for (const cluster of CLUSTERS) {
    const rows = gapRows.filter((g) => g.cluster === cluster.id);
    lines.push(`### ${cluster.title} [${cluster.policy}]`);
    lines.push("");
    lines.push(cluster.rationale);
    lines.push("");
    if (cluster.policy === "document") {
      lines.push("Document-only cluster: no cells proposed.");
    } else if (!rows.length) {
      lines.push("No gaps.");
    } else {
      lines.push(mdTable(
        ["Quest", "Stage", "Tags", "Credited", "Missing", "Waived"],
        rows.map((g) => [`${g.editor_id} (${g.quest_name})`, g.outcome_stage, g.act_tags, g.credited, g.missing, g.waived || "open"]),
      ));
    }
    lines.push("");
  }

  lines.push("## 3. Deity-name resolution (silent-drop gate)");
  lines.push("");
  lines.push(mdTable(["Matrix literal", "Resolves via"], nameRows.map((n) => [n.name, n.resolution])));
  lines.push("");

  lines.push("## 4. Stance-matrix presence");
  lines.push("");
  lines.push(stanceGaps.length ? `Record-stance fallback (no CSV row): ${stanceGaps.join(", ")}` : "All matrix deities present in stance CSVs.");
  lines.push("");

  lines.push("## 5. Part B values-profile presence");
  lines.push("");
  lines.push(profileGaps.length ? `MISSING Part B profiles: ${profileGaps.join(", ")} — these deities are invisible to every quest classification pass until profiled.` : "All 32 record deities have Part B profiles.");
  lines.push("");

  lines.push("## 6. Non-matrix channel notes");
  lines.push("");
  lines.push("- Ambient ScoreAction faucets (Kyne storm/shout/kill, Talos shout/defiance, Shor honorable-kill) intentionally favor the Nord Old Ways lane; counterparts are balanced by temple quests + matrix cells, not by cloning ambient hooks (native-track-as-parity).");
  lines.push("- DEFERRED (user decision 2026-06-10): a repeatable Kyne 'respectful hunt' Part D-style faucet. If ever built it MUST carry an anti_farm_cap (1/dawn) per the anti-farm requirement.");
  lines.push("- Part D faucets stay thin-Daedra+Dibella/Mora-only by design; Aedric counterparts are served by quests/temple favor.");
  lines.push("");

  if (warnings.length) {
    lines.push("## Warnings");
    lines.push("");
    for (const w of warnings) lines.push(`- ${w}`);
    lines.push("");
  }
  if (errors.length) {
    lines.push("## Errors");
    lines.push("");
    for (const e of errors) lines.push(`- ${e}`);
    lines.push("");
  }
  fs.writeFileSync(OUT_MD, lines.join("\n") + "\n", "utf8");
}

function writeCsv(gapRows) {
  const header = "cluster,editor_id,outcome_stage,quest_name,act_tags,credited,missing,waived";
  const esc = (v) => (/[",\n]/.test(v) ? `"${String(v).replace(/"/g, '""')}"` : v);
  const lines = [header, ...gapRows.map((g) => [g.cluster, g.editor_id, g.outcome_stage, g.quest_name, g.act_tags, g.credited, g.missing, g.waived].map(esc).join(","))];
  fs.writeFileSync(OUT_CSV, lines.join("\r\n") + "\r\n", "utf8");
}

main();
