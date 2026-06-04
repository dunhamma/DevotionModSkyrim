# PDV Project-Wide Context Hygiene Audit

Status: live hygiene ledger
Last updated: 2026-06-04 AEST

This file records project-wide cleanup decisions so context is preserved without
letting stale scaffolding look like current work.

## Current Cleanup Boundary

- Preserve archive and historical planning docs unless a current file map points
  to a replacement.
- Prefer status refreshes over deletion for docs that still explain why a path
  was taken.
- Delete only ignored local build/temp artifacts that are rebuildable or already
  superseded by tracked proof ledgers.
- Do not treat route proof, readback proof, or static matrix proof as manual
  runtime/feel proof.

## Refreshed Current Docs

- `PDV_MOD_SETUP.md`: refreshed the Daedric blocker entry so it points at the
  current proof-path blockers rather than older D-15..D-18 decision blockers.
- `references/authoring/PDV_PreBetaRaceScalingSpine.md`: updated the content
  dependency language to say Daedric decisions are locked and proof remains.
- `race-sheets/PDV_RaceDesign_Nord.md`: replaced the balancing-TBD note with
  the current `COMMITMENT_OFFER_THRESHOLD=50` and `25/50/85` threshold contract,
  while keeping manual feel tuning open.
- `references/authoring/PDV_Phase18_DialogueDrafts.md`: marked the file as
  V2/historical dialogue parking so TODO rows do not read as V1 blockers.
- `references/authoring/PDV_CAT6PromotionPilot.md`: refreshed Daedric promotion
  gating so CAT-6 now waits on proof against D-15..D-18 locks, not unresolved
  stigma/curse/order decisions.
- `references/authoring/PDV_RaceGameplayBalanceAudit.md`: updated the Daedric
  audit recommendation from decision-resolution to proof-path closure.

## Preserved Context

- `archive/**`: frozen historical context; no deletion in this pass.
- `scratch/parked-untracked-phase11-20260525-152445/`: parked untracked
  context. It is ignored, but preserved because deleting it could lose session
  recovery context.
- `scratch/phase12_live/` and `scratch/phase13_16_live/`: ignored live scratch
  context. Preserved until a tracked summary or explicit disposal decision
  exists.
- `native/vendor/Creation-Kit-Platform-Extended/`: ignored local dependency
  cache. Preserved because it may be needed for local authoring/proof tooling.
- `.claude/settings.local.json`: local agent settings. Preserved and ignored.

## Removed Local Noise

The cleanup pass may remove ignored items from these families:

- transient `generated/_audit_tmp.json`
- transient CKPE heartbeat/duplicate replay scratch packets
- stale `scratch/phase20-*` local proof dumps after tracked ledgers captured the
  useful status
- ignored `bin/` and `obj/` outputs under narrow authoring helpers
- ignored `native/DevotionPrismaBridge/.xmake/` and `native/DevotionPrismaBridge/build/`

These removals should not change tracked project history or current proof
status. If any of these artifacts become evidence-worthy, promote their summary
into a tracked proof ledger before deleting the local file.

## Follow-Up Audit Hooks

- Re-run `rg` for stale terms after each major beta-readiness tranche:
  `stale`, `superseded`, `deprecated`, `obsolete`, `TODO`, `TBD`, and
  `blocker`.
- Check `git ls-files --ignored --others --exclude-standard` when the worktree
  feels cluttered. Keep ignored dependencies/settings; remove rebuildable temp
  files and build outputs.
- Keep `PDV_AllRaceDaedricBetaReadinessLedger.md` as the current combined
  race-plus-Prince blocker ledger until beta-feel readiness is closed.
