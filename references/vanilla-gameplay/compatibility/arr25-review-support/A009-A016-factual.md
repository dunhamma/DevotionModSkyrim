# A009-A016 factual review support

This is a read-only aid for primary review. It does not assign any semantic decision. Checkpoint rows remain the source for exact FormKeys and full enumeration.

## A009 -- Creation Club and worldspace

- Stendarr's Hammer: ccBGSSSE006_Quest / If I had a Hammer (000805) has the objective "Steal Stendarr's Hammer" and stages 0, 1, 100, 500, 1000.
- The Cause duplicate records include The Cause and The Consequences. The latter records objectives for entering the Oblivion Gate, defeating the Dremora Valkynaz, retrieving Scourge/Torment, returning to Tamriel, and escaping Red Scar Cavern.
- The Contest, Caught in a Web, has stages 1,2,3,4,5,6,7,10,15,20,30,40,50,60,100; objectives include locating both heroes, defeating the Web Mother, and inspecting two corpses.
- Umbra, Vile Whispers, records objectives to investigate Champion's Rest, defeat Umbra, and retrieve the artifact.
- Vigil Enforcer, Unholy Vigil, has a 24-stage surface. Objective text includes investigating, reading clues, trailing suspects, finding Daedra worshippers, and destroying the cult.
- Wild Horses: eight Find/tame records, Horse Whisperer, and Creature of Legend are enumerated. Horse quests have stages 0 and 10; the unicorn has 0, 10, and 20. The saddle record has stage 0 only.
- Survival Mode: nine records are named heat/cold/hunger/exhaustion, player-info/UI movement, locator/check, main, and talking quests. Existing evidence has no stage/objective text for these system records.
- Animated Ships: 12 manager-named records have no recorded stage/objective text in the checkpoint.

## A010-A015 -- evidence boundary

The inspected checkpoint evidence already contains direct stage/objective rows and duplicate notes. No additional raw-file read was needed for this concise factual digest. Use each CSV row's stage_numbers and evidence fields for full detail.

## A016 -- repeatable/system-heavy sets

- Missives 2.03 enumerates regional courier-letter, courier-weapon, and gather-ingredient records across low, medium, and high tiers; its rows have enumeration but no journal/stage payload.
- Manbeast has the CreatureDialogueWerewolf override and MAG_ForceTracker; neither has recorded objectives or stages.
- Sacrilege has PlayerVampireQuest, DLC1PlayerVampireQuest, and DLC1DialogueVampire overrides without recorded objective/stage text.
- Sun Affects NPC Vampires has _SunHealthDrainQuest; its hooded companion has zero QUST records. Vampire Feeding Tweaks has AO_VampireQuest without recorded objective/stage text. Wielding Sun Stuff Hurts Vamps has zero QUST records.

## Errors and reconciliation

Checkpoint master warnings are raw-file environment warnings, not semantic findings. Existing A009 duplicate notes remain intact. No direct-read errors were recorded in this factual-support pass.
