#!/usr/bin/env node
/*
 * PDV dislike-consequence strict audit.
 *
 * Verifies the V2 shared domain-keyed disfavor sting implementation:
 *   - exactly seven shared domains and fourteen spell records plus fourteen magic effects
 *   - every deity/prince with a negative likes/dislikes row maps to a domain
 *   - abs(delta) <= 0.5 remains no-sting, >0.5 creates an eligible sting band
 *   - manager/router source uses the likes/dislikes event-context entrypoint
 *   - live ESP readback of all 14 SPEL + 14 MGEF records, read straight out of the
 *     deployed Devotion.esp via the standalone mutagen-bridge (name/source label,
 *     description, actor value, magnitude, zero engine duration, the MGEF
 *     NoDuration flag, and the SPEL -> MGEF link)
 *
 * The readback is fail-closed: if the bridge or the ESP cannot be read we FAIL
 * rather than silently pass a build we never inspected.
 *
 * Flags: --strict-dislike-consequence, --self-test, --json
 * Env:   PDV_ANVIL_ROOT, PDV_ESP, PDV_MUTAGEN_BRIDGE (path overrides)
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
// Deployed-ESP readback. The retired pdv-dislike-consequence-author helper is gone;
// records are read directly from Devotion.esp through the standalone mutagen-bridge,
// which does not depend on the retired Anvil HTTP MCP server.
const ANVIL_ROOT = toPosix(process.env.PDV_ANVIL_ROOT ?? "D:/Wabbajack/modlists/Anvil");
const PDV_ESP = toPosix(process.env.PDV_ESP ?? path.join(ANVIL_ROOT, "mods", "Devotion", "Devotion.esp"));
const MUTAGEN_BRIDGE = toPosix(
  process.env.PDV_MUTAGEN_BRIDGE
    ?? path.join(ANVIL_ROOT, "plugins", "Anvilmo2_mcp", "tools", "mutagen-bridge", "mutagen-bridge.exe"),
);
const MUTAGEN_BRIDGE_MAX_BUFFER = 128 * 1024 * 1024;
const SECONDS_PER_HOUR = 3600;

// PDV specs carry the Papyrus/CK actor-value vocabulary; Mutagen (and so the ESP
// readback) uses its own enum names. Same alias table as pdv_phase2_reward_readback_audit.
const ACTOR_VALUE_ALIASES = new Map([
  ["Speechcraft", "Speech"],
  ["BlockSkill", "Block"],
  ["Marksman", "Archery"],
  ["ResistPoison", "PoisonResist"],
]);

function normalizeActorValue(actorValue) {
  return ACTOR_VALUE_ALIASES.get(actorValue) ?? actorValue;
}

function toPosix(p) {
  return String(p).replace(/\\/g, "/");
}

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
      // The effect is Detrimental, so the stored record magnitude is positive.
      // The negative gameplay delta is supplied by the detrimental effect type.
      if (!(entry.magnitude > 0)) fail("positive record magnitude", `${entry.spellEditorId} magnitude is ${entry.magnitude}.`, SPEC);
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

function bridge(request, timeoutMs = 120_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: MUTAGEN_BRIDGE_MAX_BUFFER,
    windowsHide: true,
  });
  if (result.error) throw result.error;
  const stdout = (result.stdout || "").trim();
  if (!stdout) throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  try {
    return JSON.parse(stdout);
  } catch {
    throw new Error(`mutagen-bridge returned invalid JSON: ${stdout.slice(0, 400)}`);
  }
}

// Compare a live ESP field against the spec. Missing spec value => not asserted.
function expectField(check, editorId, field, actual, expected) {
  if (expected === undefined || expected === null) return true;
  if (String(actual) === String(expected)) return true;
  fail(check, `${editorId}.${field}: ESP has "${actual}", spec expects "${expected}".`, PDV_ESP);
  return false;
}

function validateLiveReadback(spec) {
  const check = "live ESP readback";

  if (!fs.existsSync(MUTAGEN_BRIDGE)) {
    fail(check, `mutagen-bridge.exe not found at ${MUTAGEN_BRIDGE}. Cannot read the deployed ESP.`, MUTAGEN_BRIDGE);
    return;
  }
  if (!fs.existsSync(PDV_ESP)) {
    fail(check, `Devotion.esp not found at ${PDV_ESP}.`, PDV_ESP);
    return;
  }

  let records;
  try {
    const scan = bridge({ command: "scan", plugins: [PDV_ESP] });
    records = scan.plugins?.[0]?.records ?? [];
  } catch (err) {
    fail(check, `ESP scan failed: ${err.message}`, PDV_ESP);
    return;
  }
  if (!records.length) {
    fail(check, "ESP scan returned no records.", PDV_ESP);
    return;
  }

  const formidByEdid = new Map();
  for (const r of records) if (r.edid) formidByEdid.set(r.edid, r.formid);

  // Collect every declared record, and fail loudly on any that the ESP does not carry.
  const wanted = [];
  for (const domain of spec.domains ?? []) {
    for (const band of ["light", "sharp"]) {
      const b = domain[band];
      if (!b) continue;
      wanted.push({ domain, band, spec: b, kind: "SPEL", editorId: b.spellEditorId });
      wanted.push({ domain, band, spec: b, kind: "MGEF", editorId: b.magicEffectEditorId });
    }
  }

  const missing = wanted.filter((w) => w.editorId && !formidByEdid.has(w.editorId));
  if (missing.length) {
    fail(check, `Missing from deployed ESP: ${missing.map((m) => m.editorId).join(", ")}.`, PDV_ESP);
    return;
  }

  let detailByEdid;
  try {
    const detail = bridge({
      command: "read_records",
      max_depth: 6,
      records: wanted.map((w) => ({ plugin_path: PDV_ESP, formid: formidByEdid.get(w.editorId) })),
    });
    detailByEdid = new Map();
    for (const r of detail.records ?? []) {
      if (r.editor_id && r.success && r.fields) detailByEdid.set(r.editor_id, r.fields);
    }
  } catch (err) {
    fail(check, `ESP record read failed: ${err.message}`, PDV_ESP);
    return;
  }

  let ok = 0;
  for (const w of wanted) {
    const f = detailByEdid.get(w.editorId);
    if (!f) {
      fail(check, `${w.editorId}: record read returned no fields.`, PDV_ESP);
      continue;
    }

    let good = true;
    if (w.kind === "MGEF") {
      // The MGEF Name is the named debuff the player sees in Active Effects.
      good = expectField(check, w.editorId, "Name", f.Name, w.spec.displayName) && good;
      good = expectField(check, w.editorId, "Description", f.Description, w.spec.description) && good;
      good = expectField(
        check,
        w.editorId,
        "Archetype.ActorValue",
        normalizeActorValue(f.Archetype?.ActorValue),
        normalizeActorValue(w.domain.actorValue),
      ) && good;
      if (!String(f.Flags ?? "").includes("Detrimental")) {
        fail(check, `${w.editorId}.Flags: missing Detrimental (got "${f.Flags}").`, PDV_ESP);
        good = false;
      }
      if (!String(f.Flags ?? "").includes("NoDuration")) {
        fail(check, `${w.editorId}.Flags: missing NoDuration (got "${f.Flags}").`, PDV_ESP);
        good = false;
      }
    } else {
      // The SPEL Name is the Active-Effects SOURCE label ("Favor Slips").
      good = expectField(check, w.editorId, "Name", f.Name, w.spec.sourceDisplayName) && good;
      good = expectField(check, w.editorId, "Description", f.Description, w.spec.description) && good;

      const effect = Array.isArray(f.Effects) ? f.Effects[0] : null;
      if (!effect) {
        fail(check, `${w.editorId}: no magic effect on the spell.`, PDV_ESP);
        good = false;
      } else {
        // The spell must point at its own domain/band magic effect.
        const expectedMgef = formidByEdid.get(w.spec.magicEffectEditorId);
        good = expectField(check, w.editorId, "Effects[0].BaseEffect", effect.BaseEffect, expectedMgef) && good;
        good = expectField(check, w.editorId, "Effects[0].Magnitude", effect.Data?.Magnitude, w.spec.magnitude) && good;
        // The manager owns Light/Sharp expiry through StorageUtil and removes the
        // Ability at that time. Constant Abilities must keep their engine effect
        // duration at zero or they can surface without modifying the actor value.
        good = expectField(check, w.editorId, "Effects[0].Duration", effect.Data?.Duration, 0) && good;
      }
    }
    if (good) ok++;
  }

  if (ok === wanted.length) {
    pass(
      check,
      `All ${wanted.length} disfavor records readback clean from the deployed ESP `
        + `(${wanted.length / 2} spells + ${wanted.length / 2} magic effects; name/source label, `
        + `description, actor value, magnitude, zero engine duration, NoDuration, and spell->effect link).`,
      PDV_ESP,
    );
  }
}

function runAudit() {
  const spec = readJson(SPEC);
  validateSpec(spec);
  validateCsvThresholds(spec);
  validateSourceGates(spec);
  validateLiveReadback(spec);
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
