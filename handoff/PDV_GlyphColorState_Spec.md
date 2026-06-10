# PDV Glyph Color-State Spec (L3c)

**For:** Codex + UI build (L4b). **From:** Claude. **Status:** design spec; art/CSS
deferred to L4. **Decision (user):** every deity/Prince has ONE unique glyph; **state is
shown by color**, not by swapped art. This spec defines what color says, reusing the
existing palette so glyph color and the medallion favor-line share one language.

## Grounding (reuse, do not invent)
- Glyphs are line-art with `stroke: currentColor` (`styles.css .symbol`), default rendered
  `color: var(--gold)`. So **one color axis per glyph**, driven by the wrapper's `color`.
- Palette already defined in `styles.css :root`:
  `--gold #d8b35a` · `--green #8bbf9f` · `--blue #9db8d2` · `--red #c97968` ·
  `--muted #bcb3a2` · `--gold-soft rgba(216,179,90,0.18)`.
- Established standing-color language (ArchitectureSpec §5.1 medallion favor line):
  **green = Devoted · gold = Faithful · muted = slip · red = silent**. The glyph adopts the
  same language so the medallion's mark and its favor line agree.

---

## 1. Resting glyph color = devotion STANDING

The glyph's persistent color encodes the active patron's current standing:

| State | Glyph `color` | Var | Reads as |
|---|---|---|---|
| Observant (lowest active tier) | dim gold | `--gold-soft` → bump to ~0.55 alpha gold | noticed, faint |
| Faithful | gold | `--gold` | favored |
| Devoted | green | `--green` | deep favor |
| Champion | radiant gold + aura | `--gold` + `drop-shadow` glow | apotheosis |
| Slipping / neglect | grey | `--muted` | favor cooling |
| Silent / cursed-severed | red | `--red` | cut off |

- Tier ramp is **Observant→Faithful→Devoted→Champion = dim-gold → gold → green → radiant**;
  matches the existing gold-Faithful / green-Devoted choice (non-monotonic hue is
  intentional — green signals "thriving," radiant gold signals apotheosis).
- **Curse:** the glyph goes `--red` (severed). The cold-blue *dread screen vignette*
  (IMAD, sustained onset→cure) is a **separate channel**, not the glyph color — keep both.
- Neglect vs silent: `--muted` while slipping, `--red` only at the floor/severed.

## 2. Transitions are screen flashes, not glyph recolors

The IMAD screen-tone flashes (ArchitectureSpec §5.3: reverent gold / revelation white /
dread blue / release green / turning neutral / absence grey / apotheosis gold) are a
**momentary screen overlay** on a beat. The glyph itself **settles back to its resting
standing color** after the flash. Optional: a brief glyph pulse may accompany a beat
(e.g. a `release` cure pulses the glyph green→resting), but the glyph's steady-state is
always the §1 standing color. Do not bake a transition tone into the glyph's resting color.

## 3. Chooser context: fill = nothing-yet, access = a SEPARATE channel

In the medallion-roster chooser (L3d) the player usually has **no standing** with most
listed gods, so:
- Glyph fill renders **neutral** (`--muted`, or `--gold-soft` for the active patron) — it
  does NOT encode access-tier. State-color is reserved for the standing display.
- **Access tier is shown by a separate channel** — a rim/border + optional badge — so it
  never collides with the state-color meaning:

| Access tier | Border / badge | Var |
|---|---|---|
| Native | solid gold rim | `--gold` |
| Foreign (with cost) | muted rim + small "cost" tag | `--muted` |
| Curse-access (Hircine/Molag Bal) | blue rim + lock badge | `--blue` |
| Taboo / Hostile | red rim + "forbidden" badge | `--red` |

The active patron in the chooser additionally shows its real standing color on the fill.

## 4. CSS-class contract (for L4b)

Glyph color is driven by a state class on the symbol wrapper (since `.symbol` is
`currentColor`):

```css
.symbol.dev-observant { color: rgba(216,179,90,0.55); }
.symbol.dev-faithful  { color: var(--gold); }
.symbol.dev-devoted   { color: var(--green); }
.symbol.dev-champion  { color: var(--gold); filter: drop-shadow(0 0 6px var(--gold)); }
.symbol.dev-slipping  { color: var(--muted); }
.symbol.dev-cursed    { color: var(--red); }
/* chooser access rim (separate from fill) */
.symbol-tile.acc-native  { border-color: var(--gold); }
.symbol-tile.acc-foreign { border-color: var(--muted); }
.symbol-tile.acc-curse   { border-color: var(--blue); }
.symbol-tile.acc-taboo   { border-color: var(--red); }
```

**Papyrus/payload contract:** the panel/medallion payload carries, per glyph, the symbol
name + a `devState` token (`observant|faithful|devoted|champion|slipping|cursed`) and, in
the chooser, an `accessTier` token (`native|foreign|curse|taboo`). The UI maps token →
class. Add fields, never rename/remove existing ones.

## 5. Acceptance
- One resting color per standing, all six states covered by existing vars (no new palette).
- Curse glyph = red; dread screen stays blue (two channels, not merged).
- Transitions flash on screen; glyph returns to standing color.
- Chooser: fill never encodes access; access = rim/badge only.
- Color-blind note for L4: pair every color with a non-color cue (tier label text on the
  medallion line, badge glyph in the chooser) so state is legible without hue.
