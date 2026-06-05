# Prisma glyph SVG data — substrate symbol marks

**Glyph art by the design pass (Claude).** Drop-in `symbolSpecs` entries for the six substrate symbol
keys emitted by the substrate event + instruments. Same rendering contract as `PrismaGlyph_Tier0_SVGData.md`
(viewBox `0 0 48 48`, `currentColor` stroke, no fill, `symbol-thin` for accents). Verified legible at 24px
(toast size) and 48px — see `scratch/prisma-art/glyphs.png`.

These close the Tier-3 concept-mark gap for the substrate races (lunar/hist/ancestor/branch + `malacath`,
`sect`), which render `journal` today.

```js
// add to symbolSpecs in app.js
lunar: [
  ["path", { d: "M30 10 a14 14 0 1 0 0 28 a10 14 0 1 1 0 -28 Z" }],
  ["circle", { cx: "19", cy: "24", r: "4", class: "symbol-thin" }],
],
hist: [
  ["path", { d: "M24 40 V22" }],
  ["path", { d: "M24 40 C18 40 13 38 11 34", class: "symbol-thin" }],
  ["path", { d: "M24 40 C30 40 35 38 37 34", class: "symbol-thin" }],
  ["path", { d: "M14 22 A10 10 0 0 1 34 22" }],
  ["path", { d: "M17 26 A7 7 0 0 1 31 26", class: "symbol-thin" }],
  ["circle", { cx: "24", cy: "14", r: "2.5" }],
],
ancestor: [
  ["path", { d: "M14 16 Q24 8 34 16 Q34 34 24 40 Q14 34 14 16 Z" }],
  ["circle", { cx: "19", cy: "22", r: "1.8" }],
  ["circle", { cx: "29", cy: "22", r: "1.8" }],
  ["path", { d: "M24 26 V32", class: "symbol-thin" }],
  ["path", { d: "M18 14 Q24 11 30 14", class: "symbol-thin" }],
],
malacath: [
  ["path", { d: "M16 38 C10 28 14 18 24 16" }],
  ["path", { d: "M24 16 L24 8 M16 10 H32 V14 H16 Z" }],
  ["path", { d: "M24 16 V30", class: "symbol-thin" }],
],
sect: [
  ["path", { d: "M12 36 C20 30 30 18 36 12" }],
  ["path", { d: "M36 36 C28 30 18 18 12 12" }],
  ["circle", { cx: "24", cy: "24", r: "2.4" }],
],
branch: [
  ["path", { d: "M10 34 C20 30 30 24 38 12" }],
  ["path", { d: "M22 25 q8 -10 14 -7 q-5 9 -14 7 Z", class: "symbol-thin" }],
  ["path", { d: "M16 30 q4 5 8 0", class: "symbol-thin" }],
],
```

```js
// gallerySymbols (?demo) entries
["lunar", "Lunar"], ["hist", "Hist"], ["ancestor", "Ancestor"],
["malacath", "Malacath"], ["sect", "Sect"], ["branch", "Branch"],
```

**Notes**
- `malacath` doubles as the Orc instrument mark **and** the Tier-1 Malacath Prince glyph (reuse, per
  `PrismaGlyph_DesignHandoff.md`). `hircine` and the other 15 Prince glyphs are a separate (next) batch.
- The substrate event (`SendPrismaSubstrateToast`) emits: `lunar`, `hist`, `ancestor`, `malacath` (Orc),
  `sect` (Redguard). All now resolve to a real mark.
