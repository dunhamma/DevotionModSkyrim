import { spawn } from "node:child_process";
import fs from "node:fs";
import readline from "node:readline";

// ORDER MATTERS. This used to be pinned to the AppData build, which is a STALE copy: it does not
// have housecarl_diff_record at all (it answers "Unknown tool"), and it ignores format:"json" and
// replies in text regardless. Both were mistaken for houseCARL limitations and written up as such
// -- see memory `snapshot-diffing-misses-added-list-elements`. The .claude/skills install is the
// one the MCP client itself uses, so it is the build every claim should be measured against.
// Keep the stale path last only as a fallback for a machine that lacks the skills install.
const CANDIDATE_EXES = [
  "C:/Users/Admin/.claude/skills/housecarl/server/housecarl-mcp.exe",
  "C:/Users/Admin/AppData/Local/houseCARL/server/housecarl-mcp.exe",
];

export function resolveHousecarlExe() {
  if (process.env.PDV_HOUSECARL_EXE) return process.env.PDV_HOUSECARL_EXE;
  const found = CANDIDATE_EXES.find((p) => fs.existsSync(p));
  if (!found) {
    throw new Error(`no houseCARL server found. Looked for:\n  ${CANDIDATE_EXES.join("\n  ")}\nSet PDV_HOUSECARL_EXE to override.`);
  }
  return found;
}

export async function callHousecarl(toolName, args, options = {}) {
  const executable = resolveHousecarlExe();
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

// A LONG-LIVED session: ONE server process reused across many calls.
//
// callHousecarl above spawns a process per call, which measured ~5.7s of startup EACH. That is
// fine for a handful of readbacks, but it makes a few-hundred-record sweep ~17 minutes of pure
// process spawn. Reusing one process brings the same sweep under a minute. Identical protocol and
// error semantics; the caller owns the lifetime and must call close().
export function openHousecarl(options = {}) {
  const executable = resolveHousecarlExe();
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
  let closed = false;

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
  child.on("exit", (code) => {
    closed = true;
    for (const waiter of pending.values()) waiter.reject(new Error(`houseCARL exited (code ${code}). ${stderr.trim()}`));
    pending.clear();
  });

  const request = (method, params = {}, timeoutMs) => new Promise((resolve, reject) => {
    if (closed) { reject(new Error("houseCARL session is closed.")); return; }
    const id = nextId++;
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`houseCARL timed out after ${timeoutMs}ms while calling ${method}.`));
    }, timeoutMs);
    timer.unref?.();
    pending.set(id, {
      resolve: (v) => { clearTimeout(timer); resolve(v); },
      reject: (e) => { clearTimeout(timer); reject(e); },
    });
    child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
  });

  let ready = null;
  const ensureReady = (timeoutMs) => {
    ready ??= request("initialize", {
      protocolVersion: "2025-03-26",
      capabilities: {},
      clientInfo: { name: "pdv-direct-readback", version: "1.0.0" },
    }, timeoutMs).then(() => {
      child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" })}\n`);
    });
    return ready;
  };

  return {
    executable,
    async call(toolName, args, opts = {}) {
      const timeoutMs = opts.timeoutMs ?? options.timeoutMs ?? 60_000;
      try {
        await ensureReady(timeoutMs);
        const result = await request("tools/call", { name: toolName, arguments: args }, timeoutMs);
        if (result?.isError) throw new Error(extractHousecarlText(result) || `houseCARL tool ${toolName} failed.`);
        return result;
      } catch (error) {
        const detail = stderr.trim();
        throw new Error(detail ? `${error.message}\n${detail}` : error.message);
      }
    },
    close() {
      if (closed) return;
      closed = true;
      for (const waiter of pending.values()) waiter.reject(new Error("houseCARL session closed."));
      pending.clear();
      child.stdin.end();
      child.kill();
      lines.close();
    },
  };
}

export function extractHousecarlText(result) {
  return (result?.content ?? [])
    .filter((item) => item?.type === "text")
    .map((item) => item.text ?? "")
    .join("\n");
}
