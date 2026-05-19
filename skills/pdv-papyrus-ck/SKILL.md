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
- Anvil/MO2 launcher: `D:\Wabbajack\modlists\Anvil\Anvil.exe`
- CKPE executable selected inside MO2: `D:\Wabbajack\modlists\Anvil\Stock Game\ckpe_loader.exe`
- CK ini: `D:\Wabbajack\modlists\Anvil\Stock Game\CreationKit.ini`

## Compile Pattern

Prefer the local compiler wrapper from the docs workspace:

```text
node .\tools\pdv_compile.mjs
node .\tools\pdv_compile.mjs --script PDV_ActionRouter
node .\tools\pdv_compile.mjs --all
node .\tools\pdv_compile.mjs --list
```

Run the compiler after editing any PDV `.psc`. It compiles stale active scripts
by default, treats Papyrus warnings as failures, and runs the verifier after a
successful compile unless `--skip-verify` is supplied.

Run the verifier directly after CK/ESP/property/FormList/SEQ/MO2 profile work:

```text
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase3
```

Use `--strict-phase3` before declaring Phase 3 CK wiring complete.

Manual fallback, only if the wrapper cannot be used: start
`PapyrusCompiler.exe` directly with an argv list. Do not route this through
PowerShell, `ScriptCompile.bat`, or the CK compile menu.

```text
executable:
D:\Wabbajack\modlists\Anvil\Stock Game\Papyrus Compiler\PapyrusCompiler.exe

argv:
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\SCRIPT_NAME.psc
-f=D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg
-i=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source;D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts;D:\Wabbajack\modlists\Anvil\mods\PapyrusUtil AE - Scripting Utility Functions\Scripts\Source;D:\Wabbajack\modlists\Anvil\mods\SKSE Script Sources - Compile Only\scripts\source
-o=D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts
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

- Papyrus string literal escapes are limited to `\\` and `\"`; do not use
  `\n`, `\r`, or `\t` in `.psc` strings.
- `{...}` docstrings only belong immediately after `ScriptName`, `Property`,
  `Function`, or `Event` declarations. Do not use them inside control flow or
  paste JSON-like literal `{` examples into them.
- `continue` is not a Papyrus keyword.
- `StringUtil.Replace` does not exist; avoid substitution or write a
  compile-tested helper.
- Papyrus has no ternary operator, string interpolation, string `+=`,
  `Math.max`, or `Math.min`.
- Arrays cannot be sized by variables and cap at 128 elements. Treat
  function-local arrays as suspect if compile output or runtime behavior looks
  stale.
- Split chained casts into named intermediate variables.
- `Actor.GetName()` was not valid in the attempted context.
- Variables/properties cannot shadow known type names such as `ActorBase` or
  `Message`; avoid short locals such as `key`, `form`, `actor`, and `cell`.
- Local variables cannot shadow script properties.
- Guard all casts before actor calls. `IsHostileToActor(None)` is crash-risk.
- CK condition names are not always Papyrus method names; for example,
  Papyrus `IsDead()` maps to CK condition `GetDead`.
- For hold/location work, do not assume `Cell.GetCurrentLocation()`, vanilla
  SSE `Location.IsContainedIn()`, or broad `Location.HasCommonParent()` are
  valid solutions. Prefer walking parent locations against CK-bound hold
  `Location` properties.
- `Utility.Wait()` inside paused UI/input paths resumes only when the game
  unpauses, which can release duplicate queued handlers in a burst.
- Topic Info fragments compile in a narrow CK-bound scope; use CK-bound
  properties rather than assuming direct access to manager script variables.
- `cqf` only calls named quest script functions and does not evaluate arbitrary
  Papyrus snippets. PDV's validated debug path remains the `SetPQV` poll
  harness unless a named dispatcher is intentionally added.
- `SetPQV` test commands take effect after closing the console and letting
  Papyrus run briefly.
- After script edits, retest impossible behavior from a new game or main-menu
  `coc qasmoke` path before redesigning logic; old saves can retain stale
  script state.
- Player-facing strings must be ASCII-only: use straight quotes, `...`, `--`,
  `-`, and `*`, not curly quotes, em/en dashes, ellipses, or bullets.
- Dialogue lines should stay under 80 characters where possible.
- Store returned OIDs from SkyUI MCM option builders (`AddSliderOption`,
  `AddMenuOption`, `AddToggleOption`, etc.) before relying on option events.
- If Custom Skills Framework is added later, the ESP filename in CSF JSON must
  exactly match the plugin filename.
- If `SKI_ConfigBase.pex` ever appears in `Devotion\Scripts`, delete it and
  fix the compile target list; PDV should not compile SkyUI sources.
- StorageUtil remains PDV's default backend. Do not mix StorageUtil, JFormDB,
  JDB/JArray, and live actor state for the same key; grep writers before
  adding readers.
- If JContainers is introduced, store FormIDs rather than Actor/Form objects
  in long-lived JArray/JDB collections, then resolve with `Game.GetForm()`.

## Runtime And Save Hygiene

- Prefer CK data, conditions, aliases, linked refs, quest stages, scenes,
  packages, perks, spells, magic-effect conditions, and default scripts before
  writing custom Papyrus.
- Prefer events over polling. Use `RegisterForSingleUpdate` /
  `RegisterForSingleUpdateGameTime` chains for repeated timers, and register
  the next update only after deciding work should continue.
- Every loop/timer needs an exit condition: quest stop, effect finish, alias
  clear, target death, object unload, dependency loss, timeout, or max
  iteration.
- Avoid long `Utility.Wait()` workflows. Store progress, exit, and resume from
  a timer/event instead.
- Keep handlers short. Split large work into bounded chunks or a manager-owned
  queue.
- Assume external calls can allow re-entry. Use states, busy flags, version
  tokens, or queues when multiple events can touch the same state.
- Do not keep references persistent accidentally. Avoid ObjectReference/Actor
  properties unless justified, prefer aliases/linked refs/event args, clear temp
  refs to `None`, and unregister events when finished.
- `Actor Property PlayerREF Auto` is acceptable for repeated player access; the
  player is already persistent.
- Use CK-filled properties for owned/static forms. Use `Game.GetFormFromFile`
  only for optional dependencies or prototypes, resolve once, guard for `None`,
  and never call it in hot loops.
- Treat `None`, stale property, bad cast, missing script, type mismatch, and
  unloaded-cell warnings as bugs, not normal control flow.
- Treat save files as Papyrus databases. Renaming/removing scripts, properties,
  variables, functions, or VMAD data is a migration problem. Do not rely on
  `OnInit()` rerunning for existing saved instances.
- For update-safe scripts, use an integer version and idempotent migration from
  load/timer paths; stop old timers and unregister old events during migration.
- Do not advise giant Papyrus INI budget/memory tweaks as a fix. Profile with
  Papyrus tools and fix the measured bottleneck.
- Before accepting a Papyrus script, ask whether it survives duplicate events,
  out-of-order events, save/load, and a queued event resuming after a wait.

## CK Wiring Checklist

- Launch CK by opening `D:\Wabbajack\modlists\Anvil\Anvil.exe`, selecting
  `Creation Kit` in MO2's executable dropdown, then pressing `Run`.
- Confirm `.pex` exists before expecting CK to show a new script.
- Use `node .\tools\pdv_compile.mjs --script <ScriptName>` when a new script
  needs a first compile before CK can attach it.
- Assign script properties on the actual quest's Scripts tab.
- Use Auto-Fill where property names match EditorIDs.
- For FormLists in CKPE, drag records from the Object Window when Edit does
  not open an add-entry UI.
- Generate/update SEQ when adding a new Start Game Enabled quest.
- Generate/update SEQ after adding or changing dialogue.
- Run `node .\tools\pdv_verify.mjs` after CK wiring or SEQ generation.
- For future dialogue-heavy work, use separate factions for "eligible" and
  "active/current" states, then gate every relevant topic explicitly.
- A single faction with rank values is acceptable for tier state when CK
  conditions need to read the value.
- Keep related dialogue `Link To` chains in the same branch where possible,
  and do not use Force-Activate for normal Hello topics.
