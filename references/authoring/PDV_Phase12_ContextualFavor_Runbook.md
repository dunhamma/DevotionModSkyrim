# PDV Phase 12 Contextual Favor Runbook

## Purpose

This runbook closes the gap between the Phase 12 manifest, the live manager runtime, and the narrow source-plugin helper.

Phase 12 remains intentionally narrow:

- `tools/pdv-phase12-author` can create the missing Phase 12 `KYWD` / `MGEF` / `SPEL` records when invoked with `--create-missing`
- the helper also fills spell/effect membership, family keywords, the Nord baseline track script attachment, and manager property wiring
- the verifier proves the runtime contract, record presence, lane counts, manager wiring, and Nord baseline track attachment

Do not widen the CKPE capability claim from this work. Generic safe source-plugin record creation outside the Phase 12 manifest remains out of scope.

## Locked Runtime Scope

The first live favor phase contains exactly three lanes:

1. focused `Kyne`
2. `Nord Broad Old Ways`
3. `Nord Broad Nine Divines`

The one-active favor cap is global. Phase 12 suppresses new activation while a favor is active. It does not replace or refresh an already-active favor in place.

## Normal Helper Workflow

Run dry-run first:

```powershell
dotnet run --project .\tools\pdv-phase12-author -- --dry-run --create-missing
```

Live write:

```powershell
dotnet run --project .\tools\pdv-phase12-author -- --create-missing
```

Helper contract:

- takes a timestamped backup of `PlayerDevotion_Framework.esp`
- uses `references/authoring/PDV_Phase12ContextualFavorPilot.manifest.json` as the source of truth for the Phase 12 favor record set
- creates missing Phase 12 `KYWD`, `MGEF`, and `SPEL` records only when `--create-missing` is supplied
- creates `PDV_State_NordPantheonBaseline` only if it is actually absent
- fills names/descriptions, spell-to-effect membership, family keywords, the Nord baseline `PDV_StateTrack` attachment, and `PDV__ManagerQuest` object properties
- remains conservative by default: without `--create-missing`, the helper still fails on missing records instead of creating them implicitly

## Fallback Manual Path

Use manual CK/xEdit creation only if the helper is blocked by a real record-type conflict or the direct in-place write path is unavailable.

Manual fallback inventory:

- `PDV_State_NordPantheonBaseline`
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
- `PDV_Favor_Kyne_OpenSkyRestRecovery`
- `PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery`
- `PDV_Favor_Kyne_StormRoadGrace`
- `PDV_SPEL_Favor_Kyne_StormRoadGrace`
- `PDV_Favor_Kyne_GuidedHunt`
- `PDV_SPEL_Favor_Kyne_GuidedHunt`
- `PDV_Favor_Kyne_WindMarkedPassage`
- `PDV_SPEL_Favor_Kyne_WindMarkedPassage`
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

## Verifier Workflow

Once the helper has run:

```powershell
node .\tools\pdv_verify.mjs --strict-phase12
node .\tools\pdv_verify.mjs --strict-phase12 --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

`--strict-phase12` is responsible for:

- required Phase 12 favor records
- manager property wiring
- `PDV_State_NordPantheonBaseline` existing as `QUST`
- `PDV_StateTrack` attached to `PDV_State_NordPantheonBaseline`
- lane trigger counts
- one-active storage contract in source
- broad-lane Tier 2 / Faithful cap posture

## Closeout Evidence (Phase 12)

- Automated gate pass (2026-05-26):
  - `node .\tools\pdv_verify.mjs --strict-phase12 --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving`
  - Result: `FAIL=0, WARN=0, TODO=0, PASS=1060, INFO=28`
- Helper evidence (dry-run, no writes):
  - `dotnet run --project .\tools\pdv-phase12-author -- --dry-run --create-missing`
  - Result: PASS, no file writes, favor records and `PDV__ManagerQuest` properties reported as wired.
- Runtime proof pass (2026-05-26):
  - Focused `Kyne`: all 4 favor families passed.
  - `Nord Broad Old Ways`: all 5 favor families passed.
  - `Nord Broad Nine Divines`: all 5 favor families passed.
  - Active favor suppression passed: second trigger attempt did not replace an already-active favor.
  - Non-Nord block passed on a fresh Breton character.
  - Persistence passed for both `save/load while active` and `save/load after expiry`.

Phase 12 runtime proof is complete. Further runtime work on this subsystem should be treated as regression coverage, not initial proof.

## Lessons Learned

- Focused `Kyne` runtime eligibility is stricter than the mirror globals suggest. Setting `PDV_GLO_ActiveTier = 3` alone is not enough for debug proving; the manager resolves the focused lane from the live deity ledger via `GetTier(PDV_Kyne)` plus active-patron state, so proof setup must raise the real Kyne piety/tier and not only the UI globals.
- `Trigger selected favor` is the correct debug control even though the MCM labels it `Phase 12 gate`. It still routes through the real manager path and therefore proves actual lane/family eligibility instead of a fake bypass.
- A blank `spell=` field in the pattern summary only means no favor is active. It is not evidence that the helper missed spell membership or property wiring if the same family previously activated and showed the expected `PDV_SPEL_Favor_*` record.
- For persistence proving, use a longer-duration family such as `Nord Broad Old Ways / Sky-road endurance`. The momentary families round to `expires=0.00` too quickly and produce noisy evidence.
- Expiry is stored, but cleanup is not background-polled. The manager clears expired favors when runtime refresh work runs, so the clean manual expiry proof is: trigger a long-duration favor, wait past the expiry window, run `Run dawn pass`, then confirm `Favor=lane=None`.
- Broad-lane proving should start from broad worship directly. It does not require a focused Kyne Champion setup; it requires `PATRON_STATE_BROAD`, `OriginRace = Nord`, and the matching Nord baseline.
- The strongest non-Nord negative is a fresh non-Nord character, not a mid-save `setrace` swap. `PDV_GLO_OriginRace` is captured as origin state, so mid-save race changes can leave ambiguous proof about whether the runtime blocked on live race or stale origin data.
- The efficient MCM proving loop is stable now: set broad/focused state first, select lane, select family, trigger, inspect summary, then clear only when moving to the next proof case. Saving after the summary confirms the active state avoids false persistence failures caused by saving after expiry.

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
