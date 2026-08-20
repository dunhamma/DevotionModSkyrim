# PDV 2.0 -- ORIGIN adapter-split plan (base + 10 race adapters)

STATUS: LIVING (authored 2026-08-19). Design plan for STAGE 2 of the ORIGIN extraction: turning
the flat `PDV_OriginRuntimeBase` monolith (664 fns, produced by the overnight pure move) into the
intended polymorphic shape. SUPERVISED work -- this is design + refactor, NOT a mechanical move.
Do this BEFORE the provider seam and BEFORE any ORIGIN ESP wiring.

---

## 1. Why (the intent the flat move skipped)

Decomposition plan (PDV_2.0_Branch_Cleanup_and_Decomposition_Plan.md:64): ORIGIN =
`PDV_OriginRuntimeBase` + **ten race adapters**; the manager selects one adapter by birth race and
**contains no race switchboard**. This is the codebase's established polymorphic pattern:
`PDV_DeityBase` <- 34 deity subclasses; `PDV_DaedricPathBase` <- 16 path subclasses. ORIGIN is the
one module that is inherently polymorphic-by-race, so it needs this shape (LEDGER/FAVOR/etc. are
genuinely single-runtime and correctly stayed single-script).

The flat move relocated the race switchboard into one new script (664 fns, 0 subclasses) -- a
verified, reversible intermediate, but the exact thing the plan says not to end at.

## 2. Target shape

- `PDV_OriginRuntimeBase extends Quest` -- ABSTRACT BASE. Holds: the `Manager` backref; the shared
  non-race infra (the ~56 tranche-6 fns: broad-lane/tier/standing, curse-summary/context,
  substrate pacing, Talos, medallion, survey, rest-cell); and the VIRTUAL METHOD SURFACE the
  manager dispatches on (default/no-op bodies).
- `PDV_OriginRuntime_<Race> extends PDV_OriginRuntimeBase` x10 (Altmer, Bosmer, Khajiit, Argonian,
  Breton, Redguard, Nord, Dunmer, Orc, Imperial). Each holds its lane's functions (from the
  matching tranche) and OVERRIDES the virtuals it implements.
- Manager: at init, select the adapter for the player's birth race and fill a single base-typed
  `PDV_OriginRuntimeBase Property OriginRuntime Auto` with that adapter instance (birth race is
  fixed per playthrough, so single selection beats per-call lookup). All existing
  `OriginRuntime.X()` calls then dispatch polymorphically. (A `PDV_FLST_OriginAdapters` FormList
  keyed by race index is the fallback if per-call selection is ever needed -- mirrors
  `PDV_FLST_AllDeities`.)

## 3. The hard part -- this is NOT a pure move (interface design)

The flat move preserved the manager calling ~SPECIFIC functions via `OriginRuntime.X` (73 external
+ 134 manager self-calls to named race functions). Polymorphic dispatch requires those cross-
boundary calls to resolve against methods DECLARED ON THE BASE. Two ways, and choosing is the
design work:

- **(A) Generic virtual interface (preferred, true to the pattern).** Collapse the specific cross-
  boundary calls into a SMALL set of generic virtuals on the base -- the way the manager calls
  `deity.ScoreAction(...)`, not `deity.KyneSpecificThing()`. Each race adapter implements them;
  race-internal helpers stay bare within the adapter. This is real interface design: inventory the
  cross-boundary call surface, define the generic verbs (e.g. `SetupOrigin`, `HandleContextualSignal`,
  `ApplyRites`, `GetSurveyFragment`, `SyncRaceRewards`, `OnPatronStart/End`), and remap call sites.
  Bodies change at the boundary (a real diff, needs its own parity/behavior check) -- NOT qualification-only.
- **(B) Declare-every-crossed-fn-on-the-base (mechanical but ugly).** Every cross-boundary race fn
  gets a base virtual (default no-op) + one adapter override. Preserves call sites verbatim but
  bloats the base with ~100+ virtual stubs and keeps a de-facto switchboard in the interface. Use
  only if (A) proves too large to land safely.

Recommend (A). It is the point of the pattern; (B) is a fallback that mostly re-hides the problem.

## 4. Function distribution (already 90% done by the tranches)

The overnight tranches grouped fns by race lane, so the mapping is direct:
- t1 Altmer (heritage/crisis/Thalmor/Trinimac/Syrabane/Auri-El/Xarxes/Magnus) -> `_Altmer`;
  t1 Bosmer (Green Pact/naming/path/Yffre/Zen/BaanDar) -> `_Bosmer`.
- t2 Khajiit -> `_Khajiit`; t2 Argonian -> `_Argonian`.
- t3 Breton -> `_Breton`; t3 Redguard -> `_Redguard`.
- t4 Nord (+Kyne) -> `_Nord`; t4 Dunmer -> `_Dunmer`.
- t5 Orc -> `_Orc`; t5 Imperial -> `_Imperial`.
- t6 non-race infra + Talos -> stays in the BASE.
Cross-lane shared helpers a race adapter calls (living in the base) become bare `Parent`/base calls
or stay base-resident; identify them per adapter during the split.

## 5. Interaction with the provider seam (design them together)

The 3 deferred gain-multipliers land as: `GetOrcLifeModeGainMultiplier` -> `_Orc` adapter,
`GetImperialCurseGainMultiplier` -> `_Imperial` adapter, `GetCurseGainMultiplier` -> cross-race
(base, or DAEDRIC/curse-state). So the ADR provider that LEDGER's `Providers[]` calls must reach
functions spread across adapters + base. Simplest: the **base** (`PDV_OriginRuntimeBase`) is the
single `PDV_GainModifierProvider`, and its `GetProviderGainMultiplier(deity, phase)` dispatches to
whichever adapter/own-body owns the factor for the active race. Decide this WHEN designing the
interface (Section 3), so the provider verb is one of the base virtuals.

## 6. Sequencing + verification

1. Design the base virtual interface (Section 3A). 2. Create the 10 adapter scripts; move each
lane's fns from `PDV_OriginRuntimeBase` into its adapter. 3. Remap the manager's cross-boundary
calls to the generic virtuals; wire birth-race adapter selection. 4. Build the provider seam on the
same interface (Section 5). 5. THEN ESP wiring: 10 adapter host QUSTs (each extends the base) + the
race-selection fill (or the `PDV_FLST_OriginAdapters` FormList), replacing the single-monolith host.

Verification: the lane fns still reconstruct against `origin_golden.json` (bodies unchanged by the
move between scripts); the interface-collapse call-site changes (Section 3) are the one part needing
a fresh behavior review, not just qualification parity. Compile 0/0 + a runtime smoke per race
(the manager picks the right adapter, its virtuals fire).

## 7. Effort + call

This is the largest remaining ORIGIN task and the most design-heavy -- comparable to the ADR work,
not to a tranche move. It should NOT be run unattended. The flat move is a fine, verified foundation
(no rework wasted; fns are already lane-grouped). Recommendation: do the adapter split as a
dedicated supervised session, design the interface (3A) + provider verb (5) together, and hold ORIGIN
wiring until it lands so the monolith shape is never wired.
