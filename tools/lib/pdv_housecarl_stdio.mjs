import { spawn } from "node:child_process";
import readline from "node:readline";

const DEFAULT_EXE = "C:/Users/Admin/AppData/Local/houseCARL/server/housecarl-mcp.exe";

export async function callHousecarl(toolName, args, options = {}) {
  const executable = process.env.PDV_HOUSECARL_EXE || DEFAULT_EXE;
  const timeoutMs = options.timeoutMs ?? 60_000;
  const child = spawn(executable, [], {
    cwd: options.cwd ?? process.cwd(),
    windowsHide: true,
    stdio: ["pipe", "pipe", "pipe"],
    env: {
      ...process.env,
      HouseCarl__Mo2InstanceDir: process.env.HouseCarl__Mo2InstanceDir || "D:/Wabbajack/modlists/Anvil",
      HOUSECARL_DATA_DIR: process.env.HOUSECARL_DATA_DIR || "C:/Users/Admin/.housecarl-codex/data",
    },
  });

  let stderr = "";
  child.stderr.setEncoding("utf8");
  child.stderr.on("data", (chunk) => { stderr += chunk; });
  const lines = readline.createInterface({ input: child.stdout, crlfDelay: Infinity });
  const pending = new Map();
  let nextId = 1;

  lines.on("line", (line) => {
    let message;
    try { message = JSON.parse(line); } catch { return; }
    const waiter = pending.get(message.id);
    if (waiter) {
      pending.delete(message.id);
      if (message.error) waiter.reject(new Error(message.error.message || JSON.stringify(message.error)));
      else waiter.resolve(message.result);
    }
  });

  const request = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
  });
  const notify = (method, params = {}) => {
    child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
  };

  const timeout = new Promise((_, reject) => {
    const timer = setTimeout(() => reject(new Error(`houseCARL timed out after ${timeoutMs}ms while calling ${toolName}.`)), timeoutMs);
    timer.unref?.();
  });

  try {
    await Promise.race([
      request("initialize", {
        protocolVersion: "2025-03-26",
        capabilities: {},
        clientInfo: { name: "pdv-direct-readback", version: "1.0.0" },
      }),
      timeout,
    ]);
    notify("notifications/initialized");
    const result = await Promise.race([
      request("tools/call", { name: toolName, arguments: args }),
      timeout,
    ]);
    if (result?.isError) {
      throw new Error(extractHousecarlText(result) || `houseCARL tool ${toolName} failed.`);
    }
    return result;
  } catch (error) {
    const detail = stderr.trim();
    throw new Error(detail ? `${error.message}\n${detail}` : error.message);
  } finally {
    for (const waiter of pending.values()) waiter.reject(new Error("houseCARL process closed."));
    pending.clear();
    child.stdin.end();
    child.kill();
    lines.close();
  }
}

export function extractHousecarlText(result) {
  return (result?.content ?? [])
    .filter((item) => item?.type === "text")
    .map((item) => item.text ?? "")
    .join("\n");
}
