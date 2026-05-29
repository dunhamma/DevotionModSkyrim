# AGENTS.md ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â PlayerDevotion (PDV) Mod Project

## What This Project Is

A Skyrim Special Edition (SSE) mod called **PlayerDevotion** that tracks the player's religious devotion based on their race's authentic theological traditions. The system reads the player's daily behavior and adjusts per-deity piety, which then gates tiered blessings, neglect effects, and patron-specific content.

The mod is designed for roleplayers who want mechanically meaningful, lore-accurate religious practice ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â not generic shrine-visiting bonuses.

---

## Agent skills

### Issue tracker

Issues for this repo live in GitHub Issues for `dunhamma/DevotionModSkyrim`. See `docs/agents/issue-tracker.md`.

### Triage labels

This repo uses the default Matt Pocock engineering-skill triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This repo should be treated as a single-context project; skills should read the repo-level context and architecture docs relevant to the task. See `docs/agents/domain.md`.

---

## Project File Map

| File | Role | Use When |
|------|------|----------|
| `AGENTS.md` | This file ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â project context, build status, decisions log | Context for Codex across sessions |
| `PDV_STANDARDS.md` | Operating rules: doc hygiene, description discipline, investigation/safety rules | **Read at session start.** Re-read ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ 1 + ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ 4 when in doubt |
| `PDV_MOD_SETUP.md` | Dev environment, architecture, build order, variable reference | Setting up tooling, debugging, tracking decisions |
| `tools/pdv_compile.mjs` | Node wrapper for the verified PapyrusCompiler import chain | Compiling stale/all/targeted PDV `.psc` files into the Devotion MO2 mod |
| `tools/pdv_verify.mjs` | Read-only Node/Mutagen verifier for PDV's Anvil MO2 setup | Checking CK wiring, script freshness, SEQ state, MO2 profile state, and strict phase-gate readiness |
| `tools/pdv_mcp_check.mjs` | MCP server health check — pings the Anvil MO2 MCP server and validates the active profile is `Devotion Dev` | Confirming the server is live and on the right profile before any `mo2_*` tool use; surfaces ECONNREFUSED with actionable startup instructions |
| `tools/pdv_papyrus_lookup.mjs` | BellCube-backed Papyrus lookup helper for Skyrim SE script/function pages | Looking up Papyrus signatures, script pages, and likely function locations on `papyrus.bellcube.dev` before guessing at API surfaces |
| `tools/skyui_compile_shim/*.psc` | Minimal compile-only SkyUI base-class shims used by `pdv_compile.mjs` | Compiling `PDV_MCM.psc` without inheriting noisy third-party MCM source overrides |
| `tools/pdv_author.mjs` | Safe overlay-patch authoring helper built on the local Mutagen bridge | Inspecting existing-record wiring, planning reversible ESP overlay patches, and scripting supported VMAD/FormList edits without mutating the framework ESP in place |
| `tools/creation-authoring` / `C:\Users\Admin\Documents\ckra-native` | Project-agnostic CKPE authoring bridge and proof-ledger workbench | Proving generated-plugin CK record creation paths before any source-plugin promotion; use the generic dialogue-v1 fixture for future CK-authored dialogue manifest/readback proof, while strict product support remains limited to proof-ledger-promoted capabilities |
| `tools/pdv-phase9-author` | Narrow Mutagen-backed Phase 9 framework authoring helper | Reapplying or auditing the direct framework ESP record packet for Bosmer path deity quests, message boxes, manager properties, FormList membership, and ACTI proof-surface base records |
| `tools/pdv-phase13-author` | Narrow Mutagen-backed Phase 13 framework authoring helper | Creating or filling the tracked Hircine/Nord Daedric price `MGEF` / `SPEL` packet and wiring `Price_Seeker`, `Price_Devoted`, and `Price_Champion` on `PDV_DaedricPathBase` |
| `tools/pdv-next-packet-author` | Narrow next-packet framework helper | Repairing Phase 10 Dunmer ACTI cooldown keys, ensuring the Khajiit focused-emphasis mirror global, creating/wiring the Kyne neglect spell/effect, wiring manager properties, and fail-closing the removed generated Phase 11 dialogue path |
| `tools/pdv-phase12-author` | Narrow Mutagen-backed Phase 12 framework authoring helper | Creating or filling the tracked Phase 12 contextual-favor `KYWD` / `MGEF` / `SPEL` packet, wiring `PDV__ManagerQuest`, and ensuring `PDV_State_NordPantheonBaseline` plus `PDV_StateTrack` for the Kyne + Nord broad-lane pilot |
| `tools/pdv_patch.mjs` | Planning-first offline classification/distribution patcher helper | Validating dry-run patch-rule manifests, resolving winning records from the Devotion Dev load order, and planning future generated patch work without writing a live ESP yet |
| `tools/pdv_extract_vanilla_gameplay_refs.mjs` | Read-only Mutagen extraction helper for vanilla/DLC gameplay reference tables | Refreshing generated `references/vanilla-gameplay/extracted/` CSVs before building signal matrices, patcher rules, or compatibility dossiers |
| `tools/pdv_skyrim_refs_bridge.mjs` | Read-only bridge into the neutral `SkyrimGamePlayReferences` repo | Querying broad vanilla/DLC reference tables without vendoring them into PDV |
| `references/authoring/PDV_MCMPropertyWiring.manifest.json` | Manifest-driven batch overlay target for PDV_MCM VMAD property wiring | Regenerating one canonical MCM property-wiring overlay instead of accumulating one-off property patches |
| `references/authoring/PDV_PreflightRouterServices.manifest.json` | Manifest-driven V3 Preflight router-service overlay target | Regenerating the reversible `PDV_PreflightRouterServicesOverlay.esp` canary that co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` |
| `references/authoring/PDV_Phase7SignalReceivers.manifest.json` | Manifest-driven Phase 7 hidden-shrine reference contract | Tracking the actual hidden Talos shrine reference wiring plus the CK-authored Civil War hook contract/proof notes for strict Phase 7 verification |
| `references/authoring/PDV_Phase8ConcordatTalos.manifest.json` | Manifest-driven Phase 8 Concordat/Talos overlay target | Tracking the reversible authoring payload for ConcordatStanding and Talos track-property wiring without treating the overlay as steady-state runtime |
| `references/authoring/PDV_Phase9BosmerState.manifest.json` | Manifest-driven Phase 9 Bosmer path-state + rite contract | Tracking the Bosmer path deity, message, manager-property, proof-surface, and placement contract now that framework record readback is clean |
| `references/authoring/PDV_Phase10_11_DocGrilledPlan.md` | Phase 10/11 doc-grilled plan | Tracking the locked Dunmer substrate graduation and Arngeir/Kynareth privilege-prep decisions |
| `references/authoring/PDV_NextPacket_DocGrilledPlan.md` | Khajiit/commitment/neglect/Phase 11 packet plan | Tracking the current long-smoke packet, remaining CK-owned records, and combined strict gate |
| `references/authoring/PDV_Phase11PrivilegePilot.manifest.json` | Phase 11 privilege pilot contract | Tracking the CK-safe Arngeir/Kynareth recognition gate, live readback, and runtime proof |
| `references/authoring/patch-rules/*.json` | Tracked offline patcher dry-run manifests | Planning classification/distribution work against the resolved load order without treating symbolic example payloads as authoritative live content |
| `PDV_Architecture_v2.md` | Full v2 architecture spec ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â data model, quest topology, phase plan, stance matrix | Phase planning, writing new scripts, understanding the deity/origin system |
| `PDV_Architecture_v3.md` | Forward architecture and roadmap for everything after the proven Phase 4/5/6 baseline | Planning v3 preflight, structural skeleton, beta gates, launch readiness, and post-v2 subsystem work |
| `PDV_TargetEndStates_1.0.md` | Living 1.0 product target, per-race acceptance state, roadmap traceability | Tracking final 1.0 product readiness and race-by-race end-state closure |
| `archive/completed-phase-docs-2026-05-16/README.md` | Index for completed phase walkthroughs and historical planning docs | Finding archived Phase 2/3/4/5/6 CK guides and earlier planning notes |
| `archive/PDV_DecisionsLog_Archive_2026-05.md` | Dated archive of decisions-log entries rolled out of the live log (foundational decisions, closed Phase 1-9 proofs, V3 preflight/slices/Phase 7, race implementation-lock pass, Prisma, lessons, early session notes) | Looking up the full text or rationale of a decision not in the live Decisions Log window |
| `archive/phase-order-recommendations-2026-05-20.md` | Frozen phase-order review imported from the Claude branch | Rechecking why Section 21.5 adopted the reduced reorder and rejected extra standalone slices |
| `PDV_SkyrimConsoleReference.md` | UESP-sourced console command reference (source of truth) | Any in-game testing or debugging |
| `references/PDV_Anvil_MO2_MCP_Intake.md` | Codex-facing intake of the Anvil MO2 MCP plugin, tool surface, optional binaries, and local setup status | Using or troubleshooting `mo2_*` tools from Codex |
| `references/PAPYRUS_KNOWLEDGE_INTAKE.md` | Papyrus API/reference strategy, source-layer cautions, and BellCube/SKSE intake notes | Any Papyrus scripting, API lookup, or tooling/ref-generation planning |
| `https://github.com/BellCubeDev/papyrus-index` / `https://papyrus.bellcube.dev/` | Primary external Papyrus API index for vanilla, SKSE, and many plugin-provided functions | When local `.psc` source, CK Wiki, or bundled notes do not fully settle a Papyrus signature, inheritance detail, or plugin-surface question |
| `references/PDV_RaceArchitecture_DesignReference.md` | Living race architecture reference for theology, curse handling, reward contract, and quest weighting | Resolving per-race design, locking theology decisions, planning future signal matrices |
| `race-sheets/*.md` | Race-by-race player-facing design sheets plus the overview | Keeping readable race gameplay/design summaries in sync with the locked architecture reference |
| `references/vanilla-gameplay/` | Living gameplay mechanics and immersive UX reference backbone | Looking up vanilla Skyrim mechanics, CK signal surfaces, source-backed gameplay tables, or player-experience lessons for PDV design |
| `references/vanilla-gameplay/compatibility/phase20-targets.csv`, `references/vanilla-gameplay/compatibility/PDV_Phase20_CompatibilityNotes.md` | Phase 20 compatibility matrix and operating notes | Tracking Authoria-first list-author package status, target-list evidence, religion-removal assumptions, patch shape, and smoke gates |
| `references/vanilla-gameplay/PDV_SkyrimGamePlayReferences_Bridge.md` | Bridge rules for using `dunhamma/SkyrimGamePlayReferences` from PDV | Pulling neutral reference data into PDV planning without making it design authority |
| `references/phase4/PDV_Phase4_MatrixScaffold.md` | Working conventions and normalization rules for the Phase 4 matrix pass | Understanding matrix scope, crosswalk rules, and output structure |
| `references/phase4/PDV_RaceSignalMatrix.csv` | First-release race/path/layer signal matrix | Planning Phase 4 implementation signals and anti-farm rules |
| `references/phase4/PDV_StanceMatrix.csv` | First-pass per-worship-object per-race stance matrix | Seeding Phase 4 stance properties and rivalry assumptions |
| `references/phase4/PDV_DaedricRacePrinceMatrix.csv` | Prince-first Daedric race-response matrix | Planning Daedric path buildability, race response, and exit logic |
| `references/phase4/PDV_MatrixCrossValidation.md` | Cross-matrix consistency note and intentional divergence log | Verifying the three matrixes against each other and the locked architecture |
| `skills/pdv-doc-sync/SKILL.md` | Local Codex skill source for end-of-session PDV doc sync | Updating project docs after implementation/CK/test work; run at the end of meaningful PDV sessions so doc sync and learning capture both happen |
| `skills/pdv-papyrus-ck/SKILL.md` | Local Codex skill source for PDV Papyrus/CKPE guardrails | Writing/reviewing Papyrus, compile commands, CK wiring, Story Manager tests |
| `pdv-doc-sync.skill`, `pdv-papyrus-ck.skill` | Packaged local skill artifacts | Installing/sharing the project skills |
| `archive/completed-phase-docs-2026-05-16/*` | Archived Phase 2/3 walkthroughs and earlier planning notes | Historical context only; not part of the active root workflow |
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity equivalency table (all 9 races ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â all pantheons) | Writing race-specific dialogue, checking deity names, avoiding lore errors |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice, threshold rituals, class variation, era pressures | Designing trigger conditions, writing flavour text, balancing per-race logic |
| `references/tamriel-cursed-worship-4e201.html` | Race-by-race curse-state religious interpretation source | Designing vampire/werewolf theological posture and curse pressure |
| `references/tamriel-daedric-worship-4e201.html` | Race-by-race Daedric practice source | Designing Prince-first paths, stigma, and race-specific Daedric friction |
| `archive/HOUSECARL_*.md`, `archive/Skyrim_Modding_Lessons*.md` | Frozen source material | When PDV_STANDARDS doesn't cover a question and you want the fuller treatment |
| `archive/pdv-recovery-tools-2026-05-16/*` | Historical emergency/generated repair artifacts | Provenance only; do not use as active workflow tools |

### Mod implementation folder

Source and compiled output live at `D:\Wabbajack\modlists\Anvil\mods\Devotion\` (MO2-managed; `meta.ini` present). Source `.psc` files at the root; compiled `.pex` in `Scripts\`. The MCP server is connected to the Anvil MO2 instance with the **Devotion Dev** profile.

Phase 4 design outputs are mirrored for live reference under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\`. The tracked source copies remain under `references/phase4/` in this docs workspace.

Script folder layout (CK toolchain):
```
Devotion\
  Scripts\
    PDV__MainQuest.pex
    PDV_Origin.pex
    PDV__ManagerQuest.pex     ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â compiled output
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
      PDV__ManagerQuest.psc   ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â source (edit here, compile via CK)
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
- `PDV__MainQuest.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â RunOnce bootstrap quest. **Phase 4 script complete on disk:** verifies PapyrusUtil and defers origin capture to the player-alias ingress instead of forcing `PDV_Origin.InitializeOrigin()` during `OnInit()`.
- `PDV_Origin.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (Phase 4)** One-shot origin helper. Detects and normalizes player origin race, treats vanilla vampire races as their birth race, defers while only a temporary beast-form race is visible, treats the first Nord capture as provisional to avoid placeholder new-game race reads locking too early, writes `PDV_GLO_OriginRace`, and seeds the current proof-slice deity ledgers.
- `PDV__ManagerQuest.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 18 status/Nord surface wired:** stance-aware piety, patron state, dawn consolidation, contextual favors, commitment, curse-state handling, and neglect remain manager-owned. The manager now also auto-grants `Survey Devotion`, exposes thematic player-status APIs, suppresses Nord commitment offers/contextual favors while a Nord vampire rupture is active, and preserves a cured-vampire scar note without clearing patron piety.
- `PDV_DeityBase.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 4 refactor complete on disk:** race-keyed stance properties, rivalry metadata, and cumulative patron-only boon sync. Replaces the Phase 2 origin-multiplier floats.
- `PDV_Deity_Kyne.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 4 proof slice on disk:** same Kyne rubric as before, now expected to use the simple Nord-native / everyone-else-foreign stance row plus CK-authored boon spells.
- `PDV_Deity_Talos.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (coupled follow-on slice)** First hostile-path proof deity. Curated Talos-facing defiance signals only; Altmer hostility should rival Auri-El one-way.
- `PDV_Deity_AuriEl.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (coupled follow-on slice)** Minimum viable Altmer foundation deity and real rivalry target for Talos. Seeded for Altmer, but still follows patron-only boon rules.
- `PDV_Deity_Yffre.psc` / `PDV_Deity_Zen.psc` / `PDV_Deity_BaanDar.psc` - **NEW (Phase 9 Bosmer path slice)** First Bosmer path foreground deity trio. `LivingStory` and `OldContract` deliberately share one `Y'ffre` ledger; `Z'en` is distinct from `Zenithar`; and path eligibility is gated through `PDV_StateTrack_BosmerPath` rather than separate deity variants.
- `PDV_EventTypes.psc` - **NEW (V3 Preflight script slice)** Central event and attribution constant owner. Compiles cleanly; framework-owned record wiring is live on `PlayerDevotion_Framework.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact.
- `PDV_EventBus.psc` - **NEW (V3 Preflight script slice)** Dispatch service for validated event payloads. Direct-player kill scoring remains behavior-compatible with v2; non-direct attribution is carried but non-scoring until later phases. Phase 7 source now also routes PO3 shout ingress and hidden Talos shrine defiance through manager-owned helpers. Phase 9 source adds Bosmer path-evidence routes plus the shared state-transition confirmation-rite route. Compiles cleanly; framework-owned record wiring is live on `PlayerDevotion_Framework.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact.
- `PDV_EventSignalActivator.psc` / `PDV_EventSignalEffect.psc` - **NEW (V3 Slice 1 receiver layer)** Tiny CK-owned receiver scripts for normal-play activator and MGEF/consumable proof records. They validate player/origin/day gates, call existing EventBus routes by `RouteId`, and never write piety, substrate, Green Pact, or Daedric state directly. Source and `.pex` are live; the manual ACTI/MGEF proof records now exist in the framework ESP and are runtime-proven for Dunmer portable/private shrine practice, Bosmer Green Pact violation, and Hircine hunt rite.
- `PDV_SurveyDevotionEffect.psc` - **NEW (Phase 18 status surface)** Lesser-power display effect for `PDV_SPEL_SurveyDevotion`. It calls `PDV__ManagerQuest.GetSurveyDevotionText()` and shows a thematic `MessageBox`; it never writes piety, patron, favor, or curse state.
- `PDV_PlayerEvents.psc` - **NEW (V3 pilot-first ingress slice)** Player `ReferenceAlias` event surface for sleep/load registration and routed non-kill proving signals. Source and `.pex` are live, the `PDV_Player` alias is now attached manually on `PDV__ManagerQuest`, Khajiit sleep ingress is runtime-proven through EventBus/manager/substrate, and Phase 7 source now registers PO3 shout hooks plus `OnShoutAttack(Shout akShout)` routing. Runtime hardening now treats that alias route as preferred but not exclusive: `PDV__ManagerQuest` also registers a quest-form shout fallback and suppresses duplicate callbacks before scoring. Safe authoring still cannot mint new quest aliases, so future alias additions remain manual CK/xEdit work.
- `PDV_MCM.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 18 player/status/debug surface:** SkyUI now opens on a small `Player` page with thematic readout rows plus a `Survey Devotion` action. Numeric Status and mutation-heavy Debug pages remain present but are locked behind the StorageUtil-backed `Developer Options` toggle.
- `PDV_ActionRouter.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (Phase 3)** Persistent service quest that fans validated player kill actions to all deities via `ScoreAction()`; compiles cleanly, CK quest/property wiring complete, hostile bandit/wolf runtime paths verified.
- `PDV__SM_KillActor.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (Phase 3)** Non-Start-Game-Enabled Story Manager receiver quest for `OnStoryKillActor`; compiles cleanly, CK quest/Story Manager wiring complete, receiver path verified by hostile kill events.

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
node .\tools\pdv_verify.mjs --strict-phase18
node .\tools\pdv_verify.mjs --strict-nord
node .\tools\pdv_author.mjs status phase4
node .\tools\pdv_author.mjs plan phase4
node .\tools\pdv_author.mjs apply phase4 --output PDV_Author_phase4.esp
node .\tools\pdv_author.mjs plan preflight-router-services
node .\tools\pdv_author.mjs apply preflight-router-services
node .\tools\pdv_patch.mjs validate
node .\tools\pdv_patch.mjs plan
node .\tools\pdv_patch.mjs plan --json
dotnet run --project .\tools\pdv-phase9-author -- --dry-run
dotnet run --project .\tools\pdv-phase9-author
dotnet run --project .\tools\pdv-phase9-author -- --check-placements
dotnet run --project .\tools\pdv-phase13-author -- --dry-run --create-missing
dotnet run --project .\tools\pdv-phase13-author -- --create-missing
dotnet run --project .\tools\pdv-next-packet-author -- --dry-run
dotnet run --project .\tools\pdv-next-packet-author
dotnet run --project .\tools\pdv-phase12-author -- --dry-run --create-missing
dotnet run --project .\tools\pdv-phase12-author -- --create-missing
dotnet run --project .\tools\pdv-phase18-author -- --dry-run --create-missing
dotnet run --project .\tools\pdv-phase18-author -- --create-missing
```

 The verifier checks the Anvil/Devotion paths, reads `PlayerDevotion_Framework.esp` through the Anvil MO2 MCP Mutagen bridge, validates the current Phase 4 baseline records/properties plus the Talos/Auri-El and Bosmer follow-on records, checks Phase 3 receiver/router wiring, checks script source/pex freshness, detects CK output shadow files, checks SEQ state, and confirms the active MO2 profile/load order. It now explicitly fails or warns when the live ESP is missing `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, `PDV_Deity_Talos`, `PDV_Deity_AuriEl`, expected stance rows, Talos rivalry wiring, deity boon assignments, or the tracked Pattern Proving ingress source surface (`PDV_PlayerEvents`, `PDV_EventSignalActivator`, `PDV_EventSignalEffect`, routed EventBus helpers, and new event constants). V3 Preflight source/pex readiness is verifier-covered; the framework-owned CK/xEdit records (`PDV_GLO_PatronState`, `PDV_EventTypes`, `PDV_EventBus`) report as INFO in default mode, and `--strict-preflight` promotes those outstanding Preflight gaps to FAIL for gate-close runs. `--strict-pattern-proving` now covers the first pilot-first non-kill ingress source contract, the Slice 1 receiver manifest, optional readback for the manual ACTI/MGEF proof records once they exist, and live `PDV_Player` alias readback on `PDV__ManagerQuest`. `--strict-phase7` adds PO3 shout registration/source checks, quest-form shout fallback source checks, alias readback, plus readback for the actual hidden Talos shrine reference named in `references/authoring/PDV_Phase7SignalReceivers.manifest.json`. `--strict-phase8` adds ConcordatStanding record/property and threshold-array coverage, Talos track-multiplier wiring checks, Phase 7 ingress surface checks reused by the track, manager-side runtime-wiring fallback detection, and the MCM/source contract for committed state, pending state, extreme gate, and Talos effective multiplier readback. `--strict-phase9` adds Bosmer state-track array/property coverage, shared transition source contract checks, Bosmer deity/property coverage, Bosmer manager/message wiring readback, and proof-surface receiver readback for the tracked Phase 9 editor IDs. `--strict-phase10` adds Dunmer ancestor substrate graduation checks for source contract, substrate record/scripts/properties, manager property, and the two reused Dunmer proof ACTI records. `--strict-phase11` verifies the Arngeir/Kynareth privilege pilot manifest; live dialogue readback only runs when the manifest is explicitly marked `live-dialogue-authored`. `--strict-phase12` adds contextual-favor lane/family presence checks, manager wiring/readback assertions for favor records and state keys, and explicit readback for `PDV_State_NordPantheonBaseline` as a `QUST` with `PDV_StateTrack` attached. `--strict-phase18` / `--strict-nord` verifies Survey Devotion spell/effect records, manager/MCM source contracts, Nord curse-message records, manager/effect VMAD wiring, and the four manual CK dialogue contracts in `references/authoring/PDV_Phase18StatusNord.manifest.json`; live dialogue readback remains skipped until that manifest is marked `live-dialogue-authored`. The verifier also reads back the tracked `PDV_PreflightRouterServicesOverlay.esp` canary when present. It is diagnostic only and must not write to the ESP or MO2 profile files.

 `pdv_author.mjs` is the safe authoring companion to that loop. It inspects the live framework ESP through the same Mutagen bridge, then emits a **new overlay patch plugin** into the `Devotion` mod when asked to apply changes. Current supported writes are existing-record script attachment, scalar/object VMAD properties, and FormList membership. It does **not** mint new records, edit VMAD array properties such as `RivalDeities`, or overwrite `PlayerDevotion_Framework.esp` in place. Generated patches must keep `Skyrim.esm` as the first master when using extended FormID ranges; do not manually insert masters into an existing patch without remapping FormIDs.

 `tools/creation-authoring` / `C:\Users\Admin\Documents\ckra-native` is the separate CKPE-backed generated-record workbench. The vendored Devotion copy now includes the generic `fixtures/dialogue-v1` scaffold for future dialogue work: it can model branch/topic/INFO/SEQ intent, verify CK-authored `DLBR`/`DIAL`/unnamed `INFO` readback by payload and conditions, and prove that strict mode still fails closed without CK command evidence. Use it to make future dialogue authoring less manual at the manifest/readback/proof layer, not to regenerate dialogue records directly. As of the current proof ledger, product creation support still requires proof-ledger promotion; `glob.duplicate_create` remains the narrow promoted example. Treat generated plugins as the safety boundary, and do not claim `DIAL`/`INFO` support until native CK-owned graph creation, active-plugin save, MO2 readback, verifier proof, and command evidence all pass.

 `tools/pdv-phase9-author` is a narrow Phase 9 closeout helper, not a general authoring framework. It directly rewrites `PlayerDevotion_Framework.esp` after taking a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase9\`, and it exists only to make the Bosmer path framework packet reproducible: `PDV_GLO_BosmerPath`, `PDV_StateTrack_BosmerPath`, `PDV_Deity_Zen`, `PDV_Deity_BaanDar`, Y'ffre cleanup, `PDV_FLST_AllDeities` membership, six Bosmer message boxes, `PDV__ManagerQuest` Bosmer properties, and five ACTI proof-surface base records. Run `--dry-run` first. It can fill CK-created blank shells for the known Phase 9 records, but `PDV_GLO_BosmerPath` must exist as a `GLOB` shell if the framework packet is being rebuilt from scratch. `--check-placements` is read-only and verifies that the five expected Phase 9 `PDV_REFR_*` placed references point at the intended ACTI base records. It does not prove runtime behavior.

 `tools/pdv-phase13-author` is a narrow direct-framework helper for the Phase 13 Hircine/Nord Daedric packet. It reads `PlayerDevotion_Framework.esp`, creates a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase13\`, and uses `references/authoring/PDV_Phase13DaedricHircinePilot.manifest.json` as the source of truth for the three Hircine price records. Run `--dry-run` first. By default it stays conservative and fails on missing records; with `--create-missing`, it can create the tracked `MGEF` and `SPEL` records, then wire `Price_Seeker`, `Price_Devoted`, and `Price_Champion` on `PDV_DaedricPathBase`. It does not widen the CKPE bridge capability claim and it does not replace the manual runtime proof pass.

 `tools/pdv-phase12-author` is a narrow direct-framework helper for the Phase 12 contextual-favor pilot. It reads `PlayerDevotion_Framework.esp`, creates a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase12\`, and uses `references/authoring/PDV_Phase12ContextualFavorPilot.manifest.json` as the source of truth for the Kyne + Nord broad-lane favor packet. Run `--dry-run` first. By default it stays conservative and fails on missing records; with `--create-missing`, it can create the tracked Phase 12 `KYWD`, `MGEF`, and `SPEL` records plus `PDV_State_NordPantheonBaseline` when absent, then fill the favor records, attach `PDV_StateTrack`, and wire `PDV__ManagerQuest`. It does not widen the CKPE bridge capability claim and it does not replace the manual runtime proof pass.

 `tools/pdv-phase18-author` is a narrow direct-framework helper for the Phase 18 player-status/Nord pilot packet. It reads `PlayerDevotion_Framework.esp`, creates a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase18\`, and uses `references/authoring/PDV_Phase18StatusNord.manifest.json` as the source of truth for `PDV_SPEL_SurveyDevotion`, `PDV_MGEF_SurveyDevotion`, and the Nord werewolf/vampire message records. Run `--dry-run --create-missing` first. The helper can create/fill Survey spell/effect and Nord `MESG` records, attach `PDV_SurveyDevotionEffect`, and wire manager/effect properties. It must not create dialogue records; the four Nord NPC recognition topics remain CK-authored using `references/authoring/PDV_Phase18_StatusNord_Runbook.md`.

 `pdv_patch.mjs` is the planning-first companion for the later Phase 19 offline classification/distribution direction. v0 reads tracked rule manifests from `references/authoring/patch-rules/`, validates their schema strictly, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning records, and emits deterministic dry-run plan output. It does **not** write a generated patch ESP yet; the first pass is schema/load-order/target-resolution proof only.

Toolchain usage rules:
- After editing any PDV `.psc`, run `node .\tools\pdv_compile.mjs` or `node .\tools\pdv_compile.mjs --script <ScriptName>`.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3` or compile with `node .\tools\pdv_compile.mjs --strict-phase3`.
- Before declaring V3 Preflight complete, run `node .\tools\pdv_verify.mjs --strict-preflight` (or compile with `node .\tools\pdv_compile.mjs --strict-preflight`) and resolve all FAILs.
- Before declaring a Pattern Proving checkpoint complete, run `node .\tools\pdv_verify.mjs --strict-pattern-proving` (or compile with `node .\tools\pdv_compile.mjs --strict-pattern-proving`) and treat duplicate-VMAD results as explicit waivers until the framework record attachments are manually consolidated.
- Before declaring Phase 7 signal expansion complete, run `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 8 reputation-track closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 9 Bosmer-path closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 10 Dunmer-substrate graduation complete, run `node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and confirm the runtime proof notes still show substrate progress separate from patron piety.
- Before declaring the Khajiit/commitment/neglect packet complete, run `node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` and resolve all FAIL/WARN results except explicitly waived SEQ freshness during active CK dialogue work.
- For Phase 11, run `node .\tools\pdv_verify.mjs --strict-phase11` to confirm the D-10 Arngeir/Kynareth manifest and CK-authored dialogue readback. Phase 11 runtime proof is complete as of 2026-05-26.
- For Phase 12, run `dotnet run --project .\tools\pdv-phase12-author -- --dry-run --create-missing`, then the live `--create-missing` pass if the dry-run is correct, then `node .\tools\pdv_verify.mjs --strict-phase12`. A fresh ESP write should leave `SEQ freshness` as the expected remaining warning until `PlayerDevotion_Framework.seq` is refreshed.
- For Phase 13, run `dotnet run --project .\tools\pdv-phase13-author -- --dry-run --create-missing`, then the live `--create-missing` pass if the dry-run is correct, refresh SEQ, and run `node .\tools\pdv_verify.mjs --strict-phase13` before runtime proof.
- For Phase 14-16 closeout, run `node .\tools\pdv_verify.mjs --strict-phase14 --strict-phase15 --strict-phase16` after any source or CK changes. Runtime proof is complete as of 2026-05-28; remaining work is content expansion, not seam validation.
- For Phase 17 decay bridge closeout, compile `PDV__ManagerQuest` and `PDV_MCM`, then run `node .\tools\pdv_verify.mjs --strict-phase17`. Runtime proof is still required before marking Phase 17 complete.
- For Phase 18/Nord status closeout, run `dotnet run --project .\tools\pdv-phase18-author -- --dry-run --create-missing`, then the live `--create-missing` pass if the dry-run is correct, compile `PDV_MCM`, `PDV__ManagerQuest`, and `PDV_SurveyDevotionEffect`, and run `node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord --strict-phase17 --strict-phase13 --strict-phase14 --strict-phase15 --strict-phase16`. Dialogue remains manual CK work and SEQ freshness must be resolved before closeout, not waived.

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

---

## Architecture Summary

### ESP Structure

```
PlayerDevotion_Framework.esp    ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â master: quest spine, deity registry, globals
PDV_Nord.esp                    ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â race module (depends on framework)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

### v2 Architecture (current target ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â see `PDV_Architecture_v2.md` for full spec)

Per-deity piety lives in **StorageUtil** (PapyrusUtil SE), keyed by deity FormID. A set of **mirror GlobalVariables** shadows the active patron's current values so vanilla CK Conditions can read them without scripting glue. The manager quest is a dispatcher and helper API, not a calculator.

**StorageUtil keys per deity:**

| Key | Range | Purpose |
|-----|-------|---------|
| `PDV.Piety` | 0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ200 | Current piety. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Reset at dawn. |
| `PDV.Tier` | 0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Decay grace period + MCM display |

**Mirror GlobalVariables (active patron only):**

| Global | Purpose |
|--------|---------|
| `PDV_GLO_ActivePiety` | Active patron's current piety |
| `PDV_GLO_ActiveTier` | Active patron's current tier (0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ3) |
| `PDV_GLO_ActiveDeityIndex` | Stable int identifying the active deity. -1 = none |

Mirrors are refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()` on patron switch and after any persistent piety/tier mutation to the active patron. They mirror `PDV.Piety`, not `PDV.PietyToday`, and are never the source of truth ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â StorageUtil is.

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
| 1 | Seeker | ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°Ãƒâ€šÃ‚Â¥ 10 |
| 2 | Devoted | ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°Ãƒâ€šÃ‚Â¥ 50 |
| 3 | Champion | ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°Ãƒâ€šÃ‚Â¥ 150 |

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

All records use prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals add a second underscore (`PDV_GLO__X`). Mirrored from Gods And Worship ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â full reference in `PDV_MOD_SETUP.md` ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ EditorID Prefix Convention.

```
PDV__MainQuest                  ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â internal: RunOnce bootstrap
PDV__ManagerQuest               ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â internal: runtime (registry + helper API)
PDV_GLO_ActivePiety             ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, mirror: active patron's piety (float)
PDV_GLO_ActiveTier              ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, mirror: active patron's tier 0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ3 (float)
PDV_GLO_ActiveDeityIndex        ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, mirror: active deity stable int, -1=none (float)
PDV_GLO_OriginRace              ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, set once: race index 0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ9 (Phase 4)
PDV_GLO_PatronDeity             ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, FormID of active patron, 0=none (Phase 2+)
PDV_GLO_DebugLevel              ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Global, 0ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ3 trace verbosity (MCM-toggleable)
PDV_Race[Name]Quest             ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â per-race tracking (in race ESP)
PDV_ActionRouter                ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Story Manager event fan-out (Phase 3)
PDV__SM_KillActor               ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â internal Story Manager receiver quest for Kill Actor (Phase 3)
PDV_DeityBase                   ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â base class all PDV_Deity_<X> scripts extend (Phase 2)
PDV_Deity_[Name]                ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â concrete deity quest (Phase 2+)
PDV_FLST_AllDeities             ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â FormList, iteration source for ProcessDawn and MCM
PDV_GLO_PatronState             - Global, V3 Preflight patron state: 0=unset, 1=broad worship, 2=active patron
PDV_EventTypes                  - V3 Preflight central event/attribution constant owner
PDV_EventBus                    - V3 Preflight dispatch service between receivers and deity scoring
PDV_Blessing_[Race]_Low/Mid/High
PDV_Neglect_[Race]
PDV_SMF_[EventName]             ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Ãƒâ€šÃ‚Â Story Manager flag globals
PDV_DebugSpell
```

`PDV_GLO_DevotionLevel`, `CombatBucket`, `SocialBucket`, and `LifestyleBucket` have been removed.

---

## Race Design Philosophy

Each race module is designed around the **primary religious tension** that culture faces in 4E 201. These tensions should drive what deity rubrics reward and punish ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â not generic "worship a shrine" logic.

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
- **Orcs** treat craft as prayer. Malacath is not petitioned ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â he judges by observing strength and labor.
- **Argonians** lose their core religious infrastructure (the Hist) when outside Black Marsh. Design their triggers around adaptation and absence, not normal worship.
- **Bosmer** Green Pact dietary observance (no plant matter) creates daily friction in Skyrim that is itself a mechanic opportunity.
- **Redguard** theology is a survival narrative. Their recent military victory over the Dominion is a live theological fact in 4E 201.
- **Daedric Prince** names are largely consistent across all cultures ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â use `references/skyrim-deity-reference.jsx` for the few exceptions (e.g. Azurah, Boethra, Sheggorath for Khajiit).

---

## Current Build Status

*Update this section as the project progresses.*

```
[x] Environment setup verified
[x] PDV_Framework.esp created
[x] Master quest and script skeleton running
[x] Phase 0 complete ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 complete ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â StorageUtil data model, mirror globals declared and verified,
      PDV__ManagerQuest refactored (AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors)
[x] Phase 2 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Functional alignment complete on disk; CK compile/wiring/runtime verification complete
      - PDV_DeityBase.psc (base class contract + debug global property) ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - PDV_Deity_Kyne.psc (first concrete, rubric implemented) ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - PDV__ManagerQuest.psc (per-deity StorageUtil API + dawn consolidation + poll-based debug harness) ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - VERIFIED IN GAME: patron activation, mirror globals, dawn clamp, and tier threshold transition
[x] PDV local toolchain ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, and `tools/pdv_author.mjs` built and documented
[x] Phase 3 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ActionRouter kill-event slice complete; CK wiring and runtime verification passed
      - PDV_ActionRouter.psc + .pex ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - PDV__SM_KillActor.psc + .pex ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - PDV_ActionRouter quest + properties ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - PDV__SM_KillActor quest + PDV_Router property ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - Kill Actor Story Manager receiver node + Shares Event ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - SEQ generated under Devotion\Seq ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - VERIFIED IN GAME: Kyne activation, hostile bandit +0.5 scratch, hostile wolf -3 scratch,
        neutral-kill rejection, rapid dual-kill accumulation, and manual dawn consolidation/clamping
[x] Phase 4 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â framework scripts/tooling, live ESP wiring, and full in-game proof complete
      - `PDV__MainQuest.psc` + `.pex` bootstrap implementation ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV_Origin.psc` + `.pex` origin detection / Kyne seed helper ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV__ManagerQuest.psc` stance-aware scratch + rivalry plumbing ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV_DeityBase.psc` race-keyed stance + patron-only cumulative boon sync ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV_Deity_Kyne.psc` proof-slice script update ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - historical CK walkthrough archived under `archive/completed-phase-docs-2026-05-16/PDV_Phase4_CK_Steps.md`
      - `tools/pdv_compile.mjs` / `tools/pdv_verify.mjs` Phase 4 coverage ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `tools/pdv_author.mjs` reversible overlay-patch authoring for supported existing-record wiring ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - VERIFIED IN ESP: `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`,
        Kyne stance row, Kyne boon assignments, and framework-owned `PDV__ManagerQuest.PDV_GLO_PatronDeity`
      - VERIFIED IN GAME: Nord bootstrap, Kyne seed, patron-only boon grant/removal, and save/load sanity
[x] Phase 5 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â MCM dev slice landed in script/tooling/docs, framework ESP wiring, and in-game proof
      - `PDV_MCM.psc` Status + Debug-only menu ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - manager MCM-safe roster/debug helpers ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `tools/pdv_compile.mjs` SkyUI import chain + SKI output guard ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `tools/pdv_verify.mjs` `PDV_MCM` coverage + SKI output hygiene ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - historical CK walkthrough archived under `archive/completed-phase-docs-2026-05-16/PDV_Phase5_CK_Steps.md`
      - VERIFIED IN ESP: `PDV_MCM` quest exists, script is attached, and required properties are wired directly on `PlayerDevotion_Framework.esp`
      - VERIFIED IN GAME: `PlayerDevotion` registers in SkyUI, `Status` and `Debug` pages load, the live Kyne/Talos/Auri-El roster renders, and debug patron override works
      - NOTE: MCM smoke path currently requires ReShade disabled in the Anvil Stock Game until the native conflict is understood
[x] Phase 6 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â coupled Talos + Auri-El hostile-path proof slice landed in script/tooling, CK wiring, and full in-game proof
      - `PDV_Deity_Talos.psc` + `.pex` ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV_Deity_AuriEl.psc` + `.pex` ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV_Origin.psc` generalized to small multi-deity seed table ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - `PDV__ManagerQuest.AwardCuratedSignal*()` helper path ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
      - verifier coverage for Talos/Auri-El + rivalry expectations ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
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
      - framework-owned scaffold records, arrays, and FormLists merged into `PlayerDevotion_Framework.esp`
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
      - framework-owned Bosmer path records, Y'ffre/Z'en/Baan Dar eligibility, six Bosmer message boxes, manager properties, `PDV_FLST_AllDeities` membership, and the five placed proof activator references are live in `PlayerDevotion_Framework.esp`
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
      - Phase 14 runtime proof passed on 2026-05-28 for Kyne seed/evaluate, `Not Yet` decline (`7` days), `Refuse` (`14` days with rupture), `Accept`, and accepted-patron persistence
      - Phase 15 runtime proof passed on 2026-05-28 for the shared `PDV_CurseState` werewolf/vampire/none seam, with live Hircine curse-entry and werewolf-cure traces in `Papyrus.0.log`
      - Phase 16 runtime proof passed on 2026-05-28 for active-Kyne low-piety neglect selection, Kyne neglect-spell application, and broad-worship suppression clearing the active neglect set on re-evaluation
      - targeted strict gate after the debug-path hardening is clean at `FAIL=0, WARN=1, PASS=1092, INFO=28`, with only `SEQ freshness` still warning
[x] Phase 17 decay bridge
      - source/readback implementation is live: active patrons are skipped by passive dawn decay, non-patron deities still drift, and Phase 17 has dedicated MCM proof controls plus `references/authoring/PDV_Phase17DecayModel.manifest.json`
      - runtime proof passed on 2026-05-28 for grace no-op (`20.00 -> 20.00`), eligible decay (`20.00 -> 19.50`), same-day guard (`19.50` held), broad worship (`20.00 -> 19.90`), active-patron skip, non-patron drift while Kyne stayed protected, Devoted floor (`50.00 -> 10.00`), and Champion floor (`150.00 -> 50.00`)
      - runtime proof also regression-checked Phase 16: broad worship suppressed neglect (`count=0; kyneSpell=0`), and active Kyne produced targeted neglect (`count=1; active=Kyne; kyneSpell=1`)
      - full bridge gate is clean at `FAIL=0, WARN=1, PASS=1155, INFO=29` via `node .\tools\pdv_verify.mjs --strict-phase16 --strict-phase17 --strict-phase18 --strict-nord --strict-phase13 --strict-phase14 --strict-phase15 --json`; the remaining warning is expected `SEQ freshness`
[x] Phase 11 privilege pilot
      - D-10 is resolved to the Arngeir/Kynareth recognition pilot with gate `OriginRace = Nord`, `ActiveDeityIndex = Kyne`, and `ActiveTier >= 3`
      - generated Arngeir dialogue records were removed after a CrashLogger-confirmed CTD; the live replacement is CK-authored and verifier-covered as a `DLBR`, `DIAL`, and CK-authored unnamed `INFO`
      - runtime proof passed on 2026-05-26 for Nord/Kyne Champion positive, non-Nord negative, wrong active deity negative, below-Champion negative, and save/load sanity
      - current full combined gate is clean at `PASS=908, INFO=28`, with no `FAIL`, `WARN`, or `TODO`
[~] Phase 18 status/debug surface
      - `PDV_SPEL_SurveyDevotion` / `PDV_MGEF_SurveyDevotion` are live in the framework ESP, `PDV_SurveyDevotionEffect` compiles, and `PDV_MCM` now has Player/Status/Debug pages with Developer Options gating
      - strict bridge/readiness gate including runtime-proven Phase 17 is clean at `FAIL=0, WARN=1, PASS=1155, INFO=29`; the remaining warning is expected `SEQ freshness` after the ESP write
      - runtime matrix is now locked in `references/authoring/PDV_Phase18StatusNord.manifest.json`: fresh-save auto-grant, Survey MessageBox, Player tab readout, Developer Options persistence, broad/focused Nord readouts, vampire suppression/scar, and save/load persistence
[~] Nord module complete
      - Nord player-status, broad/focused readout, vampire suppression/scar handling, Hircine/werewolf feedback, and Survey record/helper/verifier coverage are live
      - Froki, Heimskr, Andurs, and Aela dialogue contracts now include branch/topic/INFO hints plus positive/negative runtime cases; dialogue records, SEQ refresh, and counted runtime proof are still pending
[~] Phase 20 compatibility rebaseline
      - Phase 20 is now Authoria-first list-author compatibility, not Sacrosanct-first standalone compat
      - tracked source of truth is `references/vanilla-gameplay/compatibility/phase20-targets.csv` plus `PDV_Phase20_CompatibilityNotes.md`
      - 1.0 compatibility gate is an accepted Authoria integration/test package; JOJ, TOT, HOH, MOM, DoD, and VOV should reach `patch-packaged`
      - implementation patches are not built yet; current work is architecture, matrix, and handoff-policy alignment
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
- Smoke-test standard is "full phase closeout unless explicitly narrowed."
  (Phase 4/6 closeout, 2026-05-16)
- When Papyrus compile errors appear, triage in this order: import chain,
  API/source provenance, parser/language limit, then logic bug.

**Tooling harvest**
- After a new kind of PDV work, while it is still fresh, ask whether the next
  pass should be easier, safer, or more repeatable. If a pain point is manual,
  fragile, repeated, or easy to forget, harvest it into the smallest durable
  surface: a verifier check, authoring helper, manifest, checklist, local skill,
  or living docs. (Tooling harvest rule, 2026-05-24 — full entry in Decisions Log)

**Gameplay posture (load-bearing for Phase 7+)**
- Quiet / event-led / recoverable / vanilla-plus play is architecture truth.
  Reject raw skill-XP scoring, raw craft-count scoring, routine notification
  spam, and chore-loop religion as default PDV design shapes. (Gameplay posture
  lock, 2026-05-18)

**Authoring boundaries**
- Schema-first / text-first ESP authoring stays research-only. Until a proven
  build tool exists, the source of truth is the living docs, PDV `.psc` source,
  `PlayerDevotion_Framework.esp`, and the supported `tools/pdv_*` helpers; do
  not treat any YAML/TOML schema draft as authoritative state. (2026-05-16)
- Overnight/unattended windows may pull forward only the narrow set named in
  `PDV_Architecture_v3.md` Section 21.5 (commitment + neglect/decay hardening,
  UI toast contract, Khajiit focused-emphasis scaffold, limited Bosmer path
  bookkeeping) without claiming parent slices complete. Do not pull forward
  privilege, full Daedric price/stigma, or curse-state work. (Overnight enabler
  rule, 2026-05-20)

---

## Decisions Log

*Append here when architectural choices are made. Mirror significant entries in PDV_MOD_SETUP.md.*

- **Phase 20 compatibility rebaseline (2026-05-28):** Phase 20 now targets list-author packages rather than end-user Wabbajack swap support. The seven target lists are Authoria/ARR, JOJ, TOT, HOH, MOM, DoD, and VOV. Authoria is P0 and the 1.0 compatibility gate is an accepted Authoria integration/test package; the other six should reach `patch-packaged`. The tracked source of truth is `references/vanilla-gameplay/compatibility/phase20-targets.csv` plus `PDV_Phase20_CompatibilityNotes.md`. Package policy: replace the active religion overhaul plus direct dependent religion patches, ship one list-specific ESL-first compatibility patch with minimal masters, avoid direct list-plugin edits, keep core PDV vanilla-plus, use Requiem/RFTI outputs as author-regenerated list artifacts, and keep public support claims blocked until maintainer inclusion/support status.
- **Phase 17 decay bridge runtime closeout (2026-05-28):** Phase 17 is runtime-proven. Proof passed grace no-op (`20.00 -> 20.00`), eligible tick (`20.00 -> 19.50`), same-day guard (`19.50` held), broad worship reduced decay (`20.00 -> 19.90`), active-patron skip, non-patron drift while Kyne stayed protected, Devoted floor (`50.00 -> 10.00`), and Champion floor (`150.00 -> 50.00`). Regression proof confirmed broad worship suppresses Phase 16 neglect (`count=0; kyneSpell=0`) and active Kyne still applies targeted neglect (`count=1; active=Kyne; kyneSpell=1`). Runtime exposed two real fixes now live in `PDV__ManagerQuest`: fresh-save debug eligibility must not be blocked by negative proof timestamps, and tier floors must persist via `PDV.PassiveDecayFloor` instead of recalculating downward from current piety each day. Full bridge ladder is clean except expected `SEQ freshness`: `node .\tools\pdv_verify.mjs --strict-phase16 --strict-phase17 --strict-phase18 --strict-nord --strict-phase13 --strict-phase14 --strict-phase15 --json` => `FAIL=0, WARN=1, PASS=1155, INFO=29`.
- **Phase 18A/B status surface and Nord pilot scaffold (2026-05-28):** Gate A is source/readback implemented: `PDV_MCM` now opens on a small Player page, gates numeric Status/Debug behind `StorageUtil` key `PDV.UI.DeveloperOptions`, and exposes Survey Devotion without piety numbers. `PDV__ManagerQuest` auto-grants `PDV_SPEL_SurveyDevotion`, owns thematic status APIs, and suppresses Nord commitment offers/contextual favors while vampire rupture is active; cure restores access while keeping `PDV.Nord.VampireScar`. `tools/pdv-phase18-author --create-missing` created/wired `PDV_SPEL_SurveyDevotion`, `PDV_MGEF_SurveyDevotion`, and the three Nord curse messages with a backup under `Backups\phase18\`. `tools/pdv_verify.mjs --strict-phase18 --strict-nord --strict-phase17 --strict-phase13 --strict-phase14 --strict-phase15 --strict-phase16` is clean except expected `SEQ freshness` (`FAIL=0, WARN=1, PASS=1155, INFO=29`). Boundary: Froki/Heimskr/Andurs/Aela dialogue remains manual CK work per `references/authoring/PDV_Phase18_StatusNord_Runbook.md`; the manifest now locks branch/topic/INFO hints plus the runtime matrix for Player page, Developer Options, Survey broad/focused states, Hircine/werewolf, vampire suppression/cure scar, save/load, and per-speaker positive/negative dialogue proof. Phase 18 runtime proof and SEQ refresh are still required before marking Nord complete.
- **Phase 13 runtime closeout and hunt-rite cadence lesson (2026-05-28):** The final Hircine/Nord runtime pass now closes Phase 13. The live Debug page proved the negative gate (early hunt rites add signals/stigma but no piety), the positive gate (third qualifying rite on a new in-game day opens Hircine piety), Seeker and Devoted price activation, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path. Durable cadence lesson: `HandleHircineHuntRite()` uses the shared daily repeat multiplier before the pilot records stigma or piety, so same-day rites scale at `1.0`, `0.7`, `0.49`, and can reach `sig=3` while still leaving `p=5.88`, `tier=0`, and `price=None`; counted proof for Seeker must use one rite per in-game day. This supersedes the earlier same-day status correction that still treated Phase 13 as open.
- **Phase 14-16 runtime closeout and Hircine status correction (2026-05-28):** Fresh-save runtime proof on the live Debug page closed the generic Phase 14-16 seams. Kyne now proves the generic formal-offer flow end to end: seed/evaluate, `Not Yet` decline (`7` days, no rupture), `Refuse` (`14` days, rupture), `Accept`, and accepted-patron persistence. The shared `PDV_CurseState` seam now has live werewolf/vampire/none runtime proof, and the same Papyrus log shows `HircinePilot: Curse entry recorded for Hircine.` plus `HircinePilot: Werewolf cure recorded for Hircine.` The generic neglect seam now proves active-Kyne low-piety selection plus broad-worship suppression clearing the active neglect set on re-evaluation. Durable workflow lesson: after recompiling `PDV__ManagerQuest` or `PDV_MCM`, a main-menu reload was not enough to trust the new manager behavior; a full Skyrim restart was required before the live script instance matched the new `.pex`. Durable debug-surface lesson: `Reset commitment state` intentionally clears offer bookkeeping, rupture, cooldown, and seeded signal days, but it does not reset deity piety or silently clear an already accepted active patron.
- **Tooling harvest rule (2026-05-24):** After doing a new kind of PDV work, review the work while it is still fresh and ask whether the next pass should be easier, safer, or more repeatable. If the pain point is manual, fragile, repeated, easy to misread, or easy to forget, harvest it into the smallest durable surface that fits: verifier coverage, an authoring helper, a manifest, a checklist, a local skill, or living docs. Rationale: Phase 7/8/9 work repeatedly improved after runtime proof exposed missing verifier checks, helper limits, or manual CK/xEdit friction; making that review explicit keeps future phases from rediscovering the same workflow gaps.
- **Phase 11 runtime proof closeout (2026-05-26):** The CK-safe Arngeir/Kynareth recognition pilot is runtime-proven. The saved ESP contains the PDV dialogue branch/topic plus CK-authored unnamed Topic Info; verifier readback accepts the unnamed `INFO` by topic, Arngeir speaker, prompt, recognition line, and the Arngeir/Nord/Kyne/Champion conditions. Runtime proof passed for the Nord/Kyne Champion positive, non-Nord negative, wrong active deity negative, below-Champion negative, and save/load sanity. SEQ was refreshed and the full strict packet gate is clean at `PASS=908, INFO=28`, with no `FAIL`, `WARN`, or `TODO`.
- **Khajiit/commitment/neglect runtime closeout (2026-05-25):** Runtime proof completed for Khajiit focused emphasis, Kyne commitment, and Kyne neglect/decay. Khajiit road-home cadence produced Khenarthi focus, moon observance switched focus to Azurah, and save/load persistence held. Kyne commitment proof created a pending offer from two positive signal days, proved `Not Yet`, `Refuse`, and `Accept`, and confirmed active Kyne patron persistence after reload. Kyne neglect/decay proof passed the 3-day grace window, one post-grace decay tick, no same-day second tick, low-piety neglect spell application, and spell removal after piety recovery. Final full strict gate is clean at `PASS=898, INFO=29`, with no `FAIL`, `WARN`, or `TODO`. Generated Arngeir dialogue records remain removed after the CTD and Phase 11 is prep-only until rebuilt through a CK-safe path.
- **Phase 11 fail-closed helper guard (2026-05-25):** Promoted the Phase 9/next-packet branch into `main`, then verified the promoted full packet baseline at `PASS=898, INFO=29`. `tools/pdv-next-packet-author` no longer regenerates the removed Arngeir `DLBR`/`DIAL`/`INFO` records; it fails closed and leaves Phase 11 dialogue to CK-safe authoring. The Phase 11 manifest now names the manual CK-only branch, topic, info, conditions, recognition line, and SEQ refresh packet expected before strict readback and runtime proof.
- **Phase 12 helper-led record creation (2026-05-26):** `tools/pdv-phase12-author` now supports `--create-missing` and can author the tracked Phase 12 packet directly into `PlayerDevotion_Framework.esp`: `11` favor-family `KYWD`, `14` favor `MGEF`, `14` favor `SPEL`, `PDV_State_NordPantheonBaseline` when absent, `PDV_StateTrack` attachment, and `PDV__ManagerQuest` property wiring. The manifest and runbook now treat helper-led creation as the normal path and manual CK/xEdit shells as fallback-only. The live write created a timestamped backup under `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase12\`; `--strict-phase12` is clean and the full upstream strict ladder is `FAIL=0` with only the expected post-write `SEQ freshness` warning remaining until SEQ refresh.
- **Phase 10 Dunmer substrate runtime closeout (2026-05-24):** Phase 10 is runtime-proven as a proof-graduation slice, not a content expansion. A fresh Dunmer baseline showed no active patron piety and `DunmerAncestor=metric=0.000000; tier=0; prayers=0; homes=0`. The private/home shrine proof surface routed through route `31` and moved the substrate to `metric=8.000000; tier=1; prayers=0; homes=1`; after the shared daily gate cleared, the portable shrine proof surface routed through route `30` and moved it to `metric=13.000000; tier=1; prayers=1; homes=1`. Patron piety remained separate, save/load persistence passed, and the strict gate is clean at `PASS=847, WARN=0, FAIL=0, INFO=28`. The next-packet helper later corrected the live record drift by keeping private/home on `PDV.Signal.DunmerHome.Activator`, moving portable to `PDV.Signal.DunmerPortableShrine.Activator`, and adding strict verifier coverage for distinct Phase 10 cooldown keys.
- **Phase 10/11 doc-grilled handoff (2026-05-24):** Phase 10/11 are subsystem labels, but `PDV_Architecture_v3.md` Section 21.5 remains the execution-order authority. Phase 10 proceeds as Dunmer ancestor substrate proof graduation, reusing the already proven portable/private shrine ACTI surfaces and requiring evidence that substrate progress stays separate from patron piety. Phase 11 D-10 is resolved to an Arngeir/Kynareth recognition pilot gated by Nord origin, Kyne active deity, Champion tier, and Arngeir as speaker; live dialogue implementation is prep-only again after the generated-record CTD remediation. Rationale: this preserves the reduced Pattern Proving order while letting verifier/docs prep remove ambiguity before the privilege work starts.
- **CKRA GLOB duplicate-create proof and CK UX lesson (2026-05-23):** `C:\Users\Admin\Documents\ckra-native` now has one proof-ledger-supported CKPE authoring surface: `glob.duplicate_create` for disposable generated proof plugins. The proven product path duplicates `PDV_GLO_ActivePiety` through CK's Object Window duplicate command, mutates the duplicate GLOB FNAM/FLTV payload from float `0` to short `1`, posts CK's native save command, reads the saved ESP back directly, and promotes only GLOB duplicate-create in the generated capability matrix. Durable user-experience lesson: CK's visible state is load-bearing. Plain `WM_COMMAND` replay failed until the automation matched the human right-click context-menu path closely enough: active plugin, Object Window list focus, selected source row matching the explicit source, popup observation, and main-thread pumping. Durable lower-layer lesson: in-memory mutation is not product proof until CK save and direct filesystem readback prove the active plugin contains the intended record. This does not close any PDV gameplay phase and does not prove generic `createRecord`, quest/message/activator/FormList creation, VMAD array writes, Story Manager authoring, alias creation, or source-plugin promotion.
- **Phase 8 runtime proof closeout and overlay lesson (2026-05-21):** Phase 8 is now fully runtime-proven on an Imperial save. The ConcordatStanding track passed baseline raw-value movement, pending transition persistence/cancel, 3-day lock-in commit, committed-state multiplier readback, extreme-band inward-halving while locked, save/load persistence, gate unlock, and 3-day exit back to `PublicCompliant`. Durable implementation lesson: the generated `PDV_Phase8ConcordatTalosOverlay.esp` was not a safe steady-state runtime patch because a partial VMAD override could win with blank/default Talos script values (`DeityName` empty, `DeityIndex = 0`). The live fix is manager-owned runtime wiring plus save-healing in `PDV__ManagerQuest` (`EnsurePhase8RuntimeWiring()` and `EnsureTalosRuntimeIdentity()`), while the strict Phase 8 closeout gate stays clean at `FAIL=0, WARN=0, TODO=0, PASS=642, INFO=28`.
- **Phase 9 Bosmer source/tooling/runtime closeout (2026-05-21 through 2026-05-24):** The shared `PDV_StateTrack` transition contract is now live in source with offered state, pending state, three evidence-day windows, refusal/lockout handling, and explicit confirm/cancel APIs. Bosmer is the first consumer: `PDV__ManagerQuest` now owns a post-startup Bosmer path chooser, Bosmer-specific dawn suggestion evaluation, PactBound/GreenPactCompliance/LapsedFromPact handling, path-specific foreground patron switching, and a shared confirmation-rite route through EventBus/receiver scripts. `PDV_Deity_Yffre`, `PDV_Deity_Zen`, and `PDV_Deity_BaanDar` compile and have live framework record/property readback for path eligibility, while `tools/pdv_verify.mjs --strict-phase9` gates the Bosmer state-track contract, manager wiring, deity eligibility properties, messages, and tracked proof-surface editor IDs. The five manual proof REFRs read back with `tools/pdv-phase9-author -- --check-placements`: `PDV_REFR_BosmerLivingStorySignal`, `PDV_REFR_BosmerExchangeSignal`, `PDV_REFR_BosmerBanditRoadSignal`, `PDV_REFR_BosmerPactPositiveSignal`, and `PDV_REFR_StateTransitionConfirmRite`. Counted runtime proof passed for all five proof-surface routes, Living Story/Exchange/Bandit Road/Old Contract offers, confirmation-rite switching, Old Contract re-entry, PactBound/compliance separation, forced reckoning `Renounce`, forced reckoning `Recommit`, and save/load persistence. Runtime proof surfaced and fixed a real state-track bug: Old Contract re-entry required three Pact-positive evidence days, but the original tracker only retained two; `PDV_StateTrack` now retains `LatestDay`, `PreviousDay`, and `ThirdDay`. Compile lesson: from sandboxed agent sessions, PapyrusCompiler may fail before syntax analysis with `Access to the path ... .pas is denied`; rerun outside the sandbox to let it write temporary compiler files in the MO2 mod folder.

### Archived decisions

Older entries are archived in `archive/PDV_DecisionsLog_Archive_2026-05.md`,
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
