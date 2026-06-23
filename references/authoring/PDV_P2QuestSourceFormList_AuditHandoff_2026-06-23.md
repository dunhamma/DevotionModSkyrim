# P2 Quest-Source FormList Audit — Spinoff Handoff (2026-06-23)

**Mission:** deep-investigate **every** `PDV_FLST_P2_*Sources` quest-source FormList and confirm each
is correctly wired end-to-end for piety points — and populate the empty ones with curated,
evidence-backed quest sources. Triggered by the discovery that **Argonian People points are wired
but unfed** (`PDV_FLST_P2_ArgonianCommunitySources` = 0 items), and the suspicion that this is one of
many.

This is **not** a FormID-dump job. The project enforces a gated curation discipline (below); honoring
it is the point.

---

## The wiring chain (what "correctly wired" means)

For a quest to award a race's piety layer, ALL of these must hold:

1. **FormList shell** `PDV_FLST_P2_<Race><Layer>Sources` exists (FLST). — `--check-formlists`
2. **Alias property** of the same name is wired on the `PDV_Player` alias script (`PDV_PlayerEvents`).
   — `--check-alias-properties`
3. **Registration**: `PDV_PlayerEvents` calls `RegisterQuestStageList(<FormList>)` (so its member
   quests are tracked for stage changes). Confirmed present for Argonian (mgr-side `RegisterQuestStageList`).
4. **Route branch** in `PDV_PlayerEvents`: either the membership form `ShouldRouteP2Source(<FormList>,
   sourceForm, "<race_layer>", sourceKind)` OR the exact-stage form `ShouldRouteP2QuestStage(<FormList>,
   sourceQuest, expectedFormId, approvedStage, routeKey, newStage)` → calls the EventBus route.
   — `--check-route-entries`
5. **EventBus route** (`PDV_EventBus.Route<Race><Layer>(sourceId)`) → **manager handler**
   (`Handle<Race><Layer>...`) → **substrate/relation increment** (anti-farmed via
   `ConsumeDailyRepeatMultiplier`).
6. **FormList POPULATED** with the right quest records at the right stages. — `--check-source-fill`

Steps 1–5 are mostly built across races (the routes/handlers exist). **Step 6 is where the gaps are.**

## The gated population mechanism (DO NOT bypass)

`tools/pdv-phase20-p2-receiver-author` + `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`:

- Curated sources live in the manifest `sourceFillEntries` (grouped by `property` = the FormList).
- `--fill-source-entries` adds them; but `ValidateSourceFillEntries` / `ValidateQuestStageSource` REQUIRE,
  per quest-stage source: `status: "approved-for-fill"`, a `rationale`, `approvedStages` (0–65535),
  `stageReadbackEvidence`, `rejectedStageContext`, `duplicateGuard`, and `questStageGate.receiverStatus
  == "exact-stage-supported"`. Missing any → the fill is refused.
- `stageReadbackEvidence` can be satisfied by a **houseCARL read** of the QUST's stages (confirm the exact
  milestone stage + its log entry), so the spinoff does NOT need to play every quest — but it MUST verify
  the stage is the real "milestone" (accepted), not an intermediate/wrong one (rejected).
- Verify modes (read-only): `--check-formlists`, `--check-alias-properties`, `--check-source-fill`,
  `--check-route-entries`, `--check-exact-stage-gates`. Run all five at the end.
- Curation contract per FormList is in the manifest `sourceProperties[].acceptedUse / rejectedUse`.
  Respect it (e.g. Argonian Community accepts "collective/dock/Assemblage/named-aid"; rejects "generic
  helping, generic Riften/Windhelm travel, unrelated favors").

## Live inventory (houseCARL, Devotion Dev profile, 2026-06-23) — 39 `*P2*` FormLists

**Populated (have items) — verify they're the RIGHT quests/stages, not just non-empty:**
BretonHiddenArtSources(3), DunmerAzuraSources(2), DunmerBoethiahSources(2), ImperialPublicTalosSources(1),
NordHircineArkaySources(1), NordOldWaysSources(3), AltmerAurielSources(2), AltmerLorkhanPenalties(1),
AltmerMagnusSources(2), AltmerXarxesSources(3), **ArgonianHistSources(4)**, BosmerYffreSources(1),
KhajiitFocusedSources(2), KhajiitLunarSources(3), OrcMalacathSources(2), RedguardSpineSources(1).

**EMPTY (0 items) — wired but unfed; no quest awards these layers today:**
**ArgonianCommunitySources (People)**, **ArgonianSithisSources (Void)**, BosmerBaanDarSources,
BosmerZenSources, BretonGreenWaySources, BretonHiddenArtSpells*, BretonKnightsRoadSources, BretonVowSources,
BretonGreenWayHarvests*, DunmerDeviationSources, DunmerMephalaSources, ImperialCivicSources,
ImperialPatronCivicSources, ImperialPrivateTalosSources, ImperialDeathDutySources, ImperialHonestWorkSources,
ImperialLawfulOrderSources, ImperialMercySources, ImperialPublicServiceSources, NordKyneTalosSources,
RedguardAshAbahSources, RedguardCrownSources, RedguardForebearSources.
(*`*Spells`/`*Harvests` are non-quest lists — note but out of the quest-source scope.)

Net: of the quest-source `*Sources` FLSTs, **~16 populated / ~7 races have at least one empty layer**. Imperial
is the worst (8 empty civic/sub-source lists). This is a half-authored P2 quest→piety content layer —
the same "wired-but-unfed / authored-but-inert" class as the quest-matrix-key-drift and
exact-match-on-unproduced-token gaps in project memory.

## Per-FormList audit checklist (run for each of the 39)

- [ ] Shell + alias property + registration present (steps 1–3).
- [ ] Route branch present in `PDV_PlayerEvents` and points at the correct EventBus route (step 4).
- [ ] EventBus route → manager handler → correct relation/piety increment (step 5). Trace the handler;
      confirm it targets the intended layer (e.g. People vs Void vs Hist) and has an anti-farm guard.
- [ ] Populated with curated quests at verified milestone stages (step 6), matching `acceptedUse`,
      avoiding `rejectedUse`. For each: houseCARL-read the QUST stages → record `approvedStages` +
      `stageReadbackEvidence` + `rejectedStageContext` + `duplicateGuard` in the manifest.
- [ ] After fill: `--check-source-fill` + `--check-route-entries` + `--check-exact-stage-gates` all PASS.
- [ ] (Where feasible) in-game: complete the quest milestone, confirm the piety trace fires once
      (Papyrus log: `Route<Race><Layer> complete` + the handler's relation-set trace).

## PRIORITY-1: `PDV_FLST_P2_ArgonianCommunitySources` (Argonian People)

Route confirmed wired (`PDV_PlayerEvents:933` membership → `RouteArgonianCommunity` → `HandleArgonianPeopleSupport`
→ `RecordPeopleSupportScaled` +4). Only the FormList is empty. Curation contract: *collective, dock,
Assemblage, or named Argonian aid milestones*; reject generic favors.

Candidate sources to verify + curate (find FormKeys + the exact milestone stage via houseCARL):
- **Derkeethus** rescue from Darkwater Pass (named Argonian aid) — clearest fit.
- **Scouts-Many-Marshes** Windhelm dockworker fair-pay favor (Argonian Assemblage / dock milestone).
- **Riften Fishery / Bolli** Argonian-dock content (dock collective) — verify it's Argonian-specific, not generic.
- Windhelm Gray-Quarter/Argonian-adjacent milestones that pass the "collective, not generic travel" test.

Pair with **`PDV_FLST_P2_ArgonianSithisSources` (Void)** while you're in Argonian: contract = Dark
Brotherhood / death-facing Sithis *threshold* milestones (reject ordinary contracts) — route
`RouteArgonianSithisAcknowledgment` is wired, list is empty.

## Files
- Tool: `tools/pdv-phase20-p2-receiver-author/Program.cs`
- Manifest (source of truth): `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`
  (`sourceProperties`, `sourceFillEntries`, `routeEntries`, `questStageGate`, `routeContract`)
- Runtime hook: `PDV_PlayerEvents.psc` (alias on `PDV__ManagerQuest`; `ShouldRouteP2Source` /
  `ShouldRouteP2QuestStage`); routes: `PDV_EventBus.psc`; handlers: `PDV__ManagerQuest.psc`.
- Architecture: `references/authoring/PDV_Phase20_ExpandedSignalArchitecture.md` (per-FormList intended sources).
- Registry: `references/authoring/PDV_SignalFloorRegistry.csv`.

## Acceptance
A FormList is "done" when steps 1–6 pass, the curated quests match acceptedUse/rejectedUse, and the five
`--check-*` modes are green. Deliver an updated manifest + one backed-up Devotion.esp `--fill-source-entries`
write + a per-FormList status table (wired? populated? right quests? in-game-proven?).
