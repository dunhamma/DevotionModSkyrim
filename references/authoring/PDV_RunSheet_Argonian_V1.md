# PDV In-Game Run-Sheet -- Argonian (V1)

Status: V1 (Unit D Prisma live `5e9e502`; Hist potion = NEW build item this pass). Created 2026-06-25.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as an Argonian (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 7
   set PDV_GLO_DebugLevel to 2
   ```
   (`7` = Argonian. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 7`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. Daedric shrine prayers + quest reactions use the ARR
  variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects / inventory) the **Hist Sap potion** exists as a new `ALCH`
  record (`PDV_Potion_ArgonianHistSap`) and is in your inventory after race-confirm. It replaces the old book token.
- **See:** the potion is in inventory; no other Argonian hook needs a new mesh.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> seed `DebugSeedArgonian 90 60 0`; set Hist as primary and Force Piety to **85**. Then
  open **Survey Devotion** (in the panel / MCM status).
- **See:** the Argonian lines read like narration -- Hist relation depth, People/community, Sithis/Void, and a
  **Hist posture** line only when posture isn't Normal. No raw numbers/enum codes leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With Hist at Champion, open the **magic menu -> Active Effects**.
- **See:** the Hist reward effect(s) present, no duplicate/rogue auras, nothing bleeding from another race/mode.
- **Record:** ___

### Slot 4a -- Hist Sap potion loop (the new item)  [Tester] [R]+[M]
- **Do:**
  1. Open inventory, **drink the Hist Sap**.
  2. Open the Devotion panel -> **Ledger** page.
  3. Drink the Hist Sap **again the same day**.
- **See:** your **Hist piety goes up**; the **Hist Sap is still in your inventory** (count did not drop -- it
  refills itself); the **Ledger shows a new driver row** for the Hist act. The 2nd same-day drink **returns the
  vial but adds no extra piety** (daily cap).
- **[Dev] log:** a Hist award marker in Papyrus.0.log.
- **Record:** ___

### Slot 4b -- Hist hooks in normal play (the "outside QASmoke" proof)  [Tester] [R]
- **Do (play normally, no debug):** spend time **near/in water**, **sleep/rest**, and do a **community/people**
  act. Use a **load door or fast-travel** to reach water -- `coc` skips these. Open the **Ledger** after.
- **See:** each act lands a **Hist / People / Void driver row** in the Ledger during ordinary play (this is the
  proof the hooks fire in the real world, not just the test cell).
- **Record:** ___

### Slot 4c -- Hist-Adaptation milestone (new Prisma beat)  [Tester] [R]+[M]
- **Do:** trigger the **Hist Adaptation** rite (the permanent body-change choice; MCM Debug can force the gate).
- **See:** a **toast** -- *"The Hist has reshaped you."* -- and a **pinned Book of Days entry** -- *"You took the
  Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its
  image."* Fires once (it's permanent; use a fresh save to re-test).
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 4d -- Hist posture shift  [Tester] [R]+[M]
- **Do:** drive a posture change toward **Distant / Strained / Corrupted** (MCM Debug seed lower Hist, or take
  the curse). Then **sleep to the next dawn**.
- **See:** an **immediate shift toast** naming the new posture; at the **next dawn** the **Book of Days** records
  the change. Corrupted/Distant also **drain a little piety** (a separate Ledger row).
- **Record:** ___

### Slot 4e -- shadowscale / dream flavor  [Tester] [M]
- **Do:** reach the Void+people thresholds (Shadowscale Veil) and/or roll a strong posture (posture dream).
- **See:** a **flavor toast** (shadowscale activation / a posture-keyed dream). Pure flavor -- **no piety change,
  no Ledger row.**
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 0` (Nord), then fire an Argonian substrate seed/act. Reset with
  `set PDV_GLO_OriginRace to 7` after.
- **See:** **nothing Argonian moves** -- no Hist/People/Void, no markers. A non-Argonian can't drive Argonian state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as an Argonian, do ordinary things that are NOT the coded hooks: swim in circles, stand in water doing
  nothing, sleep at a random inn repeatedly, generic kills, one Dark Brotherhood join.
- **See:** **none of these score** Hist/People/Void (only the real coded acts do).
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **Hist Sap loop** feel good (drink -> the Hist answers -> you keep the
  vial)? Does the **Adaptation** read as a permanent, earned remaking? Do **posture shifts** read as the Hist
  drawing near/away rather than a debuff counter? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Argonian beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force Hist piety + Run Dawn |
| Hist substrate act (potion / water / rest / people) | Y | N | **Y (driver)** | drink potion / organic maintenance |
| Hist-Adaptation | **Y** | **Y (pinned)** | N | the adaptation rite |
| Hist-posture shift | Y | Y (next dawn) | N | lower Hist / curse |
| shadowscale / posture-dream | Y | N | N | Void+people thresholds / strong roll |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **The Hist Sap MUST refill itself.** If the count drops to 0 after drinking, the potion build is wrong -> FAIL.
- **Substrate Ledger driver is the key regression.** Argonian substrate used to record NO Ledger driver
  (the scaled-curated bug); it now should -- if the Ledger stays empty after a substrate act, FAIL.
- **Hist-Adaptation is once + permanent.** Re-test on a fresh save.
- **`coc` skips location triggers** -- walk/fast-travel to water/rest sites for Slot 4b.
- **Posture's Book-of-Days line lands at the NEXT dawn** (the toast is immediate).
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | Hist potion record + grant exist | | |
| 2 Survey | Hist/People/Void + posture legible | | |
| 3 stack | Hist reward layer, no rogue aura | | |
| 4a Hist potion loop | drink -> piety + vial returns; daily cap | | |
| 4b Hist hooks (organic) | water/rest/people/void drivers in normal play | | |
| 4c Hist-Adaptation | toast + pinned BoD, non-empty, once | | |
| 4d Hist posture | shift toast + next-dawn chronicle; Corrupted drains | | |
| 4e shadowscale/dream | flavor toasts, no piety | | |
| 5 wrong-origin | Nord origin: zero Argonian movement | | |
| 6 generic silence | swim/sleep/kill do not score | | |
| 7 felt | potion + adaptation feel earned | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Argonian `pass` until every row is filled.
