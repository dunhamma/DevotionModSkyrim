# Devotion Changelog

Notable player- and tester-facing changes. Scripts ship from the live MO2 mod
folder; this file records what changed, not the full source.

## 1.0.4 — 2026-07-27

Combines everything from the unreleased 1.0.3 with the fixes below, so this is
the first public build since 1.0.2.

Thanks to **DrHeisen**, whose independent audit of 1.0.2 found a number of the
defects below. Where his findings and this build's own fixes overlapped, his
analysis is credited in the entry.

### ⚠ Load order — please read

Devotion now ships its own copy of `TempleBlessingScript.pex` (see the shrine
fix below). **Devotion must sit BELOW — that is, at higher priority than — any
Requiem bugfix pack**, because those ship the same file. If Devotion loads
above them their copy wins, and shrines will strip your active effects again.
Nothing errors when this is wrong; the returning bug is the only symptom. In
MO2 you can confirm it under the **Data** tab: `Scripts\TempleBlessingScript.pex`
should show **Devotion** as its provider.

### Fixed — praying at a shrine no longer strips your active effects

- **Fixed (Requiem users): shrines wiped every buff you were carrying and gave
  nothing back.** Requiem's bugfix packs add a line to the shrine activation
  script that dispels **all** active magic effects on you — not just your
  previous blessing, but potions, fortify effects, enchantment effects,
  standing-stone powers, everything. On its own that is invisible, because
  Requiem's blessing lands immediately afterwards. Devotion deliberately makes
  shrines grant no blessing — praying is meant to move your standing with a god
  and write a line in the Book of Days, not hand out a stat buff from whatever
  overhaul you are running — so in combination all that was left was the loss.
  Devotion now ships a corrected script: praying no longer dispels anything,
  and still awards piety and its journal entry exactly as before.
  - **This only ever affected Requiem players.** Base Skyrim's version of that
    script does not dispel, so if you do not run Requiem you never had this
    bug and nothing about your shrines changes — except that the two vanilla
    "blessing removed / blessing received" pop-ups no longer appear, since
    Devotion grants no blessing and both messages were describing something
    that does not happen.

### Added — Bosmer Green Pact food

- **Added: eating meat now rewards a Wood Elf keeping the Green Pact.** The
  reward path existed but had no food attached to it, so nothing a Bosmer ate
  could ever satisfy it. Twenty-two vanilla and DLC meats now count — beef,
  goat, horse, venison, mammoth, horker, boar, ash hopper, chicken, rabbit and
  pheasant, raw and cooked. Eating plants remains the pact **violation** and is
  unchanged. The existing daily limit that covers the other pact-keeping acts
  applies here too, so this cannot be farmed.
- **Added: Requiem food support.** Requiem's own Green Pact item (*Torn Flesh*,
  called *Strange Meat* without Food and Beverages Redone) counts, along with
  Requiem's skeever, fox, bear, mammoth, sabrecat and troll meat and Wrothgar
  Tartare. This is distributed by keyword, so it costs nothing and does nothing
  if you don't run Requiem.

### Fixed — silent, permanent, or save-damaging

- **Fixed: two observance effects still drifted your stats permanently.** The
  Redguard "Remembering" road and rest observances (+8% Stamina Regeneration,
  +5% Health Regeneration) were missing the same `Recover` flag as the effects
  below, on a different effect type that the first sweep did not cover. Every
  time an observance turned on and off it shifted the value again, upward,
  invisibly. Both now revert cleanly. *(Found by DrHeisen.)*
- **Fixed: Devotion could stop working permanently after a single lost script
  tick.** Devotion's main heartbeat re-arms itself at the end of each beat, and
  its owner cannot receive the game's "save loaded" event — so if one beat was
  ever lost (routine when the script engine is saturated in a heavy load order),
  dawn processing, pact activation, the startup choice and the reconcile pass
  all stopped for the rest of the playthrough, with nothing in the log. A
  watchdog on load now restarts the heartbeat if it has stalled. *(DrHeisen.)*
- **Fixed: a menu that could not open silently broke the Bosmer Old Contract.**
  When the game refused to show a choice — because another menu already had the
  screen — Devotion read the non-answer as an answer. Worst case: a Bosmer's
  forced reckoning **severed the Old Contract pact with no player input**. Four
  sleep rites also stamped a three-day "you declined" cooldown, and two of them
  discarded three nights of progress, for prompts nobody ever saw. A menu that
  does not appear now changes nothing and simply retries. *(DrHeisen.)*
- **Fixed: uninstalling left Devotion's effects on your character.** The
  uninstall strip listed its spells one by one and missed the Altmer Discipline
  and Redguard Remembering families, plus every Daedric pact boon and price —
  including **Malacath's speed price**, so an uninstalled long-pact Orc stayed
  permanently slower. All are now cleared. *(DrHeisen.)*
- **Fixed: hit detection died whenever the reaction data was missing.** All
  hit-driven detection — combat sessions and near-death sampling — sat behind a
  check for a data file it does not use. If that file was missing or corrupt,
  every near-death rescue (Orc Code Holds, the Bosmer Baan Dar gap, the Argonian
  Sithis burst) silently stopped working. Hit detection no longer depends on it.
  *(DrHeisen.)*
- **Fixed: Azura's likes and dislikes never loaded.** An internal name mismatch
  (`azurah` against her canonical `Azura`) meant twelve of her reaction rows —
  including her three strongest dislikes — and her whole per-race stance table
  were skipped, so Azura could not react to anything you did. Her tables rebuild
  once automatically on an existing save. *(DrHeisen.)*
- **Fixed: MCM controls could trigger the wrong action.** Menu option IDs are
  handed out per page, and Devotion only cleared a few of them between pages, so
  a leftover ID from an earlier page could match a control on the page you were
  looking at — including destructive developer controls. Every option ID is now
  cleared before a page is built. *(DrHeisen.)*

- **Fixed: disfavor stings and several neglect penalties were applying as
  bonuses.** Twenty-two of Devotion's penalty effects were authored in a
  self-cancelling form — flagged as detrimental *and* carrying a negative
  amount, which the engine reads as a negative penalty, i.e. a buff. Every
  disfavor sting (all seven domains, light and sharp), the Kyne, Shor, Tsun,
  Stuhn, Talos, Arkay and Dibella neglect penalties, and the Ash'abah spine's
  Speech cost now carry positive amounts, so they subtract as their names and
  descriptions say. Race neglect penalties that were never flagged detrimental
  (Redguard, Imperial, Orc, Dunmer, Altmer, Bosmer, Breton, Argonian, Khajiit),
  the Daedric pact prices, and the Breton creed losses used the other valid
  convention all along and are unchanged. *(Convention identified by DrHeisen.)*

### Fixed — awards, caps, and daily timing

- **Fixed: daily caps and cooldowns were spent on awards that never landed.**
  A cap slot was claimed the moment an award was proposed, before the multipliers
  that can reduce it to nothing were applied — so a cursed or ineligible
  character burned their daily allowance earning zero. The cap is now claimed
  only when piety actually lands. *(DrHeisen.)*
- **Fixed: shrine prayers and signal activators could eat the day's credit for
  nothing.** The once-per-day charge was spent before the prayer was routed, so
  praying early after a load — the usual case — consumed the day and returned
  no piety and no feedback. The charge is now spent only on a prayer that lands.
  *(DrHeisen.)*
- **Fixed: several "once a day" limits used midnight instead of Devotion's dawn.**
  Devotion's day rolls at 06:00, but a number of daily gates still rolled at
  midnight, so a limit could reset mid-sleep or be spent twice inside one
  devotional day. Roughly two dozen daily gates now share the 06:00 day —
  including the shared anti-farm limits most signals pass through. Journal dates
  and multi-day countdowns deliberately stay on the calendar day. *(DrHeisen.)*
- **Fixed: the first in-game day refused some credit outright.** A stored "day"
  of zero is indistinguishable from game day zero, so on a brand-new save every
  shrine-prayer credit and the first hearth-rest declaration were refused.
  *(DrHeisen.)*
- **Fixed: a near-death rescue could spend its daily charge on a death it did not
  prevent.** The tier-3 save now confirms you actually survived before the day's
  charge is spent. The heal still fires either way. *(DrHeisen.)*
- **Fixed: Orc Code Holds had no daily limit** and now matches its two sibling
  rescues, with a visible notification when it fires. *(DrHeisen.)*
- **Fixed: killing a Thalmor who attacked you counted as an unprovoked killing.**
  The check looked only at whether the victim was a scripted enemy and never at
  whether they were already hostile, so cutting down a Justiciar patrol that
  opened fire on you applied the same consequences as an assassination. Choosing
  to attack a neutral Thalmor still counts as a choice. *(DrHeisen.)*
- **Fixed: bard performances stopped registering after restarting Skyrim.** An
  anti-double-award timer measured time since the application launched but was
  saved to disk, so after a restart it read hours into the future and discarded
  every performance until the new session ran longer than the old one.
  *(DrHeisen.)*
- **Fixed: Auri-El ignored its own tuning values**, returning hardcoded numbers
  instead. The values are unchanged; they now respond to tuning. *(DrHeisen.)*
- **Fixed: a Dunmer sleeping several times in one night** was repeatedly offered
  the "mark a new home" prompt. *(DrHeisen.)*

### Improved — performance and log noise

- **Improved: equipping an item is dramatically cheaper.** Devotion answered
  "does this item matter?" by re-reading and re-resolving its reaction data from
  scratch on every check, sixteen times per equip — in a large load order,
  hundreds of engine lookups and a very large number of plugin-name comparisons
  **every time you equipped anything**. Every entry is now resolved once when
  the save loads, and the check costs nothing at runtime. The blocked-hit path,
  which paid the same cost on every blocked hit, is fixed with it. *(DrHeisen.)*
- **Improved: every scored action costs far less.** A broadcast action (a kill, a
  craft, a lockpick, a book) asks all ~34 deities to score it, and about thirty
  of them have no entry for that event yet still paid for the lookup. Each deity
  now knows in advance which events it can score. The shortcut fails safe: if it
  is ever unsure, it falls back to the old full check, so piety can never be
  silently withheld. *(DrHeisen.)*
- **Improved: text formatting no longer runs 44 passes over every line.** Every
  toast, journal line and panel string was rewritten 44 times; 43 of those passes
  could not change anything. One side effect of the cleanup: authored prose
  reading "the Hist" mid-sentence is no longer wrongly capitalised. *(DrHeisen.)*
- **Improved: no more Papyrus log line for every corpse.** Devotion's kill
  receiver logged unconditionally, whether or not you were debugging. It is now
  behind the debug setting like every other trace. *(DrHeisen.)*
- **Improved: quieter background polling.** The bard poll drops to a slower
  cadence when nothing is happening and returns to full speed the moment a
  performance starts; location checks sample every three seconds instead of every
  second; a duplicate-state sweep runs every thirty seconds instead of every ten;
  and the main heartbeat skips its work while a menu owns the screen. The
  heartbeat itself stays at one second — the two things that need it are
  latency-sensitive. *(DrHeisen.)*
- **Improved: uninstalling no longer leaves thousands of dead entries in your
  save.** Devotion's quest-reaction queue blanked six keys per finished job and
  left roughly two dozen behind each time. Finished jobs are now cleared
  completely, and existing saves get a one-time sweep. *(DrHeisen.)*

### Added

- **Added: "Check stat damage" and "Repair stats"** (MCM → Player → Maintenance).
  The first is read-only and lists every value still carrying permanent drift
  from older builds. The second removes Devotion's effects, clears that drift,
  and re-grants your abilities normally — the automatic cure for the save damage
  described in the first entry below, replacing the manual console procedure.
  **Save first.** Note plainly: it also clears permanent modifiers *another* mod
  placed on those same values — rare, but real. There is no automatic pass;
  nothing runs unless you press the button. *(Design by DrHeisen.)*

### Changed — internal

- **Changed: removed retired scaffolding.** An early "sacred place" system that
  was never connected — and whose feature already ships as the Argonian
  bed-of-choice, the shared hearth-rest declaration, and Khajiit road-homes — is
  reduced to a stub; twenty-one reward slots pointing at spells that were never
  created, thirty tuning values nothing read, and sixteen write-only debug keys
  are removed. No player-facing change.
- **Changed: Syrabane's curated signal numbers** were renumbered off four IDs
  that Boethiah already used. Neither deity's behaviour changes today.

### Fixed — messages

- **Fixed: four more malformed messages.** The three Redguard "survey" messages
  tried to insert your standing using a code the game's message records cannot
  process, so the line was logged as invalid and displayed wrong; the sentence
  has been rewritten to read correctly without it. The Bosmer "Naming" message
  had an unescaped `%`. *(DrHeisen.)*

### Fixed — the original 1.0.3 set (2026-07-25, now part of this release)

- **Fixed: runaway stat drift (save-corrupting).** Devotion applies its neglect,
  disfavor, pact-price, and blessing effects as toggled abilities, but 418 of its
  422 value-modifier magic effects were missing the engine's `Recover` flag.
  Without it, each application baked the actor-value change in permanently and did
  NOT revert it on removal — so every on/off cycle shifted the stat further, for
  the life of the save. Negative effects drifted stats ever more negative (two
  users reported e.g. -22131% Magic Resistance and -5000 armor rating); positive
  effects drifted stats invisibly upward. All value-modifier effects now carry
  `Recover`, so removal reverts cleanly and the drift stops. No new game required.
  - **Curing an already-affected save:** the flag stops further drift, but stat
    residue already baked into an old save stays until you clear it. Use
    **MCM → Devotion → Player → Maintenance → Check stat damage** to see what your
    save is carrying, then **Repair stats** to clear it (save first). That button
    replaces the manual console procedure earlier 1.0.3 notes described; if you
    prefer to do it by hand, read the value with `player.getav ResistMagic` and
    add the residue back with `player.modav ResistMagic <the amount shown>`,
    repeating for any other value that looks out of range.
- **Fixed: dungeon music in safe interiors while cursed.** For a player under a
  lycanthropy or vampirism "curse", Devotion added a global music track — built
  from Skyrim's dungeon music — that overrode the normal music everywhere,
  including inns, homes, and temples, until the curse was cured. The persistent
  override is removed; the curse now plays a single short sting at the moment it
  takes hold or lifts. Saves stuck with the dungeon music clear themselves
  automatically on the next load.
- **Fixed: garbled Redguard "Remembering" message.** The observance-choice message
  contained bare `%` characters the game misread as format codes, logging a
  warning and mangling the line. Reworded to display cleanly.
- **Improved: larger, longer-lasting corner notifications on high-res displays.**
  The bottom-right toast pop-ups are enlarged on 1440p and 4K screens (they were
  rendering at roughly half physical size on a 4K overlay) and stay on screen a
  little longer so there is time to read them. 1080p and below are unchanged.
- **Fixed: Daedric pact prices and pool boons did nothing.** The maximum-pool
  parts of every Daedric pact — the Health/Magicka/Stamina "price" (Azura,
  Vaermina, Sanguine, Clavicus Vile, Hermaeus Mora, Peryite) and the pool "boon"
  (Sheogorath, Namira, Hircine) — were authored as current-value modifiers the
  game regenerates away (and the pact wrapper restored immediately), so they
  imposed and granted nothing. They now correctly raise/lower your **maximum**
  pool, so pacts have the felt cost and benefit they describe. The skill, combat,
  and resistance boons were already working and are unchanged.
- **Fixed: Hermaeus Mora's Champion boon was mis-wired.** Its two effects both
  pointed at the same Magicka effect, so a Mora Champion got doubled Magicka and
  no Alteration. It now grants the contracted **Alteration +20 and Fortify
  Magicka +20**.
- **Changed: cleaned up Daedric path scripting.** Removed a redundant duplicate
  script attached to all 16 Daedric-path quests (the concrete script already
  inherits the base). No player-facing change; a fresh save picks it up.
- **Improved: curse cures restore instantly, with clearer Redguard vampire-cure
  wording.** Curing lycanthropy or vampirism now re-applies your reward/neglect
  layer immediately instead of on the next in-game dawn, so any curse-linked stat
  penalty lifts at once. The Redguard vampire-cure message now states plainly that
  the ancestors' protection returns when you take up the death-duty again — it is
  intentionally withheld until then, not a bug.

## 1.0.1 — 2026-07-18

- **Fixed: crash to desktop when cooking or tempering.** Devotion's "Craft Item"
  Story Manager receiver quests were missing the `ANAM` (Next Alias ID) field the
  Creation Kit writes for every quest. The malformed record could make the game
  dereference an invalid handle while delivering the craft event, crashing to
  desktop — most reliably when cooking at a pot or tempering at a grindstone or
  workbench. All receiver quests now carry `ANAM`. No new game required.
- **Fixed: Namira's boon did nothing under Requiem.** Namira's Seeker/Devoted/
  Champion boon granted a health-regeneration *rate* multiplier (`HealRateMult`),
  which Requiem effectively disables — base regen is ~0, so a rate multiplier
  multiplies nothing. It is now a flat **Fortify Health + Fortify Stamina**
  (+25/+40/+50 per tier, provisional) that Requiem honors. Namira was the last
  regen-rate holdout among the Daedric boons.

## 2026-07-16

- **Changed: MCM is now players-only by default.** The four developer tabs
  (Status, Debug: State & Rewards, Debug: Daedric & Curse, Debug: Pacing &
  Pantheons) are hidden entirely on a shipped copy — the tabs no longer render
  at all, and the old one-click "Developer Options" toggle has been removed from
  the Player page. Players see only **Player** and **Settings**. Owners reveal
  the debug tabs from the console with `set PDV_GLO_DebugLevel to 3` (then reopen
  the MCM); `set PDV_GLO_DebugLevel to 0` re-hides them. See
  `PDV_SkyrimConsoleReference.md`.
- **Changed: tabs consolidated.** The "Compatibility" tab is renamed **Settings**
  and now hosts the devotional-path selector (Pilgrim's Path / Wayfarer's Path),
  which moved off the removed "Experience Mode" tab. The old "What changes"
  read-only breakdown is gone. On a shipped copy the Settings tab shows the path
  selector, the Survival and CC integration toggles, and the custom-race
  Detected + Re-detect origin recovery tools; the custom-race mapping on/off
  toggle and the grey diagnostic readouts are debug-only (mapping stays ON by
  default).
- **Changed: "Prepare for uninstall" moved to the Player page** (new Maintenance
  section) so players can prep a throwaway removal save without dev access. The
  SAVE-FIRST warning is unchanged. Running it before removing the plugin strips
  Devotion's player-attached spells/factions and clears most saved data, leaving
  a far smaller footprint than deleting the plugin alone (which strands stuck
  abilities and orphaned scripts). It is best-effort, not a truly clean save.
- **Improved: "Export Devotion Report"** now also records the Devotion build
  version, PapyrusUtil version, an Environment block (Experience Mode, custom-race
  mapping + origin detection, survival and CC integration toggles), a Diagnostics
  block (Breton tradition, Daedric pending states, last diegetic dispatch/tone/
  skipped), and a footer pointing to the Papyrus log and SKSE crash log.
- **Tester note:** the Papyrus log is separate from the report file and Skyrim
  keeps Papyrus logging **off by default**. For crashes or hard-to-reproduce
  bugs, enable it via `SkyrimCustom.ini` `[Papyrus]` (`bEnableLogging=1`,
  `bEnableTrace=1`, `bLoadDebugInformation=1`) and attach
  `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` alongside
  `PDV_DevotionReport.txt`.

## 2026-06-15

- **Added: "Export Devotion Report" MCM button** (Player page, no Developer
  Options required). Writes a full devotion snapshot to `PDV_DevotionReport.txt`
  in the Skyrim game folder so beta testers can attach one file to a bug report
  instead of digging for logs or numbers. The file includes mod/schema versions,
  in-game day, race, the summary/mode/patron/standing/curse/favor/neglect lines,
  the full Survey readout, and a per-deity ledger (tier + piety + scratch).
  Implemented as `PDV__ManagerQuest.ExportDevotionReport()` (writes via
  `MiscUtil.WriteToFile`) wired to the MCM handler in `PDV_MCM`. Pure script;
  no new CK records, properties, or SEQ changes. Save-safe.
- **Added: beta tester guide** (`Devotion_BetaTesterGuide.docx`) covering
  dependencies, what's in the mod, design intent, known limitations/beta status,
  and how to give useful feedback (including the Export Devotion Report flow and
  a copy/paste report template).
