# Prisma Devotional Instruments — visual + architecture spec

**Design + art by the design pass (Claude). Coding by Codex.**
This is the source-of-truth for the instrument hero visuals: the architecture, the data→visual mapping,
the verified algorithms (moon phase), and the palette. Codex implements the JS renderers from this; Claude
owns the art (this doc + the glyph data) and will iterate the visuals on feedback.

**See the rendered concept art:** `scratch/prisma-art/instruments.png` (all races),
`scratch/prisma-art/moontest.png` (8-phase moon). Generators: `scratch/prisma-art/*.py`.
**Pairs with:** `handoff/PrismaInstrument_UIHandoff.md` (registry shape), `handoff/PDV_PrismaSubstrate_CodexHandoff.md`
(the `instrument` payload from Papyrus), `handoff/PrismaGlyph_Substrate_SVGData.md` (the symbol marks).

---

## 1. Architecture

The panel "hero slot" renders a typed instrument selected by `instrument.kind`, via a renderer registry
(same pattern as `symbolSpecs` / `eventLanguage`). One container, race-swappable contents.

```js
const instrumentRenderers = {
  piety:    renderPiety,     // patron races (today's bar, refactored)
  lunar:    renderLunar,     // Khajiit
  hist:     renderHist,      // Argonian
  ancestor: renderAncestor,  // Dunmer
  forge:    renderForge,     // Orc
  sects:    renderSects,     // Redguard
  branch:   renderBranch,    // Bosmer
};
// in render(): dispatch the hero slot
const inst = state.instrument || pietyFromState(state);
(instrumentRenderers[inst.kind] || renderPiety)(nodes.instrument, inst);
```

- Each renderer takes `(slotEl, inst)` and builds SVG into `slotEl` (clear first).
- `inst = { kind, tier(0..3), tierLabel, primary(0..1), state, data }` (payload from Codex Track A).
- `index.html`: wrap the current piety markup in `#pdv-instrument` (the hero slot). Phase 0 ships
  `renderPiety` reproducing today's bar → **no visual change**.
- All SVG uses `makeSvgElement` (existing helper). Stroke = `currentColor`; the slot's text color is the
  theme gold, so the art inherits it. Accent strokes use a lighter class.

### Palette (already in `styles.css :root`)
`--gold #d8b35a` · `--gold-soft rgba(216,179,90,0.18)` · `--line rgba(224,204,158,0.28)` ·
`--green #8bbf9f` · `--red #c97968` · `--muted #bcb3a2` · lit fill `#ecdcab` · dark disk `#1b1a16`.
Tones: `good`→green accents, `warning`→red, neutral→gold.

### Instrument canvas
Hero slot ≈ **300×150** (see concept cards). Larger than the 48×48 glyphs — instruments are composite.

---

## 2. The flagship algorithm — moon phase (verified)

Khajiit moon phase is `GetKhajiitMoonPhaseFromGameDay` → 1..8. Render a moon at integer phase `p`:

```js
// returns SVG children for a moon at center (cx,cy), radius r, phase p (1..8)
function moonPhase(cx, cy, r, p) {
  const f = (p - 1) / 8;                 // 0=new, .5=full
  const a = f * 2 * Math.PI;
  const lit = (1 - Math.cos(a)) / 2;     // illuminated fraction
  const rx = Math.abs(r * Math.cos(a));  // terminator x-radius
  const els = [["circle", { cx, cy, r, fill: "#1b1a16", stroke: "currentColor", "stroke-width": 1.1 }]];
  const top = `${cx},${cy - r}`, bot = `${cx},${cy + r}`;
  if (lit > 0.985) {                      // full
    els.push(["circle", { cx, cy, r, fill: "#ecdcab", stroke: "currentColor", "stroke-width": 1.1 }]);
  } else if (lit >= 0.015) {              // crescent / gibbous / quarter
    const waxing = f < 0.5;
    const outer = waxing ? `A ${r} ${r} 0 0 1 ${bot}` : `A ${r} ${r} 0 0 0 ${bot}`;
    const innerSweep = waxing ? (lit < 0.5 ? 0 : 1) : (lit < 0.5 ? 1 : 0);
    els.push(["path", { d: `M ${top} ${outer} A ${rx} ${r} 0 0 ${innerSweep} ${top} Z`, fill: "#ecdcab" }]);
    els.push(["circle", { cx, cy, r, fill: "none", stroke: "currentColor", "stroke-width": 1.1 }]);
  }                                       // new → outline only
  return els;
}
```
This is the exact, verified math from `scratch/prisma-art/moontest.py` (renders new→crescent→quarter→
gibbous→full→…). **Always-on:** recompute `p` from game time on the ambient cadence so the moons drift.

---

## 3. Per-instrument construction

Each: the `data` it consumes, the build, and the live/state behavior. Coordinates are within the ~300×150
slot (see concept cards for the reference look).

### `lunar` (Khajiit) — `data: { phase 1..8, focus, lunarTier }`
- **Masser** `moonPhase(70,82,26,phase)`; **Secunda** `moonPhase(118,52,12,phase)` (smaller, offset).
- **Focus sigil** (right): an 8-point star (R 20/8 alternating) + center dot; brightness scales with
  `primary` (lattice strength). Swap the star for the focus deity's glyph when `focus` maps to one.
- **Phase strip** (bottom): 8 dots, the `phase`-th filled `#ecdcab` + gold ring, rest dark/line.
- **State pulse:** on `substrate/lunar/act`, briefly glow Masser; on `deepen`, brighten the focus sigil.

### `hist` (Argonian) — `data: { hist, people, void, form, voidActive }`
- **Trunk** `M150 132 V70` (sw 2.4). **Roots**: two cubic curves spreading from the base; count/spread
  scale with `hist`. **Canopy**: 1–3 nested arcs `M(150-R) 70 A R R 0 0 1 (150+R) 70`, more arcs = higher
  `people`; crown dot at top.
- **Void**: a translucent red wedge intruding from the right, size ∝ `void`; if `voidActive`, invert the
  canopy fill to red-tinged.
- **State pulse:** `act` → sap glow up the trunk; `thin` → drop an outer canopy arc.

### `ancestor` (Dunmer) — `data: { depth 0..3, prayer, home, reclamation }`
- **Niche arch** (line). **Mask row**: 3 masks (`scratch` ancestor-glyph shape); first `depth` masks lit
  (gold fill + gold strokes), rest dim (line). **Ash motes**: ~14 faint muted dots, density ∝ recent
  `prayer`. **Reclamation sigil** (small, optional): tri-fold mark leaning to Azura/Boethiah/Mephala.
- **State pulse:** `act` → ash shimmer; `deepen` → light the next mask.

### `forge` (Orc) — `data: { lifeMode }`
- **Anvil** (two stacked trapezoids, gold-soft fill). **Flame** above: a teardrop flame whose height/heat
  reflects `lifeMode` (Stronghold bright → City banked → Exile cold/low). **Tusk arcs** flank
  (Malacath). Use the `malacath` glyph as the small mark.
- **State pulse:** `act` → flame flare.

### `sects` (Redguard) — `data: { sect }`
- **Three blade emblems** (upward scimitar/sword + guard); the active `sect` is centered, larger, ringed.
- **Far Shores star-path**: a dashed arc along the bottom with 3 star dots (Walkabout). 
- **State pulse:** `act` → ring shimmer on the active sect.

### `branch` (Bosmer) — `data: { path, evidenceDays, pactBound }`
- **Bound branch**: a single rising cubic (sw 2.4). **Growth rings**: concentric quarter-arcs at the base,
  count = `evidenceDays` bucket. **Binding wrap**: 1–3 small wrap strokes if `pactBound` (Old Contract).
  **Bud** at the tip (pending offer) + one green **leaf** accent.
- **State pulse:** `shift` (path settle) already handled by the toast; `act` → leaf shimmer.

### `piety` (patron races) — `data: { piety, pietyToday, tier }`
- **Deity mark** (left): the active deity glyph (existing `createSymbol`). **Meter**: rounded bar, fill =
  `primary = piety/150`. **Tier pips**: 3 dots, `tier` filled. This is today's information, re-housed in the
  instrument frame → Phase 0 = no visual change.

---

## 4. Ambient (always-on) rendering

When Codex Track B lands (`SetAmbientVisible`/`SendAmbientJson` → `window.ReceivePDVAmbientJson`):
- A persistent `#pdv-ambient` region (separate from the auto-dismissing toast stack), positioned by
  payload (default a screen corner), opacity from payload.
- It reuses the **same** `instrumentRenderers[kind]` — so the moons that show in the panel are the moons
  that float on the HUD. Recompute time-based fields (moon phase) on the cadence Codex pushes.
- Never focus the view (focus pauses the game — see Codex Track B). Default hidden until the MCM toggle.

---

## 5. Build split

| Provided by Claude (art/architecture) | Built by Codex (code) |
|---|---|
| This spec; the `moonPhase` algorithm; per-instrument construction; palette; concept art; the substrate glyph data (`PrismaGlyph_Substrate_SVGData.md`) | The `instrumentRenderers` JS functions + registry + `render()` dispatch; the `#pdv-instrument` / `#pdv-ambient` containers in `index.html`; CSS for the slot/pulses; the `instrument` payload (Papyrus Track A); the native ambient layer (Track B) |

Claude iterates the **visuals** (SVG paths, proportions, new states) on feedback and republishes this doc +
the glyph data. Codex consumes the latest paths. Keep the data→visual field names stable as the interface.
