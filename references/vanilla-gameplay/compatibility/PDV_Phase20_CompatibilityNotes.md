# PDV Phase 20 Compatibility Notes

Status: living reference - Phase 20 rebaseline

This file explains how to read `phase20-targets.csv`. It is internal planning
evidence, not a public support claim and not maintainer endorsement.

## Target And Release Bar

Phase 20 targets seven list-author packages:

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
