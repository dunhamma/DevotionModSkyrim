# P2 Quest-Source FormList — Dunmer Handoff (2026-06-23)

**Mission:** Populate `PDV_FLST_P2_DunmerMephalaSources` and `PDV_FLST_P2_DunmerDeviationSources`
under the gated curation discipline. Both FormLists are wired end-to-end (steps 1–5 confirmed);
only step 6 (source fill) is missing.

**Out of scope this handoff:**
- `PDV_FLST_P2_DunmerAzuraSources` — populated (2 books; DA01 stage 100 route wired).
- `PDV_FLST_P2_DunmerBoethiahSources` — populated (2 books; DA02 stage 100 route wired).
- Any non-Dunmer FormLists.

---

## FormLists in Scope

| FormList | Route fn | Handler fn | Increment site | Anti-farm |
|---|---|---|---|---|
| `PDV_FLST_P2_DunmerMephalaSources` | `PDV_EventBus.RouteDunmerReclamationFocus(2, sourceId)` | `HandleDunmerReclamationFocus` (Manager:12524) | `AwardDunmerReclamationFocusSignal` → `AwardCuratedSignalScaled(PDV_Mephala, SIGNAL_SECRET_KEPT, …)` (Manager:12638) | `MarkP2SourceRoute` one-shot per source/kind (PlayerEvents:1423) |
| `PDV_FLST_P2_DunmerDeviationSources` | `PDV_EventBus.RouteDunmerDeviationPrice(sourceId)` | `HandleDunmerDeviationPrice` (Manager:12545) | `AwardDunmerDeviationPriceSignal` → `AwardCuratedSignal` on active Reclamation patron (Manager:12648) | `MarkP2SourceRoute` one-shot per source/kind |

**Wiring chain verification (steps 1–5):**

- Steps 1–3: FormList shells + alias properties + registration confirmed PASS per manifest
  `formListShellReadback` / `aliasPropertyReadback` (both "PASS - all 34 PDV_FLST_P2_*").
- Step 4 route branches confirmed in `live-source/Scripts/Source/PDV_PlayerEvents.psc`:
  - Mephala membership route: line 872 (`ShouldRouteP2Source(PDV_FLST_P2_DunmerMephalaSources, …)`).
  - Deviation membership route: line 875 (`ShouldRouteP2Source(PDV_FLST_P2_DunmerDeviationSources, …)`).
  - Deviation exact-stage route: line 1017 (`ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerDeviationSources, sourceQuest, 166614, 110, "dunmer_da01_black_star", newStage)` → DA01 Black Star branch).
- Step 5 handlers confirmed in `live-source/Scripts/Source/PDV__ManagerQuest.psc`:
  - `HandleDunmerReclamationFocus` at line 12524 (origin-guard → layer-weight → `AwardDunmerReclamationFocusSignal`).
  - `HandleDunmerDeviationPrice` at line 12545 (origin-guard → `AwardDunmerDeviationPriceSignal`).

**Step 6 (source fill): EMPTY for both. This is the only gap.**

---

## Design Context (from `race-sheets/PDV_RaceDesign_Dunmer.md`)

**Mephala (ReclamationFocus index 2):** The hidden community and maintained-secrets layer. Hidden
network survival: Thieves Guild as Mephala's web, Dunmer refugee protection, dangerous targeted
secrets. Accepted hooks per race-sheet: Whispering Door / Ebony Blade, Thieves Guild/network stages,
protected secrets, Grey Quarter hidden-community. **Mephala lacks any approved Reclamation book** —
the existing Azura and Boethiah fills both used books; Mephala-specific devotional books are absent
in vanilla Skyrim. Quest-stage sources are the primary path here.

**DeviationSources:** Captures the price/pressure of non-Reclamation Daedric contact, rival-Prince
push, Black Star outcome (DA01 stage 110 already wired), vampirism deviation signal. Sources must
be curated threshold/crisis moments, not generic Daedric behavior or ordinary spell/quest progress.

**IMPORTANT behavioral note — DeviationSources:** `AwardDunmerDeviationPriceSignal` (Manager:12648)
only fires if `_activeDeity` is already one of the three Reclamation Princes. A player with no
active patron sees a silent no-op. This is by design (deviation requires a baseline commitment to
deviate from), not a bug. Do not attempt to "fix" it. Candidates for DeviationSources should be
flagged in rationale as meaningful even when the active-patron guard is present.

---

## Candidate Sources to Verify and Curate

### `PDV_FLST_P2_DunmerMephalaSources` — acceptedUse: curated Mephala/Reclamation source; rejectedUse: generic stealth, generic poison, generic Daedric contact

All are `sourceKind: quest-stage` (no vanilla Mephala-specific book exists).
Each needs: houseCARL read of the QUST stages → confirm exact milestone stage + log entry →
fill `approvedStages`, `stageReadbackEvidence`, `rejectedStageContext`, `duplicateGuard`.

| # | Candidate | Quest EditorId | Likely milestone stage | Fit rationale | Verification needed |
|---|---|---|---|---|---|
| 1 | **The Whispering Door** (DA08) — Ebony Blade obtained | DA08 | Stage 40 or 50 (blade handed over / player has it) | Direct Mephala quest; the artifact is Mephala's instrument in Dunmer tradition; maximum natural fit | VERIFY exact FormKey + which stage is the terminal "Mephala handed blade" milestone via houseCARL |
| 2 | **Thieves Guild — Joined / inducted** (TGIntro / TG00) | TG00 or equivalent | Stage of first induction, not radiant jobs | Mephala's web = hidden network; joining is the threshold act per race-sheet; reject generic rank | VERIFY the induction-complete stage (the moment of joining, not completion of first job); confirm it is one-shot and not repeated on radiant loops |
| 3 | **Thieves Guild — Restored / full rebuild** (TGTQ04 or TGLeader) | TGLeader or TGTQ04 | Terminal restoration stage | The Guild fully restored as functioning hidden network — stronger Mephala threshold than mere joining | VERIFY FormKey + terminal stage; confirm mutual-exclusion with induction candidate above if both are approved |
| 4 | **Diplomatic Immunity** (MQ201) — Thalmor Embassy infiltration | MQ201 | Stage 200 or nearest terminal | Mephala: covert infiltration at personal risk to protect a secret (the Blades); highest-stakes hidden-network act accessible to all playstyles | VERIFY FormKey + exact terminal stage; rationale must note it is the network act, not generic Thalmor antipathy |
| 5 | **No Stone Unturned** (TGRFO) — Thieves Guild relic quest terminal | TGRFO | Stage 30 (final gem placed) | Deep Guild/network milestone beyond mere membership; one-shot by nature; Mephala's obligation web maintained through the whole collection arc | VERIFY FormKey + final placement stage; confirm it is truly one-shot (collection quests sometimes have repeating stages) |

**No books for Mephala:** There is no vanilla Skyrim book comparable to `Book4RareInvocationofAzura`
for Mephala. Do not add generic books (generic stealth manuals, generic poison/alchemy texts) — they
fail `rejectedUse`. If a Mephala-specific devotional text is discovered via houseCARL search, flag
it for a future tranche; do not block the quest-stage fill on it.

---

### `PDV_FLST_P2_DunmerDeviationSources` — acceptedUse: curated deviation, curse, or rival-Prince pressure; rejectedUse: generic Daedric behavior, ordinary spell/quest progress

Mix of `quest-stage` and `book`. DA01 stage 110 (Black Star) already has a
`approved-static-route-only` routeEntry (`dunmer-da01-black-star`) — it only needs the FLST fill
entry declared `approved-for-fill` with the matching fields, since the route is already wired.

| # | Candidate | Quest / FormKey | Likely milestone stage | Fit rationale | Verification needed |
|---|---|---|---|---|---|
| 1 | **DA01 — The Black Star** (Azura's Star / Nelacar branch) | DA01 `028B0E:Skyrim.esm` | Stage 110 | Already wired as `dunmer-da01-black-star` routeEntry; choosing the Black Star over Azura is the clearest rival-Prince-over-Reclamation deviation; MUTUAL EXCLUSION with DA01 stage 100 (Azura branch) already enforced via `mutualExclusionGroup: da01-branch-outcome` | Confirm stage 110 via houseCARL readback; the FormKey is already in routeEntries (`028B0E:Skyrim.esm`, expectedFormId 166614) — use it directly in the fill entry; add `approvedStages: [110]`, `stageReadbackEvidence`, `rejectedStageContext: "Azura branch (stage 100), artifact possession alone, generic soul gem use"`, `duplicateGuard: "MarkP2SourceRoute stores quest form plus routeKey dunmer_da01_black_star_stage_110"` |
| 2 | **House of Horrors** (DA10 / Molag Bal) — Mace obtained | DA10 | Terminal stage (Molag Bal's mace handed) | Molag Bal is the House of Troubles; explicit vampire/domination pressure; taking the mace is a voluntary pact with the most hostile Prince to Dunmer ancestors; deviation is real and has theological weight | VERIFY FormKey + exact terminal "mace received" stage via houseCARL; confirm one-shot |
| 3 | **Discerning the Transmundane** (DLC1HH — Hermaeus Mora) — Oghma Infinium received | DLC1HH | Terminal stage (Oghma Infinium given) | Hermaeus Mora = foreign dangerous knowledge; voluntarily trading with him constitutes Dunmer deviation per race-sheet; fits `rejectedUse` of "ordinary quest progress" cleanly because the terminal gift is a specific pact moment | VERIFY FormKey + stage for the Oghma Infinium handoff; confirm it is the terminal one-shot, not an intermediate |
| 4 | **Pieces of the Past** (DA15 — Mehrunes Dagon) — Mehrunes' Razor assembled | DA15 | Terminal stage (Razor assembled / Dagon invoked) | Mehrunes Dagon is the second House of Troubles; Razor assembly is a deliberate pact act, not incidental quest progress; fits race-sheet "Destruction-revolution-ruin" taboo entry | VERIFY FormKey + terminal stage; note rationale must distinguish razor assembly from generic dungeon exploration earlier in the quest |
| 5 | **Volkihar vampire sire** / `DLC1VQ01` — vampire infection accepted | DLC1VQ01 or vampire-onset | Vampire-accept stage | Active vampirism = Ancestor Posture `Silent`; the deviation signal at this threshold is the theologically correct Dunmer rupture marker (the moment the ash-prayer goes silent); cross-reference with existing vampire-onset detection to confirm this is additive, not duplicate | VERIFY whether PDV already fires a Dunmer substrate signal at vampire onset; if yes, this fill entry may be redundant — confirm before adding |

**Book candidate for DeviationSources:**
- **No suitable book confirmed.** Generic Daedric texts fail `rejectedUse`. If a Molag Bal or
  Mehrunes Dagon-specific devotional text exists in vanilla (analogous to Boethiah's Proving),
  flag for review; do not add speculatively.

---

## Gated-Fill Block (clone into manifest, one entry per approved candidate)

```json
{
  "property": "PDV_FLST_P2_DunmerMephalaSources",
  "sources": [
    {
      "formKey": "VERIFY_VIA_HOUSECARL:xxxxxx",
      "editorId": "DA08",
      "sourceKind": "quest-stage",
      "status": "approved-for-fill",
      "approvedStages": [ VERIFY ],
      "stageReadbackEvidence": "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
      "rejectedStageContext": "Generic stealth, generic poison use, pre-blade stages, and artifact possession alone.",
      "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey dunmer_da08_mephala_stage_<N>.",
      "rationale": "One-shot Whispering Door terminal milestone for Dunmer Mephala Reclamation focus; rejects generic Daedric contact."
    }
  ]
}
```

```json
{
  "property": "PDV_FLST_P2_DunmerDeviationSources",
  "sources": [
    {
      "formKey": "028B0E:Skyrim.esm",
      "editorId": "DA01",
      "sourceKind": "quest-stage",
      "status": "approved-for-fill",
      "approvedStages": [ 110 ],
      "stageReadbackEvidence": "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
      "rejectedStageContext": "Azura branch (stage 100), generic soul gem use, artifact possession alone.",
      "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey dunmer_da01_black_star_stage_110.",
      "rationale": "Black Star branch resolution as a one-shot Dunmer deviation marker; DA01 routeEntry already wired (approved-static-route-only); this fill entry declares the source approved-for-fill."
    }
  ]
}
```

Repeat the pattern for each additional approved candidate. The fill tool requires all six fields
(`status: "approved-for-fill"`, `rationale`, `approvedStages`, `stageReadbackEvidence`,
`rejectedStageContext`, `duplicateGuard`) and `questStageGate.receiverStatus == "exact-stage-supported"`
(already set in manifest). Missing any field = fill refused.

**The DA01 Black Star entry is the lowest-friction first fill** — FormKey and routeEntry metadata are
already in the manifest; only the sourceFillEntry needs to be added with `approved-for-fill` status
and the six required fields.

---

## Acceptance

A FormList is done when all five `--check-*` modes pass green and the curated stages match
`acceptedUse` / `rejectedUse`:

```
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-formlists
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-alias-properties
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
```

Then `--fill-source-entries` to write to ESP (back up first per `sourceFillPlan.fillCommand`).

E2E gate: complete a Mephala candidate quest to the approved stage in-game; verify Papyrus log shows
`RouteDunmerReclamationFocus complete: … focus 2`; verify Deviation fires at DA01 stage 110 with
`RouteDunmerDeviationPrice complete`. Confirm no repeat on replay (anti-farm).

---

## Hand-Back

Deliver:
1. Updated `PDV_Phase20_P2ImmersiveReceivers.manifest.json` with approved `sourceFillEntries` for
   both FormLists + `routeEntries` updated from `approved-static-route-only` to
   `approved-live-source-fill` for any newly-approved quest-stage entries.
2. Post-fill `--check-source-fill` PASS screenshot or log snippet.
3. Per-FormList status row: wired ✓, populated ✓, right quests ✓, in-game-proven (pending / date).
4. Note any candidate that was inspected and rejected (with the rejection reason per `rejectedUse`)
   so the curation record is durable.
