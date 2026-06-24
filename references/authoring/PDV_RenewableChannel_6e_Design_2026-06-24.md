# Renewable Maintenance Channels — 6e Design (Codex Handoff, 2026-06-24)

## Why
Every spine handoff says "add a renewable channel" with no spec, and **Nord/Orc shipped without
one** (their Score `renewable` dim is 0). This de-vagues it into a reusable pattern + flags the
two retrofits. Only Dunmer + Argonian currently have a renewable channel.

## The proven pattern (copy verbatim)
A renewable channel = a small `Record*` function on the race's **substrate** that feeds the metric:
```papyrus
Float Property AncestralRestDelta = 3.0 Auto
Function RecordAncestralRest(String reason)
    RecordAncestralRestScaled(1.0, reason)
EndFunction
Function RecordAncestralRestScaled(Float multiplier, String reason)
    AdjustMetric(AncestralRestDelta * ClampSignalMultiplier(multiplier), "ancestral_rest_" + reason)
EndFunction
```
(`AdjustMetric` + `ClampSignalMultiplier` are inherited from `PDV_SubstrateBase`; mirror
`PDV_Substrate_DunmerAncestor` prayer/home and `PDV_Substrate_ArgonianHist` `RecordBedOfChoiceReturn`.)
The `ClampSignalMultiplier`/daily cap IS the anti-farm — sleeping twice a day banks once.

## Channels
- **Sleep / ancestral rest — UNIVERSAL (every race):** hook the existing `OnSleepStart/Stop`
  (PDV_PlayerEvents.psc:175/186) → the manager's sleep-exit dispatcher routes to the active race's
  `substrate.RecordAncestralRest`, gated on origin + own-home/bed (mirror Argonian bed-of-choice).
  Recommend this for ALL spine races — it's the one channel everyone has.
- **Second cultural channel (one per race):** prayer or home-return, per the table.

## Per-race adoption
| Race | Sleep (universal) | 2nd cultural channel |
|---|---|---|
| **Nord** | ✅ **RETROFIT** (hearth-rest) | hold/hearth home-return |
| **Orc** | ✅ **RETROFIT** (stronghold-rest) | stronghold/longhouse home-return |
| Dunmer | (add sleep) | HAS prayer + home ✅ |
| Altmer | ✅ | study/meditation ("Disciplines of Return") |
| Imperial | ✅ | shrine-prayer (Imperial cult) or home |
| Breton | ✅ | manor home-return or prayer |
| Redguard | ✅ | home-return |

## How it scores
Score `renewable` dim counts distinct renewable channels. Sleep + one cultural = the dim climbs
off 0 for Nord/Orc and the not-yet-built races. (Each race's spine handoff's 6e line now points here.)

## Build order
- **Fold into each not-yet-built spine handoff** (Altmer/Imperial/Breton/Redguard) — add the sleep
  channel + the cultural one in the same pass.
- **Two retrofits** (Nord, Orc) — small standalone passes on their substrates: add
  `RecordAncestralRest` + wire the sleep dispatcher + (optionally) the home channel.

## ⚠️ Serialize (substrate + manager). Verify
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → update each race's `PDV_SpineStackRegistry.csv`
`renewable` score → `pdv_spine_stack_score.mjs` shows the dim climb. In-game: sleep once in
own home → one metric tick that day; second sleep same day does not double-bank.
