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
| `tools/pdv_verify.mjs` | Read-only Node/Mutagen verifier for PDV's Anvil MO2 setup | Checking CK wiring, script freshness, SEQ state, MO2 profile state, and Phase 3 readiness |
| `tools/skyui_compile_shim/*.psc` | Minimal compile-only SkyUI base-class shims used by `pdv_compile.mjs` | Compiling `PDV_MCM.psc` without inheriting noisy third-party MCM source overrides |
| `tools/pdv_author.mjs` | Safe overlay-patch authoring helper built on the local Mutagen bridge | Inspecting existing-record wiring, planning reversible ESP overlay patches, and scripting supported VMAD/FormList edits without mutating the framework ESP in place |
| `tools/pdv_extract_vanilla_gameplay_refs.mjs` | Read-only Mutagen extraction helper for vanilla/DLC gameplay reference tables | Refreshing generated `references/vanilla-gameplay/extracted/` CSVs before building signal matrices, patcher rules, or compatibility dossiers |
| `references/authoring/PDV_MCMPropertyWiring.manifest.json` | Manifest-driven batch overlay target for PDV_MCM VMAD property wiring | Regenerating one canonical MCM property-wiring overlay instead of accumulating one-off property patches |
| `references/authoring/PDV_PreflightRouterServices.manifest.json` | Manifest-driven V3 Preflight router-service overlay target | Regenerating the reversible `PDV_PreflightRouterServicesOverlay.esp` canary that co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` |
| `PDV_Architecture_v2.md` | Full v2 architecture spec ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â data model, quest topology, phase plan, stance matrix | Phase planning, writing new scripts, understanding the deity/origin system |
| `PDV_Architecture_v3.md` | Forward architecture and roadmap for everything after the proven Phase 4/5/6 baseline | Planning v3 preflight, structural skeleton, beta gates, launch readiness, and post-v2 subsystem work |
| `PDV_BetaTesterBrief.md` | External-facing beta tester brief; not architecture authority | Preparing trusted testers, explaining beta expectations, and framing launch readiness in player-facing terms |
| `PDV_Phase1_ManualSteps.md` | CK step-by-step for Phase 1 globals and script wiring | Returning to CK work after a break |
| `archive/completed-phase-docs-2026-05-16/README.md` | Index for completed phase walkthroughs and historical planning docs | Finding archived Phase 2/3/4/5/6 CK guides and earlier planning notes |
| `PDV_SkyrimConsoleReference.md` | UESP-sourced console command reference (source of truth) | Any in-game testing or debugging |
| `references/PDV_Anvil_MO2_MCP_Intake.md` | Codex-facing intake of the Anvil MO2 MCP plugin, tool surface, optional binaries, and local setup status | Using or troubleshooting `mo2_*` tools from Codex |
| `references/PAPYRUS_KNOWLEDGE_INTAKE.md` | Papyrus API/reference strategy, source-layer cautions, and BellCube/SKSE intake notes | Any Papyrus scripting, API lookup, or tooling/ref-generation planning |
| `references/PDV_RaceArchitecture_DesignReference.md` | Living race architecture reference for theology, curse handling, reward contract, and quest weighting | Resolving per-race design, locking theology decisions, planning future signal matrices |
| `race-sheets/*.md` | Race-by-race player-facing design sheets plus the overview | Keeping readable race gameplay/design summaries in sync with the locked architecture reference |
| `references/vanilla-gameplay/` | Living gameplay mechanics and immersive UX reference backbone | Looking up vanilla Skyrim mechanics, CK signal surfaces, source-backed gameplay tables, or player-experience lessons for PDV design |
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
      PDV_PlayerEvents.psc
      PDV_MCM.psc
      PDV__MainQuest.psc
```

Quest scripts (current):
- `PDV__MainQuest.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â RunOnce bootstrap quest. **Phase 4 script complete on disk:** verifies PapyrusUtil and defers origin capture to the player-alias ingress instead of forcing `PDV_Origin.InitializeOrigin()` during `OnInit()`.
- `PDV_Origin.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (Phase 4)** One-shot origin helper. Detects and normalizes player origin race, treats vanilla vampire races as their birth race, defers while only a temporary beast-form race is visible, treats the first Nord capture as provisional to avoid placeholder new-game race reads locking too early, writes `PDV_GLO_OriginRace`, and seeds the current proof-slice deity ledgers.
- `PDV__ManagerQuest.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 4 script complete and framework-wired:** stance-aware `AwardPiety()`, non-recursive rivalry plumbing, patron-only boon handling, FormList-backed `ProcessDawn`, poll-based debug harness, and `PDV_GLO_PatronDeity` wired directly on the framework ESP after the xEdit merge-back.
- `PDV_DeityBase.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 4 refactor complete on disk:** race-keyed stance properties, rivalry metadata, and cumulative patron-only boon sync. Replaces the Phase 2 origin-multiplier floats.
- `PDV_Deity_Kyne.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **Phase 4 proof slice on disk:** same Kyne rubric as before, now expected to use the simple Nord-native / everyone-else-foreign stance row plus CK-authored boon spells.
- `PDV_Deity_Talos.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (coupled follow-on slice)** First hostile-path proof deity. Curated Talos-facing defiance signals only; Altmer hostility should rival Auri-El one-way.
- `PDV_Deity_AuriEl.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (coupled follow-on slice)** Minimum viable Altmer foundation deity and real rivalry target for Talos. Seeded for Altmer, but still follows patron-only boon rules.
- `PDV_EventTypes.psc` - **NEW (V3 Preflight script slice)** Central event and attribution constant owner. Compiles cleanly; framework-owned record wiring is live on `PlayerDevotion_Framework.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact.
- `PDV_EventBus.psc` - **NEW (V3 Preflight script slice)** Dispatch service for validated event payloads. Direct-player kill scoring remains behavior-compatible with v2; non-direct attribution is carried but non-scoring until later phases. Compiles cleanly; framework-owned record wiring is live on `PlayerDevotion_Framework.esp`, and the reversible `PDV_PreflightRouterServicesOverlay.esp` remains as a historical canary artifact.
- `PDV_PlayerEvents.psc` - **NEW (V3 pilot-first ingress slice)** Player `ReferenceAlias` event surface for sleep/load registration and routed non-kill proving signals. Source and `.pex` are live, the `PDV_Player` alias is now attached manually on `PDV__ManagerQuest`, and Khajiit sleep ingress is runtime-proven through EventBus/manager/substrate. Safe authoring still cannot mint new quest aliases, so future alias additions remain manual CK/xEdit work.
- `PDV_MCM.psc` ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â **NEW (Phase 5 dev slice)** SkyUI `Status` + `Debug` surface only. Roster-driven, OID-backed, framework-attached, and explicitly not the final player-facing patron/tuning UX.
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
```

`pdv_compile.mjs` compiles active PDV scripts whose `.pex` output is missing or older than source. The active set now includes the proven v2 scripts plus the V3 Preflight/EventBus surface and first alias-side ingress script (`PDV_EventTypes`, `PDV_EventBus`, and `PDV_PlayerEvents`). `--script` targets one or more scripts, and `--all` rebuilds the active script set. It spawns `PapyrusCompiler.exe` directly with canonical CLI args (`<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`), not `ScriptCompile.bat`, PowerShell, or the CK menu. Papyrus warnings are treated as failures by default. After a successful compile, the compiler runs `pdv_verify.mjs` unless `--skip-verify` is supplied.

```text
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_verify.mjs --strict-phase3
node .\tools\pdv_verify.mjs --strict-preflight
node .\tools\pdv_verify.mjs --strict-pattern-proving
node .\tools\pdv_author.mjs status phase4
node .\tools\pdv_author.mjs plan phase4
node .\tools\pdv_author.mjs apply phase4 --output PDV_Author_phase4.esp
node .\tools\pdv_author.mjs plan preflight-router-services
node .\tools\pdv_author.mjs apply preflight-router-services
```

 The verifier checks the Anvil/Devotion paths, reads `PlayerDevotion_Framework.esp` through the Anvil MO2 MCP Mutagen bridge, validates the current Phase 4 baseline records/properties plus the Talos/Auri-El follow-on records, checks Phase 3 receiver/router wiring, checks script source/pex freshness, detects CK output shadow files, checks SEQ state, and confirms the active MO2 profile/load order. It now explicitly fails or warns when the live ESP is missing `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, `PDV_Deity_Talos`, `PDV_Deity_AuriEl`, expected stance rows, Talos rivalry wiring, deity boon assignments, or the tracked Pattern Proving ingress source surface (`PDV_PlayerEvents`, routed EventBus helpers, and new event constants). V3 Preflight source/pex readiness is verifier-covered; the framework-owned CK/xEdit records (`PDV_GLO_PatronState`, `PDV_EventTypes`, `PDV_EventBus`) report as INFO in default mode, and `--strict-preflight` promotes those outstanding Preflight gaps to FAIL for gate-close runs. `--strict-pattern-proving` now covers the first pilot-first non-kill ingress source contract as well as the proven Pattern Proving framework surface. The verifier also reads back the tracked `PDV_PreflightRouterServicesOverlay.esp` canary when present. It is diagnostic only and must not write to the ESP or MO2 profile files.

 `pdv_author.mjs` is the safe authoring companion to that loop. It inspects the live framework ESP through the same Mutagen bridge, then emits a **new overlay patch plugin** into the `Devotion` mod when asked to apply changes. Current supported writes are existing-record script attachment, scalar/object VMAD properties, and FormList membership. It does **not** mint new records, edit VMAD array properties such as `RivalDeities`, or overwrite `PlayerDevotion_Framework.esp` in place. Generated patches must keep `Skyrim.esm` as the first master when using extended FormID ranges; do not manually insert masters into an existing patch without remapping FormIDs.

Toolchain usage rules:
- After editing any PDV `.psc`, run `node .\tools\pdv_compile.mjs` or `node .\tools\pdv_compile.mjs --script <ScriptName>`.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3` or compile with `node .\tools\pdv_compile.mjs --strict-phase3`.
- Before declaring V3 Preflight complete, run `node .\tools\pdv_verify.mjs --strict-preflight` (or compile with `node .\tools\pdv_compile.mjs --strict-preflight`) and resolve all FAILs.
- Before declaring a Pattern Proving checkpoint complete, run `node .\tools\pdv_verify.mjs --strict-pattern-proving` (or compile with `node .\tools\pdv_compile.mjs --strict-pattern-proving`) and treat duplicate-VMAD results as explicit waivers until the framework record attachments are manually consolidated.

---

## Papyrus Guidance

Before writing or reviewing Papyrus, read `references/PAPYRUS_KNOWLEDGE_INTAKE.md` when the task touches API usage, compiler/import setup, or reference-generation/tooling decisions.

Working rules drawn from that intake:

- **Do not invent Papyrus APIs.** If a function signature is not verified from shipped `.psc` source, CK Wiki, SKSE source, or an explicitly cited plugin source, treat it as unknown.
- **Identify the API layer being used.** Distinguish vanilla Papyrus, SKSE extensions, and plugin-provided APIs such as PapyrusUtil, JContainers, RaceMenu, or MCM Helper.
- **Assume symbol gaps until proven otherwise.** Missing imports or missing source roots are a more likely cause than "Papyrus is weird"; verify the compiler import chain before changing logic.
- **Compile-verified beats plausible.** Prefer fixes confirmed by actual compile output over stylistically plausible Papyrus guesses.
- **Be honest about coverage limits.** `.pex`-only mods are out of scope unless source exists; BellCube/papyrus-index is curated and useful, but not exhaustive.
- **Use Skyrim-valid test paths.** For in-game testing, rely on commands documented in `PDV_SkyrimConsoleReference.md` and CK-backed harnesses such as quest stages or properties, not Fallout-only shortcuts.
- **Respect Papyrus parser limits.** Use only valid string escapes (`\\`, `\"`), keep `{...}` docstrings directly after declarations, and do not assume helpers such as `StringUtil.Replace` exist.
- **Respect Papyrus language limits.** No ternary operator, no string interpolation, no string `+=`, no `Math.max`/`Math.min`, no variable-sized arrays, arrays cap at 128, and chained casts should be split into explicit intermediate variables.
- **Avoid save-baked false positives.** When script behavior looks impossible after an edit, retest from a new game or main-menu `coc qasmoke` path before changing architecture.
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
content-rich 1.0 launch readiness. `PDV_BetaTesterBrief.md` is tester-facing
communication only; it must defer to v3 when architecture or roadmap details
conflict.

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

Pull from `skyrim-gods-reference.jsx` and `tamriel-daily-worship-4e201.html` before writing any race content. Key things to remember:

- **Khajiit** worship the lunar lattice (Riddle'Thar), not generic Nine Divines. Moon phase determines identity.
- **Dunmer** religious life centres on named ancestors, not named gods. The household ash-shrine outranks any temple.
- **Orcs** treat craft as prayer. Malacath is not petitioned ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â he judges by observing strength and labor.
- **Argonians** lose their core religious infrastructure (the Hist) when outside Black Marsh. Design their triggers around adaptation and absence, not normal worship.
- **Bosmer** Green Pact dietary observance (no plant matter) creates daily friction in Skyrim that is itself a mechanic opportunity.
- **Redguard** theology is a survival narrative. Their recent military victory over the Dominion is a live theological fact in 4E 201.
- **Daedric Prince** names are largely consistent across all cultures ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â use `skyrim-gods-reference.jsx` for the few exceptions (e.g. Azurah, Boethra, Sheggorath for Khajiit).

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
[~] V3 Pattern Proving normal-play ingress closeout
      - `PDV_PlayerEvents.psc` source and `.pex` are now live, and manager/EventBus pilot routes compile cleanly
      - latest strict gate is clean on `FAIL=0, TODO=0` (`PASS=458, WARN=2, INFO=28` at 2026-05-18 16:47 AEST)
      - remaining warnings are now `PDV_MCM` duplicate VMAD attachment plus stale SEQ freshness, not manager wiring failure
      - Imperial Concordat and the counted Khajiit emergent/moon-cycle normal-play sleep ingress are proven in game on 2026-05-18
      - live `PDV_Player` alias wiring on `PDV__ManagerQuest` is complete; the remaining gap is other normal-play triggers, not the Khajiit sleep path
      - Dunmer portable shrine/home bonus, Bosmer Green Pact, and Hircine hunt rite still need non-debug in-game trigger proof before this tranche can close
[ ] Debug spell working
[ ] Nord module complete
```

---

## Decisions Log

*Append here when architectural choices are made. Mirror significant entries in PDV_MOD_SETUP.md.*

- **Framework vs. monolithic:** One core ESP owns the quest spine and globals. Nine race ESPs patch in as modules.
- **Variable storage (2026-05-09, revised 2026-05-10):** StorageUtil (PapyrusUtil SE) is the source of truth for all per-deity piety/tier values, keyed by deity FormID. Three mirror GlobalVariables (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) shadow the active patron's values for vanilla CK Condition reads. Mirrors are write-only caches ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â always write through `AwardPiety`/`RecomputeTier`, never directly to the globals. `PDV_GLO_DevotionLevel` and the three buckets are gone.
- **Dawn detection:** `RegisterForUpdateGameTime(1.0)` with hour-window check ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â chosen over Story Manager dawn event for reliability.
- **Bootstrap / Manager quest split (2026-05-09):** `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (Start-Game-Enabled runtime). Runtime owns the mirror globals API and will own the dawn consolidation loop in Phase 2+.
- **Naming taxonomy (2026-05-09):** Internal/machinery records prefixed `PDV__X`; runtime Globals prefixed `PDV_GLO_X`; internal/system Globals (config, debug, dev) prefixed `PDV_GLO__X`. Full taxonomy in `PDV_MOD_SETUP.md` ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ EditorID Prefix Convention.
- **PapyrusUtil SE (2026-05-10):** SKSE DLL plugin ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â no ESP master, no xEdit step. Call `StorageUtil.*` directly in script; DLL resolves at runtime. Never add as a plugin master.
- **CK compiler toolchain (2026-05-10, revised 2026-05-12):** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output goes to `Scripts\`. For terminal/Codex work, use `tools\pdv_compile.mjs`, which spawns `PapyrusCompiler.exe` directly with `<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`. CK compile (Ctrl+F7) remains valid for interactive CK work. `compile.ps1` / `skyrimse.ppj` in the mod folder and Bethesda's shipped `ScriptCompile.bat` are stale/legacy artifacts and should not be used.
- **Phase 1 complete (2026-05-10):** Mirror globals declared in CK, verified in-game with `GetGlobalValue`. `PDV__ManagerQuest` refactored with `AwardPiety`/`GetPiety`/`RecomputeTier`/`RefreshPatronMirrors` API. Console command source of truth: `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed commands: `GetGlobalValue <var>` (read), `set <var> to <value>` (write).
- **Deity-as-Quest model (2026-05-10):** Each deity is a standalone persistent quest form extending PDV_DeityBase, not hardcoded rules in the manager. Allows N deities to be added via FormList membership alone; no manager changes required. Scaling proof arrives in Phase 6 when Talos is duplicated. Scripts: PDV_DeityBase (contract), PDV_Deity_Kyne (first implementation), PDV__ManagerQuest (ProcessDawn loop), all complete and ready for CK wiring.
- **Phase 2 script delivery (2026-05-10):** PDV_DeityBase.psc, PDV_Deity_Kyne.psc, and updated PDV__ManagerQuest.psc created and ready to compile. Historical walkthrough: `archive/completed-phase-docs-2026-05-16/PDV_Phase2_CK_Steps.md`. Historical summary: `archive/completed-phase-docs-2026-05-16/PDV_Phase2_Summary.md`. All three scripts follow project conventions (PDV_ prefix, internal __ convention, full documentation headers, lore alignment via deity properties).
- **Phase 2 functional alignment (2026-05-11):** `PDV__ManagerQuest` now uses per-deity StorageUtil keys (`PDV.Piety`, `PDV.PietyToday`, `PDV.Tier`, `PDV.LastTierChange`) as the runtime source of truth. `AwardPiety` writes daily scratch only, `ProcessDawn` consolidates scratch into persistent piety, tier recompute now reads each deity's own thresholds, patron switching preserves inactive deity ledgers, and the debug global is wired by property rather than hardcoded FormID lookup.
- **Phase 3 preflight (2026-05-11):** `PDV_ActionRouter` should be a persistent service quest, not the quest directly started by Story Manager. Kill Actor capture should use a small non-Start-Game-Enabled receiver quest (`PDV__SM_KillActor`) with `OnStoryKillActor(...)`; the receiver calls the router and then stops/resets. PDV Story Manager nodes must use `Shares Event`. The first slice is player-only kill capture; follower attribution, traps, non-hostile kills, and wider creature taxonomy are deferred until the event path is proven.
- **Phase 3 script implementation (2026-05-11, completed 2026-05-14):** `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` were added and compiled cleanly. Router validates direct player kills, requires hostility evidence, classifies `ActorTypeNPC` as humanoid and `ActorTypeAnimal` as beast, then writes deity deltas through `PDV__ManagerQuest.AwardPiety()` only. CK quest creation, property wiring, Story Manager node setup with `Shares Event`, and SEQ generation are complete. Runtime verification now covers the hostile bandit route (`event 2`, Kyne `+0.5`), hostile wolf route (`event 1`, Kyne `-3.0`), neutral-kill rejection, rapid dual-kill accumulation, and dawn consolidation/clamping through the intended scratch-to-persistent path.
- **Local Codex skills (2026-05-11):** Updated/rebuilt `pdv-doc-sync` to use `AGENTS.md` rather than `CLAUDE.md` as canonical, and added `pdv-papyrus-ck` for PDV Papyrus/CKPE compile, property wiring, Story Manager, and console-test guardrails. Both are packaged as `.skill` files and installed under `C:\Users\Admin\.codex\skills`.
- **PDV local toolchain (2026-05-12):** Added `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs`. The compiler directly spawns the real .NET CLI `PapyrusCompiler.exe` with short canonical flags (`-f`, `-i`, `-o`), compiles stale/all/targeted active PDV scripts into `Devotion\Scripts`, treats warnings as failures, and runs the verifier after successful compiles. It does not use `ScriptCompile.bat`, PowerShell, or the CK compile menu. The verifier uses the Anvil MO2 MCP Mutagen bridge plus filesystem/profile checks to catch CK wiring drift, stale scripts, SEQ issues, CK output shadow files, and Phase 3 Story Manager readiness. Default verifier mode treats pending Phase 3 records as TODO; `--strict-phase3` promotes those TODOs to failures.
- **PDV overlay authoring tool (2026-05-15, revised 2026-05-16):** Added `tools/pdv_author.mjs` as the safe automation path for CK-adjacent ESP wiring. It reads `PlayerDevotion_Framework.esp` through the same local Mutagen bridge as the verifier, then writes **reversible overlay patch plugins** into the `Devotion` mod rather than mutating the framework ESP in place. v1 scope is intentionally narrow: existing-record scalar/object VMAD properties and FormList membership only. New records, VMAD array properties such as `RivalDeities`, and Story Manager tree authoring remain manual CK/xEdit work. The tool now supports tracked JSON manifests under `references/authoring/`; `mcm-property-wiring` is the first manifest-driven batch overlay and replaces the earlier per-property MCM one-off patch workflow. After the merge-back investigation, the tool now warns if a generated patch's first master is not `Skyrim.esm`; do not manually insert `Skyrim.esm` into an existing patch without remapping FormIDs.
- **Temporary overlay workaround retired (2026-05-16):** `PDV_ManagerPatronWirePatch.esp` and `PDV_MCMWirePatch.esp` were temporary rescue artifacts for CK instability. Their VMAD deltas have been merged into `PlayerDevotion_Framework.esp`: the manager now owns `PDV_GLO_PatronDeity` directly, and `PDV_MCM` is script-attached with required properties directly on the framework record. Both overlays are unticked in the `Devotion Dev` profile and must not be treated as steady-state runtime requirements.
- **Phase 5 in-game proof and ReShade caveat (2026-05-16):** The first MCM slice is now proven in game on the live Kyne/Talos/Auri-El roster: `PlayerDevotion` registers in SkyUI, `Status` and `Debug` load, roster iteration works, and debug patron override can switch to Auri-El. A separate native crash was isolated to `D:\Wabbajack\modlists\Anvil\Stock Game\ReShade64.dll`; two crash logs showed repeated `ReShade64.dll` + `WS2_32.dll` + `webio.dll` frames while Papyrus showed no PDV MCM fault. Temporary smoke-test workaround: rename `ReShade64.dll` out of the Stock Game root before launching.
- **Recovery artifacts archived (2026-05-16):** The one-off bridge experiments, merge-back helper, framework-master repair script, and generated Phase 5 working files were moved to `archive/pdv-recovery-tools-2026-05-16/`. They are historical/emergency-only and should not be treated as canonical source or normal tooling.
- **Completed phase docs archived (2026-05-16):** Finished Phase 2/3/4/5/6 walkthroughs and older planning/delivery notes now live under `archive/completed-phase-docs-2026-05-16/` to keep the project root focused on living architecture/setup/standards docs.
- **Phase 4 and Phase 6 full closeout proof (2026-05-16):** The smoke-test standard is now "full phase closeout unless explicitly narrowed." Phase 4 passed bootstrap/origin, Kyne seed, patron-only boon grant/removal, and save/load sanity. Phase 6 passed Altmer bootstrap, Auri-El seed, Talos hostile-path rise, rivalry-driven Auri-El decay across dawn consolidation, Talos boon grant, patron-only removal on swap, and save/load sanity. The test pass also drove a small debug-surface expansion: curated signal testing now has a surfaced manager/MCM helper instead of relying on an unproven console `cqf` path.
- **v3 roadmap and beta gates (2026-05-16):** `PDV_Architecture_v3.md` is now the forward architecture and roadmap source for post-v2 work. It separates structural completeness from content completeness, adds V3 Preflight and Structural Skeleton gates, and defines Technical Beta, Content-Feel Beta, and content-rich 1.0 launch readiness. `PDV_BetaTesterBrief.md` is external tester communication only and must defer to v3 for architecture truth.
- **v3 Section 24 cleanup (2026-05-16):** Resolved the tracker items already answered by the roadmap and acceleration tradeoffs: D-09, D-11, D-15, D-16, D-18, D-24, D-25, D-26, D-27, D-28, D-29, and D-32. The locked posture is structural completeness first, monolithic 1.0, strong substrates only for Khajiit/Dunmer/Argonian, shrine overlays, Tier 2 broad worship, three-option commitment offers, curse-state pressure without auto-unlocking Daedric paths, thematic UI by default, in-world patron switching, concrete pattern cloning, FormList-driven MCM order, Phase 12 stack-depth benchmarking, and documented Wintersun coexistence.
- **V3 kickoff decisions (2026-05-16):** Resolved v3 D-01 through D-08. Trinimac is Altmer-native but specialist: a martial virtue / civilisational defence / Thalmor Orthodox worship target, scaffolded in Structural Skeleton but made content-ready only when that Altmer lane is built. Orcs remain Malacath-only in normal architecture; their variation is `Stronghold`, `City`, and `Legion / service / exile` life-mode, not deity choice. Malacath is dual-coded by race; Shor/Sep/Lorkhaj/Lorkhan remain separate cultural records; missing PapyrusUtil hard-fails visibly; custom-race Imperial fallback gets a first-load notice plus MCM/status diagnostic; indirect kill attribution is payload-only until a later signal phase; crime events move to Phase 8 with the first reputation track.
- **V3 Preflight script/tooling slice (2026-05-16):** Added compile-clean `PDV_EventTypes` and `PDV_EventBus`, refactored manager dawn/gain flow into named Preflight extension slots, introduced StorageUtil-backed patron-state API with optional `PDV_GLO_PatronState` mirror, added PapyrusUtil bootstrap hard-fail, custom-race fallback diagnostic, MCM status readouts, and verifier/compiler coverage. CK/xEdit record creation and in-game smoke remain pending before V3 Preflight can be marked complete.
- **V3 Preflight reversible canary (2026-05-16):** The first CK-facing Preflight wiring lands as a reversible overlay: `references/authoring/PDV_PreflightRouterServices.manifest.json` now drives `PDV_PreflightRouterServicesOverlay.esp`, which co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` and points the router at those services on the same quest record. Rationale: the current safe authoring path can attach scripts to existing records but cannot mint new quests/globals, so this proves the EventBus routing pattern now while keeping `PDV_GLO_PatronState` and any later merge-back/manual record creation explicit.
- **V3 Preflight gate closed (2026-05-16):** Framework-owned `PDV_GLO_PatronState`, `PDV_EventTypes`, and `PDV_EventBus` are now present and wired on `PlayerDevotion_Framework.esp`; strict preflight verifier runs clean (`FAIL=0`); and the clean-start smoke checklist A-F passed in-game (including stance-context rivalry validation and save/load sanity). The reversible preflight overlay can remain as historical artifact and stay inactive in runtime profile.
- **Schema-first authoring remains research only (2026-05-16):** The long-term idea of text-first ESP authoring via a Mutagen-backed build step is worth preserving, but it is not part of PDV's active workflow yet. Until a real build tool exists and is proven against the live framework, do not treat any YAML/TOML schema draft as authoritative project state. Current source of truth remains the living docs, PDV `.psc` source, `PlayerDevotion_Framework.esp`, `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, and supported `tools/pdv_author.mjs` manifests/overlays. Any future schema-first pass must be introduced by updating these living docs first, not by adding a parallel speculative source tree.
- **Vanilla gameplay reference backbone (2026-05-18):** Added `references/vanilla-gameplay/` as the living gameplay mechanics and immersive UX reference set. It is table-first and source-attributed, covering actor values, condition functions, keywords, Story Manager events, quest/radiant cautions, factions/crime, playable race indices, blessings, diseases, magic-effect archetypes, location/world context, PDV signal hooks, and UX lessons. The reference set now includes a generated extraction pack under `references/vanilla-gameplay/extracted/`, a reusable extractor (`tools/pdv_extract_vanilla_gameplay_refs.mjs`), quest/location/semantic crosswalks, hook recipe cards, compatibility dossiers, and a reward/effect palette. Design posture locked by this pass: PDV should stay quiet, event-led, lore-reactive, recoverable, and vanilla-plus; avoid raw skill/craft scoring, notification spam, hard chore loops, runtime FormList ordering dependencies, and broad GMST-style edits.
- **Gameplay posture lock (2026-05-18):** `PDV_Architecture_v3.md` now treats the vanilla-gameplay posture as architecture truth, not just reference guidance. Quiet/event-led/recoverable/vanilla-plus play is a load-bearing rule for Phase 7+, and the forward architecture now explicitly rejects raw skill-XP scoring, raw craft-count scoring, routine notification spam, and chore-loop religion as default PDV design shapes.
- **V3 Pattern Proving smoke reuse and verifier waiver boundary (2026-05-18):** The current kickoff pass should reuse the smoke already completed on May 16, 2026 and May 18, 2026 instead of reflexively re-running it. The latest strict verifier run (`node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton --strict-pattern-proving --json`) stayed clean on `FAIL=0, TODO=0` with `PASS=458, WARN=2, INFO=28` at 2026-05-18 16:47 AEST. Remaining warnings are now limited to the known `PDV_MCM` duplicate VMAD attachment plus stale SEQ freshness; manager wiring is no longer part of the warning set. Treat the duplicate-VMAD result as an explicit waiver item until manual CK/xEdit consolidation, and treat the SEQ result as a normal post-CK refresh reminder rather than a Pattern Proving blocker.
- **V3 player alias ingress boundary (2026-05-18):** `PDV_PlayerEvents.psc` is now the canonical alias-side event script for sleep/load/non-kill pilot ingress, and `PDV_EventBus` remains the single non-kill route into `PDV__ManagerQuest`. The current safe authoring/tooling stack can compile and verify that source surface, but it still cannot mint quest aliases, so `PDV_Player` was attached manually in CK/xEdit and any future alias additions remain manual too.
- **Offline classification/distribution patcher direction (2026-05-18):** `PDV_Architecture_v3.md` now locks a future Mutagen-backed offline patcher as the preferred way to do KID/SPID/SkyPatcher-like classification and distribution without making KID, SPID, or SkyPatcher hard runtime dependencies solely for keyword/NPC/record distribution. The planned tool should read the resolved load order plus PDV rule manifests, then emit a visible generated patch plugin such as `PDV_ClassificationPatch.esp`. Runtime frameworks remain candidates only for behavior that cannot be baked into an ESP patch.
- **PO3 Papyrus Extender dependency and SPID deferral (2026-05-18):** PDV v3 now accepts powerofthree's Papyrus Extender as a hard runtime dependency for non-vanilla event hooks, including Address Library for SKSE Plugins and powerofthree's Tweaks as its required dependency chain. SPID remains deferred for cost-benefit review if future NPC distribution needs runtime actor-load behavior, outfit lifecycle handling, or broad dynamic injection beyond generated patches. Classification/NPC distribution stays offline patcher-first.
- **Khajiit sleep ingress proof and origin-timing fix (2026-05-18):** The live `PDV__ManagerQuest` record now contains alias `PDV_Player` with `PDV_PlayerEvents` attached and `PDV_EventBusService`, `PDV_OriginQuest`, and `PDV_GLO_DebugLevel` filled on the alias script. The actual bug was runtime timing, not missing linkage: early fresh/load paths could still see Skyrim's temporary Nord placeholder and bake `PDV_GLO_OriginRace = 0` before Khajiit settled. The fix now defers main-quest bootstrap, queues alias-side retries, and treats the first Nord read as provisional inside `PDV_Origin`. Early Khajiit sleep attempts before resetting the live runtime global should be treated as exploratory only, not counted proof; the CK global window only shows the plugin default `-1`, not the live save value. Counted proof required resetting the runtime global in-game, confirming runtime debug at `2`, and then validating the live Papyrus log under `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`, which now proves the full Khajiit sleep route: `EventBus: RouteSleepStop complete`, `Manager: Khajiit moon observance routed...`, and `KhajiitLunar: Moon observance recorded...`. Remaining boundary for next planning pass: Dunmer portable shrine/home bonus still has backend routing plus MCM/debug coverage, but no confirmed normal-play shrine/item trigger is built yet.
- **Race architecture interrogation pass (2026-05-13):** The remaining race architecture work was locked in `references/PDV_RaceArchitecture_DesignReference.md`. Imperial, Khajiit, Bosmer, Redguard, Orc, and Argonian now have explicit current-era theological models, curse behavior, and practical Skyrim-facing interpretations. Quest and faction choices were also elevated to first-class devotion signals across the locked races, with ambient behavior acting as slower background drift rather than the only source of meaning.
- **Pre-matrix reward and system contract (2026-05-13):** `references/PDV_RaceArchitecture_DesignReference.md` now defines the requirements for the race signal matrix: modest cumulative passive baseline blessings, automatic signal-triggered contextual favors, religious privileges, no activatable power kit, optional MCM, SKSE/PapyrusUtil core dependency posture, standalone core design, no new quest content for first release, signal cost classes, cadence, anti-farm rules, survival overlap, and later Requiem/survival compatibility tracking.
- **Hybrid boon policy matrix (2026-05-14):** Locked an asymmetric hybrid boon model in `references/PDV_RaceArchitecture_DesignReference.md`. Every race gets one foreground devotional layer, but only structurally layered religions keep a true persistent substrate. `Nord`, `Imperial`, `Breton`, and `Bosmer` should express most identity through privileges, contextual favors, and state tracks rather than a second passive boon layer. `Altmer`, `Redguard`, and `Orc` keep only light persistent layers. `Dunmer`, `Khajiit`, and `Argonian` keep the strongest substrates. Global rule: most races should never feel like they have more than two meaningful always-on boon families at once.
- **Daedric worship architecture baseline (2026-05-13):** Section 11 of `references/PDV_RaceArchitecture_DesignReference.md` is now locked as a Prince-first architecture. Daedric paths reuse the Tier 0-3 spine with Daedric labels, require commitment signals before real progression, use `boon / price / stigma` contracts, stay mostly event-driven, and let race modify stigma, entry threshold, interpretation, and faith friction. Native-integrated exceptions are Azura/Azurah, Boethiah/Boethra, Mephala/Mafala, and Malacath/Mauloch; Bosmer Herma-Mora is explicitly not treated as Hermaeus Mora in the Daedric layer.
- **Phase 4 matrix pass (2026-05-13):** Added `references/phase4/PDV_Phase4_MatrixScaffold.md`, `PDV_RaceSignalMatrix.csv`, `PDV_StanceMatrix.csv`, `PDV_DaedricRacePrinceMatrix.csv`, and `PDV_MatrixCrossValidation.md` as the first implementation-facing design set for Phase 4. The pass stays first-release scoped, preserves locked race-specific architecture instead of flattening to one patron model, and records intentional stance-vs-Daedric taxonomy differences rather than forcing false consistency. Mirrored copies were also published to `D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\`.
- **Phase 4 script/tooling implementation (2026-05-14):** Added `PDV_Origin.psc`, turned `PDV__MainQuest.psc` into a real bootstrap hook, refactored `PDV_DeityBase.psc` from origin multipliers to race-keyed stance properties plus rivalry metadata, and updated `PDV__ManagerQuest.psc` so positive piety writes apply stance multipliers and hostile worship can trigger non-recursive rivalry penalties. Boon behavior is now locked for this phase as **active-patron-only but cumulative by tier**. `tools/pdv_compile.mjs` now treats `PDV__MainQuest` and `PDV_Origin` as active scripts, and `tools/pdv_verify.mjs` now explicitly checks the missing Phase 4 ESP surface (`PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, Kyne stance row, Kyne boon assignments). All scripts compiled cleanly on 2026-05-14; live verifier failures now point only at still-manual CK/ESP work.
- **Coupled Talos + Auri-El script/tooling implementation (2026-05-14):** Added `PDV_Deity_Talos.psc` and `PDV_Deity_AuriEl.psc` as the first coupled hostile-path proof slice. `PDV_Origin.psc` now seeds a small generic script-constant table for Kyne, Talos, and Auri-El. `PDV__ManagerQuest.psc` now exposes `AwardCuratedSignal()` / `AwardCuratedSignalByIndex()` for curated CK-driven devotional signals, and rivalry now fires from the **written** stance-adjusted gain rather than the raw incoming delta. The first intended Talos proof is Altmer hostility against a real Auri-El ledger target, with Talos rivalry one-way to Auri-El in this pass. `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs` now treat Talos/Auri-El as required active slice scripts and records.
- **Anvil MO2 MCP Codex intake (2026-05-14, updated 2026-05-16):** Interrogated `D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp` for Codex use and documented the usable tool surface in `references/PDV_Anvil_MO2_MCP_Intake.md`. Codex config points to Anvil's dedicated endpoint `http://127.0.0.1:27016/mcp`; the server must still be started from MO2 before `mo2_*` tools appear. The plugin was adjusted to label the server generically, check Codex config on server start, use `Devotion` as the MCP output mod default, and point `tool_paths.json` at Anvil's real Papyrus compiler/source paths. `BSArch.exe` is now installed for BSA/BA2 archive tools; `nif-tool.exe` remains the only confirmed missing optional binary.
- **Prisma UI bridge scaffold (2026-05-18):** Prisma UI's C++ API header is installed as an MO2 mod and resolves through the Anvil MCP. Added `native/DevotionPrismaBridge/` as a CommonLibSSE-NG/xmake SKSE bridge scaffold, vendored `PrismaUI_API.h`, mirrored the first `PrismaUI/views/Devotion/` HTML/CSS/JS panel into the live Devotion mod, and compiled `PDV_PrismaBridge.psc` to `.pex` as the Papyrus native declaration. Visual Studio Build Tools 2022 now live at `C:\BuildTools`, portable xmake lives at `C:\Users\Admin\Documents\xmake-v3.0.8-win64\`, and the built `DevotionPrismaBridge.dll` / `.pdb` are copied into `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\`. The local vendored Prisma header is a CommonLib-compatible shim that removes `Windows.h` while preserving the installed MO2 header mod unchanged.
- **Skyrim modding lessons intake (2026-05-14):** Archived external practical lessons at `archive/Skyrim_Modding_Lessons_2026-05-14.md` and folded the actionable rules into PDV standards, Papyrus guidance, setup notes, and the local Papyrus/CK skill. Load-bearing additions: strict player-facing ASCII, Papyrus string/docstring/parser limits, no assumed `StringUtil.Replace`, save-baked new-game retesting, grep-before-delete hygiene, and dialogue/faction gate discipline for later race modules.
- **Expanded Skyrim lessons intake (2026-05-14):** Archived the fuller follow-up at `archive/Skyrim_Modding_Lessons_Full_2026-05-14.md` and folded additional rules into the working docs/skill: Papyrus array/operator limits, chained cast avoidance, CK condition-name differences, location/hold detection cautions, one-backend-per-key storage discipline, JContainers FormID storage, dialogue line length, SEQ regeneration after dialogue edits, MCM OID storage, CSF filename caveat, and trace/debug cleanup conventions.
- **Session learnings (2026-05-11):** Practical CK/MO2 workflow is now better understood and should be treated as the project default until disproven:
  - **CK launch path:** Open `D:\Wabbajack\modlists\Anvil\Anvil.exe`, select `Creation Kit` in the MO2 executable dropdown, then press `Run`. MO2 then launches CKPE through `D:\Wabbajack\modlists\Anvil\Stock Game\ckpe_loader.exe` (set in `ModOrganizer.ini`). Do not launch `ckpe_loader.exe` directly for PDV CK work, because CK needs MO2's virtual filesystem and output routing.
  - **CK ini path:** The active CK config for this setup is `D:\Wabbajack\modlists\Anvil\Stock Game\CreationKit.ini` (with `CreationKitCustom.ini` as an optional overlay in the same folder), not the usual Documents path.
  - **SSE source layout:** For this setup, vanilla source scripts and `TESV_Papyrus_Flags.flg` live under `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts`. Do not assume LE-style or other folder variants.
  - **New scripts may need manual compile before CK sees them:** CKPE could see `PDV__ManagerQuest` but not fresh scripts like `PDV_DeityBase` / `PDV_Deity_Kyne` until `.pex` files existed. If CK offers only `Add New Script`, first verify whether the corresponding `.pex` has been compiled into `Devotion\Scripts\`.
  - **Compiler import chain for this project:** Successful external compile required four source roots:
    1. `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`
    2. `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts`
    3. `D:\Wabbajack\modlists\Anvil\mods\PapyrusUtil AE - Scripting Utility Functions\Scripts\Source`
    4. `D:\Wabbajack\modlists\Anvil\mods\SKSE Script Sources - Compile Only\scripts\source`
  - **Papyrus API gotchas confirmed by compile:** `Actor.GetName()` was not valid in the attempted context; `continue` is not a Papyrus keyword; variables/properties cannot shadow known type names such as `ActorBase` or `Message`; `SendModEvent` should not be assumed available/necessary without verification.
  - **Papyrus parser/string gotchas:** Valid string literal escapes are limited to `\\` and `\"`; `\n`, `\r`, and `\t` are not safe in `.psc` strings. `{...}` docstrings belong only directly after declarations and should not contain literal `{`; use `;` comments inside control flow.
  - **Papyrus language/naming/helper gotchas:** Short locals can collide with known script/type names, including `key`, `form`, `actor`, and `cell`; locals also cannot shadow script properties. `StringUtil.Replace`, `Math.max`, `Math.min`, ternary expressions, string interpolation, and string `+=` are unavailable. Arrays cannot be variable-sized and cap at 128; treat function-local arrays with suspicion if compile behavior looks stale.
  - **Papyrus cast and API-source gotchas:** Split chained casts into intermediate variables. Before using a new function from JContainers, PO3, UIExtensions, StorageUtil, PapyrusUtil, or any plugin API, open the shipped `.psc` and verify the exact signature.
  - **CK property friction:** Manual property filling is painful. Prefer `Auto-Fill` wherever property names match record EditorIDs, and reduce CK-only scalar properties in future script design where safe.
  - **FormList editing in CKPE:** `PDV_FLST_AllDeities` accepted drag-and-drop of the `PDV_Deity_Kyne` quest record from the Object Window. The `Edit` button was not the add-entry path in this setup.
  - **SEQ guidance:** Adding a new `Start Game Enabled` quest still means generating a SEQ file. Use xEdit for SEQ generation even if CKPE handled the quest and FormList edits successfully.
  - **Dialogue SEQ guidance:** Adding or changing dialogue also requires regenerating SEQ before testing, or dialogue may not fire until save/reload noise masks the issue.
  - **Skyrim console source of truth:** Use `PDV_SkyrimConsoleReference.md` / UESP Skyrim console docs. Do not use Fallout-style arbitrary `cqf` snippets; Skyrim testing should use commands like `SetPQV`, `SQV`, `StopQuest`, `StartQuest`, named-function `cqf` only if deliberately exposed, and globals inspection instead.
  - **Console function call caveat:** If a future harness uses `cqf`, it can only call named quest script functions; it cannot evaluate arbitrary Papyrus snippets. PDV's current validated path remains the `SetPQV` poll harness.
  - **CK output target:** The CK output target was changed to the `Devotion` mod. This is the correct setup for this project. Avoid outputting to a separate scratch mod while actively editing PDV scripts.
  - **Shadow-source risk:** `Anvil - Creation Kit Output` previously shadowed `PDV__ManagerQuest.psc` with a stale duplicate. If CK seems to ignore recent script edits, check for duplicate `PDV_*` sources in other enabled mods first.
  - **Cleanup performed:** Stale `QF_PDV__ManagerQuest_*` fragment artifacts were removed from `Anvil - Creation Kit Output`. Keeping CK output pointed at `Devotion` remains the correct setup.
  - **Phase 2 test harness direction:** The validated harness is poll-based inside `PDV__ManagerQuest` itself, using `DebugCommand`, `DebugIndex`, and `DebugValue` plus `OnUpdate()` every 1 second. The earlier stage-fragment plan was abandoned because CKPE fragment binding was unreliable in this setup.
  - **Phase 3 Story Manager direction:** Use quest script Story Manager events (`OnStoryKillActor`) through a small receiver quest rather than stage fragments or trying to "subscribe" the persistent router directly. Keep `Shares Event` checked so PDV does not consume events needed by other mods.
  - **Phase 3 Papyrus safety:** Guard all `ObjectReference` -> `Actor` casts before calling actor functions. `IsHostileToActor(None)` is documented as crash-risk, so never call it without a verified player/victim actor. Prefer CK-wired `Keyword` properties such as `ActorTypeNPC` / `ActorTypeAnimal` over SKSE `HasKeywordString()` for classification.
  - **CK condition naming:** CK condition functions are not always named like Papyrus methods. For example, Papyrus `IsDead()` maps to CK condition `GetDead`; verify the condition editor side separately.
  - **Location/hold detection:** Do not assume `Cell.GetCurrentLocation()`, vanilla SSE `Location.IsContainedIn()`, or broad `Location.HasCommonParent()` solve hold detection. Prefer walking `Location.GetParent()` from an event-provided/current location against CK-bound hold `Location` properties.
  - **Console timing rule:** `SetPQV` commands only take effect after closing the console and letting the game run briefly. Enter one `DebugCommand` at a time, close the console, wait 2-3 seconds, then inspect results.
  - **Save-bake testing rule:** After changing Papyrus scripts, impossible behavior should be retested from a new game or main-menu `coc qasmoke` path before assuming the source logic is wrong.
  - **Player-facing string rule:** Anything the player sees must be ASCII-only. Avoid curly quotes, em/en dashes, ellipses, bullets, and other multibyte punctuation in dialogue, MCM, notifications, books, and message boxes.
  - **Dialogue/faction rule:** For later dialogue-heavy race content, use separate eligible/current states or a single faction with meaningful ranks, gate every relevant topic explicitly, keep related `Link To` chains in the same branch, avoid Force-Activate for normal Hello topics, and keep dialogue lines under 80 characters.
  - **Storage backend rule:** StorageUtil remains the default for PDV state. If JContainers is introduced later, keep StorageUtil, JFormDB, JDB/JArray, and live actor values distinct per key; store FormIDs rather than Actor/Form references in long-lived JArray/JDB collections.
  - **MCM/CSF caveats:** Future SkyUI MCM option builders must store returned OIDs for event handling. If PDV ever uses Custom Skills Framework, the ESP filename in the CSF JSON must exactly match the plugin filename or lookups can silently fail.
  - **Overwrite hygiene:** Runtime `.log` files and empty screenshot folders in `D:\Wabbajack\modlists\Anvil\overwrite` were confirmed safe to delete and should not be moved into `Devotion`.
  - **CK walkthrough authoring rule:** Write manual CK steps in the same order a human should perform them in the editor. When a menu contains a long field or property list, write that list alphabetically unless the UI's own order makes another sequence clearer.

- **Race architecture grilling session (2026-05-16):** Nine design decisions locked after comprehensive review of all 10 race sheets: (1) Nord broad worship gets its own reward vocabulary with combo/overlapping contextual favors. (2) Breton restructured to three-track primary identity (Knight's Road / Hidden Art / Green Way) with god choice as secondary flavor layer; supersedes earlier flat-pantheon framing. (3) Khajiit emergent patron — no formal commitment moment, system silently detects behavioral alignment (lore confirmed via UESP/Imperial Library). (4) Khajiit moon cycle reward phasing tied to Skyrim's Masser/Secunda. (5) Khajiit Road Homes: 2-3 designated rest points instead of one sacred place. (6) Argonian bed-of-choice community designation piggybacks thane-regard; requires regular sleeping; Hist sap meditation item for custom Hist reconnection. (7) Orc City/Legion dynamic situational rewards + self-made community progression (empty→established→thriving). (8) Bosmer Old Contract gets own Green Pact tagging system mirroring Requiem/Races Redone approach (not a dependency). (9) Altmer Tier 3 Lorkhan penalties lightly weighted — triggers evocative reactions, not harsh punishment. Also locked: Imperial Concordat Uncommitted band widened to ±50, and shared PDV_SacredPlace script architecture for Argonian/Khajiit/Orc location-based devotion.
  - **Race architecture grilling rounds 2-3 (2026-05-16):** Additional decisions locked: (10) Dunmer portable shrine — inventory item with animation, prayer anywhere, bonus at player-owned property. (11) Nord broad worship at Faithful combines watered-down multi-deity blessings as combo effects. (12) Altmer crisis-of-faith events at major story points create temporary questioning states. (13) Bosmer pact failure — no lockout on single violations; 5 breaks in 2 days triggers piety penalty. (14) Argonian Arkay priest reactions flagged as essential custom content. (15) Patron commitment general model: "god notices you and reaches out" (non-Khajiit). (16) Orc community: NPC disposition preferred, faction-favor proxy for 1.0. (17) Redguard HoonDing achievable via special beasts + big win quests. (18) Dunmer Tribunal prayer gives random buff/debuff from curated themed pool. (19) Altmer vampire gets "Exiled Altmer" micro-path, Tier 1 cap, self-reconstruction. (20) Breton triangle drag is asymmetric between three traditions. (21) Imperial Concordat walk-back uses amplified reverse weight + narrative gate. (22) Custom content priority: Essential = Argonian/Dunmer/Khajiit/Orc/Bosmer; Enhancement = Altmer post-vampire. (23) Non-substrate races can be promoted to substrate if playtest warrants; architecture supports without refactor. (24) Khajiit moon cycle uses hybrid model: per-phase bonus + full-cycle compliance.
- **Bosmer Pact model locked (2026-05-17):** Y'ffre / Green Pact reframed as a binary `PactBound` path commitment rather than a soft-scaled deity. While bound, Y'ffre is exclusive and other Bosmer deity ledgers freeze; `GreenPactCompliance` is a 0-100 act-driven meter (no passive decay) with four bands (Apostate 0-19 locked, Lapsed 20-49 at 50%, Observant 50-79 at 100%, Strict 80-100 at 120%). Sustained Apostate dwell (3 in-game days) fires a forced re-commit-or-renounce prompt; no silent auto-renunciation. Lifetime cap: one re-entry permitted, second renunciation is terminal (Y'ffre ledger freezes permanently, MCM Pact toggle disables, other Bosmer deities remain available). Wild Hunt explicitly removed as a player-facing track — lore context only. Hybrid plant/violation detection: FormLists authoritative, keyword fallback as strict-mode opt-in. Authoritative spec: `references/PDV_BosmerPactModel_Planning.md` (Ratified). Folded into `race-sheets/Race_Bosmer.md` Old Contract section and `references/PDV_RaceArchitecture_DesignReference.md` sections 4.2 and 10.7. Supersedes the prior "5 breaks in 2 days triggers piety penalty" rule from rounds 2-3 (item 13).
- **Workflow ratification + regression discipline (2026-05-18):** New default project workflow after the recent race/preflight merge cycle: when a design review locks a rule, ratify it across all affected living docs in the same session instead of leaving it in one planning patch or chat summary; after broad doc merges, run a short consistency sweep for overview drift, superseded-rule leftovers, and encoding/ASCII regressions; when CK/xEdit/MO2 work could regress silently, prefer adding or tightening verifier coverage before trusting memory or a one-off smoke; and when Papyrus compile errors appear, triage in this order: import chain, API/source provenance, parser/language limit, then logic bug. Rationale: the recent follow-up commits clustered around cross-doc synchronization, verifier hardening, and small post-merge cleanup rather than deep algorithmic rework.
- **v3 gameplay refinement sync (2026-05-18):** `PDV_Architecture_v3.md` v3.10 now absorbs the Bosmer Pact ratification into the forward architecture (`PactBound`, `GreenPactCompliance`, forced reckoning, one-time re-entry, and terminal second renunciation), closes `D-19` through `D-23` to match the live `PDV__ManagerQuest` neglect/decay defaults, and leaves `D-12` open with an explicit note that the current separate Daedric roster is scaffold truth today rather than final architecture truth.
- **v3 race-sheet architecture sync (2026-05-16):** `PDV_Architecture_v3.md` v3.7 now treats the new `race-sheets/*` plus `references/PDV_RaceArchitecture_DesignReference.md` Section 12 as the active race-design source. It locks the public five-band race vocabulary onto the internal `PDV.Tier` 0-3 spine, names the first-release reputation/state tracks, clarifies strong substrates as Dunmer/Khajiit/Argonian only, keeps Orc community location as a `PDV_SacredPlace` contextual mode modifier, and updates beta gates around the named race obligations.
- **Contextual favor trigger model (2026-05-18):** Contextual favors are automatic signal-triggered boosts, not player-invoked powers. Each devotional lane should use 3-5 trigger families drawn from the same authored tables that generate piety. The player may have only one contextual favor boost active at a time; after it expires, another qualifying preferred signal can trigger a new boost. Rationale: favors should feel like the faith answering back while staying legible and preventing stacked divine burst packages.
- **Contextual favor marked-signal rule (2026-05-18):** Favor eligibility is authored, not inferred from piety sign. Most favor triggers are positive piety signals, but costly or ambiguous events can trigger a favor when the matrix marks them as meaningfully faithful, such as defiance under Concordat pressure, re-commitment after rupture, cure-and-return rites, or choosing orthodoxy after dissonance. Pure penalties, failures, hostile-rival signals, and ordinary negative drift do not trigger favors unless an explicit restoration or recommitment signal is authored. Rationale: some moments should feel marked because the character paid a real theological cost.
- **Contextual favor global cap (2026-05-18):** The one-active-boost cap applies globally across all PDV contextual favors, including temporary substrate favors. Baseline blessings, low-power persistent substrate boons, religious privileges, neglect state changes, and restoration state changes are outside the cap unless they grant a temporary contextual favor. Rationale: layered races can keep their persistent identity texture without allowing stacked timed divine bursts.
- **Contextual favor devotional-lane rule (2026-05-18):** Favor counts are per active devotional lane, not per whole race. A lane may be a focused deity, path, mode, substrate layer, or broad-worship state depending on the race architecture. Broad worship counts as its own lane and receives 3-5 blended Faithful-capped favor families rather than activating every individual deity's patron favor set. Rationale: whole-pantheon worship should feel complete and culturally normal without becoming stacked patron worship.
- **Broad-worship lane eligibility (2026-05-18):** Broad-worship lanes exist only where culturally normal and experientially useful, not for every race with multiple worship targets. First-release broad lanes are Nord, Imperial, and Redguard; Dunmer uses a special layered equivalent; Breton and Altmer do not receive generic broad lanes because tradition/coherence are their real organizing lanes. Rationale: broad worship should be a theological shape, not a generic polytheism toggle.
- **Dunmer layered contextual favor (2026-05-18):** Dunmer `Layer 1 + Layer 2` practice can trigger contextual favors before a primary Good Daedra focus. These shared favors present as the ancestor ash-prayer plus Reclamations answering the same life, not generic broad pantheon worship, and should stay mostly Quiet or Noted. Marked surfacing usually waits for primary focus, vampire cure/restoration, major diaspora burden, or major Good Daedra quest recognition. Rationale: Dunmer layered worship should feel alive before Tier 3 without collapsing into the broad-worship model used by Nord, Imperial, or Redguard.
- **Dunmer Azura presentation (2026-05-18):** Azura's Dunmer focus is painful truth and transformation at thresholds, not generic prophecy. Dawn, dusk, Azura's Star, cure arcs, exile beats, and major choice-points matter because they reveal what the character is becoming. Rationale: Azura should feel like the Reclamation who makes change meaningful for displaced Dunmer, not a flat twilight/flavor-text tag.
- **Dunmer primary-focus favor width (2026-05-18):** Azura, Boethiah, and Mephala should each receive five focused contextual-favor trigger families. Boethiah expands beyond combat into trial, overthrow, betrayal-as-test, and Chimeric self-authorship; Mephala expands beyond stealth into hidden community, lethal secrets, obligation webs, and necessary lies. Rationale: the three Good Daedra are full Dunmer religious centers, so each Devoted focus should feel complete rather than like a narrow patron tag layered on top of the ancestor substrate.
- **Dunmer Azura threshold boundary (2026-05-18):** Dawn, dusk, night, and magic-adjacent play do not trigger focused Azura contextual favor by themselves after the basic shared-layer rhythm. Focused Azura favor requires a real threshold, painful truth, transformation, exile-continuity, artifact/shrine rite, or curated major transition. Rationale: twilight should frame Azura's moments without turning her into a generic time-of-day favor engine.
- **Dunmer Boethiah cruelty boundary (2026-05-18):** Random betrayal, generic violence, casual cruelty, and ordinary faction hostility never trigger Boethiah contextual favor. Boethiah favor requires trial, overthrow, false authority, betrayal-as-test, Chimeric self-authorship, or curated quest/artifact context. Rationale: Boethiah should feel ruthless and dangerous without becoming a generic violence-reward wrapper.
- **Dunmer Mephala crime boundary (2026-05-18):** Random murder, casual theft, convenient lying, and generic crime never trigger Mephala contextual favor. Mephala favor requires hidden obligation, protected community, dangerous knowledge, targeted hidden violence, a maintained network, or curated artifact/quest context. Rationale: Mephala should feel like the Webspinner of survival and lethal secrets, not a generic crime-reward wrapper.
- **Dunmer contextual-favor review cleared (2026-05-18):** The Dunmer contextual-favor table is review-cleared for user-experience shape. It contains five shared ancestor + Good Daedra trigger families, five focused trigger families each for Azura, Boethiah, and Mephala, and anti-generic boundaries for all three focused lanes. Remaining risk is hook feasibility and launch-scope selection, not the experience model.
- **Imperial broad-worship presentation (2026-05-18):** Imperial broad worship is civic/institutional, not a reskinned Nord mythic breadth lane. Its contextual favors are led by civic acts (mercy/restraint, burial duty, lawful order, honest trade, and public/private Talos pressure), while temples, shrines, Hall of the Dead spaces, courts, Legion spaces, and similar institutions act as amplifiers, recognition surfaces, or cleaner hooks where Skyrim supports them. Rationale: Imperial religion should feel like public duty and civic infrastructure, not generic shrine attendance.
- **Redguard broad-worship presentation (2026-05-18):** Redguard broad worship is sect-shaped. Crown, Forebear, and Ash'abah each count as separate broad-worship devotional lanes for contextual favors; they share a Yokudan spine, but should not collapse into one generic Yokudan broad package. Rationale: Redguard breadth is real devotion inside a chosen societal-religious frame, not an undifferentiated pantheon mode.
- **Contextual favor duration buckets (2026-05-18):** Contextual favors use four shared duration buckets: momentary combat favor (30-90 seconds), after-act favor (2-4 in-game hours), environmental favor (while the place/time context holds), and rare major favor (24 in-game hours). Player-facing language should describe these as "for this fight," "for this journey," "while I am in the sacred context," or "until the next day" rather than exposing precise timer mechanics. Rationale: a small timing vocabulary keeps favors understandable and helps balance cross-race reward feel.
- **Contextual favor surfacing ladder (2026-05-18):** Favor visibility follows duration and significance: momentary combat favors are usually Quiet (effect/icon only), after-act and environmental favors can be Noted with short notifications when rare enough, and rare major or costly-faithful restoration/recommitment moments can be Marked with named feedback. Shorter favors should be quieter by default; costly-faithful moments may surface one level higher than duration alone would imply. Rationale: the player should feel frequent favors without notification spam, while major paid-for moments still feel memorable.
- **Contextual favor table shape (2026-05-18):** Race sheets should use the shared contextual-favor columns `Lane`, `Trigger family`, `Hook candidates`, `Favor bucket`, `Surfacing`, and `Notes`. Rationale: the signal/reward pass needs one comparable authoring shape across races without flattening race-specific theology or user-experience texture.
- **Contextual favor table rollout (2026-05-18):** Populate the shared table shape as a pilot on Nord, Imperial, and Redguard first, then propagate to all remaining race sheets after the pilot clears review. Rationale: these three are the broad-worship edge cases and will prove whether the format preserves distinct user experience across mythic breadth, civic breadth, and sect-shaped breadth.
- **Contextual favor pilot staging (2026-05-18):** Pilot tables may live directly in the Nord, Imperial, and Redguard race sheets as `Status: Pilot draft` while they are being worked; do not promote race-specific rows into the architecture reference until the pilot clears review. Rationale: the architecture should own the table shape and clearance rules, while race sheets carry draft user-experience content.
- **Contextual favor pilot scope (2026-05-18):** The Nord/Imperial/Redguard pilot should cover broad-worship lanes only. Each pilot race may include a short focused contrast note, but full focused-deity contextual-favor tables wait until the broad-lane pilot clears. Rationale: broad worship needs to stand as a complete experience before focused patron design sharpens the contrast.
- **Contextual favor pilot clearance (2026-05-18):** The Nord/Imperial/Redguard pilot clears only when each pilot broad-worship lane has 3-5 trigger families, every trigger family has a strong vanilla hook candidate or explicit custom/post-1.0 note, every row has a favor bucket and surfacing level, and each race includes a short user-experience sentence proving it does not feel like the other two broad-worship lanes. Rationale: the pilot must protect distinct race feel, not merely produce filled tables.
- **Contextual favor pilot cleared (2026-05-18):** Nord, Imperial, and Redguard cleared the cross-pilot table review. The table shape may now be propagated to the remaining race sheets. Race-specific pilot rows remain in race sheets; the architecture reference should continue to own only the shared table shape, rollout rules, and clearance criteria. Rationale: the format proved it can preserve mythic breadth, civic breadth, and sect-shaped breadth without flattening them.
- **Nord Broad Nine Divines presentation (2026-05-18):** Broad Nine Divines Nords mostly use the same deed/world hook surface as Broad Old Ways Nords, with Divine names and moral framing rather than an Imperial civic/institutional hook set. Rationale: a Nord who worships the Divines should still feel like a Nord whose religion is expressed through holds, weather, family, death, honor, and Talos pressure.
- **Broad Nord Talos pressure (2026-05-18):** Talos pressure belongs in both broad Nord lanes. In Broad Old Ways it presents as ancestral identity defiance; in Broad Nine Divines it presents as carrying contradiction inside a public Divine frame. In both cases, favor requires costly faithful signals rather than generic anti-Thalmor violence or ordinary Civil War preference. Default surfacing is Noted, escalating to Marked only for high-cost events such as hiding a worshipper, protecting a shrine, or face-to-face Thalmor defiance. Rationale: Talos pressure is a central Nord 4E 201 religious fact without making every Nord a Stormcloak caricature or spamming major feedback.
- **Imperial Concordat favor distinction (2026-05-18):** Concordat compliance may move `ConcordatStanding`, alter access, or qualify Akatosh/civic-order favor when the authored act is genuinely order-preserving, but it does not trigger Talos contextual favor. Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence. Rationale: compliance is an Imperial civic-state fact, while Talos answering back should always mean conscience under pressure.
- **Imperial lawful-order favor trigger (2026-05-18):** Legion allegiance, court status, and official faction state may provide scoring context, but they do not trigger contextual favor by themselves. Lawful-order favor requires a concrete public-service or order-preserving act, and the act must not be cruelty disguised as order. Rationale: Imperial civic faith should reward meaningful service, not faction membership as a passive blessing switch.
- **Imperial mercy/restraint bounty boundary (2026-05-18):** Bounty payment is not a generic mercy/restraint favor trigger. It counts only when authored as preventing harm or resolving a real civic conflict; ordinary pay-bounty menu interactions do not trigger favor. Rationale: Stendarr-coded civic mercy should not become a cheap economy loop or morally ambiguous menu action.
- **Redguard Crown make-way boundary (2026-05-18):** Crown may receive rare make-way favor, but only as Ruptga/HoonDing-adjacent sacred survival through honorable adversity. It is not Forebear improvisation, road pragmatism, or social adaptation. Rationale: Crown should retain Redguard victory-history resonance without stealing Forebear's pragmatic way-making identity.
- **Redguard Ash'abah marking boundary (2026-05-18):** Ash'abah routine undead-cleansing and burial duty should usually be Noted. Marked moments require real burden-bearing such as major tombs, major necromancer operations, costly impurity choices, or later custom social-stigma content. Rationale: Ash'abah should feel quietly honored often, but only visibly marked when the player carries what others avoid.
- **v3 doc cleanup and scaffold-code contract (2026-05-16):** `PDV_Architecture_v3.md` v3.8 and `references/PDV_RaceArchitecture_DesignReference.md` now make the removed bucket model explicit as legacy vocabulary only. The first Structural Skeleton code-deepening pass added compile-clean optional base scripts for reputation tracks, state tracks, substrates, sacred places, Daedric paths, and curse state before broad CK content wiring. Implementation plan review: phase order stays intact; the race-sheet cleanup tightens acceptance criteria rather than reopening v2.

## Session Notes

### 2026-05-16 V3 Preflight script/tooling kickoff

- Added `PDV_EventTypes.psc` and `PDV_EventBus.psc` to the live Devotion script source and active compile set.
- Refactored the canary kill route so direct-player hostile beast/humanoid scoring remains v2-compatible while follower/environment payloads are carried but non-scoring.
- Added manager-side patron-state helpers, named dawn/gain extension slots, PapyrusUtil bootstrap hard-fail, custom-race fallback diagnostic, and MCM status readouts.
- `node .\tools\pdv_compile.mjs --all` rebuilt all active scripts cleanly with `0 error(s), 0 warning(s)` and the verifier returned `FAIL=0, WARN=0, TODO=0`; remaining Preflight work is CK/xEdit record wiring plus in-game smoke.

### 2026-05-11 implementation and workflow summary

- `PDV_DeityBase.psc`, `PDV_Deity_Kyne.psc`, and `PDV__ManagerQuest.psc` all reached a compile-ready state for SSE after fixing invalid Papyrus assumptions and adding the missing SKSE import source.
- `PDV__ManagerQuest.psc` now contains the validated Phase 2 debug harness intended for in-game verification via poll-based `SetPQV` commands.
- In-game testing confirmed correct behavior for activation, mirror globals, dawn clamp, and tier threshold transition.
- Historical `PDV_Phase2_CK_Steps.md` and `PDV_Phase2_Summary.md` were updated to match the poll-based harness and to stop relying on arbitrary `cqf` snippets or unreliable fragment-driven testing flows. They now live under `archive/completed-phase-docs-2026-05-16/`.
- `references/PAPYRUS_KNOWLEDGE_INTAKE.md` is now explicitly part of project context and should inform future Papyrus scripting decisions.

### 2026-05-12 verifier tool

- Added `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs` as the first PDV-specific local toolchain.
- `node .\tools\pdv_compile.mjs --all` rebuilt `PDV__ManagerQuest`, `PDV_DeityBase`, `PDV_Deity_Kyne`, `PDV_ActionRouter`, and `PDV__SM_KillActor` with `0 error(s), 0 warning(s)`, then ran the verifier successfully.
- Current strict Phase 3 verifier run reports no hard failures or TODOs after CK wiring and SEQ generation.
- At this point in the Phase 3 tool build, the verifier warned about two unnamed Global records, stale manager QF fragment VMAD metadata, the missing old QF fragment file, and the now-empty xEdit SEQ output location after moving the generated SEQ into `Devotion\Seq`; the 2026-05-14 cleanup below supersedes this.

### 2026-05-14 Phase 3 CK wiring and runtime verification complete

- Created and wired `PDV_ActionRouter` as a Start Game Enabled persistent service quest with manager, FormList, debug global, player, and ActorType keyword properties assigned.
- Created and wired `PDV__SM_KillActor` as a non-Start-Game-Enabled Story Manager receiver quest with `PDV_Router` pointing to `PDV_ActionRouter`.
- Added the receiver under Story Manager Kill Actor with `Shares Event` checked, saved `PlayerDevotion_Framework.esp`, generated SEQ, and moved `PlayerDevotion_Framework.seq` into `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\`.
- Enabled Papyrus logging in the `Devotion Dev` profile INIs, then verified runtime logs for Kyne patron activation, hostile bandit scoring (`event 2`, `+0.5` scratch), hostile wolf scoring (`event 1`, `-3.0` scratch), neutral-kill rejection, rapid dual-kill accumulation, and dawn consolidation/clamping.
- `node .\tools\pdv_verify.mjs --strict-phase3` now reports `FAIL=0, WARN=0, TODO=0` after xEdit cleanup (orphan globals removed, stale Manager QF metadata removed, SEQ refreshed).

### 2026-05-13 race architecture wrap-up

- Completed the architecture grill for the remaining unfinished races and locked Imperial, Khajiit, Bosmer, Redguard, Orc, and Argonian in `references/PDV_RaceArchitecture_DesignReference.md`.
- Added a shared design rule that major quest and faction choices should carry heavier devotional weight than ambient behavior when they clearly express the race's theology.
- Synced the supporting lore-reference wording in `references/tamriel-daily-worship-4e201.html`, `references/tamriel-cursed-worship-4e201.html`, and `references/tamriel-daedric-worship-4e201.html` so the local reference set reflects the locked decisions.
- No Papyrus, CK wiring, or runtime status changed in this session; this was a design and reference-doc consolidation pass only.

### 2026-05-13 Phase 4 matrix pass

- Created the Phase 4 matrix working set under `references/phase4/`: scaffold, race signal matrix, stance matrix, Daedric race-by-Prince matrix, and cross-validation note.
- Cross-validated the three matrixes against the locked architecture in `references/PDV_RaceArchitecture_DesignReference.md` and the still-useful implementation draft in `PDV_Architecture_v2.md`.
- Resolved the main taxonomy drifts uncovered during validation: Khajiit `Hermorah` and `Nocturnal` were kept as non-native pressure lanes in the stance model, and Orc `Azura/Azurah` was tightened to a taboo outsider reading in the Daedric matrix.
- Mirrored the finished Phase 4 design outputs into `D:\Wabbajack\modlists\Anvil\mods\Devotion\Design\Phase4\` for live mod-folder reference.
- No CK wiring, ESP data entry, compile outputs, or runtime verification changed in this pass; this was design-structure work only.

### 2026-05-15/16 Phase 4-6 CK pass, MCM wiring, and overlay retirement

- Phase 4 CK wiring is now present in the live framework ESP. Verifier-confirmed records and wiring include `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, Kyne's Phase 4 stance row, Kyne's boon assignments, and `PDV__ManagerQuest.PDV_GLO_PatronDeity`.
- Phase 5's first dev-facing MCM slice is framework-owned: `PDV_MCM` exists, has the `PDV_MCM` script attached, and has all required manager/FormList/global properties wired directly on `PlayerDevotion_Framework.esp`.
- Phase 6's coupled Talos + Auri-El records are mostly framework-owned: Talos/Auri-El quests exist, `PDV_FLST_AllDeities` includes Kyne/Talos/Auri-El, `PDV_Origin` points at Talos and Auri-El, stance rows and boon spell properties are assigned, and the verifier now reaches `FAIL=0`.
- `PDV_ManagerPatronWirePatch.esp` and `PDV_MCMWirePatch.esp` were merged back through xEdit and are now unticked in the `Devotion Dev` profile. Keep the files on disk for one validation cycle only; do not leave them active "just in case."
- Current verifier state is clean: `FAIL=0, WARN=0, TODO=0` as of 2026-05-16 08:01 AEST. Remaining verifier output is informational only.
- CK source-store instability was investigated after repeated fatal errors. The missing SkyUI header chain was partially repaired by adding `SKI_QuestBase.psc` and creating a dedicated shim mod at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\` exposing `SKI_QuestBase.psc`, `SKI_ConfigBase.psc`, and `SKI_ConfigManager.psc` under `Source\Scripts\`. The `Devotion Dev` profile modlist was backed up before enabling the shim.
- In-game MCM smoke test is now complete with ReShade temporarily disabled: `PlayerDevotion` appears in SkyUI, `Status` and `Debug` both load, the roster renders correctly after the Status-page cursor-fill fix, and debug patron override can swap to Auri-El.
- ReShade remains an external environment issue, not a PDV logic failure. The confirmed crash signature was `EXCEPTION_ACCESS_VIOLATION` at `0x000000000000` with repeated `ReShade64.dll`, `WS2_32.dll`, and `webio.dll` frames in `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\SKSE\crash-2026-05-15-22-02-14.log` and `...22-17-17.log`. Workaround used for smoke testing: rename `D:\Wabbajack\modlists\Anvil\Stock Game\ReShade64.dll` before launch.

### 2026-05-16 Origin race normalization

- `PDV_Origin.psc` now separates permanent cultural origin from current body race at bootstrap. Vanilla `*RaceVampire` records normalize back to their base race index, `WerewolfBeastRace` / Dawnguard Vampire Lord race defer initialization instead of writing the Imperial fallback, and unsupported non-temporary custom races still fall back to Imperial with a trace.
- The fix compiled cleanly with `node .\tools\pdv_compile.mjs --script PDV_Origin`; the post-compile verifier returned `FAIL=0, WARN=0, TODO=0`.
- A discarded exploratory overlay, `PDV_OriginRaceNormalizationPatch.esp`, was deleted from the Devotion mod and no longer appears in the Anvil MO2 MCP plugin view.
- Architecture note: curse states remain runtime interpretation overlays. They do not mutate `PDV_GLO_OriginRace`; future vampire/werewolf scoring should live behind a dedicated curse-state module or manager helper.

