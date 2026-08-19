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

**Option A -- a small generic virtual interface.** The base declares 19 virtuals with safe
inert defaults; each adapter overrides only what its race implements. Race identity becomes
object identity: no race switchboard survives at the boundary.

### The interface (21 virtuals -- CORRECTED after the adapter pilot)

Signatures below are the corrected ones, taken from real usage. See "Corrections after
the pilot" at the end for what was wrong in the first cut and why it mattered.

Lifecycle
- `Function ApplyInitialChoice(Int choiceValue, String reason)`
- `Function EnsureRuntimeWiring()`
- `Function ApplyCurseHandlers(Int oldState, Int newState, String reason)`
- `Function EvaluateAtDawn()`

State
- `String Function GetOriginStateLabel()` -- the race's primary state-track label
- `Int Function GetOriginStateValue()` -- that track's value
- `String Function GetOriginSummary()`
- `String Function GetSurveyFragment()`
- `Bool Function IsRaceLaneNeglected()`
- `String Function GetOriginDetailLabel(String detailKey)` -- long tail
- `Int Function GetOriginDetailValue(String detailKey)` -- long tail

Signals
- `Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)`
- `Int Function HandleContextualQuery(String signalId, String reason = "", Form contextForm = None)` -- value-returning siblings
- `Function HandleLocationChange(Form newLocation = None)`

Upkeep
- `Function SyncRaceRewards()`
- `Function SyncNeglectSpells()`

Patron / offers
- `Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)`
- `Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)`

Presentation
- `Function ShowOriginNotification(Message messageRecord, String fallbackText)`
- `Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)`

Provider (see below)
- `Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)`

Defaults on the base: `""`, `0`, `False`, `None`, no-op, and `1.0` for the multiplier.

### Why these verbs and not others

The alignment is in the data, not invented. Concepts that already recur across all ten
races -- under ten different names -- become one verb each:

- `GetSurveyText` exists on 9 races (`GetNordSurveyBaseText` on the tenth).
- `SyncNeglectSpell` on 10, `SyncRewards` on 9, `ApplyCurseHandlers` on 10.
- The neglect predicate exists on **nine** races and is named differently every time:
  `IsAltmerCoherenceNeglected`, `IsBosmerPathNeglected`, `IsKhajiitLunarNeglected`,
  `IsArgonianHistNeglected`, `IsBretonTraditionNeglected`,
  `IsRedguardAncestorDistanceNeglected`, `IsDunmerAncestorNeglected`,
  `IsOrcCodeNeglected`, `IsImperialCivicNeglected`. One concept, nine spellings -- exactly
  what a virtual is for. **Nord is the exception and has none** (see the neglect-pool ruling
  below); an earlier draft of this ADR wrongly counted Nord's vampire-suppression predicate
  as the tenth.
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

Good: 288 named cross-boundary verbs collapse to 19; the base's ~225 race comparisons go
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

## Corrections after the pilot (2026-08-19)

The first cut of this interface was designed from a verb-NAME survey without checking
arity or return types against the real functions. Five adapter agents built against it and
three independently hit the same defects. Corrected in `3e32f235`; the listing above is
the corrected form.

| Was | Is | Why it mattered |
|---|---|---|
| `ApplyCurseHandlers()` | `(Int oldState, Int newState, String reason)` | all 9 race handlers take 3 args; a 3-arg child of a 0-arg base is a compile error, so it was simply unimplementable |
| `ApplyInitialChoice()` | `(Int choiceValue, String reason)` | 5 race handlers take 2 args |
| `String Get...OfferMessage()` | `Message ...(PDV_DeityBase deity)` | 6 races return a Message record keyed by deity |
| `...DetailLabel(String key)` | `(String detailKey)` | `key` resolves to Skyrim's vanilla `Key` form type |
| `HandleContextualSignal(...)` | `+ String reason = ""` | callers build the reason dynamically |
| `HandleLocationChange()` | `(Form newLocation = None)` | re-sampling `GetCurrentLocation()` is not provably the caller's `akNewLocation` |
| `ShowOriginNotification(String)` | `(Message, String)` + new `ShowOriginMessage(Message, String, Bool)` | the real notifiers take a Message record, and a modal variant exists |

Two of these deserve to be remembered rather than just fixed.

**The `key` defect was invisible to compilation.** The base stub compiled clean because it
never READ the parameter; the error ("key is not a variable") only appears once an adapter
implements the body. A green compile on a stub proves nothing about a signature.

**The missing `reason` slot was not merely cosmetic.** `HandleAltmerDawnSteadiness`
**branches on the exact reason string**, so substituting the signalId would have silently
taken the wrong branch -- a behavior change that no compile or reconstruction-parity check
would catch. 31 of t1's 49 dispatched ids target a verb taking a caller-composed reason,
and reasons are player-visible in the Ledger.

## Open items the pilot surfaced (for the central removal pass)

1. **The base calls DOWN into the lanes.** At least 13 tranche-1 and 7 tranche-2 base
   bodies call race functions directly. Deleting the lane originals from the base breaks
   the base itself unless those calls are re-routed through virtuals first. Most map onto
   existing virtuals; `BridgeKhajiitMatrixFocus` (two String args) has no home yet.
2. **Cross-lane dispatchers.** `HandleThalmorUnprovokedKill` branches Altmer AND calls an
   Imperial verb, so it belongs to neither adapter alone; it needs a joint t1/t5 decision.
3. **Non-Bool entry points.** Three Khajiit magic-effect entries and
   `HandleAltmerPracticeFocus` return `Bool`/`Int` values a caller consumes, so they
   cannot ride `HandleContextualSignal` (which returns Bool as handled/not-handled).
4. **`SyncRaceRewards()` arity fill** uses `Game.GetPlayer()` where the lane function took
   a player argument -- provably equivalent at the single live call site
   (`PDV_DevotionLedger.psc:3570/3575`) but it is new code, not a move.
5. **`GetKhajiitLunarAlignmentMultiplier` has zero call sites anywhere.** Copied and
   unwired. Do not delete it on "no references" alone.

## Ruling: neglect is THREE pools, and Nord has no race-lane one (2026-08-19)

Raised by the owner while reviewing the adapter reports: is race-lane neglect meant to flow
to the deities/princes while the broad lane covers culture, or are they separate pools?

Read from `PDV_DevotionLedger.RunDawnApplySpellAndNeglectLayers()` (:2147) and the
first-tier race sync (:3581-3605), they are **three separate pools**, and the mapping is not
the one the question supposed:

1. **Patron / deity pool** -- focused-worship lapse for an active patron, including Princes.
   The `GetPatronState() != PATRON_STATE_ACTIVE` branch.
2. **Race / culture-lane pool** -- per-race cultural practice: `SyncBretonNeglectSpell(IsBretonTraditionNeglected())`,
   `SyncOrcNeglectSpell(IsOrcCodeNeglected())`, `SyncArgonianNeglectSpell(IsArgonianHistNeglected())`.
   **This is the culture lane** -- it is the race lane, not the broad one.
3. **Broad-lane pool** -- a full-pantheon worshipper who goes quiet. Gated on
   `IsBroadWorshipActive()`, keyed off the global `PDV.Devotion.LastActTime` stamp, and it
   `return`s early, so it is mutually exclusive with the other two.

The in-code comment on pool 3 records the owner ruling of 2026-06-27 and explains the
asymmetry: Nord broad reuses the Kyne weather spell as its broad-lane neglect "for now;
per-race broad-lane neglect spells are a follow-on. Other races: no broad spell yet." That
is why `IsBroadLaneLapsed()`'s only consumer is Nord-gated at the call site.

**Therefore `IsRaceLaneNeglected()` stays UN-OVERRIDDEN for Nord.** Nord has no
race/culture-lane neglect predicate at all -- it appears in the broad pool (Kyne spell) and
the patron pool (`SyncNordPatronNeglectSpells`) only. Mapping it to
`IsNordVampireSuppressed()` would equate curse-suppression with lane lapse, which is a third
and unrelated thing. The base default `False` is the honest answer.

## Ruling: the Dunmer urn rides the normal signal path (2026-08-19)

Also raised by the owner: should the Dunmer ancestral urn use the new value channel?

No. `HandleDunmerPortableShrinePrayer(String reason)` and `HandleDunmerPlayerHomeBonus(String reason)`
are both **void**; `PDV_DunmerAncestralUrn` (a MISC `OnEquipped` ObjectReference script) fires
through `PDV_EventBus.RouteDunmerPortableShrinePrayer()` and consumes nothing back. It rides
`HandleContextualSignal` unchanged.

The instinct was still sound, and pointed at a real hazard from the other direction: the urn
path depends entirely on the `reason` argument (`"eventbus_" + eventType`), which is exactly
the slot the first interface omitted. Had that shipped, the urn would have kept working while
silently losing its provenance string.

## Known orphan: GetKhajiitLunarAlignmentMultiplier

Zero call sites anywhere. Copied into the Khajiit adapter, unwired, and **deliberately kept**.
Owner states the design intent: *when the deity you are aligned with has their moon cycle
turn, you get a multiplier bonus.* So it is a dropped feature with a known purpose, not dead
code -- do not remove it on a "no references" sweep. Wiring it is a separate work item.
