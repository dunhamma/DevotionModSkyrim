# PDV 2.0 -- ADR: Gain-Pipeline Contract (GainModifier provider seam)

Status: ADR -- DECIDED 2026-08-18. This record fixes the decision; the extraction and
the batched houseCARL/ESP session it unblocks are downstream work tracked elsewhere.

Supersedes the "decision pending" state of `PDV_2_0_GainPipelineContract_DesignBrief.md`
(that brief remains the analysis of record; this ADR is the ruling on it). Resolves the
15 `Sec 4A gain-pipeline seam` entries in `PDV_2_0RegionMap.json -> needsAdjudication`.

Code claims below trace to `live-source/Scripts/Source/PDV__ManagerQuest.psc`,
`PDV_DeityBase.psc`, `PDV_Origin.psc`, `PDV_DaedricPathBase.psc`, and `PDV_ActionRouter.psc`
at the `feature/v3-big-update` worktree HEAD as of the decision date. Line numbers drift;
re-derive before relying on one.

---

## 1. Context (one paragraph)

In the 2.0 decomposition, the single piety write path (`AwardPiety` /
`AwardPietyFromLikesDislikes` / `AwardPietyInternal` / `RunGainPipeline` / `ProcessDawn`)
is assigned to LEDGER, which extracts BEFORE ORIGIN and DAEDRIC. But the gain path
multiplies earned piety by per-module scalars whose STATE is owned by ORIGIN (curse,
orc-life-mode, imperial-curse) and DAEDRIC (stigma). ORIGIN and DAEDRIC are ALSO downward
callers of `AwardPietyInternal` (they are signal sources). That is a real dependency
CYCLE, not a one-way seam. This ADR fixes the contract that turns the cycle into a one-way
pull so LEDGER can extract mechanically.

The full coupling map, cardinality facts, and option analysis are in the design brief and
are not repeated here. This ADR records only the decisions.

---

## 2. Decision summary

1. **Inversion model: Option A** -- a provider registration list. A shared base script
   `PDV_GainModifierProvider` exposes a virtual multiplier function; ORIGIN and DAEDRIC
   override it; LEDGER holds a base-typed array and never names the concrete modules.
   (Fallback to Option C remains open if a blocking reason surfaces during build -- see 3.)
2. **Phase model:** one function `GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)`,
   asked TWICE -- once with `PHASE_PER_EVENT` inside `RunGainPipeline` (pre-cap), once with
   `PHASE_AT_DAWN` inside `ProcessDawn` (post-cap). The daily-cap clamp sits between the two
   call sites, so cap ordering is guaranteed structurally.
3. **Cycle-break:** LEDGER holds `PDV_GainModifierProvider[]` (base type only) and never
   references `PDV_Origin` or the DAEDRIC runtime concrete type. The shared `PDV_DeityBase`
   coupling is deliberately LEFT INTACT (it is the common base, not a module cycle).
4. **Hot-path guard:** three-layer fail-OPEN. A missing/None array, a None slot, or an
   unoverridden base all resolve to x1.0. Never x0.0, never a None-call throw.
5. **Registration:** CK array-fill on the LEDGER quest record in the batched houseCARL
   session (same mechanism as the FAVOR `Manager` backref). The module host IS the
   provider. NOT runtime self-registration.
6. **Dead-code removal:** DROP `GetReputationGainMultiplier` and
   `GetReputationGainMultiplierNoop` (dead -- track factor already folded into
   `GetEffectiveGainMultiplier`). INLINE the two misnamed live wrappers
   `GetCurseGainMultiplierNoop` / `GetDaedricStigmaGainMultiplierNoop` into their real
   targets at extraction (the "Noop" name lies -- they are pass-throughs, not no-ops).
7. **Lane invariant (provider contract clause):** a provider gates on BOTH the `deity`
   param AND player state, and returns 1.0 for any deity outside its lane. No provider may
   scale a gain for a deity it does not own.

---

## 3. Decision 1 -- Option A over C (and why C stays a live fallback)

**Chosen: Option A (provider registration list).** Both A and C were confirmed feasible
against the live code. C is mechanically cheaper (the manager already holds
`PDV_CurseState Property PDV_CurseStateService Auto`, and the `Manager` backref pattern is
live on ~10 module scripts). A was chosen anyway because C's price is that economy
orchestration moves BACK into `PDV__ManagerQuest` -- a 3000+ line god-object whose
break-up is the entire purpose of the 2.0 decomposition. C re-thickens exactly the object
the rebuild exists to thin. A pushes the multiplier logic OUT to the modules that own the
state, keeps the manager thin, and makes the pipeline parity-testable with a fake provider
array.

**Evidence that A is feasible (not theoretical):**

- A's mechanism -- virtual override dispatched through a base-typed reference drawn from a
  collection -- is ALREADY the load-bearing pattern on the sibling hot path.
  `PDV_DeityBase.ScoreAction` is overridden by ~40 deity subclasses and called via
  `PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase` -> `deity.ScoreAction(...)`
  (`PDV_ActionRouter.psc:504-506`; same cast pattern in `PDV_EventBus` and
  `PDV_DiegeticDirector`). The provider array is the same shape.
- A CK-filled array of a form type already ships: `Quest[] Property RivalDeities Auto`
  (`PDV_DeityBase.psc:62`). The provider-array fill has direct precedent.

**Two amendments to the brief that the grilling surfaced (both binding):**

- **The brief's "one-line `extends` change on each module host" is FALSE for DAEDRIC.**
  `PDV_DaedricPathBase extends PDV_DeityBase` (`PDV_DaedricPathBase.psc:10`) -- Papyrus is
  single-inheritance, so its one slot is spent; it CANNOT take a second parent. The DAEDRIC
  gain provider must therefore be the (freshly authored) DAEDRIC runtime host, which can
  extend `PDV_GainModifierProvider` cleanly -- **NEVER `PDV_DaedricPathBase`**. ORIGIN is
  fine: `PDV_Origin extends Quest` (`PDV_Origin.psc:20`), so it adopts
  `extends PDV_GainModifierProvider` (which itself extends Quest) with no collision and
  stays IS-A Quest transitively.
- **The provider function must NOT reuse the name `GetGainMultiplier`.** `PDV_DeityBase`
  already declares `Float Function GetGainMultiplier(Int stance)` (`PDV_DeityBase.psc:362`).
  A same-named provider function on a different base compiles, but the clash is a trap in a
  subsystem that is half deity-base. The provider function is named
  `GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)`.

**Fallback clause.** Option A is locked, but if the build discovers a blocking reason (e.g.
the base-script `extends` change proves infeasible on a module host we have not yet
inspected, or CK typed-array fill misbehaves), fall back to Option C -- thin manager
broker `Float Function GetCombinedGainMultiplier(PDV_DeityBase deity, Int phase)` reached
through LEDGER's existing `Manager` backref. Option B (push into StorageUtil) is REJECTED
outright: caching a value trivially derivable from live state reintroduces the "one data
item, two backends" drift the project forbids, and would mis-scale across a mid-game race
reset (see 8).

---

## 4. Decision 2 -- Phase model

The economy applies gain multipliers at TWO sites separated by the daily-cap clamp:

- **Site A -- per-event, pre-cap** (`RunGainPipeline`, called by `AwardPietyInternal`):
  fires once per scored deed, many times a day; result drips into the scratch accumulator
  `PDV.PietyToday`. ORIGIN's curse and DAEDRIC's stigma apply here.
- **Site B -- at-dawn, post-cap** (`ProcessDawn`): fires once at 06:00; the day's scratch
  is scaled, CLAMPED to the daily cap, then scaled again and committed to `PDV.Piety`.
  ORIGIN's orc-life-mode and imperial-curse (x0) apply here.

**Model: a single function with a `phase` parameter, invoked at each site.**

```
; on PDV_GainModifierProvider (base)
Int Property PHASE_PER_EVENT = 0 AutoReadOnly
Int Property PHASE_AT_DAWN   = 1 AutoReadOnly

Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    return 1.0    ; base default; module providers override
EndFunction
```

- `RunGainPipeline` loops the provider array with `PHASE_PER_EVENT` (before the clamp).
- `ProcessDawn` loops the SAME array with `PHASE_AT_DAWN` (after the clamp).
- A provider returns 1.0 for phases it does not participate in. ORIGIN spans both phases
  (curse at PER_EVENT; orc-life-mode x imperial-curse at AT_DAWN) -- one provider object,
  two answers keyed by `phase`. DAEDRIC answers only at PER_EVENT.

**Why one function + two call sites, not two arrays or a provider-declared phase:** ORIGIN
spans both phases; two arrays or a per-provider fixed phase force ORIGIN into two
registrations (wire one, forget the other = silent economy bug). One array asked twice
keeps a single registration per module. **Cap ordering is enforced structurally** -- the
two loops live in two different functions on two sides of the clamp; the phase cannot drift
because the code location IS the phase. Order WITHIN a site is irrelevant (all multipliers
are multiplicative and commute). Runtime cost is ~2N virtual dispatches (N ~= 2-3 providers
-> 4-6 calls), the same order as today's direct calls.

Both sites keep the existing positive-amount short-circuit (`amount > 0.0` at A,
`clampedToday > 0.0` at B): providers never scale a penalty.

---

## 5. Decision 3 -- Cycle-break

- LEDGER declares `PDV_GainModifierProvider[] Property Providers Auto` and calls
  `Providers[i].GetProviderGainMultiplier(deity, phase)`. The concrete type names
  `PDV_Origin` and the DAEDRIC runtime NEVER appear in LEDGER's script.
- Compile-time dependency graph after the break:
  `LEDGER -> PDV_GainModifierProvider -> PDV_DeityBase -> Quest`, and separately
  `ORIGIN -> LEDGER (public AwardPiety* API)` and `ORIGIN -> PDV_GainModifierProvider`.
  There is NO edge from LEDGER back to any concrete module, so there is nothing to cycle
  through. Confirmed.
- **The downward calls are untouched.** ORIGIN/DAEDRIC still call `AwardPietyInternal` as
  signal sources through the public API -- a werewolf's Hircine-blessed kill still grants
  piety exactly as before. Only the UPWARD reach (LEDGER reading module state to scale a
  gain) is inverted into a blind pull through the base type.
- **Deliberately NOT broken: the `PDV_DeityBase` coupling.** LEDGER still takes a
  `PDV_DeityBase deity` param and reads `deity.GetEffectiveGainMultiplier()`, and deities
  still call back to award via `ScoreAction -> AwardPiety`. LEDGER and DeityBase remain
  mutually acquainted ON PURPOSE: DeityBase is the shared floor both stand on, not a module
  being pried apart. A future "cleanup" that removes LEDGER's DeityBase reference would
  break the deity param -- do not.

---

## 6. Decision 4 -- Hot-path fail-open guard

Before the batched ESP session fills the array, `Providers` is None/empty. The pipeline
must fail OPEN. Three layers:

1. **Array null-check:** if `Providers` is None (unfilled Auto property), skip the loop
   entirely -- the earned amount passes through unchanged (effectively x1.0).
2. **Slot null-check:** `if Providers[i]` before calling -- skip None slots; never a
   `None.GetProviderGainMultiplier()` throw.
3. **Base default:** the base `GetProviderGainMultiplier` returns 1.0, so even a
   mis-registered provider that failed to override yields x1.0.

Never x0.0 (a fail-CLOSED default would silently zero ALL gains), never a throw on the hot
path.

**Accepted dev-window consequence:** between LEDGER extraction and the CK fill, gains run
UNMULTIPLIED (curse / stigma / dawn factors absent). This is a dev-build-only gap -- the
fill ships in the same release, so end users never see it. It is strictly better than the
alternatives (x0 zeroes all gains; a throw breaks every award). Documented as an accepted
intermediate state, not a shipped one.

---

## 7. Decision 5 -- Registration mechanism

- **CK array-fill, not runtime self-register.** The `PDV_GainModifierProvider[] Providers`
  Auto property is filled on the LEDGER quest record in the batched houseCARL session --
  the same session and mechanism that fills the FAVOR `Manager` backref and the
  `Quest[] RivalDeities` array. A runtime `RegisterProvider()` call is rejected: it needs a
  fragile init ordering (provider must run after both it and LEDGER exist), introduces
  mutable runtime state instead of a deterministic xEdit-inspectable array, and is unsafe
  before the QUST hosts exist.
- **The module host IS the provider.** `PDV_Origin` adopts
  `extends PDV_GainModifierProvider` and overrides the function to fold its curse
  (PER_EVENT) and orc-life-mode x imperial-curse (AT_DAWN) factors. The fresh DAEDRIC
  runtime host does likewise for stigma (PER_EVENT). No standalone adapter objects -- two
  providers, both the runtime hosts that already own the state.
- **Fill order is free** (multiplication commutes within a site). No ordering constraint on
  the CK array fill.

---

## 8. Decision 7 -- Lane invariant (provider contract clause)

A provider is asked about EVERY eligible deity's gains, so applicability must be gated
inside the provider, on BOTH inputs:

- **Gate on the `deity` param:** `GetOrcLifeModeGainMultiplier` bites only when
  `deity == Malacath`; `GetImperialCurseGainMultiplier` only for the Imperial civic deity.
- **Gate on player state:** curse reads `PDV_CurseStateService.IsWerewolf/IsVampire`.
- **Return 1.0 outside the lane.** No provider may scale a gain for a deity it does not own.

This -- NOT the one-race-per-playthrough assumption -- is what prevents cross-lane /
cross-race contamination (e.g. the Imperial vampire halt zeroing a Bosmer's Hircine piety).
The `deity` param is load-bearing even inside a single provider: the curse multiplier must
discriminate by lane (a werewolf dampens most lanes but NOT Hircine, who favours
werewolves) -- and the live code already reads `PDV_HircinePath` identity alongside the
werewolf/vampire flags to do exactly this. Because Option A is a pure LIVE read (no cache),
a mid-game race reset is picked up correctly on the very next gain event -- a bonus the
rejected push/cache model (Option B) could not guarantee.

---

## 9. Per-symbol disposition (resolves the 15 `needsAdjudication` entries)

| Symbol | Module | Disposition |
|---|---|---|
| `RunGainPipeline` | LEDGER | KEEP in LEDGER; loops `Providers[]` with `PHASE_PER_EVENT`. |
| `AwardPietyInternal` | LEDGER | KEEP; public gain entry, calls `RunGainPipeline`. |
| `AwardPietyFromLikesDislikes` | LEDGER | KEEP; public gain entry. |
| `AwardPiety` | LEDGER | KEEP; public gain entry. |
| `ProcessDawn` (Site B, not itself an adjudication entry) | LEDGER | KEEP; loops `Providers[]` with `PHASE_AT_DAWN` after the cap clamp. |
| `GetCurseGainMultiplier` | ORIGIN (was LEDGER-resident) | MOVE to ORIGIN provider, PER_EVENT branch. |
| `GetCurseGainMultiplierNoop` | LEDGER | INLINE into `GetCurseGainMultiplier`; drop the misnamed wrapper. |
| `GetDaedricStigmaGainMultiplier` | DAEDRIC | MOVE to DAEDRIC provider, PER_EVENT branch. |
| `GetDaedricStigmaGainMultiplierNoop` | DAEDRIC | INLINE into `GetDaedricStigmaGainMultiplier`; drop the misnamed wrapper. |
| `GetOrcLifeModeGainMultiplier` | ORIGIN | MOVE to ORIGIN provider, AT_DAWN branch. |
| `GetImperialCurseGainMultiplier` | ORIGIN | MOVE to ORIGIN provider, AT_DAWN branch. |
| `GetSurvivalContextGainMultiplier` | LEDGER | KEEP in LEDGER -- LEDGER-internal (compat lives in LEDGER), NOT a provider; no inversion needed. |
| `GetReputationGainMultiplier` | LEDGER | DROP -- dead (track factor already inside `GetEffectiveGainMultiplier`). |
| `GetReputationGainMultiplierNoop` | LEDGER | DROP -- dead wrapper of a dead function. |
| `GetTalosTrackGainMultiplier` | ORIGIN | OUT OF SCOPE for this seam -- reached through the DeityBase deity-dispatch path, not `RunGainPipeline`. Governed by the shared-base coupling this ADR leaves intact. |
| `GetTalosEffectiveGainMultiplier` | ORIGIN | OUT OF SCOPE -- same as above. |

Note: `ProcessDawn` is listed for completeness (it is the Site-B host) but is not itself an
entry in the `needsAdjudication` array. `PDV_ModePresetRef.GainMultiplier()` (Site A,
LEDGER-owned) is likewise LEDGER-internal and not part of the inversion.

Before deleting the two dead symbols, verify no gate needle in `tools/*.mjs` pins their
NAMES (a needle that pins a removed name goes red). This is a mechanical pre-removal check
at extraction time, not a design decision.

---

## 10. Resulting LEDGER-extraction unblock

With this contract fixed, LEDGER extracts mechanically:

- LEDGER's gain pipeline references only `PDV_GainModifierProvider` (base) and
  `PDV_DeityBase` (shared) -- no ORIGIN/DAEDRIC concrete types, so no upward compile
  dependency and no cycle.
- The two phases are explicit and the daily-cap ordering is preserved by construction.
- The pipeline fails open until the CK fill lands, so early loads neither throw nor zero.
- The provider array fills in the batched houseCARL session already planned for FAVOR --
  no new wiring mechanism.
- Two dead symbols and two misnamed wrappers leave with the extraction rather than being
  ported.

The build sequence this unblocks (author the base + overrides, extract LEDGER against the
base, then fill the array in the batched ESP session) is downstream work and is tracked in
the extraction manifest, not here.
