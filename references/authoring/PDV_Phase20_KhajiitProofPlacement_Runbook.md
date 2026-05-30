# PDV Phase 20 Khajiit Proof Placement Runbook

Status: source/record/proof-placement wired; runtime proof open.

## Preconditions

- `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` compile cleanly after the Khajiit route changes.
- `tools\pdv-phase20-khajiit-author --create-missing` has created the six proof ACTI base records and rewired `PDV_KhajiitLunarSubstrate` plus `PDV_GLO_KhajiitFocusedEmphasis` on `PDV__ManagerQuest`.
- `dotnet run --project .\tools\pdv-phase20-khajiit-author -- --check-placements` returns `Status = PASS`.
- Strict Phase 20 gate after SEQ refresh is clean at `PASS=1985, WARN=1, INFO=28`; the warning is the existing unnamed CK-authored INFO group.

## Proof Placement Contract

The six ACTI bases are placed as references in `QASmoke` by:

```text
dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --place-missing
```

These are proof surfaces, not final worldbuilding placement. A later content pass can move or replace them with deliberate Khajiit road/moon/focus hooks after runtime behavior is proven.

| Base ACTI | Required placed reference | Route | Signal value | Purpose |
|---|---|---:|---:|---|
| `PDV_ACTI_KhajiitMoonObservanceSignal` | `PDV_REFR_KhajiitMoonObservanceSignal` | 10 | 1 | Moon observance fallback proof |
| `PDV_ACTI_KhajiitRoadHomeAnchorOneSignal` | `PDV_REFR_KhajiitRoadHomeAnchorOneSignal` | 33 | 1 | First road-home anchor |
| `PDV_ACTI_KhajiitRoadHomeAnchorTwoSignal` | `PDV_REFR_KhajiitRoadHomeAnchorTwoSignal` | 33 | 2 | Second road-home anchor |
| `PDV_ACTI_KhajiitBaanDarRoadTrickSignal` | `PDV_REFR_KhajiitBaanDarRoadTrickSignal` | 90 | 0 | Baan Dar focus parity |
| `PDV_ACTI_KhajiitRajhinElegantTheftSignal` | `PDV_REFR_KhajiitRajhinElegantTheftSignal` | 91 | 0 | Rajhin focus parity |
| `PDV_ACTI_KhajiitAlkoshDragonOrderSignal` | `PDV_REFR_KhajiitAlkoshDragonOrderSignal` | 92 | 0 | Alkosh focus parity |

For readback, run:

```text
dotnet run --project .\tools\pdv-phase20-khajiit-author -- --check-placements
node .\tools\pdv_refresh_seq.mjs --write --json
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

## Runtime Smoke

Use a fresh test path or main-menu `coc qasmoke` path, then set:

```text
set PDV_GLO_OriginRace to 6
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the proof references across separate in-game days where the daily gate matters.

Expected log/readout surfaces:

- Moon proof logs `RouteKhajiitMoonObservance complete: 10` and moves `KhajiitLunar` observance without requiring visual sky inspection.
- Road-home anchor one logs `RouteKhajiitRoadHomeAnchor complete: 33 anchor 1`; activating anchor one again after a later day should be rejected as a same-anchor repeat.
- Road-home anchor two logs `RouteKhajiitRoadHomeAnchor complete: 33 anchor 2` and proves the circuit can continue through a second anchor.
- Baan Dar, Rajhin, and Alkosh proof logs route IDs `90`, `91`, and `92`, and the Khajiit summary exposes `bd=`, `rj=`, and `ak=` focus weights.

## Negative Checks

- Non-Khajiit origin does not score any proof reference.
- Repeating one road-home anchor does not advance the circuit.
- Moon-sugar use is not a moon observance shortcut.
- Visual moon inspection, weather, or sky visibility is not required.
- Generic crime does not satisfy Rajhin.
- Generic combat or dragon-kill spam does not satisfy Alkosh.
- Baan Dar proof must read as rare road survival/trickery, not ordinary theft.
