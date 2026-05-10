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

PDV compiles via the **Creation Kit's built-in Papyrus compiler** (Ctrl+F7 in the CK script editor). VS Code with the Papyrus extension provides editor features (syntax, intellisense, hover, format) but does not drive compilation.

> `compile.ps1` and `skyrimse.ppj` exist in the mod folder as legacy files from an earlier toolchain. Do not use them — defer to the CK compiler.

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
├── PDV__MainQuest.psc            ← at root until next compile; migrate to Scripts\Source\ then
├── Scripts\
│   ├── PDV__ManagerQuest.pex     ← compiled output (move here after CK compiles)
│   └── Source\
│       └── PDV__ManagerQuest.psc ← source files live here (CK compiler reads this path)
├── PlayerDevotion_Framework.esp
├── compile.ps1                   ← legacy, ignore
├── skyrimse.ppj                  ← legacy, ignore
├── SkyrimSE.code-workspace
└── meta.ini
```

### Compile workflow

1. Launch CK through MO2 (required — CK needs MO2's virtual filesystem to see mod files)
2. Open script via **Gameplay → Edit Script → File → Open**
3. Compile with **Ctrl+F7**
4. CK outputs `.pex` to the game's `Data\Scripts\` — move it to `Devotion\Scripts\` manually
5. Save the ESP after wiring any new properties

### VS Code Papyrus extension role

Editor-only: syntax highlighting, hover info, intellisense, debug attach. Not the build path.

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
├── PDV__MainQuest                  ← RunOnce bootstrap (stages drive setup)
├── PDV__ManagerQuest               ← Start-Game-Enabled runtime
│                                     (carries PDV_GLO_DevotionLevel + bucket properties)
├── PDV_Action[Event]               ← shared event-detection quests (e.g. PDV_ActionKill)
├── PDV_GLO_DevotionLevel           ← Global, runtime-readable
├── PDV_GLO__Config_*               ← reserved prefix for MCM-mappable config
└── PDV_GLO__Debug_*                ← reserved prefix for dev/debug toggles

PDV_[Race].esp:
├── PDV_Race[Name]Quest             ← per-race tracking quest, depends on framework
├── PDV_Race[Name]Script            ← per-race script (called by PDV__ManagerQuest)
├── PDV_Blessing_[Race]_Low/Mid/High
├── PDV_Neglect_[Race]
└── (per-race dialogue, factions, condition records)
```

Race ESPs declare the framework ESP as a master. Events fire in the framework's `PDV_Action[Event]` quests; the manager quest dispatches to the active race's script.

### EditorID Prefix Convention

All records use the prefix `PDV_`. Internal/machinery records add a double-underscore (`PDV__X`). Globals carry `_GLO_` infix; internal Globals (config, debug, dev) add a second underscore (`PDV_GLO__X`). Borrowed from the Gods And Worship taxonomy — lets a CK or xEdit reader recognize the role of a record from its name alone.

```
# Quest records
PDV__MainQuest                ← internal: RunOnce bootstrap
PDV__ManagerQuest             ← internal: runtime (dawn tick, bucket processing)
PDV_Race[Name]Quest           ← per-race tracking (in race ESP)
PDV_Action[Event]             ← shared event detection (in framework ESP)

# Global Variables (read externally — MCM, condition functions, shrine scripts)
PDV_GLO_DevotionLevel         ← Global, runtime (0–100, drives descriptors)
PDV_GLO__Config_[Setting]     ← Global, MCM-mappable config (reserved)
PDV_GLO__Debug_[Toggle]       ← Global, dev/debug toggle (reserved)
PDV_GLO__DevMode              ← Global, master debug switch (reserved)

# Script properties (read internally only — NOT Globals)
CombatBucket / SocialBucket / LifestyleBucket   ← float properties on PDV__ManagerQuest

# Spell / magic effect records
PDV_Blessing_[Race]_Low/Mid/High
PDV_Neglect_[Race]
PDV_DebugSpell

# Story Manager flag globals (one-shot)
PDV_SMF_JoinedCompanions      ← one-shot flags fired by Story Manager hooks
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
Debug.Trace("[PDV] ProcessDawn fired. DevotionLevel: " + DevotionLevel)
Debug.Trace("[PDV] CombatBucket before reset: " + CombatBucket)
```

Strip or gate these behind a `bDebugMode` property before release.

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

> **Note:** `cgf` only works on Papyrus functions marked `global`. Instance functions on quest scripts (like `AwardPiety`) cannot be called from console directly. Use `set <global> to <value>` to force test states via the mirror globals.

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

---

## Story Manager Hook Reference

These vanilla quest stages trigger one-time direct DevotionLevel shifts.  
Managed via Story Manager Quest Event Nodes in `PlayerDevotion_Framework.esp`.

| Quest | Stage | Event | Shift |
|-------|-------|-------|-------|
| `C00` (Companions intro) | 50 | Joined Companions | Per race |
| `CR00` (Companions main end) | 200 | Completed Companions | Per race |
| `CWMission005` | 200 | Joined Legion/Stormcloaks | Per race |
| `DB00` (Dark Brotherhood intro) | 10 | Joined Dark Brotherhood | Per race |
| `TG00` (Thieves Guild intro) | 30 | Joined Thieves Guild | Per race |
| `MG01` (College intro) | 10 | Joined College | Per race |
| `MQ306` (Main quest end) | 200 | Completed main quest | Per race |
| `DLC1VQ01` (Dawnguard — Harkon) | 10 | Became vampire lord | Per race |
| `C03` (Companions — Hircine) | 100 | Became werewolf | Per race |

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
[ ] Phase 2 — PDV_DeityBase + PDV_Deity_Kyne; PDV_FLST_AllDeities; ProcessDawn loop
[ ] Phase 3 — PDV_ActionRouter + first Story Manager kill node
[ ] Phase 4 — PDV_Origin, stance taxonomy, rivalry ledger, tier boon grants
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
Check that `RegisterFor[EventName]()` was called in `OnInit()`. If `OnInit()` only runs on first install (not on subsequent loads), move registration to `OnInit()` AND to an `OnPlayerLoadGame()` event fragment on the quest.

**DevotionLevel drifting unexpectedly:**  
Add trace output to `ProcessDawn()` and `WriteDirectShift()`. Run the debug spell before and after each test. The bucket system's daily cap of ±5 means extreme drift requires multiple days — if it's moving fast, a direct shift is firing repeatedly.

**Story Manager hook firing more than once:**  
Ensure the `PDV_SMF_[EventName]` flag is set to `true` on first fire and that the hook checks `if !PDV_SMF_[EventName]` before applying the shift.

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

**2026-05-10 — CK compiler toolchain:** Source `.psc` files live in `Scripts\Source\`. Compiled `.pex` output to `Scripts\`. CK compiler (Ctrl+F7) is the build path. `compile.ps1` / `skyrimse.ppj` are legacy, defer to CK.

**2026-05-10 — Console command source of truth:** `PDV_SkyrimConsoleReference.md` (UESP-sourced). Confirmed working: `GetGlobalValue <var>` (read), `set <var> to <value>` (write). `cgf` does not work on instance functions.
