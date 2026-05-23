# Player Devotion â€” Mod Development Setup Reference
**Project:** PlayerDevotion Framework + Race Modules
**Engine:** Skyrim Special Edition (SSE)
**Last Updated:** 4E 201 (update this when your setup changes)

---

## Project File Index

| File | Purpose |
|------|---------|
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity equivalency table - canonical lore reference |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice reference - design source document |
| `references/tamriel-cursed-worship-4e201.html` | Race-by-race curse-state religious interpretation source |
| `references/tamriel-daedric-worship-4e201.html` | Race-by-race Daedric practice source |
| `PDV_MOD_SETUP.md` | This file â€” dev environment and architecture reference |
| `PDV_Architecture_v3.md` | Forward architecture, subsystem gates, beta/launch roadmap |
| `PDV_TargetEndStates_1.0.md` | 1.0 product target, per-race acceptance state, roadmap traceability |
| `tools/pdv_compile.mjs` | PapyrusCompiler wrapper for stale/all/targeted PDV script compiles |
| `tools/pdv_verify.mjs` | Read-only verifier for Anvil/MO2/ESP/script wiring drift |
| `tools/pdv_author.mjs` | Safe overlay-patch authoring helper for supported ESP wiring on existing PDV records |
| `tools/pdv_patch.mjs` | Planning-first offline patcher for classification/distribution dry-run manifests |
| `tools/pdv_extract_vanilla_gameplay_refs.mjs` | Read-only vanilla/DLC gameplay reference extractor |
| `tools/pdv_skyrim_refs_bridge.mjs` | Read-only bridge for querying the neutral `SkyrimGamePlayReferences` repo |
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
| **Papyrus Extension for VS Code** | Syntax, autocomplete, compile | VS Code marketplace â€” search "Papyrus" by joelday |
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
[Profile: Devotion Dev]      â† work here (active; inside Anvil MO2 instance)
[Profile: PDV_Testing]       â† optional clean ship-verification profile (create before public release)
[Your normal play profile]   â† never touched by this project
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
PlayerDevotion_Framework.esp    â† your core file
PDV_Nord.esp                    â† race module (add as built)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

**Rule:** Keep the Devotion Dev profile minimal â€” Skyrim/DLC, SKSE, SkyUI, Address Library, powerofthree's Tweaks, powerofthree's Papyrus Extender, and PDV plugins only. Every additional mod is a potential false positive when debugging. The Anvil instance hosts a full modlist; Devotion Dev is the curated subset for PDV work.

### MO2 Settings to Configure

- **Mod Organizer â†’ Settings â†’ Nexus:** Not needed for development
- **Mod Organizer â†’ Settings â†’ Plugins:** Ensure BSA extraction is ON for vanilla assets
- **Right-click game executable â†’ Edit:** Add `-forcesteamloader` argument if CK fails to launch

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

> `compile.ps1` and `skyrimse.ppj` exist in the mod folder as legacy files from an earlier toolchain. Do not use them â€” defer to `tools\pdv_compile.mjs` for terminal compiles or the CK compiler for interactive CK work.
>
> `ScriptCompile.bat` in the `Papyrus Compiler` folder is a stale Bethesda development artifact that points at internal `C:\Projects\TESV\Build...` paths. Treat it as an example invocation, not a working wrapper.
>
> **2026-05-12 update:** The active CKPE/MO2 setup now outputs directly into the `Devotion` mod. Source files live in `Devotion\Scripts\Source\`; compiled `.pex` files should land in `Devotion\Scripts\`. If CK cannot see a newly added script, compile that script with `tools\pdv_compile.mjs --script <ScriptName>` using the known SSE import chain documented in `AGENTS.md`.

### Build files (in the mod folder)

| File | Role |
|---|---|
| `SkyrimSE.code-workspace` | VS Code workspace (rooted at the mod folder) |
| `compile.ps1` | Legacy â€” do not use |
| `skyrimse.ppj` | Legacy â€” do not use |
| `meta.ini` | MO2 mod metadata â€” do not edit manually |

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
      PDV_MCM.psc
      PDV_PrismaBridge.psc
  PlayerDevotion_Framework.esp
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
node .\tools\pdv_verify.mjs --strict-phase3
node .\tools\pdv_verify.mjs --strict-preflight
node .\tools\pdv_verify.mjs --strict-skeleton
node .\tools\pdv_verify.mjs --strict-pattern-proving
node .\tools\pdv_verify.mjs --strict-phase7
node .\tools\pdv_author.mjs list-manifests
node .\tools\pdv_author.mjs status phase4
node .\tools\pdv_author.mjs plan phase4
node .\tools\pdv_author.mjs apply phase4 --output PDV_Author_phase4.esp
node .\tools\pdv_author.mjs plan mcm-property-wiring
node .\tools\pdv_author.mjs apply mcm-property-wiring
node .\tools\pdv_author.mjs plan preflight-router-services
node .\tools\pdv_author.mjs apply preflight-router-services
node .\tools\pdv_author.mjs plan skeleton-track-scaffold
node .\tools\pdv_author.mjs apply skeleton-track-scaffold
node .\tools\pdv_author.mjs plan structural-systems-scaffold
node .\tools\pdv_author.mjs apply structural-systems-scaffold
node .\tools\pdv_author.mjs plan structural-systems-arrays
node .\tools\pdv_author.mjs apply structural-systems-arrays
node .\tools\pdv_patch.mjs validate
node .\tools\pdv_patch.mjs plan
node .\tools\pdv_patch.mjs plan --json
node .\tools\pdv_extract_vanilla_gameplay_refs.mjs
node .\tools\pdv_skyrim_refs_bridge.mjs status
node .\tools\pdv_skyrim_refs_bridge.mjs tables
```

The compiler spawns `PapyrusCompiler.exe` directly with the project import chain, compiles known scripts whose `.pex` output is missing or older than source, treats Papyrus warnings as failures, and runs the verifier after successful compiles unless `--skip-verify` is used. The active set now includes the proven v2 scripts plus the V3 Preflight script slice (`PDV_EventTypes` and `PDV_EventBus`); the optional known set includes the V3 Structural Skeleton base scripts (`PDV_ReputationTrack`, `PDV_StateTrack`, `PDV_SubstrateBase`, `PDV_SacredPlace`, `PDV_DaedricPathBase`, `PDV_CurseState`). The import chain now also includes the local `powerofthree's Papyrus Extender\Source\scripts` headers so alias-side shout ingress compiles against `PO3_Events_Alias`. `--strict-phase3`, `--strict-preflight`, `--strict-skeleton`, `--strict-pattern-proving`, `--strict-phase7`, and `--strict-phase8` all pass through to the verifier. The emitted compiler command uses the short canonical flags: `-f=<flags>`, `-i=<source-dirs>`, and `-o=<output-dir>`.

The verifier is read-only. It checks expected Anvil paths, reads `PlayerDevotion_Framework.esp` through the Anvil MO2 MCP Mutagen bridge, validates baseline framework records and VMAD properties, checks script source/pex freshness, reports SEQ drift, confirms the active MO2 profile/load order, and looks for CK output shadow files. V3 Preflight source/pex readiness is covered; the framework-owned CK/xEdit records (`PDV_GLO_PatronState`, `PDV_EventTypes`, `PDV_EventBus`) report as INFO in default mode, and `--strict-preflight` promotes unresolved Preflight gaps to FAIL for gate-close runs. V3 Structural Skeleton now covers the full dev-only scaffold contract: track records/globals/FormLists, substrate/sacred-place/Daedric/curse records, required VMAD wiring, dev FormList membership, MCM scaffold properties, and the Hircine-not-in-`PDV_FLST_AllDeities` contradiction check. Array readback is verifier-visible when arrays exist, but absent manual arrays remain INFO in default mode. `--strict-phase7` adds the Nord/Imperial-first signal gate: PO3 shout registration on `PDV_PlayerEvents`, the shout event constant, EventBus shout/shrine routes, manager shout/shrine helpers, deity-side shout anti-farm helpers, live `PDV_Player` alias + `PDV_PlayerEvents` property readback on `PDV__ManagerQuest`, and readback for the actual hidden Talos shrine reference named in `references\authoring\PDV_Phase7SignalReceivers.manifest.json`. `--strict-phase8` adds the ConcordatStanding record/property and threshold-array gate, Talos track-multiplier wiring checks, manager runtime-wiring fallback detection, reused Phase 7 ingress source checks, and the MCM/source contract for committed state, pending state, extreme gate, and Talos effective multiplier readback. The verifier also reads back `PDV_PreflightRouterServicesOverlay.esp` when that reversible canary exists.

`tools\pdv_author.mjs` is the safe authoring companion to that loop. It inspects the live framework ESP through the same local Mutagen bridge, then emits a **new overlay patch plugin** into the `Devotion` mod when asked to apply changes. Current supported writes are existing-record script attachment, scalar/object VMAD properties, and FormList membership. It does **not** create new records or overwrite `PlayerDevotion_Framework.esp` in place. It now recognizes `IntArray`, `FloatArray`, `StringArray`, and `ObjectArray` manifest syntax for planning/reporting, but VMAD array writes remain manual CK/xEdit work until the Mutagen bridge can actually emit them.

`tools\creation-authoring` is the project-agnostic successor path for generated-first CK record creation. The intended workflow is manifest intent -> generated plugin -> live readback/verifier report -> human review -> explicit promotion into `PlayerDevotion_Framework.esp`. Generated plugins remain the default safety boundary; source plugin mutation requires a separate `promote` step with approval, timestamped backup, structured merge, CK finalization when needed, and post-merge verification. Manifest authors must declare create/update intent explicitly for new record work: authored EditorIDs are design identity, so conflicts fail by default unless a manifest deliberately chooses update or deterministic rename for a safe generated helper.

As of 2026-05-23, the CKPE-backed workbench at `C:\Users\Admin\Documents\ckra-native` has exactly one proof-ledger-supported creation capability: `glob.duplicate_create`. The proven path is CK-owned Object Window duplicate replay against an explicit selected source GLOB, guarded FNAM/FLTV mutation on the duplicate, CK native UI save, strict direct ESP readback, and capability-matrix promotion for GLOB only. Use generated/disposable plugins as the safety boundary. This does not prove generic record creation, source-plugin promotion, VMAD array writes, quest/message/activator/FormList creation, Story Manager edits, or alias creation. During live CK runs, `closeSafeStatus.safeToClose = true` means the bridge has no in-flight mutation transaction; still avoid closing CK while a save is visibly pending.

`tools\pdv_patch.mjs` is the planning-first companion for the later offline classification/distribution patcher direction locked in v3. v0 reads tracked patch-rule manifests from `references\authoring\patch-rules\`, validates their schema strictly, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning records, and emits deterministic dry-run plan output. It does **not** write a generated patch ESP yet; the first pass is schema/load-order/target-resolution proof only.

`tools\pdv_extract_vanilla_gameplay_refs.mjs` is a read-only reference-data helper. It scans local Anvil stock/cleaned base masters through the Mutagen bridge and refreshes generated CSVs under `references\vanilla-gameplay\extracted\`. Use those generated tables as implementation reference data for signal matrices, offline patcher rules, and compatibility planning; curated design decisions still belong in the `references\vanilla-gameplay\pdv-crosswalk\` tables.

`tools\pdv_skyrim_refs_bridge.mjs` is a read-only lookup bridge into the neutral `dunhamma/SkyrimGamePlayReferences` repo. Set `SKYRIM_GAMEPLAY_REFERENCES_ROOT` when the clone is not under `scratch\SkyrimGamePlayReferences`. Use it to list or search broad reference tables such as reverse keywords, faction relationships, condition-bearing effects, cells, containers/furniture, enchantments, leveled lists, FormLists, shouts, and worldspaces. It does not copy data into PDV or replace local xEdit/CK verification. Bridge rules live in `references\vanilla-gameplay\PDV_SkyrimGamePlayReferences_Bridge.md`.

Tracked JSON manifests live under `references\authoring\` and can be addressed by manifest id or file path. `mcm-property-wiring` is the canonical batch target for the current `PDV_MCM` properties and defaults to `PDV_PropertyWiringOverlay.esp`, replacing repeated `PDV_Author_one_off_*` property patches when CK property editing is unstable. `preflight-router-services` is the V3 canary target for co-attaching `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter`; it defaults to `PDV_PreflightRouterServicesOverlay.esp`. `skeleton-track-scaffold` is the V3 Structural Skeleton track wiring batch for the locked 12 track quests/globals/FormLists and defaults to `PDV_SkeletonTrackScaffoldOverlay.esp`. `structural-systems-scaffold` is the broad follow-on batch for substrates, sacred places, Hircine, curse state, and MCM scaffold properties. `structural-systems-arrays` is a reporting/TODO manifest for manual threshold/state-array wiring. All three require CK/xEdit creation of the records first. Use `plan` first to inspect a batch, then `apply`, then run `node .\tools\pdv_verify.mjs`.

Tracked offline patch-rule manifests live under `references\authoring\patch-rules\`. The v0 contract uses top-level `ruleType = pdv_patch_rules_v0` manifests with explicit `target`, `operation`, `payload`, and `provenance` fields per rule. The first tracked example file is intentionally tooling-only and should not be treated as approved live content.

### Future authoring direction (non-authoritative)

PDV may eventually grow into a schema-first record-authoring workflow where a text source compiles into `PlayerDevotion_Framework.esp` via Mutagen. That idea is promising for AI-assisted authoring, diffable record changes, and build reproducibility, but it is still research only in this repo.

Until a real build tool exists and is documented here, do **not** treat any speculative YAML/TOML draft as the source of truth for PDV records. The active workflow remains:

- Papyrus source in `Devotion\Scripts\Source`
- live ESP state in `PlayerDevotion_Framework.esp`
- verification through `tools\pdv_verify.mjs`
- supported scripted ESP wiring through `tools\pdv_author.mjs` overlays and tracked manifests under `references\authoring\`

If a future schema-first tool lands, update `AGENTS.md`, this setup doc, and the verifier/authoring workflow together before adding any new source-format files.

### Anvil MO2 MCP status

Codex is configured for the Anvil MO2 MCP server at `http://127.0.0.1:27016/mcp` in `C:\Users\Admin\.codex\config.toml`. Start it from Anvil/MO2 with the `Start/Stop MCP Server` tool entry. Current local intake and optional binary status live in `references/PDV_Anvil_MO2_MCP_Intake.md`.

Toolchain usage rules:
- After any `.psc` edit, run `node .\tools\pdv_compile.mjs` or a targeted `--script` compile.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- Use `node .\tools\pdv_author.mjs` when supported existing-record property/FormList wiring should be scripted into a reversible overlay patch instead of repeated CK clicking.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3`.
- Before declaring V3 Preflight complete, run `node .\tools\pdv_verify.mjs --strict-preflight` (or compile with `node .\tools\pdv_compile.mjs --strict-preflight`) and resolve all FAILs.
- Before declaring any V3 Structural Skeleton scaffold wave complete, run `node .\tools\pdv_verify.mjs --strict-skeleton` (or compile with `node .\tools\pdv_compile.mjs --strict-skeleton`) and resolve all FAILs.
- Before declaring a Pattern Proving checkpoint complete, run `node .\tools\pdv_verify.mjs --strict-pattern-proving` (or compile with `node .\tools\pdv_compile.mjs --strict-pattern-proving`) and resolve all FAILs.
- Before declaring Phase 7 signal expansion complete, run `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.
- Before declaring Phase 8 reputation-track closeout complete, run `node .\tools\pdv_verify.mjs --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` (or compile with the same strict flags) and resolve all FAILs.

### Default closeout loop

Use this as the default order after substantive PDV work:

1. Compile changed Papyrus with `tools\pdv_compile.mjs` if any `.psc` changed.
2. If the work touched CK/ESP/MO2 state, run `tools\pdv_verify.mjs` and use
   the relevant strict gate before calling the change done.
3. If the work was supported existing-record wiring, prefer a tracked
   `pdv_author` manifest plus `plan -> apply -> verify` over repeated one-off
   CK edits.
4. If a design review locked a new rule, ratify it across the living docs in
   the same session so `AGENTS.md`, setup notes, and race/design docs do not
   drift.

This order reflects the recent project pattern: the expensive mistakes are not
usually raw code edits, but stale record wiring, one-off overlay drift, and
design decisions that were only updated in one place.

### VS Code Papyrus extension role

Editor-only: syntax highlighting, hover info, intellisense, debug attach. Not the build path.

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
- If `SKI_ConfigBase.pex` ever appears in `Devotion\Scripts` after a compile, delete it and fix the compile target list. PDV's wrapper should compile PDV scripts only; this file appearing would indicate accidental SkyUI source compilation.

---

## Project ESP Structure

### File Naming Convention

```
PlayerDevotion_Framework.esp    â† master file, all races depend on this
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
PlayerDevotion_Framework.esp:
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

All records use the prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals (config, debug, dev) add a second underscore (`PDV_GLO__X`). Borrowed from the Gods And Worship taxonomy â€” lets a CK or xEdit reader recognize the role of a record from its name alone.

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
[PDV]  â† your trace messages will appear here
error  â† search this to find script errors
warning â† non-fatal issues worth addressing
```

**Recommended log viewer:** Notepad++ with auto-refresh enabled.
Open log â†’ Edit â†’ Monitoring (tail -f equivalent).

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
| `PDV.Piety` | 0â€“200 | Current piety. Source of truth. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Consolidated at dawn, then reset. |
| `PDV.Tier` | 0â€“3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Grace period tracking + MCM display |

Read/write via `StorageUtil.GetFloatValue(deityForm, key)` / `StorageUtil.SetFloatValue(deityForm, key, value)`. PapyrusUtil SE is an SKSE DLL â€” no ESP master required, just call it directly.

### Mirror GlobalVariables (active patron only)

| EditorID | Type | Purpose |
|----------|------|---------|
| `PDV_GLO_ActivePiety` | Float | Active patron's current `PDV.Piety` |
| `PDV_GLO_ActiveTier` | Float | Active patron's tier (0â€“3) |
| `PDV_GLO_ActiveDeityIndex` | Float | Stable int for active deity. -1 = none |

Mirrors are write-only caches refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()`. Never read them as source of truth â€” always read StorageUtil. Never write them directly â€” always call `AwardPiety` or `RecomputeTier`.

### Tier Thresholds (defaults, tunable per-deity in Phase 2+)

| Tier | Label | Piety threshold |
|------|-------|----------------|
| 0 | None | < 10 |
| 1 | Seeker | â‰¥ 10 |
| 2 | Devoted | â‰¥ 50 |
| 3 | Champion | â‰¥ 150 |

### System GlobalVariables (Phase 2+)

| EditorID | Purpose |
|----------|---------|
| `PDV_GLO_OriginRace` | Permanent cultural origin race index 0â€“9, set once at game start |
| `PDV_GLO_PatronDeity` | FormID of active patron. 0 = none |
| `PDV_GLO_DebugLevel` | 0â€“3 trace verbosity, MCM-toggleable |

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
- Dialogue topics live inside Quest forms, not as top-level Object Window records.
- CK condition names are not always Papyrus method names. Example: Papyrus `IsDead()` maps to CK condition `GetDead`.
- Keep related `Link To` chains in the same branch when possible; cross-branch links can fail if the target branch conditions do not pass independently.
- Hello topics auto-fire by proximity. Do not use Force-Activate for normal Hello greetings.
- Keep dialogue lines under 80 characters where possible, and regenerate SEQ after dialogue edits.

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
[x] PlayerDevotion_Framework.esp created
[x] PDV__ManagerQuest (Start-Game-Enabled) and PDV__MainQuest (RunOnce) created in CK
[x] Phase 0 â€” PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 â€” StorageUtil data model; mirror globals declared and verified in-game;
      PDV__ManagerQuest refactored with AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors
[x] Phase 2 â€” PDV_DeityBase + PDV_Deity_Kyne; PDV_FLST_AllDeities; ProcessDawn loop;
      CK compile/wiring/runtime verification complete
[x] Phase 3 â€” PDV_ActionRouter + PDV__SM_KillActor complete;
      CK wiring, Story Manager routing, SEQ, and runtime verification all passed
[x] Phase 4 â€” scripts/tooling, framework ESP wiring, and full in-game proof passed
[x] Phase 5 â€” MCM dev slice script/tooling/framework wiring landed; in-game SkyUI proof passed
[x] Phase 6 â€” Talos + Auri-El hostile-path proof slice framework-wired and full in-game proof passed
[x] V3 Preflight - script/tooling, framework-owned record wiring, strict verifier gate, and clean-start smoke complete
[x] V3 Structural Skeleton - broad structural systems scaffold is merged, strict-verifier clean, and runtime-smoked
[ ] Debug spell created and tested
[ ] Nord module complete
```

Check off as you go. If something at step N breaks, the problem is in step N â€” not step N-7.

---

## Common Errors and Fixes

**CK crashes on load:**
Usually a corrupted plugin. Check your load order in MO2. Ensure no plugin has a missing master.

**Script compiles but quest doesn't run:**
Confirm `Start Game Enabled` is checked on the quest record in CK. Confirm the script is attached to the quest (Quest â†’ Scripts tab, not just saved in the source folder).

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

**.gitignore** â€” exclude compiled scripts and CK temp files:

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

**2026-05-23 - CKRA GLOB duplicate-create proof:** `glob.duplicate_create` is now the first narrow CKPE authoring capability promoted by proof ledger. Evidence chain: guarded Object Window duplicate replay, GLOB duplicate identity, in-memory FNAM/FLTV mutation to short `1`, CK UI save, direct saved-ESP readback, strict run report, strict proof ledger, and generated capability-matrix promotion. User-experience lesson: Object Window selection/focus/context-menu behavior is not incidental; CK automation must either reproduce or explicitly guard it. Lower-layer lesson: live memory proof is insufficient without active-plugin save and filesystem readback. This is generated-plugin infrastructure only and does not change PDV runtime phase status.

**2026-05-21 - Phase 8 runtime proof closeout and overlay lesson:** Phase 8's Imperial Concordat pilot is now runtime-proven end to end on an Imperial save. Baseline `Uncommitted`, pending start/cancel, 3-day commit into `PublicCompliant`, committed-state multiplier persistence under raw rollback, 3-day commit into `ConcordatEnforcer`, halved inward movement while the extreme gate was locked, save/load persistence before and after gate unlock, and 3-day exit back to `PublicCompliant` all passed. `tools\pdv_verify.mjs --strict-phase8` is now part of the live closeout ladder, and the combined compile+verify gate stayed fully clean at `FAIL=0, WARN=0, TODO=0, PASS=642, INFO=28` on 2026-05-20 20:20:45 AEST. Durable lesson: `PDV_Phase8ConcordatTalosOverlay.esp` should not be treated as the steady-state runtime wiring path; partial VMAD overrides can win with blank/default Talos values. The live fix is manager-owned runtime wiring plus save-healing in `PDV__ManagerQuest`, and the overlay should remain inactive unless it is explicitly rebuilt as a full safe override.

**2026-05-09 â€” Framework vs. Monolithic:** One core ESP owns the quest spine and globals. Nine race ESPs patch in as modules.

**2026-05-09 â€” Dawn detection:** `RegisterForUpdateGameTime(1.0)` with hour-window check. Chosen over Story Manager dawn event for reliability.

**2026-05-09 â€” Bootstrap / Manager quest split:** `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (Start-Game-Enabled runtime). Runtime owns the mirror globals API and the dawn consolidation loop.

**2026-05-09 â€” Naming taxonomy:** Internal/machinery records prefixed `PDV__X`; runtime Globals prefixed `PDV_GLO_X`; internal/system Globals prefixed `PDV_GLO__X`. See Â§ EditorID Prefix Convention above.

**2026-05-10 â€” Variable storage (v2):** StorageUtil (PapyrusUtil SE) is source of truth for all per-deity piety/tier values, keyed by deity FormID. Three mirror GlobalVariables shadow the active patron's values for vanilla CK Condition reads. Mirrors are write-only caches. `PDV_GLO_DevotionLevel` and the three buckets removed.

**2026-05-10 â€” PapyrusUtil SE:** SKSE DLL plugin â€” no ESP master, no xEdit step. Call `StorageUtil.*` directly. Never add as a plugin master.

**2026-05-18 - PO3 Papyrus Extender dependency:** PDV v3 accepts powerofthree's Papyrus Extender as a hard runtime dependency for event hooks that vanilla Story Manager/player aliases cannot expose cleanly. This also makes Address Library for SKSE Plugins and powerofthree's Tweaks required runtime SKSE-plugin dependencies. These are not ESP masters. Use PO3 for runtime event hooks, not keyword/classification/NPC distribution; that remains offline patcher territory. SPID remains deferred for future cost-benefit review if PDV needs actor-load distribution, outfit lifecycle behavior, or broad dynamic injection that generated patches cannot represent cleanly.

**2026-05-19 - Race end-state implementation-lock pass:** The player-experience lock pass now lives in `PDV_TargetEndStates_1.0.md`, `race-sheets/*.md`, and `references/PDV_RaceArchitecture_DesignReference.md`. Breton is implementation-locked for 1.0 experience shape; reward numbers remain tuning. Altmer is partially closed: shared patron-state use, no generic broad lane, `ThalmorAlignment` bands/start values, crisis-of-faith posture, and bounded Lorkhan economy are locked. Altmer Lorkhan pressure must use explicit tags/hooks, basic devotional upkeep should trend positive, and ordinary existence in Skyrim is not a penalty source. Remaining Altmer closeout is crisis resolution hooks, final crisis trigger list, contextual favor lanes, and focused-deity hook posture.

**2026-05-19 - Documentation authority cleanup:** `PDV_TargetEndStates_1.0.md` is now the living 1.0 product/end-state tracker. Improve Codebase Architecture review result: keep v3 as the deep architecture module, keep the target-end-state doc as the launch acceptance and roadmap-traceability module, keep the race architecture reference as the locked theology/rule module, and keep race sheets as player-facing race-experience modules. The separate beta-brief surface was removed to reduce duplicate beta/launch claims.

**2026-05-19 - v3.16 implementation handoff hardening:** `PDV_Architecture_v3.md` Section 21.5 now owns the build-facing handoff plan from Pattern Proving through the first cloned systems. Before starting a slice, use the first implementation packet checklist and handoff-card fields there: source contract, owning module, interface guarantee, data/state shape, implementation locations, entry gate, verifier gate, normal-play proof, exit/recovery, not-in-scope boundary, and docs touched. The section also maps open decisions to blockers, defines the verifier command ladder for declaring slice completion, and makes the later Daedric pilot consume the race-sheet/matrix hardening contract before any Prince/race implementation begins.

**2026-05-20 - Phase 19 tooling foundation kickoff:** Added `tools\pdv_patch.mjs` as the planning-first entrypoint for PDV's locked offline classification/distribution patcher direction. v0 validates tracked `pdv_patch_rules_v0` manifests under `references\authoring\patch-rules\`, reads the resolved `Devotion Dev` load order through the same Mutagen/MO2 context already used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning records for keyword/FormList/NPC distribution planning, and emits deterministic dry-run review output without writing a generated patch ESP yet. `tools\pdv_author.mjs` planning/status output now also promotes VMAD-array work into explicit manual follow-up packets with intended payload plus verifier readback expectations instead of generic unsupported reminders.

**2026-05-20 - PDV_MCM duplicate VMAD cleanup packet:** The live `PDV_MCM` duplicate warning is now reduced to one exact manual consolidation target, documented in `references\authoring\PDV_MCM_VMAD_Consolidation_Checklist.md`. Current split on `PlayerDevotion_Framework.esp` is three same-name `PDV_MCM` VMAD entries: `#0` owns the original manager/active-global block, `#1` owns the structural-system FormLists plus `PDV_CurseStateService`, and `#2` owns `PDV_EventBusService`. The intended steady state is one canonical `PDV_MCM` attachment with all 14 required properties, then removal of the other two same-name rows. `PDV_VmadConsolidationOverlay.esp` remains a reference/safety artifact only; merge-back into the framework record is the path that actually clears the strict verifier warning.

**2026-05-20 - Hidden shrine reference wiring lesson:** Phase 7's Talos shrine proof surface should be wired on the actual hidden shrine reference, not by defaulting to a nearby helper activator. The tracked manual contract now names `PDV_REFR_TalosShrineDefianceSignal` as the real hidden shrine reference once the EditorID is assigned, and `tools\pdv_verify.mjs --strict-phase7` now treats that co-attached reference as the readback target. Preferred compatibility posture is per-reference co-attachment first, helper objects only as fallback proof shapes, and no global shrine base-script replacement.

**2026-05-20 - PDV doc-sync learning capture rule:** `skills\pdv-doc-sync\SKILL.md` now treats lessons learned as a mandatory closeout step instead of an implied extra. Every PDV doc sync should either record durable learnings in the narrowest living doc or say explicitly that no new durable learnings qualified.

**2026-05-19 - Slice 0/1 implementation packets:** The current combined strict verifier baseline is `node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton --strict-pattern-proving --json` => `PASS=458, WARN=2, INFO=28`, no `FAIL` or `TODO`, at 2026-05-19 16:44 AEST. Treat the two warnings (`PDV_MCM` duplicate VMAD and stale SEQ freshness) as known waivers until manual consolidation or a post-CK SEQ refresh. Slice 1 implementation should add only normal-play triggers into existing EventBus routes for Dunmer portable shrine/home bonus, Bosmer Green Pact violation, and Hircine hunt rite; do not broaden into full Green Pact tagging, Daedric price/stigma, curse detection, or content cloning during that closeout.

**2026-05-10 â€” CK compiler toolchain, revised 2026-05-12:** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output to `Scripts\`. Terminal/Codex compiles use `tools\pdv_compile.mjs`, which spawns `PapyrusCompiler.exe` directly with `<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`. CK compiler (Ctrl+F7) remains valid for interactive CK work. `compile.ps1`, `skyrimse.ppj`, and Bethesda's shipped `ScriptCompile.bat` are legacy/stale artifacts and should not be used.

**2026-05-10 â€” Console command source of truth:** `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed working: `GetGlobalValue <var>` (read), `set <var> to <value>` (write). `cgf` does not work on instance functions.

**2026-05-11 â€” Phase 2 verified:** `PDV_DeityBase`, `PDV_Deity_Kyne`, and `PDV__ManagerQuest` compile and are wired in CK. In-game testing verified patron activation, mirror globals, dawn clamp, persistent piety consolidation, and tier threshold transition.

**2026-05-11 â€” Phase 3 preflight:** Keep `PDV_ActionRouter` as a persistent service quest. Use a separate non-Start-Game-Enabled receiver quest (`PDV__SM_KillActor`) for the Kill Actor Story Manager event. The receiver handles `OnStoryKillActor`, calls the router, then stops/resets. PDV Story Manager nodes must check `Shares Event`; event capture writes only through `AwardPiety()` into `PDV.PietyToday`.

**2026-05-11 â€” Phase 3 scripts compiled:** `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` were added to `Scripts\Source` and compile to `.pex` in `Devotion\Scripts`. The first compile caught Papyrus name-shadowing issues (`ActorBase`, `Message`), which were fixed before final compile.

**2026-05-14 - Phase 3 complete:** `PDV_ActionRouter` and `PDV__SM_KillActor` quest records are created and wired in `PlayerDevotion_Framework.esp`; the Kill Actor Story Manager receiver node exists with `Shares Event`; `PlayerDevotion_Framework.seq` is generated under `Devotion\Seq`; Papyrus logging is enabled in the `Devotion Dev` profile. Runtime verification passed for Kyne activation, hostile bandit scoring (`event 2`, `+0.5` scratch), hostile wolf scoring (`event 1`, `-3.0` scratch), neutral-kill rejection, rapid dual-kill accumulation, and dawn consolidation/clamping.

**2026-05-11 â€” Local Codex skills:** `pdv-doc-sync` and `pdv-papyrus-ck` skill sources live under `skills\` in this docs project, are packaged as `.skill` files, and are installed under `C:\Users\Admin\.codex\skills`.

**2026-05-12 â€” PDV local toolchain:** `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs` are the local health/build loop for the Anvil/Devotion setup. The compiler directly spawns the verified `PapyrusCompiler.exe` CLI with short `-f`, `-i`, and `-o` args, compiles active PDV scripts into `Devotion\Scripts`, treats warnings as failures, and runs the verifier after successful compiles. Normal verifier mode should remain useful during active implementation; strict Phase 3 mode intentionally fails until `PDV_ActionRouter`, `PDV__SM_KillActor`, and the Kill Actor Story Manager node exist in the ESP.

**2026-05-15 â€” PDV overlay authoring tool, revised 2026-05-16:** `tools/pdv_author.mjs` is the safe automation path for CK-adjacent ESP wiring on existing PDV records. It reads `PlayerDevotion_Framework.esp` through the same local Mutagen bridge as the verifier, then writes **reversible overlay patch plugins** into the `Devotion` mod rather than mutating the framework ESP in place. v1 scope is intentionally narrow: existing-record scalar/object VMAD properties and FormList membership only. New records, VMAD array properties such as `RivalDeities`, and Story Manager tree authoring remain manual CK/xEdit work. Generated patches must keep `Skyrim.esm` as the first master when using extended FormID ranges; do not manually insert masters into an existing patch without remapping FormIDs.

**2026-05-16 - Temporary overlays merged back and retired:** `PDV_ManagerPatronWirePatch.esp` and `PDV_MCMWirePatch.esp` were temporary rescue artifacts for CK instability. Their VMAD deltas have been merged directly into `PlayerDevotion_Framework.esp`: `PDV__ManagerQuest` now owns `PDV_GLO_PatronDeity`, and `PDV_MCM` is script-attached with required properties on the framework record. Both overlays are unticked in the `Devotion Dev` profile and must not be treated as runtime requirements.

**2026-05-16 - Manifest-driven property wiring overlays:** `tools/pdv_author.mjs` now supports tracked JSON manifests under `references\authoring\`. The first target, `mcm-property-wiring`, batches the current `PDV_MCM` property contract into one canonical `PDV_PropertyWiringOverlay.esp` overlay so the Devotion Dev profile does not accumulate per-property `PDV_Author_one_off_*` patches during CK instability.

**2026-05-14 - Anvil MO2 MCP Codex intake, updated 2026-05-16:** `references/PDV_Anvil_MO2_MCP_Intake.md` documents the local `Anvilmo2_mcp` plugin, the `mo2_*` tool surface, current Codex config, and optional tool status. Codex points at `http://127.0.0.1:27016/mcp`; the server must be started from MO2 before tools appear. The plugin is configured for Anvil's Papyrus compiler/source paths and uses `Devotion` as the MCP output mod default. `BSArch.exe` is installed for BSA/BA2 archive tools; `nif-tool.exe` remains the only confirmed missing optional binary.

**2026-05-14 - Skyrim modding lessons intake:** Archived external practical lessons at `archive/Skyrim_Modding_Lessons_2026-05-14.md` and folded durable rules into the living docs and Papyrus/CK skill: player-facing ASCII, Papyrus string/docstring/parser limits, save-baked new-game retesting, grep-before-delete hygiene, `cqf` named-function limits, and future dialogue/faction gate discipline.

**2026-05-16 - Phase 4/5/6 framework status:** The live ESP now contains the Phase 4 proof-slice surface, framework-owned manager patron wiring, the Phase 5 `PDV_MCM` quest/script/properties, and the coupled Talos + Auri-El record set with FormList membership, origin references, stance rows, rivalry wiring, and boon assignments. The verifier currently reports `FAIL=0, WARN=0, TODO=0`; remaining verifier output is informational only.

**2026-05-15 - SkyUI CK header shim:** Repeated CK fatal errors traced back to a broken SkyUI source-store chain (`SKI_QuestBase` -> `SKI_ConfigBase` -> `SKI_ConfigManager`). For the `Devotion Dev` profile, a dedicated shim mod was added at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\` exposing `SKI_QuestBase.psc`, `SKI_ConfigBase.psc`, and `SKI_ConfigManager.psc` under `Source\Scripts\`. This is a CK-environment repair for source lookup only, not a runtime SkyUI upgrade. The profile modlist was backed up before enabling the shim.

**2026-05-16 - Phase 5 in-game proof and ReShade caveat:** With `ReShade64.dll` temporarily renamed out of `D:\Wabbajack\modlists\Anvil\Stock Game\`, `PlayerDevotion` registered in SkyUI and the first MCM slice passed its live smoke test: `Status` and `Debug` both loaded, the Kyne/Talos/Auri-El roster rendered, and debug patron override worked. Two separate CTDs before that were traced to native crash stacks dominated by `ReShade64.dll`, `WS2_32.dll`, and `webio.dll`, with no matching PDV MCM fault in Papyrus. Treat ReShade as a separate environment investigation, not a blocker on PDV Phase 5 completion.

**2026-05-16 - Phase 4 and Phase 6 full closeout proof:** Phase 4 and Phase 6 are now proven in game end to end, not just verifier-clean. The closeout pass covered clean-start origin bootstrap, seeded ledger expectations, patron-only boon grant/removal, rivalry-driven Talos hostile-path transfer against Auri-El across dawn consolidation, and save/load sanity on the proven final state. The Phase 6 pass also exposed a real workflow gap: curated Talos/Auri-El signal testing was not reachable through the previously proven debug surface, so `PDV__ManagerQuest` and `PDV_MCM` were extended with a surfaced curated-signal debug helper rather than relying on an unproven console `cqf` path.

**2026-05-16 - v3 roadmap and beta gates:** `PDV_Architecture_v3.md` now owns the forward roadmap after the proven Phase 4/5/6 baseline. The roadmap separates structural completeness from content completeness, requires V3 Preflight before Phase 7 signal expansion, adds a Structural Skeleton pass for dev-only 1.0 scaffolding, and defines Technical Beta, Content-Feel Beta, and content-rich 1.0 launch readiness.

**2026-05-16 - v3 Section 24 cleanup:** `PDV_Architecture_v3.md` now removes already-settled decisions from the open tracker instead of leaving them as recommended-but-open items. Resolved IDs are D-09, D-11, D-15, D-16, D-18, D-24, D-25, D-26, D-27, D-28, D-29, and D-32. The operational defaults are structural completeness first, monolithic 1.0, strong substrates only for Khajiit/Dunmer/Argonian, shrine overlays, Tier 2 broad worship, three-option commitment offers, curse-state pressure without automatic Daedric unlocks, thematic UI by default, in-world patron switching, concrete pattern cloning, FormList-driven MCM ordering, Phase 12 stack-depth benchmarking, and documented Wintersun coexistence.

**2026-05-16 - v3 doc cleanup and scaffold-code contract:** `PDV_Architecture_v3.md` v3.8 and `references\PDV_RaceArchitecture_DesignReference.md` now treat old bucket terms as legacy design-axis shorthand, not implementation state. The first Structural Skeleton code pass added compile-clean optional base scripts: `PDV_ReputationTrack`, `PDV_StateTrack`, `PDV_SubstrateBase`, `PDV_SacredPlace`, `PDV_DaedricPathBase`, and `PDV_CurseState`. No phase-order change: Structural Skeleton remains next, Pattern Proving remains the first content-bearing wave, and no v2 implementation needs reopening solely because of the race sheets.

**2026-05-16 - V3 Preflight script/tooling slice:** Added compile-clean `PDV_EventTypes` and `PDV_EventBus`, routed the kill-event canary through attribution-aware payload hooks while preserving direct-player v2 scoring, split manager dawn/gain logic into named Preflight extension slots, added patron-state and custom-race fallback diagnostics, and expanded compiler/verifier coverage. CK/xEdit record creation and in-game smoke remain pending before V3 Preflight is complete.

**2026-05-16 - V3 Preflight reversible canary:** `references\authoring\PDV_PreflightRouterServices.manifest.json` now drives `PDV_PreflightRouterServicesOverlay.esp`, a reversible overlay that co-attaches `PDV_EventTypes` and `PDV_EventBus` to `PDV_ActionRouter` and points the router at those services on the same quest record. This was chosen because the safe authoring path can attach scripts to existing records but cannot mint new quests/globals; at this canary stage, `PDV_GLO_PatronState` and framework-owned record creation were still follow-up tasks.

**2026-05-16 - V3 Preflight gate closed:** Framework-owned `PDV_GLO_PatronState`, `PDV_EventTypes`, and `PDV_EventBus` are now present and wired directly in `PlayerDevotion_Framework.esp`; `PDV_ActionRouter` now points to framework-owned EventBus/EventTypes services; strict preflight verification runs clean (`node .\tools\pdv_verify.mjs --strict-preflight --json` => `FAIL=0`); and clean-start in-game smoke A-F passed (MCM load, origin seed, patron-state transitions, dawn consolidation, non-hostile no-change, hostile direct scratch gain + dawn consolidation, rivalry proof on hostile stance path, save/load sanity). `PDV_PreflightRouterServicesOverlay.esp` can remain as historical canary but should stay inactive at runtime.

**2026-05-17 - V3 broad structural scaffold gate closed:** The broad Structural Skeleton pass is now merged into `PlayerDevotion_Framework.esp`. New substrate, sacred-place, Hircine, curse-state, FormList, and `PDV_MCM` scaffold wiring is present on the framework ESP; `references\authoring\PDV_StructuralSystemsScaffold.manifest.json` and `references\authoring\PDV_StructuralSystemsArrays.manifest.json` are the tracked authoring/readback companions; and `tools\pdv_author.mjs` now recognizes array manifest syntax for planning while keeping array writes manual. Gate-close verification is clean: `node .\tools\pdv_verify.mjs --strict-skeleton` and `node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton` both return `FAIL=0, WARN=0, TODO=0, PASS=401, INFO=30`. Runtime smoke also passed in game on the `PDV_MCM` Debug page: `Show structural map` and `Run scaffold smoke` completed without changing patron mirrors, dawn behavior, or EventBus routing, and Papyrus confirmed read/write/restore traces for reputation, state, substrate, sacred-place, daedric, and curse scaffolds.

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

**2026-05-20 - Overnight enabler implementation pass:** The first approved overnight pull-forward work is now real in source and docs without changing slice completion claims. `PDV__ManagerQuest.psc` now records per-deity commitment signal days from positive piety writes, requires two signal days within seven plus no active per-deity cooldown before the Kyne commitment pilot can offer, moves decline/refuse timing off the old global cooldown keys onto deity-local storage, removes the active-patron decay exemption, and guards decay to once per in-game day. The Prisma overlay path now canonicalizes deprecated toast aliases into a stable five-event contract for `favor`, `dawn`, `neglect`, `tier`, and `rivalry`; the bridge README and `PDV_Architecture_v3.md` Section 16.6 now agree that those overlay toasts are stable while panel payloads and other event shapes remain prototype. Verification for the pass stayed clean: `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` succeeded on 2026-05-20 21:06:27 AEST, and `node .\tools\pdv_verify.mjs --strict-pattern-proving` also passed on 2026-05-20 21:06:41 AEST with zero `FAIL`, `WARN`, and `TODO`. Remaining proof boundary for tomorrow is runtime smoke on accepted-patron decay, a staged Kyne two-signal-day offer check, and deciding whether `Refuse` should eventually apply an authored piety-drop fraction.

**2026-05-20 - Phase 7 Civil War join markers locally confirmed:** The final open Phase 7 social-pressure packet is now narrowed to exact local records rather than seed prose. Local `Skyrim.esm` readback confirmed `CW01A` (`Joining the Legion`, `Skyrim.esm:0D517A`) and `CW01B` (`Joining the Stormcloaks`, `Skyrim.esm:0E2D29`) as the first clean join markers; both expose objective `160` `Take the oath` and complete at stage `200`. The recommended hook point is stage `200` on both quests because it is the verified once-only completion surface. The manual fragment contract is now documented in `references\authoring\PDV_Phase7_CivilWar_Closeout_Checklist.md`: preferred path is a vanilla-safe SKSE mod event line in the fragment, `SendModEvent("PDV.ConcordatCompliance")` on `CW01A` and `SendModEvent("PDV.ConcordatDefiance")` on `CW01B`. `PDV_PlayerEvents` now registers these mod events on the live player alias and routes them through `PDV_EventBus.RouteConcordatPressure(...)`. This became the preferred posture after CK fragment compilation repeatedly proved brittle around custom PDV script visibility and duplicate/ghost fragment-property state. These hooks move `ConcordatStanding` only; Talos award remains the hidden-shrine defiance route.

**2026-05-20 - Phase 7 external-hook verification boundary:** The current strict verifier now fully covers PDV-owned Phase 7 surfaces and is clean at `FAIL=0, WARN=0, TODO=0`, but it does not yet read back external vanilla quest fragment edits on `CW01A` / `CW01B`. Treat the Civil War fragment wiring plus runtime smoke as the real final closeout step even though the PDV-owned strict gate is already green. The dedicated operator packet for that last mile now lives in `references\authoring\PDV_Phase7_CivilWar_Closeout_Checklist.md`.

**2026-05-20 - Phase 7 fully closed:** The last manual packet is now done. `CW01A` stage `200` and `CW01B` stage `200` both compile and save on the live framework ESP using the tiny fragment calls `SendModEvent("PDV.ConcordatCompliance")` and `SendModEvent("PDV.ConcordatDefiance")`. Runtime proof in `Papyrus.0.log` now shows the full external-hook chain for both sides: at 16:38:24 AEST, `CW01A` logged `PlayerEvents: Concordat compliance mod event routed.` with `EventBus: RouteConcordatPressure complete: 20 adjustment 15`; at 16:42:44 AEST, `CW01B` logged `PlayerEvents: Concordat defiance mod event routed.` with `EventBus: RouteConcordatPressure complete: 21 adjustment -15`. No Talos award is attached to either Civil War join marker. Durable lesson: for vanilla quest fragments, `SendModEvent(...)` proved more reliable and more compatibility-friendly than fragment properties, inline EventBus casts, or helper-bridge plumbing, while keeping all real devotion math inside PDV-owned scripts. The post-closeout strict gate was rerun and stayed fully clean: `node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving` => `FAIL=0, WARN=0, TODO=0, PASS=588, INFO=28` at 2026-05-20 16:44 AEST.

**2026-05-18 - Khajiit sleep ingress proof and origin-runtime lesson:** The `PDV_Player` alias is now live on `PDV__ManagerQuest` with `PDV_PlayerEvents` attached and its three alias properties filled (`PDV_EventBusService`, `PDV_OriginQuest`, `PDV_GLO_DebugLevel`). The debugging lesson from this pass is that the hard part was runtime timing, not missing linkage: fresh/load paths could still see Skyrim's temporary Nord placeholder and bake `PDV_GLO_OriginRace = 0` before Khajiit settled. `PDV__MainQuest` now defers origin work to alias-side ingress, `PDV_PlayerEvents` queues origin retries, and `PDV_Origin` treats the first Nord read as provisional. Early Khajiit sleep attempts before resetting the live runtime global should be treated as exploratory only, not counted proof. Counted Khajiit smoke should reset the runtime global in-game if a stale save already baked the wrong value, confirm `PDV_GLO_DebugLevel = 2`, then sleep once and inspect `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. The counted proof on 2026-05-18 showed `EventBus: RouteSleepStop complete`, `Manager: Khajiit moon observance routed...`, and `KhajiitLunar: Moon observance recorded...` with `PDV_GLO_OriginRace` holding at `6`. The later Slice 1 receiver pass closed the remaining Dunmer normal-play shrine trigger boundary.

**2026-05-18 - Prisma UI bridge scaffold:** Prisma UI's API header is installed and visible through the Anvil MO2 MCP. Added `native\DevotionPrismaBridge\` as the first C++ SKSE bridge scaffold, vendored `PrismaUI_API.h`, mirrored the initial `PrismaUI\views\Devotion\` HTML/CSS/JS panel into the live `Devotion` mod, and added compile-clean native Papyrus declarations in `PDV_PrismaBridge.psc` / `.pex`. Visual Studio Build Tools 2022 and portable xmake are now installed locally; the `releasedbg` DLL builds cleanly, exports the expected SKSE plugin entrypoints, and copies `DevotionPrismaBridge.dll` / `.pdb` to `Devotion\SKSE\Plugins\`. The vendored local Prisma header is intentionally shimmed for CommonLibSSE-NG by avoiding `Windows.h`, while the installed MO2 Prisma API header mod remains unchanged.

**2026-05-19 - Prisma devotional UX prototype:** The first real Prisma view now renders a devotional panel rather than a raw metric card: Patron, Today, and Debug tabs; stance/rivalry notes; piety progress; recent devotional acts; suggested rites; and payload-driven transient toasts. Toast/panel marks now use an inline SVG symbol registry for deities and system notices instead of initials, with larger marks and thicker rings for readability. The bridge/native DLL now exports the new Papyrus route `SendOverlayJson(payload)` so event toasts can use the overlay receiver without focusing the panel path. `PDV__ManagerQuest` gained the first Papyrus toast helper plus dawn and active-patron positive-gain hooks. The Prisma client now expands compact event payloads for `favor`, `dawn`, `neglect`, `tier`, and `rivalry` into authored-feeling tone/title/message defaults while still allowing explicit copy overrides. Updated `index.html`, `styles.css`, and `app.js` were mirrored to `D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\` for in-game iteration. A single-file static share demo lives at `scratch\DevotionPrismaDemo.html`; it embeds the current CSS/JS and forces demo mode for Discord-style preview sharing.

**2026-05-19 - Prisma bounded-monorepo decision:** Keep Prisma UI in the main PDV repo for now as a bounded subsystem under `native\DevotionPrismaBridge\`. This keeps the SKSE bridge, Papyrus native declaration, Prisma view source, and payload contract together while the UI is tightly coupled to PDV runtime events. `scratch\DevotionPrismaDemo.html` is a generated/share review artifact, not canonical source. Reassess a separate UI repo only if Prisma gains its own JS build system, asset pipeline, UI test suite, independent release cadence, non-PDV reuse target, or recurring context noise for Papyrus/CK work.

**2026-05-16 - Completed phase docs archived:** Finished Phase 2/3 walkthroughs, older planning/delivery notes, and the now-complete Phase 4/5/6 CK walkthroughs were moved to `archive/completed-phase-docs-2026-05-16/` so the root folder stays focused on living architecture/setup/standards docs.

**2026-05-16 - Recovery artifacts archived:** One-off repair/generation files from the overlay merge-back and MCP bridge investigation were moved to `archive/pdv-recovery-tools-2026-05-16/`. They are historical/emergency-only. The active PDV workflow remains `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, `tools/pdv_author.mjs`, and the living CK step docs at repo root.

**2026-05-16 - Schema-first authoring posture:** Text-first ESP authoring via a future Mutagen-backed build tool is worth keeping as a design direction, but it is not part of the live PDV workflow yet. Until such a tool exists and is verified against the framework, speculative schema drafts are not authoritative project state. The active source-of-truth set remains the living docs, PDV `.psc` files, `PlayerDevotion_Framework.esp`, verifier expectations, and tracked `pdv_author` manifests/overlays.
