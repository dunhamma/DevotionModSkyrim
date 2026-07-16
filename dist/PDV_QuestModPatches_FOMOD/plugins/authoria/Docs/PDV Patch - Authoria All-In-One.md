# Devotion Patch - Authoria All-In-One

Every supported quest-mod patch for the Authoria (Requiem Reforged) list, in
one package with a single plugin.

## What it needs
- Devotion (PlayerDevotion), with per-mod channel support.
- The Authoria list (or any load order carrying all three of: War's Folly.esp,
  Once We Were Here - Quest Mod.esp, Slays-Many-Beasts Quest Mod.esp).

## What it contains
- PDV_Patch_Authoria_QuestMods.esp (ESL-flagged; 21 records; masters War's
  Folly, Once We Were Here, and Slays-Many-Beasts).
- 9 dialogue-hook script fragments (Scripts/ + Source/).
- All 10 matrix channels (Channels/): Sirenroot, The Rot Below, The Frozen
  Heart, Depths of the Soul, Baba Yaga, Bark and Bite, Before the End, War's
  Folly, Once We Were Here, Whispers of the Depths.

## Do NOT combine with the individual patches
This package replaces the ten individual patches. Installing both would put two
plugins over the same records and duplicate every channel. The FOMOD enforces
the choice; if you install manually, pick one lane or the other.

## Why one plugin here
A patch plugin masters every mod it touches, and a missing master stops the
game loading. The individual patches each master exactly one mod, so they work
in any load order. Authoria ships all three targets, so the combined plugin is
safe and keeps your plugin list to one ESL-flagged file.

The seven data-only patches (channels, no records) carry no plugin either way.

## Proof state
Machine-verified only: all 10 channels pass the Devotion compiler check, and
the plugin's 21 records were read back from disk after writing. The rows firing
in-game is RUNTIME-VERIFY pending.

