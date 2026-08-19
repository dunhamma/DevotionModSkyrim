# PDV 2.0 Gain-Modifier Provider Seam Extraction Spec

STATUS: LIVING (authored 2026-08-18). Buildable plan for constructing the
gain-modifier provider seam (the ADR's Option A) when the ORIGIN and DAEDRIC
modules extract. This spec OPERATIONALIZES a decided contract; it does not
re-decide anything.

Source of the decision: `PDV_2_0_ADR_GainPipelineContract.md` (DECIDED
2026-08-18). Analysis of record: `PDV_2_0_GainPipelineContract_DesignBrief.md`.
Format mirrored from `PDV_2_0_FAVOR_ExtractionSpec.md`. If any statement here
conflicts with the ADR, the ADR wins - flag the drift, do not silently diverge.

All `live-source` references are to files under
`live-source/Scripts/Source/` at the `feature/v3-big-update` worktree HEAD as of
2026-08-18. Line numbers DRIFT; locate every symbol by NAME. Live-source
locations below are the anchors, not guarantees.

## 0. Scope and approach

This spec constructs the seam that lets LEDGER's gain pipeline apply per-module
gain scalars WITHOUT naming the concrete modules that own them - inverting the
ORIGIN/DAEDRIC <-> LEDGER dependency cycle into a one-way pull (ADR Sections 3
and 5). It specifies four pieces of buildable work:

1. A new shared base script `PDV_GainModifierProvider extends Quest` (Section 2).
2. The ORIGIN provider: `PDV_Origin` adopts the base and overrides the multiplier
   (Section 3). Two manager functions move INTO `PDV_Origin`.
3. The DAEDRIC provider: a FRESH runtime host extends the base and overrides
   (Section 4). One manager function moves into it.
4. The LEDGER side: a base-typed provider array and two loop sites replacing the
   four direct `Manager.Get*GainMultiplier(...)` calls (Section 5).

This is DESIGN-AHEAD work. NONE of it is built by this document. The base
script and the ORIGIN/DAEDRIC overrides are authored WHEN ORIGIN and DAEDRIC
actually extract; the LEDGER-side loops replace the interim reach-backs at that
same point. See Section 9 for the ordering and Section 10 for the design-ahead
note. Until then this spec is the plan those extractions follow.

Two boundary facts to carry in (both from the ADR grilling, both binding):

- The `extends` change is a clean one-liner for ORIGIN (`PDV_Origin extends
  Quest` today) but is IMPOSSIBLE for `PDV_DaedricPathBase` - its single
  inheritance slot is already spent on `PDV_DeityBase`. The DAEDRIC provider is
  therefore a NEW runtime host, never `PDV_DaedricPathBase`. See Section 4.
- The provider function must NOT be named `GetGainMultiplier`. `PDV_DeityBase`
  already declares `Float Function GetGainMultiplier(Int stance)`
  (`PDV_DeityBase.psc:362`, confirmed live). The provider function is
  `GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)`.

## 1. The four functions today (live-source anchors)

The four multiplier functions still live in the manager as of this date. Read
each before moving it; the bodies below are the current gating, condensed.

| Function | live-source | phase | fail-open guard today | moves to |
| --- | --- | --- | --- | --- |
| `GetCurseGainMultiplier(PDV_DeityBase deity)` | `PDV__ManagerQuest.psc:15859` | PER_EVENT | `if !deity \|\| !PDV_CurseStateService: return 1.0` | ORIGIN provider |
| `GetDaedricStigmaGainMultiplier(PDV_DeityBase deity)` | `PDV__ManagerQuest.psc:15875` | PER_EVENT | trailing `return 1.0` default | DAEDRIC provider |
| `GetOrcLifeModeGainMultiplier(PDV_DeityBase deity)` | `PDV__ManagerQuest.psc:9305` | AT_DAWN | `if !deity \|\| !IsOrcOrigin(): return 1.0` | ORIGIN provider |
| `GetImperialCurseGainMultiplier(PDV_DeityBase deity)` | `PDV__ManagerQuest.psc:21376` | AT_DAWN | `if GetPlayerOriginRaceIndex() != ORIGIN_IMPERIAL: return 1.0` | ORIGIN provider |

Current gating in brief:

- `GetCurseGainMultiplier`: bites only when `deity == PDV_HircinePath` - werewolf
  1.5, vampire 0.5; else 1.0. Reads `PDV_CurseStateService.IsWerewolf/IsVampire`.
- `GetDaedricStigmaGainMultiplier`: Breton hidden-art offer branch (x1.25) OR
  `deity == PDV_HircinePath` stigma-tier branch (>=6.0 -> 1.25, >=3.0 -> 1.1);
  else 1.0. Reads `PDV_HircinePath.GetStigma()`, Breton tradition/exposure state.
- `GetOrcLifeModeGainMultiplier`: gates `IsOrcOrigin()` then `deity.DeityName ==
  "Malacath"`, returns the life-mode rate mult; else 1.0.
- `GetImperialCurseGainMultiplier`: gates Imperial origin, returns 0.0 when
  `StorageUtil PDV.Imperial.VampireHalt == 1` (the dawn earn-halt); else 1.0.

The two misnamed wrappers `GetCurseGainMultiplierNoop` (`:15616`) and
`GetDaedricStigmaGainMultiplierNoop` (`:15620`) are the current call-site targets
inside `RunGainPipeline` (they are pass-throughs, not no-ops). Per ADR Decision
6 they are INLINED into their real targets at extraction and dropped; the
provider override calls the real logic directly, never a "Noop" wrapper.

State-rewiring caveat (scope boundary): the four bodies read manager-owned
helpers today (`PDV_CurseStateService`, `IsOrcOrigin()`,
`GetPlayerOriginRaceIndex()`, `GetBretonTraditionValue()`,
`IsBretonHiddenArtDaedricOfferDeity()`, `PDV_HircinePath`, StorageUtil keys).
HOW those reads are satisfied after the move - as module-local ORIGIN/DAEDRIC
state, or through a `Manager` backref like FAVOR's - is decided by the ORIGIN and
DAEDRIC extraction specs, NOT here. This seam spec governs only the provider
DISPATCH mechanics (base type, virtual function, phase, array, guard, lane). The
provider body inherits whatever internal rewiring its owning module's extraction
defines. Do not re-decide state ownership in this document.

## 2. The shared base script `PDV_GainModifierProvider`

New script. `extends Quest` so any Quest-hosted module can adopt it, and so a
provider reference IS-A Quest for CK array-fill. Skeleton:

```papyrus
Scriptname PDV_GainModifierProvider extends Quest

; --- Phase selectors (which call site is asking) ---
Int Property PHASE_PER_EVENT = 0 AutoReadOnly
Int Property PHASE_AT_DAWN   = 1 AutoReadOnly

; --- Virtual multiplier. Base returns 1.0 (fail-open layer 3, Section 6).
;     Module providers OVERRIDE this; they do NOT call Parent (no accumulation
;     in the base). deity + phase are both load-bearing (Sections 5, 7).
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    return 1.0
EndFunction
```

Notes:

- `PDV_DeityBase` resolves by script name in the same namespace; no import.
- The two `AutoReadOnly` phase constants are compile-time and carry their values
  in source - no CK fill. LEDGER references them as
  `Providers[i].PHASE_PER_EVENT` OR declares its own copies; prefer reading them
  off the base so there is ONE definition (do not fork the phase values into
  LEDGER as independent literals - one data item, one home).
- Do NOT name the function `GetGainMultiplier` (Section 0). The name
  `GetProviderGainMultiplier` is fixed by the ADR.

## 3. The ORIGIN provider (`PDV_Origin`)

`PDV_Origin extends Quest` today (`PDV_Origin.psc:20`). Change ONE line:

```papyrus
Scriptname PDV_Origin extends PDV_GainModifierProvider
```

Because `PDV_GainModifierProvider extends Quest`, `PDV_Origin` stays IS-A Quest
transitively - its existing Quest usage (properties, host record) is unaffected.
No collision, because `PDV_Origin` does not currently declare
`GetProviderGainMultiplier`, `PHASE_PER_EVENT`, or `PHASE_AT_DAWN`.

At ORIGIN extraction, `GetOrcLifeModeGainMultiplier` and
`GetImperialCurseGainMultiplier` MOVE from the manager into `PDV_Origin`
(their state - orc-life-mode, imperial-curse - is ORIGIN-owned per the ADR).
`GetCurseGainMultiplier` also becomes ORIGIN-resident (the curse lane is
ORIGIN's). The override folds all three, keyed by phase:

```papyrus
; on PDV_Origin (after it extends PDV_GainModifierProvider)
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    if phase == PHASE_PER_EVENT
        return GetCurseGainMultiplier(deity)
    elseIf phase == PHASE_AT_DAWN
        return GetOrcLifeModeGainMultiplier(deity) * GetImperialCurseGainMultiplier(deity)
    endIf
    return 1.0
EndFunction
```

- PER_EVENT branch = the curse factor (Site A). AT_DAWN branch = orc-life-mode x
  imperial-curse (Site B) - the SAME product order the manager applies today at
  `PDV__ManagerQuest.psc:13258-13259`. Within-site order is irrelevant (all
  multiplicative and commute, ADR Section 4), but keeping the live order avoids a
  needless diff during parity checking.
- The trailing `return 1.0` covers any phase value the provider does not answer
  (defensive; today only two phases exist).
- Each moved function keeps its own internal fail-open guard (Section 1 table).
  The override adds no new guard of its own beyond the phase fallthrough.
- `GetCurseGainMultiplierNoop` is NOT ported; its single call site (LEDGER's
  `RunGainPipeline`) is being replaced by the provider loop (Section 5), and its
  body is inlined into `GetCurseGainMultiplier` per ADR Decision 6.

## 4. The DAEDRIC provider (fresh runtime host)

`PDV_DaedricPathBase extends PDV_DeityBase` (`PDV_DaedricPathBase.psc:10`).
Papyrus is single-inheritance; the slot is spent. The DAEDRIC gain provider
therefore CANNOT be `PDV_DaedricPathBase` and must NOT try to be. It is a NEW,
freshly authored DAEDRIC runtime host script that can take the base cleanly:

```papyrus
Scriptname PDV_DaedricRuntime extends PDV_GainModifierProvider
```

(Name illustrative - the DAEDRIC extraction spec fixes the actual host script
name and whether an existing DAEDRIC runtime host is being authored anyway that
this folds into. The binding constraint is only: it extends
`PDV_GainModifierProvider`, NEVER `PDV_DaedricPathBase`.)

At DAEDRIC extraction, `GetDaedricStigmaGainMultiplier` MOVES into this host and
the override folds it at PER_EVENT only:

```papyrus
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    if phase == PHASE_PER_EVENT
        return GetDaedricStigmaGainMultiplier(deity)
    endIf
    return 1.0    ; DAEDRIC does not participate at AT_DAWN
endFunction
```

- DAEDRIC answers ONLY at PER_EVENT (stigma is a per-event factor, Site A). At
  AT_DAWN it returns 1.0 and contributes nothing to the post-cap product.
- `GetDaedricStigmaGainMultiplierNoop` is NOT ported (inlined and dropped, ADR
  Decision 6).

## 5. LEDGER side - the array and the two loop sites

LEDGER declares the base-typed provider array. The concrete names `PDV_Origin`
and the DAEDRIC host NEVER appear in LEDGER's script (this IS the cycle-break,
ADR Section 5):

```papyrus
PDV_GainModifierProvider[] Property Providers Auto
```

### 5a. Site A - `RunGainPipeline` (PER_EVENT, pre-cap)

Today (`PDV__ManagerQuest.psc:15601-15602`):

```papyrus
appliedAmount = appliedAmount * GetCurseGainMultiplierNoop(deity)
appliedAmount = appliedAmount * GetDaedricStigmaGainMultiplierNoop(deity)
```

Becomes a loop over the array with `PHASE_PER_EVENT`, inside the existing
`if amount > 0.0` short-circuit (providers never scale a penalty):

```papyrus
Int i = 0
while i < Providers.Length
    if Providers[i]
        appliedAmount = appliedAmount * Providers[i].GetProviderGainMultiplier(deity, PHASE_PER_EVENT)
    endIf
    i += 1
endWhile
```

The two surrounding lines STAY in LEDGER untouched:
`GetSurvivalContextGainMultiplier(deity)` (`:15603`) and
`PDV_ModePresetRef.GainMultiplier()` (`:15605`) are LEDGER-internal (compat and
mode-preset), NOT providers - see ADR Section 9. Only the two curse/stigma lines
convert.

### 5b. Site B - `ProcessDawn` consolidation (AT_DAWN, post-cap)

Today (`PDV__ManagerQuest.psc:13256-13259`):

```papyrus
Float clampedToday = PDV_DevotionRules.ClampValue(scaledToday, -dailyCap, dailyCap)
if clampedToday > 0.0
    clampedToday = clampedToday * GetOrcLifeModeGainMultiplier(deity)
    clampedToday = clampedToday * GetImperialCurseGainMultiplier(deity)
    ...
```

Becomes a loop with `PHASE_AT_DAWN`, still inside the `if clampedToday > 0.0`
short-circuit and still AFTER the `ClampValue` daily-cap clamp:

```papyrus
Float clampedToday = PDV_DevotionRules.ClampValue(scaledToday, -dailyCap, dailyCap)
if clampedToday > 0.0
    Int i = 0
    while i < Providers.Length
        if Providers[i]
            clampedToday = clampedToday * Providers[i].GetProviderGainMultiplier(deity, PHASE_AT_DAWN)
        endIf
        i += 1
    endWhile
    ...
```

### 5c. The invariant BETWEEN the sites - preserve it

The daily-cap `ClampValue` (`PDV__ManagerQuest.psc:13256`) sits STRUCTURALLY
between Site A and Site B: Site A multiplies pre-clamp inside `RunGainPipeline`;
Site B multiplies post-clamp inside `ProcessDawn`. The two loops live in two
different functions on two sides of the clamp, so cap ordering cannot drift - the
CODE LOCATION is the phase (ADR Section 4). Do NOT hoist either loop across the
clamp, and do NOT collapse the two sites into one: PER_EVENT is pre-cap by
construction, AT_DAWN is post-cap by construction. A provider must never be asked
AT_DAWN before the clamp or PER_EVENT after it.

### 5d. If the array uses the base's phase constants

If LEDGER references `PHASE_PER_EVENT` / `PHASE_AT_DAWN` unqualified in its own
script, it must either read them off a provider instance or declare local copies
that MATCH the base values (0 and 1). Prefer a single definition on the base;
if LEDGER declares locals, they are the same design constant duplicated and must
never diverge. Simplest: pass the integer phase the base fixes (0 = PER_EVENT,
1 = AT_DAWN) and comment the call, so there is exactly one authoritative home for
the values (the base).

## 6. Three-layer fail-open guard (ADR Decision 4)

The pipeline must resolve to x1.0 for every missing piece - never x0.0 (which
would silently zero ALL gains), never a `None`-call throw on the hot path.

1. **Array None/empty:** `while i < Providers.Length` is a no-op when `Providers`
   is None or zero-length (an unfilled `Auto` array). The earned amount passes
   through unchanged. (If `.Length` on a None array is not safe on the target
   runtime, guard with `if Providers` before the loop - confirm against the
   compiler at build time; the loop-skip is the intent either way.)
2. **Slot None:** the `if Providers[i]` inside the loop skips None slots - never
   a `None.GetProviderGainMultiplier()` throw.
3. **Base default:** `PDV_GainModifierProvider.GetProviderGainMultiplier` returns
   1.0, so a provider that is registered but failed to override still yields x1.0.

Accepted dev-window consequence (ADR Section 6): between LEDGER extraction and
the CK array fill (Section 9), `Providers` is None and gains run UNMULTIPLIED
(curse / stigma / dawn factors absent). This is a dev-build-only gap - the fill
ships in the same release, end users never see it. It is strictly better than
x0 (zeroes all gains) or a throw (breaks every award). It is an accepted
INTERMEDIATE state, not a shipped one - do not "fix" it by defaulting to a
non-1.0 value.

## 7. Lane invariant (ADR Decision 7 - provider contract clause)

A provider is asked about EVERY eligible deity's gains, so applicability is gated
INSIDE the provider, on BOTH inputs, and returns 1.0 outside its lane:

- **Gate on the `deity` param:** curse bites only for `deity == PDV_HircinePath`;
  orc-life-mode only for `deity.DeityName == "Malacath"`; imperial-curse only for
  the Imperial civic deity. Stigma only for Hircine (or the Breton hidden-art
  offer deity).
- **Gate on player state:** curse reads werewolf/vampire; imperial-curse reads
  the vampire-halt latch; orc-life-mode reads the life-mode track.
- **Return 1.0 outside the lane.** No provider may scale a gain for a deity it
  does not own.

This - NOT any one-race-per-playthrough assumption - is what prevents cross-lane
contamination (e.g. the Imperial vampire halt zeroing a Bosmer's Hircine piety).
The `deity` param is load-bearing even within a single provider: the curse
multiplier discriminates by lane (a werewolf dampens most lanes but FAVOURS
Hircine, x1.5). Because Option A is a pure LIVE read (no cache), a mid-game race
reset is picked up on the very next gain event. The four moved bodies already
satisfy this invariant today (Section 1); the extraction PRESERVES their gating,
it does not loosen it. A provider override that dropped the `deity` gate would
regress this invariant - review each override against its Section 1 gating.

## 8. Sequencing vs the ORIGIN and DAEDRIC extractions

This seam is built across the ORIGIN and DAEDRIC extractions, not in one shot.
Recommended order:

1. **Author the base first** (`PDV_GainModifierProvider`, Section 2). It has no
   dependencies beyond `PDV_DeityBase` (already live) and compiles standalone.
   Nothing references it yet; it is inert.
2. **ORIGIN extraction** adopts the base (Section 3), moves its three functions
   in, and provides the ORIGIN override. ORIGIN becomes a valid provider object.
3. **DAEDRIC extraction** authors its runtime host on the base (Section 4), moves
   stigma in, provides the DAEDRIC override. DAEDRIC becomes a valid provider.
4. **LEDGER side** (Section 5) converts the two call sites to loops. This can
   land as soon as the base exists (step 1) - the loops fail open over an empty
   array until the fill (Section 9), so LEDGER does NOT have to wait for ORIGIN
   and DAEDRIC to finish. But the interim `Manager.Get*GainMultiplier` reach-backs
   (the state LEDGER extraction leaves in place) stay live until each function
   actually moves out with its module; do not delete a function from the manager
   before its provider exists to host it.
5. **The CK fill** (Section 9) lands LAST, in the batched houseCARL session,
   after BOTH provider hosts (ORIGIN + the DAEDRIC host QUST) exist.

Pre-removal check (ADR Section 9, mechanical): before deleting the two dead
symbols (`GetReputationGainMultiplier`, `GetReputationGainMultiplierNoop`) or the
two "Noop" wrappers, grep `tools/*.mjs` for any gate needle that pins those
NAMES - a needle pinning a removed name goes red. This is a mechanical check at
extraction time, not a design decision, and it belongs to whichever extraction
performs the removal.

## 9. DEFERRED - ESP / CK work (batched houseCARL session)

None of the following is part of a code-extraction change; they are the batched
ESP session, and they reuse the FAVOR backref/forward-ref mechanism (ADR Section
7). Until they land, `Providers` is None and the pipeline fails open (Section 6).

1. **Create the DAEDRIC runtime host QUST** for the new provider script
   (Section 4), attach the compiled script as a quest script. Per project
   convention, if the host quest is start-game-enabled remember SGE + SEQ
   (EnsureQuest omits SGE). (ORIGIN needs no new QUST - `PDV_Origin` already has
   its host record; adopting the base does not change that.)
2. **Fill the LEDGER `Providers[]` array** on the LEDGER quest record with the
   ORIGIN provider instance AND the DAEDRIC provider instance. Fill order is FREE
   (multiplication commutes within a site, ADR Section 7) - no ordering
   constraint. This is the same CK typed-array fill mechanism as the live
   `Quest[] RivalDeities` array (`PDV_DeityBase.psc:62`) and the FAVOR forward-ref
   fills.
3. **Reuse the FAVOR backref/forward-ref pattern.** The provider hosts already
   own their state (ORIGIN's curse/orc/imperial, DAEDRIC's stigma); if a provider
   body still reaches manager-owned helpers (per the Section 1 caveat), fill its
   `Manager` backref exactly as FAVOR fills `PDV_ContextualFavorRuntime.Manager`.
   The LEDGER->provider direction is the forward-ref (the `Providers[]` fill in
   step 2); any provider->manager direction is the backref.

Sequencing vs the ORIGIN and DAEDRIC extractions: this fill CANNOT run until both
provider hosts exist (ORIGIN adopted the base and the DAEDRIC host QUST is
created). It is therefore ordered AFTER both module extractions and folds into
the same batched houseCARL session that fills FAVOR's `Manager` backref and Spell
properties - one session, not a new mechanism. If the DAEDRIC host QUST is not
yet created when the session runs, fill ORIGIN into the array and leave the
DAEDRIC slot for the DAEDRIC session; the fail-open guard (Section 6) covers a
partially filled array (stigma simply absent until its slot lands).

## 10. Design-ahead note

This is a PLAN, not a build. Nothing in Sections 2-5 is authored until ORIGIN and
DAEDRIC actually extract; the base script, the two overrides, and the LEDGER-side
loops are constructed AS PART OF those extractions, following this document. The
just-completed LEDGER extraction deliberately DEFERRED this seam and left the four
multiplier reach-backs as interim `Manager.Get*GainMultiplier` calls; this spec
is what "kicks off" the seam so those reach-backs can be inverted when the modules
that own the state extract. Until then, treat this file as the contract the ORIGIN
and DAEDRIC extraction specs implement - not as work that is in progress.
