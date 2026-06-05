# Prisma UI design handoff — Medallion deity-roster chooser

**For:** a Claude design pass on the Devotion Prisma UI (and a paired Papyrus task).
**Date:** 2026-06-04
**Status:** DESIGN PREP — no implementation yet. This brief frames the problem and supplies
everything a design agent needs to design the "medallion" surface: how a race sees and
chooses, from its full roster, which god or Daedric Prince to worship.

> **Data source (kept separate, do not duplicate):**
> `references/authoring/PDV_MedallionDeityCoverageAudit.md` is the authoritative per-race
> roster + wired-status ledger. This handoff is the *design layer* on top of it. Read the
> audit first; the tables there are the content this surface must present.

---

## 1. The problem to design

Today there is **no surface that shows a race its full choosable roster** of gods + Princes.
Devotion selection is split across a debug MCM list (FormList-driven), a per-race startup
*path* modal (only 4 races get choices; only Bosmer's are deities), and the Survey/panel
(active patron only). The "medallion" is the user's name for the missing surface: an
in-fiction patron-selection menu where a race picks **which god or Daedric Prince to worship**,
from the set its culture actually permits.

**Design the medallion chooser:** per race, present the gods and Princes that race can choose,
grouped/cued by *access tier*, with glyphs, and a selection + confirm interaction.

This is intentionally an *earlier-stage* design task than the other handoffs in this folder
(which are drop-in code). Produce the UX/spec first; implementation follows.

---

## 2. The access-tier model (how the roster is structured)

Every god/Prince has a **per-race stance** from the design matrices. The medallion should make
the stance legible — worship is not binary, it carries cultural cost. Tiers, from the
`PDV_StanceMatrix.csv` (gods) and `PDV_DaedricRacePrinceMatrix.csv` (Princes):

| Tier | Gods (stance) | Princes (keyword) | Medallion treatment (design these) |
|---|---|---|---|
| **Native** | `NATIVE` | `Native` | The core lane — offered cleanly, no warning |
| **Accessible w/ cost** | `FOREIGN` (the meaningful ones) | `Legible`, `Tolerated` | Choosable, but signal social/theological cost |
| **Curse-access** | — | `Curse` | Arrives via a curse (Hircine, Molag Bal), not a free pick — design how/whether the medallion represents these |
| **Restricted** | `HOSTILE` | `Taboo`, `Hostile` | Not a normal choice — hidden, greyed, or shown only as "forbidden" with severe-cost framing |

A key design decision (below) is **how much of the Foreign/restricted set to surface at all** —
showing all 45+16 per race is likely noise; the native lane + curse-access + a curated
"foreign with cost" subset is probably the right scope.

---

## 3. Per-race scope at a glance

From the audit (see it for the full lists). Two structurally different race groups — the
medallion must handle both:

| Group | Races | Native worship shape | Medallion implication |
|---|---|---|---|
| **Deity-pantheon** | Nord, Imperial, Breton, Altmer, Bosmer | Multiple individually-named native gods | A genuine multi-deity chooser |
| **Substrate** | Dunmer, Khajiit, Argonian, Orc, Redguard | Devotion routes through a substrate/quasi-patron, with a small named set on top (Reclamations, lunar pantheon, Malacath, Yokudan, Hist) | Chooser may be a *focus* picker over a substrate, not a flat patron list |

Counts (native gods / native Princes): Imperial 8/0 · Nord 13/0 · Breton 12/0 · Altmer 9/0 ·
Bosmer 4/0 · Khajiit 9/1 · Dunmer 3/3 · Redguard 7/0 · Orc 1/1 · Argonian 2/0. (Dunmer's
3 Reclamations are both its native gods *and* native Princes.)

---

## 4. Existing surface to extend — the startup modal contract

The medallion chooser is a close cousin of the existing **startup modal**; reuse its payload
shape and the `renderStartup()` renderer in `app.js` rather than inventing a new channel.

Current payload (`SendPrismaStartupPayload` in `PDV__ManagerQuest.psc`, rendered by
`renderStartup` in `app.js`):

```json
{
  "mode": "startup",
  "startup": {
    "event": "...",
    "race_id": "...",
    "startup_mode": "info_only" | "explicit_choice",
    "options": [
      { "option_id": "...", "title": "...", "summary": "...", "description": "..." }
    ],
    "default_option_id": "...",
    "advisory_line": "...",
    "confirm_required": true,
    "title": "...",
    "summary": "..."
  }
}
```

**Design question:** does the medallion reuse `mode:"startup"` (extending each `option` with
`symbol`, `accessTier`, and a `kind:"god"|"prince"` field, plus grouping), or warrant a new
`mode:"medallion"` with a roster structure (sections per access tier)? The renderer already
handles option buttons, an active state, details pane, advisory, and confirm — a roster view
is an additive evolution of it. **Keep existing JSON fields; only add new ones** (project rule).

---

## 5. Rendering-contract dependencies (glyphs)

A roster view shows many marks at once, so it is **glyph-hungry**. Status of the symbol set
(see `handoff/PrismaGlyph_DesignHandoff.md` for the full plan):

- **Done:** the 12 base Aedric glyphs + Tier-0 `yffre`/`zen`/`baan-dar`.
- **Blocking for Princes:** all 16 Tier-1 Prince glyphs are unbuilt (`hircine`, `azura`,
  `malacath`, `molag-bal`, … render `journal` today). A Prince roster will look broken
  without at least the native ones (`azura`, `boethiah`, `mephala`, `malacath`, `hircine`).
- **Blocking for full pantheons:** Tier-2 cultural glyphs (Khajiit lunar set, Yokudan set,
  Altmer `syrabane`/`xarxes`, Nord `shor`/`tsun`/`stuhn`, etc.) are unbuilt.

The design pass should **either** scope the first medallion to the races whose glyphs exist
(deity-pantheon races minus the missing cultural gods) **or** sequence the glyph work as an
explicit dependency. Note in the design which glyphs each proposed race view needs.

---

## 6. Design decisions to resolve (the actual brief)

1. **Surface model:** extend `mode:"startup"` options, or define a `mode:"medallion"` roster
   payload with per-tier sections? Specify the JSON.
2. **How much to show:** native-only? native + curse-access? + a curated "foreign with cost"
   set? Decide the rule per access tier so the list isn't 61 entries deep.
3. **Substrate races:** is the medallion a focus-picker layered on the substrate (e.g. Khajiit
   choosing a lunar focus, Dunmer choosing a Reclamation) rather than a flat patron list?
   Design both shapes or unify them.
4. **Curse-access princes (Hircine, Molag Bal):** does the medallion offer them, reflect them
   read-only when a curse is active, or omit them? They are not free picks.
5. **Cost/stance legibility:** how is "you *can* worship this but it costs you" shown —
   colour, an advisory line, a confirm step with consequence text?
6. **Interaction:** browse-only vs. selectable + confirm; how the active patron is indicated;
   how switching/renouncing reads.
7. **Glyph sequencing:** which glyphs block which race views (Section 5).

---

## 7. Two-sided implementation (out of scope for the design pass, note for sequencing)

Designing the surface is UI. Making it *work* is paired:
- **UI (`app.js`):** roster renderer + payload handling (this design pass → later a code handoff).
- **Papyrus (`PDV__ManagerQuest.psc`):** build the per-race roster payload, accept a selection,
  and — critically — **score the chosen deity**. The audit shows most native gods/Princes have
  no scoring path today (only ~Hircine + the symbol-recognized Aedric set). A medallion that
  offers a god the engine can't score is a dead button. **Resolve the audit's open item first:
  dump `PDV_FLST_AllDeities` and confirm which deities are actually scorable.**

---

## 8. Deliverables expected from the design pass

1. The medallion payload spec (JSON), as an additive extension of the startup contract.
2. A roster-view UX: layout, access-tier cueing, glyph placement, selection + confirm flow,
   handling of both deity-pantheon and substrate races.
3. A per-race "what this view shows" table (which gods/Princes, which tiers surfaced).
4. A glyph dependency list per race view.
5. A short sequencing note: which races ship first given current glyph + scoring coverage.

---

## 9. Constraints (carry from the surfacing handoff)

- `app.js` / `index.html` / `styles.css` are **frozen** — design first; code changes land only
  via an explicit follow-up handoff.
- Do **not** touch `PDV_PrismaBridge` or the `ReceivePDVJson` / `ReceivePDVOverlayJson` entries.
- JSON payload shape: **add fields freely, never remove or rename** existing ones.
- Keep this doc and the audit **separate** from `AGENTS.md` (Codex's canonical context).
