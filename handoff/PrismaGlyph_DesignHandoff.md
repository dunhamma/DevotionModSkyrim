# Prisma UI Glyph Design Handoff

**For:** a Claude design pass on the Devotion Prisma UI symbol set.
**Owner file to edit:** `D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js`
(the `symbolSpecs`, `symbolAliases`, and `gallerySymbols` tables near the top).
**Do not touch** `index.html` / `styles.css` unless a glyph needs a new CSS hook.
**Source of truth for *which* names exist:** the Papyrus side emits symbol names from
`GetPrismaSymbolForDeity()` in `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`.
Every name Papyrus can emit must resolve to a real glyph or it silently falls back to `journal`.

---

## 1. The rendering contract (match this exactly)

Each glyph is an array of `[tagName, attributes]` SVG primitives registered under a
lowercase, hyphenated key in `symbolSpecs`. They are injected into a wrapper
`<svg class="symbol" viewBox="0 0 48 48">` by `createSymbol()`.

Authoring rules, derived from the existing glyphs:

- **Canvas:** `viewBox="0 0 48 48"`. Design on a 48×48 grid; keep ~6px padding.
- **Line-art, not fills.** Strokes inherit `currentColor`; weight/линecap come from CSS.
  Use `path`, `circle`, `line`. Avoid `fill` unless the shape is meant to be solid.
- **Thin accents** use `class: "symbol-thin"` (see `julianos`, `akatosh`, `dibella`).
  Use it for inner detail lines so they read at toast size (~20px) and panel size.
- **Silhouette first.** Glyphs render as small as a 20px toast mark. Aim for one
  strong, recognizable silhouette + at most one or two accent strokes.
- **Keys are lowercase-hyphenated** and must match the Papyrus output names exactly
  (e.g. `auri-el`, `baan-dar`, `molag-bal`, `hermaeus-mora`).

### Registration checklist per new glyph
1. Add the `key: [...]` entry to `symbolSpecs`.
2. If the in-game name differs from the key, add an entry to `symbolAliases`
   (existing examples: `auriel → auri-el`, `kynareth → kyne`).
3. Optionally add `[key, "Display Name"]` to `gallerySymbols` so it shows in the
   `?demo` symbol gallery for QA.

### Already implemented — **reuse, do not remake**
`journal`, `dawn`, `kyne`, `talos`, `auri-el`, `akatosh`, `arkay`, `dibella`,
`julianos`, `mara`, `stendarr`, `zenithar`.

---

## 2. Glyphs needed, by priority

### Tier 0 — emittable *today*, currently falling back to `journal` (ship first)
These three deity scripts already exist and Papyrus already emits these names, so
they are the only glyphs that fix a *live* gap right now (Bosmer patrons):

| key        | deity     | note |
|------------|-----------|------|
| `yffre`    | Y'ffre    | Bosmer "Spinner"/forest-law god. Wood/antler/oak motif. |
| `zen`      | Z'en      | Bosmer/Old-Elf god of debt & toil. Scales / ledger / yoke motif. |
| `baan-dar` | Baan Dar  | The Bandit God / trickster. Mask / crossed-blades / paradox motif. |

### Tier 1 — Daedric Princes (16 Skyrim-present, roster-locked)
No glyphs exist for any Prince today. These are needed for the Daedric surfacing
work (see the audit doc). Suggested motifs in parentheses.

`azura` (star/dusk-dawn), `boethiah` (blade/serpent), `mephala` (web/spider),
`malacath` (broken tower/tusk), `meridia` (radiant beacon), `hircine` (antler/hunt),
`molag-bal` (mace/chains), `nocturnal` (raven/crescent), `hermaeus-mora`
(eye/tentacle/tome), `mehrunes-dagon` (razor/four-arms), `sheogorath` (split
mask), `namira` (ringed decay), `sanguine` (rose/goblet), `clavicus-vile`
(masque/horns), `peryite` (coiled dragon/sickness), `vaermina` (skull/dream-spiral).

> Note: `hircine` and `malacath` double as the Orc life-mode / werewolf-curse marks
> (see Tier 3), so prioritize them within this tier.

### Tier 2 — locked Aedric / cultural-pantheon roster without glyphs
From `references/authoring/PDV_DeityCoverageMatrix.json` → `lockedWorshipObjects`,
minus the 12 already done. Group by culture so the visual language stays coherent:

- **Nord/Imperial:** `shor`, `tsun`, `stuhn`, `magnus`, `trinimac`
- **Altmer:** `phynaster`, `syrabane`, `xarxes` (`auri-el` exists)
- **Khajiit:** `rajhin`, `alkosh`, `khenarthi`, `riddle-thar`, `jone`, `jode`
  (`baan-dar` is Tier 0)
- **Redguard/Yokudan:** `satakal`, `ruptga`, `tu-whacca`, `tava`, `leki`, `onsi`,
  `hoon-ding`
- **Argonian/abstract:** `hist`, `sithis`, `sep`

(`kynareth` already aliases to `kyne`; keep that alias.)

### Tier 3 — concept marks for **non-deity** piety modes
These races earn devotion through a *state/substrate* rather than a single patron.
They need a "mode identity" mark so toasts and the panel can treat a substrate like
a quasi-patron (see audit recommendation). Some can reuse a Prince/Aedra glyph.

| concept key      | used by | reuse or new |
|------------------|---------|--------------|
| `ancestor`       | Dunmer ancestor substrate | new (urn / ash / mask) |
| `hist`           | Argonian Hist substrate | Tier 2 covers it |
| `void`           | Argonian Void / Sithis | reuse `sithis` or new |
| `lunar`          | Khajiit Lunar Lattice / focus | new (two moons) |
| `stronghold`     | Orc Stronghold life-mode | reuse `malacath` |
| `crown`          | Redguard Crown sect | new (Yokudan crown) |
| `forebear`       | Redguard Forebear sect | new |
| `ashabah`        | Redguard Ash'abah sect | new (shrouded/funerary) |
| `concordat`      | Imperial Concordat/Talos pressure | new (broken Talos / scroll) |
| `pact`           | Bosmer Green Pact / Old Contract | new (bound branch) |
| `exchange`       | Bosmer Exchange path | reuse `zen` |
| `curse-vampire`  | vampire curse state | new (fanged moon) |
| `curse-werewolf` | werewolf curse state | reuse `hircine` or new |
| `stigma`         | Daedric stigma pressure | new (brand/mark) |
| `broad`          | broad-pantheon worship | new (open hands / many-rays) |

---

## 3. Coordination notes (two-sided changes)

- A new **deity** glyph (Tiers 0–2) only needs the `app.js` entry **if** Papyrus
  already emits the name. Tier 0 is live. For Tiers 1–2, the matching
  `GetPrismaSymbolForDeity()` branches do **not** exist yet — those will be added on
  the Papyrus side as each deity/Prince is wired for scoring. The design glyphs can
  be authored ahead of that; they just won't appear until Papyrus emits the name.
- The **Tier 3 concept marks** also imply new event templating in `eventLanguage`
  (app.js) if we add `shift` / `daedric` / `curse` event types — see the audit doc's
  "extend the event vocab" recommendation. Flag those as a paired UI+Papyrus task.
- Keep the stroke language consistent with the existing 12 so the set reads as one
  family. The current set is geometric and reverent; match that register.
