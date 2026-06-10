# 07 -- World Context Architecture (B2 Buildable Spec)

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes.
**Date:** 2026-06-10
**Scope:** B2-P1 pilot (location + weather, Kyne + Hircine). Lunar and season
stubs included for B2-P2 but not specced to build depth.

---

## 1. Data Table: `PDV_WorldContextTable.csv`

New CSV at `references/authoring/PDV_WorldContextTable.csv`.

```
context_driver, context_key, deity, weight, notes
```

| Column | Type | Notes |
|---|---|---|
| `context_driver` | string | `"location"` or `"weather"` or `"lunar"` or `"season"` |
| `context_key` | string | location family ID (from location-theology-map.csv) or weather class ID or phase ID or season ID |
| `deity` | string | Must match `DeityName` on `PDV_DeityBase` (same constraint as holy-days CSV) |
| `weight` | float | Multiplier contribution for this driver when active. Range [0.5, 1.5]. 1.0 = neutral. >1.0 = affinity boost. <1.0 = mild attenuator. |
| `notes` | string | Human-readable rationale. Not used at runtime. |

**Example rows (B2-P1 pilot):**

```
location,wilderness_road,Kyne,1.2,Kyne favors open sky travel
location,animal_den,Kyne,1.15,Hunt and prey grounds
location,animal_den,Hircine,1.3,Hircine's domain
location,nordic_ruin,Kyne,1.1,Ancestor heights
location,city_gate,Kyne,0.9,Diminished under stone roofs
location,interior_generic,Kyne,0.85,Sky god disfavors enclosed spaces
weather,storm,Kyne,1.3,Kyne commands the storm
weather,pleasant,Kyne,1.15,Clear sky is Kyne's favor
weather,rainy,Hircine,1.1,Hunt weather
weather,snow,Hircine,1.2,Deep winter hunt
weather,pleasant,Hircine,0.9,Tame weather, diminished hunt drive
```

**Compiler:** extend `tools/pdv_living_deities_compile.mjs` (or author a sibling
`pdv_world_context_compile.mjs` matching its structure) to:
- Validate `deity` names against `PDV_DeityMood.csv`
- Validate `weight` in [0.5, 1.5] (flag outside range as authoring warning)
- Validate `context_key` against an allowed-values enum per `context_driver`
- Emit `SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_WorldContext.json`

Compiled JSON shape:
```json
{
  "entries": [
    {"driver": "location", "key": "wilderness_road", "deity": "Kyne", "weight": 1.2},
    {"driver": "weather", "key": "storm", "deity": "Kyne", "weight": 1.3}
  ]
}
```

---

## 2. Runtime State: Context StorageUtil Keys

Per-session, written at sleep (location) and on weather change (weather);
consumed at dawn. No cross-day persistence needed -- stale values are inert
because the multiplier defaults to 1.0 when no key matches.

```
PDV.Context.LocationFamily   -- String: resolved family key (e.g. "wilderness_road")
                                Written at OnSleepStart. Consumed at ProcessDawn.
PDV.Context.WeatherClass     -- Int: 0=None, 1=Pleasant, 2=Cloudy, 3=Rainy, 4=Snow
                                Written at OnWeatherChange. Consumed at ProcessDawn.
```

Both keys live on `None` (global namespace), matching the existing pattern for
cross-script state (e.g., `PDV.Khajiit.LastLunarSourceTime`).

---

## 3. Context Sampling -- Insertion Points

### 3.1 Location: extend `OnSleepStart` (PDV_PlayerEvents.psc)

Current live code (`:140-149`):
```
Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
    Actor playerActor = GetActorRef()
    if playerActor
        PDV_LastSleepStartedOutside = !playerActor.IsInInterior()
    ...
```

Extend:
```
; B2: resolve location family for world-context dawn read.
if playerActor
    PDV_LastSleepStartedOutside = !playerActor.IsInInterior()
    String locFamily = ResolveLocationFamily(playerActor)
    StorageUtil.SetStringValue(None, "PDV.Context.LocationFamily", locFamily)
endIf
```

`ResolveLocationFamily(Actor akPlayer)` is a new helper on `PDV_PlayerEvents`
(or delegated to the manager via EventBus). B2-P1 implementation: return
`"interior_generic"` if `akPlayer.IsInInterior()`, else return
`"wilderness_road"` as the base outdoor family. Location keyword resolution
(hold-level, dungeon vs wilderness) is a stretch goal gated on PROOF ITEMS L1
and L2 from 07_world_context_feasibility.md.

### 3.2 Weather: extend `OnWeatherChange` (PDV_PlayerEvents.psc)

Current live code (`:216-218`):
```
Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)
    RouteP2ImmersiveSource(akNewWeather as Form, "po3_weather")
EndEvent
```

Extend:
```
Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)
    RouteP2ImmersiveSource(akNewWeather as Form, "po3_weather")
    ; B2: store weather class for world-context dawn read.
    if akNewWeather
        Int weatherClass = akNewWeather.GetClassification()  ; PROOF ITEM W1
        StorageUtil.SetIntValue(None, "PDV.Context.WeatherClass", weatherClass)
    endIf
EndEvent
```

`Weather.GetClassification()` is flagged as PROOF ITEM W1 -- verify before
wiring. If it proves unavailable, fall back to a FormID-keyed lookup table (CSV
of storm/snow weather FormIDs authored in CK).

---

## 4. The Multiplier Function: `GetWorldContextMultiplier(PDV_DeityBase deity)`

New function on `PDV__ManagerQuest`. Called once per deity per dawn pass,
inside `RunDawnConsolidateScratch()`, before `RunDawnUpdateMoodForDeityWithMult`.

```
Float Function GetWorldContextMultiplier(PDV_DeityBase deity)
    if !JsonUtil.JsonExists(WORLD_CONTEXT_FILE)
        return 1.0
    endIf

    ; Read current context state.
    String locFamily = StorageUtil.GetStringValue(None, "PDV.Context.LocationFamily", "")
    Int weatherClass = StorageUtil.GetIntValue(None, "PDV.Context.WeatherClass", 0)
    String weatherKey = WeatherClassToKey(weatherClass)   ; "none"/"pleasant"/"cloudy"/"rainy"/"snow"

    ; Walk entries, accumulate weights for this deity.
    Float combined = 1.0
    Int count = JsonUtil.GetArraySize(WORLD_CONTEXT_FILE, "entries")
    Int i = 0
    while i < count
        String pfx = "entries[" + i + "]."
        String entryDeity  = JsonUtil.GetStringValue(WORLD_CONTEXT_FILE, pfx + "deity", "")
        String entryDriver = JsonUtil.GetStringValue(WORLD_CONTEXT_FILE, pfx + "driver", "")
        String entryKey    = JsonUtil.GetStringValue(WORLD_CONTEXT_FILE, pfx + "key", "")
        Float  entryWeight = JsonUtil.GetFloatValue(WORLD_CONTEXT_FILE,  pfx + "weight", 1.0)

        if entryDeity == deity.DeityName
            if entryDriver == "location" && entryKey == locFamily
                combined = combined * entryWeight
            elseIf entryDriver == "weather" && entryKey == weatherKey
                combined = combined * entryWeight
            endIf
        endIf
        i += 1
    endWhile

    return ClampValue(combined, WORLD_CONTEXT_MULT_MIN, WORLD_CONTEXT_MULT_MAX)
EndFunction
```

`WeatherClassToKey(Int class)` is a simple String helper (Int 0-4 -> "none",
"pleasant", "cloudy", "rainy", "snow").

**JSON array access pattern:** uses the `entries[N].field` indexing already
proven in the quest-reaction matrix reader (same JsonUtil idiom as the holy-days
spec `GetHolyDayMoodMultiplier()`). See holy-days spec PROOF ITEM P4 for
confirmation of this pattern.

---

## 5. Insertion Point: `RunDawnConsolidateScratch()` (live `:3896`)

The call site for mood updating (LD-P1) already extends the consolidation loop.
In the per-deity loop body, compute the combined multiplier from holy days and
world context before passing to the mood update:

```
; Inside the per-deity loop in RunDawnConsolidateScratch():
Float holyDayMult    = GetHolyDayMoodMultiplier(deity)       ; holy-days spec
Float worldCtxMult   = GetWorldContextMultiplier(deity)      ; B2 this spec
Float combinedMult   = ClampValue(holyDayMult * worldCtxMult, COMBINED_MULT_MIN, COMBINED_MULT_MAX)
RunDawnUpdateMoodForDeityWithMult(deity, clampedToday, combinedMult)
```

`RunDawnUpdateMoodForDeityWithMult` is the LD-P1 renamed (or default-param)
variant of the future `RunDawnUpdateMoodForDeity`. It applies the multiplier to
`dailyContribution` only, not to the decay term (consistent with holy-days spec
section 4.1).

---

## 6. Combined Multiplier Cap and Pacing Bound

**Constants (add alongside holy-days + LD-P1 constants):**
```
Float Property WORLD_CONTEXT_MULT_MIN  = 0.7  AutoReadOnly  ; floor (mild attenuation)
Float Property WORLD_CONTEXT_MULT_MAX  = 1.5  AutoReadOnly  ; ceiling (strong affinity)
Float Property COMBINED_MULT_MIN       = 0.6  AutoReadOnly  ; holy-day * world-context floor
Float Property COMBINED_MULT_MAX       = 2.0  AutoReadOnly  ; holy-day * world-context ceiling
String Property WORLD_CONTEXT_FILE = "PlayerDevotion/PDV_WorldContext" AutoReadOnly
```

**Justification against pacing model (`PIETY_DAILY_MAX_DELTA = 4.3`,
`alpha = 0.12` for Kyne, `alpha = 0.22` for Hircine):**

At the COMBINED_MULT_MAX of 2.0 (only achievable when both a holy day AND a
strong location match co-occur), the mood delta is:
  `alpha * (clampedToday / PIETY_DAILY_MAX_DELTA * 100) * 2.0`
  = `0.22 * 100 * 2.0 = 44` points (Hircine worst case)

This can cross at most two bands in one day (Wroth < -40, Exalted > +55).
The EWMA clamp to [-100, 100] is the absolute backstop. The `COMBINED_MULT_MAX`
of 2.0 matches the holy-days spec's compiler gate; it cannot be exceeded even
if both a 1.5x holy day and a 1.5x location weight apply simultaneously.

`WORLD_CONTEXT_MULT_MAX` = 1.5 ensures that world context alone (no holy day)
cannot move mood by more than `0.22 * 100 * 1.5 = 33` points -- less than the
33-point band-crossing threshold from Pleased to Exalted in one day. A single
favorable weather + location match does not instantly cap a deity's mood.

**The rule:** world context never contributes more than player action on any
given day, because world-context weight applies to `clampedToday`, which is
already zero when the player did nothing that day.

---

## 7. Omen-Appropriateness Filter: `IsOmenAppropriate()`

New function on `PDV__ManagerQuest` (or on `PDV_DiegeticDirector`). Called from
`OnMoodBandCross()` / dream dispatch before any omen payload is sent.

```
Bool Function IsOmenAppropriate(String omenType, String deityName)
    ; Gate 1: indoor suppression for sky/weather omens.
    if omenType == "storm_omen" || omenType == "sky_rapture"
        if Game.GetPlayer().IsInInterior()
            return False   ; storm omen doesn't reach indoors
        endIf
    endIf

    ; Gate 2: city suppression for wilderness omens.
    if omenType == "wilderness_call" || omenType == "hunt_omen"
        String locFamily = StorageUtil.GetStringValue(None, "PDV.Context.LocationFamily", "")
        if locFamily == "city_gate" || locFamily == "court_jarl_space"
            return False   ; wilderness omen doesn't fire in a city
        endIf
    endIf

    ; Default: appropriate.
    return True
EndFunction
```

Omen type tags are authored in `PDV_OmenProfile.csv` (existing from LD-P1 spec
section 2.4). Add an `appropriateness_class` column:
```
deity, transition, toast_key, dream_text_key, tone, appropriateness_class
Kyne, ->Exalted, HolyDay_Kyne_Storm, ..., uplifting, sky_rapture
Hircine, ->Wroth, ..., ..., ominous, hunt_omen
```

The omen filter only suppresses -- it does not redirect. A suppressed omen is
silently dropped; the band-cross still happened. Anti-spam triad handles
rescheduling if needed (per LD-P1 section 3.3).

---

## 8. New Constants and StorageUtil Keys (summary)

**Constants:**
```
String Property WORLD_CONTEXT_FILE       = "PlayerDevotion/PDV_WorldContext" AutoReadOnly
Float Property WORLD_CONTEXT_MULT_MIN    = 0.7  AutoReadOnly
Float Property WORLD_CONTEXT_MULT_MAX    = 1.5  AutoReadOnly
Float Property COMBINED_MULT_MIN         = 0.6  AutoReadOnly
Float Property COMBINED_MULT_MAX         = 2.0  AutoReadOnly
```

**StorageUtil keys (global namespace `None`):**
```
PDV.Context.LocationFamily  -- String: resolved location family key at last sleep
PDV.Context.WeatherClass    -- Int: 0-4 weather classification at last weather change
```

No per-deity context keys. The context state is player-global; the deity
affinity weights are in the JSON table.

---

## 9. Verifier Expectations

Extend `tools/pdv_verify.mjs` / `pdv_living_deities_selftest.mjs`:

- **Compiler gate:** `PDV_WorldContextTable.csv` entries compile without
  unknown deity names; all weights in [0.5, 1.5]; no duplicate
  (deity, driver, context_key) pairs.
- **Runtime proof WC1:** On a dawn after sleeping outdoors in a storm,
  confirm `Debug.Trace` shows `GetWorldContextMultiplier("Kyne")` returning
  a value > 1.0 (both location and weather weights active).
- **Runtime proof WC2:** On a dawn after sleeping indoors with no weather
  change, confirm `GetWorldContextMultiplier("Kyne")` returns <= 1.0 (interior
  attenuator only).
- **Runtime proof WC3:** Confirm the combined multiplier (holy-day * world-ctx)
  is clamped to COMBINED_MULT_MAX before being passed to
  `RunDawnUpdateMoodForDeityWithMult`.
- **Omen filter proof WC4:** In-game, trigger a Kyne storm omen indoors and
  confirm it is suppressed (no toast fired). Trigger the same omen outdoors
  during a storm and confirm it fires.
- **Anti-abuse proof WC5:** On a day with no player acts (`clampedToday = 0`),
  confirm `RunDawnUpdateMoodForDeityWithMult` is called with `clampedToday = 0`
  and the multiplier has no effect on mood output (0 * anything = 0
  contribution).

---

## 10. Owner Decisions Required Before Build

1. **B2-P1 location resolution depth:** is interior/exterior sufficient for
   the pilot, or is hold-level family mapping required? If the latter, PROOF
   ITEMS L1 and L2 must be cleared first.
2. **Weather API fallback plan:** if `Weather.GetClassification()` (PROOF ITEM
   W1) is unavailable or unreliable, authorize a FormID-keyed CSV approach
   instead.
3. **B2-P2 scope gate:** confirm lunar phase and season are explicitly deferred
   and will not be designed until B2-P1 is runtime-proven.
4. **OmenProfile CSV schema change:** adding `appropriateness_class` column
   changes the existing CSV shape (LD-P1 spec section 2.4). Owner must authorize.
