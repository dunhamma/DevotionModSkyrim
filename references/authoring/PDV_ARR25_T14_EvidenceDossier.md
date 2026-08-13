# ARR 2.5 T14 factual quest evidence dossier

## Scope and reading boundary

This is the direct factual extraction for T14's thin-roster follower and Elsweyr
lane. Every record below was read from its absolute plugin-file path with
`housecarl_read_plugin_file`. These are OUT-OF-LOAD-ORDER raw-file reads, not
winning-record or runtime-route claims. The active Anvil houseCARL instance was
not changed. Across the initial extraction and narrow follow-ups, all 25 reads
succeeded without retry.

No deity, valence, magnitude, packaging, runtime, or support verdict comes from
the readers. Those decisions belong to the primary adjudication.

## Thogra

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Thogra gra-Mugur - Orc Follower and Quest\\DK_Thogra.esp`

| FormKey | EditorID | resolving evidence |
|---|---|---|
| `167FDE:DK_Thogra.esp` | `dk_ThograMain` | Stage 150 is `CompleteQuest`: "Thogra fulfilled her blood oath and was blessed by Malacath." Stage 400 begins the betrayal; stage 410 is `ShutDownStage` and says "Thogra is dead." Stage 420 is a textless `FailQuest`/`ShutDownStage`. |
| `1F0E0E:DK_Thogra.esp` | `dk_ThograMarriageMara` | Stage 100 is `CompleteQuest`/`ShutDownStage`: "Thogra and I are now married." Objectives explicitly use the Temple of the Divines and Shrine of Mara. |
| `232B5A:DK_Thogra.esp` | `dk_ThograMarriageOrc` | Stage 100 is `CompleteQuest`/`ShutDownStage` but has no journal text. The objectives establish the Largashbur Orc-marriage route. Any stage-100 semantic row is objective-derived and remains `RUNTIME-VERIFY`. |

## Song of the Green (Auri)

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Song of the Green (Auri Follower)\\018Auri.esp`

`03E4B1:018Auri.esp` (`018AuriFriendQuest`, Song of the Green) visits Moss
Mother Cavern, Eldergleam Sanctuary, Ancestor Glade, Bloated Man's Grotto, and
Shadowgreen Cavern. Stage 80 is `CompleteQuest`; its journal says Auri opened up
about why she came to Skyrim and the pair grew closer. The earlier journal and
objectives directly frame the route as taking the homesick Bosmer to Skyrim's
most beautiful natural places.

## M'rissi

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\M'rissi's Tails of Troubles SE\\MrissiTailOfTroubles.esp`

| FormKey | EditorID | resolving evidence |
|---|---|---|
| `0935B5:MrissiTailOfTroubles.esp` | `MRTstage0` | No objective or completion surface. `NO-ROWS`. |
| `17229C:MrissiTailOfTroubles.esp` | `MRTstage1` | Stage 250 is `CompleteQuest` and records trust gained. The available text does not establish a controlled act tag by itself, so no cell is authored. |
| `260646:MrissiTailOfTroubles.esp` | `MRTstage3` | Stages 100, 7010, and 8000 carry `CompleteQuest` but no journal text. Objective 80 is to decide S'ahara's future; stage 90 hires her as housekeeper and stage 7999 says she will be docile, but neither is a completion stage. `DEFER` pending a proved branch route. |
| `554AD5:MrissiTailOfTroubles.esp` | `MRTstage3Bad` | Stage 100 is `CompleteQuest`: "Now M'rissi knows how to behave - like a good little slave she's always been." |
| `30DCA3:MrissiTailOfTroubles.esp` | `MRTstage8` | Stage 125 is `CompleteQuest` with a direct marriage log. Stage 250 is `CompleteQuest` with a direct kinship-ceremony log. Stage 999 is a parting/non-reciprocation log without `CompleteQuest`. |

## Xelzaz

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Xelzaz - Custom Fully Voiced Argonian Telvanni Follower\\BPUFXelzazFollower.esp`

| FormKey | EditorID | resolving evidence |
|---|---|---|
| `79F4DA:BPUFXelzazFollower.esp` | `BPUFXelzazTheSleepingTree` | Stage 54 completes the poison-kill route; stage 60 completes the burn-kill route; both say the tree is dead and its sap can no longer influence consumers. Stage 57 records opposing Xelzaz but not stopping him. Stage 66 records killing Xelzaz to stop him. The moral conflict is not safely reduced to a nature-despoiling cell, so it is `NO-ROWS` for T14. |
| `E408E2:BPUFXelzazFollower.esp` | `BPUFXelzazLostHistLeaf` | Stages 10 and 15 have empty log entries, no objectives, and no completion flag. `DEFER`. |
| `C6E975:BPUFXelzazFollower.esp` | `BPUFXelzazCrimsonNirnroot` | Stage 23 is `CompleteQuest`: after research, samples, experiments, and gathering ten Nirnroot, Xelzaz converted them into crimson Nirnroot with fungicultures and can repeat the process. |
| `40D29D:BPUFXelzazFollower.esp` | `BPUFXelzazArmorQuest` | Stages 21, 22, and 23 distinguish intimidation, persuasion, and killing the interlopers; stage 27 collapses all routes into the completed armor upgrade. No route-safe common moral tag is authored. `DEFER`. |
| `F47F25:BPUFXelzazFollower.esp` | `BPUFXelzazMeadQuest` | Stage 40 is `CompleteQuest`: the player stole the Black-Briar recipe and East Empire Company spices, gathered ingredients, waited through fermentation, tasted three meads with Xelzaz, and received his thanks. |
| `547931:BPUFXelzazFollower.esp` | `BPUFXelzazDragonRemains` | Only stage 10 exists. Objectives say to slay a targeted dragon and wait for its dissection, but there is no next resolving stage. `DEFER`; there is no routeable objective-derived cell. |

## Moonpath to Elsweyr

Raw file: `D:\\Wabbajack\\modlists\\ARR 2.5\\mods\\Moonpath to Elsweyr SSE\\moonpath.esp`

| FormKey | EditorID | resolving evidence |
|---|---|---|
| `06A8CA:moonpath.esp` | `AnvilMoonpathQuest` | Every progression node has a direct journal. Stage 60 is `CompleteQuest`: "I've arrived in Tenmar Forest." Earlier entries establish the Khajiit caravan, the moon-phase departure, and travel through the broken route. |
| `01ED3C:moonpath.esp` | `AnvilDenQuest` | Stage 150 is `CompleteQuest`: "The Justiciar is dead. A rebellion is growing, and soon all of Tamriel will be ablaze." Earlier stages directly establish defending the Khajiit den and attacking the Thalmor base. |
| `0589C5:moonpath.esp` | `AnvilSloadquest` | Stage 95 is `CompleteQuest`: the Sload is dead and the forest is saved from the Thrassian Plague. Stage 100 is `FailQuest`: the Sload is dead but the plague was released, the forest is sicker, and many lives were lost. Earlier text identifies a plague on a hallowed Khajiit burial site. |
| `03C6E1:moonpath.esp` | `Anvil_buildquest` | Stage 60 is `CompleteQuest`: "The base is finished - a true asset to the Rebellion." |
| `01EE82:moonpath.esp` | `AnvilQuestameir` | Stage 20 is `CompleteQuest`, but the direct text only establishes Pahmar acceptance/guarding and directs the player onward. `NO-ROWS`. |
| `0440C0:moonpath.esp` | `Anvil_armorquest` | Stage 30 is `CompleteQuest`: "This armor is fine indeed, made to wear in the desert style." It does not say the player crafted it. `NO-ROWS`. |
| `085C5D:moonpath.esp` | `Anvil_skullcatdialogue` | No stages or objectives. Dialogue holder only; `NO-ROWS`. |
