# E2E Gate Extension — Curated-Signal Parity Check — Codex Handoff (2026-06-23)

**Mission:** Add a **fail-closed curated-signal parity check** to `tools/pdv_signal_e2e_gate.mjs`
(new mode/section, read-only). It permanently catches the **Kyne-pattern silent-dead signal**: a
manager call `AwardCuratedSignal[Scaled](PDV_X, PDV_X.SIGNAL_Y, …)` where the awarded deity `X`
does **not** both *define* and *handle* `SIGNAL_Y` — so `deity.ScoreCuratedSignal(...)` returns
`0.0` and the curated piety silently never fires.

**Why:** Found 2026-06-23 — `AwardNordRouteFamilySignal`'s `OLD_SKY_ROAD` branch was missing AND
`PDV_Deity_Kyne` had no curated-signal support, so curated NordKyneTalos sources awarded zero Kyne
piety while *looking* wired. Fixed (`f8c3451`). A manual 71-reference cross-check then confirmed no
other gaps — but "confirmed by a one-off grep" is exactly the false-complete trap. This makes it a
permanent gate.

## The check (deterministic static analysis — encode this exact algorithm)

1. **Extract every curated-signal reference** in `live-source/Scripts/Source/PDV__ManagerQuest.psc`
   (and any other script that calls these — grep the tree for `AwardCuratedSignal`): match
   `AwardCuratedSignal(Scaled)?\(\s*(PDV_[A-Za-z]+)\s*,\s*(PDV_[A-Za-z]+)\.(SIGNAL_[A-Za-z_]+)`.
   Capture `awarded` (arg1), `owner` (arg2), `signal`.
2. **Resolve the awarded deity's script:** `PDV_<name>` → `PDV_Deity_<name>.psc` (e.g. `PDV_Kyne`
   → `PDV_Deity_Kyne.psc`, `PDV_AuriEl` → `PDV_Deity_AuriEl.psc`, `PDV_Tuwhacca` →
   `PDV_Deity_Tuwhacca.psc`). If the script is missing → **GAP** (`missing-script`).
3. **Assert the awarded deity defines AND handles the signal:**
   - *defines:* the script contains `Property <signal> =` (the const declaration).
   - *handles:* the script contains `== <signal>` (word-bounded) inside `ScoreCuratedSignal` (a
     conditional that returns a delta). Missing either → **GAP** (`unimplemented-signal`).
   - Note the award routes through **arg1** `.ScoreCuratedSignal(arg2's value)`. If `awarded !=
     owner` (cross-deity), flag **CROSS** and verify against the *awarded* deity's script, not the
     owner's — a cross-deity reference is suspicious by default.
4. **Flag `AwardCuratedSignalByIndex` non-debug call sites** (raw int signalType can't be resolved
   statically) as `manual-review`, NOT pass. (Today the only one is `DebugAwardCuratedSignalByIndex`
   — fine; any *new* production use must be reviewed.)
5. **Exit code 1 if any GAP/CROSS** (fail-closed). Emit the findings into the gate ledger under a
   `curated-signal-parity` section.

This is **pure static analysis — no game, no server, always runs.**

## Acceptance (prove it works, both directions)

- On the current tree: **PASS, 0 gaps** (71 references, all implemented — Kyne fixed). Confirm the
  count matches (`~71` unique references) so the extractor isn't silently dropping call sites.
- **Self-test it actually fires:** temporarily point one reference at a non-existent signal (or run
  against a fixture) and confirm the check reports the GAP + exits 1. Document the self-test; do not
  ship a checker that can only ever say PASS.

## Hand-back

Updated `tools/pdv_signal_e2e_gate.mjs` with the `curated-signal-parity` section + a ledger block,
the reference count, and a note on the self-test. Claude reviews against the manual 71-ref result.

## Model / files
- **Sonnet** (deterministic static analysis; no game). Plain ES-module JS.
- Edit: `tools/pdv_signal_e2e_gate.mjs`; reads `live-source/Scripts/Source/PDV__ManagerQuest.psc` +
  `PDV_Deity_*.psc`. Reference for the algorithm: this doc + commit `f8c3451` (the Kyne fix).
