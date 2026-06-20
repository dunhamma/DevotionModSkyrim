# PDV Phase 21 Compatibility Notes

Status: living reference - Phase 21 compatibility rebaseline

This file explains how to read `phase20-targets.csv`. It is internal planning
evidence, not a public support claim and not maintainer endorsement.

Filename note: the `phase20-*` filenames are retained for continuity with
existing handoff references, but compatibility package work is now Phase 21.
Phase 21 begins after Phase 20 stabilizes the full roster/content lock, because
compatibility smoke is only meaningful against the complete mod surface.

## Target And Release Bar

Phase 21 targets seven list-author packages:

- P0: Authoria / ARR
- P1: JOJ, TOT, HOH, MOM, DoD, VOV

The 1.0 gate is an accepted Authoria integration/test package. The other six
lists should reach `patch-packaged`: exact removal set, one list-specific
compatibility patch, exact load-order placement, patcher steps, maintainer
brief, and focused smoke checklist.

## Status Ladder

- `plugin-review-pending`: row exists, but detailed scan has not happened.
- `plugin-reviewed`: plugin/mod list plus initial overlap scan is complete.
- `patch-packaged`: author handoff package is ready.
- `author-testing`: package is with the list author.
- `smoke-passed`: focused author or local smoke passed.
- `list-included`: list accepted PDV into integration/test flow or public build.
- `public-supported`: PDV may publicly name the list as supported.

Public-facing support claims wait for `public-supported`. Technical repo docs
may name target lists and evidence before then, but must not imply approval.

## Package Rules

- Ship one list-specific compatibility patch per target list.
- ESL-flag patches unless record count, FormID shape, or tooling makes that
  unsafe.
- Do not edit list-owned plugins directly.
- Keep patch masters minimal: base game, PDV, and only touched target plugins.
- Use shared templates/rules internally if they reduce repeated work, but keep
  author-facing packages simple.
- For Requiem lists, include PDV input patches and optionally a reference-only
  RFTI output for the exact snapshot. Authors regenerate final RFTI.

## Compatibility Policy

Religion overhauls are replacement-first. Remove the active religion overhaul
and direct dependent religion patches for the target list. Other religion mods
are research sources and removal targets, not coexistence promises.

PDV may own replacement shrine reward behavior for the core religion set, but
only through targeted adapters. Do not replace global vanilla shrine activator
scripts. Classify survival, visual, temple, statue, and worldspace content
without taking ownership of those systems.

System-family rules:

- Survival/needs mods are context only. They can shape eligibility, caps, or
  duplicate-punishment avoidance, not raw piety gain/loss.
- Curse mods support curated theology transitions only: onset, cure, voluntary
  embrace/renunciation, major feeding/restraint choices, beast-form rites, and
  Hircine/Molag Bal/Azura-relevant moments.
- Quest/newland hooks must be high-signal: stable stage, clear theology, and
  relevance to a supported list.
- Adult, romance, and social frameworks are curated authored hooks only. Do
  not add generic framework event adapters.
- Compatibility patches may tune mechanics, route signals, and classify
  records, but must not change PDV theology.

## Custom Race Support

Custom races opt into one of PDV's ten existing race profiles; V1 does not add
bespoke custom-race deity rosters. The supported profile indices are:

| Index | Profile |
|---|---|
| 0 | Nord |
| 1 | Imperial |
| 2 | Breton |
| 3 | Altmer |
| 4 | Bosmer |
| 5 | Dunmer |
| 6 | Khajiit |
| 7 | Argonian |
| 8 | Orc |
| 9 | Redguard |

Preferred integration order:

1. RaceCompatibility ActorProxy keywords, when the race plugin provides them.
2. Race Blood Test `Treat` / `Morph` rules, when the list uses that framework.
3. Explicit PapyrusUtil entries in `PDV_RaceMap.json`.

Ohmes-Raht / Half-Khajiit ships as Khajiit profile `6` by default:

```text
0x03322B|HalfKhajiit.esp -> 6
0x05693A|HalfKhajiit.esp -> 6
```

The confirmed DoD Race Blood Test pattern is:

```text
Treat "HalfKhajiitRace" As "KhajiitRace";
Treat "HalfKhajiitRaceVampire" As "KhajiitRaceVampire";
Morph "HalfKhajiitRaceVampire" Is "HalfKhajiitRace";
```

Temporary beast forms are not cultural origins. Werewolf, Vampire Lord, or other
short-lived transformation RACE records belong in `PDV_TemporaryRaceMap.json`
under `temporaryRaceForms`, which makes PDV defer origin capture until the
player reverts. Do not map those forms in `PDV_RaceMap.json`.

Readback boundary: ARR and DoD local Half-Khajiit plugins currently contain only
`HalfKhajiitRace` and `HalfKhajiitRaceVampire`; no `HalfKhajiitWerewolf` RACE
record was present in the checked plugins on 2026-06-20. Runtime/manual custom
race smoke remains a separate proof bucket.

## Evidence And Smoke

Static analysis is names-plus-conflicts: scan plugin/mod names, then inspect
targeted record conflicts for shrine rewards, spells/effects, quests, races,
keywords, globals, and patch masters. Prefer a PDV scanner/Mutagen-style pass;
use xEdit for ambiguous conflicts.

Focused smoke covers startup, MCM/status, shrine prayer, one devotion action,
relevant curse/survival case where applicable, dawn tick, save/reload, and
Papyrus log review. Smoke fails on missing masters, crash/startup failure, PDV
Papyrus errors, broken MCM/status/prayer/dawn/save flows, or unresolved
high-risk record conflicts.

Non-blocking known issues may be handed off if they are documented: cosmetic
conflicts, unsupported outlier shrines, deferred quest hooks, or low-risk
warnings.
