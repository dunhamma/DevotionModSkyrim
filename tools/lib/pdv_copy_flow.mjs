import fs from "node:fs";
import { stableHash } from "./pdv_copy_census.mjs";

export const FLOW_SCHEMA = "pdv.copy-flow-workbench.v1";
export const EXCHANGE_SCHEMA = "pdv.copy-prose-exchange.v1";

const RACES = ["altmer", "argonian", "bosmer", "breton", "dunmer", "imperial", "khajiit", "nord", "orc", "redguard"];
const PRINCES = /azura|boethiah|clavicus|hermaeus|hircine|malacath|mehrunes|mephala|meridia|molag|namira|nocturnal|peryite|sanguine|sheogorath|vaermina/i;

export function buildCopyFlowModel(census, manifest) {
  validateFlowManifest(manifest);
  const known = new Set(manifest.nodes.map((node) => node.id));
  const assignments = census.rows.map((row) => {
    const flowIds = assignFlowIds(row).filter((id) => known.has(id));
    return {
      copyId: row.copyId,
      flowIds: [...new Set(flowIds)].sort(),
      runtime: Boolean(row.runtimeLocation && row.runtimeText),
      dynamic: Boolean(row.dynamic),
      manualReview: Boolean(row.manualReview),
    };
  });
  const byCopyId = new Map(assignments.map((row) => [row.copyId, row]));
  const nodes = manifest.nodes.map((node) => {
    const attached = assignments.filter((row) => row.flowIds.includes(node.id));
    return {
      ...node,
      counts: {
        all: attached.length,
        live: attached.filter((row) => row.runtime).length,
        dynamic: attached.filter((row) => row.dynamic).length,
        manual: attached.filter((row) => row.manualReview).length,
      },
    };
  });
  return {
    schema: FLOW_SCHEMA,
    authority: manifest.authority,
    roundTripPolicy: manifest.roundTripPolicy,
    sourceCensusSchema: census.schema,
    sourceFingerprint: stableHash(census.sourceFingerprint ?? census.rows.map((row) => row.copyId), 32),
    sections: manifest.sections,
    nodes,
    edges: manifest.edges,
    assignments,
    summary: {
      copyRows: assignments.length,
      liveRows: assignments.filter((row) => row.runtime).length,
      unresolvedLiveRows: assignments.filter((row) => row.runtime && row.flowIds.includes("flow.unresolved")).length,
      missingSurfaceRows: assignments.filter((row) => row.runtime && !row.flowIds.some((id) => id.startsWith("surface."))).length,
    },
    byCopyId,
  };
}

export function assignFlowIds(row) {
  const text = `${row.copyId} ${row.runtimeLocation} ${row.runtimeText} ${row.gameplayContract} ${row.referenceLocation} ${row.referenceText}`.toLowerCase();
  const ids = [];
  const race = RACES.find((name) => text.includes(name));
  if (race) ids.push(`race.${race}`);

  const daedric = row.journey === "Daedric" || PRINCES.test(text) || /daedric/.test(text);
  const eventId = eventFlowId(row, daedric, text);
  if (eventId) ids.push(eventId);
  else if (row.runtimeLocation && row.runtimeText) ids.push("flow.unresolved");

  if (/prayer|shrine|medallion/.test(text)) ids.push("signal.prayer");
  if (/quest.?reaction|questreaction|quest stage|setstage/.test(text)) ids.push("signal.quest");
  if (/likes.?dislikes|awardpietyfrom|liked act|disliked act/.test(text)) ids.push("signal.likes");
  if (/\bkid\b|craft|consume|food|drink|equipment|armor|weapon|offering/.test(text)) ids.push("signal.item");
  if (/sleep|weather|storm|combat|curse|book|world|cultural|heritage/.test(text)) ids.push("signal.world");

  ids.push(surfaceFlowId(row));
  return [...new Set(ids)];
}

function eventFlowId(row, daedric, text) {
  const event = row.event;
  if (/checkpapyrusutildependency|prepareforuninstall|ensureinfoonlystartup|recordcustomracefallback|show(?:altmer|khajiit|nord|orc|redguard)message|showtoastfallbacknotification|surveydevotioneffect/.test(text)) return "journey.system-ux";
  if (/showcapstonenotice|championambient/.test(text)) return "core.champion";
  if (/bosmerreckoning|evaluatebosmerforcedreckoning/.test(text)) return "journey.reckoning";
  if (/setupchoice|startup(?:breton|nord|orc|redguard|confirm)choice|suggest(?:banditroad|exchange|livingstory|oldcontract)|handlebosmersuggestionpopup|confirm_(?:bosmer|breton|nord|orc|redguard)|altmerdisciplines/.test(text)) return "journey.origin-choice";
  if (/cursestate|vampireexiledpath/.test(text)) return "journey.curse-transition";
  if (/khajiitmoon_|khajiitfocus_|setkhajiitfocusedemphasis/.test(text)) return "journey.lunar-focus";
  if (/adaptrite|markbed|markhearth|bosmernaming|markhome|trialofiron|fourholds|hearthheld|witnessed|ancestorspine|farshorestoken|sect_(?:ashabah|crown|forebear)|redguardremembering|calian|heritage|sacredwater|sapvision|awardbosmersong/.test(text)) return "journey.cultural-rite";
  if (daedric) {
    if (event === "commitment.offer") return "daedric.offer";
    if (event === "commitment.accept") return "daedric.active";
    if (event === "commitment.refuse" || event === "neglect.lapse") return "daedric.exit";
    if (/champion|tier\./.test(event)) return "daedric.milestone";
    if (/price|stigma|curse/.test(`${event} ${text}`)) return "daedric.price";
    if (/blessing|effect/.test(row.surface)) return "daedric.active";
    if (/survey|prisma|book/.test(row.surface)) return "daedric.active";
    return "daedric.notice";
  }
  const map = {
    "tier.initial-recognition": "core.recognition",
    "tier.faithful": "core.faithful",
    "tier.devoted": "core.focused",
    "commitment.offer": "commit.offer",
    "commitment.accept": "commit.accept",
    "commitment.not-yet": "commit.not-yet",
    "commitment.refuse": "commit.refuse",
    "champion.entry": "core.champion",
    "champion.storm-acknowledgement": "core.champion",
    "neglect.lapse": "core.neglect",
    "survey.focused-state": "core.focused",
    "book-of-days.entry": "core.focused",
    "prisma.presentation": "core.focused",
  };
  if (map[event]) return map[event];
  if (/blessing|effect|survey|prisma|book/.test(row.surface)) return "core.focused";
  if (/mcm/i.test(row.runtimeLocation)) return "core.startup";
  return "";
}

function surfaceFlowId(row) {
  if (/survey/.test(row.surface)) return "surface.survey";
  if (/prisma/.test(row.surface)) return "surface.prisma";
  if (/book/.test(row.surface)) return "surface.book";
  if (/blessing|effect/.test(row.surface)) return "surface.effects";
  if (/message|notification|dialogue/.test(row.surface)) return "surface.message";
  if (/mcm/i.test(row.runtimeLocation)) return "surface.mcm";
  return "surface.other";
}

export function renderFullFlowPenpotSvg(model) {
  const esc = (value) => String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  const ids = new Map(model.nodes.map((node) => [node.id, node]));
  const width = 2400;
  const height = 1960;
  const sections = model.sections.map((section) => `<g id="section-${esc(section.id)}"><rect x="${section.x}" y="${section.y}" width="${section.width}" height="${section.height}" rx="18" fill="#111827" stroke="#334155" stroke-width="2"/><text x="${section.x + 22}" y="${section.y + 34}" fill="#93c5fd" font-family="Inter,Arial,sans-serif" font-size="20" font-weight="700">${esc(section.title)}</text></g>`).join("");
  const edges = model.edges.map(([from, to]) => {
    const a = ids.get(from);
    const b = ids.get(to);
    if (!a || !b) return "";
    return `<line x1="${a.x + 108}" y1="${a.y + 48}" x2="${b.x + 108}" y2="${b.y + 48}" stroke="#64748b" stroke-width="2" marker-end="url(#arrow)"/>`;
  }).join("");
  const cards = model.nodes.map((node) => {
    const warning = node.id === "flow.unresolved" && node.counts.live > 0;
    const stroke = warning ? "#fb7185" : "#38bdf8";
    const summary = wrapCardText(node.summary);
    return `<g id="flow-${esc(node.id.replace(/[^a-z0-9_-]/gi, "-"))}" data-flow-id="${esc(node.id)}"><desc>${esc(node.summary)}</desc><rect x="${node.x}" y="${node.y}" width="216" height="96" rx="12" fill="#172033" stroke="${stroke}" stroke-width="2"/><text x="${node.x + 12}" y="${node.y + 16}" fill="#7dd3fc" font-family="Inter,Arial,sans-serif" font-size="9">${esc(node.id)}</text><text x="${node.x + 12}" y="${node.y + 34}" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="13" font-weight="700">${esc(node.title)}</text>${summary.map((line, index) => `<text x="${node.x + 12}" y="${node.y + 50 + index * 12}" fill="#cbd5e1" font-family="Inter,Arial,sans-serif" font-size="8">${esc(line)}</text>`).join("")}<text x="${node.x + 12}" y="${node.y + 86}" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="9">live ${node.counts.live}/${node.counts.all} · dynamic ${node.counts.dynamic} · review ${node.counts.manual}</text></g>`;
  }).join("");
  return `<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><rect width="${width}" height="${height}" fill="#0b1020"/><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#64748b"/></marker></defs><text x="40" y="36" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="25" font-weight="700">PDV 2.0 Current In-Game UX Flow</text><text x="520" y="35" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="12">Penpot maps flow and adjacency · Excel/CSV owns prose · stable IDs join them · census ${esc(model.sourceFingerprint)}</text>${sections}${edges}${cards}</svg>\n`;
}

function wrapCardText(value) {
  const words = String(value ?? "").split(/\s+/).filter(Boolean);
  const lines = [""];
  for (const word of words) {
    const current = lines[lines.length - 1];
    if (`${current} ${word}`.trim().length <= 42) lines[lines.length - 1] = `${current} ${word}`.trim();
    else if (lines.length < 2) lines.push(word);
    else { lines[1] = `${lines[1].replace(/…$/, "")}…`; break; }
  }
  return lines;
}

export function renderProseExchangeCsv(census, model) {
  const assignments = model.byCopyId ?? new Map(model.assignments.map((row) => [row.copyId, row]));
  const keys = ["exchange_schema", "copy_id", "flow_ids", "journey", "event", "surface", "runtime_location", "current_runtime_text", "gameplay_contract", "character_budget", "risk", "dynamic", "row_fingerprint", "owner_status", "owner_draft", "owner_note"];
  const lines = census.rows.map((row) => {
    const fields = protectedExchangeFields(row, assignments.get(row.copyId)?.flowIds ?? []);
    return keys.map((key) => csvCell({ ...fields, owner_status: "", owner_draft: "", owner_note: "" }[key])).join(",");
  });
  return `${keys.map(csvCell).join(",")}\n${lines.join("\n")}\n`;
}

export function importProseExchange(csvText, census, model) {
  const rows = parseCsv(csvText);
  if (!rows.length) throw new Error("exchange CSV contains no rows");
  const header = rows[0];
  const required = ["exchange_schema", "copy_id", "flow_ids", "runtime_location", "current_runtime_text", "row_fingerprint", "owner_status", "owner_draft", "owner_note"];
  for (const key of required) if (!header.includes(key)) throw new Error(`exchange CSV missing column ${key}`);
  const index = Object.fromEntries(header.map((key, i) => [key, i]));
  const current = new Map(census.rows.map((row) => [row.copyId, row]));
  const assignments = model.byCopyId ?? new Map(model.assignments.map((row) => [row.copyId, row]));
  const seen = new Set();
  const changes = [];
  const warnings = [];
  for (const values of rows.slice(1)) {
    if (values.length === 1 && !values[0]) continue;
    const get = (key) => values[index[key]] ?? "";
    const copyId = get("copy_id");
    if (seen.has(copyId)) throw new Error(`duplicate copy_id ${copyId}`);
    seen.add(copyId);
    const source = current.get(copyId);
    if (!source) throw new Error(`unknown copy_id ${copyId}`);
    const expected = protectedExchangeFields(source, assignments.get(copyId)?.flowIds ?? []);
    if (get("exchange_schema") !== EXCHANGE_SCHEMA) throw new Error(`${copyId}: unsupported exchange schema`);
    for (const key of Object.keys(expected).filter((key) => key !== "row_fingerprint")) {
      if (get(key) !== String(expected[key])) throw new Error(`${copyId}: protected column ${key} changed or census is stale`);
    }
    if (get("row_fingerprint") !== expected.row_fingerprint) throw new Error(`${copyId}: protected fields changed or census is stale`);
    const status = get("owner_status").trim().toLowerCase();
    if (!["", "keep", "replace", "review", "skip"].includes(status)) throw new Error(`${copyId}: invalid owner_status ${status}`);
    const draft = get("owner_draft");
    if (status === "replace" && !draft) throw new Error(`${copyId}: replace requires owner_draft`);
    if (/[^\x00-\x7F]/.test(draft)) throw new Error(`${copyId}: owner_draft contains non-ASCII text; resolve the encoding choice before wire-in`);
    if (source.characterBudget && draft.length > source.characterBudget) warnings.push(`${copyId}: draft exceeds ${source.characterBudget} characters`);
    if (!status) continue;
    changes.push({
      copyId,
      flowIds: assignments.get(copyId)?.flowIds ?? [],
      status,
      currentText: source.runtimeText,
      ownerDraft: draft,
      ownerNote: get("owner_note"),
      route: wireRoute(source),
      runtimeLocation: source.runtimeLocation,
    });
  }
  return {
    schema: "pdv.copy-import-plan.v1",
    mode: "review-only-no-write",
    sourceCensusFingerprint: model.sourceFingerprint,
    summary: { exchangeRows: rows.length - 1, reviewedRows: changes.length, replacements: changes.filter((row) => row.status === "replace").length, warnings: warnings.length },
    warnings,
    changes,
  };
}

function protectedExchangeFields(row, flowIds) {
  const fields = {
    exchange_schema: EXCHANGE_SCHEMA,
    copy_id: row.copyId,
    flow_ids: flowIds.join(";"),
    journey: row.journey,
    event: row.event,
    surface: row.surface,
    runtime_location: row.runtimeLocation,
    current_runtime_text: row.runtimeText,
    gameplay_contract: row.gameplayContract,
    character_budget: row.characterBudget ?? "",
    risk: row.risk,
    dynamic: row.dynamic,
  };
  return { ...fields, row_fingerprint: stableHash(fields, 32) };
}

function wireRoute(row) {
  if (!row.runtimeLocation) return "reference-only-no-wire";
  if (/Devotion\.esp|houseCARL/i.test(`${row.runtimeAuthority} ${row.runtimeLocation}`)) return "housecarl-required";
  if (/\.psc(?::|#|$)/i.test(row.runtimeLocation)) return "papyrus-source-edit";
  if (/PrismaUI|\.html(?::|$)|\.js(?::|$)/i.test(row.runtimeLocation)) return "prisma-source-edit";
  return "manual-source-classification";
}

export function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') { cell += '"'; i += 1; }
      else if (ch === '"') quoted = false;
      else cell += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ",") { row.push(cell); cell = ""; }
    else if (ch === "\n") { row.push(cell); rows.push(row); row = []; cell = ""; }
    else if (ch !== "\r") cell += ch;
  }
  if (quoted) throw new Error("exchange CSV has an unterminated quoted field");
  if (cell || row.length) { row.push(cell); rows.push(row); }
  return rows;
}

function csvCell(value) {
  const text = value == null ? "" : String(value).replace(/\r\n/g, "\n");
  return `"${text.replace(/"/g, '""')}"`;
}

function validateFlowManifest(manifest) {
  if (manifest?.schema !== "pdv.copy-flow-map.v1") throw new Error("invalid copy-flow manifest schema");
  const ids = new Set();
  for (const node of manifest.nodes ?? []) {
    if (ids.has(node.id)) throw new Error(`duplicate flow node ${node.id}`);
    ids.add(node.id);
  }
  for (const [from, to] of manifest.edges ?? []) if (!ids.has(from) || !ids.has(to)) throw new Error(`flow edge references missing node: ${from} -> ${to}`);
}

export function readFlowManifest(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}
