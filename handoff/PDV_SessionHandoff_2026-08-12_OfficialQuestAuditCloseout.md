# Session handoff -- 2026-08-12

Class: ARCHIVE (a record of this session; current status remains in the living authorities)

Session: exhaustive official-content quest audit closeout, owner ambiguity rulings,
tag/profile correction, runtime route authoring, and post-v1.5.0d source sync.

## Where this stands

The official Skyrim, Update, HearthFires, Dawnguard, Dragonborn, Fishing, and
Saints & Seducers QUST audit is complete. The frozen inventory contains 2,367
base-game/DLC occurrences canonicalized to 2,274 records plus 60 Creation Club
records. The checkpoint is 2,334/2,334:

- 377 `APPROVED`
- 1,952 `SILENT`
- 5 `REJECTED`
- zero `UNREVIEWED`, `AMBIGUOUS`, or unsafe mappings

The promoted core contains 4,108 reaction cells across 354 quest EditorIDs,
450 routed quest-stage keys, and 353 watched quests. The 28 outcomes from the
final 18-record ambiguity review generate 184 cells. `RelationshipMarriage` is
the one duplicate-owned parent and remains rowless because
`RelationshipMarriageWedding` owns the ceremony.

The published `v1.5.0d` archive is immutable and does **not** contain this
post-release closeout. Current repository/live source is ready for the next
package only after the open main-quest audit below is resolved.

## Owner decisions now implemented

- `CW03`: s210 `serve_empire_order,civic_service,keep_oath`; s240
  `defy_tyranny_talos,keep_oath`. Long faction chains may repeat meaningful
  commitment tags at evidenced milestones; the daily cap controls repetition.
- HearthFires Bandit/Giant/Wolf/Skeever attacks use `defend_kin_home` at their
  reviewed routes without duplicating ordinary kill reactions.
- Ragnvald s30 uses `slay_undead,prove_by_struggle`.
- Moss Mother Cavern uses s20 `heal_comfort,protect_the_weak` and s100
  `friendship`; Valdr, not the player, owns the burial act.
- The three torture treasure objectives distinguish coercion at s10 from
  unsurrendered treasure theft at s200.
- Riften02, Riften03, Staada, Forgotten Names, A Good Death, An Axe to Find,
  Morwen's Skaal quest, and the marriage duplicate now have final route-safe
  verdicts. Exact mappings live in
  `references/authoring/PDV_CoreQuestAmbiguityResolutions_2026-08-12.md`.

## Corrected tag/profile routing

These corrections are in tagged sources, Part B profiles, Tranche 14, Full.csv,
the compiled runtime JSON, checkpoint/evidence notes, and the focused gate:

- `restore_faction_home:blades` -> Akatosh and Talos approval.
- `restore_faction_home:dark_brotherhood` -> Sithis approval.
- `persecute_religious_worship:talos` -> Talos, Stendarr, Mara, and Stuhn
  disapproval.
- `atonement_restitution` -> Stendarr, Mara, Zenithar, and Z'en approval.
- `restore_cultural_relic` -> Xarxes approval.
- `recover_stolen_divine_relic:nocturnal` -> Nocturnal approval; the generic
  unparameterized form is retired.
- `resist_extortion` -> adds Zenithar and Stuhn.
- `coercion_extortion` -> Molag Bal approves; Stendarr, Zenithar, and Z'en
  disapprove.
- `enthrall_enslave` -> Molag Bal approves; Stendarr and Mara disapprove.
- `FreeformValdDebt` ->
  `settle_anothers_debt,recover_lost_keepsake,civic_service`; the incorrect
  `atonement_restitution` reading is gone.

`tools/lib/pdv_matrix_vocab.mjs` now validates the approved scoped slugs for
the faction-home, religious-persecution, and divine-relic namespaces while
retaining the canonical Prince-slug roster for Prince-owned namespaces.

## Runtime routes and live state

Three adapters are now part of the release payload and live Anvil tree:

- `PDV_QSA_Core_FreeformRiften02.json`
- `PDV_QSA_Core_FreeformRiften03.json`
- `PDV_QSA_Core_Staada.json`

`PDV_PlayerEvents.psc` evaluates stable global/item selectors. The action
router supplies unique-base direct-player-kill routes for Forgotten Names and
A Good Death. `PDV_ActionRouter.pex` and `PDV_PlayerEvents.pex` are newer than
their live sources. The repository and live Anvil quest-matrix JSONs were
explicitly hash-compared after final generation and both were:

`BC0620D7F9DBB1451E093D32884EA010BFD0DE093CF5E34476D51CD64DE0DBDF`

The release payload expects 236 entries, including all three adapters. The
sync helper copies all three.

## Green gates at closeout

The following independently exited 0 after final regeneration:

```powershell
node tools/pdv_qrm_lint.mjs
node tools/pdv_tagged_rows_check.mjs --dir generated/core-rows
node tools/pdv_tagged_rows_check.mjs --self-test
node tools/pdv_joj_tagged_rows_check.mjs
node tools/pdv_core_quest_audit_checkpoint.mjs --validate
node tools/pdv_core_quest_ambiguity_route_check.mjs
node tools/pdv_quest_cross_gen.mjs --self-test
node tools/pdv_quest_cross_promote.mjs --manifest references/authoring/PDV_CoreQuestCrossGenAdjudications.json
node tools/pdv_quest_tranche_merge.mjs --check
node tools/pdv_quest_matrix_compile.mjs --check --papyrusutil-check
node tools/pdv_quest_stage_ownership_check.mjs
node tools/pdv_external_support_inventory.mjs --check
node tools/pdv_external_support_inventory.mjs --coverage
node tools/pdv_matrix_runtime_preflight.mjs --name-resolution-only
node tools/pdv_quest_channel_reconcile.mjs
node tools/pdv_quest_reaction_performance_audit.mjs
node tools/pdv_book_of_days_audit.mjs
node tools/pdv_spid_kid_recognition_audit.mjs
node tools/pdv_player_facing_copy_gate.mjs
git diff --check
```

Notable receipts:

- QRM lint: 95 files / 11,086 rows / zero failures.
- General tagged gate: 10 files / 337 rows / zero failures.
- Focused ambiguity/tag gate: 166 checks.
- Name resolution: 97 files / 78 PatchHub channels / 11,113 cells.
- Core/channel reconciliation: 6,944 cells / zero duplicate natural keys.
- Quest worker audit: 42/42.
- Book of Days: 127/127.
- SPID/KID recognition: 58 rules.

## One known independent red gate

`node tools/pdv_main_quest_full_coverage_audit.mjs` currently exits 1:

- Tranche 11 has 758 rows while the gate expects 951.
- The 45 x 25 contract reports 173 missing deity-stage cells.
- Its compiled-count assertion also predates the current 4,108 / 450 / 353
  matrix shape.

Do not paper over this by changing expected counts. First determine whether the
173 cells are intended contextual exclusions/manual adjudications that the old
gate fails to model, or genuine main-quest breadth lost during retrospective
regeneration. The owner's standing rule is that major stages in the Civil War
and Dragonborn main quest may repeat appropriate tags so late-game characters
retain real piety opportunities.

## Start next session here

1. Read this handoff and
   `references/authoring/PDV_CoreQuestAmbiguityResolutions_2026-08-12.md`.
2. Run `node tools/pdv_main_quest_full_coverage_audit.mjs` and reconcile its
   exact 173-cell report against Tranche 11 and current Part B profiles.
3. Correct the source contract or restore genuinely missing authored cells;
   regenerate Full.csv and runtime JSON, then rerun the complete green gate
   set above.
4. Compile/sync any source changes and verify repository/live byte parity.
5. Build the next all-in-one prerelease (natural label after `d` is `1.5.0e`),
   validate and byte-compare it, commit receipts, tag, and publish only after
   the owner confirms the label.

Do not repeat the 2,334 direct QUST reviews. They are complete and their exact
evidence lives in `generated/core-rows/*.evidence.csv` and the checkpoint.

## Regeneration note

The V05 candidate/conflict/summary files are regenerable and intentionally
ignored rather than committed. Recreate them with:

```powershell
node tools/pdv_quest_cross_gen.mjs `
  --source generated/core-rows/Official_Ambiguity_Resolutions_2026-08-12.tagged.csv `
  --output-prefix V05_CoreAmbiguityResolution `
  --ignore-existing references/authoring/PDV_QuestReactionMatrix_Tranche14_CoreRetrospective.csv,references/authoring/PDV_QuestReactionMatrix_Full.csv
```

Then run the manifest-driven cross-promotion command from the green-gate list.

## Scratch cleanup still owed

Five verified extraction/decompilation scratch directories still existed at
handoff. They were not deleted during closeout because the current request was
handoff/commit/push, not destructive cleanup:

- `C:\Users\Admin\AppData\Local\Temp\pdv-v0202-misc-20260812`
- `D:\Wabbajack\modlists\Anvil\mods\houseCARL - PDV_V0202_DecompileScratch`
- `C:\Users\Admin\AppData\Local\Temp\pdv-v04-cc-ss`
- `C:\Users\Admin\AppData\Local\Temp\pdv-v04-cc-fish`
- `D:\Wabbajack\modlists\Anvil\mods\houseCARL - PDV_V04_CC_DecompileScratch`

Validate each exact path and reparse-point status again before deleting it.
