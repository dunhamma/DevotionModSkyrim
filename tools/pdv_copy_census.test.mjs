import assert from "node:assert/strict";
import fs from "node:fs";
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
import { assignFlowIds, buildCopyFlowModel, renderFullFlowPenpotSvg } from "./lib/pdv_copy_flow.mjs";

const flowManifest = JSON.parse(fs.readFileSync(new URL("../references/authoring/PDV_CopyFlowMap.json", import.meta.url), "utf8"));

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
  const debugOnly = extractPapyrusCopy(`Function DebugApplyTalosBetrayalCompliance()
  Debug.Notification("Talos betrayal did not apply.")
EndFunction`, "live-source/Scripts/Source/Test.psc");
  assert.equal(debugOnly.length, 1);
  assert.equal(debugOnly[0].excluded, true);
});

test("cross-cutting live reactions map to explicit journey families", () => {
  const base = { copyId: "fixture", journey: "Nord", event: "unclassified", surface: "message-body", runtimeLocation: "Devotion.esp:MESG:1:Devotion.esp:PDV_MSG_StartupNordChoice:Description", runtimeText: "Choose.", gameplayContract: "", referenceLocation: "", referenceText: "" };
  const cases = [
    ["PDV_MSG_StartupNordChoice", "journey.origin-choice"],
    ["HandleBosmerSuggestionPopup", "journey.origin-choice"],
    ["PDV_Msg_Nord_CurseState_VampireCured", "journey.curse-transition"],
    ["PDV_MESG_ArgonianAdaptRite", "journey.cultural-rite"],
    ["PDV_MESG_KhajiitMoon_01_Khenarthi", "journey.lunar-focus"],
    ["PDV_MSG_BosmerReckoning", "journey.reckoning"],
    ["CheckPapyrusUtilDependency", "journey.system-ux"],
    ["PDV_SurveyDevotionEffect.psc", "journey.system-ux"],
    ["PDV_Notif_Altmer_Xarxes_ChampionAmbient_Record", "core.champion"],
  ];
  for (const [token, expected] of cases) {
    const ids = assignFlowIds({ ...base, runtimeLocation: token });
    assert.ok(ids.includes(expected), `${token} should map to ${expected}`);
    assert.ok(!ids.includes("flow.unresolved"), `${token} should not remain unresolved`);
  }
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
  const flow = buildCopyFlowModel(census, flowManifest);
  assert.equal(flow.summary.missingSurfaceRows, 0);
  assert.equal(renderFullFlowPenpotSvg(flow), renderFullFlowPenpotSvg(flow));
  assert.match(renderFullFlowPenpotSvg(flow), /PDV 2.0 Current In-Game UX Flow/);
});

test("full-flow assignment joins journey and surface without losing unclassified live copy", () => {
  const manifests = parseManifestRows(manifestText, "fixture.md");
  const records = parseHousecarlDetail(`type=Message  formid=071513:Devotion.esp editorid=PDV_Msg_Nord_Kyne_Offer winner=Devotion.esp
  EditorID = PDV_Msg_Nord_Kyne_Offer
  MenuButtons[1].Text = Not yet.
type=Spell  formid=081513:Devotion.esp editorid=PDV_Bless_Daedric_Azura_T2 winner=Devotion.esp
  EditorID = PDV_Bless_Daedric_Azura_T2
  Name = Moonlit regard
type=Message  formid=091513:Devotion.esp editorid=PDV_Msg_Other_PlayerThing winner=Devotion.esp
  EditorID = PDV_Msg_Other_PlayerThing
  Description = A live but unclassified line.`, "MESG");
  const census = buildCensus({ runtimeRows: flattenRuntimeRecords(records), manifestRows: manifests });
  const flow = buildCopyFlowModel(census, flowManifest);
  const notYet = flow.byCopyId.get(census.rows.find((row) => row.runtimeText === "Not yet.").copyId);
  assert.ok(notYet.flowIds.includes("commit.not-yet"));
  assert.ok(notYet.flowIds.includes("race.nord"));
  assert.ok(notYet.flowIds.includes("surface.message"));
  const azura = flow.byCopyId.get(census.rows.find((row) => row.runtimeText === "Moonlit regard").copyId);
  assert.ok(azura.flowIds.includes("daedric.milestone"));
  assert.ok(azura.flowIds.includes("surface.effects"));
  const unresolved = flow.byCopyId.get(census.rows.find((row) => row.runtimeText === "A live but unclassified line.").copyId);
  assert.ok(unresolved.flowIds.includes("flow.unresolved"));
  assert.ok(unresolved.flowIds.includes("surface.message"));
});
