# PDV Phase 21 -- Authoria (ARR Test) Modlist Review + To-Do (2026-07-16)

Status: static plugin-level review (houseCARL readback) of the CURRENT Authoria
instance at `D:\Wabbajack\modlists\ARR Test`. Supersedes and replaces the deleted
Archon-era `PDV_Phase21_ARR_ConflictDossier.md` and
`PDV_Phase21_ARR_SmokeChecklist_2026-06-16.md`. Companion to
`PDV_Phase21_ARR_ExtensionMap.md` (still-valid authored ARR matrix data: 24 cells).

Proof boundary: everything here is names-plus-records static evidence. No runtime
proof is claimed; every to-do that lands a hook carries "runtime-verify pending".

## Instance / profile

- Instance: `D:\Wabbajack\modlists\ARR Test` (3,719 mod folders).
- Profiles: `Authoria - Requiem Reforged - Main Profile` (3,434 enabled) and
  `- NSFW Profile`. houseCARL auto-detected the NSFW profile as MO2-active during
  this review; the religion-relevant plugin set (Apostasy, Requiem, all quest mods
  below) is identical in both, so record winners resolve the same. Re-verify
  against Main Profile if MO2's active profile changes.
- No Wintersun, no Pilgrim, no Archon: Devotion will be the SOLE player-religion
  system in this list.

## Delta vs the June 2026 ARR pass

1. **Archon - Faiths of Tamriel is GONE.** The 15-plugin removal set and the
   local "PDV Test profile with Archon disabled" workflow are obsolete. No
   religion overhaul needs replacing.
2. **Apostasy Framework is new** (`Apostasy Framework.esp`, enabled, Nexus id
   160033 by aljoxo). Verdict: **coexists, no patch needed.** It is a modder's
   RESOURCE (custom actor values, 75 KYWD, 37 MGEF, 16 PERK, 7 SPEL, 1 QUST,
   1 SM node; vanilla masters only, no shrine/quest overrides). It is a
   dependency for the author's other mods, not a religion system.
3. **All 14 shrine-blessing SPELs resolve to `Requiem.esp`** (override depth 2:
   vanilla + Requiem only -- verified 2026-07-16 via batch readback of every
   FormID in `PDV_ShrineBlessingNeutralization.manifest.json`). Devotion's
   neutralization manifest applies UNCHANGED; Devotion just needs to win load
   order over Requiem on those records, as before.
4. **Kynareth Replaces Talos - Civil War Consequence.esp** is a placement-level
   swap (15 placed refs, 2 cells, 1 new SPEL + 3 MGEF, civil-war conditioned).
   It does NOT override the vanilla Talos shrine SPEL/ACTI base records, so the
   shrine-to-deity map survives. Its one NEW blessing spell is un-neutralized
   (see TODO-11).

## 1. Quest expansions overriding hooked vanilla quests (S2) -- ALL SAFE

Hook baseline: DA05 s100/s105, DA06 s200(+s210), DA08 s25/s60, DA10 s200(+s210),
DA11 s100/s250/s500, DA13 s100(+s101/s102), DB01 s200, T01 s200
(`PDV_QuestReactionMatrix_Full.csv`; DA06/DA08 also hard-registered in
`PDV_PlayerEvents.psc:1241/:1270`).

| Mod / plugin | Hooked quest | Verdict |
|---|---|---|
| House of Horrors QE (`HouseOfHorrorsQuestExpansion.esp`) | DA10, is winner | SAFE - s200/s210/s500 present |
| The Only Cure QE (`TheOnlyCureQuestExpansion.esp`) | DA13, winner = `Authoria - Master Patch - USSEP Dialogue Merge.esp` | SAFE - s100/s101/s102 present in winner |
| Cursed Tribe QE (`The Cursed Tribe - Quest Expansion.esp`) | DA06, is winner | SAFE - s200/s210 present (new terminals 220/230/255) |
| Whispering Door QE (`The Whispering Door - Quest Expansion.esp`) | DA08, is winner | SAFE - s25/s60 present |
| Mephala's Curse addon (`EbonyBladeCurse.esp` family) | does not touch DA08 hooks | SAFE; new quests below |
| Heart of Dibella QE (`The Heart Of Dibella - Quest Expansion.esp`) | T01, winner = `Authoria - Output - Synthesis Gameplay.esp` | SAFE - s200 present in winner |
| Ill Met by Moonlight DE (`CH_IMBMDialougeAddon.esp`) | DA05, is winner | SAFE - s100/s105 present |
| Taste of Death addon (`TasteOfDeath_Addon_*.esp`) | does not touch DA11 | SAFE; new quests below |
| Innocence Lost QE (`Innocence Lost - Quest Expansion.esp`) | DB01, is winner | SAFE - s200 present; NEW alternate terminals 198/199/201 bypass s200 (TODO-2) |
| Forsworn Conspiracy QE | MS01/MS02 only - not hooked | SAFE; new quests below |
| Paarthurnax QE (`PaarthurnaxQuestExpansion.esp`) | MQPaarthurnax - not hooked | SAFE |
| Seeking The Cure (`RisingAtDawnQuestOverhaul.esp`) | VC01 - not hooked | SAFE; cure-lane candidate (TODO-3) |

Caveat: verdicts compared stage indices on the true winners, not per-stage log
text. Renumbering is ruled out; reworded same-number terminals still fire.

## 2. New quest-mod matrix candidates (S1) -- second ARR matrix tranche

Existing coverage (do not re-add): Vigilant, Glenmoril, Unslaad, Olenveld,
Forgotten City, SEC Saints & Seducers, DAc0da, Ebony Blade curse.

### High confidence (author rows next tranche)
| Mod | Quest (FormID) | Deity / row sketch |
|---|---|---|
| Wyrmstooth | `WTBarrowOfTheWyrm` 028F01:Wyrmstooth.esp | Kyne/Akatosh - slay Vulthurkrah, milestone |
| Wyrmstooth | `WTDragonHunt` 022528, `WTBountyVampire` 4B9DF0, `WTBountyWarlock` 4B9DEF, `WTKillThalmor` 3943A0 | Kyne (hunt), Arkay/Stendarr (undead/warlock), Talos (Thalmor); repeatable - needs anti-farm cap |
| CC The Cause | `ccBGSSSE067_Quest` 06BFC1:ccbgssse067-daedinv.esm (+`_Quest2` 19952A) | anti-Mehrunes Dagon / Akatosh-aligned, milestone |
| CC Ghosts of the Tribunal | `ccASVSSE001_Quest` 000CC3 + relic quests A-E (000CA0/000F19/000F1A/00117A/0990EF) | Tribunal (Dunmer lane), main milestone + small per-relic |
| CC Divine Crusader | `ccMTYSSE001_Quest` 000865:ccmtysse001-knightsofthenine.esl | Nine Divines broad/pantheon milestone |
| CC Gray Cowl Returns | `ccBGSSSE020_Quest` 00080F:ccbgssse020-graycowl.esl | Nocturnal milestone (was already in smoke runbook as test target) |
| Mephala's Curse | `DA08MephalaHunt` 000807:EbonyBladeCurse.esp (+`DA08MephalaSpider` 000800:Whispering_Door_Expansion_Addon.esp) | Mephala serve/keep-secret rows |
| Taste of Death addon | `madNamiraAddonQuest` 000050 (+Jail01/02 000051/000052, Extort 000670, all :TasteOfDeath_Addon_Dialogue.esp) | Namira cannibal-coven continuation |
| Ill Met by Moonlight DE | `CH_TotemReturnQuest` 000026:CH_IMBMDialougeAddon.esp | Hircine small (totem return) |
| Heart of Dibella QE | `T01_GiveLetter` 000816 | Dibella/Mara small (comfort the parents) |
| Forsworn Conspiracy QE | `aaMS01NewTrialClear` 000909 (best single row of the aaMS01/aaMS02 set) | Stendarr/Talos uphold-justice |
| Siege at Icemoth | `HYORdunIcemothQST` 5A079F (+Trench 07F08F, Sanctum 097057, BlackBook 59F97E) | Arkay (undead siege), Hermaeus Mora (Black Book) |
| Hunt for the Spectre | `HSHuntForSpectreQuest` 000800:Hunt for the Spectre.esp | Arkay (lay spirit to rest) |
| Calling the Watchmaker | `SMQuest` 000892:Sithis Mod - Lovecraftian Inspired Quest.esp | Sithis/void milestone |
| M'rissi's Tails of Troubles | `MRTstage8` 30DCA3:MrissiTailOfTroubles.esp (bad branch `MRTstage3Bad` 554AD5) | Khajiit lane (Riddle'Thar/S'rendarr compassion) |
| Gift of Saturalia | `Sat_TheGiftofSaturalia` 000D61 + kindness subs (0008AA/000963/0009A4/0009D2/0008D3) | Mara (charity) main + smalls |
| Above all Else | `DBQDarbalagQuest` 000002:Darbalag - Quest Mod.esp | Hermaeus Mora (verify resist-vs-serve split) |

### Verify-theme-first -- RESOLVED 2026-07-16 (all verified + shipped)

Every quest below was verified (mostly Tier A in-plugin stage text), ruled by
the owner, and authored. See "Per-mod patch packages" below. Verification
findings that changed the answer:

- Sirenroot `EVGSirenrootQuest` 026BC5:evgSIRENROOT.esm - Tier A: only ONE
  CompleteQuest stage (s150); the "multiple endings" are not stage-split.
  Ruled Ayleid=Aldmeri kin -> elven pantheon rows. SHIPPED (10 rows).
- The Rot Below `CJ03RotBelowMQ` 02DA43:CJ03Elroy.esp - Tier A: **Namira named
  in the stage text** ("Namira's plan has been foiled"); Peryite ruled out. Two
  real terminals (s120 kill / s130 spare). SHIPPED (18 rows).
- Frozen Heart `ksws07MainQuest` 002086:ksws07_quest.esm - Tier A: THREE
  terminals (s1300 cure / s10000 refuse / s20100 kill); no deity named, but the
  woman is a **Snow Elf** -> Auri-El lens. SHIPPED (11 rows).
- Depths of the Soul `DDPikeQuest` 000000:Dungeon Delver Mod.esp - Tier A+C:
  NOT a soul/undead quest; it is a **merchant-recruitment** quest (the title is
  marketing). Zenithar only. SHIPPED (1 row).
- Baba Yaga `ksws03_main_quest` 000AA2:ksws03_quest.esp - Tier A: plain witch
  rescue, no Hircine/Namira basis. Mara only. SHIPPED (1 row).
- Bark and Bite `TCMSheoTreeQuest` 000009:Tree Contract Mod.esp - Tier A: two
  terminals (s25 kill Frija/wolves freed, s45 spare/wolves bound). SHIPPED (5).
- Once We Were Here `OWWHMainQuest` 000002 - Tier A: stages are timers, but the
  dialogue holds a real moral fork (Falmer redeemable vs irreparable) -> new
  dialogue-hook stages s60/s61 + terminal s50. SHIPPED (5 rows + ESP).
- Before the End `PMAradellQuest` 000007:PrisonerMod.esp - Tier A+C: the moral
  act is s5 (stayed with the condemned man), not the terminal. SHIPPED (2 rows).
- Whispers of the Depths `SMBMainQuest` 000001 - Tier A+C: a monster-story
  anthology, NOT Mora/Hist. Rescued via the dialogue lane: condolence beat
  -> new s45. SHIPPED (1 row + ESP).
- War's Folly `PHPreachingDialogueQuest` 000001 - Tier A: confirmed NO usable
  stage arc (2 stages, one flat "Conversation done"). Rescued via the dialogue
  lane: six player stances -> new stages s20-s25. SHIPPED (15 rows + ESP).
- Innocence Lost QE terminals 198/199/201 - Tier A on the winner: s198 is the
  player's merciful act (Grelod imprisoned); 199/201 are her later off-screen
  murder by other hands (NOT the player's act -> no rows). s198 rowed to CORE.
  SHIPPED (4 rows). NOTE 2026-08-06: these were originally hand-appended to the
  GENERATED `PDV_QuestReactionMatrix_Full.csv`, which no tranche could reproduce
  -- the next `pdv_quest_tranche_merge` run would have silently dropped all four.
  They now live in `PDV_QuestReactionMatrix_Reconciliation_2026-08-06.csv` and
  `pdv_quest_tranche_merge.mjs --check` fails on any recurrence. Never hand-edit
  Full.csv; add rows to a tranche or reconciliation source.

### No rows possible (verified)
- Wildwood Echoes: installed plugin is 24 SNDR (soundscape), zero quests.
- Finding Velehk Sain: zero quests (activator-driven treasure hunt).
- Storm the Thalmor Embassy: only overrides vanilla MQ201, no new quest.
- A Friend in Mead: main `WDSMainQuest` weak deity relevance - skip unless the
  Redguard lane wants HoonDing flavor; its WotD patch plugin is empty.

## 3. Bard / performance activity signals (new curated-signal family)

No SKSE APIs anywhere in the suite; all Papyrus-visible. Live script sources are
in `Authoria - Master Patch - Bards Reborn Tweaks.esp`'s loose files (the vanilla
mods' scripts are overridden -- hook against the Authoria copies).

- **Become a Bard** (`BecomeABard.esp`): richest surface.
  `_LP_BardIsPlaying` 051223 global 1->0 edge = performance completed;
  `_LP_BardTavernCounts` FLST 065073 (25 per-tavern count globals) = natural
  anti-farm key; `_LP_BardSkill` 027BFA (0-100) = mastery axis;
  `_LP_BardTavernQuest` 027C20 s100 and `_LP_BardJarlQuest` 027C1F s100 =
  milestone rows.
- **Skyrim's Got Talent** (`SkyrimsGotTalent-Bards.esp`): per-instrument
  expertise globals `_Talent_Lute/Flute/Drum` 000D62/000D61/000D63; delta 1-8 at
  performance end encodes quality; `_Talent_ReceiveOvation` 00E0CA = excellence
  bonus flag. **Bardic Speech's `BSP_BardSpeech.psc`** (ReferenceAlias, 5s
  single-update poll on the expertise sum) is a proven, copyable template for
  exactly this hook.
- **Bards Reborn** (`BardsRebornStudentofSong.esp`): milestone-only --
  `BardsRebornBardsCollegeQuest` 06673B and `BardsRebornPostInduction` 182293
  completion = one-time college milestones. Repeatables come via BaB/SGT.
- Deity mapping: Dibella (art/performance) primary; racial-culture secondary
  lanes per existing curated-signal doctrine. Every pulse behind Devotion's
  daily anti-farm budget regardless of SGT's own expertise cap.
- BA_BardSongs (SNDR only) and the lute mesh mods: no signal surface.

## 4. Supporting surfaces (from the full-list sweep)

- **Daedric Shrines AIO (Xtudo) + patch web** incl. `Wymrstooth - Daedric
  Shrines` (placement patch: 6 placed refs into Wyrmstooth worldspace) and a new
  **Jyggalag shrine** mod. Existing BOS STAT->ACTI swap covers 11 Princes;
  re-verify swap INI against this instance's statue records and decide whether
  the Wyrmstooth placements get prayer credit (same base forms -> free; new
  forms -> add swap lines).
- **JS Shrines of the Divines** (mesh/activator replacer) and **CC Survival -
  Disable Shrine Menu**: verify shrine ACTI records and blessing-menu behavior
  still route through the surfaces Devotion owns.
- **Vampirism/lycanthropy**: Sacrilege + Manbeast + Requiem VampireCollection.
  ARR curse theology is keyed Requiem-native per the dossier; confirm state
  detection against Sacrilege/Manbeast state tracks in smoke.
- **Alt-start**: Alternate Perspective + Starting Choices (+ `Authoria -
  Initialization Sequence`). Devotion startup flow must be smoke-tested from an
  Alternate Perspective start specifically.
- **Context-only** (never raw piety): SunHelm, Frostfall, Campfire, CC Survival;
  Ryn's Standing Stones + Requiem Birthsigns Redone; Moons And Stars SKSE
  (moon-visual only -- Khajiit lunar logic stays PDV-internal); statue/temple
  beautification (FYX Mara temple, Dibella statues, Gildergreen, etc.).

## Per-mod patch packages (BUILT 2026-07-16)

New lane: instead of folding these into the list-level Authoria ESP, each
supported mod ships as its own self-contained patch, distributed by ONE FOMOD.

Architecture:
- **Loader**: `PDV_PlayerEvents.RegisterQuestReactionChannelFolder()` scans
  `SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/` and registers every
  JSON as a matrix channel (cached to `PDV.QR.ChannelFiles`);
  `PDV__ManagerQuest.ResolveQuestReactionCellFile()` resolves core -> legacy ARR
  -> per-mod channels, first hit wins. Core + legacy ARR channels unchanged.
- **Dialogue-hook patches**: the patch ESP overrides the target QUST to ADD
  outcome stages and overrides the chosen INFO to attach a TIF end-fragment
  calling `SetStage` (the QE mods' own pattern). Rows are then ordinary
  `FormID|stage` matrix cells -- no new curated signals, no reserved-signal
  entries, no gate changes. Patch ESPs master ONLY the target mod (not
  Devotion.esp), so they are inert-but-harmless without Devotion.
- **Plugin lightness**: ESL-flagged .esp (not true .esl -- an ESM-flagged file
  would load before the mod it overrides and lose every conflict). 7 of the 10
  patches carry NO plugin at all.

| Patch | Target plugin | ESP | Channel rows/keys |
|---|---|---|---|
| Sirenroot | evgSIRENROOT.esm | no | 10 / 1 |
| The Rot Below | CJ03Elroy.esp | no | 18 / 2 |
| The Frozen Heart | ksws07_quest.esm | no | 11 / 3 |
| Depths of the Soul | Dungeon Delver Mod.esp | no | 1 / 1 |
| Baba Yaga and the Labyrinth | ksws03_quest.esp | no | 1 / 1 |
| Bark and Bite | Tree Contract Mod.esp | no | 5 / 2 |
| Before the End | PrisonerMod.esp | no | 2 / 1 |
| War's Folly | War's Folly.esp | yes (ESL-flagged) | 15 / 6 |
| Once We Were Here | Once We Were Here - Quest Mod.esp | yes (ESL-flagged) | 5 / 3 |
| Whispers of the Depths | Slays-Many-Beasts Quest Mod.esp | yes (ESL-flagged) | 1 / 1 |

### Authoria all-in-one lane (added 2026-07-16)

For Authoria specifically, the three dialogue-hook plugins collapse into ONE:
`PDV_Patch_Authoria_QuestMods.esp` (ESL-flagged, 21 records, masters War's
Folly + Once We Were Here + Slays-Many-Beasts), shipped with all 9 fragments and
all 10 channels.

Why the individual lane still exists: a patch plugin masters every mod it
touches, and a missing master stops the game loading -- so a combined plugin is
only installable by someone who has ALL its targets. Authoria guarantees them;
an arbitrary Nexus load order does not. Hence two lanes, mutually exclusive
(installing both would stack two plugins over the same records and duplicate
every channel).

The FOMOD enforces the choice: step 1 picks the lane (`mode` flag), step 2 is
`visible` only when `mode=individual`.

### FOMOD archive layout (deduplicated)

Both lanes share one copy of every file; each option composes what it needs from
multi-`<folder>` entries:

```
common/<Mod>/                SKSE/.../Channels/PDV_QRM_<Mod>.json + Docs/PDV Patch - <Mod>.md
common/_Fragments/<Mod>/     Scripts/*.pex + Scripts/Source/*.psc   (the 3 dialogue-hook mods)
plugins/individual/<Mod>/    PDV_Patch_<Mod>.esp                    (the 3 dialogue-hook mods)
plugins/authoria/            PDV_Patch_Authoria_QuestMods.esp + its Docs entry
```

- Authoria option = all 10 `common/<Mod>` + 3 `common/_Fragments/*` + `plugins/authoria`.
- Individual data-only option = its `common/<Mod>` only.
- Individual dialogue-hook option = `common/<Mod>` + `common/_Fragments/<Mod>` +
  `plugins/individual/<Mod>`.

Fixed by the restructure: every patch previously shipped `README.md` at its
folder root, so installing more than one individual patch landed several files
at the same path and clobbered all but the last. Docs are now uniquely named
under `Docs/`.

Sources: `references/authoring/patches/PDV_QRM_<Mod>.csv` (one per mod).
Package: `dist/PDV_QuestModPatches_FOMOD/` + `dist/PDV_QuestModPatches_FOMOD_20260716.zip`
(+ `.sha256.txt`; 45 files, 147 KB). Individual options auto-recommend when their
target plugin is detected. Verified: XML parses; every referenced folder exists
and is non-empty; no orphan folders; and all three install lanes simulated
file-by-file with ZERO path collisions -- Authoria (1 esp / 10 channels / 9 pex
/ 11 docs), all-ten-individual (3 esp / 10 / 9 / 10), and a 3-patch subset
(1 esp / 3 channels / 6 pex, correctly scoped).

Upstream bugs fixed in passing: War's Folly INFOs 000014/000016 shipped script
bindings whose `.pex` files are absent from the mod (`nim__TIF__05005918` /
`0500591A` -- the endings never set quest stage 10). Our replacement fragments
restore the stage-10 set alongside the new PDV stages.

Machine proof: 10/10 channels `--check` PASS; core matrix 1982 cells / 173 keys
(+4 for DB01 s198); patch records read back from disk. Runtime proof pending
(TODO-7).

### 2026-08-06 T13 extension (machine-clean test candidate)

T13 adds nine data-only channels: Wyrmstooth, CC The Cause, CC Ghosts of the
Tribunal, CC Divine Crusader, Taste of Death Addon, Siege at Icemoth, Hunt for
the Spectre, Calling the Watchmaker, and Gift of Saturalia. They contain **95
cells across 14 keys / 14 watched quests** and require no new ESP. M'rissi is
excluded and remains assigned exactly once to T14.

The FOMOD now offers 19 channel options. The Authoria lane installs all 19 while
retaining the original combined hook ESP only for the three mods that need
dialogue result fragments; every new individual option installs only its
detected mod's JSON and shared runbook. `pdv_quest_patch_fomod_validate.mjs`
passes XML parsing, all referenced folders, Authoria/all-individual/subset
simulation, channel naming, collision checks, and a 67-file hash manifest.
The structure receipt is
`references/authoring/PDV_QuestModPatches_FOMOD_Validation.json`.

Proof boundary: these options are machine-verified experimental. The 14-case
ledger is `PDV_ARR25_T13_RuntimeEvidenceLedger.json`; all cases are OPEN and the
Divine Crusader pilgrimage must be traversed organically. No T13 option is
supported yet.

### 2026-08-06 T14 extension (machine-clean test candidate)

T14 adds five data-only channels: Thogra, Song of the Green (Auri), M'rissi,
Xelzaz, and Moonpath to Elsweyr. They contain **78 cells across 15 keys / 12
watched quests** and require no new ESP. M'rissi is present exactly once here.

The cumulative FOMOD now carries 24 data channels. The Authoria combined lane
installs all guaranteed targets; each new individual option installs only the
detected mod's channel plus shared runbook. The direct factual dossier is
`PDV_ARR25_T14_EvidenceDossier.md`, primary rulings are in
`PDV_ARR25_T14_Adjudication.md`, and all 15 OPEN cases are in
`PDV_ARR25_T14_RuntimeEvidenceLedger.json`.

Proof boundary: these five options are machine-verified experimental. The
Largashbur Orc-marriage cells are objective-derived and must be traversed
organically; controlled `setstage` proves routing only. No T14 option is
supported yet.

### 2026-08-06 T15 extension (machine-clean test candidate)

T15 adds six data-only channels for College of Winterhold Quest Expansion,
Infiltration, Nilheim, The Whispering Door, Paarthurnax, and Forsworn
Conspiracy. They contain **58 cells across 14 keys / 13 watched quests** and
require no hook ESP.

The cumulative FOMOD now carries 30 data channels. The combined Authoria lane
installs all six guaranteed targets; each individual option installs only its
detected mod's channel and the shared runbook. The direct factual dossier is
`PDV_ARR25_T15_EvidenceDossier.md`, primary rulings are in
`PDV_ARR25_T15_Adjudication.md`, and all 14 OPEN cases are in
`PDV_ARR25_T15_RuntimeEvidenceLedger.json`.

Proof boundary: these options are machine-verified experimental. Paarthurnax
stage 99 is objective-derived and must be reached organically through the
persuasion route; controlled `setstage` proves routing only. No T15 option is
supported yet.

### 2026-08-06 existing-matrix multi-tag normalization

Fifteen existing core outcome keys had accumulated different truthful act-tag
subsets across their deity cells. The canonical normalization interface is
`PDV_QuestReactionMatrix_OutcomeTagNormalization.csv`; the merge gate applies it
after duplicate resolution and fails on an unknown key. Core remains **2,130
cells / 231 runtime keys**: no deity reaction, score, or routing key changed.

The bounded cross-generation pass produced 45 candidates and three conflicts.
Primary review retained no new cells, applying the standing theology-stretch
and double-credit rules rather than using wider tags to farm coverage. Exact
rulings are in `PDV_ARR25_ExistingMatrixMultiTag_Adjudication.md`. Correcting
DB06's stray chaos gloss removes two false paired-equity gaps: the T13-T15
composite is now 114 open / 99 waived across 2,361 cells. This is machine/source
consistency proof only and makes no new runtime or support claim.

### 2026-08-06 T16 extension (machine-clean test candidate)

T16 adds two channels for TG Alternative Endings and Save the Icerunner. They
contain **58 cells across seven keys / two watched quests**. Save the Icerunner
is data-only. TG Alternative Endings requires a soft-dependency script payload
because all three endings complete physical `TG09|200`, which core already owns.
The resolver preserves vanilla at 200, maps freeing all Nightingales to 201,
and maps wresting away and keeping the Skeleton Key to 202. It also suppresses
the separate Nocturnal +10 commitment route for those two alternate endings.

The cumulative FOMOD now carries 32 data channels. The combined Authoria lane
installs both channels and the current script set; the individual TGAE option
installs its channel and the dependency-complete PlayerEvents/EventBus/Manager
source+PEX set, while Save the Icerunner remains channel-only. The direct factual dossier is
`PDV_ARR25_T16_EvidenceDossier.md`, primary rulings are in
`PDV_ARR25_T16_Adjudication.md`, the static seam gate is
`tools/pdv_arr25_t16_route_check.mjs`, and all seven OPEN cases are in
`PDV_ARR25_T16_RuntimeEvidenceLedger.json`.

Proof boundary: both options are machine-verified experimental. The TG09
branches must be traversed organically because `setstage TG09 200` cannot set
or prove the ending global; testing must also confirm that no false Nocturnal
commitment award fires. No T16 option is supported yet.

### 2026-08-06 T17 extension (machine-clean test candidate)

T17 adds data-only channels for Legacy of the Dragonborn and Beyond Skyrim -
Bruma and extends the existing Wyrmstooth channel. It contributes **132 cells
across 22 keys / 12 watched quests**: 19/3 from LOTD, 54/8 from Bruma, and 59/11
new Wyrmstooth cells. Composite/ambiguous branches, linear fetches, generic
bandit tasks, and textless controller stages remain excluded.

The cumulative FOMOD now carries 34 channels. The combined Authoria lane
installs all three T17 targets; Legacy and Bruma each receive a new detected
individual option, while Wyrmstooth remains one option with one expanded JSON.
No new ESP or hard master is introduced. Direct factual evidence is in
`PDV_ARR25_T17_EvidenceDossier.md`, primary rulings are in
`PDV_ARR25_T17_Adjudication.md`, and all 22 OPEN cases are in
`PDV_ARR25_T17_RuntimeEvidenceLedger.json`.

Proof boundary: these are machine-verified experimental channels. LOTD's Snow
Elf ghost stage must prove resolving/single-fire behavior, and Wyrmstooth's
Thalmor task must prove it is not a generic repeatable kill surface. No T17
option is supported yet.

### 2026-08-06 ARR 2.5 Wave 1 inventory recovery

The recovered Wave 1 compatibility inventory is
`PDV_ARR25_ContentInventory_2026-08-06.csv`: 1,220 retained rows covering 657 of 657
mods in its original scope, after excluding one literal scratch `placeholder` row.
Scope equality, natural-record uniqueness, and triage values were reconciled. The
later 328-mod QUST universe and the selected non-quest signature universe were then
closed through deterministic checkpoint shards, primary semantic review, and T13-T17
authoring. This is still machine evidence: runtime and support proof remain OPEN.
The discovery contract, exact inventory interface, and proof boundary are recorded in
`references/authoring/PDV_ARR25_ContentSweep_CodexHandoff_2026-08-06.md`.

Follow-up logged: Sirenroot's Tilael/ghost-encounter beat (FormID range
03B421-089999) was NOT scanned -- if it holds a spare/banish choice, it is a
second hook worth adding. The Frissa report branches are tone, not morality --
deliberately not hooked.

## To-Do list

P0 = blocks the Authoria 1.0 gate package; P1 = next tranche; P2 = nice-to-have.

- [x] **TODO-1 (P0, S1): MACHINE-COMPLETE 2026-08-06.** The current T13
  high-confidence scope is authored as nine formid-bearing per-mod channels
  (95 cells / 14 keys), compiled and packaged without changing core
  `MANUAL_QUEST_FORMIDS`. M'rissi was intentionally moved to T14. Runtime and
  support proof remain OPEN in the structured T13 evidence ledger; this close
  marks authoring/package completion only.
  - [x] **Wave 1 inventory-scope prerequisite (2026-08-06):** 657 of 657 mods in
    the original bucket scope have an explicit verdict in
    `PDV_ARR25_ContentInventory_2026-08-06.csv`. This does not complete TODO-1's
    authoring work or the separate exhaustive discovery of the 328 QUST-bearing mods
    outside that original scope.
- [x] **TODO-2 (P0, S1): DONE 2026-07-16.** Innocence Lost QE 198/199/201
  text-verified on the winner; s198 (Grelod imprisoned, not murdered) rowed to
  CORE with the Stendarr/Mara/Stuhn/Molag Bal sweep. 199/201 are her later
  off-screen murder by other hands -- not the player's act, no rows.
- [ ] **TODO-3 (P1, S1):** Row VC01 vampirism-cure completion under Seeking The
  Cure (cure_undeath: +Arkay/Meridia/Mara, -Molag Bal), mirroring the C06
  cure-lane pattern; enumerate the overhaul's stage set first.
- [x] **TODO-4 (P0, S3/scripted): MACHINE-COMPLETE 2026-08-06.** The existing
  implementation already contains the optional SGT expertise and Become a Bard
  playing-edge observers, 5/15-second bounded cadence, 12-second double-route
  guard, per-tavern devotional-day cap, global daily decay, and milestone rows.
  It is packaged unchanged and statically gated. Bard runtime cases remain OPEN;
  this check does not claim support.
- [x] **TODO-5 (P1, S1): DONE 2026-07-16.** All 11 verify-theme-first targets
  verified (mostly Tier A stage text), owner-ruled, and shipped as per-mod
  patches. Superseded text below kept for the original scope note only.
- [ ] **TODO-5-OLD (superseded):** Run the verify-theme-first list (section 2) --
  stage/log-text readback per quest, then author or drop each.
- [x] **TODO-6 (P0, S5): MACHINE-COMPLETE 2026-08-06.** The stale QASmoke-sender
  swap was removed. The package now carries the read-back 11-ACTI prayer ESP and
  matching route-202 BOS map. Wyrmstooth placements use different base forms and
  do not inherit the swaps, so no unproved mappings were added. Jyggalag remains
  classify-only. Runtime prayer and negative-control cases remain OPEN.
- [x] **TODO-7 (P0, package): MACHINE-COMPLETE 2026-08-06.** The cumulative
  ARR 2.5 test candidate contains 34 channels, two scoped ESPs, current isolated
  PEX/source, Green Pact KID rules, corrected prayer swaps, full T13-T17 and
  non-quest ledgers, and refreshed README/runbook. FOMOD XML, referenced folders,
  collisions, Authoria/all-individual/subset simulations, 96 archive members,
  filenames, and checksums pass. Runtime preflight and every tester case remain
  OPEN, so the package is experimental and not supported.
- [ ] **TODO-8 (P1, S5):** Verify JS Shrines / CC Survival Disable-Shrine-Menu
  do not reroute shrine activation away from TempleBlessingScript surfaces.
  **Widened 2026-07-27 (1.0.4):** Devotion now SHIPS its own
  `Scripts\TempleBlessingScript.pex`, so this check must also enumerate every
  mod in the list that ships that same filename (Requiem bugfix packs do) and
  confirm Devotion wins it by MO2 mod priority. A loser here is silent - the
  shrine dispel-all bug simply returns.
- [ ] **TODO-9 (P1, curse):** Smoke Sacrilege + Manbeast + Requiem
  VampireCollection state detection (vampire/werewolf theology transitions).
- [ ] **TODO-10 (P1, startup):** Smoke Devotion init from an Alternate
  Perspective start with Starting Choices active.
- [ ] **TODO-11 (P2, S5):** Inspect the Kynareth-Replaces-Talos new blessing
  SPEL; add to neutralization targets if it grants a vanilla-style blessing on
  the swapped shrine.
- [ ] **TODO-12 (P2, S1):** Decide HoonDing flavor row for A Friend in Mead's
  `WDSMainQuest` (Redguard lane) or record the skip.

## Evidence trail

- Shrine SPEL winners: houseCARL batch readback 2026-07-16 (14/14 ->
  Requiem.esp, depth 2).
- QE stage verdicts: winner-level Stages readback per quest (see section 1
  caveat on log text).
- Quest enumerations: `housecarl_read_plugin_file type=Quest` per plugin, raw
  file reads on the ARR Test mods folder.
- Bard script behavior: read from the Authoria Master Patch loose sources
  (`_LP_BardQuestPlayerScript.psc`, `_talent_playinstrument.psc`,
  `BSP_BardSpeech.psc`).
