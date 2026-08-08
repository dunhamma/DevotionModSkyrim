#!/usr/bin/env node
/*
 * Read-only Requiem penalty audit.
 *
 * Verifies that active Requiem-swallowed negative HealRateMult penalties have
 * been converted to felt Health penalties, while the owner-ruled Imperial
 * civic neglect row remains ResistDisease -5.
 */
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_requiem_penalty_audit" });

const ROOT = process.cwd();
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const PDV_ESP = path.join(DEVOTION_MOD, "Devotion.esp");
const MUTAGEN_BRIDGE = path.join(
  ANVIL_ROOT,
  "plugins",
  "Anvilmo2_mcp",
  "tools",
  "mutagen-bridge",
  "mutagen-bridge.exe",
);
const AUTHORING = path.join(ROOT, "references", "authoring");

const TARGETS = [
  {
    label: "Argonian Hist Distant",
    specFile: "PDV_ArgonianRewardRecords.spec.json",
    entry: (spec) => spec.neglect,
    spell: "PDV_SPEL_Neglect_ArgonianHist",
    newMgef: "PDV_MGEF_Neglect_ArgonianHist_Health",
    oldMgef: "PDV_MGEF_Neglect_ArgonianHist_HealRate",
    actorValue: "Health",
    archetype: "PeakValueModifier",
    magnitude: -10,
    textMustContain: "Maximum Health -10",
    effectName: "Maximum Health",
  },
  {
    label: "Breton Tradition Grows Distant",
    specFile: "PDV_BretonRewardRecords.spec.json",
    entry: (spec) => spec.neglect,
    spell: "PDV_SPEL_Neglect_Breton",
    newMgef: "PDV_MGEF_Neglect_Breton_Health",
    oldMgef: "PDV_MGEF_Neglect_Breton_Restoration",
    actorValue: "Health",
    archetype: "PeakValueModifier",
    magnitude: -10,
    textMustContain: "Maximum Health -10",
    effectName: "Maximum Health",
  },
  {
    label: "Breton Cast Out",
    specFile: "PDV_BretonRewardRecords.spec.json",
    entry: (spec) => (spec.creedViolationLoss || []).find((loss) => loss.id === "excommunication"),
    spell: "PDV_SPEL_CreedLoss_Breton_Excommunication",
    newMgef: "PDV_SPEL_CreedLoss_Breton_Excommunication_MGEF_Health",
    oldMgef: "PDV_SPEL_CreedLoss_Breton_Excommunication_MGEF_HealRateMult",
    actorValue: "Health",
    archetype: "PeakValueModifier",
    magnitude: -15,
    textMustContain: "Maximum Health -15",
    effectName: "Maximum Health",
  },
];

const PRESERVED = [
  {
    label: "Imperial Divines Grow Distant",
    specFile: "PDV_ImperialRewardRecords.spec.json",
    entry: (spec) => spec.neglect,
    spell: "PDV_SPEL_Neglect_Imperial",
    mgef: "PDV_MGEF_Neglect_Imperial_Restoration",
    actorValue: "ResistDisease",
    archetype: "ValueModifier",
    magnitude: -5,
    textMustContain: "Disease Resistance -5%",
  },
];

const findings = [];

function add(status, check, detail, location = PDV_ESP) {
  findings.push({ status, check, detail, path: location });
}

function pass(check, detail, location) {
  add("PASS", check, detail, location);
}

function fail(check, detail, location) {
  add("FAIL", check, detail, location);
}

function warn(check, detail, location) {
  add("WARN", check, detail, location);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function bridge(request, timeoutMs = 60_000) {
  const result = spawnSync(MUTAGEN_BRIDGE, {
    input: JSON.stringify(request),
    encoding: "utf8",
    timeout: timeoutMs,
    windowsHide: true,
  });
  if (result.error) {
    throw result.error;
  }
  const stdout = (result.stdout || "").trim();
  if (!stdout) {
    throw new Error(`mutagen-bridge returned no output: ${(result.stderr || "").trim()}`);
  }
  const payload = JSON.parse(stdout);
  if (!payload.success) {
    throw new Error(payload.error || payload.message || "bridge call failed");
  }
  return payload;
}

function counts() {
  const result = {};
  for (const finding of findings) {
    result[finding.status] = (result[finding.status] || 0) + 1;
  }
  return result;
}

function almostEqual(left, right) {
  return Math.abs(Number(left) - Number(right)) < 0.001;
}

function hasStaleRegenText(text) {
  return /health regenerat|Health Regeneration/i.test(String(text || ""));
}

function effectMagnitude(effect) {
  return Number(effect?.Data?.Magnitude ?? 0);
}

function getEffect(entry, mgef) {
  return (entry?.effects || []).find((effect) => effect.magicEffectEditorId === mgef);
}

function specPath(fileName) {
  return path.join(AUTHORING, fileName);
}

function checkSpecTarget(target) {
  const filePath = specPath(target.specFile);
  const spec = readJson(filePath);
  const entry = target.entry(spec);
  if (!entry) {
    fail("Requiem penalty spec entry", `${target.label} spec entry is missing.`, filePath);
    return;
  }
  if (entry.spellEditorId === target.spell) {
    pass("Requiem penalty spec spell", `${target.label} keeps ${target.spell}.`, filePath);
  } else {
    fail("Requiem penalty spec spell", `${target.label} spell is ${entry.spellEditorId || "(missing)"}, expected ${target.spell}.`, filePath);
  }

  const effect = getEffect(entry, target.newMgef);
  if (!effect) {
    fail("Requiem penalty spec effect", `${target.label} is not using ${target.newMgef}.`, filePath);
    return;
  }
  if (effect.actorValue === target.actorValue) {
    pass("Requiem penalty spec actor value", `${target.newMgef} uses ${target.actorValue}.`, filePath);
  } else {
    fail("Requiem penalty spec actor value", `${target.newMgef} uses ${effect.actorValue || "(missing)"}, expected ${target.actorValue}.`, filePath);
  }
  if (almostEqual(effect.magnitude, target.magnitude)) {
    pass("Requiem penalty spec magnitude", `${target.newMgef} magnitude ${target.magnitude}.`, filePath);
  } else {
    fail("Requiem penalty spec magnitude", `${target.newMgef} magnitude ${effect.magnitude}, expected ${target.magnitude}.`, filePath);
  }
  if (effect.effectName === target.effectName) {
    pass("Requiem penalty spec effect name", `${target.newMgef} Active Effects name is ${target.effectName}.`, filePath);
  } else {
    fail("Requiem penalty spec effect name", `${target.newMgef} effectName is ${effect.effectName || "(missing)"}, expected ${target.effectName}.`, filePath);
  }
  if (String(entry.playerFacingText || "").includes(target.textMustContain) && !hasStaleRegenText(entry.playerFacingText)) {
    pass("Requiem penalty spec text", `${target.label} text says ${target.textMustContain}.`, filePath);
  } else {
    fail("Requiem penalty spec text", `${target.label} text must include '${target.textMustContain}' and must not mention health regeneration.`, filePath);
  }
}

function checkSpecPreserved(target) {
  const filePath = specPath(target.specFile);
  const spec = readJson(filePath);
  const entry = target.entry(spec);
  const effect = getEffect(entry, target.mgef);
  if (!entry || entry.spellEditorId !== target.spell || !effect) {
    fail("Requiem preserved spec", `${target.label} preserved Imperial row is missing or renamed.`, filePath);
    return;
  }
  if (effect.actorValue === target.actorValue && almostEqual(effect.magnitude, target.magnitude)) {
    pass("Requiem preserved spec", `${target.label} remains ${target.actorValue} ${target.magnitude}.`, filePath);
  } else {
    fail("Requiem preserved spec", `${target.label} is ${effect.actorValue || "(missing)"} ${effect.magnitude}, expected ${target.actorValue} ${target.magnitude}.`, filePath);
  }
  if (String(entry.playerFacingText || "").includes(target.textMustContain) && !hasStaleRegenText(entry.playerFacingText)) {
    pass("Requiem preserved spec text", `${target.label} text remains disease-resistance based.`, filePath);
  } else {
    fail("Requiem preserved spec text", `${target.label} text drifted or mentions health regeneration.`, filePath);
  }
}

function readLiveDetails(recordsByEdid, edids) {
  const detailRecords = [...edids]
    .map((edid) => recordsByEdid.get(edid))
    .filter(Boolean)
    .map((record) => ({ plugin_path: PDV_ESP.replaceAll("\\", "/"), formid: record.formid }));
  if (!detailRecords.length) {
    return new Map();
  }
  const detail = bridge({ command: "read_records", max_depth: 10, records: detailRecords }, 120_000);
  return new Map((detail.records || []).filter((record) => record.success).map((record) => [record.editor_id, record]));
}

function readAllSpellDetails(plugin) {
  const spellRecords = (plugin.records || [])
    .filter((record) => record.type === "SPEL")
    .map((record) => ({ plugin_path: PDV_ESP.replaceAll("\\", "/"), formid: record.formid }));
  const details = new Map();
  for (let index = 0; index < spellRecords.length; index += 100) {
    const chunk = spellRecords.slice(index, index + 100);
    const detail = bridge({ command: "read_records", max_depth: 6, records: chunk }, 120_000);
    for (const record of (detail.records || []).filter((entry) => entry.success)) {
      details.set(record.editor_id, record);
    }
  }
  return details;
}

function checkLiveTarget(target, recordsByEdid, detailsByEdid, allSpellDetails) {
  const spell = recordsByEdid.get(target.spell);
  const mgef = recordsByEdid.get(target.newMgef);
  const old = recordsByEdid.get(target.oldMgef);
  const spellDetail = detailsByEdid.get(target.spell);
  const mgefDetail = detailsByEdid.get(target.newMgef);

  if (spell?.type === "SPEL") {
    pass("Requiem penalty live spell", `${target.spell} exists as SPEL.`);
  } else {
    fail("Requiem penalty live spell", `${target.spell} is missing as SPEL.`);
    return;
  }
  if (mgef?.type === "MGEF") {
    pass("Requiem penalty live MGEF", `${target.newMgef} exists as MGEF.`);
  } else {
    fail("Requiem penalty live MGEF", `${target.newMgef} is missing as MGEF.`);
    return;
  }

  const fields = mgefDetail?.fields || {};
  const archetype = fields.Archetype || {};
  if (archetype.ActorValue === target.actorValue && archetype.Type === target.archetype) {
    pass("Requiem penalty live archetype", `${target.newMgef} is ${target.archetype}/${target.actorValue}.`);
  } else {
    fail("Requiem penalty live archetype", `${target.newMgef} is ${archetype.Type || "(missing)"}/${archetype.ActorValue || "(missing)"}, expected ${target.archetype}/${target.actorValue}.`);
  }
  if (fields.Name === target.effectName) {
    pass("Requiem penalty live effect name", `${target.newMgef} name is ${target.effectName}.`);
  } else {
    fail("Requiem penalty live effect name", `${target.newMgef} name is ${fields.Name || "(missing)"}, expected ${target.effectName}.`);
  }
  if (String(fields.Description || "").includes(target.textMustContain) && !hasStaleRegenText(fields.Description)) {
    pass("Requiem penalty live MGEF text", `${target.newMgef} text says ${target.textMustContain}.`);
  } else {
    fail("Requiem penalty live MGEF text", `${target.newMgef} text is stale or missing ${target.textMustContain}.`);
  }

  const effects = spellDetail?.fields?.Effects || [];
  const linked = effects.find((effect) => effect.BaseEffect === mgef.formid);
  if (!linked) {
    fail("Requiem penalty live spell effect", `${target.spell} does not include ${target.newMgef}.`);
  } else if (almostEqual(effectMagnitude(linked), target.magnitude)) {
    pass("Requiem penalty live magnitude", `${target.spell}/${target.newMgef} magnitude ${target.magnitude}.`);
  } else {
    fail("Requiem penalty live magnitude", `${target.spell}/${target.newMgef} magnitude ${effectMagnitude(linked)}, expected ${target.magnitude}.`);
  }
  if (String(spellDetail?.fields?.Description || "").includes(target.textMustContain) && !hasStaleRegenText(spellDetail?.fields?.Description)) {
    pass("Requiem penalty live SPEL text", `${target.spell} text says ${target.textMustContain}.`);
  } else {
    fail("Requiem penalty live SPEL text", `${target.spell} text is stale or missing ${target.textMustContain}.`);
  }

  if (!old) {
    warn("Requiem penalty old MGEF", `${target.oldMgef} is absent; no reverse reference possible.`);
    return;
  }
  const refs = [];
  for (const [spellEdid, detail] of allSpellDetails.entries()) {
    const usesOld = (detail.fields?.Effects || []).some((effect) => effect.BaseEffect === old.formid);
    if (usesOld) {
      refs.push(spellEdid);
    }
  }
  if (refs.length === 0) {
    pass("Requiem penalty old MGEF orphan", `${target.oldMgef} has zero SPEL refs.`);
  } else {
    fail("Requiem penalty old MGEF orphan", `${target.oldMgef} is still referenced by ${refs.join(", ")}.`);
  }
}

function checkLivePreserved(target, recordsByEdid, detailsByEdid) {
  const spell = recordsByEdid.get(target.spell);
  const mgef = recordsByEdid.get(target.mgef);
  const spellDetail = detailsByEdid.get(target.spell);
  const mgefDetail = detailsByEdid.get(target.mgef);
  if (spell?.type !== "SPEL" || mgef?.type !== "MGEF") {
    fail("Requiem preserved live records", `${target.label} missing ${target.spell} or ${target.mgef}.`);
    return;
  }
  const archetype = mgefDetail?.fields?.Archetype || {};
  if (archetype.ActorValue === target.actorValue && archetype.Type === target.archetype) {
    pass("Requiem preserved live archetype", `${target.mgef} remains ${target.archetype}/${target.actorValue}.`);
  } else {
    fail("Requiem preserved live archetype", `${target.mgef} is ${archetype.Type || "(missing)"}/${archetype.ActorValue || "(missing)"}, expected ${target.archetype}/${target.actorValue}.`);
  }
  const linked = (spellDetail?.fields?.Effects || []).find((effect) => effect.BaseEffect === mgef.formid);
  if (linked && almostEqual(effectMagnitude(linked), target.magnitude)) {
    pass("Requiem preserved live magnitude", `${target.spell}/${target.mgef} magnitude ${target.magnitude}.`);
  } else {
    fail("Requiem preserved live magnitude", `${target.spell}/${target.mgef} magnitude ${linked ? effectMagnitude(linked) : "(missing)"}, expected ${target.magnitude}.`);
  }
  const text = `${spellDetail?.fields?.Description || ""}\n${mgefDetail?.fields?.Description || ""}`;
  if (text.includes(target.textMustContain) && !hasStaleRegenText(text)) {
    pass("Requiem preserved live text", `${target.label} live text remains disease-resistance based.`);
  } else {
    fail("Requiem preserved live text", `${target.label} live text drifted or mentions health regeneration.`);
  }
}

function main() {
  for (const target of TARGETS) {
    checkSpecTarget(target);
  }
  for (const target of PRESERVED) {
    checkSpecPreserved(target);
  }

  const scan = bridge({ command: "scan", plugins: [PDV_ESP.replaceAll("\\", "/")] });
  const plugin = scan.plugins?.[0];
  if (!plugin) {
    throw new Error("Mutagen scan returned no plugin payload.");
  }
  const recordsByEdid = new Map((plugin.records || []).filter((record) => record.edid).map((record) => [record.edid, record]));
  const detailEdids = new Set();
  for (const target of TARGETS) {
    detailEdids.add(target.spell);
    detailEdids.add(target.newMgef);
    detailEdids.add(target.oldMgef);
  }
  for (const target of PRESERVED) {
    detailEdids.add(target.spell);
    detailEdids.add(target.mgef);
  }
  const detailsByEdid = readLiveDetails(recordsByEdid, detailEdids);
  const allSpellDetails = readAllSpellDetails(plugin);

  for (const target of TARGETS) {
    checkLiveTarget(target, recordsByEdid, detailsByEdid, allSpellDetails);
  }
  for (const target of PRESERVED) {
    checkLivePreserved(target, recordsByEdid, detailsByEdid);
  }

  const summary = {
    timestamp_utc: new Date().toISOString(),
    counts: counts(),
    findings,
  };
  console.log(JSON.stringify(summary, null, 2));
  process.exit((summary.counts.FAIL || 0) > 0 ? 1 : 0);
}

try {
  main();
} catch (error) {
  console.error(`pdv_requiem_penalty_audit: ${error.message}`);
  process.exit(1);
}
