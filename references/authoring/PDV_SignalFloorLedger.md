# PDV Signal-Floor Ledger

**Generated:** 2026-07-11 by `tools/pdv_signal_floor_audit.mjs` (read-only audit)

Per-PATH signal-type floor across 35 race-forked paths + 16 Daedric Princes. A path's _types_ are the DISTINCT signal-types it can surface; _renewable_ are the distinct renewable types (`harvest`, `weather`, `day-to-day`, `faucet`). One-shot types are `book`, `quest-stage`, `quest-reaction`, `spell-learned`.

**Floor:** race-path = 5 types / 2 renewable; prince = 4 types / 2 renewable. PASS iff `wired_end_to_end >= min_types AND wired_renewable >= min_renewable`.

**Designed vs wired:** `designed` counts manifest-declared P2 sourceKinds plus the existing data-backed non-P2 source families. `wired_end_to_end` counts P2 sourceKinds only from GREEN `PDV_SignalE2EGateLedger.csv` surfaces; non-P2 Prince Daedric quest-stage counts only when `PDV_PlayerEvents.psc` has both registration and a route branch. Non-P2 `day-to-day`, `quest-reaction`, and routed `faucet` remain data-backed from their source tables and runtime branches. Direct manager renewables count only when `PDV_SignalFloorDirectRenewables.csv` has a row whose named manager function contains the declared guard, anti-farm, and sink evidence. Verdicts use `wired_end_to_end`; `designed` is informational.

## Summary

- Paths audited: **51** (35 race-paths, 16 princes)
- PASS: **16** | UNDER-FLOOR: **35** (35 race-paths, 0 princes)
- Critical (deficit >= 4): 2 | High (>= 2): 33 | Low (1): 0
- Truth status: UNKNOWN-server-down=35 | non-p2-daedric-source=16

## UNDER-FLOOR roster (worst first)

| Severity | path_id | class | designed | wired_end_to_end | wired renew | wired types | missing dimension(s) |
|---|---|---|---|---|---|---|---|
| CRITICAL | `breton_green_way` | race-path | 6 | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `nord_old_ways` | race-path | 5 | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| HIGH | `altmer_auriel` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `altmer_magnus` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `altmer_xarxes` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `argonian_hist` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `argonian_people` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `argonian_void` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `bosmer_bandit_road` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `bosmer_exchange` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `bosmer_living_story` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `bosmer_old_contract` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `breton_hidden_art` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `breton_knights_road` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `dunmer_azura` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `dunmer_boethiah` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `dunmer_deviation` | race-path | 6 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `dunmer_mephala` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_civic` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_patron_civic` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_private_talos` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_public_talos` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_alkosh` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_azurah` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_baandar` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_khenarthi` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_lunar` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `khajiit_rajhin` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `nord_nine_divines` | race-path | 7 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `orc_city` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `orc_legion_exile` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `orc_stronghold` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `redguard_ashabah` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `redguard_crown` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `redguard_forebear` | race-path | 5 | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |

## Full per-path table

| path_id | class | race | fork | designed | wired_end_to_end | wired renew | verdict | designed types | wired types | truth | wired evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `breton_knights_road` | race-path | Breton | Knight's Road | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:94rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:239cells / faucet-routed:2rows |
| `breton_hidden_art` | race-path | Breton | Hidden Art | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage, spell-learned | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | quest-reaction:67cells / faucet-routed:6rows / direct-manager:HandleBretonSleepEvents[day-to-day] |
| `breton_green_way` | race-path | Breton | Green Way | 6 | 2/5 | 1/2 | UNDER-FLOOR | book, day-to-day, harvest, quest-reaction, quest-stage, weather | day-to-day, quest-reaction | UNKNOWN-server-down | likes-dislikes:37rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:57cells |
| `redguard_crown` | race-path | Redguard | Crown | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:30rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:69cells / direct-manager:HandleRedguardCrownTombRespect[faucet] |
| `redguard_forebear` | race-path | Redguard | Forebear | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:21rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:40cells / direct-manager:HandleRedguardForebearRoadPassage[faucet] |
| `redguard_ashabah` | race-path | Redguard | Ash'abah | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:21rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:40cells / direct-manager:HandleRedguardAshAbahDeathDuty[faucet] |
| `orc_city` | race-path | Orc | City | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows env[313:rest-under-open-sky] / quest-reaction:37cells / faucet-routed:1row |
| `orc_stronghold` | race-path | Orc | Stronghold | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows env[313:rest-under-open-sky] / quest-reaction:37cells / faucet-routed:1row |
| `orc_legion_exile` | race-path | Orc | Legion-Exile | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows env[313:rest-under-open-sky] / quest-reaction:37cells / faucet-routed:1row |
| `nord_old_ways` | race-path | Nord | Old Ways | 5 | 2/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction, quest-stage, weather | day-to-day, quest-reaction | UNKNOWN-server-down | likes-dislikes:68rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:225cells |
| `nord_nine_divines` | race-path | Nord | Nine Divines | 7 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage, spell-learned, weather | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:117rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:316cells / faucet-routed:2rows |
| `bosmer_old_contract` | race-path | Bosmer | Old Contract | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:58rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:169cells / direct-manager:HandleBosmerPactPositiveSignal[faucet] |
| `bosmer_living_story` | race-path | Bosmer | Living Story | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:58rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:169cells / direct-manager:HandleBosmerLivingStorySignal[faucet] |
| `bosmer_exchange` | race-path | Bosmer | Exchange | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:57rows env[314:sleep-in-bed,345:discover-location] / quest-reaction:168cells / direct-manager:HandleBosmerExchangeSignal[faucet] |
| `bosmer_bandit_road` | race-path | Bosmer | Bandit Road | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:56rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:174cells / direct-manager:HandleBosmerBanditRoadSignal[faucet] |
| `argonian_hist` | race-path | Argonian | Hist | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, harvest, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:4cells / direct-manager:TryArgonianNearWaterMaintenance[faucet] |
| `argonian_people` | race-path | Argonian | People | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, harvest, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:4cells / direct-manager:TryArgonianNearWaterMaintenance[faucet] |
| `argonian_void` | race-path | Argonian | Void | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:13rows / quest-reaction:15cells / direct-manager:TryArgonianSithisNearDeathBurst[faucet] |
| `khajiit_lunar` | race-path | Khajiit | Lunar | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:55rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:101cells / faucet-routed:1row |
| `khajiit_khenarthi` | race-path | Khajiit | Khenarthi | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:19cells / direct-manager:HandleKhajiitRoadHomeAnchor[day-to-day] / direct-manager:RecordKhajiitFocusSignal[faucet] |
| `khajiit_azurah` | race-path | Khajiit | Azurah | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:15cells / faucet-routed:1row |
| `khajiit_baandar` | race-path | Khajiit | Baan Dar | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:10rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:27cells / direct-manager:HandleKhajiitBaanDarRoadTrick[faucet] |
| `khajiit_rajhin` | race-path | Khajiit | Rajhin | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:21cells / direct-manager:HandleKhajiitRajhinElegantTheft[faucet] |
| `khajiit_alkosh` | race-path | Khajiit | Alkosh | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows / quest-reaction:19cells / direct-manager:HandleKhajiitAlkoshDragonOrder[faucet] |
| `altmer_auriel` | race-path | Altmer | Auri-El | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, harvest, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky] / quest-reaction:22cells / direct-manager:HandleAltmerDawnSteadiness[faucet] |
| `altmer_magnus` | race-path | Altmer | Magnus | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage, spell-learned | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows / quest-reaction:18cells / direct-manager:HandleAltmerSleepEvents[faucet] |
| `altmer_xarxes` | race-path | Altmer | Xarxes | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[345:discover-location] / quest-reaction:24cells / direct-manager:HandleAltmerOrthodoxCostlyEnforcement[faucet] |
| `dunmer_azura` | race-path | Dunmer | Azura | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:12rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:15cells / faucet-routed:1row |
| `dunmer_boethiah` | race-path | Dunmer | Boethiah | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows / quest-reaction:33cells / faucet-routed:1row |
| `dunmer_mephala` | race-path | Dunmer | Mephala | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:11rows env[313:rest-under-open-sky] / quest-reaction:31cells / faucet-routed:1row |
| `dunmer_deviation` | race-path | Dunmer | Deviation | 6 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage, spell-learned | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | quest-reaction:119cells / faucet-routed:5rows / direct-manager:HandleDunmerDeviationPrice[day-to-day] |
| `imperial_civic` | race-path | Imperial | Civic | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:94rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:239cells / faucet-routed:2rows |
| `imperial_public_talos` | race-path | Imperial | Public-Talos | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:10rows env[345:discover-location] / quest-reaction:41cells / direct-manager:HandleImperialTalosPressure[faucet] |
| `imperial_private_talos` | race-path | Imperial | Private-Talos | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:10rows env[345:discover-location] / quest-reaction:41cells / direct-manager:HandleImperialTalosPressure[faucet] |
| `imperial_patron_civic` | race-path | Imperial | Patron-Civic | 5 | 3/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction | UNKNOWN-server-down | likes-dislikes:94rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:239cells / faucet-routed:2rows |
| `prince_mehrunes_dagon` | prince | Daedric | Mehrunes Dagon | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_DagonLiveSources[quest-stage] / likes-dislikes:11rows / quest-reaction:40cells / faucet-routed:1row |
| `prince_boethiah` | prince | Daedric | Boethiah | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_BoethiahLiveSources[quest-stage] / likes-dislikes:9rows / quest-reaction:33cells / faucet-routed:1row |
| `prince_mephala` | prince | Daedric | Mephala | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_MephalaLiveSources[quest-stage] / likes-dislikes:11rows env[313:rest-under-open-sky] / quest-reaction:31cells / faucet-routed:1row |
| `prince_nocturnal` | prince | Daedric | Nocturnal | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_NocturnalLiveSources[quest-stage] / likes-dislikes:10rows env[345:discover-location] / quest-reaction:22cells / faucet-routed:1row |
| `prince_hircine` | prince | Daedric | Hircine | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_HircineLiveSources[quest-stage] / likes-dislikes:9rows env[313:rest-under-open-sky] / quest-reaction:18cells / faucet-routed:1row |
| `prince_hermaeus_mora` | prince | Daedric | Hermaeus Mora | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_MoraLiveSources[quest-stage] / likes-dislikes:12rows env[345:discover-location] / quest-reaction:24cells / faucet-routed:2rows |
| `prince_azura` | prince | Daedric | Azura | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_AzuraLiveSources[quest-stage] / likes-dislikes:10rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:15cells / faucet-routed:1row |
| `prince_namira` | prince | Daedric | Namira | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_NamiraLiveSources[quest-stage] / likes-dislikes:11rows env[313:rest-under-open-sky] / quest-reaction:3cells / faucet-routed:2rows |
| `prince_sanguine` | prince | Daedric | Sanguine | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_SanguineLiveSources[quest-stage] / likes-dislikes:7rows / quest-reaction:2cells / faucet-routed:3rows |
| `prince_vaermina` | prince | Daedric | Vaermina | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_VaerminaLiveSources[quest-stage] / likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:10cells / faucet-routed:1row |
| `prince_peryite` | prince | Daedric | Peryite | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_PeryiteLiveSources[quest-stage] / likes-dislikes:8rows env[314:sleep-in-bed] / quest-reaction:6cells / faucet-routed:1row |
| `prince_malacath` | prince | Daedric | Malacath | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_MalacathLiveSources[quest-stage] / likes-dislikes:11rows env[313:rest-under-open-sky] / quest-reaction:37cells / faucet-routed:1row |
| `prince_clavicus_vile` | prince | Daedric | Clavicus Vile | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_VileLiveSources[quest-stage] / likes-dislikes:9rows env[345:discover-location] / quest-reaction:13cells / faucet-routed:1row |
| `prince_meridia` | prince | Daedric | Meridia | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_MeridiaLiveSources[quest-stage] / likes-dislikes:8rows env[313:rest-under-open-sky] / quest-reaction:19cells / faucet-routed:1row |
| `prince_molag_bal` | prince | Daedric | Molag Bal | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_MolagLiveSources[quest-stage] / likes-dislikes:12rows / quest-reaction:33cells / faucet-routed:1row |
| `prince_sheogorath` | prince | Daedric | Sheogorath | 4 | 4/4 | 2/2 | PASS | day-to-day, faucet, quest-reaction, quest-stage | day-to-day, faucet, quest-reaction, quest-stage | non-p2-daedric-source | daedric-live-source-branch:PDV_FLST_Daedric_SheoLiveSources[quest-stage] / likes-dislikes:11rows env[345:discover-location] / quest-reaction:8cells / faucet-routed:2rows |

## P2 surfaces not wired end-to-end

These FormLists are declared for the path but are not GREEN in `PDV_SignalE2EGateLedger.csv`, so their sourceKinds do not count toward `wired_end_to_end`.

| path_id | blocked P2 surfaces |
|---|---|
| `breton_knights_road` | PDV_FLST_P2_BretonKnightsRoadSources:INCOMPLETE/shell, PDV_FLST_P2_BretonVowSources:INCOMPLETE/shell |
| `breton_hidden_art` | PDV_FLST_P2_BretonHiddenArtSources:INCOMPLETE/shell, PDV_FLST_P2_BretonHiddenArtSpells:INCOMPLETE/shell |
| `breton_green_way` | PDV_FLST_P2_BretonGreenWaySources:INCOMPLETE/shell, PDV_FLST_P2_BretonGreenWayHarvests:INCOMPLETE/shell |
| `redguard_crown` | PDV_FLST_P2_RedguardSpineSources:INCOMPLETE/shell, PDV_FLST_P2_RedguardCrownSources:INCOMPLETE/shell |
| `redguard_forebear` | PDV_FLST_P2_RedguardSpineSources:INCOMPLETE/shell, PDV_FLST_P2_RedguardForebearSources:INCOMPLETE/shell |
| `redguard_ashabah` | PDV_FLST_P2_RedguardSpineSources:INCOMPLETE/shell, PDV_FLST_P2_RedguardAshAbahSources:INCOMPLETE/shell |
| `orc_city` | PDV_FLST_P2_OrcMalacathSources:INCOMPLETE/shell |
| `orc_stronghold` | PDV_FLST_P2_OrcMalacathSources:INCOMPLETE/shell |
| `orc_legion_exile` | PDV_FLST_P2_OrcMalacathSources:INCOMPLETE/shell |
| `nord_old_ways` | PDV_FLST_P2_NordOldWaysSources:INCOMPLETE/shell, PDV_FLST_P2_NordKyneTalosSources:INCOMPLETE/shell |
| `nord_nine_divines` | PDV_FLST_P2_NordKyneTalosSources:INCOMPLETE/shell, PDV_FLST_P2_NordHircineArkaySources:INCOMPLETE/shell |
| `bosmer_old_contract` | PDV_FLST_P2_BosmerYffreSources:INCOMPLETE/shell |
| `bosmer_living_story` | PDV_FLST_P2_BosmerYffreSources:INCOMPLETE/shell |
| `bosmer_exchange` | PDV_FLST_P2_BosmerZenSources:INCOMPLETE/shell |
| `bosmer_bandit_road` | PDV_FLST_P2_BosmerBaanDarSources:INCOMPLETE/shell |
| `argonian_hist` | PDV_FLST_P2_ArgonianHistSources:INCOMPLETE/shell |
| `argonian_people` | PDV_FLST_P2_ArgonianCommunitySources:INCOMPLETE/shell |
| `argonian_void` | PDV_FLST_P2_ArgonianSithisSources:INCOMPLETE/shell |
| `khajiit_lunar` | PDV_FLST_P2_KhajiitLunarSources:INCOMPLETE/shell |
| `khajiit_khenarthi` | PDV_FLST_P2_KhajiitFocusedSources:INCOMPLETE/shell |
| `khajiit_azurah` | PDV_FLST_P2_KhajiitFocusedSources:INCOMPLETE/shell |
| `khajiit_baandar` | PDV_FLST_P2_KhajiitFocusedSources:INCOMPLETE/shell |
| `khajiit_rajhin` | PDV_FLST_P2_KhajiitFocusedSources:INCOMPLETE/shell |
| `khajiit_alkosh` | PDV_FLST_P2_KhajiitFocusedSources:INCOMPLETE/shell |
| `altmer_auriel` | PDV_FLST_P2_AltmerAurielSources:INCOMPLETE/shell, PDV_FLST_P2_AltmerLorkhanPenalties:INCOMPLETE/shell |
| `altmer_magnus` | PDV_FLST_P2_AltmerMagnusSources:INCOMPLETE/shell |
| `altmer_xarxes` | PDV_FLST_P2_AltmerXarxesSources:INCOMPLETE/shell |
| `dunmer_azura` | PDV_FLST_P2_DunmerAzuraSources:INCOMPLETE/shell |
| `dunmer_boethiah` | PDV_FLST_P2_DunmerBoethiahSources:INCOMPLETE/shell |
| `dunmer_mephala` | PDV_FLST_P2_DunmerMephalaSources:INCOMPLETE/shell |
| `dunmer_deviation` | PDV_FLST_P2_DunmerDeviationSources:INCOMPLETE/shell |
| `imperial_civic` | PDV_FLST_P2_ImperialCivicSources:INCOMPLETE/shell, PDV_FLST_P2_ImperialPublicServiceSources:INCOMPLETE/shell, PDV_FLST_P2_ImperialMercySources:INCOMPLETE/shell, PDV_FLST_P2_ImperialLawfulOrderSources:INCOMPLETE/shell, PDV_FLST_P2_ImperialHonestWorkSources:INCOMPLETE/shell, PDV_FLST_P2_ImperialDeathDutySources:INCOMPLETE/shell |
| `imperial_public_talos` | PDV_FLST_P2_ImperialPublicTalosSources:INCOMPLETE/shell |
| `imperial_private_talos` | PDV_FLST_P2_ImperialPrivateTalosSources:INCOMPLETE/shell |
| `imperial_patron_civic` | PDV_FLST_P2_ImperialPatronCivicSources:INCOMPLETE/shell |

## Data-quality caveats

- **No `weather`, `harvest`, or `spell-learned` P2 source is GREEN in the E2E gate.** Several FormLists *declare* these `sourceKinds` (e.g. `BretonGreenWaySources` weather/harvest, `NordKyneTalosSources` weather, `BretonHiddenArtSpells` spell-learned), but none are wired end-to-end. Never-GREEN P2 kinds: `book`, `harvest`, `quest-stage`, `spell-learned`, `weather`. Never-populated manifest fallback kinds: `weather`. The likes-dislikes CSV also carries no weather event-id (only env ids 313/314/345). Net effect: `weather` and `harvest` are currently unreachable as wired distinct types for every path.
- **Only GREEN E2E surfaces contribute P2 `book` or `quest-stage` breadth.** Current GREEN surfaces: none. Nord Old Ways' MQ104/MQ304 routes and Redguard's MS08 routes remain blocked by static-only route review, so those `quest-stage` declarations do not count as wired.
- **Prince quest-reaction is NOT zero.** A literal application of the rule (any matrix cell whose `deity` equals the path's name) gives Molag Bal 6, Peryite 3, Namira 2, Vaermina 2 quest-reaction cells (many are negative/reject branches, e.g. *destroy altar*, but the `deity` column still attributes them). Every one of the 16 Princes has at least 1 quest-reaction cell. This contradicts an a-priori expectation that Namira/Vaermina/Peryite/Molag Bal have none; the tool reports the ground-truth count.
- **Prince day-to-day rows come from the Prince V2 table.** Race-path rows still use `PDV_DeityLikesDislikes.csv`; Prince rows use `PDV_DeityLikesDislikes_Princes_V2.csv`, which is the runtime table loaded by `PDV__ManagerQuest.psc` for `PDV_DaedricPath_*` actors.
- **Part D faucet rows count only when routed in `PDV_PlayerEvents.psc`.** Designed rows remain visible in `designed`, but `wired_end_to_end` requires a matching `RouteQuestReactionFaucet` or `ShouldRouteQuestReactionFaucet` branch so silent candidate faucets do not pass the floor.
- **Deity-name aliasing applied** (case-insensitive, apostrophe/dot/hyphen-stripped): `Azura`=`azurah`, `Hermaeus Mora`=`Mora`, `Clavicus Vile`=`Vile`, `Boethiah`=`Boethra`, `Mephala`=`Mafala`. `Auri-El`->`auriel`, `Y'ffre`->`yffre`, `Z'en`->`zen` fold by the same normalizer.
- **Several registry deities never appear in any data source** and therefore contribute nothing: Redguard `Onsi`/`Ruptga`/`Tava`/`Zeht`/`Satakal`, Breton `Phynaster`, Altmer/others absent from likes-dislikes, quest-matrix, and Part D. Redguard Crown/Forebear day-to-day comes only from `HoonDing`/`Leki`/`Tu'whacca`, which are the sole sect deities present in the sources.
- **Registry size is 35 race-paths + 16 princes = 51.** The task header said '33 race-paths / 49 total', but its own explicit enumeration (Khajiit = Lunar + 5 focused = 6; 3+3+3+2+4+3+6+3+4+4 = 35) sums to 35. The explicit per-path list is treated as authoritative over the header count.

