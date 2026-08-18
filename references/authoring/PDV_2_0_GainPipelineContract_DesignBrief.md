# PDV 2.0 -- Gain-Pipeline Contract Design Brief

Status: LIVING design brief. Decision pending. Written 2026-08-18 as grounding for the
Section 4A "gain-pipeline seam" adjudication (see `PDV_2_0RegionMap.json` ->
`needsAdjudication`). This brief does NOT decide; it lays out the coupling, the
constraints, and the options so the decision can be made once.

Source of truth for every code claim here: `live-source/Scripts/Source/PDV__ManagerQuest.psc`
and `live-source/Scripts/Source/PDV_DeityBase.psc` at the `feature/v3-big-update` worktree
HEAD. Line numbers are from that snapshot and will drift; re-derive before relying on one.

---

## 1. Why this must be decided before LEDGER extracts

In the 2.0 decomposition (`PDV_2_0RegionMap.json`), the single piety write path --
`AwardPiety` / `AwardPietyFromLikesDislikes` / `AwardPietyInternal` / `RunGainPipeline` --
is assigned to **LEDGER** (`PDV_DevotionLedger`). But the gain path multiplies the earned
amount by a family of per-module multipliers whose STATE is owned by modules that extract
LATER: ORIGIN (`PDV_OriginRuntimeBase`) and DAEDRIC (`PDV_DaedricRuntime`).

So the module that extracts first (LEDGER) contains code that reads state the later
modules will own. If LEDGER extracts as-is, it acquires a compile-time dependency on
ORIGIN and DAEDRIC. Worse, ORIGIN and DAEDRIC are *already* downstream callers of
`AwardPietyInternal` (they are signal sources). That is a **dependency cycle**, not a
one-way seam. The registration contract below is what turns the cycle into a one-way pull.

The region map already flags all of this: every gain-path symbol carries the note
"award path couples upward to ORIGIN-curse / DAEDRIC-stigma / Survival / compat gain
multipliers; requires a GainModifier registration contract before extraction."

---

## 2. The pipeline sequence (there are TWO application sites, not one)

The economy applies gain multipliers at two distinct points in a piety's life. This split
is the single most important fact in this brief, because a "just iterate one list" design
silently collapses the two sites into one and breaks the daily-cap ordering.

### Site A -- per-event, pre-cap: `RunGainPipeline` (called by `AwardPietyInternal`)

`AwardPietyInternal` resolves the deity's stance, calls `RunGainPipeline`, then writes the
result to the **scratch** accumulator `PDV.PietyToday` (NOT to committed piety). Body of
`RunGainPipeline`:

```
Float appliedAmount = amount
if amount > 0.0                                  ; positive gains only -- penalties bypass ALL multipliers
    if applyStanceMultiplier
        appliedAmount *= deity.GetEffectiveGainMultiplier()          ; stance x track x eligibility
    else
        appliedAmount *= deity.GetEffectiveGainMultiplierWithoutStance()  ; track x eligibility
    endIf
    appliedAmount *= GetCurseGainMultiplierNoop(deity)               ; -> GetCurseGainMultiplier
    appliedAmount *= GetDaedricStigmaGainMultiplierNoop(deity)       ; -> GetDaedricStigmaGainMultiplier
    appliedAmount *= GetSurvivalContextGainMultiplier(deity)
    if PDV_ModePresetRef
        appliedAmount *= PDV_ModePresetRef.GainMultiplier()          ; ExpMode preset
    endIf
endIf
return appliedAmount
```

The `deity.GetEffectiveGainMultiplier()` call folds THREE factors from `PDV_DeityBase`:
`GetGainMultiplier(stance)` x `GetTrackGainMultiplier()` x `GetEligibilityGainMultiplier()`.
The standalone `GetReputationGainMultiplier` (which just returns `deity.GetTrackGainMultiplier()`)
is therefore redundant with the track factor already inside `GetEffectiveGainMultiplier` --
and it is in fact **dead** (see Section 4).

### Site B -- at-dawn, post-cap: `ProcessDawn` consolidation

At dawn, the day's scratch (`PDV.PietyToday`) is scaled, then **clamped to the daily cap**,
then multiplied by two more multipliers, then committed to `PDV.Piety`:

```
Float scaledToday  = pietyToday * GAIN_RATE_SCALE
Float dailyCap     = PIETY_DAILY_MAX_DELTA * (PDV_ModePresetRef ? DailyCapScalar() : 1)
Float clampedToday = ClampValue(scaledToday, -dailyCap, dailyCap)
if clampedToday > 0.0                            ; positive net only
    clampedToday *= GetOrcLifeModeGainMultiplier(deity)     ; ORIGIN (Malacath life-mode)
    clampedToday *= GetImperialCurseGainMultiplier(deity)   ; ORIGIN (Imperial vampire halt; x0)
endIf
newPiety = ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)
```

**Ordering constraint that the contract MUST preserve:** the daily-cap clamp sits BETWEEN
the two sites. Site-A multipliers scale the *pre-cap* per-event scratch; Site-B multipliers
scale the *post-cap* consolidated total. Moving a Site-B provider into Site-A (or vice
versa) changes the economy: e.g. the Imperial vampire halt (x0) at dawn zeroes even gains
that had already been earned and capped for the day. A provider's phase is not cosmetic.

The final write in both cases is a `StorageUtil` float on the deity Form
(`PDV.PietyToday` at Site A, `PDV.Piety` at Site B). LEDGER owns both keys.

---

## 3. Coupling map (multiplier -> residence -> state read -> owning module)

"Residence" = which module the FUNCTION is assigned to in the region map. "State owner" =
which module owns the DATA the function reads. These differ, which is the whole problem:
a LEDGER-resident function can still read ORIGIN/DAEDRIC state.

| Multiplier | Site | Residence (regionmap) | State it reads | State-owning module | Pure read? |
|---|---|---|---|---|---|
| `deity.GetEffectiveGainMultiplier` (stance x track x eligibility) | A | DeityBase (shared) | VMAD stance, StateTracks on the deity | shared base (DeityBase) | pure |
| `GetReputationGainMultiplier` (+Noop) | -- | LEDGER | `deity.GetTrackGainMultiplier()` | shared base -- **DEAD, never called** | pure |
| `GetCurseGainMultiplier` (+Noop) | A | **LEDGER** | `PDV_CurseStateService.IsWerewolf/IsVampire`; `PDV_HircinePath` identity | **ORIGIN** (CurseStateService) + **DAEDRIC** (HircinePath) | pure |
| `GetDaedricStigmaGainMultiplier` (+Noop) | A | **DAEDRIC** | `PDV_HircinePath.GetStigma()`; Breton witchcraft-exposure StorageUtil | **DAEDRIC** (stigma) + **ORIGIN** (Breton tradition/exposure) | pure |
| `GetSurvivalContextGainMultiplier` | A | LEDGER | survival-mod need globals (SurvivalMode/SunHelm), cached | LEDGER (compat lives in LEDGER) | pure (init caches once) |
| `PDV_ModePresetRef.GainMultiplier` | A | LEDGER | ExpMode preset form | LEDGER (`PDV_ModePresetRef` is LEDGER-owned) | pure |
| `GetOrcLifeModeGainMultiplier` | B | **ORIGIN** | `PDV_OrcLifeModeTrack.GetCurrentState()`, Malacath only | **ORIGIN** | pure |
| `GetImperialCurseGainMultiplier` | B | **ORIGIN** | `PDV.Imperial.VampireHalt` StorageUtil, Imperial only | **ORIGIN** | pure |

Reduced to the load-bearing claim: **the upward couplings LEDGER's pipeline must break are
to ORIGIN and DAEDRIC.** Survival and ModePreset are LEDGER-internal and are NOT part of
the inversion problem. Talos gain multipliers (`GetTalosTrackGainMultiplier`,
`GetTalosEffectiveGainMultiplier`) are ORIGIN-resident and reached through DeityBase, not
through the `RunGainPipeline` chain -- listed in the adjudication set for completeness but
they do not sit in either site above.

Every provider is a **pure read** of already-computed state. None mutates during the gain
event. `InitSurvivalContext` caches forms on first call but that is idempotent setup, not a
per-event write. This purity is what makes all three inversion options viable.

---

## 4. Cardinality, order, and short-circuit facts

- **Count of LIVE multiplier applications:** 5 at Site A (effective-gain bundle, curse,
  stigma, survival, mode preset) + 2 at Site B (orc life-mode, imperial-curse) = **7**.
  Of the ORIGIN/DAEDRIC upward set specifically: curse, stigma (Site A) + orc-life-mode,
  imperial-curse (Site B) = **4 upward couplings**.
- **All applications are MULTIPLICATIVE** (repeated `appliedAmount *= f`). There is no
  additive or subtractive modifier and no accumulation across providers.
- **Order within a site is NOT mathematically significant** -- multiplication commutes
  (floating-point associativity aside, which is below any gameplay-visible threshold).
- **Order BETWEEN sites IS significant** -- the daily-cap clamp separates them (Section 2).
  A provider carries a phase (PER_EVENT vs AT_DAWN); that is the only ordering datum the
  contract must carry.
- **Short-circuit:** both sites gate the whole multiplier block on a positive amount
  (`amount > 0.0` at A, `clampedToday > 0.0` at B). Providers never scale a penalty. Any
  contract can preserve this by only invoking providers on the positive branch.
- **The "Noop" wrappers are misnamed and are NOT no-ops.** `GetCurseGainMultiplierNoop`
  and `GetDaedricStigmaGainMultiplierNoop` each just delegate to the real function; they
  are a historical indirection layer. `GetReputationGainMultiplierNoop` -> 
  `GetReputationGainMultiplier` is the exception: **neither is called anywhere** (the track
  factor is already inside `GetEffectiveGainMultiplier`), so both are dead and should be
  dropped, not ported, when LEDGER extracts.
- **Default/None behavior:** every provider returns `1.0` when its state is absent, its
  deity does not match, or its origin does not match. A missing provider must default to
  `1.0`, never `0.0` -- a fail-closed default here would silently zero all gains.

---

## 5. Reverse-coupling / cycle gotcha (the reason a plain call-up fails)

ORIGIN and DAEDRIC sit on BOTH sides of LEDGER:

- **Downward (sanctioned):** ORIGIN and QUESTREACTION call `AwardPietyInternal` /
  `AwardPiety` / `AwardPietyFromLikesDislikes` as signal sources. This is the public gain
  API and stays as-is (module -> LEDGER).
- **Upward (the problem):** LEDGER's `RunGainPipeline` (Site A) and `ProcessDawn` (Site B)
  read ORIGIN/DAEDRIC state to compute the multipliers (LEDGER -> module).

If LEDGER extracts with the upward reads left as direct calls, LEDGER's `.psc` must declare
a property reference to `PDV_OriginRuntimeBase` and `PDV_DaedricRuntime`, while those two
already declare a `Manager` backref that reaches LEDGER. Papyrus tolerates cyclic script
references at compile time, but the cycle defeats the point of the decomposition: LEDGER
could no longer be reasoned about, tested, or extracted without its supposed dependents.
There is also a live-order hazard -- at first run after a deferred-ESP fill, an unfilled
provider reference is `None`, and a `None.GetGainMultiplier()` on the hot gain path would
throw every award.

There is no other reverse call: the curse-transition path (`HandleCurseStateTransition`
-> `ApplyOrcCurseHandlers` etc.) is LEDGER -> ORIGIN and is a separate seam already listed
in the manifest; it does not run inside the gain pipeline.

---

## 6. Inversion options

All three keep the public gain API (`AwardPiety*`) in LEDGER and remove LEDGER's
compile-time dependency on ORIGIN/DAEDRIC. They differ in HOW the per-module multiplier
reaches the pipeline. Every option must carry the PER_EVENT/AT_DAWN phase and default a
missing provider to `1.0`.

### Option A -- Provider registration list (base-script polymorphism)

Define a thin base script, e.g. `PDV_GainModifierProvider extends Quest` (or a bare
ScriptObject base the module scripts already extend), exposing:

```
Float Function GetGainMultiplier(PDV_DeityBase deity, Int phase)
    return 1.0    ; base default; subclasses override
EndFunction
```

ORIGIN and DAEDRIC each expose an adapter that overrides it (ORIGIN folds curse +
imperial-curse + orc-life-mode by phase; DAEDRIC folds stigma). LEDGER holds an ordered
`PDV_GainModifierProvider[]` property, filled at the deferred-ESP session. `RunGainPipeline`
and `ProcessDawn` iterate the array, calling each provider with the current phase, and
multiply the returned scalars. LEDGER references only the base type, never ORIGIN/DAEDRIC.

- Removes upward dep: yes -- LEDGER compiles against the base script only.
- Papyrus feasibility: Papyrus has no formal interfaces, but virtual override on a shared
  base is fully supported and is the idiomatic substitute. Array-of-base-typed-properties
  is standard.
- Startup/registration cost: one array property fill per provider in the deferred houseCARL
  session; providers must extend the base (a one-line `extends` change on each module host).
- Runtime cost per gain event: one virtual dispatch per provider (2-3 calls), same order of
  cost as today's direct calls.
- Testability/parity: highest -- a fake provider array makes the pipeline unit-isolable; a
  parity harness can assert the product equals the pre-extraction chain. Phase handling is
  explicit in the loop.
- Deferred-ESP / backref fit: clean -- the array fill rides the exact same deferred session
  that fills the `Manager` backref and forward `Manager.<Module>Runtime` refs. Providers
  self-register by being placed in the array at fill time; no runtime `RegisterProvider`
  call needed (and none is safe before the QUST hosts exist).

### Option B -- Push model (module writes into a LEDGER-owned context)

Each module recomputes its multiplier whenever its state changes and writes the scalar into
a LEDGER-owned StorageUtil channel (e.g. `PDV.Gain.Mult.Curse`, `...Stigma`, keyed by phase
and, where needed, by deity). The pipeline reads the channel and never calls out.

- Removes upward dep: yes -- LEDGER only reads StorageUtil; no script reference either way
  for the multiplier.
- Papyrus feasibility: trivial (StorageUtil floats).
- Startup/registration cost: none structural, but every module must find and hook EVERY
  state-change site that could move its multiplier (werewolf/vampire onset, stigma change,
  life-mode change, vampire-halt set/clear) and push on each. Missing one leaves a stale
  scalar.
- Runtime cost per gain event: cheapest at read time (StorageUtil get). Cost moves to the
  write side.
- Testability/parity: weaker -- correctness now depends on push completeness, not on a
  single read path. The classic failure is a stale pushed value that diverges from the
  live state; that is exactly the "one data item, two backends" drift the project rule
  warns against (the multiplier would be derivable from state AND cached in StorageUtil).
- Deferred-ESP / backref fit: fine (no new refs) but the per-deity multipliers (curse,
  stigma) are deity-scoped, so the channel must be keyed per deity, multiplying the number
  of keys and push sites.

### Option C -- Manager stays broker (thin manager combines and hands LEDGER a scalar)

The thin `PDV__ManagerQuest` already holds forward references to every module and each
module holds a `Manager` backref. Let the manager own the multiplier orchestration: expose
`Float Function GetCombinedGainMultiplier(PDV_DeityBase deity, Int phase)` on the manager,
which calls `Manager.OriginRuntime.<...>` and `Manager.DaedricRuntime.<...>`, multiplies
them, and returns one scalar. LEDGER calls back through its own `Manager` backref:
`appliedAmount *= Manager.GetCombinedGainMultiplier(deity, PHASE_EVENT)`.

- Removes upward dep: yes for LEDGER-to-module (LEDGER references only the manager, which it
  already does via backref). The upward reference relocates into the manager, which is the
  one script permitted to know every module.
- Papyrus feasibility: highest -- uses only property calls that already exist; no base
  script, no new array, no new StorageUtil keys.
- Startup/registration cost: lowest -- no new fills beyond the backref/forward refs that
  the extraction already requires.
- Runtime cost per gain event: one extra manager hop plus the same 2-3 module calls.
- Testability/parity: middle -- the combining logic is centralized and testable, but it
  lives in the manager (the least "deep" module), and the manager now knows the phase
  semantics and the multiplier set. Risk of the manager re-accreting economy logic that the
  decomposition was meant to move OUT of it.
- Deferred-ESP / backref fit: best possible -- it is literally the backref pattern already
  chosen for FAVOR (`Manager` backref + `Manager.FavorRuntime` forward ref). No new
  mechanism.

### Tradeoff table

| Criterion | A: Registration list | B: Push/StorageUtil | C: Manager broker |
|---|---|---|---|
| Removes LEDGER->ORIGIN/DAEDRIC compile dep | Yes (base only) | Yes (no refs) | Yes (via existing backref) |
| Papyrus mechanism | virtual override on shared base | StorageUtil floats | existing property calls |
| New wiring at deferred-ESP fill | provider array fill | none (but per-deity keys) | none beyond required refs |
| Push-completeness risk / state drift | none (pull) | HIGH (cache vs source) | none (pull) |
| Phase (pre-cap vs post-cap) handling | explicit in loop | encoded in key | explicit in signature |
| Per-event runtime cost | 2-3 virtual dispatch | cheap reads | 1 hop + 2-3 calls |
| Testability / parity isolation | HIGH | LOW | MEDIUM |
| Keeps economy logic OUT of manager | Yes | Yes | NO (relocates it there) |
| Extra `.psc` surface introduced | base + 2 adapters | key constants | 1 manager function |

---

## 7. Recommendation

**Lead with Option A (provider registration list), using Option C's backref only as the
fill mechanism.** A is the only option that keeps the pull direction (no drift), keeps the
economy logic out of the thin manager, and makes the pipeline parity-testable against the
pre-extraction chain -- at the cost of one shared base script and an array fill that rides
the deferred-ESP session already planned for FAVOR. Model the provider set explicitly on
the two phases so the daily-cap ordering survives the refactor. Drop the dead
`GetReputationGainMultiplier(+Noop)` rather than porting it, and treat the other two "Noop"
wrappers as removable indirection. Fall back to C only if the base-script `extends` change
on the ORIGIN/DAEDRIC hosts proves infeasible in the deferred houseCARL session; never B,
because caching a value that is trivially derivable from live state reintroduces the exact
drift class the project forbids.
