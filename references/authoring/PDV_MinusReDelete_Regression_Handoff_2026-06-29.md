# Re-Delete 11 Regressed Specced-Minus Specs (Codex Handoff, 2026-06-29)

## Why (regression, not new work)
The 2026-06-24 triage took `pdv_specced_minus_audit` from **18 -> 0** (commit `4fd2b683`):
9 pantheon-creed + 2 no-trigger Daedric minuses were removed as dead specs; 7 others were wired.
Commit **`d6e9f43f` "Close Papyrus cleanup parity gaps"** (2026-06-25) then **re-added the exact
11 removed specs** -- a pure-additive parity sweep (7 deity files, 44 insertions, 0 deletions, no
emit sites). The audit is back to **11 UNEMITTED**. This handoff reverts that regression.

Decision basis: `PDV_MinusTriage_Decision_2026-06-24.md` (Class C pantheon-creed + the 2 Class B
no-trigger Daedric). Coverage re-verified 2026-06-29 (see "Coverage" below) -- removal is safe.

## Scope: this is the inverse of `d6e9f43f`'s deity-file hunks
`git show d6e9f43f -- live-source/Scripts/Source/PDV_Deity_*.psc` is the authoritative add-list;
remove exactly those lines. **Do NOT `git revert` the whole commit** -- it also carries unrelated
parity fixes that must stay. Remove only the per-signal triads below.

## Remove (per deity: the `Int Property SIGNAL_*`, its `Float Property DELTA_*`, and its `elseIf` branch in `ScoreCuratedSignal`)

| Script | Signals to remove |
|---|---|
| `PDV_Deity_Arkay.psc` | `SIGNAL_CREED_CIVIC_COMPROMISE` (1210), `SIGNAL_CREED_DEATH_DUTY_ABANDONED` (1211) |
| `PDV_Deity_Boethiah.psc` | `SIGNAL_TREACHERY` (2004) |
| `PDV_Deity_Magnus.psc` | `SIGNAL_ARTS_PROFANED` (1805), `SIGNAL_KNOWLEDGE_DESTROYED` (1806) |
| `PDV_Deity_Malacath.psc` | `SIGNAL_SELF_ERASURE` (2250) **ONLY** |
| `PDV_Deity_Stendarr.psc` | `SIGNAL_CREED_CIVIC_COMPROMISE` (1310), `SIGNAL_CREED_ENFORCER_CRUELTY` (1311) |
| `PDV_Deity_Trinimac.psc` | `SIGNAL_APOSTASY` (2303) |
| `PDV_Deity_Xarxes.psc` | `SIGNAL_RECORD_FALSIFIED` (1905), `SIGNAL_LINEAGE_REPUDIATED` (1906) |

For each signal, delete all three of its lines:
- `Int Property SIGNAL_X = <id> AutoReadOnly`
- `Float Property DELTA_X = <neg> Auto`
- the `    elseIf signalType == SIGNAL_X` + `        return DELTA_X` pair in that script's `ScoreCuratedSignal`.

## Do NOT touch (these stay -- they are WIRED, not regressed)
- Malacath: `OATH_BREAK`, `CURSE_CODE_RUPTURE`, `BROKEN_FAITH_KIN` (all have live emits).
- Boethiah: `RECLAMATION_ABANDONED` (wired).
- All 16 currently-emitted minuses in `PDV_SpeccedMinusLedger.md`.

## Safe-delete precondition (already verified 2026-06-29; re-confirm before each delete)
`grep -rn "SIGNAL_X" live-source/Scripts/Source/` must show the signal ONLY inside its own deity
script (the define + the `ScoreCuratedSignal` branch -- no emit site). Verified clean for all 11.
NOTE: `SIGNAL_CREED_CIVIC_COMPROMISE` appears in BOTH Arkay and Stendarr -- this is fine, each
script defines its OWN constant (IDs 1210 vs 1310); they are independent, not a cross-reference.

## Coverage -- why removing all 11 is penalty-safe (verified 2026-06-29 vs live CSVs)
The 11 are curated **milestone** signals that never emitted (never fired). Every affected deity
keeps a real, live negative through the two independent channels that DO fire:

| Deity | Act-based LD dislikes (live) | Other wired curated neg | Net downside w/o the 11 |
|---|---|---|---|
| Arkay | 4 (raise-undead, murder-defenseless, assault-innocent, daedric-artifact) | - | dislikes + decay/neglect |
| Stendarr | 6 | - | dislikes + decay/neglect |
| Magnus | 2 | - | dislikes + decay/neglect |
| Trinimac | 5 | - | dislikes + decay/neglect |
| Xarxes | 3 | - | dislikes + decay/neglect |
| Boethiah | 3 + 2 (main + Princes table) | RECLAMATION_ABANDONED | curated + dislikes + decay |
| Malacath | 4 + 4 | OATH_BREAK / CURSE_CODE_RUPTURE / BROKEN_FAITH_KIN | curated + dislikes + decay |

Two distinct penalty mechanisms remain fully intact (neither depends on the 11):
1. Passive neglect/decay -- `ApplyDecayToDeity` lowers the piety number after a lapse + a flat
   felt neglect debuff spell (`SyncXNeglectSpell`). Inaction-driven, at dawn.
2. Dislikes -- a disliked action routes through `PDV_EventBus.RouteAction` ->
   `deity.ScoreAction` (negative `PDV.LD.<evt>.D`) -> `AwardPiety(deity, delta)`. Action-driven.

(Note: the 2026-06-24 decision doc called Magnus/Trinimac/Xarxes "pure-positive, 0 dislikes" -- a
later LD-enrichment pass gave them 2/5/3 dislikes, so they are now act-penalty-covered too. The
removal is even safer than the original decision assumed.)

## Parallel/serialize
**Parallel-safe** relative to manager/EventBus work: all edits are confined to the 7 deity scripts,
no manager/hook changes. Serialize ONLY against any other in-flight task editing these same 7
deity `.psc` files. Low-risk mechanical deletion.

## Verify
- `node tools/pdv_compile.mjs` for each of the 7 edited scripts -> 0/0.
- `node tools/pdv_verify.mjs` -> FAIL=0.
- `node tools/pdv_specced_minus_audit.mjs` -> **11 -> 0 UNEMITTED**, CLEAN 16/16 wired.
- `node tools/pdv_signal_e2e_gate.mjs` -> 0 RED, curated-signal parity PASS
  (removing never-emitted signals cannot break any emit site).
