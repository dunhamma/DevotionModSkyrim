# Skyrim Gameplay Mechanics Reference

**Started:** 2026-05-18  
**Status:** Living reference - first validated pass  
**Scope:** Gameplay mechanics, CK data surfaces, and player-experience lessons useful for PlayerDevotion design.

This repository is the gameplay counterpart to the PDV lore references. It is not meant to copy UESP or the CK Wiki. It records which vanilla systems matter to PDV, which source should be trusted for each system, and what design constraints follow from those mechanics.

## Validation Standard

Use the strongest available source for the question being answered:

| Source class | Use for | Notes |
|---|---|---|
| Local game/plugin data | FormID, EditorID, record ownership, current load-order truth | Preferred when we need exact records from `Skyrim.esm`, DLC masters, or PDV plugins. |
| CK Wiki / UESP CK Wiki | CK record behavior, Story Manager events, condition functions, Papyrus object contracts | Preferred for authoring behavior and implementation constraints. |
| UESP gameplay pages | Player-facing vanilla mechanics, formulas, quest/faction summaries, shrine and disease tables | Preferred for gameplay baseline and public reference. |
| Established mod pages and community discussions | Player-experience patterns, immersion preferences, compatibility expectations | Use as qualitative evidence, not statistical proof. |

## Folder Map

| Folder | Purpose |
|---|---|
| `schema/` | CSV conventions, CK record type notes, and extraction assumptions. |
| `extracted/` | Generated vanilla/DLC record tables from local Anvil master data. |
| `core/` | Actor values, condition functions, keywords, record signatures, and FormID conventions. |
| `story/` | Quest categories, Story Manager events, and radiant quest cautions. |
| `social-crime/` | Factions, crime scopes, bounty mechanics, and civic-order signals. |
| `races-actors/` | Playable race mechanics, PDV origin indices, vampire/temporary race handling, and actor-type tags. |
| `religion-magic/` | Shrine blessings, diseases, magic effect archetypes, and vanilla religion records. |
| `world/` | Worldspaces, locations, location-type keywords, dungeon categories, and encounter-zone notes. |
| `rewards/` | Reward/neglect/effect magnitude palette and stacking cautions. |
| `compatibility/` | Compatibility dossiers for major religion, survival, curse, and gameplay overhauls. |
| `pdv-crosswalk/` | PDV signal hook index, UX lessons, deity/shrine crosswalks, and implementation risk notes. |

## First-Pass Findings

1. **PDV should stay event-led, not poll-led.** CK Story Manager and player-alias events provide the right signal shape; deity scripts should score curated events instead of raw skill XP, raw crafting counts, or constant timers.
2. **Globals are a CK bridge, not truth.** PDV's StorageUtil source of truth plus mirror globals matches the CK condition model: conditions can read globals, actor values, factions, races, keywords, quest stages, and location state without script polling.
3. **Vanilla blessings are short and exclusive.** Shrine blessings are short-term and normally only one shrine blessing can be active at a time; PDV should avoid accidentally replacing that layer unless intentionally designing shrine integration.
4. **Crime has witness and hold-scope nuance.** Reported bounty, hidden sin, commanded follower crime, murder, assault, theft, trespass, and jail outcomes should not be flattened into one "bad act" signal.
5. **Radiant quests are useful but weak evidence.** Radiant targets can be randomized or selected earlier than the player sees them, so PDV should treat them as context unless the content is curated by quest stage or faction progression.
6. **Immersion fails when it becomes menu tax.** Player research consistently favors quiet systems that create roleplay opportunities over recurring chores, repeated popups, or invisible punishment.
7. **Vanilla-plus feel is a design constraint.** The best PDV lane is a hidden religious layer that reacts to Skyrim play, not a visible reputation sim that constantly explains itself.

## Highest-Value Tables To Expand Next

| Priority | Table | Why |
|---|---|---|
| 1 | `core/condition-functions.csv` | Drives CK condition authoring for boons, privileges, dialogue, shrine access, and status surfaces. |
| 1 | `story/story-manager-events.csv` | Defines the signal capture roadmap beyond `Kill Actor`. |
| 1 | `religion-magic/blessings.csv` | Establishes vanilla shrine baseline before PDV overwrites or layers on religion mechanics. |
| 1 | `religion-magic/magic-effect-archetypes.csv` | Keeps boons/neglect effects compatible with vanilla stacking and UI behavior. |
| 2 | `social-crime/factions.csv` | Needed for civic order, Thalmor pressure, guild paths, Vigilants, Companions, Blood-Kin, and hold-level community signals. |
| 2 | `world/loctype-keywords.csv` | Needed for sacred places, wilderness/temple/dungeon distinctions, sleep/location signals, and race-substrate layers. |
| 3 | `pdv-crosswalk/quest-moral-signal-crosswalk.csv` | Handpicked quest/faction/Daedric moral signals for future quest-stage implementation. |

## Generated Extraction Pack

Run this from the project root to refresh the local vanilla/DLC extraction pack:

```text
node .\tools\pdv_extract_vanilla_gameplay_refs.mjs
```

The generated tables live under `extracted/`. They are implementation reference
data, not final design decisions. Use the `pdv-crosswalk/` tables to curate
which extracted records become real PDV signals or patcher rules.

## Design North Star

PDV should make the player feel that Skyrim's gods noticed what they were already doing. It should not ask the player to maintain a second job. Use rare, meaningful surfaces: first-load origin, shrine or commitment moments, tier changes, major neglect, and debug-only diagnostics.

## Source Registry

See `sources.yaml` for the source list used by this first pass.
