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

export async function prepareLiveProfile(manifest, profile, context) {
  const preflight = [];
  const ping = await context.mcp.callTool("mo2_ping");
  preflight.push({
    phase: "mo2-ping",
    status: ping.status === "ok" ? "PASS" : "FAIL",
    result: ping
  });

  const indexStatus = await context.mcp.callTool("mo2_record_index_status");
  if (indexNeedsBuild(indexStatus)) {
    const build = await context.mcp.callTool("mo2_build_record_index", { force_rebuild: false });
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

  const pluginStatus = await checkPlugins(manifest, profile, context);
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

export function createPatchWriter(context) {
  return async (patchRequest) => {
    return context.mcp.callTool("mo2_create_patch", patchRequest);
  };
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
        normalized.conflicts[operation.target] = await getConflictChain(operation.target, context);
      } catch {
        normalized.conflicts[operation.target] = null;
      }
    }
    return normalized;
  };
}

export function createCompileRunner(projectRoot, args = []) {
  return async () => {
    const compileArgs = args.length ? args : ["pdv_compile.mjs"];
    return {
      phase: "compile",
      name: "pdv-compiler",
      ...await runProcess("node", compileArgs, {
        cwd: path.join(projectRoot, "tools")
      })
    };
  };
}

export function createPdvVerifierRunner(projectRoot, args = []) {
  return async () => {
    const verifierArgs = args.length ? args : ["pdv_verify.mjs", "--strict-phase9"];
    return {
      phase: "project-verifier",
      name: "pdv-verifier",
      ...await runProcess("node", verifierArgs, {
        cwd: path.join(projectRoot, "tools")
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
