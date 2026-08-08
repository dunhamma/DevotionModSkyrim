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

## RESOLVED for 39 of 44 - merged 2026-08-08 (`c1c47357`)

`codex/arr25-content-sweep` was merged into `codex/khajiit-lunar-champion-rebalance`.
`references/authoring/patches/*.csv` went 10 -> 39, and **all 39 now regenerate
byte-identical to the shipped channels** (verified by compiling each source and diffing
against `dist/`, ignoring timestamps).

### What regeneration changed, and why it was needed anyway

The first regeneration pass came back **39 differ / 0 identical**, which looked alarming
and was not. The award rows were identical in every case (`stringList` value-diff = 0);
every difference sat in the **shared stance matrix** baked into each channel:

- The merge brought `7e9fd58e fix(altmer): scope current roster to five deities`, which
  deliberately moves **Mara, Stendarr and Y'ffre from NATIVE to FOREIGN for Altmer**
  ("Altmer access deferred for a future roster review"). The shipped channels predated
  that theology decision.
- A deity key renamed from `Riddle'Thar / ja-Kha'jay` to `Riddle'Thar`.

**The rename was a live defect, not cosmetic.** `PDV__ManagerQuest.psc:3455` builds the
lookup as `"stance." + raceLabel + "." + deityName`, and the manager's own name for that
deity is the short `Riddle'Thar`. Channels carrying the long-form key therefore hold a
key the manager cannot find. Regenerating fixes it; the 39 are now consistent with the
core matrix.

## RESOLVED - all 44 channels now regenerate from tracked source (2026-08-08)

Final state: **44 source CSVs, 44 shipped channels, 44/44 regenerate identical, 0 with
no source.** The five below were reconstructed; award data was compared field-by-field
against the pre-reconstruction channels and **preserved exactly** (deities, valences,
intensities, magnitudes, tags, and the quest-key set all unchanged).

Two things worth knowing about the reconstruction:

- **The stale channels used an older channel format.** They carried `quest.<key>.evidence`
  and `quest.<key>.runtimeverify` keys that the current compiler no longer emits (the
  other 39 have neither). So the target was not byte-identity with the stale files but
  the current format with identical award data. Those evidence strings were moved into
  the CSV `citation` column, which is where provenance belongs.
- **`outcome` text could not be recovered.** The channel format never encoded it. Each
  reconstructed row says so in its citation: award data is verbatim, editor_id/formid are
  houseCARL readbacks, and the outcome sentence is authored.

Both addon quests turned out to be the mods' OWN added quests, not the vanilla ones they
sit beside - `T01_GiveLetter` is not vanilla `T01` (9 rows in Full.csv) and
`CH_TotemReturnQuest` is not vanilla `DA05` (15 rows). Core owns the vanilla pair, the
per-mod patch owns the addition. No gap and no double-award.

### The five, as reconstructed



These ship in `dist/` but were generated from untracked scratch CSVs that no longer
exist. `git log --all -S` finds no `patches/PDV_QRM_<name>.csv` for any of them, so
unlike the 29 this is not branch drift - the source was never tracked at all.

| Channel | Target plugin | Award rows (FormID\|stage -> deities) |
|---|---|---|
| `AboveAllElse` | `Darbalag - Quest Mod.esp` | `2\|40` -> Hermaeus Mora |
| `BardsRebornStudentOfSong` | `BardsRebornStudentofSong.esp` | `419643\|140`, `1581715\|20` -> Dibella |
| `BecomeABard` | `BecomeABard.esp` | `162848\|100`, `162847\|100` -> Dibella |
| `HeartOfDibellaQE` | `The Heart Of Dibella - Quest Expansion.esp` | `2070\|0` -> Dibella, Mara |
| `IllMetByMoonlightDialogue` | `CH_IMBMDialougeAddon.esp` | `38\|10` -> Hircine |

**Consequence right now:** these five still carry the stale long-form `Riddle'Thar` key
and the pre-`7e9fd58e` Altmer stances, so they are inconsistent with the core matrix and
the other 39. Seven award rows in total are affected.

**Reconstruction is mechanical but needs record reads.** Every channel reports
`questEditorIds: [None]` - the editor IDs were never resolved, and the CSV schema is
keyed on `editor_id`. Rebuilding them requires resolving each FormID against a load order
that carries the plugin (none are in Anvil; check ARR). Do NOT invent editor_ids to make
the file parse - an unprovable row is exactly what the ARR method refuses to author.

## Suggested gate

Add to the no-op patch gate already scoped: **every shipped channel folder must have a
resolvable source row set**. Fail the build when a channel's `questEditorIds` cannot be
found in `Full.csv` or `references/authoring/patches/*.csv`. That converts this failure
class from silent to loud, and would have caught it the day the branches diverged.

Related: [[full-csv-is-generated-tranche-merge-check]], [[repo-source-drift-live-ahead]],
[[codex-commit-sweep-reverts-shared-files]].
