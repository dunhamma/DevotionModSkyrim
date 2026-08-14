# PDV Mod Packaging State Authority

Updated: 2026-08-14 AEST
Status: v1.5.0 final remains the published line from clean commit `e63de5f5`; the ground-up V3 Slice 1 catalog/runtime/semantic/package backend is green and awaits one combined fresh-game plus Authoria smoke before runtime acceptance.

The published v1.5.0 package incorporates the closed official-quest work: all 18 ambiguity
decisions, the `FreeformRiften02` selector adapter, the owner-approved tag/profile
correction slate, and the core matrix expanded to 4,108 cells across 354 quest
EditorIDs (main-quest coverage reconciled, PR #76). The optional SPID NPC
religious-recognition feature is deliberately unadvertised in 1.5.0 and now defaults
OFF (owner decision 2026-08-12): it is wired but not yet in-game validated, and its
hard-rival path sets a faction ENEMY reaction that needs an attack-on-sight check
before it is advertised. The archive is tagged and published; this does not promote
the unadvertised SPID feature or close its runtime evidence.

## Purpose

This is the living authority for Devotion core and compatibility-package state.
Read it before changing a package, reporting what an archive contains, or
promoting a compatibility option from experimental to supported.

The dated ARR review is preserved in
`PDV_QuestModPatches_ARR_Review_2026-08-06.md`. That review is source evidence;
this file owns the current decision and state.

## Locked v1.5 package boundary

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

## Locked ground-up V3 package boundary

1. Core retains the same no-third-party-master boundary.
2. The 75 data-only compatibility sources compile into one deterministic,
   delta-only third-party catalog and install automatically in the all-in-one
   package. Runtime plugin and sentinel checks keep absent sources inert.
3. Only the five integrations that ship an ESPFE or patch-owned script remain
   dependency-detected FOMOD choices. Their narrow source masters remain
   conditional and never become core masters.
4. Per-source CSVs remain local authoring inputs. `dist` is generated output,
   never the semantic source of `sourceMod`, option ownership, or catalog data.
5. Core, official third-party, and external-extension catalogs load in that
   order using fully-qualified `pluginName|localFormId|stage` identity. A bad
   source rejects only itself.

The full Slice 1 interface, schema, activation, collision, and proof contract is
`PDV_V3Slice1QuestReaction.manifest.json`. This V3 boundary does not retroactively
change the published v1.5 installer.

Slice 1D-A backend proof is now green for AFDI. Its observer preserves the
30-global baseline/backoff/poll-retirement mechanism but submits one
`afdi|artifact_destroyed.*` semantic event into `PDV_QuestReactionRuntime`;
devotional outcomes live only in the official v2 catalog. Direct houseCARL
readback of the canonical/generated-identical ESP proves one Runtime property binding,
`PDV_QuestReactionRuntimeService -> 0716DF:Devotion.esp`, and a sole
`Devotion.esp` master after dynamic resolution replaced the typed AFDI anchor.
The SGE SEQ and PEX were regenerated and the adapter source/bytecode lock refreshed.
This is compile, package-byte, VMAD, and master proof only: AFDI runtime behavior
remains open for the combined fresh-game smoke.

Slice 1D-B backend proof is green. `PDV_QuestReactionCompatibility.manifest.json`
now generates the entire compatibility tree: one required official V2 catalog,
75 data-only integrations with no individual installer option, and exactly five
dependency-detected adapter folders. The generated tree contains 31 files and no
V1 channel/stage-adapter payload. `PDV_QuestReactionPackageV3.receipt.json` records
every path, byte length, SHA-256, and the tree hash. Installer simulation reports
zero destination collisions; normalized sorted ZIP creation extracts and exact-hash
verifies every member. This is package/backend proof only. Real mod-manager detection,
installed source/sentinel behavior, and Skyrim gameplay remain for combined smoke.

## Public-copy boundary

Player-facing package files and GitHub release notes describe only shipped capabilities,
installation behavior, and the complete integration inventory. They do not expose internal
audit labels, proof states, gate results, human-versus-machine verification distinctions, or
unfinished evidence bookkeeping. Those details remain in internal authorities and receipts.

Every public release note and packaged README lists all shipped quest-patch integrations,
all shipped KID integrations, and all shipped SPID integrations. A category with no shipped
integration is stated plainly as `None in this build`; planned or speculative coverage is
never presented as shipped support.

## UI delivery contract

All accepted devotional acts, including modular quest, shrine, and observer
signals, finalize through the core reaction surface. One logical act produces
exactly one Prisma toast and one source Book-of-Days entry. A distinct tier or
milestone Chronicle entry may accompany the act, but it does not create a
second toast. Capped, duplicate, zero-credit, and classify-only events create no
false player-facing acknowledgement.

Every compatibility source carries its player-facing name in the V2 catalog.
The core queue preserves that name through finalisation: the transient
Prisma toast displays it and the persistent Book-of-Days entry stores and
displays it. Core reactions omit the optional field. Existing saves pad the new
journal source list before appending, so a new label cannot attach to an older
entry. For compatibility testing, these two labelled surfaces are the player-visible
confirmation that routing fired; logs remain diagnostic evidence, not the
player acceptance surface.

For Altmer heritage practice, `quiet` controls tone and cadence, not whether an
earned Prisma notice exists. Every accepted daily practice must receive the same
notice opportunity as equivalent race-substrate acts, and the toast and source
Book entry must reuse the same resolved practice line.

## v1.5.0 final release state

- Build date: 2026-08-12; version `1.5.0` (final); source commit
  `e63de5f5` (clean tree, `sourceDirty:false`).
- Public archive: `Devotion-FOMOD-1.5.0-20260812.zip`, 9,403,044 bytes,
  SHA-256 `91185A68A6459E4CB307FE6363A24A82BFBE5249AA7EA6DCC6C5E5D06D883083`.
  It contains 769 ZIP entries / 361 files: 236 required core files plus the
  125-file PatchHub tree. Exact membership and every core- and archive-member
  hash were checked after packaging; zero missing, extra, duplicate, or
  mismatched entries. The player-facing dev-status scan is clean.
- The core input is `Devotion-1.5.0-20260812.zip`, SHA-256
  `D35035752D31E0D74817510E035E8B2893BD9BBCDCC944ACEC6CCAF9F0E59D99`, 236 files.
  Its manifest, fresh PSC/PEX pairs, native DLL freshness/exports, Prisma
  asset/cache parity, ANAM, SEQ, version, and direct ESP-hash readback gates pass.
- Delta from v1.5.0d: core grew 233 -> 236 files as the closed official-quest
  matrix (4,108 cells / 354 quest EditorIDs, main-quest coverage reconciled in
  PR #76) is now shipped; PatchHub inventory unchanged at 80 options / 78 channels.
  SPID NPC religious-recognition now defaults OFF and is cut from the changelog
  (manager getters recompiled, PDV_MCM recompiled to satisfy the dependency gate).
  Adds a user-selectable Normal/Large Prisma toast size (MCM: Presentation -> Toast
  size) for 4K legibility; the Prisma view cache key was bumped to match. The Large
  sizing still awaits a 4K in-game confirmation.
- Tagged and published. Runtime, presentation, balance, and save/load observations
  remain post-release tester evidence, not release gates.

## v1.5.0d prerelease state (historical)

- Build date: 2026-08-12; internal version `1.5.0`; prerelease label `d`;
  source commit `add677167467ecfef0f6e4e0caccbc148a439000`.
- Public archive: `Devotion-FOMOD-1.5.0d-20260812.zip`, 9,389,668 bytes,
  SHA-256 `B53FBA4879E33557ECE967E51A5D683A364C7566D953B801A3243CE5C94AE62F`.
  It contains 766 ZIP entries / 358 files: 233 required core files plus the
  125-file PatchHub tree. Exact membership, every core-member hash, and every
  assembled archive-member hash were checked after packaging; there are no
  missing, extra, duplicate, or mismatched file entries.
- The core input is `Devotion-1.5.0-20260812.zip`, SHA-256
  `F43C4B8EEA627D1CEE8109518FAAAB2611A1195427CA5243E7D96D12E690F385`.
  Its 233-entry manifest, 100 fresh PSC/PEX pairs, native DLL freshness and
  exports, Prisma asset/cache parity, ANAM, SEQ, version, and direct ESP-hash
  readback gates pass.
- The PatchHub has 80 dependency-gated options: 75 data-only quest-reaction
  options and five plugin-bearing options. Seventy-eight channel JSON files are
  present. The validated installer tree has 125 files and tree SHA-256
  `CB4AADDB12EB04C6E56903909A0CF774EB1F82146510A4A35887515D3660D193`.
- The JoJ B-series is closed at 37/37 candidates: 31 APPROVED and six SILENT.
  Interesting NPCs contributes 27 cells / 269 deity rows behind `3DNPC.esp`.
- KID contributes 31 live rules across Green Pact food and seven semantic
  item-action families. SPID contributes 58 live rules: 29 faith-keyword rules
  and 29 cohort-faction rules. Both remain soft dependencies; the underlying
  plugin adds 57 faith keywords, 15 semantic keywords, one player faction, and
  57 cohort factions without adding AI packages or inventory distribution.
- The 2026-08-12 maintenance pass keeps religious recognition event-driven and
  presents effective identity/band transitions through one Prisma-first notice
  plus one Book-of-Days entry. The focused panel and normal MCM surface retain
  the current state without per-NPC or periodic polling. All 100 shipped
  Papyrus pairs are fresh, with zero broken optimization findings.
- Prisma recognition payload, renderer, cache, dedupe, fallback, and journal
  contracts pass. The broad Prisma audit has one preserved failure for the
  deferred issue #37 Daedric mechanic-copy table; no Prince gameplay records or
  copy were retuned in this release.
- `PDV_QuestModPatches_FOMOD_Validation.json` is the exact membership and
  checksum receipt for the PatchHub input. The ignored local
  `Devotion-FOMOD-1.5.0c-20260812.zip.proof.json` records the assembled archive.
- This is a complete tester release, not an experimental partial hub. The
  package is save-safe reaction data and narrow patch support; runtime routing,
  presentation, balance, and save/load observations are post-release tester
  evidence and are not release gates.
- All requested B-series, packaging, name-resolution, player-copy, Book-of-Days,
  and Prisma-to-1.0 gates pass. The broader `pdv_prisma_ui_audit` retains one
  pre-existing non-PatchHub failure: its static Daedric mechanic-copy table and
  the record contract disagree on older boon rows. Direct houseCARL readback
  confirmed the shipped Boethiah records; gameplay records were not retuned in
  this release.

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
- core payload manifest count plus V3 required-catalog/adapter inventory;
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
| `Devotion-FOMOD-1.5.0a-20260811.zip` | 9,299,883 | `56470A12F71FD2BBB47D0B3FAD9B5F75CCD3D2E9C5A8A9D6DD38FFC2778B5208` | 746 ZIP entries / 353 files; required 1.5.0 core; 77 optional patches; 75 source-labelled channels; public patch/KID/SPID inventory |
| `Devotion-FOMOD-1.5.0b-20260811.zip` | 9,317,126 | `A60E742FA43DD75FDCA03ACA01597A61DFB4E45D14AE46EA78D92C2D14304722` | 748 ZIP entries / 355 files; 233-file required core; 77 optional patches; 75 source-labelled channels; 31 KID and 58 SPID rules |
| `PDV-QuestModPatchHub-20260812.zip` | 987,283 | `C9D39F9321BC3045C48A9C771CC318F8CB768C6ED557F15124C99B90D15D6D5F` | 122 members; 77 options; 75 channel files; corrected complete patch/KID/SPID root inventory |
| `Devotion-FOMOD-1.5.0c-20260812.zip` | 9,320,236 | `89D2010A56FB4DCECBD0DDC2096B0281E2F949259F0933F833BA55783F2FB9CF` | 748 ZIP entries / 355 files; 233-file required core; 77 optional patches; 75 source-labelled channels; 31 KID and 58 SPID rules |
| `Devotion-FOMOD-1.5.0d-20260812.zip` | 9,389,668 | `B53FBA4879E33557ECE967E51A5D683A364C7566D953B801A3243CE5C94AE62F` | 766 ZIP entries / 358 files; 233-file required core; 80 optional patches; 78 source-labelled channels; expanded official quest recognition; visible event-driven SPID recognition |
| `Devotion-FOMOD-1.5.0-20260812.zip` | 9,403,044 | `91185A68A6459E4CB307FE6363A24A82BFBE5249AA7EA6DCC6C5E5D06D883083` | 769 ZIP entries / 361 files; 236-file required core; 80 optional patches; 78 source-labelled channels; ships the reconciled 4,108-cell official-quest matrix; SPID NPC recognition defaults OFF / unadvertised / (experimental) MCM copy; adds Normal/Large toast size toggle; README requirements completed (Address Library, PO3); published v1.5.0, repackaged from clean commit e63de5f5 |

Core intentionally includes the current Altmer and Khajiit runtime/UI assets,
the canonical core quest matrix, the Calian assets, the native Prisma bridge,
three flat Data-root KID/SPID distributor files, and `TempleBlessingScript`. It intentionally excludes
`PDV_QuestReactionMatrix_ARR.json`, named third-party reaction channels, AFDI,
TGAE-specific data, shrine compatibility records, and all PatchHub hook files.

PatchHub intentionally includes only dependency-gated per-mod channels, the
generic TGAE adapter data, three existing narrow hook ESPFEs and fragments, the
AFDI observer ESPFE/SEQ/script, and the neutral Daedric Shrines AIO ESPFE/BOS
pair. It intentionally excludes the retired Authoria combined plugin and tree,
Creation Club channel options, core scripts, the core matrix, Green Pact KID,
and tester ledgers that are not install payload.

## Candidate acceptance evidence

- Core archive extraction and exact-manifest verification: PASS, 233 entries,
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
