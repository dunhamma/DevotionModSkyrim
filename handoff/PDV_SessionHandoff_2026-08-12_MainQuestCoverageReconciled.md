# Session Handoff: Main-Quest 173-Cell Reconciliation

Updated: 2026-08-12
Predecessor: `handoff/PDV_SessionHandoff_2026-08-12_OfficialQuestAuditCloseout.md`

## What this session closed

The predecessor handoff left one open item: the main-quest full-coverage audit
(`tools/pdv_main_quest_full_coverage_audit.mjs`) reported **173 missing deity-stage cells**
on the 45x25 contract, and asked whether these were intentional exclusions or genuine
regeneration gaps. This session made that determination and reconciled the artifact.

## Determination: intentional, owner-approved exclusions

The 173 missing cells are **not** a regeneration gap. They are the exact footprint of five
main-quest beats that the official-quest retrospective (`b3cc95d6`) narrowed away from the
original all-deity fan-out, with reasons recorded and marked owner-approved in
`references/authoring/PDV_CoreQuestSourceRepairs.json`:

| Beat | Removed from T11 | Present after | Missing (silenced) |
|------|-----------------:|--------------:|-------------------:|
| MQ103\|190 (Bleak Falls Barrow) | 32 | 7 | 38 |
| MQ105U\|60 (Greybeard oath) | 36 | 8 | 37 |
| MQ203\|280 (Alduin's Wall) | 40 | 7 | 38 |
| MQ206\|100 (Alduin's Bane) | 45 | 8 | 37 |
| MQ206\|220 (Alduin's Bane / Dragonrend) | 40 | 22 | 23 |
| **Total** | **193** | **52** | **173** |

193 T11 rows were removed; 20 of those cells survive via other tranches, leaving 173 truly
absent. The removals reflect direct act-evidence: e.g. returning the Dragonstone proves
research and civic service, not honorable combat for Trinimac. The surviving deities per
beat are thematically coherent (knowledge gods for the Dragonstone, oath/sky gods for the
Greybeards).

The 20 other contracted beats retain full 45-deity coverage because they have not yet had a
direct-evidence pass -- not because uniform coverage is an invariant. **A future coverage
FAIL on another main-quest beat is most likely the contract lagging a new owner-approved
narrowing, and is resolved by adding `approvedSilences`, not by restoring cells.**

## Changes made (repo-side only; no .psc / no ESP)

- `references/authoring/PDV_MainQuestFullCoverageContract.json`
  - `approvedSilences`: `[]` -> **173 entries**, each carrying the per-beat evidence reason
    and the `PDV_CoreQuestSourceRepairs.json` citation.
  - `expected.tranche11Rows`: 951 -> **758** (matches current T11 after the removals).
  - `expected.matrixCells`: 1978 -> **4108**; `questKeys`: 172 -> **450**;
    `watchedQuests`: 134 -> **353**. These reconcile the whole-matrix counts to the
    committed post-retrospective compile (faucetActs unchanged at 26). This is updating a
    stale snapshot-pin to already-committed, owner-approved data, not loosening the gate.
  - `authority` note and `updated` date refreshed.
- `references/authoring/PDV_QuestReactionMatrix_T11_SilenceLedger.md`
  - "Approved silences: none" -> the 173-cell, five-beat table; date refreshed.

## Verification

`node tools/pdv_main_quest_full_coverage_audit.mjs --check` -> **PASS (19/19, exit 0)**.
The audit re-derives the compiled matrix internally (`pdv_quest_matrix_compile --check`),
so the live PapyrusUtil JSON already matches; no Papyrus recompile was needed for this change.

## Not done (owner-gated or out of scope)

1. **Prerelease 1.5.0e** -- explicitly owner-confirmation-gated in the predecessor handoff.
   Not built.
2. **Full repository/live parity verify** (`pdv_verify.mjs`, houseCARL live readback) -- not
   run. This change is documentation/contract only, so it has no live-ESP parity impact, and
   a full live verify flips the shared MO2/houseCARL profile pointer; left for the owner's
   parity/prerelease pass.
3. **Stale aggregate counts (1978/172) in canonical docs** -- `AGENTS.md`, `PDV_MOD_SETUP.md`
   and several dated handoffs/runbooks still cite the pre-retrospective 1978/172 numbers.
   Already tracked in `PDV_ARR25_ContentSweep_CodexHandoff_2026-08-06.md:144`. Left to Codex
   (canonical-doc ownership); not rewritten here.
4. **Five decompilation scratch directories** (predecessor "Administrative Notes") -- still
   pending path/reparse-point validation before deletion. Not touched (deletion + reparse
   validation; owner call).
