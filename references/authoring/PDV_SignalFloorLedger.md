# PDV Signal-Floor Ledger

**Generated:** 2026-06-23 by `tools/pdv_signal_floor_audit.mjs` (read-only audit)

Per-PATH signal-type floor across 35 race-forked paths + 16 Daedric Princes. A path's _types_ are the DISTINCT signal-types it can surface; _renewable_ are the distinct renewable types (`harvest`, `weather`, `day-to-day`, `faucet`). One-shot types are `book`, `quest-stage`, `quest-reaction`, `spell-learned`.

**Floor:** race-path = 5 types / 2 renewable; prince = 4 types / 2 renewable. PASS iff `distinct_types >= min_types AND distinct_renewable >= min_renewable`.

## Summary

- Paths audited: **51** (35 race-paths, 16 princes)
- PASS: **0** | UNDER-FLOOR: **51** (35 race-paths, 16 princes)
- Critical (deficit >= 4): 15 | High (>= 2): 35 | Low (1): 1

## UNDER-FLOOR roster (worst first)

| Severity | path_id | class | types | renew | present | missing dimension(s) |
|---|---|---|---|---|---|---|
| CRITICAL | `prince_hircine` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `prince_mehrunes_dagon` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `prince_meridia` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `prince_molag_bal` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `prince_nocturnal` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `prince_sheogorath` | prince | 1/4 | 0/2 | quest-reaction | types 1/4 (short 3); renewable 0/2 (short 2) |
| CRITICAL | `argonian_people` | race-path | 1/5 | 1/2 | day-to-day | types 1/5 (short 4); renewable 1/2 (short 1) |
| CRITICAL | `argonian_hist` | race-path | 2/5 | 1/2 | book, day-to-day | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `argonian_void` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `bosmer_bandit_road` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `bosmer_exchange` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `breton_green_way` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `dunmer_deviation` | race-path | 2/5 | 1/2 | faucet, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `dunmer_mephala` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| CRITICAL | `imperial_private_talos` | race-path | 2/5 | 1/2 | day-to-day, quest-reaction | types 2/5 (short 3); renewable 1/2 (short 1) |
| HIGH | `prince_azura` | prince | 2/4 | 1/2 | day-to-day, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_boethiah` | prince | 2/4 | 1/2 | day-to-day, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_clavicus_vile` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_hermaeus_mora` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_malacath` | prince | 2/4 | 1/2 | day-to-day, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_mephala` | prince | 2/4 | 1/2 | day-to-day, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_namira` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_peryite` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_sanguine` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `prince_vaermina` | prince | 2/4 | 1/2 | faucet, quest-reaction | types 2/4 (short 2); renewable 1/2 (short 1) |
| HIGH | `altmer_magnus` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `altmer_xarxes` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `bosmer_living_story` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `bosmer_old_contract` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `breton_hidden_art` | race-path | 3/5 | 1/2 | book, faucet, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `dunmer_azura` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `dunmer_boethiah` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `imperial_public_talos` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_alkosh` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_azurah` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_baandar` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_khenarthi` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_lunar` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `khajiit_rajhin` | race-path | 3/5 | 1/2 | day-to-day, quest-reaction, quest-stage | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `nord_old_ways` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `orc_city` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `orc_legion_exile` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `orc_stronghold` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `redguard_ashabah` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `redguard_crown` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `redguard_forebear` | race-path | 3/5 | 1/2 | book, day-to-day, quest-reaction | types 3/5 (short 2); renewable 1/2 (short 1) |
| HIGH | `breton_knights_road` | race-path | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_civic` | race-path | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `imperial_patron_civic` | race-path | 3/5 | 2/2 | day-to-day, faucet, quest-reaction | types 3/5 (short 2) |
| HIGH | `altmer_auriel` | race-path | 4/5 | 1/2 | book, day-to-day, quest-reaction, quest-stage | types 4/5 (short 1); renewable 1/2 (short 1) |
| LOW | `nord_nine_divines` | race-path | 4/5 | 2/2 | book, day-to-day, faucet, quest-reaction | types 4/5 (short 1) |

## Full per-path table

| path_id | class | race | fork | types | renew | verdict | types_present | evidence |
|---|---|---|---|---|---|---|---|---|
| `breton_knights_road` | race-path | Breton | Knight's Road | 3/5 | 2/2 | UNDER-FLOOR | day-to-day, faucet, quest-reaction | likes-dislikes:81rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:100cells / faucet:4rows |
| `breton_hidden_art` | race-path | Breton | Hidden Art | 3/5 | 1/2 | UNDER-FLOOR | book, faucet, quest-reaction | manifest-populated:[book] / quest-reaction:23cells / faucet:4rows |
| `breton_green_way` | race-path | Breton | Green Way | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:26rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:18cells |
| `redguard_crown` | race-path | Redguard | Crown | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:26rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:27cells |
| `redguard_forebear` | race-path | Redguard | Forebear | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:18rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:20cells |
| `redguard_ashabah` | race-path | Redguard | Ash'abah | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:18rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:20cells |
| `orc_city` | race-path | Orc | City | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:12cells |
| `orc_stronghold` | race-path | Orc | Stronghold | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:12cells |
| `orc_legion_exile` | race-path | Orc | Legion-Exile | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:12cells |
| `nord_old_ways` | race-path | Nord | Old Ways | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:57rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:100cells |
| `nord_nine_divines` | race-path | Nord | Nine Divines | 4/5 | 2/2 | UNDER-FLOOR | book, day-to-day, faucet, quest-reaction | manifest-populated:[book] / likes-dislikes:101rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:133cells / faucet:4rows |
| `bosmer_old_contract` | race-path | Bosmer | Old Contract | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:47rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:75cells |
| `bosmer_living_story` | race-path | Bosmer | Living Story | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:47rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:75cells |
| `bosmer_exchange` | race-path | Bosmer | Exchange | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:49rows env[314:sleep-in-bed,345:discover-location] / quest-reaction:79cells |
| `bosmer_bandit_road` | race-path | Bosmer | Bandit Road | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:47rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:77cells |
| `argonian_hist` | race-path | Argonian | Hist | 2/5 | 1/2 | UNDER-FLOOR | book, day-to-day | manifest-populated:[book] / likes-dislikes:10rows env[313:rest-under-open-sky,314:sleep-in-bed] |
| `argonian_people` | race-path | Argonian | People | 1/5 | 1/2 | UNDER-FLOOR | day-to-day | likes-dislikes:10rows env[313:rest-under-open-sky,314:sleep-in-bed] |
| `argonian_void` | race-path | Argonian | Void | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:10rows env[314:sleep-in-bed] / quest-reaction:10cells |
| `khajiit_lunar` | race-path | Khajiit | Lunar | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:46rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:25cells |
| `khajiit_khenarthi` | race-path | Khajiit | Khenarthi | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:8rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:2cells |
| `khajiit_azurah` | race-path | Khajiit | Azurah | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:11rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:2cells |
| `khajiit_baandar` | race-path | Khajiit | Baan Dar | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:9rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:5cells |
| `khajiit_rajhin` | race-path | Khajiit | Rajhin | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:8rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:10cells |
| `khajiit_alkosh` | race-path | Khajiit | Alkosh | 3/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction, quest-stage | manifest-populated:[quest-stage] / likes-dislikes:10rows / quest-reaction:6cells |
| `altmer_auriel` | race-path | Altmer | Auri-El | 4/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction, quest-stage | manifest-populated:[book,quest-stage] / likes-dislikes:10rows env[313:rest-under-open-sky] / quest-reaction:7cells |
| `altmer_magnus` | race-path | Altmer | Magnus | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:7rows / quest-reaction:8cells |
| `altmer_xarxes` | race-path | Altmer | Xarxes | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[345:discover-location] / quest-reaction:11cells |
| `dunmer_azura` | race-path | Dunmer | Azura | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:2cells |
| `dunmer_boethiah` | race-path | Dunmer | Boethiah | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:11rows env[314:sleep-in-bed] / quest-reaction:17cells |
| `dunmer_mephala` | race-path | Dunmer | Mephala | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:10rows env[313:rest-under-open-sky] / quest-reaction:20cells |
| `dunmer_deviation` | race-path | Dunmer | Deviation | 2/5 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:25cells / faucet:2rows |
| `imperial_civic` | race-path | Imperial | Civic | 3/5 | 2/2 | UNDER-FLOOR | day-to-day, faucet, quest-reaction | likes-dislikes:81rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:100cells / faucet:4rows |
| `imperial_public_talos` | race-path | Imperial | Public-Talos | 3/5 | 1/2 | UNDER-FLOOR | book, day-to-day, quest-reaction | manifest-populated:[book] / likes-dislikes:8rows env[345:discover-location] / quest-reaction:23cells |
| `imperial_private_talos` | race-path | Imperial | Private-Talos | 2/5 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:8rows env[345:discover-location] / quest-reaction:23cells |
| `imperial_patron_civic` | race-path | Imperial | Patron-Civic | 3/5 | 2/2 | UNDER-FLOOR | day-to-day, faucet, quest-reaction | likes-dislikes:81rows env[313:rest-under-open-sky,314:sleep-in-bed,345:discover-location] / quest-reaction:100cells / faucet:4rows |
| `prince_mehrunes_dagon` | prince | Daedric | Mehrunes Dagon | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:5cells |
| `prince_boethiah` | prince | Daedric | Boethiah | 2/4 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:11rows env[314:sleep-in-bed] / quest-reaction:17cells |
| `prince_mephala` | prince | Daedric | Mephala | 2/4 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:10rows env[313:rest-under-open-sky] / quest-reaction:20cells |
| `prince_nocturnal` | prince | Daedric | Nocturnal | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:13cells |
| `prince_hircine` | prince | Daedric | Hircine | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:7cells |
| `prince_hermaeus_mora` | prince | Daedric | Hermaeus Mora | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:1cell / faucet:2rows |
| `prince_azura` | prince | Daedric | Azura | 2/4 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:11rows env[313:rest-under-open-sky,345:discover-location] / quest-reaction:2cells |
| `prince_namira` | prince | Daedric | Namira | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:2cells / faucet:2rows |
| `prince_sanguine` | prince | Daedric | Sanguine | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:1cell / faucet:2rows |
| `prince_vaermina` | prince | Daedric | Vaermina | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:2cells / faucet:1row |
| `prince_peryite` | prince | Daedric | Peryite | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:3cells / faucet:2rows |
| `prince_malacath` | prince | Daedric | Malacath | 2/4 | 1/2 | UNDER-FLOOR | day-to-day, quest-reaction | likes-dislikes:11rows env[313:rest-under-open-sky,314:sleep-in-bed] / quest-reaction:12cells |
| `prince_clavicus_vile` | prince | Daedric | Clavicus Vile | 2/4 | 1/2 | UNDER-FLOOR | faucet, quest-reaction | quest-reaction:2cells / faucet:2rows |
| `prince_meridia` | prince | Daedric | Meridia | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:7cells |
| `prince_molag_bal` | prince | Daedric | Molag Bal | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:6cells |
| `prince_sheogorath` | prince | Daedric | Sheogorath | 1/4 | 0/2 | UNDER-FLOOR | quest-reaction | quest-reaction:3cells |

## Empty P2 FormList shells (declared, not populated)

These FormLists are routed to a path but appear in neither `sourceFillEntries` nor an `approved-live-source-fill` route, so their declared sourceKinds do NOT count toward the floor.

| path_id | empty shell FormLists |
|---|---|
| `breton_knights_road` | PDV_FLST_P2_BretonKnightsRoadSources, PDV_FLST_P2_BretonVowSources |
| `breton_hidden_art` | PDV_FLST_P2_BretonHiddenArtSpells |
| `breton_green_way` | PDV_FLST_P2_BretonGreenWaySources, PDV_FLST_P2_BretonGreenWayHarvests |
| `redguard_crown` | PDV_FLST_P2_RedguardCrownSources |
| `redguard_forebear` | PDV_FLST_P2_RedguardForebearSources |
| `redguard_ashabah` | PDV_FLST_P2_RedguardAshAbahSources |
| `nord_old_ways` | PDV_FLST_P2_NordKyneTalosSources |
| `nord_nine_divines` | PDV_FLST_P2_NordKyneTalosSources |
| `bosmer_exchange` | PDV_FLST_P2_BosmerZenSources |
| `bosmer_bandit_road` | PDV_FLST_P2_BosmerBaanDarSources |
| `argonian_people` | PDV_FLST_P2_ArgonianCommunitySources |
| `argonian_void` | PDV_FLST_P2_ArgonianSithisSources |
| `dunmer_mephala` | PDV_FLST_P2_DunmerMephalaSources |
| `dunmer_deviation` | PDV_FLST_P2_DunmerDeviationSources |
| `imperial_civic` | PDV_FLST_P2_ImperialCivicSources, PDV_FLST_P2_ImperialPublicServiceSources, PDV_FLST_P2_ImperialMercySources, PDV_FLST_P2_ImperialLawfulOrderSources, PDV_FLST_P2_ImperialHonestWorkSources, PDV_FLST_P2_ImperialDeathDutySources |
| `imperial_private_talos` | PDV_FLST_P2_ImperialPrivateTalosSources |
| `imperial_patron_civic` | PDV_FLST_P2_ImperialPatronCivicSources |

## Data-quality caveats

- **No `weather`, `harvest`, or `spell-learned` curated source is populated anywhere in the live manifest.** Several FormLists *declare* these `sourceKinds` (e.g. `BretonGreenWaySources` weather/harvest, `NordKyneTalosSources` weather, `BretonHiddenArtSpells` spell-learned), but none appear in `sourceFillEntries` or an `approved-live-source-fill` route, so they are empty shells and do not count. Never-populated curated kinds: `harvest`, `spell-learned`, `weather`. The likes-dislikes CSV also carries no weather event-id (only env ids 313/314/345). Net effect: `weather` and `harvest` are currently unreachable as distinct types for EVERY path, which caps most race-paths at 3 types and is the dominant reason for the UNDER-FLOOR sweep.
- **Most Nord/Redguard/Khajiit quest-stage routes are `approved-static-route-only`, not live-fill.** Only Altmer (`AltmerLorkhanPenalties`), Bosmer (`BosmerYffreSources`), and Khajiit (`KhajiitFocusedSources`) routes carry `approved-live-source-fill`, so only those paths score the `quest-stage` type. Nord Old Ways' MQ104/MQ304 routes and Redguard's MS08 routes are present but static-only.
- **Prince quest-reaction is NOT zero.** A literal application of the rule (any matrix cell whose `deity` equals the path's name) gives Molag Bal 6, Peryite 3, Namira 2, Vaermina 2 quest-reaction cells (many are negative/reject branches, e.g. *destroy altar*, but the `deity` column still attributes them). Every one of the 16 Princes has at least 1 quest-reaction cell. This contradicts an a-priori expectation that Namira/Vaermina/Peryite/Molag Bal have none; the tool reports the ground-truth count.
- **Deity-name aliasing applied** (case-insensitive, apostrophe/dot/hyphen-stripped): `Azura`=`azurah`, `Hermaeus Mora`=`Mora`, `Clavicus Vile`=`Vile`, `Boethiah`=`Boethra`, `Mephala`=`Mafala`. `Auri-El`->`auriel`, `Y'ffre`->`yffre`, `Z'en`->`zen` fold by the same normalizer.
- **Several registry deities never appear in any data source** and therefore contribute nothing: Redguard `Onsi`/`Ruptga`/`Tava`/`Zeht`/`Satakal`, Breton `Phynaster`, Altmer/others absent from likes-dislikes, quest-matrix, and Part D. Redguard Crown/Forebear day-to-day comes only from `HoonDing`/`Leki`/`Tu'whacca`, which are the sole sect deities present in the sources.
- **Registry size is 35 race-paths + 16 princes = 51.** The task header said '33 race-paths / 49 total', but its own explicit enumeration (Khajiit = Lunar + 5 focused = 6; 3+3+3+2+4+3+6+3+4+4 = 35) sums to 35. The explicit per-path list is treated as authoritative over the header count.

