import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TOOL_ROOT = path.resolve(__dirname, "..");
const PROJECT_ROOT = path.resolve(TOOL_ROOT, "..", "..");
const DEFAULT_RUNNER_PROJECT = path.join(PROJECT_ROOT, "tools", "creation-merge-runner", "CreationMergeRunner.csproj");

export async function runLocalMergeRunner(mergeRequest, context = {}, options = {}) {
  const runnerProject = options.runnerProject || DEFAULT_RUNNER_PROJECT;
  const sourcePath = requireOption(options.sourcePath, "sourcePath");
  const generatedPath = requireOption(options.generatedPath, "generatedPath");
  const outputPath = requireOption(options.outputPath, "outputPath");
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "creation-merge-"));
  const requestPath = path.join(tempDir, "structured-merge-request.json");
  fs.writeFileSync(requestPath, JSON.stringify(mergeRequest, null, 2));

  const args = [
    "run",
    "--project",
    runnerProject,
    "--",
    "--request",
    requestPath,
    "--source-path",
    sourcePath,
    "--generated-path",
    generatedPath,
    "--output-path",
    outputPath
  ];

  if (options.approved) {
    args.push("--approved");
  }
  if (options.dryRun) {
    args.push("--dry-run");
  }
  if (options.backupRoot) {
    args.push("--backup-root", options.backupRoot);
  }

  const result = spawnSync("dotnet", args, {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true
  });

  const stdout = (result.stdout || "").trim();
  const jsonStart = stdout.indexOf("{");
  const payloadText = jsonStart >= 0 ? stdout.slice(jsonStart) : stdout;
  let payload = null;
  if (payloadText) {
    try {
      payload = JSON.parse(payloadText);
    } catch {
      payload = null;
    }
  }

  return {
    status: result.status === 0 && payload?.status === "PASS" ? "PASS" : "FAIL",
    exitCode: result.status,
    requestPath,
    runnerProject,
    sourcePath,
    generatedPath,
    outputPath,
    stdout,
    stderr: result.stderr || "",
    report: payload
  };
}

function requireOption(value, name) {
  if (!value) {
    throw new Error(`Local merge runner requires ${name}.`);
  }
  return value;
}
