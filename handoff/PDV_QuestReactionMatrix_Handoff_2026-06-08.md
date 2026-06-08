# PDV Quest-Reaction Matrix — Session Handoff (2026-06-08)

> **SUPERSEDED 2026-06-08** — this handoff was consumed. The matrix is now merged
> (`PDV_QuestReactionMatrix_Full.csv`, 317 cells), the calibration is LOCKED
> (leave-as-is; tune value later), the temple/favor sweep + Part D faucets are
> authored, and the wiring is specced in `references/authoring/PDV_QuestReactionMatrix_WiringSpec.md`.
> See AGENTS.md Decisions Log (2026-06-08) for the authoritative state.
> **Correction:** §1 here mislabels `t02`/`0211D5` as "The Heart of Dibella" — it is
> actually *The Book of Love* (Mara); Heart of Dibella is `T01`/`023B6C`. Kept below
> for history only; do not act on its open decision points.

Self-contained handoff for a fresh session. The active work is the **quest-reaction
matrix**; two foundational engine fixes are compiled and parked for in-game testing.

---

## 0. WHERE WE ARE RIGHT NOW (the live decision point)

We just finished drafting the full quest-reaction matrix (~300 cells, all 32
deities) and are at a **calibration decision** on tranche-2:

- Apply a deterministic calibration to `PDV_QuestReactionMatrix_Tranche2.csv`:
  **(a) cap milestones to <=1-2 per quest** (keep the most-thematic; demote the rest
  to `small`); **(b) keep the broad-martial fan-out but at `small`** for secondary
  war-gods (race-stance modulation filters the rest per player).
- Then **merge tranche-1 + tranche-2 -> full matrix**, user review, then wire.

The user asked for this handoff before deciding. NEXT SESSION: confirm the
calibration rule with the user, apply it, merge, present for review.

---

## 1. THE QUEST-REACTION MATRIX (active work)

**Concept (locked):** vanilla/DLC quest *choices* grant piety GAIN/LOSS to a race's
deities + the 16 Daedric Princes, based on whether each god approves/disapproves of
the choice. Small reactions + milestone reactions. One choice fans across many gods
(e.g. a sacrifice: Boethiah +, Stendarr/Mara/Arkay -, Mephala +, Orc->Boethiah
stigma). It is a one-time curated table the wiring consumes — NOT a runtime system.

**How a cell is decided:** tag the quest outcome with **act-tags** (read from the
journal text) -> match each deity's **values profile** (approve/disapprove tag sets)
-> emit valence + magnitude. Universal profile is then modulated by **race-stance**
(NATIVE/FOREIGN/TABOO from the EXISTING `references/phase4/PDV_StanceMatrix.csv` +
`PDV_DaedricRacePrinceMatrix.csv`) at WIRING time.

### Artifacts (all checked in)
- **`references/authoring/PDV_QuestReactionMatrix.md`** — THE foundation doc:
  - Part A: locked act-tag vocabulary (~45 moral primitives).
  - Part B/B-2: values profiles for all ~30 deities + 16 Princes (approve/disapprove
    + intensity C/S/m + lore anchors).
  - Part C: magnitude rules + **race-stance modulation** (the matrix dimension).
  - Part D / D-2: thin-god supplement + **cited proof-of-concept** for the 6 thin
    gods (Namira/Dibella/Sanguine/Peryite/Vaermina/Clavicus).
  - Part E: the validated **read-and-judge procedure + output schema + build order**.
- **`PDV_QuestReactionMatrix_Tranche1.csv`** — 16 Princes + Nocturnal, ~57 cells,
  branching gain/loss, **user-reviewed** (Clavicus good both ways; Mara+/Stendarr-
  on sparing Barbas; Dibella -trash/+clean).
- **`PDV_QuestReactionMatrix_Tranche2.csv`** — 246 cells, 47 quests, 32 deities
  (Companions/CivilWar/DarkBrotherhood/College/MainQuest/ThievesGuild). **Needs the
  calibration above.** Distribution: Talos +23, Shor +18, Mephala +17, Boethiah +15,
  Tsun +13, Sithis +10, ...; conscience gods take losses (Stendarr +6/-10, Mara
  +1/-6, Zenithar -6).

### Helper tools (this session)
- `tools/pdv_quest_reaction_pilot.mjs` — keyword detector; KEEP as a **regression/
  disagreement net** (not source of truth). Run prints live coverage counts.
- `tools/pdv_quest_dump.mjs` — dumps Daedric/Temple journal data.
- `tools/pdv_quest_remaining_dump.mjs` — wrote `references/vanilla-gameplay/extracted/
  quest_journal_remaining.md` (the workflow input).
- `tools/pdv_quest_tranche2_assemble.mjs <workflow_output_file>` — transforms the
  workflow JSON result -> Tranche2 CSV + distribution/over-fire analysis. (Workflow
  result is `{summary,logs,result:{cellCount,rows}}`; rows at `result.rows`;
  editor_ids needed `-suffix` normalization for DB/TG batches.)

### Data foundation (locked)
- Candidate universe = `references/vanilla-gameplay/extracted/vanilla-quest-stage-
  readback.csv` (763 rows; ~125 real named quests after collapsing sub-records;
  its `stage_log_summary` ALREADY carries branch-resolved journal text — the primary
  read-and-judge source). houseCARL = record/editorId confirmation only. UESP via
  **WebSearch** (WebFetch is 403-blocked).
- Curation/exclusion + approval ledgers: `PDV_Phase20_SourceCurationDossier.md`,
  `PDV_Phase20_QuestStageExclusionAudit.md`, `PDV_Phase20_SourceFillApprovalLedger.json`.

### Remaining matrix work (after calibration)
1. **Temple/Favor sweep for narrow Aedra** — these quests are EXCLUDED from the
   candidate CSV (Dibella's own quest "The Heart of Dibella" = `t02`/`0211D5` is not
   in it). Must pull Temple/Favor quests in for Dibella/Mara/Zenithar/Kynareth.
2. **Thin-god Part D acts** — artifact/perk/repeatable faucets (Ring of Namira feed,
   Sanguine drink, etc.) not yet authored.
3. **Wire the frozen matrix into Papyrus/ESP** — the entire downstream (a quest-stage
   reaction receiver consuming the table + race-stance modulation). NOT STARTED.
4. Optionally re-run the Opus workflow for any remaining single-outcome quests not in
   tranche-1/2.

---

## 2. LOCKED DECISIONS (this session)
- Quest hooks = reactive approval/disapproval piety (gain/loss, small->milestone),
  per the values-profile × race-stance model. NOT the daily faucet; NOT hard gates.
- Vanilla + DLC only (mod quests -> optional patches later).
- Act-tag vocabulary is the bridge; read-and-judge from CSV journal text.
- Model: **Opus 4.8 / high reasoning** for all judgment work (do NOT downgrade).
- Narrow gods: keep quest-tagging tight; widen via Part D + read-and-judge + a future
  custom-content-flagging pass (later release); target >=12 reactions each.
- Pacing (memory): 4.3/day cap, 85 Champion, ~30-45 days normal / ~20 dedicated;
  do NOT inflate so normal play caps daily.
- Anti-farm (memory): every signal needs a cap on the PIETY pulse; ritual acts =
  once per dawn cycle.

---

## 3. PARKED: two foundational engine fixes (compiled + verified, AWAIT in-game test)

Both are script-only edits to `PDV__ManagerQuest.psc`, **compiled 0 error/0 warning,
`pdv_verify` FAIL=0 PASS=2837**. They take effect on the EXISTING save after reload.

1. **Auto daily ProcessDawn** (`OnUpdate`, ~:500): detects in-game day rollover
   (`Utility.GetCurrentGameTime() as Int` vs StorageUtil `PDV.DawnAuto.LastDay`,
   lazy-baselined via `PDV.DawnAuto.Init`) and calls `ProcessDawn()` once/day.
   **THE root-cause fix** — ProcessDawn had NO auto trigger (only the MCM debug
   button), so piety NEVER consolidated in normal play for ANY race. (See memory
   `processdawn-no-auto-trigger.md` — UPDATE it once runtime-confirmed.)
2. **Dunmer prayer once-per-dawn cap** (`AwardActiveDunmerReclamationMemorySignal`,
   ~:6613): day-stamp guard on `PDV.Signal.DunmerAncestorMemory.Day` so the
   ancestor-memory pulse banks at most once/day (was stacking 0.5->1.0->1.5).

**IN-GAME TEST (deferred by user):** reload -> as Dunmer w/ Boethiah active patron
(MCM debug), fire ancestor prayer once (Boethiah PietyToday +0.5), fire again same
day (no increase = cap works), then **plain Wait past midnight** (no debug button) ->
Boethiah `Piety` banks ~0.66 and `PietyToday` resets (= auto-dawn works). Log at
debug 2 shows `[PDV] Auto-dawn: day rollover to <day>`.

Cosmetic: an earlier idempotent `pdv-phase20-race-author --author-rewards` Imperial
run (a NO-OP — the 32-deity roster was already authored) left a `SEQ older than ESP`
WARN. Harmless; refresh SEQ or restore the `Backups/phase20-race-rewards/*.bak` if
desired.

---

## 4. CRITICAL LESSONS / OPERATIONAL KNOWLEDGE
- **DO NOT trust exploration/audit subagents on COUNTS or inventory.** This session
  they were wrong repeatedly: claimed only 6 deities in `PDV_FLST_AllDeities` (it has
  **32**, verified); claimed Dunmer prayer was "substrate-only no piety" (the pulse
  exists, gated on active patron). **Verify against `pdv_verify`, houseCARL, the live
  source, or a deterministic script — never agent inventories.**
- `PDV_FLST_AllDeities` already has all 32 deities, wired to manager/MCM/ActionRouter/
  EventBus; dawn consolidation (`RunDawnConsolidateScratch` :3103) iterates it.
- houseCARL is currently restored to **Anvil (Devotion Dev)**. For ESP WRITES: park
  it on `D:\Wabbajack\modlists\DoD` + `housecarl_load_order_status`, verify ESP free,
  write, then restore to Anvil (per `compat-reference-instances` memory).
- The keyword pilot is a recall PROXY/regression net; read-and-judge (journal text)
  is the source of truth.

## 5. MEMORIES SAVED THIS SESSION
`piety-pacing-model.md`, `anti-farm-cap-requirement.md`,
`processdawn-no-auto-trigger.md` (+ existing index in MEMORY.md).

## 6. BROADER CONTEXT (paused)
The session opened with a big beta-readiness faucet plan (per-race lore faucets,
Prince patron commitment, #16 power-slot bug, startup copy, capitalization,
selectability). That is PAUSED in favor of the quest-reaction matrix. Full plan:
`C:\Users\Admin\.claude\plans\time-to-kick-off-sparkling-goblet.md` (contains the
verified state, the per-race grounded hook inventories, and the corrected findings).
The #16 power-slot bug still needs the exact "ancestor power" record identified
in-game (`help "ancestor"`).

## 7. IMMEDIATE NEXT ACTIONS (next session)
1. Confirm + apply the tranche-2 calibration (cap milestones; demote broad fan-out).
2. Merge tranche-1 + tranche-2 -> full matrix; present per-deity distribution; user review.
3. Temple/Favor sweep for narrow Aedra (Dibella t02 etc.).
4. (Then) design the Papyrus/ESP wiring that consumes the frozen matrix + race-stance.
5. (Whenever in-game) run the parked engine-fix test (section 3).
