import fs from "node:fs";
import path from "node:path";
import { writeJson } from "./io.mjs";

export function writeReviewReports(runReport, options = {}) {
  const reportsDir = path.resolve(options.reportsDir || "reports");
  fs.mkdirSync(reportsDir, { recursive: true });
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const basename = `${runReport.manifest.project}-${timestamp}.review`;
  const jsonPath = writeJson(path.join(reportsDir, `${basename}.json`), buildReviewJson(runReport));
  const markdownPath = path.join(reportsDir, `${basename}.md`);
  fs.writeFileSync(markdownPath, formatReviewMarkdown(runReport, jsonPath), "utf8");
  return {
    schema: "creation-authoring.review-artifacts.v1",
    jsonPath,
    markdownPath
  };
}

export function buildReviewJson(runReport) {
  return {
    schema: "creation-authoring.review-report.v1",
    status: runReport.status,
    manifest: runReport.manifest,
    profile: runReport.profile,
    planSummary: runReport.planSummary,
    operations: runReport.planOperations,
    phases: runReport.phases.map((phase) => ({
      phase: phase.phase,
      status: phase.status,
      message: phase.message || null,
      summary: phase.summary || null,
      result: phase.result || phase.writerResult || phase.adapterResult || null,
      report: phase.report || null,
      packet: phase.packet || null,
      patchRequest: phase.patchRequest || null
    })),
    manualPackets: runReport.manualPackets || []
  };
}

export function formatReviewMarkdown(runReport, jsonPath = null) {
  const lines = [];
  lines.push(`# ${runReport.manifest.project} Authoring Review`);
  lines.push("");
  lines.push(`Status: ${runReport.status}`);
  lines.push(`Source plugin: ${runReport.manifest.sourcePlugin}`);
  lines.push(`Generated plugin: ${runReport.manifest.output}`);
  if (jsonPath) {
    lines.push(`Machine report: ${jsonPath}`);
  }
  lines.push("");
  lines.push("## Gates");
  for (const phase of runReport.phases) {
    lines.push(`- ${phase.status}: ${phase.phase}${phase.message ? ` - ${phase.message}` : ""}`);
  }
  lines.push("");
  lines.push("## Operations");
  for (const operation of runReport.planOperations || []) {
    lines.push(`- ${operation.status}: ${operation.id} ${operation.kind} -> ${operation.target}`);
    lines.push(`  - backend: ${operation.backend}`);
    lines.push(`  - tier: ${operation.capabilityTier}`);
    if (operation.reviewIntent) {
      lines.push(`  - intent: ${operation.reviewIntent}`);
    }
  }
  if (runReport.manualPackets?.length) {
    lines.push("");
    lines.push("## Manual Or Blocked Packets");
    for (const packet of runReport.manualPackets) {
      lines.push(`- ${packet.operationId}: ${packet.reason}`);
    }
  }
  return `${lines.join("\n")}\n`;
}
