# Quest-reaction patch sources live on an unmerged branch

Status: LIVING (open finding)
Found: 2026-08-08, during the JoJ / cross-instance content audit
Severity: **regeneration would silently delete shipped patch content**

---

## The finding

The per-mod quest-reaction patches in `dist/PDV_QuestModPatches_FOMOD/common/` are
**generated** artifacts. Their source rows are per-mod CSVs under
`references/authoring/patches/PDV_QRM_<Mod>.csv`.

Those sources are split across two branches:

| Branch | `references/authoring/patches/*.csv` | rows | distinct editor_ids |
|---|---|---|---|
| `codex/khajiit-lunar-champion-rebalance` (current HEAD) | **10** | - | 10 |
| `codex/arr25-content-sweep` (**not** an ancestor of HEAD) | **39** | 526 | 91 |

The hub ships **44** channel folders. HEAD can only regenerate 10 of them.

**Consequence:** running the documented pipeline
(`pdv_quest_tranche_merge.mjs` -> `pdv_quest_matrix_compile.mjs`) from this branch
regenerates the channels from 10 sources and **drops roughly 29 mods' worth of shipped
patch content**, with no error - the tool has no way to know a source it never saw used
to exist.

## How it was caught

`PaarthurnaxQE`, `InfiltrationQE` and `NilheimQE` ship channels carrying real award rows
(`MQPaarthurnax` s99 -> Stendarr/Stuhn/Mara/Kyne/Molag Bal; `dunTrevasWatchQST` s100 ->
Stendarr/Mara/Akatosh; `dunNilheimQST` s100/s130 -> Shor/Malacath/Baan Dar,
Zenithar/Z'en), all stamped `generatedAt 2026-08-06`. None of those three editor_ids
appears in `Full.csv` **or** in any tracked CSV on HEAD.

`git log --all -S` traced them to `ff7fc4e2` on `codex/arr25-content-sweep`, which carries
`PDV_QRM_InfiltrationQE.csv` and 28 other patch CSVs absent from HEAD. There is no
deletion commit on HEAD, because they were never on HEAD.

## Two things this corrects

**1. `Full.csv` is not the coverage authority on its own.** Coverage is
`Full.csv` (core, 156 editor_ids) **plus** `references/authoring/patches/*.csv` (per-mod,
91 on the sweep branch). Any audit that checks only `Full.csv` will report covered mods as
uncovered and re-author rows that already exist. This audit did exactly that before the
patches directory was found.

**2. A channel existing does not mean its source does.** The shipped `dist/` tree and the
tracked source tree are out of step. Treat `dist/` as evidence of what was built, never as
evidence of what can be rebuilt.

## Recommended fix

Merge or cherry-pick the 29 missing `PDV_QRM_*.csv` files from
`codex/arr25-content-sweep` onto the mainline, then regenerate and diff the channels
against the shipped ones. A clean diff proves the sources are complete; any channel that
comes back empty names a source still missing.

## Suggested gate

Add to the no-op patch gate already scoped: **every shipped channel folder must have a
resolvable source row set**. Fail the build when a channel's `questEditorIds` cannot be
found in `Full.csv` or `references/authoring/patches/*.csv`. That converts this failure
class from silent to loud, and would have caught it the day the branches diverged.

Related: [[full-csv-is-generated-tranche-merge-check]], [[repo-source-drift-live-ahead]],
[[codex-commit-sweep-reverts-shared-files]].
