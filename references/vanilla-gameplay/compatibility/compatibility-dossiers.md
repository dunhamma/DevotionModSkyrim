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

Posture: modular experimental deployment. The current machine target is
`D:\Wabbajack\modlists\ARR 2.5`, profile
`KoK R11 - PDV ARR25 Experiment 20260807`. The July ARR Test review remains
historical source evidence, while current package/deployment state is owned by
`references/authoring/PDV_ModPackaging_StateAuthority.md` and the structured
deployment receipt.

Known overlap families from the 2026-07-16 pass:

- Requiem stack and RFTI output (all 14 shrine-blessing SPELs resolve to
  Requiem.esp; Devotion's neutralization manifest applies unchanged).
- NO active religion overhaul to replace: Archon is gone from the list;
  Apostasy Framework is a modder's resource (custom AVs/keywords), coexists.
- Frostfall, SunHelm, Campfire, and Survival Mode context.
- Vampire/werewolf support (Sacrilege, Manbeast, Requiem VampireCollection)
  and feeding-related plugins.
- Daedric shrine surfaces, quest expansions overriding hooked vanilla DA
  quests, new-land quest content, bard/performance activity mods, and major
  shrine/statue/worldspace additions.

Current PDV route:

- Ship ordinary Devotion core plus the dependency-gated modular PatchHub; do
  not restore an Authoria combined lane or list-wide core-script override.
- Keep source-specific hooks narrow and minimally mastered; all five installed
  patch plugins are independent ESPFEs.
- V3 AFDI is the first migrated semantic adapter: the observer resolves all 30
  source globals dynamically, submits catalog-owned event IDs, and its ESPFE
  retains only `Devotion.esp` as a master. Static compile/VMAD/master proof is
  green; Authoria runtime and sentinel/load-order confirmation remain open.
- Keep Authoria priority as proof order only; do not fork PDV theology or
  create Authoria-special mechanics.

### Diaries of Dibella

Phase 21 priority: P1.

Posture: integration applied locally (2026-06-30) and machine-valid (load order
clean); runtime in-game smoke and a current-evidence refresh are still required
before release packaging. See "Integration applied" below.

Known overlap families from the local pass:

- Wintersun religion layer and dependent Wintersun patches.
- Growl, Sacrilege, Moonlight Tales Mini, and vampire feeding support.
- Frostfall, Last Seed, Campfire, and bathing/cleanliness systems.
- Dibella, Mara, Talos, temple, shrine, and social-location content.

Likely PDV route:

- Replace Wintersun and direct religion patches.
- Keep survival, curse, bathing, social, temple, and visual content unless a
  concrete conflict appears.
- Use curated authored hooks for Dibella/Mara/Talos content only where
  high-signal and stable.

Integration applied (2026-06-30) -- machine-valid, runtime smoke pending:

- Devotion (PreBeta .8) installed into the live DoD profile; all six SKSE deps
  (PapyrusUtil, PO3, SkyUI, Address Library, KID, PrismaUI) confirmed present.
- Wintersun removed: disabled `Wintersun - Faiths of Skyrim` + its 4 pure add-ons
  (Hearthfires Wintersun Shrines, Tweaks and Enhancements, GotT Lite, Gallows Hall)
  + 15 "X - Wintersun patch" compat patches (Sacrilege, DBM, LOTD_TCC, COTN Dawnstar,
  JK's DB Sanctuary, TOCQE, TWDQE, FloatingSword TCIY, SDA, Mrissi, AX ValSerano,
  Mannaz-Freyr, Lux, Lux Orbis, Northern Roads) -- 20 plugins total.
- `DOD - Ohmes-Raht Fix.esp` forward-patched: its only Wintersun footprint was 1 DIAL
  + 1 INFO override (dead dialogue); removed those 2 records + stripped the Wintersun
  master (last master, no FormID renumber). Re-parse verified valid; original backed up.
  Ohmes-Raht piety is handled by Devotion's `PDV_RaceMap.json` (HalfKhajiit -> Khajiit).
- `JOJ - Player Devotion Patch.esp` (Lux/MusicMerged CELL cleanup) added.
- Load order: **0 new missing masters**. The 3 flagged are PRE-EXISTING and unrelated
  (HalfKhajiit -> RaceCompatibility.esm; ORomance -> OSA.esm/OStim.esp).
- Owner follow-up: re-run **Synthesis + ParallaxGen** -- their outputs
  (`Lord's Vision - Synthesis Gameplay.esp`, `PG_1.esp`) are disabled pending regen.
- Backups under `profiles/Diaries of Dibella - Lord's Vision/pdv-dod-backup-20260630/`.
- STILL OPEN: in-game runtime smoke (launch with no missing-master CTD; Ohmes-Raht
  origin resolves to Khajiit; shrine-prayer behaviour). Not yet release evidence.

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
