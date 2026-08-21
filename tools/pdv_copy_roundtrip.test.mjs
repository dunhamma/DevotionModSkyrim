import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import { buildCensus, flattenRuntimeRecords, parseHousecarlDetail } from "./lib/pdv_copy_census.mjs";
import { buildCopyFlowModel, importProseExchange, parseCsv, renderProseExchangeCsv } from "./lib/pdv_copy_flow.mjs";

const flowManifest = JSON.parse(fs.readFileSync(new URL("../references/authoring/PDV_CopyFlowMap.json", import.meta.url), "utf8"));

function fixture() {
  const records = parseHousecarlDetail(`type=Message  formid=071513:Devotion.esp editorid=PDV_Msg_Nord_Kyne_Offer winner=Devotion.esp
  EditorID = PDV_Msg_Nord_Kyne_Offer
  Description = Will you carry my name?`, "MESG");
  const census = buildCensus({ runtimeRows: flattenRuntimeRecords(records), manifestRows: [] });
  return { census, flow: buildCopyFlowModel(census, flowManifest) };
}

test("exchange round trip preserves protected context and produces no-write routes", () => {
  const { census, flow } = fixture();
  const csv = renderProseExchangeCsv(census, flow);
  const table = parseCsv(csv);
  const header = table[0];
  table[1][header.indexOf("owner_status")] = "replace";
  table[1][header.indexOf("owner_draft")] = "Carry my name.";
  table[1][header.indexOf("owner_note")] = "Owner approved.";
  const edited = table.map((row) => row.map((cell) => `"${String(cell).replace(/\n/g, "\\n").replace(/"/g, '""')}"`).join(",")).join("\n") + "\n";
  const plan = importProseExchange(edited, census, flow);
  assert.equal(plan.mode, "review-only-no-write");
  assert.equal(plan.summary.replacements, 1);
  assert.equal(plan.changes[0].ownerDraft, "Carry my name.");
  assert.equal(plan.changes[0].route, "housecarl-required");
});

test("exchange rejects duplicate IDs, protected-field drift, empty replacements, and non-ASCII drafts", () => {
  const { census, flow } = fixture();
  const csv = renderProseExchangeCsv(census, flow);
  const edit = (updates, duplicate = false) => {
    const table = parseCsv(csv);
    const header = table[0];
    for (const [key, value] of Object.entries(updates)) table[1][header.indexOf(key)] = value;
    if (duplicate) table.push([...table[1]]);
    return table.map((row) => row.map((cell) => `"${String(cell).replace(/\n/g, "\\n").replace(/"/g, '""')}"`).join(",")).join("\n") + "\n";
  };
  assert.throws(() => importProseExchange(edit({}, true), census, flow), /duplicate copy_id/);
  assert.throws(() => importProseExchange(edit({ row_fingerprint: "wrong" }), census, flow), /protected fields changed/);
  assert.throws(() => importProseExchange(edit({ current_runtime_text: "tampered" }), census, flow), /protected column current_runtime_text changed/);
  assert.throws(() => importProseExchange(edit({ owner_status: "replace" }), census, flow), /requires owner_draft/);
  assert.throws(() => importProseExchange(edit({ owner_status: "replace", owner_draft: "Kyne’s call" }), census, flow), /non-ASCII/);
});
