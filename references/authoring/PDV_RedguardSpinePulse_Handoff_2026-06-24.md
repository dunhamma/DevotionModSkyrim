# PDV Redguard Ancestor-Spine Pulse — Codex Handoff (2026-06-24)

## Owner ruling (2026-06-24)
RedguardSpine acts award a **small Tu'whacca honest pulse**. (Satakal is not a built
deity — no `PDV_Deity_Satakal.psc` — so the spine pulse targets `PDV_Tuwhacca`, the
Yokudan soul-keeper of the dead/ancestors.)

## Why
`HandleRedguardAncestorSpine` (live `PDV__ManagerQuest.psc:5571`) feeds the sect-direction
track (`RecordRedguardSectSignal`) and StorageUtil counters but reaches **no piety/relation
sink**, so a Yokudan-spine source awards **0 deity piety**. This is the same
"always-active spine acts route to an inactive ledger" gap the Argonian Hist two-ledger
template closes with an honest deity pulse. The signal-E2E gate flags it:
`PDV_FLST_P2_RedguardSpineSources` is **RED** on `handler_piety_sink`
("No route handler reaches a piety/relation sink within depth 2").

Model exactly on Argonian: `HandleArgonianHistMaintenance` double-routes every act into
both the substrate metric AND `AwardCuratedSignalScaled(PDV_Hist, PDV_Hist.SIGNAL_HIST_PULSE,
None, multiplier)` (`DELTA_HIST_PULSE = 1.0`).

## Changes (Papyrus — Codex lane; do NOT touch routes/PlayerEvents/manifest)

### 1. `live-source/Scripts/Source/PDV_Deity_Tuwhacca.psc`
- **Add a signal const** in the 24xx Tu'whacca block (2401–2405 are used; **2406 is free**),
  next to `SIGNAL_DEATH_DUTY_ABANDONMENT = 2405` (~line 32):
  ```papyrus
  Int Property SIGNAL_ANCESTOR_SPINE = 2406 AutoReadOnly   ; Yokudan ancestor-spine: small honest pulse for any accepted spine act
  ```
- **Add the return delta** next to the other `DELTA_*` properties (~line 38), magnitude
  matched to Argonian's pulse:
  ```papyrus
  Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto
  ```
- **Handle it** in `ScoreCuratedSignal` (insert a branch in the existing if/elseIf chain,
  before the final `return 0.0` at ~line 63):
  ```papyrus
  elseIf signalType == SIGNAL_ANCESTOR_SPINE
      return DELTA_ANCESTOR_SPINE
  ```
  > Both the const define AND the `ScoreCuratedSignal` handle are required — the new
  > curated-signal parity check (in `tools/pdv_signal_e2e_gate.mjs`) fails closed if a
  > deity is awarded a signal it does not both define and handle (the Kyne silent-zero class).

### 2. `live-source/Scripts/Source/PDV__ManagerQuest.psc` — `HandleRedguardAncestorSpine` (~line 5571)
- After `RecordRedguardSectSignal(currentSect, multiplier, reason)` (line 5579), add the
  honest pulse, reusing the **same `multiplier`** already produced by
  `ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAncestorSpine")` (line 5576):
  ```papyrus
  AwardCuratedSignalScaled(PDV_Tuwhacca, PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE, None, multiplier)
  ```
- Reusing `multiplier` means the pulse is **daily-capped** and yields **0 on a same-day
  repeat** — identical anti-farm to Argonian. Do not add a separate cap.

## Do NOT
- Do not change route wiring (`route_branch` already PASS), `PDV_PlayerEvents.psc`, or the
  P2 manifest. Wiring is fully present; only the deity-pulse sink is missing.

## Verify (Codex, before hand-back)
1. `node tools/pdv_compile.mjs --script PDV_Deity_Tuwhacca` → 0/0
2. `node tools/pdv_compile.mjs --script PDV__ManagerQuest` → 0/0
3. `node tools/pdv_verify.mjs` → FAIL=0

## Acceptance (Claude re-checks on hand-back)
- `node tools/pdv_signal_e2e_gate.mjs` → `PDV_FLST_P2_RedguardSpineSources` flips
  **RED → GREEN** (`handler_piety_sink` PASS — `AwardCuratedSignalScaled` is a recognized sink,
  anti-farm satisfied by `ConsumeDailyRepeatMultiplier`).
- The curated-signal parity section passes for the new `SIGNAL_ANCESTOR_SPINE`
  (Tu'whacca defines + handles it).
- In-game proof (later, MCM-driven, server up): a Redguard spine act banks exactly one
  small Tu'whacca pulse per dawn cycle; same-day repeat does not double-bank.

## Note (prove on a fresh save)
`DELTA_ANCESTOR_SPINE` follows the project's `Auto`-with-default convention (mirrors
`DELTA_HIST_PULSE`). Confirm the pulse magnitude on a new game; `AutoReadOnly` consts are
compile-time literals and need no migration.

## Stretch (separate packet — do NOT bundle unless asked)
`SIGNAL_DEATH_DUTY_ABANDONMENT` (2405) is **specced but never emitted** (ancestral-spine
audit gap #4 — same silent class). Wiring its emit site is a follow-on, not part of this fix.
