# PDV V3 Preflight Smoke Checklist

Purpose: run one clean-start in-game smoke pass that closes the V3 Preflight exit gate after strict verifier is clean.

Source alignment:
- `PDV_Architecture_v3.md` (V3 Preflight exit gate)
- `AGENTS.md` (toolchain and current runtime wiring)

---

## 1) Preconditions (do before launch)

- `Devotion Dev` profile selected in MO2.
- `PlayerDevotion_Framework.esp` active.
- `PDV_PreflightRouterServicesOverlay.esp` inactive (framework-owned EventBus/EventTypes wiring is now in the framework ESP).
- Strict verifier is clean:
  - `node .\tools\pdv_verify.mjs --strict-preflight --json`
  - Expect `FAIL=0`.

Optional but recommended:
- Start from desktop, then launch the game fresh (avoid resuming a long-lived session).
- Keep Papyrus logging enabled for this run.

---

## 2) Test Session Setup (clean-start)

1. Launch game from MO2 `Devotion Dev`.
2. From main menu, start a new game path for testing (preferred quick path: `coc qasmoke` from main-menu load context if you use that workflow).
3. Wait for initialization to settle (no rapid menu spam in first few seconds).
4. Open MCM and confirm `PlayerDevotion` appears.

Pass criteria:
- No crash on load/start.
- MCM menu opens and both `Status` and `Debug` pages load.

---

## 3) Gate Checks (execute in order)

### A. Origin Seed + Baseline State

Action:
- On MCM `Status`, record:
  - `Active patron`
  - `Patron state`
  - `Origin diagnostic`
  - Active mirrors (`Active piety`, `Active tier`, `Active deity index`)

Pass criteria:
- Origin diagnostic is present and sane for chosen race.
- No impossible null-state mismatch (for example, active patron text with invalid active index).

### B. Patron State Transitions

Action:
1. Use `Debug patron override` on a selected deity.
2. Confirm `Status` updates to active patron state.
3. Use `Clear patron override`.
4. If your current build exposes broad-worship control in your harness, trigger it and verify broad state.

Pass criteria:
- Transition to `Active` works.
- Transition back from debug override works.
- No stale mirrors after transitions.

### C. Dawn Pipeline Integrity

Action:
1. Select a deity.
2. Set `Target scratch` to a non-zero value.
3. Apply target scratch.
4. Run `Run dawn pass`.
5. Re-check roster/status values.

Pass criteria:
- Scratch piety consolidates into stored piety through dawn.
- Tier updates are consistent with thresholds.
- No negative or out-of-range mirror anomalies.

### D. EventBus Canary Behavior (direct-player kill route preserved)

Action:
- Execute one direct-player hostile kill and one non-direct/non-hostile case you can produce reliably.
- Re-check piety deltas in MCM and (if needed) Papyrus traces.

Pass criteria:
- Direct hostile kill path produces expected scoring behavior.
- Non-direct attribution remains non-scoring in Preflight.
- No routing errors or missing-service behavior in logs.

### E. Talos/Auri-El Rivalry Through Dawn

Action (recommended via MCM curated signal controls):
1. Select Talos (or Auri-El) and apply curated rivalry-relevant signals.
2. Run dawn pass.
3. Check both deity ledgers and active-state behavior.

Pass criteria:
- Rivalry-linked adjustments still occur correctly.
- Dawn consolidation does not break rivalry outcomes.

### F. Save/Load Sanity

Action:
1. Create a save at a known state.
2. Reload that save.
3. Re-open MCM status and verify state consistency.

Pass criteria:
- No state loss/regression across save/load.

---

## 4) Evidence Capture

Capture at minimum:
- One screenshot each of:
  - `Status` page baseline
  - `Debug` page before dawn run
  - `Status` page after dawn run
- Short note of each action and observed result.
- Relevant Papyrus trace snippets for any unexpected behavior.

---

## 5) Run Log Template (copy/paste)

```text
PDV V3 Preflight Smoke Run
Date:
Tester:
MO2 Profile:
Build/ESP timestamp:

Preconditions
- strict-preflight verify result:
- overlay active/inactive state:

Session setup
- clean-start method:
- MCM loaded (Y/N):
- crash-free start (Y/N):

Gate A - Origin/Baseline
- active patron:
- patron state:
- origin diagnostic:
- result: PASS/FAIL

Gate B - Patron transitions
- override to active:
- clear override:
- broad state check (if available):
- result: PASS/FAIL

Gate C - Dawn pipeline
- scratch before:
- stored before:
- run dawn:
- scratch after:
- stored after:
- tier after:
- result: PASS/FAIL

Gate D - EventBus canary
- direct hostile kill observed effect:
- non-direct/non-hostile observed effect:
- result: PASS/FAIL

Gate E - Talos/Auri-El rivalry
- setup:
- post-dawn outcome:
- result: PASS/FAIL

Gate F - Save/load sanity
- save created:
- reload result:
- state consistency:
- result: PASS/FAIL

Overall
- V3 Preflight smoke: PASS/FAIL
- blockers:
- follow-up actions:
```

---

## 6) Exit Decision Rule

Mark V3 Preflight smoke complete only when:
- all gate checks above are PASS, and
- strict preflight verifier remains `FAIL=0` after any test-driven edits.

