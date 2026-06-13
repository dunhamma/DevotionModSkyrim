# PDV Khajiit Beta-Feel Packet

**Goal:** flip the Khajiit gate verdict from **Conditional -> Pass**.
**Source contract:** `PDV_PreBetaRaceGateLedger.md` (Khajiit block).
**Status when written:** lunar substrate + Survey/rejection basics passed 2026-06-06;
organic edge hooks + focus emergence + reward-at-threshold are the remaining proof.

> **Tester note (carried from the failed first attempt):** the focus god must be at
> **Champion tier and be the active focus** before the edge routes produce a visible
> reward/emergence. So **Section 1 sets up Champion first** via the MCM, then Section 2
> exercises the routes. Do them in order.

---

## 0. Setup

- [ ] **Khajiit** character. **Fresh save** preferred (clean focus weights + freshly-wired messages).
- [ ] MCM -> **Debug: State & Rewards** -> set **Debug level = 2**.
- [ ] Papyrus logging on. Log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

---

## 1. Establish the focus + Champion FIRST (so the routes fire/are observable)

Do this once per focus god you want to test (Khenarthi / Azurah / Baan Dar / Rajhin / Alkosh). All on
**MCM -> Debug: State & Rewards**:

1. [ ] **Race focus & state** -> **"Khajiit focus -> <focus god>"** (sets the emergent focus).
2. [ ] **Target deity** -> **"Selected deity"** -> cycle to the same focus god.
3. [ ] **Debug values** -> **Target piety** slider -> **85** -> **"Apply target piety"**.
4. [ ] **Actions** -> **"Run dawn pass"**.
5. [ ] **Confirm:** the Champion notice appears after **"Run dawn pass"** (not after **"Apply target piety"**); Active Effects shows the matching **<focus god> Champion blessing**; Survey shows **Focused: <focus god>**; log shows the focus lead/Champion reward add for that god.

For the current shared Champion-presentation regression, sweep all five focus gods. For edge-route behavior, prioritize **Baan Dar**, **Rajhin**, and **Alkosh** below.

- [x] PASS 2026-06-13: all five Khajiit focus gods now share the same Champion presentation path. The notice is dawn/reward-sync owned rather than target-piety-slider owned, and Baan Dar uses the player-facing display label while preserving the old `BaanDar` storage key.

---

## 2. Edge beats - fire each route and watch the log (positive **and** rejection)

### Baan Dar (route 90) - desperate combat
- [ ] PASS target: fight **3+ enemies**, let health dip **below 50%**, win -> `Khajiit outnumbered win detected` + `focus Baan Dar adjusted`.
- [ ] PASS target: drop **below 20%**, win -> `near-fatal reversal detected` (the marked beat).
- [x] PASS 2026-06-13: While the **Baan Dar Champion blessing** is active, a hit that leaves health below **20%** fired the once/day survival capstone. Confirmed log sequence: `start key=PDV.Capstone.Khajiit.BaanDarSlip ... trigger=OnHit`, then `low-health sample ... trigger=Hit percent=0.154396`, then `T3 daily low-health save fired ... day=1 ... restore=healSpell`. No in-game day wait should be needed after a clean regrant/reload; `daily block ... day=1` means the save already fired earlier that same in-game day.
- [ ] Rejection target: 3+ kills at **full health** (steamroll) -> **silent** (adversity gate).
- [ ] Rejection target: flee with **no kill** -> **silent**.

### Rajhin (route 91) - elegant theft
- [ ] PASS target: sneak + **undetected** pickpocket of a **notable** target (jarl / court wizard) **or** **200g+** value -> `Khajiit Rajhin elegant theft detected`.
- [ ] Rejection target: 2-gold off a farmer -> **silent**.
- [ ] Rejection target: corpse loot -> **silent**.
- [ ] Rejection target: **detected** attempt -> **silent**.

### Alkosh (route 92) - dragon / order
- [ ] PASS target: kill a **named** dragon (Mirmulnir at the Western Watchtower) -> `named-dragon kill routed for Alkosh` (one-shot).
- [ ] PASS target: learn a **word-wall** word -> next dawn -> `Alkosh word-of-power drip`.
- [ ] Optional: kill a **generic** dragon -> 25% nudge (weekly cap).
- [ ] Optional: kill **Paarthurnax** -> chaos-aid **negative**.

---

## 3. Focus emergence from play (prove it at least once without forcing)

- [ ] On a **clean** focus (reset or fresh), repeat edge beats until **dawn** -> `Khajiit focused emphasis ... -> <God> (lead)` + Prisma shift toast + Survey shows **Focused: <God>**. (Confirms the focus emerges from behaviour, not just the MCM force.)

---

## 4. Confirm the basics still hold

- [ ] **Rejection sweep** - no devotion movement, watch the log for silence: moon-sugar use, manual focus pick, fast-travel loop, one-bed camping, generic inn sleep, generic theft, generic combat, ordinary night stealth, generic dragon spam.
- [ ] **Survey clarity** - Survey Devotion reads cleanly: Lunar Lattice tier/phase/posture, road-home cadence, active focus + standing, active favor; **no** unwanted full-Prisma/MCM auto-open.
- [ ] **Reward ceiling** - lunar substrate + **one** focus + **one** active favor; not a third loud package.

---

## 5. Stack snapshot (capture once)

- [ ] MCM -> paginated **"Show pattern summary"** -> Khajiit section. Record: lunar metric/tier/phase/observance/road-home count, focused emphasis, the **5 focus weights**, last anchor, repeat-reject count, active favor, lunar posture, ShadowDrift/curse pressure, Daedric modifiers.

---

## 6. After the run

- [ ] `node tools/pdv_phase20_runtime_check.mjs --race khajiit` -> confirm route markers.
- [ ] Report results per section -> gate ledger flips **Conditional -> Pass** (final-world placement stays a separate item, same as Altmer).
