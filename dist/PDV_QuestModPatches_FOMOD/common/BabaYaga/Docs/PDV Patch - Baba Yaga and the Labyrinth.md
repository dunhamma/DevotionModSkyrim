# Devotion Patch - Baba Yaga and the Labyrinth

Teaches Devotion how the gods react to the outcomes of Baba Yaga and the Labyrinth.

## What it needs
- Devotion (PlayerDevotion), with per-mod channel support (scans
  SKSE/Plugins/StorageUtilData/PlayerDevotion/Channels/).
- ksws03_quest.esp active in your load order.

## What it contains
- Matrix channel: PDV_QRM_BabaYaga.json -- 1 row / 1 quest key (s600).
- Plugin: no.

## Install
Install through the Devotion Quest Mod Patches FOMOD, or drop this folder in
as a normal mod. If it ships a plugin, enable it and let it sort after the
mod it patches.

## Proof state
Machine-verified only: the matrix channel passes the Devotion compiler check,
and any plugin records were read back from disk after writing. The rows firing
in-game is RUNTIME-VERIFY pending -- if a stage number proves wrong in play,
the patch awards nothing rather than the wrong thing.

Devotion never fires for a mod you do not have: an absent plugin resolves to
nothing and the channel's rows stay dormant.

