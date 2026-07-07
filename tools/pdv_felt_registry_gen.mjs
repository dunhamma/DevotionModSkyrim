#!/usr/bin/env node
/*
 * PDV Felt-Effect Registry generator.
 *
 * Derives references/authoring/PDV_FeltEffectRegistry.json - the exhaustive
 * enumeration of every declared in-game FELT effect (boons/blessings,
 * prices/dislikes, neglect, substrate/favor, curse) across the 10 race reward
 * specs, the 16 Daedric Prince record contracts, and the two likes/dislikes
 * CSVs - grouped into families (lane x effect class) for the C-FELT-TRACE and
 * C-FELT-FAMILY end-state gates.
 *
 * Positive likes/dislikes CSV rows (sentiment +) are piety economy, proven by
 * the pacing sim and the signal e2e gate; they are NOT felt-effect registry
 * rows. Negative rows ARE (class price): the user's felt gate explicitly
 * includes dislikes.
 *
 * Fail-closed: an effect candidate found under an unmapped spec key is an
 * ORPHAN and generation fails - extend CLASS_BY_KEY deliberately instead.
 *
 * Flags:
 *   --check         regenerate in memory and diff vs the committed registry
 *   --sync-ledger   create/merge PDV_FeltFamilyEvidenceLedger.json slots
 *   --retro-credit  conservatively credit family slots from recorded packet
 *                   evidence (name-match + structural Prince rules)
 *   --self-test     classifier fixture test
 *   --json          JSON summary to stdout
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const AUTH = "references/authoring";
const REGISTRY_REL = `${AUTH}/PDV_FeltEffectRegistry.json`;
const LEDGER_REL = `${AUTH}/PDV_FeltFamilyEvidenceLedger.json`;
const MANUAL_LEDGER_REL = `${AUTH}/PDV_Phase20_ManualEvidenceLedger.json`;
const DAEDRIC_LEDGER_REL = `${AUTH}/PDV_DaedricRuntimeEvidenceLedger.json`;
const RACES = ["Altmer", "Argonian", "Bosmer", "Breton", "Dunmer", "Imperial", "Khajiit", "Nord", "Orc", "Redguard"];
const FAMILY_BAND = [100, 300];

// Prince editorId stems that differ from the canonical CSV/display stems.
const PRINCE_ALIASES = { Dagon: "MehrunesDagon", Molag: "MolagBal", Mora: "HermaeusMora", Sheo: "Sheogorath", Vile: "ClavicusVile", Clavicus: "ClavicusVile" };
// Princes with curse-access lanes (matches pdv_daedric_beta_gate curse slots).
const CURSE_ACCESS_STEMS = ["Hircine", "Molag"];

function normalizeLaneToken(token) {
  const cleaned = String(token).replace(/^Daedric:/, "").replace(/[^A-Za-z0-9]+/g, "");
  if (!cleaned) return token;
  return cleaned[0].toUpperCase() + cleaned.slice(1);
}

function canonicalPrince(stem) {
  const t = normalizeLaneToken(stem);
  return PRINCE_ALIASES[t] ?? t;
}

// Top-level race-spec key -> effect class. Keys listed as "ignore" are walked
// for orphan detection but expected to carry no felt-effect candidates.
const CLASS_BY_KEY = {
  broadState: "boon",
  emphasisRewards: "boon",
  nineDivinesLane: "boon",
  supportSpells: "boon",
  farShoresToken: "boon",
  substrateBoons: "substrate-favor",
  nearWaterContext: "substrate-favor",
  creedViolation: "price",
  creedViolationLoss: "price",
  lorkhanPressure: "price",
  deityTrackModifiers: "price",
  neglect: "neglect",
  curseAndExile: "curse",
};
const IGNORE_KEYS = new Set([
  "schema", "status", "notes", "gate", "gateType", "deityQuests",
  "managerDeityProperties", "ownsNoNewDeities", "ownsNewDeities",
  "deityOwnership", "stateTracks", "stateTrack", "stateRecordAuthoring",
  "stateSurfaces", "greenPactHandling", "doubleRoute", "pace",
  "currencyAndPace", "realHookSources", "requiredContentRows",
  "messageRecords", "rejectedHooks", "v1RecognitionSurface", "budget",
  "balanceInvariants", "rulingCompliance", "ruleCompliance",
  "rulingsCompliance", "judgmentCalls", "authoringPlan",
  "cumulativeRebalanceApplied", "ceilingReviewApplied20260614",
  "emphasisLayerDesignNote", "daedricForks", "reusedDeities",
]);

const flags = new Set(process.argv.slice(2));

function loadJson(rel) { return JSON.parse(fs.readFileSync(path.join(ROOT, rel), "utf8")); }
function sha(rel) {
  try { return crypto.createHash("sha256").update(fs.readFileSync(path.join(ROOT, rel))).digest("hex").slice(0, 16); }
  catch { return "absent"; }
}

function isEffectCandidate(obj, allowMessages) {
  if (obj == null || typeof obj !== "object" || Array.isArray(obj)) return false;
  if (typeof obj.spellEditorId === "string" && obj.spellEditorId.startsWith("PDV_")) return true;
  if (typeof obj.magicEffectEditorId === "string" && obj.magicEffectEditorId.startsWith("PDV_")) return true;
  if (Array.isArray(obj.effects) && obj.effects.some((e) => e && (e.actorValue !== undefined || e.magnitude !== undefined))) return true;
  // Only message-typed fields count: spec "row" fields reuse PDV_Msg_* names
  // as content-manifest row ids without any ESP MESG record behind them.
  if (allowMessages && Object.entries(obj).some(([k, v]) => /message/i.test(k) && typeof v === "string" && /^PDV_M(?:sg|esg|ESG)_/.test(v))) return true;
  return false;
}

// Lane from editorId convention PDV_<Type>_<A>_<B>_<Tier...>: "A-B", else fallback.
function laneFromEditorId(editorId, fallback) {
  const tokens = String(editorId ?? "").split("_").filter(Boolean);
  if (tokens.length >= 4 && tokens[0] === "PDV") {
    const tail = tokens.slice(2).filter((t) => !/^T\d$/i.test(t) && !/^(Seeker|Devoted|Champion)$/i.test(t));
    if (tail.length >= 2) return tail[0] === "Daedric" ? `Daedric-${canonicalPrince(tail[1])}` : `${tail[0]}-${tail[1]}`;
    if (tail.length === 1) return tail[0];
  }
  return fallback;
}

function collectCandidates(node, jsonPath, out, allowMessages = false) {
  if (node == null || typeof node !== "object") return;
  if (Array.isArray(node)) {
    node.forEach((v, i) => collectCandidates(v, `${jsonPath}[${i}]`, out, allowMessages));
    return;
  }
  if (isEffectCandidate(node, allowMessages)) {
    out.push({ node, jsonPath });
    // Do not recurse inside a candidate: nested effects[] rows belong to it.
    return;
  }
  for (const [k, v] of Object.entries(node)) collectCandidates(v, `${jsonPath}.${k}`, out, allowMessages);
}

function buildRegistry() {
  const effects = [];
  const orphans = [];
  const sourceHashes = {};

  // 1) Race reward specs.
  for (const race of RACES) {
    const rel = `${AUTH}/PDV_${race}RewardRecords.spec.json`;
    sourceHashes[rel] = sha(rel);
    const spec = loadJson(rel);
    for (const [key, value] of Object.entries(spec)) {
      const cls = CLASS_BY_KEY[key];
      const allowMessages = cls === "curse" || cls === "neglect" || cls === "price";
      const candidates = [];
      collectCandidates(value, `$.${key}`, candidates, allowMessages);
      if (!candidates.length) continue;
      if (!cls) {
        if (!IGNORE_KEYS.has(key)) orphans.push(`${rel} key '${key}' is unmapped in CLASS_BY_KEY (${candidates.length} candidates)`);
        else orphans.push(`${rel} ignored key '${key}' unexpectedly holds ${candidates.length} effect candidate(s), e.g. ${candidates[0].jsonPath}`);
        continue;
      }
      for (const { node, jsonPath } of candidates) {
        const messageId = Object.entries(node).find(([k, v]) => /message/i.test(k) && typeof v === "string" && /^PDV_M(?:sg|esg|ESG)_/.test(v))?.[1] ?? null;
        const editorId = node.spellEditorId ?? node.magicEffectEditorId ?? (allowMessages ? messageId : null);
        effects.push({
          effectId: editorId ?? `${race}:${jsonPath}`,
          class: cls,
          lane: laneFromEditorId(editorId, `${race}-${key}`),
          race,
          origin: "race-spec",
          declaredIn: `${rel} ${jsonPath}`,
          displayName: node.displayName ?? node.name ?? null,
          tier: node.tier ?? null,
          wiringProperty: node.property ?? node.spellProperty ?? node.messageProperty ?? null,
          expected: {
            espEditorIds: [node.spellEditorId, node.magicEffectEditorId, messageId].filter(Boolean),
            effects: Array.isArray(node.effects)
              ? node.effects.map((e) => ({ actorValue: e.actorValue ?? null, magnitude: e.magnitude ?? null, duration: e.duration ?? null }))
              : [],
          },
        });
      }
    }
  }

  // 2) Daedric Prince record contracts (boons + prices are spell-backed).
  const daedricRel = `${AUTH}/PDV_DaedricPrinceRecordContracts.json`;
  sourceHashes[daedricRel] = sha(daedricRel);
  const daedric = loadJson(daedricRel);
  for (const prince of daedric.princes) {
    const lane = `Daedric-${canonicalPrince(prince.stem)}`;
    for (const [key, cls] of [["boons", "boon"], ["prices", "price"]]) {
      for (const entry of prince[key] ?? []) {
        effects.push({
          effectId: entry.spellEditorId ?? entry.magicEffectEditorId,
          class: cls,
          lane,
          race: null,
          origin: "prince-contract",
          declaredIn: `${daedricRel} princes[${prince.stem}].${key}`,
          displayName: entry.displayName ?? null,
          tier: entry.property ?? null,
          wiringProperty: entry.property ?? null,
          expected: {
            espEditorIds: [entry.spellEditorId, entry.magicEffectEditorId].filter(Boolean),
            effects: (entry.effects ?? []).map((e) => ({ actorValue: e.actorValue ?? null, magnitude: e.magnitude ?? null, duration: e.duration ?? null })),
          },
        });
      }
    }
    if (CURSE_ACCESS_STEMS.some((s) => canonicalPrince(s) === canonicalPrince(prince.stem))) {
      effects.push({
        effectId: `curse-access:${canonicalPrince(prince.stem)}`,
        class: "curse",
        lane,
        race: null,
        origin: "prince-contract-curse",
        declaredIn: `${daedricRel} princes[${prince.stem}] (curse-access lane; slots gated by pdv_daedric_beta_gate curse slots)`,
        displayName: `${prince.displayName} curse-access pressure`,
        tier: null,
        expected: { espEditorIds: [], effects: [] },
      });
    }
  }

  // 3) Likes/dislikes CSVs: negative rows are felt prices (dislikes).
  for (const [rel, laneFor] of [
    [`${AUTH}/PDV_DeityLikesDislikes.csv`, (actor) => normalizeLaneToken(actor)],
    [`${AUTH}/PDV_DeityLikesDislikes_Princes_V2.csv`, (actor) => `Daedric-${canonicalPrince(actor)}`],
  ]) {
    sourceHashes[rel] = sha(rel);
    const lines = fs.readFileSync(path.join(ROOT, rel), "utf8").split(/\r?\n/).filter(Boolean);
    const header = lines[0].split(",");
    const idx = (name) => header.indexOf(name);
    for (const line of lines.slice(1)) {
      const cols = line.split(",");
      const sentiment = cols[idx("sentiment")];
      if (sentiment !== "-") continue;
      const actor = cols[idx("actor")];
      effects.push({
        effectId: `csv:${actor}:${cols[idx("eventId")]}`,
        class: "price",
        lane: laneFor(actor),
        race: null,
        origin: "likes-dislikes-csv",
        declaredIn: `${rel} actor=${actor} eventId=${cols[idx("eventId")]}`,
        displayName: cols[idx("eventName")],
        tier: cols[idx("tier")],
        expected: {
          espEditorIds: [],
          delta: Number(cols[idx("baseDelta")]),
          dailyCap: Number(cols[idx("dailyCap")]),
        },
      });
    }
  }

  // 4) Contextual favor spells: every wired favor is a manager Spell Property
  // (PDV_SPEL_Favor_<Lane>_<Family>). Manager-scan keeps this exhaustive as
  // new favor lanes land without needing a new manifest mapping.
  const managerRel = "live-source/Scripts/Source/PDV__ManagerQuest.psc";
  sourceHashes[managerRel] = sha(managerRel);
  const managerSrc = fs.readFileSync(path.join(ROOT, managerRel), "utf8");
  const favorIds = [...new Set([...managerSrc.matchAll(/Spell Property (PDV_SPEL_Favor_\w+)/g)].map((m) => m[1]))];
  for (const id of favorIds) {
    const tokens = id.split("_"); // PDV SPEL Favor <Lane> <Family...>
    effects.push({
      effectId: id,
      class: "substrate-favor",
      lane: `Favor-${tokens[3]}`,
      race: null,
      origin: "manager-favor-property",
      declaredIn: `${managerRel} Spell Property ${id}`,
      displayName: tokens.slice(4).join(" "),
      tier: null,
      wiringProperty: id,
      expected: { espEditorIds: [id], effects: [] },
    });
  }

  // Families = lane x class.
  const familyMap = new Map();
  for (const e of effects) {
    const familyId = `${e.lane}|${e.class}`;
    e.familyId = familyId;
    if (!familyMap.has(familyId)) familyMap.set(familyId, { familyId, lane: e.lane, class: e.class, race: e.race, members: [] });
    const fam = familyMap.get(familyId);
    fam.members.push(e.effectId);
    if (fam.race == null && e.race != null) fam.race = e.race;
  }
  const families = [...familyMap.values()].sort((a, b) => a.familyId.localeCompare(b.familyId));

  return {
    schema: "pdv.felt-effect-registry.v1",
    sourceHashes,
    counts: {
      effects: effects.length,
      families: families.length,
      byClass: effects.reduce((m, e) => ((m[e.class] = (m[e.class] ?? 0) + 1), m), {}),
    },
    familyBand: FAMILY_BAND,
    effects,
    families,
    orphans,
  };
}

// ---------- family evidence ledger sync + retro-credit ----------

function syncLedger(registry) {
  const ledgerPath = path.join(ROOT, LEDGER_REL);
  let ledger = {
    schema: "pdv.felt-family-evidence-ledger.v1",
    purpose: "One in-game felt-proof slot per lane x effect-class family (C-FELT-FAMILY). Statuses: pending / evidence-recorded / retro-credited / not-applicable. Retro-credits carry creditedFrom provenance; never hand-copy machine claims into these slots.",
    rules: { allowedStatuses: ["pending", "evidence-recorded", "retro-credited", "not-applicable"] },
    families: {},
  };
  if (fs.existsSync(ledgerPath)) ledger = JSON.parse(fs.readFileSync(ledgerPath, "utf8"));

  const next = {};
  let added = 0, dropped = 0;
  for (const fam of registry.families) {
    const existing = ledger.families[fam.familyId];
    if (existing) { next[fam.familyId] = existing; continue; }
    const sample = registry.effects.find((e) => e.familyId === fam.familyId);
    next[fam.familyId] = {
      status: "pending",
      lane: fam.lane,
      class: fam.class,
      race: fam.race,
      expected: `Feel one ${fam.class} effect of lane ${fam.lane} in game (e.g. ${sample?.displayName ?? sample?.effectId}) and record what was observed.`,
      note: "",
      creditedFrom: null,
    };
    added++;
  }
  dropped = Object.keys(ledger.families).filter((id) => !(id in next)).length;
  ledger.families = next;
  ledger.updated = new Date().toISOString().slice(0, 10);
  fs.writeFileSync(ledgerPath, JSON.stringify(ledger, null, 2) + "\n", "utf8");
  return { added, dropped, total: Object.keys(next).length, ledger };
}

function retroCredit(registry) {
  const ledgerPath = path.join(ROOT, LEDGER_REL);
  const ledger = JSON.parse(fs.readFileSync(ledgerPath, "utf8"));
  const manual = loadJson(MANUAL_LEDGER_REL);
  const daedric = loadJson(DAEDRIC_LEDGER_REL);
  let credited = 0;

  // Race families: displayName substring match against that race's recorded notes.
  const raceNotes = {};
  for (const [race, row] of Object.entries(manual.races ?? {})) {
    raceNotes[race] = Object.entries(row.manualEvidenceSlots ?? {})
      .filter(([, s]) => s.status === "evidence-recorded" && s.note)
      .map(([slot, s]) => ({ slot, note: s.note }));
  }
  for (const [familyId, slot] of Object.entries(ledger.families)) {
    if (slot.status !== "pending" || !slot.race) continue;
    const notes = raceNotes[slot.race] ?? [];
    const members = registry.effects.filter((e) => e.familyId === familyId && e.displayName && e.displayName.length >= 8);
    outer: for (const m of members) {
      for (const n of notes) {
        if (n.note.toLowerCase().includes(m.displayName.toLowerCase())) {
          slot.status = "retro-credited";
          slot.note = `Retro-credited ${new Date().toISOString().slice(0, 10)}: '${m.displayName}' named in ${slot.race} packet evidence.`;
          slot.creditedFrom = { ledger: MANUAL_LEDGER_REL, race: slot.race, slot: n.slot, matched: m.displayName };
          credited++;
          break outer;
        }
      }
    }
  }

  // Prince structural credits: activeEffects pass -> boon family; curseNoDoubleFire pass -> curse family.
  const princeRows = daedric.princes ?? [];
  for (const [familyId, slot] of Object.entries(ledger.families)) {
    if (slot.status !== "pending" || !slot.lane.startsWith("Daedric-")) continue;
    const stem = slot.lane.slice("Daedric-".length);
    const row = princeRows.find((p) => canonicalPrince(p.stem).toLowerCase() === stem.toLowerCase());
    if (!row) continue;
    const structural = slot.class === "boon" ? "activeEffects" : slot.class === "curse" ? "curseNoDoubleFire" : null;
    if (!structural) continue;
    if (row.slots?.[structural]?.status === "pass") {
      slot.status = "retro-credited";
      slot.note = `Retro-credited ${new Date().toISOString().slice(0, 10)}: ${stem} ${structural} slot recorded pass in the Daedric runtime evidence ledger.`;
      slot.creditedFrom = { ledger: DAEDRIC_LEDGER_REL, prince: stem, slot: structural };
      credited++;
    }
  }

  ledger.updated = new Date().toISOString().slice(0, 10);
  fs.writeFileSync(ledgerPath, JSON.stringify(ledger, null, 2) + "\n", "utf8");
  const open = Object.values(ledger.families).filter((s) => s.status === "pending").length;
  return { credited, open, total: Object.keys(ledger.families).length };
}

// ---------- self test ----------

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  expect("candidate: spellEditorId", isEffectCandidate({ spellEditorId: "PDV_X" }));
  expect("candidate: effects[] with actorValue", isEffectCandidate({ effects: [{ actorValue: "Health", magnitude: 5 }] }));
  expect("non-candidate: plain object", !isEffectCandidate({ note: "x" }));
  expect("lane parse tier strip", laneFromEditorId("PDV_Bless_Altmer_Orthodox_T1", "fb") === "Altmer-Orthodox");
  expect("lane parse prince tier word", laneFromEditorId("PDV_Bless_Daedric_Boethiah_Seeker", "fb") === "Daedric-Boethiah");
  expect("lane fallback", laneFromEditorId(null, "fb") === "fb");
  const out = [];
  collectCandidates({ a: { spellEditorId: "PDV_A", effects: [{ actorValue: "Health", magnitude: 1 }] }, b: [{ magicEffectEditorId: "PDV_B" }] }, "$", out);
  expect("collect finds 2, no nested double-count", out.length === 2);
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

// ---------- entry ----------

if (flags.has("--self-test")) {
  selfTest();
} else {
  const registry = buildRegistry();
  if (registry.orphans.length) {
    console.error("ORPHAN EFFECT CANDIDATES (fail-closed; map the key in CLASS_BY_KEY or fix the spec):");
    for (const o of registry.orphans) console.error(`  - ${o}`);
    process.exitCode = 1;
  } else if (flags.has("--check")) {
    const committedPath = path.join(ROOT, REGISTRY_REL);
    if (!fs.existsSync(committedPath)) { console.error(`--check: committed registry missing: ${REGISTRY_REL}`); process.exitCode = 1; }
    else {
      const committed = JSON.parse(fs.readFileSync(committedPath, "utf8"));
      const a = JSON.stringify({ e: committed.effects, f: committed.families });
      const b = JSON.stringify({ e: registry.effects, f: registry.families });
      if (a === b) { console.log("--check: committed registry matches regeneration."); }
      else { console.error("--check: committed registry DRIFTED from sources; re-run pdv_felt_registry_gen.mjs."); process.exitCode = 1; }
    }
  } else {
    registry.updated = new Date().toISOString().slice(0, 10);
    fs.writeFileSync(path.join(ROOT, REGISTRY_REL), JSON.stringify(registry, null, 2) + "\n", "utf8");
    const [lo, hi] = FAMILY_BAND;
    const bandNote = registry.counts.families < lo || registry.counts.families > hi
      ? ` (WARN: outside sanity band ${lo}-${hi})` : ` (in sanity band ${lo}-${hi})`;
    console.log(`Registry written: ${registry.counts.effects} effects, ${registry.counts.families} families${bandNote}`);
    console.log(`By class: ${Object.entries(registry.counts.byClass).map(([k, v]) => `${k}=${v}`).join(" ")}`);
    if (flags.has("--sync-ledger")) {
      const r = syncLedger(registry);
      console.log(`Family ledger synced: +${r.added} added, -${r.dropped} dropped, ${r.total} total slots.`);
    }
    if (flags.has("--retro-credit")) {
      const r = retroCredit(registry);
      console.log(`Retro-credit: ${r.credited} credited this pass; ${r.open} families still pending of ${r.total}.`);
    }
    if (flags.has("--json")) console.log(JSON.stringify({ counts: registry.counts }, null, 2));
  }
}
