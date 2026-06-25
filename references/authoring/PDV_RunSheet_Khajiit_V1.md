# PDV In-Game Run-Sheet -- Khajiit (V1)

Status: V1 (Unit D Prisma live `5e9e502`; emergence-onset + lunar-posture chronicle + substrate
Ledger driver + Champion pin = NEW this pass). Created 2026-06-25. Pair with
`PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

**Khajiit is a no-offer race by design.** Khajiit never gets a "commit to a patron?" pop-up. A focused
emphasis deity emerges *silently* from whichever of Khenarthi / Azurah / Baan Dar / Rajhin / Alkosh has the
most piety. The road just turns toward that god -- you don't choose it; you were already walking it.

---

## Preflight (do once)
1. Start a **new save** as a Khajiit (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 6
   set PDV_GLO_DebugLevel to 2
   ```
   (`6` = Khajiit. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`. The Khajiit seeds you need are
   **Set Khajiit Focus** (Khenarthi/Azurah/Baan Dar/Rajhin/Alkosh) and **Cycle Lunar Posture**
   (Normal -> Strained -> Corrupted -> ShadowDrift).
5. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 6`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  (the Baan Dar Champion survival capstone especially) must be proven *here* -- watch the bar actually move.
  Daedric shrine prayers + quest reactions use the ARR variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects) the **lunar blessing family** exists -- the five focus families
  each have T1/T2/T3 (`PDV_Bless_Khajiit_Khenarthi_T1..T3`, `..._Azurah_`, `..._BaanDar_`, `..._Rajhin_`,
  `..._Alkosh_`) plus the neglect spell `PDV_SPEL_Neglect_KhajiitLunar`. No new mesh/inventory item is needed
  (Khajiit substrate is observance-driven, not an item).
- **See:** the records exist; nothing else Khajiit needs a new asset.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> **Set Khajiit Focus** to a god (say Rajhin) and Force that god's piety to **85**. Then
  open **Survey Devotion** (in the panel / MCM status).
- **See:** the Khajiit lines read like narration -- **Lunar Lattice** depth, moon practice, road-home cadence,
  and the **active focus** (which god leads now), with a **lunar posture** line only when posture isn't Normal.
  No raw numbers/enum codes leaking; "Azurah" renders with a capital A.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With a focus god at Champion, open the **magic menu -> Active Effects**.
- **See:** the **one** focused-family reward stack present (lunar substrate + the active focus T1/T2/T3 for
  that god only), no duplicate/rogue auras, no second focus family bleeding in, nothing from another race/mode.
- **Record:** ___

### Slot 4a -- lunar substrate act + the Ledger-driver fix  [Tester] [R]+[M]
- **Do (play normally, no debug):** spend a night under the moons / **rest to observe a moon phase**, and
  **walk between two road-home anchors on foot** (use a load door or fast-travel to reach the first -- `coc`
  skips location triggers). Open the Devotion panel -> **Ledger** page after each.
- **See:** a **lunar substrate toast** ("The moons marked this observance." / "The road home was remembered.")
  AND **crucially a new Ledger driver row** for the act (Azurah for moon, Khenarthi for road-home). Before the
  fix the lunar substrate recorded NO Ledger driver -- if the Ledger stays empty after a substrate act, FAIL.
- **[Dev] log:** a moon-observance / road-home award marker in Papyrus.0.log.
- **Record:** ___

### Slot 4b -- the silent emergence (NEW headline beat)  [Tester] [R]+[M]
- **Do:** MCM Debug -> **Set Khajiit Focus** to a god that is NOT currently the focus (this forces a fresh
  emergence). Or build one god's piety highest by repeated curated acts so the focus emerges in normal play.
- **See:** a **toast** -- *"Your road turns toward {focus}."* -- and a **pinned Book of Days entry** --
  *"Under the moons your road turned toward {focus}, and stayed there."* There is **NO pop-up offer**
  (this is the silent commitment; Khajiit never asks). It fires only when the focus actually changes.
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 4c -- lunar posture shift (severe = NEW chronicle)  [Tester] [R]+[M]
- **Do:** MCM Debug -> **Cycle Lunar Posture** through Strained, then **Corrupted**, then **ShadowDrift**
  (or take the werewolf/vampire curse to drive it organically).
- **See:** an **immediate shift toast** naming the new posture ("Lattice strained" / "Lattice thinned" /
  "Drifting to shadow"). The two **severe** transitions now also write a **Book of Days** line --
  Corrupted -> *"The moonlight scatters from your path. Corruption is upon you."*; ShadowDrift ->
  *"You slipped into the moons' shadow. Darkness is upon you."* ShadowDrift also pops a **modal** message.
  (Strained is toast-only by design -- no chronicle.)
- **Check the Corrupted/ShadowDrift Book of Days lines are NOT blank.**
- **Record:** ___

### Slot 4d -- focus Champion + the pin fix (NEW)  [Tester] [R]+[M]
- **Do:** MCM Debug -> Set Khajiit Focus to a god, Force its piety to **85**, **Run Dawn** so it reaches Champion.
- **See:** the universal Champion toast + **Book of Days entry**, and **the entry is PINNED** (it survives the
  21-day prune). Khajiit's Champion entry was historically the ONE race that did NOT pin -- confirm it now pins
  like every other race. Sleep/wait 22+ days and re-check the Chronicle: the Champion line must still be there.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 0` (Nord), then fire a Khajiit substrate seed/act (moon observance
  / road-home). Reset with `set PDV_GLO_OriginRace to 6` after.
- **See:** **nothing Khajiit moves** -- no lunar substrate, no focus, no posture, no markers. A non-Khajiit
  can't drive Khajiit state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as a Khajiit, do ordinary things that are NOT the coded hooks: stare at the moons doing nothing,
  use moon-sugar, fast-travel in a loop, sleep one bed at the same inn repeatedly, generic theft / pickpocket,
  generic kills, ordinary night sneaking, generic dragon kills.
- **See:** **none of these score** lunar/focus (only the real coded acts -- moon-phase observance, road-home
  on foot, Baan Dar/Rajhin/Alkosh behavior beats -- do). Manual focus picking is rejected too: the focus is
  earned, never entitled.
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **silent emergence** read as "the road turned toward this god on its
  own" rather than a menu you clicked? Does the **lunar posture** read as the moons drawing near/away rather
  than a debuff counter? Do the severe-posture chronicle lines land with weight? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Khajiit beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (**pinned** Champion -- fix) | N | Force focus piety + Run Dawn |
| lunar substrate act (moon / road-home) | Y | N | **Y (driver -- fix)** | observe moon / walk road-home anchors |
| emergence onset (silent focus lock) | **Y** | **Y (pinned)** | N | focus changes (Debug Set Focus or earned) |
| focus reorientation (later re-focus) | Y | Y (next dawn) | N | a different god takes the lead |
| lunar posture: Strained | Y | N | N | Cycle Lunar Posture / curse |
| lunar posture: Corrupted | Y | **Y (chronicle -- fix)** | N | Cycle to Corrupted / curse |
| lunar posture: ShadowDrift | Y (+ modal) | **Y (chronicle -- fix)** | N | Cycle to ShadowDrift / sustained night-theft |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **No pop-up offer is CORRECT.** Khajiit is a by-design no-offer race. If you see a "commit to a patron?"
  box, that is wrong. The emergence is silent -- toast + pinned chronicle only.
- **Substrate Ledger driver is the key regression.** Khajiit lunar substrate used to record NO Ledger driver
  (the scaled-curated P0 bug); it now double-routes to the emphasis deity -- if the Ledger stays empty after a
  moon/road-home act, FAIL.
- **Champion pin is the other key regression.** Khajiit's Champion entry was historically the only one not
  pinned -- prove it survives the 21-day prune (Slot 4d).
- **Only Corrupted/ShadowDrift get a chronicle line.** Strained is toast-only by design (not a FAIL).
- **`coc` skips location triggers** -- walk/fast-travel to reach road-home anchors and moon-observance sites.
- **The focus posture/label feeds the dawn snapshot**, so a re-focus chronicle lands at the **next dawn**
  (the emergence-onset entry is immediate; later focus shifts ride the dawn diff).
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | lunar focus families + neglect spell exist | | |
| 2 Survey | Lattice/moon/road-home/focus + posture legible | | |
| 3 stack | one focus family, no rogue/second aura | | |
| 4a substrate + Ledger | moon/road-home toast + driver row (fix) | | |
| 4b silent emergence | toast + pinned BoD, non-empty, NO offer popup | | |
| 4c posture shift | toast all; Corrupted/ShadowDrift chronicle (fix) | | |
| 4d Champion pin | Champion BoD pins + survives prune (fix) | | |
| 5 wrong-origin | Nord origin: zero Khajiit movement | | |
| 6 generic silence | moon-sugar/fast-travel/theft/kills do not score | | |
| 7 felt | emergence reads earned; posture reads as the moons | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Khajiit `pass` until every row is filled.
