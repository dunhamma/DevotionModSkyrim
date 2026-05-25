import fs from "node:fs";
import { execFile } from "node:child_process";
import net from "node:net";
import os from "node:os";
import path from "node:path";
import { writeJson } from "./io.mjs";

const DEFAULT_PIPE = "\\\\.\\pipe\\CreationKitAuthoringBridge";

export async function runCkIpcPacket(packet, options = {}) {
  const mode = options.mode || "named-pipe";
  const timeoutMs = Number(options.timeoutMs || 60000);
  const commandId = `${packet.project || "creation-authoring"}-${Date.now()}`;

  if (mode === "file-queue") {
    return writeFileQueuePacket(packet, {
      commandId,
      queueDir: options.queueDir || path.join(os.tmpdir(), "creation-kit-authoring-bridge")
    });
  }

  return sendNamedPipePacket(packet, {
    commandId,
    pipeName: options.pipeName || DEFAULT_PIPE,
    timeoutMs
  });
}

function writeFileQueuePacket(packet, options) {
  fs.mkdirSync(options.queueDir, { recursive: true });
  const requestPath = path.join(options.queueDir, `${options.commandId}.request.json`);
  writeJson(requestPath, packet);
  return {
    schema: "creation-authoring.ck-command-result.v1",
    status: "REQUESTED",
    transport: "file-queue",
    requestPath,
    message: "CK command packet was written to the file queue. A running CKPE bridge must consume it and write a result."
  };
}

function sendNamedPipePacket(packet, options) {
  return new Promise((resolve) => {
    const startedAt = new Date();
    const client = net.createConnection(options.pipeName);
    let settled = false;
    let responseText = "";

    const timer = setTimeout(() => {
      finish({
        schema: "creation-authoring.ck-command-result.v1",
        status: "UNSAFE_BLOCKED",
        transport: "named-pipe",
        pipeName: options.pipeName,
        startedAt: startedAt.toISOString(),
        finishedAt: new Date().toISOString(),
        message: "Timed out waiting for CKPE authoring bridge response."
      });
    }, options.timeoutMs);

    client.on("connect", () => {
      client.write(`${JSON.stringify(packet)}\n`);
    });

    client.on("data", (chunk) => {
      responseText += chunk.toString();
    });

    client.on("error", (error) => {
      if (process.platform === "win32" && error.code === "EPIPE") {
        client.destroy();
        sendWindowsPowerShellNamedPipePacket(packet, options, startedAt).then(finish);
        return;
      }

      finish({
        schema: "creation-authoring.ck-command-result.v1",
        status: "UNSAFE_BLOCKED",
        transport: "named-pipe",
        pipeName: options.pipeName,
        startedAt: startedAt.toISOString(),
        finishedAt: new Date().toISOString(),
        message: `CKPE authoring bridge is not available: ${error.message}`
      });
    });

    client.on("end", () => {
      try {
        finish(JSON.parse(responseText));
      } catch {
        finish({
          schema: "creation-authoring.ck-command-result.v1",
          status: "FAIL",
          transport: "named-pipe",
          pipeName: options.pipeName,
          startedAt: startedAt.toISOString(),
          finishedAt: new Date().toISOString(),
          message: "CKPE authoring bridge returned non-JSON output.",
          responseText
        });
      }
    });

    function finish(result) {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      client.destroy();
      resolve(result);
    }
  });
}

function sendWindowsPowerShellNamedPipePacket(packet, options, startedAt) {
  return new Promise((resolve) => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "creation-kit-authoring-bridge-"));
    const requestPath = path.join(tempDir, "request.json");
    fs.writeFileSync(requestPath, JSON.stringify(packet), "utf8");

    const script = `
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$pipeName = $env:CK_AUTHORING_PIPE_SERVER
$requestPath = $env:CK_AUTHORING_REQUEST_PATH
$timeoutMs = [int]$env:CK_AUTHORING_TIMEOUT_MS
$request = [System.IO.File]::ReadAllText($requestPath, [System.Text.Encoding]::UTF8)
$pipe = [System.IO.Pipes.NamedPipeClientStream]::new('.', $pipeName, [System.IO.Pipes.PipeDirection]::InOut, [System.IO.Pipes.PipeOptions]::None)
$reader = $null
$writer = $null
try {
  $pipe.Connect($timeoutMs)
  $writer = [System.IO.StreamWriter]::new($pipe)
  $writer.AutoFlush = $true
  $reader = [System.IO.StreamReader]::new($pipe)
  $writer.Write($request)
  $pipe.WaitForPipeDrain()
  $response = $reader.ReadToEnd()
  [Console]::Out.Write($response)
} finally {
  if ($reader) { try { $reader.Dispose() } catch {} }
  if ($writer) { try { $writer.Dispose() } catch {} }
  if ($pipe) { try { $pipe.Dispose() } catch {} }
}
`;

    execFile("powershell.exe", [
      "-NoProfile",
      "-NonInteractive",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      script
    ], {
      timeout: options.timeoutMs + 1000,
      env: {
        ...process.env,
        CK_AUTHORING_PIPE_SERVER: pipeServerNameFromPath(options.pipeName),
        CK_AUTHORING_REQUEST_PATH: requestPath,
        CK_AUTHORING_TIMEOUT_MS: String(options.timeoutMs)
      },
      windowsHide: true
    }, (error, stdout, stderr) => {
      fs.rmSync(tempDir, { recursive: true, force: true });

      if (error) {
        resolve({
          schema: "creation-authoring.ck-command-result.v1",
          status: "UNSAFE_BLOCKED",
          transport: "named-pipe-powershell",
          pipeName: options.pipeName,
          startedAt: startedAt.toISOString(),
          finishedAt: new Date().toISOString(),
          message: `CKPE authoring bridge PowerShell fallback failed: ${stderr.trim() || error.message}`
        });
        return;
      }

      try {
        resolve({
          ...JSON.parse(stdout),
          clientTransport: "powershell-named-pipe-fallback"
        });
      } catch {
        resolve({
          schema: "creation-authoring.ck-command-result.v1",
          status: "FAIL",
          transport: "named-pipe-powershell",
          pipeName: options.pipeName,
          startedAt: startedAt.toISOString(),
          finishedAt: new Date().toISOString(),
          message: "CKPE authoring bridge PowerShell fallback returned non-JSON output.",
          responseText: stdout
        });
      }
    });
  });
}

export function pipeServerNameFromPath(pipeName = DEFAULT_PIPE) {
  const normalized = pipeName.replace(/\//g, "\\");
  const prefix = "\\\\.\\pipe\\";
  if (normalized.toLowerCase().startsWith(prefix.toLowerCase())) {
    return normalized.slice(prefix.length);
  }
  return normalized;
}
