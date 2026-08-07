# ARR 2.5 Exhaustive Content Sweep -- Codex Handoff

Date: 2026-08-06
Branch: `codex/khajiit-lunar-champion-rebalance`
Author: Claude session (Opus 5). Owner-approved plan folded in below.
Status: **Phase 0 complete. Phase 1 partially complete and PAUSED by API errors.**

---

## 1. TL;DR

Devotion's quest-reaction matrix is essentially 100% vanilla. Third-party Authoria
content reaches the game through two side channels carrying ~120 rows total. The
owner asked for an exhaustive sweep of Authoria (ARR) 2.5 to find every taggable
piece of content we have missed, then to apply the matrix across every race and
deity.

What landed this session:

- **Phase 0 is done.** The stranded tranche-merge `--check` gate is on the branch.
- **Phase 1 is ~92% done by mod count** -- an inventory of 900 rows covering 602 of
  657 in-scope mods, committed as a real artifact.
- **Four of six reader agents hit API 529.** Two had already written complete files;
  two (LOTD, Vanilla Expansions) did not finish. 55 mods lack a verdict.
- **A scope gap was found late and is NOT yet covered: 328 QUST-bearing mods sit
  outside the in-scope bucket set, including all 55 Creation Club mods** -- which
  are the highest-priority targets in the existing backlog. See item C-3.

The single most valuable discovery: **follower personal questlines**, which are the
only content in 3739 plugins that can reach Devotion's thin-roster races.

---

## 2. Where things stand

### Done

| Item | Evidence |
|---|---|
| Cherry-picked the stranded `--check` gate | commit `639b7ab8` (cherry-pick of `9591d7dd`) |
| Tranche-merge gate green | `node tools/pdv_quest_tranche_merge.mjs --check` -> **PASS, exit 0** |
| Content inventory (partial) | `references/vanilla-gameplay/compatibility/PDV_ARR25_ContentInventory_2026-08-06.csv` -- 900 rows, 602 of 657 in-scope mods |

Gate output at handoff time is **2131 cells / 155 quests / 45 deities**. Note this
moved during the session: it read 1982 cells before Codex merged Tranche 12
(149 rows) in the working tree. Any doc quoting 1978 / 1982 is stale.

### Deliberately NOT done (owner's or Codex's call, not mine)

- **Wiring Tranche 12 into the merge file list.** Codex did this in the working tree
  mid-session. Left alone deliberately: Authoria work ships as *channels*, which
  never enter `Full.csv`, so it was never a prerequisite for this workstream.
- **The stale 1978/172 counts** in `AGENTS.md:216`, `PDV_MOD_SETUP.md:565`,
  `PDV_Architecture_v3.md:139/185`. `Claude.md` rule 3 puts `AGENTS.md` off limits,
  and the numbers move again with every tranche. Now 2131 / 173+.

### Errored / incomplete -- this is the Codex work list in section 4

Four of six reader subagents terminated on `API Error: 529 Overloaded`. Two of them
had already written complete output; two had not.

| Slice | Work list | Result |
|---|---|---|
| `inv_followers.csv` | 71 plugins | **COMPLETE** 71/71, 143 rows |
| `inv_namedmods.csv` | 61 plugins | **COMPLETE**, 190 rows |
| `inv_lines.csv` | 57 plugins | **COMPLETE** 57/57, 69 rows (529 fired after the write) |
| `inv_systems.csv` | 58 plugins | **COMPLETE** 58/58, 96 rows (529 fired after the write) |
| `inv_lotd.csv` | 92 plugins | **MISSING** -- 529 mid-enumeration; resumed once, unconfirmed |
| `inv_vanillaexp.csv` | 50 plugins | **MISSING** -- still running at handoff time |

Scratchpad (slices + work lists + the derived maps):
`C:\Users\Admin\AppData\Local\Temp\claude\C--Users-Admin-Documents-Devotion-Mod-Project\2f6eb23b-9aa6-4e14-a04e-513af87204df\scratchpad\`

That directory is session-scoped and **will not survive indefinitely** -- if the two
missing slices are not recovered soon, re-run them from the bucket TSVs, which are
also in there (`bucket_lotd.tsv`, `bucket_vanillaexp.tsv`). Regenerating the bucket
TSVs from scratch is cheap; see section 5.

---

## 3. The plan (folded in)

Full version: `C:\Users\Admin\.claude\plans\while-our-khajiit-work-floofy-unicorn.md`.
Condensed here so this handoff stands alone.

### Two architectural facts that shape everything

**1. New coverage needs zero Papyrus and zero ESP.**
`PDV_PlayerEvents.RegisterQuestReactionChannelFolder()`
(`live-source/Scripts/Source/PDV_PlayerEvents.psc:1588`) discovers channels
dynamically via `JsonUtil.JsonInFolder`. Any JSON dropped in
`SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/` registers itself as a matrix
file. The July per-mod FOMOD already proves the pattern with 10 channels.

Corollary: **keep Authoria work in channels, not core.** Channel rows carry their own
`formid` column, need no `MANUAL_QUEST_FORMIDS` registration, never enter `Full.csv`,
and therefore trip neither `pdv_matrix_runtime_preflight.mjs:22-23` (hardcoded watched
counts) nor `PDV_MainQuestFullCoverageContract.json` (asserts whole-matrix cell count).
Promote to core only for vanilla-guaranteed content, and bump both contracts in the
same commit when you do.

**2. The race dimension is TWO gates, not one.**
A matrix cell names a deity, never a race. At runtime it passes through:

- **A hard reachability gate** -- `IsDashboardDeityInOriginRoster`
  (`PDV__ManagerQuest.psc:4127`). Each race reaches a fixed roster: Nord 13,
  Breton 11, Imperial 8, Altmer 8, Khajiit 7, Bosmer 5, Dunmer 3, Redguard 3,
  Argonian 2, **Orc 1**. A cell outside the player's roster is **dropped entirely**,
  not dampened. Daedric Princes bypass this gate and reach everyone.
- **A stance multiplier** -- `stance.<Race>.<Deity>`: NATIVE 1.0, FOREIGN/TOLERATED
  0.4, TABOO/HOSTILE -> stigma, CURSE -> curse layer.

So "apply the matrix to every race" is NOT satisfied by authoring more rows for
popular deities. For a thin-roster race, value only lands if the row names a deity
that race can reach, or a Prince. Existing evidence of the trap: Trinimac carries an
explicit Orc stance in `PDV_StanceMatrix.csv` but is absent from the Orc origin
roster, so all 36 Trinimac cells are dead for Orcs.

### Phase 1 -- exhaustive discovery (in progress)

Source of truth: `D:\Wabbajack\modlists\ARR 2.5`, profile `KoK R11`.

**Do not switch houseCARL's instance.** It is on `D:\Wabbajack\modlists\Anvil` /
profile `Devotion Dev`, which live Khajiit work depends on. `housecarl_read_plugin_file`
takes absolute paths and reads out-of-load-order files fine. Its
`declared master(s) NOT installed` warning is a false alarm -- it resolves masters
against Anvil; they exist in ARR 2.5.

Scope rule: **every enabled mod in a content-bearing bucket gets a row and an explicit
verdict.** `NO-ROWS` with a reason, never omission.

### Phase 2 -- quest-lane tranches

Ordering is by who the rows can reach, not by mod. Two scarcity measures, routinely
conflated:

- **Per-deity target**: >= 20 positive / >= 10 negative signals. Hand-tracked in
  `PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md`; no script recomputes it.
- **Per-path gate** (`tools/pdv_signal_floor_audit.mjs`): 35 race paths + 16 Princes,
  PASS iff `wired_types >= 5` (Princes 4) and `wired_renewable >= 2`. Currently
  50 PASS / 1 UNDER-FLOOR (`breton_hidden_art`, renewable 1/2).

**Quest rows are one-shot: they raise `wired_types`, never `wired_renewable`.** The
one path actually failing cannot be fixed in Phase 2. Do not promise otherwise.

Tranche order:

| # | Tranche | Reaches |
|---|---|---|
| T13 | July high-confidence backlog (`PDV_ARR_ModPatchlist_2026-07-16.md:79-96`) | Namira, Sithis, Hermaeus Mora, Hircine -- Princes, so all 10 races |
| T14 | **Thin-roster races: follower questlines + Elsweyr** | Orc, Argonian, Bosmer, Khajiit |
| T15 | Vanilla expansions (CoW QE, Caught Red Handed, Infiltration, Nilheim ...) | Magnus, Julianos, Zenithar, Dibella |
| T16 | nimwraith alternate routes | Nocturnal, Clavicus Vile, Vaermina, Meridia |
| T17 | New lands + LOTD | Auri-El, Xarxes, Trinimac, Peryite, Sheogorath |

T14 is promoted ahead of the vanilla expansions because it is the only tranche that
moves the needle for Orc, Argonian and Bosmer players.

Per tranche: author `references/authoring/patches/PDV_QRM_<Mod>.csv` (the standard 10
columns plus `formid` as `PLUGIN:HEX`) -> compile with `--matrix`/`--output --check`
-> drop the JSON in `Channels/` -> gates.

### Settled authoring rules -- do not relitigate

- **Calibration is LOCKED** (`AGENTS.md:1623`): no per-quest cap on how many deities
  react. Pacing is tuned via milestone VALUE.
- Vocabulary: valence `{+,-}`, intensity `{C,S,m}`, magnitude `{milestone, small}`.
  **`echo` is retired.**
- milestone iff the matched tag is `C` for that deity AND the stage is terminal.
  Values: milestone 18/12/8, small 6/4/2, x stance 1.0/0.4.
- One quest fire = one toast + one Book of Days beat, however many gods it feeds.
- Merge dedupes on `(editor_id, outcome_stage, deity)`; conflicting valences abort
  with exit 1.
- ARR quest mods frequently ship NO journal text (`Stages[i].LogEntries[0].Entry`
  absent). Where only `Objectives[i].DisplayText` exists, those are *directives* not
  outcomes, so the row scores on the **next stage after** the act's objective and
  carries `RUNTIME-VERIFY` in its citation. Tranche 12's rows in
  `PDV_QuestReactionMatrix_ARR.csv` are the reference example.

### Phase 3 -- deity breadth

Do not hand-author the fan-out. `tools/pdv_quest_cross_gen.mjs` crosses every tagged
outcome against every Part B profile and emits a review slate. Then re-measure with
`pdv_signal_floor_audit.mjs` and `pdv_paired_equity_audit.mjs`.

Caution: `pdv_paired_equity_audit.mjs` **already reports FAIL** (28 open cluster gaps,
72 waived) before any of this work. Capture its baseline before T13 so tranches are
judged on the delta.

### Phase 4 -- non-quest lane

The only lane that can move `wired_renewable`. Faucet rows use the channel JSON's
existing `faucet.<Deity>.<act_tag>.*` schema. Existing Story Manager hooks
(`PDV__SM_ChangeLocation`, `_AddToPlayer`, `_CraftItem`, `_KillActor`,
`_IncreaseSkill`, `_PickLock`, `_NewVoicePower`, `_Trespass`) already fire on modded
content -- the work is curated list membership, not new Papyrus.

Repeatable acts belong in `PDV_DeityLikesDislikes.csv`, NOT the matrix. That path
requires the regen chain plus a `LIKES_DISLIKES_VERSION` bump
(`PDV__ManagerQuest.psc:629`, currently 20) or the rows are inert on existing saves.
**Do not** re-pin `EXPECTED_LIKES_DISLIKES_VERSION` in `pdv_verify.mjs` -- that
constant was deliberately removed 2026-08-03; older handoffs saying otherwise are
stale.

---

## 4. Codex work items

### C-1 (P0) -- Finish the two missing inventory slices

`inv_lotd.csv` (92 plugins) and `inv_vanillaexp.csv` (50 plugins) were not written.
55 in-scope mods currently have no verdict, listed by:

```
python -c "import csv;scope={l.split(chr(9))[1].strip() for l in open(r'<scratchpad>\scope.tsv',encoding='utf-8')};got={r['mod'] for r in csv.DictReader(open('references/vanilla-gameplay/compatibility/PDV_ARR25_ContentInventory_2026-08-06.csv',encoding='utf-8',newline=''))};print(sorted(scope-got))"
```

Read each plugin with `housecarl_read_plugin_file` on its absolute path. For each:
QUST records the plugin DEFINES (FormID master = itself) vs merely OVERRIDES, plus
DEFINED counts of BOOK/SPEL/ACTI/MISC/FACT/LCTN/NPC_.

Two targets in the Vanilla Expansions slice matter most and were never reached:

- **College of Winterhold - Quest Expansion** -- the owner's original example. Known
  from a spot read to define 10 QUST (8 player-facing), 3 BOOK, 1 SPEL
  (`Cow_ApprenticesBoon` 0009E8), 2 NPC_, 1 MISC. Appears nowhere in this repo. Feeds
  Magnus (9 quests) and Julianos (15), both thin.
- **At Your Own Pace** (+ College of Winterhold / Misc / Thane Overhaul) -- reworks
  pacing and adds player choice across several vanilla questlines. Likely the richest
  untapped source of branching outcome stages in the modlist. Determine precisely
  whether it defines new QUST or adds stages to vanilla FormIDs.

**Record the (a)/(b)/(c) distinction for every Quest Expansion mod**: (a) defines new
QUST, (b) overrides a vanilla QUST and adds stages beyond the vanilla maximum (list
the added stage numbers), (c) only edits existing stages. That decides channel vs core.

### C-2 (P0) -- Re-verify the two slices whose agents 529'd after writing

`inv_lines.csv` and `inv_systems.csv` were validated at 57/57 and 58/58 plugin
coverage, so they are believed complete. Spot-check a handful of `NO-ROWS` verdicts
against the plugins before trusting them wholesale -- the agents died immediately
after writing and their self-reports were never delivered.

### C-3 (P0) -- Close the scope gap. THIS IS THE BIGGEST OUTSTANDING ITEM.

The in-scope bucket set was drawn too narrowly. Measured totals:

- **583 mods across the modlist carry QUST records.**
- **255 were in scope** and read this session.
- **328 are OUT of scope and have never been looked at.**

Excluded buckets holding real content, by QUST-bearing mod count:

| Separator | Mods | Why it matters |
|---|---:|---|
| **Base Game & Creation Club Files** | **55** | **Contains CC The Cause, Ghosts of the Tribunal, Divine Crusader, Saints & Seducers, Umbra, Bittercup, Goblins, Forgotten Seasons, Shadowfoot Sanctum, Tundra Homestead. Four of these are named T13 high-confidence targets.** |
| Gameplay - Magic Mods | 11 | Magnus/Julianos lane |
| Gameplay - Combat | 9 | |
| Gameplay - Frameworks | 8 | |
| Gameplay - Perks & Leveling | 6 | |
| Gameplay - Vampire and Werewolf Overhaul | 5 | **Sacrilege, Manbeast -- curse-state detection, TODO-9** |
| City Stuff - Solitude / Whiterun / Riften / Villages / Misc Worldspace | 21 | village and city quest content |
| Gameplay - Missives | 4 | radiant quest boards, repeatable |
| Gameplay - Ostim Standalone | 24 | probably NO-ROWS, still needs a verdict |
| Gameplay - Wet and Cold, Essential-*, Interface-*, Animations-*, Visuals-* | ~185 | mostly NO-ROWS, cheap to rule |

Also confirmed out of scope and unread: **Shadow of Skyrim - Nemesis and Alternative
Death System** (separator `Gameplay - Death Alternative`). Player death is a strong
devotion signal and this mod owns it.

Recommendation: run a second discovery wave over `Base Game & Creation Club Files`,
`Gameplay - Vampire and Werewolf Overhaul`, `Gameplay - Death Alternative`,
`Gameplay - Magic Mods`, `Gameplay - Missives` and the `City Stuff - *` buckets first
(~110 mods, high yield), then sweep the remaining ~218 for cheap `NO-ROWS` verdicts.

### C-4 (P1) -- Completeness check before the inventory is called done

The set of distinct `mod` values in the inventory CSV must equal the set of enabled
mods in every content bucket. A straight set-difference against `modlist.txt`,
expected empty. Record the count in a ledger header (`N of N verdicted`) so a later
reader can tell coverage from silence. **Do not** rewrite
`PDV_ARR_ModPatchlist_2026-07-16.md` -- it holds owner rulings that must survive;
extend it with a pointer instead, and close its TODO-1 scope question.

### C-5 (P1) -- Re-tagging pass over the existing matrix

A finding that needs no new content. Coverage is driven by how many act_tags an
outcome carries, and **94% of existing rows carry exactly one tag** (2005 of 2131;
only 126 carry two or more).

Tag matching is exact plus one namespace wildcard (`serve_a_daedra:*` matches
`serve_a_daedra:molagbal`); broad-base matching was considered and explicitly
rejected as too broad (`tools/pdv_quest_cross_gen.mjs:123`). There is **no tag
hierarchy** -- `kill_honorable_combat` is a sibling of `the_hunt`, not a child of any
`combat` parent. And there is **zero tag matching at runtime**: the engine reads an
authored `deitiesCsv` per cell (`PDV__ManagerQuest.psc:1764`); tags ride along only
to build reason strings.

Worked example of the cost. A stage where the player wins a one-on-one challenge and
kills a stronger foe truthfully carries `kill_honorable_combat`, `honorable_duel` and
`prove_by_struggle`. Cross-gen pools tags per `editor_id|stage` and tests each deity
independently, keeping that deity's strongest hit. Fourteen deities match; five reach
C, and four of those five get there from a tag other than the one Shor uses:

| Deity | Best from | Intensity |
|---|---|---|
| Shor | `kill_honorable_combat` | C |
| Tsun | `prove_by_struggle` | C |
| HoonDing | `prove_by_struggle` | C |
| Leki | `honorable_duel` | C |
| Boethiah | `prove_by_struggle` | C |

Tag that stage with only `kill_honorable_combat` and Leki drops C->S, Tsun C->S,
HoonDing C->m, while **Boethiah and Baan Dar vanish entirely** -- neither has the tag.

So the Phase 2 authoring rule is: **tag each outcome with every tag that is TRUE of
what the player did, not just the one that motivated the row.** The honest limit is
truth -- the ledger's two standing drop reasons are "theology stretch" and
"double-credit", so widening tags to farm coverage is what gets rows dropped.

A re-tagging pass over the existing 2131 rows would widen deity coverage with no new
content. Worth its own tranche.

### C-6 (P2) -- Open questions carried forward

- **No gate checks reachability.** Nothing fails when a cell names a deity no race can
  reach (the Trinimac/Orc case). Worth a lint once the inventory shows how common it
  is. `Claude.md:17` means asking before touching the toolchain.
- Whether the combined Authoria all-in-one lane or the per-mod FOMOD lane absorbs each
  new tranche. July rule of thumb: Authoria-guaranteed targets go in the combined ESP;
  anything an arbitrary load order might lack ships per-mod, because a missing master
  stops the game loading.
- Whether `live-source/Scripts/Source/` is in sync with
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` before Phase 4 touches
  any `.psc`. Audits read the repo mirror; the compiler reads MO2.

---

## 5. Findings worth acting on

### Follower questlines -- the best find, and entirely absent from this repo

Nine follower mods carry QUST records. None appear anywhere in the repo today. These
are the only content that reaches the thin-roster races.

**Thogra gra-Mugur** (`DK_Thogra.esp`) -- 16 QUST defined, 3 player-facing.
**Orc reaches exactly one deity (Malacath)**, so this is close to the only leverage
that exists for an Orc player.
- `167FDE` *Thogra's Revenge* -- 24 stages. THE Orc quest.
- `1F0E0E` *Marry Thogra - Temple of the Divines* (Mara) vs `232B5A` *Marry Thogra -
  Largashbur* (Malacath) -- **a genuine theological fork**: Divines rite against
  stronghold rite, for the race with the narrowest roster in the game.

**Xelzaz** (`BPUFXelzazFollower.esp`) -- 96 QUST defined, 10 player-facing. Argonian
reaches only The Hist and Sithis; Xelzaz also opens a Dunmer Telvanni angle.
- `79F4DA` *An Unwanted Scion* -- 17 stages / 9 objectives, explicit moral fork.
  Highest-value Argonian row available.
- `E408E2` *Lost and Found* -- paired with MISC `BEFE1E BPUFXelzazHistLeaf` and a BOOK.
- `C6E975` *Of Crimson* (16 stages), `40D29D` *Quid Pro Quo* (Telvanni bargain framing,
  Boethiah/Mephala), `F47F25` *The Good Stuff* (34 stages, largest),
  `547931` *Field Research: Dragon Dissection* (a desecration angle on Akatosh).

**Song of the Green / Auri** (`018Auri.esp`) -- 19 QUST defined, 1 player-facing.
- `03E4B1` *Song of the Green* -- the Bosmer pilgrimage quest, 9 stages / 7 objectives.
  Y'ffre sits at 3 quests, joint-thinnest non-Prince deity in the ledger.

Others carrying quests: Deadlands Expanded (Mehrunes Dagon), Kaidan 2, Lucien
(Julianos/Xarxes), Remiel (Julianos/Magnus), Heart of Ice Astrid (Sithis), Ashe,
Yoana.

Verified negatives, recorded so they are not re-checked: **Val Serano** has no QUST
despite "Quest Adventure" in the title; **Inigo** and **Fluffy Thistlefoot** ship no
plugin in their own folder (Inigo's ESP lives in `Inigo - cleaned esp File`), so
resolve by plugin, never by mod folder.

### Aetherium Forge Destroys Items (AFDI) -- a ready-made Prince signal

The strongest non-quest find. The mod lets the player **destroy Daedric artifacts**
and ships exactly the records needed to detect it:

- `000801` ACTI -- the activator that fires the destruction.
- `000800` FLST -- master list of every destroyable Daedric artifact.
- `000D5C`-`000E8B` KYWD -- **per-Prince ownership tags** on each artifact, including
  a benign-Azura variant (`000D60`) that should read differently from a malign one.
- `0001FC`, `000D43`, `000D79` QUST -- script shims
  (`ANDR_AFDI_DestroyQuestScript`).

PDV already has the matching tag namespace: `destroy_reject_daedra:<prince>` is in use
in the ARR channel today. This maps onto starving Princes AND reaches every race,
since Princes bypass the origin-roster gate.

### Other non-quest candidates

- **Simple Hunting Overhaul** -- `000D90` KYWD marks a carcass **ruined by overkill**.
  A directly detectable disrespectful-hunt event: Kyne approves `the_hunt`(C) and
  disapproves `defile_nature`(C).
- **Become a Bard** / **Skyrim's Got Talent** -- confirmed present with the records
  the July spec (TODO-4) already designed against.
- **Why I Came to Skyrim - Origin Stories** (`The Book of Origins.esp`) -- the player
  picks a backstory at character creation, including arriving as **a pilgrim to a
  Shrine** (`00009A`) and **a pilgrim to High Hrothgar / the Seven Thousand Steps**
  (`00009F`). A declared religious origin; worth considering as starting-piety or
  stance seed rather than a quest row.
- **Alternate Perspective** (63 defined quests) and **Adventurer's Start** (38) --
  flagged DEFER, not NO-ROWS. These own game start, and PDV's startup flow must be
  smoke-tested against them (existing TODO-10).

---

## 6. Corrections made this session -- read before trusting older notes

1. **The mod->separator map was inverted.** In `modlist.txt` a separator sits *below*
   the group it labels (`VIGILANT SE` line 3312, its separator line 3313). The first
   map assigned each mod to the separator *above* it, shifting every label by one
   group. It produced plausible output and wrong bucket contents were reported from it
   before an implausible count exposed it. **Any derived map needs an anchor check** --
   verify known mods land in expected buckets before trusting counts.
   Corrected figures: Quests and Newlands is **404 mods**; 583 mods carry QUST.

2. **A name regex silently dropped content.** Filtering by title excluded
   *The Whispering Door - Quest Expansion* because it contains "Door", which had been
   excluded to strip mesh mods. Regex may **order** the work; it may never **bound** it.

3. **`Authoria` is not a mod.** It is a Wabbajack modlist bundling ~250 content mods;
   its own 587 plugins are patch/merge output defining almost nothing. The taggable
   universe is the bundled mods. `housecarl_cross_plugin_query` cannot reach them --
   they are not in the active load order, so absolute-path `read_plugin_file` is the
   only route without switching instances.

4. **Cell counts moved mid-session** from 1982 to 2131 when Codex merged Tranche 12.
   Do not quote a cell count from any doc without re-running the gate.

---

## 7. Verification

Per tranche. **Branch on exit code, never on grepped output.**

```
node tools/pdv_quest_tranche_merge.mjs --check
node tools/pdv_quest_matrix_compile.mjs --check --json
node tools/pdv_quest_matrix_compile.mjs --papyrusutil-check --json
node tools/pdv_quest_matrix_selftest.mjs
node tools/pdv_matrix_runtime_preflight.mjs --json
```

Then: `pdv_signal_floor_audit.mjs`, `pdv_paired_equity_audit.mjs`,
`pdv_deity_signal_remap_adversary_check.mjs`,
`pdv_verify.mjs --strict-curated-signal-dispatch --json`.

**Proof boundary.** Everything above is machine verification only. Every
objective-derived row ships `RUNTIME-VERIFY` in its citation and stays that way until
observed in game. The July per-mod patches are still machine-verified only (TODO-7).
Per `pdv-proof-boundary`, do not describe any of this as tested, supported, or
beta-ready on green gates alone.
