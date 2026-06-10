# 02 -- Architecture: Holy Days & Festivals

**Status:** BUILDABLE SPEC. Design only; no Papyrus/CK/ESP changes here.
All function names are from the LD-P1 authored slice unless noted.

---

## 1. Calendar Table Shape

### Source CSV: `references/authoring/PDV_HolyDayCalendar.csv`

```
deity, month, day, kind, label_key, mood_gain_multiplier, demand_window_bonus_days, holy_day_offer_eligible
```

| Column | Type | Notes |
|---|---|---|
| `deity` | string | Must match `DeityName` on the `PDV_DeityBase` script |
| `month` | int 1-12 | Imperial calendar month number (1 = Morning Star) |
| `day` | int 1-30 | Day of month (1-based) |
| `kind` | string | `"name_day"` or `"feast"` -- name_day = stronger, feast = lighter |
| `label_key` | string | Key for a Prisma/notification toast (e.g. "HolyDay_Kyne_Storm") |
| `mood_gain_multiplier` | float | Applied to `dailyContribution` in `RunDawnUpdateMoodForDeity` (default 1.5 for name_day, 1.25 for feast) |
| `demand_window_bonus_days` | int | Added to `windowDays` in `OfferDemand` when this holy day is active (default 2) |
| `holy_day_offer_eligible` | bool (1/0) | If 1, allows `IsEligibleForDemandOffer` to pass even without a `DownCrossPending` flag |

### Compiled output: `SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_HolyDays.json`

```json
{
  "epochDayOffset": 226,
  "entries": [
    {
      "deity": "Kyne",
      "absoluteDayOfYear": 229,
      "kind": "name_day",
      "labelKey": "HolyDay_Kyne_Storm",
      "moodGainMultiplier": 1.5,
      "demandWindowBonusDays": 2,
      "holyDayOfferEligible": 1
    },
    {
      "deity": "Hircine",
      "absoluteDayOfYear": 284,
      "kind": "name_day",
      "labelKey": "HolyDay_Hircine_Hunt",
      "moodGainMultiplier": 1.5,
      "demandWindowBonusDays": 2,
      "holyDayOfferEligible": 1
    }
  ]
}
```

`absoluteDayOfYear` is the 0-based day within the 360-day year (0-359), pre-computed
at compile time from `month` and `day` with the epoch offset absorbed. The Papyrus
reader never does month/day arithmetic -- it only computes a single day-of-year int
and looks up matches. This is safer and simpler.

`epochDayOffset` is stored for traceability; the Papyrus reader does not need it
(the absolute values are already baked). **Owner must confirm the epoch value
before the compile step. See 01_feasibility.md P1.**

---

## 2. Compiler: `tools/pdv_holy_days_compile.mjs`

A sibling of `pdv_living_deities_compile.mjs`. Reads
`PDV_HolyDayCalendar.csv`, validates deity names against
`PDV_DeityMood.csv` (all deities must be known), checks month 1-12 and day
1-30 ranges, applies the epoch offset, and writes `PDV_HolyDays.json`.

Self-test gates (run before CK wiring):
- No duplicate (deity, absoluteDayOfYear) pairs
- `moodGainMultiplier` in [1.0, 2.0] -- values outside this range flag a warning
- `demandWindowBonusDays` in [0, 7]
- All deity names present in the LD mood table (cross-validation)

---

## 3. Per-Dawn Date Check -- `GetHolyDayDataForDeity()`

A new helper function, inserted into `PDV__ManagerQuest.psc`:

```
; Returns the moodGainMultiplier for 'deity' if today is one of its holy days,
; or 1.0 if not. Also sets StorageUtil key PDV.HolyDay.<deity>.Active (0 or 1)
; for demand-offer reads later in the same dawn pass.
Float Function GetHolyDayMoodMultiplier(PDV_DeityBase deity)
    if !JsonUtil.JsonExists(HOLY_DAYS_FILE)
        return 1.0
    endIf

    ; Derive day-of-year from absolute game day (dawn-adjusted).
    Int gameDayAbsolute = (Utility.GetCurrentGameTime() - 0.25) as Int
    Int dayOfYear = gameDayAbsolute - (gameDayAbsolute / 360) * 360

    ; Walk the entries array looking for a match on this deity + day.
    Int count = JsonUtil.GetArraySize(HOLY_DAYS_FILE, "entries")
    Int i = 0
    while i < count
        String prefix = "entries[" + i + "]."
        String entryDeity = JsonUtil.GetStringValue(HOLY_DAYS_FILE, prefix + "deity", "")
        Int entryDay = JsonUtil.GetIntValue(HOLY_DAYS_FILE, prefix + "absoluteDayOfYear", -1)
        if entryDeity == deity.DeityName && entryDay == dayOfYear
            Float mult = JsonUtil.GetFloatValue(HOLY_DAYS_FILE, prefix + "moodGainMultiplier", 1.0)
            StorageUtil.SetIntValue(deity as Form, "PDV.HolyDay.Active", 1)
            return mult
        endIf
        i += 1
    endWhile

    StorageUtil.SetIntValue(deity as Form, "PDV.HolyDay.Active", 0)
    return 1.0
EndFunction
```

**Note:** `JsonUtil.GetArraySize` and indexed `entries[N]` key access is the
pattern already used in the quest-reaction matrix reader. Verify this is the
correct JsonUtil array traversal idiom before wiring. PROOF ITEM P2 in
01_feasibility.md covers a simpler proof; this is an additional PROOF ITEM P4:
confirm JsonUtil array indexing with the `entries[N].key` pattern in the
SKSE/JsonUtil version present in Anvil.

---

## 4. Insertion Points in the Dawn Loop

### 4.1 Mood-gain multiplier -- inside `RunDawnConsolidateScratch()` (live `:3954`)

The call site for `RunDawnUpdateMoodForDeity` already sits in the per-deity loop.
Inject the multiplier as a local variable computed before the call:

```
; Holy day: amplify dailyContribution going into the EWMA this dawn.
Float holyDayMult = GetHolyDayMoodMultiplier(deity)
RunDawnUpdateMoodForDeityWithMult(deity, clampedToday, holyDayMult)
```

`RunDawnUpdateMoodForDeityWithMult` is the renamed (or overloaded, via a new
parameter with a default of 1.0) version of the existing `RunDawnUpdateMoodForDeity`
(live `:10384`). Inside:

```
Float dailyContribution = (clampedToday / PIETY_DAILY_MAX_DELTA) * 100.0 * holyDayMult
Float newMood = Clamp(alphaValue * dailyContribution + (1.0 - alphaValue) * oldMood, -100.0, 100.0)
```

The multiplier applies to `dailyContribution` only, not to the decay term
`(1 - alpha) * oldMood`. This means a holy day amplifies the day's push but does
NOT slow the return-to-zero decay on subsequent days. Pacing anchor: with
`alpha=0.12` (Kyne) and a full daily cap (4.3 piety = 100.0 contribution), a
1.5x holy day moves mood by `0.12 * 150.0 = 18.0` points (vs. 12.0 normally).
That is enough to cross one band boundary but not two (Wroth-to-Exalted in one
day is impossible even on a holy day). See anti-abuse section below.

### 4.2 Demand window bonus -- inside `OfferDemand()` (live `:10528`)

```
Int windowDays = JsonUtil.GetIntValue(LIVING_DEITIES_FILE, demandPrefix + "windowDays", 3)
; Holy day: extend window if active.
if StorageUtil.GetIntValue(deity as Form, "PDV.HolyDay.Active") == 1
    Int bonus = JsonUtil.GetIntValue(HOLY_DAYS_FILE, ..., 2)
    windowDays += bonus
endIf
```

The `PDV.HolyDay.Active` flag was written by `GetHolyDayMoodMultiplier()` earlier
in the same dawn pass, so it is always fresh when `OfferDemand` runs.

### 4.3 Holy-day demand eligibility -- inside `IsEligibleForDemandOffer()` (live `:10504`)

Currently the function returns `False` if `PDV.Mood.DownCrossPending != 1`.
Add a holy-day bypass when `holyDayOfferEligible == 1`:

```
Bool downCross = StorageUtil.GetIntValue(deityForm, "PDV.Mood.DownCrossPending") == 1
Bool holyDayOffer = StorageUtil.GetIntValue(deityForm, "PDV.HolyDay.Active") == 1 && \
                    JsonUtil.GetIntValue(HOLY_DAYS_FILE, ..., 0) == 1
if !downCross && !holyDayOffer
    return False
endIf
```

This allows the deity to make a demand on its name day even from Cool (not
Wroth), provided no demand is already pending and the cooldown is clear. The
demand on a holy day is the deity reminding you of its nature, not a grievance.

---

## 5. Anti-Abuse: Bounding the Holy Day

The holy day MUST NOT allow one deity to runaway-feed through repeated holy days
or stacked multipliers. Three bounds apply:

**Bound 1 -- Mood is clamped to [-100, 100] regardless of multiplier.**
`GetMoodAlpha` returns a value <= 1.0 and `dailyContribution` is already
bounded at +-100 (because `clampedToday / PIETY_DAILY_MAX_DELTA` is already
clamped to +-1.0 by `RunDawnConsolidateScratch`). A 2.0x multiplier at most
produces a dailyContribution of +-200, and `alpha * 200 = 0.22 * 200 = 44`
(Hircine, most aggressive). Still within one or two band crossings. The Clamp
to [-100, 100] in the EWMA formula is the hard stop.

**Bound 2 -- Multiplier is capped at 2.0x in the compiler self-test.**
The CSV compiler rejects `moodGainMultiplier > 2.0`. This is an authoring-time
bound, not a runtime guard.

**Bound 3 -- Holy days are rare (at most 1-2 per deity per year).**
A single name-day fires once per 360-day year for each deity. Even at 2.0x
amplification, a maximum of 1 in 180 days (2 events/year) has elevated gains.
The sustained-signal pacing model (4.3/day, ~30-45 days to Champion) is not
materially disrupted by two amplified days per year. Mood is an EWMA -- the
effect of one amplified day decays like any other day at rate `(1 - alpha)`.
With `alpha=0.22` (Hircine), the impact of a single holy day is gone in ~4
ordinary days.

**Bound 4 -- Stance ceiling still applies.**
`GetMoodBandCeiling(deity)` is called AFTER the EWMA update and caps the
stored band at Pleased for FOREIGN deities. A holy day does not lift the
stance ceiling. A Nord getting an amplified Dibella day does not shoot past
the FOREIGN cap.

---

## 6. New Constants (add alongside existing LD-P1 constants)

```
String Property HOLY_DAYS_FILE = "PlayerDevotion/PDV_HolyDays" AutoReadOnly
Float Property HOLY_DAY_MOOD_MULT_DEFAULT = 1.5 AutoReadOnly
Float Property HOLY_DAY_FEAST_MULT_DEFAULT = 1.25 AutoReadOnly
Int Property HOLY_DAY_DEMAND_WINDOW_BONUS_DEFAULT = 2 AutoReadOnly
```

---

## 7. StorageUtil Keys (per deity form)

```
PDV.HolyDay.Active      -- Int (0/1): set each dawn pass, consumed by OfferDemand
                           in the same pass. No persistence across days needed;
                           always overwritten at next dawn.
```

No additional StorageUtil state. The holy-day calendar is read-only JSON.

---

## 8. Verifier / Self-Test Expectations

Extend `tools/pdv_verify.mjs` or `pdv_living_deities_selftest.mjs`:

- Calendar compiler self-test: no duplicate (deity, absoluteDayOfYear); multipliers
  in [1.0, 2.0]; window bonus in [0, 7]; all deity names resolve.
- Runtime proof (Block E): on a dawn that lands on a holy day, confirm:
  (a) `Debug.Trace` shows the amplified `dailyContribution` for that deity
  (b) Mood delta is >= 1.5x the non-holy baseline for that day
  (c) Demand window on a holy-day offer is base+2 days (or base+bonus)
  (d) On consecutive non-holy days, mood returns toward the EWMA trajectory
      expected without amplification (no permanent uplift)
- Anti-abuse gate: author a console test forcing two consecutive holy days for
  the same deity (via debug day-override or save manipulation) and confirm the
  mood does NOT exceed +100 and does NOT persist above the trajectory without
  continued signal.
- Stance-ceiling gate: confirm a FOREIGN deity on its name day still cannot
  exceed Pleased band.

---

## 9. Summary of Modulated Knobs (traceability)

| Knob | Function | Effect |
|---|---|---|
| `dailyContribution` in EWMA | `RunDawnUpdateMoodForDeity` (`:10384`) | Amplified by `moodGainMultiplier` on holy day |
| `windowDays` | `OfferDemand` (`:10528`) | Extended by `demandWindowBonusDays` on holy day |
| `DownCrossPending` gate bypass | `IsEligibleForDemandOffer` (`:10504`) | Holy-day demand eligible even from Cool |
| Mood band ceiling | `GetMoodBandCeiling` (`:10342`) | Unchanged -- stance ceiling always applies |
| `GetDemandMoodSwing` | `:10677` | Unchanged -- swing magnitude is per-alpha, not per holy day |
| `PIETY_DAILY_MAX_DELTA` (`:323`) | Clamp in `RunDawnConsolidateScratch` | Unchanged -- piety (not mood) is still capped normally |
