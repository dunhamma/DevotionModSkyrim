# Devotion — Authoria / ARR Compatibility + Extensibility

This add-on makes **Devotion (PDV)** aware of the *Authoria - Requiem Reforged*
list's extra theological content. It is an **add-on**: install the core
**Devotion** mod first (the PDV_FirstLook build), then this package on top.

## What's in this package

| File | What it does |
|------|--------------|
| `PDV_AuthoriaARR_Compatibility.esp` | ESL-flagged. 11 Daedric **shrine-prayer Activators** (one-off +2 piety prayer, once/day) for the `man_DaedricShrines` statues. Masters: `Skyrim.esm`, `Devotion.esp`. |
| `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini` | Base Object Swapper rule that makes the decorative Daedric statues *clickable* by swapping their STAT meshes to the prayer Activators. Requires **po3 Base Object Swapper**. |
| `SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR.json` | The **extensibility channel**: 22 quest-reaction cells across 20 watched quests from Vigilant, Glenmoril, Unslaad, Olenveld, The Forgotten City, Saints & Seducers, DAc0da, and the Ebony Blade curse. Loaded automatically alongside the core matrix; silently no-ops for any content you don't have. |

## Requirements / load order

1. **Devotion.esp** (core PDV) — active **before** `Requiem for the Indifferent.esp`.
2. **po3 Base Object Swapper** (for the clickable shrine prayers).
3. This plugin (`PDV_AuthoriaARR_Compatibility.esp`) after Devotion.esp.
4. The Archon religion overhaul family stays **disabled** in the ARR profile
   (PDV owns the shrine SPELs; they revert to Requiem FormIDs on Archon removal).

## Notes for testers

- The **patch** half (Archon removal + PDV owning the cure-only shrine spells) is
  handled by the disabled-Archon profile, not by a record override in this ESP.
- The **extensibility** half is the ARR quest-matrix channel + the shrine prayers.
- Daedric **shrine prayers** give a flat +2 to that Prince once per in-game day and
  now show a confirmation line ("You offer a prayer at the shrine of ...").
  Uncommitted Princes accumulate piety in the background and won't appear in the
  Devotion panel until you commit to them.
- Five quest-reaction cells are flagged RUNTIME-VERIFY (no clean shutdown stage to
  bind to) — see `Docs/PDV_Phase21_ARR_SmokeRunbook.md`.

This is a beta integration package; public Authoria support is not yet claimed.
