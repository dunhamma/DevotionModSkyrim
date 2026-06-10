# PDV Beta Test Packet - Bosmer

Created: 2026-06-06
Updated: 2026-06-10
Status: ready to run - DA05 source fill readback pass, runtime/manual proof pending
Mode: console-assisted DA05 source packet plus QASmoke route fallback

Bosmer now has one approved exact P2 quest-stage source fill:
`PDV_FLST_P2_BosmerYffreSources` contains `DA05`
(`Skyrim.esm:02A49A`) for Ill Met By Moonlight terminal stages `100` and
`105`. This is readback/source-fill proof only. It does not prove runtime route
delivery, wrong-origin rejection, Survey/status clarity, reward/stack behavior,
or final-world feel.

## Expected Build - Y'ffre Hunt-Law Pressure

Use a disposable Bosmer save.

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

Run one exact DA05 terminal branch with console assistance:

```text
setstage DA05 100
```

Expected runtime proof after closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Expected route marker:

```text
RouteBosmerYffre complete
```

Manual evidence to record:

```text
Accepted DA05 stage 100 route: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/FAIL
Feel note:
```

## Edge Build - Mercy Branch

Use a separate disposable Bosmer save or reload before the terminal branch.

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
setstage DA05 105
```

Expected runtime proof after closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Manual evidence to record:

```text
Accepted DA05 stage 105 route: PASS/FAIL
Wrong-origin rejection: PENDING/FAIL
Generic-source silence: PENDING/FAIL
Repeat/anti-farm result: PENDING/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/FAIL
Feel note:
```

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

## Remaining Source Scope

Only DA05 stage `100` / `105` is currently approved and filled. Living Story,
Exchange, Bandit Road, Old Contract, Pact-pressure, book, trade, theft,
forest-travel, kindness, broad plant, and generic hunting sources remain blocked
unless separately approved with exact source metadata and readback.

## Evidence To Bring Back

```text
Bosmer QASmoke route fallback: PASS/FAIL
Bosmer DA05 live source packet: PASS/FAIL
Wrong-origin rejection: PENDING/FAIL
Generic-source silence: PENDING/FAIL
Survey/status clarity: PENDING/FAIL
Reward/stack snapshot: PENDING/FAIL
Blocking notes:
```
