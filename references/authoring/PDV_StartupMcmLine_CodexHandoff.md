# Codex Handoff — `GetStartupMcmLine` Post-Confirm Branch

**Owner:** Codex (live Papyrus). **Author of this spec:** Claude.
**Batch:** 1G (Session A2 follow-up). **Implement:** any time; small,
self-contained, no upstream blockers. **No open items.**
**File:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`.

## Problem

After completing the per-path startup confirm on an explicit-choice race
(Breton / Bosmer / Orc / Redguard / Nord), the MCM Player page's **Startup**
row keeps showing `"Choose a starting path, then confirm."` forever. The
Summary and Mode rows on the same page correctly flip to the confirmed
canonical (e.g. `"BRETON | GREEN WAY | UNPROVEN"` / `"GREEN WAY"`), so the
three rows visually disagree about whether startup is done.

Discovered 2026-06-22 during Session A2 in-game retest on a fresh Breton
(post-confirm Green Way save). The 1A self-heal is unrelated and working
fine — manager is bound, `GetPlayerMcmSummaryLine` and `GetPlayerMcmModeLine`
return the post-confirm canonical strings; **only** the Startup row is stale.

## Root cause

`GetStartupMcmLine` at `PDV__ManagerQuest.psc:14116-14124`:

```papyrus
String Function GetStartupMcmLine()
    Int originRace = GetPlayerOriginRaceIndex()
    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        return "Choose a starting path, then confirm."
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction
```

It branches on `startupMode == STARTUP_MODE_EXPLICIT_CHOICE` and returns the
prompt unconditionally for those races, **never checking
`PDV.Startup.UnifiedChoiceComplete`**. The parallel function
`GetPlayerMcmModeLine` at `:14086-14089` already gates on the same flag the
correct way:

```papyrus
if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
    return GetStartupMcmLine()
endIf
```

— which is why **Mode** flips to the canonical summary post-confirm while
**Startup** does not.

## Fix

Replace `GetStartupMcmLine` with the gated version:

```papyrus
String Function GetStartupMcmLine()
    Int originRace = GetPlayerOriginRaceIndex()
    Int startupMode = GetStartupModeForOrigin(originRace)
    if startupMode == STARTUP_MODE_EXPLICIT_CHOICE
        if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
            return "Choose a starting path, then confirm."
        endIf
    endIf

    return GetStartupCanonicalSummary(originRace)
EndFunction
```

Post-confirm, the function falls through to `GetStartupCanonicalSummary(originRace)`
— the same source `GetPlayerMcmModeLine` already trusts.

No other callers need changing. `GetPlayerMcmModeLine` keeps its existing
"if not complete, delegate" pattern and gets the right answer either way.

## Side effect: cosmetic label/value collision auto-fixes

The screenshot also showed `"startUpCHOOSE A STARTING PATH, THEN CONFIRM."`
with the SkyUI label/value columns visually colliding (no separator). That's
a SkyUI two-column overflow because the 36-char prompt is the longest value
on the page and eats the gutter. After this fix, the prompt only renders
pre-confirm, so the collision disappears once the player completes startup.
No separate fix needed.

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_verify.mjs
```

Expect `1 succeeded, 0 failed` / `0 error(s), 0 warning(s)` and `FAIL=0`
(SEQ-freshness WARN ok). Snapshot + commit, then hand back to Claude to
pull→mirror.

## In-game proof (User — Session A2 retest)

On a post-confirm explicit-choice save (any of Breton / Bosmer / Orc /
Redguard / Nord), open MCM → Player page → confirm the **Startup** row now
shows the canonical summary (e.g. `"Green Way"`, `"Old Ways"`, `"Stronghold"`)
instead of `"Choose a starting path, then confirm."`. Summary and Mode rows
should keep showing what they already do. Record in the manual evidence
ledger under the framework-floor slot adjacent to the 1A entry.
