# PDV Session Handoff -- Hircine Display Drift And Audit Fixes

**Date:** 2026-06-12 AEST  
**Status:** Mechanical audit fixes landed; runtime/manual proof still pending  
**Scope:** Follow-up to the 2026-06-11 audit items for Hircine VMAD/source drift, SEQ freshness, Orc ActorValue names, generated artifact cleanup, and ASCII-safe audit output.

## Read First

1. `references/authoring/PDV_InGameTestingNeeded_Runbook.md` - active ordered in-game queue.
2. `references/authoring/PDV_DaedricControlledProof_Runbook.md` - controlled MCM/QASmoke/organic Daedric proof path.
3. `references/authoring/PDV_DaedricInGameSmokePacket.md` - compact tester command sheet.
4. `references/authoring/PDV_DaedricRuntimeEvidenceLedger.json` - structured Daedric evidence slots.
5. `references/authoring/PDV_CompletenessGapLedger.md` - current completeness audit ledger.

## What Changed

### Hircine Display Surface

Live source:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_DaedricPath_Hircine.psc
```

Compiled output:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_DaedricPath_Hircine.pex
```

`PDV_DaedricPath_Hircine.psc` keeps its Phase 13 hunt/residue behavior, but now declares the all-Prince display/control properties already baked onto the concrete Hircine quest in the framework ESP:

- `ControlledSignalPietyDelta`
- `ControlledSignalStigmaDelta`
- `Notif_Lapse`
- `Notif_Stigma_Suspected`
- `Notif_Stigma_Known`
- `Notif_Stigma_Notorious`
- `Notif_NeglectTexture`
- `Msg_Exit`
- all ten `Msg_Response_<Race>` properties

It also now exposes the controlled/live-sender proof helpers and shows the race response on werewolf entry. This fixes the source side of the orphaned VMAD property warnings. It does not by itself prove the in-game display path.

### SEQ

`Devotion.seq` was refreshed after confirming Skyrim/CK were not running:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq
```

Backup:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260611-094346.bak
```

Refresh result: `PASS`, `changed=false`, `questCount=39`.

### Orc Rebalance Pre-Authoring Fix

`references/authoring/PDV_OrcRewardRecords.spec.json` now uses canonical ActorValue strings:

- `Speechcraft` instead of `Speech`
- `Block` instead of `BlockSkill`

`node .\tools\pdv_cumulative_rebalance.mjs --dry` now prints:

```text
Orc / City:
  T2 Restoration+18, Speechcraft+8
  T3 Restoration+41, Speechcraft+28, Block+5

Orc / LegionExile:
  T2 OneHanded+18, Block+8
  T3 OneHanded+41, Block+28, StaminaRateMult+5
```

### Audit Hygiene

- Deleted untracked `generated/_contract_raw.json`.
- Repaired `AGENTS.md`, `PDV_CompletenessGapLedger.md`, and `PDV_CompletenessGapLedger.csv` to ASCII.
- Added `asciiSafe()` to `tools/pdv_completeness_audit.mjs` so future ledger output stays ASCII-safe.
- Added durable notes to `AGENTS.md` and `PDV_MOD_SETUP.md`.

## Verification Snapshot

### Readback / Verifier

Commands already run after the fix:

```powershell
node .\tools\pdv_compile.mjs --script PDV_DaedricPath_Hircine
node .\tools\pdv_refresh_seq.mjs --write --json
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-race-costing
node .\tools\pdv_completeness_audit.mjs --json
node .\tools\pdv_cumulative_rebalance.mjs --dry
```

Observed results:

- Hircine compile: `0 error(s), 0 warning(s)`.
- Default verifier: `FAIL=0, WARN=2, TODO=0, PASS=2929, INFO=38`.
- Remaining default warnings: four unnamed `INFO` records and nine medallion glyph fallbacks.
- Strict Phase 20 race-costing: still fails on the separate Khajiit CAT-6 text/magnitude mismatch.
- Completeness audit: still fails closed with `3 GAP`, `87 GAP-REVIEW`.

The three hard completeness gaps were not auto-fixed because they need adjudication:

- Redguard `PDV_Bless_Redguard_FarShoresToken` spell missing.
- Breton `PDV_State_BretonDruidicFork` state track missing.
- Redguard required content rows missing.

### Route / Runtime Smoke

No new in-game route proof was run in this slice. Hircine is now eligible for the Daedric proof session, but route evidence still needs to be recorded.

### Manual / Acceptance

No Active Effects, MessageBox, Prisma/notification, save/load, stack-legibility, or manual-feel evidence was recorded in this slice.

### Placement / World Proof

No final-world placement proof was recorded in this slice.

## Next Session: Hircine-First Daedric Proof

Before launching Skyrim:

```powershell
node .\tools\pdv_daedric_test_readiness.mjs --deep
node .\tools\pdv_verify.mjs
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

In game, prioritize Hircine before the full all-Prince sweep because it was the only Prince with source/VMAD drift:

1. Use MCM Debug -> Daedric display proof -> select Hircine.
2. Run the controlled signal, tier, lapse, stigma, summary, and reset controls.
3. Activate the QASmoke Hircine sender and generic silence sender.
4. If using organic proof, use the exact DA05 stage path from the Daedric smoke packet and remember that console `setstage` only works when the quest is already running.
5. For Hircine curse access, separately test werewolf entry/cure/no-double-fire. DA05 route proof is content-surface proof, not lycanthropy proof.

After closing Skyrim, record route slots:

```powershell
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince Hircine --include-generic
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source qasmoke --prince Hircine --include-generic
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source organic --prince Hircine --no-generic
```

Record manual slots only from direct observation:

```powershell
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot activeEffects --status pass --note "<observed Active Effects evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot summaryMessage --status pass --note "<observed summary MessageBox evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot prismaNotification --status pass --note "<observed Prisma or notification evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot saveLoad --status pass --note "<observed save/load evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot stackLegibility --status pass --note "<observed stack legibility evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot curseNoDoubleFire --status pass --note "<observed werewolf no-double-fire evidence>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot manualFeel --status pass --note "<short feel note>"
```

Then run:

```powershell
node .\tools\pdv_daedric_evidence_intake.mjs --summary
node .\tools\pdv_daedric_beta_gate.mjs --strict
```

Expected beta gate result after Hircine only: still blocked for the other fifteen Princes. That is correct.

## Remaining Non-Hircine Work

- Adjudicate the 3 hard completeness gaps before generating Breton/Redguard records.
- Decide the systematic `GAP-REVIEW` surfacing pattern: per-race notification/message records versus shared records with race text.
- Remove the four unnamed `INFO` records the next time the ESP is safely open for write cleanup.
- Add or accept fallback status for the nine missing medallion glyphs.
- Resolve the separate Khajiit CAT-6 text/magnitude mismatch before trusting strict Phase 20 race-costing as a pass gate again.

## Do Not Claim Yet

- Do not claim Hircine beta-display ready from the compile/readback fix.
- Do not claim Daedric all-Prince beta readiness until all sixteen Princes have route, display, save/load, stack, manual-feel, and generic-silence evidence in the ledger.
- Do not claim race beta-feel readiness from the completeness ledger alone. Race packets still need manual/runtime evidence and final-world placement remains separate.
