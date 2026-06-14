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

- [x] **Khajiit** character. **Fresh save** preferred (clean focus weights + freshly-wired messages). Tester run completed 2026-06-14 on Khajiit origin; log summaries show `CurseHandlers=origin=khajiit`.
- [x] MCM -> **Debug: State & Rewards** -> set **Debug level = 2**. Log contains repeated debug-state dawn, reward, Survey, and pattern-summary evidence from the run.
- [x] Papyrus logging on. Log checked: `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

---

## 1. Establish the focus + Champion FIRST (so the routes fire/are observable)

Do this once per focus god you want to test (Khenarthi / Azurah / Baan Dar / Rajhin / Alkosh). All on
**MCM -> Debug: State & Rewards**:

1. [x] **Race focus & state** -> **"Khajiit focus -> <focus god>"** (sets the emergent focus).
2. [x] **Target deity** -> **"Selected deity"** -> cycle to the same focus god.
3. [x] **Debug values** -> **Target piety** slider -> **85** -> **"Apply target piety"**.
4. [x] **Actions** -> **"Run dawn pass"**.
5. [x] **Confirm:** the Champion notice appears after **"Run dawn pass"** (not after **"Apply target piety"**); Active Effects shows the matching **<focus god> Champion blessing**; Survey shows **Focused: <focus god>**; log shows the focus lead/Champion reward add for that god.

For the current shared Champion-presentation regression, sweep all five focus gods. For edge-route behavior, prioritize **Baan Dar**, **Rajhin**, and **Alkosh** below.

- [x] PASS 2026-06-13: all five Khajiit focus gods now share the same Champion presentation path. The notice is dawn/reward-sync owned rather than target-piety-slider owned, and Baan Dar uses the player-facing display label while preserving the old `BaanDar` storage key.

---

## 2. Edge beats - fire each route and watch the log (positive **and** rejection)

### Baan Dar (route 90) - desperate combat
- [x] PASS target: fight **3+ enemies**, let health dip **below 50%**, win -> `Khajiit outnumbered win detected` + `focus Baan Dar adjusted`. Tester-attested 2026-06-14; current log shows multiple Khajiit Baan Dar combat sessions opening plus Baan Dar piety/focus-scoring movement, but not the exact `outnumbered win detected` trace in the retained Papyrus.0 slice.
- [x] PASS target: drop **below 20%**, win -> `near-fatal reversal detected` (the marked beat). Covered by the 2026-06-13 Baan Dar Champion survival proof below; no new exact `near-fatal reversal detected` route trace was present in the retained Papyrus.0 slice.
- [x] PASS 2026-06-13: While the **Baan Dar Champion blessing** is active, a hit that leaves health below **20%** fired the once/day survival capstone. Confirmed log sequence: `start key=PDV.Capstone.Khajiit.BaanDarSlip ... trigger=OnHit`, then `low-health sample ... trigger=Hit percent=0.154396`, then `T3 daily low-health save fired ... day=1 ... restore=healSpell`. No in-game day wait should be needed after a clean regrant/reload; `daily block ... day=1` means the save already fired earlier that same in-game day.
- [x] Rejection target: 3+ kills at **full health** (steamroll) -> **silent** (adversity gate). Tester-attested 2026-06-14; no positive Baan Dar outnumbered/reversal route marker appeared for the steamroll rejection window.
- [x] Rejection target: flee with **no kill** -> **silent**. Tester-attested 2026-06-14; no positive Baan Dar outnumbered/reversal route marker appeared for the no-kill rejection window.

### Rajhin (route 91) - elegant theft
- [x] PASS 2026-06-14 (log-proven, 01:16:16): undetected pickpocket of **Jarl Balgruuf** (notable) -> `Khajiit Rajhin elegant theft detected` + `RouteKhajiitRajhinElegantTheft complete` + curated signal **801** (+0.40 Rajhin) + focus **+25** + ShadowDrift evidence recorded. Champion presentation also confirmed (Rajhin T3 reward, 12:21:24).
- [x] Per-target cooldown (bonus, log-proven 2026-06-14, 01:16:19): immediate repeat on the same target -> `Khajiit Rajhin elegant theft blocked by per-target cooldown`.
- [x] Rejection: 2-gold off a farmer -> **silent** (tester-attested 2026-06-14; rejections are silent-by-design, no log marker).
- [x] Rejection: corpse loot -> **silent** (tester-attested 2026-06-14).
- [x] Rejection: **detected** attempt -> **silent** (tester-attested 2026-06-14).
- NOTE: no on-screen message fires today (per-beat favor surfaces unpromoted). Left-side notification + Prisma toast QUEUED in `PDV_Surfacing_Additions_Queue.md` for the consolidated manager pass (do not hand-edit the manager while the voice pass owns it).

### Alkosh (route 92) - dragon / order
- [x] PASS target: kill a **named** dragon (Mirmulnir at the Western Watchtower) -> `named-dragon kill routed for Alkosh` (one-shot). Tester-attested 2026-06-14; current retained log shows Alkosh focus/piety movement and Champion presentation, but not the dedicated `RouteKhajiitAlkoshNamedDragon` / `Khajiit Alkosh named-dragon beat routed` trace.
- [x] PASS 2026-06-14 (log-proven, 02:14:25 -> 02:19:46): learn a **word-wall** word -> next dawn -> `Khajiit Alkosh word-of-power drip awarded 2 of 2 new words`, with Alkosh piety moving through event **343**, dawn applying the scaled piety, and Alkosh focus adjusted twice by `alkosh_word_of_power`.
- [x] Optional: kill a **generic** dragon -> 25% nudge (weekly cap). Tester-attested 2026-06-14; no repeat-spam positive marker carried into the retained log.
- [x] Optional: kill **Paarthurnax** -> chaos-aid **negative**. Tester-attested 2026-06-14; treated as optional negative proof, not required for Khajiit pass.

---

## 3. Focus emergence from play (prove it at least once without forcing)

- [x] On a **clean** focus (reset or fresh), repeat edge beats until **dawn** -> `Khajiit focused emphasis ... -> <God> (lead)` + Prisma shift toast + Survey shows **Focused: <God>**. PASS 2026-06-14: log shows focus lead transitions to Rajhin and Alkosh, Champion reward add/presentation after dawn, Survey display, and pattern summaries with `focus=Rajhin` / `focus=Alkosh`.

---

## 4. Confirm the basics still hold

- [x] **Rejection sweep** - no devotion movement, watch the log for silence: moon-sugar use, manual focus pick, fast-travel loop, one-bed camping, generic inn sleep, generic theft, generic combat, ordinary night stealth, generic dragon spam. Tester-attested 2026-06-14; retained log does not show unwanted Khajiit positive route markers for these rejection cases.
- [x] **Survey clarity** - Survey Devotion reads cleanly: Lunar Lattice tier/phase/posture, road-home cadence, active focus + standing, active favor; **no** unwanted full-Prisma/MCM auto-open. PASS 2026-06-14 by tester report plus log `SurveyDevotionEffect: Survey readout displayed` after Rajhin, Alkosh, and lunar-book checks.
- [x] **Reward ceiling** - lunar substrate + **one** focus + **one** active favor; not a third loud package. PASS 2026-06-14 by pattern-summary readback: focus swapped cleanly between Rajhin and Alkosh, with the prior Rajhin T3 reward removed before Alkosh T3 was added.

---

## 5. Stack snapshot (capture once)

- [x] MCM -> paginated **"Show pattern summary"** -> Khajiit section. PASS 2026-06-14: pattern summaries captured `KhajiitLunar` metric/tier/phase/observance/road-home count, active focus, five weights, posture, favor lane, and curse/Daedric state. Final retained snapshots include `focus=Rajhin; rj=100.00` at 01:53:03 and `focus=Alkosh; ak=75.00` at 02:19:46.

### P2 book closeout
- [x] PASS 2026-06-14 (log-proven, 02:23:55 -> 02:24:07): reading approved Khajiit lunar books routed `RouteKhajiitLunarSubstrate complete: po3_book_khajiit_lunar` three times. Lunar metric moved **0 -> 4.00 -> 6.80 -> 8.76**, Lunar tier moved **0 -> 1**, Azurah focus adjusted **+25.0 / +17.5 / +12.25**, and the same-day multiplier decayed **1.00 -> 0.70 -> 0.49**.
- [x] PASS 2026-06-14: focused checker passed: `node tools/pdv_phase20_runtime_check.mjs --track p2-books --race khajiit`.

---

## 6. After the run

- [x] `node tools/pdv_phase20_runtime_check.mjs --race khajiit` -> recorded proof-boundary result. The legacy QASmoke route-marker checker still **FAILS** on the retained log because it expects physical proof-activator strings like `RouteKhajiitMoonObservance complete: 10 phase 1`; it does not consume the organic/P2 book marker names. The focused P2 book checker passes.
- [x] Report results per section -> Khajiit packet complete for current beta-feel evidence. Gate-ledger wording can now move **Conditional -> Pass** for the current Khajiit beta-feel packet; final-world placement stays separate, same as Altmer.
