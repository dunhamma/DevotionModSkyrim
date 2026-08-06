# ARR 2.5 Exhaustive Content Sweep -- Codex Handoff

Date: 2026-08-06
Branch: `codex/arr25-content-sweep`
Author: Claude session (Opus 5). Owner-approved plan folded in below.
Status: **The exhaustive QUST-plus-selected-signal sweep, T13-T17 authoring, existing-matrix normalization, safe non-quest renewables, and cumulative machine/package gates are complete. The test archive is built. ARR 2.5 runtime, player-surface, semantic, and support proof remain open.**

---

## 1. TL;DR

Devotion's quest-reaction matrix is essentially 100% vanilla. Third-party Authoria
content reaches the game through two side channels carrying ~120 rows total. The
owner asked for an exhaustive sweep of Authoria (ARR) 2.5 to find every taggable
piece of content we have missed, then to apply the matrix across every race and
deity.

What landed this session:

- **Phase 0 is done.** The stranded tranche-merge `--check` gate is on the branch.
- **Wave 1 is complete** -- the recovered inventory contains 1,220 retained rows
  covering **657 of 657** in-scope mods. The literal `placeholder` scratch row was
  excluded; scope equality, natural-record uniqueness, and triage vocabulary were
  rechecked during reconciliation.
- **The API 529 recovery is complete for this wave.** The surviving LOTD and Vanilla
  Expansions shards were recovered and merged; representative `NO-ROWS` results from
  the two post-write-529 shards were re-read directly from absolute ARR plugin paths.
- **The former 328-mod QUST scope gap is closed.** All 466 queued plugin paths were
  read directly in 48 deterministic checkpoints. Every declared QUST count has a
  matching per-record evidence row; all direct evidence and plugin rollups have a
  primary verdict, with no unresolved read failure or unreviewed checkpoint row.
- **The reconciled inventory now contains 20,342 rows across 1,284 distinct mods.**
  The QUST interface remains exact equality against Wave 1's 657 mods plus the 328
  previously uncovered mods. The selected non-quest pass directly read all 1,070
  plugin paths, reduced 23,902 reviewed occurrences to 18,791 defining natural
  records, and retained 123 candidates while recording 18,668 explicit rejections.
- **The selected non-quest universe is closed:** 614 mods / 1,070 plugin paths in
  107 complete batches, zero read failures, zero unresolved primary reviews, and
  exact natural-record equality. The 332 older free-form candidate rows now have a
  checked-in canonical review ledger; three classify-only/out-of-roster concepts
  deliberately have no current runtime candidate. Reachability reports no malformed
  or unknown canonical names and no pending legacy review.
- **T13 is machine-complete:** nine data-only channels contain 95 cells across
  14 outcome keys, the 116-candidate cross-generation slate was primary-reviewed,
  paired-equity has zero unexplained delta, and the 19-channel FOMOD directory
  passes deterministic structure/collision/hash validation. All 14 tester cases
  remain OPEN; this is an experimental test candidate, not supported content.
- **T14 is machine-complete:** five data-only channels contain 78 cells across
  15 outcome keys / 12 watched quests. The initial 87-candidate plus one-conflict
  cross-generation pass was primary-adjudicated to 46 kept suggestions and 22
  explicit final rejections after three over-broad act aliases were removed.
  Paired-equity adds zero unexplained open gaps (116 open / 88 waived composite),
  and the cumulative FOMOD now carries 24 channels. All 15 T14 tester cases remain
  OPEN; the Largashbur marriage must be traversed organically.
- **T15 is machine-complete:** six data-only channels contain 58 cells across
  14 outcome keys / 13 watched quests. The full final cross-generation slate
  contains 68 reviewed rejections and zero conflicts. Paired-equity adds zero
  unexplained open gaps (116 open / 99 waived composite across 2,361 cells),
  and the cumulative FOMOD now carries 30 channels. All 14 T15 tester cases
  remain OPEN; the Paarthurnax persuasion route must be traversed organically.
- **Existing-matrix multi-tag normalization is machine-complete:** 15 core
  outcome keys now carry one truthful canonical act set across every existing
  deity cell. The bounded 45-candidate/three-conflict cross-generation slate
  was primary-reviewed with zero new cells retained; this consistency pass did
  not farm coverage. Core remains 2,130 cells / 231 runtime keys. Correcting
  DB06's stray chaos gloss removes two false paired-equity gaps, taking the
  T13-T15 composite from 116 to 114 open gaps without adding a cell.
- **T16 is machine-complete:** TG Alternative Endings and Save the Icerunner add
  58 cells across seven outcome keys in two channels. TG09's three physical
  stage-200 endings are resolved through a soft-dependency script seam: vanilla
  keeps 200, freeing the Nightingales maps to 201, and keeping the Skeleton Key
  maps to 202. The alternate routes also suppress TG09's otherwise false +10
  Nocturnal commitment pulse. Paired-equity adds zero unexplained gaps (114 open /
  106 waived across 2,419 cells), and the cumulative FOMOD carries 32 channels.
  All seven tester cases remain OPEN, so both options are experimental.
- **T17 is machine-complete:** Legacy of the Dragonborn and Bruma add two new
  data-only channels, while Wyrmstooth's existing T13 channel gains its remaining
  direct resolving outcomes. T17 contributes 132 cells across 22 keys / 12
  watched quests. The 80-candidate/two-conflict cross-generation slate was
  primary-reviewed to 25 keeps and 55 final rejections. Paired-equity adds zero
  unexplained gaps (114 open / 116 waived across 2,551 cells), and the cumulative
  FOMOD now carries 34 channels. All 22 tester cases remain OPEN.
- **The safe non-quest tranche is machine-complete:** 17 ARR foods are classified
  through exact-name KID rules; Breton Hidden Art now has its second direct
  renewable while preserving Mara; AFDI observes 30 successful-destruction
  globals through a 15-second optional poll with existing-save baseline and
  once-ever persistence; the existing bard anti-farm lane was verified; and the
  stale QASmoke shrine swap was replaced by the read-back 11-ACTI prayer package.
  Hunting remains explicitly deferred because the truthful seam requires a
  third-party script event. All non-quest runtime cases remain OPEN.
- **The cumulative test archive is machine-complete:** 36 FOMOD nodes / 34
  individual content options / 34 channels / 92 files. Combined Authoria,
  all-individual, and representative-subset simulations pass. Archive membership
  is exactly 92 entries with no missing/extra files; SHA-256 is
  `7E93CC59F78F443E8EFA46EAC3D5C052E56EC80C8D30388F08854AD1B4B3E132`.

The single most valuable discovery: **follower personal questlines**, which are the
only content in 3739 plugins that can reach Devotion's thin-roster races.

---

## 2. Where things stand

### Done

| Item | Evidence |
|---|---|
| Cherry-picked the stranded `--check` gate | commit `639b7ab8` (cherry-pick of `9591d7dd`) |
| Tranche-merge gate green | `node tools/pdv_quest_tranche_merge.mjs --check` -> **PASS, exit 0** |
| T12 canonical merge repaired | commit `e5c6999`; resolved FormID duplicate gate; 2,130 cells; matrix self-test PASS |
| Consolidated content inventory (machine inventory only) | `references/vanilla-gameplay/compatibility/PDV_ARR25_ContentInventory_2026-08-06.csv` -- 20,342 rows / 1,284 mods; exact QUST equality plus 18,791 deduplicated selected-signal records; not tester support proof |
| Exhaustive QUST worklist frozen | `PDV_ARR25_DiscoveryWorklist_2026-08-06.csv` + batch manifest -- 328 mods / 466 plugin paths in 8-10 path batches |
| Direct-read QUST checkpoints | 48/48 batches complete, 466/466 plugin paths read, zero unresolved errors, zero unreviewed evidence rows; count-equality gate passes |
| Non-QUST signature universe frozen | 1,356 mods / 3,001 paths scanned; 614 mods / 1,070 paths admitted to direct signal review; 1,931 paths explicitly outside selected signatures; zero scan read errors |
| Non-quest signal checkpoints | 107/107 complete batches, 1,070/1,070 plugin paths, 23,902 occurrences -> 18,791 defining records, 123 retained, zero unresolved reads/reviews |
| T13 authoring and package directory | 95 cells / 14 keys / 9 channels; 19-option FOMOD; `PDV_ARR25_T13_Adjudication.md`; package validation PASS; runtime/support OPEN |
| T14 thin-roster authoring and package directory | 78 cells / 15 keys / 5 channels; cumulative 24-channel FOMOD; `PDV_ARR25_T14_Adjudication.md`; runtime/support OPEN |
| T15 vanilla quest-expansion authoring and package directory | 58 cells / 14 keys / 6 channels; cumulative 30-channel FOMOD; `PDV_ARR25_T15_Adjudication.md`; runtime/support OPEN |
| Existing-matrix multi-tag normalization | 15 outcome keys normalized; 45 candidates + 3 conflicts primary-reviewed; 0 new cells; paired-equity 114 open / 99 waived (delta -2); `PDV_ARR25_ExistingMatrixMultiTag_Adjudication.md` |
| T16 alternate-route authoring and package directory | 58 cells / 7 keys / 2 channels; cumulative 32-channel FOMOD; soft-dependency TG09 201/202 resolver and false-commitment suppression; `PDV_ARR25_T16_Adjudication.md`; runtime/support OPEN |
| T17 large-content authoring and package directory | 132 new cells / 22 keys / 12 watched quests across LOTD, Bruma, and the expanded Wyrmstooth channel; cumulative 34-channel FOMOD; `PDV_ARR25_T17_Adjudication.md`; runtime/support OPEN |
| Non-quest renewable closeout | 17 food records applied; Hidden Art 2/2; 30 AFDI globals; bard contract retained; 11 correct prayer swaps; 108 records explicitly deferred; `PDV_ARR25_NonQuest_Adjudication.md`; runtime/support OPEN |
| Cumulative ARR 2.5 test archive | `dist/PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip`; 92 entries; exact tree/archive validation PASS; support remains closed |

Current gate output is **2,130 cells / 154 EditorIDs / 45 deities**; compile output is
231 runtime keys / 154 watched quests. The former 2,131 result contained one duplicate
runtime cell under two EditorID aliases. Any doc quoting 1,978 / 1,982 / 2,131 as the
current count is stale.

### Deliberately NOT done (owner's or Codex's call, not mine)

- **The stale 1978/172 counts** in `AGENTS.md:216`, `PDV_MOD_SETUP.md:565`,
  `PDV_Architecture_v3.md:139/185`. `Claude.md` rule 3 puts `AGENTS.md` off limits,
  and the numbers move again with every tranche. Use fresh gate output.

### Recovery provenance -- Wave 1 complete

Four of six reader subagents terminated on `API Error: 529 Overloaded`. Two of them
had already written complete output; the two surviving late shards were subsequently
recovered from the scratchpad and reconciled into the durable inventory.

| Slice | Work list | Result |
|---|---|---|
| `inv_followers.csv` | 71 plugins | **COMPLETE** 71/71, 143 rows |
| `inv_namedmods.csv` | 61 plugins | **COMPLETE**, 190 rows |
| `inv_lines.csv` | 57 plugins | **COMPLETE** 57/57, 69 rows (529 fired after the write) |
| `inv_systems.csv` | 58 plugins | **COMPLETE** 58/58, 96 rows (529 fired after the write) |
| `inv_lotd.csv` | 92 plugins | **RECOVERED** -- merged into the Wave 1 inventory |
| `inv_vanillaexp.csv` | 50 plugins | **RECOVERED** -- merged into the Wave 1 inventory |

Scratchpad (slices + work lists + the derived maps):
`C:\Users\Admin\AppData\Local\Temp\claude\C--Users-Admin-Documents-Devotion-Mod-Project\2f6eb23b-9aa6-4e14-a04e-513af87204df\scratchpad\`

The scratchpad is recovery provenance, not a remaining execution dependency. The
consolidated inventory is the durable result, and the minimal source maps needed to
reproduce the remaining discovery contract are preserved under
`references/vanilla-gameplay/compatibility/arr25-discovery-source/` with hashes in
`PDV_ARR25_DiscoveryBatches_2026-08-06.json`.

---

## 3. The plan (folded in)

Full version: `C:\Users\Admin\.claude\plans\while-our-khajiit-work-floofy-unicorn.md`.
Condensed here so this handoff stands alone.

### Two architectural facts that shape everything

**1. New coverage needs zero Papyrus and zero ESP.**
`PDV_PlayerEvents.RegisterQuestReactionChannelFolder()`
(`live-source/Scripts/Source/PDV_PlayerEvents.psc:1588`) discovers channels
dynamically via `JsonUtil.JsonInFolder`. Any JSON dropped in
`SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/` registers itself as a matrix
file. The July per-mod FOMOD already proves the pattern with 10 channels.

Corollary: **keep Authoria work in channels, not core.** Channel rows carry their own
`formid` column, need no `MANUAL_QUEST_FORMIDS` registration, never enter `Full.csv`,
and therefore trip neither `pdv_matrix_runtime_preflight.mjs:22-23` (hardcoded watched
counts) nor `PDV_MainQuestFullCoverageContract.json` (asserts whole-matrix cell count).
Promote to core only for vanilla-guaranteed content, and bump both contracts in the
same commit when you do.

**2. The race dimension is TWO gates, not one.**
A matrix cell names a deity, never a race. At runtime it passes through:

- **A hard reachability gate** -- `IsDashboardDeityInOriginRoster`
  (`PDV__ManagerQuest.psc:4127`). Each race reaches a fixed roster: Nord 13,
  Breton 11, Imperial 8, Altmer 8, Khajiit 7, Bosmer 5, Dunmer 3, Redguard 3,
  Argonian 2, **Orc 1**. A cell outside the player's roster is **dropped entirely**,
  not dampened. Daedric Princes bypass this gate and reach everyone.
- **A stance multiplier** -- `stance.<Race>.<Deity>`: NATIVE 1.0, FOREIGN/TOLERATED
  0.4, TABOO/HOSTILE -> stigma, CURSE -> curse layer.

So "apply the matrix to every race" is NOT satisfied by authoring more rows for
popular deities. For a thin-roster race, value only lands if the row names a deity
that race can reach, or a Prince. Existing evidence of the trap: Trinimac carries an
explicit Orc stance in `PDV_StanceMatrix.csv` but is absent from the Orc origin
roster, so all 36 Trinimac cells are dead for Orcs.

### Phase 1 -- exhaustive discovery (complete 2026-08-06)

Source of truth: `D:\Wabbajack\modlists\ARR 2.5`, profile `KoK R11`.

**Do not switch houseCARL's instance.** It is on `D:\Wabbajack\modlists\Anvil` /
profile `Devotion Dev`, which live Khajiit work depends on. `housecarl_read_plugin_file`
takes absolute paths and reads out-of-load-order files fine. Its
`declared master(s) NOT installed` warning is a false alarm -- it resolves masters
against Anvil; they exist in ARR 2.5.

Scope rule: **every enabled mod in a content-bearing bucket gets a row and an explicit
verdict.** `NO-ROWS` with a reason, never omission.

### Phase 2 -- quest-lane tranches

Ordering is by who the rows can reach, not by mod. Two scarcity measures, routinely
conflated:

- **Per-deity target**: >= 20 positive / >= 10 negative signals. Hand-tracked in
  `PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md`; no script recomputes it.
- **Per-path gate** (`tools/pdv_signal_floor_audit.mjs`): 35 race paths + 16 Princes,
  PASS iff `wired_types >= 5` (Princes 4) and `wired_renewable >= 2`. Currently
  50 PASS / 1 UNDER-FLOOR (`breton_hidden_art`, renewable 1/2).

**Quest rows are one-shot: they raise `wired_types`, never `wired_renewable`.** The
one path actually failing cannot be fixed in Phase 2. Do not promise otherwise.

Tranche order:

| # | Tranche | Reaches |
|---|---|---|
| T13 | July high-confidence backlog (`PDV_ARR_ModPatchlist_2026-07-16.md:79-96`) | Namira, Sithis, Hermaeus Mora, Hircine -- Princes, so all 10 races |
| T14 | **Thin-roster races: follower questlines + Elsweyr** | Orc, Argonian, Bosmer, Khajiit |
| T15 | Vanilla expansions (CoW QE, Caught Red Handed, Infiltration, Nilheim ...) | Magnus, Julianos, Zenithar, Dibella |
| T16 | nimwraith alternate routes | Nocturnal, Rajhin, Baan Dar, Clavicus Vile, Stendarr, Stuhn, and truthful paired reactions |
| T17 | New lands + LOTD | Auri-El, Xarxes, Trinimac, Peryite, Sheogorath |

T14 is promoted ahead of the vanilla expansions because it is the only tranche that
moves the needle for Orc, Argonian and Bosmer players.

Per tranche: author `references/authoring/patches/PDV_QRM_<Mod>.csv` (the standard 10
columns plus `formid` as `PLUGIN:HEX`) -> compile with `--matrix`/`--output --check`
-> drop the JSON in `Channels/` -> gates.

### Settled authoring rules -- do not relitigate

- **Calibration is LOCKED** (`AGENTS.md:1623`): no per-quest cap on how many deities
  react. Pacing is tuned via milestone VALUE.
- Vocabulary: valence `{+,-}`, intensity `{C,S,m}`, magnitude `{milestone, small}`.
  **`echo` is retired.**
- milestone iff the matched tag is `C` for that deity AND the stage is terminal.
  Values: milestone 18/12/8, small 6/4/2, x stance 1.0/0.4.
- One quest fire = one toast + one Book of Days beat, however many gods it feeds.
- Merge dedupes on `(editor_id, outcome_stage, deity)`; conflicting valences abort
  with exit 1.
- ARR quest mods frequently ship NO journal text (`Stages[i].LogEntries[0].Entry`
  absent). Where only `Objectives[i].DisplayText` exists, those are *directives* not
  outcomes, so the row scores on the **next stage after** the act's objective and
  carries `RUNTIME-VERIFY` in its citation. Tranche 12's rows in
  `PDV_QuestReactionMatrix_ARR.csv` are the reference example.

### Phase 3 -- deity breadth

Do not hand-author the fan-out. `tools/pdv_quest_cross_gen.mjs` crosses every tagged
outcome against every Part B profile and emits a review slate. Then re-measure with
`pdv_signal_floor_audit.mjs` and `pdv_paired_equity_audit.mjs`.

Caution: the refreshed post-T12 core baseline is **116 open cluster gaps / 71
waived**, not the stale 28/72 report committed before the T12 expansion. T13's
in-memory composite is 116 open / 81 waived; T13+T14 is 116 open / 88 waived after
primary review. Both have zero unexplained open-gap delta. The audit supports
repeated `--append-matrix` plus `--no-write` for channel tranche comparisons.

### Phase 4 -- non-quest lane

The only lane that can move `wired_renewable`. Faucet rows use the channel JSON's
existing `faucet.<Deity>.<act_tag>.*` schema. Existing Story Manager hooks
(`PDV__SM_ChangeLocation`, `_AddToPlayer`, `_CraftItem`, `_KillActor`,
`_IncreaseSkill`, `_PickLock`, `_NewVoicePower`, `_Trespass`) already fire on modded
content -- the work is curated list membership, not new Papyrus.

Repeatable acts belong in `PDV_DeityLikesDislikes.csv`, NOT the matrix. That path
requires the regen chain plus a `LIKES_DISLIKES_VERSION` bump
(`PDV__ManagerQuest.psc:629`, currently 20) or the rows are inert on existing saves.
**Do not** re-pin `EXPECTED_LIKES_DISLIKES_VERSION` in `pdv_verify.mjs` -- that
constant was deliberately removed 2026-08-03; older handoffs saying otherwise are
stale.

---

## 4. Codex work items

### C-1 (complete 2026-08-06) -- Recover and reconcile the two missing inventory slices

`inv_lotd.csv` and `inv_vanillaexp.csv` were recovered from the session scratchpad
and merged with the existing 900-row artifact. The literal `placeholder` row was
discarded. The resulting 1,220 rows cover all 657 Wave 1 scope mods; no scoped mod
is missing and no out-of-scope mod was introduced. The later authoring pass must still
record the (a)/(b)/(c) Quest Expansion distinction before deciding channel versus core.

### C-2 (complete 2026-08-06) -- Re-verify the post-write-529 inventory shards

Direct `housecarl_read_plugin_file` spot checks were performed without switching from
the Anvil instance: an override-only patch (`AP - USSEP patch.esp`) contains only the
vanilla `MQ101` QUST override; `Civil War Lines Expansion.esp` defines a dialogue
holder with empty objectives/stages; and `C.O.I.N.esp` defines three no-journal system
quests alongside its coin-record surface. The asset-only `Alternate Perspective - No
Start Room Markers` folder was also confirmed to contain only scripts and `meta.ini`,
with no plugin file. These checks support the recorded `NO-ROWS` strata; they are not
runtime or semantic proof for a later authoring tranche.

### C-3 (complete 2026-08-06) -- Close the QUST scope gap

The in-scope bucket set was drawn too narrowly. Measured totals:

- **583 mods across the modlist carry QUST records.**
- **255 were in scope** and read this session.
- **328 were outside Wave 1.** The frozen queue covered them all.

The direct-read contract is now frozen in
`PDV_ARR25_DiscoveryWorklist_2026-08-06.csv`: Wave A 97 mods / 156 paths, Wave B
23 / 26, and Wave C 208 / 284. All 48 batches are now complete: 466/466 absolute
plugin paths direct-read, every declared QUST count reconciled to per-record evidence,
zero unresolved errors, and zero unreviewed checkpoint rows. The consolidated
inventory is 1,551 rows / 985 distinct mods, with an empty set difference against the
657 Wave 1 mods plus the 328-mod gap queue.

Excluded buckets holding real content, by QUST-bearing mod count:

| Separator | Mods | Why it matters |
|---|---:|---|
| **Base Game & Creation Club Files** | **55** | **Contains CC The Cause, Ghosts of the Tribunal, Divine Crusader, Saints & Seducers, Umbra, Bittercup, Goblins, Forgotten Seasons, Shadowfoot Sanctum, Tundra Homestead. Four of these are named T13 high-confidence targets.** |
| Gameplay - Magic Mods | 11 | Magnus/Julianos lane |
| Gameplay - Combat | 9 | |
| Gameplay - Frameworks | 8 | |
| Gameplay - Perks & Leveling | 6 | |
| Gameplay - Vampire and Werewolf Overhaul | 5 | **Sacrilege, Manbeast -- curse-state detection, TODO-9** |
| City Stuff - Solitude / Whiterun / Riften / Villages / Misc Worldspace | 21 | village and city quest content |
| Gameplay - Missives | 4 | radiant quest boards, repeatable |
| Gameplay - Ostim Standalone | 24 | probably NO-ROWS, still needs a verdict |
| Gameplay - Wet and Cold, Essential-*, Interface-*, Animations-*, Visuals-* | ~185 | mostly NO-ROWS, cheap to rule |

Shadow of Skyrim, Creation Club, vampire/werewolf, magic, missives, city/worldspace,
OStim, framework, interface, visual, and low-yield buckets all now carry an explicit
primary verdict. This closes factual QUST discovery only; approved `DEFER` rows still
belong to their T13-T17 or renewable authoring tranche.

### C-4 (complete 2026-08-06) -- Scope-equality reconciliation

The 657 distinct `mod` values in the consolidated inventory equal the 657 entries in
the preserved `arr25-discovery-source/wave1_scope.tsv`; the Wave 1 set differences are
empty. The appended 328-mod queue is also an exact subset of the consolidated inventory,
so the combined 985-mod discovery interface has no missing mod verdict.

### C-4b (complete 2026-08-06) -- Selected non-quest closure and canonical interface

All 107 non-quest checkpoints are complete. The closure gate validates checkpoint
manifests, direct-read status, and primary verdicts, then resolves patch/update
occurrences to `record-signature|defining-plugin|local-FormID`. The result is 23,902
occurrences, 18,791 unique natural records, 5,111 duplicate occurrences removed,
123 retained candidates, and 18,668 explicit `NO-ROWS` records. There are no
unresolved reads or reviewer states.

The legacy candidate migration is independently frozen in
`PDV_ARR25_LegacyCandidateCanonicalReview_2026-08-06.csv`: 332 rows / 145 distinct
phrases reviewed. Current-roster aliases are explicit (for example Azurah -> Azura,
S'rendarr -> Stendarr, Mauloch -> Malacath); concepts outside the current runtime
roster remain in the evidence prose but are not invented as reachable deities.
Jyggalag remains classify-only. The report-only reachability audit passes with
20,342 rows, 458 rows carrying canonical candidates, zero pending legacy reviews,
zero unknown names, and zero warnings.

### C-5 (P1) -- Re-tagging pass over the existing matrix

A finding that needs no new content. Coverage is driven by how many act_tags an
outcome carries, and **94% of existing rows carry exactly one tag** (2005 of 2131;
only 126 carry two or more).

Tag matching is exact plus one namespace wildcard (`serve_a_daedra:*` matches
`serve_a_daedra:molagbal`); broad-base matching was considered and explicitly
rejected as too broad (`tools/pdv_quest_cross_gen.mjs:123`). There is **no tag
hierarchy** -- `kill_honorable_combat` is a sibling of `the_hunt`, not a child of any
`combat` parent. And there is **zero tag matching at runtime**: the engine reads an
authored `deitiesCsv` per cell (`PDV__ManagerQuest.psc:1764`); tags ride along only
to build reason strings.

Worked example of the cost. A stage where the player wins a one-on-one challenge and
kills a stronger foe truthfully carries `kill_honorable_combat`, `honorable_duel` and
`prove_by_struggle`. Cross-gen pools tags per `editor_id|stage` and tests each deity
independently, keeping that deity's strongest hit. Fourteen deities match; five reach
C, and four of those five get there from a tag other than the one Shor uses:

| Deity | Best from | Intensity |
|---|---|---|
| Shor | `kill_honorable_combat` | C |
| Tsun | `prove_by_struggle` | C |
| HoonDing | `prove_by_struggle` | C |
| Leki | `honorable_duel` | C |
| Boethiah | `prove_by_struggle` | C |

Tag that stage with only `kill_honorable_combat` and Leki drops C->S, Tsun C->S,
HoonDing C->m, while **Boethiah and Baan Dar vanish entirely** -- neither has the tag.

So the Phase 2 authoring rule is: **tag each outcome with every tag that is TRUE of
what the player did, not just the one that motivated the row.** The honest limit is
truth -- the ledger's two standing drop reasons are "theology stretch" and
"double-credit", so widening tags to farm coverage is what gets rows dropped.

A re-tagging pass over the existing 2,130 rows would widen deity coverage with no new
content. Worth its own tranche.

### C-6 -- Resolved controls and remaining source check

- `tools/pdv_arr25_inventory_reachability_audit.mjs` is the report-only roster gate.
  Canonical candidates now come from explicit primary review rather than parsing
  legacy prose as authority. The gate parses the live roster function and locks
  Altmer-reachable / Orc-pressure-only Trinimac.
- Packaging is settled: Authoria-guaranteed targets enter the combined lane, while
  arbitrary-load-order support stays per-mod so missing masters cannot block startup.
- Whether `live-source/Scripts/Source/` is in sync with
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` before Phase 4 touches
  any `.psc`. Audits read the repo mirror; the compiler reads MO2.

---

## 5. Findings worth acting on

### Follower questlines -- the best find, and entirely absent from this repo

Nine follower mods carry QUST records. None appear anywhere in the repo today. These
are the only content that reaches the thin-roster races.

**Thogra gra-Mugur** (`DK_Thogra.esp`) -- 16 QUST defined, 3 player-facing.
**Orc reaches exactly one deity (Malacath)**, so this is close to the only leverage
that exists for an Orc player.
- `167FDE` *Thogra's Revenge* -- 24 stages. THE Orc quest.
- `1F0E0E` *Marry Thogra - Temple of the Divines* (Mara) vs `232B5A` *Marry Thogra -
  Largashbur* (Malacath) -- **a genuine theological fork**: Divines rite against
  stronghold rite, for the race with the narrowest roster in the game.

**Xelzaz** (`BPUFXelzazFollower.esp`) -- 96 QUST defined, 10 player-facing. Argonian
reaches only The Hist and Sithis; Xelzaz also opens a Dunmer Telvanni angle.
- `79F4DA` *An Unwanted Scion* -- 17 stages / 9 objectives, explicit moral fork.
  Highest-value Argonian row available.
- `E408E2` *Lost and Found* -- paired with MISC `BEFE1E BPUFXelzazHistLeaf` and a BOOK.
- `C6E975` *Of Crimson* (16 stages), `40D29D` *Quid Pro Quo* (Telvanni bargain framing,
  Boethiah/Mephala), `F47F25` *The Good Stuff* (34 stages, largest),
  `547931` *Field Research: Dragon Dissection* (a desecration angle on Akatosh).

**Song of the Green / Auri** (`018Auri.esp`) -- 19 QUST defined, 1 player-facing.
- `03E4B1` *Song of the Green* -- the Bosmer pilgrimage quest, 9 stages / 7 objectives.
  Y'ffre sits at 3 quests, joint-thinnest non-Prince deity in the ledger.

Others carrying quests: Deadlands Expanded (Mehrunes Dagon), Kaidan 2, Lucien
(Julianos/Xarxes), Remiel (Julianos/Magnus), Heart of Ice Astrid (Sithis), Ashe,
Yoana.

Verified negatives, recorded so they are not re-checked: **Val Serano** has no QUST
despite "Quest Adventure" in the title; **Inigo** and **Fluffy Thistlefoot** ship no
plugin in their own folder (Inigo's ESP lives in `Inigo - cleaned esp File`), so
resolve by plugin, never by mod folder.

### Aetherium Forge Destroys Items (AFDI) -- a ready-made Prince signal

The strongest non-quest find. The mod lets the player **destroy Daedric artifacts**
and ships exactly the records needed to detect it:

- `000801` ACTI -- the activator that fires the destruction.
- `000800` FLST -- master list of every destroyable Daedric artifact.
- `000D5C`-`000E8B` KYWD -- **per-Prince ownership tags** on each artifact, including
  a benign-Azura variant (`000D60`) that should read differently from a malign one.
- `0001FC`, `000D43`, `000D79` QUST -- script shims
  (`ANDR_AFDI_DestroyQuestScript`).

PDV already has the matching tag namespace: `destroy_reject_daedra:<prince>` is in use
in the ARR channel today. This maps onto starving Princes AND reaches every race,
since Princes bypass the origin-roster gate.

### Other non-quest candidates

- **Hunter Loot / hunting internals were not promoted as faucets.** Direct record
  evidence showed the tempting skin/butcher spells are constant-effect self
  monitoring abilities rather than player-cast actions. Keyword and internal-system
  records remain useful implementation evidence, but are explicit `NO-ROWS` inputs
  until an actual routed action surface is proven.
- **Become a Bard** / **Skyrim's Got Talent** -- confirmed present with the records
  the July spec (TODO-4) already designed against.
- **Why I Came to Skyrim - Origin Stories** (`The Book of Origins.esp`) -- the player
  picks a backstory at character creation, including arriving as **a pilgrim to a
  Shrine** (`00009A`) and **a pilgrim to High Hrothgar / the Seven Thousand Steps**
  (`00009F`). A declared religious origin; worth considering as starting-piety or
  stance seed rather than a quest row.
- **Alternate Perspective** (63 defined quests) and **Adventurer's Start** (38) --
  flagged DEFER, not NO-ROWS. These own game start, and PDV's startup flow must be
  smoke-tested against them (existing TODO-10).

---

## 6. Corrections made this session -- read before trusting older notes

1. **The mod->separator map was inverted.** In `modlist.txt` a separator sits *below*
   the group it labels (`VIGILANT SE` line 3312, its separator line 3313). The first
   map assigned each mod to the separator *above* it, shifting every label by one
   group. It produced plausible output and wrong bucket contents were reported from it
   before an implausible count exposed it. **Any derived map needs an anchor check** --
   verify known mods land in expected buckets before trusting counts.
   Corrected figures: Quests and Newlands is **404 mods**; 583 mods carry QUST.

2. **A name regex silently dropped content.** Filtering by title excluded
   *The Whispering Door - Quest Expansion* because it contains "Door", which had been
   excluded to strip mesh mods. Regex may **order** the work; it may never **bound** it.

3. **`Authoria` is not a mod.** It is a Wabbajack modlist bundling ~250 content mods;
   its own 587 plugins are patch/merge output defining almost nothing. The taggable
   universe is the bundled mods. `housecarl_cross_plugin_query` cannot reach them --
   they are not in the active load order, so absolute-path `read_plugin_file` is the
   only route without switching instances.

4. **Cell counts moved mid-session** from 1982 to 2131 when Codex merged Tranche 12.
   Do not quote a cell count from any doc without re-running the gate.

---

## 7. Verification

Per tranche. **Branch on exit code, never on grepped output.**

```
node tools/pdv_quest_tranche_merge.mjs --check
node tools/pdv_quest_matrix_compile.mjs --check --json
node tools/pdv_quest_matrix_compile.mjs --papyrusutil-check --json
node tools/pdv_quest_matrix_selftest.mjs
node tools/pdv_arr25_nonquest_check.mjs
node tools/pdv_arr25_t16_route_check.mjs --pex-root generated/arr25-nonquest-pex
node tools/pdv_quest_patch_fomod_validate.mjs --archive dist/PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip
```

Then: `pdv_signal_floor_audit.mjs`, `pdv_paired_equity_audit.mjs`,
`pdv_deity_signal_remap_adversary_check.mjs`,
`pdv_verify.mjs --strict-curated-signal-dispatch --json`.

**Proof boundary.** Everything above is machine verification only. Every
objective-derived row ships `RUNTIME-VERIFY` in its citation and stays that way until
observed in game. The July per-mod patches are still machine-verified only (TODO-7).
Per `pdv-proof-boundary`, do not describe any of this as tested, supported, or
beta-ready on green gates alone.

ARR runtime preflight is intentionally not part of discovery/package closure.
Run it only after installing and enabling the combined candidate on ARR 2.5
`KoK R11`. Then work through the six bundled T13-T17/non-quest ledgers and return
the route marker, piety readback, exactly-one-toast, exactly-one-Book-beat,
save/load, organic-semantics, and failure fields. Only equivalent passed cases may
move an individual option or the combined lane toward support.
