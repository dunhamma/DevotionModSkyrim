#!/usr/bin/env node
/*
 * pdv_vmad_audit.mjs - Read-only VMAD script/property audit for Devotion.esp.
 *
 * WHAT IT CHECKS
 *   A. Sibling outlier   - within a family of records sharing an architectural
 *                          parent script, a record MISSING a property the
 *                          majority of its family carries. This is the Syrabane
 *                          shape: PDV_Deity_Syrabane carried 4 properties where
 *                          every sibling carried 14, so Stance_Altmer fell back
 *                          to the script default FOREIGN and every likes/dislikes
 *                          row scored 0.0, silently.
 *   B. Declared-but-absent (object-typed only) - a declared property whose type
 *                          is a form/array type and which no VMAD entry supplies.
 *                          These dereference to None at runtime.
 *   C. Present-but-null  - a VMAD entry exists but its Object is (null link).
 *   D. Present-but-undeclared - a VMAD fill survives after its property moved
 *                          out of the attached script. Papyrus ignores it and
 *                          emits an initialization warning on a fresh instance.
 *   E. Duplicate-name    - one attachment carries the same property name more
 *                          than once, leaving ambiguous authoring state even
 *                          when both copies currently point to the same value.
 *
 * WHAT IT DELIBERATELY DOES NOT CHECK
 *   Scalar (Int/Float/Bool/String) absence under detector B. Papyrus applies the
 *   script's own default, and leaving tuning scalars (DELTA_*) out of a VMAD is
 *   the standard, intended authoring pattern. Scalar absence is a signal ONLY via
 *   detector A, where the record is an outlier against its own kind.
 *   AutoReadOnly properties, which cannot be set in a VMAD at all.
 *   Properties whose source declaration documents them as optional.
 *   Anything listed in PDV_VMAD_AuditWaivers.json.
 *
 * SOURCE OF TRUTH
 *   Property DECLARATIONS are read from the MO2 LIVE tree, not the repo's
 *   live-source/ mirror. The mirror lags: in-flight work lands live first (see
 *   AGENTS.md "SHIPPED-VS-REPO SOURCE DRIFT" and PDV_MOD_SETUP.md "Repo-source
 *   drift"). Auditing against the mirror invents phantom "no source for script X"
 *   gaps. Override with PDV_DEVOTION_SOURCE_DIR; a divergence against the repo
 *   mirror is reported, never silently absorbed.
 *
 * READ-ONLY. Calls only housecarl_load_order_status / _cross_plugin_query /
 * _batch_record_detail. Never writes to the ESP.
 *
 * USAGE
 *   node tools/pdv_vmad_audit.mjs            Human-readable report; exit 1 on findings.
 *   node tools/pdv_vmad_audit.mjs --json     Machine-readable document on stdout.
 *
 * The verdict is the EXIT CODE, never a grepped field. Exit 1 means at least one
 * un-waived detector A/B/C/D/E finding survived independent re-read.
 */
import fs from "node:fs";
import path from "node:path";
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";
import { devotionSource } from "./lib/pdv_paths.mjs";

// Refuse unrecognised flags. These tools read argv with includes()/indexOf(), so an
// unknown or mistyped flag would otherwise fall through to a default and the run would
// SUCCEED against something the caller never asked for. Matches the pdv_arr25_* convention.
const KNOWN_FLAGS = new Set(["--json"]);
for (const arg of process.argv.slice(2)) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    throw new Error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
  }
}


const ROOT = process.cwd();
const SOURCE_DIR = process.env.PDV_DEVOTION_SOURCE_DIR || devotionSource();
const MIRROR_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const WAIVERS_PATH = path.join(ROOT, "references", "authoring", "PDV_VMAD_AuditWaivers.json");
const PLUGIN = "Devotion.esp";
const MANAGER_FORMID = "00C325:Devotion.esp";
const BIG_THRESHOLD = 120; // above this, read properties by explicit index

const json = process.argv.includes("--json");
const log = (...args) => { if (!json) console.error(...args); };

// ---------------------------------------------------------------------
// Source parsing
// ---------------------------------------------------------------------

const NATIVE_SCALAR_TYPES = new Set(["int", "float", "bool", "string"]);

// An array property has no usable script default (it is None until set), so it
// is treated as object-typed even when its element type is a scalar.
function classifyType(type) {
  const isArray = /\[\s*\]$/.test(type);
  const base = type.replace(/\[\s*\]$/, "").toLowerCase();
  return { isArray, isObject: isArray || !NATIVE_SCALAR_TYPES.has(base) };
}

const OPTIONAL_HINT = /\boptional\b|safe to leave unfilled|leave (?:it )?unfilled|when unset|falls back|not required/i;

function parseScriptSources(dir) {
  const scripts = new Map();
  let files;
  try {
    files = fs.readdirSync(dir);
  } catch (error) {
    throw new Error(`Cannot read Papyrus source dir "${dir}": ${error.message}. Set PDV_DEVOTION_SOURCE_DIR.`);
  }
  const propRe = /^[ \t]*([A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*\])?)\s+Property\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:=\s*(?:"[^"]*"|\S+))?\s*(AutoReadOnly|Auto)\b(.*)$/i;
  for (const file of files) {
    if (!file.toLowerCase().endsWith(".psc")) continue;
    const text = fs.readFileSync(path.join(dir, file), "utf8");
    const scriptMatch = text.match(/^\s*Scriptname\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s+extends\s+([A-Za-z_][A-Za-z0-9_]*))?/im);
    if (!scriptMatch) continue;
    const name = scriptMatch[1];
    const lines = text.split(/\r?\n/);
    const declared = new Map();
    for (let i = 0; i < lines.length; i++) {
      const m = lines[i].match(propRe);
      if (!m) continue;
      const [, rawType, propName, autoKind, trailing] = m;
      // Doc text can be a trailing "; ..." on the declaration line, or a
      // following {...} block. Both are used in this codebase to mark a
      // property optional; both must be read or the audit reports designed
      // fallbacks as defects.
      let doc = trailing || "";
      let j = i + 1;
      while (j < lines.length && lines[j].trim() === "") j++;
      if (j < lines.length && lines[j].trim().startsWith("{")) {
        while (j < lines.length) {
          doc += ` ${lines[j]}`;
          if (lines[j].includes("}")) break;
          j++;
        }
      }
      const type = rawType.replace(/\s+/g, "");
      const { isArray, isObject } = classifyType(type);
      declared.set(propName, {
        type, isArray, isObject,
        autoReadOnly: autoKind.toLowerCase() === "autoreadonly",
        optional: OPTIONAL_HINT.test(doc),
        declaredIn: name,
      });
    }
    scripts.set(name, { file, extends: scriptMatch[2] || null, declared });
  }
  return scripts;
}

function ancestorChain(scripts, name) {
  const chain = [];
  const seen = new Set();
  let cur = name;
  while (cur && scripts.has(cur) && !seen.has(cur)) {
    seen.add(cur);
    chain.push(cur);
    cur = scripts.get(cur).extends;
  }
  return chain;
}

function resolveEffectiveProperties(scripts, name) {
  const chain = ancestorChain(scripts, name);
  const result = new Map();
  for (let i = chain.length - 1; i >= 0; i--) {
    for (const [k, v] of scripts.get(chain[i]).declared) result.set(k, v);
  }
  return result;
}

// Detector A families group by the IMMEDIATE parent script when that parent is
// itself a PDV script, else by the attached script name. Grouping by every
// ancestor (the naive approach) lumps PDV_Deity_* and PDV_DaedricPath_* into one
// PDV_DeityBase family and then reports all 16 Daedric paths as Stance_* outliers
// -- but the Daedric lane deliberately uses StateByRace/StigmaModByRace/
// ExitDifficultyByRace instead, and is not in PDV_FLST_AllDeities at all, so it
// never consults Stance_*. Immediate-parent grouping keeps the two kinds apart.
function familyKey(scripts, scriptName) {
  const parent = scripts.get(scriptName)?.extends;
  return parent && scripts.has(parent) ? parent : scriptName;
}

// ---------------------------------------------------------------------
// Waivers
// ---------------------------------------------------------------------

function loadWaivers() {
  if (!fs.existsSync(WAIVERS_PATH)) return [];
  const doc = JSON.parse(fs.readFileSync(WAIVERS_PATH, "utf8").replace(/^\uFEFF/, ""));
  return doc.waivers ?? [];
}

function waiverFor(waivers, finding) {
  return waivers.find((w) => {
    if (w.script !== finding.scriptName && w.script !== finding.declaredIn) return false;
    // A base-class waiver must not silently cover a subclass that uses the
    // property for real: PDV_DaedricPathBase overrides SyncPatronBoonsToTier and
    // grants Boon_* for real, while the Aedric shells deliberately never do.
    if (w.excludeScriptPrefixes?.some((p) => String(finding.scriptName).startsWith(p))) return false;
    if (!(w.properties ?? []).includes(finding.property)) return false;
    if (w.formids && !w.formids.includes(finding.formid)) return false;
    if (w.detectors && !w.detectors.includes(finding.detector)) return false;
    return true;
  });
}

// ---------------------------------------------------------------------
// houseCARL acquisition
// ---------------------------------------------------------------------

async function callJson(tool, args, opts) {
  const text = extractHousecarlText(await callHousecarl(tool, args, opts));
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new Error(`${tool} did not return parseable JSON (${error.message}). Raw: ${text.slice(0, 400)}`);
  }
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function propFromNoteAndSubs(entry) {
  return {
    index: Number(entry.index),
    name: entry.name ?? null,
    type: entry.type ?? null,
    object: entry.object ?? null,
    data: entry.data ?? null,
    hasNullLink: entry.object === "(null link)",
  };
}

// Parse a batch_record_detail "fields" array into script entries under rootPrefix.
function parseScriptEntries(fields, rootPrefix) {
  const esc = rootPrefix.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const scriptNameRe = new RegExp(`^${esc}\\[(\\d+)\\]\\.Name$`);
  const propCountRe = new RegExp(`^${esc}\\[(\\d+)\\]\\.Properties$`);
  const propNoteRe = new RegExp(`^${esc}\\[(\\d+)\\]\\.Properties\\[(\\d+)\\]$`);
  const propSubRe = new RegExp(`^${esc}\\[(\\d+)\\]\\.Properties\\[(\\d+)\\]\\.(Name|Data|Object)$`);
  const scripts = new Map();
  const ensure = (si) => {
    if (!scripts.has(si)) scripts.set(si, { name: null, propCount: null, properties: new Map() });
    return scripts.get(si);
  };
  for (const f of fields) {
    let m;
    if ((m = f.path.match(scriptNameRe))) {
      ensure(m[1]).name = f.value;
    } else if ((m = f.path.match(propCountRe))) {
      const c = String(f.note ?? "").match(/(\d+)\s+item/);
      if (c) ensure(m[1]).propCount = Number(c[1]);
    } else if ((m = f.path.match(propNoteRe))) {
      const props = ensure(m[1]).properties;
      if (!props.has(m[2])) props.set(m[2], { index: m[2] });
      const t = String(f.note ?? "").match(/\[Script(\w+?)Property\]/);
      const n = String(f.note ?? "").match(/Name=(\S+)/);
      if (t) props.get(m[2]).type = t[1];
      if (n) props.get(m[2]).name = n[1];
    } else if ((m = f.path.match(propSubRe))) {
      const props = ensure(m[1]).properties;
      if (!props.has(m[2])) props.set(m[2], { index: m[2] });
      const rec = props.get(m[2]);
      if (m[3] === "Name") rec.name = f.value;
      else if (m[3] === "Data") rec.data = f.value;
      else rec.object = f.value;
    }
  }
  return [...scripts.entries()].map(([si, s]) => ({
    index: Number(si),
    name: s.name,
    propCount: s.propCount,
    properties: [...s.properties.values()].map(propFromNoteAndSubs),
  }));
}

async function shapePass(formids, fieldPath) {
  const out = new Map();
  for (const group of chunk(formids, 50)) {
    const data = await callJson("housecarl_batch_record_detail", {
      formids: group, fields: [fieldPath], depth: 3, format: "json", max_chars: 200_000,
    }, { timeoutMs: 90_000 });
    if (data.truncated) throw new Error(`Shape pass truncated on a 50-record chunk for ${fieldPath}; reduce chunk size.`);
    for (const rec of data.records) out.set(rec.formid, parseScriptEntries(rec.fields, fieldPath));
  }
  return out;
}

// Explicit per-index reads: the only way past houseCARL's bounded generic
// container expansion for the 512-property manager quest.
async function detailPassExplicit(formid, propsPath, propCount) {
  const all = new Map();
  for (const group of chunk(Array.from({ length: propCount }, (_, i) => i), 60)) {
    let attempt = group;
    for (;;) {
      const data = await callJson("housecarl_batch_record_detail", {
        formids: [formid], fields: attempt.map((i) => `${propsPath}[${i}]`),
        depth: 3, format: "json", max_chars: 200_000,
      }, { timeoutMs: 90_000 });
      if (data.truncated) {
        if (attempt.length <= 1) throw new Error(`${formid} ${propsPath}[${attempt[0]}] truncates alone; cannot read.`);
        attempt = attempt.slice(0, Math.ceil(attempt.length / 2));
        log(`  truncation on ${formid}; halving to ${attempt.length} indices`);
        continue;
      }
      for (const f of data.records[0].fields) {
        const m = f.path.match(/\.Properties\[(\d+)\](?:\.(Name|Data|Object))?$/);
        if (!m) continue;
        if (!all.has(m[1])) all.set(m[1], { index: m[1] });
        const e = all.get(m[1]);
        if (!m[2]) {
          const t = String(f.note ?? "").match(/\[Script(\w+?)Property\]/);
          const n = String(f.note ?? "").match(/Name=(\S+)/);
          if (t) e.type = t[1];
          if (n) e.name = n[1];
        } else if (m[2] === "Name") e.name = f.value;
        else if (m[2] === "Data") e.data = f.value;
        else e.object = f.value;
      }
      break;
    }
  }
  return [...all.values()].map(propFromNoteAndSubs);
}

async function detailPassGeneric(formids, rootPrefix) {
  const data = await callJson("housecarl_batch_record_detail", {
    formids, fields: [rootPrefix], depth: 4, format: "json", max_chars: 400_000,
  }, { timeoutMs: 120_000 });
  if (data.truncated) return null;
  const out = new Map();
  for (const rec of data.records) out.set(rec.formid, parseScriptEntries(rec.fields, rootPrefix));
  return out;
}

async function readProperties(w) {
  if (w.propCount === 0) return [];
  if (w.propCount > BIG_THRESHOLD) {
    return detailPassExplicit(w.formid, `${w.rootPrefix}[${w.scriptIndex}].Properties`, w.propCount);
  }
  const result = await detailPassGeneric([w.formid], w.rootPrefix);
  return result?.get(w.formid)?.find((s) => s.index === w.scriptIndex)?.properties ?? [];
}

// ---------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------

async function main() {
  log("Confirming houseCARL instance/profile...");
  const statusText = extractHousecarlText(await callHousecarl("housecarl_load_order_status", { lookup: PLUGIN }));
  if (!/as a plugin:\s*ACTIVE/.test(statusText)) {
    throw new Error(`${PLUGIN} is not ACTIVE in the current MO2 profile. A wrong-profile or wrong-instance read returns a plausible WRONG answer, never an error.\n${statusText}`);
  }
  const instance = statusText.match(/instance:\s*(.+)/)?.[1]?.trim() ?? null;
  const profile = statusText.match(/profile '([^']+)'/)?.[1] ?? null;
  log(`  instance: ${instance}\n  profile: ${profile}`);

  log(`Parsing Papyrus sources from ${SOURCE_DIR} ...`);
  const scripts = parseScriptSources(SOURCE_DIR);
  const sourceFileCount = fs.readdirSync(SOURCE_DIR).filter((f) => f.toLowerCase().endsWith(".psc")).length;
  log(`  ${scripts.size} script classes from ${sourceFileCount} .psc files`);

  // Mirror divergence is reported, never silently absorbed: auditing the repo
  // mirror instead of the live tree manufactures phantom "no source" gaps.
  let mirrorDivergence = null;
  if (path.resolve(MIRROR_DIR) !== path.resolve(SOURCE_DIR) && fs.existsSync(MIRROR_DIR)) {
    const live = new Set(fs.readdirSync(SOURCE_DIR).filter((f) => f.toLowerCase().endsWith(".psc")));
    const mirror = new Set(fs.readdirSync(MIRROR_DIR).filter((f) => f.toLowerCase().endsWith(".psc")));
    const onlyLive = [...live].filter((f) => !mirror.has(f));
    const onlyMirror = [...mirror].filter((f) => !live.has(f));
    if (onlyLive.length || onlyMirror.length) {
      mirrorDivergence = { mirrorDir: MIRROR_DIR, liveCount: live.size, mirrorCount: mirror.size, onlyInLive: onlyLive, onlyInMirror: onlyMirror };
      log(`  WARNING: repo mirror differs from the tree read (live ${live.size} vs mirror ${mirror.size}).`);
      if (onlyLive.length) log(`    live-only: ${onlyLive.join(", ")}`);
      if (onlyMirror.length) log(`    mirror-only: ${onlyMirror.join(", ")}`);
    }
  }

  const waivers = loadWaivers();
  log(`  ${waivers.length} waiver group(s) loaded`);

  log(`Enumerating VMAD-carrying records in ${PLUGIN} ...`);
  const enumeration = await callJson("housecarl_cross_plugin_query", {
    plugins: [PLUGIN], defined_in: true, where: ["VirtualMachineAdapter exists"],
    format: "json", limit: 2000, max_chars: 400_000,
  });
  if (enumeration.truncated || enumeration.capped) {
    throw new Error(`Enumeration truncated/capped (total=${enumeration.total}). Raise limit/max_chars.`);
  }
  const records = enumeration.matches.map((m) => ({ formid: m.formid, type: m.type, editorid: m.editorid }));
  log(`  enumerated ${records.length} records`);

  log("Shape pass...");
  const scriptShapes = await shapePass(records.map((r) => r.formid), "VirtualMachineAdapter.Scripts");

  // The manager quest also carries an alias-attached script; the record-level
  // enumeration yields one row per RECORD, so this script is invisible to it.
  let aliasShape = [];
  if (records.some((r) => r.formid === MANAGER_FORMID)) {
    const aliasData = await callJson("housecarl_batch_record_detail", {
      formids: [MANAGER_FORMID], fields: ["VirtualMachineAdapter.Aliases[0].Scripts"], depth: 3, format: "json", max_chars: 50_000,
    });
    aliasShape = parseScriptEntries(aliasData.records[0].fields, "VirtualMachineAdapter.Aliases[0].Scripts");
  }

  const work = [];
  for (const rec of records) {
    for (const s of scriptShapes.get(rec.formid) ?? []) {
      work.push({ ...rec, rootPrefix: "VirtualMachineAdapter.Scripts", scriptIndex: s.index, scriptName: s.name, propCount: s.propCount ?? 0 });
    }
  }
  for (const s of aliasShape) {
    work.push({ formid: MANAGER_FORMID, type: "Quest", editorid: "PDV__ManagerQuest [Aliases[0]]", rootPrefix: "VirtualMachineAdapter.Aliases[0].Scripts", scriptIndex: s.index, scriptName: s.name, propCount: s.propCount ?? 0 });
  }
  log(`  ${work.length} script attachments (${aliasShape.length} alias-attached)`);

  log("Detail pass...");
  const keyOf = (w) => `${w.formid}#${w.rootPrefix}#${w.scriptIndex}`;
  const liveByWork = new Map();
  for (const w of work.filter((x) => x.propCount === 0)) liveByWork.set(keyOf(w), []);
  for (const w of work.filter((x) => x.propCount > BIG_THRESHOLD)) {
    log(`  explicit-index read: ${w.editorid} / ${w.scriptName} (${w.propCount} properties)`);
    liveByWork.set(keyOf(w), await readProperties(w));
  }
  for (const rootPrefix of ["VirtualMachineAdapter.Scripts", "VirtualMachineAdapter.Aliases[0].Scripts"]) {
    const items = work.filter((w) => w.rootPrefix === rootPrefix && w.propCount > 0 && w.propCount <= BIG_THRESHOLD);
    let batch = [];
    const flush = async () => {
      if (!batch.length) return;
      const current = batch;
      batch = [];
      const result = await detailPassGeneric([...new Set(current.map((w) => w.formid))], rootPrefix);
      if (result === null) {
        log(`  generic batch truncated (${current.length}); halving`);
        const half = Math.ceil(current.length / 2);
        batch = current.slice(0, half); await flush();
        batch = current.slice(half); await flush();
        return;
      }
      for (const w of current) {
        liveByWork.set(keyOf(w), (result.get(w.formid) ?? []).find((s) => s.index === w.scriptIndex)?.properties ?? []);
      }
    };
    let budget = 0;
    for (const w of items) {
      if (batch.length >= 30 || budget + w.propCount > 500) { await flush(); budget = 0; }
      batch.push(w); budget += w.propCount;
    }
    await flush();
  }

  if (liveByWork.size !== work.length) {
    throw new Error(`Analysed ${liveByWork.size} script attachments but enumerated ${work.length}. Every record must be accounted for.`);
  }
  log(`  analysed ${liveByWork.size}/${work.length} script attachments`);

  // -------------------------------------------------------------
  // Detectors
  // -------------------------------------------------------------
  const hypotheses = [];
  const missingSourceWarnings = [];
  // Papyrus and VMAD property matching are case-insensitive. Preserve original
  // spelling for reports, but normalize every comparison key.
  const propertyKey = (name) => String(name ?? "").toLowerCase();
  const liveNamesFor = (w) => new Map((liveByWork.get(keyOf(w)) ?? []).filter((p) => p.name).map((p) => [propertyKey(p.name), p]));

  for (const w of work) {
    if (!scripts.has(w.scriptName)) {
      missingSourceWarnings.push(`${w.editorid} (${w.formid}) attaches "${w.scriptName}" with no matching .psc in ${SOURCE_DIR}.`);
      continue;
    }
    const effective = resolveEffectiveProperties(scripts, w.scriptName);
    const effectiveByKey = new Map([...effective].map(([name, decl]) => [propertyKey(name), { name, decl }]));
    const liveProperties = liveByWork.get(keyOf(w)) ?? [];
    const liveByName = liveNamesFor(w);
    for (const [property, decl] of effective) {
      if (decl.autoReadOnly || decl.optional || !decl.isObject) continue;
      const live = liveByName.get(propertyKey(property));
      if (!live) {
        hypotheses.push({ detector: "B", formid: w.formid, editorid: w.editorid, scriptName: w.scriptName, declaredIn: decl.declaredIn, property, declaredType: decl.type });
      } else if (live.hasNullLink) {
        hypotheses.push({ detector: "C", formid: w.formid, editorid: w.editorid, scriptName: w.scriptName, declaredIn: decl.declaredIn, property, declaredType: decl.type });
      }
    }
    const liveNameCounts = new Map();
    for (const live of liveProperties.filter((property) => property.name)) {
      const key = propertyKey(live.name);
      const current = liveNameCounts.get(key) ?? { name: live.name, count: 0 };
      current.count += 1;
      liveNameCounts.set(key, current);
      if (!effectiveByKey.has(key)) {
        hypotheses.push({ detector: "D", formid: w.formid, editorid: w.editorid, scriptName: w.scriptName, declaredIn: w.scriptName, property: live.name, declaredType: live.type ?? "VMAD-only" });
      }
    }
    for (const { name: property, count: occurrenceCount } of liveNameCounts.values()) {
      if (occurrenceCount > 1) {
        const decl = effectiveByKey.get(propertyKey(property))?.decl;
        hypotheses.push({ detector: "E", formid: w.formid, editorid: w.editorid, scriptName: w.scriptName, declaredIn: decl?.declaredIn ?? w.scriptName, property, declaredType: decl?.type ?? "VMAD-only", occurrenceCount });
      }
    }
  }

  // Detector A: within an immediate-parent family, report only ABSENT-where-the-
  // majority-is-PRESENT. The opposite direction (present on a minority) is extra
  // configuration, not a silent zero, and reporting it buries the real signal.
  const families = new Map();
  for (const w of work) {
    if (!scripts.has(w.scriptName)) continue;
    const key = familyKey(scripts, w.scriptName);
    if (!families.has(key)) families.set(key, []);
    families.get(key).push(w);
  }
  for (const [family, members] of families) {
    if (members.length < 3) continue;
    const candidates = new Map();
    for (const m of members) {
      for (const [property, decl] of resolveEffectiveProperties(scripts, m.scriptName)) {
        if (!decl.autoReadOnly && !decl.optional) candidates.set(property, decl);
      }
    }
    for (const [property, decl] of candidates) {
      const present = members.filter((m) => liveNamesFor(m).has(propertyKey(property)));
      if (present.length / members.length < 0.6) continue;
      for (const m of members.filter((x) => !liveNamesFor(x).has(propertyKey(property)))) {
        // Attribute to the FAMILY, not to decl.declaredIn: when each leaf declares
        // its own copy (every Prince declares its own Notif_Stigma_* trio), the
        // candidate map holds whichever member happened to be scanned last, and
        // reporting that name credits an arbitrary sibling for another's absence.
        hypotheses.push({ detector: "A", formid: m.formid, editorid: m.editorid, scriptName: m.scriptName, declaredIn: family, property, declaredType: decl.type, family, familySize: members.length, presentCount: present.length });
      }
    }
  }

  // -------------------------------------------------------------
  // Waive, then verify survivors with an independent per-record re-read
  // -------------------------------------------------------------
  const waived = [];
  const active = [];
  for (const h of hypotheses) {
    const w = waiverFor(waivers, h);
    if (w) waived.push({ ...h, waiverReason: w.reason });
    else active.push(h);
  }
  log(`Hypotheses: ${hypotheses.length} (${waived.length} waived, ${active.length} to verify)`);

  const verifyCache = new Map();
  for (const formid of new Set(active.map((f) => f.formid))) {
    const perScript = new Map();
    for (const w of work.filter((x) => x.formid === formid)) {
      const list = (await readProperties(w)).filter((p) => p.name);
      perScript.set(`${w.rootPrefix}#${w.scriptIndex}`, { list, byName: new Map(list.map((p) => [propertyKey(p.name), p])) });
    }
    verifyCache.set(formid, perScript);
  }

  const confirmed = [];
  const dropped = [];
  for (const f of active) {
    const w = work.find((x) => x.formid === f.formid && x.scriptName === f.scriptName);
    const props = w && verifyCache.get(f.formid)?.get(`${w.rootPrefix}#${w.scriptIndex}`);
    if (!props) { dropped.push({ ...f, reason: "re-read produced no data" }); continue; }
    const live = props.byName.get(propertyKey(f.property));
    if (f.detector === "C") {
      if (live?.hasNullLink) confirmed.push(f);
      else dropped.push({ ...f, reason: live ? `re-read shows ${live.object ?? live.data}, not null` : "re-read shows the property absent" });
    } else if (f.detector === "D") {
      const effective = w && scripts.has(w.scriptName) ? resolveEffectiveProperties(scripts, w.scriptName) : new Map();
      const declared = [...effective.keys()].some((name) => propertyKey(name) === propertyKey(f.property));
      if (live && !declared) confirmed.push(f);
      else dropped.push({ ...f, reason: live ? "re-read source now declares the property" : "re-read shows the VMAD fill absent" });
    } else if (f.detector === "E") {
      const occurrenceCount = props.list.filter((property) => propertyKey(property.name) === propertyKey(f.property)).length;
      if (occurrenceCount > 1) confirmed.push({ ...f, occurrenceCount });
      else dropped.push({ ...f, reason: `re-read shows ${occurrenceCount} occurrence(s), not a duplicate` });
    } else if (live) {
      dropped.push({ ...f, reason: "re-read found the property bound after all" });
    } else {
      confirmed.push(f);
    }
  }
  log(`Confirmed ${confirmed.length}, dropped ${dropped.length} after independent re-read`);

  // -------------------------------------------------------------
  // Report grouped by (declaring script, property), not per instance
  // -------------------------------------------------------------
  // A detector-A hit on a property detector B already reported is the same
  // defect seen twice: B says "declared and absent", A says "absent unlike your
  // siblings". Report it once, as B, carrying A's family split as context --
  // listing both doubles the apparent finding count over identical records.
  const objectLevel = confirmed.filter((f) => f.detector !== "A");
  const objectKeys = new Set(objectLevel.map((f) => `${f.formid}|${f.property}`));
  const familyContext = new Map();
  const siblingOnly = [];
  for (const f of confirmed.filter((x) => x.detector === "A")) {
    if (objectKeys.has(`${f.formid}|${f.property}`)) {
      familyContext.set(`${f.declaredIn}|${f.property}`, { family: f.family, familySize: f.familySize, presentCount: f.presentCount });
      familyContext.set(`${f.property}`, { family: f.family, familySize: f.familySize, presentCount: f.presentCount });
    } else {
      siblingOnly.push(f);
    }
  }

  const groups = new Map();
  for (const f of [...objectLevel, ...siblingOnly]) {
    const key = `${f.detector}|${f.declaredIn}|${f.property}`;
    if (!groups.has(key)) {
      const ctx = f.detector === "A" ? f : (familyContext.get(`${f.declaredIn}|${f.property}`) ?? familyContext.get(`${f.property}`) ?? {});
      groups.set(key, { detector: f.detector, declaredIn: f.declaredIn, property: f.property, declaredType: f.declaredType, family: ctx.family ?? null, familySize: ctx.familySize ?? null, presentCount: ctx.presentCount ?? null, records: [] });
    }
    groups.get(key).records.push({ formid: f.formid, editorid: f.editorid, scriptName: f.scriptName });
  }
  const findingGroups = [...groups.values()].sort((a, b) => b.records.length - a.records.length);
  const reportedFindings = objectLevel.length + siblingOnly.length;

  const report = {
    status: confirmed.length ? "FINDINGS" : "CLEAN",
    instance, profile, plugin: PLUGIN,
    sourceDir: SOURCE_DIR, sourceFileCount, scriptClasses: scripts.size,
    mirrorDivergence,
    enumeratedRecords: records.length,
    analysedScriptAttachments: liveByWork.size,
    counts: {
      hypotheses: hypotheses.length,
      waived: waived.length,
      verified: active.length,
      confirmed: confirmed.length,
      reported: reportedFindings,
      dedupedIntoObjectLevel: confirmed.filter((f) => f.detector === "A").length - siblingOnly.length,
      dropped: dropped.length,
      byDetector: ["A", "B", "C", "D", "E"].reduce((acc, d) => ({ ...acc, [d]: confirmed.filter((f) => f.detector === d).length }), {}),
    },
    findingGroups,
    dropped,
    waivedSample: waived.slice(0, 20),
    missingSourceWarnings,
  };

  if (json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`\nVMAD property audit -- ${PLUGIN}`);
    console.log(`  instance ${instance} | profile ${profile}`);
    console.log(`  source   ${SOURCE_DIR} (${sourceFileCount} .psc, ${scripts.size} classes)`);
    if (mirrorDivergence) {
      console.log(`  WARNING  repo mirror diverges: live ${mirrorDivergence.liveCount} vs mirror ${mirrorDivergence.mirrorCount}`);
      if (mirrorDivergence.onlyInLive.length) console.log(`           live-only: ${mirrorDivergence.onlyInLive.join(", ")}`);
      if (mirrorDivergence.onlyInMirror.length) console.log(`           mirror-only: ${mirrorDivergence.onlyInMirror.join(", ")}`);
    }
    console.log(`  records  ${records.length} enumerated / ${liveByWork.size} script attachments analysed`);
    console.log(`  findings ${hypotheses.length} hypotheses -> ${waived.length} waived -> ${confirmed.length} confirmed (${dropped.length} dropped on re-read)`);
    console.log(`           ${reportedFindings} reported after folding sibling-outlier duplicates into their object-level finding`);
    for (const w of missingSourceWarnings) console.log(`  NOTE     ${w}`);
    if (!findingGroups.length) {
      console.log("\nNo un-waived findings.");
    } else {
      console.log("");
      for (const g of findingGroups) {
        const scope = g.detector === "A" ? ` [family ${g.family}: present on ${g.presentCount}/${g.familySize}]` : "";
        console.log(`[${g.detector}] ${g.declaredIn}.${g.property} (${g.declaredType}) -- ${g.records.length} record(s)${scope}`);
        for (const r of g.records) console.log(`      ${r.formid}  ${r.editorid}`);
      }
    }
    console.log("");
  }
  process.exitCode = confirmed.length ? 1 : 0;
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
