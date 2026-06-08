# PDV Quest-Reaction Matrix — Wiring Spec (Codex handoff)

**Created:** 2026-06-08 · **Author of design:** Claude · **Implementer:** Codex
**Status:** Design FROZEN. This spec is the implementation contract — build against
it; do not re-derive the matrix or the theology.

---

## 0. What this is

The quest-reaction matrix and thin-god faucets are authored and frozen. This spec
tells Codex how to wire them into the live mod. The judgment work (which god reacts,
valence, intensity, magnitude) is DONE and must not be re-litigated — it is data now.

**Frozen input artifacts (source of truth, do not edit for wiring):**
- `references/authoring/PDV_QuestReactionMatrix_Full.csv` — 317 cells, 71 quests, 39
  deities (Daedric + questlines + temple/favor). Schema:
  `editor_id,quest_name,outcome_stage,outcome,act_tags,deity,valence,intensity,magnitude,citation`
- `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` — 15
  repeatable faucet acts. Schema:
  `deity,act,trigger_detection,act_tag,valence,intensity,magnitude,anti_farm_cap,buildability,notes`
- `references/authoring/PDV_QuestReactionMatrix.md` — Part A (tag vocab), Part B
  (deity value-profiles), **Part C2 (race-stance modulation — the rules #3 implements)**.
- `references/phase4/PDV_StanceMatrix.csv` + `PDV_DaedricRacePrinceMatrix.csv` — the
  per-race NATIVE/FOREIGN/TABOO/HOSTILE/CURSE stance data #3 consumes.

**Proven mechanism this extends:** `PDV_PlayerEvents` already detects quest stages via
PO3 Papyrus Extender (`PO3_Events_Alias.RegisterForQuestStage` →
`OnQuestStageChange(Quest, Int)` → `RouteP2ImmersiveQuestStage` →
`ShouldRouteP2QuestStage(expectedFormId, approvedStage)`). The Altmer MQ104-s160 P2
fill runs through this today. **Wiring the matrix = scaling this receiver, not building
a new one.**

---

## 1. PINNED DECISION — data representation = JSON-config (NOT FormList-baked)

Confirmed by user 2026-06-08. The matrix and faucets are loaded at runtime from JSON
(PapyrusUtil `JsonUtil` or JContainers — implementer's choice; PDV already depends on
PapyrusUtil/StorageUtil). Rationale: scales to 317 cells without FormList sprawl;
keeps the CSVs as source of truth; and **milestone/small numeric VALUES live in the
JSON value-table — the single "tune-later" lever** (per memory `piety-pacing-model`
and `quest-reaction-matrix-calibration`: counts frozen, value tuned here).

REJECTED: ESP-FormList-baked (matches existing P2 style but bloats the ESP and makes
the per-cell tuning painful).

NOTE: detection still uses a watch-FormList of the 71 Quest forms (that is the
registration surface, not the cell store). Only the cell DATA moves to JSON.

---

## 2. Workstream 1 — data pipeline (NEW tool)

Build `tools/pdv_quest_matrix_compile.mjs` (read-only over the CSVs; emits JSON):

- Resolve each `editor_id` → base Quest FormID (`XXXXXX:Master.esp`) via houseCARL
  readback (note USSEP overrides keep the base Skyrim.esm formid). Emit a mapping so
  the runtime keys by formid, not editorid.
- Emit JSON shape:
```json
{
  "values": { "milestone": {"C":18,"S":12,"m":8}, "small": {"C":6,"S":4,"m":2} },
  "stance":  { "NATIVE":1.0, "FOREIGN":0.4, "TOLERATED":0.4,
               "TABOO":"stigma", "HOSTILE":"stigma", "CURSE":"curse" },
  "questCells": {
    "01EA50|200": [ {"deity":"Sithis","v":"+","i":"S","m":"small"}, ... ]
  },
  "faucetActs": {
    "Namira.cannibalism": {"deity":"Namira","v":"+","i":"C","m":"small","cap":"1/dawn"}
  }
}
```
- `values` and `stance` numbers above are **ILLUSTRATIVE, NOT LOCKED** — they are the
  tuning surface. Initial values must respect: a single milestone ≤ ~one tier-step
  (tiers 25/50/85), a loss stings but is recoverable (Part C1).
- Ship the JSON under the Devotion mod (e.g. `SKSE/Plugins/StorageUtilData/` or the
  PDV config path the manager already reads).

---

## 3. Workstream 2 — quest-reaction receiver (EXTEND proven path)

- Author a watch-FormList `PDV_FLST_QuestReaction_Watch` containing all 71 matrix
  Quest forms. Register it through the existing `RegisterQuestStageList` pattern in
  `PDV_PlayerEvents` (additive — leave the P2 route FormLists intact).
- In `OnQuestStageChange(Quest akQuest, Int aiNewStage)`, after the existing P2 route
  check, call a new manager entry: `PDV__ManagerQuest.ApplyQuestReaction(akQuest,
  aiNewStage)`.
- `ApplyQuestReaction`: build key `formidHex|stage`, look up `questCells[key]`; if
  present, for each cell call the stance-award function (#4). No-op if absent
  (most stages are silent — correct).
- Multi-branch quests already have one cell-set per terminal/branch stage in the CSV;
  keying by `formid|stage` handles branches for free.

---

## 4. Workstream 3 — stance-modulation + award (NEW, fully specified by Part C2)

Implement in `PDV__ManagerQuest` (piety lives in StorageUtil per-deity + mirror
globals for CK Condition reads — keep that contract):

```
Function ApplyDeityReaction(String deity, String valence, String intensity, \
                            String magnitude, String sourceTag, Bool isFaucet)
  Float base = values[magnitude][intensity]
  String stance = StanceFor(PlayerRace, deity)          ; from stance JSON
  ; --- Part C2 rules ---
  ; NATIVE / FOREIGN(=TOLERATED): apply (base * mult) with the cell's valence
  ; TABOO / HOSTILE: an APPROVING (+) act becomes a stigma PENALTY (negative),
  ;                  a DISAPPROVING (-) act is neutral or mild relief (≈0)
  ; CURSE (Hircine=lycanthropy, MolagBal=vampirism): do NOT touch piety — route to
  ;                  the existing curse layer (PDV_CurseState)
  ; faucet acts: enforce anti-farm cap (1/dawn day-stamp; 1/ever; 1/book) BEFORE award
```

- Stance lookup: bake `PDV_StanceMatrix.csv` (Aedra/race) + `PDV_DaedricRacePrinceMatrix.csv`
  (Princes/race) into the JSON (`stanceByRace[deity][race] = "NATIVE"...`). Princes
  that are also race-NATIVE (Azura/Boethiah/Mephala for Dunmer/Khajiit; Malacath for
  Orc) resolve via the race-Aedra row first.
- Quest one-shots are NOT anti-farm-gated (Part C1: one-shot by nature). Faucets ARE
  (reuse the day-stamp guard pattern from the parked Dunmer prayer cap fix).
- Award goes through the manager's existing per-deity piety pulse so dawn
  consolidation / tiers / Survey all keep working.

---

## 5. Workstream 4 — faucet hooks + records

15 acts in the faucets CSV. Detection mostly reuses PO3-events-on-alias already in
`PDV_PlayerEvents`:

| Hook | Mechanism | Records to author |
|---|---|---|
| Namira corpse-feed | Ring of Namira "Feed" MGEF (PO3 `RegisterForMagicEffectApply`) | — (vanilla MGEF) |
| Namira eat flesh | `OnObjectEquipped` ∈ FormList | `PDV_FLST_Faucet_HumanFlesh` |
| Sanguine drink | `OnObjectEquipped` ∈ FormList | `PDV_FLST_Faucet_Alcohol` (curated ALCH) |
| Sanguine Rose / Vaermina Skull | `OnSpellCast`/staff fire (PO3) | — (vanilla staves) |
| Peryite disease | poll in `OnUpdate` (HasMagicEffect disease) | — |
| Peryite Spellbreaker / Clavicus Masque | `OnObjectEquipped` (specific item) | — |
| Mora Black Book | `OnBookRead` ∈ FormList | `PDV_FLST_Faucet_BlackBooks` (coordinate owner vs BookRead) |
| Mora rare tomes | `OnBookRead` ∈ FormList | `PDV_FLST_Faucet_RareLore` |
| Dibella alms | "The Gift of Charity" MGEF (PO3 `RegisterForMagicEffectApply`) | — (vanilla MGEF) |
| Dibella adornment | `OnObjectEquipped` ∈ FormList | `PDV_FLST_Faucet_FineApparel` |
| Dibella marry | `PlayerMarried` event | — |

All faucet pulses route through `ApplyDeityReaction(..., isFaucet=true)` with the cap.

**DEFERRED (do not block on these):** Clavicus "win a favorable bargain" (curated
quest persuade-success dialogue fragments — hand-authored per-quest, no generic
event); Dibella "perform music/create art" (no vanilla repeatable — reserved for
modded content + the future custom-content-flagging pass). Masque-wear / adornment
cover those two gods meanwhile.

---

## 6. Verification gates (per pdv-proof-boundary)

1. `node tools/pdv_compile.mjs` — 0 error / 0 warning.
2. `node tools/pdv_verify.mjs` — FAIL=0 (records, FLST membership, SGE/SEQ, manager
   property wiring for the new receiver + faucet FormLists).
3. JSON load self-test: manager logs cell-count + faucet-count on init.
4. QASmoke route proof: fire a representative quest-stage per family
   (e.g. MQ104 s160 Shor+, DA11 s100 Namira+/Stendarr−, TG09 Nocturnal+) and confirm
   the right per-deity stance-modulated pulse in `Logs\Script\Papyrus.0.log`.
5. Faucet smoke: one act per god (drink → Sanguine; equip Masque → Clavicus; give
   beggar gold → Dibella; read Black Book → Mora) with the 1/dawn cap proven
   (second same-day fire = no increase).
6. Negative check: a stance-TABOO approving act yields stigma, not gain (e.g. Orc
   pleasing Boethiah).

---

## 7. Coordination flags (carry into AGENTS.md)

- **Race-stance modulation is applied at WIRING/runtime ONLY** (Part C2) — the matrix
  cells are universal; never bake stance into the cells.
- **Black Book owner:** pick BookRead OR the Mora faucet, not both (exclusion audit).
- **Tune-later lever** = the JSON `values`/`stance` tables; counts are frozen (memory
  `quest-reaction-matrix-calibration`).
- **Parked engine fixes** (auto-dawn + Dunmer prayer cap) must be in-game-proven
  before/with this — the faucet caps reuse that day-stamp pattern.
- **Possible small follow-up:** Y'ffre/Z'en/Khenarthi have deity scripts but no matrix
  cells yet (e.g. Blessings-of-Nature peaceful branch → Y'ffre `honor_the_wild`).
  Optional coverage, non-blocking.
