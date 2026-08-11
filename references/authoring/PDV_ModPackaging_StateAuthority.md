# PDV Mod Packaging State Authority

Updated: 2026-08-11 AEST
Status: complete PatchHub tester-release archive machine-verified; runtime and player-observation evidence continues post-release

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
5. Core and PatchHub retain separate source manifests and validation receipts,
   but the public tester distribution is one all-in-one FOMOD: required core
   plus every dependency-gated optional patch. A PatchHub-only archive may be
   retained as an internal proof artifact, not as the player download.

## UI delivery contract

All accepted devotional acts, including modular quest, shrine, and observer
signals, finalize through the core reaction surface. One logical act produces
exactly one Prisma toast and one source Book-of-Days entry. A distinct tier or
milestone Chronicle entry may accompany the act, but it does not create a
second toast. Capped, duplicate, zero-credit, and classify-only events create no
false player-facing acknowledgement.

Every PatchHub channel carries the player-facing name of its owning FOMOD
option. The core queue preserves that name through finalisation: the transient
Prisma toast displays it and the persistent Book-of-Days entry stores and
displays it. Core reactions omit the optional field. Existing saves pad the new
journal source list before appending, so a new label cannot attach to an older
entry. For patch testing, these two labelled surfaces are the player-visible
confirmation that routing fired; logs remain diagnostic evidence, not the
player acceptance surface.

For Altmer heritage practice, `quiet` controls tone and cadence, not whether an
earned Prisma notice exists. Every accepted daily practice must receive the same
notice opportunity as equivalent race-substrate acts, and the toast and source
Book entry must reuse the same resolved practice line.

## Current PatchHub tester-release state

- Build date: 2026-08-11; source state: the consolidated
  `feat(joj): complete B07 and close B-series content audit` commit.
- Archive: `PDV-QuestModPatchHub-20260811.zip`, 984,357 bytes, SHA-256
  `5548314D06F28FF9CF577F76650C63FED35AEB3A85C28557338F0B2D56BFB0B1`.
- The PatchHub has 77 dependency-gated options: 72 data-only quest-reaction
  options and five plugin-bearing options. Seventy-five channel JSON files are
  present. The validated installer tree has 122 files and tree SHA-256
  `14C0A6B2F3F12271F3868D837D820664A00687B9BBC398FDABF3C3A996ADECA0`.
- The JoJ B-series is closed at 37/37 candidates: 31 APPROVED and six SILENT.
  Interesting NPCs contributes 27 cells / 269 deity rows behind `3DNPC.esp`.
- `PDV_QuestModPatches_FOMOD_Validation.json` is the exact membership and
  checksum receipt: 122 archive members, zero missing, extra, or mismatched.
- This is a complete tester release, not an experimental partial hub. The
  package is save-safe reaction data and narrow patch support; runtime routing,
  presentation, balance, and save/load observations are post-release tester
  evidence and are not release gates.
- Core was not rebuilt in this tranche. The 2026-08-07 core artifact and its
  separate proof boundary remain unchanged.

## Superseded 2026-08-07 candidate state

- Integration branch: `codex/arr25-content-sweep`.
- Packaging source commit: `ff7fc4e`.
- Altmer Prisma parity commit: `f476e535`.
- Core version remains `1.0.4`; the build date and checksum distinguish this
  candidate from the public `Devotion-1.0.4-20260727.zip`.
- Legacy ARR source is decomposed into eight source-backed channels; fourteen
  Creation Club cells are promoted to core. Core has 2,144 cells / 234 quest
  keys / 157 watches. Core plus 39 PatchHub channels has 2,670 cells / 360
  quest keys and zero duplicate natural keys.
- The PatchHub has one `SelectAny` modular step with 41 dependency-gated
  options: 39 reaction channels, the AFDI observer, and the Daedric Shrines AIO
  prayer activators. It contains five narrow ESL-flagged plugins in total: the
  three pre-existing dialogue/result hooks plus the two special-lane plugins.
- This section records the older ARR25 experimental state. Its PatchHub archive
  is superseded by the complete 2026-08-11 tester release above.

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

## Built replacement artifacts

| Archive | Bytes | SHA-256 | Exact contents |
|---|---:|---|---|
| `Devotion-1.0.4-20260807.zip` | 8,294,880 | `CF7CFDBD5FC84D6B7BA5C6B4DFC697745978DA50C3290E1ED89095D41775E4DE` | 231 manifest entries; 100 PSC/PEX pairs; Altmer five-deity roster repair |
| `PDV-QuestModPatchHub-ARR25-Experimental-20260807.zip` | 509,879 | `DEC5EBC4285F3985D3D8F0BDF1ADBE4F288C20FB09F3D83EA3ECD5457F633949` | 80 members; 41 options; 39 channel files |
| `PDV-QuestModPatchHub-20260811.zip` | 984,357 | `5548314D06F28FF9CF577F76650C63FED35AEB3A85C28557338F0B2D56BFB0B1` | 122 members; 77 options; 75 channel files; complete B01-B07 JoJ tester release |

Core intentionally includes the current Altmer and Khajiit runtime/UI assets,
the canonical core quest matrix, the Calian assets, the native Prisma bridge,
and `TempleBlessingScript`. It intentionally excludes
`PDV_QuestReactionMatrix_ARR.json`, named third-party reaction channels, AFDI,
TGAE-specific data, shrine compatibility records, and all PatchHub hook files.

PatchHub intentionally includes only dependency-gated per-mod channels, the
generic TGAE adapter data, three existing narrow hook ESPFEs and fragments, the
AFDI observer ESPFE/SEQ/script, and the neutral Daedric Shrines AIO ESPFE/BOS
pair. It intentionally excludes the retired Authoria combined plugin and tree,
Creation Club channel options, core scripts, the core matrix, Green Pact KID,
and tester ledgers that are not install payload.

## Candidate acceptance evidence

- Core archive extraction and exact-manifest verification: PASS, 231 entries,
  zero missing or extra members; all 100 source/bytecode pairs fresh.
- PatchHub XML, source folders, individual-option simulations, all-option and
  representative simulations, destination collision checks, archive member
  equality, and per-member checksums: PASS, zero warnings and zero failures.
- Matrix merge/compile/self-test and core-plus-channel reconciliation: PASS;
  no duplicate natural keys.
- Canonical reachability audit: PASS, 20,342 inventory rows / 1,284 mods, zero
  malformed names. T16 adapter and non-quest static gates: PASS (30 and 47
  assertions respectively).
- Altmer Prisma policy/parity audit: PASS, 124 checks. All seven registered
  heritage producers retain one accepted Book line and one Prisma notice; a
  distinct tier Chronicle is allowed only on crossing.
- Signal-floor backend scenarios pass, but their runtime/manual evidence slots
  remain open. Paired equity retains baseline debt: 114 open gaps, 75 waivers,
  zero name errors, and five warnings; this candidate adds no new open-gap
  count.
- Direct houseCARL file proof matches the packaged Anvil `Devotion.esp` hash
  and reads 1,988 records across 22 record types. Because houseCARL remained on
  ARR for this task, active Anvil load-order winner, FormLink, VMAD and contested
  override proof were not refreshed.
- Full strict Phase 20 Altmer verification was attempted but exceeded its
  124-second run window; no PASS is claimed from that command. The targeted
  Prisma gate and compilation passed.

## ARR 2.5 deployment state

The additive experiment profile
`KoK R11 - PDV ARR25 Experiment 20260807` is installed and selected. The base
`KoK R11` profile files remain unchanged. It enables the two new mod folders,
disables the three prior Devotion/compatibility folders, and replaces the
combined ESP with five narrow ESPFEs.

Deployment preflight passes at 33 PASS / 4 INFO / 0 FAIL: 157 core watches,
39 valid winning channels, and 3,743 checked plugins present in matching
`plugins.txt` / `loadorder.txt` order. Direct houseCARL profile readback resolves
3,803 active plugins to real files. Nine representative core/PatchHub runtime
assets and all six installed plugin files have the intended sole provider,
including the core matrix, manager PEX, Altmer practice JSON, Prisma app,
Vigilant channel, TGAE adapter, AFDI PEX/SEQ, and Daedric shrine BOS map. The structured receipt is
`PDV_ARR25_ModularDeploymentReceipt_2026-08-07.json`.

The read-only runtime-evidence coverage gate also passes: 72 of 72 quest
outcomes are assigned exactly once, with no missing or orphan case; the
non-quest packet contains 30 AFDI and 19 other cases. This proves assignment
coverage, not an in-game result.

This closes deployment-state and asset-winner proof only. No fresh-process
matrix registration, gameplay route, player-surface, semantic, save/load, or
support proof is implied.

The 2026-08-07 Altmer runtime correction limits Altmer scoring, medallion, and
quest-reaction notices to Auri-El, Magnus, Xarxes, Syrabane, and Trinimac.
Mara, Stendarr, and Y'ffre are deferred to a future roster review. The rebuilt
core above is installed in the additive experiment profile; Book of Days repair
version 3 removes affected historical entries on the next Altmer journal open.
The Prisma static audit passes 125 checks, but the corrected runtime behavior
still requires a fresh in-game observation.

## Open proof and migration contract

Install core first and PatchHub below it on ARR 2.5 `KoK R11`, selecting only
detected source-mod options. Remove the retired `PDV_AuthoriaARR_Combined.esp`,
`PDV_QuestReactionMatrix_ARR.json`, and any older compatibility package that
overwrites core scripts or matrices. Then run the ARR runtime preflight and the
structured cases in
`PDV_ARR25_ModularPatchHub_ExperimentRunbook_2026-08-07.md`.

Runtime routing, exactly-one-toast, exactly-one-Book beat, organic semantics,
save/load behavior, AFDI existing-save baseline, TGAE branch mapping, shrine
placement, and per-option support all remain open until tester evidence is
returned. Controlled `setstage` can prove routing but cannot clear inferred
semantic correctness. Superseded artifacts are
`Devotion-1.0.4-20260727.zip` and
`PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip`; preserve them only for
rollback or historical evidence.
