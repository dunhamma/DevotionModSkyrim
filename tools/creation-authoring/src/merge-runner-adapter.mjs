import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TOOL_ROOT = path.resolve(__dirname, "..");
const PROJECT_ROOT = path.resolve(TOOL_ROOT, "..", "..");
const DEFAULT_RUNNER_PROJECT = path.join(PROJECT_ROOT, "native", "CreationMergeRunner", "CreationMergeRunner.csproj");

export async function runLocalMergeRunner(mergeRequest, context = {}, options = {}) {
  const runnerProject = options.runnerProject || DEFAULT_RUNNER_PROJECT;
  const sourcePath = requireOption(options.sourcePath, "sourcePath");
  const generatedPath = requireOption(options.generatedPath, "generatedPath");
  const outputPath = requireOption(options.outputPath, "outputPath");
  assertSafeMergePaths({ sourcePath, generatedPath, outputPath, allowSourceMutation: options.allowSourceMutation });
  const tempRoot = path.join(PROJECT_ROOT, "temp");
  fs.mkdirSync(tempRoot, { recursive: true });
  const tempDir = fs.mkdtempSync(path.join(tempRoot, "creation-merge-"));
  const requestPath = path.join(tempDir, "structured-merge-request.json");
  const dotnetHome = path.join(tempDir, "dotnet-home");
  const dotnetAppData = path.join(tempDir, "dotnet-appdata");
  fs.mkdirSync(dotnetHome, { recursive: true });
  fs.mkdirSync(dotnetAppData, { recursive: true });
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
    env: {
      ...process.env,
      APPDATA: dotnetAppData,
      DOTNET_CLI_HOME: dotnetHome,
      DOTNET_NOLOGO: "1",
      DOTNET_SKIP_FIRST_TIME_EXPERIENCE: "1",
      DOTNET_CLI_TELEMETRY_OPTOUT: "1"
    },
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

export function assertSafeMergePaths({ sourcePath, generatedPath, outputPath, allowSourceMutation = false } = {}) {
  const normalizedSource = normalizePath(sourcePath);
  const normalizedGenerated = normalizePath(generatedPath);
  const normalizedOutput = normalizePath(outputPath);
  if (normalizedSource && normalizedGenerated && normalizedSource === normalizedGenerated) {
    throw new Error("Generated plugin path must not be the source plugin path.");
  }
  if (!allowSourceMutation && normalizedSource && normalizedOutput && normalizedSource === normalizedOutput) {
    throw new Error("Merge output path must be a reviewed candidate path, not the source plugin path.");
  }
}

function requireOption(value, name) {
  if (!value) {
    throw new Error(`Local merge runner requires ${name}.`);
  }
  return value;
}

function normalizePath(value) {
  return value ? path.resolve(String(value)).toLowerCase() : null;
}
