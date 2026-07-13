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
const RESERVED_SIGNALS_PATH = `${ROOT}/tools/pdv_reserved_signals.json`;
const RESERVED_EVENTS_PATH = `${ROOT}/tools/pdv_reserved_events.json`;
const RESERVED_ROUTES_PATH = `${ROOT}/tools/pdv_reserved_routes.json`;
const EVENT_TYPES_PATH = `${SOURCE_DIR}/PDV_EventTypes.psc`;
const ACTION_ROUTER_PATH = `${SOURCE_DIR}/PDV_ActionRouter.psc`;
const LIKES_CSV_PATH = `${ROOT}/references/authoring/PDV_DeityLikesDislikes.csv`;
const PRINCE_LIKES_CSV_PATH = `${ROOT}/references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv`;
const P2_AUTHOR_PROJECT = `${ROOT}/tools/pdv-phase20-p2-receiver-author/PdvPhase20P2ReceiverAuthor.csproj`;
const MCP_CHECK = `${ROOT}/tools/pdv_mcp_check.mjs`;
const COMPLETENESS_AUDIT = `${ROOT}/tools/pdv_completeness_audit.mjs`;

const PIETY_SINK_RE = /\b(AwardCuratedSignal(?:Scaled)?|AwardPiety|ApplyDeityReaction|ApplyQuestReactionPiety|Record[A-Za-z]+Scaled|AddCommitmentSignal|ApplyBretonInitialChoice)\b/;
const ANTI_FARM_RE = /\bConsumeDailyRepeatMultiplier\b|\.Day\b|GetCurrentGameTime\s*\(|MarkP2SourceRoute\s*\(/;
const MAX_HANDLER_SINK_DEPTH = 3;

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
    completenessAudit: runCompletenessAudit(mcp),
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

  const curatedParity = evaluateCuratedSignalParity(managerText);
  const dispatchCoverage = evaluateCuratedSignalDispatchCoverage();
  const eventCoverage = evaluateEventEmissionCoverage();
  const routeReach = evaluateRouteReachability();
  const csvFreshness = evaluateCsvCodegenFreshness();
  const killClassification = evaluateKillClassification();

  writeLedgers(rows, helpers, curatedParity, dispatchCoverage, eventCoverage, routeReach, csvFreshness, killClassification);

  const counts = countBy(rows, (row) => row.verdict);
  const surfacesPass = !rows.some((row) => row.verdict !== "GREEN");
  const declarationGatesOk = dispatchCoverage.ok && eventCoverage.ok && routeReach.ok && csvFreshness.ok && killClassification.ok;
  const summary = {
    status: surfacesPass && curatedParity.ok && declarationGatesOk ? "PASS" : "FAIL",
    surfaces: rows.length,
    counts,
    curatedSignalParity: {
      status: curatedParity.ok ? "PASS" : "FAIL",
      references: curatedParity.total,
      ok: curatedParity.okCount,
      gaps: curatedParity.gaps.length,
      cross: curatedParity.cross.length,
      byIndex: curatedParity.byIndex.length,
    },
    curatedSignalDispatch: {
      status: dispatchCoverage.ok ? "PASS" : "FAIL",
      declaredScored: dispatchCoverage.declaredScored,
      dispatched: dispatchCoverage.dispatched,
      undispatched: dispatchCoverage.undispatched,
      reservedKnownGaps: dispatchCoverage.knownGaps.length,
      failures: dispatchCoverage.failures.length,
      staleLedger: dispatchCoverage.staleLedger.length,
      ledgerError: dispatchCoverage.ledgerError.length,
    },
    eventEmissionCoverage: {
      status: eventCoverage.ok ? "PASS" : "FAIL",
      declared: eventCoverage.declared,
      emitted: eventCoverage.emitted,
      deadPromises: eventCoverage.deadPromises,
      deadConstants: eventCoverage.deadConstants,
      reservedKnownGaps: eventCoverage.knownGaps.length,
      failures: eventCoverage.failures.length,
      staleLedger: eventCoverage.staleLedger.length,
    },
    routeReachability: {
      status: routeReach.ok ? "PASS" : "FAIL",
      targets: routeReach.targets,
      reachable: routeReach.reachable,
      orphans: routeReach.orphans,
      reservedKnownGaps: routeReach.knownGaps.length,
      failures: routeReach.failures.length,
      staleLedger: routeReach.staleLedger.length,
    },
    killClassification: {
      status: killClassification.ok ? "PASS" : "FAIL",
      failures: killClassification.failures,
    },
    csvCodegenFreshness: {
      status: csvFreshness.ok ? "PASS" : "FAIL",
      csvIds: csvFreshness.csvIds,
      seededIds: csvFreshness.seededIds,
      version: csvFreshness.version,
      csvNotSeeded: csvFreshness.csvNotSeeded.length,
      seededNotCsv: csvFreshness.seededNotCsv.length,
      seededNotInSuperset: csvFreshness.seededNotInSuperset.length,
    },
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
    // formKey metadata must agree with the runtime expectedFormId (the gate validates the
    // latter against the ESP, so a drifted formKey silently points at the wrong record --
    // the class that mis-keyed DA05/DA02/MG08 to PlacedObjects).
    const fk = String(entry.formKey ?? "").split(":")[0].toUpperCase();
    const efid = entry.expectedFormId != null ? Number(entry.expectedFormId).toString(16).toUpperCase().padStart(6, "0") : "";
    if (fk && efid && fk !== efid) {
      add(property, `Route entry ${id} formKey ${fk} != expectedFormId 0x${efid} (metadata drift).`);
    }
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

function runCompletenessAudit(mcp) {
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
  // With houseCARL up, run the full ESP-backed audit (it resolves EditorIDs the
  // source-only --skip-esp view flags as gaps, and PASSes). Fall back to --skip-esp
  // only when the Anvil MCP probe is down, so the gate never blocks on a missing server.
  const skipEsp = !mcp.ok;
  const auditArgs = [
    "--import",
    `data:text/javascript,${encodeURIComponent(preload)}`,
    COMPLETENESS_AUDIT,
    "--json",
  ];
  if (skipEsp) auditArgs.push("--skip-esp");
  const result = spawnSync(process.execPath, auditArgs, {
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
    command: `node tools/pdv_completeness_audit.mjs --json${skipEsp ? " --skip-esp" : ""}`,
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

  const result = findHandlerSinkPath(handler, managerFunctions, MAX_HANDLER_SINK_DEPTH, new Set(), [], false);
  if (result.reachesSink) {
    const sinkPath = result.path.slice(1).join("->");
    const via = sinkPath.length ? ` via ${sinkPath}` : "";
    return {
      reachesSink: true,
      hasAntiFarm: result.hasAntiFarm,
      detail: result.hasAntiFarm ? `sink${via} with anti-farm` : `sink${via} without anti-farm`,
    };
  }

  return {
    reachesSink: false,
    hasAntiFarm: result.hasAntiFarm,
    detail: `no sink within depth ${MAX_HANDLER_SINK_DEPTH}`,
  };
}

function findHandlerSinkPath(functionName, managerFunctions, remainingDepth, seen, path, inheritedAntiFarm) {
  if (seen.has(functionName)) {
    return { reachesSink: false, hasAntiFarm: inheritedAntiFarm, path };
  }
  const body = managerFunctions.get(functionName);
  if (!body) {
    return { reachesSink: false, hasAntiFarm: inheritedAntiFarm, path };
  }

  const nextPath = [...path, functionName];
  const hasAntiFarm = inheritedAntiFarm || ANTI_FARM_RE.test(body);
  if (PIETY_SINK_RE.test(body)) {
    return { reachesSink: true, hasAntiFarm, path: nextPath };
  }
  if (remainingDepth <= 0) {
    return { reachesSink: false, hasAntiFarm, path: nextPath };
  }

  const nextSeen = new Set(seen);
  nextSeen.add(functionName);
  const calls = unique([...body.matchAll(/\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)].map((match) => match[1]))
    .filter((name) => name !== functionName && managerFunctions.has(name));
  for (const call of calls) {
    const result = findHandlerSinkPath(call, managerFunctions, remainingDepth - 1, nextSeen, nextPath, hasAntiFarm);
    if (result.reachesSink) {
      return result;
    }
  }

  return { reachesSink: false, hasAntiFarm, path: nextPath };
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

// Curated-signal parity: the Kyne silent-zero class. Every
// AwardCuratedSignal[Scaled](deity, deity.SIGNAL_X, ...) routes the award through
// deity.ScoreCuratedSignal(SIGNAL_X); if the awarded deity script does not BOTH define
// the SIGNAL_X const AND have a `== SIGNAL_X` branch in ScoreCuratedSignal, the award
// silently scores 0.0 -- the call site looks wired but banks nothing. Pure static
// analysis over the live .psc tree; no server, always runs.
function evaluateCuratedSignalParity(managerText) {
  // Manager property name -> declared deity script type (e.g. PDV_Tuwhacca -> PDV_Deity_Tuwhacca).
  const propType = new Map();
  for (const m of managerText.matchAll(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s+Property\s+(PDV_[A-Za-z0-9_]+)\s+Auto\b/gim)) {
    propType.set(m[2], m[1]);
  }

  const scriptCache = new Map();
  const readScript = (type) => {
    if (scriptCache.has(type)) return scriptCache.get(type);
    const path = `${SOURCE_DIR}/${type}.psc`;
    const entry = fs.existsSync(path)
      ? (() => { const text = fs.readFileSync(path, "utf8"); return { text, fns: buildFunctionMap(text) }; })()
      : null;
    scriptCache.set(type, entry);
    return entry;
  };
  const resolveType = (prop) => {
    const declared = propType.get(prop);
    if (declared && fs.existsSync(`${SOURCE_DIR}/${declared}.psc`)) return declared;
    const fallback = `PDV_Deity_${prop.replace(/^PDV_/, "")}`;
    if (fs.existsSync(`${SOURCE_DIR}/${fallback}.psc`)) return fallback;
    return declared || fallback; // best-guess name for the message even when missing
  };

  const files = fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));
  const refs = [];
  const byIndex = [];
  const awardRe = /\bAwardCuratedSignal(?:Scaled)?\s*\(\s*(PDV_[A-Za-z0-9_]+)\s*,\s*(PDV_[A-Za-z0-9_]+)\.(SIGNAL_[A-Za-z0-9_]+)/g;
  const byIndexRe = /\bAwardCuratedSignalByIndex\s*\(/g;
  for (const file of files) {
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    if (!text.includes("AwardCuratedSignal")) continue;
    for (const m of text.matchAll(awardRe)) {
      refs.push({ file, awarded: m[1], owner: m[2], signal: m[3] });
    }
    for (const m of text.matchAll(byIndexRe)) {
      const lineStart = text.lastIndexOf("\n", m.index) + 1;
      const lineHead = text.slice(lineStart, m.index);
      // Skip the helper's own definition line ("...Function AwardCuratedSignalByIndex(").
      if (/\bFunction\s+$/.test(lineHead)) continue;
      // Enclosing function: the by-index path is debug/MCM-only seeding, so a Debug* caller
      // is allowed; only a non-debug (production dynamic-dispatch) call site is manual-review.
      let enclosing = "";
      for (const fm of text.slice(0, m.index).matchAll(/(?:^|\n)\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)) {
        enclosing = fm[1];
      }
      if (/Debug/i.test(enclosing)) continue;
      const lineEndRaw = text.indexOf("\n", m.index);
      const line = text.slice(lineStart, lineEndRaw < 0 ? text.length : lineEndRaw).trim();
      byIndex.push({ file, context: `${enclosing || "?"}: ${line}` });
    }
  }

  const gaps = [];
  const cross = [];
  let okCount = 0;
  for (const ref of refs) {
    if (ref.awarded !== ref.owner) {
      cross.push(ref); // signal const read from a different deity than the one scoring it
      continue;
    }
    const type = resolveType(ref.awarded);
    const script = readScript(type);
    if (!script) {
      gaps.push({ ...ref, reason: `missing deity script ${type}.psc` });
      continue;
    }
    const defines = new RegExp(`Property\\s+${ref.signal}\\b`).test(script.text);
    const scoreBody = script.fns.get("ScoreCuratedSignal") || "";
    const handles = new RegExp(`==\\s*${ref.signal}\\b`).test(scoreBody);
    if (defines && handles) {
      okCount += 1;
    } else if (!defines) {
      gaps.push({ ...ref, reason: `${type} does not define ${ref.signal}` });
    } else {
      gaps.push({ ...ref, reason: `${type}.ScoreCuratedSignal has no '== ${ref.signal}' branch (silent zero)` });
    }
  }

  if (process.env.PDV_SIGNAL_E2E_PARITY_SELFTEST === "1") {
    // Deterministic FAIL-direction self-test: inject a guaranteed silent-zero ref so the
    // checker is provably not a can-only-say-PASS no-op.
    gaps.push({ file: "(selftest)", awarded: "PDV_Hist", owner: "PDV_Hist", signal: "SIGNAL_SELFTEST_NONEXISTENT", reason: "selftest injected gap" });
  }

  const ok = gaps.length === 0 && cross.length === 0 && byIndex.length === 0;
  return { total: refs.length, okCount, gaps, cross, byIndex, ok };
}

function loadReservedLedger(ledgerPath) {
  if (!fs.existsSync(ledgerPath)) return {};
  try {
    const raw = JSON.parse(fs.readFileSync(ledgerPath, "utf8").replace(/^﻿/, ""));
    const out = {};
    for (const [k, v] of Object.entries(raw)) {
      if (k.startsWith("_")) continue; // _README / _seededDate metadata keys, never entries
      out[k] = v;
    }
    return out;
  } catch (err) {
    return { __error: String((err && err.message) || err) };
  }
}

function loadReservedSignals() {
  return loadReservedLedger(RESERVED_SIGNALS_PATH);
}

// Strip Papyrus comments (block ;/ ... /; and line ;...) so token scans do not
// count commented-out or documentation references as live code.
function stripPapyrusComments(text) {
  return text.replace(/;\/[\s\S]*?\/;/g, "").replace(/;[^\n]*/g, "");
}

// Registry-driven dispatch coverage: the INVERSE of evaluateCuratedSignalParity, and the
// check that closes the dead-signal class found 2026-07-06. Parity proves "every AWARDED
// signal is scored"; this proves "every DECLARED + SCORED signal is really AWARDED from a
// non-debug, non-display trigger." A signal that is declared (Int Property SIGNAL_X) and
// handled in ScoreCuratedSignal but never passed to AwardCuratedSignal[Scaled] can never
// bank piety. The whole suite missed this because every prior check anchored on the DISPATCH
// side (award call sites) reasoning forward to scoring, so a zero-dispatch signal was
// structurally invisible; this one enumerates the DECLARATION side (the deity-script
// SIGNAL_ registry) and computes {declared+scored} MINUS {really-dispatched}. Undispatched
// signals must be either wired or explicitly logged in tools/pdv_reserved_signals.json.
// Pure static source check -- no server, always runs.
function evaluateCuratedSignalDispatchCoverage() {
  const deityFiles = fs.readdirSync(SOURCE_DIR).filter((f) => /^PDV_Deity_.*\.psc$/i.test(f));
  // 1. Enumerate the audit REGISTRY from declarations (not from dispatch).
  const declared = [];
  const declRe = /^\s*Int\s+Property\s+(SIGNAL_[A-Z0-9_]+)\s*=\s*-?\d+\s+AutoReadOnly/gim;
  for (const file of deityFiles) {
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    // Deity-script filename -> manager property/owner (PDV_Deity_Malacath.psc -> PDV_Malacath).
    const owner = `PDV_${file.replace(/^PDV_Deity_/i, "").replace(/\.psc$/i, "")}`;
    const scoreBody = buildFunctionMap(text).get("ScoreCuratedSignal") || "";
    for (const m of text.matchAll(declRe)) {
      const signal = m[1];
      // "Scored" == ScoreCuratedSignal has a '== SIGNAL_X' branch (a declared-but-unhandled
      // signal is the separate parity class, not this one).
      const scored = new RegExp(`==\\s*${signal}\\b`).test(scoreBody);
      declared.push({ owner, signal, file, scored, key: `${owner}.${signal}` });
    }
  }
  // 2. Build the REAL-dispatch set: AwardCuratedSignal[Scaled] call sites only, excluding
  //    Debug* enclosing functions and the display-phrase maps. awardRe requires an actual
  //    Award call, so a bare SIGNAL_ reference inside HumanizeCuratedSignalReason /
  //    CuratedSignalDriverReason (a token->phrase map) never matches -- that false-positive
  //    is exactly what let completeness_audit mark BLOOD_KIN as "sent". AwardCuratedSignalByIndex
  //    is dynamic/debug seeding and deliberately does NOT count as coverage.
  const allFiles = fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));
  const awardRe = /\bAwardCuratedSignal(?:Scaled)?\s*\(\s*(PDV_[A-Za-z0-9_]+)\s*,\s*(PDV_[A-Za-z0-9_]+)\.(SIGNAL_[A-Za-z0-9_]+)/g;
  const DISPLAY_FNS = /^(HumanizeCuratedSignalReason|CuratedSignalDriverReason)$/;
  const dispatched = new Set();
  for (const file of allFiles) {
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    if (!text.includes("AwardCuratedSignal")) continue;
    for (const m of text.matchAll(awardRe)) {
      let enclosing = "";
      for (const fm of text.slice(0, m.index).matchAll(/(?:^|\n)\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/g)) {
        enclosing = fm[1];
      }
      if (/Debug/i.test(enclosing) || DISPLAY_FNS.test(enclosing)) continue;
      dispatched.add(`${m[2]}.${m[3]}`); // owner.signal
    }
  }
  // 3. Diff: scored-declared MINUS really-dispatched.
  const undispatched = declared
    .filter((d) => d.scored && !dispatched.has(d.key))
    .map((d) => ({ owner: d.owner, signal: d.signal, file: d.file, key: d.key }));

  if (process.env.PDV_SIGNAL_DISPATCH_SELFTEST === "1") {
    // FAIL-direction self-test: a scored+declared signal with no dispatch and no ledger entry
    // must surface, proving the checker is not a can-only-say-PASS no-op.
    undispatched.push({ owner: "PDV_Hist", signal: "SIGNAL_SELFTEST_UNDISPATCHED", file: "(selftest)", key: "PDV_Hist.SIGNAL_SELFTEST_UNDISPATCHED" });
  }

  // 4. Ledger split: listed => documented known-gap (informational); unlisted => hard FAIL.
  const reserved = loadReservedSignals();
  const ledgerError = reserved.__error ? [reserved.__error] : [];
  const knownGaps = [];
  const failures = [];
  for (const u of undispatched) {
    if (reserved[u.key]) knownGaps.push({ ...u, reason: (reserved[u.key] && reserved[u.key].reason) || "(no reason given)" });
    else failures.push(u);
  }
  // 5. Anti-rot: a ledger entry that is no longer undispatched (now wired, or no longer
  //    declared/scored) is stale and must be removed -- also a FAIL.
  const undispatchedKeys = new Set(undispatched.map((u) => u.key));
  const staleLedger = Object.keys(reserved)
    .filter((k) => !k.startsWith("__"))
    .filter((k) => !undispatchedKeys.has(k));

  const ok = failures.length === 0 && staleLedger.length === 0 && ledgerError.length === 0;
  return {
    declaredTotal: declared.length,
    declaredScored: declared.filter((d) => d.scored).length,
    dispatched: dispatched.size,
    undispatched: undispatched.length,
    knownGaps,
    failures,
    staleLedger,
    ledgerError,
    ok,
  };
}

// Gate A -- EVT emission coverage: the event-type sibling of dispatch coverage, closing
// the class that produced the five manually-found dead events (341/360/361/362/364/365)
// and the 2026-07-07 finds (350/351/335/366 dead data rows; 310/311/312 dead constants).
// Registry = every `Int Property EVT_X = N` in PDV_EventTypes.psc. An event is EMITTED if
// an emitter script references its token on a live (non-declaration, comment-stripped)
// line or routes its raw id; it is CONSUMED if consumer scripts reference it or the
// likes/dislikes data (CSV rows, WriteLD/WritePLD seeds, clear-superset array) carries its
// id. FAIL: consumed-but-never-emitted (a data row promising piety that can never fire)
// and declared-but-never-anything (dead constant) -- unless reserved in
// tools/pdv_reserved_events.json. Emitted-but-unconsumed is reported as info only.
function evaluateEventEmissionCoverage() {
  const declText = fs.readFileSync(EVENT_TYPES_PATH, "utf8");
  const declared = [];
  for (const m of declText.matchAll(/^\s*Int\s+Property\s+(EVT_[A-Z0-9_]+)\s*=\s*(-?\d+)\s+AutoReadOnly/gim)) {
    declared.push({ name: m[1], id: Number(m[2]), key: `PDV_EventTypes.${m[1]}` });
  }

  const allFiles = fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));
  const emitterFiles = allFiles.filter((f) =>
    /^(PDV_PlayerEvents|PDV_ActionRouter|PDV_EventBus|PDV_FragmentBridge|PDV_EventSignalActivator|PDV_EventSignalEffect|PDV__SM_[A-Za-z]+)\.psc$/i.test(f));
  const consumerFiles = allFiles.filter((f) =>
    /^(PDV__ManagerQuest|PDV_DeityBase|PDV_Deity_[A-Za-z]+|PDV_DaedricPathBase|PDV_DaedricPath_[A-Za-z]+|PDV_Substrate_[A-Za-z]+)\.psc$/i.test(f));

  const liveText = (file) => {
    const stripped = stripPapyrusComments(fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8"));
    // Drop declaration lines everywhere (emitter scripts re-declare local EVT_ consts).
    return stripped.replace(/^\s*Int\s+Property\s+EVT_[A-Z0-9_]+\s*=.*$/gim, "");
  };
  const emitterText = emitterFiles.map(liveText).join("\n");
  const consumerText = consumerFiles.map(liveText).join("\n");

  // Raw-int routing (RouteAction(350, ...)) counts as emission by id.
  const rawEmittedIds = new Set();
  for (const m of emitterText.matchAll(/\bRouteAction(?:WithAttribution)?\s*\(\s*(\d+)\b/g)) {
    rawEmittedIds.add(Number(m[1]));
  }

  // Data consumption: CSV eventId columns + manager WriteLD/WritePLD seeds + clear-superset array.
  const dataConsumedIds = new Set();
  for (const csvPath of [LIKES_CSV_PATH, PRINCE_LIKES_CSV_PATH]) {
    if (!fs.existsSync(csvPath)) continue;
    const lines = fs.readFileSync(csvPath, "utf8").split(/\r?\n/).slice(1);
    for (const line of lines) {
      const id = Number((line.split(",")[1] || "").trim());
      if (Number.isFinite(id) && id > 0) dataConsumedIds.add(id);
    }
  }
  const managerLive = stripPapyrusComments(fs.readFileSync(MANAGER_PATH, "utf8"));
  for (const m of managerLive.matchAll(/\bWriteP?LD\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*,\s*(\d+)\b/g)) {
    dataConsumedIds.add(Number(m[1]));
  }
  for (const m of managerLive.matchAll(/\bp?ldEvents\s*\[\s*\d+\s*\]\s*=\s*(\d+)\b/g)) {
    dataConsumedIds.add(Number(m[1]));
  }

  const results = [];
  for (const d of declared) {
    const tokenRe = new RegExp(`\\b${d.name}\\b`);
    const emitted = tokenRe.test(emitterText) || rawEmittedIds.has(d.id);
    const consumed = tokenRe.test(consumerText) || dataConsumedIds.has(d.id);
    let verdict = "OK";
    if (!emitted && consumed) verdict = "DEAD_PROMISE";
    else if (!emitted && !consumed) verdict = "DEAD_CONSTANT";
    else if (emitted && !consumed) verdict = "EMITTED_UNCONSUMED";
    results.push({ ...d, emitted, consumed, verdict });
  }

  // Data-seeded ids not covered by the EventTypes registry: they may be declared LOCALLY
  // in another script (PlayerEvents EVT_SLEEP_IN_INN=315, ActionRouter 303-style) -- an id
  // counts as emitted if ANY of its declaring tokens appears live in an emitter, or it is
  // routed raw. Otherwise its rows are dead promises (the Namira cannibalize-367 / Clavicus
  // persuade-354 / Kyne kill-event3/4 class -- ids documented only in comments or nowhere).
  const declaredIds = new Set(declared.map((d) => d.id));
  const unionDeclared = new Map(); // id -> Set of declaring token names, across ALL scripts
  for (const file of allFiles) {
    const text = fs.readFileSync(`${SOURCE_DIR}/${file}`, "utf8");
    for (const m of text.matchAll(/^\s*Int\s+Property\s+(EVT_[A-Z0-9_]+)\s*=\s*(-?\d+)\s+AutoReadOnly/gim)) {
      const id = Number(m[2]);
      if (!unionDeclared.has(id)) unionDeclared.set(id, new Set());
      unionDeclared.get(id).add(m[1]);
    }
  }
  const idEmitted = (id) => {
    if (rawEmittedIds.has(id)) return true;
    for (const name of unionDeclared.get(id) || []) {
      if (new RegExp(`\\b${name}\\b`).test(emitterText)) return true;
    }
    return false;
  };
  const undeclaredDead = [...dataConsumedIds]
    .filter((id) => !declaredIds.has(id) && !idEmitted(id))
    .sort((a, b) => a - b)
    .map((id) => {
      const names = [...(unionDeclared.get(id) || [])];
      return { name: names[0] || `(undeclared id ${id})`, id, key: `PDV_EventTypes.ID_${id}`, emitted: false, consumed: true, verdict: names.length ? "DEAD_PROMISE_LOCAL_DECL" : "DEAD_PROMISE_UNDECLARED" };
    });

  const bad = [...results.filter((r) => r.verdict === "DEAD_PROMISE" || r.verdict === "DEAD_CONSTANT"), ...undeclaredDead];
  if (process.env.PDV_EVENT_EMISSION_SELFTEST === "1") {
    bad.push({ name: "EVT_SELFTEST_DEAD", id: -999, key: "PDV_EventTypes.EVT_SELFTEST_DEAD", emitted: false, consumed: true, verdict: "DEAD_PROMISE" });
  }

  const reserved = loadReservedLedger(RESERVED_EVENTS_PATH);
  const ledgerError = reserved.__error ? [reserved.__error] : [];
  const knownGaps = [];
  const failures = [];
  for (const b of bad) {
    if (reserved[b.key]) knownGaps.push({ ...b, reason: (reserved[b.key] && reserved[b.key].reason) || "(no reason given)" });
    else failures.push(b);
  }
  const badKeys = new Set(bad.map((b) => b.key));
  const staleLedger = Object.keys(reserved).filter((k) => !k.startsWith("__")).filter((k) => !badKeys.has(k));

  const infoUnconsumed = results.filter((r) => r.verdict === "EMITTED_UNCONSUMED").map((r) => r.key);
  const ok = failures.length === 0 && staleLedger.length === 0 && ledgerError.length === 0;
  return {
    declared: declared.length,
    emitted: results.filter((r) => r.emitted).length,
    deadPromises: results.filter((r) => r.verdict === "DEAD_PROMISE").length,
    deadConstants: results.filter((r) => r.verdict === "DEAD_CONSTANT").length,
    knownGaps,
    failures,
    staleLedger,
    ledgerError,
    infoUnconsumed,
    ok,
  };
}

// Gate B -- Route/Handle reachability: an EventBus Route* or manager Handle* function with
// ZERO call sites is dead plumbing (the RouteBosmerBaanDarGap / RouteOrcStrongholdPresence
// class). Any live (comment-stripped) call site counts -- reachability, not trigger
// quality, is the claim. Reserved orphans live in tools/pdv_reserved_routes.json.
function evaluateRouteReachability() {
  const allFiles = fs.readdirSync(SOURCE_DIR).filter((f) => /\.psc$/i.test(f));
  const liveByFile = new Map(allFiles.map((f) => [f, stripPapyrusComments(fs.readFileSync(`${SOURCE_DIR}/${f}`, "utf8"))]));

  const targets = [];
  for (const m of (liveByFile.get("PDV_EventBus.psc") || "").matchAll(/^\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+(Route[A-Za-z0-9_]+)\s*\(/gim)) {
    targets.push({ name: m[1], kind: "route", key: `PDV_EventBus.${m[1]}` });
  }
  for (const m of (liveByFile.get("PDV__ManagerQuest.psc") || "").matchAll(/^\s*(?:[A-Za-z_][\w\[\]]*\s+)?Function\s+(Handle[A-Za-z0-9_]+)\s*\(/gim)) {
    targets.push({ name: m[1], kind: "handle", key: `PDV__ManagerQuest.${m[1]}` });
  }

  const orphans = [];
  let reachable = 0;
  for (const t of targets) {
    let callers = 0;
    const callRe = new RegExp(`\\b${t.name}\\s*\\(`, "g");
    const defRe = new RegExp(`Function\\s+${t.name}\\s*\\(`, "gi");
    for (const text of liveByFile.values()) {
      const calls = (text.match(callRe) || []).length;
      const defs = (text.match(defRe) || []).length;
      callers += Math.max(0, calls - defs);
    }
    if (callers === 0) orphans.push(t);
    else reachable += 1;
  }

  if (process.env.PDV_ROUTE_REACH_SELFTEST === "1") {
    orphans.push({ name: "RouteSelftestOrphan", kind: "route", key: "PDV_EventBus.RouteSelftestOrphan" });
  }

  const reserved = loadReservedLedger(RESERVED_ROUTES_PATH);
  const ledgerError = reserved.__error ? [reserved.__error] : [];
  const knownGaps = [];
  const failures = [];
  for (const o of orphans) {
    if (reserved[o.key]) knownGaps.push({ ...o, reason: (reserved[o.key] && reserved[o.key].reason) || "(no reason given)" });
    else failures.push(o);
  }
  const orphanKeys = new Set(orphans.map((o) => o.key));
  const staleLedger = Object.keys(reserved).filter((k) => !k.startsWith("__")).filter((k) => !orphanKeys.has(k));

  const ok = failures.length === 0 && staleLedger.length === 0 && ledgerError.length === 0;
  return { targets: targets.length, reachable, orphans: orphans.length, knownGaps, failures, staleLedger, ledgerError, ok };
}

// Gate C -- Kill classification inheritance: actor-type keywords can live on a victim's
// race rather than its actor base. Without this fallback, a real draugr Story Manager
// kill reaches the router but silently misses EVT_KILL_UNDEAD and every downstream deity
// reaction. Keep undead first so a race-derived undead type cannot fall through to NPC.
function evaluateKillClassification() {
  const routerText = fs.readFileSync(ACTION_ROUTER_PATH, "utf8");
  const routerFunctions = buildFunctionMap(routerText);
  const actorHasKeyword = routerFunctions.get("ActorHasKeyword") || "";
  const classifyKillVictim = routerFunctions.get("ClassifyKillVictim") || "";
  const playerEventsText = fs.readFileSync(PLAYER_EVENTS_PATH, "utf8");
  const playerEventFunctions = buildFunctionMap(playerEventsText);
  const inheritedKeyword = playerEventFunctions.get("ActorHasInheritedKeyword") || "";
  const paarthurnaxCheck = playerEventFunctions.get("IsPaarthurnaxActor") || "";
  const khajiitKill = playerEventFunctions.get("HandleKhajiitOrganicKill") || "";
  const failures = [];

  if (!/actorRef\.GetRace\s*\(\s*\)/.test(actorHasKeyword) || !/actorRace\.HasKeyword\s*\(\s*keywordRef\s*\)/.test(actorHasKeyword)) {
    failures.push("ActorHasKeyword lacks the Actor.GetRace() keyword fallback.");
  }

  const undeadIndex = classifyKillVictim.indexOf("ActorHasKeyword(victimActor, ActorTypeUndead)");
  const undeadReturnIndex = classifyKillVictim.indexOf("return EVT_KILL_UNDEAD");
  const npcIndex = classifyKillVictim.indexOf("ActorHasKeyword(victimActor, ActorTypeNPC)");
  if (undeadIndex < 0 || undeadReturnIndex < undeadIndex || npcIndex < 0 || undeadIndex > npcIndex) {
    failures.push("ClassifyKillVictim must return EVT_KILL_UNDEAD before the generic NPC branch.");
  }

  if (!/actorRef\.GetRace\s*\(\s*\)/.test(inheritedKeyword) || !/actorRace\.HasKeyword\s*\(\s*keywordRef\s*\)/.test(inheritedKeyword)) {
    failures.push("PDV_PlayerEvents special kill paths lack the actor/base/race keyword helper.");
  }
  if (!/ActorHasInheritedKeyword\s*\(\s*victimActor\s*,\s*ActorTypeDragon\s*\)/.test(paarthurnaxCheck)) {
    failures.push("Paarthurnax recognition bypasses inherited ActorTypeDragon classification.");
  }
  if (!/ActorHasInheritedKeyword\s*\(\s*victimActor\s*,\s*ActorTypeDragon\s*\)/.test(khajiitKill)) {
    failures.push("Khajiit organic dragon recognition bypasses inherited ActorTypeDragon classification.");
  }

  if (process.env.PDV_KILL_CLASSIFICATION_SELFTEST === "1") {
    failures.push("Synthetic kill-classification failure.");
  }

  return { failures, ok: failures.length === 0 };
}

// Gate D -- CSV -> codegen freshness: a likes/dislikes CSV edit is inert until
// pdv_likesdislikes_gen regenerates the manager seed block and the version bumps
// (the likes-dislikes-csv-codegen class). Content-level check at event-id granularity:
// D1 every CSV event id has a manager WriteLD/WritePLD seed; D2 every seeded id is still
// in a CSV (removed row not regenerated); D3 the ClearRowsForDeity superset array
// (GetLikesDislikesEventTypes) covers every seeded id -- the MAINTENANCE invariant the
// manager itself documents. Per-deity delta drift is out of scope (id-set granularity).
function evaluateCsvCodegenFreshness() {
  const readCsvIds = (csvPath) => {
    const ids = new Set();
    if (!fs.existsSync(csvPath)) return ids;
    const lines = fs.readFileSync(csvPath, "utf8").split(/\r?\n/).slice(1);
    for (const line of lines) {
      const id = Number((line.split(",")[1] || "").trim());
      if (Number.isFinite(id) && id > 0) ids.add(id);
    }
    return ids;
  };
  const deityCsvIds = readCsvIds(LIKES_CSV_PATH);
  const princeCsvIds = readCsvIds(PRINCE_LIKES_CSV_PATH);

  const managerLive = stripPapyrusComments(fs.readFileSync(MANAGER_PATH, "utf8"));
  const collectIds = (re) => {
    const ids = new Set();
    for (const m of managerLive.matchAll(re)) ids.add(Number(m[1]));
    return ids;
  };
  // Deity seeds/superset and Prince seeds/superset are SEPARATE systems (WriteLD /
  // GetLikesDislikesEventTypes vs WritePLD / GetPrinceEventTypes) -- compare per side.
  const deitySeeded = collectIds(/\bWriteLD\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*,\s*(\d+)\b/g);
  const princeSeeded = collectIds(/\bWritePLD\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*,\s*(\d+)\b/g);
  const fns = buildFunctionMap(managerLive);
  const supersetOf = (fnName) => {
    const ids = new Set();
    for (const m of (fns.get(fnName) || "").matchAll(/\[\s*\d+\s*\]\s*=\s*(\d+)\b/g)) ids.add(Number(m[1]));
    return ids;
  };
  const deitySuperset = supersetOf("GetLikesDislikesEventTypes");
  const princeSuperset = supersetOf("GetPrinceEventTypes");

  const diff = (a, b) => [...a].filter((id) => !b.has(id)).sort((x, y) => x - y);
  const csvNotSeeded = [...diff(deityCsvIds, deitySeeded).map((id) => `deity:${id}`), ...diff(princeCsvIds, princeSeeded).map((id) => `prince:${id}`)];
  const seededNotCsv = [...diff(deitySeeded, deityCsvIds).map((id) => `deity:${id}`), ...diff(princeSeeded, princeCsvIds).map((id) => `prince:${id}`)];
  const seededNotInSuperset = [...diff(deitySeeded, deitySuperset).map((id) => `deity:${id}`), ...diff(princeSeeded, princeSuperset).map((id) => `prince:${id}`)];
  const versionMatch = managerLive.match(/LIKES_DISLIKES_VERSION\s*=\s*(\d+)/);

  if (process.env.PDV_CSV_FRESHNESS_SELFTEST === "1") {
    csvNotSeeded.push("deity:-999");
  }

  const ok = csvNotSeeded.length === 0 && seededNotCsv.length === 0 && seededNotInSuperset.length === 0;
  return {
    csvIds: deityCsvIds.size + princeCsvIds.size,
    seededIds: deitySeeded.size + princeSeeded.size,
    supersetIds: deitySuperset.size + princeSuperset.size,
    version: versionMatch ? Number(versionMatch[1]) : null,
    csvNotSeeded,
    seededNotCsv,
    seededNotInSuperset,
    ok,
  };
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

function writeLedgers(rows, helpers, curatedParity, dispatchCoverage, eventCoverage, routeReach, csvFreshness, killClassification) {
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
  if (curatedParity) {
    md.push("## Curated-Signal Parity");
    md.push("");
    md.push("Every AwardCuratedSignal[Scaled](deity, deity.SIGNAL_X) must resolve to a deity script that DEFINES and HANDLES SIGNAL_X in ScoreCuratedSignal, else the curated piety silently scores 0.0 (the Kyne class). Pure static source check -- no server.");
    md.push(`Status: ${curatedParity.ok ? "PASS" : "FAIL"} | references=${curatedParity.total} | ok=${curatedParity.okCount} | gaps=${curatedParity.gaps.length} | cross-deity=${curatedParity.cross.length} | by-index=${curatedParity.byIndex.length}`);
    md.push("");
    if (curatedParity.gaps.length) {
      md.push("### Gaps (silent-zero / missing script)");
      for (const g of curatedParity.gaps) {
        md.push(`- ${asciiSafe(g.awarded)}.${asciiSafe(g.signal)} (${asciiSafe(g.file)}): ${asciiSafe(g.reason)}`);
      }
      md.push("");
    }
    if (curatedParity.cross.length) {
      md.push("### Cross-deity (award deity != signal owner -- manual review)");
      for (const c of curatedParity.cross) {
        md.push(`- award ${asciiSafe(c.awarded)} using ${asciiSafe(c.owner)}.${asciiSafe(c.signal)} (${asciiSafe(c.file)})`);
      }
      md.push("");
    }
    if (curatedParity.byIndex.length) {
      md.push("### By-index call sites (manual review)");
      for (const b of curatedParity.byIndex) {
        md.push(`- ${asciiSafe(b.file)}: ${asciiSafe(b.context)}`);
      }
      md.push("");
    }
  }
  if (dispatchCoverage) {
    md.push("## Curated-Signal Dispatch Coverage");
    md.push("");
    md.push("Registry-driven INVERSE of parity: every DECLARED + SCORED SIGNAL_ in a PDV_Deity_*.psc must have a real AwardCuratedSignal[Scaled] dispatch (non-Debug, non-display). An undispatched signal can never bank piety (the dead-signal class). Reserved known-gaps live in tools/pdv_reserved_signals.json; anything undispatched and NOT reserved FAILs, and a stale reservation FAILs too. Pure static source check -- no server.");
    md.push(`Status: ${dispatchCoverage.ok ? "PASS" : "FAIL"} | declared-scored=${dispatchCoverage.declaredScored} | dispatched=${dispatchCoverage.dispatched} | undispatched=${dispatchCoverage.undispatched} | reserved-known-gaps=${dispatchCoverage.knownGaps.length} | unlisted-FAIL=${dispatchCoverage.failures.length} | stale-ledger=${dispatchCoverage.staleLedger.length}`);
    md.push("");
    if (dispatchCoverage.ledgerError.length) {
      md.push("### Reserved-ledger parse error");
      for (const e of dispatchCoverage.ledgerError) md.push(`- ${asciiSafe(e)}`);
      md.push("");
    }
    if (dispatchCoverage.failures.length) {
      md.push("### Undispatched and NOT reserved (FAIL -- wire a trigger or add a justified ledger entry)");
      for (const f of dispatchCoverage.failures) {
        md.push(`- ${asciiSafe(f.key)} (declared+scored in ${asciiSafe(f.file)}, NO real AwardCuratedSignal[Scaled] dispatch)`);
      }
      md.push("");
    }
    if (dispatchCoverage.staleLedger.length) {
      md.push("### Stale reservations (FAIL -- now wired or no longer declared; remove from ledger)");
      for (const s of dispatchCoverage.staleLedger) md.push(`- ${asciiSafe(s)}`);
      md.push("");
    }
    if (dispatchCoverage.knownGaps.length) {
      md.push("### Reserved known-gaps (documented deferral -- burn down toward empty)");
      for (const k of dispatchCoverage.knownGaps.slice().sort((a, b) => a.key.localeCompare(b.key))) {
        md.push(`- ${asciiSafe(k.key)}: ${asciiSafe(k.reason)}`);
      }
      md.push("");
    }
  }
  if (eventCoverage) {
    md.push("## EVT Emission Coverage");
    md.push("");
    md.push("Every declared EVT_ in PDV_EventTypes.psc must be EMITTED by a real emitter script (or reserved in tools/pdv_reserved_events.json). DEAD_PROMISE = data rows/consumers exist but the event never fires; DEAD_CONSTANT = declared and referenced nowhere. Emitted-but-unconsumed is informational.");
    md.push(`Status: ${eventCoverage.ok ? "PASS" : "FAIL"} | declared=${eventCoverage.declared} | emitted=${eventCoverage.emitted} | dead-promises=${eventCoverage.deadPromises} | dead-constants=${eventCoverage.deadConstants} | reserved=${eventCoverage.knownGaps.length} | unlisted-FAIL=${eventCoverage.failures.length} | stale-ledger=${eventCoverage.staleLedger.length}`);
    md.push("");
    if (eventCoverage.failures.length) {
      md.push("### Dead events NOT reserved (FAIL)");
      for (const f of eventCoverage.failures) md.push(`- ${asciiSafe(f.key)} (id ${f.id}, ${asciiSafe(f.verdict)})`);
      md.push("");
    }
    if (eventCoverage.staleLedger.length) {
      md.push("### Stale event reservations (FAIL -- remove from ledger)");
      for (const s of eventCoverage.staleLedger) md.push(`- ${asciiSafe(s)}`);
      md.push("");
    }
    if (eventCoverage.knownGaps.length) {
      md.push("### Reserved dead events (documented deferral)");
      for (const k of eventCoverage.knownGaps.slice().sort((a, b) => a.key.localeCompare(b.key))) {
        md.push(`- ${asciiSafe(k.key)} (id ${k.id}, ${asciiSafe(k.verdict)}): ${asciiSafe(k.reason)}`);
      }
      md.push("");
    }
    if (eventCoverage.infoUnconsumed.length) {
      md.push("### Emitted but unconsumed (info)");
      for (const i of eventCoverage.infoUnconsumed) md.push(`- ${asciiSafe(i)}`);
      md.push("");
    }
  }
  if (routeReach) {
    md.push("## Route/Handle Reachability");
    md.push("");
    md.push("Every PDV_EventBus Route* and PDV__ManagerQuest Handle* function needs at least one live call site, else it is dead plumbing. Reserved orphans live in tools/pdv_reserved_routes.json.");
    md.push(`Status: ${routeReach.ok ? "PASS" : "FAIL"} | targets=${routeReach.targets} | reachable=${routeReach.reachable} | orphans=${routeReach.orphans} | reserved=${routeReach.knownGaps.length} | unlisted-FAIL=${routeReach.failures.length} | stale-ledger=${routeReach.staleLedger.length}`);
    md.push("");
    if (routeReach.failures.length) {
      md.push("### Orphans NOT reserved (FAIL)");
      for (const f of routeReach.failures) md.push(`- ${asciiSafe(f.key)} (${asciiSafe(f.kind)})`);
      md.push("");
    }
    if (routeReach.staleLedger.length) {
      md.push("### Stale route reservations (FAIL -- remove from ledger)");
      for (const s of routeReach.staleLedger) md.push(`- ${asciiSafe(s)}`);
      md.push("");
    }
    if (routeReach.knownGaps.length) {
      md.push("### Reserved orphans (documented deferral)");
      for (const k of routeReach.knownGaps.slice().sort((a, b) => a.key.localeCompare(b.key))) {
        md.push(`- ${asciiSafe(k.key)}: ${asciiSafe(k.reason)}`);
      }
      md.push("");
    }
  }
  if (csvFreshness) {
    md.push("## Likes/Dislikes CSV -> Codegen Freshness");
    md.push("");
    md.push("Event-id-set cross-check between the likes/dislikes CSVs and the manager's generated WriteLD/WritePLD seeds + ClearRowsForDeity superset array. A mismatch means a CSV edit shipped without rerunning pdv_likesdislikes_gen (inert edit) or a removed row was not regenerated. Per-deity delta drift is out of scope.");
    md.push(`Status: ${csvFreshness.ok ? "PASS" : "FAIL"} | csv-ids=${csvFreshness.csvIds} | seeded-ids=${csvFreshness.seededIds} | superset-ids=${csvFreshness.supersetIds} | LIKES_DISLIKES_VERSION=${csvFreshness.version}`);
    md.push("");
    if (csvFreshness.csvNotSeeded.length) md.push(`### CSV ids with no manager seed (FAIL): ${csvFreshness.csvNotSeeded.join(", ")}`);
    if (csvFreshness.seededNotCsv.length) md.push(`### Seeded ids no longer in any CSV (FAIL): ${csvFreshness.seededNotCsv.join(", ")}`);
    if (csvFreshness.seededNotInSuperset.length) md.push(`### Seeded ids missing from ClearRowsForDeity superset (FAIL): ${csvFreshness.seededNotInSuperset.join(", ")}`);
    if (!csvFreshness.ok) md.push("");
  }
  if (killClassification) {
    md.push("## Kill Classification Inheritance");
    md.push("");
    md.push("Actor-type classification checks actor reference, actor base, and actor race. This prevents race-derived undead (including draugr) from missing EVT_KILL_UNDEAD and falling through to the generic NPC branch.");
    md.push(`Status: ${killClassification.ok ? "PASS" : "FAIL"}`);
    if (killClassification.failures.length) {
      md.push("");
      for (const failure of killClassification.failures) md.push(`- ${asciiSafe(failure)}`);
    }
    md.push("");
  }
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

// --declaration-gates-only (alias: --dispatch-coverage-only): run ONLY the pure-static
// declaration-side gates (no MCP/dotnet), print JSON, exit non-zero on any FAIL. This is
// what pdv_verify shells on every run, so the whole family is default-FAIL everywhere.
if (process.argv.includes("--declaration-gates-only") || process.argv.includes("--dispatch-coverage-only")) {
  const dispatch = evaluateCuratedSignalDispatchCoverage();
  const events = evaluateEventEmissionCoverage();
  const routes = evaluateRouteReachability();
  const csv = evaluateCsvCodegenFreshness();
  const killClassification = evaluateKillClassification();
  const ok = dispatch.ok && events.ok && routes.ok && csv.ok && killClassification.ok;
  console.log(JSON.stringify({
    check: "declarationGates",
    status: ok ? "PASS" : "FAIL",
    dispatch: {
      status: dispatch.ok ? "PASS" : "FAIL",
      declaredScored: dispatch.declaredScored,
      dispatched: dispatch.dispatched,
      undispatched: dispatch.undispatched,
      reservedKnownGaps: dispatch.knownGaps.length,
      failures: dispatch.failures.map((f) => f.key),
      staleLedger: dispatch.staleLedger,
      ledgerError: dispatch.ledgerError,
    },
    events: {
      status: events.ok ? "PASS" : "FAIL",
      declared: events.declared,
      emitted: events.emitted,
      reservedKnownGaps: events.knownGaps.length,
      failures: events.failures.map((f) => `${f.key} (id ${f.id}, ${f.verdict})`),
      staleLedger: events.staleLedger,
      ledgerError: events.ledgerError,
      infoUnconsumed: events.infoUnconsumed,
    },
    routes: {
      status: routes.ok ? "PASS" : "FAIL",
      targets: routes.targets,
      reachable: routes.reachable,
      reservedKnownGaps: routes.knownGaps.length,
      failures: routes.failures.map((f) => f.key),
      staleLedger: routes.staleLedger,
      ledgerError: routes.ledgerError,
    },
    killClassification: {
      status: killClassification.ok ? "PASS" : "FAIL",
      failures: killClassification.failures,
    },
    csvFreshness: {
      status: csv.ok ? "PASS" : "FAIL",
      csvIds: csv.csvIds,
      seededIds: csv.seededIds,
      version: csv.version,
      csvNotSeeded: csv.csvNotSeeded,
      seededNotCsv: csv.seededNotCsv,
      seededNotInSuperset: csv.seededNotInSuperset,
    },
  }, null, 2));
  process.exitCode = ok ? 0 : 1;
} else {
  main();
}
