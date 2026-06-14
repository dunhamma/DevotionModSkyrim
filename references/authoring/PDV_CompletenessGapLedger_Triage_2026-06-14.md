# PDV Completeness Gap Ledger Triage - 2026-06-14

Status: batched triage after the Dunmer shrine, all-race reward ESP closeout, and the BC-0024/BC-0028 Altmer source closeout.

Purpose: keep generated `PDV_CompletenessGapLedger.csv` rows from being treated as current ESP-authoring blockers without review. The ledger remains useful, but many open IDs are stale naming drift, already-live records, or future-scope design placeholders.

## Current Closeout Boundary

- The current automated beta-readiness gate is no longer blocked by source-authority drift, stale reward readback, paired-deity equity, packet-content structure, or the BC-0024/BC-0028 Altmer source tranche.
- Remaining `pdv_beta_readiness_audit` failures are manual/runtime race evidence and the release-claim boundary that depends on that evidence.
- The completeness ledger still contains classified `GAP-REVIEW` rows. These are not automatically beta blockers; promote only coherent batches into named implementation slices.
- Do not bulk-author records from this triage. Real future gaps still need a scoped design/source approval before ESP writes.

## Already Live Or Stale Ledger Rows

These rows read as already satisfied by current source/records, stale generated-ledger naming, or superseded readback expectations:

`BC-0024`, `BC-0028`, `BC-0148`, `BC-0150`, `BC-0178`, `BC-0213`, `BC-0217`, `BC-0224`, `BC-0469`, `BC-0520`, `BC-0535`, `BC-0570`, `BC-0577`, `BC-0589`, `BC-0634`, `BC-0636`, `BC-0637`, `BC-0639`, `BC-0644`, `BC-0646`, `BC-0647`, `BC-0650`, `BC-0651`, `BC-0652`, `BC-0653`, `BC-0654`, `BC-0656`, `BC-0658`, `BC-0659`, `BC-0660`, `BC-0661`, `BC-0664`, `BC-0665`, `BC-0666`, `BC-0667`, `BC-0669`, `BC-0670`, `BC-0671`, `BC-0672`, `BC-0673`, `BC-0674`, `BC-0676`, `BC-0677`, `BC-0680`, `BC-0683`, `BC-0684`, `BC-0685`, `BC-0687`, `BC-0688`, `BC-0689`, `BC-0690`, `BC-0691`, `BC-0693`, `BC-0694`, `BC-0695`, `BC-0696`, `BC-0699`, `BC-0712`, `BC-0713`, `BC-0735`, `BC-0741`, `BC-0760`.

Action: close or rebaseline in the generated completeness-audit source during a separate audit-tool cleanup pass. `BC-0024` is now generated as PASS after `RunDawnAwardAltmerAuriElDawn` was added before dawn consolidation. `BC-0028` is now generated as PASS after `HandleAltmerMagicSkillIncrease` was added and the audit learned that `AwardCuratedSignalScaled` is a piety sink. The 2026-06-14 batched cleanup also taught the audit established naming drift (`PDV_Player` -> `PDV_PlayerEvents`, `PDV_State_*` -> `PDV_StateTrack_*`, `PDV_GLO_State_*` -> `PDV_GLO_*`, `ProcessCommitmentOffers` -> `RunDawnProcessCommitmentOffersNoop`, `ApplySpell` -> `RunDawnApplySpellAndNeglectLayers`) and fixed the Part B profile parser so Auri-El, Malacath, and Vaermina profiles read correctly.

## Doc-Only Or False Positive Rows

These rows are not current runtime/record authoring requirements:

`BC-0225`, `BC-0227`, `BC-0697`, `BC-0698`, `BC-0710`.

Action: clarify owning docs or generated-audit labels only.

## Deferred Design Scope

`BC-0732` is deferred design scope, not a pre-beta ESP blocker.

Action: leave deferred until its owning design slice is reopened.

## Remaining Classified Work

These rows remain open after batched audit cleanup. Treat them as grouped packets, not one-row opportunistic fixes.

### Probe-Gated Source Routes

`BC-0025` Altmer College/Psijic and `BC-0094` Nord Kyne/Kynareth piety wording remain source questions. Both have adjacent live support/context systems, but the current machine proof does not prove the specific piety-award behavior described by the contract rows.

Action: promote only after a route packet names exact event sources, anti-farm keys, and expected piety sink. Do not claim the existing support/favor route as piety proof.

### Favor-Family Top-Up Packet

`BC-0048`, `BC-0049`, `BC-0052`, `BC-0457`, `BC-0458`, `BC-0593`, and `BC-0594` are the Bosmer Z'en Reciprocity / Breton KnightJustice top-up family. houseCARL readback confirms `PDV_FavorFamily_ZenReciprocity` and `PDV_FavorFamily_KnightJustice` are not present in `Devotion.esp`; the trigger-top-up runbook still requires detection-probe proof before locking the source routes.

Action: build as one named packet after probe proof: register the two KYWD records through a narrow PDV helper, add source routing/caps, refresh SEQ if needed, then rerun targeted readback plus the standard gates.

### Daedric Exposure Global

`BC-0224`, `BC-0699`, and `BC-0713` require `PDV_GLO_DaedricExposure`. houseCARL confirms all 16 per-Prince stigma globals exist and the aggregate `PDV_GLO_DaedricExposure` does not. Current Daedric beta/readiness gates pass without this aggregate social-reaction global.

Action: keep as a separate Daedric social-reaction authoring packet unless the release scope reopens NPC/social conditions that consume the aggregate global. Do not mark Daedric runtime/display proof complete from this readback.

### Formal State/Curse Records

`BC-0520`, `BC-0535`, `BC-0570`, `BC-0573`, and `BC-0577` describe formal state-track or curse-history records. Current source uses StorageUtil posture/history keys for several of these behaviors, but the completeness rows still name formal record/state surfaces.

Action: decide as a batch whether these are record-authoring requirements or contract drift to live StorageUtil keys. If authoring, use the relevant narrow record helper and rerun readback. If contract drift, update the rows to the live keys and proof commands.

### Transition Surfacing Backlog

`BC-0634`, `BC-0636`, `BC-0637`, `BC-0639`, `BC-0641`, `BC-0644`, `BC-0646`, `BC-0647`, `BC-0650`, `BC-0651`, `BC-0652`, `BC-0653`, `BC-0654`, `BC-0656`, `BC-0658`, `BC-0659`, `BC-0660`, `BC-0661`, `BC-0664`, `BC-0665`, `BC-0666`, `BC-0667`, `BC-0669`, `BC-0670`, `BC-0671`, `BC-0672`, `BC-0673`, `BC-0674`, `BC-0676`, `BC-0677`, `BC-0680`, `BC-0683`, `BC-0684`, `BC-0685`, `BC-0689`, and `BC-0696` are transition/surfacing message or notification rows. They are record/copy surfacing backlog, not proof that core piety or reward records failed.

Action: handle as a record-copy/surfacing tranche if those notifications are in beta scope; otherwise keep as classified non-runtime backlog.

### Deferred Design

`BC-0732` remains deferred Mara privilege-pilot scope.

Action: leave deferred until the owning privilege/dialogue pattern is reopened.

## Verification Snapshot

- All ten Phase 20 race reward specs passed `--author-rewards --dry-run`, live `--author-rewards`, and post-write `--check-rewards`.
- `node .\tools\pdv_phase2_reward_readback_audit.mjs --json` passed with `PASS=1291`.
- P2 `--check-source-fill`, `--check-exact-stage-gates`, and `--check-route-entries` passed after source-authority drift cleanup.
- Completeness audit now reports `PASS=360`, `GAP-REVIEW=54`; `BC-0024` passes as a source-reachable Altmer Auri-El dawn route and `BC-0028` passes as a source-reachable Altmer Magnus magic milestone route.
- `node .\tools\pdv_beta_readiness_audit.mjs --json` reports only race manual/runtime evidence and release-boundary failures.
