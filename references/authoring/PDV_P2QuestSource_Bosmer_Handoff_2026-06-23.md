# P2 Quest-Source FormList — Bosmer Handoff (2026-06-23)

**Mission:** Populate `PDV_FLST_P2_BosmerZenSources` and `PDV_FLST_P2_BosmerBaanDarSources`
with curated, evidence-backed quest-stage entries under the gated curation discipline.
Both are among the thinnest paths in the floor audit. The Exchange and Bandit Road paths
have zero quest-source piety today; all P2 scoring for those paths comes from the organic
signal layer (activators, Papyrus events) alone.

This is **not** a FormID-dump job. Every entry must go through the manifest's
`ValidateQuestStageSource` gate before `--fill-source-entries` will write it.

---

## FormLists in scope

| FormList | Route (manifest) | Accepted use | Rejected use |
|---|---|---|---|
| `PDV_FLST_P2_BosmerZenSources` | `PDV_EventBus.RouteBosmerZenExchange(sourceId)` | Curated Z'en exchange, debt-settling, proportional justice, or contract-completion sources | Generic trade, generic bounty loops, ordinary looting, or unrelated favor quests |
| `PDV_FLST_P2_BosmerBaanDarSources` | `PDV_EventBus.RouteBosmerBaanDarRoad(sourceId)` | Curated Baan Dar road-life, exile-survival, reversal, and survival-cunning sources | Generic theft, generic travel, ordinary bandit killing, or repeatable crime loops |

**For contrast:** `PDV_FLST_P2_BosmerYffreSources` is already populated (DA05 stages 100/105 — Ill Met By Moonlight hunt/mercy outcomes). Use that entry's structure as the template for new entries.

---

## Wiring chain — confirmed

All five chain steps are live and intact for both FormLists. No GAPs found.

**Step 1 — FormList shells:** Both `PDV_FLST_P2_BosmerZenSources` and `PDV_FLST_P2_BosmerBaanDarSources` exist as FLST records. Confirmed by `--check-formlists` PASS (2026-06-04 audit).

**Step 2 — Alias properties:** Both property names are wired on `PDV_PlayerEvents` alias. Confirmed by `--check-alias-properties` PASS.

**Step 3 — Registration:** `PDV_PlayerEvents` calls `RegisterQuestStageList` for Bosmer FormLists at startup.

**Step 4 — Route branches** (`PDV_PlayerEvents.psc`, lines 944-949):
```
if ShouldRouteP2Source(PDV_FLST_P2_BosmerZenSources, sourceForm, "bosmer_zen", sourceKind)
    PDV_EventBusService.RouteBosmerZenExchange(sourceKind + "_bosmer_zen")
endIf
if ShouldRouteP2Source(PDV_FLST_P2_BosmerBaanDarSources, sourceForm, "bosmer_baandar", sourceKind)
    PDV_EventBusService.RouteBosmerBaanDarRoad(sourceKind + "_bosmer_baandar")
endIf
```

**Step 5 — EventBus → Manager → increment:**

*ZenExchange path* (`PDV_EventBus.psc` lines 1112-1115):
```
Function RouteBosmerZenExchange(String sourceId)
    RouteBosmerExchange()       ; → PDV_EventBus.psc:892
    Trace(2, "RouteBosmerZenExchange complete: " + sourceId)
EndFunction
```
`RouteBosmerExchange()` (line 892) → `PDV_Manager.HandleBosmerExchangeSignal("eventbus_" + eventType)` → `PDV__ManagerQuest.psc:4063`. Handler: guards `IsBosmerOrigin()`, applies `ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerExchange")` (anti-farm), records `RecordEvidenceDay(BOSMER_PATH_EXCHANGE, reason)`, then `AwardCuratedSignalScaled(PDV_Zen, PDV_Zen.SIGNAL_EXCHANGE, ...)` gated on `GetCurrentState() == BOSMER_PATH_EXCHANGE`.

*BaanDarRoad path* (`PDV_EventBus.psc` lines 1117-1120):
```
Function RouteBosmerBaanDarRoad(String sourceId)
    RouteBosmerBanditRoad()     ; → PDV_EventBus.psc:908
    Trace(2, "RouteBosmerBaanDarRoad complete: " + sourceId)
EndFunction
```
`RouteBosmerBanditRoad()` (line 908) → `PDV_Manager.HandleBosmerBanditRoadSignal("eventbus_" + eventType)` → `PDV__ManagerQuest.psc:4081`. Handler: mirrors Exchange — `ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerBanditRoad")` (anti-farm), `RecordEvidenceDay(BOSMER_PATH_BANDIT_ROAD, reason)`, `AwardCuratedSignalScaled(PDV_BaanDar, PDV_BaanDar.SIGNAL_BANDIT_ROAD, ...)` gated on `GetCurrentState() == BOSMER_PATH_BANDIT_ROAD`.

**Both paths have a functioning anti-farm daily-repeat cap and a path-active gate. Step 6 (FormList populated) is the only gap.**

---

## PDV_FLST_P2_BosmerZenSources — candidates to verify and curate

**Lore anchor:** Z'en is the Bosmer god of payment in kind — balance, not revenge; debt-honoring, proportionate return. The Exchange path scores debt-settling, contract-completion, proportionate vengeance, and justice-facing resolutions. Reject generic bounties, trade loops, or looting.

**Note on vanilla coverage:** Z'en debt-settling content is thin in vanilla Skyrim. There are no quests explicitly about Z'en. All candidates below are quests whose structure maps to the debt/contract/proportional-justice concept — Codex must verify lore fit is defensible before approving.

| # | Quest (ID) | Candidate stage | Why it fits | Why to be careful | Verify |
|---|---|---|---|---|---|
| 1 | **The Golden Claw** (`MS13`) | Stage 100 (pendant returned, dungeon cleared, debt settled to its owner) | Classic debt-recovery: the Lucan quest is literally about restoring what was taken; the player completes a contract implied at the start | Generic dungeon quest feel — verify stage 100 is the final resolution stage, not a mid-quest step | VERIFY exact FormKey + milestone stage via houseCARL |
| 2 | **In My Time of Need** (`MS08`) | Stage 100 (Saadia protected) or Stage 110 (Alik'r paid — Kematu wins) | Both branches involve a claim and a settlement: one by protection, one by turning her over; Exchange Bosmer could honor either contract | Stage selection is branch-critical; do not approve both branches as a duplicate pair without a mutual-exclusion group; verify which stage is the true settlement resolution vs. intermediate | VERIFY exact FormKey + milestone stage via houseCARL |
| 3 | **A Chance Arrangement** (`TG00`, first Thieves Guild job, debt owed to Brynjolf) | Stage 200 (planted item, deal fulfilled) | A promise was made to Brynjolf; fulfilling it honors the exchange even if the act itself is theft — the contract-honoring is the Z'en signal | The theft framing may fail `rejectedUse` ("generic theft"); only approvable if the contract-completion framing dominates; confirm stage is a genuine one-shot resolution, not a repeatable job | VERIFY exact FormKey + milestone stage via houseCARL |
| 4 | **Promises to Keep** (`FreeformRiften07`) or a named debt-resolution favor quest | Stage 200 (Frost returned, contract with Louis Letrush honored) | Named NPC contract, genuine debt: the player agreed to deliver a horse and does so; Z'en would recognize this | Small quest; verify it actually has a tracked quest-stage at resolution (not just a DialogueQuest marker) | VERIFY exact FormKey + milestone stage via houseCARL |
| 5 | **The Mind of Madness** (`DA15`) is out of scope. Consider instead **Caught Red Handed** (`FreeformRiften08`) — debt/leverage/truth | Stage 100 (Svana's debt to Haelga collected via blackmail tokens) | Proportional recovery: three tokens = three witnesses = Haelga's exploitation ended; balance restored | Blackmail framing may feel like Nocturnal/Mephala territory; Z'en interpretation is defensible (the account was uneven, Svana collects what was taken), but needs explicit rationale in the manifest entry | VERIFY exact FormKey + milestone stage via houseCARL |

**Minimum fill target:** 2 approved entries. 3 is the recommended floor given thin path coverage. Do not pad with quests that don't fit `acceptedUse` — an empty list is better than a mis-curation.

---

## PDV_FLST_P2_BosmerBaanDarSources — candidates to verify and curate

**Lore anchor:** Baan Dar is the Bosmer trickster patron of outcasts, exiles, and road-life survival. The Bandit Road path scores exile-survival, outcast solidarity, cunning reversals, and survival under duress. Reject generic theft loops, ordinary bandit killing, and repeatable content.

**Note on vanilla coverage:** The race sheet explicitly flags that Bandit Road sources were "inferred, not wired" — vanilla Skyrim has sparse content for exile-survival and outcast identity. Road-cunning and reversal quests exist but require careful stage-selection to isolate the terminal "survived by cunning" beat. Some candidates below are structurally weaker; mark them clearly.

| # | Quest (ID) | Candidate stage | Why it fits | Why to be careful | Verify |
|---|---|---|---|---|---|
| 1 | **No One Escapes Cidhna Mine** (`MS02`) | Stage 200 (escaped; survival through cunning in captivity) | The definitive exile-survival arc in vanilla: stripped of everything, must navigate prison politics to escape; the reversal — prisoner becomes free — is exactly the Baan Dar narrative | Very long quest with complex branching; identify the exact "escaped" resolution stage and confirm it is one-shot; Forsworn-side escape vs. Madanach cooperation may produce different stage numbers — pick the stage that fires for any successful escape, not a faction-specific one | VERIFY exact FormKey + milestone stage via houseCARL |
| 2 | **Forbidden Legend** (`dunAngarvundeQST`) / or a named road-survival marker | Completion stage | Relic hunt that requires surviving ambushes in hostile territory; feels like road-life cunning | Weak lore connection to Baan Dar specifically — "survived a dungeon" may read as generic; only approvable if the dungeon has a clear "exile survived against the odds" resolution stage | VERIFY exact FormKey + milestone stage via houseCARL; likely WEAK, require strong rationale |
| 3 | **The Forsworn Conspiracy** (`MS01`) | Stage 100 (Imprisoned, forced into Cidhna Mine — the entry point of exile) | The arrest IS the exile threshold; Baan Dar road life begins when you're cast out | This is the entry, not the exit — better as a companion entry paired with MS02 Stage 200; on its own it fires before the survival, not after; mark as paired/conditional if approved | VERIFY exact FormKey + milestone stage via houseCARL |
| 4 | **A Chance Arrangement** (`TG00`) — same as ZenSources candidate #3 | Stage 200 | Road-trickster framing: the first Thieves Guild job is the prototype Baan Dar cunning act — a planted item, an engineered outcome | This quest appears in ZenSources candidates too; if approved for both, a mutual-exclusion group is mandatory (same quest cannot fire both routes); requires explicit `duplicateGuard` noting the cross-FormList conflict | VERIFY exact FormKey + milestone stage via houseCARL; FLAG cross-FormList conflict |
| 5 | **In Service To Crime** (`TG01`, first full Thieves Guild job) — or a named road-survival reversal | Stage 200 (job completed; road-trickster contract honored) | After `TG00`, this is the first real Guild job: trickster cunning, working the margins, road-life skills applied | Repeatable job class; confirm `TG01` is a one-shot quest, not a repeatable radiant job wrapper; if repeatable, reject — Bandit Road cannot use repeatable jobs as sources | VERIFY repeatability via houseCARL before considering |

**Minimum fill target:** 2 approved entries. MS02 Stage 200 (Cidhna Mine escape) is the strongest single candidate for this list; anchor on that if stage verification passes.

---

## Gated-fill block (clone from BosmerYffreSources pattern)

For each approved source, add an entry to `sourceFillEntries` in
`references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`:

```json
{
  "property": "PDV_FLST_P2_BosmerZenSources",    /* or BosmerBaanDarSources */
  "sources": [
    {
      "formKey": "XXXXXX:Skyrim.esm",             /* houseCARL-verified; never guess */
      "editorId": "QuestEditorId",
      "sourceKind": "quest-stage",
      "status": "approved-for-fill",
      "approvedStages": [ NNN ],
      "stageReadbackEvidence": "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
      "rejectedStageContext": "Describe which stages or branches are explicitly rejected.",
      "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey bosmer_<quest>_zen (or _baandar).",
      "rationale": "One-sentence lore rationale; cite accepted use and rejection of the listed rejected use."
    }
  ]
}
```

**Fill-tool safety rules (do not bypass):**
- `status` must be `"approved-for-fill"` — the tool refuses all other values.
- `approvedStages` must be present for `quest-stage` sourceKind.
- `stageReadbackEvidence` must point at the existing CSV (already present in the project).
- `rejectedStageContext` and `duplicateGuard` are required fields.
- `questStageGate.receiverStatus` must equal `"exact-stage-supported"` — it does for Bosmer per the manifest header.
- Run `--check-exact-stage-gates` after editing to confirm the gate sees the new entries.

If TG00 (`A Chance Arrangement`) is approved for both ZenSources and BaanDarSources, add a `mutualExclusionGroup` key to both entries and confirm `ShouldRouteP2Source` will only match one FormList per event (it will, because each FLST is checked independently; but the player cannot be on both Exchange and Bandit Road simultaneously — the path gate in the handler prevents double-scoring).

---

## Acceptance

A FormList is done when all five checks pass and at least one entry fires a Papyrus-log trace:

1. `--check-formlists` — shells present (already green; confirm not regressed).
2. `--check-alias-properties` — properties wired (already green; confirm not regressed).
3. `--check-route-entries` — static route metadata present for new entries.
4. `--check-source-fill` — approved entries written into the FLST via the fill tool.
5. `--check-exact-stage-gates` — stage gate metadata valid for each new quest-stage entry.
6. (Recommended, not blocking) In-game: complete one approved quest milestone on a Bosmer Exchange/Bandit Road save; confirm Papyrus log shows `RouteBosmerZenExchange complete` / `RouteBosmerBaanDarRoad complete` and the handler's `AwardCuratedSignalScaled` trace.

Run all five via:
```
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-formlists --check-alias-properties --check-route-entries --check-source-fill --check-exact-stage-gates
```

---

## Hand-back

Deliver:
- Updated `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` with approved entries in `sourceFillEntries`.
- One `--fill-source-entries` write to `Devotion.esp` (backup auto-created).
- Per-FormList status row (wired? populated? right quests? in-game proven?) in `PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md` or a new status table.

Do **not** add entries that fail `acceptedUse` to hit a minimum count. If vanilla coverage is too thin to reach 2 approved entries for BaanDarSources, note the gap explicitly and leave the FormList empty — an inert-but-correctly-wired list is better than a mis-curation.

---

## Files

| File | Role |
|---|---|
| `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` | Source of truth: `sourceProperties`, `sourceFillEntries`, `questStageGate` |
| `tools/pdv-phase20-p2-receiver-author/Program.cs` | Fill + check tool |
| `live-source/Scripts/Source/PDV_PlayerEvents.psc` | Route branches (lines 944-949 for Bosmer) |
| `live-source/Scripts/Source/PDV_EventBus.psc` | `RouteBosmerZenExchange` (1112), `RouteBosmerBaanDarRoad` (1117), `RouteBosmerExchange` (892), `RouteBosmerBanditRoad` (908) |
| `live-source/Scripts/Source/PDV__ManagerQuest.psc` | `HandleBosmerExchangeSignal` (4063), `HandleBosmerBanditRoadSignal` (4081) |
| `race-sheets/PDV_RaceDesign_Bosmer.md` | Lore, path definitions, signal examples, Z'en/Baan Dar design spec |
| `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv` | Stage evidence source (`stageReadbackEvidence` pointer) |
