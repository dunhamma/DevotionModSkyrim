#!/usr/bin/env node
// Generate a trigger-first optimization ledger for the shipped PDV runtime.
// This audit is deliberately evidence-producing: it never treats static review
// as runtime proof and writes tracked ledger files only when --write is passed.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { hashBytes, hashText, writeTextWithEol } from "./lib/pdv_file_compare.mjs";

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(TOOL_DIR, "..");
const MOD_ROOT = process.env.PDV_MOD_PATH || "D:\\Wabbajack\\modlists\\Anvil\\mods\\Devotion";
const SOURCE_ROOT = path.join(MOD_ROOT, "Scripts", "Source");
const PEX_ROOT = path.join(MOD_ROOT, "Scripts");
const CANDIDATE_SOURCE_ROOT = path.join(REPO_ROOT, "live-source", "Scripts", "Source");
const NATIVE_ROOT = path.join(REPO_ROOT, "native", "DevotionPrismaBridge");
const PRISMA_ROOT = path.join(NATIVE_ROOT, "mod", "PrismaUI", "views", "Devotion");
const DEFAULT_LOG =
  "C:\\Users\\Admin\\Documents\\My Games\\Skyrim Special Edition\\Logs\\Script\\Papyrus.0.log";
const LEDGER_JSON = path.join(
  REPO_ROOT,
  "references",
  "authoring",
  "PDV_ShipOptimizationLedger.json",
);
const LEDGER_MD = path.join(
  REPO_ROOT,
  "references",
  "authoring",
  "PDV_ShipOptimizationLedger.md",
);

function fail(message) {
  console.error(`[FAIL] ${message}`);
  process.exit(1);
}

function sha256(filePath) {
  return hashBytes(filePath).toUpperCase();
}

function normalizedTextSha256(filePath) {
  return hashText(filePath).toUpperCase();
}

function count(source, expression) {
  return [...source.matchAll(expression)].length;
}

function parseArgs(argv) {
  const args = {
    write: false,
    json: false,
    archive: null,
    log: DEFAULT_LOG,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--write") {
      args.write = true;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--archive") {
      args.archive = path.resolve(argv[++index]);
    } else if (arg === "--log") {
      args.log = path.resolve(argv[++index]);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function scriptNames() {
  if (!fs.existsSync(SOURCE_ROOT)) fail(`Live source root is missing: ${SOURCE_ROOT}`);
  return fs
    .readdirSync(SOURCE_ROOT)
    .filter((name) => /^PDV_.*\.psc$/i.test(name))
    .map((name) => path.basename(name, ".psc"))
    .sort();
}

function eventNames(source) {
  return [...source.matchAll(/^\s*Event\s+([A-Za-z0-9_]+)/gim)].map((match) => match[1]);
}

function registrationCounts(source) {
  const registrations = {};
  for (const match of source.matchAll(/\b(RegisterFor[A-Za-z0-9_]+|UnregisterFor[A-Za-z0-9_]+)\s*\(/g)) {
    registrations[match[1]] = (registrations[match[1]] || 0) + 1;
  }
  return registrations;
}

function classifyScript(name, source) {
  if (name === "PDV_PlayerEvents") {
    const bardGuard =
      source.includes('Game.IsPluginInstalled("BecomeABard.esp")') &&
      source.includes('Game.IsPluginInstalled("SkyrimsGotTalent-Bards.esp")');
    const explicitScheduler =
      source.includes("PDV_ORIGIN_NEXT_DUE") &&
      source.includes("PDV_COMBAT_NEXT_DUE") &&
      source.includes("PDV_BARD_NEXT_DUE") &&
      source.includes("Function ArmEarliestDeadline");
    if (!bardGuard) return "broken";
    if (!explicitScheduler) return "suboptimal";
    return "clean";
  }
  if (name === "PDV__ManagerQuest") return "suboptimal";
  return "clean";
}

function scanScript(name) {
  const pscPath = path.join(SOURCE_ROOT, `${name}.psc`);
  const pexPath = path.join(PEX_ROOT, `${name}.pex`);
  const source = fs.readFileSync(pscPath, "utf8");
  const pscStat = fs.statSync(pscPath);
  const pexExists = fs.existsSync(pexPath);
  const pexStat = pexExists ? fs.statSync(pexPath) : null;
  const events = eventNames(source);
  const registrations = registrationCounts(source);
  const metrics = {
    events,
    registrations,
    updateEvents: events.filter((event) => /^OnUpdate/i.test(event)).length,
    waits: count(source, /\bUtility\.Wait(?:GameTime)?\s*\(/g),
    gameGetPlayer: count(source, /\bGame\.GetPlayer\s*\(/g),
    getFormFromFile: count(source, /\bGame\.GetFormFromFile\s*\(/g),
    pluginInstalledChecks: count(source, /\bGame\.IsPluginInstalled\s*\(/g),
    traces: count(source, /\bDebug\.Trace(?:Stack)?\s*\(/g),
    whileLoops: count(source, /^\s*While\b/gim),
    gotoStates: count(source, /\bGoToState\s*\(/g),
    remoteCalls: count(source, /\b[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\s*\(/g),
  };
  const hotScore =
    metrics.updateEvents * 25 +
    Object.entries(registrations)
      .filter(([registration]) => !registration.startsWith("Unregister"))
      .reduce((sum, [, value]) => sum + value * 4, 0) +
    metrics.waits * 4 +
    metrics.gameGetPlayer +
    metrics.getFormFromFile * 3 +
    metrics.whileLoops * 5;

  return {
    script: name,
    classification: classifyScript(name, source),
    trigger: events.length ? events.join(", ") : "function/property-driven; no local Event declaration",
    frequency:
      metrics.updateEvents > 0 || registrations.RegisterForSingleUpdate
        ? "timer/update capable; measure at runtime"
        : "event/call driven",
    externalCallCost: {
      estimatedStaticCallSites: metrics.remoteCalls,
      gameGetPlayer: metrics.gameGetPlayer,
      getFormFromFile: metrics.getFormFromFile,
      traces: metrics.traces,
      waits: metrics.waits,
    },
    metrics,
    hotScore,
    persistenceAndCleanup: {
      hasStateMachine: metrics.gotoStates > 0,
      registerCalls: Object.entries(registrations)
        .filter(([registration]) => !registration.startsWith("Unregister"))
        .reduce((sum, [, value]) => sum + value, 0),
      unregisterCalls: Object.entries(registrations)
        .filter(([registration]) => registration.startsWith("Unregister"))
        .reduce((sum, [, value]) => sum + value, 0),
      cleanupSymmetryNeedsRuntimeReview:
        Object.keys(registrations).some((registration) => registration.startsWith("Register")) &&
        !Object.keys(registrations).some((registration) => registration.startsWith("Unregister")),
    },
    artifact: {
      psc: {
        path: pscPath,
        bytes: pscStat.size,
        mtime: pscStat.mtime.toISOString(),
        sha256: sha256(pscPath),
      },
      pex: pexExists
        ? {
            path: pexPath,
            bytes: pexStat.size,
            mtime: pexStat.mtime.toISOString(),
            sha256: sha256(pexPath),
            fresh: pexStat.mtimeMs >= pscStat.mtimeMs,
          }
        : {
            path: pexPath,
            missing: true,
            fresh: false,
          },
    },
  };
}

function knownFindings(scripts) {
  const playerEvents = scripts.find((script) => script.script === "PDV_PlayerEvents");
  const manager = scripts.find((script) => script.script === "PDV__ManagerQuest");
  const worker = scripts.find((script) => script.script === "PDV_QuestReactionWorker");
  const candidatePlayerEvents = fs.readFileSync(
    path.join(CANDIDATE_SOURCE_ROOT, "PDV_PlayerEvents.psc"),
    "utf8",
  );
  const candidateManager = fs.readFileSync(
    path.join(CANDIDATE_SOURCE_ROOT, "PDV__ManagerQuest.psc"),
    "utf8",
  );
  const bardGuarded =
    candidatePlayerEvents.includes('Game.IsPluginInstalled("BecomeABard.esp")') &&
    candidatePlayerEvents.includes('Game.IsPluginInstalled("SkyrimsGotTalent-Bards.esp")');
  const explicitScheduler = candidatePlayerEvents.includes("Function ArmEarliestDeadline");
  const managerInstrumented = candidateManager.includes("[PDV] OPT_PROFILE manager60");
  return [
    {
      id: "PDV-OPT-PAP-001",
      classification: bardGuarded ? "clean" : "broken",
      scope: "PDV_PlayerEvents optional bard integration",
      trigger: "load/reinitialization resolves optional bard forms",
      frequency: "once per load or explicit reinitialization",
      externalCallCost: "up to six native GetFormFromFile calls; absent plugins emit Papyrus errors",
      evidence: `${playerEvents?.metrics.getFormFromFile ?? 0} GetFormFromFile call sites and ${
        playerEvents?.metrics.pluginInstalledChecks ?? 0
      } IsPluginInstalled guards in the 1.0.3 live baseline; candidate guards both optional plugins`,
      fix:
        "Check Game.IsPluginInstalled once per optional plugin per load, then resolve and cache its forms only when installed.",
      releaseLane: "1.0.4",
      requiredProof:
        "Fresh-process Papyrus log with neither bard mod installed contains zero missing-plugin errors; installed-mod routes still pass.",
      status: bardGuarded ? "implemented; runtime proof open" : "confirmed defect",
    },
    {
      id: "PDV-OPT-PAP-002",
      classification: explicitScheduler ? "clean" : "suboptimal",
      scope: "PDV_PlayerEvents origin/combat/bard scheduler",
      trigger: "origin retry, combat polling, or bard polling requests a deadline",
      frequency: "shared OnUpdate lane; combat may request one-second cadence",
      externalCallCost: "multiple callers re-arm a single native update registration",
      evidence: `${playerEvents?.metrics.registrations.RegisterForSingleUpdate ?? 0} single-update registrations in current source`,
      fix:
        "Persist one next-due timestamp per lane and register once for the earliest outstanding deadline.",
      releaseLane: "1.0.4",
      requiredProof:
        "Origin, combat, and bard lanes each fire at their deadline under overlap; no lane is starved or polled early.",
      status: explicitScheduler ? "implemented; runtime overlap proof open" : "implementation pending",
    },
    {
      id: "PDV-OPT-PAP-003",
      classification: "suboptimal",
      scope: "PDV__ManagerQuest permanent one-second chain",
      trigger: "OnUpdate",
      frequency: "one second while manager is running",
      externalCallCost: `${manager?.externalCallCost.estimatedStaticCallSites ?? 0} static cross/native-style call sites in the script; runtime call distribution unknown`,
      evidence:
        "Reconciliation lanes are already tiered, but targeted runtime call counts and ten-minute idle profile are not yet captured.",
      fix:
        "Instrument first. Retain one-second work only for measured responsiveness; move reconciliation/self-heal work only when the change reduces targeted external calls by at least 20 percent.",
      releaseLane: "1.0.4 measured tranche",
      requiredProof:
        "Before/after ten-minute idle and deterministic active profiles plus behavior regression run.",
      status: managerInstrumented
        ? "instrumented in candidate; cadence unchanged; profiling gate open"
        : "not changed; profiling gate open",
    },
    {
      id: "PDV-OPT-PAP-004",
      classification: "clean",
      scope: "PDV_QuestReactionWorker bounded queue",
      trigger: "queued quest-reaction jobs",
      frequency: "0.1-second worker only while runnable work is pending",
      externalCallCost: `${worker?.externalCallCost.estimatedStaticCallSites ?? 0} static cross/native-style call sites`,
      evidence: "Static performance audit passes; no current runtime FIFO markers exist in the inspected log.",
      fix:
        "Keep the bounded worker. Compact no-op/unreachable cells at ingress only if controlled runtime jobs exceed two seconds or delivery is incomplete.",
      releaseLane: "retain in 1.0.4; redesign only on runtime failure",
      requiredProof:
        "Four controlled jobs complete FIFO with matching toast/Book entries, no toast later than two seconds, then organic MQ106 routing.",
      status: "static clean; runtime proof open",
    },
    {
      id: "PDV-OPT-PKG-001",
      classification: "clean",
      scope: "release payload and compiled freshness",
      trigger: "release preflight/package/verify",
      frequency: "every release candidate",
      externalCallCost: "filesystem hashes, timestamps, archive reopen, ANAM checker, and hash-bound houseCARL proof",
      evidence: "Exact 216-entry manifest and 96 PSC/PEX pair gate are implemented.",
      fix: "Fail on missing or unexpected payload entries and any stale compiled/native/UI dependency.",
      releaseLane: "1.0.3 tooling",
      requiredProof: "Preflight passes, archive reopens, exact manifest comparison passes, checksum published.",
      status: "implemented",
    },
    {
      id: "PDV-OPT-VMAD-001",
      classification: "suboptimal",
      scope: "Devotion.esp VMAD attachment/property inventory",
      trigger: "scripted record or quest alias initializes",
      frequency: "record/load dependent",
      externalCallCost: "not a performance cost by itself; unbound object properties can silently no-op",
      evidence:
        "Direct houseCARL validation scanned 183 scripted records: 552 unbound Auto properties, 0 bound-but-null, 0 unverifiable attachments.",
      fix:
        "Triage each unbound property as intentionally runtime-filled/inherited/optional or defective. Do not mass-bind, remove scripts, or reduce VMAD in 1.0.x.",
      releaseLane: "audit now; verified defects in 1.0.4; structural retirement in 1.1",
      requiredProof:
        "Per-property source-use and runtime/record contract review; repeat houseCARL attachment count after any record edit.",
      status: "generated audit queue; no VMAD change in this tranche",
    },
    {
      id: "PDV-OPT-NATIVE-001",
      classification: "clean",
      scope: "DevotionPrismaBridge native bridge",
      trigger: "Papyrus call, SKSE lifecycle message, or input event",
      frequency: "event-driven; no native recurring idle callback",
      externalCallCost: "bounded mutex-protected payload copy/deferred overlay and Prisma JS callback",
      evidence:
        "Static inventory confirms twelve native Papyrus functions, recursive mutex, input sink, no serialization state, and no hook/trampoline.",
      fix: "Preserve the twelve-function surface and current payload schemas.",
      releaseLane: "1.0.3 audit",
      requiredProof: "Fresh native build plus Prisma lifecycle/failure-path runtime smoke.",
      status: "static clean; runtime proof open",
    },
    {
      id: "PDV-OPT-UI-001",
      classification: "clean",
      scope: "Prisma UI idle behavior",
      trigger: "native payload or user input",
      frequency: "event-driven",
      externalCallCost: "no recurring idle interval",
      evidence: "Static scan checks listener registration, payload parsing, bounded toast/overlay growth, and recurring timers.",
      fix: "Retain current event-driven model.",
      releaseLane: "1.0.3 audit",
      requiredProof: "Prisma panel, overlays, toasts, and Book of Days pass in a fresh process.",
      status: "static clean; runtime proof open",
    },
    {
      id: "PDV-OPT-ASSET-001",
      classification: "suboptimal",
      scope: "Prisma local font formats",
      trigger: "embedded browser font load",
      frequency: "view load",
      externalCallCost: "duplicate local TTF and WOFF2 payload plus network fallback",
      evidence: "Both local formats are shipped; WOFF2 behavior in the embedded Prisma browser is not yet runtime-proven.",
      fix:
        "If embedded Prisma renders WOFF2 correctly, retain WOFF2 only and remove TTF/network fallback; otherwise retain TTF only.",
      releaseLane: "1.0.4 after manual proof",
      requiredProof: "Embedded Prisma browser visual/font-load proof, not desktop Chromium alone.",
      status: "deferred; no asset removed",
    },
    {
      id: "PDV-OPT-ASSET-002",
      classification: "clean",
      scope: "Dunmer ancestral urn textures",
      trigger: "urn mesh renders",
      frequency: "scene dependent",
      externalCallCost: "two loose GPU texture loads",
      evidence:
        "2048-square DDS files are already DXT1/DXT5 compressed with full mip chains; houseCARL resolves Devotion as sole provider.",
      fix: "Keep both textures unchanged.",
      releaseLane: "all lanes",
      requiredProof: "No additional optimization proof required; preserve visual smoke.",
      status: "retained",
    },
  ];
}

function logEvidence(logPath) {
  if (!fs.existsSync(logPath)) {
    return {
      path: logPath,
      missing: true,
      proofBoundary: "No runtime claim.",
    };
  }
  const text = fs.readFileSync(logPath, "utf8");
  const lines = text.split(/\r?\n/);
  const errorLines = lines.filter((line) => /\berror:/i.test(line));
  const warningLines = lines.filter((line) => /\bwarning:/i.test(line));
  const pdvLines = lines.filter((line) => /\bPDV_/i.test(line));
  const bardMissing = lines.filter(
    (line) =>
      /GetFormFromFile/i.test(line) &&
      /(BecomeABard\.esp|SkyrimsGotTalent-Bards\.esp)/i.test(line),
  );
  return {
    path: logPath,
    bytes: fs.statSync(logPath).size,
    mtime: fs.statSync(logPath).mtime.toISOString(),
    sha256: sha256(logPath),
    counts: {
      errors: errorLines.length,
      warnings: warningLines.length,
      pdvTaggedLines: pdvLines.length,
      optionalBardMissingPluginErrors: bardMissing.length,
      questReactionCompleteMarkers: count(text, /QR_QUEUE[^\r\n]*COMPLETE/g),
      questReactionOverflows: count(text, /QR_QUEUE[^\r\n]*OVERFLOW/g),
      broadScopeAborts: count(text, /BROAD_SCOPE_ABORT/g),
      vmFreezes: count(text, /VM is freezing/g),
    },
    proofBoundary:
      "Observed log snapshot only; it is not a controlled idle/active acceptance run unless the operator records that scenario.",
  };
}

function archiveEvidence(archivePath) {
  if (!archivePath) {
    return { provided: false, proofBoundary: "No archive baseline supplied to this run." };
  }
  if (!fs.existsSync(archivePath)) fail(`Archive baseline not found: ${archivePath}`);
  return {
    provided: true,
    path: archivePath,
    bytes: fs.statSync(archivePath).size,
    mtime: fs.statSync(archivePath).mtime.toISOString(),
    sha256: sha256(archivePath),
  };
}

function candidateSourceEvidence(names) {
  const changed = [];
  for (const name of names) {
    const livePath = path.join(SOURCE_ROOT, `${name}.psc`);
    const candidatePath = path.join(CANDIDATE_SOURCE_ROOT, `${name}.psc`);
    if (!fs.existsSync(candidatePath)) continue;
    const liveHash = normalizedTextSha256(livePath);
    const candidateHash = normalizedTextSha256(candidatePath);
    if (liveHash !== candidateHash) {
      changed.push({
        script: name,
        liveSha256: liveHash,
        candidateSha256: candidateHash,
        candidateMtime: fs.statSync(candidatePath).mtime.toISOString(),
      });
    }
  }
  return {
    sourceRoot: CANDIDATE_SOURCE_ROOT,
    changedScriptCount: changed.length,
    changedScripts: changed,
    deployment: "not copied into the live 1.0.3 smoke mod",
  };
}

function nativeEvidence() {
  const mainPath = path.join(NATIVE_ROOT, "src", "main.cpp");
  const source = fs.readFileSync(mainPath, "utf8");
  const registered = [
    ...source.matchAll(/RegisterFunction\s*(?:<[^>]*>)?\s*\(\s*"(\w+)"/g),
  ].map((match) => match[1]);
  return {
    registeredPapyrusFunctions: [...new Set(registered)].sort(),
    registeredPapyrusFunctionCount: new Set(registered).size,
    recursiveMutex: source.includes("std::recursive_mutex"),
    inputEventSink: source.includes("BSTEventSink<RE::InputEvent"),
    coSaveState: /SerializationInterface|SKSE::Serialization/i.test(source),
    trampolineOrHook: /Trampoline|write_branch|write_call|REL::Relocation/i.test(source),
  };
}

function uiEvidence() {
  const appPath = path.join(PRISMA_ROOT, "app.js");
  const source = fs.readFileSync(appPath, "utf8");
  return {
    appBytes: fs.statSync(appPath).size,
    sha256: sha256(appPath),
    setIntervalCalls: count(source, /\bsetInterval\s*\(/g),
    setTimeoutCalls: count(source, /\bsetTimeout\s*\(/g),
    requestAnimationFrameCalls: count(source, /\brequestAnimationFrame\s*\(/g),
    addEventListenerCalls: count(source, /\.addEventListener\s*\(/g),
    jsonParseCalls: count(source, /\bJSON\.parse\s*\(/g),
    boundedGrowthTokens: {
      toastRemoval: /remove\(\)|removeChild\(/.test(source),
      arraySpliceOrShift: /\.splice\(|\.shift\(/.test(source),
    },
  };
}

function markdown(ledger) {
  const classificationCounts = ledger.scripts.reduce((counts, script) => {
    counts[script.classification] = (counts[script.classification] || 0) + 1;
    return counts;
  }, {});
  const hotScripts = [...ledger.scripts].sort((a, b) => b.hotScore - a.hotScore).slice(0, 20);
  const lines = [
    "# PDV Ship Optimization Ledger",
    "",
    `Generated: ${ledger.generatedAt}`,
    "",
    "This ledger is trigger-first. Static/readback evidence does not close runtime or manual proof.",
    "",
    "## Baseline",
    "",
    `- Live script pairs: ${ledger.summary.scriptCount}`,
    `- Script classifications: broken ${classificationCounts.broken || 0}; suboptimal ${
      classificationCounts.suboptimal || 0
    }; clean ${classificationCounts.clean || 0}`,
    `- Archive: ${
      ledger.archive.provided
        ? `${ledger.archive.bytes} bytes; SHA-256 ${ledger.archive.sha256}`
        : "not supplied"
    }`,
    `- Papyrus log snapshot: ${
      ledger.log.missing
        ? "missing"
        : `${ledger.log.counts.errors} error lines; ${ledger.log.counts.warnings} warning lines; ${
            ledger.log.counts.vmFreezes
          } VM-freeze markers; ${
            ledger.log.counts.optionalBardMissingPluginErrors
          } optional-bard missing-plugin errors`
    }`,
    "- Log boundary: this is an uncontrolled snapshot and cannot close fresh-process runtime acceptance.",
    "",
    "## Findings",
    "",
    "| ID | Class | Scope | Trigger/frequency | Fix/lane | Required proof | Status |",
    "| --- | --- | --- | --- | --- | --- | --- |",
    ...ledger.findings.map(
      (finding) =>
        `| ${finding.id} | ${finding.classification} | ${finding.scope} | ${
          finding.trigger
        }; ${finding.frequency} | ${finding.fix} (${finding.releaseLane}) | ${
          finding.requiredProof
        } | ${finding.status} |`,
    ),
    "",
    "## Highest static hot scores",
    "",
    "| Script | Class | Score | Updates | Registrations | Waits | GetPlayer | GetFormFromFile | Trace |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...hotScripts.map(
      (script) =>
        `| ${script.script} | ${script.classification} | ${script.hotScore} | ${
          script.metrics.updateEvents
        } | ${Object.values(script.metrics.registrations).reduce((a, b) => a + b, 0)} | ${
          script.metrics.waits
        } | ${script.metrics.gameGetPlayer} | ${script.metrics.getFormFromFile} | ${
          script.metrics.traces
        } |`,
    ),
    "",
    "## Proof debt",
    "",
    ...ledger.proofDebt.map((item) => `- ${item}`),
    "",
    "The JSON sibling contains every script's trigger, registration, external-call-site counts, PSC/PEX hashes, timestamps, and freshness result.",
    "",
  ];
  return `${lines.join("\n")}\n`;
}

const args = parseArgs(process.argv.slice(2));
const scripts = scriptNames().map(scanScript);
if (scripts.length !== 96) fail(`Expected 96 live PDV scripts, found ${scripts.length}.`);
const stale = scripts.filter((script) => !script.artifact.pex.fresh);
const ledger = {
  schemaVersion: 1,
  generatedAt: new Date().toISOString(),
  releaseLanes: {
    "1.0.3": "release tooling and evidence only while smoke packet is open",
    "1.0.4": "low-risk, save-compatible runtime optimizations",
    "1.1": "script removal, decomposition, VMAD reduction, and migration-sensitive work",
  },
  summary: {
    scriptCount: scripts.length,
    staleScriptPairCount: stale.length,
    sourceAvailabilityPromise: "all 96 PSC files remain in the player archive",
  },
  archive: archiveEvidence(args.archive),
  candidate: candidateSourceEvidence(scripts.map((script) => script.script)),
  log: logEvidence(args.log),
  native: nativeEvidence(),
  ui: uiEvidence(),
  findings: knownFindings(scripts),
  scripts,
  proofDebt: [
    "Controlled ten-minute idle PapyrusProfiler or stack-profile call counts.",
    "Deterministic active profile covering load, combat, crafting, shrine, MCM, Prisma, and quest reaction.",
    "Fresh-process absent-bard-mod error proof after the 1.0.4 source fix is compiled and deployed.",
    "PlayerEvents overlapping origin/combat/bard deadline runtime proof.",
    "Four-job quest-reaction FIFO/two-second proof plus organic MQ106.",
    "Embedded Prisma WOFF2 render proof before removing either font format.",
    "Full save/load, MCM, shrine, piety, Book of Days, Prisma, and uninstall-preparation regression.",
  ],
};

if (args.write) {
  writeTextWithEol(LEDGER_JSON, `${JSON.stringify(ledger, null, 2)}\n`, "lf");
  writeTextWithEol(LEDGER_MD, markdown(ledger), "lf");
  console.log(`[PASS] Wrote ${LEDGER_JSON}`);
  console.log(`[PASS] Wrote ${LEDGER_MD}`);
}

if (args.json) {
  console.log(JSON.stringify(ledger, null, 2));
} else {
  console.log(
    `[PASS] Audited ${scripts.length} scripts; ${stale.length} stale PSC/PEX pairs; ` +
      `${ledger.findings.length} ledger findings.`,
  );
  const classes = ledger.findings.reduce((result, finding) => {
    result[finding.classification] = (result[finding.classification] || 0) + 1;
    return result;
  }, {});
  console.log(
    `  findings: broken ${classes.broken || 0}, suboptimal ${classes.suboptimal || 0}, clean ${
      classes.clean || 0
    }`,
  );
  console.log(
    `  runtime/manual proof debt remains open: ${ledger.proofDebt.length} acceptance surfaces`,
  );
}
