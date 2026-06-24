# Green Way 5/5 — Eldergleam quest-stage (Codex Handoff, 2026-06-24)

## Goal
Add the **quest-stage** type to the Breton Green Way path, taking `breton_green_way`
floor **4/5 → 5/5**. Source = completing **"The Blessings of Nature"** (`dunEldergleamT03`,
restoring the Gildergreen with Eldergleam sap) — the canonical nature-site milestone.

## ATOMICITY (critical)
The gate is at **0 RED**. A routeEntry without its PlayerEvents branch makes
`route_branch` FAIL and **RED-regresses `BretonGreenWaySources`**. So author BOTH parts
below in the SAME pass before re-running the gate.

## Part 1 — manifest routeEntry
Add to `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` `routeEntries[]`
(verified via houseCARL live read 2026-06-24: `dunEldergleamT03` stages = [0,10,20,30,40,50,51,52,100], 100 = final/complete):
```json
{
  "id": "breton-eldergleam-blessings",
  "race": "Breton",
  "property": "PDV_FLST_P2_BretonGreenWaySources",
  "sourceKind": "quest-stage",
  "formKey": "015CC2:Skyrim.esm",
  "expectedFormId": 89282,
  "approvedStage": 100,
  "routeKey": "breton_eldergleam_blessings",
  "dispatch": "PDV_EventBusService.RouteBretonGreenWayStanding(\"po3_queststage_breton_eldergleam_blessings\")",
  "acceptedContext": "Completing The Blessings of Nature (restoring the Gildergreen via Eldergleam sap) as a one-shot nature-site Green Way milestone.",
  "rejectedContext": "Intermediate quest stages, generic Whiterun temple errands, or repeated visits.",
  "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey.",
  "mutualExclusionGroup": "breton-eldergleam-blessings",
  "stageReadbackEvidence": "houseCARL dunEldergleamT03 (015CC2) live read 2026-06-24: stages [0,10,20,30,40,50,51,52,100]; 100 = final.",
  "implementationStatus": "route-verified-approved-for-source-fill",
  "reviewStatus": "approved-live-source-fill"
}
```
> Dispatch is `RouteBretonGreenWayStanding` ONLY (NOT `RouteBretonTraditionChoice`) — a
> completed quest should feed Green Way standing, not re-latch the tradition.

## Part 2 — PlayerEvents branch
In `live-source/Scripts/Source/PDV_PlayerEvents.psc`, in the P2 quest-stage handler (mirror
an existing `ShouldRouteP2QuestStage` branch, e.g. the Nord OldWays one), add:
```papyrus
if ShouldRouteP2QuestStage(PDV_FLST_P2_BretonGreenWaySources, sourceQuest, 89282, 100, "breton_eldergleam_blessings", newStage)
    PDV_EventBusService.RouteBretonGreenWayStanding("po3_queststage_breton_eldergleam_blessings")
endIf
```
`RegisterQuestStageList(PDV_FLST_P2_BretonGreenWaySources)` is already present (the surface's
`registration` check passes); confirm, don't duplicate.

## Verify
- `node tools/pdv_compile.mjs --script PDV_PlayerEvents` -> 0/0; `node tools/pdv_verify.mjs` -> FAIL=0.
- `node tools/pdv_signal_e2e_gate.mjs` -> still **39 GREEN / 0 RED** (BretonGreenWaySources stays GREEN, now with a quest-stage route).
- `node tools/pdv_signal_floor_audit.mjs` -> `breton_green_way` **4/5 -> 5/5**.
