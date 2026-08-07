# Devotion ARR 2.5 experimental PatchHub

Install `Devotion-1.0.4-20260807.zip` first, then this PatchHub below Devotion. Select only options whose source plugin is present. Do not retain `PDV_AuthoriaARR_Combined.esp`, `PDV_QuestReactionMatrix_ARR.json`, or an older compatibility package that overwrites Devotion's core scripts.

The 41 options are independent. Most install one per-mod reaction channel. A few install a narrow hook ESP, a data adapter, or an optional observer:

- AFDI installs an ESL-flagged observer quest, its `.seq`, and its script.
- Daedric Shrines AIO installs an ESL-flagged activator plugin and matching BOS swaps.
- TG Alternative Endings installs a data-only quest-stage adapter; it does not replace core scripts.

Expected surface behavior for one resolving outcome is at most one transient Devotion toast and one Book of Days beat, even when several deities react. Altmer are not excluded from Prisma UI: credited heritage/practice acts use the same toast policy as other races, zero-credit acts remain silent, and only a real tier transition may add a separate Chronicle beat. Gameplay must not open the focused Prisma panel or Book of Days.

Record the option, source-plugin version, route/stage, expected and observed piety, toast count, Book count, save/load result, and logs. `setstage` can prove routing but cannot clear inferred semantic correctness.

This package is machine-verified experimental, not supported. Runtime routing, player-surface behavior, semantic correctness, and save/load behavior remain open until tester evidence is recorded.
