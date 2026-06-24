# Specced-Minus Triage — Decision Record (2026-06-24)

**Context:** `tools/pdv_specced_minus_audit.mjs` found **18** curated-signal minuses that a deity
DEFINES + HANDLES (a `ScoreCuratedSignal` branch returns a negative delta) but which **nothing
ever EMITS** — penalties that can never fire (the declared-but-never-emitted class). Source:
`PDV_SpeccedMinusLedger.md`. This records the disposition decided with the owner.

## Two penalty channels (why "remove" is not uniform)
A deity's felt downside comes from TWO independent mechanisms:
1. **Curated-signal minuses** — `SIGNAL_*` with a negative `DELTA_*`, fired by an
   `AwardCuratedSignal` emit (milestone-style). These 18 have no emit.
2. **LD-table dislikes** — day-to-day negative `baseDelta` rows in `PDV_DeityLikesDislikes.csv`.
   A SEPARATE channel that fires on routine actions; unaffected by the curated-signal removal.

So removing a dead curated spec only zeroes a deity's downside if it ALSO has no LD dislikes.

## Disposition of all 18 (by class)
### A. Per-race spine minuses → wire on the spine pulse (NOT removed)
- `PDV_Deity_Hist`: HIST_ABANDONMENT (−4), HIST_CORRUPTION (−8), VOID_OVERREACH (−6) → Argonian spine.
- `PDV_Deity_Tuwhacca`: DEATH_DUTY_ABANDONMENT (−3) → Redguard spine (pulse already landed; wire the minus on the abandonment act).

### B. Daedric minuses → triage with the Daedric / Orc pass (NOT removed)
- `PDV_Deity_Boethiah` TREACHERY (−3), `PDV_Deity_Mephala` SECRET_BETRAYED (−3),
  `PDV_Deity_Malacath` SELF_ERASURE/BROKEN_FAITH_KIN/CURSE_CODE_RUPTURE (−3/−2/−2) → Orc spine + Daedric pass.

### C. Pantheon-creed minuses → **REMOVE the dead specs** (the decision)
9 signals on Arkay/Magnus/Stendarr/Trinimac/Xarxes. **None has any EMITTED curated minus.**
Whether removal leaves the deity penalty-free depends on its LD dislikes:

| Deity | dead curated specs (removed) | LD dislikes (kept) | Net after removal |
|---|---|---|---|
| **Arkay** | CREED_CIVIC_COMPROMISE, CREED_DEATH_DUTY_ABANDONED | **4** | Keeps a working penalty layer |
| **Stendarr** | CREED_CIVIC_COMPROMISE, CREED_ENFORCER_CRUELTY | **6** | Keeps a working penalty layer |
| **Magnus** | ARTS_PROFANED, KNOWLEDGE_DESTROYED | 0 | **Pure-positive** (decay/neglect only) |
| **Trinimac** | APOSTASY | 0 | **Pure-positive** |
| **Xarxes** | RECORD_FALSIFIED, LINEAGE_REPUDIATED | 0 | **Pure-positive** |

## Decision + why
- **Arkay & Stendarr → remove the dead curated specs.** Pure cleanup: they retain 4 and 6
  working day-to-day dislikes, so they keep a real downside. The removed milestone-penalties
  never fired and added nothing.
- **Magnus, Trinimac, Xarxes → accept PURE-POSITIVE** (remove the dead specs; add no penalty).
  **Why:** their creed-violation has **no representing action in the game** — there is no
  "destroy knowledge" / "falsify a record" / "apostatize" event to hook, through EITHER the
  curated OR the LD-dislike channel. That missing trigger is exactly why they were never wired
  and have no dislikes. For low-conflict scholarly/honor deities, piety **decay/neglect when
  ignored is a sufficient soft downside**; inventing a forced proxy would be lore-arbitrary.

## Reversal path (if this is revisited)
If a future content pass adds an in-game action that genuinely represents one of these
violations (e.g. a book-burning/desecration event), re-add the `SIGNAL_*` + `DELTA_*` +
`ScoreCuratedSignal` branch (or an LD dislike row) and wire the emit at that action. The
specced-minus audit will then count it as emitted. Nothing about removing the dead spec now
forecloses that — it just stops shipping a penalty that provably cannot fire.

## Implementation
Removal handed to Codex: `PDV_MinusRemoval_PantheonCreed_Handoff_2026-06-24.md`. Parallel-safe
(these 5 deities are not touched by the spine builds). After: `pdv_specced_minus_audit` drops
18 → 9 unemitted; `pdv_signal_e2e_gate` parity stays PASS.
