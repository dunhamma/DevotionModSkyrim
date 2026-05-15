# Player Devotion — Mod Development Setup Reference
**Project:** PlayerDevotion Framework + Race Modules  
**Engine:** Skyrim Special Edition (SSE)  
**Last Updated:** 4E 201 (update this when your setup changes)

---

## Project File Index

| File | Purpose |
|------|---------|
| `skyrim-gods-reference.jsx` | Cross-cultural deity equivalency table — canonical lore reference |
| `tamriel-daily-worship-4e201.html` | Race-by-race daily practice reference — design source document |
| `PDV_MOD_SETUP.md` | This file — dev environment and architecture reference |
| `tools/pdv_compile.mjs` | PapyrusCompiler wrapper for stale/all/targeted PDV script compiles |
| `tools/pdv_verify.mjs` | Read-only verifier for Anvil/MO2/ESP/script wiring drift |
| `tools/pdv_author.mjs` | Safe overlay-patch authoring helper for supported ESP wiring on existing PDV records |
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
| **Mod Organizer 2** | 2.5.x | Nexus #6194 | Development environment manager |
| **SSEEdit (xEdit)** | 4.x | Nexus #164771 | Conflict checking |

### Scripting & Editing

| Tool | Purpose | Source |
|------|---------|--------|
| **VS Code** | Primary script editor | code.visualstudio.com |
| **Papyrus Extension for VS Code** | Syntax, autocomplete, compile | VS Code marketplace — search "Papyrus" by joelday |
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
[Profile: Devotion Dev]      ← work here (active; inside Anvil MO2 instance)
[Profile: PDV_Testing]       ← optional clean ship-verification profile (create before public release)
[Your normal play profile]   ← never touched by this project
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
---
PlayerDevotion_Framework.esp    ← your core file
PDV_Nord.esp                    ← race module (add as built)
PDV_Imperial.esp
PDV_Dunmer.esp
PDV_Altmer.esp
PDV_Khajiit.esp
PDV_Bosmer.esp
PDV_Redguard.esp
PDV_Orc.esp
PDV_Argonian.esp
```

**Rule:** Keep the Devotion Dev profile minimal — Skyrim/DLC, SKSE, SkyUI, and PDV plugins only. Every additional mod is a potential false positive when debugging. The Anvil instance hosts a full modlist; Devotion Dev is the curated subset for PDV work.

### MO2 Settings to Configure

- **Mod Organizer → Settings → Nexus:** Not needed for development
- **Mod Organizer → Settings → Plugins:** Ensure BSA extraction is ON for vanilla assets
- **Right-click game executable → Edit:** Add `-forcesteamloader` argument if CK fails to launch

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

> `compile.ps1` and `skyrimse.ppj` exist in the mod folder as legacy files from an earlier toolchain. Do not use them — defer to `tools\pdv_compile.mjs` for terminal compiles or the CK compiler for interactive CK work.
>
> `ScriptCompile.bat` in the `Papyrus Compiler` folder is a stale Bethesda development artifact that points at internal `C:\Projects\TESV\Build...` paths. Treat it as an example invocation, not a working wrapper.
>
> **2026-05-12 update:** The active CKPE/MO2 setup now outputs directly into the `Devotion` mod. Source files live in `Devotion\Scripts\Source\`; compiled `.pex` files should land in `Devotion\Scripts\`. If CK cannot see a newly added script, compile that script with `tools\pdv_compile.mjs --script <ScriptName>` using the known SSE import chain documented in `AGENTS.md`.

### Build files (in the mod folder)

| File | Role |
|---|---|
| `SkyrimSE.code-workspace` | VS Code workspace (rooted at the mod folder) |
| `compile.ps1` | Legacy — do not use |
| `skyrimse.ppj` | Legacy — do not use |
| `meta.ini` | MO2 mod metadata — do not edit manually |

### Project layout

```
D:\Wabbajack\modlists\Anvil\mods\Devotion\
  Scripts\
    PDV__ManagerQuest.pex
    PDV_ActionRouter.pex
    PDV__SM_KillActor.pex
    PDV_DeityBase.pex
    PDV_Deity_Kyne.pex
    Source\
      PDV__MainQuest.psc
      PDV__ManagerQuest.psc
      PDV_ActionRouter.psc
      PDV__SM_KillActor.psc
      PDV_DeityBase.psc
      PDV_Deity_Kyne.psc
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
node .\tools\pdv_author.mjs status phase4
node .\tools\pdv_author.mjs plan phase4
node .\tools\pdv_author.mjs apply phase4 --output PDV_Author_phase4.esp
```

The compiler spawns `PapyrusCompiler.exe` directly with the project import chain, compiles active scripts whose `.pex` output is missing or older than source, treats Papyrus warnings as failures, and runs the verifier after successful compiles unless `--skip-verify` is used. The emitted compiler command uses the short canonical flags: `-f=<flags>`, `-i=<source-dirs>`, and `-o=<output-dir>`.

The verifier is read-only. It checks expected Anvil paths, reads `PlayerDevotion_Framework.esp` through the Anvil MO2 MCP Mutagen bridge, validates baseline Phase 2 records and VMAD properties, checks script source/pex freshness, reports SEQ drift, confirms the active MO2 profile/load order, and looks for CK output shadow files. By default, unfinished Phase 3 CK wiring is reported as TODO; use `--strict-phase3` when Phase 3 should be treated as required.

`tools\pdv_author.mjs` is the safe authoring companion to that loop. It inspects the live framework ESP through the same local Mutagen bridge, then emits a **new overlay patch plugin** into the `Devotion` mod when asked to apply changes. Current supported writes are existing-record scalar/object VMAD properties and FormList membership. It does **not** create new records, edit VMAD array properties such as `RivalDeities`, or overwrite `PlayerDevotion_Framework.esp` in place.

### Anvil MO2 MCP status

Codex is configured for the Anvil MO2 MCP server at `http://127.0.0.1:27015/mcp` in `C:\Users\Admin\.codex\config.toml`. Start it from Anvil/MO2 with the `Start/Stop MCP Server` tool entry. Current local intake and optional binary status live in `references/PDV_Anvil_MO2_MCP_Intake.md`.

Toolchain usage rules:
- After any `.psc` edit, run `node .\tools\pdv_compile.mjs` or a targeted `--script` compile.
- After CK/ESP changes, property wiring, FormList edits, SEQ generation, or MO2 profile edits, run `node .\tools\pdv_verify.mjs`.
- Use `node .\tools\pdv_author.mjs` when supported existing-record property/FormList wiring should be scripted into a reversible overlay patch instead of repeated CK clicking.
- Before declaring Phase 3 CK wiring complete, run `node .\tools\pdv_verify.mjs --strict-phase3`.

### VS Code Papyrus extension role

Editor-only: syntax highlighting, hover info, intellisense, debug attach. Not the build path.

### Papyrus authoring gotchas

Keep these in mind before blaming CKPE or MO2 for compile weirdness:

- Papyrus string literals only reliably escape `\\` and `\"`. Do not put `\n`, `\r`, or `\t` in `.psc` strings.
- `{...}` docstrings belong immediately after `ScriptName`, `Property`, `Function`, or `Event` declarations. Use `;` comments inside control flow, and avoid JSON-like literal `{` examples in docstrings.
- `StringUtil.Replace` does not exist. Avoid string substitution in runtime paths unless a manual helper has been compile-tested.
- Papyrus has no ternary operator, string interpolation, string `+=`, `Math.max`, or `Math.min`. Arrays cannot be sized by variables and cap at 128 elements.
- Split chained casts into named intermediate variables. Do not rely on `(value as int as float)` style expressions.
- Do not use short names that may collide with type/script names (`key`, `form`, `actor`, `cell`, `ActorBase`, `Message`) or local names that shadow script properties. Prefer explicit local names such as `targetActor`.
- If a script edit behaves impossibly on an existing save, retest from a new game or main-menu `coc qasmoke` path before redesigning the logic.
- If `SKI_ConfigBase.pex` ever appears in `Devotion\Scripts` after a compile, delete it and fix the compile target list. PDV's wrapper should compile PDV scripts only; this file appearing would indicate accidental SkyUI source compilation.

---

## Project ESP Structure

### File Naming Convention

```
PlayerDevotion_Framework.esp    ← master file, all races depend on this
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

All records use the prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals (config, debug, dev) add a second underscore (`PDV_GLO__X`). Borrowed from the Gods And Worship taxonomy — lets a CK or xEdit reader recognize the role of a record from its name alone.

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
[PDV]  ← your trace messages will appear here
error  ← search this to find script errors
warning ← non-fatal issues worth addressing
```

**Recommended log viewer:** Notepad++ with auto-refresh enabled.  
Open log → Edit → Monitoring (tail -f equivalent).

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
| `PDV.Piety` | 0–200 | Current piety. Source of truth. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Consolidated at dawn, then reset. |
| `PDV.Tier` | 0–3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion |
| `PDV.LastTierChange` | game time | Grace period tracking + MCM display |

Read/write via `StorageUtil.GetFloatValue(deityForm, key)` / `StorageUtil.SetFloatValue(deityForm, key, value)`. PapyrusUtil SE is an SKSE DLL — no ESP master required, just call it directly.

### Mirror GlobalVariables (active patron only)

| EditorID | Type | Purpose |
|----------|------|---------|
| `PDV_GLO_ActivePiety` | Float | Active patron's current `PDV.Piety` |
| `PDV_GLO_ActiveTier` | Float | Active patron's tier (0–3) |
| `PDV_GLO_ActiveDeityIndex` | Float | Stable int for active deity. -1 = none |

Mirrors are write-only caches refreshed by `PDV__ManagerQuest.RefreshPatronMirrors()`. Never read them as source of truth — always read StorageUtil. Never write them directly — always call `AwardPiety` or `RecomputeTier`.

### Tier Thresholds (defaults, tunable per-deity in Phase 2+)

| Tier | Label | Piety threshold |
|------|-------|----------------|
| 0 | None | < 10 |
| 1 | Seeker | ≥ 10 |
| 2 | Devoted | ≥ 50 |
| 3 | Champion | ≥ 150 |

### System GlobalVariables (Phase 2+)

| EditorID | Purpose |
|----------|---------|
| `PDV_GLO_OriginRace` | Race index 0–9, set once at game start |
| `PDV_GLO_PatronDeity` | FormID of active patron. 0 = none |
| `PDV_GLO_DebugLevel` | 0–3 trace verbosity, MCM-toggleable |

Phase 4 implementation note:

- `PDV_GLO_OriginRace` should default to `-1` in CK so `PDV_Origin.InitializeOrigin()` can detect "not initialized yet" safely.
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
[x] Phase 0 — PDV_MasterQuest deleted, rename to PDV__ManagerQuest clean
[x] Phase 1 — StorageUtil data model; mirror globals declared and verified in-game;
      PDV__ManagerQuest refactored with AwardPiety/GetPiety/RecomputeTier/RefreshPatronMirrors
[x] Phase 2 — PDV_DeityBase + PDV_Deity_Kyne; PDV_FLST_AllDeities; ProcessDawn loop;
      CK compile/wiring/runtime verification complete
[x] Phase 3 — PDV_ActionRouter + PDV__SM_KillActor complete;
      CK wiring, Story Manager routing, SEQ, and runtime verification all passed
[~] Phase 4 — scripts/tooling landed; ESP/CK wiring and in-game proof still pending
[ ] Phase 5 — MCM
[ ] Phase 6 — Talos (second deity; proof of scalability)
[ ] Debug spell created and tested
[ ] Nord module complete
```

Check off as you go. If something at step N breaks, the problem is in step N — not step N-7.

---

## Common Errors and Fixes

**CK crashes on load:**  
Usually a corrupted plugin. Check your load order in MO2. Ensure no plugin has a missing master.

**Script compiles but quest doesn't run:**  
Confirm `Start Game Enabled` is checked on the quest record in CK. Confirm the script is attached to the quest (Quest → Scripts tab, not just saved in the source folder).

**Trace messages not appearing in Papyrus.0.log:**  
Confirm `bEnableLogging=1` and `bEnableTrace=1` in CreationKit.ini. Confirm you're looking at the right log file — there may be Papyrus.0.log and Papyrus.1.log. The most recent session is .0.

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

---

## Version Control Setup (Git)

If using Git, initialize in your workspace folder:

```bash
git init
git add .
git commit -m "Initial project structure"
```

**.gitignore** — exclude compiled scripts and CK temp files:

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

**2026-05-09 — Framework vs. Monolithic:** One core ESP owns the quest spine and globals. Nine race ESPs patch in as modules.

**2026-05-09 — Dawn detection:** `RegisterForUpdateGameTime(1.0)` with hour-window check. Chosen over Story Manager dawn event for reliability.

**2026-05-09 — Bootstrap / Manager quest split:** `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (Start-Game-Enabled runtime). Runtime owns the mirror globals API and the dawn consolidation loop.

**2026-05-09 — Naming taxonomy:** Internal/machinery records prefixed `PDV__X`; runtime Globals prefixed `PDV_GLO_X`; internal/system Globals prefixed `PDV_GLO__X`. See § EditorID Prefix Convention above.

**2026-05-10 — Variable storage (v2):** StorageUtil (PapyrusUtil SE) is source of truth for all per-deity piety/tier values, keyed by deity FormID. Three mirror GlobalVariables shadow the active patron's values for vanilla CK Condition reads. Mirrors are write-only caches. `PDV_GLO_DevotionLevel` and the three buckets removed.

**2026-05-10 — PapyrusUtil SE:** SKSE DLL plugin — no ESP master, no xEdit step. Call `StorageUtil.*` directly. Never add as a plugin master.

**2026-05-10 — CK compiler toolchain, revised 2026-05-12:** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output to `Scripts\`. Terminal/Codex compiles use `tools\pdv_compile.mjs`, which spawns `PapyrusCompiler.exe` directly with `<script.psc> -f=<flags> -i=<source-dirs> -o=<output-dir>`. CK compiler (Ctrl+F7) remains valid for interactive CK work. `compile.ps1`, `skyrimse.ppj`, and Bethesda's shipped `ScriptCompile.bat` are legacy/stale artifacts and should not be used.

**2026-05-10 — Console command source of truth:** `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed working: `GetGlobalValue <var>` (read), `set <var> to <value>` (write). `cgf` does not work on instance functions.

**2026-05-11 — Phase 2 verified:** `PDV_DeityBase`, `PDV_Deity_Kyne`, and `PDV__ManagerQuest` compile and are wired in CK. In-game testing verified patron activation, mirror globals, dawn clamp, persistent piety consolidation, and tier threshold transition.

**2026-05-11 — Phase 3 preflight:** Keep `PDV_ActionRouter` as a persistent service quest. Use a separate non-Start-Game-Enabled receiver quest (`PDV__SM_KillActor`) for the Kill Actor Story Manager event. The receiver handles `OnStoryKillActor`, calls the router, then stops/resets. PDV Story Manager nodes must check `Shares Event`; event capture writes only through `AwardPiety()` into `PDV.PietyToday`.

**2026-05-11 — Phase 3 scripts compiled:** `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` were added to `Scripts\Source` and compile to `.pex` in `Devotion\Scripts`. The first compile caught Papyrus name-shadowing issues (`ActorBase`, `Message`), which were fixed before final compile.

**2026-05-14 - Phase 3 complete:** `PDV_ActionRouter` and `PDV__SM_KillActor` quest records are created and wired in `PlayerDevotion_Framework.esp`; the Kill Actor Story Manager receiver node exists with `Shares Event`; `PlayerDevotion_Framework.seq` is generated under `Devotion\Seq`; Papyrus logging is enabled in the `Devotion Dev` profile. Runtime verification passed for Kyne activation, hostile bandit scoring (`event 2`, `+0.5` scratch), hostile wolf scoring (`event 1`, `-3.0` scratch), neutral-kill rejection, rapid dual-kill accumulation, and dawn consolidation/clamping.

**2026-05-11 — Local Codex skills:** `pdv-doc-sync` and `pdv-papyrus-ck` skill sources live under `skills\` in this docs project, are packaged as `.skill` files, and are installed under `C:\Users\Admin\.codex\skills`.

**2026-05-12 — PDV local toolchain:** `tools/pdv_compile.mjs` and `tools/pdv_verify.mjs` are the local health/build loop for the Anvil/Devotion setup. The compiler directly spawns the verified `PapyrusCompiler.exe` CLI with short `-f`, `-i`, and `-o` args, compiles active PDV scripts into `Devotion\Scripts`, treats warnings as failures, and runs the verifier after successful compiles. Normal verifier mode should remain useful during active implementation; strict Phase 3 mode intentionally fails until `PDV_ActionRouter`, `PDV__SM_KillActor`, and the Kill Actor Story Manager node exist in the ESP.

**2026-05-15 — PDV overlay authoring tool:** `tools/pdv_author.mjs` is the safe automation path for CK-adjacent ESP wiring on existing PDV records. It reads `PlayerDevotion_Framework.esp` through the same local Mutagen bridge as the verifier, then writes **reversible overlay patch plugins** into the `Devotion` mod rather than mutating the framework ESP in place. v1 scope is intentionally narrow: existing-record scalar/object VMAD properties and FormList membership only. New records, VMAD array properties such as `RivalDeities`, and Story Manager tree authoring remain manual CK/xEdit work.

**2026-05-15 - Temporary manager overlay workaround:** Because `PDV__ManagerQuest` repeatedly froze CK when opened, a reversible overlay patch `PDV_ManagerPatronWirePatch.esp` was generated and enabled in the `Devotion Dev` profile to supply `PDV__ManagerQuest.PDV_GLO_PatronDeity` at runtime. Treat this as a temporary bridge only. When the manager property is successfully merged back into `PlayerDevotion_Framework.esp`, disable/remove the overlay patch and return the verifier expectation to the framework ESP alone.

**2026-05-14 - Anvil MO2 MCP Codex intake:** `references/PDV_Anvil_MO2_MCP_Intake.md` documents the local `Anvilmo2_mcp` plugin, the `mo2_*` tool surface, current Codex config, and optional tool status. Codex points at `http://127.0.0.1:27015/mcp`; the server must be started from MO2 before tools appear. The plugin is configured for Anvil's Papyrus compiler/source paths and uses `Devotion` as the MCP output mod default. `BSArch.exe` is installed for BSA/BA2 archive tools; `nif-tool.exe` remains the only confirmed missing optional binary.

**2026-05-14 - Skyrim modding lessons intake:** Archived external practical lessons at `archive/Skyrim_Modding_Lessons_2026-05-14.md` and folded durable rules into the living docs and Papyrus/CK skill: player-facing ASCII, Papyrus string/docstring/parser limits, save-baked new-game retesting, grep-before-delete hygiene, `cqf` named-function limits, and future dialogue/faction gate discipline.

**2026-05-15 - Phase 4 CK status:** The live ESP now contains most of the Phase 4 proof-slice surface: `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, Kyne stance wiring, and Kyne boon assignments. The remaining true Phase 4 blocker is `PDV__ManagerQuest.PDV_GLO_PatronDeity`, which was left unwired because CK repeatedly hung when opening the manager quest record. Current verifier failures beyond that property are Phase 6 follow-on expectations, not additional Kyne/bootstrap misses.

**2026-05-15 - SkyUI CK header shim:** Repeated CK fatal errors traced back to a broken SkyUI source-store chain (`SKI_QuestBase` -> `SKI_ConfigBase` -> `SKI_ConfigManager`). For the `Devotion Dev` profile, a dedicated shim mod was added at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\` exposing `SKI_QuestBase.psc`, `SKI_ConfigBase.psc`, and `SKI_ConfigManager.psc` under `Source\Scripts\`. This is a CK-environment repair for source lookup only, not a runtime SkyUI upgrade. The profile modlist was backed up before enabling the shim.

**2026-05-15 - Session closeout state:** `PDV_Phase5_CK_Steps.md` now exists as the manual walkthrough for the first MCM slice. `pdv_verify.mjs` still warns about an unnamed `MGEF` record (`PlayerDevotion_Framework.esp:03235B`, likely orphan residue) and an out-of-date `Devotion\Seq\PlayerDevotion_Framework.seq`. Recommended next-session order is: fresh MO2/CK restart, attempt `PDV__ManagerQuest` first, assign `PDV_GLO_PatronDeity`, refresh SEQ, rerun verifier, then decide whether to keep Phase 4 isolated or continue Phase 6 CK wiring.
