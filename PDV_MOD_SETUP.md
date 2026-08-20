# Player Devotion -- Mod Development Setup Reference
**Project:** Devotion Framework + Race Modules
**Engine:** Skyrim Special Edition (SSE)
**Last Updated:** 4E 201 (update this when your setup changes)

---

## Skyrim Plugin Work: houseCARL Direct

All plugin record reads, writes, and verification go through the `housecarl_*`
MCP tools directly. Do not route through, extend, or rebuild a local wrapper,
adapter, bridge, capability matrix, or authoring helper. Verification is a
`housecarl_read_record` / `housecarl_cross_plugin_query` readback after the
write -- that readback is the proof.

The legacy authoring layer (`pdv_author.mjs`, `pdv_writer_review.mjs`,
`creation-authoring`, `creation-merge-runner`, all `pdv-*-author`) is **deleted
from disk**, preserved only in `tools/pdv-authoring-trees-retired-2026-07-13.zip`.
Dated Decisions entries below that mention those helpers are historical record,
not instructions. The full rule, including the list of stale houseCARL beliefs
not to re-derive, lives in `AGENTS.md` under "houseCARL v1.7+ Direct Plugin
Work Rule".

---

## Project File Index

| File | Purpose |
|------|---------|
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity equivalency table - canonical lore reference |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice reference - design source document |
| `references/tamriel-cursed-worship-4e201.html` | Race-by-race curse-state religious interpretation source |
| `references/tamriel-daedric-worship-4e201.html` | Race-by-race Daedric practice source |
| `PDV_MOD_SETUP.md` | This file -- dev environment and architecture reference |
| `PDV_Architecture_v3.md` | Forward architecture, subsystem gates, beta/launch roadmap |
| `PDV_TargetEndStates_1.0.md` | 1.0 product target, per-race acceptance state, roadmap traceability |
| `references/authoring/PDV_DeityCoverageMatrix.json` | Phase 20 full roster authority for locked gods and Skyrim-present Princes across every race |
| `references/authoring/PDV_DaedricPrinceRecordContracts.json` | Generated Daedric Prince CAT-6 record contract for all sixteen Skyrim-present Princes: QUST, SPEL, MGEF, MESG, stigma globals, arrays, path scripts, and FormList membership |
| `references/authoring/PDV_MedallionRoster.manifest.json` | Phase 20 medallion roster contract: all ten race native rosters stay visible, live deities display as offer-owned roster entries, and no medallion entry directly commits a patron |
| `references/authoring/PDV_PrismaIntegrationBoundary.md` | Prisma/P2 integration boundary: P2 gameplay proof stays separate from Prisma UI presentation, with the handoff at manager-owned state and typed payloads |
| `references/authoring/PDV_Phase20AltmerImplementationCosting.manifest.json` | Phase 20 Altmer crisis/Lorkhan/favor/curse implementation manifest; currently proof-placement-gate-live for the crisis state, first two Altmer contextual favors, four ACTI trigger proof base records, three curse/exile message records, and four QASmoke proof references |
| `references/authoring/PDV_Phase20_AltmerProofPlacement_Runbook.md` | Phase 20 Altmer proof-placement/runtime runbook for the four proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20ArgonianImplementationCosting.manifest.json` | Phase 20 Argonian Hist/People/Void implementation manifest; currently proof-placement-gate-live for the concrete Hist substrate, Hist posture track, four proof ACTI base records, and four QASmoke proof references |
| `references/authoring/PDV_Phase20_ArgonianProofPlacement_Runbook.md` | Phase 20 Argonian proof-placement/runtime runbook for the four proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20OrcImplementationCosting.manifest.json` | Phase 20 Orc life-mode implementation manifest; currently proof-placement-gate-live for the life-mode state track, eight proof ACTI base records, and eight QASmoke proof references |
| `references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md` | Phase 20 Orc proof-placement/runtime runbook for the eight proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20RedguardImplementationCosting.manifest.json` | Phase 20 Redguard sect implementation manifest; currently proof-placement-gate-live for the sect state track, four proof ACTI base records, and four QASmoke proof references |
| `references/authoring/PDV_Phase20_RedguardProofPlacement_Runbook.md` | Phase 20 Redguard proof-placement/runtime runbook for the four proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json` | Phase 20 Bosmer non-hunter parity implementation manifest; currently proof-placement-gate-live for eight favor proof ACTI base records and eight QASmoke proof references |
| `references/authoring/PDV_Phase20_BosmerProofPlacement_Runbook.md` | Phase 20 Bosmer proof-placement/runtime runbook for the eight proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20KhajiitImplementationCosting.manifest.json` | Phase 20 Khajiit lunar/road/focus implementation manifest; currently proof-placement-gate-live for the lunar substrate, focus mirror, six proof ACTI base records, and six QASmoke proof references |
| `references/authoring/PDV_Phase20_KhajiitProofPlacement_Runbook.md` | Phase 20 Khajiit proof-placement/runtime runbook for the six proof ACTIs and their runtime smoke |
| `references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` | Consolidated Phase 20 QASmoke runtime proof runbook with checker commands, Survey/status immersion checks, negative checks, and closeout criteria |
| `references/authoring/PDV_Phase20*ImplementationCosting.manifest.json` | Phase 20 race implementation-costing manifests for Altmer, Argonian, Orc, Redguard, Bosmer non-hunter parity, and Khajiit |
| `references/authoring/PDV_PreBetaRaceScalingSpine.md` | Shared pre-beta race-scaling spine: Altmer active spine, Khajiit first contrast, Argonian second contrast, Orc/Redguard/Bosmer P1 packets, Breton/Dunmer/Imperial/Nord P2 audit-only packets |
| `references/authoring/PDV_PreBetaRaceGateLedger.md` | Shared all-race pre-beta gate ledger with current verdicts, accepted/rejected hooks, anti-farm rule, Survey/status result, final placement result, stack snapshot, expected/edge builds, and blocking follow-up |
| `references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md` | Combined beta-feel blocker ledger for all ten races plus all sixteen Skyrim-present Daedric Princes, including P2 runtime proof, manual evidence, Daedric 20C record/readback proof, and remaining runtime/display blockers |
| `references/authoring/PDV_BetaFeelReleaseGate.md` | Console-assisted beta-feel release gate for expected-build, edge-build, rejection, Survey/status, stack, and tester-handoff proof |
| `references/authoring/PDV_BetaTestPacket_Altmer.md` | First restarted full-race beta-test packet for Altmer Auri-El/Magnus/Xarxes sources, MQ104 edge, rejection checks, Survey clarity, anti-farm, and reward/stack snapshot |
| `references/authoring/PDV_DaedricBatch0_D18ProofLedger.md` | Static D-18 proof ledger for Daedric Batch 0: Azura, Vaermina, Meridia, and Molag Bal |
| `references/authoring/PDV_DaedricControlledProof_Runbook.md` | Controlled in-game proof runbook for all sixteen Daedric Prince paths through MCM controls, physical QASmoke sender refs, and all sixteen exact organic quest-stage senders |
| `references/authoring/PDV_DaedricInGameSmokePacket.md` | Compact generated Daedric tester packet with MCM sweep, QASmoke activator names/EditorIDs/positions, organic `setstage` routes, checker commands, and manual observation checklist |
| `references/authoring/PDV_DaedricRuntimeEvidenceLedger.json` | Structured Daedric runtime/manual evidence ledger consumed by `pdv_daedric_beta_gate`; starts every Prince pending and is updated only after counted in-game proof |
| `references/authoring/PDV_ProjectWideContextHygiene_Audit.md` | Live hygiene ledger for stale-doc refreshes, preserved context, and ignored local artifact cleanup decisions |
| `references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` | Remaining Phase 20 no-in-game-proof queue for gate-ledger hardening, immersive hook contracts, static verifier work, stack audits, CAT-6 prep, recognition prep, and Daedric proof-path closeout |
| `references/authoring/PDV_Phase20_NoInGameProof_Gates.json` | Structured no-game Phase 20 gate packet checked by `--strict-phase20-race-costing`; now owns all-race immersive hook contracts, asset policy, and the P2 source-scaffold ledger |
| `references/authoring/PDV_Phase20_AllRaceSourceCuration_Runbook.md` | Unified all-race source curation handoff; keeps scan-only quest candidates out of live route/FormList sources until exact quest/stage/outcome readback is complete |
| `references/authoring/PDV_Phase20_NextReadbackHook.md` | Next-session hook for the post-P2-book-fill runtime pass and exact-stage quest gate; do not treat source-fill readback as beta proof |
| `references/authoring/PDV_Phase20_SourceCurationDossier.md` | Readback-backed all-race quest-stage source curation dossier with semantic verdicts and implementation statuses; no live source-fill permission by itself |
| `references/authoring/PDV_Phase20_QuestStageExclusionAudit.md` | Quest-stage exclusion and future-review audit with reason codes for the vanilla/DLC readback inventory |
| `references/authoring/PDV_Phase20_SourceFillApprovalLedger.json` | Source-fill approval ledger for the safe P2 book-read FormList fill and blocked quest-stage/non-P2 receiver decisions |
| `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` | Source-scaffolded all-race receiver manifest for player-alias PO3 book, spell, harvest, weather, and quest-stage hooks, with FLST shell, alias-property, approved book-fill readback, exact-stage quest gate, and receiver anti-farm metadata |
| `references/authoring/PDV_Phase20_P2SourceCuration_Runbook.md` | P2 source curation handoff for deciding exact book, spell, harvest, weather, and quest-stage source records before approved source-fill writes |
| `references/authoring/PDV_Phase20_ContentHook_ClaudeReviewPacket.md` | Review-only parking packet for weak, broad, lore-controversial, branch-unproven, or non-live-fill hook candidates that need design/readback promotion before entering the P2 manifest |
| `references/authoring/PDV_Phase20_RewardRecordContracts.json` | All-ten-race first-tier reward record contract for `SPEL`/`MGEF` EditorIDs, player-facing text, provisional magnitudes, Daedric/stack rules, author/wire/check commands, and runtime/manual proof gates |
| `references/authoring/PDV_ConsolidatedBuildPass_RecordWave.spec.json` | 2026-06-14 first consolidated record-wave spec for voice-conformance `MESG`/`NOTI` promotion plus Altmer `PDV_RepTrack_ThalmorAlignment` readback |
| `references/authoring/PDV_Phase20_ManualEvidenceLedger.json` | Structured pending evidence intake for future Phase 20 manual/runtime checks, including immersive hook proof and asset-status slots |
| `references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md` | Phase 20 manual-check handoff for wrong-origin rejection, generic-hook rejection, Survey/status display, stack snapshots, immersive hook proof, and asset-status checks per race |
| `references/authoring/PDV_Phase20_BetaReadinessRemainder.md` | End-of-tranche beta-readiness handoff separating proven source-fill/readback work from remaining automated, runtime/manual, placement/feel, and tester-handoff blockers |
| `references/authoring/PDV_RaceGameplayBalanceAudit.md`, `PDV_RaceRewardBudgetLedger.md`, `PDV_RaceEffectReviewLedger.md`, `PDV_RacePlaystyleCoverageLedger.md`, `PDV_RaceImplementationCostingBacklog.md` | Multi-lens race gameplay audit, reward/effect/playstyle/immersion ledgers, and implementation-costing backlog |
| `tools/pdv_compile.mjs` | PapyrusCompiler wrapper for stale/all/targeted PDV script compiles |
| `tools/pdv_verify.mjs` | Read-only verifier for Anvil/MO2/ESP/script wiring drift. 2026-07-26: the Daedric price gate checks all 48 MGEF/SPEL pairs for exact detrimental flags, effect linkage, positive absolute stored magnitude, and reversible resource-pool archetypes. 2026-07-15: gained `checkSourceLacks` (assert-ABSENT contracts) -- used where a ratified design change REMOVED code and the gate now guards the removal (Phase 18 dialogue quartet via manifest status `v1-removed-voiced-v2`; the four converted deity-spine pulses). Reintroduction of guarded-absent code is a strict FAIL by design. |
| `tools/pdv-authoring-trees-retired-2026-07-13.zip` | **Retired** Mutagen/CKPE record-author helper trees (`pdv_author.mjs`, `pdv_writer_review.mjs`, `creation-authoring`, `creation-merge-runner`, all `pdv-*-author`) | Forensics only. All plugin record reads/writes/verification now go through the `housecarl_*` MCP tools directly -- see the houseCARL Direct Plugin Work Rule above. Do not restore, extend, or copy the dry-run/backup/proof-ledger pattern. |
| `tools/pdv_housecarl_p2_readback.mjs` | Direct houseCARL exact readback for P2 receiver FormLists, approved source membership, and player-alias VMAD bindings; unexpected live members fail |
| `tools/pdv_pantheon_record_readback.mjs` | Direct houseCARL focused Imperial/Nord reward and substrate inherited-property readback |
| `tools/pdv_pantheon_presentation_readback.mjs` | Direct houseCARL broad reward, active-substrate, Observe-the-Moons, manager VMAD, and player-visible `Spine` readback |
| `tools/pdv_active_effect_naming_audit.mjs` | Direct houseCARL audit of every `PDV_Bless_*` parent spell and child MGEF; parent spells use family/tier headings while child effects use concise mechanical or distinct scripted-effect labels |
| `tools/pdv_guide_tables_gen.mjs` | Regenerates race-guide bonus tables from the reward spec JSONs and prints them to STDOUT -- it does NOT edit the guide `.md` files; guide tables are hand-spliced from its output. Its old Observant/Faithful "retired-word" lint was retired 2026-07-15 (those are the ratified broad bands); a per-family vocabulary gate is the tracked follow-up. |
| `tools/pdv_main_quest_full_coverage_audit.mjs` | Fail-closed static/generated-readback gate for the 2026-07-15 main-quest contract: 45 identities x 25 exact stages, 951 T11 rows, 1978-cell compiled matrix, strict integer stages, no `echo`, exact 17/11 Paarthurnax rosters, and indexed 134-watch registration. A PASS is not in-game route/display proof. |
| `tools/pdv_guide_bbcode.mjs` | Emits `dist/nexus-articles/*.bb` from the 10 race guides and hard-fails on surviving review tags, HTML comments, or non-ASCII -- the Nexus release gate. Run after ANY guide edit. |
| `tools/pdv_package_release.mjs` | Builds the `dist/` release zip from the live Anvil Devotion mod folder -- the ONLY sanctioned path to a public bundle (never hand-roll it; rc1 leaked an 876KB `.orig`). Gates on version, ANAM, and archive contents; those gates are NARROWER than `pdv_verify.mjs`, so a green package run is not a green verify run. |
| `tools/pdv_release_proof_refresh.mjs` | Re-derives and gates the committed houseCARL release proof against the active Anvil profile. `--capture` writes a gitignored review candidate; confirmed `--refresh` promotes it; release preflight runs `--check` and fails closed if the backend is unavailable or proof drifted. |
| `tools/pdv_file_semantics_audit.mjs` | Enforces the current file compare/hash inventory: normalized text versus exact bytes, fixed LF/CRLF writers, and paired `.gitattributes` pins. Run after changing any file freshness, generated-text, checksum, cache-key, snapshot, or packaging comparison. |
| `tools/pdv_substrate_pacing_audit.mjs` | Strict source/contract audit for the six paced substrates: one +4 devotional credit per 06:00 day, timing maths, authentic-route ownership, curse exceptions, decay, and player-copy exclusions |
| `tools/pdv_broad_pantheon_audit.mjs` | Strict source/contract audit for Imperial, Nord Old Ways, and Nord Nine Divines pools: signed logical-event aggregation, active-baseline gating, grace/decay, migration, and T2 patron transition |
| `tools/pdv_pantheon_substrate_runtime_evidence_check.mjs` | Fail-closed runtime/manual evidence checker for the 12 pantheon/substrate co-test cards; a static pass never closes an evidence bucket, and rotating Papyrus/temporary captures need an exact retained reference in the committed pantheon co-test evidence store |
| `tools/pdv_patch.mjs` | Offline patcher for classification/distribution manifests and generated patch review/live artifacts |
| `tools/pdv_content_verify.mjs` | Read-only verifier for the race/Daedric content manifests plus Phase 20 roster coverage (ASCII, budgets, slot IDs, voice, full roster gate) |
| `tools/pdv_formal_offer_check.mjs` | Read-only verifier for the formal-offer scale-out spec, live manager eligibility/source flow, no-offer race exclusions, quiet-emergence cues, and delegated ESP/property readback |
| `tools/pdv_prisma_parity_unitd_check.mjs` | Read-only verifier for Prisma parity Unit D journal/toast wiring, carryover award funnel, director resolver preservation, and Daedric commitment-title readback |
| `tools/pdv_prisma_to_oneoh_audit.mjs` | Read-only roll-up verifier for Prisma-to-1.0 wiring; checks current producer callsites, source/live parity, repo/live Prisma UI parity, and adversarial negative fixtures before runtime smoke |
| `tools/pdv_deity_stance_parity.mjs` | Cross-checks the three sources of a deity stance -- the matrix JSON `stance.<Race>.<Deity>` (wins at runtime), the ESP `Stance_<Race>` VMAD property (fallback), and `IsDashboardDeityInOriginRoster`. Fails on ESP/JSON drift and on an off-roster deity reading NATIVE; warns where the JSON value cannot be expressed in the record at all. Derives rosters and canonical names from source rather than pinning them |
| `tools/pdv_patch_source_lock.mjs` | Gates canonical optional-adapter PSC/PEX pairs by normalized source hash and exact bytecode hash; `--relock` accepts reviewed bytecode after recompiling |
| `tools/pdv_quest_reaction_build.mjs` | Single V3 Quest Reaction build entrypoint for deterministic catalogs, the required-catalog/five-adapter FOMOD tree, exact receipts, installer simulation, and verified normalized archives |
| `tools/pdv_quest_reaction_semantic_adapter_audit.mjs` | Verifies the V3 AFDI observer keeps its baseline/backoff/poll-retirement lifecycle, submits exactly one catalog-owned semantic event per routed destruction, and leaves no Manager batch or devotional-outcome ownership in adapter code |
| `tools/lib/pdv_daedric_effect_model.mjs` | Explicit all-Prince boon/price model and independently tunable ActorValue-family bands; exceptional packets such as Mora Champion live in the Prince declaration rather than editor-ID override maps |
| `tools/pdv_generate_daedric_contract.mjs` | Generates the all-Prince Daedric record contract and non-Hircine path scripts from the content manifest, race/Prince matrix, and explicit effect model. **Report-only by default**; `--self-test` proves model invariants and zero reviewed-contract drift, while writes remain explicit through `--write-contract` or `--scaffold-scripts --source-dir <path>` |
| `tools/pdv_prisma_ui_audit.mjs` | Read-only Prisma UI policy audit; blocks gameplay scripts from opening focused/blocking Prisma UI without default-off/player-owned gating and fails stale Book-of-Days manager/MCM bytecode |
| `tools/pdv_v3_prisma_extraction_audit.mjs` | Read-only V3 PRISMA extraction gate for the 114-function presenter, typed ORIGIN presentation seam, module references, and 48-public/66-private contract |
| `tools/pdv_v3_debug_extraction_audit.mjs` | Read-only V3 DEBUG extraction gate for the 136-function harness, retained manager dispatcher/registers, typed MCM double-hop, zero Global surface, and 111-public/25-private contract |
| `tools/pdv_prisma_toast_fallback_audit.mjs` | Read-only Prisma-first toast fallback audit; fails raw player-facing top-left-only gameplay notices, checks stable toast helpers use shared fallback behavior, and hardens the P2 book route from `OnBookRead` through `ShowP2BookNotice` |
| `tools/pdv_phase2_reward_readback_audit.mjs` | Read-only Phase 2 static closeout audit for reward records, manager spell/deity properties, FLST/SEQ/SGE state, Green Pact static layer plus the plant-food baseline, capstone records, and real-hook classification |
| `tools/pdv_dislike_consequence_audit.mjs` | Read-only strict audit for dislike-consequence V2; checks the shared-domain spec, 32-deity CSV threshold/domain coverage, manager/router source gates, and live ESP readback |
| `tools/pdv_phase20_base_wiring_audit.mjs` | Read-only all-race Phase 20 base wiring audit for P2 receiver contracts, approved source-fill counts, static quest-stage route contracts, and T1 reward manager source references |
| `tools/pdv_phase20_runtime_check.mjs` | Read-only Papyrus log checker for the Phase 20 QASmoke proof route markers; route proof only, not a replacement for Survey/status immersion checks |
| `tools/pdv_daedric_runtime_check.mjs` | Read-only Papyrus log checker for Daedric route markers from QASmoke, MCM, or exact organic quest-stage senders; route proof only, not a replacement for Active Effects, MessageBox, Prisma, curse, save/load, or stack checks |
| `tools/pdv_daedric_ingame_packet.mjs` | Read-only Daedric tester packet generator; writes `PDV_DaedricInGameSmokePacket.md` from the all-Prince contract |
| `tools/pdv_daedric_test_readiness.mjs` | Read-only Daedric in-game preflight; checks the contract, packet freshness, live PEX freshness, active Devotion plugin, ESP/SEQ, Papyrus log path, process state, and optional deep readback/self-test |
| `tools/pdv_daedric_evidence_intake.mjs` | Structured Daedric runtime/manual evidence intake helper; initializes and updates `PDV_DaedricRuntimeEvidenceLedger.json` after in-game proof and can auto-record route slots from passing Daedric runtime-check logs |
| `tools/pdv_daedric_beta_gate.mjs` | Read-only Daedric beta-display gate; fails closed until all Prince runtime/display evidence slots pass |
| `tools/pdv_extract_vanilla_gameplay_refs.mjs` | Read-only vanilla/DLC gameplay reference extractor |
| `tools/pdv_extract_quest_stage_readback.mjs` | Read-only vanilla/DLC quest-stage readback helper that writes `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv` for Phase 20 exact-source review |
| `tools/pdv_skyrim_refs_bridge.mjs` | Read-only bridge for querying the neutral `SkyrimGamePlayReferences` repo |
| `tools/pdv_quest_matrix_compile.mjs` | Quest-reaction matrix compiler that emits live PapyrusUtil JSON from the frozen matrix/faucet/readback/stance inputs |
| `tools/pdv_quest_tranche_merge.mjs` | Source-tranche merger for `PDV_QuestReactionMatrix_Full.csv`; edit tranches, not Full |
| `tools/pdv_deity_signal_remap_adversary_check.mjs` | Static guard for the 2026-07 deity signal remap: shrine cap, Syrabane display, offer eligibility, likes/dislikes versioning, quest rows, and exclusions |
| `tools/pdv_signal_floor_smoke_gate.mjs` | Backend/static smoke gate for the 2026-07-09 signal-floor handoff; checks scenario manifest, source CSVs, live PapyrusUtil JSON, manager/MCM harness tokens, and optional Papyrus log markers, then writes `PDV_SignalFloorSmokeLedger.{md,json}` |
| `references/authoring/PDV_SignalFloorSmokeScenarios_2026-07-09.json` | Scenario manifest for the signal-floor smoke set: representative quest-stage fan-out, LD v15, Green Way, crypt-clear, Paarthurnax kill/spare, and borderline prove-or-drop rows |
| `references/authoring/PDV_SignalFloorSmokeLedger.md` | Generated signal-floor smoke result ledger; backend PASS can leave runtime marker/manual slots OPEN without promoting the slice to runtime proof |
| `references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md` | Single co-testing runbook for the remaining 1.0 smoke closeout; use it for machine preflight, signal-floor smoke cards, exact evidence capture, stop conditions, and remaining 1.0 evidence sinks |
| `native/DevotionPrismaBridge/` | C++ SKSE/Prisma bridge scaffold plus mirrored runtime Prisma panel assets |
| `references/PDV_Anvil_MO2_MCP_Intake.md` | Codex-facing intake for the Anvil MO2 MCP plugin and optional tool status |

---

## Required Tools

### Core (Install Before Anything Else)

| Tool | Version | Source | Notes |
|------|---------|--------|-------|
| **Skyrim Special Edition** | Latest Steam | Steam | Keep vanilla backup |
| **Creation Kit for SSE** | Latest | Steam (free DLC) | Do not update mid-project |
| **SKSE64** | Match your SSE version exactly | skse.silverlock.org | NOT from Nexus |
| **SkyUI** | 5.2SE | Nexus #12604 | Required for MCM |
| **Address Library for SKSE Plugins** | Match your SSE runtime | Nexus | Required by the PO3/Tweaks SKSE plugin chain |
| **powerofthree's Tweaks** | Match your SSE runtime | Nexus | Required by PO3 Papyrus Extender |
| **powerofthree's Papyrus Extender** | Match your SSE runtime | Nexus | Hard runtime dependency for v3 event hooks |
| **Mod Organizer 2** | 2.5.x | Nexus #6194 | Development environment manager |
| **SSEEdit (xEdit)** | 4.x | Nexus #164771 | Conflict checking |

### Scripting & Editing

| Tool | Purpose | Source |
|------|---------|--------|
| **VS Code** | Primary script editor | code.visualstudio.com |
| **Papyrus Extension for VS Code** | Syntax, autocomplete, compile | VS Code marketplace -- search "Papyrus" by joelday |
| **Notepad++** | Fallback text editor, log reading | notepad-plus-plus.org |
| **Git** | Version control (strongly recommended) | git-scm.com |

### Optional but Useful

| Tool | Purpose |
|------|---------|
| **NifSkope** | Mesh inspection if adding new objects |
| **Cathedral Assets Optimizer** | Asset optimization before release |
| **FNIS or Nemesis** | Only if adding custom animations |

---

## Mod Organizer 2 Configuration

### Profile Structure

The active dev profile is **Devotion Dev** inside the Anvil MO2 instance. Source and compiled scripts live at `D:\Wabbajack\modlists\Anvil\mods\Devotion\` and are managed by MO2 (`meta.ini` present).

```
[Profile: Devotion Dev]      <- work here (active; inside Anvil MO2 instance)
[Profile: PDV_Testing]       <- optional clean ship-verification profile (create before public release)
[Your normal play profile]   <- never touched by this project
```

### Development Load Order (Minimum)

```
Skyrim.esm
Update.esm
Dawnguard.esm
HearthFires.esm
Dragonborn.esm
---
SKSE
SkyUI.esp
Address Library for SKSE Plugins
powerofthree's Tweaks
powerofthree's Papyrus Extender
---
Devotion.esp    <- your core file
PDV_Nord.esp                    <- race module (add as built)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

**Rule:** Keep the Devotion Dev profile minimal -- Skyrim/DLC, SKSE, SkyUI, Address Library, powerofthree's Tweaks, powerofthree's Papyrus Extender, and PDV plugins only. Every additional mod is a potential false positive when debugging. The Anvil instance hosts a full modlist; Devotion Dev is the curated subset for PDV work.

### MO2 Settings to Configure

- **Mod Organizer -> Settings -> Nexus:** Not needed for development
- **Mod Organizer -> Settings -> Plugins:** Ensure BSA extraction is ON for vanilla assets
- **Right-click game executable -> Edit:** Add `-forcesteamloader` argument if CK fails to launch

---

## Creation Kit Configuration

### INI Settings

Navigate to: `Documents\My Games\Skyrim Special Edition\CreationKit.ini`
Add or confirm these values:

```ini
[Papyrus]
sScriptSourceFolder = .\Data\Scripts\Source
sAdditionalImports = $(source)
bEnableLogging = 1
bEnableTrace = 1
bLoadDebugInformation = 1

[MESSAGES]
bBlockMessageBoxes = 0
```

Navigate to: `Documents\My Games\Skyrim Special Edition\CreationKitPrefs.ini`
Add or confirm:

```ini
[General]
bAllowMultipleMasterLoads = 1
```

### CK Launch Arguments (set in MO2)

```
-editor
```

No other arguments needed for standard development.

---

## Build Toolchain

PDV now has a local compiler wrapper for terminal/Codex work: `tools\pdv_compile.mjs`. It spawns the real Anvil SSE `.NET` CLI `PapyrusCompiler.exe` directly with canonical args:

```text
PapyrusCompiler.exe <script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>
```

The wrapper outputs `.pex` files directly into the MO2-managed `Devotion\Scripts` folder. It does not call `ScriptCompile.bat`, PowerShell, or Creation Kit's compile menu.

Creation Kit's built-in Papyrus compiler (Ctrl+F7 in the CK script editor) remains valid when working interactively in CK. For scripted/terminal work, prefer `node .\tools\pdv_compile.mjs` from the docs workspace because it checks stale scripts, treats warnings as failures, and runs the verifier after successful compiles. VS Code with the Papyrus extension provides editor features (syntax, intellisense, hover, format) but does not drive compilation.

> `compile.ps1` and `skyrimse.ppj` exist in the mod folder as legacy files from an earlier toolchain. Do not use them -- defer to `tools\pdv_compile.mjs` for terminal compiles or the CK compiler for interactive CK work.
>
> `ScriptCompile.bat` in the `Papyrus Compiler` folder is a stale Bethesda development artifact that points at internal `C:\Projects\TESV\Build...` paths. Treat it as an example invocation, not a working wrapper.
>
> **2026-05-12 update:** The active CKPE/MO2 setup now outputs directly into the `Devotion` mod. Source files live in `Devotion\Scripts\Source\`; compiled `.pex` files should land in `Devotion\Scripts\`. If CK cannot see a newly added script, compile that script with `tools\pdv_compile.mjs --script <ScriptName>` using the known SSE import chain documented in `AGENTS.md`.

### Build files (in the mod folder)

| File | Role |
|---|---|
| `SkyrimSE.code-workspace` | VS Code workspace (rooted at the mod folder) |
| `compile.ps1` | Legacy -- do not use |
| `skyrimse.ppj` | Legacy -- do not use |
| `meta.ini` | MO2 mod metadata -- do not edit manually |

### Native Prisma bridge scaffold

Prisma UI is a C++ SKSE API, not a Papyrus API. PDV's bridge scaffold lives in:

```text
C:\Users\Admin\Documents\Devotion Mod Project\native\DevotionPrismaBridge\
```

The live Devotion mod now carries the Papyrus declaration and first Prisma view assets:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_PrismaBridge.psc
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_PrismaBridge.pex
D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\index.html
D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\styles.css
D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js
D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\DevotionPrismaBridge.dll
D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\DevotionPrismaBridge.pdb
```

Papyrus surface:

```papyrus
Bool Function IsAvailable() Global Native
Bool Function OpenDevotionPanel() Global Native
Bool Function CloseDevotionPanel() Global Native
Bool Function ToggleDevotionPanel() Global Native
Bool Function SendJson(String payload) Global Native
Bool Function SendOverlayJson(String payload) Global Native
```

`PDV_PrismaBridge.psc` compiled cleanly on 2026-05-18. The native DLL also
builds cleanly with Visual Studio Build Tools 2022 installed at `C:\BuildTools`
and portable xmake at `C:\Users\Admin\Documents\xmake-v3.0.8-win64\`. Build from
`native\DevotionPrismaBridge\` with:

```powershell
$env:PDV_MOD_PATH = "D:\Wabbajack\modlists\Anvil\mods\Devotion"
& "C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe" f -y -m releasedbg
& "C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe" -y
```

The live DLL was verified on 2026-05-18 with matching SHA256 between build output
and `Devotion\SKSE\Plugins`, and `dumpbin /exports` shows the expected
`SKSEPlugin_Load`, `SKSEPlugin_Query`, and `SKSEPlugin_Version` exports. The
current Anvil MCP VFS can cache file listings, so restart or refresh the MCP
server if newly copied SKSE files do not immediately appear through `mo2_*`
tools.

The first player-facing Prisma UX prototype was mirrored into the live mod on
2026-05-19. It keeps the native bridge contract unchanged (`ReceivePDVJson`) and
renders a devotional status panel with Patron, Today, and Debug tabs. Payloads
may also include `toast`, `toasts`, or `mode: "toast"` for short-lived feedback
such as devotional acknowledgements, dawn reflections, and neglect warnings.
Marks are symbol-driven (`symbol: "kyne"`, `symbol: "dawn"`,
`symbol: "journal"`, etc.) rather than letter-initial driven. Use
`SendJson(payload)` for focused panel payloads and `SendOverlayJson(payload)`
for transient overlay payloads such as real event toasts.

### Project layout

```
D:\Wabbajack\modlists\Anvil\mods\Devotion\
  PrismaUI\
    views\
      Devotion\
        index.html
        styles.css
        app.js
  Scripts\
    PDV__MainQuest.pex
    PDV_Origin.pex
    PDV__ManagerQuest.pex
    PDV_ActionRouter.pex
    PDV__SM_KillActor.pex
    PDV_DeityBase.pex
    PDV_Deity_Kyne.pex
    PDV_Deity_Talos.pex
    PDV_Deity_AuriEl.pex
    PDV_EventTypes.pex
    PDV_EventBus.pex
    PDV_SurveyDevotionEffect.pex
    PDV_PrismaBridge.pex
    Source\
      PDV__MainQuest.psc
      PDV_Origin.psc
      PDV__ManagerQuest.psc
      PDV_ActionRouter.psc
      PDV__SM_KillActor.psc
      PDV_DeityBase.psc
      PDV_Deity_Kyne.psc
      PDV_Deity_Talos.psc
      PDV_Deity_AuriEl.psc
      PDV_EventTypes.psc
      PDV_EventBus.psc
      PDV_SurveyDevotionEffect.psc
      PDV_MCM.psc
      PDV_PrismaBridge.psc
  Devotion.esp
  compile.ps1                 (legacy, ignore)
  skyrimse.ppj                (legacy, ignore)
  SkyrimSE.code-workspace
  meta.ini
```

### Compile workflow

1. Launch `D:\Wabbajack\modlists\Anvil\Anvil.exe`, select `Creation Kit` in MO2, and press `Run` (required - CK needs MO2's virtual filesystem and output routing)
2. Edit source scripts under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`
3. Run `node .\tools\pdv_compile.mjs` from `C:\Users\Admin\Documents\Devotion Mod Project`
4. Use `node .\tools\pdv_compile.mjs --script <ScriptName>` for targeted compiles, or `node .\tools\pdv_compile.mjs --all` for a full active-script rebuild
5. Wire properties/records in CK when needed, then save the ESP
6. Run `node .\tools\pdv_verify.mjs` after CK/ESP/SEQ/MO2 profile changes
7. Regenerate SEQ after adding or changing dialogue before in-game testing

### PDV local toolchain workflow

Run from `C:\Users\Admin\Documents\Devotion Mod Project`:

```text
node .\tools\pdv_compile.mjs
node .\tools\pdv_compile.mjs --script PDV_ActionRouter
node .\tools\pdv_compile.mjs --all
node .\tools\pdv_compile.mjs --list
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_verify.mjs --strict-phase12
node .\tools\pdv_verify.mjs --strict-phase12 --json
node .\tools\pdv_verify.mjs --strict-phase18
node .\tools\pdv_verify.mjs --strict-nord
node .\tools\pdv_verify.mjs --strict-phase20-roster
node .\tools\pdv_verify.mjs --strict-phase20-altmer
node .\tools\pdv_verify.mjs --strict-phase20-race-costing
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_phase20_runtime_check.mjs --list
node .\tools\pdv_phase20_runtime_check.mjs --race all
node .\tools\pdv_verify.mjs --strict-phase3
node .\tools\pdv_verify.mjs --strict-preflight
node .\tools\pdv_verify.mjs --strict-skeleton
node .\tools\pdv_verify.mjs --strict-pattern-proving
node .\tools\pdv_verify.mjs --strict-phase7
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_content_verify.mjs --json
node .\tools\pdv_content_verify.mjs --strict-phase20-roster
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence
node .\tools\pdv_patch.mjs validate
node .\tools\pdv_patch.mjs plan
node .\tools\pdv_patch.mjs plan --json
node .\tools\pdv_patch.mjs build --dry-run --json
node .\tools\pdv_patch.mjs build --dry-run --allow-candidates --json
node .\tools\pdv_patch.mjs build
node .\tools\pdv_generate_daedric_contract.mjs
node .\tools\pdv_extract_vanilla_gameplay_refs.mjs
node .\tools\pdv_skyrim_refs_bridge.mjs status
node .\tools\pdv_skyrim_refs_bridge.mjs tables
```

For Book-of-Days or Prisma payload work, treat `pdv_prisma_ui_audit.mjs` and
`pdv_book_of_days_audit.mjs` as bytecode freshness gates, not just UI/source
scans. They fail if the live manager/MCM PEX files are stale against the
journal payload contract, including the repeated failure class where
`PDV__ManagerQuest` was recompiled after a signature/open-close change but
`PDV_MCM.pex` still contains the old hotkey call.

For Pantheon Parity and Substrate Pacing work, run the two authority audits
(`pdv_substrate_pacing_audit.mjs` and `pdv_broad_pantheon_audit.mjs`), direct
houseCARL readbacks (`pdv_pantheon_record_readback.mjs`,
`pdv_pantheon_presentation_readback.mjs`,
`pdv_active_effect_naming_audit.mjs`, and `pdv_housecarl_p2_readback.mjs
--check-all`), the normal verifier, and the Prisma audit before opening Skyrim.
Then run `pdv_pantheon_substrate_runtime_evidence_check.mjs`: it is expected to
fail while the PS-A1 through PS-A12 evidence cards are open. Use a fresh
main-menu `coc qasmoke` save after deployment; a static/readback pass does not
prove old save instances, route delivery, or player-visible behavior.

PS-A11 is the one controlled exception to a real-time wait: `GetDevotionalDay()`
reads `Utility.GetCurrentGameTime()`, so `set GameDaysPassed ...` cannot test
its catch-up path. After one real positive pool fold, zero scratch, and
suppression of that pool, use Pacing's throwaway-save-only `PS-A11 catch-up`
control. It calls the production `ProcessBroadPantheonThroughDay(...)` through
five days after the recorded gain without mutating game time; the expected
result is two grace days then three `-0.1` ticks. Save/reload and invoke the
same control again to prove idempotence. This controlled route does not fill
organic-route evidence.

For Daedric Prince CAT-6 work, first run `tools\pdv_generate_daedric_contract.mjs --self-test`, then regenerate `references\authoring\PDV_DaedricPrinceRecordContracts.json` with `--write-contract` before authoring. The explicit effect authority is `tools\lib\pdv_daedric_effect_model.mjs`; its small interface supplies all tier packets while the manifest owns player text and the matrix owns race posture. A bare run is report-only and writes nothing; `--write-contract` refuses any change to the reviewed JSON unless `--force` deliberately accepts it. Script scaffolding is a separate opt-in (`--scaffold-scripts --source-dir <path>`) so regenerating a contract can never invalidate a build's bytecode as a side effect. The generated JSON is the record-authoring contract; author the ESP packet from it with the `housecarl_*` MCP tools and verify each write with a `housecarl_read_record` readback. `pdv_verify` additionally fails unless all 96 contracted spells and all 97 effect references resolve and link in the live ESP; its dedicated price gate separately enforces all 48 detrimental stored magnitudes. Boon magnitude reconciliation belongs to the owner-reviewed #37 balance pass, not this structural gate. The packet covers all sixteen Skyrim-present Princes: per-Prince records, base/concrete `PDV_DaedricPathBase` VMAD wiring, stigma globals, arrays, `PDV_FLST_DaedricPaths_All` membership, manager FormList wiring, the QASmoke proof sender ACTI/REFR packet, and all sixteen exact organic quest-stage source FormLists. This is still a record/readback gate only; controlled in-game display proof and live-source proof are required before calling a Prince beta-display ready.

For design-first thin-Prince artifact faucets, keep the scope to low-risk equip events unless a richer artifact-use support path has been designed. The artifact faucet FormLists for Molag Bal, Hircine, Meridia, Sheogorath, Mehrunes Dagon, and Nocturnal are authored and read back with the `housecarl_*` MCP tools; `tools\pdv_quest_matrix_compile.mjs --check` must report the matching Part D faucet count before live JSON write. This is machine/readback proof only until in-game artifact-equip smoke and wrong-origin silence are captured.

The compiler spawns `PapyrusCompiler.exe` directly with the project import chain, compiles known scripts whose `.pex` output is missing or older than source, treats Papyrus warnings as failures, and runs the verifier after successful compiles unless `--skip-verify` is used. `references\authoring\PDV_ReleasePayload.manifest.json` is the single shipped-script inventory for default, `--all`, and `--list`; do not add a second active/optional list in the compiler. Default and `--all` compilation fail if any manifested source is absent instead of silently shrinking the target set. `node .\tools\pdv_compile_inventory_audit.mjs` verifies exact manifest/compiler/source agreement against the compiler's resolved `PDV_COMPILE_SOURCE_ROOT` (or its normal Anvil source root) without building bytecode. The import chain includes the local `powerofthree's Papyrus Extender\Source\scripts` headers so alias-side shout ingress compiles against `PO3_Events_Alias`. `--strict-phase3`, `--strict-preflight`, `--strict-skeleton`, `--strict-pattern-proving`, `--strict-phase7`, `--strict-phase8`, `--strict-phase9`, `--strict-phase10`, `--strict-khajiit`, `--strict-commitment`, `--strict-neglect-decay`, `--strict-phase11`, `--strict-phase12`, `--strict-phase13`, `--strict-phase14`, `--strict-phase15`, `--strict-phase16`, `--strict-phase17`, `--strict-phase18`, `--strict-phase19`, `--strict-phase20-roster`, `--strict-phase20-altmer`, `--strict-phase20-race-costing`, and `--strict-nord` all pass through to the verifier. The emitted compiler command uses the short canonical flags: `-f=<flags>`, `-i=<source-dirs>`, and `-o=<output-dir>`.

The verifier is read-only. It checks expected Anvil paths, reads `Devotion.esp` through the Anvil MO2 MCP Mutagen bridge, validates baseline framework records and VMAD properties, checks script source/pex freshness, reports SEQ drift, confirms the active MO2 profile/load order, and looks for CK output shadow files. It also source-gates the generated small-signal tables in the deployed manager: `LIKES_DISLIKES_VERSION = 8`, `PRINCE_LD_VERSION = 3`, exact CSV-generated `LoadRowsForDeity` coverage for 32 deities / 315 rows, exact `LoadPrinceRowsForPath` coverage for 16 Prince paths / 160 rows, and `GetLikesDislikesEventTypes` coverage for all 31 deity CSV event IDs. V3 Preflight source/pex readiness is covered; the framework-owned CK/xEdit records (`PDV_GLO_PatronState`, `PDV_EventTypes`, `PDV_EventBus`) report as INFO in default mode, and `--strict-preflight` promotes unresolved Preflight gaps to FAIL for gate-close runs. V3 Structural Skeleton now covers the full dev-only scaffold contract: track records/globals/FormLists, substrate/sacred-place/Daedric/curse records, required VMAD wiring, dev FormList membership, MCM scaffold properties, and the Hircine-not-in-`PDV_FLST_AllDeities` contradiction check. Array readback is verifier-visible when arrays exist, but absent manual arrays remain INFO in default mode. `--strict-phase7` adds the Nord/Imperial-first signal gate: PO3 shout registration on `PDV_PlayerEvents`, the shout event constant, EventBus shout/shrine routes, manager shout/shrine helpers, deity-side shout anti-farm helpers, live `PDV_Player` alias + `PDV_PlayerEvents` property readback on `PDV__ManagerQuest`, and readback for the actual hidden Talos shrine reference named in `references\authoring\PDV_Phase7SignalReceivers.manifest.json`. `--strict-phase8` adds the ConcordatStanding record/property and threshold-array gate, Talos track-multiplier wiring checks, manager runtime-wiring fallback detection, reused Phase 7 ingress source checks, and the MCM/source contract for committed state, pending state, extreme gate, and Talos effective multiplier readback. `--strict-phase9` adds Bosmer path-state arrays/properties, Y'ffre/Zen/Baan Dar deity path eligibility, Bosmer manager/message wiring, threshold/`IsAedric` balancing readback for the Bosmer deity records, and ACTI proof-surface base record readback for route IDs `41-45`. `--strict-phase10` adds Dunmer ancestor substrate graduation checks for source contract, substrate record/scripts/properties, manager property, the two reused Dunmer proof ACTI records, and distinct portable/private shrine cooldown keys. `--strict-khajiit` checks the focused-emphasis source contract, `PDV_GLO_KhajiitFocusedEmphasis`, and manager wiring. `--strict-commitment` checks the Kyne commitment source/MCM contract and existing manager/deity properties. `--strict-neglect-decay` remains a legacy combined gate for the Kyne neglect/decay source contract, `PDV_MGEF_Neglect_Kyne`, `PDV_SPEL_Neglect_Kyne`, and manager spell-property wiring; it now also enables the standalone Phase 16 and Phase 17 checks. `--strict-phase11` verifies the Arngeir/Kynareth privilege pilot manifest; live dialogue readback only runs when that manifest is explicitly marked `live-dialogue-authored`. `--strict-phase12` adds contextual-favor lane/family presence checks, manager wiring/readback assertions for favor records and state keys, and explicit readback for `PDV_State_NordPantheonBaseline` as a `QUST` with `PDV_StateTrack` attached. `--strict-phase13` checks the Hircine/Nord Daedric packet and Hircine-not-in-`PDV_FLST_AllDeities` contract. `--strict-phase14` checks the generic commitment source surface plus the live Phase 14 manifest. `--strict-phase15` checks the shared curse-transition surface plus the live Phase 15 manifest. `--strict-phase16` checks the generic neglect-selection surface plus the live Phase 16 manifest. `--strict-phase17` checks the standalone decay/balancing manifest, locked decay and gain constants, active-patron passive-decay skip, grace, once-per-day guard, broad-worship multiplier, persistent floor helper, vampire `IsAedric` floor bypass, tier-down hysteresis, Orc post-clamp gain multiplier helper, and debug proof surface. `--strict-phase18` / `--strict-nord` checks the Survey Devotion spell/effect records, manager/MCM source contracts including grant-only handling plus exact `Skyrim.esm:025BEE` Voice-slot readback for `Survey Devotion`, Nord curse-message records, manager/effect VMAD wiring, and the four CK-authored Nord dialogue contracts in `references\authoring\PDV_Phase18StatusNord.manifest.json`; live dialogue readback now runs because that manifest is marked `live-dialogue-authored`. `--strict-phase20-roster` checks `references\authoring\PDV_DeityCoverageMatrix.json` against the Phase 4 stance and Daedric matrices, fails missing race coverage, excludes Jyggalag unless adopted later, and fails dev-only language for locked gods or Skyrim-present Princes. The default verifier also checks `PDV_MedallionRoster.manifest.json`: all ten race rosters must stay visible, pending entries without live deity records must carry disabled reasons, live records must read back for honest display, and the manager source must block direct medallion commitment. `--strict-phase20-altmer` checks the Altmer implementation manifest, decision sources, crisis enum, drafted content rows, rejected-hook families, immersion proof, planned verifier contract, runtime proof case coverage, and source-scaffolded manager/EventBus/EventTypes/receiver hooks once the manifest status is `source-scaffolded` or later; `PDV_State_AltmerCrisis` record readback begins when the status moves to `record-wired`, record-wired Altmer favor families must have `KYWD` / `MGEF` / `SPEL` records, spell-effect membership, effect keyword, and manager spell-property wiring, and record-wired Altmer trigger surfaces must have ACTI records with `PDV_EventSignalActivator`, route IDs, origin gates, source IDs, and daily keys; `--strict-phase20-race-costing` checks all Phase 20 race implementation-costing manifests for schema, sources, state surfaces, enum contracts, required content rows, rejected hooks, immersion proof, verifier gates, first slices, and runtime proof cases; `--strict-phase21-roster` remains accepted as a temporary alias. The verifier also reads back `PDV_PreflightRouterServicesOverlay.esp` when that reversible canary exists.

Altmer-specific note: when `PDV_Phase20AltmerImplementationCosting.manifest.json`
marks curse/exile rows as `record-wired`, `--strict-phase20-altmer` also
requires matching `MESG` records plus manager message-property wiring.

Argonian-specific note: when `PDV_Phase20ArgonianImplementationCosting.manifest.json`
moves beyond `costed-not-built`, `--strict-phase20-race-costing` checks the
Argonian source scaffold. At `record-wired`, it also reads back
`PDV_Substrate_ArgonianHist`, `PDV_State_ArgonianHistPosture`, manager
properties, and the four Argonian proof ACTI base records. At
`proof-placement-gate-live`, it also reads back the four `PDV_REFR_Argonian*`
QASmoke proof references and their base links.

Orc-specific note: when `PDV_Phase20OrcImplementationCosting.manifest.json`
moves beyond `costed-not-built`, `--strict-phase20-race-costing` checks the
Orc life-mode source scaffold. At `record-wired`, it also reads back
`PDV_StateTrack_OrcLifeMode`, `PDV_GLO_OrcLifeMode`, manager properties, and
the eight Orc proof ACTI base records. At `proof-placement-gate-live`, it also
reads back the eight `PDV_REFR_Orc*` QASmoke proof references and their base
links.

Redguard-specific note: when `PDV_Phase20RedguardImplementationCosting.manifest.json`
moves beyond `costed-not-built`, `--strict-phase20-race-costing` checks the
Redguard sect source scaffold. At `record-wired`, it also reads back
`PDV_StateTrack_RedguardSect`, `PDV_GLO_RedguardSect`, manager properties, and
the four Redguard proof ACTI base records. At `proof-placement-gate-live`, it
also reads back the four `PDV_REFR_Redguard*` QASmoke proof references and
their base links.

Bosmer-specific note: when `PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json`
moves beyond `costed-not-built`, `--strict-phase20-race-costing` checks the
Bosmer favor-parity source scaffold. At `record-wired`, it also reads back the
eight Bosmer proof ACTI base records for route IDs `100-107`. At
`proof-placement-gate-live`, it also reads back the eight `PDV_REFR_Bosmer*`
QASmoke proof references and their base links.

Khajiit-specific note: when `PDV_Phase20KhajiitImplementationCosting.manifest.json`
moves beyond `costed-not-built`, `--strict-phase20-race-costing` checks the
Khajiit lunar/focus source scaffold. At `record-wired`, it also reads back
`PDV_Substrate_KhajiitLunar`, `PDV_GLO_KhajiitFocusedEmphasis`, manager
properties, and the six Khajiit proof ACTI base records. At
`proof-placement-gate-live`, it also reads back the six `PDV_REFR_Khajiit*`
QASmoke proof references and their base links.

`tools\sync-devotion-to-live.ps1` is a guarded copy helper for repo-tracked Prisma and StorageUtil assets, not a bootstrap or repair tool. It requires an existing healthy `D:\Wabbajack\modlists\Anvil\mods\Devotion` folder with `Devotion.esp`, refuses empty or damaged live roots, creates `generated\live-devotion-backups\pre-sync-*` before non-dry-run writes, and asserts that `Devotion.esp` still exists after sync. It must not copy untracked scratch Papyrus into live by default. If the live mod folder is missing or empty, restore from `generated\live-devotion-snapshot\...` or a live backup first; never run sync as the first creator of the main mod folder.

`tools\pdv_phase20_base_wiring_audit.mjs` is a read-only all-race base wiring audit for Phase 20. It checks the P2 receiver manifest, reward contract, and live `PDV_PlayerEvents.psc`, `PDV_EventBus.psc`, and `PDV__ManagerQuest.psc` sources for receiver property coverage, route function presence, approved source-fill counts, static quest-stage route contracts, and T1 reward manager references. It is a scaffold/readback gate, not in-game runtime proof.

`tools\pdv_phase20_runtime_check.mjs` is the Phase 20 QASmoke Papyrus log checker. Use it after in-game activation of the current 34 proof references to confirm Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer EventBus route markers. `--strict-manager` can require optional manager traces for counted closeout, but this remains route-marker proof only; `references\authoring\PDV_Phase20_QASmokeRuntimeProof_Runbook.md` owns the required Survey/status, immersion-feel, negative-hook, anti-farm, and final world-placement boundary.

`tools\pdv_daedric_runtime_check.mjs` is the Daedric Papyrus log checker. Use it after in-game activation of the sixteen `PDV_REFR_Daedric_<Prince>_LiveSender_QASmoke` refs, the MCM sender controls, the exact organic quest-stage senders, and `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke` to confirm route-200 Prince sender markers and the route-201 generic silence marker. `--strict-manager` also requires the manager traces emitted at debug level 2. Use `--source qasmoke` for physical QASmoke sender proof, `--source mcm` for MCM sender/sweep proof, and `--source organic` for exact PO3 quest-stage sender proof; `--source organic` requires the exact `eventbus_200_po3_queststage_daedric_*` marker so a controlled sender cannot satisfy live-source proof by accident. This is route-marker proof only; Active Effects, MessageBox summaries, Prisma display, curse no-double-fire, save/load, and stack legibility remain runbook/manual proof.

`tools\pdv_daedric_ingame_packet.mjs --write` regenerates
`references\authoring\PDV_DaedricInGameSmokePacket.md`, a compact tester packet
for the current all-Prince Daedric contract. It includes MCM sweep instructions,
QASmoke activator names and EditorIDs, `help` / `player.placeatme` fallback
commands, exact organic `setstage` routes, and matching runtime-check commands.
It is read-only and does not inspect or write the ESP.

`tools\pdv_daedric_test_readiness.mjs --deep` is the final repo-side preflight
before launching Skyrim for Daedric testing. It checks the all-Prince contract,
generated smoke packet, live `PDV_PlayerEvents` and `PDV_MCM` PEX freshness,
`Devotion Dev` plugin activation, framework ESP/SEQ presence, Papyrus log path,
and Skyrim/CK process state. `--deep` also runs the Daedric runtime checker
organic self-test. (Its historical `pdv-daedric-author --check` step is retired
with that helper -- use a direct `housecarl_read_record` readback of the Prince
records instead.)

`tools\pdv_daedric_evidence_intake.mjs` owns structured Daedric runtime/manual
proof intake. Run `--init` once, `--summary` to see open slots,
`--from-runtime-check --source mcm|qasmoke|organic` to auto-record route slots
after the matching Papyrus log proof passes, and `--record` for manual display
or feel observations to update
`references\authoring\PDV_DaedricRuntimeEvidenceLedger.json`. The ledger keeps
route proof separate from Active Effects, MessageBox, Prisma/notification,
save/load, stack legibility, manual feel, and Molag/Hircine curse no-double-fire
slots.

`tools\pdv_daedric_beta_gate.mjs` is the fail-closed Daedric beta-display gate.
Run it after recording the in-game evidence ledger. It reports each Prince's
missing, conditional, failed, or blocked slots and exits nonzero until all
sixteen Princes have passed required route/display/manual evidence, including
Molag/Hircine curse no-double-fire.

Phase 9 runtime proof is closed as of 2026-05-24. The proof pass covered all five then-live Bosmer proof activator routes (`41-45`), Living Story/Exchange/Bandit Road/Old Contract offers, popup accept paths, confirmation-rite state switching, Old Contract `PactBound` and `GreenPactCompliance` separation, forced reckoning `Renounce`, forced reckoning `Recommit`, and save/load persistence. Those Windhelm proof activators were retired on 2026-06-16 after visual cleanup; the route proof remains historical evidence, not permission to keep visible proof items in live spaces. The proof pass also fixed `PDV_StateTrack` evidence retention so three-day offers retain/count `LatestDay`, `PreviousDay`, and `ThirdDay`.

Phase 10 Dunmer substrate proof-graduation is closed as of 2026-05-24. The counted proof used the existing `PDV_ACTI_DunmerPrivateShrineSignal` route `31` and `PDV_ACTI_DunmerPortableShrineSignal` route `30` proof surfaces on a fresh Dunmer baseline. Baseline MCM/readback showed patron piety and deity roster values at `0.000000` and `DunmerAncestor=metric=0.000000; tier=0; prayers=0; homes=0`; private/home activation advanced only the substrate to `metric=8.000000; tier=1; prayers=0; homes=1`; after the daily gate cleared, portable activation advanced only the substrate to `metric=13.000000; tier=1; prayers=1; homes=1`. Save/load persistence passed and the strict gate stayed clean at `PASS=847, WARN=0, FAIL=0, INFO=28`. Runtime log follow-up found the expected vanilla script trace file at `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` (`18060` bytes, last written 2026-05-24 18:18:13), including `PDV_MCM` initialization and `[PDV] DunmerAncestor: DunmerAncestor tier 0 -> 1`. The earlier `C:\Users\Admin\Documents\My Games\Skyrim.INI\SKSE\PapyrusTweaks.log` hit is Papyrus Tweaks NG plugin logging, not the vanilla script trace surface. The next-packet helper corrected the live ACTI drift: portable now uses `PDV.Signal.DunmerPortableShrine.Activator`, private/home keeps `PDV.Signal.DunmerHome.Activator`, and `--strict-phase10` now fails if the two records share one once-per-day key again.

`tools\pdv_patch.mjs` is the Phase 19 offline classification/distribution patcher direction locked in v3. It reads tracked patch-rule manifests from `references\authoring\patch-rules\`, validates their schema strictly, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_verify.mjs`, resolves winning target records plus payload references, and emits deterministic `validate`, `plan`, and `build` output. `build` writes only a generated `PDV_ClassificationPatch.esp` in the Devotion mod folder through the existing Mutagen bridge patch-request contract; it must not overwrite `Devotion.esp` or mutate source masters/plugins. Default build output emits only `approved` rules. Use `--dry-run` for review, `--allow-candidates` only for explicit candidate test output, and `--allow-tooling-examples` only for deliberate proof/example experiments.

`tools\pdv_extract_vanilla_gameplay_refs.mjs` is a read-only reference-data helper. It scans local Anvil stock/cleaned base masters through the Mutagen bridge and refreshes generated CSVs under `references\vanilla-gameplay\extracted\`. Use those generated tables as implementation reference data for signal matrices, offline patcher rules, and compatibility planning; curated design decisions still belong in the `references\vanilla-gameplay\pdv-crosswalk\` tables.

`tools\pdv_extract_quest_stage_readback.mjs` is the Phase 20 read-only quest-stage follow-up. It reads `references\vanilla-gameplay\extracted\vanilla-quest-candidates.csv`, uses the local Mutagen bridge to read exact QUST stages/objectives/fragments/aliases from vanilla/DLC masters, and writes `references\vanilla-gameplay\extracted\vanilla-quest-stage-readback.csv`. Use it for dossier/review work only; it does not write ESP data or authorize `sourceFillEntries`.

`tools\pdv_quest_matrix_compile.mjs` remains the V1 compiler used by the public 1.5 line and the pure tuple compiler consumed by the V2 build. For V3, `tools\pdv_quest_reaction_build.mjs` consumes `references\authoring\PDV_QuestReactionCompatibility.manifest.json` plus the frozen core, 78 quest CSVs, AFDI semantic CSV, stage selectors, and locked adapter assets. It deterministically generates `PDV_QuestReactionCore.v2.json`, `PDV_QuestReactionPatches.v2.json`, the 31-file required-catalog/five-adapter FOMOD tree, and exact SHA-256 receipts. Use `node .\tools\pdv_quest_reaction_build.mjs --self-test --check --json`; use `--write` only when reviewed authoring inputs intentionally change. `--package --output <new.zip>` refuses overwrite, writes normalized deterministic ZIP metadata, extracts the archive, and exact-hash verifies all 31 members. The generated PapyrusUtil wire keeps top-level bucket names and values unchanged but lowercases every member name inside typed buckets; integer selector arrays belong in `intList`. Conflicting case-fold collisions fail generation. For an installed V3 profile, run `node .\tools\pdv_matrix_runtime_preflight.mjs --mo2 <root> --profile <name> --compat-mod <installed-compatibility-mod-name> --expected-core 353 --expected-official-sources 79 --json`; it uses the same wire validator as generation, rejects mixed-case/unaddressable catalogs before Skyrim starts, checks the winning core and official v2 catalogs, and does not inspect retired V1 channels. Slice 1C-B consumes the fixed core/official files plus sorted `QuestReactionExtensions/*.json`, with qualified quest and semantic keys only. Backend/static/compile/package, installed-profile admission, and combined Anvil gameplay are green; Authoria installer/support acceptance remains open.

Current remap note (main-quest expansion 2026-07-15): source tranches through T11 compile to 1978 cells / 172 quest keys / 134 watched quests / 45 deity names / 26 faucet acts. Use `node .\tools\pdv_quest_tranche_merge.mjs`, then `node .\tools\pdv_main_quest_full_coverage_audit.mjs --json`, then the formal-offer/remap/signal-floor gates before claiming source/readback readiness. For the representative smoke set, run `node .\tools\pdv_signal_floor_smoke_gate.mjs --json`; use `--write-ledger` to regenerate `PDV_SignalFloorSmokeLedger.{md,json}` after source, runtime JSON, or Papyrus log evidence changes. The Debug: State & Rewards MCM page has a `Signal-floor smoke` controlled route selector backed by `PDV__ManagerQuest.DebugRunSignalFloorSmokeScenario`, but those routes remain backend/log convenience only. Green source/readback gates still do not prove runtime-route, Active Effects, Book of Days, Survey/status, Prisma/notification, save/load stack behavior, or the expanded Paarthurnax/main-quest surface; use `references\authoring\PDV_1_0_CoTest_Runbook_2026-07-10.md` for live tester/Codex steps.

Quest-reaction delivery in the public 1.5 line is bounded by the legacy
`PDV_QuestReactionWorker` implementation. That line remains the behavior oracle
for existing saves: it compacts non-runnable rows at ingress, applies at most two
reactions every `0.1` seconds, and emits one final aggregate surface.

The ground-up V3 Quest Reaction contract lives in
`references\authoring\PDV_V3Slice1QuestReaction.manifest.json`. Slice 1B now
runs all eight deterministic parity cases and replaces--not wraps--the legacy
implementation. The existing `0716DF:Devotion.esp` quest hosts
`PDV_QuestReactionRuntime`; Runtime owns qualified catalog resolution,
duplicate suppression, `PDV.V3.QR.*` FIFO state, bounded processing, resume,
cleanup, and status. Manager owns scoring/presentation through a narrow callback
seam. EventBus and MCM target Runtime directly, while PlayerEvents configures it
on alias init/load. The 1.5 queue keys and Worker identity are intentionally not
migrated because V3 is new-game-only.

Run `node .\tools\pdv_quest_reaction_characterization.mjs` and
`node .\tools\pdv_quest_reaction_performance_audit.mjs --self-test` for deterministic
and static proof. Then run
`node .\tools\pdv_quest_reaction_runtime_check.mjs --max-admission-ms 1000 --max-job-ms 180000` after a
fresh Skyrim sweep. Runtime acceptance still requires FIFO lifecycle markers,
    one visible final toast/Book beat per accepted job, and a mid-job save/load
    resume. The consolidated catalog v2 compiler and Runtime cutover are
    backend-green. The AFDI semantic adapter migration and generated package
    consolidation are also backend-green. The combined fresh-game Anvil lane is
    now green for the four-job FIFO/player surfaces, non-empty-queue RESUME, and
    organic MQ102 stage 160. Authoria FOMOD detection, source/sentinel behavior,
    adapters, and support acceptance are the remaining Slice 1 gate.

The Quest Reaction architecture self-test also protects the shared public-source
boundary: every positive, negative, and mixed final toast and Book entry must use
the sanitized source value. Its negative mutations fail if the sanitizer is
removed or if Book alone is changed back to raw `sourceModName`; qualified
Bethesda identities remain available to queue diagnostics.

The 2026-08-14 fresh-game canary passed qualified ingress, five complete queue
lifecycles, the four-job FIFO sweep, four Book of Days entries, and reload after
the queue had already drained. A follow-up save at job 2 cell 4/21 emitted
`RESUME pending=3` and drained jobs 2-4 in FIFO order; four qualified toast
correlations reached both Prisma receipt and render. Re-run that captured shape with
`node .\tools\pdv_quest_reaction_runtime_check.mjs --expected-sequence
"Skyrim.esm|210731|150,Skyrim.esm|148154|160,Skyrim.esm|207142|200,Skyrim.esm|221587|220"
--max-job-ms 180000` for the deliberate save/load run. The same canary exposed
three player-surface defects now owned by the stacked canary-fix branch: Old
Ways deities leaked through the Nine Divines baseline; four persistent Book
entries initially produced only one visibly observed toast; and the resumed
job repeated several later-job Divine names in one new Book entry.

The stacked fix is checked with
`node .\tools\pdv_quest_reaction_eligibility_audit.mjs --self-test` and
`node .\tools\pdv_prisma_toast_cardinality_audit.mjs --self-test`. The first
locks selected-baseline scoring plus the deliberate taboo/hostile and Daedric
exceptions. The second requires four distinct logical correlations to render
four toasts while preserving exact-duplicate suppression. Build the Manager
with `pdv_compile.mjs --script PDV__ManagerQuest`, build the native bridge with
the documented releasedbg xmake command, sync `app.js` and `index.html`, then
fully restart Skyrim before the counted retest. At debug level 2,
`PDV_TOAST_TRACE` markers distinguish Manager submission, native receipt and
Interop dispatch, and UI receipt/dedupe/render. The Runtime now owns one
persisted armed update chain, defers re-arm when a saved active slice owns the
resume, and checkpoints `CellIndex` after each applied cell. The queued Manager
surface lists each deity once; the existing arrow/rune carries higher piety
magnitude instead of repeated names. The corrected counted run on 2026-08-14
logged four enqueues, four starts, four FIFO completions, one `RESUME pending=3`
from cell 2/21, four Prisma receipts/renders, zero UI dedupes, and no overlap,
overflow, stack, or broad-scope failure. The tester confirmed four visible
toasts and no repeated deity names in any newly-created Book entry. Resume and
presentation proof therefore pass. Two subsequent fresh lane sweeps also pass:
Old Ways logged `NordOldWays`, accepted `20/20/20/9` cells, and manually included
Stuhn/Shor while excluding Akatosh; Nine Divines logged `NordNineDivines`,
accepted `21/21/21/7`, and manually excluded Stuhn/Shor/Tsun while retaining
Akatosh. Each lane completed four FIFO jobs with one resume and no overlap,
overflow, stack, or broad-scope failure. This closes the stacked canary-fix
runtime/manual proof. Catalog-v2, semantic-adapter, generated-package backend,
and combined Anvil gameplay now pass; Authoria installer, source/sentinel,
adapter, and support acceptance remains open.

For isolated patch-only Papyrus, set `PDV_COMPILE_SOURCE_ROOT` and
`PDV_COMPILE_OUTPUT_ROOT` to the patch source/output folders, set
`PDV_TRACKED_SOURCE_ROOT` to the same source, and pass the live core source folder
through `PDV_COMPILE_EXTRA_IMPORT_ROOTS`. Slice 1D-A uses that path to compile
`PDV_AFDIObserver` without copying patch code into core. After compile, run
`node .\tools\pdv_patch_source_lock.mjs --relock`, then regenerate and verify the
package with `pdv_quest_reaction_build.mjs --write` and `--check`.

AFDI now submits one catalog-owned `afdi|artifact_destroyed.*` semantic event per
routable destruction. The observer retains baseline/backoff/poll-retirement behavior
but contains no deity outcome literals. Direct houseCARL readback proves the adapter
ESP binds only `PDV_QuestReactionRuntimeService -> 0716DF:Devotion.esp` and now has
only `Devotion.esp` as a master; its SEQ was regenerated after the master prune.
These are compile/readback proofs, not AFDI runtime or save/load proof.

Papyrus logs may append multiple fresh sessions whose persisted sequence resets
to `v3qr_1`. `pdv_quest_reaction_runtime_check.mjs` therefore pairs lifecycle
occurrences in order rather than mapping the whole file by job ID; it fails a
completion without its own preceding start and rejects negative latency. Its
self-test contains two sessions with reused IDs.

The V2 runtime checker also requires the latest configuration/reload summaries
to report at least two admitted catalogs and nonzero active quest keys. An
isolated corrupt extension may increase `rejected` without failing valid core and
official admission. Runtime emits debug-gated `CATALOG_REJECT` markers only on
configuration/reload paths. Its lifecycle is now `ENQUEUE -> BUILD -> START ->
COMPLETE`: admission persists a lightweight header and reports `admissionMs`, then
the existing scheduler materializes catalog cells through persisted build cursors
at the shared two-work-item tick budget before application starts. PlayerEvents
flushes the ordinary quest broad scope before this independent submission. This
fix adds no polling, scheduler, property, VMAD surface, or public Runtime method.
Backend/static and targeted compile proof pass. The 2026-08-15 smoke then proved
organic MQ102 stage-160 admission at `45.013428` ms and an ordered complete
lifecycle. A clean four-job sweep saved during job 1 at `build=8/45`, resumed
with `pending=4`, and drained four FIFO BUILD/START/COMPLETE chains; every
admission was about 45 ms and there was no overflow, stack safety failure, or
`BROAD_SCOPE_ABORT`. Runtime-route and materialization-resume proof therefore
pass. The tester also confirmed four visible toasts and four correct,
duplicate-free Book entries from that counted run. The bounded-ingress fix is
therefore fully smoke-proven; broader Slice 1 compatibility and Authoria
acceptance remain separate gates.

The separate `likes_dislikes_345` discover-location abort is handled on
`codex/v3-broad-scope-likes-fix`. Non-presented generic action fan-out must not
call `BeginLikesDislikesSurface` across the all-deity loop. EventBus and the
ActionRouter fallback capture the active broad pool, collect the strongest
eligible applied positive (or most severe eligible negative) in local
variables, and commit once through `CommitDetachedBroadPantheonEvent`. Run
`node .\tools\pdv_broad_pantheon_audit.mjs --self-test`, the Quest Reaction
performance/characterization/eligibility gates, and compile
`PDV__ManagerQuest`, `PDV_EventBus`, and `PDV_ActionRouter` before syncing.
Backend/static plus isolated and synced live compilation are green. The Anvil
overlap run passed `pdv_quest_reaction_runtime_check.mjs` with the expected
quest sequence and no `BROAD_SCOPE_ABORT`; the tester also confirmed both final
player surfaces. That run did not record a separate numeric broad-standing
before/after readout, so the deterministic model remains the proof for exact
strongest-positive/most-severe-negative selection. Full Authoria testing is deferred until the V3 core and
generated compatibility installer are assembled; Anvil remains the current
runtime canary lane.

Slice 1B compile/readback closeout (2026-08-13) used:

```powershell
node .\tools\pdv_compile.mjs --script PDV_QuestReactionRuntime --script PDV__ManagerQuest --script PDV_EventBus --script PDV_PlayerEvents --script PDV_MCM --skip-verify
node .\tools\pdv_compile_inventory_audit.mjs
node .\tools\pdv_quest_reaction_performance_audit.mjs --self-test
```

The compile produced 0 errors and 0 warnings for all five scripts; inventory is
100/100. `housecarl_load_order_status(profile="Devotion Dev",
lookup="Devotion.esp")` first confirmed the Anvil instance and active framework.
Direct `housecarl_read_record` calls for `0716DF`, `00C325`, `046AF7`,
and `03AFBE` in `Devotion.esp` confirmed the repurposed Runtime host plus its
Manager/EventBus/MCM bindings. V1 local-key fallback is retired; fully-qualified
collision behavior is covered by deterministic backend fixtures, while corrected
installed runtime activation still requires the fresh-game smoke.

`tools\pdv_skyrim_refs_bridge.mjs` is a read-only lookup bridge into the neutral `dunhamma/SkyrimGamePlayReferences` repo. Set `SKYRIM_GAMEPLAY_REFERENCES_ROOT` when the clone is not under `scratch\SkyrimGamePlayReferences`. Use it to list or search broad reference tables such as reverse keywords, faction relationships, condition-bearing effects, cells, containers/furniture, enchantments, leveled lists, FormLists, shouts, and worldspaces. It does not copy data into PDV or replace local xEdit/CK verification. Bridge rules live in `references\vanilla-gameplay\PDV_SkyrimGamePlayReferences_Bridge.md`.

Tracked JSON manifests live under `references\authoring\` and can be addressed by manifest id or file path. `PDV_DeityCoverageMatrix.json` is the Phase 20 roster authority: it reconciles the Phase 4 stance/Daedric matrices into the 1.0 requirement that every locked god and all sixteen Skyrim-present Daedric Prince surfaces be content-ready for every race. `PDV_MedallionRoster.manifest.json` is the lightweight UI/runtime intent contract for the medallion surface: full native roster visibility, live-record readback for honest roster copy, and offer-only commitment with no direct medallion selection path. `mcm-property-wiring` is the canonical batch target for the current `PDV_MCM` properties and defaults to `PDV_PropertyWiringOverlay.esp`, replacing repeated `PDV_Author_one_off_*` property patches when CK property editing is unstable. `preflight-router-services` is the V3 canary target for co-attaching `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter`; it defaults to `PDV_PreflightRouterServicesOverlay.esp`. `skeleton-track-scaffold` is the V3 Structural Skeleton track wiring batch for the locked 12 track quests/globals/FormLists and defaults to `PDV_SkeletonTrackScaffoldOverlay.esp`. `structural-systems-scaffold` is the broad follow-on batch for substrates, sacred places, Hircine, curse state, and MCM scaffold properties. `structural-systems-arrays` is a reporting/TODO manifest for manual threshold/state-array wiring. `PDV_Phase11PrivilegePilot.manifest.json` is the CK-safe runtime contract for the D-10 Arngeir/Kynareth privilege pilot, including the CK-authored branch/topic/unnamed INFO readback and runtime proof status. `PDV_Phase12ContextualFavorPilot.manifest.json` is the targeted contextual-favor runtime contract manifest for Kyne + Nord broad lanes. The scaffold manifests require CK/xEdit creation of the records first. Use `plan` first to inspect a batch, then `apply`, then run `node .\tools\pdv_verify.mjs`.

Tracked offline patch-rule manifests live under `references\authoring\patch-rules\`. The v0 contract uses top-level `ruleType = pdv_patch_rules_v0` manifests with explicit `target`, `operation`, `payload`, and `provenance` fields per rule. Supported provenance statuses are `tooling-example`, `candidate`, `approved`, and `blocked`. `tooling-example` rules are plan-only by default; `candidate` rules must resolve but require `--allow-candidates` to emit; only `approved` rules emit in default live builds. `PDV_PatchRuleExamples.json` and `PDV_Phase19ProofRules.json` are tooling/proof documentation, while `PDV_Phase19TempleLocationRules.json` is the first approved live packet.

### Future authoring direction (non-authoritative)

PDV may eventually grow into a schema-first record-authoring workflow where a text source compiles into `Devotion.esp` via Mutagen. That idea is promising for AI-assisted authoring, diffable record changes, and build reproducibility, but it is still research only in this repo.

Until a real build tool exists and is documented here, do **not** treat any speculative YAML/TOML draft as the source of truth for PDV records. The active workflow remains:

- Papyrus source in `Devotion\Scripts\Source`
- live ESP state in `Devotion.esp`
- verification through `tools\pdv_verify.mjs`
- scripted ESP wiring through direct `housecarl_*` MCP calls, with tracked contracts under `references\authoring\`

If a future schema-first tool lands, update `AGENTS.md`, this setup doc, and the verifier/authoring workflow together before adding any new source-format files.

### Anvil MO2 MCP status

Codex is configured for the Anvil MO2 MCP server at `http://127.0.0.1:27016/mcp` in `C:\Users\Admin\.codex\config.toml`. Start it from Anvil/MO2 with the `Start/Stop MCP Server` tool entry. Current local intake and optional binary status live in `references/PDV_Anvil_MO2_MCP_Intake.md`.

Toolchain usage rules:
- After any `.psc` edit, run `node .\tools\pdv_compile.mjs` or a targeted `--script` compile.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- After doing a new kind of work, review what was manual, fragile, repeated, or easy to forget, then improve the verifier/helper/manifest/checklist/docs path when the next pass would benefit.
- After editing any `race-sheets\PDV_*Content_Manifest.md` content manifest, run `node .\tools\pdv_content_verify.mjs` and resolve all FAILs (ASCII drift, budget caps, slot-ID collisions).
- After editing `references\authoring\PDV_DeityCoverageMatrix.json` or Phase 20 roster scope, run `node .\tools\pdv_verify.mjs --strict-phase20-roster` and `node .\tools\pdv_content_verify.mjs --strict-phase20-roster`.
- After editing `references\authoring\PDV_MedallionRoster.manifest.json`, Prisma medallion UI, or manager medallion helpers, run `node .\tools\pdv_verify.mjs`; if `.psc` changed, compile `PDV__ManagerQuest` first.
- After editing `references\authoring\PDV_Phase20AltmerImplementationCosting.manifest.json` or Altmer crisis/Lorkhan/favor scope, run `node .\tools\pdv_verify.mjs --strict-phase20-altmer`. If source changed, compile the touched scripts first with `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_EventBus --script PDV_EventTypes --strict-phase20-altmer --strict-phase20-race-costing`.
- After editing any `references\authoring\PDV_Phase20*ImplementationCosting.manifest.json` file or race implementation-costing scope, run `node .\tools\pdv_verify.mjs --strict-phase20-race-costing`.
- After Phase 20 QASmoke runtime activation, run `node .\tools\pdv_phase20_runtime_check.mjs --race all`, then capture the Survey/status, immersion, negative-hook, and anti-farm checks in `references\authoring\PDV_Phase20_QASmokeRuntimeProof_Runbook.md`; route logs alone are not runtime closeout.
- Use the `housecarl_*` MCP tools when existing-record property/FormList wiring should be scripted instead of repeated CK clicking. The default lane writes a new patch plugin, leaving `Devotion.esp` untouched; verify with a `housecarl_read_record` readback.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3`.
- Before declaring V3 Preflight complete, run `node .\tools\pdv_verify.mjs --strict-preflight` (or compile with `node .\tools\pdv_compile.mjs --strict-preflight`) and resolve all FAILs.
- Before declaring any V3 Structural Skeleton scaffold wave complete, run `node .\tools\pdv_verify.mjs --strict-skeleton` (or compile with `node .\tools\pdv_compile.mjs --strict-skeleton`) and resolve all FAILs.
- Before declaring a Pattern Proving checkpoint complete, run `node .\tools\pdv_verify.mjs --strict-pattern-proving` (or compile with `node .\tools\pdv_compile.mjs --strict-pattern-proving`) and resolve all FAILs.
- Before declaring Phase 7 signal expansion complete, run `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 8 reputation-track closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 9 Bosmer-path closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 10 Dunmer-substrate graduation complete, run `node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and confirm runtime notes still prove substrate progress separate from patron piety.
- Before declaring the Khajiit/commitment/neglect/Phase 11 packet complete, run `node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and resolve all FAIL/WARN results. Current closeout is clean at `PASS=908, INFO=28`.
- For Phase 11, run `node .\tools\pdv_verify.mjs --strict-phase11` to confirm the D-10 Arngeir/Kynareth manifest contract plus the live CK-authored branch/topic/INFO readback. Phase 11 runtime proof is complete as of 2026-05-26.
- **Record authoring (all phases):** author ESP record changes with the `housecarl_*` MCP tools directly, then read the value back with `housecarl_read_record` / `housecarl_cross_plugin_query` in the same session -- that readback is the proof. Then compile any touched source scripts, refresh SEQ after ESP writes, and run the strict verifier ladder for the phase. The retired `pdv-*-author` helpers that used to own this step are gone; see the houseCARL Direct Plugin Work Rule in `AGENTS.md`.
- Phase 12 closeout ladder: `node .\tools\pdv_verify.mjs --strict-phase12`, then the full upstream strict ladder. A fresh ESP write should leave `SEQ freshness` as the expected remaining warning until `Devotion.seq` is refreshed.
- Phase 13 closeout ladder: refresh SEQ, then `node .\tools\pdv_verify.mjs --strict-phase13` before starting runtime proof.
- Phase 18/Nord closeout ladder: compile `PDV_MCM`, `PDV__ManagerQuest`, and `PDV_SurveyDevotionEffect`, then `node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord --strict-phase17 --strict-phase13 --strict-phase14 --strict-phase15 --strict-phase16`. Dialogue edits remain manual CK work; refresh SEQ after CK saves and resolve freshness before closeout. The closeout runtime matrix lives in `references\authoring\PDV_Phase18StatusNord.manifest.json`, expanded into operator steps in `references\authoring\PDV_Phase18_StatusNord_Runbook.md`.
- Phase 20 race packets (Altmer, Argonian, Orc, Redguard, Bosmer, Khajiit): after the houseCARL write + readback, compile the touched scripts (typically `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, `PDV_EventSignalActivator`, plus any race substrate such as `PDV_Substrate_ArgonianHist`), refresh SEQ, and run `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing`.
- Phase 20 QASmoke proof references and the preserved CAT-6 pilot (`PDV_Bless_Khajiit_Lunar_T1`): place/verify the proof REFRs via houseCARL, then `node .\tools\pdv_refresh_seq.mjs --write --json` and `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`. This creates proof-harness refs only; final immersive world placement and runtime proof remain separate gates. All-race T1 reward grants are owned by `PDV_Phase20_RewardRecordContracts.json`, and Active Effects display still requires runtime/manual proof.
- For Phase 20 roster/content lock work, `--strict-phase20-roster` is required. The gate must stay clean before declaring any full-roster slice complete.

### Default closeout loop

Use this as the default order after substantive PDV work:

1. Compile changed Papyrus with `tools\pdv_compile.mjs` if any `.psc` changed.
2. If the work touched CK/ESP/MO2 state, run `tools\pdv_verify.mjs` and use
   the relevant strict gate before calling the change done.
3. If the work was existing-record wiring, prefer a direct `housecarl_*` write
   plus a `housecarl_read_record` readback over repeated one-off CK edits.
4. If a design review locked a new rule, ratify it across the living docs in
   the same session so `AGENTS.md`, setup notes, and race/design docs do not
   drift.
5. If the work introduced a new pattern, do a tooling harvest: decide whether
   verifier coverage, an authoring helper, a manifest, a checklist, or a local
   skill should make the next pass easier.

This order reflects the recent project pattern: the expensive mistakes are not
usually raw code edits, but stale record wiring, one-off overlay drift, and
design decisions that were only updated in one place.

### VS Code Papyrus extension role

Editor-only: syntax highlighting, hover info, intellisense, debug attach. Not the build path.

### Integrity & signal verifier suite (2026-06-24)

One-command roll-up: `node tools/pdv_integrity_harness.mjs` (gate + curated-parity + floor +
spine-score + specced-minus + deity-chain + eligibility-reward coverage + completeness;
`--skip-slow` omits the dotnet-backed checks).
Ledger classes (PDV_STANDARDS.md section 5.3, ratified 2026-07-15): the machine-read
pipeline-state files (`PDV_SignalE2EGateLedger.csv`, `PDV_SignalFloorLedger.csv`,
`PDV_P2FormListEspLedger.csv`, `PDV_FeltTraceLedger.json`, `PDV_PacingSimLedger.json`,
`PDV_FinalPlacementLedger.json`, `PDV_1_0_FreshnessStamps.json`) are committed; every other
generated output below is a regenerable report -- gitignored, kept on disk, regenerated by
running its tool. If a report file is missing, run its tool; do not restore it from git.
Individual tools (all read-only except their own generated ledgers):
- `node tools/pdv_signal_e2e_gate.mjs` -> `PDV_SignalE2EGateLedger.{md,csv}` (P2 surface
  wiring + the **curated-signal parity** check; exit 1 on RED or a parity gap)
- `node tools/pdv_signal_floor_audit.mjs` -> `PDV_SignalFloorLedger.{md,csv}` (per-path floor)
- `node tools/pdv_signal_floor_smoke_gate.mjs --write-ledger` ->
  `PDV_SignalFloorSmokeLedger.{md,json}` (representative signal-floor smoke matrix; backend
  PASS may still leave runtime/manual slots OPEN)
- `node tools/pdv_spine_stack_score.mjs` -> `PDV_SpineStackScoreLedger.{md,csv}` (ancestral-spine
  parity, Argonian=100%, <70%=target; reads `PDV_SpineStackRegistry.csv`)
- `node tools/pdv_specced_minus_audit.mjs` -> `PDV_SpeccedMinusLedger.{md,csv}` (minus signals
  defined+handled but never emitted)
- `node tools/pdv_deity_chain_audit.mjs --json` -> blocking live code/ESP reverse-trace check
  for missing reward/offer records and unreachable active-patron reward families
- `node tools/pdv_eligibility_reward_coverage_audit.mjs --json` ->
  `PDV_EligibilityRewardCoverageLedger.{md,csv}` (focusable reward rows from live Papyrus
  checked against live SPEL existence and manager VMAD property fill)
- `node tools/pdv_substrate_pacing_audit.mjs --json` -> shared `+4` daily-credit,
  `1/25/75`, decay, origin/source, and bypass contract
- `node tools/pdv_broad_pantheon_audit.mjs --json` -> Imperial/Nord pool aggregation,
  migration, baseline, decay, and patron-transition contract
- `node tools/pdv_pantheon_record_readback.mjs --json` and
  `node tools/pdv_pantheon_presentation_readback.mjs --json` -> direct houseCARL record,
  VMAD, Active Effects, Observe-the-Moons, and player-copy readback
- self-test env flags: `PDV_SIGNAL_E2E_PARITY_SELFTEST=1`, `PDV_SPINE_SELFTEST=1`, `PDV_SPECCED_MINUS_SELFTEST=1`

**Gotchas:**
- **MCP-down:** the e2e gate's live-ESP columns + houseCARL are SKIP-not-PASS when the Anvil MCP
  server is down (a RED there is a liveness artifact, not an authored RED). `pdv_verify` reads
  `Devotion.esp` **directly** (no MCP), so it covers the ESP layer even when MCP is down. Start it
  via Anvil.exe -> MO2 Tools -> Start MCP Server.
- **Workflow `args` don't inject:** passing `args` to the Workflow tool gave `race=UNKNOWN` twice
  (string, and object-via-scriptPath). HARDCODE race-specific values into acceptance-workflow
  scripts (the hardcoded Dunmer/Orc scripts worked; the parameterized Altmer/Breton ones failed).
- **Repo-source drift:** `live-source/` is a junction to the canonical untracked live dir; the
  Grep/Glob editor index can surface a more-advanced worktree than bash sees on disk. Trust
  `pdv_compile`/`pdv_verify` (they read the live deploy dir) + git for ground truth.
- **VMAD declarations are not bindings:** a Papyrus `Property ... Auto` declaration and a valid
  target record do not prove the live QUST VMAD is filled. Read the exact manager/alias property
  through houseCARL after every property addition. The Observe-the-Moons power and message list
  existed but remained runtime-None until direct readback caught and repaired both bindings.
- **Approved FormLists are exact sets:** readback must fail on unexpected members as well as
  missing approved members. A rogue vanilla `CounterLeft01` entry survived until exact-membership
  validation replaced presence-only checking.

### Papyrus authoring gotchas

Keep these in mind before blaming CKPE or MO2 for compile weirdness:

- On compile failure, classify the problem in this order: import chain,
  API/source provenance, Papyrus parser/language limit, then logic bug.
- Papyrus string literals only reliably escape `\\` and `\"`. Do not put `\n`, `\r`, or `\t` in `.psc` strings.
- `{...}` docstrings belong immediately after `ScriptName`, `Property`, `Function`, or `Event` declarations. Use `;` comments inside control flow, and avoid JSON-like literal `{` examples in docstrings.
- `StringUtil.Replace` does not exist. Avoid string substitution in runtime paths unless a manual helper has been compile-tested.
- Papyrus has no ternary operator, string interpolation, string `+=`, `Math.max`, or `Math.min`. Arrays cannot be sized by variables and cap at 128 elements.
- Split chained casts into named intermediate variables. Do not rely on `(value as int as float)` style expressions.
- Do not use short names that may collide with type/script names (`key`, `form`, `actor`, `cell`, `ActorBase`, `Message`) or local names that shadow script properties. Prefer explicit local names such as `targetActor`.
- Before using a new vanilla, SKSE, or plugin-provided Papyrus function, open
  the shipped `.psc` source or other verified project source and confirm the
  exact signature first.
- If a script edit behaves impossibly on an existing save, retest from a new game or main-menu `coc qasmoke` path before redesigning the logic.
- To fire a PDV signal object (`PDV_REFR_*Signal`) from the console for testing, get the plugin's 2-hex load prefix from a NAMED PDV record, not the (nameless) activator: `help "HoonDing" 0` -> read the prefix off the `SPEL:` line's FormID, then `prid <prefix><refid>` + `activate player` (bare `activate` errors). `help "OrcStrongholdForge"` returns nothing because the activators have no name and the Anvil list strips EditorIDs; never hardcode a guessed prefix (load order drifts). See memory `signal-prefix-via-named-blessing`.
- If `SKI_ConfigBase.pex` ever appears in `Devotion\Scripts` after a compile, delete it and fix the compile target list. PDV's wrapper should compile PDV scripts only; this file appearing would indicate accidental SkyUI source compilation.

---

## Project ESP Structure

### File Naming Convention

```
Devotion.esp    <- master file, all races depend on this
PDV_Nord.esp
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

### Quest Layout per ESP

The framework ESP holds the spine: bootstrap, runtime, and shared event detection. Race ESPs hold per-race tracking and reactions only.

```
Devotion.esp:
  PDV__MainQuest                  RunOnce bootstrap
  PDV__ManagerQuest               Start-Game-Enabled runtime; per-deity ledger and dawn consolidation
  PDV_Deity_[Name]                Start-Game-Enabled deity quest records
  PDV_ActionRouter                Start-Game-Enabled Phase 3 fan-out service
  PDV__SM_KillActor               Phase 3 Story Manager receiver for Kill Actor; not Start-Game-Enabled
  PDV_FLST_AllDeities             FormList of deity quests
  PDV_GLO_ActivePiety             Active patron mirror
  PDV_GLO_ActiveTier              Active patron mirror
  PDV_GLO_ActiveDeityIndex        Active patron mirror
  PDV_GLO_DebugLevel              Trace verbosity

PDV_[Race].esp:
  PDV_Race[Name]Quest             per-race tracking quest, depends on framework
  PDV_Race[Name]Script            per-race script
  PDV_Blessing_[Race]_Low/Mid/High
  PDV_Neglect_[Race]
  per-race dialogue, factions, condition records
```

Race ESPs declare the framework ESP as a master. Event capture lives in framework-level receiver quests; scoring lives on deity quests and routes through `PDV_ActionRouter` plus `PDV__ManagerQuest.AwardPiety()`.

### EditorID Prefix Convention

All records use the prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals (config, debug, dev) add a second underscore (`PDV_GLO__X`). Borrowed from the Gods And Worship taxonomy -- lets a CK or xEdit reader recognize the role of a record from its name alone.

```
# Quest records
PDV__MainQuest                internal: RunOnce bootstrap
PDV_Origin                    internal: one-shot Phase 4 origin detector / seed helper
PDV__ManagerQuest             internal: runtime ledger, mirrors, dawn consolidation
PDV_Deity_[Name]              concrete deity quest
PDV_Deity_Talos               hostile-path proof deity for Altmer/Talos defection slice
PDV_Deity_AuriEl              minimal Altmer foundation deity / Talos rival target
PDV_ActionRouter              persistent Phase 3 event fan-out service
PDV__SM_KillActor             internal Phase 3 Story Manager receiver
PDV_Race[Name]Quest           per-race tracking (in race ESP)

# Global Variables (read externally by MCM, condition functions, shrine scripts)
PDV_GLO_ActivePiety           active patron piety mirror
PDV_GLO_ActiveTier            active patron tier mirror
PDV_GLO_ActiveDeityIndex      active patron stable int, -1 = none
PDV_GLO_OriginRace            Phase 4 race index
PDV_GLO_PatronDeity           active patron cached identifier, 0 = none
PDV_GLO_DebugLevel            trace verbosity
PDV_GLO__Config_[Setting]     reserved MCM config prefix

# Spell / magic effect records
PDV_Blessing_[Race]_Low/Mid/High
PDV_Neglect_[Race]
PDV_DebugSpell

# Story Manager flag globals (one-shot, where needed)
PDV_SMF_JoinedCompanions      one-shot flags fired by Story Manager hooks
PDV_SMF_JoinedDarkBrotherhood
PDV_SMF_JoinedThievesGuild
PDV_SMF_JoinedLegion
PDV_SMF_JoinedStormcloaks
PDV_SMF_JoinedCollege
PDV_SMF_BecameWerewolf
PDV_SMF_BecameVampire
```

Consistent prefixing is non-negotiable. It prevents conflicts, makes records findable in xEdit, and keeps the CK object window navigable as the mod grows.

---

## Papyrus Log Setup

Enable detailed Papyrus logging for development.

**Log location:**
`Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`

**What to look for:**

```
[PDV]  <- your trace messages will appear here
error  <- search this to find script errors
warning <- non-fatal issues worth addressing
```

**Recommended log viewer:** Notepad++ with auto-refresh enabled.
Open log -> Edit -> Monitoring (tail -f equivalent).

**Add trace calls to every significant function during development:**

```papyrus
Debug.Trace("[PDV] ProcessDawn complete.")
Debug.Trace("[PDV] ActionRouter: routed event " + eventType + " delta " + delta)
```

Gate traces behind `PDV_GLO_DebugLevel` before release.

---

## Key Console Commands for Testing

Run in-game via the **~** (tilde) key. Full command reference: `PDV_SkyrimConsoleReference.md`.

```
; Read a global variable
GetGlobalValue PDV_GLO_ActivePiety
GetGlobalValue PDV_GLO_ActiveTier
GetGlobalValue PDV_GLO_ActiveDeityIndex

; Write a global variable (for forcing test states)
set PDV_GLO_ActivePiety to 15.0

; Show all variables on a quest
sqv PDV__ManagerQuest

; Show all quest stages
sqs PDV__ManagerQuest

; Check what race the player is
player.getracename

; Toggle AI (freezes all NPCs for environment inspection)
tai

; Toggle collision (for checking trigger box placement)
tcl
```

> **Note:** `cgf` only works on Papyrus functions marked `global`. `cqf` only calls named functions that exist on the quest script; it does not evaluate arbitrary Papyrus snippets. Instance functions on quest scripts (like `AwardPiety`) cannot be called from console directly unless a deliberate named debug dispatcher is added. PDV's current validated debug path remains the `SetPQV` poll harness and globals inspection.

---

## Core Variables Reference

Quick reference for the values that everything else reads and writes.

> The bucket system (`CombatBucket`, `SocialBucket`, `LifestyleBucket`) and `PDV_GLO_DevotionLevel` have been removed as of Phase 1. Do not reference them.

### StorageUtil Keys (per-deity, keyed by deity FormID)

| Key | Range | Purpose |
|-----|-------|---------|
| `PDV.Piety` | 0--200 | Current piety. Source of truth. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Consolidated at dawn, then reset. |
| `PDV.Tier` | 0--3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Grace period tracking + MCM display |

Read/write via `StorageUtil.GetFloatValue(deityForm, key)` / `StorageUtil.SetFloatValue(deityForm, key, value)`. PapyrusUtil SE is an SKSE DLL -- no ESP master required, just call it directly.

### Mirror GlobalVariables (active patron only)

| EditorID | Type | Purpose |
|----------|------|---------|
| `PDV_GLO_ActivePiety` | Float | Active patron's current `PDV.Piety` |
| `PDV_GLO_ActiveTier` | Float | Active patron's tier (0--3) |
| `PDV_GLO_ActiveDeityIndex` | Float | Stable int for active deity. -1 = none |

Mirrors are write-only caches refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()`. Never read them as source of truth -- always read StorageUtil. Never write them directly -- always call `AwardPiety` or `RecomputeTier`.

### Tier Thresholds (defaults, tunable per-deity in Phase 2+)

| Tier | Label | Piety threshold |
|------|-------|----------------|
| 0 | None | < 10 |
| 1 | Seeker | >= 10 |
| 2 | Devoted | >= 50 |
| 3 | Champion | >= 150 |

### System GlobalVariables (Phase 2+)

| EditorID | Purpose |
|----------|---------|
| `PDV_GLO_OriginRace` | Permanent cultural origin race index 0--9, set once at game start |
| `PDV_GLO_PatronDeity` | FormID of active patron. 0 = none |
| `PDV_GLO_DebugLevel` | 0--3 trace verbosity, MCM-toggleable |

Phase 4 implementation note:

- `PDV_GLO_OriginRace` should default to `-1` in CK so `PDV_Origin.InitializeOrigin()` can detect "not initialized yet" safely.
- `PDV_Origin` normalizes vanilla vampire race records back to the corresponding base race before writing `PDV_GLO_OriginRace`. If the current race is only a temporary beast form (`WerewolfBeastRace` or Dawnguard Vampire Lord), initialization defers instead of writing a fallback.
- The CK global editor only shows the plugin default for `PDV_GLO_OriginRace`. Use in-game `GetGlobalValue PDV_GLO_OriginRace` / `set PDV_GLO_OriginRace to -1` when you need to inspect or reset the runtime value in a live save during smoke testing.
- `PDV_GLO_PatronDeity` is now written by `PDV__ManagerQuest.SetActiveDeity()`. It is a cache/helper global, not the canonical source of truth for patron state.

Coupled Talos + Auri-El follow-on note:

- `PDV_Origin` now uses a small script-constant seed table for `PDV_Kyne`, `PDV_Talos`, and `PDV_AuriEl`.
- `PDV__ManagerQuest.AwardCuratedSignal()` is the intended reusable path for named shrine/quest/faction/devotional signals that do not belong in the broad event router.
- Talos hostility should be verified against a real `PDV_Deity_AuriEl` ledger target, not a placeholder.

---

## Story Manager Hook Reference

Phase 3 uses Story Manager for live action capture, but Story Manager starts quests rather than directly subscribing a persistent quest to an event stream.

Current Phase 3 route:

| Event | Receiver quest | Script event | Router output |
|-------|----------------|--------------|---------------|
| Kill Actor | `PDV__SM_KillActor` | `OnStoryKillActor(victim, killer, location, crime, relationship)` | `PDV_ActionRouter.HandleStoryKillActor(...)` |

Rules:

- `PDV_ActionRouter` stays Start-Game-Enabled and persistent.
- Story Manager receiver quests such as `PDV__SM_KillActor` are not Start-Game-Enabled.
- PDV Story Manager nodes must have `Shares Event` checked.
- Receiver scripts should call the router, then stop/reset themselves so later events can start them again.
- Event capture writes through `PDV__ManagerQuest.AwardPiety()` only; it never writes persistent piety, tier, or mirror globals directly.

Current script status:
- `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` compile cleanly.
- CK quest creation, property assignment, Kill Actor node wiring, and SEQ generation are complete.
- Runtime verification passed for hostile bandit scoring (`event 2`, Kyne `+0.5` scratch), hostile wolf scoring (`event 1`, Kyne `-3.0` scratch), neutral-kill rejection, rapid dual-kill accumulation, and manual dawn consolidation/clamping.

---

## Future Dialogue, MCM, and Storage Notes

Dialogue:
- V1 does not add new NPC conversation lines, voiced responses, lip files,
  scene content, or broad recognition topics. Existing Arngeir/Nord dialogue is
  retained as technical proof and prototype evidence only.
- Dialogue topics live inside Quest forms, not as top-level Object Window records.
- CK condition names are not always Papyrus method names. Example: Papyrus `IsDead()` maps to CK condition `GetDead`.
- Keep related `Link To` chains in the same branch when possible; cross-branch links can fail if the target branch conditions do not pass independently.
- Hello topics auto-fire by proximity. Do not use Force-Activate for normal Hello greetings.
- Keep future V2 dialogue lines under 80 characters where possible, and regenerate SEQ after dialogue edits.

Storage:
- Pick one backend per key. Do not write with StorageUtil and read with JFormDB or JDB/JArray.
- StorageUtil remains the PDV default for per-deity and per-form state.
- If JContainers is introduced later, store integer FormIDs in long-lived JArray/JDB collections and resolve with `Game.GetForm(formId)` when a live Form/Actor is needed.
- For JDB, use plain keys with `setObj` and dot-prefixed paths with `solveObj`; do not create nested dot paths through `setObj`.

MCM and skill systems:
- SkyUI MCM option builders return OIDs. Store each OID from `AddSliderOption`, `AddMenuOption`, `AddToggleOption`, etc., or event handlers cannot reliably identify which option fired.
- Keep MCM minimal: enable/disable, hotkeys, verbosity/difficulty, and a small number of genuinely player-facing toggles.
- The first PDV MCM slice is a development surface only: `Status` + `Debug`, no tuning globals, and no player-facing patron-selection contract.
- If PDV later uses Custom Skills Framework, the ESP filename in the CSF JSON must match the plugin filename exactly. Mismatch can make skill/perk lookups fail silently.

---

## Build Order

Follow this sequence. Do not skip ahead.

```
[x] Environment setup complete and verified
[x] MO2 dev profile confirmed clean (Devotion Dev minimal)
[x] CK launches and finds all vanilla assets
[x] Devotion.esp created
[x] PDV__ManagerQuest (Start-Game-Enabled) and PDV__MainQuest (RunOnce) created in CK
[x] Phase 0 -- PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 -- StorageUtil data model; mirror globals declared and verified in-game;
      PDV__ManagerQuest refactored with AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors
[x] Phase 2 -- PDV_DeityBase + PDV_Deity_Kyne; PDV_FLST_AllDeities; ProcessDawn loop;
      CK compile/wiring/runtime verification complete
[x] Phase 3 -- PDV_ActionRouter + PDV__SM_KillActor complete;
      CK wiring, Story Manager routing, SEQ, and runtime verification all passed
[x] Phase 4 -- scripts/tooling, framework ESP wiring, and full in-game proof passed
[x] Phase 5 -- MCM dev slice script/tooling/framework wiring landed; in-game SkyUI proof passed
[x] Phase 6 -- Talos + Auri-El hostile-path proof slice framework-wired and full in-game proof passed
[x] V3 Preflight - script/tooling, framework-owned record wiring, strict verifier gate, and clean-start smoke complete
[x] V3 Structural Skeleton - broad structural systems scaffold is merged, strict-verifier clean, and runtime-smoked
[ ] Debug spell created and tested
[ ] Nord module complete
```

Check off as you go. If something at step N breaks, the problem is in step N -- not step N-7.

---

## Common Errors and Fixes

**Author-tool ESP write fails "used by another process" (and Skyrim/xEdit/CK are NOT running):**
The houseCARL MCP's Mutagen overlay holds an open handle on the Anvil load order, including `Devotion.esp`, after any houseCARL read in the session. Pointing houseCARL elsewhere releases it. Workaround (verified 2026-06-11): `housecarl_set_mo2_instance` -> `D:\Wabbajack\modlists\DoD`, run the ESP write(s), then re-point to `D:\Wabbajack\modlists\Anvil`. Always re-point back: the instance choice persists to disk. If `SkyrimSE.exe` IS in the tasklist, that is the lock instead -- the game must quit to desktop first.

**CK crashes on load:**
Usually a corrupted plugin. Check your load order in MO2. Ensure no plugin has a missing master.

**Script compiles but quest doesn't run:**
Confirm `Start Game Enabled` is checked on the quest record in CK. Confirm the script is attached to the quest (Quest -> Scripts tab, not just saved in the source folder).

**Trace messages not appearing in Papyrus.0.log:**
Confirm `bEnableLogging=1` and `bEnableTrace=1` in the active game/profile INIs, not just CK defaults. For the current `Devotion Dev` runtime, the live Papyrus path is `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. There may also be `Papyrus.1.log`; `.0` is usually the newest active session, but verify timestamps instead of assuming.

**Event not firing:**
For Phase 3 Story Manager events, check that the receiver quest is under the correct SM Event Node, that `Shares Event` is checked, and that the receiver quest is not already stuck running. Use `SQV PDV__SM_KillActor` around a kill test and check Papyrus logs for the receiver trace.

**Piety changing unexpectedly:**
Check whether the change is in `PDV.PietyToday` or persistent `PDV.Piety`. Runtime events should only write `PDV.PietyToday`; persistent piety and mirrors should change only after `ProcessDawn()`.

**Story Manager hook firing more than once:**
For repeatable live events such as kills, duplicates are not handled with one-shot globals. Confirm the receiver quest stops/resets after dispatch, then test rapid kills to verify exactly one routed action per valid kill.

**Parser errors that point at the wrong line:**
Check for invalid string escapes (`\n`, `\r`, `\t`), misplaced `{...}` docstrings, literal `{` inside docstrings, or locals/properties shadowing a script/type name. Papyrus often reports the cascade rather than the original trigger.

**Script behavior differs between saves:**
Retest from a new game or main-menu `coc qasmoke` path. Skyrim save files can retain old script instances and property state after source changes.

**Nexus "Mod Manager Download" clicks silently do nothing:**
The Windows `nxm://` protocol handler (`HKCU:\Software\Classes\nxm\shell\open\command`) can point at a
DELETED MO2 instance -- verified 2026-07-04 when it still pointed at the removed KoK modlist, so manager
downloads vanished without any error. Fix from the target instance: open Anvil MO2 -> Settings -> Nexus ->
"Associate with 'Download with Manager' links". Manual browser downloads land in `C:\Users\Admin\Downloads`
and MO2-managed ones in `D:\Wabbajack\downloaded mods` (shared by the instances).

**Reading a book/opening an item menu CTDs instantly:**
Check the record has a real `Model` path. A Mutagen-authored BOOK with `Model = (absent)` crashes the book
menu on read (the 2026-07-04 Dunmer urn CTD). `housecarl_read_record` shows the field; any NIF that exists
in the VFS fixes it. Verify asset resolution with `housecarl_asset_status`.

**Bundling third-party assets into the Devotion mod:**
Precedent (2026-07-04, Remiros' Dunmer Urns HD): repath the MESH into a Devotion-owned folder
(`Meshes\PDV\...`) so vanilla records are not silently replaced, keep the TEXTURES at the exact paths the
NIF references internally (scan the NIF binary for `.dds` strings first; unique third-party filenames mean
no vanilla collision and no NIF editing), record the permission basis in the mod-root `Credits.txt`, and add
the new folders to the tester-bundle deployable set (it is no longer just the 108-file list -- `Meshes\`,
`Textures\`, `Credits.txt` must ship).

**Inventory item renders as a tiny speck (or not at all) in the item-card preview:**
The preview camera zooms to fit the MESH's BSTriShape bounding spheres, NOT the record's ObjectBounds.
World-replacer meshes can ship absurd export bounds that never matter in-world -- Remiros' urn had
RADIUS=4565 on a 74-unit-tall model, so the camera framed a sphere 60x the urn and drew a speck. Diagnose
with `node .\tools\pdv_nif_inspect.mjs <nif>` (dumps blocks, scales, bound centers/radii + their byte
offsets); fix with an in-place `writeFloatLE` at the reported bound offset, setting a radius that safely
covers the geometry (corner distance from the bound center + margin -- too small causes world culling
flicker). Always back up the `.nif` first; the record's OBND is still worth setting for engine grid/LOD
purposes but does not drive the preview camera.

**Game CTDs while opening SkyUI MCM during PDV smoke tests:**
Check the newest crash log under `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\SKSE\`. If the stack repeats `ReShade64.dll` with `WS2_32.dll` and `webio.dll`, treat it as a native environment issue first rather than a PDV MCM logic failure. The confirmed PDV smoke-test workaround was to temporarily rename `D:\Wabbajack\modlists\Anvil\Stock Game\ReShade64.dll` out of the Stock Game root, retest, then restore it later for dedicated ReShade investigation.

---

## Version Control Setup (Git)

If using Git, initialize in your workspace folder:

```bash
git init
git add .
git commit -m "Initial project structure"
```

**.gitignore** -- exclude compiled scripts and CK temp files:

```
*.pex
*.bak
*.tes
*.log
CreationKitPrefs.ini
```

Commit after every completed build step. Branch for experimental features.
Suggested branch naming: `feature/nord-combat-triggers`, `fix/dawn-event-doubling`.

---

## Notes / Decisions Log

**2026-08-20 AEST - V3 post-module integration gate reconciliation:**
After ORIGIN, RECOGNITION, PRISMA, and DEBUG extraction, the 37 known verifier failures were
retired as one integration checkpoint rather than churned during each module move. Normal
location ingress now calls `OriginRuntime.HandleLocationChange(...)` once; contextual ORIGIN
events and queries, including moon observation and Baan Dar rescue eligibility, route through
the generic typed seam. Any verifier that follows decomposed behavior must read the complete
module family, join every matching polymorphic override body, and inspect an explicit VMAD
property window instead of assuming manager residence, selecting the first override, or using
a stale tail slice. Full verification is clean at `FAIL=0, WARN=0, TODO=0, PASS=4092, INFO=97`.
The manager still has duplicate historical Nine Divines T1/T2 and Observe Moons/FormList VMAD
properties; both copies point to the same correct forms, so deletion is a later supervised
record-cleanup pass, not part of this source/gate checkpoint. This evidence is static,
compile, and readback proof only; fresh-game, player-surface, save/load, and package proof remain
separate.

**2026-08-11 AEST - Daedric effect-model decomposition (balance-neutral):**
Daedric boon and price composition moved behind
`tools/lib/pdv_daedric_effect_model.mjs`. The compiler now consumes one
`buildPrinceSpellPackets(...)` interface; the module explicitly declares every tier,
maps every used ActorValue to a unit-specific band, and owns Mora Champion's two-effect
packet in place. Generator self-test proves the resulting sixteen-Prince contract is
unchanged. The live verifier now resolves all 96 SPELs and 97 effect references and
links, while the dedicated price gate still checks all price magnitudes. No ESP
or magnitude changed; #37 retains the boon reconciliation, owner-reviewed tuning, and
in-game felt-check work.

**2026-08-11 AEST - standard release-proof refresh:**
`tools/pdv_release_proof_refresh.mjs` and
`references/authoring/PDV_ReleaseProofRefresh_Runbook.md` now own the complete refresh
sequence. Machine checks re-derive ESP bytes, masters, both record frames, exact contested
membership, critical winners, VMAD, PSC/PEX pairs, and claimed asset providers. Promotion
requires explicit review of critical-target scope, CELL retention, and the open proof
boundary. `pdv_package_release.mjs` calls the live check and no longer pins the number 33.
The proof remains static/package evidence only; runtime and manual behaviour stay open.

**2026-08-11 AEST - off-roster worship boundary and save migration:** New patron
selection is centrally limited to the player's origin roster or a currently valid
formal-offer lane. Explicit MCM debug selection remains an override. Existing saves
retain an already-active FOREIGN/TOLERATED off-roster patron, and that relationship can
still receive shrine and quest reactions at the canonical 0.4 rate; generic deeds remain
NATIVE-only. Quest-matrix awards bypass the record stance multiplier because the compiled
matrix has already applied stance. Likes/dislikes version 21 reprojects every deity's
record stance, and the stance parity gate now checks the runtime migration table as a
fourth authority.

**2026-08-11 AEST - KID/SPID optional recognition layer:** KID and SPID are now
strongly recommended soft dependencies rather than deferred frameworks. Three flat Data-root
distributor files ship with Devotion: `PDV_GreenPact_KID.ini`,
`PDV_ItemRecognition_KID.ini`, and `PDV_ReligiousRecognition_DISTR.ini`. KID supplies the
Green Pact and seven semantic item-action lanes; SPID supplies faith keywords plus paired
cohort factions for non-voiced NPC recognition. Faithful/Devoted map to Friend/Ally, while
Enemy is reserved for explicit hard rivals and does not create attack-on-sight behavior. The
manager owns relationship reconciliation and exposes a ModEvent ownership handshake for
Repute or another reputation system. Absence of either framework simply removes that optional
reach; core devotion and PatchHub quest reactions remain available.

**2026-08-11 AEST - source-labelled PatchHub tester surfaces:** Every generated
PatchHub reaction channel now receives its FOMOD option name as optional
`sourceMod` metadata. `PDV__ManagerQuest` carries it through the reaction queue,
the Prisma toast, and the matching persistent Book-of-Days entry. Existing saves
pad the new journal source list before the first labelled append. The installer
validator fails when a channel label differs from its owning option. Core
reactions omit the field. The public tester artifact is one all-in-one FOMOD
with required core and all dependency-gated patch options; runtime observations
follow release, and the labelled toast plus Book entry are the tester-visible
proof that a patch fired.

**2026-08-07 AEST - release-issue reconciliation:** The live `Devotion.esp`
now includes Hircine and Molag Bal stigma notification triples and the complete
Shor T3 low-health-save presentation contract. Its current SHA-256 is
`87B04CDFFC9F0A3064CEA37D37DDAEA10C3AEEB9A4B9D3B1B515C44AE7B395B7`
(649,917 bytes). The source-side release fixes compile cleanly. This is direct
readback/static proof only; the substrate uninstall fix still requires an MCM
uninstall smoke before issue #30 or the release claim can be closed.

**2026-08-07 AEST - ARR 2.5 combined candidate deployment and winner-aware
preflight:** Installed the 84-file combined FOMOD lane as
`D:\Wabbajack\modlists\ARR 2.5\mods\Devotion - Authoria ARR Compatibility`,
enabled it on `KoK R11`, and activated `PDV_AuthoriaARR_Combined.esp`
after `Devotion.esp` / before `Requiem for the Indifferent.esp`. Profile files
were backed up to
`profiles\KoK R11\pdv-arr25-backups\20260807-070513`. Direct houseCARL asset
readback caught and corrected the MO2 priority direction: this profile's
`modlist.txt` lists the higher-priority winner first, so the compatibility mod
must appear above `Devotion - PatchHub` and `Devotion`. The runtime preflight
now resolves actual MO2 winners instead of inspecting the named core folder,
and `--expected-channels` verifies the deployed per-mod folder. The historical
combined-lane command used 154 core watches, 62 ARR watches, 34 channels, and
the now-retired `--expected-arr` argument. It is superseded by the modular
deployment command in
`references\authoring\PDV_ARR25_ModularPatchHub_ExperimentRunbook_2026-08-07.md`:
157 core watches, 39 winning channels, and no combined compatibility winner.
No post-deployment Papyrus registration marker exists yet, so runtime and
support remain open.

**2026-08-07 AEST - modular core/PatchHub replacement candidate:** The combined
Authoria lane described below is superseded. ARR now installs the ordinary
Devotion core archive plus a fully modular, dependency-gated PatchHub; no option
may replace core scripts or matrices. The committed source is `ff7fc4e`. Core is
`dist\Devotion-1.0.4-20260807.zip` (231 exact members, SHA-256
`CF7CFDBD5FC84D6B7BA5C6B4DFC697745978DA50C3290E1ED89095D41775E4DE`).
This rebuild includes the Altmer five-deity roster correction and existing-save
Book of Days repair version 3.
PatchHub is `dist\PDV-QuestModPatchHub-ARR25-Experimental-20260807.zip` (80
exact members, 41 options, 39 channels, SHA-256
`DEC5EBC4285F3985D3D8F0BDF1ADBE4F288C20FB09F3D83EA3ECD5457F633949`).
The Altmer Prisma parity gate passes 124 checks, including one notice per
accepted daily heritage practice. Machine/package proof passes; runtime-route,
player-surface, semantic, save/load, and support evidence remain open. The
living authority and experiment sequence are
`references\authoring\PDV_ModPackaging_StateAuthority.md` and
`references\authoring\PDV_ARR25_ModularPatchHub_ExperimentRunbook_2026-08-07.md`.

**2026-08-06 AEST - ARR 2.5 exhaustive content/package candidate (superseded
package architecture; historical evidence only):** The isolated
`codex/arr25-content-sweep` worktree closes the finite QUST plus selected non-quest
inventory, authors T13-T17 as 34 per-mod channels, and packages the safe non-quest
surface. `PDV_PlayerEvents` now optionally polls AFDI's 30 latched successful-
destruction globals every 15 real-time seconds through the unified scheduler;
version 1 baselines existing saves without retroactive credit and persists each
transition before routing. The package also carries exact-name ARR Green Pact KID
rules, the existing bounded bard lane, Breton Hidden Art's second renewable, and
the read-back 11-ACTI route-202 shrine-prayer ESP/BOS pair. Wyrmstooth placements
use different base forms and are not covered; Jyggalag remains classify-only;
hunting is deferred because a truthful route requires a third-party ModEvent after
the IHA corpse-token write. The validated archive is
`dist\PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip`: 95 members, no missing or
extra files, SHA-256
`E11D7B2A90ED0F980DA2394CF63A465167E55730C252EF5FF1EF05A64D0B5C9D`.
Papyrus compile is 0/0 and strict verification is `PASS=4074, TODO=1, INFO=78,
WARN=1, FAIL=0`. This moves machine/package proof only; ARR 2.5 runtime preflight,
every structured tester case, and support remain OPEN.

**2026-07-27 AEST - 1.0.4 shipped; shrine-script boundary amended and a hard MO2
priority requirement added:** Devotion 1.0.4 is public (tag `v1.0.4`,
`Devotion-1.0.4-20260727.zip`). Three things below change how this document's earlier
entries should be read.

1. **Devotion now ships a loose-file `Scripts\TempleBlessingScript.pex`.** The
   2026-06-14 and 2026-06-21 shrine-neutralization entries further down state that
   Devotion "does not replace shrine activator scripts". That wording is SUPERSEDED. The
   ESP-record half of the boundary is unchanged and still enforced - no shrine `ACTI`
   override, no script-property replacement, `pdv-shrine-blessing-author`'s
   no-ACTI-replacement check still applies - but Devotion does now ship a corrected
   compiled override of the vanilla script itself. Reason: Requiem's bugfix packs add a
   line dispelling ALL of the player's active magic effects on shrine activation, which is
   invisible under Requiem alone (its blessing lands right after) but is pure loss under
   Devotion, which grants no shrine blessing by design.
   **INSTALL REQUIREMENT: Devotion must sit BELOW (higher priority than) any Requiem
   bugfix pack in MO2.** Requiem's packs ship the same filename; if Devotion loads above
   them their copy wins and the bug returns. Nothing errors - the returning bug is the
   only symptom. Verify in MO2's **Data** tab: `Scripts\TempleBlessingScript.pex` must
   show `Devotion` as its provider. This is the project's first ordering requirement that
   is about MOD priority rather than PLUGIN load order, and the two are set in different
   MO2 panes.

2. **`Recover` on value-modifying MGEFs is now a project-wide authoring invariant.** Any
   new Devotion MGEF whose archetype modifies an actor value must carry `Recover` before
   it is written, because Devotion applies its effect families as toggled abilities and
   the engine otherwise bakes the change in permanently (reported in the field as
   `-22131%` Magic Resistance and `-5000` armour). Shipped-ESP readback on 2026-07-27:
   ValueModifier `395/395`, PeakValueModifier `232/232`, `627/627` total. Treat a missing
   flag as a save-corruption defect. The 2026-07-26 entry immediately below still owns the
   rest of the Daedric price serialization convention.

3. **Release packaging goes through `tools\pdv_package_release.mjs`, never by hand.** It
   builds the `dist\` zip from the live Anvil Devotion folder and gates on version, ANAM,
   archive contents, and a fresh live run of `pdv_release_proof_refresh.mjs --check`.
   Use the release-proof runbook and its `--capture`/confirmed `--refresh` path after any
   ESP or claimed-winner/provider change; never edit the proof snapshot just to satisfy a
   count. These gates are still NARROWER than `pdv_verify.mjs`: a green package run is not
   runtime/manual proof, and a `pdv_verify` FAIL at package time is usually real record
   drift rather than a stale audit.

Readback discipline reminder that this session paid for: confirm the active MO2 instance
with `housecarl_load_order_status` before any readback that will become a status claim.
houseCARL persists its instance across restarts, so it can still be pointed at
`D:\Wabbajack\modlists\ARR` from earlier compatibility work and will silently answer from
that list's older `Devotion.esp` - a plausible, internally consistent, completely wrong
answer rather than an error. Re-point with
`housecarl_set_mo2_instance D:\Wabbajack\modlists\Anvil`.

**2026-07-26 AEST - Daedric price serialization repair and runtime closeout:**
Daedric price contract magnitudes remain negative as player-facing semantics,
but every live price MGEF now carries `Recover, Detrimental, NoDuration,
NoArea, PowerAffectsMagnitude, NoHitEffect` and its carrier SPEL stores the
positive absolute magnitude. Direct houseCARL authoring repaired all 48 pairs
atomically after an exact ESP backup; direct readback found 48/48 corrected
pairs. `PDV_DaedricPrinceRecordContracts.json`, its generator, and
`pdv_verify.mjs` now own the convention. Post-repair in-game proof passed all
three Azura Stamina tiers (-10/-20/-30) and all three Mephala Speech tiers
(-8/-12/-15), including named Active Effects and exact Lapse restoration.
Papyrus log markers corroborate both tier ladders through 3->0. Hermaeus Mora
Champion separately passed its unique Alteration +20 / maximum Magicka +20
boon, Stamina -30 price, Active Effects, and Lapse restoration. This is
family-wide authority/readback plus representative PeakValueModifier,
ValueModifier, and multi-effect Champion runtime proof; the other 39 tiers
were not individually manually exercised.

**2026-07-15 AEST - Altmer notification and terminology consolidation:** Altmer P2 sacred-book
actions now surface one specific player-facing outcome: the generic lore fan-out remains
mechanically active but is presentation-silent, and the Trinimac reserved-signal surface is also
suppressed for P2 book reasons. A crisis transition takes precedence over the ordinary book
notice. Heritage progress is intentionally quiet except for a concise Book of Days entry when it
crosses a tier; the tier labels remain `Ordered Heritage`, `Disciplined Heritage`, and `Exemplar
Heritage`, while prose calls the underlying practice `ancestral inheritance`. Crisis copy names
`Auri-El's path` instead of an ambiguous old order. The shared Prisma substrate fallback is now
neutral grammar. Live manager/UI sources were synchronized; `PDV__ManagerQuest` and `PDV_MCM`
compiled 0 errors/0 warnings; `pdv_prisma_ui_audit.mjs` passed 121 checks after its policy contract
and cache key were updated. This is source/UI/bytecode proof only: no broad retest was requested,
and fresh in-game presentation confirmation remains open.

**2026-07-15 AEST - Main-quest full-pantheon coverage:** The complete Helgen-to-Alduin
chain is now authored as 1125 unique deity-stage reactions: 45 runtime identities across
25 exact stages on 19 quest records, with zero approved silences. T11 contributes 951 rows;
the canonical/runtime matrix is 1978 cells / 172 keys / 134 watches / 26 faucets. Stage
fields are strict integers and the retired `echo` tier is forbidden. `MQPaarthurnax` remains
outside the stage matrix; its live fork has exact 17-kill and 11-spare rosters. The watch
loader now reads PapyrusUtil lists by index so the 134 entries never cross the 128-element
Papyrus array boundary. `PDV_PlayerEvents`, `PDV__ManagerQuest`, and the companion `PDV_MCM`
compiled 0/0; Anvil and ARR core/extension JSONs were refreshed. Static/generated-readback
proof is green through `pdv_main_quest_full_coverage_audit.mjs`, including an explicit
45/45 Prisma producer-and-rendered-glyph contract with no journal-icon fallback; the
updated cache-busted Prisma view is deployed to both Anvil and ARR. Representative in-game
route, ledger-all/toast-loudest, actual overlay rendering, alias, save/load, and expanded
Paarthurnax proof remains open and fail-closed under `C-MAIN-QUEST-FULL-COVERAGE-RUNTIME` until the five
`mainQuestFullCoverageRuntime` ledger slots are evidence-recorded. Pre-T11 6-kill/4-spare
Paarthurnax waivers are revision-stamped historical evidence, not current 17/11 proof.
For controlled T11 display testing, use the Signal-floor MCM cards `MQ206 220`,
`T11: MQ101 150`, `T11: MQ105 160`, and `T11: MQ106 200 - Syrabane`; they call
the manager reaction path without mutating vanilla quests. Do not run these vanilla
main-quest stages with `setstage` from QASmoke: `MQ106` stage 200 is a shutdown stage.

**2026-07-13 AEST - Breton architecture audit and Hidden Art layered-pact repair:** Runtime co-test passed Book of Days, the Hidden Art Champion route, Prince boon, price waiver, current-pool preservation, and the controlled Mora Champion offer. Breton same-family Champion records are cumulative absolute totals and replace T2, while a distinct patron boon remains beside the lane reward. Hidden Art waives the integrated Prince price and duplicate stigma; non-Hidden-Art pacts still carry their ordinary price. Mora's tuned Champion boon is `+20 Alteration; +20 Magicka`. The new Magicka effect and all 18 Daedric Health/Magicka/Stamina price effects use `PeakValueModifier` plus `Recover`, so they alter the reversible maximum pool rather than continuously draining the current pool. Survey uses one sentence: `Your pact with Hermaeus Mora has opened Hidden Art - Champion.` The manager suppresses waived price copy, presents the combined boon mechanic, and no longer resends a successful milestone toast after the native bridge has queued it.

**2026-06-30 AEST - Requiem felt-penalty backend closeout:** The Requiem swallowed-regen penalty tail is now backend/readback clean for the active rows that should be felt as max-health penalties. Argonian Hist Distant uses `PDV_MGEF_Neglect_ArgonianHist_Health` (`Health -10`), Breton Tradition Distant uses `PDV_MGEF_Neglect_Breton_Health` (`Health -10`), and Breton Excommunication uses `PDV_SPEL_CreedLoss_Breton_Excommunication_MGEF_Health` (`Health -15`). Imperial civic neglect is intentionally preserved as `PDV_MGEF_Neglect_Imperial_Restoration` / `ResistDisease -5`. New preflight/readback command: `node .\tools\pdv_requiem_penalty_audit.mjs`; latest result `PASS=44`. The live `Devotion.esp` and `Devotion.seq` were refreshed with backups under `Backups\phase20-race-rewards\` and `Seq\`; houseCARL confirmed the converted MGEFs and zero old-regeneration spell refs on `Devotion Dev`. Proof boundary: this is authority/readback/backend smoke only. In-game Requiem Active Effects, `player.getav Health`, HP-bar movement, and manual magnitude feel remain open in `references\authoring\PDV_InGameTestingNeeded_Runbook.md`.

**2026-06-29 AEST - Prisma-first toast fallback hardening:** Transient gameplay acknowledgements are now Prisma-first through `PDV__ManagerQuest.SendPrismaToastPayloadOrFallback(...)`, which tries `PDV_PrismaBridge.SendOverlayJson(...)` and uses vanilla top-left `Debug.Notification(...)` only as fallback when Prisma is unavailable or the send fails. `ShowP2BookNotice`, shift/substrate/Daedric/event toast helpers, Daedric milestone toasts, and clear gameplay acknowledgement notices now route through that helper; raw top-left calls are limited to explicit seed/debug diagnostics and the shared fallback. `tools\pdv_prisma_toast_fallback_audit.mjs` guards the policy and the P2 book path from `PDV_PlayerEvents.OnBookRead` to `ShowP2BookNotice`, including Nord `Skyrim.esm:0ED161` / `Book1CheapNordsArise`. Proof boundary: source/audit/compile only until fresh in-game Prisma display and fallback-off-modlist tests are recorded.

**2026-07-05 AEST - Book of Days cultural cover line refresh:** The live Book of Days cover now uses manager-owned cultural summary copy plus a dynamic concise path-status line instead of the old static devotional sentence/race-only crop. `BuildBookOfDaysSummary(originRace)` owns the per-race cultural scope sentence, and `GetBookOfDaysPathStatusLabel(originRace)` reports pact, focused deity, broad lane, ancestor/Hist/lunar/life-mode/sect/tradition/crisis state as appropriate with title-cased player-facing labels. The Prisma view now renders the full normalized path status, keeps the standing gauge as the only detailed standing surface, removes the lower gauge captions, and nudges the cover copy/gauge spacing for the refined book layout. Live sync backup: `generated\live-devotion-backups\pre-sync-20260705-111604`. Proof boundary: source/UI/live deployment plus compile/audit only; fresh in-game visual smoke remains tester-owned. Gates passed: `PDV__ManagerQuest` compile 0/0, `PDV_MCM` compile 0/0, bundled verifier `FAIL=0 WARN=1`, `pdv_book_of_days_audit` `PASS=125 WARN=0 FAIL=0`, and `pdv_prisma_ui_audit` `87 checks`.

**2026-06-28 AEST - Book of Days key-close hardening:** Follow-up to the 2026-06-27 close trap. The journal is intentionally focused so ESC/X can release it, but that also means Papyrus hotkey handling may run while Skyrim is in menu mode. `PDV_MCM.OnKeyDown` now checks `PDV_PrismaBridge.IsJournalVisible()` before the menu-mode open guard, closes visible journals through `ClosePrismaJournal()`, and reconciles stale `PDV.Diegetic.Journal.Open` state after X/ESC closes. The native bridge tracks journal visibility on journal payload open, `journalClose`, and hidden-view checks. `node .\tools\pdv_prisma_ui_audit.mjs` now fails closed if this bridge/MCM ordering contract drifts. Proof boundary: compile/native build/static audit/live deployment only; fresh in-game U1 smoke still must prove key-close, X-close then key-open, ESC-close then key-open, and save/load.

**2026-06-27 AEST - Book of Days close trap fix:** A trusted Authoria tester reproduced a populated Book of Days surface that could not be dismissed by ESC or the journal hotkey, and the book had no in-view close affordance. Root cause was the journal using the unfocused overlay path while relying on a second Papyrus hotkey; the live `PDV_MCM.OnKeyDown` path also guards journal hotkeys during menu mode. `native\DevotionPrismaBridge` now treats journal overlay payloads as focused, hides/unfocuses on `journalClose`, and the Book of Days view has its own close button plus ESC handler routed through the existing native close listener. The live Anvil Devotion mod was backed up under `generated\live-devotion-backups\pre-prisma-bod-close-20260627-202954`, rebuilt with xmake, and redeployed (`DevotionPrismaBridge.dll` 414720 bytes); `node .\tools\pdv_prisma_ui_audit.mjs` still passes 13 checks. Proof boundary: build/static audit/live-file deployment only; fresh in-game U1 smoke is still required, especially on the friend's Authoria setup.

**2026-06-25 AEST - Prisma parity Unit D implementation:** Unit D copy is wired at machine/readback level. `PDV__ManagerQuest.psc` now surfaces locked offer accept/refuse Book of Days lines, refusal cue dispatch, reason-bearing commitment carryover through `AwardPiety`, Altmer committed-band reorientation, Breton startup tradition, Hircine onset/renunciation, Redguard Champion-entry, Argonian adaptation, Breton druidic fork, Bosmer path confirm, Khajiit severe lunar posture, and Altmer crisis toasts/chronicles. `PDV_DiegeticDirector.psc` preserves the Imperial/Altmer resolvers while making Khajiit quiet-emergence resolve the focused deity name. `tools\pdv-daedric-offer-title-author` updated the 16 Daedric commitment MESG titles only, with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-offer-titles\Devotion.esp.20260625-162540.bak`; `tools\pdv_prisma_parity_unitd_check.mjs` is the repeatable static/readback gate. Proof boundary: compile/readback/verifier only; in-game Prisma display/runtime proof remains owner-gated.

**2026-06-24 AEST - Redguard spine pulse + design-first Prince faucets:** The Redguard ancestor-spine accepted route now awards Tu'whacca piety through `PDV_Deity_Tuwhacca.SIGNAL_ANCESTOR_SPINE` and `PDV__ManagerQuest.HandleRedguardAncestorSpine`, closing the current sect-telemetry-only gap. The design-first Prince artifact faucet slice now uses `PDV_PlayerEvents.OnObjectEquipped` JSON-key mappers plus direct-framework FormLists authored by `tools\pdv-prince-faucet-author` for Molag Bal, Hircine, Meridia, Sheogorath, Mehrunes Dagon, and Nocturnal; Skeleton Key remains excluded. `tools\pdv_quest_matrix_compile.mjs --check` now sees 20 Part D faucet acts. Proof captured: targeted Papyrus compile 0/0, `pdv-prince-faucet-author --check` PASS, default `pdv_verify` FAIL=0/WARN=3, floor ledgers regenerated, and houseCARL readback confirmed the six FormLists are won by `Devotion.esp`. Runtime/manual proof remains open for artifact equip smoke, wrong-origin silence, Survey/status feel, and the broader quest-reaction matrix.

**2026-06-25 AEST - Authoria ARR trusted-tester package refresh:** The shareable Authoria/ARR handoff is now `dist\PDV_AuthoriaARR_TrustedTester_20260625.zip`, containing current core `PDV_FirstLook_20260625.zip`, refreshed `PDV_AuthoriaARR_Compatibility_20260625.zip`, and `PDV_Phase21_ARR_EarlyTester_README_2026-06-25.md`. Core packaging source is the live Anvil `D:\Wabbajack\modlists\Anvil\mods\Devotion` folder. The cure-only shrine replacement boundary remains in `Devotion.esp` after disabling the 15 Archon-family plugins; the separate `PDV_AuthoriaARR_Compatibility.esp` ships only the 11 Daedric shrine-prayer ACTIs used by `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`. ARR matrix package counts are `24 cells / 22 keys / 20 quests / 24 faucet acts`. Machine/readback packaging gates pass. Trusted-tester runtime smoke now also passes the ARR matrix reload (`core 73 / ARR 20`), one organic ARR quest hook (`zzzAoMMqGoodEnd` stage 255 -> Stendarr +12), Daedric shrine click/top-left feedback, same-day shrine no-double-award, and Book of Days Chronicle entry. The Prisma overlay toast did not appear and is deferred to the Prisma parity backlog. Reqtificator/RFTI regeneration on the recipient setup and Authoria maintainer acceptance remain separate open gates.

**2026-06-21 AEST - Shrine prayer presentation v2:** Shrine neutralization now owns the player-facing prayer line as well as cure-only spell normalization. `references\authoring\PDV_ShrineBlessingNeutralization.manifest.json` is schema v2 with `presentationPolicy = override-temple-blessing-message`; `tools\pdv-shrine-blessing-author` still leaves each target shrine blessing spell with one cure effect, and now also writes/checks the existing `TempleBlessingScript` / `DLC2TempleShrineScript` `BlessingMessage` records as main-ESP `MESG` overrides. This replaces vanilla-style "Blessing of <deity> added" feedback with plain prayer text such as `You pray at Talos' shrine.` without restoring ActorValue shrine boons, adding hidden notice MGEFs, or replacing shrine activator scripts. Backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\shrine-blessing-neutralization\Devotion.esp.20260621-140000.bak`. Readback proof: shrine author `--dry-run`, `--write`, and `--check` passed; default `node .\tools\pdv_verify.mjs` passed at `FAIL=0 WARN=3 TODO=0 PASS=3083 INFO=35`; houseCARL confirmed all 14 target shrine spells have one cure effect and all 14 target prayer messages win from `Devotion.esp`. Runtime/manual acceptance remains open for Talos plus one non-Talos Divine shrine and Active Effects inspection.

**2026-06-20 AEST - Nord startup gate + Requiem tail closeout:** Nord startup now uses direct `Devotion.esp` MESG records and manager VMAD wiring for `Old Ways` index 0 and `Nine Divines` index 1. `tools\pdv-startup-author` owns the three Nord startup messages. `tools\pdv-requiem-tail-author` owns the folded tail records: Shor/HoonDing hidden `PDV_T3DailyLowHealthSaveEffect` effects plus heal spells, HoonDing breakthrough boss FormList and manager `NecromancerFaction`/`WarlockFaction` properties, and Namira zero-passive/copy cleanup. Run race reward authors before this helper so `preserveAdditionalEffects` is applied and the hidden save effects are attached last. Current proof: `PDV__ManagerQuest` compile 0/0, default verifier `FAIL=0 WARN=2 PASS=3057 INFO=33`, Phase 2 reward readback `PASS=1279 WARN=0 FAIL=0`, Daedric beta gate `PASS=16`, `pdv-requiem-tail-author --check --all` PASS, and houseCARL readback of the winning records. This is not runtime/manual HP-bar, route, Survey/status, save/load, or new-game startup proof.

**2026-06-20 AEST - Ash'abah cleared-undead-site hook:** `tools\pdv-requiem-tail-author` now supports `--author-ashabah-cleared-sites`; `--all` includes it. The helper writes/checks `PDV_FLST_RedguardAshAbahUndeadClearSites` and manager VMAD property wiring directly in `Devotion.esp`. The shipped list is 43 houseCARL-confirmed clearable undead locations: draugr crypts, vampire lairs, and dragon-priest lairs with `LocTypeClearable`, excluding non-clearable/demo locations. Runtime source uses `TrackRedguardAshAbahUndeadSiteVisit(Location)` to arm an approved site while it is still uncleared, then `HandleRedguardAshAbahUndeadSiteClear(Location)` pays only if the site is approved, now cleared, armed, and not already consumed. This prevents existing saves from retroactively paying sites cleared before this build. `PDV_ActionRouter` arms new/current locations and checks old/current locations from kill and change-location paths, so the final kill can pay immediately while leaving a cleared site also catches settled-clear state. Backup: `Backups\requiem-tail\Devotion.esp.20260620-195641.bak`; SEQ backup: `Seq\Devotion.seq.20260620-095714.bak`. Proof: `PDV_ActionRouter` and `PDV__ManagerQuest` compile 0/0, `pdv-requiem-tail-author --check --all` PASS, default verifier `FAIL=0 WARN=2 PASS=3057 INFO=33`, reward readback `PASS=1279 WARN=0 FAIL=0`, and houseCARL reads FormList `071586:Devotion.esp` plus manager property slot 357. Runtime/manual proof remains in the Redguard race packet.

**2026-06-20 AEST - Ohmes-Raht / custom-race V1 support contract:** Custom races resolve into PDV's existing ten race profiles rather than adding bespoke V1 race paths. Ohmes-Raht / Half-Khajiit ships as Khajiit profile `6` through `SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json` entries for `HalfKhajiitRace` (`03322B`) and `HalfKhajiitRaceVampire` (`05693A`). Temporary beast-form races use the separate `PDV_TemporaryRaceMap.json` defer list so origin capture waits until the player reverts; they must not be mapped as permanent cultural origins. `tools\sync-devotion-to-live.ps1` copies the packaged StorageUtil JSON/README files into the live MO2 mod folder. Runtime/manual custom-race smoke remains separate from readback proof.

**2026-06-20 AEST - Book of Days Prisma recovery closeout:** The live-only Book of Days path is now part of tracked recovery state: `PDV_MCM.psc` owns the player hotkey toggle/open-state reset, `PDV__ManagerQuest.psc` builds the journal payload with a race+path-only `survey` line (`Race | Path`, rendered by Prisma as `Race - Path`), and standing remains meter-only. `native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js`/`index.html`/`styles.css` render the left-page path line and use fixed viewport math for the scaled book so the preview stays in frame on narrow viewports. The repo Prisma view was synced to live with backup `generated\live-devotion-backups\pre-sync-20260620-141135`; `PDV_MCM` and `PDV__ManagerQuest` compiled 0/0; `pdv_prisma_ui_audit` passed 13 checks; default `pdv_verify` passed `FAIL=0 WARN=3 PASS=3057 INFO=33`; and the eyeball preview artifacts live under `scratch\prisma-book-preview\`. Boundary: this is compile/verifier/UI-preview proof, not fresh in-game hotkey/runtime proof.

**2026-06-20 AEST - Live Devotion restore and primary-plugin guard:** The Anvil live mod folder was found missing its primary Devotion artifacts and was restored from `generated\live-devotion-snapshot\2026-06-15-final-polish`, then brought back to post-16 state: `PDV__ManagerQuest.psc` regenerated the small-signal table at `LIKES_DISLIKES_VERSION = 9` with 312 rows; the retired Windhelm proof records were removed through `tools\pdv-phase9-author -- --retire-windhelm-proof-records`; the Book of Days Prisma view and fonts were restored live from the current branch; the startup confirm-screen packet and D1 diegetic packet were reapplied, with `PDV_DiegeticDirector.D1Enabled = True` read back from ESP VMAD; SEQ was refreshed; scripts compiled 0/0; and default `pdv_verify` passed at `FAIL=0 WARN=2 TODO=0 PASS=3002 INFO=33`. External recovery copy: `generated\live-devotion-backups\post-restore-20260620-105204`; Prisma restore backup: `generated\live-devotion-backups\pre-prisma-restore-20260620-110158`. `tools\sync-devotion-to-live.ps1` now fail-closes if the live mod folder lacks `Devotion.esp` or looks damaged, takes a pre-sync backup of primary artifacts, includes the Book of Days font assets, excludes untracked scratch Papyrus by default, and must never create an empty replacement for the main mod folder. Boundary: the current `pdv_book_of_days_audit.mjs` proves UI hash parity but still fails the expanded journal-history Papyrus contract; that source is not present in current Git history and was not invented during restore.

**2026-06-17 AEST - Trusted first-look cleanup issues resolved:** The first-look log/property and Windhelm visible-proof-surface issues are closed after machine cleanup plus tester confirmation. Redguard stale manager VMAD properties for removed `*_NeglectTexture` props were pruned from `Devotion.esp`; the hidden Talos receiver override on `10753E:Skyrim.esm` was retired so the vanilla shrine reference wins; and the five Phase 9 Bosmer Windhelm proof ACTI/REFR records plus the `Devotion.esp` `WindhelmTempleofTalos` cell override were removed so Lux wins the cell again. Backups: `Backups\vmad-stale-property-prune\Devotion.esp.20260616-214622.bak`, `Backups\windhelm-hidden-talos-cleanup\Devotion.esp.20260616-220104.bak`, and `Backups\bosmer-windhelm-signal-cleanup\Devotion.esp.20260616-224337.bak`. Evidence: houseCARL readback shows the retired Talos/Bosmer records absent and `WindhelmTempleofTalos` won by `Lux.esp`; `pdv_refresh_seq --write --json` passes with `changed=false questCount=39`; default `pdv_verify --json` passes at `PASS=2990 WARN=2 INFO=47`; `tools\pdv-phase9-author -- --check-placements` passes the retired-record absence check. User retest on 2026-06-17 reported fixed.

**2026-06-15 AEST - Mod identity rename to Devotion:** Public mod identity and the active framework plugin are now `Devotion` / `Devotion.esp`. The live Anvil mod file was renamed from `PlayerDevotion_Framework.esp` to `Devotion.esp`, the SEQ file from `PlayerDevotion_Framework.seq` to `Devotion.seq`, and the Devotion Dev profile now loads `*Devotion.esp`. Rename backups are under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\rename-devotion\`. Internal `PDV_` script/record identifiers and existing data paths such as `SKSE\Plugins\StorageUtilData\PlayerDevotion\` remain intentionally unchanged to avoid save/data churn. Proof is machine/readback only: the renamed scripts compile 0/0, default `pdv_verify --json` passes at `PASS=3028 WARN=2 INFO=45`, `pdv_refresh_seq --write --json` passes with `changed=false questCount=39`, and `pdv_daedric_test_readiness --deep --json` passes at `PASS=71`. Runtime/manual beta proof remains separate.

**2026-07-09 AEST - Green Pact plant-food baseline readback closeout:** houseCARL review of the ARR Authoria/Requiem setup found the Bosmer food rule is not broad keyword tagging: `Requiem - Food and Beverages Redone` attaches Green Pact behavior to Bosmer through a race effect and a curated `Apo_BosmerExclusionFoods` FormList of earthborn foods. PDV now mirrors that conservative pattern for base/DLC plant foods only: `tools\pdv-phase20-p2-receiver-author --author-green-pact` fills `PDV_FLST_GreenPact_PlantFoods` with the 25 non-Requiem FormKeys, `--check-green-pact` fails if any baseline entry is missing, and `pdv_phase2_reward_readback_audit.mjs` now checks the same baseline. Live write backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\Devotion.esp.20260709-135850.bak`. Proof boundary: ESP/readback and static source-path proof only; no new Papyrus compile was needed because `PDV_PlayerEvents.RouteBosmerGreenPactFood` and OldContract-gated `HandleGreenPactViolation` were already present. Runtime consumption proof and full expansion for potions, ingredients, firewood/lumber, flora harvests, and mod-added food KID curation remain open. The broad reward readback audit now passes the Green Pact baseline but still has unrelated Breton reward-record failures.

**2026-07-09 AEST - Bosmer Y'ffre green-site fanout source implementation:** `PDV__ManagerQuest.HandleBosmerLocationChange` now dispatches the signal-floor location-site surface requested in `PDV_SignalFloor_DeepDive_ConsolidatedCodexHandoff_2026-07-09.md`. New per-site StorageUtil keys live under `PDV.Yffre.Seen.*` with `PDV.Yffre.SiteCount`, `PDV.Yffre.LastSite`, and a shared once/day cap `PDV.Signal.YffreGreenSite`; successful sites route through the existing `HandleBosmerLivingStoryNatureSite(...)` evidence/signal path. Covered sites are Eldergleam, Gildergreen, Ancestor Glade, All-Maker Wind/Water/Sun/Earth/Beast, and All-Maker Tree. Tree Stone uses `DLC2TempleOfMiraakLocation` only to arm a proximity poll and awards near `DLC2StandingStoneTreeREF`, because houseCARL readback found no dedicated `DLC2StoneTreeLocation`. Source was synced to the live Anvil Devotion source and compiled: `PDV__ManagerQuest` 0 errors / 0 warnings, verifier `FAIL=0 WARN=2 TODO=0 PASS=3546 INFO=68`. Proof boundary: source/compile/verifier only; no in-game location-change smoke has run.

**2026-07-09 AEST - Generalized crypt-cleared signal implementation:** The signal-floor G2 handoff item was found to be spec-only from the prior pass: the matrix/docs mentioned the generalized crypt-cleared signal, but live source and `Devotion.esp` only had the Redguard Ash'abah-specific cleared-site hook. The generic layer is now built. `PDV__ManagerQuest.psc` declares `PDV_FLST_UndeadCryptClearSites`, arms approved uncleared locations with `TrackUndeadCryptClearSiteVisit(Location)`, consumes each cleared site once with `HandleUndeadCryptSiteClear(Location)`, and decays same-day repeats through `PDV.Signal.UndeadCryptClear`. `PDV_ActionRouter.psc` calls the generic arm/check pair from both kill and change-location paths. The fanout is quiet source/driver scoring at `small` tier: Arkay/Meridia C, Stendarr/Tu'whacca S, Azura/Y'ffre m, with quest-reaction stance and reachability rules preserved. `tools\pdv-requiem-tail-author` now supports `--author-undead-crypt-clear-sites`; `--check --all` verifies `PDV_FLST_UndeadCryptClearSites` as `07165E:Devotion.esp` with the same 43 curated undead locations as the Redguard list and a manager VMAD property pointing to it. Source was synced to the live Anvil Devotion source; `tools\sync-devotion-to-live.ps1` now maps `PDV__ManagerQuest.psc` and `PDV_ActionRouter.psc` so this source-copy step is repeatable. Backups: ESP `Backups\requiem-tail\Devotion.esp.20260709-154225.bak`, live source `generated\live-devotion-backups\pre-crypt-clear-source-sync-20260709-154413`, SEQ `Seq\Devotion.seq.20260709-054554.bak`. Proof: `PDV__ManagerQuest` and `PDV_ActionRouter` compile 0/0 from live source, `pdv-requiem-tail-author --check --all` PASS, SEQ refresh `changed=false`, and default verifier `FAIL=0 WARN=1 TODO=0 PASS=3546 INFO=68` with only the existing medallion glyph fallback warning. Runtime/manual crypt-clear proof remains open.

**2026-07-09 AEST - Signal-floor master closeout + Paarthurnax kill/spare fork:** Follow-up to `references\authoring\PDV_SignalFloor_MasterHandoff_2026-07-09.md`. Crypt-clear FormList population is verified with `pdv-requiem-tail-author --author-undead-crypt-clear-sites --check` (property points at `07165E:Devotion.esp`; list check PASS). The Paarthurnax KILL branch is now global instead of Khajiit-only: `PDV_PlayerEvents.IsPaarthurnaxActor(...)` runs before the origin gate, `PDV_EventBus.RoutePaarthurnaxKill(Form)` calls `PDV__ManagerQuest.HandlePaarthurnaxKill(Form, String)`, and the manager stores `PDV.Paarthurnax.KillSeen` before sending one-shot Shor, Tsun, Kyne, Stendarr, Stuhn, and Mara losses through existing quest-reaction stance/reachability rules. Khajiit origin players still receive the existing Alkosh chaos-aid consequence. The Paarthurnax SPARE branch is now also V1 source-wired: `MQ305` stage 200 and load-time catchup check `Paarthurnax.GetDeadCount() == 0`, then `RoutePaarthurnaxSpare` / `HandlePaarthurnaxSpare` stores `PDV.Paarthurnax.SpareSeen` and sends Stuhn, Stendarr, Mara, and Kyne gains through the same stance/reachability rules. `tools\sync-devotion-to-live.ps1` now also maps `PDV_EventBus.psc` and `PDV_PlayerEvents.psc`; live source backups include `generated\live-devotion-backups\pre-sync-20260709-163637` and `generated\live-devotion-backups\pre-sync-20260709-165239`. Proof: `PDV_PlayerEvents`, `PDV_EventBus`, and `PDV__ManagerQuest` compile 0/0; default verifier `FAIL=0 WARN=1 TODO=0 PASS=3546 INFO=68`; matrix compile PASS at 1071 cells / 169 quest keys / 135 watched quests / 26 faucet acts; adversary check PASS with the expected thin-Hist warning; formal-offer PASS; dislike-consequence audit PASS. Runtime/manual proof for crypt-clear, plant consumption, Paarthurnax kill/spare, and the wider signal-floor smoke matrix remains open.

**2026-07-05 AEST - AddToPlayer generic faucet receiver closeout:** `tools\pdv-phase20-p2-receiver-author` now includes the generic `PDV__SM_AddToPlayer` QUST and `PDV__SM_AddToPlayerNode` Story Manager node under vanilla `PlayerAddItem` root `02C439:Skyrim.esm`. Live writes succeeded after Skyrim released `Devotion.esp`, with backups `Backups\phase20-p2-receivers\Devotion.esp.20260705-092142.bak` and `Devotion.esp.20260705-092146.bak`; focused receiver and Story Manager checks pass, and `pdv_verify --strict-phase3` reports `FAIL=0`, `TODO=0`. Proof boundary: compile/readback/strict-gate only. Runtime proof for `362` must steal an owned loose/container item, not pickpocket, and record either `[PDV] EventBus: RouteAction complete: event 362` or an advanced `PDV.Meta.LastTheftTime` timestamp; a deity delta is optional because the Nocturnal meta-faucet consumes the timestamp.

**2026-06-14 AEST - Authoria ARR Phase 21 package evidence:** ARR is now at local `patch-packaging` evidence for the shrine replacement slice. The test profile is `D:\Wabbajack\modlists\ARR`, profile `Authoria - Requiem Reforged - Main Profile`, with `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test` junctioned to the Anvil Devotion mod. Profile backups are under `D:\Wabbajack\modlists\ARR\profiles\Authoria - Requiem Reforged - Main Profile\pdv-authoria-backups`, stamp `20260614-224145`. Live profile inspection found 15 Archon-family plugin lines, not the provisional 16; all 15 are disabled locally, and `Devotion.esp` loads before `Requiem for the Indifferent.esp`. houseCARL two-sided readback confirmed all 14 shrine blessing spells now win from `Devotion.esp`, with Requiem as middle-layer input and the Dragonborn Good Daedra altar spells preserving `PDV_MGEF_DunmerShrineCure` / `PDV_DunmerShrinePrayerEffect`. No standalone `PDV_AuthoriaARR_Compatibility.esp` was emitted for this proven slice because no extra ARR override is needed; the name remains reserved for future approved route adapters. Reward specs/contracts match the Requiem retune (`DamageResist` 15/30/50, Orc T1 = 15). Package docs: `references\authoring\PDV_Phase21_ARR_CompatibilityPackage.manifest.json`, `references\authoring\PDV_Phase21_ARR_AuthorHandoff.md`, and `references\authoring\PDV_Phase21_ARR_PapyrusOptimizationReview.md`. Runtime/manual ARR smoke and Authoria acceptance remain open.

**2026-06-14 AEST - Vanilla/DLC shrine blessing normalization:** `references\authoring\PDV_ShrineBlessingNeutralization.manifest.json` and `tools\pdv-shrine-blessing-author` now own the vanilla/DLC clickable shrine normalization pass. The helper discovers activators using `TempleBlessingScript` / `DLC2TempleShrineScript`, resolves their `TempleBlessing` spell property, and writes only approved cure-only `SPEL` overrides into `Devotion.esp`; it does not replace shrine activator scripts. The live framework now has 14 cure-only blessing overrides for the Divines/Talos/Nocturnal/Auriel/Dragonborn Reclamation shrine spells, with Lux Via and Nocturnal shrine activators covered through their reused normalized spells. The Azura/Boethiah/Mephala Dragonborn altar spells use `PDV_MGEF_DunmerShrineCure` (`071554:Devotion.esp`), a CureDisease effect with `PDV_DunmerShrinePrayerEffect`, so they can still trigger the Dunmer outdoor-shrine route while stripping vanilla stat boons. Backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\shrine-blessing-neutralization\Devotion.esp.20260614-204741.bak`. Readback proof: `dotnet run --project .\tools\pdv-shrine-blessing-author -- --discover`, `--dry-run`, `--write`, and `--check` passed; latest follow-up `--check` passed at `2026-06-14 20:52 AEST`; default `node .\tools\pdv_verify.mjs --json` passed at `FAIL=0 WARN=2 PASS=3039 INFO=42` and checks the manifest, target count, cure-only effects, and no-ACTI-replacement boundary. Runtime/manual proof remains open for disease cure, Dragonborn Good Daedra shrine routing via `PDV_DunmerShrinePrayerEffect`, and Active Effects inspection.

**2026-06-14 AEST - ESP authoring closeout and pre-beta cleanup:** The post-shrine closeout refreshed the all-ten-race Phase 20 reward records through `tools\pdv-phase20-race-author` after Skyrim/Anvil released the framework ESP lock. All ten specs passed dry-run, live write, and `--check-rewards`; framework backups were written under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\`, ending with `Devotion.esp.20260614-211759.bak`, and `pdv_refresh_seq --write` confirmed the 39-quest SEQ set was unchanged. P2 source-authority drift is resolved: `PDV_Phase20_P2ImmersiveReceivers.manifest.json` now treats only Altmer `MQ104` stage 160 and Bosmer `DA05` stages 100/105 as approved quest-stage live-fill groups, while Khajiit route metadata remains blocked until source-fill ledger approval. `tools\pdv-phase20-p2-receiver-author --check-route-entries` now recognizes the live grouped `ShouldRouteP2QuestStageGroup(...)` pattern as well as direct route calls. Bosmer and Argonian beta packets now include explicit edge-build sections, stale/noisy reward readback is superseded by the current reward checks, paired-deity warnings were reviewed as non-blocking, and `references\authoring\PDV_CompletenessGapLedger_Triage_2026-06-14.md` records the completeness-ledger classifications. Follow-up source closeout closed `BC-0024` and `BC-0028`: `PDV__ManagerQuest.RunDawnAwardAltmerAuriElDawn` routes the once-per-dawn Altmer Auri-El foundation signal before dawn consolidation, and `PDV_ActionRouter.HandleStoryIncreaseSkill` forwards the skill name to `PDV__ManagerQuest.HandleAltmerMagicSkillIncrease`, which routes one-time Altmer magic thresholds through Magnus `SIGNAL_MAGIC_MILESTONE`; `tools\pdv_completeness_audit.mjs` recognizes `AwardCuratedSignalScaled`, drift aliases, and the corrected Part B parser, producing completeness `PASS=360 GAP-REVIEW=54`. Follow-up non-runtime rebaseline now indexes repo data docs/manifests for `verify_layer=data`, aliases stale reward `PDV_MGEF_Bless_*` rows to live effect families, and classifies explicit deferred/expected-absent rows without converting them into live work; generated completeness is `PASS=389 GAP-REVIEW=24 NEEDS-MANUAL=293 FUTURE=60 WAIVED=2` with no hard `GAP`. The remaining 24 generated review rows are grouped as source route/probe, trigger top-up, Daedric exposure, formal state/curse, and copy/surfacing backlog classes rather than open one-row ESP blockers. Automated closeout proof: all ten reward checks pass, `pdv_phase2_reward_readback_audit` passes at `PASS=1291`, P2 source/exact-stage/route checks pass, Daedric beta/readiness gates pass, `pdv_content_verify` passes, and strict `pdv_beta_readiness_audit` is blocked only by race manual/runtime evidence plus the dependent release-boundary claim. This is machine/readback/doc proof only, not runtime/manual or final-placement proof.

**2026-06-14 AEST - Dunmer Layer-2 werewolf weighting:** The live manager now implements `GetDunmerCurseLayerWeight(2)` as 0.75x only under werewolf posture for Good Daedra Layer-2 piety, while preserving vampire Layer-2 pressure at 1.0 and the existing Layer-1 vampire 0x / werewolf 0.5x rule. The new `AwardCuratedSignalScaled(...)` helper is used only for Dunmer Reclamation focus and the Good Daedra memory pulse from portable-shrine/home routes. Backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\dunmer-layer2-werewolf\PDV__ManagerQuest.psc.20260614-162320.bak`. Proof is compile/readback only: `PDV__ManagerQuest` compile 0/0, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, `pdv_writer_review` exit 0, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`. Grey Quarter and dawn/dusk Dunmer follow-ups plus runtime/manual proof remain open.

**2026-06-14 AEST - Orc oath-break source route:** Malacath now owns `SIGNAL_OATH_BREAK = 2253` with `DELTA_OATH_BREAK = -1.5`; `PDV_EventTypes` exposes `EVT_ORC_OATH_BREAK = 74`, `PDV_EventBus` exposes `RouteOrcOathBreak(sourceId)`, the manager exposes `HandleOrcOathBreak(reason)` / `AwardOrcOathBreakSignal()` with storage breadcrumbs for future proof, and both reusable receivers can route `ROUTE_ORC_OATH_BREAK = 74` into EventBus. Backups: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\orc-oath-break\*.20260614-162930.bak`, plus deployed receiver backups `PDV_EventSignalActivator.psc.20260614-164338.bak` and `PDV_EventSignalEffect.psc.20260614-164338.bak`. Proof is source/compile/verifier only: `PDV_Deity_Malacath`, `PDV_EventTypes`, `PDV_EventBus`, `PDV__ManagerQuest`, `PDV_EventSignalActivator`, and `PDV_EventSignalEffect` compile 0/0; default `pdv_verify` now guards the EventTypes/EventBus/manager/Malacath/receiver snippets and passes at `FAIL=0 WARN=2 TODO=0 PASS=2989 INFO=43`; `pdv_content_verify` stays `FAIL=0 WARN=0 PASS=1080 INFO=4`. Exact vanilla quest/failure emitters and runtime/manual proof remain open.

**2026-06-14 AEST - Orc Witnessed first record tranche:** `PDV_OrcRewardRecords.spec.json` now includes and readback-verifies Trial of Iron support spells (`PDV_SPEL_Orc_TrialOfIron_Tusk` / `_Shield` / `_Hammer` / `_Yoke`), The Watchers mode-split MESG notices, and Hearth-Held support spell + declare/return/missed-cadence MESG notices. The deployed manager declares matching Spell/Message properties and compiles 0/0. ESP backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\Devotion.esp.20260614-165115.bak`; manager-source backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\orc-witnessed-record-prep\PDV__ManagerQuest.psc.20260614-164915.bak`. Proof is record/source/readback only: Orc `--check-rewards` PASS, default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2989 INFO=43`, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, and `pdv_refresh_seq --check` still sees the same 39 SGE quests. Trial-of-Iron/Watchers/Hearth-Held runtime behavior and Four Holds remain follow-up work.

**2026-06-14 AEST - Orc Four Holds route/message tranche:** Four Holds now uses StorageUtil one-shot keys instead of a full state enum. Source route 75 is compile/verifier-clean through `PDV_EventTypes`, `PDV_EventBus.RouteOrcFourHoldsVisit`, both reusable signal receivers, `PDV_Deity_Malacath.SIGNAL_FOUR_HOLDS_VISIT = 2208`, and `PDV__ManagerQuest.HandleOrcFourHoldsVisit`. `PDV_OrcRewardRecords.spec.json` now readback-verifies four hold notifications plus `PDV_Msg_Orc_FourHolds_Milestone`, all wired on the manager. Backups: source `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\orc-four-holds-source\*.20260614-165431.bak`; ESP `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\Devotion.esp.20260614-165810.bak`; SEQ `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260614-065950.bak`. Proof is source/compile/readback only: touched scripts compile 0/0, Orc `--check-rewards` PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, `pdv_writer_review` regenerated, `pdv_refresh_seq --write` wrote the unchanged 39 SGE quest set, and default `pdv_verify` passes at `FAIL=0 WARN=2 TODO=0 PASS=3003 INFO=43`. Final-world ChangeLocation emitters, route runtime proof, and manual feel remain open.

**2026-06-14 AEST - Orc Four Holds QASmoke proof harness:** The Orc implementation manifest now includes four additional Four Holds proof ACTIs/REFRs (`PDV_ACTI_OrcFourHolds_*Signal` / `PDV_REFR_OrcFourHolds_*Signal`) for Dushnikh Yal, Mor Khazgur, Narzulbur, and Largashbur, bringing Orc's QASmoke proof surface to eight refs and the Phase 20 helper's current scope to 34 refs. The route-checker knows the four new route 75 markers and expected manager notices. Backups: ACTI ESP `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-orc\Devotion.esp.20260614-170457.bak`; REFR ESP `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-proof-placements\Devotion.esp.20260614-170503.bak`; SEQ `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260614-070658.bak`. Proof is QASmoke placement/readback only: Orc `--check-placements` PASS, proof-placement `--check-placements --manifest Orc` PASS, default proof-placement `--check-placements` PASS across 34 refs, Orc `--check-rewards` PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=3031 INFO=43`. Four Holds runtime activation, final-world stronghold arrival emitters, and manual feel remain open.

**2026-06-14 AEST - Dunmer portable-prayer twilight window:** Azura now owns `SIGNAL_DUNMER_TWILIGHT_RITE = 704` with `DELTA_DUNMER_TWILIGHT_RITE = 0.25`. The manager calls `TryAwardDunmerTwilightWindowSignal(reason)` from `HandleDunmerPortableShrinePrayer`, awarding once per dawn window (06:00-09:00) and once per dusk window (18:00-21:00) per day via `PDV.Signal.DunmerTwilight.<Window>.Day`. Backups: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\dunmer-twilight-window\*.20260614-163414.bak`. `PDV_Deity_Azura` and `PDV__ManagerQuest` compile 0/0. The verifier initially exposed stale SEQ after the current ESP wave; `pdv_refresh_seq --write` refreshed 39 SGE quests with backup `Seq\Devotion.seq.20260614-063540.bak`. Final readback boundary: default `pdv_verify` now guards the manager/Azura source snippets and passes at `FAIL=0 WARN=2 TODO=0 PASS=2979 INFO=43`; `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`. Outdoor Good Daedra shrine activation and runtime/manual proof remain open.

**2026-06-14 AEST - Shared below-20% hook and support records:** The low-health combat-session path is no longer Bosmer-only. Live `PDV_PlayerEvents.psc` opens one combat session for Bosmer, Khajiit, Argonian, and Orc; routes the first below-20% health dip through `PDV_EventBus.RoutePlayerBelowHealthGate`; preserves Khajiit's existing near-fatal/outnumbered session handling; and routes Orc's survived-combat payout through `RoutePlayerBelowHealthSurvived` on combat exit. `PDV__ManagerQuest.psc` fans the shared gate to Bosmer Baan Dar Gap, Argonian Sithis T3 near-death burst, and Orc Code Holds. `tools\pdv-phase20-race-author` now supports opt-in timed FireAndForget support spells via spec fields `duration`, `spellType`, and `castType`, defaulting all existing reward entries to the previous Ability/ConstantEffect shape. New/readback-clean records are `PDV_Bless_Argonian_Sithis_T3`, `PDV_SPEL_ArgonianSithisNearDeathBurst`, `PDV_SPEL_OrcCodeHolds`, and `PDV_SPEL_OrcCodeHolds_Devoted`. Backups: source `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\below-health-shared-hook\*.20260614-155641.bak`; ESP `...\Backups\phase20-race-rewards\Devotion.esp.20260614-160145.bak` and `...\Devotion.esp.20260614-160152.bak`; SEQ `...\Seq\Devotion.seq.20260614-060254.bak`. Proof is compile/readback only: manager/EventBus/PlayerEvents compile 0/0; Argonian and Orc reward-spec readbacks PASS; `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`; default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`; `pdv_completeness_audit` `PASS=337`, `GAP-REVIEW=77`. Runtime/manual proof of the burst/survival payout remains open.

**2026-06-14 AEST - Redguard Far Shores V1 contract cleanup:** Reconciled stale inventory-object/private-home wording to the live V1 route. `BC-0118` now checks the routed Far Shores token proof surface (`PDV_ACTI_RedguardFarShoresTokenSignal` / `PDV_REFR_RedguardFarShoresTokenSignal`, route 83) plus `PDV.Redguard.FarShoresToken` storage proof; the support spell remains unconditional V1 and no private/home bonus ships. `PDV_NextBuildPass_RecordSpec.md`, `PDV_RaceDesign_Redguard.md`, and `PDV_PreBetaRaceScalingSpine.md` now match. Comment drift in live `PDV_Deity_Tuwhacca.psc` was backed up at `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\redguard-far-shores-docsync\PDV_Deity_Tuwhacca.psc.20260614-161756.bak` and recompiled cleanly. Dawnguard cure-vampire remains exact-source routing only: generic cure already drives Redguard Tu'whacca re-entry, while Ash'abah burden requires a readback-approved quest/stage before `PDV_FLST_P2_RedguardAshAbahSources` fill.

**2026-06-14 AEST - Doc sync for completeness ledger rebaseline:** Observed the generated completeness ledgers at `PASS=335`, `GAP-REVIEW=79`, and ESP detail coverage at 1481 records. Khajiit rows `BC-0574`, `BC-0575`, and `BC-0576` are now generated-ledger PASS based on source reachability/readability, while `BC-0672` remains narrowed to the missing `PDV_Msg_Khajiit_ShadowDriftEntry` detail. No generated ledger, source script, PEX, or ESP records were edited in this sync. Verification rerun: `node .\tools\pdv_verify.mjs --json` returned `FAIL=0`, `WARN=3`, `INFO=34`; treat this as doc/ledger status, not new in-game proof.

**2026-06-13 AEST - Bosmer runtime fixes and reward ESP refresh:** Bosmer DA05 stage 100/105, wrong-origin rejection, generic-source silence, Old Contract threshold snapshot, Living Story rewards, Exchange mechanics, and Green Dreams now have tester evidence recorded in the Bosmer packet/ledgers. Runtime fixes landed in the live manager source and PEX: Bosmer hearth declaration is path-neutral like Argonian bed declaration, Tale Carried remains Living Story-only, and Baan Dar Gap uses the shared Khajiit/Bosmer combat-session poll instead of a direct low-health hit hook. `tools\pdv-phase20-race-author` now writes regen actor values (`HealRate`, `MagickaRate`, `StaminaRate`, and `*RateMult`) as PeakValueModifier effects while keeping ordinary skill/resist AVs as ValueModifier. The live Bosmer reward write refreshed Exchange T1/T2 copy to name `Z'en` and rewrote `The Path Goes Quiet` as PeakValueModifier StaminaRateMult -5. ESP backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\Devotion.esp.20260613-181508.bak`; SEQ backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260613-081520.bak`. Closeout verifier: `node .\tools\pdv_verify.mjs` `FAIL=0 WARN=2 PASS=2938 INFO=34`; targeted readback confirmed the Bosmer stamina archetype and Z'en copy. Handoff: `references\authoring\PDV_SessionHandoff_BosmerRuntimeFixes.md`.

**2026-06-12 AEST - Completeness/readback closure slice:** Closed the three real `pdv_completeness_audit` hard gaps without claiming Daedric beta proof. Redguard Far Shores is now an unconditional V1 support spell/effect (`PDV_Bless_Redguard_FarShoresToken` + `PDV_MGEF_Redguard_FarShoresToken_Magic`, +5% Magic Resistance) with the private/home promise removed from contracts and content rows. Redguard V1 sect, Survey, champion-entry, token, and curse-state message records are authored and manager-wired; the old `PrivateContext` row is deferred. Breton now has `PDV_State_BretonDruidicFork` + `PDV_GLO_State_BretonDruidicFork` with enum `None=0/Druidic=1/Werewolf=2/Betrayed=3`, manager mirror helpers, Green Way reward gating on the Druidic fork state, and Betrayed creed-loss spell sync. `tools\pdv-phase20-race-author` now handles opt-in support spells, state-track/global mirrors, and message records. Orc reward readback naming drift is fixed by explicit spec EditorIDs for the five live `Speech`/`BlockSkill` MGEFs. The cumulative-rebalance stamp wording now says the current values are absolute tier values; no magnitude retune happened. Live manager compile passed 0/0, framework ESP backups were `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\Devotion.esp.20260612-091535.bak` and `...\Devotion.esp.20260612-091542.bak`, and SEQ backup was `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260611-231749.bak`. Closeout: completeness `PASS` with no GAP bucket, strict race-costing `PASS=2933 WARN=2 INFO=34`, Phase 2 reward readback `PASS=1280`, cumulative dry-run skips all 9 stamped specs. Manual/runtime proof for Daedric display slots and stack legibility remains pending.

**2026-06-11 AEST - Hircine display-surface drift and SEQ/audit hygiene:** `PDV_DaedricPath_Hircine.psc` keeps its Phase 13 hunt/residue path but now declares the standard all-Prince display/control properties and proof helpers already wired in the ESP, including per-race responses, exit/lapse/neglect texture messages, and controlled-signal deltas. Compiled `PDV_DaedricPath_Hircine` with 0 errors/0 warnings; refreshed `Devotion.seq` with 39 SGE quests and backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260611-094346.bak`; default verifier is `FAIL=0, WARN=2`. The same pass normalized Orc spec ActorValues to `Speechcraft`/`Block`, deleted `generated/_contract_raw.json`, and made completeness-ledger output ASCII-safe. The completeness audit still fails closed on the same adjudication-required Redguard/Breton hard gaps.

**2026-06-10 - Generic faucet FormList content helper:** `tools\pdv-phase20-p2-receiver-author` now owns the exact vanilla content fill for `PDV_FLST_FaucetSkillBooks`, `PDV_FLST_FaucetSpellTomes`, `PDV_FLST_FaucetRaiseUndeadEffects`, and `PDV_FLST_FaucetDaedricArtifacts` through `--fill-generic-faucets` and `--check-generic-faucet-fill`. The fill gates events `340/341/365/368` and uses the corrected Sneak skill-book FormIDs plus Ebony Mail. Live fill completed with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\Devotion.esp.20260610-191400.bak`; readback exact counts are `90/93/8/19`. If a future write fails with `Devotion.esp` in use, close the external process holding the Devotion mod folder, then rerun fill followed by the check.

**2026-05-30 - Phase 20/21 order flip:** Phase 20 is now the full roster/content lock and Phase 21 is the Authoria-first compatibility package lane. Compatibility testing waits until Phase 20 stabilizes the complete mod surface. `--strict-phase20-roster` is canonical; `--strict-phase21-roster` remains accepted as a temporary alias.

**2026-05-30 - Phase 20 full roster architecture lock:** The old 1.0 target of 25-35 deities and 8-12 Daedric paths is retired. Phase 20 now requires every locked race-architecture god and all sixteen Skyrim-present Daedric Prince surfaces to be content-ready for every race. `references\authoring\PDV_DeityCoverageMatrix.json` is the roster authority, and Jyggalag remains excluded unless future adopted content explicitly adds him.

**2026-05-28 - Phase 21 compatibility rebaseline (renumbered 2026-05-30):** Compatibility targets Authoria-first list-author packages instead of a Sacrosanct-first standalone compat patch. The target set is Authoria/ARR plus JOJ, TOT, HOH, MOM, DoD, and VOV. The tracked source of truth is `references\vanilla-gameplay\compatibility\phase20-targets.csv` plus `PDV_Phase20_CompatibilityNotes.md`. Authoria is the 1.0 compatibility gate via accepted integration/test package; the other six lists should reach `patch-packaged`. Package policy: replace the active religion overhaul and direct dependent religion patches, ship one list-specific ESL-first patch with minimal masters, do not edit list-owned plugins, let Requiem authors regenerate final RFTI/Reqtificator output, and hold public support claims until list inclusion/support status is reached.

**2026-05-28 - Phase 17 decay runtime closeout:** Phase 17 is runtime-proven. The counted pass covered grace no-op (`20.00 -> 20.00`), eligible decay (`20.00 -> 19.50`), same-day guard (`19.50` held), broad worship reduced decay (`20.00 -> 19.90`), active-patron skip, non-patron drift while Kyne stayed protected, Devoted floor (`50.00 -> 10.00`), and Champion floor (`150.00 -> 50.00`). The Phase 16 regression pass also held: broad worship suppressed neglect (`count=0; kyneSpell=0`) and active Kyne produced targeted neglect (`count=1; active=Kyne; kyneSpell=1`). Runtime proof exposed and fixed two manager gaps: fresh-save eligible proof timestamps could be negative, and tier floors needed persistent `PDV.PassiveDecayFloor` storage. The bridge ladder is clean at `FAIL=0, WARN=1, PASS=1155, INFO=29`, with only expected `SEQ freshness`.

**2026-05-23 - CKRA GLOB duplicate-create proof:** `glob.duplicate_create` is now the first narrow CKPE authoring capability promoted by proof ledger. Evidence chain: guarded Object Window duplicate replay, GLOB duplicate identity, in-memory FNAM/FLTV mutation to short `1`, CK UI save, direct saved-ESP readback, strict run report, strict proof ledger, and generated capability-matrix promotion. User-experience lesson: Object Window selection/focus/context-menu behavior is not incidental; CK automation must either reproduce or explicitly guard it. Lower-layer lesson: live memory proof is insufficient without active-plugin save and filesystem readback. This is generated-plugin infrastructure only and does not change PDV runtime phase status.

**2026-05-21 - Phase 8 runtime proof closeout and overlay lesson:** Phase 8's Imperial Concordat pilot is now runtime-proven end to end on an Imperial save. Baseline `Uncommitted`, pending start/cancel, 3-day commit into `PublicCompliant`, committed-state multiplier persistence under raw rollback, 3-day commit into `ConcordatEnforcer`, halved inward movement while the extreme gate was locked, save/load persistence before and after gate unlock, and 3-day exit back to `PublicCompliant` all passed. `tools\pdv_verify.mjs --strict-phase8` is now part of the live closeout ladder, and the combined compile+verify gate stayed fully clean at `FAIL=0, WARN=0, TODO=0, PASS=642, INFO=28` on 2026-05-20 20:20:45 AEST. Durable lesson: `PDV_Phase8ConcordatTalosOverlay.esp` should not be treated as the steady-state runtime wiring path; partial VMAD overrides can win with blank/default Talos values. The live fix is manager-owned runtime wiring plus save-healing in `PDV__ManagerQuest`, and the overlay should remain inactive unless it is explicitly rebuilt as a full safe override.

**2026-05-09 -- Framework vs. Monolithic:** One core ESP owns the quest spine and globals. Nine race ESPs patch in as modules.

**2026-05-09 -- Dawn detection:** `RegisterForUpdateGameTime(1.0)` with hour-window check. Chosen over Story Manager dawn event for reliability.

**2026-05-09 -- Bootstrap / Manager quest split:** `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (Start-Game-Enabled runtime). Runtime owns the mirror globals API and the dawn consolidation loop.

**2026-05-09 -- Naming taxonomy:** Internal/machinery records prefixed `PDV__X`; runtime Globals prefixed `PDV_GLO_X`; internal/system Globals prefixed `PDV_GLO__X`. See Section  EditorID Prefix Convention above.

**2026-05-10 -- Variable storage (v2):** StorageUtil (PapyrusUtil SE) is source of truth for all per-deity piety/tier values, keyed by deity FormID. Three mirror GlobalVariables shadow the active patron's values for vanilla CK Condition reads. Mirrors are write-only caches. `PDV_GLO_DevotionLevel` and the three buckets removed.

**2026-05-10 -- PapyrusUtil SE:** SKSE DLL plugin -- no ESP master, no xEdit step. Call `StorageUtil.*` directly. Never add as a plugin master.

**2026-05-18 - PO3 Papyrus Extender dependency:** PDV v3 accepts powerofthree's Papyrus Extender as a hard runtime dependency for event hooks that vanilla Story Manager/player aliases cannot expose cleanly. This also makes Address Library for SKSE Plugins and powerofthree's Tweaks required runtime SKSE-plugin dependencies. These are not ESP masters. Use PO3 for runtime event hooks, not keyword/classification/NPC distribution; that remains offline patcher territory. SPID remains deferred for future cost-benefit review if PDV needs actor-load distribution, outfit lifecycle behavior, or broad dynamic injection that generated patches cannot represent cleanly.

**2026-05-19 - Race end-state implementation-lock pass:** The player-experience lock pass now lives in `PDV_TargetEndStates_1.0.md`, `race-sheets/*.md`, and `references/PDV_RaceArchitecture_DesignReference.md`. Breton is implementation-locked for 1.0 experience shape; reward numbers remain tuning. The original pass left an Altmer closeout gap after shared patron-state use, no generic broad lane, `ThalmorAlignment` bands/start values, crisis-of-faith posture, and bounded Lorkhan economy were locked. That gap was superseded by the 2026-05-30 Altmer closeout entry; Altmer Lorkhan pressure must still use explicit tags/hooks, basic devotional upkeep should trend positive, and ordinary existence in Skyrim is not a penalty source.

**2026-05-19 - Documentation authority cleanup:** `PDV_TargetEndStates_1.0.md` is now the living 1.0 product/end-state tracker. Improve Codebase Architecture review result: keep v3 as the deep architecture module, keep the target-end-state doc as the launch acceptance and roadmap-traceability module, keep the race architecture reference as the locked theology/rule module, and keep race sheets as player-facing race-experience modules. The separate beta-brief surface was removed to reduce duplicate beta/launch claims.

**2026-05-19 - v3.16 implementation handoff hardening:** `PDV_Architecture_v3.md` Section 21.5 now owns the build-facing handoff plan from Pattern Proving through the first cloned systems. Before starting a slice, use the first implementation packet checklist and handoff-card fields there: source contract, owning module, interface guarantee, data/state shape, implementation locations, entry gate, verifier gate, normal-play proof, exit/recovery, not-in-scope boundary, and docs touched. The section also maps open decisions to blockers, defines the verifier command ladder for declaring slice completion, and makes the later Daedric pilot consume the race-sheet/matrix hardening contract before any Prince/race implementation begins.

**2026-05-20 - Phase 19 tooling foundation kickoff:** Added `tools\pdv_patch.mjs` as the planning-first entrypoint for PDV's locked offline classification/distribution patcher direction. v0 validates tracked `pdv_patch_rules_v0` manifests under `references\authoring\patch-rules\`, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning records for keyword/FormList/NPC distribution planning, and emits deterministic dry-run review output without writing a generated patch ESP yet. `tools\pdv_author.mjs` planning/status output now also promotes VMAD-array work into explicit manual follow-up packets with intended payload plus verifier readback expectations instead of generic unsupported reminders.

**2026-05-30 - Phase 19 generated patcher proof:** `tools\pdv_patch.mjs build` now emits the generated `PDV_ClassificationPatch.esp` artifact through the existing Mutagen bridge writer seam. `validate` and `plan` remain read-only; `build --dry-run --json` produces the patch request without writing. The patcher now resolves payload references for keyword, FormList, NPC spell/perk/faction/item/package distribution fields, blocks unresolved `candidate` / `approved` rules, and keeps `tooling-example` rules plan-only by default. `tools\pdv_verify.mjs --strict-phase19` verifies the dry-run summary, generated patch readback, and that the proof overrides live only in `PDV_ClassificationPatch.esp`, not in `Skyrim.esm` or `Devotion.esp`.

**2026-05-30 - Phase 19 live content closeout:** `PDV_ClassificationPatch.esp` is now active in `Devotion Dev` immediately after `Devotion.esp`. Default `pdv_patch build` emits only approved rules; `PDV_Phase19ProofRules.json` is retired to `tooling-example`, and `PDV_Phase19TempleLocationRules.json` is the first approved live packet. It adds existing `LocTypeTemple` to six obvious shrine/temple `LCTN` records: `MarkarthShrineofTalosLocation`, `ShrineofAzuraLocation`, `ShrineofBoethiahLocation`, `ShrineofMehrunesDagonLocation`, `ShrineofPeryiteLocation`, and `DLC1FalmerValleyTempleLocation`. `tools\pdv_verify.mjs --strict-phase19` now verifies active profile placement, generated patch readback for those six overrides, absence of retired proof overrides, and source-plugin safety. The generated patch is a dev/review artifact; approved core vanilla/DLC rules may later be promoted into `Devotion.esp` through a separate release-packaging merge gate, while list-specific compatibility rules stay separate generated patches.

**2026-05-20 - PDV_MCM duplicate VMAD cleanup packet:** The live `PDV_MCM` duplicate warning is now reduced to one exact manual consolidation target, documented in `references\authoring\PDV_MCM_VMAD_Consolidation_Checklist.md`. Current split on `Devotion.esp` is three same-name `PDV_MCM` VMAD entries: `#0` owns the original manager/active-global block, `#1` owns the structural-system FormLists plus `PDV_CurseStateService`, and `#2` owns `PDV_EventBusService`. The intended steady state is one canonical `PDV_MCM` attachment with all 14 required properties, then removal of the other two same-name rows. `PDV_VmadConsolidationOverlay.esp` remains a reference/safety artifact only; merge-back into the framework record is the path that actually clears the strict verifier warning.

**2026-05-20 - Hidden shrine reference wiring lesson:** Phase 7's Talos shrine proof surface should be wired on the actual hidden shrine reference, not by defaulting to a nearby helper activator. The tracked manual contract now names `PDV_REFR_TalosShrineDefianceSignal` as the real hidden shrine reference once the EditorID is assigned, and `tools\pdv_verify.mjs --strict-phase7` now treats that co-attached reference as the readback target. Preferred compatibility posture is per-reference co-attachment first, helper objects only as fallback proof shapes, and no global shrine base-script replacement.

**2026-05-20 - PDV doc-sync learning capture rule:** `skills\pdv-doc-sync\SKILL.md` now treats lessons learned as a mandatory closeout step instead of an implied extra. Every PDV doc sync should either record durable learnings in the narrowest living doc or say explicitly that no new durable learnings qualified.

**2026-05-19 - Slice 0/1 implementation packets:** The current combined strict verifier baseline is `node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton --strict-pattern-proving --json` => `PASS=458, WARN=2, INFO=28`, no `FAIL` or `TODO`, at 2026-05-19 16:44 AEST. Treat the two warnings (`PDV_MCM` duplicate VMAD and stale SEQ freshness) as known waivers until manual consolidation or a post-CK SEQ refresh. Slice 1 implementation should add only normal-play triggers into existing EventBus routes for Dunmer portable shrine/home bonus, Bosmer Green Pact violation, and Hircine hunt rite; do not broaden into full Green Pact tagging, Daedric price/stigma, curse detection, or content cloning during that closeout.

**2026-05-10 -- CK compiler toolchain, revised 2026-05-12:** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output to `Scripts\`. Terminal/Codex compiles use `tools\pdv_compile.mjs`, which spawns `PapyrusCompiler.exe` directly with `<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`. CK compiler (Ctrl+F7) remains valid for interactive CK work. `compile.ps1`, `skyrimse.ppj`, and Bethesda's shipped `ScriptCompile.bat` are legacy/stale artifacts and should not be used.

**2026-05-10 -- Console command source of truth:** `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed working: `GetGlobalValue <var>` (read), `set <var> to <value>` (write). `cgf` does not work on instance functions.

**2026-05-11 -- Phase 2 verified:** `PDV_DeityBase`, `PDV_Deity_Kyne`, and `PDV__ManagerQuest` compile and are wired in CK. In-game testing verified patron activation, mirror globals, dawn clamp, persistent piety consolidation, and tier threshold transition.

**2026-05-11 -- Phase 3 preflight:** Keep `PDV_ActionRouter` as a persistent service quest. Use a separate non-Start-Game-Enabled receiver quest (`PDV__SM_KillActor`) for the Kill Actor Story Manager event. The receiver handles `OnStoryKillActor`, calls the router, then stops/resets. PDV Story Manager nodes must check `Shares Event`; event capture writes only through `AwardPiety()` into `PDV.PietyToday`.

**2026-05-11 -- Phase 3 scripts compiled:** `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` were added to `Scripts\Source` and compile to `.pex` in `Devotion\Scripts`. The first compile caught Papyrus name-shadowing issues (`ActorBase`, `Message`), which were fixed before final compile.

**2026-05-14 - Phase 3 complete:** `PDV_ActionRouter` and `PDV__SM_KillActor` quest records are created and wired in `Devotion.esp`; the Kill Actor Story Manager receiver node exists with `Shares Event`; `Devotion.seq` is generated under `Devotion\Seq`; Papyrus logging is enabled in the `Devotion Dev` profile. Runtime verification passed for Kyne activation, hostile bandit scoring (`event 2`, `+0.5` scratch), hostile wolf scoring (`event 1`, `-3.0` scratch), neutral-kill rejection, rapid dual-kill accumulation, and dawn consolidation/clamping.

**2026-05-11 -- Local Codex skills:** `pdv-doc-sync` and `pdv-papyrus-ck` skill sources live under `skills\` in this docs project, are packaged as `.skill` files, and are installed under `C:\Users\Admin\.codex\skills`.

**2026-05-12 -- PDV local toolchain:** `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs` are the local health/build loop for the Anvil/Devotion setup. The compiler directly spawns the verified `PapyrusCompiler.exe` CLI with short `-f`, `-i`, and `-o` args, compiles active PDV scripts into `Devotion\Scripts`, treats warnings as failures, and runs the verifier after successful compiles. Normal verifier mode should remain useful during active implementation; strict Phase 3 mode intentionally fails until `PDV_ActionRouter`, `PDV__SM_KillActor`, and the Kill Actor Story Manager node exist in the ESP.

**2026-05-15 -- PDV overlay authoring tool, revised 2026-05-16:** `tools/pdv_author.mjs` is the safe automation path for CK-adjacent ESP wiring on existing PDV records. It reads `Devotion.esp` through the same local Mutagen bridge as the verifier, then writes **reversible overlay patch plugins** into the `Devotion` mod rather than mutating the framework ESP in place. v1 scope is intentionally narrow: existing-record scalar/object VMAD properties and FormList membership only. New records, VMAD array properties such as `RivalDeities`, and Story Manager tree authoring remain manual CK/xEdit work. Generated patches must keep `Skyrim.esm` as the first master when using extended FormID ranges; do not manually insert masters into an existing patch without remapping FormIDs.

**2026-05-16 - Temporary overlays merged back and retired:** `PDV_ManagerPatronWirePatch.esp` and `PDV_MCMWirePatch.esp` were temporary rescue artifacts for CK instability. Their VMAD deltas have been merged directly into `Devotion.esp`: `PDV__ManagerQuest` now owns `PDV_GLO_PatronDeity`, and `PDV_MCM` is script-attached with required properties on the framework record. Both overlays are unticked in the `Devotion Dev` profile and must not be treated as runtime requirements.

**2026-05-16 - Manifest-driven property wiring overlays:** `tools/pdv_author.mjs` now supports tracked JSON manifests under `references\authoring\`. The first target, `mcm-property-wiring`, batches the current `PDV_MCM` property contract into one canonical `PDV_PropertyWiringOverlay.esp` overlay so the Devotion Dev profile does not accumulate per-property `PDV_Author_one_off_*` patches during CK instability.

**2026-05-14 - Anvil MO2 MCP Codex intake, updated 2026-05-16:** `references/PDV_Anvil_MO2_MCP_Intake.md` documents the local `Anvilmo2_mcp` plugin, the `mo2_*` tool surface, current Codex config, and optional tool status. Codex points at `http://127.0.0.1:27016/mcp`; the server must be started from MO2 before tools appear. The plugin is configured for Anvil's Papyrus compiler/source paths and uses `Devotion` as the MCP output mod default. `BSArch.exe` is installed for BSA/BA2 archive tools; `nif-tool.exe` remains the only confirmed missing optional binary.

**2026-05-14 - Skyrim modding lessons intake:** Archived external practical lessons at `archive/Skyrim_Modding_Lessons_2026-05-14.md` and folded durable rules into the living docs and Papyrus/CK skill: player-facing ASCII, Papyrus string/docstring/parser limits, save-baked new-game retesting, grep-before-delete hygiene, `cqf` named-function limits, and future dialogue/faction gate discipline.

**2026-05-16 - Phase 4/5/6 framework status:** The live ESP now contains the Phase 4 proof-slice surface, framework-owned manager patron wiring, the Phase 5 `PDV_MCM` quest/script/properties, and the coupled Talos + Auri-El record set with FormList membership, origin references, stance rows, rivalry wiring, and boon assignments. The verifier currently reports `FAIL=0, WARN=0, TODO=0`; remaining verifier output is informational only.

**2026-05-15 - SkyUI CK header shim:** Repeated CK fatal errors traced back to a broken SkyUI source-store chain (`SKI_QuestBase` -> `SKI_ConfigBase` -> `SKI_ConfigManager`). For the `Devotion Dev` profile, a dedicated shim mod was added at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\` exposing `SKI_QuestBase.psc`, `SKI_ConfigBase.psc`, and `SKI_ConfigManager.psc` under `Source\Scripts\`. This is a CK-environment repair for source lookup only, not a runtime SkyUI upgrade. The profile modlist was backed up before enabling the shim.

**2026-05-16 - Phase 5 in-game proof and ReShade caveat:** With `ReShade64.dll` temporarily renamed out of `D:\Wabbajack\modlists\Anvil\Stock Game\`, `PlayerDevotion` registered in SkyUI and the first MCM slice passed its live smoke test: `Status` and `Debug` both loaded, the Kyne/Talos/Auri-El roster rendered, and debug patron override worked. Two separate CTDs before that were traced to native crash stacks dominated by `ReShade64.dll`, `WS2_32.dll`, and `webio.dll`, with no matching PDV MCM fault in Papyrus. Treat ReShade as a separate environment investigation, not a blocker on PDV Phase 5 completion.

**2026-05-16 - Phase 4 and Phase 6 full closeout proof:** Phase 4 and Phase 6 are now proven in game end to end, not just verifier-clean. The closeout pass covered clean-start origin bootstrap, seeded ledger expectations, patron-only boon grant/removal, rivalry-driven Talos hostile-path transfer against Auri-El across dawn consolidation, and save/load sanity on the proven final state. The Phase 6 pass also exposed a real workflow gap: curated Talos/Auri-El signal testing was not reachable through the previously proven debug surface, so `PDV__ManagerQuest` and `PDV_MCM` were extended with a surfaced curated-signal debug helper rather than relying on an unproven console `cqf` path.

**2026-05-16 - v3 roadmap and beta gates:** `PDV_Architecture_v3.md` now owns the forward roadmap after the proven Phase 4/5/6 baseline. The roadmap separates structural completeness from content completeness, requires V3 Preflight before Phase 7 signal expansion, adds a Structural Skeleton pass for dev-only 1.0 scaffolding, and defines Technical Beta, Content-Feel Beta, and content-rich 1.0 launch readiness.

**2026-05-16 - v3 Section 24 cleanup:** `PDV_Architecture_v3.md` now removes already-settled decisions from the open tracker instead of leaving them as recommended-but-open items. Resolved IDs are D-09, D-11, D-15, D-16, D-18, D-24, D-25, D-26, D-27, D-28, D-29, and D-32. The operational defaults were structural completeness first, monolithic 1.0, strong substrates only for Khajiit/Dunmer/Argonian, shrine overlays, Tier 2 broad worship, three-option commitment offers, curse-state pressure without automatic Daedric unlocks, thematic UI by default, in-world patron switching, concrete pattern cloning, FormList-driven MCM ordering, Phase 12 stack-depth benchmarking, and then-documented Wintersun coexistence. The compatibility lane later superseded the religion-overhaul posture with replacement-first list-author packages.

**2026-05-16 - v3 doc cleanup and scaffold-code contract:** `PDV_Architecture_v3.md` v3.8 and `references\PDV_RaceArchitecture_DesignReference.md` now treat old bucket terms as legacy design-axis shorthand, not implementation state. The first Structural Skeleton code pass added compile-clean optional base scripts: `PDV_ReputationTrack`, `PDV_StateTrack`, `PDV_SubstrateBase`, `PDV_SacredPlace`, `PDV_DaedricPathBase`, and `PDV_CurseState`. No phase-order change: Structural Skeleton remains next, Pattern Proving remains the first content-bearing wave, and no v2 implementation needs reopening solely because of the race sheets.

**2026-05-16 - V3 Preflight script/tooling slice:** Added compile-clean `PDV_EventTypes` and `PDV_EventBus`, routed the kill-event canary through attribution-aware payload hooks while preserving direct-player v2 scoring, split manager dawn/gain logic into named Preflight extension slots, added patron-state and custom-race fallback diagnostics, and expanded compiler/verifier coverage. CK/xEdit record creation and in-game smoke remain pending before V3 Preflight is complete.

**2026-05-16 - V3 Preflight reversible canary:** `references\authoring\PDV_PreflightRouterServices.manifest.json` now drives `PDV_PreflightRouterServicesOverlay.esp`, a reversible overlay that co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` and points the router at those services on the same quest record. This was chosen because the safe authoring path can attach scripts to existing records but cannot mint new quests/globals; at this canary stage, `PDV_GLO_PatronState` and framework-owned record creation were still follow-up tasks.

**2026-05-16 - V3 Preflight gate closed:** Framework-owned `PDV_GLO_PatronState`, `PDV_EventTypes`, and `PDV_EventBus` are now present and wired directly in `Devotion.esp`; `PDV_ActionRouter` now points to framework-owned EventBus/EventTypes services; strict preflight verification runs clean (`node .\tools\pdv_verify.mjs --strict-preflight --json` => `FAIL=0`); and clean-start in-game smoke A-F passed (MCM load, origin seed, patron-state transitions, dawn consolidation, non-hostile no-change, hostile direct scratch gain + dawn consolidation, rivalry proof on hostile stance path, save/load sanity). `PDV_PreflightRouterServicesOverlay.esp` can remain as historical canary but should stay inactive at runtime.

**2026-05-17 - V3 broad structural scaffold gate closed:** The broad Structural Skeleton pass is now merged into `Devotion.esp`. New substrate, sacred-place, Hircine, curse-state, FormList, and `PDV_MCM` scaffold wiring is present on the framework ESP; `references\authoring\PDV_StructuralSystemsScaffold.manifest.json` and `references\authoring\PDV_StructuralSystemsArrays.manifest.json` are the tracked authoring/readback companions; and `tools\pdv_author.mjs` now recognizes array manifest syntax for planning while keeping array writes manual. Gate-close verification is clean: `node .\tools\pdv_verify.mjs --strict-skeleton` and `node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton` both return `FAIL=0, WARN=0, TODO=0, PASS=401, INFO=30`. Runtime smoke also passed in game on the `PDV_MCM` Debug page: `Show structural map` and `Run scaffold smoke` completed without changing patron mirrors, dawn behavior, or EventBus routing, and Papyrus confirmed read/write/restore traces for reputation, state, substrate, sacred-place, daedric, and curse scaffolds.

**2026-05-18 - Pattern Proving smoke and verifier guardrail:** The first V3 Pattern Proving smoke now has live proof on the current framework baseline: Imperial Concordat and the Khajiit emergent/moon-cycle lane both passed in game, but only the later Khajiit pass after runtime-origin reset counts as the formal proof. The important workflow lesson is save-bake discipline: after VMAD/property merge-back or live MCM/runtime quest wiring changes, the first trustworthy smoke should be from a new save or main-menu `coc qasmoke`, because existing saves can preserve stale script instances that masquerade as missing manager/property wiring. `tools\pdv_verify.mjs` now warns when a quest record carries duplicate same-name VMAD script attachments, since that drift can look verifier-clean while still producing confusing runtime behavior. `PDV_VmadConsolidationOverlay.esp` was generated as a temporary diagnostic/containment overlay during investigation, but it is not a steady-state requirement and should remain inactive unless explicitly needed for future recovery work.

**2026-05-18 - Pattern Proving ingress code landed, smoke reused, alias wiring still manual:** The kickoff implementation pass did not need to re-run the proving smokes from last night and this morning; those remain the live evidence base. Instead, the code/deepening work added the first normal-play ingress surface around the already-proven pilot slice: `PDV_PlayerEvents.psc` now exists as the canonical player `ReferenceAlias` event script, `PDV_EventBus.psc` gained routed non-kill handlers for sleep, Dunmer ancestor prayer/home bonus, Khajiit moon/road-home cadence, Green Pact violation, and Hircine hunt rite, and `PDV__ManagerQuest.psc` / `PDV_MCM.psc` now prefer semantic EventBus routes over direct debug-only mutation. The targeted compile pass succeeded cleanly for `PDV__ManagerQuest`, `PDV_EventBus`, `PDV_EventTypes`, `PDV_MCM`, `PDV_Substrate_DunmerAncestor`, `PDV_Substrate_KhajiitLunar`, `PDV_DaedricPath_Hircine`, and `PDV_PlayerEvents`, and strict verification for that pass was clean on `FAIL=0, TODO=0` with `PASS=458, WARN=2, INFO=28` at 2026-05-18 16:47 AEST. Remaining warnings were `PDV_MCM` duplicate VMAD plus stale SEQ freshness; the refreshed 2026-05-19 Slice 0 baseline above preserves the same warning boundary. Important boundary: the safe authoring stack can compile and verify `PDV_PlayerEvents`, but it still cannot mint quest aliases, so `PDV_Player` was attached manually and any future alias additions remain manual CK/xEdit work. `PDV_PatternProvingCoreOverlay.esp` is not an active profile dependency in `Devotion Dev`; the current proving baseline lives on the framework/source side, with overlays kept as tracked artifacts only.

**2026-05-19 - Slice 1 signal receiver layer:** Added `PDV_EventSignalActivator.psc` and `PDV_EventSignalEffect.psc` as the reusable CK-owned receiver layer for non-debug normal-play Slice 1 proofs. Both scripts compile to `.pex`, expose `PDV_EventBusService`, `PlayerREF`, `PDV_GLO_OriginRace`, `PDV_GLO_DebugLevel`, `RouteId`, `RequiredOriginRace`, `TraceLabel`, and `OncePerDayKey`, and route only to existing EventBus functions: `30` Dunmer portable shrine, `31` Dunmer private/home shrine, `32` Green Pact violation, and `34` Hircine hunt rite. `tools\pdv_compile.mjs` now treats both receiver scripts as active. `tools\pdv_verify.mjs --strict-pattern-proving` now checks their source/pex freshness plus `references\authoring\PDV_Slice1SignalReceivers.manifest.json`, and validates ACTI/MGEF script/property readback once manual CK/xEdit proof records exist. The initial receiver-layer verifier result before manual record creation was clean at 2026-05-19 17:08 AEST: `FAIL=0, TODO=0, PASS=494, WARN=2, INFO=32`. `pdv_author.mjs plan slice1-signal-receivers` confirms the record plan but produces zero operations because the authoring helper still cannot mint new records.

**2026-05-19 - Slice 1 runtime proof closed:** Manual CK/xEdit proof records now exist for the Slice 1 receiver layer and pass strict Pattern Proving readback. Counted in-game proof completed Dunmer portable/private shrine practice (`prayers=1; homes=1`), Bosmer OldContract Green Pact violation (`gp=1`), and Hircine hunt rite (`sig=1; stigma=1.000000; state=Legible`) through normal-play receiver records, with Papyrus traces showing receiver -> EventBus -> manager/substrate/path routing. Bosmer/Hircine save-load sanity passed, and the final combined strict verifier at 2026-05-19 20:28 AEST is clean: `FAIL=0, TODO=0, PASS=522, WARN=2, INFO=28`. Runtime hardening from the proof pass also updated `PDV_PlayerEvents.psc` so origin capture waits for playable controls / `RaceSex Menu` close, and updated `PDV_MCM.psc` with a fallback through `PDV_EventBusService` for manager/debug access while the then-live duplicate `PDV_MCM` VMAD state awaited later consolidation.

**2026-05-19 - Phase 7 Nord/Imperial-first implementation packet:** The next signal wave now has live source/tooling scaffolding on disk. `PDV_PlayerEvents.psc` registers PO3 shout hooks and routes `OnShoutAttack(Shout akShout)` through `PDV_EventBus.RouteShoutAttack(...)` into `PDV__ManagerQuest.HandleShoutAttack(...)`; `PDV_EventTypes.psc` now reserves `35` for Talos shrine defiance and `40` for shout use; `PDV_EventSignalActivator.psc` can route Talos shrine defiance through `RouteId = 35` when it is co-attached to the actual hidden shrine reference; and `PDV_DeityBase.psc`, `PDV_Deity_Kyne.psc`, and `PDV_Deity_Talos.psc` now enforce shout anti-farm rules with deity-side daily caps plus cooldown windows stored on the deity form via StorageUtil. `tools\pdv_compile.mjs` now imports PO3 source headers directly, and `tools\pdv_verify.mjs --strict-phase7` covers the new shout/shrine source contract plus manual reference readback through `references\authoring\PDV_Phase7SignalReceivers.manifest.json`. Boundary remains explicit: the hidden shrine reference wiring plus verified Civil War one-shot hooks still require manual CK/xEdit creation after local record confirmation.

**2026-05-20 - Phase 7 shout ingress hardening:** Runtime proof showed the `PDV_Player` alias was live and `PDV_PlayerEvents` refreshed shout hooks on load, but `OnShoutAttack(Shout akShout)` did not reliably surface through the alias receiver alone during counted shout-use tests. The hardening pass keeps the alias route as the preferred ingress, adds a quest-level PO3 form fallback on `PDV__ManagerQuest` (`PO3_Events_Form.RegisterForShoutAttack(Self)` + `OnPlayerShoutAttack(Shout akShout)`), and suppresses near-simultaneous duplicate shout callbacks inside `HandleShoutAttack(...)` so future runtime sessions cannot double-award if both receivers fire. `tools\pdv_verify.mjs --strict-phase7` now also reads back the live `PDV_Player` alias contract (`PDV_PlayerEvents` + `PDV_EventBusService` / `PDV_OriginQuest` / `PDV_GLO_DebugLevel`) from `PDV__ManagerQuest` instead of trusting source snippets alone.

**2026-05-20 - Phase 7 runtime proof closeout and timing lesson:** Counted in-game proof is now real for the two live Phase 7 surfaces that were in scope for this wave. The hidden Talos shrine reference on an Imperial save now proves shrine behavior preservation, Talos curated signal award, Concordat `-15` pressure, immediate repeat block, save/load persistence, and next-day reopen. The shout lane now proves counted PO3 ingress on a clean Nord save, with MCM scratch deltas landing at `Kyne t=0.35` and `Talos t=0.5`. The testing lesson is durable: PDV shout anti-farm cooldown is measured in in-game time (`0.0208` days, roughly 30 in-game minutes), not vanilla shout UI cooldown. A second shout after vanilla recovery but before enough in-game time passes should be treated as a correct anti-farm non-award, not a routing failure.

**2026-05-20 - Strict verifier baseline refreshed to zero warnings:** The former standing warning pair is now gone. Manual xEdit merge-back consolidated `PDV_MCM` down to one canonical VMAD attachment with all required properties, the framework/SEQ state now passes freshness checks again, and the strict gate stayed fully clean after the `PDV_FragmentBridge` source checks were added: `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` => `FAIL=0, WARN=0, TODO=0, PASS=579, INFO=28` at 2026-05-20 15:51 AEST. Treat that as the new baseline rather than carrying old warning waivers forward.

**2026-05-20 - Pattern Proving reduced reorder adopted:** Section 21.5's live order now keeps the first four pilot slices intact, then runs `Commitment -> Neglect/decay -> Privilege -> Contextual favor -> UI toast hardening -> Daedric -> Curse-state`. The archived branch review lives at `archive\phase-order-recommendations-2026-05-20.md`, but the living plan intentionally did **not** add a standalone base-script verification slice or a standalone signal-breadth slice because Structural Skeleton and the current Phase 7 runtime proof already cover those seams in this repo state. Operational takeaway: do not start full Daedric price/stigma work until decay-aware tuning, privilege conditioning, and the Prisma toast payload contract are all stable.

**2026-05-20 - Overnight enabler rule:** Section 21.5's completion order still governs what counts as done, but implementation may now pull forward a short list of enabler micro-slices when that unlocks unattended overnight work. Approved early pulls are `Commitment + Neglect/decay` hardening, `UI toast` contract stabilization, the `Khajiit focused-emphasis` scaffold, and limited `Bosmer path` intent/cooldown/state bookkeeping. These are build accelerators only, not permission to mark the parent slices complete. Privilege, full Daedric price/stigma, and curse-state remain behind the live gates.

**2026-05-23 - Phase 9 framework record and placement closeout; retired 2026-06-16:** The Bosmer path framework packet was authored directly into `Devotion.esp` with timestamped backups under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase9`. Historical live record readback confirmed `PDV_Deity_Zen`, `PDV_Deity_BaanDar`, Y'ffre/Zen/BaanDar path eligibility, all six Bosmer message boxes, `PDV__ManagerQuest` Bosmer properties, `PDV_FLST_AllDeities` membership, and five ACTI proof-surface base records for route IDs `41-45`. The Windhelm proof placements and base ACTIs (`PDV_REFR_BosmerLivingStorySignal`, `PDV_REFR_BosmerExchangeSignal`, `PDV_REFR_BosmerBanditRoadSignal`, `PDV_REFR_BosmerPactPositiveSignal`, `PDV_REFR_StateTransitionConfirmRite`, and their `PDV_ACTI_*` bases) were removed on 2026-06-16 because they were still visible in `WindhelmTempleofTalos`. Current strict Phase 9 treats those records as retired and fails if they return. The counted runtime proof remains historical evidence from 2026-05-24, not a live placement contract.

**2026-05-24 - Phase 10/11 doc-grilled handoff:** Phase 10/11 are now treated as subsystem labels, with `PDV_Architecture_v3.md` Section 21.5 remaining authoritative for execution order. Phase 10 is scoped as Dunmer ancestor substrate proof graduation using the existing Dunmer portable/private shrine ACTI proof surfaces, with no new boon spell or notification requirement. D-10 is resolved to the Arngeir/Kynareth recognition pilot gated by Nord origin, Kyne active deity, Champion tier, and Arngeir as speaker. Generated live dialogue records were later removed after a CrashLogger-confirmed CTD, so Phase 11 is prep-only again until rebuilt through a CK-safe path.

**2026-05-24 - Khajiit/commitment/neglect/Phase 11 next-packet scaffold:** Source/tooling prep is live for the next Section 21.5 packet. `PDV__ManagerQuest.psc` now has Khajiit focused-emphasis state/readback, Kyne commitment offer APIs, and Kyne neglect spell sync hooks; `tools\pdv_verify.mjs` now exposes `--strict-khajiit`, `--strict-commitment`, `--strict-neglect-decay`, and prep-aware `--strict-phase11` readback; `tools\pdv_compile.mjs` passes those gates through. `tools\pdv-next-packet-author` corrected the Phase 10 Dunmer cooldown-key drift, wired `PDV_GLO_KhajiitFocusedEmphasis`, created `PDV_MGEF_Neglect_Kyne` / `PDV_SPEL_Neglect_Kyne`, and wired the manager spell property. The generated Arngeir dialogue records were removed after CrashLogger tied a CTD to the generated topic/branch shape. This scaffold checkpoint was superseded by the 2026-05-25 Khajiit/commitment/neglect runtime closeout below; the remaining work is a later CK-safe Phase 11 dialogue rebuild.

**2026-05-25 - Khajiit/commitment/neglect runtime closeout:** Runtime proof completed for the next Section 21.5 packet except Phase 11 dialogue, which remains prep-only after the CTD remediation. Khajiit road-home cadence produced Khenarthi focus at `KhajiitLunar=metric=13.139999; tier=1; roadhome=3; focus=Khenarthi; kh=54.75; az=0.00`; moon observance switched focus to Azurah at `metric=24.904676; tier=1; phase=1; observance=6; roadhome=3; focus=Azurah; kh=54.75; az=73.52`; save/load persistence held at `metric=24.904699`. Kyne commitment proof created a pending offer from two positive Kyne signal days (`pending=0; days=2; cooldown=0.00`), proved the `Not Yet`, `Refuse`, and `Accept` branches under the original timer cadence, accepted Kyne as active patron at `Active piety=51.000000`, `Active tier=DEVOTED`, `Active deity index=0`, and confirmed active-patron persistence after reload. The current 2026-06-25 source supersedes the old cooldown cadence with one offer per qualification, lapse-and-rebuild reoffer, and per-deity terminal refusal. Kyne neglect/decay proof passed the 3-day grace, one post-grace decay tick, no same-day second tick, low-piety neglect spell application, and spell removal after recovery. Final full strict gate is clean at `PASS=898, INFO=29`.

**2026-05-25 - Phase 11 fail-closed helper guard:** After promoting the Phase 9/next-packet branch into `main`, the full packet verifier remained clean at `PASS=898, INFO=29`. `tools\pdv-next-packet-author` now blocks generated Phase 11 Arngeir dialogue creation and only preserves the cleanup path for removing those records if they reappear. `references\authoring\PDV_Phase11PrivilegePilot.manifest.json` now carries the manual CK-only branch/topic/info/SEQ packet so the next live step is explicit CK authoring, SEQ refresh, strict readback, and runtime positive/negative proof.

**2026-05-25 - Phase 11 CK-safe authoring packet ready:** The Phase 11 manifest is now also consumable by `tools\creation-authoring`, and `tools\creation-authoring\reference-packs\player-devotion\player-devotion-phase11.profile.json` points at the CKPE bridge plus the full packet strict verifier. Planning the manifest reports four CKPE-ready operations: branch, topic, info, and SEQ refresh. The native bridge still intentionally blocks mutating dialogue handlers, so this is an executable CK handoff, not a safe automated dialogue writer. `references\authoring\PDV_Phase11_CKSafeDialogue_Runbook.md` is the operator packet for the manual CK pass. The live status remains `prep-only` until CK save, SEQ refresh, manifest promotion to `live-dialogue-authored`, strict readback, and runtime positive/negative proof.

**2026-05-26 - Phase 11 Arngeir/Kynareth runtime closeout:** The manual CK dialogue pass is saved in `Devotion.esp` as the PDV branch/topic plus a CK-authored unnamed Topic Info. `tools\pdv_verify.mjs --strict-phase11` resolves that unnamed `INFO` by topic, Arngeir speaker, prompt, response line, and condition stack. SEQ was refreshed. Runtime proof passed for Nord/Kyne Champion positive, non-Nord negative, wrong active deity negative, below-Champion negative, and save/load sanity. The full strict packet gate is clean at `PASS=908, INFO=28`, with no `FAIL`, `WARN`, or `TODO`.

**2026-05-28 - Phase 13 runtime closeout and hunt-rite cadence lesson:** Fresh-save runtime proof on the live Debug page now closes the Hircine/Nord pilot as a first full Daedric path. The counted proof covered the negative gate before day-three commitment signals, Seeker and Devoted price activation, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path. Durable live-behavior lesson: same-day `Hircine hunt rite` presses are throttled by the shared daily repeat multiplier before stigma or piety is applied. On the same in-game day, the rite multiplier scales `1.0`, `0.7`, `0.49`, so the third same-day rite can legitimately produce `sig=3`, `p=5.88`, `tier=0`, and `price=None`. Counted Seeker proof must therefore use one rite on each of three in-game days.

**2026-05-28 - Phase 14-16 runtime closeout and Hircine status correction:** Fresh-save runtime proof on the live Debug page closed the generic Phase 14-16 seams. Phase 14 proved Kyne seed/evaluate, the `Not Yet`, `Refuse`, and `Accept` branches, and accepted-patron persistence. The current 2026-06-25 source supersedes the original 7/14-day cooldown cadence: `Not Yet` leaves the one-shot qualification guard set until piety lapses below threshold and later re-qualifies, and `Refuse` permanently blocks that deity from asking again. Phase 15 proved the shared `PDV_CurseState` seam for werewolf, vampire, and clear transitions; current `Papyrus.0.log` also shows `[PDV] HircinePilot: Curse entry recorded for Hircine.` and `[PDV] HircinePilot: Werewolf cure recorded for Hircine.` during the same pass. Phase 16 proved active-Kyne low-piety neglect selection, Kyne neglect-spell application, and broad-worship suppression clearing the active neglect set on re-evaluation. Durable workflow lesson: after recompiling `PDV__ManagerQuest` or `PDV_MCM`, a main-menu reload was not enough to trust the live manager instance; a full Skyrim restart was required before the new `.pex` behavior appeared in game. Durable debug-surface lesson: `Reset commitment state` clears offer bookkeeping, rupture, and seeded signal days, but it intentionally does not reset deity piety or clear an already accepted active patron.

**2026-05-28 - Phase 17 decay bridge source/readback:** Superseded by the runtime closeout and 2026-06-02 balancing retune entries above. The source/readback pass added the standalone verifier gate and manifest, active-patron passive-decay skip, non-patron drift, the original `3.0` day grace / `0.5` daily rate / `0.2x` broad-worship multiplier, and gated MCM proof controls; the current live contract is `2.0` day grace, `25/50/85` thresholds, `4.3` daily cap, and `1.32` gain scale.

**2026-05-30 - Altmer implementation-spec closeout:** Altmer is no longer the named open race in the 1.0 target docs. `race-sheets\PDV_RaceDesign_Altmer.md` now locks `PDV_State_AltmerCrisis`, the final crisis source list, resolution routes, contextual-favor lane families, focused-deity launch hook posture, and rejected surfaces. `race-sheets\PDV_RaceContent_Manifest.md` Section 13.13 drafts the formerly gated crisis, contextual-favor, and Exiled vampire rows. `PDV_TargetEndStates_1.0.md` now marks Altmer implementation-spec and hook feasibility as locked. Remaining work is implementation costing, verifier assertions, runtime proof, and tuning.

**2026-05-30 - Race implementation-costing backlog:** `references\authoring\PDV_RaceImplementationCostingBacklog.md` now converts the race gameplay audit into buildable slices. It defines the P0 Altmer crisis/Lorkhan/favor queue, P1 Argonian Hist/People, Orc life-mode, Redguard sect, Bosmer non-hunter, and Khajiit lunar/road queues, and P2 stack/ceiling controls for Breton, Dunmer, Imperial, and Nord. Child manifests now cover Altmer, Argonian, Orc, Redguard, Bosmer non-hunter parity, and Khajiit. `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` is live for the full manifest set, and `--strict-phase20-altmer` remains the focused Altmer crisis/Lorkhan/favor gate. Future race runtime work should cost state artifacts, hook sources, rejected hooks, immersion proof, player surfacing, verifier/readback gates, runtime proof, and compatibility notes here before implementation.

**2026-05-30 - Race immersion budget:** Immersion is now treated as verifier-enforced reward budget, not post-hoc writing polish. `references\authoring\PDV_RaceRewardBudgetLedger.md` adds immersion budget rules and a race-by-race immersion matrix; `references\authoring\PDV_RaceGameplayBalanceAudit.md` requires an immersion proof before runtime promotion; every Phase 20 race-costing manifest now carries an `immersionProof` block; and `tools\pdv_verify.mjs --strict-phase20-race-costing` fails missing/thin immersion proof.

**2026-05-30 - Orc life-mode proof slice:** `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now compile with Orc route IDs `70-73`, manager handlers, life-mode status/survey surfacing, and curse code-pressure markers. `tools\pdv-phase20-orc-author --create-missing` filled `PDV_StateTrack_OrcLifeMode`, created/wired four ACTI proof base records for Stronghold forge, City dignity, Legion/Exile service, and self-made community, and wired `PDV_OrcLifeModeTrack` on `PDV__ManagerQuest` with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-orc\Devotion.esp.20260530-222149.bak`. `references\authoring\PDV_Phase20_OrcProofPlacement_Runbook.md` defines the remaining CK-owned placement packet; `--check-placements` currently fails only on the four expected missing `PDV_REFR_Orc*` references. After compile, helper authoring, and SEQ refresh, `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1697, WARN=1, INFO=29`, with only the existing unnamed CK-authored INFO warning.

**2026-05-30 - Redguard sect proof slice:** `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now compile with Redguard route IDs `80-83`, manager handlers, sect status/survey surfacing, Far Shores token state, and curse-cycle pressure markers. `tools\pdv-phase20-redguard-author --create-missing` filled `PDV_StateTrack_RedguardSect`, created/wired four ACTI proof base records for Crown tomb respect, Forebear road passage, Ash'abah death duty, and Far Shores token use, and wired `PDV_RedguardSectTrack` on `PDV__ManagerQuest` with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-redguard\Devotion.esp.20260530-224436.bak`. `references\authoring\PDV_Phase20_RedguardProofPlacement_Runbook.md` defines the remaining CK-owned placement packet; `--check-placements` currently fails only on the four expected missing `PDV_REFR_Redguard*` references. After compile, helper authoring, and SEQ refresh, `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1762, WARN=1, INFO=28`, with only the existing unnamed CK-authored INFO warning.

**2026-05-31 AEST - Khajiit moon/road/focus proof slice:** `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now compile with Khajiit proof routes for moon observance (`10`), road-home anchors (`33`), Baan Dar (`90`), Rajhin (`91`), and Alkosh (`92`). The manager now origin-gates Khajiit moon/road scoring, rejects immediate same-anchor road-home repeats, records focus movement for Baan Dar/Rajhin/Alkosh, and exposes all five focus weights in summary readback. `tools\pdv-phase20-khajiit-author --create-missing` created/wired six ACTI proof base records and rewired `PDV_KhajiitLunarSubstrate` plus `PDV_GLO_KhajiitFocusedEmphasis` on `PDV__ManagerQuest` with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-khajiit\Devotion.esp.20260531-040325.bak`. `references\authoring\PDV_Phase20_KhajiitProofPlacement_Runbook.md` defines the remaining CK-owned placement packet; `--check-placements` currently fails only on the six expected missing `PDV_REFR_Khajiit*` references. After compile, helper authoring, and SEQ refresh, `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1857, WARN=1, INFO=28`, with only the existing unnamed CK-authored INFO warning.

**2026-05-31 AEST - Bosmer non-hunter favor proof slice:** `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now compile with Bosmer favor proof routes for Old Contract proper hunt (`100`), Old Contract forest kept (`101`), Living Story community kept (`102`), Living Story nature site (`103`), Exchange debt settled (`104`), Exchange proportionate vengeance (`105`), Bandit Road road life (`106`), and Bandit Road reversal (`107`). The manager now records per-path favor counters, exposes Bosmer favor summary readback, and gives Bandit Road reversal a seven-day major-favor cooldown so pariah-road payoff is meaningful without becoming a faucet. `tools\pdv-phase20-bosmer-author --create-missing` created/wired eight ACTI proof base records with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-bosmer\Devotion.esp.20260531-042153.bak`. `references\authoring\PDV_Phase20_BosmerProofPlacement_Runbook.md` defines the remaining CK-owned placement packet; `--check-placements` currently fails only on the eight expected missing `PDV_REFR_Bosmer*` references. After compile, helper authoring, and SEQ refresh, `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1963, WARN=1, INFO=28`, with only the existing unnamed CK-authored INFO warning.

**2026-05-31 AEST - Phase 20 QASmoke proof-placement packet:** `tools\pdv-phase20-proof-placement-author --place-missing` created the 30 Phase 20 proof references in `QASmoke` for Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer after a clean dry-run. The live framework backup is `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-proof-placements\Devotion.esp.20260531-044132.bak`. The generic placement helper and all six per-race `--check-placements` helpers now pass, SEQ was refreshed, all six race-costing manifests are promoted to `proof-placement-gate-live`, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1985, WARN=1, INFO=28`, with only the existing unnamed CK-authored INFO warning. `tools\pdv_phase20_runtime_check.mjs` and `references\authoring\PDV_Phase20_QASmokeRuntimeProof_Runbook.md` now provide the counted runtime proof lane: log-route verification plus Survey/status, immersion, negative-hook, and anti-farm checks. Runtime proof and final immersive world placement remain open.

**2026-05-31 AEST - Phase 20 QASmoke route proof closeout:** The all-race QASmoke runtime pass is route-proven. `node .\tools\pdv_phase20_runtime_check.mjs --race all` and `node .\tools\pdv_phase20_runtime_check.mjs --race all --strict-manager` passed after the Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer proof markers were activated. A follow-up polish pass changed the temporary proof activator names/prompts to all-caps debug labels and hardened `tools\pdv-phase20-proof-placement-author --check-placements` so mixed/lower-case proof marker display strings fail readback. The six per-race author helpers rewrote the live ACTI labels, the hardened proof-placement check passes, SEQ freshness was refreshed, and the strict Phase 20 verifier is clean at `PASS=1985, WARN=1, INFO=28`. This closes route-stack proof only; final immersive world placement, rejected/anti-farm checks, Survey/status feel checks, and "thin or mechanical" feel belong to pre-beta gameplay scaling after enough real hooks and rewards exist for the race to be judged.

**2026-05-31 AEST - Pre-beta race scaling correction:** The race gameplay audit is not ready to hand to an external beta tester just because route proof passed. Rejected-hook checks for generic travel/sleep/combat/theft/crafting, Survey/status feel checks, final immersive placement, and P2 stack/ceiling audits for Breton, Dunmer, Imperial, and Nord are still required. The sequencing correction is that these are pre-beta buildout and internal validation gates. Next session should choose the scaling spine: recommended Altmer first, Nord as the control/reference for a fully felt race, then Khajiit or Argonian as the first contrast race.

**2026-05-31 AEST - Pre-beta race scaling spine:** `references\authoring\PDV_PreBetaRaceScalingSpine.md` now owns the internal handoff between QASmoke route proof and external beta readiness. The chosen order is Altmer active spine, Khajiit first contrast, Argonian second contrast, Orc/Redguard/Bosmer P1 packet prep, and Breton/Dunmer/Imperial/Nord P2 audit-only stack/ceiling packets. Each packet records normal-play hooks, rejected generic hooks, Survey/status readout, final placement, reward ceiling/floor, stack snapshot, runtime proof command, manual feel note, and content dependency.

**2026-05-31 AEST - Daedric expansion blocker rewrite; refreshed 2026-06-07:** CAT-4 now treats the old "Section 11.6 open decisions" language as stale. D-12 separate Daedric roster, D-13 mixed recovery, and D-14 reduced cross-Prince hostility are locked defaults. D-15..D-18 later locked stigma handling, curse-access templates, Prince authoring order, and per-Prince content-ready criteria. All-Prince CAT-6 record/readback is now complete; the remaining Daedric blockers are runtime/display proof, live sender proof, wrong/generic-source silence, stack/Survey legibility, and deeper Hircine/Molag Bal curse-access checks. This blocks broad 1.0 Prince runtime promotion, not pre-beta race-scaling hook validation.

**2026-05-31 AEST - Pre-beta acceptance and content-scale packets (recognition scope revised 2026-06-01):** Three architecture packets now gate the next content/scaling work before broad grinding. `references\authoring\PDV_PreBetaRaceAcceptanceRubric.md` defines race-scaling `Pass` / `Conditional` / `Fail` criteria across normal-session hooks, rejected hooks, anti-farm cadence, Survey/status clarity, final placement, reward floor/ceiling, expected/edge builds, and stack snapshots. `references\authoring\PDV_RecognitionDialogueScalePacket.md` preserves the CK-safe recognition pattern for planned V2 work while V1 avoids new NPC conversation lines, voiced responses, lip files, scene content, and broad recognition topics. `references\authoring\PDV_CAT6PromotionPilot.md` defines the first low-risk non-dialogue draft-to-ESP-to-handbook proof before broad CAT-6 promotion.

**2026-05-31 AEST - Phase 20 pre-beta gate implementation; refreshed 2026-06-07 for all-race plus Daedric beta-feel:** `references\authoring\PDV_PreBetaRaceGateLedger.md` now records all ten race gate packets with verdict, normal-session route, accepted/rejected hooks, anti-farm rule, Survey/status result, final placement result, reward floor/ceiling, stack snapshot, expected/edge builds, and blocking follow-up. The Altmer costing manifest is reconciled to the current content-lock rows (`MarriageBeat`, `DivineBody_DawnObservance`, `ThalmorOrthodox_ProjectDefended`) while preserving legacy wired record EditorIDs. `PDV__ManagerQuest.psc` now has fiction-facing Survey/status branches for all ten races, including P2 Breton/Dunmer/Imperial audit readouts and less numeric Argonian/Redguard status text. `tools\pdv_verify.mjs --strict-phase20-race-costing` now checks the all-race Survey source scaffold, and `PDV_Phase20_PreBetaManualChecks_Runbook.md` owns the manual handoff. `PDV_AllRaceDaedricBetaReadinessLedger.md` is now the combined beta-feel blocker ledger: Daedric D-15..D-18 are locked, all sixteen Skyrim-present Prince rows are drafted, all-Prince CAT-6 record/readback is complete, and remaining Daedric blockers are runtime/display proof, live sender proof, wrong/generic-source silence, stack/Survey legibility, and deeper Hircine/Molag Bal curse-access checks.

**2026-06-04 AEST - Daedric Batch 0 static proof:** `references\authoring\PDV_DaedricBatch0_D18ProofLedger.md` now records static D-18 proof for Azura / Azurah, Vaermina, Meridia, and Molag Bal. `race-sheets\PDV_DaedricContent_Manifest.md` now includes firing-density sanity paragraphs for those four Princes, and Molag Bal's stigma rows are explicitly curse-state display text, not independent per-act stigma. This is repo proof only: no ESP write, no CAT-6 promotion, and no runtime/display proof claim.

**2026-06-04 AEST - P2 book accepted-route runtime proof:** Minimal in-game smoke with debug level 2 produced strict-manager Papyrus log proof for the first P2 audit packet: Dunmer Azura, Dunmer Boethiah, Imperial public Talos, Nord Old Ways, and Nord Hircine/Arkay. `references\authoring\PDV_Phase20_SourceFillApprovalLedger.json`, `PDV_AllRaceDaedricBetaReadinessLedger.md`, `PDV_Phase20_PreBetaManualChecks_Runbook.md`, and `PDV_Phase20_ManualEvidenceLedger.json` record this as accepted-route proof only. Remaining current-log P2 book targets are Altmer Auri-El/Magnus/Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath, and Redguard ancestor spine; Breton Hidden Art has earlier proof and only needs rerun if a same-log full set is desired. Wrong-origin rejection, generic-source silence, Survey/status clarity, stack snapshots, and manual feel remain open.

**2026-06-04 AEST - P2 book proof expansion and startup UI overlap fix:** Follow-up smoke added strict-manager route proof for Altmer Auri-El/Magnus/Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath, and Redguard ancestor spine. All approved filled P2 book families now have accepted-route proof across session logs: `Papyrus.1.log` for the non-Redguard packet and `Papyrus.0.log` for Redguard after restart/log rotation; Breton Hidden Art remains earlier-log proof only unless a same-log full sweep is desired. Khajiit proved the route in the log, but Survey/status did not visibly change during the smoke and remains a status-clarity follow-up. Orc proved the route, but the test exposed a startup UI overlap where the Prisma startup panel stacked over the CK startup MessageBox; `PDV__ManagerQuest.psc` now suppresses Prisma startup payloads for the CK-backed startup choice/info path until Prisma can own input without a simultaneous MessageBox. `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` compiled cleanly and the verifier summary stayed clean at `FAIL=0, WARN=1, TODO=0, PASS=2699, INFO=29` with only the known unnamed INFO warning.

**2026-06-04 AEST - P2 toast/status wiring audit:** Follow-up source audit found that several P2 book routes were route-proven but not consistently player-facing. `PDV_EventBus.psc` now preserves P2 book source IDs for Altmer, Argonian Hist, and Khajiit Lunar manager calls; `PDV_PlayerEvents.psc` sends Argonian Hist books through the source-preserving helper; and `PDV__ManagerQuest.psc` now gates accepted P2 book toasts for Altmer Auri-El/Magnus/Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath, and Redguard ancestor spine while refreshing the Prisma panel and adding visible one-book Survey/status deltas for Khajiit, Argonian, Orc, and Redguard. `tools\pdv_phase20_runtime_check.mjs` now expects the new Argonian P2 source-preserving marker. `node .\tools\pdv_compile.mjs --script PDV_EventBus`, `--script PDV_PlayerEvents`, and `--script PDV__ManagerQuest` compiled cleanly; content verify stayed `FAIL=0, WARN=0`; strict Phase 20 verifier stayed `FAIL=0, WARN=1, PASS=2699, INFO=29`. Runtime rerun is required for toast + Survey/status proof because this was patched after the previous accepted-route logs.

**2026-06-04 AEST - P2 proof feedback-lane correction:** Altmer retest showed the Survey/status state updating, but Prisma swallowed the expected toast and opened the full Devotion panel in an unclickable state. `PDV__ManagerQuest.psc` now routes P2 book-source proof notices through vanilla `Debug.Notification` only, suppresses Prisma panel auto-refresh for P2 book contextual favors, and removes the Khajiit focus-state panel refresh side effect. Prisma remains the intended replacement UI later, but the current P2 empirical proof lane is top-left notification plus Survey/status check. `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` compiled with `0 error(s), 0 warning(s)`; content verify stayed `FAIL=0, WARN=0, PASS=1081, INFO=4`; strict Phase 20 verifier stayed `FAIL=0, WARN=1, PASS=2699, INFO=29`.

**2026-06-14 AEST - Consolidated manager/codegen/record-wave closeout:** The live manager at `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc` was updated in place after safety backup `Backups\consolidated-build-pass\PDV__ManagerQuest.psc.20260614-143727.bak`. Held likes/dislikes codegen landed on the current Survey manager (`LIKES_DISLIKES_VERSION = 8`, `PRINCE_LD_VERSION = 3`, 315 deity rows, 160 Prince rows). Manager follow-ups landed for Nord scar wording, Khajiit posture toast display labels, Rajhin/Alkosh top-left notices + Prisma toasts, and the Survey recent-events buffer. `tools\pdv-phase20-race-author` now supports reputation-track authoring plus read-only `--check-rewards`, and authored `references\authoring\PDV_ConsolidatedBuildPass_RecordWave.spec.json` into `Devotion.esp`: first-wave Nord/Argonian/Redguard/Khajiit `MESG`/`NOTI` records plus `PDV_RepTrack_ThalmorAlignment` with manager property wiring. Framework backup: `Backups\phase20-race-rewards\Devotion.esp.20260614-145010.bak`; SEQ backup after refresh: `Seq\Devotion.seq.20260614-045101.bak`. Evidence: `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` compiled 0 errors / 0 warnings, `dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec .\references\authoring\PDV_ConsolidatedBuildPass_RecordWave.spec.json` passed, current default `node .\tools\pdv_verify.mjs` reported `FAIL=0, WARN=2, TODO=0, PASS=3038, INFO=43`, `node .\tools\pdv_content_verify.mjs` reported `FAIL=0, WARN=0, PASS=1080, INFO=4`, writer review regenerated 1066 drafted rows, and houseCARL readback confirmed the Thalmor track plus representative message/property bindings. Runtime/manual proof remains open: fresh-save Survey render, likes/dislikes reload, Rajhin/Alkosh feedback, and Altmer alignment-path spot checks are not claimed here.

**2026-06-14 AEST - Reward readback and Breton creed-loss follow-up:** `tools\pdv-phase20-race-author --check-rewards` now readbacks reward SPEL/MGEF packets, copy, magnitudes, night conditions, regen AV PeakValueModifier archetypes, substrate slots, manager properties, and explicit creed-loss spell properties. All ten `PDV_{Race}RewardRecords.spec.json` files pass after refreshing stale regen archetypes in the live framework ESP; `PDV_KhajiitRewardRecords.spec.json` uses `preserveAdditionalEffects` for `PDV_Bless_Khajiit_BaanDar_T3` so its live low-health capstone effect is not stripped by future full refreshes. Breton follow-up: live `PDV__ManagerQuest.psc` now applies the four Breton creed-loss spells persistently from current state bands (`VowIntegrity` strained, `Excommunication` broken, `ExposureRupture` at `WitchcraftExposure >= 100`, Druidic fork betrayal via existing fork state), and `PDV_BretonRewardRecords.spec.json` now wires all four spell properties onto the manager. The source-only threshold-notice follow-up emits one top-left notice when each creed-loss state first becomes active. Backups: manager `Backups\breton-creedloss-routing\PDV__ManagerQuest.psc.20260614-152113.bak` and `Backups\breton-threshold-notices\PDV__ManagerQuest.psc.20260614-160858.bak`; final Breton ESP `Backups\phase20-race-rewards\Devotion.esp.20260614-152246.bak`; final SEQ `Seq\Devotion.seq.20260614-052259.bak`. Evidence: latest `PDV__ManagerQuest` compile 0/0, all-race reward readback PASS, Breton readback PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, writer review regenerated 1066 rows, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`. Runtime/manual proof and breach-source quest routing remain open.

**2026-06-14 AEST - Imperial Concordat secondary modifiers:** `tools\pdv-phase20-race-author` now writes and readbacks deity track modifier arrays via `deityTrackModifiers`. `PDV_ImperialRewardRecords.spec.json` wires Arkay and Stendarr to the live `PDV_RepTrack_ConcordatStanding` record: Arkay `[1.0,1.0,1.0,0.85,0.85]`, Stendarr `[1.15,1.15,1.0,0.85,0.85]`. The deployed manager adds `GetImperialConcordatPressureForAction` / `ApplyImperialConcordatAction` for the resolved eight-action point table and routes hidden Talos shrine pressure through `hidden_talos_shrine` while preserving `-15`. Backups: manager `Backups\imperial-concordat-modifiers\PDV__ManagerQuest.psc.20260614-152707.bak`; ESP `Backups\phase20-race-rewards\Devotion.esp.20260614-153052.bak`; SEQ `Seq\Devotion.seq.20260614-053101.bak`. Evidence: manager compile 0/0, Imperial readback PASS, all-ten reward-spec sweep PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`. Runtime/manual proof and exact source routing for the remaining Concordat actions remain open.

**2026-06-27 AEST - Nord/Imperial reward closeout, felt-neglect ESP batch, and Talos creed debug runtime:** The Nord Nine Divines lane now reuses the existing Imperial Divine reward SPELs for Akatosh, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth, and Mara; no Nord-specific Divine reward records were authored. `tools\pdv_eligibility_reward_coverage_audit.mjs` now gates focusable reward reachability against live Papyrus, live SPEL existence, and filled `PDV__ManagerQuest` VMAD properties, and `pdv_integrity_harness` runs it as blocking. `tools\pdv-neglect-esp-author` wrote/readbacks the felt-neglect batch: Kyne `ResistFrost -8`, Imperial civic `ResistDisease -5`, plus Shor/Tsun/Stuhn/Talos Nord patron neglect spells and manager properties. The medallion is now roster display only: live deities render as non-selectable roster entries and `SelectMedallionEntry` cannot commit a patron. Finally, `PDV__ManagerQuest.HandleTalosBetrayal` and `PDV_MCM` Debug buttons wire the Imperial/Nord focused-Talos `-2/-3` creed-loss smoke path; Imperial also pushes raw Concordat standing toward compliance. Machine/readback proof is clean; runtime/manual Anvil smoke remains the acceptance boundary, and organic Talos betrayal detection is still future work.

**2026-06-14 AEST - Consolidated record-wave recheck clean:** The Redguard curse-state MESG body mismatch found during beta-feel burndown recheck is closed. Re-authoring `PDV_ConsolidatedBuildPass_RecordWave.spec.json` refreshed the live record bodies with backup `Backups\phase20-race-rewards\Devotion.esp.20260614-153521.bak`; SEQ refresh stayed `changed=false` with backup `Seq\Devotion.seq.20260614-053531.bak`. The consolidated record-wave `--check-rewards` now passes, `pdv_content_verify` remains `FAIL=0 WARN=0 PASS=1080 INFO=4`, and default `pdv_verify` remains `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`.

**2026-06-14 AEST - Argonian Molag Bal DominationPressure writer:** The deployed manager now computes the existing `PDV.Curse.Argonian.DominationPressure` flag without adding a VMAD property: it finds `PDV_DaedricPath_Molag` through `PDV_FLST_DaedricPaths_All`, requires Argonian origin + vampire curse + Molag Seeker tier or higher, and lets `PDV_Substrate_ArgonianHist.RefreshHistPosture` resolve Corrupted(4). It also refreshes that posture after Molag live signals / Prince V2 piety changes and syncs the legacy `PDV.Curse.Argonian.HistPosture` debug key to the substrate posture. Molag Bal Argonian accessibility is confirmed by the Daedric contract/readback state `Curse`. `PDV_BetaContract.csv` row `BC-0714` now uses the live `PDV_DaedricPath_Molag` script name instead of the stale proposed `PDV_DaedricPath_MolagBal`; regenerated completeness audit reports `PASS=337`, `GAP-REVIEW=77`, with `BC-0714` PASS. Manager backup: `Backups\argonian-domination-pressure\PDV__ManagerQuest.psc.20260614-154229.bak`. Evidence: `PDV__ManagerQuest` compile 0/0, Argonian reward-spec readback PASS, `pdv_completeness_audit` PASS, `pdv_content_verify` `FAIL=0 WARN=0 PASS=1080 INFO=4`, and default `pdv_verify` `FAIL=0 WARN=2 TODO=0 PASS=2929 INFO=43`. Runtime/manual proof remains open.

**2026-06-07 AEST - Phase 2 all-race static gate closeout:** The automated/static Phase 2 reward/receiver gate is complete across all ten races. Live Papyrus source remains under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`; tracked snapshots and docs record the verifier surface. Closeout evidence: `node .\tools\pdv_compile.mjs --all` compiled every PDV script with `0 error(s), 0 warning(s)`; `node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json` reported `PASS=2841, WARN=2, INFO=30`; `node .\tools\pdv_phase20_base_wiring_audit.mjs` reported `sourceProperties=39`, `sourceFillRecords=30`, `routeEntries=24`, and `rewards=10`; `node .\tools\pdv_prisma_ui_audit.mjs` passed 11 checks; `node .\tools\pdv_content_verify.mjs` reported `PASS=1081, WARN=0, FAIL=0, INFO=4`; and `node .\tools\pdv_phase2_reward_readback_audit.mjs --json` reported `PASS=1268`. `tools\pdv-phase20-p2-receiver-author` now also owns Green Pact and capstone static check modes, while `tools\pdv_phase2_reward_readback_audit.mjs` owns read-only Phase 2 reward/capstone/readback gating. Runtime/manual beta proof remains open: run all ten `PDV_BetaTestPacket_{Race}.md` packets and update `PDV_PreBetaRaceGateLedger.md` plus `PDV_Phase20_ManualEvidenceLedger.json` before external beta.

**2026-06-08 AEST - Quest-reaction matrix runtime wiring first pass:** `tools\pdv_quest_matrix_compile.mjs` now compiles the frozen quest-reaction matrix, Part D faucet CSV, stance matrices, quest-stage readback, and a narrow six-quest manual FormID fallback into live PapyrusUtil JSON at `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionMatrix.json`. The generated JSON self-test passes at 95 quest-stage keys, 71 watched quests, and 14 non-deferred faucet acts, plus source-backed form/effect lists for Namira `DA11AbFortifyHealth`, Dibella `FavorFortifySpeechcraft`, Peryite `DA13Spellbreaker`, Clavicus Masque, curated alcohol/flesh/apparel/tomes, and Black Books. Live `PDV_PlayerEvents.psc` registers the JSON quest watch list and routes quest-stage, book, equipped-object, magic-effect, and blocked-hit Spellbreaker faucet signals through `PDV_EventBus.psc`; live `PDV__ManagerQuest.psc` applies stance-aware matrix cells, direct daily piety deltas, Daedric stigma, and curse refresh markers. Compile evidence: `node .\tools\pdv_compile.mjs --script PDV_EventBus`, `--script PDV_PlayerEvents`, and `--script PDV__ManagerQuest` each pass at 0 errors / 0 warnings. Verification evidence: `pdv_content_verify --json` stays `PASS=1081, INFO=4`; `pdv_verify --json` stays `PASS=2837, WARN=3, INFO=34`. This is compile/readback wiring proof only; in-game quest-stage/faucet smoke, negative TABOO/stigma proof, visible status/Survey feel, and remaining deferred/owned-later hooks such as staff-use, disease polling, marriage, and curated bargain fragments remain open.

**2026-06-04 AEST - Phase 20 manifest-route and reward-contract wave:** `PDV_Phase20_P2ImmersiveReceivers.manifest.json` now owns exact-stage route entries as well as approved book source fills. `tools\pdv-phase20-p2-receiver-author --check-route-entries` validates 24 static `PDV_PlayerEvents.psc` quest-stage branches against manifest route keys, duplicate guards, mutual-exclusion groups, and dispatch targets. Weak or branch-unproven candidates live in `PDV_Phase20_ContentHook_ClaudeReviewPacket.md` and are not live-fill authority. `PDV_Phase20_RewardRecordContracts.json` plus `tools\pdv-phase20-reward-author` define the all-ten-race T1 reward `SPEL`/`MGEF` wave; `PDV__ManagerQuest` now compiles with manager-owned reward sync/removal source, live reward records are authored, and manager VMAD reward spell properties are wired. Framework backups include `Backups\phase20-race-rewards\Devotion.esp.20260604-223803.bak` and `Devotion.esp.20260604-224251.bak`. Final automated gates passed: reward `--check`, P2 source-fill, exact-stage, and route-entry checks; `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` with `0 error(s), 0 warning(s)`; `node .\tools\pdv_content_verify.mjs` at `FAIL=0, WARN=0, PASS=1081, INFO=4`; and strict Phase 20 verify at `FAIL=0, WARN=1, PASS=2814, INFO=29` with only the known unnamed INFO warning. Runtime/manual proof for Active Effects display, save/load, Survey clarity, and balance feel remains the next boundary.

**2026-06-06 AEST - Prisma/P2 integration boundary:** `references\authoring\PDV_PrismaIntegrationBoundary.md` now keeps Prisma as a separate UI integration track from P2 gameplay proof. P2 remains authoritative for route/source/reward state through readback, logs, top-left notifications, Survey/status, and manual evidence; Prisma consumes manager-owned typed payloads for toasts, panels, medallion presentation, and future always-on HUD work. Always-on HUD is not implemented and is not required for P2 proof. Final readiness needs both P2 gameplay proof and Prisma UI proof.

**2026-06-06 AEST - Prisma instrument pass:** `native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js`, `index.html`, and `styles.css` now render a manager-owned panel `instrument` payload for piety, lunar, Hist, ancestor, forge, sect, and branch modes. `PDV__ManagerQuest.psc` builds the instrument JSON, emits substrate toasts for current substrate routes, and changes Redguard/Bosmer quasi-patron symbols to real substrate marks instead of generic journal fallback. `tools\sync-devotion-to-live.ps1` copied the four tracked UI/source files into `D:\Wabbajack\modlists\Anvil\mods\Devotion`; repo/live hashes matched. `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` compiled with `0 error(s), 0 warning(s)`; `node .\tools\pdv_content_verify.mjs` passed at `FAIL=0, WARN=0, PASS=1081, INFO=4`; and `node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json` passed at `PASS=2827, WARN=2, INFO=29`.

**2026-06-06 AEST - Phase 20 all-race base wiring audit:** `tools\pdv_phase20_base_wiring_audit.mjs` now provides a compact read-only base-mod audit for the all-race scaffold. It checks `PDV_Phase20_P2ImmersiveReceivers.manifest.json`, `PDV_Phase20_RewardRecordContracts.json`, and the live `PDV_PlayerEvents.psc`, `PDV_EventBus.psc`, and `PDV__ManagerQuest.psc` sources. Current pass: 34 P2 receiver contracts, 30 approved source-fill records, 24 static quest-stage routes, and 10 T1 reward contracts across all ten races. Full live Papyrus compile passed for every PDV script with `0 error(s), 0 warning(s)`, content verify stayed clean at `PASS=1081, INFO=4`, and strict Phase 20 verify stayed clean at `PASS=2827, WARN=2, INFO=29`. Runtime/manual proof and additional exact-source approvals remain separate gates.

**2026-06-06 AEST - Beta-feel release gate lock:** `references\authoring\PDV_BetaFeelReleaseGate.md` now defines the accepted beta-feel proof bar. Console-assisted proof is valid when the console sets up the situation and the final PDV trigger, feedback, rejection, Survey/status, reward, or stack behavior is exercised in game. Race Beta-Feel release requires all ten races to record expected-build and edge-build packets, wrong-origin/generic-source checks, Survey/status clarity, reward or state notes, stack snapshots, known issues, and tester stop conditions. Full Devotion Beta-Feel release also requires all sixteen Skyrim-present Princes to clear the Daedric 20C/CAT-6 readback plus runtime/display proof bar.

**2026-06-06 AEST - Prisma toast display-label fix:** `native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js` now renders stable symbol keys such as `auri-el` through display labels for toast deity names, preserving payload/glyph keys while showing player-facing `Auri-El` casing. The fixed file was copied to `D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js` after Skyrim closed; `node --check` passed for repo and live `app.js`, and `node .\tools\pdv_prisma_ui_audit.mjs` passed ten checks including the live display-name guard.

**2026-06-06 AEST - Khajiit restarted packet and Azurah label fix:** The currently wired Khajiit lunar packet is recorded as Conditional-pass. Words of Clan Mother Ahnissi and The Tale of Dro'Zira produced Prisma toasts, Survey/status visuals passed, wrong-origin rejection and generic-source silence passed, and the reward/stack check correctly remained pending below threshold. After the 2026-06-10 runbook sweep, the structured Khajiit closeout blocker is only the `assetStatus` manual-ledger slot; live edge focus sources for Baan Dar, Rajhin, Alkosh, or another approved Khajiit edge route remain future expansion outside the currently filled wired-lunar packet. `native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js` now maps normalized `azura` symbol keys to player-facing `Azurah`; the file was copied to the live Devotion Prisma view, and `node .\tools\pdv_prisma_ui_audit.mjs` now passes eleven checks including the Azurah display-name guard. After closed-Skyrim log readback still showed the old lowercase manager trace, `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` recompiled the already-correct source with 0 errors and 0 warnings and verifier summary `FAIL=0, WARN=2, PASS=2827, INFO=29`.

**2026-06-06 AEST - Race proof restart boundary:** Focused in-game proof is now recorded for Altmer MQ104 stage 160 and Khajiit Words of Clan Mother Ahnissi. Altmer passed live route/log proof plus manual Survey Devotion readout for Lorkhan pressure/crisis language. Khajiit passed strict-manager log proof plus in-game Survey/status movement and no unwanted full Prisma/MCM auto-open. These are accepted-source packet passes, not whole-race beta-feel passes. Next runtime work should restart as full per-race beta-test packets under `PDV_BetaFeelReleaseGate.md`, covering expected build, edge build, accepted source, wrong-origin/generic rejection, Survey/status, reward or state-layer proof, stack snapshot, known issues, and tester stop conditions.

**2026-06-10 AEST - Altmer beta-packet stack snapshot closed:** The current Altmer beta packet now has manual reward/stack evidence. Tester read the approved Auri-El/Magnus/Xarxes books, Survey Devotion showed Auri-El foundation, `Current standing: Unproven`, and `Last favor: Dawn steadiness`, and Active Effects showed `Altmer: Dawn Steadiness` with matching source. `PDV_BetaTestPacket_Altmer.md`, `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_PreBetaRaceGateLedger.md`, `PDV_RuntimeEvidenceTracker.md`, and the active in-game testing queue now treat Altmer as pass for the current race beta-feel packet. Final-world placement remains a separate proof bucket.

**2026-05-31 AEST - Phase 20 no-in-game-proof workplan:** `references\authoring\PDV_Phase20_NoInGameProof_Workplan.md` now owns the remaining Phase 20 work that can continue before additional Skyrim runtime proof. The packet separates allowed repo/readback/planning work from deferred manual proof, and sequences gate-ledger hardening, hook contracts, static verifier expansion, final placement contracts, stack audits, Survey/status copy prep, CAT-6 target-record proof, recognition packet prep, and Daedric proof-path closeout. `references\authoring\PDV_Phase20_NoInGameProof_Gates.json` is the structured verifier target for the same boundary, and `references\authoring\PDV_Phase20_ManualEvidenceLedger.json` is the pending structured intake for future manual/runtime evidence.

**2026-06-02 AEST - Balancing retune implementation:** Implemented the balancing handoff in source and live framework records. `PDV__ManagerQuest` now uses `PIETY_DAILY_MAX_DELTA=4.3`, `GAIN_RATE_SCALE=1.32`, `DECAY_GRACE_DAYS=2.0`, `TIER_DOWN_HYSTERESIS=5.0`, Orc post-clamp gain multipliers (`Stronghold=1.0`, `City=0.75`, `Legion/Exile=0.60`), and a vampire `IsAedric` passive-floor bypass. `PDV_DeityBase` defaults now use thresholds `25/50/85` and exposes `IsAedric`. `tools\pdv-balancing-author` retuned Kyne, Talos, Auri-El, Y'ffre, Z'en, and Baan Dar VMAD scalar properties in `Devotion.esp`; framework backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\balancing\Devotion.esp.20260602-185006.bak`. Compiled `PDV_DeityBase` and `PDV__ManagerQuest`, refreshed SEQ, and the full bridge strict gate is clean at `PASS=2369, INFO=29`, with no `FAIL`, `WARN`, or `TODO`.

**2026-05-31 AEST - CAT-6 Khajiit Tier 1 pilot; 2026-06-04 grant ownership refresh:** `tools\pdv-phase20-cat6-author --create-missing` created/finalized the pilot-provisional `PDV_Bless_Khajiit_Lunar_T1` `SPEL` plus `PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen` and `PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist` in `Devotion.esp` from the exact race content manifest row. Both effects are night-gated from 7PM through 7AM, and the source text says "At night" to match. Framework backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\cat6-khajiit-lunar-t1\Devotion.esp.20260531-184518.bak`. The standalone pilot grant-unwired boundary is superseded by the all-ten-race reward contract wave: `PDV_Phase20_RewardRecordContracts.json` and `tools\pdv-phase20-reward-author` now own Khajiit reward grants with the other race T1 rewards. Runtime/manual proof for Active Effects display, save/load, Survey clarity, and balance feel remains pending.

**2026-05-31 AEST - Experience Mode design merge:** `references\PDV_ExperienceMode_DesignReference.md` and `references\authoring\PDV_ExperienceMode.manifest.json` are merged as planning contracts for `Pilgrim's Path` default/hard and `Wayfarer's Path` easy. Runtime is not live yet; remaining work is `PDV_ModePreset`, `PDV_GLO_Mode`, MCM/status surfacing, manager gain/cap/decay/grace scalars, ActionRouter cheap-repeatable gating, verifier readback, and two-mode runtime smoke.

**2026-05-31 AEST - Nord content review merge:** The Nord content review branch resolved `race-sheets\PDV_RaceContent_Manifest.md` conflicts and keeps Nord as the full content pilot while all ten race-facing sections now carry full draft prose. The content caveats are authoring-side, not runtime-side: long CK-facing slot IDs may need Phase 19 shorthand, and all draft strings still require ratification/promotion before ESP record ownership.

**2026-05-30 - Argonian Hist/People proof slice:** `PDV_Substrate_ArgonianHist` is now a concrete compile-clean substrate for Hist, People, and Void values with gentle Hist-distance dawn decay, a People buffer, Sithis threshold counting, bed-of-choice cadence counters, and posture labels. `PDV__ManagerQuest`, `PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now compile with Argonian route IDs `60-63`, manager handlers, Survey/status surfacing, dawn refresh, and curse-posture refresh. `tools\pdv-phase20-argonian-author --create-missing` attached the concrete substrate, created/wired `PDV_State_ArgonianHistPosture`, created/wired four ACTI proof base records, and wired manager properties with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-argonian\Devotion.esp.20260530-215821.bak`. `references\authoring\PDV_Phase20_ArgonianProofPlacement_Runbook.md` defines the remaining CK-owned placement packet; `--check-placements` currently fails only on the four expected missing `PDV_REFR_Argonian*` references. After compile, helper authoring, and SEQ refresh, `node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json` is clean at `PASS=1633, WARN=1, INFO=30`, with only the existing unnamed CK-authored INFO warning.

**2026-05-30 - Altmer proof-placement handoff:** `references\authoring\PDV_Phase20_AltmerProofPlacement_Runbook.md` now defines the CK-owned placement packet for the four wired Altmer proof ACTIs. Each trigger surface in the Altmer manifest now declares a `placementRefEditorId`, `tools\pdv-phase20-altmer-author --check-placements` verifies the four `PDV_REFR_Altmer*` references after CK save, and `--strict-phase20-altmer` is ready to read back those references once `placementStatus` is promoted beyond `manual-placement-required`. This does not automate placement; it makes the manual boundary exact and verifier-ready.

**2026-05-30 - Altmer curse-message slice:** `PDV__ManagerQuest` now compiles with Altmer vampire exile pressure, werewolf hard halt, cured-vampire scar text, and status/survey summary helpers. `tools\pdv-phase20-altmer-author --create-missing` now creates/wires `PDV_Msg_Altmer_VampireExiledPath_Entry`, `PDV_Msg_Altmer_VampireExiledPath_Recognition`, and `PDV_Msg_Altmer_CurseState_WerewolfHardHalt` on `PDV__ManagerQuest`, with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-altmer\Devotion.esp.20260530-212200.bak`. The Altmer manifest status is now `curse-message-wired`; CK placement/attachment of the proof ACTIs and runtime proof remain open. The focused Phase 20 gate after compile, helper authoring, and SEQ refresh is `PASS=1549, WARN=1, INFO=30`, with only the existing unnamed CK-authored INFO warning.

**2026-05-30 - Altmer trigger-proof slice:** `PDV_EventSignalActivator` and `PDV_EventSignalEffect` now compile with Altmer route support for route IDs `50-53`, including `SignalValue` and `SignalSourceId` so generic proof records can route Lorkhan pressure and crisis-source variants without bespoke scripts. `tools\pdv-phase20-altmer-author --create-missing` now creates/wires four Altmer ACTI trigger proof base records: `PDV_ACTI_AltmerDragonbornCrisisSignal`, `PDV_ACTI_AltmerLorkhanPressureSignal`, `PDV_ACTI_AltmerDawnSteadinessSignal`, and `PDV_ACTI_AltmerOrthodoxCostSignal`, with backup `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-altmer\Devotion.esp.20260530-210740.bak`. `references\authoring\PDV_Phase20AltmerImplementationCosting.manifest.json` is now `trigger-proof-wired`; CK placement/attachment, Exiled vampire handling, and runtime proof remain open. The focused Phase 20 gate after compile, helper authoring, and SEQ refresh is `PASS=1543, WARN=1, INFO=30`, with only the existing unnamed CK-authored INFO warning.

**2026-05-30 - Altmer source, crisis-record, and first favor-record slice:** `PDV__ManagerQuest`, `PDV_EventBus`, and `PDV_EventTypes` now compile with the first Altmer runtime source scaffold. The manager owns `PDV_AltmerCrisisTrack`, crisis-state intake, bounded Lorkhan pressure routing, rejected-surface assertions, `GetAltmerSummary()`, debug helpers, and two real contextual-favor families: quiet dawn steadiness and marked orthodox costly enforcement. The manager activates those through `TryActivateContextualFavor(FAVOR_LANE_ALTMER, ...)` and suppresses the clean positive lane while Altmer curse/exile pressure is active. The event bus exposes route helpers for Lorkhan pressure, crisis source, dawn steadiness, and orthodox costly enforcement; event IDs `50-53` are reserved in `PDV_EventTypes`. `tools\pdv-phase20-altmer-author --create-missing` created and wired `PDV_State_AltmerCrisis` plus the two Altmer favor `KYWD` / `MGEF` / `SPEL` records, with a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-altmer\`. Later trigger-proof work moved the manifest to `trigger-proof-wired`; Exiled vampire handling, CK placement/attachment, and runtime proof remain open.

**2026-05-30 - Phase 18A/B status surface and Nord pilot closeout:** Phase 18A/B is runtime-proven. `PDV_MCM` now opens on a small Player page, hides numeric Status/Debug behind `StorageUtil` key `PDV.UI.DeveloperOptions`, and exposes a Survey Devotion action. `PDV__ManagerQuest` grants `PDV_SPEL_SurveyDevotion` without changing the selected power and owns thematic status APIs; the original source-2 auto-equip call is superseded by grant-only handling and an exact Voice-slot SPEL record. The manager suppresses Nord commitment offers/contextual favors while vampire rupture is active, and keeps `PDV.Nord.VampireScar` after cure without clearing patron piety. `tools\pdv-phase18-author --create-missing` created/wired `PDV_SPEL_SurveyDevotion`, `PDV_MGEF_SurveyDevotion`, and the three Nord curse messages with a backup under `Backups\phase18\`. Froki, Heimskr, Andurs, and Aela are CK-authored/live as branch/topic/unnamed INFO chains. The strict Phase 18/Nord verifier resolves those INFOs by speaker, prompt, response, owning topic, and condition stack; after SEQ refresh and the voice-slot source contract it is clean at `PASS=1185, INFO=28`, with no `FAIL`, `WARN`, or `TODO`. Fresh-save player/runtime proof has passed for Player page behavior, Developer Options persistence, Survey broad/focused states, Hircine/werewolf tension, vampire suppression/cure scar, save/load persistence, and per-speaker positive/negative dialogue behavior for Froki, Heimskr, Andurs, and Aela. Current 2026-07-14 strict readback no longer supports the old dialogue-completeness claim: all four Nord dialogue chains are absent in both the pre-power-fix backup and the active ESP, producing 20 strict Phase 18/Nord failures; this is pre-existing debt, not a power-slot regression.

**2026-05-24 - Phase 10 Dunmer runtime closeout:** Counted runtime proof completed the Dunmer substrate proof-graduation slice. Fresh Dunmer baseline showed `DunmerAncestor=metric=0.000000; tier=0; prayers=0; homes=0` and all active/deity piety readbacks at `0.000000`. The private/home shrine ACTI route `31` advanced the substrate to `metric=8.000000; tier=1; prayers=0; homes=1`; after waiting for the daily gate, the portable shrine ACTI route `30` advanced it to `metric=13.000000; tier=1; prayers=1; homes=1`. Patron piety remained separate, save/load persistence passed, and the combined strict gate is clean at `PASS=847, WARN=0, FAIL=0, INFO=28`. Log search found `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` with the Phase 10 session and one PDV Dunmer tier trace, while `C:\Users\Admin\Documents\My Games\Skyrim.INI\SKSE\PapyrusTweaks.log` is only plugin logging. The later next-packet helper changed portable to `PDV.Signal.DunmerPortableShrine.Activator`, kept private/home on `PDV.Signal.DunmerHome.Activator`, and added verifier coverage for distinct cooldown keys.

**2026-05-24 - Phase 9 runtime closeout:** Counted Bosmer runtime proof completed all Phase 9 path-state acceptance surfaces: proof activators for route IDs `41-45`, Living Story one-day offer/accept/confirm, Exchange two-day offer/accept/confirm, Bandit Road two-day offer/accept/confirm, Old Contract three-day re-entry offer/accept/confirm, save/load persistence after re-entry, Old Contract Green Pact reckoning `Renounce`, and Old Contract reckoning `Recommit`. The proof pass exposed a real `PDV_StateTrack` bug where only two evidence days were retained even though Old Contract re-entry requires three; `PDV_StateTrack.psc` and `.pex` now retain/count a third evidence day. The final combined strict verifier stayed clean at `PASS=808, WARN=0, FAIL=0, INFO=28`.

**2026-05-20 - Overnight enabler implementation pass:** The first approved overnight pull-forward work is now real in source and docs without changing slice completion claims. `PDV__ManagerQuest.psc` now records per-deity commitment signal days from positive piety writes, requires two signal days within seven before the Kyne commitment pilot can offer, removes the active-patron decay exemption, and guards decay to once per in-game day. Its original per-deity cooldown timer model was superseded on 2026-06-25 by `PDV.Commitment.Offered` / `PDV.Commitment.Refused` guards: one offer per qualification, reoffer only after lapse-and-rebuild, and terminal per-deity refusal. The Prisma overlay path now canonicalizes deprecated toast aliases into a stable five-event contract for `favor`, `dawn`, `neglect`, `tier`, and `rivalry`; the bridge README and `PDV_Architecture_v3.md` Section 16.6 now agree that those overlay toasts are stable while panel payloads and other event shapes remain prototype. Verification for the pass stayed clean: `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` succeeded on 2026-05-20 21:06:27 AEST, and `node .\tools\pdv_verify.mjs --strict-pattern-proving` also passed on 2026-05-20 21:06:41 AEST with zero `FAIL`, `WARN`, and `TODO`. Remaining proof boundary for tomorrow is runtime smoke on accepted-patron decay, a staged Kyne two-signal-day offer check, and deciding whether `Refuse` should eventually apply an authored piety-drop fraction.

**2026-05-20 - Phase 7 Civil War join markers locally confirmed:** The final open Phase 7 social-pressure packet is now narrowed to exact local records rather than seed prose. Local `Skyrim.esm` readback confirmed `CW01A` (`Joining the Legion`, `Skyrim.esm:0D517A`) and `CW01B` (`Joining the Stormcloaks`, `Skyrim.esm:0E2D29`) as the first clean join markers; both expose objective `160` `Take the oath` and complete at stage `200`. The recommended hook point is stage `200` on both quests because it is the verified once-only completion surface. The manual fragment contract is now documented in `references\authoring\PDV_Phase7_CivilWar_Closeout_Checklist.md`: preferred path is a vanilla-safe SKSE mod event line in the fragment, `SendModEvent("PDV.ConcordatCompliance")` on `CW01A` and `SendModEvent("PDV.ConcordatDefiance")` on `CW01B`. `PDV_PlayerEvents` now registers these mod events on the live player alias and routes them through `PDV_EventBus.RouteConcordatPressure(...)`. This became the preferred posture after CK fragment compilation repeatedly proved brittle around custom PDV script visibility and duplicate/ghost fragment-property state. These hooks move `ConcordatStanding` only; Talos award remains the hidden-shrine defiance route.

**2026-05-20 - Phase 7 external-hook verification boundary:** The current strict verifier now fully covers PDV-owned Phase 7 surfaces and is clean at `FAIL=0, WARN=0, TODO=0`, but it does not yet read back external vanilla quest fragment edits on `CW01A` / `CW01B`. Treat the Civil War fragment wiring plus runtime smoke as the real final closeout step even though the PDV-owned strict gate is already green. The dedicated operator packet for that last mile now lives in `references\authoring\PDV_Phase7_CivilWar_Closeout_Checklist.md`.

**2026-05-20 - Phase 7 fully closed:** The last manual packet is now done. `CW01A` stage `200` and `CW01B` stage `200` both compile and save on the live framework ESP using the tiny fragment calls `SendModEvent("PDV.ConcordatCompliance")` and `SendModEvent("PDV.ConcordatDefiance")`. Runtime proof in `Papyrus.0.log` now shows the full external-hook chain for both sides: at 16:38:24 AEST, `CW01A` logged `PlayerEvents: Concordat compliance mod event routed.` with `EventBus: RouteConcordatPressure complete: 20 adjustment 15`; at 16:42:44 AEST, `CW01B` logged `PlayerEvents: Concordat defiance mod event routed.` with `EventBus: RouteConcordatPressure complete: 21 adjustment -15`. No Talos award is attached to either Civil War join marker. Durable lesson: for vanilla quest fragments, `SendModEvent(...)` proved more reliable and more compatibility-friendly than fragment properties, inline EventBus casts, or helper-bridge plumbing, while keeping all real devotion math inside PDV-owned scripts. The post-closeout strict gate was rerun and stayed fully clean: `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` => `FAIL=0, WARN=0, TODO=0, PASS=588, INFO=28` at 2026-05-20 16:44 AEST.

**2026-05-18 - Khajiit sleep ingress proof and origin-runtime lesson:** The `PDV_Player` alias is now live on `PDV__ManagerQuest` with `PDV_PlayerEvents` attached and its three alias properties filled (`PDV_EventBusService`, `PDV_OriginQuest`, `PDV_GLO_DebugLevel`). The debugging lesson from this pass is that the hard part was runtime timing, not missing linkage: fresh/load paths could still see Skyrim's temporary Nord placeholder and bake `PDV_GLO_OriginRace = 0` before Khajiit settled. `PDV__MainQuest` now defers origin work to alias-side ingress, `PDV_PlayerEvents` queues origin retries, and `PDV_Origin` treats the first Nord read as provisional. Early Khajiit sleep attempts before resetting the live runtime global should be treated as exploratory only, not counted proof. Counted Khajiit smoke should reset the runtime global in-game if a stale save already baked the wrong value, confirm `PDV_GLO_DebugLevel = 2`, then sleep once and inspect `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. The counted proof on 2026-05-18 showed `EventBus: RouteSleepStop complete`, `Manager: Khajiit moon observance routed...`, and `KhajiitLunar: Moon observance recorded...` with `PDV_GLO_OriginRace` holding at `6`. The later Slice 1 receiver pass closed the remaining Dunmer normal-play shrine trigger boundary.

**2026-05-18 - Prisma UI bridge scaffold:** Prisma UI's API header is installed and visible through the Anvil MO2 MCP. Added `native\DevotionPrismaBridge\` as the first C++ SKSE bridge scaffold, vendored `PrismaUI_API.h`, mirrored the initial `PrismaUI\views\Devotion\` HTML/CSS/JS panel into the live `Devotion` mod, and added compile-clean native Papyrus declarations in `PDV_PrismaBridge.psc` / `.pex`. Visual Studio Build Tools 2022 and portable xmake are now installed locally; the `releasedbg` DLL builds cleanly, exports the expected SKSE plugin entrypoints, and copies `DevotionPrismaBridge.dll` / `.pdb` to `Devotion\SKSE\Plugins\`. The vendored local Prisma header is intentionally shimmed for CommonLibSSE-NG by avoiding `Windows.h`, while the installed MO2 Prisma API header mod remains unchanged.

**2026-05-19 - Prisma devotional UX prototype:** The first real Prisma view now renders a devotional panel rather than a raw metric card: Patron, Today, and Debug tabs; stance/rivalry notes; piety progress; recent devotional acts; suggested rites; and payload-driven transient toasts. Toast/panel marks now use an inline SVG symbol registry for deities and system notices instead of initials, with larger marks and thicker rings for readability. The bridge/native DLL now exports the new Papyrus route `SendOverlayJson(payload)` so event toasts can use the overlay receiver without focusing the panel path. `PDV__ManagerQuest` gained the first Papyrus toast helper plus dawn and active-patron positive-gain hooks. The Prisma client now expands compact event payloads for `favor`, `dawn`, `neglect`, `tier`, and `rivalry` into authored-feeling tone/title/message defaults while still allowing explicit copy overrides. Updated `index.html`, `styles.css`, and `app.js` were mirrored to `D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\` for in-game iteration. A single-file static share demo lives at `scratch\DevotionPrismaDemo.html`; it embeds the current CSS/JS and forces demo mode for Discord-style preview sharing.

**2026-05-19 - Prisma bounded-monorepo decision:** Keep Prisma UI in the main PDV repo for now as a bounded subsystem under `native\DevotionPrismaBridge\`. This keeps the SKSE bridge, Papyrus native declaration, Prisma view source, and payload contract together while the UI is tightly coupled to PDV runtime events. `scratch\DevotionPrismaDemo.html` is a generated/share review artifact, not canonical source. Reassess a separate UI repo only if Prisma gains its own JS build system, asset pipeline, UI test suite, independent release cadence, non-PDV reuse target, or recurring context noise for Papyrus/CK work.

**2026-05-16 - Completed phase docs archived:** Finished Phase 2/3 walkthroughs, older planning/delivery notes, and the now-complete Phase 4/5/6 CK walkthroughs were moved to `archive/completed-phase-docs-2026-05-16/` so the root folder stays focused on living architecture/setup/standards docs.

**2026-05-16 - Recovery artifacts archived:** One-off repair/generation files from the overlay merge-back and MCP bridge investigation were moved to `archive/pdv-recovery-tools-2026-05-16/`. They are historical/emergency-only. The active PDV workflow remains `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, `tools/pdv_author.mjs`, and the living CK step docs at repo root.

**2026-05-16 - Schema-first authoring posture:** Text-first ESP authoring via a future Mutagen-backed build tool is worth keeping as a design direction, but it is not part of the live PDV workflow yet. Until such a tool exists and is verified against the framework, speculative schema drafts are not authoritative project state. The active source-of-truth set remains the living docs, PDV `.psc` files, `Devotion.esp`, verifier expectations, and tracked `pdv_author` manifests/overlays.

**2026-06-07 AEST - Daedric CAT-6 record/readback gate (attachment model corrected 2026-07-13):** `references\authoring\PDV_DaedricPrinceRecordContracts.json`, `tools\pdv_generate_daedric_contract.mjs`, and `tools\pdv-daedric-author` own the all-sixteen-Prince Daedric CAT-6 record/readback packet. The pass authored and checked per-Prince QUST/SPEL/MGEF/MESG records, stigma globals, arrays, concrete path VMAD wiring, and `PDV_FLST_DaedricPaths_All` membership in `Devotion.esp`. All sixteen `PDV_DaedricPath_<Prince>` scripts compile; each quest attaches exactly its concrete script and inherits `PDV_DaedricPathBase` behavior without a direct base attachment. The 2026-07-13 correction removed the redundant base VMAD entry from all sixteen live quests and added a fail-closed verifier invariant. Original gate evidence stayed clean at `pdv-daedric-author --check` PASS, `pdv_content_verify` `FAIL=0, WARN=0, PASS=1081, INFO=4`, strict Phase 20 race-costing `PASS=2841, WARN=2, INFO=30`, and Phase 2 reward readback `PASS=1268`. Runtime/display proof remains separate: controlled/debug senders, live vanilla senders, wrong/generic-source silence, stack/Survey legibility, and deeper Hircine/Molag Bal curse-access checks are still required before beta-display readiness.

**2026-06-07 AEST - Daedric controlled MCM + QASmoke sender surface:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc` now exposes a Debug-page `Daedric display proof` section driven by `PDV_FLST_DaedricPaths_All`. It cycles all sixteen Prince paths and provides reset, commitment signal, Seeker/Devoted/Champion/lapse forcing, stigma, summary MessageBox, notification, Prisma toast hooks, EventBus sender routing, generic-silence probing, and a one-prompt `Route all Princes` sweep for controlled in-game smoke. `tools\pdv-daedric-author --create-missing` also placed sixteen route-200 QASmoke refs (`PDV_REFR_Daedric_<Prince>_LiveSender_QASmoke`) plus route-201 `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`; `--check` readbacks all 17 refs to their ACTI bases. Latest framework backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\Devotion.esp.20260607-191318.bak`. `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_EventBus --script PDV_EventTypes --script PDV_EventSignalActivator --script PDV_EventSignalEffect --script PDV_MCM` compiled with 0 errors and 0 warnings; verifier readback confirmed the MCM and manager Daedric FormList properties. Tester handoff: `references\authoring\PDV_DaedricControlledProof_Runbook.md`.

**2026-06-07 AEST - Daedric exact organic senders:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_PlayerEvents.psc` now registers sixteen Daedric-specific PO3 quest-stage FormLists and routes exact vanilla stages into `PDV_EventBus.RouteDaedricPrinceSignal`: Boethiah `DA02` 100, Azura `DA01` 100, Vaermina `DA16` 190, Meridia `DA09` 500, Molag Bal `DA10` 200, Mephala `DA08` 60, Malacath `DA06` 200, Dagon `DA07` 100, Sheogorath `DA15` 200, Namira `DA11` 100, Sanguine `DA14` 200, Clavicus Vile `DA03` 200, Hermaeus Mora `DA04` 100, Nocturnal `TG09` 200, Peryite `DA13` 100, and Hircine `DA05` 100. `tools\pdv-daedric-author --create-missing` created/read back all sixteen `PDV_FLST_Daedric_<Prince>LiveSources` FormLists, filled each with its exact `Skyrim.esm` quest FormKey, and wired all sixteen properties on the `PDV_PlayerEvents` alias script. `node .\tools\pdv_compile.mjs --script PDV_PlayerEvents --script PDV_MCM` compiled with 0 errors and 0 warnings. Latest framework backup: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\Devotion.esp.20260607-194539.bak`. This is ready for in-game proof but not counted until the stages are exercised and checked with `tools\pdv_daedric_runtime_check.mjs --strict-manager --source organic`.

**2026-06-07 AEST - Daedric sender runtime checker:** `tools\pdv_daedric_runtime_check.mjs` now checks the Daedric sender route markers from Papyrus logs. Self-test passes for all sixteen Prince route-200 markers plus the route-201 generic silence marker, and the checker derives Prince order from `PDV_DaedricPrinceRecordContracts.json` so it stays aligned with the authored FormList/ESP order. `--strict-manager` accepts Prince-specific `eventbus_200_*` manager traces by default; `--source qasmoke`, `--source mcm`, and `--source organic` narrow the required manager marker to physical QASmoke, MCM, or exact PO3 quest-stage sender proof. Use `node .\tools\pdv_daedric_runtime_check.mjs --strict-manager --source organic` after exact-stage in-game activation when debug level 2 traces are enabled.

**2026-06-07 AEST - Daedric in-game smoke packet:** `tools\pdv_daedric_ingame_packet.mjs --write` now generates `references\authoring\PDV_DaedricInGameSmokePacket.md` from the current all-Prince contract. The packet gives the tester a compact route sheet: preflight, MCM `Route all Princes` checker, QASmoke activator names/EditorIDs/positions plus `help` and `player.placeatme` fallback, all sixteen organic `setstage` routes, and the matching `--source qasmoke` / `--source organic` runtime-check commands. This is a handoff artifact only; it does not replace manual Active Effects, MessageBox, Prisma, generic-silence, save/load, stack, or Hircine/Molag curse checks.

**2026-06-07 AEST - Daedric test-readiness preflight:** `tools\pdv_daedric_test_readiness.mjs --deep` now passes with `PASS=71`. It is the read-only launch preflight for the Daedric smoke packet: contract count, packet freshness/content, per-Prince QASmoke packet rows, evidence-intake command coverage including `--from-runtime-check`, structured runtime-evidence ledger schema/rows/slots, beta-display gate presence, live PEX freshness, Devotion profile activation, framework ESP/SEQ, Papyrus log path, process state, Daedric author readback, and organic source-mode runtime checker self-test.

**2026-06-07 AEST - Daedric runtime evidence intake:** `tools\pdv_daedric_evidence_intake.mjs --init` created `references\authoring\PDV_DaedricRuntimeEvidenceLedger.json` with all sixteen Princes pending runtime/display proof. The helper records per-Prince slots for MCM route, QASmoke route, organic route, generic silence, Active Effects, summary MessageBox, Prisma/notification, save/load, stack legibility, manual feel, and Molag/Hircine curse no-double-fire. `--from-runtime-check --source mcm|qasmoke|organic` now runs the Daedric runtime checker and records route slots only when matching Papyrus log proof passes; current-log negative checks fail cleanly without changing the ledger. `tools\pdv_daedric_beta_gate.mjs` fails closed on the current pending ledger and becomes the final all-Prince beta-display proof gate after runtime evidence is recorded. This is the structured place to record evidence after Skyrim testing; it intentionally starts as `PENDING` and does not upgrade any Prince from readback alone.
