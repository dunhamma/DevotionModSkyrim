#!/usr/bin/env node
/*
 * Read-only static characterization for quest-reaction eligibility.
 *
 * It proves source policy only. Papyrus compilation and fresh-save runtime
 * proof remain separate gates.
 */

import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { familySourceText } from "./lib/pdv_symbol_home.mjs";

const KNOWN_FLAGS = new Set(["--json", "--self-test"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_quest_reaction_eligibility_audit" });

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_ROOT = path.join(ROOT, "live-source", "Scripts", "Source");
const JSON_OUTPUT = process.argv.includes("--json");
const SELF_TEST = process.argv.includes("--self-test");

function functionBody(source, functionName) {
  const start = source.search(new RegExp(`(?:[A-Za-z]+\\s+)?Function\\s+${functionName}\\s*\\(`, "i"));
  if (start < 0) return "";
  const tail = source.slice(start);
  const end = tail.search(/\n\s*EndFunction\b/i);
  return end < 0 ? tail : tail.slice(0, end + 12);
}

function add(findings, ok, id, detail) {
  findings.push({ status: ok ? "PASS" : "FAIL", id, detail });
}

function returnLine(body, stateName) {
  const match = body.match(new RegExp(`${stateName}[\\s\\S]*?return\\s+([^\\r\\n]+)`, "i"));
  return match ? match[1] : "";
}

export function evaluate(managerSource) {
  const findings = [];
  const reachable = functionBody(managerSource, "IsQuestReactionDeityReachable");
  const cheapSkip = functionBody(managerSource, "IsQueuedQuestReactionCellCheapSkip");
  const apply = functionBody(managerSource, "ApplyDeityReaction");
  const nordEligible = functionBody(managerSource, "IsNordOfferEligibleDeity");
  const genericEligible = functionBody(managerSource, "IsGenericLikesDislikesDeityReachable");

  add(findings, /PDV_DaedricPathBase[\s\S]*?return\s+True/i.test(reachable), "policy.daedric-reachable", "Daedric paths remain reachable for quest reactions.");
  add(findings, /IsGrandfatheredOffRosterPatron\s*\(\s*deity\s*\)[\s\S]*?return\s+True/i.test(reachable), "policy.grandfathered-patron", "A restored off-roster active patron remains reachable.");
  add(findings, /originRace\s*==\s*ORIGIN_NORD[\s\S]*?return\s+(?:[A-Za-z_]\w*\.)*IsNordOfferEligibleDeity\s*\(\s*deity\s*\)/i.test(reachable), "policy.nord-selected-lane", "Nord quest reactions delegate to the selected-baseline eligibility policy.");
  add(findings, !/IsEligibleForPlayer\s*\(/i.test(reachable), "policy.state-track-rate-not-binary", "State-track eligibility remains owned by DeityBase gain/tier behavior, not this lane gate.");
  add(findings, /stance\s*==\s*"CURSE"[\s\S]*?return\s+False/i.test(cheapSkip), "ingress.curse-preserved", "Curse cells stay runnable for curse refresh handling.");
  add(findings, /stance\s*==\s*"TABOO"\s*\|\|\s*stance\s*==\s*"HOSTILE"[\s\S]*?IsDashboardDeityInOriginRoster[\s\S]*?return\s+False/i.test(cheapSkip) && !/amount\s*<\s*0\.0/i.test(cheapSkip), "ingress.taboo-hostile-both-signs", "Visible taboo/hostile cells survive ingress regardless of sign because positive values become stigma.");
  add(findings, /return\s+!IsQuestReactionDeityReachable\s*\(\s*deity\s*\)/i.test(cheapSkip), "ingress.non-displeasure-current-lane", "All other non-curse cells compact out unless eligible on the current lane.");

  const tabooStart = apply.indexOf('if stance == "TABOO" || stance == "HOSTILE"');
  const foreignStart = apply.indexOf('if stance == "FOREIGN" || stance == "TOLERATED"');
  const tabooBranch = tabooStart >= 0 && foreignStart > tabooStart ? apply.slice(tabooStart, foreignStart) : "";
  const finalGate = apply.indexOf('Debug.Trace("[PDV] QuestReaction skipped inactive lane deity: "');
  const award = apply.indexOf("ApplyQuestReactionPiety(deity, appliedReactionAmount");
  add(findings, /!IsQuestReactionDeityReachable\s*\(\s*deity\s*\)\s*&&\s*!IsDashboardDeityInOriginRoster/i.test(tabooBranch) && /ApplyQuestReactionStigma/i.test(tabooBranch) && /ApplyQuestReactionPiety/i.test(tabooBranch), "award.taboo-hostile-displeasure", "Visible taboo/hostile cells preserve both stigma and piety-loss consequences outside a selected Nord lane.");
  add(findings, finalGate >= 0 && award > finalGate, "award.normal-current-lane", "The final current-lane guard runs before ordinary piety and Book-surface accumulation.");

  const oldWays = returnLine(nordEligible, "NORD_BASELINE_OLD_WAYS");
  const nineDivines = returnLine(nordEligible, "NORD_BASELINE_NINE_DIVINES");
  const cases = [
    ["case.nine-stuhn-skipped", !nineDivines.includes("PDV_Stuhn"), "Nine Divines excludes Stuhn."],
    ["case.nine-shor-skipped", !nineDivines.includes("PDV_Shor"), "Nine Divines excludes Shor."],
    ["case.nine-tsun-skipped", !nineDivines.includes("PDV_Tsun"), "Nine Divines excludes Tsun."],
    ["case.nine-akatosh-applies", nineDivines.includes("PDV_Akatosh"), "Nine Divines includes Akatosh."],
    ["case.old-ways-stuhn-applies", oldWays.includes("PDV_Stuhn"), "Old Ways includes Stuhn."],
    ["case.old-ways-shor-applies", oldWays.includes("PDV_Shor"), "Old Ways includes Shor."],
    ["case.old-ways-akatosh-skipped", !oldWays.includes("PDV_Akatosh"), "Old Ways excludes Akatosh."],
    ["case.talos-both-lanes", /if deity == PDV_Talos[\s\S]*?return True/i.test(nordEligible), "Talos remains eligible in either Nord baseline."],
  ];
  for (const [id, ok, detail] of cases) add(findings, ok, id, detail);
  add(findings, /originRace\s*==\s*ORIGIN_NORD[\s\S]*?return\s+(?:[A-Za-z_]\w*\.)*IsNordOfferEligibleDeity\s*\(\s*deity\s*\)/i.test(genericEligible), "alignment.generic-likes-dislikes", "Generic likes/dislikes and quest reactions share Nord selected-lane policy.");

  return findings;
}

function runSelfTest(managerSource) {
  const baseline = evaluate(managerSource);
  if (baseline.some((finding) => finding.status === "FAIL")) throw new Error("Current source does not satisfy the eligibility characterization.");
  const broken = evaluate(managerSource.replace(/return\s+(?:[A-Za-z_]\w*\.)*IsNordOfferEligibleDeity\s*\(\s*deity\s*\)/, "return IsDashboardDeityInOriginRoster(deity, originRace)"));
  if (!broken.some((finding) => finding.id === "policy.nord-selected-lane" && finding.status === "FAIL")) throw new Error("Self-test did not reject the old Nord union-roster behavior.");
  return [{ status: "PASS", id: "self-test.nord-union-regression", detail: "Fixture rejects the old dashboard-union route." }];
}

const managerSource = familySourceText(ROOT, SOURCE_ROOT);
let findings = evaluate(managerSource);
if (SELF_TEST) findings = findings.concat(runSelfTest(managerSource));
const failures = findings.filter((finding) => finding.status === "FAIL");
const result = { status: failures.length === 0 ? "PASS" : "FAIL", findings };

if (JSON_OUTPUT) {
  console.log(JSON.stringify(result, null, 2));
} else {
  for (const finding of findings) console.log(`[${finding.status}] ${finding.id}: ${finding.detail}`);
  console.log(`Summary: ${result.status}`);
  console.log("Proof boundary: static source policy only; compilation, runtime piety, Book of Days, toast, and save/load are separate proof.");
}
process.exitCode = failures.length === 0 ? 0 : 1;
