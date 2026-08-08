# Devotion - experimental build with per-mod quest patches

This archive is the whole distribution. Install it with your mod manager and run the
installer; there is no separate core download.

- **Devotion core installs automatically.** It is a required part of the installer, not an
  option you can miss.
- **The 46 per-mod patch options are optional.** Each one is locked to its source plugin: if
  the mod it patches is not active in your load order, the option cannot be selected and
  nothing for it is installed.

Place `Devotion.esp` late in your load order by hand rather than letting LOOT decide. Do not
keep `PDV_AuthoriaARR_Combined.esp`, `PDV_QuestReactionMatrix_ARR.json`, or any older Devotion
compatibility package alongside this one -- those overwrite Devotion's core scripts.

Most options install a single per-mod reaction channel. Three install a little more:

- AFDI installs an ESL-flagged observer quest, its `.seq`, and its script.
- Daedric Shrines AIO installs an ESL-flagged activator plugin and matching BOS swaps.
- TG Alternative Endings installs a data-only quest-stage adapter; it does not replace core
  scripts.

## For testers

Expected surface behavior for one resolving outcome is at most one transient Devotion toast
and one Book of Days beat, even when several deities react. Altmer are not excluded from
Prisma UI: credited heritage/practice acts use the same toast policy as other races,
zero-credit acts remain silent, and only a real tier transition may add a separate Chronicle
beat. Gameplay must not open the focused Prisma panel or Book of Days.

If you are reporting back, record the option, the source mod's version, the route or stage
you took, expected and observed piety, toast count, Book count, save/load result, and your
logs. `setstage` can show that routing fired, but it cannot tell you the reaction was the
right one.

This package is experimental and not supported.
