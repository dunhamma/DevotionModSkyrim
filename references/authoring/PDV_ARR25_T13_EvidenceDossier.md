# ARR 2.5 T13 factual quest evidence dossier

## Scope and reading boundary

This is a factual extraction for T13. Every listed record was read directly
from its absolute plugin-file path with `housecarl_read_plugin_file`; each is
therefore an OUT-OF-LOAD-ORDER raw-file read, not a winning-record assertion.
No MO2 instance was changed. This dossier makes no deity, valence, magnitude,
support, or implementation decision.

`CompleteQuest` below means the flag on that stage's log entry. It does not
assert how the quest was reached at runtime. Where the file exposes an
objective but not a deterministic stage transition, the follow-up is
`RUNTIME-VERIFY`.

## Wyrmstooth

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Wyrmstooth\\Wyrmstooth.esp`

| FormKey | EditorID | Flags | exact factual surface | terminal / resolving evidence |
|---|---|---|---|---|
| `028F01:Wyrmstooth.esp` | `WTBarrowOfTheWyrm` | `RunOnce` | Objectives include "Defend Stonehollow from Vulthurkrah" (230) and "Receive your reward from Lurius Liore" (260). | Stage 260 log: "The dragon Vulthurkrah has been defeated." Stage 270 is `ShutDownStage` and its log entry is `CompleteQuest`; terminal entry text absent. |
| `022528:Wyrmstooth.esp` | `WTDragonHunt` | `RunOnce` | Objective 100: "Find and defeat the dragon at Ancient's Ascent"; objective 120: "Return to Lurius Liore". | Stage 120 log says the dragon fled to Wyrmstooth and instructs return to Lurius. Stage 130 log is `CompleteQuest` with `NextQuest = 028F01:Wyrmstooth.esp`; terminal entry text absent. |
| `4B9DF0:Wyrmstooth.esp` | `WTBountyVampire` | `273` | Objective 10: "Kill the Master Vampire at Bloodfrost Burrow." | Stage 20 log entry is `CompleteQuest`; text absent. |
| `4B9DEF:Wyrmstooth.esp` | `WTBountyWarlock` | `273` | Objective 10: "Kill the troublesome warlock at Krakevisa." | Stage 20 log entry is `CompleteQuest`; text absent. |
| `3943A0:Wyrmstooth.esp` | `WTKillThalmor` | `273` | Objectives: "Kill the Thalmor spies." (10), then "Return to Alberthor." (20). | Stage 30 is `CompleteQuest`; its log says: "I have dealt with the Thalmor spies for Alberthor." |

## Creation Club: The Cause

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Creation Club - The Cause\\ccbgssse067-daedinv.esm`

| FormKey | EditorID | Flags | exact factual surface | terminal / resolving evidence |
|---|---|---|---|---|
| `06BFC1:ccbgssse067-daedinv.esm` | `ccBGSSSE067_Quest` | `RunOnce` | 34 objectives. Early objectives include "Meet Skorvild at the Shrine to Stendarr" (30), "Defeat the Mythic Dawn Assassins" (40), and "Read Skorvild's Journal" (60). | Raw stages run through 400. Stages 290, 300, and 400 have log entries but their text is absent and none carries `CompleteQuest` in the file read. `RUNTIME-VERIFY` any claimed resolving stage. |
| `19952A:ccbgssse067-daedinv.esm` | `ccBGSSSE067_Quest2` | not separately asserted here | Objectives include retrieving Vonos' Journal, entering the gate, defeating Dremora, retrieving Scourge and Torment, returning to Tamriel, and escaping. | Stage 1000 is `CompleteQuest`. Its log says the player entered the Deadlands, vanquished two Dremora, retrieved their weapons, escaped, and the Vigil of Stendarr secured Red Scar Cavern. Stage 300 has the corresponding pre-escape log. |

## Creation Club: Ghosts of the Tribunal

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Creation Club - Ghosts of the Tribunal\\ccasvsse001-almsivi.esm`

| FormKey | EditorID | name | flags | factual objective / stage surface |
|---|---|---|---|---|
| `000CC3:ccasvsse001-almsivi.esm` | `ccASVSSE001_Quest` | Ghosts of the Tribunal | `RunOnce` | Stages: 1, 2, 3, 4, 5, 7-23, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95-100, 110, 120, 125, 130, 140, 150, 155, 160, 170, 180, 185, 190, 200, 250, 290. No readable objective text in the direct read. `RUNTIME-VERIFY` terminal semantics. |
| `000CA0:ccasvsse001-almsivi.esm` | `ccASVSSE001_QuestA` | Buyer Beware | `RunOnce` | Objectives include tracking a Redoran Guard after midnight, looking for cellar clues, killing the Buyer, retrieving the Mask of Vivec, and returning to the temple. Stages end at 3000; terminal flag/text requires `RUNTIME-VERIFY`. |
| `000F19:ccasvsse001-almsivi.esm` | `ccASVSSE001_QuestB` | Her Word Against Theirs | `RunOnce` | Objectives include translating and distributing letters, then giving them to the Reclamation Priest. Stages include 500 and 1000; terminal meaning requires `RUNTIME-VERIFY`. |
| `000F1A:ccasvsse001-almsivi.esm` | `ccASVSSE001_QuestC` | Careless Curation | `RunOnce` | Objectives: ask about missing Curate, read Melita's plea, find the Curate in Kagrenzel. Stages end at 100; `RUNTIME-VERIFY` terminal meaning. |
| `00117A:ccasvsse001-almsivi.esm` | `ccASVSSE001_QuestD` | Ashen Heart | `RunOnce` | Objectives include solving the armory puzzle, reading Erden Relvel's note, killing the Priest of Dagoth Ur, and retrieving the Mask of Dagoth Ur. Stages end at 100; `RUNTIME-VERIFY` terminal meaning. |
| `0990EF:ccasvsse001-almsivi.esm` | `ccASVSSE001_QuestE` | Trueflame | `RunOnce` | Objectives include collecting and placing four forge gems, applying Pyroil Tar, operating the forge, and picking up Trueflame. Stages end at 100; `RUNTIME-VERIFY` terminal meaning. |

## Creation Club: Divine Crusader

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Creation Club - Divine Crusader\\ccmtysse001-knightsofthenine.esl`

| FormKey | EditorID | flags | exact factual surface | terminal / resolving evidence |
|---|---|---|---|---|
| `000865:ccmtysse001-knightsofthenine.esl` | `ccMTYSSE001_Quest` | not separately asserted here | Stage 10 log: "I have committed acts that have made me unfit to wear the Crusader's Relics. I will need to make a pilgrimage to nine shrines in order to repent." | Stage 100 has `CompleteQuest`; entry text absent. No objective text was exposed in this raw read. |

## Taste of Death addon

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\The Taste of Death - Quest Addon\\TasteOfDeath_Addon_Dialogue.esp`

| FormKey | EditorID | name / flags | objective and stage evidence |
|---|---|---|---|
| `000050:TasteOfDeath_Addon_Dialogue.esp` | `madNamiraAddonQuest` | A Bitter Aftertaste; `273` | Objectives: optional Brother Verulus (5), evidence in Reachcliff Cave (10), optional Jarl permission (15), confront Hogni/Lisbet/Banning (21-23), and Jarl reward (30). Stages: 0, 5, 6, 10, 20, 30, 40, 45, 100. No `CompleteQuest` flag was established in the direct stage surface; `RUNTIME-VERIFY` resolution. |
| `000051:TasteOfDeath_Addon_Dialogue.esp` | `madNamiraAddonQuestJail01` | no name; `273` | No objectives; stages 0 and 10. Player-resolving status is not established: `RUNTIME-VERIFY`. |
| `000052:TasteOfDeath_Addon_Dialogue.esp` | `madNamiraAddonQuestJail02` | no name; `273` | No objectives; stages 0 and 10. Player-resolving status is not established: `RUNTIME-VERIFY`. |
| `000670:TasteOfDeath_Addon_Dialogue.esp` | `madNamiraAddonQuestExtort` | no name; `273` | No objectives; stages 0 and 10. Player-resolving status is not established: `RUNTIME-VERIFY`. |

## Siege at Icemoth

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Siege at Icemoth\\Siege at Icemoth.esp`

| FormKey | EditorID | name / flags | objective and stage evidence |
|---|---|---|---|
| `5A079F:Siege at Icemoth.esp` | `HYORdunIcemothQST` | Siege at Icemoth; `273` | Objectives: travel to Fort Icemoth (10); deal with source of undead (20). Stages 0 (`StartUpStage`), 10, 20, 30. No completion flag was exposed; `RUNTIME-VERIFY`. |
| `07F08F:Siege at Icemoth.esp` | `HYORdunSaervildsTrenchQST` | no name; `RunOnce` | No objectives. Stages 10 (`StartUpStage`), 20, 100. No completion flag was exposed; `RUNTIME-VERIFY`. |
| `097057:Siege at Icemoth.esp` | `HYORdunWintershroudSanctumQST` | The Topaz Claw; `RunOnce` | Objectives: obtain Topaz Dragon Claw (10), find a use (15), find Winter Shroud Sanctum's secret (20). Stages 0 (`StartUpStage`), 10, 15, 20, 100. No completion flag was exposed; `RUNTIME-VERIFY`. |
| `59F97E:Siege at Icemoth.esp` | `HYORBlackBook08Quest` | Black Book: The Font of Memory; `RunOnce` | Objective 10: "Learn the Black Book's hidden knowledge." Stages 10 and 20. No completion flag was exposed; `RUNTIME-VERIFY`. |

## Hunt for the Spectre

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\The Hunt for the Spectre - Elden Ring Inspired Quest\\Hunt for the Spectre.esp`

`000800:Hunt for the Spectre.esp` (`HSHuntForSpectreQuest`) has objective 31, "Find Ren's amulet." The raw log sequence records stage 31 "Player going to find pendant", 32 "Retrieved Pendant", 40 "Ren survived", 45 "Timer started, quest done", 50 "Ren dies happy, quest done", and stage 55 `CompleteQuest`, "Quest finally done, Spectre is dead." Those are alternate-looking factual stage outcomes; runtime route selection is not inferred here.

## Calling the Watchmaker

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Calling the Watchmaker - Lovecraftian Inspired Quest\\Sithis Mod - Lovecraftian Inspired Quest.esp`

`000892:Sithis Mod - Lovecraftian Inspired Quest.esp` (`SMQuest`) objectives are speak with the scholar (5), speak with Dreynos (15), speak with Dreynos again (25), and check up on Dreynos (35). Stage 35 is `CompleteQuest` and logs that Dreynos' burned remains were found; stages 40 and 45 log alternate wording about killing or slaying Dreynos. The raw file does not establish which outcome is normal play: `RUNTIME-VERIFY`.

## The Gift of Saturalia

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\The Gift of Saturalia - A Quest for the Holidays\\TheGiftofSaturalia.esp`

| FormKey | EditorID | name | flags | objective surface | stage surface |
|---|---|---|---|---|---|
| `000D61:TheGiftofSaturalia.esp` | `Sat_TheGiftofSaturalia` | The Gift of Saturalia | `273` | "Help Niklas with his Saturalia gifts" (5) | 0, 5-11, 15; no `CompleteQuest` flag exposed in this read. |
| `0008AA:TheGiftofSaturalia.esp` | `Sat_Orphanage` | Three Wise Men | `RunOnce` | toys from Bersi, food from Talen-Jei, optional Maramal donation, visit orphanage, speak to Constance, return to Niklas | 0, 5, 10, 11, 12, 15, 20; `RUNTIME-VERIFY` resolving stage. |
| `0008D3:TheGiftofSaturalia.esp` | `Sat_Laugh` | The Joy of Dawnstar | `RunOnce` | make seven people laugh (1/7 through 7/7), then speak to Niklas | 0-8; `RUNTIME-VERIFY` resolving stage. |
| `000963:TheGiftofSaturalia.esp` | `Sat_Adoption` | Windhelm By The Sea | `RunOnce` | speak to Captain Lonely-Gale; return to Niklas | 0, 5, 10; `RUNTIME-VERIFY` resolving stage. |
| `0009A4:TheGiftofSaturalia.esp` | `Sat_Dog` | Lending a Paw | `RunOnce` | bring Santus to Olava the Feeble; return to Niklas | 0, 5, 10; `RUNTIME-VERIFY` resolving stage. |
| `0009D2:TheGiftofSaturalia.esp` | `Sat_Music` | A Song in the Dark | `RunOnce` | speak to Diane, Viarmo, and Diane; take Diane to Viarmo; return to Niklas | 0, 5, 10, 15, 20, 21, 25, 30; stage 30 is `ShutDownStage`, not a `CompleteQuest` assertion. |

## Above All Else

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Above all Else - Lovecraft Inspired Quest\\Darbalag - Quest Mod.esp`

`000002:Darbalag - Quest Mod.esp` (`DBQDarbalagQuest`) has no name and no objectives in the direct read. Stages are 0, 5, 10, 15, 20, 25, 30, 35, and 40; only stage 5 has text, "Timer started." No stage carries `CompleteQuest` in the raw extraction. `RUNTIME-VERIFY` required for any claimed player-resolving route.

## Explicit carryover / exclusion

Gray Cowl and Mephala's Curse are already covered elsewhere and were not re-adjudicated here. M'rissi is excluded from this T13 dossier and remains assigned to T14.
