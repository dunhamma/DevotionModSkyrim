# 07 -- World Context Charter (B2 Layer)

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes. Design only.
**Date:** 2026-06-10
**Scope:** B2 = location theology + weather + lunar phase + season + calendar
holidays as a unified mood-multiplier and omen-appropriateness layer.

---

## 1. Novelty Claim

Every reviewed Skyrim faith mod (Wintersun, Pilgrim, Gods & Worship, Pantheon)
treats the world as static backdrop: piety moves only when the player acts.
None of them modulate favor based on where the player is, what the weather is,
or what phase the moons are in. B2 is the first Skyrim faith-mod layer to treat
**world state as an active participant** in the deity relationship -- the god
notices where you are and what the sky is doing, not just what you did.

---

## 2. Relationship to Holy Days (calendar subset)

Holy days (calendar/holy-days/) are a **subset of B2** already fully specced.
See `references/research/holy-days/02_architecture.md`. That spec provides:
- Calendar CSV -> JSON compiler and the `GetHolyDayMoodMultiplier()` pattern
- Per-dawn date check and `PDV.HolyDay.Active` StorageUtil flag
- Multiplier insertion point inside `RunDawnUpdateMoodForDeityWithMult()`
- Anti-abuse bounding (multiplier cap 2.0x; EWMA clamp to [-100, 100])

**This dossier does not re-derive any of that.** It treats holy-day multipliers
as one column of the combined context multiplier table and applies the same
insertion pattern to location, weather, lunar, and season drivers.

---

## 3. The Unified B2 Model

World context acts on the deity relationship through **two distinct surfaces**:

**Surface 1 -- Dawn mood multiplier (same insertion as holy days)**
At each dawn pass, before `RunDawnUpdateMoodForDeityWithMult()` is called for
a given deity, a `GetWorldContextMultiplier(deity)` function aggregates all
active context signals (location family, weather class, lunar phase, season,
holy day) and returns a single combined multiplier clamped to [1.0, MAX_CTX].
This multiplier amplifies (or, for alignment mismatches, attenuates) the
`dailyContribution` term in the EWMA -- the same lever holy days already use.
It applies to `dailyContribution` only, never to the decay term, consistent
with the holy-day architecture.

**Surface 2 -- Omen-appropriateness filter (dispatch time)**
When `OnMoodBandCross()` or a dream dispatch prepares an omen payload, an
`IsOmenAppropriate(omen, context)` check suppresses or redirects the omen
based on current world state. A storm omen does not fire indoors. A wilderness
rapture omen does not fire in a city. This is a filter, not a mood driver --
it does not touch piety or mood values.

These two surfaces are **kept strictly separate**:
- Surface 1 runs once per dawn, per deity, in the consolidation loop.
- Surface 2 runs at omen dispatch time (band-cross, dream check) and is
  stateless: it reads current game state and returns pass/fail.

---

## 4. Per-Driver Roles

| Driver | Surface 1 (dawn mult) | Surface 2 (omen filter) |
|---|---|---|
| Calendar holy days | Yes (handled by holy-days spec) | No |
| Location theology | Yes (affinity weight from CSV) | Yes (indoor/outdoor/hold gate) |
| Weather class | Yes (storm/clear alignment) | Yes (suppress indoor/wrong-weather omen) |
| Lunar phase | Yes (moon-phase weight from table) | No |
| Season | Yes (seasonal affinity weight) | No |

---

## 5. P1 Pilot Scope Recommendation

**Pilot: location + weather for Kyne and Hircine only.**

Rationale:
- Location and weather share one existing live hook (`OnWeatherChange` in
  `PDV_PlayerEvents.psc:216`, `PDV_LastSleepStartedOutside` pattern).
- Kyne (wind/sky/mountain) and Hircine (wild/hunt/forest) have the strongest
  location-theology signal in the existing `location-theology-map.csv` (26
  families). They make the pilot meaningful with minimal authoring.
- Lunar phase reuses the Khajiit substrate's `GetKhajiitMoonPhaseFromGameDay()`
  function (live: `PDV__ManagerQuest.psc:9791`) but requires extending its
  scope beyond Khajiit identity to a cross-deity mood driver -- a separate
  design decision. Defer to B2-P2.
- Season requires a month-to-season mapping and calendar arithmetic. The API
  surface (`Game.GetCalendarDayOfMonth()` / `Game.GetCalendarMonth()`) is
  available (cited in `00_substrate_seam_map.md`) but no live usage exists in
  PDV for dawn-time reads. Defer to B2-P2.

**B2-P1 deliverable:** a `PDV_WorldContextTable.csv` (location family x deity
affinity weight + weather class x deity affinity weight) + a single
`GetWorldContextMultiplier(deity)` function that reads location and weather,
returning a combined multiplier applied alongside the holy-day multiplier. Plus
the `IsOmenAppropriate()` filter scoped to indoor/outdoor and weather class.

---

## 6. Design Principles

1. World context is **strictly a multiplier on what the player already earned**.
   It amplifies or attenuates the daily contribution; it never adds piety points
   independently. A player who did nothing today gets nothing from context.

2. Context never outweighs player action. See bounding in 07_world_context_
   architecture.md section 5.

3. Authoring is data-driven (CSV -> JSON), matching the existing pipeline for
   holy days, mood tables, and demand tables.

4. New Papyrus APIs are not assumed. Every seam must be traced to a live
   function or a verified-available Papyrus native. Unverified APIs are flagged
   as proof items.
