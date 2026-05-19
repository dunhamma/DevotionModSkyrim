# PDV Phase 4 Matrix Cross-Validation

Status: Living validation note for the Phase 4 matrix pass
Last revised: 2026-05-19

## Files Validated

- `references/phase4/PDV_Phase4_MatrixScaffold.md`
- `references/phase4/PDV_RaceSignalMatrix.csv`
- `references/phase4/PDV_StanceMatrix.csv`
- `references/phase4/PDV_DaedricRacePrinceMatrix.csv`

## Coverage Check

### Race signal matrix

Current row counts by race:

- `Nord`: 6
- `Imperial`: 6
- `Breton`: 6
- `Altmer`: 6
- `Bosmer`: 6
- `Dunmer`: 6
- `Khajiit`: 8
- `Argonian`: 7
- `Orc`: 6
- `Redguard`: 6

Interpretation:

- Every race has enough rows to represent its locked architecture, its major
  quest-weighted signals, and its first-release curse/pressure hooks.
- `Khajiit` and `Argonian` intentionally carry more rows because their locked
  architectures are layered and substrate-heavy rather than simple patron-choice
  models.

### Stance matrix

- `45` worship objects currently covered.
- Coverage includes:
  - Phase 4 core proof anchors (`Kyne`, `Talos`)
  - major Aedric / Aldmeri / Yokudan / Khajiiti / Orc / Argonian anchors
  - key Daedric pressures needed for rivalry and path-planning

### Daedric matrix

- `16` vanilla Skyrim-facing Prince surfaces currently covered.
- This means the `15` normal Daedric quest/artifact routes plus Nocturnal's
  Thieves Guild / Nightingale surface.
- Nocturnal is a questline/oath exception, not a normal standalone Daedric
  quest. The Skeleton Key does not count toward vanilla Oblivion Walker.
- Jyggalag is out of first-release scope unless future Creation Club or
  Sheogorath/Jyggalag content is explicitly adopted.

Implementation handoff check:

- The current CSV is sufficient for architecture alignment, race-sheet sync,
  and first-pass path planning.
- It is not, by itself, the final data shape for CK/Papyrus implementation.
  Each implemented Prince/race pairing must be expanded into the Section 11
  contract fields in `references/PDV_RaceArchitecture_DesignReference.md`.
- The expansion must preserve the source distinction between normal Daedric
  quest/artifact routes, Nocturnal's faction-oath surface, curse-state surfaces
  for Molag Bal and Hircine, and out-of-scope Jyggalag material.
- Race-sheet prose is acceptance context only; implementation should use the
  matrix plus the Section 11 contract as the build source.
- `PDV_Architecture_v3.md` Section 21.5 now treats this expansion as the Slice
  8 entry gate before any Prince/race implementation begins.

## Validation Rules Applied

### 1. Race signal rows must map to locked architecture

Pass.

No race signal row invents a new path outside the locked race file. The
matrix stays within:

- broad-vs-focused systems where those are locked
- layered substrate models where those are locked
- mode/sect/path structures already confirmed in the race architecture file

### 2. Strong quest signals must outweigh ambient drift where required

Pass.

The signal matrix consistently gives quest/faction milestones the heavier,
cleaner hooks when the race file calls for them:

- `Imperial`: Concordat / Thalmor / Talos protection
- `Breton`: occult, knightly, and Druidic fork content
- `Dunmer`: Azura / Boethiah / Mephala plus diaspora solidarity
- `Altmer`: Thalmor alignment and Lorkhan-adjacency acts
- `Khajiit`: caravans, Azura's Star, Thieves Guild, main-quest dragon order
- `Bosmer`: path-defining quest outcomes over weak ambient simulation
- `Redguard`: sect identity and funerary burden through explicit quest content
- `Orc`: Blood-Kin, stronghold acceptance, and mode-defining tests
- `Argonian`: Assemblage/community hooks over fake richness

### 3. Repeatable signals must carry anti-farm rules

Pass.

All repeatable or daily-capped rows now include a throttling rule such as:

- one-per-day caps
- location rotation
- immediate-repeat suppression
- milestone-only gating
- style/context requirements instead of raw action counts

### 4. No Daedric matrix row may overwrite a native race substrate

Pass.

This was checked explicitly for:

- `Khajiit` lunar substrate
- `Dunmer` ancestor layer
- `Redguard` ancestor reverence layer
- `Argonian` Hist/community/Sithis structure
- `Orc` Malacath mode architecture

No Daedric row claims to replace those baseline layers.

## Crosswalk Rules Between Matrices

The stance matrix and Daedric matrix do not use the same vocabulary.
Consistency therefore means directional agreement, not literal string identity.

### Stance matrix

Uses:

- `NATIVE`
- `FOREIGN`
- `TABOO`
- `HOSTILE`

### Daedric matrix

Uses:

- `Native`
- `Legible`
- `Tolerated`
- `Taboo`
- `Hostile`
- `Curse`

### Intentional crosswalk

- `NATIVE` should usually align with `Native`
- `FOREIGN` may align with `Foreign`, `Legible`, or `Tolerated`
- `TABOO` should usually align with `Taboo`, but may become `Legible` where the
  race file explicitly says the pressure is understandable without becoming
  orthodox
- `HOSTILE` should align with `Hostile`
- `Curse` is an override state, not a contradiction

## Intentional Divergences Kept

These differences are intentional and should not be "fixed" later without a
real architecture decision.

### Bosmer + Hircine

- Stance matrix: `TABOO`
- Daedric matrix: `Legible`

Reason:

- Bosmer do not treat Hircine as a normal core path
- But Wild Hunt / beast-shape adjacency makes him theologically legible in a
  way that simple `Foreign` would undersell

### Khajiit + Nocturnal

- Stance matrix: `TABOO`
- Daedric matrix: `Taboo`

Reason:

- `Rajhin` remains the native trickster lane
- `Nocturnal` is external pressure, not native thief theology

### Khajiit + Hermorah / Hermaeus Mora

- Stance matrix: `FOREIGN`
- Daedric matrix: `Legible`

Reason:

- Khajiit lore can understand Hermorah
- But the locked Daedric baseline does not grant Hermorah the same native
  integration status as `Azurah`, `Boethra`, or `Mafala`
- The matrix therefore keeps Khajiit understanding without promoting the lane
  into a native default path

### Meridia in several human cultures

- Stance matrix: `FOREIGN`
- Daedric matrix: often `Tolerated`

Reason:

- The stance taxonomy has no separate `TOLERATED` bucket
- `FOREIGN` is the correct implementation-side collapse for a non-native but
  not maximally taboo path

### Hircine and Molag Bal under curse states

- Stance matrix: often `TABOO` or `FOREIGN`
- Daedric matrix: often `Curse`

Reason:

- The race-level culture may reject the Prince
- The curse-state architecture still makes the Prince mechanically relevant

## Specific Fixes Made During Validation

### Fixed

- `Hermaeus Mora / Hermorah` for `Khajiit` was lowered from `NATIVE` to
  `FOREIGN` in the stance matrix so it matches the locked Daedric baseline more
  honestly.
- `Nocturnal` for `Khajiit` was tightened from `FOREIGN` to `TABOO` in the
  stance matrix so it better matches the explicit "external pressure, not native
  trickster lane" rule.
- `Azura / Azurah` for `Orc` was tightened from `Foreign` to `Taboo` in the
  Daedric matrix so it matches the stance-side cultural reading beside
  `Malacath`.

### Left unresolved on purpose

- `Shor` / `Sep` / `Lorkhaj` remain separated rather than force-merged.
- `Trinimac` remains pressure/memory rather than a standard Orc progression
  path.
- `Bosmer` Hircine remains a pressure lane rather than a core path.

## Outcome

This matrix pass is internally consistent enough to support:

- Phase 4 implementation planning
- Kyne stance seeding
- Talos second-deity planning
- Daedric path prioritization
- later CK/property data entry without flattening the race architectures

The main remaining implementation dependency is still Phase 3 runtime closure,
not additional matrix logic discovery.
