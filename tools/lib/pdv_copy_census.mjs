import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export const CENSUS_SCHEMA = "pdv.copy-census.v1";

export const SURFACE_BUDGETS = Object.freeze({
  notification: 80,
  "message-title": 40,
  "message-body": 500,
  "message-button": 40,
  "blessing-name": 40,
  "blessing-description": 200,
  "survey-readout": 240,
  "book-title": 60,
  "book-text": null,
  "prisma-label": 80,
  "papyrus-runtime": null,
  "dialogue-topic": 120,
  "dialogue-response": 500,
});

const RECORD_TYPES = Object.freeze({
  SPEL: { fields: ["EditorID", "Name", "Description"], depth: 2 },
  MGEF: { fields: ["EditorID", "Name", "Description"], depth: 2 },
  MESG: { fields: ["EditorID", "Name", "Description", "MenuButtons"], depth: 5 },
  BOOK: { fields: ["EditorID", "Name", "BookText"], depth: 3 },
  DIAL: { fields: ["EditorID", "Name"], depth: 2 },
  INFO: { fields: ["EditorID", "Prompt", "Responses"], depth: 5 },
});

const PLAYER_TEXT_FIELDS = [
  /^Name$/,
  /^Description$/,
  /^BookText$/,
  /^Prompt$/,
  /^MenuButtons\[\d+\]\.Text$/,
  /^Responses\[\d+\]\.(ResponseText|Text)$/,
];

const DEV_ONLY = /\b(debug|developer|dev-only|self[- ]?test|qa ?smoke|proof|harness|fixture|seed|force|trace|dump|reset all)\b/i;
const UI_CALL = /\b(?:Debug\.(?:Notification|MessageBox)|ShowMessage|ShowSurvey|SendPrisma(?:EventToast|Toast|Panel)|AppendBookOfDaysEntry|SetInfoText|AddTextOption|AddMenuOption|AddToggleOption|AddHeaderOption)\s*\((.*)$/i;

export function stableHash(value, length = 16) {
  return crypto.createHash("sha256").update(typeof value === "string" ? value : stableStringify(value)).digest("hex").slice(0, length);
}

export function stableStringify(value) {
  return `${JSON.stringify(sortValue(value), null, 2)}\n`;
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(Object.keys(value).sort().map((key) => [key, sortValue(value[key])]));
}

export function normalizeText(value) {
  if (value == null) return "";
  const text = String(value).trim();
  return text === "(absent)" || text === "<null>" ? "" : text.replace(/\r\n/g, "\n");
}

export function splitMarkdownRow(line) {
  const cells = [];
  let current = "";
  let escaped = false;
  for (const ch of line.trim().replace(/^\|/, "").replace(/\|$/, "")) {
    if (escaped) { current += ch; escaped = false; continue; }
    if (ch === "\\") { escaped = true; current += ch; continue; }
    if (ch === "|") { cells.push(current.trim()); current = ""; continue; }
    current += ch;
  }
  cells.push(current.trim());
  return cells;
}

export function parseManifestRows(text, sourcePath) {
  const rows = [];
  let section = "";
  for (const [offset, line] of text.split(/\r?\n/).entries()) {
    if (/^#{2,4}\s+/.test(line)) section = line.replace(/^#+\s+/, "").trim();
    if (!/^\|\s*PDV_/.test(line)) continue;
    const cells = splitMarkdownRow(line);
    if (cells.length < 8) continue;
    const [slotId, surface, density, voice, budget, gameplaySource, firingCondition, prose] = cells;
    rows.push({
      slotId,
      surface,
      density,
      voice,
      budget,
      gameplaySource,
      firingCondition,
      prose,
      section,
      sourcePath,
      line: offset + 1,
    });
  }
  return rows;
}

export function parseAuthoredProse(prose) {
  const result = { direct: normalizeText(prose), title: "", body: "" };
  const title = prose.match(/(?:^|\s)Title:\s*"([\s\S]*?)"(?=\s+Body:|$)/i);
  const body = prose.match(/(?:^|\s)Body:\s*"([\s\S]*?)"(?=\s+Title:|$)/i);
  if (title || body) {
    result.title = normalizeText(title?.[1]);
    result.body = normalizeText(body?.[1]);
  }
  return result;
}

export function parseHousecarlInventory(text, recordType) {
  const found = new Map();
  for (const line of text.split(/\r?\n/)) {
    const match = line.match(/^\s*([0-9A-F]{6,8}:[^\s]+)\s+type=\w+\s+editorid=([^\s]+)/i)
      || line.match(/^\s*formid[=:]\s*([0-9A-F]{6,8}(?::[^\s]+)?).*?editorid[=:]\s*([^\s]+)/i)
      || line.match(/^\s*type=\w+\s+formid=([0-9A-F]{6,8}(?::[^\s]+)?)\s+editorid=([^\s]+)/i)
      || line.match(/^\s*(?:\d+\.\s*)?([0-9A-F]{6,8})\s+([^\s]+)(?:\s|$)/i);
    if (!match) continue;
    const formId = normalizeFormId(match[1]);
    const editorId = match[2].replace(/[;,]$/, "");
    if (editorId.startsWith("PDV_")) found.set(formId, { recordType, formId, editorId });
  }
  return [...found.values()].sort((a, b) => a.formId.localeCompare(b.formId));
}

export function parseHousecarlDetail(text, expectedType = "") {
  const records = [];
  let current = null;
  let lastField = null;
  for (const raw of text.split(/\r?\n/)) {
    const header = raw.match(/^\s*type=(\w+)\s+formid=([0-9A-F]{6,8}(?::[^\s]+)?)\s+editorid=([^\s]+).*$/i);
    if (header) {
      if (current) records.push(current);
      current = { recordType: normalizeRecordType(header[1], expectedType), formId: normalizeFormId(header[2]), editorId: header[3], fields: {} };
      lastField = null;
      continue;
    }
    if (!current) {
      const compact = raw.match(/^\s*(?:\d+\.\s*)?([0-9A-F]{6,8})\s+([^\s]+)\s*(.*)$/i);
      if (compact && compact[2].startsWith("PDV_")) {
        if (current) records.push(current);
        current = { recordType: expectedType, formId: compact[1].toUpperCase(), editorId: compact[2], fields: {} };
        lastField = null;
      }
      continue;
    }
    const field = raw.match(/^\s{2,}([A-Za-z][A-Za-z0-9_.\[\]]*)\s*=\s*(.*)$/);
    if (field) {
      lastField = field[1];
      current.fields[lastField] = normalizeText(field[2]);
      if (lastField === "EditorID" && current.fields[lastField]) current.editorId = current.fields[lastField];
      continue;
    }
    if (lastField && raw.trim() && !/^\s*(?:winner|source|override|fields?)\b/i.test(raw)) {
      current.fields[lastField] = normalizeText(`${current.fields[lastField]}\n${raw.trim()}`);
    }
  }
  if (current) records.push(current);
  return records;
}

export function flattenRuntimeRecords(records) {
  const rows = [];
  for (const record of records) {
    for (const [fieldPath, raw] of Object.entries(record.fields ?? {})) {
      const text = normalizeText(raw);
      if (!text || !PLAYER_TEXT_FIELDS.some((pattern) => pattern.test(fieldPath))) continue;
      const surface = recordSurface(record.recordType, fieldPath, record.editorId);
      if (!surface) continue;
      rows.push({
        sourceKind: "esp",
        copyId: `esp:${record.recordType.toLowerCase()}:${record.formId}:${fieldPath.toLowerCase()}`,
        surface,
        visibility: recordVisibility(record.recordType, fieldPath),
        runtimeLocation: `Devotion.esp:${record.recordType}:${record.formId}:${record.editorId}:${fieldPath}`,
        runtimeAuthority: "live Devotion.esp direct houseCARL readback",
        runtimeText: text,
        recordType: record.recordType,
        formId: record.formId,
        editorId: record.editorId,
        fieldPath,
        dynamic: false,
        manualReview: false,
      });
    }
  }
  return rows.sort((a, b) => a.copyId.localeCompare(b.copyId));
}

function recordSurface(type, field, editorId) {
  if (type === "MESG" && field === "Name") return "message-record-name";
  if (type === "MESG" && field === "Description") return "message-body";
  if (type === "MESG" && /^MenuButtons/.test(field)) return "message-button";
  if (type === "SPEL" && field === "Name") return editorId === "PDV_SPEL_SurveyDevotion" ? "survey-readout" : "blessing-name";
  if (type === "SPEL" && field === "Description") return editorId === "PDV_SPEL_SurveyDevotion" ? "survey-readout" : "blessing-description";
  if (type === "MGEF" && field === "Name") return "blessing-name";
  if (type === "MGEF" && field === "Description") return "blessing-description";
  if (type === "BOOK" && field === "Name") return "book-title";
  if (type === "BOOK" && field === "BookText") return "book-text";
  if (type === "DIAL" && field === "Name") return "dialogue-topic";
  if (type === "INFO" && field === "Prompt") return "dialogue-topic";
  if (type === "INFO" && /^Responses/.test(field)) return "dialogue-response";
  return null;
}

function recordVisibility(type, field) {
  if (type === "MESG" && field === "Name") return "record-metadata-not-rendered";
  return "player-visible";
}

function normalizeRecordType(value, expectedType = "") {
  const compact = String(value ?? "").replace(/[^A-Za-z]/g, "").toUpperCase();
  const aliases = {
    SPELL: "SPEL",
    MAGICEFFECT: "MGEF",
    MESSAGE: "MESG",
    BOOK: "BOOK",
    DIALOGTOPIC: "DIAL",
    DIALOGRESPONSE: "INFO",
    DIALOGINFO: "INFO",
  };
  return aliases[compact] ?? (RECORD_TYPES[compact] ? compact : expectedType || compact);
}

function normalizeFormId(value) {
  const [hex, ...plugin] = String(value).split(":");
  return plugin.length ? `${hex.toUpperCase()}:${plugin.join(":")}` : hex.toUpperCase();
}

export function extractPapyrusCopy(text, sourcePath) {
  const rows = [];
  let functionName = "<global>";
  let devFunction = false;
  for (const [index, raw] of text.split(/\r?\n/).entries()) {
    const fn = raw.match(/^\s*(?:[A-Za-z0-9_\[\]]+\s+)?Function\s+([A-Za-z0-9_]+)/i);
    if (fn) { functionName = fn[1]; devFunction = DEV_ONLY.test(functionName) || /^Debug[A-Z0-9_]/.test(functionName); continue; }
    if (/^\s*EndFunction\b/i.test(raw)) { functionName = "<global>"; devFunction = false; continue; }
    const call = raw.match(UI_CALL);
    if (!call) continue;
    const literals = [...raw.matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((m) => m[1].replace(/\\"/g, '"'));
    const expression = normalizeText(call[1]?.replace(/;.*$/, ""));
    const dynamic = /\+|\b(?:Get|Format|Resolve|Name|label|text|title|message)\b/i.test(expression) || literals.length === 0;
    const semanticLine = raw.replace(/\bDebug\.(?:Notification|MessageBox)\b/gi, "player-ui-call");
    const excluded = devFunction || DEV_ONLY.test(semanticLine);
    const line = index + 1;
    const values = [...literals];
    if (dynamic) values.push(`[dynamic expression] ${expression}`);
    values.forEach((value, ordinal) => {
      if (!normalizeText(value) || /^[a-z][a-z0-9_.-]*$/.test(normalizeText(value))) return;
      rows.push({
        sourceKind: "papyrus",
        copyId: `psc:${toPosix(sourcePath)}:${line}:${ordinal}:${stableHash(value, 8)}`,
        surface: inferPapyrusSurface(raw),
        runtimeLocation: `${toPosix(sourcePath)}:${line} (${functionName})`,
        runtimeAuthority: "tracked live-source Papyrus",
        runtimeText: normalizeText(value),
        functionName,
        dynamic,
        manualReview: dynamic,
        excluded,
        exclusionReason: excluded ? "developer/debug/proof surface" : "",
      });
    });
  }
  return rows;
}

function inferPapyrusSurface(line) {
  if (/Prisma/i.test(line)) return "prisma-label";
  if (/BookOfDays/i.test(line)) return "book-text";
  if (/Notification/i.test(line)) return "notification";
  if (/Survey|SetInfoText/i.test(line)) return "survey-readout";
  if (/MessageBox|ShowMessage/i.test(line)) return "message-body";
  return "papyrus-runtime";
}

export function extractPrismaCopy(text, sourcePath) {
  const rows = [];
  const extension = path.extname(sourcePath).toLowerCase();
  if (extension === ".html") {
    const clean = text.replace(/<!--[\s\S]*?-->/g, "").replace(/<script[\s\S]*?<\/script>/gi, "").replace(/<style[\s\S]*?<\/style>/gi, "");
    for (const match of clean.matchAll(/>([^<>]+)</g)) {
      const value = decodeHtml(match[1]).replace(/\s+/g, " ").trim();
      if (!value || value === "x") continue;
      const line = text.slice(0, match.index).split(/\r?\n/).length;
      rows.push(prismaRow(sourcePath, line, value, false));
    }
    for (const match of text.matchAll(/\b(?:aria-label|title|placeholder)="([^"]+)"/g)) {
      const line = text.slice(0, match.index).split(/\r?\n/).length;
      rows.push(prismaRow(sourcePath, line, decodeHtml(match[1]), false));
    }
  } else {
    const visibleHint = /(?:textContent|innerText|title|message|label|summary|advisory|empty|fallback|toast)/i;
    for (const [index, raw] of text.split(/\r?\n/).entries()) {
      if (!visibleHint.test(raw) || DEV_ONLY.test(raw)) continue;
      for (const match of raw.matchAll(/(["'`])([^"'`]{2,240})\1/g)) {
        const value = match[2].replace(/\$\{[^}]+\}/g, "%s").trim();
        if (!/[A-Za-z]/.test(value) || /^[.#\[\]{}()/:_-]+$/.test(value) || /^[a-z][a-z0-9_.-]*$/.test(value) || /^[.#]/.test(value)) continue;
        rows.push(prismaRow(sourcePath, index + 1, value, match[1] === "`" && /\$\{/.test(match[2])));
      }
    }
  }
  return dedupeBy(rows, (row) => `${row.runtimeLocation}|${row.runtimeText}`);
}

function prismaRow(sourcePath, line, value, dynamic) {
  const text = normalizeText(value);
  return {
    sourceKind: "prisma",
    copyId: `prisma:${toPosix(sourcePath)}:${line}:${stableHash(text, 8)}`,
    surface: "prisma-label",
    runtimeLocation: `${toPosix(sourcePath)}:${line}`,
    runtimeAuthority: "tracked Prisma view",
    runtimeText: text,
    dynamic,
    manualReview: dynamic,
    excluded: false,
    exclusionReason: "",
  };
}

function decodeHtml(value) {
  return value.replace(/&times;/g, "x").replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
}

export function buildCensus({ runtimeRows, manifestRows, sourceFingerprint = {}, sourceClasses = [], extractionCoverage = {} }) {
  const manifestById = new Map(manifestRows.map((row) => [row.slotId, row]));
  const rows = runtimeRows.filter((row) => !row.excluded).map((runtime) => enrichRuntimeRow(runtime, manifestById));
  const runtimeIds = new Set(runtimeRows.filter((row) => row.editorId).map((row) => row.editorId));
  for (const manifest of manifestRows) {
    if (runtimeIds.has(manifest.slotId)) continue;
    const authored = parseAuthoredProse(manifest.prose);
    rows.push({
      copyId: `reference:${manifest.slotId}`,
      journey: inferJourney(manifest.slotId, manifest.section),
      event: inferEvent(manifest.slotId, manifest.firingCondition),
      surface: normalizeManifestSurface(manifest.surface),
      visibility: "writing-reference-only",
      runtimeLocation: "",
      runtimeAuthority: "",
      runtimeText: "",
      gameplayContractSource: "unresolved current gameplay authority",
      gameplayContract: `Reference claim only, pending current-source confirmation: ${manifest.firingCondition}`,
      referenceLocation: `${manifest.sourcePath}:${manifest.line}`,
      referenceText: authored.body || authored.title || authored.direct,
      referenceAuthority: "authoring manifest reference bank; not presumed live",
      voice: manifest.voice,
      voiceProfileRef: voiceProfileFor(manifest.slotId, manifest.section),
      playerJob: inferPlayerJob(manifest.slotId, manifest.surface),
      characterBudget: parseBudget(manifest.budget),
      parity: "reference-only-no-live-match",
      risk: "P1",
      riskBasis: "authored reference has no matching live EditorID in the extracted record set",
      researchNeeded: false,
      editorialStatus: "census-review",
      ownerNote: "Confirm whether this row is intentionally dynamic, V2-only, retired, or missing from runtime.",
      dynamic: false,
      manualReview: true,
    });
  }
  rows.sort((a, b) => a.copyId.localeCompare(b.copyId));
  const excluded = runtimeRows.filter((row) => row.excluded).length;
  return {
    schema: CENSUS_SCHEMA,
    scope: {
      included: ["live Devotion.esp player-facing fields", "tracked player-facing Papyrus and MCM", "Prisma view", "Survey Devotion", "Book of Days", "race and Daedric authoring manifests as reference"],
      excluded: ["player guides", "installers", "compatibility documentation", "developer/debug/proof surfaces", "archives", "retired material"],
    },
    authorities: {
      runtimeText: "what the current live record or tracked runtime source exposes to the player",
      gameplayContract: "what the cited current feature source says the event does",
      writingReference: "prior prose, lore, or tone material that may be reused but is not presumed live",
    },
    sourceClasses,
    sourceFingerprint,
    extractionCoverage,
    summary: summarize(rows, excluded),
    rows,
  };
}

function enrichRuntimeRow(runtime, manifestById) {
  const manifest = manifestForRuntime(runtime, manifestById);
  const authored = manifest ? parseAuthoredProse(manifest.prose) : null;
  const referenceText = manifest ? referenceForField(authored, runtime.fieldPath) : "";
  const parity = !manifest ? "runtime-only-no-reference" : equivalent(runtime.runtimeText, referenceText) ? "exact" : "runtime-reference-differ";
  const surface = runtime.surface;
  const budget = manifest ? parseBudget(manifest.budget) : SURFACE_BUDGETS[surface] ?? null;
  const overBudget = budget != null && runtime.runtimeText.length > budget;
  const internal = DEV_ONLY.test(runtime.runtimeText);
  const gameplay = gameplayContractForRuntime(runtime, manifest);
  let risk = "P3";
  let riskBasis = "clear runtime copy; optional editorial polish only";
  if (internal) { risk = "P1"; riskBasis = "player copy appears to contain developer/proof language"; }
  else if (overBudget) { risk = "P1"; riskBasis = `runtime text exceeds the ${budget}-character surface cap`; }
  else if (!manifest && runtime.sourceKind === "esp") { risk = "P2"; riskBasis = "live record lacks a matched writing reference"; }
  else if (parity === "runtime-reference-differ") { risk = "P2"; riskBasis = "live text differs from its prior writing reference; discrepancy needs diagnosis"; }
  else if (runtime.dynamic) { risk = "P1"; riskBasis = "dynamic assembly requires contextual/manual review"; }
  if (gameplay.risk) { risk = gameplay.risk; riskBasis = gameplay.riskBasis; }
  return {
    copyId: runtime.copyId,
    journey: inferJourney(runtime.editorId ?? runtime.runtimeLocation, manifest?.section ?? ""),
    event: inferEvent(`${runtime.editorId ?? runtime.functionName ?? ""} ${runtime.fieldPath ?? ""} ${runtime.runtimeText}`, manifest?.firingCondition ?? runtime.functionName ?? ""),
    surface,
    visibility: runtime.visibility ?? "player-visible",
    runtimeLocation: runtime.runtimeLocation,
    runtimeAuthority: runtime.runtimeAuthority,
    runtimeText: runtime.runtimeText,
    gameplayContractSource: gameplay.source,
    gameplayContract: gameplay.meaning,
    referenceLocation: manifest ? `${manifest.sourcePath}:${manifest.line}` : "",
    referenceText,
    referenceAuthority: manifest ? "authoring manifest reference bank; not presumed live" : "",
    voice: manifest?.voice ?? "unclassified",
    voiceProfileRef: voiceProfileFor(runtime.editorId ?? "", manifest?.section ?? ""),
    playerJob: inferPlayerJob(runtime.editorId ?? "", surface),
    characterBudget: budget,
    parity,
    risk,
    riskBasis,
    researchNeeded: false,
    editorialStatus: parity === "exact" ? "mapped" : "census-review",
    ownerNote: "",
    dynamic: Boolean(runtime.dynamic),
    manualReview: Boolean(runtime.manualReview || parity !== "exact"),
  };
}

function gameplayContractForRuntime(runtime, manifest) {
  const pilot = nordKyneGameplayContract(runtime);
  if (pilot) return pilot;
  if (runtime.sourceKind === "papyrus") {
    return {
      source: runtime.runtimeLocation,
      meaning: runtime.dynamic
        ? "Current runtime function assembles this player surface dynamically; review the neighbouring branch and rendered result."
        : "Current runtime function emits this literal on a player-facing UI call.",
    };
  }
  const referenceClaim = manifest ? ` Prior reference claim: ${manifest.firingCondition}` : "";
  return {
    source: runtime.sourceKind === "prisma" ? runtime.runtimeLocation : "unresolved current gameplay authority",
    meaning: runtime.sourceKind === "prisma"
      ? "Current Prisma view presents this text; the producing gameplay event remains a separate source link."
      : `Live record field is inventoried, but its current firing/attachment contract still requires source linkage.${referenceClaim}`,
  };
}

function nordKyneGameplayContract(runtime) {
  const id = runtime.editorId ?? "";
  const text = runtime.runtimeText ?? "";
  if (id === "PDV_Msg_Nord_Kyne_Offer" && /^MenuButtons\[0\]/.test(runtime.fieldPath ?? "")) {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#DebugAcceptPendingCommitment",
      meaning: "Accept makes Kyne the active deity, synchronizes the focused reward, emits the acceptance cue/toast, and clears the pending offer.",
    };
  }
  if ((id === "PDV_Msg_Nord_Kyne_Offer" && /^MenuButtons\[1\]/.test(runtime.fieldPath ?? "")) || id === "PDV_Msg_Nord_OfferResponse_NotYet") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#DebugDeclinePendingCommitment; #IsCommitmentDeclineDelayActive",
      meaning: "Not Yet clears the pending offer and blocks that deity for one in-game day. It is available for two deferrals; the third offer removes Not Yet and requires Accept or Refuse.",
      risk: "P1",
      riskBasis: "the choice does not state its one-day consequence or two-deferral limit, and the older Nord reference claims a different seven/fourteen-day rule",
    };
  }
  if ((id === "PDV_Msg_Nord_Kyne_Offer" && /^MenuButtons\[2\]/.test(runtime.fieldPath ?? "")) || id === "PDV_Msg_Nord_OfferResponse_Refuse") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#DebugRefusePendingCommitment; #IsCommitmentRefused",
      meaning: "Refuse permanently marks this deity refused in current state, sets commitment rupture, emits a warning toast, and pins a silent Book-of-Days chronicle.",
      risk: "P1",
      riskBasis: "the choice does not communicate its persistent consequence, and the older Nord reference describes cooldown behavior instead",
    };
  }
  if (id === "PDV_Msg_Nord_Kyne_Offer") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#IsEligibleForFormalCommitmentOffer; #GetBestFormalCommitmentOfferCandidate; #ShowFormalCommitmentOffer",
      meaning: "At dawn, an uncommitted Nord can receive the highest-weight eligible offer after reaching 50 piety and recording qualifying signals on two distinct days in the last seven; baseline membership, prior refusal, offered state, and cooldown also gate it.",
    };
  }
  if (id === "PDV_Msg_Nord_Kyne_ChampionEntry") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#MaybeShowNordKyneChampionEntry; #ProcessQueuedNordKyneChampionEntry",
      meaning: "On the first Nord/Kyne Champion-tier reach, queue a one-time modal after the universal tier toast, Book-of-Days entry, and ledger feed; do not suppress those adjacent surfaces.",
    };
  }
  if (id === "PDV_Notif_Nord_Kyne_ChampionAmbient_Storm") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#RunDawnChampionAmbient; #ShowChampionAmbientForDeity",
      meaning: "With notifications enabled, an active Kyne Champion receives this recurring message on the shared four-devotional-day dawn cadence. Current source has no weather condition.",
      risk: "P2",
      riskBasis: "the older writing reference describes a daily storm-weather trigger, but current runtime can surface the line in any weather",
    };
  }
  if (/^PDV_(?:Bless_Nord_Kyne_T[123]|MGEF_Nord_Kyne_T[123])/.test(id)) {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#SyncNordRewardFamily plus direct live SPEL/MGEF fields",
      meaning: "The manager synchronizes the highest applicable focused Kyne reward family; the live record description is the mechanical display authority for the active spell/effect.",
    };
  }
  if (/^PDV_(?:SPEL|MGEF)_Neglect_Kyne/.test(id)) {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#IsPatronLapsed; #SyncKyneNeglectSpell",
      meaning: "After more than three in-game days without a devotional act, an active Kyne patron is lapsed and the dedicated neglect spell is synchronized until the lapse clears.",
    };
  }
  if (/SurveyDevotion/.test(id)) {
    return {
      source: "live-source/Scripts/Source/PDV_SurveyDevotionEffect.psc; live-source/Scripts/Source/PDV__ManagerQuest.psc#GetSurveyDevotionText",
      meaning: "Casting Survey Devotion requests the manager's dynamically assembled current status; the spell record only explains the action.",
    };
  }
  if (id === "PDV_BookOfDays") {
    return {
      source: "live-source/Scripts/Source/PDV__ManagerQuest.psc#AppendBookOfDaysEntry",
      meaning: "The book record is a container surface; event-specific journal text is appended dynamically by the manager.",
    };
  }
  if (/Kyne/i.test(text) && runtime.sourceKind === "papyrus") {
    return {
      source: runtime.runtimeLocation,
      meaning: "Current tracked runtime source emits or assembles this Kyne-facing text.",
    };
  }
  return null;
}

function manifestForRuntime(runtime, manifestById) {
  if (!runtime.editorId) return null;
  const exact = manifestById.get(runtime.editorId);
  if (!/^MenuButtons\[\d+\]\.Text$/.test(runtime.fieldPath ?? "")) return exact;
  const race = runtime.editorId.match(/^PDV_Msg_([A-Za-z]+)_[A-Za-z0-9]+_Offer$/)?.[1];
  if (!race) return exact;
  const index = Number(runtime.fieldPath.match(/\[(\d+)\]/)?.[1]);
  const suffix = ["Accept", "NotYet", "Refuse"][index];
  return suffix ? manifestById.get(`PDV_Msg_${race}_OfferResponse_${suffix}`) ?? exact : exact;
}

function referenceForField(authored, field = "") {
  if (!authored) return "";
  if (field === "Name") return authored.title || (authored.body ? "" : authored.direct);
  if (field === "Description" || field === "BookText" || field === "Prompt" || /^Responses/.test(field)) return authored.body || authored.direct;
  if (/^MenuButtons/.test(field)) return authored.title || authored.body ? "" : authored.direct;
  return authored.direct;
}

function normalizeManifestSurface(surface) {
  if (/notification/i.test(surface)) return "notification";
  if (/messagebox/i.test(surface)) return "message-body";
  if (/blessing/i.test(surface)) return "blessing-description";
  if (/survey|status spell/i.test(surface)) return "survey-readout";
  if (/prisma/i.test(surface)) return "prisma-label";
  if (/dialogue/i.test(surface)) return "dialogue-topic";
  return surface.toLowerCase().replace(/\s+/g, "-");
}

function parseBudget(value) {
  const match = String(value ?? "").match(/^(\d+)/);
  return match ? Number(match[1]) : null;
}

function inferJourney(value, section) {
  const text = `${value} ${section}`;
  const race = text.match(/\b(Altmer|Argonian|Bosmer|Breton|Dunmer|Imperial|Khajiit|Nord|Orc|Redguard)\b/i)?.[1];
  if (race) return titleCase(race);
  if (/Daedric|Azura|Boethiah|Clavicus|Hermaeus|Hircine|Malacath|Mehrunes|Mephala|Meridia|Molag|Namira|Nocturnal|Peryite|Sanguine|Sheogorath|Vaermina/i.test(text)) return "Daedric";
  return "Shared";
}

function inferEvent(value, contract) {
  const text = `${value} ${contract}`;
  if (/OfferResponse_Accept|Accept the/i.test(text)) return "commitment.accept";
  if (/OfferResponse_NotYet|Not Yet/i.test(text)) return "commitment.not-yet";
  if (/OfferResponse_Refuse|Refuse/i.test(text)) return "commitment.refuse";
  if (/Offer/i.test(text)) return "commitment.offer";
  if (/ChampionAmbient.*Storm|storm weather/i.test(text)) return "champion.storm-acknowledgement";
  if (/ChampionEntry|first .*Devoted/i.test(text)) return "champion.entry";
  if (/Neglect|lapse|slipping/i.test(text)) return "neglect.lapse";
  if (/Survey/i.test(text)) return "survey.focused-state";
  if (/BookOfDays|Book of Days/i.test(text)) return "book-of-days.entry";
  if (/Prisma/i.test(text)) return "prisma.presentation";
  if (/_T1(?:\b|_)|Tier 1|Seeker/i.test(text)) return "tier.initial-recognition";
  if (/_T2(?:\b|_)|Tier 2|Faithful/i.test(text)) return "tier.faithful";
  if (/_T3(?:\b|_)|Tier 3|Devoted/i.test(text)) return "tier.devoted";
  return "unclassified";
}

function inferPlayerJob(value, surface) {
  const text = `${value} ${surface}`;
  if (/OfferResponse/i.test(text)) return "Make the consequence of this choice legible from the player's seat.";
  if (/Offer/i.test(text)) return "Understand who is asking, what commitment means, and that a choice is required.";
  if (/Bless|tier/i.test(text)) return "Recognize the new standing and understand the active mechanical effect.";
  if (/Survey/i.test(text)) return "Scan current devotion, direction, and any problem that needs attention.";
  if (/Neglect|lapse/i.test(text)) return "Notice loss of regard and understand how to recover it.";
  if (/Champion/i.test(text)) return "Feel earned recognition while understanding the state transition.";
  if (/Prisma|Book/i.test(text)) return "Place the event in the surrounding devotional record without contradicting gameplay.";
  return "Understand the immediate player-facing state or action.";
}

function voiceProfileFor(value, section) {
  if (/Kyne/i.test(value)) return "race-sheets/PDV_RaceContent_Manifest.md#10.1:Kyne";
  if (/Nord/i.test(`${value} ${section}`)) return "race-sheets/PDV_RaceContent_Manifest.md#10.1";
  if (/Daedric/i.test(section)) return "race-sheets/PDV_DaedricContent_Manifest.md voice profile for matched Prince";
  return "matched race/deity tone profile in existing content material";
}

function equivalent(a, b) {
  if (!a || !b) return false;
  return normalizeText(a).replace(/\s+/g, " ") === normalizeText(b).replace(/\s+/g, " ");
}

function summarize(rows, excluded) {
  const count = (key) => Object.fromEntries([...new Set(rows.map((row) => row[key]))].sort().map((value) => [value, rows.filter((row) => row[key] === value).length]));
  return {
    rowCount: rows.length,
    dynamicManualReview: rows.filter((row) => row.dynamic || row.manualReview).length,
    excludedDeveloperDebug: excluded,
    bySurface: count("surface"),
    byParity: count("parity"),
    byRisk: Object.fromEntries(["P0", "P1", "P2", "P3"].map((risk) => [risk, rows.filter((row) => row.risk === risk).length])),
  };
}

export function validateCensus(census) {
  const errors = [];
  if (census?.schema !== CENSUS_SCHEMA) errors.push(`schema must be ${CENSUS_SCHEMA}`);
  if (!Array.isArray(census?.rows)) errors.push("rows must be an array");
  if (!census?.extractionCoverage || typeof census.extractionCoverage !== "object") errors.push("extractionCoverage must be an object");
  const required = ["copyId", "journey", "event", "surface", "visibility", "runtimeLocation", "runtimeText", "gameplayContractSource", "gameplayContract", "referenceLocation", "referenceText", "voiceProfileRef", "playerJob", "parity", "risk", "researchNeeded", "editorialStatus", "dynamic", "manualReview"];
  const ids = new Set();
  for (const [index, row] of (census?.rows ?? []).entries()) {
    for (const field of required) if (!(field in row)) errors.push(`rows[${index}] missing ${field}`);
    if (ids.has(row.copyId)) errors.push(`duplicate copyId ${row.copyId}`);
    ids.add(row.copyId);
    if (!/^P[0-3]$/.test(row.risk ?? "")) errors.push(`${row.copyId}: invalid risk ${row.risk}`);
    if (row.characterBudget != null && (!Number.isInteger(row.characterBudget) || row.characterBudget < 1)) errors.push(`${row.copyId}: invalid characterBudget`);
  }
  return errors;
}

export function renderCsv(census) {
  const keys = ["copyId", "journey", "event", "surface", "visibility", "runtimeLocation", "runtimeText", "gameplayContractSource", "gameplayContract", "referenceLocation", "referenceText", "voice", "voiceProfileRef", "playerJob", "characterBudget", "parity", "risk", "riskBasis", "researchNeeded", "editorialStatus", "ownerNote", "dynamic", "manualReview"];
  return `${keys.map(csvCell).join(",")}\n${census.rows.map((row) => keys.map((key) => csvCell(row[key])).join(",")).join("\n")}\n`;
}

export function renderFormalOfferUx(census) {
  const offerRows = census.rows.filter((row) => {
    const location = `${row.runtimeLocation} ${row.copyId}`;
    return /PDV_Msg_[A-Za-z]+_[A-Za-z0-9]+_Offer/i.test(location)
      || /PDV_Msg_Daedric_[A-Za-z0-9]+_Commitment/i.test(location);
  });
  const groups = {};
  for (const row of offerRows) {
    const location = `${row.runtimeLocation} ${row.copyId}`;
    const race = location.match(/PDV_Msg_(Nord|Imperial|Breton|Dunmer|Altmer|Redguard)_/i)?.[1];
    const group = /PDV_Msg_Daedric_/i.test(location) ? "Daedric" : race ? titleCase(race) : (row.journey || "Shared");
    (groups[group] ??= []).push({
      copyId: row.copyId, event: row.event, surface: row.surface, visibility: row.visibility,
      runtimeLocation: row.runtimeLocation, runtimeText: row.runtimeText,
      gameplayContract: row.gameplayContract, referenceLocation: row.referenceLocation,
      referenceText: row.referenceText, parity: row.parity, risk: row.risk,
      ownerDraft: "", ownerStatus: "awaiting-owner-draft-or-lock", technicalReview: "",
    });
  }
  for (const rows of Object.values(groups)) rows.sort((a, b) => a.copyId.localeCompare(b.copyId));
  return {
    schema: "pdv.formal-offer-ux.v1",
    authority: "working view generated from the copy census; ownerDraft is the only creative authority",
    prosePolicy: "Do not rewrite owner prose. Flag only a mechanical contradiction, surface mismatch, encoding conflict, or implementation blocker.",
    mechanics: {
      offerChoices: ["Accept", "Not Yet", "Refuse"],
      notYet: "Available for the first two deferrals; each deferral delays that deity for one in-game day.",
      thirdOffer: "Not Yet is hidden; the player must Accept or Refuse.",
      refuse: "Persistent refusal in current state, with commitment rupture and journal/toast aftermath.",
      headings: "MESG Name is metadata in vanilla Skyrim; a Prisma choice surface is required to display it as a heading.",
    },
    trancheOrder: ["Nord", "Imperial", "Breton", "Dunmer", "Altmer", "Redguard", "Daedric"],
    groups,
  };
}

export function renderPietyNarrativeViability() {
  return {
    schema: "pdv.piety-narrative-viability.v1",
    decision: "investigate-independently-do-not-implement",
    question: "Can commitment wording accurately name the two or three strongest kinds of devotional acts the character performed?",
    currentEvidence: [
      { seam: "PDV__ManagerQuest.AwardPietyInternal / RecordDeityDriver", finding: "Piety awards already pass through a common manager seam and record recent driver labels.", limitation: "The recent-driver ring is presentation history, not a durable contribution ledger, and cannot prove lifetime or offer-window leaders." },
      { seam: "likes/dislikes keyword rows and event routes", finding: "Many awards have stable action or source labels that could map into narrative buckets.", limitation: "Some awards are generic, repeated, indirect, or multi-deity; bucket semantics need an explicit reviewed map." },
    ],
    minimumViableModel: {
      window: "Since the last commitment decision reset, or a deliberately chosen rolling window.",
      storage: "Per-deity numeric totals by reviewed narrative bucket; do not infer from current piety alone.",
      ranking: "Choose top two distinct buckets by contributed piety; use deterministic tie-breaking and a minimum evidence floor.",
      fallback: "Use the approved static offer whenever fewer than two reliable buckets qualify.",
      proseBoundary: "The subsystem supplies factual act labels only. The owner writes and approves every sentence template.",
    },
    candidateBuckets: ["mercy-and-protection", "battle-and-courage", "rites-and-the-dead", "craft-and-honest-exchange", "study-and-magic", "home-and-kinship", "travel-and-open-sky", "defiance-and-law", "hunt-and-wilderness", "deception-and-secrecy"],
    unknownsToResolve: [
      "Whether ranking should use raw piety, capped contribution, frequency, recency, or a hybrid.",
      "Which existing routes expose a stable action key before AwardPietyInternal.",
      "Whether negative acts subtract from the same bucket or remain separate context.",
      "Save migration, reset boundary, and StorageUtil growth limits.",
      "How to prevent repetitive or absurd pairings across deities and cultures.",
    ],
    viabilityGate: [
      "At least 90 percent of positive award routes map deterministically to a reviewed bucket or explicit ignore state.",
      "A simulation over representative play histories produces stable, explainable leaders.",
      "The static fallback remains correct for every offer.",
      "No generated wording is shipped without owner-approved templates.",
    ],
  };
}

export function renderPenpotUxMapSvg() {
  const nodes = [
    [40,70,170,64,"Eligible at dawn","50 piety + 2 signal days"], [260,70,170,64,"Offer 1","Accept / Not Yet / Refuse"],
    [480,20,170,64,"Accept","Commit to patron"], [480,110,170,64,"Not Yet #1","Delay one day"], [700,110,170,64,"Offer 2","Three choices remain"],
    [920,110,170,64,"Not Yet #2","Delay one day"], [1140,110,170,64,"Offer 3","Accept / Refuse only"], [480,200,170,64,"Refuse","Persistent rupture"],
    [1140,20,170,64,"Accept","Commit to patron"], [1140,200,170,64,"Refuse","Persistent rupture"],
    [40,330,260,110,"Vanilla fallback","Body + conditional buttons\nMESG Name not rendered"], [350,330,260,110,"Prisma enhanced offer","Visible heading + approved body\nNon-pausing choice panel"],
    [660,330,260,110,"Owner prose authority","Exact workbook cells only\nTechnical review, no rewriting"], [970,330,340,110,"Dynamic-act investigation","Rank top factual buckets\nStatic approved fallback required"],
  ];
  const arrows = [[210,102,260,102],[430,102,480,52],[430,102,480,142],[430,102,480,232],[650,142,700,142],[870,142,920,142],[1090,142,1140,142],[1225,110,1225,84],[1225,174,1225,200],[170,330,170,264],[480,330,480,264],[790,330,790,264],[1140,330,1140,264]];
  const esc = (value) => String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const nodeSvg = nodes.map(([x,y,w,h,title,body]) => `<g><rect x="${x}" y="${y}" width="${w}" height="${h}" rx="12" fill="#172033" stroke="#7dd3fc" stroke-width="2"/><text x="${x+14}" y="${y+25}" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="15" font-weight="700">${esc(title)}</text>${body.split("\n").map((line,i)=>`<text x="${x+14}" y="${y+49+i*18}" fill="#cbd5e1" font-family="Inter,Arial,sans-serif" font-size="12">${esc(line)}</text>`).join("")}</g>`).join("");
  const arrowSvg = arrows.map(([x1,y1,x2,y2]) => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="#94a3b8" stroke-width="2" marker-end="url(#arrow)"/>`).join("");
  return `<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="1360" height="480" viewBox="0 0 1360 480"><rect width="1360" height="480" fill="#0b1020"/><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#94a3b8"/></marker></defs><text x="40" y="38" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="24" font-weight="700">PDV Formal Commitment UX Map</text>${arrowSvg}${nodeSvg}</svg>\n`;
}

function csvCell(value) {
  const text = value == null ? "" : String(value).replace(/\r?\n/g, "\\n");
  return `"${text.replace(/"/g, '""')}"`;
}

export function renderNordKynePacket(census) {
  const rows = census.rows.filter(isNordKynePilotRow);
  const ordered = rows.sort((a, b) => `${a.event}|${a.copyId}`.localeCompare(`${b.event}|${b.copyId}`));
  const calibration = selectNordKyneCalibrationRows(ordered);
  const table = ordered.map((row) => `| ${escapeTable(row.event)} | ${escapeTable(row.surface)} | ${escapeTable(shortLocation(row.runtimeLocation))} | ${escapeTable(row.runtimeText || "[reference only]")} | ${escapeTable(row.parity)} |`).join("\n");
  const taste = calibration.map(({ row, stage, context, job }) => `| ${escapeTable(stage)} | ${escapeTable(context)} | ${escapeTable(job)} | ${escapeTable(row.runtimeText || row.referenceText)} |  |  |`).join("\n");
  return `# Nord/Kyne Prose-Uplift Learning Packet\n\n` +
    `Generated from the current local census. This packet maps evidence; it does not approve or rewrite copy.\n\n` +
    `## Authority boundary\n\n` +
    `- Runtime text: direct live Devotion.esp readback or tracked runtime source.\n` +
    `- Gameplay contract: the cited current firing condition or neighbouring runtime function.\n` +
    `- Writing reference: existing prose and tone material, never presumed live.\n\n` +
    `## Voice and theology references\n\n` +
    `- Kyne profile: cold, clear weather imagery; spare lines; the storm in the sentence; addresses the hunter, not the citizen.\n` +
    `- Primary contextual sources: race-sheets/PDV_RaceDesign_Nord.md and race-sheets/PDV_RaceContent_Manifest.md Sections 10.1-10.7.\n` +
    `- External research: none required yet. Open it only for a named contradiction or missing theological fact.\n\n` +
    `## Mechanical truth locked for the pilot\n\n` +
    `- Initial through Champion rewards: the manager synchronizes the highest applicable focused Kyne spell; live SPEL/MGEF descriptions are the current mechanical display.\n` +
    `- Offer: at dawn, while uncommitted, Kyne needs at least 50 piety plus qualifying signals on two distinct days in the last seven; baseline, offered/refused state, and delay gates also apply. The highest-weight eligible deity offers first.\n` +
    `- Accept: makes Kyne active, synchronizes the focused reward, emits acceptance presentation, and clears the pending offer.\n` +
    `- Not Yet: clears the pending offer and delays Kyne for one in-game day without piety loss. It may be selected twice; on the third offer the button is removed.\n` +
    `- Refuse: records a persistent refusal in current state, sets commitment rupture, emits a warning toast, and pins a Book-of-Days chronicle.\n` +
    `- Champion: the first Champion-tier reach queues Kyne's one-time modal in addition to the universal tier toast, journal entry, and ledger feed.\n` +
    `- Lapse: more than three in-game days without a devotional act activates Kyne's dedicated neglect spell until the lapse clears.\n\n` +
    `## First diagnostic findings\n\n` +
    `- Surface correction: Skyrim's vanilla MessageBox does not render a MESG Name field. Rows such as \`Kyne Reaches Back\` and \`Kyne's Recognition\` are record metadata/intended-heading evidence, not current visible headings.\n` +
    `- Authority drift: the older Nord reference says seven/fourteen-day decline cooldowns; current source implements a one-day Not Yet delay and persistent Refuse state. Treat current source as the mechanic unless design deliberately changes it.\n` +
    `- Owner wording lock: approved workbook drafts are not subject to assistant prose correction. Review only mechanical contradiction, surface mismatch, encoding conflict, or implementation blocker.\n` +
    `- Adjacency risk: Champion recognition is intentionally additive, so the modal must be reviewed beside the universal tier toast, Book-of-Days entry, and ledger feed rather than in isolation.\n\n` +
    `- Trigger drift: the older manifest calls the Champion ambient line storm-gated and daily. Current source emits it for an active Kyne Champion on the general four-devotional-day dawn cadence, with no weather condition.\n` +
    `- Reachability correction: \`PDV_MGEF_Neglect_Kyne\` (\`06FF8F\`) has no live references and is not the effect used by the current neglect spell. The calibration below uses the linked \`PDV_MGEF_Neglect_Kyne_Stamina\` / \`PDV_SPEL_Neglect_Kyne\` copy instead.\n\n` +
    `## Pilot order\n\n` +
    `1. Initial recognition and active T1 blessing.\n2. Faithful threshold and commitment offer.\n3. Accept, Not Yet, and Refuse branches.\n4. Focused Survey, Prisma, and Book-of-Days adjacency.\n5. Champion entry and storm acknowledgement.\n6. Neglect or lapse feedback.\n\n` +
    `For each event: lock mechanics and the actual rendered surface; use the owner's exact approved draft; flag only a mechanical contradiction, surface mismatch, encoding conflict, or implementation blocker; then read it beside adjacent and alternate branches.\n\n` +
    `## Current journey text\n\n| Event | Surface | Runtime location | Current text | Parity |\n|---|---|---|---|---|\n${table || "| [none] | | | | |"}\n\n` +
    `## Taste calibration\n\nEach row identifies the actual surface and trigger. Mark Accept or Reject, then name the observable reason: clarity, theological fit, rhythm, narrator distance, cliche, repetition, or another concrete trait.\n\n| Journey stage | Where and when it appears | What the line must accomplish | Existing line | Accept / Reject | Observable reason |\n|---|---|---|---|---|---|\n${taste || "| [No static pilot lines extracted] | | | | | |"}\n\n` +
    `## Editorial working fields\n\nFor the selected event, record: mechanical truth; player decision; comprehension job; emotional beat; theological beat; neighbouring line before; neighbouring line after; chosen direction; owner draft; required corrections; likely improvements; taste calls; approved minimal edit; wire-in authority; static readback; in-game presentation proof.\n`;
}

function selectNordKyneCalibrationRows(rows) {
  const specs = [
    ["Initial recognition", /PDV_Bless_Nord_Kyne_T1:Name\s/i, "Spell/Active Effects heading when the first focused Kyne reward is active.", "Name the reward and standing clearly at a glance."],
    ["Initial recognition", /PDV_Bless_Nord_Kyne_T1:Description\s/i, "Tooltip beneath the first focused Kyne reward.", "Combine an earned theological beat with the exact current benefit."],
    ["Faithful reward", /PDV_Bless_Nord_Kyne_T2:Description\s/i, "Tooltip after the focused Kyne reward advances to its middle tier.", "Show deepening recognition without hiding the current mechanics."],
    ["Champion reward", /PDV_Bless_Nord_Kyne_T3:Description\s/i, "Tooltip after the focused Kyne reward reaches Champion.", "Make the culmination feel distinct while remaining mechanically accurate."],
    ["Commitment offer heading metadata", /PDV_Msg_Nord_Kyne_Offer:Name\s/i, "MESG record Name. Vanilla Skyrim does not render it above the modal body; it becomes visible only if an enhanced surface deliberately presents it.", "Record the intended heading without claiming it is currently player-visible."],
    ["Commitment offer", /PDV_Msg_Nord_Kyne_Offer:Description\s/i, "Body of that modal, immediately above the three response buttons.", "Make the invitation, speaker, and choice legible without generic fantasy solemnity."],
    ["Accept choice", /PDV_Msg_Nord_Kyne_Offer:MenuButtons\[0\]\.Text\s/i, "First offer button; choosing it makes Kyne the active patron immediately.", "State affirmative commitment from the player's seat."],
    ["Not Yet choice", /PDV_Msg_Nord_Kyne_Offer:MenuButtons\[1\]\.Text\s/i, "Second offer button; clears the offer and delays Kyne for one in-game day.", "Communicate postponement rather than refusal, with enough consequence clarity."],
    ["Refuse choice", /PDV_Msg_Nord_Kyne_Offer:MenuButtons\[2\]\.Text\s/i, "Third offer button; records persistent refusal, rupture, toast, and chronicle state.", "Make the durable rejection distinguishable from Not Yet."],
    ["Champion heading metadata", /PDV_Msg_Nord_Kyne_ChampionEntry:Name\s/i, "MESG record Name. Vanilla Skyrim does not render it above the one-time Champion body; it becomes visible only on an enhanced surface.", "Record the intended heading without claiming it is currently player-visible."],
    ["Champion recognition", /PDV_Msg_Nord_Kyne_ChampionEntry:Description\s/i, "Body of the one-time modal, shown in addition to tier toast, journal, and ledger surfaces.", "Deliver earned divine recognition without repeating the adjacent status surfaces."],
    ["Champion life", /PDV_Notif_Nord_Kyne_ChampionAmbient_Storm:Description\s/i, "Recurring message for an active Kyne Champion on the four-devotional-day dawn cadence; it is not weather-gated in current source.", "Provide quiet ongoing texture that still makes sense outside storm weather."],
    ["Focused Survey", /reference:PDV_Msg_Nord_Survey_Focused\s/i, "Older reference draft for the focused Survey state; current Survey text is assembled dynamically, so this is not confirmed live wording.", "Summarize patron, standing, and bond in a fast status readout."],
    ["Lapse", /PDV_SPEL_Neglect_Kyne:Name\s/i, "Spell and Active Effects heading after more than three in-game days without a devotional act.", "Name Kyne's withdrawal without implying a mechanic the effect does not have."],
    ["Lapse", /PDV_SPEL_Neglect_Kyne:Description\s/i, "Spell tooltip while the current -8% Frost Resistance neglect effect is active.", "Explain the felt loss, exact penalty, and recovery route."],
    ["Book of Days entry point", /PDV_MCM\.psc:.*OpenBookOfDaysFromMcm.*The Book of Days opens\./i, "Brief notification after the player chooses the MCM journal action, immediately before Prisma opens the journal.", "Confirm the action without competing with the journal itself."],
  ];
  const selected = [];
  for (const [stage, pattern, context, job] of specs) {
    const row = rows.find((candidate) => pattern.test(`${candidate.copyId} ${candidate.runtimeLocation} ${candidate.runtimeText}`));
    if (row) selected.push({ row, stage, context, job });
  }
  return selected;
}

function isNordKynePilotRow(row) {
  const text = `${row.copyId} ${row.runtimeLocation} ${row.referenceLocation} ${row.runtimeText} ${row.gameplayContract}`;
  const stableRuntime = /PDV_(?:Bless_Nord_Kyne_T[123]|MGEF_Nord_Kyne_T[123]|SPEL_Neglect_Kyne|MGEF_Neglect_Kyne|Msg_Nord_Kyne_(?:Offer|ChampionEntry)|Notif_Nord_Kyne_ChampionAmbient_Storm|SPEL_SurveyDevotion|MGEF_SurveyDevotion|BookOfDays)/i.test(text);
  const stableReference = /PDV_(?:Notif_Nord_Kyne_NeglectTexture|Msg_Nord_Survey_Focused|Msg_Nord_Survey_FocusedSlipping|Msg_Nord_OfferResponse_(?:Accept|NotYet|Refuse))/i.test(text);
  const prismaAdjacency = /^(?:Current patron|Tier|Public recognition|Today|Recent signs|No patron has answered yet\.|Adherents remain neutral until your standing is Faithful\.|No devotional acts have been recorded yet\.)$/i.test(row.runtimeText);
  const meaningfulDynamic = /PDV_SurveyDevotionEffect\.psc/i.test(row.runtimeLocation)
    || (/BookOfDays/i.test(row.runtimeLocation) && /\s/.test(row.runtimeText) && row.runtimeText.length > 18)
    || (/Prisma/i.test(row.runtimeLocation) && prismaAdjacency);
  return stableRuntime || stableReference || meaningfulDynamic;
}

function shortLocation(value) {
  if (!value) return "[not live-matched]";
  return value.replace(/^.*?(Devotion\.esp:)/, "$1").replace(/^.*?(live-source\/)/, "$1");
}

function escapeTable(value) {
  return String(value ?? "").replace(/\r?\n/g, "<br>").replace(/\|/g, "\\|");
}

function toPosix(value) { return String(value).replace(/\\/g, "/"); }
function titleCase(value) { return value[0].toUpperCase() + value.slice(1).toLowerCase(); }
function dedupeBy(values, keyFn) { const seen = new Set(); return values.filter((value) => { const key = keyFn(value); if (seen.has(key)) return false; seen.add(key); return true; }); }

export function readUtf8(filePath) { return fs.readFileSync(filePath, "utf8"); }
export function recordTypes() { return RECORD_TYPES; }
