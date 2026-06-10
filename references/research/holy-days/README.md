# Holy Days & Festivals -- Bucket 2 Design Charter

**Status:** DESIGN DOSSIER ONLY. No Papyrus/CK/ESP changes in this deliverable.
Sequenced after LD-P1/LD-P2 are runtime-proven.

---

## What Holy Days Add

Holy days are calendar-fixed dates on which a deity's influence is intensified.
On that deity's name day (or feast day), two things happen inside the existing
LD engine, with no new runtime loop:

1. **Mood gain is amplified.** The daily `clampedToday` contribution to that
   deity's mood EWMA is multiplied by a `moodGainMultiplier` (e.g. 1.5x). The
   player who was already doing the right things feels the deity's pleasure
   more sharply; the player doing nothing notices a steeper pull toward Cool.

2. **A demand window opens wider (or sooner).** If a demand would normally
   expire in `windowDays`, on a holy day the effective window is extended by
   `demandWindowBonus` days (e.g. +2d). Alternatively, the offer threshold
   for that deity's demand check is softened: the deity is willing to ask
   on a holy day even if mood has not yet down-crossed. This is the "special
   demand window" described in the Bucket 2 seed.

Nothing else changes. The mood EWMA, band thresholds, omen dispatch,
`GetDemandMoodSwing`, and anti-abuse caps are all unchanged.

---

## Why This Is Natural in the Engine

The LD-P1 dawn loop already calls `RunDawnUpdateMoodForDeity` and
`RunDawnProcessDemands` once per dawn. A holy day is just a per-dawn flag
("today is Kyne's day") that adjusts two inputs into those existing functions.
It does not fork the loop, add a tick, or introduce new state per deity --
it only modulates constants the loop already uses.

---

## Lore-Grounded Sample Calendar

Skyrim's in-game calendar uses the Imperial calendar: 12 months of 30 days
each (360 days/year). Each month corresponds to a named period. The game
starts in the 4th Era, Year 201.

Sources below note which are attested in TES lore sources (UESP, in-game
books) and which are plausible extrapolations flagged as [PLACEHOLDER].

### Month names (Imperial Calendar)

| Month | # | Name |
|---|---|---|
| 1 | Jan | Morning Star |
| 2 | Feb | Sun's Dawn |
| 3 | Mar | First Seed |
| 4 | Apr | Rain's Hand |
| 5 | May | Second Seed |
| 6 | Jun | Midyear |
| 7 | Jul | Sun's Height |
| 8 | Aug | Last Seed |
| 9 | Sep | Hearthfire |
| 10 | Oct | Frostfall |
| 11 | Nov | Sun's Dusk |
| 12 | Dec | Evening Star |

### Attested Feast Days (TES lore)

| Date | Deity | Feast name | Source | Notes |
|---|---|---|---|---|
| Month 6 Day 16 | Kyne / Kynareth | "Tibedetha" (Festival of Blades; Kyne's storm war-aspect) | In-game book "The Warrior's Charge" | Attested for Kyne martial aspect; also associated with Talos/Tiber Septim in some sources. |
| Month 9 Day 13 | Arkay | "Arkay's Day" / Day of the Dead | UESP / TES lore | Festival of remembrance. |
| Month 12 Day 28 | Akatosh | "South Wind's Prayer" (Akatosh's solstice vigil) | In-game "The Dragon Break Re-Examined" | Dragon God of Time at year-end. |
| Month 3 Day 7 | Dibella | "Flower Day" | UESP | Spring festival of beauty and love. |
| Month 1 Day 1 | New Year -- multiple deities share | "New Life Festival" | ESO canon; plausible for SSE | Observed by most Imperial-adjacent races. |

### Plausible / Extrapolated Dates (PLACEHOLDER -- owner decision required)

| Date | Deity | Suggested name | Rationale |
|---|---|---|---|
| Month 10 Day 15 | Hircine | "The Hunt's Height" | Mid-Frostfall: prey is lean and desperate; the hunt is hardest and most sacred. [PLACEHOLDER] |
| Month 8 Day 20 | Kyne | "Storm's Breath" | Late Last Seed, before the harvest closes; storm season begins in Skyrim. [PLACEHOLDER] |
| Month 5 Day 14 | Mara | "Heart Day" | Spring pairing season, already faintly attested in ESO as an Aedric love observance. [PLACEHOLDER] |
| Month 11 Day 6 | Arkay | "Mourning Bell" | Early Sun's Dusk, first hard frost; second Arkay window (winter dead). [PLACEHOLDER] |
| Month 2 Day 3 | Azura | "Azura's Dawn" | Sun's Dawn = Azura's dawn-dusk domain; first dawn after deepest winter. [PLACEHOLDER] |

### P1 Pilot Scope

For LD-P1 (Kyne + Hircine pilot), wire exactly two holy days:

- **Kyne: Month 8 Day 20** ("Storm's Breath") [PLACEHOLDER -- owner confirms date]
- **Hircine: Month 10 Day 15** ("The Hunt's Height") [PLACEHOLDER -- owner confirms date]

All other entries are backlog pending LD-P2+ deities.

---

## Scope

| Phase | Content |
|---|---|
| P1 Pilot | Two holy days (Kyne + Hircine); calendar CSV + JSON; date-check helper; `RunDawnUpdateMoodForDeity` mood-multiplier injection; demand window bonus; verifier gate |
| P2 Backlog | Expand to all LD-P2 deities (Dibella, Mara, Arkay, Azura, etc.) |
| Post-P2 | Multi-day festival windows (e.g. "New Life Week"); cross-deity shared feast days; MCM holy-day density slider |
