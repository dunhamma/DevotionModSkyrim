# ARR 2.5 T15 evidence dossier

## Scope and evidence boundary

T15 covers vanilla quest expansions whose usable outcomes are either new QUST
definitions or new resolving stages on vanilla QUST records. Evidence came from
absolute-path direct `housecarl_read_plugin_file` reads against the ARR 2.5
plugin files. The active Anvil houseCARL instance was not changed.

These reads establish the data encoded in the named files. They do not prove the
ARR winning record, runtime stage delivery, player-facing presentation, or
support. Objective-derived semantics remain explicitly runtime-gated.

## Authored evidence

| plugin/channel | record and resolving stages | primary evidence verdict |
|---|---|---|
| College Of Winterhold - Quest Expansion.esp | new `Cow_Breathing|50`, `Cow_restoration|25`, `Cow_Conjuration|25`, `Cow_Reading|25`, `Cow_enchantment|70`, `Cow_illusion|25`, `Cow_Destruction|20` | Seven direct `CompleteQuest`/`ShutDownStage` lesson resolutions. The central curriculum umbrella was excluded as double credit. |
| Infiltration - Quest Expansion.esp | override `Skyrim.esm:04B2A1`, `dunTrevasWatchQST|100` | Direct completion says Brurid was dealt with and Stalleo can return his family to Treva's Watch. |
| Nilheim_MiscQuestExpansion.esp | override `Skyrim.esm:01BAEC`, `dunNilheimQST|100` and `|130` | Direct completion distinguishes defeating Telrav's double-cross from explicitly extorting him. |
| The Whispering Door - Quest Expansion.esp | override `Skyrim.esm:04A37B`, `DA08|45` | Direct completion says the Ebony Blade was removed so it could cause no more harm. |
| PaarthurnaxQuestExpansion.esp | override `Skyrim.esm:03FA16`, `MQPaarthurnax|99` | Stage 75 exposes persuade-the-Blades versus kill-Paarthurnax; stage 99 is textless `CompleteQuest`. The spare/persuasion interpretation is objective-derived and retains `RUNTIME-VERIFY`. |
| Forsworn Conspiracy Quest Expansion.esp | new `aaMS01New|49`, `aaMS02New|60` | Direct completions record victory in trial by combat and the separate route that saves Madanach. The latter explicitly acknowledges that he intends to rebuild his army. |

## Reviewed exclusions and corrections

- College central `COW_CentralQuest|50` merely closes the umbrella over the
  seven scored lessons and would double-credit the same curriculum.
- College refusal stages 30/80 were excluded. Declining a class is not itself a
  controlled theological fault.
- Caught Red Handed QE adds brawl/threaten objectives, but its terminal stages
  are textless and raw QUST data does not map the branches safely. `DEFER`.
- Heart of Dibella QE stages 55-57 are invitation/wait/talk intermediates; the
  existing vanilla terminals remain the truthful scoring surfaces. `NO-ROWS`.
- House of Horrors QE stages 50-54 are textless intermediates. The existing
  stage 210 direct destruction resolution already carries the outcome.
- The Cursed Tribe QE adds intermediate ghost beats and textless completions
  220/230 without a safe branch mapping; stage 210 already directly records the
  magic-assisted resolution.
- The Only Cure QE stages 14/82 are intermediate; existing stages 101/102 are
  the direct terminal surfaces.
- Infiltration stage 95, Nilheim stage 150, and Forsworn stage 80 do not create
  safe additional moral outcomes from their available evidence.
- Paarthurnax stage 99 is `CompleteQuest` with no journal text, correcting the
  earlier inventory implication that its text directly stated the spared route.

## FormKey rule

Vanilla override channels use the origin FormKey (`Skyrim.esm:HEX`), not the
expansion ESP basename. New QUST definitions use their defining expansion ESP.
This preserves runtime lookup identity across override aliases.
