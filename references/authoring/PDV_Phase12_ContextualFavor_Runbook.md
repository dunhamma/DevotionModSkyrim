# PDV Phase 12 Contextual Favor Runbook

## Purpose

This runbook closes the gap between the Phase 12 manifest, the live manager runtime, and the narrow source-plugin helper.

Phase 12 is intentionally conservative:

- manual CK/xEdit shells are acceptable for new `MGEF` / `SPEL` / `KYWD` assets
- `tools/pdv-phase12-author` fills and wires those shells
- the verifier proves the runtime contract, record presence, lane counts, and manager wiring

Do not widen the CKPE capability claim from this work. Generic safe source-plugin `MGEF` / `SPEL` / `KYWD` creation is still out of scope.

## Locked Runtime Scope

The first live favor phase contains exactly three lanes:

1. focused `Kyne`
2. `Nord Broad Old Ways`
3. `Nord Broad Nine Divines`

The one-active favor cap is global. Phase 12 suppresses new activation while a favor is active. It does not replace or refresh an already-active favor in place.

## Manual CK/xEdit Shells

Create or confirm these shells before running the helper.

### 1. Nord baseline track

Confirm `PDV_State_NordPantheonBaseline` exists and is usable by `PDV__ManagerQuest`.

- State labels:
  - `OldWays = 0`
  - `NineDivines = 1`
- This track stores setup framing only.
- Do not encode `Broad` or `Primary` in this track.

### 2. Family keywords

Create:

- `PDV_FavorFamily_OpenSkyRecovery`
- `PDV_FavorFamily_RoadGrace`
- `PDV_FavorFamily_GuidedHunt`
- `PDV_FavorFamily_WindPassage`
- `PDV_FavorFamily_HonorableOrdeal`
- `PDV_FavorFamily_HoldDefense`
- `PDV_FavorFamily_AncestorQuiet`
- `PDV_FavorFamily_TalosPressure`
- `PDV_FavorFamily_MercyDuty`
- `PDV_FavorFamily_ProperDeath`
- `PDV_FavorFamily_HonestWork`

### 3. Focused Kyne shells

- `PDV_Favor_Kyne_OpenSkyRestRecovery`
- `PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery`
- `PDV_Favor_Kyne_StormRoadGrace`
- `PDV_SPEL_Favor_Kyne_StormRoadGrace`
- `PDV_Favor_Kyne_GuidedHunt`
- `PDV_SPEL_Favor_Kyne_GuidedHunt`
- `PDV_Favor_Kyne_WindMarkedPassage`
- `PDV_SPEL_Favor_Kyne_WindMarkedPassage`

### 4. Nord Broad Old Ways shells

- `PDV_Favor_NordBroadOldWays_SkyRoadEndurance`
- `PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance`
- `PDV_Favor_NordBroadOldWays_HonorableOrdeal`
- `PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal`
- `PDV_Favor_NordBroadOldWays_HearthAndHoldDefense`
- `PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense`
- `PDV_Favor_NordBroadOldWays_DeathRightAncestorQuiet`
- `PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet`
- `PDV_Favor_NordBroadOldWays_HiddenTalosDefiance`
- `PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance`

### 5. Nord Broad Nine Divines shells

- `PDV_Favor_NordBroadNineDivines_KynarethRoadGrace`
- `PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace`
- `PDV_Favor_NordBroadNineDivines_HouseholdAndMercyDuty`
- `PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty`
- `PDV_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy`
- `PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy`
- `PDV_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft`
- `PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft`
- `PDV_Favor_NordBroadNineDivines_TalosPressureInsideTheNine`
- `PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine`

## Helper Workflow

Run dry-run first:

```powershell
dotnet run --project .\tools\pdv-phase12-author -- --dry-run
```

Live write:

```powershell
dotnet run --project .\tools\pdv-phase12-author
```

Helper contract:

- takes a timestamped backup of `PlayerDevotion_Framework.esp`
- assumes shells already exist
- fills names/descriptions and spell-to-effect membership
- assigns family keywords to the listed magic effects
- wires `PDV__ManagerQuest` Phase 12 object properties
- does not claim generic record creation support

## Verifier Workflow

Once shells are present and the helper has run:

```powershell
node .\tools\pdv_verify.mjs --strict-phase12
node .\tools\pdv_verify.mjs --strict-phase12 --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

`--strict-phase12` is responsible for:

- required Phase 12 favor records
- manager property wiring
- Nord baseline track wiring
- lane trigger counts
- one-active storage contract in source
- broad-lane Tier 2 / Faithful cap posture

## Runtime Proof Order

1. Focused `Kyne`:
   - open-sky rest recovery
   - storm-road grace
   - guided hunt
   - wind-marked passage
2. `Nord Broad Old Ways`
3. `Nord Broad Nine Divines`
4. Anti-stack and save/load sanity

Negative proof:

- wrong deity for focused Kyne
- Kyne below Champion
- non-Nord for Nord broad lanes
- active primary patron suppresses broad lanes
- a second favor does not fire while one is active
