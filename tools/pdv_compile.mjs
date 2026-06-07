#!/usr/bin/env node
/*
 * Papyrus compiler wrapper for the PlayerDevotion Anvil/MO2 development setup.
 *
 * This tool compiles PDV source scripts by spawning PapyrusCompiler.exe
 * directly with the project-verified SSE import chain. It does not call
 * ScriptCompile.bat, PowerShell, or the CK compile menu. After a successful
 * compile, it runs the PDV verifier unless --skip-verify is used.
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const ANVIL_ROOT = "D:/Wabbajack/modlists/Anvil";
const STOCK_GAME = path.join(ANVIL_ROOT, "Stock Game");
const DEVOTION_MOD = path.join(ANVIL_ROOT, "mods", "Devotion");
const DEVOTION_SOURCE = path.join(DEVOTION_MOD, "Scripts", "Source");
const DEVOTION_PEX = path.join(DEVOTION_MOD, "Scripts");
const SKYUI_HEADERS_SOURCE = path.join(PROJECT_ROOT, "tools", "skyui_compile_shim");
const COMPILER_EXE = path.join(STOCK_GAME, "Papyrus Compiler", "PapyrusCompiler.exe");
const ASSEMBLER_EXE = path.join(STOCK_GAME, "Papyrus Compiler", "PapyrusAssembler.exe");
const FLAGS_FILE = path.join(STOCK_GAME, "Data", "Source", "Scripts", "TESV_Papyrus_Flags.flg");
const VERIFIER = path.join(PROJECT_ROOT, "tools", "pdv_verify.mjs");

const IMPORT_ROOTS = [
  DEVOTION_SOURCE,
  path.join(ANVIL_ROOT, "mods", "SKSE Script Sources - Compile Only", "scripts", "source"),
  path.join(ANVIL_ROOT, "mods", "PapyrusUtil AE - Scripting Utility Functions", "Scripts", "Source"),
  path.join(ANVIL_ROOT, "mods", "powerofthree's Papyrus Extender", "Source", "scripts"),
  path.join(STOCK_GAME, "Data", "Source", "Scripts"),
  SKYUI_HEADERS_SOURCE,
];

const ACTIVE_SCRIPTS = [
  "PDV__MainQuest",
  "PDV_Origin",
  "PDV__ManagerQuest",
  "PDV_DeityBase",
  "PDV_Deity_Kyne",
  "PDV_Deity_Talos",
  "PDV_Deity_AuriEl",
  "PDV_Deity_Yffre",
  "PDV_Deity_Zen",
  "PDV_Deity_BaanDar",
  "PDV_EventTypes",
  "PDV_EventBus",
  "PDV_FragmentBridge",
  "PDV_EventSignalActivator",
  "PDV_EventSignalEffect",
  "PDV_PlayerEvents",
  "PDV_ActionRouter",
  "PDV__SM_KillActor",
  "PDV_SurveyDevotionEffect",
  "PDV_MCM",
  "PDV_Substrate_DunmerAncestor",
  "PDV_Substrate_KhajiitLunar",
  "PDV_Substrate_ArgonianHist",
  "PDV_DaedricPath_Boethiah",
  "PDV_DaedricPath_Azura",
  "PDV_DaedricPath_Vaermina",
  "PDV_DaedricPath_Meridia",
  "PDV_DaedricPath_Molag",
  "PDV_DaedricPath_Mephala",
  "PDV_DaedricPath_Malacath",
  "PDV_DaedricPath_Dagon",
  "PDV_DaedricPath_Sheo",
  "PDV_DaedricPath_Namira",
  "PDV_DaedricPath_Sanguine",
  "PDV_DaedricPath_Vile",
  "PDV_DaedricPath_Mora",
  "PDV_DaedricPath_Nocturnal",
  "PDV_DaedricPath_Peryite",
  "PDV_DaedricPath_Hircine",
];

const OPTIONAL_SCRIPTS = [
  "PDV_ReputationTrack",
  "PDV_StateTrack",
  "PDV_SubstrateBase",
  "PDV_SacredPlace",
  "PDV_DaedricPathBase",
  "PDV_CurseState",
];

function main() {
  const args = parseArgs(process.argv.slice(2));
  const environment = checkEnvironment();

  if (args.list) {
    printScriptList(args);
    process.exitCode = environment.ok ? 0 : 1;
    return;
  }

  if (!environment.ok) {
    printEnvironmentFailures(environment.failures, args.json);
    process.exitCode = 1;
    return;
  }

  const targets = selectTargets(args);
  if (!targets.ok) {
    printSelectionError(targets.message, args.json);
    process.exitCode = 2;
    return;
  }

  if (!targets.scripts.length) {
    printNoop(args);
    return;
  }

  if (args.dryRun) {
    printDryRun(targets.scripts, args);
    return;
  }

  const startedAt = Date.now();
  const results = targets.scripts.map((scriptName) => compileScript(scriptName, args, startedAt));
  const compileFailed = results.some((result) => !result.ok);
  let verifyResult = null;

  if (!compileFailed && !args.skipVerify) {
    verifyResult = runVerifier(args);
  }

  printResults(results, verifyResult, args);
  process.exitCode = compileFailed || verifyResult?.failed ? 1 : 0;
}

function parseArgs(argv) {
  const args = {
    all: false,
    allowWarnings: false,
    dryRun: false,
    json: false,
    list: false,
    scripts: [],
    skipVerify: false,
    strictPhase3: false,
    strictPreflight: false,
    strictSkeleton: false,
    strictPatternProving: false,
    strictPhase7: false,
    strictPhase8: false,
    strictPhase9: false,
    strictPhase10: false,
    strictPhase11: false,
    strictPhase12: false,
    strictPhase13: false,
    strictPhase14: false,
    strictPhase15: false,
    strictPhase16: false,
    strictPhase17: false,
    strictPhase18: false,
    strictPhase19: false,
    strictPhase20Roster: false,
    strictPhase20Altmer: false,
    strictPhase20RaceCosting: false,
    strictNord: false,
    strictKhajiit: false,
    strictCommitment: false,
    strictNeglectDecay: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--all") {
      args.all = true;
    } else if (arg === "--allow-warnings") {
      args.allowWarnings = true;
    } else if (arg === "--dry-run") {
      args.dryRun = true;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--list") {
      args.list = true;
    } else if (arg === "--script") {
      const value = argv[index + 1];
      if (!value) {
        usage("Missing value after --script.");
      }
      args.scripts.push(value);
      index += 1;
    } else if (arg.startsWith("--script=")) {
      args.scripts.push(arg.slice("--script=".length));
    } else if (arg === "--skip-verify") {
      args.skipVerify = true;
    } else if (arg === "--strict-phase3") {
      args.strictPhase3 = true;
    } else if (arg === "--strict-preflight") {
      args.strictPreflight = true;
    } else if (arg === "--strict-skeleton") {
      args.strictSkeleton = true;
    } else if (arg === "--strict-pattern-proving") {
      args.strictPatternProving = true;
    } else if (arg === "--strict-phase7") {
      args.strictPhase7 = true;
    } else if (arg === "--strict-phase8") {
      args.strictPhase8 = true;
    } else if (arg === "--strict-phase9") {
      args.strictPhase9 = true;
    } else if (arg === "--strict-phase10") {
      args.strictPhase10 = true;
    } else if (arg === "--strict-phase11") {
      args.strictPhase11 = true;
    } else if (arg === "--strict-phase12") {
      args.strictPhase12 = true;
    } else if (arg === "--strict-phase13") {
      args.strictPhase13 = true;
    } else if (arg === "--strict-phase14") {
      args.strictPhase14 = true;
    } else if (arg === "--strict-phase15") {
      args.strictPhase15 = true;
    } else if (arg === "--strict-phase16") {
      args.strictPhase16 = true;
    } else if (arg === "--strict-phase17") {
      args.strictPhase17 = true;
    } else if (arg === "--strict-phase18") {
      args.strictPhase18 = true;
    } else if (arg === "--strict-phase19") {
      args.strictPhase19 = true;
    } else if (arg === "--strict-phase20-roster" || arg === "--strict-phase21-roster") {
      args.strictPhase20Roster = true;
    } else if (arg === "--strict-phase20-altmer") {
      args.strictPhase20Altmer = true;
    } else if (arg === "--strict-phase20-race-costing") {
      args.strictPhase20RaceCosting = true;
    } else if (arg === "--strict-nord") {
      args.strictNord = true;
      args.strictPhase18 = true;
    } else if (arg === "--strict-khajiit") {
      args.strictKhajiit = true;
    } else if (arg === "--strict-commitment") {
      args.strictCommitment = true;
    } else if (arg === "--strict-neglect-decay") {
      args.strictNeglectDecay = true;
    } else if (arg === "-h" || arg === "--help") {
      usage(null, 0);
    } else {
      usage(`Unknown argument: ${arg}`);
    }
  }

  if (args.all && args.scripts.length) {
    usage("Use either --all or --script, not both.");
  }

  return args;
}

function usage(error = null, exitCode = 2) {
  const text = [
    "Usage: node tools/pdv_compile.mjs [options]",
    "",
    "Default: compile active PDV scripts whose .pex output is missing or older than source.",
    "",
    "Options:",
    "  --all                 Compile all active PDV scripts.",
    "  --script NAME         Compile one script; repeat for multiple scripts.",
    "  --dry-run             Print compiler commands without running them.",
    "  --list                Show known scripts and stale/fresh status.",
    "  --json                Print machine-readable output.",
    "  --skip-verify         Do not run tools/pdv_verify.mjs after successful compile.",
    "  --strict-phase3       Pass --strict-phase3 to the verifier.",
    "  --strict-preflight    Pass --strict-preflight to the verifier.",
    "  --strict-skeleton     Pass --strict-skeleton to the verifier.",
    "  --strict-pattern-proving Pass --strict-pattern-proving to the verifier.",
    "  --strict-phase7       Pass --strict-phase7 to the verifier.",
    "  --strict-phase8       Pass --strict-phase8 to the verifier.",
    "  --strict-phase9       Pass --strict-phase9 to the verifier.",
    "  --strict-phase10      Pass --strict-phase10 to the verifier.",
    "  --strict-phase11      Pass --strict-phase11 to the verifier.",
    "  --strict-phase12      Pass --strict-phase12 to the verifier.",
    "  --strict-phase13      Pass --strict-phase13 to the verifier.",
    "  --strict-phase14      Pass --strict-phase14 to the verifier.",
    "  --strict-phase15      Pass --strict-phase15 to the verifier.",
    "  --strict-phase16      Pass --strict-phase16 to the verifier.",
    "  --strict-phase17      Pass --strict-phase17 to the verifier.",
    "  --strict-phase18      Pass --strict-phase18 to the verifier.",
    "  --strict-phase19      Pass --strict-phase19 to the verifier.",
    "  --strict-phase20-roster       Pass --strict-phase20-roster to the verifier.",
    "  --strict-phase20-altmer       Pass --strict-phase20-altmer to the verifier.",
    "  --strict-phase20-race-costing Pass --strict-phase20-race-costing to the verifier.",
    "  --strict-nord         Pass --strict-nord to the verifier.",
    "  --strict-khajiit      Pass --strict-khajiit to the verifier.",
    "  --strict-commitment   Pass --strict-commitment to the verifier.",
    "  --strict-neglect-decay Pass --strict-neglect-decay to the verifier.",
    "  --allow-warnings      Do not convert Papyrus warnings into failures.",
  ].join("\n");

  if (error) {
    console.error(error);
    console.error();
  }
  console.log(text);
  process.exit(exitCode);
}

function checkEnvironment() {
  const required = {
    "PapyrusCompiler.exe": COMPILER_EXE,
    "PapyrusAssembler.exe": ASSEMBLER_EXE,
    "TESV_Papyrus_Flags.flg": FLAGS_FILE,
    "Devotion source": DEVOTION_SOURCE,
    "Devotion output": DEVOTION_PEX,
    "PDV verifier": VERIFIER,
  };
  for (const [label, filePath] of IMPORT_ROOTS.map((root, index) => [`Import root ${index + 1}`, root])) {
    required[label] = filePath;
  }

  const failures = Object.entries(required)
    .filter(([, filePath]) => !exists(filePath))
    .map(([label, filePath]) => ({ label, path: filePath }));

  // Probe write access on the .pex output folder. PapyrusCompiler emits a
  // cryptic ".pas is denied" OS error when it cannot write its temp files;
  // a pre-flight write probe catches sandbox restrictions before the compiler
  // spawns and surfaces a clear actionable message instead.
  if (failures.length === 0) {
    const probe = path.join(DEVOTION_PEX, ".pdv_write_probe");
    try {
      fs.writeFileSync(probe, "");
      fs.unlinkSync(probe);
    } catch {
      failures.push({
        label: "Devotion output (write access)",
        path: DEVOTION_PEX,
        detail:
          "Cannot write to the Devotion Scripts folder. " +
          "PapyrusCompiler will fail with a '.pas is denied' error. " +
          "Rerun outside the Codex sandbox so the compiler can write its temp files.",
      });
    }
  }

  return {
    ok: failures.length === 0,
    failures,
  };
}

function selectTargets(args) {
  const known = [...ACTIVE_SCRIPTS, ...OPTIONAL_SCRIPTS];

  if (args.scripts.length) {
    const scripts = [...new Set(args.scripts.map(normalizeScriptName))];
    const missing = scripts.filter((scriptName) => !exists(scriptPath(scriptName)));
    if (missing.length) {
      return {
        ok: false,
        message: `Missing source script(s): ${missing.map((name) => `${name}.psc`).join(", ")}`,
      };
    }
    return { ok: true, scripts };
  }

  if (args.all) {
    return { ok: true, scripts: known.filter((scriptName) => exists(scriptPath(scriptName))) };
  }

  return {
    ok: true,
    scripts: known.filter((scriptName) => scriptStatus(scriptName).stale),
  };
}

function compileScript(scriptName, args, startedAt) {
  const source = scriptPath(scriptName);
  const output = pexPath(scriptName);
  const compilerArgs = compilerArguments(scriptName);

  const result = spawnSync(COMPILER_EXE, compilerArgs, {
    cwd: path.dirname(COMPILER_EXE),
    encoding: "utf8",
    timeout: 120_000,
    windowsHide: true,
  });

  const stdout = result.stdout || "";
  const stderr = result.stderr || "";
  const combined = [stdout.trim(), stderr.trim()].filter(Boolean).join("\n");
  const warnings = hasCompilerProblems(combined, "warning");
  const errors = hasCompilerProblems(combined, "error");
  const pexFresh = exists(output) && mtimeMs(output) >= mtimeMs(source);
  const straySkyuiOutputs = findStraySkyuiOutputs();
  const processOk = !result.error && result.status === 0;
  const warningsOk = args.allowWarnings || !warnings;
  const ok = processOk && !errors && warningsOk && pexFresh && straySkyuiOutputs.length === 0;

  return {
    script: scriptName,
    source,
    output,
    command: formatCommand(COMPILER_EXE, compilerArgs),
    status: result.status,
    signal: result.signal,
    error: result.error?.message || null,
    warnings,
    errors,
    pexFresh,
    straySkyuiOutputs,
    outputUpdatedDuringRun: exists(output) && mtimeMs(output) >= startedAt - 1_000,
    ok,
    stdout: stdout.trim(),
    stderr: stderr.trim(),
  };
}

function runVerifier(args) {
  const verifierArgs = [VERIFIER];
  if (args.strictPhase3) {
    verifierArgs.push("--strict-phase3");
  }
  if (args.strictPreflight) {
    verifierArgs.push("--strict-preflight");
  }
  if (args.strictSkeleton) {
    verifierArgs.push("--strict-skeleton");
  }
  if (args.strictPatternProving) {
    verifierArgs.push("--strict-pattern-proving");
  }
  if (args.strictPhase7) {
    verifierArgs.push("--strict-phase7");
  }
  if (args.strictPhase8) {
    verifierArgs.push("--strict-phase8");
  }
  if (args.strictPhase9) {
    verifierArgs.push("--strict-phase9");
  }
  if (args.strictPhase10) {
    verifierArgs.push("--strict-phase10");
  }
  if (args.strictPhase11) {
    verifierArgs.push("--strict-phase11");
  }
  if (args.strictPhase12) {
    verifierArgs.push("--strict-phase12");
  }
  if (args.strictPhase13) {
    verifierArgs.push("--strict-phase13");
  }
  if (args.strictPhase14) {
    verifierArgs.push("--strict-phase14");
  }
  if (args.strictPhase15) {
    verifierArgs.push("--strict-phase15");
  }
  if (args.strictPhase16) {
    verifierArgs.push("--strict-phase16");
  }
  if (args.strictPhase17) {
    verifierArgs.push("--strict-phase17");
  }
  if (args.strictPhase18) {
    verifierArgs.push("--strict-phase18");
  }
  if (args.strictPhase19) {
    verifierArgs.push("--strict-phase19");
  }
  if (args.strictPhase20Roster) {
    verifierArgs.push("--strict-phase20-roster");
  }
  if (args.strictPhase20Altmer) {
    verifierArgs.push("--strict-phase20-altmer");
  }
  if (args.strictPhase20RaceCosting) {
    verifierArgs.push("--strict-phase20-race-costing");
  }
  if (args.strictNord) {
    verifierArgs.push("--strict-nord");
  }
  if (args.strictKhajiit) {
    verifierArgs.push("--strict-khajiit");
  }
  if (args.strictCommitment) {
    verifierArgs.push("--strict-commitment");
  }
  if (args.strictNeglectDecay) {
    verifierArgs.push("--strict-neglect-decay");
  }

  const result = spawnSync(process.execPath, verifierArgs, {
    cwd: PROJECT_ROOT,
    encoding: "utf8",
    timeout: 120_000,
    windowsHide: true,
  });

  return {
    command: formatCommand(process.execPath, verifierArgs),
    status: result.status,
    failed: Boolean(result.error) || result.status !== 0,
    error: result.error?.message || null,
    stdout: (result.stdout || "").trim(),
    stderr: (result.stderr || "").trim(),
  };
}

function compilerArguments(scriptName) {
  return [
    scriptPath(scriptName),
    `-f=${FLAGS_FILE}`,
    `-i=${IMPORT_ROOTS.join(";")}`,
    `-o=${DEVOTION_PEX}`,
  ];
}

function printScriptList(args) {
  const scripts = [...ACTIVE_SCRIPTS, ...OPTIONAL_SCRIPTS];
  const rows = scripts.map((scriptName) => scriptStatus(scriptName));

  if (args.json) {
    console.log(JSON.stringify({ scripts: rows }, null, 2));
    return;
  }

  console.log("PDV compiler script status");
  for (const row of rows) {
    const state = row.sourceExists ? (row.pexExists ? (row.stale ? "stale" : "fresh") : "missing pex") : "missing source";
    console.log(`${row.script}: ${state}`);
    console.log(`  source: ${row.source}`);
    console.log(`  output: ${row.output}`);
  }
}

function printEnvironmentFailures(failures, json) {
  if (json) {
    console.log(JSON.stringify({ ok: false, failures }, null, 2));
    return;
  }

  console.error("PDV compiler environment check failed:");
  for (const failure of failures) {
    console.error(`[FAIL] ${failure.label}: ${failure.path}`);
    if (failure.detail) {
      console.error(`       ${failure.detail}`);
    }
  }
}

function printSelectionError(message, json) {
  if (json) {
    console.log(JSON.stringify({ ok: false, error: message }, null, 2));
    return;
  }
  console.error(message);
}

function printNoop(args) {
  const payload = {
    ok: true,
    compiled: [],
    message: "No stale active PDV scripts found.",
  };
  if (args.json) {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }
  console.log("PDV compiler");
  console.log(payload.message);
  console.log("Use --all for a full rebuild, or --script NAME for a targeted compile.");
}

function printDryRun(scripts, args) {
  const commands = scripts.map((scriptName) => ({
    script: scriptName,
    command: formatCommand(COMPILER_EXE, compilerArguments(scriptName)),
  }));

  if (args.json) {
    console.log(JSON.stringify({ dry_run: true, commands }, null, 2));
    return;
  }

  console.log("PDV compiler dry run");
  for (const entry of commands) {
    console.log(`[${entry.script}] ${entry.command}`);
  }
}

function printResults(results, verifyResult, args) {
  const payload = {
    ok: results.every((result) => result.ok) && !verifyResult?.failed,
    compiled: results,
    verifier: verifyResult,
  };

  if (args.json) {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }

  console.log("PDV compiler");
  for (const result of results) {
    const status = result.ok ? "PASS" : "FAIL";
    console.log(`[${status}] ${result.script}`);
    if (result.error) {
      console.log(`  error: ${result.error}`);
    }
    if (result.warnings && !args.allowWarnings) {
      console.log("  warning policy: warnings are treated as failures");
    }
    if (!result.pexFresh) {
      console.log(`  output is missing or stale: ${result.output}`);
    }
    if (result.straySkyuiOutputs.length) {
      console.log(`  stray SkyUI outputs: ${result.straySkyuiOutputs.join(", ")}`);
    }
    const output = [result.stdout, result.stderr].filter(Boolean).join("\n");
    if (output) {
      console.log(indent(output, "  "));
    }
  }

  if (verifyResult) {
    console.log();
    console.log(`[${verifyResult.failed ? "FAIL" : "PASS"}] verifier`);
    if (verifyResult.error) {
      console.log(`  error: ${verifyResult.error}`);
    }
    if (verifyResult.stdout) {
      console.log(indent(verifyResult.stdout, "  "));
    }
    if (verifyResult.stderr) {
      console.log(indent(verifyResult.stderr, "  "));
    }
  }
}

function scriptStatus(scriptName) {
  const source = scriptPath(scriptName);
  const output = pexPath(scriptName);
  const sourceExists = exists(source);
  const pexExists = exists(output);
  return {
    script: scriptName,
    source,
    output,
    sourceExists,
    pexExists,
    stale: sourceExists && (!pexExists || mtimeMs(output) < mtimeMs(source)),
  };
}

function normalizeScriptName(value) {
  const base = path.basename(value, path.extname(value));
  return base.trim();
}

function scriptPath(scriptName) {
  return path.join(DEVOTION_SOURCE, `${scriptName}.psc`);
}

function pexPath(scriptName) {
  return path.join(DEVOTION_PEX, `${scriptName}.pex`);
}

function exists(filePath) {
  return fs.existsSync(filePath);
}

function mtimeMs(filePath) {
  return fs.statSync(filePath).mtimeMs;
}

function formatCommand(command, args) {
  return [command, ...args].map(quoteArg).join(" ");
}

function findStraySkyuiOutputs() {
  if (!exists(DEVOTION_PEX)) {
    return [];
  }

  return fs.readdirSync(DEVOTION_PEX)
    .filter((name) => /^SKI_.*\.pex$/i.test(name))
    .sort();
}

function hasCompilerProblems(output, kind) {
  const countPattern = new RegExp(`([1-9]\\d*)\\s+${kind}\\(s\\)`, "i");
  if (countPattern.test(output)) {
    return true;
  }

  const diagnosticPattern = new RegExp(`\\b${kind}\\b\\s*:`, "i");
  return diagnosticPattern.test(output);
}

function quoteArg(value) {
  const text = String(value);
  if (!text || /[\s"`]/.test(text)) {
    return `"${text.replace(/"/g, '\\"')}"`;
  }
  return text;
}

function indent(text, prefix) {
  return text
    .split(/\r?\n/)
    .map((line) => `${prefix}${line}`)
    .join("\n");
}

main();
