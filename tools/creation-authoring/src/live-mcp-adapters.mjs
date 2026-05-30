import fs from "node:fs";
import path from "node:path";
import { McpHttpClient } from "./mcp-client.mjs";
import { normalizeMo2RecordDetail } from "./live-readback.mjs";
import { runProcess } from "./process-runner.mjs";

const FORMID_PATTERN = /^[^:]+:[0-9a-fA-F]{1,8}$/;

export function createLiveMcpContext(options = {}) {
  return {
    mcp: options.mcp || new McpHttpClient({ url: options.mcpUrl }),
    recordCache: new Map(),
    conflictCache: new Map()
  };
}

export async function refreshLiveRecordIndex(context, phase = "mo2-record-index-refresh") {
  try {
    const build = await context.mcp.callTool("mo2_build_record_index", { force_rebuild: true });
    context.recordCache.clear();
    context.conflictCache.clear();
    return {
      phase,
      status: missingMasters(build).length ? "FAIL" : "PASS",
      message: "MO2 record index was force rebuilt after an external plugin write.",
      result: build
    };
  } catch (error) {
    return {
      phase,
      status: "FAIL",
      message: "MO2 record index force rebuild failed after an external plugin write.",
      error: serializeError(error)
    };
  }
}

export async function prepareLiveProfile(manifest, profile, context) {
  const preflight = [];
  let ping;
  try {
    ping = await context.mcp.callTool("mo2_ping");
  } catch (error) {
    preflight.push({
      phase: "mo2-ping",
      status: "FAIL",
      message: "MO2 MCP is not available.",
      error: serializeError(error)
    });
    return { profile, preflight };
  }
  preflight.push({
    phase: "mo2-ping",
    status: ping.status === "ok" ? "PASS" : "FAIL",
    result: ping
  });

  let indexStatus;
  try {
    indexStatus = await context.mcp.callTool("mo2_record_index_status");
  } catch (error) {
    preflight.push({
      phase: "mo2-record-index",
      status: "FAIL",
      message: "MO2 record index status could not be read.",
      error: serializeError(error)
    });
    return { profile, preflight };
  }
  if (indexNeedsBuild(indexStatus)) {
    let build;
    try {
      build = await context.mcp.callTool("mo2_build_record_index", { force_rebuild: false });
    } catch (error) {
      preflight.push({
        phase: "mo2-record-index",
        status: "FAIL",
        message: "MO2 record index build/check failed.",
        error: serializeError(error)
      });
      return { profile, preflight };
    }
    preflight.push({
      phase: "mo2-record-index",
      status: "PASS",
      message: "Record index build/check completed.",
      result: build
    });
  } else {
    preflight.push({
      phase: "mo2-record-index",
      status: missingMasters(indexStatus).length ? "FAIL" : "PASS",
      result: indexStatus
    });
  }

  let pluginStatus;
  try {
    pluginStatus = await checkPlugins(manifest, profile, context);
  } catch (error) {
    pluginStatus = {
      phase: "mo2-plugin-state",
      status: "FAIL",
      sourcePlugin: profile.sourcePlugin,
      generatedPlugin: manifest.output,
      blockers: ["MO2 plugin state could not be read."],
      error: serializeError(error)
    };
  }
  preflight.push(pluginStatus);

  const records = {};
  const identifiers = collectIdentifiers(manifest);
  for (const identifier of identifiers) {
    const record = await resolveLiveRecord(identifier, context);
    if (record.resolved) {
      records[identifier] = record;
    }
  }

  return {
    profile: {
      ...profile,
      resourceConnectors: [
        ...profile.resourceConnectors,
        {
          type: "fixture",
          name: "live-mo2-resolved-records",
          records
        }
      ]
    },
    preflight
  };
}

function serializeError(error) {
  return {
    name: error?.name || "Error",
    message: error?.message || String(error)
  };
}

export function createPatchWriter(context, options = {}) {
  return async (patchRequest) => {
    const result = await context.mcp.callTool("mo2_create_patch", patchRequest);
    if (!shouldUseExistingGeneratedPayloadWriter(result, patchRequest, options)) {
      return result;
    }
    const fallback = await runExistingGeneratedPayloadWriter(patchRequest, result.existing_path, options);
    return {
      ...fallback,
      fallbackFrom: "mo2_create_patch",
      initialResult: result
    };
  };
}

function shouldUseExistingGeneratedPayloadWriter(result, patchRequest, options = {}) {
  if (!result?.existing_path || !/file already exists/i.test(String(result.error || result.message || ""))) {
    return false;
  }
  const outputName = patchRequest.output_name || options.generatedPlugin;
  const sourcePlugin = options.sourcePlugin;
  const existingName = path.basename(result.existing_path);
  if (!outputName || existingName.toLowerCase() !== String(outputName).toLowerCase()) {
    return false;
  }
  if (sourcePlugin && existingName.toLowerCase() === String(sourcePlugin).toLowerCase()) {
    return false;
  }
  return Array.isArray(patchRequest.records) &&
    patchRequest.records.length > 0 &&
    patchRequest.records.every((record) => {
      return record.set_message ||
        record.set_message_payload ||
        record.set_activator ||
        record.set_activator_payload;
    });
}

async function runExistingGeneratedPayloadWriter(patchRequest, pluginPath, options = {}) {
  const projectRoot = options.projectRoot || process.cwd();
  const reportsDir = path.resolve(projectRoot, options.reportsDir || "reports");
  const requestDir = path.join(reportsDir, "payload-writer-requests");
  fs.mkdirSync(requestDir, { recursive: true });
  const requestPath = path.join(requestDir, `${patchRequest.output_name || "payload"}-${Date.now()}.json`);
  fs.writeFileSync(requestPath, JSON.stringify(patchRequest, null, 2));

  const writerExe = path.join(projectRoot, "native", "CreationPayloadWriter", "bin", "Debug", "net8.0", "CreationPayloadWriter.exe");
  const writerProject = path.join(projectRoot, "native", "CreationPayloadWriter", "CreationPayloadWriter.csproj");
  const command = fs.existsSync(writerExe) ? writerExe : "dotnet";
  const args = fs.existsSync(writerExe)
    ? ["--plugin-path", pluginPath, "--request", requestPath, "--output-path", pluginPath]
    : ["run", "--project", writerProject, "--", "--plugin-path", pluginPath, "--request", requestPath, "--output-path", pluginPath];
  const result = await runProcess(command, args, { cwd: projectRoot });
  const report = parsePayloadWriterReport(result.stdout);
  return {
    status: result.status,
    exitCode: result.exitCode,
    stdout: result.stdout,
    stderr: result.stderr,
    writer: "CreationPayloadWriter",
    requestPath,
    pluginPath,
    report
  };
}

function parsePayloadWriterReport(stdout) {
  const trimmed = String(stdout || "").trim();
  if (!trimmed) {
    return null;
  }
  try {
    return JSON.parse(trimmed);
  } catch {
    const lastJson = trimmed.split(/\r?\n/).reverse().find((line) => line.trim().startsWith("{"));
    if (!lastJson) {
      return null;
    }
    try {
      return JSON.parse(lastJson);
    } catch {
      return null;
    }
  }
}

export function createReadbackCollector(context) {
  return async ({ manifest, plan }) => {
    const formids = [];
    const unresolved = [];
    for (const item of plan.operations) {
      const target = item.targetResolution?.formid || item.operation.target;
      if (FORMID_PATTERN.test(target)) {
        formids.push(target);
      } else {
        unresolved.push(item.operation.target);
      }
    }

    const details = [];
    const uniqueFormids = [...new Set(formids)];
    if (uniqueFormids.length) {
      details.push(await context.mcp.callTool("mo2_record_detail", {
        formids: uniqueFormids,
        include_disabled: true,
        resolve_links: true
      }));
    }
    for (const editorId of [...new Set(unresolved)]) {
      try {
        details.push(await context.mcp.callTool("mo2_record_detail", {
          editor_id: editorId,
          include_disabled: true,
          resolve_links: true
        }));
      } catch {
        // The verifier will surface unresolved readback as TODO/FAIL.
      }
    }

    const normalized = normalizeMo2RecordDetail({
      records: details.flatMap((detail) => detail.records || [detail])
    });
    normalized.conflicts = {};
    for (const operation of manifest.operations) {
      try {
        const chain = await getConflictChain(operation.target, context);
        normalized.conflicts[operation.target] = chain;
        attachConflictChain(normalized, operation, chain);
      } catch {
        normalized.conflicts[operation.target] = null;
      }
    }
    return normalized;
  };
}

function attachConflictChain(readback, operation, chain) {
  const conflictChain = normalizeConflictChain(chain);
  const records = readback.records || {};
  const candidates = [
    operation.target,
    operation.payload?.createdEditorId,
    operation.payload?.targetEditorId
  ].filter(Boolean);
  for (const record of Object.values(records)) {
    if (!record || typeof record !== "object") {
      continue;
    }
    const matches = candidates.some((candidate) =>
      equals(record.editorId || record.EditorID, candidate) ||
      equals(record.formid || record.FormID, candidate)
    );
    if (matches) {
      record.conflictChain = conflictChain;
      record.conflictChainDetail = chain;
    }
  }
}

function normalizeConflictChain(chain) {
  if (Array.isArray(chain)) {
    return chain;
  }
  if (Array.isArray(chain?.chain)) {
    return chain.chain;
  }
  if (Array.isArray(chain?.conflictChain)) {
    return chain.conflictChain;
  }
  return [];
}

export function createCompileRunner(projectRoot, args = [], options = {}) {
  return async () => {
    const compileArgs = args.length ? args : ["pdv_compile.mjs"];
    return {
      phase: "compile",
      name: "pdv-compiler",
      ...await runProcess(process.execPath, compileArgs, {
        cwd: options.cwd || path.join(projectRoot, "tools")
      })
    };
  };
}

export function createPdvVerifierRunner(projectRoot, args = [], options = {}) {
  return async () => {
    const verifierArgs = args.length ? args : ["pdv_verify.mjs", "--strict-phase9"];
    return {
      phase: "project-verifier",
      name: "pdv-verifier",
      ...await runProcess(process.execPath, verifierArgs, {
        cwd: options.cwd || path.join(projectRoot, "tools")
      })
    };
  };
}

async function resolveLiveRecord(identifier, context) {
  if (typeof identifier !== "string" || !identifier.trim()) {
    return unresolved(identifier);
  }
  const key = identifier.toLowerCase();
  if (context.recordCache.has(key)) {
    return context.recordCache.get(key);
  }

  let query;
  if (FORMID_PATTERN.test(identifier)) {
    query = await context.mcp.callTool("mo2_query_records", {
      formid: identifier,
      include_disabled: true,
      limit: 5
    });
  } else {
    query = await context.mcp.callTool("mo2_query_records", {
      editor_id_filter: identifier,
      include_disabled: true,
      limit: 25
    });
  }

  const records = query.records || query.results || [];
  const match = findExactMatch(identifier, records);
  if (!match) {
    const result = unresolved(identifier);
    context.recordCache.set(key, result);
    return result;
  }

  const conflictChain = await getConflictChain(match.editor_id || match.editorId || identifier, context).catch(() => null);
  const result = {
    identifier,
    editorId: match.editor_id || match.editorId || match.EditorID || identifier,
    formid: match.formid || match.formID || match.FormID || null,
    recordType: match.record_type || match.recordType || match.type || null,
    plugin: match.plugin || match.origin_plugin || null,
    winningPlugin: match.winning_plugin || match.winningPlugin || match.plugin || null,
    conflictChain,
    resolved: true
  };
  context.recordCache.set(key, result);
  return result;
}

async function getConflictChain(identifier, context) {
  const key = identifier.toLowerCase();
  if (context.conflictCache.has(key)) {
    return context.conflictCache.get(key);
  }
  const args = FORMID_PATTERN.test(identifier)
    ? { formid: identifier, include_disabled: true }
    : { editor_id: identifier, include_disabled: true };
  const chain = await context.mcp.callTool("mo2_conflict_chain", args);
  context.conflictCache.set(key, chain);
  return chain;
}

async function checkPlugins(manifest, profile, context) {
  const plugins = await context.mcp.callTool("mo2_list_plugins", {
    filter: profile.sourcePlugin,
    enabled_only: false,
    limit: 25
  });
  const list = plugins.plugins || plugins.results || [];
  const source = list.find((plugin) => equals(plugin.name, profile.sourcePlugin));
  const blockers = [];
  if (!source) {
    blockers.push(`Source plugin ${profile.sourcePlugin} is not visible in MO2.`);
  } else if (source.enabled === false) {
    blockers.push(`Source plugin ${profile.sourcePlugin} is disabled.`);
  }

  return {
    phase: "mo2-plugin-state",
    status: blockers.length ? "FAIL" : "PASS",
    sourcePlugin: profile.sourcePlugin,
    generatedPlugin: manifest.output,
    blockers,
    result: source || null
  };
}

function collectIdentifiers(manifest) {
  const values = new Set();
  for (const operation of manifest.operations) {
    values.add(operation.target);
    for (const property of operation.payload?.properties || []) {
      if (typeof property.value === "string") {
        values.add(property.value);
      }
    }
    if (typeof operation.payload?.entry === "string") {
      values.add(operation.payload.entry);
    }
  }
  return [...values].filter(Boolean);
}

function indexNeedsBuild(status) {
  return status?.built === false || status?.status === "not_built" || status?.record_count === 0;
}

function missingMasters(status) {
  return status?.missing_masters || status?.missingMasters || [];
}

function findExactMatch(identifier, records) {
  if (FORMID_PATTERN.test(identifier)) {
    return records.find((record) => equals(record.formid || record.FormID, identifier)) || records[0] || null;
  }
  return records.find((record) => equals(record.editor_id || record.editorId || record.EditorID, identifier)) || null;
}

function unresolved(identifier) {
  return {
    identifier,
    editorId: typeof identifier === "string" ? identifier : null,
    formid: null,
    recordType: null,
    plugin: null,
    winningPlugin: null,
    resolved: false
  };
}

function equals(left, right) {
  return typeof left === "string" &&
    typeof right === "string" &&
    left.toLowerCase() === right.toLowerCase();
}
