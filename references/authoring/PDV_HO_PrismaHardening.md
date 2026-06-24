# PDV_HO_PrismaHardening - Prisma UI hardening to the "UI live" gate

**Created:** 2026-06-24
**Track:** NATIVE / parallel (xmake + JS). NOT serialized on `PDV__ManagerQuest.psc`.
**Status:** Queue-ready handoff. Drafted alongside Queue A/B; dispatch independently.
**Owner contract:** `PDV_Architecture_v3.md` Sections 16.5, 16.6, 25.6 (Content-Feel
Beta "UI live" gate), 25.7 (1.0 launch).

---

## Dispatch note (read first)

This is a **native C++/JS track**, built with **xmake** under
`native/DevotionPrismaBridge/`. It does **not** edit the Papyrus manager, ESP
records, or any signal/floor/spine artifact. It can run in parallel with the
serialized Queue A and the ESP-record Queue B - it shares no write surface with
them, so there is no serialization conflict.

It is **not** on the build-debt burndown. The burndown counts machine-buildable
signal-floor items only (currently 23, all cleared by handoff A1). This handoff
advances a separate **road-to-1.0 front** ("UI live"); it does not reduce the 23.

---

## Why this exists

v3 promotes the player-facing UI from "nice to have" to a **gate**:

- Section 25.6 (Content-Feel Beta, the gate *before* 1.0) requires
  "Commitment, neglect, decay, curse-state, and UI are live."
- Section 16.5 still describes the Prisma surface as the "current prototype
  path."
- Section 16.6 lays out a 5-step UI staging sequence that has not been worked
  through.

So Prisma is a real 1.0 dependency that was not in the original Codex queue.
This handoff turns the prototype into the staged, contract-clean surface 25.6
requires.

---

## Prerequisite - do this before any new UI work

Rebuild and redeploy the bridge. The cold-view focus-trap fix is in source but
**unbuilt**: commit `5301ec0` added the `g_panelFocusPending` defer in
`native/DevotionPrismaBridge/src/main.cpp` (`OnDomReady` re-applies focus only
after DOM-ready, so a cold/first-open panel can never trap the player on an
empty focused view). See memory note "Prisma cold-view focus trap".

1. Build with xmake from `native/DevotionPrismaBridge/`.
2. Deploy `DevotionPrismaBridge.dll` plus the `mod/PrismaUI/` view tree.
3. Re-run the in-game Prisma smoke (Section 16.5): open the panel from a cold
   game state and confirm it opens populated, focused, and **ESC always
   releases** (in-view X and ESC both work on a not-pre-warmed view).
4. Confirm `DevotionPrismaBridge.log` is clean (bridge, DOM-ready, interop, JS).

Everything below assumes a rebuilt, deployed, smoke-clean baseline.

---

## Scope - the Section 16.6 staging sequence, made concrete

Source of truth (Section 16.6): editable UI source lives under
`native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/` (`index.html`,
`app.js`, view CSS). `scratch/DevotionPrismaDemo.html` is a review/share aid,
**not** canonical. A payload schema becomes a contract only when documented in
the bridge README or v3.

### 1. Accessibility hardening (largest chunk)

Files: `views/Devotion/index.html`, `app.js`, view CSS.

- **Live region for toasts.** Make `#pdv-toasts` an `aria-live="polite"`
  region so transient toasts announce their message text. Decorative symbol
  SVGs already carry `aria-hidden="true"` (good) - announce the human text, not
  the glyph.
- **Keyboard nav + focus states** for the panel tabs (patron / today / debug)
  and the two focusable overlays: startup modal (`#pdv-startup-modal`) and
  journal/Book-of-Days modal (`#pdv-journal-modal`). Visible focus rings;
  logical tab order.
- **Focus trap + guaranteed escape** on those overlays. Reuse the cold-view
  lesson: never move focus to a not-ready view; ESC must always release. The
  choice channel (`g_choiceFocusPending`) and panel channel
  (`g_panelFocusPending`) already defer focus to `OnDomReady` - keep new
  overlays on the same discipline.
- **Reduced motion** (`prefers-reduced-motion`): damp toast/instrument
  animation.
- **Color contrast + text scaling + tab semantics** across panel and toasts.

### 2. Payload contract cleanup

Mark every toast/panel payload field as **stable | prototype | deprecated** and
document it in the bridge README (that documentation is what makes it a contract
per Section 16.6).

- **Stable today** (Section 16.6): `favor`, `dawn`, `neglect`, `tier`,
  `rivalry`.
- **Still prototype** (in `app.js` `eventLanguage`, not yet in the stable
  contract): `shift`, `daedric`, `curse`, `substrate`, plus all full-panel
  payloads.
- The `app.js` `eventAliases` map (e.g. `piety|gain -> favor`,
  `tier_up -> tier`, `daedric_boon|price|lapse|residue -> daedric`) is the
  current normalization layer - document it as the alias contract.

### 3. Visual system pass

Symbols, spacing, tone colors (good/neutral/warning), responsive constraints,
and Skyrim overlay readability (toasts must read over busy game backgrounds).

### 4. Runtime integration expansion

Route more real devotional events through `PDV_PrismaBridge.SendOverlayJson()`
**without** increasing notification spam. Respect the Section 16.5 quiet bar:
routine per-act scoring must not become toast spam. `app.js` already de-dupes
via `recentToastKeys` - extend, do not bypass, that guard.

### 5. Smoke / tester workflow

Keep three views aligned: the local preview, `scratch/DevotionPrismaDemo.html`
(regenerate as a share aid), and the in-game Prisma smoke.

---

## Coordination with handoff A2 (Daedric surfacing)

A2 surfaces Daedric / Prince beats as toasts, and the `daedric` toast payload is
currently in the **prototype** set (step 2 above). Promote and document the
`daedric` toast shape here so A2's surfacing rides a stable contract rather than
a prototype one. If A2 dispatches first, treat its `daedric` payload usage as the
de facto shape to stabilize.

---

## Out of scope (deferred, do not build here)

- Promoting the full panel to a default player-facing opener - it stays
  MCM/debug-reachable until a later player-surface pass (Section 16.5/16.6).
- A player-facing MCM pass (MCM stays config/debug/opening support).
- Splitting Prisma into a separate repo - only when at least two of the
  Section 16.6 triggers hold.
- Any new NPC dialogue or voice (V2, Section 21.3).

---

## Proof boundary

- **Machine:** xmake builds clean; the view loads in the local preview with no
  console errors; README payload table updated.
- **Route:** `SendOverlayJson()` markers present in `DevotionPrismaBridge.log`
  for the routed events.
- **Manual (play-gated - this is the gate):** in-game Prisma smoke per Sections
  16.5 and 25.4 - panel opens patron/today/debug with no bridge or JS errors; a
  real active-patron gain raises a transient favor toast without focusing the
  panel; `ProcessDawn()` raises a dawn toast; no spam in normal play; ESC always
  escapes; `DevotionPrismaBridge.log` clean. A missing toast with otherwise
  correct piety math is a Prisma smoke failure, not a scoring failure.

---

## One-line tracking summary

Road-to-1.0 front "UI live" (Content-Feel Beta gate). Native/xmake, parallel to
Queue A/B. Not on the build-debt burndown. Sibling of the still-unqueued
Experience Mode build front.
