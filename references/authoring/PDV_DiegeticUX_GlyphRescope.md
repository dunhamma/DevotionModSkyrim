# PDV Glyph Re-Scope — what the diegetic text layer lets you defer

**Status:** Scoping decision doc. Formalizes the glyph-roster re-scope enabled by the diegetic UX layer.
**Reads with:** `handoff/PrismaMedallionRoster_DesignHandoff.md` §5 (glyph status), `handoff/PrismaInstruments_EndToEndPlan.md`
(the "glyph only appears when SVG-wired AND Papyrus-emitted AND deity-scorable" gate), `handoff/PrismaGlyph_FullRoster_SVGData.md`
(the 49 drawn glyphs), `references/authoring/PDV_DiegeticUX_ContentBank_Roster.md` (the text that now carries identity).
**Date:** 2026-06-05

## The headline

The diegetic layer does **not** change how many *medallions* you need (the medallion was always **one
chooser surface** + now **one deity-aware MISC item** — not a per-deity count). It changes the **glyph**
economics: because the medallion text, the journal line, and the MessageBox all **name the deity in
words**, a deity can have a complete player-facing surface **without a wired glyph**. Glyphs become
**progressive enhancement**, not a launch gate.

## Three glyph states (the distinction that matters)

| State | Meaning | Today |
|---|---|---|
| **Drawn** | SVG art exists | **49 roster glyphs drawn** in `PrismaGlyph_FullRoster_SVGData.md` (+6 substrate, +15 base/Tier-0). Art is *mostly done.* |
| **Wired** | SVG is in `app.js symbolSpecs` AND Papyrus emits the name AND the deity is scorable | only **15 wired** (12 base Aedric + `yffre`/`zen`/`baan-dar`). |
| **Text-fallback** | no wired glyph → the surface renders **text-only** | **the new default** — graceful, not broken. |

**The re-scope is about the *Wired* column, not the *Drawn* column.** The art is largely paid for; the
question is how many you must *wire + scorability-gate* before each deity is shippable. The diegetic layer
answers: **only the ones you want to feel premium now** — the rest ride on text.

## The rule that makes this safe (inverts a prior worry)

The EndToEndPlan flagged a need for a "symbol-name → glyph-key map … to prevent silent `journal`
fallbacks." With the diegetic layer, **a missing glyph resolving to text is the intended behaviour, not a
defect.** So:

1. **Still build the symbol-name → glyph-key map** — Papyrus must only emit valid keys, and the map records
   which keys are wired vs text-only.
2. **Text-only is a first-class render**, not an error state. The medallion/journal never show a broken or
   placeholder `journal` icon for an unwired deity — they show the deity's name + state text (the content
   bank). (Prisma toasts/instruments may still show a neutral mark.)
3. **A deity is shippable when it is *scorable* + has *text copy*** — glyph optional. This decouples the
   long-tail deity rollout from glyph wiring.

## Priority tiers (what to wire, and when)

### W0 — wire now (the only glyphs the launch path needs)
The 15 base/Tier-0 (done) + the surfaces the pilot and shared systems actually show:
- **Already wired (15):** 12 base Aedric + `yffre`, `zen`, `baan-dar`.
- **Substrate marks (6, drawn, drop into symbolSpecs):** `lunar`, `hist`, `ancestor`, `malacath`, `sect`,
  `branch` — these back the instruments + the pilot races.
- **Pilot Princes/Reclamation (drawn):** `azura` (Dunmer pilot), plus `hircine`, `molag-bal` (the
  curse-access pair the shared curse system surfaces).

→ **W0 ≈ 24 wired** (15 + 6 + 3). This covers both pilot races, the instruments, and the curse system.

### W1 — wire next (native lanes, art already drawn)
The native-pantheon glyphs each deity-pantheon race shows, plus the remaining native Princes — all already
drawn in the roster/cultural batches:
- Native Princes: `boethiah`, `mephala` (Dunmer Reclamations) + any other native (`meridia` for the
  cleansing-light reuse).
- Cultural pantheon glyphs that exist (Nord `shor`/`stuhn`/…, Altmer `syrabane`/`xarxes`, Khajiit lunar
  set, Yokudan set) — wire per race as that race's content lands.

→ Wire **per race, as that race's content bank ships** (D3). No big-bang.

### W2 — defer behind text (no launch dependency)
The long-tail: full 45-god + 16-Prince roster depth, concept marks, and the **refinement-flagged** glyphs
(`mehrunes-dagon`, `tsun`, `satakal` per `PrismaGlyphRoster_RefinementFlags.md`). These render as **text**
until wired; wire opportunistically. **None blocks 1.0.**

## Per-race glyph need (feel-complete vs text-covered)

| Race | Glyphs to feel premium (wire) | Covered by text alone |
|---|---|---|
| Khajiit (pilot) | `lunar` + Khenarthi/lunar-focus mark | the 9-god lunar pantheon tail |
| Dunmer (pilot) | `ancestor` + `azura` | `boethiah`/`mephala` (W1), ancestor depth |
| Nord | a few native (`shor`…) | the 13-god pantheon tail |
| Imperial | base Aedric (already wired) | Talos politics handled in text/standing |
| Breton | base + `yffre`/Green | the 12-god tail; **the legibility medallion is all text anyway** |
| Altmer | `auri-el`/`trinimac` | the 9-god tail |
| Bosmer | `branch` + `yffre`/`baan-dar` (wired) | the 4 paths in text |
| Argonian | `hist` | Sithis/void in text |
| Orc | `malacath` | — (Orc is nearly single-deity) |
| Redguard | `sect` | the 7-god Yokudan tail |

**Observation:** the substrate races (which carry the heaviest cultural tails) need essentially **one
substrate mark each** to feel complete — the tail is text. The deity-pantheon races lean on the
already-wired base Aedric set. So the *premium* glyph set is small.

## Impact statement

| | Before diegetic layer | After |
|---|---|---|
| Glyphs that must be **wired + scorable** before a deity has any surface | ~the full roster (≈49+ to avoid broken chooser) | **W0 ≈ 24**, then per-race W1 as content ships |
| Medallion *items/surfaces* | 1 chooser | 1 chooser + 1 MISC (coexist) — **no change in count** |
| Long-tail deities blocked on art | yes | **no** — text-covered, glyph optional |
| Refinement-flagged glyphs blocking ship | yes | **no** — deferred behind text |

**Net:** the *required-before-ship* glyph wiring drops from the full roster to roughly the **W0 ~24**, and
the medallion-roster chooser itself can be **scoped to native lanes where glyphs are wired**, with the
diegetic MISC medallion + journal carrying awareness for everything else. The drawn-but-unwired roster
stays as a backlog of pure enhancement, not a blocker.

## What to keep doing regardless
- Build the **symbol-name → glyph-key map** (valid emit names; marks wired vs text-only).
- Keep the **6 substrate marks** on the W0 critical path (they back the instruments, PDV's real moat).
- The **real bottleneck remains deity *scoring/wiring***, not art — the diegetic layer just means a scorable
  deity is immediately presentable in text without waiting on its glyph.
