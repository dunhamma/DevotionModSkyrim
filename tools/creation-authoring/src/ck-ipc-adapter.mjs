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
  if (process.platform === "win32") {
    return sendWindowsNamedPipePacket(packet, options);
  }

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

function sendWindowsNamedPipePacket(packet, options) {
  const startedAt = new Date();
  let fd = null;
  const retryUntil = Date.now() + Number(options.timeoutMs || 60000);
  let lastError = null;
  try {
    for (;;) {
      try {
        fd = fs.openSync(options.pipeName, "r+");
        break;
      } catch (error) {
        lastError = error;
        if (!["EBUSY", "ENOENT", "EPERM"].includes(error.code) || Date.now() >= retryUntil) {
          throw error;
        }
        Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 100);
      }
    }
    fs.writeSync(fd, Buffer.from(JSON.stringify(packet), "utf8"));
    const responseBuffer = Buffer.alloc(1024 * 1024);
    const bytesRead = fs.readSync(fd, responseBuffer, 0, responseBuffer.length, null);
    const responseText = responseBuffer.subarray(0, bytesRead).toString("utf8");
    return JSON.parse(responseText);
  } catch (error) {
    return {
      schema: "creation-authoring.ck-command-result.v1",
      status: "UNSAFE_BLOCKED",
      transport: "named-pipe",
      pipeName: options.pipeName,
      startedAt: startedAt.toISOString(),
      finishedAt: new Date().toISOString(),
      message: `CKPE authoring bridge is not available: ${error.message || lastError?.message}`
    };
  } finally {
    if (fd !== null) {
      try {
        fs.closeSync(fd);
      } catch {
        // The bridge may close the pipe after writing; the response has already been handled.
      }
    }
  }
}
