# Prisma instruments + glyphs — end-to-end readiness plan

Master tracker tying the design/art (Claude) and coding (Codex) tracks together so the substrate-equity +
instrument + glyph system actually ships and works in-game. Ownership: **Claude = architecture, design, art
(incl. glyph SVG data); Codex = all code (JS, Papyrus, native C++).**

Legend: ✅ done · 📄 specced in a handoff, not yet built · ⛔ not started/blocked.

---

## The gating insight (read first)

**The 49+6 new glyphs are dormant on *both* sides today.** Verified:
- `app.js symbolSpecs` contains only the 12 base + 3 Tier-0 (`yffre`/`zen`/`baan-dar`). The substrate and
  roster glyphs exist only in handoff docs.
- Papyrus `GetPrismaSymbolForDeity` emits only ~13 deity names; the substrate event emits 5.

So a glyph only appears in-game when **two** things land: (1) its SVG is in `symbolSpecs` (Codex JS), **and**
(2) Papyrus actually emits its symbol name. (2) is the real bottleneck — for most deities that means the
deity has to be **scorable / selectable** (the medallion + Prince-scoring backlog). **The instruments,
glyphs, and the medallion are one interlocked system; the glyph payoff is gated on deity wiring.**

---

## Status snapshot

| Layer | State |
|---|---|
| Event voice (favor…substrate) | ✅ live in `app.js` |
| Tier-0 glyphs (`yffre/zen/baan-dar`) | ✅ live |
| Substrate glyphs (`lunar/hist/ancestor/malacath/sect/branch`) | 📄 `PrismaGlyph_Substrate_SVGData.md` |
| 49-glyph roster (Princes/cultural/concept) | 📄 `PrismaGlyph_FullRoster_SVGData.md` (refined) |
| Instrument renderers + `#pdv-instrument` slot | 📄 `PrismaInstruments_VisualSpec.md` / `PrismaInstrument_UIHandoff.md` |
| Substrate event emit (Papyrus) | 📄 Codex Track A |
| Panel `instrument` payload (Papyrus) | 📄 Codex Track A |
| Native ambient layer | 📄 Codex Track B |
| Medallion roster (select deity) | 📄 `PrismaMedallionRoster_DesignHandoff.md` (brief only) |

---

## Remaining work by owner

### Claude (art / architecture) — mostly done; remaining:
1. **Glyph refinement** — apply your review feedback + the 3 self-flagged (`mehrunes-dagon`, `tsun`, `satakal`). ⛔ awaiting review
2. **Authoritative symbol-name → glyph-key map** — one table so Codex/Papyrus never emit a name that has no
   glyph (prevents silent `journal` fallbacks). ⛔ (I'll produce this; it's the contract that ties art↔Papyrus)
3. **Instrument *state* art** — the `deepen`/`thin`/silenced visuals + the curse-silenced substrate look
   (e.g. vampire silences the Hist). 📄 partially in the visual spec; needs the silenced states.
4. **Medallion visual spec** — promote the medallion brief to a full visual spec (like the instruments got),
   if the medallion is in scope for this arc. ⛔
5. **CSS/art direction** for the slot + pulses + ambient (colors, motion) — spec for Codex to implement. 📄 partial

### Codex — JS (Track C)
1. Drop both glyph data files into `symbolSpecs` + `gallerySymbols`. 📄
2. `#pdv-instrument` container (`index.html`) + `instrumentRenderers` registry + `render()` dispatch +
   port `moonPhase()` + the 7 renderers. 📄
3. CSS for the slot + state pulses. 📄
4. `ReceivePDVAmbientJson` persistent region (pairs with native). 📄

### Codex — Papyrus (Track A + the gating backlog)
1. `SendPrismaSubstrateToast` + emit wiring (act/deepen/thin). 📄
2. `instrument` payload block in `PushDevotionPanel` (per-race `data`). 📄
3. **Extend `GetPrismaSymbolForDeity`** to every name that now has a glyph (so active deities show their
   mark). ⛔ — bounded and high-value; do even ahead of full scoring.
4. **Deity wiring backlog (the real unlock):** the medallion offer/select/score, Prince scoring (15
   Princes), and the cultural-deity scoring — this is what makes most glyphs actually fire. ⛔ large;
   start with the FormList reconciliation (dump `PDV_FLST_AllDeities`).
5. Curse-silenced substrate states (Papyrus side of #3 above). ⛔

### Codex — Native C++ (Track B)
1. Ambient lifecycle (`SetAmbientVisible`/`SendAmbientJson`, keep view shown-unfocused) + rebuild DLL. 📄
2. MCM "ambient HUD" toggle (Papyrus MCM + the native call). ⛔

---

## Cross-cutting / integration items (easy to forget)

- **Symbol-name contract** — the map in Claude #2 is the single interface that keeps art and Papyrus in
  sync; every emitted name must resolve. Treat as the acceptance gate for "no journal fallbacks."
- **`?demo` harness** — extend the demo controls to preview each instrument + the ambient widget, and a
  glyph gallery page showing all symbols (QA at true size). (Codex JS)
- **Update cadence** — the always-on instrument needs a throttled tick (game-time) so moons drift without
  spam; reuse the panel dirty-flag/`OnUpdate` pattern. (Codex Papyrus + native)
- **Curse posture interactions** — vampire/werewolf states silence or recolor some substrates; design (Claude)
  + wiring (Codex).
- **Live deploy** — `tools/sync-devotion-to-live.ps1` copies repo→live; the `.psc` still needs a **CK
  compile** and the **DLL a rebuild**. (User/Codex)
- **Frozen-file process** — all `app.js`/`index.html`/`styles.css` edits land via the handoffs above.

---

## Decisions needed (you)

1. **Medallion in scope now?** Instruments alone improve the *panel*, but most glyphs stay dormant until the
   medallion/deity-scoring lands. Do we pursue the medallion in this arc, or ship instruments + substrate
   events first and let the glyph roster fill in as deities are wired later?
2. **Always-on default** — confirm hybrid-opt-in vs always-on HUD (you said "maybe raise depending"); this
   sets the native acceptance criteria.
3. **Glyph review outcome** — which flagged marks to keep/redo (feeds Claude #1).

---

## Suggested critical path

1. **Glyph review → refine** (Claude) + **drop glyphs into `symbolSpecs`** (Codex JS) + **extend
   `GetPrismaSymbolForDeity`** (Codex Papyrus). → glyphs stop being dormant for already-wired deities.
2. **Substrate events + `instrument` payload** (Codex Papyrus) + **instrument renderers** (Codex JS). →
   substrate races get reactive toasts **and** a live panel instrument (the equity fix lands, all races).
3. **Native ambient + MCM toggle** (Codex) + **ambient renderer** (Codex JS). → always-on instruments.
4. **Deity-wiring backlog / medallion** (Codex Papyrus, gated on the FormList dump). → the full glyph roster
   goes live as deities become selectable/scorable.

Steps 1–2 deliver the headline value (equity + instruments, all races) without the heavy backlog; 3 adds the
always-on flourish; 4 is the long tail that lights up the rest of the glyphs.
