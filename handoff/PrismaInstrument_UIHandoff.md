# Prisma UI handoff — substrate event + instrument renderer (Claude UI track)

**For:** a Claude code pass on `app.js` (the frozen file). Pairs with the Codex tracks in
`handoff/PDV_PrismaSubstrate_CodexHandoff.md` and the design in
`handoff/PrismaSubstrateInstruments_DesignDraft.md`.

Two parts:
- **Part 1 — `substrate` event language** (Phase 0). Low-risk, same additive pattern as `shift`/`daedric`/
  `curse`. **Applied this session.**
- **Part 2 — instrument renderer registry** (Phase 1). The hero-slot refactor; needs an `index.html`
  container and pairs with Codex Track A's `instrument` panel block. **Specced here, not yet applied.**

---

## Part 1 — `substrate` event (Phase 0)

### Payload (from Codex `SendPrismaSubstrateToast`)
```json
{"mode":"toast","toast":{"event":"substrate","substrate":"lunar|hist|ancestor|stronghold|sect",
  "phase":"act|deepen|thin","symbol":"...","context":"...","state":"..."}}
```

### `normalizeToastPayload` additions
```js
if (!normalized.substrate) {
  normalized.substrate = text(payload.substrate, "");
}
if (!normalized.state) {
  normalized.state = text(payload.state, "");
}
```
(`phase` is already normalized by the daedric pass.)

### `eventAliases` additions
```js
substrate_act:    "substrate",
substrate_deepen: "substrate",
substrate_thin:   "substrate",
```

### `substrateName` helper (next to `curseLabel`)
```js
const substrateName = (payload = {}) => {
  const s = text(payload.substrate, "").toLowerCase();
  if (s === "lunar") return "The moons";
  if (s === "hist") return "The Hist";
  if (s === "ancestor") return "Your ancestors";
  if (s === "stronghold") return "The stronghold";
  if (s === "sect") return "Your sect";
  return "Your path";
};
```

### `eventLanguage.substrate` block
```js
substrate: {
  tone: (payload) => (text(payload.phase, "") === "thin" ? "warning" : "good"),
  symbol: (payload) => text(payload.symbol, "journal"),
  title: (payload) => {
    const name = substrateName(payload);
    const phase = text(payload.phase, "");
    if (phase === "deepen") return `${name} deepen`;
    if (phase === "thin") return `${name} thin`;
    return `${name} answer`;
  },
  message: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const name = substrateName(payload);
    const phase = text(payload.phase, "");
    if (phase === "deepen") return `${name} hold you more strongly now.`;
    if (phase === "thin") return `${name} are slipping from you.`;
    return `${name} marked what you did.`;
  },
  listTitle: (payload) => {
    const state = text(payload.state, "");
    return state || substrateName(payload);
  },
  listText: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    return text(payload.phase, "") === "thin"
      ? `${substrateName(payload)} need tending.`
      : `${substrateName(payload)} are with you.`;
  },
},
```

### Demo entries + buttons
```js
substrate_lunar:    { event: "substrate", substrate: "lunar",    phase: "act",    symbol: "lunar",    state: "Lattice: steady" },
substrate_deepen:   { event: "substrate", substrate: "hist",     phase: "deepen", symbol: "hist",     state: "Hist: strong" },
substrate_thin:     { event: "substrate", substrate: "ancestor", phase: "thin",   symbol: "ancestor", state: "Ancestor layer: quiet" },
```
```html
<button type="button" data-demo-toast="substrate_lunar">Substrate (lunar act)</button>
<button type="button" data-demo-toast="substrate_deepen">Substrate (deepen)</button>
<button type="button" data-demo-toast="substrate_thin">Substrate (thin)</button>
```

> Note: symbols `lunar` / `hist` / `ancestor` have no glyph yet (Tier-3, per `PrismaGlyph_DesignHandoff.md`)
> and fall back to `journal` until the instrument glyphs land. Non-breaking.

---

## Part 2 — Instrument renderer registry (Phase 1, not yet applied)

Resolves the dead-piety-bar inequity: the panel "hero slot" renders a typed instrument by `kind`.

### Panel payload (from Codex Track A)
```json
"instrument": { "kind":"piety|lunar|hist|ancestor|forge|sects|branch",
  "tier":0, "tierLabel":"...", "primary":0.0, "state":"...", "data":{ ... } }
```

### UI design
1. **`index.html`:** wrap the current piety-bar markup in a `#pdv-instrument` hero-slot container (the
   piety DOM stays for `kind:"piety"`). New container so substrate renderers can replace its contents.
2. **`app.js`:** an `instrumentRenderers` registry keyed by `kind` (same shape as `symbolSpecs` /
   `eventLanguage`):
   ```js
   const instrumentRenderers = {
     piety:  (slot, inst) => renderPietyInstrument(slot, inst),   // = today's bar, refactored
     lunar:  (slot, inst) => renderLunarInstrument(slot, inst),   // twin moons (pilot)
     // hist, ancestor, forge, sects, branch added per phase
   };
   ```
3. In `render()`, dispatch the hero slot:
   ```js
   const inst = state.instrument;
   const kind = (inst && instrumentRenderers[inst.kind]) ? inst.kind : "piety";
   instrumentRenderers[kind](nodes.instrument, inst || pietyFromState(state));
   ```
   **Phase 0 guarantee:** with `kind:"piety"` reproducing the current bar, there is **no visual change**.

### Pilot instrument — `lunar` (Khajiit)
- `inst.data = { phase:1..8, focus, lunarTier }`.
- Render: two SVG moons (Masser large + Secunda small) at the phase (8-step terminator), the focus sigil
  brightening with the lattice tier (`primary`), an observance pulse on a `substrate/lunar/act` toast.
- Forms to evaluate: corner crescent-pair · panel orrery · 8-phase strip. (See design draft §Khajiit.)
- New SVG glyphs needed: `moon-masser`, `moon-secunda` (or a phase-parametric moon component) — author in
  the `symbolSpecs` family.

### Then: per-race renderers (`hist`, `ancestor`, `forge`, `sects`, `branch`) per the design draft specs.

---

## Part 3 — Ambient entry (Phase 2, pairs with Codex Track B native)

When the native ambient layer lands (`SetAmbientVisible` / `SendAmbientJson` →
`window.ReceivePDVAmbientJson`), add a **persistent** ambient region (separate from the auto-dismissing
toast stack) that renders the same instrument via the registry above — so the moons can float on the HUD.
```js
window.ReceivePDVAmbientJson = (payloadText) => {
  const p = parsePayload(payloadText);          // { kind, visible, opacity, instrument }
  renderAmbient(p);                             // persistent #pdv-ambient region, reuse instrumentRenderers
};
```
Gate visibility/opacity on the payload; never auto-dismiss. Default hidden until the MCM toggle pushes
`visible:true`.

---

## Constraints
- `app.js` / `index.html` / `styles.css` are frozen — Part 1 is applied via this doc; Parts 2–3 land via
  follow-up application of this same doc.
- Add JSON fields freely; never remove/rename existing ones.
- Do not touch `PDV_PrismaBridge` or the `ReceivePDVJson` / `ReceivePDVOverlayJson` entries.
