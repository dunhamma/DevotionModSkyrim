# PDV Quest-Reaction Matrix — Codex Wiring Handoff (2026-06-08)

Self-contained handoff for a fresh **Codex** session. The quest-reaction matrix is
**designed, authored, and frozen as checked-in data** (by Claude). Your job is the
**implementation**: wire it into Papyrus/ESP. The judgment work (which god reacts,
valence, intensity, magnitude) is DONE — treat the CSVs as law, do not re-author them.

---

## 0. THE TASK (one line)

Implement the quest-reaction matrix + thin-god faucets into the live Devotion mod,
following the frozen contract in **`references/authoring/PDV_QuestReactionMatrix_WiringSpec.md`**.
That spec is authoritative for architecture; this handoff is orientation + guardrails.

---

## 1. WHERE WE ARE

- **Matrix content-complete & frozen.** `PDV_QuestReactionMatrix_Full.csv` = **317
  cells / 71 quests / 39 deities** (Tranche1 Daedric+Nocturnal, Tranche2 questlines,
  Tranche3 temple/favor). Full.csv is GENERATED — edit a tranche then re-run
  `tools/pdv_quest_tranche_merge.mjs`; never hand-edit Full.csv.
- **Part D faucets authored.** `PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` = 15
  repeatable daily-faucet acts for the thin gods.
- **Wiring NOT started.** No source/ESP changes have been made for wiring yet. This
  handoff is the start of that work.

---

## 2. FROZEN INPUT ARTIFACTS (source of truth — read, don't rewrite)

| File | Role |
|---|---|
| `references/authoring/PDV_QuestReactionMatrix_WiringSpec.md` | **THE implementation contract** (read first) |
| `references/authoring/PDV_QuestReactionMatrix.md` | Foundation: Part A tag vocab, Part B deity profiles, **Part C2 stance rules you implement**, Part D/D-3 faucets, Part E method |
| `references/authoring/PDV_QuestReactionMatrix_Full.csv` | 317 cells (GENERATED) |
| `references/authoring/PDV_QuestReactionMatrix_Tranche{1,2,3_TempleFavor}.csv` | Source tranches behind Full.csv |
| `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` | 15 faucet acts |
| `references/phase4/PDV_StanceMatrix.csv` + `PDV_DaedricRacePrinceMatrix.csv` | Per-race NATIVE/FOREIGN/TABOO/HOSTILE/CURSE data the stance-award consumes |
| `tools/pdv_quest_tranche_merge.mjs` | Regenerates Full.csv from tranches |

---

## 3. THE FIVE WORKSTREAMS (summary — detail in the WiringSpec)

1. **Data pipeline (new tool):** `tools/pdv_quest_matrix_compile.mjs` — CSVs ->
   runtime JSON keyed `formidHex|stage -> [cells]` and `faucet_act -> cell`, plus a
   `values` table (milestone/small x C/S/m) and a `stance` multiplier table. Resolve
   `editor_id -> base FormID` via houseCARL.
2. **Quest-reaction receiver (extend proven):** add the 71 quests to a watch-FormList,
   register via the existing `RegisterForQuestStage` path, and in `OnQuestStageChange`
   call a new `PDV__ManagerQuest.ApplyQuestReaction(quest, stage)`.
3. **Stance-modulation + award (new):** `PDV__ManagerQuest.ApplyDeityReaction(...)` —
   Part C2: NATIVE full / FOREIGN dampened / TABOO->stigma / CURSE->curse-layer, x
   intensity x magnitude VALUE. Quest one-shots uncapped; faucets 1/dawn.
4. **Faucet hooks + records:** ~10 hooks (reuse `OnBookRead`/`OnObjectEquipped`/
   `OnSpellCast`/`RegisterForMagicEffectApply`/disease-poll) + 4 curated FormLists
   (alcohol, human flesh, fine apparel, Black Books). Deferred: Clavicus quest-persuade
   fragments, Dibella perform/art.
5. **Verification:** see §6.

---

## 4. LOCKED DECISIONS — DO NOT relitigate

- **Calibration:** milestone COUNTS are frozen. Do NOT cap milestones per quest. Pacing
  is tuned via milestone VALUE in the JSON `values` table (the one tuning lever),
  because piety is per-god so the cross-god fan-out never over-feeds one god. (Memory:
  `quest-reaction-matrix-calibration`.)
- **Data representation = JSON-config** (PapyrusUtil/JContainers), NOT ESP-FormList-baked.
  Only the watch-FormList of 71 quests lives in the ESP.
- **Race-stance modulation is applied at WIRING/runtime ONLY** (Part C2). Matrix cells
  are universal — never bake stance into them.
- **Anti-farm:** quest one-shots are not gated; faucets cap 1/dawn (reuse the day-stamp
  guard pattern — see the parked engine fix). Memory: `anti-farm-cap-requirement`.
- **Black Book owner:** pick the Mora faucet OR a BookRead receiver, not both.
- **Pacing budget:** a single milestone <= ~one tier-step (tiers 25/50/85); a loss
  stings but recovers. Memory: `piety-pacing-model`.

---

## 5. PROVEN MECHANISM TO REUSE (do not reinvent)

- **Quest-stage detection is already live.** `PDV_PlayerEvents` (alias on
  `PDV__ManagerQuest`) uses PO3 Papyrus Extender: `PO3_Events_Alias.RegisterForQuestStage`
  -> `OnQuestStageChange(Quest, Int)` -> `RouteP2ImmersiveQuestStage` ->
  `ShouldRouteP2QuestStage(expectedFormId, approvedStage)`. The Altmer MQ104-s160 P2
  fill runs through this today. Add the matrix receiver alongside the P2 routes
  (additive; leave P2 intact).
- **Piety pulse** goes through the manager's existing per-deity award so dawn
  consolidation, tiers, decay, and Survey keep working. Per-deity piety lives in
  **StorageUtil keyed by deity form**; mirror globals exist only for CK Condition reads.
- **Faucet detection** reuses the existing alias events (`OnBookRead`,
  `OnObjectEquipped`) + PO3 `RegisterForMagicEffectApply` for the Gift-of-Charity and
  Ring-of-Namira MGEFs.
- **All 39 deities already have scripts** under `Scripts\Source\PDV_Deity_*.psc` (incl.
  Yffre/Zen/Khenarthi) and are members of `PDV_FLST_AllDeities` (32 wired). No new deity
  records are needed for this wiring.

---

## 6. TOOLCHAIN & VERIFICATION GATES (per pdv-proof-boundary)

- Source: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\*.psc`. Compile via
  `node tools/pdv_compile.mjs` (NOT the generic MO2 compile). Verify via
  `node tools/pdv_verify.mjs`.
- ESP records: author with the existing `tools/pdv_author.mjs` / phase-author helpers.
  **For ESP WRITES, park houseCARL off Anvil** per memory `compat-reference-instances`:
  point it at `D:\Wabbajack\modlists\DoD`, confirm `PlayerDevotion_Framework.esp` is
  free (Skyrim/CK closed), write, then **restore houseCARL to Anvil (Devotion Dev)**.
  Reads are fine on Anvil.
- Gates: (1) compile 0/0; (2) `pdv_verify` FAIL=0; (3) JSON load self-test (manager logs
  cell+faucet counts on init); (4) QASmoke route proof per quest family (e.g. MQ104 s160
  Shor+, DA11 s100 Namira+/Stendarr-, TG09 Nocturnal+); (5) faucet smoke with 1/dawn cap
  proven; (6) negative check: TABOO approving act -> stigma not gain. Log path:
  `Logs\Script\Papyrus.0.log`.

---

## 7. CRITICAL LESSONS / GUARDRAILS

- **Verify against `pdv_verify` / houseCARL / live source — never trust agent
  inventories on counts** (this bit the prior session repeatedly).
- **Handoff correction:** `t02`/`0211D5` = **The Book of Love (Mara)**, NOT "The Heart
  of Dibella" (that is `T01`/`023B6C`). The matrix already uses the correct IDs.
- **ASCII-safe player text only** (Skyrim ActorValue names; no smart quotes/em-dashes) —
  the repo already carries mojibake scars in some docs; do not add more to source.
- If you create any new `QUST` (you likely will not — wiring adds FormLists/MGEF/scripts,
  not deity quests), it needs the SGE flag + SEQ entry (memory
  `deity-quest-sge-seq-requirement`).
- Per CLAUDE.md rule 4: do not edit `pdv_verify.mjs` expectations without explicit
  approval; if new FormLists/records trip strict verify as "unexpected," surface it.

---

## 8. PARKED / COORDINATE

- **Two compiled engine fixes await in-game test** (auto daily ProcessDawn in `OnUpdate`;
  Dunmer prayer once-per-dawn cap). The faucet 1/dawn caps reuse that SAME day-stamp
  pattern — align with it. Memory: `processdawn-no-auto-trigger`.
- **Deferred triggers** (no clean vanilla hook): Clavicus "win a favorable bargain"
  (hand-authored quest persuade-success fragments), Dibella "perform music/create art".
  Masque-wear / adornment cover those gods meanwhile.
- **Optional follow-up:** Y'ffre/Z'en/Khenarthi have deity scripts but no matrix cells
  yet (e.g. Blessings-of-Nature peaceful branch -> Y'ffre `honor_the_wild`). Non-blocking.

---

## 9. IMMEDIATE NEXT ACTIONS (Codex)

1. Read `PDV_QuestReactionMatrix_WiringSpec.md` end to end.
2. Build `tools/pdv_quest_matrix_compile.mjs` (CSVs -> JSON; resolve editor_id->formid
   via houseCARL); land the JSON under the Devotion config path the manager reads.
3. Wire workstream 2 (watch-FormList + receiver) and 3 (`ApplyDeityReaction` + stance),
   compile 0/0, `pdv_verify` FAIL=0.
4. Wire the faucet hooks + 4 FormLists (workstream 4).
5. Run the verification gates (§6); record route + faucet-cap proof.
6. On completion, run `pdv-doc-sync` and update AGENTS.md Decisions Log + the v3 §5.8
   status from "wiring pending" to its proven state.

Full prior context: AGENTS.md Decisions Log (2026-06-08); `PDV_Architecture_v3.md` §5.8.
