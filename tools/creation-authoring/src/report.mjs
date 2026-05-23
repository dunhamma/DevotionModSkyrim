export function formatPlan(plan) {
  const lines = [];
  lines.push(`Project: ${plan.manifest.project}`);
  lines.push(`Game: ${plan.manifest.game}`);
  lines.push(`Source plugin: ${plan.manifest.sourcePlugin}`);
  lines.push(`Output: ${plan.manifest.output || "(profile/default)"}`);
  lines.push(`Summary: ${plan.summary.ready} ready, ${plan.summary.manual} manual, ${plan.summary.abort} abort`);
  lines.push("");

  for (const item of plan.operations) {
    lines.push(`- [${item.status}] ${item.operation.id} ${item.operation.kind} -> ${item.operation.target}`);
    lines.push(`  backend: ${item.backend}`);
    if (item.manualPacket) {
      lines.push(`  reason: ${item.manualPacket.reason}`);
    }
  }

  return `${lines.join("\n")}\n`;
}

export function formatManualPackets(packets) {
  const lines = [];
  for (const packet of packets) {
    lines.push(`${packet.operationId}: ${packet.kind} -> ${packet.target}`);
    lines.push(`Reason: ${packet.reason}`);
    for (const [index, step] of packet.steps.entries()) {
      lines.push(`${index + 1}. ${step}`);
    }
    lines.push(`Verifier: ${packet.verifier}`);
    lines.push("");
  }
  return `${lines.join("\n").trimEnd()}\n`;
}

export function formatVerify(report) {
  const lines = [];
  lines.push(`Project: ${report.manifest.project}`);
  lines.push(`Summary: PASS=${report.summary.PASS} FAIL=${report.summary.FAIL} WARN=${report.summary.WARN} TODO=${report.summary.TODO}`);
  lines.push("");
  for (const item of report.results) {
    lines.push(`- [${item.status}] ${item.operationId} ${item.kind} -> ${item.target}`);
    lines.push(`  ${item.message}`);
  }
  return `${lines.join("\n")}\n`;
}
