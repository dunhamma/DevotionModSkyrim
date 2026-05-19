# PDV Bridge To SkyrimGamePlayReferences

**Status:** Living bridge note  
**Scope:** How PlayerDevotion should use the neutral `dunhamma/SkyrimGamePlayReferences` repo without copying its whole data layer into PDV.

## Purpose

`SkyrimGamePlayReferences` is the broad, mod-neutral discovery repo. PDV should use it for high-volume vanilla/DLC record lookup, hook discovery, and patcher planning.

This repo remains the PDV design authority. Curated deity scoring, race theology, stance logic, rewards, and implementation decisions still live in the PDV architecture, race sheets, phase matrices, and `references/vanilla-gameplay/pdv-crosswalk/`.

## Local Link

The bridge tool looks for the neutral repo in this order:

1. `SKYRIM_GAMEPLAY_REFERENCES_ROOT`
2. `scratch/SkyrimGamePlayReferences` under this repo
3. a sibling `SkyrimGamePlayReferences` folder next to this repo

Current local development clone:

```text
C:\Users\Admin\Documents\Devotion Mod Project\scratch\SkyrimGamePlayReferences
```

## Bridge Commands

```text
node .\tools\pdv_skyrim_refs_bridge.mjs status
node .\tools\pdv_skyrim_refs_bridge.mjs tables
node .\tools\pdv_skyrim_refs_bridge.mjs search reverse-keywords daedra --limit 10
node .\tools\pdv_skyrim_refs_bridge.mjs search faction-relationships thalmor --limit 10
node .\tools\pdv_skyrim_refs_bridge.mjs search condition-effects blessing --limit 10
```

The bridge is read-only. It does not copy generated data into PDV, mutate plugins, or make the neutral repo a runtime dependency.

## PDV High-Value Tables

| Bridge key | Source table | PDV use |
|---|---|---|
| `reverse-keywords` | `data/extracted/vanilla-reverse-keyword-index.csv` | Start from a CK keyword and find example records that use it. |
| `faction-relationships` | `data/extracted/vanilla-faction-relationships.csv` | Inspect civic, religious, crime, guild, Thalmor, Vigilant, vampire, and stronghold faction surfaces. |
| `condition-effects` | `data/extracted/vanilla-condition-bearing-effects-index.csv` | Find vanilla condition patterns for boons, neglect, privileges, and CK-readable gates. |
| `locations` | `data/extracted/vanilla-location-signal-candidates.csv` | Review sacred places, city/hold spaces, inns, ruins, strongholds, and dungeon context. |
| `cells` | `data/extracted/vanilla-cell-location-candidates.csv` | Discover named cells before focused xEdit/CK inspection. |
| `containers-furniture` | `data/extracted/vanilla-container-furniture-candidates.csv` | Find sleep, crafting, altar, vendor, and ritual interaction candidates. |
| `enchantments` | `data/extracted/vanilla-enchantment-palette.csv` | Compare reward effect patterns and magnitude ranges. |
| `magic-effects` | `data/extracted/vanilla-magic-effect-palette.csv` | Compare vanilla blessings, curses, boons, neglect effects, and active-effect behavior. |
| `leveled-lists` | `data/extracted/vanilla-leveled-list-signal-candidates.csv` | Seed offline patcher rules for distribution-sensitive records. |
| `formlists` | `data/extracted/vanilla-formlist-detail-candidates.csv` | Inspect vanilla curated record sets before designing PDV FormLists or manifests. |
| `shouts` | `data/extracted/vanilla-shout-records.csv` | Review voice-power records for Dragonborn or Thu'um-adjacent content. |
| `worldspaces` | `data/extracted/vanilla-worldspace-records.csv` | Check Skyrim, Solstheim, and mythic-space boundaries. |

## Feed-Back Rule

Use the neutral repo for discovery and broad reference. Feed back into PDV only after curation:

1. Search or inspect the neutral table.
2. Verify exact records in local xEdit/CK or through the Mutagen bridge.
3. Add the chosen signal to a PDV crosswalk, matrix, or patcher manifest.
4. Record the design meaning in PDV terms, not neutral repo terms.

Good PDV outputs:

- a deity hook row
- a race signal matrix row
- a curated patcher rule
- a compatibility dossier note
- a reward/neglect magnitude decision

Bad PDV outputs:

- vendoring the whole neutral repo
- treating scan-only rows as implementation truth
- scoring raw keyword presence without context
- using leveled-list or FormList order assumptions without local verification

## When To Refresh

Refresh or pull the neutral repo when PDV work needs broad vanilla/DLC discovery:

- new deity reaction surfaces
- race-specific signal expansion
- offline classification/distribution patcher rules
- compatibility planning for religion, survival, curse, or overhaul mods
- reward and neglect magnitude review

PDV should not require the neutral repo to compile, verify, or run in game. The bridge is a planning and authoring convenience only.
