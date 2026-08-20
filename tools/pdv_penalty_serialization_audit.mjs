#!/usr/bin/env node
import { callHousecarl, extractHousecarlText } from "./lib/pdv_housecarl_stdio.mjs";
import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import {
  classifyPenaltyPair,
  extractSpellEffectPairs,
  parseFlags,
  parseRecordBlocks,
} from "./lib/pdv_penalty_serialization.mjs";

const KNOWN_FLAGS = new Set(["--json"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_penalty_serialization_audit" });

const json = process.argv.includes("--json");
const families = ["Neglect", "Disfavor", "Price"];

function text(result) {
  return extractHousecarlText(result);
}

function normalizeFormId(value) {
  return String(value ?? "").trim().toLowerCase();
}

async function inventoryPenaltySpells() {
  const spells = new Map();
  for (const family of families) {
    const result = await callHousecarl("housecarl_cross_plugin_query", {
      plugins: ["Devotion.esp"],
      type: "SPEL",
      editorid_contains: family,
      fields: ["EditorID"],
      limit: 500,
      max_chars: 80_000,
    });
    for (const block of parseRecordBlocks(text(result))) {
      spells.set(normalizeFormId(block.formId), { formId: block.formId, editorId: block.editorId, family });
    }
  }
  return [...spells.values()];
}

async function main() {
  const inventory = await inventoryPenaltySpells();
  const spellResult = await callHousecarl("housecarl_batch_record_detail", {
    formids: inventory.map((spell) => spell.formId),
    fields: ["EditorID", "Effects"],
    depth: 4,
    max_chars: 500_000,
  }, { timeoutMs: 120_000 });
  const spellBlocks = new Map(parseRecordBlocks(text(spellResult)).map((block) => [normalizeFormId(block.formId), block]));

  const pairs = [];
  const preliminaryFailures = [];
  for (const spell of inventory) {
    const block = spellBlocks.get(normalizeFormId(spell.formId));
    if (!block) {
      preliminaryFailures.push({ status: "FAIL", code: "MISSING_SPELL_READBACK", ...spell });
      continue;
    }
    const spellPairs = extractSpellEffectPairs(block);
    if (!spellPairs.length) {
      preliminaryFailures.push({ status: "FAIL", code: "NO_EFFECTS", ...spell });
      continue;
    }
    for (const pair of spellPairs) pairs.push({ ...spell, ...pair });
  }

  const effectIds = [...new Set(pairs.map((pair) => normalizeFormId(pair.baseEffect)))];
  const effectResult = await callHousecarl("housecarl_batch_record_detail", {
    formids: effectIds,
    fields: ["EditorID", "Archetype", "Flags"],
    depth: 3,
    max_chars: 500_000,
  }, { timeoutMs: 120_000 });
  const effects = new Map(parseRecordBlocks(text(effectResult)).map((block) => [normalizeFormId(block.formId), block]));

  const findings = [...preliminaryFailures];
  for (const pair of pairs) {
    const effect = effects.get(normalizeFormId(pair.baseEffect));
    if (!effect) {
      findings.push({ status: "FAIL", code: "MISSING_EFFECT_READBACK", ...pair });
      continue;
    }
    const archetype = effect.fields.get("Archetype.Type") ?? "missing";
    const actorValue = effect.fields.get("Archetype.ActorValue") ?? "missing";
    const flags = parseFlags(effect.fields.get("Flags"));
    if (!["ValueModifier", "PeakValueModifier"].includes(archetype)) {
      findings.push({
        status: "INFO",
        code: "NON_MODIFIER",
        ...pair,
        magicEffectEditorId: effect.editorId,
        archetype,
        actorValue,
        flags,
      });
      continue;
    }
    const classification = classifyPenaltyPair({ magnitude: pair.magnitude, flags });
    findings.push({
      ...classification,
      ...pair,
      magicEffectEditorId: effect.editorId,
      archetype,
      actorValue,
      flags,
    });
  }

  const failures = findings.filter((finding) => finding.status === "FAIL");
  const passes = findings.filter((finding) => finding.status === "PASS");
  const informational = findings.filter((finding) => finding.status === "INFO");
  const report = {
    status: failures.length ? "FAIL" : "PASS",
    authority: "direct-houseCARL-v1.7+",
    plugin: "Devotion.esp",
    families,
    summary: {
      spells: inventory.length,
      linkedEffects: findings.length,
      modifierPairs: passes.length + failures.length,
      valid: passes.length,
      invalid: failures.length,
      nonModifier: informational.length,
    },
    failures,
    informational,
    findings,
  };

  if (json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    for (const failure of failures) {
      console.log(`[FAIL] ${failure.editorId ?? failure.formId} effect[${failure.index ?? "?"}] -> ${failure.magicEffectEditorId ?? failure.baseEffect ?? "missing"}: ${failure.code}; magnitude=${failure.magnitude ?? "missing"}; flags=${failure.flags?.join(",") || "none"}`);
    }
    for (const info of informational) {
      console.log(`[INFO] ${info.editorId} effect[${info.index}] -> ${info.magicEffectEditorId}: ${info.archetype} is outside the modifier sign/flag invariant.`);
    }
    console.log(`Penalty serialization: ${report.status}; spells=${report.summary.spells}; linkedEffects=${report.summary.linkedEffects}; modifiers=${report.summary.modifierPairs}; valid=${report.summary.valid}; invalid=${report.summary.invalid}; nonModifier=${report.summary.nonModifier}`);
  }
  process.exitCode = failures.length ? 1 : 0;
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
