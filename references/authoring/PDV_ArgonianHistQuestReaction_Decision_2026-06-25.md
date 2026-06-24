# Decision: Argonian Hist/People quest-reaction absence (2026-06-25)

**Status:** BY-DESIGN *for now* — **explicitly open to reinterrogation** via alternative methods.
This is a "note for now," not a closed verdict.

## The observation
The signal-floor audit reports `quest-reaction` wired on **49 of 51** paths; the only two without
it are `argonian_hist` and `argonian_people` (`PDV_SignalFloorRegistry.csv` rows for the Hist/People
layers).

## Mechanical root cause (hard-confirmed from files)
- `quest-reaction` = the vanilla-quest → deity milestone matrix (`PDV_QuestReactionMatrix_Full.csv`).
  The audit (`tools/pdv_signal_floor_audit.mjs` ~L374-382) marks a path wired **iff ≥1 matrix cell's
  `deity` equals the path's deity** — a pure deity-name lookup.
- Both `argonian_hist` and `argonian_people` credit deity **"The Hist"** (the registry note on
  `argonian_people` says it outright: *"buffers Hist; no separate deity"*).
- Direct counts in the matrix: **"The Hist" = 0 cells**, **"People" = 0 cells**, **Sithis = 16
  cells** (which is why the sibling `argonian_void` path *is* wired — the 51st distinction).
- There is no `PDV_Deity` record for "the People" (deity list has Hist + Sithis only).

## Why this is currently judged by-design
- `argonian_people` has no deity lane at all — it can never hold its own matrix cell; credit routes
  to The Hist by design.
- The Hist is a **substrate-led, environment/behaviour-expressed** patron (a Kyne-class / data-table
  deity — see [[rich-daytoday-deities-missing-curated-milestone-piety]]). Its worship is recorded on
  `PDV_Substrate_ArgonianHist` (Hist-maintenance, near/sacred water, bed-of-choice, sanctuary,
  Eldergleam-class quest-*stage* routes), not via vanilla-quest *completion*.
- Vanilla Skyrim has effectively **no Black Marsh / Hist quest content** to map, and the Hist has no
  pantheon aspect-pairing to inherit shared credit from (unlike Kyne/Kynareth, Arkay/Tu'whacca).

## Important: by-design for quest-reaction ≠ floor-complete
Do NOT read "quest-reaction is by-design absent" as "these paths are fine." The signal-floor audit
flags BOTH as **under-floor on source-type breadth** (distinct axis from the spine *score*):
- `argonian_hist`: **HIGH**, wired 3/5 types, renewable 1/2 (short 2 types, short 1 renewable).
- `argonian_people`: **CRITICAL**, wired 2/5 types, renewable 1/2 (short 3 types, short 1 renewable).
(The spine *score* — the always-active ancestral richness — is a separate metric where Argonian is
100%.) So these two are part of the **23 under-floor race-paths** (pre-1.0 enrichment work). Because
quest-reaction is by-design unavailable here, the floor shortfall must be cleared via **other** source
types — env/behavioural signals (location / sleep / weather / harvest), the deferred-signal class in
[[green-way-signals-deferred-by-semantic-pass]] — not the vanilla-quest matrix.

## OPEN — reinterrogate via alternative methods (do NOT treat as closed)
If revisited, consider whether the Hist *should* receive milestone-style credit through a method
other than the literal vanilla-quest matrix, e.g.:
1. **Env/behavioural "quest-reaction equivalent"** — treat Hist-themed location/quest-stage beats
   (Eldergleam, marsh sanctuaries, Hist-sap finds) as milestone credit, so the dim isn't tied to
   vanilla quest records.
2. **Paired / shared credit** — a thematically-adjacent vanilla quest (nature/wild → Kyne/Yffre)
   could grant a small Hist echo for Argonian-origin players (paired-deity equity precedent).
3. **Curated PDV quest-stage source** — author a dedicated Hist milestone off a PDV quest stage
   rather than the vanilla matrix.
4. **Audit-side disposition** — decide whether to formally waive these two as expected-N/A vs. add a
   real source; today they are neither waived nor sourced, just observed.

## Verification caveat
The adversarial-verification workflow for this verdict did **not** complete — it hit the shared
session limit (resets ~5pm Australia/Sydney). The mechanical facts above are hard-confirmed; the
"no apt vanilla quest exists" judgment is the part that should get a second, independent pass when
subagents are available again.
