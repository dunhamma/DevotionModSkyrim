---
name: pdv-papyrus-ck
description: >
  Papyrus, SKSE, CKPE, and MO2 workflow guardrails for the PlayerDevotion
  Skyrim SSE mod project. Use when writing/reviewing PDV .psc scripts,
  running the local compiler/verifier toolchain, compiling with
  PapyrusCompiler, planning CK property wiring, Story Manager event capture,
  or in-game console tests.
---

# PDV Papyrus / CK Workflow

Use this skill before editing or reviewing PDV Papyrus scripts, compile
commands, CKPE wiring steps, Story Manager setup, or Skyrim console tests.

## Ground Rules

- Read `AGENTS.md` first, then `references/PAPYRUS_KNOWLEDGE_INTAKE.md` when
  API usage or compiler imports matter.
- Do not invent Papyrus APIs. Verify signatures from shipped `.psc` sources,
  CK Wiki, SKSE sources, or plugin source.
- Distinguish vanilla Papyrus, SKSE, PapyrusUtil, SkyUI/MCM, and other plugin
  APIs.
- Compile-verified beats plausible. If a Papyrus assumption matters, compile it.
- Avoid CK stage fragments for PDV test harnesses unless revalidated in CKPE.

## Project Paths

- Docs: `C:\Users\Admin\Documents\Devotion Mod Project`
- Compiler tool: `C:\Users\Admin\Documents\Devotion Mod Project\tools\pdv_compile.mjs`
- Verifier tool: `C:\Users\Admin\Documents\Devotion Mod Project\tools\pdv_verify.mjs`
- Mod: `D:\Wabbajack\modlists\Anvil\mods\Devotion`
- Source: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`
- Output: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts`
- CKPE: `D:\Wabbajack\modlists\Anvil\Stock Game\ckpe_loader.exe`
- CK ini: `D:\Wabbajack\modlists\Anvil\Stock Game\CreationKit.ini`

## Compile Pattern

Prefer the local compiler wrapper from the docs workspace:

```powershell
node .\tools\pdv_compile.mjs
node .\tools\pdv_compile.mjs --script PDV_ActionRouter
node .\tools\pdv_compile.mjs --all
node .\tools\pdv_compile.mjs --list
```

Run the compiler after editing any PDV `.psc`. It compiles stale active scripts
by default, treats Papyrus warnings as failures, and runs the verifier after a
successful compile unless `--skip-verify` is supplied.

Run the verifier directly after CK/ESP/property/FormList/SEQ/MO2 profile work:

```powershell
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase3
```

Use `--strict-phase3` before declaring Phase 3 CK wiring complete.

Manual fallback, only if the wrapper cannot be used:

```powershell
& "D:\Wabbajack\modlists\Anvil\Stock Game\Papyrus Compiler\PapyrusCompiler.exe" `
"D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\SCRIPT_NAME.psc" `
"-f=D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg" `
"-i=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source;D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts;D:\Wabbajack\modlists\Anvil\mods\PapyrusUtil AE - Scripting Utility Functions\Scripts\Source;D:\Wabbajack\modlists\Anvil\mods\SKSE Script Sources - Compile Only\scripts\source" `
"-o=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts"
```

`PapyrusCompiler.exe` and `PapyrusAssembler.exe` are real command-line .NET
executables. Do not use Bethesda's shipped `ScriptCompile.bat`; it is a stale
development artifact with internal `C:\Projects\TESV\Build...` paths.

## PDV-Specific Patterns

- `PDV__ManagerQuest` owns canonical piety/tier helpers and mirror refresh.
- `AwardPiety(deity, amount)` writes `PDV.PietyToday` only.
- `ProcessDawn()` consolidates scratch piety, recomputes tier, and updates mirrors.
- `PDV_ActionRouter` fans validated actions to all deities; it owns no piety.
- Story Manager receiver quests are thin glue. For Kill Actor, use
  `PDV__SM_KillActor.OnStoryKillActor(...)` and call the router.
- Story Manager nodes added by PDV must use `Shares Event`.
- Prefer CK-wired properties and Auto-Fillable EditorIDs over magic FormIDs.

## Papyrus Gotchas Already Confirmed

- `continue` is not a Papyrus keyword.
- `Actor.GetName()` was not valid in the attempted context.
- Variables/properties cannot shadow known type names such as `ActorBase` or
  `Message`.
- Guard all casts before actor calls. `IsHostileToActor(None)` is crash-risk.
- `SetPQV` test commands take effect after closing the console and letting
  Papyrus run briefly.

## CK Wiring Checklist

- Confirm `.pex` exists before expecting CK to show a new script.
- Use `node .\tools\pdv_compile.mjs --script <ScriptName>` when a new script
  needs a first compile before CK can attach it.
- Assign script properties on the actual quest's Scripts tab.
- Use Auto-Fill where property names match EditorIDs.
- For FormLists in CKPE, drag records from the Object Window when Edit does
  not open an add-entry UI.
- Generate/update SEQ when adding a new Start Game Enabled quest.
- Run `node .\tools\pdv_verify.mjs` after CK wiring or SEQ generation.
