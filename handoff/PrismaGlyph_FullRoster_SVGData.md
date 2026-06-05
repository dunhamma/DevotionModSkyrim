# Prisma glyph SVG data — full roster (Princes, cultural pantheons, concept marks)

**Glyph art by the design pass (Claude).** Drop-in `symbolSpecs` entries for the 49 glyphs authored this
pass, grouped by batch. Same contract as the other glyph docs (viewBox `0 0 48 48`, `currentColor`,
`symbol-thin` accents). Rendered contact sheets: `scratch/prisma-art/batch{1-5}_*.png`.

See `PDV_PrismaGlyphRoster_RefinementFlags.md` for the marks I flagged for a second pass.

## Tier 1 — Daedric Princes

```js
  "azura": [
    ["path", { d: "M24 6 L27 18 L39 14 L30 23 L42 28 L29 28 L33 40 L24 31 L15 40 L19 28 L6 28 L18 23 L9 14 L21 18 Z" }],
    ["path", { d: "M10 34 A14 14 0 0 0 38 34", class: "symbol-thin" }],
  ],
  "boethiah": [
    ["path", { d: "M24 8 V40" }],
    ["path", { d: "M20 12 L24 8 L28 12" }],
    ["path", { d: "M24 14 C34 16 14 24 24 30 C34 34 16 38 24 40", class: "symbol-thin" }],
  ],
  "mephala": [
    ["path", { d: "M24 8 V40 M10 16 L38 32 M38 16 L10 32 M8 24 H40" }],
    ["path", { d: "M24 14 A10 10 0 0 1 34 24 A10 10 0 0 1 24 34 A10 10 0 0 1 14 24 A10 10 0 0 1 24 14", class: "symbol-thin" }],
  ],
  "malacath": [
    ["path", { d: "M16 38 C10 28 14 18 24 16" }],
    ["path", { d: "M24 16 L24 8 M16 10 H32 V14 H16 Z" }],
    ["path", { d: "M24 16 V30", class: "symbol-thin" }],
  ],
  "meridia": [
    ["circle", { cx: "24", cy: "18", r: "6" }],
    ["path", { d: "M24 4 V9 M10 18 H15 M33 18 H38 M14 8 L17 11 M34 8 L31 11" }],
    ["path", { d: "M16 26 L24 24 L32 26 L28 42 H20 Z", class: "symbol-thin" }],
  ],
  "hircine": [
    ["path", { d: "M24 40 V22" }],
    ["path", { d: "M24 24 C16 22 12 14 12 8 C16 12 18 10 20 14 C20 8 22 10 24 14 C26 10 28 8 28 14 C30 10 32 12 36 8 C36 14 32 22 24 24" }],
  ],
  "molag-bal": [
    ["circle", { cx: "24", cy: "16", r: "7" }],
    ["path", { d: "M24 4 V9 M24 23 V40 M16 12 L11 8 M32 12 L37 8 M16 20 L11 24 M32 20 L37 24" }],
    ["path", { d: "M20 32 A4 4 0 0 0 28 32 A4 4 0 0 0 20 32", class: "symbol-thin" }],
  ],
  "nocturnal": [
    ["path", { d: "M14 10 A16 16 0 1 0 34 34 A12 12 0 1 1 14 10 Z" }],
    ["path", { d: "M30 16 L40 12 L34 20", class: "symbol-thin" }],
  ],
  "hermaeus-mora": [
    ["path", { d: "M8 24 C14 16 34 16 40 24 C34 32 14 32 8 24 Z" }],
    ["circle", { cx: "24", cy: "24", r: "5" }],
    ["circle", { cx: "24", cy: "24", r: "1.6" }],
    ["path", { d: "M8 24 C4 20 6 14 4 10 M40 24 C44 20 42 14 44 10 M8 24 C4 28 6 34 4 38 M40 24 C44 28 42 34 44 38", class: "symbol-thin" }],
  ],
  "mehrunes-dagon": [
    ["path", { d: "M24 24 L24 6 M24 24 L40 14 M24 24 L40 34 M24 24 L8 14 M24 24 L8 34 M24 24 L24 42" }],
    ["circle", { cx: "24", cy: "24", r: "3" }],
  ],
  "sheogorath": [
    ["path", { d: "M24 8 C14 8 12 18 12 26 C12 36 18 42 24 42 Z" }],
    ["path", { d: "M24 8 C34 8 36 18 36 26 C36 36 30 42 24 42", class: "symbol-thin" }],
    ["circle", { cx: "18", cy: "22", r: "1.6" }],
    ["path", { d: "M28 20 L34 22 L28 24", class: "symbol-thin" }],
  ],
  "namira": [
    ["circle", { cx: "24", cy: "24", r: "13" }],
    ["path", { d: "M24 11 V6 M24 37 V42 M11 24 H6 M37 24 H42 M15 15 L11 11 M33 15 L37 11 M15 33 L11 37 M33 33 L37 37", class: "symbol-thin" }],
    ["circle", { cx: "24", cy: "24", r: "4" }],
  ],
  "sanguine": [
    ["path", { d: "M16 14 H32 L29 28 A5 5 0 0 1 19 28 Z" }],
    ["path", { d: "M24 28 V38 M18 40 H30" }],
    ["path", { d: "M24 8 C20 10 20 16 24 18 C28 16 28 10 24 8 Z", class: "symbol-thin" }],
  ],
  "clavicus-vile": [
    ["path", { d: "M14 22 C14 14 34 14 34 22 C34 34 28 40 24 40 C20 40 14 34 14 22 Z" }],
    ["path", { d: "M14 22 C8 18 8 10 12 8 C14 14 16 16 18 18 M34 22 C40 18 40 10 36 8 C34 14 32 16 30 18" }],
    ["circle", { cx: "20", cy: "24", r: "1.5" }],
    ["circle", { cx: "28", cy: "24", r: "1.5" }],
  ],
  "peryite": [
    ["path", { d: "M24 24 m0 -3 a3 3 0 1 1 0 6 a7 7 0 1 1 0 -12 a11 11 0 1 1 0 20 a15 15 0 1 1 0 -28" }],
    ["circle", { cx: "36", cy: "10", r: "1.6", class: "symbol-thin" }],
  ],
  "vaermina": [
    ["path", { d: "M24 22 m0 -2 a2 2 0 1 1 0 4 a5 5 0 1 1 0 -8 a8 8 0 1 1 0 14" }],
    ["path", { d: "M14 36 A14 14 0 0 1 34 36", class: "symbol-thin" }],
    ["path", { d: "M18 40 L20 36 M24 41 V37 M30 40 L28 36", class: "symbol-thin" }],
  ],
```

## Tier 2 — Khajiit lunar pantheon + Argonian

```js
  "jode": [
    ["circle", { cx: "24", cy: "24", r: "14" }],
    ["path", { d: "M24 10 A14 14 0 0 1 24 38", class: "symbol-thin" }],
  ],
  "jone": [
    ["path", { d: "M30 10 A14 14 0 1 0 30 38 A11 14 0 1 1 30 10 Z" }],
  ],
  "riddle-thar": [
    ["path", { d: "M16 16 A10 10 0 1 0 16 32 A8 10 0 1 1 16 16 Z" }],
    ["path", { d: "M32 16 A10 10 0 1 1 32 32 A8 10 0 1 0 32 16 Z" }],
    ["path", { d: "M19 24 H29", class: "symbol-thin" }],
  ],
  "khenarthi": [
    ["path", { d: "M24 12 C16 18 12 26 10 36 C18 30 22 28 24 28 C26 28 30 30 38 36 C36 26 32 18 24 12 Z" }],
    ["path", { d: "M24 12 V28", class: "symbol-thin" }],
  ],
  "alkosh": [
    ["path", { d: "M10 28 C12 16 22 12 24 12 C26 12 36 16 38 28" }],
    ["path", { d: "M14 24 L10 20 M34 24 L38 20" }],
    ["circle", { cx: "19", cy: "24", r: "1.6" }],
    ["circle", { cx: "29", cy: "24", r: "1.6" }],
    ["path", { d: "M16 32 Q24 38 32 32", class: "symbol-thin" }],
    ["path", { d: "M24 28 L21 33 H27 Z", class: "symbol-thin" }],
  ],
  "rajhin": [
    ["path", { d: "M18 16 L14 9 M30 16 L34 9" }],
    ["path", { d: "M16 18 C12 24 12 32 18 36 C22 39 26 39 30 36 C36 32 36 24 32 18 C28 14 20 14 16 18 Z" }],
    ["circle", { cx: "20", cy: "25", r: "1.5" }],
    ["circle", { cx: "28", cy: "25", r: "1.5" }],
    ["path", { d: "M22 31 Q24 33 26 31", class: "symbol-thin" }],
  ],
  "sithis": [
    ["circle", { cx: "24", cy: "24", r: "14", class: "symbol-thin" }],
    ["path", { d: "M24 12 C16 18 16 30 24 36 C30 31 30 17 24 12 Z" }],
  ],
  "sep": [
    ["path", { d: "M14 14 C26 12 30 20 24 24 C18 28 22 36 34 34" }],
    ["path", { d: "M14 14 L11 11 M14 14 L11 17", class: "symbol-thin" }],
    ["circle", { cx: "33", cy: "34", r: "1.4" }],
  ],
```

## Tier 2 — Nord/Imperial + Altmer

```js
  "shor": [
    ["path", { d: "M24 38 C8 28 10 14 18 12 C22 11 24 14 24 17 C24 14 26 11 30 12 C38 14 40 28 24 38 Z" }],
    ["path", { d: "M24 22 V30 M20 26 H28", class: "symbol-thin" }],
  ],
  "tsun": [
    ["path", { d: "M24 8 L38 14 V24 C38 32 32 38 24 41 C16 38 10 32 10 24 V14 Z" }],
    ["path", { d: "M16 16 L32 34 M32 16 L16 34", class: "symbol-thin" }],
  ],
  "stuhn": [
    ["path", { d: "M24 8 L38 14 V24 C38 32 32 38 24 41 C16 38 10 32 10 24 V14 Z" }],
    ["circle", { cx: "24", cy: "20", r: "4", class: "symbol-thin" }],
    ["path", { d: "M24 24 V32 M24 28 H29", class: "symbol-thin" }],
  ],
  "magnus": [
    ["circle", { cx: "24", cy: "22", r: "7" }],
    ["path", { d: "M24 6 V11 M24 33 V38 M8 22 H13 M35 22 H40 M13 11 L16 14 M35 11 L32 14" }],
    ["path", { d: "M18 40 L24 28 L30 40", class: "symbol-thin" }],
  ],
  "trinimac": [
    ["path", { d: "M24 8 L34 12 V22 C34 30 30 36 24 40 C18 36 14 30 14 22 V12 Z" }],
    ["path", { d: "M24 14 V32 M18 20 L24 14 L30 20", class: "symbol-thin" }],
    ["path", { d: "M19 26 H29", class: "symbol-thin" }],
  ],
  "phynaster": [
    ["path", { d: "M24 6 V42" }],
    ["path", { d: "M18 6 H30", class: "symbol-thin" }],
    ["path", { d: "M20 14 H28 M20 22 H28 M20 30 H28", class: "symbol-thin" }],
    ["path", { d: "M16 42 H32", class: "symbol-thin" }],
  ],
  "syrabane": [
    ["circle", { cx: "24", cy: "27", r: "11" }],
    ["path", { d: "M24 16 L20 8 H28 Z" }],
    ["circle", { cx: "24", cy: "27", r: "4", class: "symbol-thin" }],
  ],
  "xarxes": [
    ["path", { d: "M14 12 C12 12 12 16 14 16 H32 C30 16 30 12 32 12 C36 12 36 36 32 36 H14 C12 36 12 32 14 32" }],
    ["path", { d: "M30 10 L36 22", class: "symbol-thin" }],
    ["path", { d: "M18 22 H27 M18 27 H24", class: "symbol-thin" }],
  ],
```

## Tier 2 — Redguard / Yokudan

```js
  "satakal": [
    ["path", { d: "M24 10 A14 14 0 1 1 16 14" }],
    ["path", { d: "M16 14 L11 12 M16 14 L13 19", class: "symbol-thin" }],
    ["path", { d: "M24 10 A2 2 0 1 0 24 14 A2 2 0 1 0 24 10", class: "symbol-thin" }],
  ],
  "ruptga": [
    ["circle", { cx: "14", cy: "14", r: "1.8" }],
    ["circle", { cx: "34", cy: "12", r: "1.8" }],
    ["circle", { cx: "24", cy: "24", r: "1.8" }],
    ["circle", { cx: "16", cy: "34", r: "1.8" }],
    ["circle", { cx: "36", cy: "32", r: "1.8" }],
    ["path", { d: "M14 14 L24 24 L34 12 M24 24 L16 34 M24 24 L36 32", class: "symbol-thin" }],
  ],
  "tu-whacca": [
    ["path", { d: "M12 40 V20 A12 12 0 0 1 36 20 V40" }],
    ["path", { d: "M24 16 L26 21 L31 21 L27 24 L29 29 L24 26 L19 29 L21 24 L17 21 L22 21 Z", class: "symbol-thin" }],
  ],
  "tava": [
    ["path", { d: "M8 18 C16 26 20 26 24 22 C28 26 32 26 40 18 C34 28 28 32 24 40 C20 32 14 28 8 18 Z" }],
    ["circle", { cx: "24", cy: "21", r: "1.4" }],
  ],
  "leki": [
    ["path", { d: "M24 6 V34" }],
    ["path", { d: "M18 30 H30" }],
    ["path", { d: "M24 34 C20 38 28 40 24 44", class: "symbol-thin" }],
    ["path", { d: "M20 12 C28 12 28 18 24 18 C20 18 20 24 28 24", class: "symbol-thin" }],
  ],
  "onsi": [
    ["path", { d: "M14 40 C12 26 20 12 36 8 C34 12 34 14 36 16 C24 20 18 28 18 40 Z" }],
    ["path", { d: "M14 40 H22", class: "symbol-thin" }],
  ],
  "hoon-ding": [
    ["path", { d: "M12 12 L28 24 L12 36" }],
    ["path", { d: "M22 12 L38 24 L22 36" }],
  ],
```

## Tier 3 — concept marks

```js
  "void": [
    ["path", { d: "M24 10 A14 14 0 1 1 18 11", class: "symbol-thin" }],
    ["path", { d: "M24 18 A6 6 0 1 1 20 19" }],
    ["circle", { cx: "24", cy: "24", r: "1.4" }],
  ],
  "stronghold": [
    ["path", { d: "M12 40 V20 H16 V16 H20 V20 H24 V16 H28 V20 H32 V16 H36 V40 Z" }],
    ["path", { d: "M20 40 V30 H28 V40", class: "symbol-thin" }],
  ],
  "crown": [
    ["path", { d: "M10 34 L14 16 L20 26 L24 12 L28 26 L34 16 L38 34 Z" }],
    ["path", { d: "M10 34 H38", class: "symbol-thin" }],
    ["circle", { cx: "24", cy: "12", r: "1.6" }],
  ],
  "forebear": [
    ["path", { d: "M10 34 C10 24 16 22 18 30 C18 18 30 18 30 30 C32 22 38 24 38 34 Z" }],
    ["path", { d: "M24 30 C20 24 28 22 24 16 C28 22 28 28 24 30 Z", class: "symbol-thin" }],
  ],
  "ashabah": [
    ["path", { d: "M24 8 V30" }],
    ["path", { d: "M19 14 H29", class: "symbol-thin" }],
    ["path", { d: "M14 26 C14 38 34 38 34 26 C30 32 18 32 14 26 Z" }],
    ["path", { d: "M24 30 V38", class: "symbol-thin" }],
  ],
  "concordat": [
    ["path", { d: "M14 10 C12 10 12 14 14 14 V34 C12 34 12 38 14 38 H34 C36 38 36 34 34 34 V14 C36 14 36 10 34 10 Z" }],
    ["path", { d: "M16 12 L34 36", class: "symbol-thin" }],
    ["path", { d: "M19 20 H29", class: "symbol-thin" }],
  ],
  "pact": [
    ["path", { d: "M18 16 C30 16 30 26 18 26 C12 26 12 34 24 34 C36 34 36 26 30 26" }],
    ["path", { d: "M18 16 C12 16 12 24 24 24", class: "symbol-thin" }],
  ],
  "stigma": [
    ["circle", { cx: "24", cy: "24", r: "13" }],
    ["path", { d: "M24 16 L20 26 H28 L24 34" }],
    ["path", { d: "M24 11 V14 M24 34 V37", class: "symbol-thin" }],
  ],
  "broad": [
    ["circle", { cx: "24", cy: "24", r: "5" }],
    ["path", { d: "M32.0 24.0 L37.0 24.0", class: "symbol-thin" }],
    ["path", { d: "M30.9 28.0 L35.3 30.5", class: "symbol-thin" }],
    ["path", { d: "M28.0 30.9 L30.5 35.3", class: "symbol-thin" }],
    ["path", { d: "M24.0 32.0 L24.0 37.0", class: "symbol-thin" }],
    ["path", { d: "M20.0 30.9 L17.5 35.3", class: "symbol-thin" }],
    ["path", { d: "M17.1 28.0 L12.7 30.5", class: "symbol-thin" }],
    ["path", { d: "M16.0 24.0 L11.0 24.0", class: "symbol-thin" }],
    ["path", { d: "M17.1 20.0 L12.7 17.5", class: "symbol-thin" }],
    ["path", { d: "M20.0 17.1 L17.5 12.7", class: "symbol-thin" }],
    ["path", { d: "M24.0 16.0 L24.0 11.0", class: "symbol-thin" }],
    ["path", { d: "M28.0 17.1 L30.5 12.7", class: "symbol-thin" }],
    ["path", { d: "M30.9 20.0 L35.3 17.5", class: "symbol-thin" }],
  ],
  "curse-vampire": [
    ["path", { d: "M32 10 A15 15 0 1 0 32 38 A12 15 0 1 1 32 10 Z" }],
    ["path", { d: "M20 24 L22 30 L24 24 M26 24 L28 29 L30 24", class: "symbol-thin" }],
  ],
```

## gallerySymbols (?demo) entries

```js
  ["azura",""], ["boethiah",""], ["mephala",""], ["malacath",""], ["meridia",""], ["hircine",""], ["molag-bal",""], ["nocturnal",""], ["hermaeus-mora",""], ["mehrunes-dagon",""], ["sheogorath",""], ["namira",""], ["sanguine",""], ["clavicus-vile",""], ["peryite",""], ["vaermina",""], ["jode",""], ["jone",""], ["riddle-thar",""], ["khenarthi",""], ["alkosh",""], ["rajhin",""], ["sithis",""], ["sep",""], ["shor",""], ["tsun",""], ["stuhn",""], ["magnus",""], ["trinimac",""], ["phynaster",""], ["syrabane",""], ["xarxes",""], ["satakal",""], ["ruptga",""], ["tu-whacca",""], ["tava",""], ["leki",""], ["onsi",""], ["hoon-ding",""], ["void",""], ["stronghold",""], ["crown",""], ["forebear",""], ["ashabah",""], ["concordat",""], ["pact",""], ["stigma",""], ["broad",""], ["curse-vampire",""]
```