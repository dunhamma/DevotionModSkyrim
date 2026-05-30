# PDV Phase 20 Redguard Proof Placement Runbook

Last updated: 2026-05-31

This runbook is the runtime proof packet for the first Redguard sect and Far
Shores proof slice. Source, framework record wiring, QASmoke proof references,
and verifier readback are shell-proven. The remaining work is runtime smoke and
negative-surface proof.

## Preconditions

- `PlayerDevotion_Framework.esp` is active in the Anvil `Devotion Dev` profile.
- The following records already exist in `PlayerDevotion_Framework.esp`:
  - `PDV_StateTrack_RedguardSect`
  - `PDV_GLO_RedguardSect`
  - `PDV_ACTI_RedguardCrownTombRespectSignal`
  - `PDV_ACTI_RedguardForebearRoadSignal`
  - `PDV_ACTI_RedguardAshAbahDeathDutySignal`
  - `PDV_ACTI_RedguardFarShoresTokenSignal`
- Strict shell gate:

```text
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Expected current shell result after the Phase 20 proof-placement packet:
`PASS=1985, WARN=1, INFO=28`. The remaining warning is the existing unnamed
CK-authored INFO record class.

## Proof Placement Contract

Create or rename exactly these placed reference EditorIDs:

| Base ACTI | Required REFR EditorID | Suggested proof meaning |
|---|---|---|
| `PDV_ACTI_RedguardCrownTombRespectSignal` | `PDV_REFR_RedguardCrownTombRespectSignal` | Crown tomb respect or ancestral form proof |
| `PDV_ACTI_RedguardForebearRoadSignal` | `PDV_REFR_RedguardForebearRoadSignal` | Forebear road-passage or contract dignity proof |
| `PDV_ACTI_RedguardAshAbahDeathDutySignal` | `PDV_REFR_RedguardAshAbahDeathDutySignal` | Ash'abah death-duty or impurity-borne proof |
| `PDV_ACTI_RedguardFarShoresTokenSignal` | `PDV_REFR_RedguardFarShoresTokenSignal` | Private Tu'whacca / Far Shores token proof |

The proof references are currently placed in `QASmoke` by:

```text
dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --place-missing
```

These references are proof surfaces, not final worldbuilding placement. A later
content pass can move or replace them with deliberate Redguard/death-duty hooks
after runtime behavior is proven.

## Placement Readback

Run:

```text
dotnet run --project .\tools\pdv-phase20-redguard-author -- --check-placements
```

Expected result: `Status = PASS`, with each
`PDV_REFR_Redguard*` reference pointing at the matching `PDV_ACTI_Redguard*`
base.

If readback fails, do not runtime-test. Fix the REFR EditorID or base activator
first.

## Runtime Smoke

Fresh game or clean proof save:

```text
set PDV_GLO_OriginRace to 9
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate each proof object once. Expected Papyrus markers:

```text
RouteRedguardCrownTombRespect complete: 80
RouteRedguardForebearRoadPassage complete: 81
RouteRedguardAshAbahDeathDuty complete: 82
RouteRedguardFarShoresToken complete: 83
```

Expected status surfaces:

- Survey Devotion shows the active Redguard sect and current standing.
- Crown proof can set/read `Crown`.
- Forebear proof can set/read `Forebear`.
- Ash'abah proof can set/read `AshAbah`.
- Far Shores token changes the private Tu'whacca token weight without presenting
  Arkay as the actual worship target.

## Negative Checks

Before increasing Redguard reward magnitude, prove these rejected surfaces:

- Non-Redguard origin cannot activate the route meaningfully.
- Same-day repeats are reduced by the daily repeat guard.
- Generic combat and body count do not satisfy HoonDing make-way.
- Fast travel does not satisfy Forebear road passage.
- Generic undead spam does not repeatedly feed Ash'abah reward.
- Arkay shrine use does not silently replace Tu'whacca devotion.

## Completion Gate

Do not mark the Redguard slice runtime-proven until all four placement refs pass
readback, all four positive routes produce logs/status changes, and the negative
surface checks are recorded.
