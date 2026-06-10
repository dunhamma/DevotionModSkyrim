# PDV Faucet Surfacing Spec (L3a)

**For:** Codex (UI/Papyrus surfacing of faucet favor). **From:** Claude. **Status:** spec.
Copy source = `references/authoring/PDV_FaucetDigest_CopyBank.md`. This pins the UI contract
the faucet wiring surfaces to; it adds **no** new eventClass and changes **no** existing
flow except the dawn-digest assembly.

---

## 1. The model (law)

A faucet act is **routine favor**. On a qualifying, uncapped (1/dawn) faucet act:

1. **Medallion refresh** — call the existing `RefreshMedallion()` (the standing read /
   glyph color updates to reflect the new piety). Immediate.
2. **Dawn-digest accrual** — the favor accrues to `PDV.PietyToday` on the deity form and
   is rendered once, at dawn, as that god's `favor.digest` line.

**Never:**
- a per-act toast or Notification (anti-spam — the act is quiet by design);
- a route through `PDV_DiegeticDirector.Dispatch()` (faucets are not `tier`/`emergence`/
  `curse` beats; routing them through Dispatch would trip one-shot guards and fire screen/
  sound channels meant for real transitions);
- any magnitude/number in the surfaced text.

This matches the D1 pilot invariant: *"Routine favor never routes through Dispatch()."*
The only beat a faucet can ever cause is an **indirect** `tier.reach` if the accrued favor
crosses a tier boundary at dawn — that beat fires through the **normal** tier path with the
deity's authored `tier.<label>` copy, not through any faucet-specific surface.

---

## 2. Dawn-digest format (multi-faucet day)

One `favor.digest` line per fed god, assembled at dawn. Grouping is **pantheon-aware** per
`PDV_FaucetDigest_CopyBank.md` §"Pantheon-aware dawn presentation":

```
Your devotions settle with the dawn.          <- existing dawn Notification, now the header
  <Pantheon header, if the race follows one>:
    <member-god favor.digest>                  <- ordered by piety standing, desc
    <member-god favor.digest>
  <stand-alone foreign/Daedric favor.digest>   <- below the pantheon block, by standing
```

- Show a god's line only if `PDV.PietyToday != 0` on its form.
- Pantheon members group under the active-pantheon header (Nord
  `PDV_State_NordPantheonBaseline` → "The Old Ways were kept:" / "The Nine were honored:";
  Imperial = the Nine). Daedric/thin/foreign faucet gods stand alone beneath.
- Single-patron player: just that god's line, no header.
- Worked 2-god and 3-god examples (incl. a Nord pantheon case and a Dibella-inside-the-Nine
  case) are in the copy bank §"Worked examples".

---

## 3. Channels

| Channel | On a faucet act | At dawn |
|---|---|---|
| Toast / Notification | none | the existing dawn Notification, reused as the digest header |
| Medallion (glyph + standing) | `RefreshMedallion()` | `RefreshMedallion("dawn")` (already called) |
| Journal / Book of Days | none | append each fed god's `favor.digest` (DBF, if present) |
| Dispatch() screen/sound/music | none | none |

Verbosity: at Verbose (2) an optional tiny chime on a faucet act is allowed (matches the
existing routine-favor Verbose hook); at Transitions (1) and Silent (0), nothing per-act.

---

## 4. Acceptance
- A faucet act produces **no** toast and **no** Dispatch call; medallion refreshes.
- At dawn, exactly one line per fed god; pantheon grouping correct; ordering by standing.
- A faucet pulse that crosses a tier fires the deity's authored `tier.<label>` beat once
  (normal tier path), not a faucet-specific surface.
- No magnitude text anywhere in the digest.
- Deps-absent (no DBF) degrades cleanly: the digest header Notification still fires; the
  per-god journal lines no-op without error.
