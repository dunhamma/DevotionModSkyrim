# PDV Session Handoff — Spine-Parity Wrap (written 2026-06-24, for next session)

## TL;DR — where we are
The big workstream is **done**: the **ancestral-spine parity build is complete — 7/7 races at
parity** (open-item #6's core, gap #2/#3/#5). Alongside it, the **signal E2E gate reached 0 RED**,
the **verifier layer was built out** (curated-parity, specced-minus, Spine Stack Score, and a
one-command Integrity Harness), **Green Way 5/5 + all 16 prince floors landed**, and the
**18-minus triage was decided end-to-end**. What remains is **cross-cutting polish**, most of it
already specced into committed handoffs.

## What landed this session
- **Gate: 26/13 → 39 GREEN / 0 RED** (curated-signal parity PASS, 95 refs / 0 gaps / 0 cross). Got there via 2 calibrations, **13 route promotions** (evidence-backed), **5 `formKey` bug fixes** (DA05/DA02/MG08 pointed at PlacedObjects) + a formKey-drift gate check, and Green Way + Hidden Art source fills.
- **Spine parity 7/7.** Built `tools/pdv_spine_stack_score.mjs` first (gate-before-build), then worst-first built + **adversarially accepted** every target: **Nord 77 · Dunmer 80 · Orc 77 · Altmer 77 · Imperial 77 · Breton 77 · Redguard 70** (+ the 3 RICH: Bosmer 73 · Khajiit 87 · Argonian 100). `parityTargets: []`.
- **Verifier suite (all new):** curated-signal parity (in the e2e gate), `tools/pdv_specced_minus_audit.mjs`, `tools/pdv_spine_stack_score.mjs`, and `tools/pdv_integrity_harness.mjs` (one-command roll-up of all six checks).
- **Floor: 6 → 28 PASS.** Green Way 5/5 (Eldergleam quest-stage) + **all 16 prince floors** at parity + the spine builds.
- **Minus triage decided** (`PDV_MinusTriage_Decision_2026-06-24.md`): 18 unemitted curated minuses → plan to 0. Pantheon **remove 9**, Daedric **wire 3 / remove 2**, per-race **wire 4** (Tuwhacca's already wired in the Redguard build; Hist×3 remain).
- **Dead diegetic: 0** — all Nord/Orc dead notifs dispatched in their spine builds.

## Current state — canonical commands
- **`node tools/pdv_integrity_harness.mjs`** — THE single readout (gate/parity/floor/spine-score/specced-minus/completeness). Currently **PASS**.
- Gate 39 GREEN / 0 RED, parity PASS. Spine 7/7 at parity. Floor 28 PASS / 23 under-floor.
- `node tools/pdv_spine_stack_score.mjs` → `PDV_SpineStackScoreLedger.{md,csv}` (the living spine-parity data; a widget tracker handoff exists: `PDV_SpineParityWidget_Handoff_2026-06-24.md`).

## Open items / next steps (PRIORITIZED)
1. **IN-FLIGHT — accept on hand-back:** 6e renewable retrofit + Redguard margin
   (`PDV_SpineMargin_6eRetrofit_Redguard_Handoff_2026-06-24.md`). Dispatched. Lifts Nord ~83 /
   Orc ~80 / **Redguard 70 → ~77** (off the knife-edge). Accept with a **race-hardcoded** workflow.
2. **HANDED OFF — dispatch + accept (specs complete):**
   - **6c minus cleanup** → `PDV_MinusRemoval_PantheonCreed_Handoff` (remove 9) + `PDV_DaedricMinus_Wire_Handoff` (wire 3 / remove 2) + Hist×3 wiring. Target: `specced_minus` **18 → 0**.
   - **6d per-culture LD** → `PDV_PerCultureAncestralLD_Handoff` (`originGate` column + per-culture ancestor rows).
3. **NEEDS A HANDOFF (only cross-linked today, not standalone):**
   - **6f variety tranches** (Altmer/Orc/Redguard) — cross-linked to `PDV_RaceEffectReviewLedger.md` "Pending" rows; write a dedicated handoff.
   - **6g Book-of-Days bespoke voice** (Imperial/Altmer on the generic fallback) — write a dedicated handoff.
4. **THEN:** re-baseline the living burnup/progress charts to reflect spine-parity-complete; stand up the spine-parity widget from its tracker handoff.

## Next planning steps (how to run the next session)
- **Keep the cadence that worked:** dispatch one handoff → Codex builds + commits → I run the **5-refuter adversarial-acceptance workflow** (boon-unconditional · pulse-fires · ESP-boon-exists · no-regression · race-specific) → accept iff all refuters clean + compile 0/0 + verify FAIL=0.
- **Start of session:** run `pdv_integrity_harness.mjs`, accept the in-flight 6e/Redguard hand-back, then dispatch 6c + 6d.
- **Mid-session:** write + dispatch the 6f and 6g handoffs to close the cross-cutting set.
- **Definition of "spine + findings done":** harness PASS, `specced_minus` 0 unemitted, all 6a-6g sub-items dispatched + accepted, Redguard comfortably > 70.

## Gotchas (learned this session)
- **Workflow `args` don't inject reliably** — passing `args` (string OR object via scriptPath) gave `race=UNKNOWN` twice and the agents wandered. **HARDCODE race-specific values in acceptance workflow scripts** (the Dunmer/Orc hardcoded scripts worked; the Altmer/Breton parameterized ones failed). Or accept directly (compile/verify/gate/score/houseCARL) — also reliable.
- **MCP (Anvil server) liveness** — live-ESP gate columns + houseCARL are SKIP-not-PASS when down (a RED there is a liveness artifact, not an authored RED). `pdv_verify` reads the `.esp` **directly** (no MCP), so it covers the ESP layer when MCP is down. Start: Anvil.exe → MO2 Tools → Start MCP Server.
- **Repo-source drift** — `live-source/` is a junction to the canonical untracked live dir; the Grep/Glob index can surface a *more-advanced worktree* than bash sees on disk. **Trust `pdv_compile`/`pdv_verify` + git for ground truth**, not the editor index.
- **Redguard has NO substrate script** — its boon is `SyncRedguardSpineBoon` + `PDV_Bless_Redguard_Spine_*` ESP spells keyed on the sect; its renewable channel must adapt the substrate pattern, not copy it.
- **Curated Score dims drift** — registry rows are Codex-authored per build; the Score `minus_stack` is over-credited until the minus cleanup lands, and `piety_sink` had a Nord-vs-Redguard inconsistency (both 1 site, scored 3 vs 2). Re-derive deterministically in a future Score v2 if trust matters.

## Standing tools/artifacts (post-session)
| Artifact | Run |
|---|---|
| **Integrity Harness** (roll-up) | `node tools/pdv_integrity_harness.mjs` |
| Signal E2E gate (+ curated parity) | `node tools/pdv_signal_e2e_gate.mjs` |
| Signal-floor audit | `node tools/pdv_signal_floor_audit.mjs` |
| **Spine Stack Score** | `node tools/pdv_spine_stack_score.mjs` |
| **Specced-minus audit** | `node tools/pdv_specced_minus_audit.mjs` |
| Completeness / paired-equity | `node tools/pdv_completeness_audit.mjs` / `pdv_paired_equity_audit.mjs` |
| ESP-reality | houseCARL MCP (needs Anvil server up) |

Detailed open-item tracking (6a-6g sub-items, minus dispositions, cross-links) lives in
`PDV_SessionHandoff_2026-06-24.md` open-item #6 + `PDV_MinusTriage_Decision_2026-06-24.md`.
