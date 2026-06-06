# Prisma Tier-0 glyph SVG data — yffre, zen, baan-dar

**Live gap:** these three symbol keys are emitted by Papyrus today (Bosmer patrons and
Khajiit Baan Dar focus) and fall back to the journal mark. Drop these entries into the
`symbolSpecs` object in `app.js` to close the gap.

**Rendering contract reminder:**
- ViewBox: `0 0 48 48`, ~6px padding, `currentColor` stroke, no fill
- Thin accent lines: `class: "symbol-thin"` (lighter weight, per CSS)
- Each `[tagName, attributes]` pair maps to `makeSvgElement(tagName, attributes)`

---

## `yffre` — Y'ffre, the Bosmer Spinner

*Motif: the eternal forest pattern — a stylised tree with roots and canopy as one
continuous cycle, reflecting Y'ffre as the first spirit to become a story and hold
the shape of the world.*

```js
yffre: [
  // Root spread
  ["path", { d: "M24 38 C18 38 12 34 11 28" }],
  ["path", { d: "M24 38 C30 38 36 34 37 28" }],
  // Trunk
  ["path", { d: "M24 38 V20" }],
  // Branching canopy — left and right arcs meeting at top
  ["path", { d: "M24 20 C16 20 10 16 10 10 C10 8 12 8 14 10 C16 12 18 14 24 14" }],
  ["path", { d: "M24 20 C32 20 38 16 38 10 C38 8 36 8 34 10 C32 12 30 14 24 14" }],
  // Crown knot — the continuous cycle point
  ["circle", { cx: "24", cy: "14", r: "3", class: "symbol-thin" }],
],
```

---

## `zen` — Z'en, Bosmer god of toil and the honest debt

*Motif: the scales of proportionate exchange — a balance beam with two hanging pans,
suggesting the moral economy of debt, return, and fair measure. Simple and deliberate;
Z'en's theology is economic, not ornate.*

```js
zen: [
  // Balance fulcrum and post
  ["path", { d: "M24 12 V32" }],
  ["path", { d: "M18 32 H30" }],
  // Beam
  ["path", { d: "M14 20 H34" }],
  // Left pan hanging
  ["path", { d: "M14 20 L12 28 H20 L18 20", class: "symbol-thin" }],
  // Right pan hanging
  ["path", { d: "M34 20 L32 28 H40 L38 20", class: "symbol-thin" }],
  // Top pivot mark
  ["circle", { cx: "24", cy: "12", r: "2" }],
],
```

*Note: the beam is level (balanced) by default — reflecting Z'en's principle that
the Exchange should be proportionate, not tipped. If you want to show the system under
tension, you could tilt the beam 4–5 degrees; leave it level for the default glyph.*

---

## `baan-dar` — Baan Dar, the Bandit God / trickster

*Motif: the mask with a hidden eye — a simple face-split between concealment and
revelation, suggesting the trickster's road and the reversal of expectation. One
half of the mask shows; the other is the negative space. The single central eye is
the knowing detail.*

```js
"baan-dar": [
  // Outer mask oval
  ["path", { d: "M16 14 C12 16 10 20 10 24 C10 34 16 38 24 38 C32 38 38 34 38 24 C38 20 36 16 32 14 Z" }],
  // Mask split — vertical dividing line
  ["path", { d: "M24 10 V38" }],
  // Left eye-socket (hidden side — just a hollow arc)
  ["path", { d: "M14 22 C14 20 16 19 18 20", class: "symbol-thin" }],
  // Right eye (seeing side — filled)
  ["circle", { cx: "30", cy: "22", r: "2.5" }],
  // Brow on the seeing side
  ["path", { d: "M27 18 C28 17 32 17 33 18", class: "symbol-thin" }],
  // Top of mask / cap
  ["path", { d: "M18 10 C20 8 28 8 30 10" }],
],
```

---

## Registration checklist

For each glyph above:
1. Add the key/array to `symbolSpecs` in `app.js`.
2. Add `[key, "Display Name"]` to `gallerySymbols` for `?demo` visibility:
   ```js
   ["yffre",    "Y'ffre"],
   ["zen",      "Z'en"],
   ["baan-dar", "Baan Dar"],
   ```
3. No alias needed — the Papyrus output names match these keys exactly.

---

## Visual QA notes

- `yffre`: the canopy arcs should read as a single living loop at small size (~20px).
  If they collapse, simplify to two shorter arcs without the root spread.
- `zen`: the pan paths use absolute coords — the right pan intentionally extends past
  the 42px padding boundary. Clip to 38 if it feels too wide.
- `baan-dar`: the mask-split at `M24 10 V38` bisects the oval exactly. At small size
  the split may disappear; add `stroke-width` override via a second class if needed,
  or replace with a path that has a small gap at the centre.

These are production-ready starting points, not final artwork — adjust curves and
proportions to match the family's visual weight.
