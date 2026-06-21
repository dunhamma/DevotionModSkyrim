# Codex Handoff — MCM Manager-Binding Self-Heal

**Owner:** Codex (live Papyrus). **Author of this spec:** Claude.
**Batch:** 1A. **Implement:** FIRST (unblocks in-game Session A; it's the
first-impression beta blocker). Self-contained — **no open items**.
**File:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc`.

## Problem

On some saves the MCM Player page shows "Devotion is still starting up" even
though the manager quest is running, because `PDV_MCM`'s `PDV_Manager` property
baked to `None` on that save and the EventBus ref is also unbound. `GetManagerService()`
(lines 2224–2234) has only two resolution paths (own property → EventBus's
property) and **no plugin-level last resort**, so it returns `None` and the
player sees a dead mod. A tester won't run the console recovery; they'll uninstall.

## Fix A (root) — add a plugin-level last resort to `GetManagerService`

`GetManagerService()` currently is:
```papyrus
PDV__ManagerQuest Function GetManagerService()
    if PDV_Manager
        return PDV_Manager
    endIf

    if PDV_EventBusService && PDV_EventBusService.PDV_Manager
        return PDV_EventBusService.PDV_Manager
    endIf

    return None
EndFunction
```
Insert a third fallback before `return None`:
```papyrus
    ; Plugin-level last resort: resolve the manager quest directly from
    ; Devotion.esp so the MCM self-heals even on a save where BOTH the baked
    ; PDV_Manager property and the EventBus ref are unbound (the "still
    ; starting up" failure). 00C325 = PDV__ManagerQuest QUST in Devotion.esp.
    PDV__ManagerQuest pluginManager = Game.GetFormFromFile(0x00C325, "Devotion.esp") as PDV__ManagerQuest
    if pluginManager
        return pluginManager
    endIf

    return None
```
No caching needed: `EnsureManagerBinding` (lines 2236–2252) already caches the
resolved manager into `PDV_Manager` after the first success and validates a
read-only call, so the `GetFormFromFile` runs at most once per affected save.
`GetFormFromFile` resolves the plugin by filename, so a different load-order
index is handled automatically; only the 6-hex object index (`00C325`) is fixed.

## Fix B (defense) — make the player page attempt a rebind before the fallback

`BuildPlayerPage` reads the raw property at **line 1006** (`if PDV_Manager`),
so even with Fix A it won't self-heal at page build unless something else already
rebound. Change line 1006 from:
```papyrus
    if PDV_Manager
```
to:
```papyrus
    if EnsureManagerBinding("player_page")
```
The `else` branch at line 1029 (the "still starting up" text) then only shows
when the manager is genuinely unresolvable via all three paths. Leave the body
(lines 1007–1027) unchanged — after `EnsureManagerBinding` returns True,
`PDV_Manager` is set, so every `PDV_Manager.Get…()` call resolves.

The two `OnOptionSelect` fallbacks (lines 412, 425) already gate on
`EnsureManagerBinding(...)`, so they inherit Fix A automatically — no edit there.

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV_MCM
node .\tools\pdv_verify.mjs
```
Expect `1 succeeded, 0 failed` and `FAIL=0` (SEQ-freshness WARN ok). Snapshot +
commit, then hand back to Claude to pull→mirror.

## Codex closeout (2026-06-21 AEST)

Applied to the live MO2 source and the tracked `live-source` mirror:

- `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc`
- `C:\Users\Admin\Documents\Devotion Mod Project\live-source\Scripts\Source\PDV_MCM.psc`

Machine gates:

- `node .\tools\pdv_compile.mjs --script PDV_MCM`: `1 succeeded, 0 failed`,
  `0 error(s), 0 warning(s)`.
- `node .\tools\pdv_verify.mjs`: `FAIL=0, WARN=3, TODO=0, PASS=3083,
  INFO=35`.

Warnings observed: four unnamed INFO records, medallion glyph fallback, and SEQ
mtime freshness. Runtime/manual proof remains the Session A MCM Player-page
check below.

## In-game proof (User — Session A)

On a save that previously showed "Devotion is still starting up" (or force it:
the page should never show that text while `PDV__ManagerQuest` is running): open
MCM → Player page → confirm Summary/Startup/Mode lines render real data, not the
fallback. With `PDV_GLO_DebugLevel >= 1`, the Papyrus log shows
`[PDV] MCM: Manager rebound (player_page)` on the heal. Record in the manual
evidence ledger (framework-floor slot).
