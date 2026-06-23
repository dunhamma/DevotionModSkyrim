# P2 Quest-Source FormList — Redguard Spinoff Handoff (2026-06-23)

**Parent audit:** `references/authoring/PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md`
**Status:** Scoped handoff — Crown / Forebear / Ash'abah empty FormLists only.
**Contrast reference:** `PDV_FLST_P2_RedguardSpineSources` already has 1 entry (book
`Skyrim.esm:01ACD1` / Manual of Mixed Unit Tactics) and routes via
`RouteRedguardAncestorSpine` → `HandleRedguardAncestorSpine`. It is populated and
**out of scope**.

---

## Mission

Three Redguard P2 quest-source FormLists are wired end-to-end but **empty**, so no quest
milestone currently awards sect-lane piety.

**Blocked status note (from project memory / session-C context):** Forebear and Ash'abah
exact-stage approvals were previously BLOCKED pending a source-fill ledger declaration for
these FormLists. **This handoff is the unblocking artifact.** Codex must curate exact
milestone stages, verify them via houseCARL, record the required gated-fill metadata in
`PDV_Phase20_P2ImmersiveReceivers.manifest.json`, and execute `--fill-source-entries` once
metadata passes `ValidateQuestStageSource`.

---

## FormLists in Scope

| FormList | Route fn (PDV_EventBus.psc) | Inner fn dispatched | Handler (PDV__ManagerQuest.psc) | Increment site | acceptedUse (short) | rejectedUse (short) | Chain status |
|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_RedguardCrownSources` | `RouteRedguardSectSignal(0, …)` → `RouteRedguardCrownTombRespect()` (EventBus:767) | `HandleRedguardCrownTombRespect` (Manager:5315) | `AwardRedguardCrownSignal` (Manager:5643) via `ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardCrownTombRespect")` (Manager:5320) | Tu'whacca SIGNAL_CROWN_FORM via `AwardCuratedSignalScaled` (Manager:5645) | Crown, Alik'r, honorable martial, ancestor-duty quest stages | Generic Alik'r proximity, ordinary NPC contact, generic bounty, non-terminal MS08 | **CHAIN INTACT — STEP 6 ONLY (empty FormList)** |
| `PDV_FLST_P2_RedguardForebearSources` | `RouteRedguardSectSignal(1, …)` → `RouteRedguardForebearRoadPassage()` (EventBus:783) | `HandleRedguardForebearRoadPassage` (Manager:5326) | `AwardRedguardForebearSignal` (Manager:5649) via `ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")` (Manager:5331) | Leki SIGNAL_SWORD_SINGING when `_activeDeity == PDV_Leki`; RecordRedguardSectSignal always records substrate (Manager:5332) | Forebear, road-passage, exile-protection, contract, make-way quest stages | Generic travel, ordinary mercenary work, repeated caravan contact, non-terminal MS08 state | **CHAIN INTACT — STEP 6 ONLY (empty FormList)** |
| `PDV_FLST_P2_RedguardAshAbahSources` | `RouteRedguardSectSignal(2, …)` → `RouteRedguardAshAbahDeathDuty()` (EventBus:799) | `HandleRedguardAshAbahDeathDuty` (Manager:5337) | `ApplyRedguardAshAbahDutyRewards` (Manager:5478) via `ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")` (Manager:5342) | Tu'whacca SIGNAL_DEATH_DUTY via `AwardRedguardAshAbahSignal` (Manager:5711) + `TryRedguardTuwhaccaDeathRiteHeal` + `MarkRedguardAshAbahStigma` | Ash'abah, undead-cleansing, death-duty, major necromancer-operation stages | Generic undead combat, repeatable dungeon clearing, generic Arkay proxy text, unrelated necromancer loot | **CHAIN INTACT — STEP 6 ONLY (empty FormList)** |

**Wiring-chain gap finding:** NONE. All three chains are verified intact through
`PDV_PlayerEvents.psc` (lines 966–974 membership route; lines 1071–1076 exact-stage route),
`PDV_EventBus.psc` (`RouteRedguardSectSignal` at line 841 dispatches correctly by sectId),
and `PDV__ManagerQuest.psc` (handlers at lines 5315, 5326, 5337 gate on
`IsRedguardOrigin() && PDV_RedguardSectTrack`; anti-farm via `ConsumeDailyRepeatMultiplier`
present at each site). The **sole gap is Step 6**: all three FormLists have 0 entries.

**Race-sheet design contract (`race-sheets/PDV_RaceDesign_Redguard.md` §"In-game hook
cross-check"):** confirmed that MS08 stages 200/201 are the locked sect-split hooks; Hall
of the Dead quests and major necromancer/undead operations are the primary Ash'abah hooks.
All candidates below derive from that locked table.

---

## Pre-existing Route Entries (Manifest `routeEntries`)

Two Redguard MS08 entries already exist in the manifest with `reviewStatus:
"approved-static-route-only"`. They verify the static Papyrus branches and are ready for
source-fill declaration — they only lack `status: "approved-for-fill"` in
`sourceFillEntries`.

| id | property | formKey | approvedStage | routeKey | implementationStatus |
|---|---|---|---|---|---|
| `redguard-ms08-crown` | `PDV_FLST_P2_RedguardCrownSources` | `01CF25:Skyrim.esm` | 201 | `redguard_ms08_crown` | `route-verified-pending-source-fill` |
| `redguard-ms08-forebear` | `PDV_FLST_P2_RedguardForebearSources` | `01CF25:Skyrim.esm` | 200 | `redguard_ms08_forebear` | `route-verified-pending-source-fill` |

Stage semantics (per race-sheet lock and CK note): stage 200 = player helped Saadia
(Forebear / exile-protection positive); stage 201 = player delivered Saadia to Kematu /
Alik'r (Crown / Hammerfell-justice / ancestor-duty positive). Both are terminal,
mutualExclusionGroup `ms08-branch-outcome`.

---

## Per-FormList Candidates to Verify and Curate

All FormKey and stage values marked **[VERIFY via houseCARL]** — do NOT treat these as
confirmed; use `housecarl_read_record` on the QUST to confirm (a) the FormKey resolves in
the load order, (b) the named stage exists, and (c) the stage log entry matches the
expected terminal or milestone semantic. Record `stageReadbackEvidence` with a reference to
the readback path or inline note.

### PDV_FLST_P2_RedguardCrownSources — 2 candidates

**Source kind: `quest-stage` only** (manifest `sourceKinds: ["quest-stage"]`).

1. **MS08 — "In My Time of Need," stage 201** (Delivered Saadia to Kematu / Alik'r justice)
   - FormKey: `01CF25:Skyrim.esm` [already in routeEntries; VERIFY stage 201 terminal log]
   - routeKey: `redguard_ms08_crown` (already declared)
   - Accepted: Crown / Hammerfell-justice / ancestor-duty. The player chose the Alik'r.
   - Rejected: Stage 200 (opposite branch), generic proximity, intermediate stages.
   - duplicateGuard: `MarkP2SourceRoute` stores quest form + routeKey.
   - mutualExclusionGroup: `ms08-branch-outcome`
   - **Action:** Add this entry to `sourceFillEntries` with `status: "approved-for-fill"` and
     `stageReadbackEvidence` from houseCARL QUST readback.

2. **WE37 or equivalent unique Alik'r warrior defeat milestone** — if a named quest stage
   captures the player's honorable resolution of an Alik'r patrol encounter.
   - VERIFY: Search houseCARL for a QUST tied to the wandering Alik'r in Whiterun exterior
     (`WE37` / `WERoad11` family). If no terminal stage exists, exclude — do not use
     location-proximity alone.
   - Accepted only if: single terminal milestone at a meaningful cultural beat, not a
     generic combat event.

### PDV_FLST_P2_RedguardForebearSources — 3 candidates

**Source kind: `quest-stage` only** (manifest `sourceKinds: ["quest-stage"]`).

1. **MS08 — "In My Time of Need," stage 200** (Helped Saadia escape the Alik'r)
   - FormKey: `01CF25:Skyrim.esm` [already in routeEntries; VERIFY stage 200 terminal log]
   - routeKey: `redguard_ms08_forebear` (already declared)
   - Accepted: Forebear / exile-protection / anti-Alik'r sympathy. The player chose to
     protect the woman, not honor Hammerfell justice.
   - Rejected: Stage 201 (opposite branch), generic stages.
   - duplicateGuard: `MarkP2SourceRoute` stores quest form + routeKey.
   - mutualExclusionGroup: `ms08-branch-outcome`
   - **Action:** Add entry to `sourceFillEntries` with `status: "approved-for-fill"`.

2. **Companion contract / mercenary completion milestone** — a curated one-shot quest stage
   representing an honestly-completed Forebear-compatible contract or service:
   - Candidate A: `FavorAndolil` (Scouts-Many-Marshes pay-up) or equivalent named NPC
     favor completion at a Redguard-adjacent mercenary/contract quest. VERIFY FormKey via
     houseCARL; confirm the terminal stage maps to honest contract completion.
   - Candidate B: A Companions radiant-quest terminal stage (e.g., a unique-stage hire or
     named-contract completion that is Forebear-compatible and one-shot).
   - Accepted: Honest completion, contract fulfilled under pressure, no betrayal.
   - Rejected: Generic radiant completion loops. Only add if a non-repeating terminal
     stage can be isolated.

3. **Road-passage or civil-defense curated milestone** (optional, verify carefully):
   - A Forebear-appropriate escort or road-safety quest (e.g., a civilian escort that ends
     at a named stage) capturing "making-a-way" passage. VERIFY that the terminal stage is
     genuinely one-shot and not a radiant restart. If no safe candidate found, omit — do
     not pad to hit a count.

### PDV_FLST_P2_RedguardAshAbahSources — 4 candidates

**Source kind: `quest-stage` only** (manifest `sourceKinds: ["quest-stage"]`).

1. **DA11Intro — "Investigate the Hall of the Dead" (Markarth), stage 20** (Cleared the
   Hall of the Dead of supernatural presence / told Verulus it is safe)
   - Potential FormKey: `Skyrim.esm:07D949` [VERIFY via houseCARL — confirm stage 20 = "Tell
     Verulus the Hall of the Dead is safe"; stage 200 = alternative close; check which is
     the correct Ash'abah-duty terminal]
   - Accepted: Death-duty, Hall of the Dead, Arkay-adjacent burial service. The player
     cleaned a corrupted Hall. Strongest vanilla Ash'abah hook.
   - Rejected: Stage 10 (investigate only), DA11 main quest stages (Namira worship = wrong
     direction entirely — do NOT use DA11 `02C358` stage 100, that is cannibal completion).
   - Note: `DA11Intro` (`07D949`) is the favor quest; `DA11` (`02C358`) is Namira's quest —
     these are different records. Use only `DA11Intro` stage 20 for the burial-service
     reading. VERIFY the FormKey and stage semantics match exactly.
   - duplicateGuard: `MarkP2SourceRoute` stores quest form + routeKey (propose
     `redguard_da11intro_ashabah_duty`).
   - mutualExclusionGroup: `ashabah-hall-duty`

2. **Companions C03 / C06 — beast-blood entry or cure, stage 200** (as undead-adjacent
   death-duty witness rather than a celebration)
   - FormKey C03: `Skyrim.esm:01CEF4`; C06: `Skyrim.esm:01CEF6` [already in manifest
     routeEntries for Nord and Altmer; VERIFY that these read as one-shot stage 200 with
     the correct terminal log; confirm mutual-exclusion does not collide with Nord entries
     — different `property` fields, so no collision]
   - Accepted: The beast-blood moment is a death-threshold the Ash'abah interprets as an
     undead-adjacent burden crossing. Thematically fits the "impurity borne" lane.
   - Rejected: Generic Companions radiant quests, intermediate stages, cure-only if not also
     one-shot per-character.
   - Note: The race-sheet does not list this explicitly as a primary hook. Evaluate whether
     the "beast-blood = Ash'abah threshold" reading is strong enough or whether the slot
     is better reserved for a cleaner death-duty source. Include only if houseCARL confirms
     stage 200 is genuinely terminal and one-shot.

3. **A major necromancer operation completion stage** — a named necromancer questline with a
   terminal stage that represents an Ash'abah-appropriate operation clear:
   - Candidate: Any Radiant quest or named quest that ends a necromancer/summoner operation
     (e.g., a College of Winterhold quest stage that terminates a necromancy investigation,
     or a named Conjuration-lore quest). VERIFY via houseCARL that the terminal stage is
     one-shot and not part of a repeatable radiant.
   - Accepted: Major necromancer operation completion (the player took on what others
     wouldn't). Named operation, not a generic undead dungeon clear.
   - Rejected: Any stage from a repeatable quest, generic kill-count stages, or loot stages.

4. **MS08 stage 201 mirror for Ash'abah** — if the player chose to deliver Saadia (the
   dead-rites / Hammerfell-justice reading), consider whether this also carries an
   Ash'abah ancestor-duty credit:
   - **DESIGN DECISION NEEDED:** The race-sheet marks MS08 201 as Crown-positive. Routing
     the same quest+stage to both Crown AND Ash'abah FormLists would mean a single act
     awards both, which may be intentional (ancestor-duty is always-active across all sects)
     or may over-reward. Raise with the user before adding. Do NOT add without explicit
     approval; the formKey uniqueness check in the tool applies per property, so the same
     form/stage CAN appear in both FormLists if curation approves it.

---

## Gated-Fill Block (Clone from Template)

When each candidate is verified and approved, add an entry to `sourceFillEntries` in
`PDV_Phase20_P2ImmersiveReceivers.manifest.json` with ALL of the following fields populated
(tool will reject any entry missing a field):

```json
{
  "property": "PDV_FLST_P2_RedguardCrownSources",  // or Forebear / AshAbah
  "sources": [
    {
      "formKey": "XXXXXX:Skyrim.esm",               // DO NOT invent — houseCARL readback only
      "editorId": "QuestEditorId",
      "sourceKind": "quest-stage",                  // only "quest-stage" for these FormLists
      "status": "approved-for-fill",
      "approvedStages": [NNN],                       // exact stage only; array
      "stageReadbackEvidence": "houseCARL readback of QUST XXXXXX confirmed stage NNN = '<log text>'",
      "rejectedStageContext": "<what stages/contexts are explicitly excluded>",
      "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey <routeKey>.",
      "rationale": "<one-sentence accepted-use rationale>",
      "routeKey": "<redguard_xx_routekey>"           // must match routeEntries.id or be newly declared
    }
  ]
}
```

Notes:
- `questStageGate.receiverStatus` is already `"exact-stage-supported"` (manifest top-level) — this satisfies the validator prerequisite.
- `formKeyFormat` is `localHex:ModName.ext` (e.g., `01CF25:Skyrim.esm`).
- The fill tool enforces `status == "approved-for-fill"` and the `approvedStages` array
  MUST be present for quest-stage sourceKind entries.
- MS08 entries must also reference the existing `routeEntries` routeKey so the
  `--check-route-entries` pass can correlate them.

---

## Acceptance

Run all five check modes after filling:

```
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\... -- --check-formlists
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\... -- --check-alias-properties
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\... -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\... -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\... -- --check-exact-stage-gates
```

All five must PASS before any ESP write (`--fill-source-entries`).

**E2E gate (post-fill, in-game):** Complete MS08 (one branch per character), confirm
`PDV_EventBus.psc` trace fires `RouteRedguardSectSignal complete` with the correct sectId
in Papyrus.0.log. Confirm piety tick on the expected Tu'whacca or sect-substrate channel.
Do not use `cqf` — wire verification MCM button if needed (project memory:
`debug-testing-is-mcm-driven-not-cqf`).

---

## Manifest Diff Summary (What Codex Must Add)

Minimum viable fill to unblock Forebear and Ash'abah (Crown has MS08 too):

| FormList | Minimum entries | Key actions |
|---|---|---|
| Crown | 1 (MS08 stage 201) | Add `sourceFillEntries` entry; promote `redguard-ms08-crown` routeEntry to `approved-for-fill` |
| Forebear | 1 (MS08 stage 200) + 1–2 optional | Add `sourceFillEntries` entry; promote `redguard-ms08-forebear` routeEntry; optionally add curated contract stage |
| Ash'abah | 1–2 (DA11Intro stage 20 + optional necromancer op) | DA11Intro FormKey must be verified; no routeEntry pre-exists so a new entry is needed in `routeEntries` before `sourceFillEntries` can reference it |

---

## Hand-Back

Return:
1. Updated `PDV_Phase20_P2ImmersiveReceivers.manifest.json` with `sourceFillEntries` added
   for all approved candidates.
2. A backed-up `Devotion.esp` after `--fill-source-entries` write.
3. A per-FormList status table: wired? populated? right quests? in-game-proven?
4. Any candidate that failed houseCARL stage verification should be recorded in a
   `rejectedCandidates` note at the bottom of this file (or inline in the manifest as
   `status: "rejected-stage-unverified"`).
