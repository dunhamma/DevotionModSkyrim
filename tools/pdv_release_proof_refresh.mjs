#!/usr/bin/env node
// Re-derive and gate the release-proof snapshot against the live Anvil profile.
//
// authorityA: live Devotion.esp plus direct houseCARL readback and the live
//             Devotion source/asset providers.
// authorityB: references/authoring/PDV_HousecarlReleaseProof.json.
// runtimeWinner: the active load-order winner and live loose-file provider.
// allowedFallback: none for a release build.
// proofClass: verification for live comparisons; explicit manual confirmation
//             for critical-target scope, CELL retention, and open boundaries.
// driftClass: stale-generated / fallback-disagrees-with-winner / backend-unavailable.
// skipRule: none. An unavailable houseCARL backend is a release-proof failure.

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { assertKnownFlags, makeFlagReader } from "./lib/pdv_cli.mjs";
import { hashBytes, writeTextWithEol } from "./lib/pdv_file_compare.mjs";
import { extractHousecarlText, openHousecarl, resolveHousecarlExe } from "./lib/pdv_housecarl_stdio.mjs";

const KNOWN_FLAGS = new Set([
  "--check",
  "--capture",
  "--refresh",
  "--json",
  "--self-test",
  "--note",
  "--confirm-critical-scope",
  "--confirm-cell-retention",
  "--confirm-open-boundary",
  "--accept-contested-changes",
  "--accept-critical-winner-changes",
]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_release_proof_refresh" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PROOF_PATH = path.join(ROOT, "references", "authoring", "PDV_HousecarlReleaseProof.json");
const RUNBOOK_PATH = path.join(ROOT, "references", "authoring", "PDV_ReleaseProofRefresh_Runbook.md");
const CANDIDATE_PATH = path.join(ROOT, "generated", "PDV_HousecarlReleaseProof.candidate.json");
const MOD_ROOT = process.env.PDV_MOD_PATH || "D:/Wabbajack/modlists/Anvil/mods/Devotion";
const ESP_PATH = path.join(MOD_ROOT, "Devotion.esp");
const SOURCE_DIR = path.join(MOD_ROOT, "Scripts", "Source");
const PEX_DIR = path.join(MOD_ROOT, "Scripts");
const PLUGIN = "Devotion.esp";
const EXPECTED_PROFILE = "Devotion Dev";
const EXPECTED_INSTANCE = path.resolve("D:/Wabbajack/modlists/Anvil");
const TIMEOUT_MS = 240_000;
const AS_JSON = process.argv.includes("--json");
const FLAGS = makeFlagReader(process.argv.slice(2));

function die(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

function sha256Text(value) {
  return crypto.createHash("sha256").update(value, "utf8").digest("hex").toUpperCase();
}

function parseJson(text, label) {
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`${label} did not return JSON. Response head:\n${text.slice(0, 400)}`);
  }
}

function groupsToObject(doc) {
  return Object.fromEntries((doc.groups ?? []).map((entry) => [entry.key, entry.count]));
}

function sortedObject(value) {
  if (Array.isArray(value)) return value.map(sortedObject);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(Object.keys(value).sort().map((key) => [key, sortedObject(value[key])]));
}

function exactFingerprint(records) {
  const lines = records
    .map((record) => `${record.formid}|${record.type}|${record.editorid}|${record.winner}`)
    .sort()
    .join("\n");
  return sha256Text(`${lines}\n`);
}

function parseStatus(text) {
  const profile = text.match(/profile '([^']+)'/)?.[1] ?? null;
  const instance = text.match(/^instance:\s*(.+)$/m)?.[1]?.trim() ?? null;
  const active = /as a plugin:\s*ACTIVE/.test(text);
  return { profile, instance, active };
}

function parseErrors(text) {
  return {
    danglingLinks: Number(text.match(/(\d+) dangling ref\(s\)/)?.[1] ?? -1),
    missingMasters: Number(text.match(/(\d+) missing master\(s\)/)?.[1] ?? -1),
    parseFailures: Number(text.match(/(\d+) unscannable record\(s\)/)?.[1] ?? -1),
  };
}

function fieldNoteCount(record, fieldPath) {
  const note = (record.fields ?? []).find((field) => field.path === fieldPath && field.note)?.note ?? "";
  return Number(note.match(/\[list:\s*(\d+) item\(s\)\]/)?.[1] ?? 0);
}

function fieldScriptName(record, fieldPath) {
  const note = (record.fields ?? []).find((field) => field.path === fieldPath && field.note)?.note ?? "";
  return note.match(/Name=([^\]]+)/)?.[1] ?? null;
}

function listScriptPairs() {
  const names = (dir, extension) => new Set(
    fs.readdirSync(dir)
      .filter((name) => name.toLowerCase().endsWith(extension))
      .map((name) => path.basename(name, extension).toLowerCase()),
  );
  const psc = names(SOURCE_DIR, ".psc");
  const pex = names(PEX_DIR, ".pex");
  const onlyPsc = [...psc].filter((name) => !pex.has(name)).sort();
  const onlyPex = [...pex].filter((name) => !psc.has(name)).sort();
  return {
    psc: psc.size,
    pex: pex.size,
    pairNamesExact: onlyPsc.length === 0 && onlyPex.length === 0,
    onlyPsc,
    onlyPex,
  };
}

function assetGroupsFromProof(proof) {
  return Object.entries(proof.assetWinners ?? {})
    .filter(([, value]) => value && Array.isArray(value.paths))
    .map(([key, value]) => ({ key, paths: value.paths }));
}

function parseAssetStatuses(text, paths) {
  const statuses = {};
  for (const assetPath of paths) {
    const start = text.indexOf(assetPath);
    if (start < 0) throw new Error(`housecarl_asset_status omitted ${assetPath}`);
    const next = text.indexOf("\n\n", start);
    const block = text.slice(start, next < 0 ? undefined : next);
    const winner = block.match(/WINS:\s*([^\r\n]+?)(?:\s+\((?:loose|archive[^)]*)\))?\s*$/m)?.[1]?.trim() ?? null;
    const providerCount = Number(block.match(/providers \((\d+)\):/)?.[1] ?? -1);
    const providerLine = block.match(/providers \(\d+\):\s*([^\r\n]+)/)?.[1]?.trim() ?? "";
    const soleProvider = providerCount === 1
      ? providerLine.replace(/\s+\((?:loose|archive[^)]*)\)\s*$/, "").trim()
      : null;
    statuses[assetPath] = { winner, providerCount, soleProvider };
  }
  return statuses;
}

function runVmadAudit() {
  const result = spawnSync(process.execPath, [path.join(ROOT, "tools", "pdv_vmad_audit.mjs"), "--json"], {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: 32 * 1024 * 1024,
    timeout: TIMEOUT_MS,
  });
  if (result.error) throw result.error;
  let report = null;
  try {
    report = JSON.parse(result.stdout);
  } catch {
    throw new Error(`pdv_vmad_audit did not return JSON (exit ${result.status}).\n${result.stdout.slice(0, 400)}\n${result.stderr.slice(0, 400)}`);
  }
  return { exitCode: result.status ?? 1, report };
}

async function collectLive(template, { cellRetentionConfirmed = false } = {}) {
  if (!fs.existsSync(ESP_PATH)) throw new Error(`live ESP not found: ${ESP_PATH}`);
  resolveHousecarlExe();

  const stat = fs.statSync(ESP_PATH);
  const session = openHousecarl({ timeoutMs: TIMEOUT_MS });
  let status;
  let rawFile;
  let defined;
  let conflictsGrouped;
  let conflicts;
  let errors;
  let vmadGrouped;
  let placedGrouped;
  let criticalRecordWinners;
  let assetText = "";
  const assetGroups = assetGroupsFromProof(template);
  const assetPaths = assetGroups.flatMap((group) => group.paths);

  const callText = async (tool, args) => extractHousecarlText(await session.call(tool, args, { timeoutMs: TIMEOUT_MS }));
  const callJson = async (tool, args) => parseJson(await callText(tool, { ...args, format: "json" }), tool);

  try {
    status = parseStatus(await callText("housecarl_load_order_status", { lookup: PLUGIN }));
    rawFile = await callJson("housecarl_read_plugin_file", {
      plugin: ESP_PATH,
      depth: 1,
      limit: 5,
      max_chars: 100_000,
    });
    defined = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], defined_in: true, group_by: "type", limit: 5000, max_chars: 1_000_000,
    });
    conflictsGrouped = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], conflicts_only: true, group_by: "type", limit: 5000, max_chars: 1_000_000,
    });
    conflicts = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], conflicts_only: true, fields: ["EditorID"], limit: 5000, max_chars: 1_000_000,
    });
    errors = parseErrors(await callText("housecarl_check_errors", {
      plugins: [PLUGIN], limit: 5000, max_chars: 1_000_000,
    }));
    vmadGrouped = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], defined_in: true, where: ["VirtualMachineAdapter exists"], group_by: "type", limit: 5000, max_chars: 1_000_000,
    });
    placedGrouped = await callJson("housecarl_cross_plugin_query", {
      plugins: [PLUGIN], defined_in: true, type: "REFR", group_by: "winner", limit: 5000, max_chars: 1_000_000,
    });

    criticalRecordWinners = [];
    for (const target of template.criticalRecordWinners ?? []) {
      const isManager = target.formid === "00C325:Devotion.esp" || target.editorid === "PDV__ManagerQuest";
      const record = await callJson("housecarl_read_record", {
        formid: target.formid,
        fields: isManager
          ? ["EditorID", "VirtualMachineAdapter.Scripts", "VirtualMachineAdapter.Aliases"]
          : ["EditorID"],
        depth: isManager ? 2 : 1,
        max_chars: 30_000,
      });
      const current = {
        formid: target.formid,
        editorid: record.editorid ?? null,
        winner: record.winner ?? null,
      };
      if (isManager) {
        const propertyShape = await callJson("housecarl_read_record", {
          formid: target.formid,
          fields: ["VirtualMachineAdapter.Scripts[0].Properties"],
          depth: 1,
          max_chars: 30_000,
        });
        current.vmadScripts = fieldNoteCount(record, "VirtualMachineAdapter.Scripts");
        current.vmadScriptName = fieldScriptName(record, "VirtualMachineAdapter.Scripts[0]");
        current.vmadProperties = fieldNoteCount(propertyShape, "VirtualMachineAdapter.Scripts[0].Properties");
        current.vmadAliases = fieldNoteCount(record, "VirtualMachineAdapter.Aliases");
      }
      criticalRecordWinners.push(current);
    }

    if (assetPaths.length) {
      assetText = await callText("housecarl_asset_status", { asset_paths: assetPaths, max_chars: 200_000 });
    }
  } finally {
    session.close();
  }

  if (status.profile !== EXPECTED_PROFILE || !status.active || path.resolve(status.instance ?? "") !== EXPECTED_INSTANCE) {
    throw new Error(`wrong houseCARL context: instance=${status.instance ?? "missing"}, profile=${status.profile ?? "missing"}, active=${status.active}`);
  }
  for (const doc of [rawFile, defined, conflictsGrouped, conflicts, vmadGrouped, placedGrouped]) {
    if (doc.truncated || doc.capped) throw new Error("houseCARL returned a truncated/capped release-proof enumeration");
  }

  const definedTypes = groupsToObject(defined);
  const rawTypes = Object.fromEntries((rawFile.type_counts ?? []).map((entry) => [entry.type, entry.count]));
  const conflictTypes = groupsToObject(conflictsGrouped);
  const vmadTypes = groupsToObject(vmadGrouped);
  const placedWinners = groupsToObject(placedGrouped);
  const contestedRecords = (conflicts.matches ?? [])
    .map((record) => ({
      formid: record.formid,
      type: record.type,
      editorid: record.editorid ?? "",
      winner: record.winner ?? "",
    }))
    .sort((a, b) => a.formid.localeCompare(b.formid));
  const assetStatuses = parseAssetStatuses(assetText, assetPaths);
  const assetWinners = {
    note: "Re-derived by pdv_release_proof_refresh via housecarl_asset_status against Devotion Dev.",
  };
  for (const group of assetGroups) {
    const statuses = group.paths.map((assetPath) => assetStatuses[assetPath]);
    const winners = new Set(statuses.map((entry) => entry.winner));
    const soleProviders = new Set(statuses.map((entry) => entry.soleProvider));
    assetWinners[group.key] = {
      queried: group.paths.length,
      paths: group.paths,
      soleProvider: soleProviders.size === 1 ? [...soleProviders][0] : null,
      winner: winners.size === 1 ? [...winners][0] : null,
    };
  }

  const vmad = runVmadAudit();
  const scriptPairs = listScriptPairs();
  const now = new Date().toISOString();
  const openBoundary = Array.isArray(template.proofBoundary?.open)
    ? template.proofBoundary.open
    : ["manual UI behavior", "navmesh and terrain spatial integrity", "runtime behavior"];

  return {
    schemaVersion: 2,
    generatedAt: now,
    postChangeVerifiedAt: now,
    profile: status.profile,
    plugin: PLUGIN,
    active: status.active,
    espSha256: hashBytes(ESP_PATH).toUpperCase(),
    espSizeBytes: stat.size,
    espModifiedUtc: stat.mtime.toISOString(),
    refreshNote: template.refreshNote ?? "REVIEW REQUIRED",
    masters: rawFile.masters ?? [],
    recordSummary: {
      frame: "definedIn",
      frameNote: "Records Devotion.esp defines, re-derived by housecarl_cross_plugin_query with defined_in=true and group_by=type.",
      total: defined.total,
      types: Object.keys(definedTypes).length,
      typeCounts: definedTypes,
      quests: definedTypes.Quest ?? 0,
      magicEffects: definedTypes.MagicEffect ?? 0,
      spells: definedTypes.Spell ?? 0,
      messages: definedTypes.Message ?? 0,
      placedObjects: definedTypes.PlacedObject ?? 0,
      cellsTouched: rawTypes.Cell ?? 0,
    },
    fileRecordSummary: {
      frame: "rawFile",
      frameNote: "Every record the file contains, definitions plus overrides, re-derived by housecarl_read_plugin_file on the absolute ESP path.",
      total: rawFile.total,
      types: Object.keys(rawTypes).length,
      typeCounts: rawTypes,
    },
    errors,
    contestedRecordCount: conflictsGrouped.total,
    contestedRecordBreakdown: {
      note: "Re-derived live by housecarl_cross_plugin_query with conflicts_only=true; exact membership is gated by contestedRecordSet.sha256.",
      ...conflictTypes,
    },
    contestedRecordSet: {
      algorithm: "SHA-256 of sorted formid|type|editorid|winner lines",
      count: contestedRecords.length,
      sha256: exactFingerprint(contestedRecords),
      records: contestedRecords,
    },
    criticalRecordWinners,
    cellNestedReferenceRetention: {
      verified: cellRetentionConfirmed,
      details: template.cellNestedReferenceRetention?.details ?? [],
      placedObjectsEnumerated: placedGrouped.total,
      placedObjectsWinningFromDevotion: placedWinners[PLUGIN] ?? 0,
    },
    vmadValidation: {
      scriptedRecords: vmad.report.enumeratedRecords,
      scriptedRecordsByType: vmadTypes,
      scriptAttachments: vmad.report.analysedScriptAttachments,
      aliasAttachments: criticalRecordWinners.find((entry) => entry.editorid === "PDV__ManagerQuest")?.vmadAliases ?? 0,
      sourceFileCount: vmad.report.sourceFileCount,
      scriptClasses: vmad.report.scriptClasses,
      auditTool: "tools/pdv_vmad_audit.mjs",
      auditExitCode: vmad.exitCode,
      auditFindingsUnwaived: vmad.report.counts?.confirmed ?? -1,
      boundary: "The gate input is the current audit exit code and unwaived finding count; waived hypotheses and manual intent review remain outside this snapshot.",
    },
    filesystemScriptPairs: scriptPairs,
    assetWinners,
    proofBoundary: {
      closed: [
        "active load-order presence",
        "live ESP byte identity",
        "FormLink integrity",
        "master presence",
        "record parsing",
        "exact contested-record membership",
        "critical record winners",
        "placed-reference winner retention",
        "VMAD audit verdict",
        "claimed loose-asset provider resolution",
      ],
      open: openBoundary,
    },
    refreshProcedure: {
      tool: "tools/pdv_release_proof_refresh.mjs",
      runbook: "references/authoring/PDV_ReleaseProofRefresh_Runbook.md",
      check: "node tools/pdv_release_proof_refresh.mjs --check",
      capture: "node tools/pdv_release_proof_refresh.mjs --capture",
      refresh: "Use --refresh with --note and all three --confirm-* flags after reviewing the candidate; accept changed contested membership or critical winners only with the matching --accept-* flag.",
      packageGate: "pdv_package_release.mjs runs --check and fails when houseCARL is unavailable or the committed proof is stale.",
    },
  };
}

function gateProjection(proof) {
  return sortedObject({
    schemaVersion: proof.schemaVersion,
    profile: proof.profile,
    plugin: proof.plugin,
    active: proof.active,
    espSha256: proof.espSha256,
    espSizeBytes: proof.espSizeBytes,
    masters: proof.masters,
    recordSummary: proof.recordSummary,
    fileRecordSummary: proof.fileRecordSummary,
    errors: proof.errors,
    contestedRecordCount: proof.contestedRecordCount,
    contestedRecordBreakdown: proof.contestedRecordBreakdown,
    contestedRecordSet: proof.contestedRecordSet,
    criticalRecordWinners: proof.criticalRecordWinners,
    cellNestedReferenceRetention: proof.cellNestedReferenceRetention,
    vmadValidation: proof.vmadValidation,
    filesystemScriptPairs: proof.filesystemScriptPairs,
    assetWinners: proof.assetWinners,
  });
}

function diffValues(expected, actual, prefix = "") {
  if (Object.is(expected, actual)) return [];
  if (Array.isArray(expected) || Array.isArray(actual)) {
    return JSON.stringify(expected) === JSON.stringify(actual)
      ? []
      : [`${prefix || "value"}: committed=${JSON.stringify(expected)} live=${JSON.stringify(actual)}`];
  }
  if (expected && actual && typeof expected === "object" && typeof actual === "object") {
    const keys = new Set([...Object.keys(expected), ...Object.keys(actual)]);
    return [...keys].flatMap((key) => diffValues(expected[key], actual[key], prefix ? `${prefix}.${key}` : key));
  }
  return [`${prefix || "value"}: committed=${JSON.stringify(expected)} live=${JSON.stringify(actual)}`];
}

function boundaryFailures(proof) {
  const failures = [];
  const open = proof.proofBoundary?.open ?? [];
  if (!open.some((entry) => /runtime/i.test(entry))) failures.push("proofBoundary.open must retain a runtime boundary");
  if (!open.some((entry) => /manual|UI/i.test(entry))) failures.push("proofBoundary.open must retain a manual/UI boundary");
  if (!proof.refreshNote || /REVIEW REQUIRED/i.test(proof.refreshNote)) failures.push("refreshNote must describe the change that triggered the refresh");
  if (proof.cellNestedReferenceRetention?.verified !== true) failures.push("CELL nested-reference retention requires explicit manual confirmation");
  if (proof.vmadValidation?.auditExitCode !== 0 || proof.vmadValidation?.auditFindingsUnwaived !== 0) failures.push("VMAD audit must be clean");
  if (proof.filesystemScriptPairs?.pairNamesExact !== true) failures.push("PSC/PEX script names must pair exactly");
  for (const [key, group] of Object.entries(proof.assetWinners ?? {})) {
    if (!group || !Array.isArray(group.paths)) continue;
    if (group.winner !== "Devotion" || group.soleProvider !== "Devotion") failures.push(`assetWinners.${key} is not won solely by Devotion`);
  }
  return failures;
}

function sameCriticalWinners(a = [], b = []) {
  const project = (rows) => rows.map((row) => ({ formid: row.formid, editorid: row.editorid, winner: row.winner }));
  return JSON.stringify(project(a)) === JSON.stringify(project(b));
}

function runSelfTest() {
  const recordA = [{ formid: "000001:A.esm", type: "Quest", editorid: "A", winner: "Patch.esp" }];
  const recordB = [{ formid: "000002:A.esm", type: "Quest", editorid: "B", winner: "Patch.esp" }];
  if (exactFingerprint(recordA) === exactFingerprint(recordB)) throw new Error("exact contested-set fingerprint missed same-count membership drift");
  const baseline = { hash: "A", nested: { count: 1 } };
  if (diffValues(baseline, structuredClone(baseline)).length) throw new Error("equal projections reported drift");
  const changed = structuredClone(baseline);
  changed.nested.count = 2;
  if (!diffValues(baseline, changed).some((entry) => entry.startsWith("nested.count:"))) throw new Error("nested drift was not reported precisely");
  console.log("pdv_release_proof_refresh self-test: PASS (exact-set and nested-drift fixtures detected).");
}

async function main() {
  if (process.argv.includes("--self-test")) {
    runSelfTest();
    return;
  }
  const modes = ["--check", "--capture", "--refresh"].filter((flag) => process.argv.includes(flag));
  if (modes.length > 1) die(`choose one mode, got ${modes.join(", ")}`);
  const mode = modes[0] ?? "--check";
  if (!fs.existsSync(PROOF_PATH)) die(`committed proof missing: ${PROOF_PATH}`);
  const proof = JSON.parse(fs.readFileSync(PROOF_PATH, "utf8"));
  let refreshNote = null;
  if (mode === "--refresh") {
    refreshNote = FLAGS.value("--note");
    for (const flag of ["--confirm-critical-scope", "--confirm-cell-retention", "--confirm-open-boundary"]) {
      if (!process.argv.includes(flag)) die(`--refresh requires ${flag}`);
    }
    if (!refreshNote || refreshNote.trim().length < 20) die("--refresh requires a specific --note of at least 20 characters");
  }
  const cellConfirmed = mode === "--check" || process.argv.includes("--confirm-cell-retention");
  const live = await collectLive(proof, { cellRetentionConfirmed: cellConfirmed });

  if (mode === "--capture") {
    live.refreshNote = "REVIEW REQUIRED: describe the live ESP or load-order change that triggered this refresh.";
    live.candidateReview = {
      status: "REVIEW_REQUIRED",
      compareAgainst: path.relative(ROOT, PROOF_PATH).replaceAll("\\", "/"),
      required: [
        "Review exact contested-record membership and winner changes, not only the count.",
        "Confirm the critical-record target list is still sufficient for current release claims.",
        "Confirm CELL nested-reference retention and the placed-reference winner result.",
        "Confirm proofBoundary.open still names every unproven runtime/manual surface.",
        "Supply a specific refresh note before promotion.",
      ],
    };
    fs.mkdirSync(path.dirname(CANDIDATE_PATH), { recursive: true });
    writeTextWithEol(CANDIDATE_PATH, `${JSON.stringify(live, null, 2)}\n`, "lf");
    console.log(`Release-proof candidate written: ${CANDIDATE_PATH}`);
    console.log("Candidate is regenerable and not package authority; review it before --refresh.");
    return;
  }

  if (mode === "--refresh") {
    const previousSet = proof.contestedRecordSet?.sha256 ?? null;
    if (previousSet !== live.contestedRecordSet.sha256 && !process.argv.includes("--accept-contested-changes")) {
      die("the exact contested-record set changed (or has no prior fingerprint); review the candidate and pass --accept-contested-changes only if intentional");
    }
    if (!sameCriticalWinners(proof.criticalRecordWinners, live.criticalRecordWinners) && !process.argv.includes("--accept-critical-winner-changes")) {
      die("one or more critical record winners changed; review the candidate and pass --accept-critical-winner-changes only if intentional");
    }
    live.refreshNote = refreshNote.trim();
    const unsafe = boundaryFailures(live);
    if (unsafe.length) die(`refusing to refresh an unsafe proof:\n- ${unsafe.join("\n- ")}`);
    writeTextWithEol(PROOF_PATH, `${JSON.stringify(live, null, 2)}\n`, "lf");
    console.log(`Refreshed ${PROOF_PATH}`);
    console.log(`  ESP SHA-256: ${live.espSha256}`);
    console.log(`  contested : ${live.contestedRecordSet.count} exact records (${live.contestedRecordSet.sha256})`);
    return;
  }

  const differences = diffValues(gateProjection(proof), gateProjection(live));
  const boundary = boundaryFailures(proof);
  const notes = [];
  if (proof.espModifiedUtc !== live.espModifiedUtc) {
    notes.push(`ESP mtime differs but is informative only (committed ${proof.espModifiedUtc}, live ${live.espModifiedUtc}); byte hash decides freshness.`);
  }
  const result = {
    status: differences.length || boundary.length ? "FAIL" : "PASS",
    proofClass: "live verification plus committed manual boundary confirmations",
    profile: live.profile,
    espSha256: live.espSha256,
    definedRecords: live.recordSummary.total,
    fileRecords: live.fileRecordSummary.total,
    contestedRecords: live.contestedRecordSet.count,
    contestedRecordSetSha256: live.contestedRecordSet.sha256,
    criticalRecords: live.criticalRecordWinners.length,
    vmadAuditExitCode: live.vmadValidation.auditExitCode,
    assetPaths: assetGroupsFromProof(live).reduce((sum, group) => sum + group.paths.length, 0),
    differences,
    boundaryFailures: boundary,
    notes,
    openProofBoundary: proof.proofBoundary?.open ?? [],
  };
  if (AS_JSON) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`Release-proof refresh: ${result.status}`);
    console.log(`  profile   : ${result.profile}`);
    console.log(`  ESP       : ${result.espSha256}`);
    console.log(`  records   : ${result.definedRecords} defined / ${result.fileRecords} file-contained`);
    console.log(`  contested : ${result.contestedRecords} exact (${result.contestedRecordSetSha256})`);
    console.log(`  critical  : ${result.criticalRecords}`);
    console.log(`  VMAD exit : ${result.vmadAuditExitCode}`);
    for (const item of [...differences, ...boundary]) console.log(`  [FAIL] ${item}`);
    for (const item of notes) console.log(`  [INFO] ${item}`);
    console.log("  open proof boundary:");
    for (const item of result.openProofBoundary) console.log(`    - ${item}`);
  }
  if (result.status !== "PASS") process.exitCode = 1;
}

main().catch((error) => die(error.stack || error.message));
