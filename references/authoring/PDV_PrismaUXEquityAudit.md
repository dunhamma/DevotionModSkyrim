# Prisma UX Equity & Creative Expansion Audit

**Date:** 2026-06-04
**Status:** AUDIT + design exploration. No implementation. Flagship concepts here can graduate
to their own design handoffs (the way the medallion audit spawned `PrismaMedallionRoster_DesignHandoff.md`).
**Question 1:** Does each race get an equally immersive Prisma experience — or do the races whose
framework isn't a focused divine-patron or Daedric-worship lane (the *substrate* races) get less to
see and feel?
**Question 2:** Where could we expand creatively with Prisma (or other UI) — e.g. an always-on,
visually rich Khajiit moon-cycle tracker — and what's the equivalent for each substrate race?

**Short answer to Q1:** Yes, there's a real and structural inequity — and it's *worse* than "less
material." The whole Prisma surface is built around a metric (piety toward a named patron) that is
**null for substrate races**, so their panel reads as empty/waiting rather than alive, and they miss
the entire `favor`/`tier`/`neglect`/`rivalry` toast stream. The irony: substrate races carry *more*
underlying state than patron races — it's just collapsed into a single label string.

---

## Part 1 — Equity audit

### The "immersion budget" lens

Immersion budget = how much **distinct, evolving, visible** devotional material a player of a given
race encounters through Prisma over a play session. Three ingredients:
1. **A live metric** — something that visibly moves (the piety bar, a tier).
2. **An event stream** — toasts that fire as you play and react to what you did.
3. **A distinct identity** — a symbol/title/voice that feels like *this* race's faith.

### Two classes of race emerge

| | **Patron-stream races** | **Substrate races** |
|---|---|---|
| Races | Nord, Imperial, Breton, Altmer, Bosmer*(when a path/patron is named)* | Dunmer, Khajiit, Argonian, Orc, Redguard |
| Live metric | ✅ piety bar animates, tier climbs | ❌ piety bar pinned (no single scoring float) |
| `favor` toast (per act) | ✅ with the god's glyph | ❌ deity-keyed; never fires |
| `tier` / `neglect` / `rivalry` | ✅ | ❌ all deity-keyed |
| `dawn` | ✅ | ✅ (shared) |
| `shift` (mode transition) | n/a | ◐ Khajiit/Argonian/Orc/Redguard/Bosmer only — **Dunmer gets none** |
| `daedric` / `curse` | ✅ if werewolf/vampire | ✅ if werewolf/vampire |
| Panel identity | the god (name + glyph + meter) | a substrate **label string** ("Hist: Strained", "Lunar Lattice", "Ancestor layer: steady") |

\* Bosmer straddles: it has a substrate-style path track *and* names a deity patron (Y'ffre/Z'en/Baan
Dar), so it gets both the path `shift` toasts and the patron stream. It is the best-served "substrate"
race precisely because it was given a named patron on top.

### Root cause (code-level)

- `favor` (2765, 3099), `tier` (2222), `neglect` (2422), `rivalry` (6610) all call
  `SendPrismaEventToast(..., PDV_DeityBase deity, ...)` — they **require an active deity**. A race
  worshipping through a substrate has no `_activeDeity`, so none of these can fire.
- `PushDevotionPanel` (579): when there's no `_activeDeity`, `piety` has no per-deity value to show —
  the panel's centerpiece meter is dead, and the race's real state is squeezed into `tierLabelOverride`
  (one line of text).

### The irony: substrate races have *more* dormant state

Far from being "simpler," substrate races compute richer state than patron races — almost none of it
surfaced. From `PDV__ManagerQuest.psc`:

| Race | Dormant state already computed | What Prisma shows of it |
|---|---|---|
| **Khajiit** | `GetKhajiitMoonPhaseFromGameDay` (8-phase, 28-day lunar cycle); 5-way focus (Khenarthi/Azurah/Baan Dar/Rajhin/Alkosh) with weights + second focus; `GetSubstrateTier`; `GetRoadHomeCount`; `GetLastObservedPhase` | one label: "Lunar Lattice" / "Focused: X" |
| **Argonian** | `GetHistRelation`, `GetPeopleRelation`, `GetVoidRelation` (3 axes); `GetSubstrateForm`; `IsVoidFullyActive`; posture | one label: "Hist: <posture>" |
| **Dunmer** | ancestor `GetSubstrateTier`, `GetPrayerCount`, `GetHomeBonusCount`, `GetDunmerReclamationFocusLabel`, curse posture | one label: "Ancestor layer: <depth>" (+ **no toasts at all**) |
| **Breton** | `GetBretonKnightlyVowLabel`, `GetBretonWitchcraftExposureLabel`, `GetBretonDruidicStandingLabel`, curse posture (4 sub-tracks) | one label: tradition |
| **Orc** | life-mode (Stronghold/City/Legion-Exile) | one label + shift toast |
| **Redguard** | sect (Crown/Forebear/Ash'abah); Far Shores/ancestor spine | one label + shift toast |

### Verdict

The concern is correct and **understated**. Substrate races don't merely receive fewer toasts — they
are shown a UI whose primary instrument (the piety meter) is meaningless for them, and they are cut out
of the reactive event stream that makes the patron experience feel alive. **Dunmer are the most
under-served**: a substrate race that doesn't even get the `shift` transition toast, so a Dunmer player
sees essentially a static label and the shared `dawn`/`curse` events.

The fix is **not** "bolt more toasts onto substrate races." It's to give each substrate its own *native
instrument* — a visual that expresses its mechanic the way the piety bar expresses a patron. The data
is already there; only the surface is missing. That is exactly what Part 2 explores.

---

## Part 2 — Creative expansion: substrate-native Prisma instruments

### Design principle

Every substrate race should get a **bespoke, ambient instrument** — ideally always-on or panel-resident
— that turns its dormant state into a living visual. Where the patron races have a piety bar that fills,
the substrate races get an instrument that *breathes* with their mechanic. Crucially, **the feeding data
already exists in Papyrus** for all of these; the work is a render surface + a state-push cadence.

### 🌑 Flagship — Khajiit: the Lunar Lattice (moon-cycle tracker)

The strongest candidate, and the one you flagged. Khajiit identity *is* the moons (ja-Kha'jay): furstock
is set by Masser and Secunda. We already compute an 8-phase, 28-day cycle from game time.

- **Data ready:** `GetKhajiitMoonPhaseFromGameDay(gameTime)` → phase 1–8; focus (5-way) + weights;
  `GetKhajiitLunarTierLabel` (quiet/beginning/steady/strong); `GetRoadHomeCount`; last observed phase.
- **Visual:** twin moons (Masser large, Secunda small) rendered at their current phase, always present in
  a corner; the **active focus** shown as a sigil/constellation that waxes with its weight; lunar tier as
  the moons' **glow intensity**; an observance "pulse" when you sleep under the sky (the existing
  `HandleKhajiitMoonObservance` hook).
- **Forms it could take** (pick during design): a minimal corner crescent-pair HUD; a full-panel
  **orrery**; a horizontal "lattice" of the 8 phases with the current one lit; the focus deity's glyph
  *rising and setting* with the moons across the in-game day.
- **Always-on feasibility:** high — phase is pure game-time math, no scoring needed; update on a timer.

### 🌳 Argonian: the Hist (living tree / sap-flow)

Three relation axes + form is begging for a non-linear visual.

- **Data ready:** `GetHistRelation` / `GetPeopleRelation` / `GetVoidRelation`, `GetSubstrateForm`,
  `IsVoidFullyActive`, posture.
- **Visual:** a Hist tree whose **roots** = Hist relation, **canopy/leaves** = People relation, and a
  creeping **shadow/rot** = Void relation; posture = overall vitality; "Void fully active" = the tree
  silhouetted/inverted. Sap-glow pulses on maintenance acts.
- **Forms:** a three-pronged rooted gauge; a tree that gains/sheds leaves; a sap meter that rises.

### 🏺 Dunmer: the Ancestors (ash, urns, masks)

The most under-served race — highest priority to *fix*, even if the instrument is modest.

- **Data ready:** ancestor depth tier, prayer count, home-bonus count, Reclamation focus
  (Azura/Boethiah/Mephala), curse posture.
- **Visual:** an ancestral niche/altar that accrues — **ancestor masks** lighting one by one with depth;
  drifting **ash motes** whose density = recent prayer; the Reclamation focus as a tri-fold sigil that
  leans toward the favored Good Daedra.
- **Forms:** a vertical "lineage" of masks; an ash-urn that fills; a House-sigil that sharpens with depth.

### 🔥 Orc: the Stronghold Code (forge / banner)

- **Data ready:** life-mode (Stronghold/City/Legion-Exile), Malacath.
- **Visual:** a forge whose fire-color reflects life-mode (hearth-bright Stronghold → banked City →
  cold Exile); Malacath's tusk/hammer as the anvil mark; the code as a banner that frays in exile.
- **Forms:** a forge-glow strip; a three-state banner; an anvil that rings (pulse) on Malacath acts.

### ⚔️ Redguard: the Sword-Sects (Crown / Forebear / Ash'abah)

- **Data ready:** sect, Far Shores/ancestor spine.
- **Visual:** three crossed-blade sigils, the active sect lit; the **Walkabout / Far Shores** as a star-
  path the player advances along; Ash'abah shown as the shrouded, set-apart blade.
- **Forms:** a sect crest; a star-road progress line; a blade that sheathes/draws by stance.

### 🌿 Bosmer: the Green Pact (bound branch) — lower priority, already best-served

- **Data ready:** path state (4), evidence days, pact-bound flag.
- **Visual:** a bound branch that tightens under the Old Contract and loosens off it; **evidence days as
  growth rings**; the offered/pending transition as a bud about to break.
- Already has `shift` toasts + a named patron, so this is polish, not a gap.

### Cross-cutting idea: a panel "instrument slot"

Rather than ten one-off surfaces, design **one slot** in the panel that, for substrate races, replaces the
dead piety meter with the race's instrument (and for patron races stays the piety bar). One container,
race-swappable contents — keeps the panel coherent and the work bounded.

---

## Part 3 — Technical feasibility (Prisma + alternatives)

- **Two channels exist:** `PDV_PrismaBridge.SendJson` (panel) and `SendOverlayJson` (overlay/toasts).
  The panel already uses a dirty-flag + `OnUpdate` flush (`RequestPanelRefresh`) — a natural cadence for
  pushing instrument state.
- **Always-on** is the open technical question. Toasts auto-dismiss; an ambient widget must *persist*.
  Options to evaluate in design:
  1. A **persistent overlay element** via a new additive payload `mode` (e.g. `"ambient"`) that renders a
     non-dismissing DOM region (vs. the transient toast stack).
  2. An **always-open panel widget** if PrismaUI supports a pinned/HUD view.
  3. Push state on a throttled timer (game-time tick) so the moons/tree update without spam.
- **Art:** the existing `symbolSpecs` SVG line-art system covers moons, trees, forges, blades in-style;
  richer motion is CSS animation. No new art pipeline required for a first pass.
- **Non-Prisma alternatives** (note for completeness): SkyUI widgets / a HUD mod framework could host an
  always-on moon dial, but that fragments the experience across two UIs — prefer keeping it in Prisma for
  voice/visual coherence unless a hard constraint forces otherwise.

### Constraints to carry
- Each instrument is **two-sided**: Papyrus (push state on cadence) + UI (render). New always-on surfaces
  likely need a new payload `mode` — **additive only** (never remove/rename existing fields).
- `app.js` / `index.html` / `styles.css` are **frozen** — design first, code via an explicit handoff.
- Do **not** touch `PDV_PrismaBridge` or the `ReceivePDVJson` / `ReceivePDVOverlayJson` entry points.

---

## Part 4 — Recommended sequencing

1. **Khajiit Lunar Lattice** — flagship; data fully ready; highest visual payoff; you requested it.
   Graduate to its own design handoff first (it will define the always-on `mode` the others reuse).
2. **Dunmer Ancestors** — fixes the most under-served race; depth label already added this session.
3. **Argonian Hist** — richest dormant data (3 axes); best showcase for a non-linear instrument.
4. **Panel "instrument slot"** — the unifying container; design alongside #1 so the rest slot in.
5. **Orc / Redguard** — simpler, mode-based; lower lift, lower dynamism; do after the pattern is proven.
6. **Bosmer** — polish only.

_This document is an audit + exploration. No code or UI was changed to produce it._
