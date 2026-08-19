# ADR -- ORIGIN adapter interface (base virtual surface)

Status: ACCEPTED (2026-08-19). Supersedes the open question in
`PDV_2_0_ORIGIN_AdapterSplit_Plan.md` Section 3, and settles the provider-ownership
contradiction between that plan's Section 5 and
`PDV_2_0_ProviderSeam_ExtractionSpec.md` Section 3.

This is step 1 of the adapter split. It must be frozen before the 10 adapters are cut.

## Context -- the measured call surface

`PDV_OriginRuntimeBase` is a flat 12,107-line monolith carrying ~664 moved functions and
~225 `ORIGIN_*` race comparisons. Cross-boundary calls today, measured from source:

| | verbs | call sites |
|---|---|---|
| Total distinct `OriginRuntime.X` | **341** | **707** |
| ...race-specific (must collapse) | **288** | **478** |
| ...shared / non-race (stay on base) | 53 | 229 |

Callers: manager 378 calls / 161 verbs; `PDV_DevotionLedger` 172 / 112; `PDV_EventBus`
107 / 94; `PDV_ActionRouter` 23 / 18; `PDV_MCM` only 13 / 6; the rest single digits.

Two facts drove the design. First, **Option B is dead on arrival**: declaring every
crossed function on the base means ~288 virtual stubs and keeps a de-facto switchboard in
the interface. Second, `PDV_EventBus` calls **94 distinct verbs, nearly all once** -- that
is one-named-verb-per-signal, and it collapses almost entirely into a single keyed verb.

## Decision

**Option A -- a small generic virtual interface.** The base declares 18 virtuals with safe
inert defaults; each adapter overrides only what its race implements. Race identity becomes
object identity: no race switchboard survives at the boundary.

### The interface

Lifecycle
- `Function ApplyInitialChoice()`
- `Function EnsureRuntimeWiring()`
- `Function ApplyCurseHandlers()`
- `Function EvaluateAtDawn()`

State
- `String Function GetOriginStateLabel()` -- the race's primary state-track label
- `Int Function GetOriginStateValue()` -- that track's value
- `String Function GetOriginSummary()`
- `String Function GetSurveyFragment()`
- `Bool Function IsRaceLaneNeglected()`
- `String Function GetOriginDetailLabel(String key)` -- long tail
- `Int Function GetOriginDetailValue(String key)` -- long tail

Signals
- `Bool Function HandleContextualSignal(String signalId, Form contextForm = None, Float magnitude = 0.0)`
- `Function HandleLocationChange()`

Upkeep
- `Function SyncRaceRewards()`
- `Function SyncNeglectSpells()`

Patron / offers
- `Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)`
- `String Function GetFormalCommitmentOfferMessage()`

Presentation
- `Function ShowOriginNotification(String messageKey)`

Provider (see below)
- `Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)`

Defaults on the base: `""`, `0`, `False`, no-op, and `1.0` for the multiplier.

### Why these verbs and not others

The alignment is in the data, not invented. Concepts that already recur across all ten
races -- under ten different names -- become one verb each:

- `GetSurveyText` exists on 9 races (`GetNordSurveyBaseText` on the tenth).
- `SyncNeglectSpell` on 10, `SyncRewards` on 9, `ApplyCurseHandlers` on 10.
- The neglect predicate exists on **all ten** and is named differently every time:
  `IsAltmerCoherenceNeglected`, `IsBosmerPathNeglected`, `IsKhajiitLunarNeglected`,
  `IsArgonianHistNeglected`, `IsBretonTraditionNeglected`,
  `IsRedguardAncestorDistanceNeglected`, `IsDunmerAncestorNeglected`,
  `IsOrcCodeNeglected`, `IsImperialCivicNeglected`, plus the Nord vampire-suppression
  variant. One concept, ten spellings -- exactly what a virtual is for.
- Same for the primary state label: Tradition / Focus / Sect / LifeMode / Path /
  DevotionMode / Concordat / AncestorLayer / CulturalPractice / CrisisState.

The 91 `Handle*` race verbs do **not** align by name, because each race has its own signal
vocabulary. That is the correct place for a keyed verb, not a named one.

### Signal IDs drop the race prefix

`OriginRuntime.HandleBosmerExchangeSignal()` becomes
`OriginRuntime.HandleContextualSignal("exchange")`. The caller stops naming the race; the
live adapter supplies it.

Because **exactly one adapter is instantiated per playthrough** (selected by birth race at
init, fixed thereafter), signal IDs only need to be unique *within* a race, not globally.
That sharply limits renaming churn.

This also preserves an existing design requirement rather than fighting it: a signal sent
to the wrong origin hits the base default and returns `False`. Wrong-origin and
rejected-hook inertness -- which the race gates already assert -- becomes structural
instead of something each handler re-checks.

## Provider ownership (settles D1)

`PDV_OriginRuntimeBase extends PDV_GainModifierProvider`, and
`GetProviderGainMultiplier` is one of the base virtuals above.

- `PDV_GainModifierProvider extends Quest`, so the base stays IS-A Quest and can still be a
  host QUST script. The inheritance slot is chained, not spent.
- `GetOrcLifeModeGainMultiplier` and `GetImperialCurseGainMultiplier` are today hard race
  gates that early-return 1.0 for nine races out of ten -- and both already call into
  `OriginRuntime` to ask the race question. They become overrides on `_Orc` and `_Imperial`;
  every other adapter inherits `1.0`. The gate disappears rather than moving.
- `GetCurseGainMultiplier` is not race-gated (it reads curse state and a deity check) and
  stays on the base.
- Only one adapter is live, so LEDGER's `Providers[]` holds one ORIGIN entry regardless.

The seam spec's Section 3 names `PDV_Origin` instead. That is wrong and must be corrected:
`PDV_Origin.psc` is a 519-line one-shot bootstrap quest (detect race, write
`PDV_GLO_OriginRace`, seed three deity ledgers) with no lane logic. It is the wrong home for
a per-award and per-dawn hot path.

Per D2, decay is a third consumer site (`PDV_DevotionLedger.psc:2287`) alongside award
(`RunGainPipeline` :3253) and dawn (`ProcessDawn` :2027-2033), and routes through the same
provider array with its own phase.

## What stays on the base, non-virtual

The 53 shared verbs / 229 calls: `GetPlayerOriginRaceIndex` (101 calls on its own),
`GetOriginRaceLabel`, broad-lane tier/standing/display, curse summary and context,
substrate pacing, Talos, medallion, survey scaffolding, rest-cell. This is the tranche-6
non-race infrastructure the split plan already assigns to the base.

The `IsAltmerOrigin` / `IsBosmerOrigin` / `IsKhajiitOrigin` style predicates are answered on
the base from the race index; they do not need to be virtual.

## The move stays parity-provable

The obvious risk with Option A is that "bodies change at the boundary", which would forfeit
reconstruction parity against `origin_golden.json`. It does not have to.

**Each adapter's virtual override delegates to the existing named function**, whose body
moves unchanged:

```papyrus
; PDV_OriginRuntime_Bosmer
Bool Function HandleContextualSignal(String signalId, Form contextForm = None, Float magnitude = 0.0)
    if signalId == "exchange"
        HandleBosmerExchangeSignal()
        return True
    elseIf signalId == "bandit-road"
        HandleBosmerBanditRoadSignal()
        return True
    endIf
    return False
EndFunction
```

So the ~664 moved bodies still reconstruct byte-for-byte; the only new code is a thin,
hand-reviewable dispatch layer per adapter. Parity proof survives the split, and the
behavior review narrows to the dispatch tables plus the remapped call sites.

## Consequences

Good: 288 named cross-boundary verbs collapse to 18; the base's ~225 race comparisons go
away with the lanes; `PDV_EventBus` loses 94 named calls; wrong-origin inertness becomes
structural; the presentation surface in MCM is only 6 verbs, so the keyed detail accessors
absorb it easily.

Accepted cost: `GetPlayerOriginRaceIndex` stays heavily used (101 calls) and callers that
branch on the race index externally are **not** removed by this pass. Those are residual
switchboards outside the ORIGIN boundary; collapse them opportunistically later, and do not
let this ADR imply they are gone.

Also accepted: two keyed accessors (`GetOriginDetailLabel/Value`) are a lookup inside one
adapter. That is a per-race key table, not a cross-race switch -- the race dimension stays
polymorphic.

## Verification

1. Lane functions still reconstruct against `origin_golden.json` (bodies unchanged).
2. The dispatch layer and remapped call sites get a hand behavior review -- this is the part
   parity cannot cover.
3. Compile 0 errors / 0 warnings.
4. Runtime smoke per race: the manager selects the right adapter and its virtuals fire.
5. **New durable gate**: assert no `OriginRuntime.<RaceName>` call survives outside the
   adapter scripts. That is the machine-checkable statement of this ADR, and it will catch
   any future reintroduction of a named race call at the boundary.

## Sequencing

Freeze this interface, then: cut 10 adapters and move lane functions (parallelisable by
tranche pair -- t1 Altmer/Bosmer, t2 Khajiit/Argonian, t3 Breton/Redguard, t4 Nord/Dunmer,
t5 Orc/Imperial); remap call sites and wire birth-race selection; build the provider seam on
this interface; then ESP wiring. ORIGIN stays inert until the split lands, so the monolith
shape is never wired.
