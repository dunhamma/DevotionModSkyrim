# PDV Phase 20 Orc Proof Placement Runbook

## Purpose

This runbook is the runtime proof packet for the first Orc life-mode proof
slice plus the Four Holds route-proof extension. The source, life-mode state
track, manager wiring, EventBus routes, proof ACTI base records, and QASmoke
proof references are automation-authored and verifier-covered. The remaining
work is in-game proof: activate the proof surfaces, confirm status/log
movement, and record the negative checks.

These proof activators are a QASmoke test cluster. They prove route wiring,
life-mode status text, anti-farm behavior, parity between Stronghold, City, and
Legion/Exile play, and Four Holds route wiring. They are not the final
immersive world hooks for craft quality, Blood-Kin crisis, city dignity,
service pressure, or real stronghold first-arrival placement.

## Preconditions

- Active MO2 profile: `Devotion Dev`.
- Active plugin in CK: `PlayerDevotion_Framework.esp`.
- `PDV__ManagerQuest.pex`, `PDV_EventTypes.pex`, `PDV_EventBus.pex`, and
  `PDV_EventSignalActivator.pex` are current.
- `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
  is clean except for the known unnamed `INFO` warning.
- `dotnet run --project .\tools\pdv-phase20-orc-author -- --check-placements`
  returns `Status = PASS`.
- `dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --check-placements`
  returns `Status = PASS`.

## Proof Placement Contract

Place one reference for each already-wired ACTI base record.

| Base ACTI | Placed REFR EditorID | Runtime proof |
|---|---|---|
| `PDV_ACTI_OrcStrongholdForgeSignal` | `PDV_REFR_OrcStrongholdForgeSignal` | Stronghold forge route `70` proves craft-as-code without raw crafting loops. |
| `PDV_ACTI_OrcCityDignitySignal` | `PDV_REFR_OrcCityDignitySignal` | City dignity route `71` proves City Orc is a complete life, not failed Stronghold play. |
| `PDV_ACTI_OrcLegionServiceSignal` | `PDV_REFR_OrcLegionServiceSignal` | Legion/Exile route `72` proves pressure-bearing service can carry the code. |
| `PDV_ACTI_OrcSelfMadeCommunitySignal` | `PDV_REFR_OrcSelfMadeCommunitySignal` | Self-made community route `73` proves chosen belonging outside a stronghold. |
| `PDV_ACTI_OrcFourHolds_DushnikhYalSignal` | `PDV_REFR_OrcFourHolds_DushnikhYalSignal` | Four Holds route `75`, hold `1`, proves Dushnikh Yal one-shot visit routing. |
| `PDV_ACTI_OrcFourHolds_MorKhazgurSignal` | `PDV_REFR_OrcFourHolds_MorKhazgurSignal` | Four Holds route `75`, hold `2`, proves Mor Khazgur one-shot visit routing. |
| `PDV_ACTI_OrcFourHolds_NarzulburSignal` | `PDV_REFR_OrcFourHolds_NarzulburSignal` | Four Holds route `75`, hold `3`, proves Narzulbur one-shot visit routing. |
| `PDV_ACTI_OrcFourHolds_LargashburSignal` | `PDV_REFR_OrcFourHolds_LargashburSignal` | Four Holds route `75`, hold `4`, proves Largashbur one-shot visit routing and the all-holds milestone after the fourth unique hold. |

The ACTI base records already carry `PDV_EventSignalActivator` with the correct
route IDs, origin gate, source IDs, and daily keys. The proof references are
placed in `QASmoke` by:

```powershell
dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --place-missing
```

Do not hand-edit the base ACTI scripts in CK during this pass. If a
script/property looks missing, stop and rerun the relevant author helper instead
of hand-filling it.

## Readback

Run the placement-specific readback first:

```powershell
dotnet run --project .\tools\pdv-phase20-orc-author -- --check-placements
```

Expected result:

- `PDV_REFR_OrcStrongholdForgeSignal -> PDV_ACTI_OrcStrongholdForgeSignal`
- `PDV_REFR_OrcCityDignitySignal -> PDV_ACTI_OrcCityDignitySignal`
- `PDV_REFR_OrcLegionServiceSignal -> PDV_ACTI_OrcLegionServiceSignal`
- `PDV_REFR_OrcSelfMadeCommunitySignal -> PDV_ACTI_OrcSelfMadeCommunitySignal`
- `PDV_REFR_OrcFourHolds_DushnikhYalSignal -> PDV_ACTI_OrcFourHolds_DushnikhYalSignal`
- `PDV_REFR_OrcFourHolds_MorKhazgurSignal -> PDV_ACTI_OrcFourHolds_MorKhazgurSignal`
- `PDV_REFR_OrcFourHolds_NarzulburSignal -> PDV_ACTI_OrcFourHolds_NarzulburSignal`
- `PDV_REFR_OrcFourHolds_LargashburSignal -> PDV_ACTI_OrcFourHolds_LargashburSignal`

Then run:

```powershell
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Strict verification should remain clean except for the known unnamed `INFO`
warning. If strict verification fails, the verifier will name the missing or
mismatched `PDV_REFR_*` reference.

## Runtime Smoke

Use a fresh Orc test character where possible. For an existing test save, set
the origin global only as a proof setup step:

```text
set PDV_GLO_OriginRace to 8
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the eight proof references once each. Expected log and player-facing
surfaces:

| Activation | Expected proof |
|---|---|
| Stronghold forge | Papyrus log contains `RouteOrcStrongholdForge complete: 70` and manager trace `Orc Stronghold forge routed`; Survey/status shows `Stronghold` life. |
| City dignity | Papyrus log contains `RouteOrcCityDignity complete: 71` and manager trace `Orc City dignity routed`; Survey/status shows `City` life. |
| Legion service | Papyrus log contains `RouteOrcLegionService complete: 72` and manager trace `Orc Legion or exile service routed`; Survey/status shows `LegionExile` life. |
| Self-made community | Papyrus log contains `RouteOrcSelfMadeCommunity complete: 73` and manager trace `Orc self-made community routed`; Survey/status shows City-aligned self-made belonging. |
| Four Holds - Dushnikh Yal | Papyrus log contains `RouteOrcFourHoldsVisit complete: 1` and manager trace `Orc Four Holds routed: hold 1`; notification says Dushnikh Yal is counted. |
| Four Holds - Mor Khazgur | Papyrus log contains `RouteOrcFourHoldsVisit complete: 2` and manager trace `Orc Four Holds routed: hold 2`; notification says Mor Khazgur is counted. |
| Four Holds - Narzulbur | Papyrus log contains `RouteOrcFourHoldsVisit complete: 3` and manager trace `Orc Four Holds routed: hold 3`; notification says Narzulbur is counted. |
| Four Holds - Largashbur | Papyrus log contains `RouteOrcFourHoldsVisit complete: 4` and manager trace `Orc Four Holds routed: hold 4`; notification says Largashbur is counted, and the all-holds milestone message appears after all four unique holds. |

Negative checks:

- Activate on a non-Orc origin and confirm no Orc life-mode or weight changes.
- Re-activate same-day surfaces and confirm daily keys prevent noisy repeat
  farming where expected.
- Confirm raw craft count, generic kill count, generic dungeon clear, Legion
  membership alone, ordinary city presence, and MCM-only mode choice are still
  rejected surfaces.
- Confirm vampire and werewolf posture are stored separately from normal
  life-mode scoring.

Counted runtime proof should include the Papyrus log excerpt, Survey/player
status readout, and the strict verifier result after any final manifest status
promotion.
