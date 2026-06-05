# Prisma Substrate Equity & Instruments — Design Draft (for review)

**Date:** 2026-06-04
**Status:** DRAFT FOR DISCUSSION — not a final handoff. Resolves both questions from
`references/authoring/PDV_PrismaUXEquityAudit.md`:
- **Q1 (equity):** substrate races get a structurally thinner Prisma experience (dead piety meter,
  no reactive toast stream).
- **Q2 (creative):** bespoke, possibly always-on instruments (Khajiit moons, Hist tree, etc.).

**Thesis:** these are one problem. The reason substrate races feel empty is that the panel is built
around *one* instrument — the piety bar — that only patron races can fill, and the reactive toast
stream is deity-keyed. **Fix the model, not the symptom:** make "the hero instrument" and "the
devotional pulse" *pluggable per race*, then the creative instruments (Q2) become the very thing that
restores equity (Q1). Everything below is additive to the existing payloads (no field removed/renamed).

---

## The three pillars

| Pillar | Resolves | One-line |
|---|---|---|
| **1. Devotional Instrument model** | Q1 (dead meter) + Q2 (visuals) | The panel "hero slot" renders a typed instrument; piety bar is just `kind:"piety"`, the moons are `kind:"lunar"`, etc. |
| **2. Substrate pulse (event stream)** | Q1 (no reactive toasts) | A new `substrate` typed event so substrate *acts* produce reactive toasts, the way `favor`/`tier`/`neglect` do for patrons. |
| **3. Ambient surface** | Q2 (always-on) | An optional persistent overlay (`mode:"ambient"`) that floats the race's instrument on the HUD — the "always-on moon dial." |

Pillars 1+2 make every race equally *alive*. Pillar 3 is the creative flourish on top. They share one
renderer, so the work compounds rather than multiplies.

---

## Pillar 1 — The Devotional Instrument model

### Problem
`PushDevotionPanel` builds the panel around `piety` (a 0–200 float toward `_activeDeity`) + `tier`.
Substrate races have no such float, so the bar is dead and their real state is crushed into one
`tierLabel` string.

### Design
Add one **additive** object to the panel payload — `instrument` — that the UI renders into the hero
slot (where the piety bar lives today). The UI keeps an **instrument renderer registry** keyed by
`kind`, exactly mirroring how `symbolSpecs` and `eventLanguage` are registries. New instrument = new
entry; nothing existing churns.

```jsonc
// added to the PushDevotionPanel JSON
"instrument": {
  "kind": "piety" | "lunar" | "hist" | "ancestor" | "forge" | "sects" | "branch",
  "tier": 0,                 // universal 0–3 progression so EVERY race has a sense of advancement
  "tierLabel": "Devoted",    // human label
  "primary": 0.0,            // 0..1 main fill/intensity (piety/150 for patrons; tier-progress for substrates)
  "state": "Waxing • Azurah",// short race-specific state line
  "data": { /* race-specific structured fields — see per-race specs */ }
}
```

- **Patron races:** `kind:"piety"`, `primary = piety/150`, `data:{pietyToday,...}` → renders today's bar
  unchanged. (Phase 0 ships this with *zero* visual change — it proves the refactor.)
- **Substrate races:** `kind` = the race instrument, `data` = its bindings.

### Why a universal `tier` matters
Patron races get a felt sense of *climbing* (Seeker→Devoted→Champion). Substrate races today have named
states but no ladder. Most already compute a 0–3 substrate tier (`GetKhajiitLunarTierLabel`,
`GetSubstrateTier` on the ancestor/lunar substrates) — surfacing it as the instrument `tier` gives every
race a shared progression spine without inventing new scoring.

### UI shape
`render()` in `app.js` dispatches the hero slot to `instrumentRenderers[instrument.kind] ?? renderPietyBar`.
Each renderer is an SVG/CSS function (same family as `symbolSpecs`). Frozen-file rule applies → this is a
design now, code via a later handoff.

---

## Pillar 2 — The Substrate Pulse (reactive event stream)

### Problem
`favor` (per act), `tier` (deepen), `neglect` (thin), `rivalry` are all deity-keyed — they need an
active `PDV_DeityBase`. Substrate acts (moon observance, Hist maintenance, ancestor prayer) fire **no
toast at all**, so substrate play feels unacknowledged. This — not the visuals — is the heart of the
equity gap.

### Design
A new `substrate` typed event, reusing the existing funnel (`normalizeToastPayload` →
`resolveEventPayload` → `eventLanguage`) exactly as `shift`/`daedric`/`curse` do. Papyrus gets a
`SendPrismaSubstrateToast(substrate, phase, context, symbol, state)` helper paralleling
`SendPrismaShiftToast`.

```jsonc
{"mode":"toast","toast":{
  "event":   "substrate",
  "substrate":"lunar"|"hist"|"ancestor"|"stronghold"|"sect",
  "phase":   "act" | "deepen" | "thin",
  "symbol":  "lunar"|"hist"|"ancestor"|"malacath"|"journal",
  "context": "<race-aware phrase, may be empty>",
  "state":   "<current state label, e.g. 'Lattice: steady'>"
}}
```

| phase | meaning | parallels | tone |
|---|---|---|---|
| `act` | a contributing substrate act registered | `favor` | good (throttled — see anti-spam) |
| `deepen` | substrate tier increased | `tier` | good |
| `thin` | substrate weakened/decayed | `neglect` | warning |

`eventLanguage.substrate` owns the voice, keyed on `substrate`+`phase` (e.g. lunar/act → "The moons
marked your road-rest."; hist/thin → "The Hist's hold on you thins."). Per-substrate flavor lives in the
UI, not Papyrus — consistent with "the UI owns the voice."

### Papyrus emit sites (already inventoried — wiring points are known)
- **Khajiit:** `ObserveMoonPhaseScaled` (1331), `RecordRoadHomeCadenceScaled` (1360) → `act`; lunar tier
  rise → `deepen`.
- **Argonian:** `RecordHistMaintenanceScaled` (1398), `RecordPeopleSupportScaled` (1412),
  `RecordBedOfChoiceReturnScaled` (1423), `RecordVoidSignalScaled` (1434) → `act`; `ProcessHistDistanceDawn`
  thinning → `thin`.
- **Dunmer:** `RecordPortableShrinePrayerScaled` (1308), `RecordPlayerHomeBonusScaled` (1316) → `act`;
  depth tier rise → `deepen`.
- **Orc/Redguard:** life-mode / sect acts → `act`; mode change already covered by `shift`.

### Anti-spam (carry the favor pattern)
`act` toasts must be throttled like contextual favor (`ConsumeDailyRepeatMultiplier`, family cooldowns)
or they nag. `deepen`/`thin` are rare and always surface. **Open question:** default chattiness — see
Decision 3.

### Relationship to `shift`
`shift` already fires on *named-mode transitions* (Khajiit focus change, Orc life-mode change). `substrate`
is the *ongoing pulse* (acts + deepen/thin). They complement: `shift` = "your mode changed" (rare),
`substrate` = "your devotion moved" (the stream). **Could be unified** into one event with more phases —
see Decision 4.

---

## Pillar 3 — The Ambient surface (always-on)

### Problem
Toasts auto-dismiss; an instrument like the moons should *persist*. The panel is opened on demand.

### Design — three feasibility tiers (pick during review)
- **A — Panel-resident only:** the instrument lives in the panel hero slot; seen when the player opens
  the devotion panel. Lowest effort, no new channel, no always-on.
- **B — Persistent ambient overlay (`mode:"ambient"`):** a new additive payload mode renders a small,
  **non-dismissing** widget in a screen corner (separate DOM region from the transient toast stack).
  Papyrus pushes ambient state on a cadence (the existing `OnUpdate` + dirty-flag pattern). This is the
  "always-on moon dial."
- **C — Hybrid (recommended):** build the instrument once (Pillar 1) so the *same* renderer drives both
  the panel hero slot and an optional ambient overlay, gated by an MCM toggle. Player chooses whether the
  moons float on their HUD; default off or low-opacity.

```jsonc
// Pillar 3B/C payload — additive new mode
{"mode":"ambient","ambient":{
  "kind":"lunar", "visible":true, "opacity":0.85,
  "instrument": { /* same instrument object as Pillar 1 */ }
}}
```

### Key feasibility unknown (needs a spike)
Does PrismaUI support a **persistent, always-visible view** distinct from the toast overlay, including
sane behavior in menus/loading/combat? The toast overlay is transient by design. This is the one true
unknown in the whole draft — flag for a short technical spike before committing to B/C. If PrismaUI
can't hold a persistent view cheaply, we ship A now and revisit ambient later.

---

## Per-race instrument specs (Q2 content, with data bindings)

Each spec: the `kind`, the `data` bindings (all from functions that **already exist**), the visual, and
the substrate-pulse mapping.

### 🌑 Khajiit — `lunar` (flagship)
- **data:** `{ phase: GetKhajiitMoonPhaseFromGameDay(now) (1–8), focus: GetKhajiitFocusLabel/…edEmphasis,
  focusWeight, secondFocusWeight, lunarTier: GetKhajiitLunarTierLabel, roadHome: GetRoadHomeCount,
  observed: GetLastObservedPhase }`
- **visual:** twin moons — **Masser** (large) + **Secunda** (small) at the current phase; active focus as
  a sigil that brightens with its weight; lunar tier = glow; an observance pulse on sleep-under-sky.
  *(Vanilla Skyrim's moons share a phase cycle — render both at `phase`, optionally offset Secunda a step
  for depth.)*
- **pulse:** moon observance / road-home → `substrate/lunar/act`; lattice tier up → `deepen`.
- **forms (decide in build):** corner crescent-pair HUD · full-panel orrery · 8-phase lattice strip with
  current lit · focus glyph rising/setting with the moons across the day.

### 🌳 Argonian — `hist`
- **data:** `{ hist: GetHistRelation, people: GetPeopleRelation, void: GetVoidRelation,
  form: GetSubstrateForm, voidActive: IsVoidFullyActive, posture: GetHistPostureLabel }`
- **visual:** a Hist tree — roots=Hist, canopy/leaves=People, creeping shadow=Void; posture=vitality;
  void-fully-active = inverted/silhouetted tree. Sap-glow on maintenance.
- **pulse:** maintenance/people/bed-return/void acts → `act`; Hist-distance dawn thinning → `thin`.

### 🏺 Dunmer — `ancestor`  *(most under-served race — priority to fix)*
- **data:** `{ depthTier: GetSubstrateTier, prayer: GetPrayerCount, home: GetHomeBonusCount,
  reclamation: GetDunmerReclamationFocusLabel, cursePosture: GetDunmerCursePostureLabel }`
- **visual:** an ancestral niche — **masks light one by one with depth**; drifting ash motes whose density
  = recent prayer; Reclamation focus as a tri-fold sigil leaning to the favored Good Daedra.
- **pulse:** ash-prayer / home rite → `act`; depth tier up → `deepen`. *(Gives Dunmer their first toasts.)*

### 🔥 Orc — `forge`
- **data:** `{ lifeMode: GetOrcLifeModeLabel }` (+ Malacath if/when scored)
- **visual:** a forge whose fire-color reflects life-mode (hearth-bright Stronghold → banked City → cold
  Exile); anvil = Malacath mark; banner frays in exile.
- **pulse:** life-mode acts → `act`; mode change already `shift`.

### ⚔️ Redguard — `sects`
- **data:** `{ sect: GetRedguardSectLabel }` (+ Far Shores/ancestor spine)
- **visual:** three crossed-blade sigils, active sect lit; Walkabout/Far Shores as a star-path advanced
  along; Ash'abah = shrouded, set-apart blade.
- **pulse:** sect acts → `act`; sect change already `shift`.

### 🌿 Bosmer — `branch` *(polish only — already best-served)*
- **data:** `{ path: GetBosmerPathLabel, evidenceDays: GetRecentEvidenceDayCount, pactBound }`
- **visual:** a bound branch tightening under Old Contract; **evidence days as growth rings**; pending
  offer as a bud about to break.

---

## Phasing (so value lands early and the unknown is de-risked)

| Phase | Deliverable | Notes |
|---|---|---|
| **0** | Instrument model: payload `instrument` block + UI renderer registry, `kind:"piety"` reproducing today's bar | Zero visual change; proves the refactor; unblocks all instruments |
| **1** | Khajiit `lunar` instrument (panel-resident) + `substrate` event + `eventLanguage.substrate` | Flagship; data fully ready |
| **2** | Ambient spike → if green, `mode:"ambient"` with lunar as pilot | The one feasibility unknown lives here |
| **3** | Dunmer `ancestor` + Argonian `hist` instruments + their pulses | Fixes the worst gaps |
| **4** | Orc `forge`, Redguard `sects`; Bosmer `branch` polish | Simpler; pattern proven |

Each phase is two-sided (Papyrus push + UI render) and ships behind the frozen-file handoff process.

---

## Open decisions (let's talk these through)

1. **Universal instrument, or substrate-only?** Recommend universal (patron = `kind:"piety"`) so the panel
   has one coherent model. Alternative: leave patron races exactly as-is and only add instruments for
   substrate races (less refactor, two code paths).
2. **Universal 0–3 tier for substrates?** Recommend yes (shared progression spine). Risk: forcing a ladder
   onto states that are cyclical (moons) rather than cumulative.
3. **Pulse chattiness.** How often should `act` toasts fire? Recommend conservative (≈favor cadence, daily-
   capped) to avoid nagging — but substrate races currently get *nothing*, so we have headroom.
4. **Unify `shift` into `substrate`?** Keep separate (clear: shift=mode change, substrate=pulse) vs. fold
   into one event with phases `act/deepen/thin/shift`. Fewer event types vs. clearer semantics.
5. **Always-on appetite (Pillar 3 A/B/C).** Panel-only, persistent HUD, or opt-in hybrid? Immersion vs.
   screen clutter vs. effort + the PrismaUI persistence unknown.
6. **Scope/appetite.** Is this a 1.0 push (at least Phase 0–1) or a 2.0 arc? Phase 0 alone is low-risk and
   makes the panel honest for substrate races even before any new art.
7. **Gameplay tie-in (optional depth).** Should instruments be purely informational, or also reflect/grant
   real effects (e.g. Khajiit moon-phase nudging furstock-flavored buffs)? Out of scope for the UI draft,
   but worth a yes/no on intent.

---

## Decisions locked (2026-06-04 review)

1. **Architecture → Universal model.** Every race uses the instrument slot; the piety bar becomes
   `kind:"piety"`. Phase 0 reproduces today's bar with no visual change.
2. **Universal 0–3 tier → yes**, but cyclical instruments (moons) treat `tier` as *depth/strength*, not a
   linear ladder — the lunar `primary` reflects the substrate strength, the moon phase is its own field.
3. **Pulse chattiness → conservative** (≈favor cadence, daily-capped via `ConsumeDailyRepeatMultiplier`).
4. **`shift` vs `substrate` → keep separate.** `shift` = named-mode change (already wired); `substrate` =
   ongoing pulse (`act`/`deepen`/`thin`).
5. **Always-on → hybrid opt-in now, with headroom to escalate to always-on HUD** once the native layer
   lands (see spike).
6. **Scope → proceed on all three** (refine design + start Phase 0 + the ambient feasibility spike).
7. **Gameplay tie-in → out of scope** for this UI arc (revisit later).

## Spike result — ambient/always-on feasibility: ✅ GREEN (lighter than expected)

Read of `native/DevotionPrismaBridge/include/prisma/PrismaUI_API.h` + `src/main.cpp` + `PDV_PrismaBridge.psc`:

- PrismaUI **decouples focus from visibility** (`Show`/`Hide` vs `Focus`/`Unfocus`), supports `SetOrder`
  (layering) and `InteropCall` (cheap data push). A view can be **visible-but-unfocused** = on-screen,
  no input capture, **no game pause**.
- The bridge **already uses this**: `SendOverlayJson` does `Show(g_view)` *unfocused* then pushes the
  toast. So the persistent, transparent, unfocused HUD layer **already exists and is in use** — toasts
  are the proof of concept. The panel is the same `g_view`, focused + `pauseGame=true`.
- **Therefore an always-on ambient widget needs no new rendering tech** — it needs the view kept
  shown-unfocused independent of panel open/close. Today `CloseDevotionPanel` calls `Hide(g_view)`,
  and the view starts hidden, so the one gap is *lifecycle*: keep an ambient layer shown when the panel
  is closed.
- **This gap is native C++** (`src/main.cpp`, built with `xmake`/CommonLibSSE) — a different toolchain
  from Papyrus (CK) and JS (text). It is the cleanest piece to delegate.

## Work split (who does what)

| Track | Work | Owner | Phase |
|---|---|---|---|
| **UI/JS** | `eventLanguage.substrate` + instrument renderer registry in `app.js` (+ index.html slot) | **Claude (this branch)** | 0–1 |
| **Papyrus** | `instrument` block in `PushDevotionPanel`; `SendPrismaSubstrateToast` + emit wiring | **Codex** (owns live `PDV__ManagerQuest.psc`) | 0–1 |
| **Native C++** | Ambient layer lifecycle (keep view shown-unfocused; `SetAmbientVisible`/`SendAmbientJson`) | **Codex** (owns `src/main.cpp` + build) | 2 |

→ Codex tracks captured in `handoff/PDV_PrismaSubstrate_CodexHandoff.md`.
→ Claude UI track captured in `handoff/PrismaInstrument_UIHandoff.md`.

_This is a draft for discussion. Design locked above; implementation split per the table._
