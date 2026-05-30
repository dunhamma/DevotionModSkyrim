# PDV Phase 20 QASmoke Runtime Proof Runbook

Status: QASmoke proof references are placed and read back cleanly; runtime proof
and final immersive world placement remain open.

This runbook consolidates the Phase 20 race proof slices into one counted
runtime pass. It proves that the temporary QASmoke proof activators reach the
intended EventBus and manager routes. It does not prove final world placement,
player-facing immersion, or anti-farm tuning by itself.

## Preconditions

Run these checks before opening Skyrim:

```powershell
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
```

The current expected verifier baseline is `PASS=1985, WARN=1, INFO=28`; the
single warning is the existing unnamed CK-authored INFO record class. If the
placement helper or strict verifier fails, do not runtime-test. Fix readback
first.

Use a fresh proof save or a clean save made before any Phase 20 activator pass.
Before launching Skyrim, archive the existing Papyrus log so the checker cannot
pass on stale traces:

```powershell
if (Test-Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log") { Rename-Item -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -NewName ("Papyrus.0.phase20-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log") }
```

## Shared In-Game Setup

Open the console and run:

```text
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

For route-marker smoke, one session can step through all six race groups by
changing `PDV_GLO_OriginRace` before each group. For counted immersion/status
proof, prefer one clean proof save per race so the Survey Devotion readout is
not muddied by another race's earlier temporary signals.

## Race Groups

| Race | Origin command | Activators | Checker |
|------|----------------|------------|---------|
| Altmer | `set PDV_GLO_OriginRace to 3` | `PDV_REFR_AltmerDragonbornCrisisSignal`, `PDV_REFR_AltmerLorkhanPressureSignal`, `PDV_REFR_AltmerDawnSteadinessSignal`, `PDV_REFR_AltmerOrthodoxCostSignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race altmer` |
| Argonian | `set PDV_GLO_OriginRace to 7` | `PDV_REFR_ArgonianHistMaintenanceSignal`, `PDV_REFR_ArgonianPeopleSupportSignal`, `PDV_REFR_ArgonianVoidSignal`, `PDV_REFR_ArgonianBedOfChoiceSignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race argonian` |
| Orc | `set PDV_GLO_OriginRace to 8` | `PDV_REFR_OrcStrongholdForgeSignal`, `PDV_REFR_OrcCityDignitySignal`, `PDV_REFR_OrcLegionServiceSignal`, `PDV_REFR_OrcSelfMadeCommunitySignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race orc` |
| Redguard | `set PDV_GLO_OriginRace to 9` | `PDV_REFR_RedguardCrownTombRespectSignal`, `PDV_REFR_RedguardForebearRoadSignal`, `PDV_REFR_RedguardAshAbahDeathDutySignal`, `PDV_REFR_RedguardFarShoresTokenSignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race redguard` |
| Khajiit | `set PDV_GLO_OriginRace to 6` | `PDV_REFR_KhajiitMoonObservanceSignal`, `PDV_REFR_KhajiitRoadHomeAnchorOneSignal`, `PDV_REFR_KhajiitRoadHomeAnchorTwoSignal`, `PDV_REFR_KhajiitBaanDarRoadTrickSignal`, `PDV_REFR_KhajiitRajhinElegantTheftSignal`, `PDV_REFR_KhajiitAlkoshDragonOrderSignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race khajiit` |
| Bosmer | `set PDV_GLO_OriginRace to 4` | `PDV_REFR_BosmerOldContractProperHuntSignal`, `PDV_REFR_BosmerOldContractForestKeptSignal`, `PDV_REFR_BosmerLivingStoryCommunityKeptSignal`, `PDV_REFR_BosmerLivingStoryNatureSiteSignal`, `PDV_REFR_BosmerExchangeDebtSettledSignal`, `PDV_REFR_BosmerExchangeProportionateVengeanceSignal`, `PDV_REFR_BosmerBanditRoadRoadLifeSignal`, `PDV_REFR_BosmerBanditRoadReversalSignal` | `node .\tools\pdv_phase20_runtime_check.mjs --race bosmer` |

After closing Skyrim, run the consolidated checker:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race all
node .\tools\pdv_phase20_runtime_check.mjs --race all --strict-manager
```

`--strict-manager` is useful for counted closeout, but the default route check
is the minimum hard gate. If `--strict-manager` fails only on optional markers,
inspect the Papyrus log and the relevant manager source before changing code;
some routes intentionally expose their visible state through Survey/status
rather than a unique manager trace.

## Immersion and Status Checks

For each race, capture the log checker result and a player-facing status readout.
Use Survey Devotion or the MCM Player page after the activators fire. The proof
must show:

| Race | Immersion/status surface |
|------|--------------------------|
| Altmer | Crisis source/state, Lorkhan pressure, quiet dawn steadiness, and orthodox-cost favor read as competing Altmer identity pressures rather than generic bonuses. |
| Argonian | Hist, People, Void, and bed-of-choice movement read as layered belonging; one Void hit must not replace the Hist as the whole religion. |
| Orc | Stronghold, City, Legion/Exile, and self-made community read as complete Orc lives, not as a single favored class path. |
| Redguard | Crown, Forebear, Ash'abah, and Far Shores token movement read as sect/death-duty context, not generic undead or travel rewards. |
| Khajiit | Moon observance, two road-home anchors, and Baan Dar/Rajhin/Alkosh focus weights read as lunar-road practice; repeating one road anchor should not feel optimal. |
| Bosmer | Old Contract, Living Story, Exchange, and Bandit Road favor counters all move; Bandit Road reversal remains rare enough to feel like a story payoff instead of a daily faucet. |

## Negative Checks

The runtime pass is incomplete without at least these manual checks:

- Wrong-origin rejection: set `PDV_GLO_OriginRace` to a different race and confirm
  an activator from the target race does not add the target route marker.
- Same-day or same-anchor pressure: for Khajiit, repeat
  `PDV_REFR_KhajiitRoadHomeAnchorOneSignal` and confirm the immediate repeat is
  rejected or does not improve the cadence.
- Major-favor pressure: for Bosmer, repeat
  `PDV_REFR_BosmerBanditRoadReversalSignal` and confirm the seven-day cooldown
  blocks immediate farming.
- Survey/status copy: make sure the resulting player-facing text reads like the
  race's theology and life context, not an internal route/debug label dump.

## Closeout Gate

Do not mark any Phase 20 race runtime-proven until all of the following are true:

- The race-specific checker passes against a fresh Papyrus log.
- Survey Devotion or the MCM Player page shows the intended player-facing state.
- The negative checks above are recorded for the race or explicitly deferred with
  a reason.
- `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
  remains clean after the runtime pass.
- Final world placement is still tracked separately from the QASmoke proof
  cluster.
