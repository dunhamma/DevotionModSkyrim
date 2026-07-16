# PDV Daedric Surfacing Adversarial Acceptance (2026-06-25)

Scope: D2 residuals from `PDV_HO_DaedricSurfacing_2026-06-25.md`, accepted after the Codex implementation in commit `3153d8e`.

Proof boundary: this is machine/readback and static adversarial acceptance only. It does not prove in-game Book-of-Days display, Ledger rendering, Survey player observation, save/load behavior, or manual feel.

> **Superseded in part 2026-07-16.** The pre-pact thresholds/copy proven below describe the ORIGINAL implementation. As of 2026-07-16 the pre-pact notice fires at piety **20** (not half-Seeker/12.5); the single beat is *"<Prince> has taken notice of you."* + a toast + the "watching" badge (the ">0 has taken an interest" onset and the "The world tilts toward <Prince>" pressure beat were removed and consolidated onto the source-agnostic `UpdatePrePactNoticeState` seam); and Daedric quest reactions stay out of Book of Days until the Prince reaches Seeker (25). The R1/R3 rows below are retained as a historical record of the pre-2026-07-16 code.

## Refuter Pass

Accepted with the same post-build shape used for recent Claude hand-backs: five targeted refuters plus compile, verifier, and harness gates.

| Refuter | Verdict | Evidence |
|---|---|---|
| R1 pre-pact queue/reset | PASS | `PDV_DaedricPathBase.UpdatePrePactNoticeState` uses `ThresholdSeeker * 0.5`, queues `PDV.Daedric.PendingPrePactNotices` with duplicate prevention, and resets `PDV.Daedric.PrePactNoticeShown` on pact tier or below-threshold piety. |
| R2 top-only Ledger watching | PASS | `GetTopPrePactDaedricPath` returns none during an active pact, filters tier-none paths, selects max stored piety, and `GetDashboardJson` appends the path with system tag `watching`. |
| R3 Book-only pre-pact, Survey silent | PASS | `ProcessPendingDaedricPrePactNotices` appends `The world tilts toward <Prince>.` with tone `daedric.pressure`; `GetSurveyDevotionText` still only short-circuits for an active pact and has no pre-pact fallback. |
| R4 first-activation journal guard | PASS | `ProcessPendingDaedricActivation` logs `<Prince> claims your devotion.` only when `HasRecentDaedricMilestoneJournal` is false; milestone presentation stamps `PDV.Daedric.LastMilestoneJournalPath` and `PDV.Daedric.LastMilestoneJournalTime`. |
| R5 driver/no-regression prerequisite | PASS | `SetStoredPiety` records `PDV.Driver.*` through `RecordDaedricPathDriver`, and `ApplyQuestReactionPiety` still routes through `AwardPiety`. |

## Gate Results

Run from `C:\Users\Admin\Documents\Devotion Mod Project` on the live Anvil Devotion source/profile.

| Gate | Result |
|---|---|
| `node .\tools\pdv_mcp_check.mjs` | OK, profile `Devotion Dev` |
| `node .\tools\pdv_ascii_guard.mjs` | OK, 89 `.psc` files ASCII-clean |
| `node .\tools\pdv_compile.mjs --script PDV_DaedricPathBase.psc` | PASS, 0 errors / 0 warnings |
| `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest.psc` | PASS, 0 errors / 0 warnings |
| `node .\tools\pdv_verify.mjs` | `FAIL=0`, `WARN=3`, `PASS=3497` |
| `node .\tools\pdv_signal_e2e_gate.mjs` | PASS, 39 GREEN / 0 RED, curated-signal parity PASS |
| `node .\tools\pdv_specced_minus_audit.mjs` | CLEAN, 16 wired / 0 unemitted |
| `node .\tools\pdv_spine_stack_score.mjs` | PASS, no parity targets, no dead declarations |
| `node .\tools\pdv_signal_floor_audit.mjs` | PASS, 51 paths PASS / 0 UNDER-FLOOR |
| `node .\tools\pdv_ledger_coverage_audit.mjs` | CLEAN, Daedric stored-piety driver hook YES |
| `node .\tools\pdv_integrity_harness.mjs` | PASS, gate 39 GREEN / 0 RED; parity PASS |

## Acceptance

D2 residuals are accepted at the machine/readback layer. Remaining proof belongs to the runtime/manual bucket: observe a pre-pact Book-of-Days entry, confirm the Ledger `watching` branch in UI, confirm Survey remains silent before pact, and confirm first-pact activation does not double-log when a milestone entry fires in the same tick.
