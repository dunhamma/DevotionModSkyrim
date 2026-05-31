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
import { createPlan } from "./planner.mjs";
import { executeApply } from "./executor.mjs";
import { analyzeMixedCkWriterSequence, hydratePlanFromReadback } from "./orchestrator.mjs";
import { verifyManifest } from "./verifier.mjs";
import { buildStrictGatePhase, summarizePhaseStatuses } from "./release-status.mjs";
import { buildLoadPluginSetCommand } from "./ck-command-packet.mjs";
import {
  createCompileRunner,
  createLiveMcpContext,
  createPatchWriter,
  createPdvVerifierRunner,
  createReadbackCollector,
  prepareLiveProfile,
  refreshLiveRecordIndex
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
    if (command === "ck-from-report") {
      await ckFromReportCommand(positional, options);
      return;
    }
    if (command === "finalize-report") {
      await finalizeReportCommand(positional, options);
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
  const reportsDir = path.resolve(options.reportsDir || live.profile.reportsDir || "reports");

  const compileConfig = compilerConfigFromProfile(live.profile);
  const verifierConfig = verifierConfigFromProfile(live.profile);
  const report = await handleAuthoringRequest({
    action: "run",
    manifest,
    profile: live.profile,
    strict: Boolean(options.strict),
    executeLive: true,
    allowManualPackets: Boolean(options.allowManualPackets),
    allowUnprovenCk: Boolean(options.allowUnprovenCk),
    patchOptions: {
      output: options.output,
      author: options.author,
      eslFlag: options.esl === undefined ? true : options.esl
    },
    adapters: {
      patchWriter: createPatchWriter(context, {
        projectRoot: PROJECT_ROOT,
        reportsDir,
        generatedPlugin: manifest.output,
        sourcePlugin: manifest.sourcePlugin
      }),
      readbackCollector: createReadbackCollector(context),
      ckAdapter: async (packet) => runCkIpcPacket(packet, {
        mode: options.ckMode || "named-pipe",
        pipeName: options.ckPipe,
        queueDir: options.ckQueueDir,
        timeoutMs: options.ckTimeoutMs
      }),
      compileRunner: compileConfig.enabled ? createCompileRunner(PROJECT_ROOT, compileConfig.args, {
        cwd: compileConfig.cwd || verifierConfig.cwd
      }) : null,
      verifierRunner: verifierConfig.enabled ? createPdvVerifierRunner(PROJECT_ROOT, verifierConfig.args, {
        cwd: verifierConfig.cwd
      }) : null
    }
  });

  report.phases.unshift(...live.preflight);
  report.status = summarizePhaseStatuses(report.phases);

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

  const verifierConfig = verifierConfigFromProfile(profile);
  const promotion = await handleAuthoringRequest({
    action: "promote",
    profile,
    runReport,
    approved: Boolean(options.approved),
    allowSourceMutation: Boolean(options.allowSourceMutation),
    sourcePath: options.sourcePath,
    generatedPath: options.generatedPath,
    mergeOutputPath: options.mergeOutputPath,
    backupRoot: options.backupRoot,
    forceCkFinalization: Boolean(options.forceCkFinalization),
    adapters: {
      backupRunner: mergeRunner ? async () => ({ status: "DEFERRED_TO_MERGE_RUNNER" }) : null,
      mergeRunner,
      ckFinalizer: async (mergeRequest) => {
        const sourcePlugin = profile.sourcePlugin;
        const candidatePlugin = options.mergeOutputPath || profile.sourcePlugin;
        const generatedPlugin = runReport.manifest?.output || profile.defaultOutput;
        const requiredPlugins = [...new Set([sourcePlugin, generatedPlugin, candidatePlugin].filter(Boolean))];
        const packet = {
          schema: "creation-authoring.ck-command-packet.v1",
          project: profile.modId,
          game: profile.game,
          sourcePlugin,
          generatedPlugin: candidatePlugin,
          failClosed: true,
          commands: [
            { op: "openProject", profile: profile.modId, game: profile.game },
            buildLoadPluginSetCommand({
              requiredPlugins,
              sourcePlugin,
              generatedPlugin: candidatePlugin,
              activePlugin: candidatePlugin,
              intendedSaveTarget: candidatePlugin,
              sourcePluginNotActive: candidatePlugin !== sourcePlugin
            }),
            { op: "postUiSaveCommand", plugin: candidatePlugin }
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
      postMergeVerifier: createPdvVerifierRunner(PROJECT_ROOT, verifierConfig.args, {
        cwd: verifierConfig.cwd
      })
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

function compilerConfigFromProfile(profile) {
  const connector = profile.resourceConnectors.find((item) => item.type === "papyrus-compiler" && Array.isArray(item.args));
  if (!connector) {
    return {
      enabled: false,
      args: [],
      cwd: null
    };
  }
  return {
    enabled: true,
    args: connector.args,
    cwd: connector.cwd || null
  };
}

async function ckFromReportCommand(positional, options) {
  const reportPath = positional[0];
  if (!reportPath) {
    usage(1, "ck-from-report requires a run report path.");
  }
  const report = readDocument(reportPath).document;
  const ckPhaseIndex = report.phases.findIndex((phase) => phase.phase === "ck-apply");
  if (ckPhaseIndex < 0 || !report.phases[ckPhaseIndex].packet) {
    throw new Error("Run report does not contain a ck-apply packet.");
  }

  const packet = report.phases[ckPhaseIndex].packet;
  const adapterResult = await runCkIpcPacket(packet, {
    mode: options.ckMode || "named-pipe",
    pipeName: options.ckPipe,
    queueDir: options.ckQueueDir,
    timeoutMs: options.ckTimeoutMs
  });
  const status = normalizeCkAdapterStatus(adapterResult);
  report.phases[ckPhaseIndex] = {
    ...report.phases[ckPhaseIndex],
    status,
    message: status === "PASS" ? "CK adapter completed." : "CK adapter did not complete all commands safely.",
    adapterResult
  };
  report.status = summarizePhaseStatuses(report.phases);
  report.finishedAt = new Date().toISOString();

  const outputPath = options.reportPath || reportPath;
  report.reportPath = writeJson(outputPath, report);
  print(report, options, () => {
    return [
      `Status: ${report.status}`,
      `CK status: ${status}`,
      `Run report: ${report.reportPath}`
    ].join("\n") + "\n";
  });
}

function passedCkDuplicateTargets(report = {}) {
  const ckPhase = (report.phases || []).find((phase) => phase.phase === "ck-apply" && phase.status === "PASS");
  return (ckPhase?.adapterResult?.commands || [])
    .filter((command) => command.op === "duplicateCreateRecord" && command.status === "PASS")
    .map((command) => {
      return command.evidence?.createdRecord?.record?.editorId ||
        command.evidence?.requested?.targetEditorId ||
        command.evidence?.requested?.createdEditorId ||
        command.evidence?.requested?.target ||
        null;
    })
    .filter(Boolean);
}

async function finalizeReportCommand(positional, options) {
  const reportPath = positional[0];
  if (!reportPath) {
    usage(1, "finalize-report requires a run report path.");
  }
  if (!options.profile) {
    usage(1, "finalize-report requires --profile <path>.");
  }
  const manifestPath = positional[1];
  if (!manifestPath) {
    usage(1, "finalize-report requires a manifest path after the report path.");
  }

  const baseProfile = loadProfile(options.profile);
  const manifest = loadManifest(manifestPath, baseProfile);
  const context = createLiveMcpContext({ mcpUrl: options.mcpUrl });
  const live = await prepareLiveProfile(manifest, baseProfile, context);
  const plan = createPlan(manifest, live.profile, {
    allowUnprovenCk: Boolean(options.allowUnprovenCk)
  });
  const report = readDocument(reportPath).document;
  const sequencing = analyzeMixedCkWriterSequence(plan, {
    completedIdentityTargets: passedCkDuplicateTargets(report),
    includeNonReadyIdentity: true
  });
  const compileConfig = compilerConfigFromProfile(live.profile);
  const verifierConfig = verifierConfigFromProfile(live.profile);
  const reportsDir = path.resolve(options.reportsDir || live.profile.reportsDir || "reports");

  const preserved = report.phases.filter((phase) => {
    return ![
      "mo2-ping",
      "mo2-record-index",
      "mo2-plugin-state",
      "compile",
      "post-ck-record-index",
      "post-ck-readback",
      "post-ck-identity-gate",
      "payload-apply",
      "post-payload-record-index",
      "readback-collect",
      "verify",
      "project-verifier",
      "strict-gate"
    ].includes(phase.phase);
  });
  const phases = [
    ...live.preflight,
    ...preserved
  ];

  if (sequencing.delayedWriterOperationIds.size) {
    const ckPhase = phases.find((phase) => phase.phase === "ck-apply");
    if (!ckPhase || ckPhase.status !== "PASS") {
      phases.push({
        phase: "post-ck-identity-gate",
        status: "UNSAFE_BLOCKED",
        message: "Payload writer operations are blocked until the preserved CK phase is PASS."
      });
    } else {
      phases.push(await refreshLiveRecordIndex(context, "post-ck-record-index"));
      const postCkReadback = await createReadbackCollector(context)({ manifest, profile: live.profile, plan, phases });
      phases.push({
        phase: "post-ck-readback",
        status: "PASS",
        message: "Readback collector completed after CK duplicate/save."
      });
      const identityManifest = {
        ...manifest,
        operations: manifest.operations.filter((operation) => sequencing.identityOperationIds.has(operation.id))
      };
      const identityVerify = verifyManifest(identityManifest, live.profile, postCkReadback);
      const identityStatus = identityVerify.summary.FAIL ? "FAIL" : identityVerify.summary.TODO ? "TODO" : "PASS";
      phases.push({
        phase: "post-ck-identity-gate",
        status: identityStatus,
        message: identityStatus === "PASS"
          ? "Generated duplicate identity is proven for payload writer sequencing."
          : "Generated duplicate identity is not proven; payload writer is blocked.",
        report: identityVerify
      });
      if (identityStatus === "PASS") {
        const payloadPlan = hydratePlanFromReadback(plan, postCkReadback, sequencing.delayedWriterOperationIds);
        const payloadApply = await executeApply(payloadPlan, {
          patchOptions: {
            eslFlag: options.esl === undefined ? true : options.esl
          },
          patchWriter: createPatchWriter(context, {
            projectRoot: PROJECT_ROOT,
            reportsDir,
            generatedPlugin: manifest.output,
            sourcePlugin: manifest.sourcePlugin
          }),
          phaseName: "payload-apply",
          operationFilter: (item) => sequencing.delayedWriterOperationIds.has(item.operation.id)
        });
        phases.push(payloadApply);
        if (payloadApply.status === "PASS") {
          phases.push(await refreshLiveRecordIndex(context, "post-payload-record-index"));
        }
      }
    }
  }

  if (compileConfig.enabled) {
    phases.push(await createCompileRunner(PROJECT_ROOT, compileConfig.args, {
    cwd: compileConfig.cwd || verifierConfig.cwd
    })({ manifest, profile: live.profile, plan }));
  } else {
    phases.push({
      phase: "compile",
      status: "SKIPPED",
      message: "No papyrus-compiler connector is configured."
    });
  }

  const readback = await createReadbackCollector(context)({ manifest, profile: live.profile, plan, phases });
  phases.push({
    phase: "readback-collect",
    status: "PASS",
    message: "Readback collector completed."
  });
  const verifyReport = verifyManifest(manifest, live.profile, readback);
  phases.push({
    phase: "verify",
    status: verifyReport.summary.FAIL ? "FAIL" : verifyReport.summary.TODO ? "TODO" : "PASS",
    report: verifyReport
  });
  if (verifierConfig.enabled) {
    phases.push(await createPdvVerifierRunner(PROJECT_ROOT, verifierConfig.args, {
    cwd: verifierConfig.cwd
    })({ profile: live.profile }));
  } else {
    phases.push({
      phase: "project-verifier",
      status: "SKIPPED",
      message: "No pdv-verifier connector is configured."
    });
  }
  if (options.strict) {
    phases.push(buildStrictGatePhase(phases, report.manualPackets || []));
  }

  report.phases = phases;
  report.status = summarizePhaseStatuses(phases);
  report.finishedAt = new Date().toISOString();
  report.planSummary = plan.summary;
  const outputPath = options.reportPath || reportPath;
  report.reportPath = writeJson(outputPath, report);
  const review = writeReviewReports(report, { reportsDir });
  report.reviewArtifacts = review;
  writeJson(outputPath, report);

  print(report, options, () => {
    return [
      `Status: ${report.status}`,
      `Run report: ${report.reportPath}`,
      `Review markdown: ${review.markdownPath}`,
      `Review JSON: ${review.jsonPath}`
    ].join("\n") + "\n";
  });
}

function verifierConfigFromProfile(profile) {
  const connector = profile.resourceConnectors.find((item) => item.type === "pdv-verifier" && Array.isArray(item.args));
  if (!connector) {
    return {
      enabled: false,
      args: [],
      cwd: null
    };
  }
  return {
    enabled: true,
    args: connector.args,
    cwd: connector.cwd || null
  };
}

function normalizeCkAdapterStatus(result) {
  if (!result) {
    return "FAIL";
  }
  if (["PASS", "SKIPPED", "REQUESTED", "UNSAFE_BLOCKED"].includes(result.status)) {
    return result.status;
  }
  return "FAIL";
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
    else if (arg === "--allow-unproven-ck") options.allowUnprovenCk = true;
    else if (arg === "--approved") options.approved = true;
    else if (arg === "--force-ck-finalization") options.forceCkFinalization = true;
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
  node ./src/live-runner.mjs run <manifest.json> --profile <profile.json> [--strict] [--allow-manual-packets] [--allow-unproven-ck] [--json]
  node ./src/live-runner.mjs promote <run-report.json> --profile <profile.json> --approved --merge-runner <csproj> --source-path <esp> --generated-path <esp> --merge-output-path <esp> [--force-ck-finalization] [--json]
`);
  process.exit(exitCode);
}
