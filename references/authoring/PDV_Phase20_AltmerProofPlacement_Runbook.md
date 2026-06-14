# PDV Phase 20 Altmer Proof Placement Runbook

## Purpose

This runbook is the runtime proof packet for the first Altmer runtime proof
slice. The source, base records, favor records, curse messages, and QASmoke
proof references are automation-authored and verifier-covered. The remaining
work is in-game proof: activate the four proof surfaces, confirm status/log
movement, and record the negative checks.

These proof activators are a QASmoke test cluster. They prove route wiring,
feedback, state movement, and pacing. They are not the final immersive world
hooks for Dragonborn, Lorkhan, dawn practice, or orthodox-cost content.

## Preconditions

- Active MO2 profile: `Devotion Dev`.
- Active plugin in CK: `Devotion.esp`.
- `PDV_EventSignalActivator.pex`, `PDV_EventSignalEffect.pex`, and
  `PDV__ManagerQuest.pex` are current.
- `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
  is clean except for the known unnamed `INFO` warning.
- `dotnet run --project .\tools\pdv-phase20-altmer-author -- --check-placements`
  returns `Status = PASS`.
- `dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --check-placements`
  returns `Status = PASS`.

## Proof Placement Contract

Place one reference for each already-wired ACTI base record.

| Base ACTI | Placed REFR EditorID | Runtime proof |
|---|---|---|
| `PDV_ACTI_AltmerDragonbornCrisisSignal` | `PDV_REFR_AltmerDragonbornCrisisSignal` | Dragonborn crisis source routes as crisis source `1`. |
| `PDV_ACTI_AltmerLorkhanPressureSignal` | `PDV_REFR_AltmerLorkhanPressureSignal` | Lorkhan pressure routes as pressure tier `3`. |
| `PDV_ACTI_AltmerDawnSteadinessSignal` | `PDV_REFR_AltmerDawnSteadinessSignal` | Quiet daily-life positive favor route fires. |
| `PDV_ACTI_AltmerOrthodoxCostSignal` | `PDV_REFR_AltmerOrthodoxCostSignal` | Marked orthodox-cost favor route fires. |

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
dotnet run --project .\tools\pdv-phase20-altmer-author -- --check-placements
```

Expected result:

- `PDV_REFR_AltmerDragonbornCrisisSignal -> PDV_ACTI_AltmerDragonbornCrisisSignal`
- `PDV_REFR_AltmerLorkhanPressureSignal -> PDV_ACTI_AltmerLorkhanPressureSignal`
- `PDV_REFR_AltmerDawnSteadinessSignal -> PDV_ACTI_AltmerDawnSteadinessSignal`
- `PDV_REFR_AltmerOrthodoxCostSignal -> PDV_ACTI_AltmerOrthodoxCostSignal`

Then run:

```powershell
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Strict verification should remain clean except for the known unnamed `INFO`
warning. If strict verification fails, the verifier will name the missing or
mismatched `PDV_REFR_*` reference.

## Runtime Smoke

Use a fresh Altmer test character where possible. For an existing test save,
set the origin global only as a proof setup step:

```text
set PDV_GLO_OriginRace to 3
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the four proof references once each. Expected log and player-facing
surfaces:

| Activation | Expected proof |
|---|---|
| Dragonborn crisis | Papyrus log contains `RouteAltmerCrisisSource complete: 51 source 1`; Survey/status shows an Altmer crisis state/source. |
| Lorkhan pressure | Papyrus log contains `RouteAltmerLorkhanPressure complete: 50 tier 3`; Survey/status shows pressure count movement. |
| Dawn steadiness | Papyrus log contains `RouteAltmerDawnSteadiness complete: 52`; the active favor/status surface records dawn steadiness without loud punitive copy. |
| Orthodox cost | Papyrus log contains `RouteAltmerOrthodoxCostlyEnforcement complete: 53`; the active favor/status surface records orthodox-cost support. |

Negative checks:

- Activate on a non-Altmer origin and confirm no Altmer state changes.
- Re-activate same-day surfaces and confirm daily keys prevent noisy repeat
  farming where expected.
- Confirm ordinary travel in the test cell does not create Lorkhan pressure.

Curse-message proof can use the existing MCM Developer Options curse controls:

1. Cycle curse origin to Altmer and apply it.
2. Force vampire and confirm the Exiled entry message/status.
3. Force none and confirm cured-vampire scar recognition appears once.
4. Force werewolf and confirm hard-halt copy/status.

Counted runtime proof should include the Papyrus log excerpt, Survey/player
status readout, and the strict verifier result after any final manifest status
promotion.
