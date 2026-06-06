# PDV Devotional Item / Token — Asset Plan

**Status:** Asset decision aid for the per-race devotional *items* (tokens). Companion to
`references/authoring/PDV_PortableDevotionalToken_BuildSpec.md` (the build pattern — vanilla-art reuse) and
`references/authoring/PDV_ShrineAsset_CoverageAndSourcing.md` (the shrine side).
**Date:** 2026-06-05

## Principle
The token build spec already requires **vanilla-art reuse — no custom mesh/texture.** So the default for
every item below is **zero-cost vanilla**. Free modder-resource packs are an **optional V2 visual upgrade**
(consistent with "custom art = V2"). Pick a thematically-right *existing* MISC/BOOK and rename/describe it.

## Does each substrate/token race need an item?

| Race | Substrate | Needs an item? | Why |
|---|---|---|---|
| **Khajiit** | lunar (moon phase) + road/home cadence | **No (1.0)** | The "shrine" is the **sky** — Masser/Secunda are visible anywhere, outdoors, every clear night. No accessibility gap to substitute for. Road/rest cadence already gives an active rhythm. An item would be redundant + risks chore-feel. *Optional V2:* a light lunar charm / home moondial only if indoor/daytime Khajiit feel idle in playtest. |
| **Argonian** | Hist (water proximity) | **Yes** — Hist-sap token (spec'd) | No Hist tree in Skyrim; needs a portable rite + the active layer over passive water-proximity. |
| **Dunmer** | ancestor | **Yes** — ash-shrine token (spec'd, proven) | No ancestral tomb in Skyrim; portable shrine substitute. (Azura/Boethiah have vanilla shrines.) |
| **Redguard** | sect / Far Shores | **Yes** — Far Shores token (spec'd) | No Far Shores access; vanilla **Arkay** shrine is the fallback for the Tu'whacca death-duty side. |
| **Bosmer** (proposed) | branch / Green Pact | **Optional 1.0** — closes the main residual shrine gap cheaply | No Y'ffre shrine; parallels the three proven tokens. |

**Khajiit walkthrough (the one that needed reasoning):** the exile tokens exist because those gods'
shrines are *inaccessible* in Skyrim. Khajiit devotion routes through the **moons**, which are never
inaccessible — so there is nothing for a token to substitute for. Conclusion: **no Khajiit item for 1.0.**

## Per-item asset picks (vanilla default → free upgrade)

| Item | Vanilla reuse (1.0, zero cost) | Free upgrade (optional, V2) |
|---|---|---|
| **Dunmer ash-shrine token** | a vanilla **burial urn** / ash-pile / "Bone Meal", or a **book/journal** mesh (the spec's BOOK ritual-focus). Dunmer-themed clutter reads best. | **ElSopa HD – Dark Elf Urns** (Dunmer urn retexture); **Oaristys Modder's Resource Pack** (urns/censers); Beyond Skyrim: Morrowind clutter *(permission-gated)*. |
| **Argonian Hist-sap token** | a vanilla **potion/vial** mesh named "Hist Sap" (green ingredient bottle), or the **Taproot** ingredient as an amber-sap focus. | clutter packs for a distinct amber vial; Black Marsh / Hist themed resources *(permission-gated)*. |
| **Redguard Far Shores token** | a **map/star-chart note** (Walkabout/star-path) or a reused **amulet/coin** (Yokudan). Shrine side already uses vanilla **Arkay** as fallback. | Hammerfell / Redguard resources (Beyond Skyrim *(permission-gated)*); amulet resource packs. |
| **Bosmer token** (if added) | a **bone/antler charm** (Green Pact = no plant matter → bone/leather/antler), reusing a vanilla bone or amulet MISC. | bone/antler/leather clutter from the resource packs below. |
| **Khajiit charm** (only if V2-optional) | a **Moonstone** (Moonstone Ore ingredient) or reused **amulet** as a "moon charm". | clutter packs. |

## Free asset sources (with license posture)

For when you want a more distinct look than vanilla (V2). **Always confirm the per-mod permission tab.**

- **Modder's Resource Pack — Oaristys & Tamira** — the big permissive clutter pack (~386 meshes; SSE version
  exists). **Explicitly free to use, modify, and convert to SSE without asking** — the safest default.
  ([nexus](https://www.nexusmods.com/skyrim/mods/16525))
- **InsanitySorrow's Resources** (clutter) — long-standing free modder resource, widely credited.
- **Blary's resources** (containers/clutter) & **Tamira's resources** (dishes/food/static) — free, credited.
- **ElSopa HD – Dark Elf Urns** — Dunmer urn retexture, ideal for the ash-shrine token.
- **Super List of Skyrim Modder's Resources** (Winking Skeever) — the master index to browse by type.
  ([list](https://winkingskeever.com/list-of-skyrim-modders-resources/))
- **Beyond Skyrim** (Morrowind / Hammerfell / Black Marsh) — lore-perfect cultural items, but **permission-
  gated** (coordinate, don't bundle).

**License rule of thumb:** Oaristys/InsanitySorrow/Blary/Tamira packs = free-to-use with credit; ElSopa =
check tab (usually permissive with credit); Beyond Skyrim / large team mods = ask first. Default to the
Oaristys pack + vanilla, which need no permission.

## Recommendation
- **1.0:** vanilla-reuse for the three existing tokens; **add the Bosmer token** (vanilla bone/antler) to
  close the residual gap; **no Khajiit item.**
- **V2 (optional polish):** swap any token mesh to a free-resource upgrade (Oaristys/ElSopa) and reconsider a
  Khajiit lunar charm only if playtest shows an indoor/daytime devotion gap.

## Decisions for you
1. **Bosmer token in for 1.0?** (Vanilla bone/antler charm — zero cost, closes the main gap.)
2. **Khajiit — confirm no item for 1.0?** (Recommended; revisit only on playtest evidence.)
3. **Token meshes — ship 1.0 on pure vanilla, and treat free-resource upgrades (Oaristys/ElSopa) as V2?**
