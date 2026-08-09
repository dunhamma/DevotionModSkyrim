# JoJ silence ledger

Class: LIVING (opened 2026-08-09, grows as the content audit proceeds)

Every JoJ candidate ruled SILENT, **with the evidence that produced the ruling**.

That last part is the point of the file. `PDV_ARR25_ContentSweep_CodexHandoff_2026-08-06.md`
recorded Val Serano as a verified negative with no QUST records, phrased *"recorded so they
are not re-checked"* -- and the plugin defines 62. A negative written specifically to stop
anyone looking again survives exactly as long as nobody disobeys it. So each row here carries
the record read, and a later reader is expected to re-derive rather than trust.

A SILENT ruling means Devotion awards nothing for that content. It does not mean the mod is
unsupported, and it never means the mod is bad.

---

## Kaidan

Kaidan splits across several plugins. `Kaidan - Immersive Features.esp` declares `0Kaidan.esp`
as a **master**, so the AIO extends Kaidan 2 rather than replacing it; both are covered, as two
separately-gated options (owner ruling 2026-08-09). What follows is what was ruled out.

### `KaidanNSFW.esp` -- SILENT (nothing to hook)

| | |
|---|---|
| Read | `housecarl_read_plugin_file`, absolute path, 2026-08-09 |
| Defines | exactly **1** QUST: `000800:KaidanNSFW.esp` `KaidanNSFWQuest`, Name `NSFW IF Kaidan` |
| Stages | **0** |
| Objectives | **0** |

A config/controller quest. Devotion routes on quest-stage fires, so a quest with no stages
offers nothing to attach a row to -- there is no hook, at any depth, for any deity.

This is a mechanical ruling, not a content one. The owner asked for this material included if
practical (2026-08-09) and it is not practical in the matrix lane. If Kaidan's adult content
should be noticed later, the hook has to be a non-quest surface -- a SPID or keyword lane
watching state rather than stages -- which is a different packet with a different proof stack.

It also supersedes the earlier `DEFER` in `arr25-discovery-checkpoints/C020.csv`, whose reason
read *"content-bearing or alternate-resolution quest evidence lacks the stage/objective
semantics needed for truthful deity assignment"*. That was right, and this records **why**.

### `K03` / `K04` relationship and romance progression -- SILENT (no evidence at any stage)

| Quest | Name | Stages | Stages with evidence | Tiers |
|---|---|---:|---:|---|
| `K03` | Relationship progression | 14 | **0** | all C |
| `K04` | Romance Progression | 26 | **0** | all C |

Forty stages between them and not one carries a journal entry or an objective. They are silent
state machines that drive dialogue conditions; the player never sees a line of either.

The owner ruled on 2026-08-09 that marriage and romance should both be covered. Marriage is
covered -- see below. **Romance progression cannot be**, because rowing it would mean assigning
theological meaning to forty unlabelled stage numbers with no text to cite. That is precisely
what the citation standard exists to prevent, and a row invented that way is indistinguishable
from a correct one until a player notices piety arriving for nothing.

What survives instead is the part of the romance arc that *is* player-facing:
`HFSmallWedding` ("Blood of my Blood"), `HFBigWedding`, `HFBigWeddingIF` and `KaiHoneymoon`
("With You All The Way") all carry stages with objectives, and all are rowable to Mara on
`marriage_family`. The owner's intent is served; the mechanism is the wedding, not the meter.

### `Kaidan - Alternate Start Quest.esp` -- SILENT (owner ruling)

`KNewStart` "Transgressions Unknown" (7 stages / 6 objectives per the 2026-08-06 ARR content
inventory) is a start-mode variant rather than a story beat. Owner ruling 2026-08-09, taken
with the two-option Kaidan shape. Revisit if alternate-start coverage is ever wanted as a
class -- the quest itself is content-bearing and would be rowable.

---

## Already covered -- do NOT queue these as work

Both were caught by the first worklist build reporting them as defining no QUST of their own,
then confirmed by a record read. This is the trap `PDV_JoJ_CompatibilityPackage_2026-08-08.md`
section 2 names in advance: **a quest expansion typically adds stages to the VANILLA editor
id**, so coverage must be computed against `Full.csv`, never against hub folder names. A
folder-name diff would have queued both as uncovered work, and it would have been wrong.

| Mod | Plugin | Overrides | Already in `Full.csv` |
|---|---|---|---|
| The Only Cure - Quest Expansion | `TheOnlyCureQuestExpansion.esp` | `08998D:Skyrim.esm` `DA13`, and nothing else | `DA13` s101 *(QE - refuse)* and s102 *(QE - destroy altar)*, Peryite |
| House of Horrors - Quest Expansion | `HouseOfHorrorsQuestExpansion.esp` | `022F08:Skyrim.esm` `DA10`, and nothing else | `DA10` s210 *(QE - destroy altar)*, Molag Bal and Stendarr |

Neither needs a channel. A channel keyed on their FormIDs would double-claim cells the core
matrix already owns, which `pdv_quest_channel_reconcile.mjs` would reject anyway.

## No quest surface at all -- SILENT

Read 2026-08-09; each touches **zero** QUST records, defined or overridden. Nothing in the
quest-reaction lane can see them.

| Mod | Plugin | QUST records |
|---|---|---:|
| Respectful Ravyn | `Respectful Ravyn.esp` | 0 |
| Cult of the World Eater - Dragon Priests Buff Alduin | `World Eater's Influence.esp` | 0 |
| Unique Vampire Dens SSE | `gonkishvampdens.esp` | 0 |

The first two sat in JoJ's **Quest Expansions** separator and the third in **New Quests &
Adventures**, so all three read as quest content by section membership. They are a difficulty
tweak, an NPC behaviour tweak, and a dungeon overhaul. Section membership is a candidate
filter, not evidence -- which is the same lesson the folder-name misclassifications taught.

---

## Pruned as framework by the structural digest

`tools/pdv_joj_stage_digest.mjs` classifies a quest `framework` when it carries no journal
entry and no objective on any stage. These are the `JRLucienMapMarker` / `KaiCompJorrvaskr`
family the ARR discovery waves already adjudicated as non-content: map markers, ride handlers,
catch-up helpers, furniture and scene controllers.

| Mod | Quests defined | Content | Framework |
|---|---:|---:|---:|
| Kaidan 2 | 26 | 8 | 18 |
| Immersive Kaidan AIO | 143 | 14 | **129** |
| The Tools of Kagrenac + Ascend (batch B01) | 9 | 5 | 4 |

Framework quests are **evidence-classified, not human-ruled**, and are listed by name in each
mod's digest so the classification is auditable rather than silent. A quest wrongly pruned here
is recoverable: re-read it and the tiers will say so. Nothing in this table is a design
decision.
