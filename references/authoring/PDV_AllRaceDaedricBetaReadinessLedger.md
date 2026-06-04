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
Result: FAIL overall
Current 2026-06-04 log pass: Dunmer Azura, Dunmer Boethiah, Imperial public Talos, Nord Old Ways, Nord Hircine/Arkay, Altmer Auri-El, Altmer Magnus, Altmer Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath
Earlier log pass: Breton Hidden Art
Current missing runtime proof: Redguard ancestor spine; fresh Breton Hidden Art only if a same-log full set is desired
```

## Race Runtime And Manual Gap

| Race | Current beta-feel state | P2 book/source runtime state | Manual evidence gap |
|---|---|---|---|
| Altmer | Fail - runtime/manual proof deferred | Auri-El, Magnus, and Xarxes book source manager-log proof passed on 2026-06-04 | Stack snapshot, manual feel, immersive hook proof, asset status |
| Khajiit | Fail - runtime/manual proof deferred | Lunar book source manager-log proof passed on 2026-06-04 | Survey/status did not visibly change during smoke; wrong-origin, generic-source silence, stack snapshot, and feel remain pending |
| Argonian | Fail - runtime/manual proof deferred | Hist book source manager-log proof passed on 2026-06-04 | Wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Orc | Fail - runtime/manual proof deferred | Malacath book source manager-log proof passed on 2026-06-04 | Startup UI overlap was observed and patched in live script; wrong-origin, generic-source silence, Survey/status, stack snapshot, and feel remain pending |
| Redguard | Fail - runtime/manual proof deferred | Filled ancestor-spine book source lacks current manager-log proof | All manual slots pending |
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
- Broad Daedric CAT-6 promotion remains blocked until each Prince has a
  per-Prince D-18/CAT-6 packet, record readback, and runtime or display proof.

| Batch | Princes | Current status | Beta-feel blocker |
|---|---|---|---|
| Pilot already drafted | Boethiah / Boethra | Full pilot draft exists; native Dunmer/Khajiit route to race manifest | Needs per-row CAT-6 promotion/readback/runtime display before beta-feel proof |
| Batch 0 template proof | Azura / Azurah, Vaermina, Meridia, Molag Bal | Static D-18 draft proof complete in `PDV_DaedricBatch0_D18ProofLedger.md`; no ESP writes | Needs CAT-6 target selection, target-record readback, runtime/display proof, and stack/Survey legibility |
| Batch 1 native variants | Mephala / Mafala, Malacath / Mauloch | Draft rows exist | Needs native-integration routing proof and CAT-6/readback packet |
| Batch 2 standard external pacts | Mehrunes Dagon, Sheogorath, Namira / Namiira, Sanguine / Sangiin, Clavicus Vile, Hermaeus Mora, Nocturnal | Draft rows exist | Needs standard-pact D-18 closure; Nocturnal must be Thieves Guild/Nightingale oath surface |
| Batch 3 tolerated/curse-access tail | Peryite, Hircine | Draft rows exist; Hircine has earlier Nord/curse runtime pattern | Needs Peryite tolerated-class proof and Hircine content-surface proof without double-firing curse-state rows |

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
3. Use `PDV_DaedricBatch0_D18ProofLedger.md` to pick the first narrow Batch 0
   CAT-6 target.
4. Promote non-voiced CAT-6 rows only through per-row packets with readback and
   display proof.
5. Re-run this ledger's command set after every source-fill, CAT-6, or Daedric
   promotion tranche.
