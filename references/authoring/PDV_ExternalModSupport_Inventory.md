# PDV External-Mod Support Inventory

Updated: 2026-08-09 AEST
Class: LIVING -- hand-authored authority (`PDV_STANDARDS.md` section 5.3 class 1)
Status: complete inventory of shipped support; runtime proof is open on most of it, and this doc says which

<!-- pdv-inventory-counts {
  "g1DataOnlyPatches": 49,
  "g2PluginPatches": 5,
  "g1WithAwardRows": 49,
  "g2WithAwardRows": 3,
  "totalReactionCells": 187,
  "totalAwardRows": 1009,
  "hubFoldersTotal": 54,
  "manifestOptions": 54,
  "sourceCsvs": 52,
  "reconstructedCsvs": 5,
  "coreRows": 2144,
  "coreEditorIds": 157,
  "coreQuestExpansionEditorIds": 3,
  "coreCreationClubEditorIds": 4,
  "splitCoverageMods": 2,
  "splitCoverageCollisions": 0,
  "kidLiveRules": 1,
  "kidLiveRuleNames": 9,
  "kidDeclaredEmptyLanes": 4,
  "swapInisDistinct": 1,
  "swapEntries": 11,
  "papyrusHookPlugins": 7
} -->

## Purpose

One place to answer "what external-mod content does Devotion actually support?".

Before this doc the answer was spread across the FOMOD manifest, 52 per-mod
source CSVs, the core matrix, a KID ini, a BaseObjectSwapper ini and a handful
of Papyrus hooks, and nothing tied them together. The grouping below is by
**attach mechanism** -- *how* the support reaches the game -- because that is
the distinction that actually decides whether a user needs to install anything.

**The distinction that matters most:** some support ships as a real installable
patch the user opts into; some is baked into base Devotion with no patch at all.
Both are real support. Only the first one appears in the PatchHub installer, so
reading the installer alone systematically undercounts what the mod covers.

### Regenerating

`tools/pdv_external_support_inventory.mjs` re-derives every number here from the
shipped files. Its dump lands in `generated/` and is **gitignored** -- it is a
section 5.3 class 4 regenerable report and is never committed. This doc is class 1,
hand-curated, and carries the reasoning; the script gates its arithmetic:

```bash
node tools/pdv_external_support_inventory.mjs --check
```

That compares the `pdv-inventory-counts` block at the top of this file against
live content and **exits non-zero on drift**. The verdict is the exit code; do
not grep its output.

Since 2026-08-09 it also checks the **prose**. Landing one mod left the old
option count and award-row total sitting in the body while the counts block had
correctly moved on -- a green gate on a document that had started lying, which is
worse than a red one because nobody goes looking.

Two limits, both real, both stated here rather than left to be discovered:

- The scan covers the phrasings that carry numbers **today**. A new sentence with
  a figure in it is unchecked until its pattern is added to `PROSE` in the script.
- It cannot tell a live claim from a **quoted example**. The first draft of this
  very section quoted the two stale figures to explain the bug, and the checker
  correctly failed on them. Do not write historical counts as bare numerals in
  this file; describe them instead.

### Coverage -- who benefits, not what ships

Everything above counts **mechanisms**. It cannot answer "is the Hist getting as
many opportunities as the others", which is what decides whether a race lane
feels alive:

```bash
node tools/pdv_external_support_inventory.mjs --coverage
```

Per-deity and per-race-lane row counts against a **relative** floor -- 60% of the
median, so it keeps asking the same question as the matrix grows instead of
needing a constant retuned. Exits non-zero on an unwaived breach. Deliberately
thin gods are waived with a reason in
`references/authoring/PDV_CoverageFloorWaivers.csv`; Sanguine, Peryite and Namira
are waived there because their Part B profiles carry 1, 2 and 3 approve tags by
design, and widening them would mean inventing a domain they do not have.

It is a **separate exit** from `--check` on purpose: a coverage breach is a
content gap someone has to decide about, not a documentation error, and one red
standing for two unrelated problems teaches people to ignore it.

Worship objects with no matrix rows at all (Phynaster, Satakal, Ruptga, Tava,
Onsi, Riddle'Thar, Jone/Jode) are **reported, never silently dropped** -- they are
substrate and state deities rather than quest-reaction targets, and a lane can
only be judged thin once you know what is in it.

### Evidence buckets used below

| Bucket | What it means |
|---|---|
| **machine-verified** | The channel/ini/plugin was read off disk and contains what this doc says. Everything in the tables is at least this. |
| **runtime open** | No in-game evidence that the hook fires. The hub manifest's own option description says so. Most of the hub sits here. |
| **reconstructed source** | The shipped channel is authoritative; the per-mod source CSV was rebuilt from it on 2026-08-08. Award data is verbatim, `outcome` prose is authored. Recorded in each row's `citation`. |

Nothing below is claimed as runtime-proven. Where a mod's support is proven in
game, that proof lives in a runbook, not here.

---

## Summary -- counts per group

| # | Group | Attach mechanism | Entries | Ships a plugin? | User installs anything? |
|---|---|---|---:|---|---|
| **G1** | Per-mod quest-reaction patches, data-only | `common/<Mod>/` StorageUtil channel JSON | **49** | No | Yes -- PatchHub option |
| **G2** | Per-mod patches that ship a plugin | ESP (+ TIF fragments / SEQ / BOS ini) | **5** | Yes | Yes -- PatchHub option |
| **G3** | Covered by the CORE mod, no separate patch | rows in `PDV_QuestReactionMatrix_Full.csv` | **157** editor ids (2144 rows) | n/a -- in `Devotion.esp` | **No** |
| **G4** | Item-keyword support (KID) | `PDV_GreenPact_KID.ini` | **1** live rule (9 item names), 4 empty lanes | No | No -- in core |
| **G5** | Shrine / world-object support (BaseObjectSwapper) | `PDV_DaedricShrinesAIO_SWAP.ini` | **1** ini, 11 swaps | Yes -- inside the G2 patch | Yes -- PatchHub option |
| **G6** | Papyrus activity hooks, no quest stage | plugin literals in `PDV_PlayerEvents` / `PDV__ManagerQuest` / `PDV_Origin` | **7** plugins | No | **No** |

G1 + G2 = the 54 PatchHub options, 1:1 with the 54 manifest entries and the 54
`common/` folders. 187 quest-reaction cells, 1009 deity award rows.

**Read this next to the installer:** a user who installs zero PatchHub options
still gets G3, G4 and G6. That is the majority of the reaction surface by row
count -- 2144 core rows against 1009 in the whole hub.

---

## G1 -- Per-mod quest-reaction patches (data-only)

A `common/<Mod>/` folder containing exactly one file: a StorageUtil channel JSON
under `SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/`. No plugin, no
script, no master. The channel declares `questWatchPlugins` and `questEditorIds`;
`PDV__ManagerQuest.ResolveQuestReactionCellFile` checks the core matrix first,
then each registered channel, first hit wins.

Column meanings: **Quests** = distinct quest editor ids watched. **Cells** =
distinct `(formid|stage)` resolutions reacted to -- a quest with several endings
contributes several. **Rows** = individual deity awards across those cells.

Every mod listed has a channel with award rows > 0. Confirmed by reading the
shipped channels, not by the folder existing.

#### New Quests and Lands

| Mod | Depends on | Quests | Cells | Rows | Deities | Source CSV | Proof state |
|---|---|---:|---:|---:|---|---|---|
| Above All Else | `Darbalag - Quest Mod.esp` | 1 | 1 | 1 | Hermaeus Mora | `PDV_QRM_AboveAllElse.csv` | runtime open; **reconstructed source** |
| Baba Yaga and the Labyrinth | `ksws03_quest.esp` | 1 | 1 | 1 | Mara | `PDV_QRM_BabaYaga.csv` | machine-verified |
| Bark and Bite | `Tree Contract Mod.esp` | 1 | 2 | 5 | Hircine, Sheogorath, Stendarr | `PDV_QRM_BarkAndBite.csv` | machine-verified |
| Before the End | `PrisonerMod.esp` | 1 | 1 | 2 | Arkay, Mara | `PDV_QRM_BeforeTheEnd.csv` | machine-verified |
| Beyond Skyrim - Bruma | `BSHeartland.esm` | 4 | 8 | 54 | Akatosh, Alkosh, Baan Dar, Boethiah, Clavicus Vile, Dibella, HoonDing, Julianos, Khenarthi, Leki, Malacath, Mara, Mephala, Molag Bal, Nocturnal, Rajhin, Shor, Sithis, Stendarr, Stuhn, Talos, Y'ffre, Z'en, Zenithar | `PDV_QRM_BeyondSkyrimBruma.csv` | runtime open |
| Calling the Watchmaker | `Sithis Mod - Lovecraftian Inspired Quest.esp` | 1 | 1 | 16 | Baan Dar, Dibella, HoonDing, Khenarthi, Kynareth, Kyne, Leki, Mara, Molag Bal, Rajhin, Shor, Sithis, Stendarr, Stuhn, Talos, Tsun | `PDV_QRM_CallingTheWatchmaker.csv` | runtime open |
| DAc0da | `DAc0da.esm` | 2 | 2 | 2 | Akatosh, Arkay | `PDV_QRM_DAc0da.csv` | runtime open |
| Depths of the Soul | `Dungeon Delver Mod.esp` | 1 | 1 | 1 | Zenithar | `PDV_QRM_DepthsOfTheSoul.csv` | machine-verified |
| Glenmoril | `Glenmoril.esm` | 2 | 2 | 3 | Arkay, Azura, Namira | `PDV_QRM_Glenmoril.csv` | runtime open |
| Hunt for the Spectre | `Hunt for the Spectre.esp` | 1 | 1 | 6 | Arkay, Azura, Meridia, Stendarr, Tu'whacca, Y'ffre | `PDV_QRM_HuntForSpectre.csv` | runtime open |
| Moonpath to Elsweyr | `moonpath.esp` | 4 | 5 | 29 | Julianos, Khenarthi, Kynareth, Kyne, Magnus, Mara, Molag Bal, Stendarr, Stuhn, Syrabane, Talos, The Hist, Tsun, Y'ffre | `PDV_QRM_Moonpath.csv` | runtime open |
| Olenveld | `Olenveld.esp` | 1 | 1 | 1 | Arkay | `PDV_QRM_Olenveld.csv` | runtime open |
| Siege at Icemoth | `Siege at Icemoth.esp` | 2 | 2 | 14 | Arkay, Azura, Boethiah, Hermaeus Mora, HoonDing, Julianos, Magnus, Malacath, Meridia, Shor, Stendarr, Tsun, Tu'whacca, Y'ffre | `PDV_QRM_SiegeAtIcemoth.csv` | runtime open |
| Sirenroot | `evgSIRENROOT.esm` | 1 | 1 | 10 | Arkay, Auri-El, Azura, Magnus, Meridia, Stendarr, Tu'whacca, Xarxes, Y'ffre, Zenithar | `PDV_QRM_Sirenroot.csv` | machine-verified |
| Skyrim Extended Cut - Saints and Seducers | `Skyrim Extended Cut - Saints and Seducers.esp` | 1 | 1 | 1 | Sheogorath | `PDV_QRM_SkyrimExtendedCutSaintsAndSeducers.csv` | runtime open |
| Taste of Death Addon | `TasteOfDeath_Addon_Dialogue.esp` | 1 | 1 | 9 | Akatosh, Alkosh, Auri-El, Julianos, Namira, Stendarr, Stuhn, Z'en, Zenithar | `PDV_QRM_TasteOfDeathAddon.csv` | runtime open |
| The Forgotten City | `ForgottenCity.esp` | 2 | 3 | 3 | Julianos, Mara, Stendarr | `PDV_QRM_ForgottenCity.csv` | runtime open |
| The Frozen Heart | `ksws07_quest.esm` | 1 | 3 | 11 | Auri-El, Mara, Molag Bal, Stendarr, Trinimac | `PDV_QRM_FrozenHeart.csv` | machine-verified |
| The Gift of Saturalia | `TheGiftofSaturalia.esp` | 5 | 5 | 19 | Dibella, Kynareth, Mara, Stendarr, Stuhn, Syrabane, Y'ffre | `PDV_QRM_GiftOfSaturalia.csv` | runtime open |
| The Rot Below | `CJ03Elroy.esp` | 1 | 2 | 17 | Arkay, Azura, Dibella, Mara, Meridia, Namira, Stendarr, Tu'whacca, Y'ffre | `PDV_QRM_RotBelow.csv` | machine-verified |
| The Tools of Kagrenac | `Tools of Kagrenac.esp` | 1 | 2 | 25 | Alkosh, Auri-El, Hermaeus Mora, Hircine, HoonDing, Julianos, Khenarthi, Kynareth, Kyne, Leki, Magnus, Malacath, Mara, Mehrunes Dagon, Molag Bal, Shor, Stendarr, Stuhn, Syrabane, Talos, Trinimac, Tsun, Vaermina, Zenithar | `PDV_QRM_ToolsOfKagrenac.csv` | machine-verified |
| Heart of the Reach | `HeartOfTheReach.esp` | 1 | 2 | 12 | Dibella, Hircine, Khenarthi, Kynareth, Kyne, Mara, The Hist, Y'ffre | `PDV_QRM_HeartOfTheReach.csv` | machine-verified |
| Sleepwalking Into A Nightmare | `NightmarePlane.esp` | 1 | 2 | 29 | Akatosh, Arkay, Auri-El, Baan Dar, Boethiah, Dibella, HoonDing, Khenarthi, Kynareth, Kyne, Mara, Molag Bal, Rajhin, Shor, Stendarr, Stuhn, Syrabane, Talos, The Hist, Tsun, Vaermina | `PDV_QRM_SleepwalkingNightmare.csv` | machine-verified |
| Legends of Aetherium | `LegendsOfAetherium.esp` | 1 | 1 | 9 | Auri-El, Baan Dar, Boethiah, HoonDing, Kyne, Malacath, Shor, Talos, Tsun | `PDV_QRM_LegendsOfAetherium.csv` | machine-verified |
| Moon and Star | `MoonAndStar_MAS.esp` | 4 | 16 | 121 | Alkosh, Auri-El, Baan Dar, Boethiah, Dibella, Hircine, HoonDing, Khenarthi, Kynareth, Kyne, Leki, Malacath, Mara, Mehrunes Dagon, Mephala, Molag Bal, Rajhin, Shor, Sithis, Stendarr, Stuhn, Syrabane, Talos, Trinimac, Tsun, Vaermina, Z'en, Zenithar | `PDV_QRM_MoonAndStar.csv` | machine-verified |
| Project AHO | `Dwarfsphere.esp` | 11 | 19 | 162 | Akatosh, Alkosh, Arkay, Auri-El, Azura, Baan Dar, Boethiah, Clavicus Vile, Dibella, Hermaeus Mora, Hircine, HoonDing, Julianos, Khenarthi, Kynareth, Kyne, Leki, Magnus, Malacath, Mara, Mehrunes Dagon, Mephala, Meridia, Molag Bal, Namira, Nocturnal, Rajhin, Sanguine, Sheogorath, Shor, Sithis, Stendarr, Stuhn, Syrabane, Talos, Trinimac, Tsun, Tu'whacca, Vaermina, Xarxes, Y'ffre, Z'en, Zenithar | `PDV_QRM_ProjectAHO.csv` | machine-verified |
| The Gray Cowl of Nocturnal | `Gray Fox Cowl.esm` | 7 | 10 | 75 | Akatosh, Alkosh, Arkay, Auri-El, Azura, Baan Dar, Boethiah, Hircine, HoonDing, Julianos, Khenarthi, Kynareth, Kyne, Leki, Magnus, Malacath, Mara, Mehrunes Dagon, Mephala, Meridia, Molag Bal, Namira, Nocturnal, Rajhin, Sheogorath, Shor, Sithis, Stendarr, Stuhn, Syrabane, Talos, Trinimac, Tsun, Tu'whacca, Vaermina, Xarxes, Y'ffre, Z'en, Zenithar | `PDV_QRM_GrayCowlOfNocturnal.csv` | machine-verified |
| The Sinister Seven | `The_Sinister_Seven.esp` | 1 | 2 | 28 | Alkosh, Auri-El, Baan Dar, Boethiah, Hircine, HoonDing, Kyne, Leki, Malacath, Mehrunes Dagon, Shor, Talos, Trinimac, Tsun | `PDV_QRM_SinisterSeven.csv` | machine-verified |
| Unslaad | `Unslaad.esm` | 4 | 4 | 7 | Akatosh, Alkosh, Baan Dar, Stuhn, Tsun | `PDV_QRM_Unslaad.csv` | runtime open |
| Vigilant | `Vigilant.esm` | 18 | 21 | 32 | Akatosh, Alkosh, Arkay, Azura, Baan Dar, Julianos, Khenarthi, Kynareth, Kyne, Molag Bal, Stendarr, Zenithar | `PDV_QRM_Vigilant.csv` | runtime open |
| Wyrmstooth | `Wyrmstooth.esp` | 6 | 12 | 76 | Alkosh, Arkay, Azura, Baan Dar, Boethiah, Clavicus Vile, Dibella, HoonDing, Khenarthi, Kynareth, Kyne, Leki, Malacath, Mara, Mephala, Meridia, Nocturnal, Rajhin, Shor, Stendarr, Stuhn, Syrabane, Talos, Trinimac, Tsun, Tu'whacca, Y'ffre, Z'en, Zenithar | `PDV_QRM_Wyrmstooth.csv` | runtime open |

Vigilant (21 cells) and Wyrmstooth (12 cells, 76 rows) are the two deepest
data-only patches in the hub.

#### Quest Expansions

| Mod | Depends on | Quests | Cells | Rows | Deities | Source CSV | Proof state |
|---|---|---:|---:|---:|---|---|---|
| College of Winterhold - Quest Expansion | `College Of Winterhold - Quest Expansion.esp` | 7 | 7 | 37 | Arkay, Auri-El, Hermaeus Mora, Julianos, Magnus, Malacath, Meridia, Stendarr, Syrabane, Tu'whacca, Xarxes, Y'ffre, Z'en, Zenithar | `PDV_QRM_CollegeQuestExpansion.csv` | runtime open |
| Ebony Blade Curse | `EbonyBladeCurse.esp` | 1 | 2 | 2 | Mephala | `PDV_QRM_EbonyBladeCurse.csv` | runtime open |
| Forsworn Conspiracy - Quest Expansion | `Forsworn Conspiracy Quest Expansion.esp` | 2 | 2 | 6 | Leki, Mara, Molag Bal, Stendarr, Stuhn | `PDV_QRM_ForswornConspiracyQE.csv` | runtime open |
| Ill Met by Moonlight - Dialogue Expansion | `CH_IMBMDialougeAddon.esp` | 1 | 1 | 1 | Hircine | `PDV_QRM_IllMetByMoonlightDialogue.csv` | machine-verified; **reconstructed source**; **split with core** |
| Infiltration - Quest Expansion | `Infiltration - Quest Expansion.esp` | 1 | 1 | 3 | Akatosh, Mara, Stendarr | `PDV_QRM_InfiltrationQE.csv` | runtime open |
| Nilheim - Misc Quest Expansion | `Nilheim_MiscQuestExpansion.esp` | 1 | 2 | 5 | Baan Dar, Malacath, Shor, Z'en, Zenithar | `PDV_QRM_NilheimQE.csv` | runtime open |
| Paarthurnax - Quest Expansion | `PaarthurnaxQuestExpansion.esp` | 1 | 1 | 5 | Kyne, Mara, Molag Bal, Stendarr, Stuhn | `PDV_QRM_PaarthurnaxQE.csv` | runtime open |
| Save the Icerunner | `SaveTheIcerunner.esp` | 1 | 5 | 41 | Akatosh, Baan Dar, Clavicus Vile, Khenarthi, Kynareth, Malacath, Mara, Mephala, Nocturnal, Rajhin, Stendarr, Stuhn, Trinimac, Z'en, Zenithar | `PDV_QRM_SaveTheIcerunner.csv` | runtime open |
| The Heart of Dibella - Quest Expansion | `The Heart Of Dibella - Quest Expansion.esp` | 1 | 1 | 2 | Dibella, Mara | `PDV_QRM_HeartOfDibellaQE.csv` | machine-verified; **reconstructed source**; **split with core** |
| The Whispering Door - Quest Expansion | `The Whispering Door - Quest Expansion.esp` | 1 | 1 | 2 | Mephala, Stendarr | `PDV_QRM_WhisperingDoorQE.csv` | runtime open; **split with core** |
| Thieves Guild Alternative Endings | `TG Alternative Endings.esp` | 1 | 2 | 17 | Akatosh, Baan Dar, Malacath, Mara, Nocturnal, Rajhin, Stendarr, Stuhn, Trinimac, Z'en, Zenithar | `PDV_QRM_TGAlternativeEndings.csv` | runtime open; **split with core** |

Four of these eleven are split with the core matrix -- see
[Split coverage](#split-coverage-part-core-part-patch).

#### Followers

| Mod | Depends on | Quests | Cells | Rows | Deities | Source CSV | Proof state |
|---|---|---:|---:|---:|---|---|---|
| M'rissi's Tails of Troubles | `MrissiTailOfTroubles.esp` | 2 | 3 | 10 | Akatosh, Dibella, Malacath, Mara, Stuhn, Trinimac, Z'en, Zenithar | `PDV_QRM_Mrissi.csv` | runtime open |
| Song of the Green - Auri | `018Auri.esp` | 1 | 1 | 3 | Kynareth, Kyne, Y'ffre | `PDV_QRM_Auri.csv` | runtime open |
| Thogra | `DK_Thogra.esp` | 3 | 4 | 24 | Akatosh, Dibella, HoonDing, Leki, Malacath, Mara, Molag Bal, Shor, Sithis, Stendarr, Stuhn, Talos, Trinimac, Tsun, Z'en | `PDV_QRM_Thogra.csv` | runtime open |
| Xelzaz | `BPUFXelzazFollower.esp` | 2 | 2 | 12 | Auri-El, Baan Dar, Hermaeus Mora, Julianos, Magnus, Mephala, Nocturnal, Rajhin, Sanguine, Sheogorath, Xarxes, Zenithar | `PDV_QRM_Xelzaz.csv` | runtime open |

#### Bardic Life

| Mod | Depends on | Quests | Cells | Rows | Deities | Source CSV | Proof state |
|---|---|---:|---:|---:|---|---|---|
| Bards Reborn - Student of Song | `BardsRebornStudentofSong.esp` | 2 | 2 | 2 | Dibella | `PDV_QRM_BardsRebornStudentOfSong.csv` | machine-verified; **reconstructed source** |
| Become a Bard | `BecomeABard.esp` | 2 | 2 | 2 | Dibella | `PDV_QRM_BecomeABard.csv` | runtime open; **reconstructed source** |

Both Bardic Life mods **also** appear in G6. The quest patch here covers the
career milestones (induction, completing the course of study); the Papyrus hook
covers the repeatable act of performing. Different mechanisms, same mods,
neither one redundant.

#### World Systems and Collections

| Mod | Depends on | Quests | Cells | Rows | Deities | Source CSV | Proof state |
|---|---|---:|---:|---:|---|---|---|
| Legacy of the Dragonborn | `LegacyoftheDragonborn.esm` | 3 | 3 | 19 | Arkay, Auri-El, Azura, Khenarthi, Malacath, Mara, Sheogorath, Stendarr, Stuhn, Syrabane, Trinimac, Tsun, Tu'whacca, Xarxes | `PDV_QRM_LegacyOfTheDragonborn.csv` | runtime open |

LotD reacts to the Trial of Trinimac, ending the Eye of Camlorn's curse, and
bringing peace to a Snow Elf ghost. Composite Ezra branches and linear relic
fetches are deliberately excluded, not missing.

---

## G2 -- Per-mod patches that ship a plugin

Five options. They divide into two mechanisms that look alike in the installer
and are nothing alike underneath.

### G2a -- The stage-manufacturing patches (3)

Once We Were Here, War's Folly and Whispers of the Depths react to mods whose
resolutions happen entirely in dialogue and **never fire a quest stage**. There
was nothing for a data-only channel to watch. So each patch:

1. **Overrides the host mod's own quest record** -- confirmed by direct readback:
   `PDV_Patch_WarsFolly.esp` carries `000001:War's Folly.esp` (`PHPreachingDialogueQuest`),
   `PDV_Patch_OnceWeWereHere.esp` carries `000002:Once We Were Here - Quest Mod.esp`
   (`OWWHMainQuest`), `PDV_Patch_SlaysManyBeasts.esp` carries
   `000001:Slays-Many-Beasts Quest Mod.esp` (`SMBMainQuest`).
2. **Re-lists the relevant DIAL/INFO** and attaches a TIF fragment to the chosen
   TopicInfo. Each fragment is one line: `GetOwningQuest().SetStage(N)`.
3. Ships a normal G1 channel that reacts to the stage the fragment just invented.

Because the quest is the host mod's own and is already running, no `.seq` is
needed and none ships. That is correct, not an omission.

| Mod | Depends on | Ships | Quests | Cells | Rows | Deities | Proof state |
|---|---|---|---:|---:|---:|---|---|
| Once We Were Here | `Once We Were Here - Quest Mod.esp` | ESP (1 QUST + 2 DIAL + 2 INFO), 2 TIF fragments (s60, s61) | 1 | 3 | 5 | Arkay, Auri-El, Mara, Stendarr | machine-verified |
| War's Folly | `War's Folly.esp` | ESP (1 QUST + 6 DIAL + 6 INFO), 6 TIF fragments (s20-s25) | 1 | 6 | 15 | Arkay, Boethiah, Kyne, Mara, Molag Bal, Stendarr, Talos, Tsun | machine-verified |
| Whispers of the Depths | `Slays-Many-Beasts Quest Mod.esp` | ESP (1 QUST + 1 DIAL + 1 INFO), 1 TIF fragment (s45) | 1 | 1 | 1 | Mara | machine-verified |

Cell counts do not always equal fragment counts. Once We Were Here reacts to
three cells (s50, s60, s61) from two fragments -- s50 is a stage the host mod
already fires on its own, so only s60 and s61 had to be manufactured. War's
Folly's six cells map 1:1 onto its six fragments.

Each of these installs **three** folders: `common\<Mod>` (channel),
`common\_Fragments\<Mod>` (the `.pex`), and `plugins\individual\<Mod>` (the ESP).
The other two G2 options install a single `common\<Mod>` folder that already
contains the ESP. Anything that infers "ships a plugin" from the channel folder
alone gets all five wrong.

### G2b -- The two that award nothing through quest stages (2)

Both ship an ESP and **have no channel and no award rows at all**. Their support
is real but reaches piety by a different route entirely. This is the case where
"the hub folder exists" is most misleading.

| Mod | Depends on | Ships | Mechanism | Deities | Proof state |
|---|---|---|---|---|---|
| Aetherium Forge Destroys Items | `Aetherium Forge Destroys Items.esp` | ESP (1 QUST, ESL-flagged) + `PDV_AFDIObserver.pex` + `PDV_Patch_AFDI.seq` | Papyrus observer quest polling 30 artifact-destroyed GlobalVariables on a 15s `OnUpdate`; routes via `ApplyExternalReaction` | see below | runtime open; save/load evidence open |
| Daedric Shrines AIO prayer activators | `man_DaedricShrines.esp` | ESP (11 ACTI, ESL-flagged) + `PDV_DaedricShrinesAIO_SWAP.ini` | BaseObjectSwapper -- see [G5](#g5--shrine--world-object-support-baseobjectswapper) | Azura, Hermaeus Mora, Hircine, Mehrunes Dagon, Mephala, Molag Bal, Namira, Peryite, Sanguine, Sheogorath, Vaermina | runtime open; placement evidence open |

**AFDI deity coverage**, read from `PDV_AFDIObserver.psc`:

- Destroying a Prince's artifact: `-` milestone to that Prince, plus `+` small to
  Stendarr and Syrabane. Owners recognised: Azura, Boethiah, Clavicus Vile,
  Hermaeus Mora, Hircine, Malacath, Mehrunes Dagon, Meridia, Mephala, Molag Bal,
  Namira, Nocturnal, Peryite, Sanguine, Sheogorath, Vaermina.
- Black Star: `+` milestone to **Azura** (the exception -- destroying it pleases her).
- Auriel's Bow / Auriel's Shield: `-` milestone to Auri-El.
- The Sithis artifact: `-` milestone to Sithis.
- Necromancer's Amulet: `+` small to Arkay and Stendarr.
- Jyggalag: deliberately classify-only, no award.

The observer baselines an existing save on first run (`PDV.AFDI.BaselineVersion`)
so a player who already destroyed artifacts gets no retroactive award.

> The observer's poll LIFECYCLE was rewritten by a concurrent session on 2026-08-08
> while this inventory was being compiled (resolve backoff, and retirement of the
> registration once all 30 slots are accounted for). The 30-slot artifact table and
> the deity routing above were diffed and are UNCHANGED. Re-read the script before
> citing its poll behaviour.

---

## G3 -- Covered by the CORE mod, no separate patch

`references/authoring/PDV_QuestReactionMatrix_Full.csv` -- **2144 rows across 157
distinct quest editor ids** -- ships inside base `Devotion.esp`. It is generated
by `tools/pdv_quest_tranche_merge.mjs` from the `PDV_QuestReactionMatrix_Tranche*`
files; edit a tranche, never `Full.csv`.

Nobody installs anything for any of this. It is why the PatchHub is a small part
of the support picture and not the whole of it.

| Kind | Editor ids | How identified |
|---|---:|---|
| Vanilla Skyrim | 101 | no `cc*` / `DLC*` prefix |
| Dawnguard / Dragonborn (`DLC1*`, `DLC2*`) | 52 | prefix |
| Creation Club | 4 | `cc<studio>SSE<nnn>` prefix |

Prefix is a **classification, not a readback**: an editor id names the quest, not
the file that defines it. It is reliable here because Bethesda's own prefixes are
consistent, but do not cite it as plugin provenance.

### Creation Club quests in core

| Editor id | Quest | Stage | Rows | Deities |
|---|---|---:|---:|---|
| `ccASVSSE001_QuestE` | Trueflame | 100 | 2 | Malacath, Zenithar |
| `ccBGSSSE020_Quest` | The Gray Cowl of Nocturnal | 100 | 1 | Nocturnal |
| `ccBGSSSE067_Quest2` | The Consequences | 1000 | 3 | Akatosh, Mehrunes Dagon, Stendarr |
| `ccMTYSSE001_Quest` | The Pilgrim's Path | 100 | 9 | Akatosh, Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Talos, Zenithar |

Two more CC integrations are Papyrus hooks rather than matrix rows -- see G6.

### Quest-expansion mods covered by core alone

The important case. These mods extend a **vanilla** quest, so core already
reacts to the vanilla editor id and the expansion's own new stages were authored
straight into the core matrix (via `PDV_QuestReactionMatrix_Tranche6_CompatCore.csv`).
**There is no hub option for any of them and none is needed.**

| Editor id | Quest | Stages in core | Rows | What the QE stage is |
|---|---|---|---:|---|
| `DA06` | The Cursed Tribe (+ QE ghost variant) | 50, 110, 200, 210 | 19 | s210 lifts the Largashbur ghost-curse by magic; +Malacath indirect. Vanilla s200 Champion stays Daedric-sender-owned. (s50/s110 are vanilla beats core already covered.) |
| `DA10` | The House of Horrors (+ QE destroy altar) | 200, 210 | 17 | s210 helps Tyranus destroy Molag Bal's altar: -Molag Bal milestone, +Stendarr small. Vanilla s200 (serve Molag Bal) stays sender-owned. |
| `DA13` | The Only Cure (+ QE refuse / destroy altar) | 100, 101, 102 | 5 | s101 refuses Peryite's bargain; s102 destroys the altar. Vanilla s100 stays sender-owned. |

The pattern in all three: **the vanilla stage keeps its original owner, and the
QE stage is a separate row.** A player without the expansion installed simply
never reaches the QE stage; nothing misfires.

### Split coverage (part core, part patch)

The most confusing case in the inventory, and the reason the G1/G3 boundary is
not a clean per-mod line. For these four mods **some of the support ships in core
and some ships in a hub patch**, and reading either source alone gives a wrong
answer about what is covered.

| Mod | Core covers | Hub patch covers | Collision? |
|---|---|---|---|
| **The Heart of Dibella - QE** (`The Heart Of Dibella - Quest Expansion.esp`) | vanilla `T01` *The Heart of Dibella* s200, 9 rows | its own new quest `T01_GiveLetter` s0, 2 rows (Dibella, Mara) | none -- different quest record |
| **Ill Met by Moonlight - Dialogue Expansion** (`CH_IMBMDialougeAddon.esp`) | vanilla `DA05` *Ill Met By Moonlight* s10/s100/s105, 15 rows | its own new quest `CH_TotemReturnQuest` s10, 1 row (Hircine) | none -- different quest record |
| **The Whispering Door - QE** (`The Whispering Door - Quest Expansion.esp`) | vanilla `DA08` *The Whispering Door* s25, s60, 12 rows | the **same** editor id `DA08` at s45, 2 rows (Mephala, Stendarr) | **checked, none** -- s45 is disjoint from s25/s60 |
| **Thieves Guild Alternative Endings** (`TG Alternative Endings.esp`) | vanilla `TG09` *Darkness Returns* s10/s30/s200, 7 rows | the **same** editor id `TG09` at s201 and s202, 17 rows | **checked, none** -- 201/202 disjoint from 10/30/200 |

**Why the collision check matters.** `ResolveQuestReactionCellFile` checks the
core matrix **first** and takes the first hit. A hub cell that duplicates a
`(formid|stage)` core already owns would be silently dead -- the patch would
install, register, and never fire, with nothing in the log. The bottom two rows
share an editor id with core and are the ones exposed to this; both are currently
clean. `--check` re-runs this comparison, so a future tranche that adds `DA08`
s45 or `TG09` s201 to core turns the gate red instead of silently killing a patch.

---

## G4 -- Item-keyword support (KID)

`mod-data/SKSE/Plugins/KeywordItemDistributor/PDV_GreenPact_KID.ini`, shipped in
base Devotion. No patch, no user action.

Mod-added food is tagged here rather than added to `PDV_FLST_GreenPact_*` because
a FormList entry pointing at another plugin's record makes that plugin a **master
of Devotion.esp**, and everyone without it gets a missing-master failure. KID
re-applies at every startup with no master dependency and no save footprint. The
routing code accepts either path (`FormMatchesListOrKeyword`); vanilla and DLC
food stays in the FormLists.

**One live rule:**

| Keyword | Form type | Filter | Items | Aimed at |
|---|---|---|---:|---|
| `PDV_KW_GreenPact_Meat` | `Potion` | item **name** | 9 | Requiem + Requiem - Food and Beverages Redone |

Names: Torn Flesh, Strange Meat, Skeever Meat, Wrothgar Tartare, Fox Meat, Bear
Meat, Mammoth Meat, Sabrecat Meat, Troll Meat. Eating any of these **rewards** a
pact-keeping Bosmer -- meat is permitted; it is eating plants that breaks the
Green Pact.

Two facts worth not re-deriving:

- **Torn Flesh and Strange Meat are the same record** (`284894:Requiem.esp`).
  Base Requiem calls it Strange Meat; Food and Beverages Redone renames it. Both
  names are listed so the rule holds either way.
- **These match by name, not FormID/EditorID, on purpose.** For the `Potion` type
  KID resolves a Form filter against the item's *magic effects*, not the item's
  own FormID, so `0x284894~Requiem.esp` would match nothing. Name matching is
  also self-correcting: if another mod adds its own "Bear Meat", tagging it as
  meat is still right.

Safe when Requiem is absent -- KID matches nothing.

**Four declared-but-empty lanes:** `PDV_KW_GreenPact_Plant`,
`PDV_KW_GreenPact_Fungi`, `PDV_KW_GreenPact_Egg`, `PDV_KW_GreenPact_Insect`.
They exist as commented templates only. Nothing is distributed for them; a mod
whose food falls in one of those families is **not** currently supported.

The ini's comment block is load-bearing -- the 2026-08-06 packaging archive
shipped a rule superset with the reasoning stripped and nothing flagged it. If
you regenerate the file, carry the comments forward.

---

## G5 -- Shrine / world-object support (BaseObjectSwapper)

`PDV_DaedricShrinesAIO_SWAP.ini`, shipped inside the Daedric Shrines AIO G2
patch. **One ini, eleven swaps.**

Daedric Shrines AIO's Prince statues are `STAT` records -- decorative meshes with
no activator, no script and no spell, so there is nothing to pray at. A definitive
2026-06-15 scan confirmed zero of the sixteen Princes had a clean route anchor
(the only `ACTI`s are Nocturnal's two, which carry `TempleBlessingScript` and
must not be replaced). BaseObjectSwapper swaps the decorative statue for an
opt-in Devotion prayer activator at runtime, with no ESP edit to the source mod.

The eleven activators, read back from `PDV_Patch_DaedricShrinesAIO.esp`:

| FormID | Editor id | Prince |
|---|---|---|
| `000800` | `PDV_ACTI_ShrinePrayer_Azura` | Azura |
| `000801` | `PDV_ACTI_ShrinePrayer_Vaermina` | Vaermina |
| `000802` | `PDV_ACTI_ShrinePrayer_MolagBal` | Molag Bal |
| `000803` | `PDV_ACTI_ShrinePrayer_Mephala` | Mephala |
| `000804` | `PDV_ACTI_ShrinePrayer_MehrunesDagon` | Mehrunes Dagon |
| `000805` | `PDV_ACTI_ShrinePrayer_Sheogorath` | Sheogorath |
| `000806` | `PDV_ACTI_ShrinePrayer_Namira` | Namira |
| `000807` | `PDV_ACTI_ShrinePrayer_Sanguine` | Sanguine |
| `000808` | `PDV_ACTI_ShrinePrayer_HermaeusMora` | Hermaeus Mora |
| `000809` | `PDV_ACTI_ShrinePrayer_Hircine` | Hircine |
| `00080A` | `PDV_ACTI_ShrinePrayer_Peryite` | Peryite |

Ten swap sources are `man_DaedricShrines.esp` records; one (`0x0C5999`) is a
`Skyrim.esm` record. Five Princes have no swap: Boethiah, Clavicus Vile, Malacath,
Meridia, Nocturnal.

**Runtime and placement evidence are open.** The manifest says so and nothing has
superseded it.

> An identical-content copy of this ini exists at
> `dist/PDV_AuthoriaARR_Compatibility/PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`.
> It is a legacy package artefact and does **not** ship through the PatchHub.
> The copy under `plugins/individual/DaedricShrinesAIO/` is staging; the FOMOD
> installs the `common/DaedricShrinesAIO/` one.

---

## G6 -- Papyrus activity hooks (no quest stage)

Support wired straight into the core scripts. **No patch, no channel, no user
action** -- every one is guarded behind `Game.IsPluginInstalled` /
`Game.GetModByName`, so an absent mod is a clean no-op with no Papyrus error.

Seven external plugins are referenced by name across `live-source/Scripts/Source`:

| Plugin | Mod | Where | What it does | Deities |
|---|---|---|---|---|
| `BecomeABard.esp` | Become a Bard | `PDV_PlayerEvents.psc:2972-2974` | Reads `IsPlaying` (`0x51223`) and the tavern-count FormList (`0x65073`). A performance ending in a tavern not yet credited today is the "playing edge". | Dibella |
| `SkyrimsGotTalent-Bards.esp` | Skyrim's Got Talent | `PDV_PlayerEvents.psc:2978-2982` | Reads lute/flute/drum expertise globals and the ovation flag; the summed **delta** since the last tick is the performance quality. | Dibella |
| `SunHelmSurvival.esp` | SunHelm Survival | `PDV__ManagerQuest.psc:16270-16276` | Hunger/thirst/cold/fatigue globals feed a bounded severity | *none -- see below* |
| `ccQDRSSE001-SurvivalMode.esl` | CC Survival Mode | `PDV__ManagerQuest.psc:16262-16267` | Hunger/cold/exhaustion globals feed the same severity | *none -- see below* |
| `ccbgssse025-advdsgs.esm` | CC Saints & Seducers | `PDV__ManagerQuest.psc:16393-16395` | `GetStageDone(200)` on Restoring Order records a controlled Sheogorath signal, once ever | Sheogorath |
| `ccbgssse001-fish.esm` | CC Fishing | `PDV__ManagerQuest.psc:16398-16400` | Rising edge on the `IsFishing` global awards 0.5 piety with a daily repeat multiplier | Kyne |
| `RaceCompatibility.esm` | RaceCompatibility | `PDV_Origin.psc:69` | Maps an unrecognised custom race to a vanilla profile via `ActorProxy` keywords | *none -- see below* |

### The bard hook, in detail

The one the design leans on hardest, and the only G6 entry whose mods also have
G1 patches.

`BardPerformancePollTick` runs a two-state cadence: 5 s while a performance is
live, 15 s after two quiet ticks. It computes `expertiseDelta` (summed lute +
flute + drum change) and `performanceEnded` (`IsPlaying` 1 -> 0), clamps quality
to 1-8, applies a per-tavern daily cap, and routes through
`PDV_EventBus.RouteBardPerformance` to `HandleBardPerformance`, which awards
`SIGNAL_PATRON_CIVIC_FAVOR` to **Dibella** scaled by
`(0.75 + quality * 0.125)`, `+0.25` for an ovation, times the daily repeat
multiplier.

It is a poll rather than an equip/unequip gate on purpose: both mods drive
performances through their own dialogue and quest machinery, and the only signals
visible from script are four GlobalVariables. A hard gate would have to guess
which forms count as an instrument across two mods, and a wrong guess fails
**silently** -- bard piety just stops, with nothing in the log.

A 12-second anti-double-route stamp guards the route. That stamp is cleared on
every load because `Utility.GetCurrentRealTime()` counts seconds since the
application started and resets on relaunch, while the stamp itself persists in
the save.

### Three hooks that award no piety

Worth stating plainly, because "supported" reads as "gives piety" and here it
does not:

- **SunHelm Survival** and **CC Survival Mode** are *context only*. A detected
  survival mod's needs state scales already-earned piety as a bounded multiplier,
  and only **downward** (`SURVIVAL_DAMP_PER_SEVERITY = 0.0267`), as a mild
  anti-farm under hardship. Never a piety source. Toggleable via
  `PDV.Compat.SurvivalContextEnabled`; both feed one shared severity, so
  installing both does not double the damping.
- **RaceCompatibility** is a race-resolution layer, not content. It maps an
  unrecognised custom race to one of the ten vanilla indices via `ActorProxy`
  keywords, after an author/user override map is checked first. Without it a
  custom-race player falls back to the Imperial profile with a notification.
  Toggleable via `PDV.Compat.CustomRaceMapping`.

CC content is toggleable via `PDV.Compat.CCContentEnabled`, and
`GetCCContentStatusLine` surfaces which of Saints & Seducers / Fishing was
detected.

---

## Known gaps and honest caveats

1. **Runtime proof is open across most of the hub.** 33 of the 46 options carry
   "runtime evidence remains open" in their own manifest description. Machine
   verification means the channel parses and the cells exist -- not that a stage
   fires in game and piety lands. Do not report hub coverage as proven.
2. **Five source CSVs were reconstructed on 2026-08-08** from the shipped
   channels, because the originals were never tracked in any branch:
   `AboveAllElse`, `BardsRebornStudentOfSong`, `BecomeABard`, `HeartOfDibellaQE`,
   `IllMetByMoonlightDialogue`. Deity, valence, intensity, magnitude and tag are
   verbatim from the channel; `editor_id` and `formid` were resolved by direct
   houseCARL readback; `quest_name` is the record's own Name field. **The
   `outcome` prose is authored, not recovered.** Each row's `citation` says so.
3. **Two G2 options award nothing through quest stages** (AFDI,
   DaedricShrinesAIO). They have hub folders and ESPs and no channel. Counting
   hub folders as "mods with quest reactions" overcounts by two.
4. **`--check` gates counts, not correctness.** It proves this doc's arithmetic
   still matches the shipped files. It does not prove a deity assignment is
   right, that a stage exists in the target mod, or that anything fires.
5. **The core matrix has no `formid` column.** Plugin provenance for a G3 row is
   inferred from the editor id prefix. Where that matters, read the record.
6. **This doc is derived from the git work tree.** The compile toolchain reads
   the MO2 tree. If the two have drifted, G6 (which reads `live-source/`) is the
   section most likely to lag; sync before treating it as current.
7. **Four Green Pact KID lanes are declared and empty.** Plant, Fungi, Egg and
   Insect distribute nothing today.
8. **Five Daedric Princes have no shrine swap:** Boethiah, Clavicus Vile,
   Malacath, Meridia, Nocturnal. Nocturnal's are the two `TempleBlessingScript`
   activators Devotion must not replace; the others are STAT-only or
   worldspace-placement only.

---

## Where the sources live

| Source | Path | Authority for |
|---|---|---|
| PatchHub manifest | `references/authoring/PDV_QuestPatchHub.manifest.json` | The 46 options: name, dependency, description, folders, category |
| FOMOD installer | `dist/PDV_QuestModPatches_FOMOD/fomod/ModuleConfig.xml` | What each option actually installs, and its dependency gate |
| Shipped channels | `dist/PDV_QuestModPatches_FOMOD/common/<Mod>/SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/*.json` | What a patch really reacts to and awards |
| Per-mod source CSVs | `references/authoring/patches/PDV_QRM_*.csv` | Authoring intent and citations (44 files; slug does not always match the hub folder) |
| Core matrix | `references/authoring/PDV_QuestReactionMatrix_Full.csv` | G3. **Generated** -- edit the `Tranche*` files |
| KID | `mod-data/SKSE/Plugins/KeywordItemDistributor/PDV_GreenPact_KID.ini` | G4 |
| BOS swap | `dist/PDV_QuestModPatches_FOMOD/common/DaedricShrinesAIO/SKSE/Plugins/BaseObjectSwapper/PDV_DaedricShrinesAIO_SWAP.ini` | G5 |
| Papyrus | `live-source/Scripts/Source/{PDV_PlayerEvents,PDV__ManagerQuest,PDV_Origin}.psc` | G6 |
| Packaging decisions | `references/authoring/PDV_ModPackaging_StateAuthority.md` | Which options are experimental vs supported |
