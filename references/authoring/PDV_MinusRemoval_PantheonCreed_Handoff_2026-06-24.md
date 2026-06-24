# Remove 9 Dead Pantheon-Creed Minus Specs (Codex Handoff, 2026-06-24)

## Decision (logged)
Per `PDV_MinusTriage_Decision_2026-06-24.md`: the 9 pantheon-creed curated-signal minuses are
specced but **never emitted** and have **no in-game action to trigger them**. Arkay/Stendarr
keep their working LD dislikes (4 and 6); Magnus/Trinimac/Xarxes become pure-positive (decay is
the soft downside). **Remove the dead specs.**

## Parallel-safe
These 5 deity scripts are **not** touched by the spine builds (Shor/Azura/AuriEl/Malacath), so
this can run alongside the spine queue. Low-risk mechanical deletion.

## Remove (the const + its DELTA + its ScoreCuratedSignal branch), per deity
| Script | Remove these signals |
|---|---|
| `PDV_Deity_Arkay.psc` | `SIGNAL_CREED_CIVIC_COMPROMISE`, `SIGNAL_CREED_DEATH_DUTY_ABANDONED` |
| `PDV_Deity_Magnus.psc` | `SIGNAL_ARTS_PROFANED`, `SIGNAL_KNOWLEDGE_DESTROYED` |
| `PDV_Deity_Stendarr.psc` | `SIGNAL_CREED_CIVIC_COMPROMISE`, `SIGNAL_CREED_ENFORCER_CRUELTY` |
| `PDV_Deity_Trinimac.psc` | `SIGNAL_APOSTASY` |
| `PDV_Deity_Xarxes.psc` | `SIGNAL_RECORD_FALSIFIED`, `SIGNAL_LINEAGE_REPUDIATED` |

For each: delete the `Int Property SIGNAL_X = ... AutoReadOnly` line, the matching
`Float Property DELTA_X = ... Auto` line, and the `elseIf signalType == SIGNAL_X / return DELTA_X`
branch in that script's `ScoreCuratedSignal`.

## SAFE-DELETE precondition (do per signal before removing)
`grep -rn "SIGNAL_X" live-source/Scripts/Source/` — it MUST appear **only** in its own deity
script (the define + the ScoreCuratedSignal branch). If anything outside that script references
it, STOP and flag (it's not actually dead). The specced-minus audit confirmed zero emit sites,
but confirm zero references too before deleting.

## Do NOT remove (these are NOT in this decision)
The per-race spine minuses (Hist×3, Tuwhacca) and Daedric minuses (Boethiah, Mephala, Malacath)
stay — they get **wired** in their spine/Daedric builds, not removed.

## Verify
- `node tools/pdv_compile.mjs` for each of the 5 edited scripts → 0/0; `node tools/pdv_verify.mjs` → FAIL=0.
- `node tools/pdv_specced_minus_audit.mjs` → unemitted **18 → 9** (the 9 pantheon ones gone; the
  remaining 9 are the spine/Daedric ones intentionally kept).
- `node tools/pdv_signal_e2e_gate.mjs` → still 0 RED, curated-signal parity PASS (removing
  never-emitted signals cannot break any emit site).
