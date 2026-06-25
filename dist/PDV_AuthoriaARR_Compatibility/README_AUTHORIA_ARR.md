# Devotion - Authoria / ARR Compatibility + Extensibility

This add-on makes Devotion (PDV) aware of the Authoria - Requiem Reforged
list's extra theological content. It is an add-on: install the core Devotion mod
first (`PDV_FirstLook_20260625.zip`), then this package on top.

This is a trusted-tester integration package. Machine/readback checks pass, one
ARR quest backend route has passed local runtime smoke, and local shrine-prayer
smoke passed for click/top-left feedback, Book of Days entry, and same-day
no-double-award. Public Authoria support is not claimed until maintainer
acceptance is complete.

## What's in this package

| File | What it does |
|------|--------------|
| `PDV_AuthoriaARR_Compatibility.esp` | ESL-flagged. 11 Daedric shrine-prayer Activators (one-off +2 piety prayer, once/day) for the `man_DaedricShrines` statues. Masters: `Skyrim.esm`, `Devotion.esp`. |
| `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini` | Base Object Swapper rule that makes the decorative Daedric statues clickable by swapping their STAT meshes to the prayer Activators. Requires po3 Base Object Swapper. |
| `SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR.json` | The extensibility channel: 24 quest-reaction cells / 22 quest keys / 20 watched quests / 24 faucet acts from Vigilant, Glenmoril, Unslaad, Olenveld, The Forgotten City, Saints & Seducers, DAc0da, and the Ebony Blade curse. Loaded automatically alongside the core matrix; silently no-ops for any content you do not have. |

## Requirements / load order

1. `Devotion.esp` (core PDV) active before `Requiem for the Indifferent.esp`.
2. po3 Base Object Swapper, for clickable shrine prayers.
3. `PDV_AuthoriaARR_Compatibility.esp` after `Devotion.esp`.
4. The Archon religion overhaul family stays disabled in the ARR profile.

## Notes for testers

- The shrine-replacement half is handled by disabling Archon and letting
  `Devotion.esp` own the cure-only shrine spells.
- The add-on half is the ARR quest-matrix channel plus the Daedric shrine-prayer
  ESP/BOS swap.
- Daedric shrine prayers give a flat +2 to that Prince once per in-game day and
  show a confirmation line. Uncommitted Princes accumulate piety in the
  background and will not appear in the Devotion panel until you commit to them.
- Local ARR backend route proof passed on 2026-06-25: matrix reload showed core
  73 watched quests and ARR channel 20 watched, then
  `setstage zzzAoMMqGoodEnd 255` logged Stendarr +12 and
  `[PDV] QuestReaction: 5047158|255 applied 1 cells.` No front-end toast was
  observed or required for that backend quest-reaction check.
- Local shrine-prayer proof passed for the clickable shrine route, top-left
  prayer line, Book of Days Chronicle entry, and same-day no-double-award. The
  Prisma overlay toast did not appear and is deferred to the Prisma parity
  backlog.
- Five quest-reaction cells are flagged RUNTIME-VERIFY because their terminal
  stages do not expose a clean shutdown flag. See
  `Docs/PDV_Phase21_ARR_SmokeRunbook.md`.

This is a beta integration package; public Authoria support is not yet claimed.
