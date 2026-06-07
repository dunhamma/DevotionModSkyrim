# PDV Prisma Glyph Branch Handoff

**Created:** 2026-06-07
**Branch:** `prisma-glyphs-phase2-deities`
**Scope:** JS/SVG art only. The Papyrus `GetPrismaSymbolForDeity` mappings already
landed on `main`; this branch only adds the matching glyphs so the keys resolve to
real icons instead of the `journal` fallback.

## Why this exists

The Phase 2 reconcile mapped every scored deity to a Prisma symbol key in
`PDV__ManagerQuest.psc::GetPrismaSymbolForDeity`. 17 of those keys do not yet have
an SVG in `symbolSpecs`, so they currently render the generic `journal` icon in
toasts/medallion. `tools/pdv_prisma_roster_parity.mjs` reports each as a **WARN**
("maps to <key> but that glyph is not authored in symbolSpecs yet"). This branch
turns those 18 WARN rows (17 distinct keys) into PASS.

Run `node tools/pdv_prisma_roster_parity.mjs` to see the live WARN list at any time.

## Keys that already reuse an existing glyph (no work needed)

These Phase 2 deities map to glyphs that already exist — already PASS:
- `Malacath` -> `malacath`
- `The Hist` -> `hist`

(Originally assumed `azura` reused an existing glyph; it does **not** — `azura` is
in `gallerySymbols` as a label only, with no `symbolSpecs` entry. It is in the list
below.)

## Keys that need a new SVG glyph (17)

| Symbol key | Deity | Race(s) | Iconography hint |
|------------|-------|---------|------------------|
| `azura` | Azura / Azurah | Dunmer, Khajiit | dawn-and-dusk star / rose |
| `boethiah` | Boethiah | Dunmer | duelist's blade / web of plots |
| `mephala` | Mephala | Dunmer | spider's web / twin threads |
| `shor` | Shor | Nord | whalebone bridge / underworld heart |
| `tsun` | Tsun | Nord | crossed shield-and-axe (shield-thane) |
| `stuhn` | Stuhn | Nord | balance / ransom-scale, brother to Tsun |
| `kynareth` | Kynareth | Nord, Imperial, Breton | open hand to the wind (distinct from Kyne's hawk) |
| `magnus` | Magnus | Altmer | sun-rune / aperture in the sky |
| `xarxes` | Xarxes | Altmer | scrivener's scroll / ancestor-ledger |
| `trinimac` | Trinimac | Altmer, Orc | broken-then-reforged standard |
| `khenarthi` | Khenarthi | Khajiit | bird-of-many-winds / south wind |
| `rajhin` | Rajhin | Khajiit | footpad's shadow / purloined ring |
| `alkosh` | Alkosh | Khajiit | dragon-sun / time-cat |
| `sithis` | Sithis | Argonian | void-spiral / negative space |
| `tuwhacca` | Tu'whacca | Redguard | tomb-gate / Far Shores door |
| `hoonding` | HoonDing | Redguard | make-way crescent / charging horn |
| `leki` | Leki | Redguard | sword-saint's blade-and-stance |

## Authoring instructions (paste to the branch session)

> Open `D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js`.
> For each of the 17 keys above, add (1) an entry to the `symbolSpecs` map using the
> same path convention as the existing `journal`/`dawn`/`kyne` entries (`viewBox`
> `0 0 48 52`-style coordinates, `path`/`circle` arrays with `class` tokens like
> `symbol-thin`), and (2) a `[key, label]` row in `gallerySymbols` (skip `azura` for
> gallery — it already has a `["azura", "Azurah"]` label row; just add its
> `symbolSpecs` glyph). Use **lowercase-hyphenated** keys exactly as listed. Hyphenated
> keys must be quoted in `symbolSpecs` (`"baan-dar":` style) — none of these 17 have
> hyphens, so they stay unquoted. Do NOT edit any `.psc` file; the Papyrus mapping is
> already on main. Keep `node tools/pdv_prisma_ui_audit.mjs` green. After editing,
> mirror the file to the repo copy and hash-match:
>
> ```powershell
> Copy-Item "D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js" `
>   "C:\Users\Admin\Documents\Devotion Mod Project\native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js" -Force
> ```
>
> Acceptance: `node tools/pdv_prisma_roster_parity.mjs --strict` returns **FAIL=0**
> (every roster deity has a real glyph), and `node tools/pdv_prisma_ui_audit.mjs`
> still passes 11 checks.
