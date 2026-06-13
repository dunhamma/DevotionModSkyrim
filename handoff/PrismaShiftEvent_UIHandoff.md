# Prisma UI handoff — `shift` event type

**For:** a Claude design/code pass on `app.js`.
**Status:** Superseded by the live `app.js` implementation and
`native/DevotionPrismaBridge/README.md` stable payload notes. Keep this file as
handoff context only; do not paste it verbatim without checking the live UI.
**Context:** `PDV__ManagerQuest.psc` now emits `{"event":"shift",...}` overlay payloads
when a race's substrate or state-track mode changes. These are the non-deity piety modes:
Khajiit focus emphasis, Argonian Hist posture, Orc life-mode, Redguard sect, and Bosmer
path (on the rite-confirmed settle). This doc is the drop-in spec.

---

## 1. Payload shape

```json
{
  "mode": "toast",
  "toast": {
    "event":     "shift",
    "shiftMode": "<new state label — e.g. 'Khenarthi', 'Stronghold', 'Hist Silenced'>",
    "symbol":    "<prisma symbol key — see table below>",
    "context":   "<optional short phrase — may be empty>",
    "deity":     "<active patron name if any — may be absent>"
  }
}
```

### Symbol keys emitted and their glyph status

| shiftMode context | symbol emitted | glyph status |
|---|---|---|
| Khajiit focus: Khenarthi | `khenarthi` | Tier 2 — `journal` fallback |
| Khajiit focus: Azurah | `azurah` | Tier 1 Prince — `journal` fallback |
| Khajiit focus: Baan Dar | `baan-dar` | **Tier 0 — needed now** |
| Khajiit focus: Rajhin | `rajhin` | Tier 2 — `journal` fallback |
| Khajiit focus: Alkosh | `alkosh` | Tier 2 — `journal` fallback |
| Khajiit (no emphasis) | `lunar` | Tier 3 concept — `journal` fallback |
| Argonian Hist posture | `hist` | Tier 2 — `journal` fallback |
| Orc life-mode | `malacath` | Tier 1 Prince — `journal` fallback |
| Redguard sect | `journal` | no sect glyph yet |
| Bosmer path settle | `yffre` / `zen` / `baan-dar` | **Tier 0 — needed now** |

---

## 2. `normalizeToastPayload` additions

```js
// After the existing if(!normalized.rival) block:
if (!normalized.shiftMode) {
  normalized.shiftMode = text(payload.shiftMode || payload.mode || payload.state, "");
}
```

---

## 3. `eventAliases` additions

```js
path_shift:  "shift",
mode_change: "shift",
track_shift: "shift",
```

---

## 4. `eventLanguage.shift` block

```js
shift: {
  tone: () => "neutral",
  symbol: (payload) => text(payload.symbol, "journal"),
  title: (payload) => {
    const mode = displayName(payload.shiftMode, "");
    return mode ? `The path turns toward ${mode}` : "Your path shifts";
  },
  message: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const mode = displayName(payload.shiftMode, "");
    return mode
      ? `${mode} has begun to shape your practice.`
      : "Your practice has found a new shape.";
  },
  listTitle: (payload) => displayName(payload.shiftMode, "Path shift"),
  listText: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const mode = displayName(payload.shiftMode, "");
    return mode
      ? `${mode} is now the shape of your practice.`
      : "Your path has settled into a new mode.";
  },
},
```

---

## 5. Demo entries

```js
// In demoToasts:
shift_khajiit:  { event: "shift", shiftMode: "Khenarthi", symbol: "khenarthi" },
shift_argonian: { event: "shift", shiftMode: "Hist Strained", symbol: "hist" },
shift_orc:      { event: "shift", shiftMode: "Stronghold", symbol: "malacath" },
shift_redguard: { event: "shift", shiftMode: "Crown" },
shift_bosmer:   { event: "shift", shiftMode: "Old Contract", symbol: "yffre" },
```

Demo buttons (add alongside existing `[data-demo-toast]` buttons):

```html
<button type="button" data-demo-toast="shift_khajiit">Shift (Khajiit focus)</button>
<button type="button" data-demo-toast="shift_argonian">Shift (Argonian Hist)</button>
<button type="button" data-demo-toast="shift_orc">Shift (Orc life-mode)</button>
<button type="button" data-demo-toast="shift_redguard">Shift (Redguard sect)</button>
<button type="button" data-demo-toast="shift_bosmer">Shift (Bosmer path)</button>
```

---

## 6. What does NOT emit a `shift` today (and why)

- **Dunmer ancestor layer** — Dunmer's substrate accumulates piety rather than
  transitioning between named modes. No discrete shift to surface; Dunmer continuity
  is better addressed by the panel quasi-patron pass (Step 5 of the audit).
- **Imperial Concordat** — `ApplyConcordatPressure` adjusts a scalar, not a labelled
  state. Too granular for a shift event; surface via `driftLabel` in the panel instead.
- **Nord baseline** — transitions only at startup (already handled by the startup modal)
  and via debug commands. Not a runtime shift the player drives.
- **Bosmer path-offer / path-refuse** — those one-off literal toasts are
  intentionally kept as-is (the wording is already tuned and contextual).
