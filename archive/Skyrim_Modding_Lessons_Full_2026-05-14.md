# Skyrim Modding: Lessons Learned

Hard-won wisdom from building a complex Papyrus + SKSE + Prisma UI mod. Most of this applies to any non-trivial mod, but I've called out things especially relevant to a religion mod (dialogue-heavy, factions, NPCs, possibly worship mechanics or a custom skill).

This is the full version — there's a TL;DR section at the bottom if you want the highlights only.

---

## 1. Compile Workflow (Do Not Deviate)

The compile dance for a real Papyrus mod is fragile. Pick a routine and follow it every time:

1. Write or update scripts in `Source\Scripts\`.
2. Compile via a batch script that calls `PapyrusCompiler.exe` with the right import paths — **never** the CK's internal Compile button. The CK's compile button fails for any non-trivial project; the error message is unrelated to the actual problem.
3. **Delete `SKI_ConfigBase.pex` from your `Scripts\` output after every compile, without exception.** It's a side product that breaks SkyUI MCM integration if left in place. Bake this into your compile batch script as the last step.
4. Make CK changes (quest properties, dialogue topics, faction bindings).
5. Save the ESP.
6. **Regenerate the SEQ file in SSEEdit if any dialogue was added or changed.** Without an updated SEQ, your new dialogue won't fire until the player saves and reloads.
7. Test on a fresh save.

For a religion mod with priest dialogue, the SEQ-regeneration step bites constantly. Add an SSEEdit script or just remember it.

---

## 2. Papyrus Language Gotchas

These will eat hours if you don't know them upfront.

### Missing language features you'd expect to exist

- **No ternary operator.** No `condition ? a : b`. Use `If`/`Else`.
- **No `Math.max` or `Math.min`.** Write inline `If` comparisons or helper functions.
- **No string interpolation.** Concatenate with `+`. No `+=` for strings either — you have to write `s = s + "..."`.
- **No variable-size arrays.** `int[] arr = new int[count]` won't compile when `count` is a variable. Array sizes must be integer literals.
- **Max array size is 128.** Hard cap.
- **Local arrays inside functions are unreliable.** Declaring `int[] arr = new int[128]` inside a function body sometimes silently fails to compile — the old `.pex` continues running with no error, and your new code has no effect. Workaround: use script-level property arrays, double-pass counting (count first, iterate second), or JArrays anchored in JDB.

### String literal limitations

- The **only** valid escape sequences are `\\` and `\"`. `\n`, `\r`, `\t` cause cryptic compile errors like `"required (...)+ loop did not match anything"`.
- If you need a newline or tab at runtime, derive it via `StringUtil.GetNthChar(someString, index)` and concatenate.
- **`StringUtil` has no Replace function.** String substitution requires a manual `GetNthChar` scan-and-rebuild loop. Plan around this.

### Casts and chains

- **Chained casts are a compile error.** `(value as int as float)` fails. Split into two variables: `int tmp = value as int` then `float result = tmp as float`.
- `IsDead()` is Papyrus only — use `GetDead` in CK conditions.
- `GetOwningQuest()` cannot be cast to your custom quest script directly. Use a script property bound in CK instead.

### Docstring `{...}` syntax is restricted

- Only valid **immediately after** `ScriptName`, `Property`, `Function`, or `Event` declarations.
- Putting `{...}` inside an `If`/`Else`/`While` body fails with `"mismatched input expecting ENDIF"` and cascading unrelated-looking errors.
- Docstring bodies **cannot contain a literal `{` character.** Don't paste JSON examples into docstrings.
- For comments inside control flow, use `;` line comments.
- Property doc strings on faction properties can also fail when the content matches grammar tokens — omit when in doubt.

### Reserved words bite

Papyrus rejects common type names as local variable names. Confirmed reserved: `key` (collides with the `Key` script type). Error: `"cannot name a variable or property the same as a known type or script"`. When in doubt with a short common noun, prefix it: `effectKey`, `targetForm`, `subjectActor`.

### Local variables cannot shadow script properties

`Actor playerRef = ...` fails to compile when `PlayerRef` is already a script property. Use a different variable name or call the property directly.

### The VM pauses with the game

If your mod opens a UI that pauses the game (book, menu, anything that freezes time), the Papyrus VM is also paused. `Utility.Wait(N)` inside an input handler that fires *while paused* suspends until the game unpauses — not for N real-time seconds.

If you put `Utility.Wait` inside an `OnKeyDown` or similar handler that can fire during a paused UI, you'll get duplicate queued handlers that all wake in a burst when the player resumes. Symptom: 10 identical actions firing the instant they close the menu.

### TIF fragments compile in isolation

Topic Info Fragments extend `TopicInfo` and don't see your manager scripts directly. Bare references like `WorkerManager.DoThing()` fail with `"variable WorkerManager is undefined"`.

The CK auto-adds a property declaration for any quest script you reference in the fragment editor. Use the auto-added property to reach the manager:

```papyrus
; Fails:
WorkerManager.DoThing(akSpeaker)

; Works (CK auto-binds STMain):
STMain.WorkerManager.DoThing(akSpeaker)
```

Also: `akSpeaker` in the auto-generated fragment template is already cast to `Actor` — do not add a redundant `as Actor` cast.

TIF Fragments use `Fragment_0` for End events when only one event exists. `Fragment_1` is the End event only when both Begin and End exist on the same TIF.

---

## 3. The Papyrus Runtime Will Surprise You

These are the painful ones — bugs you cannot find from reading source.

### Runtime string case-fold (the worst one)

Skyrim's Papyrus runtime occasionally folds string literals to "canonical" forms in some internal pool when constructing strings via concatenation. The pool source is unclear, the fold is inconsistent across runs of the same code, and you cannot predict it from source.

Observed examples:

- `"venues"` → `"Venues"`
- `"name"` → `"Name"`
- `"hold"` → `"Hold"`
- `"true"` → `"TRUE"` (all caps)
- `"false"` → `"False"` (title case — inconsistent with TRUE)
- Some keys folded on one run, didn't on the next

**What does not work as a workaround:**

- Splitting literals across `+` (`"v" + "enues"`) — still folded.
- Constructing via `StringUtil.GetNthChar` — same.
- Switching `BSFixedString` to `std::string` on the SKSE plugin side helps for *cross-boundary* strings but not Papyrus-internal construction.

**What works:** normalize on the consuming side. If you're emitting JSON from Papyrus into a JS UI, write a JS-side normalizer that lowercases keys against a canonical table and coerces stringified bools (`"true"`/`"TRUE"`/`"True"`) back to real bools. Have your Papyrus JSON emitter wrap bools in quotes (`"true"`/`"false"` rather than bare `true`/`false`) so the JS regex has something to match.

For a religion mod, if you're saving prayer data, scripture content, or any structured payload as JSON for any reason — assume keys will get case-mangled in transit. Pick one canonical case and normalize.

### `BSFixedString` is a case-insensitive interned pool

Skyrim's `RE::BSFixedString` is a global case-insensitive interned string type. Strings created from C-strings with content matching an existing pool entry get folded to the pool's canonical case. This is mostly invisible but bites SKSE plugin development.

SKSE plugin natives that pass strings between C++ and Papyrus should use `std::string` (not `BSFixedString`) when content needs case preservation. `SKSE::ModCallbackEvent::strArg` is `BSFixedString` and unfortunately not bypassable — JS→Papyrus action verbs go through this and get folded. Papyrus's `==` on strings is case-insensitive so dispatcher checks still match; the fold just shows up in trace logs.

### ASCII-only for anything the player sees

Skyrim's text pipeline mangles UTF-8 multibyte characters into Mojibake. Applies to:

- Menu entries (UIExtensions, MessageBox options)
- `Debug.Notification` text
- MCM labels and tooltips
- Dialogue text (responses, prompts)
- Book / scroll / journal content
- In-game widget content

Forbidden: `…`  `—`  `–`  `’`  `‘`  `”`  `“`  `•`

Use instead: `...`  `--`  `-`  `'`  `'`  `"`  `"`  `*`

**Comments in `.psc` files and `Debug.Trace` output to the log are fine** (the log is UTF-8 capable). Player-facing strings only. But non-ASCII characters *anywhere* in a `.psc` file (including in comments) have occasionally caused compile errors — so when in doubt, ASCII-only across the board.

For a religion mod with prayers, scripture, NPC dialogue — this is a lot of text to audit. Bake the rule in from day one.

### `WIDeadBodyCleanupScript` log spam is not your bug

If you see scary-looking errors about `WIDeadBodyCleanupScript` in your Papyrus log, those are vanilla Skyrim noise. Not yours. Ignore.

---

## 4. CK Navigation and Dialogue

### Dialogue lives inside Quests

You will not find dialogue topics by filtering the Object Window top level. Topic infos are nested inside Quest forms. Path:

```
Object Window > Quest > [YourQuestName] > double-click >
  Player Dialogue tab > Branches (left) > Topics (middle) > Infos (right)
```

For a religion mod, most of your dialogue (priest conversations, worship prompts, conversion topics) will probably live inside one or two control quests. Get comfortable with this view.

### CK conditions use different function names than Papyrus

The CK condition picker shows engine function names, not Papyrus ones. Common surprises:

- Papyrus `IsDead()` → CK condition `GetDead`
- Papyrus `HasKeyword(kw)` → CK condition `HasKeyword`
- Papyrus `GetFactionRank(f)` → CK condition `GetFactionRank`

Always check both sides — the condition editor in CK won't autocomplete a Papyrus function name you remember from script.

### `Link To` within a branch is reliable

Cross-branch `Link To` can fail if the target branch's conditions don't pass independently. Keep related topics in the same branch when you want reliable chaining.

### Hello topics auto-fire by proximity

Topics on a `Hello` branch auto-fire when an NPC with a valid Hello Info gets within roughly 150 units of the player. **Do not** use `Force-Activate` to trigger them — that causes dialogue to open from across the room. Reserve `Force-Activate` for specific cases where immediate dialogue is needed regardless of distance.

### `GetCurrentLocation()` and modded interiors

`Cell` has no `GetCurrentLocation()` method — pass `Location` directly from `OnLocationChange` as `akNewLoc`.

`Location.IsContainedIn()` is **not** in SSE vanilla Papyrus stubs even though PO3 is loaded. Do not use.

`Location.HasCommonParent()` returns `True` for any two locations sharing any ancestor — *including the root Skyrim location.* It will never tell you what you want. Never use for hold detection.

Always check the PO3 source directory before using `Location` or `Form` methods not in vanilla stubs.

### Hold detection from cell is hard

Skyrim has nine hold Location forms. You might assume `GetCurrentLocation()` will give you the hold reliably. It won't for modded interiors — `PlayerInTownXxxFaction` checks don't fire there, and Location parents can be misconfigured in mods.

Pattern that works: walk `Cell.GetLocation()` → `Location.GetParent()` upward, comparing against your nine bound hold Location properties. Stops when one matches or parent goes to None.

If your religion mod needs hold awareness (region-based blessings, hold-shrine effects), implement this fallback and surface manual override in your UI when detection fails.

---

## 5. Dialogue & Factions

This is where a religion mod will spend most of its complexity budget.

### One faction is rarely enough

Whenever you have a state that gates dialogue, you almost always need **at least two factions**: one for "currently eligible to be offered X" and one for "currently has X."

For a religion mod, this might be:

- `ReligionXFollowerFaction` — current followers (gates blessing dialogue, priest greetings)
- `ReligionXEligibleFaction` — NPCs the player can convert (gates the conversion topic itself)

If you only have one faction and use it for both gates, you'll find that once you remove the NPC (excommunication, deconversion), you can never re-convert them — because the "offer conversion" topic also keyed off that faction.

Pattern: when removing an NPC from a role, **audit every eligibility gate that mentions that role**, not just the obvious one.

### Use faction RANK to encode tier state

When you need a state that the CK can read for conditions but the value lives in JFormDB/StorageUtil (which CK can't read), **use a single faction with rank values** to encode the state.

- One faction is simpler to manage in CK property bindings and the ESP form list.
- `SetFactionRank(faction, N)` is idempotent and clean.
- CK condition `GetFactionRank Faction == N` supports equality on rank values.
- Multiple sub-factions for different tiers proliferates form records and complicates cleanup.

Note: `AddToFaction` adds at rank 0 by default. To set a non-zero rank, follow with `SetFactionRank`. The CK doesn't require ranks to be defined in the faction's Ranks list for `SetFactionRank`/`GetFactionRank` to work — they're just integer values.

For a religion mod, a single `ReligionXFollowerFaction` with rank 0/1/2/3 for novice/initiate/devoted/anointed is much cleaner than four parallel factions.

### Gate every relevant topic on the right factions

If your mod has retired/dead/excommunicated/deconverted states, every topic that shouldn't show for those NPCs needs an explicit condition. The default is "show" — you have to opt out. Specifically:

- Greeting topics
- Recruitment/conversion topics
- Service/management topics and all sub-actions
- Confirmation topics for pending states

Condition pattern: `GetFactionRank ReligionExcommunicatedFaction < 0` on Subject (meaning "subject is *not* in the excommunicated faction"). Add this to every new topic from the start — retrofitting is painful.

### Same fragment body, different conditions

Multi-info topics where each "tier" has different requirements (novice/initiate/devotee greetings, etc.) — write one fragment body, differentiate tiers via conditions on each Info, not by branching inside the fragment.

### Dialogue lines must be under 80 characters

This is a hard engine limit. Also: avoid contractions in NPC dialogue — they don't match the game's voice style and read as out of place. Use full forms ("I am" instead of "I'm").

---

## 6. Storage Backends (Pick One Per Key)

Skyrim modding has at least four different "places to put data," and they don't interoperate. Picking wrong is one of the most common silent bug sources.

### The four backends

| Backend | When to use | Persistence |
|---|---|---|
| `StorageUtil` (PapyrusUtil) | Simple typed values attached to a form or globally | Saves via PapyrusUtil |
| `JFormDB` (JContainers) | Hierarchical values attached to a form (`.path.to.key`) | Saves via JContainers |
| `JMap`/`JArray` rooted in `JDB` | Structured maps/lists with their own identity | Saves via JContainers |
| Live actor properties (`GetActorValue`, `GetItemCount`) | Values that are properties of the runtime actor state | Engine-managed |

**Critical rule:** these backends do not interoperate. Same key name, different store, they cannot read each other's writes.

### Common bug pattern

Snapshot reads zeros because the writer used StorageUtil but the read uses JFormDB. Or vice versa. Symptom is silent: field arrives empty, UI looks broken, no error in the log.

**Rule:** before adding a new read of any key, grep the codebase for every writer of that key. If writers don't exist, the field is a stub — annotate it. If writers exist on a different backend, match the writer's backend.

### Choosing the right backend

- **StorageUtil first.** Simpler, fewer GC pitfalls, less ceremony. Good default for per-actor flags, counters, timestamps.
- **JFormDB for hierarchical attached data.** When you want `actor.ST.worker.xp` style nested keys on a specific form.
- **JMap/JArray in JDB for structured collections.** Workers roster, client list, event queue. Anything you'd model as a typed collection.
- **Live actor properties** for things the engine already knows (gender, race, current health). Don't shadow these with mod-tracked copies.

### JDB rules (read before every JDB write)

- **JDB.setObj uses a plain key.** `JDB.setObj("MyKey", handle)` is correct.
- **JDB.solveObj uses a dot-prefixed path.** `JDB.solveObj(".MyKey")` is correct.
- **They match only when the key has no dots.** Asymmetric naming convention — easy to get wrong.
- **Never use nested JDB dot paths via `setObj`** (e.g., `JDB.setObj(".MyMod.ledger.totalGold", h)`). The dot prefix on setObj causes immediate GC of the intermediate JArray/JMap. Use flat keys: `JDB.setObj("MyMod_LedgerTotalGold", h)`.
- **JFormDB nested paths ARE safe** — different backend with different semantics.

### JArray Form/Actor reference GC

Form and Actor references stored as values inside a JArray are subject to JContainers garbage collection even when the JArray container is anchored at JDB root. The JDB anchor retains the container but does not protect the form references stored inside.

Symptom: `JArray.getForm` returns `None` for entries that were successfully written, typically after a UIListMenu open/close cycle (several seconds during which GC runs).

**Rule:** never store Actor or Form objects directly in a JArray that must survive across a menu cycle or any wait period. Always store integer FormIDs instead:

```papyrus
; Write
JArray.addInt(handle, akActor.GetFormID())

; Read
int formID = JArray.getInt(handle, index, 0)
Actor a = Game.GetForm(formID) as Actor
```

Integer values are plain data — JContainers has nothing to GC. `Game.GetForm` resolves a valid FormID to the live Actor reference as long as the plugin is loaded.

### Per-form initialization flags

Use `StorageUtil.GetIntValue(akForm, "myMod.client.initialised", 0)` rather than `JFormDB.hasPath`. `hasPath` returns `False` after GC even when data was successfully written. StorageUtil values are GC-stable.

### JContainers `writeToString` is unreliable

JContainers' tree serializer (`writeToString`/`toString` natives) returns null or malformed output depending on which fork of the DLL the user installed. Use hand-built JSON via string concatenation when you need serialization.

---

## 7. Defensive Cleanup Patterns

Lifecycle teardown is harder than it looks.

### The "gate too narrow" bug

Common pattern: `ReleaseFollower(actor)` or `Excommunicate(actor)` calls some comprehensive `UnassignFromAllRoles(actor)` function — but only when the actor is currently in some specific state (e.g., `If onDuty == 1`).

The bug: that actor might be in other roles that need cleaning up regardless of the gating flag. Worker is a paramour at one venue while resting in another — paramour designation persists after release because the cleanup gate was scoped to "on duty."

**Pattern fix:** capture relevant state BEFORE the gated cleanup, then run a defensive idempotent cleanup AFTER, regardless of the gate.

```papyrus
; Snapshot state before cleanup
String roleKey = JFormDB.solveStr(akActor, ".roles.activeRole")
bool wasParamour = IsParamour(akActor)

; Gated cleanup (may not run)
If (StorageUtil.GetIntValue(akActor, "onDuty", 0) == 1)
    UnassignFromVenue(akActor)
EndIf

; Defensive cleanup (always runs, idempotent)
ClearParamourDesignation(akActor)
If wasParamour && roleKey != ""
    AutoPromoteReplacement(roleKey)
EndIf
```

### General principle

Lifecycle teardown functions (Release, Finalize, Excommunicate, etc.) that delegate cleanup to a domain-management function should not gate the delegation on flags independent of the cleanup's scope. If the domain function clears role X as part of its work, that clear must run regardless of unrelated state flags.

For a religion mod: deconverting a follower should clean up *every* religion-related faction membership, ability, blessing buff, and scheduled event — not just the ones tied to "currently a priest" or "currently in good standing."

### When deleting code, grep for everything

Before removing a Papyrus function, property, or even a block, **recursively grep for every symbol it defines or references**. This includes:

- The function/property name itself
- Every local variable declared inside the block (especially `bool handledX` style flags)
- Every constant or magic string the block depends on

Local variables in particular can be referenced from sibling paths — shared OR-chain conditions, post-block cleanup, multi-handler dispatchers — that a function-name grep won't catch. A block declared `bool handledWDFGrowth`; the variable was referenced 70 lines later in an unrelated multi-handler OR guard; removing the block produced cascading "undefined variable" errors in dependent scripts.

Use `findstr /S /I "symbolName" *.psc` on Windows or `grep -r` on Linux/Mac. Run it across the **entire** Source/Scripts folder, not just files you happen to have open.

### Always request the latest source files before editing

If you're working across sessions, machines, or with collaborators, always confirm you have the latest version of every file before making changes. A "forward-looking" upload list (files you *think* are relevant) is almost never complete. CK-side changes may have generated new TIFs the previous session didn't see. When in doubt, grep the full project for callers.

### Always check mod-API sources before using new functions

Before using any function from JContainers, PO3 Papyrus Extender, UIExtensions, StorageUtil, PapyrusUtil, SexLab, etc. that is **not** already present in your codebase, open the relevant `.psc` source file and verify the exact function signature. Guessing at API signatures has produced compile errors and, worse, incorrect implementations that compile but behave wrong at runtime.

---

## 8. Testing & Debugging

### `cqf` only calls named functions

The Skyrim console `cqf` (CallQuestFunction) does **not** evaluate arbitrary Papyrus. This will not work:

```
cqf "MyQuest" "Debug.Trace(\"hello\")"
```

It only invokes named functions that exist on the quest-attached script.

Plan a debug dispatcher early: have a function on your main control quest that takes a string action name and a few args, and dispatches to internal handlers. You can wire it to console commands, MCM buttons, and in-mod UI buttons uniformly.

### Papyrus log location

```
Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log
```

Enable Papyrus logging in `Skyrim.ini`:

```ini
[Papyrus]
bEnableLogging=1
bEnableTrace=1
bLoadDebugInformation=1
```

Tail this file while testing. Most of your debugging will live here.

For Custom Skills Framework, there's a separate log:

```
Documents/My Games/Skyrim Special Edition/SKSE/CustomSkills.log
```

### Always test from a new save

Skyrim caches script state in saves. If you modify a script and load an old save, you may be running the old version against the new code, or vice versa. Symptoms are mysterious and intermittent.

Standard test workflow: `coc` to a relevant cell from a new-game start. Use `player.additem` and `player.setav` to bootstrap. Have a "test setup" dispatcher function on your control quest.

**Default assumption: testing is on a fresh save.** Never suggest "stale state from a previous session" as the cause of a bug without confirming the save is new.

### Debug trace protocol

When a bug persists across more than one test cycle without a clear log signal, add `Debug.Trace` calls immediately rather than speculating. Speculation wastes sessions; traces waste one compile.

Rules:

- Tag every debug trace with `; DEBUG - remove before release` on the line above.
- Keep a running list of all active debug traces somewhere — a section in your design doc, an issue, a markdown file. Update it every session.
- Add traces at precise decision points: function entry (what did we receive?), branch taken (which path?), key variable values before any conditional.
- Don't remove debug traces mid-session. Let them accumulate; strip them all at once when the issue is confirmed resolved.
- After stripping, verify the log no longer contains DBG lines before closing the session.

Trace naming convention: `[MYMOD] DBG FunctionName: key=value`. Always prefix with `DBG` so you can grep separately from production traces.

### Code is the source of truth, design docs aren't

You will write a design doc. The doc will drift from the code within weeks. **Always check the code for current behavior** before relying on the doc. Mark known-stale sections in the doc as you find them, and treat the doc as a guide to *intent*, not a spec.

---

## 9. UI & Strings

### MCM sliders need their OID stored

`AddSliderOption()` returns an OID (option ID) that must be stored in a script variable. Without it the slider renders but is non-functional — `OnOptionSliderOpen` and `OnOptionSliderAccept` cannot identify which slider fired.

```papyrus
; Wrong:
AddSliderOption("Cooldown days", _cooldownDays, "{0}")

; Right:
int _oidCooldownDays
_oidCooldownDays = AddSliderOption("Cooldown days", _cooldownDays, "{0}")
```

Same applies to `AddMenuOption`, `AddToggleOption`, and other MCM option builders — store the OID, use it for identification in event handlers.

### Keep MCM minimal

A common temptation: every tunable value gets an MCM slider. Resist this. MCM is bulky, expensive to author, and clutters the player's settings.

Good MCM scope:

- Enable/disable mod
- Hotkey rebinds
- One or two truly user-facing toggles (verbosity, difficulty preset)
- Spawn-a-quest-item button if relevant

Bad MCM scope:

- Multipliers and thresholds
- Cooldown tuning
- Per-feature toggles for things players will toggle once

For internal tunables, put them in a debug page inside your own mod UI (book, holotape, custom menu). Easier to author, easier to extend, doesn't pollute the player's settings list.

### Server-truthful gating

JS/UI optimistic updates (UI changes immediately, Papyrus runs in background) can mask silent failures when an action's preconditions aren't met server-side. Pattern: emit a server-computed `canX` bool or precondition data so the UI can pre-flight gate the action.

For a religion mod: `canPerformRitual: bool`, `hasOffering: bool`, `shrineUnlocked: bool` exposed as data the UI consumes, rather than the UI guessing or showing a button that silently fails. When the precondition fails, disable the button with a tooltip explanation rather than letting the player click and see nothing happen.

---

## 10. Skill Systems

### Use CSF for a real skill

If your religion mod wants a "Worship" or "Piety" skill that levels up, integrates with the vanilla skill UI, and grants perks — use **Custom Skills Framework** (Meh321). It's the standard.

Caveats:

- CSF's API doesn't expose XP-within-current-level cleanly. You can ask "what level am I?" but the granular progress bar value is awkward to read out. Plan UI around level transitions, not progress percentages.
- **CSF ESP filename must be exact.** The ESP name in `YourMod.json` (in `SKSE\Plugins\CustomSkills\`) must match your ESP file name *exactly*. `"MyMod.esp"` vs `"My Mod - Awesome Edition.esp"` is a SILENT failure in every `LookupForm` call. Symptoms: `GetSkillLevel` returns 0, perks invisible, XP does nothing, **no error in any log**. Triple-check this.

A nicer skill menu shell on top of CSF is **Meta Skill Menu** by Mardoxx (Nexus 62423). Good UX if you want a discoverable home for your skill tree without writing custom UI.

### Perk grant/revoke patterns

If your perk system has both "granted by leveling" and "granted by debug/admin command" paths, be careful — your level-up handler may revoke debug-granted perks on the next level-up if it iterates all perks and re-evaluates them.

Pattern: set a `debug.allPerksGranted` flag when granting via debug, check it in the level-up handler, and skip the revoke iteration when set. Clear the flag in your matching `RevokeAllPerks` debug action.

---

## 11. Architecture & Scope

### Pick dependencies deliberately

Every required dependency reduces your potential audience. Cost-benefit:

| Dependency | Use when | Cost |
|---|---|---|
| SKSE | Almost always (Papyrus alone is too limited) | Standard, expected |
| Address Library | If you use SKSE | Tiny, ubiquitous |
| PapyrusUtil | Need StorageUtil, math, arrays | Tiny, ubiquitous |
| JContainers | Need maps/trees, JSON | Bigger but well-supported |
| PO3 Papyrus Extender | Need OnDeath events, extended form/actor methods | Common dep |
| UIExtensions | Custom menus from Papyrus | Adds a menu dep |
| CSF | Custom skill with vanilla-style UI | Niche but standard |
| Custom SKSE plugin (C++) | Truly need engine-level access | Big — you maintain it |

Don't write a C++ SKSE plugin unless you've genuinely exhausted Papyrus options. The maintenance burden compounds — every Skyrim update potentially breaks Address Library offsets and forces a rebuild.

### Start with the data model, not the UI

Before writing dialogue, before building shrines, decide:

- What's a "follower" of a deity? (faction? StorageUtil flag? per-actor object?)
- Where does prayer count live? Per-actor? Per-deity-globally? Both?
- How does the player query "how am I doing with God X?"
- What's the unit of progression? Daily prayers? Quest completions? Total offerings?

Get this right and the dialogue/UI/perks layer on cleanly. Get it wrong and you'll refactor everything twice.

### Idempotent daily ticks

Mods often want "daily bonus" effects — once per in-game day, apply X. Standard pattern:

1. Stamp a JDB key with the current game day when you apply.
2. Before applying, check the stamp — if it matches today, skip.

This protects against duplicate-fire from multiple update sources (`OnUpdate`, `OnUpdateGameTime`, sleep wake-up, etc.).

### Use FormIDs as identity, not actor references

When you need to track "which workers/followers/clients exist" across cells, menu cycles, save/load — store decimal FormIDs as plain ints, not Actor references. Resolve via `Game.GetForm(formID) as Actor` when you need the live reference.

This works correctly with ESL-flagged plugins (FE-prefixed FormIDs) and survives every kind of GC and serialization.

### Concurrency and race conditions

Multiple Papyrus stacks can run concurrently. Common race pattern: two cell-entry events both pick the same worker for a scene because the "is this worker busy?" check happens before either has marked them busy.

Pattern fix: **pre-mark busy synchronously**, in the same stack as the selection, before any async call. If both stacks then proceed past the busy mark, the second one's call will harmlessly find the worker already busy and back off cleanly.

For a religion mod: if you have rituals or appointments that involve multiple NPCs, you'll hit this. Plan for atomic selection-and-claim, not select-then-claim-later.

### Game time vs delta time

Don't confuse `Utility.GetCurrentGameTime()` (in-game days, persists with save) with real-world delta time. Fast-traveling forward 8 hours advances game time but not real time; sleeping advances both. For "real-time" mechanics (cooldowns measured in player engagement), use scene-count or interaction-count rather than game-time delta. For "world-time" mechanics (daily reset, weekly events), use game-time delta. Picking wrong creates exploits — players can fast-forward through cooldowns.

---

## 12. General Wisdom

- **Notifications are precious.** `Debug.Notification` is the only "passive" feedback channel that doesn't require the player to open anything. Don't burn it on routine state changes; reserve it for things the player needs to know but isn't actively looking for. For a religion mod: deity favor crossing tiers, ritual success, divine intervention — yes. Daily prayer accumulator going from 4 to 5 — no.
- **Players will not read.** If your mod has a tutorial book or readme, assume nobody reads it. Design around discoverability — every important action should have an obvious entry point in-game.
- **Test on a clean profile.** Periodically install your mod on a fresh MO2 profile with only declared deps. It will expose hidden dependencies you didn't realize you'd absorbed from your dev profile.
- **Faction rank is your friend.** You can store small integer state in faction rank without inventing new storage. Useful for "tier of follower," "deity affinity 0-5," or "current standing."
- **Save-bake. Plan for it.** Players will use your mod in saves spanning months. Anything you remove from the script architecture lives on in old saves as orphan references. Design new features as additive when you can; design removals carefully when you must.
- **Bed ownership.** Player-owned beds (Breezehome, custom homes) cannot be slept in by NPCs. NPC sleep packages fail gracefully to sandbox in these cells. If your priest NPC is supposed to sleep at the player's home shrine, this will surprise you.
- **Cell-load AI grid initialization takes time.** First worker spawned into a new venue cell may stand idle briefly. On re-entry they sandbox immediately. This is Skyrim AI grid initialization — not fixable from Papyrus. Don't try.
- **Trace your assumptions, not your conclusions.** When something goes wrong, log the input values to every decision point, not just the final state. Half of debugging is discovering you assumed something that wasn't true.

---

## TL;DR for a religion mod

If your friend is doing a religion mod specifically, the top ten things to internalize:

1. **Two factions per role, minimum** — one for "eligible," one for "active." Or use rank values on a single faction. Audit every dialogue gate when state changes.
2. **ASCII only** for prayers, scripture, dialogue, notifications. No fancy quotes or em-dashes.
3. **Pick one storage backend per key and stick to it.** Grep for writers before adding a reader. StorageUtil is the default; JFormDB for hierarchical attached data; JArray-in-JDB for collections. Never mix.
4. **Build a debug dispatcher on your control quest from day one** — `cqf` can only call named functions. You'll use the dispatcher for console testing, MCM buttons, and in-mod UI uniformly.
5. **Code over docs** — keep a design doc for intent, but always grep the code for current behavior before making changes.
6. **Use CSF for a real skill** — and triple-check the ESP filename in the CSF config JSON. Silent failure mode is brutal.
7. **Test from a new game every time you touch a script.** Old saves cache old script state in ways that will mislead you.
8. **Compile workflow**: bat file, delete `SKI_ConfigBase.pex`, save ESP, regenerate SEQ if dialogue changed, fresh save to test. Every time.
9. **Defensive cleanup**: when removing a follower from any role, clean up *every* role-related state — factions, abilities, scheduled events, designations. Don't gate cleanup on the role-state flag itself.
10. **Add `Debug.Trace` before speculating.** Tag with `; DEBUG - remove before release`. Strip them all at once when the bug is resolved.

Good luck to them. The first mod is the hardest; the second one is half the work.
