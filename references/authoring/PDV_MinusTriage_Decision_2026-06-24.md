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

### B. Daedric minuses → RESOLVED 2026-06-24 (wire 3, remove 2)
All 3 deities have working LD dislikes (Boethiah 3, Mephala 3, Malacath 4) -- none goes
penalty-free either way. Unlike the pantheon-creed class, several of these DO have a real
in-game trigger. Handoff: `PDV_DaedricMinus_Wire_Handoff_2026-06-24.md`.
- **WIRE** (real trigger exists; fold into the Orc/Daedric builds):
  - `PDV_Deity_Malacath` `CURSE_CODE_RUPTURE` (-2) -> on **werewolf onset** (lycanthropy is a Code violation; clean, lore-perfect trigger).
  - `PDV_Deity_Mephala` `SECRET_BETRAYED` (-3) -> on a **clumsy crime / bounty-gain / caught-in-the-act** (the opposite of Mephala's subtlety).
  - `PDV_Deity_Malacath` `BROKEN_FAITH_KIN` (-2) -> on **deserting sworn service / betraying the kin-faction** (if a clean hook exists, else hold).
- **REMOVE** (no clean event; the deity keeps its working LD dislikes):
  - `PDV_Deity_Boethiah` `TREACHERY` (-3 = cowardice/fleeing the test); `PDV_Deity_Malacath` `SELF_ERASURE` (-3 = swallowing an insult).

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

## Implementation outcome (2026-06-25, commit 4fd2b68) — specced_minus 18 → 0, DONE
All three classes executed in one pass (Claude solo, Codex out): removed the 9 pantheon-creed
(A: Arkay/Magnus/Stendarr/Trinimac/Xarxes) + the 2 no-trigger Daedric (Boethiah TREACHERY,
Malacath SELF_ERASURE); wired the 3 Daedric (Malacath CURSE_CODE_RUPTURE on werewolf onset via
`ApplyOrcCurseHandlers`; Mephala SECRET_BETRAYED on caught crime via ActionRouter trespass/assault,
Dunmer+Mephala-focus gated; Malacath BROKEN_FAITH_KIN on Legion-Exile desertion via
`ApplyOrcLifeModeSwitch`) + the 3 Hist (HIST_ABANDONMENT/CORRUPTION/VOID_OVERREACH on the Argonian
posture model); Tu'whacca DEATH_DUTY_ABANDONMENT was already wired by the 6e Redguard build. Final:
`pdv_specced_minus_audit` CLEAN 16/16 wired, harness PASS.

**FLAGGED FOR REVIEW — `BROKEN_FAITH_KIN` hook choice.** The handoff specified "follower-abandon /
faction-leave, else HOLD." No clean vanilla event exists for that, so it was wired to a deliberate
player switch AWAY from Legion-Exile (the Orc sworn-service life mode), excluding the passive 14-day
dawn lapse-to-City (which bypasses `ApplyOrcLifeModeSwitch`). This is a defensible reading of
"deserted sworn service" but is BEYOND the handoff's literal trigger — owner/Codex should confirm it
stands or retune. Reversible: drop the one call site in `ApplyOrcLifeModeSwitch` to HOLD it instead.

## REGRESSION caught + reverting (2026-06-29) -- specced_minus 0 -> 11, re-delete handoff issued
Commit `d6e9f43f` "Close Papyrus cleanup parity gaps" (2026-06-25) **re-added the exact 11 specs this
decision removed** -- a pure-additive parity sweep (7 deity files, 44 insertions, 0 deletions, still no
emit sites). `pdv_specced_minus_audit` is back to 11 UNEMITTED (the 9 pantheon-creed + Boethiah
`TREACHERY` + Malacath `SELF_ERASURE`). This is a regression of a closed item, NOT new content.

Coverage re-verified 2026-06-29 against the live CSVs: every affected deity still carries act-based
LD dislikes (Arkay 4, Stendarr 6, Magnus 2, Trinimac 5, Xarxes 3, Boethiah 3+2, Malacath 4+4) plus
decay/neglect -- so re-deletion stays penalty-safe. Correction to section C above: Magnus/Trinimac/Xarxes are
**no longer pure-positive** (a later LD-enrichment pass gave them 2/5/3 dislikes); the removal is even
safer than originally assessed. Disposition: **re-delete the 11** (not wire) -- they remain dead specs
with no in-game trigger. Handoff: `PDV_MinusReDelete_Regression_Handoff_2026-06-29.md`.
