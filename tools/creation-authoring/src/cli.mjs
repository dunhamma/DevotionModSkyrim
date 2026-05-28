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
import { checkPromotionCandidateDryRun, formatPromotionCandidateCheck } from "./promotion-candidate-check.mjs";
import { buildProofLedgerFromRun, mergeProofResults, verifyProofLedger } from "./proof-ledger.mjs";
import { formatPlatformV1EvidenceCheck, verifyPlatformV1Evidence } from "./proof-freshness.mjs";
import { buildPlatformProofSummary, formatPlatformProofSummary } from "./proof-summary.mjs";
import { checkFixtureDirectory } from "./fixture-check.mjs";
import { formatManualPackets, formatPlan, formatVerify } from "./report.mjs";
import {
  buildCapabilityMatrix,
  defaultCkpeRoot,
  explainCapabilityForFamily,
  extractCkpeRecordInventory,
  loadProofResults,
  verifyCapabilityMatrix,
  writeCapabilityMatrixArtifacts,
  writeInventoryArtifact
} from "./inventory.mjs";

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

    if (command === "inventory") {
      const inventory = extractCkpeRecordInventory({
        game: options.game || "SkyrimSE",
        ckpeRoot: options.ckpeRoot || defaultCkpeRoot()
      });
      const written = options.writeGenerated ? writeInventoryArtifact(inventory) : maybeWriteJson(options.outputFile, inventory);
      const result = { ...inventory, written: written || null };
      print(result, options, () => {
        const lines = [
          `Game: ${inventory.game}`,
          `Record families: ${inventory.count}`,
          `Source: ${inventory.source.path}`
        ];
        if (written) {
          lines.push(`Written: ${written}`);
        }
        return `${lines.join("\n")}\n`;
      });
      return;
    }

    if (command === "matrix") {
      const inventory = extractCkpeRecordInventory({
        game: options.game || "SkyrimSE",
        ckpeRoot: options.ckpeRoot || defaultCkpeRoot()
      });
      const proofResults = loadProofResults(options.proofResults);
      const matrix = buildCapabilityMatrix({
        inventory,
        proofResults,
        game: options.game || inventory.game
      });
      const verification = verifyCapabilityMatrix(matrix, inventory);
      const written = options.writeGenerated ? writeCapabilityMatrixArtifacts(matrix, verification) : null;
      const result = { matrix, verification, written };
      if (options.verifyMatrix && verification.status !== "PASS") {
        process.exitCode = 1;
      }
      print(result, options, () => {
        const lines = [
          `Game: ${matrix.game}`,
          `Record families: ${matrix.summary.total}`,
          `Verification: ${verification.status}`
        ];
        for (const [status, count] of Object.entries(matrix.summary)) {
          if (status !== "total") {
            lines.push(`- ${status}: ${count}`);
          }
        }
        if (written?.jsonPath) {
          lines.push(`Matrix JSON: ${written.jsonPath}`);
          lines.push(`Matrix Markdown: ${written.markdownPath}`);
        }
        return `${lines.join("\n")}\n`;
      });
      return;
    }

    if (command === "proof-summary") {
      const inventory = extractCkpeRecordInventory({
        game: options.game || "SkyrimSE",
        ckpeRoot: options.ckpeRoot || defaultCkpeRoot()
      });
      const proofResults = loadProofResults(options.proofResults);
      const matrix = buildCapabilityMatrix({
        inventory,
        proofResults,
        game: options.game || inventory.game
      });
      const summary = buildPlatformProofSummary(matrix, {
        game: options.game || inventory.game,
        sourceMatrix: options.matrix,
        sourceProofResults: options.proofResults || null
      });
      const written = maybeWriteJson(options.outputFile, summary);
      print({ summary, written }, options, () => {
        const formatted = formatPlatformProofSummary(summary);
        return written ? `${formatted}Proof summary: ${written}\n` : formatted;
      });
      return;
    }

    if (command === "proof-freshness") {
      const report = verifyPlatformV1Evidence({
        proofResultsPath: options.proofResults || "generated/proof-results.skyrimse.json",
        matrixPath: options.matrix || "generated/capability-matrix.skyrimse.json",
        summaryPath: options.summary || "generated/platform-v1-proof-summary.json"
      });
      const written = maybeWriteJson(options.outputFile, report);
      if (report.status !== "PASS") {
        process.exitCode = 1;
      }
      print({ report, written }, options, () => formatPlatformV1EvidenceCheck(report, written));
      return;
    }

    if (command === "explain-capability") {
      const recordFamily = positional[0];
      if (!recordFamily) {
        usage(1, "explain-capability requires a CK record family such as QUST.");
      }
      const inventory = extractCkpeRecordInventory({
        game: options.game || "SkyrimSE",
        ckpeRoot: options.ckpeRoot || defaultCkpeRoot()
      });
      const matrix = buildCapabilityMatrix({
        inventory,
        proofResults: loadProofResults(options.proofResults),
        game: options.game || inventory.game
      });
      const explanation = explainCapabilityForFamily(matrix, recordFamily);
      print(explanation, options, () => JSON.stringify(explanation, null, 2) + "\n");
      return;
    }

    if (command === "proof-ledger") {
      const reportPath = positional[0];
      if (!reportPath) {
        usage(1, "proof-ledger requires a strict run report path.");
      }
      if (!options.outputFile) {
        usage(1, "proof-ledger requires --output-file <path>.");
      }
      const runReport = readDocument(reportPath).document;
      const proofLedger = buildProofLedgerFromRun(runReport, {
        fixture: options.fixture || runReport.reportPath || reportPath
      });
      const proofLedgerVerification = verifyProofLedger(proofLedger);
      const platformPathVerification = options.platformV1
        ? verifyPlatformV1ProofPaths({
          fixture: options.fixture || runReport.reportPath || reportPath,
          reportPath,
          outputFile: options.outputFile
        })
        : { status: "PASS", failures: [] };
      proofLedgerVerification.failures.push(...platformPathVerification.failures);
      proofLedgerVerification.status = proofLedgerVerification.failures.length ? "FAIL" : proofLedgerVerification.status;
      proofLedger.verification = proofLedgerVerification;
      const written = maybeWriteJson(options.outputFile, proofLedger);
      if (proofLedgerVerification.status !== "PASS") {
        process.exitCode = 1;
      }
      print({ proofLedger, verification: proofLedgerVerification, written }, options, () => formatProofLedger(proofLedger, written));
      return;
    }

    if (command === "proof-results") {
      if (!positional.length) {
        usage(1, "proof-results requires one or more proof ledger/result paths.");
      }
      if (!options.outputFile) {
        usage(1, "proof-results requires --output-file <path>.");
      }
      const documents = positional.map((item) => ({
        ...readDocument(item).document,
        __sourcePath: item
      }));
      const proofResults = mergeProofResults(documents, { game: options.game || "SkyrimSE" });
      const written = maybeWriteJson(options.outputFile, proofResults);
      print({ proofResults, written }, options, () => formatProofResults(proofResults, written));
      return;
    }

    if (command === "fixture-check") {
      const fixtureDir = positional[0];
      if (!fixtureDir) {
        usage(1, "fixture-check requires a fixture directory.");
      }
      if (!options.profile) {
        usage(1, "fixture-check requires --profile <path>.");
      }
      if (!options.readback) {
        usage(1, "fixture-check requires --readback <path>.");
      }
      const profile = loadProfile(options.profile);
      const readback = readDocument(options.readback).document;
      const report = checkFixtureDirectory(fixtureDir, profile, readback, {
        allowUnprovenCk: Boolean(options.allowUnprovenCk)
      });
      const written = maybeWriteJson(options.outputFile, report);
      if (report.status !== "PASS") {
        process.exitCode = 1;
      }
      print({ report, written }, options, () => formatFixtureCheck(report, written));
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
        sourcePath: options.sourcePath,
        generatedPath: options.generatedPath,
        mergeOutputPath: options.mergeOutputPath,
        backupRoot: options.backupRoot,
        backupRunner: mergeRunner ? async () => ({
          status: "DEFERRED_TO_MERGE_RUNNER",
          message: "The local merge runner performs the timestamped backup immediately before writing output."
        }) : null,
        mergeRunner
      });
      maybeWriteJson(options.outputFile, report);
      if (report.status !== "PASS") {
        process.exitCode = 1;
      }
      print(report, options, () => formatPromotion(report));
      return;
    }

    if (command === "promotion-candidate-check") {
      const reportPath = positional[0];
      if (!reportPath) {
        usage(1, "promotion-candidate-check requires a run report path.");
      }
      if (!options.profile) {
        usage(1, "promotion-candidate-check requires --profile <path>.");
      }
      if (!options.mergeRunner) {
        usage(1, "promotion-candidate-check requires --merge-runner <csproj>.");
      }
      if (!options.mergeOutputPath) {
        usage(1, "promotion-candidate-check requires --merge-output-path <esp>.");
      }
      const profile = loadProfile(options.profile);
      const runReport = readDocument(reportPath).document;
      const mergeRunner = async (mergeRequest, context) => {
        return runLocalMergeRunner(mergeRequest, context, {
          runnerProject: options.mergeRunner,
          sourcePath: options.sourcePath,
          generatedPath: options.generatedPath,
          outputPath: options.mergeOutputPath,
          backupRoot: options.backupRoot,
          approved: Boolean(options.approved),
          dryRun: true
        });
      };
      const report = await checkPromotionCandidateDryRun(runReport, profile, {
        approved: Boolean(options.approved),
        allowSourceMutation: Boolean(options.allowSourceMutation),
        sourcePath: options.sourcePath,
        generatedPath: options.generatedPath,
        mergeOutputPath: options.mergeOutputPath,
        backupRoot: options.backupRoot,
        backupRunner: async () => ({
          status: "DEFERRED_TO_MERGE_RUNNER",
          message: "The local merge runner performs the timestamped backup immediately before writing output."
        }),
        mergeRunner
      });
      const written = maybeWriteJson(options.outputFile, report);
      if (report.status !== "PASS") {
        process.exitCode = 1;
      }
      print(report, options, () => formatPromotionCandidateCheck(report, written));
      return;
    }

    if (command === "generate") {
      options.executeLive = true;
      options.writeReport = options.writeReport ?? true;
    }

    if (command === "prove" || command === "prove-applied") {
      options.strict = true;
      options.writeReport = options.writeReport ?? true;
    }

    if (!["plan", "apply", "ck-apply", "verify", "manual-packet", "run", "generate", "drift", "prove", "prove-applied"].includes(command)) {
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
    const plan = createPlan(manifest, profile, {
      allowUnprovenCk: Boolean(options.allowUnprovenCk)
    });

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

    if (command === "run" || command === "generate" || command === "prove" || command === "prove-applied") {
      const readback = options.readback ? readDocument(options.readback).document : null;
      const appliedPatchEvidence = options.writerEvidence ? readDocument(options.writerEvidence).document : null;
      if (command === "prove-applied" && !appliedPatchEvidence) {
        usage(1, "prove-applied requires --writer-evidence <path>.");
      }
      const report = await runPipeline(manifest, profile, {
        allowManualPackets: Boolean(options.allowManualPackets),
        allowUnprovenCk: Boolean(options.allowUnprovenCk),
        strict: Boolean(options.strict),
        executeLive: Boolean(options.executeLive),
        readback,
        appliedPatchEvidence,
        writeReport: Boolean(options.writeReport),
        reportPath: options.reportPath,
        patchOptions: {
          output: options.output,
          author: options.author,
          eslFlag: options.esl === undefined ? true : options.esl
        }
      });
      if ((command === "prove" || command === "prove-applied") && options.proofOutput) {
        const proofLedger = buildProofLedgerFromRun(report, { fixture: manifestPath });
        const proofLedgerVerification = verifyProofLedger(proofLedger);
        if (options.platformV1) {
          const platformPathVerification = verifyPlatformV1ProofPaths({
            fixture: manifestPath,
            reportPath: report.reportPath,
            outputFile: options.proofOutput
          });
          proofLedgerVerification.failures.push(...platformPathVerification.failures);
          proofLedgerVerification.status = proofLedgerVerification.failures.length ? "FAIL" : proofLedgerVerification.status;
        }
        proofLedger.verification = proofLedgerVerification;
        maybeWriteJson(options.proofOutput, proofLedger);
        if (proofLedgerVerification.status !== "PASS") {
          process.exitCode = 1;
        }
      }
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
  const command = argv[0]?.startsWith("-") ? null : argv[0];

  for (let index = command ? 1 : 0; index < argv.length; index += 1) {
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
    } else if (arg === "--game") {
      options.game = requireNext(argv, ++index, "--game");
    } else if (arg.startsWith("--game=")) {
      options.game = arg.slice("--game=".length);
    } else if (arg === "--ckpe-root") {
      options.ckpeRoot = requireNext(argv, ++index, "--ckpe-root");
    } else if (arg.startsWith("--ckpe-root=")) {
      options.ckpeRoot = arg.slice("--ckpe-root=".length);
    } else if (arg === "--proof-results") {
      options.proofResults = requireNext(argv, ++index, "--proof-results");
    } else if (arg.startsWith("--proof-results=")) {
      options.proofResults = arg.slice("--proof-results=".length);
    } else if (arg === "--matrix") {
      options.matrix = requireNext(argv, ++index, "--matrix");
    } else if (arg.startsWith("--matrix=")) {
      options.matrix = arg.slice("--matrix=".length);
    } else if (arg === "--summary") {
      options.summary = requireNext(argv, ++index, "--summary");
    } else if (arg.startsWith("--summary=")) {
      options.summary = arg.slice("--summary=".length);
    } else if (arg === "--proof-output") {
      options.proofOutput = requireNext(argv, ++index, "--proof-output");
    } else if (arg.startsWith("--proof-output=")) {
      options.proofOutput = arg.slice("--proof-output=".length);
    } else if (arg === "--fixture") {
      options.fixture = requireNext(argv, ++index, "--fixture");
    } else if (arg.startsWith("--fixture=")) {
      options.fixture = arg.slice("--fixture=".length);
    } else if (arg === "--write-generated") {
      options.writeGenerated = true;
    } else if (arg === "--platform-v1") {
      options.platformV1 = true;
    } else if (arg === "--verify-matrix" || arg === "--verify") {
      options.verifyMatrix = true;
    } else if (arg === "--author") {
      options.author = requireNext(argv, ++index, "--author");
    } else if (arg.startsWith("--author=")) {
      options.author = arg.slice("--author=".length);
    } else if (arg === "--no-esl") {
      options.esl = false;
    } else if (arg === "--allow-manual-packets") {
      options.allowManualPackets = true;
    } else if (arg === "--allow-unproven-ck") {
      options.allowUnprovenCk = true;
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
    } else if (arg === "--writer-evidence") {
      options.writerEvidence = requireNext(argv, ++index, "--writer-evidence");
    } else if (arg.startsWith("--writer-evidence=")) {
      options.writerEvidence = arg.slice("--writer-evidence=".length);
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
  if (report.candidatePlugin) {
    lines.push(`Candidate plugin: ${report.candidatePlugin}`);
  }
  for (const phase of report.phases) {
    lines.push(`- [${phase.status}] ${phase.phase}${phase.message ? `: ${phase.message}` : ""}`);
    for (const blocker of phase.gates?.blockers || []) {
      lines.push(`  blocker: ${blocker}`);
    }
  }
  const nextAdapter = report.phases.find((phase) => phase.status === "REQUESTED" || phase.status === "TODO" || phase.status === "MANUAL");
  if (nextAdapter) {
    lines.push(`Next required adapter: ${nextAdapter.phase}`);
  }
  if (report.reportPath) {
    lines.push(`Report: ${report.reportPath}`);
  }
  return `${lines.join("\n")}\n`;
}

function formatProofLedger(ledger, written) {
  const lines = [];
  lines.push(`Status: ${ledger.status}`);
  lines.push(`Proof rows: ${ledger.proofs.length}`);
  if (ledger.verification) {
    lines.push(`Verification: ${ledger.verification.status}`);
  }
  if (written) {
    lines.push(`Proof ledger: ${written}`);
  }
  for (const proof of ledger.proofs) {
    lines.push(`- [${proof.status}] ${proof.recordFamily} ${proof.operation} ${proof.target}`);
    for (const missing of proof.missingCoverage || []) {
      lines.push(`  missing: ${missing}`);
    }
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
  creation-authoring ck-apply <manifest.json> --profile <profile.json> [--allow-unproven-ck] [--json]
  creation-authoring generate <manifest.json> --profile <profile.json> [--allow-manual-packets] [--allow-unproven-ck] [--write-report] [--json]
  creation-authoring run <manifest.json> --profile <profile.json> [--execute-live] [--allow-manual-packets] [--allow-unproven-ck] [--write-report] [--json]
  creation-authoring prove <manifest.json> --profile <profile.json> --strict [--proof-output <path>] [--platform-v1] [--json]
  creation-authoring prove-applied <manifest.json> --profile <profile.json> --readback <readback.json> --writer-evidence <writer-evidence.json> --strict [--proof-output <path>] [--platform-v1] [--json]
  creation-authoring promote <run-report.json> --profile <profile.json> [--approved] [--merge-runner <csproj>] [--source-path <esp>] [--generated-path <esp>] [--merge-output-path <esp>] [--output-file <path>] [--json]
  creation-authoring promotion-candidate-check <run-report.json> --profile <profile.json> --approved --merge-runner <csproj> --source-path <esp> --generated-path <esp> --merge-output-path <esp> [--output-file <path>] [--json]
  creation-authoring verify <manifest.json> --profile <profile.json> --readback <readback.json> [--json]
  creation-authoring drift <manifest.json> --profile <profile.json> [--readback <readback.json>] [--json]
  creation-authoring manual-packet <manifest.json> --profile <profile.json> [--json]
  creation-authoring inventory [--game SkyrimSE] [--write-generated] [--json]
  creation-authoring matrix [--game SkyrimSE] [--proof-results <path>] [--write-generated] [--verify] [--json]
  creation-authoring proof-summary [--game SkyrimSE] [--proof-results <path>] [--output-file <path>] [--json]
  creation-authoring proof-freshness [--proof-results <path>] [--matrix <path>] [--summary <path>] [--output-file <path>] [--json]
  creation-authoring explain-capability <record-family> [--game SkyrimSE] [--proof-results <path>] [--json]
  creation-authoring proof-ledger <run-report.json> --output-file <proof-ledger.json> [--fixture <manifest-or-fixture>] [--platform-v1] [--json]
  creation-authoring proof-results <proof-ledger-or-results.json>... --output-file <proof-results.json> [--game SkyrimSE] [--json]
  creation-authoring fixture-check <fixture-dir> --profile <profile.json> --readback <readback.json> [--output-file <path>] [--json]
  creation-authoring migrate-pdv <pdv-author-manifest.json> [--profile <profile.json>] [--output-file <path>] [--json]
  creation-authoring explain [operation-kind] [--json]
`);
  process.exit(exitCode);
}

function formatFixtureCheck(report, written) {
  const lines = [
    `Status: ${report.status}`,
    `Fixtures: ${report.summary.total}`,
    `PASS: ${report.summary.PASS}`,
    `FAIL: ${report.summary.FAIL}`
  ];
  for (const result of report.results) {
    lines.push(`- [${result.status}] ${result.project}`);
    for (const failure of result.failures || []) {
      lines.push(`  failure: ${failure}`);
    }
  }
  if (written) {
    lines.push(`Fixture check: ${written}`);
  }
  return `${lines.join("\n")}\n`;
}

function formatProofResults(proofResults, written) {
  const lines = [
    `Proof results: ${proofResults.results.length}`,
    `Sources: ${(proofResults.sourceLedgers || []).length}`
  ];
  const grouped = proofResults.results.reduce((summary, result) => {
    const key = `${result.recordFamily || "UNKNOWN"} ${result.operation || "unknown"}`;
    summary.set(key, (summary.get(key) || 0) + 1);
    return summary;
  }, new Map());
  for (const [key, count] of grouped) {
    lines.push(`- ${key}: ${count}`);
  }
  if (written) {
    lines.push(`Proof results written: ${written}`);
  }
  return `${lines.join("\n")}\n`;
}

function verifyPlatformV1ProofPaths({ fixture, reportPath, outputFile }) {
  const failures = [];
  const normalizedFixture = normalizePath(fixture);
  const normalizedReport = normalizePath(reportPath);
  const normalizedOutput = normalizePath(outputFile);
  if (
    !normalizedFixture.startsWith("fixtures/platform-v1/") &&
    !normalizedFixture.startsWith("fixtures/ckpe/") &&
    !normalizedFixture.startsWith("reference-packs/player-devotion/platform-v1/")
  ) {
    failures.push({
      code: "platform_v1_fixture_path",
      message: "Platform v1 proof fixtures must live under fixtures/platform-v1, fixtures/ckpe, or reference-packs/player-devotion/platform-v1.",
      path: fixture
    });
  }
  if (!normalizedReport.startsWith("reports/") && !normalizedReport.startsWith("fixtures/ckpe/")) {
    failures.push({
      code: "platform_v1_report_path",
      message: "Platform v1 strict reports must live under reports or fixtures/ckpe.",
      path: reportPath
    });
  }
  if (!normalizedOutput.startsWith("generated/") && !normalizedOutput.startsWith("fixtures/ckpe/")) {
    failures.push({
      code: "platform_v1_ledger_path",
      message: "Platform v1 proof ledgers must live under generated or fixtures/ckpe.",
      path: outputFile
    });
  }
  return {
    status: failures.length ? "FAIL" : "PASS",
    failures
  };
}

function normalizePath(value = "") {
  const cwd = process.cwd().replaceAll("\\", "/").replace(/\/$/u, "");
  const normalized = String(value).replaceAll("\\", "/").replace(/^\.\//u, "");
  if (normalized.startsWith(`${cwd}/`)) {
    return normalized.slice(cwd.length + 1);
  }
  return normalized;
}

