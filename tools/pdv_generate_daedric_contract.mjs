#!/usr/bin/env node
/*
 * =============================== DO NOT BLIND-RUN ===============================
 * `references/authoring/PDV_DaedricPrinceRecordContracts.json` is generated from the
 * content manifest, race/Prince matrix, and the explicit effect model in
 * `tools/lib/pdv_daedric_effect_model.mjs`. The JSON remains the record-authoring
 * contract, while the effect model owns effect axes, bands, and exceptional packets.
 *
 * This banner used to say the generator DIVERGED from that curated file and that
 * re-running would revert the fixes. Measured 2026-08-08: it no longer does. A default
 * run reports `wouldChangeCuratedContract: false` with no drifted princes, i.e. the
 * generator and the curated JSON now agree on everything except the `generatedAtLocal`
 * timestamp, which is excluded from the comparison. The reconciliation the old banner
 * asked for has happened.
 *
 * That does not make blind-running safe, it makes the guard checkable - so the warning
 * is now ENFORCED rather than merely written down. A comment guards nothing, and the
 * default run used to overwrite the curated JSON and 15 live .psc files regardless:
 *
 *   (no flags)                          compute and report a diff. Writes NOTHING.
 *   --write-contract                    write the JSON, but REFUSE if it would change
 *                                       curated content. --force overrides that refusal.
 *   --scaffold-scripts --source-dir P   write the .psc files, into P. No default path.
 *
 * The two jobs are separated because they have different cadences and different risk:
 * regenerating a contract must never be able to invalidate a build's bytecode as a
 * side effect. See issue #35 items 1 and 2.
 * =================================================================================
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  buildPrinceSpellPackets,
  validateDaedricEffectModel,
} from "./lib/pdv_daedric_effect_model.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const MANIFEST = path.join(PROJECT_ROOT, "race-sheets", "PDV_DaedricContent_Manifest.md");
const MATRIX = path.join(PROJECT_ROOT, "references", "phase4", "PDV_DaedricRacePrinceMatrix.csv");
const OUT = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DaedricPrinceRecordContracts.json");

const KNOWN_FLAGS = new Set(["--write-contract", "--scaffold-scripts", "--source-dir", "--force", "--self-test"]);
const ARGS = process.argv.slice(2);
for (const arg of ARGS) {
  if (arg.startsWith("--") && !KNOWN_FLAGS.has(arg)) {
    console.error(`Unknown argument: ${arg}. Known: ${[...KNOWN_FLAGS].join(", ")}`);
    process.exit(2);
  }
}
const flag = (name) => ARGS.includes(name);
const argValue = (name) => {
  const i = ARGS.indexOf(name);
  if (i < 0) return null;
  const v = ARGS[i + 1];
  if (!v || v.startsWith("--")) {
    console.error(`${name} requires a value`);
    process.exit(2);
  }
  return v;
};

const WRITE_CONTRACT = flag("--write-contract");
const SCAFFOLD = flag("--scaffold-scripts");
const FORCE = flag("--force");
const SELF_TEST = flag("--self-test");
if (SELF_TEST && (WRITE_CONTRACT || SCAFFOLD || FORCE)) {
  console.error("--self-test cannot be combined with write or force flags.");
  process.exit(2);
}

// No default. The old hardcoded "D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source"
// tied the tool to one machine and one MO2 instance, and silently wrote into a live build.
const SOURCE_DIR = argValue("--source-dir");

const RACE_ORDER_MATRIX = ["Nord", "Imperial", "Breton", "Dunmer", "Altmer", "Khajiit", "Bosmer", "Redguard", "Orc", "Argonian"];
const RACE_ORDER_PDV = ["Nord", "Imperial", "Breton", "Altmer", "Bosmer", "Dunmer", "Khajiit", "Argonian", "Orc", "Redguard"];

const PRINCE_META = {
  Azura: { displayName: "Azura", aliases: ["Azura / Azurah"], batch: 0, stigmaClass: "Standard" },
  Boethiah: { displayName: "Boethiah", aliases: ["Boethiah / Boethra"], batch: "pilot", stigmaClass: "Standard" },
  Mephala: { displayName: "Mephala", aliases: ["Mephala / Mafala"], batch: 1, stigmaClass: "Standard" },
  Malacath: { displayName: "Malacath", aliases: ["Malacath / Mauloch"], batch: 1, stigmaClass: "Standard" },
  Meridia: { displayName: "Meridia", aliases: ["Meridia"], batch: 0, stigmaClass: "Tolerated" },
  Nocturnal: { displayName: "Nocturnal", aliases: ["Nocturnal"], batch: 2, stigmaClass: "Standard" },
  Mora: { displayName: "Hermaeus Mora", aliases: ["Hermaeus Mora"], batch: 2, stigmaClass: "Standard" },
  Dagon: { displayName: "Mehrunes Dagon", aliases: ["Mehrunes Dagon"], batch: 2, stigmaClass: "High-rupture" },
  Sheo: { displayName: "Sheogorath", aliases: ["Sheogorath"], batch: 2, stigmaClass: "Standard" },
  Vile: { displayName: "Clavicus Vile", aliases: ["Clavicus Vile"], batch: 2, stigmaClass: "Standard" },
  Vaermina: { displayName: "Vaermina", aliases: ["Vaermina"], batch: 0, stigmaClass: "Standard" },
  Sanguine: { displayName: "Sanguine", aliases: ["Sanguine / Sangiin"], batch: 2, stigmaClass: "Standard" },
  Namira: { displayName: "Namira", aliases: ["Namira / Namiira"], batch: 2, stigmaClass: "Standard" },
  Peryite: { displayName: "Peryite", aliases: ["Peryite"], batch: 3, stigmaClass: "Tolerated" },
  Hircine: { displayName: "Hircine", aliases: ["Hircine"], batch: 3, stigmaClass: "Curse-access", existingScript: true },
  Molag: { displayName: "Molag Bal", aliases: ["Molag Bal"], batch: 0, stigmaClass: "Curse-access" },
};

const STATE_VALUE = { Native: 0, Legible: 1, Foreign: 2, Tolerated: 3, Taboo: 4, Hostile: 5, Curse: 6 };
const STIGMA_MOD = { Native: 0.0, Legible: 0.75, Foreign: 1.0, Tolerated: 0.5, Taboo: 1.25, Hostile: 1.5, Curse: 1.5 };
const EXIT_DIFFICULTY = { Native: 0, Legible: 1, Foreign: 1, Tolerated: 1, Taboo: 2, Hostile: 3, Curse: 3 };

function csvRows(text) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') {
        field += '"';
        i += 1;
      } else if (ch === '"') {
        quoted = false;
      } else {
        field += ch;
      }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === ",") {
      row.push(field);
      field = "";
    } else if (ch === "\n") {
      row.push(field.replace(/\r$/, ""));
      rows.push(row);
      row = [];
      field = "";
    } else {
      field += ch;
    }
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  const [headers, ...data] = rows.filter((r) => r.length && r.some(Boolean));
  return data.map((r) => Object.fromEntries(headers.map((h, i) => [h, r[i] ?? ""])));
}

function tableRows(block) {
  return block
    .split(/\r?\n/)
    .filter((line) => /^\|\s*PDV_/.test(line))
    .map((line) => {
      const cells = line.split("|").slice(1, -1).map((c) => c.trim());
      return { id: cells[0], finalText: cells[cells.length - 1] };
    });
}

function sectionFor(manifest, startPattern, endPattern) {
  const start = manifest.search(startPattern);
  if (start < 0) throw new Error(`Section not found: ${startPattern}`);
  const rest = manifest.slice(start);
  const end = rest.search(endPattern);
  return end < 0 ? rest : rest.slice(0, end);
}

function messageParts(text, fallbackTitle) {
  const match = text.match(/Title:\s*"([^"]+)"\s*Body:\s*"([\s\S]+)"\s*$/);
  if (match) {
    return { title: match[1], body: match[2] };
  }
  return { title: fallbackTitle, body: text };
}

function stemFromId(id) {
  const match = id.match(/^PDV_(?:Bless|Price|Msg|Notif)_Daedric_([^_]+)_/);
  if (!match) return null;
  return match[1];
}

function matrixFor(rows, meta) {
  return rows.find((row) => meta.aliases.includes(row.Prince));
}

function stateName(cell) {
  const first = String(cell || "").split(";")[0].trim();
  return Object.hasOwn(STATE_VALUE, first) ? first : "Foreign";
}

function stateArrays(row) {
  const byMatrixRace = Object.fromEntries(RACE_ORDER_MATRIX.map((race) => [race, stateName(row[race])]));
  return {
    stateByRace: RACE_ORDER_PDV.map((race) => STATE_VALUE[byMatrixRace[race]]),
    stigmaModByRace: RACE_ORDER_PDV.map((race) => STIGMA_MOD[byMatrixRace[race]]),
    exitDifficultyByRace: RACE_ORDER_PDV.map((race) => EXIT_DIFFICULTY[byMatrixRace[race]]),
    statesByRace: Object.fromEntries(RACE_ORDER_PDV.map((race) => [race, byMatrixRace[race]])),
  };
}

// Effect axes, magnitude bands, and exceptional multi-effect packets live behind the
// effect-model module's small buildPrinceSpellPackets interface.
function buildPrince(stem, rows, matrixRows) {
  const meta = PRINCE_META[stem];
  if (!meta) throw new Error(`Missing PRINCE_META for ${stem}`);
  const matrixRow = matrixFor(matrixRows, meta);
  if (!matrixRow) throw new Error(`Missing matrix row for ${stem}`);
  const arrays = stateArrays(matrixRow);
  const princeRows = rows.filter((r) => stemFromId(r.id) === stem);
  const byId = new Map(princeRows.map((r) => [r.id, r.finalText]));
  const boonIds = ["Seeker", "Devoted", "Champion"].map((tier) => `PDV_Bless_Daedric_${stem}_${tier}`);
  const priceIds = ["Seeker", "Devoted", "Champion"].map((tier) => `PDV_Price_Daedric_${stem}_${tier}`);
  const messageIds = princeRows
    .map((r) => r.id)
    .filter((id) => id.startsWith(`PDV_Msg_Daedric_${stem}_`) || id.startsWith(`PDV_Notif_Daedric_${stem}_`));
  const messages = messageIds.map((id) => {
    const parts = messageParts(byId.get(id) ?? "", meta.displayName);
    return {
      editorId: id,
      title: parts.title,
      body: parts.body,
      property: id.replace(`PDV_Msg_Daedric_${stem}_`, "Msg_").replace(`PDV_Notif_Daedric_${stem}_`, "Notif_"),
      messageBox: id.startsWith("PDV_Msg_"),
    };
  });
  const missing = [...boonIds, ...priceIds].filter((id) => !byId.has(id));
  if (missing.length) throw new Error(`${stem} missing required spell rows: ${missing.join(", ")}`);
  const spellPackets = buildPrinceSpellPackets({
    stem,
    displayName: meta.displayName,
    finalTextById: byId,
  });
  return {
    stem,
    displayName: meta.displayName,
    batch: meta.batch,
    questEditorId: `PDV_DaedricPath_${stem}`,
    scriptName: `PDV_DaedricPath_${stem}`,
    existingScript: Boolean(meta.existingScript),
    stigmaGlobalEditorId: `PDV_GLO_Daedric_${stem}_Stigma`,
    commitmentSignalsRequired: 3,
    stigmaClass: meta.stigmaClass,
    hookSource: matrixRow.VanillaHookPriority,
    temptationPressure: matrixRow.TemptationPressure,
    commitmentSignal: matrixRow.CommitmentSignal,
    ...arrays,
    boons: spellPackets.boons,
    prices: spellPackets.prices,
    messages,
  };
}

function scriptText(prince) {
  if (prince.existingScript) return null;
  const storagePrefix = `PDV.Daedric.${prince.stem}`;
  return `;/\n    ${prince.scriptName}.psc\n    PlayerDevotion - ${prince.displayName} Daedric path\n    Generated from PDV_DaedricPrinceRecordContracts.json.\n/;\n\nScriptname ${prince.scriptName} extends PDV_DaedricPathBase\n\nFloat Property ControlledSignalPietyDelta = 12.0 Auto\nFloat Property ControlledSignalStigmaDelta = 1.0 Auto\n\nMessage Property Msg_Commitment Auto\nMessage Property Msg_ChampionEntry Auto\nMessage Property Msg_Exit Auto\nMessage Property Notif_SeekerEntry Auto\nMessage Property Notif_DevotedEntry Auto\nMessage Property Notif_Lapse Auto\nMessage Property Notif_Stigma_Suspected Auto\nMessage Property Notif_Stigma_Known Auto\nMessage Property Notif_Stigma_Notorious Auto\nMessage Property Notif_NeglectTexture Auto\nMessage Property Msg_Response_Nord Auto\nMessage Property Msg_Response_Imperial Auto\nMessage Property Msg_Response_Breton Auto\nMessage Property Msg_Response_Altmer Auto\nMessage Property Msg_Response_Bosmer Auto\nMessage Property Msg_Response_Dunmer Auto\nMessage Property Msg_Response_Khajiit Auto\nMessage Property Msg_Response_Argonian Auto\nMessage Property Msg_Response_Orc Auto\nMessage Property Msg_Response_Redguard Auto\n\nFunction RecordControlledSignal(String reason)\n    AddCommitmentSignal(\"controlled_\" + reason)\n    AddStigma(ControlledSignalStigmaDelta, \"controlled_\" + reason)\n\n    if HasCommitmentSignalGateOpen()\n        AdjustStoredPiety(ControlledSignalPietyDelta, \"controlled_\" + reason)\n    endIf\n\n    TraceControlled(1, \"Controlled signal recorded: \" + GetControlledSummary())\nEndFunction\n\nFunction DebugRunControlledProof(Int targetTier)\n    ResetDaedricForDebug()\n    AddCommitmentSignal(\"debug_one\")\n    AddCommitmentSignal(\"debug_two\")\n    AddCommitmentSignal(\"debug_three\")\n\n    if targetTier >= TIER_CHAMPION\n        SetStoredPiety(ThresholdChampion, \"debug_controlled_proof\")\n    elseIf targetTier >= TIER_DEVOTED\n        SetStoredPiety(ThresholdDevoted, \"debug_controlled_proof\")\n    else\n        SetStoredPiety(ThresholdSeeker, \"debug_controlled_proof\")\n    endIf\n\n    AddStigma(ControlledSignalStigmaDelta, \"debug_controlled_proof\")\n    ShowControlledProofMessages()\n    TraceControlled(1, \"DebugRunControlledProof: \" + GetControlledSummary())\nEndFunction\n\nFunction DebugRunLiveSenderProof(String hookId)\n    RecordControlledSignal(\"live_\" + hookId)\n    StorageUtil.SetStringValue(GetDeityForm(), \"${storagePrefix}.LastLiveHook\", hookId)\n    TraceControlled(1, \"Live sender proof recorded for \" + hookId)\nEndFunction\n\nFunction DebugRenouncePath()\n    ResetDaedricForDebug()\n    SetStoredPiety(0.0, \"debug_renounce\")\n    StorageUtil.SetIntValue(GetDeityForm(), \"${storagePrefix}.Renounced\", 1)\n    if Msg_Exit\n        Msg_Exit.Show()\n    endIf\n    TraceControlled(1, \"DebugRenouncePath\")\nEndFunction\n\nFunction ShowControlledProofMessages()\n    ShowIfPresent(Notif_SeekerEntry)\n    ShowIfPresent(Notif_DevotedEntry)\n    ShowIfPresent(Msg_Commitment)\n    ShowIfPresent(Msg_ChampionEntry)\n    ShowIfPresent(Notif_Stigma_Suspected)\n    ShowIfPresent(Notif_Stigma_Known)\n    ShowIfPresent(Notif_Stigma_Notorious)\n    ShowIfPresent(Notif_NeglectTexture)\n    ShowRaceResponseForPlayer()\nEndFunction\n\nFunction ShowTierEntryMessage(Int oldTier, Int newTier)\n    if newTier <= oldTier\n        return\n    endIf\n    if newTier == TIER_CHAMPION\n        ShowIfPresent(Msg_ChampionEntry)\n    elseIf newTier == TIER_DEVOTED\n        ShowIfPresent(Notif_DevotedEntry)\n    elseIf newTier == TIER_SEEKER\n        ShowIfPresent(Notif_SeekerEntry)\n    endIf\nEndFunction\n\nFunction ShowCommitmentBeat()\n    ShowIfPresent(Msg_Commitment)\nEndFunction\n\nFunction ShowRaceResponseForPlayer()\n    Int originRace = GetPlayerOriginRace()\n    if originRace == RACE_NORD\n        ShowIfPresent(Msg_Response_Nord)\n    elseIf originRace == RACE_IMPERIAL\n        ShowIfPresent(Msg_Response_Imperial)\n    elseIf originRace == RACE_BRETON\n        ShowIfPresent(Msg_Response_Breton)\n    elseIf originRace == RACE_ALTMER\n        ShowIfPresent(Msg_Response_Altmer)\n    elseIf originRace == RACE_BOSMER\n        ShowIfPresent(Msg_Response_Bosmer)\n    elseIf originRace == RACE_DUNMER\n        ShowIfPresent(Msg_Response_Dunmer)\n    elseIf originRace == RACE_KHAJIIT\n        ShowIfPresent(Msg_Response_Khajiit)\n    elseIf originRace == RACE_ARGONIAN\n        ShowIfPresent(Msg_Response_Argonian)\n    elseIf originRace == RACE_ORSIMER\n        ShowIfPresent(Msg_Response_Orc)\n    elseIf originRace == RACE_REDGUARD\n        ShowIfPresent(Msg_Response_Redguard)\n    endIf\nEndFunction\n\nFunction ShowIfPresent(Message messageRecord)\n    if messageRecord\n        messageRecord.Show()\n    endIf\nEndFunction\n\nString Function GetControlledSummary()\n    return GetContractSummary() + \"; \" + GetDaedricSpellSummary() + \"; exit=\" + GetExitDifficultyForPlayer()\nEndFunction\n\nFunction TraceControlled(Int level, String traceText)\n    if GetDebugLevel() >= level\n        Debug.Trace(\"[PDV] ${prince.stem}Path: \" + traceText)\n    endIf\nEndFunction\n`;
}

function main() {
  const manifest = fs.readFileSync(MANIFEST, "utf8");
  const matrixRows = csvRows(fs.readFileSync(MATRIX, "utf8"));
  const boethiah = sectionFor(manifest, /^## 6\. Boethiah/m, /^## 7\./m);
  const chapter7 = sectionFor(manifest, /^## 7\./m, /^## 8\./m);
  const rows = [...tableRows(boethiah), ...tableRows(chapter7)];
  const stems = ["Boethiah", "Azura", "Vaermina", "Meridia", "Molag", "Mephala", "Malacath", "Dagon", "Sheo", "Namira", "Sanguine", "Vile", "Mora", "Nocturnal", "Peryite", "Hircine"];
  const modelIssues = validateDaedricEffectModel(stems);
  if (modelIssues.length) {
    console.error(JSON.stringify({ status: "FAIL", check: "effect-model", issues: modelIssues }, null, 2));
    process.exit(1);
  }
  const princes = stems.map((stem) => buildPrince(stem, rows, matrixRows));
  const contract = {
    schema: "pdv.daedric-prince-record-contracts.v1",
    generatedFrom: [
      "race-sheets/PDV_DaedricContent_Manifest.md",
      "references/phase4/PDV_DaedricRacePrinceMatrix.csv",
    ],
    generatedAtLocal: new Date().toLocaleString("en-AU", { timeZone: "Australia/Sydney", hour12: false }),
    sourceOfTruth: "Manifest row EditorIDs and text win over work-order shorthand.",
    priceSerialization: {
      magicEffectFlags: [
        "Recover",
        "Detrimental",
        "NoDuration",
        "NoArea",
        "PowerAffectsMagnitude",
        "NoHitEffect",
      ],
      storedSpellMagnitude: "Positive absolute value of the semantic negative magnitude; Detrimental supplies the negative gameplay delta.",
    },
    operationalFormList: "PDV_FLST_DaedricPaths_All",
    devFormList: "PDV_FLST_DaedricPaths_DevOnly",
    princeCount: princes.length,
    princes,
  };
  // `generatedAtLocal` is a timestamp and moves on every run, so it is excluded from the
  // comparison. Including it would make every run report drift and the refusal below
  // would degrade into noise that everyone learns to pass --force through.
  const comparable = (c) => {
    const { generatedAtLocal, ...rest } = c;
    return JSON.stringify(rest, null, 2);
  };
  const existing = fs.existsSync(OUT) ? JSON.parse(fs.readFileSync(OUT, "utf8")) : null;
  const drift = existing ? comparable(existing) !== comparable(contract) : false;

  const driftedPrinces = [];
  if (existing) {
    const byStem = new Map((existing.princes ?? []).map((p) => [p.stem, JSON.stringify(p)]));
    for (const p of princes) {
      const before = byStem.get(p.stem);
      if (before === undefined) driftedPrinces.push(`${p.stem} (absent from the curated file)`);
      else if (before !== JSON.stringify(p)) driftedPrinces.push(p.stem);
    }
  }

  const report = {
    contract: OUT,
    princes: princes.length,
    curatedFileExists: Boolean(existing),
    wouldChangeCuratedContract: drift,
    driftedPrinces,
  };

  let contractWritten = false;
  if (WRITE_CONTRACT) {
    if (drift && !FORCE) {
      console.error(JSON.stringify({
        status: "REFUSED",
        reason:
          "Regenerating would change the reviewed record contract. Inspect the generated diff and " +
          "its effect-model source before using --force to accept a deliberate contract change.",
        ...report,
      }, null, 2));
      process.exit(1);
    }
    fs.writeFileSync(OUT, `${JSON.stringify(contract, null, 2)}\n`);
    contractWritten = true;
  }

  let scriptsWritten = 0;
  if (SCAFFOLD) {
    if (!SOURCE_DIR) {
      console.error("--scaffold-scripts requires --source-dir <path to Scripts/Source>. There is no default: the old hardcoded path wrote into one machine's live build.");
      process.exit(2);
    }
    if (!fs.existsSync(SOURCE_DIR)) {
      console.error(`--source-dir does not exist: ${SOURCE_DIR}`);
      process.exit(2);
    }
    for (const prince of princes) {
      const text = scriptText(prince);
      if (!text) continue;
      fs.writeFileSync(path.join(SOURCE_DIR, `${prince.scriptName}.psc`), text);
      scriptsWritten += 1;
    }
  }

  console.log(JSON.stringify({
    status: "PASS",
    mode: SELF_TEST
      ? "self-test (no files written)"
      : (!WRITE_CONTRACT && !SCAFFOLD ? "report-only (no files written)" : "write"),
    effectModel: "PASS",
    ...report,
    contractWritten,
    scriptsWritten,
    scriptTarget: SCAFFOLD ? SOURCE_DIR : null,
  }, null, 2));
}

main();
