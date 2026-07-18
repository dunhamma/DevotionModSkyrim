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
  SHIPPED (4 rows, `PDV_QuestReactionMatrix_Full.csv`).

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

Follow-up logged: Sirenroot's Tilael/ghost-encounter beat (FormID range
03B421-089999) was NOT scanned -- if it holds a spare/banish choice, it is a
second hook worth adding. The Frissa report branches are tone, not morality --
deliberately not hooked.

## To-Do list

P0 = blocks the Authoria 1.0 gate package; P1 = next tranche; P2 = nice-to-have.

- [ ] **TODO-1 (P0, S1):** Author the ARR matrix tranche 2 from the
  high-confidence table in section 2 (CSV -> `pdv_quest_matrix_compile.mjs`;
  register new FormIDs in `MANUAL_QUEST_FORMIDS`). Runtime-verify flags on
  every row lacking ShutDownStage proof.
- [x] **TODO-2 (P0, S1): DONE 2026-07-16.** Innocence Lost QE 198/199/201
  text-verified on the winner; s198 (Grelod imprisoned, not murdered) rowed to
  CORE with the Stendarr/Mara/Stuhn/Molag Bal sweep. 199/201 are her later
  off-screen murder by other hands -- not the player's act, no rows.
- [ ] **TODO-3 (P1, S1):** Row VC01 vampirism-cure completion under Seeking The
  Cure (cure_undeath: +Arkay/Meridia/Mara, -Molag Bal), mirroring the C06
  cure-lane pattern; enumerate the overhaul's stage set first.
- [ ] **TODO-4 (P0, S3/scripted):** Build the bard performance hook: BSP-style
  alias poll on SGT expertise deltas + `_LP_BardIsPlaying` edge, per-tavern
  anti-farm via `_LP_BardTavernCounts`, milestones on BaB tavern/Jarl s100 and
  the two Bards Reborn college quests. Soft-dependency guards
  (GetFormFromFile) so it no-ops without the mods. Dibella primary lane.
- [x] **TODO-5 (P1, S1): DONE 2026-07-16.** All 11 verify-theme-first targets
  verified (mostly Tier A stage text), owner-ruled, and shipped as per-mod
  patches. Superseded text below kept for the original scope note only.
- [ ] **TODO-5-OLD (superseded):** Run the verify-theme-first list (section 2) --
  stage/log-text readback per quest, then author or drop each.
- [ ] **TODO-6 (P0, S5):** Re-verify the BOS shrine-prayer swap INI against ARR
  Test statue records; extend to the Wyrmstooth Daedric-shrine placements and
  decide Jyggalag (currently no PDV deity -- likely classify-only).
- [ ] **TODO-7 (P0, package):** Refresh `PDV_AuthoriaARR_Compatibility` package
  against this instance (masters check, matrix JSON regen, README instance
  path), then local smoke per the updated
  `PDV_Phase21_ARR_SmokeRunbook.md` (no Archon step anymore).
- [ ] **TODO-8 (P1, S5):** Verify JS Shrines / CC Survival Disable-Shrine-Menu
  do not reroute shrine activation away from TempleBlessingScript surfaces.
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
