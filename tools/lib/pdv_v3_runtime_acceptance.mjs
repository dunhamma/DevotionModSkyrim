import fs from "node:fs";

export const MANIFEST_SCHEMA = "pdv.v3-runtime-acceptance-manifest.v1";
export const LEDGER_SCHEMA = "pdv.v3-runtime-acceptance-ledger.v1";
export const PASS_STATUSES = new Set(["pass", "not_required"]);
export const STATUS_VALUES = new Set(["pending", "pass", "fail", "blocked", "not_required"]);

export function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
}

export function nowLocal() {
  return new Date().toLocaleString("en-AU", {
    timeZone: "Australia/Sydney",
    hour12: false,
  });
}

export function validateManifest(manifest) {
  const errors = [];
  if (manifest?.schema !== MANIFEST_SCHEMA) errors.push(`Expected manifest schema ${MANIFEST_SCHEMA}.`);
  if (!Number.isInteger(manifest?.revision) || manifest.revision < 1) errors.push("Manifest revision must be a positive integer.");
  if (!Array.isArray(manifest?.gates) || !manifest.gates.length) errors.push("Manifest must declare at least one gate.");
  const gateIds = new Set();
  const caseIds = new Set();
  for (const gate of manifest?.gates ?? []) {
    if (!gate.id || gateIds.has(gate.id)) errors.push(`Duplicate or missing gate id: ${gate.id || "(missing)"}.`);
    gateIds.add(gate.id);
    if (!Array.isArray(gate.cases) || !gate.cases.length) errors.push(`Gate ${gate.id} has no cases.`);
    for (const testCase of gate.cases ?? []) {
      if (!testCase.id || caseIds.has(testCase.id)) errors.push(`Duplicate or missing case id: ${testCase.id || "(missing)"}.`);
      caseIds.add(testCase.id);
      if (!Array.isArray(testCase.slots) || !testCase.slots.length) errors.push(`Case ${testCase.id} has no slots.`);
      const slots = new Set();
      for (const slot of testCase.slots ?? []) {
        if (!slot || slots.has(slot)) errors.push(`Case ${testCase.id} has duplicate or missing slot ${slot || "(missing)"}.`);
        slots.add(slot);
      }
    }
  }
  for (const rule of manifest?.logRules?.failPatterns ?? []) {
    try {
      new RegExp(rule.pattern, rule.flags || "");
    } catch (error) {
      errors.push(`Invalid log rule ${rule.id || "(missing)"}: ${error.message}`);
    }
  }
  return errors;
}

export function createSlot() {
  return {
    status: "pending",
    observedAtLocal: "",
    commit: "",
    note: "",
    artifacts: [],
  };
}

export function syncLedger(manifest, inputLedger = {}) {
  const existingRows = new Map((inputLedger.cases ?? []).map((row) => [row.id, row]));
  const cases = [];
  for (const gate of manifest.gates) {
    for (const definition of gate.cases) {
      const existing = existingRows.get(definition.id) ?? {};
      const slots = {};
      for (const slotId of definition.slots) {
        const prior = existing.slots?.[slotId] ?? createSlot();
        slots[slotId] = {
          ...createSlot(),
          ...prior,
          artifacts: Array.isArray(prior.artifacts) ? prior.artifacts : [],
        };
      }
      cases.push({
        id: definition.id,
        gate: gate.id,
        title: definition.title,
        slots,
      });
    }
  }
  return {
    schema: LEDGER_SCHEMA,
    manifestRevision: manifest.revision,
    testedCommit: String(inputLedger.testedCommit ?? ""),
    profile: String(inputLedger.profile || manifest.profile || ""),
    enabledMod: String(inputLedger.enabledMod || manifest.enabledMod || ""),
    startedAtLocal: String(inputLedger.startedAtLocal ?? ""),
    updatedAtLocal: String(inputLedger.updatedAtLocal ?? ""),
    cases,
    observations: Array.isArray(inputLedger.observations) ? inputLedger.observations : [],
  };
}

export function recordSlot(ledger, { caseId, slotId, status, note, artifacts = [], commit = "" }) {
  if (!STATUS_VALUES.has(status)) throw new Error(`Unsupported status ${status}.`);
  if (status !== "pending" && !String(note).trim()) throw new Error("--note is required unless status is pending.");
  const row = ledger.cases.find((item) => item.id === caseId);
  if (!row) throw new Error(`Unknown case ${caseId}.`);
  if (!row.slots[slotId]) throw new Error(`Unknown slot ${caseId}.${slotId}.`);
  const observedAtLocal = status === "pending" ? "" : nowLocal();
  row.slots[slotId] = {
    status,
    observedAtLocal,
    commit: commit || ledger.testedCommit || "",
    note: String(note || ""),
    artifacts: artifacts.filter(Boolean),
  };
  ledger.updatedAtLocal = nowLocal();
  ledger.observations.push({
    observedAtLocal,
    case: caseId,
    slot: slotId,
    status,
    commit: row.slots[slotId].commit,
    note: row.slots[slotId].note,
    artifacts: row.slots[slotId].artifacts,
  });
  return row.slots[slotId];
}

export function evaluateGate(manifest, ledger, gateId, options = {}) {
  const findings = [];
  const manifestErrors = validateManifest(manifest);
  for (const detail of manifestErrors) findings.push({ status: "FAIL", check: "manifest", detail });
  if (ledger?.schema !== LEDGER_SCHEMA) findings.push({ status: "FAIL", check: "ledger schema", detail: `Expected ${LEDGER_SCHEMA}.` });
  if (ledger?.manifestRevision !== manifest?.revision) findings.push({ status: "FAIL", check: "manifest revision", detail: `Ledger revision ${ledger?.manifestRevision ?? "missing"}; manifest revision ${manifest?.revision ?? "missing"}.` });
  if (!String(ledger?.testedCommit || "").match(/^[0-9a-f]{7,40}$/i)) findings.push({ status: "FAIL", check: "tested commit", detail: "Ledger testedCommit is missing or invalid." });
  if (ledger?.profile !== manifest?.profile) findings.push({ status: "FAIL", check: "profile", detail: `Ledger profile ${ledger?.profile || "missing"}; expected ${manifest?.profile}.` });
  if (ledger?.enabledMod !== manifest?.enabledMod) findings.push({ status: "FAIL", check: "enabled mod", detail: `Ledger enabled mod ${ledger?.enabledMod || "missing"}; expected ${manifest?.enabledMod}.` });
  if (!ledger?.startedAtLocal) findings.push({ status: "FAIL", check: "session start", detail: "Ledger startedAtLocal is missing." });

  const selectedGates = gateId === "all" ? manifest.gates : manifest.gates.filter((gate) => gate.id === gateId);
  if (!selectedGates.length) findings.push({ status: "FAIL", check: "gate", detail: `Unknown gate ${gateId}.` });
  if (selectedGates.some((gate) => gate.requiresLog) && !(options.logReports ?? []).length) {
    findings.push({ status: "FAIL", check: "Papyrus logs", detail: "This gate requires at least one fresh Papyrus log scan." });
  }
  const rowMap = new Map((ledger?.cases ?? []).map((row) => [row.id, row]));
  const caseReports = [];
  for (const gate of selectedGates) {
    for (const definition of gate.cases) {
      const row = rowMap.get(definition.id);
      const slots = [];
      for (const slotId of definition.slots) {
        const evidence = row?.slots?.[slotId];
        let status = "PASS";
        let detail = evidence?.note || "Evidence recorded.";
        if (!evidence) {
          status = "FAIL";
          detail = "Evidence slot is missing from the ledger.";
        } else if (!PASS_STATUSES.has(evidence.status)) {
          status = "FAIL";
          detail = `Status is ${evidence.status || "missing"}.`;
        } else if (!String(evidence.note || "").trim()) {
          status = "FAIL";
          detail = "Passing evidence requires a note.";
        } else if (!String(evidence.commit || "").match(/^[0-9a-f]{7,40}$/i)) {
          status = "FAIL";
          detail = "Passing evidence requires the tested commit.";
        }
        slots.push({ id: slotId, status, detail, evidenceStatus: evidence?.status ?? "missing" });
      }
      caseReports.push({
        id: definition.id,
        gate: gate.id,
        title: definition.title,
        status: slots.every((slot) => slot.status === "PASS") ? "PASS" : "FAIL",
        slots,
      });
    }
  }

  for (const changedPath of options.runtimeSensitiveChanges ?? []) {
    findings.push({ status: "FAIL", check: "tested commit freshness", detail: `Runtime-sensitive path changed after testedCommit: ${changedPath}` });
  }
  for (const logReport of options.logReports ?? []) {
    for (const match of logReport.matches) findings.push({ status: "FAIL", check: `Papyrus log ${match.rule}`, detail: `${logReport.path || "log"}: ${match.line}` });
    if (logReport.stale) findings.push({ status: "FAIL", check: "Papyrus log freshness", detail: `${logReport.path || "log"}: ${logReport.staleReason}` });
  }
  const status = findings.every((finding) => finding.status === "PASS") && caseReports.every((row) => row.status === "PASS") ? "PASS" : "FAIL";
  return { status, gate: gateId, findings, cases: caseReports };
}

export function scanLog(text, logRules, options = {}) {
  const matches = [];
  const lines = String(text || "").split(/\r?\n/);
  for (const rule of logRules?.failPatterns ?? []) {
    const regex = new RegExp(rule.pattern, rule.flags || "");
    for (const line of lines) {
      regex.lastIndex = 0;
      if (regex.test(line)) matches.push({ rule: rule.id, line: line.slice(0, 500) });
    }
  }
  const startedAt = parseEvidenceTime(options.startedAt);
  const modifiedAt = options.modifiedAt instanceof Date ? options.modifiedAt.getTime() : Number(options.modifiedAt);
  const stale = Number.isFinite(startedAt) && Number.isFinite(modifiedAt) && modifiedAt < startedAt;
  return {
    status: matches.length || stale ? "FAIL" : "PASS",
    matches,
    stale,
    staleReason: stale ? "Papyrus log predates the recorded session start." : "",
  };
}

function parseEvidenceTime(value) {
  if (!value) return NaN;
  const direct = Date.parse(value);
  if (Number.isFinite(direct)) return direct;
  const match = String(value).match(/^(\d{1,2})\/(\d{1,2})\/(\d{4}),?\s+(\d{1,2}):(\d{2}):(\d{2})$/);
  if (!match) return NaN;
  const [, day, month, year, hour, minute, second] = match;
  return new Date(Number(year), Number(month) - 1, Number(day), Number(hour), Number(minute), Number(second)).getTime();
}

export function isRuntimeSensitive(filePath, prefixes) {
  const normalized = String(filePath).replace(/\\/g, "/");
  return prefixes.some((prefix) => normalized === prefix || normalized.startsWith(prefix));
}

export function formatSummary(report) {
  const lines = [`PDV V3 runtime acceptance ${report.gate}: ${report.status}`];
  for (const finding of report.findings) lines.push(`[${finding.status}] ${finding.check}: ${finding.detail}`);
  for (const testCase of report.cases) {
    lines.push(`[${testCase.status}] ${testCase.id}: ${testCase.title}`);
    for (const slot of testCase.slots.filter((item) => item.status !== "PASS")) lines.push(`  [${slot.status}] ${slot.id}: ${slot.detail}`);
  }
  return lines.join("\n");
}
