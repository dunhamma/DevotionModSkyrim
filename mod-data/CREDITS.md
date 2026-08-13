# Third-party assets shipped in `mod-data/`

## Calians - Altmer Accessories -- by pixelartpeach

- Nexus: https://www.nexusmods.com/skyrimspecialedition/mods/118654
- Category: Modders Resources. Version 1.0 (2024-05-05).
- Files used here: one mesh (the `white/eggshell` variant, shipped as
  `meshes/PDV/Clutter/PDV_AltmerCalian.nif`) and the four textures it references
  (`MS03 Calians/textures/...`).

**Permission, quoted from the mod page:**

> "I give full permission to use my mod in your own. Distributors to put them in each of the
> Thalmor's pockets, mods that rename or retexture them, adding them to followers or locations, HD
> models, whatever you want. The only thing I require is for you to credit me with a direct link in
> your mod description."

**THE CONDITION IS NOT OPTIONAL, AND THIS FILE DOES NOT DISCHARGE IT.** The author requires a credit
with a direct link **in the mod description** -- that means the Nexus page for Devotion, not just
this repo. Add it to the release description before any public build that contains these files.

Known issue in the upstream resource, verified 2026-08-06: its meshes reference
`MS03 Calians\textures\...` while the archive installs textures to `textures\...`, so the meshes
render untextured as shipped. Devotion works around this by shipping the textures at the paths its
mesh expects. See `references/authoring/PDV_Altmer_PracticeToken_LoreDive_2026-08-06.md`. Worth
reporting upstream.
