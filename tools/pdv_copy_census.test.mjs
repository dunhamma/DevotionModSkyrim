import assert from "node:assert/strict";
import test from "node:test";
import {
  buildCensus,
  extractPapyrusCopy,
  extractPrismaCopy,
  flattenRuntimeRecords,
  parseHousecarlDetail,
  parseManifestRows,
  renderCsv,
  renderFormalOfferUx,
  renderNordKynePacket,
  renderPenpotUxMapSvg,
  renderPietyNarrativeViability,
  stableStringify,
  validateCensus,
} from "./lib/pdv_copy_census.mjs";

const manifestText = `## 10. Nord
| PDV_Msg_Nord_Kyne_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord | Dawn at Faithful | Title: "Kyne Reaches Back" Body: "Will you carry my name?" |
| PDV_Msg_Nord_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture | Accept commits | Accept the bond. |
| PDV_Msg_Nord_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture | Older delay claim | Not yet. |
| PDV_Msg_Nord_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture | Older refusal claim | Refuse the offer. |
| PDV_Notif_Nord_Kyne_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord | Lapse crossing | The wind passes you by today. |`;

test("manifest and live fields retain separate authority", () => {
  const manifests = parseManifestRows(manifestText, "fixture.md");
  const records = parseHousecarlDetail(`type=Message  formid=071513 editorid=PDV_Msg_Nord_Kyne_Offer winner=Devotion.esp
  EditorID = PDV_Msg_Nord_Kyne_Offer
  Name = Kyne Reaches Back
  Description = Will you carry my name?
  MenuButtons[0].Text = Accept the bond.`, "MESG");
  const census = buildCensus({ runtimeRows: flattenRuntimeRecords(records), manifestRows: manifests });
  assert.deepEqual(validateCensus(census), []);
  const body = census.rows.find((row) => row.copyId.endsWith(":description"));
  assert.equal(body.runtimeText, "Will you carry my name?");
  assert.equal(body.referenceText, "Will you carry my name?");
  assert.match(body.runtimeAuthority, /houseCARL/);
  assert.match(body.referenceAuthority, /not presumed live/);
  assert.equal(body.parity, "exact");
  const recordName = census.rows.find((row) => row.copyId.endsWith(":name"));
  assert.equal(recordName.surface, "message-record-name");
  assert.equal(recordName.visibility, "record-metadata-not-rendered");
  const button = census.rows.find((row) => row.surface === "message-button");
  assert.equal(button.parity, "exact");
  assert.equal(button.event, "commitment.accept");
});

test("Papyrus extractor classifies dynamic copy and excludes debug functions", () => {
  const rows = extractPapyrusCopy(`Function ShowSurvey()
  Debug.Notification("The bond holds.")
  SendPrismaEventToast("tier", deityName + " answers.")
EndFunction
Function DebugSeedProof()
  Debug.Notification("Seed complete")
EndFunction`, "live-source/Scripts/Source/Test.psc");
  assert.equal(rows.length, 3);
  assert.equal(rows.filter((row) => row.dynamic).length, 1);
  assert.equal(rows.filter((row) => row.excluded).length, 1);
});

test("Nord offer branches use current mechanics instead of the older reference claim", () => {
  const manifests = parseManifestRows(manifestText, "fixture.md");
  const records = parseHousecarlDetail(`type=Message  formid=071513:Devotion.esp editorid=PDV_Msg_Nord_Kyne_Offer winner=Devotion.esp
  EditorID = PDV_Msg_Nord_Kyne_Offer
  MenuButtons[1].Text = Not yet.
  MenuButtons[2].Text = Refuse the offer.`, "MESG");
  const census = buildCensus({ runtimeRows: flattenRuntimeRecords(records), manifestRows: manifests });
  const notYet = census.rows.find((row) => row.event === "commitment.not-yet" && row.runtimeText);
  const refuse = census.rows.find((row) => row.event === "commitment.refuse" && row.runtimeText);
  assert.match(notYet.gameplayContract, /one in-game day/);
  assert.match(notYet.gameplayContract, /two deferrals/);
  assert.match(refuse.gameplayContract, /permanently marks/);
  assert.equal(notYet.risk, "P1");
  assert.equal(refuse.risk, "P1");
  const packet = renderNordKynePacket(census);
  assert.match(packet, /Where and when it appears/);
  assert.match(packet, /delays Kyne for one in-game day/);
  assert.match(packet, /persistent refusal/);
  assert.match(packet, /does not render a MESG Name field/);
  assert.doesNotMatch(packet, /Title of the dawn modal/);
});

test("Prisma extractor inventories visible HTML without style or comments", () => {
  const rows = extractPrismaCopy(`<main aria-label="Devotion status"><p>Nothing is waiting for dawn.</p><!-- hidden note --></main>`, "view/index.html");
  assert.deepEqual(rows.map((row) => row.runtimeText).sort(), ["Devotion status", "Nothing is waiting for dawn."]);
});

test("rendering is deterministic", () => {
  const census = buildCensus({ runtimeRows: [], manifestRows: parseManifestRows(manifestText, "fixture.md") });
  assert.equal(stableStringify(census), stableStringify(census));
  assert.equal(renderCsv(census), renderCsv(census));
  assert.equal(new Set(census.rows.map((row) => row.copyId)).size, census.rows.length);
  assert.deepEqual(Object.keys(census.summary.byRisk), ["P0", "P1", "P2", "P3"]);
  const formalOfferUx = renderFormalOfferUx(census);
  assert.equal(formalOfferUx.schema, "pdv.formal-offer-ux.v1");
  assert.ok(formalOfferUx.groups.Nord);
  assert.equal(renderPietyNarrativeViability().decision, "investigate-independently-do-not-implement");
  assert.match(renderPenpotUxMapSvg(), /PDV Formal Commitment UX Map/);
});
