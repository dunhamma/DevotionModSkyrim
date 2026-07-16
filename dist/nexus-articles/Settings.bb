[size=6][b]Settings and Controls - using the Devotion menu[/b][/size]

Everything you can change or check lives in the Mod Configuration Menu (the SkyUI settings menu you open with the Escape menu, then Mod Configuration). Open it and pick [b]Devotion[/b] from the list on the left. There are two tabs: [b]Player[/b] and [b]Settings[/b]. Nothing here is required reading - Devotion runs fine on its defaults - but this is where you check your standing, tune the feel, and grab a report if something goes wrong.

[size=5][b]The Player tab[/b][/size]

This tab is your at-a-glance status board plus a few actions. The top block is read-only: your current patron, standing, active path, any curse, recent favor, and whether you are neglecting anyone. It updates itself; you cannot edit it here.

[list]
[*][b]Survey Devotion[/b] - opens a written readout of where your faith stands right now, in plain devotional language and without spoiling numbers. Use this any time you want to know how a god sees you.
[*][b]Export Devotion Report[/b] - writes a snapshot of your whole devotion state to a text file so you can attach it to a bug report. See "Reporting a problem" below.
[/list]

[b]Book of Days[/b]

[list]
[*][b]Open Book of Days[/b] - opens your rolling devotion journal, the in-world record of what your gods have noticed.
[*][b]Book of Days key[/b] - bind a hotkey to open that journal any time without going through the menu. Unbound by default.
[*][b]Open Devotion panel[/b] - bind a hotkey for the Devotion status panel. Unbound by default.
[/list]

[b]Maintenance[/b]

[list]
[*][b]Version[/b] - the installed Devotion build number. Handy to quote in a bug report.
[*][b]Prepare for uninstall[/b] - preps a clean-as-possible removal. See "Removing Devotion" below. Save first.
[/list]

[size=5][b]The Settings tab[/b][/size]

[b]Devotional Path[/b]

[list]
[*][b]Current path[/b] - switches between the two ways to experience Devotion. This is the one setting most players will want to think about.
[/list]

[list]
[*][b]Pilgrim's Path[/b] (default) - the authored balance. Devotion is earned at its intended pace, daily gains are held to their normal ceilings, and neglect bites at full strength. This is the path built for survival and Requiem-style playthroughs, where faith should cost something.
[*][b]Wayfarer's Path[/b] - a gentler pace for non-survival players. Piety comes in faster (about 1.25x), daily ceilings are wider, neglect decays more slowly and forgives longer, and ordinary adventuring - even just leveling up - counts for a little devotion. Pick this if you want the flavor without the discipline.
[/list]

You can switch paths at any time; it changes how future devotion is earned, not what you have already banked.

[b]Presentation[/b]

[list]
[*][b]In-Game Effects[/b] - the on-screen devotion cues: screen effects, sounds, and music stingers that play when your standing shifts. On by default. Turn it off for a quieter, effects-free experience - your Book of Days journal still records everything either way.
[*][b]Notifications[/b] - the corner pop-up messages that appear when your devotion changes. On by default. Turn it off to play with no pop-ups; the Book of Days journal still records everything.
[/list]

[b]Custom Race[/b]

If you play a vanilla race this section needs no attention. It exists for custom-race and custom-vampire users.

[list]
[*][b]Detected[/b] - shows which devotional origin Devotion resolved you to.
[*][b]Re-detect origin[/b] - runs origin detection again. Use it if you installed a custom-race patch after starting, or if your origin resolved to the wrong profile. Beast forms are handled automatically and should not be re-detected mid-transformation.
[/list]

[b]Survival Context[/b]

[list]
[*][b]Survival integration[/b] - if you run a survival mod (Survival Mode or SunHelm), this lets its hardship gently soften how much devotion you earn while you are cold, hungry, or exhausted. It never grants piety on its own and it is safe to leave on with no survival mod installed. On by default.
[/list]

[b]AE / Creation Club[/b]

[list]
[*][b]CC integration[/b] - lets supported Anniversary Edition and Creation Club content contribute small optional devotion signals. No CC content is required for Devotion to work. On by default.
[/list]

[size=5][b]Reporting a problem[/b][/size]

Good reports get fixed faster. If something looks wrong:

[list]
[*][b]1.[/b] Open the [b]Player[/b] tab and click [b]Export Devotion Report[/b]. This writes [b]PDV_DevotionReport.txt[/b] into your Skyrim game folder (the same folder as SkyrimSE.exe). Attach that file to your report. If you cannot find it, search your PC for PDV_DevotionReport.txt.
[*][b]2.[/b] Tell us your Devotion build number (Player tab, Maintenance, Version), your race, and what you expected versus what happened.
[/list]

For a crash or a bug that is hard to reproduce, a Papyrus log helps a lot - but Skyrim keeps Papyrus logging turned off by default. To turn it on, add this to [b]SkyrimCustom.ini[/b] (in Documents\My Games\Skyrim Special Edition):

[code]
[Papyrus]
bEnableLogging=1
bEnableTrace=1
bLoadDebugInformation=1
[/code]

Then reproduce the problem, quit, and attach:

[list]
[*]Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
[*]any Documents\My Games\Skyrim Special Edition\SKSE\crash-*.log
[/list]

alongside PDV_DevotionReport.txt.

[size=5][b]Removing Devotion[/b][/size]

Devotion adds scripts, blessings, and other effects to your character, so simply deleting the plugin can leave stuck abilities and orphaned scripts in your save. If you want to stop using Devotion mid-playthrough:

[list]
[*][b]1.[/b] Make a save you are willing to throw away first.
[*][b]2.[/b] Player tab, Maintenance, click [b]Prepare for uninstall[/b] and confirm. This strips Devotion's added blessings and factions, clears most of its saved data, and stops the mod.
[*][b]3.[/b] Make a fresh save, then remove the plugin.
[/list]

This is best effort, not a guaranteed clean save - the only fully clean removal is a save made before Devotion was ever installed. But running it first leaves a far smaller footprint than pulling the plugin cold.
