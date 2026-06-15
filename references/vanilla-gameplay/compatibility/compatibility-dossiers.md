# PDV Compatibility Dossiers

Status: living reference - Phase 21 compatibility rebaseline

These are internal planning dossiers. They do not claim public support,
maintainer approval, or end-user Wabbajack swap safety. Phase 21 targets
list-author packages first, with Authoria / ARR as P0.

Compatibility package work is now Phase 21. It waits on the Phase 20 full
roster/content lock so every list package is tested against the complete mod
surface. The `phase20-targets.csv` and `PDV_Phase20_CompatibilityNotes.md`
filenames are retained for continuity with existing handoff references.

The tracked target matrix is `phase20-targets.csv`. The operating rules for
status, package shape, smoke, and public claims live in
`PDV_Phase20_CompatibilityNotes.md`.

## Default Compatibility Posture

- Use replacement-first handling for active religion overhauls.
- Remove the target list's religion overhaul plus direct dependent religion
  patches; keep non-religion survival, curse, visual, temple, city, quest, and
  world content unless a concrete conflict appears.
- Prefer one list-specific ESL-first patch per list package.
- Do not edit list-owned plugins directly.
- Keep patch masters minimal and avoid new hard dependencies.
- Read external mod state only through explicit adapters.
- Never let an external mod become PDV's piety source of truth.
- Public list support waits for `public-supported` status.

## List-Author Targets

### Authoria / ARR

Phase 21 priority: P0.

Posture: first full package lane. The local `D:\Wabbajack\modlists\ARR`
install and selected `ARSE` profile are initial evidence only; patch
development must refresh against the Authoria authors' current list.

Known overlap families from the local pass:

- Requiem stack and RFTI output.
- Archon religion layer to replace.
- Frostfall, SunHelm, Campfire, and Survival Mode context.
- Vampire/werewolf support and feeding-related plugins.
- Daedric shrine surfaces, Vigilant/Glenmoril/Unslaad/LOTD-style quest and
  newland content, and major shrine/statue/worldspace additions.

Likely PDV route:

- Ship one Authoria-specific compat patch with minimal masters.
- Include a reference-only RFTI output for the exact snapshot if useful, but
  require the author to regenerate final RFTI.
- Keep Authoria priority as proof order only; do not fork PDV theology or
  create Authoria-special mechanics.

### Diaries of Dibella

Phase 21 priority: P1.

Posture: local package-evidence lane, not release evidence. The installed DoD
profile has a readback-backed package for the Wintersun replacement slice, but
it still needs runtime smoke and a refresh from current public or
author-provided evidence before public support.

Current shareable artifact:

- `dist/PDV_DoD_BordelloPatch_v0_20260615.zip`.
- Install guide: `references/authoring/PDV_Phase21_DoD_PackageInstall.md`.
- Authoria reuse audit:
  `references/authoring/PDV_Phase21_DoD_AuthoriaReuseAudit.md`.
- The package includes Devotion runtime files and docs only. It deliberately
  excludes Synthesis, ParallaxGen, TexGen, and DynDOLOD output because those
  must be rebuilt against the edited end-user profile.

Known overlap families from the local pass:

- Wintersun religion layer and dependent Wintersun patches.
- Stale generated-output masters after Wintersun removal:
  `DynDOLOD.esp`, `Lord's Vision - Synthesis Gameplay.esp`, and `PG_1.esp`.
- Shared Authoria/DoD quest and custom-race surfaces: Heart of Dibella QE,
  Caught Red Handed QE, Talos' Tease, The Only Cure QE, Whispering Door QE,
  Half-Khajiit / Ohmes-Raht, and M'rissi.
- DoD-specific candidate surfaces: Dibellan Baths Sybil blessing
  `akdAltarSybilSpell`, Ohmes-Raht custom-race origin mapping, Mara's Embrace,
  and Talos' Tease social-location context.
- Growl, Sacrilege, Moonlight Tales Mini, and vampire feeding support.
- Frostfall, Last Seed, Campfire, and bathing/cleanliness systems.
- Dibella, Mara, Talos, temple, shrine, and social-location content.

Likely PDV route:

- Replace Wintersun and direct religion patches.
- Keep survival, curse, bathing, social, temple, and visual content unless a
  concrete conflict appears.
- Use curated authored hooks for Dibella/Mara/Talos content only where
  high-signal and stable.
- Current local package disables 20 Wintersun-family plugins, enables the
  junctioned local Devotion test mod, and emits no standalone DoD ESP because
  `Devotion.esp` wins the proven shrine spell surface after removal.
- Rebuild Synthesis, ParallaxGen, TexGen if the list workflow requires it, and
  DynDOLOD after Wintersun removal; do not distribute or hand-clean old
  generated outputs that still master Wintersun or `DBM_Wintersun_Patch.esp`.
- Do not copy Authoria's `Authoria - Reqtificated - *` patches into DoD. The
  readback evidence shows those are Requiem/list-balancing overrides, not PDV
  event adapters.
- Keep the Sybil blessing, Ohmes-Raht custom race, Heart of Dibella QE, Caught
  Red Handed QE, and Talos' Tease as candidate adapters until exact design and
  runtime gates are approved.

### JOJ, TOT, HOH, MOM, VOV

Phase 21 priority: P1.

Posture: public Bordello load-order pages are acceptable pre-handoff evidence
for initial package work. If author-provided files differ, perform one normal
revision pass before author smoke.

Likely PDV route:

- Build exact removal sets from the current public plugin/modlist evidence.
- Ship one list-specific ESL-first patch per package.
- Treat list theme as compatibility context, not a reason to change PDV
  theology.

## System-Family Dossiers

### Religion Overhauls

Examples: Wintersun, Pilgrim, Archon, Gods and Worship.

PDV posture: replacement-first research targets.

Why they matter:

- They identify common shrine, blessing, deity, favor, tenet, and notification
  surfaces.
- They often carry many direct dependent patches inside curated modlists.

Likely PDV route:

- Remove the active religion overhaul and direct dependent patches for a
  supported-list package.
- Use their compatibility notes to discover likely conflicts, not to inherit
  their whole patch universe.
- Do not promise triple-stack coexistence for 1.0.

### Requiem - The Roleplaying Overhaul

PDV posture: vanilla-plus core, list-specific Requiem patch.

Why it matters:

- Requiem changes combat, races, perks, economy, enemy danger, and reward
  magnitude expectations.
- Authoria is Requiem-based, so Requiem support is part of the P0 proof lane.

Likely PDV route:

- Keep core PDV vanilla-plus.
- Tune values and classification through the Authoria/Requiem list patch.
- Require author-side RFTI regeneration. Reference RFTI output is snapshot
  proof, not a portable final artifact.

### Curse Mods

Examples: Sacrosanct, Sacrilege, Growl, Moonlight Tales, Vampire Feeding
Tweaks, vampire/werewolf visual or behavior addons.

PDV posture: curated theology transitions.

Why they matter:

- Vampirism and lycanthropy are major theological states for PDV.
- List curse stacks may diverge from vanilla feeding, cure, or beast-form
  behavior.

Likely PDV route:

- Detect state reliably and avoid double-fire.
- Support onset, cure, voluntary embrace/renunciation, major feeding or
  restraint choices, beast-form rites, and Hircine/Molag Bal/Azura-relevant
  moments when safe.
- Do not mirror rank, perk, hunger, blood potency, or progression systems.

### Survival And Needs

Examples: Survival Mode, Frostfall, SunHelm, Last Seed, Campfire, iNeed-style
systems, bathing/cleanliness systems when they affect roleplay cadence.

PDV posture: context only.

Why they matter:

- Weather, rest, travel, hunger, exposure, camping, bathing, and hardship can
  overlap with Kyne/Kynareth/Khenarthi, exile, pilgrimage, and wilderness
  favors.

Likely PDV route:

- Use survival state to shape eligibility, caps, or duplicate-punishment
  avoidance.
- Do not award or remove raw piety from hunger, cold, thirst, exposure, or
  cleanliness meters.
- Keep survival mods installed unless a specific record conflict exists.

### Quest And Newland Mods

Examples: Vigilant, Glenmoril, Unslaad, LOTD, Wyrmstooth, major Daedric or
temple quest expansions.

PDV posture: high-signal curated hooks only.

Why they matter:

- Some quest choices are directly religious or Daedric.
- Broad quest-stage mapping would turn compatibility into a content phase.

Likely PDV route:

- Add hooks only when stages are stable, theology is clear, and the target is
  relevant to a supported list.
- Do not infer theology from plugin presence alone.
- Defer low-impact quest hooks as non-blocking known issues.

### Adult, Romance, And Social Frameworks

PDV posture: curated authored hooks only.

Why they matter:

- Dibella, Mara, Sanguine, Molag Bal, taboo, and social-role content can overlap
  with adult, romance, and social systems in curated lists.

Likely PDV route:

- Do not read generic framework events.
- Recognize only specific authored quests, relationships, places, or outcomes
  with clear religious meaning.
- Keep PDV from becoming a generic interaction counter.

## Shrine And Prayer Rule

PDV may replace religion-mod shrine reward behavior after the old religion
overhaul is removed. The implementation path is targeted adapters, not global
vanilla shrine activator replacement.

Release-list coverage target:

- Vanilla Divine and Talos worship surfaces.
- Major Daedric worship surfaces.
- Visible list-added replacements for the core religion set.
- Context-only recognition for unsupported deities or outlier shrine objects.

Survival, visual, temple, statue, and worldspace records should be classified
or referenced without taking ownership of those systems.
