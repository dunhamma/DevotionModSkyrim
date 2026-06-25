# PDV In-Game Run-Sheet -- Orc (V1)

Status: V1 (Unit D Prisma live `5e9e502`; Trial of Iron 6f rite + lapse-to-City toast fix = build items
this pass). Created 2026-06-25. Refreshes the earlier `PDV_RunSheet_Orc_BetaFeel.md` draft to V1.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV__ManagerQuest.psc` (live source).

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

**Orc is a MONO race.** Only **Malacath** ever accrues piety -- there is no second patron, no broad
pantheon. The Orc layer instead carries a **life-mode** (Stronghold / City / Legion-Exile) that the world
confirms at startup and that shapes the reward ceiling, plus the **Trial of Iron** rite. If anything other
than Malacath shows up in the Ledger from an Orc act, that is a bug.

---

## Preflight (do once)
1. Start a **new save** as an Orc (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 8
   set PDV_GLO_DebugLevel to 2
   ```
   (`8` = Orc (`ORIGIN_ORC`). Every Orc life-mode hook is origin-gated on `GetOriginRaceValue()==8`.
   DebugLevel 2 turns on the log markers the owner checks.)
4. The **life-mode is world-confirmed at startup.** A fresh Orc starts in **City** (the steady default).
   The world moves you to Stronghold / Legion-Exile only through real beats (Blood-Kin, sworn service) or
   the accumulation gate -- see the tests. The MCM "Orc -> ..." buttons FORCE a mode for stack testing only;
   that is a SEED, never proof a world signal fired.
5. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`. The Orc controls you will use:
   "Orc -> City" / "Orc -> Stronghold" / "Orc -> Legion-Exile" (`DebugSetOrcLifeMode`), "Run dawn pass"
   (settles accumulated evidence without sleeping a full day), and the Force Piety control.
6. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 8`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. The life-mode reward ceiling (Stronghold steadier,
  City / Legion-Exile sharper) reads against the Requiem economy here.

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects / inventory) the **Trial of Iron** rite path exists: the
  `PDV_MESG_Orc_TrialOfIron` choice message and the four discipline spells
  (`PDV_SPEL_Orc_TrialOfIron_Tusk` / `_Shield` / ...). Malacath is the only Orc deity record.
- **See:** the rite message and discipline spells resolve; no second Orc patron exists; no Orc hook needs a new mesh.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> set Malacath as primary and Force Piety to **85**. Then open **Survey Devotion**
  (in the panel / MCM status).
- **See:** the Orc lines read the **committed life mode** (City / Stronghold / Legion-Exile), Malacath
  standing/tier, and curse pressure when present. KNOWN editorial gap -- the Orc Survey opens with
  dev-language and may leak the raw life-mode enum (all-race Survey rewrite, task #10). Note it; it is NOT a
  sole FAIL.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With Malacath at Champion in a single committed mode, open the **magic menu -> Active Effects**.
- **See:** exactly **one** life-mode reward family for the committed mode (Stronghold forge build vs.
  City / Legion-Exile edge build) plus the Malacath layer; **no cross-mode bleed**, no second substrate,
  no rogue aura from another race/mode. Any Trial of Iron discipline you took is clear-before-add (never two at once).
- **Record:** ___

### Slot 4a -- Trial of Iron rite (the new 6f rite)  [Tester] [R]+[M]
- **Do:**
  1. Trigger the **Trial of Iron** rite (MCM Debug can force the gate). Pick a discipline (Tusk / Shield / ...).
  2. Open the Devotion panel -> **Ledger** page.
  3. Trigger the rite **again the same week**.
- **See:** a **plain top-left notice** -- *"You take up a discipline of the Code. The Trial of Iron holds
  you to it."* -- and a **Book of Days entry** -- *"You took up a discipline in the Trial of Iron. The Code
  is held in iron."*; the **Ledger shows a new Malacath driver row** (*"Took up the Trial of Iron"*, +0.5).
  The 2nd attempt inside 7 days is **silent / returns "Not yet"** (the 7-day rite cooldown is the anti-farm cap).
- **IMPORTANT -- the transient notice is a plain `Debug.Notification`, NOT a Prisma overlay toast.** Per
  owner ruling R1 this is **intentional, not a gap**. The durable surfaces (Ledger driver + Book of Days
  entry) ARE Prisma-wired; only the flash notice is the vanilla top-left. Do NOT FAIL this for "no toast."
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **[Dev] log:** a Malacath award marker in Papyrus.0.log.
- **Record:** ___

### Slot 4b -- stronghold substrate act (toast + Ledger)  [Tester] [R]+[M]
- **Do (play normally, no debug):** reach an Orc stronghold by **load door or fast-travel** (`coc` skips the
  location trigger). Dushnikh Yal / Mor Khazgur / Narzulbur / Largashbur. Open the **Ledger** after.
- **See:** a **substrate toast** -- *"The code was marked."* (the stronghold token) -- AND a **Malacath
  driver row** lands in the Ledger for the stronghold act. This is `substrate.act.stronghold` = toast +
  Ledger driver. A single arrival is an **evidence day**; the committed mode does NOT flip on one arrival
  (no-flip gate). Re-entering the same day is silent (once/dawn guard).
- **Record:** ___

### Slot 4c -- life-mode reorientation (toast now + Book of Days at dawn)  [Tester] [R]+[M]
- **Do:** drive a **real mode switch**. Two ways:
  1. The instant gate -- resolve **DA06 The Cursed Tribe** (Blood-Kin) -> immediate switch to Stronghold.
  2. The accumulation gate -- log **two** mode-coded evidence days within seven (e.g. two stronghold
     arrivals, or seed via "Run dawn pass" after stronghold acts) -> switch settles at dawn.
- **See:** an **immediate shift toast** naming the new life mode (`reorientation.orc.lifemode`); at the
  **next dawn** the **Book of Days** records the change (it lands on the dawn snapshot diff, not at the
  switch instant). A confirmed switch holds a **3-day lock-in**.
- **Record:** ___

### Slot 4d -- the lapse-to-City fix (silent 14-day lapse now toasts)  [Tester] [R]+[M]
- **Do:** get into **Stronghold or Legion-Exile**, then let the mode go stale -- **no mode-coded evidence
  for 14 days** (sleep/wait days out, or seed the clock, then "Run dawn pass"). The mode lapses back to
  **City**, the steady default.
- **See:** the lapse-to-City now **fires a shift toast** and the **next-dawn Book of Days** entry, **exactly
  like an explicit switch**. This is the FIX -- the silent 14-day lapse used to route directly through
  `SetState` and fire NO toast; it now routes through `ApplyOrcLifeModeSwitch` (reason
  `orc_dawn_lapse_to_city`). If the lapse happens with NO toast, the regression is back -> FAIL.
- **Record:** ___

### Slot 4e -- mono check (only Malacath in the Ledger)  [Tester] [R]
- **Do:** award Orc piety any way above (Trial of Iron, stronghold act, tier-up). Open the **Ledger** and
  read every driver row's god.
- **See:** **only Malacath** ever shows. No other deity (Mara, Stendarr, Talos, a Prince...) accrues from an
  Orc act. Orc is mono -- a second god in the Ledger = a mis-routed signal = FAIL.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 7` (non-Orc), then fire an Orc act (arrive a stronghold via
  load door; trigger the rite). Reset with `set PDV_GLO_OriginRace to 8` after.
- **See:** **nothing Orc moves** -- no life-mode evidence day, no committed-mode change, no Malacath
  movement, no markers. A non-Orc can't drive Orc state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as an Orc, do ordinary things that are NOT the coded hooks: raw smithing/crafting, generic
  combat kills, ore mining, vendor sales, a brawl, ordinary (non-stronghold) city presence, **CW01A Legion
  membership join alone**, **CW02B (Stormcloak Jagged Crown)**, Hearthfire land/plot building.
- **See:** **none of these** record an Orc life-mode evidence day, move the committed mode, or score
  Malacath (only the real coded acts do). A Stormcloak finale must NOT fire the Legion-Exile capstone.
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **Trial of Iron** read as a sworn discipline held in iron (and is
  the plain notice fine for it, vs. wanting a louder toast)? Do the three life modes read as authored
  **social circumstance**, not different theology? Does **Blood-Kin** feel like a major instant beat while
  soft signals feel like they **accumulate** toward a switch? Does the **lapse to City** read as the
  Stronghold/Legion life quietly fading rather than a silent reset? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Orc beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force Malacath piety + Run Dawn |
| rite.orc.trial-of-iron | **N (plain Debug.Notification, by ruling R1)** | **Y** | **Y (driver)** | the Trial of Iron rite |
| substrate.act.stronghold | **Y** | N | **Y (driver)** | stronghold arrival (load door / fast-travel) |
| reorientation.orc.lifemode (switch) | **Y** | **Y (next dawn)** | N | Blood-Kin / 2-of-7 evidence days |
| reorientation.orc.lifemode (lapse-to-City) | **Y (fixed)** | **Y (next dawn)** | N | 14 days no mode evidence |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **The Trial of Iron transient notice is a plain top-left, ON PURPOSE.** Per owner ruling R1 the rite's
  flash notice is a vanilla `Debug.Notification`, NOT a Prisma overlay toast. The Ledger driver + Book of
  Days entry ARE the durable Prisma surfaces. Do NOT FAIL it for "no Prisma toast."
- **Orc is mono -- only Malacath.** Any other god in the Ledger from an Orc act is a mis-route -> FAIL.
- **Substrate Ledger driver is a key regression check.** A stronghold act must land BOTH a toast and a
  Malacath driver row. If the Ledger stays empty after a stronghold act, FAIL.
- **The lapse-to-City fix.** The 14-day silent lapse used to fire NO toast; it must now toast + chronicle
  like an explicit switch (reason `orc_dawn_lapse_to_city`). No toast on lapse = regression -> FAIL.
- **`coc` skips location triggers** -- walk/fast-travel into strongholds for Slot 4b. `coc` does NOT fire
  `OnStoryChangeLocation`.
- **No instant flip on a single soft signal.** One stronghold arrival / one Thane / one home / one CW
  milestone is an evidence DAY, not a switch. Two mode-coded days within seven (settled at dawn) flip it;
  a 3-day lock-in holds it. Blood-Kin (DA06 resolved) is the one instant exception. A single-signal
  non-flip is a PASS for the no-flip gate, not a miss.
- **Forcing a mode in MCM is a SEED, not proof.** `DebugSetOrcLifeMode` writes the committed mode directly
  -- it proves the reward stack, not that a world signal moved the state.
- **Book-of-Days line for a switch/lapse lands at the NEXT dawn** (the toast is immediate).
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | Trial of Iron message + discipline spells exist; Malacath is sole deity | | |
| 2 Survey | life mode + Malacath + curse legible (dev-language gap noted) | | |
| 3 stack | one life-mode reward family, no cross-mode bleed | | |
| 4a Trial of Iron | rite -> Ledger driver + BoD entry; plain notice (R1); 7-day cooldown | | |
| 4b stronghold substrate | toast + Malacath driver on stronghold arrival | | |
| 4c reorientation switch | shift toast now + next-dawn BoD; Blood-Kin instant, soft accumulates | | |
| 4d lapse-to-City fix | 14-day lapse toasts + chronicles like a switch | | |
| 4e mono check | only Malacath appears in the Ledger | | |
| 5 wrong-origin | non-Orc origin: zero Orc movement | | |
| 6 generic silence | craft/combat/mining/vendor/CW01A/CW02B/Hearthfire do not score | | |
| 7 felt | rite + modes + lapse feel earned and social | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Orc `pass` until every row is filled.
