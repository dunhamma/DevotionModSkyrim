# PDV Daedric Controlled Proof Runbook

Status: ready for in-game smoke
Updated: 2026-06-07 AEST

## Purpose

This runbook is the controlled/debug proof path for the all-Prince Daedric
CAT-6 tranche. It lets the tester exercise every Skyrim-present Prince from
the live MCM, physical QASmoke proof sender refs, or exact vanilla quest-stage
organic senders.

For a compact command sheet generated from the current contract, use
`PDV_DaedricInGameSmokePacket.md` or refresh it with:

```text
node .\tools\pdv_daedric_ingame_packet.mjs --write
```

Before launching Skyrim, run:

```text
node .\tools\pdv_daedric_test_readiness.mjs --deep
```

During and after in-game testing, record runtime/display evidence with:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --summary
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince all --include-generic
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source organic --prince Azura --no-generic
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Azura --slot organicRoute --status pass --note "DA01 stage 100 produced exact organic manager marker"
```

Prefer `--from-runtime-check` for route-marker slots after the matching
`pdv_daedric_runtime_check` command passes. Use manual `--record` calls for
Active Effects, MessageBox, Prisma/notification, save/load, stack legibility,
manual feel, and Molag/Hircine curse no-double-fire observations.

This proves the player-visible mechanics path: Prince selection, commitment
signal, piety tier transition, boon/price Active Effects, stigma counter,
notification/Prisma toast, summary readback, and lapse cleanup.

It also includes an EventBus live-sender scaffold proof and a generic-source
silence probe. The organic sender routes are exact quest-stage routes for all
sixteen Princes; they still need in-game runtime proof before they count.

## Implementation Surface

Live source:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc
```

Compiled output:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_MCM.pex
```

The MCM Debug page has a new `Daedric display proof` section. It uses the
already-wired `PDV_FLST_DaedricPaths_All` property on the live `PDV_MCM` quest.
The live-sender scaffold routes through `PDV_EventBus` and
`PDV__ManagerQuest.HandleDaedricPrinceSignal`; `PDV_EventSignalActivator` and
`PDV_EventSignalEffect` reserve route `200` for curated Prince sender refs and
route `201` for generic silence probes. The manager
`PDV_FLST_DaedricPaths_All` property is wired in the framework ESP by
`tools/pdv-daedric-author`.

Physical QASmoke proof senders are also live in `PlayerDevotion_Framework.esp`.
Each Prince has one route-200 `PDV_REFR_Daedric_<Prince>_LiveSender_QASmoke`
reference linked to `PDV_ACTI_Daedric_<Prince>_LiveSender`. The generic silence
negative check is `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`, linked to
`PDV_ACTI_Daedric_GenericSilenceProbe` on route 201.

Organic live sender FormLists are wired on the `PDV_PlayerEvents` player
alias and registered through PO3 quest-stage events:

- `PDV_FLST_Daedric_BoethiahLiveSources`: `DA02` (`04D8D6:Skyrim.esm`) stage
  100 routes Boethiah index 0.
- `PDV_FLST_Daedric_AzuraLiveSources`: `DA01` (`028AD6:Skyrim.esm`) stage 100
  routes Azura index 1.
- `PDV_FLST_Daedric_VaerminaLiveSources`: `DA16` (`0242AF:Skyrim.esm`) stage
  190 routes Vaermina index 2. This is the Skull branch after killing Erandur;
  do not use stage 200, which is the Erandur-lives anti-Vaermina ending.
- `PDV_FLST_Daedric_MeridiaLiveSources`: `DA09` (`04E4E1:Skyrim.esm`) stage
  500 routes Meridia index 3.
- `PDV_FLST_Daedric_MolagLiveSources`: `DA10` (`022F08:Skyrim.esm`) stage 200
  routes Molag Bal index 4.
- `PDV_FLST_Daedric_MephalaLiveSources`: `DA08` (`04A37B:Skyrim.esm`) stage
  60 routes Mephala index 5.
- `PDV_FLST_Daedric_MalacathLiveSources`: `DA06` (`03B681:Skyrim.esm`) stage
  200 routes Malacath index 6.
- `PDV_FLST_Daedric_DagonLiveSources`: `DA07` (`0240B8:Skyrim.esm`) stage 100
  routes Mehrunes Dagon index 7.
- `PDV_FLST_Daedric_SheoLiveSources`: `DA15` (`02AC68:Skyrim.esm`) stage 200
  routes Sheogorath index 8.
- `PDV_FLST_Daedric_NamiraLiveSources`: `DA11` (`02C358:Skyrim.esm`) stage
  100 routes Namira index 9.
- `PDV_FLST_Daedric_SanguineLiveSources`: `DA14` (`01BB9B:Skyrim.esm`) stage
  200 routes Sanguine index 10.
- `PDV_FLST_Daedric_VileLiveSources`: `DA03` (`01BFC4:Skyrim.esm`) stage 200
  routes Clavicus Vile index 11.
- `PDV_FLST_Daedric_MoraLiveSources`: `DA04` (`02D512:Skyrim.esm`) stage 100
  routes Hermaeus Mora index 12.
- `PDV_FLST_Daedric_NocturnalLiveSources`: `TG09` (`021555:Skyrim.esm`) stage
  200 routes Nocturnal index 13.
- `PDV_FLST_Daedric_PeryiteLiveSources`: `DA13` (`08998D:Skyrim.esm`) stage
  100 routes Peryite index 14.
- `PDV_FLST_Daedric_HircineLiveSources`: `DA05` (`02A49A:Skyrim.esm`) stage
  100 routes Hircine index 15.

These routes use separate `PDV.P2Source.daedric_*` duplicate keys, so they do
not consume the race P2 route keys for Dunmer, Nord, Bosmer, Khajiit, or Orc.

## Preflight

1. Launch Skyrim through Anvil MO2 with the `Devotion Dev` profile.
2. Start from a throwaway save or `coc qasmoke`.
3. Open `Mod Configuration > PlayerDevotion > Player`.
4. Enable `Developer Options`.
5. Open `Debug`.

Optional but useful:

```text
set PDV_GLO_DebugLevel to 2
```

If the MCM does not refresh after compiling a new `.pex`, fully restart Skyrim.
A main-menu reload is not always enough for MCM/script-instance changes.

## QASmoke Sender Proof

Use this route when you want a physical in-world sender test instead of only
the MCM button path.

1. Start from a clean throwaway save or main-menu `coc qasmoke`.
2. Find the debug activators named `PDV DAEDRIC <PRINCE>`.
3. Activate one Prince sender.
4. Open the MCM Debug page and select the same Prince in `Selected Prince`.
5. Select `Show Prince summary`.
6. Confirm that the Prince gained one commitment signal and +10 piety from the
   EventBus route.
7. Activate `PDV DAEDRIC GENERIC SILENCE`.
8. Show the same Prince summary again and confirm piety, signal count, stigma,
   tier, and Active Effects did not change.

The QASmoke route uses once-per-day keys. If retesting on the same in-game day,
use a new save/day or reset the target Prince path before comparing summaries.

## Organic Live Sender Proof

Use this route after controlled proof when you want to prove the vanilla
quest-stage senders. Start from a throwaway save where PO3 events are active
and `PDV_PlayerEvents` has loaded at least once. Console `setstage` is valid
for route proof; normal-play completion is still better for final feel notes.

1. Enable debug traces:

```text
set PDV_GLO_DebugLevel to 2
```

2. Complete or console-advance one of the exact approved stages:

```text
setstage DA01 100
setstage DA02 100
setstage DA16 190
setstage DA09 500
setstage DA10 200
setstage DA08 60
setstage DA05 100
setstage DA06 200
setstage DA07 100
setstage DA15 200
setstage DA11 100
setstage DA14 200
setstage DA03 200
setstage DA04 100
setstage TG09 200
setstage DA13 100
```

3. Run the matching checker. Examples:

```text
node .\tools\pdv_daedric_runtime_check.mjs --prince Azura --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Boethiah --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Vaermina --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Meridia --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Molag --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Mephala --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Hircine --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Malacath --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Dagon --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Sheo --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Namira --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Sanguine --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Vile --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Mora --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Nocturnal --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Peryite --strict-manager --source organic --no-generic
```

4. Open the MCM Debug page, select the same Prince, and use `Show Prince
   summary`.
5. Confirm one commitment signal and +10 piety were added by the
   `po3_queststage_daedric_*` source.
6. Confirm unrelated Princes did not change.

The `--source organic` flag requires the exact
`eventbus_200_po3_queststage_daedric_*` manager trace, so an MCM or QASmoke
route cannot satisfy an organic sender proof by accident. The checker validates
route markers and manager traces only. Active Effects, MessageBox summary,
Prisma toast, save/load, stack legibility, and curse no-double-fire behavior
still need manual observation. Hircine's `DA05` route is a Hircine
content-surface proof; it is not a lycanthropy curse-onset proof.

## Fast All-Prince Route Sweep

Use this route when you need route-marker evidence for the whole Prince roster
without activating every QASmoke object individually.

1. Open the MCM Debug page.
2. Select `Route all Princes`.
3. Confirm the prompt.
4. Wait for the top-left `PDV Daedric all-Prince sender sweep complete`
   notification.
5. Run the checker below.

After activating all sixteen Prince senders plus the generic silence sender,
run:

```text
node .\tools\pdv_daedric_runtime_check.mjs --strict-manager --source mcm
```

For a partial smoke, use:

```text
node .\tools\pdv_daedric_runtime_check.mjs --prince Molag --strict-manager --source mcm --no-generic
node .\tools\pdv_daedric_runtime_check.mjs --prince Hircine --strict-manager --source mcm
```

The checker proves route markers only. Keep the Active Effects, summary,
Prisma, curse, save/load, and stack observations in the manual evidence notes.

## Per-Prince Controlled Proof

For each Prince:

1. Use `Selected Prince` until the target Prince is shown.
2. Select `Reset Prince path`.
3. Select `Add Prince signal`.
4. Select `Force Seeker`.
5. Check Active Effects for the Seeker boon and Seeker price.
6. Select `Force Devoted`.
7. Check Active Effects for Seeker + Devoted boon/price stacking.
8. Select `Force Champion`.
9. Check Active Effects for Seeker + Devoted + Champion boon/price stacking.
10. Select `Add stigma`.
11. Select `Show Prince summary`.
12. Select `Route live sender`.
13. Confirm the summary now shows one additional commitment signal and +10
    piety from the EventBus path.
14. Select `Generic silence probe`.
15. Confirm the summary did not change.
16. Select `Force lapse`.
17. Check Active Effects no longer show the Prince boon/price stack.

Expected visible feedback:

- A top-left `PDV Daedric ...` notification for reset, signal, tier, lapse, and
  stigma actions.
- A summary MessageBox with `p=`, `tier=`, `sig=`, `stigma=`, `state=`,
  `boon=`, `price=`, and `exit=`.
- Prisma overlay toast where the bridge is available.
- `Route live sender` and the matching QASmoke Prince activator change the
  selected Prince through EventBus; `Generic silence probe` and the QASmoke
  generic activator emit a notice but do not change piety, tier, signal count,
  stigma, or Active Effects.

## Pass Bar

A Prince passes controlled display proof when the tester records:

- Seeker, Devoted, Champion, and lapse actions execute without Papyrus errors.
- Active Effects show the expected cumulative boon/price stack at each tier.
- `Show Prince summary` matches the expected piety tier and stigma state.
- Lapse clears the Prince boon/price stack.
- EventBus live-sender proof changes only the selected Prince.
- Generic silence proof leaves the selected Prince summary unchanged.
- No unrelated race `CurseState` response double-fires during non-curse proof.

Hircine and Molag Bal need an extra curse-access pass after the generic
controlled proof because their final beta-display bar includes curse onset,
cure/exit, and no-double-fire behavior.

## Gate Evidence Already Green

Latest automated evidence after all-sixteen exact organic sender placement:

```text
node .\tools\pdv_compile.mjs --script PDV_MCM
node .\tools\pdv_compile.mjs --script PDV_PlayerEvents --script PDV_MCM
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_EventBus --script PDV_EventTypes --script PDV_EventSignalActivator --script PDV_EventSignalEffect --script PDV_MCM
dotnet run --project .\tools\pdv-daedric-author\PdvDaedricAuthor.csproj -- --check
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
node .\tools\pdv_daedric_runtime_check.mjs --self-test --strict-manager
node .\tools\pdv_daedric_runtime_check.mjs --self-test --strict-manager --source organic
node .\tools\pdv_daedric_ingame_packet.mjs --write
node .\tools\pdv_daedric_test_readiness.mjs --deep
node .\tools\pdv_daedric_evidence_intake.mjs --summary
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince all --include-generic
node .\tools\pdv_daedric_beta_gate.mjs
```

Results:

```text
PDV_MCM compile: 0 errors, 0 warnings
PDV_PlayerEvents compile: 0 errors, 0 warnings
Daedric all-Prince MCM route sweep compile: 0 errors, 0 warnings
Daedric live-sender scaffold compile: 0 errors, 0 warnings
pdv-daedric-author --check: PASS all 16 plus 17 QASmoke sender refs plus 16 organic FormLists
pdv_content_verify: FAIL=0, WARN=0, PASS=1081, INFO=4
strict Phase 20 race-costing: PASS=2841, WARN=2, INFO=30
Phase 2 reward readback: PASS=1268
pdv_daedric_runtime_check --self-test --strict-manager: PASS all 16 plus generic
pdv_daedric_runtime_check --self-test --strict-manager --source organic: PASS all 16 plus generic
pdv_daedric_ingame_packet --write: generated PDV_DaedricInGameSmokePacket.md
pdv_daedric_test_readiness --deep: PASS=71
pdv_daedric_evidence_intake --summary: PENDING until in-game proof is recorded
pdv_daedric_evidence_intake --from-runtime-check: records route slots only after matching Papyrus log proof passes
pdv_daedric_beta_gate: FAIL/PENDING until all runtime/display slots pass
```

Latest framework backup from the all-sixteen organic sender authoring pass:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\PlayerDevotion_Framework.esp.20260607-194539.bak
```
