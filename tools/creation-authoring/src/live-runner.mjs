#!/usr/bin/env node
import path from "node:path";
import { fileURLToPath } from "node:url";
import { loadManifest } from "./manifest.mjs";
import { loadProfile } from "./profile.mjs";
import { readDocument, writeJson } from "./io.mjs";
import { handleAuthoringRequest } from "./service.mjs";
import { runLocalMergeRunner } from "./merge-runner-adapter.mjs";
import { runCkIpcPacket } from "./ck-ipc-adapter.mjs";
import { writeReviewReports } from "./review-report.mjs";
import {
  createCompileRunner,
  createLiveMcpContext,
  createPatchWriter,
  createPdvVerifierRunner,
  createReadbackCollector,
  prepareLiveProfile
} from "./live-mcp-adapters.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..", "..", "..");

await main(process.argv.slice(2));

async function main(argv) {
  try {
    const { command, positional, options } = parseArgs(argv);
    if (!command || options.help) {
      usage(0);
    }
    if (command === "run" || command === "generate") {
      await runCommand(command, positional, options);
      return;
    }
    if (command === "promote") {
      await promoteCommand(positional, options);
      return;
    }
    usage(1, `Unknown live-runner command: ${command}`);
  } catch (error) {
    console.error(`${error.name || "Error"}: ${error.message}`);
    process.exitCode = 1;
  }
}

async function runCommand(command, positional, options) {
  const manifestPath = positional[0];
  if (!manifestPath) {
    usage(1, `${command} requires a manifest path.`);
  }
  if (!options.profile) {
    usage(1, `${command} requires --profile <path>.`);
  }

  const baseProfile = loadProfile(options.profile);
  const manifest = loadManifest(manifestPath, baseProfile);
  const context = createLiveMcpContext({ mcpUrl: options.mcpUrl });
  const live = await prepareLiveProfile(manifest, baseProfile, context);

  const compileArgs = compilerArgsFromProfile(live.profile);
  const verifierArgs = verifierArgsFromProfile(live.profile);
  const report = await handleAuthoringRequest({
    action: "run",
    manifest,
    profile: live.profile,
    strict: Boolean(options.strict),
    executeLive: true,
    allowManualPackets: Boolean(options.allowManualPackets),
    patchOptions: {
      output: options.output,
      author: options.author,
      eslFlag: options.esl === undefined ? true : options.esl
    },
    adapters: {
      patchWriter: createPatchWriter(context),
      readbackCollector: createReadbackCollector(context),
      ckAdapter: async (packet) => runCkIpcPacket(packet, {
        mode: options.ckMode || "named-pipe",
        pipeName: options.ckPipe,
        queueDir: options.ckQueueDir,
        timeoutMs: options.ckTimeoutMs
      }),
      compileRunner: createCompileRunner(PROJECT_ROOT, compileArgs),
      verifierRunner: createPdvVerifierRunner(PROJECT_ROOT, verifierArgs)
    }
  });

  report.phases.unshift(...live.preflight);
  report.status = summarizeReport(report.phases);

  const reportsDir = path.resolve(options.reportsDir || live.profile.reportsDir || "reports");
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const reportPath = options.reportPath || path.join(reportsDir, `${manifest.project}-${timestamp}.run-report.json`);
  report.reportPath = writeJson(reportPath, report);
  const review = writeReviewReports(report, { reportsDir });
  report.reviewArtifacts = review;
  writeJson(reportPath, report);

  print(report, options, () => {
    return [
      `Status: ${report.status}`,
      `Run report: ${report.reportPath}`,
      `Review markdown: ${review.markdownPath}`,
      `Review JSON: ${review.jsonPath}`
    ].join("\n") + "\n";
  });
}

async function promoteCommand(positional, options) {
  const reportPath = positional[0];
  if (!reportPath) {
    usage(1, "promote requires a run report path.");
  }
  if (!options.profile) {
    usage(1, "promote requires --profile <path>.");
  }

  const profile = loadProfile(options.profile);
  const runReport = readDocument(reportPath).document;
  const context = createLiveMcpContext({ mcpUrl: options.mcpUrl });
  const mergeRunner = options.mergeRunner ? async (mergeRequest, runnerContext) => {
    return runLocalMergeRunner(mergeRequest, runnerContext, {
      runnerProject: options.mergeRunner,
      sourcePath: options.sourcePath,
      generatedPath: options.generatedPath,
      outputPath: options.mergeOutputPath,
      backupRoot: options.backupRoot,
      approved: Boolean(options.approved),
      dryRun: Boolean(options.dryRun)
    });
  } : null;

  const promotion = await handleAuthoringRequest({
    action: "promote",
    profile,
    runReport,
    approved: Boolean(options.approved),
    adapters: {
      backupRunner: mergeRunner ? async () => ({ status: "DEFERRED_TO_MERGE_RUNNER" }) : null,
      mergeRunner,
      ckFinalizer: async (mergeRequest) => {
        const packet = {
          schema: "creation-authoring.ck-command-packet.v1",
          project: profile.modId,
          game: profile.game,
          sourcePlugin: profile.sourcePlugin,
          generatedPlugin: runReport.manifest?.output || profile.defaultOutput,
          failClosed: true,
          commands: [
            { op: "openProject", profile: profile.modId, game: profile.game },
            { op: "loadPlugin", plugin: options.mergeOutputPath || profile.sourcePlugin, active: true },
            { op: "savePlugin", plugin: options.mergeOutputPath || profile.sourcePlugin }
          ],
          verifierExpectations: mergeRequest.operations.flatMap((operation) => operation.verifierExpectations || [])
        };
        return runCkIpcPacket(packet, {
          mode: options.ckMode || "named-pipe",
          pipeName: options.ckPipe,
          queueDir: options.ckQueueDir,
          timeoutMs: options.ckTimeoutMs
        });
      },
      postMergeVerifier: createPdvVerifierRunner(PROJECT_ROOT, verifierArgsFromProfile(profile))
    }
  });

  const reportsDir = path.resolve(options.reportsDir || profile.reportsDir || "reports");
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const promotionPath = options.reportPath || path.join(reportsDir, `${profile.modId}-${timestamp}.promotion-report.json`);
  promotion.reportPath = writeJson(promotionPath, promotion);

  print(promotion, options, () => {
    return [
      `Status: ${promotion.status}`,
      `Promotion report: ${promotion.reportPath}`
    ].join("\n") + "\n";
  });
}

function compilerArgsFromProfile(profile) {
  const connector = profile.resourceConnectors.find((item) => item.type === "papyrus-compiler" && Array.isArray(item.args));
  return connector?.args || ["pdv_compile.mjs"];
}

function verifierArgsFromProfile(profile) {
  const connector = profile.resourceConnectors.find((item) => item.type === "pdv-verifier" && Array.isArray(item.args));
  return connector?.args || ["pdv_verify.mjs", "--strict-phase9"];
}

function summarizeReport(phases) {
  if (phases.some((phase) => phase.status === "FAIL" || phase.status === "UNSAFE_BLOCKED")) {
    return "FAIL";
  }
  if (phases.some((phase) => phase.status === "REQUESTED")) {
    return "REQUESTED";
  }
  if (phases.some((phase) => phase.status === "TODO" || phase.status === "MANUAL")) {
    return "TODO";
  }
  return "PASS";
}

function parseArgs(argv) {
  const command = argv[0]?.startsWith("-") ? null : argv[0];
  const positional = [];
  const options = {};
  for (let index = command ? 1 : 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--json") options.json = true;
    else if (arg === "--help" || arg === "-h") options.help = true;
    else if (arg === "--profile") options.profile = requireNext(argv, ++index, arg);
    else if (arg.startsWith("--profile=")) options.profile = arg.slice("--profile=".length);
    else if (arg === "--strict") options.strict = true;
    else if (arg === "--allow-manual-packets") options.allowManualPackets = true;
    else if (arg === "--approved") options.approved = true;
    else if (arg === "--dry-run") options.dryRun = true;
    else if (arg === "--mcp-url") options.mcpUrl = requireNext(argv, ++index, arg);
    else if (arg.startsWith("--mcp-url=")) options.mcpUrl = arg.slice("--mcp-url=".length);
    else if (arg === "--ck-mode") options.ckMode = requireNext(argv, ++index, arg);
    else if (arg === "--ck-pipe") options.ckPipe = requireNext(argv, ++index, arg);
    else if (arg === "--ck-queue-dir") options.ckQueueDir = requireNext(argv, ++index, arg);
    else if (arg === "--ck-timeout-ms") options.ckTimeoutMs = Number(requireNext(argv, ++index, arg));
    else if (arg === "--output") options.output = requireNext(argv, ++index, arg);
    else if (arg === "--author") options.author = requireNext(argv, ++index, arg);
    else if (arg === "--no-esl") options.esl = false;
    else if (arg === "--reports-dir") options.reportsDir = requireNext(argv, ++index, arg);
    else if (arg === "--report-path") options.reportPath = requireNext(argv, ++index, arg);
    else if (arg === "--merge-runner") options.mergeRunner = requireNext(argv, ++index, arg);
    else if (arg === "--source-path") options.sourcePath = requireNext(argv, ++index, arg);
    else if (arg === "--generated-path") options.generatedPath = requireNext(argv, ++index, arg);
    else if (arg === "--merge-output-path") options.mergeOutputPath = requireNext(argv, ++index, arg);
    else if (arg === "--backup-root") options.backupRoot = requireNext(argv, ++index, arg);
    else if (arg.startsWith("-")) usage(1, `Unknown option: ${arg}`);
    else positional.push(arg);
  }
  return { command, positional, options };
}

function requireNext(argv, index, option) {
  if (!argv[index]) {
    usage(1, `${option} requires a value.`);
  }
  return argv[index];
}

function print(value, options, formatter) {
  if (options.json) {
    console.log(JSON.stringify(value, null, 2));
  } else {
    process.stdout.write(formatter());
  }
}

function usage(exitCode, message = null) {
  if (message) {
    console.error(message);
  }
  process.stdout.write(`Usage:
  node ./src/live-runner.mjs run <manifest.json> --profile <profile.json> [--strict] [--allow-manual-packets] [--json]
  node ./src/live-runner.mjs promote <run-report.json> --profile <profile.json> --approved --merge-runner <csproj> --source-path <esp> --generated-path <esp> --merge-output-path <esp> [--json]
`);
  process.exit(exitCode);
}
