# PDV Compatibility Package - Journals of Jyggalag (JoJ)

Status: LIVING (plan, pre-implementation)
Opened: 2026-08-08
Precedent: `PDV_DoD_CompatibilityPackage_2026-06-30.md`. JoJ is the second of the two
real build-targets tracked by `C-COMPAT-BORDELLO` (DoD-base and JOJ-base).

Owner decisions on this page (2026-08-08):
- **Religion swap goes FIRST**, in the same job as the content audit.
- Content audit covers **all four classes**: quest mods, quest expansions, named
  followers, and dialogue/reaction expansions.

---

## 1. Instance facts (verified 2026-08-08)

| Fact | Value |
|---|---|
| Path | `D:\Wabbajack\modlists\JoJ` |
| Full name | Journals of Jyggalag |
| Profiles | `Journals of Jyggalag - Lord's Vision`, `Journals of Jyggalag - Performance` |
| Target profile | Lord's Vision |
| Active plugins | 3,610 |
| Mods | 3,689 |
| Religion layer | Wintersun - Faiths of Skyrim |
| Race overhaul | Mannaz - Integrated Races of Skyrim |
| Standing stones | Freyr - Integrated Standing Stones of Skyrim |
| Vampires / lycanthropy | Sacrosanct, Growl |
| Beast-race extras | HalfKhajiit (Ohmes-Raht) |

**houseCARL instance safety.** `housecarl_set_mo2_instance` persists to
`houseCARL.user.json` and is shared by every workspace on this machine. Run
`housecarl_load_order_status` and confirm the instance line before **any** readback that
becomes a claim, and **restore the pointer to Anvil** at the end of every JoJ session.
The failure mode is a confident wrong answer, not an error.

---

## 2. Free coverage already in place

The per-mod patch hub currently targets 38 plugins. **18 of them are already active in
JoJ** and are patched the moment the FOMOD installs:

`018Auri.esp`, `BPUFXelzazFollower.esp`, `College Of Winterhold - Quest Expansion.esp`,
`DAc0da.esm`, `DK_Thogra.esp`, `ForgottenCity.esp`, `Glenmoril.esm`,
`LegacyoftheDragonborn.esm`, `MrissiTailOfTroubles.esp`, `Olenveld.esp`,
`Siege at Icemoth.esp`, `Skyrim Extended Cut - Saints and Seducers.esp`,
`The Heart of Dibella - Quest Expansion.esp`, `TheGiftofSaturalia.esp`, `Unslaad.esm`,
`Vigilant.esm`, `Wyrmstooth.esp`, `evgSIRENROOT.esm`.

**Coverage must be computed against `Full.csv`, not against hub folder names.** Quest
expansions typically add stages to the **vanilla** editor ID, so they need rows without
needing a plugin. `Tranche6_CompatCore.csv` already carries `DA10` s210 (House of
Horrors QE) and `ccBGSSSE020_Quest` s100 (Gray Cowl) on exactly this basis. A folder-name
diff would have reported both as uncovered. It would have been wrong.

---

## 3. Phase 0 - the religion swap (runs first)

### 3.1 Removal set - MASTER-READ, 2026-08-08

**Verified.** Every active plugin's TES4 header was parsed (3,610 scanned, 0 unresolved).
**27 plugins depend on Wintersun, not 24.** All 23 name-matched dependents are real, and
all are ESL-flagged - but the name match missed four, and the four are the interesting
ones:

| Missed plugin | What it is | Resolution |
|---|---|---|
| `JOJ - Gameplay Edits.esp` | **list-owned**; masters `Hearthfires - Wintersun Shrines.esp` (the addon, *not* Wintersun itself); overrides **0** Wintersun-defined records - the master is required for a *reference*, not an override | specialty patch |
| `JOJ - Cell and Worldspace Edits.esp` | **list-owned**; overrides exactly **1** Wintersun record: `019B89` `WSN_AltarsCell`, Wintersun's own internal altars cell - dead weight once Wintersun goes | specialty patch |
| `Lord's Vision - Synthesis Gameplay.esp` | Synthesis output | resolves on re-run |
| `PG_1.esp` | ParallaxGen output | resolves on re-run |

**Neither list-owned plugin can be hand-stripped.** Wintersun sits at master index 34 of
63 in Gameplay Edits and 33 of 42 in Cell and Worldspace Edits - not last, so removing it
renumbers every master index above it. Combined with the standing policy *do not edit
list-owned plugins directly*, hand-editing is off the table. See 3.2a.

The 23 name-matched dependents:

```
Wintersun - Faiths of Skyrim.esp          Wintersun - Tweaks and Enhancements.esp
Wintersun Skillrate Alternative.esp       Wintersun - GotT Lite Patch.esp
Wintersun - Gallows Hall.esp              Wintersun - ZIA Patch.esp
Hearthfires - Wintersun Shrines.esp       Camping Expansion - Wintersun shrines.esp
JKs Dark Brotherhood Sanctuary - Wintersun patch.esp
COTN Dawnstar - Wintersun Patch.esp       DBM_Wintersun_Patch.esp
LOTD_TCC_Wintersun.esp                    TCIY_Wintersun_Patch.esp
FloatingSword_TCIY_Wintersun_Patch.esp    SDA Wintersun Patch.esp
HoHQE - Wintersun.esp                     TOCQE - Wintersun patch.esp
TWDQE - Wintersun patch.esp               Wintersun - Mrissi Patch.esp
AX ValSerano-Wintersun.esp                Mannaz-Freyr-Wintersun-patch.esp
Lux Orbis - Wintersun patch.esp           Lux - Wintersun patch.esp
Northern Roads - Wintersun patch.esp
```

Note `Wintersun Textures Reborn` is asset-only (no plugin) and can simply be disabled.

### 3.2 CORRECTED - the four CELL patches are disabled, NOT forwarded

My first draft said `Lux - Wintersun patch.esp`, `Lux Orbis - Wintersun patch.esp`,
`Northern Roads - Wintersun patch.esp` and `Mannaz-Freyr-Wintersun-patch.esp` had to be
hand-forwarded like DoD's `Ohmes-Raht Fix.esp`, or JoJ's lighting would revert. **The
records disprove that.** Read 2026-08-08:

| Patch | Records | Every record owned by |
|---|---|---|
| `Lux - Wintersun patch.esp` | 5 (3 PlacedObject, 2 Cell) | `Skyrim.esm` |
| `Lux Orbis - Wintersun patch.esp` | 89 (58 PlacedObject, 27 Cell, 3 PlacedNpc, 1 Worldspace) | `Skyrim.esm` |
| `Northern Roads - Wintersun patch.esp` | 15 (6 Cell, 5 Landscape, 3 PlacedObject, 1 Worldspace) | `Skyrim.esm` |
| `Mannaz-Freyr-Wintersun-patch.esp` | 2 (1 LeveledItem, 1 MagicEffect) | - |

**None of them defines a single record of its own.** They are pure reconciliation
overrides of vanilla records. Spot-checked the conflict tree on `008ED9` (`POISnowy16`),
one of Lux Orbis's 27 cells - 7 plugins touch it, and **`Lux Orbis.esp` overrides it
independently** at position 4, one slot below the patch. So disabling the patch loses
nothing: Lux Orbis's own version simply wins once Wintersun is gone.

**Ruling: disable all four.** With Wintersun removed, the reconciliation is not merely
unnecessary - it is positioned around objects that no longer exist.

A second finding from the same conflict tree: the actual winner of that cell is
`Occlusion.esp`, with `Lord's Vision - Synthesis Terrain.esp` directly beneath it. **The
final winner for JoJ's contested CELLs is usually a regenerated tool output**, not any
religion mod - which both defuses the lighting worry and widens the re-run list in 3.6.

### 3.2a Specialty patch - the two list-owned JOJ plugins

The only genuinely hard part of the swap. Both `JOJ - Gameplay Edits.esp` and
`JOJ - Cell and Worldspace Edits.esp` get a missing master the moment Wintersun (or the
Hearthfires shrines addon) is disabled, and neither can be edited - see 3.1.

**Recommended resolution: empty-master stubs.** Ship record-free ESPs named
`Wintersun - Faiths of Skyrim.esp` and `Hearthfires - Wintersun Shrines.esp` (TES4 header
only). Both list-owned plugins then load unchanged; their Wintersun FormLinks resolve to
nothing, which is the same as a null link and is harmless; no list-owned plugin is
touched; and the whole thing reverses by deleting two files. The one record actually at
stake, `WSN_AltarsCell`, is Wintersun's internal altar holding cell - losing it is correct.

**Upstream option:** hand the JoJ devs a Wintersun-free rebuild of those two plugins. That
is the clean long-term fix and is the kind of thing to take to the list authors rather
than absorb.

`HoHQE - Wintersun.esp`, `TOCQE - Wintersun patch.esp`, `TWDQE - Wintersun patch.esp`,
`SDA Wintersun Patch.esp`, `Wintersun - Mrissi Patch.esp` and
`AX ValSerano-Wintersun.esp` are the **religion-reaction patches** - they are precisely
the places JoJ's authors wanted a religion mod to notice content. Their record contents
are a free, authored specification of where Devotion should hook. **Read them before
deleting them.**

### 3.3 Load order placement

Devotion goes in **Wintersun's slot**. Placed by hand, by conflict.
**Never LOOT a curated modlist** - standing owner ruling.

`Devotion.esp` ships `TempleBlessingScript.pex` and must sit **below** any Requiem
bugfix pack that also ships it. Confirm whether JoJ has one.

### 3.4 Race mapping

- `HalfKhajiit.esp` (Ohmes-Raht) -> `PDV_RaceMap.json` maps `HalfKhajiit` -> `Khajiit`,
  as already done for DoD. The old SOS Ohmes script patch is SUPERSEDED - do not use it.
- `Mannaz - Integrated Races of Skyrim` adds races. Every added race needs a RaceMap
  entry or Devotion will not resolve an origin for a player using one. **This is new -
  DoD did not have Mannaz.** Enumerate Mannaz's RACE records and rule on each.
- `Freyr` changes standing stones; check for interaction with any Devotion reward that
  reads a stone.

### 3.5 Vampire and lycanthropy lanes

JoJ ships Sacrosanct and Growl rather than vanilla. The Imperial vampire earn-halt is
V2-strict and zeros civic gain at dawn; the Redguard halt is specced but not built.
Confirm the halt's detection still fires under Sacrosanct's vampirism implementation
rather than assuming the vanilla `PlayerVampireQuest` shape.

### 3.6 Tool outputs - do not patch these

JoJ runs Synthesis, ParallaxGen **and DynDOLOD/Occlusion**. Their outputs are regenerated
by the user and must never be forwarded into a patch.

Three tool outputs are directly implicated by the swap, verified 2026-08-08:
`Lord's Vision - Synthesis Gameplay.esp` and `PG_1.esp` both carry a Wintersun master
(so both currently break on removal and both fix themselves on re-run), and
`Occlusion.esp` + `Lord's Vision - Synthesis Terrain.esp` are the actual load-order
winners for the contested CELLs.

**Re-run list handed back to the user: Synthesis, DynDOLOD/Occlusion, ParallaxGen.**
Wider than DoD's, and not optional here - two of the three currently hold a master that
is being removed.

### 3.7 Phase 0 exit criteria

- 0 **new** missing masters (pre-existing ones documented and attributed).
- Devotion in Wintersun's slot, placed by conflict.
- Lighting spot-checked in at least one cell touched by each Lux/NR patch.
- houseCARL pointer restored to Anvil.

### 3.8 Phase 0 COMPLETE - 2026-08-08

Applied to `D:\Wabbajack\modlists\JoJ`, profile **`R11 Dev`** only. Backups of all three
profile files in `profiles\R11 Dev\_PDV_backup_2026-08-08\`.

**Removal**
- 24 plugins deactivated: 22 Wintersun dependents + `PG_1.esp` and
  `Lord's Vision - Synthesis Gameplay.esp` (tool outputs, disabled pending regen per the
  DoD precedent - `PG_1.esp` additionally mastered `DBM_Wintersun_Patch.esp`, which no
  stub covers).
- 15 Wintersun-dedicated mod folders disabled, including the translations-only
  `Wintersun - Faiths of Skyrim - Settings Loader`.
- Shared patch hubs (`Lux (patch hub)` 146 plugins, `Lux Orbis (patch hub)` 67, etc.)
  were **plugin-deactivated only, never folder-disabled** - disabling those folders would
  have removed dozens of unrelated patches.

**Master stubs** — `mods\PDV - Wintersun Master Stubs\`, 83 bytes each, ESL flags matched
to the originals (Wintersun plain, Hearthfires ESL). Readback: 0 masters, 0 records.
Proof the approach works: `019B89:Wintersun - Faiths of Skyrim.esp` (`WSN_AltarsCell`)
now resolves to *not present in the load order* while both `JOJ - *` plugins still load.

**Devotion** — `Devotion-1.0.4-20260808.zip`, packaged from Anvil live source via
`tools/pdv_package_release.mjs`, all 9 gates PASS, 226 entries,
sha256 `D289001E24A8C8E1E39B7A8ED32167987319C8BE2ED914D2AFA5052871054730`. Extracted to
`mods\Devotion\`; version recorded in its `meta.ini`. Placed **by hand in Wintersun's
exact slot** - plugins.txt line 1768, loadorder.txt line 1848. Never LOOTed.
All six SKSE dependencies confirmed present in JoJ (PapyrusUtil, po3 Papyrus Extender,
PrismaUI, JContainers, ConsoleUtilSSE, MCM Helper). Devotion is the **sole** provider of
`TempleBlessingScript.pex` in this list, so the Requiem-ordering hazard does not apply.

**Exit criterion MET.** Full-order TES4 header scan of all 3,587 active plugins:
**0 new missing masters**. Two remain and both are pre-existing and unrelated -
`HalfKhajiit.esp` needs `RaceCompatibility.esm` and `ORomance.esp` needs `OSA.esm`;
neither master is installed anywhere in JoJ and neither plugin was touched. These are the
same two the DoD session recorded. houseCARL restored to Anvil / `Devotion Dev`.

**Still open from Phase 0:** the lighting spot-check (needs the game), the Mannaz RaceMap
entries, the Sacrosanct vampire-halt confirmation, and the user's
Synthesis / DynDOLOD-Occlusion / ParallaxGen re-run.

### 3.9 Repo findings surfaced by packaging (not JoJ-specific)

Packaging the build required fixing real drift in the repo, all now corrected:

1. **Release manifest was stale in both directions.** 11 files shipped since 1.0.4 were
   never manifested (Altmer practice focus + lines, Khajiit Azurah portent, Baan Dar
   rescue, moon observations, the Calian mesh, TempleBlessingScript), and
   `PDV_QuestReactionMatrix_ARR.json` was still required after `aa95c7e8` deleted it.
   Manifest now 226 entries (was 216).
2. **`TempleBlessingScript` cannot be a `sourceScripts` entry.** The packager's pair check
   filters on `/^Scripts\/PDV_.*\.pex$/i`, so a deliberate vanilla-name override can never
   satisfy it. Expressed as a fixed pair instead; **the tool was not edited**. Worth
   knowing before the next non-`PDV_` script ships.
3. **15 `PDV_DaedricPath_*` scripts had stale bytecode** - sources bulk-touched
   2026-08-07T05:46, `.pex` still from 03:17. All recompiled, 0 errors / 0 warnings.
4. **houseCARL release proof refreshed** against the current ESP. Re-derived: hash, record
   summary (1961/21), 0 dangling / 0 missing / 0 parse, 33 contested records, 51/51 placed
   objects winning from Devotion, ManagerQuest VMAD 1 script / 524 properties / 1 alias,
   100 script pairs. **Not re-derived and explicitly marked as carried forward:** the
   property-level unbound-Auto counts.
   Note the gate hardcodes `contestedRecordCount === 33` - that is **pinning, not
   verifying**; it happens to still be 33.
5. **Devotion defines 1 Faction record.** Corrects the SPID scope doc's claim of zero.

---

## 4. Phase 1 - the content audit

### 4.1 Method, chosen for token cost

The naive approach reads 3,610 plugins into context and dies. The method is:

1. **Bound the candidate set from MO2's own separators.** `modlist.txt` groups mods into
   named sections. The four in-scope classes map to five separators: `New Quests &
   Adventures`, `Quest Expansions`, `Dialogue Expansions`, `Added Followers & NPCs`,
   `Follower Dialogue Expansion`. That turns 3,689 mods into roughly 150 candidates
   **without a single record read**. Already done - see 4.2.
2. **Subtract existing coverage by script.** Extract `editor_id` from `Full.csv` (2,131
   rows) and intersect. Runs in a script; only the shortlist enters context.
3. **Per-candidate record read, batched, output to file.** houseCARL QUST reads for the
   shortlist only, written to the scratchpad, diffed by script. Only the ranked result
   is read.
4. **Triage, then author.** Each candidate gets COVER / SILENT / DEFER with a reason.

The cost driver is **not** row authoring - it is stage citation. Every matrix row carries
a `citation` and the standard is "text-confirmed via houseCARL". At 5-15 rows per mod
across ~60 covered mods this is 300-900 stage reads. That is what makes this multi-session.

### 4.2 Candidate set (from MO2 separators, verified 2026-08-08)

**Class A - new quest mods, uncovered.** Gray Cowl of Nocturnal (10th Anniversary),
Project AHO, Moon and Star, The Tools of Kagrenac, The Sinister Seven, Legends of
Aetherium, **Sleepwalking Into A Nightmare (new Daedric Prince)**, Heart of the Reach,
There Is No Umbra III, Ascend - Hidden Peaks, Leaps of Faith, Unique Vampire Dens.

**Class B - quest expansions, uncovered.** The Only Cure QE (Peryite), Caught Red Handed
QE (Dibella), The Innocence Lost QE, Destroy the Dark Brotherhood QE, Penitus Oculatus,
Thieves Guild for Good Guys, The Choice Is Yours, Destroy the Acolyte Priests, Defeat the
Dragon Cult, Return Aegisbane, Respectful Ravyn, Revealing Rune.

**Class C - named followers, uncovered.** Kaidan 2, Inigo, Lucien, Remiel, Hoth, Gore,
Taliesin, Val Serano, Redcap the Riekling, Sa'chil, Khajiit Will Follow, Merlin the
Corgi, Jesper the Guard, the ColdSun's Visions set, the Reaper864 / Daedric Descendants
set. Mechanism is identical to the shipped Auri patch - a follower's personal quest
(`018AuriFriendQuest` s80) is just a quest with stages.

#### Class C record verdicts (structural QUST probe, 2026-08-09)

Six were read directly off disk rather than judged by name. All six define content
quests, so none is a dead end:

| Follower | Plugin | QUST defined | Content quests among them |
|---|---|---:|---|
| Lucien | `Lucien.esp` | 48 | `JRLucienOctavius`, `JRLucienDelphine`, `JRLucienVilja`, `JRLucienBardsCollege`, `JRLucienHoth` |
| Remiel | `HLIORemi.esp` | 55 | `HLIORemiMainQuest02`, `HLIOMQ1RewardManager`, `HLIOChaurusPieQuest`, `HLIOVampirism` |
| Astrid (Heart of Ice) | `SM_Astrid.esp` | 55 | `SM_AstridStart`, `SM_AstridWedding`, `SM_AstridEnding`, `SM_AstridDrinkQuest` |
| Sa'chil | `SU04SachilFollower.esp` | 45 | `..._Q1_MainQuest`, `..._Q2_DragonbornQuest`, `..._Q3_DawnguardQuest` |
| Val Serano | `AX ValSerano.esp` | 62 (+4 overrides) | `Val000`-`Val006`, `ValS01`-`ValS05`, `ValEnd`, `ValAddon01/02/03` |
| Taliesin | `00Taliesin.esp` | 17 | `0TallyMQ`, `VV_TallyConfession`, `00TallyBerwhale`, `0TallySleepingTreeSap` |

**A count is not a work estimate.** Every one of these also carries framework quests that
are not player-facing - Lucien's 48 include `JRLucienMapMarker`, `JRLucienRiding`,
`JRLucienCatchUp` and `JRLucienGetHorseQuest`. The ARR discovery waves already adjudicated
that family as non-content. Authoring rows still needs a per-quest stage read; this only
settles that there is something there to read.

**Val Serano is the correction that matters.** `PDV_ARR25_ContentSweep_CodexHandoff_2026-08-06.md`
recorded it as a verified negative with no QUST, *"recorded so they are not re-checked"*.
It has 62. That doc is corrected.

Five of these six had been silently dropped from the work list entirely: the candidate
queue's name filter read "Voiced" in `Lucien - Immersive Fully Voiced Male Follower` the
same way it read it in `VIGILANT - ElevenLabs Voiced`, and discarded the followers while
queueing their cosmetic replacers. Fixed in `tools/pdv_candidate_queue.mjs`, which now
carries a structural QUST probe alongside the names.

**Class D - dialogue and reaction expansions.** NPCs React To Necromancy, NPCs React To
Frenzy, NPCs React To Invisibility, Vampire / Bandit / Dremora / Civil War / Forsworn and
Thalmor Lines Expansion, Guard Dialogue Overhaul, Immersive Rejections, the ~30-mod FDE
family.

### 4.3 Class D needs a different hook, and that is the audit's main risk

Classes A, B and C all resolve to quest stages, which is exactly what the matrix eats.
**Class D largely does not have quest stages** - these mods add INFO records conditioned
on state, not quest progression. Feeding them through the matrix will produce either
nothing or wrong rows.

The honest reading is that Class D splits three ways:

- **Some do have hidden quests.** Many "lines expansion" mods ship a container quest for
  their dialogue. If it has stages that advance, it is matrix-eligible. Check first.
- **Some are SPID's job, not the matrix's.** "NPCs React To Necromancy" is a disposition
  and reaction mod. Devotion tagging into it belongs in the SPID recognition packet, not
  in a quest channel. This is the single strongest argument for sequencing SPID
  alongside, not after, the JoJ audit.
- **Some are genuinely out of reach** and belong in a silence ledger with a reason.

**Recommendation: audit Class D last, and expect its output to be a routing verdict
table rather than matrix rows.** Do not promise Class D coverage in matrix terms.

### 4.4 Deliverables

- `PDV_QuestReactionMatrix_Tranche13_JoJ_QuestMods.csv` (Class A)
- `PDV_QuestReactionMatrix_Tranche14_JoJ_QuestExpansions.csv` (Class B)
- `PDV_QuestReactionMatrix_Tranche15_JoJ_Followers.csv` (Class C)
- `PDV_JoJ_ClassD_RoutingVerdicts.md` (Class D - verdicts, not rows)
- `PDV_JoJ_SilenceLedger.md` - every candidate ruled SILENT, with its reason
- New `dist/PDV_QuestModPatches_FOMOD/common/<Mod>/` folders + Docs per covered mod
- FOMOD `ModuleConfig.xml` updated with the new options

---

## 5. Phase 2 - verification

### 5.1 The channel lane (about 95% of the deliverable)

No plugin, no scripts, **no VMAD**. Its proof stack:

1. `pdv_quest_tranche_merge.mjs --check` - `Full.csv` is **generated**; gate it or the
   merge silently drifts.
2. `pdv_quest_matrix_compile.mjs` - schema and compile.
3. `pdv_matrix_runtime_preflight.mjs` - **the load-bearing one.** Does stage 80 of that
   quest actually exist, and does its text say what the row's citation claims.
4. JSON key-drift check - the tell for this failure is "0 quest entries" at runtime.

### 5.2 The plugin lane (the minority, and where VMAD applies)

Only patches that ship an ESP with TIF fragments. Precedents: War's Folly (6 fragments),
Once We Were Here (2), Whispers of the Depths (1). Its proof stack:

1. houseCARL readback of the ESP after writing - **an in-place write has silently
   reverted an earlier one before**, so read back, do not assume.
2. Masters minimal, ESL-flagged.
3. **VMAD readback** - `VirtualMachineAdapter.Scripts` on every record we attached to,
   confirming the fragment landed and is bound to the stage we think it is.
4. `housecarl_validate_scripts` for `.pex`/`.psc` pairing.

### 5.3 Stated plainly, because the question was asked directly

A green VMAD check proves the script fragments attached. **It proves nothing about the
channels**, and the channels are the overwhelming majority of this work. The channel
lane's equivalent of a VMAD check is the runtime preflight in 5.1 step 3 - "does this
stage exist and mean what we said". Both gates are needed; neither substitutes for the
other; and neither is in-game proof.

### 5.4 In-game

Everything above is machine proof. Runtime delivery, toast selection, Book of Days
display and feel are a tester pass. `coc` skips Story Manager location-change triggers -
walk in through a load door.

---

## 6. Sequencing

| Phase | Content | Gate |
|---|---|---|
| 0 | Religion swap, load order, RaceMap, Lux/NR forwarding | 0 new missing masters; lighting spot check |
| 1a | Coverage subtraction script; candidate shortlist | shortlist reproducible from a script |
| 1b | Class A + B stage reads and rows | preflight green |
| 1c | Class C follower rows | preflight green |
| 1d | Class D routing verdicts | verdict table, no rows promised |
| 2 | Channel compile, FOMOD packaging | merge `--check`, compile, preflight |
| 3 | Plugin-lane patches, if any | houseCARL readback + VMAD |
| 4 | Tester bundle | GitHub pre-release, not a `dist/` commit |

Phases 1b/1c/1d are independently shippable. Do not hold the tranche for Class D.

---

## 7. Proof boundary

Section 1, 2, 3.1 and 4.2 are live reads of the JoJ profile files and the repo on
2026-08-08. Section 3.1 is **name-matched, not master-read**. Everything from section 3.2
onward is plan, not evidence. No record in JoJ has been read via houseCARL yet, and the
houseCARL instance pointer has not been moved.
