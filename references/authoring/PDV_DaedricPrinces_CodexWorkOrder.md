# PDV Daedric Princes — Codex Work Order

**Created:** 2026-06-07
**For:** Codex, running in parallel with Claude's Prisma reconcile.
**Goal:** Bring all 16 Skyrim-present Daedric Princes to **D-18 content-ready**
(authored records + readback), so the only remaining gap is manual runtime/display
proof. This is the static/authoring half of the Daedric beta bar.

> **Source-of-truth rule:** derive every exact EditorID and every line of prose from
> the canonical manifest, **not** from this work order. This document gives the
> contract, the precedent, the order, and the gates — the manifest gives the content.

## Authority documents (read first)

- `race-sheets/PDV_DaedricContent_Manifest.md` — per-Prince rows. **Section 6
  (Boethiah) is the full authored pilot**; copy its row structure. Section 7.x holds
  each Prince (Mephala 7.2, etc.). Section 5 = locked stigma band model.
- `references/phase4/PDV_DaedricRacePrinceMatrix.csv` — the `DaedricMatrix` cited in
  every row; supplies per-race state, stigma weight, and exit difficulty.
- `references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md` — batch state + blockers.
- `references/authoring/PDV_DaedricBatch0_D18ProofLedger.md` — the proven static-proof template.
- `references/authoring/PDV_CAT6PromotionPilot.md` + `PDV_CAT6PromotionPilot.manifest.json` — promotion policy.

## Verified slot-ID convention (per Prince)

From the manifest (Boethiah/Mephala confirmed). `<Prince>` is the bare name
(`Boethiah`, `Mephala`, `MehrunesDagon`, …):

| Family | Slot ID pattern | Type | Budget / voice |
|--------|-----------------|------|----------------|
| Boon ×3 | `PDV_Bless_Daedric_<Prince>_{Seeker,Devoted,Champion}` | SPEL (passive) | 200/140, Narrator |
| Price ×3 | `PDV_Price_Daedric_<Prince>_{Seeker,Devoted,Champion}` | SPEL (passive) | 200/140, Narrator |
| Tier notifs ×3 | `PDV_Notif_Daedric_<Prince>_{SeekerEntry,DevotedEntry,Lapse}` | MESG/notif | 80/60 |
| Champion entry | `PDV_Msg_Daedric_<Prince>_ChampionEntry` | MESG box | 500/280, God-voice |
| Commitment / curse-onset | `PDV_Msg_Daedric_<Prince>_Commitment` | MESG box | 500/280, God-voice |
| Stigma ×3 | `PDV_Notif_Daedric_<Prince>_Stigma_{Suspected,Known,Notorious}` | MESG/notif | 80/60 |
| Neglect | `PDV_Notif_Daedric_<Prince>_NeglectTexture` | MESG/notif | 80/60 |
| Exit | `PDV_Msg_Daedric_<Prince>_Exit` | MESG box | 500/280 |
| Per-race response | `PDV_Msg_Daedric_<Prince>_Response_<Race>` | MESG box | one per non-native race |

## Code contract

- **Base class:** `PDV_DaedricPathBase.psc` (extends `PDV_DeityBase`). It already
  owns the grammar — `Price_Seeker/Devoted/Champion`, `StigmaPerEvent`,
  `StigmaGlobal`, `CommitmentSignalsRequired`, the `StateByRace` (`Int[]`),
  `StigmaModByRace` (`Float[]`), `ExitDifficultyByRace` (`Int[]`) arrays, the
  `DAEDRIC_STATE_*` enum, `OnTierChange/OnPatronStart/OnPatronEnd`,
  `AddCommitmentSignal`, `AddStigma`, `GetDaedricStateForPlayer`,
  `SyncDaedricContractToTier`. **Do not re-implement any of this** in per-Prince scripts.
- **Per-Prince script:** `PDV_DaedricPath_<Prince>.psc extends PDV_DaedricPathBase`,
  adding only the curated signal-scoring specific to that Prince. **Template:**
  `PDV_DaedricPath_Hircine.psc` (Phase 13 pilot; in
  `handoff/.../Source-Papyrus/` and `scratch/phase13_16_live/`).
- Populate `StateByRace` / `StigmaModByRace` / `ExitDifficultyByRace` from the matrix
  row. **Origin race index order is `RACE_*` in `PDV_DeityBase.psc`:** Nord 0,
  Imperial 1, Breton 2, Altmer 3, Bosmer 4, Dunmer 5, Khajiit 6, Argonian 7, Orc 8,
  Redguard 9 (array length 10, index 8 = Orc).
- Compile after each script: `node .\tools\pdv_compile.mjs --script PDV_DaedricPath_<Prince>` → **0/0** required.

## Record authoring surface

There is **no general Daedric record author yet**. (`tools/pdv-phase20-cat6-author`
is the narrow Khajiit-lunar pilot tool — do **not** use it for Princes.) The proven
precedent is:

- `tools/pdv-phase13-author/` — Mutagen-backed C# author that created the Hircine
  Daedric `MGEF`/`SPEL` packet and wired `Price_*` on `PDV_DaedricPathBase`, driven
  by `references/authoring/PDV_Phase13DaedricHircinePilot.manifest.json`.
- `tools/pdv-phase20-reward-author/` — JSON-contract-driven author
  (`PDV_Phase20_RewardRecordContracts.json`) for the race T1 reward SPEL/MGEF.

**Directive:** generalize this pattern into a per-Prince manifest-driven author
(extend `pdv-phase13-author` or add `tools/pdv-daedric-author`) that reads a Daedric
contract JSON built from the manifest rows and writes the SPEL/MESG records + wires
`PDV_DaedricPath_<Prince>` price/boon properties and `PDV_FLST_AllDaedricPaths`
membership. Always:
1. **Back up the ESP first:** copy `Devotion.esp` to a dated `.bak`.
2. **Dry-run first** (`--dry-run`), inspect the planned writes, then run live.
3. **Refresh SEQ** after authoring Start-Game-Enabled path quests (BaanDar lesson:
   every `PDV_Deity_*`/path QUST needs the SGE flag **and** a SEQ entry).

## Batch order (D-17, strict)

1. **Batch 1 — native variants:** Mephala / Mafala, Malacath / Mauloch.
2. **Batch 2 — standard external:** Mehrunes Dagon, Sheogorath, Namira / Namiira,
   Sanguine / Sangiin, Clavicus Vile, Hermaeus Mora, Nocturnal.
3. **Batch 3 — tolerated / curse tail:** Peryite, Hircine.

Batch 0 (Azura, Vaermina, Meridia, Molag Bal) already has static D-18 proof — it
needs the *record* pass to match, not re-design.

## Worked first target: Mephala (Batch 1)

- Content: manifest **§7.2** (boons, prices, tier-ups, commitment, stigma, neglect,
  exit, per-race responses — all prose already drafted there).
- Matrix: the `Mephala` row of `PDV_DaedricRacePrinceMatrix.csv`.
- Native-integration: Dunmer routes to the race manifest → **author no
  `PDV_Msg_Daedric_Mephala_Response_Dunmer` row**. Khajiit is Legible (gets a global
  response row).
- Steps: write `PDV_DaedricPath_Mephala.psc` (from the Hircine template) → build the
  Mephala contract JSON from §7.2 → dry-run the author → back up ESP → author live →
  wire FormList + path properties → SEQ refresh → run the gate below.

## Hard rules

- **Native-override races get no response row** (Dunmer for Reclamations; Khajiit for
  Boethra/Mafala; Orc for Malacath). They are routed to the race manifest, not the
  Daedric path.
- **Curse-access Princes (Hircine, Molag Bal)** use the D-16 reduced-row set:
  `_Commitment` becomes `_CurseOnset` (fired by the curse-state module), stigma is
  curse-state-driven, exit is the cure path. They must **not** double-fire the race
  `CurseState` rows.
- **No CAT-6 string promotion without readback proof.** Author → read back → then
  treat as content-ready.
- ASCII-only player-facing text (content verifier enforces this).

## Per-Prince acceptance gate (D-18)

```powershell
node .\tools\pdv_compile.mjs --script PDV_DaedricPath_<Prince>     # 0/0
node .\tools\pdv_content_verify.mjs                                # PASS, no FAIL/WARN on the Prince rows
node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json   # no NEW fail
node .\tools\pdv_phase2_reward_readback_audit.mjs --json           # every new record reads back
```
A Prince is content-ready only when all four pass **and** its manifest row checklist
(tone, 3 boons, 3 prices, tier-ups, commitment/curse-onset, stigma, neglect, exit,
all non-native response rows) is complete. Record status in
[PDV_RuntimeEvidenceTracker.md](PDV_RuntimeEvidenceTracker.md). Runtime/display proof
is a separate manual pass, not part of this work order.

## Coordination with Claude (avoid collision)

- **The framework ESP is yours this pass.** Claude's Prisma reconcile writes only
  `.psc`/`.js`/Node files — no ESP records — so there is no ESP merge conflict.
- **Only shared file: `PDV__ManagerQuest.psc`.** Claude edited the Prisma regions
  (`GetPrismaSymbolForDeity`, the panel JSON builders, a new
  `GetPanelNextThresholdText`). **Branch/rebase off Claude's Prisma commit** before
  touching the manager's Daedric routing, so the two edits never race.
- Keep the full verifier sequence green before each commit.
