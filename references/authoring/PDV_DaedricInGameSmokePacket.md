# PDV Daedric In-Game Smoke Packet

Status: ready for tester execution
Generated: 12/06/2026, 5:27:31 pm AEST

## Preflight

From the repo, run the readiness preflight before launching Skyrim:

```text
node .\tools\pdv_daedric_test_readiness.mjs --deep
```

1. Launch Skyrim through Anvil MO2 with the `Devotion Dev` profile.
2. Start from a throwaway save or main-menu `coc qasmoke`.
3. Open `Mod Configuration > PlayerDevotion > Player` and enable `Developer Options`.
4. Open `Mod Configuration > PlayerDevotion > Debug`.
5. Enable debug traces:

```text
set PDV_GLO_DebugLevel to 2
```

## Fast MCM Sweep

Use `Route all Princes` on the MCM Debug page, then run:

```text
node .\tools\pdv_daedric_runtime_check.mjs --strict-manager --source mcm
```

This proves route markers only. It does not replace Active Effects, summary, Prisma, save/load, stack, or curse checks.

## QASmoke Physical Sender Proof

Use `coc qasmoke`, then find the activators named below. If the room is cluttered, use the console `help` command for the ACTI base and `player.placeatme <ACTI FormID>` to place a temporary copy next to the player. The placed copy uses the same scripted activator base.

| Prince | Activator name | ACTI EditorID | QASmoke REFR EditorID | Position | Checker |
|---|---|---|---|---|---|
| Boethiah | PDV DAEDRIC BOETHIAH | PDV_ACTI_Daedric_Boethiah_LiveSender | PDV_REFR_Daedric_Boethiah_LiveSender_QASmoke | x=1024, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Boethiah --strict-manager --source qasmoke --no-generic` |
| Azura | PDV DAEDRIC AZURA | PDV_ACTI_Daedric_Azura_LiveSender | PDV_REFR_Daedric_Azura_LiveSender_QASmoke | x=1216, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Azura --strict-manager --source qasmoke --no-generic` |
| Vaermina | PDV DAEDRIC VAERMINA | PDV_ACTI_Daedric_Vaermina_LiveSender | PDV_REFR_Daedric_Vaermina_LiveSender_QASmoke | x=1408, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Vaermina --strict-manager --source qasmoke --no-generic` |
| Meridia | PDV DAEDRIC MERIDIA | PDV_ACTI_Daedric_Meridia_LiveSender | PDV_REFR_Daedric_Meridia_LiveSender_QASmoke | x=1600, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Meridia --strict-manager --source qasmoke --no-generic` |
| Molag Bal | PDV DAEDRIC MOLAG | PDV_ACTI_Daedric_Molag_LiveSender | PDV_REFR_Daedric_Molag_LiveSender_QASmoke | x=1792, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Molag --strict-manager --source qasmoke --no-generic` |
| Mephala | PDV DAEDRIC MEPHALA | PDV_ACTI_Daedric_Mephala_LiveSender | PDV_REFR_Daedric_Mephala_LiveSender_QASmoke | x=1984, y=-768, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Mephala --strict-manager --source qasmoke --no-generic` |
| Malacath | PDV DAEDRIC MALACATH | PDV_ACTI_Daedric_Malacath_LiveSender | PDV_REFR_Daedric_Malacath_LiveSender_QASmoke | x=1024, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Malacath --strict-manager --source qasmoke --no-generic` |
| Mehrunes Dagon | PDV DAEDRIC DAGON | PDV_ACTI_Daedric_Dagon_LiveSender | PDV_REFR_Daedric_Dagon_LiveSender_QASmoke | x=1216, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Dagon --strict-manager --source qasmoke --no-generic` |
| Sheogorath | PDV DAEDRIC SHEO | PDV_ACTI_Daedric_Sheo_LiveSender | PDV_REFR_Daedric_Sheo_LiveSender_QASmoke | x=1408, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Sheo --strict-manager --source qasmoke --no-generic` |
| Namira | PDV DAEDRIC NAMIRA | PDV_ACTI_Daedric_Namira_LiveSender | PDV_REFR_Daedric_Namira_LiveSender_QASmoke | x=1600, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Namira --strict-manager --source qasmoke --no-generic` |
| Sanguine | PDV DAEDRIC SANGUINE | PDV_ACTI_Daedric_Sanguine_LiveSender | PDV_REFR_Daedric_Sanguine_LiveSender_QASmoke | x=1792, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Sanguine --strict-manager --source qasmoke --no-generic` |
| Clavicus Vile | PDV DAEDRIC VILE | PDV_ACTI_Daedric_Vile_LiveSender | PDV_REFR_Daedric_Vile_LiveSender_QASmoke | x=1984, y=-592, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Vile --strict-manager --source qasmoke --no-generic` |
| Hermaeus Mora | PDV DAEDRIC MORA | PDV_ACTI_Daedric_Mora_LiveSender | PDV_REFR_Daedric_Mora_LiveSender_QASmoke | x=1024, y=-416, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Mora --strict-manager --source qasmoke --no-generic` |
| Nocturnal | PDV DAEDRIC NOCTURNAL | PDV_ACTI_Daedric_Nocturnal_LiveSender | PDV_REFR_Daedric_Nocturnal_LiveSender_QASmoke | x=1216, y=-416, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Nocturnal --strict-manager --source qasmoke --no-generic` |
| Peryite | PDV DAEDRIC PERYITE | PDV_ACTI_Daedric_Peryite_LiveSender | PDV_REFR_Daedric_Peryite_LiveSender_QASmoke | x=1408, y=-416, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Peryite --strict-manager --source qasmoke --no-generic` |
| Hircine | PDV DAEDRIC HIRCINE | PDV_ACTI_Daedric_Hircine_LiveSender | PDV_REFR_Daedric_Hircine_LiveSender_QASmoke | x=1600, y=-416, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --prince Hircine --strict-manager --source qasmoke --no-generic` |
| Generic silence | PDV DAEDRIC GENERIC SILENCE | PDV_ACTI_Daedric_GenericSilenceProbe | PDV_REFR_Daedric_GenericSilenceProbe_QASmoke | x=1792, y=-416, z=64 | `node .\tools\pdv_daedric_runtime_check.mjs --strict-manager --source qasmoke` |

Example in-game lookup:

```text
help "PDV DAEDRIC AZURA" 4 ACTI
player.placeatme <ACTI FormID from help>
```

## Organic Quest-Stage Sender Proof

After controlled proof, use these exact stage routes from a throwaway save where PO3 quest-stage events are active and `PDV_PlayerEvents` has loaded.

| Prince | Console route | Checker | Note |
|---|---|---|---|
| Boethiah | `setstage DA02 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Boethiah --strict-manager --source organic --no-generic` |  |
| Azura | `setstage DA01 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Azura --strict-manager --source organic --no-generic` |  |
| Vaermina | `setstage DA16 190` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Vaermina --strict-manager --source organic --no-generic` | Skull branch after killing Erandur; do not use stage 200. |
| Meridia | `setstage DA09 500` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Meridia --strict-manager --source organic --no-generic` |  |
| Molag Bal | `setstage DA10 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Molag --strict-manager --source organic --no-generic` | Curse-access Prince; still needs no-double-fire manual proof. |
| Mephala | `setstage DA08 60` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Mephala --strict-manager --source organic --no-generic` |  |
| Malacath | `setstage DA06 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Malacath --strict-manager --source organic --no-generic` |  |
| Mehrunes Dagon | `setstage DA07 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Dagon --strict-manager --source organic --no-generic` |  |
| Sheogorath | `setstage DA15 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Sheo --strict-manager --source organic --no-generic` |  |
| Namira | `setstage DA11 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Namira --strict-manager --source organic --no-generic` |  |
| Sanguine | `setstage DA14 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Sanguine --strict-manager --source organic --no-generic` |  |
| Clavicus Vile | `setstage DA03 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Vile --strict-manager --source organic --no-generic` |  |
| Hermaeus Mora | `setstage DA04 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Mora --strict-manager --source organic --no-generic` |  |
| Nocturnal | `setstage TG09 200` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Nocturnal --strict-manager --source organic --no-generic` | Nightingale oath surface; still needs feel proof. |
| Peryite | `setstage DA13 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Peryite --strict-manager --source organic --no-generic` |  |
| Hircine | `setstage DA05 100` | `node .\tools\pdv_daedric_runtime_check.mjs --prince Hircine --strict-manager --source organic --no-generic` | Content-surface proof; not lycanthropy curse-onset proof. |

The `--source organic` checker requires the exact `eventbus_200_po3_queststage_daedric_*` manager marker, so an MCM or QASmoke route cannot count as organic proof.

## Manual Observations To Capture

- Active Effects at Seeker, Devoted, Champion, and lapse.
- `Show Prince summary` after signal, tier, stigma, live sender, generic silence, and lapse.
- Prisma or notification display for commitment, boon, price/stigma, and lapse.
- Generic silence leaves piety, tier, signal count, stigma, and Active Effects unchanged.
- Hircine and Molag Bal curse-access behavior does not double-fire race `CurseState` rows.
- Save/load sanity after one standard Prince, one native/tolerated Prince, and one curse-access Prince.

## Evidence Intake

Initialize or inspect the structured evidence ledger:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --init
node .\tools\pdv_daedric_evidence_intake.mjs --summary
```

After a successful all-Prince MCM route sweep:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince all --include-generic
```

After a successful single-Prince QASmoke proof:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source qasmoke --prince Azura --no-generic
```

After a successful single-Prince organic proof:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source organic --prince Azura --no-generic
```

After Molag Bal or Hircine curse-access proof, record the no-double-fire slot:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Molag --slot curseNoDoubleFire --status pass --note "Molag Bal proof did not double-fire race CurseState rows"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot curseNoDoubleFire --status pass --note "Hircine proof did not double-fire race CurseState rows"
```

Manual display slots use the same shape with `--slot activeEffects`, `summaryMessage`, `prismaNotification`, `saveLoad`, `stackLegibility`, `curseNoDoubleFire`, or `manualFeel`.

## Automated Gates To Re-Run After Testing

```text
dotnet run --project .\tools\pdv-daedric-author\PdvDaedricAuthor.csproj -- --check
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
node .\tools\pdv_daedric_beta_gate.mjs
```

