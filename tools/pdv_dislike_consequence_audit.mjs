#!/usr/bin/env node
/*
 * PDV dislike-consequence strict audit.
 *
 * Verifies the V2 shared domain-keyed disfavor sting implementation:
 *   - exactly seven shared domains and fourteen spell records plus fourteen magic effects
 *   - every deity/prince with a negative likes/dislikes row maps to a domain
 *   - abs(delta) <= 0.5 remains no-sting, >0.5 creates an eligible sting band
 *   - manager/router source uses the likes/dislikes event-context entrypoint
 *   - live ESP record/VMAD readback passes through pdv-dislike-consequence-author
 *
 * Flags: --strict-dislike-consequence, --self-test, --json
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const ROOT = process.cwd();
const AUTH = path.join(ROOT, "references", "authoring");
const SPEC = path.join(AUTH, "PDV_DislikeConsequenceRecords.spec.json");
const DEITY_CSV = path.join(AUTH, "PDV_DeityLikesDislikes.csv");
const MANAGER = path.join(ROOT, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const ROUTER = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_ActionRouter.psc");
const EVENT_BUS = path.join(ROOT, "live-source", "Scripts", "Source", "PDV_EventBus.psc");
const AUTHOR_PROJECT = path.join(ROOT, "tools", "pdv-dislike-consequence-author", "PdvDislikeConsequenceAuthor.csproj");

const flags = new Set(process.argv.slice(2));
const findings = [];

function add(status, check, detail, location = "") {
  findings.push({ status, check, detail, location });
}
const pass = (check, detail, location) => add("PASS", check, detail, location);
const fail = (check, detail, location) => add("FAIL", check, detail, location);

function counts() {
  return findings.reduce((m, f) => ((m[f.status] = (m[f.status] ?? 0) + 1), m), {});
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function splitCsvLine(line) {
  const out = [];
  let cur = "";
  let quoted = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"' && quoted && line[i + 1] === '"') {
      cur += '"';
      i++;
    } else if (ch === '"') {
      quoted = !quoted;
    } else if (ch === "," && !quoted) {
      out.push(cur);
      cur = "";
    } else {
      cur += ch;
    }
  }
  out.push(cur);
  return out;
}

function loadCsv(file) {
  const lines = read(file).split(/\r?\n/).filter((line) => line.trim());
  const header = splitCsvLine(lines[0]);
  return lines.slice(1).map((line, lineIndex) => {
    const cells = splitCsvLine(line);
    const row = { line: lineIndex + 2 };
    header.forEach((name, idx) => { row[name] = cells[idx] ?? ""; });
    return row;
  });
}

function normalizeActor(actor) {
  return String(actor ?? "").replace(/^Daedric:/i, "").replace(/[^A-Za-z0-9]+/g, "").toLowerCase();
}

function actorDomain(spec, actor) {
  const needle = normalizeActor(actor);
  for (const [name, domain] of Object.entries(spec.deityDomains ?? {})) {
    if (normalizeActor(name) === needle) return domain;
  }
  return null;
}

function validateSpec(spec) {
  if (spec.schema === "pdv.dislike-consequence-records.v1") pass("spec schema", spec.schema, SPEC);
  else fail("spec schema", `Unexpected schema ${spec.schema}`, SPEC);

  const domains = spec.domains ?? [];
  if (domains.length === 7) pass("domain count", "Seven shared disfavor domains.", SPEC);
  else fail("domain count", `Expected 7 domains, found ${domains.length}.`, SPEC);

  const ids = new Set();
  const domainNames = new Set();
  for (const domain of domains) {
    if (domainNames.has(domain.domain)) fail("unique domain", `Duplicate domain ${domain.domain}.`, SPEC);
    domainNames.add(domain.domain);
    for (const band of ["light", "sharp"]) {
      const entry = domain[band];
      if (!entry) {
        fail("band record", `${domain.domain}.${band} missing.`, SPEC);
        continue;
      }
      for (const key of ["spellEditorId", "magicEffectEditorId", "propertyName", "displayName", "description"]) {
        if (!entry[key]) fail("band field", `${domain.domain}.${band}.${key} missing.`, SPEC);
      }
      for (const id of [entry.spellEditorId, entry.magicEffectEditorId]) {
        if (ids.has(id)) fail("unique editor id", `Duplicate editor id ${id}.`, SPEC);
        ids.add(id);
      }
      if (!(entry.magnitude < 0)) fail("negative magnitude", `${entry.spellEditorId} magnitude is ${entry.magnitude}.`, SPEC);
      if (![2, 4].includes(Number(entry.durationHours))) fail("duration", `${entry.spellEditorId} durationHours is ${entry.durationHours}.`, SPEC);
    }
  }
  if (ids.size === 28) pass("record id count", "Fourteen spell ids plus fourteen magic-effect ids declared.", SPEC);
  else fail("record id count", `Expected 28 spell/effect ids, found ${ids.size}.`, SPEC);

  const domainValues = new Set(Object.values(spec.deityDomains ?? {}));
  for (const domain of domainValues) {
    if (!domainNames.has(domain)) fail("deity domain target", `deityDomains references unknown ${domain}.`, SPEC);
  }
  if (Object.keys(spec.deityDomains ?? {}).length === 32) pass("deity domain map", "All 32 likes/dislikes actors are mapped.", SPEC);
  else fail("deity domain map", `Expected 32 mapped actors, found ${Object.keys(spec.deityDomains ?? {}).length}.`, SPEC);
}

function validateCsvThresholds(spec) {
  const rows = loadCsv(DEITY_CSV);
  const negative = rows.filter((row) => row.sentiment === "-");
  let eligible = 0;
  let cutoff = 0;
  for (const row of negative) {
    const absDelta = Math.abs(Number(row.baseDelta));
    const domain = actorDomain(spec, row.actor);
    if (!domain) fail("negative actor domain", `${row.actor} line ${row.line} has no disfavor domain.`, DEITY_CSV);
    if (absDelta <= 0.5) {
      cutoff++;
    } else {
      eligible++;
      if (!domain) continue;
      const expectedBand = absDelta > 1.0 ? "sharp" : "light";
      const domainSpec = (spec.domains ?? []).find((d) => d.domain === domain);
      if (!domainSpec?.[expectedBand]?.spellEditorId) fail("eligible band", `${row.actor} ${row.eventId} maps to ${domain}.${expectedBand} but no spell exists.`, SPEC);
    }
  }
  pass("negative rows parsed", `${negative.length} negative deity likes/dislikes rows scanned; Daedric prince dislike lanes are out of scope.`, DEITY_CSV);
  pass("threshold split", `${eligible} rows eligible for stings; ${cutoff} rows at <=0.5 remain piety-only.`, DEITY_CSV);
}

function requireSourceContains(file, check, patterns) {
  const text = read(file);
  for (const pattern of patterns) {
    const ok = pattern instanceof RegExp ? pattern.test(text) : text.includes(pattern);
    if (ok) pass(check, `Found ${pattern}.`, file);
    else fail(check, `Missing ${pattern}.`, file);
  }
}

function validateSourceGates(spec) {
  requireSourceContains(MANAGER, "manager gate", [
    "Function AwardPietyFromLikesDislikes(PDV_DeityBase deity, Float amount, Int eventType, String reason = \"\")",
    "Function ApplyDisfavorSting(PDV_DeityBase deity, Float appliedAmount, String sourceTag)",
    "Bool Function HasDisfavorStanding(PDV_DeityBase deity)",
    "Bool Function IsDisfavorRepeatSuppressed(PDV_DeityBase deity, Int domainValue, Int eventType)",
    "Int Function CountActiveDisfavorStings()",
    "Function UpdateDisfavorStingRuntime()",
    "_pendingLikesDislikesEventType",
    "DISFAVOR_MAX_ACTIVE_DOMAINS = 3",
  ]);
  requireSourceContains(ROUTER, "router dispatch", ["AwardPietyFromLikesDislikes(deity, delta, eventType"]);
  requireSourceContains(EVENT_BUS, "event bus dispatch", ["AwardPietyFromLikesDislikes(deity, delta, eventType"]);
  requireSourceContains(MANAGER, "shout dispatch", ["AwardPietyFromLikesDislikes(deity, delta * multiplier, eventType, reason)"]);

  const manager = read(MANAGER);
  for (const domain of spec.domains ?? []) {
    for (const band of ["light", "sharp"]) {
      const propertyName = domain[band]?.propertyName;
      if (!propertyName) continue;
      if (new RegExp(`Spell\\s+Property\\s+${propertyName}\\s+Auto`).test(manager)) pass("manager spell property", propertyName, MANAGER);
      else fail("manager spell property", `Missing Spell Property ${propertyName} Auto.`, MANAGER);
    }
  }
}

function validateLiveReadback() {
  const result = spawnSync("dotnet", ["run", "--project", AUTHOR_PROJECT, "--", "--check"], {
    cwd: ROOT,
    encoding: "utf8",
    timeout: 120_000,
    windowsHide: true,
  });
  if (result.status === 0) {
    pass("live ESP readback", "pdv-dislike-consequence-author --check PASS.", AUTHOR_PROJECT);
  } else {
    fail("live ESP readback", `${result.stderr || ""}\n${result.stdout || ""}`.trim(), AUTHOR_PROJECT);
  }
}

function runAudit() {
  const spec = readJson(SPEC);
  validateSpec(spec);
  validateCsvThresholds(spec);
  validateSourceGates(spec);
  validateLiveReadback();
}

function selfTest() {
  const asserts = [];
  const expect = (name, ok) => asserts.push({ name, ok });
  expect("csv quotes", splitCsvLine('a,"b,c","d""e"').join("|") === 'a|b,c|d"e');
  const fake = { deityDomains: { "Baan Dar": "MoonLuckShadow", "The Hist": "VoidSecrets", "auri-el": "OrderTradeLore" } };
  expect("actor normalize space", actorDomain(fake, "Baan Dar") === "MoonLuckShadow");
  expect("actor normalize article", actorDomain(fake, "The Hist") === "VoidSecrets");
  expect("actor normalize punctuation", actorDomain(fake, "Auri-El") === "OrderTradeLore");
  expect("actor normalize prince prefix", actorDomain(fake, "Daedric:BaanDar") === "MoonLuckShadow");
  for (const a of asserts) console.log(`${a.ok ? "[PASS]" : "[FAIL]"} ${a.name}`);
  const failed = asserts.filter((a) => !a.ok).length;
  console.log(failed ? `SELF-TEST FAIL (${failed})` : `SELF-TEST PASS (${asserts.length} assertions)`);
  process.exitCode = failed ? 1 : 0;
}

if (flags.has("--self-test")) {
  selfTest();
} else {
  if (!flags.has("--strict-dislike-consequence")) {
    fail("mode", "Run with --strict-dislike-consequence.", "tools/pdv_dislike_consequence_audit.mjs");
  } else {
    runAudit();
  }
  const summary = { status: findings.some((f) => f.status === "FAIL") ? "FAIL" : "PASS", counts: counts(), findings };
  if (flags.has("--json")) console.log(JSON.stringify(summary, null, 2));
  else {
    for (const f of findings) console.log(`[${f.status}] ${f.check}: ${f.detail}${f.location ? ` (${f.location})` : ""}`);
    console.log(`${summary.status}: ${JSON.stringify(summary.counts)}`);
  }
  process.exitCode = summary.status === "PASS" ? 0 : 1;
}
