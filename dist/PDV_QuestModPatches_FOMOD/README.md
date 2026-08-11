# Devotion - the mod, plus optional per-mod quest patches

This archive is the whole distribution. Install it with your mod manager and run the
installer; there is no separate core download.

- **Devotion core installs automatically.** It is a required part of the installer, not an
  option you can miss.
- **The 77 per-mod patch options are optional.** Each one is locked to its source plugin: if
  the mod it patches is not active in your load order, the option cannot be selected and
  nothing for it is installed.

Place `Devotion.esp` late in your load order by hand rather than letting LOOT decide. Do not
keep `PDV_AuthoriaARR_Combined.esp`, `PDV_QuestReactionMatrix_ARR.json`, or any older Devotion
compatibility package alongside this one -- those overwrite Devotion's core scripts.

Most options install a single per-mod reaction channel. Five install an ESP:

- Aetherium Forge Destroys Items installs `PDV_Patch_AFDI.esp`, an observer quest, its
  `.seq`, and its script. Load it after `Aetherium Forge Destroys Items.esp` and
  `Devotion.esp`.
- Daedric Shrines AIO installs `PDV_Patch_DaedricShrinesAIO.esp` and matching BOS swaps.
  Load the patch after `Devotion.esp`.
- Once We Were Here, War's Folly, and Whispers of the Depths each install an ESL-flagged
  dialogue-fragment patch. Load each `PDV_Patch_*.esp` after its named source quest plugin.

Keeping all five `PDV_Patch_*.esp` files below `Devotion.esp` and below their source
plugins satisfies those master and override relationships. Thieves Guild Alternative
Endings remains data-only: its quest-stage adapter is JSON, not an ESP.

## For testers

Expected surface behavior for one resolving outcome is at most one transient Devotion toast
and one Book of Days beat, even when several deities react. Both surfaces name the source
mod, so a tester can identify which installed patch fired without reading logs. Altmer are not excluded from
Prisma UI: credited heritage/practice acts use the same toast policy as other races,
zero-credit acts remain silent, and only a real tier transition may add a separate Chronicle
beat. Gameplay must not open the focused Prisma panel or Book of Days.

If you are reporting back, record the option, the source mod's version, the route or stage
you took, expected and observed piety, toast count, Book count, save/load result, and your
logs. `setstage` can show that routing fired, but it cannot tell you the reaction was the
right one.

Report anything that looks wrong on the mod page rather than assuming it is your load order.
