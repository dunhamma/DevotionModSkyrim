# AGENTS.md -- Devotion (PDV) Mod Project

## What This Project Is

A Skyrim Special Edition (SSE) mod called **Devotion** that tracks the player's religious devotion based on their race's authentic theological traditions. The system reads the player's daily behavior and adjusts per-deity piety, which then gates tiered blessings, neglect effects, and patron-specific content.

The mod is designed for roleplayers who want mechanically meaningful, lore-accurate religious practice -- not generic shrine-visiting bonuses.

---

## Agent skills

### Issue tracker

Issues for this repo live in GitHub Issues for `dunhamma/DevotionModSkyrim`. See `docs/agents/issue-tracker.md`.

### Triage labels

This repo uses the default Matt Pocock engineering-skill triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This repo should be treated as a single-context project; skills should read the repo-level context and architecture docs relevant to the task. See `docs/agents/domain.md`.

---

## houseCARL v1.7+ Direct Plugin Work Rule

**This rule supersedes any older instruction in this file, `PDV_MOD_SETUP.md`, tool tables, or handoff docs that conflicts with it.** Where a doc still tells you to run a retired helper, the doc is stale: follow this rule and flag the drift.

For **all** Skyrim plugin work -- reading records, resolving conflicts and load-order winners, creating or editing records, authoring patches, merging, verification -- call the `housecarl_*` MCP tools directly. Do not route through, consult, extend, or re-implement any local wrapper, adapter, bridge, capability matrix, or authoring helper, and do not build new ones.

houseCARL is the writer **and** the reader. Verification is a direct `housecarl_read_record` / `housecarl_cross_plugin_query` readback after the write. That readback **is** the proof -- no adapter, no text-scraping layer, no proof-ledger pipeline in between.

### The retired layer

`tools/pdv_author.mjs`, `tools/pdv_writer_review.mjs`, `tools/creation-authoring`, `tools/creation-merge-runner`, and every `tools/pdv-*-author` helper are **deleted from disk**, preserved only in `tools/pdv-authoring-trees-retired-2026-07-13.zip`. Do not use, restore, extend, or copy their dry-run/backup/proof-ledger pattern into new work. Historical references in the Build Status checklist and Decisions Log below are **record of what happened**, not instructions -- do not act on them.

The bridge's generated artifacts (capability matrices, platform proof-ledgers, CKPE/creation/dialogue fixtures) are archived under `_retired/bridge-era-2026-07-14/`. **Never cite anything in that folder as a description of houseCARL's capabilities.** In particular, its `capability-matrix.skyrimse.json` claims `"supported": 1` / `"research_only": 116` -- that describes the retired bridge, not houseCARL, which reads and writes every record type Mutagen models.

Keep using PDV compile, audit, runtime-check, evidence, documentation, and non-ESP generation tools where they do not write plugin records.

### Sanctioned programmatic path (the only one)

The read-only gate scripts -- `tools/pdv_housecarl_p2_readback.mjs`, `tools/pdv_pantheon_record_readback.mjs`, `tools/pdv_pantheon_presentation_readback.mjs`, via `tools/lib/pdv_housecarl_stdio.mjs` -- speak houseCARL's own MCP JSON-RPC for deterministic CI-style gates. They carry no capability matrix, scrape no output, and never write. They are gates, not a bridge. Interactive/agent plugin work still goes through the `housecarl_*` MCP tools directly.

### Stale beliefs -- do not re-derive these

The retired layer encoded a picture of houseCARL that is years of releases out of date. If you find any of these in a local doc or infer it from local code, it is **false**:

| Stale belief | Current reality |
|---|---|
| "houseCARL supports only some record families; keep a supported/research-only matrix" | houseCARL reads and writes **every record type Mutagen models, by construction**. There is no partial-coverage matrix to maintain. The CKRA "77 supported / 56 research_only / 27 readback-only" numbers describe the retired bridge, not houseCARL. |
| "Wiring a gendered arm (ARMA `SkinTexture.Male`) throws an NPE; fall back to NIF path rewrites" | Fixed in houseCARL **1.6.0**. Single-gender skin ArmorAddon writes work in all lanes. Retest instead of working around. |
| "`into=` needs a three-way match between value, MO2 folder suffix, and ESP basename" | Fixed in **1.4.0**. `into=` resolves by ESP basename **or** folder name. |
| "houseCARL's MO2 parser fails on spaced `key = value` lines in ModOrganizer.ini" | Fixed in current releases. |
| "houseCARL output must be normalized/parsed by an adapter before it is usable" | You are the intended reader. Call the tool, read the output, act on it. |
| "Writes are safer through a manifest-driven local author tool with dry-run/backup modes" | houseCARL's default lane already writes to a **new** plugin, leaving originals untouched; the in-place lane is explicit and consented. A second, unverified local writer adds risk, not safety. |
| "`housecarl_diff_record` misses ADDED list elements -- use it for what was *retuned*, never what was *added*" | **False**, reproduced-disproven 2026-08-05. A FormList that gained a member diffs unscoped and names the addition; a quest whose VMAD went 4 -> 14 script properties enumerates all 10 additions by name when scoped with `fields=`. See `handoff/PDV_SnapshotFingerprinting_Handoff_2026-08-04.md`. |

If a task appears blocked by a houseCARL limitation, **first reproduce it with a direct `housecarl_*` call on the current version** and read the actual error. Do not trust a locally recorded "known issue" without reproducing it. Only a reproduced, current-version failure is worth reporting upstream.

**"Current version" means the binary you are actually calling.** The gate scripts and the MCP tools can resolve to *different houseCARL installs*, and that split is not visible in the output. It is how the diff-record belief above was manufactured: `tools/lib/pdv_housecarl_stdio.mjs` was pinned to the AppData build, which has no `housecarl_diff_record` at all and ignores `format:"json"`, while the MCP tools used the newer `.claude/skills/housecarl/` build. A limitation reproduced through a script is only evidence about that script's binary. The driver now resolves `.claude/skills` first and fails loudly if no server is found; `PDV_HOUSECARL_EXE` overrides.

**Reading git history around this:** commit `817dd39b` ("docs(tools): record that snapshot diffing misses ADDED list elements") records the *false* belief and is public. Its retraction lives in the two handoff docs and in this table, not in that commit, so the commit reads as authoritative in isolation. The fix and the retraction are commit `00279734`.

---

## Project File Map

| File | Role | Use When |
|------|------|----------|
| `AGENTS.md` | This file -- project context, build status, decisions log | Context for Codex across sessions |
| `PDV_STANDARDS.md` | Operating rules: doc hygiene, description discipline, investigation/safety rules | **Read at session start.** Re-read Section 1 + Section 4 when in doubt |
| `PDV_MOD_SETUP.md` | Dev environment, architecture, build order, variable reference | Setting up tooling, debugging, tracking decisions |
| `tools/pdv_compile.mjs` | Node wrapper for the verified PapyrusCompiler import chain | Compiling stale/all/targeted PDV `.psc` files into the Devotion MO2 mod |
| `tools/pdv_compile_inventory_audit.mjs` | Read-only shipped-script inventory gate | Checking that `pdv_compile --list` exactly matches every source/PEX pair owned by `PDV_ReleasePayload.manifest.json` in the compiler's configured source root; catches clean-rebuild omissions without compiling bytecode |
| `tools/pdv_verify.mjs` | Read-only Node/Mutagen verifier for PDV's Anvil MO2 setup | Checking CK wiring, script freshness, SEQ state, MO2 profile state, and strict phase-gate readiness |
| `tools/pdv_ascii_guard.mjs` | Non-ASCII / mojibake guard and fixer for `.psc` source (any text via `--ext`) | Scanning or `--fix`ing script comments before commit/handoff so smart punctuation and stray BOMs never reach Codex as mojibake; backs the PostToolUse `.psc` write-hook; see PDV_STANDARDS 6.9 |
| `tools/pdv_prisma_ui_audit.mjs` | Read-only Prisma UI policy audit | Checking that gameplay scripts do not open focused/blocking Prisma UI except through explicit default-off/player-owned surfaces; also fails closed if Book-of-Days manager/MCM bytecode is stale against the live journal payload contract |
| `tools/pdv_v3_prisma_extraction_audit.mjs` | Read-only V3 PRISMA extraction gate | Checking the 114-function presenter residence, manager/presenter backrefs, seven origin presentation virtuals across all ten adapters, removal of the eight multi-race content switches, and exact 48-public/66-private call-graph contract |
| `tools/pdv_v3_debug_extraction_audit.mjs` | Read-only V3 DEBUG extraction gate | Checking the 136-function debug-harness residence, retained manager dispatcher/registers, typed MCM double-hop, eight module references, zero Global/console surface, and exact 111-public/25-private call-graph contract |
| `tools/pdv_v3_runtime_acceptance.mjs` | Fail-closed V3 runtime/manual evidence gate and intake CLI | Starting a commit-pinned Gate 1/2/final evidence run, recording individual proof slots, scanning fresh Papyrus logs, invalidating evidence after runtime-sensitive changes, and refusing to infer player-surface PASS from route logs |
| `tools/pdv_active_effect_naming_audit.mjs` | Direct houseCARL Active Effects naming audit | Checking every `PDV_Bless_*` spell and child MGEF: parent spells carry the family/tier heading, while child effects carry concise mechanical labels or distinct scripted-effect names |
| `tools/pdv_penalty_serialization_audit.mjs` | Direct houseCARL penalty serialization gate | Checking every linked `Neglect`, `Disfavor`, and `Price` spell effect for `Recover` plus exactly one engine-valid magnitude/`Detrimental` encoding; non-modifier script effects are reported separately |
| `tools/pdv_copy_census.mjs` | Read-only player-facing copy census and UX-workbench generator | Keeping live runtime text, current gameplay contracts, and prior writing references independently traceable before prose edits; `--refresh-live` reads `Devotion.esp` through direct houseCARL batches, while the census, Nord/Kyne packet, race-batched formal-offer view, dynamic-piety viability model, and Penpot-importable UX map remain ignored and regenerable under `generated/pdv-copy-census/` |
| `tools/pdv_mcp_check.mjs` | MCP server health check -- pings the Anvil MO2 MCP server and validates the active profile is `Devotion Dev` | Confirming the server is live and on the right profile before any `mo2_*` tool use; surfaces ECONNREFUSED with actionable startup instructions |
| `tools/pdv_papyrus_lookup.mjs` | BellCube-backed Papyrus lookup helper for Skyrim SE script/function pages | Looking up Papyrus signatures, script pages, and likely function locations on `papyrus.bellcube.dev` before guessing at API surfaces |
| `tools/skyui_compile_shim/*.psc` | Minimal compile-only SkyUI base-class shims used by `pdv_compile.mjs` | Compiling `PDV_MCM.psc` without inheriting noisy third-party MCM source overrides |
| `tools/pdv-authoring-trees-retired-2026-07-13.zip` | **Retired** Mutagen/CKPE record-author helper trees (`pdv_author.mjs`, `pdv_writer_review.mjs`, `creation-authoring`, `creation-merge-runner`, all `pdv-*-author`) | Forensics only. All plugin record reads/writes/verification now go through the `housecarl_*` MCP tools directly -- see the houseCARL Direct Plugin Work Rule above. Do not restore, extend, or copy the dry-run/backup/proof-ledger pattern. |
| `tools/sync-devotion-to-live.ps1` | Guarded live-file sync helper | Copying repo-tracked Prisma assets, StorageUtil assets, and selected live-source Papyrus files, including `PDV_MCM.psc`, into the existing Anvil Devotion mod only after backing up the live ESP/SEQ/Scripts/SKSE/Prisma artifacts; refuses empty or damaged live mod folders |
| `tools/pdv_package_release.mjs` | Release zip builder -- the ONLY sanctioned path to a `dist/` bundle | Packaging a public build from the live Anvil Devotion mod folder. Never hand-roll the zip (rc1 leaked an 876KB `.orig`); the script gates on version, ANAM, and archive contents. Note its gates are narrower than `pdv_verify.mjs` -- a green package run is not a green verify run |
| `tools/pdv_release_proof_refresh.mjs` | Script-backed live release-proof refresh and gate | Re-deriving the active profile, ESP identity, both record-count frames, exact contested set, critical winners, VMAD verdict, script pairs, and claimed asset providers; use `--capture` for review and the confirmed `--refresh` path to update `PDV_HousecarlReleaseProof.json` |
| `references/authoring/PDV_ReleaseProofRefresh_Runbook.md` | Release-proof refresh authority and operator checklist | Deciding when proof refresh is required, which fields gate packaging, which require manual confirmation, and which runtime/manual claims remain open after a green package build |
| `tools/pdv_cli_flag_contract_audit.mjs` | Read-only contract gate for the fourteen issue #61 CLI flags | Checking that each retained flag is semantically consumed and retired aliases are absent from active tool contracts |
| `tools/pdv_file_semantics_audit.mjs` | Read-only EOL/file-comparison contract gate | Checking the current 22-tool inventory, helper selection, `.gitattributes` pins, and LF/CRLF behavior fixtures |
| `references/authoring/PDV_FileComparisonSemantics.json` | File comparison and generated-text EOL authority | Recording whether each audited tool asks a normalized-text, exact-byte, mixed, or removed-dead-code question |
| `D:\...\Devotion\Scripts\TempleBlessingScript.pex` (+ `Source\*.psc`) | Shipped loose-file override of the vanilla shrine activation script | Reasoning about shrine behavior or install order. Ships from 1.0.4 to undo Requiem's bugfix-pack dispel-all line. **Devotion must sit BELOW any Requiem bugfix pack in MO2** or their copy wins silently -- see the 2026-07-27 Decisions Log entry |
| `D:\...\Devotion\PDV_GreenPact_KID.ini` | Green Pact mod-added food distribution | Adding mod-added meats to the Bosmer Green Pact reward lane. KID distributor files live at the Data root. Rules match by item NAME, not FormID/EditorID; vanilla and DLC meats are the static record set, not KID |
| `references/authoring/PDV_BosmerVariety_PapyrusHandoff.md` | Bosmer variety `PDV__ManagerQuest.psc` runtime layer | Authoring/applying the Bosmer dream/hearth/Songs/signature/Naming Papyrus (property decls, exact call-site insertions, full functions) modeled on the shipped Argonian variety code; closes the manifest's `scriptLayerPending` |
| `tools/pdv_cumulative_rebalance.mjs` | Highest-tier-only cumulative rebalancer | ONE-SHOT rewrite of focused 3-tier families to per-ActorValue cumulative totals (+ per-effect `effectName`). NOT idempotent (a re-run would double magnitudes); specs are stamped `cumulativeRebalanceApplied` on `--write` and refused thereafter. Already applied 2026-06-11 to all 9 non-Argonian specs -- future magnitude tuning edits the cumulative values in the spec by hand |
| `tools/pdv_reward_desc_regen.mjs` | Reward description regenerator | Text-only pass that rewrites `playerFacingText` from the CURRENT spec effects (keeps the no-digit flavor lead, appends an accurate named effect summary); safe to re-run after any magnitude change, never re-sums |
| `tools/pdv_likesdislikes_gen.mjs` | Likes/dislikes Papyrus codegen | Emitting the `LoadRowsForDeity` function body from `PDV_DeityLikesDislikes.csv` to stdout for paste into the live `PDV__ManagerQuest.psc`; editing the CSV alone is inert, and removals also require the `ClearRowsForDeity` superset + a `LIKES_DISLIKES_VERSION` bump |
| `tools/pdv_dislike_consequence_audit.mjs` | Read-only dislike-consequence strict audit | Checking the V2 shared-domain spec, 32-deity CSV threshold/domain coverage, manager/router source gates, and live ESP readback via the author helper; run with `--strict-dislike-consequence` |
| `tools/pdv_phase20_base_wiring_audit.mjs` | Read-only all-race Phase 20 base wiring audit | Checking all ten races for P2 receiver contracts, live source-fill coverage counts, static quest-stage routes, and T1 reward manager script references against the live Devotion source |
| `tools/pdv_beta_readiness_audit.mjs` | Read-only beta-readiness closure audit | Failing closed on broad "scaled out" or beta-feel claims until authority, readback, runtime-route, manual, and release-claim proof buckets all line up |
| `tools/pdv_phase2_reward_readback_audit.mjs` | Read-only Phase 2 static reward/capstone readback audit | Checking Phase 2 reward records, manager deity/reward/neglect properties, FLST membership, SGE/SEQ state, Green Pact static layer plus the plant-food baseline, fallback capstone records, and real-hook classification |
| `tools/pdv_breton_architecture_audit.mjs` | Read-only Breton architecture contract audit | Checking all three traditions, 25/50 pacing and daily cap, Survey/Book layered identity, all Champion mappings, Hidden Art integrated-Prince price/stigma rules, Notorious behavior, debug/startup reconciliation, retired reward cleanup, and live-sync coverage |
| `tools/pdv_requiem_penalty_audit.mjs` | Read-only Requiem felt-penalty audit | Checking the Argonian/Breton converted negative Health penalties, old regen-MGEF orphaning, and Imperial `ResistDisease -5` preservation against specs plus live `Devotion.esp` |
| `tools/pdv_eligibility_reward_coverage_audit.mjs` | Read-only live-code-to-ESP reward coverage audit | Checking every focusable/offer-eligible reward row derived from live Papyrus against live SPEL existence and filled `PDV__ManagerQuest` VMAD properties |
| `tools/pdv_vmad_audit.mjs` | Read-only plugin-wide VMAD script-property audit | Sweeping EVERY scripted record in `Devotion.esp` for missing or unfilled script properties: sibling outliers against an immediate-parent family (the Syrabane shape), declared-but-absent object properties, and present-but-null bindings. Parses declarations from the MO2 LIVE tree, never the lagging `live-source/` mirror, and warns when they diverge. Architecturally-correct absences live in `references/authoring/PDV_VMAD_AuditWaivers.json`; the verdict is the exit code |
| `tools/pdv_phase20_runtime_check.mjs` | Read-only Papyrus log checker for Phase 20 QASmoke runtime proof | Checking Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer route markers after in-game proof activation; route proof only, not a replacement for Survey/status immersion checks |
| `tools/pdv_daedric_runtime_check.mjs` | Read-only Papyrus log checker for Daedric sender runtime proof | Checking Daedric route-200 sender markers from QASmoke, MCM, or exact organic quest-stage sources plus the route-201 generic silence marker after in-game proof activation; route proof only, not a replacement for Active Effects/display/curse/stack checks |
| `tools/pdv_daedric_queststage_check.mjs` | Read-only static guard checker for the 16 Daedric organic quest-stage route guards | Verifying every `(questFormID, stage)` guard in `PDV_PlayerEvents.psc` resolves to a real vanilla quest stage (vs `vanilla-quest-stage-readback.csv`) and that its `RouteDaedricPrinceSignal` index matches the contract manifest order; catches silent-miss + index-drift that MCM/QASmoke route proof cannot see, with no game needed |
| `tools/pdv_daedric_ingame_packet.mjs` | Read-only Daedric tester packet generator | Writing `PDV_DaedricInGameSmokePacket.md` from the all-Prince contract with MCM sweep, QASmoke activator/help fallback, exact organic `setstage`, and matching runtime-check commands |
| `tools/pdv_daedric_test_readiness.mjs` | Read-only Daedric in-game preflight | Checking contract, packet, live PEX freshness, Devotion profile activation, ESP/SEQ, Papyrus log path, process state, and optional deep Daedric readback/self-test before Skyrim smoke |
| `tools/pdv_daedric_evidence_intake.mjs` | Structured Daedric runtime/manual evidence intake helper | Initializing and updating `PDV_DaedricRuntimeEvidenceLedger.json` after in-game proof; can auto-record MCM/QASmoke/organic route slots from `pdv_daedric_runtime_check` pass results without treating readback as beta-display evidence |
| `tools/pdv_daedric_beta_gate.mjs` | Read-only Daedric beta-display gate | Failing closed until all sixteen Princes have passed runtime/display evidence slots in `PDV_DaedricRuntimeEvidenceLedger.json`, including Molag/Hircine curse no-double-fire |
| `tools/lib/pdv_daedric_effect_model.mjs` | Explicit Daedric boon/price effect model | Reviewing or changing Prince effect axes, exceptional multi-effect packets, or independently tunable ActorValue-family magnitude bands before regenerating the record contract |
| `tools/pdv_generate_daedric_contract.mjs` | Report-first Daedric contract compiler and opt-in script scaffolder | Running `--self-test`, detecting reviewed-contract drift, explicitly regenerating `PDV_DaedricPrinceRecordContracts.json`, or scaffolding path scripts to a caller-supplied directory |
| `tools/pdv_patch.mjs` | Offline classification/distribution patcher helper | Validating patch-rule manifests, resolving winning records and payload references from the Devotion Dev load order, and building the generated `PDV_ClassificationPatch.esp` review/live artifact without mutating source plugins |
| `tools/pdv_extract_vanilla_gameplay_refs.mjs` | Read-only Mutagen extraction helper for vanilla/DLC gameplay reference tables | Refreshing generated `references/vanilla-gameplay/extracted/` CSVs before building signal matrices, patcher rules, or compatibility dossiers |
| `tools/pdv_extract_quest_stage_readback.mjs` | Read-only Mutagen quest-stage readback helper for vanilla/DLC quest candidates | Refreshing `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv` before Phase 20 exact-source dossier review; does not write ESP data or authorize source fill |
| `tools/pdv_skyrim_refs_bridge.mjs` | Read-only bridge into the neutral `SkyrimGamePlayReferences` repo | Querying broad vanilla/DLC reference tables without vendoring them into PDV |
| `tools/pdv_quest_matrix_compile.mjs` | Quest-reaction matrix runtime JSON compiler | Compiling the frozen quest-reaction CSVs, stance matrices, quest readback, and curated faucet form lists into live PapyrusUtil JSON at `SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix.json`; run `--check` before writing |
| `tools/pdv_quest_reaction_build.mjs` | Deterministic V3 Quest Reaction catalog/package builder | Generating or exact-byte-checking the two fully-qualified v2 catalogs, 31-file required-catalog/five-adapter FOMOD, receipts, installer simulation, and normalized verified archive from the compatibility manifest plus canonical inputs. The internal model may use camel case, but serialized PapyrusUtil typed-bucket member names must be lowercase, integer arrays must use `intList`, and stored values preserve case; combined Anvil gameplay is green, while Authoria installer/support acceptance remains open |
| `tools/pdv_patch_source_lock.mjs` | Optional-adapter bytecode lock gate | Checking normalized PSC hashes plus exact PEX hashes before V3 package generation; use `--relock` only after reviewed recompilation |
| `references/authoring/PDV_QuestReactionCompatibility.manifest.json` | V3 Quest Reaction compatibility authority | Mapping all 80 integrations to source IDs, plugins, sentinels, CSVs, adapter/package metadata, extension precedence, and disabled-source behavior |
| `tools/pdv_quest_reaction_performance_audit.mjs` | Read-only V3 Quest Reaction ownership audit | Verifying the Runtime-owned bounded FIFO, one scheduler, V3 persistence namespace, Manager callback boundary, ordinary-scope closure before QR submission, lightweight admission, persisted bounded catalog materialization, sanitized toast/Book source attribution, direct EventBus/MCM routing, and Worker retirement |
| `tools/pdv_quest_reaction_characterization.mjs` | Executable V3 Quest Reaction behavior oracle | Running the eight literal interface-level parity fixtures before and during runtime ownership extraction; deterministic proof only, not Skyrim/save/VMAD evidence |
| `tools/pdv_quest_reaction_semantic_adapter_audit.mjs` | Read-only V3 semantic-adapter boundary audit | Verifying AFDI retains its polling lifecycle while submitting one semantic event, owns no devotional outcomes, and leaves no live Manager external-batch callers |
| `tools/pdv_quest_reaction_runtime_check.mjs` | Read-only quest-reaction queue log checker | Checking QR_QUEUE ENQUEUE/BUILD/START/COMPLETE lifecycle, FIFO/coalescing/completion sequence, cross-session-safe timing despite reused `v3qr_N` IDs, admission latency, overflow, stack-dump/broad-scope-abort markers, and normal save-load freeze/thaw observations after an in-game sweep |
| `references/authoring/PDV_V3Slice1QuestReaction.manifest.json` | Ground-up V3 Quest Reaction Slice 1 authority | Locking the deep-module interface, clean-break save boundary, catalog v2 identity/activation/collision rules, packaging shape, parity cases, retirement targets, and Slice 1 exit gates |
| `tools/pdv_signal_floor_smoke_gate.mjs` | Read-only/generated signal-floor smoke gate | Checking the 2026-07-09 signal-floor smoke scenarios against source CSVs, live PapyrusUtil JSON, manager/MCM debug harness tokens, optional Papyrus log markers, and writing `PDV_SignalFloorSmokeLedger.{md,json}` (regenerable report -- on demand, not committed); backend PASS does not replace runtime/manual proof |
| `references/authoring/PDV_SignalFloorSmokeScenarios_2026-07-09.json` | Signal-floor smoke scenario manifest | Source of truth for the 13 representative smoke cases: quest fan-out, main-quest death/lore gods, Sithis, Zenithar, Hircine cure, Season Unending, crypt clear, LD v15, Green Way, Paarthurnax kill/spare, and borderline prove-or-drop rows |
| `references/authoring/PDV_SignalFloorSmokeLedger.md` | Generated signal-floor smoke ledger (regenerable report -- on demand, not committed) | Captures backend/static PASS rows, OPEN runtime marker slots, and manual checks still owed for the master signal-floor handoff; regenerate via `pdv_signal_floor_smoke_gate.mjs --write-ledger` |
| `references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md` | Co-testing operator runbook for 1.0 smoke closeout | Single tester/Codex sheet for machine preflight, signal-floor smoke cards, evidence capture, stop conditions, and the remaining 1.0 gate/evidence sinks; the contract plus a fresh gate run remains the pass/fail authority |
| `references/authoring/PDV_MCMPropertyWiring.manifest.json` | Manifest-driven batch overlay target for PDV_MCM VMAD property wiring | Regenerating one canonical MCM property-wiring overlay instead of accumulating one-off property patches |
| `references/PDV_ExperienceMode_DesignReference.md` | Experience Mode design lock | Planning the single user-facing difficulty toggle: Pilgrim's Path default/hard versus Wayfarer's Path easy, including scalars, MCM surface, storage, and verification expectations |
| `references/authoring/PDV_ExperienceMode.manifest.json` | Experience Mode CK/wiring manifest | Tracking the future `PDV_ModePreset` quest, `PDV_GLO_Mode`, and property-wiring contract for MCM, manager, and ActionRouter integration |
| `references/authoring/PDV_PreflightRouterServices.manifest.json` | Manifest-driven V3 Preflight router-service overlay target | Regenerating the reversible `PDV_PreflightRouterServicesOverlay.esp` canary that co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` |
| `references/authoring/PDV_Phase7SignalReceivers.manifest.json` | Manifest-driven Phase 7 hidden-shrine reference contract | Tracking the actual hidden Talos shrine reference wiring plus the CK-authored Civil War hook contract/proof notes for strict Phase 7 verification |
| `references/authoring/PDV_Phase8ConcordatTalos.manifest.json` | Manifest-driven Phase 8 Concordat/Talos overlay target | Tracking the reversible authoring payload for ConcordatStanding and Talos track-property wiring without treating the overlay as steady-state runtime |
| `references/authoring/PDV_Phase9BosmerState.manifest.json` | Manifest-driven Phase 9 Bosmer path-state + rite contract | Tracking the Bosmer path deity, message, manager-property, proof-surface, and placement contract now that framework record readback is clean |
| `references/authoring/PDV_Phase10_11_DocGrilledPlan.md` | Phase 10/11 doc-grilled plan | Tracking the locked Dunmer substrate graduation and Arngeir/Kynareth privilege-prep decisions |
| `references/authoring/PDV_NextPacket_DocGrilledPlan.md` | Khajiit/commitment/neglect/Phase 11 packet plan | Tracking the current long-smoke packet, remaining CK-owned records, and combined strict gate |
| `references/authoring/PDV_Phase11PrivilegePilot.manifest.json` | Phase 11 privilege pilot contract | Tracking the CK-safe Arngeir/Kynareth recognition gate, live readback, and runtime proof |
| `references/authoring/PDV_DeityCoverageMatrix.json` | Phase 20 full roster authority | Tracking every locked god and Skyrim-present Daedric Prince against every race for response state, hook source, implementation status, verifier status, and runtime proof status |
| `tools/pdv_formal_offer_check.mjs` | Read-only all-race reachability/formal-offer verifier | Checking exact ordinary rosters for all ten races, exact formal-offer deity sets, guarded MCM/debug mutation, no-offer race exclusions, quiet-emergence cues, and delegated ESP/property readback |
| `tools/pdv_prisma_parity_unitd_check.mjs` | Read-only Prisma parity Unit D verifier | Checking the Unit D offer/reorientation/curse/quiet-emergence journal lines, carryover award funnel, director resolver preservation, and Daedric title readback |
| `tools/pdv_prisma_to_oneoh_audit.mjs` | Read-only Prisma-to-1.0 wiring audit | Roll-up checking current Prisma 1.0 producer wiring, source/live parity, repo/live Prisma UI parity, and adversarial negative fixtures before runtime smoke |
| `references/authoring/PDV_MedallionRoster.manifest.json` | Phase 20 medallion roster contract | Showing the full native roster per race while keeping commitment offer-only; live deities display as non-selectable roster entries |
| `references/authoring/PDV_PrismaIntegrationBoundary.md` | Prisma/P2 integration boundary | Keeping P2 gameplay proof separate from Prisma UI presentation while defining the manager-owned state and typed-payload handoff |
| `references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md` | Combined beta-feel blocker ledger | Tracking the current all-ten-race plus all-sixteen-Prince beta-feel gap, including P2 runtime proof, manual evidence, Daedric 20C record/readback proof, and remaining runtime/display blockers |
| `references/authoring/PDV_BetaReadinessClosureAudit.md` | Beta-readiness closure audit runbook | Explaining the fail-closed closure audit, current blocker classes, and proof-bucket boundary before any beta-feel readiness claim |
| `references/authoring/PDV_BetaFeelBurndown.md` | Living beta-feel burndown report | Consolidating current done/open work across the all-race audit, handoffs, race gate ledger, runtime/manual evidence, and current readback rechecks before any beta-feel readiness claim |
| `references/authoring/PDV_DaedricBatch0_D18ProofLedger.md` | Daedric Batch 0 proof ledger | Tracking static D-18 proof for Azura, Vaermina, Meridia, and Molag Bal before any Daedric CAT-6 promotion or ESP write |
| `references/authoring/PDV_DaedricPrinceRecordContracts.json` | Daedric Prince CAT-6 record contract | Generated from the Daedric content manifest and Prince matrix; source of truth for all sixteen Prince record IDs, player-facing text, conservative effect packets, race-state arrays, messages, and author/check expectations |
| `references/authoring/PDV_DaedricControlledProof_Runbook.md` | Daedric controlled in-game proof runbook | Testing all sixteen Prince paths through the MCM Debug page, physical QASmoke live-sender refs, and all sixteen exact organic vanilla quest-stage senders |
| `references/authoring/PDV_DaedricInGameSmokePacket.md` | Compact Daedric in-game tester packet | Generated handoff sheet with preflight, MCM sweep, QASmoke activator names/EditorIDs/positions, organic `setstage` routes, checker commands, and manual observation checklist |
| `references/authoring/PDV_DaedricRuntimeEvidenceLedger.json` | Structured Daedric runtime/manual evidence ledger | Per-Prince proof slots for route markers, Active Effects, summaries, Prisma/notification, generic silence, save/load, stack legibility, manual feel, and curse no-double-fire |
| `references/authoring/PDV_ProjectWideContextHygiene_Audit.md` | Project-wide context hygiene audit | Tracking stale-doc refreshes, preserved historical/scratch context, ignored local artifact cleanup, and future cleanup rules |
| `references/authoring/PDV_Phase20AltmerImplementationCosting.manifest.json` | Phase 20 Altmer implementation manifest | Tracking the Altmer crisis/Lorkhan/favor/curse slice from costing into source scaffold, record wiring, runtime proof, Exiled vampire handling, rejected hooks, verifier expectations, and tuning |
| `references/authoring/PDV_Phase20_AltmerProofPlacement_Runbook.md` | Phase 20 Altmer proof-placement/runtime runbook | Checking the four QASmoke Altmer proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20ArgonianImplementationCosting.manifest.json` | Phase 20 Argonian implementation manifest | Tracking the Argonian Hist/People/Void layered substrate, Hist posture track, proof ACTIs, rejected hooks, immersion proof, and runtime proof expectations |
| `references/authoring/PDV_Phase20_ArgonianProofPlacement_Runbook.md` | Phase 20 Argonian proof-placement/runtime runbook | Checking the four QASmoke Argonian proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20OrcImplementationCosting.manifest.json` | Phase 20 Orc implementation manifest | Tracking the Orc life-mode state track, Stronghold/City/Legion proof ACTIs, rejected hooks, immersion proof, and runtime proof expectations |
| `references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md` | Phase 20 Orc proof-placement/runtime runbook | Checking the four QASmoke Orc proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20RedguardImplementationCosting.manifest.json` | Phase 20 Redguard implementation manifest | Tracking the Redguard sect state track, Crown/Forebear/Ash'abah/Far Shores proof ACTIs, rejected hooks, immersion proof, and runtime proof expectations |
| `references/authoring/PDV_Phase20_RedguardProofPlacement_Runbook.md` | Phase 20 Redguard proof-placement/runtime runbook | Checking the four QASmoke Redguard proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json` | Phase 20 Bosmer implementation manifest | Tracking Bosmer non-hunter favor parity across Old Contract, Living Story, Exchange, and Bandit Road proof ACTIs, rejected hooks, immersion proof, and runtime proof expectations |
| `references/authoring/PDV_Phase20_BosmerProofPlacement_Runbook.md` | Phase 20 Bosmer proof-placement/runtime runbook | Checking the eight QASmoke Bosmer proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20KhajiitImplementationCosting.manifest.json` | Phase 20 Khajiit implementation manifest | Tracking the Khajiit lunar substrate, focus mirror, road-home anchors, Baan Dar/Rajhin/Alkosh proof ACTIs, rejected hooks, immersion proof, and runtime proof expectations |
| `references/authoring/PDV_Phase20_KhajiitProofPlacement_Runbook.md` | Phase 20 Khajiit proof-placement/runtime runbook | Checking the six QASmoke Khajiit proof `PDV_REFR_*` references, then running runtime smoke |
| `references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` | Consolidated Phase 20 QASmoke runtime proof runbook | Tracking the all-race QASmoke route-proof pass, checker commands, proof-label casing rule, Survey/status immersion checks, negative checks, and pre-beta gameplay-scaling closeout criteria |
| `references/authoring/PDV_Phase20*ImplementationCosting.manifest.json` | Phase 20 race implementation-costing manifests | Costing P0/P1 race runtime slices before source or CK work: Altmer crisis, Argonian Hist/People, Orc life-mode, Redguard sect, Bosmer non-hunter parity, and Khajiit lunar/road proof |
| `references/authoring/PDV_PreBetaRaceScalingSpine.md` | Shared pre-beta race-scaling spine | Owning the Altmer -> Khajiit -> Argonian scaling order, P1 packet split, P2 audit-only split, shared gate template, subagent packets, and verification sequence before external beta |
| `references/authoring/PDV_PreBetaRaceGateLedger.md` | Shared pre-beta race gate ledger | Recording all ten race verdicts, normal-session route, accepted/rejected hooks, anti-farm rule, Survey/status result, final placement result, reward floor/ceiling, stack snapshot, expected/edge builds, and blocking follow-up |
| `references/authoring/PDV_PreBetaRaceAcceptanceRubric.md` | Pre-beta race acceptance rubric | Defining the measurable pass/conditional/fail bar for normal-session hooks, rejected-hook coverage, anti-farm cadence, Survey/status clarity, final placement, stack snapshots, expected/edge builds, and manual feel notes |
| `references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` | Phase 20 no-in-game-proof workplan | Planning the remaining Phase 20 architecture, manifests, verifier/readback gates, placement contracts, stack audits, CAT-6 prep, and recognition prep that can proceed before additional Skyrim runtime proof |
| `references/authoring/PDV_Phase20_NoInGameProof_Gates.json` | Structured Phase 20 no-in-game gate packet | Machine-checking all ten race no-game statuses, immersive hook contracts, asset policy, P2 source-scaffold state, stack snapshots, CAT-6 target-record state, recognition packet prep, and Daedric blocker state |
| `references/authoring/PDV_Phase20_AllRaceSourceCuration_Runbook.md` | Phase 20 all-race source curation handoff | Applying the exact-source standard to all ten races before empirical proof; scan-only quest candidates must not be promoted into live FormLists or route sources without specific quest/stage/outcome readback |
| `references/authoring/PDV_Phase20_NextReadbackHook.md` | Phase 20 next-session readback hook | Ready-to-use handoff for the next all-race exact-source readback pass; produces an approval dossier before any live source fill |
| `references/authoring/PDV_Phase20_SourceCurationDossier.md` | Phase 20 quest-stage source curation dossier | Grouping readback-backed all-race quest-stage candidates by race and route family with semantic verdicts and implementation status, without granting live source-fill permission |
| `references/authoring/PDV_Phase20_QuestStageExclusionAudit.md` | Phase 20 quest-stage exclusion audit | Maintaining reason codes, excluded/no-route patterns, and future-review notes for the vanilla/DLC quest-stage inventory |
| `references/authoring/PDV_Phase20_SourceFillApprovalLedger.json` | Phase 20 source-fill approval ledger | Recording approved P2 book-read source fills, blocked quest-stage/non-P2 receiver decisions, duplicate guards, exact-stage gate command, and P2 runtime-check command |
| `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` | Phase 20 P2 immersive receiver manifest | Tracking the source-scaffolded all-race PO3/player-alias receiver FormLists, alias-property wiring, approved book-fill readback, exact-stage quest-source gate, receiver-side anti-farm policy, event families, route targets, asset status, and remaining runtime proof boundary |
| `references/authoring/PDV_Phase20_P2SourceCuration_Runbook.md` | Phase 20 P2 source curation handoff | Separating candidate book, spell, harvest, weather, and quest-stage source directions from approved `sourceFillEntries`; use before adding any live P2 FormList entries |
| `references/authoring/PDV_Phase20_ContentHook_ClaudeReviewPacket.md` | Phase 20 content-hook review packet | Holding weak, broad, lore-controversial, branch-unproven, or non-live-fill hook candidates until local readback plus design review promotes them into the P2 manifest |
| `references/authoring/PDV_Phase20_RewardRecordContracts.json` | Phase 20 first-tier race reward contract | Tracking all ten race T1 reward spell/effect EditorIDs, player-facing text, provisional actor-value magnitudes, Daedric/stack interaction policy, author/wire/check commands, and runtime/manual proof gates |
| `references/authoring/PDV_Phase20_ManualEvidenceLedger.json` | Structured Phase 20 manual evidence intake | Recording pending/future wrong-origin, rejected-hook, Survey/status, final-placement, stack-snapshot, and manual-feel evidence without accidentally converting no-game readiness into beta proof |
| `references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md` | Phase 20 pre-beta manual checks runbook | Handing off from automated source/manifest/readback gates into wrong-origin, generic-hook, Survey/status, stack snapshot, and final-placement manual checks per race |
| `references/authoring/PDV_InGameTestingNeeded_Runbook.md` | Current in-game testing queue | Running the ordered manual/runtime proof pass after repo-side gates: Altmer/Khajiit small gaps, Bosmer DA05, remaining race packets, then Daedric runtime/display proof |
| `references/authoring/PDV_HO_RequiemPenalties_2026-06-30.md` | Requiem felt-penalty implementation handoff | Replaying or auditing the Argonian/Breton negative Health penalty conversion, Imperial preservation ruling, and required backend/readback/houseCARL/adversarial gates |
| `references/authoring/PDV_DislikeConsequence_DesignReference.md`, `PDV_DislikeConsequenceRecords.spec.json`, `PDV_DislikeConsequence_TestLedger.json` | Shared deity dislike-consequence V2 authority | Owning the 7-domain disfavor sting map for the 32 deity likes/dislikes actors, record contract, cutoff bands, standing/source/anti-stack gates, and pending Requiem runtime proof slots |
| `references/authoring/PDV_SessionHandoff_2026-07-11_CoTestPause.md` | 1.0 co-test pause handoff | Resuming after Nord/Imperial felt proof closeout and before Breton architect review on tradition reward deity anchoring |
| `references/authoring/PDV_SessionHandoff_2026-07-05_DunmerCloseout.md` | Dunmer closeout / next-session handoff | Current entrypoint after Dunmer manual/runtime pass; points the next session at strict audit rerun, residual blocker readout, Requiem felt proof, and likes/dislikes reload proof |
| `references/authoring/PDV_SessionHandoff_2026-07-04_ImperialCloseout.md` | Imperial closeout handoff | Superseded by the 2026-07-05 Dunmer closeout; kept as the Imperial V1 manual/runtime evidence record and Book of Days Chronicle / separate Ledger digest watch item |
| `references/authoring/PDV_SessionHandoff_HircineAuditFixes.md` | Hircine/audit-fix session handoff | Picking up after the Hircine display-surface drift, SEQ refresh, Orc ActorValue normalization, ASCII-ledger cleanup, and next Hircine-first Daedric proof commands |
| `references/authoring/PDV_SessionHandoff_BosmerRuntimeFixes.md` | Bosmer runtime-fix handoff | Picking up after Bosmer DA05 proof intake, Naming path-neutral hearth fix, Baan Dar combat-session reroute, Exchange copy refresh, and PeakValueModifier stamina-neglect ESP write |
| `references/authoring/PDV_Phase20_BetaReadinessRemainder.md` | Phase 20 beta-readiness remainder hook | Summarizing what the safe P2 source-fill tranche proves and what remains for automated, manual/runtime, placement/feel, and tester-handoff beta readiness |
| `references/authoring/PDV_BetaFeelReleaseGate.md` | Beta-feel release gate | Defining the console-assisted expected-build plus edge-build proof bar, release scope choices, stop conditions, and final tester handoff checklist |
| `references/authoring/PDV_BetaTestPacket_*.md` | Race beta-test packets | Running console-assisted race beta-feel packets across approved live sources, wrong-origin/generic silence, Survey clarity, reward/stack snapshots, and scoped edge blockers; Bosmer now has a DA05 source packet plus QASmoke fallback |
| `references/authoring/PDV_RecognitionDialogueScalePacket.md` | Planned V2 recognition/dialogue scale packet | Preserving the CK-safe proof pattern for future curated recognition lines while V1 uses non-voiced Survey/status, MCM, MessageBox, notification, spell/effect, book/note, shrine/service-gate, and Prisma surfaces instead of new NPC conversations |
| `references/authoring/PDV_CAT6PromotionPilot.md` | CAT-6 content promotion pilot packet | Proving one low-risk non-dialogue draft-to-ESP-to-handbook promotion chain before broad string promotion |
| `references/authoring/PDV_RaceGameplayBalanceAudit.md` | Multi-lens 1.0 gameplay balance audit | Checking race-by-race gameplay wealth, class/playstyle coverage, non-god immersion lanes, benefit parity, hook reality, writing/surfacing, compatibility, and proof status |
| `references/authoring/PDV_RaceVarietyTranche_Roadmap.md` | Design-locked per-race variety tranches modeled on the Argonian thinness fix, with thinness ranking, resolved decisions, and build order | Building Bosmer/Orc/Altmer/Redguard/Khajiit gameplay-variety tranches; checking locked tranche shapes, shared-site and Baan Dar pairing rules, and the per-race build gates before authoring variety records or runtime work |
| `references/authoring/PDV_RaceRewardBudgetLedger.md` | Race reward-budget working ledger | Tracking foreground rewards, substrates/state layers, contextual favors, privileges, costs, neglect, immersion budget, and overstack/thinness risk before new runtime or content work |
| `references/authoring/PDV_RaceEffectReviewLedger.md` | Race effect-review gate ledger | Locking race-by-race effect families, magnitudes, conditions, stacking, grant/removal, Survey explanation, anti-farm posture, and curse/Daedric interactions for the Phase 20 reward contract and future tuning |
| `references/authoring/PDV_RacePlaystyleCoverageLedger.md` | Race playstyle-coverage working ledger | Tracking warrior, mage, stealth/social, survival/travel, craft/labor, low-violence, and curse/Daedric support across all ten races |
| `references/authoring/PDV_RaceImplementationCostingBacklog.md` | Race implementation-costing backlog | Translating the multi-lens audit into buildable state records, hook sources, rejected-hook assertions, immersion proof, player-facing surfacing, verifier gates, and runtime proof slices |
| `references/authoring/PDV_RacePietyRateAudit.md` | Per-race piety-rate audit (Phase 2 root) | Diagnosing the structural piety-rate skew (only Nord had a working faucet pre-Phase 2) and locking the native-track-as-parity model that the Khajiit pilot proved and Phase 2 propagates |
| `references/authoring/PDV_RaceContractTemplate.md` | Per-race build contract template | Filling one copy per race: foreground patron, offer vs no-offer gate type, piety-feeding acts + anti-farm, creed-violation loss, broad + per-patron 3-tier rewards, substrate/state boons, neglect |
| `references/authoring/PDV_Phase2_DeityRoster_and_ArchitectureRulings.md` | Phase 2 deity roster + binding rulings R1-R8 | Coordination authority: broad-as-state, fixed manager broad-T1 editorIds, R3 per-patron naming, shared-deity ownership map, focusable-only deities, Daedric forks via 20C, three gate shapes, balance invariants; lists owners and reusers + authoring order |
| `references/authoring/PDV_Phase2_CapstoneSignatures.md` | Phase 2 T3 capstone signatures | LOCKED Bosmer/Khajiit + draft per-race capstones; shared mechanism library (M1-M11+) with OK buildable / WARNING fiddly + fallback annotations; locked rules: <=1 cheat-death per race (all once/day), fallback-as-floor binding for all fiddly detections |
| `references/authoring/PDV_{Race}RewardRecords.spec.json` | Per-race reward record spec (x10) | Authoritative record contract for race reward authoring (now performed with the `housecarl_*` MCP tools): deity QUSTs (create:true/false + stances), manager deity + reward + neglect Spell properties, broad + per-patron + substrate/support boons, optional state/reputation/global mirrors, optional message records, V1 Survey recognition, authoring plan |
| `references/authoring/PDV_ConsolidatedBuildPass_RecordWave.spec.json` | 2026-06-14 first consolidated record-wave spec | Authored/read back the first voice-conformance MESG/NOTI tranche plus `PDV_RepTrack_ThalmorAlignment`; later ESP tranches remain in `PDV_NextBuildPass_RecordSpec.md` |
| `references/authoring/PDV_Phase20{Race}ImplementationCosting.manifest.json` | Per-race Phase 20 costing manifests (now complete for all 10) | Imperial/Breton/Dunmer/Nord added 2026-06-07 from `PDV_Phase20_NoInGameProof_Gates.json` P2 audit-only contracts; all 10 race manifests are now under `--strict-phase20-race-costing` |
| `references/authoring/PDV_BetaTestPacket_{Race}.md` | Per-race beta test packets (x10) | Console-assisted normal-play walks: approved live sources, wrong-origin/generic silence, Survey/status clarity, reward/Active-Effects snapshot, stack snapshot, edge blockers |
| `references/authoring/PDV_KhajiitPilot_SmokeTest_Runbook.md` | Khajiit pilot in-game smoke runbook | The proven Phase 1 smoke checks (R1-R7) that the Phase 2 per-race runbooks will mirror |
| `references/authoring/PDV_SessionHandoff_KhajiitPilot.md` | Phase 1 Khajiit pilot handoff | Authoritative session detail for the proven Khajiit pilot; reference for the Phase 2 propagation template |
| `references/authoring/PDV_SessionHandoff_BosmerVarietyLocal.md` | Bosmer variety local-completion handoff (current) | Picking up the Bosmer "The Story Goes On" tranche on the local Windows session: resolve the 4 Songs LCTN FormIDs, dry-run/write `pdv-bosmer-variety-author`, apply the Papyrus handoff, recompile, fresh-save smoke, beta packet, then the Orc batch |
| `references/authoring/PDV_SessionHandoff_Phase2_AllRaces.md` | Phase 2 all-race propagation handoff (current) | Session detail for Phase A design, B1 deity scripts, B2 all-race static closeout, Green Pact/capstone static gate, verification evidence, and the remaining runtime/manual beta packet boundary |
| `references/authoring/patch-rules/*.json` | Tracked offline patcher manifests | Planning/building classification and distribution work against the resolved load order; `tooling-example` rules remain plan-only, `candidate` rules require explicit test-build opt-in, and only `approved` rules emit by default |
| `PDV_Architecture_v2.md` | Full v2 architecture spec -- data model, quest topology, phase plan, stance matrix | Phase planning, writing new scripts, understanding the deity/origin system |
| `PDV_Architecture_v3.md` | Forward architecture and roadmap for everything after the proven Phase 4/5/6 baseline | Planning v3 preflight, structural skeleton, beta gates, launch readiness, and post-v2 subsystem work |
| `PDV_TargetEndStates_1.0.md` | Living 1.0 product target, per-race acceptance state, roadmap traceability | Tracking final 1.0 product readiness and race-by-race end-state closure |
| `archive/completed-phase-docs-2026-05-16/README.md` | Index for completed phase walkthroughs and historical planning docs | Finding archived Phase 2/3/4/5/6 CK guides and earlier planning notes |
| `archive/PDV_DecisionsLog_Archive_2026-05.md` | Dated archive of decisions-log entries rolled out of the live log (foundational decisions, closed Phase 1-9 proofs, V3 preflight/slices/Phase 7, race implementation-lock pass, Prisma, lessons, early session notes) | Looking up the full text or rationale of a decision not in the live Decisions Log window |
| `archive/phase-order-recommendations-2026-05-20.md` | Frozen phase-order review imported from the Claude branch | Rechecking why Section 21.5 adopted the reduced reorder and rejected extra standalone slices |
| `PDV_SkyrimConsoleReference.md` | UESP-sourced console command reference (source of truth) | Any in-game testing or debugging |
| `references/PDV_Anvil_MO2_MCP_Intake.md` | Codex-facing intake of the Anvil MO2 MCP plugin, tool surface, optional binaries, and local setup status | Using or troubleshooting `mo2_*` tools from Codex |
| `references/PAPYRUS_KNOWLEDGE_INTAKE.md` | Papyrus API/reference strategy, source-layer cautions, and BellCube/SKSE intake notes | Any Papyrus scripting, API lookup, or tooling/ref-generation planning |
| `https://github.com/BellCubeDev/papyrus-index` / `https://papyrus.bellcube.dev/` | Primary external Papyrus API index for vanilla, SKSE, and many plugin-provided functions | When local `.psc` source, CK Wiki, or bundled notes do not fully settle a Papyrus signature, inheritance detail, or plugin-surface question |
| `references/authoring/PDV_QuestReactionMatrix.md` | Quest-reaction matrix foundation (Part A act-tag vocab, Part B deity value-profiles, Part C race-stance modulation, Part D/D-3 thin-god faucets, Part E read-and-judge method) | Authoring/maintaining the quest-reaction matrix; the design source of truth |
| `references/authoring/PDV_QuestReactionMatrix_Full.csv` | GENERATED frozen matrix: current source/readback surface is 1978 cells / 172 quest keys / 134 watched quests / 45 deity names after the 2026-07-15 full-main-quest pass. Regenerated by `tools/pdv_quest_tranche_merge.mjs`; do NOT hand-edit | Input to the wiring; per-deity reaction lookup |
| `references/authoring/PDV_QuestReactionMatrix_Tranche*.csv` | SOURCE tranches the Full matrix merges from (T1 Daedric/Nocturnal, T2 questlines, T3 temple/favor, T4 thin-pantheon, T5 aspect-parity, T6 compat core, T7 cross-echo, T8 pool expansion, T9 deity-signal remap, T10 signal floor, T11 main-quest full coverage) | Editing matrix cells (edit a tranche, then re-merge) |
| `references/authoring/PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv` | Source tranche for the 2026-07-09 deity-signal-remap rows, including Syrabane's approved broad 8-row College/warding/plague/hostile-magic slice | Extending/remediating remap quest wiring without hand-editing Full.csv |
| `references/authoring/PDV_PairedDeityEquityAudit.md/.csv` | GENERATED paired-deity equity report (per-deity x channel cross-tab, cluster gaps, name-resolution + Part B presence gates). Do NOT hand-edit; regenerate via the audit tool | Checking same-coin deities have equitable signal access; gate before matrix changes ship |
| `references/authoring/PDV_PairedEquityWaivers.csv` | Hand-maintained accepted-gap list (cluster,editor_id,outcome_stage,deity,reason) consumed by the equity audit | Recording an intentional non-echo with its theological reason |
| `tools/pdv_paired_equity_audit.mjs` | Repeatable paired-deity equity auditor (separate from `pdv_verify.mjs`); exit 1 on unwaived gaps | Re-run after any tranche/faucet/stance change to catch silent-drop + equity regressions |
| `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` | 26 compiled repeatable/activity faucet acts for thin gods and Prince artifact/use lanes, with triggers, anti-farm caps, buildability flags, and compiler-merged equivalent duplicate keys | Wiring the faucet layer (Part D method 2) |
| `references/authoring/PDV_QuestReactionMatrix_WiringSpec.md` | Codex handoff spec: JSON-config data rep, cell-lookup contract, `ApplyDeityReaction` stance-award (Part C2), faucet hook/record table, verification gates | Implementing the quest-reaction wiring into Papyrus/ESP |
| `tools/pdv_quest_tranche_merge.mjs` | Merges the matrix tranches -> Full.csv and emits the per-deity distribution | Regenerating Full.csv after editing any tranche |
| `tools/pdv_quest_matrix_compile.mjs` | Compiles Full.csv + Part D faucets + stance/readback inputs into live PapyrusUtil JSON | Regenerating `PDV_QuestReactionMatrix.json` after matrix/faucet/readback changes; use `--check` for dry-run validation |
| `tools/pdv_deity_signal_remap_adversary_check.mjs` | Static adversary checker for the deity signal remap: shrine daily cap, Syrabane display/reachability, formal-offer eligibility, likes/dislikes versioning, quest-row coverage, and documented exclusions | Rechecking remap guardrails before in-game smoke or further matrix/likes-dislikes edits |
| `references/authoring/PDV_DeitySignalRemap_NextSessionHandoff_2026-07-09.md` | Current remap follow-up handoff: deity-by-deity quest-matrix and likes/dislikes breadth pass, with exact-stage/rejected-context standards | Picking up the next remap wiring tranche |
| `references/authoring/PDV_SignalFloor_MasterHandoff_2026-07-09.md` | Current signal-floor master handoff/closeout: 1071-cell quest matrix, likes/dislikes v15, crypt-clear population, Paarthurnax kill/spare fork, and the remaining runtime smoke boundary | Picking up signal-floor verification, runtime smoke, or post-closeout cleanup |
| `references/authoring/PDV_DeitySignalRemap_InGameSmoke_Runbook.md` | Tester-facing remap smoke runbook with readback, runtime-route, manual visual, adversary, and representative route checks kept separate | Proving the remap in game after source/readback gates are green |
| `references/PDV_RaceArchitecture_DesignReference.md` | Living race architecture reference for theology, curse handling, reward contract, and quest weighting | Resolving per-race design, locking theology decisions, planning future signal matrices |
| `race-sheets/*.md` | Race-by-race player-facing design sheets plus the overview | Keeping readable race gameplay/design summaries in sync with the locked architecture reference |
| `references/vanilla-gameplay/` | Living gameplay mechanics and immersive UX reference backbone | Looking up vanilla Skyrim mechanics, CK signal surfaces, source-backed gameplay tables, or player-experience lessons for PDV design |
| `references/vanilla-gameplay/compatibility/phase20-targets.csv`, `references/vanilla-gameplay/compatibility/PDV_Phase20_CompatibilityNotes.md` | Phase 21 compatibility matrix and operating notes | Tracking Authoria-first list-author package status, target-list evidence, religion-removal assumptions, patch shape, and smoke gates |
| `references/authoring/PDV_ModPackaging_StateAuthority.md` | Living core/PatchHub packaging authority | Read before changing a package or reporting package state; update after every build, archive replacement, or support-status change |
| `references/authoring/PDV_DriftGatePattern.md` | Living authority-declaration and drift-class pattern for competing-source gates | Designing or reviewing a gate that compares authored, generated, staged, live, fallback, or registry sources |
| `references/authoring/PDV_QuestModPatches_ARR_Review_2026-08-06.md` | Preserved ARR packaging review | Source evidence for the modular-hub transition; the living packaging authority owns current state |
| `references/vanilla-gameplay/PDV_SkyrimGamePlayReferences_Bridge.md` | Bridge rules for using `dunhamma/SkyrimGamePlayReferences` from PDV | Pulling neutral reference data into PDV planning without making it design authority |
| `references/phase4/PDV_Phase4_MatrixScaffold.md` | Working conventions and normalization rules for the Phase 4 matrix pass | Understanding matrix scope, crosswalk rules, and output structure |
| `references/phase4/PDV_RaceSignalMatrix.csv` | First-release race/path/layer signal matrix | Planning Phase 4 implementation signals and anti-farm rules |
| `references/phase4/PDV_StanceMatrix.csv` | First-pass per-worship-object per-race stance matrix | Seeding Phase 4 stance properties and rivalry assumptions |
| `references/phase4/PDV_DaedricRacePrinceMatrix.csv` | Prince-first Daedric race-response matrix | Planning Daedric path buildability, race response, and exit logic |
| `references/phase4/PDV_MatrixCrossValidation.md` | Cross-matrix consistency note and intentional divergence log | Verifying the three matrixes against each other and the locked architecture |
| `archive/completed-phase-docs-2026-05-16/*` | Archived Phase 2/3 walkthroughs and earlier planning notes | Historical context only; not part of the active root workflow |
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity equivalency table (all 9 races x all pantheons) | Writing race-specific dialogue, checking deity names, avoiding lore errors |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice, threshold rituals, class variation, era pressures | Designing trigger conditions, writing flavour text, balancing per-race logic |
| `references/tamriel-cursed-worship-4e201.html` | Race-by-race curse-state religious interpretation source | Designing vampire/werewolf theological posture and curse pressure |
| `references/tamriel-daedric-worship-4e201.html` | Race-by-race Daedric practice source | Designing Prince-first paths, stigma, and race-specific Daedric friction |
| `archive/HOUSECARL_*.md`, `archive/Skyrim_Modding_Lessons*.md` | Frozen source material | When PDV_STANDARDS doesn't cover a question and you want the fuller treatment |
| `archive/pdv-recovery-tools-2026-05-16/*` | Historical emergency/generated repair artifacts | Provenance only; do not use as active workflow tools |

### Mod implementation folder

Source and compiled output live at `D:\Wabbajack\modlists\Anvil\mods\Devotion\` (MO2-managed; `meta.ini` present). Source `.psc` files at the root; compiled `.pex` in `Scripts\`. The MCP server is connected to the Anvil MO2 instance with the **Devotion Dev** profile.

Phase 4 design outputs are mirrored for live reference under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\`. The tracked source copies remain under `references/phase4/` in this docs workspace.

**Isolated V3 big-update workspace (2026-07-28):** a separate build space exists for large in-progress work that shouldn't disturb the live Devotion Dev compile/playtest state. Git side: branch `feature/v3-big-update`, checked out in its own worktree at `.claude/worktrees/v3-big-update/` (the primary checkout here stays on `main`) -- run a separate Claude/Codex session rooted in that worktree folder for V3 work so branch switches in one session never disturb the other's checked-out files. MO2 side: same Anvil instance throughout, just a separate mod folder `D:\Wabbajack\modlists\Anvil\mods\Devotion-V3Dev\` (a full copy of live `Devotion\`) plus MO2 profile **"Devotion V3 Dev"** (clone of `Devotion Dev`, fresh empty saves), which disables `Devotion` and enables `Devotion-V3Dev` in its place -- both provide a file named `Devotion.esp`, so plugins.txt needed no edit, only the mod toggle. To compile against it, set `PDV_COMPILE_SOURCE_ROOT` / `PDV_COMPILE_OUTPUT_ROOT` to the `Devotion-V3Dev\Scripts\Source` / `Devotion-V3Dev\Scripts` paths before running `pdv_compile.mjs` (the script already supports this override, no toolchain edit needed) -- safe to run concurrently with a normal compile since it's fully env-scoped per terminal. To playtest or run any `housecarl_*` MCP call against it, switch MO2's active profile to "Devotion V3 Dev" first -- houseCARL auto-follows the active profile on its next call, and this is a SINGLE shared toggle for the whole instance, so it is NOT safe to interleave live houseCARL/playtest work on both profiles at once; confirm which profile is active (`housecarl_load_order_status`, no args) before trusting any read tied to a status claim.

Script folder layout (CK toolchain):
```
Devotion\
  Scripts\
    PDV__MainQuest.pex
    PDV_Origin.pex
    PDV__ManagerQuest.pex     <- compiled output
    PDV_ActionRouter.pex
    PDV__SM_KillActor.pex
    PDV_DeityBase.pex
    PDV_Deity_Kyne.pex
    PDV_Deity_Talos.pex
    PDV_Deity_AuriEl.pex
    PDV_EventTypes.pex
    PDV_EventBus.pex
    PDV_EventSignalActivator.pex
    PDV_EventSignalEffect.pex
    PDV_SurveyDevotionEffect.pex
    PDV_PlayerEvents.pex
    Source\
      PDV__ManagerQuest.psc   <- source (edit here, compile via CK)
      PDV_Origin.psc
      PDV_ActionRouter.psc
      PDV__SM_KillActor.psc
      PDV_DeityBase.psc
      PDV_Deity_Kyne.psc
      PDV_Deity_Talos.psc
      PDV_Deity_AuriEl.psc
      PDV_EventTypes.psc
      PDV_EventBus.psc
      PDV_EventSignalActivator.psc
      PDV_EventSignalEffect.psc
      PDV_SurveyDevotionEffect.psc
      PDV_PlayerEvents.psc
      PDV_MCM.psc
      PDV__MainQuest.psc
```

Quest scripts (current):
- **2026-06-04 P2 receiver update:** `PDV_PlayerEvents`, `PDV_EventBus`, and
  `PDV__ManagerQuest` now compile with all-ten-race P2 receiver shells/routes
  represented. The live ESP has 34 `PDV_FLST_P2_*` FormLists wired onto the
  `PDV_PlayerEvents` alias, approved book-read fills for the current P2 book
  tranche, and one approved live quest-stage fill: Altmer `MQ104` stage 160 in
  `PDV_FLST_P2_AltmerLorkhanPenalties`. Other quest-stage entries remain
  blocked until separately approved with exact stage metadata. The receiver manifest also owns the static
  `routeContract`/`routeEntries` check for exact-stage branches; the checker
  verifies 24 manifest route entries against `PDV_PlayerEvents.psc`.
- **2026-06-04 reward-contract wave authored:** `PDV__ManagerQuest` now
  compiles with all-ten-race first-tier reward spell properties and
  manager-owned dawn sync/removal logic. Reward records are governed by
  `PDV_Phase20_RewardRecordContracts.json` and
  `tools/pdv-phase20-reward-author`; live `SPEL`/`MGEF` records are authored,
  manager VMAD reward properties are wired, and runtime/manual proof remains
  the next boundary.
- **2026-06-04 P2 proof feedback correction:** P2 book-source proof now uses
  vanilla top-left `Debug.Notification` messages instead of Prisma toast
  fallback, and P2 book-state changes no longer auto-open the Prisma panel.
  Prisma remains the desired future replacement UI, but P2 empirical proof
  should not depend on an overlay that can trap input or hide CK MessageBoxes.
- **2026-06-06 Prisma/P2 integration boundary:** Prisma is a separate UI
  integration track from P2 gameplay proof. P2 proves route/source/reward state
  through readback, logs, notifications, Survey/status, and manual evidence;
  Prisma consumes manager-owned state through typed payloads for toasts, panels,
  medallion presentation, and eventual always-on HUD work. A clean P2 proof does
  not imply Prisma UI proof, and a good Prisma display does not prove gameplay.
- **2026-06-06 Prisma instrument pass:** The Prisma panel now accepts a
  manager-owned `instrument` payload and renders piety, lunar, Hist, ancestor,
  forge, sect, and branch instruments through the tracked `PrismaUI` view.
  `PDV__ManagerQuest` emits substrate toasts for current substrate routes while
  keeping P2 proof independent of Prisma. Repo and live UI/source files matched
  by hash after sync; `PDV__ManagerQuest` compiled with `0 error(s), 0
  warning(s)`, content verify passed at `FAIL=0, WARN=0, PASS=1081, INFO=4`,
  and strict Phase 20 race-costing verify passed at `PASS=2827, WARN=2,
  INFO=29`.
- **2026-06-06 Prisma full-panel gameplay guard:** `PDV__ManagerQuest` now
  defaults `AutoPushPrismaPanel` and `AllowPrismaBlockingSurfaces` to false, so
  shout/devotion state changes can score and mark panel state dirty without
  pushing the full Prisma panel, startup modal, or medallion modal over live
  gameplay. `PDV__ManagerQuest` compiled with `0 error(s), 0 warning(s)`, the
  compile wrapper verifier stayed clean at `FAIL=0, WARN=2, PASS=2827,
  INFO=29`, and `node .\tools\pdv_prisma_ui_audit.mjs` passed eight checks.
- **2026-06-06 Prisma toast label casing fix:** The tracked and live Prisma
  view now resolves stable symbol keys such as `auri-el` through display labels
  before rendering toast deity names, so player-facing toast copy shows
  `Auri-El` while payload keys remain stable. `node --check` passed for repo
  and live `app.js`; `node .\tools\pdv_prisma_ui_audit.mjs` now checks the live
  display-name path and passed ten checks.
- **2026-06-06 race proof restart boundary:** Altmer MQ104 stage 160 and
  Khajiit Words of Clan Mother Ahnissi now have focused in-game source proof
  recorded in `PDV_Phase20_ManualEvidenceLedger.json` and
  `PDV_PreBetaRaceGateLedger.md`. The next testing pass should restart as full
  per-race beta-test packets using `PDV_BetaFeelReleaseGate.md`: expected
  build, edge build, accepted source, wrong-origin/generic rejection,
  Survey/status, reward or state-layer evidence, stack snapshot, known issues,
  and tester stop conditions.
- `PDV__MainQuest.psc` -- RunOnce bootstrap quest. **Phase 4 script complete on disk:** verifies PapyrusUtil and defers origin capture to the player-alias ingress instead of forcing `PDV_Origin.InitializeOrigin()` during `OnInit()`.
- `PDV_Origin.psc` -- **NEW (Phase 4)** One-shot origin helper. Detects and normalizes player origin race, treats vanilla vampire races as their birth race, defers while only a temporary beast-form race is visible, treats the first Nord capture as provisional to avoid placeholder new-game race reads locking too early, writes `PDV_GLO_OriginRace`, and seeds the current proof-slice deity ledgers.
- `PDV__ManagerQuest.psc` -- **Phase 20 status/P2 hook surface wired:** stance-aware piety, patron state, dawn consolidation, contextual favors, commitment, curse-state handling, and neglect remain manager-owned. The manager grants `Survey Devotion` without forcing the player's selected power, exposes thematic player-status APIs, suppresses Nord commitment offers/contextual favors while a Nord vampire rupture is active, preserves a cured-vampire scar note without clearing patron piety, and now owns wrong-origin-guarded Breton/Dunmer/Imperial/Nord immersive hook handlers plus Survey acknowledgements for those P2 route contexts. Survey Devotion and Observe the Moons are authored as Voice-slot Lesser Powers, so Skyrim's normal Power selection swaps between them without left/right-hand prompts.
- `PDV_DeityBase.psc` -- **Phase 4 refactor complete on disk:** race-keyed stance properties, rivalry metadata, and cumulative patron-only boon sync. Replaces the Phase 2 origin-multiplier floats.
- `PDV_Deity_Kyne.psc` -- **Phase 4 proof slice on disk:** same Kyne rubric as before, now expected to use the simple Nord-native / everyone-else-foreign stance row plus CK-authored boon spells.
- `PDV_Deity_Talos.psc` -- **NEW (coupled follow-on slice)** First hostile-path proof deity. Curated Talos-facing defiance signals only; Altmer hostility should rival Auri-El one-way.
- `PDV_Deity_AuriEl.psc` -- **NEW (coupled follow-on slice)** Minimum viable Altmer foundation deity and real rivalry target for Talos. Seeded for Altmer, but still follows patron-only boon rules.
- `PDV_Deity_Yffre.psc` / `PDV_Deity_Zen.psc` / `PDV_Deity_BaanDar.psc` - **NEW (Phase 9 Bosmer path slice)** First Bosmer path foreground deity trio. `LivingStory` and `OldContract` deliberately share one `Y'ffre` ledger; `Z'en` is distinct from `Zenithar`; and path eligibility is gated through `PDV_StateTrack_BosmerPath` rather than separate deity variants.
- `PDV_EventTypes.psc` - **V3/Phase 20 event constant owner:** Central event and attribution constant owner. Compiles cleanly; framework-owned record wiring is live on `Devotion.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact. Phase 20 now includes P2 immersive route IDs for Breton tradition/vow/hidden-art/Green Way, Dunmer Reclamation/deviation, Imperial civic/Talos/patron civic favor, and Nord Old Ways/Kyne-Talos/Hircine-Arkay contexts.
- `PDV_EventBus.psc` - **V3/Phase 20 dispatch service:** Dispatch service for validated event payloads. Direct-player kill scoring remains behavior-compatible with v2; non-direct attribution is carried but non-scoring until later phases. Phase 7 source routes PO3 shout ingress and hidden Talos shrine defiance through manager-owned helpers. Phase 9 source adds Bosmer path-evidence routes plus the shared state-transition confirmation-rite route. Phase 20 adds source-scaffolded P2 immersive hook routes for Breton, Dunmer, Imperial, and Nord that forward into manager handlers without direct reward-state writes. Compiles cleanly; framework-owned record wiring is live on `Devotion.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact.
- `PDV_EventSignalActivator.psc` / `PDV_EventSignalEffect.psc` - **NEW (V3 Slice 1 receiver layer)** Tiny CK-owned receiver scripts for normal-play activator and MGEF/consumable proof records. They validate player/origin/day gates, call existing EventBus routes by `RouteId`, and never write piety, substrate, Green Pact, or Daedric state directly. Source and `.pex` are live; the manual ACTI/MGEF proof records now exist in the framework ESP and are runtime-proven for Dunmer portable/private shrine practice, Bosmer Green Pact violation, and Hircine hunt rite.
- `PDV_SurveyDevotionEffect.psc` - **NEW (Phase 18 status surface)** Lesser-power display effect for `PDV_SPEL_SurveyDevotion`. It calls `PDV__ManagerQuest.GetSurveyDevotionText()` and shows a thematic `MessageBox`; it never writes piety, patron, favor, or curse state.
- `PDV_PlayerEvents.psc` - **NEW (V3 pilot-first ingress slice)** Player `ReferenceAlias` event surface for sleep/load registration and routed non-kill proving signals. Source and `.pex` are live, the `PDV_Player` alias is now attached manually on `PDV__ManagerQuest`, Khajiit sleep ingress is runtime-proven through EventBus/manager/substrate, and Phase 7 source now registers PO3 shout hooks plus `OnShoutAttack(Shout akShout)` routing. Runtime hardening now treats that alias route as preferred but not exclusive: `PDV__ManagerQuest` also registers a quest-form shout fallback and suppresses duplicate callbacks before scoring. Phase 3 generic faucet alias routes for `340/341/365/368` are source/property-wired, and their live FormLists are now filled/readback-clean. Safe authoring still cannot mint new quest aliases, so future alias additions remain manual CK/xEdit work.
- `PDV_MCM.psc` -- **Phase 18 player/status/debug surface:** SkyUI now opens on a small `Player` page with thematic readout rows plus a `Survey Devotion` action. Numeric Status and mutation-heavy Debug pages remain present but are locked behind the StorageUtil-backed `Developer Options` toggle.
- `PDV_ActionRouter.psc` -- **NEW (Phase 3)** Persistent service quest that fans validated player kill actions to all deities via `ScoreAction()`; compiles cleanly, CK quest/property wiring complete, hostile bandit/wolf runtime paths verified.
- `PDV__SM_KillActor.psc` -- **NEW (Phase 3)** Non-Start-Game-Enabled Story Manager receiver quest for `OnStoryKillActor`; compiles cleanly, CK quest/Story Manager wiring complete, receiver path verified by hostile kill events.

- `PDV__SM_CraftItem.psc`, `PDV__SM_NewVoicePower.psc`, `PDV__SM_IncreaseSkill.psc`, `PDV__SM_ChangeLocation.psc`, `PDV__SM_PickLock.psc`, `PDV__SM_Trespass.psc`, `PDV__SM_AssaultActor.psc`, `PDV__SM_AddToPlayer.psc` - **Phase 3 generic faucet receiver source:** thin non-SGE Story Manager receiver scripts for the hybrid day-to-day faucet slice; compile cleanly, QUST shells and `PDV_Router` VMAD wiring are readback-clean, Story Manager nodes are readback-clean, and `tools/pdv-phase20-p2-receiver-author` owns the generic faucet FormList shell/property/content-fill and receiver/Story Manager checks.

(`PDV_MasterQuest.psc` and its `.pex` have been deleted. ESP record removed via xEdit. Done.)

### Local toolchain

Run the local compiler, verifier, and authoring helper from this docs workspace:

```text
node .\tools\pdv_compile.mjs
node .\tools\pdv_compile.mjs --script PDV_ActionRouter
node .\tools\pdv_compile.mjs --all
node .\tools\pdv_compile.mjs --list
node .\tools\pdv_papyrus_lookup.mjs --query PushString
node .\tools\pdv_papyrus_lookup.mjs --script PapyrusUtil --function PushString
```

`pdv_compile.mjs` compiles active PDV scripts whose `.pex` output is missing or older than source. The active set now includes the proven v2 scripts plus the V3 Preflight/EventBus surface, Slice 1 receiver scripts, first alias-side ingress script, Phase 9 Bosmer path deity trio (`PDV_Deity_Yffre`, `PDV_Deity_Zen`, `PDV_Deity_BaanDar`), and the Phase 18 `PDV_SurveyDevotionEffect` player-status surface. `--script` targets one or more scripts, and `--all` rebuilds the active script set. It spawns `PapyrusCompiler.exe` directly with canonical CLI args (`<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`), not `ScriptCompile.bat`, PowerShell, or the CK menu. The import chain now explicitly includes the local `powerofthree's Papyrus Extender\Source\scripts` headers for alias-side shout ingress. Papyrus warnings are treated as failures by default. After a successful compile, the compiler runs `pdv_verify.mjs` unless `--skip-verify` is supplied. In sandboxed agent sessions `pdv_compile.mjs` detects the restriction with a write-access probe and emits a clear error before spawning the compiler; rerun outside the sandbox.

```text
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_verify.mjs --strict-phase3
node .\tools\pdv_verify.mjs --strict-preflight
node .\tools\pdv_verify.mjs --strict-pattern-proving
node .\tools\pdv_verify.mjs --strict-phase7
node .\tools\pdv_verify.mjs --strict-phase8
node .\tools\pdv_verify.mjs --strict-phase9
node .\tools\pdv_verify.mjs --strict-phase10
node .\tools\pdv_verify.mjs --strict-phase11
node .\tools\pdv_verify.mjs --strict-phase12
node .\tools\pdv_verify.mjs --strict-phase20-roster
node .\tools\pdv_verify.mjs --strict-phase20-altmer
node .\tools\pdv_verify.mjs --strict-phase20-race-costing
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_phase20_runtime_check.mjs --list
node .\tools\pdv_phase20_runtime_check.mjs --race all
node .\tools\pdv_verify.mjs --strict-phase18
node .\tools\pdv_verify.mjs --strict-nord
node .\tools\pdv_patch.mjs validate
node .\tools\pdv_patch.mjs plan
node .\tools\pdv_patch.mjs plan --json
node .\tools\pdv_patch.mjs build --dry-run --json
node .\tools\pdv_patch.mjs build --dry-run --allow-candidates --json
node .\tools\pdv_patch.mjs build
```

 The verifier checks the Anvil/Devotion paths, reads `Devotion.esp` through the Anvil MO2 MCP Mutagen bridge, validates the current Phase 4 baseline records/properties plus the Talos/Auri-El and Bosmer follow-on records, checks Phase 3 receiver/router wiring, checks script source/pex freshness, detects CK output shadow files, checks SEQ state, and confirms the active MO2 profile/load order. It now explicitly fails or warns when the live ESP is missing `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, `PDV_Deity_Talos`, `PDV_Deity_AuriEl`, expected stance rows, Talos rivalry wiring, deity boon assignments, or the tracked Pattern Proving ingress source surface (`PDV_PlayerEvents`, `PDV_EventSignalActivator`, `PDV_EventSignalEffect`, routed EventBus helpers, and new event constants). V3 Preflight source/pex readiness is verifier-covered; the framework-owned CK/xEdit records (`PDV_GLO_PatronState`, `PDV_EventTypes`, `PDV_EventBus`) report as INFO in default mode, and `--strict-preflight` promotes those outstanding Preflight gaps to FAIL for gate-close runs. `--strict-pattern-proving` now covers the first pilot-first non-kill ingress source contract, the Slice 1 receiver manifest, optional readback for the manual ACTI/MGEF proof records once they exist, and live `PDV_Player` alias readback on `PDV__ManagerQuest`. `--strict-phase7` adds PO3 shout registration/source checks, quest-form shout fallback source checks, alias readback, plus readback for the actual hidden Talos shrine reference named in `references/authoring/PDV_Phase7SignalReceivers.manifest.json`. `--strict-phase8` adds ConcordatStanding record/property and threshold-array coverage, Talos track-multiplier wiring checks, Phase 7 ingress surface checks reused by the track, manager-side runtime-wiring fallback detection, and the MCM/source contract for committed state, pending state, extreme gate, and Talos effective multiplier readback. `--strict-phase9` adds Bosmer state-track array/property coverage, shared transition source contract checks, Bosmer deity/property coverage, Bosmer manager/message wiring readback, and proof-surface receiver readback for the tracked Phase 9 editor IDs. `--strict-phase10` adds Dunmer ancestor substrate graduation checks for source contract, substrate record/scripts/properties, manager property, and the two reused Dunmer proof ACTI records. `--strict-phase11` verifies the Arngeir/Kynareth privilege pilot manifest; live dialogue readback only runs when the manifest is explicitly marked `live-dialogue-authored`. `--strict-phase12` adds contextual-favor lane/family presence checks, manager wiring/readback assertions for favor records and state keys, and explicit readback for `PDV_State_NordPantheonBaseline` as a `QUST` with `PDV_StateTrack` attached. `--strict-phase20-roster` checks `references/authoring/PDV_DeityCoverageMatrix.json` against the Phase 4 stance and Daedric matrices, fails missing race coverage, and fails dev-only language for locked gods or Skyrim-present Princes. `--strict-phase20-altmer` validates the Altmer implementation-costing manifest, decision sources, crisis enum, drafted content rows, rejected-hook families, immersion proof, planned verifier contract, runtime proof case coverage, and the manager/EventBus/EventTypes/receiver hooks when the manifest status is `source-scaffolded` or later; when the manifest is `record-wired` or later, it also reads back `PDV_State_AltmerCrisis` and `PDV_AltmerCrisisTrack`; when Altmer favor families are marked `record-wired`, it verifies their `KYWD` / `MGEF` / `SPEL` records, spell-effect membership, effect keyword, and manager spell-property wiring; when Altmer trigger surfaces are marked `record-wired`, it verifies their ACTI records, `PDV_EventSignalActivator` attachment, route IDs, origin gates, source IDs, and daily keys. `--strict-phase20-race-costing` validates all Phase 20 race implementation-costing manifests for schema, sources, state surfaces, enum contracts, required content rows, rejected hooks, immersion proof, verifier gates, first slices, and runtime proof cases. `--strict-phase21-roster` remains accepted as a temporary alias. `--strict-phase18` / `--strict-nord` verifies Survey Devotion spell/effect records, manager/MCM source contracts, Nord curse-message records, manager/effect VMAD wiring, and the four CK-authored Nord dialogue contracts in `references/authoring/PDV_Phase18StatusNord.manifest.json`; live dialogue readback now runs because that manifest is marked `live-dialogue-authored`. The verifier also reads back the tracked `PDV_PreflightRouterServicesOverlay.esp` canary when present. It is diagnostic only and must not write to the ESP or MO2 profile files.

The authoring companion to that loop is now **houseCARL**, called directly via the `housecarl_*` MCP tools. Its default lane writes into a new patch plugin, leaving `Devotion.esp` untouched; the in-place lane is explicit and consented. Verification is a `housecarl_read_record` / `housecarl_cross_plugin_query` readback in the same session -- that readback is the proof. See the houseCARL Direct Plugin Work Rule at the top of this file. The retired `pdv_author.mjs` overlay helper and its supported/unsupported write matrix no longer apply and must not be reintroduced.

 `tools/sync-devotion-to-live.ps1` is a guarded copy helper for repo-tracked Prisma and StorageUtil assets, not a bootstrap or repair tool. It requires an existing healthy `D:\Wabbajack\modlists\Anvil\mods\Devotion` folder with `Devotion.esp`, refuses empty or damaged roots, creates `generated\live-devotion-backups\pre-sync-*` before non-dry-run writes, and asserts that `Devotion.esp` still exists after sync. It must not copy untracked scratch Papyrus into live by default. If the live mod folder is missing or empty, restore from a snapshot or backup first; do not run sync as the first creator of the mod folder.

`tools/pdv_phase20_base_wiring_audit.mjs` is a read-only all-race scaffold
audit for the Phase 20 base mod layer. It checks the P2 receiver manifest,
reward contract, and live `PDV_PlayerEvents`, `PDV_EventBus`, and
`PDV__ManagerQuest` sources for all ten race receiver contracts, route function
presence, approved source-fill counts, and T1 reward manager references.

`tools/pdv_phase20_runtime_check.mjs` is a read-only Papyrus log checker for
the Phase 20 QASmoke runtime proof pass. It validates route markers for the
Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer proof references, can
optionally require manager traces with `--strict-manager`, and defaults to the
live Skyrim SE `Papyrus.0.log` path. It proves route delivery only; Survey
Devotion/MCM status, immersion feel, negative hooks, anti-farm behavior, and
final world placement remain separate closeout evidence.

`pdv_patch.mjs` is the Phase 19 offline classification/distribution patcher. It reads tracked rule manifests from `references/authoring/patch-rules/`, validates their schema strictly, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning target records plus payload references, and emits deterministic `validate`, `plan`, and `build` output. `build` writes only a generated `PDV_ClassificationPatch.esp` in the Devotion mod folder through the existing Mutagen bridge patch-request contract. It must not overwrite `Devotion.esp` or mutate source masters/plugins. Default `build` output emits only `approved` rules; `candidate` rules require `--allow-candidates`, and `tooling-example` rules require `--allow-tooling-examples`. `PDV_Phase19TempleLocationRules.json` is the first approved live packet; the retired proof rules are plan-only.

Toolchain usage rules:
- After editing any PDV `.psc`, run `node .\tools\pdv_compile.mjs` or `node .\tools\pdv_compile.mjs --script <ScriptName>`.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- After touching Prisma bridge/panel/overlay calls, Book-of-Days payload/open-close code, or any `PDV_PrismaBridge.*` Papyrus surface, run `node .\tools\pdv_prisma_ui_audit.mjs`; gameplay code should emit toasts or stay silent unless a player-owned UI entry point explicitly opens a blocking surface. This audit now fails if `PDV_MCM.pex` is older than the live Book-of-Days manager payload contract it calls, so a manager-only compile cannot silently strand the in-game hotkey on old bytecode.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3` or compile with `node .\tools\pdv_compile.mjs --strict-phase3`.
- Before declaring V3 Preflight complete, run `node .\tools\pdv_verify.mjs --strict-preflight` (or compile with `node .\tools\pdv_compile.mjs --strict-preflight`) and resolve all FAILs.
- Before declaring a Pattern Proving checkpoint complete, run `node .\tools\pdv_verify.mjs --strict-pattern-proving` (or compile with `node .\tools\pdv_compile.mjs --strict-pattern-proving`) and treat duplicate-VMAD results as explicit waivers until the framework record attachments are manually consolidated.
- Before declaring Phase 7 signal expansion complete, run `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 8 reputation-track closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 9 Bosmer-path closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 10 Dunmer-substrate graduation complete, run `node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and confirm the runtime proof notes still show substrate progress separate from patron piety.
- Before declaring the Khajiit/commitment/neglect packet complete, run `node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and resolve all FAIL/WARN results except explicitly waived SEQ freshness during active CK dialogue work.
- For Phase 11, run `node .\tools\pdv_verify.mjs --strict-phase11` to confirm the D-10 Arngeir/Kynareth manifest and CK-authored dialogue readback. Phase 11 runtime proof is complete as of 2026-05-26.
- For Phase 12, author any record changes with the `housecarl_*` MCP tools, then run `node .\tools\pdv_verify.mjs --strict-phase12`. A fresh ESP write should leave `SEQ freshness` as the expected remaining warning until `Devotion.seq` is refreshed.
- For Phase 13, author any record changes with the `housecarl_*` MCP tools, refresh SEQ, and run `node .\tools\pdv_verify.mjs --strict-phase13` before runtime proof.
- For Phase 14-16 closeout, run `node .\tools\pdv_verify.mjs --strict-phase14 --strict-phase15 --strict-phase16` after any source or CK changes. Runtime proof is complete as of 2026-05-28; remaining work is content expansion, not seam validation.
- For Phase 17 decay/balancing regression, compile `PDV_DeityBase` and `PDV__ManagerQuest`, refresh SEQ after any ESP write, then run `node .\tools\pdv_verify.mjs --strict-phase17`. The current full bridge ladder is `node .\tools\pdv_verify.mjs --strict-phase16 --strict-phase17 --strict-phase18 --strict-nord --strict-phase13 --strict-phase14 --strict-phase15`.
- For Phase 18/Nord status closeout, author any record changes with the `housecarl_*` MCP tools, compile `PDV_MCM`, `PDV__ManagerQuest`, and `PDV_SurveyDevotionEffect`, and run `node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord --strict-phase17 --strict-phase13 --strict-phase14 --strict-phase15 --strict-phase16`. Future dialogue edits remain manual CK work; refresh SEQ after CK saves and resolve freshness before closeout.
- For Phase 20 roster planning or content lock work, run `node .\tools\pdv_verify.mjs --strict-phase20-roster` and `node .\tools\pdv_content_verify.mjs --strict-phase20-roster`; missing race/deity handling or dev-only locked roster entries block the 1.0 gate. For race implementation-costing work, run `node .\tools\pdv_verify.mjs --strict-phase20-race-costing`; for the Altmer-specific crisis/Lorkhan/favor lane also run `node .\tools\pdv_verify.mjs --strict-phase20-altmer`. After any `housecarl_*` record write, read the value back with a houseCARL read tool, compile any touched source scripts, refresh SEQ after ESP writes, run the relevant placement checks, and rerun the strict Phase 20 Altmer/race-costing verifier. After in-game QASmoke proof activation, run `node .\tools\pdv_phase20_runtime_check.mjs --race all` and then record Survey/status, immersion, negative-hook, and anti-farm evidence from `references\authoring\PDV_Phase20_QASmokeRuntimeProof_Runbook.md`; the log checker alone is not runtime closeout.

---

## Papyrus Guidance

Before writing or reviewing Papyrus, read `references/PAPYRUS_KNOWLEDGE_INTAKE.md` when the task touches API usage, compiler/import setup, or reference-generation/tooling decisions.

Primary external Papyrus reference path for this project:

- `https://github.com/BellCubeDev/papyrus-index`
- `https://papyrus.bellcube.dev/`

Use BellCube to verify Papyrus signatures, inheritance, and plugin-provided function surfaces when shipped `.psc` source, CK Wiki pages, or local mod sources do not fully settle the question. Treat it as a high-value curated reference, not as permission to skip compile verification or local source inspection.

Preferred local helper for that lookup:

- `node .\tools\pdv_papyrus_lookup.mjs --query <FunctionOrScript>`
- `node .\tools\pdv_papyrus_lookup.mjs --script <ScriptName> --function <FunctionName>`

Working rules drawn from that intake:

- **Do not invent Papyrus APIs.** If a function signature is not verified from shipped `.psc` source, CK Wiki, SKSE source, or an explicitly cited plugin source, treat it as unknown.
- **Identify the API layer being used.** Distinguish vanilla Papyrus, SKSE extensions, and plugin-provided APIs such as PapyrusUtil, JContainers, RaceMenu, or MCM Helper.
- **Assume symbol gaps until proven otherwise.** Missing imports or missing source roots are a more likely cause than "Papyrus is weird"; verify the compiler import chain before changing logic.
- **Compile-verified beats plausible.** Prefer fixes confirmed by actual compile output over stylistically plausible Papyrus guesses.
- **Be honest about coverage limits.** `.pex`-only mods are out of scope unless source exists; BellCube/papyrus-index is curated and useful, but not exhaustive.
- **Use Skyrim-valid test paths.** For in-game testing, rely on commands documented in `PDV_SkyrimConsoleReference.md` and CK-backed harnesses such as quest stages or properties, not Fallout-only shortcuts.
- **Respect Papyrus parser limits.** Use only valid string escapes (`\\`, `\"`), keep `{...}` docstrings directly after declarations, and do not assume helpers such as `StringUtil.Replace` exist.
- **Respect Papyrus language limits.** No ternary operator, no string interpolation, no string `+=`, no `Math.max`/`Math.min`, no variable-sized arrays, arrays cap at 128, and chained casts should be split into explicit intermediate variables.
- **Prefer engine data over script work.** Use CK conditions, aliases, linked refs, quest stages, scenes, packages, perks, spells, MGEF conditions, and default scripts before adding custom Papyrus.
- **Prefer events and single-update chains over polling.** Repeated timers should use `RegisterForSingleUpdate` / `RegisterForSingleUpdateGameTime`, have explicit exit conditions, and unregister when finished.
- **Design for Papyrus re-entry and save state.** External calls can allow queued events to resume; use states, busy flags, version tokens, or queues where overlap matters. Treat saves as Papyrus databases and handle script/property changes as migrations.
- **Avoid accidental persistence.** Do not keep ObjectReference/Actor properties or script variables filled unless justified; prefer aliases/event args/linked refs, clear temporary refs to `None`, and unregister events on shutdown/effect finish/quest stop.
- **Treat runtime errors as bugs.** Guard all optional forms, references, casts, and unloaded-cell operations. Do not normalize recurring `None`, stale property, type mismatch, or unloaded-cell log spam.
- **Avoid save-baked false positives.** When script behavior looks impossible after an edit, retest from a new game or main-menu `coc qasmoke` path before changing architecture.
- **Profile before guessing.** Use Papyrus logging/profiling for controlled diagnostics, and do not ship code or advice that depends on huge Papyrus INI budget/memory tweaks.
- **Keep player-facing text ASCII.** Dialogue, notifications, MCM strings, books, and message boxes should use straight quotes, `...`, `--`, and `-` rather than curly quotes, em dashes, ellipses, or bullets.
- **Keep persistence backends isolated.** Before adding a reader, grep for writers and match their backend. StorageUtil remains PDV's default; do not mix StorageUtil, JFormDB, JDB/JArray, and live actor state under the same key.
- **`Actor.GetFurnitureReference()` is None at `OnSleepStart`.** The engine has not seated the actor in the bed when the event fires, so the bed object cannot be captured there (verified 2026-06-11, the Argonian bed-of-choice bug). For sleep-location identity use the parent CELL read at `OnSleepStop` (`GetParentCell()`, always valid), not the furniture ref.
- **A version-gated StorageUtil table must CLEAR removed keys, not just rewrite.** Codegen'd reload tables (e.g. `LoadLikesDislikesTable` -> per-deity `PDV.LD.*`) that only write rows leave orphan keys when a row is REMOVED; the stale key keeps scoring on any save that loaded the old version, and a version bump alone does not fix it. Clear a known event/key superset before rewriting (verified 2026-06-11, the sithis kill-hostile orphan). Same family as VMAD-bake and quest-matrix key drift.
- **MessageBox buttons render in ONE horizontal row.** Long button labels run off-screen (verified 2026-06-11, the adaptation rite menu). Keep MESG buttons to one or two short words and put effect numbers/details in the message BODY (`\n` line breaks render in the body); never encode data into button labels.
- **`cqf` was not accepted as a console command in this setup.** For console-driven debug dispatchers, prefer the SetPQV poll-harness pattern: hidden Auto properties for the inputs plus a `...Go` flag the 1s `OnUpdate` tick consumes and resets (see `DebugSeedArgonian` + `DebugSeedGo` in `PDV__ManagerQuest`). Set the value properties first, flip the Go flag last, close the console, and wait a tick.
- **A raw `Message.Show()` cannot display while the MCM/config menu is open.** It returns the default button (0 = first) instantly with no dialog, so any Accept/Decline gate auto-accepts silently (verified 2026-06-13, the Daedric Champion offer forced from the MCM; the MESG record + VMAD wiring were correct -- this is pure UI timing, not a wiring/save-bake bug). To show an authored blocking message that an MCM action triggers, DEFER it: queue it and process from the manager `OnUpdate` loop gated on `Utility.IsInMenuMode() == false` so it fires after the menu closes. The same message displays fine from a non-menu (organic) script context.

---

## Architecture Summary

### ESP Structure

```
Devotion.esp    <- master: quest spine, deity registry, globals
PDV_Nord.esp                    <- race module (depends on framework)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

### v2 Architecture (current target -- see `PDV_Architecture_v2.md` for full spec)

Per-deity piety lives in **StorageUtil** (PapyrusUtil SE), keyed by deity FormID. A set of **mirror GlobalVariables** shadows the active patron's current values so vanilla CK Conditions can read them without scripting glue. The manager quest is a dispatcher and helper API, not a calculator.

**StorageUtil keys per deity:**

| Key | Range | Purpose |
|-----|-------|---------|
| `PDV.Piety` | 0-200 | Current piety. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Reset at dawn. |
| `PDV.Tier` | 0-3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Decay grace period + MCM display |

**Mirror GlobalVariables (active patron only):**

| Global | Purpose |
|--------|---------|
| `PDV_GLO_ActivePiety` | Active patron's current piety |
| `PDV_GLO_ActiveTier` | Active patron's current tier (0-3) |
| `PDV_GLO_ActiveDeityIndex` | Stable int identifying the active deity. -1 = none |

Mirrors are refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()` on patron switch and after any persistent piety/tier mutation to the active patron. They mirror `PDV.Piety`, not `PDV.PietyToday`, and are never the source of truth -- StorageUtil is.

### v3 Architecture (forward plan)

`PDV_Architecture_v3.md` is the forward source for post-v2 work. It separates
structural completeness from content completeness, adds the v3 preflight and
structural skeleton gates, and defines Technical Beta, Content-Feel Beta, and
content-rich 1.0 launch readiness. `PDV_TargetEndStates_1.0.md` is the living
1.0 product target and race-by-race end-state tracker; it defers subsystem
architecture and phase gates to v3.

### v2 Tier thresholds (current defaults, tunable per-deity in Phase 2+)

| Tier | Label | Piety threshold |
|------|-------|----------------|
| 0 | None | < 10 |
| 1 | Seeker | >= 10 |
| 2 | Devoted | >= 50 |
| 3 | Champion | >= 150 |

**The bucket system has been removed.** `CombatBucket`, `SocialBucket`, `LifestyleBucket`, and `PDV_GLO_DevotionLevel` are gone. Do not reference them.

### Phase 3 Preflight

Phase 3 has been interrogated before implementation. The stable route is:

- `PDV_ActionRouter` is a Start-Game-Enabled persistent service quest.
- `PDV__SM_KillActor` is a separate non-Start-Game-Enabled Story Manager receiver quest.
- Story Manager starts `PDV__SM_KillActor` from the Kill Actor event; its script handles `OnStoryKillActor(...)`, calls `PDV_ActionRouter.HandleStoryKillActor(...)`, then stops/resets.
- `PDV_ActionRouter` validates player-only kill events for the first slice, classifies hostile animal/NPC kills, iterates `PDV_FLST_AllDeities`, calls each deity's `ScoreAction()`, and writes through `PDV__ManagerQuest.AwardPiety()`.
- Phase 3 must not write `PDV.Piety`, `PDV.Tier`, or mirror globals directly. Runtime events write only `PDV.PietyToday`; dawn remains the only consolidation path.
- Story Manager nodes added by PDV must have `Shares Event` checked for mod compatibility.
- Do not use CK stage fragments for this slice unless the quest-event path fails and fragments are revalidated in CKPE.

---

## Naming Conventions

All records use prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals add a second underscore (`PDV_GLO__X`). Mirrored from Gods And Worship -- full reference in `PDV_MOD_SETUP.md` Section EditorID Prefix Convention.

```
PDV__MainQuest                  <- internal: RunOnce bootstrap
PDV__ManagerQuest               <- internal: runtime (registry + helper API)
PDV_GLO_ActivePiety             <- Global, mirror: active patron's piety (float)
PDV_GLO_ActiveTier              <- Global, mirror: active patron's tier 0-3 (float)
PDV_GLO_ActiveDeityIndex        <- Global, mirror: active deity stable int, -1=none (float)
PDV_GLO_OriginRace              <- Global, set once: race index 0-9 (Phase 4)
PDV_GLO_PatronDeity             <- Global, FormID of active patron, 0=none (Phase 2+)
PDV_GLO_DebugLevel              <- Global, 0-3 trace verbosity (MCM-toggleable)
PDV_Race[Name]Quest             <- per-race tracking (in race ESP)
PDV_ActionRouter                <- Story Manager event fan-out (Phase 3)
PDV__SM_KillActor               <- internal Story Manager receiver quest for Kill Actor (Phase 3)
PDV_DeityBase                   <- base class all PDV_Deity_<X> scripts extend (Phase 2)
PDV_Deity_[Name]                <- concrete deity quest (Phase 2+)
PDV_FLST_AllDeities             <- FormList, iteration source for ProcessDawn and MCM
PDV_GLO_PatronState             - Global, V3 Preflight patron state: 0=unset, 1=broad worship, 2=active patron
PDV_EventTypes                  - V3 Preflight central event/attribution constant owner
PDV_EventBus                    - V3 Preflight dispatch service between receivers and deity scoring
PDV_Blessing_[Race]_Low/Mid/High
PDV_Neglect_[Race]
PDV_SMF_[EventName]             <- Story Manager flag globals
PDV_DebugSpell
```

`PDV_GLO_DevotionLevel`, `CombatBucket`, `SocialBucket`, and `LifestyleBucket` have been removed.

---

## Race Design Philosophy

Each race module is designed around the **primary religious tension** that culture faces in 4E 201. These tensions should drive what deity rubrics reward and punish -- not generic "worship a shrine" logic.

| Race | Core Tension | What Deity Rubrics Should Reflect |
|------|-------------|----------------------------------|
| Nord | Talos ban vs. identity | Openly defiant worship vs. pragmatic silence |
| Imperial | Concordat enforcement vs. private faith | Civic observance vs. personal conscience |
| Dunmer | Tribunal gone, far from ancestral tombs | Ash-prayer maintenance, ancestor memory |
| Altmer | Thalmor enforcement as religious vocation | Theological purity, bloodline, magical study |
| Khajiit | Excluded from cities, no temple access | Moon-watching, caravan community cohesion |
| Bosmer | Green Pact observance without Valenwood enforcement | Dietary compliance, hunting ritual |
| Redguard | Post-victory confidence, Crown/Forebear split | Martial-devotional practice, sword rites |
| Orc | Labor as worship, Malacath's active judgment | Craft excellence, honor, code adherence |
| Argonian | Hist absence, identity under discrimination | Community cohesion, Sithis acknowledgment |

Detailed current race architecture decisions, curse interpretations, and quest/faction weighting now live in `references/PDV_RaceArchitecture_DesignReference.md`. Use that file as the current race-design source of truth when it is more specific than the summary table above.

---

## Key Lore Constraints

Pull from `references/skyrim-deity-reference.jsx`, `references/tamriel-daily-worship-4e201.html`, `references/tamriel-cursed-worship-4e201.html`, and `references/tamriel-daedric-worship-4e201.html` before writing race content. Key things to remember:

- **Khajiit** worship the lunar lattice (Riddle'Thar), not generic Nine Divines. Moon phase determines identity.
- **Dunmer** religious life centres on named ancestors, not named gods. The household ash-shrine outranks any temple.
- **Orcs** treat craft as prayer. Malacath is not petitioned -- he judges by observing strength and labor.
- **Argonians** lose their core religious infrastructure (the Hist) when outside Black Marsh. Design their triggers around adaptation and absence, not normal worship.
- **Bosmer** Green Pact dietary observance (no plant matter) creates daily friction in Skyrim that is itself a mechanic opportunity.
- **Redguard** theology is a survival narrative. Their recent military victory over the Dominion is a live theological fact in 4E 201.
- **Daedric Prince** names are largely consistent across all cultures -- use `references/skyrim-deity-reference.jsx` for the few exceptions (e.g. Azurah, Boethra, Sheggorath for Khajiit).

---

## Current Build Status

*Update this section as the project progresses.*

```
[x] Environment setup verified
[~] V3 manager decomposition / ORIGIN module (2026-08-20, `feature/v3-origin-extraction`) - `PDV_OriginRuntimeBase` plus ten race adapters are live in `Devotion-V3Dev`; the manager's runtime-filled `OriginRuntime` switchboard is backed by the ten-entry `PDV_FLST_OriginAdapters`, and every adapter has the manager backref. Phase C removed the safe duplicate/switchboard families while explicitly deferring the cross-lane notification, state/detail, and stringly contextual-signal clusters. Ordinary deity reachability is now enforced as an all-race invariant: every race has an exact reviewed native roster, all six formal-offer races have exact reviewed offer sets, and every ordinary gameplay or MCM mutation must stay inside the current race-authorized set. Altmer-to-Baan-Dar remains one negative regression fixture, not the scope of the rule. The normal setter has no bypass argument; the sole invalid-state consent fixture is labelled UNSAFE, persistently invalidates the run as proof, self-cleans, and restores the prior patron mode. Machine proof: changed scripts compile 0/0 in `Devotion-V3Dev`; formal/reachability gate `PASS=412/WARN=0/FAIL=0`; VMAD audit 207/207 attachments, 0 unwaived findings; direct houseCARL confirms the FormList and ten manager backrefs. OPEN MANUAL PROOF: representative all-race out-of-roster surface smoke, race-change prior-race stripping/no-double-dip, MCM `OnConfigOpen`, recognition-off silence, and formal-offer player copy. The historical `e739f79f` cast audit is superseded by the current source-derived module contract and is retained only as a historical baseline.
[~] V3 manager decomposition / RECOGNITION module (2026-08-20, `feature/v3-recognition-extraction`) - all 31 NPC-recognition functions and the three-field form cache now live in `PDV_RecognitionRuntime`; manager lifecycle/panel calls, both ledger sync calls, and all five MCM controls route through the typed module. Direct houseCARL readback proves the StartGameEnabled host QUST `07179F`, module `Manager` backref -> `00C325`, manager `RecognitionRuntime` -> `07179F`, and the regenerated 56-entry SEQ. Four changed scripts compile 0/0; the extraction-aware SPID/KID audit passes 58 rules; VMAD passes 205/205 attachments with 0 unwaived findings; repo/live PSC hashes match and every PEX is fresh. `PDV_Msg_Altmer_VampireExiledPath_Recognition` was corrected to ORIGIN ownership because it is an Altmer Exiled-path acknowledgement, not an SPID NPC-recognition surface. OPEN MANUAL PROOF: claim/release/state event routing, MCM toggles, faction reactions, recognition-off silence, focused-panel JSON, and save/load persistence. The former 37 decomposition-era verifier failures are retired by the post-module integration checkpoint; the recognition-specific audit and VMAD gate remain clean.
[~] V3 manager decomposition / PRISMA module (2026-08-20, `feature/v3-prisma-extraction`) - all 114 mapped presentation functions now live in `PDV_PrismaPresenter`; actual external call-graph truth is 48 public functions / 66 private. The eight load-bearing per-race content switches now dispatch through seven named ORIGIN presentation virtuals plus the existing Survey/detail interface, implemented by all ten adapters; the presenter retains only envelope precedence. Direct houseCARL readback proves StartGameEnabled host QUST `0717A0`, `Manager -> 00C325`, Survey spell `070524`, diegetic director `07149A`, manager `Prisma -> 0717A0`, and the regenerated 57-entry SEQ. All 20 changed scripts compile 0/0; extraction audit `PASS=37/FAIL=0`; VMAD passes 206/206 attachments with 0 unwaived findings. OPEN MANUAL PROOF: panel/toast/Book/Survey byte-for-byte player surfaces, close behavior, fresh-game startup, and save/load. The legacy broad Prisma gates still default to the 1.5 `Devotion` tree and contain manager-residence assertions; refresh them during the post-module integration sweep before using them as V3 evidence.
[~] V3 manager decomposition / DEBUG module (2026-08-20, `feature/v3-debug-extraction`) - all 136 `Debug*` bodies now live in `PDV_DebugRuntime`; the manager retains only `RunDebugCommand` and its four scratch registers, and MCM reaches manager-owned harness functions through the typed `manager.DebugRuntime.Debug*` double-hop. Call-graph truth is 111 public functions / 25 module-internal helpers. Direct houseCARL readback proves StartGameEnabled priority-50 host QUST `0717A1`, its seven stable module/back references, manager property 515 `DebugRuntime -> 0717A1`, and the regenerated 58-entry SEQ. The eighth reference, `OriginRuntime`, is deliberately runtime-filled from the manager's selected adapter so debug cannot disagree with captured origin; the precise absence is evidence-waived and the VMAD audit passes 207/207 attachments with 0 unwaived findings. All five affected scripts compile 0/0; extraction audit `PASS=27/FAIL=0`; repo/live PSC hashes match and PEX files are fresh. No `Debug*` function is Global or user-console reachable. OPEN MANUAL PROOF: fresh-game MCM harness sweep, save/load rebinding, and representative per-module driver checks. The first human pass uses the existing MCM surface; a tester-only `PDV_DebugConsole` remains deferred unless that run proves a concrete missing driver, and it must not enter the user payload.
[x] V3 post-module integration reconciliation (2026-08-20, `feature/v3-post-module-integration`) - retired the 37 decomposition-era verifier failures after ORIGIN, RECOGNITION, PRISMA, and DEBUG landed. ActionRouter location ingress now makes one typed `OriginRuntime.HandleLocationChange` call; EventBus, moon observation, and Baan Dar rescue use the generic ORIGIN contextual-query seam. Extraction-aware source gates read the complete module family and join all polymorphic override bodies instead of assuming manager residence or taking the first override. Pantheon readback uses the complete manager VMAD property range rather than a stale tail slice; supervised consolidation removed stale fills and duplicate property names. The retirement manifest now has zero unresolved rows and its gate rejects any retired symbol still declared in live source. All ten adapters are also checked against exact reviewed neglect helper and spell-reference families, so cross-race/path neglect leakage fails the module gate; Kyne is only a concrete regression fixture. Result: full verifier `FAIL=0/WARN=0/TODO=0/PASS=4104/INFO=100`, formal/reachability 412/412, VMAD 207/207 attachments, signal E2E 41/41 surfaces with 486/486 non-reserved targets reachable, substrate pacing PASS, broad pantheon PASS, and pantheon record/presentation readback 89/89 and 82/82. Runtime/player-surface, fresh-game/save-load, and release/package proof remain open and separate.
[~] V3 unified runtime acceptance (2026-08-20, `feature/v3-big-update`) - the former module-specific smoke cards are now subordinate to `PDV_2_0_RuntimeAcceptance_Runbook.md`, a 3-gate machine manifest, committed evidence store, and `pdv_v3_runtime_acceptance.mjs`. Gate 1 covers the existing MCM driver across fresh Nord/Khajiit/Imperial/Altmer sessions, race-change cleanup, presentation cardinality, recognition, compatibility adapters, save/load, logs, and deterministic performance. Gate 2 is reserved for the owner-ratified four-page/full-ST MCM revamp; the final gate reruns the critical combined path. The gate is intentionally PENDING: its ledger has no tested commit or runtime/manual evidence, requires fresh Papyrus logs, and invalidates evidence after runtime-sensitive files change. No MCM revamp implementation or merge-readiness claim is authorized until Gate 1 passes.
[~] Wire-or-retire rulings + full dead-code adjudication (2026-08-07, branch `codex/khajiit-lunar-champion-rebalance`) - closed the five "documented as working, no live call path" items from the hygiene handoff. WIRED: `PDV_Msg_Nord_CurseState_WerewolfCured` (cure branch only reset flags), `PDV_Msg_Nord_Kyne_ChampionEntry` (additive on the tier surface, so the toast/Book/Ledger keep theirs), `AwardDunmerAncestorSpinePulse` (ancestral-layer Ledger driver, patron-INDEPENDENT, anti-farm cap on the pulse). RETIRED: `GetAltmerPracticeLine` (dead second draw site), `RefreshOpenBookOfDays` (superseded duplicate of the MCM journal-hotkey reconciliation; its three gates now assert the behaviour against `PDV_MCM.psc` instead of pinning a function name). All 133 uncalled functions adjudicated BY NAME in `references/authoring/PDV_DeadCode_RetiredScaffolding_Verdicts_2026-08-07.md` (37 LIKELY-REMOVABLE, 16 SUPERSEDED, 14 LEDGER-PROTECTED); all 18 read-never-written StorageUtil keys and all 5 unreferenced tools resolved. Gates green by exit code. In-game proof: werewolf cure PASS; Kyne recognition retest pending.
[x] 1.0.4 SHIPPED PUBLIC (2026-07-27) - `Devotion-1.0.4-20260727.zip`, tag `v1.0.4`, GitHub release `Devotion 1.0.4`; `sha256 2DF7CADAF2AEAC8CFFAB7ED51258F2A58A653C6FC24FC143105476F4B3D7F087`. First public build since 1.0.2; folds in the never-released 1.0.3 plus the DrHeisen audit ports. No new game required. Player-facing scope is `CHANGELOG.md` 1.0.4 (authority) - save-damage class (Recover-flag sweep + `Check stat damage` / `Repair stats` MCM maintenance, heartbeat watchdog, uninstall cleanup), shrine class (Devotion now ships its own `TempleBlessingScript.pex`), god-reaction class (Daedric price/pool serialization, Hermaeus Mora Champion, 22 self-cancelling penalty effects, Azura likes/dislikes + stance table, Thalmor self-defence, Bosmer Old Contract menu-refusal guard), Bosmer Green Pact food (22 vanilla/DLC meats + Requiem keyword lane), and the runtime-cost pass. RELEASE READBACK (2026-07-27, houseCARL, Anvil `Devotion Dev`, against the exact shipped ESP - zip and live `Devotion.esp` are byte-identical, `sha256 0680B51F...`): every value-modifying MGEF defined in `Devotion.esp` now carries `Recover` - ValueModifier `395/395`, PeakValueModifier `232/232`, `627/627` total, zero remaining. That closes the save-corrupting stat-drift class at the record layer. PROOF BOUNDARY: this is release readback, not manual proof - the on/off revert was manually observed only on the representative Azura/Mephala/Hermaeus Mora tiers (2026-07-26); the rest of the 627 are readback-proven. Two-tester smoke passed all checks (commit 701185ce). OPEN: the shipped build's runtime-optimization source is NOT on `main` - see the drift entry below.
[x] SHIPPED-VS-REPO SOURCE DRIFT (2026-07-27, RESOLVED by merging `codex/pdv-ship-optimization`; recorded here because the diagnosis is the reusable part) - the 1.0.4 zip shipped the runtime-cost pass, but its Papyrus source lived only on the unmerged branch `codex/pdv-ship-optimization` (`47ae2b0b`, "feat(1.0.4): optimize runtime and harden release gates"), which is NOT an ancestor of `v1.0.4`. Evidence: live `D:\...\Devotion\Scripts\Source\PDV__ManagerQuest.psc` and `PDV_PlayerEvents.psc` are byte-identical to that branch's `live-source/` mirror and diverge from `main`'s mirror by 320 / 213 content lines; the shipped `.pex` for both matches the live `.pex` exactly (923022 / 94350 bytes, compiled 2026-07-26 19:00 / 18:19). All other 95 tracked `live-source` scripts match `main` on content (the 5 that `diff` flags are CRLF-only - see `prisma-view-deploy-lf-required`). CONSEQUENCE (git-only, and narrower than it first looked): `main` could not rebuild the shipped build, and `main`'s `CHANGELOG.md` described optimizations whose source it did not contain. The source itself was never lost or at risk - the release package ships all 97 `.psc` files under `Scripts\Source\`, and those shipped sources are byte-identical to the optimized versions, so the correct source was publicly available on the Nexus download and present in the live MO2 folder the whole time. Verified 2026-07-27 by extracting the zip's `PDV__ManagerQuest.psc` / `PDV_PlayerEvents.psc` and diffing: 0 lines against post-merge `main`, 320 / 213 against pre-merge `main`. Also unmerged with that branch: `tools/pdv_ship_optimization_audit.mjs`, `tools/pdv_player_events_optimization_audit.mjs`, the hardened `tools/pdv_package_release.mjs`, `PDV_ReleasePayload.manifest.json`, and `PDV_HousecarlReleaseProof.json`. RESOLUTION: merged on `docs/1.0.4-doc-sync` (2026-07-27). One conflicted file (`AGENTS.md`), an append-ordering collision in the Decisions Log where both sides added entries at the top; resolved by keeping both in date order. Everything else auto-merged. DURABLE LESSON: the zip is packaged from the live MO2 folder, not from git, so a build can ship work that never reached the trunk and no gate will notice. After any release, diff the live `Scripts\Source` against the tracked `live-source/` mirror before assuming `main` can rebuild what shipped. Note that CRLF-vs-LF makes `diff` report whole-file changes on untouched scripts - compare with `--strip-trailing-cr` or you will chase five phantom drifts (see `prisma-view-deploy-lf-required`).
[x] Daedric price-family serialization repair (2026-07-26) - Azura Seeker runtime diagnosis proved the engine-correct constant-effect penalty convention: semantic contract magnitude remains negative, while the live MGEF uses `Detrimental + PowerAffectsMagnitude` and the carrier SPEL stores the positive absolute magnitude. The convention was applied atomically to all 48 price MGEFs and 48 carrier spells through direct houseCARL in-place authoring after backing up `Devotion.esp`; independent houseCARL readback found 48/48 corrected pairs. `PDV_DaedricPrinceRecordContracts.json` and its generator now state the serialization rule, and `pdv_verify.mjs` fails on flag/link/magnitude/archetype drift; final gate `FAIL=0 WARN=0 TODO=1 PASS=4120 INFO=72`. Post-repair runtime passed all three Azura Stamina tiers (-10/-20/-30) and all three Mephala Speech tiers (-8/-12/-15), with named Active Effects and exact Lapse restoration; the Papyrus log corroborates both tier ladders through 3->0. Hermaeus Mora Champion also passed its distinct Alteration +20 / maximum Magicka +20 boon plus Stamina -30 price and Lapse restoration. This closes the shared repair convention with one PeakValueModifier family, one non-resource ValueModifier family, and the unique multi-effect Champion regression. The remaining 39 tiers are readback-proven, not individually manually tested. Handoff: `handoff/PDV_AzuraPrice_ActorValueDiagnosis_Handoff_2026-07-26.md`; tester steps: `references/authoring/PDV_SmokePacket_1.0.3_2026-07-26.md`.
[x] Build-batch HIGH smoke test COMPLETE (2026-06-14) - the 9 pure-script HIGH friction/gate items from the 9-race beta audit are in-game proven via Papyrus.0.log (tests 1-9 PASS; test 10 Survey copy spot-checks folded into the editorial rewrite pass). Items: Orc life-mode evidence-gate no-flip + EvaluateOrcLifeModeAtDawn, Redguard sect evidence-gate + HoonDing weekly cap, Nord IsNordOfferEligibleDeity (all baseline gods + Talos, not just Kyne), Imperial ApplyImperialCurseHandlers (Nine Divines accrual 0x while halted), Dunmer ApplyDunmerCurseHandlers (ancestor silence), Argonian TryArgonianNearWaterMaintenance, Altmer GetAltmerLorkhanPietyPenalty, Breton DecayBretonWitchcraftExposureAtDawn, neglect Debug.Notification fallback. Verified: StateTrack evidence-gate holds (single signal never flips; the 2nd distinct-day signal applies the switch IN-HANDLER not at dawn) + day-rollover auto-dawn self-fires; Nord commitment offer is STATE-ONLY (sets PDV.Commitment.PendingDeityIndex + trace, no popup - MCM-surfaced, diegetic deferred); neglect eligibility = piety>0 OR active patron (patron forced to 0 guaranteed flagged; once-per-save PDV.Neglect.PatronToastState guard). Build .psc live on D:\...\Devotion\Scripts\Source (NOT repo-tracked); compile 0/0, verify FAIL=0, readback 1280/0. Next: editorial Survey-rewrite pass + ESP-record build pass. Memory: signal-prefix-via-named-blessing, bosmer-neglect-threshold-is-10-not-25, diegetic-surfacing-d0-gated, survey-toast-narrator-voice-sweep.
[~] Khajiit beta-feel gap closure + enablement audit (2026-06-13) - end-to-end audit confirmed Khajiit ~96% wired (T1/T2/T3 rewards all 5 gods, Baan Dar avoid-death capstone, likes/dislikes v7, organic routes 10/33/90/91/92 all machine-PASS; the lone reward-readback FAIL was a verifier blind spot, not a content hole - see Decisions Log). Closed the 2 real gaps: (1) 5 phase-blessing SPEL+MGEF authored (PDV_Bless_Khajiit_Phase_*, ValueModifier per the shipped Lunar T1/Khenarthi T2 convention, NOT PeakValueModifier) via new `pdv-phase20-khajiit-author --author-phase-blessings`, 5 manager props wired; in-game proven (Alkosh phase blessing shows for the presiding god once that god is Faithful/tier 2). (2) Full Lunar curse-posture: PDV_State_KhajiitLunarPosture StateTrack (Normal/Strained=werewolf/Corrupted=vampire/ShadowDrift) + 5 curse MessageBoxes (PDV_Msg_Khajiit_CurseState_*) via new `--author-posture`, built on shared PDV_CurseState; manager RefreshKhajiitLunarPosture/ApplyKhajiitCurseHandlers + ShadowDrift evidence (night Rajhin-theft, 3-in-7, honors the LOCKED boundary) + Survey overlay + MCM "Khajiit lunar posture" cycle button; compile 0/0, reward readback 1280/0, verify FAIL=0; MCM posture cycle + curse messages proven in-game. Pending: phase-blessing + Breton creed-loss description re-author (Skyrim was open; specs fixed, ESP write queued) and full organic beta-feel proof. Guides: PDV_Khajiit_BetaRaceGuide.md (tester "what fires what triggers") + PDV_Khajiit_PlayerGuide.md (player flavor) + PDV_Khajiit_PapyrusOptimization_Review.md.
[~] Bosmer variety tranche "The Story Goes On" + path-family reward layer (2026-06-13) - records authored/written (4 Songs LCTNs resolved; slot-2 swapped WhiterunWindDistrict->Temple of Kynareth 01F87D because the former is not an LCTN), Papyrus runtime layer applied (dreams/Hearth+Tale Carried/Songs/Scales/Baan Dar Gap/Naming), 5 scripts compile 0/0, verify FAIL=0; 14 PDV_Bless_Bosmer reward SPELs confirmed live + wired; debug MCM gained Bosmer->LivingStory/Exchange + "Seed Bosmer variety" buttons. Manual runtime now has partial pass evidence: DA05 stages 100/105, wrong-origin rejection, generic-source silence, OldContract threshold snapshot, LivingStory rewards, Exchange mechanics, and Green Dreams passed. Remaining smoke: fresh-load Naming retest, PeakValueModifier neglect feel, Exchange T1/T2 copy display, Baan Dar combat-session cadence, remaining variety levers, Bandit Road/broad-Y'ffre stack, feel, and asset status. Handoff: references/authoring/PDV_SessionHandoff_BosmerRuntimeFixes.md
[x] Daedric 16-Prince roster beta-feel PASS (2026-06-13) - pact redesign (one-active hard switch + ~2x magnitudes) in-game proven; PDV_DaedricRuntimeEvidenceLedger.json all-16 overall=pass; Champion offer (Message.Show over open MCM) fixed via deferred replay; final-world placement separate
[~] Khajiit organic edge hooks record-wired (2026-06-12) - Baan Dar/Rajhin/Alkosh normal-play detection in PDV_PlayerEvents; --check-khajiit-organic PASS; beta-feel packet PDV_Khajiit_BetaFeelPacket.md pending -> Khajiit stays Conditional
[x] MCM debug-menu cleanup (2026-06-12) - paginated race-first pattern summary; Debug split into "State & Rewards" + "Daedric & Curse"; state-axis Champion-proc setters (Khajiit focus / Breton tradition / Orc mode / Argonian focus)
[x] V3 per-race piety architecture fix - Khajiit pilot COMPLETE & runtime-proven (2026-06-07);
      double-route piety, emphasis 3-tier rewards, neglect, anti-creed, shared-deity reconciliation;
      generalized race-contract template ready to propagate to the other 9 races (Phase 2).
      Detail: references/authoring/PDV_SessionHandoff_KhajiitPilot.md
[~] Argonian variety tranche + all-races highest-tier reward consolidation (2026-06-11) - all scripts/records landed, machine gates clean (verify FAIL=0, 0 new completeness gaps); Argonian runtime-proven (dreams, waters+sap, kill-silence, sleep-cap) with reward-tier/Shadowscale/Adaptation in-game checks reachable via DebugSeedArgonian; other 9 races' consolidation needs a per-race smoke; repo commit 3d600bc
[~] Phase 2 all-race propagation (2026-06-07) - automated/static all-race reward/receiver gate complete; runtime/manual beta packets pending
      - Phase A (design): generalized records author `tools/pdv-phase20-race-author/` (build 0/0,
        dry-run reproduces Khajiit ESP); 9 reward specs + 4 missing costing manifests + binding
        rulings + master deity roster + capstone signatures (LOCKED Bosmer/Khajiit, draft for the
        other 8); convergence review clean (0 deity-ownership collisions, 0 orphans, 22 new
        deities owned, FLST 10 -> projected 32)
      - Locked decisions: native-track-as-parity piety model; two-tier magnitude convention
        (universal combat <=~12%, narrow resist/regen/utility up to ~15); signatures at T3 capstone
        only on top of stat half; once/day saves with <=1 cheat-death per race; fallback-as-floor
        binding for all fiddly detections; broad worship is a STATE not a deity (R1); broad-T1
        editorIds match the manager's existing per-race props (R2); deities shared across races
        keyed by per-race stance (R4); Daedric forks via existing 20C system (R6); Nord Old Ways
        gods Shor/Tsun/Stuhn promoted to focusable per user decision; Argonian primal-unarmed lands
        on Sithis/Void T2 (parallel to Khajiit Baan Dar/Rajhin clawed builds)
      - B1 (deity scripts): 22 new `PDV_Deity_*.psc` authored (Akatosh/Mara/Arkay/Stendarr/Zenithar/
        Dibella/Julianos/Kynareth/Hist/Sithis/Magnus/Xarxes/Boethiah/Mephala/Malacath/Trinimac/
        Tuwhacca/HoonDing/Leki/Shor/Tsun/Stuhn). Collision-free SIGNAL_* blocks 1000-3199.
        Compiled clean: `0 error(s), 0 warning(s)` for every new script
      - B2/B3 static closeout: all ten races now have manager scoring and reward/neglect sync
        coverage; Imperial civic and Nord Nine Divines routes use parseable `sourceId` family
        tokens for per-Divine scoring; approved real-hook routing remains source/readback covered
      - ESP/static authoring: all-race reward/deity records, shared-deity reconciliation, Green Pact
        static layer, fallback-floor T3 capstone records, and SEQ refresh are authored/readback-clean
      - Static verification closeout: full PDV compile 0/0; strict race-costing `PASS=2841,
        WARN=2, INFO=30`; base wiring `sourceProperties=39`, `sourceFillRecords=30`,
        `routeEntries=24`, `rewards=10`; Prisma audit 11 checks; content verify `PASS=1081,
        WARN=0, FAIL=0, INFO=4`; Phase 2 reward readback `PASS=1268`
      - Open beta work: run the ten runtime/manual `PDV_BetaTestPacket_{Race}.md` packets,
        including Active Effects, stack snapshots, save/load sanity, rejected-hook silence,
        Survey/status clarity, feel notes, and ledger verdicts
      - Authoritative session detail: references/authoring/PDV_SessionHandoff_Phase2_AllRaces.md
[~] Daedric all-Prince beta-display tranche (2026-06-07; pact redesign 2026-06-11/12) - CAT-6 records/readback complete; one-active-pact HARD SWITCH + ~2x high-stakes magnitudes landed with version-gated old-save migration (commits 6866de5/47f1618); Hircine source/VMAD drift fixed (4d36f42); controlled QASmoke proof surface ready; Hircine-first in-game proof queue is next (see PDV_SessionHandoff_HircineAuditFixes.md); runtime proof pending
      - All sixteen Skyrim-present Princes have manifest-derived QUST/SPEL/MGEF/MESG/GLOB packets,
        path VMAD arrays, `PDV_FLST_DaedricPaths_All` membership, and manager FormList wiring
        authored/readback-clean through `tools/pdv-daedric-author`
      - All sixteen concrete `PDV_DaedricPath_<Prince>` scripts compile 0/0. Each Prince quest
        attaches exactly its concrete script; inherited base behavior is not co-attached.
      - MCM Debug `Daedric display proof` controls and QASmoke ACTI/REFR live-sender proof refs exist
        for every Prince, plus `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`; MCM also has a
        one-prompt `Route all Princes` sweep for fast route-log evidence
      - Exact organic PO3 quest-stage senders are wired/readback for all sixteen Princes:
        Boethiah `DA02` 100, Azura `DA01` 100, Vaermina `DA16` 190, Meridia `DA09` 500,
        Molag Bal `DA10` 200, Mephala `DA08` 60, Malacath `DA06` 200, Dagon `DA07` 100,
        Sheogorath `DA15` 200, Namira `DA11` 100, Sanguine `DA14` 200, Clavicus Vile
        `DA03` 200, Hermaeus Mora `DA04` 100, Nocturnal `TG09` 200, Peryite `DA13` 100,
        and Hircine `DA05` 100
      - `tools/pdv_daedric_runtime_check.mjs` is ready to verify the all-Prince route markers from
        `Papyrus.0.log` after the QASmoke activators are exercised
      - Latest gates: `pdv_content_verify` `FAIL=0/WARN=0/PASS=1081/INFO=4`;
        strict Phase 20 race-costing `PASS=2841/WARN=2/INFO=30`; reward readback `PASS=1268`;
        `pdv-daedric-author --check` `PASS`
      - Open beta work: run `references/authoring/PDV_DaedricControlledProof_Runbook.md`,
        capture Active Effects/summary/Prisma/display evidence, prove generic-source silence,
        then prove the all-sixteen organic vanilla senders and run Hircine/Molag Bal
        curse-access no-double-fire
[x] PDV_Framework.esp created
[x] Master quest and script skeleton running
[x] Phase 0 complete -- PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 complete -- StorageUtil data model, mirror globals declared and verified,
      PDV__ManagerQuest refactored (AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors)
[x] Phase 2 -- Functional alignment complete on disk; CK compile/wiring/runtime verification complete
      - PDV_DeityBase.psc (base class contract + debug global property) OK
      - PDV_Deity_Kyne.psc (first concrete, rubric implemented) OK
      - PDV__ManagerQuest.psc (per-deity StorageUtil API + dawn consolidation + poll-based debug harness) OK
      - VERIFIED IN GAME: patron activation, mirror globals, dawn clamp, and tier threshold transition
[x] PDV local toolchain -- `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, and `tools/pdv_author.mjs` built and documented
[x] Phase 3 -- ActionRouter kill-event slice complete; CK wiring and runtime verification passed
      - PDV_ActionRouter.psc + .pex OK
      - PDV__SM_KillActor.psc + .pex OK
      - PDV_ActionRouter quest + properties OK
      - PDV__SM_KillActor quest + PDV_Router property OK
      - Kill Actor Story Manager receiver node + Shares Event OK
      - SEQ generated under Devotion\Seq OK
      - VERIFIED IN GAME: Kyne activation, hostile bandit +0.5 scratch, hostile wolf -3 scratch,
        neutral-kill rejection, rapid dual-kill accumulation, and manual dawn consolidation/clamping
[x] Phase 4 -- framework scripts/tooling, live ESP wiring, and full in-game proof complete
      - `PDV__MainQuest.psc` + `.pex` bootstrap implementation OK
      - `PDV_Origin.psc` + `.pex` origin detection / Kyne seed helper OK
      - `PDV__ManagerQuest.psc` stance-aware scratch + rivalry plumbing OK
      - `PDV_DeityBase.psc` race-keyed stance + patron-only cumulative boon sync OK
      - `PDV_Deity_Kyne.psc` proof-slice script update OK
      - historical CK walkthrough archived under `archive/completed-phase-docs-2026-05-16/PDV_Phase4_CK_Steps.md`
      - `tools/pdv_compile.mjs` / `tools/pdv_verify.mjs` Phase 4 coverage OK
      - `tools/pdv_author.mjs` reversible overlay-patch authoring for supported existing-record wiring OK
      - VERIFIED IN ESP: `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`,
        Kyne stance row, Kyne boon assignments, and framework-owned `PDV__ManagerQuest.PDV_GLO_PatronDeity`
      - VERIFIED IN GAME: Nord bootstrap, Kyne seed, patron-only boon grant/removal, and save/load sanity
[x] Phase 5 -- MCM dev slice landed in script/tooling/docs, framework ESP wiring, and in-game proof
      - `PDV_MCM.psc` Status + Debug-only menu OK
      - manager MCM-safe roster/debug helpers OK
      - `tools/pdv_compile.mjs` SkyUI import chain + SKI output guard OK
      - `tools/pdv_verify.mjs` `PDV_MCM` coverage + SKI output hygiene OK
      - historical CK walkthrough archived under `archive/completed-phase-docs-2026-05-16/PDV_Phase5_CK_Steps.md`
      - VERIFIED IN ESP: `PDV_MCM` quest exists, script is attached, and required properties are wired directly on `Devotion.esp`
      - VERIFIED IN GAME: `PlayerDevotion` registers in SkyUI, `Status` and `Debug` pages load, the live Kyne/Talos/Auri-El roster renders, and debug patron override works
      - NOTE: MCM smoke path currently requires ReShade disabled in the Anvil Stock Game until the native conflict is understood
[x] Phase 6 -- coupled Talos + Auri-El hostile-path proof slice landed in script/tooling, CK wiring, and full in-game proof
      - `PDV_Deity_Talos.psc` + `.pex` OK
      - `PDV_Deity_AuriEl.psc` + `.pex` OK
      - `PDV_Origin.psc` generalized to small multi-deity seed table OK
      - `PDV__ManagerQuest.AwardCuratedSignal*()` helper path OK
      - verifier coverage for Talos/Auri-El + rivalry expectations OK
      - VERIFIED IN ESP: Talos/Auri-El quest records, FormList entries, origin properties, stance rows, and boon assignments
      - historical CK walkthrough archived under `archive/completed-phase-docs-2026-05-16/PDV_Phase6_Talos_AuriEl_CK_Steps.md`
      - VERIFIED IN GAME: Altmer bootstrap, Auri-El seed, Talos hostile-path rise, rivalry-driven Auri-El decay, patron-only boon removal, and save/load sanity
[x] V3 Preflight - script/tooling, framework record wiring, strict verifier gate, and clean-start smoke complete
      - `PDV_EventTypes.psc` + `.pex` central event/attribution constants
      - `PDV_EventBus.psc` + `.pex` dispatch service for validated event payloads
      - `PDV_ActionRouter.psc` carries direct-player/follower/environment attribution payloads; only direct-player kills score
      - `PDV__ManagerQuest.psc` has explicit patron-state API, named dawn pipeline slots, and gain pipeline no-op extension points
      - `PDV__MainQuest.psc` hard-fails visibly if PapyrusUtil is unavailable
      - `PDV_Origin.psc` records unsupported custom-race fallback and surfaces a first-load notification
      - `PDV_MCM.psc` Status page shows patron state and custom-race fallback diagnostic
      - `tools/pdv_compile.mjs` active set includes `PDV_EventTypes` and `PDV_EventBus`
      - `references/authoring/PDV_PreflightRouterServices.manifest.json` generates `PDV_PreflightRouterServicesOverlay.esp` as the first reversible ActionRouter/EventBus/EventTypes co-attachment canary
      - `tools/pdv_verify.mjs` strict preflight gate (`--strict-preflight`) is active and clean
      - VERIFIED BY TOOLING: `node .\tools\pdv_verify.mjs --strict-preflight --json` returns `FAIL=0` after framework record wiring and SEQ refresh
      - VERIFIED IN GAME (clean-start smoke): MCM load, origin seed, patron-state transitions, dawn consolidation, non-hostile no-change, hostile direct scratch gain + dawn consolidation, Talos/Auri-El rivalry proof via curated signal on hostile stance path, and save/load sanity
[x] V3 Structural Skeleton - framework scaffold wiring, strict gate, and runtime smoke complete
      - framework-owned scaffold records, arrays, and FormLists merged into `Devotion.esp`
      - strict skeleton gate is clean (`node .\tools\pdv_verify.mjs --strict-skeleton`)
      - VERIFIED IN GAME: `Show structural map` and `Run scaffold smoke` passed without changing patron mirrors, dawn behavior, or EventBus routing
[x] V3 Pattern Proving normal-play ingress closeout
      - `PDV_PlayerEvents.psc`, `PDV_EventSignalActivator.psc`, and `PDV_EventSignalEffect.psc` source and `.pex` are now live, and manager/EventBus pilot routes compile cleanly
      - latest strict gate is fully clean on `FAIL=0, WARN=0, TODO=0` (`PASS=579, INFO=28` at 2026-05-20 15:51 AEST after `PDV_FragmentBridge` verifier coverage was added)
      - Imperial Concordat and the counted Khajiit emergent/moon-cycle normal-play sleep ingress are proven in game on 2026-05-18
      - live `PDV_Player` alias wiring on `PDV__ManagerQuest` is complete; the origin timing fix now waits for playable controls/RaceSex-menu close before final origin capture
      - Slice 0 baseline inventory and Slice 1 normal-play ingress handoff packets are recorded in `PDV_Architecture_v3.md` Section 21.5; `references/authoring/PDV_Slice1SignalReceivers.manifest.json` records the manual CK receiver-record contract
      - VERIFIED IN GAME: Dunmer portable shrine + private/home shrine (`prayers=1; homes=1`), Bosmer OldContract Green Pact violation (`gp=1`), Hircine hunt rite (`sig=1; stigma=1; state=Legible`), and Bosmer/Hircine save-load sanity
[x] Phase 7 Nord/Imperial-first signal expansion complete
      - runtime proof is complete for hidden Talos shrine defiance on the real shrine reference, PO3 shout ingress on a clean Nord save, deity-side shout anti-farm behavior, and both Civil War social hooks
      - `PDV_REFR_TalosShrineDefianceSignal` is wired on the real hidden shrine reference and passes strict readback
      - `CW01A` (`Joining the Legion`, `Skyrim.esm:0D517A`) and `CW01B` (`Joining the Stormcloaks`, `Skyrim.esm:0E2D29`) both use stage `200` `SendModEvent(...)` one-shots and are runtime-proven through `PDV_PlayerEvents -> PDV_EventBus -> PDV__ManagerQuest`
      - strict closeout gate is fully clean: `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` => `FAIL=0, WARN=0, TODO=0, PASS=588, INFO=28` at 2026-05-20 16:44 AEST
[x] Phase 8 Imperial-first reputation track closeout complete
      - `PDV_ReputationTrack.psc` now persists committed state, pending state, lock-in timing, and the extreme reset gate; `PDV_DeityBase.psc` owns track-driven gain/decay multipliers; `PDV__ManagerQuest.psc` wires Talos runtime track usage and repairs bad baked Talos values on older saves
      - core runtime proof is complete on 2026-05-21 for baseline `Uncommitted`, pending transition start/cancel, 3-day commit, committed-vs-raw multiplier resolution, extreme-state inward halving, gate unlock, save/load persistence, and 3-day exit from the extreme band
      - strict closeout gate is fully clean: `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` => `FAIL=0, WARN=0, TODO=0, PASS=642, INFO=28` at 2026-05-20 20:20:45 AEST
      - `PDV_Phase8ConcordatTalosOverlay.esp` is now a historical authoring artifact only and remains inactive; steady-state runtime wiring lives in `PDV__ManagerQuest`
[x] Phase 9 Bosmer path-state closeout complete
      - framework-owned Bosmer path records, Y'ffre/Z'en/Baan Dar eligibility, six Bosmer message boxes, manager properties, `PDV_FLST_AllDeities` membership, and the five placed proof activator references are live in `Devotion.esp`
      - runtime proof is complete on 2026-05-24 for all five proof-surface routes (`41-45`), Living Story offer/accept/confirm, Exchange offer/accept/confirm, Bandit Road offer/accept/confirm, Old Contract re-entry offer/accept/confirm, Old Contract PactBound/compliance separation, forced reckoning `Renounce`, forced reckoning `Recommit`, and save/load persistence after re-entry
      - runtime proof surfaced and fixed a real `PDV_StateTrack` bug: destination offers that require three evidence days now retain/count `LatestDay`, `PreviousDay`, and `ThirdDay` instead of only two evidence days
      - strict closeout gate is fully clean: `node .\tools\pdv_verify.mjs --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving --json` => `PASS=808, WARN=0, FAIL=0, INFO=28` at 2026-05-24 AEST
[x] Phase 10 Dunmer ancestor substrate proof-graduation complete
      - runtime proof is complete on 2026-05-24 from a fresh Dunmer baseline: active patron piety/deity roster values stayed `0.000000`, while `DunmerAncestor` began at `metric=0.000000; tier=0; prayers=0; homes=0`
      - private/home shrine route `31` advanced substrate only to `metric=8.000000; tier=1; prayers=0; homes=1`; portable shrine route `30` after the daily gate cleared advanced substrate only to `metric=13.000000; tier=1; prayers=1; homes=1`
      - save/load persistence passed, and the strict closeout gate is clean: `node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving --json` => `PASS=847, WARN=0, FAIL=0, INFO=28`
      - follow-up fixed in the next-packet pass: `PDV_ACTI_DunmerPortableShrineSignal` now uses `PDV.Signal.DunmerPortableShrine.Activator`, private/home keeps `PDV.Signal.DunmerHome.Activator`, and `--strict-phase10` fails if they drift back to one shared key
[x] Khajiit / commitment / neglect-decay runtime packet complete
      - source/verifier/tooling scaffold is live: `--strict-khajiit`, `--strict-commitment`, and `--strict-neglect-decay`; compile pass for `PDV__ManagerQuest.psc` succeeded after the next-packet source edits
      - Khajiit focused emphasis uses `PDV_GLO_KhajiitFocusedEmphasis` as the CK-readable mirror and keeps formal `PDV_GLO_PatronState` out of Khajiit focus
      - safe ESP helper ensured the Khajiit mirror global/property, repaired Phase 10 Dunmer cooldown keys, created `PDV_MGEF_Neglect_Kyne` / `PDV_SPEL_Neglect_Kyne`, and wired the manager spell property; backups were written under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\next-packet\`
      - runtime proof passed for Khajiit Khenarthi/Azurah focus and persistence, Kyne commitment offer/decline/refuse/accept/persistence, and Kyne neglect/decay grace, once-per-day tick, spell apply, and spell removal
      - current full combined gate is clean at `PASS=898, INFO=29`, with no `FAIL`, `WARN`, or `TODO`
[x] Phase 13 Hircine/Nord pilot
      - framework packet is live: `PDV_DaedricPath_Hircine`, Hircine price records, stigma global, manager routing, EventBus routing, MCM actions, and strict `--strict-phase13` coverage
      - runtime proof passed on 2026-05-28 for the live Hircine gate and exit loop: hunt-rite signals/stigma, negative no-piety pre-gate behavior, Seeker and Devoted price activation, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path
      - durable cadence lesson: same-day Hircine hunt rites are throttled by the shared repeat multiplier, so Seeker proof requires one rite on each of three in-game days; same-day spam can reach `sig=3` while still staying below `ThresholdSeeker`
[x] Phase 14-16 generic seam closeout complete
      - Phase 14 runtime proof passed on 2026-05-28 for Kyne seed/evaluate, the `Not Yet` / `Refuse` / `Accept` branches, and accepted-patron persistence; the current 2026-06-25 cadence supersedes the old 7/14-day reoffer timers with one offer per qualification, lapse-and-rebuild reoffer, and per-deity terminal refusal
      - Phase 15 runtime proof passed on 2026-05-28 for the shared `PDV_CurseState` werewolf/vampire/none seam, with live Hircine curse-entry and werewolf-cure traces in `Papyrus.0.log`
      - Phase 16 runtime proof passed on 2026-05-28 for active-Kyne low-piety neglect selection, Kyne neglect-spell application, and broad-worship suppression clearing the active neglect set on re-evaluation
      - targeted strict gate after the debug-path hardening is clean at `FAIL=0, WARN=1, PASS=1092, INFO=28`, with only `SEQ freshness` still warning
[x] Phase 17 decay bridge
      - source/readback implementation is live: active patrons are skipped by passive dawn decay, non-patron deities still drift, and Phase 17 has dedicated MCM proof controls plus `references/authoring/PDV_Phase17DecayModel.manifest.json`
      - runtime proof passed on 2026-05-28 for grace no-op (`20.00 -> 20.00`), eligible decay (`20.00 -> 19.50`), same-day guard (`19.50` held), broad worship (`20.00 -> 19.90`), active-patron skip, non-patron drift while Kyne stayed protected, Devoted floor (`50.00 -> 10.00`), and Champion floor (`150.00 -> 50.00`)
      - runtime proof also regression-checked Phase 16: broad worship suppressed neglect (`count=0; kyneSpell=0`), and active Kyne produced targeted neglect (`count=1; active=Kyne; kyneSpell=1`)
      - full bridge gate was clean at Phase 17 closeout; after the Phase 18 dialogue save, SEQ refresh, and final dialogue smoke, the current Phase 18/Nord gate is clean at `PASS=1185, INFO=28`
[x] Phase 11 privilege pilot
      - D-10 is resolved to the Arngeir/Kynareth recognition pilot with gate `OriginRace = Nord`, `ActiveDeityIndex = Kyne`, and `ActiveTier >= 3`
      - generated Arngeir dialogue records were removed after a CrashLogger-confirmed CTD; the live replacement is CK-authored and verifier-covered as a `DLBR`, `DIAL`, and CK-authored unnamed `INFO`
      - runtime proof passed on 2026-05-26 for Nord/Kyne Champion positive, non-Nord negative, wrong active deity negative, below-Champion negative, and save/load sanity
      - current full combined gate is clean at `PASS=908, INFO=28`, with no `FAIL`, `WARN`, or `TODO`
[x] Phase 18 status/debug surface
      - `PDV_SPEL_SurveyDevotion` / `PDV_MGEF_SurveyDevotion` are live in the framework ESP, `PDV_SurveyDevotionEffect` compiles, and `PDV_MCM` now has Player/Status/Debug pages with Developer Options gating
      - strict bridge/readiness gate including runtime-proven Phase 17 and live Nord dialogue readback is clean at `PASS=1185, INFO=28`, with no `FAIL`, `WARN`, or `TODO`
      - runtime matrix is complete in `references/authoring/PDV_Phase18StatusNord.manifest.json`: fresh-save auto-grant, Survey MessageBox/Z-slot activation, Player tab readout, Developer Options persistence, broad/focused Nord readouts, vampire suppression/scar, save/load persistence, and per-speaker dialogue positives/negatives
[x] Nord module complete
      - Nord player-status, broad/focused readout, vampire suppression/scar handling, Hircine/werewolf feedback, and Survey record/helper/verifier coverage are live
      - Froki, Heimskr, Andurs, and Aela dialogue records are CK-authored/live as branch/topic/unnamed INFO chains, strict-verifier-covered by speaker, prompt, response, topic, and conditions, and runtime-proven with positive and negative in-game dialogue checks
[x] Phase 19 live generated patch closeout
      - `tools/pdv_patch.mjs build` now emits `PDV_ClassificationPatch.esp` as an active ESL-flagged generated artifact with six approved Temple LCTN `LocTypeTemple` overrides
      - `tools/pdv_verify.mjs --strict-phase19` verifies approved-rule dry-run output, active Devotion Dev profile/load-order placement, generated patch readback, proof-rule absence, and source-plugin safety
      - Packaging boundary: this generated patch is a dev/review artifact; approved core vanilla/DLC rules are eligible for later main-ESP promotion, while compatibility/list-specific rules stay separate generated patches
[~] Phase 20 full roster architecture lock
      - Phase 20 now owns the full 1.0 roster target: every locked race-architecture god and all sixteen Skyrim-present Daedric Prince surfaces must be content-ready for every race
      - `references/authoring/PDV_DeityCoverageMatrix.json` is the roster authority for response state, commitment gate, boon/favor surface, price/neglect/stigma, exit/residue, hook source, implementation status, verifier status, and runtime proof status
      - `--strict-phase20-roster` is the first strict tooling gate; content implementation remains future Phase 20B-E work
      - Altmer has crossed from costing-only into compiled source plus `PDV_State_AltmerCrisis` record wiring, two wired favor spell records for dawn steadiness and orthodox costly enforcement, four wired ACTI trigger proof base records for crisis, Lorkhan pressure, dawn steadiness, and orthodox cost, three wired curse/exile `MESG` records, four QASmoke proof references, and route runtime proof; final immersive world placement and pre-beta gameplay scaling remain open
      - Argonian has crossed from costing-only into compiled source plus concrete `PDV_Substrate_ArgonianHist`, record-wired `PDV_State_ArgonianHistPosture`, four wired ACTI trigger proof base records for Hist maintenance, People support, Void threshold, and bed-of-choice cadence, manager/status surfacing, four QASmoke proof references, and route runtime proof; pre-beta gameplay scaling remains open
      - Orc has crossed from costing-only into compiled source plus record-wired `PDV_StateTrack_OrcLifeMode`, four wired ACTI trigger proof base records for Stronghold forge, City dignity, Legion/Exile service, and self-made community, manager/status/curse posture surfacing, four QASmoke proof references, and route runtime proof; pre-beta gameplay scaling remains open
      - Redguard has crossed from costing-only into compiled source plus record-wired `PDV_StateTrack_RedguardSect`, four wired ACTI trigger proof base records for Crown tomb respect, Forebear road passage, Ash'abah death duty, and Far Shores token use, manager/status/curse-cycle surfacing, four QASmoke proof references, and route runtime proof; pre-beta gameplay scaling remains open
      - Khajiit has crossed from costing-only into compiled source plus readback-covered `PDV_Substrate_KhajiitLunar`, `PDV_GLO_KhajiitFocusedEmphasis`, six wired ACTI trigger proof base records for moon observance, two road-home anchors, Baan Dar, Rajhin, and Alkosh, manager/status focus-weight surfacing, six QASmoke proof references, and route runtime proof; pre-beta gameplay scaling remains open
      - Bosmer non-hunter parity has crossed from costing-only into compiled source plus eight wired ACTI trigger proof base records for Old Contract proper hunt/forest kept, Living Story community/nature proof, Exchange debt/redress, Bandit Road road-life/reversal, eight QASmoke proof references, and route runtime proof; pre-beta gameplay scaling remains open
      - `references/authoring/PDV_PreBetaRaceScalingSpine.md` now owns the next internal scaling gate: Altmer active spine, Khajiit first contrast, Argonian second contrast, Orc/Redguard/Bosmer P1 packets, and Breton/Dunmer/Imperial/Nord P2 audit-only stack/ceiling packets
[~] Phase 21 compatibility rebaseline
      - Phase 21 is Authoria-first list-author compatibility, not Sacrosanct-first standalone compat
      - tracked source of truth is `references/vanilla-gameplay/compatibility/phase20-targets.csv` plus `PDV_Phase20_CompatibilityNotes.md`
      - 1.0 compatibility gate is an accepted Authoria integration/test package; JOJ, TOT, HOH, MOM, DoD, and VOV should reach `patch-packaged`
      - full compatibility testing waits until Phase 20 makes the full mod surface stable enough to test against a modlist
```

---

## Standing Rules

Active project rules consolidated from the decisions log, in present tense.
Originating dated entries are in `archive/PDV_DecisionsLog_Archive_2026-05.md`.

**Doc & decision hygiene**
- When a design review locks a rule, ratify it across all affected living docs
  in the same session; never leave it stranded in one planning patch or chat
  summary. (Workflow ratification, 2026-05-18)
- After broad doc merges, run a short consistency sweep for overview drift,
  superseded-rule leftovers, and encoding/ASCII regressions.
- Every PDV doc-sync must record durable lessons learned in the living docs, or
  state plainly that none qualified; silent closeouts are incomplete doc syncs.
  (doc-sync learning capture ratified, 2026-05-20)

**Regression & verification discipline**
- When CK/xEdit/MO2 work could regress silently, add or tighten verifier
  coverage before trusting memory or a one-off smoke.
- For Skyrim plugin work, before finalizing any created, edited, merged,
  repacked, or installed ESP/ESL, explicitly check plugin master/header order.
  Confirm vanilla game masters are first in proper order, all required masters
  are present, and binary validation does not report "game master is not first",
  "misordered masters", "extended master", or similar header warnings. If master
  order is wrong, fix or rebuild the plugin header and rerun validation before
  interpreting downstream record warnings as real. Use houseCARL for resolved
  load-order/winner checks, but use SSEDump, xEdit, or Mutagen-style binary
  validation for the plugin file itself when checking master/header order.
  Final responses for ESP/ESL work must report the master-order result.
- Smoke-test standard is "full phase closeout unless explicitly narrowed."
  (Phase 4/6 closeout, 2026-05-16)
- When Papyrus compile errors appear, triage in this order: import chain,
  API/source provenance, parser/language limit, then logic bug.
- Cross-cutting audits use the **gate-first, registry-driven** discipline: enumerate the
  full unit set in a registry, score each unit against a floor/contract, build a fail-closed
  gate that reconciles DESIGN->DECLARATION->WIRING->PROOF (never trust declared status -- the
  recurring PDV bug class is "declared/designed but not wired end-to-end," silent in Papyrus),
  treat gate runs and their committed machine-read artifacts as the source of truth over
  hand-status docs (report renderings are regenerated on demand, not committed --
  PDV_STANDARDS.md section 5.3), put DETERMINISTIC
  checks in scripts/gates and reserve agent swarms for genuine judgment, make every checker
  self-testing, adversarially verify findings, and use **houseCARL for the ESP-reality proof
  layer** (true load-order winner + record detail), gated by MCP liveness and SKIP-not-PASS
  when down. (Cross-cutting-audit doctrine, 2026-06-24; memory [[cross-cutting-audit-doctrine]])
- **Gates assert invariants, not snapshots of correct values.** A gate that hardcodes an expected
  value goes red on every legitimate change to that value, and the red says nothing about
  correctness -- it says someone forgot to edit the gate. `pdv_verify.mjs` used to pin
  `EXPECTED_LIKES_DISLIKES_VERSION` / `EXPECTED_PRINCE_LD_VERSION`; it now READS both out of
  `PDV__ManagerQuest.psc` and asserts what actually matters (the property exists, is well-formed,
  is positive), matching how `pdv_signal_e2e_gate.mjs` already read it. **Bumping
  `LIKES_DISLIKES_VERSION` no longer requires a verifier edit -- do not re-pin it.** Apply the same
  test to any new gate: would a correct, intended change make this fail? Then it is pinning, not
  verifying. (2026-08-03, found during Altmer packet P1)
- **Snapshot the live mod before any record- or script-writing packet.**
  `node tools/pdv_snapshot_live.mjs --label <packet>-pre`. `Devotion.esp` lives outside the repo and
  is NOT git-tracked; the only ESP in git is a 2026-06-15 snapshot ~116KB adrift from live, in a
  directory that is now gitignored. GitHub Releases are recovery at *release* cadence only -- opaque
  binaries you cannot diff or roll back per packet. Snapshots land in
  `generated/live-devotion-backups/` (`.gitignore:10`), which matters because the repo is **PUBLIC**:
  tracking the dev ESP would publish unreleased records. ~4.7MB / 204 files, sha256-verified;
  `--restore` auto-snapshots first so a restore is reversible. (2026-08-03)
- **An in-place write can SILENTLY REVERT an earlier in-place edit to the same plugin. Re-verify
  earlier records after every later write.** Confirmed data loss 2026-08-03: packet P1 added 10
  `Stance_*` VMAD properties to `PDV_Deity_Syrabane` and verified clean (14 read back individually);
  two packets later the record was back to 4 and everything built on it was silently scoring 0.0.
  **The only tell was FILE SIZE** -- after P1 `Devotion.esp` was 637,838 bytes; after P7's write,
  which ADDED a property, it was 637,765. An additive edit cannot shrink a plugin, so P7 rewrote
  from a **pre-P1 parsed model**, reverting P1 and then applying its own edit. P7's and P9's own
  edits survived; only the earlier one was lost.
  Probable trigger: the houseCARL instance was switched away and back between the two writes.
  **So:** watch the byte count the tool prints on every in-place write; never switch instance
  mid-session on a plugin you are editing, and if it is switched treat every prior in-place edit to
  that plugin as SUSPECT; prefer ONE batched call over several sequential ones. Per-write
  verification is necessary and NOT sufficient -- it only ever proves the record you just touched,
  at the moment you touched it. (2026-08-03; memory [[inplace-write-silently-reverted-earlier-edit]])
- **A gate's verdict is its EXIT CODE or its overall status -- never a grepped sub-field.** The
  gates already exit non-zero on failure by design (`tools/pdv_signal_e2e_gate.mjs:166`; its header
  says "exits 1 for every non-GREEN run so CI/pre-commit cannot go falsely green"). **Piping
  defeats that**: `node tools/pdv_signal_e2e_gate.mjs | grep ...` returns GREP's exit status, so a
  FAIL is discarded silently while the fields you happened to grep look healthy. Run the gate
  unpiped and check `$?`, or redirect to a file and read the top-level `status` plus all seven
  section statuses. Proven 2026-08-03: a packet was signed off on grepped dispatch counts while
  `sourceFill` was RED -- a new FormList had a `sourceProperties` entry but no `sourceFillEntries`
  member authority, and it surfaced two packets later by accident. **A gate you have not seen
  return a verdict has not run.** Do not "fix" this by making gates print louder; they are already
  correct. (2026-08-03; memory [[gate-verdict-is-exit-code-not-grepped-field]])
- **A new P2 source FormList needs BOTH manifest entries.** `sourceProperties` (the route
  declaration) *and* `sourceFillEntries` (per-member `approved-for-fill` authority) in
  `PDV_Phase20_P2ImmersiveReceivers.manifest.json`. Only the second is checked by
  `pdv_housecarl_p2_readback.mjs --check-source-fill`; a list with members but no fill authority
  fails there and nowhere else.
- **CONFIRM houseCARL's MO2 instance before ANY readback that becomes a claim.** The instance is
  GLOBAL and PERSISTED (`houseCARL.user.json`, "persists across restarts"), so an agent that points
  it elsewhere silently redirects every later read for everyone. `Devotion.esp` exists in **both**
  Anvil and ARR 2.5, so a wrong-instance read does not error -- it returns a DIFFERENT, older record
  set. Proven 2026-08-03: a P7 verification reported "FormID not present in the load order (3799
  plugins)" for a record that existed perfectly well; houseCARL had been left on
  `D:\Wabbajack\modlists\ARR 2.5` profile `KoK R11`. The 3799-plugin count and an
  `Authoria - Output - *.esp` winner are both tells that you are on ARR, not Anvil (Anvil is ~357
  plugins, profile `Devotion Dev`). Check with `housecarl_load_order_status` first; restore with
  `housecarl_set_mo2_instance path="D:\Wabbajack\modlists\Anvil"`. **If you switch the instance for
  any reason, switch it back and say so in your handback.**
  (2026-08-03; memory [[compat-reference-instances]])
- **A `REQ_` EditorID on a `XXXXXX:Skyrim.esm` FormID is a RENAMED vanilla record, not a Requiem
  addition** — and `editorid_contains=` matches the load-order WINNER's name, so searching a vanilla
  stem can return **zero matches for a record that plainly exists**. Proven 2026-08-03: the three
  vanilla ward tomes `SpellTomeLesserWard` (`09E2AE`), `SpellTomeSteadfastWard` (`0A2720`) and
  `SpellTomeGreaterWard` (`0A2722`) all surface as `REQ_Tome_RestorationN_Ward_ConcSelf` at override
  depth 4 under `Authoria - Output - Synthesis Gameplay.esp`. Same trap on `AlchCureDisease` ->
  `REQ_Alch_CureDisease`. Pin the read with `plugin="Skyrim.esm"` to get the true identity.
  **A null result from ONE EditorID stem is not evidence of absence.** Before writing "no vanilla
  source exists" into a spec, vary the stem, search by `type=` + a broad stem, or check the defining
  plugin -- and state which of those you actually did. This was concluded wrongly twice in one
  session from a single failed query. (2026-08-03; memory [[requiem-renames-vanilla-records-in-queries]])
- **`live-source/Scripts/Source/` and the MO2 tree are two separate directories, not a junction.**
  The compiler and `pdv_verify` both read
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\`. An edit made only in the repo mirror
  will pass a gate that never saw it -- and did, on 2026-08-03. Copy across and `diff -rq` both
  trees before calling any Papyrus work done.

**Codex coordination & audit follow-through**
- At each pause, proactively hand the user ready-to-dispatch **Codex handoff docs** (do NOT ask
  permission to write one), each with a one-line **parallel-vs-serialize verdict** against their
  running implementation queue (shared `.psc` / manifest array / compile-gate / `Devotion.esp`
  in-place write = serialize; disjoint files = parallel-safe). Claude owns design/gate-spec +
  adversarial acceptance; Codex owns bulk build. (Always-write-handoffs rule, 2026-06-24;
  memory [[always-write-codex-handoffs-and-wrap-audits]])
- When a new audit/analysis surfaces findings, **wrap them into the existing open-items / ledgers /
  handoffs** with quantification + cross-links (mark superseded "not-yet-built" lines done, paste
  the actual ranking/list), then **commit the committed-class artifacts immediately** (hand-authored
  authority, evidence store, pipeline state -- PDV_STANDARDS.md section 5.3; regenerable reports
  are never committed, rerun their tool instead) -- never leave a finding
  stranded in a fresh one-off doc or uncommitted (untracked audit work can evaporate; see
  [[live-manager-not-in-git-disappearance-risk]]). No broad rewrites; don't touch AGENTS.md
  unprompted. (Audit-wrapping rule, 2026-06-24)
- Accept each Codex spine/parity build with the **5-refuter adversarial workflow** (deterministic
  suite + boon-unconditional - pulse-fires - ESP-boon-exists - no-regression - race-specific);
  accept iff all refuters clean + compile 0/0 + verify FAIL=0. HARDCODE race-specific values in the
  acceptance script -- Workflow `args` do not inject reliably. (Adversarial-acceptance cadence, 2026-06-24)

**Tooling harvest**
- After a new kind of PDV work, while it is still fresh, ask whether the next
  pass should be easier, safer, or more repeatable. If a pain point is manual,
  fragile, repeated, or easy to forget, harvest it into the smallest durable
  surface: a verifier check, authoring helper, manifest, checklist, local skill,
  or living docs. (Tooling harvest rule, 2026-05-24 -- full entry in Decisions Log)

**Gameplay posture (load-bearing for Phase 7+)**
- Quiet / event-led / recoverable / vanilla-plus play is architecture truth.
  Reject raw skill-XP scoring, raw craft-count scoring, routine notification
  spam, and chore-loop religion as default PDV design shapes. (Gameplay posture
  lock, 2026-05-18)

**Panel/dashboard copy**
- Prisma dashboard/weekly "recent drivers" row copy (`HumanizeDriverReason` /
  `HumanizeCuratedSignalReason` in `PDV__ManagerQuest.psc`) must plainly state
  the fire-when trigger ("a quest paid in gold", "a quest done at night"),
  never poetic/mystical flavor -- the god-card header already carries the
  mood/identity, the row's job is mechanical legibility. Does NOT extend to
  Survey/toast narrator copy, which keeps its established voice. (Driver-copy
  ruling, 2026-07-05; memory [[driver-copy-describe-trigger-not-flavor]])

**Release scope (V1 vs V2)**
- V1 (1.0) ships no voiced NPC dialogue. All spoken-dialogue content - the
  Phase 11 privilege/recognition dialogue lane, the Phase 18 Nord recognition
  quartet, and the 39 `PDV_Dlog_*_Recognition` stubs - is V2. In V1, deliver any
  "dialogue privilege" / "recognition" payoff through non-voiced surfaces only
  (MessageBox, notification, Survey, faction/disposition). Deferred work lands in
  `references/authoring/PDV_V2_Backlog.md`. (Voiced-content non-goal,
  2026-05-31 - full entry in Decisions Log; rule in `PDV_Architecture_v3.md`
  Section 21.3)
- Release-prep cleanup completed 2026-06-24: `tools/pdv-release-prep-author`
  removed the parked Phase 11 Arngeir/Kyne and Phase 18 Nord spoken-dialogue
  `DLBR`/`DIAL`/`INFO` records from the live V1 `Devotion.esp`; `--check`
  now readbacks them absent. This is machine/readback proof only; V2 can rebuild
  curated dialogue from the backlog/specification later.

**Authoring boundaries**
- Schema-first / text-first ESP authoring stays research-only. Until a proven
  build tool exists, the source of truth is the living docs, PDV `.psc` source,
  `Devotion.esp`, the `housecarl_*` MCP tools, and the supported `tools/pdv_*`
  compile/audit/verify helpers; do
  not treat any YAML/TOML schema draft as authoritative state. (2026-05-16)
- Overnight/unattended windows may pull forward only the narrow set named in
  `PDV_Architecture_v3.md` Section 21.5 (commitment + neglect/decay hardening,
  UI toast contract, Khajiit focused-emphasis scaffold, limited Bosmer path
  bookkeeping) without claiming parent slices complete. Do not pull forward
  privilege, full Daedric price/stigma, or curse-state work. (Overnight enabler
  rule, 2026-05-20)

**Tester-bundle distribution**
- Tester bundles ship as **GitHub Releases** (`gh release create prebeta-X.Y <zip> --title "Devotion PreBeta .Y" --notes-file <notes> --prerelease`)
  on the PUBLIC `dunhamma/DevotionModSkyrim`, NOT as new `dist/` commits (legacy FirstLook/Authoria
  zips already in `dist/` stay). The bundle is the clean MO2 deployable of the live `mods/Devotion`
  folder MINUS `Backups/`, `Scripts/Source/`, `*.pdb`, `*.bak*`, packaged with a top-level
  `Devotion\` folder plus an INSTALL & NOTES readme; verify completeness + `.pex` freshness and keep
  wording reviewer-safe before cutting. First release: `prebeta-0.8` (2026-06-30). (Tester-bundle
  release convention, 2026-06-30; memory [[tester-bundle-via-github-releases]])
- **A GitHub Release edit is not done until the repo says the same thing.** Publishing or
  updating a release -- cutting it, replacing an asset, or editing the notes -- and leaving the
  repo unchanged puts the public artifact ahead of its own source of truth, and the drift is
  invisible because nothing gates a release page against the repo. In the SAME session as any
  release write, land the repo side through a normal PR: the changelog entry for that version
  (`CHANGELOG.md` and `dist/release-meta/CHANGELOG.txt`), any doc whose text the release notes
  restate, and any tracked packaging state the build changed. Never leave it as an uncommitted
  working-tree edit.
- **Do it at the stage, not at the end.** When release work spans several steps, commit the repo
  side as each stage completes rather than batching it into a closeout that may not happen. A
  session that ends with a published release and an unsynced repo has shipped a fact nobody can
  reproduce from source. (Ratified 2026-08-09, after the 1.5.0 tester build's asset and notes were
  both updated on GitHub while `CHANGELOG.md` still ended at 1.0.2.)

---

## Decisions Log

- **[2026-08-20] - V3 merge acceptance is one commit-pinned three-gate contract:** Module smoke cards no longer independently authorize completion. Gate 1 proves the extracted modules through the existing MCM; Gate 2 proves the same-branch four-page/full-ST MCM revamp with Reduce Motion, 90-140% font scale, and Default/High Contrast/Colorblind Safe palettes; the final gate reruns the combined critical path. The evidence tool requires fresh logs, individual proof-slot notes, and no runtime-sensitive changes after the tested commit. Rationale: the previous cards proved useful wiring slices but overlapped, omitted cross-module state cleanup and support surfaces, and could not prevent a route log or stale session from being promoted into player acceptance.
- **[2026-08-20] - Race isolation gates enforce whole roster and neglect families, not named fixtures:**
  A defect is any ordinary run reaching a deity outside its current race-authorized roster or
  carrying another race/path's neglect family. Altmer-to-Baan-Dar and Nord/Kyne Frost Resistance
  remain useful concrete regression fixtures, but neither defines the invariant. The reachability
  gate therefore checks exact ordinary rosters for all ten races and exact reviewed offer sets for
  all six offer races; the module-contract gate checks every adapter's exact neglect helper and
  `PDV_SPEL_Neglect_*` reference family. Explicit formal-offer and Daedric pact lanes remain
  separately reviewed exceptions. Forced invalid state is test evidence only when the named unsafe
  injector emits its proof-invalidating marker and self-cleans. Rationale: fixture-specific gates
  would allow the same cross-race bug to recur under a different race, deity, or neglect spell
  while remaining green.

- **[2026-08-20] - Penalty serialization is an all-family record contract, not a module responsibility:**
  The V3 module interfaces own penalty eligibility and spell add/remove lifecycle; they do not
  interpret MGEF flags or stored SPEL magnitudes. A direct-houseCARL gate now inventories every
  linked `Neglect`, `Disfavor`, and `Price` effect and accepts both engine-valid encodings:
  negative magnitude without `Detrimental`, or positive magnitude with `Detrimental`, always
  with `Recover`. The first full sweep found one concrete fixture: Kyne's reused Frost Resistance neglect
  had positive `8` with no `Detrimental`; `PDV_MGEF_Neglect_Kyne_Stamina` was corrected in place
  without changing its FormID, actor value, magnitude, or carrier-spell link. Post-write result:
  81 spells, 82 linked effects, 79 modifier pairs, 79 valid, zero invalid; three legacy Hircine
  script effects remain explicitly outside the modifier rule. This is record/readback proof, not
  fresh-game, save/load, Active Effects, cure/dispel, or package proof. The invariant covers every
  linked Neglect, Disfavor, and Price modifier; it is not Kyne-specific. `pdv_verify.mjs` targets
  the V3 tree when `PDV_DEVOTION_ROOT` is set. `pdv_requiem_penalty_audit.mjs` now shares that
  resolver and passes 44/44 on both the default public tree and V3Dev; the Argonian spec/live
  visible name is reconciled to `The Hist Silenced`.

- **[2026-08-11] - Daedric effect composition is a deep module; balance remains a separate proof lane:**
  `tools/lib/pdv_daedric_effect_model.mjs` now owns every Prince's three boon and
  price declarations, the Mora Champion two-effect exception, and six independently
  tunable ActorValue unit families. The contract compiler crosses one
  `buildPrinceSpellPackets(...)` interface instead of combining a skill/not-skill
  fork with editor-ID override maps. The structural move is output-preserving: the
  compiler reports zero drift against all sixteen reviewed contracts and changes no
  ESP record or shipped magnitude. `pdv_verify` now resolves all 96 contracted spells
  and 97 effect references and links so a phantom generated MGEF cannot be misreported
  as an ESP defect again; the pre-existing 48-price gate continues to enforce price
  magnitudes. The first exhaustive comparison also surfaced 40 pre-existing boon
  magnitude differences, which remain #37 evidence rather than permission to rewrite
  the ESP or contract during this structural pass. Magnitude suitability, the
  one-live-pact premise, and Malacath's provisional movement price remain the separate
  #37 balance and felt-check lane.

- **[2026-08-11] - Release proof is re-derived live and fingerprints exact contested membership:**
  `pdv_release_proof_refresh.mjs` is the single script-backed workflow for checking,
  capturing, and promoting `PDV_HousecarlReleaseProof.json`. It fails closed outside Anvil's
  `Devotion Dev` profile or when houseCARL is unavailable, re-runs the VMAD audit, and hashes the
  sorted `formid|type|editorid|winner` contested set. The release packager invokes `--check`, so
  its former `contestedRecordCount === 33` literal is retired: a coincidental different set of 33
  now fails. Critical-target scope, contested CELL retention, and the open runtime/manual boundary
  remain explicit human confirmations during `--refresh`; timestamps and mtime are provenance,
  not substitute gates for byte identity. Rationale: PRs #64-#66 showed that manual proof refresh
  was both a release bottleneck and easy to reconstruct incorrectly from prose.

- **[2026-08-11] - Off-roster worship is blocked for new commitments while reduced-rate legacy patrons remain playable:**
  `SetActiveDeity` is the central selection boundary: normal commitments must belong to the
  origin roster or an active formal-offer lane, while the MCM's explicit debug route may override
  that rule. A stored patron restored from an older save may remain active only as a
  FOREIGN/TOLERATED grandfathered relationship; quest reactions and shrine prayer preserve that
  relationship at the canonical 0.4 matrix rate, while generic deed gains remain NATIVE-only.
  Quest-matrix amounts are stance-pre-scaled and therefore enter the gain pipeline without a
  second record-stance multiplier. `LIKES_DISLIKES_VERSION` 21 reprojects all 33 record stances on
  existing saves, and `pdv_deity_stance_parity.mjs` now gates JSON, ESP, and the runtime migration
  source together. Rationale: the stale migration table could silently restore several off-roster
  gods to NATIVE and the former quest path applied reduced stance twice.

- **[2026-08-11] - File gates must distinguish normalized text from exact bytes:**
  The current 22-tool compare/hash inventory is explicit: text freshness and generated-text
  checks normalize CRLF to LF; plugins, PEX/SEQ, fonts, archives, snapshots, cache keys, and
  receipts remain byte-exact; tracked writers select LF or CRLF deliberately. The first layer
  is a canonical `.gitattributes` rule and the second is `pdv_file_compare.mjs`, enforced by
  `pdv_file_semantics_audit.mjs`. Rationale: either layer alone can still false-fail or churn a
  clean checkout when `core.autocrlf` differs between machines.

- **[2026-08-11] - Documented CLI flags must select a real mode or leave the active contract:**
  The fourteen issue #61 flags now resolve explicitly: `--check`, `--dry`, and `--strict`
  select documented safe/default modes; `--json` selects structured output; the child-tool
  `--run` wording and retired combined-ARR `--expected-arr` option are removed. The
  `pdv_cli_flag_contract_audit.mjs` regression gate fails if a retained flag is only accepted by
  `KNOWN_FLAGS` without a semantic read. Rationale: a command that succeeds because its safety or
  output flag was silently ignored is a false interface, even when its accidental default happens
  to be safe.

- **[2026-08-11] - Drift gates must name competing authorities and distinguish verification from pinning:**
  Every new competing-source gate declares `authorityA`, `authorityB`, `runtimeWinner`,
  `allowedFallback`, `proofClass`, `driftClass`, and `skipRule` using
  `references/authoring/PDV_DriftGatePattern.md`. Legal values cannot be learned from the payload
  being validated, backend absence cannot become a silent pass, and stored literal expectations
  report as `PIN` unless the same run independently re-derives them. Rationale: stance, FOMOD,
  release-proof, and Prince-slug drift each survived a green check because the gate compared the
  wrong authorities or carried its own copy of the answer.

- **[2026-08-11] - Mechanical multi-file tool edits require exhaustive syntax and command verification:**
  A repeated text match is not evidence that every insertion point has the same syntactic shape.
  Before a transform touches multiple files under `tools/`, enumerate the exact targets, inspect
  each anchor around imports, strings, template literals, embedded scripts, nested structures, and
  generated regions, then apply the complete `PDV_STANDARDS.md` section 6.7c closeout sweep. That
  sweep runs `node --check` on every edited tool, reviews every insertion structurally, exercises
  accepted and rejected CLI paths when flags change, reruns affected documented commands, and
  confirms final file/edit counts. Rationale: PR #62 placed one insertion inside a multi-line import
  and another inside an embedded preload template; only exhaustive verification caught both.

- **[2026-08-11] - KID and SPID are strongly recommended soft dependencies for optional devotional reach:**
  Devotion remains functional without either framework. `PDV_GreenPact_KID.ini` and
  `PDV_ItemRecognition_KID.ini` distribute fifteen PDV semantic keywords for Green Pact and
  seven item-action families; `PDV_ReligiousRecognition_DISTR.ini` distributes twenty-nine
  faith keywords and twenty-nine matching cohort factions. Faithful standing maps cohorts to
  Friend, Devoted maps them to Ally, and only explicit hard rivals can map to Enemy; none of
  these rules add AI packages, attack-on-sight flags, spells, perks, or inventory. The MCM
  controls default on, all files install at the Data root, and external reputation systems may
  claim the recognition lane through `PDV.Recognition.Claim` / `.Release` / `.State` so the
  two systems do not apply competing relationship changes. Spoken recognition remains V2.

- **[2026-08-11] - PatchHub reactions must identify their source on both player-visible surfaces:**
  Each compiled `PDV_QRM_*` PatchHub channel carries the exact player-facing name of its
  manifest option as optional `sourceMod` metadata. The core queue carries that value to
  one Prisma toast and the matching persistent Book-of-Days entry; core reactions omit it.
  Existing saves pad the parallel journal source list before adding a new entry. For
  compatibility testing, the labelled toast and Book entry are how a player confirms a
  patch fired; under-the-hood piety and logs alone are not an adequate tester surface.
  Public tester delivery is one all-in-one FOMOD with required core plus every optional,
  dependency-gated patches. Internal core/PatchHub manifests remain separate proof inputs.

- **[2026-08-12] - Official quest audit is exhaustive and owner-resolved; recognition presentation is event-driven:**
  The official-content audit universe is the frozen 2,367-occurrence worklist,
  canonicalized to 2,274 base-game/DLC QUST records plus 60 Creation Club
  records. Direct houseCARL plugin reads, not the older filtered quest table,
  own semantic evidence. The promoted core contains 4,108 cells across 354
  quest EditorIDs, and the checkpoint is 2,334/2,334 with zero `UNREVIEWED`
  records. SPID relationship state now reconciles from devotional state,
  settings, external ownership, and load events rather than the manager's
  periodic maintenance sweep. Effective identity/band transitions receive one
  Prisma-first notice plus one Book-of-Days entry, guarded by
  `PDV.Recognition.LastPresentedSignature`; the focused panel and normal MCM
  page expose current capability. Copy says adherents *may* react and never
  claims that SPID or a particular NPC fired.
- **[2026-08-12] - Official quest ambiguity decisions must be promoted immediately and route meaning must be preserved:**
  All 18 reviewed exceptions now have durable final verdicts: 28 approved
  outcomes add 184 deity cells, while `RelationshipMarriage` is duplicate-owned
  by `RelationshipMarriageWedding` and intentionally rowless. Shared physical
  terminals may be adapted only from directly evidenced stable state:
  `FreeformRiften02` uses its vanilla Lynly-friend global,
  `FreeformRiften03` uses its arrested global, and Staada uses possession of the
  unique Sheogorath-Shaped Amber. `Forgotten Names` and `A Good Death` use
  direct-player kills of unique actor bases; generic combat continues to own
  their ordinary kill semantics. Hearthfire home attacks credit
  `defend_kin_home`, not unproven or duplicate player kills. CW03 terminal
  milestones intentionally repeat `keep_oath` so long faction chains continue
  offering late-game piety. The same closeout parameterizes Blades/Brotherhood
  home restoration, Talos-worship persecution, and Nocturnal's stolen relic;
  assigns restitution, cultural-relic recovery, resistance to extortion,
  coercion, and enthrallment to explicit deity profiles; and corrects Vald's
  Debt to `settle_anothers_debt,recover_lost_keepsake,civic_service`. The focused
  `pdv_core_quest_ambiguity_route_check.mjs` gate owns these contracts. An owner
  approval must update the tagged slate and checkpoint in the same closeout;
  conversation-approved work must never remain documented as `UNREVIEWED`.
- **[2026-08-11] - JoJ B-series closes at 37/37; save-safe PatchHub testing follows release:**
  B07 Interesting NPCs closes the JoJ candidate set with 31 APPROVED and six SILENT
  verdicts. The complete PatchHub is released to testers as one dependency-gated FOMOD;
  runtime routing, player presentation, balance, and save/load observations are
  post-release evidence, not release gates, because these reaction-data patches do not
  interfere with current saves. Do not hold future complete PatchHub packages for
  per-option playthrough proof. Package bytes still require the exact installer-tree,
  archive-membership, and checksum receipt. Lighting, Mannaz, Sacrosanct, Wintersun
  removal, and generated world outputs are unrelated to the B-series content audit and
  must not be introduced as closeout spot checks.

- **[2026-08-10] - Follower friendship is not marriage, and Sheogorath's whimsy is not generic chaos:**
  B06 review removed `marriage_family` from Gore's Drunken Huntsman friendship milestone; ordinary
  growing closeness uses the owner-approved `friendship` profile (Mara close, Hist strong). Do not
  stretch `marriage_family` beyond its wed/adopt/reconcile/hearth contract.
  Owner-supplied gameplay context established that Merlin is recruited inside Sheogorath's domain,
  so the canonical vocabulary now includes narrow `embrace_whimsy`: freely welcoming an improbable
  or playfully impossible turn. Only Sheogorath currently reacts. Do not substitute
  `sow_chaos_madness` (which means spreading disorder/ruin and fans out broadly), and do not call the
  Merlin encounter `serve_a_daedra:sheogorath` because no bargain or task is evidenced. Merlin's
  untexted stage 255 remains a positional `RUNTIME-VERIFY` row; this is authored/machine-gated, not
  runtime proof. The same review ruled Redcap's captive-villager rescue as both `civic_service` and
  `defend_kin_home`: the player returns Redcap's Riekling people safely home.

- **[2026-08-07] - Daedric race-response family: destination ruled, wiring BACKLOGGED, do not re-wire:**
  `ShowRaceResponseForPlayer()` has **no organic call site anywhere in the mod** -- only
  `DebugRunControlledProof` -> `ShowControlledProofMessages` reaches it, in all 16
  `PDV_DaedricPath_*.psc`. Its single organic trigger was ever `PDV_DaedricPath_Hircine.psc:151`,
  which fired it on **werewolf curse entry**: the wrong event, a second blocking modal on top of the
  Nord curse handler's own, and a body that reads as nonsense there (it explains what closing the
  path costs, delivered before the player has taken it). That call was removed. The manifest's
  "One-time on a <race> committing" has therefore **never been true** -- the real commitment beat is
  `ShowCommitmentBeat()` from `PDV_DaedricPathBase.AddCommitmentSignal`, and the response was never
  attached to it. **Owner ruling: destination is a pinned Book of Days entry at commitment, NOT a
  second modal, and wiring waits for the next uplift because the copy is not shippable** -- 139 of
  155 bodies (90%) carry `--` in player-facing prose and 24 exceed the 280-char budget. The family is
  deliberately unreferenced outside debug; **do not propose the 155 records for removal and do not
  re-attach them to the curse transition.** Prior ruling + copy bar:
  `references/authoring/PDV_DaedricRaceResponse_Backlog_2026-08-07.md`. Keep the voice split when the
  copy pass happens: Response is Narrator (the mod telling the player what their own people make of
  the choice), while Commitment/ChampionEntry/Exit are God-voice.

- **[2026-08-07] - `Message.Show()` over an open MCM, reaffirmed the hard way; new modals must be queued:**
  The 2026-06-13 ruling below was re-broken the same day it was re-read. An inline
  `ShowNordMessage(...)` for the Nord/Kyne champion recognition fired from a tier crossing reachable
  by the MCM piety seed, so it displayed nothing **and set its one-shot key**, burning the beat
  permanently and making a correct record + correct VMAD binding look broken. **Standing rule: before
  writing any new `Message.Show()`, answer "can this path be reached from an MCM button?"** Debug
  piety seeds, curse forcing and focus forcing all run with the menu open, so most tier/state/curse
  surfaces qualify. Two sanctioned patterns: queue it and present from `OnUpdate` gated on
  `Utility.IsInMenuMode() == false` (`ProcessQueuedNordKyneChampionEntry`, mirroring
  `QueueDaedricMilestoneMcmReplay`), **stamping the one-shot when it PRESENTS, never when it queues**;
  or route to a toast as the curse handlers do via `suppressModal` on `mcm_force_*` reasons -- which
  is exactly why the curse messages survived this trap and the champion modal did not. A one-shot
  guard also needs a reset path, or it recreates the P10 "total silence on a re-climb" bug: the Kyne
  key now clears on demotion from Champion alongside the tier notice.

- **[2026-08-07] - Curse cure surfacing: the generic toast stands aside, but only where a race can replace it:**
  A Nord curing lycanthropy received three surfaces for one event -- the race line, Hircine's residue
  toast, and the generic `<Curse> is lifted` toast whose copy its own comment marks PLACEHOLDER.
  `SendPrismaCurseToast` now returns early on `phase == "cure"` when `_raceCurseSurfaceShown` is set
  by a race emitter. Implemented as a **flag, not a race list**, because cure records exist for only
  **4 of 10 races** (Nord, Argonian, Khajiit, Redguard); Bosmer, Breton, Dunmer, Imperial and Orc have
  **none declared at all**, so for them the generic toast is the only cure surface and must keep
  firing. Altmer is N/A by design. **`references/authoring/PDV_TransitionSurfacing_CoverageMap.md:97-99`
  over-claims cure coverage for six races** -- it records design intent, not shipped state, the same
  doc-over-claim found on the Nord werewolf cure earlier the same day.

- **[2026-08-07] - Dunmer ancestral spine is patron-INDEPENDENT and caps on the pulse:**
  `AwardDunmerAncestorSpinePulse` existed, awarded Azura's registered `SIGNAL_ANCESTOR_SPINE` (705),
  and was called by nothing, while the Orc (2209) and Redguard (2406) equivalents fire. Consequence
  was a real defect: a Dunmer praying at the portable urn got substrate progress but a Ledger driver
  **only** with an ACTIVE patron and **only** on the first prayer of the day, because
  `AwardActiveDunmerReclamationMemorySignal` was the sole curated signal on that path and carries both
  gates -- the empty Ledger `PDV_RunSheet_Dunmer_V1.md:184` calls "the key regression". **Owner
  ruling: it feeds the ANCESTRAL layer, so it fires on the first prayer of the devotional day
  regardless of patron.** That also dissolves the apparent conflict with the one-pulse-per-act comment
  at `PDV__ManagerQuest.psc:7876`, which governs the **home bonus** not stacking on the prayer: layer 1
  (ancestral, curse-silenced) and layer 2 (Reclamation, "routes regardless") were always separate
  lanes. The anti-farm cap lives **on the pulse**, not the call site, so a future second call site
  cannot reintroduce farming, and it reuses the `GetDevotionalDay() + 2` encoding.

- **[2026-08-07] - Offer-response mirrors are SUPERSEDED, not a regression; retire recommended:**
  The 18 `PDV_Msg_<Race>_OfferResponse_*` properties (six races, **not** 21 across seven) have zero
  consumers. The concern that authored copy was lost does not hold: each authored sentence was
  **split across two surfaces** -- opening clause to `BuildCommitmentOffer*ToastLine`, state clause
  and cooldown consequence to `BuildCommitmentOffer*JournalLine`. Verified per race in
  `references/authoring/PDV_OfferResponseMirrors_CopyVsBuiltLine_2026-08-07.md`. The only thing the
  mirrors would add is a blocking modal, which the mod has already answered the other way
  (toast + chronicle + diegetic cue). **Two things must not be retired with them:** "Not yet" has no
  surface anywhere (`NotYet` appears nowhere outside its six declarations -- no toast builder, no
  journal arm, no defer function), and FP-020 in `PDV_FinalPolishLook_Ledger.md:98` cites line anchors
  pointing at unrelated `PDV_Bless_*` properties while marking a never-seen surface done-on-live.

- **[2026-08-07] - Gates must assert the invariant, not a function name (`RefreshOpenBookOfDays` retired):**
  Carried as "an intended periodic refresh never wired into the tick loop". It was not:
  `PDV_MCM.psc` `OnKeyDown:1708-1719` already performs the identical journal-open reconciliation
  inline, at the only moment it is consumed, so the standalone function was a superseded duplicate and
  wiring it to a tick would have added periodic cost to re-check state reconciled for free. Three
  gates asserted on its **name**; `pdv_prisma_ui_audit` now asserts the behaviour against
  `PDV_MCM.psc` and the two list-needles in `pdv_book_of_days_audit` / `pdv_matrix_runtime_preflight`
  are dropped with a pointer to where the invariant moved.

- **[2026-08-07] - Dead-code adjudication records ROWS, not counts, and a delegated verdict is not a finding:**
  The morning pass recorded "still uncovered: 42 of 84 functions" but **no per-function table**, so
  nothing said which 42 and its row-level verdicts existed only in agent output. All **133** uncalled
  functions are now adjudicated by name. Main-loop re-checking against `tools/*.mjs` flipped **three**
  delegated verdicts, every one in the dangerous direction -- `GetNordAncestorSummary`
  (`pdv_verify.mjs:6228`), `GetImperialCivicLayerLabel` (`:6905`) and `RegisterGenericEffectList`
  (`:8847`) all sit in `checkSourceContains` must-be-present lists. Two verification traps recorded:
  a substring grep makes `DebugSeedBosmer` and `GetKhajiitLunarPostureLabel` look called (the hits are
  inside `DebugSeedBosmerVariety` / `GetKhajiitLunarPostureLabelAt`, and the longer sibling is the
  live one), and every `Record*` wrapper looks gate-named when those hits are all on its `*Scaled`
  sibling. Also corrected: the `AGENTS.md:1560` citation used to claim the Daedric Champion offer is
  "broken for all 16 Princes" does **not** support that -- see the 2026-06-13 entry below, which
  records the MESG + VMAD wiring as housecarl-verified correct.
- **[2026-08-07] - Pre-release GitHub issue reconciliation distinguishes implementation from runtime closure:** Issues #29-#32 were reviewed against current source and direct live ESP readback. Canonical slash aliases are normalized at matrix compile time; uninstall asks all seven substrate owners to clear their own boons; substrate ownership contracts now classify teardown-only manager references without creating a second runtime owner; optional skeleton arrays are null-guarded; Hircine/Molag stigma messages and Shor T3 presentation are wired in the live ESP. Azurah's Khajiit response remains deliberately absent because Azurah is native. Static gates and direct readback are green, but issue #30 remains runtime-open until an MCM uninstall smoke confirms substrate spells are removed. Issue #27 remains a future cross-race Azurah's Portent design review and is not a release defect.

- **[2026-08-07] - Altmer current scoring/display roster is five deities:**
  Auri-El, Magnus, Xarxes, Syrabane, and Trinimac are the current Altmer list.
  Mara, Stendarr, and Y'ffre are `FOREIGN` for Altmer and must not score, appear
  in the Altmer medallion, or enter Altmer Book of Days quest-reaction beats.
  Their broader-pantheon case is deferred to the future-update backlog and may
  only be restored deity-by-deity with the stance, runtime roster, medallion,
  reachability inventory, and Prisma gate updated together. Phynaster remains
  presentation-only and outside live scoring.

- **[2026-08-07] - Authoria combined packaging is superseded by the modular
  PatchHub:** `PDV_AuthoriaARR_Combined.esp`, its list-specific tree, and
  `PDV_QuestReactionMatrix_ARR.json` must not ship. ARR now consumes the same
  dependency-gated PatchHub as any other load order: 39 per-mod reaction
  channels plus independent AFDI and Daedric Shrines AIO options. Vanilla,
  DLC, and Creation Club reactions remain in core; PatchHub options may not
  replace core scripts or matrices. The 2026-08-06 95-member archive and the
  earlier combined-lane decision below are historical evidence only. Current
  filenames, hashes, exact contents, proof debt, and migration instructions are
  owned by `references/authoring/PDV_ModPackaging_StateAuthority.md`.

- **[2026-08-07] - ARR 2.5 preflight must inspect MO2 winners, not the named
  core-mod folder:** The combined candidate is installed and enabled on `KoK
  R11` as `Devotion - Authoria ARR Compatibility`, with reversible profile
  backups under `profiles\KoK R11\pdv-arr25-backups\20260807-070513`.
  houseCARL readback proved that ARR's `modlist.txt` serializes the
  higher-priority winner first: the compatibility mod must appear above both
  `Devotion - PatchHub` and `Devotion` for its scripts, matrices, KID, and ESP
  to win. `pdv_matrix_runtime_preflight.mjs` now resolves the winning provider
  through enabled-mod priority (plus overwrite), checks the optional channel
  count, and passes the deployed `154` core / `62` ARR / `34` channel contract
  at `31 PASS / 4 INFO / 0 FAIL`. This advances deployment/readback proof only;
  the current Papyrus log has no post-deployment registration markers, and all
  runtime-route, player-surface, semantic, and support proof remains open.

- **[2026-08-06] - ARR 2.5 content sweep is machine-complete but remains an
  experimental test candidate:** The finite scope is every enabled ARR 2.5 mod
  containing QUST plus the selected non-quest signature universe. Direct plugin
  enumeration, canonical inventory/reachability, T13-T17 channels, and package
  simulation are complete on `codex/arr25-content-sweep`; the cumulative archive
  is `dist/PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip` (95 entries, SHA-256
  `E11D7B2A90ED0F980DA2394CF63A465167E55730C252EF5FF1EF05A64D0B5C9D`).
  Non-quest rules locked by the pass: Potion KID classification uses exact item
  names because ALCH form filters target effects; AFDI is observed through its 30
  post-success latched globals with an existing-save no-credit baseline and
  once-ever persistence; Jyggalag stays classify-only; Wyrmstooth shrine refs do
  not inherit the ARR statue swaps because their base forms differ; and hunting
  remains deferred until the third-party animation script emits a truthful
  per-corpse-action event. Machine, readback, runtime-route, player-surface, and
  support proof remain separate. No ARR 2.5 option is supported until its full
  structured tester ledger passes.

- **[2026-08-03] - Khajiit road-home sleep uses sleep-start context and one presentation per devotional day:**
  `PDV_PlayerEvents` captures exterior status at `OnSleepStart` and carries it through
  `PDV_EventBus` to the manager at completed, non-interrupted `OnSleepStop`. The manager
  must not resample the wake cell: tent and bedroll sleep flows can move the player while
  waking. Missing start context fails closed. The first completed outdoor rest in each
  06:00 devotional day receives one toast and one Book of Days entry independently of
  whether another lunar practice already spent the shared `+4`; in that capped case the
  copy is `The road home was remembered. Today's lunar practice was already marked.`
  Later road-home rests in the same cycle create neither surface. Source/static gates,
  targeted Papyrus compile, Prisma policy, and live-source sync are complete; vanilla
  exterior-bedroll and Authoria Campfire-tent runtime/manual proof remain open. Papyrus
  review also locked the local rule to cache engine/cross-script values once per event and
  reuse already-loaded focus weights instead of repeating StorageUtil reads.

- **[2026-07-27] - Every value-modifying MGEF Devotion defines carries `Recover`; this is
  now a project-wide invariant, not a Daedric-family convention:**
  Devotion applies neglect, disfavor, pact-price, observance, and blessing effects as
  toggled abilities. Without `Recover` the engine bakes the actor-value change in and
  never reverts it on removal, so each on/off cycle shifts the stat further for the life
  of the save (two users reported `-22131%` Magic Resistance and `-5000` armour rating).
  The 1.0.3 sweep covered the ValueModifier family; DrHeisen then found two Redguard
  "Remembering" observances still drifting on the PeakValueModifier side, and 1.0.4 closed
  that. Shipped-ESP readback on 2026-07-27 is `627/627` - ValueModifier `395/395`,
  PeakValueModifier `232/232`. RULE: any new Devotion MGEF whose archetype modifies an
  actor value must carry `Recover` at authoring time; a missing flag is a save-corruption
  defect, not a tuning nit. This generalizes and supersedes the narrower 2026-07-26
  Daedric-price statement below, which remains correct about the rest of its serialization
  convention (`Detrimental` + `PowerAffectsMagnitude`, positive absolute magnitude on the
  carrier SPEL). Player-side residue already baked into an old save is NOT fixed by the
  flag; MCM -> Player -> Maintenance -> `Check stat damage` / `Repair stats` clears it.

- **[2026-07-27] - Devotion ships its own `TempleBlessingScript.pex`, and MO2 priority is
  now a hard install requirement:**
  Requiem's bugfix packs add a line to the shrine activation script that dispels ALL of the
  player's active magic effects. Under Requiem alone this is invisible, because Requiem's
  blessing lands immediately after. Devotion deliberately grants no shrine blessing, so in
  combination the player was left with pure loss. The fix is a corrected compiled
  `Scripts\TempleBlessingScript.pex` shipped in the Devotion mod folder. This AMENDS the
  earlier shrine-neutralization boundary (2026-06-14 / 2026-06-21 entries below, and
  `PDV_MOD_SETUP.md`), which stated that Devotion does not replace shrine activator
  scripts. The ESP-record half of that boundary still holds - Devotion still writes no
  shrine `ACTI` override and no script-property replacement; what changed is that Devotion
  now ships a loose-file `.pex` override of a vanilla script. CONSEQUENCE: **Devotion must
  sit BELOW (higher priority than) any Requiem bugfix pack in MO2**, or their copy wins and
  the bug returns silently. Nothing errors when this is wrong; the returning bug is the only
  symptom. Verify under MO2's Data tab: `Scripts\TempleBlessingScript.pex` must show
  `Devotion` as provider. Non-Requiem players were never affected - base Skyrim's script
  does not dispel; the only visible change for them is that the two vanilla
  "blessing removed / blessing received" pop-ups no longer appear, both of which described
  something Devotion prevents anyway.

- **[2026-07-27] - Green Pact mod-added food is distributed by KID, matched by NAME:**
  The Bosmer Green Pact meat reward path existed but had no food attached, so nothing a
  Bosmer ate could satisfy it. Vanilla and DLC meats (22 of them) are the static record
  set; mod-added food goes through `SKSE/Plugins/KeywordItemDistributor/PDV_GreenPact_KID.ini`,
  NOT through the FormList. RULE: those KID rules match by item NAME, not FormID or
  EditorID - a FormID/EditorID rule silently distributes nothing across the variant
  plugins players actually run (Requiem's Torn Flesh renames to Strange Meat without Food
  and Beverages Redone, and the Requiem meats are re-defined per list). Eating plants
  remains the pact violation, unchanged, and the existing daily cap applies to the meat
  reward so it cannot be farmed. Because it is keyword-distributed, the Requiem lane costs
  nothing and does nothing for players who do not run Requiem.

- **[2026-07-27] - A houseCARL read is only evidence once the MO2 instance is confirmed:**
  During this doc sync a routine readback of the shipped ESP reported that only `4` of
  `422` ValueModifier MGEFs carried `Recover` - i.e. that 1.0.4's flagship save-damage fix
  had never shipped. It was false. houseCARL was still pointed at
  `D:\Wabbajack\modlists\ARR` (profile `R11 KoK`) from earlier compatibility work, and was
  reading THAT instance's older 2026-07-23 `Devotion.esp`, a genuinely different file
  (`646823` bytes vs the shipped `637626`). After
  `housecarl_set_mo2_instance D:\Wabbajack\modlists\Anvil` the same query returned
  `395/395`. RULE: before any readback that will become a status claim, confirm the active
  instance with `housecarl_load_order_status` - the failure mode is a plausible,
  internally-consistent, catastrophic-looking answer, not an error. See the
  `compat-reference-instances` memory.

- **[2026-07-26] - Daedric penalties use semantic-negative authority and engine-positive serialization:**
  Every `PDV_Price_Daedric_*` contract effect keeps a negative magnitude because
  that value describes the player-facing penalty. The corresponding live MGEF
  carries exactly `Recover, Detrimental, NoDuration, NoArea,
  PowerAffectsMagnitude, NoHitEffect`, and the matching SPEL stores the positive
  absolute magnitude. Azura Seeker established the convention in game after
  the Redguard Forebear reward was separated from the price baseline; the same
  serialization was then applied to all 48 tiers. Direct houseCARL readback is
  family-wide; representative runtime proof now covers all three Azura Stamina
  tiers and all three Mephala Speech tiers with exact Lapse restoration. The
  distinct Hermaeus Mora Champion two-effect boon and price also passed. The
  generator and standard verifier own the regression guard; the other 39 tiers
  remain readback-proven rather than individually manually tested.

- **[2026-07-26] - Quest-reaction runtime failure triggers save-compatible ingress compaction:**
  The fresh 1.0.4 controlled sweep completed MQ101/MQ105/MQ106/MQ206 in exact
  FIFO order, produced four matching Book of Days entries, and had no overflow,
  broad-scope abort, stack dump, or PDV-attributable error. It did not meet the
  two-second target: START-to-COMPLETE timings were approximately 11, 5, 5, and
  5 seconds. The paired `VM is freezing` -> revert/load -> `VM is thawing`
  sequence was normal save-load lifecycle, not a queue failure. Per the
  ship-optimization gate, new jobs now resolve reachability and zero-value rows
  at ingress, persist only runnable base/meta rows, record source/skipped/meta
  counts plus ingress-build time, and retain the exact two-reaction/0.1-second
  worker bound. Saved jobs without the additive `Compacted` key keep the legacy
  worker-side cheap-skip path; no script, property, or existing persistent
  variable was renamed or removed. Manager then MCM compiled 0 errors/0
  warnings; `pdv_verify` passed 4119 checks with the one pre-existing generic
  faucet TODO, and quest/static/Prisma/Book/ASCII gates passed. Post-compaction
  fresh-process latency and organic MQ106 remain open, so this is a committed
  implementation checkpoint rather than runtime-complete proof.

- **[2026-07-15] - Main quest is a full-pantheon authored lane, not sparse keyword coverage:**
  The Helgen-to-Alduin contract is 45 runtime deity identities across 25 exact stages on
  19 quest records: 1125 unique cells, with no approved silences. Tranche 11 contributes
  951 cells; the canonical matrix is 1978 cells / 172 keys / 134 watched quests / 26
  faucets. `MQPaarthurnax` stays outside the stage matrix because spare has no reliable
  completion stage; its existing fork owns exact 17-kill and 11-spare reaction rosters.
  The 134-watch loader must use indexed `JsonUtil.StringListCount`/`StringListGet`, never
  a materialized Papyrus array. Static/generated-readback authority is
  `PDV_MainQuestFullCoverageContract.json` plus
  `pdv_main_quest_full_coverage_audit.mjs`; it also requires an explicit producer symbol and
  rendered Prisma glyph for all 45 identities, so no expanded main-quest toast silently
  falls back to the journal icon. Fresh route, Book of Days, toast, actual overlay rendering,
  alias, latch, and feel evidence remain a separate in-game proof bucket. The 1.0 rollup consumes
  that bucket through `C-MAIN-QUEST-FULL-COVERAGE-RUNTIME` and the five
  `mainQuestFullCoverageRuntime` slots; pre-T11 Paarthurnax waivers cannot close the
  expanded 17/11 proof.

- **[2026-07-15] - T11 main-quest smoke never advances vanilla stages from QASmoke:**
  `MQ106` stage 200 is a vanilla shutdown stage; forcing it on an out-of-context
  QASmoke save froze the VM before PDV emitted a route marker. The Signal-floor MCM
  harness therefore owns safe controlled cards for MQ101 150, MQ105 160, MQ106 200,
  and the existing MQ206 220. They resolve the real quest form and call
  `ApplyQuestReaction` directly, proving manager/Prisma/Book of Days behavior without
  changing vanilla quest state. They do not prove `PDV_PlayerEvents.OnQuestStageChange`
  delivery; organic route proof remains a separate required bucket.

- **[2026-07-15] — Broad-band vocabulary applies to every broad-lane blessing family:** The
  ratified `Distant/Observant/Faithful` public bands (BroadPantheonContracts
  `playerFacingBands`) govern ALL broad-lane reward records, not only the three pool
  families — including Dunmer Reclamation (its `tierCap: Devoted` spec exception is
  revoked) and the retired Argonian Hist records on paper. Rationale: the Reclamation
  grant gate is unambiguously broad (`PATRON_STATE_BROAD`, caps at 50); a lone "Devoted"
  on a lane with no Champion rung tells a maxed player they are mid-ladder. Executed
  2026-07-15: six ESP renames (Bosmer/Breton/Orc/Redguard broad T1 "- Seeker" ->
  "- Observant"; Dunmer T1 -> "- Observant", T2 -> "- Faithful") with houseCARL readback
  proof + six spec realignments. Gate gap noted: no audit yet validates SPEL tier words
  against the bands (the naming audit covers child MGEFs only).
- **[2026-07-15] — Curated signals feeding broad pools is INTENDED; the guard is trigger
  rarity:** `AwardPietyInternal` auto-opening a broad-pantheon scope (so any curated award
  on a pool-eligible deity feeds the pool's strongest-delta-per-event) matches the pool
  contracts' own wording and stays. Rationale: award-path surgery would change behavior for
  all 86 wired signals. Consequence: a curated signal on a pool-eligible deity may only
  wire with a genuinely RARE detector — `Tsun.SIGNAL_ADVERSITY_SURVIVED` must key on
  near-fatal reversal, not ordinary hard fights.
- **[2026-07-15] — Talos protect-worshipper favor is wireable via authored rescue routes:**
  The `PDV_TargetEndStates_1.0.md` "never generic rebellion or plain anti-Thalmor violence"
  rule OVERSTATED the design: rescuing/protecting a Talos worshipper counts as authored
  faithful defiance even when Thalmor die in the doing; plain Thalmor-killing still earns
  nothing. `Talos.SIGNAL_PROTECT_WORSHIPPER` wires via quest-stage rescue beats (e.g. MS08
  routes exist; MS09-class rescue stages), one-shot latched. TargetEndStates wording amended
  same day.
- **[2026-07-15] — Malacath/Tu'whacca/Azura deity pulses from substrate-adjacent contexts
  are AUTHENTIC god lanes, not unfinished pantheon parity:** Orc life-mode, Ash'abah
  named-undead burden, and Dunmer twilight-window pulses are act-specific and theologically
  owned — unlike the four converted passive spines (Nord/Imperial/Altmer/Breton). Ratified
  so no future session "finishes" the parity by converting them. Rationale: the parity
  ruling was about passive daily credit inventing deity piety; these three fire on
  deliberate acts through their gods' own lanes.
- **[2026-07-15] — Khajiit Champion signature moments are POST-1.0 (owner correction):**
  The four stat-only capstone moments (Khenarthi wind-speed, Azurah spell-ward, Rajhin
  shadow-slip, Alkosh dragon-stagger) were mis-recorded as "defer to a design session";
  the owner's ruling is post-1.0 by design — now entered in `PDV_V2_Backlog.md` and OFF
  the 1.0 issue list. Guides already de-promise them, so V1 copy is honest; Baan Dar's
  shipped cheat-death holds Khajiit's one-save-per-race slot, so the V2 designs must be
  non-save mechanics. The remaining 1.0 issue candidates are only the two pre-existing
  stale-gate-contract items (14 spine-source verify contracts; remap-adversary Breton
  hidden-art-champion assert).
- **[2026-07-15] — True-bug fix pass EXECUTED (scoped ManagerQuest pass + records + gate descope):**
  All phases of `PDV_HO_ScopedManagerPass_2026-07-15.md` landed in one session. Records:
  Akatosh's Endurance re-authored (Maximum Health +30 + Magic Resist +15) at Imperial AND
  Breton layers (was a Julianos duplicate at both); HearthHeld converted to flat Fortify
  Stamina +15. Papyrus (compile 0/0, MCM refreshed): 21 signal cuts (phrase->branch->const,
  DELTA floats retained for save safety), 8 wires (Tu'whacca re-entry on first mortal sect
  act; Magnus/Xarxes active-patron heritage-memory dawn pulse; Trinimac orthodox pressure;
  Leki duel + Tsun near-fatal adversity via combat sessions widened to Nord(0)/Redguard(9);
  Talos protect-worshipper via MS09 s201 rescue; Malacath exile-return latch), Altmer
  crisis exit (3 rite-evidence-days -> REASSERTING -> 2-day lockout -> SCARRED_RESOLVED at
  dawn; 7-day heterodox acceptance below alignment 0), Orc stronghold forge routed from
  Story Manager craft, +2 once/day orthodox-rite alignment mover (dead +15/+20 keys
  deleted), medallion tier labels to canon (Seeker/Distant). Gates: dispatch coverage
  102/94/8/8 PASS (ledger holds only the 8 wire-later entries); naming audit PASS; strict
  Phase 18 34->14 via the approved dialogue descope (assert-ABSENT posture in pdv_verify +
  manifest status v1-removed-voiced-v2). KNOWN PRE-EXISTING (stash-proven on pristine
  main, NOT this pass): 14 stale spine-source verify contracts (DESCOPED same day with
  owner sign-off — checkSourceLacks absence-guards; strict gate 0 FAIL / 4142 PASS) +
  the remap adversary breton-hidden-art-champion assert (still owed a
  stale-assert-vs-real-gap verdict). Guides:
  Leki/Malacath/Talos beats restored, boon tables respliced, BBCode gate clean; the
  tables tool's Observant/Faithful "retired-word" lint retired (inverted by the band
  ratification). Runtime proof owed: RC1 + RC7-RC15 (co-test runbook).
- **[2026-07-15] — Nord Phase 18 dialogue quartet reclassified: V1 removal, not debt:**
  The four absent Froki/Heimskr/Andurs/Aela chains (20 strict Phase 18/Nord failures)
  are the PLANNED V1 build action from `PDV_V2_Backlog.md` ("First V2 step is actually a
  V1 removal... Re-add voiced in V2"), owner-confirmed — the 07-14 "pre-existing debt"
  classification below is superseded. The real defect is stale gate expectations:
  `pdv_verify.mjs` `PHASE18_NORD_DIALOGUE_CONTRACTS` still asserts the removed records.
  Descoping those contracts to V2-expected-absent is queued in the fix plan as a rule-5
  toolchain edit; **owner sign-off GRANTED 2026-07-15** (execute in fix-pass P3 with
  before/after strict-gate proof). Rationale: a strict gate asserting deliberately
  removed content trains people to ignore red gates. Same-day rulings: Akatosh's
  Endurance re-authors to Fortify Health +30 + Magic Resist +15 at both Imperial and
  Breton layers (Julianos's Insight keeps the Magicka block); GitHub issue filing is
  HELD until after the fix pass lands (Part D D3 stays the internal tracker).
- **[2026-07-15] — Reserved-signal ledger disposition (37 = 21 cut / 8 wire-now / 8
  wire-later):** Every `tools/pdv_reserved_signals.json` entry now carries
  decision/owner/expires per PDV_STANDARDS 5.2. Cuts and near-term wires belong to the
  scoped ManagerQuest pass; Syrabane's five stay reserved for the BC-0153 beta warding
  lane; Stuhn's two for the pantheon-parity focusable-patron build; Trinimac orthodoxy for
  the Orthodox Champion lane. Leki/Malacath wires were owner-ruled KEPT despite the
  Nexus-final guide cutting their copy — restore the copy when the wires land.
- **[2026-07-15] - PS-A11 broad catch-up uses an explicit synthetic target, never `GameDaysPassed`:**
  `PDV__ManagerQuest.GetDevotionalDay()` derives from `Utility.GetCurrentGameTime()`, so setting the
  console global `GameDaysPassed` cannot exercise broad-pool dawn or catch-up behavior. The old PS-A11
  instruction therefore produced no test signal, not a decay failure. The Pacing MCM now exposes the
  throwaway-save-only `PS-A11 catch-up` control. It requires a real folded positive gain, zero pending
  scratch, and a suppressed selected pool, then calls the production
  `ProcessBroadPantheonThroughDay(...)` through `lastGainDay + 5` without changing Skyrim time. This
  yields exactly two grace days followed by three `-0.1` ticks (for example, `2.64 -> 2.34`) and records
  `[PDV][PS-A11]`; repeating the same target is idempotent. The broad-pantheon audit statically guards
  the manager preconditions, production call, and MCM surface. Source/compile/verifier proof is clean;
  PS-A11 runtime and save/load evidence remains open.

- **[2026-07-15] - PS-A1 reserved-zero/first-dawn co-test closed:** The tester
  confirmed the remaining reserved-zero day-0, first-dawn, and save/load sequence
  passed. The zero-activity dawn was intentionally silent: with no accepted event
  and no pending scratch, no toast or Book of Days digest is expected. The first
  Papyrus inspection was discarded because it targeted the wrong rotated log path;
  the retained evidence record distinguishes that tester confirmation from the
  independently retained DBDestroy duplicate-suppression trace. The structured
  runtime ledger now has all twelve PS-A cards PASS with zero open required buckets.

- **[2026-07-15] - Ledger-authority consolidation: regenerable reports leave git:** Ratified four
  artifact classes (PDV_STANDARDS.md section 5.3): hand-authored authorities, evidence stores, and
  machine-read pipeline state stay committed; regenerable pure-report ledgers are gitignored and
  regenerated on demand. De-committed 24 files: EndStateBurndown md+json, SignalFloorSmoke md+json,
  SpeccedMinus, SpineStackScore, AntiFarmSweep, EligibilityRewardCoverage, RewardRuntimeOrderLint,
  IntegrityHarness, LedgerCoverage, CompletenessGap md+csv, plus the generated md twins of
  SignalE2EGate, SignalFloor, P2FormListEsp, FeltTrace (and its csv), PacingSim, and FinalPlacement.
  Verified before the de-commit: none is an EndStateContract freshness source or read-mode ledger;
  the signal trio reads only the committed CSVs; signal_e2e_gate consumes the completeness audit via
  --json stdout and suppresses its md/csv writes; endstate gate counts (PASS=2 STALE=1 RED=18) and
  signal-trio exit codes matched the pre-change baseline after untracking. Authority phrasing is now
  "the contract plus a fresh gate run", never a committed rendering. Files stay on disk locally; a
  fresh clone regenerates each by running its tool. Rule forward: a file named in contract
  freshness.sources or evidence.read must be committed; a new pure-report tool adds its .gitignore
  line in the same commit that adds the tool. (Ledger-authority consolidation, 2026-07-15)
- **[2026-07-15] - Explicit P2 book reads and ambient progress have separate
  presentation/scope contracts:** `SurfaceP2BookReadNotice` validates real
  `po3_book` provenance and bypasses setup-quiet presentation so its toast and
  Book of Days acknowledgement cannot be lost; `SurfaceP2AmbientProgressNotice`
  is reserved for the Altmer/Breton sleep paths and remains quiet during setup.
  Nested book, harvest, and quest-stage receivers now carry the root Logical
  Devotional Act identity into P2, generic action, likes/dislikes, and
  quest-reaction work, joining only an exact match. This prevents the normal
  self-deadlock that produced `BROAD_SCOPE_ABORT` without weakening the guard
  against truly concurrent event stacks. `pdv_prisma_ui_audit.mjs` and
  `pdv_broad_pantheon_audit.mjs` enforce the two contracts; runtime/manual
  proof remains required. Follow-up Breton runtime diagnosis found that the
  Hidden Art handler incorrectly gated an approved book acknowledgement on
  daily `practiceAwarded`; a mechanical cap must never suppress that book's
  toast/Book-of-Days record. `pdv_prisma_ui_audit.mjs` now rejects that coupling
  and `pdv_phase20_runtime_check.mjs --track p2-books --race breton
  --strict-manager` requires all three distinct Breton acknowledgement traces.
  The 2026-07-15 fresh Breton retest passed those markers plus three visual
  toasts/Book-of-Days entries with no broad-scope abort or mismatch. The
  cap-dependent `Breton tradition choice routed` trace is not an assertion:
  it is not emitted after a full practice cap. The same-day Imperial regression
  then passed the former nested book and quest collision shapes: `The Talos
  Mistake` produced its two distinct-lane notices, MQ103 stage 190 produced
  civic-service plus combined quest-reaction acknowledgement, and the fresh
  log has `RouteImperialTalosPressure complete: 141`,
  `RouteImperialCivicService complete: 140`, and `RouteQuestReaction complete:
  stage 190` with neither broad-scope marker. Re-reading the Talos book logs
  both generic and P2 source repeat suppression and produces no presentation;
  book credit is once per source per save. The same interface then passed a
  three-book Altmer regression: Auri-El, Magnus, and Xarxes each logged their
  exact P2 route and book-notice trace and each rendered a toast plus Book of
  Days acknowledgement. Two generic-book-lane toasts also appeared and are
  accepted as separate player actions, not duplicate P2 acknowledgement. A
  controlled standalone MCM root (`MQ302 300`) then produced one combined
  acknowledgement and logged four applied reaction cells with no scope marker.
  After returning to broad worship and resetting the Imperial pool, that root
   awarded Mara, Stendarr, and Akatosh `+4` each; the live pool readout showed
  `active=TRUE`, `scratch=4.000000`, and `lastEvent=quest_284963|300`. This
  proves strongest-positive aggregation for the scoped regression, not overall
  beta readiness.

- **[2026-07-15] - Altmer presentation is milestone-first, with Auri-El rather
  than vague order language:** Approved Altmer P2 sacred books now reserve the
  player-facing moment for one specific toast and one Book of Days entry. The
  generic lore fan-out still applies its mechanics but does not compete for a
  second surface; the Trinimac reserved-signal surface also stays silent on a
  P2 book. If the third disciplined reading resolves the crisis, the
  state-transition toast/chronicle replaces the ordinary book notice. Ordinary
  heritage progress is quiet; only a heritage tier crossing adds the concise
  Book of Days line. Crisis text names `Auri-El's path` (shaken, returned to,
  or holding) and heritage prose names `ancestral inheritance`; `Ordered
  Heritage` remains only the mechanical tier label. The shared substrate
  renderer now uses neutral grammar so it cannot produce malformed plural or
  possessive copy. Proof moved only through source/live sync, two 0/0 Papyrus
  compiles, and the 121-check Prisma UI audit. Fresh in-game observation of
  this revised presentation remains open; it does not invalidate earlier route
  proof.

- **Khajiit lunar and Champion rebalance implemented (2026-08-06 AEST; runtime/manual proof open):** Khajiit now use exclusive substrate packages `Disease +5` at 1-24, `Stamina +10 / Disease +10` at 25-74, and `Stamina +15 / Disease +15` at 75+, with Lunar Attunement's Magicka removed. Focus emerges automatically at `25` weight, `15` lead, and actual Seeker piety; the first emergence owns one ceremonial MessageBox, Prisma toast, and pinned Book entry, while later qualifying leaders reorient without another popup and ties/piety loss do not erase focus. The eight god-strength slots remain `Alkosh, Azurah, Khenarthi, Rajhin, Rajhin, Baan Dar, Khenarthi, Azurah`; rotating stat spells and the `+10%` piety multiplier are retired. Lattice Resonance uses one keyworded 1.20x perk over the fifteen focused numeric spells, with a separate marker and scheduled game-time boundary reconciliation. The 56-line JSON observation packet provides ten lines per god plus six shared lines, uniform selection, resolved-ID no-repeat, and compiled fallback. Azurah Champion owns the once-per-06:00-day native conditioned Portent detection power; Baan Dar's rescue now has a dedicated final Champion/origin/focus/T3 guard and restores to 50% Health. Direct houseCARL record IDs and proof are recorded in the current Khajiit specs; `PDV_KhajiitPapyrusOptimization_2026-08-06.md`, the five-deity signal decision packet, and the in-game runbook hold the remaining proof and follow-up boundaries.

- **[2026-08-13] - Ground-up V3 starts with a clean-break Quest Reaction deep module:** V3 rebuild work starts from current `main`, remains new-game-only, and keeps the 1.5 line available for existing saves. Slice 1 preserves timing, values, ordering, copy, and exactly-one final surface while ownership moves into one `PDV_QuestReactionRuntime` hosted on the existing worker quest. The runtime owns catalog resolution, source activation, duplicate suppression, persisted FIFO delivery, scheduling, and compatibility status behind a versioned quest-stage/semantic-event interface. Official third-party data compiles into one auto-installed delta catalog with fully-qualified `pluginName|localFormId|stage` identity; only the five real plugin/script adapters remain dependency-detected installer options. `PDV_ReleasePayload.manifest.json` is now the single compile inventory authority. Rationale: the slice exercises the full architecture and compatibility chain without adding per-mod Papyrus, 80 runtime modules, another scheduler, or third-party masters to core.

- **[2026-08-14] - Quest reactions obey selected theological lanes and retain one logical presentation identity:** Automatic Nord quest reactions are eligible against the selected Old Ways or Nine Divines baseline, not the dashboard's union roster, with the same policy enforced at ingress and immediately before award. Authored taboo/hostile displeasure, Daedric paths, and grandfathered active patrons retain explicit exceptions. Queue-finalized toasts carry the qualified reaction key as correlation so exact duplicate delivery can be suppressed without merging distinct completed jobs. One persisted armed update chain owns resume, checkpoints every applied cell, and lets a saved active slice finish before re-arming. A logical deed lists each deity once; the Book arrow/rune, never repeated prose, carries higher piety magnitude. Rationale: the first Slice 1B canaries exposed selected-lane leakage, ambiguous toast cardinality, and repeated deity names after mid-job reload. Corrected runs proved FIFO completion after resume, four UI renders and visible toasts, duplicate-free Book entries, and distinct Old Ways/Nine Divines runtime shapes plus the expected manual deity inclusion/exclusion without adding another scheduler, queue, or dependency.

- **[2026-08-15] - Quest Reaction admission is scope-isolated and scheduler-materialized:** PlayerEvents closes and flushes the ordinary quest broad scope before submitting Quest Reaction. Runtime persists a lightweight qualified job header and returns; its existing single scheduler then materializes catalog source/meta cells through persisted cursors at the shared two-work-item tick budget before application begins. Rationale: fresh Before the Storm proof measured `7469.970703` ms of synchronous cell materialization inside `OnQuestStageChange`, allowing MQ103 stage 10 to replace the still-open MQ102 broad scope and trigger `BROAD_SCOPE_ABORT`. The fix keeps the five-method interface, one scheduler, 0.1-second rearm, FIFO, queue bound, scoring semantics, and one final surface unchanged. Static audits and targeted compilation pass. A corrected organic run admitted in 45 ms; a clean sweep saved at `build=8/45`, resumed with four pending jobs, and drained four FIFO BUILD/START/COMPLETE chains without a safety failure. The tester confirmed four visible toasts and four correct duplicate-free Book entries. The bounded-ingress fix is fully smoke-proven; broader Slice 1 compatibility and Authoria acceptance remain separate.

- **[2026-08-15] - Non-presented generic actions never own shared broad scope across roster fan-out:** Discover-location event `345` exposed a separate concurrency defect after the bounded QR smoke: EventBus kept the Manager's temporary broad accumulator open while scoring the whole deity roster, so a nearby quest event could hit the two-second stale-owner guard and discard `likes_dislikes_345`. Non-presented actions now aggregate eligible applied deltas in caller-local variables and commit one result directly through the Manager without opening, waiting on, or clearing shared scope. Presented event `303`/`366`, shrine/shout, ordinary quest, and persisted QR transaction contracts remain unchanged. Event reason lookup is cached once per action. Static regression gates plus isolated and synced live compilation of Manager/EventBus/ActionRouter pass; `pdv_quest_reaction_runtime_check.mjs` then passed the Anvil overlap run without `BROAD_SCOPE_ABORT`, and the tester confirmed both final player surfaces. No separate numeric broad-standing before/after readout was recorded, so exact strongest-positive/most-severe-negative selection remains deterministic-model proof rather than a manual numeric claim. Full Authoria acceptance is intentionally delayed until the assembled V3 core plus generated compatibility installer can be tested as one load-order/dependency/sentinel surface.

- **[2026-08-15] - Quest Reaction public-source sanitation is an architecture-gate invariant:** A sibling broad-scope branch was deployed before the already-reviewed Bethesda-master source sanitizer had merged, so the new Book entry again exposed `Skyrim.esm`. The shared Manager fix still correctly preserves qualified master identity for diagnostics while clearing the five official master names only from toast and Book source labels. To prevent branch composition from silently removing it again, `pdv_quest_reaction_performance_audit.mjs` now checks all positive, negative, and mixed final-surface calls and carries adversarial mutations for both sanitizer removal and a Book-only raw-source bypass. Keep optional integration attribution visible. This moves static regression proof only; the owner elected to carry prior player-surface proof forward without another presentation-only retest.

- **[2026-08-17] - Combined Anvil acceptance closes the core Quest Reaction runtime lane, not compatibility support:** The assembled V3 core and official catalog passed a fresh four-job FIFO/player-surface sweep, non-empty-queue save/load `RESUME`, and organic MQ102 stage 160 on Anvil `Devotion Dev`, with no queue safety marker. The roughly 31-second sweep drain is retained as a non-blocking bounded-throughput tuning observation. Authoria remains required for real FOMOD dependency detection, source/sentinel activation, the five adapters, and support claims. Rationale: runtime-route, player-surface, save/load, package-integrity, and mod-manager/support proof are separate buckets; a green Anvil core lane cannot substitute for the final compatibility environment.

- **[2026-08-17] - Not-save-safe Part A removal is propagated to its audits and contracts, not just the manager:** The owner-authorized not-save-safe migration sweep (`references/authoring/PDV_NotSaveSafe_MigrationSweep_Plan.md`, shipped in #79 incl. `39fb7aa4`/`af7e668e`) removed the pure-legacy save migrations from the manager but left three gates enforcing the old design, so `feature/v3-big-update` failed its own `pdv_verify` on `Broad pantheon contract` (12) and `Substrate pacing contract` (1, Khajiit). These were proven stale contracts, not manager regressions or live-vs-branch drift (the live MO2 manager is byte-identical to the branch mirror). Reconciled `pdv_broad_pantheon_audit.mjs` + `PDV_BroadPantheonContracts.json` and the Khajiit `source.khajiit-moon-power-slot` probe in `pdv_substrate_pacing_audit.mjs`: six obsolete migration assertions deleted, and the frozen-counter, relocated broad-event, and Observe-the-Moons invariants RE-ANCHORED (not deleted) to their post-refactor homes (`ApplyBroadPantheonEventResult`, `AwardPietyInternal`, `EnsureKhajiitObserveMoonsPower` grant/remove) so each still fails if the invariant is absent. Both audits re-run green (exit 0); no relocated invariant weakened. The full `pdv_verify` exit-0 (which also reads the live MO2 install) was NOT re-confirmed this pass — the MO2 MCP server was down. Deferred + filed to `handoff/PDV_NotSaveSafe_MigrationSweep_Handoff_2026-08-17.md`: the Part B live removals (`RepairBookOfDaysJournalText`, the `AncestorSpine_T1` strip — keep the reward spell), plus the coupled `pdv_prisma_ui_audit` pin and `PDV_SubstratePacingContracts.json` migration language, all needing manager edits + compile. Rationale: a removal not propagated to its contract reads as a regression; a gate re-anchored by deletion would silently drop a live invariant.

- **[2026-08-21] - Copy uplift and refined KID filtering live on a 2.0 descendant, with owner prose kept as data:** `fix/2.0-copy-uplift` is rooted at the current `feature/v3-big-update` integration tip. It carries the narrower SunHelm water exclusion and the already-disabled Hircine/Zenithar KID lanes, plus the read-only copy census and Nord/Kyne workbench. Approved commitment headings/bodies live in versioned `PDV_CommitmentOfferCopy.json`; 2.0 translates the choice state into `PDV_DevotionLedger` and the refusal/deferral action into `PDV_DebugRuntime` rather than restoring those bodies to the manager. Repository-source compilation passed for Ledger, DebugRuntime, and Manager with zero warnings; census tests, deterministic regeneration, and the formal-offer source gate passed. This is static/build proof only. The new `PDV_GLO_CommitmentNotYetAvailable` ledger property still needs direct plugin wiring/readback, followed by live-source compilation and in-game presentation/save-load proof. Durable rule: when working copy changes cross the 2.0 extraction boundary, replay behavior into the owning deep module instead of copying an older manager body.

### Archived decisions

Older entries are archived in `archive/PDV_DecisionsLog_Archive_2026-05_2026-07.md`
(the 182 closed 2026-05 to 2026-07 decisions rolled out of this section, with a
full dated index), and in `archive/PDV_DecisionsLog_Archive_2026-05.md`,
which carries a full dated index. Archived coverage: foundational
architecture/toolchain decisions, closed Phase 1-9 proofs, V3
preflight/slices/Phase 7 closeout, the race-architecture implementation-lock
pass, Daedric and contextual-favor design locks, Prisma UI scaffolding, lessons
intake, and the 2026-05-11 -> 2026-05-16 session notes. Live invariants from
those entries are restated under Architecture Summary / Naming Conventions;
active process rules under Standing Rules above.

**Rolling-window convention:** keep the current phase arc here in full. At
doc-sync time, roll entries for fully-closed phases that predate the active arc
into the dated archive (leaving the title+date in the archive index), and
promote any still-active rule into Standing Rules rather than archiving it
silently. Start a new dated archive file per month when the current one grows
large.
