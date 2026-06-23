#!/usr/bin/env node
/*
 * README: Signal E2E Gate columns are one proof class per P2 signal surface.
 * manifest_parse proves the manifest row is well-formed enough to judge.
 * shell and alias_property are live-ESP readback checks from the P2 author.
 * registration, route_branch, handler_piety_sink, and route_review_status are static checks.
 * live_fill and manifest_esp_reconcile are live-ESP source-fill checks.
 * SKIP means the live Anvil MCP probe failed; SKIP is never treated as PASS.
 * GREEN means every proof column PASS. RED means at least one proof column FAIL.
 * INCOMPLETE means no FAIL, but at least one proof column SKIP.
 * The process exits 1 for every non-GREEN run so CI/pre-commit cannot go falsely green.
 * This tool is read-only except for its own generated ledger files.
 */

import fs from "node:fs";
import { spawnSync } from "node:child_process";

const ROOT = process.cwd().replace(/\\/g, "/");
const MANIFEST_PATH = `${ROOT}/references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`;
const OUT_MD = `${ROOT}/references/authoring/PDV_SignalE2EGateLedger.md`;
const OUT_CSV = `${ROOT}/references/authoring/PDV_SignalE2EGateLedger.csv`;
const SOURCE_DIR = `${ROOT}/live-source/Scripts/Source`;
const PLAYER_EVENTS_PATH = `${SOURCE_DIR}/PDV_PlayerEvents.psc`;
const EVENT_BUS_PATH = `${SOURCE_DIR}/PDV_EventBus.psc`;
const MANAGER_PATH = `${SOURCE_DIR}/PDV__ManagerQuest.psc`;
const P2_AUTHOR_PROJECT = `${ROOT}/tools/pdv-phase20-p2-receiver-author/PdvPhase20P2ReceiverAuthor.csproj`;
const MCP_CHECK = `${ROOT}/tools/pdv_mcp_check.mjs`;
const COMPLETENESS_AUDIT = `${ROOT}/tools/pdv_completeness_audit.mjs`;

const PIETY_SINK_RE = /\b(AwardCuratedSignal(?:Scaled)?|AwardPiety|ApplyDeityReaction|ApplyQuestReactionPiety|Record[A-Za-z]+Scaled|AddCommitmentSignal)\b/;
const ANTI_FARM_RE = /\bConsumeDailyRepeatMultiplier\b|\.Day\b|GetCurrentGameTime\s*\(|MarkP2SourceRoute\s*\(/;

function main() {
  assertFile(MANIFEST_PATH);
  assertFile(PLAYER_EVENTS_PATH);
  assertFile(EVENT_BUS_PATH);
  assertFile(MANAGER_PATH);

  const manifest = JSON.parse(fs.readFileSync(MANIFEST_PATH, "utf8").replace(/^\uFEFF/, ""));
  const playerEventsText = fs.readFileSync(PLAYER_EVENTS_PATH, "utf8");
  const eventBusText = fs.readFileSync(EVENT_BUS_PATH, "utf8");
  const managerText = fs.readFileSync(MANAGER_PATH, "utf8");

  const eventBusFunctions = buildFunctionMap(eventBusText);
  const managerFunctions = buildFunctionMap(managerText);
  const surfaces = buildSurfaces(manifest);
  const manifestIssues = buildManifestIssues(manifest, surfaces);
  const routeEntriesByProperty = groupBy(manifest.routeEntries ?? [], (entry) => entry.property ?? "");
  const sourceFillByProperty = buildSourceFillGroups(manifest);

  const mcp = runMcpCheck();
  if (!mcp.ok) {
    console.warn(`[PDV Signal E2E] Anvil MCP unavailable; live-ESP checks are SKIP: ${mcp.message}`);
  }

  const helpers = {
    mcp,
    routeEntries: runP2Mode("--check-route-entries"),
    exactStageGates: runP2Mode("--check-exact-stage-gates"),
    formLists: mcp.ok ? runP2Mode("--check-formlists") : skippedHelper("UNKNOWN-server-down"),
    aliasProperties: mcp.ok ? runP2Mode("--check-alias-properties") : skippedHelper("UNKNOWN-server-down"),
    sourceFill: mcp.ok ? runP2Mode("--check-source-fill") : skippedHelper("UNKNOWN-server-down"),
    completenessAudit: runCompletenessAudit(),
  };

  const helperFacts = buildHelperFacts(helpers);
  const rows = surfaces.map((surface) =>
    evaluateSurface({
      surface,
      manifestIssues,
      routeEntries: routeEntriesByProperty.get(surface.property) ?? [],
      sourceFill: sourceFillByProperty.get(surface.property) ?? emptySourceFillGroup(surface.property),
      helperFacts,
      helpers,
      playerEventsText,
      eventBusFunctions,
      managerFunctions,
    })
  );

  writeLedgers(rows, helpers);

  const counts = countBy(rows, (row) => row.verdict);
  const summary = {
    status: rows.some((row) => row.verdict !== "GREEN") ? "FAIL" : "PASS",
    surfaces: rows.length,
    counts,
    mcp: mcp.ok ? "PASS" : "SKIP",
    ledger: "references/authoring/PDV_SignalE2EGateLedger.md",
  };
  console.log(JSON.stringify(summary, null, 2));
  process.exitCode = summary.status === "PASS" ? 0 : 1;
}

function assertFile(file) {
  if (!fs.existsSync(file)) {
    throw new Error(`Required file not found: ${file}`);
  }
}

function buildSurfaces(manifest) {
  const properties = manifest.sourceProperties ?? [];
  return properties
    .filter((entry) => String(entry.property ?? "").startsWith("PDV_FLST_P2_"))
    .map((entry) => ({
      property: String(entry.property ?? "").trim(),
      race: String(entry.race ?? "").trim(),
      sourceKinds: Array.isArray(entry.sourceKinds) ? entry.sourceKinds.map(String) : [],
      routeText: String(entry.route ?? "").trim(),
      acceptedUse: String(entry.acceptedUse ?? "").trim(),
      rejectedUse: String(entry.rejectedUse ?? "").trim(),
    }))
    .sort((a, b) => a.property.localeCompare(b.property));
}

function buildManifestIssues(manifest, surfaces) {
  const issues = new Map();
  const add = (property, message) => {
    const key = property || "(global)";
    if (!issues.has(key)) issues.set(key, []);
    issues.get(key).push(message);
  };

  const seen = new Set();
  const known = new Set(surfaces.map((surface) => surface.property));
  for (const surface of surfaces) {
    if (!surface.property) add(surface.property, "Missing sourceProperties.property.");
    if (seen.has(surface.property)) add(surface.property, "Duplicate sourceProperties.property.");
    seen.add(surface.property);
    if (!surface.race) add(surface.property, "Missing sourceProperties.race.");
    if (!surface.sourceKinds.length) add(surface.property, "Missing sourceProperties.sourceKinds.");
    if (!surface.routeText) add(surface.property, "Missing sourceProperties.route.");
  }

  for (const group of manifest.sourceFillEntries ?? []) {
    const property = String(group.property ?? "").trim();
    if (!known.has(property)) {
      add(property, "sourceFillEntries group targets an undeclared source property.");
      continue;
    }
    const surface = surfaces.find((candidate) => candidate.property === property);
    const allowed = new Set(surface.sourceKinds.map((kind) => kind.toLowerCase()));
    for (const source of group.sources ?? []) {
      const sourceKind = String(source.sourceKind ?? "").trim();
      const label = String(source.editorId ?? source.formKey ?? "(unnamed source)");
      if (!sourceKind) add(property, `Source ${label} is missing sourceKind.`);
      if (sourceKind && !allowed.has(sourceKind.toLowerCase())) {
        add(property, `Source ${label} uses undeclared sourceKind ${sourceKind}.`);
      }
      if (!String(source.formKey ?? "").trim()) add(property, `Source ${label} is missing formKey.`);
      if (!String(source.status ?? "").trim()) add(property, `Source ${label} is missing status.`);
    }
  }

  for (const entry of manifest.routeEntries ?? []) {
    const property = String(entry.property ?? "").trim();
    const id = String(entry.id ?? "(missing route id)");
    if (!known.has(property)) add(property, `Route entry ${id} targets undeclared source property.`);
    if (!String(entry.reviewStatus ?? "").trim()) add(property, `Route entry ${id} is missing reviewStatus.`);
    if (!String(entry.dispatch ?? "").trim()) add(property, `Route entry ${id} is missing dispatch.`);
  }

  return issues;
}

function buildSourceFillGroups(manifest) {
  const out = new Map();
  for (const group of manifest.sourceFillEntries ?? []) {
    const property = String(group.property ?? "").trim();
    const approved = (group.sources ?? []).filter((source) =>
      String(source.status ?? "").toLowerCase() === "approved-for-fill"
    );
    out.set(property, {
      property,
      approved,
      approvedCount: approved.length,
      approvedQuestStageCount: approved.filter((source) =>
        String(source.sourceKind ?? "").toLowerCase() === "quest-stage"
      ).length,
    });
  }
  return out;
}

function emptySourceFillGroup(property) {
  return { property, approved: [], approvedCount: 0, approvedQuestStageCount: 0 };
}

function runMcpCheck() {
  if (process.env.PDV_SIGNAL_E2E_FORCE_MCP_DOWN === "1") {
    return {
      ok: false,
      status: "SKIP",
      command: "node tools/pdv_mcp_check.mjs --json",
      exitCode: null,
      message: "Forced server-down simulation via PDV_SIGNAL_E2E_FORCE_MCP_DOWN=1.",
      report: null,
      stdout: "",
      stderr: "",
    };
  }
  const result = spawnSync(process.execPath, [MCP_CHECK, "--json"], {
    cwd: ROOT,
    encoding: "utf8",
    timeout: 15_000,
    maxBuffer: 16 * 1024 * 1024,
    windowsHide: true,
  });
  const parsed = parseJsonFromOutput(result.stdout);
  const ok = result.status === 0 && parsed?.ok === true;
  return {
    ok,
    status: ok ? "PASS" : "SKIP",
    command: "node tools/pdv_mcp_check.mjs --json",
    exitCode: result.status,
    message: ok ? `Server live, profile ${parsed.profile ?? "(unknown)"}.` : (parsed?.error ?? result.stderr.trim() ?? "MCP check failed."),
    report: parsed,
    stdout: result.stdout,
    stderr: result.stderr,
  };
}

function runP2Mode(mode) {
  const result = spawnSync("dotnet", ["run", "--project", P2_AUTHOR_PROJECT, "--", mode], {
    cwd: ROOT,
    encoding: "utf8",
    timeout: 60_000,
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true,
  });
  const parsed = parseJsonFromOutput(result.stdout);
  const ok = result.status === 0 && parsed?.Status === "PASS";
  return {
    ok,
    skipped: false,
    mode,
    status: ok ? "PASS" : "FAIL",
    command: `dotnet run --project ./tools/pdv-phase20-p2-receiver-author/PdvPhase20P2ReceiverAuthor.csproj -- ${mode}`,
    exitCode: result.status,
    report: parsed,
    stdout: result.stdout,
    stderr: result.stderr,
    message: ok ? "PASS" : (parsed?.Exception ?? parsed?.Errors?.join("; ") ?? result.stderr.trim() ?? "helper failed"),
  };
}

function skippedHelper(reason) {
  return {
    ok: false,
    skipped: true,
    status: "SKIP",
    command: "(skipped)",
    exitCode: null,
    report: null,
    stdout: "",
    stderr: "",
    message: reason,
  };
}

function runCompletenessAudit() {
  const preload = `
import fs from "node:fs";
const originalWriteFileSync = fs.writeFileSync.bind(fs);
fs.writeFileSync = function(file, data, options) {
  const normalized = String(file).replace(/\\\\/g, "/");
  if (normalized.endsWith("/references/authoring/PDV_CompletenessGapLedger.md")
      || normalized.endsWith("/references/authoring/PDV_CompletenessGapLedger.csv")) {
    return;
  }
  return originalWriteFileSync(file, data, options);
};
`;
  const result = spawnSync(process.execPath, [
    "--import",
    `data:text/javascript,${encodeURIComponent(preload)}`,
    COMPLETENESS_AUDIT,
    "--json",
    "--skip-esp",
  ], {
    cwd: ROOT,
    encoding: "utf8",
    timeout: 60_000,
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true,
  });
  const parsed = parseJsonFromOutput(result.stdout);
  return {
    ok: result.status === 0,
    skipped: false,
    status: result.status === 0 ? "PASS" : "FAIL",
    command: "node tools/pdv_completeness_audit.mjs --json --skip-esp",
    exitCode: result.status,
    report: parsed,
    stdout: result.stdout,
    stderr: result.stderr,
    message: parsed ? `Completeness audit ${parsed.status ?? "completed"}; source ${parsed.sourceLayer ?? "(unknown)"}.` : (result.stderr.trim() || "completeness audit failed"),
  };
}

function parseJsonFromOutput(text) {
  const raw = String(text ?? "").trim();
  if (!raw) return null;
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end < start) return null;
  try {
    return JSON.parse(raw.slice(start, end + 1));
  } catch {
    return null;
  }
}

function buildHelperFacts(helpers) {
  return {
    formListPass: actionSet(helpers.formLists, /^(PDV_FLST_P2_[A-Za-z0-9]+) exists as FLST\.$/),
    aliasPass: actionSet(helpers.aliasProperties, /^PDV_PlayerEvents alias property (PDV_FLST_P2_[A-Za-z0-9]+) points at /),
    sourceFillConfirmed: actionCount(helpers.sourceFill, /^(PDV_FLST_P2_[A-Za-z0-9]+) contains /),
    sourceFillMissing: errorSet(helpers.sourceFill, /^(PDV_FLST_P2_[A-Za-z0-9]+) is missing /),
  };
}

function actionSet(helper, regex) {
  const out = new Set();
  for (const action of helper.report?.Actions ?? []) {
    const match = String(action).match(regex);
    if (match) out.add(match[1]);
  }
  return out;
}

function actionCount(helper, regex) {
  const out = new Map();
  for (const action of helper.report?.Actions ?? []) {
    const match = String(action).match(regex);
    if (match) out.set(match[1], (out.get(match[1]) ?? 0) + 1);
  }
  return out;
}

function errorSet(helper, regex) {
  const out = new Set();
  for (const error of helper.report?.Errors ?? []) {
    const match = String(error).match(regex);
    if (match) out.add(match[1]);
  }
  return out;
}

function evaluateSurface(ctx) {
  const {
    surface,
    manifestIssues,
    routeEntries,
    sourceFill,
    helperFacts,
    helpers,
    playerEventsText,
    eventBusFunctions,
    managerFunctions,
  } = ctx;

  const manifestParse = statusFromIssues(manifestIssues.get(surface.property) ?? [], "Manifest row parses.");
  const shell = liveStatus(helpers.formLists, helperFacts.formListPass.has(surface.property), `${surface.property} exists as FLST.`);
  const aliasProperty = liveStatus(helpers.aliasProperties, helperFacts.aliasPass.has(surface.property), `${surface.property} alias property is wired.`);
  const registration = evaluateRegistration(surface, playerEventsText);
  const routeBranch = evaluateRouteBranch(surface, routeEntries, playerEventsText);
  const routeFunctions = unique([
    ...extractRouteFunctions(surface.routeText),
    ...routeEntries.flatMap((entry) => extractRouteFunctions(String(entry.dispatch ?? ""))),
  ]);
  const handlerReach = evaluateHandlerReach(routeFunctions, eventBusFunctions, managerFunctions, routeBranch.preRouteAntiFarm);
  const routeReview = evaluateRouteReview(routeEntries);
  const liveFill = evaluateLiveFill(helpers.sourceFill, helperFacts, sourceFill);
  const manifestEsp = evaluateManifestEspReconcile(helpers.sourceFill, helperFacts, sourceFill);

  const checks = {
    manifest_parse: manifestParse,
    shell,
    alias_property: aliasProperty,
    registration,
    route_branch: routeBranch,
    handler_piety_sink: handlerReach,
    route_review_status: routeReview,
    live_fill: liveFill,
    manifest_esp_reconcile: manifestEsp,
  };
  const verdict = deriveVerdict(checks);
  const failingStep = firstProblem(checks);
  const detail = Object.entries(checks)
    .filter(([, check]) => check.status !== "PASS")
    .map(([name, check]) => `${name}: ${check.detail}`)
    .join(" | ") || "All proof columns passed.";

  return {
    property: surface.property,
    race: surface.race,
    sourceKinds: surface.sourceKinds.join(";"),
    routeFunctions: routeFunctions.join(";"),
    handlers: handlerReach.handlers.join(";"),
    checks,
    verdict,
    failing_step: failingStep,
    detail,
  };
}

function statusFromIssues(issues, passDetail) {
  if (!issues.length) return { status: "PASS", detail: passDetail };
  return { status: "FAIL", detail: issues.join("; ") };
}

function liveStatus(helper, predicate, passDetail) {
  if (helper.skipped) return { status: "SKIP", detail: helper.message };
  if (!helper.ok) return { status: "FAIL", detail: helper.message };
  if (predicate) return { status: "PASS", detail: passDetail };
  return { status: "FAIL", detail: "Live helper did not confirm this property." };
}

function evaluateRegistration(surface, playerEventsText) {
  if (!surface.sourceKinds.map((kind) => kind.toLowerCase()).includes("quest-stage")) {
    return { status: "PASS", detail: "No quest-stage source kind declared; registration not required." };
  }
  const snippet = `RegisterQuestStageList(${surface.property})`;
  if (playerEventsText.includes(snippet)) {
    return { status: "PASS", detail: `${snippet} is present.` };
  }
  return { status: "FAIL", detail: `${snippet} is missing.` };
}

function evaluateRouteBranch(surface, routeEntries, playerEventsText) {
  const nonQuestKinds = surface.sourceKinds.filter((kind) => kind.toLowerCase() !== "quest-stage");
  const expectedRouteFunctions = extractRouteFunctions(surface.routeText);
  const details = [];
  let failed = false;
  let preRouteAntiFarm = false;

  if (nonQuestKinds.length > 0) {
    const branch = findBranch(playerEventsText, `ShouldRouteP2Source(${surface.property},`);
    if (!branch) {
      failed = true;
      details.push(`Missing ShouldRouteP2Source branch for ${surface.property}.`);
    } else {
      preRouteAntiFarm = true;
      const missingRoutes = expectedRouteFunctions.filter((route) => !branch.includes(`.${route}(`));
      if (missingRoutes.length) {
        failed = true;
        details.push(`Source branch missing dispatch: ${missingRoutes.join(", ")}.`);
      } else {
        details.push("ShouldRouteP2Source branch dispatches the manifest route.");
      }
    }
  }

  if (routeEntries.length > 0) {
    const missing = routeEntries.filter((entry) => !routeEntryPresent(entry, playerEventsText));
    if (missing.length) {
      failed = true;
      details.push(`Missing exact-stage route entries: ${missing.map((entry) => entry.id).join(", ")}.`);
    } else {
      preRouteAntiFarm = true;
      details.push(`${routeEntries.length} exact-stage route entries are present.`);
    }
  }

  if (routeEntries.length === 0 && nonQuestKinds.length === 0 && surface.sourceKinds.some((kind) => kind.toLowerCase() === "quest-stage")) {
    failed = true;
    details.push("Quest-stage-only surface has no exact routeEntries.");
  }

  return {
    status: failed ? "FAIL" : "PASS",
    detail: details.join(" ") || "No route branch required by current source kinds.",
    preRouteAntiFarm,
  };
}

function routeEntryPresent(entry, playerEventsText) {
  const property = String(entry.property ?? "");
  const routeKey = String(entry.routeKey ?? "");
  const expectedFormId = Number(entry.expectedFormId);
  const approvedStage = Number(entry.approvedStage);
  const branchSnippet = `ShouldRouteP2QuestStage(${property}, sourceQuest, ${expectedFormId}, ${approvedStage}, "${routeKey}", newStage)`;
  const groupedBranchSnippet = String(entry.mutualExclusionGroup ?? "").trim()
    ? `ShouldRouteP2QuestStageGroup(${property}, sourceQuest, ${expectedFormId}, ${approvedStage}, "${routeKey}", "${entry.mutualExclusionGroup}", newStage)`
    : "";
  const dispatch = String(entry.dispatch ?? "").replace("PDV_EventBusService.", "");
  return (playerEventsText.includes(branchSnippet) || (groupedBranchSnippet && playerEventsText.includes(groupedBranchSnippet)))
    && (!dispatch || playerEventsText.includes(dispatch));
}

function evaluateHandlerReach(routeFunctions, eventBusFunctions, managerFunctions, preRouteAntiFarm) {
  const routeDetails = [];
  const handlers = [];
  let anyReach = false;
  let anyAntiFarm = false;

  for (const route of routeFunctions) {
    const routeBody = eventBusFunctions.get(route);
    if (!routeBody) {
      routeDetails.push(`${route}: missing EventBus function`);
      continue;
    }
    const routeHandlers = collectRouteHandlers(route, eventBusFunctions);
    if (!routeHandlers.length) {
      routeDetails.push(`${route}: no manager Handle* call`);
      continue;
    }
    for (const handler of routeHandlers) {
      handlers.push(handler);
      const reach = analyzeHandler(handler, managerFunctions);
      if (reach.reachesSink) anyReach = true;
      if (reach.hasAntiFarm || preRouteAntiFarm) anyAntiFarm = true;
      routeDetails.push(`${route}->${handler}: ${reach.detail}`);
    }
  }

  if (!routeFunctions.length) {
    return { status: "FAIL", detail: "No route function declared for this surface.", handlers: [] };
  }
  if (anyReach && anyAntiFarm) {
    return { status: "PASS", detail: routeDetails.join(" "), handlers: unique(handlers) };
  }
  const reason = !anyReach ? "No route handler reaches a piety/relation sink within depth 2." : "No anti-farm guard found in handler/helper or pre-route branch.";
  return { status: "FAIL", detail: `${reason} ${routeDetails.join(" ")}`, handlers: unique(handlers) };
}

function collectRouteHandlers(route, eventBusFunctions, seen = new Set()) {
  if (seen.has(route)) return [];
  seen.add(route);
  const body = eventBusFunctions.get(route);
  if (!body) return [];

  const handlers = [...body.matchAll(/\bPDV_Manager\.(Handle[A-Za-z0-9_]+)\s*\(/g)].map((match) => match[1]);
  for (const match of body.matchAll(/\b(Route[A-Za-z0-9_]+)\s*\(/g)) {
    const nextRoute = match[1];
    if (nextRoute !== route && eventBusFunctions.has(nextRoute)) {
      handlers.push(...collectRouteHandlers(nextRoute, eventBusFunctions, seen));
    }
  }
  return unique(handlers);
}

function analyzeHandler(handler, managerFunctions) {
  const body = managerFunctions.get(handler);
  if (!body) {
    return { reachesSink: false, hasAntiFarm: false, detail: "missing manager handler" };
  }
  if (PIETY_SINK_RE.test(body)) {
    return {
      reachesSink: true,
      hasAntiFarm: ANTI_FARM_RE.test(body),
      detail: ANTI_FARM_RE.test(body) ? "direct sink with handler anti-farm" : "direct sink without handler anti-farm",
    };
  }

  const calls = unique([...body.matchAll(/\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)].map((match) => match[1]))
    .filter((name) => name !== handler);
  for (const call of calls) {
    const calleeBody = managerFunctions.get(call);
    if (calleeBody && PIETY_SINK_RE.test(calleeBody)) {
      const hasAntiFarm = ANTI_FARM_RE.test(body) || ANTI_FARM_RE.test(calleeBody);
      return {
        reachesSink: true,
        hasAntiFarm,
        detail: hasAntiFarm ? `sink via ${call} with anti-farm` : `sink via ${call} without anti-farm`,
      };
    }
  }
  return { reachesSink: false, hasAntiFarm: ANTI_FARM_RE.test(body), detail: "no sink within depth 2" };
}

function evaluateRouteReview(routeEntries) {
  if (!routeEntries.length) {
    return { status: "PASS", detail: "No routeEntries declared for this surface." };
  }
  const blocked = routeEntries.filter((entry) =>
    String(entry.reviewStatus ?? "").toLowerCase() !== "approved-live-source-fill"
  );
  if (blocked.length) {
    return {
      status: "FAIL",
      detail: `Static-only or unapproved routeEntries: ${blocked.map((entry) => `${entry.id}:${entry.reviewStatus ?? "(missing)"}`).join(", ")}.`,
    };
  }
  return { status: "PASS", detail: "All routeEntries are approved-live-source-fill." };
}

function evaluateLiveFill(helper, helperFacts, sourceFill) {
  if (helper.skipped) return { status: "SKIP", detail: helper.message };
  if (!helper.ok) return { status: "FAIL", detail: helper.message };
  if (helperFacts.sourceFillMissing.has(sourceFill.property)) {
    return { status: "FAIL", detail: "Source-fill helper reports missing live ESP entries." };
  }
  if (sourceFill.approvedCount <= 0) {
    return { status: "FAIL", detail: "No approved sourceFillEntries declared for this surface." };
  }
  const confirmed = helperFacts.sourceFillConfirmed.get(sourceFill.property) ?? 0;
  if (confirmed < sourceFill.approvedCount) {
    return { status: "FAIL", detail: `Source-fill helper confirmed ${confirmed}/${sourceFill.approvedCount} approved entries.` };
  }
  return { status: "PASS", detail: `Source-fill helper confirmed ${confirmed}/${sourceFill.approvedCount} approved entries in the live ESP.` };
}

function evaluateManifestEspReconcile(helper, helperFacts, sourceFill) {
  if (helper.skipped) return { status: "SKIP", detail: helper.message };
  if (!helper.ok) return { status: "FAIL", detail: helper.message };
  if (sourceFill.approvedCount <= 0) {
    return { status: "FAIL", detail: "Manifest has no approved sourceFillEntries to reconcile against the ESP." };
  }
  const confirmed = helperFacts.sourceFillConfirmed.get(sourceFill.property) ?? 0;
  if (confirmed === sourceFill.approvedCount && !helperFacts.sourceFillMissing.has(sourceFill.property)) {
    return { status: "PASS", detail: "Manifest approved entries match source-fill readback for this surface." };
  }
  return { status: "FAIL", detail: `Manifest/ESP source-fill drift: ${confirmed}/${sourceFill.approvedCount} entries confirmed.` };
}

function deriveVerdict(checks) {
  const statuses = Object.values(checks).map((check) => check.status);
  if (statuses.includes("FAIL")) return "RED";
  if (statuses.includes("SKIP")) return "INCOMPLETE";
  return "GREEN";
}

function firstProblem(checks) {
  for (const [name, check] of Object.entries(checks)) {
    if (check.status === "FAIL") return name;
  }
  for (const [name, check] of Object.entries(checks)) {
    if (check.status === "SKIP") return name;
  }
  return "";
}

function buildFunctionMap(text) {
  const functions = new Map();
  const re = /^\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)[\s\S]*?^\s*EndFunction/gim;
  for (const match of text.matchAll(re)) {
    functions.set(match[1], match[0]);
  }
  return functions;
}

function extractRouteFunctions(text) {
  return unique([...String(text ?? "").matchAll(/\b(Route[A-Za-z0-9_]+)\s*\(/g)].map((match) => match[1]));
}

function findBranch(text, needle) {
  const index = text.indexOf(needle);
  if (index < 0) return "";
  const start = text.lastIndexOf("\n", index) + 1;
  const end = text.indexOf("\n    endIf", index);
  if (end < 0) return text.slice(start, Math.min(text.length, start + 800));
  return text.slice(start, end + 10);
}

function groupBy(items, keyFn) {
  const out = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!out.has(key)) out.set(key, []);
    out.get(key).push(item);
  }
  return out;
}

function countBy(items, keyFn) {
  const out = {};
  for (const item of items) {
    const key = keyFn(item);
    out[key] = (out[key] ?? 0) + 1;
  }
  return out;
}

function unique(items) {
  return [...new Set(items.filter(Boolean))];
}

function writeLedgers(rows, helpers) {
  const counts = countBy(rows, (row) => row.verdict);
  const statusCounts = {};
  for (const row of rows) {
    for (const [name, check] of Object.entries(row.checks)) {
      statusCounts[`${name}.${check.status}`] = (statusCounts[`${name}.${check.status}`] ?? 0) + 1;
    }
  }

  const md = [];
  md.push("# PDV Signal E2E Gate Ledger");
  md.push("");
  md.push("GENERATED by tools/pdv_signal_e2e_gate.mjs - do not hand-edit.");
  md.push("");
  md.push("GREEN requires every proof column to PASS. RED means at least one FAIL. INCOMPLETE means at least one SKIP and no FAIL.");
  md.push("SKIP is used only for live-ESP checks when the Anvil MCP liveness probe is down.");
  md.push("");
  md.push(`Summary: ${Object.entries(counts).map(([key, value]) => `${key}=${value}`).join(" | ")}`);
  md.push(`MCP: ${helpers.mcp.status} - ${asciiSafe(helpers.mcp.message)}`);
  md.push("");
  md.push("## Helper Invocations");
  md.push("");
  for (const [name, helper] of Object.entries(helpers)) {
    md.push(`- ${name}: ${helper.status}${helper.exitCode === null ? "" : ` (exit ${helper.exitCode})`} - ${asciiSafe(helper.command)} - ${asciiSafe(helper.message)}`);
  }
  md.push("");
  md.push("## Column Counts");
  md.push("");
  for (const [key, value] of Object.entries(statusCounts).sort()) {
    md.push(`- ${key}: ${value}`);
  }
  md.push("");
  md.push("## RED / INCOMPLETE By Failing Step");
  md.push("");
  const problemRows = rows.filter((row) => row.verdict !== "GREEN");
  const byStep = groupBy(problemRows, (row) => row.failing_step || "(none)");
  for (const [step, stepRows] of [...byStep.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
    md.push(`### ${step} (${stepRows.length})`);
    md.push("");
    for (const row of stepRows) {
      md.push(`- ${row.verdict} ${row.property} (${row.race || "unknown"}): ${asciiSafe(row.detail)}`);
    }
    md.push("");
  }
  md.push("## Per-Surface Ledger");
  md.push("");
  md.push("| Property | Race | Kinds | Manifest | Shell | Alias | Registration | Route Branch | Handler Sink | Route Review | Live Fill | Reconcile | Verdict | Detail |");
  md.push("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|");
  for (const row of rows) {
    md.push([
      row.property,
      row.race,
      row.sourceKinds,
      row.checks.manifest_parse.status,
      row.checks.shell.status,
      row.checks.alias_property.status,
      row.checks.registration.status,
      row.checks.route_branch.status,
      row.checks.handler_piety_sink.status,
      row.checks.route_review_status.status,
      row.checks.live_fill.status,
      row.checks.manifest_esp_reconcile.status,
      row.verdict,
      row.detail,
    ].map((cell) => `| ${markdownCell(cell)} `).join("") + "|");
  }
  fs.writeFileSync(OUT_MD, md.join("\n") + "\n", "utf8");

  const cols = [
    "property",
    "race",
    "sourceKinds",
    "routeFunctions",
    "handlers",
    "manifest_parse",
    "shell",
    "alias_property",
    "registration",
    "route_branch",
    "handler_piety_sink",
    "route_review_status",
    "live_fill",
    "manifest_esp_reconcile",
    "verdict",
    "failing_step",
    "detail",
  ];
  const csv = [cols.join(",")];
  for (const row of rows) {
    csv.push(cols.map((col) => {
      if (row.checks[col]) return csvCell(row.checks[col].status);
      return csvCell(row[col]);
    }).join(","));
  }
  fs.writeFileSync(OUT_CSV, csv.join("\r\n") + "\r\n", "utf8");
}

function markdownCell(value) {
  return asciiSafe(value).replace(/\|/g, "/");
}

function csvCell(value) {
  const text = asciiSafe(value);
  if (/[",\r\n]/.test(text)) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}

function asciiSafe(value) {
  return String(value ?? "")
    .replace(/\u2014/g, "--")
    .replace(/[\u2010\u2011\u2012\u2013]/g, "-")
    .replace(/\u2192/g, "->")
    .replace(/\u2190/g, "<-")
    .replace(/\u2265/g, ">=")
    .replace(/\u2264/g, "<=")
    .replace(/\u2026/g, "...")
    .replace(/[\u2018\u2019]/g, "'")
    .replace(/[\u201c\u201d]/g, "\"")
    .replace(/\u00a0/g, " ")
    .replace(/[^\x00-\x7F]/g, "?");
}

main();
