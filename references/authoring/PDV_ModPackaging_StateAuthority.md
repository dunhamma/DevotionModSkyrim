# PDV Mod Packaging State Authority

Updated: 2026-08-07 AEST
Status: approved transition in progress; replacement archives not yet accepted

## Purpose

This is the living authority for Devotion core and compatibility-package state.
Read it before changing a package, reporting what an archive contains, or
promoting a compatibility option from experimental to supported.

The dated ARR review is preserved in
`PDV_QuestModPatches_ARR_Review_2026-08-06.md`. That review is source evidence;
this file owns the current decision and state.

## Locked package boundary

1. Devotion core carries vanilla, DLC, Creation Club, and generic runtime
   capabilities. It does not carry named modlist or third-party reaction data.
2. Devotion - PatchHub is fully modular. Each source mod has one conditional,
   self-contained option containing only its channel, generic adapter data, and
   any narrowly-mastered ESPFE or patch-owned script it requires.
3. The former Authoria all-in-one lane and combined plugin are superseded. ARR
   consumes the same modular hub as any other load order.
4. A PatchHub option cannot replace Devotion core scripts or matrices.
5. Core and PatchHub are separate archives, manifests, checksums, and support
   claims. An outer tester handoff may distribute both without merging their
   install trees.

## UI delivery contract

All accepted devotional acts, including modular quest, shrine, and observer
signals, finalize through the core reaction surface. One logical act produces
exactly one Prisma toast and one source Book-of-Days entry. A distinct tier or
milestone Chronicle entry may accompany the act, but it does not create a
second toast. Capped, duplicate, zero-credit, and classify-only events create no
false player-facing acknowledgement.

For Altmer heritage practice, `quiet` controls tone and cadence, not whether an
earned Prisma notice exists. Every accepted daily practice must receive the same
notice opportunity as equivalent race-substrate acts, and the toast and source
Book entry must reuse the same resolved practice line.

## Current transition state

- Integration branch: `codex/arr25-content-sweep`.
- Baseline before reconciliation: `f63a07e4`.
- Altmer Prisma parity commit integrated as `f476e535`.
- Core version remains `1.0.4`; the replacement build date and checksums must
  distinguish it from `Devotion-1.0.4-20260727.zip`.
- Legacy ARR matrix decomposition, modular FOMOD conversion, special-lane
  isolation, release-manifest hardening, and replacement archive construction
  remain in progress.
- Machine verification, runtime route proof, player-surface proof, semantic
  proof, and support promotion are separate. No replacement archive is
  supported yet.

## Required state update

Every future package build or packaging status change updates this file with:

- build date, version, source commit, archive filename, byte size, and SHA-256;
- core payload manifest count and PatchHub option/channel/plugin inventory;
- intentionally included and excluded files;
- machine-gate results and exact unresolved failures;
- runtime-route, player-surface, semantic, save/load, and support evidence;
- superseded archive names and any migration or install-order warning.

A package state claim is incomplete if the archive has not been extracted and
checked against its recorded manifest. A green build or readback cannot close
runtime, player-surface, semantic, or support proof.

## Planned replacement artifacts

- `Devotion-1.0.4-20260807.zip`
- `PDV-QuestModPatchHub-ARR25-Experimental-20260807.zip`

These names are targets until the archives pass their acceptance gates. Record
the actual final names and hashes here rather than assuming the targets shipped.
