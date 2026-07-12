# PDV In-Game Run-Sheet -- Breton (V1)

> STALE REWARD MODEL (2026-07-12). This sheet is a Prisma/surfacing run-sheet; its
> reward-mapping notes predate two model changes. Slot 1's single-deity mapping
> (Knight's Road -> Stendarr, Hidden Art -> Julianos, Green Way -> Kynareth) was
> superseded by the 07-11 tradition-pool reconciliation and again by the owner-locked
> **two-axis split** (tradition = practice track; patron championing over the full
> 11-god roster; a Green Way Breton can champion Magnus). For the current reward math
> and its test cards, use `PDV_1_0_CoTest_Runbook_2026-07-10.md` (Breton Two-Axis
> Split Cards BX1-BX7) and `PDV_BretonTwoAxis_BuildSpec_2026-07-12.md`. The Prisma /
> Survey / Book-of-Days SURFACING slots below remain useful, but do not treat the
> deity->tradition mapping in Slot 1 as authoritative.

Status: V1 (Unit D Prisma live `5e9e502`; tradition-choice + druidic-fork toasts/Book-of-Days are NEW
build items this pass). Created 2026-06-25. Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources:
`PDV_PreBetaRaceGateLedger.md`, `PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as a Breton (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 2
   set PDV_GLO_DebugLevel to 2
   ```
   (`2` = Breton. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. **Breton picks a tradition at startup.** On a fresh Breton save the startup popup offers **Knight's Road /
   Hidden Art / Green Way**. Pick one to drive the tradition-choice beat (Slot 4a), or use the MCM
   `DebugSetBretonTradition` seed to set it (0 = Knight's Road, 1 = Hidden Art, 2 = Green Way).
6. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 2`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. Daedric shrine prayers + quest reactions use the ARR
  variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects) the **tradition blessing family** wires up after race-confirm:
  Knight's Road -> Stendarr, Hidden Art -> Julianos, Green Way -> Kynareth (the T1/T2/T3 `PDV_Bless_Breton_*`
  blessings). Only the **chosen** tradition's blessing should be live; the other two stay dormant.
- **See:** the active tradition's reward effect is present; no rogue blessings from the unchosen traditions.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** Set a tradition (MCM `DebugSetBretonTradition`) and Force Piety on its patron to **85**. Then open
  **Survey Devotion** (in the panel / MCM status).
- **See:** the Breton lines read like narration -- the **tradition** you walk (Knight's Road vow / Hidden Art
  cover / Green Way covenant), plus a **vow / exposure / druidic-standing** line, your **standing** band, the
  **druidic fork** line only when Green Way has forked, a **cross-tradition pull** line only if pressure > 0,
  and no obsolete **mixed inheritance** layer. No raw numbers/enum codes leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With the chosen patron at Champion, open the **magic menu -> Active Effects**.
- **See:** the tradition reward effect(s) present, no duplicate/rogue auras, nothing bleeding from another
  tradition/race/mode.
- **Record:** ___

### Slot 4a -- tradition-choice beat (the start-lock)  [Tester] [R]+[M]
- **Do:** On a fresh Breton save, take the **startup tradition choice** (or MCM `DebugSetBretonTradition` on a
  fresh state). Then open the panel -> **Chronicle**.
- **See:** a **toast** -- *"You set your tradition: {tradition}."* -- and a **pinned Book of Days entry** --
  *"You've chosen your road: {tradition}."* where `{tradition}` is
  Knight's Road / Hidden Art / Green Way.
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 4b -- tradition is start-locked; off-tradition acts build pressure  [Tester] [R]
- **Do:** After the tradition is set, do an act that belongs to a **different** tradition (e.g. an occult/Hidden
  Art signal while on Knight's Road). Re-open **Survey Devotion**.
- **See:** the **tradition does NOT switch** (start-locked in 1.0); instead a **cross-tradition pull** line
  appears in the Survey (*"You are being pulled toward another tradition..."*). Pressure accrues but never
  silently rewrites the tradition. No mid-game switch.
- **[Dev] log:** a `cross-tradition pressure` trace marker in Papyrus.0.log.
- **Record:** ___

### Slot 4c -- retired substrate absence (mixed inheritance)  [Tester] [R]+[M]
- **Do:** On a migrated Breton save or after any old ancestor-spine seed path, run one reward sync or pass a dawn.
  Open **Active Effects**, **Survey Devotion**, and the panel -> **Ledger** page after.
- **See:** no `Breton Inherited Ward`, no mixed-inheritance Survey line, and no new `breton-ancestor` Ledger row.
  The legacy records may still exist in the ESP, but the runtime path is retired for 1.0.
- **Record:** ___

### Slot 4d -- druidic fork: Werewolf (Green Way, new Prisma beat)  [Tester] [R]+[M]
- **Do:** On a **Green Way** Breton, drive the **Werewolf** fork (the beast-blood path; MCM Debug can force it).
- **See:** a **toast** -- *"The Green Way turns wild in you."* -- and a **Book of Days entry** -- *"The beast-blood
  took your Green Way down a wilder road. The Werewolf path is yours now."* The Survey fork line updates to the
  Werewolf wording.
- **Check the Book of Days line is NOT blank.**
- **Record:** ___

### Slot 4e -- druidic fork: Betrayed (Green Way, new Prisma beat)  [Tester] [R]+[M]
- **Do:** On a **Green Way** Breton, drive the **Betrayed** fork (break faith with the Green; MCM Debug can force it).
- **See:** a **toast** -- *"You broke faith with the Green."* -- and a **Book of Days entry** -- *"You turned from
  the Green Way's trust. The path remembers the betrayal."* The Survey fork line updates to the Betrayed wording.
- **Note:** only **Werewolf** and **Betrayed** are meaningful forks that surface. **None** and **Druidic** (the
  default Green Way state) are silent -- no toast/Chronicle.
- **Record:** ___

### Slot 4f -- tier-ups, curse, neglect (per universal)  [Tester] [R]+[M]
- **Do:** Force the chosen patron's piety to **25 / 50 / 85** with **Run Dawn** between; then drive a **curse**
  (rupture) and a **neglect** lapse (piety 0 + Run Dawn).
- **See:** Seeker/Devoted/Champion **toast + Book of Days** at each tier (Champion pinned); a **curse** toast +
  Book of Days note (a ruptured tradition closes the road until cured); a **neglect** toast + Book of Days note
  once on the first lapse. (Run these through the Universal Prisma sheet too.)
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 0` (Nord), then fire a Breton tradition/substrate seed/act. Reset
  with `set PDV_GLO_OriginRace to 2` after.
- **See:** **nothing Breton moves** -- no tradition write, no fork change, no cross-tradition pressure, no
  substrate driver, no markers. A non-Breton can't drive Breton state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as a Breton, do ordinary things that are NOT the coded hooks: generic spellcasting, owning a generic
  Daedric artifact, joining the College, generic help-without-reward, ordinary animal kills, casual shrine visits.
- **See:** **none of these score** tradition/exposure/vow/druidic or switch the tradition (only the real coded
  acts do). Casual tradition switching is a rejected hook.
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **tradition choice** read as a real, earned start-lock ("will not be
  easily swayed")? Does an off-tradition act feel like **quiet pressure** rather than a switch? Do the **Werewolf
  / Betrayed** forks read as meaningful turns in the Green Way? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Breton beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force patron piety + Run Dawn |
| tradition-choice (start-lock) | **Y** | **Y (pinned)** | N | startup choice / `DebugSetBretonTradition` |
| off-tradition -> cross-tradition pressure | N | N | N | off-tradition act (Survey line only) |
| retired substrate absence (breton-ancestor) | N | N | N | reward sync / dawn / old spine pulse cleanup |
| druidic-fork Werewolf | **Y** | **Y** | N | Green Way -> beast-blood path |
| druidic-fork Betrayed | **Y** | **Y** | N | Green Way -> break faith |
| druidic-fork None / Druidic | N | N | N | silent (default Green Way state) |
| curse (tradition rupture) | Y | Y | N | rupture pressure |
| neglect / dawn digest | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **Tradition is start-locked in 1.0.** Off-tradition acts build **cross-tradition pressure** (a counter
  surfaced in Survey) but do NOT switch the tradition -- a mid-game pressure-switch is deferred. If an
  off-tradition act flips the tradition, that's a regression -> FAIL.
- **Tradition is NOT a formal-offer race.** It's the startup choice + quiet pressure scaffolding -- there is no
  accept/refuse offer popup. Off-tradition acts feed the cross-tradition-pressure layer.
- **Only Werewolf and Betrayed forks surface.** None and Druidic (the default Green Way fork) are silent by
  design -- no missing toast there.
- **Breton substrate is retired in 1.0.** If `breton-ancestor` writes a new toast, Book of Days entry, Ledger
  driver, or `Breton Inherited Ward` active effect, FAIL.
- **`coc` skips location/behavioral triggers** -- walk/fast-travel in for any location- or sleep-keyed hook.
- **Champion + tradition-choice Book-of-Days entries are pinned** (survive pruning); ordinary entries prune at 21 days.
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | chosen-tradition blessing family live; others dormant | | |
| 2 Survey | tradition/vow/exposure/druidic/pressure legible; no mixed-inheritance copy | | |
| 3 stack | tradition reward layer, no rogue aura | | |
| 4a tradition-choice | toast + pinned BoD, non-empty, names tradition | | |
| 4b start-lock + pressure | off-tradition act -> pressure, NO switch | | |
| 4c retired substrate absence | no toast, no Ledger driver, no Breton Inherited Ward | | |
| 4d fork Werewolf | toast + BoD, non-empty; Survey updates | | |
| 4e fork Betrayed | toast + BoD, non-empty; Survey updates | | |
| 4f tier/curse/neglect | per-universal surfaces fire | | |
| 5 wrong-origin | Nord origin: zero Breton movement | | |
| 6 generic silence | generic cast/artifact/College do not score or switch | | |
| 7 felt | choice + start-lock + forks feel earned | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Breton `pass` until every row is filled.
