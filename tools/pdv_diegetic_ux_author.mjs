#!/usr/bin/env node
/*
 * Repo-only diegetic UX authoring planner.
 *
 * This intentionally does not write Devotion.esp, live source,
 * live PEX, or SEQ. It turns PDV_DiegeticUX.manifest.json into an ordered
 * source/CK/VMAD/record/proof plan for later manual or helper-backed live work.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DEFAULT_MANIFEST = path.join(PROJECT_ROOT, "references", "authoring", "PDV_DiegeticUX.manifest.json");
const EXPECTED_SCHEMA = "pdv.diegetic_ux.manifest.v1";

main(process.argv.slice(2));

function main(argv) {
  const args = parseArgs(argv);
  if (!args.command || args.help) {
    usage();
  }

  if (!["plan", "status"].includes(args.command)) {
    usage(`Unknown command: ${args.command}`);
  }

  const manifestPath = path.resolve(PROJECT_ROOT, args.manifest || DEFAULT_MANIFEST);
  const manifest = loadManifest(manifestPath);
  const validation = validateManifest(manifest, manifestPath);
  const plan = buildPlan(manifest, manifestPath);
  const payload = {
    schema: "pdv.diegetic_ux.author_plan.v1",
    status: validation.failCount === 0 ? "PASS" : "FAIL",
    mode: "dry-run-only",
    manifest: toRepoPath(manifestPath),
    liveWriteBlocked: true,
    liveWriteBlockedReason: "Planner emits intent only; no ESP/source/PEX/SEQ writes are implemented.",
    validation,
    plan
  };

  if (args.writePlan) {
    writePlan(args.writePlan, payload);
  }

  if (args.command === "status") {
    printStatus(payload);
  } else if (args.json) {
    console.log(JSON.stringify(payload, null, 2));
  } else {
    printPlan(payload);
  }

  process.exit(validation.failCount === 0 ? 0 : 1);
}

function usage(errorMessage = null) {
  if (errorMessage) {
    console.error(errorMessage);
    console.error("");
  }

  console.log([
    "Usage:",
    "  node .\\tools\\pdv_diegetic_ux_author.mjs plan [--json] [--manifest <path>] [--write-plan <path>]",
    "  node .\\tools\\pdv_diegetic_ux_author.mjs status [--json] [--manifest <path>]",
    "Notes:",
    "  - plan/status are read-only.",
    "  - This tool never writes Devotion.esp, live scripts, live PEX, or SEQ.",
    "  - Use the emitted plan as the CK/helper handoff after pdv_diegetic_ux_check passes."
  ].join("\n"));
  process.exit(errorMessage ? 1 : 0);
}

function parseArgs(argv) {
  const args = {
    command: null,
    json: false,
    help: false,
    manifest: null,
    writePlan: null
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!args.command && !arg.startsWith("-")) {
      args.command = arg;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else if (arg === "--manifest") {
      args.manifest = requireNext(argv, ++index, "--manifest");
    } else if (arg.startsWith("--manifest=")) {
      args.manifest = arg.slice("--manifest=".length);
    } else if (arg === "--write-plan") {
      args.writePlan = requireNext(argv, ++index, "--write-plan");
    } else if (arg.startsWith("--write-plan=")) {
      args.writePlan = arg.slice("--write-plan=".length);
    } else {
      usage(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function requireNext(argv, index, name) {
  if (index >= argv.length || argv[index].startsWith("-")) {
    usage(`${name} requires a value.`);
  }
  return argv[index];
}

function loadManifest(manifestPath) {
  if (!fs.existsSync(manifestPath)) {
    throw new Error(`Manifest not found: ${manifestPath}`);
  }
  return JSON.parse(fs.readFileSync(manifestPath, "utf8"));
}

function validateManifest(manifest, manifestPath) {
  const findings = [];
  const add = (status, check, detail) => findings.push({ status, check, detail });
  const pass = (check, detail) => add("PASS", check, detail);
  const fail = (check, detail) => add("FAIL", check, detail);

  if (manifest.schema === EXPECTED_SCHEMA) {
    pass("manifest schema", `Schema is ${EXPECTED_SCHEMA}.`);
  } else {
    fail("manifest schema", `Expected ${EXPECTED_SCHEMA}, got ${manifest.schema || "(missing)"}.`);
  }

  if (manifest.authoringPlanner?.mode === "dry-run-only") {
    pass("planner mode", "Manifest declares dry-run-only planner mode.");
  } else {
    fail("planner mode", "Manifest must declare authoringPlanner.mode = dry-run-only.");
  }

  for (const script of manifest.sourcePromotion?.scripts || []) {
    if (script.scriptName && script.scratch && script.live) {
      pass("source promotion", `${script.scriptName} has scratch and live paths.`);
    } else {
      fail("source promotion", `Incomplete source promotion entry in ${toRepoPath(manifestPath)}.`);
    }
  }

  const quests = manifest.ckWriteContract?.quests || [];
  if (quests.length >= 2) {
    pass("CK quests", `${quests.length} quest shells are declared.`);
  } else {
    fail("CK quests", "Expected at least PDV_DiegeticDeps and PDV_DiegeticDirector quest shells.");
  }

  const directorProperties = manifest.ckWriteContract?.directorProperties || [];
  const d0Properties = directorProperties.filter((property) => property.requiredForD0Live);
  const d1Properties = directorProperties.filter((property) => property.requiredForD1Live);
  if (d0Properties.length >= 8) {
    pass("D0 director properties", `${d0Properties.length} D0 director properties are declared.`);
  } else {
    fail("D0 director properties", "Expected D0 director globals/service/default properties.");
  }
  if (d1Properties.length >= 17) {
    pass("D1 director properties", `${d1Properties.length} D1 director channel properties are declared.`);
  } else {
    fail("D1 director properties", "Expected D1 channel record properties.");
  }

  const d1Records = (manifest.ckWriteContract?.d1Records || []).flatMap((group) => group.editorIds || []);
  const d1PropertyTargets = new Set(d1Properties.filter((property) => property.type === "Object").map((property) => property.value));
  for (const editorId of d1Records) {
    if (d1PropertyTargets.has(editorId)) {
      pass("D1 record property coverage", `${editorId} has a director property target.`);
    } else {
      fail("D1 record property coverage", `${editorId} is listed as a D1 record but has no director property target.`);
    }
  }

  const failCount = findings.filter((finding) => finding.status === "FAIL").length;
  const passCount = findings.filter((finding) => finding.status === "PASS").length;
  return { status: failCount === 0 ? "PASS" : "FAIL", passCount, failCount, findings };
}

function buildPlan(manifest) {
  const steps = [];
  let order = 1;
  const addStep = (phase, kind, summary, detail = {}) => {
    steps.push({ order: order++, phase, kind, summary, ...detail });
  };

  addStep("preflight", "check", "Run diegetic UX source/manifest guardrail.", {
    command: manifest.liveWritePolicy?.sourcePromotionRequiresCleanCheck || "node tools/pdv_diegetic_ux_check.mjs"
  });

  for (const script of manifest.sourcePromotion?.scripts || []) {
    addStep("source", "copy-intent", `Promote ${script.scriptName} source from scratch to live source folder.`, {
      scriptName: script.scriptName,
      from: script.scratch,
      to: script.live,
      mode: script.mode || "copy"
    });
  }

  addStep("compile", "command-intent", "Compile diegetic UX scripts in the live Devotion mod only after source promotion.", {
    command: manifest.liveWritePolicy?.liveCompileRequires
  });

  for (const quest of manifest.ckWriteContract?.quests || []) {
    addStep("ck-d0", "quest-shell", `Create or verify Start Game Enabled quest ${quest.editorId}.`, {
      editorId: quest.editorId,
      script: quest.script,
      startGameEnabled: quest.startGameEnabled,
      runOnce: quest.runOnce,
      properties: quest.properties || []
    });
  }

  for (const property of manifest.ckWriteContract?.managerProperties || []) {
    addStep("ck-d0", "vmad-property", `Wire manager property ${property.property} -> ${property.value}.`, {
      record: property.record,
      script: property.script,
      property: property.property,
      type: property.type,
      value: property.value
    });
  }

  for (const property of manifest.ckWriteContract?.directorProperties || []) {
    const phase = property.requiredForD1Live ? "ck-d1" : "ck-d0";
    addStep(phase, "vmad-property", `Wire director property ${property.name} -> ${property.value}.`, {
      record: "PDV_DiegeticDirector",
      script: "PDV_DiegeticDirector",
      property: property.name,
      type: property.type,
      value: property.value,
      requiredForD0Live: Boolean(property.requiredForD0Live),
      requiredForD1Live: Boolean(property.requiredForD1Live)
    });
  }

  for (const group of manifest.ckWriteContract?.d1Records || []) {
    for (const editorId of group.editorIds || []) {
      addStep("ck-d1", "record-shell", `Create or duplicate placeholder ${group.type} record ${editorId}.`, {
        recordType: group.type,
        editorId
      });
    }
  }

  addStep("seq", "command-intent", "Refresh SEQ after adding Start Game Enabled quests.", {
    command: "node tools/pdv_refresh_seq.mjs --write --json"
  });
  addStep("verify", "command-intent", "Run the standard verifier after CK/ESP/property/SEQ work.", {
    command: "node tools/pdv_verify.mjs --json"
  });
  addStep("smoke-d0", "manual-proof", "Keep D1Enabled false and run a no-behavior-change fresh-start smoke.", {
    expected: "Existing PDV surfaces still work; diegetic director has no visible channel output."
  });
  addStep("smoke-d1", "manual-proof", "Only after D0 passes, enable D1Enabled and run counted QASmoke transition proof.", {
    expected: "Pilot transitions fire each channel once per direction; deps-absent fallback is clean."
  });

  return {
    stepCount: steps.length,
    liveWritePolicy: manifest.liveWritePolicy,
    openLiveGates: manifest.openLiveGates || [],
    steps
  };
}

function writePlan(writePath, payload) {
  const outputPath = path.resolve(PROJECT_ROOT, writePath);
  if (!outputPath.startsWith(PROJECT_ROOT + path.sep)) {
    throw new Error(`Refusing to write outside repo: ${outputPath}`);
  }
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, `${JSON.stringify(payload, null, 2)}\n`);
}

function printStatus(payload) {
  console.log(`${payload.status}: ${payload.plan.stepCount} dry-run authoring steps. Live writes are blocked by design.`);
}

function printPlan(payload) {
  console.log(`Diegetic UX authoring plan (${payload.status})`);
  console.log(`Manifest: ${payload.manifest}`);
  console.log(`Mode: ${payload.mode}`);
  console.log("");
  for (const step of payload.plan.steps) {
    console.log(`${step.order}. [${step.phase}] ${step.summary}`);
  }
}

function toRepoPath(filePath) {
  const relative = path.relative(PROJECT_ROOT, filePath);
  return relative.startsWith("..") ? filePath : relative.replaceAll(path.sep, "/");
}
