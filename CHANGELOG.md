# Devotion Changelog

Notable player- and tester-facing changes. Scripts ship from the live MO2 mod
folder; this file records what changed, not the full source.

## 1.0.3 — 2026-07-25

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
    residue already baked into an old save stays until you correct it. Devotion is
    the only thing driving these values to extremes, so with no Devotion penalty
    currently active, open the console, read the value, then add the residue back.
    Use YOUR reading, not these numbers: `player.getav ResistMagic` — if it shows a
    large negative like -22131, `player.modav ResistMagic 22131`; likewise
    `player.getav DamageResist` — `player.modav DamageResist <the shown amount>`.
    Re-check with `getav`, and repeat for any other value that looks out of range.
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
