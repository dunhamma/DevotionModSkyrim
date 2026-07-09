# PDV Phase 20 Quest-Stage Exclusion Audit

**Created:** 2026-06-03
**Status:** Exclusion taxonomy and future-review queue
**Companion inventory:** `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv`

## Purpose

The quest-stage inventory read back 763 vanilla/DLC candidate quests. Most rows
should not become live devotion sources. This audit gives future passes stable
reason codes so exclusions remain reviewable instead of disappearing into a
generic "not used" bucket.

## Reason Codes

| Code | Meaning |
|---|---|
| `EXCL_SCAN_ONLY_NO_READBACK` | Candidate table row only; no exact quest/stage/outcome readback. This should now apply only to future rows outside the current inventory. |
| `EXCL_TECHNICAL_CONTROLLER` | Init, alias-fill, cache, scheduler, objective, monitor, handler, tracking, tutorial, debug, or controller quest. |
| `EXCL_DIALOGUE_SCENE_AMBIENT` | Dialogue, scene, bark, hello, commentary, rumor, or ambient NPC quest without a specific player-owned INFO or fragment outcome. |
| `EXCL_RADIANT_REPEATABLE` | Radiant job, world encounter, random target/location, repeatable service, or side-job pattern that cannot support one-shot theological scoring. |
| `EXCL_CONTAINER_TOO_BROAD` | A quest whose watched stage is a container/umbrella that fires on UNRELATED stages the deity has no read on. NOTE (2026-07-09): this is NOT a licence to skip a questline's progression beats. A main-quest/questline progression stage with an exact, relevant deity read (e.g. Alduin's Wall -> Julianos disciplined_study) DOES count; exclude only when the specific watched stage genuinely fires for unrelated content. "It's a middle beat" is not an exclusion reason. |
| `EXCL_OUTCOME_AMBIGUOUS` | Quest is useful, but the receiver cannot distinguish the moral branch or mutually exclusive outcome. |
| `EXCL_NON_PLAYER_AGENCY` | World, NPC, or system state, not a legible player act. |
| `EXCL_WRONG_ROUTE_OR_RACE` | Semantically valid elsewhere, but not for this race/route family. |
| `EXCL_DUPLICATE_SOURCE_OWNER` | Should be owned by book-read, spell-effect, item-acquisition, faction-rank, location, kill, shrine/rite, or curse-state receiver instead of quest-stage. |
| `EXCL_ANTI_FARM_UNPROVABLE` | Would fire repeatedly or from generic progression without a reliable cooldown/duplicate guard. |
| `EXCL_CUSTOM_RECEIVER_REQUIRED` | Needs narrower fragment/script/faction/item/location-plus-stage logic before it can be approved. |
| `EXCL_LORE_WEAK` | Title or EditorID theme is suggestive, but UESP / Imperial Library / PDV design authority does not support the semantic verdict strongly enough. |

## Citation Policy

Quest-stage verdicts must separate record proof from meaning proof.

Local Mutagen/xEdit/CK readback is the authority for exact quest records, form
keys, stages, aliases, fragments, and branch mechanics. UESP quest pages are
the preferred citation for vanilla/DLC quest flow, stage names, choices, and
mutually exclusive outcomes. Imperial Library or in-game lore-book citations
justify theological or racial meaning; they do not prove implementation
behavior.

A `strong` verdict needs exact local readback, a stage/outcome-specific UESP
citation, a compatible receiver shape, and a PDV race/design citation when the
semantic mapping is non-obvious. A `plausible` verdict may have good UESP or
lore support but remains `needs-stage-readback`, `receiver-needed`, or
`manual-only`. Scan-only rows, EditorID inference, generic quest progress,
ambient dialogue, and broad questline membership cannot become approved
source-fill evidence.

## Exclusion Patterns By Master

| Source | Pattern | Default reason code | Notes |
|---|---|---|---|
| Skyrim / Update | Update duplicate rows for `Skyrim.esm:*` records | `EXCL_DUPLICATE_SOURCE_OWNER` | Treat as duplicate evidence until readback proves Update changes the relevant terminal stage or fragment. |
| Skyrim / Update | Root questline and faction scaffolds | `EXCL_CONTAINER_TOO_BROAD` | Examples include broad `MQ`, `C00`, `DarkBrotherhood`, `TG00`, dialogue systems, and questline containers. |
| Skyrim / Update | Scene/helper/monitor quests | `EXCL_TECHNICAL_CONTROLLER` | Examples include intro, post-quest, scene, monitor, location-check, and rampage helpers. |
| Skyrim / Update | Radiant/repeatable/favor loops | `EXCL_RADIANT_REPEATABLE` | Not acceptable without one-shot marker and rejected-loop proof. |
| Skyrim / Update | Whole Daedric quest rows without branch-safe outcome | `EXCL_OUTCOME_AMBIGUOUS` | Strong semantic candidates must still split mutually exclusive stages before source-fill. |
| Dawnguard | WESC / WE / world encounters | `EXCL_RADIANT_REPEATABLE` | Random encounter scaffolding and ambient combat are not durable moral-stage evidence. |
| Dawnguard | Dialogue, scene, hello, or block quests | `EXCL_DIALOGUE_SCENE_AMBIENT` | Presentation plumbing unless a specific player-owned INFO/fragment outcome is proven. |
| Dawnguard | `DLC1RH*`, `DLC1RV*`, `DLC1Radiant*` | `EXCL_RADIANT_REPEATABLE` | Repeatable/radiant targets are farmable and context-variable. |
| Dawnguard | Trackers/controllers/handlers | `EXCL_TECHNICAL_CONTROLLER` | Use as supporting readback only, not semantic quest-stage sources. |
| Dawnguard | Vampire mechanics rows | `EXCL_DUPLICATE_SOURCE_OWNER` | Curse-state or explicit outcome routes should own these, not broad quest-stage scoring. |
| HearthFires | Attacks and infestations | `EXCL_RADIANT_REPEATABLE` | Random household incidents are not stable devotion sources. |
| HearthFires | Adoption schedulers/couriers/adoptable trackers | `EXCL_TECHNICAL_CONTROLLER` | Only a final adoption outcome is candidate-worthy. |
| HearthFires | Steward/housecarl dialogue | `EXCL_DIALOGUE_SCENE_AMBIENT` | Household support presentation, not the player build/adoption act. |
| HearthFires | Construction rows | `EXCL_CUSTOM_RECEIVER_REQUIRED` | Use only after exact player-legible milestone selection; do not score raw crafting. |
| Dragonborn | Dialogue/scene/support rows | `EXCL_DIALOGUE_SCENE_AMBIENT` | Skaal, Raven Rock, Tel Mithryn scenes are ambient or NPC-scene scaffolds. |
| Dragonborn | World encounters, services, merchants, hirelings | `EXCL_RADIANT_REPEATABLE` | Too loop-prone for theology scoring. |
| Dragonborn | Cultist, ash spawn, dungeon controller, creature dialogue, spawner rows | `EXCL_TECHNICAL_CONTROLLER` | Collapse into generic combat or hidden quest state. |
| Dragonborn | Black Book rewards/controllers | `EXCL_DUPLICATE_SOURCE_OWNER` | Pick one owner between BookRead and quest-stage. |
| Dragonborn | Raven Rock favor breadth | `EXCL_LORE_WEAK` | `DLC2RR01/RR02/RR03` are reviewable; most other local color is too generic. |
| Dragonborn | Skaal / All-Maker rows | `EXCL_WRONG_ROUTE_OR_RACE` | Strong theology, but not current Dunmer Reclamation fill unless explicitly rerouted. |
| Dragonborn | Pillar/stone controller rows | `EXCL_CONTAINER_TOO_BROAD` | Useful only with exact stone/outcome; whole controllers would fire from generic state churn. |

## Future Review Targets

- Recheck `Update.esm` duplicates only when the winning record differs from the
  Skyrim source row.
- Split Daedric quests by final branch/outcome before any receiver fill.
- Decide whether Dragonborn Black Book events are owned by BookRead,
  quest-stage, or a dedicated Mora/deviation receiver.
- Decide whether HearthFires adoption/homestead should be quest-stage,
  location/property-state, or manual-only Altmer Tier 3 evidence.
- Decide whether Raven Rock and Skaal rows belong in a future Solstheim
  community route rather than current Dunmer Reclamation/deviation routes.


## 2026-07-04 Phase-3 tagging sweep (matrix expansion)

Adjudicated during the 40-50-quests-per-deity expansion (5-agent tagging pass + main-loop
spot-check + UESP verification agents). Quests below are EXCLUDED from the quest-reaction
matrix; tagged survivors live in PDV_QuestOutcomeInventory.csv.

- EXCL_TECHNICAL_CONTROLLER: DarkBrotherhoodadditionalNPCDialogue, DarkBrotherhoodSanctuaryConversation1,
  DarkBrotherhoodSanctuaryConvSystem, DarkBrotherhoodSanctuaryDialogue, MQ102A, MQ102B, MQ201Party,
  MQ302FillAliases, DA11Intro, DA11IntroScene, MG01Pointer (UESP-confirmed pure progression pointer),
  TG00MaulHandler, TG00MiscHandler, TG04EECHandler, TG04Post, TG09Post, TG00SP
- EXCL_DIALOGUE_SCENE_AMBIENT: CW00A, CW00B, TG02SP
- EXCL_RADIANT_REPEATABLE: TG02B (radiant job hub), FreeformSkyHavenTempleB "Dragon Hunting"
  (UESP-verified radiant/repeatable -- initially mis-tagged, corrected in spot-check)
- EXCL_CONTAINER_TOO_BROAD: CW01AOutfitImperial
- EXCL_OUTCOME_AMBIGUOUS: MQ102 (courier leg), MQ105Ustengrav (horn already stolen; empty-tomb tracker),
  MQ203 (expository escort), MQ204 (traversal/dialogue), MQ205 (dispatch), x, FreeformSkyHavenTempleC (single-stage blessing grant), DB04 "Whispers in the Dark" (Listener
  reveal has no morally-legible player act; eavesdrop row rejected in spot-check)
- CUT CONTENT (unreachable in vanilla; UESP-verified): FreeformWinterholdCollegeA "Research Thief"
  (quest item never placed; also note the real cut plot is the PLAYER stealing for Nirya),
  FreeformWinterholdCollegeB "The Missing Apprentices" (no completion trigger; s200 is bookkeeping only)
