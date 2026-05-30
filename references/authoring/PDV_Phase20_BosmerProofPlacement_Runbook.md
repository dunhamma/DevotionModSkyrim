# PDV Phase 20 Bosmer Proof Placement Runbook

Last updated: 2026-05-31

This runbook is the runtime proof packet for the Bosmer non-hunter parity proof
slice. Phase 9 already proves the base Bosmer path system. This packet adds
path-specific favor proof surfaces so Living Story, Exchange, and Bandit Road
can be tested with the same seriousness as Old Contract without expanding Green
Pact item/tag enforcement.

## Preconditions

- `PlayerDevotion_Framework.esp` is active in the Anvil `Devotion Dev` profile.
- The following base ACTI records already exist in `PlayerDevotion_Framework.esp`:
  - `PDV_ACTI_BosmerOldContractProperHuntSignal`
  - `PDV_ACTI_BosmerOldContractForestKeptSignal`
  - `PDV_ACTI_BosmerLivingStoryCommunityKeptSignal`
  - `PDV_ACTI_BosmerLivingStoryNatureSiteSignal`
  - `PDV_ACTI_BosmerExchangeDebtSettledSignal`
  - `PDV_ACTI_BosmerExchangeProportionateVengeanceSignal`
  - `PDV_ACTI_BosmerBanditRoadRoadLifeSignal`
  - `PDV_ACTI_BosmerBanditRoadReversalSignal`
- Strict shell gate:

```text
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Current shell result after the Phase 20 proof-placement packet:
`PASS=1985, WARN=1, INFO=28`. The remaining warning is the existing unnamed
CK-authored INFO record class.

## Proof Placement Contract

Create or rename exactly these placed reference EditorIDs:

| Base ACTI | Required REFR EditorID | Suggested proof meaning |
|---|---|---|
| `PDV_ACTI_BosmerOldContractProperHuntSignal` | `PDV_REFR_BosmerOldContractProperHuntSignal` | Proper hunt or restrained Pact observance |
| `PDV_ACTI_BosmerOldContractForestKeptSignal` | `PDV_REFR_BosmerOldContractForestKeptSignal` | Forest kept, desecration prevented, living world respected |
| `PDV_ACTI_BosmerLivingStoryCommunityKeptSignal` | `PDV_REFR_BosmerLivingStoryCommunityKeptSignal` | Community memory, preservation, story carried |
| `PDV_ACTI_BosmerLivingStoryNatureSiteSignal` | `PDV_REFR_BosmerLivingStoryNatureSiteSignal` | Grove, nature site, or non-destructive outdoor practice |
| `PDV_ACTI_BosmerExchangeDebtSettledSignal` | `PDV_REFR_BosmerExchangeDebtSettledSignal` | Debt, restitution, or promise honored |
| `PDV_ACTI_BosmerExchangeProportionateVengeanceSignal` | `PDV_REFR_BosmerExchangeProportionateVengeanceSignal` | Redress or proportional justice |
| `PDV_ACTI_BosmerBanditRoadRoadLifeSignal` | `PDV_REFR_BosmerBanditRoadRoadLifeSignal` | Costly road life, outsider survival, pariah solidarity |
| `PDV_ACTI_BosmerBanditRoadReversalSignal` | `PDV_REFR_BosmerBanditRoadReversalSignal` | Rare Baan Dar reversal or impossible escape |

The proof references are currently placed in `QASmoke` by:

```text
dotnet run --project .\tools\pdv-phase20-proof-placement-author -- --place-missing
```

These references are proof surfaces, not final worldbuilding placement. A later
content pass can move or replace them with deliberate Bosmer path hooks after
runtime behavior is proven.

## Placement Readback

Run:

```text
dotnet run --project .\tools\pdv-phase20-bosmer-author -- --check-placements
```

Expected result: `Status = PASS`, with each
`PDV_REFR_Bosmer*` reference pointing at the matching `PDV_ACTI_Bosmer*` base.

If readback fails, do not runtime-test. Fix the REFR EditorID or base activator
first.

## Runtime Smoke

Fresh game or clean proof save:

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate each proof object once. Expected Papyrus markers:

```text
RouteBosmerOldContractProperHunt complete: 100
RouteBosmerOldContractForestKept complete: 101
RouteBosmerLivingStoryCommunityKept complete: 102
RouteBosmerLivingStoryNatureSite complete: 103
RouteBosmerExchangeDebtSettled complete: 104
RouteBosmerExchangeProportionateVengeance complete: 105
RouteBosmerBanditRoadRoadLife complete: 106
RouteBosmerBanditRoadReversal complete: 107
```

Expected status surface:

- Survey Devotion includes `favor=oc=`, `ls=`, `ex=`, and `br=` counters.
- Living Story evidence can advance path suggestion without pretending it is
  Old Contract orthodoxy.
- Exchange evidence moves through Z'en debt/redress logic, not commerce profit.
- Bandit Road evidence moves through Baan Dar survival logic, not generic crime.
- Baan Dar reversal obeys the seven-day major-favor cooldown.

## Negative Checks

Before increasing Bosmer reward magnitude, prove these rejected surfaces:

- Non-Bosmer origin cannot activate the route meaningfully.
- Generic forest travel does not satisfy Living Story or Old Contract by itself.
- Generic barter profit does not satisfy Exchange.
- Random theft or repeated crime does not satisfy Bandit Road.
- Broad plant detection is not used as Green Pact punishment in this packet.

## Completion Gate

Do not mark the Bosmer non-hunter slice runtime-proven until all eight placement
refs pass readback, all eight positive routes produce logs/status changes, and
the negative surface checks are recorded.
