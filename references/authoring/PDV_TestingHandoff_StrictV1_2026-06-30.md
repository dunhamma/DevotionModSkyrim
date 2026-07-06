# PDV Strict v1.0 Testing Handoff

Generated: 2026-06-30 AEST

Target: strict v1.0 beta readiness, not a limited tester build with known open proof.

Current verdict: do not open strict v1.0 beta yet. Static/readback gates are
clean on the current Prisma-to-1.0 update. As of the 2026-07-04 Imperial
closeout, the active race blocker is Dunmer manual/runtime evidence; Requiem
felt-penalty proof and the broader last-pass sweeps remain separate strict-v1.0
work.

2026-07-04 update: use
`PDV_SessionHandoff_2026-07-04_ImperialCloseout.md` as the current race-session
entrypoint. Imperial is closed for the current race beta-feel packet unless a
regression touches Concordat, Talos offer gating, civic-service route
attribution, formal offers, Active Effects, or Book-of-Days/Ledger surfacing.

## Current Checked State

These checks were run after the latest Prisma-to-1.0 recovery update:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_prisma_toast_fallback_audit.mjs
node .\tools\pdv_book_of_days_audit.mjs
node .\tools\pdv_requiem_penalty_audit.mjs
node .\tools\pdv_daedric_beta_gate.mjs --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
node .\tools\pdv_integrity_harness.mjs
```

Results:

| Gate | Current result |
| --- | --- |
| Targeted compile | PASS: `PDV__ManagerQuest`, `PDV_MCM`, `PDV_PlayerEvents`, all `0 error(s), 0 warning(s)` |
| `pdv_verify --json` | PASS: `PASS=3512`, `WARN=1`, `INFO=64` |
| `pdv_prisma_to_oneoh_audit` | PASS: `PASS=50`, `FAIL=0` |
| `pdv_prisma_ui_audit` | PASS: 48 checks |
| `pdv_prisma_toast_fallback_audit` | PASS: `PASS=26`, `FAIL=0` |
| `pdv_book_of_days_audit` | PASS: `PASS=107`, `WARN=0`, `FAIL=0` |
| `pdv_requiem_penalty_audit` | PASS: `PASS=44` |
| `pdv_daedric_beta_gate --json` | PASS: `PASS=16` |
| `pdv_integrity_harness` | PASS, including signal E2E `39 GREEN / 0 RED` |
| `pdv_beta_readiness_audit --strict --json` | NOT_BETA_READY: `FAIL=2`, Dunmer:7 manual evidence blocker plus the release-claim boundary |

## 2026-07-04 Kickoff Recheck

These checks were rerun at kickoff after the Imperial closeout handoff was
created:

```powershell
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_compile.mjs --script PDV_ActionRouter --script PDV_EventBus --script PDV_EventTypes --script PDV__ManagerQuest
node .\tools\pdv_ascii_guard.mjs --summary --ext .psc .\live-source\Scripts\Source\PDV_ActionRouter.psc
```

Results:

- Strict beta audit remains `NOT_BETA_READY`: `PASS=29`, `INFO=3`,
  `WARN=1`, `FAIL=2`; blockers are `Dunmer:7` and the release-claim boundary.
- Prisma UI audit passes 74 checks.
- `PDV_EventBus`, `PDV_EventTypes`, and `PDV__ManagerQuest` compile with
  `0 error(s), 0 warning(s)`.
- `PDV_ActionRouter` initially failed because `GetEventReason` called a
  nonexistent `GetEventTypes()` helper. The source now uses the existing
  `PDV_EventTypesService` property, compiles with `0 error(s), 0 warning(s)`,
  and passes ASCII guard.
- Post-compile verifier reports `FAIL=0`, `WARN=1`, `PASS=3510`, `INFO=66`.
  The remaining warning is the known medallion glyph fallback.

Important boundary: the new `neglect.recover` path is statically clean and
compiled, but it is not runtime/manual proof. It must be tested through the
Universal Prisma U6/U7 pass and carried into the Dunmer Prisma slots. Imperial
already passed for the current race packet and remains regression reference.

## Source Updates Just Checked

- `PDV__ManagerQuest.psc` now stores `PDV.Neglect.PatronToastState` before
  changing it and emits `SurfaceTransition("neglect", ..., "recover", ..., "renewal")`
  when the active patron leaves neglect.
- `PDV__ManagerQuest.psc` now builds Book of Days path text, standing-deity
  selection, and standing instrument JSON through named helpers instead of
  keeping that logic inside the payload builder.
- Imperial info-only startup copy is shortened: it no longer appends the long
  generic Devotion advisory paragraph to the initial race message.
- Prisma overlay close state now routes through a shared overlay controller:
  Book of Days, dormant startup/medallion modal, and focused panel opens clear
  stale modal state before showing the next surface.
- `PDV_RunSheet_Universal_Prisma_V1.md` now has U6 neglect drop and U7 neglect
  recovery. The old readability synthesis is now U8.
- `PDV_RunSheet_Dunmer_BetaFeel.md` requires the shared recovery beat inside
  its Prisma surface evidence. `PDV_RunSheet_Imperial_BetaFeel.md` already
  passed for the current packet and remains regression reference only.
- `PDV_InGameTestingNeeded_Runbook.md` now includes
  `node .\tools\pdv_prisma_to_oneoh_audit.mjs` in preflight and calls out the
  recovery sweep.
- `tools\pdv_prisma_to_oneoh_audit.mjs` is the new roll-up guard for the
  Prisma-to-1.0 producer/UI wiring.

## Proof Rules

Keep these buckets separate:

| Bucket | Counts for | Does not count for |
| --- | --- | --- |
| Authority/spec | Roster, manifests, row coverage, locked design | Runtime feel, UI display, player proof |
| Readback/static | ESP/source/UI parity, property wiring, compiled path presence | In-game behavior |
| Runtime-route | Papyrus markers, checker pass, accepted/rejected source route proof | Manual legibility or feel |
| Manual/runtime | Active Effects, Survey/status readability, stack snapshots, visible UI behavior, save/load feel | Static/readback gate closure |
| Claim | Strict beta/public readiness | Any narrower "machine clean" claim |

Do not update the manual evidence ledger from readback-only proof.

## Testing Order

### 0. Freeze The Test Build

Before opening Skyrim:

1. Confirm the working tree and note any uncommitted files.
2. Do not use the existing `dist\Devotion for Diaries of Dibella - Tester Pack (PreBeta .8).zip`
   as the final beta package.
3. If any script or Prisma asset changes after this point, restart at Step 1.

Evidence sink: this handoff plus `git status --short --branch`.

Stop if: the intended test build is unclear, source/live parity fails, or the
tester package is older than the final gate rerun.

### 1. Machine Preflight Bundle

Run this full preflight immediately before opening Skyrim:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_integrity_harness.mjs
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_prisma_toast_fallback_audit.mjs
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_book_of_days_audit.mjs
node .\tools\pdv_requiem_penalty_audit.mjs
node .\tools\pdv_daedric_beta_gate.mjs --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

If the SEQ may have changed or a package is about to be rebuilt, also run:

```powershell
node .\tools\pdv_refresh_seq.mjs --write --json
```

Expected:

- Compile succeeds with no errors or warnings for the three targeted scripts.
- `pdv_verify` has no `FAIL`; the known medallion glyph warning is allowed only
  if unchanged and still documented.
- Book of Days repo/live hashes pass.
- Prisma-to-1.0 audit passes, including `neglect.recover`.
- Requiem audit passes as backend/readback proof only.
- Daedric beta gate remains `PASS=16`.
- Strict beta audit may still fail on Dunmer manual evidence plus the release
  claim boundary until Step 4 is recorded.

Stop if: any new static/readback gate fails, Daedric drops below `PASS=16`, or
strict beta reports blockers other than the known Dunmer manual slots and the
release-claim boundary.

### 2. Universal Prisma V1 Smoke

2026-07-06 checkpoint: U1-U9 passed in game during Mega Packet Sitting 1. This
section remains the recipe if a future Prisma/source change invalidates that
evidence; do not rerun it only to close the current Sitting-1 residuals. The
open Prisma residuals are the Mega Packet C2 per-origin beats: Altmer alignment
band, Khajiit Champion pin pruning survival, and Redguard sect Champion toast.

Run `references/authoring/PDV_RunSheet_Universal_Prisma_V1.md` before the race
sheets because the latest update touches shared Prisma behavior.

Order:

1. U1: toast-only event surfaces.
2. U2: player-owned Devotion panel open/close.
3. U3: Book of Days open/close from player-owned controls, including ESC/X/hotkey.
4. U4: Ledger and substrate rows.
5. U5: Book of Days legibility and prune behavior.
6. U6: neglect drop. Confirm first lapse gets a neglect toast and Book of Days note once.
7. U7: neglect recovery. After U6, award one patron signal, set patron piety to
   15, run dawn, and confirm a readable recovery/renewal beat without forced full
   panel open and without repeating the old lapse.
8. U8: formal offer accept/refuse. Use MCM Developer Options to seed/evaluate a
   pending commitment on an offer-capable race, then prove both Accept and Refuse
   on disposable saves. Confirm each gives a Prisma toast plus a pinned,
   non-blank Book of Days line, and neither forces the full panel open.
9. U9: write the readability synthesis.

Evidence sink: `references/authoring/PDV_V1_BetaReadinessGate.md`, Papyrus log,
and `DevotionPrismaBridge` log.

Stop if: Book of Days is blank, ESC/X/hotkey close fails, gameplay events force
open the full panel, neglect drop repeats every dawn, recovery is absent, or
offer accept/refuse lacks either its toast or pinned Chronicle line.

### 3. Imperial Beta-Feel Run Sheet - Closed Current Packet

Do not rerun `references/authoring/PDV_RunSheet_Imperial_BetaFeel.md` as an
active blocker unless a regression touches Concordat, Talos offer gating,
civic-service route attribution, formal offers, Active Effects, or
Book-of-Days/Ledger surfacing.

Current evidence lives in:

- `references/authoring/PDV_RunSheet_Imperial_V1.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `references/authoring/PDV_SessionHandoff_2026-07-04_ImperialCloseout.md`

Historical/regression scope:

Close all seven strict blockers for Imperial:

```text
wrongOriginRejection
genericHookRejection
surveyStatusClarity
stackSnapshot
manualFeelNote
immersiveHookProof
assetStatus
```

Order inside the sheet if this must be reopened:

1. Seed a disposable Imperial test state and confirm MCM/debug setup.
2. Prove accepted Imperial routes: public/private Talos pressure and civic Survey
   display.
3. Prove wrong-origin rejection.
4. Prove generic silence: faction membership, attendance, bounty/lawfulness, and
   any generic civic hook must not score.
5. Run the shared Daedric inn-sleep negative plus positive sleep control if the
   sheet calls for it.
6. Record Survey/status clarity and stack snapshot, including Active Effects and
   any public/private Talos stack.
7. Run the Prisma surface checks, including civic neglect preservation and the
   active-patron recovery beat from Universal U6/U7 and formal offer U8 if this
   save is used for commitment-offer proof.
8. Save/load after the stack snapshot, reopen Devotion surfaces, and confirm no
   stale/doubled UI state.
9. Run the route checker:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager
```

Evidence sinks:

- `references/authoring/PDV_RunSheet_Imperial_BetaFeel.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- Papyrus log marker `RouteImperialTalosPressure complete:`

Stop if: a wrong-origin or generic hook scores, Survey contradicts MCM/debug
state, Prisma forces the full panel, Imperial civic neglect changes from
`ResistDisease -5` into Health loss, or save/load changes the visible state.

### 4. Dunmer Beta-Feel Run Sheet

Run `references/authoring/PDV_RunSheet_Dunmer_BetaFeel.md`.

Close all seven strict blockers for Dunmer:

```text
wrongOriginRejection
genericHookRejection
surveyStatusClarity
stackSnapshot
manualFeelNote
immersiveHookProof
assetStatus
```

Order inside the sheet:

1. Seed a disposable Dunmer test state and confirm MCM/debug setup.
2. Prove accepted Reclamation and ancestor routes: Azura, Boethiah, portable
   shrine, player-home, twilight, and other sheet-approved sources.
3. Prove wrong-origin rejection.
4. Prove generic Daedric behavior rejection.
5. Record Survey/status clarity and stack snapshots, including deviation/curse
   legibility and Active Effects.
6. Run the Prisma surface checks, including the shared active-patron recovery beat.
   If this save is used for formal commitment proof, also record Universal U8
   accept/refuse surfaces.
7. Save/load after the snapshot and confirm Survey, Active Effects, Prisma, and
   manager state agree.
8. Run the route checker:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer --strict-manager
```

Evidence sinks:

- `references/authoring/PDV_RunSheet_Dunmer_BetaFeel.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- Papyrus log markers for the accepted Dunmer route families

Stop if: generic Daedric behavior scores, wrong-origin scores, ancestor/Reclamation
sources cannot be distinguished in Survey/status, curse/deviation stack is
illegible, Prisma surfaces are blank/forced, or save/load mutates the visible state.

### 5. Requiem Felt-Penalty Sweep

Run with Requiem active. The existing audit proves backend/readback only; this
step proves player-visible feltness.

Cases:

| Case | Expected runtime proof |
| --- | --- |
| Argonian Hist Distant | Active Effects shows Maximum Health, `player.getav Health` drops by 10, HP bar reflects lower ceiling |
| Breton Tradition Distant | Active Effects shows Maximum Health, `player.getav Health` drops by 10, HP bar reflects lower ceiling |
| Breton Excommunication | Active Effects shows Maximum Health, `player.getav Health` drops by 15, HP bar reflects lower ceiling |
| Imperial civic neglect | Remains `ResistDisease -5`; no Health drop from this effect |

For each case record:

- Origin/race and patron state used.
- Active Effects screenshot or exact observed text.
- Before/after `player.getav Health`.
- Manual HP-bar feel note.
- Confirmation that unrelated Requiem regeneration behavior is not being counted
  as the PDV penalty.

Evidence sink: append to the Requiem handoff or the current in-game testing
runbook, then summarize into the final beta gate note.

Stop if: a Health penalty does not change `player.getav Health`, the Active
Effects label is not Maximum Health for the three converted cases, Imperial loses
Health, or Requiem is not actually active.

### 6. Day-To-Day Signal Sweep

After Dunmer and Requiem, run a cross-system smoke to catch broad script
rewrite regressions.

Cover at least:

- Craft signals: 330-333.
- Book/knowledge signals: 340-345.
- Sleep signals: 313/314.
- Trespass and transgression: 361 plus 360/362/364/365/368 as applicable.
- Race-gate negative controls.
- Anti-farm cadence.
- Dawn bank and day rollover.
- Dashboard driver capture with nonzero `AwardPiety` movements.
- Gameplay Prisma/toast updates without blocking panel opens.
- Formal offer accept/refuse produces toast plus pinned Book of Days entries.
- Redguard sect champion-entry produces the sect message, matching toast, and
  non-blank Book of Days entry.
- Altmer Thalmor alignment produces the new `Where you stand... shifts` Book of
  Days line when the committed band changes.
- Shrine prayer writes one player-origin-appropriate Book of Days deity name.

Evidence sink: current broad smoke notes plus any affected race ledger rows.

Stop if: a basic gameplay event stops scoring, anti-farm allows repeat farm,
dawn bank duplicates/drops movements, a dashboard driver is missing for a nonzero
`AwardPiety`, or a gameplay event opens a blocking panel.

### 7. Prince V2 Path-Deepening Sweep

Run this after the race blockers because Daedric beta-display is currently clean
but the script rewrite window touched Prince behavior.

Cover:

- Deepen-not-initiate behavior.
- One open-path deepen marker.
- Uncommitted path does not deepen.
- Azura dual-face behavior.
- Hircine curse no-double-fire.
- Hircine renunciation uses the approved toast and pinned Book of Days line.
- Anti-farm for repeated Prince path events.

Evidence sink: Daedric runtime evidence ledger only if a required slot regresses;
otherwise record as a last-pass regression smoke note.

Stop if: an uncommitted Prince path deepens, Azura face routing flips incorrectly,
Hircine curse double-fires, or `pdv_daedric_beta_gate.mjs --json` drops below
`PASS=16` afterward.

### 8. Final Gate Rerun

After all runtime/manual evidence is recorded, rerun:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_integrity_harness.mjs
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_prisma_toast_fallback_audit.mjs
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_book_of_days_audit.mjs
node .\tools\pdv_requiem_penalty_audit.mjs
node .\tools\pdv_daedric_beta_gate.mjs --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Acceptance:

- `pdv_beta_readiness_audit --strict --json` has no `FAIL` blockers.
- Dunmer manual evidence slots are closed from actual runtime/manual proof, not
  from static checks, and Imperial remains closed on the 2026-07-04 evidence.
- Book of Days audit still passes.
- Prisma-to-1.0 audit still passes.
- Requiem proof includes Active Effects, `player.getav Health`, HP-bar feel, and
  Imperial preservation.
- Daedric beta gate still reports `PASS=16`.

Only after this final gate passes should the tester package be rebuilt.

### 9. Package Rebuild

Rebuild the tester package only from the post-gate live mod state. Then rerun the
package/readback gate that verifies live/repo sync and package contents.

Do not ship a pre-existing zip from `dist` unless its timestamp and contents are
proven to come after the final successful gate rerun.

## Final Claim Language

Allowed now:

- Static/readback gates are clean for the current Prisma-to-1.0 recovery update.
- Daedric beta-display evidence remains closed at `PASS=16`.
- Book of Days live/repo parity is clean.

Blocked now:

- Strict v1.0 beta readiness.
- Any claim that Requiem penalties are felt in-game.
- Any claim that Dunmer beta feel or strict v1.0 beta readiness is complete.
- Any final tester package claim based on the current pre-existing zip.
