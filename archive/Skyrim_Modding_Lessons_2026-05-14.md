# Skyrim Modding: Lessons Learned

Hard-won wisdom from building a complex Papyrus + SKSE + Prisma UI mod. Most of this applies to any non-trivial mod, but I've called out things especially relevant to a religion mod (dialogue-heavy, factions, NPCs, possibly worship mechanics or a custom skill).

---

## 1. Papyrus Scripting Gotchas

These will eat hours if you don't know them upfront.

### String literals are extremely limited

The **only** valid escape sequences in Papyrus string literals are `\\` and `\"`. That's it.

- `\n`, `\r`, `\t` will *not* compile. You'll get cryptic errors like `"required (...)+ loop did not match anything"`.
- If you need a newline or tab at runtime, derive it via `StringUtil.GetNthChar(someString, index)` and concatenate.

### StringUtil has no Replace

There is no built-in `Replace` function. If you need string substitution, you have to write a manual `GetNthChar` scan-and-rebuild loop. Plan around this — try to avoid substitution in hot paths.

### Docstring `{...}` syntax is restricted

The `{description}` syntax only works **immediately after** `ScriptName`, `Property`, `Function`, or `Event` declarations. You cannot put a `{...}` block inside an `If`/`Else`/`While` body — the parser reads `{` as the start of an expression and you get `"mismatched input expecting ENDIF"` with a cascade of unrelated-looking errors.

Also: docstring bodies **cannot contain a literal `{` character**. If you paste a JSON snippet into a docstring, the lexer chokes and you get cascading `"Unknown user flag"` / `"missing EOF"` errors that mysteriously also break every script that depends on this one. Write examples as prose.

For comments inside control flow, use `;` line comments.

### Reserved words bite

Papyrus reserves common type names and rejects them as local variable names. Confirmed reserved: `key` (collides with the `Key` script type). When in doubt with a short common-noun name (`key`, `form`, `actor`, `cell`), prefix it: `effectKey`, `targetForm`, `subjectActor`. The error message is `"cannot name a variable or property the same as a known type or script"` plus a cascade of `"X is not a variable"` errors.

### The VM pauses with the game

If your mod opens a UI that pauses the game (e.g., a menu, a book, anything that freezes time), the Papyrus VM is also paused. This means `Utility.Wait(N)` inside an input handler that fires *while paused* will suspend until the game unpauses, then return — not after N real-time seconds.

Practical consequence: if you put `Utility.Wait` inside an `OnKeyDown` or similar handler that can fire during a paused UI, you'll get duplicate queued handlers that all wake in a burst when the player resumes. Symptom: 10 identical actions firing the moment they close the menu. Diagnose by adding `Debug.Trace` before and after every `Wait`.

### TIF fragments compile in isolation

Topic Info fragments in the CK compile against a tiny scope — they can't see your manager scripts directly. The CK auto-adds a property for any quest script you reference. So:

```papyrus
; In a TIF fragment, this FAILS:
WorkerManager.DoThing()
; "variable WorkerManager is undefined"

; This WORKS (CK auto-binds STMain):
STMain.WorkerManager.DoThing()
```

Also: `akSpeaker` in the template is already typed as `Actor` — no redundant cast needed.

---

## 2. Creation Kit Navigation

The CK's Object Window is misleading about where things live.

### Dialogue lives inside Quests, not at top level

You will not find dialogue topics by filtering the Object Window. Topic infos are nested inside the Quest form. Path:

```
Object Window > Quest > [YourQuestName] > double-click >
  Player Dialogue tab > Branches (left) > Topics (middle) > Infos (right)
```

For a religion mod, most of your dialogue (priest conversations, worship prompts, conversion topics) will probably live inside one or two control quests. Get comfortable with this view.

### Hold detection from cell is hard

Skyrim has nine hold Location forms (WhiterunHoldLocation, etc.), and you might assume `GetCurrentLocation()` will give you the hold reliably. It won't for modded interiors — `PlayerInTownXxxFaction` checks don't fire there, and Location parents can be misconfigured in mods.

If your religion mod needs to know which hold the player or an NPC is in (for region-based blessings, hold-shrine effects, etc.), build a fallback: read from a cell-detection script, allow manual override in your UI, and warn the user when detection fails rather than guessing.

---

## 3. Dialogue & Factions

This is where a religion mod will spend most of its complexity budget.

### One faction is rarely enough

Whenever you have a state that gates dialogue, you almost always need **at least two factions**: one for "currently eligible to be offered X" and one for "currently has X."

For a religion mod, this might be:

- `ReligionXFollowerFaction` (current followers — gates blessing dialogue, priest greetings)
- `ReligionXEligibleFaction` (NPCs the player can convert — gates the conversion topic itself)

If you only have one faction and use it for both gates, you'll find that once you remove the NPC from the faction (excommunication, deconversion), you can never re-convert them — because the "offer conversion" topic also keyed off that faction.

Pattern: when removing an NPC from a role, **audit every eligibility gate that mentions that role**, not just the obvious one.

### Gate every relevant topic on the right factions

If your mod has retired/dead/excommunicated states, every topic that shouldn't show for those NPCs needs an explicit condition. The default is "show" — you have to opt out. Specifically:

- Greeting topics
- Recruitment/conversion topics
- Service/management topics and all sub-actions
- Confirmation topics for pending states

Condition pattern: `GetFactionRank ReligionExcommunicatedFaction < 0` on Subject (meaning "subject is *not* in the excommunicated faction"). Add this to every new topic from the start — retrofitting is painful.

### Same fragment body, different conditions

Multi-info topics where each "tier" has different requirements (e.g., novice/initiate/devotee greetings) — write one fragment body, then differentiate the tiers via conditions on each Info, not by branching inside the fragment.

---

## 4. Testing & Debugging

### `cqf` only calls named functions

The Skyrim console `cqf` (CallQuestFunction) does **not** evaluate arbitrary Papyrus. This will not work:

```
cqf "MyQuest" "Debug.Trace(\"hello\")"
```

It only invokes named functions that exist on the quest-attached script. So your debug workflow has to be:

1. Write a `DebugDoX()` function on your control quest script.
2. Call `cqf "MyQuest" "DebugDoX"` from the console.

This means: **plan a debug dispatcher early.** Have a function on your main quest that takes a string action name and a few args, and dispatches to internal handlers. Then you can wire console commands, MCM buttons, or in-mod UI buttons to the same dispatcher.

### Papyrus log location

```
Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log
```

Enable Papyrus logging in `Skyrim.ini` (`bEnableLogging=1`, `bEnableTrace=1`, `bLoadDebugInformation=1`). Tail this file while testing — most of your debugging will live here.

### Always test from a new game when changing scripts

Skyrim aggressively caches script state in saves. If you modify a script and load an old save, you may be running the old version against the new code, or vice-versa. Symptoms are mysterious and intermittent.

Standard test workflow: `coc` to a relevant cell from a new-game start. Use `player.additem` and `player.setav` to bootstrap test state. Have a "test setup" dispatcher function on your control quest.

### Code is the source of truth, design docs aren't

You will write a design doc. The doc will drift from the code within weeks. **Always check the code for current behavior** before relying on the doc. Mark known-stale sections in the doc as you find them, and treat the doc as a guide to *intent*, not a spec.

---

## 5. UI & Strings

### ASCII-only for anything the player sees

Skyrim's text pipeline mangles UTF-8 multi-byte characters into Mojibake. This applies to:

- Menu entries (UIExtensions, MessageBox options)
- `Debug.Notification` text
- MCM labels and tooltips
- Dialogue text (responses, prompts)
- Book / scroll / journal content

Forbidden: `…`  `—`  `–`  `’`  `‘`  `”`  `“`  `•`

Use instead: `...`  `--`  `-`  `'`  `'`  `"`  `"`  `*`

Comments in your `.psc` files and Debug.Trace output to the log are fine (the log is UTF-8 capable). Player-facing strings only.

For a religion mod with prayers, scripture, NPC dialogue, etc., this is a lot of text to audit. Bake the rule in from day one — it's much easier than scrubbing later.

### Keep MCM minimal

A common temptation: every tunable value gets an MCM slider. Resist this. MCM is bulky, expensive to author, and clutters the player's settings screen.

Good MCM scope:
- Enable/disable mod
- Hotkey rebinds
- One or two truly user-facing toggles (verbosity, difficulty preset)
- Spawn-a-quest-item button if relevant

Bad MCM scope:
- Multipliers and thresholds
- Cooldown tuning
- Per-feature toggles for things players will toggle once

For internal tunables, put them in a debug page inside your own mod UI (book, holotape, whatever your equivalent is). Easier to author, easier to extend, doesn't pollute the player's settings list.

---

## 6. Project Hygiene

### Grep before you delete

Before removing a Papyrus function, property, or even a code block, **recursively grep for every symbol it defines or references**. This includes:

- The function/property name itself
- Every local variable declared inside the block (especially `bool handledX` style flags)
- Every constant or magic string the block depends on

Local variables in particular can be referenced from sibling paths — shared OR-chain conditions, post-block cleanup, multi-handler dispatchers — that a function-name grep won't catch. Specific gotcha: removing a block that declared `bool handledWDFGrowth`, then later in the same function a multi-handler OR guard `If handledWDFGrowth || handledY || handledZ` fails to compile with an unrelated-sounding error.

Use `findstr /S /I "symbolName" *.psc` on Windows, or `grep -r` on Linux/Mac. Run it across the **entire** Source/Scripts folder, not just files you happen to have open.

### Beware out-of-date uploaded files

If you're sharing scripts between machines or with collaborators, always confirm you have the latest version of every file before making cross-script changes. A "forward-looking" upload list (the files you *think* are relevant) is almost never complete. When in doubt, grep the full project for callers.

### Manage in-flight edits carefully

When you have local edits in progress, don't accidentally re-copy a "fresh" version of the same file from your upload source — you'll silently revert your in-progress work. Pick a working directory and stay in it.

---

## 7. Persistent Storage

For a religion mod you'll likely want to track: which NPCs follow which deity, prayer counts, offering totals, sacred sites visited, possibly a worship "skill" or favor level per deity. The options:

### StorageUtil (simplest, recommended for most things)

PapyrusUtil's `StorageUtil` lets you attach typed values (int, float, string, form) and arrays to any form or globally. Simple, reliable, fast.

```papyrus
StorageUtil.SetIntValue(akTarget, "MyMod.prayerCount", 1)
StorageUtil.GetIntValue(akTarget, "MyMod.prayerCount", 0)  ; default 0
```

Convention: namespace your keys (`MyMod.foo`) so you don't collide with other mods.

### JContainers (when you need maps and trees)

JContainers gives you JMap / JArray / JFormMap — useful for nested structures like per-deity stats or scripted shrine rosters. More flexible but heavier, and you have to manage object lifetimes (root them in JDB or attach to a form).

A few cautions:
- JContainers JSON snapshot output is unreliable across forks; if you need to emit JSON to a UI, hand-build it.
- Always test that you're reading from the same backend you wrote to. A common bug: writing via `StorageUtil` but reading via `JFormDB` (or vice versa) — get back zeros or empty strings and chase ghosts.

### Custom Skills Framework (CSF) if you want a real skill

If your religion mod wants a "Worship" or "Piety" skill that levels up, integrates with the vanilla skill menu, and grants perks — use **Custom Skills Framework** by Meh321. It's the standard.

Caveat: CSF's API doesn't expose XP-within-current-level cleanly. You can ask "what level am I?" but the granular progress bar value is awkward to read out. Plan UI around level transitions, not progress percentages.

A nicer skill menu shell on top of CSF is **Meta Skill Menu** by Mardoxx (Nexus 62423). Good UX if you want a discoverable home for your skill tree.

---

## 8. Architecture & Scope

### Pick your dependencies deliberately

Every required dependency reduces your potential audience. Cost-benefit:

| Dependency | Use when | Cost |
|---|---|---|
| SKSE | Almost always (Papyrus alone is too limited) | Standard, expected |
| PapyrusUtil | Need StorageUtil, math, arrays | Tiny, ubiquitous |
| JContainers | Need maps/trees, JSON | Bigger but well-supported |
| UIExtensions | Custom menus from Papyrus | Adds a menu dep |
| CSF | Custom skill | Niche but standard |
| Custom SKSE plugin (C++) | Truly need engine-level access | Big — you maintain it |

Don't write a C++ SKSE plugin unless you've genuinely exhausted Papyrus options. The maintenance burden compounds.

### Start with the data model, not the UI

Before writing dialogue, before building shrines, decide:

- What's a "follower" of a deity? (faction? storageutil flag? per-actor object?)
- Where does prayer count live? Per-actor? Per-deity-globally? Both?
- How does the player query "how am I doing with God X?"
- What's the unit of progression? Daily prayers? Quest completions? Total offerings?

Get this right and the dialogue/UI/perks layer on cleanly. Get it wrong and you'll refactor everything twice.

### Idempotent daily ticks

Mods often want "daily bonus" effects — once per in-game day, apply X. Standard pattern:

1. Stamp a JDB key with the current game day when you apply.
2. Before applying, check the stamp — if it matches today, skip.

This protects against duplicate-fire from multiple update sources (`OnUpdate`, `OnUpdateGameTime`, sleep wake-up, etc.).

---

## 9. General Wisdom

- **Notifications are precious.** `Debug.Notification` is the only "passive" feedback channel that doesn't require the player to open anything. Don't burn it on routine state changes; reserve it for things the player needs to know but isn't actively looking for.
- **Players will not read.** If your mod has a tutorial book or readme, assume nobody reads it. Design around discoverability — every important action should have an obvious entry point in-game.
- **Test on a clean profile.** Periodically install your mod on a fresh MO2 profile with only the bare minimum (SKSE, Address Library, your declared deps). It will expose hidden dependencies you didn't realize you'd absorbed from your dev profile.
- **Faction rank is your friend.** You can store small integer state in faction rank without inventing new storage. Useful for "tier of follower" or "deity affinity 0-5."
- **Save-bake. Plan for it.** Players will use your mod in saves spanning months. Anything you remove from the script architecture lives on in old saves as orphan references. Design new features as additive when you can; design removals carefully when you must.

---

## TL;DR for a religion mod

If your friend is doing a religion mod specifically, the top six things to internalize:

1. **Two factions per role, minimum** — one for "eligible," one for "active." Audit every dialogue gate when state changes.
2. **ASCII only** for prayers, scripture, dialogue, notifications. No fancy quotes or em-dashes.
3. **Build a debug dispatcher on your control quest from day one** — you'll use it for console testing, MCM buttons, and in-mod UI uniformly.
4. **Code over docs** — keep a design doc for intent, but always grep the code for current behavior before making changes.
5. **Use CSF if you want a real skill, StorageUtil for everything else.** Don't reach for JContainers unless you actually need nested structures.
6. **Test from a new game every time you touch a script.** Old saves cache old script state in ways that will mislead you.

Good luck to them. The first mod is the hardest; the second one is half the work.
