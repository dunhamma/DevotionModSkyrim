# PDV P2 FormList ESP-Truth Ledger

**Generated:** 2026-07-13 by `tools/pdv_p2_formlist_esp_audit.mjs` (reads the deployed Devotion.esp via mutagen-bridge.exe)

This audit is the server-independent counterpart to `pdv_signal_e2e_gate.mjs`. It reads the true FormList population (`Items` field) straight from `Devotion.esp` and fails on empty-but-routed lists, on ledger drift (a ledger calls a surface shell/unverified while the ESP proves it populated), and on manifest approved fills missing from the live ESP.

## Summary

- P2 receivers audited: **39**
- Populated: **39** | Empty: **0** | Missing FLST record: **0**
- FAIL rows: **0** | WARN rows: **0**
- ledger-drift (shell claim vs populated ESP): **0** | empty-routed: **0** | fill-missing: **0**

## Full per-receiver table

| Property | Race | Routed | ESP items | Approved fills | Fills missing | Undeclared | E2E verdict | Shell claim | Verdict |
|---|---|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_AltmerAurielSources` | Altmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | Altmer | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_AltmerMagnusSources` | Altmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_AltmerXarxesSources` | Altmer | yes | 3 | 3 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ArgonianCommunitySources` | Argonian | yes | 3 | 3 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ArgonianHistSources` | Argonian | yes | 4 | 4 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ArgonianSithisSources` | Argonian | yes | 4 | 4 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BosmerBaanDarSources` | Bosmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BosmerYffreSources` | Bosmer | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BosmerZenSources` | Bosmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonGreenWayHarvests` | Breton | yes | 4 | 4 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonGreenWaySources` | Breton | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonHiddenArtSources` | Breton | yes | 3 | 3 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonHiddenArtSpells` | Breton | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonKnightsRoadSources` | Breton | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_BretonVowSources` | Breton | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_DunmerAzuraSources` | Dunmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_DunmerBoethiahSources` | Dunmer | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_DunmerDeviationSources` | Dunmer | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_DunmerMephalaSources` | Dunmer | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialCivicSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialDeathDutySources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialHonestWorkSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialLawfulOrderSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialMercySources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialPatronCivicSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialPrivateTalosSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialPublicServiceSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_ImperialPublicTalosSources` | Imperial | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_KhajiitFocusedSources` | Khajiit | yes | 3 | 3 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_KhajiitLunarSources` | Khajiit | yes | 5 | 5 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_NordHircineArkaySources` | Nord | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_NordKyneTalosSources` | Nord | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_NordOldWaysSources` | Nord | yes | 3 | 3 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_OrcMalacathSources` | Orc | yes | 2 | 2 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_RedguardAshAbahSources` | Redguard | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_RedguardCrownSources` | Redguard | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_RedguardForebearSources` | Redguard | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |
| `PDV_FLST_P2_RedguardSpineSources` | Redguard | yes | 1 | 1 | 0 | 0 | GREEN | no | OK |

