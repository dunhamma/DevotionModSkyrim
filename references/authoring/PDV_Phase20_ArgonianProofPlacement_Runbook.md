# PDV Phase 20 Argonian Proof Placement Runbook

## Purpose

This runbook is the runtime proof packet for the first Argonian Hist / People /
Void runtime proof slice. The source, substrate record, posture track, manager
wiring, EventBus routes, proof ACTI base records, and QASmoke proof references
are automation-authored and verifier-covered. The remaining work is in-game
proof: activate the four proof surfaces, confirm status/log movement, and
record the negative checks.

These proof activators are a QASmoke test cluster. They prove route wiring,
layered feedback, anti-farm behavior, and the balance between Hist, People, and
Void. They are not the final immersive world hooks for Hist sap, community
support, bed choice, or Sithis content.

## Preconditions

- Active MO2 profile: `Devotion Dev`.
- Active plugin in CK: `PlayerDevotion_Framework.esp`.
- `PDV_Substrate_ArgonianHist.pex`, `PDV__ManagerQuest.pex`,
  `PDV_EventTypes.pex`, `PDV_EventBus.pex`, and
  `PDV_EventSignalActivator.pex` are current.
- `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
  is clean except for the known unnamed `INFO` warning.
- `dotnet run --project .\tools\pdv-phase20-argonian-author -- --check-placements`
  returns `Status = PASS`.
- `dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --check-placements`
  returns `Status = PASS`.

## Proof Placement Contract

Place one reference for each already-wired ACTI base record.

| Base ACTI | Placed REFR EditorID | Runtime proof |
|---|---|---|
| `PDV_ACTI_ArgonianHistMaintenanceSignal` | `PDV_REFR_ArgonianHistMaintenanceSignal` | Hist maintenance route `60` moves the Hist layer without rewarding generic swimming. |
| `PDV_ACTI_ArgonianPeopleSupportSignal` | `PDV_REFR_ArgonianPeopleSupportSignal` | People support route `61` proves chosen-community support. |
| `PDV_ACTI_ArgonianVoidSignal` | `PDV_REFR_ArgonianVoidSignal` | Void route `62` increments the threshold signal instead of fully activating Sithis on one beat. |
| `PDV_ACTI_ArgonianBedOfChoiceSignal` | `PDV_REFR_ArgonianBedOfChoiceSignal` | Bed-of-choice route `63` proves the chosen-family cadence hook. |

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
dotnet run --project .\tools\pdv-phase20-argonian-author -- --check-placements
```

Expected result:

- `PDV_REFR_ArgonianHistMaintenanceSignal -> PDV_ACTI_ArgonianHistMaintenanceSignal`
- `PDV_REFR_ArgonianPeopleSupportSignal -> PDV_ACTI_ArgonianPeopleSupportSignal`
- `PDV_REFR_ArgonianVoidSignal -> PDV_ACTI_ArgonianVoidSignal`
- `PDV_REFR_ArgonianBedOfChoiceSignal -> PDV_ACTI_ArgonianBedOfChoiceSignal`

Then run:

```powershell
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Strict verification should remain clean except for the known unnamed `INFO`
warning. If strict verification fails, the verifier will name the missing or
mismatched `PDV_REFR_*` reference.

## Runtime Smoke

Use a fresh Argonian test character where possible. For an existing test save,
set the origin global only as a proof setup step:

```text
set PDV_GLO_OriginRace to 7
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the four proof references once each. Expected log and player-facing
surfaces:

| Activation | Expected proof |
|---|---|
| Hist maintenance | Papyrus log contains `RouteArgonianHistMaintenance complete: 60` and manager trace `Argonian Hist maintenance routed`; Survey/status shows Hist movement. |
| People support | Papyrus log contains `RouteArgonianPeopleSupport complete: 61` and manager trace `Argonian People support routed`; Survey/status shows People movement. |
| Void signal | Papyrus log contains `RouteArgonianVoidSignal complete: 62`; one activation increments the Sithis signal count but does not make Void the dominant route. |
| Bed of choice | Papyrus log contains `RouteArgonianBedOfChoice complete: 63` and manager trace `Argonian bed-of-choice return routed`; Survey/status shows the bed cadence count. |

Negative checks:

- Activate on a non-Argonian origin and confirm no Argonian layer changes.
- Re-activate same-day surfaces and confirm daily keys prevent noisy repeat
  farming where expected.
- Confirm generic swimming, generic inn sleep, generic murder, and a single
  Brotherhood join are still rejected surfaces.
- Confirm Void remains threshold-gated: one signal is not full activation.

Counted runtime proof should include the Papyrus log excerpt, Survey/player
status readout, and the strict verifier result after any final manifest status
promotion.
