# PDV Medallion-Roster Chooser — UX Design Spec (L3d)

**For:** the eventual L4c build (Codex Papyrus payload + UI renderer). **From:** Claude.
**Status:** DESIGN ONLY — resolves the 7 open questions in
`handoff/PrismaMedallionRoster_DesignHandoff.md`. Code + glyph install are deferred to L4
(glyph-hungry; `app.js` frozen). Data authority = `PDV_MedallionDeityCoverageAudit.md`
(per-race roster + stance) and `PDV_DeityCoverageMatrix.json` (61 locked worship objects).

The chooser is the missing surface that shows a race **its full choosable roster** and lets
it commit a patron. It is a close cousin of the startup modal and reuses that renderer.

---

## Q1 — Surface model: new `mode:"medallion"`, additive to the startup contract

The startup payload is a flat `options[]`; a roster needs **per-tier sections**, so define a
new `mode:"medallion"` that the existing `renderStartup()` machinery (option buttons,
active state, details pane, advisory, confirm) is extended to render. **Keep all existing
startup fields; only add new ones.**

```json
{
  "mode": "medallion",
  "medallion": {
    "race_id": "nord",
    "active_option_id": "kyne",          // current patron, or "broad" / "" if none
    "title": "Choose your devotion",
    "summary": "Whom will you keep above the rest?",
    "advisory_line": "Deepest devotion asks one god become your own.",
    "confirm_required": true,
    "sections": [
      { "tier": "native",  "label": "Your gods",            "options": [ ... ] },
      { "tier": "focus",   "label": "Within the Lattice",   "options": [ ... ] },  // substrate races
      { "tier": "foreign", "label": "Foreign, at a cost",   "options": [ ... ] },
      { "tier": "curse",   "label": "By curse only",        "options": [ ... ] }
    ]
  }
}
```
Each `option` extends the startup option with: `symbol` (glyph key), `kind:"god"|"prince"|
"focus"|"substrate"`, `accessTier` (`native|foreign|curse|taboo`), `devState` (the L3c
standing token; usually `""` until chosen), and `cost_line` (consequence text for confirm).

## Q2 — How much to show: native + curse-access + a curated foreign-with-cost subset

Showing all 45+16 per race is noise. Per race, surface:
- **Native** lane — always (the core).
- **Curse-access** — Hircine / Molag Bal, shown per Q4 (conditional).
- **Foreign-with-cost** — a **curated** subset of the meaningful Foreign entries for that
  race (the ones a player realistically chooses, e.g. the `Legible`/`Tolerated` Princes
  from `PDV_DaedricRacePrinceMatrix.csv`), NOT the whole Foreign tail.
- **Hostile / Taboo** — **omitted by default**; surfaced only as a collapsed "forbidden"
  note if already relevant (a curse active, or a quest exposed it). Never a normal button.

Result: each race view is ~5-15 entries, not 61.

## Q3 — Substrate races: a focus-picker over the substrate, not a flat list

Two view shapes, unified by the `sections` model:
- **Deity-pantheon races** (Nord, Imperial, Breton, Altmer, Bosmer): a `native` section of
  individually-selectable gods (a genuine multi-deity chooser).
- **Substrate races** (Dunmer, Khajiit, Argonian, Orc, Redguard): a `substrate` section
  (the always-on frame — House Ancestors / Lunar Lattice / Hist / forge life-mode / Yokudan
  sect; `kind:"substrate"`, non-selectable, shows the substrate glyph + standing) **plus** a
  `focus` section of foci the player can emphasize within it (Reclamation / lunar focus /
  sect path). The focus is what gets "chosen"; it layers on the substrate rather than
  replacing it. This matches the locked substrate designs — the substrate gods are NOT
  individually matrix-scored (see L1 scope), so they appear as **foci**, not patrons.

## Q4 — Curse-access Princes (Hircine, Molag Bal): reflected read-only, never offered

They are not free picks. In the `curse` section they render **locked** (blue rim + lock
badge, L3c) with a one-line "arrives by curse" note, and are **non-selectable** while no
curse is active. When the matching curse IS active (werewolf→Hircine, vampire→Molag Bal),
the entry switches to an active/available read-only reflection of that path's standing — it
shows the player where they stand, but commitment is still driven by the curse, not the
button. Omit them entirely for races where they are Taboo/Hostile rather than Curse.

## Q5 — Cost/stance legibility: rim/badge + advisory + a consequence confirm

Layered, reusing L3c's separate access channel so color-state is never overloaded:
- **At-a-glance:** the access rim/badge (native gold / foreign muted+"cost" / curse blue+
  lock / taboo red+"forbidden").
- **On focus:** the details pane shows the stance plainly ("Worshipping <god> as a <race>
  is tolerated, at a cost to standing among your own.").
- **On commit:** a **confirm step with `cost_line`** consequence text for any non-native
  pick; native picks confirm cleanly with no warning.

## Q6 — Interaction: select + confirm; active = standing color; switch = "turn of the heart"

- **Select + confirm**, not browse-only (this is a commitment surface). Reuse the startup
  confirm flow.
- **Active patron** indicated by the existing active-option styling **plus** its real L3c
  standing color on the glyph fill (the one place in the chooser fill encodes state).
- **Switching** patrons: selecting a new option confirms with a "turn of the heart" note —
  committing or switching is meaningful, not a menu toggle (echoes
  `STARTUP_ADVISORY_TEXT`). **Renouncing** returns to broad worship (`active_option_id:
  "broad"`); offer a "Keep no single god" option in the native section.

## Q7 — Glyph sequencing (the build dependency)

Every option's `symbol` must resolve to an installed glyph or it falls back to `journal`.
The full set is designed (`PrismaGlyph_FullRoster_SVGData.md`) but **not installed** (L4a).
Sequence chooser race-views by glyph readiness:
1. **First:** races whose native set is mostly the 12 live Aedric glyphs + Tier-0
   (Imperial, Nord-minus-Shor/Tsun/Stuhn, Breton-minus-Magnus/Phynaster).
2. **After Prince glyphs install:** Daedric-heavy foreign sections + Dunmer/Khajiit/Orc
   native Princes.
3. **After Tier-2 cultural glyphs install:** Khajiit lunar, Yokudan Redguard, Altmer
   Syrabane/Xarxes/Magnus, Nord Shor/Tsun/Stuhn.

Per-race glyph dependency list (which keys each view needs) = the per-race roster in
`PDV_MedallionDeityCoverageAudit.md` cross-referenced with the
`PrismaGlyph_DesignHandoff.md` Tier-0/1/2 lists. Author that table during L4a install.

---

## Per-race "what the view shows" (from the coverage audit)

| Race | Native section | Foreign-with-cost (curated) | Curse | Shape |
|---|---|---|---|---|
| Imperial | the 8 Nine-Divines gods | Meridia (Tolerated) | Hircine, Molag Bal | pantheon |
| Nord | 13 Old Ways/Divines gods | Meridia | Hircine, Molag Bal | pantheon |
| Breton | 12 gods + Y'ffre | the 9 Legible Princes (Azura, Mephala, Nocturnal, Mora, Namira, Vile, Hircine…) | Molag Bal | pantheon |
| Altmer | Auri-El + 8 Aldmeri | — | Molag Bal | pantheon |
| Bosmer | Y'ffre, Auri-El, Xarxes, Baan Dar | Hircine, Nocturnal (Legible) | Molag Bal | pantheon |
| Dunmer | substrate: House Ancestors | foci: Azura/Boethiah/Mephala | Molag Bal | substrate+foci |
| Khajiit | substrate: Lunar Lattice | foci: lunar set + Baan Dar; Legible Princes (Boethiah, Mephala, Mora, Namira, Sanguine) | Hircine, Molag Bal | substrate+foci |
| Argonian | substrate: the Hist + Sithis | — | Hircine, Molag Bal | substrate+foci |
| Orc | substrate: Malacath life-mode | — | Hircine | substrate+foci |
| Redguard | substrate: Yokudan sect | Meridia (Tolerated) | Hircine | substrate+foci |

(Counts/stances per `PDV_MedallionDeityCoverageAudit.md`; the curated Foreign subset is the
`Legible`/`Tolerated` entries, not the full Foreign tail.)

## Deliverables when L4c builds
1. The `mode:"medallion"` JSON (above) finalized against the live startup payload.
2. The roster renderer (sections, access rim/badge, details, confirm) as an additive
   evolution of `renderStartup()`.
3. The per-race glyph dependency table (with L4a).
4. Papyrus: `SendPrismaMedallionPayload(race)` building the per-race roster + accepting a
   selection and **scoring the chosen patron** — a chosen god the engine cannot score is a
   dead button (audit's open item; resolve scoring in L1 first).

## Acceptance (design)
- All 10 races have a defined view (pantheon or substrate+foci); curated, not 61-deep.
- Curse-access Princes reflected read-only, never offered as free picks.
- Cost shown by rim/badge + advisory + consequence confirm; native is clean.
- Select+confirm with renounce-to-broad; active shows standing color.
- Glyph sequencing + per-race dependency identified; substrate gods are foci, not patrons.
