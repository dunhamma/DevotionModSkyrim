# PDV Beta Readiness Closure Audit

**Created:** 2026-06-10
**Status:** Active fail-closed claim gate
**Tool:** `tools/pdv_beta_readiness_audit.mjs`

## Purpose

This audit exists to stop "backend scaled out" or "beta-feel ready" claims from
passing on partial proof.

It reads the current authority files and ledgers across race content, P2 source
fill, manual race evidence, beta packets, and Daedric runtime evidence. It keeps
the proof buckets separate:

- `authority`: row-level design/contract coverage exists and is machine-checkable.
- `readback`: records, FormLists, properties, and source-fill entries read back.
- `runtime-route`: Papyrus route markers prove a signal reached the manager.
- `manual`: player-facing behavior, wrong-origin silence, stack snapshots, and feel.
- `claim`: the final release/readiness statement is allowed or blocked.

## Command

Run from the repo root:

```powershell
node .\tools\pdv_beta_readiness_audit.mjs --strict
```

Use JSON output when another tool or report needs structured results:

```powershell
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

`NOT_BETA_READY` is the expected verdict until every blocker is intentionally
closed. A failing audit is useful evidence, not a broken tool.

## What It Catches

The audit checks for:

- Missing row-level race/deity or race/Prince coverage authority.
- Drift between the P2 receiver manifest and the source-fill approval ledger.
- Missing or malformed per-race reward specs.
- P2 receiver source rows without accepted/rejected source boundaries.
- Source-fill rows without exact sources, duplicate guards, or quest-stage gates.
- Race manual evidence slots still pending.
- Missing or blocked beta-test packets.
- Daedric runtime/display evidence still pending.
- Any release claim that would collapse readback proof into runtime/manual proof.

## First Strict Run

The first strict run on 2026-06-10 correctly failed closed:

```text
Verdict: NOT_BETA_READY
Counts: PASS=23 WARN=1 FAIL=9 INFO=3
```

Blocking classes:

- `PDV_DeityCoverageMatrix.json` has summary coverage fields but no row-level
  coverage array for every race/deity and race/Prince pairing.
- `PDV_Phase20_P2ImmersiveReceivers.manifest.json` still declares `0` approved
  quest-stage entries while `PDV_Phase20_SourceFillApprovalLedger.json` has the
  approved Altmer MQ104 stage-160 source fill.
- Race manual evidence remains pending for most races; Altmer and Khajiit have
  one pending slot each.
- Bosmer remains a blocked source packet with only the QASmoke fallback packet.
- All sixteen Daedric Princes remain pending in the runtime/display evidence
  ledger.

These findings match the intended proof boundary: record/readback scaffolding is
advanced, but beta-feel release evidence is not complete.

## Row Authority Remediation

The 2026-06-10 remediation pass moved the repo-side authority gaps to pending
runtime state:

- `PDV_DeityCoverageMatrix.json` now has 610 row-level coverage entries:
  450 locked worship object x race rows plus 160 Skyrim-present Prince x race
  rows.
- Every row carries the required beta-readiness fields and an explicit
  `runtimeProofStatus` of `pending-runtime`.
- `PDV_Phase20_P2ImmersiveReceivers.manifest.json` now declares the one approved
  exact quest-stage fill: Altmer MQ104 stage 160 for the Lorkhan crisis route.
- The closure audit now checks exact row completeness, not just array presence.

Post-remediation strict run:

```text
Verdict: NOT_BETA_READY
Counts: PASS=26 WARN=1 FAIL=6 INFO=3
```

Remaining blockers are runtime/manual only: race manual evidence, Bosmer source
packet approval/fill, Daedric runtime/display evidence, and the corresponding
release-claim boundaries.

## Bosmer Source Packet Remediation

The 2026-06-10 Bosmer remediation pass approved and filled one exact source
packet:

- `PDV_FLST_P2_BosmerYffreSources` now contains `DA05`
  (`Skyrim.esm:02A49A`).
- Approved stages are `100` and `105`, matching the Ill Met By Moonlight
  terminal hunt/mercy branches.
- The source-fill writer created backup
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\Devotion.esp.20260610-152411.bak`.
- `--check-source-fill`, `--check-exact-stage-gates`, and the base wiring audit
  read back the Bosmer source fill.

This moves Bosmer from source-blocked to runtime/manual pending. It does not
prove DA05 route delivery, wrong-origin rejection, generic-source silence,
Survey/status clarity, reward/stack behavior, or feel.

## 2026-07-05 Closure Run

After the Imperial and Dunmer manual/runtime closeouts were transcribed into
`PDV_Phase20_ManualEvidenceLedger.json`, the strict audit passed:

```text
Verdict: STRICT_GATE_PASS
Counts: PASS=31 WARN=1 INFO=2
Blockers: []
```

The pass means the strict beta-readiness closure audit now sees authority,
readback, runtime-route, manual race evidence, and Daedric runtime/display
evidence aligned for the current beta-feel gate. It does not claim
final-world placement, Requiem feltness proof, likes/dislikes reload proof, or
future content-depth tranches.

The remaining warning is the paired-deity warning count, which the audit reports
as non-blocking for this gate.

## Closeout Order

1. Preserve the current strict-audit pass in the active handoff and avoid using
   older `NOT_BETA_READY` or `Dunmer:7` output as current state.
2. Keep future beta-feel release claims tied to rerunning
   `node .\tools\pdv_beta_readiness_audit.mjs --strict --json` after any
   evidence, Daedric, Prisma, reward, or runtime-surfacing change.
3. Track final-world placement, Requiem feltness proof, likes/dislikes reload
   proof, and future content-depth tranches outside this strict gate unless the
   gate contract is intentionally expanded.

## Boundary

Do not use a green record/readback gate, QASmoke route proof, or source-fill
readback as beta-feel proof. The closure audit can pass only when the relevant
authority, readback, runtime-route, and manual evidence buckets all support the
claim being made.
