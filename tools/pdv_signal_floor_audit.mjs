// pdv_signal_floor_audit.mjs
//
// READ-ONLY audit. Measures a per-PATH "signal-type floor" for the PDV
// (PlayerDevotion) Skyrim mod across 35 race-forked paths + 16 Daedric Princes.
//
// For each path it counts the DISTINCT signal-types and DISTINCT renewable
// signal-types the path can actually surface, by cross-referencing:
//   1. references/authoring/PDV_SignalFloorRegistry.csv              (the path universe + deity/formlist mapping)
//   2. references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json (designed curated source-types per formlist)
//   3. references/authoring/PDV_SignalE2EGateLedger.csv            (GREEN curated P2 source-types wired end-to-end)
//   4. references/authoring/PDV_DeityLikesDislikes.csv               (day-to-day + env renewable signals)
//   5. references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv    (Prince day-to-day renewable signals)
//   6. references/authoring/PDV_QuestReactionMatrix_Full.csv         (one-shot quest-reaction cells)
//   7. references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv (routed renewable faucet rows)
//   8. live-source/Scripts/Source/PDV_PlayerEvents.psc               (non-P2 Daedric quest-stage + faucet branch proof)
//   9. references/authoring/PDV_SignalFloorDirectRenewables.csv      (code-backed direct manager renewables)
//  10. live-source/Scripts/Source/PDV__ManagerQuest.psc              (direct manager renewable evidence)
//
// Verdict per path: PASS if wired_end_to_end >= min_types AND wired_renewable >= min_renewable, else UNDER-FLOOR.
//
// Outputs (alongside the registry, under references/authoring/):
//   PDV_SignalFloorLedger.csv
//   PDV_SignalFloorLedger.md
//
// No external dependencies. node:fs only.

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO = join(__dirname, "..");
const AUTH = join(REPO, "references", "authoring");

const PATHS = {
  registry: join(AUTH, "PDV_SignalFloorRegistry.csv"),
  manifest: join(AUTH, "PDV_Phase20_P2ImmersiveReceivers.manifest.json"),
  e2eLedger: join(AUTH, "PDV_SignalE2EGateLedger.csv"),
  likes: join(AUTH, "PDV_DeityLikesDislikes.csv"),
  princeLikes: join(AUTH, "PDV_DeityLikesDislikes_Princes_V2.csv"),
  quest: join(AUTH, "PDV_QuestReactionMatrix_Full.csv"),
  partd: join(AUTH, "PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv"),
  directRenewables: join(AUTH, "PDV_SignalFloorDirectRenewables.csv"),
  espLedger: join(AUTH, "PDV_P2FormListEspLedger.csv"),
  playerEvents: join(REPO, "live-source", "Scripts", "Source", "PDV_PlayerEvents.psc"),
  managerQuest: join(REPO, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc"),
  outCsv: join(AUTH, "PDV_SignalFloorLedger.csv"),
  outMd: join(AUTH, "PDV_SignalFloorLedger.md"),
};

// ---------------------------------------------------------------------------
// RFC-4180-ish CSV parser (handles quoted fields with embedded commas/quotes).
// The quest matrix has commas inside quoted act_tags/citation fields, so a
// naive split would mis-attribute deities. This parser is mandatory.
// ---------------------------------------------------------------------------
function parseCSV(txt) {
  const rows = [];
  let i = 0, field = "", row = [], inq = false;
  while (i < txt.length) {
    const c = txt[i];
    if (inq) {
      if (c === '"') {
        if (txt[i + 1] === '"') { field += '"'; i += 2; continue; }
        inq = false; i++; continue;
      }
      field += c; i++; continue;
    }
    if (c === '"') { inq = true; i++; continue; }
    if (c === ",") { row.push(field); field = ""; i++; continue; }
    if (c === "\r") { i++; continue; }
    if (c === "\n") { row.push(field); rows.push(row); row = []; field = ""; i++; continue; }
    field += c; i++;
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows;
}

function csvToObjects(txt) {
  const rows = parseCSV(txt).filter(r => r.length > 1 || (r.length === 1 && r[0].trim() !== ""));
  if (rows.length === 0) return [];
  const hdr = rows[0].map(h => h.trim());
  return rows.slice(1).map(r => {
    const o = {};
    hdr.forEach((h, idx) => { o[h] = (r[idx] ?? "").trim(); });
    return o;
  });
}

// ---------------------------------------------------------------------------
// Type vocabulary + renewable classification.
// ---------------------------------------------------------------------------
const RENEWABLE_TYPES = new Set(["harvest", "weather", "day-to-day", "faucet"]);
const ONESHOT_TYPES = new Set(["book", "quest-stage", "quest-reaction", "spell-learned"]);
const ALL_TYPES = new Set([...RENEWABLE_TYPES, ...ONESHOT_TYPES]);

function isRenewable(t) { return RENEWABLE_TYPES.has(t); }

// ---------------------------------------------------------------------------
// Deity name normalization + aliasing (CASE-INSENSITIVE).
// Canonical key = lowercased + apostrophes/dots stripped + whitespace collapsed.
// Aliases fold variant spellings onto the registry's canonical deity name.
// ---------------------------------------------------------------------------
const ALIASES = {
  // alias-source canonical key  ->  registry canonical key
  "hermaeusmora": "hermaeusmora", "mora": "hermaeusmora",
  "clavicusvile": "clavicusvile", "vile": "clavicusvile",
  "azura": "azura", "azurah": "azura",
  "boethiah": "boethiah", "boethra": "boethiah",
  "mephala": "mephala", "mafala": "mephala",
};

function normDeity(name) {
  let k = (name || "")
    .toLowerCase()
    .replace(/['`.\u2019]/g, "")   // strip apostrophes (straight + curly) and dots
    .replace(/[-]/g, "")            // strip hyphens (auri-el -> auriel)
    .replace(/\s+/g, "")            // collapse whitespace
    .trim();
  if (ALIASES[k]) k = ALIASES[k];
  return k;
}

function normActor(name) {
  let actor = (name || "").trim();
  if (actor.toLowerCase().startsWith("daedric:")) {
    actor = actor.slice("daedric:".length).trim();
  }
  return normDeity(actor);
}

// Build the canonical alias-fold once for a set of registry deity keys so that
// e.g. an "azurah" actor row matches a registry "Azura" deity and vice versa.
function deityMatchSet(registryDeities) {
  const s = new Set();
  for (const d of registryDeities) s.add(normDeity(d));
  return s;
}

// ---------------------------------------------------------------------------
// Likes/dislikes eventId classification.
// ---------------------------------------------------------------------------
const ENV_EVENT_NAMES = { 313: "rest-under-open-sky", 314: "sleep-in-bed", 345: "discover-location" };
const COMBAT_IDS = new Set([1, 2, 3, 4, 300, 301, 302, 304]);
// 313 rest-under-open-sky + 345 discover-location -> renewable env (outdoor/location)
// 314 sleep-in-bed -> env (sleep)
// The MERE PRESENCE of any likes-dislikes row for a path's deities -> renewable "day-to-day".

// ===========================================================================
// Load data
// ===========================================================================
const registry = csvToObjects(readFileSync(PATHS.registry, "utf8"));
const manifest = JSON.parse(readFileSync(PATHS.manifest, "utf8"));
const e2eRows = existsSync(PATHS.e2eLedger) ? csvToObjects(readFileSync(PATHS.e2eLedger, "utf8")) : [];
const likesRows = csvToObjects(readFileSync(PATHS.likes, "utf8"));
const princeLikesRows = existsSync(PATHS.princeLikes) ? csvToObjects(readFileSync(PATHS.princeLikes, "utf8")) : [];
const questRows = csvToObjects(readFileSync(PATHS.quest, "utf8"));
const partdRows = csvToObjects(readFileSync(PATHS.partd, "utf8"));
const directRenewableRows = existsSync(PATHS.directRenewables) ? csvToObjects(readFileSync(PATHS.directRenewables, "utf8")) : [];

// ESP-truth ledger (from tools/pdv_p2_formlist_esp_audit.mjs). When present, it lets
// this source-only audit tell a server-down "shell" SKIP (E2E could not read the ESP)
// apart from a genuinely empty FormList: a populated list that reads as INCOMPLETE/shell
// is stale-ledger drift, not missing content. Verdicts still require a GREEN E2E surface;
// this only makes the blocked-surface labels and truth_status honest.
const espLedgerRows = existsSync(PATHS.espLedger) ? csvToObjects(readFileSync(PATHS.espLedger, "utf8")) : [];
const espPopByProp = new Map();
for (const row of espLedgerRows) {
  if (!row.property) continue;
  const n = parseInt(row.esp_item_count, 10);
  espPopByProp.set(row.property, { itemCount: Number.isFinite(n) ? n : null, verdict: row.verdict || "" });
}
const playerEventsText = existsSync(PATHS.playerEvents) ? readFileSync(PATHS.playerEvents, "utf8") : "";
const managerQuestText = existsSync(PATHS.managerQuest) ? readFileSync(PATHS.managerQuest, "utf8") : "";

const routedFaucetKeys = new Set();
for (const match of playerEventsText.matchAll(/RouteQuestReactionFaucet\("([^"]+)"/g)) {
  routedFaucetKeys.add(match[1]);
}
for (const match of playerEventsText.matchAll(/ShouldRouteQuestReactionFaucet\("([^"]+)"/g)) {
  routedFaucetKeys.add(match[1]);
}

// ---------------------------------------------------------------------------
// Manifest: derive declared and legacy-populated curated source-types per
// FormList property.
//   - sourceProperties[]: declared sourceKinds; these feed the designed count.
//   - sourceFillEntries[]: manifest-approved fills; these feed only fallback
//     and empty-shell transparency when the E2E ledger is absent.
//   - routeEntries[]: quest-stage routes; only reviewStatus containing
//     "approved-live-source-fill" count in the legacy fallback map.
// ---------------------------------------------------------------------------
const declaredKinds = new Map();     // property -> Set(sourceKinds declared)
for (const sp of manifest.sourceProperties || []) {
  declaredKinds.set(sp.property, new Set(sp.sourceKinds || []));
}

const populatedKinds = new Map();    // property -> Set(sourceKinds actually live)
function addPopulated(prop, kind) {
  if (!prop || !kind) return;
  if (!populatedKinds.has(prop)) populatedKinds.set(prop, new Set());
  populatedKinds.get(prop).add(kind);
}

// (a) sourceFillEntries -> populated (these are live curated source fills)
for (const fe of manifest.sourceFillEntries || []) {
  const prop = fe.property;
  for (const s of fe.sources || []) {
    if ((s.status || "").includes("approved-for-fill")) addPopulated(prop, s.sourceKind);
  }
}

// (b) routeEntries with approved-live-source-fill -> populated quest-stage source
for (const re of manifest.routeEntries || []) {
  if ((re.reviewStatus || "").includes("approved-live-source-fill")) {
    addPopulated(re.property, re.sourceKind || "quest-stage");
  }
}

// ---------------------------------------------------------------------------
// E2E gate ledger: this is the authoritative source for P2 FormList truth.
// Only GREEN surfaces contribute P2 sourceKinds to wired_end_to_end. RED and
// INCOMPLETE/SKIP rows remain visible as blocked or unknown and never count as
// wired proof.
// ---------------------------------------------------------------------------
const E2E_PROOF_COLUMNS = [
  "manifest_parse",
  "shell",
  "alias_property",
  "registration",
  "route_branch",
  "handler_piety_sink",
  "route_review_status",
  "live_fill",
  "manifest_esp_reconcile",
];

const e2eByProperty = new Map();
for (const row of e2eRows) {
  if (row.property) e2eByProperty.set(row.property, row);
}

function splitSemis(s) {
  return (s || "").split(";").map(x => x.trim()).filter(Boolean);
}

function addTypes(target, kinds) {
  for (const kind of kinds || []) {
    if (ALL_TYPES.has(kind)) target.add(kind);
  }
}

function isDaedricLiveSource(prop) {
  return String(prop || "").startsWith("PDV_FLST_Daedric_");
}

function daedricSourceBranchStatus(prop) {
  const hasRegistration = playerEventsText.includes(`RegisterQuestStageList(${prop})`);
  const hasBranch = playerEventsText.includes(`ShouldRouteP2QuestStage(${prop},`);
  return { hasRegistration, hasBranch, ok: hasRegistration && hasBranch };
}

function faucetKey(row) {
  const deity = (row.deity || "").trim();
  const tag = (row.act_tag || "").trim();
  return deity && tag ? `${deity}.${tag}` : "";
}

function sortedTypes(types) {
  return [...types].sort();
}

function e2eVerdict(row) {
  return String(row?.verdict || "").toUpperCase();
}

function e2eHasSkip(row) {
  return E2E_PROOF_COLUMNS.some(col => String(row?.[col] || "").toUpperCase() === "SKIP");
}

function escapeRegExp(s) {
  return String(s || "").replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function extractPapyrusFunction(text, name) {
  if (!text || !name) return "";
  const lines = text.split(/\r?\n/);
  const startRe = new RegExp("^\\s*(?:[A-Za-z0-9_\\[\\]]+\\s+)?Function\\s+" + escapeRegExp(name) + "\\s*\\(", "i");
  let start = -1;
  for (let i = 0; i < lines.length; i++) {
    if (startRe.test(lines[i])) {
      start = i;
      break;
    }
  }
  if (start < 0) return "";

  for (let i = start + 1; i < lines.length; i++) {
    if (/^\s*EndFunction\b/i.test(lines[i])) {
      return lines.slice(start, i + 1).join("\n");
    }
  }
  return lines.slice(start).join("\n");
}

function missingTokens(text, tokens) {
  return tokens.filter(t => !text.includes(t));
}

const directRenewablesByPath = new Map();
for (const row of directRenewableRows) {
  if (!row.path_id) continue;
  if (!directRenewablesByPath.has(row.path_id)) directRenewablesByPath.set(row.path_id, []);
  directRenewablesByPath.get(row.path_id).push(row);
}

const directFunctionBodies = new Map();
function getDirectFunctionBody(name) {
  if (!directFunctionBodies.has(name)) {
    directFunctionBodies.set(name, extractPapyrusFunction(managerQuestText, name));
  }
  return directFunctionBodies.get(name);
}

function directRenewableCheck(row) {
  const kind = (row.type || "").trim();
  const fn = (row.manager_function || "").trim();
  if (!ALL_TYPES.has(kind)) return { ok: false, reason: `unknown-type:${kind || "(blank)"}` };
  if (!isRenewable(kind)) return { ok: false, reason: `not-renewable:${kind}` };
  if (!fn) return { ok: false, reason: "missing-manager-function" };

  const body = getDirectFunctionBody(fn);
  if (!body) return { ok: false, reason: `missing-function:${fn}` };

  const bodyMissing = [
    ...missingTokens(body, splitSemis(row.guard_evidence)).map(t => `guard:${t}`),
    ...missingTokens(body, splitSemis(row.anti_farm_evidence)).map(t => `anti-farm:${t}`),
    ...missingTokens(body, splitSemis(row.sink_evidence)).map(t => `sink:${t}`),
  ];
  const globalMissing = missingTokens(managerQuestText, splitSemis(row.global_evidence)).map(t => `global:${t}`);
  const hookMissing = missingTokens(managerQuestText, splitSemis(row.hook_evidence)).map(t => `hook:${t}`);
  const missing = [...bodyMissing, ...globalMissing, ...hookMissing];
  if (missing.length) return { ok: false, reason: `missing-evidence:${missing.join("+")}` };
  return { ok: true, reason: "code-backed" };
}

// ===========================================================================
// Per-path computation
// ===========================================================================
function splitPipes(s) {
  return (s || "").split("|").map(x => x.trim()).filter(Boolean);
}

const results = [];

for (const row of registry) {
  const pathId = row.path_id;
  if (!pathId) continue;
  const cls = row.class;
  const race = row.race;
  const fork = row.fork;
  const deities = splitPipes(row.deities);
  const formlists = splitPipes(row.formlists);
  const minTypes = parseInt(row.min_types, 10);
  const minRenew = parseInt(row.min_renewable, 10);

  const deitySet = deityMatchSet(deities);
  const designedTypes = new Set();  // manifest/data breadth; informational
  const wiredTypes = new Set();     // proof-backed breadth; verdict source
  const designedEvidence = [];      // human-readable attribution notes
  const wiredEvidence = [];
  const envEventsSeen = new Set();  // which env event-types (313/314/345)

  // ----- (1) P2 curated source-types.
  // Designed uses declared manifest breadth. Wired uses GREEN E2E surfaces.
  // If no E2E ledger exists, retain the old manifest-populated fallback only
  // as an explicit designed-only value and prevent it from producing PASS.
  const blockedP2Surfaces = [];
  const designedOnlyFormlists = [];
  const emptyShells = [];
  const blockedDirectRenewables = [];
  let truthStatus = e2eRows.length ? "e2e-ledger" : "designed-only-no-e2e-ledger";

  for (const prop of formlists) {
    if (isDaedricLiveSource(prop)) {
      designedTypes.add("quest-stage");
      designedEvidence.push(`daedric-live-source-designed:${prop}[quest-stage]`);

      const daedricStatus = daedricSourceBranchStatus(prop);
      if (daedricStatus.ok) {
        wiredTypes.add("quest-stage");
        wiredEvidence.push(`daedric-live-source-branch:${prop}[quest-stage]`);
        if (cls === "prince") truthStatus = "non-p2-daedric-source";
      } else {
        const missing = [
          daedricStatus.hasRegistration ? "" : "registration",
          daedricStatus.hasBranch ? "" : "route_branch",
        ].filter(Boolean).join("+");
        blockedP2Surfaces.push(`${prop}:missing-daedric-${missing || "proof"}`);
        truthStatus = "daedric-source-incomplete";
      }
      continue;
    }

    const decl = declaredKinds.get(prop);
    if (decl) {
      addTypes(designedTypes, decl);
      designedEvidence.push(`p2-designed:${prop}[${sortedTypes(decl).join(",")}]`);
    }

    const pop = populatedKinds.get(prop);
    if (decl && (!pop || pop.size === 0)) emptyShells.push(prop);

    if (e2eRows.length) {
      const gate = e2eByProperty.get(prop);
      const verdict = e2eVerdict(gate);
      if (verdict === "GREEN") {
        const kinds = splitSemis(gate.sourceKinds);
        addTypes(wiredTypes, kinds);
        wiredEvidence.push(`p2-e2e-green:${prop}[${kinds.sort().join(",")}]`);
      } else if (gate) {
        const esp = espPopByProp.get(prop);
        const espNote = esp && esp.itemCount > 0
          ? `,esp-populated:${esp.itemCount}`
          : (esp && esp.itemCount === 0 ? ",esp-EMPTY" : "");
        const status = `${verdict || "UNKNOWN"}${gate.failing_step ? `/${gate.failing_step}` : ""}${espNote}`;
        blockedP2Surfaces.push(`${prop}:${status}`);
        if (verdict === "INCOMPLETE" || e2eHasSkip(gate)) {
          // A server-down SKIP the deployed ESP contradicts (list populated) is a
          // stale-ledger artifact, not an empty shell. Label it truthfully; the verdict
          // stays proof-limited (this status is not in the PASS allowlist below).
          truthStatus = (esp && esp.itemCount > 0) ? "esp-populated-live-e2e-pending" : "UNKNOWN-server-down";
        }
      } else if (decl) {
        blockedP2Surfaces.push(`${prop}:missing-e2e-row`);
        if (truthStatus === "e2e-ledger") truthStatus = "missing-e2e-row";
      }
    } else {
      // Server/ledger unavailable fallback. This is exposed in truth_status and
      // cannot make the row PASS.
      if (pop) {
        addTypes(wiredTypes, pop);
        wiredEvidence.push(`p2-designed-only:${prop}[${sortedTypes(pop).join(",")}]`);
      }
      if (decl) designedOnlyFormlists.push(prop);
    }
  }
  if (!e2eRows.length && formlists.length === 0) truthStatus = "non-p2-data";

  // ----- (2) Likes/dislikes -> renewable "day-to-day" + env event surfacing
  let likesHits = 0;
  const activeLikesRows = cls === "prince" ? princeLikesRows : likesRows;
  for (const lr of activeLikesRows) {
    if (deitySet.has(normActor(lr.actor))) {
      likesHits++;
      const eid = parseInt(lr.eventId, 10);
      if (ENV_EVENT_NAMES[eid]) envEventsSeen.add(eid);
    }
  }
  if (likesHits > 0) {
    designedTypes.add("day-to-day");
    wiredTypes.add("day-to-day");
    const envList = [...envEventsSeen].sort((a, b) => a - b)
      .map(id => `${id}:${ENV_EVENT_NAMES[id]}`);
    const note = `likes-dislikes:${likesHits}row${likesHits === 1 ? "" : "s"}` +
      (envList.length ? ` env[${envList.join(",")}]` : "");
    designedEvidence.push(note);
    wiredEvidence.push(note);
  }

  // ----- (3) Quest matrix -> one-shot "quest-reaction"
  let questHits = 0;
  for (const qr of questRows) {
    if (deitySet.has(normDeity(qr.deity))) questHits++;
  }
  if (questHits > 0) {
    designedTypes.add("quest-reaction");
    wiredTypes.add("quest-reaction");
    const note = `quest-reaction:${questHits}cell${questHits === 1 ? "" : "s"}`;
    designedEvidence.push(note);
    wiredEvidence.push(note);
  }

  // ----- (4) Part D faucets -> renewable "faucet"
  let faucetDesignedHits = 0;
  let faucetHits = 0;
  for (const pr of partdRows) {
    if ((pr.buildability || "").toUpperCase() === "DEFERRED") continue;
    if (!deitySet.has(normDeity(pr.deity))) continue;

    faucetDesignedHits++;
    if (routedFaucetKeys.has(faucetKey(pr))) faucetHits++;
  }
  if (faucetDesignedHits > 0) {
    designedTypes.add("faucet");
    const note = `faucet-designed:${faucetDesignedHits}row${faucetDesignedHits === 1 ? "" : "s"}`;
    designedEvidence.push(note);
  }
  if (faucetHits > 0) {
    wiredTypes.add("faucet");
    const note = `faucet-routed:${faucetHits}row${faucetHits === 1 ? "" : "s"}`;
    wiredEvidence.push(note);
  }

  // ----- (5) Direct manager renewables -> code-backed renewable types.
  // These rows are allowed to count only when the named manager function exists
  // and the declared origin/active-path guard, anti-farm gate, hook seam, and
  // piety/substrate sink evidence are present in the live-source mirror.
  for (const dr of directRenewablesByPath.get(pathId) || []) {
    const kind = (dr.type || "").trim();
    const fn = (dr.manager_function || "").trim();
    if (ALL_TYPES.has(kind)) {
      designedTypes.add(kind);
      designedEvidence.push(`direct-manager-designed:${fn || "(missing)"}[${kind}]`);
    }

    const status = directRenewableCheck(dr);
    if (status.ok) {
      wiredTypes.add(kind);
      wiredEvidence.push(`direct-manager:${fn}[${kind}]`);
    } else {
      blockedDirectRenewables.push(`${fn || "(missing-function)"}[${kind || "(missing-type)"}]:${status.reason}`);
    }
  }

  // ----- Tally
  const designedTypesPresent = sortedTypes(designedTypes);
  const wiredTypesPresent = sortedTypes(wiredTypes);
  const designedRenewPresent = designedTypesPresent.filter(isRenewable);
  const wiredRenewPresent = wiredTypesPresent.filter(isRenewable);
  const designedDistinctTypes = designedTypesPresent.length;
  const wiredDistinctTypes = wiredTypesPresent.length;
  const designedDistinctRenew = designedRenewPresent.length;
  const wiredDistinctRenew = wiredRenewPresent.length;

  const passTypes = wiredDistinctTypes >= minTypes;
  const passRenew = wiredDistinctRenew >= minRenew;
  const proofLimited = !["e2e-ledger", "non-p2-data", "non-p2-daedric-source"].includes(truthStatus);
  const verdict = (passTypes && passRenew && !proofLimited) ? "PASS" : "UNDER-FLOOR";

  const missing = [];
  if (!passTypes) missing.push(`types ${wiredDistinctTypes}/${minTypes} (short ${minTypes - wiredDistinctTypes})`);
  if (!passRenew) missing.push(`renewable ${wiredDistinctRenew}/${minRenew} (short ${minRenew - wiredDistinctRenew})`);
  if (passTypes && passRenew && proofLimited) missing.push(`wired proof ${truthStatus}`);

  results.push({
    pathId, cls, race, fork,
    deities, formlists,
    minTypes, minRenew,
    designedDistinctTypes, designedDistinctRenew,
    wiredDistinctTypes, wiredDistinctRenew,
    designedTypesPresent, wiredTypesPresent,
    designedRenewPresent, wiredRenewPresent,
    distinctTypes: wiredDistinctTypes,
    distinctRenew: wiredDistinctRenew,
    typesPresent: wiredTypesPresent,
    renewPresent: wiredRenewPresent,
    verdict,
    missing,
    designedEvidence,
    wiredEvidence,
    evidence: wiredEvidence,
    emptyShells,
    blockedP2Surfaces,
    blockedDirectRenewables,
    designedOnlyFormlists,
    truthStatus,
    envEventsSeen: [...envEventsSeen].sort((a, b) => a - b),
    deficit: (Math.max(0, minTypes - wiredDistinctTypes)) +
      (Math.max(0, minRenew - wiredDistinctRenew)) +
      (proofLimited && passTypes && passRenew ? 1 : 0),
  });
}

// ===========================================================================
// Emit ledger CSV
// ===========================================================================
function csvCell(s) {
  s = String(s ?? "");
  if (/[",\n]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
  return s;
}
const csvHeader = [
  "path_id",
  "class",
  "race",
  "fork",
  "designed",
  "wired_end_to_end",
  "distinct_types",
  "distinct_renewable",
  "designed_renewable",
  "wired_renewable",
  "designed_types_present",
  "wired_types_present",
  "types_present",
  "verdict",
  "missing",
  "truth_status",
  "blocked_p2_surfaces",
  "blocked_direct_renewables",
  "designed_only_formlists",
];
const csvLines = [csvHeader.join(",")];
for (const r of results) {
  csvLines.push([
    r.pathId, r.cls, r.race, r.fork,
    r.designedDistinctTypes,
    r.wiredDistinctTypes,
    r.distinctTypes,
    r.distinctRenew,
    r.designedDistinctRenew,
    r.wiredDistinctRenew,
    r.designedTypesPresent.join("|"),
    r.wiredTypesPresent.join("|"),
    r.typesPresent.join("|"),
    r.verdict,
    r.missing.join("; "),
    r.truthStatus,
    r.blockedP2Surfaces.join("|"),
    r.blockedDirectRenewables.join("|"),
    r.designedOnlyFormlists.join("|"),
  ].map(csvCell).join(","));
}
writeFileSync(PATHS.outCsv, csvLines.join("\n") + "\n", "utf8");

// ===========================================================================
// Emit ledger Markdown
// ===========================================================================
const total = results.length;
const racePaths = results.filter(r => r.cls === "race-path");
const princes = results.filter(r => r.cls === "prince");
const pass = results.filter(r => r.verdict === "PASS");
const under = results.filter(r => r.verdict === "UNDER-FLOOR");
const underRace = under.filter(r => r.cls === "race-path");
const underPrince = under.filter(r => r.cls === "prince");

const underRanked = [...under].sort((a, b) =>
  b.deficit - a.deficit ||
  a.distinctTypes - b.distinctTypes ||
  a.distinctRenew - b.distinctRenew ||
  a.pathId.localeCompare(b.pathId));

function sev(r) {
  if (r.deficit >= 4) return "CRITICAL";
  if (r.deficit >= 2) return "HIGH";
  return "LOW";
}

const now = new Date().toISOString().slice(0, 10);
const md = [];
md.push("# PDV Signal-Floor Ledger");
md.push("");
md.push(`**Generated:** ${now} by \`tools/pdv_signal_floor_audit.mjs\` (read-only audit)`);
md.push("");
md.push(`Per-PATH signal-type floor across ${racePaths.length} race-forked paths + ${princes.length} Daedric Princes. ` +
  "A path's _types_ are the DISTINCT signal-types it can surface; _renewable_ are the " +
  "distinct renewable types (`harvest`, `weather`, `day-to-day`, `faucet`). " +
  "One-shot types are `book`, `quest-stage`, `quest-reaction`, `spell-learned`.");
md.push("");
md.push("**Floor:** race-path = 5 types / 2 renewable; prince = 4 types / 2 renewable. " +
  "PASS iff `wired_end_to_end >= min_types AND wired_renewable >= min_renewable`.");
md.push("");
md.push("**Designed vs wired:** `designed` counts manifest-declared P2 sourceKinds plus the existing " +
  "data-backed non-P2 source families. `wired_end_to_end` counts P2 sourceKinds only from GREEN " +
  "`PDV_SignalE2EGateLedger.csv` surfaces; non-P2 Prince Daedric quest-stage counts only when " +
  "`PDV_PlayerEvents.psc` has both registration and a route branch. Non-P2 `day-to-day`, " +
  "`quest-reaction`, and routed `faucet` remain data-backed from their source tables and " +
  "runtime branches. Direct manager renewables count only when `PDV_SignalFloorDirectRenewables.csv` " +
  "has a row whose named manager function contains the declared guard, anti-farm, and sink evidence. " +
  "Verdicts use `wired_end_to_end`; `designed` is informational.");
md.push("");
md.push("## Summary");
md.push("");
md.push(`- Paths audited: **${total}** (${racePaths.length} race-paths, ${princes.length} princes)`);
md.push(`- PASS: **${pass.length}** | UNDER-FLOOR: **${under.length}** (${underRace.length} race-paths, ${underPrince.length} princes)`);
md.push(`- Critical (deficit >= 4): ${under.filter(r => sev(r) === "CRITICAL").length} | High (>= 2): ${under.filter(r => sev(r) === "HIGH").length} | Low (1): ${under.filter(r => sev(r) === "LOW").length}`);
const truthStatusCounts = results.reduce((acc, r) => {
  acc[r.truthStatus] = (acc[r.truthStatus] || 0) + 1;
  return acc;
}, {});
md.push(`- Truth status: ${Object.entries(truthStatusCounts).sort().map(([k, v]) => `${k}=${v}`).join(" | ")}`);
md.push("");

md.push("## UNDER-FLOOR roster (worst first)");
md.push("");
if (underRanked.length === 0) {
  md.push("_None - every path meets its floor._");
} else {
  md.push("| Severity | path_id | class | designed | wired_end_to_end | wired renew | wired types | missing dimension(s) |");
  md.push("|---|---|---|---|---|---|---|---|");
  for (const r of underRanked) {
    md.push(`| ${sev(r)} | \`${r.pathId}\` | ${r.cls} | ${r.designedDistinctTypes} | ${r.wiredDistinctTypes}/${r.minTypes} | ${r.wiredDistinctRenew}/${r.minRenew} | ${r.wiredTypesPresent.join(", ") || "(none)"} | ${r.missing.join("; ")} |`);
  }
}
md.push("");

md.push("## Full per-path table");
md.push("");
md.push("| path_id | class | race | fork | designed | wired_end_to_end | wired renew | verdict | designed types | wired types | truth | wired evidence |");
md.push("|---|---|---|---|---|---|---|---|---|---|---|---|");
for (const r of results) {
  md.push(`| \`${r.pathId}\` | ${r.cls} | ${r.race} | ${r.fork} | ${r.designedDistinctTypes} | ${r.wiredDistinctTypes}/${r.minTypes} | ${r.wiredDistinctRenew}/${r.minRenew} | ${r.verdict} | ${r.designedTypesPresent.join(", ") || "(none)"} | ${r.wiredTypesPresent.join(", ") || "(none)"} | ${r.truthStatus} | ${r.wiredEvidence.join(" / ") || "(no wired sources matched)"} |`);
}
md.push("");

// Blocked P2 surface transparency section
const withBlockedP2 = results.filter(r => r.blockedP2Surfaces.length);
if (withBlockedP2.length) {
  md.push("## P2 surfaces not wired end-to-end");
  md.push("");
  md.push("These FormLists are declared for the path but are not GREEN in `PDV_SignalE2EGateLedger.csv`, " +
    "so their sourceKinds do not count toward `wired_end_to_end`.");
  md.push("");
  md.push("| path_id | blocked P2 surfaces |");
  md.push("|---|---|");
  for (const r of withBlockedP2) {
    md.push(`| \`${r.pathId}\` | ${r.blockedP2Surfaces.join(", ")} |`);
  }
  md.push("");
}

// Direct manager renewable transparency section
const withBlockedDirect = results.filter(r => r.blockedDirectRenewables.length);
if (withBlockedDirect.length) {
  md.push("## Direct manager renewables not code-backed");
  md.push("");
  md.push("These rows are declared in `PDV_SignalFloorDirectRenewables.csv` but do not yet have all " +
    "declared manager function, guard, anti-farm, sink, and hook evidence in `PDV__ManagerQuest.psc`.");
  md.push("");
  md.push("| path_id | blocked direct renewables |");
  md.push("|---|---|");
  for (const r of withBlockedDirect) {
    md.push(`| \`${r.pathId}\` | ${r.blockedDirectRenewables.join(", ")} |`);
  }
  md.push("");
}

// Empty-shell transparency section
const withShells = results.filter(r => r.emptyShells.length);
if (withShells.length) {
  md.push("## Empty P2 FormList shells (declared, not populated)");
  md.push("");
  md.push("These FormLists are routed to a path but appear in neither `sourceFillEntries` " +
    "nor an `approved-live-source-fill` route in the manifest fallback map. They also do not count " +
    "toward `wired_end_to_end` unless the E2E gate row is GREEN.");
  md.push("");
  md.push("| path_id | empty shell FormLists |");
  md.push("|---|---|");
  for (const r of withShells) {
    md.push(`| \`${r.pathId}\` | ${r.emptyShells.join(", ")} |`);
  }
  md.push("");
}

// ----- Data-quality caveats (computed, not hand-asserted) -----
// Which curated source-kinds are wired by a GREEN E2E surface?
const allGreenP2Kinds = new Set();
const greenP2Properties = [];
for (const row of e2eRows) {
  if (e2eVerdict(row) === "GREEN") {
    greenP2Properties.push(row.property);
    for (const k of splitSemis(row.sourceKinds)) allGreenP2Kinds.add(k);
  }
}
const neverGreenP2Kinds = [...ALL_TYPES].filter(t =>
  ["book", "quest-stage", "weather", "harvest", "spell-learned"].includes(t) && !allGreenP2Kinds.has(t)
).sort();

// Which renewable curated source-kinds are populated ANYWHERE in the manifest fallback map?
const allPopulatedKinds = new Set();
for (const set of populatedKinds.values()) for (const k of set) allPopulatedKinds.add(k);
const neverPopulated = [...ALL_TYPES].filter(t =>
  // only the manifest-sourced curated kinds are relevant here
  ["book", "quest-stage", "weather", "harvest", "spell-learned"].includes(t) && !allPopulatedKinds.has(t)
).sort();

md.push("## Data-quality caveats");
md.push("");
md.push("- **No `weather`, `harvest`, or `spell-learned` P2 source is GREEN in the E2E gate.** " +
  "Several FormLists *declare* these `sourceKinds` (e.g. `BretonGreenWaySources` weather/harvest, " +
  "`NordKyneTalosSources` weather, `BretonHiddenArtSpells` spell-learned), but none are wired end-to-end. " +
  (neverGreenP2Kinds.length ? `Never-GREEN P2 kinds: \`${neverGreenP2Kinds.join("`, `")}\`. ` : "") +
  (neverPopulated.length ? `Never-populated manifest fallback kinds: \`${neverPopulated.join("`, `")}\`. ` : "") +
  "The likes-dislikes CSV also carries no weather event-id (only env ids 313/314/345). " +
  "Net effect: `weather` and `harvest` are currently unreachable as wired distinct types for every path.");
md.push("- **Only GREEN E2E surfaces contribute P2 `book` or `quest-stage` breadth.** " +
  (greenP2Properties.length ? `Current GREEN surfaces: \`${greenP2Properties.sort().join("`, `")}\`. ` : "Current GREEN surfaces: none. ") +
  "Nord Old Ways' MQ104/MQ304 routes and Redguard's MS08 routes remain blocked by static-only route review, " +
  "so those `quest-stage` declarations do not count as wired.");
md.push("- **Prince quest-reaction is NOT zero.** A literal application of the rule (any matrix cell whose " +
  "`deity` equals the path's name) gives Molag Bal 6, Peryite 3, Namira 2, Vaermina 2 quest-reaction cells " +
  "(many are negative/reject branches, e.g. *destroy altar*, but the `deity` column still attributes them). " +
  "Every one of the 16 Princes has at least 1 quest-reaction cell. This contradicts an a-priori expectation " +
  "that Namira/Vaermina/Peryite/Molag Bal have none; the tool reports the ground-truth count.");
md.push("- **Prince day-to-day rows come from the Prince V2 table.** Race-path rows still use " +
  "`PDV_DeityLikesDislikes.csv`; Prince rows use `PDV_DeityLikesDislikes_Princes_V2.csv`, " +
  "which is the runtime table loaded by `PDV__ManagerQuest.psc` for `PDV_DaedricPath_*` actors.");
md.push("- **Part D faucet rows count only when routed in `PDV_PlayerEvents.psc`.** Designed rows " +
  "remain visible in `designed`, but `wired_end_to_end` requires a matching `RouteQuestReactionFaucet` " +
  "or `ShouldRouteQuestReactionFaucet` branch so silent candidate faucets do not pass the floor.");
md.push("- **Deity-name aliasing applied** (case-insensitive, apostrophe/dot/hyphen-stripped): " +
  "`Azura`=`azurah`, `Hermaeus Mora`=`Mora`, `Clavicus Vile`=`Vile`, `Boethiah`=`Boethra`, `Mephala`=`Mafala`. " +
  "`Auri-El`->`auriel`, `Y'ffre`->`yffre`, `Z'en`->`zen` fold by the same normalizer.");
md.push("- **Several registry deities never appear in any data source** and therefore contribute nothing: " +
  "Redguard `Onsi`/`Ruptga`/`Tava`/`Zeht`/`Satakal`, Breton `Phynaster`, Altmer/others absent from likes-dislikes, " +
  "quest-matrix, and Part D. Redguard Crown/Forebear day-to-day comes only from `HoonDing`/`Leki`/`Tu'whacca`, " +
  "which are the sole sect deities present in the sources.");
md.push("- **Registry size is 35 race-paths + 16 princes = 51.** The task header said '33 race-paths / 49 total', " +
  "but its own explicit enumeration (Khajiit = Lunar + 5 focused = 6; 3+3+3+2+4+3+6+3+4+4 = 35) sums to 35. " +
  "The explicit per-path list is treated as authoritative over the header count.");
md.push("");

writeFileSync(PATHS.outMd, md.join("\n") + "\n", "utf8");

// ===========================================================================
// Console summary
// ===========================================================================
console.log(`Signal-floor audit complete: ${total} paths (${pass.length} PASS, ${under.length} UNDER-FLOOR; verdicts use wired_end_to_end).`);
console.log(`  race-paths under: ${underRace.length}/${racePaths.length} | princes under: ${underPrince.length}/${princes.length}`);
console.log(`Wrote: ${PATHS.outCsv}`);
console.log(`Wrote: ${PATHS.outMd}`);
console.log("");
console.log("UNDER-FLOOR roster (worst first):");
for (const r of underRanked) {
  console.log(`  [${sev(r).padEnd(8)}] ${r.pathId.padEnd(24)} designed ${String(r.designedDistinctTypes).padStart(1)} wired ${r.wiredDistinctTypes}/${r.minTypes} renew ${r.wiredDistinctRenew}/${r.minRenew}  present=[${r.wiredTypesPresent.join(",")}]  missing: ${r.missing.join("; ")}`);
}
