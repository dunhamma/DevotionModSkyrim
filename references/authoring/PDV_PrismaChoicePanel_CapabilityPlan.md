# PDV Prisma Choice Panel -- Capability Plan (Avenue B)

**Created:** 2026-06-19
**Status:** PLAN FOR SIGN-OFF. No code, records, native source, or toolchain
files changed yet. This document is the scoped build spec the product owner
asked for after choosing Avenue B. Nothing here is implemented until the
sign-off decisions in Section 12 are answered.

Companion to `references/authoring/PDV_PrismaIntegrationBoundary.md`
(the locked boundary this capability must satisfy) and the
Argonian rite menu feasibility finding that motivated it.

---

## 1. Goal

Build a reusable, SAFE Prisma-backed blocking-choice capability -- a "PDV choice
panel" -- that can present N options (full labels, multi-row grid, custom size)
and return the player's pick to `PDV__ManagerQuest` as a typed result, WITHOUT:

- trapping input (player can always escape),
- overlapping live controls or another menu/MessageBox,
- making gameplay depend on Prisma being up (vanilla `Message.Show()` stays the
  permanent fallback floor).

The Argonian "Hist Adaptation" rite (`PDV_MESG_ArgonianAdaptRite`,
`0714D5:Devotion.esp`) is the proposed low-stakes PILOT. The capability is
designed to generalize to the ~18 other blocking menus (Section 10).

This is the only avenue that fits the locked boundary. Editing the global
`messagebox.swf` (Avenue A) was rejected: strictly global blast radius, no
per-message override, and it forks the third-party Better MessageBox Controls
mod that owns the live layout.

## 2. Why the current bridge cannot do this yet

Traced across all three layers:

| Layer | File | State today |
|---|---|---|
| Native bridge | `native/DevotionPrismaBridge/src/main.cpp` | 6 one-directional game->Prisma funcs. NEVER calls `RegisterJSListener`. No return channel. `SendOverlayJson` shows but never focuses, so it cannot capture input. |
| PrismaUI API | `native/DevotionPrismaBridge/include/prisma/PrismaUI_API.h` | Already provides the primitives we need: `RegisterJSListener` (:48), `Focus(view, pauseGame, disableFocusMenu)` (:55), `Unfocus`/`HasFocus`/`HasAnyActiveFocus` (:57-58,:101). Unused by us. |
| View | `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js` | Interop is inbound only (`ReceivePDVJson` / `ReceivePDVOverlayJson`, :1715-1716). Startup/medallion option buttons (:1241,:1312) only mutate local DOM state. No call ever leaves the view. |
| Manager | live `PDV__ManagerQuest.psc` | No `RegisterForModEvent` anywhere. Has a 1s `OnUpdate` heartbeat (:681, re-armed :678/:783). Startup payload builder `SendPrismaStartupPayload` (:12225) already emits an `[{option_id,title,summary,description}]` array but ships it via the NON-focused `SendOverlayJson` (:12262) -- i.e. display-only even when enabled. |

Net: the return channel (Prisma -> manager) is net-new at every layer. The
PrismaUI engine supports it; the Devotion bridge does not use it.

## 3. Constraints this must satisfy (non-negotiable)

From `PDV_PrismaIntegrationBoundary.md` and `tools/pdv_prisma_ui_audit.mjs`:

1. `AllowPrismaBlockingSurfaces` defaults FALSE and stays the master gate. The
   choice path must early-return when it is false (audit-enforced shape).
2. Every Prisma call must be guarded by `PDV_PrismaBridge.IsAvailable()`; bridge
   down => vanilla MESG fallback.
3. The audit currently hard-requires EXACTLY ONE focused `SendJson` call in the
   manager (`pdv_prisma_ui_audit.mjs:115-120`). A focused choice surface adds a
   second focused channel and WILL fail the audit as written. The audit must be
   extended (Section 8) -- a toolchain edit that needs explicit sign-off
   (CLAUDE.md rule 4).
4. "P2 proves state. Prisma surfaces state." The choice result feeds manager
   state through a typed payload; the manager remains authoritative. P2 proof
   must never depend on this surface.

## 4. Architecture

```
present:  manager -> PDV_PrismaBridge.ShowChoice(menuId, optionsJson)   [focused, paused]
                  -> C++ Focus(view) + InteropCall(showChoice, payload)
                  -> JS renders grid, registers one-shot result handler

pick:     JS button/ESC -> prisma.invoke("PDVChoiceResult", {menu, index|cancel})
                        -> C++ JSListener stores {menuId, index, cancelled}, Unfocus(view)
                        -> game unpauses

consume:  manager OnUpdate tick -> PDV_PrismaBridge.ConsumePendingChoice()
                                -> matches menuId -> ApplyArgonianAdaptation(index)
                                -> or handles cancel / watchdog timeout
```

### Return-channel mechanism: poll into the existing tick (recommended)

Two options for SKSE -> Papyrus delivery:

- **(A) Poll via existing `OnUpdate` heartbeat (RECOMMENDED).** C++ stores the
  result; a new native `ConsumePendingChoice()` returns + clears it; the manager
  already ticks every 1s, so the same tick consumes the result and runs the
  watchdog. Fits the codebase (no new event pattern), and centralizes the
  watchdog in one place.
- **(B) SKSE mod event + `RegisterForModEvent`.** More event-pure, but
  introduces a subscription pattern the manager does not currently use, and
  scatters watchdog logic. Not recommended for a first build.

Caveat to design around (belongs in the proof, Section 7): while
`Focus(pauseGame=true)` holds the game paused, the Papyrus update timer is
suspended, so the poll/watchdog does NOT run mid-focus. That is acceptable
because result delivery happens at unfocus (C++ unfocuses the instant JS
reports), after which the tick resumes and consumes. It does mean the Papyrus
watchdog cannot rescue a trap that occurs WHILE focused -- which is exactly why
the primary escape must be client-side (Section 7), not a Papyrus timer.

## 5. Proposed API surface

### Native (additions to `main.cpp` + `PDV_PrismaBridge.psc`)

```papyrus
; Capability probe so an OLD dll degrades to MESG instead of erroring on a
; missing native. Manager must gate ShowChoice/ConsumePendingChoice behind this.
Bool Function SupportsChoice() Global Native

; Focused, input-capturing show of a choice grid. pauseGame chosen by caller.
; Returns False if the view/bridge is unavailable (caller falls back to MESG).
Bool Function ShowChoice(String payload) Global Native

; Non-blocking poll. Return contract (status, not raw index, to disambiguate):
;   -3 = no choice channel active
;   -2 = pending (focused, awaiting a pick)
;   -1 = cancelled (ESC / cancel / dismissed)
;   >=0 = chosen option index
; The token also carries the menuId so the manager can verify the result
; belongs to the menu it opened (drops a stale/foreign result).
Int  Function ConsumePendingChoice(String menuId) Global Native
```

C++ work in `main.cpp`:
- On first `ShowChoice`, call `RegisterJSListener(view, "PDVChoiceResult", cb)`.
- Add a focused show path: `Show` + `Focus(view, pauseGame, /*disableFocusMenu=*/false)`
  (keep PrismaUI's own focus-menu escape ON as an independent rescue).
- `InteropCall(view, "ReceivePDVChoice", payload)`.
- JSListener callback parses `{menu,index|cancel}`, stores it, calls
  `Unfocus(view)`.
- `ConsumePendingChoice` returns the stored status and clears it.

### View (additions to `app.js` + index.html/styles.css)

- New `window.ReceivePDVChoice(payloadText)` that renders a 3+2 (N-up) grid from
  the same `[{option_id,title,summary,...}]` shape `SendPrismaStartupPayload`
  already produces -- so the payload builder is shared.
- Each option button + an always-present Cancel control + a global `keydown`
  ESC handler all call `prisma.invoke("PDVChoiceResult", JSON.stringify({...}))`
  exactly once (latch to ignore double-fire), then clear the grid.
- Reuse existing fonts/symbol rendering; this is layout only.

### Manager (Papyrus)

- New guarded builder mirroring the existing guard shape:

```papyrus
Bool Function ShowPrismaChoice(String menuId, String optionsJson, Bool pauseGame = true)
    if !AllowPrismaBlockingSurfaces
        return False
    endIf
    if !PDV_PrismaBridge.IsAvailable() || !PDV_PrismaBridge.SupportsChoice()
        return False
    endIf
    String payload = "{\"mode\":\"choice\",\"choice\":{\"menu\":\"" + menuId + "\",...}}"
    StorageUtil.SetStringValue(None, "PDV.Choice.PendingMenu", menuId)
    StorageUtil.SetIntValue(None, "PDV.Choice.PresentedDay", today + 1)  ; pending guard
    return PDV_PrismaBridge.ShowChoice(payload)
EndFunction
```

- Consume in the existing `OnUpdate` tick: if a pending menu is set, call
  `ConsumePendingChoice(menuId)`, dispatch on the status, clear the pending
  guard, and run the watchdog (Section 7).

## 6. Rite control-flow change (sync -> async)

`TryArgonianAdaptationRite` (live `PDV__ManagerQuest.psc:2693`) keeps ALL its
pre-gates unchanged (origin, substrate threshold, rooted, Adapt.Active==0, the
10-14 day clock). Only the present/apply step changes:

```
existing (unchanged fallback):
    Int pressed = PDV_MESG_ArgonianAdaptRite.Show()   ; :2733, synchronous
    if pressed < 0 || pressed > 3 ... else ApplyArgonianAdaptation(player, pressed)

new:
    if ShowPrismaChoice("argonian_adapt", <5 options>)   ; async, focused
        return True   ; "menu shown" -> dream does not stack tonight
    endIf
    ; bridge down / gate off -> existing synchronous MESG path, byte-for-byte
    Int pressed = PDV_MESG_ArgonianAdaptRite.Show()
    ...
```

- The result (apply adaptation index 0-3, or cancel on index 4 / ESC) is handled
  by the tick consumer calling the EXISTING `ApplyArgonianAdaptation`
  (`:2743`) -- no reward logic changes.
- A `PDV.Choice.Pending*` guard prevents re-offering the same menu while a pick
  is outstanding.
- Worst case (Prisma absent) == today's behavior exactly.

## 7. Input-safety design (THE gate)

This is what currently keeps `AllowPrismaBlockingSurfaces` false. Layered so no
single failure traps the player:

1. **Primary escape is client-side, not Papyrus.** ESC + a visible Cancel
   control in the view ALWAYS send a `cancel` result and release focus, even if
   the game is paused (JS/PrismaUI input runs while focused). This is the main
   guarantee.
2. **Independent engine escape.** Show with `disableFocusMenu=false` so
   PrismaUI's own focus-menu can release focus even if our JS handler is broken.
3. **Papyrus watchdog (secondary).** After unfocus the tick resumes; if a
   presented menu has no result within N ticks (view never came up, result lost
   after unfocus), force `Unfocus`, clear pending, and either fall back to MESG
   or silently abort. Explicitly does NOT cover a mid-paused-focus trap -- (1)/(2) do.
4. **No overlap.** Before focusing, gate on `Utility.IsInMenuMode()` and
   `HasAnyActiveFocus()`; never open over an existing menu/MessageBox; defer.
5. **Bridge down.** `IsAvailable()`/`SupportsChoice()` false => never touch
   Prisma; use MESG.
6. **Save/load.** Saving mid-choice must restore unfocused and unstuck:
   on load, if a pending menu exists, clear focus and re-arm or abort.

### Proof matrix (must all pass to flip the gate for choice surfaces)

| Scenario | Expected |
|---|---|
| Normal pick (each of 5 options) | correct adaptation applied / cancel = no change |
| ESC while focused | cancel, focus released, game resumes |
| Cancel control | same as ESC |
| Bridge DLL absent / old DLL | falls through to MESG, no error |
| Open while another menu up | deferred, never overlaps |
| Save mid-choice, reload | not stuck, not double-applied |
| JS error / no response | watchdog releases focus, falls back |
| Fresh game / load / combat / menu-stack | no trap in any |

`node tools/pdv_prisma_ui_audit.mjs` must pass (after Section 8).

## 8. Audit revision (toolchain edit -- needs sign-off)

`tools/pdv_prisma_ui_audit.mjs` must learn about the choice channel:

- Allow exactly ONE focused choice channel: a single `ShowChoice(` call site in
  the manager, inside `ShowPrismaChoice`, guarded by both
  `if !AllowPrismaBlockingSurfaces` and `IsAvailable()`/`SupportsChoice()`.
- Keep the existing "exactly one `SendJson`" rule for `PushDevotionPanel`
  untouched (do not relax it).
- Forbid non-manager source from calling `ShowChoice` (same rule class as
  `SendJson`).

Per CLAUDE.md rule 4, the audit is a toolchain script; I will not touch it
without explicit approval. It is listed here as a required, scoped edit.

## 9. Versioning, compatibility, distribution

- Rebuilding the SKSE plugin (`xmake`) and shipping a new
  `DevotionPrismaBridge.dll` + updated `PDV_PrismaBridge.psc` (now declaring 3
  new natives) is heavier than the usual Papyrus/Mutagen/JS toolchain -- a real
  build-environment + redistribution cost.
- A `.psc` that declares a Native the loaded DLL does not register will ERROR at
  call time. Hence the `SupportsChoice()` probe: the manager must gate all new
  natives behind it so an old/missing DLL degrades to MESG rather than throwing.
- New view assets ship in the existing Devotion PrismaUI view folder; no new
  external dependency.

## 10. Reuse map -- why build it as a capability, not a one-off

The manager has ~18 blocking `.Show()` menus that could opt into this; the big
ones drive the value:

| Menu | live site | Notes |
|---|---|---|
| Startup race/path select + per-path confirm | :11002-11325 | Most layout-stressed menu in the mod -- the real driver |
| Argonian adaptation rite (PILOT) | :2733 | Low frequency, clean MESG fallback |
| Argonian bed-of-choice | :2671 | |
| Bosmer mark-hearth / naming / reckoning | :3157,:3217,:13556 | |
| Formal offer | :9564 | |
| Suggestion / retry / confirm | :11294,:13633, etc. | |

A single `ShowPrismaChoice(menuId, optionsJson, pauseGame)` + the tick consumer
+ MESG fallback serves all of them. Each menu opts in by building an options
array (the `SendPrismaStartupPayload` builder is already the template) and
leaving its `.Show()` as the fallback.

## 11. Phasing and rough effort

Gated; each phase proves before the next. Effort is relative, not hours.

- **Phase 0 -- plumbing proof (throwaway). [SOURCE COMPLETE 2026-06-19; awaiting
  game-closed build + in-game proof -- see Section 14.]** Wire `RegisterJSListener`
  + a focused show + `ConsumePendingChoice` end to end on a dummy 2-option menu
  behind a SetPQV debug flag (`DebugPrismaChoiceGo`, mirroring the existing
  DebugSeed harness -- no MCM surgery for a throwaway). Prove a round trip and
  ESC escape. No rite, no manager flow, no audit change (audit still 13/13).
  GATE: round trip + escape proven in game.
- **Phase 1 -- capability + audit.** Add `ShowPrismaChoice` + tick consumer +
  watchdog + the `SupportsChoice` probe; extend the audit. GATE: audit passes,
  watchdog + fallback proven.
- **Phase 2 -- rite pilot.** Convert `TryArgonianAdaptationRite` to the async
  present/apply with MESG fallback. GATE: full Section 7 proof matrix on the
  rite.
- **Phase 3 -- input-safety sign-off.** Run the proof matrix across fresh
  game/load/combat/menu-stack/save-mid-choice. GATE: flip
  `AllowPrismaBlockingSurfaces` for choice surfaces only (panel push stays off).
- **Phase 4 -- generalize.** Migrate the startup flow and other menus opt-in.

The proof (Phases 0/3), not the code, is the long pole.

## 12. Sign-off decisions needed before any build

1. Confirm "Go for B" authorizes me to START Phase 0 (writes native C++,
   Papyrus, JS), or whether this plan alone is the deliverable for now.
2. Return channel: poll-into-tick (A, recommended) vs mod event (B)?
3. Default `pauseGame` for choice surfaces: true (modal, recommended) vs false
   (non-blocking, keeps Papyrus watchdog live)?
4. Pilot menu: the Argonian rite (recommended) or go straight to the startup
   flow?
5. Approval to edit the toolchain audit `tools/pdv_prisma_ui_audit.mjs`
   (required for Phase 1; CLAUDE.md rule 4).
6. Approval to rebuild + redistribute the native SKSE DLL.

## 13. Risks / open questions

- Papyrus update-timer suspension during paused focus (Section 4 caveat) is
  handled by client-side escapes, but must be PROVEN, not assumed.
- PrismaUI focus interaction with other SKSE UI (MCM, other overlays) under
  `HasAnyActiveFocus` needs in-game confirmation.
- Glyph/font coverage for full labels in the grid (existing IMFellEnglish set).
- This does not change P2 proof standing; it is a UI-track capability behind the
  default-off gate.

## 14. Phase 0 build + test runbook (current)

### Source changes landed (2026-06-19)

| Layer | File | Change |
|---|---|---|
| Native | `native/DevotionPrismaBridge/src/main.cpp` | `RegisterJSListener("PDVChoiceResult", OnChoiceResult)` in EnsureView; focused `ShowChoiceImpl` (`InteropCall ReceivePDVChoice` + `Show` + `Focus(view,true,false)`); `OnChoiceResult` parses `"<menu>\|<token>"`, stores status, `Unfocus`; new natives `SupportsChoice` / `ShowChoice(menuId,payload)` / `ConsumePendingChoice(menuId)`. |
| Bridge decls | `native/DevotionPrismaBridge/mod/Scripts/Source/PDV_PrismaBridge.psc` + live `D:\...\Devotion\Scripts\Source\PDV_PrismaBridge.psc` | 3 native declarations. |
| View | `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js` (repo only so far) | `window.ReceivePDVChoice` -> 3-up grid (wraps 3+2), buttons + Cancel + global ESC -> `window.PDVChoiceResult("<menu>\|<idx-or-cancel>")`; bad payload -> cancel (no trap). Inline styles, no HTML/CSS edits. |
| Manager | live `D:\...\Devotion\Scripts\Source\PDV__ManagerQuest.psc` | `Int Property DebugPrismaChoiceGo Auto Hidden`; `Phase0PrismaChoiceTick()` (present-on-flag, consume-on-later-tick); call added in `OnUpdate` before the re-arm. |

Verified statically: `node tools/pdv_prisma_ui_audit.mjs` = 13/13 PASS (Phase 0 adds no audit-visible surface). C++ re-read for coherence; all 9 Papyrus functions registered.

### Build + deploy: DONE (2026-06-19, Skyrim closed)

1. View deployed: live `app.js` == repo (verified identical).
2. DLL built + deployed: `xmake f -y -m releasedbg` + `xmake -y` -> `build ok,
   14.9s`; `after_build` copied to live `SKSE/Plugins`. Live DLL = 409600 bytes,
   mtime 21:46, SHA256 == build output; all 5 new tokens (`SupportsChoice`,
   `ShowChoice`, `ConsumePendingChoice`, `PDVChoiceResult`, `ReceivePDVChoice`)
   present in the deployed binary.
   - NOTE: `xmake` was MISSING machine-wide this session (the README path was
     gone). Reinstalled portable v3.0.8 to `C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe`
     (VS Build Tools at `C:\BuildTools` was still present). `commonlibsse-ng`
     package was still cached, so no network restore was needed.
3. Papyrus compiled (live): `PDV_PrismaBridge` 0/0, `PDV__ManagerQuest` 0/0;
   verifier `FAIL=0, WARN=2` (the two known-live unnamed INFOs); prisma UI audit
   13/13.

### Remaining: in-game proof (USER -- requires launching Skyrim)

Fresh launch, load a save, open console, fire (same quest target as the
DebugSeed setpqv harness):

   `setpqv PDV__ManagerQuest DebugPrismaChoiceGo 1`

### Pass criteria
- A 2-option grid appears and the game pauses.
- Click Option A/B -> top-left "PDV Phase 0: picked option 0/1 (round trip OK)";
  game resumes.
- Re-fire, press Esc (or Cancel) -> "PDV Phase 0: CANCELLED (Esc/cancel round
  trip OK)"; game resumes.
- Focus releases every time (no input trap); `Data\SKSE\Plugins\DevotionPrismaBridge.log`
  shows `Prisma choice result: menu='phase0_test' status=N`.
- Old-DLL guard: if the DLL was NOT rebuilt, `SupportsChoice()` is false and the
  tick reports "Prisma choice channel unavailable" instead of erroring.

### Contracts proven here (carried into Phase 1)
- JS->C++: `window['<listener>'](stringArg)` (confirmed from PrismaUI.dll's own
  injected IME-focus JS). C++->JS: `InteropCall(view, fn, arg)` -> `window[fn](arg)`.
- Result wire format (inbound) is the simple `"<menu>|<token>"` string; Phase 1
  may upgrade to JSON. Outbound option payload is already JSON.
- `Focus(view, pauseGame, disableFocusMenu=false)` + `Unfocus` (from the result
  callback) govern input capture. Phase 0 now uses pauseGame=FALSE (see below).

### Attempt 1 FROZE the game -- root cause + fix (2026-06-19)

First `setpqv ... DebugPrismaChoiceGo 1` hard-froze Skyrim. Bridge log showed
`Created Prisma view` + `DOM ready`, then nothing -- the grid never rendered and
no result returned.

Root cause: `ShowChoiceImpl` called `InteropCall(ReceivePDVChoice)` + `Focus(pauseGame=true)`
IMMEDIATELY after creating a COLD view, before the DOM was ready and
`window.ReceivePDVChoice` existed. The payload was dropped, the grid never
rendered, no ESC handler attached -- yet the game was focused + PAUSED. A paused
game also freezes the 1s Papyrus `OnUpdate` tick, so the watchdog could not fire
-> unrecoverable trap. Exactly the hazard the plan flagged, proven live.

Fix (defense-in-depth; DLL + .pex rebuilt/redeployed 2026-06-19 ~22:55-22:57):
1. Defer the grid send + focus to `OnDomReady` when the view is cold (track
   `g_domReady`); never focus an empty view.
2. Phase 0 calls `ShowChoice(..., pauseGame=FALSE)` so the OnUpdate watchdog
   stays alive and a failed render cannot hard-freeze.
3. New native `CancelChoice()` + a manager watchdog (~20 ticks) force-release a
   stuck panel.
4. Hardened view CSS (explicit edges, not `inset`) + a `console.log` render
   marker that surfaces in the bridge log.

LESSON (carry into Phase 1): a modal `pauseGame=true` choice CANNOT rely on a
Papyrus watchdog (paused => tick frozen). Modal safety must be client-side (JS
ESC/cancel) + PrismaUI's focus-menu + a render-before-focus guarantee. Never
focus until the UI is confirmed interactive.

### Re-test (build done; Skyrim launch needed)

Fresh launch, load a save at a SAFE spot (non-modal: the world keeps running),
console: `setpqv PDV__ManagerQuest DebugPrismaChoiceGo 1`. Expect the grid to
render (game NOT paused), click -> "picked option N", Esc/Cancel -> "CANCELLED",
or ~20s idle -> "watchdog forced unfocus". Bridge log should show
`PDV choice render: menu=phase0_test options=2` then `Prisma choice result: ...`.

NOTE: a separate verifier FAIL (LIKES_DISLIKES_VERSION manager=9 vs pdv_verify
expects 8) is parallel LD-regen drift, NOT from this work, and does not affect
the Phase 0 test.
