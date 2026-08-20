#!/usr/bin/env node

import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_DIR = path.join(ROOT, "live-source", "Scripts", "Source");
const REGION_PATH = path.join(ROOT, "references", "authoring", "PDV_2_0RegionMap.json");
const CONTRACT_PATH = path.join(ROOT, "references", "authoring", "PDV_2_0ModuleContracts.manifest.json");
const RETIREMENT_PATH = path.join(ROOT, "references", "authoring", "PDV_2_0Retirement.manifest.json");
const KNOWN_FLAGS = new Set(["--check", "--write", "--json", "--self-test"]);

assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_module_contract_sync" });
const WRITE = process.argv.includes("--write");
const CHECK = process.argv.includes("--check") || !WRITE;
const JSON_OUTPUT = process.argv.includes("--json");
const SELF_TEST = process.argv.includes("--self-test");
if (WRITE && process.argv.includes("--check")) throw new Error("--check and --write are mutually exclusive.");

const ALLOWED_MANAGER_BRIDGES = new Map([
  // ORIGIN needs the manager-owned canonical global reader and exposes a local
  // forwarding method so race adapters can call it without learning Manager.
  ["ORIGIN", new Set(["getplayeroriginraceindex"])],
]);
const REQUIRED_ORIGIN_ADAPTER_OVERRIDES = ["SyncRaceRewards", "SyncNeglectSpells"];
const ORIGIN_NEGLECT_CONTRACTS = new Map([
  ["PDV_OriginRuntime_Altmer", { hooks: ["SyncAltmerNeglectSpell", "IsAltmerCoherenceNeglected"], spells: ["PDV_SPEL_Neglect_Altmer"] }],
  ["PDV_OriginRuntime_Argonian", { hooks: ["SyncArgonianNeglectSpell", "IsArgonianHistNeglected"], spells: ["PDV_SPEL_Neglect_ArgonianHist"] }],
  ["PDV_OriginRuntime_Bosmer", { hooks: ["SyncBosmerNeglectSpell", "IsBosmerPathNeglected"], spells: ["PDV_SPEL_Neglect_Bosmer"] }],
  ["PDV_OriginRuntime_Breton", { hooks: ["SyncBretonNeglectSpell", "IsBretonTraditionNeglected"], spells: ["PDV_SPEL_Neglect_Breton"] }],
  ["PDV_OriginRuntime_Dunmer", { hooks: ["SyncDunmerNeglectSpell", "IsDunmerAncestorNeglected"], spells: ["PDV_SPEL_Neglect_Dunmer"] }],
  ["PDV_OriginRuntime_Imperial", { hooks: ["SyncImperialNeglectSpell", "IsImperialCivicNeglected"], spells: ["PDV_SPEL_Neglect_Imperial"] }],
  ["PDV_OriginRuntime_Khajiit", { hooks: ["SyncKhajiitNeglectSpell", "IsKhajiitLunarNeglected"], spells: ["PDV_SPEL_Neglect_KhajiitLunar"] }],
  ["PDV_OriginRuntime_Nord", {
    hooks: ["SyncKyneNeglectSpell", "IsKyneNeglectActive", "SyncNordPatronNeglectSpells"],
    spells: [
      "PDV_SPEL_Neglect_Kyne",
      "PDV_SPEL_Neglect_Shor",
      "PDV_SPEL_Neglect_Tsun",
      "PDV_SPEL_Neglect_Stuhn",
      "PDV_SPEL_Neglect_Talos",
      "PDV_SPEL_Neglect_Arkay",
      "PDV_SPEL_Neglect_Dibella",
    ],
  }],
  ["PDV_OriginRuntime_Orc", { hooks: ["SyncOrcNeglectSpell", "IsOrcCodeNeglected"], spells: ["PDV_SPEL_Neglect_Orc"] }],
  ["PDV_OriginRuntime_Redguard", { hooks: ["SyncRedguardNeglectSpell", "IsRedguardAncestorDistanceNeglected"], spells: ["PDV_SPEL_Neglect_Redguard"] }],
]);

function esc(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export function stripPapyrusCode(source) {
  let output = "";
  let inString = false;
  let inDocBlock = false;
  let inBlockComment = false;
  for (let index = 0; index < String(source).length; index += 1) {
    const char = source[index];
    const next = source[index + 1];
    if (inBlockComment) {
      if (char === "/" && next === ";") {
        output += "  ";
        index += 1;
        inBlockComment = false;
      } else {
        output += char === "\n" ? "\n" : " ";
      }
      continue;
    }
    if (inDocBlock) {
      if (char === "}") inDocBlock = false;
      output += char === "\n" ? "\n" : " ";
      continue;
    }
    if (inString) {
      if (char === "\\" && next) {
        output += "  ";
        index += 1;
      } else {
        if (char === '"') inString = false;
        output += char === "\n" ? "\n" : " ";
      }
      continue;
    }
    if (char === '"') {
      inString = true;
      output += " ";
      continue;
    }
    if (char === "{") {
      inDocBlock = true;
      output += " ";
      continue;
    }
    if (char === ";" && next === "/") {
      inBlockComment = true;
      output += "  ";
      index += 1;
      continue;
    }
    if (char === ";") {
      while (index < source.length && source[index] !== "\n") index += 1;
      output += "\n";
      continue;
    }
    output += char;
  }
  return output;
}

function stripInlineComment(line) {
  let inString = false;
  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    if (char === "\\" && inString && index + 1 < line.length) {
      index += 1;
      continue;
    }
    if (char === '"') inString = !inString;
    if (char === ";" && !inString) return line.slice(0, index).trim();
  }
  return line.trim();
}

export function parsePapyrusDeclarations(source, scriptName = "<fixture>") {
  const declarations = new Map();
  for (const line of String(source).split(/\r?\n/)) {
    const match = line.match(
      /^\s*(?:(?:[A-Za-z_]\w*(?:\[\])?)\s+)?(?:Function|Event)\s+([A-Za-z_]\w*)\s*\(/i,
    );
    if (!match) continue;
    const name = match[1];
    const signature = stripInlineComment(line).replace(/\s+/g, " ");
    declarations.set(name.toLowerCase(), { name, signature, scriptName });
  }
  return declarations;
}

export function extractPapyrusFunctionBody(source, functionName) {
  const code = stripPapyrusCode(source);
  const pattern = new RegExp(
    `^\\s*(?:(?:[A-Za-z_]\\w*(?:\\[\\])?)\\s+)?Function\\s+${esc(functionName)}\\s*\\([^\\n]*\\)\\s*\\n([\\s\\S]*?)^\\s*EndFunction\\b`,
    "im",
  );
  return code.match(pattern)?.[1] ?? "";
}

export function discoverQualifiedCalls(source, qualifiers) {
  const code = stripPapyrusCode(source);
  const calls = new Set();
  for (const qualifier of qualifiers) {
    const pattern = new RegExp(`\\b${esc(qualifier)}\\s*\\.\\s*([A-Za-z_]\\w*)\\s*\\(`, "g");
    for (const match of code.matchAll(pattern)) calls.add(match[1]);
  }
  return calls;
}

export function auditRetirementRows(rows, liveSymbols) {
  const unresolved = rows
    .filter((row) => String(row.adjudication ?? "").trim().toUpperCase() === "NEEDS-REVIEW")
    .map((row) => row.symbol);
  const retiredStillDeclared = rows
    .filter((row) => row.action === "retire" && liveSymbols.has(String(row.symbol).toLowerCase()))
    .map((row) => ({ symbol: row.symbol, owners: liveSymbols.get(String(row.symbol).toLowerCase()) }));
  return { rows: rows.length, unresolved, retiredStillDeclared };
}

export function auditOriginNeglectContract(source, contract) {
  const body = extractPapyrusFunctionBody(source, "SyncNeglectSpells");
  const actualHooks = [...new Set(body.match(/\b(?:Sync|Is)[A-Za-z0-9_]*Neglect[A-Za-z0-9_]*\b/g) ?? [])].sort();
  const expectedHooks = [...contract.hooks].sort();
  const actualSpells = [...new Set(stripPapyrusCode(source).match(/\bPDV_SPEL_Neglect_[A-Za-z0-9_]+\b/g) ?? [])].sort();
  const expectedSpells = [...contract.spells].sort();
  const problems = [];
  if (!body) problems.push("SyncNeglectSpells body is missing");
  if (JSON.stringify(actualHooks) !== JSON.stringify(expectedHooks)) {
    problems.push(`SyncNeglectSpells hooks expected [${expectedHooks.join(", ")}], found [${actualHooks.join(", ")}]`);
  }
  if (JSON.stringify(actualSpells) !== JSON.stringify(expectedSpells)) {
    problems.push(`neglect spells expected [${expectedSpells.join(", ")}], found [${actualSpells.join(", ")}]`);
  }
  return { problems, actualHooks, actualSpells };
}

function runSelfTest() {
  const fixture = [
    "Scriptname PDV_Fixture extends Quest",
    "Function RealCall()",
    "    LedgerRuntime.AwardPiety(None, 1.0)",
    '    String ignored = "LedgerRuntime.NotACall()"',
    "    ; LedgerRuntime.AlsoNotACall()",
    "    { LedgerRuntime.DocumentationOnly() }",
    "    ;/ LedgerRuntime.BlockCommentOnly() /;",
    "EndFunction",
  ].join("\n");
  assert.deepEqual([...discoverQualifiedCalls(fixture, ["LedgerRuntime"])], ["AwardPiety"]);
  const declarations = parsePapyrusDeclarations(fixture, "PDV_Fixture");
  assert.equal(declarations.get("realcall")?.signature, "Function RealCall()");
  const stacked = "PDV_Manager.DebugRuntime.DebugRunNeglectPass()";
  assert.deepEqual([...discoverQualifiedCalls(stacked, ["DebugRuntime"])], ["DebugRunNeglectPass"]);
  assert.match(extractPapyrusFunctionBody(fixture, "RealCall"), /LedgerRuntime\.AwardPiety/);
  const retirement = auditRetirementRows(
    [
      { symbol: "OldFunction", action: "retire", adjudication: "reviewed" },
      { symbol: "PendingFunction", action: "extract", adjudication: "NEEDS-REVIEW" },
    ],
    new Map([["oldfunction", [{ script: "PDV_Fixture", kind: "function" }]]]),
  );
  assert.deepEqual(retirement.unresolved, ["PendingFunction"]);
  assert.equal(retirement.retiredStillDeclared[0]?.symbol, "OldFunction");
  const leakedNeglect = auditOriginNeglectContract(
    [
      "Function SyncNeglectSpells()",
      "    SyncAltmerNeglectSpell(IsAltmerCoherenceNeglected())",
      "EndFunction",
      "Spell Property PDV_SPEL_Neglect_Altmer Auto",
      "Spell Property PDV_SPEL_Neglect_Breton Auto",
    ].join("\n"),
    { hooks: ["SyncAltmerNeglectSpell", "IsAltmerCoherenceNeglected"], spells: ["PDV_SPEL_Neglect_Altmer"] },
  );
  assert.match(leakedNeglect.problems.join("; "), /PDV_SPEL_Neglect_Breton/);
  console.log("pdv_module_contract_sync self-test: PASS=7 FAIL=0");
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function scriptStem(fileName) {
  return path.basename(fileName, ".psc");
}

function callerLabel(fileName, moduleByScript) {
  const stem = scriptStem(fileName);
  if (moduleByScript.has(stem)) return moduleByScript.get(stem);
  if (stem === "PDV_MCM") return "MCM";
  if (stem === "PDV_SurveyDevotionEffect") return "SURVEY";
  return stem;
}

function moduleRegionEntries(moduleName, regionModules) {
  if (moduleName === "ORIGIN") {
    return Object.entries(regionModules).filter(([name]) => name === "ORIGIN" || name.startsWith("ORIGIN_"));
  }
  return regionModules[moduleName] ? [[moduleName, regionModules[moduleName]]] : [];
}

function inheritanceCycle(headers) {
  const visiting = new Set();
  const visited = new Set();
  const walk = (name, stack) => {
    if (visiting.has(name)) return [...stack, name];
    if (visited.has(name) || !headers.has(name)) return null;
    visiting.add(name);
    const parent = headers.get(name);
    const cycle = parent ? walk(parent, [...stack, name]) : null;
    visiting.delete(name);
    visited.add(name);
    return cycle;
  };
  for (const name of headers.keys()) {
    const cycle = walk(name, []);
    if (cycle) return cycle;
  }
  return null;
}

function buildContract() {
  const existing = readJson(CONTRACT_PATH);
  const region = readJson(REGION_PATH);
  const retirement = readJson(RETIREMENT_PATH);
  const sourceFiles = fs.readdirSync(SOURCE_DIR).filter((file) => file.toLowerCase().endsWith(".psc")).sort();
  const sources = new Map(sourceFiles.map((file) => [file, fs.readFileSync(path.join(SOURCE_DIR, file), "utf8")]));
  const strippedSources = new Map([...sources].map(([file, source]) => [file, stripPapyrusCode(source)]));
  const declarationsByScript = new Map(
    [...sources].map(([file, source]) => [scriptStem(file), parsePapyrusDeclarations(source, scriptStem(file))]),
  );

  const liveSymbols = new Map();
  const addLiveSymbol = (symbol, script, kind) => {
    const key = symbol.toLowerCase();
    if (!liveSymbols.has(key)) liveSymbols.set(key, []);
    liveSymbols.get(key).push({ script, kind });
  };
  for (const [script, declarations] of declarationsByScript) {
    for (const declaration of declarations.values()) addLiveSymbol(declaration.name, script, "function-or-event");
  }

  const propertyOwnersByType = new Map();
  const propertyPattern = /^\s*([A-Za-z_]\w*)\s+Property\s+([A-Za-z_]\w*)\s+Auto\b/gim;
  for (const source of strippedSources.values()) {
    for (const match of source.matchAll(propertyPattern)) {
      const type = match[1].toLowerCase();
      if (!propertyOwnersByType.has(type)) propertyOwnersByType.set(type, new Set());
      propertyOwnersByType.get(type).add(match[2]);
    }
  }
  for (const [file, source] of strippedSources) {
    for (const match of source.matchAll(propertyPattern)) addLiveSymbol(match[2], scriptStem(file), "property");
  }

  const moduleScripts = new Map();
  const moduleByScript = new Map();
  for (const moduleName of Object.keys(existing.modules)) {
    const entries = moduleRegionEntries(moduleName, region.modules);
    const scripts = [...new Set(entries.map(([, entry]) => entry.targetScript))];
    if (!scripts.length) scripts.push(existing.modules[moduleName].targetScript);
    moduleScripts.set(moduleName, scripts);
    for (const script of scripts) moduleByScript.set(script, moduleName);
  }

  const headers = new Map();
  for (const [file, source] of strippedSources) {
    const match = source.match(/^\s*Scriptname\s+([A-Za-z_]\w*)(?:\s+extends\s+([A-Za-z_]\w*))?/im);
    if (match) headers.set(match[1], match[2] ?? null);
  }

  const managerDeclarations = declarationsByScript.get("PDV__ManagerQuest") ?? new Map();
  const problems = [];
  const retirementAudit = auditRetirementRows(retirement.rows ?? [], liveSymbols);
  if (retirementAudit.unresolved.length) {
    problems.push(`Retirement authority has unresolved NEEDS-REVIEW rows: ${retirementAudit.unresolved.join(", ")}.`);
  }
  for (const row of retirementAudit.retiredStillDeclared) {
    const owners = row.owners.map((owner) => `${owner.script} (${owner.kind})`).join(", ");
    problems.push(`Retired symbol ${row.symbol} is still declared by ${owners}.`);
  }
  const moduleReports = [];
  const generatedModules = {};

  for (const [moduleName, oldModule] of Object.entries(existing.modules)) {
    const scripts = moduleScripts.get(moduleName) ?? [oldModule.targetScript];
    const actual = new Map();
    const signatureOwners = new Map();
    for (const script of scripts) {
      const declarations = declarationsByScript.get(script);
      if (!declarations) {
        problems.push(`${moduleName}: source ${script}.psc is missing.`);
        continue;
      }
      for (const [key, declaration] of declarations) {
        const normalizedSignature = declaration.signature.toLowerCase();
        if (!signatureOwners.has(key)) signatureOwners.set(key, new Map());
        if (!signatureOwners.get(key).has(normalizedSignature)) signatureOwners.get(key).set(normalizedSignature, []);
        signatureOwners.get(key).get(normalizedSignature).push(script);
        if (!actual.has(key)) actual.set(key, declaration);
      }
    }
    for (const [key, signatures] of signatureOwners) {
      if (signatures.size > 1) {
        problems.push(`${moduleName}: ${actual.get(key)?.name ?? key} has incompatible declarations across ${scripts.join(", ")}.`);
      }
    }

    const targetType = oldModule.targetScript.toLowerCase();
    const qualifiers = new Set([oldModule.targetScript, ...(propertyOwnersByType.get(targetType) ?? [])]);
    const calledBy = new Map();
    for (const [file, source] of sources) {
      if (scripts.includes(scriptStem(file))) continue;
      for (const name of discoverQualifiedCalls(source, qualifiers)) {
        const key = name.toLowerCase();
        if (!calledBy.has(key)) calledBy.set(key, { name, callers: new Set() });
        calledBy.get(key).callers.add(callerLabel(file, moduleByScript));
      }
    }

    const unresolvedCalls = [...calledBy].filter(([key]) => !actual.has(key));
    for (const [, call] of unresolvedCalls) {
      problems.push(`${moduleName}: externally called ${call.name} has no declaration in ${scripts.join(", ")}.`);
    }

    const regionEntries = moduleRegionEntries(moduleName, region.modules);
    const expected = new Map(
      regionEntries.flatMap(([, entry]) => (entry.functions ?? []).map((fn) => [fn.name.toLowerCase(), fn.name])),
    );
    const missingRegion = [...expected].filter(([key]) => !actual.has(key)).map(([, name]) => name);
    if (missingRegion.length) problems.push(`${moduleName}: RegionMap functions missing from target: ${missingRegion.join(", ")}.`);

    const allowedBridges = ALLOWED_MANAGER_BRIDGES.get(moduleName) ?? new Set();
    const managerDuplicates = moduleName === "MANAGER"
      ? []
      : [...expected]
        .filter(([key]) => managerDeclarations.has(key) && !allowedBridges.has(key))
        .map(([, name]) => name);
    if (managerDuplicates.length) {
      problems.push(`${moduleName}: mapped functions still declared by manager: ${managerDuplicates.join(", ")}.`);
    }

    const missingAdapterOverrides = [];
    const neglectIsolationProblems = [];
    if (moduleName === "ORIGIN") {
      for (const script of scripts.filter((name) => name !== oldModule.targetScript)) {
        const declarations = declarationsByScript.get(script) ?? new Map();
        for (const functionName of REQUIRED_ORIGIN_ADAPTER_OVERRIDES) {
          if (!declarations.has(functionName.toLowerCase())) missingAdapterOverrides.push(`${script}.${functionName}`);
        }
        const contract = ORIGIN_NEGLECT_CONTRACTS.get(script);
        const source = strippedSources.get(`${script}.psc`) ?? "";
        if (!contract) {
          neglectIsolationProblems.push(`${script} has no reviewed neglect isolation contract`);
          continue;
        }
        const audit = auditOriginNeglectContract(source, contract);
        neglectIsolationProblems.push(...audit.problems.map((problem) => `${script}.${problem}`));
      }
      if (missingAdapterOverrides.length) {
        problems.push(`ORIGIN: race adapters missing reward/neglect isolation overrides: ${missingAdapterOverrides.join(", ")}.`);
      }
      if (neglectIsolationProblems.length) {
        problems.push(`ORIGIN: cross-race/path neglect isolation drift: ${neglectIsolationProblems.join("; ")}.`);
      }
    }

    const publicEntries = [...calledBy]
      .filter(([key]) => actual.has(key))
      .map(([key, call]) => ({
        name: actual.get(key).name,
        signature: actual.get(key).signature,
        calledByModules: [...call.callers].sort((left, right) => left.localeCompare(right)),
      }))
      .sort((left, right) => left.name.localeCompare(right.name));
    const privateCount = actual.size - publicEntries.length;
    if (privateCount < 0) problems.push(`${moduleName}: public surface exceeds the declaration inventory.`);

    generatedModules[moduleName] = {
      targetScript: oldModule.targetScript,
      callForm: oldModule.callForm,
      public: publicEntries,
      privateCount,
    };
    moduleReports.push({
      module: moduleName,
      scripts,
      declarations: actual.size,
      publicCount: publicEntries.length,
      privateCount,
      regionExpected: expected.size,
      missingRegion,
      managerDuplicates,
      unresolvedCalls: unresolvedCalls.map(([, call]) => call.name),
      missingAdapterOverrides,
      neglectIsolationProblems,
      qualifiers: [...qualifiers].sort(),
    });
  }

  const cycle = inheritanceCycle(headers);
  if (cycle) problems.push(`Papyrus inheritance cycle: ${cycle.join(" -> ")}.`);

  const generated = {
    schema: existing.schema,
    generatedFrom: "PDV_2_0RegionMap.json + current live-source call graph",
    generatedBy: "tools/pdv_module_contract_sync.mjs",
    modules: generatedModules,
  };
  const rendered = `${JSON.stringify(generated, null, 2)}\n`;
  const current = fs.readFileSync(CONTRACT_PATH, "utf8").replace(/\r\n/g, "\n");
  const drift = current !== rendered;
  const digest = crypto.createHash("sha256").update(rendered).digest("hex").toUpperCase();
  return { generated, rendered, drift, digest, problems, moduleReports, inheritanceCycle: cycle, retirementAudit };
}

function main() {
  if (SELF_TEST) {
    runSelfTest();
    return;
  }
  const result = buildContract();
  if (WRITE && !result.problems.length) writeTextWithEol(CONTRACT_PATH, result.rendered, "lf");
  const status = result.problems.length || (CHECK && result.drift) ? "FAIL" : "PASS";
  const report = {
    status,
    mode: WRITE ? "write" : "check",
    contractPath: path.relative(ROOT, CONTRACT_PATH).replace(/\\/g, "/"),
    drift: result.drift,
    wrote: WRITE && !result.problems.length,
    generatedSha256: result.digest,
    inheritanceCycle: result.inheritanceCycle,
    retirementAuthority: {
      path: path.relative(ROOT, RETIREMENT_PATH).replace(/\\/g, "/"),
      ...result.retirementAudit,
    },
    problems: result.problems,
    modules: result.moduleReports,
  };
  if (JSON_OUTPUT) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    for (const module of report.modules) {
      console.log(
        `[${module.missingRegion.length || module.managerDuplicates.length || module.unresolvedCalls.length || module.missingAdapterOverrides.length || module.neglectIsolationProblems.length ? "FAIL" : "PASS"}] ` +
        `${module.module}: ${module.declarations} declarations = ${module.publicCount} public + ${module.privateCount} private; ` +
        `${module.regionExpected} RegionMap names present.`,
      );
    }
    console.log(
      `[${report.retirementAuthority.unresolved.length || report.retirementAuthority.retiredStillDeclared.length ? "FAIL" : "PASS"}] ` +
      `Retirement authority: ${report.retirementAuthority.rows} rows; ${report.retirementAuthority.unresolved.length} unresolved; ` +
      `${report.retirementAuthority.retiredStillDeclared.length} retired symbols still declared.`,
    );
    for (const problem of report.problems) console.error(`[FAIL] ${problem}`);
    if (report.drift && !WRITE) console.error("[FAIL] Module contract manifest differs from the current source call graph. Run with --write after review.");
    if (report.wrote) console.log(`[PASS] Rewrote ${report.contractPath}.`);
    console.log(`PDV module contract sync: ${status}; drift=${report.drift}; sha256=${report.generatedSha256}`);
  }
  process.exitCode = status === "PASS" || (WRITE && !result.problems.length) ? 0 : 1;
}

main();
