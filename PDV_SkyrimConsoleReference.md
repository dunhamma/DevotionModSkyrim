# Skyrim Console Command Reference
Source: UESP Wiki — https://en.uesp.net/wiki/Skyrim:Console
Used as source of truth for all console commands in the Devotion mod project.

---

## How to Read Commands
- Arguments in `<>` are placeholders — replace with the actual value, no brackets.
- Leading zeros in IDs are optional: `additem 2299c 1` = `additem 0002299c 1`
- Open console in-game with the **~** (tilde) key.
- `player.` prefix targets the player character.
- Target an NPC by clicking them in the console, or use `prid <RefID>` first.

---

## Devotion Mod Quick Reference
Commands most relevant to this project, confirmed working:

| Command | Effect |
|---|---|
| `GetGlobalValue <GlobalEditorID>` | Read a global variable value ✓ confirmed |
| `set <GlobalEditorID> to <value>` | Set a global variable value ✓ confirmed |
| `ShowGlobalVars` | List ALL current global variables and values |
| `sqv <quest ID>` | Show all variables on a quest |
| `sqs <quest ID>` | Show all stages of a quest and which are achieved |
| `setstage <quest ID> <stage#>` | Advance a quest to a specific stage |
| `getstage <quest ID>` | Show the current active stage of a quest |
| `prid <RefID>` | Select a reference by FormID (required for quests) |

> **Note:** `cgf` (Call Global Function) is NOT in the UESP command list and
> does not work for instance functions on quest scripts. Do not use it.
> `sgt` and `setglobalvalue` are also not valid commands — use `GetGlobalValue`
> and `set <var> to <value>` instead.

---

## Toggle Commands

| Command | Effect | Notes |
|---|---|---|
| `animcam` | Toggle animator camera | 3rd person camera that rotates without changing player facing |
| `psb` | Player Spell Book | Gives complete spell book + shouts. Can crash Skyrim |
| `s1st` | Show 1st person model in 3rd person | 3rd person only |
| `sucsm <number>` | Change UFO cam speed | Full name: SetUFOCamSpeedMult |
| `tai` | Toggle AI | Targeted; if no actor selected, toggles globally |
| `tb` | Toggle Borders | Shows cell borders as thin white line |
| `tc` | Toggle controls driven | Transfers control to highlighted NPC |
| `tcai` | Toggle Combat AI | Toggles combat AI on/off |
| `tcl` | Toggle collision (noclip) | Fly through world. Targeted — affects player if nothing selected |
| `tdetect` | Toggle AI Detection | NPCs can't see you. Note: pickpocket failure still triggers hostility |
| `teofis` | Toggle End-Of-Frame ImageSpace | Disables blur/contrast; big FPS boost |
| `tfc <1>` | Freeflying camera | `tfc 1` freezes environment while camera still moves |
| `tfow` | Toggle Fog of War | Disables local map |
| `tg` | Toggle grass | |
| `tgm` | Toggle god mode | No damage, magicka, stamina, encumbrance, shout cooldown |
| `tim` | Toggle immortal mode | Can't die from 0 health, but can be decapitated |
| `tll` | Toggle LOD | Hides faraway LOD meshes |
| `tm` | Toggle menus/HUD | Also hides console — type blind to re-enable |
| `tmm <show?>(,<discovered?>,<includehidden?>)` | Show/hide all map markers | e.g. `tmm 1,0,0` adds undiscovered markers without fast travel |
| `tmove` | Toggle Player Movement | |
| `ts` | Toggle sky | |
| `tscr` | Toggle script processing globally | |
| `tt` | Toggle trees | |
| `twf` | Toggle wireframe | |
| `tws` | Toggle water system | |

---

## Targeted Commands
These require a target. Click in console, use `prid <RefID>`, or prefix with `player.`

| Command | Effect | Notes |
|---|---|---|
| `additem <item ID> <count>` | Give item to character | `player.additem 000669A5 5` adds 5 leeks. Negative count removes. |
| `addperk <perk ID>` | Give a perk | Use `help <perkname> 0` to find perk ID |
| `addspell <spell ID>` | Add spell/power/ability/disease | Does not work for shouts; use `teachword` |
| `addfac <faction ID> <rank>` | Add actor to faction | 0 = lowest rank, -1 = remove from faction |
| `advlevel` | Advance level by 1 | No attribute/perk point awarded |
| `AdvSkill <skill> <nn>` | Advance skill by experience amount | See Actor Value Indices for skill names |
| `Cast <spell ID> <target refID> <left/right/voice/power>` | Cast spell at target | |
| `completequest <quest ID>` | Complete quest instantly | May not update related NPCs |
| `DamageActorValue <attribute> <nn>` | Damage attribute by amount | Recovers normally. Use `restoreactorvalue` to fix. |
| `disable` | Make object invisible, no collision | Scripting still runs |
| `dispelallspells` | Dispel all temporary spell effects | |
| `drop <base ID> <amount>` | Force drop items from inventory | Works on quest items |
| `duplicateallitems <container refID>` | Copy all inventory items to target container | |
| `enable` | Undo `disable` | |
| `equipitem <Item baseID> <0/1> <left/right>` | Equip item on NPC | |
| `equipspell <Spell ID> <left/right/voice/instant>` | Equip spell | |
| `equipshout <Shout ID>` | Equip shout | |
| `forceAV <attribute> <nn>` | Force attribute to value via permanent modifier | Shows green highlight |
| `getAV <attribute>` | Get attribute value | e.g. `player.getav heavyarmor` |
| `getAVinfo <attribute>` | Get detailed attribute info | Shows base, modifiers, etc. |
| `getlevel` | Get level of target | |
| `GetLocationCleared <locationID>` | Check clear status | 0 = not cleared, 1 = cleared |
| `getrelationshiprank <target>` | Get relationship rank | Range -4 to 4 |
| `getstage <quest ID>` | Show current quest stage | |
| `hasperk <perk ID>` | Check if actor has perk | Returns rank if found |
| `incPCS <skill name>` | Increase skill one level | Awards perk point and level-up unlike `advskill` |
| `kah` | Kill all hostiles | Added in SE Patch 1.6.1130 |
| `kill <Actor ID (optional)>` | Kill selected actor | Optional ID = who gets blamed |
| `lock <level>` | Lock object at difficulty level | 101+ = Requires Key |
| `MarkForDelete` | Delete object on cell reload | Irreversible |
| `modAV <attribute> <nn>` | Modify attribute by amount | Permanent modifier, shows green highlight |
| `moveto <actor ID>` | Move character to actor | e.g. `player.moveto 0002BFA2` |
| `movetoqt <quest ID>` | Move to quest target location | |
| `openactorcontainer 1` | Open NPC's inventory | |
| `paycrimegold (<jail?> <confiscate?> <faction ID>)` | Pay bounty | |
| `placeatme <actor/object ID>` | Spawn object at current position | Uses base ID, not ref ID |
| `playidle <idle ID>` | Play animation on actor | |
| `pushactoraway <actor ID> <number>` | Push actor in random direction | Negative = pull toward player |
| `recycleactor` | Revive/reset NPC | May come back headless if already looted |
| `removeallitems <actor or container ID>` | Remove all inventory items | Optional: transfer to target container |
| `removeitem <item ID> <count>` | Remove specific items | |
| `removeperk <perk ID>` | Remove perk | Does not refund perk points |
| `removespell <spell ID>` | Remove spell/power/ability/disease | |
| `resetAI` | Reset NPC AI | Forces weapon sheath/re-draw |
| `resethealth` | Restore character to full health | |
| `resetinventory` | Reset character/container inventory to default | |
| `RestoreActorValue <attribute> <nn>` | Restore attribute up to normal value | Fixes `DamageActorValue`; not `modAV`/`forceAV`/`setAV` |
| `resurrect <1>` | Resurrect dead actor | `resurrect 1` = gets up in place with gear |
| `say <dialogue topic ID>` | Force NPC to say dialogue topic | Runs associated scripts |
| `setactoralpha <0-100>` | Set actor opacity | `player.setactoralpha 100` fixes invisibility bugs |
| `setAV <attribute> <nn>` | Set attribute to value | |
| `setessential <base ID> <0 or 1>` | Set actor mortal (0) or essential (1) | Use BASE ID not ref ID |
| `setghost <0 or 1>` | Toggle ghost mode on NPC | Immune to all combat |
| `setgs <setting> <value>` | Set game setting | e.g. `setgs fJumpHeightMin 200` |
| `setlevel <multiplier> <modifier> <min> <max>` | Set NPC level | multiplier in tenths of % (1000 = 100%) |
| `SetLocationCleared <locationID> 1` | Set area as cleared | |
| `setnpcweight <0-100>` | Set NPC/player weight | Also: `snpcw` |
| `setownership <ID>` | Set item ownership | Removes stolen tag. Drop item first, then click it. |
| `setrace <race>` | Change character race | Use plain text name e.g. `nordrace` |
| `setrelationshiprank <target> <#>` | Set relationship between actors | 4=lover, 0=acquaintance, -4=archnemesis |
| `setscale <#>` | Set object/actor scale | 0.1 to 10; default 1 |
| `setstage <quest ID> <stage #>` | Set quest to specific stage | |
| `setunconscious <0/1>` | Make actor unconscious | 1 = trance, 0 = wake |
| `inv` / `showinventory` | List all items in inventory with base IDs | |
| `sifh <#>` | Set actor to ignore friendly hits | `sifh 1` = ignore |
| `sqs <quest ID>` | Show all quest stages | Shows which stages are achieved |
| `stopcombat` | Stop combat with targeted NPC | |
| `StopCombatAlarmOnActor` | Stop all aggression toward actor | Use `player.StopCombatAlarmOnActor` |
| `str <0-1.0>` | Set refraction value | `str 0.000001` = invisible |
| `teachword <word>` | Teach dragon shout word | |
| `unequipitem <Item baseID>` | Unequip item from NPC | Leaves in inventory |
| `unlock` | Unlock targeted object | Works on Requires Key locks |
| `unlockword <word>` | Unlock shout word | |

---

## Untargeted Commands
No target required.

| Command | Effect | Notes |
|---|---|---|
| `bat` | Execute batch file | Runs a .txt of console commands |
| `caqs` | Complete ALL quest stages | Not recommended. May crash. |
| `coc <cellname>` | Transport to named cell | e.g. `coc Riverwood`. `coc qasmoke` = QA test hall |
| `cow <worldspace> <x,y>` | Transport to world cell | e.g. `cow tamriel 5,7` |
| `csb` | Clear screen blood | Useful for screenshots |
| `fov <angle>` | Set field of view | Default ~65; no value sets to 75 |
| `fw <formID>` | Force weather | Temporary. Append `,1` to prolong e.g. `fw 10e1ec,1` |
| `GetGlobalValue <Variable>` | Return value of a global variable | e.g. `GetGlobalValue PDV_GLO_ActivePiety` ✓ |
| `GetInCellParam <Cell ID> <Object ID>` | Check if object is in cell | 0 = not present, 1 = present |
| `GetPCMiscStat <Stat>` | Return misc stat value | e.g. `GetPCMS "days as a werewolf"` |
| `help <Text>` | Find IDs for items/spells/settings | Use quotes for multi-word queries. `help "daedric"` |
| `killallactors` / `killall` | Kill all non-essential loaded actors | |
| `load <name>` | Load a save | Spaces in name require quotes |
| `ModPCMiscStat <Stat> <nn>` | Modify misc stat by amount | |
| `pcb` | Purge cell buffer | Frees memory, often improves FPS |
| `playercreatepotion <MGEF ID>` | Create potion with effect | Up to 3 MGEF IDs |
| `playerenchantobject <object ID> <MGEF ID>` | Spawn enchanted object | Up to 2 MGEF IDs |
| `prid <RefID>` | Select reference by FormID | Required to target quests from console |
| `qqq` | Quit to desktop immediately | |
| `refini` | Refresh all .ini settings | |
| `resetinterior <cellID>` | Reset entire cell to default | Use `pcb` after if recently visited |
| `resetquest <quest ID>` | Reset quest to stage 0 | |
| `saq` | Start all quests | Not recommended. May crash. |
| `save <name>` | Save game to named file | Quotes for names with spaces |
| `saveini` | Save settings to ini | Saves to Data folder, named after last plugin |
| `set <Global Variable> to <Value>` | Set a global variable | e.g. `set PDV_GLO_ActivePiety to 15.0` ✓ |
| `set gameday to <#>` | Set date (1-30) | |
| `set gamedayspassed to <#>` | Set days since game start | |
| `set gamehour to <#>` | Set time of day (24hr float) | e.g. `set gamehour to 18.9833` = 6:59pm |
| `set gamemonth to <#>` | Set month (1-12) | |
| `set gameyear to <#>` | Set year (4th Era) | |
| `set playeranimalcount to <qty>` | Set animal follower count | Resets count; doesn't remove actual follower |
| `set playerfollowercount to <qty>` | Set follower count | Resets count; doesn't remove actual follower |
| `set timescale to <qty>` | Set time speed | Default 20. 1 = real time. NPCs can't cross cells below 1. |
| `setplayerrace <ID>` | Set player race | Plain text e.g. `nordrace` |
| `setpqv <quest ID> <variable ID> <value>` | Set a quest variable | Boolean/int only. Use `sqv` to find variables. |
| `SexChange` | Toggle player or NPC gender | Doesn't change face or voice |
| `SGTM <value>` | Set game time multiplier | Affects combat/movement/dialogue unlike `timescale`. Default 1. |
| `ShowGlobalVars` | List all global variables and values | Scroll with PgUp/PgDown |
| `ShowMessage <ID>` | Display a message form | |
| `showracemenu` | Open character creation | Changing race resets skills/stats |
| `spf <filename>` | Save player face to file | Exports slider settings for CK import. Auto-adds .npc |
| `sqo` | List active quest objectives and states | Human-readable |
| `sqt` | List all active quest IDs and targets | |
| `sqv <quest ID>` | Show all quest variables | Use `setpqv` to modify |
| `stp <u1> <u2> <u3> <chroma>` | Set tint parameters | chroma 0-1 inverted; 1 = B&W, 0 = no tint |
