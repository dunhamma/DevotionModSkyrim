# Session C — Requiem HP-bar sweep run-sheet (2026-06-22)

The load-bearing run: proves the flat health rewards move the HP bar **under Requiem**
and **sets the tuned magnitudes**. Hand the felt deltas back → tune-back + 1B penalty
conversion → "tuning frozen" → Codex 1F.

## SETUP (do once)

0. **FIX THE LOAD ORDER FIRST (verified 2026-06-22).** In the **ARR** MO2 instance,
   profile **PDV Test**, left pane: **ENABLE** `Devotion - PlayerDevotion Local Test`
   (junction → today's build, was DISABLED) and **DISABLE** `PDV_Authoria_FirstLook`
   (stale Jun-21 snapshot with 82 old .pex). Keep `PDV_AuthoriaARR_Compatibility`
   enabled. The two Devotion.esp copies are byte-identical → **no Reqtificator re-run**.
1. Launch ARR / PDV Test (SKSE). Confirm `Devotion.esp` loads before `Requiem`, the
   compat ESP after `Devotion.esp`, Archon family disabled, "Living Deities Test" off.
2. **Fresh disposable save** (HEAD ab193cb ships migration v3 + patron/Prince exclusivity;
   a stale save can confound seeding). Console: `set PDV.UI.DeveloperOptions to 1`.
   MCM DebugLevel 2; confirm Papyrus log on.
3. **Per-heal method:** `set PDV_GLO_OriginRace to N` → MCM Debug "Selected deity" →
   "Target piety" slider to the tier (Seeker 25 / Devoted-Faithful 50 / Champion 85) →
   "Apply target piety" → `player.getav Health` before & after → record (after − before).
   Passive Fortify applies on seed (no trigger). Re-check the active commitment after
   each seed ("Show piety map") — exclusivity can sever a prior seed.

## BEFORE-BED SLICE — passive Fortify-Health sweep (A1–A6, ~20–30 min)

| # | Race / lane | Console | Seed | Expect (record the felt delta) |
|---|---|---|---|---|
| A1 | **Argonian — Hist emphasis** | `set PDV_GLO_OriginRace to 7` | PDV_Deity_Hist @ 25 / 50 / 75 | +10 / +20 / +30 max-Health. (Argonian *substrate* health is nearWater-only → reads 0; test Hist emphasis.) |
| A2 | **Khajiit — Baan Dar** | `set PDV_GLO_OriginRace to 6` | PDV_Deity_BaanDar @ 50 / 85 | +20 / +30. Seeker(25)=0 (armor-only) — note, not a miss. |
| A3 | **Breton — broad Tradition** | `set PDV_GLO_OriginRace to 2` | broad lane @ 25 / 50 (stay BROAD, no focused family) | +10 / +20. Caps at Faithful (no Champion on broad). 0 ⇒ a focused family is active; clear to broad. |
| A4 | **Orc — broad Malacath** | `set PDV_GLO_OriginRace to 8` | Malacath broad @ 50 (stay BROAD, no life-mode) | +20 at Faithful. Seeker=0 (armor). Code-Holds near-death heal is triggered → LATER. |
| A5 | **Imperial — broad Civic** | `set PDV_GLO_OriginRace to 1` | Civic broad @ 25 / 50 | +10 / +20. Caps at Faithful. |
| A6 | **Imperial — Arkay focused** | (already Imperial) | PDV_Deity_Arkay @ 50 / 85 | +20 / +30 (headline Imperial max-health). Seeker=0 (ResistDisease). |

**Record format:** per row, the Health before/after at each tier + the felt delta vs the
expected provisional value. Flag any that feel wrong under Requiem.

## LATER (triggered — needs real gameplay, NOT tonight)

- **A7 Imperial Mara sleep-mercy** — seed Mara focused Devoted/Champion → sleep in a bed →
  getav. Flat Restore ~25/~40 HP + "You wake mended"; once/day.
- **A8 Dunmer home-prayer** — origin 5, sleep to declare home, seed Reclamation patron →
  fire rite AT home → 15/30 HP; prove it does NOT fire elsewhere; once/day.
- **A9 Orc Code Holds** — drop to near-death in combat → flat 40/60 restore.
- **B1a Redguard Tu'whacca death-rite** — death-duty/Ash'abah act → 30/50 once/day.
- **B1b Namira heal-on-feed** — Namira ≥Seeker, feed → HP+Stamina pulse, tier-scaled.
- **B2 HoonDing make-way** — kill a dragon (make-way once; 2nd same-day soft-decays;
  bandit rejected; Champion <20% HP → AvoidDeath once/day; road-passage → Forebear not HoonDing).

## Honest estimate

Before-bed slice (A1–A6): ~20–30 min. Full Session C incl. the triggered rows: a few hours
of real play. Knock out A1–A6 tonight; the triggered rows are a separate session.
