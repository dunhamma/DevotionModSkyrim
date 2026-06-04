# PDV Phase 20 Next Runtime Hook

**Created:** 2026-06-03
**Updated:** 2026-06-03
**Status:** Post-P2-book-fill runtime and exact-stage gate handoff
**Owner:** Companion to `PDV_Phase20_BetaReadinessRemainder.md`

## Paste-In Hook

Continue Phase 20 from the post-P2-book-fill boundary. Do not redo the old
readback-only handoff as if no fill occurred. The approved P2 book-read packet
is live-readback PASS, but it is not runtime or beta proof.

Primary runtime track:

1. Prove accepted book-read behavior in game for the six filled P2 source
   families:
   - Breton Hidden Art
   - Dunmer Azura
   - Dunmer Boethiah
   - Imperial public Talos
   - Nord Old Ways
   - Nord Hircine/Arkay edge
2. For each family, record accepted trigger behavior, wrong-origin silence,
   generic-source silence, repeat/anti-farm behavior, Survey/status clarity,
   and stack snapshot evidence.
3. Update `PDV_Phase20_ManualEvidenceLedger.json` and
   `PDV_PreBetaRaceGateLedger.md` only for checks actually run.

Secondary automated track:

1. Keep the exact-stage quest gate green before any quest-stage source is
   filled.
2. Design runtime exact-stage receiver support before changing
   `questStageGate.receiverStatus` to `exact-stage-supported`.
3. Do not fill quest-stage sources until `PDV_PlayerEvents` can compare
   `aiNewStage` against explicit approved stages for that source and route
   family.

Start from:

- `references/authoring/PDV_Phase20_NoInGameProof_Gates.json`
- `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`
- `references/authoring/PDV_Phase20_SourceFillApprovalLedger.json`
- `references/authoring/PDV_Phase20_BetaReadinessRemainder.md`
- `references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`

## Commands

Run before in-game proof:

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --list
```

Run after the in-game P2 book-read pass:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager
```

## Required Output

Record the P2 book-source runtime result. Do not mark a race `Pass` or
`Conditional` only because the checker sees route markers; Survey/status,
wrong-origin silence, repeat behavior, stack snapshot, and manual feel evidence
must also be recorded.

If exact-stage quest work starts, create the receiver design or implementation
first. Do not write quest-stage entries to the ESP while
`questStageGate.receiverStatus` is `not-implemented`.

## Stop Conditions

Stop and report instead of filling quest-stage sources if:

- any source is only a scan-table candidate
- a quest source has no exact stage or outcome readback
- a route would fire from generic quest progress, generic book reading, generic
  travel, generic crime, generic combat, or generic crafting
- a source would double-score through two receiver families
- a source needs a new receiver shape rather than an existing FormList
- a source would require a new mesh or visual asset

Current expected asset posture remains: no required new custom mesh assets for
the end-state hook network.
