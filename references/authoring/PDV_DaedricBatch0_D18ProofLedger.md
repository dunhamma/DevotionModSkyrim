# PDV Daedric Batch 0 D-18 Proof Ledger

**Created:** 2026-06-04
**Status:** Static D-18 draft proof complete; CAT-6/readback/runtime proof still blocked
**Owner:** Companion to `PDV_Daedric_DecisionPacket_CAT4.md`,
`PDV_AllRaceDaedricBetaReadinessLedger.md`, `PDV_DeityCoverageMatrix.json`,
`race-sheets/PDV_DaedricContent_Manifest.md`, and
`references/phase4/PDV_DaedricRacePrinceMatrix.csv`

## Purpose

This ledger proves the first Daedric template-variation batch at the repo
content-contract level before broad Prince promotion. It does not write ESP
records, does not promote CAT-6 strings, and does not claim runtime or display
proof.

Batch 0 is the D-17 template proof set:

- Azura / Azurah - standard path with native-integrated Dunmer and Khajiit
  override.
- Vaermina - pure standard external pact with no native override.
- Meridia - tolerated weight class.
- Molag Bal - curse-access reduced-row pattern.

## Evidence Baseline

```text
Content source:
race-sheets/PDV_DaedricContent_Manifest.md

Matrix source:
references/phase4/PDV_DaedricRacePrinceMatrix.csv

Decision source:
references/authoring/PDV_Daedric_DecisionPacket_CAT4.md

Verifier:
node .\tools\pdv_content_verify.mjs
Latest result during this packet: FAIL=0, WARN=0, PASS=1079, INFO=4

Strict Phase 20 gate:
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
Latest result during the parent readiness refresh: PASS=2699, WARN=1, INFO=29
Known warning: unnamed CK-authored INFO records
```

## Batch 0 Verdict

Static D-18 draft proof is complete for Batch 0. Every Batch 0 Prince now has:

- tone profile;
- Seeker, Devoted, and Champion boon descriptions;
- Seeker, Devoted, and Champion price descriptions;
- tier-up, lapse, Champion entry, and commitment or curse-access commitment
  copy;
- stigma or curse-state visibility rows;
- neglect and exit copy;
- per-race response coverage or explicit native-integrated routing;
- named matrix hook source;
- firing-density sanity paragraph.

The remaining blocker is the next gate: CAT-6 target selection, target-record
ownership, readback coverage, runtime or menu/display proof, and stack/Survey
legibility.

## Per-Prince Static Proof

| Prince | Template shape | Matrix hook | Static D-18 status | Remaining blocker |
|---|---|---|---|---|
| Azura / Azurah | Standard + native override | The Black Star > Azura shrine > artifact outcome | Static draft coverage complete; Dunmer and Khajiit route to race manifest, other eight races have response rows | Select non-voiced CAT-6 targets; prove record readback and display; prove native override does not create duplicate Daedric response |
| Vaermina | Standard pure | Waking Nightmare > Skull of Corruption > nightmare/sleep corruption | Static draft coverage complete; all ten races have response rows | Keep hooks quest/threshold anchored so ordinary sleep is not a source faucet; prove CAT-6/readback/display |
| Meridia | Tolerated | The Break of Dawn > Dawnbreaker > undead/necromancer cleansing | Static draft coverage complete; all ten races have response rows; tolerated-class firing-density paragraph added | Prove tolerated stigma behavior and prevent generic undead farming before any promotion |
| Molag Bal | Curse-access | The House of Horrors > vampirism > Mace of Molag Bal | Static draft coverage complete; all ten races have response rows; stigma rows clarified as curse-state display, not per-act accrual | Prove no double-fire with race `CurseState` rows; prove cure/exit/residue display and stack behavior |

## D-18 Checklist

| D-18 item | Azura | Vaermina | Meridia | Molag Bal | Notes |
|---|---|---|---|---|---|
| Tone profile | Pass | Pass | Pass | Pass | Present in each manifest section |
| Boon descriptions x3 | Pass | Pass | Pass | Pass | Passive SPEL text only |
| Price descriptions x3 | Pass | Pass | Pass | Pass | Paired to boons in manifest |
| Tier-up, lapse, Champion entry | Pass | Pass | Pass | Pass | Message/notification rows present |
| Commitment or curse-onset | Pass | Pass | Pass | Pass | Molag Bal uses curse-access commitment reframe |
| Stigma or curse-state crossings | Pass | Pass | Pass | Pass | Molag Bal rows are display text only and must be curse-state driven |
| Neglect and exit residue | Pass | Pass | Pass | Pass | Exit copy present; runtime residue still unproved |
| Per-race responses | Pass | Pass | Pass | Pass | Azura has eight non-native response rows plus native-integrated routing; other three have ten response rows |
| Matrix hook source | Pass | Pass | Pass | Pass | Hook line present from Daedric matrix |
| Content verifier | Pass | Pass | Pass | Pass | Clean at packet creation |
| Firing-density sanity | Pass | Pass | Pass | Pass | Added for Batch 0 on 2026-06-04 |
| CAT-6 target/readback | Blocked | Blocked | Blocked | Blocked | No ESP records promoted in this packet |
| Runtime or display proof | Blocked | Blocked | Blocked | Blocked | Requires later controlled proof |
| Stack/Survey legibility | Blocked | Blocked | Blocked | Blocked | Requires expected/edge race stack snapshots |

## Promotion Rules

Do not promote a Batch 0 row until the promotion packet names:

- source row and final ratified text;
- target record type and EditorID;
- authoring boundary;
- rollback path;
- verifier/readback assertion;
- runtime, menu, Survey/status, or controlled MessageBox display proof;
- expected race build and Daedric edge stack interaction.

V1 remains non-voiced only. Dialogue, INFO, scene, package, and generated
dialogue graph work stay out of this packet.

## Next Batch 0 Work

1. Pick one Batch 0 Prince for the first Daedric CAT-6 proof. Recommended:
   Meridia, because the tolerated class is lower social-risk and the target
   surface can likely be a passive boon or price description.
2. Name exactly one target record and field before editing.
3. Add verifier/readback coverage for that target.
4. Prove runtime or menu/display text.
5. Only after one Batch 0 CAT-6 row passes, repeat for the other three Batch 0
   Princes before scaling to Batch 1.
