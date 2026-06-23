# Harden the Signal-Floor Audit to Live-ESP Truth — Codex Handoff (2026-06-23)

**Mission:** Upgrade `tools/pdv_signal_floor_audit.mjs` so its "populated" reflects **live-ESP
reality**, not the manifest's declared status, and so breadth (designed) and truth (wired) are never
conflated again. Small, surgical change — do not restructure the working audit.

**Why:** The floor audit currently counts a `book`/`quest-stage` type as present whenever the manifest
declares it in `sourceFillEntries` or a route exists. But a route can be `approved-static-route-only`
(never fills) and a FormList shell can be empty in the live ESP. So the audit can over-credit a path
as having a type it doesn't actually fire. This handoff makes the count honest.

## Changes

1. **Live-ESP cross-check for source-types.** A `book` or `quest-stage` type counts ONLY when the
   live ESP FormList actually contains a matching record. Reuse the end-to-end gate's ESP read (or
   the P2 author `--check-source-fill` output) rather than reading the ESP independently. When the
   server is down, mark the ESP-dependent portion `UNKNOWN-server-down` and fall back to the manifest
   value with an explicit `designed-only` flag on that cell — never silently treat designed as wired.
2. **`quest-stage` route-truth.** Count `quest-stage` only when the path's route `reviewStatus`
   contains `approved-live-source-fill` (not `approved-static-route-only`).
3. **New `wired_end_to_end` column** in `PDV_SignalFloorLedger.{md,csv}`, distinct from the existing
   `designed` count: `wired_end_to_end` = the count of types whose surface is GREEN in the
   `PDV_SignalE2EGateLedger` (consume it if present; else compute the ESP-verified subset). Keep
   `designed` for comparison. The PASS/UNDER-FLOOR verdict moves to `wired_end_to_end` once the gate
   ledger exists; `designed` becomes informational.

## Acceptance

- The ledger shows both `designed` and `wired_end_to_end`; for paths with empty ESP shells
  (Green Way, Argonian People/Void, Redguard sects, the 8 Imperial civic lanes), `wired_end_to_end <
  designed`. Nord Old Ways' `quest-stage` drops out of `wired_end_to_end` (its MQ104/MQ304 routes are
  static-only). No path's `wired_end_to_end` exceeds its `designed`.
- With the server down, the run completes (no crash), ESP-dependent cells flagged `designed-only`.

## Hand-back

Updated `tools/pdv_signal_floor_audit.mjs` + regenerated ledger showing the two columns + a one-line
note on the designed-vs-wired distinction. Claude reviews against the e2e gate ledger.

## Model / cost
Surgical edit → **Sonnet** or Codex. Depends on HANDOFF-GATE (consumes its ESP read / ledger);
sequence GATE first.

## Files
- Edit: `tools/pdv_signal_floor_audit.mjs`; regenerate `references/authoring/PDV_SignalFloorLedger.{md,csv}`
- Depends on: `tools/pdv_signal_e2e_gate.mjs` (HANDOFF-GATE), `references/authoring/PDV_SignalE2EGateLedger.csv`
