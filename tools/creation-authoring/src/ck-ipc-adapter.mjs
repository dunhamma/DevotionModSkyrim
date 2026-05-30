import fs from "node:fs";
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
    const retryUntil = Date.now() + Number(options.timeoutMs || 60000);
    let settled = false;
    let responseText = "";
    let lastError = null;
    let client = null;

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

    attemptConnection();

    function attemptConnection() {
      if (settled) {
        return;
      }
      client = net.createConnection({
        path: options.pipeName,
        allowHalfOpen: true
      });

      client.on("connect", () => {
        client.write(JSON.stringify(packet));
      });

      client.on("data", (chunk) => {
        responseText += chunk.toString();
      });

      client.on("error", (error) => {
        lastError = error;
        if (responseText.trim()) {
          finishFromResponse();
          return;
        }
        const retryable = ["ECONNREFUSED", "ENOENT", "EBUSY", "EPERM"].includes(error.code);
        if (retryable && Date.now() < retryUntil) {
          client.destroy();
          client = null;
          setTimeout(attemptConnection, 100);
          return;
        }
        finish({
          schema: "creation-authoring.ck-command-result.v1",
          status: "UNSAFE_BLOCKED",
          transport: "named-pipe",
          pipeName: options.pipeName,
          startedAt: startedAt.toISOString(),
          finishedAt: new Date().toISOString(),
          message: `CKPE authoring bridge is not available: ${error.message || lastError?.message}`
        });
      });

      client.on("end", () => {
        if (!responseText.trim()) {
          finish({
            schema: "creation-authoring.ck-command-result.v1",
            status: "UNSAFE_BLOCKED",
            transport: "named-pipe",
            pipeName: options.pipeName,
            startedAt: startedAt.toISOString(),
            finishedAt: new Date().toISOString(),
            message: "CKPE authoring bridge closed without returning a response."
          });
          return;
        }
        finishFromResponse();
      });
    }

    function finishFromResponse() {
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
    }

    function finish(result) {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      if (client) {
        client.destroy();
      }
      resolve(result);
    }
  });
}
