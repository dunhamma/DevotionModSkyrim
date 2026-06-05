# Prisma glyph SVG data — full roster (Princes, cultural pantheons, concept marks)

**Glyph art by the design pass (Claude).** Drop-in `symbolSpecs` for the 49-glyph roster. Glyphs marked
**(refined)** use the lore-grounded second pass (`scratch/prisma-art/batch6_refined.png`); the rest are the
first pass (`batch{1-5}_*.png`). Same contract as the other glyph docs (viewBox `0 0 48 48`, `currentColor`,
`symbol-thin` accents). See `PrismaGlyphRoster_RefinementFlags.md` for the lore basis of each refinement.

## Tier 1 — Daedric Princes

```js
  "azura": [
    ["path", { d: "M24 6 L27 18 L39 14 L30 23 L42 28 L29 28 L33 40 L24 31 L15 40 L19 28 L6 28 L18 23 L9 14 L21 18 Z" }],
    ["path", { d: "M10 34 A14 14 0 0 0 38 34", class: "symbol-thin" }],
  ],
  "boethiah": [  // (refined)
    ["path", { d: "M24 42 V12" }],
    ["path", { d: "M20 16 L24 10 L28 16" }],
    ["path", { d: "M24 38 C16 36 16 30 24 28 C32 26 32 20 24 18 C18 16 20 12 26 12", class: "symbol-thin" }],
    ["circle", { cx: "26", cy: "12", r: "1.3" }],
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
  "molag-bal": [  // (refined)
    ["path", { d: "M24 40 V21" }],
    ["circle", { cx: "24", cy: "15", r: "6" }],
    ["path", { d: "M30.0 15.0 L33.0 15.0" }],
    ["path", { d: "M28.2 19.2 L30.4 21.4" }],
    ["path", { d: "M24.0 21.0 L24.0 24.0" }],
    ["path", { d: "M19.8 19.2 L17.6 21.4" }],
    ["path", { d: "M18.0 15.0 L15.0 15.0" }],
    ["path", { d: "M19.8 10.8 L17.6 8.6" }],
    ["path", { d: "M24.0 9.0 L24.0 6.0" }],
    ["path", { d: "M28.2 10.8 L30.4 8.6" }],
    ["path", { d: "M19 31 a5 5 0 1 0 10 0 a5 5 0 1 0 -10 0", class: "symbol-thin" }],
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
  "mehrunes-dagon": [  // (refined)
    ["path", { d: "M24 15 C26 25 26 33 24 43 C22 33 22 25 24 15 Z" }],
    ["path", { d: "M12 15 C18 18 19 12 24 15 C29 12 30 18 36 15" }],
    ["path", { d: "M24 15 V8" }],
    ["circle", { cx: "24", cy: "6", r: "2.4" }],
    ["path", { d: "M18 19 L21 22 M30 19 L27 22", class: "symbol-thin" }],
  ],
  "sheogorath": [
    ["path", { d: "M24 8 C14 8 12 18 12 26 C12 36 18 42 24 42 Z" }],
    ["path", { d: "M24 8 C34 8 36 18 36 26 C36 36 30 42 24 42", class: "symbol-thin" }],
    ["circle", { cx: "18", cy: "22", r: "1.6" }],
    ["path", { d: "M28 20 L34 22 L28 24", class: "symbol-thin" }],
  ],
  "namira": [  // (refined)
    ["circle", { cx: "24", cy: "22", r: "11" }],
    ["path", { d: "M24 33 C18 38 18 42 24 44 C30 42 30 38 24 33" }],
    ["path", { d: "M21 38 L17 40 M27 38 L31 40 M22 41 L19 44 M26 41 L29 44", class: "symbol-thin" }],
    ["circle", { cx: "24", cy: "22", r: "4", class: "symbol-thin" }],
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
  "vaermina": [  // (refined)
    ["path", { d: "M16 22 C16 13 32 13 32 22 C32 27 30 30 28 32 V37 H20 V32 C18 30 16 27 16 22 Z" }],
    ["circle", { cx: "20", cy: "23", r: "2.2" }],
    ["circle", { cx: "28", cy: "23", r: "2.2" }],
    ["path", { d: "M24 27 L22 31 H26 Z", class: "symbol-thin" }],
    ["path", { d: "M24 8 C28 8 28 12 24 12 C21 12 22 15 24 15", class: "symbol-thin" }],
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
  "riddle-thar": [  // (refined)
    ["path", { d: "M18 14 A11 11 0 1 0 18 34 A8 11 0 1 1 18 14 Z" }],
    ["path", { d: "M30 14 A11 11 0 1 1 30 34 A8 11 0 1 0 30 14 Z" }],
    ["path", { d: "M22 24 Q24 20 26 24", class: "symbol-thin" }],
  ],
  "khenarthi": [  // (refined)
    ["path", { d: "M10 30 C18 26 22 26 24 22 C26 26 30 26 38 30" }],
    ["path", { d: "M24 22 V10" }],
    ["path", { d: "M21 14 L24 10 L27 14" }],
    ["path", { d: "M14 36 Q24 32 34 36", class: "symbol-thin" }],
  ],
  "alkosh": [  // (refined)
    ["path", { d: "M10 30 C10 18 18 14 26 16 C30 12 36 12 40 14 C36 16 36 20 38 22 C40 28 34 34 26 32" }],
    ["circle", { cx: "30", cy: "20", r: "1.5" }],
    ["path", { d: "M20 24 Q26 28 32 26", class: "symbol-thin" }],
    ["path", { d: "M14 30 L11 34 M18 31 L16 36", class: "symbol-thin" }],
  ],
  "rajhin": [  // (refined)
    ["path", { d: "M24 30 C18 30 16 24 20 22 C18 18 22 16 24 19 C26 16 30 18 28 22 C32 24 30 30 24 30 Z" }],
    ["circle", { cx: "16", cy: "18", r: "2.6" }],
    ["circle", { cx: "22", cy: "13", r: "2.6" }],
    ["circle", { cx: "30", cy: "13", r: "2.6" }],
    ["circle", { cx: "34", cy: "18", r: "2.6" }],
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
  "shor": [  // (refined)
    ["path", { d: "M24 40 C8 28 11 14 18 12 C22 11 24 14 24 17 C24 14 26 11 30 12 C37 14 40 28 24 40 Z" }],
    ["path", { d: "M18 22 L24 30 L30 22", class: "symbol-thin" }],
  ],
  "tsun": [  // (refined)
    ["path", { d: "M24 9 V41" }],
    ["path", { d: "M24 13 L12 16 L16 24 L24 20 Z" }],
    ["path", { d: "M24 13 L36 16 L32 24 L24 20 Z" }],
  ],
  "stuhn": [  // (refined)
    ["path", { d: "M24 8 L37 13 V24 C37 32 31 38 24 41 C17 38 11 32 11 24 V13 Z" }],
    ["circle", { cx: "21", cy: "22", r: "3", class: "symbol-thin" }],
    ["path", { d: "M23 24 L30 31 M27 31 H30 V28", class: "symbol-thin" }],
  ],
  "magnus": [
    ["circle", { cx: "24", cy: "22", r: "7" }],
    ["path", { d: "M24 6 V11 M24 33 V38 M8 22 H13 M35 22 H40 M13 11 L16 14 M35 11 L32 14" }],
    ["path", { d: "M18 40 L24 28 L30 40", class: "symbol-thin" }],
  ],
  "trinimac": [  // (refined)
    ["path", { d: "M24 18 V42" }],
    ["path", { d: "M19 24 L24 18 L29 24" }],
    ["circle", { cx: "24", cy: "12", r: "5" }],
    ["path", { d: "M29.0 12.0 L32.0 12.0", class: "symbol-thin" }],
    ["path", { d: "M27.5 15.5 L29.7 17.7", class: "symbol-thin" }],
    ["path", { d: "M24.0 17.0 L24.0 20.0", class: "symbol-thin" }],
    ["path", { d: "M20.5 15.5 L18.3 17.7", class: "symbol-thin" }],
    ["path", { d: "M19.0 12.0 L16.0 12.0", class: "symbol-thin" }],
    ["path", { d: "M20.5 8.5 L18.3 6.3", class: "symbol-thin" }],
    ["path", { d: "M24.0 7.0 L24.0 4.0", class: "symbol-thin" }],
    ["path", { d: "M27.5 8.5 L29.7 6.3", class: "symbol-thin" }],
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
  "satakal": [  // (refined)
    ["path", { d: "M27 11 A13.5 13.5 0 1 0 22 11" }],
    ["path", { d: "M22 11 L17 8 L20 11 L17 14 Z" }],
    ["path", { d: "M27 11 L31 10", class: "symbol-thin" }],
    ["circle", { cx: "19.5", cy: "11", r: "0.8" }],
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
  "leki": [  // (refined)
    ["path", { d: "M24 6 V40" }],
    ["path", { d: "M19 12 H29" }],
    ["path", { d: "M14 22 C22 18 26 26 34 22", class: "symbol-thin" }],
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
  "forebear": [  // (refined)
    ["circle", { cx: "24", cy: "20", r: "6" }],
    ["path", { d: "M30.0 20.0 L33.0 20.0", class: "symbol-thin" }],
    ["path", { d: "M27.7 24.7 L29.6 27.0", class: "symbol-thin" }],
    ["path", { d: "M22.7 25.8 L22.0 28.8", class: "symbol-thin" }],
    ["path", { d: "M18.6 22.6 L15.9 23.9", class: "symbol-thin" }],
    ["path", { d: "M18.6 17.4 L15.9 16.1", class: "symbol-thin" }],
    ["path", { d: "M22.7 14.2 L22.0 11.2", class: "symbol-thin" }],
    ["path", { d: "M27.7 15.3 L29.6 13.0", class: "symbol-thin" }],
    ["path", { d: "M8 34 C14 30 18 34 24 31 C30 34 34 30 40 34" }],
  ],
  "ashabah": [  // (refined)
    ["path", { d: "M24 6 V30" }],
    ["path", { d: "M19 11 H29", class: "symbol-thin" }],
    ["path", { d: "M24 30 L21 36 H27 Z" }],
    ["path", { d: "M12 20 C16 26 32 26 36 20 C34 30 14 30 12 20 Z", class: "symbol-thin" }],
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
  "broad": [  // (refined)
    ["path", { d: "M13 27 C15 36 21 39 24 39 C27 39 33 36 35 27" }],
    ["path", { d: "M13 27 L10 22 M35 27 L38 22", class: "symbol-thin" }],
    ["circle", { cx: "18", cy: "16", r: "1.7" }],
    ["circle", { cx: "24", cy: "13", r: "1.7" }],
    ["circle", { cx: "30", cy: "16", r: "1.7" }],
    ["path", { d: "M18 19 V23 M24 16 V22 M30 19 V23", class: "symbol-thin" }],
  ],
  "curse-vampire": [  // (refined)
    ["path", { d: "M33 9 A15 15 0 1 0 33 39 A12 15 0 1 1 33 9 Z" }],
    ["path", { d: "M21 23 L23 29 L25 23 Z" }],
    ["path", { d: "M27 23 L29 29 L31 23 Z" }],
    ["circle", { cx: "26", cy: "33", r: "1.4", class: "symbol-thin" }],
  ],
```

## gallerySymbols (?demo) entries

```js
  ["azura",""], ["boethiah",""], ["mephala",""], ["malacath",""], ["meridia",""], ["hircine",""], ["molag-bal",""], ["nocturnal",""], ["hermaeus-mora",""], ["mehrunes-dagon",""], ["sheogorath",""], ["namira",""], ["sanguine",""], ["clavicus-vile",""], ["peryite",""], ["vaermina",""], ["jode",""], ["jone",""], ["riddle-thar",""], ["khenarthi",""], ["alkosh",""], ["rajhin",""], ["sithis",""], ["sep",""], ["shor",""], ["tsun",""], ["stuhn",""], ["magnus",""], ["trinimac",""], ["phynaster",""], ["syrabane",""], ["xarxes",""], ["satakal",""], ["ruptga",""], ["tu-whacca",""], ["tava",""], ["leki",""], ["onsi",""], ["hoon-ding",""], ["void",""], ["stronghold",""], ["crown",""], ["forebear",""], ["ashabah",""], ["concordat",""], ["pact",""], ["stigma",""], ["broad",""], ["curse-vampire",""]
```