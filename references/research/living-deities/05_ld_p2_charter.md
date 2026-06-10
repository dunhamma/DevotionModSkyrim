# LD-P2 -- Living Deities Phase 2: Charter

**Status:** DRAFT design dossier, 2026-06-10. Forward-design layer on top of the
LD-P1 engine slice authored in `research/living-deities/src/` (Block B). No
Papyrus/CK/ESP changes are made by this dossier -- it is spec + feasibility only,
in the same honesty discipline as `03_feasibility.md` (source-traced, no in-game
proof). Names are the contract; line numbers drift.

> **Scope reminder (inherited from LD-P1):** the Living Deities engine is forward
> work, NOT the mod's release V1. LD-P2 presumes LD-P1 is built AND runtime-proven
> first (see "Dependency on LD-P1" below) -- it is the second engine build phase,
> not a parallel one.

## 1. What LD-P2 adds (the four deferred mechanisms)

LD-P1 shipped the scalar-EWMA engine MVP and explicitly parked four richer pieces.
LD-P2 owns exactly those four, confirmed against the LD-P1 docs:

1. **Materialized decaying mood modifiers.** A small per-deity ring buffer of named,
   time-limited `{cause, delta, day}` entries that decay independently and sum into
   the mood band alongside the scalar EWMA. Gives omens/journal a diegetic "why"
   ("your mercy at the gate still pleases Stendarr") and an audit trail. Deferred
   from LD-P1 by owner ruling A.4 (`DECISIONS_PENDING.md`; `02_mood_model.md` "Optional
   Tier-2 enrichment").
2. **Expectation-red demand triggers.** A second demand-offer trigger: a sustained-low
   expectation signal (the patron has been under-fed for N days relative to its
   cadence), not only the LD-P1 band-down-cross. LD-P1's `IsEligibleForDemandOffer`
   fires only on `PDV.Mood.DownCrossPending`; the architecture notes flag
   "expectation-red joins in LD-P2" inline at that gate.
3. **A second demand type per deity.** LD-P1 binds each deity to one `demandKey.<Deity>`
   (a single JSON scalar). LD-P2 lets a deity carry a small ordered set of demand
   definitions, chosen by trigger + recent history, so Kyne (or Hircine) can ask
   different things on different occasions.
4. **Richer `PDV_DiegeticDirector` omen modalities.** LD-P1 omens ride toast + dream
   only. LD-P2 routes mood/demand omens through the EXISTING `PDV_DiegeticDirector`
   (live: `PDV_DiegeticDirector.psc`) so a band-cross can also tint the screen, play a
   sound cue, set a body-mark, or append a journal line -- the modalities the director
   already scaffolds but LD-P1 left on the toast/dream channel.

**Confirmation against the docs.** The prompt's stated scope matches what LD-P1
deferred, with ONE correction surfaced by this pass: LD-P1's docs repeatedly call the
DiegeticDirector "specced but not built" / "pending that director being built"
(`03_feasibility.md` Spike 4; `04_living_deities_architecture.md` 3.7). That is stale
-- the director **exists in live source today** as a wired, `D1Enabled`-gated scaffold
(see `05_ld_p2_feasibility.md`). Mechanism (4) is therefore recomposition, not
greenfield, and is cheaper than the LD-P1 framing implied.

## 2. Why each piece was deferred from LD-P1

| Mechanism | Why deferred (LD-P1 reasoning) |
|---|---|
| Materialized modifiers | The scalar EWMA alone is sufficient to make mood read as "alive"; the ring buffer is pure enrichment (cause attribution + audit), so it was cut to keep the MVP to "1 float + 1 int per deity" (`02_mood_model.md` cost summary). Owner ratified A.4. |
| Expectation-red demands | LD-P1 needed exactly ONE demand trigger to prove the offer/fulfill/expire loop. Band-down-cross was the simplest correct trigger that reuses existing crossing dispatch. A second trigger is additive and only meaningful once the first loop is runtime-proven. |
| Second demand type | One demand type proves the binding-and-fulfillment contract end to end. A roster of demands per deity is content breadth, not a new mechanism, so it waits until the single-demand path is proven not to double-fire / mis-reset. |
| Rich director modalities | LD-P1 deliberately rode the lowest-risk channels (toast + dream) so mood could ship without depending on the diegetic-UX surface (IMOD/shader/journal/OAR), which carries soft external deps (Description Framework, DBF, OAR) the LD-P1 docs treat as a separate hardening track. |

## 3. Dependency on LD-P1 being proven

LD-P2 is **gated on LD-P1 being runtime-proven**, not merely authored. Specific
preconditions, each an LD-P1 "in-game proof still required" item that must close first:

- **Mood persistence + band-on-cross fire-once** (Spike 1 proof items). Materialized
  modifiers and expectation-red both re-enter `OnMoodBandCross` / `ApplyMoodDelta`; if
  the LD-P1 crossing dispatch is not proven fire-once, LD-P2 multiplies the bug.
- **Demand offer/fulfill/expire loop proven once** (Spike 3 proof items). The second
  demand type and expectation-red trigger reuse `OfferDemand` / `FulfillDemand` /
  `ApplyDemandExpiry` verbatim; they must be proven single-active + single-reset first.
- **Faucet-breadth runtime proof** (the `2e665b7` hybrid-faucet 313/343 receivers,
  runtime-pending per `04_living_deities_architecture.md` 3.2). Expectation-red reads
  "how fed has this deity been," which is only meaningful once the non-combat faucet is
  confirmed live; otherwise expectation-red mis-fires on Kyne for lack of input.
- **Hircine curse-gate correctness** (Spike 0 proof items). The Hircine second demand
  type and any director body-mark must respect the curse gate already proven in LD-P1.

If LD-P1's smoke run has not closed those items, LD-P2 must not start: it would build
on unproven dispatch.

## 4. Scope boundaries -- what stays LD-P3 / backlog

LD-P2 is still engine, not content sprawl. Explicitly OUT of LD-P2:

- **Any new external hard dependency.** LD-P2 stays Vanilla/PO3 + the already-present
  optional Prisma/OAR/Description-Framework/DBF soft deps. It does not add a new master.
- **The full diegetic-UX content pass.** LD-P2 routes mood/demand events INTO the
  existing director and authors the omen-profile tone/journal rows for the pilot
  deities only. Building out the director's external-API calls (actual DF medallion
  writes, DBF journal appends, OAR prayer poses) is the director's own hardening track,
  not LD-P2's; LD-P2 consumes the director where it is already functional (IMOD/shader/
  sound/body-mark/StorageUtil caching) and degrades cleanly where it is not.
- **The future buckets** (`04_future_buckets_backlog.md`): theophany/avatar encounters,
  holy days, inter-deity alliances, schism, sacrifice economy, congregation, prophecy
  chains, relic resonance, divine climate, afterlife stakes, voiced theophany. All
  remain backlog, sequenced after LD-P2.
- **The Dominance/Dread second axis** and **world-state ambient omen layer** (M1
  surfaced extras): explicitly Backlog/LD-P3 candidates, not LD-P2.
- **Public `PDV_ModMood` patch API**: stays parked (decision B.7).
- **Demand chains / branching arcs** (backlog bucket 8): LD-P2 ships independent
  demands, never multi-stage gated arcs.

## 5. Pilot scope for LD-P2

Same pilot as LD-P1 -- **Kyne + curse-gated Hircine** -- so LD-P2 adds depth to proven
deities rather than breadth to unproven ones. Each pilot deity gains: one materialized-
modifier source wired to its existing fulfillment/expiry events; an expectation-red
trigger tuned to its alpha cadence; a second demand definition; and director routing
for its mood-up/mood-down/demand omens. No new deity actor is introduced in LD-P2 (the
one greenfield actor, `PDV_Deity_Hircine`, was LD-P1's).

## 6. Open decisions for the human owner

Carried into `05_ld_p2_feasibility.md` and `05_ld_p2_architecture.md`; listed here for
the owner:

1. **Modifier-vs-scalar weighting** -- do materialized modifiers REPLACE part of the
   scalar EWMA's swing, or sit purely additive on top of it? (Additive is simpler but
   can over-swing the band; see architecture 2.1.)
2. **Expectation-red threshold** -- days-under-fed before a red trigger, per deity, and
   whether it suppresses while a demand is already pending.
3. **Second-demand selection rule** -- round-robin, weighted-by-trigger, or
   history-avoiding? (Architecture 3.2 proposes trigger-keyed.)
4. **Director enablement** -- LD-P2 assumes `D1Enabled` may still be False at ship; is
   the owner content with mood omens routing to the director's StorageUtil-cached /
   toast-fallback path until the director's own hardening track flips `D1Enabled`?
