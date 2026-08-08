# A001-A008 factual review support

Scope: direct raw-file QUST enumeration already recorded in the eight checkpoint shards. This note does **not** assign triage, deity, valence, magnitude, support, or review status.

## Reading boundary

`housecarl_read_plugin_file(..., type: "QUST")` returns record identity (FormID source, EditorID) and not quest stage/log/objective payload. Accordingly, the items below identify potentially player-facing families and controller/config/dialogue-only indicators; stage/log/objective evidence remains **not enumerated in the direct summary** and must be obtained in a later record-level review where needed. No direct-read errors were recorded in these eight checkpoint CSVs.

## A001 -- base/CC opening set

- **Alternative Armors (Daedric Mail, Daedric Plate, Dragon Plate, Dragonscale, Dwarven Mail, Dwarven Plate):** each has a `ccBGSSSE0xx_Quest` plus `ccBGSSSE0xx_MiscQuest`; the Daedric Mail file also contains `ccBGSSSE051_MiscQuestAliasFillers` (controller/alias indicator).
- **Cleaned base masters:** includes vanilla-source QUST overrides such as `C03`, `TG05`, `TG08B`, `DA16`, `PlayerWerewolfQuest`, and `CreatureDialogueWerewolf`. The `CreatureDialogue*` identity is a dialogue/controller indicator; the others require objective/stage inspection before any player-outcome conclusion.
- **A001 inventory volume:** 569 enumerated QUST rows. This is an enumeration/support packet, not a claim that all 569 are player-resolving.

## A002 -- CC alternative armour continuation

- **Ebony Plate:** `ccBGSSSE063_Quest`, `ccBGSSSE063_MiscQuest`.
- **Elven Hunter, Iron, Leather, Orcish Plate, Orcish Scaled, Silver, Stalhrim Fur, Steel Soldier:** each follows the paired `..._Quest` / `..._MiscQuest` pattern.
- **Arcane Accessories:** `ccBGSSSE014_SpellPack_StartupQuest` is explicitly a startup/controller indicator.
- **A002 inventory volume:** 19 QUST rows.

## A003 -- CC quests and supporting controllers

- **Arms of Chaos:** `ccPEWSSE002_Quest` and `ccPEWSSE002_QuestItems`; the latter is an item/controller indicator.
- **Bittercup:** `ccKRTSSE001_QuestFortune` and `ccKRTSSE001_QuestPower` are potential resolving paths; `...DialogueFollower`, `...FerrySystem`, and `...zQuest` are dialogue/system indicators.
- **Civil War Champions:** `ccFFBSSE001_Quest` alongside `...KillTracking` and `...CorpseCheck` controller/tracking indicators.
- **Ghosts of the Tribunal / Almsivi:** `ccASVSSE001_Quest[A-E]` and `ccASVSSE001_Quest`; `FollowerFriendQuest` is a follower/controller indicator.
- **A003 inventory volume:** 79 QUST rows.

## A004 -- mounts, pets, and small CC quest lines

- **Wild Horses:** `ccBGSSSE034_WildHorsesQuest`, `...UnicornQuest`, and several `...Misc_Horse*` records; `HorseSaddleQuest` is equipment/controller adjacent.
- **Adventurer's Backpack:** `ccBGSSSE040_Quest`; `PetControlQuest` is controller-only by identity.
- **Netch Leather:** `ccBGSSSE041_Quest`, `...BootsQuest`, `...MiscQuest`; `DialogueQuest` is dialogue-only by identity.
- **Expanded Crossbow Pack:** `ccBGSSSE043_VampireHunterQuest`.
- **A004 inventory volume:** 29 QUST rows.

## A005 -- CC continuation

- **Daedric Intervention:** `ccBGSSSE067_Quest`, `...Quest2`; `WightDialogue` is dialogue-only by identity.
- **Nordic Jewelry:** `CraftsmanEncounterQuest` and `CraftNorJewelryQuest` warrant objective review; `UtilityQuest` is a controller indicator.
- **Hearthfire / homes:** `ccEEJSSE001_Quest`.
- **Civil War Champions and Bittercup duplicates:** same record identities as A003; retain as source-plugin duplicate evidence, do not infer separate outcomes.
- **A005 inventory volume:** 24 QUST rows.

## A006 -- Survival, Forgotten Seasons, Necromantic Grimoire, Farming

- **Survival Mode:** `SurvivalModeMainQuest`; `Need*`, `Heat*`, `PlayerInfo*`, `PlayerTalking*`, and `UIMovement*` are monitoring/UI controller indicators.
- **Forgotten Seasons:** `DLCDwarvenPuzzleDungeonQuest01`, `Quest02`, `HorseQuest`, and `CrownQuest` are the potential progression branches; `Check`, `Update`, and horse dialogue are controller/dialogue indicators.
- **Necromantic Grimoire:** `ccVSVSSE003_MainQuest`; `CreatureDialogueBoneColossus` is dialogue-only by identity.
- **Farming:** `ccVSVSSE004_IntroQuestMisc` and `...MainQuest` are potential progression paths.
- **A006 inventory volume:** 39 QUST rows.

## A007 -- Fishing

- `ccBGSSSE001-fish.esm` contributes 69 QUST rows. Candidate progression identities include `Fish_MQ[1-4]`, `Crab_MQ[1-4]`, and named `Misc_*` branches.
- `FishingSystemQuest`, `PersistentDialogueQuest`, `DialogueDetectQuest`, `DecorationDialogue`, `FishingFollowerIdleQuest`, and `RadiantQuests` are system/dialogue/radiant indicators, not outcome evidence.
- Every proposed player-resolving branch still needs its actual objective/stage sequence; no such sequence is supplied by the direct summary.

## A008 -- Redguard, ResourcePack, Ruin's Edge, Saints & Seducers

- **Redguard Elite Armaments:** `ccEDHSSE003_Quest`.
- **ResourcePack:** `RP_DynamicCarriageSystem`, `RP_DefaultSpellTomeInjector`, `RP_AloeIntegration`, and `RP_DynamicFerrySystem` are system/injector indicators.
- **Ruin's Edge:** `ccBGSSSE004_Quest`.
- **Saints & Seducers:** potential progression identities include `...MiscQuest_AmberMadnessGear`, `...MiscQuest_GSDSGearBook`, `...StaadaQuest`, `...MiscQuest_Nerveshatter`, and Elytra acquisition/adoption records. Kill-leader, post-quest-courier, rare-curios integration, and pet-adoption identities are tracking/courier/integration indicators.
- **A008 inventory volume:** 31 QUST rows.

## Exact errors and duplicate handling

- Direct checkpoint summaries for A001-A008 record no read errors.
- Repeated QUST FormIDs across cleaned-master and dedicated CC inputs are source-plugin duplicates, not independently established player outcomes.
- This digest deliberately does not collapse those duplicates or change any review status.

