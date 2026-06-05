# Codex Handoff — Prisma substrate instruments: Papyrus wiring + native ambient bridge

**For:** Codex (owns the live `PDV__ManagerQuest.psc` and the native `DevotionPrismaBridge` DLL).
**From:** the Prisma substrate-equity design pass. Read first:
- `handoff/PrismaSubstrateInstruments_DesignDraft.md` — the full design + locked decisions.
- `references/authoring/PDV_PrismaUXEquityAudit.md` — why this exists (substrate races get a thin Prisma surface).

**Why these two tracks are yours:** Track A edits the **live `PDV__ManagerQuest.psc`** (your canonical
file — Claude has been editing only the `scratch/p2-toast-panel-fix/` repo snapshot, which then has to be
reconciled with your live edits; cleaner for you to own the wiring). Track B is **native C++** (`src/main.cpp`
+ `xmake`) — a different toolchain from anything Claude touches.

**Coordination:** Claude owns the **UI/JS** side (`handoff/PrismaInstrument_UIHandoff.md` — the
`eventLanguage.substrate` block and the instrument renderer registry in `app.js`). The JSON contracts below
are the fixed interface between your tracks and Claude's. **Add JSON fields freely; never remove/rename.**

---

## Track A — Papyrus (`PDV__ManagerQuest.psc`) · Phases 0–1 · no native dependency

This track works through the **existing** `SendOverlayJson` channel — no native change needed. It gives
substrate races their first reactive toast stream and feeds the panel instrument.

### A1. New emitter — `SendPrismaSubstrateToast`

Mirror `SendPrismaShiftToast` (currently ~line 4223). JSON shape (must match the UI block exactly):

```json
{"mode":"toast","toast":{
  "event":"substrate",
  "substrate":"lunar|hist|ancestor|stronghold|sect",
  "phase":"act|deepen|thin",
  "symbol":"<prisma symbol key>",
  "context":"<optional race phrase>",
  "state":"<current state label, optional>"
}}
```

```papyrus
Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String state)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"substrate\""
    j = j + ",\"substrate\":\"" + JsonSafeString(substrate) + "\""
    j = j + ",\"phase\":\"" + JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + JsonSafeString(context) + "\""
    endIf
    if state != ""
        j = j + ",\"state\":\"" + JsonSafeString(state) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(j)
EndFunction
```

### A2. Emit sites (all already inventoried — `act` only fires when the daily multiplier is non-zero)

| Race | Function (current line) | Emit |
|---|---|---|
| Khajiit | `HandleKhajiitMoonObservance` (after `ObserveMoonPhaseScaled`, 1331) | `lunar`/`act`, symbol `lunar` |
| Khajiit | `RecordRoadHomeCadenceScaled` site (~1360) | `lunar`/`act` |
| Argonian | `RecordHistMaintenanceScaled` (1398), `RecordPeopleSupportScaled` (1412), `RecordBedOfChoiceReturnScaled` (1423), `RecordVoidSignalScaled` (1434) | `hist`/`act`, symbol `hist` |
| Argonian | `ProcessHistDistanceDawn` (1449) when posture weakens | `hist`/`thin` |
| Dunmer | `RecordPortableShrinePrayerScaled` (1308), `RecordPlayerHomeBonusScaled` (1316) | `ancestor`/`act`, symbol `ancestor` |
| any substrate | when `GetSubstrateTier()` increases across a record call | `deepen` |

**Pattern (Khajiit example):**
```papyrus
; inside HandleKhajiitMoonObservance, after ObserveMoonPhaseScaled:
if multiplier > 0.0
    Int tierBefore = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    ; ... (the ObserveMoonPhaseScaled call already ran) ...
    Int tierAfter = PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    if tierAfter > tierBefore
        SendPrismaSubstrateToast("lunar", "deepen", "", "lunar", "Lattice: " + GetKhajiitLunarTierLabel(tierAfter))
    else
        SendPrismaSubstrateToast("lunar", "act", "The moons marked your road-rest.", "lunar", "")
    endif
    RequestPanelRefresh()
endif
```
**Anti-spam:** gate `act` on the existing `ConsumeDailyRepeatMultiplier(...) > 0` (already in these handlers).
`deepen`/`thin` are rare — always emit. Keep `context` short or empty (the UI owns the voice).

### A3. Panel `instrument` block — `GetPanelInstrumentJson` + add to `PushDevotionPanel`

Add one **additive** object to the `PushDevotionPanel` JSON (after `debug`, ~line 636). The current UI
ignores unknown fields, so this is safe to ship before Claude's renderer lands.

```json
"instrument": { "kind":"piety|lunar|hist|ancestor|forge|sects|branch",
  "tier":0, "tierLabel":"...", "primary":0.0, "state":"...", "data":{ ... } }
```

```papyrus
String Function GetPanelInstrumentKind(Int originRace, Bool hasActiveDeity)
    if hasActiveDeity
        return "piety"
    endIf
    if originRace == ORIGIN_KHAJIIT
        return "lunar"
    elseIf originRace == ORIGIN_ARGONIAN
        return "hist"
    elseIf originRace == ORIGIN_DUNMER
        return "ancestor"
    elseIf originRace == ORIGIN_ORC
        return "forge"
    elseIf originRace == ORIGIN_REDGUARD
        return "sects"
    elseIf originRace == ORIGIN_BOSMER
        return "branch"
    endIf
    return "piety"
EndFunction
```

`GetPanelInstrumentJson(originRace, hasActiveDeity, tierValue, tierLabel, piety)` builds the object:
- `primary` = `piety/150.0` for `piety`; `tierValue/3.0` for substrate kinds.
- `state` = the substrate state line (reuse `GetPanelQuasiPatronTierLabel(originRace)` / `tierLabel`).
- `data` (per-race, expand over phases — Phase 0 may ship minimal):
  - **lunar:** `{ "phase": GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()), "focus": GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()), "lunarTier": GetKhajiitLunarTierLabel(...) }`
  - **hist:** `{ "hist": GetHistRelation, "people": GetPeopleRelation, "void": GetVoidRelation, "form": GetSubstrateForm, "voidActive": IsVoidFullyActive }`
  - **ancestor:** `{ "depth": GetSubstrateTier, "prayer": GetPrayerCount, "home": GetHomeBonusCount, "reclamation": GetDunmerReclamationFocusLabel }`
  - **forge / sects / branch:** the race's mode/sect/path label.

Keep `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc` in sync with your live edits (it is the repo copy).

---

## Track B — Native ambient bridge (`src/main.cpp` + `PDV_PrismaBridge.psc`) · Phase 2 · gates always-on

This is the only piece blocking the **always-on** instrument (the floating moon dial). The spike confirmed
PrismaUI fully supports it; the work is lifecycle in the bridge DLL.

### B0. Current behavior (from `src/main.cpp`)
- One global `PrismaView g_view`, created **hidden** at load, `SetOrder(g_view, 900)`.
- `OpenDevotionPanel` → `Show(g_view)` + `Focus(g_view, /*pauseGame*/true, false)`.
- `CloseDevotionPanel` → `Unfocus(g_view)` + **`Hide(g_view)`**.
- `SendOverlayJson` → **`Show(g_view)` (unfocused)** + `InteropCall(g_view,"ReceivePDVOverlayJson",payload)`.
- `SendJson` → `InteropCall(g_view,"ReceivePDVJson",payload)` (no Show).

So the unfocused, non-pausing HUD layer **already works** (that is how toasts render). The only gap: the
view is hidden when the panel closes, so an ambient widget can't persist.

### B1. Recommended approach (Option 1 — single view, minimal)
Keep one view; decouple "ambient visible" from panel close.

1. Add `static bool g_ambientActive = false;`.
2. New native `SetAmbientVisible(bool a_on)`:
   - `g_ambientActive = a_on;`
   - if `a_on` → `g_prisma->Show(g_view);` (do **not** focus); else → if panel not focused, `Hide(g_view)`.
3. New native `SendAmbientJson(const char* payload)`:
   - if view valid → `g_prisma->Show(g_view);` + `InteropCall(g_view,"ReceivePDVAmbientJson",payload)`.
4. Modify `CloseDevotionPanel`: `Unfocus(g_view);` then `if (!g_ambientActive) g_prisma->Hide(g_view);`
   (keep the view shown when ambient is on; just drop focus + pause).
5. Register the two new functions in `RegisterFunctions` and add them to `PDV_PrismaBridge.psc`:
   ```papyrus
   Bool Function SetAmbientVisible(Bool visible) Global Native
   Bool Function SendAmbientJson(String payload) Global Native
   ```

**JS contract (Claude implements in `app.js`):** a `window.ReceivePDVAmbientJson(payload)` entry that renders
the instrument into a **persistent** ambient DOM region (separate from the auto-dismissing toast stack).
Claude's UI handoff covers this; your job is to deliver the native entry + keep the view shown.

### B2. Alternative (Option 2 — second view, cleaner separation)
`CreateView("…/ambient.html")` as a second `PrismaView g_ambientView`, `Show` unfocused at load, its own
`SetOrder`, never focused; `SendAmbientJson` targets it. Pros: full isolation from the panel; its own JS
bundle. Cons: a second HTML/JS app to maintain. Pick Option 1 for v1 unless isolation is wanted.

### B3. Constraints & acceptance
- The ambient layer must **never** `Focus` (focus pauses the game) — visible + unfocused only.
- Do not change `SendJson` / `SendOverlayJson` signatures or the existing `ReceivePDVJson` /
  `ReceivePDVOverlayJson` entry points.
- Build: `xmake` (`xmake.lua` present), CommonLibSSE-NG / SKSE; rebuild `DevotionPrismaBridge.dll`.
- **Acceptance:** with an MCM "ambient HUD" toggle on, the substrate instrument is visible on the HUD while
  the devotion panel is **closed** and the game is **unpaused**; toggling off hides it; opening/closing the
  panel does not destroy it; no pause is introduced by the ambient layer.

---

## Suggested order
1. **Track A** first (Phase 0–1) — pure Papyrus, immediate equity win, no native dependency, pairs with
   Claude's `eventLanguage.substrate` (already specced).
2. **Track B** (Phase 2) — when ready to make instruments always-on. Pairs with Claude's ambient renderer.
