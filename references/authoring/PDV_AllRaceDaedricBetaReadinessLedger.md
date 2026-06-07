# PDV All-Race + Daedric Beta Readiness Ledger

**Created:** 2026-06-04
**Status:** Internal beta-feel blocker ledger
**Owner:** Companion to `PDV_Phase20_BetaReadinessRemainder.md`,
`PDV_PreBetaRaceGateLedger.md`, `PDV_DeityCoverageMatrix.json`,
`PDV_Daedric_DecisionPacket_CAT4.md`,
`PDV_DaedricBatch0_D18ProofLedger.md`, and `PDV_CAT6PromotionPilot.md`

## Purpose

This ledger is the single routing surface for the current beta-feel gap:
all ten races plus all sixteen Skyrim-present Daedric Princes must be ready
for content-feel testing. It deliberately separates clean structure/readback
from runtime proof and manual feel proof.

`Conditional` remains internal only. External beta-feel readiness requires
pass-level race evidence plus Daedric 20C content-ready closure.

## Evidence Baseline

```text
Git fetch: origin/main equals local HEAD on 2026-06-04; no fast-forward was available.

Housecarl load order:
Profile: Devotion Dev
PlayerDevotion_Framework.esp: ACTIVE
P2 FLST shell readback: 34 PDV_FLST_P2_* FormLists, all winning from PlayerDevotion_Framework.esp, override_depth=1

Content verifier:
node .\tools\pdv_content_verify.mjs
Result: FAIL=0, WARN=0, PASS=1079, INFO=4

Strict Phase 20 verifier:
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
Result: PASS=2699, WARN=1, INFO=29
Known warning: unnamed CK-authored INFO records in PlayerDevotion_Framework.esp

P2 book runtime checker:
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager
Result: PASS across session logs for all approved filled P2 book families; FAIL only if requiring one current Papyrus.0.log sweep after log rotation
Papyrus.1.log pass: Dunmer Azura, Dunmer Boethiah, Imperial public Talos, Nord Old Ways, Nord Hircine/Arkay, Altmer Auri-El, Altmer Magnus, Altmer Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath
Papyrus.0.log pass: Redguard ancestor spine
Earlier log pass: Breton Hidden Art
Current missing runtime proof: none for approved filled P2 book families across session logs; fresh same-log full sweep remains optional only

Daedric CAT-6 author/readback tranche (2026-06-07):
dotnet run --project .\tools\pdv-daedric-author\PdvDaedricAuthor.csproj -- --check
Result: PASS for all 16 Skyrim-present Princes
Compiled scripts: all 15 generated non-Hircine PDV_DaedricPath_<Prince> scripts compile 0 error / 0 warning
Strict Phase 20 verifier after SEQ refresh: PASS=2841, WARN=2, INFO=30
Content verifier: FAIL=0, WARN=0, PASS=1081, INFO=4
Reward readback audit: PASS=1268

Daedric controlled sender surface (2026-06-07):
Live MCM source: D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc
Compiled output: D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_MCM.pex
Controlled proof runbook: references\authoring\PDV_DaedricControlledProof_Runbook.md
PDV_MCM + EventBus live-sender scaffold compile: 0 errors / 0 warnings
Manager FormList property: PDV__ManagerQuest.PDV_FLST_DaedricPaths_All wired by pdv-daedric-author
QASmoke proof senders: 16 PDV_REFR_Daedric_<Prince>_LiveSender_QASmoke route-200 refs plus PDV_REFR_Daedric_GenericSilenceProbe_QASmoke route-201 ref, all read back to their ACTI bases
Fast route sweep: MCM Debug `Route all Princes` routes all 16 EventBus sender cues plus the generic silence probe in one prompt
QASmoke runtime checker: tools\pdv_daedric_runtime_check.mjs self-test PASS for all 16 plus generic; run --strict-manager --source qasmoke after physical QASmoke activation, --source mcm after MCM sweep activation, and --source organic after exact vanilla quest-stage activation
Structured evidence intake: references\authoring\PDV_DaedricRuntimeEvidenceLedger.json exists with all 16 Princes pending; update with tools\pdv_daedric_evidence_intake.mjs only after in-game proof
Daedric beta-display gate: tools\pdv_daedric_beta_gate.mjs currently fails closed at PENDING=16 until all runtime/display slots pass
Latest ESP backup: D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\PlayerDevotion_Framework.esp.20260607-191318.bak
Status: MCM controls, EventBus live-sender scaffold, and physical QASmoke proof sender refs are ready for in-game smoke; not yet counted runtime proof

Daedric exact organic live senders (2026-06-07):
Live source: D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_PlayerEvents.psc
Compiled output: D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_PlayerEvents.pex
Routes: Boethiah DA02 stage 100, Azura DA01 stage 100, Vaermina DA16 stage 190, Meridia DA09 stage 500, Molag Bal DA10 stage 200, Mephala DA08 stage 60, Malacath DA06 stage 200, Mehrunes Dagon DA07 stage 100, Sheogorath DA15 stage 200, Namira DA11 stage 100, Sanguine DA14 stage 200, Clavicus Vile DA03 stage 200, Hermaeus Mora DA04 stage 100, Nocturnal TG09 stage 200, Peryite DA13 stage 100, Hircine DA05 stage 100
Readback: all 16 PDV_FLST_Daedric_<Prince>LiveSources FormLists exist, contain their exact Skyrim.esm quest FormKeys, and are wired on the PDV_PlayerEvents alias script
Latest ESP backup: D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\PlayerDevotion_Framework.esp.20260607-194539.bak
Status: all exact organic quest-stage senders are placed/readback-clean and ready for in-game proof; none are counted runtime proof yet
```

## Race Runtime And Manual Gap

| Race | Current beta-feel state | P2 book/source runtime state | Manual evidence gap |
|---|---|---|---|
| Altmer | Fail - runtime/manual proof deferred | Auri-El, Magnus, and Xarxes book source manager-log proof passed on 2026-06-04; toast/status surfacing patched after that proof and needs rerun | Stack snapshot, manual feel, immersive hook proof, asset status |
| Khajiit | Fail - runtime/manual proof deferred | Lunar book source manager-log proof passed on 2026-06-04; one-book Survey/status surfacing patched after that proof and needs rerun | Survey/status did not visibly change during pre-fix smoke; wrong-origin, generic-source silence, stack snapshot, and feel remain pending |
| Argonian | Fail - runtime/manual proof deferred | Hist book source manager-log proof passed on 2026-06-04; source-preserving toast/status surfacing patched after that proof and needs rerun | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Orc | Fail - runtime/manual proof deferred | Malacath book source manager-log proof passed on 2026-06-04; toast/status surfacing patched after that proof and needs rerun | Startup UI overlap was observed and patched in live script; wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Redguard | Fail - runtime/manual proof deferred | Ancestor-spine book source manager-log proof passed on 2026-06-04; toast/status surfacing patched after that proof and needs rerun | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Bosmer | Fail - runtime/manual proof deferred | P2 FormList shells exist; Bosmer P2 source shells are currently empty | All manual slots pending |
| Breton | Fail - runtime/manual proof deferred | Hidden Art book source manager-log proof passed in an earlier log; rerun only if same-log proof is desired | All manual slots pending |
| Dunmer | Fail - runtime/manual proof deferred | Azura and Boethiah book source manager-log proof passed on 2026-06-04 | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Imperial | Fail - runtime/manual proof deferred | Public Talos book source manager-log proof passed on 2026-06-04 | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Nord | Fail - runtime/manual proof deferred | Old Ways and Hircine/Arkay book source manager-log proof passed on 2026-06-04 | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |

## P2 FormList Shell State

Filled current source families:

- `PDV_FLST_P2_BretonHiddenArtSources` - 3 items
- `PDV_FLST_P2_DunmerAzuraSources` - 2 items
- `PDV_FLST_P2_DunmerBoethiahSources` - 2 items
- `PDV_FLST_P2_ImperialPublicTalosSources` - 1 item
- `PDV_FLST_P2_NordHircineArkaySources` - 1 item
- `PDV_FLST_P2_NordOldWaysSources` - 3 items
- `PDV_FLST_P2_AltmerAurielSources` - 2 items
- `PDV_FLST_P2_AltmerMagnusSources` - 2 items
- `PDV_FLST_P2_AltmerXarxesSources` - 3 items
- `PDV_FLST_P2_ArgonianHistSources` - 4 items
- `PDV_FLST_P2_KhajiitLunarSources` - 3 items
- `PDV_FLST_P2_OrcMalacathSources` - 2 items
- `PDV_FLST_P2_RedguardSpineSources` - 1 item

Empty shells are not failures by themselves. They remain blockers only when
their race route claims require a live source family for beta-feel proof.

## Daedric 20C Gap

Roster authority is `PDV_DeityCoverageMatrix.json`: all sixteen
Skyrim-present Princes are in 1.0 scope, and Jyggalag is excluded unless later
adopted explicitly.

The current Daedric state is:

- D-15 stigma model, D-16 curse-access template, D-17 authoring order, and
  D-18 per-Prince content-ready bar are locked.
- `race-sheets/PDV_DaedricContent_Manifest.md` now carries draft rows for all
  sixteen Princes.
- Draft prose and clean content verification do not equal beta-feel proof.
- Broad Daedric CAT-6 record promotion/readback is authored for all sixteen
  Princes through `PDV_DaedricPrinceRecordContracts.json` and
  `tools/pdv-daedric-author`.
- The MCM Debug page and QASmoke now expose controlled sender paths for all
  sixteen Princes through `PDV_FLST_DaedricPaths_All`, route-200
  `PDV_REFR_Daedric_<Prince>_LiveSender_QASmoke` refs, plus a route-201
  generic-source silence probe; see
  `PDV_DaedricControlledProof_Runbook.md`.
- Exact organic vanilla quest-stage senders are wired/readback for all sixteen
  Princes. The remaining Daedric beta-feel blocker is running
  controlled/runtime display proof, proving those organic routes in game,
  wrong/generic source silence, and stack/Survey legibility. Record those
  results in `PDV_DaedricRuntimeEvidenceLedger.json` with
  `tools/pdv_daedric_evidence_intake.mjs`; readback alone must leave rows
  pending. `tools/pdv_daedric_beta_gate.mjs` is the fail-closed promotion gate
  and currently remains `PENDING=16` by design.

| Batch | Princes | Current status | Beta-feel blocker |
|---|---|---|---|
| Pilot already drafted | Boethiah / Boethra | CAT-6 records authored/read back; MCM and QASmoke controlled senders ready; exact `DA02` stage 100 organic sender wired/readback; native Dunmer and Khajiit route through no-native-row behavior | Run controlled display proof, organic sender proof, and stack/Survey legibility |
| Batch 0 template proof | Azura / Azurah, Vaermina, Meridia, Molag Bal | CAT-6 records authored/read back; MCM and QASmoke controlled senders ready; exact organic senders wired/readback: Azura `DA01` 100, Vaermina `DA16` 190, Meridia `DA09` 500, Molag Bal `DA10` 200; Molag Bal remains curse-access | Run controlled display proof, organic sender proof, and Molag Bal curse-state no-double-fire proof |
| Batch 1 native variants | Mephala / Mafala, Malacath / Mauloch | CAT-6 records authored/read back; MCM and QASmoke controlled senders ready; exact organic senders wired/readback: Mephala `DA08` 60, Malacath `DA06` 200 | Run native-integration display proof, organic sender proof, and stack/Survey legibility |
| Batch 2 standard external pacts | Mehrunes Dagon, Sheogorath, Namira / Namiira, Sanguine / Sangiin, Clavicus Vile, Hermaeus Mora, Nocturnal | CAT-6 records authored/read back; MCM and QASmoke controlled senders ready; exact organic senders wired/readback: Dagon `DA07` 100, Sheogorath `DA15` 200, Namira `DA11` 100, Sanguine `DA14` 200, Clavicus Vile `DA03` 200, Hermaeus Mora `DA04` 100, Nocturnal `TG09` 200 | Run standard-pact controlled display proof and organic sender proof; Nocturnal must still prove Thieves Guild/Nightingale oath surface |
| Batch 3 tolerated/curse-access tail | Peryite, Hircine | CAT-6 records authored/read back; MCM and QASmoke controlled senders ready; exact organic senders wired/readback: Peryite `DA13` 100, Hircine `DA05` 100; Hircine retains earlier Nord/curse runtime pattern | Run Peryite tolerated-class display proof and Hircine content-surface proof without double-firing curse-state rows |

## Per-Prince Acceptance Checklist

A Prince cannot be called beta-feel ready until all of these are true:

1. Tone profile is reviewed against the manifest and matrix.
2. Seeker, Devoted, and Champion boon descriptions are ratified.
3. Seeker, Devoted, and Champion price descriptions are ratified and paired.
4. Tier-up, lapse, Champion entry, and commitment or curse-onset copy are
   ratified.
5. Stigma crossings follow D-15, or curse-access behavior follows D-16.
6. Neglect, exit, and residue are authored and routed.
7. Per-race response handling exists for every non-native race, with explicit
   native-integrated no-row routing where applicable.
8. Hook source is named from `PDV_DaedricRacePrinceMatrix.csv`.
9. `node .\tools\pdv_content_verify.mjs` remains green.
10. CAT-6 target records have readback proof and no slot collision.
11. Runtime, menu, or controlled display proof shows the player-facing text.
12. Expected race build plus Daedric edge build stack snapshot remains legible
    and capped.

## Next Work Queue

1. Finish P2 book runtime proof for all filled families that currently fail.
2. Fill the manual evidence ledger without upgrading any race to pass until
   all rubric slots are proved.
3. Run `PDV_DaedricControlledProof_Runbook.md` for the all-Prince Daedric
   packet, including both MCM and QASmoke sender routes plus the generic-silence
   probe, then record the results in `PDV_DaedricRuntimeEvidenceLedger.json`
   before claiming any Prince beta-display ready.
4. Prove the sixteen exact organic live vanilla senders already wired; keep
   generic behavior from becoming a devotion faucet.
5. Re-run this ledger's command set after every source-fill, CAT-6, or Daedric
   promotion tranche.
