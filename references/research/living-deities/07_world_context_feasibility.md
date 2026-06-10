# 07 -- World Context Feasibility (B2 per-driver)

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes.
**Date:** 2026-06-10
**Honesty bar:** matches `03_feasibility.md`. Every seam is traced to a live
function name or marked as a proof item. No live CK or in-game runtime here;
every path below ends with the specific proof still required.

---

## Grounding

Live source tree: `D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`
PDV__ManagerQuest.psc = 10,197 lines (2026-06-10).
Function names are the contract; line numbers drift.

---

## Driver 1: Location Theology

**Claim:** The player's location family (derived from the existing
`location-theology-map.csv`, 26 families) modifies the dawn mood contribution
for deities with affinities to that family.

**Live seam:**
- `location-theology-map.csv` already exists at
  `references/vanilla-gameplay/pdv-crosswalk/location-theology-map.csv` with 26
  families, examples, vanilla surfaces, and primary deity associations.
  Status: design-seed (not yet compiled to runtime JSON).
- `PDV_PlayerEvents.psc:143`: `PDV_LastSleepStartedOutside =
  !playerActor.IsInInterior()` -- live, proven. This is the cheapest available
  location proxy: interior/exterior resolved at sleep start.
- `Game.GetPlayer().IsInInterior()` -- vanilla Papyrus, confirmed in live usage.
- No live usage of `GetCurrentLocation()` or Location keyword reads in
  `PDV__ManagerQuest.psc` or `PDV_PlayerEvents.psc`. This is unproven territory.

**Sampling options (honest cost):**

Option A -- Dawn-only, interior/exterior flag (CHEAPEST):
  At `ProcessDawn()`, read `PDV_LastSleepStartedOutside` (already persisted on
  the player alias) to get a coarse outdoor/indoor flag. Resolve to a location
  family tier (outdoor = eligible for sky/wilderness deities). One boolean read;
  zero new hooks. Limitation: no hold-level or specific-location resolution.

Option B -- Sample at sleep (existing hook, CURRENT BEST):
  `OnSleepStart` already resolves `IsInInterior()` and stores it. Extend this
  to also sample `Game.GetPlayer().GetCurrentLocation()` and resolve to a
  location family via a JSON table lookup. Write the resolved family key to
  `PDV.Context.LocationFamily`. The dawn pass reads this stored key.
  Cost: one `GetCurrentLocation()` call at sleep, one StorageUtil write.
  Risk: PROOF ITEM L1 -- `GetCurrentLocation()` returns a Location form;
  mapping it to the CSV's 26 families requires either keyword-based matching
  (Location.HasKeyword(), vanilla) or a pre-authored formlist per family.
  Neither has been used in PDV live source. Needs a spike proof.

Option C -- OnUpdate sampling (EXPENSIVE, NOT RECOMMENDED):
  Poll location on the existing 1s manager tick. High overhead, no benefit over
  Option B. Not recommended.

**Recommendation:** Option B. Sample at `OnSleepStart`, resolve to location
family, persist to StorageUtil. Dawn reads the stored family. This is consistent
with the "player mostly was today" framing.

**Confidence:** MEDIUM. The interior/exterior proxy is HIGH confidence (live).
Hold- or family-level resolution is MEDIUM -- it depends on
`GetCurrentLocation()` and keyword/formlist mapping which have no live PDV
precedent.

**Recomposition vs greenfield:**
- Interior/exterior flag: pure recomposition of `PDV_LastSleepStartedOutside`.
- Hold-level family lookup: greenfield. Needs Location.HasKeyword() spike.

**Proof still required (B2-P1):**
- L1: Confirm `Game.GetPlayer().GetCurrentLocation()` returns a non-None
  Location during normal outdoor play (not just in named dungeons).
- L2: Confirm `Location.HasKeyword(keyword)` is a valid vanilla Papyrus call
  and identify at least 2 distinguishing keywords for the Kyne/Hircine-relevant
  families (e.g., LocTypeWilderness, LocTypeDungeon). If keywords are
  insufficient, confirm LCTN FormList authoring is feasible in CK.
- L3: Confirm `StorageUtil.SetStringValue` / `GetStringValue` round-trip at
  sleep persists cleanly through a dawn tick (known to work; confirm no race on
  load-game path).

---

## Driver 2: Weather

**Claim:** The current weather class (storm, clear, fog, snow, rain) modifies
the dawn mood contribution for storm- or sky-aligned deities (Kyne: storm
positive / clear positive; Hircine: storm negative / rain irrelevant).

**Live seam:**
- `PDV_PlayerEvents.psc:216-218`: `Event OnWeatherChange(Weather akOldWeather,
  Weather akNewWeather)` calling `RouteP2ImmersiveSource(akNewWeather as Form,
  "po3_weather")`. LIVE and proven. Registered via
  `PO3_Events_Alias.RegisterForWeatherChange(Self)`.
- `PDV_PlayerEvents.psc:1024-1032`: the `po3_weather` anti-farm gate (once per
  in-game day per weather FormID). Proven.
- The weather Form passed to `RouteP2ImmersiveSource` is used for FormID-keyed
  dedup today; it is not classified by type.

**Weather class resolution (PROOF ITEM W1):**
  Vanilla Papyrus offers `Weather.GetClassification()` (returns an Int: 0=None,
  1=Pleasant, 2=Cloudy, 3=Rainy, 4=Snow). This maps cleanly to the B2 weather
  classes needed. However, this function has **no live usage in PDV source**.
  Must be confirmed against the SKSE/PapyrusUtil version in Anvil.
  Alternative: tag weather FormIDs in a CSV (storm = Frostfall/Kyne-weather
  FormIDs). Less elegant but zero API risk.

**Sampling strategy:**
  Option A -- Store weather class at `OnWeatherChange` (RECOMMENDED):
    When `OnWeatherChange` fires, call `akNewWeather.GetClassification()` and
    write the Int to `StorageUtil.SetIntValue(None, "PDV.Context.WeatherClass",
    classInt)`. Dawn reads `PDV.Context.WeatherClass`. This is a write-on-change
    pattern, not polling. Cost: one StorageUtil write per weather transition.
  Option B -- Read at dawn:
    Call `Game.GetCurrentWeather().GetClassification()` inside `ProcessDawn()`.
    Risk: `Game.GetCurrentWeather()` is a vanilla Papyrus function but has no
    live PDV usage -- PROOF ITEM W2. Option A is safer because it reuses the
    proven `OnWeatherChange` hook.

**Omen filter:** Storm omen should not fire indoors. `IsOmenAppropriate()` at
dispatch time: read `Game.GetPlayer().IsInInterior()` and suppress storm omens
indoors. Vanilla API, proven in live PDV via `IsInInterior()` usage.

**Confidence:** HIGH for the hook (live, proven). MEDIUM for
`GetClassification()` (no live PDV usage; needs proof).

**Recomposition vs greenfield:**
  Hook: pure recomposition. Weather-class read: greenfield (new API usage).
  StorageUtil pattern for context state: recomposition of existing pattern.

**Proof still required (B2-P1):**
- W1: Confirm `Weather.GetClassification()` returns expected Int values for
  Skyrim's weather forms (particularly storms and blizzards).
- W2: If Option B is chosen, confirm `Game.GetCurrentWeather()` returns a valid
  Weather form during normal play (not None).

---

## Driver 3: Lunar Phase

**Claim:** The moon phase modifies the dawn mood contribution for moon-aligned
deities (Khajiit: Riddle'Thar/Khenarthi; potentially Molag Bal for blood moon;
Y'ffre for specific cycles). Reuses the existing lunar substrate's phase read.

**Live seam:**
- `GetKhajiitMoonPhaseFromGameDay(Float gameDay)` at `PDV__ManagerQuest.psc:9791`
  (live, proven): takes `Utility.GetCurrentGameTime()` and returns an Int 1-8
  (28-day cycle, 8 phases). Pure arithmetic; no Papyrus native risk.
- `PDV_Substrate_KhajiitLunar.GetLastObservedPhase()`: returns the last
  phase the substrate recorded for a Khajiit player. For non-Khajiit or when
  the substrate has not yet observed, falls back to the arithmetic function.
- `PDV_Substrate_KhajiitLunar.psc` is live and locked (proven in game).

**Cross-deity extension:**
  For B2 lunar, the phase read is `GetKhajiitMoonPhaseFromGameDay()` called
  from the dawn context pass. This function is already on the manager and needs
  no new API. The lunar substrate's `GetLastObservedPhase()` is Khajiit-player-
  gated and must NOT be called for non-Khajiit deity context reads -- use the
  arithmetic function directly.

**Scope:** Lunar phase is B2-P2, not B2-P1 pilot. The phase function is
recomposition; the cross-deity authoring (which deities care about which phases)
is a new data table.

**Confidence:** HIGH for phase arithmetic (proven). MEDIUM for cross-deity
authoring (no phase-deity table exists yet; needs design).

**Recomposition vs greenfield:**
  Phase read: recomposition. Cross-deity weight table: greenfield (authoring).

**Proof still required (B2-P2):**
- LU1: Confirm the 28-day cycle in `GetKhajiitMoonPhaseFromGameDay()` aligns
  with vanilla Skyrim's actual Masser/Secunda cycle (or document the intentional
  simplification).
- LU2: Design the per-deity phase affinity table (which deities, which phases,
  what weight range). Owner decision required before authoring.

---

## Driver 4: Season

**Claim:** The current in-game month maps to a season (4 seasons x 3 months),
which modifies the dawn mood contribution for seasonally-aligned deities
(Kyne: late autumn/winter storms positive; Dibella: spring positive; etc.).

**Live seam:**
- `Game.GetCalendarDayOfMonth()` and `Game.GetCalendarMonth()` -- cited in
  `00_substrate_seam_map.md` as available. Both are vanilla Papyrus functions.
  **No live usage in PDV source for either.** Both are PROOF ITEMS.
- `Utility.GetCurrentGameTime() as Int` is the proven day-count pattern. Month
  derivation from the absolute day count is arithmetic:
    `Int month = (gameDayInt / 30) % 12 + 1`  (rough; exact epoch proof needed).
  The holy-days spec uses the equivalent day-of-year pattern -- month derivation
  is the same arithmetic extended one step.

**Scope:** Season is B2-P2. No live PDV season reads exist.

**Confidence:** LOW-MEDIUM. The arithmetic path is tractable but the correct
epoch offset (same concern as holy-days spec PROOF ITEM P1) must be verified
before any season logic is authored.

**Recomposition vs greenfield:**
  All greenfield. No existing seasonal logic in PDV source.

**Proof still required (B2-P2):**
- S1: Confirm `Game.GetCalendarMonth()` returns an Int in [1,12] and maps
  cleanly to Skyrim's Imperial calendar month names (same verification as
  holy-days spec epoch proof).
- S2: Alternatively, confirm the arithmetic month derivation from
  `Utility.GetCurrentGameTime() as Int` with the correct epoch offset.
- S3: Owner decision: which deities get seasonal affinity weights? Scope the
  authoring surface before building.

---

## Summary Verdicts

| Driver | Confidence | Recomp vs Green | B2-P1 or P2 | Blockers |
|---|---|---|---|---|
| Location (interior/exterior) | HIGH | Recomposition | P1 | None -- proven seam |
| Location (hold/family level) | MEDIUM | Greenfield | P1 (stretch) | L1, L2 |
| Weather class | HIGH hook / MEDIUM API | Mostly recomp | P1 | W1 |
| Lunar phase | HIGH arithmetic | Recomp + greenfield table | P2 | LU1, LU2 |
| Season | LOW-MEDIUM | Greenfield | P2 | S1 or S2, S3 |
| Holy days | PROVEN | Recomposition | Subset (done) | None |
