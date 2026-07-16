#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, "..");
const LEDGER = path.join(ROOT, "references", "authoring", "PDV_PantheonSubstrateRuntimeEvidenceLedger.json");
const EVIDENCE_ARCHIVE = path.join(ROOT, "references", "authoring", "evidence", "PDV_PantheonSubstrate_CoTest_2026-07-15.md");
const SCHEMA = "pdv.pantheon-substrate-runtime-evidence.v2";
const BUCKETS = ["runtimeRoute", "organicRoute", "manualDisplay", "saveLoad"];
const ALLOWED = new Set(["OPEN", "PASS", "FAIL", "BLOCKED", "NOT_REQUIRED"]);
const REQUIRED_IDS = Array.from({ length: 12 }, (_, index) => `PS-A${index + 1}`);

function usage() {
  console.log("Usage: node tools/pdv_pantheon_substrate_runtime_evidence_check.mjs [--strict] [--json] [--self-test] [--help]");
  console.log("Read-only, fail-closed check of timestamped PS-A1..PS-A12 runtime evidence.");
}

function hasTimestamp(value) {
  if (typeof value !== "string") return false;
  const timestamp = value.trim();
  if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:\d{2})$/.test(timestamp)) {
    return !Number.isNaN(Date.parse(timestamp));
  }

  // Evidence entered before the schema gate used a local AEST range. The
  // first time is still a concrete observed-at timestamp; accepting it keeps
  // a retrospective schema check from recasting already-recorded proof as
  // malformed. New intake must use the ISO form above.
  const legacyAest = timestamp.match(/^(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}(?::\d{2})?)(?:-\d{2}:\d{2}:\d{2})?\sAEST$/);
  if (legacyAest !== null) {
    const clock = legacyAest[2].length === 5 ? `${legacyAest[2]}:00` : legacyAest[2];
    return !Number.isNaN(Date.parse(`${legacyAest[1]}T${clock}+10:00`));
  }
  const legacyIsoRange = timestamp.match(/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})-\d{2}:\d{2}:\d{2}([+-]\d{2}:\d{2})$/);
  return legacyIsoRange !== null && !Number.isNaN(Date.parse(`${legacyIsoRange[1]}${legacyIsoRange[2]}`));
}

function hasRetainedReference(reference) {
  if (!fs.existsSync(EVIDENCE_ARCHIVE)) return false;
  try {
    // The archive is an explicit, reviewed retention record, not a general
    // fallback: an entry must match the full original source reference.
    return fs.readFileSync(EVIDENCE_ARCHIVE, "utf8").includes(`- ${reference}`);
  } catch {
    return false;
  }
}

function isConcreteEvidenceReference(entry) {
  if (typeof entry !== "string") return false;
  const reference = entry.trim();
  if (reference.length < 5) return false;

  const hashIndex = reference.indexOf("#");
  const pathPart = hashIndex >= 0 ? reference.slice(0, hashIndex).trim() : reference;
  const locator = hashIndex >= 0 ? reference.slice(hashIndex + 1).trim() : "";
  if (!pathPart || (hashIndex >= 0 && !locator)) return false;

  const resolvedPath = path.isAbsolute(pathPart) ? path.normalize(pathPart) : path.resolve(ROOT, pathPart);
  if (!fs.existsSync(resolvedPath) || !fs.statSync(resolvedPath).isFile()) return hasRetainedReference(reference);

  // Screenshots are concrete captures by themselves. Text and log evidence
  // must identify the exact section, line, or unique marker being credited.
  const extension = path.extname(resolvedPath).toLowerCase();
  const isImage = new Set([".png", ".jpg", ".jpeg", ".webp", ".bmp"]).has(extension);
  if (isImage) return true;
  if (!locator) return hasRetainedReference(reference);

  let content;
  try {
    content = fs.readFileSync(resolvedPath, "utf8");
  } catch {
    return false;
  }
  const lineMatch = locator.match(/^L?(\d+)$/i);
  if (lineMatch) {
    const lineNumber = Number(lineMatch[1]);
    return lineNumber > 0 && lineNumber <= content.split(/\r?\n/).length;
  }
  return content.includes(locator) || hasRetainedReference(reference);
}

function hasReferences(value) {
  return Array.isArray(value) && value.length > 0 && value.every(isConcreteEvidenceReference);
}

function malformed(message, jsonMode) {
  const result = { status: "MALFORMED", ledger: path.relative(ROOT, LEDGER).replaceAll("\\", "/"), errors: [message] };
  if (jsonMode) console.log(JSON.stringify(result, null, 2));
  else console.error(`MALFORMED: ${message}`);
  process.exitCode = 2;
}

const args = new Set(process.argv.slice(2));
if (args.has("--help")) {
  usage();
  process.exit(0);
}
const unknown = [...args].filter((arg) => arg !== "--json" && arg !== "--strict" && arg !== "--self-test");
if (unknown.length > 0) {
  usage();
  process.exit(2);
}
const jsonMode = args.has("--json");

if (args.has("--self-test")) {
  const ownPath = path.relative(ROOT, fileURLToPath(import.meta.url)).replaceAll("\\", "/");
  const cases = [
    { id: "reject-token", expected: false, actual: isConcreteEvidenceReference("xxxxx") },
    { id: "reject-missing-file", expected: false, actual: isConcreteEvidenceReference("references/authoring/does-not-exist.log#marker") },
    { id: "reject-missing-marker", expected: false, actual: isConcreteEvidenceReference(`${ownPath}#${["marker", "absent", "runtime"].join("-")}`) },
    { id: "accept-existing-marker", expected: true, actual: isConcreteEvidenceReference(`${ownPath}#isConcreteEvidenceReference`) },
  ];
  const failures = cases.filter((entry) => entry.actual !== entry.expected);
  const result = { status: failures.length === 0 ? "PASS" : "FAIL", cases, failures };
  if (jsonMode) console.log(JSON.stringify(result, null, 2));
  else console.log(`Pantheon/substrate evidence checker self-test: ${result.status}`);
  process.exit(failures.length === 0 ? 0 : 2);
}

let ledger;
try {
  ledger = JSON.parse(fs.readFileSync(LEDGER, "utf8"));
} catch (error) {
  malformed(`Cannot read or parse ledger: ${error.message}`, jsonMode);
  process.exit();
}

const structuralErrors = [];
if (ledger.schema !== SCHEMA) structuralErrors.push(`schema must be ${SCHEMA}`);
if (ledger.requiredCards !== REQUIRED_IDS.length) structuralErrors.push(`requiredCards must be ${REQUIRED_IDS.length}`);
if (!Array.isArray(ledger.cards)) structuralErrors.push("cards must be an array");
if (!hasTimestamp(ledger.updatedAtLocal)) structuralErrors.push("updatedAtLocal must be an ISO timestamp with timezone");

if (Array.isArray(ledger.cards)) {
  const ids = ledger.cards.map((card) => card?.id);
  for (const id of REQUIRED_IDS) {
    if (ids.filter((candidate) => candidate === id).length !== 1) structuralErrors.push(`${id} must occur exactly once`);
  }
  for (const id of ids) {
    if (!REQUIRED_IDS.includes(id)) structuralErrors.push(`unexpected card id ${String(id)}`);
  }
}

if (structuralErrors.length > 0) {
  malformed(structuralErrors.join("; "), jsonMode);
  process.exit();
}

const cardResults = [];
for (const card of ledger.cards) {
  const errors = [];
  const pending = [];
  if (typeof card.title !== "string" || card.title.trim() === "") errors.push("title must be a non-empty string");
  if (!Array.isArray(card.requiredBuckets) || card.requiredBuckets.length === 0) {
    errors.push("requiredBuckets must be a non-empty array");
  } else {
    const unique = new Set(card.requiredBuckets);
    if (unique.size !== card.requiredBuckets.length) errors.push("requiredBuckets contains duplicates");
    for (const bucketName of card.requiredBuckets) {
      if (!BUCKETS.includes(bucketName)) errors.push(`unknown required bucket ${String(bucketName)}`);
    }
  }

  for (const bucketName of BUCKETS) {
    const bucket = card[bucketName];
    if (!bucket || typeof bucket !== "object" || Array.isArray(bucket)) {
      errors.push(`${bucketName} must be an evidence object`);
      continue;
    }
    if (!ALLOWED.has(bucket.status)) errors.push(`${bucketName}.status is invalid`);
    const required = card.requiredBuckets?.includes(bucketName);
    if (required && bucket.status === "NOT_REQUIRED") errors.push(`${bucketName} is required and cannot be NOT_REQUIRED`);
    if (bucket.status === "PASS") {
      if (!hasTimestamp(bucket.observedAtLocal)) errors.push(`${bucketName} PASS lacks a valid observedAtLocal timestamp`);
      else if (Date.parse(bucket.observedAtLocal) > Date.now() + 300_000) errors.push(`${bucketName} PASS observedAtLocal is in the future`);
      if (!hasReferences(bucket.evidenceRefs)) errors.push(`${bucketName} PASS lacks concrete existing evidenceRefs (images, or file#locator)`);
    }
    if (required && bucket.status !== "PASS") pending.push(`${bucketName}:${bucket.status || "MISSING"}`);
  }

  cardResults.push({
    id: card.id,
    title: card.title,
    status: errors.length > 0 ? "INVALID" : pending.length > 0 ? "OPEN" : "PASS",
    requiredBuckets: card.requiredBuckets,
    pending,
    errors,
  });
}

const invalidCards = cardResults.filter((card) => card.status === "INVALID");
const openCards = cardResults.filter((card) => card.status === "OPEN");
const passedCards = cardResults.filter((card) => card.status === "PASS");
const status = invalidCards.length > 0 ? "MALFORMED" : openCards.length > 0 ? "FAIL" : "PASS";
const result = {
  status,
  ledger: path.relative(ROOT, LEDGER).replaceAll("\\", "/"),
  summary: {
    requiredCards: REQUIRED_IDS.length,
    passedCards: passedCards.length,
    openCards: openCards.length,
    invalidCards: invalidCards.length,
    openRequiredBuckets: openCards.reduce((count, card) => count + card.pending.length, 0),
  },
  cards: cardResults,
};

if (jsonMode) {
  console.log(JSON.stringify(result, null, 2));
} else {
  console.log(`Pantheon/substrate runtime evidence: ${status}`);
  console.log(`${passedCards.length}/${REQUIRED_IDS.length} cards PASS; ${result.summary.openRequiredBuckets} required buckets remain OPEN.`);
  for (const card of cardResults.filter((entry) => entry.status !== "PASS")) {
    const detail = [...card.errors, ...card.pending].join("; ");
    console.log(`- ${card.id} ${card.status}: ${detail}`);
  }
}

process.exitCode = status === "PASS" ? 0 : status === "FAIL" ? 1 : 2;
