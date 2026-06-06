# PDV Piety-Surfacing Audit — continuity across all earning modes

**Purpose:** make every way a race *earns or loses devotion* surface to the player
with the same quality the deity-patron path now has in Prisma. Audit first, then fill
the **non-deity** gaps (substrates, state tracks, curses, and especially Daedric
Princes). This doc is the plan; the glyph half is in
`handoff/PrismaGlyph_DesignHandoff.md`.

Status as of this pass: the Prisma toast layer is event-templated
(`favor | dawn | neglect | tier | rivalry`), contextual favors now route through the
`favor` voice, and the main panel is wired (`PushDevotionPanel`). What remains is
**non-deity** modes that still only surface on-demand (Survey/MCM) instead of
emitting first-class events.

---

## 1. Surfacing channels we have (no new tool needed)

| Channel | Moment vs. state | Owns the voice? | Good for |
|---|---|---|---|
| **Prisma toast** (overlay) | moment-in-time | UI (event vocab) | "something just happened" |
| **Prisma panel** (`SendJson`) | current state | UI | at-a-glance dashboard while open |
| **MCM Player page** | current state, menu | Papyrus strings | persistent reference, settings |
| **Survey Devotion power** | on-demand narrative | Papyrus prose | deep, reverent read |
| `Debug.Notification` | fallback | Papyrus | last-resort when bridge is down |

**Recommendation up front:** do **not** add a new tool. We already have the right
stack (moment → toast, state → panel + MCM, narrative → Survey). The real gap is
**architectural**: many non-deity modes update silent StorageUtil/state-track values
and are only *read back* later. They should **emit a typed Prisma event at the moment
of change**, the same way patron piety does. One funnel, UI owns voice and symbol.

---

## 2. Piety-earning modes — taxonomy

1. **Patron deity** (scores `PDV.Piety`): Kyne, Talos, Auri-El, Y'ffre, Z'en, Baan Dar.
   → fully surfaced: favor/tier/neglect/rivalry toasts + panel + survey.
2. **Broad pantheon baseline** (Nord Old Ways / Nine Divines, Imperial Nine).
3. **Race substrate / state track** (Dunmer ancestor, Khajiit lunar+focus, Argonian
   Hist posture, Orc life-mode, Redguard sect, Bosmer path, Imperial Concordat).
4. **Contextual favors** (timed blessings for race-appropriate acts) — now on `favor`.
5. **Curse states** (vampire/werewolf, Altmer dawn-exile, Nord Sovngarde-closed).
6. **Daedric Princes** (only Hircine is path-wired; 15 others are prose-ready only).

Modes 2/3/5/6 are the **non-deity gaps**.

---

## 3. Per-race audit

Legend — Surfaced: ✅ event+panel ; 🟡 survey/MCM only ; ❌ silent.

| Race | Earning modes present | Patron toasts | Non-deity surfacing today | Primary gap |
|---|---|---|---|---|
| **Nord** | Kyne/Talos patron, Old Ways & Nine Divines lanes, contextual favor, neglect, vampire curse | ✅ | pantheon-baseline shift 🟡, contextual favor ✅(now), Sovngarde-closed 🟡 | baseline shift + curse onset/cure as events |
| **Imperial** | Nine Divines broad, Concordat/Talos pressure, Talos patron path | ✅ (if Talos patron) | Concordat pressure 🟡, Talos-pressure 🟡 | Concordat shift + Talos-pressure events |
| **Breton** | tradition pick (Knight's Road/Hidden Art/Green Way), P2 hooks | ⚠️ depends on tradition deity | startup ✅, tradition state 🟡 | tradition-shift event; Hidden Art Daedric tie-in |
| **Dunmer** | ancestor substrate, **Reclamations (Azura/Boethiah/Mephala)** | ❌ no patron deity wired | ancestor layer 🟡 | **non-deity substrate + 3 Daedric Princes unwired** |
| **Altmer** | Auri-El patron, crisis/coherence, Altmer favor lane, werewolf-halt/vampire-exile curse | ✅ | crisis state 🟡, contextual favor ✅(now), curse special-states 🟡 | crisis-shift + curse events; `auri-el` already glyphed |
| **Khajiit** | lunar substrate, **silent** focus emphasis, Baan Dar/Rajhin/Alkosh | ✅ (Baan Dar if patron) | focus shift 🟡 (intentionally quiet), lunar 🟡 | decide which lunar/focus beats are quiet vs. shown; Rajhin/Alkosh unwired |
| **Bosmer** | path track → Y'ffre/Z'en/Baan Dar patrons, Green Pact compliance, path-change rite | ✅ | path-change literal toast ✅, Green Pact violation 🟡, path state in panel 🟡 | Green Pact lapse as `neglect`; path state into panel; glyphs (Tier 0) |
| **Redguard** | sect pick (Crown/Forebear/Ash'abah), **Yokudan pantheon**, Ash'abah undead duty | ❌ no patron deity wired | startup ✅, sect state 🟡 | **non-deity sect + Yokudan pantheon unwired** |
| **Orc** | life-mode (Stronghold/City/Legion-Exile), **Malacath** | ❌ Malacath not scoring | startup ✅, life-mode 🟡 | **Malacath Daedric path + life-mode-shift events** |
| **Argonian** | **Hist posture substrate, People (borrowed gods), Void/Sithis** | ❌ no patron deity | Hist refresh at dawn 🟡 | **fully non-deity race — needs substrate-as-quasi-patron surfacing** |

Cross-cutting: **Daedric Princes** — only `PDV_DaedricPath_Hircine` is path-wired.
The other 15 are content-ready in prose (`PDV_DeityCoverageMatrix.json` slice 20C)
but have no runtime scoring, no event, and no glyph. This is the single biggest
non-deity continuity gap and it touches Dunmer, Orc, Breton, Khajiit, and any race
that crosses into a Prince.

---

## 4. How to "comfortably pull non-deity modes into the experience"

The deity path works because a patron has: an **identity** (name + symbol), a
**meter** (piety/tier), and **typed events** (favor/tier/neglect/rivalry). Give the
non-deity modes the same three things, treating each substrate/state as a
**quasi-patron**.

### 4a. Extend the Prisma event vocab (UI + Papyrus, paired)
Add a small, reusable set so non-deity modes have first-class voice instead of
literal strings. Proposed additions to `eventLanguage` (app.js) + matching
`SendPrismaEventToast`-style emit on the Papyrus side:

- **`shift`** — a substrate/state-track transition (Khajiit focus, Argonian Hist
  posture, Orc life-mode, Redguard sect, Dunmer ancestor layer, Concordat, Bosmer
  path). Neutral tone, "mode" symbol. *"Your path turns toward &lt;state&gt;."*
- **`daedric`** — Prince boon/price/stigma. Reuses favor/neglect shape but with a
  Prince symbol + stigma framing (warning-leaning). Covers the 16-Prince slice.
- **`curse`** — vampire/werewolf onset, cure, exile, residue/scar. Warning tone.
  Replaces today's literal Nord/Altmer curse notices.
- **`rite`** — state-confirmation rite (Bosmer path settle is already literal; this
  templates it). Good tone.

`favor` / `tier` / `neglect` / `rivalry` stay as-is and are reused wherever a
non-deity mode has an analogous beat (e.g. Green Pact lapse = `neglect`).

### 4b. Give each non-deity mode a symbol identity
See `handoff/PrismaGlyph_DesignHandoff.md` Tier 3 (concept marks) + Tier 1 (Princes).
Then extend `GetPrismaSymbolForDeity()` (or a new `GetPrismaSymbolForMode()`) so the
manager can emit those names. Without symbols, every non-deity event renders the
generic `journal` mark and the modes blur together.

### 4c. Put substrate state into the panel as a quasi-patron
`PushDevotionPanel` already sends `patron`, `tier`, `piety`, `summary`. For races
with no scoring patron, populate those fields from the substrate (e.g. Argonian:
`patron = "The Hist"`, `symbol = "hist"`, `tierLabel = Hist posture`, summary from
`GetArgonianSurveyText()`), and use `relations[]`/`acts[]` for the secondary layers
(People, Void). The panel field shape already supports this — it's a Papyrus-only
change, no UI edit.

### 4d. Emit at the moment of change (the architectural fix)
Today substrate/state changes mostly write silent storage and are read back via
Survey/MCM. Add a `SendPrismaEventToast(...)` / `RequestPanelRefresh()` at each
state-track transition point (the `GetX...Label`/`SetState` sites already exist),
exactly as patron piety now does. This is the bulk of the work and is **Papyrus-only**
for everything except the new `eventLanguage` templates.

---

## 5. Suggested phasing

1. **Ship Tier-0 glyphs** (`yffre`, `zen`, `baan-dar`) — fixes a live Bosmer gap. UI-only.
2. **`curse` event** + curse glyphs — replaces literal curse notices across Nord/Altmer
   (and future races). High value, bounded.
3. **`shift` event** + Tier-3 concept glyphs + per-state emit — covers Khajiit,
   Argonian, Orc, Redguard, Dunmer, Imperial, Bosmer substrate continuity.
4. **`daedric` event** + Prince glyphs + scoring wiring — the 16-Prince slice (20C).
   Largest; do Hircine first as the template (already path-wired), then Molag Bal/
   Azura/Boethiah/Mephala (curse + Reclamation overlaps), then the rest.
5. **Panel quasi-patron population** for the no-patron races (Argonian first).

Each step is independently shippable and each keeps the **one-funnel** rule: the
manager emits a typed event; the UI owns the wording and the mark.

---

## 6. Out-of-scope confirmations

- SPID / SkyPatcher / new SKSE plugins are **not** surfacing tools — they distribute
  records. They don't help here; the surface stack in §1 is sufficient.
- No new in-game menu/tool is recommended. Adding one fragments the UX; the gap is
  funnel + symbols + templates, not a missing surface.
