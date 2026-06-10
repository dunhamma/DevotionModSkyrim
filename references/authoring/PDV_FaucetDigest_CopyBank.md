# PDV Faucet Digest Copy Bank (L2b)

**Status:** Review-ready copy. The `favor.digest` lines here are the canonical entries for
the seven faucet gods; they fold into those gods' ContentBank blocks (L2a) under the same
`PDV_Journal.<deity>.favor.digest` key. This doc also fixes the **pantheon-aware dawn
presentation** rule the surfacing spec (L3a) and Codex build to.

**Model (law):** a faucet act is *routine favor* — it surfaces ONLY as one batched
`favor.digest` line at dawn + a medallion refresh. Never a per-act toast, never through
`Dispatch()`. Anti-farm 1/dawn lives in the matrix JSON (`faucet.[key].anti_farm_cap`);
the copy renders the *result*, never the cap or a magnitude.

**Style:** ASCII-only, <=80 chars/line, in-voice, in the god's register. One line per fed
god per dawn — written true whether the player did one qualifying act or several.

---

## The seven faucet gods — `favor.digest`

| deity | `PDV_Journal.<deity>.favor.digest` |
|---|---|
| Namira | `Namira noted the day's hunger; what others revile, you did not refuse.` |
| Sanguine | `Sanguine smiled on the day's indulgence; the cup was not set down.` |
| Peryite | `Peryite marked the day; you bore the rot and did not pray it away.` |
| Vaermina | `Vaermina took the day's harvest; dreams not your own passed through you.` |
| Clavicus Vile | `Clavicus marked the day; the bargain's edge rode well at your brow.` |
| Hermaeus Mora | `Mora caught the day's reading; forbidden pages turned under your eye.` |
| Dibella | `Dibella blessed the day's grace; you tended beauty, alms, or vow.` |

Notes:
- **Namira** covers both faucet acts (corpse-feed + human-flesh) which share one
  1/dawn cannibalism cap — one line regardless of which fired.
- **Sanguine** covers drink + Sanguine Rose; **Peryite** disease + Spellbreaker ward;
  **Mora** Black Book + rare tomes; **Dibella** marry/alms/adorn. One line each.
- **Clavicus / Dibella** also have `DEFERRED` acts (quest-persuade, perform/art) with no
  vanilla hook — the digest line stays true without them.

---

## Pantheon-aware dawn presentation (the framing rule)

A day can feed several gods. The dawn digest renders **one `favor.digest` line per fed
god**, but the *grouping* respects the player's worship model:

1. **Multi-god race following a pantheon** (Nord Old Ways / Nine Divines; Imperial Nine):
   gods that belong to the active pantheon are listed **under a pantheon header**,
   ordered by piety standing (highest first).
2. **Daedric / thin / foreign faucet gods** (Namira, Sanguine, Peryite, Vaermina,
   Clavicus, Mora; Dibella when she is *not* in the player's active pantheon) render as
   **stand-alone lines below the pantheon block**, also ordered by standing.
3. A god is shown only if it received favor that day (`PDV.PietyToday != 0` on its form).
4. The header text follows the race's active-pantheon state — e.g. Nord
   `PDV_State_NordPantheonBaseline`: `OldWays` → "The Old Ways were kept:" /
   `NineDivines` → "The Nine were honored:". Imperial is always the Nine.

A single-patron player (committed to one god) just sees that god's line; no header.

---

## Worked examples

### A — Nord on the Old Ways: Kyne + Shor (pantheon) + Sanguine (foreign faucet)
```
Your devotions settle with the dawn.
  The Old Ways were kept:
    Kyne's breath stayed with you on the open road.
    Shor weighed the day's valor and did not look away.
  Sanguine smiled on the day's indulgence; the cup was not set down.
```

### B — Imperial (Nine Divines): Mara + Dibella, Dibella fed by the alms faucet
```
Your devotions settle with the dawn.
  The Nine were honored:
    Mara's mercy moved through your hands today.
    Dibella blessed the day's grace; you tended beauty, alms, or vow.
```
(Dibella is a Divine here, so her faucet line sits *inside* the pantheon block.)

### C — Breton committed to Namira, also tending Stendarr broadly (3 lines)
```
Your devotions settle with the dawn.
  Stendarr counted the day's mercies.
  Namira noted the day's hunger; what others revile, you did not refuse.
```
(Committed patron Namira stands alone; Stendarr is the broad-worship Divine. No header
because Breton's broad lane is not a named multi-god pantheon roster.)

---

## Integration note for Codex
- Append each god's line via the journal path at dawn: in `RunDawnConsolidateScratch()`
  (`PDV__ManagerQuest.psc` ~3695), for each deity with `PDV.PietyToday != 0` whose accrual
  came from a faucet act, queue `PDV_Journal.<deity>.favor.digest`.
- Group under the pantheon header when the deity is a member of the race's active pantheon
  (reuse the pantheon-membership the offer-gating already knows); else stand-alone.
- The existing dawn Notification ("Your devotions settle with the dawn.") becomes the
  digest header line; the per-god lines append beneath it (journal/DBF on the diegetic
  side, or the panel dawn payload).
- No magnitude numbers in any digest line.
