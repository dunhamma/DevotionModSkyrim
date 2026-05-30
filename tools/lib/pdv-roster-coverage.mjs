import fs from "node:fs";
import path from "node:path";

export const PHASE20_EXPECTED_RACES = [
  "Nord",
  "Imperial",
  "Breton",
  "Dunmer",
  "Altmer",
  "Khajiit",
  "Bosmer",
  "Redguard",
  "Orc",
  "Argonian",
];

export const PHASE20_SKYRIM_DAEDRIC_PRINCES = [
  "Azura / Azurah",
  "Boethiah / Boethra",
  "Mephala / Mafala",
  "Malacath / Mauloch",
  "Meridia",
  "Hircine",
  "Molag Bal",
  "Nocturnal",
  "Hermaeus Mora",
  "Mehrunes Dagon",
  "Sheogorath",
  "Namira / Namiira",
  "Sanguine / Sangiin",
  "Clavicus Vile",
  "Peryite",
  "Vaermina",
];

export const PHASE20_REQUIRED_COVERAGE_COLUMNS = [
  "deityOrPrince",
  "culturalForm",
  "skyrimPresentStatus",
  "race",
  "responseState",
  "commitmentGate",
  "boonOrFavorSurface",
  "priceNeglectOrStigma",
  "exitOrResidue",
  "hookSource",
  "playerFeedback",
  "implementationStatus",
  "verifierStatus",
  "runtimeProofStatus",
];

export function verifyPhase21RosterCoverage(projectRoot, options = {}) {
  const strictContentReady = Boolean(options.strictContentReady);
  const findings = [];
  const manifestPath = path.join(projectRoot, "references", "authoring", "PDV_DeityCoverageMatrix.json");

  const add = (status, check, detail, filePath = null) => {
    findings.push({ status, check, detail, path: filePath ? String(filePath) : null });
  };
  const pass = (check, detail, filePath = null) => add("PASS", check, detail, filePath);
  const info = (check, detail, filePath = null) => add("INFO", check, detail, filePath);
  const warn = (check, detail, filePath = null) => add("WARN", check, detail, filePath);
  const fail = (check, detail, filePath = null) => add("FAIL", check, detail, filePath);

  if (!fs.existsSync(manifestPath)) {
    fail("Phase 20 roster manifest", "references/authoring/PDV_DeityCoverageMatrix.json is missing.", manifestPath);
    return findings;
  }

  let manifest;
  try {
    manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  } catch (error) {
    fail("Phase 20 roster manifest", `Manifest JSON could not be parsed: ${error.message}`, manifestPath);
    return findings;
  }

  if (manifest.schema === "pdv_deity_coverage_matrix_v1") {
    pass("Phase 20 roster manifest", "Manifest declares schema pdv_deity_coverage_matrix_v1.", manifestPath);
  } else {
    fail("Phase 20 roster manifest", `Unexpected schema '${manifest.schema}'.`, manifestPath);
  }

  compareSet({
    label: "Phase 20 required races",
    actual: manifest.requiredRaces || [],
    expected: PHASE20_EXPECTED_RACES,
    filePath: manifestPath,
    pass,
    fail,
  });

  compareSet({
    label: "Phase 20 Skyrim-present Daedric Princes",
    actual: manifest.skyrimPresentDaedricPrinces || [],
    expected: PHASE20_SKYRIM_DAEDRIC_PRINCES,
    filePath: manifestPath,
    pass,
    fail,
  });

  compareSet({
    label: "Phase 20 coverage columns",
    actual: manifest.coverageColumns || [],
    expected: PHASE20_REQUIRED_COVERAGE_COLUMNS,
    filePath: manifestPath,
    pass,
    fail,
  });

  const excludedNames = (manifest.excludedDaedricPrinces || []).map((entry) => entry.name);
  if (excludedNames.includes("Jyggalag") && !(manifest.skyrimPresentDaedricPrinces || []).includes("Jyggalag")) {
    pass("Phase 20 Daedric exclusion", "Jyggalag is explicitly excluded unless future adopted content adds him.", manifestPath);
  } else {
    fail("Phase 20 Daedric exclusion", "Jyggalag must be explicitly excluded and absent from the Skyrim-present Prince roster.", manifestPath);
  }

  const serialized = JSON.stringify(manifest).toLowerCase();
  if (serialized.includes("dev-only") || serialized.includes("dev_only")) {
    const detail = "The Phase 20 roster authority still contains dev-only language; 1.0 requires content-ready handling for locked gods and Skyrim-present Princes.";
    if (strictContentReady) {
      fail("Phase 20 dev-only guard", detail, manifestPath);
    } else {
      warn("Phase 20 dev-only guard", detail, manifestPath);
    }
  } else {
    pass("Phase 20 dev-only guard", "No locked god or Skyrim-present Prince is marked dev-only in the roster authority.", manifestPath);
  }

  const sourceMatrices = manifest.sourceMatrices || {};
  const stancePath = resolveProjectPath(projectRoot, sourceMatrices.stanceMatrix);
  const daedricPath = resolveProjectPath(projectRoot, sourceMatrices.daedricRacePrinceMatrix);

  const stanceRows = readCsvForCheck(stancePath, "Phase 20 stance matrix", findings);
  const daedricRows = readCsvForCheck(daedricPath, "Phase 20 Daedric matrix", findings);
  const lockedWorshipObjects = manifest.lockedWorshipObjects || [];

  if (stanceRows) {
    const byObject = new Map(stanceRows.rows.map((row) => [row.WorshipObject, row]));
    const missing = lockedWorshipObjects.filter((name) => !byObject.has(name));
    if (missing.length) {
      fail("Phase 20 locked worship roster", `Missing stance rows: ${missing.join(", ")}.`, stancePath);
    } else {
      pass("Phase 20 locked worship roster", `${lockedWorshipObjects.length} locked worship object(s) are present in the stance matrix.`, stancePath);
    }
    checkRaceColumns({
      label: "Phase 20 stance race coverage",
      rows: lockedWorshipObjects.map((name) => byObject.get(name)).filter(Boolean),
      raceColumns: PHASE20_EXPECTED_RACES,
      nameField: "WorshipObject",
      filePath: stancePath,
      pass,
      fail,
    });
    reportRaceCoverage({
      label: "Phase 20 stance response spread",
      rows: lockedWorshipObjects.map((name) => byObject.get(name)).filter(Boolean),
      raceColumns: PHASE20_EXPECTED_RACES,
      info,
      filePath: stancePath,
    });
  }

  if (daedricRows) {
    const byPrince = new Map(daedricRows.rows.map((row) => [row.Prince, row]));
    const missing = PHASE20_SKYRIM_DAEDRIC_PRINCES.filter((name) => !byPrince.has(name));
    if (missing.length) {
      fail("Phase 20 Daedric Prince roster", `Missing Daedric matrix rows: ${missing.join(", ")}.`, daedricPath);
    } else {
      pass("Phase 20 Daedric Prince roster", "All sixteen Skyrim-present Prince surfaces are present in the Daedric matrix.", daedricPath);
    }
    checkRaceColumns({
      label: "Phase 20 Daedric race coverage",
      rows: PHASE20_SKYRIM_DAEDRIC_PRINCES.map((name) => byPrince.get(name)).filter(Boolean),
      raceColumns: PHASE20_EXPECTED_RACES,
      nameField: "Prince",
      filePath: daedricPath,
      pass,
      fail,
    });
    reportRaceCoverage({
      label: "Phase 20 Daedric response spread",
      rows: PHASE20_SKYRIM_DAEDRIC_PRINCES.map((name) => byPrince.get(name)).filter(Boolean),
      raceColumns: PHASE20_EXPECTED_RACES,
      info,
      filePath: daedricPath,
    });
  }

  return findings;
}

function compareSet({ label, actual, expected, filePath, pass, fail }) {
  const actualSet = new Set(actual);
  const expectedSet = new Set(expected);
  const missing = expected.filter((entry) => !actualSet.has(entry));
  const extra = actual.filter((entry) => !expectedSet.has(entry));
  if (missing.length || extra.length) {
    fail(label, `Missing: ${missing.join(", ") || "none"}; extra: ${extra.join(", ") || "none"}.`, filePath);
  } else {
    pass(label, `${expected.length} expected value(s) present.`, filePath);
  }
}

function resolveProjectPath(projectRoot, maybeRelative) {
  if (!maybeRelative || typeof maybeRelative !== "string") {
    return null;
  }
  return path.isAbsolute(maybeRelative) ? maybeRelative : path.join(projectRoot, maybeRelative);
}

function readCsvForCheck(filePath, label, findings) {
  const add = (status, check, detail, pathValue = null) => findings.push({ status, check, detail, path: pathValue });
  if (!filePath || !fs.existsSync(filePath)) {
    add("FAIL", label, "CSV source is missing.", filePath);
    return null;
  }
  try {
    const text = fs.readFileSync(filePath, "utf8");
    const [headerLine, ...dataLines] = text.split(/\r?\n/).filter((line) => line.trim());
    const headers = parseCsvLine(headerLine);
    const rows = dataLines.map((line) => {
      const cells = parseCsvLine(line);
      const row = {};
      headers.forEach((header, index) => {
        row[header] = cells[index] || "";
      });
      return row;
    });
    add("PASS", label, `Read ${rows.length} row(s).`, filePath);
    return { headers, rows };
  } catch (error) {
    add("FAIL", label, `CSV source could not be read: ${error.message}`, filePath);
    return null;
  }
}

function checkRaceColumns({ label, rows, raceColumns, nameField, filePath, pass, fail }) {
  const gaps = [];
  for (const row of rows) {
    for (const race of raceColumns) {
      if (!String(row[race] || "").trim()) {
        gaps.push(`${row[nameField] || "(unnamed)"}.${race}`);
      }
    }
  }
  if (gaps.length) {
    fail(label, `Missing race coverage cells: ${gaps.slice(0, 30).join(", ")}${gaps.length > 30 ? "..." : ""}.`, filePath);
  } else {
    pass(label, `${rows.length} roster row(s) cover all ${raceColumns.length} race column(s).`, filePath);
  }
}

function reportRaceCoverage({ label, rows, raceColumns, info, filePath }) {
  const parts = raceColumns.map((race) => {
    const counts = {};
    for (const row of rows) {
      const state = normalizeResponseState(row[race]);
      counts[state] = (counts[state] || 0) + 1;
    }
    return `${race}=${Object.entries(counts).map(([state, count]) => `${state}:${count}`).join("/")}`;
  });
  info(label, parts.join("; "), filePath);
}

function normalizeResponseState(value) {
  const raw = String(value || "").trim();
  if (!raw) return "MISSING";
  const match = raw.match(/^[A-Za-z-]+/);
  return match ? match[0] : raw;
}

function parseCsvLine(line) {
  const cells = [];
  let current = "";
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    if (char === '"') {
      if (quoted && line[index + 1] === '"') {
        current += '"';
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (char === "," && !quoted) {
      cells.push(current);
      current = "";
    } else {
      current += char;
    }
  }
  cells.push(current);
  return cells;
}
