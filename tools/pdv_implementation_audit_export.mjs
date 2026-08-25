#!/usr/bin/env node
/**
 * Validate the Race Architecture Atlas implementation audit and emit ignored,
 * workbook-ready JSON/CSV projections. This tool never reads or writes an ESP
 * and never changes owner prose. Plugin evidence must already be recorded in
 * the atlas from direct houseCARL readback.
 *
 * Usage:
 *   node tools/pdv_implementation_audit_export.mjs --check
 *   node tools/pdv_implementation_audit_export.mjs --write
 */
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseCsv } from "./lib/pdv_copy_flow.mjs";
import { acceptedDeityNames } from "./lib/pdv_matrix_vocab.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ATLAS_PATH = path.join(ROOT, "references", "authoring", "PDV_RaceArchitectureAtlas.json");
const CENSUS_PATH = path.join(ROOT, "generated", "pdv-copy-census", "PDV_CopyCensus.json");
const WORKBOOK_DIR = path.join(ROOT, "references", "authoring", "prose-workbook");
const ROUNDTRIP_PATH = path.join(WORKBOOK_DIR, "canonical-roundtrip-source.csv");
const DISPOSITION_PATH = path.join(WORKBOOK_DIR, "reference-disposition-audit.json");
const OUT_DIR = path.join(ROOT, "generated", "pdv-race-implementation-audit");
const OUT_JSON = path.join(OUT_DIR, "PDV_ImplementationAudit.json");
const OUT_QUEUE_CSV = path.join(OUT_DIR, "PDV_ImplementationAudit.csv");
const OUT_COPY_CSV = path.join(OUT_DIR, "PDV_ImplementationAuditCopyLinks.csv");

const write = process.argv.includes("--write");
if (!write && !process.argv.includes("--check")) {
  console.error("usage: pdv_implementation_audit_export.mjs --check|--write");
  process.exit(1);
}

const [atlas, census, sourceText, disposition] = await Promise.all([
  fs.readFile(ATLAS_PATH, "utf8").then(JSON.parse),
  fs.readFile(CENSUS_PATH, "utf8").then(JSON.parse),
  fs.readFile(ROUNDTRIP_PATH, "utf8"),
  fs.readFile(DISPOSITION_PATH, "utf8").then(JSON.parse),
]);

if (atlas.implementationAudit?.schema !== "pdv.race-implementation-audit.v1") throw new Error("atlas implementation audit schema missing");
const nodeById = new Map();
for (const race of atlas.races) for (const lane of race.lanes || []) for (const item of [...(lane.nodes || []), ...(lane.stubs || [])]) nodeById.set(item.nodeId, item);
for (const item of atlas.daedric?.nodes || []) nodeById.set(item.nodeId, item);

const sourceRows = parseCsv(sourceText);
const headers = sourceRows[0];
const source = sourceRows.slice(1).filter((row) => row.length > 1 || row[0]);
const index = Object.fromEntries(headers.map((name, i) => [name, i]));
const get = (row, key) => row[index[key]] ?? "";
if (source.length !== 5166) throw new Error(`roundtrip row drift: expected 5166, found ${source.length}`);
const censusById = new Map(census.rows.map((row) => [row.copyId, row]));
const sourceById = new Map(source.map((row) => [get(row, "copy_id"), row]));
if (sourceById.size !== 5166 || censusById.size !== 5166) throw new Error("copy ID uniqueness/count drift");

const { names: acceptedNames, issues } = acceptedDeityNames(ROOT);
if (issues.length) throw new Error(issues.join("; "));
const aliases = new Map([["HermaeusMora", "Hermaeus Mora"], ["Mora", "Hermaeus Mora"], ["MehrunesDagon", "Mehrunes Dagon"], ["Dagon", "Mehrunes Dagon"], ["MolagBal", "Molag Bal"], ["Molag", "Molag Bal"], ["ClavicusVile", "Clavicus Vile"], ["Vile", "Clavicus Vile"], ["Sheo", "Sheogorath"], ["AuriEl", "Auri-El"], ["BaanDar", "Baan Dar"], ["TheHist", "The Hist"], ["Hist", "The Hist"], ["Tuwhacca", "Tu'whacca"], ["Yffre", "Y'ffre"], ["Zen", "Z'en"]]);
for (const name of acceptedNames) aliases.set(name.replace(/[^A-Za-z0-9]/g, ""), name);
const aliasEntries = [...aliases.entries()].sort((a, b) => b[0].length - a[0].length);
const displayNames = [...new Set(acceptedNames)].sort((a, b) => b.length - a.length);
const esc = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
function inferDeity(row) {
  const copyId = get(row, "copy_id");
  const identifierText = `${get(row, "runtime_location")} ${copyId}`;
  const idMatches = aliasEntries.filter(([alias]) => new RegExp(`(?:^|[^A-Za-z0-9])${esc(alias)}(?:[^A-Za-z0-9]|$)`, "i").test(identifierText)).map(([, label]) => label);
  if (idMatches.length) return [...new Set(idMatches)].join(" / ");
  const prose = `${get(row, "current_runtime_text")} ${get(row, "gameplay_contract")}`;
  const proseMatches = displayNames.filter((name) => new RegExp(`(?:^|[^A-Za-z])${esc(name)}(?:[^A-Za-z]|$)`, "i").test(prose));
  if (proseMatches.length) return [...new Set(proseMatches)].join(" / ");
  return censusById.get(copyId)?.dynamic ? "Dynamic deity / patron" : "Shared / system";
}

const live = source.filter((row) => get(row, "current_runtime_text") && get(row, "surface") !== "message-record-name");
const groups = {
  "Journey & Reactions": live.filter((row) => !["blessing-name", "blessing-description", "prisma-label", "book-title"].includes(get(row, "surface"))),
  "Rewards & Effects": live.filter((row) => ["blessing-name", "blessing-description"].includes(get(row, "surface"))),
  "UI Labels": live.filter((row) => ["prisma-label", "book-title"].includes(get(row, "surface"))),
};
const writingLocation = new Map();
for (const [sheet, rows] of Object.entries(groups)) {
  rows.sort((a, b) => [get(a, "journey"), inferDeity(a), get(a, "event"), get(a, "surface"), get(a, "copy_id")].join("\0").localeCompare([get(b, "journey"), inferDeity(b), get(b, "event"), get(b, "surface"), get(b, "copy_id")].join("\0")));
  rows.forEach((row, i) => writingLocation.set(get(row, "copy_id"), `${sheet}!${i + 5}`));
}
if ([...writingLocation].length !== 4173) throw new Error(`visible writing location drift: ${writingLocation.size}`);

const dispositionLocation = new Map([...disposition.rows]
  .sort((a, b) => [a.race, a.deity, a.event, a.surface, a.copyId].join("\0").localeCompare([b.race, b.deity, b.event, b.surface, b.copyId].join("\0")))
  .map((row, i) => [row.copyId, `Disposition Audit!${i + 5}`]));

const copyLinks = [];
const queueIds = new Set();
for (const row of atlas.implementationAudit.queue) {
  if (queueIds.has(row.auditId)) throw new Error(`duplicate auditId ${row.auditId}`);
  queueIds.add(row.auditId);
  for (const nodeId of row.nodeIds || []) if (!nodeById.has(nodeId)) throw new Error(`${row.auditId}: unknown node ${nodeId}`);
  for (const copyId of row.copyIds || []) {
    const censusRow = censusById.get(copyId);
    if (!censusRow || !sourceById.has(copyId)) throw new Error(`${row.auditId}: unknown copy ID ${copyId}`);
    const editLocation = writingLocation.get(copyId) || dispositionLocation.get(copyId) || "Roundtrip Data (technical only)";
    copyLinks.push({ auditId: row.auditId, race: row.race, moment: row.moment, copyId, visibility: censusRow.visibility, surface: censusRow.surface, currentWording: censusRow.runtimeText || "", referenceWording: censusRow.referenceText || "", editLocation });
  }
}

const projection = { schema: "pdv.implementation-audit-projection.v1", sourceCommit: atlas.implementationAudit.sourceCommit, pluginFingerprint: atlas.implementationAudit.pluginFingerprint, queue: atlas.implementationAudit.queue, copyLinks };
const quote = (value) => `"${String(value ?? "").replace(/"/g, '""')}"`;
const queueHeaders = ["audit_id", "kind", "race", "moment", "player_impact", "active_question", "gap_class", "status", "papyrus_result", "esp_result", "implementation_route", "runtime_proof", "linked_copy_count", "node_ids"];
const queueCsv = [queueHeaders, ...projection.queue.map((q) => [q.auditId, q.kind, q.race, q.moment, q.playerImpact, q.question, q.gapClass, q.status, q.papyrusResult, q.espResult, q.implementationRoute, q.runtimeProof, q.copyIds.length, q.nodeIds.join(" | ")])].map((row) => row.map(quote).join(",")).join("\r\n") + "\r\n";
const copyHeaders = ["audit_id", "race", "moment", "copy_id", "visibility", "surface", "current_wording", "reference_wording", "edit_location"];
const copyCsv = [copyHeaders, ...copyLinks.map((r) => [r.auditId, r.race, r.moment, r.copyId, r.visibility, r.surface, r.currentWording, r.referenceWording, r.editLocation])].map((row) => row.map(quote).join(",")).join("\r\n") + "\r\n";

if (write) {
  await fs.mkdir(OUT_DIR, { recursive: true });
  await Promise.all([fs.writeFile(OUT_JSON, JSON.stringify(projection, null, 2) + "\n"), fs.writeFile(OUT_QUEUE_CSV, queueCsv), fs.writeFile(OUT_COPY_CSV, copyCsv)]);
}
console.log(JSON.stringify({ ok: true, mode: write ? "write" : "check", queue: projection.queue.length, linkedCopies: copyLinks.length, actionableUxQuestions: projection.queue.filter((q) => q.kind === "ux-decision").length, out: write ? path.relative(ROOT, OUT_DIR).replaceAll(path.sep, "/") : null }));
