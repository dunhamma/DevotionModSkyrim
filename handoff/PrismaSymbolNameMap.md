# Prisma symbol-name → glyph-key contract map

The single interface between the **art** (glyph SVGs in `symbolSpecs`, Claude) and **Papyrus** (the `symbol`
string each event/panel emits, Codex). **Rule:** every symbol name Papyrus emits must resolve to a real glyph
(directly or via `symbolAliases`) — otherwise it silently falls back to `journal`. This map is the acceptance
gate for "no unintended journal fallbacks."

Glyph keys live in: `app.js symbolSpecs` (base 12 + Tier-0), `PrismaGlyph_Substrate_SVGData.md`,
`PrismaGlyph_FullRoster_SVGData.md`. Emitters verified in `PDV__ManagerQuest.psc`.

---

## 1. Names emitted today (must resolve)

| Symbol name emitted | Glyph key | Status | Emitter |
|---|---|---|---|
| `kyne` `talos` `auri-el` `akatosh` `arkay` `dibella` `julianos` `mara` `stendarr` `zenithar` | same | ✅ base 12 | `GetPrismaSymbolForDeity`, quasi-patron, favor/tier |
| `yffre` `zen` `baan-dar` | same | ✅ Tier-0 (live in `app.js`) | deity symbol, Khajiit focus, Bosmer path |
| `dawn` | `dawn` | ✅ | dawn event |
| `journal` | `journal` | ✅ fallback | neglect, generic |
| `hist` | `hist` | ⬆ glyph authored, **not yet in `symbolSpecs`** | Argonian shift / quasi-patron / substrate |
| `malacath` | `malacath` | ⬆ authored, not in `symbolSpecs` | Orc shift / quasi-patron / substrate |
| `ancestor` | `ancestor` | ⬆ authored, not in `symbolSpecs` | Dunmer quasi-patron / substrate |
| `lunar` | `lunar` | ⬆ authored, not in `symbolSpecs` | Khajiit quasi-patron / substrate |
| `khenarthi` `rajhin` `alkosh` | same | ⬆ authored (roster), not in `symbolSpecs` | Khajiit focus (`GetKhajiitFocusSymbol`) |
| `hircine` | `hircine` | ⬆ authored, not in `symbolSpecs` | daedric event |
| `curse-vampire` | `curse-vampire` | ⬆ authored, not in `symbolSpecs` | curse event |
| `azurah` | `azura` | ⚠ **needs alias** `azurah → azura` | Khajiit focus (Azurah) |
| `curse-werewolf` | `hircine` | ⚠ **needs alias** `curse-werewolf → hircine` (reuse) or own glyph | curse event |
| `journal` (Redguard) | `sect` | ⚠ **Papyrus fix** — emit `sect`, not `journal` | Redguard quasi-patron + shift |
| `journal` (Breton) | — | ✓ acceptable fallback (no Breton glyph) | Breton quasi-patron |

**⬆ = the glyph exists in a handoff doc but isn't in `app.js symbolSpecs` yet.** Codex Track C drops
`PrismaGlyph_Substrate_SVGData.md` + `PrismaGlyph_FullRoster_SVGData.md` into `symbolSpecs`; until then these
names fall back to `journal` in-game even though they're emitted.

### Action items from §1
- **Codex JS:** add `hist`, `malacath`, `ancestor`, `lunar`, `khenarthi`, `rajhin`, `alkosh`, `hircine`,
  `curse-vampire` (and the rest of the roster) to `symbolSpecs`.
- **Codex JS — `symbolAliases`:** add `azurah: "azura"` and `"curse-werewolf": "hircine"`.
- **Codex Papyrus:** Redguard `GetPanelQuasiPatronSymbol` + the Redguard shift emit → return `"sect"`.
- **Claude (optional):** a `tradition` glyph for Breton if we don't want the `journal` fallback there.

---

## 2. Dormant glyphs (authored, no emitter yet — light up as deities are wired)

These have art ready but **no Papyrus path emits their name today**. They activate when the deity becomes
selectable/scorable (the medallion + Prince/cultural-scoring backlog) and gets a `GetPrismaSymbolForDeity`
branch. No art work needed — purely a Papyrus-emit dependency.

- **Princes (need scoring + emit):** `azura`* `boethiah` `mephala` `meridia` `molag-bal` `nocturnal`
  `hermaeus-mora` `mehrunes-dagon` `sheogorath` `namira` `sanguine` `clavicus-vile` `peryite` `vaermina`
  (*`azura` is reachable now via the `azurah` alias once added.)
- **Cultural (need the deity wired):** `shor` `tsun` `stuhn` `magnus` `trinimac` `phynaster` `syrabane`
  `xarxes` `jode` `jone` `riddle-thar` `sithis` `sep` `satakal` `ruptga` `tu-whacca` `tava` `leki` `onsi`
  `hoon-ding`
- **Concept (light up with substrate-instrument detail / medallion):** `void` `stronghold` `crown`
  `forebear` `ashabah` `concordat` `pact` `stigma` `broad`

### Natural next emitters (cheap wins once the deities/states exist)
- `stronghold` ← could replace `malacath` for the Orc instrument's *City/Exile* sub-states.
- `crown` / `forebear` / `ashabah` ← Redguard sect detail (per-sect symbol instead of one `sect`).
- `concordat` ← Imperial Concordat state; `pact` ← Bosmer Old Contract; `void`/`sithis` ← Argonian Void posture.

---

## 3. Summary
- **3 small contract fixes** make every *currently-emitted* name resolve: the `azurah` + `curse-werewolf`
  aliases (JS) and the Redguard `sect` emit (Papyrus). Do these alongside dropping the glyphs into
  `symbolSpecs`.
- The **large dormant set** is not a bug — it's the glyph roster waiting on the deity-wiring backlog
  (`PrismaInstruments_EndToEndPlan.md` §gating insight). Each lights up as its deity becomes scorable.
