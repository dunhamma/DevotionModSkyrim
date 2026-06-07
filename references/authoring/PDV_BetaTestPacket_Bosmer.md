# PDV Beta Test Packet - Bosmer

Created: 2026-06-06
Status: blocked for beta-feel source packet - no approved live source fill
Mode: QASmoke route fallback plus source-approval handoff

Bosmer does not currently have approved P2 book-source fill in the live tranche.
The base wiring audit reports Bosmer receiver scaffolds and reward records, but
`approvedSourceFillRecords: 0`. Do not claim a Bosmer beta-feel source packet
until at least one exact Living Story, Exchange, Bandit Road, Old Contract, or
Pact-pressure source is approved, filled, and read back.

## Current Runnable Fallback - QASmoke Route Proof

QASmoke proof confirms route-stack behavior only. It does not prove final
placement, normal-play feel, or anti-farm protection.

Use a disposable save:

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the eight Bosmer proof objects once:

```text
PDV_REFR_BosmerOldContractProperHuntSignal
PDV_REFR_BosmerOldContractForestKeptSignal
PDV_REFR_BosmerLivingStoryCommunityKeptSignal
PDV_REFR_BosmerLivingStoryNatureSiteSignal
PDV_REFR_BosmerExchangeDebtSettledSignal
PDV_REFR_BosmerExchangeProportionateVengeanceSignal
PDV_REFR_BosmerBanditRoadRoadLifeSignal
PDV_REFR_BosmerBanditRoadReversalSignal
```

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Expected route markers:

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

## Beta-Feel Source Packet Blocker

Before a real Bosmer beta-feel packet can run, approve and fill at least one
exact source family. The candidate must reject generic kindness, generic trade,
raw theft, forest travel, random vengeance, broad plant detection, and generic
hunting unless the exact path context owns the route.

## Evidence To Bring Back

```text
Bosmer QASmoke route fallback: PASS/FAIL
Bosmer live source packet: BLOCKED until exact source fill
Wrong-origin rejection: PENDING/FAIL
Generic-source silence: PENDING/FAIL
Survey/status clarity: PENDING/FAIL
Reward/stack snapshot: PENDING/FAIL
Blocking notes:
```

