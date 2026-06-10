# 01 -- Feasibility: Holy Days & Festivals

**Status:** DESIGN DOSSIER. No in-game proof for this feature exists yet.
All seams below are traced to live source names; no proof claim is made.

---

## Live Seams This Feature Builds On

### 1. The dawn loop -- `ProcessDawn()` (live `:3933`)
Holy days are evaluated exactly once per dawn in the existing `ProcessDawn()`
call chain. The call fires on day rollover in the `OnUpdate` 1-second tick
via the `pdvCurrentDawnDay > LastDay` guard (live `:555-565`). No new tick or
registration needed. Holy-day logic rides as a pre-check before the per-deity
loop.

### 2. Day-index computation -- `pdvCurrentDawnDay` pattern (live `:555-556`)
```
Float pdvDawnAdjustedTime = Utility.GetCurrentGameTime() - 0.25
Int pdvCurrentDawnDay = pdvDawnAdjustedTime as Int
```
`Utility.GetCurrentGameTime()` returns fractional game-days since the start of
the save (a vanilla Papyrus function, no SKSE required). The `DAWN_DAY_OFFSET`
of 0.25 (= 6h) already separates day boundaries at dawn rather than midnight.
This same value, cast to an Int, is the day index PDV uses everywhere for
anti-farm caps.

**In-game month/day derivation:** Skyrim uses a 360-day calendar (12 months x
30 days). Given `gameDayTotal = Utility.GetCurrentGameTime() as Int`, the
month and day can be derived:

```
; NOTE: Game starts at a fixed calendar offset (4E 201, around 17th of Last Seed
; = approx. game day 0 = Month 8, Day 17). The exact epoch offset at save-game
; start is NOT exposed as a built-in Papyrus function -- see proof item P1.
Int dayInYear = gameDayTotal - (gameDayTotal / 360) * 360    ; modulo 360
Int monthIndex = dayInYear / 30                               ; 0-based, 0=Morning Star
Int dayOfMonth = (dayInYear - monthIndex * 30) + 1           ; 1-based
```

This arithmetic is entirely vanilla integer math against
`Utility.GetCurrentGameTime()`. No SKSE, no PO3, no new dep.

**PROOF ITEM P1 (calendar epoch offset):** The exact game-day integer at which
a new save starts (i.e. which real Tamrielic calendar date day-0 corresponds to)
must be verified in-game or against CK initial conditions. UESP records that
"Unbound" begins on the 17th of Last Seed, 4E 201, which maps to Month 8 Day 17
of the 360-day calendar. If `Utility.GetCurrentGameTime()` returns 0.0 at that
moment, then `dayInYear = 0` maps to Month 8 Day 17, not Month 1 Day 1 -- the
offset must be baked into any calendar lookup. The lookup table can absorb this:
store holy days as `absoluteDayOfYear` (0-359) with the epoch offset applied at
table-compile time. This is a compile-time constant, not a runtime unknown.
**Owner decision required: confirm epoch offset before calendar compile.**

**PROOF ITEM P2 (date arithmetic in practice):** The month/day derivation above
has never been exercised in this codebase. Before wiring the holy-day multiplier,
a console test (`Debug.Notification` of computed month/day on a known date)
should confirm the epoch math. This is a one-session in-game proof, not an
architecture unknown.

### 3. Mood gain knob -- `RunDawnUpdateMoodForDeity()` (live `:10384`)
The function receives `clampedToday` (a float already computed and clamped by
`RunDawnConsolidateScratch()`). A holy day multiplier applies to
`dailyContribution` inside this function, or equivalently the caller can pass
`clampedToday * holyDayMultiplier`. The EWMA formula is:
```
newMood = Clamp(alpha * dailyContribution + (1 - alpha) * oldMood, -100, 100)
```
Multiplying `dailyContribution` by 1.5x on a holy day does not change the
formula's shape -- it is a transient single-day amplification, no structural
change.

### 4. Demand window knob -- `OfferDemand()` (live `:10528`) and `IsEligibleForDemandOffer()` (live `:10504`)
`OfferDemand` reads `windowDays` from JSON:
```
Int windowDays = JsonUtil.GetIntValue(LIVING_DEITIES_FILE, demandPrefix + "windowDays", 3)
```
A holy day bonus is applied by adding `demandWindowBonus` to `windowDays`
before computing `ExpiresAt = nowTime + windowDays`. The JSON table value is the
base; the bonus is a runtime delta on holy days only.

Additionally, `IsEligibleForDemandOffer` currently requires a down-cross pending
flag. On a holy day, an alternative offer path is available: the deity can issue
a demand even without a recent down-cross (the holy day itself is grounds). This
is a single extra `||` branch -- a holy-day eligibility gate in parallel with
the existing `DownCrossPending` check.

### 5. JSON-table pattern -- `LIVING_DEITIES_FILE` and compiler (live `:345`)
The LD engine already loads `PDV_LivingDeities.json` via `JsonUtil` from
`SKSE/Plugins/StorageUtilData/PlayerDevotion/`. The holy-day calendar is a
natural fourth CSV/JSON alongside `PDV_DeityMood.csv`, `PDV_DemandTable.csv`,
and `PDV_OmenProfile.csv`. The same `pdv_living_deities_compile.mjs` toolchain
can compile it, or a sibling `pdv_holy_days_compile.mjs` can produce a separate
`PDV_HolyDays.json` file (separation keeps the LD file from growing unbounded).

The `GetKhajiitMoonPhaseFromGameDay()` function (live `:9862`) is precedent for
calendar arithmetic inside this codebase: it derives a phase index from
`Utility.GetCurrentGameTime()` using pure integer math. The holy-day check is
structurally identical.

---

## Confidence Assessment

| Question | Confidence | Notes |
|---|---|---|
| Dawn loop as insertion point | HIGH | Proven at runtime (2026-06-08); ProcessDawn fires on day rollover |
| `Utility.GetCurrentGameTime()` availability | HIGH | Vanilla Papyrus; no SKSE dep; in heavy use in this codebase |
| Month/day derivation arithmetic | MEDIUM | Logic is simple but epoch offset not confirmed -- see P1/P2 |
| Mood-gain multiplier injection | HIGH | One parameter change inside `RunDawnUpdateMoodForDeity`; formula unchanged |
| Demand window bonus | HIGH | One additive delta to `windowDays` before `OfferDemand` computes `ExpiresAt` |
| Holy-day eligibility gate (alternative offer path) | MEDIUM | Extra `||` branch; logic is simple; needs careful interaction test with DownCrossPending anti-spam |
| JSON compile/load pattern | HIGH | Proven in `pdv_living_deities_compile.mjs` (Block A, 2026-06-10 passing) |
| Calendar epoch offset | LOW -- proof required | P1 above; must confirm in-game or against CK initial conditions |

---

## Recomposition vs. Greenfield

**Recomposition throughout.** No new tick, no new event hook, no new StorageUtil
namespace beyond a single "today is a holy day" flag per deity (cleared at dawn).
The holy-day calendar is data (a JSON table) and a small new helper function
(`GetHolyDayMultiplier(deity, dayOfYear)`). The call site is a two-line injection
into the existing dawn loop. The demand-window bonus is an additive delta on a
value already read from JSON. Nothing forks the engine.

---

## In-CK / In-Game Proof Still Required

- P1: confirm calendar epoch offset (what game-day int does a new save start on?)
- P2: console-test the month/day derivation arithmetic on a known in-game date
- P3: runtime smoke -- Kyne holy day fires on the correct dawn, multiplier applies,
  demand window is extended, and no runaway mood accumulation across consecutive
  days (the anti-abuse cap must hold; see 02_architecture.md)

No in-game proof exists at time of authoring (2026-06-10). This dossier is
design-only; proof is a Block E (post-LD-P1) activity.
