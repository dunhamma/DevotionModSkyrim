let nextRequestId = 1;

export class McpHttpClient {
  constructor(options = {}) {
    this.url = options.url || "http://127.0.0.1:27016/mcp";
    this.clientName = options.clientName || "creation-authoring-live-runner";
    this.clientVersion = options.clientVersion || "0.1.0";
    this.initialized = false;
  }

  async initialize() {
    if (this.initialized) {
      return null;
    }
    const result = await this.rpc("initialize", {
      protocolVersion: "2025-03-26",
      capabilities: {},
      clientInfo: {
        name: this.clientName,
        version: this.clientVersion
      }
    });
    this.initialized = true;
    return result;
  }

  async callTool(name, args = {}) {
    await this.initialize();
    const result = await this.rpc("tools/call", {
      name,
      arguments: args
    });
    if (result?.isError) {
      throw new Error(`MCP tool ${name} failed: ${extractContentText(result)}`);
    }
    return parseToolResult(result);
  }

  async rpc(method, params = {}) {
    const response = await fetch(this.url, {
      method: "POST",
      headers: {
        "content-type": "application/json"
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: nextRequestId++,
        method,
        params
      })
    });

    const text = await response.text();
    if (!response.ok) {
      throw new Error(`MCP HTTP ${response.status}: ${text}`);
    }

    const payload = JSON.parse(text);
    if (payload.error) {
      throw new Error(`MCP ${method} error: ${payload.error.message || JSON.stringify(payload.error)}`);
    }
    return payload.result;
  }
}

export function parseToolResult(result) {
  const text = extractContentText(result);
  if (!text) {
    return result;
  }
  try {
    return JSON.parse(text);
  } catch {
    return {
      text
    };
  }
}

function extractContentText(result) {
  const content = result?.content || [];
  return content
    .filter((item) => item?.type === "text")
    .map((item) => item.text || "")
    .join("\n")
    .trim();
}
