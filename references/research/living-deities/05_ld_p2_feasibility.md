# LD-P2 -- Feasibility Assessment (the four deferred mechanisms)

**Status:** DRAFT, 2026-06-10. Source-traced against the **live** tree
(`D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`) and the **authored
LD-P1 Block B slice** (`research/living-deities/src/`). Matches the honesty bar of
`03_feasibility.md`: **there is no Creation Kit and no Skyrim runtime in this session,
so nothing below is QASmoke/in-game proof.** Every seam is traced to a real function
NAME (names are the contract; line numbers drift). Each mechanism ends with the
specific in-CK/in-game proof STILL required.

> **Headline:** all four LD-P2 mechanisms are **recomposition of code that already
> exists** -- either in the LD-P1 slice or in live source. The one correction this pass
> forces on the LD-P1 docs: **`PDV_DiegeticDirector` is NOT unbuilt.** It ships in live
> source as a wired, `D1Enabled`-gated scaffold with every modality LD-P2 wants. So the
> LD-P1 framing ("pending that director being built") overstated mechanism (4)'s cost.
> Net: LD-P2 carries **zero greenfield actors and no new external dependency** -- only
> new StorageUtil keys, new manager functions, and authoring rows.

---

## Grounding seams confirmed this pass (live + LD-P1 slice)

| Seam (NAME is the contract) | Where | Used by LD-P2 mechanism |
|---|---|---|
| `RunDawnUpdateMoodForDeity(deity, clampedToday)` | LD-P1 slice | 1 (modifier summation), 2 |
| `ComputeMoodBand(deity, moodValue)` | LD-P1 slice | 1 (band must read scalar + modifiers) |
| `ApplyMoodDelta(deity, delta, reason)` | LD-P1 slice | 1 (modifier write path) |
| `IsEligibleForDemandOffer(deity, nowTime)` | LD-P1 slice | 2 (expectation-red 2nd trigger) |
| `OfferDemand` / `FulfillDemand` / `ApplyDemandExpiry` | LD-P1 slice | 2, 3 (reused verbatim) |
| `demandKey.<DeityName>` JSON scalar | LD-P1 slice (`OfferDemand`) | 3 (becomes a list) |
| `RunDawnApplySpellAndNeglectLayers` + `PDV.Neglect.*` + `PDV.LastEventGameTime` | live `PDV__ManagerQuest.psc` | 2 (expectation = under-fed signal) |
| `SurfaceTransition(eventClass, surfaceKey, direction, deityIndex, toneOverride)` | live `PDV__ManagerQuest.psc:1119` -> `PDV_DiegeticDirectorService.Dispatch(...)` | 4 |
| `PDV_DiegeticDirector.Dispatch(...)` + `EmitScreen/EmitSound/EmitJournal/SetBodyMark/EmitPrayerAnim` | live `PDV_DiegeticDirector.psc` | 4 |
| `SendPrismaEventToast(eventName, deity, context, tierLabel, rival)` | live `PDV__ManagerQuest.psc:1057` | 4 (fallback channel) |
| `LIVING_DEITIES_FILE` JSON + `pdv_living_deities_compile.mjs` + self-test | LD-P1 slice / tools | 1,2,3 (data-driven config) |

---

## Mechanism 1 -- Materialized decaying mood modifiers - confidence HIGH - recomposition

- **Live/LD-P1 seam it builds on:** the scalar mood lives at StorageUtil key
  `PDV.Mood` (per deity form), written by `RunDawnUpdateMoodForDeity` and
  `ApplyMoodDelta`; bands are computed by `ComputeMoodBand`. The ring buffer is a
  PARALLEL StorageUtil layer (`PDV.MoodMod.*`) summed into an *effective* mood that
  `ComputeMoodBand` reads, leaving the EWMA scalar untouched.
- **Why HIGH:** no new tick, no new event. Modifiers are written at the exact points
  that already exist (`FulfillDemand` -> a "+pleased" modifier; `ApplyDemandExpiry` ->
  a "-displeasure" modifier; a curated milestone via `ApplyDeityReaction`). They decay
  per dawn inside the SAME `RunDawnUpdateMoodForDeity` loop that already runs per deity.
  The rotating-buffer pattern is named in `02_mood_model.md` "Optional Tier-2
  enrichment" and was costed there.
- **Recomposition vs greenfield:** recomposition. New code is a bounded fixed-size
  StorageUtil ring (no JContainers needed -- N is small, e.g. 4 slots * `{cause,delta,
  expireDay}`), plus a `GetEffectiveMood(deity)` helper that the band computation calls.
- **Open design risk (owner decision):** additive-on-top-of-scalar can push the band
  past where the scalar alone would sit (double-counting the same act, since the act
  also moved the EWMA). Mitigation options in `05_ld_p2_architecture.md` 2.1.
- **In-CK/in-game proof STILL required:** (1) a modifier decays to zero on schedule and
  is pruned from the ring; (2) effective-mood band matches scalar+modifier sum after a
  seeded sequence; (3) buffer is bounded -- oldest entry evicted, no unbounded
  StorageUtil growth across save/load; (4) cause string survives save/load for journal
  attribution; (5) no double band-cross fire when both scalar and a modifier cross in
  the same dawn.

## Mechanism 2 -- Expectation-red demand trigger - confidence MED-HIGH - recomposition

- **Live/LD-P1 seam it builds on:** LD-P1's `IsEligibleForDemandOffer` currently gates
  on `PDV.Mood.DownCrossPending == 1` AND band `<= MOOD_BAND_COOL`. The slice's own
  comment at that gate reads "expectation-red joins in LD-P2." Expectation itself is
  derivable TODAY from two live sources: (a) `PDV.LastEventGameTime` (written per deity
  in `RunDawnConsolidateScratch`) gives days-since-last-positive-act; (b) the live
  neglect machinery -- `RunDawnApplySpellAndNeglectLayers`, `ApplyGenericNeglectFlags`,
  `IsNeglectFlagActive(deity)`, `PDV.Neglect.*` -- already computes "this patron has
  been under-fed." Expectation-red = a deity whose days-since-last-act exceeds an
  authored cadence threshold (scaled by its alpha), even with NO band cross.
- **Why MED-HIGH not HIGH:** the trigger logic is trivial recomposition, but its
  MEANING depends on the **faucet-breadth runtime proof** still pending
  (`2e665b7` 313/343 receivers). Until the non-combat faucet is confirmed live,
  "under-fed" is over-true for Kyne (she only registers kills, which she penalizes), so
  expectation-red would mis-fire. It is feasible to BUILD now; it is not safe to TUNE
  until that smoke closes. That dependency, not the code, is why this is not HIGH.
- **Recomposition vs greenfield:** recomposition. New code is an added branch in
  `IsEligibleForDemandOffer` (`... OR IsExpectationRed(deity, nowTime)`) plus a small
  `IsExpectationRed` reading `PDV.LastEventGameTime` / neglect flags against an authored
  per-deity `expectationDecayRate` / `expectationRedDays`.
- **In-CK/in-game proof STILL required:** (1) expectation-red fires once when a fed-then-
  starved patron crosses its cadence threshold WITHOUT a band cross; (2) it does NOT
  fire while a demand is already pending (suppression); (3) it respects the
  `DEMAND_OFFER_COOLDOWN_DAYS` cooldown shared with the band-cross trigger; (4) on the
  Kyne case specifically, it does NOT chronically fire once the broadened faucet is
  runtime-proven (the tuning-gate dependency).

## Mechanism 3 -- Second demand type per deity - confidence HIGH - recomposition

- **Live/LD-P1 seam it builds on:** `OfferDemand` reads a single scalar
  `demandKey.<DeityName>` from `LIVING_DEITIES_FILE`, then reads `demand.<key>.*` fields
  (windowDays, eventTypesCsv, eventFilter, questMatrixTag, label) and writes them to the
  per-deity `PDV.Demand.*` cache. Fulfillment (`NotifyDemandFaucetSignal`,
  `NotifyDemandQuestTag`) reads ONLY that cache, so it is already demand-instance-keyed,
  not demand-type-keyed. Supporting two demand types per deity needs ONLY a selection
  step before `OfferDemand` writes the cache -- the offer/fulfill/expire machinery is
  unchanged.
- **Why HIGH:** the entire fulfillment path is already parameterized by the cached
  binding, not by a hard-coded key. The single demand was a config limit
  (`demandKey.<Deity>` = one string), not an architectural one.
- **Recomposition vs greenfield:** recomposition. New code: `demandKeys.<DeityName>` JSON
  becomes a pipe-list; a `SelectDemandKey(deity, trigger)` chooses one (the LD-P1
  scalar path is the 1-element case). The existing CSV/JSON compiler
  (`pdv_living_deities_compile.mjs`) and `PDV_DemandTable.csv` gain rows, not columns
  (or one column; see architecture 3.2).
- **In-CK/in-game proof STILL required:** (1) two demand definitions for one deity each
  offer correctly and write distinct `PDV.Demand.*` caches; (2) only ONE demand active
  per deity at a time (the single-active invariant LD-P1 proves is not broken by the
  selection step); (3) fulfillment matches the CURRENTLY-cached binding, not a stale one
  from the other demand type; (4) self-test still passes binding-integrity for every row.

## Mechanism 4 -- Rich DiegeticDirector omen modalities - confidence HIGH (routing) / MED (full UX) - recomposition

- **CORRECTION to the LD-P1 docs (the load-bearing finding):** `03_feasibility.md`
  Spike 4 and `04_living_deities_architecture.md` 3.7 say the rich director is "specced
  but not built" / "pending that director being built." **This is stale.**
  `PDV_DiegeticDirector.psc` **exists in live source** with:
  - a complete entry point `Dispatch(String eventClass, String surfaceKey, String
    direction, Int deityIndex, String toneOverride)`;
  - modality emitters `EmitScreen` (IMOD `ApplyCrossFade` + shader spell), `EmitSound`
    (`Sound.Play`), `EmitMusicForClass`/`EmitMusicState`, `EmitJournal`, `SetBodyMark`,
    `EmitPrayerAnim`, `RefreshMedallion`;
  - a tone profiler `GetProfileTone(eventClass, direction, ...)` and per-race journal/
    medallion text (`ResolveKhajiitJournalLine`, `BuildDunmerMedallionText`, etc.);
  - and it is ALREADY WIRED into the manager: `PDV_DiegeticDirectorService` property,
    `SurfaceTransition(...)` -> `Dispatch(...)` (live `PDV__ManagerQuest.psc:1119`), and
    the neglect path already calls `SurfaceTransition("neglect", ..., "drop", ...,
    "absence")` (live `:4019`).
- **What is genuinely deferred (the honest cost):** the director is gated by
  `Bool Property D1Enabled = False` -- when False, `Dispatch` records
  `PDV.Diegetic.LastSkipped` and returns. AND the external-API leaf calls are
  intentionally stubbed pending CK/source verification: Description Framework medallion
  writes (`RefreshMedallion` caches `DFPending`), DBF journal appends (`EmitJournal`
  caches `PendingDBF`/`DBFPending`), and OAR poses (`EmitPrayerAnim` is "data-only/no-op"
  until a V2 submod). The IMOD/shader/sound/music/body-mark paths require their CK
  records (`PDV_IMAD_*`, `PDV_Abil_Shader_*`, `PDV_SND_*`, `PDV_MUS_CurseBed`) to exist
  and be property-wired.
- **So LD-P2 mechanism (4) = routing, not building.** LD-P2's job is to call
  `SurfaceTransition("mood", deity.DeityName, "up"/"down", deity.DeityIndex, tone)` and
  `SurfaceTransition("demand", ...)` from `OnMoodBandCross` / `OfferDemand` /
  `FulfillDemand` / `ApplyDemandExpiry` -- alongside the existing toast -- plus add
  `"mood"`/`"demand"` arms to `GetProfileTone` and the omen-profile journal rows. The
  director then emits whatever modalities its CK records + `D1Enabled` support, and
  StorageUtil-caches the rest. This is why routing is HIGH and full-UX is MED: the
  routing is pure recomposition; the visible richness is bounded by the director's own
  separate hardening track (CK records + `D1Enabled` flip + DF/DBF/OAR verification),
  which is NOT LD-P2 scope (charter 4).
- **Recomposition vs greenfield:** recomposition. New code is a handful of
  `SurfaceTransition` calls + two `GetProfileTone` arms. No new modality code.
- **In-CK/in-game proof STILL required:** (1) a mood band-cross routes through
  `Dispatch` and records the expected `PDV.Diegetic.LastDispatch`/`LastTone` even while
  `D1Enabled` is False (cache path); (2) with `D1Enabled` True and CK records present,
  the IMOD/sound/body-mark fire once per cross, not per dawn; (3) toast fallback still
  fires when the director skips (no double-surface and no dropped surface); (4) demand
  omens degrade cleanly (Debug.Notification) when both Prisma and director are inert.

---

## Feasibility verdict table

| LD-P2 mechanism | In-repo / live precedent | Confidence | Recomposition vs greenfield |
|---|---|:-:|:-:|
| 1 -- Materialized decaying modifiers | `RunDawnUpdateMoodForDeity` + `ApplyMoodDelta` + `ComputeMoodBand` (LD-P1) | HIGH | recomposition (new StorageUtil ring) |
| 2 -- Expectation-red demand trigger | `IsEligibleForDemandOffer` (LD-P1) + neglect machinery + `PDV.LastEventGameTime` (live) | MED-HIGH | recomposition (faucet-breadth tuning dep) |
| 3 -- Second demand type per deity | `OfferDemand` cache + `demandKey.<Deity>` JSON (LD-P1) | HIGH | recomposition (config: scalar -> list) |
| 4 -- Rich director modalities | `PDV_DiegeticDirector.Dispatch` + `SurfaceTransition` (LIVE, scaffolded) | HIGH (routing) / MED (full UX) | recomposition (routing only) |

**Conclusion.** LD-P2 is buildable as **pure recomposition with zero new actors and no
new hard dependency.** The only correction it forces on the LD-P1 record is that the
DiegeticDirector already exists -- mechanism (4) was over-costed. The two real
constraints are not infeasibility but *gating*: mechanism 2 cannot be TUNED until the
LD-P1 faucet-breadth smoke closes, and mechanism 4's visible richness is bounded by the
director's own `D1Enabled` + CK-record hardening track (out of LD-P2 scope). All
remaining unknowns are runtime-verification items appropriate for an in-CK/in-game proof
session, listed per mechanism above.
