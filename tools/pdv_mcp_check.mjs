#!/usr/bin/env node
/*
 * MCP server health check for the PDV Anvil/MO2 development setup.
 *
 * Confirms the Anvil MO2 MCP server is reachable, reports the active profile,
 * and warns if the profile is not "Devotion Dev". Run this at the start of a
 * Codex session before using mo2_* tools to catch stale-server or wrong-profile
 * problems early.
 *
 * Usage: node tools/pdv_mcp_check.mjs [--json]
 */

import http from "node:http";

const MCP_URL = "http://127.0.0.1:27016/mcp";
const EXPECTED_PROFILE = "Devotion Dev";
const TIMEOUT_MS = 5_000;

// MCP JSON-RPC request for tools/call on mo2_ping
const PING_REQUEST = JSON.stringify({
  jsonrpc: "2.0",
  id: 1,
  method: "tools/call",
  params: {
    name: "mo2_ping",
    arguments: {},
  },
});

function main() {
  const json = process.argv.includes("--json");

  httpPost(MCP_URL, PING_REQUEST, TIMEOUT_MS)
    .then((body) => {
      let parsed;
      try {
        parsed = JSON.parse(body);
      } catch {
        fail(json, "MCP server returned non-JSON response.", { raw: body });
        return;
      }

      const result = extractResult(parsed);
      if (!result) {
        fail(json, "mo2_ping call failed or returned unexpected shape.", { response: parsed });
        return;
      }

      const profile = result.profile ?? result.active_profile ?? null;
      const basePath = result.base_path ?? result.instance_path ?? null;
      const profileOk = !profile || profile === EXPECTED_PROFILE;

      const warnings = [];
      if (profile && !profileOk) {
        warnings.push(
          `Active profile is "${profile}", expected "${EXPECTED_PROFILE}". ` +
            `Switch to the Devotion Dev profile before running mo2_* tools.`
        );
      }
      if (!profile) {
        warnings.push(
          "mo2_ping response did not include a profile field. " +
            "Confirm the active profile is Devotion Dev before using mo2_* tools."
        );
      }

      if (json) {
        console.log(
          JSON.stringify(
            {
              ok: profileOk,
              server: MCP_URL,
              profile: profile ?? "(not reported)",
              basePath: basePath ?? "(not reported)",
              warnings,
              raw: result,
            },
            null,
            2
          )
        );
      } else {
        console.log(`PDV MCP health check`);
        console.log(`  server : ${MCP_URL}`);
        console.log(`  profile: ${profile ?? "(not reported)"}`);
        if (basePath) {
          console.log(`  base   : ${basePath}`);
        }
        if (warnings.length) {
          for (const w of warnings) {
            console.warn(`[WARN] ${w}`);
          }
        } else {
          console.log(`[OK] Server live, profile confirmed.`);
        }
      }

      process.exitCode = profileOk ? 0 : 1;
    })
    .catch((err) => {
      fail(json, buildConnectionError(err), null);
    });
}

function extractResult(parsed) {
  // MCP tools/call response: { result: { content: [ { type:"text", text: "..." } ] } }
  try {
    const text = parsed?.result?.content?.[0]?.text;
    if (text) {
      return JSON.parse(text);
    }
  } catch {
    // fall through
  }
  // Some MCP implementations return the result directly
  if (parsed?.result && typeof parsed.result === "object" && !Array.isArray(parsed.result)) {
    return parsed.result;
  }
  return null;
}

function buildConnectionError(err) {
  if (err.code === "ECONNREFUSED") {
    return (
      `MCP server not reachable at ${MCP_URL} (ECONNREFUSED). ` +
      `Open D:\\Wabbajack\\modlists\\Anvil\\Anvil.exe, then use ` +
      `MO2 Tools > Start/Stop MCP Server. Restart Codex if mo2_* tools ` +
      `remain invisible after starting the server.`
    );
  }
  if (err.code === "ETIMEDOUT" || err.message?.includes("timeout")) {
    return `MCP server at ${MCP_URL} did not respond within ${TIMEOUT_MS}ms (ETIMEDOUT).`;
  }
  return `MCP server connection failed: ${err.message}`;
}

function fail(json, message, detail) {
  if (json) {
    console.log(JSON.stringify({ ok: false, error: message, detail: detail ?? null }, null, 2));
  } else {
    console.error(`[FAIL] ${message}`);
  }
  process.exitCode = 1;
}

function httpPost(url, body, timeoutMs) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const options = {
      hostname: parsed.hostname,
      port: parseInt(parsed.port, 10),
      path: parsed.pathname,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body),
      },
      timeout: timeoutMs,
    };

    const req = http.request(options, (res) => {
      const chunks = [];
      res.on("data", (chunk) => chunks.push(chunk));
      res.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    });

    req.on("timeout", () => {
      req.destroy(Object.assign(new Error("Request timed out"), { code: "ETIMEDOUT" }));
    });
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

main();
