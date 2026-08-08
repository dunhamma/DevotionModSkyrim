==============================================================
 DEVOTION
 Religious devotion for Skyrim Special Edition, by race
==============================================================

Devotion tracks your character's religious standing through the
theological tradition their race actually holds. Your daily conduct
moves per-deity piety, and piety gates tiered blessings, the slow
weight of neglect, and patron-specific content.

It is built for roleplayers who want religion to mean something
mechanically -- not a shrine-touch buff.


REQUIREMENTS
--------------------------------------------------------------
  Skyrim Special Edition
  SKSE64
  SkyUI                     (MCM configuration menu)
  PapyrusUtil SE            (data storage)
  PrismaUI                  (in-game Survey / Book of Days)
  Keyword Item Distributor  (powerofthree's KID)


INSTALLING
--------------------------------------------------------------
  Mod Organizer 2 / Vortex:
    Install this archive with your mod manager as normal, then
    enable the mod and Devotion.esp.

    The installer fits core plus optional per-mod patches into one
    pass. Devotion itself always installs. The patch options teach
    Devotion how the gods react to the outcomes of specific quest
    mods, and each is locked to its source plugin -- if you do not
    have that mod active, the option cannot be selected and nothing
    for it is installed.

  Manual:
    Extract the contents into your Skyrim Special Edition\Data
    folder, then enable Devotion.esp.

  Load order:
    Place Devotion.esp by hand rather than letting LOOT decide.
    Late in the order is correct. If you run another religion or
    worship overhaul, Devotion takes that slot instead -- they
    are not designed to run together.

  Start a NEW game, or a save that has never had Devotion
  installed. Adding it mid-playthrough is not supported.

  Updating from an earlier Devotion version is save-safe: install
  over the old files on your existing Devotion save -- no new game
  needed.


UNINSTALLING
--------------------------------------------------------------
  Open the MCM -> Player -> Maintenance -> "Prepare for uninstall"
  and SAVE FIRST. This strips Devotion's spells and factions and
  clears most of its saved data before you remove the plugin.

  It is best-effort, not a clean save. Removing the plugin without
  running it first will strand abilities and orphaned scripts.


FIRST STEPS
--------------------------------------------------------------
  - A startup message asks how your character came to their faith.
  - The MCM ("Devotion") holds your settings and the devotional
    path selector (Pilgrim's Path / Wayfarer's Path).
  - Use the Survey power to read your standing with the gods.


SOURCE CODE
--------------------------------------------------------------
  Full Papyrus source ships in Scripts\Source\ (96 .psc files).
  It is not needed at runtime -- it is there so you can read it,
  learn from it, or rebuild the scripts yourself.


CREDITS
--------------------------------------------------------------
  See Credits.txt for third-party asset credits and their
  permissions.
