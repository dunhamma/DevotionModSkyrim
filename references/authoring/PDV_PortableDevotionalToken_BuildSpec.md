# PDV Portable Devotional Token — Shared Build Spec

**Status:** Spec / build-ready. Generalizes the runtime-proven Dunmer portable/private
shrine pattern (Phase 10) to the two remaining exile-race tokens.

**Scope:** One reusable item + routing pattern that ships **three reskins**:

| Token | Race | Substrate it feeds | Source lock |
|-------|------|--------------------|-------------|
| Ash-shrine token | Dunmer | `PDV_Substrate_DunmerAncestor` | `race-sheets/PDV_RaceDesign_Dunmer.md:179` |
| Far Shores token | Redguard | Tu'whacca/Satakal sect surface | `race-sheets/PDV_RaceDesign_Redguard.md:53,62` |
| Hist sap | Argonian | `PDV_Substrate_ArgonianHist` | `race-sheets/PDV_RaceDesign_Argonian.md:47,67-72` |

**Design intent (shared):** a permanent inventory item, usable anywhere, that supplies a
valid devotional/maintenance signal, with a **bonus when used in player-owned property**
or an authored private-shrine context. None of the three needs a custom mesh or texture —
all reuse vanilla art (see ledger §1).

---

## 1. What already exists (do not rebuild)

The Dunmer token is **runtime-proven** (Phase 10, `PASS=847`). Reuse its machinery verbatim;
the other two tokens are new records pointed at the same proven routes.

- Event constants: `EVT_DUNMER_PORTABLE_SHRINE`, `EVT_DUNMER_HOME_BONUS`
  (`PDV_Architecture_v3.md:2162`).
- Routes: `RouteDunmerPortableShrinePrayer`, `RouteDunmerPlayerHomeBonus`.
- Receiver `RouteId` values `30` (portable) and `31` (private/home).
- Phase 10 repaired **portable/private cooldown-key drift** — the two routes use
  **distinct** StorageUtil cooldown keys. Preserve that separation for every token.

The new work is: (a) two new item records + two new event/route pairs per the same shape,
and (b) seeding the shared home-detection list.

---

## 2. Record shape (per token)

Recommended activation surface: a **non-consumable BOOK "ritual focus"** rather than an
ingestible (which would be consumed) or a placed activator (which breaks "usable anywhere").
Rationale: a BOOK is reusable, usable from inventory in any cell, carries the prayer/flavor
text directly in its read view (free immersion, no notification spam), and accepts a script
fragment that fires the EventBus event. Where a race reads better as a cast rite, a granted
self-target Lesser Power (SPEL) is the sanctioned alternative — same fragment, same routing.

Argonian Hist sap is the current exception: it ships as a potion-style vial (`ALCH`) with a
script-only magic effect because the failed book/misc token did not produce the intended
inventory-use feel. The effect re-adds the vial after use so it behaves as a permanent token.
Future investigation: find a CK/record setup that lets this behave as a truly persistent,
non-consumed inventory-use item instead of relying on the current re-add workaround.

Per token, author:

1. **BOOK** record (e.g. `PDV_Book_DunmerAshShrine`, `PDV_Book_RedguardFarShores`):
   - Flags: cannot-be-taken-disabled = false; **non-consumable** (no spell/skill teach that
     removes it); weight `0`, value `0`; quest-item flag optional to prevent drop.
   - Read view holds the prayer copy (authored text, non-voiced — consistent with the
     §21.3 voiced-content non-goal).
   - Script fragment on read → `SendDevotionEvent(EVT_<RACE>_PORTABLE_SHRINE)`.
2. **MGEF/SPEL alternative** only if the race ships as a Lesser Power instead of a book.
   Hist sap uses an `ALCH` + script `MGEF` variant for inventory-use reliability.
3. Granting: the token is granted once on race-confirm (the same first-load hook that runs
   the MCM setup). Living races get it at start; it is **not** re-granted on load if already
   owned (guard on a `PDV.<Race>.TokenGranted` bool).

### New event/route pairs (mirror Dunmer)

| Token | Portable event | Home/private event | RouteIds |
|-------|----------------|--------------------|----------|
| Hist sap | `EVT_ARGONIAN_HIST_SAP` | `EVT_ARGONIAN_HIST_HOME` | new pair, mirror 30/31 |
| Far Shores | `EVT_REDGUARD_FARSHORES` | `EVT_REDGUARD_FARSHORES_HOME` | new pair, mirror 30/31 |

(Dunmer already owns `30`/`31`.)

---

## 3. Shared home / private-context detection

One helper, used by all three home routes — do **not** re-implement per race.

- Maintain `PDV_FLST_PlayerHomeLocations` seeded with vanilla `LocTypePlayerHouse`-keyworded
  locations plus the Hearthfire homesteads (Lakeview, Windstad, Heljarchen).
- On token use, the fragment resolves home context in this order:
  1. `PlayerRef.GetCurrentLocation()` is in `PDV_FLST_PlayerHomeLocations`, **or**
  2. current cell owner resolves to the player (cell-ownership fallback for modded/player
     homes not in the list).
- If home context is true → route the **home** event (`...HOME`, RouteId 31-equivalent);
  else route the **portable** event (RouteId 30-equivalent).

This reuses the exact decision the proven Dunmer route 30/31 split already makes; the only
new artifact is the shared FLST.

---

## 4. Signal contract (what a use grants)

Calibrate against the proven Dunmer baseline: after one portable + one home use the proof
read `DunmerAncestor metric=13.0; prayers=1; homes=1` (`PDV_Architecture_v3.md` Phase 10
trace). Mirror that magnitude; do not invent a larger economy.

On a **valid** (non-cooldown) use, the route must:

1. Stamp the maintenance timestamp for that substrate:
   - Dunmer: increment `PDV.Substrate.DunmerAncestor.PrayerCount` / `HomeCount`, bump `Metric`.
   - Argonian: set `PDV.Substrate.ArgonianHist.LastMaintenanceDay = currentDay` and add a
     small `Hist` increment — this is the documented offset to the dawn `-1` decay
     (`race-sheets/PDV_RaceDesign_Argonian.md:47`). Respects the non-curse floor of `20`.
   - Redguard: bump the Tu'whacca/Satakal sect substrate metric.
2. Apply the **home bonus** only on the home route (slightly larger increment / or a small
   secondary buff), per "bonus when used in player-owned property."
3. Write the **distinct** cooldown key (portable vs home) and enforce a per-day cap so the
   token can't be spammed. Keep portable and home keys separate (Phase 10 lesson).

### Anti-farm / floors

- One scored portable use and one scored home use per in-game day (separate caps).
- Argonian: the sap routes a Hist communication moment and grants `+5` Hist piety once per
  in-game day. It never restores a curse-suppressed Hist on its own (posture rules still win).
- No effect while the race's curse posture silences the substrate (vampire Silent/Corrupted
  for Argonian; ash-prayer Silent for Dunmer) — the token logs but scores zero, matching the
  documented "logged but inert" behavior.

---

## 5. Per-token flavor (authored copy, non-voiced)

Each book's read text is the only race-specific writing. Keep it short, first-person, and
diegetic:

- **Dunmer ash-shrine:** morning ash-prayer; the ancestors are present even in exile.
- **Redguard Far Shores:** addressing Tu'whacca / the journey to the Far Shores. Player-facing
  copy must say the Redguard is *using* Skyrim's death institution while addressing Tu'whacca,
  **not** worshipping Arkay (`race-sheets/PDV_RaceDesign_Redguard.md:53`).
- **Argonian Hist sap:** tasting the sap; a thread of the Hist reaching across the distance
  from Black Marsh.

---

## 6. Build checklist

- [ ] Shared `PDV_FLST_PlayerHomeLocations` seeded; cell-ownership fallback wired.
- [x] Argonian: `ALCH` vial + script `MGEF` + EventBus route + once-per-day `+5` Hist piety; tester passed 2026-06-17. Future work: replace the re-add workaround with a truly persistent/non-consumed inventory-use item if CK record behavior allows it.
- [ ] Redguard: BOOK record + `EVT_REDGUARD_FARSHORES` / `_HOME` + routes + sect-substrate writes + cooldown keys.
- [ ] Dunmer: confirm existing route 30/31 still passes after FLST refactor (regression only).
- [ ] One-time grant guarded per race on race-confirm.
- [ ] Curse-posture zero-score guard verified for each.
- [ ] Authored read copy for all three books.
- [ ] Runtime proof per token: portable route, home route, save/load persistence, anti-farm cap (mirror the Phase 10 proof lane).
