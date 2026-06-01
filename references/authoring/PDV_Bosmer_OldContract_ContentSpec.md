# PDV Bosmer Old Contract — Content Spec (#4 Green Pact tagging, #5 Y'ffre reckoning)

**Status:** Content/data spec. The *logic* for both items is already runtime-proven in
Phase 9 (`PASS=808`: setup, path offers, Old Contract re-entry, PactBound/compliance
separation, forced-reckoning `Renounce` and `Recommit`, save/load). What remains is the
**data** (FormList contents) and the **authored copy** — not new systems.

**Authoritative model:** `references/PDV_BosmerPactModel_Planning.md` (ratified). Where the
race sheet and the Pact model disagree on specifics, the Pact model wins
(`PDV_BosmerPactModel_Planning.md:160-170`).

---

## #4 — Green Pact compliance tagging

The most significant custom data work on the Bosmer sheet
(`race-sheets/PDV_RaceDesign_Bosmer.md:229`). `GreenPactCompliance` (GPC) is a 0–100 meter,
no passive decay, meaningful only while `PactBound == true`. It needs to know which items
and acts are Pact-violating vs Pact-honoring.

### Detection model (LOCKED)

> Hybrid detection: **FormLists are authoritative; keyword fallback is a strict-mode opt-in
> only.** (`PDV_BosmerPactModel_Planning.md:53`)

So the deliverable is a set of curated FormLists, with keywords only as an optional
strict-mode widener. This keeps false positives controlled (the risk with blanket keyword
matching on `VendorItemFood`).

### FormLists to author

| FormList | Contents | Drives |
|----------|----------|--------|
| `PDV_FLST_GreenPact_ViolatingFood` | Plant-based ingestibles: vegetables, fruit, bread, soups/stews that are vegetable-based, and plant-derived drink (mead, ale, wine, Black-Briar, etc.) | GPC **down** on ingest |
| `PDV_FLST_GreenPact_ViolatingPotion` | ALCH potions whose effect derives from flora ingredients | GPC **down** on ingest |
| `PDV_FLST_GreenPact_ViolatingIngredient` | Flora alchemy ingredients (harvested plants/fungi used in alchemy) | GPC **down** on alchemy-craft |
| `PDV_FLST_GreenPact_HonoringFood` | Animal meat (raw and cooked), insect/egg/cheese edge cases curated explicitly | GPC **up** on ingest |
| `PDV_FLST_GreenPact_WoodAct` | Sawn-log / firewood items + woodworking recipe keywords (Hearthfire build mats) | GPC **down** on wood interaction (the hard one — `race-sheets/PDV_RaceDesign_Bosmer.md:80`) |

**Curation method (keeps it tractable):** seed the violating-food/ingredient lists with an
xEdit script that enumerates vanilla + DLC `ALCH` and `INGR` records, filtering by the
food keyword and by membership in vanilla flora ingredient lists, then **hand-review** the
output (the careful-curation requirement at `race-sheets/PDV_RaceDesign_Bosmer.md:73`).
Insects/fungi that "are not technically plant matter" are the known edge cases — resolve
each by hand into honoring vs violating, don't let the script guess.

### Detection hooks (existing infrastructure)

- **Ingestion:** the `PDV_PlayerEvents` alias already hooks `OnObjectEquipped`
  (`PDV_Architecture_v3.md:254`). For ingestibles, equip == consume. On equip of an ALCH:
  check the violating/honoring lists, route the GPC delta.
- **Alchemy craft of flora:** craft-complete event + ingredient-in-`ViolatingIngredient`.
- **Woodcutting / wood build:** detect the firewood/sawn-log item gain or the woodworking
  furniture/recipe keyword. (Lowest-confidence hook — acceptable to ship wood detection as
  build-recipe-only in 1.0 and widen later.)
- **Routing:** losses go through the proven `EVT_GREEN_PACT_VIOLATION` /
  `RouteGreenPactViolation` (RouteId `32`, Slice-1 proven). Gains use a honoring counterpart
  of the same shape.

### GPC deltas + bands (from Pact model)

Bands and Y'ffre multipliers are locked (`PDV_BosmerPactModel_Planning.md:55-62`):
Apostate 0–19 (0%, locked out) · Lapsed 20–49 (50%) · Observant 50–79 (100%) · Strict 80–100 (120%).
Losses are symmetric and band-graceful — Strict absorbs minor violations more gracefully;
Apostate cannot regain without first re-entering Lapsed (`:64-66`). Suggested per-act
magnitudes (tune in the Phase 4 signal matrix, the documented open item at `:174`):

- Eat violating food/potion: small GPC loss (e.g. −2), capped per day to avoid meal-spam swings.
- Alchemy on flora: small loss per craft session (daily-capped).
- Wood act: the hardest — small loss, but **only** on clearly devotional-violating contexts
  (deliberate woodcutting / homestead building), not incidental.
- Honoring food (meat): small GPC gain, daily-capped.
- Proper hunt conduct: handled by **kill events** (Cost Class A), not these lists.

### Anti-farm / guards

- Per-day caps on both gains and losses so a player can't grind meals to whipsaw GPC.
- All GPC tracking is inert while `PactBound == false` (frozen for record only —
  `PDV_BosmerPactModel_Planning.md:43`).

### #4 checklist

- [ ] Five FormLists authored + xEdit seed script + hand-review pass on edge cases.
- [ ] `OnObjectEquipped` ingest classifier (violating vs honoring) wired to route 32 / honoring counterpart.
- [ ] Alchemy-flora and wood-act hooks (wood may ship recipe-only for 1.0).
- [ ] Per-day caps; `PactBound` gate.
- [ ] Phase 4 signal-matrix rows updated with final magnitudes (closes the open item at planning `:174`).

---

## #5 — Y'ffre forced reckoning scene

**Mechanics are already proven** (Phase 9 covered forced-reckoning `Renounce` and
`Recommit`, plus the lifetime cap). The remaining work is **content**: the authored copy and
its presentation, plus confirming the day-counter trigger. This is non-voiced — consistent
with the §21.3 voiced-content non-goal — so it ships as a `MESG` MessageBox, not a scene
file.

### Trigger (confirm wired)

- GPC remains in the Apostate band (0–19) for **3 consecutive in-game days**
  (`PDV_BosmerPactModel_Planning.md:108`).
- Needs a running day-counter in the Apostate state that **resets** the moment GPC leaves
  Apostate (`race-sheets/PDV_RaceDesign_Bosmer.md:230`). Evaluate at **dawn**, consistent with
  the mod's other daily evaluations.
- One-shot per Apostate dwell. No silent auto-renounce — the decision is always surfaced
  (`PDV_BosmerPactModel_Planning.md:115`).

### Presentation (the authored content)

A two-button `MESG` in Y'ffre's voice — must "feel like Y'ffre actually confronting you, not
a generic popup" (`race-sheets/PDV_RaceDesign_Bosmer.md:230`).

Ratified prompt copy (`PDV_BosmerPactModel_Planning.md:110`):

> *"You have lived against the Pact. Re-commit, or be cast from Y'ffre's song."*

Buttons: **[Re-commit]** · **[Renounce]**

### Outcomes (proven branches — author the copy, don't rebuild the logic)

| Choice | Effect | Confirm copy |
|--------|--------|--------------|
| Re-commit | `GPC` snaps to **30** (Lapsed); `PactBound` stays true; `LapsedFromPact` unchanged (`:112-113`) | "The song holds you a while longer. Do not test it again." |
| Renounce (first) | Standard exit; Y'ffre ledger frozen (not zeroed); other Bosmer deities unfreeze; `LapsedFromPact++` (`:117-124`) | "You step out of the song. The forest will remember the shape of your leaving." |

### Terminal-state rewrite (LOCKED)

If `LapsedFromPact == 1` at the moment of this reckoning, **both** the prompt and the
renounce confirmation must rewrite to make finality explicit
(`PDV_BosmerPactModel_Planning.md:149-158`):

> *"This will end your bond with Y'ffre. You will not be able to return."*

On that terminal renounce: Y'ffre ledger frozen **permanently** (read-only historical value
in the status screen), `LapsedFromPact → 2`, the MCM `Take the Green Pact` toggle disables
with tooltip *"Y'ffre's song no longer answers you."* The cap closes the Pact, not the
pantheon — other Bosmer-recognized deities stay available (`:135-147`).

### #5 checklist

- [ ] Confirm the dawn Apostate day-counter (increment in Apostate, reset on band-exit, fire at 3).
- [ ] Author the `MESG` records: standard prompt, terminal-rewrite prompt, two confirm strings, terminal-renounce confirm.
- [ ] Verify the proven Recommit/Renounce branches consume the new copy and the `LapsedFromPact` gate selects standard vs terminal text.
- [ ] Status-screen read-only "frozen Y'ffre devotion" line for the terminal state.
