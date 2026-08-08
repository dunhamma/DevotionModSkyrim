# Devotion Patch - The Frozen Heart

Teaches Devotion how the gods react to the outcomes of The Frozen Heart.

## What it needs
- Devotion (PlayerDevotion), with per-mod channel support (scans
  SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/).
- ksws07_quest.esm active in your load order.

## What it contains
- Matrix channel: PDV_QRM_FrozenHeart.json -- 11 rows / 3 quest keys (s1300, s10000, s20100).
- Plugin: no.

## Install
Install through the Devotion Quest Mod Patches FOMOD, or drop this folder in
as a normal mod. If it ships a plugin, enable it and let it sort after the
mod it patches.

## Notes

Devotion never fires for a mod you do not have: an absent plugin resolves to
nothing and the channel's rows stay dormant. If an outcome is not recognised,
the patch awards nothing rather than the wrong thing.
