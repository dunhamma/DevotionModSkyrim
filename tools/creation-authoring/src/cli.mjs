#!/usr/bin/env node
import { createCapabilityRegistry } from "./capabilities.mjs";
import { loadManifest } from "./manifest.mjs";
import { loadProfile } from "./profile.mjs";
import { readDocument, maybeWriteJson } from "./io.mjs";
import { createPlan } from "./planner.mjs";
import { buildPatchRequest } from "./patch-request.mjs";
import { verifyManifest } from "./verifier.mjs";
import { executeCkApply } from "./executor.mjs";
import { runPipeline } from "./orchestrator.mjs";
import { migratePdvAuthorManifest } from "./pdv-migration.mjs";
import { promoteRunReport } from "./promotion.mjs";
import { analyzeDrift } from "./drift.mjs";
import { runLocalMergeRunner } from "./merge-runner-adapter.mjs";
import { formatManualPackets, formatPlan, formatVerify } from "./report.mjs";

await main(process.argv.slice(2));

async function main(argv) {
  try {
    const { command, positional, options } = parseArgs(argv);
    if (!command || options.help) {
      usage(0);
    }

    if (command === "explain") {
      const registry = createCapabilityRegistry();
      const explanation = registry.explain(positional[0]);
      print(explanation, options, () => JSON.stringify(explanation, null, 2));
      return;
    }

    if (command === "migrate-pdv") {
      const sourcePath = positional[0];
      if (!sourcePath) {
        usage(1, "migrate-pdv requires a PDV manifest path.");
      }
      const profile = options.profile ? loadProfile(options.profile) : null;
      const sourceManifest = readDocument(sourcePath).document;
      const migrated = migratePdvAuthorManifest(sourceManifest, profile);
      maybeWriteJson(options.outputFile, migrated);
      print(migrated, options, () => JSON.stringify(migrated, null, 2) + "\n");
      return;
    }

    if (command === "promote") {
      const reportPath = positional[0];
      if (!reportPath) {
        usage(1, "promote requires a run report path.");
      }
      if (!options.profile) {
        usage(1, "promote requires --profile <path>.");
      }
      const profile = loadProfile(options.profile);
      const runReport = readDocument(reportPath).document;
      const mergeRunner = options.mergeRunner ? async (mergeRequest, context) => {
        return runLocalMergeRunner(mergeRequest, context, {
          runnerProject: options.mergeRunner,
          sourcePath: options.sourcePath,
          generatedPath: options.generatedPath,
          outputPath: options.mergeOutputPath,
          backupRoot: options.backupRoot,
          approved: Boolean(options.approved),
          dryRun: Boolean(options.dryRun)
        });
      } : null;
      const report = await promoteRunReport(runReport, profile, {
        approved: Boolean(options.approved),
        allowSourceMutation: Boolean(options.allowSourceMutation),
        reportPath: options.reportPath,
        backupRunner: mergeRunner ? async () => ({
          status: "DEFERRED_TO_MERGE_RUNNER",
          message: "The local merge runner performs the timestamped backup immediately before writing output."
        }) : null,
        mergeRunner
      });
      print(report, options, () => formatPromotion(report));
      return;
    }

    if (command === "generate") {
      options.executeLive = true;
      options.writeReport = options.writeReport ?? true;
    }

    if (!["plan", "apply", "ck-apply", "verify", "manual-packet", "run", "generate", "drift"].includes(command)) {
      usage(1, `Unknown command: ${command}`);
    }

    const manifestPath = positional[0];
    if (!manifestPath) {
      usage(1, `${command} requires a manifest path.`);
    }
    if (!options.profile) {
      usage(1, `${command} requires --profile <path>.`);
    }

    const profile = loadProfile(options.profile);
    const manifest = loadManifest(manifestPath, profile);
    const plan = createPlan(manifest, profile);

    if (command === "plan") {
      print(plan, options, () => formatPlan(plan));
      return;
    }

    if (command === "manual-packet") {
      const packets = plan.operations.filter((item) => item.manualPacket).map((item) => item.manualPacket);
      const result = {
        schema: "creation-authoring.manual-packets.v1",
        manifest: plan.manifest,
        packets
      };
      print(result, options, () => formatManualPackets(packets));
      return;
    }

    if (command === "apply") {
      const patchRequest = buildPatchRequest(plan, {
        output: options.output,
        author: options.author,
        eslFlag: options.esl === undefined ? true : options.esl
      });
      const result = {
        schema: "creation-authoring.apply-request.v1",
        plan,
        patchRequest,
        note: "This v1 executor emits a deterministic patch request. A host MCP adapter should pass it to the selected plugin writer."
      };
      const written = maybeWriteJson(options.emitPatchRequest, patchRequest);
      if (written) {
        result.writtenPatchRequest = written;
      }
      print(result, options, () => {
        const lines = [formatPlan(plan).trimEnd(), "", `Patch records: ${patchRequest.records.length}`];
        if (written) {
          lines.push(`Patch request written: ${written}`);
        }
        return `${lines.join("\n")}\n`;
      });
      return;
    }

    if (command === "ck-apply") {
      const result = await executeCkApply(plan);
      print(result, options, () => JSON.stringify(result, null, 2) + "\n");
      return;
    }

    if (command === "verify") {
      const readback = options.readback ? readDocument(options.readback).document : null;
      const report = verifyManifest(manifest, profile, readback);
      print(report, options, () => formatVerify(report));
      return;
    }

    if (command === "drift") {
      const readback = options.readback ? readDocument(options.readback).document : null;
      const report = analyzeDrift(manifest, profile, readback);
      print(report, options, () => JSON.stringify(report, null, 2) + "\n");
      return;
    }

    if (command === "run" || command === "generate") {
      const readback = options.readback ? readDocument(options.readback).document : null;
      const report = await runPipeline(manifest, profile, {
        allowManualPackets: Boolean(options.allowManualPackets),
        strict: Boolean(options.strict),
        executeLive: Boolean(options.executeLive),
        readback,
        writeReport: Boolean(options.writeReport),
        reportPath: options.reportPath,
        patchOptions: {
          output: options.output,
          author: options.author,
          eslFlag: options.esl === undefined ? true : options.esl
        }
      });
      print(report, options, () => formatRun(report));
    }
  } catch (error) {
    console.error(`${error.name || "Error"}: ${error.message}`);
    if (error.details && Object.keys(error.details).length) {
      console.error(JSON.stringify(error.details, null, 2));
    }
    process.exitCode = 1;
  }
}

function parseArgs(argv) {
  const positional = [];
  const options = {};
  const command = argv[0];

  for (let index = 1; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--json") {
      options.json = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else if (arg === "--profile") {
      options.profile = requireNext(argv, ++index, "--profile");
    } else if (arg.startsWith("--profile=")) {
      options.profile = arg.slice("--profile=".length);
    } else if (arg === "--readback") {
      options.readback = requireNext(argv, ++index, "--readback");
    } else if (arg.startsWith("--readback=")) {
      options.readback = arg.slice("--readback=".length);
    } else if (arg === "--emit-patch-request") {
      options.emitPatchRequest = requireNext(argv, ++index, "--emit-patch-request");
    } else if (arg.startsWith("--emit-patch-request=")) {
      options.emitPatchRequest = arg.slice("--emit-patch-request=".length);
    } else if (arg === "--output") {
      options.output = requireNext(argv, ++index, "--output");
    } else if (arg.startsWith("--output=")) {
      options.output = arg.slice("--output=".length);
    } else if (arg === "--output-file") {
      options.outputFile = requireNext(argv, ++index, "--output-file");
    } else if (arg.startsWith("--output-file=")) {
      options.outputFile = arg.slice("--output-file=".length);
    } else if (arg === "--author") {
      options.author = requireNext(argv, ++index, "--author");
    } else if (arg.startsWith("--author=")) {
      options.author = arg.slice("--author=".length);
    } else if (arg === "--no-esl") {
      options.esl = false;
    } else if (arg === "--allow-manual-packets") {
      options.allowManualPackets = true;
    } else if (arg === "--strict") {
      options.strict = true;
    } else if (arg === "--write-report") {
      options.writeReport = true;
    } else if (arg === "--execute-live") {
      options.executeLive = true;
    } else if (arg === "--approved") {
      options.approved = true;
    } else if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--merge-runner") {
      options.mergeRunner = requireNext(argv, ++index, "--merge-runner");
    } else if (arg.startsWith("--merge-runner=")) {
      options.mergeRunner = arg.slice("--merge-runner=".length);
    } else if (arg === "--source-path") {
      options.sourcePath = requireNext(argv, ++index, "--source-path");
    } else if (arg.startsWith("--source-path=")) {
      options.sourcePath = arg.slice("--source-path=".length);
    } else if (arg === "--generated-path") {
      options.generatedPath = requireNext(argv, ++index, "--generated-path");
    } else if (arg.startsWith("--generated-path=")) {
      options.generatedPath = arg.slice("--generated-path=".length);
    } else if (arg === "--merge-output-path") {
      options.mergeOutputPath = requireNext(argv, ++index, "--merge-output-path");
    } else if (arg.startsWith("--merge-output-path=")) {
      options.mergeOutputPath = arg.slice("--merge-output-path=".length);
    } else if (arg === "--backup-root") {
      options.backupRoot = requireNext(argv, ++index, "--backup-root");
    } else if (arg.startsWith("--backup-root=")) {
      options.backupRoot = arg.slice("--backup-root=".length);
    } else if (arg === "--allow-source-mutation") {
      options.allowSourceMutation = true;
    } else if (arg === "--report-path") {
      options.reportPath = requireNext(argv, ++index, "--report-path");
    } else if (arg.startsWith("--report-path=")) {
      options.reportPath = arg.slice("--report-path=".length);
    } else if (arg.startsWith("-")) {
      usage(1, `Unknown option: ${arg}`);
    } else {
      positional.push(arg);
    }
  }

  return { command, positional, options };
}

function formatRun(report) {
  const lines = [];
  lines.push(`Status: ${report.status}`);
  lines.push(`Project: ${report.manifest.project}`);
  lines.push(`Plan: ${report.planSummary.ready} ready, ${report.planSummary.manual} manual, ${report.planSummary.abort} abort`);
  for (const phase of report.phases) {
    lines.push(`- [${phase.status}] ${phase.phase}${phase.message ? `: ${phase.message}` : ""}`);
  }
  if (report.reportPath) {
    lines.push(`Report: ${report.reportPath}`);
  }
  return `${lines.join("\n")}\n`;
}

function formatPromotion(report) {
  const lines = [];
  lines.push(`Status: ${report.status}`);
  lines.push(`Source plugin: ${report.sourcePlugin}`);
  lines.push(`Generated plugin: ${report.generatedPlugin}`);
  for (const phase of report.phases) {
    lines.push(`- [${phase.status}] ${phase.phase}${phase.message ? `: ${phase.message}` : ""}`);
    for (const blocker of phase.gates?.blockers || []) {
      lines.push(`  blocker: ${blocker}`);
    }
  }
  if (report.reportPath) {
    lines.push(`Report: ${report.reportPath}`);
  }
  return `${lines.join("\n")}\n`;
}

function requireNext(argv, index, optionName) {
  if (!argv[index]) {
    usage(1, `${optionName} requires a value.`);
  }
  return argv[index];
}

function print(value, options, textFormatter) {
  if (options.json) {
    console.log(JSON.stringify(value, null, 2));
  } else {
    process.stdout.write(textFormatter());
  }
}

function usage(exitCode, message = null) {
  if (message) {
    console.error(message);
  }
  process.stdout.write(`Usage:
  creation-authoring plan <manifest.json> --profile <profile.json> [--json]
  creation-authoring apply <manifest.json> --profile <profile.json> [--emit-patch-request <path>] [--json]
  creation-authoring ck-apply <manifest.json> --profile <profile.json> [--json]
  creation-authoring generate <manifest.json> --profile <profile.json> [--allow-manual-packets] [--write-report] [--json]
  creation-authoring run <manifest.json> --profile <profile.json> [--execute-live] [--allow-manual-packets] [--write-report] [--json]
  creation-authoring promote <run-report.json> --profile <profile.json> [--approved] [--merge-runner <csproj>] [--source-path <esp>] [--generated-path <esp>] [--merge-output-path <esp>] [--json]
  creation-authoring verify <manifest.json> --profile <profile.json> --readback <readback.json> [--json]
  creation-authoring drift <manifest.json> --profile <profile.json> [--readback <readback.json>] [--json]
  creation-authoring manual-packet <manifest.json> --profile <profile.json> [--json]
  creation-authoring migrate-pdv <pdv-author-manifest.json> [--profile <profile.json>] [--output-file <path>] [--json]
  creation-authoring explain [operation-kind] [--json]
`);
  process.exit(exitCode);
}
