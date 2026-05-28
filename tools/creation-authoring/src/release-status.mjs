export const MATRIX_STATUSES = [
  "supported",
  "ck_required_unproven",
  "safe_writer_unproven",
  "read_only",
  "research_only",
  "manual_blocked",
  "out_of_scope_3d_modeling",
  "not_applicable"
];

export const PLATFORM_V1_SUPPORTED_STATUSES = new Set(["supported"]);
export const PLATFORM_V1_DISCOVERY_STATUSES = new Set([
  "ck_required_unproven",
  "safe_writer_unproven"
]);
export const PLATFORM_V1_BLOCKED_STATUSES = new Set([
  "manual_blocked",
  "read_only",
  "research_only",
  "out_of_scope_3d_modeling",
  "not_applicable"
]);

export const PASS_PHASE_STATUSES = new Set(["PASS", "SKIPPED"]);
export const FAIL_PHASE_STATUSES = new Set(["FAIL", "UNSAFE_BLOCKED"]);
export const WAITING_PHASE_STATUSES = new Set(["REQUESTED"]);
export const INCOMPLETE_PHASE_STATUSES = new Set(["TODO", "MANUAL"]);
export const STRICT_BLOCKING_PHASE_STATUSES = new Set([
  ...FAIL_PHASE_STATUSES,
  ...WAITING_PHASE_STATUSES,
  ...INCOMPLETE_PHASE_STATUSES
]);

export function classifyPlatformV1MatrixStatus(status) {
  if (PLATFORM_V1_SUPPORTED_STATUSES.has(status)) {
    return "supported";
  }
  if (PLATFORM_V1_DISCOVERY_STATUSES.has(status)) {
    return "discoveryOnly";
  }
  return "blocked";
}

export function summarizePhaseStatuses(phases = []) {
  if (phases.some((phase) => FAIL_PHASE_STATUSES.has(phase.status))) {
    return "FAIL";
  }
  if (phases.some((phase) => WAITING_PHASE_STATUSES.has(phase.status))) {
    return "REQUESTED";
  }
  if (phases.some((phase) => INCOMPLETE_PHASE_STATUSES.has(phase.status))) {
    return "TODO";
  }
  return "PASS";
}

export function collectStrictBlockers(phases = [], manualPackets = []) {
  const blockers = phases.filter((phase) => STRICT_BLOCKING_PHASE_STATUSES.has(phase.status));
  for (const packet of manualPackets) {
    blockers.push({
      phase: "manual-packet",
      status: "MANUAL",
      message: `${packet.kind} on ${packet.target} emitted a manual development packet. Manual packets are not a shippable automation path.`
    });
  }
  return blockers;
}

export function buildStrictGatePhase(phases = [], manualPackets = []) {
  const blockers = collectStrictBlockers(phases, manualPackets);
  return {
    phase: "strict-gate",
    status: blockers.length ? "FAIL" : "PASS",
    message: blockers.length
      ? "Strict mode requires every executable, readback, and verifier phase to pass before review or promotion."
      : "Strict mode passed.",
    blockers: blockers.map((phase) => ({
      phase: phase.phase,
      status: phase.status,
      message: phase.message || null
    }))
  };
}

export function normalizeRunnerStatus(result) {
  if (!result) {
    return "FAIL";
  }
  if (result.status === "DEFERRED_TO_MERGE_RUNNER") {
    return "PASS";
  }
  if (["PASS", "SKIPPED", "REQUESTED", "UNSAFE_BLOCKED"].includes(result.status)) {
    return result.status;
  }
  return "FAIL";
}
